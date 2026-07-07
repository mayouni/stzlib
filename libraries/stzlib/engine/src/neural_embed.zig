// Softanza Engine -- Neural embeddings (ggml), model loading + inspection
//
// MILESTONE 2a: runtime GGUF model loading -- the capability that defines the
// neural tier (classical models are @embedFile'd; neural models are LARGE and
// load from disk at runtime). Opens a BERT-family GGUF (e.g. all-MiniLM-L6-v2),
// reads its architecture + hyperparameters + tensor inventory. The BERT forward
// pass + WordPiece tokenizer + mean-pooling (-> the embedding vector) is the next
// milestone, built on the model handle established here.

const std = @import("std");
const c = @cImport({
    @cInclude("ggml.h");
    @cInclude("ggml-cpu.h");
    @cInclude("gguf.h");
});

const gpa = std.heap.c_allocator;

// One process-wide loaded model (embedding is a single-model workload for now).
var g_gguf: ?*c.gguf_context = null;
var g_ctx: ?*c.ggml_context = null;
var g_arch: [64]u8 = undefined;
var g_arch_len: usize = 0;

// Load a GGUF model: metadata + WEIGHTS (no_alloc=false makes gguf read the
// tensor blob into the created ggml_context and wire tensor->data). 1 on success.
pub export fn neural_model_load(path: [*c]const u8) callconv(.c) c_int {
    neural_model_free();
    var mctx: ?*c.ggml_context = null;
    const params = c.gguf_init_params{ .no_alloc = false, .ctx = &mctx };
    const ctx = c.gguf_init_from_file(path, params) orelse return 0;
    g_gguf = ctx;
    g_ctx = mctx;
    g_arch_len = 0;
    if (kvStr("general.architecture")) |a| {
        const s = std.mem.span(a);
        const n = @min(s.len, g_arch.len);
        @memcpy(g_arch[0..n], s[0..n]);
        g_arch_len = n;
    }
    return 1;
}

pub export fn neural_model_free() callconv(.c) void {
    if (g_gguf) |x| {
        c.gguf_free(x);
        g_gguf = null;
    }
    if (g_ctx) |x| {
        c.ggml_free(x);
        g_ctx = null;
    }
    g_arch_len = 0;
    freeVocab();
    g_tok_ids.clearAndFree(gpa);
    g_emb.clearAndFree(gpa);
    g_tok_emb.clearAndFree(gpa);
    g_tok_emb_ntok = 0;
    g_tok_emb_ndim = 0;
}

pub export fn neural_model_loaded() callconv(.c) c_int {
    return if (g_gguf != null) 1 else 0;
}

fn kvStr(key: [*:0]const u8) ?[*:0]const u8 {
    const ctx = g_gguf orelse return null;
    const id = c.gguf_find_key(ctx, key);
    if (id < 0) return null;
    return c.gguf_get_val_str(ctx, id);
}

// Integer value for an ARCH-PREFIXED key suffix (".embedding_length" ->
// "bert.embedding_length"). Type-guarded: reads gguf_get_kv_type FIRST (safe) and
// dispatches to the matching getter, so we never call e.g. get_val_u32 on a
// non-scalar/mismatched key (whose get_ne() would divide by a 0 type size).
fn kvArchInt(suffix: []const u8, dflt: i64) i64 {
    const ctx = g_gguf orelse return dflt;
    if (g_arch_len == 0) return dflt;
    var buf: [96]u8 = undefined;
    if (g_arch_len + suffix.len + 1 > buf.len) return dflt;
    @memcpy(buf[0..g_arch_len], g_arch[0..g_arch_len]);
    @memcpy(buf[g_arch_len..][0..suffix.len], suffix);
    buf[g_arch_len + suffix.len] = 0;
    const key: [*:0]const u8 = @ptrCast(&buf[0]);
    const id = c.gguf_find_key(ctx, key);
    if (id < 0) return dflt;
    return switch (c.gguf_get_kv_type(ctx, id)) {
        c.GGUF_TYPE_UINT32 => @intCast(c.gguf_get_val_u32(ctx, id)),
        c.GGUF_TYPE_INT32 => @intCast(c.gguf_get_val_i32(ctx, id)),
        c.GGUF_TYPE_UINT64 => @intCast(c.gguf_get_val_u64(ctx, id)),
        c.GGUF_TYPE_INT64 => c.gguf_get_val_i64(ctx, id),
        c.GGUF_TYPE_UINT16 => @intCast(c.gguf_get_val_u16(ctx, id)),
        else => dflt,
    };
}

