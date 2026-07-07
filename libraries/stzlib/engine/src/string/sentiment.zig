// Softanza Engine -- Sentiment analysis (VADER)
//
// VADER (Hutto & Gilbert 2014): a rule-based sentiment model tuned for general
// and social text. Lexicon-backed valence + five heuristics (caps emphasis,
// degree boosters with distance damping, negation, contrastive "but", and
// punctuation emphasis), normalized to a compound score in [-1, 1].
//
// Fully deterministic, no ML/model files: the sentiment lexicon
// (src/string/data/vader_lexicon.txt, MIT, ~7500 terms) is COMPILED IN via
// @embedFile; the booster/negation word lists are inline. English.

const std = @import("std");
const core = @import("core.zig");
const mem = core.mem;
const gpa = core.gpa;
const StzStringHandle = core.StzStringHandle;
const str_new = core.str_new;

const lexicon_data = @embedFile("data/vader_lexicon.txt");

const B_INCR: f64 = 0.293;
const B_DECR: f64 = -0.293;
const C_INCR: f64 = 0.733;
const N_SCALAR: f64 = -0.74;

var g_built = false;
var g_lex: std.StringHashMap(f64) = undefined;

fn buildLex() void {
    if (g_built) return;
    g_lex = std.StringHashMap(f64).init(gpa);
    var it = std.mem.splitScalar(u8, lexicon_data, '\n');
    while (it.next()) |raw| {
        const line = std.mem.trimRight(u8, raw, "\r");
        if (line.len == 0) continue;
        const tab = std.mem.indexOfScalar(u8, line, '\t') orelse continue;
        const tok = line[0..tab];
        const val = std.fmt.parseFloat(f64, line[tab + 1 ..]) catch continue;
        g_lex.put(tok, val) catch {};
    }
    g_built = true;
}

fn eqAny(w: []const u8, comptime list: []const []const u8) bool {
    inline for (list) |x| {
        if (mem.eql(u8, w, x)) return true;
    }
    return false;
}

fn boosterScalarBase(w: []const u8) f64 {
    if (eqAny(w, &.{ "absolutely", "amazingly", "awfully", "completely", "considerable", "considerably", "decidedly", "deeply", "effing", "enormous", "enormously", "entirely", "especially", "exceptional", "exceptionally", "extreme", "extremely", "fabulously", "flipping", "flippin", "frickin", "friggin", "fully", "fucking", "greatly", "hella", "highly", "hugely", "incredible", "incredibly", "intensely", "major", "majorly", "more", "most", "particularly", "purely", "quite", "really", "remarkably", "so", "substantially", "thoroughly", "total", "totally", "tremendous", "tremendously", "uber", "unbelievably", "unusually", "utterly", "very" })) return B_INCR;
    if (eqAny(w, &.{ "almost", "barely", "hardly", "less", "little", "marginal", "marginally", "occasional", "occasionally", "partly", "scarce", "scarcely", "slight", "slightly", "somewhat", "sorta", "sortof", "kinda", "kindof" })) return B_DECR;
    return 0;
}

fn isNegation(w: []const u8) bool {
    if (eqAny(w, &.{ "aint", "arent", "cannot", "cant", "couldnt", "darent", "didnt", "doesnt", "dont", "hadnt", "hasnt", "havent", "isnt", "mightnt", "mustnt", "neither", "neednt", "never", "none", "nope", "nor", "not", "nothing", "nowhere", "oughtnt", "shant", "shouldnt", "uhuh", "wasnt", "werent", "without", "wont", "wouldnt", "rarely", "seldom", "despite", "ain't", "aren't", "can't", "couldn't", "daren't", "didn't", "doesn't", "don't", "hadn't", "hasn't", "haven't", "isn't", "mightn't", "mustn't", "needn't", "oughtn't", "shan't", "shouldn't", "wasn't", "weren't", "won't", "wouldn't", "uh-uh" })) return true;
    return mem.indexOf(u8, w, "n't") != null;
}

// A token = a whitespace-delimited run (slice into the source).
const Tok = struct { s: []const u8 };

fn isAllCap(t: []const u8) bool {
    var has_letter = false;
    for (t) |c| {
        if (c >= 'a' and c <= 'z') return false;
        if (c >= 'A' and c <= 'Z') has_letter = true;
    }
    return has_letter and t.len > 1;
}

// Lowercase + strip leading/trailing ASCII punctuation for lexicon lookup.
fn lowerStrip(t: []const u8, buf: []u8) []const u8 {
    var s: usize = 0;
    var e: usize = t.len;
    while (s < e and !isWordish(t[s])) s += 1;
    while (e > s and !isWordish(t[e - 1])) e -= 1;
    // if nothing wordish (pure punctuation, e.g. an emoticon), keep the raw token
    const src = if (s < e) t[s..e] else t;
    if (src.len > buf.len) return src;
    for (src, 0..) |c, i| buf[i] = if (c >= 'A' and c <= 'Z') c + 32 else c;
    return buf[0..src.len];
}

