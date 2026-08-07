//! The G2 op library -- the catalog G0's kill criteria approved, built on the
//! G1 lifecycle layer (SOFTANZA_GPU_PLAN.md).
//!
//! Ops take G1 BUFFER IDS, not host arrays: the residency law. A caller
//! uploads once, chains ops (each is submit-only, no waits), and reads back
//! once. Scalars (sum/dot) are the exception -- a reduction's answer lives on
//! the CPU by definition, so those ops read back their partials.
//!
//! Kernel sourcing: every op's WGSL is a comptime constant compiled through
//! the G1 compile-cache (stz_gpu_kernel_compile). The per-call cost of the
//! cache lookup is a text hash (sub-microsecond against a 60 us dispatch
//! floor), and it makes ops self-healing across device re-init: a Shutdown /
//! SelectAdapter clears the pipeline cache, and the next op call simply
//! recompiles. No epoch bookkeeping.
//!
//! Binding contract (the ops family, via stz_gpu_dispatch_params):
//!   @binding(0) tile uniform (G1-owned; xoff in workgroups along x)
//!   @binding(1) op params uniform (this layer; <= 64 bytes)
//!   @binding(2..) data buffers, in call order
//!
//! Reduction shape: one dispatch produces per-workgroup partials (shared-mem
//! tree, 256 lanes), partials read back and folded in f64 on the CPU. The
//! fold order is fixed (ascending), so for integer-valued inputs the result
//! is EXACT -- the parity guard exploits that. For general data the
//! GPU-vs-CPU difference is f32 accumulation order; the guard's tolerance
//! bands are SET FROM MEASUREMENT, per the plan.
//!
//! Aliasing rule: an op's OUT buffer must be distinct from its inputs
//! (WebGPU usage-scope validation rejects read|read_write aliasing in one
//! bind group). In-place mutation is offered only where the kernel is
//! WRITTEN in-place (ScaleInPlace, and softmax's internal passes).

const std = @import("std");
const gpu = @import("gpu.zig");

const alloc = std.heap.c_allocator;

const WG = 256; // elementwise/reduction workgroup width
const TILE = 16; // matmul/pairdist tile edge

// ---------------------------------------------------------------- helpers

/// Every op's first gate: no device means FALLBACK, counted here -- the
/// layer that refuses is the layer that counts (before any buffer checks,
/// so a dead device answers FALLBACK, not STALE-because-ids-died-with-it).
fn gateAvailable() i32 {
    if (gpu.stz_gpu_is_available() == 0) {
        gpu.countFallback();
        return gpu.FALLBACK;
    }
    return gpu.OK;
}

/// Validate a buffer id can hold `n` f32 elements. OK / STALE / BAD_ARG.
fn checkBuf(id: i64, n: usize) i32 {
    const sz = gpu.stz_gpu_buffer_size(id);
    if (sz < 0) return gpu.STALE;
    if (@as(f64, @floatFromInt(n * 4)) > sz) return gpu.BAD_ARG;
    return gpu.OK;
}

fn ceilDiv(a: usize, b: usize) usize {
    return (a + b - 1) / b;
}

fn compile(text: []const u8) i64 {
    return gpu.stz_gpu_kernel_compile(text.ptr, @floatFromInt(text.len));
}

fn dispatchP(kernel: i64, params: anytype, bufs: []const i64, wx: usize, wy: usize) i32 {
    const bytes = std.mem.asBytes(params);
    return gpu.stz_gpu_dispatch_params(
        kernel,
        bytes.ptr,
        @floatFromInt(bytes.len),
        bufs.ptr,
        @intCast(bufs.len),
        @floatFromInt(wx),
        @floatFromInt(wy),
    );
}

// the shared preamble every ops kernel starts with
const PRELUDE =
    \\struct StzTile { xoff : u32, p0 : u32, p1 : u32, p2 : u32 }
    \\@group(0) @binding(0) var<uniform> tile : StzTile;
    \\
;

// ---------------------------------------------------------------- elementwise

const EwParams = extern struct { n: u32, pad: u32, alpha: f32, beta: f32 };