pub export fn neural_model_arch() callconv(.c) [*c]const u8 {
    return kvStr("general.architecture") orelse @ptrCast("");
}

pub export fn neural_model_n_embd() callconv(.c) c_int {
    return @intCast(kvArchInt(".embedding_length", 0));
}

pub export fn neural_model_n_layers() callconv(.c) c_int {
    return @intCast(kvArchInt(".block_count", 0));
}

pub export fn neural_model_n_heads() callconv(.c) c_int {
    return @intCast(kvArchInt(".attention.head_count", 0));
}

pub export fn neural_model_n_ctx() callconv(.c) c_int {
    return @intCast(kvArchInt(".context_length", 0));
}

// Vocabulary size = length of the tokenizer.ggml.tokens string array.
pub export fn neural_model_n_vocab() callconv(.c) c_int {
    const ctx = g_gguf orelse return 0;
    const id = c.gguf_find_key(ctx, "tokenizer.ggml.tokens");
    if (id < 0) return 0;
    return @intCast(c.gguf_get_arr_n(ctx, id));
}

pub export fn neural_model_n_tensors() callconv(.c) c_int {
    const ctx = g_gguf orelse return 0;
    return @intCast(c.gguf_get_n_tensors(ctx));
}

// --- introspection (debug: enumerate KV keys + types) ---
pub export fn neural_model_kv_count() callconv(.c) c_int {
    const ctx = g_gguf orelse return 0;
    return @intCast(c.gguf_get_n_kv(ctx));
}

pub export fn neural_model_key(i: c_int) callconv(.c) [*c]const u8 {
    const ctx = g_gguf orelse return @ptrCast("");
    return c.gguf_get_key(ctx, @intCast(i));
}

pub export fn neural_model_key_type(i: c_int) callconv(.c) c_int {
    const ctx = g_gguf orelse return -1;
    return @intCast(c.gguf_get_kv_type(ctx, @intCast(i)));
}

pub export fn neural_model_tensor_name(i: c_int) callconv(.c) [*c]const u8 {
    const ctx = g_gguf orelse return @ptrCast("");
    return c.gguf_get_tensor_name(ctx, @intCast(i));
}

// ---- WordPiece tokenizer -----------------------------------------------------
// BERT tokenization: basic (lowercase, split whitespace + punctuation) then
// greedy longest-match WordPiece against the GGUF vocab (tokenizer.ggml.tokens),
// wrapped in [CLS] .. [SEP]. Uncased/ASCII path (fine for MiniLM English); accent
// stripping / CJK is a later refinement.
var g_vocab: std.StringHashMap(i32) = undefined;
var g_vocab_built: bool = false;
var g_cls: i32 = 101;
var g_sep: i32 = 102;
var g_unk: i32 = 100;
var g_tok_ids: std.ArrayList(i32) = .{};

fn kvI32(key: [*:0]const u8, dflt: i32) i32 {
    const ctx = g_gguf orelse return dflt;
    const id = c.gguf_find_key(ctx, key);
    if (id < 0) return dflt;
    return switch (c.gguf_get_kv_type(ctx, id)) {
        c.GGUF_TYPE_UINT32 => @intCast(c.gguf_get_val_u32(ctx, id)),
        c.GGUF_TYPE_INT32 => c.gguf_get_val_i32(ctx, id),
        else => dflt,
    };
}

fn buildVocab() bool {
    if (g_vocab_built) return true;
    const ctx = g_gguf orelse return false;
    const tid = c.gguf_find_key(ctx, "tokenizer.ggml.tokens");
    if (tid < 0) return false;
    g_vocab = std.StringHashMap(i32).init(gpa);
    const n = c.gguf_get_arr_n(ctx, tid);
    var i: usize = 0;
    while (i < n) : (i += 1) {
        const tok = c.gguf_get_arr_str(ctx, tid, i); // stable slice while model loaded
        g_vocab.put(std.mem.span(tok), @intCast(i)) catch {};
    }
    g_cls = kvI32("tokenizer.ggml.cls_token_id", 101);
    g_sep = kvI32("tokenizer.ggml.seperator_token_id", 102);
    g_unk = kvI32("tokenizer.ggml.unknown_token_id", 100);
    g_vocab_built = true;
    return true;
}

