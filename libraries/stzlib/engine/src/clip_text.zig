//! clip_text.zig -- the CLIP text side of OWL-ViT: a byte-level BPE tokenizer and the query embedding (IM9f).
//!
//! OWL-ViT answers "where is a red mug?" by comparing each patch's embedding with the embedding of the QUERY WORDS, so the words must be
//! tokenized exactly as CLIP tokenizes them. The algorithm is HF's CLIPTokenizer (OpenAI's simple_tokenizer):
//!   1. the text is lower-cased and runs of whitespace become one space (leading and trailing whitespace goes)
//!   2. it is cut into pieces by the pattern  's|'t|'re|'ve|'m|'ll|'d | letters | ONE digit | a run of anything else (not space, letter, digit)
//!   3. a piece's UTF-8 bytes are written as printable characters (GPT-2's byte-to-unicode table), the last gets "</w>" appended
//!   4. the lowest-ranked merge of two adjacent symbols is applied again and again; each symbol is then looked up in vocab.json
//!   5. ids: 49406 (start), the words, 49407 (end), padded with 0 to 16 (OWL-ViT's fixed query length); too long is cut, keeping the end token
//! The pipeline is the one tokenizers' Rust BPE runs for this model (transformers 5's CLIPTokenizer): NFC, whitespace to one space, lower-case,
//! the split pattern above, byte-level, BPE. Unicode comes from utf8proc (the engine's own copy, linked into this DLL): NFC, the simple lower-case
//! of every script, and \p{L} / \p{N} as general categories. TWO FACTS THE REFERENCE TAUGHT US, neither in any description of CLIP's tokenizer:
//!   - every "!" is a token of its own, id 0, with no "</w>": "!" is OWL-ViT's PAD token, an ADDED token, and added tokens are cut out of the text
//!     before anything else runs ("a!b" is a, !, b; "!!!" is three 0s, where OpenAI's own tokenizer gives one "!!!</w>")
//!   - the start and end tokens written in the text ("<|startoftext|>") are their ids, not letters and punctuation
//! STATED LIMIT: the lower-case is utf8proc's SIMPLE mapping; Rust's is the full one, which differs for a handful of characters (U+0130 becomes
//! "i" here and "i" + U+0307 there).
//!
//! The two data files are the model's own (google/owlvit-base-patch32: vocab.json and merges.txt), read once per process.

const std = @import("std");
const graph = @import("ocr_graph.zig");
const vis = @import("vision.zig");

const gpa = std.heap.c_allocator;

pub const seq_len: usize = 16;
pub const start_id: i32 = 49406;
pub const end_id: i32 = 49407;

pub const Clip = struct {
    arena: std.heap.ArenaAllocator,
    vocab: std.StringHashMap(u32),
    ranks: std.StringHashMap(u32), // "a" ++ 0xFF ++ "b" -> rank
    byte_char: [256][]const u8, // the printable UTF-8 stand-in of every byte
};

var cache_paths: std.ArrayList([]u8) = .empty;
var cache_clips: std.ArrayList(*Clip) = .empty;

fn readAll(path: []const u8) ![]u8 {
    const f = try std.fs.cwd().openFile(path, .{});
    defer f.close();
    return try f.readToEndAlloc(gpa, 64 * 1024 * 1024);
}

fn appendUtf8(list: *std.ArrayList(u8), a: std.mem.Allocator, cp: u21) !void {
    var b: [4]u8 = undefined;
    const n = try std.unicode.utf8Encode(cp, &b);
    try list.appendSlice(a, b[0..n]);
}

fn hexVal(ch: u8) !u21 {
    return switch (ch) {
        '0'...'9' => ch - '0',
        'a'...'f' => ch - 'a' + 10,
        'A'...'F' => ch - 'A' + 10,
        else => error.BadVocab,
    };
}

