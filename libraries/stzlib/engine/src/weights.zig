//! weights.zig -- a graph model's tensors READ, DIGESTED and PATCHED by name (WSP-SPIKE-01; SOFTANZA_WEIGHT_SPACE_GOVERNANCE.md, section 3).
//!
//! The first instruments of the pattern ladder over weights: a tensor's shape and values go to Ring so a numbrex, listex or matrex can be asked
//! of them; a tensor's SHA-256 is the negative sibling of a patch (every tensor a patch did not name must digest the same before and after); and
//! the patch itself is ONE op of a closed catalogue, `remove-direction`: for each named column w of a tensor, w' = w - (w . d) d, so the column
//! stops reading the direction d. The op loads its own copy of the model (never the cached one other calls run), writes the patched GGUF and
//! says how many values changed. What direction to remove is the CALLER's finding (the court judges it); applying it is arithmetic, here.
//!
//! Layout: ggml's ne[0] is the contiguous dimension, so a linear head stored [768, k] is k columns of 768 values each, column j at j * 768.

const std = @import("std");
const graph = @import("ocr_graph.zig");
const vis = @import("vision.zig");

const c = graph.c;
const gpa = std.heap.c_allocator;

pub const TensorInfo = struct { rank: u32, ne: [4]i64, ty: c_int, n: usize };

fn tensorOf(m: *graph.Model, name: []const u8) !*c.ggml_tensor {
    const z = try gpa.dupeZ(u8, name);
    defer gpa.free(z);
    return c.ggml_get_tensor(m.wctx, z.ptr) orelse {
        graph.setError("weights: no tensor named {s}", .{name});
        return error.NoSuchTensor;
    };
}

fn rankOf(t: *c.ggml_tensor) u32 {
    var r: u32 = 4;
    while (r > 1 and t.ne[r - 1] == 1) r -= 1;
    return r;
}

pub fn info(model_path: []const u8, name: []const u8) !TensorInfo {
    const m = try vis.modelFor(model_path);
    const t = try tensorOf(m, name);
    return .{ .rank = rankOf(t), .ne = .{ t.ne[0], t.ne[1], t.ne[2], t.ne[3] }, .ty = @intCast(t.type), .n = @intCast(c.ggml_nelements(t)) };
}

/// The names of every tensor the GGUF holds, in file order. Caller frees the outer slice; the names stay the GGUF's.
pub fn names(model_path: []const u8) ![][]const u8 {
    const m = try vis.modelFor(model_path);
    const n: usize = @intCast(c.gguf_get_n_tensors(m.gguf));
    const out = try gpa.alloc([]const u8, n);
    for (0..n) |i| out[i] = std.mem.span(c.gguf_get_tensor_name(m.gguf, @intCast(i)));
    return out;
}

/// count values of an F32 tensor from flat index start (0-based), in ggml order. Caller frees.
pub fn slice(model_path: []const u8, name: []const u8, start: usize, count: usize) ![]f32 {
    const m = try vis.modelFor(model_path);
    const t = try tensorOf(m, name);
    if (t.type != c.GGML_TYPE_F32) {
        graph.setError("weights: {s} is not F32 (type {d})", .{ name, @as(c_int, @intCast(t.type)) });
        return error.NotF32;
    }
    const n: usize = @intCast(c.ggml_nelements(t));
    if (start >= n) return error.OutOfRange;
    const take = @min(count, n - start);
    const data: [*]const f32 = @ptrCast(@alignCast(t.data));
    const out = try gpa.alloc(f32, take);
    @memcpy(out, data[start .. start + take]);
    return out;
}

/// The SHA-256 of a tensor's bytes, as 64 hex characters.
pub fn digest(model_path: []const u8, name: []const u8) ![64]u8 {
    const m = try vis.modelFor(model_path);
    const t = try tensorOf(m, name);
    return digestOf(t);
}