fn freeVocab() void {
    if (g_vocab_built) {
        g_vocab.deinit();
        g_vocab_built = false;
    }
}

fn isPunct(ch: u8) bool {
    return (ch >= '!' and ch <= '/') or (ch >= ':' and ch <= '@') or
        (ch >= '[' and ch <= '`') or (ch >= '{' and ch <= '~');
}
fn isSpace(ch: u8) bool {
    return ch == ' ' or ch == '\t' or ch == '\n' or ch == '\r';
}

// Greedy longest-match WordPiece for one basic token (already lowercased, ASCII).
// This vocab uses the SentencePiece "metaspace" convention: WORD-INITIAL pieces
// carry a leading "▁" (E2 96 81); continuation pieces are bare (no "##").
const META = [3]u8{ 0xE2, 0x96, 0x81 };
fn wordpiece(word: []const u8, out: *std.ArrayList(i32)) void {
    if (word.len == 0) return;
    var kb: [272]u8 = undefined;
    var start: usize = 0;
    while (start < word.len) {
        var end = word.len;
        var found: i32 = -1;
        var matched_end = start;
        while (end > start) : (end -= 1) {
            const sub = word[start..end];
            var key: []const u8 = sub; // continuation: bare
            if (start == 0) { // word-initial: metaspace prefix
                if (3 + sub.len > kb.len) continue;
                @memcpy(kb[0..3], &META);
                @memcpy(kb[3 .. 3 + sub.len], sub);
                key = kb[0 .. 3 + sub.len];
            }
            if (g_vocab.get(key)) |id| {
                found = id;
                matched_end = end;
                break;
            }
        }
        if (found < 0) { // no subword matched -> whole word is [UNK]
            out.append(gpa, g_unk) catch {};
            return;
        }
        out.append(gpa, found) catch {};
        start = matched_end;
    }
}

fn tokenizeInto(text: []const u8, out: *std.ArrayList(i32)) void {
    out.append(gpa, g_cls) catch {};
    var wb: [256]u8 = undefined;
    var i: usize = 0;
    while (i < text.len) {
        const ch = text[i];
        if (isSpace(ch)) {
            i += 1;
            continue;
        }
        if (isPunct(ch)) { // punctuation is its own token
            wordpiece(text[i .. i + 1], out);
            i += 1;
            continue;
        }
        // accumulate a run of non-space, non-punct bytes; ASCII-lowercase it
        var n: usize = 0;
        while (i < text.len and !isSpace(text[i]) and !isPunct(text[i])) : (i += 1) {
            if (n < wb.len) {
                const b = text[i];
                wb[n] = if (b >= 'A' and b <= 'Z') b + 32 else b;
                n += 1;
            }
        }
        wordpiece(wb[0..n], out);
    }
    out.append(gpa, g_sep) catch {};
}

// Tokenize into the shared id buffer; returns the token count. neural_token_at(i)
// reads back an id (for verification).
pub export fn neural_tokenize(text: [*c]const u8, len: usize) callconv(.c) c_int {
    if (!buildVocab()) return 0;
    g_tok_ids.clearRetainingCapacity();
    if (text != null and len > 0) tokenizeInto(text[0..len], &g_tok_ids);
    return @intCast(g_tok_ids.items.len);
}

pub export fn neural_token_at(i: c_int) callconv(.c) c_int {
    const idx: usize = @intCast(i);
    if (idx >= g_tok_ids.items.len) return -1;
    return g_tok_ids.items[idx];
}

// PROBE: raw vocab token string at index i (to check id-order + null-termination).
pub export fn neural_vocab_token(i: c_int) callconv(.c) [*c]const u8 {
    const ctx = g_gguf orelse return @ptrCast("");
    const tid = c.gguf_find_key(ctx, "tokenizer.ggml.tokens");
    if (tid < 0) return @ptrCast("");
    return c.gguf_get_arr_str(ctx, tid, @intCast(i));
}

