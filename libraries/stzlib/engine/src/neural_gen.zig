// Softanza Engine -- GENERATIVE decoder (ggml): llama-family GGUF text generation
//
// GENERATIVE MILESTONE: a causal decoder running on the same ctor-independent
// ggml foundation as the encoder tier (neural_embed.zig). Covers the llama
// family (llama arch: SmolLM2/TinyLlama; qwen2 arch: Qwen2.5) --
// RMSNorm + RoPE + GQA causal attention + SwiGLU FFN + (tied) lm_head --
// with a KV cache and greedy (deterministic) sampling.
//
// Tokenizer: GPT-2 byte-level BPE read from the GGUF (tokenizer.ggml.tokens +
// .merges), with CONTROL tokens (<|im_start|>, <|im_end|>, ...) matched
// literally before BPE so ChatML prompts tokenize correctly.

const std = @import("std");
const embed = @import("neural_embed.zig");
const gm = @import("gbnf_machine.zig");
const c = @cImport({
    @cInclude("ggml.h");
    @cInclude("ggml-cpu.h");
    @cInclude("gguf.h");
});

const gpa = std.heap.c_allocator;

fn gguf() ?*c.gguf_context {
    const h = embed.ggufHandle() orelse return null;
    return @ptrCast(@alignCast(h));
}
fn mctx() ?*c.ggml_context {
    const h = embed.ctxHandle() orelse return null;
    return @ptrCast(@alignCast(h));
}

// ---- KV helpers (own cImport types) ------------------------------------------
fn kvStr(key: [*:0]const u8) ?[*:0]const u8 {
    const ctx = gguf() orelse return null;
    const id = c.gguf_find_key(ctx, key);
    if (id < 0) return null;
    if (c.gguf_get_kv_type(ctx, id) != c.GGUF_TYPE_STRING) return null;
    return c.gguf_get_val_str(ctx, id);
}

fn archName() []const u8 {
    const a = kvStr("general.architecture") orelse return "";
    return std.mem.span(a);
}

fn kvArchInt(suffix: []const u8, dflt: i64) i64 {
    const ctx = gguf() orelse return dflt;
    const arch = archName();
    if (arch.len == 0) return dflt;
    var buf: [96]u8 = undefined;
    if (arch.len + suffix.len + 1 > buf.len) return dflt;
    @memcpy(buf[0..arch.len], arch);
    @memcpy(buf[arch.len..][0..suffix.len], suffix);
    buf[arch.len + suffix.len] = 0;
    const key: [*:0]const u8 = @ptrCast(&buf[0]);
    const id = c.gguf_find_key(ctx, key);
    if (id < 0) return dflt;
    return switch (c.gguf_get_kv_type(ctx, id)) {
        c.GGUF_TYPE_UINT32 => @intCast(c.gguf_get_val_u32(ctx, id)),
        c.GGUF_TYPE_INT32 => @intCast(c.gguf_get_val_i32(ctx, id)),
        c.GGUF_TYPE_UINT64 => @intCast(c.gguf_get_val_u64(ctx, id)),
        c.GGUF_TYPE_INT64 => c.gguf_get_val_i64(ctx, id),
        c.GGUF_TYPE_ARRAY => uniformArrayValue(ctx, id) orelse dflt,
        else => dflt,
    };
}

// Some models (granite) store a per-layer value, e.g. head_count_kv, as an ARRAY with one entry per layer.
// When every entry is the same it IS that value; when they differ (a hybrid or otherwise irregular stack)
// there is no single value and null is returned - callers that cannot run such a model refuse it.
fn uniformArrayValue(ctx: *c.gguf_context, id: i64) ?i64 {
    const at = c.gguf_get_arr_type(ctx, id);
    const n = c.gguf_get_arr_n(ctx, id);
    if (n == 0) return null;
    const data = c.gguf_get_arr_data(ctx, id) orelse return null;
    switch (at) {
        c.GGUF_TYPE_UINT32 => {
            const a: [*]const u32 = @ptrCast(@alignCast(data));
            var i: usize = 1;
            while (i < n) : (i += 1) if (a[i] != a[0]) return null;
            return @intCast(a[0]);
        },
        c.GGUF_TYPE_INT32 => {
            const a: [*]const i32 = @ptrCast(@alignCast(data));
            var i: usize = 1;
            while (i < n) : (i += 1) if (a[i] != a[0]) return null;
            return @intCast(a[0]);
        },
        else => return null,
    }
}

// True when the key exists as an array whose entries differ (an irregular stack this decoder cannot run).
fn kvArchIrregularArray(suffix: []const u8) bool {
    const ctx = gguf() orelse return false;
    const arch = archName();
    if (arch.len == 0) return false;
    var buf: [96]u8 = undefined;
    if (arch.len + suffix.len + 1 > buf.len) return false;
    @memcpy(buf[0..arch.len], arch);
    @memcpy(buf[arch.len..][0..suffix.len], suffix);
    buf[arch.len + suffix.len] = 0;
    const key: [*:0]const u8 = @ptrCast(&buf[0]);
    const id = c.gguf_find_key(ctx, key);
    if (id < 0) return false;
    if (c.gguf_get_kv_type(ctx, id) != c.GGUF_TYPE_ARRAY) return false;
    return uniformArrayValue(ctx, id) == null;
}

fn kvArchF32(suffix: []const u8, dflt: f32) f32 {
    const ctx = gguf() orelse return dflt;
    const arch = archName();
    if (arch.len == 0) return dflt;
    var buf: [96]u8 = undefined;
    if (arch.len + suffix.len + 1 > buf.len) return dflt;
    @memcpy(buf[0..arch.len], arch);
    @memcpy(buf[arch.len..][0..suffix.len], suffix);
    buf[arch.len + suffix.len] = 0;
    const key: [*:0]const u8 = @ptrCast(&buf[0]);
    const id = c.gguf_find_key(ctx, key);
    if (id < 0) return dflt;
    if (c.gguf_get_kv_type(ctx, id) == c.GGUF_TYPE_FLOAT32) return c.gguf_get_val_f32(ctx, id);
    return dflt;
}

fn kvI32(key: [*:0]const u8, dflt: i32) i32 {
    const ctx = gguf() orelse return dflt;
    const id = c.gguf_find_key(ctx, key);
    if (id < 0) return dflt;
    return switch (c.gguf_get_kv_type(ctx, id)) {
        c.GGUF_TYPE_UINT32 => @intCast(c.gguf_get_val_u32(ctx, id)),
        c.GGUF_TYPE_INT32 => c.gguf_get_val_i32(ctx, id),
        else => dflt,
    };
}

fn kvBool(key: [*:0]const u8, dflt: bool) bool {
    const ctx = gguf() orelse return dflt;
    const id = c.gguf_find_key(ctx, key);
    if (id < 0) return dflt;
    if (c.gguf_get_kv_type(ctx, id) != c.GGUF_TYPE_BOOL) return dflt;
    return c.gguf_get_val_bool(ctx, id);
}

fn getT(m: ?*c.ggml_context, comptime fmt: []const u8, args: anytype, b: []u8) *c.ggml_tensor {
    const s = std.fmt.bufPrintZ(b, fmt, args) catch unreachable;
    return c.ggml_get_tensor(m, s.ptr).?;
}
fn getTOpt(m: ?*c.ggml_context, comptime fmt: []const u8, args: anytype, b: []u8) ?*c.ggml_tensor {
    const s = std.fmt.bufPrintZ(b, fmt, args) catch unreachable;
    return c.ggml_get_tensor(m, s.ptr);
}

// ---- generator detection ------------------------------------------------------
// A DECODER model: llama-family arch with a causal backbone (attn_norm + rope
// hyperparams) and a gpt2-BPE tokenizer with merges.
pub export fn neural_model_has_generator() callconv(.c) c_int {
    if (gguf() == null or mctx() == null) return 0;
    const arch = archName();
    const known = std.mem.eql(u8, arch, "llama") or std.mem.eql(u8, arch, "qwen2") or
        std.mem.eql(u8, arch, "qwen3") or std.mem.eql(u8, arch, "smollm") or
        std.mem.eql(u8, arch, "granite");
    if (!known) return 0;
    var nb: [64]u8 = undefined;
    if (getTOpt(mctx(), "blk.0.attn_norm.weight", .{}, &nb) == null) return 0;
    if (getTOpt(mctx(), "output_norm.weight", .{}, &nb) == null) return 0;
    // This decoder is a DENSE attention stack. A mixture-of-experts model, a hybrid with state-space
    // layers, or any stack whose layers differ in KV heads is REFUSED here, so that loading it says
    // "not a generator" instead of aborting inside the graph (the granite family ships all of these
    // under the same arch string).
    if (kvArchInt(".expert_count", 0) > 0) return 0;
    if (kvArchIrregularArray(".attention.head_count_kv")) return 0;
    const n_layers: usize = @intCast(@max(kvArchInt(".block_count", 0), 0));
    var li: usize = 0;
    while (li < n_layers) : (li += 1) {
        if (getTOpt(mctx(), "blk.{d}.attn_q.weight", .{li}, &nb) == null) return 0;
    }
    return 1;
}