/// vocab.json is one flat object {"token": id, ...}; tokens carry \uXXXX, \\ and \" escapes.
fn parseVocab(a: std.mem.Allocator, src: []const u8, map: *std.StringHashMap(u32)) !void {
    var i: usize = 0;
    while (i < src.len and src[i] != '{') i += 1;
    i += 1;
    var key: std.ArrayList(u8) = .empty;
    while (true) {
        while (i < src.len and (src[i] == ' ' or src[i] == ',' or src[i] == '\n' or src[i] == '\r' or src[i] == '\t')) i += 1;
        if (i >= src.len or src[i] == '}') break;
        if (src[i] != '"') return error.BadVocab;
        i += 1;
        key.clearRetainingCapacity();
        while (i < src.len and src[i] != '"') {
            if (src[i] == '\\') {
                i += 1;
                switch (src[i]) {
                    '"' => try key.append(a, '"'),
                    '\\' => try key.append(a, '\\'),
                    '/' => try key.append(a, '/'),
                    'n' => try key.append(a, '\n'),
                    't' => try key.append(a, '\t'),
                    'r' => try key.append(a, '\r'),
                    'u' => {
                        var cp: u21 = 0;
                        for (src[i + 1 .. i + 5]) |h| cp = cp * 16 + try hexVal(h);
                        i += 4;
                        if (cp >= 0xD800 and cp < 0xDC00 and i + 6 < src.len and src[i + 1] == '\\' and src[i + 2] == 'u') {
                            var lo: u21 = 0;
                            for (src[i + 3 .. i + 7]) |h| lo = lo * 16 + try hexVal(h);
                            cp = 0x10000 + ((cp - 0xD800) << 10) + (lo - 0xDC00);
                            i += 6;
                        }
                        try appendUtf8(&key, a, cp);
                    },
                    else => return error.BadVocab,
                }
                i += 1;
            } else {
                try key.append(a, src[i]);
                i += 1;
            }
        }
        i += 1; // the closing quote
        while (i < src.len and (src[i] == ' ' or src[i] == ':')) i += 1;
        var id: u32 = 0;
        while (i < src.len and src[i] >= '0' and src[i] <= '9') : (i += 1) id = id * 10 + (src[i] - '0');
        try map.put(try a.dupe(u8, key.items), id);
    }
    key.deinit(a);
}

pub fn load(vocab_path: []const u8, merges_path: []const u8) !*Clip {
    for (cache_paths.items, 0..) |p, i| {
        if (std.mem.eql(u8, p, vocab_path)) return cache_clips.items[i];
    }
    const t = try gpa.create(Clip);
    t.arena = std.heap.ArenaAllocator.init(gpa);
    const a = t.arena.allocator();
    t.vocab = std.StringHashMap(u32).init(a);
    t.ranks = std.StringHashMap(u32).init(a);
    const vsrc = readAll(vocab_path) catch {
        graph.setError("clip: cannot read {s}", .{vocab_path});
        return error.NoVocab;
    };
    defer gpa.free(vsrc);
    try parseVocab(a, vsrc, &t.vocab);
    const msrc = readAll(merges_path) catch {
        graph.setError("clip: cannot read {s}", .{merges_path});
        return error.NoMerges;
    };
    defer gpa.free(msrc);
    var rank: u32 = 0;
    var lines = std.mem.splitScalar(u8, msrc, '\n');
    var first = true;
    while (lines.next()) |raw| {
        const line = std.mem.trimRight(u8, raw, "\r");
        if (first) {
            first = false;
            if (std.mem.startsWith(u8, line, "#version")) continue;
        }
        const sp = std.mem.indexOfScalar(u8, line, ' ') orelse continue;
        const k = try a.alloc(u8, line.len);
        @memcpy(k[0..sp], line[0..sp]);
        k[sp] = 0xFF;
        @memcpy(k[sp + 1 ..], line[sp + 1 ..]);
        try t.ranks.put(k, rank);
        rank += 1;
    }
    // GPT-2's byte-to-unicode table: the bytes that print stand for themselves, the others take 256, 257, ... in order
    var n: u21 = 0;
    for (0..256) |b| {
        const printable = (b >= 33 and b <= 126) or (b >= 161 and b <= 172) or (b >= 174 and b <= 255);
        var cp: u21 = @intCast(b);
        if (!printable) {
            cp = 256 + n;
            n += 1;
        }
        var buf: [4]u8 = undefined;
        const l = try std.unicode.utf8Encode(cp, &buf);
        t.byte_char[b] = try a.dupe(u8, buf[0..l]);
    }
    try cache_paths.append(gpa, try gpa.dupe(u8, vocab_path));
    try cache_clips.append(gpa, t);
    return t;
}

const u8p = struct {
    extern fn utf8proc_tolower(cp: i32) callconv(.c) i32;
    extern fn utf8proc_category(cp: i32) callconv(.c) c_int;
    extern fn utf8proc_map(str: [*]const u8, strlen: isize, dstptr: *?[*]u8, options: c_int) callconv(.c) isize;
    extern fn utf8proc_free(ptr: ?*anyopaque) callconv(.c) void;
};
const OPT_STABLE_COMPOSE: c_int = 2 | 8; // UTF8PROC_STABLE | UTF8PROC_COMPOSE: NFC

