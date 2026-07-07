// Softanza Engine -- Part-of-speech tagging (averaged perceptron)
//
// Penn-Treebank POS tags (NN, VB, DT, JJ, ...) via Honnibal's averaged-perceptron
// tagger -- the same model NLTK ships. Deterministic, fast (no ML runtime): the
// trained model (NLTK averaged_perceptron_tagger, Apache-2.0) is exported to a
// compact form and COMPILED IN via @embedFile (classes + word->tag fast-path
// dict + 75k feature weights). This is the keystone the NER layer builds on.
//
// Faithful reimplementation of the tagger's feature templates, word
// normalization and (score, tag) argmax tie-break, so the vendored weights apply
// exactly. Words are tokenized through the UAX#29 seam (WordIter).

const std = @import("std");
const core = @import("core.zig");
const wb = @import("word_break.zig");
const mem = core.mem;
const gpa = core.gpa;
const StzStringHandle = core.StzStringHandle;
const str_new = core.str_new;

const classes_data = @embedFile("data/pos_classes.txt");
const tagdict_data = @embedFile("data/pos_tagdict.txt");
const weights_data = @embedFile("data/pos_weights.txt");

const TagW = struct { tag: u8, w: f32 };

var g_built = false;
var g_classes: std.ArrayList([]const u8) = .{};
var g_tagdict: std.StringHashMap([]const u8) = undefined; // word -> tag string
var g_weights: std.StringHashMap([]TagW) = undefined; // feature -> [(tag,weight)]

fn buildTables() void {
    if (g_built) return;
    g_tagdict = std.StringHashMap([]const u8).init(gpa);
    g_weights = std.StringHashMap([]TagW).init(gpa);

    var ci = std.mem.splitScalar(u8, classes_data, '\n');
    while (ci.next()) |raw| {
        const t = std.mem.trimRight(u8, raw, "\r");
        if (t.len > 0) g_classes.append(gpa, t) catch {};
    }
    var ti = std.mem.splitScalar(u8, tagdict_data, '\n');
    while (ti.next()) |raw| {
        const line = std.mem.trimRight(u8, raw, "\r");
        const tab = std.mem.indexOfScalar(u8, line, '\t') orelse continue;
        g_tagdict.put(line[0..tab], line[tab + 1 ..]) catch {};
    }
    var wi = std.mem.splitScalar(u8, weights_data, '\n');
    while (wi.next()) |raw| {
        const line = std.mem.trimRight(u8, raw, "\r");
        const tab = std.mem.indexOfScalar(u8, line, '\t') orelse continue;
        const feat = line[0..tab];
        // count pairs
        var cnt: usize = 0;
        var pit = std.mem.splitScalar(u8, line[tab + 1 ..], ' ');
        while (pit.next()) |p| {
            if (p.len > 0) cnt += 1;
        }
        if (cnt == 0) continue;
        const arr = gpa.alloc(TagW, cnt) catch continue;
        var k: usize = 0;
        pit = std.mem.splitScalar(u8, line[tab + 1 ..], ' ');
        while (pit.next()) |p| {
            if (p.len == 0) continue;
            const colon = std.mem.indexOfScalar(u8, p, ':') orelse continue;
            const tag = std.fmt.parseInt(u8, p[0..colon], 10) catch continue;
            const w = std.fmt.parseFloat(f32, p[colon + 1 ..]) catch continue;
            arr[k] = .{ .tag = tag, .w = w };
            k += 1;
        }
        g_weights.put(feat, arr[0..k]) catch {};
    }
    g_built = true;
}

fn isDigit(c: u8) bool {
    return c >= '0' and c <= '9';
}

// Honnibal normalization: !HYPHEN / !YEAR / !DIGITS / lowercase.
fn normalize(word: []const u8, buf: []u8) []const u8 {
    if (word.len == 0) return word;
    if (word[0] != '-' and std.mem.indexOfScalar(u8, word, '-') != null) return "!HYPHEN";
    var alldig = true;
    for (word) |c| {
        if (!isDigit(c)) {
            alldig = false;
            break;
        }
    }
    if (alldig) return if (word.len == 4) "!YEAR" else "!DIGITS";
    if (isDigit(word[0])) return "!DIGITS";
    if (word.len > buf.len) return word;
    for (word, 0..) |c, i| buf[i] = if (c >= 'A' and c <= 'Z') c + 32 else c;
    return buf[0..word.len];
}

fn suffix3(s: []const u8) []const u8 {
    return if (s.len <= 3) s else s[s.len - 3 ..];
}

const START1 = "-START-";
const START2 = "-START2-";
const END1 = "-END-";
const END2 = "-END2-";

// Accumulate weights for one built feature string into `scores`.
fn addFeature(feat: []const u8, scores: []f64) void {
    if (g_weights.get(feat)) |arr| {
        for (arr) |tw| scores[tw.tag] += tw.w;
    }
}

// Build "prefix arg1 [arg2]" into buf and score it.
fn feat1(scores: []f64, buf: []u8, prefix: []const u8, a: []const u8) void {
    const n = prefix.len + 1 + a.len;
    if (n > buf.len) return;
    @memcpy(buf[0..prefix.len], prefix);
    buf[prefix.len] = ' ';
    @memcpy(buf[prefix.len + 1 ..][0..a.len], a);
    addFeature(buf[0..n], scores);
}