// ---- GPT-2 byte-level BPE ------------------------------------------------------
// Bytes map to printable unicode chars (the GPT-2 trick) so every byte sequence
// is representable; the GGUF vocab/merges are stored in that mapped form.
var g_b2u: [256]u21 = undefined; // byte -> unicode cp
var g_u2b: [512]i16 = undefined; // unicode cp (< 512) -> byte, -1 = none
var g_maps_built: bool = false;

fn buildByteMaps() void {
    if (g_maps_built) return;
    for (0..512) |i| g_u2b[i] = -1;
    var n: u21 = 0;
    for (0..256) |bi| {
        const b: u21 = @intCast(bi);
        const printable = (b >= '!' and b <= '~') or (b >= 0xA1 and b <= 0xAC) or (b >= 0xAE and b <= 0xFF);
        if (printable) {
            g_b2u[bi] = b;
        } else {
            g_b2u[bi] = 256 + n;
            n += 1;
        }
        g_u2b[g_b2u[bi]] = @intCast(bi);
    }
    g_maps_built = true;
}

var g_bpe_built: bool = false;
var g_bpe_gen: usize = 0; // embed.model_generation at build time
var g_tok_map: std.StringHashMap(i32) = undefined; // token string -> id
var g_merge_map: std.StringHashMap(i32) = undefined; // "left right" -> rank
var g_n_vocab: usize = 0;
var g_bos: i32 = -1;
var g_eos: i32 = -1;
var g_add_bos: bool = false;
// `hidden`: a CONTROL token (type 3) never appears in decoded text; a USER-DEFINED added token (type 4) is matched
// when ENCODING (so "<think>" is ONE token, as the model was trained, not "<" "think" ">") but is still shown when
// DECODING, as llama.cpp does.
const Special = struct { s: []const u8, id: i32, hidden: bool = true };
var g_specials: std.ArrayList(Special) = .{};
var g_eog: std.ArrayList(i32) = .{}; // end-of-generation ids (eos, <|im_end|>, ...)

fn freeBpe() void {
    if (g_bpe_built) {
        g_tok_map.deinit();
        g_merge_map.deinit();
        g_specials.clearAndFree(gpa);
        g_eog.clearAndFree(gpa);
        g_bpe_built = false;
        // the decoded-piece cache is keyed to THIS vocabulary; a new model
        // means new pieces, and a stale one would mask the wrong tokens
        g_pieces_ready = false;
    }
}

fn vocabToken(i: usize) []const u8 {
    const ctx = gguf() orelse return "";
    const tid = c.gguf_find_key(ctx, "tokenizer.ggml.tokens");
    if (tid < 0) return "";
    return std.mem.span(c.gguf_get_arr_str(ctx, tid, @intCast(i)));
}

fn buildBpe() bool {
    // model reloaded since last build? invalidate everything generation-scoped
    if (g_bpe_built and g_bpe_gen == embed.model_generation) return true;
    freeBpe();
    resetKv();
    const ctx = gguf() orelse return false;
    buildByteMaps();
    const tid = c.gguf_find_key(ctx, "tokenizer.ggml.tokens");
    if (tid < 0) return false;
    const n: usize = @intCast(c.gguf_get_arr_n(ctx, tid));
    g_n_vocab = n;
    g_tok_map = std.StringHashMap(i32).init(gpa);
    g_merge_map = std.StringHashMap(i32).init(gpa);

    // token types (3 = CONTROL) for special-token literal matching
    var types: ?[*]const i32 = null;
    const yid = c.gguf_find_key(ctx, "tokenizer.ggml.token_type");
    if (yid >= 0 and c.gguf_get_kv_type(ctx, yid) == c.GGUF_TYPE_ARRAY and
        c.gguf_get_arr_type(ctx, yid) == c.GGUF_TYPE_INT32)
    {
        types = @ptrCast(@alignCast(c.gguf_get_arr_data(ctx, yid)));
    }

    for (0..n) |i| {
        const s = std.mem.span(c.gguf_get_arr_str(ctx, tid, i)); // stable while loaded
        g_tok_map.put(s, @intCast(i)) catch {};
        if (types) |ty| {
            if ((ty[i] == 3 or ty[i] == 4) and s.len > 0) { // CONTROL, or USER-DEFINED (added tokens: <think>, <tool_call>...)
                g_specials.append(gpa, .{ .s = s, .id = @intCast(i), .hidden = (ty[i] == 3) }) catch {};
            }
        }
    }

    const mid = c.gguf_find_key(ctx, "tokenizer.ggml.merges");
    if (mid >= 0) {
        const nm: usize = @intCast(c.gguf_get_arr_n(ctx, mid));
        for (0..nm) |i| {
            const s = std.mem.span(c.gguf_get_arr_str(ctx, mid, i));
            g_merge_map.put(s, @intCast(i)) catch {};
        }
    }

    g_bos = kvI32("tokenizer.ggml.bos_token_id", -1);
    g_eos = kvI32("tokenizer.ggml.eos_token_id", -1);
    g_add_bos = kvBool("tokenizer.ggml.add_bos_token", false);
    if (g_eos >= 0) g_eog.append(gpa, g_eos) catch {};
    // ChatML end marker doubles as end-of-generation when present
    if (g_tok_map.get("<|im_end|>")) |id| {
        if (id != g_eos) g_eog.append(gpa, id) catch {};
    }
    if (g_tok_map.get("<|endoftext|>")) |id| {
        if (id != g_eos) g_eog.append(gpa, id) catch {};
    }
    g_bpe_gen = embed.model_generation;
    g_bpe_built = true;
    return true;
}

fn isAsciiLetter(b: u8) bool {
    return (b >= 'a' and b <= 'z') or (b >= 'A' and b <= 'Z') or b >= 0x80;
}
fn isAsciiDigit(b: u8) bool {
    return b >= '0' and b <= '9';
}
fn isWs(b: u8) bool {
    return b == ' ' or b == '\t' or b == '\n' or b == '\r';
}

// Encode one pre-token (raw bytes) via byte->unicode mapping + BPE merges.
fn bpeWord(word: []const u8, out: *std.ArrayList(i32)) void {
    if (word.len == 0) return;
    // map bytes to the unicode form (each byte -> one codepoint, utf8-encoded)
    var mapped: std.ArrayList(u8) = .{};
    defer mapped.clearAndFree(gpa);
    // symbol boundaries into `mapped` (start offsets; one symbol per BYTE initially)
    var bounds: std.ArrayList(usize) = .{};
    defer bounds.clearAndFree(gpa);
    for (word) |b| {
        bounds.append(gpa, mapped.items.len) catch return;
        var ub: [4]u8 = undefined;
        const un = std.unicode.utf8Encode(g_b2u[b], &ub) catch continue;
        mapped.appendSlice(gpa, ub[0..un]) catch return;
    }
    bounds.append(gpa, mapped.items.len) catch return;

    // greedy lowest-rank merge until no merge applies
    var kb: [640]u8 = undefined;
    while (bounds.items.len > 2) {
        var best_rank: i32 = std.math.maxInt(i32);
        var best_i: usize = 0;
        var i: usize = 0;
        while (i + 2 < bounds.items.len) : (i += 1) {
            const a = mapped.items[bounds.items[i]..bounds.items[i + 1]];
            const b2 = mapped.items[bounds.items[i + 1]..bounds.items[i + 2]];
            if (a.len + 1 + b2.len > kb.len) continue;
            @memcpy(kb[0..a.len], a);
            kb[a.len] = ' ';
            @memcpy(kb[a.len + 1 ..][0..b2.len], b2);
            if (g_merge_map.get(kb[0 .. a.len + 1 + b2.len])) |r| {
                if (r < best_rank) {
                    best_rank = r;
                    best_i = i;
                }
            }
        }
        if (best_rank == std.math.maxInt(i32)) break;
        _ = bounds.orderedRemove(best_i + 1); // fuse the pair
    }

    // symbols -> ids (fallback: per-byte token lookup)
    var si: usize = 0;
    while (si + 1 < bounds.items.len) : (si += 1) {
        const sym = mapped.items[bounds.items[si]..bounds.items[si + 1]];
        if (g_tok_map.get(sym)) |id| {
            out.append(gpa, id) catch {};
        } else {
            // per-codepoint fallback
            var view = std.unicode.Utf8View.init(sym) catch continue;
            var it = view.iterator();
            while (it.nextCodepointSlice()) |cs| {
                if (g_tok_map.get(cs)) |id2| out.append(gpa, id2) catch {};
            }
        }
    }
}

