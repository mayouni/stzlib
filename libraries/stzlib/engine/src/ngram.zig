// ngram.zig -- the n-gram language model, owned END TO END by the engine.
//
// Ring is a thin consumer: it hands over the raw corpus (documents joined by
// '\n') and asks questions. EVERYTHING heavy happens here -- tokenisation,
// Unicode lowercasing, counting, and the probability arithmetic. There is no
// Ring-side counting path; heavy work belongs to the engine so the library
// can carry an industry-grade corpus with confidence.
//
// Model: Laplace-smoothed bigrams.  P(w2|w1) = (count(w1 w2) + 1) / (count(w1) + V)
// A bigram never spans a document boundary (the '\n'): the count walk breaks
// the chain there.

const std = @import("std");
const unicode = @import("unicode.zig");

const Counts = std.StringHashMap(u32);
const c_alloc = std.heap.c_allocator;

// A token longer than this is counted verbatim (un-lowercased). Real words are
// far shorter; this only bounds the on-stack lowercasing buffer.
const TOK_MAX = 512;

pub const NgramModel = struct {
    arena: std.heap.ArenaAllocator, // owns every interned key string
    uni: Counts, // unigram counts:  "word"  -> count
    bi: Counts, //  bigram  counts:  "w1 w2" -> count
    tokens: usize,

    fn keyAlloc(self: *NgramModel, s: []const u8) ![]const u8 {
        const dup = try self.arena.allocator().alloc(u8, s.len);
        @memcpy(dup, s);
        return dup;
    }

    fn bump(map: *Counts, self: *NgramModel, key: []const u8) void {
        if (map.getPtr(key)) |p| {
            p.* += 1;
        } else {
            const owned = self.keyAlloc(key) catch return;
            map.put(owned, 1) catch return;
        }
    }
};

// Unicode-correct lowercase of one token into `buf`. Returns the lowered slice,
// or the raw token if it does not fit (rare -- only pathologically long tokens).
fn lowerTok(tok: []const u8, buf: []u8) []const u8 {
    if (tok.len == 0) return tok;
    const n = unicode.stz_unicode_to_lower_str(tok.ptr, tok.len, buf.ptr, buf.len);
    if (n == 0) return tok; // lowering produced nothing -> keep the original
    return buf[0..n];
}

const WsClass = enum { token, space, newline };
fn classify(c: u8) WsClass {
    return switch (c) {
        '\n' => .newline,
        ' ', '\t', '\r' => .space,
        else => .token,
    };
}

/// Build a model from the raw corpus (documents joined by '\n'). The engine
/// tokenises on whitespace and lowercases each token. Returns null on OOM.
pub fn train(text: []const u8) ?*NgramModel {
    const m = c_alloc.create(NgramModel) catch return null;
    m.* = .{
        .arena = std.heap.ArenaAllocator.init(c_alloc),
        .uni = Counts.init(c_alloc),
        .bi = Counts.init(c_alloc),
        .tokens = 0,
    };

    var cur_buf: [TOK_MAX]u8 = undefined; // lowercased current token
    var prev_buf: [TOK_MAX]u8 = undefined; // lowercased previous token (stable)
    var prev_len: usize = 0;
    var have_prev = false;
    var key_buf: [TOK_MAX * 2 + 1]u8 = undefined;

    var i: usize = 0;
    const n = text.len;
    while (i < n) {
        // skip inter-token whitespace, breaking the bigram chain on a newline
        while (i < n) {
            switch (classify(text[i])) {
                .space => i += 1,
                .newline => {
                    have_prev = false; // document boundary
                    i += 1;
                },
                .token => break,
            }
        }
        if (i >= n) break;

        const start = i;
        while (i < n and classify(text[i]) == .token) : (i += 1) {}
        const raw = text[start..i];
        const cur = lowerTok(raw, &cur_buf);

        NgramModel.bump(&m.uni, m, cur);
        m.tokens += 1;

        if (have_prev and prev_len + 1 + cur.len <= key_buf.len) {
            @memcpy(key_buf[0..prev_len], prev_buf[0..prev_len]);
            key_buf[prev_len] = ' ';
            @memcpy(key_buf[prev_len + 1 ..][0..cur.len], cur);
            NgramModel.bump(&m.bi, m, key_buf[0 .. prev_len + 1 + cur.len]);
        }

        // carry cur into prev for the next pair (cur_buf is reused next round)
        if (cur.len <= prev_buf.len) {
            @memcpy(prev_buf[0..cur.len], cur);
            prev_len = cur.len;
            have_prev = true;
        } else {
            have_prev = false;
        }
    }

    return m;
}

pub fn free(m: *NgramModel) void {
    m.bi.deinit();
    m.uni.deinit();
    m.arena.deinit();
    c_alloc.destroy(m);
}

pub fn vocabSize(m: *NgramModel) usize {
    return m.uni.count();
}

pub fn tokenCount(m: *NgramModel) usize {
    return m.tokens;
}

fn uniCount(m: *NgramModel, w: []const u8) u32 {
    return if (m.uni.get(w)) |c| c else 0;
}

fn biCount(m: *NgramModel, w1: []const u8, w2: []const u8) u32 {
    var kb: [TOK_MAX * 2 + 1]u8 = undefined;
    if (w1.len + 1 + w2.len > kb.len) return 0;
    @memcpy(kb[0..w1.len], w1);
    kb[w1.len] = ' ';
    @memcpy(kb[w1.len + 1 ..][0..w2.len], w2);
    return if (m.bi.get(kb[0 .. w1.len + 1 + w2.len])) |c| c else 0;
}

/// Laplace-smoothed bigram probability. The words are lowercased here, so a
/// caller may pass them in any case.
pub fn bigramProb(m: *NgramModel, w1: []const u8, w2: []const u8) f64 {
    var b1: [TOK_MAX]u8 = undefined;
    var b2: [TOK_MAX]u8 = undefined;
    const lw1 = lowerTok(w1, &b1);
    const lw2 = lowerTok(w2, &b2);
    const bi: f64 = @floatFromInt(biCount(m, lw1, lw2));
    const uni: f64 = @floatFromInt(uniCount(m, lw1));
    const v: f64 = @floatFromInt(vocabSize(m));
    return (bi + 1.0) / (uni + v);
}

/// Sum of log bigram probabilities over the query's adjacent pairs. The query
/// is one line (a single sentence): tokens split on whitespace, lowercased.
/// Fewer than two tokens -> 0.
pub fn logProb(m: *NgramModel, query: []const u8) f64 {
    var total: f64 = 0;
    var prev_buf: [TOK_MAX]u8 = undefined;
    var prev_len: usize = 0;
    var have_prev = false;
    var cur_buf: [TOK_MAX]u8 = undefined;

    var i: usize = 0;
    const n = query.len;
    while (i < n) {
        while (i < n and classify(query[i]) != .token) : (i += 1) {}
        if (i >= n) break;
        const start = i;
        while (i < n and classify(query[i]) == .token) : (i += 1) {}
        const cur = lowerTok(query[start..i], &cur_buf);

        if (have_prev) {
            const bi: f64 = @floatFromInt(biCount(m, prev_buf[0..prev_len], cur));
            const uni: f64 = @floatFromInt(uniCount(m, prev_buf[0..prev_len]));
            const v: f64 = @floatFromInt(vocabSize(m));
            total += @log((bi + 1.0) / (uni + v));
        }
        if (cur.len <= prev_buf.len) {
            @memcpy(prev_buf[0..cur.len], cur);
            prev_len = cur.len;
            have_prev = true;
        } else have_prev = false;
    }
    return total;
}
