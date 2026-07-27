//! Multinomial naive Bayes over word counts, Laplace-smoothed, with the model
//! RESIDENT in the engine.
//!
//! PHASE 5, SECOND PASS. The first pass took 100 documents from 12.497s to 0.088s by
//! retiring the HasKey counting idiom, and left a `ring_find` scan over a key list
//! that grows with the vocabulary -- 3000 documents still took 3.647s. But the
//! interesting part of that 3.647s is that only about two thirds of it was counting.
//! The rest was `_TokensOf`, which built a whole stzText object per document just to
//! reach the word iterator. Moving the counting alone would have left that floor in
//! place, so tokenization moved too.
//!
//! THE TOKENIZATION MUST BE THE SAME TOKENIZATION, or the model is a different model.
//! `stzText.Words()` goes through `str_extract_words`, which walks UAX#29 word
//! segmentation (`word_break.zig`); and `_TokensOf` then lowercased each token with
//! StzLower. So this file uses the SAME WordIter and the same case fold -- not a
//! whitespace split that would agree on "the cat sat" and disagree on "don't",
//! "3.14", "word2vec" and every CJK document.
//!
//! ORDER IS PART OF THE ANSWER, twice over. Labels() publishes labels in first-seen
//! order, and Classify() scans them in that order taking the first strict maximum --
//! so two labels with identical scores resolve to whichever was trained first. Both
//! are preserved here: labels live in an ArrayList in arrival order, and the hash map
//! only finds their index.

const std = @import("std");
const wb = @import("string/word_break.zig");
const unicode = @import("unicode.zig");

pub const Model = struct {
    alloc: std.mem.Allocator,
    /// distinct labels, FIRST-SEEN order -- this order is published and decides ties
    labels: std.ArrayList([]u8),
    label_docs: std.ArrayList(u32),
    label_words: std.ArrayList(u32),
    label_index: std.StringHashMap(u32),
    /// "label\x00word" -> count
    counts: std.StringHashMap(u32),
    vocab: std.StringHashMap(void),
    n_docs: u32,

    pub fn init(alloc: std.mem.Allocator) !*Model {
        const m = try alloc.create(Model);
        m.* = .{
            .alloc = alloc,
            .labels = try std.ArrayList([]u8).initCapacity(alloc, 0),
            .label_docs = try std.ArrayList(u32).initCapacity(alloc, 0),
            .label_words = try std.ArrayList(u32).initCapacity(alloc, 0),
            .label_index = std.StringHashMap(u32).init(alloc),
            .counts = std.StringHashMap(u32).init(alloc),
            .vocab = std.StringHashMap(void).init(alloc),
            .n_docs = 0,
        };
        return m;
    }

    pub fn deinit(self: *Model) void {
        for (self.labels.items) |l| self.alloc.free(l);
        self.labels.deinit(self.alloc);
        self.label_docs.deinit(self.alloc);
        self.label_words.deinit(self.alloc);
        var it = self.label_index.keyIterator();
        while (it.next()) |k| self.alloc.free(k.*);
        self.label_index.deinit();
        var ci = self.counts.keyIterator();
        while (ci.next()) |k| self.alloc.free(k.*);
        self.counts.deinit();
        var vi = self.vocab.keyIterator();
        while (vi.next()) |k| self.alloc.free(k.*);
        self.vocab.deinit();
        self.alloc.destroy(self);
    }
};

fn isAscii(s: []const u8) bool {
    for (s) |b| {
        if (b >= 0x80) return false;
    }
    return true;
}

/// A lowercased copy of `w`. This is `str_to_lower`'s logic, and it has to be:
/// StzLower is what the Ring `_TokensOf` applied, so a different fold here would
/// quietly build a different model on any corpus that is not pure ASCII. ASCII takes
/// the byte-wise path; everything else goes through the same full Unicode fold.
fn lowerDup(alloc: std.mem.Allocator, w: []const u8) ![]u8 {
    if (isAscii(w)) {
        const buf = try alloc.alloc(u8, w.len);
        for (w, 0..) |b, i| buf[i] = if (b >= 'A' and b <= 'Z') b + 32 else b;
        return buf;
    }
    const big = try alloc.alloc(u8, w.len * 4);
    defer alloc.free(big);
    const n = unicode.stz_unicode_to_lower_str(w.ptr, w.len, big.ptr, big.len);
    if (n == 0) return alloc.dupe(u8, w);
    return alloc.dupe(u8, big[0..n]);
}

/// The tokens of `text`, lowercased, appended to `out`. Each slice is owned by the
/// caller and must be freed.
pub fn tokenizeInto(
    alloc: std.mem.Allocator,
    text: []const u8,
    out: *std.ArrayList([]u8),
) !void {
    var it = wb.WordIter.init(text);
    while (it.next()) |span| {
        try out.append(alloc, try lowerDup(alloc, text[span.start..span.end]));
    }
}