// GPT-2-style pre-tokenization (pragmatic approximation): optional leading
// space glued to the following letter/digit/symbol run; whitespace runs kept.
fn bpeSegment(text: []const u8, out: *std.ArrayList(i32)) void {
    var i: usize = 0;
    while (i < text.len) {
        var start = i;
        // a single leading space attaches to the next word (the Ġ convention)
        if (text[i] == ' ' and i + 1 < text.len and !isWs(text[i + 1])) i += 1;
        if (i < text.len and isAsciiLetter(text[i])) {
            while (i < text.len and isAsciiLetter(text[i])) i += 1;
            bpeWord(text[start..i], out);
            continue;
        }
        if (i < text.len and isAsciiDigit(text[i])) {
            while (i < text.len and isAsciiDigit(text[i])) i += 1;
            bpeWord(text[start..i], out);
            continue;
        }
        if (i < text.len and !isWs(text[i])) { // punctuation / symbols run
            while (i < text.len and !isWs(text[i]) and !isAsciiLetter(text[i]) and !isAsciiDigit(text[i])) i += 1;
            bpeWord(text[start..i], out);
            continue;
        }
        // pure whitespace run (the glued-space case was consumed above)
        start = i;
        while (i < text.len and isWs(text[i])) i += 1;
        if (i > start) bpeWord(text[start..i], out);
    }
}

// Full encode: CONTROL tokens matched literally first, BPE between them.
fn encode(text: []const u8, out: *std.ArrayList(i32)) void {
    if (g_add_bos and g_bos >= 0) out.append(gpa, g_bos) catch {};
    var i: usize = 0;
    var seg_start: usize = 0;
    while (i < text.len) {
        var matched: ?Special = null;
        // the LONGEST special that starts here (a short one must not shadow a longer one)
        for (g_specials.items) |sp| {
            if (sp.s.len > 0 and i + sp.s.len <= text.len and
                std.mem.eql(u8, text[i .. i + sp.s.len], sp.s))
            {
                if (matched == null or sp.s.len > matched.?.s.len) matched = sp;
            }
        }
        if (matched) |sp| {
            if (i > seg_start) bpeSegment(text[seg_start..i], out);
            out.append(gpa, sp.id) catch {};
            i += sp.s.len;
            seg_start = i;
        } else {
            i += 1;
        }
    }
    if (text.len > seg_start) bpeSegment(text[seg_start..], out);
}

// Decode ids -> bytes (reverse byte-unicode mapping; control tokens skipped).
fn decodeInto(ids: []const i32, out: *std.ArrayList(u8)) void {
    for (ids) |id| {
        if (id < 0 or @as(usize, @intCast(id)) >= g_n_vocab) continue;
        var is_special = false;
        for (g_specials.items) |sp| {
            if (sp.id == id and sp.hidden) {
                is_special = true;
                break;
            }
        }
        if (is_special) continue;
        const s = vocabToken(@intCast(id));
        var view = std.unicode.Utf8View.init(s) catch continue;
        var it = view.iterator();
        while (it.nextCodepoint()) |cp| {
            if (cp < 512 and g_u2b[cp] >= 0) {
                out.append(gpa, @intCast(g_u2b[cp])) catch {};
            } else {
                var ub: [4]u8 = undefined;
                const un = std.unicode.utf8Encode(cp, &ub) catch continue;
                out.appendSlice(gpa, ub[0..un]) catch {};
            }
        }
    }
}

// ---- KV cache -----------------------------------------------------------------
var g_kc: std.ArrayList(std.ArrayList(f32)) = .{}; // per layer, pos-major [p][g*hd+d]
var g_vc: std.ArrayList(std.ArrayList(f32)) = .{};
var g_n_past: usize = 0;
var g_logits: std.ArrayList(f32) = .{};
var g_gen_text: std.ArrayList(u8) = .{};

fn resetKv() void {
    for (g_kc.items) |*a| a.clearAndFree(gpa);
    for (g_vc.items) |*a| a.clearAndFree(gpa);
    g_kc.clearAndFree(gpa);
    g_vc.clearAndFree(gpa);
    g_n_past = 0;
}

// The model's shape, read once per forward and handed to the graph builder.
const Dims = struct {
    n_embd: usize,
    n_head: usize,
    n_kv: usize,
    n_layer: usize,
    hd: usize,
    grp: usize,
    eps: f32,
    rope_base: f32,
    n_ctx_train: i32,
    rope_type: c_int,
    n_past: usize,
    // granite: four scalars that are no-ops for every other architecture (1, 0 = use 1/sqrt(hd), 1, 1)
    emb_scale: f32,
    att_scale: f32,
    res_scale: f32,
    logit_scale: f32,
};

const DecodeGraph = struct { graph: *c.ggml_cgraph, logits: *c.ggml_tensor };

const decode_graph_nodes: usize = 8192;

// What the graph needs from its context, EXACTLY: every tensor's header plus
// the data of each tensor that owns data (a view borrows its source's), plus
// the graph object. Read off a graph built with no_alloc, where nothing is
// allocated but everything is sized.
fn graphPoolBytes(ctx: *c.ggml_context) usize {
    const align_mask: usize = c.GGML_MEM_ALIGN - 1;
    var total: usize = c.ggml_graph_overhead_custom(decode_graph_nodes, false);
    var t = c.ggml_get_first_tensor(ctx);
    while (t != null) : (t = c.ggml_get_next_tensor(ctx, t)) {
        total += c.ggml_tensor_overhead();
        if (t.*.view_src == null) total += (c.ggml_nbytes(t) + align_mask) & ~align_mask;
    }
    return total;
}