const Cp = struct { cp: u21, len: usize };

/// The codepoint at s[i]; a byte that is not valid UTF-8 is its own codepoint (it cannot occur after NFC, which rejects nothing but is kept total).
pub fn cpAt(s: []const u8, i: usize) Cp {
    const n = std.unicode.utf8ByteSequenceLength(s[i]) catch return .{ .cp = s[i], .len = 1 };
    if (i + n > s.len) return .{ .cp = s[i], .len = 1 };
    const cp = std.unicode.utf8Decode(s[i .. i + n]) catch return .{ .cp = s[i], .len = 1 };
    return .{ .cp = cp, .len = n };
}

pub fn isLetterCp(cp: u21) bool {
    if (cp < 128) return (cp >= 'a' and cp <= 'z') or (cp >= 'A' and cp <= 'Z');
    const cat = u8p.utf8proc_category(@intCast(cp));
    return cat >= 1 and cat <= 5; // Lu Ll Lt Lm Lo
}
pub fn isNumberCp(cp: u21) bool {
    if (cp < 128) return cp >= '0' and cp <= '9';
    const cat = u8p.utf8proc_category(@intCast(cp));
    return cat >= 9 and cat <= 11; // Nd Nl No
}
pub fn isSpaceCp(cp: u21) bool {
    return switch (cp) {
        ' ', '\t', '\n', '\r', 0x0B, 0x0C, 0x85, 0xA0, 0x1680, 0x2028, 0x2029, 0x202F, 0x205F, 0x3000 => true,
        0x2000...0x200A => true,
        else => false,
    };
}

fn specialAt(s: []const u8) i32 {
    if (std.mem.startsWith(u8, s, "<|startoftext|>")) return start_id;
    if (std.mem.startsWith(u8, s, "<|endoftext|>")) return end_id;
    return -1;
}
fn specialLen(id: i32) usize {
    return if (id == start_id) "<|startoftext|>".len else "<|endoftext|>".len;
}

/// The BPE pieces of one pre-split piece, as vocab ids, appended to out.
fn encodePiece(t: *Clip, piece: []const u8, out: *std.ArrayList(i32)) !void {
    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();
    const a = arena.allocator();
    var syms: std.ArrayList([]const u8) = .empty;
    for (piece, 0..) |b, i| {
        if (i + 1 == piece.len) {
            const s = try a.alloc(u8, t.byte_char[b].len + 4);
            @memcpy(s[0..t.byte_char[b].len], t.byte_char[b]);
            @memcpy(s[t.byte_char[b].len..], "</w>");
            try syms.append(a, s);
        } else try syms.append(a, t.byte_char[b]);
    }
    while (syms.items.len > 1) {
        var best: u32 = std.math.maxInt(u32);
        var at: usize = 0;
        for (0..syms.items.len - 1) |i| {
            const x = syms.items[i];
            const y = syms.items[i + 1];
            const k = try a.alloc(u8, x.len + 1 + y.len);
            @memcpy(k[0..x.len], x);
            k[x.len] = 0xFF;
            @memcpy(k[x.len + 1 ..], y);
            if (t.ranks.get(k)) |r| {
                if (r < best) {
                    best = r;
                    at = i;
                }
            }
        }
        if (best == std.math.maxInt(u32)) break;
        // merge EVERY occurrence of that pair, left to right, as the reference does
        const x = syms.items[at];
        const y = syms.items[at + 1];
        var next: std.ArrayList([]const u8) = .empty;
        var i: usize = 0;
        while (i < syms.items.len) {
            if (i + 1 < syms.items.len and std.mem.eql(u8, syms.items[i], x) and std.mem.eql(u8, syms.items[i + 1], y)) {
                const m = try a.alloc(u8, x.len + y.len);
                @memcpy(m[0..x.len], x);
                @memcpy(m[x.len..], y);
                try next.append(a, m);
                i += 2;
            } else {
                try next.append(a, syms.items[i]);
                i += 1;
            }
        }
        syms = next;
    }
    for (syms.items) |s| {
        const id = t.vocab.get(s) orelse return error.NotInVocab;
        try out.append(gpa, @intCast(id));
    }
}

fn contraction(s: []const u8) usize {
    if (s.len < 2 or s[0] != '\'') return 0;
    inline for (.{ "'s", "'t", "'re", "'ve", "'m", "'ll", "'d" }) |c| {
        if (std.mem.startsWith(u8, s, c)) return c.len;
    }
    return 0;
}

