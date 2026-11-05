//! gpu_spmv.zig -- GB0's last op: the CSR sparse-dense product on the GPU
//! (SOFTANZA_GPU_PLAN.md, GB0; what the graph and neural desks asked for).
//!
//! y = A x, A a sparse matrix in CSR form: `rowptr` (nrows + 1 offsets, rowptr[0] = 0 and
//! rowptr[nrows] = nnz), `cols` (the column of every stored entry, 0-based) and `vals` (its value),
//! x a dense vector (or, with k > 1, a dense matrix of k columns, row-major) and y the answer. All
//! four index and value buffers are f32 like every buffer of the plane: the offsets and columns are
//! whole numbers, exact below 2^24, so nnz is limited to 16,777,216 and a larger one is refused by
//! name (TOO_LARGE), and so is a column beyond that.
//!
//! Two kernels, because the shape decides:
//!   scalar   one thread per output element, walking its row: no waste on short rows, the whole
//!            row on one thread for a long one. It is also the dense-matrix product (k >= 1), the
//!            k threads of a row being neighbours, so their reads of x's row are one coalesced run;
//!   vector   one workgroup per row (k = 1): its 256 threads stride the row's entries and a tree adds
//!            their partials in workgroup memory. Wasted on a row of five, the right one for a row of
//!            hundreds.
//! The variant is chosen by the mean row length (nnz / nrows) against a threshold the guard measured
//! on this machine, or by the caller (1 scalar, 2 vector). A sum adds in a fixed order per variant:
//! the scalar one left to right along the row, the vector one in a tree, so on whole numbers below
//! 2^24 both equal the loop's sum to the bit and on other data they differ in the last bits.
//!
//! The CSR is NOT validated: reading the offsets back to check them would cost more than the product
//! on a big matrix. A row pointer that is not non-decreasing, or a column past x, reads what the
//! device's bounds clamp gives, and nothing crashes; the answer is the caller's to trust.
//!
//! Binding contract, the ops family's: @binding(0) tile, @binding(1) params, @binding(2..) buffers in
//! call order; every kernel reads the tile uniform.

const std = @import("std");
const gpu = @import("gpu.zig");

const WG: usize = 256;
pub const MAX_NNZ: usize = 1 << 24;
pub const SCALAR: u32 = 1;
pub const VECTOR: u32 = 2;
/// The mean row length from which one workgroup per row beats one thread per row, measured on the
/// RTX 3050 (1,000,000 entries, 2026-11-05): the scalar kernel wins at 2 to 16 entries a row, the two
/// tie or trade places at 32 (0.75 against 0.74 ms in one run, 1.3 against 2.5 in a loaded one), and the
/// vector kernel wins by about 2x from 64. 48 sits between the last tie and the first clear win.
pub const AUTO_VECTOR_MIN: usize = 48;

const PRELUDE =
    \\struct StzTile { xoff : u32, p0 : u32, p1 : u32, p2 : u32 }
    \\@group(0) @binding(0) var<uniform> tile : StzTile;
    \\
;

const SpParams = extern struct { nrows: u32, k: u32, p1: u32, p2: u32 };

const WGSL_SCALAR = PRELUDE ++
    \\struct P { nrows : u32, k : u32, p1 : u32, p2 : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> rp : array<f32>;
    \\@group(0) @binding(3) var<storage, read> cols : array<f32>;
    \\@group(0) @binding(4) var<storage, read> vals : array<f32>;
    \\@group(0) @binding(5) var<storage, read> x : array<f32>;
    \\@group(0) @binding(6) var<storage, read_write> y : array<f32>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
    \\  let t = gid.x + tile.xoff * 256u;
    \\  if (t >= p.nrows * p.k) { return; }
    \\  let r = t / p.k;
    \\  let j = t % p.k;
    \\  let a = u32(rp[r]);
    \\  let b = u32(rp[r + 1u]);
    \\  var acc = 0.0;
    \\  for (var e = a; e < b; e = e + 1u) {
    \\    acc = acc + vals[e] * x[u32(cols[e]) * p.k + j];
    \\  }
    \\  y[t] = acc;
    \\}
;

const WGSL_VECTOR = PRELUDE ++
    \\struct P { nrows : u32, k : u32, p1 : u32, p2 : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> rp : array<f32>;
    \\@group(0) @binding(3) var<storage, read> cols : array<f32>;
    \\@group(0) @binding(4) var<storage, read> vals : array<f32>;
    \\@group(0) @binding(5) var<storage, read> x : array<f32>;
    \\@group(0) @binding(6) var<storage, read_write> y : array<f32>;
    \\var<workgroup> sh : array<f32, 256>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(local_invocation_id) lid : vec3<u32>,
    \\        @builtin(workgroup_id) wid : vec3<u32>) {
    \\  let l = lid.x;
    \\  let r = wid.x + tile.xoff;
    \\  let valid = r < p.nrows;
    \\  var a = 0u;
    \\  var b = 0u;
    \\  if (valid) {
    \\    a = u32(rp[r]);
    \\    b = u32(rp[r + 1u]);
    \\  }
    \\  var acc = 0.0;
    \\  for (var e = a + l; e < b; e = e + 256u) {
    \\    acc = acc + vals[e] * x[u32(cols[e])];
    \\  }
    \\  sh[l] = acc;
    \\  workgroupBarrier();
    \\  for (var s = 128u; s > 0u; s = s >> 1u) {
    \\    if (l < s) { sh[l] = sh[l] + sh[l + s]; }
    \\    workgroupBarrier();
    \\  }
    \\  if (l == 0u && valid) { y[r] = sh[0]; }
    \\}