// Everything one decoder forward puts in its graph. With fill == false the
// graph is built for its SHAPE only (tensors carry no data), which is what
// lets forwardDecode size its pool from the graph instead of from a formula.
fn buildDecodeGraph(
    ctx: *c.ggml_context,
    m: ?*c.ggml_context,
    ids: []const i32,
    d: Dims,
    fill: bool,
    kouts: *std.ArrayList(*c.ggml_tensor),
    vouts: *std.ArrayList(*c.ggml_tensor),
) ?DecodeGraph {
    const n_new = ids.len;
    const n_past = d.n_past;
    const kv_len = n_past + n_new;
    const n_embd = d.n_embd;
    const n_head = d.n_head;
    const n_kv = d.n_kv;
    const n_layer = d.n_layer;
    const hd = d.hd;
    const grp = d.grp;
    const eps = d.eps;
    const rope_base = d.rope_base;
    const n_ctx_train = d.n_ctx_train;
    const rope_type = d.rope_type;

    var nb: [96]u8 = undefined;
    var nb2: [96]u8 = undefined;

    const tokens = c.ggml_new_tensor_1d(ctx, c.GGML_TYPE_I32, @intCast(n_new)).?;
    const positions = c.ggml_new_tensor_1d(ctx, c.GGML_TYPE_I32, @intCast(n_new)).?;
    if (fill) {
        const td: [*]i32 = @ptrCast(@alignCast(tokens.*.data));
        const pd: [*]i32 = @ptrCast(@alignCast(positions.*.data));
        for (0..n_new) |i| {
            td[i] = ids[i];
            pd[i] = @intCast(n_past + i);
        }
    }

    // causal mask [kv_len, n_new*grp]: query x (token t = x % n_new, global
    // position n_past+t) may attend keys 0..n_past+t
    const mask = c.ggml_new_tensor_2d(ctx, c.GGML_TYPE_F32, @intCast(kv_len), @intCast(n_new * grp)).?;
    if (fill) {
        const mkd: [*]f32 = @ptrCast(@alignCast(mask.*.data));
        for (0..n_new * grp) |x| {
            const t = x % n_new;
            for (0..kv_len) |k| {
                mkd[x * kv_len + k] = if (k <= n_past + t) 0.0 else -1.0e9;
            }
        }
    }

    var cur = c.ggml_get_rows(ctx, getT(m, "token_embd.weight", .{}, &nb), tokens).?;
    if (d.emb_scale != 1.0) cur = c.ggml_scale(ctx, cur, d.emb_scale).?;

    // granite states its attention scale; everything else uses 1/sqrt(head_dim)
    const scale: f32 = if (d.att_scale > 0.0) d.att_scale else 1.0 / @sqrt(@as(f32, @floatFromInt(hd)));

    for (0..n_layer) |L| {
        const inpL = cur;
        var h = c.ggml_rms_norm(ctx, cur, eps).?;
        h = c.ggml_mul(ctx, h, getT(m, "blk.{d}.attn_norm.weight", .{L}, &nb)).?;

        var Q = c.ggml_mul_mat(ctx, getT(m, "blk.{d}.attn_q.weight", .{L}, &nb), h).?;
        if (getTOpt(m, "blk.{d}.attn_q.bias", .{L}, &nb2)) |bq| Q = c.ggml_add(ctx, Q, bq).?;
        var K = c.ggml_mul_mat(ctx, getT(m, "blk.{d}.attn_k.weight", .{L}, &nb), h).?;
        if (getTOpt(m, "blk.{d}.attn_k.bias", .{L}, &nb2)) |bk| K = c.ggml_add(ctx, K, bk).?;
        var V = c.ggml_mul_mat(ctx, getT(m, "blk.{d}.attn_v.weight", .{L}, &nb), h).?;
        if (getTOpt(m, "blk.{d}.attn_v.bias", .{L}, &nb2)) |bv| V = c.ggml_add(ctx, V, bv).?;

        // RoPE on Q and K (shape [hd, heads, n_new] as rope expects)
        var Q3 = c.ggml_reshape_3d(ctx, Q, @intCast(hd), @intCast(n_head), @intCast(n_new)).?;
        // qwen3 normalises each head's Q (and K) with a learned [hd] weight BEFORE rope; the tensors
        // exist only in such models, so every other architecture takes the old path unchanged
        if (getTOpt(m, "blk.{d}.attn_q_norm.weight", .{L}, &nb2)) |qn|
            Q3 = c.ggml_mul(ctx, c.ggml_rms_norm(ctx, Q3, eps), qn).?;
        Q3 = c.ggml_rope_ext(ctx, Q3, positions, null, @intCast(hd), rope_type, n_ctx_train, rope_base, 1.0, 0.0, 1.0, 0.0, 0.0).?;
        var K3 = c.ggml_reshape_3d(ctx, K, @intCast(hd), @intCast(n_kv), @intCast(n_new)).?;
        if (getTOpt(m, "blk.{d}.attn_k_norm.weight", .{L}, &nb2)) |kn|
            K3 = c.ggml_mul(ctx, c.ggml_rms_norm(ctx, K3, eps), kn).?;
        K3 = c.ggml_rope_ext(ctx, K3, positions, null, @intCast(hd), rope_type, n_ctx_train, rope_base, 1.0, 0.0, 1.0, 0.0, 0.0).?;

        // Kcur/Vcur in cache-readout layout [hd, n_new, heads_kv]
        const Kcur = c.ggml_cont(ctx, c.ggml_permute(ctx, K3, 0, 2, 1, 3)).?;
        const V3 = c.ggml_reshape_3d(ctx, V, @intCast(hd), @intCast(n_kv), @intCast(n_new)).?;
        const Vcur = c.ggml_cont(ctx, c.ggml_permute(ctx, V3, 0, 2, 1, 3)).?;
        kouts.append(gpa, Kcur) catch return null;
        vouts.append(gpa, Vcur) catch return null;

        // K_all/V_all = cached part (input tensors) ++ current
        var K_all = Kcur;
        var V_all = Vcur;
        if (n_past > 0) {
            const kpast = c.ggml_new_tensor_3d(ctx, c.GGML_TYPE_F32, @intCast(hd), @intCast(n_past), @intCast(n_kv)).?;
            const vpast = c.ggml_new_tensor_3d(ctx, c.GGML_TYPE_F32, @intCast(hd), @intCast(n_past), @intCast(n_kv)).?;
            if (fill) {
                const kpd: [*]f32 = @ptrCast(@alignCast(kpast.*.data));
                const vpd: [*]f32 = @ptrCast(@alignCast(vpast.*.data));
                const kc = g_kc.items[L].items;
                const vc = g_vc.items[L].items;
                for (0..n_kv) |g| {
                    for (0..n_past) |p| {
                        for (0..hd) |dd| {
                            kpd[dd + hd * (p + n_past * g)] = kc[p * (n_kv * hd) + g * hd + dd];
                            vpd[dd + hd * (p + n_past * g)] = vc[p * (n_kv * hd) + g * hd + dd];
                        }
                    }
                }
            }
            K_all = c.ggml_concat(ctx, kpast, Kcur, 1).?;
            V_all = c.ggml_concat(ctx, vpast, Vcur, 1).?;
        }

        // attention: group-query via the reshape trick (consecutive q-heads share
        // a kv head)
        const Qp = c.ggml_cont(ctx, c.ggml_permute(ctx, Q3, 0, 2, 1, 3)).?; // [hd, n_new, n_head]
        const Qv = c.ggml_reshape_3d(ctx, Qp, @intCast(hd), @intCast(n_new * grp), @intCast(n_kv)).?;
        var KQ = c.ggml_mul_mat(ctx, K_all, Qv).?; // [kv_len, n_new*grp, n_kv]
        KQ = c.ggml_soft_max_ext(ctx, KQ, mask, scale, 0.0).?;
        const Vt = c.ggml_cont(ctx, c.ggml_permute(ctx, V_all, 1, 0, 2, 3)).?; // [kv_len, hd, n_kv]
        var KQV = c.ggml_mul_mat(ctx, Vt, KQ).?; // [hd, n_new*grp, n_kv]
        KQV = c.ggml_reshape_3d(ctx, KQV, @intCast(hd), @intCast(n_new), @intCast(n_head)).?;
        KQV = c.ggml_cont(ctx, c.ggml_permute(ctx, KQV, 0, 2, 1, 3)).?;
        KQV = c.ggml_reshape_2d(ctx, KQV, @intCast(hd * n_head), @intCast(n_new)).?;

        var attn = c.ggml_mul_mat(ctx, getT(m, "blk.{d}.attn_output.weight", .{L}, &nb), KQV).?;
        if (getTOpt(m, "blk.{d}.attn_output.bias", .{L}, &nb2)) |bo| attn = c.ggml_add(ctx, attn, bo).?;
        if (d.res_scale != 1.0) attn = c.ggml_scale(ctx, attn, d.res_scale).?;
        cur = c.ggml_add(ctx, attn, inpL).?;

        // SwiGLU FFN
        var h2 = c.ggml_rms_norm(ctx, cur, eps).?;
        h2 = c.ggml_mul(ctx, h2, getT(m, "blk.{d}.ffn_norm.weight", .{L}, &nb)).?;
        const gate = c.ggml_mul_mat(ctx, getT(m, "blk.{d}.ffn_gate.weight", .{L}, &nb), h2).?;
        const up = c.ggml_mul_mat(ctx, getT(m, "blk.{d}.ffn_up.weight", .{L}, &nb2), h2).?;
        var ff = c.ggml_mul(ctx, c.ggml_silu(ctx, gate), up).?;
        ff = c.ggml_mul_mat(ctx, getT(m, "blk.{d}.ffn_down.weight", .{L}, &nb), ff).?;
        if (d.res_scale != 1.0) ff = c.ggml_scale(ctx, ff, d.res_scale).?;
        cur = c.ggml_add(ctx, cur, ff).?;
    }

    var xF = c.ggml_rms_norm(ctx, cur, eps).?;
    xF = c.ggml_mul(ctx, xF, getT(m, "output_norm.weight", .{}, &nb)).?;
    // lm_head on the LAST token only (untied output.weight, else tied embeddings)
    const last = c.ggml_view_2d(ctx, xF, @intCast(n_embd), 1, xF.*.nb[1], @intCast((n_new - 1) * xF.*.nb[1])).?;
    const lastc = c.ggml_cont(ctx, last).?;
    const lm_w = getTOpt(m, "output.weight", .{}, &nb) orelse getT(m, "token_embd.weight", .{}, &nb);
    var logits = c.ggml_mul_mat(ctx, lm_w, lastc).?;
    // granite divides the logits by a stated factor
    if (d.logit_scale != 1.0 and d.logit_scale > 0.0) logits = c.ggml_scale(ctx, logits, 1.0 / d.logit_scale).?;

    const graph = c.ggml_new_graph_custom(ctx, decode_graph_nodes, false) orelse return null;
    c.ggml_build_forward_expand(graph, logits);
    for (kouts.items) |t| c.ggml_build_forward_expand(graph, t);
    for (vouts.items) |t| c.ggml_build_forward_expand(graph, t);
    return .{ .graph = graph, .logits = logits };
}

// The pool the last forward pass asked for, in bytes (0 before any). Exposed so
// a guard can report what a prompt of a given size costs a given model.
var g_last_pool_bytes: usize = 0;

pub export fn neural_gen_last_pool_bytes() callconv(.c) f64 {
    return @floatFromInt(g_last_pool_bytes);
}

