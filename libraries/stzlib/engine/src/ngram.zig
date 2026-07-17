// ngram.zig -- the corpus model, owned END TO END by the engine.
//
// Ring is a thin consumer: it hands over the raw corpus (documents joined by
// '\n') and asks questions. EVERYTHING that grows with the corpus happens
// here -- tokenisation, Unicode lowercasing, counting, sorting, TF-IDF. There
// is no Ring counting path; heavy work belongs to the engine so the library
// can carry an industry-grade corpus with confidence.
//
// The model holds, per corpus:
//   uni  -- unigram counts        word   -> count     (vocabulary / frequency)
//   bi   -- bigram  counts        "w1 w2"-> count     (the Laplace LM)
//   docs -- per-document term counts (TF)             (one map per document)
//   df   -- document frequency    word   -> #docs     (IDF)
//
// A bigram never spans a document boundary (the '\n').

const std = @import("std");
const unicode = @import("unicode.zig");

const Counts = std.StringHashMap(u32);
const c_alloc = std.heap.c_allocator;

const TOK_MAX = 512; // bounds the on-stack lowercasing buffer

pub const Entry = struct { word: []const u8, count: u32 };
pub const EntryF = struct { word: []const u8, score: f64 };

pub const NgramModel = struct {
    arena: std.heap.ArenaAllocator, // owns every interned key string
    uni: Counts,
    bi: Counts,
    docs: std.ArrayListUnmanaged(Counts), // per-document term counts (TF)
    df: Counts, // document frequency per term (IDF)
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

fn lowerTok(tok: []const u8, buf: []u8) []const u8 {
    if (tok.len == 0) return tok;
    const n = unicode.stz_unicode_to_lower_str(tok.ptr, tok.len, buf.ptr, buf.len);
    if (n == 0) return tok;
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

// Count one document's tokens into uni/bi and a fresh per-doc TF map, then
// record the document and its distinct terms' contribution to df.
fn processDoc(m: *NgramModel, seg: []const u8) void {
    var doc = Counts.init(c_alloc);

    var cur_buf: [TOK_MAX]u8 = undefined;
    var prev_buf: [TOK_MAX]u8 = undefined;
    var prev_len: usize = 0;
    var have_prev = false;
    var key_buf: [TOK_MAX * 2 + 1]u8 = undefined;

    var i: usize = 0;
    const n = seg.len;
    while (i < n) {
        while (i < n and classify(seg[i]) != .token) : (i += 1) {}
        if (i >= n) break;
        const start = i;
        while (i < n and classify(seg[i]) == .token) : (i += 1) {}
        const cur = lowerTok(seg[start..i], &cur_buf);

        NgramModel.bump(&m.uni, m, cur);
        NgramModel.bump(&doc, m, cur);
        m.tokens += 1;

        if (have_prev and prev_len + 1 + cur.len <= key_buf.len) {
            @memcpy(key_buf[0..prev_len], prev_buf[0..prev_len]);
            key_buf[prev_len] = ' ';
            @memcpy(key_buf[prev_len + 1 ..][0..cur.len], cur);
            NgramModel.bump(&m.bi, m, key_buf[0 .. prev_len + 1 + cur.len]);
        }
        if (cur.len <= prev_buf.len) {
            @memcpy(prev_buf[0..cur.len], cur);
            prev_len = cur.len;
            have_prev = true;
        } else have_prev = false;
    }

    // each DISTINCT term in this document adds 1 to its document frequency
    var it = doc.keyIterator();
    while (it.next()) |k| NgramModel.bump(&m.df, m, k.*);

    m.docs.append(c_alloc, doc) catch {
        doc.deinit();
    };
}

/// Build the model from the raw corpus (documents joined by '\n').
pub fn train(text: []const u8) ?*NgramModel {
    const m = c_alloc.create(NgramModel) catch return null;
    m.* = .{
        .arena = std.heap.ArenaAllocator.init(c_alloc),
        .uni = Counts.init(c_alloc),
        .bi = Counts.init(c_alloc),
        .docs = .{},
        .df = Counts.init(c_alloc),
        .tokens = 0,
    };

    var seg_start: usize = 0;
    var i: usize = 0;
    const n = text.len;
    while (i < n) : (i += 1) {
        if (text[i] == '\n') {
            processDoc(m, text[seg_start..i]);
            seg_start = i + 1;
        }
    }
    processDoc(m, text[seg_start..n]); // the final document

    return m;
}

pub fn free(m: *NgramModel) void {
    for (m.docs.items) |*d| d.deinit();
    m.docs.deinit(c_alloc);
    m.df.deinit();
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
pub fn docCount(m: *NgramModel) usize {
    return m.docs.items.len;
}

fn lowered(w: []const u8, buf: []u8) []const u8 {
    return lowerTok(w, buf);
}

pub fn uniCount(m: *NgramModel, w: []const u8) u32 {
    var b: [TOK_MAX]u8 = undefined;
    return if (m.uni.get(lowered(w, &b))) |c| c else 0;
}

// Term frequency of `w` in document `doc_idx` (1-based, matching Ring).
pub fn tf(m: *NgramModel, w: []const u8, doc_idx: usize) u32 {
    if (doc_idx < 1 or doc_idx > m.docs.items.len) return 0;
    var b: [TOK_MAX]u8 = undefined;
    return if (m.docs.items[doc_idx - 1].get(lowered(w, &b))) |c| c else 0;
}

pub fn dfOf(m: *NgramModel, w: []const u8) u32 {
    var b: [TOK_MAX]u8 = undefined;
    return if (m.df.get(lowered(w, &b))) |c| c else 0;
}

// Smoothed inverse document frequency -- the ONE place this formula lives, so
// Ring's IdfOf and topTerms below cannot drift apart.
//   idf(w) = log( (1 + D) / (1 + df(w)) ) + 1
pub fn idf(m: *NgramModel, w: []const u8) f64 {
    const d: f64 = @floatFromInt(m.docs.items.len);
    const df: f64 = @floatFromInt(dfOf(m, w));
    return @log((1.0 + d) / (1.0 + df)) + 1.0;
}

fn biCount(m: *NgramModel, w1: []const u8, w2: []const u8) u32 {
    var kb: [TOK_MAX * 2 + 1]u8 = undefined;
    if (w1.len + 1 + w2.len > kb.len) return 0;
    @memcpy(kb[0..w1.len], w1);
    kb[w1.len] = ' ';
    @memcpy(kb[w1.len + 1 ..][0..w2.len], w2);
    return if (m.bi.get(kb[0 .. w1.len + 1 + w2.len])) |c| c else 0;
}

/// Laplace-smoothed bigram probability. Words are lowercased here.
pub fn bigramProb(m: *NgramModel, w1: []const u8, w2: []const u8) f64 {
    var b1: [TOK_MAX]u8 = undefined;
    var b2: [TOK_MAX]u8 = undefined;
    const lw1 = lowerTok(w1, &b1);
    const lw2 = lowerTok(w2, &b2);
    const bi: f64 = @floatFromInt(biCount(m, lw1, lw2));
    const uni: f64 = @floatFromInt(if (m.uni.get(lw1)) |c| c else 0);
    const v: f64 = @floatFromInt(vocabSize(m));
    return (bi + 1.0) / (uni + v);
}

/// Sum of log bigram probabilities over the query's adjacent pairs.
pub fn logProb(m: *NgramModel, query: []const u8) f64 {
    var total: f64 = 0;
    var prev_buf: [TOK_MAX]u8 = undefined;
    var prev_len: usize = 0;
    var have_prev = false;
    var cur_buf: [TOK_MAX]u8 = undefined;
    const v: f64 = @floatFromInt(vocabSize(m));

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
            const uni: f64 = @floatFromInt(if (m.uni.get(prev_buf[0..prev_len])) |c| c else 0);
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

fn moreCount(_: void, a: Entry, b: Entry) bool {
    return a.count > b.count;
}
fn moreScore(_: void, a: EntryF, b: EntryF) bool {
    return a.score > b.score;
}

/// The whole vocabulary, sorted by count descending. Caller frees with
/// freeEntries. Returns an empty slice on OOM.
pub fn mostFrequent(m: *NgramModel) []Entry {
    const out = c_alloc.alloc(Entry, m.uni.count()) catch return &.{};
    var i: usize = 0;
    var it = m.uni.iterator();
    while (it.next()) |e| : (i += 1) {
        out[i] = .{ .word = e.key_ptr.*, .count = e.value_ptr.* };
    }
    std.mem.sort(Entry, out, {}, moreCount);
    return out;
}

pub fn freeEntries(e: []Entry) void {
    if (e.len > 0) c_alloc.free(e);
}

/// The terms of document `doc_idx` (1-based) scored by TF-IDF, sorted
/// descending. Caller frees with freeEntriesF.
pub fn topTerms(m: *NgramModel, doc_idx: usize) []EntryF {
    if (doc_idx < 1 or doc_idx > m.docs.items.len) return &.{};
    const doc = &m.docs.items[doc_idx - 1];
    const out = c_alloc.alloc(EntryF, doc.count()) catch return &.{};
    var i: usize = 0;
    var it = doc.iterator();
    while (it.next()) |e| : (i += 1) {
        const tfv: f64 = @floatFromInt(e.value_ptr.*);
        out[i] = .{ .word = e.key_ptr.*, .score = tfv * idf(m, e.key_ptr.*) };
    }
    std.mem.sort(EntryF, out, {}, moreScore);
    return out;
}

pub fn freeEntriesF(e: []EntryF) void {
    if (e.len > 0) c_alloc.free(e);
}