// ---- BERT embedding forward pass --------------------------------------------
var g_emb: std.ArrayList(f32) = .{};

fn kvArchF32(suffix: []const u8, dflt: f32) f32 {
    const ctx = g_gguf orelse return dflt;
    if (g_arch_len == 0) return dflt;
    var buf: [96]u8 = undefined;
    if (g_arch_len + suffix.len + 1 > buf.len) return dflt;
    @memcpy(buf[0..g_arch_len], g_arch[0..g_arch_len]);
    @memcpy(buf[g_arch_len..][0..suffix.len], suffix);
    buf[g_arch_len + suffix.len] = 0;
    const key: [*:0]const u8 = @ptrCast(&buf[0]);
    const id = c.gguf_find_key(ctx, key);
    if (id < 0) return dflt;
    if (c.gguf_get_kv_type(ctx, id) == c.GGUF_TYPE_FLOAT32) return c.gguf_get_val_f32(ctx, id);
    return dflt;
}

fn layerNorm(ctx: ?*c.ggml_context, x: *c.ggml_tensor, w: *c.ggml_tensor, b: *c.ggml_tensor, eps: f32) *c.ggml_tensor {
    var t = c.ggml_norm(ctx, x, eps).?;
    t = c.ggml_mul(ctx, t, w).?;
    t = c.ggml_add(ctx, t, b).?;
    return t;
}

// Per-token hidden-state vectors from the forward pass (token-major: token t,
// dim e at t*n_embd+e). The shared substrate for the mean-pooled sentence
// embedding AND any token-level task (NER, token classification, QA).
var g_tok_emb: std.ArrayList(f32) = .{};
var g_tok_emb_ntok: usize = 0;
var g_tok_emb_ndim: usize = 0;