// One decoder forward over `ids` (n_new tokens) with the current cache;
// leaves the last token's logits in g_logits and appends K/V to the cache.
//
// THE POOL IS MEASURED, NOT ESTIMATED. The graph is built twice: first in a
// context that allocates nothing (no_alloc), which is enough to know the size
// of every tensor in it; then in a context of exactly that many bytes. The
// formula this replaced (128 MB + kv_len*n_new*n_head*n_layer*24 + ...) was
// a few hundred KB short for Qwen2.5-Coder-1.5B, so that model could not
// answer a 40-token prompt, and at 512 tokens the process ended in a
// GGML_ASSERT. A graph cannot disagree with its own size.
fn forwardDecode(ids: []const i32) bool {
    const m = mctx() orelse return false;
    const n_new = ids.len;
    if (n_new == 0) return false;

    const n_embd: usize = @intCast(kvArchInt(".embedding_length", 0));
    const n_head: usize = @intCast(kvArchInt(".attention.head_count", 0));
    const n_kv: usize = @intCast(kvArchInt(".attention.head_count_kv", @intCast(n_head)));
    const n_layer: usize = @intCast(kvArchInt(".block_count", 0));
    if (n_embd == 0 or n_head == 0 or n_layer == 0 or n_kv == 0) return false;
    const arch = archName();
    const dims = Dims{
        .n_embd = n_embd,
        .n_head = n_head,
        .n_kv = n_kv,
        .n_layer = n_layer,
        // Qwen3 (and others) decouple the head dimension from hidden/heads: the 0.6B has hidden 1024,
        // 16 heads and head_dim 128, so the attention width (n_head*hd = 2048) is NOT n_embd. The GGUF
        // says so in `.attention.key_length`; models that omit it have hd = n_embd/n_head, as before.
        .hd = @intCast(kvArchInt(".attention.key_length", @intCast(n_embd / n_head))),
        .grp = n_head / n_kv,
        .eps = kvArchF32(".attention.layer_norm_rms_epsilon", 1e-5),
        .rope_base = kvArchF32(".rope.freq_base", 10000.0),
        .n_ctx_train = @intCast(kvArchInt(".context_length", 2048)),
        // llama-family GGUFs are converted with PERMUTED Q/K weights so NORMAL
        // (interleaved) rope applies; qwen2/qwen3 use the NeoX layout.
        .rope_type = if (std.mem.eql(u8, arch, "qwen2") or std.mem.eql(u8, arch, "qwen3"))
            c.GGML_ROPE_TYPE_NEOX
        else
            c.GGML_ROPE_TYPE_NORMAL,
        .n_past = g_n_past,
        .emb_scale = kvArchF32(".embedding_scale", 1.0),
        .att_scale = kvArchF32(".attention.scale", 0.0),
        .res_scale = kvArchF32(".residual_scale", 1.0),
        .logit_scale = kvArchF32(".logit_scale", 1.0),
    };

    // grow the per-layer cache lists on first use
    if (g_kc.items.len != n_layer) {
        resetKv();
        for (0..n_layer) |_| {
            g_kc.append(gpa, .{}) catch return false;
            g_vc.append(gpa, .{}) catch return false;
        }
    }
    // resetKv() above may have zeroed g_n_past
    const n_past = g_n_past;
    var dims_now = dims;
    dims_now.n_past = n_past;

    var kouts: std.ArrayList(*c.ggml_tensor) = .{};
    defer kouts.clearAndFree(gpa);
    var vouts: std.ArrayList(*c.ggml_tensor) = .{};
    defer vouts.clearAndFree(gpa);

    // pass 1: the graph's shape, in a context that holds headers and no data
    var pool_bytes: usize = 0;
    {
        const meta = c.ggml_init(.{ .mem_size = 64 * 1024 * 1024, .mem_buffer = null, .no_alloc = true }) orelse return false;
        defer c.ggml_free(meta);
        if (buildDecodeGraph(meta, m, ids, dims_now, false, &kouts, &vouts) == null) return false;
        pool_bytes = graphPoolBytes(meta);
    }
    kouts.clearRetainingCapacity();
    vouts.clearRetainingCapacity();
    g_last_pool_bytes = pool_bytes;

    // pass 2: the same graph, in a pool of exactly the size pass 1 measured
    const ctx = c.ggml_init(.{ .mem_size = pool_bytes + 64 * 1024, .mem_buffer = null, .no_alloc = false }) orelse return false;
    defer c.ggml_free(ctx);
    const built = buildDecodeGraph(ctx, m, ids, dims_now, true, &kouts, &vouts) orelse return false;
    const graph = built.graph;
    const logits = built.logits;

    var plan = c.ggml_graph_plan(graph, 4, null);
    var wbuf: ?[]u8 = null;
    if (plan.work_size > 0) {
        wbuf = gpa.alloc(u8, plan.work_size) catch return false;
        plan.work_data = wbuf.?.ptr;
    }
    defer if (wbuf) |w| gpa.free(w);
    _ = c.ggml_graph_compute(graph, &plan);

    // append the new K/V ([hd, n_new, n_kv], element (d,t,g)) to the caches
    const hd = dims.hd;
    for (0..n_layer) |L| {
        const kd: [*]const f32 = @ptrCast(@alignCast(kouts.items[L].*.data));
        const vd: [*]const f32 = @ptrCast(@alignCast(vouts.items[L].*.data));
        const kc = &g_kc.items[L];
        const vc = &g_vc.items[L];
        kc.ensureTotalCapacity(gpa, (n_past + n_new) * n_kv * hd) catch return false;
        vc.ensureTotalCapacity(gpa, (n_past + n_new) * n_kv * hd) catch return false;
        for (0..n_new) |t| {
            for (0..n_kv) |g| {
                for (0..hd) |d| {
                    kc.appendAssumeCapacity(kd[d + hd * (t + n_new * g)]);
                    vc.appendAssumeCapacity(vd[d + hd * (t + n_new * g)]);
                }
            }
        }
    }
    g_n_past = n_past + n_new;

    // read back the last-token logits
    const n_vocab_t: usize = @intCast(logits.*.ne[0]);
    const ld: [*]const f32 = @ptrCast(@alignCast(logits.*.data));
    g_logits.clearRetainingCapacity();
    g_logits.ensureTotalCapacity(gpa, n_vocab_t) catch return false;
    for (0..n_vocab_t) |i| g_logits.appendAssumeCapacity(ld[i]);
    return true;
}

fn argmaxLogits() i32 {
    var best: usize = 0;
    var bestv: f32 = -3.4e38;
    for (g_logits.items, 0..) |v, i| {
        if (v > bestv) {
            bestv = v;
            best = i;
        }
    }
    return @intCast(best);
}

fn isEog(id: i32) bool {
    for (g_eog.items) |e| {
        if (e == id) return true;
    }
    return false;
}

// ---- sampling ------------------------------------------------------------------
// temperature <= 0 -> greedy (deterministic). Otherwise: logits/temp ->
// top-k -> softmax -> top-p nucleus -> draw with the SEEDED prng, so a
// given (prompt, options, seed) is reproducible.
var g_prng: std.Random.DefaultPrng = undefined;

const Cand = struct { id: i32, v: f32 };
fn candDesc(_: void, a: Cand, b: Cand) bool {
    return a.v > b.v;
}

fn sampleId(temp: f32, top_p: f32, top_k: c_int) i32 {
    if (temp <= 0) return argmaxLogits();
    const n = g_logits.items.len;
    if (n == 0) return -1;
    const cands = gpa.alloc(Cand, n) catch return argmaxLogits();
    defer gpa.free(cands);
    for (g_logits.items, 0..) |v, i| cands[i] = .{ .id = @intCast(i), .v = v };
    return sampleFrom(cands, temp, top_p, top_k);
}

// The draw itself, over WHATEVER candidates it is handed. Split out of
// sampleId so the grammar path can hand it the surviving candidates and
// get the same temperature / top-k / top-p behaviour, rather than growing
// a second sampler that drifts from this one.
fn sampleFrom(cands: []Cand, temp: f32, top_p: f32, top_k: c_int) i32 {
    const n = cands.len;
    if (n == 0) return -1;
    if (temp <= 0) {
        var best = cands[0];
        for (cands[1..]) |cd| {
            if (cd.v > best.v) best = cd;
        }
        return best.id;
    }
    std.mem.sort(Cand, cands, {}, candDesc);
    var k: usize = if (top_k > 0) @min(@as(usize, @intCast(top_k)), n) else n;
    if (k > 200) k = 200; // hard cap: the tail is numerically irrelevant
    // softmax over the kept candidates (temperature applied)
    const maxv = cands[0].v;
    var sum: f32 = 0;
    for (0..k) |i| {
        const e = @exp((cands[i].v - maxv) / temp);
        cands[i].v = e;
        sum += e;
    }
    if (sum <= 0) return cands[0].id;
    // top-p nucleus: the smallest prefix whose mass reaches top_p
    var kept: usize = k;
    if (top_p > 0 and top_p < 1) {
        var acc: f32 = 0;
        for (0..k) |i| {
            acc += cands[i].v / sum;
            if (acc >= top_p) {
                kept = i + 1;
                break;
            }
        }
    }
    var ksum: f32 = 0;
    for (0..kept) |i| ksum += cands[i].v;
    const r = g_prng.random().float(f32) * ksum;
    var acc2: f32 = 0;
    for (0..kept) |i| {
        acc2 += cands[i].v;
        if (r <= acc2) return cands[i].id;
    }
    return cands[kept - 1].id;
}