fn makeKey(alloc: std.mem.Allocator, label: []const u8, word: []const u8) ![]u8 {
    const k = try alloc.alloc(u8, label.len + 1 + word.len);
    @memcpy(k[0..label.len], label);
    k[label.len] = 0;
    @memcpy(k[label.len + 1 ..], word);
    return k;
}

/// Index of `label`, appending it if new. First-seen order is preserved.
fn labelSlot(m: *Model, label: []const u8) !u32 {
    if (m.label_index.get(label)) |i| return i;
    const owned = try m.alloc.dupe(u8, label);
    const key = try m.alloc.dupe(u8, label);
    try m.labels.append(m.alloc, owned);
    try m.label_docs.append(m.alloc, 0);
    try m.label_words.append(m.alloc, 0);
    const slot: u32 = @intCast(m.labels.items.len - 1);
    try m.label_index.put(key, slot);
    return slot;
}

pub fn train(m: *Model, text: []const u8, label: []const u8) !void {
    var toks = try std.ArrayList([]u8).initCapacity(m.alloc, 16);
    defer {
        for (toks.items) |t| m.alloc.free(t);
        toks.deinit(m.alloc);
    }
    try tokenizeInto(m.alloc, text, &toks);

    const slot = try labelSlot(m, label);
    m.label_docs.items[slot] += 1;

    for (toks.items) |w| {
        const key = try makeKey(m.alloc, label, w);
        const gop = try m.counts.getOrPut(key);
        if (gop.found_existing) {
            m.alloc.free(key);
            gop.value_ptr.* += 1;
        } else {
            gop.value_ptr.* = 1;
        }
        m.label_words.items[slot] += 1;
        if (!m.vocab.contains(w)) {
            const vw = try m.alloc.dupe(u8, w);
            try m.vocab.put(vw, {});
        }
    }
    m.n_docs += 1;
}

/// Log score per label, in label order. `out` must hold at least labels.len.
pub fn classify(m: *Model, text: []const u8, out: []f64) !usize {
    var toks = try std.ArrayList([]u8).initCapacity(m.alloc, 16);
    defer {
        for (toks.items) |t| m.alloc.free(t);
        toks.deinit(m.alloc);
    }
    try tokenizeInto(m.alloc, text, &toks);

    const n_vocab: f64 = @floatFromInt(m.vocab.count());
    const n_docs: f64 = @floatFromInt(m.n_docs);

    for (m.labels.items, 0..) |label, li| {
        var score = @log(@as(f64, @floatFromInt(m.label_docs.items[li])) / n_docs);
        const total: f64 = @floatFromInt(m.label_words.items[li]);
        for (toks.items) |w| {
            const key = try makeKey(m.alloc, label, w);
            defer m.alloc.free(key);
            const c: f64 = @floatFromInt(m.counts.get(key) orelse 0);
            score += @log((c + 1.0) / (total + n_vocab));
        }
        out[li] = score;
    }
    return m.labels.items.len;
}

// ─── tests ───────────────────────────────────────────────────────────────────

test "tokenization is the UAX#29 seam, lowercased" {
    const alloc = std.testing.allocator;
    var toks = try std.ArrayList([]u8).initCapacity(alloc, 4);
    defer {
        for (toks.items) |t| alloc.free(t);
        toks.deinit(alloc);
    }
    try tokenizeInto(alloc, "Don't stop, 3.14 word2vec!", &toks);
    // the apostrophe and the decimal point HOLD -- a whitespace split would agree,
    // a punctuation split would not
    try std.testing.expectEqualStrings("don't", toks.items[0]);
    try std.testing.expectEqualStrings("stop", toks.items[1]);
    try std.testing.expectEqualStrings("3.14", toks.items[2]);
    try std.testing.expectEqualStrings("word2vec", toks.items[3]);
}

test "it learns a two-class split" {
    const alloc = std.testing.allocator;
    const m = try Model.init(alloc);
    defer m.deinit();
    try train(m, "great food lovely staff", "positive");
    try train(m, "cold soup rude waiter", "negative");
    var s: [2]f64 = undefined;
    const n = try classify(m, "lovely great food", &s);
    try std.testing.expectEqual(@as(usize, 2), n);
    try std.testing.expect(s[0] > s[1]);
}

test "labels keep first-seen order" {
    const alloc = std.testing.allocator;
    const m = try Model.init(alloc);
    defer m.deinit();
    try train(m, "a", "zeta");
    try train(m, "b", "alpha");
    try std.testing.expectEqualStrings("zeta", m.labels.items[0]);
    try std.testing.expectEqualStrings("alpha", m.labels.items[1]);
}

test "an unseen word is smoothed, not fatal" {
    const alloc = std.testing.allocator;
    const m = try Model.init(alloc);
    defer m.deinit();
    try train(m, "known words here", "x");
    try train(m, "other words there", "y");
    var s: [2]f64 = undefined;
    _ = try classify(m, "completely unseen vocabulary", &s);
    try std.testing.expect(s[0] < 0 and s[1] < 0); // finite log-probabilities
}
