// R4 step 8 -- THE GGUF WRITER: Softanza learns to WRITE the format it
// reads (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md 5.9, foundry rung 2).
// Rides ggml's own gguf writer API (vendored): build an in-memory gguf
// context, add f32 tensors (data arrives f64 from Ring, narrowed at
// the edge), write the file, inspect it back.
//
// One export session at a time (begin -> add-tensor* -> write); the
// session owns a ggml context whose memory holds the tensor data
// until the write.

const std = @import("std");

const c = @cImport({
    @cInclude("ggml.h");
    @cInclude("gguf.h");
});

var g_gguf: ?*c.gguf_context = null;
var g_ctx: ?*c.ggml_context = null;

fn cleanup() void {
    if (g_gguf) |g| c.gguf_free(g);
    g_gguf = null;
    if (g_ctx) |x| c.ggml_free(x);
    g_ctx = null;
}

pub fn stz_gguf_export_begin(arch: [*c]const u8, name: [*c]const u8) callconv(.c) i32 {
    cleanup();
    g_gguf = c.gguf_init_empty() orelse return 0;
    g_ctx = c.ggml_init(.{ .mem_size = 64 * 1024 * 1024, .mem_buffer = null, .no_alloc = false }) orelse {
        cleanup();
        return 0;
    };
    c.gguf_set_val_str(g_gguf, "general.architecture", arch);
    c.gguf_set_val_str(g_gguf, "general.name", name);
    return 1;
}

/// rows == 1 -> a 1-D tensor of `cols`; else a 2-D [cols, rows] (ne0 =
/// cols, row-major data). Data is a flat f64 buffer of rows*cols.
pub fn stz_gguf_export_add_tensor(name: [*c]const u8, rows: i32, cols: i32, data: [*]const f64, n: i32) callconv(.c) i32 {
    const gg = g_gguf orelse return 0;
    const ctx = g_ctx orelse return 0;
    if (rows < 1 or cols < 1) return 0;
    const want: usize = @intCast(rows * cols);
    if (@as(usize, @intCast(n)) < want) return 0;

    const t = if (rows == 1)
        c.ggml_new_tensor_1d(ctx, c.GGML_TYPE_F32, @intCast(cols)) orelse return 0
    else
        c.ggml_new_tensor_2d(ctx, c.GGML_TYPE_F32, @intCast(cols), @intCast(rows)) orelse return 0;

    _ = c.ggml_set_name(t, name);
    const td: [*]f32 = @ptrCast(@alignCast(t.*.data));
    for (0..want) |i| td[i] = @floatCast(data[i]);
    c.gguf_add_tensor(gg, t);
    return 1;
}

pub fn stz_gguf_export_write(path: [*c]const u8) callconv(.c) i32 {
    const gg = g_gguf orelse return 0;
    const ok = c.gguf_write_to_file(gg, path, false);
    cleanup();
    return if (ok) 1 else 0;
}

pub fn stz_gguf_export_abort() callconv(.c) void {
    cleanup();
}

// --- inspection (round-trip proof; arch-agnostic, metadata only) ---

var g_arch_buf: [128]u8 = undefined;

/// tensor count of the file, or -1 on failure. The architecture string
/// is fetched separately after a successful inspect.
pub fn stz_gguf_inspect(path: [*c]const u8) callconv(.c) i64 {
    const params = c.gguf_init_params{ .no_alloc = true, .ctx = null };
    const gg = c.gguf_init_from_file(path, params) orelse return -1;
    defer c.gguf_free(gg);
    const n = c.gguf_get_n_tensors(gg);
    const kid = c.gguf_find_key(gg, "general.architecture");
    if (kid >= 0) {
        const s = c.gguf_get_val_str(gg, kid);
        const len = std.mem.len(@as([*:0]const u8, @ptrCast(s)));
        const take = @min(len, g_arch_buf.len - 1);
        @memcpy(g_arch_buf[0..take], s[0..take]);
        g_arch_buf[take] = 0;
    } else {
        g_arch_buf[0] = 0;
    }
    return n;
}

pub fn stz_gguf_inspect_arch() callconv(.c) [*:0]const u8 {
    return @ptrCast(&g_arch_buf);
}