const WGSL_AXPBY = PRELUDE ++
    \\struct P { n : u32, pad : u32, alpha : f32, beta : f32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> a : array<f32>;
    \\@group(0) @binding(3) var<storage, read> b : array<f32>;
    \\@group(0) @binding(4) var<storage, read_write> outv : array<f32>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
    \\  let i = gid.x + tile.xoff * 256u;
    \\  if (i < p.n) { outv[i] = p.alpha * a[i] + p.beta * b[i]; }
    \\}
;

const WGSL_MUL = PRELUDE ++
    \\struct P { n : u32, pad : u32, alpha : f32, beta : f32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> a : array<f32>;
    \\@group(0) @binding(3) var<storage, read> b : array<f32>;
    \\@group(0) @binding(4) var<storage, read_write> outv : array<f32>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
    \\  let i = gid.x + tile.xoff * 256u;
    \\  if (i < p.n) { outv[i] = a[i] * b[i]; }
    \\}
;

const WGSL_SCALE_INPLACE = PRELUDE ++
    \\struct P { n : u32, pad : u32, alpha : f32, beta : f32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read_write> v : array<f32>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
    \\  let i = gid.x + tile.xoff * 256u;
    \\  if (i < p.n) { v[i] = v[i] * p.alpha; }
    \\}
;

/// out = alpha*a + beta*b, elementwise over n f32s. out must be distinct.
pub fn stz_gpu_op_axpby(alpha: f64, a: i64, beta: f64, b: i64, out: i64, nf: f64) callconv(.c) i32 {
    const gate = gateAvailable();
    if (gate != gpu.OK) return gate;
    const n: usize = @intFromFloat(nf);
    if (n == 0) return gpu.BAD_ARG;
    for ([_]i64{ a, b, out }) |id| {
        const st = checkBuf(id, n);
        if (st != gpu.OK) return st;
    }
    const kern = compile(WGSL_AXPBY);
    if (kern == 0) return if (gpu.stz_gpu_is_available() == 0) gpu.FALLBACK else gpu.GPU_ERROR;
    const p = EwParams{ .n = @intCast(n), .pad = 0, .alpha = @floatCast(alpha), .beta = @floatCast(beta) };
    return dispatchP(kern, &p, &.{ a, b, out }, ceilDiv(n, WG), 1);
}

/// out = a .* b (Hadamard), elementwise over n f32s. out must be distinct.
pub fn stz_gpu_op_mul(a: i64, b: i64, out: i64, nf: f64) callconv(.c) i32 {
    const gate = gateAvailable();
    if (gate != gpu.OK) return gate;
    const n: usize = @intFromFloat(nf);
    if (n == 0) return gpu.BAD_ARG;
    for ([_]i64{ a, b, out }) |id| {
        const st = checkBuf(id, n);
        if (st != gpu.OK) return st;
    }
    const kern = compile(WGSL_MUL);
    if (kern == 0) return if (gpu.stz_gpu_is_available() == 0) gpu.FALLBACK else gpu.GPU_ERROR;
    const p = EwParams{ .n = @intCast(n), .pad = 0, .alpha = 0, .beta = 0 };
    return dispatchP(kern, &p, &.{ a, b, out }, ceilDiv(n, WG), 1);
}

/// v *= alpha, in place over n f32s.
pub fn stz_gpu_op_scale_inplace(v: i64, alpha: f64, nf: f64) callconv(.c) i32 {
    const gate = gateAvailable();
    if (gate != gpu.OK) return gate;
    const n: usize = @intFromFloat(nf);
    if (n == 0) return gpu.BAD_ARG;
    const st = checkBuf(v, n);
    if (st != gpu.OK) return st;
    const kern = compile(WGSL_SCALE_INPLACE);
    if (kern == 0) return if (gpu.stz_gpu_is_available() == 0) gpu.FALLBACK else gpu.GPU_ERROR;
    const p = EwParams{ .n = @intCast(n), .pad = 0, .alpha = @floatCast(alpha), .beta = 0 };
    return dispatchP(kern, &p, &.{v}, ceilDiv(n, WG), 1);
}

// ---------------------------------------------------------------- matmul

const MmParams = extern struct { m: u32, k: u32, n: u32, pad: u32 };