// Run the BERT forward pass and leave the RAW per-token hidden states in
// g_tok_emb (copied out before the compute context is freed). Returns false on
// any failure. Both neural_embed_text (mean-pool) and neural_embed_tokens build
// on this.
fn forwardTokens(text: [*c]const u8, len: usize) bool {
    if (!buildVocab()) return false;
    const mctx = g_ctx orelse return false;

    g_tok_ids.clearRetainingCapacity();
    if (text == null or len == 0) return false;
    tokenizeInto(text[0..len], &g_tok_ids);
    var n_tok: usize = g_tok_ids.items.len;
    if (n_tok < 2) return false;
    if (n_tok > 256) n_tok = 256; // cap sequence length

    const n_embd: usize = @intCast(neural_model_n_embd());
    const n_head: usize = @intCast(neural_model_n_heads());
    const n_layer: usize = @intCast(neural_model_n_layers());
    if (n_embd == 0 or n_head == 0 or n_layer == 0) return false;
    const head_dim = n_embd / n_head;
    const eps = kvArchF32(".attention.layer_norm_epsilon", 1e-12);

    const mem_size: usize = 48 * 1024 * 1024 + n_tok * n_tok * n_head * n_layer * 64;
    const ctx = c.ggml_init(.{ .mem_size = mem_size, .mem_buffer = null, .no_alloc = false }) orelse return false;
    defer c.ggml_free(ctx);

    // inputs
    const tokens = c.ggml_new_tensor_1d(ctx, c.GGML_TYPE_I32, @intCast(n_tok)).?;
    const positions = c.ggml_new_tensor_1d(ctx, c.GGML_TYPE_I32, @intCast(n_tok)).?;
    const types = c.ggml_new_tensor_1d(ctx, c.GGML_TYPE_I32, @intCast(n_tok)).?;
    const td: [*]i32 = @ptrCast(@alignCast(tokens.*.data));
    const pd: [*]i32 = @ptrCast(@alignCast(positions.*.data));
    const yd: [*]i32 = @ptrCast(@alignCast(types.*.data));
    for (0..n_tok) |i| {
        td[i] = g_tok_ids.items[i];
        pd[i] = @intCast(i);
        yd[i] = 0;
    }
    var nb: [64]u8 = undefined;
    const T = struct {
        fn get(m: ?*c.ggml_context, comptime fmt: []const u8, args: anytype, b: []u8) *c.ggml_tensor {
            const s = std.fmt.bufPrintZ(b, fmt, args) catch unreachable;
            return c.ggml_get_tensor(m, s.ptr).?;
        }
    };

    // embeddings + LayerNorm
    var cur = c.ggml_get_rows(ctx, T.get(mctx, "token_embd.weight", .{}, &nb), tokens).?;
    cur = c.ggml_add(ctx, cur, c.ggml_get_rows(ctx, T.get(mctx, "token_types.weight", .{}, &nb), types)).?;
    cur = c.ggml_add(ctx, cur, c.ggml_get_rows(ctx, T.get(mctx, "position_embd.weight", .{}, &nb), positions)).?;
    cur = layerNorm(ctx, cur, T.get(mctx, "token_embd_norm.weight", .{}, &nb), T.get(mctx, "token_embd_norm.bias", .{}, &nb), eps);

    var nb2: [64]u8 = undefined;
    for (0..n_layer) |L| {
        const inpL = cur;
        // Q,K,V  [n_embd, n_tok]
        var Q = c.ggml_add(ctx, c.ggml_mul_mat(ctx, T.get(mctx, "blk.{d}.attn_q.weight", .{L}, &nb), cur), T.get(mctx, "blk.{d}.attn_q.bias", .{L}, &nb2)).?;
        var K = c.ggml_add(ctx, c.ggml_mul_mat(ctx, T.get(mctx, "blk.{d}.attn_k.weight", .{L}, &nb), cur), T.get(mctx, "blk.{d}.attn_k.bias", .{L}, &nb2)).?;
        var V = c.ggml_add(ctx, c.ggml_mul_mat(ctx, T.get(mctx, "blk.{d}.attn_v.weight", .{L}, &nb), cur), T.get(mctx, "blk.{d}.attn_v.bias", .{L}, &nb2)).?;
        // heads
        Q = c.ggml_cont(ctx, c.ggml_permute(ctx, c.ggml_reshape_3d(ctx, Q, @intCast(head_dim), @intCast(n_head), @intCast(n_tok)), 0, 2, 1, 3)).?;
        K = c.ggml_cont(ctx, c.ggml_permute(ctx, c.ggml_reshape_3d(ctx, K, @intCast(head_dim), @intCast(n_head), @intCast(n_tok)), 0, 2, 1, 3)).?;
        V = c.ggml_cont(ctx, c.ggml_permute(ctx, c.ggml_reshape_3d(ctx, V, @intCast(head_dim), @intCast(n_head), @intCast(n_tok)), 1, 2, 0, 3)).?;
        // attention
        var KQ = c.ggml_mul_mat(ctx, K, Q).?;
        KQ = c.ggml_scale(ctx, KQ, 1.0 / @sqrt(@as(f32, @floatFromInt(head_dim)))).?;
        KQ = c.ggml_soft_max(ctx, KQ).?;
        var KQV = c.ggml_mul_mat(ctx, V, KQ).?; // [head_dim, n_tok, n_head]
        KQV = c.ggml_cont(ctx, c.ggml_permute(ctx, KQV, 0, 2, 1, 3)).?;
        KQV = c.ggml_reshape_2d(ctx, KQV, @intCast(n_embd), @intCast(n_tok)).?;
        var attn = c.ggml_add(ctx, c.ggml_mul_mat(ctx, T.get(mctx, "blk.{d}.attn_output.weight", .{L}, &nb), KQV), T.get(mctx, "blk.{d}.attn_output.bias", .{L}, &nb2)).?;
        attn = c.ggml_add(ctx, attn, inpL).?;
        attn = layerNorm(ctx, attn, T.get(mctx, "blk.{d}.attn_output_norm.weight", .{L}, &nb), T.get(mctx, "blk.{d}.attn_output_norm.bias", .{L}, &nb2), eps);
        // FFN
        var ff = c.ggml_add(ctx, c.ggml_mul_mat(ctx, T.get(mctx, "blk.{d}.ffn_up.weight", .{L}, &nb), attn), T.get(mctx, "blk.{d}.ffn_up.bias", .{L}, &nb2)).?;
        ff = c.ggml_gelu(ctx, ff).?;
        ff = c.ggml_add(ctx, c.ggml_mul_mat(ctx, T.get(mctx, "blk.{d}.ffn_down.weight", .{L}, &nb), ff), T.get(mctx, "blk.{d}.ffn_down.bias", .{L}, &nb2)).?;
        ff = c.ggml_add(ctx, ff, attn).?;
        cur = layerNorm(ctx, ff, T.get(mctx, "blk.{d}.layer_output_norm.weight", .{L}, &nb), T.get(mctx, "blk.{d}.layer_output_norm.bias", .{L}, &nb2), eps);
    }

    // compute cur = [n_embd, n_tok]
    const graph = c.ggml_new_graph(ctx) orelse return false;
    c.ggml_build_forward_expand(graph, cur);
    var plan = c.ggml_graph_plan(graph, 4, null);
    var wbuf: ?[]u8 = null;
    if (plan.work_size > 0) {
        wbuf = gpa.alloc(u8, plan.work_size) catch return false;
        plan.work_data = wbuf.?.ptr;
    }
    defer if (wbuf) |w| gpa.free(w);
    _ = c.ggml_graph_compute(graph, &plan);

    // cur.data is contiguous [n_embd, n_tok] = token-major (token t's vector is
    // cd[t*n_embd .. +n_embd]). Copy it out before the ctx (and its data) is freed.
    const cd: [*]const f32 = @ptrCast(@alignCast(cur.*.data));
    g_tok_emb.clearRetainingCapacity();
    g_tok_emb.ensureTotalCapacity(gpa, n_tok * n_embd) catch return false;
    for (0..n_tok * n_embd) |i| g_tok_emb.appendAssumeCapacity(cd[i]);
    g_tok_emb_ntok = n_tok;
    g_tok_emb_ndim = n_embd;
    return true;
}