;

fn ceilDiv(a: usize, b: usize) usize {
    return (a + b - 1) / b;
}

fn compile(text: []const u8) i64 {
    return gpu.stz_gpu_kernel_compile(text.ptr, @floatFromInt(text.len));
}

fn dispatchP(kernel: i64, params: anytype, bufs: []const i64, wx: usize) i32 {
    const bytes = std.mem.asBytes(params);
    return gpu.stz_gpu_dispatch_params(kernel, bytes.ptr, @floatFromInt(bytes.len), bufs.ptr, @intCast(bufs.len), @floatFromInt(wx), 1);
}

/// The variant `auto` picks for a matrix of nrows rows and nnz entries: 1 scalar, 2 vector.
pub fn stz_gpu_spmv_variant_for(nrowsf: f64, nnzf: f64) callconv(.c) f64 {
    const nrows: usize = @intFromFloat(nrowsf);
    const nnz: usize = @intFromFloat(nnzf);
    if (nrows == 0) return SCALAR;
    return if (nnz / nrows >= AUTO_VECTOR_MIN) VECTOR else SCALAR;
}

fn checkBuf(id: i64, nbytes: usize) i32 {
    const sz = gpu.stz_gpu_buffer_size(id);
    if (sz < 0) return gpu.STALE;
    if (@as(f64, @floatFromInt(nbytes)) > sz) return gpu.BAD_ARG;
    return gpu.OK;
}

fn drive(rp: i64, cols: i64, vals: i64, x: i64, y: i64, nrows: usize, nnz: usize, k: usize, variant: u32) i32 {
    if (gpu.stz_gpu_is_available() == 0) {
        gpu.countFallback();
        return gpu.FALLBACK;
    }
    if (nrows == 0 or nnz == 0 or k == 0) return gpu.BAD_ARG;
    if (nnz > MAX_NNZ) return gpu.TOO_LARGE;
    if (nrows * k > std.math.maxInt(u32)) return gpu.TOO_LARGE;
    const ids = [_]i64{ rp, cols, vals, x, y };
    for (ids, 0..) |a, i| {
        if (a == 0) return gpu.BAD_ARG;
        for (ids[i + 1 ..]) |b| {
            if (a == b) return gpu.BAD_ARG;
        }
    }
    var st = checkBuf(rp, (nrows + 1) * 4);
    if (st != gpu.OK) return st;
    st = checkBuf(cols, nnz * 4);
    if (st != gpu.OK) return st;
    st = checkBuf(vals, nnz * 4);
    if (st != gpu.OK) return st;
    st = checkBuf(x, 4);
    if (st != gpu.OK) return st;
    st = checkBuf(y, nrows * k * 4);
    if (st != gpu.OK) return st;

    const p = SpParams{ .nrows = @intCast(nrows), .k = @intCast(k), .p1 = 0, .p2 = 0 };
    if (variant == VECTOR) {
        const kern = compile(WGSL_VECTOR);
        if (kern == 0) return gpu.GPU_ERROR;
        return dispatchP(kern, &p, &.{ rp, cols, vals, x, y }, nrows);
    }
    const kern = compile(WGSL_SCALAR);
    if (kern == 0) return gpu.GPU_ERROR;
    return dispatchP(kern, &p, &.{ rp, cols, vals, x, y }, ceilDiv(nrows * k, WG));
}

/// y = A x for a CSR matrix, x a dense vector. variant 0 picks by the mean row length, 1 is the
/// scalar kernel, 2 the workgroup-per-row one. rowptr has nrows + 1 entries; cols and vals nnz.
pub fn stz_gpu_op_spmv(rp: i64, cols: i64, vals: i64, x: i64, y: i64, nrowsf: f64, nnzf: f64, variantf: f64) callconv(.c) i32 {
    if (variantf != 0 and variantf != 1 and variantf != 2) return gpu.BAD_ARG;
    const nrows: usize = @intFromFloat(nrowsf);
    const nnz: usize = @intFromFloat(nnzf);
    const v: u32 = if (variantf == 0) @intFromFloat(stz_gpu_spmv_variant_for(nrowsf, nnzf)) else @intFromFloat(variantf);
    return drive(rp, cols, vals, x, y, nrows, nnz, 1, v);
}

/// Y = A X for a CSR matrix and a dense matrix of k columns (row-major, ncols rows): y is nrows x k.
pub fn stz_gpu_op_spmm(rp: i64, cols: i64, vals: i64, x: i64, y: i64, nrowsf: f64, nnzf: f64, kf: f64) callconv(.c) i32 {
    if (kf < 1 or kf != @floor(kf)) return gpu.BAD_ARG;
    return drive(rp, cols, vals, x, y, @intFromFloat(nrowsf), @intFromFloat(nnzf), @intFromFloat(kf), SCALAR);
}

test "the variant follows the mean row length" {
    try std.testing.expectEqual(@as(f64, 1), stz_gpu_spmv_variant_for(1000, 5000));
    try std.testing.expectEqual(@as(f64, 1), stz_gpu_spmv_variant_for(1000, 47000));
    try std.testing.expectEqual(@as(f64, 2), stz_gpu_spmv_variant_for(1000, 48000));
    try std.testing.expectEqual(@as(f64, 2), stz_gpu_spmv_variant_for(10, 10000));
    try std.testing.expectEqual(@as(f64, 1), stz_gpu_spmv_variant_for(0, 0));
}