// The G0 spike kernel, moved onto the ops binding contract and made
// x-tileable (col offset by tile.xoff workgroups). 16x16 workgroup tiles;
// deliberately the FLOOR, not a tuned ceiling -- G0's decision stands
// either way.
const WGSL_MATMUL = PRELUDE ++
    \\struct P { m : u32, k : u32, n : u32, pad : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> a : array<f32>;
    \\@group(0) @binding(3) var<storage, read> b : array<f32>;
    \\@group(0) @binding(4) var<storage, read_write> cc : array<f32>;
    \\var<workgroup> ta : array<f32, 256>;
    \\var<workgroup> tb : array<f32, 256>;
    \\@compute @workgroup_size(16, 16)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>,
    \\        @builtin(local_invocation_id) lid : vec3<u32>) {
    \\  let row = gid.y;
    \\  let col = gid.x + tile.xoff * 16u;
    \\  var acc = 0.0;
    \\  let tiles = (p.k + 15u) / 16u;
    \\  for (var t = 0u; t < tiles; t = t + 1u) {
    \\    let k0 = t * 16u;
    \\    let acol = k0 + lid.x;
    \\    let brow = k0 + lid.y;
    \\    ta[lid.y * 16u + lid.x] = select(0.0, a[row * p.k + acol], row < p.m && acol < p.k);
    \\    tb[lid.y * 16u + lid.x] = select(0.0, b[brow * p.n + col], brow < p.k && col < p.n);
    \\    workgroupBarrier();
    \\    for (var kk = 0u; kk < 16u; kk = kk + 1u) {
    \\      acc = acc + ta[lid.y * 16u + kk] * tb[kk * 16u + lid.x];
    \\    }
    \\    workgroupBarrier();
    \\  }
    \\  if (row < p.m && col < p.n) { cc[row * p.n + col] = acc; }
    \\}
;

/// C(m x n) = A(m x k) * B(k x n), all row-major f32.
pub fn stz_gpu_op_matmul(a: i64, b: i64, cbuf: i64, mf: f64, kf: f64, nf: f64) callconv(.c) i32 {
    const gate = gateAvailable();
    if (gate != gpu.OK) return gate;
    const m: usize = @intFromFloat(mf);
    const k: usize = @intFromFloat(kf);
    const n: usize = @intFromFloat(nf);
    if (m == 0 or k == 0 or n == 0) return gpu.BAD_ARG;
    var st = checkBuf(a, m * k);
    if (st != gpu.OK) return st;
    st = checkBuf(b, k * n);
    if (st != gpu.OK) return st;
    st = checkBuf(cbuf, m * n);
    if (st != gpu.OK) return st;
    const kern = compile(WGSL_MATMUL);
    if (kern == 0) return if (gpu.stz_gpu_is_available() == 0) gpu.FALLBACK else gpu.GPU_ERROR;
    const p = MmParams{ .m = @intCast(m), .k = @intCast(k), .n = @intCast(n), .pad = 0 };
    return dispatchP(kern, &p, &.{ a, b, cbuf }, ceilDiv(n, TILE), ceilDiv(m, TILE));
}

// ---------------------------------------------------------------- pairwise distance

const PdParams = extern struct { m: u32, n: u32, d: u32, pad: u32 };

