// R4 step 2 -- THE GGML BRIDGE (seed): stzMatrix matmul through ggml's
// threaded, SIMD kernel. (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md 5.3/5.9:
// stzMatrix and ggml tensors are both contiguous float arrays -- this is
// the feasible-and-strategic wire.)
//
// HOME: compiled into stz_matrix.dll (which links ggml since R4 step 2)
// -- the handle table in ring_api.zig is per-DLL static state, so the
// matmul must live where the matrix handles live (found the hard way:
// a cross-DLL registration resolved handles against the WRONG table).
//
// Precision note: ggml computes in f32; stzMatrix stores f64. The bridge
// narrows/widens at the edges -- fine for ML workloads (the consumer this
// bridge serves), documented for numeric-analysis ones.

const std = @import("std");
const matrix = @import("matrix.zig");

const c = @cImport({
    @cInclude("ggml.h");
    @cInclude("ggml-cpu.h");
});

const gpa = std.heap.c_allocator;

/// C = A(m x k) * B(k x n), computed by ggml. Returns 1 on success,
/// 0 on any dimension/context failure (caller falls back to the naive
/// path -- graceful degradation, never a crash).
pub fn stz_neural_matmul_into(
    pa: ?*const matrix.StzMatrix,
    pb: ?*const matrix.StzMatrix,
    pres: ?*matrix.StzMatrix,
) callconv(.c) i32 {
    const A = pa orelse return 0;
    const B = pb orelse return 0;
    const RES = pres orelse return 0;
    if (A.cols != B.rows) return 0;
    if (RES.rows != A.rows or RES.cols != B.cols) return 0;

    const m = A.rows;
    const k = A.cols;
    const n = B.cols;

    const mem_size: usize = (m * k + k * n + m * n) * @sizeOf(f32) + 3 * 1024 * 1024;
    const ctx = c.ggml_init(.{ .mem_size = mem_size, .mem_buffer = null, .no_alloc = false }) orelse return 0;
    defer c.ggml_free(ctx);

    // ggml_mul_mat(X, Y): X.ne0 == Y.ne0 == the shared k; the result's
    // rows dot X's rows with Y's rows. Feeding X = B-transposed rows
    // (each row = a COLUMN of B) and Y = A's rows yields exactly
    // row-major C = A*B in the result buffer.
    const tX = c.ggml_new_tensor_2d(ctx, c.GGML_TYPE_F32, @intCast(k), @intCast(n)) orelse return 0;
    const tY = c.ggml_new_tensor_2d(ctx, c.GGML_TYPE_F32, @intCast(k), @intCast(m)) orelse return 0;

    const xd: [*]f32 = @ptrCast(@alignCast(tX.*.data));
    const yd: [*]f32 = @ptrCast(@alignCast(tY.*.data));
    for (0..n) |j| {
        for (0..k) |t| {
            xd[j * k + t] = @floatCast(B.data[t * n + j]);
        }
    }
    for (0..m * k) |i| yd[i] = @floatCast(A.data[i]);

    const res = c.ggml_mul_mat(ctx, tX, tY) orelse return 0;
    const graph = c.ggml_new_graph(ctx) orelse return 0;
    c.ggml_build_forward_expand(graph, res);

    var plan = c.ggml_graph_plan(graph, 4, null);
    var wbuf: ?[]u8 = null;
    if (plan.work_size > 0) {
        wbuf = gpa.alloc(u8, plan.work_size) catch return 0;
        plan.work_data = wbuf.?.ptr;
    }
    defer if (wbuf) |w| gpa.free(w);
    _ = c.ggml_graph_compute(graph, &plan);

    const rd: [*]const f32 = @ptrCast(@alignCast(res.*.data));
    for (0..m * n) |i| RES.data[i] = @floatCast(rd[i]);
    return 1;
}