fn isWordish(c: u8) bool {
    return (c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z') or (c >= '0' and c <= '9') or c >= 0x80 or c == '\'';
}

fn normalize(score: f64) f64 {
    const n = score / @sqrt(score * score + 15.0);
    if (n > 1.0) return 1.0;
    if (n < -1.0) return -1.0;
    return n;
}

fn punctuationEmphasis(text: []const u8) f64 {
    var ep: usize = 0;
    var qm: usize = 0;
    for (text) |c| {
        if (c == '!') ep += 1;
        if (c == '?') qm += 1;
    }
    if (ep > 4) ep = 4;
    var amp: f64 = @as(f64, @floatFromInt(ep)) * 0.292;
    if (qm > 1) amp += if (qm > 3) 0.96 else @as(f64, @floatFromInt(qm)) * 0.18;
    return amp;
}

pub const Scores = struct { compound: f64, pos: f64, neg: f64, neu: f64 };

// Whitespace-tokenize `text` into `toks` and return the allocated per-token net
// VADER valences (after caps/booster/negation/but). Caller frees the slice and
// deinits `toks`. Returns null on empty input / OOM. Shared by analyze() and
// str_sentiment_explained so the explanation matches the score exactly.
fn tokenizeAndScore(text: []const u8, toks: *std.ArrayList(Tok)) ?[]f64 {
    buildLex();
    {
        var i: usize = 0;
        while (i < text.len) {
            while (i < text.len and (text[i] == ' ' or text[i] == '\t' or text[i] == '\n' or text[i] == '\r')) i += 1;
            if (i >= text.len) break;
            const start = i;
            while (i < text.len and !(text[i] == ' ' or text[i] == '\t' or text[i] == '\n' or text[i] == '\r')) i += 1;
            toks.append(gpa, .{ .s = text[start..i] }) catch {};
        }
    }
    const n = toks.items.len;
    if (n == 0) return null;

    // ALL-CAPS differential: some (but not all) tokens are ALL CAPS.
    var caps: usize = 0;
    for (toks.items) |t| {
        if (isAllCap(t.s)) caps += 1;
    }
    const cap_diff = caps > 0 and caps != n;

    var sentiments = gpa.alloc(f64, n) catch return null;

    var lbuf: [128]u8 = undefined;
    var pbuf: [128]u8 = undefined;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        var v: f64 = 0;
        const wl = lowerStrip(toks.items[i].s, &lbuf);
        // booster words themselves carry no sentiment
        if (boosterScalarBase(wl) == 0) {
            if (g_lex.get(wl)) |lv| {
                v = lv;
                if (isAllCap(toks.items[i].s) and cap_diff) v += if (v > 0) C_INCR else -C_INCR;
                var si: usize = 0;
                while (si < 3) : (si += 1) {
                    if (i <= si) break;
                    const prev = lowerStrip(toks.items[i - si - 1].s, &pbuf);
                    if (g_lex.get(prev) != null) continue;
                    var s = boosterScalarBase(prev);
                    if (s != 0) {
                        if (v < 0) s = -s;
                        if (isAllCap(toks.items[i - si - 1].s) and cap_diff) s += if (v > 0) C_INCR else -C_INCR;
                        if (si == 1) s *= 0.95;
                        if (si == 2) s *= 0.9;
                    }
                    v += s;
                    v = negationCheck(v, toks.items, si, i, &pbuf);
                }
            }
        }
        sentiments[i] = v;
    }

    butCheck(toks.items, sentiments, &lbuf);
    return sentiments;
}

// Strip leading/trailing non-wordish bytes WITHOUT lowercasing (display form).
fn stripPunct(t: []const u8) []const u8 {
    var s: usize = 0;
    var e: usize = t.len;
    while (s < e and !isWordish(t[s])) s += 1;
    while (e > s and !isWordish(t[e - 1])) e -= 1;
    return if (s < e) t[s..e] else t;
}

// Per-contributing-token breakdown: "token\x01valence" NUL-delimited, only the
// tokens whose net VADER valence is nonzero (the words that actually moved the
// score). Backs SentimentExplained().
pub fn str_sentiment_explained(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const result = str_new() orelse return null;
    const s = handle orelse return result;
    var toks: std.ArrayList(Tok) = .{};
    defer toks.deinit(gpa);
    const sentiments = tokenizeAndScore(s.slice(), &toks) orelse return result;
    defer gpa.free(sentiments);
    var first = true;
    var i: usize = 0;
    while (i < toks.items.len) : (i += 1) {
        if (sentiments[i] == 0) continue;
        if (!first) result.data.append(gpa, 0) catch break;
        result.data.appendSlice(gpa, stripPunct(toks.items[i].s)) catch break;
        result.data.append(gpa, 1) catch break; // 0x01 field separator
        var nb: [32]u8 = undefined;
        const ns = std.fmt.bufPrint(&nb, "{d:.3}", .{sentiments[i]}) catch "0";
        result.data.appendSlice(gpa, ns) catch break;
        first = false;
    }
    return result;
}