// Squared L2 between every row of A (m x d) and every row of B (n x d):
// D[i][j] = sum_k (A[i][k] - B[j][k])^2. The embedding kernel -- knn/ann
// rank on squared distance, so no sqrt here (monotone, and exact for the
// integer witnesses).
const WGSL_PAIRDIST = PRELUDE ++
    \\struct P { m : u32, n : u32, d : u32, pad : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> a : array<f32>;
    \\@group(0) @binding(3) var<storage, read> b : array<f32>;
    \\@group(0) @binding(4) var<storage, read_write> dist : array<f32>;
    \\var<workgroup> ta : array<f32, 256>;
    \\var<workgroup> tb : array<f32, 256>;
    \\@compute @workgroup_size(16, 16)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>,
    \\        @builtin(local_invocation_id) lid : vec3<u32>,
    \\        @builtin(workgroup_id) wid : vec3<u32>) {
    \\  let row = gid.y;
    \\  let col = gid.x + tile.xoff * 16u;
    \\  let rowBase = wid.y * 16u;
    \\  let colBase = (wid.x + tile.xoff) * 16u;
    \\  var acc = 0.0;
    \\  let tiles = (p.d + 15u) / 16u;
    \\  for (var t = 0u; t < tiles; t = t + 1u) {
    \\    let k0 = t * 16u;
    \\    let ar = rowBase + lid.y;
    \\    let br = colBase + lid.y;
    \\    let kc = k0 + lid.x;
    \\    ta[lid.y * 16u + lid.x] = select(0.0, a[ar * p.d + kc], ar < p.m && kc < p.d);
    \\    tb[lid.y * 16u + lid.x] = select(0.0, b[br * p.d + kc], br < p.n && kc < p.d);
    \\    workgroupBarrier();
    \\    let kmax = min(16u, p.d - k0);
    \\    for (var kk = 0u; kk < kmax; kk = kk + 1u) {
    \\      let diff = ta[lid.y * 16u + kk] - tb[lid.x * 16u + kk];
    \\      acc = acc + diff * diff;
    \\    }
    \\    workgroupBarrier();
    \\  }
    \\  if (row < p.m && col < p.n) { dist[row * p.n + col] = acc; }
    \\}
;

/// D(m x n) = squared L2 distances between rows of A(m x d) and B(n x d).
pub fn stz_gpu_op_pairdist(a: i64, b: i64, dbuf: i64, mf: f64, nf: f64, df: f64) callconv(.c) i32 {
    const gate = gateAvailable();
    if (gate != gpu.OK) return gate;
    const m: usize = @intFromFloat(mf);
    const n: usize = @intFromFloat(nf);
    const d: usize = @intFromFloat(df);
    if (m == 0 or n == 0 or d == 0) return gpu.BAD_ARG;
    var st = checkBuf(a, m * d);
    if (st != gpu.OK) return st;
    st = checkBuf(b, n * d);
    if (st != gpu.OK) return st;
    st = checkBuf(dbuf, m * n);
    if (st != gpu.OK) return st;
    const kern = compile(WGSL_PAIRDIST);
    if (kern == 0) return if (gpu.stz_gpu_is_available() == 0) gpu.FALLBACK else gpu.GPU_ERROR;
    const p = PdParams{ .m = @intCast(m), .n = @intCast(n), .d = @intCast(d), .pad = 0 };
    return dispatchP(kern, &p, &.{ a, b, dbuf }, ceilDiv(n, TILE), ceilDiv(m, TILE));
}

// ---------------------------------------------------------------- reductions

const RedParams = extern struct { n: u32, pad0: u32, pad1: u32, pad2: u32 };

const WGSL_SUM_PARTIALS = PRELUDE ++
    \\struct P { n : u32, pad0 : u32, pad1 : u32, pad2 : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> v : array<f32>;
    \\@group(0) @binding(3) var<storage, read_write> parts : array<f32>;
    \\var<workgroup> sh : array<f32, 256>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>,
    \\        @builtin(local_invocation_id) lid : vec3<u32>,
    \\        @builtin(workgroup_id) wid : vec3<u32>) {
    \\  let i = gid.x + tile.xoff * 256u;
    \\  sh[lid.x] = select(0.0, v[i], i < p.n);
    \\  workgroupBarrier();
    \\  for (var s = 128u; s > 0u; s = s >> 1u) {
    \\    if (lid.x < s) { sh[lid.x] = sh[lid.x] + sh[lid.x + s]; }
    \\    workgroupBarrier();
    \\  }
    \\  if (lid.x == 0u) { parts[wid.x + tile.xoff] = sh[0]; }
    \\}
;