/// The text as the reference's normalizer leaves it: NFC, every run of whitespace one space, every codepoint lower-cased. Caller frees.
fn normalize(text: []const u8) ![]u8 {
    var composed: ?[*]u8 = null;
    var src: []const u8 = text;
    var owned = false;
    if (text.len > 0) {
        const n = u8p.utf8proc_map(text.ptr, @intCast(text.len), &composed, OPT_STABLE_COMPOSE);
        if (n >= 0 and composed != null) {
            src = composed.?[0..@intCast(n)];
            owned = true;
        }
    }
    defer if (owned) u8p.utf8proc_free(composed);
    var out: std.ArrayList(u8) = .empty;
    errdefer out.deinit(gpa);
    var space = false;
    var i: usize = 0;
    while (i < src.len) {
        const c = cpAt(src, i);
        i += c.len;
        if (isSpaceCp(c.cp)) {
            space = true;
            continue;
        }
        if (space) try out.append(gpa, ' ');
        space = false;
        const low: u21 = if (c.cp < 128) std.ascii.toLower(@intCast(c.cp)) else @intCast(u8p.utf8proc_tolower(@intCast(c.cp)));
        try appendUtf8(&out, gpa, low);
    }
    if (space) try out.append(gpa, ' ');
    return out.toOwnedSlice(gpa);
}

/// The 16 ids of a query. Caller frees.
pub fn encode(t: *Clip, text: []const u8) ![]i32 {
    const s = try normalize(text);
    defer gpa.free(s);
    var ids: std.ArrayList(i32) = .empty;
    defer ids.deinit(gpa);
    var i: usize = 0;
    while (i < s.len) {
        if (s[i] == ' ') {
            i += 1;
            continue;
        }
        if (s[i] == '!') { // the pad token, an added token: a piece of its own, id 0
            try ids.append(gpa, 0);
            i += 1;
            continue;
        }
        const sp = specialAt(s[i..]);
        if (sp >= 0) {
            try ids.append(gpa, sp);
            i += specialLen(sp);
            continue;
        }
        const cl = contraction(s[i..]);
        var j = i;
        if (cl > 0) {
            j = i + cl;
        } else {
            const first = cpAt(s, i);
            if (isLetterCp(first.cp)) {
                while (j < s.len) {
                    const c = cpAt(s, j);
                    if (!isLetterCp(c.cp)) break;
                    j += c.len;
                }
            } else if (isNumberCp(first.cp)) {
                j = i + first.len; // one number character per piece
            } else {
                // a run of anything that is not space, letter or number (and not an added token, which is cut out first); a contraction is
                // only tried at the START of a piece
                while (j < s.len) {
                    const c = cpAt(s, j);
                    if (isSpaceCp(c.cp) or isLetterCp(c.cp) or isNumberCp(c.cp) or s[j] == '!' or specialAt(s[j..]) >= 0) break;
                    j += c.len;
                }
            }
        }
        try encodePiece(t, s[i..j], &ids);
        i = j;
    }
    const out = try gpa.alloc(i32, seq_len);
    @memset(out, 0);
    out[0] = start_id;
    const room = seq_len - 2;
    const take = @min(ids.items.len, room);
    for (0..take) |k| out[1 + k] = ids.items[k];
    out[1 + take] = end_id;
    return out;
}

pub const Embedded = struct { v: []f32, ms: f64 };

/// A query's embedding: the text graph's row at the END token, L2-normalised (the caller's step: the graph has no ReduceL2).
pub fn embed(model_path: []const u8, vocab_path: []const u8, merges_path: []const u8, text: []const u8, n_threads: c_int) !Embedded {
    const t = try load(vocab_path, merges_path);
    const m = try vis.modelFor(model_path);
    const ids = try encode(t, text);
    defer gpa.free(ids);
    const o = try graph.runIds(m, ids, n_threads);
    defer gpa.free(o.data);
    const width = o.data.len / seq_len;
    var eos: usize = 0;
    for (ids, 0..) |v, k| {
        if (v == end_id) {
            eos = k;
            break;
        }
    }
    const v = try gpa.alloc(f32, width);
    @memcpy(v, o.data[eos * width .. (eos + 1) * width]);
    var sum: f64 = 0;
    for (v) |x| sum += @as(f64, x) * x;
    const nrm: f32 = @floatCast(@sqrt(sum) + 1e-6);
    for (v) |*x| x.* /= nrm;
    return .{ .v = v, .ms = o.ms };
}
