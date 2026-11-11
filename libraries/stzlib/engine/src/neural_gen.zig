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
const gr = @import("gguf_read.zig"); // SECURITY-MODELDATA-01b: every metadata read checks its type first
const gm = @import("gbnf_machine.zig");
const clip = @import("clip_text.zig"); // its Unicode classes (utf8proc), for the LLAMA3 pre-tokenizer
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
    var v: i128 = 0;
    if (c.gguf_get_kv_type(ctx, id) == c.GGUF_TYPE_ARRAY) {
        v = uniformArrayValue(ctx, id) orelse return dflt;
    } else {
        v = gr.intAt(ctx, id) orelse return dflt;
    }
    // every key read here is a size or a count: never negative, and it must fit the casts its callers make
    if (v < 0 or v > std.math.maxInt(i32)) return dflt;
    return @intCast(v);
}

// Some models (granite) store a per-layer value, e.g. head_count_kv, as an ARRAY with one entry per layer.
// When every entry is the same it IS that value; when they differ (a hybrid or otherwise irregular stack)
// there is no single value and null is returned - callers that cannot run such a model refuse it.
fn uniformArrayValue(ctx: *c.gguf_context, id: i64) ?i64 {
    if (gr.arrOf(u32, ctx, id)) |a| {
        if (a.len == 0) return null;
        for (a[1..]) |x| if (x != a[0]) return null;
        return @intCast(a[0]);
    }
    if (gr.arrOf(i32, ctx, id)) |a| {
        if (a.len == 0) return null;
        for (a[1..]) |x| if (x != a[0]) return null;
        return @intCast(a[0]);
    }
    return null;
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
    return gr.float(ctx, key, dflt);
}

fn kvI32(key: [*:0]const u8, dflt: i32) i32 {
    const ctx = gguf() orelse return dflt;
    return gr.intAs(i32, ctx, key, dflt);
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
    // LFM3 mixes convolution and attention layers: its own contract decides (l3Read)
    if (std.mem.eql(u8, arch, "lfm3")) return if (l3Ok(mctx())) 1 else 0;
    const known = std.mem.eql(u8, arch, "llama") or std.mem.eql(u8, arch, "qwen2") or
        std.mem.eql(u8, arch, "qwen3") or std.mem.eql(u8, arch, "smollm") or
        std.mem.eql(u8, arch, "granite") or std.mem.eql(u8, arch, "gemma4");
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
    const s = gr.arrStr(ctx, gr.find(ctx, "tokenizer.ggml.tokens"), i) orelse return "";
    return std.mem.span(s);
}

fn buildBpe() bool {
    // model reloaded since last build? invalidate everything generation-scoped
    if (g_bpe_built and g_bpe_gen == embed.model_generation) return true;
    freeBpe();
    resetKv();
    const ctx = gguf() orelse return false;
    buildByteMaps();
    const tid = gr.find(ctx, "tokenizer.ggml.tokens");
    const n: usize = gr.arrN(ctx, tid, gr.T_STR) orelse return false;
    if (n == 0 or n > std.math.maxInt(i32)) return false;
    g_n_vocab = n;
    g_tok_map = std.StringHashMap(i32).init(gpa);
    g_merge_map = std.StringHashMap(i32).init(gpa);

    // token types (3 = CONTROL) for special-token literal matching
    var types: ?[*]const i32 = null;
    // a token-type array shorter than the vocabulary was read past its end: it is used only when it covers it
    if (gr.arrOf(i32, ctx, gr.find(ctx, "tokenizer.ggml.token_type"))) |ty| {
        if (ty.len >= n) types = ty.ptr;
    }

    for (0..n) |i| {
        const s = std.mem.span(gr.arrStr(ctx, tid, i).?); // i < n, checked above; stable while loaded
        g_tok_map.put(s, @intCast(i)) catch {};
        if (types) |ty| {
            if ((ty[i] == 3 or ty[i] == 4) and s.len > 0) { // CONTROL, or USER-DEFINED (added tokens: <think>, <tool_call>...)
                g_specials.append(gpa, .{ .s = s, .id = @intCast(i), .hidden = (ty[i] == 3) }) catch {};
            }
        }
    }

    const mid = gr.find(ctx, "tokenizer.ggml.merges");
    if (gr.arrN(ctx, mid, gr.T_STR)) |nm| {
        for (0..nm) |i| {
            const s = std.mem.span(gr.arrStr(ctx, mid, i).?);
            g_merge_map.put(s, @intCast(i)) catch {};
        }
    }

    g_spm = if (kvStr("tokenizer.ggml.model")) |tm| std.mem.eql(u8, std.mem.span(tm), "gemma4") else false;
    g_bos = kvI32("tokenizer.ggml.bos_token_id", -1);
    g_eos = kvI32("tokenizer.ggml.eos_token_id", -1);
    g_add_bos = kvBool("tokenizer.ggml.add_bos_token", false);
    // llama.cpp b12283 cuts an "lfm2" tokenizer's text by the LLAMA3 pattern; whether a BOS opens it is the file's
    // own add_bos_token (llama.cpp reads it after the pre-type's default, so the file's value stands)
    g_pre_llama3 = if (kvStr("tokenizer.ggml.pre")) |pre| std.mem.eql(u8, std.mem.span(pre), "lfm2") else false;
    if (g_eos >= 0) g_eog.append(gpa, g_eos) catch {};
    // ChatML end marker doubles as end-of-generation when present
    if (g_tok_map.get("<|im_end|>")) |id| {
        if (id != g_eos) g_eog.append(gpa, id) catch {};
    }
    if (g_tok_map.get("<|endoftext|>")) |id| {
        if (id != g_eos) g_eog.append(gpa, id) catch {};
    }
    // Gemma 4 ends a turn with <turn|> (llama.cpp counts it end-of-generation)
    if (g_tok_map.get("<turn|>")) |id| {
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
            if (i > seg_start) segment(text[seg_start..i], out);
            out.append(gpa, sp.id) catch {};
            i += sp.s.len;
            seg_start = i;
        } else {
            i += 1;
        }
    }
    if (text.len > seg_start) segment(text[seg_start..], out);
}

fn segment(text: []const u8, out: *std.ArrayList(i32)) void {
    if (g_spm) spmSegment(text, out) else if (g_pre_llama3) llama3Segment(text, out) else bpeSegment(text, out);
}