fn digestOf(t: *c.ggml_tensor) [64]u8 {
    const bytes: [*]const u8 = @ptrCast(t.data);
    var h: [32]u8 = undefined;
    std.crypto.hash.sha2.Sha256.hash(bytes[0..c.ggml_nbytes(t)], &h, .{});
    var hex: [64]u8 = undefined;
    const digits = "0123456789abcdef";
    for (h, 0..) |b, i| {
        hex[i * 2] = digits[b >> 4];
        hex[i * 2 + 1] = digits[b & 15];
    }
    return hex;
}

pub const Patched = struct { changed: usize, cols: usize, wd_first: f32, wd_abs_sum: f64 };

/// remove-direction: columns col0 .. col0 + ncols - 1 of tensor name lose their component along dir (unit or not: the projection divides by
/// |d|^2), and the model is written to out_path as a byte copy of the original with that tensor's bytes replaced. The model is loaded afresh
/// and freed; the cached copy other calls run is untouched.
pub fn removeDirection(model_path: []const u8, out_path: []const u8, name: []const u8, col0: usize, ncols: usize, dir: []const f32) !Patched {
    const m = try graph.load(model_path);
    defer m.free();
    const t = try tensorOf(m, name);
    if (t.type != c.GGML_TYPE_F32) {
        graph.setError("weights: {s} is not F32", .{name});
        return error.NotF32;
    }
    const inner: usize = @intCast(t.ne[0]);
    const cols: usize = @intCast(@divExact(c.ggml_nelements(t), @as(i64, @intCast(inner))));
    if (dir.len != inner) {
        graph.setError("weights: the direction has {d} values, the tensor's columns have {d}", .{ dir.len, inner });
        return error.DirectionLength;
    }
    if (col0 >= cols or col0 + ncols > cols) {
        graph.setError("weights: columns {d}..{d} are outside the tensor's {d}", .{ col0, col0 + ncols, cols });
        return error.OutOfRange;
    }
    var dd: f64 = 0;
    for (dir) |v| dd += @as(f64, v) * v;
    if (dd == 0) return error.ZeroDirection;
    const data: [*]f32 = @ptrCast(@alignCast(t.data));
    var first: f32 = 0;
    var abs_sum: f64 = 0;
    for (col0..col0 + ncols) |j| {
        const w = data[j * inner .. (j + 1) * inner];
        var wd: f64 = 0;
        for (w, dir) |a, b| wd += @as(f64, a) * b;
        const k: f32 = @floatCast(wd / dd);
        if (j == col0) first = k;
        abs_sum += @abs(wd / dd);
        for (w, dir) |*a, b| a.* -= k * b;
    }
    // the patched file is the ORIGINAL file, byte for byte, with the one tensor's bytes overwritten at their offset: every other tensor
    // is identical by construction (the negative sibling), and no writer re-serialises what it did not touch
    const tid = c.gguf_find_tensor(m.gguf, (try gpa.dupeZ(u8, name)).ptr);
    if (tid < 0) return error.NoSuchTensor;
    const at: u64 = c.gguf_get_data_offset(m.gguf) + c.gguf_get_tensor_offset(m.gguf, tid);
    const nbytes: usize = c.ggml_nbytes(t);
    try std.fs.cwd().copyFile(model_path, std.fs.cwd(), out_path, .{});
    const f = std.fs.cwd().openFile(out_path, .{ .mode = .read_write }) catch {
        graph.setError("weights: could not open {s} for writing", .{out_path});
        return error.WriteFailed;
    };
    defer f.close();
    const bytes: [*]const u8 = @ptrCast(t.data);
    f.pwriteAll(bytes[0..nbytes], at) catch {
        graph.setError("weights: could not write {s}", .{out_path});
        return error.WriteFailed;
    };
    return .{ .changed = ncols * inner, .cols = ncols, .wd_first = first, .wd_abs_sum = abs_sum };
}
