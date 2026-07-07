// Softanza Engine -- TextRank (Mihalcea & Tarau 2004)
//
// Graph-based ranking (PageRank) over text, model-free and deterministic:
//   * str_textrank_keywords: nodes = content words, edges = co-occurrence within
//     a sliding window; PageRank -> the most "central" terms.
//   * str_summarize: nodes = sentences, edge weight = word-overlap similarity;
//     PageRank -> the most central sentences = an extractive summary (emitted in
//     original reading order).
// Complements RAKE (textutil): RAKE scores phrases locally; TextRank scores by
// global graph centrality. Reuses the embedded stopword set via textutil.

const std = @import("std");
const core = @import("core.zig");
const wb = @import("word_break.zig");
const textutil = @import("textutil.zig");
const gpa = core.gpa;
const StzStringHandle = core.StzStringHandle;
const str_new = core.str_new;

const DAMPING: f64 = 0.85;
const ITERATIONS: usize = 40;
const WINDOW: usize = 4; // co-occurrence window for keywords

// Weighted PageRank on an adjacency-list graph. adj[i] maps neighbor -> weight;
// wsum[i] = total outgoing weight. Returns scores (caller frees).
fn pageRank(n: usize, adj: []const std.AutoHashMap(usize, f64), wsum: []const f64) ?[]f64 {
    var score = gpa.alloc(f64, n) catch return null;
    var next = gpa.alloc(f64, n) catch {
        gpa.free(score);
        return null;
    };
    const base = (1.0 - DAMPING);
    for (score) |*s| s.* = 1.0;
    var it: usize = 0;
    while (it < ITERATIONS) : (it += 1) {
        for (0..n) |i| next[i] = base;
        for (0..n) |j| {
            if (wsum[j] == 0) continue;
            const contrib = DAMPING * score[j] / wsum[j];
            var e = adj[j].iterator();
            while (e.next()) |kv| {
                next[kv.key_ptr.*] += contrib * kv.value_ptr.*;
            }
        }
        const tmp = score;
        score = next;
        next = tmp;
    }
    gpa.free(next);
    return score;
}

fn addEdge(adj: []std.AutoHashMap(usize, f64), a: usize, b: usize, w: f64) void {
    const ga = adj[a].getOrPut(b) catch return;
    if (!ga.found_existing) ga.value_ptr.* = 0;
    ga.value_ptr.* += w;
}

// ---- Keywords ---------------------------------------------------------------
pub fn str_textrank_keywords(handle: StzStringHandle, n_top: c_int) callconv(.c) StzStringHandle {
    const result = str_new() orelse return null;
    const s = handle orelse return result;
    const src = s.slice();

    // content-word node sequence (lowercased key -> node id)
    var vocab = std.StringHashMap(usize).init(gpa);
    defer {
        var it = vocab.keyIterator();
        while (it.next()) |k| gpa.free(k.*);
        vocab.deinit();
    }
    var reps = std.ArrayList([]const u8){}; // original-case representative per node
    defer reps.deinit(gpa);
    var seq = std.ArrayList(usize){}; // node id per content word, in order
    defer seq.deinit(gpa);

    var lb: [256]u8 = undefined;
    var wit = wb.WordIter.init(src);
    while (wit.next()) |sp| {
        const w = src[sp.start..sp.end];
        const key = textutil.lowerAsciiInto(w, &lb);
        if (textutil.isStopwordLower(key)) continue;
        if (key.len < 2) continue; // skip single letters/punctuation-ish
        const gp = vocab.getOrPut(key) catch continue;
        if (!gp.found_existing) {
            const owned = gpa.dupe(u8, key) catch continue;
            gp.key_ptr.* = owned;
            gp.value_ptr.* = reps.items.len;
            reps.append(gpa, w) catch {};
        }
        seq.append(gpa, gp.value_ptr.*) catch {};
    }
    const n = reps.items.len;
    if (n == 0) return result;

    // build graph
    var adj = gpa.alloc(std.AutoHashMap(usize, f64), n) catch return result;
    defer {
        for (0..n) |i| adj[i].deinit();
        gpa.free(adj);
    }
    for (0..n) |i| adj[i] = std.AutoHashMap(usize, f64).init(gpa);
    for (seq.items, 0..) |a, i| {
        var k = i + 1;
        const end = @min(i + WINDOW, seq.items.len);
        while (k < end) : (k += 1) {
            const b = seq.items[k];
            if (a == b) continue;
            addEdge(adj, a, b, 1.0);
            addEdge(adj, b, a, 1.0);
        }
    }
    var wsum = gpa.alloc(f64, n) catch return result;
    defer gpa.free(wsum);
    for (0..n) |i| {
        var t: f64 = 0;
        var e = adj[i].valueIterator();
        while (e.next()) |v| t += v.*;
        wsum[i] = t;
    }

    const score = pageRank(n, adj, wsum) orelse return result;
    defer gpa.free(score);

    // rank node ids by score desc (stable by first-appearance)
    var order = gpa.alloc(usize, n) catch return result;
    defer gpa.free(order);
    for (0..n) |i| order[i] = i;
    const Ctx = struct { sc: []const f64 };
    std.mem.sort(usize, order, Ctx{ .sc = score }, struct {
        fn lt(c: Ctx, a: usize, b: usize) bool {
            return c.sc[a] > c.sc[b];
        }
    }.lt);

    const limit: usize = if (n_top <= 0) n else @min(@as(usize, @intCast(n_top)), n);
    var i: usize = 0;
    while (i < limit) : (i += 1) {
        const id = order[i];
        if (i > 0) result.data.append(gpa, 0) catch break;
        result.data.appendSlice(gpa, reps.items[id]) catch break;
        result.data.append(gpa, 1) catch break;
        var nb: [32]u8 = undefined;
        const ns = std.fmt.bufPrint(&nb, "{d:.4}", .{score[id]}) catch "0";
        result.data.appendSlice(gpa, ns) catch break;
    }
    return result;
}