// Decode ids -> bytes (reverse byte-unicode mapping; control tokens skipped).
fn decodeInto(ids: []const i32, out: *std.ArrayList(u8)) void {
    for (ids) |id| {
        if (id < 0 or @as(usize, @intCast(id)) >= g_n_vocab) continue;
        var is_special = false;
        for (g_specials.items) |sp| {
            if (sp.id == id and sp.hidden and !(g_show_controls and id != g_eos)) {
                is_special = true;
                break;
            }
        }
        if (is_special) continue;
        const s = vocabToken(@intCast(id));
        if (g_spm) {
            spmDecodeInto(s, out);
            continue;
        }
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
// THE KV CACHE (IM8b). Until 2026-11-03 it was two lists of f32 per layer, position-major, copied on EVERY step into fresh tensors,
// concatenated with the new K and V (a second copy), V transposed again for the attention (a third), in a pool of up to 166 MB
// allocated and first-touched each step: the cost of a step GREW WITH THE CONTEXT (27 ms at 82 tokens, 55 ms at 1439, measured by
// phase). Now each layer owns two persistent tensors in the layout the attention reads: K as [hd, cap, n_kv] and V TRANSPOSED as
// [cap, hd, n_kv], `cap` the capacity in tokens, doubled when a prompt outgrows it. The graph writes the new K and V into them
// (ggml_cpy into a view) and attends over views of them: nothing is copied but the new tokens.
var g_kvctx: ?*c.ggml_context = null;
var g_kt: std.ArrayList(*c.ggml_tensor) = .{};
var g_vt: std.ArrayList(*c.ggml_tensor) = .{};
var g_cap: usize = 0;
var g_kv_shape: [2]usize = .{ 0, 0 }; // n_kv, hd of the allocated cache
var g_n_past: usize = 0;
var g_logits: std.ArrayList(f32) = .{};
var g_gen_text: std.ArrayList(u8) = .{};
// THREADS. One token's step reads every weight once and is bound by memory: 4 threads were measured enough. A pass over
// several tokens (a prompt chunk, speculative decoding's verification) does that arithmetic once per token and is bound
// by compute, so it may take more. The split changes which thread computes a row, never the order of any sum.
var g_threads_one: c_int = 4;
var g_threads_many: c_int = 4;
pub export fn neural_gen_set_threads(one: c_int, many: c_int) callconv(.c) void {
    g_threads_one = std.math.clamp(one, 1, 64);
    g_threads_many = std.math.clamp(many, 1, 64);
}
var g_kv_ids: std.ArrayList(i32) = .{}; // the token ids the cache holds, in order (-1: a picture's row); see prefixKeep
var g_prefix_reuse: bool = true;
var g_reused: usize = 0;
var g_rows_out: usize = 1; // rows of logits a forward computes: 1, or k+1 for speculative decoding's verification
var g_row_best: std.ArrayList(i32) = .{}; // the best token of each of those rows (filled only when there are several)

// THE ATTENTION'S WIDTH IS PADDED, so a token's numbers do not depend on how many tokens were read with it
// (RADAR-NVIDIA-SPECDEC-01, 2026-11-11). Attention sums over the keys -- the softmax's total and each value row's dot
// product -- and those sums are vectorised: an element's place in the accumulation depends on the row's LENGTH, through
// the vector tail. One token read alone sums over n_past+1 keys; the same token read in a batch of k+1 sums over
// n_past+k+1, the later keys masked. The sums differed in their last bits, and a near tie between two tokens then went
// the other way: speculative decoding, which reads k+1 tokens at once, wrote "which is why the sky appears blue" where
// the model alone writes "making the sky appear blue" (1 text of 6, measured). Every forward now attends over a width
// rounded up to kv_pad keys, the extra keys masked: every element sits in the same lane in either case, and a masked
// key adds exactly 0 (exp(-1e9) is 0 in f32, and the cache is zeroed when allocated, so 0 * a stale value is 0).
// 64 covers the widest unrolled step ggml's f32 kernels take (AVX-512: 16 lanes x 4) and tinyBLAS's k granularity.
const kv_pad: usize = 64;
fn padKv(n: usize) usize {
    return (n + kv_pad - 1) / kv_pad * kv_pad;
}

fn resetKv() void {
    if (g_kvctx) |k| c.ggml_free(k);
    g_kvctx = null;
    g_kt.clearAndFree(gpa);
    g_vt.clearAndFree(gpa);
    g_cap = 0;
    g_kv_shape = .{ 0, 0 };
    g_n_past = 0;
    g_kv_ids.clearRetainingCapacity();
    resetConv();
}

/// The cache holds `need` tokens of n_layer layers x n_kv heads x hd: allocated, or grown by doubling with the valid part copied
/// across (a growth is rare: a prompt outgrows a capacity that doubles). A different model shape starts a new cache.
fn ensureKv(n_layer: usize, n_kv: usize, hd: usize, need: usize) bool {
    if (g_kt.items.len == n_layer and g_kv_shape[0] == n_kv and g_kv_shape[1] == hd and g_cap >= need) return true;
    if (g_kt.items.len != 0 and (g_kt.items.len != n_layer or g_kv_shape[0] != n_kv or g_kv_shape[1] != hd)) resetKv();
    var cap: usize = if (g_cap == 0) 256 else g_cap;
    while (cap < need) cap *= 2;
    const per = hd * cap * n_kv * 4;
    const bytes = 2 * n_layer * (per + c.ggml_tensor_overhead() + 128) + 65536;
    const nctx = c.ggml_init(.{ .mem_size = bytes, .mem_buffer = null, .no_alloc = false }) orelse return false;
    // zeroed: the padded attention reads keys no token wrote yet, masked, and 0 * (whatever was there) must be 0
    @memset(@as([*]u8, @ptrCast(c.ggml_get_mem_buffer(nctx).?))[0..c.ggml_get_mem_size(nctx)], 0);
    var nk: std.ArrayList(*c.ggml_tensor) = .{};
    var nv: std.ArrayList(*c.ggml_tensor) = .{};
    var ok = true;
    for (0..n_layer) |_| {
        const kt = c.ggml_new_tensor_3d(nctx, c.GGML_TYPE_F32, @intCast(hd), @intCast(cap), @intCast(n_kv));
        const vt = c.ggml_new_tensor_3d(nctx, c.GGML_TYPE_F32, @intCast(cap), @intCast(hd), @intCast(n_kv));
        if (kt == null or vt == null) {
            ok = false;
            break;
        }
        nk.append(gpa, kt.?) catch {
            ok = false;
            break;
        };
        nv.append(gpa, vt.?) catch {
            ok = false;
            break;
        };
    }
    if (!ok) {
        nk.clearAndFree(gpa);
        nv.clearAndFree(gpa);
        c.ggml_free(nctx);
        return false;
    }
    if (g_kvctx != null and g_n_past > 0 and g_kt.items.len == n_layer) {
        const np = g_n_past;
        for (0..n_layer) |L| {
            const ok_: [*]const f32 = @ptrCast(@alignCast(g_kt.items[L].*.data));
            const nk_: [*]f32 = @ptrCast(@alignCast(nk.items[L].*.data));
            const ov: [*]const f32 = @ptrCast(@alignCast(g_vt.items[L].*.data));
            const nv_: [*]f32 = @ptrCast(@alignCast(nv.items[L].*.data));
            for (0..n_kv) |g| {
                @memcpy(nk_[hd * cap * g ..][0 .. hd * np], ok_[hd * g_cap * g ..][0 .. hd * np]);
                for (0..hd) |d| @memcpy(nv_[cap * (d + hd * g) ..][0..np], ov[g_cap * (d + hd * g) ..][0..np]);
            }
        }
    }
    if (g_kvctx) |old| c.ggml_free(old);
    g_kt.deinit(gpa);
    g_vt.deinit(gpa);
    g_kt = nk;
    g_vt = nv;
    g_kvctx = nctx;
    g_cap = cap;
    g_kv_shape = .{ n_kv, hd };
    return true;
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
// THE DECODER'S CONTRACT (SECURITY-MODELDATA-01b, 2026-11-08). The graph below takes every weight with `.?` and
// reshapes Q, K and V by the sizes the metadata states; a file whose sizes disagree with its own tensors -- a
// head_count_kv that is missing, or of the wrong type, falls back to n_head -- failed a GGML_ASSERT in a reshape and
// ended the process (12 SmolLM2 mutants of the fuzz). So before the first graph of a model, every tensor the graph
// reads is checked against the sizes: Q [n_embd, n_head*hd], K and V [n_embd, n_kv*hd], the output [n_head*hd,
// n_embd], the three FFN matrices on one n_ff, the norms and any bias f32 vectors of their width, n_head a multiple
// of n_kv. The answer is kept for the loaded model, and so are the rows of the token table, which every id fed to
// the graph must be one of.
var g_dc_gen: usize = std.math.maxInt(usize);
var g_dc_ok: bool = false;
var g_dc_rows: i64 = 0;

fn dMat(m: ?*c.ggml_context, comptime fmt: []const u8, args: anytype, ne0: i64, ne1: i64) bool {
    var b: [96]u8 = undefined;
    const t = getTOpt(m, fmt, args, &b) orelse return false;
    return t.*.ne[0] == ne0 and t.*.ne[1] == ne1 and t.*.ne[2] == 1 and t.*.ne[3] == 1;
}
// a vector of n f32s; `optional`: an absent one is fine (the graph reads it only when present)
fn dVec(m: ?*c.ggml_context, comptime fmt: []const u8, args: anytype, n: i64, optional: bool) bool {
    var b: [96]u8 = undefined;
    const t = getTOpt(m, fmt, args, &b) orelse return optional;
    return t.*.type == c.GGML_TYPE_F32 and t.*.ne[0] == n and t.*.ne[1] == 1 and t.*.ne[2] == 1 and t.*.ne[3] == 1;
}

fn decoderContract(m: ?*c.ggml_context, d: Dims) bool {
    if (d.n_kv > d.n_head or d.n_head % d.n_kv != 0 or d.hd == 0 or d.n_layer > 4096) return false;
    const E: i64 = @intCast(d.n_embd);
    const Q: i64 = @intCast(d.n_head * d.hd);
    const KV: i64 = @intCast(d.n_kv * d.hd);
    const HD: i64 = @intCast(d.hd);
    var nb: [96]u8 = undefined;
    const te = getTOpt(m, "token_embd.weight", .{}, &nb) orelse return false;
    if (te.*.ne[0] != E or te.*.ne[1] < 1 or te.*.ne[2] != 1 or te.*.ne[3] != 1) return false;
    g_dc_rows = te.*.ne[1];
    if (getTOpt(m, "output.weight", .{}, &nb)) |o| {
        if (o.*.ne[0] != E or o.*.ne[1] < 1 or o.*.ne[2] != 1 or o.*.ne[3] != 1) return false;
    }
    if (!dVec(m, "output_norm.weight", .{}, E, false)) return false;
    const g0 = getTOpt(m, "blk.0.ffn_gate.weight", .{}, &nb) orelse return false;
    const F: i64 = g0.*.ne[1];
    var l: usize = 0;
    while (l < d.n_layer) : (l += 1) {
        if (!dVec(m, "blk.{d}.attn_norm.weight", .{l}, E, false)) return false;
        if (!dMat(m, "blk.{d}.attn_q.weight", .{l}, E, Q) or !dVec(m, "blk.{d}.attn_q.bias", .{l}, Q, true)) return false;
        if (!dMat(m, "blk.{d}.attn_k.weight", .{l}, E, KV) or !dVec(m, "blk.{d}.attn_k.bias", .{l}, KV, true)) return false;
        if (!dMat(m, "blk.{d}.attn_v.weight", .{l}, E, KV) or !dVec(m, "blk.{d}.attn_v.bias", .{l}, KV, true)) return false;
        if (!dVec(m, "blk.{d}.attn_q_norm.weight", .{l}, HD, true) or !dVec(m, "blk.{d}.attn_k_norm.weight", .{l}, HD, true)) return false;
        if (!dMat(m, "blk.{d}.attn_output.weight", .{l}, Q, E) or !dVec(m, "blk.{d}.attn_output.bias", .{l}, E, true)) return false;
        if (!dVec(m, "blk.{d}.ffn_norm.weight", .{l}, E, false)) return false;
        if (!dMat(m, "blk.{d}.ffn_gate.weight", .{l}, E, F) or !dMat(m, "blk.{d}.ffn_up.weight", .{l}, E, F)) return false;
        if (!dMat(m, "blk.{d}.ffn_down.weight", .{l}, F, E)) return false;
    }
    return true;
}

fn decoderOk(m: ?*c.ggml_context, d: Dims) bool {
    if (g_dc_gen != embed.model_generation) {
        g_dc_ok = decoderContract(m, d);
        g_dc_gen = embed.model_generation;
    }
    return g_dc_ok;
}

fn buildDecodeGraph(
    ctx: *c.ggml_context,
    m: ?*c.ggml_context,
    ids: []const i32,
    embd: ?[]const f32,
    d: Dims,
    fill: bool,
    kouts: *std.ArrayList(*c.ggml_tensor),
    vouts: *std.ArrayList(*c.ggml_tensor),
) ?DecodeGraph {
    const n_new = ids.len;
    const n_past = d.n_past;
    const kv_len = padKv(n_past + n_new); // the attention's width; keys past n_past+n_new are masked (see kv_pad)
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

    // the input rows: each token's embedding, or rows the caller gives (a picture's, IM7) in their place
    var cur = if (embd) |e| blk: {
        const t = c.ggml_new_tensor_2d(ctx, c.GGML_TYPE_F32, @intCast(n_embd), @intCast(n_new)).?;
        if (fill) @memcpy(@as([*]f32, @ptrCast(@alignCast(t.*.data)))[0 .. n_embd * n_new], e[0 .. n_embd * n_new]);
        break :blk t;
    } else c.ggml_get_rows(ctx, getT(m, "token_embd.weight", .{}, &nb), tokens).?;
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

        // Kcur/Vcur [hd, n_new, heads_kv]: written into the persistent cache, in place, K as is and V transposed
        const Kcur = c.ggml_cont(ctx, c.ggml_permute(ctx, K3, 0, 2, 1, 3)).?;
        const V3 = c.ggml_reshape_3d(ctx, V, @intCast(hd), @intCast(n_kv), @intCast(n_new)).?;
        const Vcur = c.ggml_cont(ctx, c.ggml_permute(ctx, V3, 0, 2, 1, 3)).?;
        const kt = g_kt.items[L];
        const vt = g_vt.items[L];
        const kview = c.ggml_view_3d(ctx, kt, @intCast(hd), @intCast(n_new), @intCast(n_kv), kt.*.nb[1], kt.*.nb[2], n_past * kt.*.nb[1]).?;
        const vview = c.ggml_view_3d(ctx, vt, @intCast(n_new), @intCast(hd), @intCast(n_kv), vt.*.nb[1], vt.*.nb[2], n_past * vt.*.nb[0]).?;
        // the writes are listed in LAYER ORDER, K then V: the graph is built by expanding them first (see the end), so every
        // layer's attention, which reads the cache through the views below, comes after its own writes
        kouts.append(gpa, c.ggml_cpy(ctx, Kcur, kview).?) catch return null;
        kouts.append(gpa, c.ggml_cpy(ctx, c.ggml_permute(ctx, Vcur, 1, 0, 2, 3), vview).?) catch return null;
        const K_all = c.ggml_view_3d(ctx, kt, @intCast(hd), @intCast(kv_len), @intCast(n_kv), kt.*.nb[1], kt.*.nb[2], 0).?;
        const Vt = c.ggml_view_3d(ctx, vt, @intCast(kv_len), @intCast(hd), @intCast(n_kv), vt.*.nb[1], vt.*.nb[2], 0).?;

        // attention: group-query via the reshape trick (consecutive q-heads share
        // a kv head)
        const Qp = c.ggml_cont(ctx, c.ggml_permute(ctx, Q3, 0, 2, 1, 3)).?; // [hd, n_new, n_head]
        const Qv = c.ggml_reshape_3d(ctx, Qp, @intCast(hd), @intCast(n_new * grp), @intCast(n_kv)).?;
        var KQ = c.ggml_mul_mat(ctx, K_all, Qv).?; // [kv_len, n_new*grp, n_kv]
        KQ = c.ggml_soft_max_ext(ctx, KQ, mask, scale, 0.0).?;
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
    // lm_head on the LAST token only (untied output.weight, else tied embeddings) -- or on the last g_rows_out tokens,
    // when speculative decoding's verification pass needs the target's choice after each of them
    const n_out: usize = @max(1, @min(g_rows_out, n_new));
    const last = c.ggml_view_2d(ctx, xF, @intCast(n_embd), @intCast(n_out), xF.*.nb[1], @intCast((n_new - n_out) * xF.*.nb[1])).?;
    const lastc = c.ggml_cont(ctx, last).?;
    const lm_w = getTOpt(m, "output.weight", .{}, &nb) orelse getT(m, "token_embd.weight", .{}, &nb);
    var logits = c.ggml_mul_mat(ctx, lm_w, lastc).?;
    // granite divides the logits by a stated factor
    if (d.logit_scale != 1.0 and d.logit_scale > 0.0) logits = c.ggml_scale(ctx, logits, 1.0 / d.logit_scale).?;

    const graph = c.ggml_new_graph_custom(ctx, decode_graph_nodes, false) orelse return null;
    // the cache writes FIRST, in layer order: expanding layer L+1's write pulls in layer L's attention and FFN (L+1's input), after
    // layer L's own writes, and the logits come last, so every read of the cache is ordered after its write
    for (kouts.items) |t| c.ggml_build_forward_expand(graph, t);
    c.ggml_build_forward_expand(graph, logits);
    _ = vouts;
    return .{ .graph = graph, .logits = logits };
}

// The pool the last forward pass asked for, in bytes (0 before any). Exposed so
// a guard can report what a prompt of a given size costs a given model.
var g_last_pool_bytes: usize = 0;

// Where the last decoder forward's time went, in ms (IM8b): [0] the shape pass, [1] the pool allocation, [2] the second build
// and the cache copied into it, [3] the compute, [4] the K/V appended to the cache, [5] the logits read back
var g_phase: [6]f64 = .{ 0, 0, 0, 0, 0, 0 };
fn msSince(t: i128) f64 {
    return @as(f64, @floatFromInt(std.time.nanoTimestamp() - t)) / 1e6;
}
pub export fn neural_gen_step_phase(i: c_int) callconv(.c) f64 {
    if (i < 0 or i > 5) return 0;
    return g_phase[@intCast(i)];
}

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
    return forwardDecodeX(ids, null);
}

// forwardDecode with the input rows given (n_embd floats per id) instead of looked up: the embedding entry
fn forwardDecodeX(ids: []const i32, embd: ?[]const f32) bool {
    if (isGemma4()) return if (embd == null) forwardGemma4(ids) else false; // GEMMA4-01: its own graph, text rows only
    if (isLfm3()) return if (embd == null) forwardLfm3(ids) else false; // LFM3: its own graph, text rows only
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

    // the model keeps the decoder's contract, and what is fed in fits it (SECURITY-MODELDATA-01b)
    if (!decoderOk(m, dims)) return false;
    if (embd) |e| {
        if (e.len < n_embd * n_new) return false;
    } else {
        for (ids) |t| if (t < 0 or t >= g_dc_rows) return false;
    }

    // the persistent cache, sized for this forward (a new model shape starts a new cache, which zeroes g_n_past)
    if (!ensureKv(n_layer, n_kv, dims.hd, padKv(g_n_past + n_new))) return false;
    const n_past = g_n_past;
    var dims_now = dims;
    dims_now.n_past = n_past;

    var kouts: std.ArrayList(*c.ggml_tensor) = .{};
    defer kouts.clearAndFree(gpa);
    var vouts: std.ArrayList(*c.ggml_tensor) = .{};
    defer vouts.clearAndFree(gpa);

    // pass 1: the graph's shape, in a context that holds headers and no data
    var tp = std.time.nanoTimestamp();
    var pool_bytes: usize = 0;
    {
        const meta = c.ggml_init(.{ .mem_size = 64 * 1024 * 1024, .mem_buffer = null, .no_alloc = true }) orelse return false;
        defer c.ggml_free(meta);
        if (buildDecodeGraph(meta, m, ids, embd, dims_now, false, &kouts, &vouts) == null) return false;
        pool_bytes = graphPoolBytes(meta);
    }
    kouts.clearRetainingCapacity();
    vouts.clearRetainingCapacity();
    g_last_pool_bytes = pool_bytes;
    g_phase[0] = msSince(tp);
    tp = std.time.nanoTimestamp();

    // pass 2: the same graph, in a pool of exactly the size pass 1 measured
    const ctx = c.ggml_init(.{ .mem_size = pool_bytes + 64 * 1024, .mem_buffer = null, .no_alloc = false }) orelse return false;
    defer c.ggml_free(ctx);
    g_phase[1] = msSince(tp);
    tp = std.time.nanoTimestamp();
    const built = buildDecodeGraph(ctx, m, ids, embd, dims_now, true, &kouts, &vouts) orelse return false;
    const graph = built.graph;
    const logits = built.logits;

    g_phase[2] = msSince(tp);
    tp = std.time.nanoTimestamp();
    var plan = c.ggml_graph_plan(graph, if (n_new > 1) g_threads_many else g_threads_one, null);
    var wbuf: ?[]u8 = null;
    if (plan.work_size > 0) {
        wbuf = gpa.alloc(u8, plan.work_size) catch return false;
        plan.work_data = wbuf.?.ptr;
    }
    defer if (wbuf) |w| gpa.free(w);
    _ = c.ggml_graph_compute(graph, &plan);
    g_phase[3] = msSince(tp);
    tp = std.time.nanoTimestamp();

    g_n_past = n_past + n_new;
    kvIdsSet(n_past, ids, embd != null);
    g_phase[4] = msSince(tp);
    tp = std.time.nanoTimestamp();

    // read back the last-token logits (and, for a verification pass, the best token of every row)
    const n_vocab_t: usize = @intCast(logits.*.ne[0]);
    const n_rows: usize = @intCast(logits.*.ne[1]);
    const ld_all: [*]const f32 = @ptrCast(@alignCast(logits.*.data));
    g_row_best.clearRetainingCapacity();
    if (n_rows > 1) {
        g_row_best.ensureTotalCapacity(gpa, n_rows) catch return false;
        for (0..n_rows) |r| {
            const row = ld_all[r * n_vocab_t ..][0..n_vocab_t];
            var best: usize = 0;
            var bestv: f32 = -3.4e38;
            for (row, 0..) |v, i| {
                if (v > bestv) {
                    bestv = v;
                    best = i;
                }
            }
            g_row_best.appendAssumeCapacity(@intCast(best));
        }
    }
    const ld = ld_all + (n_rows - 1) * n_vocab_t;
    g_logits.clearRetainingCapacity();
    g_logits.ensureTotalCapacity(gpa, n_vocab_t) catch return false;
    for (0..n_vocab_t) |i| g_logits.appendAssumeCapacity(ld[i]);
    g_phase[5] = msSince(tp);
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
// THE STOP SEES A REPEATED BLOCK, NOT ONLY A REPEATED LINE (2026-11-11). Granite-Docling looped on page v20_c22 by
// writing one line 88 times, which "the same line N times" ended; after 0f31cb56e moved its numbers by their last bits
// it looped on a ten-line footer instead ("in" / "England" / "and" / "Wales" / "·" / "Company" / ...), each line
// different from the one before, and ran to the 2048-token cap. So each finished line's hash is kept, and the stop fires
// when the last k*N lines are N copies of the last k, for any block of k <= stop_period lines; k = 1 is the old rule.
// stop_period was 8 first and missed that footer by two lines; 16 covers a page header or footer written word by word.
var g_line_hashes: std.ArrayList(u64) = .{};
const stop_period: usize = 16;

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
    g_line_hashes.clearRetainingCapacity();
    g_line_cur.clearRetainingCapacity();
    g_line_prev.clearRetainingCapacity();
    g_line_run = 0;
    g_stopped_on_repeat = false;
    g_show_controls = false;
}

// A document model writes its STRUCTURE as control tokens (<text>, <otsl>, <fcel>: Granite-Docling's DocTags),
// so a stream started with startWithSegments gives them back as text; every other stream hides them.
var g_show_controls: bool = false;

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

fn noteLineForCycle(line: []const u8) void {
    const keep = stop_period * g_stop_repeat;
    if (g_line_hashes.items.len >= keep and keep > 0) _ = g_line_hashes.orderedRemove(0);
    g_line_hashes.append(gpa, std.hash.Wyhash.hash(0x5107, line)) catch return;
    const h = g_line_hashes.items;
    var k: usize = 1;
    while (k <= stop_period) : (k += 1) {
        const need = k * g_stop_repeat;
        if (h.len < need) break;
        const tail = h[h.len - need ..];
        var same = true;
        var i: usize = k;
        while (i < need) : (i += 1) {
            if (tail[i] != tail[i - k]) {
                same = false;
                break;
            }
        }
        if (same) {
            g_stopped_on_repeat = true;
            return;
        }
    }
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
            if (g_stop_repeat > 0) noteLineForCycle(cur);
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
    // a fresh prompt keeps what the cache already holds of it (RADAR-SNAPSHOT-PREFIXKV-01) and reads the rest
    g_reused = 0;
    if (reset != 0) {
        const keep = prefixKeep(prompt);
        if (keep == 0) resetKv() else {
            g_n_past = keep;
            g_kv_ids.shrinkRetainingCapacity(keep);
            prompt = prompt[keep..];
            g_reused = keep;
        }
    }
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

// ---- the embedding entry (IM7: a picture in the prompt) -------------------------------------------------
//
// A vision-language model's prompt is text, then a picture's rows, then text: the picture arrives as n_rows
// embeddings of the decoder's width (vlm.zig makes them), read in place of n_rows <image> tokens at the
// positions they would hold. Everything after is ordinary generation: neural_gen_next() as for any prompt.
// A fresh sequence; 1 when the stream is ready, 0 with neural_gen_last_error() set otherwise.
pub fn startWithRows(before: []const u8, rows: []const f32, n_rows: usize, after: []const u8, max_new: c_int) c_int {
    g_stream_active = false;
    g_last_error = GEN_OK;
    g_truncated = false;
    g_last_prompt_tokens = 0;
    resetTermination();
    if (neural_model_has_generator() == 0 or !buildBpe()) {
        g_last_error = GEN_NO_GENERATOR;
        return 0;
    }
    const n_embd: usize = @intCast(kvArchInt(".embedding_length", 0));
    if (n_rows == 0 or rows.len != n_rows * n_embd) {
        g_last_error = GEN_FORWARD_FAILED;
        return 0;
    }
    resetKv();
    var a: std.ArrayList(i32) = .{};
    defer a.clearAndFree(gpa);
    var b: std.ArrayList(i32) = .{};
    defer b.clearAndFree(gpa);
    encode(before, &a);
    encode(after, &b);
    // the text after the picture continues the sequence: no second BOS
    var tail = b.items;
    if (g_add_bos and tail.len > 0 and tail[0] == g_bos) tail = tail[1..];
    g_last_prompt_tokens = a.items.len + n_rows + tail.len;
    if (g_last_prompt_tokens >= contextWindow()) {
        g_last_error = GEN_PROMPT_TOO_LONG;
        return 0;
    }
    const zeros = gpa.alloc(i32, n_rows) catch return 0;
    defer gpa.free(zeros);
    @memset(zeros, 0);
    if (!prefillIds(a.items) or !forwardDecodeX(zeros, rows) or !prefillIds(tail)) {
        g_last_error = GEN_FORWARD_FAILED;
        return 0;
    }
    g_stream_max = if (max_new > 0) @intCast(max_new) else 64;
    g_stream_n = 0;
    g_stream_temp = 0;
    g_stream_topp = 1.0;
    g_stream_topk = 0;
    g_prng = std.Random.DefaultPrng.init(0);
    g_stream_active = true;
    return 1;
}

// A PAGE in the prompt (Granite-Docling): texts[0], block 0's rows, texts[1], block 1's rows, ..., texts[n], every
// block `per` rows of the decoder's width. The texts are encoded one by one, so text that must be ONE piece for the
// tokenizer ("\n\n" between two views) is one entry. A fresh sequence; 1 when the stream is ready.
pub fn startWithSegments(texts: []const []const u8, rows: []const f32, per: usize, max_new: c_int) c_int {
    g_stream_active = false;
    g_last_error = GEN_OK;
    g_truncated = false;
    g_last_prompt_tokens = 0;
    resetTermination();
    if (neural_model_has_generator() == 0 or !buildBpe()) {
        g_last_error = GEN_NO_GENERATOR;
        return 0;
    }
    const n_embd: usize = @intCast(kvArchInt(".embedding_length", 0));
    if (per == 0 or n_embd == 0 or rows.len % (per * n_embd) != 0 or texts.len != rows.len / (per * n_embd) + 1) {
        g_last_error = GEN_FORWARD_FAILED;
        return 0;
    }
    const n_blocks = texts.len - 1;
    resetKv();
    const ids = gpa.alloc(std.ArrayList(i32), texts.len) catch return 0;
    for (ids) |*l| l.* = .{};
    defer {
        for (ids) |*l| l.clearAndFree(gpa);
        gpa.free(ids);
    }
    var total: usize = n_blocks * per;
    for (texts, 0..) |t, k| {
        encode(t, &ids[k]);
        // the text after a picture continues the sequence: no second BOS
        if (k > 0 and g_add_bos and ids[k].items.len > 0 and ids[k].items[0] == g_bos) _ = ids[k].orderedRemove(0);
        total += ids[k].items.len;
    }
    g_last_prompt_tokens = total;
    if (total >= contextWindow()) {
        g_last_error = GEN_PROMPT_TOO_LONG;
        return 0;
    }
    const zeros = gpa.alloc(i32, per) catch return 0;
    defer gpa.free(zeros);
    @memset(zeros, 0);
    for (0..texts.len) |k| {
        if (!prefillIds(ids[k].items)) {
            g_last_error = GEN_FORWARD_FAILED;
            return 0;
        }
        if (k < n_blocks and !forwardDecodeX(zeros, rows[k * per * n_embd ..][0 .. per * n_embd])) {
            g_last_error = GEN_FORWARD_FAILED;
            return 0;
        }
    }
    g_stream_max = if (max_new > 0) @intCast(max_new) else 64;
    g_stream_n = 0;
    g_stream_temp = 0;
    g_stream_topp = 1.0;
    g_stream_topk = 0;
    g_prng = std.Random.DefaultPrng.init(0);
    g_show_controls = true;
    g_stream_active = true;
    return 1;
}

// the width of the loaded decoder's rows (0 when none is loaded): what a picture's rows must have
pub fn embdWidth() usize {
    return @intCast(@max(0, kvArchInt(".embedding_length", 0)));
}

// one given token read into the sequence (a guard's teacher forcing: the reference's tokens, one by one)
pub fn feedToken(id: i32) bool {
    var one = [1]i32{id};
    return forwardDecode(one[0..]);
}

fn prefillIds(ids: []const i32) bool {
    var off: usize = 0;
    while (off < ids.len) {
        const end = @min(off + prefill_chunk, ids.len);
        if (!forwardDecode(ids[off..end])) return false;
        off = end;
    }
    return true;
}

// the last position's logits after the latest forward (a guard compares them with the reference's)
pub fn lastLogits() []const f32 {
    return g_logits.items;
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

// ---- speculative decoding (RADAR-NVIDIA-SPECDEC-01, 2026-11-11) ---------------------------------------------------
//
// A small DRAFTER of the same family proposes k tokens one by one; the TARGET then reads the k+1 tokens [x0, d1..dk] in
// ONE forward, keeping its own greedy choice after each of them. The drafts are taken while they equal the target's
// choice; the first that differs is replaced by the target's own token, and the cache is cut back to what was taken.
// So the text is the TARGET's greedy text -- the drafter only decides how many tokens one target pass may confirm --
// and the speedup is the drafter's cheapness times how often it agrees. Greedy only: a sampled or constrained
// generation (temperature, grammar, repeat penalty, stop-on-repeat) is refused, not approximated.
//
// THE TWO MODELS. The decoder keeps one model's state in globals (the loaded GGUF, its tokenizer, its cache, its
// contract verdict). The drafter's state lives in a SLOT beside it -- embed.ModelSlot for the model, GenSlot for the
// rest -- and swapIn/swapOut EXCHANGE the two, so the drafter runs through exactly the code the target runs, and
// nothing is rebuilt on a swap: each model keeps its own generation number, tokenizer maps and cache.
//
// THE SAME TOKENIZER, OR NOTHING. A draft token is an id; it means the same word to the target only if both models
// number the same vocabulary the same way. A signature over every token string, bos, eos and the end-of-generation set
// is taken from each model, and a target whose signature differs from the drafter's is refused.

const GenSlot = struct {
    kvctx: ?*c.ggml_context = null,
    kt: std.ArrayList(*c.ggml_tensor) = .{},
    vt: std.ArrayList(*c.ggml_tensor) = .{},
    cap: usize = 0,
    kv_shape: [2]usize = .{ 0, 0 },
    n_past: usize = 0,
    kv_ids: std.ArrayList(i32) = .{},
    cvctx: ?*c.ggml_context = null,
    cv: std.ArrayList(*c.ggml_tensor) = .{},
    cv_cap: usize = 0,
    cv_shape: [2]usize = .{ 0, 0 },
    pre_llama3: bool = false,
    logits: std.ArrayList(f32) = .{},
    bpe_built: bool = false,
    bpe_gen: usize = 0,
    tok_map: std.StringHashMap(i32) = undefined,
    merge_map: std.StringHashMap(i32) = undefined,
    n_vocab: usize = 0,
    bos: i32 = -1,
    eos: i32 = -1,
    add_bos: bool = false,
    specials: std.ArrayList(Special) = .{},
    eog: std.ArrayList(i32) = .{},
    spm: bool = false,
    dc_gen: usize = std.math.maxInt(usize),
    dc_ok: bool = false,
    dc_rows: i64 = 0,
};

fn swapGen(s: *GenSlot) void {
    std.mem.swap(?*c.ggml_context, &g_kvctx, &s.kvctx);
    std.mem.swap(std.ArrayList(*c.ggml_tensor), &g_kt, &s.kt);
    std.mem.swap(std.ArrayList(*c.ggml_tensor), &g_vt, &s.vt);
    std.mem.swap(usize, &g_cap, &s.cap);
    std.mem.swap([2]usize, &g_kv_shape, &s.kv_shape);
    std.mem.swap(usize, &g_n_past, &s.n_past);
    std.mem.swap(std.ArrayList(i32), &g_kv_ids, &s.kv_ids);
    std.mem.swap(?*c.ggml_context, &g_cvctx, &s.cvctx);
    std.mem.swap(std.ArrayList(*c.ggml_tensor), &g_cv, &s.cv);
    std.mem.swap(usize, &g_cv_cap, &s.cv_cap);
    std.mem.swap([2]usize, &g_cv_shape, &s.cv_shape);
    std.mem.swap(bool, &g_pre_llama3, &s.pre_llama3);
    std.mem.swap(std.ArrayList(f32), &g_logits, &s.logits);
    std.mem.swap(bool, &g_bpe_built, &s.bpe_built);
    std.mem.swap(usize, &g_bpe_gen, &s.bpe_gen);
    std.mem.swap(std.StringHashMap(i32), &g_tok_map, &s.tok_map);
    std.mem.swap(std.StringHashMap(i32), &g_merge_map, &s.merge_map);
    std.mem.swap(usize, &g_n_vocab, &s.n_vocab);
    std.mem.swap(i32, &g_bos, &s.bos);
    std.mem.swap(i32, &g_eos, &s.eos);
    std.mem.swap(bool, &g_add_bos, &s.add_bos);
    std.mem.swap(std.ArrayList(Special), &g_specials, &s.specials);
    std.mem.swap(std.ArrayList(i32), &g_eog, &s.eog);
    std.mem.swap(bool, &g_spm, &s.spm);
    std.mem.swap(usize, &g_dc_gen, &s.dc_gen);
    std.mem.swap(bool, &g_dc_ok, &s.dc_ok);
    std.mem.swap(i64, &g_dc_rows, &s.dc_rows);
}

var g_draft_model: embed.ModelSlot = .{};
var g_draft_gen: GenSlot = .{};
var g_draft_ready: bool = false;
var g_draft_sig: u64 = 0;
var g_target_sig: u64 = 0;
var g_target_sig_gen: usize = std.math.maxInt(usize);

fn swapIn() void {
    embed.swapModel(&g_draft_model);
    swapGen(&g_draft_gen);
}
fn swapOut() void {
    swapGen(&g_draft_gen);
    embed.swapModel(&g_draft_model);
}

const SPEC_OK: c_int = 0;
const SPEC_NO_DRAFTER: c_int = 1; // no drafter is loaded
const SPEC_DRAFTER_REFUSED: c_int = 2; // the drafter file did not load as a generator (digest, shape, arch)
const SPEC_VOCAB_DIFFERS: c_int = 3; // the target numbers its vocabulary differently from the drafter
const SPEC_NOT_GREEDY: c_int = 4; // grammar, repeat penalty or stop-on-repeat is set: refused, not approximated
const SPEC_TARGET_FAILED: c_int = 5; // the target refused the prompt (see neural_gen_last_error)
const SPEC_FORWARD_FAILED: c_int = 6;
var g_spec_status: c_int = SPEC_OK;

// [rounds, tokens drafted, drafts taken, target passes, drafter passes, ms, tokens produced, ms in the target's
//  verification passes, ms in the drafter]
var g_spec_stats: [9]f64 = .{ 0, 0, 0, 0, 0, 0, 0, 0, 0 };

// The vocabulary's identity: every token string in order, then bos, eos and the end-of-generation set.
fn vocabSignature() u64 {
    var h = std.hash.Wyhash.init(0x5eed_d1ce);
    h.update(std.mem.asBytes(&g_n_vocab));
    for (0..g_n_vocab) |i| {
        h.update(vocabToken(i));
        h.update(&[_]u8{0});
    }
    h.update(std.mem.asBytes(&g_bos));
    h.update(std.mem.asBytes(&g_eos));
    for (g_eog.items) |e| h.update(std.mem.asBytes(&e));
    return h.final();
}

fn freeDrafter() void {
    if (g_draft_model.gguf != null or g_draft_gen.bpe_built or g_draft_gen.kvctx != null) {
        swapIn();
        freeBpe();
        resetKv();
        g_logits.clearAndFree(gpa);
        swapOut();
    }
    embed.freeSlot(&g_draft_model);
    g_draft_gen = .{};
    g_draft_ready = false;
    g_draft_sig = 0;
}

/// Free the drafter (the target in place is untouched).
pub export fn neural_gen_draft_free() callconv(.c) void {
    freeDrafter();
}

/// Load the drafter from a GGUF file, beside the model in place: digest-checked as every model is, a generator this
/// decoder knows, its tokenizer read. 1 when ready; 0 with neural_gen_spec_status() = SPEC_DRAFTER_REFUSED otherwise.
pub export fn neural_gen_draft_load(path: [*c]const u8) callconv(.c) c_int {
    freeDrafter();
    g_spec_status = SPEC_OK;
    if (path == null) {
        g_spec_status = SPEC_DRAFTER_REFUSED;
        return 0;
    }
    var ok = false;
    {
        swapIn();
        defer swapOut();
        if (embed.neural_model_load(path) == 1 and neural_model_has_generator() == 1 and buildBpe()) {
            g_draft_sig = vocabSignature();
            ok = true;
        }
    }
    if (!ok) {
        freeDrafter();
        g_spec_status = SPEC_DRAFTER_REFUSED;
        return 0;
    }
    g_draft_ready = true;
    return 1;
}

pub export fn neural_gen_draft_ready() callconv(.c) c_int {
    return if (g_draft_ready) 1 else 0;
}

pub export fn neural_gen_spec_status() callconv(.c) c_int {
    return g_spec_status;
}

pub export fn neural_gen_spec_stat(i: c_int) callconv(.c) f64 {
    if (i < 0 or i >= g_spec_stats.len) return 0;
    return g_spec_stats[@intCast(i)];
}

fn specCommit(id: i32, out: *std.ArrayList(i32)) bool {
    out.append(gpa, id) catch return false;
    g_chunk.clearRetainingCapacity();
    var one = [1]i32{id};
    decodeInto(one[0..], &g_chunk);
    g_gen_text.appendSlice(gpa, g_chunk.items) catch return false;
    return true;
}

/// Greedy generation with the drafter proposing up to `k` tokens per target pass. The text is the target's own greedy
/// text (neural_gen_text); the counts of the run are in neural_gen_spec_stat. Its length, or -1 (see the status).
pub export fn neural_generate_spec(text: [*c]const u8, len: usize, max_new: c_int, k_in: c_int) callconv(.c) c_int {
    const t0 = std.time.nanoTimestamp();
    g_spec_status = SPEC_OK;
    g_spec_stats = .{ 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    g_gen_text.clearRetainingCapacity();
    if (!g_draft_ready) {
        g_spec_status = SPEC_NO_DRAFTER;
        return -1;
    }
    if (g_gram_on or g_rep_penalty > 1.0 or g_stop_repeat > 0) {
        g_spec_status = SPEC_NOT_GREEDY;
        return -1;
    }
    const k: usize = @intCast(std.math.clamp(k_in, 1, 16));
    const max: usize = if (max_new > 0) @intCast(max_new) else 64;

    // the target reads the prompt (fresh sequence, greedy); its last logits give the first token
    if (neural_gen_start(text, len, max_new, 0, 1.0, 0, 0) == 0) {
        g_spec_status = SPEC_TARGET_FAILED;
        return -1;
    }
    g_stream_active = false; // this function drives the target, not neural_gen_next
    if (g_target_sig_gen != embed.model_generation) {
        g_target_sig = vocabSignature();
        g_target_sig_gen = embed.model_generation;
    }
    if (g_target_sig != g_draft_sig) {
        g_spec_status = SPEC_VOCAB_DIFFERS;
        return -1;
    }

    var prompt: std.ArrayList(i32) = .{};
    defer prompt.clearAndFree(gpa);
    encode(text[0..len], &prompt);

    // the drafter reads the same prompt into its own cache
    const n_prompt_d = prompt.items.len;
    const dok = blk: {
        swapIn();
        defer swapOut();
        resetKv();
        break :blk prefillIds(prompt.items);
    };
    if (!dok) {
        g_spec_status = SPEC_FORWARD_FAILED;
        return -1;
    }

    var out: std.ArrayList(i32) = .{};
    defer out.clearAndFree(gpa);
    var drafts: std.ArrayList(i32) = .{};
    defer drafts.clearAndFree(gpa);
    var batch: std.ArrayList(i32) = .{};
    defer batch.clearAndFree(gpa);
    var d_have: usize = 0; // produced tokens the drafter's cache already holds

    var x0 = argmaxLogits();
    while (true) {
        if (x0 < 0 or isEog(x0)) break;
        if (g_n_past >= contextWindow()) {
            g_truncated = true;
            break;
        }
        if (!specCommit(x0, &out)) break;
        if (out.items.len >= max) break;

        // the drafter proposes: first it catches up on what was produced, then one token at a time
        const room = contextWindow() - g_n_past; // >= 1 here: x0 still has to go into the target's cache
        const kk = @min(k, room - 1, max - out.items.len);
        drafts.clearRetainingCapacity();
        if (kk > 0) {
            const td = std.time.nanoTimestamp();
            defer g_spec_stats[8] += @as(f64, @floatFromInt(std.time.nanoTimestamp() - td)) / 1.0e6;
            const ok = blk: {
                swapIn();
                defer swapOut();
                g_n_past = n_prompt_d + d_have; // what the drafter took last round, cut to what the target kept
                if (!prefillIds(out.items[d_have..])) break :blk false;
                g_spec_stats[4] += 1;
                d_have = out.items.len;
                while (drafts.items.len < kk) {
                    const d = argmaxLogits();
                    drafts.append(gpa, d) catch break :blk false;
                    if (isEog(d) or drafts.items.len == kk) break;
                    var one = [1]i32{d};
                    if (!forwardDecode(one[0..])) break :blk false;
                    g_spec_stats[4] += 1;
                }
                break :blk true;
            };
            if (!ok) {
                g_spec_status = SPEC_FORWARD_FAILED;
                break;
            }
        }

        // the target reads x0 and every draft in one pass, keeping its choice after each
        batch.clearRetainingCapacity();
        batch.append(gpa, x0) catch break;
        batch.appendSlice(gpa, drafts.items) catch break;
        const base = g_n_past;
        g_rows_out = batch.items.len;
        const tv = std.time.nanoTimestamp();
        const tok = forwardDecode(batch.items);
        g_spec_stats[7] += @as(f64, @floatFromInt(std.time.nanoTimestamp() - tv)) / 1.0e6;
        g_rows_out = 1;
        if (!tok) {
            g_spec_status = SPEC_FORWARD_FAILED;
            g_last_error = GEN_FORWARD_FAILED;
            break;
        }
        g_spec_stats[0] += 1;
        g_spec_stats[1] += @floatFromInt(drafts.items.len);
        g_spec_stats[3] += 1;
        // best[i]: the target's token after batch[i] (one row: the plain last-token choice)
        var lone = [1]i32{0};
        const best: []const i32 = if (batch.items.len > 1) g_row_best.items else blk: {
            lone[0] = argmaxLogits();
            break :blk lone[0..];
        };

        var a: usize = 0;
        var stop = false;
        while (a < drafts.items.len and drafts.items[a] == best[a]) {
            const d = drafts.items[a];
            if (isEog(d)) {
                stop = true;
                break;
            }
            a += 1;
            if (!specCommit(d, &out)) {
                stop = true;
                break;
            }
            if (out.items.len >= max) {
                stop = true;
                break;
            }
        }
        g_spec_stats[2] += @floatFromInt(a);
        // the target keeps x0 and the drafts it took; the drafter, at most what it was fed
        g_n_past = base + 1 + a;
        d_have = @min(d_have + a, d_have + (if (drafts.items.len > 0) drafts.items.len - 1 else 0));
        if (stop) break;
        x0 = best[a];
    }
    g_spec_stats[6] = @floatFromInt(out.items.len);
    g_spec_stats[5] = @as(f64, @floatFromInt(std.time.nanoTimestamp() - t0)) / 1.0e6;
    g_gen_text.append(gpa, 0) catch return -1;
    if (g_spec_status != SPEC_OK) return -1;
    return @intCast(g_gen_text.items.len - 1);
}

// ---- the read prompt kept (RADAR-SNAPSHOT-PREFIXKV-01, 2026-11-11) ----------------------------------------------------
//
// NVIDIA's Snapshot restores a warmed GPU process instead of starting it cold; Radar's lesson for Softanza: the warm
// state worth keeping here is a prompt already READ. Two levels:
//   IN MEMORY  the cache remembers which token ids it holds (g_kv_ids). A fresh prompt that begins as the cache does
//              keeps that common prefix and reads only the rest -- a fixed system prompt is read once, not per call.
//              At least one token is always read, so the logits are fresh.
//   ON DISK    neural_gen_prefix_save writes the cache's tokens and K/V rows, keyed by the model's SHA-256 and shapes;
//              neural_gen_prefix_load puts them back, and the next prompt that begins with those tokens reuses them.
// THE ANSWER IS THE SAME, BIT FOR BIT: a position's K and V depend only on the tokens before it (causal attention), and
// since 0f31cb56e a token's numbers do not depend on how many tokens were read with it (kv_pad) -- so the logits after
// a reused prefix are the logits a full read gives. neural_gen_logits_hash() lets a guard check that over the whole
// vocabulary.

fn kvIdsSet(n_past: usize, ids: []const i32, rows: bool) void {
    if (g_kv_ids.items.len > n_past) g_kv_ids.shrinkRetainingCapacity(n_past);
    if (g_kv_ids.items.len != n_past) { // a gap: the record cannot say what the cache holds any more
        g_kv_ids.clearRetainingCapacity();
        return;
    }
    for (ids) |t| g_kv_ids.append(gpa, if (rows) -1 else t) catch {
        g_kv_ids.clearRetainingCapacity();
        return;
    };
}

// how much of `prompt` the cache already holds, leaving at least its last token to read
fn prefixKeep(prompt: []const i32) usize {
    if (!g_prefix_reuse or prompt.len < 2 or g_kv_ids.items.len < g_n_past) return 0;
    const held = g_kv_ids.items[0..g_n_past];
    var n: usize = 0;
    while (n < held.len and n < prompt.len - 1 and held[n] >= 0 and held[n] == prompt[n]) n += 1;
    return n;
}

pub export fn neural_gen_set_prefix_reuse(on: c_int) callconv(.c) void {
    g_prefix_reuse = on != 0;
}
/// tokens of the last fresh prompt that the cache already held (not read again)
pub export fn neural_gen_reused_tokens() callconv(.c) c_int {
    return @intCast(g_reused);
}
/// a 32-bit hash of the whole last logits vector, bit for bit (equal hashes: equal logits, to the bit)
pub export fn neural_gen_logits_hash() callconv(.c) f64 {
    const h = std.hash.Wyhash.hash(0x10917, std.mem.sliceAsBytes(g_logits.items));
    return @floatFromInt(@as(u32, @truncate(h)));
}

const PREFIX_MAGIC = "STZKV001";
const PX_OK: c_int = 0;
const PX_UNREADABLE: c_int = 1;
const PX_NOT_PREFIX: c_int = 2;
const PX_OTHER_MODEL: c_int = 3;
const PX_OTHER_SHAPE: c_int = 4;
const PX_SIZE: c_int = 5;
const PX_VALUES: c_int = 6;
const PX_NOTHING: c_int = 7;
var g_prefix_status: c_int = PX_OK;
pub export fn neural_gen_prefix_status() callconv(.c) c_int {
    return g_prefix_status;
}

// the cache shape this model's forward uses: [layers with a cache, kv heads, head width]
fn modelKvShape() ?[3]usize {
    const m = mctx() orelse return null;
    if (isGemma4()) {
        if (!g4Ok(m)) return null;
        return .{ g_g4.own, g_g4.kv, g_g4.hd_g };
    }
    const n_embd: usize = @intCast(@max(0, kvArchInt(".embedding_length", 0)));
    const n_head: usize = @intCast(@max(0, kvArchInt(".attention.head_count", 0)));
    const n_layer: usize = @intCast(@max(0, kvArchInt(".block_count", 0)));
    if (n_embd == 0 or n_head == 0 or n_layer == 0) return null;
    const n_kv: usize = @intCast(@max(0, kvArchInt(".attention.head_count_kv", @intCast(n_head))));
    const hd: usize = @intCast(@max(0, kvArchInt(".attention.key_length", @intCast(n_embd / n_head))));
    if (n_kv == 0 or hd == 0) return null;
    return .{ n_layer, n_kv, hd };
}

/// Write the first n tokens the cache holds (n <= 0: all of them) to `path`, keyed by the model's SHA-256 and shapes.
/// 1 written; 0 with neural_gen_prefix_status() saying why.
pub export fn neural_gen_prefix_save(path: [*c]const u8, n_c: c_int) callconv(.c) c_int {
    g_prefix_status = PX_NOTHING;
    if (path == null) return 0;
    const hex = embed.modelHex() orelse return 0;
    if (g_kvctx == null or g_n_past == 0 or g_kv_ids.items.len < g_n_past) return 0;
    if (g_cv.items.len > 0) return 0; // a convolution's state is not in the file format (LFM3): in-memory reuse only
    const n: usize = if (n_c <= 0) g_n_past else @min(@as(usize, @intCast(n_c)), g_n_past);
    for (g_kv_ids.items[0..n]) |t| if (t < 0) return 0; // picture rows have no token to key them by
    const layers = g_kt.items.len;
    const kv = g_kv_shape[0];
    const hd = g_kv_shape[1];
    g_prefix_status = PX_UNREADABLE;
    const f = std.fs.cwd().createFile(std.mem.span(@as([*:0]const u8, @ptrCast(path))), .{}) catch return 0;
    defer f.close();
    var buf: [65536]u8 = undefined;
    var w = f.writer(&buf);
    const io = &w.interface;
    io.writeAll(PREFIX_MAGIC) catch return 0;
    io.writeAll(hex) catch return 0;
    for ([_]u32{ @intCast(layers), @intCast(kv), @intCast(hd), @intCast(n) }) |v| io.writeInt(u32, v, .little) catch return 0;
    io.writeAll(std.mem.sliceAsBytes(g_kv_ids.items[0..n])) catch return 0;
    for (0..layers) |L| {
        const k: [*]const f32 = @ptrCast(@alignCast(g_kt.items[L].*.data));
        const v: [*]const f32 = @ptrCast(@alignCast(g_vt.items[L].*.data));
        for (0..kv) |g| io.writeAll(std.mem.sliceAsBytes(k[hd * g_cap * g ..][0 .. hd * n])) catch return 0;
        for (0..kv) |g| for (0..hd) |d| io.writeAll(std.mem.sliceAsBytes(v[g_cap * (d + hd * g) ..][0..n])) catch return 0;
    }
    io.flush() catch return 0;
    g_prefix_status = PX_OK;
    return 1;
}

/// Put a saved prefix back into the cache: refused, with a status, unless it was written for THIS model file (its
/// SHA-256), with this model's cache shape, is exactly the size its header says, and holds finite numbers only -- a
/// prefix file is model data, read as SECURITY-MODELDATA-01 reads one. The next fresh prompt that begins with its
/// tokens reads only the rest. Returns the number of tokens restored, 0 on a refusal.
pub export fn neural_gen_prefix_load(path: [*c]const u8) callconv(.c) c_int {
    g_prefix_status = PX_UNREADABLE;
    if (path == null) return 0;
    if (neural_model_has_generator() == 0 or !buildBpe()) return 0;
    const hex = embed.modelHex() orelse return 0;
    g_prefix_status = PX_OTHER_SHAPE;
    if (isLfm3()) return 0; // its convolution state is not in the file format
    g_prefix_status = PX_UNREADABLE;
    const shape = modelKvShape() orelse return 0;
    const bytes = std.fs.cwd().readFileAlloc(gpa, std.mem.span(@as([*:0]const u8, @ptrCast(path))), 1 << 32) catch return 0;
    defer gpa.free(bytes);
    const head = PREFIX_MAGIC.len + 64 + 16;
    g_prefix_status = PX_NOT_PREFIX;
    if (bytes.len < head or !std.mem.eql(u8, bytes[0..8], PREFIX_MAGIC)) return 0;
    g_prefix_status = PX_OTHER_MODEL;
    if (!std.mem.eql(u8, bytes[8..72], hex)) return 0;
    const layers = std.mem.readInt(u32, bytes[72..76], .little);
    const kv = std.mem.readInt(u32, bytes[76..80], .little);
    const hd = std.mem.readInt(u32, bytes[80..84], .little);
    const n = std.mem.readInt(u32, bytes[84..88], .little);
    g_prefix_status = PX_OTHER_SHAPE;
    if (layers != shape[0] or kv != shape[1] or hd != shape[2]) return 0;
    g_prefix_status = PX_SIZE;
    if (n == 0 or n >= contextWindow()) return 0;
    const per_layer = @as(u64, 2) * kv * hd * n * 4;
    const want = @as(u64, head) + @as(u64, n) * 4 + per_layer * layers;
    if (bytes.len != want) return 0;
    var ids: std.ArrayList(i32) = .{};
    defer ids.clearAndFree(gpa);
    ids.ensureTotalCapacity(gpa, n) catch return 0;
    for (0..n) |i| {
        const t = std.mem.readInt(i32, bytes[head + 4 * i ..][0..4], .little);
        g_prefix_status = PX_VALUES;
        if (t < 0 or t >= g_n_vocab) return 0;
        ids.appendAssumeCapacity(t);
    }
    const data = bytes[head + 4 * n ..];
    var off: usize = 0;
    while (off < data.len) : (off += 4) {
        const x: f32 = @bitCast(std.mem.readInt(u32, data[off..][0..4], .little));
        if (!std.math.isFinite(x)) return 0;
    }
    resetKv();
    g_prefix_status = PX_UNREADABLE;
    if (!ensureKv(layers, kv, hd, padKv(n))) return 0;
    off = 0;
    const take = struct {
        fn f(src: []const u8, at: *usize, dst: []f32) void {
            @memcpy(std.mem.sliceAsBytes(dst), src[at.* .. at.* + dst.len * 4]);
            at.* += dst.len * 4;
        }
    }.f;
    for (0..layers) |L| {
        const k: [*]f32 = @ptrCast(@alignCast(g_kt.items[L].*.data));
        const v: [*]f32 = @ptrCast(@alignCast(g_vt.items[L].*.data));
        for (0..kv) |g| take(data, &off, k[hd * g_cap * g ..][0 .. hd * n]);
        for (0..kv) |g| for (0..hd) |d| take(data, &off, v[g_cap * (d + hd * g) ..][0..n]);
    }
    g_n_past = n;
    g_kv_ids.clearRetainingCapacity();
    g_kv_ids.appendSlice(gpa, ids.items) catch {
        resetKv();
        return 0;
    };
    g_prefix_status = PX_OK;
    return @intCast(n);
}

// ---- the Gemma 4 decoder (general.architecture = "gemma4"; GEMMA4-01 step 2, 2026-11-11) -----------------------------
//
// Gemma 4 E4B (and NVIDIA's Nemotron 3.5 Bolt E4B, post-trained from it), wired as llama.cpp b12283 wires it
// (src/models/gemma4.cpp, read line by line):
//   - the token rows are scaled by sqrt(n_embd);
//   - PER-LAYER EMBEDDINGS: a second table gives every token P numbers per layer; they are added to a projection of the
//     token's row (RMS-normed, eps folded), scaled by 1/sqrt(2), and each block multiplies its slice into a gated
//     branch: gelu(inp_gate x) * slice -> proj -> RMS norm -> added to the residual;
//   - two kinds of attention by the file's own pattern: SLIDING layers (head hd_s, window W, rope base b_s) and GLOBAL
//     ones (head hd_g, rope base b_g with the file's frequency factors). Q and K are RMS-normed per head with weights,
//     V without; the attention scale is 1 (the norms do its work); rope is NEOX;
//   - the last `shared_kv_layers` layers write no cache: they read the cache of the last own layer of their kind;
//   - norms after attention and after the feed-forward; a GELU gated feed-forward; each layer's output scaled by its
//     own scalar; the logits soft-capped: c * tanh(x / c).
// THE CACHE: every own layer's K and V are allocated at the widest head (hd_g) and a sliding layer reads its first hd_s
// columns through views -- the llama path's cache unchanged; sliding layers hold twice what they need (0.8 GB at 4,096
// tokens for E4B, against 0.47 GB packed). The attention width is padded as everywhere (kv_pad).

const G4 = struct {
    n_layer: usize,
    d: usize, // n_embd
    h: usize, // query heads
    kv: usize, // kv heads
    hd_g: usize,
    hd_s: usize,
    f: usize,
    p: usize, // per-layer embedding width
    own: usize, // layers with their own cache: n_layer - shared_kv_layers
    window: usize,
    base_g: f32,
    base_s: f32,
    eps: f32,
    softcap: f32,
    n_ctx_train: c_int,
    rows: i64, // vocabulary rows of token_embd
    swa: [256]bool,
};

var g_g4_gen: usize = std.math.maxInt(usize);
var g_g4_ok: bool = false;
var g_g4: G4 = undefined;

fn isGemma4() bool {
    return std.mem.eql(u8, archName(), "gemma4");
}

fn g4Hd(d: *const G4, il: usize) usize {
    return if (d.swa[il]) d.hd_s else d.hd_g;
}
fn g4Src(d: *const G4, il: usize) usize {
    if (il < d.own) return il;
    return d.own - (if (d.swa[il]) @as(usize, 2) else 1);
}

fn g4Mat(m: ?*c.ggml_context, comptime fmt: []const u8, args: anytype, ne0: usize, ne1: usize) bool {
    var nb: [96]u8 = undefined;
    const t = getTOpt(m, fmt, args, &nb) orelse return false;
    return t.*.ne[0] == ne0 and t.*.ne[1] == ne1 and t.*.ne[2] == 1 and t.*.ne[3] == 1;
}
fn g4Vec(m: ?*c.ggml_context, comptime fmt: []const u8, args: anytype, n: usize) bool {
    var nb: [96]u8 = undefined;
    const t = getTOpt(m, fmt, args, &nb) orelse return false;
    return t.*.type == c.GGML_TYPE_F32 and t.*.ne[0] == n and t.*.ne[1] == 1 and t.*.ne[2] == 1 and t.*.ne[3] == 1;
}

// THE CONTRACT (SECURITY-MODELDATA-01's rule): every tensor the graph reads is present and shaped to the file's own
// sizes, checked once per model, before ggml sees any of it -- a file that lies about a shape is refused, not run.
fn g4Read(m: ?*c.ggml_context) ?G4 {
    const ctx = gguf() orelse return null;
    var d: G4 = undefined;
    const L = kvArchInt(".block_count", 0);
    if (L < 2 or L > 256) return null;
    d.n_layer = @intCast(L);
    d.d = @intCast(@max(0, kvArchInt(".embedding_length", 0)));
    d.h = @intCast(@max(0, kvArchInt(".attention.head_count", 0)));
    d.kv = @intCast(@max(0, kvArchInt(".attention.head_count_kv", 0)));
    d.hd_g = @intCast(@max(0, kvArchInt(".attention.key_length", 0)));
    d.hd_s = @intCast(@max(0, kvArchInt(".attention.key_length_swa", 0)));
    d.f = @intCast(@max(0, kvArchInt(".feed_forward_length", 0)));
    d.p = @intCast(@max(0, kvArchInt(".embedding_length_per_layer_input", 0)));
    const shared: usize = @intCast(@max(0, kvArchInt(".attention.shared_kv_layers", 0)));
    d.window = @intCast(@max(0, kvArchInt(".attention.sliding_window", 0)));
    if (d.d == 0 or d.h == 0 or d.kv == 0 or d.h % d.kv != 0 or d.hd_g == 0 or d.hd_s == 0 or d.hd_s > d.hd_g or
        d.f == 0 or d.p == 0 or d.window == 0 or shared + 2 > d.n_layer) return null;
    if (d.d > 1 << 16 or d.f > 1 << 18 or d.hd_g > 4096 or d.h > 1024) return null;
    if (kvArchInt(".attention.value_length", @intCast(d.hd_g)) != d.hd_g or
        kvArchInt(".attention.value_length_swa", @intCast(d.hd_s)) != d.hd_s) return null;
    d.own = d.n_layer - shared;
    d.base_g = kvArchF32(".rope.freq_base", 10000.0);
    d.base_s = kvArchF32(".rope.freq_base_swa", 10000.0);
    d.eps = kvArchF32(".attention.layer_norm_rms_epsilon", 1e-6);
    d.softcap = kvArchF32(".final_logit_softcapping", 0.0);
    if (!(d.eps >= 0) or !(d.softcap >= 0) or !(d.base_g > 0) or !(d.base_s > 0)) return null;
    d.n_ctx_train = @intCast(std.math.clamp(kvArchInt(".context_length", 2048), 1, 1 << 24));
    // the rope turns the whole head of each kind (dimension_count = key_length): another split is not this wiring
    if (kvArchInt(".rope.dimension_count", @intCast(d.hd_g)) != d.hd_g or
        kvArchInt(".rope.dimension_count_swa", @intCast(d.hd_s)) != d.hd_s) return null;
    var key: [96]u8 = undefined;
    const pk = std.fmt.bufPrintZ(&key, "{s}.attention.sliding_window_pattern", .{archName()}) catch return null;
    const pat = gr.arrBool(ctx, gr.find(ctx, pk)) orelse return null;
    if (pat.len != d.n_layer) return null;
    for (0..d.n_layer) |i| d.swa[i] = pat[i] != 0;
    // a shared layer reads the last own layer of its kind: that layer must be of its kind
    for (d.own..d.n_layer) |il| if (d.swa[g4Src(&d, il)] != d.swa[il]) return null;

    const D = d.d;
    const PL = d.p * d.n_layer;
    var nb: [96]u8 = undefined;
    const te = getTOpt(m, "token_embd.weight", .{}, &nb) orelse return null;
    if (te.*.ne[0] != D or te.*.ne[1] < 1 or te.*.ne[2] != 1) return null;
    d.rows = te.*.ne[1];
    const V: usize = @intCast(d.rows);
    if (getTOpt(m, "output.weight", .{}, &nb) != null and !g4Mat(m, "output.weight", .{}, D, V)) return null;
    if (!g4Mat(m, "per_layer_token_embd.weight", .{}, PL, V)) return null;
    if (!g4Mat(m, "per_layer_model_proj.weight", .{}, D, PL)) return null;
    if (!g4Vec(m, "per_layer_proj_norm.weight", .{}, d.p) or !g4Vec(m, "output_norm.weight", .{}, D)) return null;
    for (0..d.n_layer) |il| {
        const hd = g4Hd(&d, il);
        if (!g4Vec(m, "blk.{d}.attn_norm.weight", .{il}, D)) return null;
        if (!g4Mat(m, "blk.{d}.attn_q.weight", .{il}, D, d.h * hd)) return null;
        if (!g4Vec(m, "blk.{d}.attn_q_norm.weight", .{il}, hd)) return null;
        if (!g4Mat(m, "blk.{d}.attn_output.weight", .{il}, d.h * hd, D)) return null;
        if (il < d.own) {
            if (!g4Mat(m, "blk.{d}.attn_k.weight", .{il}, D, d.kv * hd)) return null;
            if (!g4Vec(m, "blk.{d}.attn_k_norm.weight", .{il}, hd)) return null;
            if (getTOpt(m, "blk.{d}.attn_v.weight", .{il}, &nb) != null and !g4Mat(m, "blk.{d}.attn_v.weight", .{il}, D, d.kv * hd)) return null;
        }
        if (!d.swa[il] and !g4Vec(m, "rope_freqs.weight", .{}, hd / 2)) return null;
        if (!g4Vec(m, "blk.{d}.post_attention_norm.weight", .{il}, D) or !g4Vec(m, "blk.{d}.ffn_norm.weight", .{il}, D)) return null;
        if (!g4Mat(m, "blk.{d}.ffn_gate.weight", .{il}, D, d.f) or !g4Mat(m, "blk.{d}.ffn_up.weight", .{il}, D, d.f)) return null;
        if (!g4Mat(m, "blk.{d}.ffn_down.weight", .{il}, d.f, D) or !g4Vec(m, "blk.{d}.post_ffw_norm.weight", .{il}, D)) return null;
        if (!g4Mat(m, "blk.{d}.inp_gate.weight", .{il}, D, d.p) or !g4Mat(m, "blk.{d}.proj.weight", .{il}, d.p, D)) return null;
        if (!g4Vec(m, "blk.{d}.post_norm.weight", .{il}, D)) return null;
        if (getTOpt(m, "blk.{d}.layer_output_scale.weight", .{il}, &nb) != null and !g4Vec(m, "blk.{d}.layer_output_scale.weight", .{il}, 1)) return null;
        if (getTOpt(m, "blk.{d}.ffn_gate_inp.weight", .{il}, &nb) != null) return null; // the mixture-of-experts variant: not this wiring
    }
    return d;
}

fn g4Ok(m: ?*c.ggml_context) bool {
    if (g_g4_gen != embed.model_generation) {
        g_g4_gen = embed.model_generation;
        if (g4Read(m)) |d| {
            g_g4 = d;
            g_g4_ok = true;
        } else g_g4_ok = false;
    }
    return g_g4_ok;
}

fn g4Norm(ctx: *c.ggml_context, x: *c.ggml_tensor, w: *c.ggml_tensor, eps: f32) *c.ggml_tensor {
    return c.ggml_mul(ctx, c.ggml_rms_norm(ctx, x, eps).?, w).?;
}

fn buildGemma4Graph(
    ctx: *c.ggml_context,
    m: ?*c.ggml_context,
    ids: []const i32,
    d: *const G4,
    n_past: usize,
    fill: bool,
    kouts: *std.ArrayList(*c.ggml_tensor),
) ?DecodeGraph {
    const n = ids.len;
    const kv_len = padKv(n_past + n);
    const grp = d.h / d.kv;
    const D = d.d;
    var nb: [96]u8 = undefined;
    var nb2: [96]u8 = undefined;

    const tokens = c.ggml_new_tensor_1d(ctx, c.GGML_TYPE_I32, @intCast(n)).?;
    const positions = c.ggml_new_tensor_1d(ctx, c.GGML_TYPE_I32, @intCast(n)).?;
    const mask_g = c.ggml_new_tensor_2d(ctx, c.GGML_TYPE_F32, @intCast(kv_len), @intCast(n * grp)).?;
    const mask_s = c.ggml_new_tensor_2d(ctx, c.GGML_TYPE_F32, @intCast(kv_len), @intCast(n * grp)).?;
    if (fill) {
        const td: [*]i32 = @ptrCast(@alignCast(tokens.*.data));
        const pd: [*]i32 = @ptrCast(@alignCast(positions.*.data));
        for (0..n) |i| {
            td[i] = ids[i];
            pd[i] = @intCast(n_past + i);
        }
        const mg: [*]f32 = @ptrCast(@alignCast(mask_g.*.data));
        const ms: [*]f32 = @ptrCast(@alignCast(mask_s.*.data));
        for (0..n * grp) |x| {
            const q = n_past + x % n; // this query's position
            for (0..kv_len) |k| {
                const seen = k <= q;
                mg[x * kv_len + k] = if (seen) 0.0 else -1.0e9;
                // llama.cpp LLAMA_SWA_TYPE_STANDARD: a key W or more positions back is out of the window
                ms[x * kv_len + k] = if (seen and q - k < d.window) 0.0 else -1.0e9;
            }
        }
    }

    // the token rows, scaled by sqrt(n_embd)
    var inpL = c.ggml_get_rows(ctx, getT(m, "token_embd.weight", .{}, &nb), tokens).?;
    inpL = c.ggml_scale(ctx, inpL, @sqrt(@as(f32, @floatFromInt(D)))).?;

    // the per-layer inputs [P, n, L]: the table's rows plus the normed projection of the scaled token row
    const P = d.p;
    const L = d.n_layer;
    var ple = c.ggml_get_rows(ctx, getT(m, "per_layer_token_embd.weight", .{}, &nb), tokens).?;
    ple = c.ggml_scale(ctx, ple, @sqrt(@as(f32, @floatFromInt(P))) / @sqrt(2.0)).?;
    ple = c.ggml_reshape_3d(ctx, ple, @intCast(P), @intCast(L), @intCast(n)).?;
    var proj = c.ggml_mul_mat(ctx, getT(m, "per_layer_model_proj.weight", .{}, &nb), inpL).?;
    proj = c.ggml_reshape_3d(ctx, proj, @intCast(P), @intCast(L), @intCast(n)).?;
    proj = c.ggml_rms_norm(ctx, proj, d.eps * @as(f32, @floatFromInt(D))).?; // eps / (1/sqrt(D))^2
    const pnorm = c.ggml_scale(ctx, getT(m, "per_layer_proj_norm.weight", .{}, &nb), 1.0 / @sqrt(2.0)).?;
    proj = c.ggml_mul(ctx, proj, pnorm).?;
    ple = c.ggml_add(ctx, proj, ple).?;
    ple = c.ggml_cont(ctx, c.ggml_permute(ctx, ple, 0, 2, 1, 3)).?; // [P, n, L]

    const rope_f = getTOpt(m, "rope_freqs.weight", .{}, &nb2);
    for (0..L) |il| {
        const hd = g4Hd(d, il);
        const is_swa = d.swa[il];
        const base = if (is_swa) d.base_s else d.base_g;
        const ff: ?*c.ggml_tensor = if (is_swa) null else rope_f;

        var cur = g4Norm(ctx, inpL, getT(m, "blk.{d}.attn_norm.weight", .{il}, &nb), d.eps);
        var Q = c.ggml_mul_mat(ctx, getT(m, "blk.{d}.attn_q.weight", .{il}, &nb), cur).?;
        Q = c.ggml_reshape_3d(ctx, Q, @intCast(hd), @intCast(d.h), @intCast(n)).?;
        Q = g4Norm(ctx, Q, getT(m, "blk.{d}.attn_q_norm.weight", .{il}, &nb), d.eps);
        Q = c.ggml_rope_ext(ctx, Q, positions, ff, @intCast(hd), c.GGML_ROPE_TYPE_NEOX, d.n_ctx_train, base, 1.0, 0.0, 1.0, 0.0, 0.0).?;

        const src = g4Src(d, il);
        const kt = g_kt.items[src];
        const vt = g_vt.items[src];
        if (il < d.own) {
            var K = c.ggml_mul_mat(ctx, getT(m, "blk.{d}.attn_k.weight", .{il}, &nb), cur).?;
            const V = if (getTOpt(m, "blk.{d}.attn_v.weight", .{il}, &nb2)) |wv| c.ggml_mul_mat(ctx, wv, cur).? else K;
            K = c.ggml_reshape_3d(ctx, K, @intCast(hd), @intCast(d.kv), @intCast(n)).?;
            K = g4Norm(ctx, K, getT(m, "blk.{d}.attn_k_norm.weight", .{il}, &nb), d.eps);
            K = c.ggml_rope_ext(ctx, K, positions, ff, @intCast(hd), c.GGML_ROPE_TYPE_NEOX, d.n_ctx_train, base, 1.0, 0.0, 1.0, 0.0, 0.0).?;
            var V3 = c.ggml_reshape_3d(ctx, V, @intCast(hd), @intCast(d.kv), @intCast(n)).?;
            V3 = c.ggml_rms_norm(ctx, V3, d.eps).?;
            const Kcur = c.ggml_cont(ctx, c.ggml_permute(ctx, K, 0, 2, 1, 3)).?; // [hd, n, kv]
            const Vcur = c.ggml_cont(ctx, c.ggml_permute(ctx, V3, 0, 2, 1, 3)).?;
            const kview = c.ggml_view_3d(ctx, kt, @intCast(hd), @intCast(n), @intCast(d.kv), kt.*.nb[1], kt.*.nb[2], n_past * kt.*.nb[1]).?;
            const vview = c.ggml_view_3d(ctx, vt, @intCast(n), @intCast(hd), @intCast(d.kv), vt.*.nb[1], vt.*.nb[2], n_past * vt.*.nb[0]).?;
            kouts.append(gpa, c.ggml_cpy(ctx, Kcur, kview).?) catch return null;
            kouts.append(gpa, c.ggml_cpy(ctx, c.ggml_permute(ctx, Vcur, 1, 0, 2, 3), vview).?) catch return null;
        }
        const K_all = c.ggml_view_3d(ctx, kt, @intCast(hd), @intCast(kv_len), @intCast(d.kv), kt.*.nb[1], kt.*.nb[2], 0).?;
        const Vt = c.ggml_view_3d(ctx, vt, @intCast(kv_len), @intCast(hd), @intCast(d.kv), vt.*.nb[1], vt.*.nb[2], 0).?;
        const Qp = c.ggml_cont(ctx, c.ggml_permute(ctx, Q, 0, 2, 1, 3)).?; // [hd, n, h]
        const Qv = c.ggml_reshape_3d(ctx, Qp, @intCast(hd), @intCast(n * grp), @intCast(d.kv)).?;
        var KQ = c.ggml_mul_mat(ctx, K_all, Qv).?;
        KQ = c.ggml_soft_max_ext(ctx, KQ, if (is_swa) mask_s else mask_g, 1.0, 0.0).?;
        var KQV = c.ggml_mul_mat(ctx, Vt, KQ).?;
        KQV = c.ggml_reshape_3d(ctx, KQV, @intCast(hd), @intCast(n), @intCast(d.h)).?;
        KQV = c.ggml_cont(ctx, c.ggml_permute(ctx, KQV, 0, 2, 1, 3)).?;
        KQV = c.ggml_reshape_2d(ctx, KQV, @intCast(hd * d.h), @intCast(n)).?;
        cur = c.ggml_mul_mat(ctx, getT(m, "blk.{d}.attn_output.weight", .{il}, &nb), KQV).?;
        cur = g4Norm(ctx, cur, getT(m, "blk.{d}.post_attention_norm.weight", .{il}, &nb), d.eps);
        const attn_out = c.ggml_add(ctx, cur, inpL).?;

        // the GELU-gated feed-forward, normed before and after
        var h2 = g4Norm(ctx, attn_out, getT(m, "blk.{d}.ffn_norm.weight", .{il}, &nb), d.eps);
        const up = c.ggml_mul_mat(ctx, getT(m, "blk.{d}.ffn_up.weight", .{il}, &nb), h2).?;
        const gate = c.ggml_gelu(ctx, c.ggml_mul_mat(ctx, getT(m, "blk.{d}.ffn_gate.weight", .{il}, &nb), h2).?).?;
        h2 = c.ggml_mul_mat(ctx, getT(m, "blk.{d}.ffn_down.weight", .{il}, &nb), c.ggml_mul(ctx, gate, up).?).?;
        h2 = g4Norm(ctx, h2, getT(m, "blk.{d}.post_ffw_norm.weight", .{il}, &nb), d.eps);
        cur = c.ggml_add(ctx, h2, attn_out).?;

        // the per-layer embedding branch
        var pe = c.ggml_gelu(ctx, c.ggml_mul_mat(ctx, getT(m, "blk.{d}.inp_gate.weight", .{il}, &nb), cur).?).?;
        const slice = c.ggml_view_2d(ctx, ple, @intCast(P), @intCast(n), ple.*.nb[1], il * ple.*.nb[2]).?;
        pe = c.ggml_mul(ctx, pe, slice).?;
        pe = c.ggml_mul_mat(ctx, getT(m, "blk.{d}.proj.weight", .{il}, &nb), pe).?;
        pe = g4Norm(ctx, pe, getT(m, "blk.{d}.post_norm.weight", .{il}, &nb), d.eps);
        cur = c.ggml_add(ctx, cur, pe).?;

        if (getTOpt(m, "blk.{d}.layer_output_scale.weight", .{il}, &nb2)) |os| cur = c.ggml_mul(ctx, cur, os).?;
        inpL = cur;
    }

    const xF = g4Norm(ctx, inpL, getT(m, "output_norm.weight", .{}, &nb), d.eps);
    const n_out: usize = @max(1, @min(g_rows_out, n));
    const last = c.ggml_cont(ctx, c.ggml_view_2d(ctx, xF, @intCast(D), @intCast(n_out), xF.*.nb[1], @intCast((n - n_out) * xF.*.nb[1])).?).?;
    const lm_w = getTOpt(m, "output.weight", .{}, &nb) orelse getT(m, "token_embd.weight", .{}, &nb);
    var logits = c.ggml_mul_mat(ctx, lm_w, last).?;
    if (d.softcap > 0) {
        logits = c.ggml_scale(ctx, logits, 1.0 / d.softcap).?;
        logits = c.ggml_tanh(ctx, logits).?;
        logits = c.ggml_scale(ctx, logits, d.softcap).?;
    }
    const graph = c.ggml_new_graph_custom(ctx, decode_graph_nodes, false) orelse return null;
    for (kouts.items) |t| c.ggml_build_forward_expand(graph, t);
    c.ggml_build_forward_expand(graph, logits);
    return .{ .graph = graph, .logits = logits };
}

fn forwardGemma4(ids: []const i32) bool {
    const m = mctx() orelse return false;
    const n_new = ids.len;
    if (n_new == 0 or !g4Ok(m)) return false;
    const d = &g_g4;
    for (ids) |t| if (t < 0 or t >= d.rows) return false;
    if (!ensureKv(d.own, d.kv, d.hd_g, padKv(g_n_past + n_new))) return false;
    const n_past = g_n_past;
    var kouts: std.ArrayList(*c.ggml_tensor) = .{};
    defer kouts.clearAndFree(gpa);

    var tp = std.time.nanoTimestamp();
    var pool_bytes: usize = 0;
    {
        const meta = c.ggml_init(.{ .mem_size = 64 * 1024 * 1024, .mem_buffer = null, .no_alloc = true }) orelse return false;
        defer c.ggml_free(meta);
        if (buildGemma4Graph(meta, m, ids, d, n_past, false, &kouts) == null) return false;
        pool_bytes = graphPoolBytes(meta);
    }
    kouts.clearRetainingCapacity();
    g_last_pool_bytes = pool_bytes;
    g_phase[0] = msSince(tp);
    tp = std.time.nanoTimestamp();
    const ctx = c.ggml_init(.{ .mem_size = pool_bytes + 64 * 1024, .mem_buffer = null, .no_alloc = false }) orelse return false;
    defer c.ggml_free(ctx);
    g_phase[1] = msSince(tp);
    tp = std.time.nanoTimestamp();
    const built = buildGemma4Graph(ctx, m, ids, d, n_past, true, &kouts) orelse return false;
    g_phase[2] = msSince(tp);
    tp = std.time.nanoTimestamp();
    var plan = c.ggml_graph_plan(built.graph, if (n_new > 1) g_threads_many else g_threads_one, null);
    var wbuf: ?[]u8 = null;
    if (plan.work_size > 0) {
        wbuf = gpa.alloc(u8, plan.work_size) catch return false;
        plan.work_data = wbuf.?.ptr;
    }
    defer if (wbuf) |w| gpa.free(w);
    _ = c.ggml_graph_compute(built.graph, &plan);
    g_phase[3] = msSince(tp);
    g_n_past = n_past + n_new;
    kvIdsSet(n_past, ids, false);
    return readLogits(built.logits);
}

// the logits of the last row into g_logits, and each row's best token into g_row_best when there are several
fn readLogits(logits: *c.ggml_tensor) bool {
    const tp = std.time.nanoTimestamp();
    const n_vocab_t: usize = @intCast(logits.*.ne[0]);
    const n_rows: usize = @intCast(logits.*.ne[1]);
    const ld_all: [*]const f32 = @ptrCast(@alignCast(logits.*.data));
    g_row_best.clearRetainingCapacity();
    if (n_rows > 1) {
        g_row_best.ensureTotalCapacity(gpa, n_rows) catch return false;
        for (0..n_rows) |r| {
            const row = ld_all[r * n_vocab_t ..][0..n_vocab_t];
            var best: usize = 0;
            var bestv: f32 = -3.4e38;
            for (row, 0..) |v, i| {
                if (v > bestv) {
                    bestv = v;
                    best = i;
                }
            }
            g_row_best.appendAssumeCapacity(@intCast(best));
        }
    }
    const ld = ld_all + (n_rows - 1) * n_vocab_t;
    g_logits.clearRetainingCapacity();
    g_logits.ensureTotalCapacity(gpa, n_vocab_t) catch return false;
    for (0..n_vocab_t) |i| g_logits.appendAssumeCapacity(ld[i]);
    g_phase[5] = msSince(tp);
    return true;
}

// ---- the LLAMA3 pre-tokenizer (tokenizer.ggml.pre = "lfm2"; RADAR-LFM3-FAMILY-01, 2026-11-11) -----------------------
//
// LFM3's tokenizer is byte-level BPE, as GPT-2's, but its text is cut into pieces by the LLAMA3 pattern, which
// llama.cpp b12283 maps "lfm2" to (with ignore_merges and BOS forced on): Unicode letters, not ASCII only; digits in
// threes; contractions; and its own whitespace rules. bpeSegment approximates GPT-2's cut and stays the cut of the
// families already guarded; this one is exact, alternative by alternative, in the pattern's order:
//   (?:'[sS]|'[tT]|'[rR][eE]|'[vV][eE]|'[mM]|'[lL][lL]|'[dD])|[^\r\n\p{L}\p{N}]?\p{L}+|\p{N}{1,3}|
//    ?[^\s\p{L}\p{N}]+[\r\n]*|\s*[\r\n]+|\s+(?!\S)|\s+
// A piece the vocabulary holds whole is that token (ignore_merges); any other goes through the merges.

var g_pre_llama3: bool = false;

fn l3Nl(cp: u21) bool {
    return cp == '\r' or cp == '\n';
}

// the length in bytes of the piece the pattern matches at text[i..]
fn llama3PieceLen(t: []const u8, i: usize) usize {
    const c0 = clip.cpAt(t, i);
    const cp = c0.cp;
    // 1: a contraction
    if (cp == '\'' and i + 1 < t.len) {
        const a = std.ascii.toLower(t[i + 1]);
        if (a == 's' or a == 't' or a == 'm' or a == 'd') return 2;
        if (i + 2 < t.len) {
            const b = std.ascii.toLower(t[i + 2]);
            if ((a == 'r' and b == 'e') or (a == 'v' and b == 'e') or (a == 'l' and b == 'l')) return 3;
        }
    }
    // 2: [^\r\n\p{L}\p{N}]? \p{L}+
    {
        var j = i;
        if (!clip.isLetterCp(cp) and !clip.isNumberCp(cp) and !l3Nl(cp) and i + c0.len < t.len and clip.isLetterCp(clip.cpAt(t, i + c0.len).cp)) j = i + c0.len;
        if (clip.isLetterCp(clip.cpAt(t, j).cp)) {
            while (j < t.len and clip.isLetterCp(clip.cpAt(t, j).cp)) j += clip.cpAt(t, j).len;
            return j - i;
        }
    }
    // 3: \p{N}{1,3}
    if (clip.isNumberCp(cp)) {
        var j = i;
        var k: usize = 0;
        while (j < t.len and k < 3 and clip.isNumberCp(clip.cpAt(t, j).cp)) : (k += 1) j += clip.cpAt(t, j).len;
        return j - i;
    }
    // 4: ' '? [^\s\p{L}\p{N}]+ [\r\n]*
    {
        var j = i;
        if (cp == ' ') j += 1;
        const st = j;
        while (j < t.len) {
            const x = clip.cpAt(t, j);
            if (clip.isSpaceCp(x.cp) or clip.isLetterCp(x.cp) or clip.isNumberCp(x.cp)) break;
            j += x.len;
        }
        if (j > st) {
            while (j < t.len and (t[j] == '\r' or t[j] == '\n')) j += 1;
            return j - i;
        }
    }
    if (clip.isSpaceCp(cp)) {
        // the whitespace run, and where its last newline ends
        var w = i;
        var last_nl: usize = 0;
        var last_len: usize = 0;
        while (w < t.len) {
            const x = clip.cpAt(t, w);
            if (!clip.isSpaceCp(x.cp)) break;
            if (l3Nl(x.cp)) last_nl = w + x.len;
            last_len = x.len;
            w += x.len;
        }
        // 5: \s*[\r\n]+ -- up to the run's last newline
        if (last_nl > i) return last_nl - i;
        // 6: \s+(?!\S) -- all of it at the end of the text, else all but its last character
        if (w == t.len) return w - i;
        if (w - i > last_len) return w - i - last_len;
        // 7: \s+
        return w - i;
    }
    // anything else (an unpaired byte): one codepoint
    return c0.len;
}

fn llama3Segment(text: []const u8, out: *std.ArrayList(i32)) void {
    var mapped: std.ArrayList(u8) = .{};
    defer mapped.clearAndFree(gpa);
    var i: usize = 0;
    while (i < text.len) {
        const n = @max(1, llama3PieceLen(text, i));
        const piece = text[i..@min(text.len, i + n)];
        i += n;
        // ignore_merges: a piece the vocabulary holds whole is that one token
        mapped.clearRetainingCapacity();
        for (piece) |b| {
            var ub: [4]u8 = undefined;
            const un = std.unicode.utf8Encode(g_b2u[b], &ub) catch continue;
            mapped.appendSlice(gpa, ub[0..un]) catch return;
        }
        if (g_tok_map.get(mapped.items)) |id| {
            out.append(gpa, id) catch {};
            continue;
        }
        bpeWord(piece, out);
    }
}

// ---- the LFM3 decoder (general.architecture = "lfm3"; RADAR-LFM3-FAMILY-01, 2026-11-11) ---------------------------
//
// Liquid AI's LFM3, wired as llama.cpp b12283 wires it (src/models/lfm3.cpp and lfm-base.cpp, read line by line):
//   - layers of two kinds, by the file's per-layer head_count_kv: 0 is a SHORT CONVOLUTION, more is ATTENTION
//     (sliding or global by the file's pattern);
//   - a convolution layer: in_proj gives b, c and x; b*x goes through a causal convolution of width l_cache (7) per
//     channel; c times that; out_proj. Its state is the last l_cache-1 values of b*x, so the engine KEEPS b*x for every
//     position, in a cache shaped as the attention's (g_cv, one [cap, n_embd] tensor a layer, l_cache-1 zero rows
//     first): reuse of a prefix, a rollback and a drafter's cut work on it exactly as on K and V;
//   - an attention layer: Q and K RMS-normed per head with weights, V not; NEOX rope over the whole head, the global
//     layers with the file's frequency factors (half the head turns); scale 1/sqrt(head); every head's output scaled by
//     sigmoid(attn_gate x) -- the gate reads the block's normed input;
//   - norms after each block when the file has them (both or neither); a SiLU-gated feed-forward; no logit cap; the
//     token rows not scaled. A decision model (attention.causal = false) is the other graph: refused here.
// THE CONTRACT, before ggml sees a tensor, as for Gemma 4: every tensor present and shaped to the file's own sizes.

const L3 = struct {
    n_layer: usize,
    d: usize,
    h: usize,
    kv: usize,
    hd: usize,
    f: usize,
    dconv: usize, // l_cache - 1
    window: usize,
    base_g: f32,
    base_s: f32,
    eps: f32,
    n_ctx_train: c_int,
    rows: i64,
    n_attn: usize,
    n_conv: usize,
    post: bool,
    attn: [256]bool,
    swa: [256]bool,
    idx: [256]usize, // the layer's slot in its kind's cache
};

var g_l3_gen: usize = std.math.maxInt(usize);
var g_l3_ok: bool = false;
var g_l3: L3 = undefined;

fn isLfm3() bool {
    return std.mem.eql(u8, archName(), "lfm3");
}

fn l3Key(suffix: []const u8, buf: *[96]u8) ?[*:0]const u8 {
    const k = std.fmt.bufPrintZ(buf, "{s}{s}", .{ archName(), suffix }) catch return null;
    return k.ptr;
}

fn l3Read(m: ?*c.ggml_context) ?L3 {
    const ctx = gguf() orelse return null;
    var d: L3 = undefined;
    var kb: [96]u8 = undefined;
    const L = kvArchInt(".block_count", 0);
    if (L < 2 or L > 256) return null;
    d.n_layer = @intCast(L);
    d.d = @intCast(@max(0, kvArchInt(".embedding_length", 0)));
    d.h = @intCast(@max(0, kvArchInt(".attention.head_count", 0)));
    d.hd = @intCast(@max(0, kvArchInt(".attention.key_length", 0)));
    d.f = @intCast(@max(0, kvArchInt(".feed_forward_length", 0)));
    const lc = kvArchInt(".shortconv.l_cache", 0);
    if (lc < 2 or lc > 64) return null;
    d.dconv = @intCast(lc - 1);
    d.window = @intCast(@max(0, kvArchInt(".attention.sliding_window", 0)));
    if (d.d == 0 or d.h == 0 or d.hd == 0 or d.f == 0 or d.window == 0) return null;
    if (d.d > 1 << 16 or d.f > 1 << 18 or d.hd > 4096 or d.h > 1024) return null;
    if (kvArchInt(".attention.value_length", @intCast(d.hd)) != d.hd) return null;
    if (kvArchInt(".rope.dimension_count", @intCast(d.hd)) != d.hd) return null;
    // the decision variant (non-causal attention) is another graph
    if (gr.find(ctx, l3Key(".attention.causal", &kb) orelse return null) >= 0 and !gr.boolOr(ctx, l3Key(".attention.causal", &kb).?, true)) return null;
    d.base_g = kvArchF32(".rope.freq_base", 10000.0);
    d.base_s = kvArchF32(".rope.freq_base_swa", 10000.0);
    d.eps = kvArchF32(".attention.layer_norm_rms_epsilon", 1e-5);
    if (!(d.eps >= 0) or !(d.base_g > 0) or !(d.base_s > 0)) return null;
    d.n_ctx_train = @intCast(std.math.clamp(kvArchInt(".context_length", 2048), 1, 1 << 24));
    // the per-layer kv heads (0: a convolution) and the sliding pattern
    const kid = gr.find(ctx, l3Key(".attention.head_count_kv", &kb) orelse return null);
    var kvs: [256]i64 = undefined;
    if (gr.arrOf(u32, ctx, kid)) |a| {
        if (a.len != d.n_layer) return null;
        for (a, 0..) |x, i| kvs[i] = x;
    } else if (gr.arrOf(i32, ctx, kid)) |a| {
        if (a.len != d.n_layer) return null;
        for (a, 0..) |x, i| kvs[i] = x;
    } else return null;
    const pat = gr.arrBool(ctx, gr.find(ctx, l3Key(".attention.sliding_window_pattern", &kb) orelse return null)) orelse return null;
    if (pat.len != d.n_layer) return null;
    d.kv = 0;
    d.n_attn = 0;
    d.n_conv = 0;
    for (0..d.n_layer) |i| {
        d.swa[i] = pat[i] != 0;
        if (kvs[i] < 0) return null;
        d.attn[i] = kvs[i] > 0;
        if (d.attn[i]) {
            if (d.kv == 0) d.kv = @intCast(kvs[i]) else if (kvs[i] != d.kv) return null;
            d.idx[i] = d.n_attn;
            d.n_attn += 1;
        } else {
            if (d.swa[i]) return null;
            d.idx[i] = d.n_conv;
            d.n_conv += 1;
        }
    }
    if (d.n_attn == 0 or d.kv == 0 or d.h % d.kv != 0) return null;

    const D = d.d;
    var nb: [96]u8 = undefined;
    const te = getTOpt(m, "token_embd.weight", .{}, &nb) orelse return null;
    if (te.*.ne[0] != D or te.*.ne[1] < 1 or te.*.ne[2] != 1) return null;
    d.rows = te.*.ne[1];
    const V: usize = @intCast(d.rows);
    if (getTOpt(m, "output.weight", .{}, &nb) != null and !g4Mat(m, "output.weight", .{}, D, V)) return null;
    if (!g4Vec(m, "output_norm.weight", .{}, D)) return null;
    d.post = getTOpt(m, "blk.0.post_attention_norm.weight", .{}, &nb) != null;
    for (0..d.n_layer) |il| {
        if (!g4Vec(m, "blk.{d}.attn_norm.weight", .{il}, D) or !g4Vec(m, "blk.{d}.ffn_norm.weight", .{il}, D)) return null;
        if (d.post) {
            if (!g4Vec(m, "blk.{d}.post_attention_norm.weight", .{il}, D) or !g4Vec(m, "blk.{d}.post_ffw_norm.weight", .{il}, D)) return null;
        } else if (getTOpt(m, "blk.{d}.post_attention_norm.weight", .{il}, &nb) != null or getTOpt(m, "blk.{d}.post_ffw_norm.weight", .{il}, &nb) != null) return null;
        if (!g4Mat(m, "blk.{d}.ffn_gate.weight", .{il}, D, d.f) or !g4Mat(m, "blk.{d}.ffn_up.weight", .{il}, D, d.f)) return null;
        if (!g4Mat(m, "blk.{d}.ffn_down.weight", .{il}, d.f, D)) return null;
        if (d.attn[il]) {
            if (!g4Mat(m, "blk.{d}.attn_q.weight", .{il}, D, d.h * d.hd) or !g4Mat(m, "blk.{d}.attn_k.weight", .{il}, D, d.kv * d.hd)) return null;
            if (!g4Mat(m, "blk.{d}.attn_v.weight", .{il}, D, d.kv * d.hd) or !g4Mat(m, "blk.{d}.attn_output.weight", .{il}, d.h * d.hd, D)) return null;
            if (!g4Vec(m, "blk.{d}.attn_q_norm.weight", .{il}, d.hd) or !g4Vec(m, "blk.{d}.attn_k_norm.weight", .{il}, d.hd)) return null;
            if (!g4Mat(m, "blk.{d}.attn_gate.weight", .{il}, D, d.h)) return null;
            if (!d.swa[il] and !g4Vec(m, "rope_freqs.weight", .{}, d.hd / 2)) return null;
        } else {
            const cw = getTOpt(m, "blk.{d}.shortconv.conv.weight", .{il}, &nb) orelse return null;
            if (cw.*.type != c.GGML_TYPE_F32 or cw.*.ne[0] != d.dconv + 1 or cw.*.ne[1] != D or cw.*.ne[2] != 1) return null;
            if (!g4Mat(m, "blk.{d}.shortconv.in_proj.weight", .{il}, D, 3 * D) or !g4Mat(m, "blk.{d}.shortconv.out_proj.weight", .{il}, D, D)) return null;
        }
    }
    return d;
}

fn l3Ok(m: ?*c.ggml_context) bool {
    if (g_l3_gen != embed.model_generation) {
        g_l3_gen = embed.model_generation;
        if (l3Read(m)) |d| {
            g_l3 = d;
            g_l3_ok = true;
        } else g_l3_ok = false;
    }
    return g_l3_ok;
}

// the convolution cache: one [cap, n_embd] tensor a convolution layer, its first dconv rows always zero
var g_cvctx: ?*c.ggml_context = null;
var g_cv: std.ArrayList(*c.ggml_tensor) = .{};
var g_cv_cap: usize = 0;
var g_cv_shape: [2]usize = .{ 0, 0 }; // n_embd, dconv

fn resetConv() void {
    if (g_cvctx) |k| c.ggml_free(k);
    g_cvctx = null;
    g_cv.clearAndFree(gpa);
    g_cv_cap = 0;
    g_cv_shape = .{ 0, 0 };
}

fn ensureConv(n_conv: usize, d: usize, dconv: usize, need: usize) bool {
    if (g_cv.items.len == n_conv and g_cv_shape[0] == d and g_cv_shape[1] == dconv and g_cv_cap >= need) return true;
    if (g_cv.items.len != 0 and (g_cv.items.len != n_conv or g_cv_shape[0] != d or g_cv_shape[1] != dconv)) resetConv();
    var cap: usize = if (g_cv_cap == 0) 256 else g_cv_cap;
    while (cap < need) cap *= 2;
    const bytes = n_conv * (cap * d * 4 + c.ggml_tensor_overhead() + 128) + 65536;
    const nctx = c.ggml_init(.{ .mem_size = bytes, .mem_buffer = null, .no_alloc = false }) orelse return false;
    @memset(@as([*]u8, @ptrCast(c.ggml_get_mem_buffer(nctx).?))[0..c.ggml_get_mem_size(nctx)], 0);
    var nt: std.ArrayList(*c.ggml_tensor) = .{};
    for (0..n_conv) |_| {
        const t = c.ggml_new_tensor_2d(nctx, c.GGML_TYPE_F32, @intCast(cap), @intCast(d)) orelse {
            nt.clearAndFree(gpa);
            c.ggml_free(nctx);
            return false;
        };
        nt.append(gpa, t) catch {
            nt.clearAndFree(gpa);
            c.ggml_free(nctx);
            return false;
        };
    }
    if (g_cvctx != null and g_cv.items.len == n_conv) {
        const keep = dconv + g_n_past; // the zero rows and every position held
        for (0..n_conv) |L| {
            const o: [*]const f32 = @ptrCast(@alignCast(g_cv.items[L].*.data));
            const n_: [*]f32 = @ptrCast(@alignCast(nt.items[L].*.data));
            for (0..d) |ch| @memcpy(n_[cap * ch ..][0..@min(keep, g_cv_cap)], o[g_cv_cap * ch ..][0..@min(keep, g_cv_cap)]);
        }
    }
    if (g_cvctx) |old| c.ggml_free(old);
    g_cv.deinit(gpa);
    g_cv = nt;
    g_cvctx = nctx;
    g_cv_cap = cap;
    g_cv_shape = .{ d, dconv };
    return true;
}

fn buildLfm3Graph(
    ctx: *c.ggml_context,
    m: ?*c.ggml_context,
    ids: []const i32,
    d: *const L3,
    n_past: usize,
    fill: bool,
    kouts: *std.ArrayList(*c.ggml_tensor),
) ?DecodeGraph {
    const n = ids.len;
    const kv_len = padKv(n_past + n);
    const grp = d.h / d.kv;
    const D = d.d;
    const hd = d.hd;
    var nb: [96]u8 = undefined;
    var nb2: [96]u8 = undefined;

    const tokens = c.ggml_new_tensor_1d(ctx, c.GGML_TYPE_I32, @intCast(n)).?;
    const positions = c.ggml_new_tensor_1d(ctx, c.GGML_TYPE_I32, @intCast(n)).?;
    const mask_g = c.ggml_new_tensor_2d(ctx, c.GGML_TYPE_F32, @intCast(kv_len), @intCast(n * grp)).?;
    const mask_s = c.ggml_new_tensor_2d(ctx, c.GGML_TYPE_F32, @intCast(kv_len), @intCast(n * grp)).?;
    if (fill) {
        const td: [*]i32 = @ptrCast(@alignCast(tokens.*.data));
        const pd: [*]i32 = @ptrCast(@alignCast(positions.*.data));
        for (0..n) |i| {
            td[i] = ids[i];
            pd[i] = @intCast(n_past + i);
        }
        const mg: [*]f32 = @ptrCast(@alignCast(mask_g.*.data));
        const ms: [*]f32 = @ptrCast(@alignCast(mask_s.*.data));
        for (0..n * grp) |x| {
            const q = n_past + x % n;
            for (0..kv_len) |k| {
                const seen = k <= q;
                mg[x * kv_len + k] = if (seen) 0.0 else -1.0e9;
                ms[x * kv_len + k] = if (seen and q - k < d.window) 0.0 else -1.0e9;
            }
        }
    }

    var inpL = c.ggml_get_rows(ctx, getT(m, "token_embd.weight", .{}, &nb), tokens).?;
    const rope_f = getTOpt(m, "rope_freqs.weight", .{}, &nb2);
    const scale: f32 = 1.0 / @sqrt(@as(f32, @floatFromInt(hd)));
    for (0..d.n_layer) |il| {
        const cur_in = g4Norm(ctx, inpL, getT(m, "blk.{d}.attn_norm.weight", .{il}, &nb), d.eps);
        var cur: *c.ggml_tensor = undefined;
        if (d.attn[il]) {
            const is_swa = d.swa[il];
            const base = if (is_swa) d.base_s else d.base_g;
            const ff: ?*c.ggml_tensor = if (is_swa) null else rope_f;
            var Q = c.ggml_mul_mat(ctx, getT(m, "blk.{d}.attn_q.weight", .{il}, &nb), cur_in).?;
            Q = c.ggml_reshape_3d(ctx, Q, @intCast(hd), @intCast(d.h), @intCast(n)).?;
            Q = g4Norm(ctx, Q, getT(m, "blk.{d}.attn_q_norm.weight", .{il}, &nb), d.eps);
            Q = c.ggml_rope_ext(ctx, Q, positions, ff, @intCast(hd), c.GGML_ROPE_TYPE_NEOX, d.n_ctx_train, base, 1.0, 0.0, 1.0, 0.0, 0.0).?;
            var K = c.ggml_mul_mat(ctx, getT(m, "blk.{d}.attn_k.weight", .{il}, &nb), cur_in).?;
            K = c.ggml_reshape_3d(ctx, K, @intCast(hd), @intCast(d.kv), @intCast(n)).?;
            K = g4Norm(ctx, K, getT(m, "blk.{d}.attn_k_norm.weight", .{il}, &nb), d.eps);
            K = c.ggml_rope_ext(ctx, K, positions, ff, @intCast(hd), c.GGML_ROPE_TYPE_NEOX, d.n_ctx_train, base, 1.0, 0.0, 1.0, 0.0, 0.0).?;
            const V = c.ggml_reshape_3d(ctx, c.ggml_mul_mat(ctx, getT(m, "blk.{d}.attn_v.weight", .{il}, &nb), cur_in).?, @intCast(hd), @intCast(d.kv), @intCast(n)).?;
            const kt = g_kt.items[d.idx[il]];
            const vt = g_vt.items[d.idx[il]];
            const Kcur = c.ggml_cont(ctx, c.ggml_permute(ctx, K, 0, 2, 1, 3)).?;
            const Vcur = c.ggml_cont(ctx, c.ggml_permute(ctx, V, 0, 2, 1, 3)).?;
            const kview = c.ggml_view_3d(ctx, kt, @intCast(hd), @intCast(n), @intCast(d.kv), kt.*.nb[1], kt.*.nb[2], n_past * kt.*.nb[1]).?;
            const vview = c.ggml_view_3d(ctx, vt, @intCast(n), @intCast(hd), @intCast(d.kv), vt.*.nb[1], vt.*.nb[2], n_past * vt.*.nb[0]).?;
            kouts.append(gpa, c.ggml_cpy(ctx, Kcur, kview).?) catch return null;
            kouts.append(gpa, c.ggml_cpy(ctx, c.ggml_permute(ctx, Vcur, 1, 0, 2, 3), vview).?) catch return null;
            const K_all = c.ggml_view_3d(ctx, kt, @intCast(hd), @intCast(kv_len), @intCast(d.kv), kt.*.nb[1], kt.*.nb[2], 0).?;
            const Vt = c.ggml_view_3d(ctx, vt, @intCast(kv_len), @intCast(hd), @intCast(d.kv), vt.*.nb[1], vt.*.nb[2], 0).?;
            const Qp = c.ggml_cont(ctx, c.ggml_permute(ctx, Q, 0, 2, 1, 3)).?;
            const Qv = c.ggml_reshape_3d(ctx, Qp, @intCast(hd), @intCast(n * grp), @intCast(d.kv)).?;
            var KQ = c.ggml_mul_mat(ctx, K_all, Qv).?;
            KQ = c.ggml_soft_max_ext(ctx, KQ, if (is_swa) mask_s else mask_g, scale, 0.0).?;
            var KQV = c.ggml_mul_mat(ctx, Vt, KQ).?;
            KQV = c.ggml_reshape_3d(ctx, KQV, @intCast(hd), @intCast(n), @intCast(d.h)).?;
            KQV = c.ggml_cont(ctx, c.ggml_permute(ctx, KQV, 0, 2, 1, 3)).?; // [hd, h, n]
            // every head's output scaled by sigmoid(attn_gate x)
            var gate = c.ggml_sigmoid(ctx, c.ggml_mul_mat(ctx, getT(m, "blk.{d}.attn_gate.weight", .{il}, &nb), cur_in).?).?;
            gate = c.ggml_reshape_3d(ctx, gate, 1, @intCast(d.h), @intCast(n)).?;
            KQV = c.ggml_mul(ctx, KQV, gate).?;
            KQV = c.ggml_reshape_2d(ctx, KQV, @intCast(hd * d.h), @intCast(n)).?;
            cur = c.ggml_mul_mat(ctx, getT(m, "blk.{d}.attn_output.weight", .{il}, &nb), KQV).?;
        } else {
            const bcx = c.ggml_mul_mat(ctx, getT(m, "blk.{d}.shortconv.in_proj.weight", .{il}, &nb), cur_in).?; // [3D, n]
            const es = c.ggml_element_size(bcx);
            const b = c.ggml_view_2d(ctx, bcx, @intCast(D), @intCast(n), bcx.*.nb[1], 0).?;
            const cc = c.ggml_view_2d(ctx, bcx, @intCast(D), @intCast(n), bcx.*.nb[1], D * es).?;
            const x = c.ggml_view_2d(ctx, bcx, @intCast(D), @intCast(n), bcx.*.nb[1], 2 * D * es).?;
            const bxT = c.ggml_cont(ctx, c.ggml_transpose(ctx, c.ggml_mul(ctx, b, x).?).?).?; // [n, D]
            const ct = g_cv.items[d.idx[il]];
            const cview = c.ggml_view_2d(ctx, ct, @intCast(n), @intCast(D), ct.*.nb[1], (d.dconv + n_past) * ct.*.nb[0]).?;
            kouts.append(gpa, c.ggml_cpy(ctx, bxT, cview).?) catch return null;
            // the window: the dconv values before this read and the n it writes (the cache's zero rows stand before position 0)
            const win = c.ggml_cont(ctx, c.ggml_view_2d(ctx, ct, @intCast(d.dconv + n), @intCast(D), ct.*.nb[1], n_past * ct.*.nb[0]).?).?;
            const sx = c.ggml_reshape_3d(ctx, win, @intCast(d.dconv + n), @intCast(D), 1).?;
            const conv = c.ggml_ssm_conv(ctx, sx, getT(m, "blk.{d}.shortconv.conv.weight", .{il}, &nb)).?; // [D, n, 1]
            const y = c.ggml_mul(ctx, cc, c.ggml_reshape_2d(ctx, conv, @intCast(D), @intCast(n)).?).?;
            cur = c.ggml_mul_mat(ctx, getT(m, "blk.{d}.shortconv.out_proj.weight", .{il}, &nb), y).?;
        }
        if (d.post) cur = g4Norm(ctx, cur, getT(m, "blk.{d}.post_attention_norm.weight", .{il}, &nb), d.eps);
        cur = c.ggml_add(ctx, inpL, cur).?;
        const fn_ = g4Norm(ctx, cur, getT(m, "blk.{d}.ffn_norm.weight", .{il}, &nb), d.eps);
        const up = c.ggml_mul_mat(ctx, getT(m, "blk.{d}.ffn_up.weight", .{il}, &nb), fn_).?;
        const gt = c.ggml_silu(ctx, c.ggml_mul_mat(ctx, getT(m, "blk.{d}.ffn_gate.weight", .{il}, &nb), fn_).?).?;
        var ffo = c.ggml_mul_mat(ctx, getT(m, "blk.{d}.ffn_down.weight", .{il}, &nb), c.ggml_mul(ctx, gt, up).?).?;
        if (d.post) ffo = g4Norm(ctx, ffo, getT(m, "blk.{d}.post_ffw_norm.weight", .{il}, &nb), d.eps);
        inpL = c.ggml_add(ctx, cur, ffo).?;
    }

    const xF = g4Norm(ctx, inpL, getT(m, "output_norm.weight", .{}, &nb), d.eps);
    const n_out: usize = @max(1, @min(g_rows_out, n));
    const last = c.ggml_cont(ctx, c.ggml_view_2d(ctx, xF, @intCast(D), @intCast(n_out), xF.*.nb[1], @intCast((n - n_out) * xF.*.nb[1])).?).?;
    const lm_w = getTOpt(m, "output.weight", .{}, &nb) orelse getT(m, "token_embd.weight", .{}, &nb);
    const logits = c.ggml_mul_mat(ctx, lm_w, last).?;
    const graph = c.ggml_new_graph_custom(ctx, decode_graph_nodes, false) orelse return null;
    for (kouts.items) |t| c.ggml_build_forward_expand(graph, t);
    c.ggml_build_forward_expand(graph, logits);
    return .{ .graph = graph, .logits = logits };
}

fn forwardLfm3(ids: []const i32) bool {
    const m = mctx() orelse return false;
    const n_new = ids.len;
    if (n_new == 0 or !l3Ok(m)) return false;
    const d = &g_l3;
    for (ids) |t| if (t < 0 or t >= d.rows) return false;
    if (!ensureKv(d.n_attn, d.kv, d.hd, padKv(g_n_past + n_new))) return false;
    if (d.n_conv > 0 and !ensureConv(d.n_conv, d.d, d.dconv, d.dconv + g_n_past + n_new)) return false;
    const n_past = g_n_past;
    var kouts: std.ArrayList(*c.ggml_tensor) = .{};
    defer kouts.clearAndFree(gpa);
    var tp = std.time.nanoTimestamp();
    var pool_bytes: usize = 0;
    {
        const meta = c.ggml_init(.{ .mem_size = 64 * 1024 * 1024, .mem_buffer = null, .no_alloc = true }) orelse return false;
        defer c.ggml_free(meta);
        if (buildLfm3Graph(meta, m, ids, d, n_past, false, &kouts) == null) return false;
        pool_bytes = graphPoolBytes(meta);
    }
    kouts.clearRetainingCapacity();
    g_last_pool_bytes = pool_bytes;
    g_phase[0] = msSince(tp);
    tp = std.time.nanoTimestamp();
    const ctx = c.ggml_init(.{ .mem_size = pool_bytes + 64 * 1024, .mem_buffer = null, .no_alloc = false }) orelse return false;
    defer c.ggml_free(ctx);
    const built = buildLfm3Graph(ctx, m, ids, d, n_past, true, &kouts) orelse return false;
    g_phase[2] = msSince(tp);
    tp = std.time.nanoTimestamp();
    var plan = c.ggml_graph_plan(built.graph, if (n_new > 1) g_threads_many else g_threads_one, null);
    var wbuf: ?[]u8 = null;
    if (plan.work_size > 0) {
        wbuf = gpa.alloc(u8, plan.work_size) catch return false;
        plan.work_data = wbuf.?.ptr;
    }
    defer if (wbuf) |w| gpa.free(w);
    _ = c.ggml_graph_compute(built.graph, &plan);
    g_phase[3] = msSince(tp);
    g_n_past = n_past + n_new;
    kvIdsSet(n_past, ids, false);
    return readLogits(built.logits);
}

// ---- SPM-style BPE (tokenizer.ggml.model = "gemma4"; GEMMA4-01, 2026-11-11) -----------------------------------------
//
// Gemma 4's tokenizer is BPE over RAW UTF-8, not GPT-2's byte-to-unicode map: the text's spaces become U+2581 ("▁"),
// no space is prepended, the text splits only into runs of newlines and runs of everything else, and each run merges
// its characters pair by pair, lowest merge rank first (leftmost on a tie) -- the whole line is one word. A piece the
// vocabulary does not hold is written as its bytes, each the token "<0xXX>". This is llama.cpp's llm_tokenizer_bpe
// with LLAMA_VOCAB_PRE_TYPE_GEMMA4 (b12283, src/llama-vocab.cpp), read line by line; the guard compares ids with it.
// A line can be thousands of characters, so the merges run on a priority queue with stale pairs skipped (the
// rescanning loop of bpeWord would be quadratic in the line).

var g_spm: bool = false; // the model in place tokenizes SPM-style (set by buildBpe from tokenizer.ggml.model)

const SpmSym = struct { start: usize, n: usize, prev: isize, next: isize };
const SpmPair = struct { rank: i32, left: usize, right: usize, len: usize };
fn spmPairLess(_: void, a: SpmPair, b: SpmPair) std.math.Order {
    if (a.rank != b.rank) return std.math.order(a.rank, b.rank);
    return std.math.order(a.left, b.left);
}

fn spmUtf8Len(b: u8) usize {
    if (b < 0x80) return 1;
    if (b >> 5 == 0b110) return 2;
    if (b >> 4 == 0b1110) return 3;
    if (b >> 3 == 0b11110) return 4;
    return 1;
}

fn spmRank(word: []const u8, syms: []const SpmSym, l: usize, r: usize, kb: *std.ArrayList(u8)) ?i32 {
    const a = word[syms[l].start..][0..syms[l].n];
    const b = word[syms[r].start..][0..syms[r].n];
    kb.clearRetainingCapacity();
    kb.appendSlice(gpa, a) catch return null;
    kb.append(gpa, ' ') catch return null;
    kb.appendSlice(gpa, b) catch return null;
    return g_merge_map.get(kb.items);
}

fn spmPush(q: *std.PriorityQueue(SpmPair, void, spmPairLess), word: []const u8, syms: []const SpmSym, l: isize, r: isize, kb: *std.ArrayList(u8)) void {
    if (l < 0 or r < 0) return;
    const li: usize = @intCast(l);
    const ri: usize = @intCast(r);
    const rank = spmRank(word, syms, li, ri, kb) orelse return;
    q.add(.{ .rank = rank, .left = li, .right = ri, .len = syms[li].n + syms[ri].n }) catch {};
}

fn spmWord(word: []const u8, out: *std.ArrayList(i32)) void {
    if (word.len == 0) return;
    var syms: std.ArrayList(SpmSym) = .{};
    defer syms.clearAndFree(gpa);
    var off: usize = 0;
    while (off < word.len) {
        const n = @min(word.len - off, spmUtf8Len(word[off]));
        const idx: isize = @intCast(syms.items.len);
        syms.append(gpa, .{ .start = off, .n = n, .prev = idx - 1, .next = if (off + n == word.len) -1 else idx + 1 }) catch return;
        off += n;
    }
    var kb: std.ArrayList(u8) = .{};
    defer kb.clearAndFree(gpa);
    var q = std.PriorityQueue(SpmPair, void, spmPairLess).init(gpa, {});
    defer q.deinit();
    var i: usize = 1;
    while (i < syms.items.len) : (i += 1) spmPush(&q, word, syms.items, @intCast(i - 1), @intCast(i), &kb);
    while (q.removeOrNull()) |p| {
        const s = syms.items;
        // stale: either side was merged away, or grew, since this pair was queued
        if (s[p.left].n == 0 or s[p.right].n == 0) continue;
        if (s[p.left].next != @as(isize, @intCast(p.right)) or s[p.left].n + s[p.right].n != p.len) continue;
        s[p.left].n += s[p.right].n;
        s[p.right].n = 0;
        s[p.left].next = s[p.right].next;
        if (s[p.right].next >= 0) s[@intCast(s[p.right].next)].prev = @intCast(p.left);
        spmPush(&q, word, s, s[p.left].prev, @intCast(p.left), &kb);
        spmPush(&q, word, s, @intCast(p.left), s[p.left].next, &kb);
    }
    // the pieces, in order; a piece the vocabulary lacks becomes its bytes as <0xXX>
    var at: isize = 0;
    while (at >= 0) {
        const sym = syms.items[@intCast(at)];
        at = sym.next;
        if (sym.n == 0) continue;
        const piece = word[sym.start..][0..sym.n];
        if (g_tok_map.get(piece)) |id| {
            out.append(gpa, id) catch {};
        } else {
            const hex = "0123456789ABCDEF";
            for (piece) |ch| {
                const bt = [6]u8{ '<', '0', 'x', hex[ch >> 4], hex[ch & 15], '>' };
                if (g_tok_map.get(bt[0..])) |id| out.append(gpa, id) catch {};
            }
        }
    }
}

fn spmSegment(text: []const u8, out: *std.ArrayList(i32)) void {
    var buf: std.ArrayList(u8) = .{};
    defer buf.clearAndFree(gpa);
    for (text) |b| {
        if (b == ' ') buf.appendSlice(gpa, "\u{2581}") catch return else buf.append(gpa, b) catch return;
    }
    const t = buf.items;
    var i: usize = 0;
    while (i < t.len) {
        const start = i;
        const nl = t[i] == '\n';
        while (i < t.len and (t[i] == '\n') == nl) i += 1;
        const run = t[start..i];
        // a run of newlines that is itself a token is that token (llama.cpp PR 21343); otherwise it merges
        if (nl) {
            if (g_tok_map.get(run)) |id| {
                out.append(gpa, id) catch {};
                continue;
            }
        }
        spmWord(run, out);
    }
}

// one SPM token's text: "<0xXX>" is that byte, U+2581 is a space
fn spmDecodeInto(s: []const u8, out: *std.ArrayList(u8)) void {
    if (s.len == 6 and s[0] == '<' and s[1] == '0' and s[2] == 'x' and s[5] == '>') {
        const v = std.fmt.parseInt(u8, s[3..5], 16) catch {
            out.appendSlice(gpa, s) catch {};
            return;
        };
        out.append(gpa, v) catch {};
        return;
    }
    var k: usize = 0;
    while (k < s.len) {
        if (k + 3 <= s.len and s[k] == 0xE2 and s[k + 1] == 0x96 and s[k + 2] == 0x81) {
            out.append(gpa, ' ') catch {};
            k += 3;
        } else {
            out.append(gpa, s[k]) catch {};
            k += 1;
        }
    }
}

/// The text of the ids the last neural_gen_tokenize produced, decoded as generation decodes (a round trip for a guard).
pub export fn neural_gen_probe_text() callconv(.c) [*c]const u8 {
    g_gen_text.clearRetainingCapacity();
    decodeInto(g_probe_ids.items, &g_gen_text);
    g_gen_text.append(gpa, 0) catch return @ptrCast("");
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