fn feat2(scores: []f64, buf: []u8, prefix: []const u8, a: []const u8, b: []const u8) void {
    const n = prefix.len + 1 + a.len + 1 + b.len;
    if (n > buf.len) return;
    var o: usize = 0;
    @memcpy(buf[o..][0..prefix.len], prefix);
    o += prefix.len;
    buf[o] = ' ';
    o += 1;
    @memcpy(buf[o..][0..a.len], a);
    o += a.len;
    buf[o] = ' ';
    o += 1;
    @memcpy(buf[o..][0..b.len], b);
    addFeature(buf[0..n], scores);
}

// Predict the tag for token index `ti` (0-based) given normalized context (with
// 2 START + 2 END padding, so context[ti+2] is the current word), original word,
// and the two previous tags.
fn predict(ti: usize, word: []const u8, context: [][]const u8, prev: []const u8, prev2: []const u8) u8 {
    var scores = [_]f64{0} ** 64;
    var fbuf: [256]u8 = undefined;
    const ci = ti + 2;

    addFeature("bias", &scores);
    feat1(&scores, &fbuf, "i suffix", suffix3(word));
    feat1(&scores, &fbuf, "i pref1", word[0..1]);
    feat1(&scores, &fbuf, "i-1 tag", prev);
    feat1(&scores, &fbuf, "i-2 tag", prev2);
    feat2(&scores, &fbuf, "i tag+i-2 tag", prev, prev2);
    feat1(&scores, &fbuf, "i word", context[ci]);
    feat2(&scores, &fbuf, "i-1 tag+i word", prev, context[ci]);
    feat1(&scores, &fbuf, "i-1 word", context[ci - 1]);
    feat1(&scores, &fbuf, "i-1 suffix", suffix3(context[ci - 1]));
    feat1(&scores, &fbuf, "i-2 word", context[ci - 2]);
    feat1(&scores, &fbuf, "i+1 word", context[ci + 1]);
    feat1(&scores, &fbuf, "i+1 suffix", suffix3(context[ci + 1]));
    feat1(&scores, &fbuf, "i+2 word", context[ci + 2]);

    // argmax over classes; tie -> lexicographically-largest tag (classes are
    // sorted ascending, so higher index).
    var best: f64 = -std.math.inf(f64);
    var besti: u8 = 0;
    const nc = g_classes.items.len;
    var t: u8 = 0;
    while (t < nc) : (t += 1) {
        if (scores[t] > best) {
            best = scores[t];
            besti = t;
        } else if (scores[t] == best and t > besti) {
            besti = t;
        }
    }
    return besti;
}

// Tag a list of word tokens; returns an allocated array of tag strings (static
// slices into the embedded classes data). Caller frees the outer slice. Shared
// by str_pos_tags and the NER layer.
pub fn tagTokens(toks: [][]const u8) ?[][]const u8 {
    buildTables();
    const n = toks.len;
    const tags = gpa.alloc([]const u8, n) catch return null;
    if (n == 0) return tags;
    const context = gpa.alloc([]const u8, n + 4) catch {
        gpa.free(tags);
        return null;
    };
    defer gpa.free(context);
    const normbufs = gpa.alloc([64]u8, n) catch {
        gpa.free(tags);
        return null;
    };
    defer gpa.free(normbufs);
    context[0] = START1;
    context[1] = START2;
    context[n + 2] = END1;
    context[n + 3] = END2;
    for (toks, 0..) |tok, idx| context[idx + 2] = normalize(tok, &normbufs[idx]);

    var prev: []const u8 = START1;
    var prev2: []const u8 = START2;
    var idx: usize = 0;
    while (idx < n) : (idx += 1) {
        var tag: []const u8 = undefined;
        if (g_tagdict.get(toks[idx])) |td| {
            tag = td;
        } else {
            tag = g_classes.items[predict(idx, toks[idx], context, prev, prev2)];
        }
        tags[idx] = tag;
        prev2 = prev;
        prev = tag;
    }
    return tags;
}

// Tag every word token; return the tags NUL-delimited, aligned with WordIter/Words().
pub fn str_pos_tags(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const result = str_new() orelse return null;
    const s = handle orelse return result;
    const src = s.slice();
    var toks: std.ArrayList([]const u8) = .{};
    defer toks.deinit(gpa);
    {
        var wit = wb.WordIter.init(src);
        while (wit.next()) |sp| toks.append(gpa, src[sp.start..sp.end]) catch {};
    }
    if (toks.items.len == 0) return result;
    const tags = tagTokens(toks.items) orelse return result;
    defer gpa.free(tags);
    for (tags, 0..) |t, i| {
        if (i > 0) result.data.append(gpa, 0) catch break;
        result.data.appendSlice(gpa, t) catch break;
    }
    return result;
}

const testing = std.testing;
const str_from = core.str_from;
const str_free = core.str_free;

test "pos tags a simple sentence" {
    const s = str_from("The quick brown fox jumps", 25) orelse return error.SkipZigTest;
    defer str_free(s);
    const r = str_pos_tags(s) orelse return error.SkipZigTest;
    defer str_free(r);
    // DT JJ JJ NN VBZ  (NUL-delimited)
    try testing.expect(std.mem.startsWith(u8, r.slice(), "DT"));
}