const WGSL_DOT_PARTIALS = PRELUDE ++
    \\struct P { n : u32, pad0 : u32, pad1 : u32, pad2 : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> a : array<f32>;
    \\@group(0) @binding(3) var<storage, read> b : array<f32>;
    \\@group(0) @binding(4) var<storage, read_write> parts : array<f32>;
    \\var<workgroup> sh : array<f32, 256>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>,
    \\        @builtin(local_invocation_id) lid : vec3<u32>,
    \\        @builtin(workgroup_id) wid : vec3<u32>) {
    \\  let i = gid.x + tile.xoff * 256u;
    \\  sh[lid.x] = select(0.0, a[i] * b[i], i < p.n);
    \\  workgroupBarrier();
    \\  for (var s = 128u; s > 0u; s = s >> 1u) {
    \\    if (lid.x < s) { sh[lid.x] = sh[lid.x] + sh[lid.x + s]; }
    \\    workgroupBarrier();
    \\  }
    \\  if (lid.x == 0u) { parts[wid.x + tile.xoff] = sh[0]; }
    \\}
;

const WGSL_MAX_PARTIALS = PRELUDE ++
    \\struct P { n : u32, pad0 : u32, pad1 : u32, pad2 : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> v : array<f32>;
    \\@group(0) @binding(3) var<storage, read_write> parts : array<f32>;
    \\var<workgroup> sh : array<f32, 256>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>,
    \\        @builtin(local_invocation_id) lid : vec3<u32>,
    \\        @builtin(workgroup_id) wid : vec3<u32>) {
    \\  let i = gid.x + tile.xoff * 256u;
    \\  sh[lid.x] = select(-3.4028235e38, v[i], i < p.n);
    \\  workgroupBarrier();
    \\  for (var s = 128u; s > 0u; s = s >> 1u) {
    \\    if (lid.x < s) { sh[lid.x] = max(sh[lid.x], sh[lid.x + s]); }
    \\    workgroupBarrier();
    \\  }
    \\  if (lid.x == 0u) { parts[wid.x + tile.xoff] = sh[0]; }
    \\}
;

const ReduceKind = enum { sum, dot, max };

/// Shared reduction driver: dispatch partials, read them back, fold in f64
/// (ascending order -- deterministic, and exact for integer-valued data).
fn reduceDrive(kind: ReduceKind, a: i64, b: i64, n: usize, out_val: *f64) i32 {
    const nparts = ceilDiv(n, WG);
    const scratch = gpu.stz_gpu_buffer_new(@floatFromInt(nparts * 4));
    if (scratch == 0) return if (gpu.stz_gpu_is_available() == 0) gpu.FALLBACK else gpu.TOO_LARGE;
    defer _ = gpu.stz_gpu_buffer_free(scratch);

    const kern = switch (kind) {
        .sum => compile(WGSL_SUM_PARTIALS),
        .dot => compile(WGSL_DOT_PARTIALS),
        .max => compile(WGSL_MAX_PARTIALS),
    };
    if (kern == 0) return gpu.GPU_ERROR;
    const p = RedParams{ .n = @intCast(n), .pad0 = 0, .pad1 = 0, .pad2 = 0 };
    const st = switch (kind) {
        .dot => dispatchP(kern, &p, &.{ a, b, scratch }, nparts, 1),
        else => dispatchP(kern, &p, &.{ a, scratch }, nparts, 1),
    };
    if (st != gpu.OK) return st;

    const parts = alloc.alloc(f32, nparts) catch return gpu.GPU_ERROR;
    defer alloc.free(parts);
    const rst = gpu.stz_gpu_buffer_read(scratch, @ptrCast(parts.ptr), @floatFromInt(nparts * 4));
    if (rst != gpu.OK) return rst;

    var acc: f64 = if (kind == .max) -std.math.inf(f64) else 0;
    for (parts) |v| {
        switch (kind) {
            .max => acc = @max(acc, @as(f64, v)),
            else => acc += @as(f64, v),
        }
    }
    out_val.* = acc;
    return gpu.OK;
}

/// Sum of n f32s. Partials on GPU, f64 fold on CPU (ascending, deterministic).
pub fn stz_gpu_op_sum(a: i64, nf: f64, out_val: *f64) callconv(.c) i32 {
    const gate = gateAvailable();
    if (gate != gpu.OK) return gate;
    const n: usize = @intFromFloat(nf);
    if (n == 0) return gpu.BAD_ARG;
    const st = checkBuf(a, n);
    if (st != gpu.OK) return st;
    return reduceDrive(.sum, a, 0, n, out_val);
}

