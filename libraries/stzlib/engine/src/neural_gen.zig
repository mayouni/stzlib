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
        else => dflt,
    };
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
        std.mem.eql(u8, arch, "qwen3") or std.mem.eql(u8, arch, "smollm");
    if (!known) return 0;
    var nb: [64]u8 = undefined;
    if (getTOpt(mctx(), "blk.0.attn_norm.weight", .{}, &nb) == null) return 0;
    if (getTOpt(mctx(), "output_norm.weight", .{}, &nb) == null) return 0;
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
const Special = struct { s: []const u8, id: i32 };
var g_specials: std.ArrayList(Special) = .{};
var g_eog: std.ArrayList(i32) = .{}; // end-of-generation ids (eos, <|im_end|>, ...)

fn freeBpe() void {
    if (g_bpe_built) {
        g_tok_map.deinit();
        g_merge_map.deinit();
        g_specials.clearAndFree(gpa);
        g_eog.clearAndFree(gpa);
        g_bpe_built = false;
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
            if (ty[i] == 3 and s.len > 0) { // CONTROL
                g_specials.append(gpa, .{ .s = s, .id = @intCast(i) }) catch {};
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
        for (g_specials.items) |sp| {
            if (sp.s.len > 0 and i + sp.s.len <= text.len and
                std.mem.eql(u8, text[i .. i + sp.s.len], sp.s))
            {
                matched = sp;
                break;
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
            if (sp.id == id) {
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

// One decoder forward over `ids` (n_new tokens) with the current cache;
// leaves the last token's logits in g_logits and appends K/V to the cache.
fn forwardDecode(ids: []const i32) bool {
    const m = mctx() orelse return false;
    const n_new = ids.len;
    if (n_new == 0) return false;

    const n_embd: usize = @intCast(kvArchInt(".embedding_length", 0));
    const n_head: usize = @intCast(kvArchInt(".attention.head_count", 0));
    const n_kv: usize = @intCast(kvArchInt(".attention.head_count_kv", @intCast(n_head)));
    const n_layer: usize = @intCast(kvArchInt(".block_count", 0));
    if (n_embd == 0 or n_head == 0 or n_layer == 0 or n_kv == 0) return false;
    const hd = n_embd / n_head;
    const grp = n_head / n_kv;
    const eps = kvArchF32(".attention.layer_norm_rms_epsilon", 1e-5);
    const rope_base = kvArchF32(".rope.freq_base", 10000.0);
    const n_ctx_train: i32 = @intCast(kvArchInt(".context_length", 2048));
    const arch = archName();
    // llama-family GGUFs are converted with PERMUTED Q/K weights so NORMAL
    // (interleaved) rope applies; qwen2/qwen3 use the NeoX layout.
    const rope_type: c_int = if (std.mem.eql(u8, arch, "qwen2") or std.mem.eql(u8, arch, "qwen3"))
        c.GGML_ROPE_TYPE_NEOX
    else
        c.GGML_ROPE_TYPE_NORMAL;

    // grow the per-layer cache lists on first use
    if (g_kc.items.len != n_layer) {
        resetKv();
        for (0..n_layer) |_| {
            g_kc.append(gpa, .{}) catch return false;
            g_vc.append(gpa, .{}) catch return false;
        }
    }
    const n_past = g_n_past;
    const kv_len = n_past + n_new;

    const mem_size: usize = 128 * 1024 * 1024 + kv_len * n_new * n_head * n_layer * 24 + n_new * n_embd * n_layer * 64;
    const ctx = c.ggml_init(.{ .mem_size = mem_size, .mem_buffer = null, .no_alloc = false }) orelse return false;
    defer c.ggml_free(ctx);

    var nb: [96]u8 = undefined;
    var nb2: [96]u8 = undefined;

    const tokens = c.ggml_new_tensor_1d(ctx, c.GGML_TYPE_I32, @intCast(n_new)).?;
    const positions = c.ggml_new_tensor_1d(ctx, c.GGML_TYPE_I32, @intCast(n_new)).?;
    const td: [*]i32 = @ptrCast(@alignCast(tokens.*.data));
    const pd: [*]i32 = @ptrCast(@alignCast(positions.*.data));
    for (0..n_new) |i| {
        td[i] = ids[i];
        pd[i] = @intCast(n_past + i);
    }

    // causal mask [kv_len, n_new*grp]: query x (token t = x % n_new, global
    // position n_past+t) may attend keys 0..n_past+t
    const mask = c.ggml_new_tensor_2d(ctx, c.GGML_TYPE_F32, @intCast(kv_len), @intCast(n_new * grp)).?;
    const mkd: [*]f32 = @ptrCast(@alignCast(mask.*.data));
    for (0..n_new * grp) |x| {
        const t = x % n_new;
        for (0..kv_len) |k| {
            mkd[x * kv_len + k] = if (k <= n_past + t) 0.0 else -1.0e9;
        }
    }

    var cur = c.ggml_get_rows(ctx, getT(m, "token_embd.weight", .{}, &nb), tokens).?;

    // keep per-layer Kcur/Vcur nodes to read back into the cache after compute
    var kouts: std.ArrayList(*c.ggml_tensor) = .{};
    defer kouts.clearAndFree(gpa);
    var vouts: std.ArrayList(*c.ggml_tensor) = .{};
    defer vouts.clearAndFree(gpa);

    const scale: f32 = 1.0 / @sqrt(@as(f32, @floatFromInt(hd)));

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
        Q3 = c.ggml_rope_ext(ctx, Q3, positions, null, @intCast(hd), rope_type, n_ctx_train, rope_base, 1.0, 0.0, 1.0, 0.0, 0.0).?;
        var K3 = c.ggml_reshape_3d(ctx, K, @intCast(hd), @intCast(n_kv), @intCast(n_new)).?;
        K3 = c.ggml_rope_ext(ctx, K3, positions, null, @intCast(hd), rope_type, n_ctx_train, rope_base, 1.0, 0.0, 1.0, 0.0, 0.0).?;

        // Kcur/Vcur in cache-readout layout [hd, n_new, heads_kv]
        const Kcur = c.ggml_cont(ctx, c.ggml_permute(ctx, K3, 0, 2, 1, 3)).?;
        const V3 = c.ggml_reshape_3d(ctx, V, @intCast(hd), @intCast(n_kv), @intCast(n_new)).?;
        const Vcur = c.ggml_cont(ctx, c.ggml_permute(ctx, V3, 0, 2, 1, 3)).?;
        kouts.append(gpa, Kcur) catch return false;
        vouts.append(gpa, Vcur) catch return false;

        // K_all/V_all = cached part (input tensors) ++ current
        var K_all = Kcur;
        var V_all = Vcur;
        if (n_past > 0) {
            const kpast = c.ggml_new_tensor_3d(ctx, c.GGML_TYPE_F32, @intCast(hd), @intCast(n_past), @intCast(n_kv)).?;
            const vpast = c.ggml_new_tensor_3d(ctx, c.GGML_TYPE_F32, @intCast(hd), @intCast(n_past), @intCast(n_kv)).?;
            const kpd: [*]f32 = @ptrCast(@alignCast(kpast.*.data));
            const vpd: [*]f32 = @ptrCast(@alignCast(vpast.*.data));
            const kc = g_kc.items[L].items;
            const vc = g_vc.items[L].items;
            for (0..n_kv) |g| {
                for (0..n_past) |p| {
                    for (0..hd) |d| {
                        kpd[d + hd * (p + n_past * g)] = kc[p * (n_kv * hd) + g * hd + d];
                        vpd[d + hd * (p + n_past * g)] = vc[p * (n_kv * hd) + g * hd + d];
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
        KQV = c.ggml_reshape_2d(ctx, KQV, @intCast(n_embd), @intCast(n_new)).?;

        var attn = c.ggml_mul_mat(ctx, getT(m, "blk.{d}.attn_output.weight", .{L}, &nb), KQV).?;
        if (getTOpt(m, "blk.{d}.attn_output.bias", .{L}, &nb2)) |bo| attn = c.ggml_add(ctx, attn, bo).?;
        cur = c.ggml_add(ctx, attn, inpL).?;

        // SwiGLU FFN
        var h2 = c.ggml_rms_norm(ctx, cur, eps).?;
        h2 = c.ggml_mul(ctx, h2, getT(m, "blk.{d}.ffn_norm.weight", .{L}, &nb)).?;
        const gate = c.ggml_mul_mat(ctx, getT(m, "blk.{d}.ffn_gate.weight", .{L}, &nb), h2).?;
        const up = c.ggml_mul_mat(ctx, getT(m, "blk.{d}.ffn_up.weight", .{L}, &nb2), h2).?;
        var ff = c.ggml_mul(ctx, c.ggml_silu(ctx, gate), up).?;
        ff = c.ggml_mul_mat(ctx, getT(m, "blk.{d}.ffn_down.weight", .{L}, &nb), ff).?;
        cur = c.ggml_add(ctx, cur, ff).?;
    }

    var xF = c.ggml_rms_norm(ctx, cur, eps).?;
    xF = c.ggml_mul(ctx, xF, getT(m, "output_norm.weight", .{}, &nb)).?;
    // lm_head on the LAST token only (untied output.weight, else tied embeddings)
    const last = c.ggml_view_2d(ctx, xF, @intCast(n_embd), 1, xF.*.nb[1], @intCast((n_new - 1) * xF.*.nb[1])).?;
    const lastc = c.ggml_cont(ctx, last).?;
    const lm_w = getTOpt(m, "output.weight", .{}, &nb) orelse getT(m, "token_embd.weight", .{}, &nb);
    const logits = c.ggml_mul_mat(ctx, lm_w, lastc).?;

    const graph = c.ggml_new_graph_custom(ctx, 8192, false) orelse return false;
    c.ggml_build_forward_expand(graph, logits);
    for (kouts.items) |t| c.ggml_build_forward_expand(graph, t);
    for (vouts.items) |t| c.ggml_build_forward_expand(graph, t);

    var plan = c.ggml_graph_plan(graph, 4, null);
    var wbuf: ?[]u8 = null;
    if (plan.work_size > 0) {
        wbuf = gpa.alloc(u8, plan.work_size) catch return false;
        plan.work_data = wbuf.?.ptr;
    }
    defer if (wbuf) |w| gpa.free(w);
    _ = c.ggml_graph_compute(graph, &plan);

    // append the new K/V ([hd, n_new, n_kv], element (d,t,g)) to the caches
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

pub export fn neural_gen_start(text: [*c]const u8, len: usize, max_new: c_int, temp: f64, top_p: f64, top_k: c_int, seed: c_int) callconv(.c) c_int {
    g_stream_active = false;
    if (neural_model_has_generator() == 0) return 0;
    if (!buildBpe()) return 0;
    if (text == null or len == 0) return 0;
    resetKv();
    var ids: std.ArrayList(i32) = .{};
    defer ids.clearAndFree(gpa);
    encode(text[0..len], &ids);
    if (ids.items.len == 0) return 0;
    const cap: usize = 512;
    var prompt = ids.items;
    if (prompt.len > cap) prompt = prompt[prompt.len - cap ..];
    if (!forwardDecode(prompt)) return 0;
    g_stream_max = if (max_new > 0) @intCast(max_new) else 64;
    g_stream_n = 0;
    g_stream_temp = @floatCast(temp);
    g_stream_topp = @floatCast(top_p);
    g_stream_topk = top_k;
    g_prng = std.Random.DefaultPrng.init(@intCast(@as(u32, @bitCast(seed))));
    g_stream_active = true;
    return 1;
}

pub export fn neural_gen_next() callconv(.c) c_int {
    if (!g_stream_active) return 0;
    if (g_stream_n >= g_stream_max) {
        g_stream_active = false;
        return 0;
    }
    const id = sampleId(g_stream_temp, g_stream_topp, g_stream_topk);
    if (id < 0 or isEog(id)) {
        g_stream_active = false;
        return 0;
    }
    g_chunk.clearRetainingCapacity();
    var one = [1]i32{id};
    decodeInto(one[0..], &g_chunk);
    g_chunk.append(gpa, 0) catch {
        g_stream_active = false;
        return 0;
    };
    g_stream_n += 1;
    if (!forwardDecode(one[0..])) {
        g_stream_active = false;
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