// ---- GRAMMAR-CONSTRAINED DECODING ----------------------------------------------
//
// THE DIFFERENCE THIS MAKES, AND THE ONLY CLAIM IT EARNS. Without it, a
// schema is CHECKED after the model has spoken: measured on the model this
// repository ships, 5.0 calls per valid answer and 4 inputs in 10 that no
// number of retries rescues (base/test/neural/_measure_structured.ring).
// With it, a token that would violate the grammar is never among the
// candidates -- the violation is UNEMITTABLE rather than caught.
//
// It constrains SHAPE ONLY. `city: Paris` and `city: Tokyo` are equally
// grammatical, and no grammar makes a wrong answer right. The Ring court in
// stzOutputSchema still checks every value constraint, and schema_gbnf's
// stz_gbnf_unenforced() lists them by name.
//
// HOW A CANDIDATE IS JUDGED. A token is not a byte: its piece may be
// several bytes, and a piece whose first bytes fit while its last does not
// must be refused (the `yesterday` case, unit-tested in gbnf_machine.zig).
// So the machine is cloned and fed the WHOLE piece, and only a piece that
// survives to its last byte is allowed to be drawn.
//
// THE COST, HONESTLY. The judgement runs over the whole vocabulary at every
// step. A one-byte prefilter (the set of bytes any live position could take
// next) throws away the great majority before the whole-piece test runs,
// and the decoded piece of every token is cached once per model rather than
// rebuilt per step.

var g_gram_on: bool = false;
var g_gram_masked: usize = 0; // candidates refused across this generation
var g_gram_seen: usize = 0; // candidates judged across this generation
var g_gram_steps: usize = 0;
var g_gram_stalled: bool = false; // the grammar admitted NO token at some step

// Every token's decoded bytes, once per model. Control tokens decode to
// nothing (decodeInto skips them), which is what keeps them out of the
// candidate set unless the grammar is complete and they are end-of-generation.
var g_piece_buf: std.ArrayList(u8) = .{};
var g_piece_off: std.ArrayList(u32) = .{};
var g_pieces_gen: usize = 0;
var g_pieces_ready: bool = false;

fn buildPieces() bool {
    if (!buildBpe()) return false;
    if (g_pieces_ready and g_pieces_gen == embed.model_generation) return true;
    g_piece_buf.clearRetainingCapacity();
    g_piece_off.clearRetainingCapacity();
    var one: std.ArrayList(u8) = .{};
    defer one.clearAndFree(gpa);
    for (0..g_n_vocab) |i| {
        g_piece_off.append(gpa, @intCast(g_piece_buf.items.len)) catch return false;
        one.clearRetainingCapacity();
        const ids = [1]i32{@intCast(i)};
        decodeInto(ids[0..], &one);
        g_piece_buf.appendSlice(gpa, one.items) catch return false;
    }
    g_piece_off.append(gpa, @intCast(g_piece_buf.items.len)) catch return false;
    g_pieces_gen = embed.model_generation;
    g_pieces_ready = true;
    return true;
}

fn tokenPiece(id: usize) []const u8 {
    if (!g_pieces_ready or id + 1 >= g_piece_off.items.len) return "";
    const a = g_piece_off.items[id];
    const b = g_piece_off.items[id + 1];
    return g_piece_buf.items[a..b];
}

fn sampleIdConstrained(temp: f32, top_p: f32, top_k: c_int) i32 {
    const n = @min(g_logits.items.len, g_n_vocab);
    if (n == 0) return -1;

    var mask: [32]u8 = undefined;
    gm.firstByteMask(&mask);
    const can_end = gm.stz_grammar_can_end() != 0;

    const cands = gpa.alloc(Cand, n + 8) catch return -1;
    defer gpa.free(cands);
    var kept: usize = 0;
    var seen: usize = 0;

    for (0..n) |i| {
        const pc = tokenPiece(i);
        if (pc.len == 0) continue; // a control token: never text, judged below
        seen += 1;
        const b = pc[0];
        if ((mask[b >> 3] & (@as(u8, 1) << @intCast(b & 7))) == 0) continue;
        if (!gm.canAcceptBytes(pc)) continue;
        cands[kept] = .{ .id = @intCast(i), .v = g_logits.items[i] };
        kept += 1;
    }
    g_gram_seen += seen;
    g_gram_masked += seen - kept;

    // End-of-generation is legal exactly when the grammar is SATISFIED. That
    // is the whole stopping rule: the model may not stop mid-structure, and
    // it may not continue past a completed one without the grammar allowing it.
    if (can_end) {
        for (g_eog.items) |e| {
            const ei: usize = @intCast(e);
            if (e < 0 or ei >= g_logits.items.len) continue;
            if (kept >= cands.len) break;
            cands[kept] = .{ .id = e, .v = g_logits.items[ei] + g_end_bias };
            kept += 1;
        }
    }

    if (kept == 0) {
        // Not a silent truncation: the grammar admitted nothing here, and
        // neural_gen_grammar_stalled() says so to whoever asks.
        g_gram_stalled = true;
        return -1;
    }
    return sampleFrom(cands[0..kept], temp, top_p, top_k);
}

// Install a grammar. 0 = installed; anything else is gbnf_machine's refusal
// code, with the sentence in stz_grammar_last_refusal().
pub export fn neural_gen_set_grammar(text: [*c]const u8, len: usize) callconv(.c) c_int {
    if (text == null or len == 0) {
        neural_gen_clear_grammar();
        return 0;
    }
    const rc = gm.stz_grammar_set(text, len);
    if (rc != 0) {
        g_gram_on = false;
        return rc;
    }
    if (!buildPieces()) {
        g_gram_on = false;
        gm.stz_grammar_clear();
        return -100; // no tokenizer to mask over: no model, or no vocabulary
    }
    g_gram_on = true;
    g_gram_masked = 0;
    g_gram_seen = 0;
    g_gram_steps = 0;
    g_gram_stalled = false;
    return 0;
}

pub export fn neural_gen_clear_grammar() callconv(.c) void {
    g_gram_on = false;
    gm.stz_grammar_clear();
}

pub export fn neural_gen_grammar_active() callconv(.c) c_int {
    return if (g_gram_on) 1 else 0;
}

// Candidates the grammar refused during the last generation, and how many
// it judged. The ratio is the honest picture of what masking did.
pub export fn neural_gen_grammar_masked() callconv(.c) c_int {
    return @intCast(@min(g_gram_masked, @as(usize, 2000000000)));
}

pub export fn neural_gen_grammar_judged() callconv(.c) c_int {
    return @intCast(@min(g_gram_seen, @as(usize, 2000000000)));
}

pub export fn neural_gen_grammar_steps() callconv(.c) c_int {
    return @intCast(g_gram_steps);
}

// TRUE when some step had NO legal token at all. The generation stopped
// there; it did not quietly produce something else.
pub export fn neural_gen_grammar_stalled() callconv(.c) c_int {
    return if (g_gram_stalled) 1 else 0;
}

// TRUE when the grammar is SATISFIED where generation stopped -- the
// difference between a whole answer and one cut off by the token budget.
pub export fn neural_gen_grammar_complete() callconv(.c) c_int {
    if (!g_gram_on) return 0;
    return gm.stz_grammar_can_end();
}

pub export fn neural_gen_grammar_refusal(out: [*c]u8) callconv(.c) c_int {
    return gm.stz_grammar_last_refusal(@ptrCast(out));
}

// ---- generation: STREAM session -------------------------------------------------
// neural_gen_start prefills; each neural_gen_next produces ONE token (its
// decoded text readable via neural_gen_chunk) -- 1 = a token was produced,
// 0 = finished (EOG or max reached). The blocking neural_generate_xt is the
// same session run to completion.
var g_stream_active: bool = false;
var g_stream_max: usize = 0;
var g_stream_n: usize = 0;
var g_stream_temp: f32 = 0;
var g_stream_topp: f32 = 1.0;
var g_stream_topk: c_int = 0;
var g_chunk: std.ArrayList(u8) = .{};

// ---- the prompt window ------------------------------------------------------------
//
// A fresh prompt used to be cut to its LAST 512 tokens, silently: a system
// message at the head survived at 506 tokens and was gone at 514, and the only
// symptom was a wrong answer (found by the Ring++ session's local K4,
// 2026-10-20, ringpp haro/spike/v22/k4/ENGINE_NOTES.md). Now:
//   - a prompt is prefilled in chunks of at most `prefill_chunk` tokens through
//     the same append path a chat turn uses, so no part of it is dropped, and
//     because the pool is quadratic in the chunk (kv_len * n_new), chunking is
//     also what keeps a larger model inside memory;
//   - the window is the model's trained context (`.context_length`), or a
//     lower limit the caller set. A prompt that does not fit is REFUSED with a
//     code the Ring side reads (neural_gen_last_error), never trimmed;
//   - a generation that runs into the end of the window stops and says so
//     (neural_gen_truncated).
const prefill_chunk: usize = 256;