/// Dot product of two n-f32 vectors.
pub fn stz_gpu_op_dot(a: i64, b: i64, nf: f64, out_val: *f64) callconv(.c) i32 {
    const gate = gateAvailable();
    if (gate != gpu.OK) return gate;
    const n: usize = @intFromFloat(nf);
    if (n == 0) return gpu.BAD_ARG;
    var st = checkBuf(a, n);
    if (st != gpu.OK) return st;
    st = checkBuf(b, n);
    if (st != gpu.OK) return st;
    return reduceDrive(.dot, a, b, n, out_val);
}

// ---------------------------------------------------------------- softmax

const SoftParams = extern struct { n: u32, pad0: u32, maxv: f32, pad1: f32 };

// exp pass: out[i] = exp(in[i] - max), AND per-workgroup partial sums of the
// exps -- fused so softmax costs 3 dispatches total (max, exp+partials,
// scale), not 4.
const WGSL_EXP_PARTIALS = PRELUDE ++
    \\struct P { n : u32, pad0 : u32, maxv : f32, pad1 : f32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> v : array<f32>;
    \\@group(0) @binding(3) var<storage, read_write> outv : array<f32>;
    \\@group(0) @binding(4) var<storage, read_write> parts : array<f32>;
    \\var<workgroup> sh : array<f32, 256>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>,
    \\        @builtin(local_invocation_id) lid : vec3<u32>,
    \\        @builtin(workgroup_id) wid : vec3<u32>) {
    \\  let i = gid.x + tile.xoff * 256u;
    \\  var e = 0.0;
    \\  if (i < p.n) {
    \\    e = exp(v[i] - p.maxv);
    \\    outv[i] = e;
    \\  }
    \\  sh[lid.x] = e;
    \\  workgroupBarrier();
    \\  for (var s = 128u; s > 0u; s = s >> 1u) {
    \\    if (lid.x < s) { sh[lid.x] = sh[lid.x] + sh[lid.x + s]; }
    \\    workgroupBarrier();
    \\  }
    \\  if (lid.x == 0u) { parts[wid.x + tile.xoff] = sh[0]; }
    \\}
;

/// out = softmax(in) over n f32s (max-shifted, numerically safe).
/// in and out must be distinct buffers.
pub fn stz_gpu_op_softmax(in: i64, out: i64, nf: f64) callconv(.c) i32 {
    const gate = gateAvailable();
    if (gate != gpu.OK) return gate;
    const n: usize = @intFromFloat(nf);
    if (n == 0) return gpu.BAD_ARG;
    var st = checkBuf(in, n);
    if (st != gpu.OK) return st;
    st = checkBuf(out, n);
    if (st != gpu.OK) return st;

    // pass 1: global max (partials + CPU fold)
    var maxv: f64 = 0;
    st = reduceDrive(.max, in, 0, n, &maxv);
    if (st != gpu.OK) return st;

    // pass 2: exp(in - max) into out, with partial sums
    const nparts = ceilDiv(n, WG);
    const scratch = gpu.stz_gpu_buffer_new(@floatFromInt(nparts * 4));
    if (scratch == 0) return if (gpu.stz_gpu_is_available() == 0) gpu.FALLBACK else gpu.TOO_LARGE;
    defer _ = gpu.stz_gpu_buffer_free(scratch);
    const kern = compile(WGSL_EXP_PARTIALS);
    if (kern == 0) return gpu.GPU_ERROR;
    const p = SoftParams{ .n = @intCast(n), .pad0 = 0, .maxv = @floatCast(maxv), .pad1 = 0 };
    st = dispatchP(kern, &p, &.{ in, out, scratch }, nparts, 1);
    if (st != gpu.OK) return st;

    const parts = alloc.alloc(f32, nparts) catch return gpu.GPU_ERROR;
    defer alloc.free(parts);
    st = gpu.stz_gpu_buffer_read(scratch, @ptrCast(parts.ptr), @floatFromInt(nparts * 4));
    if (st != gpu.OK) return st;
    var total: f64 = 0;
    for (parts) |v| total += @as(f64, v);
    if (total <= 0) return gpu.GPU_ERROR;

    // pass 3: out *= 1/total
    return stz_gpu_op_scale_inplace(out, 1.0 / total, nf);
}

test {
    _ = gpu;
}