// ---- Extractive summary -----------------------------------------------------
const Sent = struct { start: usize, end: usize, words: std.StringHashMap(void) };

fn sentWordCount(s: *const Sent) usize {
    return s.words.count();
}

pub fn str_summarize(handle: StzStringHandle, n_sent: c_int) callconv(.c) StzStringHandle {
    const result = str_new() orelse return null;
    const s = handle orelse return result;
    const src = s.slice();

    var sents = std.ArrayList(Sent){};
    defer {
        for (sents.items) |*sd| {
            var it = sd.words.keyIterator();
            while (it.next()) |k| gpa.free(k.*);
            sd.words.deinit();
        }
        sents.deinit(gpa);
    }

    var lb: [256]u8 = undefined;
    var sit = wb.SentenceIter.init(src);
    while (sit.next()) |span| {
        var a = span.start;
        var b = span.end;
        while (a < b and (src[a] == ' ' or src[a] == '\t' or src[a] == '\n' or src[a] == '\r')) a += 1;
        while (b > a and (src[b - 1] == ' ' or src[b - 1] == '\t' or src[b - 1] == '\n' or src[b - 1] == '\r')) b -= 1;
        if (b <= a) continue;
        var words = std.StringHashMap(void).init(gpa);
        var wit = wb.WordIter.init(src[a..b]);
        while (wit.next()) |wp| {
            const w = src[a + wp.start .. a + wp.end];
            const key = textutil.lowerAsciiInto(w, &lb);
            if (textutil.isStopwordLower(key)) continue;
            if (key.len < 2) continue;
            if (!words.contains(key)) {
                const owned = gpa.dupe(u8, key) catch continue;
                words.put(owned, {}) catch gpa.free(owned);
            }
        }
        sents.append(gpa, .{ .start = a, .end = b, .words = words }) catch {
            var it = words.keyIterator();
            while (it.next()) |k| gpa.free(k.*);
            words.deinit();
        };
    }
    const n = sents.items.len;
    if (n == 0) return result;
    if (n == 1) {
        result.data.appendSlice(gpa, src[sents.items[0].start..sents.items[0].end]) catch {};
        return result;
    }

    // similarity graph: common words / (log|Si| + log|Sj|)
    var adj = gpa.alloc(std.AutoHashMap(usize, f64), n) catch return result;
    defer {
        for (0..n) |i| adj[i].deinit();
        gpa.free(adj);
    }
    for (0..n) |i| adj[i] = std.AutoHashMap(usize, f64).init(gpa);
    var wsum = gpa.alloc(f64, n) catch return result;
    defer gpa.free(wsum);
    @memset(wsum, 0);

    for (0..n) |i| {
        const li = sentWordCount(&sents.items[i]);
        if (li == 0) continue;
        for (i + 1..n) |j| {
            const lj = sentWordCount(&sents.items[j]);
            if (lj == 0) continue;
            // count common words (iterate smaller set)
            var common: usize = 0;
            var it = sents.items[i].words.keyIterator();
            while (it.next()) |k| {
                if (sents.items[j].words.contains(k.*)) common += 1;
            }
            if (common == 0) continue;
            const denom = @log(@as(f64, @floatFromInt(li)) + 1.0) + @log(@as(f64, @floatFromInt(lj)) + 1.0);
            if (denom <= 0) continue;
            const w = @as(f64, @floatFromInt(common)) / denom;
            adj[i].put(j, w) catch {};
            adj[j].put(i, w) catch {};
            wsum[i] += w;
            wsum[j] += w;
        }
    }

    const score = pageRank(n, adj, wsum) orelse return result;
    defer gpa.free(score);

    // pick top-k sentence indices, then emit in ORIGINAL order
    var order = gpa.alloc(usize, n) catch return result;
    defer gpa.free(order);
    for (0..n) |i| order[i] = i;
    const Ctx = struct { sc: []const f64 };
    std.mem.sort(usize, order, Ctx{ .sc = score }, struct {
        fn lt(c: Ctx, a: usize, b: usize) bool {
            return c.sc[a] > c.sc[b];
        }
    }.lt);

    const k: usize = if (n_sent <= 0) n else @min(@as(usize, @intCast(n_sent)), n);
    var pick = gpa.alloc(bool, n) catch return result;
    defer gpa.free(pick);
    @memset(pick, false);
    for (0..k) |i| pick[order[i]] = true;

    var first = true;
    for (0..n) |i| {
        if (!pick[i]) continue;
        if (!first) result.data.append(gpa, 0) catch break;
        result.data.appendSlice(gpa, src[sents.items[i].start..sents.items[i].end]) catch break;
        first = false;
    }
    return result;
}

const testing = std.testing;
const str_from = core.str_from;
const str_free = core.str_free;

test "textrank keywords + summary run" {
    const txt = "Natural language processing enables computers to understand human language. Machine learning models power modern natural language processing. Language models learn patterns from large text corpora. These models improve many language tasks.";
    const s = str_from(txt, txt.len) orelse return error.SkipZigTest;
    defer str_free(s);
    const kw = str_textrank_keywords(s, 3) orelse return error.SkipZigTest;
    defer str_free(kw);
    try testing.expect(kw.slice().len > 0);
    const sm = str_summarize(s, 2) orelse return error.SkipZigTest;
    defer str_free(sm);
    try testing.expect(sm.slice().len > 0);
}