// ---- termination aids ----------------------------------------------------------------
//
// THE DECODER GUARANTEES A VALID SHAPE, NOT AN END. A grammar that may always
// take one more statement is satisfied by one more statement, so a small model
// that has run out of things to say can loop inside the grammar until the token
// cap (Qwen2.5-Coder-1.5B left 8 of its 20 Ring++ programs without their end
// marker, repeating one line up to 48 times -- ENGINE_NOTES.md, 2026-10-20). The
// remedies belong to the sampler, not the grammar. Three, each OFF by default and
// each deterministic (no random draw is added; a seed still reproduces a run):
//
//   repeat penalty   a token this generation has already produced, within the last
//                    `rep_last_n` tokens, has its logit divided by the penalty
//                    (multiplied, when negative) -- llama.cpp's rule. It sees only
//                    what THIS generation wrote, never the prompt: the prompt's own
//                    tokens are not the loop being broken.
//   stop on repeat   the generation ends once the same non-blank line has been
//                    written N times running. The repeated lines stay in the text;
//                    neural_gen_stopped_on_repeat() says it happened.
//   end bias         while the grammar is SATISFIED, the end-of-generation logits
//                    are raised by this much, so a model that is done is let off.
//
// WHAT EACH ONE HURTS is the Ring side's to publish, with the measurement: a
// penalty also taxes legitimate repeats (indentation, `end`, `)`), stop-on-repeat
// cuts a program that really does repeat a line N times, and an end bias can end a
// program the moment the grammar is first satisfied.
var g_rep_penalty: f32 = 1.0;
var g_rep_last_n: usize = 64;
var g_stop_repeat: usize = 0;
var g_end_bias: f32 = 0;
var g_stopped_on_repeat: bool = false;
var g_hist: std.ArrayList(i32) = .{}; // tokens THIS generation has produced
var g_seen: std.ArrayList(u8) = .{}; // scratch: one flag per vocabulary id
var g_line_cur: std.ArrayList(u8) = .{};
var g_line_prev: std.ArrayList(u8) = .{};
var g_line_run: usize = 0;

// Install the aids for the generations that follow. rep_penalty <= 1 and
// stop_repeat <= 0 and end_bias == 0 mean "off" for that aid.
pub export fn neural_gen_set_termination(rep_penalty: f64, rep_last_n: c_int, stop_repeat: c_int, end_bias: f64) callconv(.c) void {
    g_rep_penalty = if (rep_penalty > 1.0) @floatCast(rep_penalty) else 1.0;
    g_rep_last_n = if (rep_last_n > 0) @intCast(rep_last_n) else 64;
    g_stop_repeat = if (stop_repeat > 0) @intCast(stop_repeat) else 0;
    g_end_bias = @floatCast(end_bias);
}

pub export fn neural_gen_clear_termination() callconv(.c) void {
    neural_gen_set_termination(1.0, 64, 0, 0.0);
}

// 1 when the last generation was ended by the stop-on-repeat rule.
pub export fn neural_gen_stopped_on_repeat() callconv(.c) c_int {
    return if (g_stopped_on_repeat) 1 else 0;
}

fn resetTermination() void {
    g_hist.clearRetainingCapacity();
    g_line_cur.clearRetainingCapacity();
    g_line_prev.clearRetainingCapacity();
    g_line_run = 0;
    g_stopped_on_repeat = false;
}

fn applyRepeatPenalty() void {
    const n_vocab = g_logits.items.len;
    if (n_vocab == 0 or g_hist.items.len == 0) return;
    if (g_seen.items.len != n_vocab) {
        g_seen.resize(gpa, n_vocab) catch return;
        @memset(g_seen.items, 0);
    }
    const from = if (g_hist.items.len > g_rep_last_n) g_hist.items.len - g_rep_last_n else 0;
    const win = g_hist.items[from..];
    for (win) |t| {
        if (t < 0) continue;
        const i: usize = @intCast(t);
        if (i >= n_vocab or g_seen.items[i] != 0) continue;
        g_seen.items[i] = 1;
        const v = g_logits.items[i];
        g_logits.items[i] = if (v > 0) v / g_rep_penalty else v * g_rep_penalty;
    }
    for (win) |t| {
        if (t < 0) continue;
        const i: usize = @intCast(t);
        if (i < n_vocab) g_seen.items[i] = 0;
    }
}

fn trimmedLine(line: []const u8) []const u8 {
    return std.mem.trim(u8, line, " \t\r");
}

// Feed the text of one emitted token to the repeated-line detector.
fn trackLines(piece: []const u8) void {
    for (piece) |b| {
        if (b != '\n') {
            g_line_cur.append(gpa, b) catch return;
            continue;
        }
        const cur = trimmedLine(g_line_cur.items);
        if (cur.len > 0) {
            if (std.mem.eql(u8, cur, trimmedLine(g_line_prev.items))) {
                g_line_run += 1;
            } else {
                g_line_prev.clearRetainingCapacity();
                g_line_prev.appendSlice(gpa, cur) catch return;
                g_line_run = 1;
            }
            if (g_stop_repeat > 0 and g_line_run >= g_stop_repeat) g_stopped_on_repeat = true;
        }
        g_line_cur.clearRetainingCapacity();
    }
}

const GEN_OK: c_int = 0;
const GEN_NO_GENERATOR: c_int = 1;
const GEN_PROMPT_TOO_LONG: c_int = 2;
const GEN_FORWARD_FAILED: c_int = 3;

var g_last_error: c_int = GEN_OK;
var g_truncated: bool = false;
var g_ctx_limit: usize = 0; // 0 = the model's own trained context
var g_last_prompt_tokens: usize = 0;

fn contextWindow() usize {
    const train: usize = @intCast(@max(kvArchInt(".context_length", 2048), 1));
    if (g_ctx_limit != 0 and g_ctx_limit < train) return g_ctx_limit;
    return train;
}

// Tokens the loaded model can hold at once (its trained context, or the limit
// set below).
pub export fn neural_gen_context_window() callconv(.c) c_int {
    if (neural_model_has_generator() == 0) return 0;
    return @intCast(@min(contextWindow(), @as(usize, 2000000000)));
}

// Lower the window below the trained context (a caller bounding memory); 0
// restores the trained context. Returns the window now in force.
pub export fn neural_gen_set_context_limit(n: c_int) callconv(.c) c_int {
    g_ctx_limit = if (n > 0) @intCast(n) else 0;
    return neural_gen_context_window();
}

// Why the last start did not begin: 0 none, 1 no generator is loaded, 2 the
// prompt does not fit the window, 3 a forward pass failed (out of memory).
pub export fn neural_gen_last_error() callconv(.c) c_int {
    return g_last_error;
}

// 1 when the LAST generation stopped because the window filled, not because
// the model finished or the caller's token budget ran out.
pub export fn neural_gen_truncated() callconv(.c) c_int {
    return if (g_truncated) 1 else 0;
}

// Tokens in the last prompt handed to a start (BOS included on a fresh one).
pub export fn neural_gen_last_prompt_tokens() callconv(.c) c_int {
    return @intCast(@min(g_last_prompt_tokens, @as(usize, 2000000000)));
}

pub export fn neural_gen_start(text: [*c]const u8, len: usize, max_new: c_int, temp: f64, top_p: f64, top_k: c_int, seed: c_int) callconv(.c) c_int {
    return neural_gen_start_x(text, len, max_new, temp, top_p, top_k, seed, 1);
}

