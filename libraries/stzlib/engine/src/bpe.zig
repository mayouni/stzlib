//! bpe.zig -- a byte-fallback BPE tokenizer read from a model's own GGUF (IM5 of SOFTANZA_IMAGE_INTELLIGENCE.md).
//!
//! SigLIP2's text tower reads Gemma's vocabulary (256,000 tokens, 580,604 merges). onnx_to_gguf.py --tokenizer
//! writes it beside the weights: stz.tok.vocab (the tokens by id), stz.tok.merge_a / merge_b (the merges as two
//! parallel arrays in rank order), stz.tok.space (what a space becomes: "\u{2581}"), stz.tok.eos, stz.tok.pad.
//! The algorithm is HF tokenizers' BPE as tokenizer.json configures it for this model:
//!   1. every " " becomes the space mark (the normalizer); no pre-split survives that, so the whole text is one word
//!   2. the word starts as its characters; a character outside the vocabulary becomes its UTF-8 bytes as <0xXX>
//!   3. repeatedly merge the adjacent pair of lowest merge rank (leftmost on a tie) until no pair has a rank
//!   4. ids, truncated to seq - 1, then <eos>, then <pad> up to seq (SigLIP2 pads every text to 64; no BOS)
//! Each symbol stays a contiguous slice of the normalized text, so a merge only moves a boundary.

const std = @import("std");
const c = @import("ocr_graph.zig").c;
const gr = @import("gguf_read.zig"); // SECURITY-MODELDATA-01b

pub const Bpe = struct {
    arena: std.heap.ArenaAllocator,
    vocab: std.StringHashMap(u32),
    ranks: std.StringHashMap(u32), // "a" ++ 0xFF ++ "b" -> rank (0xFF never occurs in UTF-8)
    space: []const u8,
    eos: u32,
    pad: u32,
};

// i is in range at every call (each loop is bounded by the array's own checked count)
fn arrStr(g: *c.gguf_context, id: i64, i: usize) []const u8 {
    return std.mem.span(gr.arrStr(g, id, i).?);
}

/// The tokenizer a GGUF carries, or null when it carries none. The strings stay owned by the GGUF.
pub fn fromGguf(g: *c.gguf_context, gpa: std.mem.Allocator) !?*Bpe {
    const vid = c.gguf_find_key(g, "stz.tok.vocab");
    if (vid < 0) return null;
    const aid = c.gguf_find_key(g, "stz.tok.merge_a");
    const bid = c.gguf_find_key(g, "stz.tok.merge_b");
    if (aid < 0 or bid < 0) return error.NoMerges;
    // SECURITY-MODELDATA-01b: arrays of strings, and the two merge halves the same length -- merge_b shorter
    // than merge_a was read past its end
    const nv: usize = gr.arrN(g, vid, gr.T_STR) orelse return error.BadTokenizer;
    const na = gr.arrN(g, aid, gr.T_STR) orelse return error.BadTokenizer;
    if (gr.arrN(g, bid, gr.T_STR) != na or nv > std.math.maxInt(i32) or na > std.math.maxInt(i32)) return error.BadTokenizer;
    const t = try gpa.create(Bpe);
    t.arena = std.heap.ArenaAllocator.init(gpa);
    const a = t.arena.allocator();
    t.vocab = std.StringHashMap(u32).init(a);
    t.ranks = std.StringHashMap(u32).init(a);
    // nv, checked above
    try t.vocab.ensureTotalCapacity(@intCast(nv));
    for (0..nv) |i| t.vocab.putAssumeCapacity(arrStr(g, vid, i), @intCast(i));
    const nm: usize = na;
    try t.ranks.ensureTotalCapacity(@intCast(nm));
    for (0..nm) |i| {
        const x = arrStr(g, aid, i);
        const y = arrStr(g, bid, i);
        const k = try a.alloc(u8, x.len + 1 + y.len);
        @memcpy(k[0..x.len], x);
        k[x.len] = 0xFF;
        @memcpy(k[x.len + 1 ..], y);
        const r = t.ranks.getOrPutAssumeCapacity(k);
        if (!r.found_existing) r.value_ptr.* = @intCast(i);
    }
    const sid = c.gguf_find_key(g, "stz.tok.space");
    t.space = if (gr.strAt(g, sid)) |s| std.mem.span(s) else "";
    // the ids are i32 when they reach the model: an eos or pad past that range panicked in encode's casts
    // (SECURITY-MODELDATA-01c); whether the id is a row of the model's table is the graph's check, at its lookup
    t.eos = @intCast(@max(0, gr.intAs(i32, g, "stz.tok.eos", 1)));
    t.pad = @intCast(@max(0, gr.intAs(i32, g, "stz.tok.pad", 0)));
    return t;
}