pub fn analyze(text: []const u8) Scores {
    var toks: std.ArrayList(Tok) = .{};
    defer toks.deinit(gpa);
    const sentiments = tokenizeAndScore(text, &toks) orelse return .{ .compound = 0, .pos = 0, .neg = 0, .neu = 0 };
    defer gpa.free(sentiments);

    // sum + punctuation emphasis
    var sum: f64 = 0;
    for (sentiments) |s| sum += s;
    const punct = punctuationEmphasis(text);
    if (sum > 0) sum += punct else if (sum < 0) sum -= punct;
    const compound = normalize(sum);

    // pos/neg/neu proportions (VADER sift + normalization)
    var pos: f64 = 0;
    var neg: f64 = 0;
    var neu: f64 = 0;
    for (sentiments) |s| {
        if (s > 0) pos += s + 1 else if (s < 0) neg += s - 1 else neu += 1;
    }
    if (pos > @abs(neg)) pos += punct else if (pos < @abs(neg)) neg -= punct;
    const total = pos + @abs(neg) + neu;
    if (total == 0) return .{ .compound = compound, .pos = 0, .neg = 0, .neu = 0 };
    return .{ .compound = compound, .pos = @abs(pos / total), .neg = @abs(neg / total), .neu = @abs(neu / total) };
}

fn lowerEql(t: []const u8, comptime lit: []const u8, buf: []u8) bool {
    const w = lowerStrip(t, buf);
    return mem.eql(u8, w, lit);
}

fn negationCheck(valence: f64, toks: []const Tok, start_i: usize, i: usize, buf: []u8) f64 {
    var v = valence;
    if (start_i == 0) {
        if (i >= 1 and isNegation(lowerStrip(toks[i - 1].s, buf))) v *= N_SCALAR;
    } else if (start_i == 1) {
        if (i >= 2) {
            if (lowerEql(toks[i - 2].s, "never", buf) and (lowerEql(toks[i - 1].s, "so", buf) or lowerEql(toks[i - 1].s, "this", buf))) {
                v *= 1.25;
            } else if (!(lowerEql(toks[i - 2].s, "without", buf) and lowerEql(toks[i - 1].s, "doubt", buf)) and isNegation(lowerStrip(toks[i - 2].s, buf))) {
                v *= N_SCALAR;
            }
        }
    } else if (start_i == 2) {
        if (i >= 3) {
            const never3 = lowerEql(toks[i - 3].s, "never", buf);
            const soThis = lowerEql(toks[i - 2].s, "so", buf) or lowerEql(toks[i - 2].s, "this", buf) or lowerEql(toks[i - 1].s, "so", buf) or lowerEql(toks[i - 1].s, "this", buf);
            const without3 = lowerEql(toks[i - 3].s, "without", buf);
            const doubt = lowerEql(toks[i - 2].s, "doubt", buf) or lowerEql(toks[i - 1].s, "doubt", buf);
            if (never3 and soThis) {
                v *= 1.25;
            } else if (!(without3 and doubt) and isNegation(lowerStrip(toks[i - 3].s, buf))) {
                v *= N_SCALAR;
            }
        }
    }
    return v;
}

// Contrastive conjunction: words before "but" get 0.5 weight, after get 1.5.
fn butCheck(toks: []const Tok, sentiments: []f64, buf: []u8) void {
    var bi: ?usize = null;
    for (toks, 0..) |t, idx| {
        if (lowerEql(t.s, "but", buf)) {
            bi = idx;
            break;
        }
    }
    if (bi) |b| {
        for (sentiments, 0..) |*s, idx| {
            if (idx < b) s.* *= 0.5 else if (idx > b) s.* *= 1.5;
        }
    }
}

// mode: 0=compound  1=pos  2=neg  3=neu
pub fn str_sentiment(handle: StzStringHandle, mode: c_int) callconv(.c) f64 {
    const s = handle orelse return 0;
    const r = analyze(s.slice());
    return switch (mode) {
        0 => r.compound,
        1 => r.pos,
        2 => r.neg,
        3 => r.neu,
        else => 0,
    };
}

const testing = std.testing;
const str_from = core.str_from;
const str_free = core.str_free;

test "vader positive/negative/booster/negation" {
    const p = str_from("VADER is smart, handsome, and funny!", 36) orelse return error.SkipZigTest;
    defer str_free(p);
    try testing.expect(str_sentiment(p, 0) > 0.5);

    const nneg = str_from("The movie was horrible and boring.", 34) orelse return error.SkipZigTest;
    defer str_free(nneg);
    try testing.expect(str_sentiment(nneg, 0) < -0.3);

    const neg = str_from("The movie was not good.", 23) orelse return error.SkipZigTest;
    defer str_free(neg);
    try testing.expect(str_sentiment(neg, 0) < 0);
}