// Embed `text` -> a normalized SENTENCE vector (mean-pool of the per-token
// hidden states), stored in g_emb; returns the dim (0 on failure). Read via
// neural_embed_at(i).
pub export fn neural_embed_text(text: [*c]const u8, len: usize) callconv(.c) c_int {
    if (!forwardTokens(text, len)) return 0;
    const n_tok = g_tok_emb_ntok;
    const n_embd = g_tok_emb_ndim;
    g_emb.clearRetainingCapacity();
    g_emb.ensureTotalCapacity(gpa, n_embd) catch return 0;
    var norm: f32 = 0;
    for (0..n_embd) |e| {
        var s: f32 = 0;
        for (0..n_tok) |t| s += g_tok_emb.items[t * n_embd + e];
        const m = s / @as(f32, @floatFromInt(n_tok));
        g_emb.appendAssumeCapacity(m);
        norm += m * m;
    }
    norm = @sqrt(norm);
    if (norm == 0) norm = 1;
    for (0..n_embd) |e| g_emb.items[e] /= norm;
    return @intCast(n_embd);
}

pub export fn neural_embed_at(i: c_int) callconv(.c) f64 {
    const idx: usize = @intCast(i);
    if (idx >= g_emb.items.len) return 0;
    return g_emb.items[idx];
}

// --- Token-level embeddings (foundation for NER / token classification) -------
// neural_embed_tokens runs the forward pass and returns the TOKEN COUNT (incl.
// the [CLS]/[SEP] wrappers). The RAW per-token hidden-state vectors are then read
// via neural_token_dim() + neural_token_value(tok, dim). Raw (not L2-normalized):
// normalize caller-side for cosine. This is the substrate a real token-
// classification NER head plugs onto.
pub export fn neural_embed_tokens(text: [*c]const u8, len: usize) callconv(.c) c_int {
    if (!forwardTokens(text, len)) return 0;
    return @intCast(g_tok_emb_ntok);
}

pub export fn neural_token_dim() callconv(.c) c_int {
    return @intCast(g_tok_emb_ndim);
}

pub export fn neural_token_value(tok: c_int, dim: c_int) callconv(.c) f64 {
    if (tok < 0 or dim < 0) return 0;
    const t: usize = @intCast(tok);
    const d: usize = @intCast(dim);
    if (t >= g_tok_emb_ntok or d >= g_tok_emb_ndim) return 0;
    return g_tok_emb.items[t * g_tok_emb_ndim + d];
}