// reset=1 -> fresh prefill (single-shot / first chat turn); reset=0 ->
// APPEND to the existing KV cache (a follow-up chat turn), so history is
// processed ONCE across a conversation, not re-fed each turn.
pub export fn neural_gen_start_x(text: [*c]const u8, len: usize, max_new: c_int, temp: f64, top_p: f64, top_k: c_int, seed: c_int, reset: c_int) callconv(.c) c_int {
    g_stream_active = false;
    g_last_error = GEN_OK;
    g_truncated = false;
    g_last_prompt_tokens = 0;
    resetTermination();
    if (neural_model_has_generator() == 0 or !buildBpe()) {
        g_last_error = GEN_NO_GENERATOR;
        return 0;
    }
    if (text == null or len == 0) return 0;
    if (reset != 0) resetKv();
    var ids: std.ArrayList(i32) = .{};
    defer ids.clearAndFree(gpa);
    encode(text[0..len], &ids);
    if (ids.items.len == 0) return 0;
    var prompt = ids.items;
    // a follow-up turn drops the leading BOS the encoder prepends (history
    // already opened the sequence)
    if (reset == 0 and g_add_bos and prompt.len > 0 and prompt[0] == g_bos)
        prompt = prompt[1..];
    g_last_prompt_tokens = prompt.len;
    // the prompt, plus what is already cached, plus room for at least one new
    // token, must fit the window; otherwise REFUSE (never trim)
    if (g_n_past + prompt.len >= contextWindow()) {
        g_last_error = GEN_PROMPT_TOO_LONG;
        return 0;
    }
    var off: usize = 0;
    while (off < prompt.len) {
        const end = @min(off + prefill_chunk, prompt.len);
        if (!forwardDecode(prompt[off..end])) {
            g_last_error = GEN_FORWARD_FAILED;
            return 0;
        }
        off = end;
    }
    g_stream_max = if (max_new > 0) @intCast(max_new) else 64;
    g_stream_n = 0;
    g_stream_temp = @floatCast(temp);
    g_stream_topp = @floatCast(top_p);
    g_stream_topk = top_k;
    // The seed space is 32-bit BECAUSE THE EXPORTED ABI SAYS c_int, end to
    // end (neural_gen_start and friends are public C symbols; widening the
    // parameter is an ABI break, not an edge fix). 2^32 distinct sampling
    // streams is ample for generation reproducibility, and DefaultPrng's
    // splitmix expansion gives a 32-bit seed a full-quality state. The
    // audit note calling this a truncation defect was a misdiagnosis.
    g_prng = std.Random.DefaultPrng.init(@as(u32, @bitCast(seed)));
    // A grammar constrains THIS generation from its first token: the
    // machine goes back to the start of the grammar, and the counters that
    // report what masking did go back to zero with it.
    if (g_gram_on) {
        _ = gm.stz_grammar_reset();
        g_gram_masked = 0;
        g_gram_seen = 0;
        g_gram_steps = 0;
        g_gram_stalled = false;
    }
    g_stream_active = true;
    return 1;
}

// ---- reading the model's probabilities for chosen tokens (the DECISION primitive) ------------------------
//
// A classifier does not need to GENERATE: after the prompt, the model has a distribution over its next token,
// and the first tokens of the candidate answers are enough to tell "bug" from "billing" from "other". This reads
// that distribution once -- no sampling, no parsing, no grammar -- and returns true probabilities (softmax over the
// whole vocabulary), so a caller also learns how much of the mass the candidates hold at all.
//   neural_gen_prefill_logits  prefill the prompt (a fresh sequence) and keep the last token's logits
//   neural_gen_logit_at        the logit of one token id (-1e30 when out of range)
//   neural_gen_logit_lse       log-sum-exp of all logits, the softmax normaliser
pub export fn neural_gen_prefill_logits(text: [*c]const u8, len: usize) callconv(.c) c_int {
    const ok = neural_gen_start_x(text, len, 1, 0, 1.0, 0, 0, 1);
    g_stream_active = false;
    return ok;
}

pub export fn neural_gen_logit_at(id: c_int) callconv(.c) f64 {
    if (id < 0) return -1.0e30;
    const i: usize = @intCast(id);
    if (i >= g_logits.items.len) return -1.0e30;
    return g_logits.items[i];
}

pub export fn neural_gen_logit_lse() callconv(.c) f64 {
    if (g_logits.items.len == 0) return 0;
    var mx: f32 = -3.4e38;
    for (g_logits.items) |v| {
        if (v > mx) mx = v;
    }
    var sum: f64 = 0;
    for (g_logits.items) |v| sum += @exp(@as(f64, v - mx));
    return @as(f64, mx) + @log(sum);
}

pub export fn neural_gen_next() callconv(.c) c_int {
    if (!g_stream_active) return 0;
    if (g_stream_n >= g_stream_max) {
        g_stream_active = false;
        return 0;
    }
    if (g_n_past >= contextWindow()) {
        g_truncated = true;
        g_stream_active = false;
        return 0;
    }
    if (g_rep_penalty > 1.0) applyRepeatPenalty();
    const id = if (g_gram_on)
        sampleIdConstrained(g_stream_temp, g_stream_topp, g_stream_topk)
    else
        sampleId(g_stream_temp, g_stream_topp, g_stream_topk);
    if (id < 0 or isEog(id)) {
        g_stream_active = false;
        return 0;
    }
    // The machine really moves here. It cannot refuse: the candidate was
    // drawn from the set the same machine judged one moment ago.
    if (g_gram_on) {
        _ = gm.acceptBytes(tokenPiece(@intCast(id)));
        g_gram_steps += 1;
    }
    g_chunk.clearRetainingCapacity();
    var one = [1]i32{id};
    decodeInto(one[0..], &g_chunk);
    g_chunk.append(gpa, 0) catch {
        g_stream_active = false;
        return 0;
    };
    g_stream_n += 1;
    if (g_rep_penalty > 1.0) g_hist.append(gpa, id) catch {};
    if (g_stop_repeat > 0 and g_chunk.items.len > 1) trackLines(g_chunk.items[0 .. g_chunk.items.len - 1]);
    if (g_stopped_on_repeat) {
        // the token is already drawn and is returned; the cache still takes it so a
        // following chat turn continues from a consistent state
        _ = forwardDecode(one[0..]);
        g_stream_active = false;
        return 1;
    }
    if (!forwardDecode(one[0..])) {
        g_stream_active = false;
        g_last_error = GEN_FORWARD_FAILED;
        return 1; // the produced chunk is still valid
    }
    return 1;
}

pub export fn neural_gen_chunk() callconv(.c) [*c]const u8 {
    if (g_chunk.items.len == 0) return @ptrCast("");
    return @ptrCast(g_chunk.items.ptr);
}

pub export fn neural_gen_active() callconv(.c) c_int {
    return if (g_stream_active) 1 else 0;
}

// tokens currently in the KV cache (the conversation length so far).
pub export fn neural_gen_cached() callconv(.c) c_int {
    return @intCast(g_n_past);
}

// Continue generation from the CURRENT cache (no reset): the multi-turn
// primitive. Returns the byte length of the new text, -1 on failure.
pub export fn neural_generate_cont(text: [*c]const u8, len: usize, max_new: c_int, temp: f64, top_p: f64, top_k: c_int, seed: c_int) callconv(.c) c_int {
    if (neural_gen_start_x(text, len, max_new, temp, top_p, top_k, seed, 0) == 0) return -1;
    g_gen_text.clearRetainingCapacity();
    while (neural_gen_next() == 1) {
        if (g_chunk.items.len > 1)
            g_gen_text.appendSlice(gpa, g_chunk.items[0 .. g_chunk.items.len - 1]) catch break;
    }
    g_gen_text.append(gpa, 0) catch return -1;
    return @intCast(g_gen_text.items.len - 1);
}

// Blocking generation with sampling options; temperature 0 = greedy.
pub export fn neural_generate_xt(text: [*c]const u8, len: usize, max_new: c_int, temp: f64, top_p: f64, top_k: c_int, seed: c_int) callconv(.c) c_int {
    if (neural_gen_start(text, len, max_new, temp, top_p, top_k, seed) == 0) return -1;
    g_gen_text.clearRetainingCapacity();
    while (neural_gen_next() == 1) {
        if (g_chunk.items.len > 1)
            g_gen_text.appendSlice(gpa, g_chunk.items[0 .. g_chunk.items.len - 1]) catch break;
    }
    g_gen_text.append(gpa, 0) catch return -1;
    return @intCast(g_gen_text.items.len - 1);
}

// Greedy (deterministic) generation -- the temperature-0 case of _xt.
pub export fn neural_generate(text: [*c]const u8, len: usize, max_new: c_int) callconv(.c) c_int {
    return neural_generate_xt(text, len, max_new, 0, 1.0, 0, 0);
}

pub export fn neural_gen_text() callconv(.c) [*c]const u8 {
    if (g_gen_text.items.len == 0) return @ptrCast("");
    return @ptrCast(g_gen_text.items.ptr);
}

// tokenizer probe: BPE-encode into a shared buffer (count returned; ids via
// neural_gen_token_at) -- lets Ring verify the tokenizer independently.
var g_probe_ids: std.ArrayList(i32) = .{};
pub export fn neural_gen_tokenize(text: [*c]const u8, len: usize) callconv(.c) c_int {
    if (!buildBpe()) return 0;
    g_probe_ids.clearRetainingCapacity();
    if (text != null and len > 0) encode(text[0..len], &g_probe_ids);
    return @intCast(g_probe_ids.items.len);
}
pub export fn neural_gen_token_at(i: c_int) callconv(.c) c_int {
    const idx: usize = @intCast(i);
    if (idx >= g_probe_ids.items.len) return -1;
    return g_probe_ids.items[idx];
}
