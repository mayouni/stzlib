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
    @cInclude("gguf.h");
});

// One process-wide loaded model (embedding is a single-model workload for now).
var g_gguf: ?*c.gguf_context = null;
var g_ctx: ?*c.ggml_context = null;
var g_arch: [64]u8 = undefined;
var g_arch_len: usize = 0;

// Load a GGUF model's metadata (no tensor data yet: no_alloc). 1 on success.
pub export fn neural_model_load(path: [*c]const u8) callconv(.c) c_int {
    neural_model_free();
    var mctx: ?*c.ggml_context = null;
    const params = c.gguf_init_params{ .no_alloc = true, .ctx = &mctx };
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