const Sym = struct { s: usize, e: usize, bytes: bool }; // bytes: a character outside the vocabulary

/// The ids of a text, exactly seq of them (seq = 0: unpadded, no truncation). Caller frees.
pub fn encode(t: *Bpe, text: []const u8, seq: usize, gpa: std.mem.Allocator) ![]i32 {
    // 1. the normalizer: " " -> the space mark
    var norm: std.ArrayList(u8) = .empty;
    defer norm.deinit(gpa);
    for (text) |ch| {
        if (ch == ' ' and t.space.len > 0) try norm.appendSlice(gpa, t.space) else try norm.append(gpa, ch);
    }
    const s = norm.items;
    // 2. the characters
    var syms: std.ArrayList(Sym) = .empty;
    defer syms.deinit(gpa);
    var i: usize = 0;
    while (i < s.len) {
        var n: usize = std.unicode.utf8ByteSequenceLength(s[i]) catch 1;
        if (i + n > s.len) n = 1;
        try syms.append(gpa, .{ .s = i, .e = i + n, .bytes = !t.vocab.contains(s[i .. i + n]) });
        i += n;
    }
    // 3. the merges, lowest rank first, leftmost on a tie
    var key: std.ArrayList(u8) = .empty;
    defer key.deinit(gpa);
    while (syms.items.len > 1) {
        var best: usize = std.math.maxInt(usize);
        var at: usize = 0;
        for (0..syms.items.len - 1) |j| {
            const x = syms.items[j];
            const y = syms.items[j + 1];
            if (x.bytes or y.bytes) continue;
            key.clearRetainingCapacity();
            try key.appendSlice(gpa, s[x.s..x.e]);
            try key.append(gpa, 0xFF);
            try key.appendSlice(gpa, s[y.s..y.e]);
            if (t.ranks.get(key.items)) |r| {
                if (r < best) {
                    best = r;
                    at = j;
                }
            }
        }
        if (best == std.math.maxInt(usize)) break;
        syms.items[at].e = syms.items[at + 1].e;
        _ = syms.orderedRemove(at + 1);
    }
    // 4. the ids
    var ids: std.ArrayList(i32) = .empty;
    errdefer ids.deinit(gpa);
    for (syms.items) |y| {
        if (!y.bytes) {
            try ids.append(gpa, @intCast(t.vocab.get(s[y.s..y.e]) orelse return error.TokenNotInVocabulary));
            continue;
        }
        for (s[y.s..y.e]) |byte| {
            var nb: [6]u8 = undefined;
            const name = try std.fmt.bufPrint(&nb, "<0x{X:0>2}>", .{byte});
            try ids.append(gpa, @intCast(t.vocab.get(name) orelse return error.ByteTokenMissing));
        }
    }
    if (seq > 0) {
        if (ids.items.len > seq - 1) ids.shrinkRetainingCapacity(seq - 1);
        try ids.append(gpa, @intCast(t.eos));
        while (ids.items.len < seq) try ids.append(gpa, @intCast(t.pad));
    } else try ids.append(gpa, @intCast(t.eos));
    return ids.toOwnedSlice(gpa);
}
