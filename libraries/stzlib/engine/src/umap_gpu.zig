//! umap_gpu.zig -- GS6c: UMAP's sparse form on the GPU, as a silent seam
//! inside umap.buildGraph and umap.runSupervised (SOFTANZA_GPU_PLAN.md, GS6).
//!
//! Where a UMAP fit's time sits, measured on the CPU 2026-09-10 (d = 8):
//!
//!     n        graph build     one epoch
//!     4,000       175 ms         4.2 ms
//!     8,192     1,640 ms         8 ms
//!    16,384     5,280 ms        16 ms
//!
//! Above 8,192 the build is the fit: the approximate forest, and a DENSE
//! n x n f64 matrix the fuzzy union walked (2 GB at 16k). The union is
//! sparse now on the CPU (umap.zig, bit-identical edges), and the two halves
//! this module moves are:
//!
//!   1. the k nearest neighbours, EXACT, one thread per row: the row's point
//!      staged in registers, every other point scanned, a sorted k-array
//!      kept in registers with the CPU's tie rule (the lower index wins).
//!      No n x n matrix is ever materialised -- the answer is n x k. Above
//!      the forest's threshold this REPLACES an approximate answer with an
//!      exact one and is faster.
//!
//!   2. the epoch, in GATHER form: one thread per point sums the attraction
//!      of its sampled incident edges and the repulsion of its negative
//!      samples, and the positions advance synchronously (Jacobi) rather
//!      than in the CPU's sequential order (Gauss-Seidel). THE ATTRACTION
//!      IS HALVED PER ENDPOINT: under a synchronous update every pull a
//!      point receives is computed from positions that have not yet moved,
//!      so a well-connected point overshoots its cluster and the layout
//!      rings. Measured on the CPU's own loop (src/gs6c_probe.zig, 5-NN
//!      blob purity, 200 epochs): sequential 0.982 at 4k, synchronous
//!      0.951, synchronous with the attraction halved 0.972 -- and 1.000
//!      against 0.997 at 1k. The pair still closes by the transform path's
//!      one-sided step. The sampling
//!      schedule is stateless -- edge e is sampled at epoch t when
//!      floor((t+1)/eps_e) exceeds floor(t/eps_e), which is what the CPU's
//!      running next_sample computes -- so an epoch is ONE dispatch with no
//!      device-side state but the positions, and a whole fit's epochs batch
//!      into a handful of submits. Negative samples come from a hash of
//!      (seed, epoch, edge, sample): deterministic, so the same seed gives
//!      the same embedding on the device, as it does on the CPU.
//!
//! The two routes are compared on what a stochastic layout promises -- the
//! blobs stay together and apart -- not on bits: the device updates
//! synchronously and samples its own negatives, and its neighbour distances
//! are f32. The CPU is the truth; any refusal at any point drops to it and
//! is COUNTED. The density term stays on the CPU: on the epochs where it is
//! on, the positions come down, the term applies, and they go back up.
//!
//! THE STATS DLL'S DEVICE is tsne_gpu's (one device per DLL, one owner);
//! this module asks it, never opens its own.

const std = @import("std");
const gpu = @import("gpu.zig");
const verify = @import("gpu_verify.zig");
const tsne_gpu = @import("tsne_gpu.zig");

const alloc = std.heap.c_allocator;

/// The gates. Epoch chain: the whole fit measured 2.3x at 1,000 points and
/// 10x at 4,000 (see the plan's GS6c STATUS); k-NN: the CPU's threaded
/// exact scan is fast below a thousand points.
var g_min_n: usize = 1000;
var g_knn_min_n: usize = 1024;

pub const C_EPOCHS_GPU = 0; // epochs served by the device
pub const C_FALLBACK = 1; // eligible work the device could not serve
pub const C_FITS_GPU = 2; // fits whose every epoch ran on the device
pub const C_KNN_GPU = 3; // neighbour tables built on the device
pub const C_KNN_VARIANT = 4; // tables built by a foundry-chosen variant, not the generic
pub const C_TRUST_GPU = 5; // trustworthiness scores computed on the device (GS6f)
var counters: [6]f64 = @splat(0);

pub fn stz_umap_gpu_set_min_n(nf: f64) callconv(.c) void {
    g_min_n = @intFromFloat(@max(nf, 1));
}
pub fn stz_umap_gpu_min_n() callconv(.c) f64 {
    return @floatFromInt(g_min_n);
}
pub fn stz_umap_gpu_set_knn_min_n(nf: f64) callconv(.c) void {
    g_knn_min_n = @intFromFloat(@max(nf, 1));
}
pub fn stz_umap_gpu_knn_min_n() callconv(.c) f64 {
    return @floatFromInt(g_knn_min_n);
}
pub fn stz_umap_gpu_counter(i: i32) callconv(.c) f64 {
    if (i < 0 or i >= counters.len) return 0;
    return counters[@intCast(i)];
}
pub fn stz_umap_gpu_counters_reset() callconv(.c) void {
    counters = @splat(0);
}

// ---------------------------------------------------------------- kernels

const PRELUDE =
    \\struct StzTile { xoff : u32, p0 : u32, p1 : u32, p2 : u32 }
    \\@group(0) @binding(0) var<uniform> tile : StzTile;
    \\
;

const KNN_MAX_K = 64;
const KNN_STAGE_D = 64;

// ---------------------------------------------------------------- the k-NN variants (GK2's foundry, here)
//
// cuML's UMAP paper puts the k-NN at 98% of a 3M-point run: it is the ceiling
// at scale, and ours was the naive scan. Four kernels answer the same
// contract -- one thread per row, the k nearest by squared distance, ties to
// the lower index, one f32 output buffer [d2 (n*k) | index as f32 (n*k)] --
// and only GK0's checker decides which one a shape class dispatches:
//
//   GENERIC  every thread walks every row from global memory (the row's own
//            point in registers when d <= 64)
//   TILE     a workgroup stages a tile of candidate rows in workgroup memory
//            with coalesced loads, every thread scans the tile (d <= 64)
//   TILE4    TILE with four candidates in flight per step (d <= 64)
//   CHUNK    32 candidates x 64 dimensions per tile, the distances
//            accumulated across dimension chunks -- any d up to 1024
//   BROKEN   TILE with one index off by one: the checker's negative sibling,
//            reachable only through the foundry's mask, never dispatchable
//
// The insertion is ONE function shared by every kernel, so the tie rule
// cannot drift between them. The output as one buffer is what lets the
// checker compare a whole answer in one band: an index that differs by one
// differs by 1.0, far outside any distance band.

pub const KNN_GENERIC: usize = 0;
pub const KNN_TILE: usize = 1;
pub const KNN_TILE4: usize = 2;
pub const KNN_CHUNK: usize = 3;
pub const KNN_BROKEN: usize = 4;
pub const KNN_REAL: usize = 4; // variants a table may hold: 0..KNN_REAL-1
pub const KNN_VARIANTS: usize = 5;

const KNN_HEAD =
    \\struct P { n : u32, d : u32, k : u32, pad : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> x : array<f32>;
    \\@group(0) @binding(3) var<storage, read_write> outb : array<f32>;
    \\fn ins(bd : ptr<function, array<f32, 64>>, bi : ptr<function, array<u32, 64>>, k : u32, acc : f32, j : u32) {
    \\  var pos = k - 1u;
    \\  while (pos > 0u && (*bd)[pos - 1u] > acc) { (*bd)[pos] = (*bd)[pos - 1u]; (*bi)[pos] = (*bi)[pos - 1u]; pos = pos - 1u; }
    \\  (*bd)[pos] = acc;
    \\  (*bi)[pos] = j;
    \\}
    \\
;

const KNN_TAIL =
    \\  if (i < n) {
    \\    for (var s = 0u; s < k; s = s + 1u) { outb[i * k + s] = bd[s]; outb[n * k + i * k + s] = f32(bi[s]); }
    \\  }
    \\}
;

const WGSL_KNN_GENERIC = PRELUDE ++ KNN_HEAD ++
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(workgroup_id) wid : vec3<u32>, @builtin(local_invocation_id) lid : vec3<u32>) {
    \\  let i = (wid.x + tile.xoff) * 256u + lid.x;
    \\  let n = p.n;
    \\  let d = p.d;
    \\  let k = p.k;
    \\  var xi : array<f32, 64>;
    \\  var bd : array<f32, 64>;
    \\  var bi : array<u32, 64>;
    \\  let staged = d <= 64u;
    \\  if (i < n && staged) { for (var t = 0u; t < d; t = t + 1u) { xi[t] = x[i * d + t]; } }
    \\  for (var s = 0u; s < k; s = s + 1u) { bd[s] = 3.0e38; bi[s] = 0u; }
    \\  var worst = 3.0e38;
    \\  if (i < n) {
    \\    for (var j = 0u; j < n; j = j + 1u) {
    \\      if (j == i) { continue; }
    \\      var acc = 0.0;
    \\      if (staged) {
    \\        for (var t = 0u; t < d; t = t + 1u) { let df = xi[t] - x[j * d + t]; acc = acc + df * df; }
    \\      } else {
    \\        for (var t = 0u; t < d; t = t + 1u) { let df = x[i * d + t] - x[j * d + t]; acc = acc + df * df; }
    \\      }
    \\      if (acc < worst) { ins(&bd, &bi, k, acc, j); worst = bd[k - 1u]; }
    \\    }
    \\  }
++ KNN_TAIL;

// TILE and TILE4 share a body; the broken sibling is TILE with one index off
fn tileBody(comptime four: bool, comptime broken: bool) []const u8 {
    return PRELUDE ++ KNN_HEAD ++
        \\var<workgroup> tl : array<f32, 4096>;
        \\@compute @workgroup_size(256)
        \\fn main(@builtin(workgroup_id) wid : vec3<u32>, @builtin(local_invocation_id) lid : vec3<u32>) {
        \\  let i = (wid.x + tile.xoff) * 256u + lid.x;
        \\  let n = p.n;
        \\  let d = p.d;
        \\  let k = p.k;
        \\  var xi : array<f32, 64>;
        \\  var bd : array<f32, 64>;
        \\  var bi : array<u32, 64>;
        \\  if (i < n) { for (var t = 0u; t < d; t = t + 1u) { xi[t] = x[i * d + t]; } }
        \\  for (var s = 0u; s < k; s = s + 1u) { bd[s] = 3.0e38; bi[s] = 0u; }
        \\  var worst = 3.0e38;
        \\  let rows_per = 4096u / d;
        \\  for (var b = 0u; b < n; b = b + rows_per) {
        \\    let rows = min(rows_per, n - b);
        \\    workgroupBarrier();
        \\    for (var e = lid.x; e < rows * d; e = e + 256u) { tl[e] = x[b * d + e]; }
        \\    workgroupBarrier();
        \\    if (i < n) {
    ++ (if (four)
        \\      var jj = 0u;
        \\      for (; jj + 4u <= rows; jj = jj + 4u) {
        \\        var a0 = 0.0; var a1 = 0.0; var a2 = 0.0; var a3 = 0.0;
        \\        for (var t = 0u; t < d; t = t + 1u) {
        \\          let xv = xi[t];
        \\          let d0 = xv - tl[jj * d + t]; a0 = a0 + d0 * d0;
        \\          let d1 = xv - tl[(jj + 1u) * d + t]; a1 = a1 + d1 * d1;
        \\          let d2 = xv - tl[(jj + 2u) * d + t]; a2 = a2 + d2 * d2;
        \\          let d3 = xv - tl[(jj + 3u) * d + t]; a3 = a3 + d3 * d3;
        \\        }
        \\        if (b + jj != i && a0 < worst) { ins(&bd, &bi, k, a0, b + jj); worst = bd[k - 1u]; }
        \\        if (b + jj + 1u != i && a1 < worst) { ins(&bd, &bi, k, a1, b + jj + 1u); worst = bd[k - 1u]; }
        \\        if (b + jj + 2u != i && a2 < worst) { ins(&bd, &bi, k, a2, b + jj + 2u); worst = bd[k - 1u]; }
        \\        if (b + jj + 3u != i && a3 < worst) { ins(&bd, &bi, k, a3, b + jj + 3u); worst = bd[k - 1u]; }
        \\      }
        \\      for (; jj < rows; jj = jj + 1u) {
    else
        \\      for (var jj = 0u; jj < rows; jj = jj + 1u) {
    ) ++
        \\        let j = b + jj;
        \\        if (j == i) { continue; }
        \\        var acc = 0.0;
        \\        for (var t = 0u; t < d; t = t + 1u) { let df = xi[t] - tl[jj * d + t]; acc = acc + df * df; }
        \\        if (acc < worst) { ins(&bd, &bi, k, acc, j); worst = bd[k - 1u]; }
        \\      }
        \\    }
        \\  }
    ++ (if (broken)
        \\  if (i == 0u) { bi[k - 1u] = bi[k - 1u] + 1u; }
        \\
    else
        \\
    ) ++ KNN_TAIL;
}

const WGSL_KNN_TILE = tileBody(false, false);
const WGSL_KNN_TILE4 = tileBody(true, false);
const WGSL_KNN_BROKEN = tileBody(false, true);

const WGSL_KNN_CHUNK = PRELUDE ++ KNN_HEAD ++
    \\var<workgroup> tl : array<f32, 2048>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(workgroup_id) wid : vec3<u32>, @builtin(local_invocation_id) lid : vec3<u32>) {
    \\  let i = (wid.x + tile.xoff) * 256u + lid.x;
    \\  let n = p.n;
    \\  let d = p.d;
    \\  let k = p.k;
    \\  var bd : array<f32, 64>;
    \\  var bi : array<u32, 64>;
    \\  for (var s = 0u; s < k; s = s + 1u) { bd[s] = 3.0e38; bi[s] = 0u; }
    \\  var worst = 3.0e38;
    \\  let irow = min(i, n - 1u) * d;
    \\  for (var b = 0u; b < n; b = b + 32u) {
    \\    let rows = min(32u, n - b);
    \\    var acc : array<f32, 32>;
    \\    for (var r = 0u; r < 32u; r = r + 1u) { acc[r] = 0.0; }
    \\    for (var c0 = 0u; c0 < d; c0 = c0 + 64u) {
    \\      let cl = min(64u, d - c0);
    \\      workgroupBarrier();
    \\      for (var e = lid.x; e < rows * cl; e = e + 256u) { let r = e / cl; let t = e - r * cl; tl[r * 64u + t] = x[(b + r) * d + c0 + t]; }
    \\      workgroupBarrier();
    \\      for (var t = 0u; t < cl; t = t + 1u) {
    \\        let xv = x[irow + c0 + t];
    \\        for (var r = 0u; r < 32u; r = r + 1u) { let df = xv - tl[r * 64u + t]; acc[r] = acc[r] + df * df; }
    \\      }
    \\    }
    \\    if (i < n) {
    \\      for (var r = 0u; r < 32u; r = r + 1u) {
    \\        let j = b + r;
    \\        if (r < rows && j != i && acc[r] < worst) { ins(&bd, &bi, k, acc[r], j); worst = bd[k - 1u]; }
    \\      }
    \\    }
    \\  }
++ KNN_TAIL;

const KNN_NAMES = [KNN_VARIANTS][*:0]const u8{ "generic", "tile", "tile4", "chunk", "broken" };

fn knnSource(v: usize) []const u8 {
    return switch (v) {
        KNN_TILE => WGSL_KNN_TILE,
        KNN_TILE4 => WGSL_KNN_TILE4,
        KNN_CHUNK => WGSL_KNN_CHUNK,
        KNN_BROKEN => WGSL_KNN_BROKEN,
        else => WGSL_KNN_GENERIC,
    };
}

/// Can variant v answer shape (n, d, k) at all? The generic always can.
pub fn knnVariantEligible(v: usize, n: usize, d: usize, k: usize) bool {
    if (n < 2 or d == 0 or k == 0 or k > KNN_MAX_K or k >= n) return false;
    return switch (v) {
        KNN_GENERIC => true,
        KNN_TILE, KNN_TILE4, KNN_BROKEN => d <= KNN_STAGE_D,
        KNN_CHUNK => d <= 1024,
        else => false,
    };
}

// the variant table: a decision per shape class (n-class, d-class, k-class),
// written only by the foundry's verdict or an explicit set; the broken
// variant can never enter it
const KnnVariantEntry = struct { cn: u8, cd: u8, ck: u8, v: u8 };
var knn_variants: std.ArrayListUnmanaged(KnnVariantEntry) = .{};

fn findKnnVariant(cn: u8, cd: u8, ck: u8) ?*KnnVariantEntry {
    for (knn_variants.items) |*e| {
        if (e.cn == cn and e.cd == cd and e.ck == ck) return e;
    }
    return null;
}

pub fn stz_umap_knn_variant_set(nf: f64, df: f64, kf: f64, vf: f64) callconv(.c) i32 {
    const v: usize = @intFromFloat(@max(vf, 0));
    if (v >= KNN_REAL) return gpu.BAD_ARG;
    const cn = gpu.shapeClass(nf);
    const cd = gpu.shapeClass(df);
    const ck = gpu.shapeClass(kf);
    if (findKnnVariant(cn, cd, ck)) |e| {
        e.v = @intCast(v);
        return gpu.OK;
    }
    knn_variants.append(alloc, .{ .cn = cn, .cd = cd, .ck = ck, .v = @intCast(v) }) catch return gpu.GPU_ERROR;
    return gpu.OK;
}

pub fn stz_umap_knn_variant_get(nf: f64, df: f64, kf: f64) callconv(.c) f64 {
    if (findKnnVariant(gpu.shapeClass(nf), gpu.shapeClass(df), gpu.shapeClass(kf))) |e| return @floatFromInt(e.v);
    return 0;
}

pub fn stz_umap_knn_variant_clear() callconv(.c) void {
    knn_variants.clearRetainingCapacity();
}

pub fn stz_umap_knn_variant_name(vf: f64) callconv(.c) [*:0]const u8 {
    const v: usize = @intFromFloat(@max(vf, 0));
    if (v >= KNN_VARIANTS) return "";
    return KNN_NAMES[v];
}

/// The variant the table names for this shape, degraded to the generic when
/// it cannot answer the shape (a table row from another k, say).
fn knnVariantFor(n: usize, d: usize, k: usize) usize {
    const e = findKnnVariant(gpu.shapeClass(@floatFromInt(n)), gpu.shapeClass(@floatFromInt(d)), gpu.shapeClass(@floatFromInt(k))) orelse return KNN_GENERIC;
    const v: usize = e.v;
    if (v < KNN_REAL and knnVariantEligible(v, n, d, k)) return v;
    return KNN_GENERIC;
}

const WGSL_STEP = PRELUDE ++
    \\struct P { n : u32, dims : u32, epoch : u32, neg : u32, alpha : f32, a : f32, b : f32, rep : f32, seed : u32, p0 : u32, p1 : u32, p2 : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> yin : array<f32>;
    \\@group(0) @binding(3) var<storage, read_write> yout : array<f32>;
    \\@group(0) @binding(4) var<storage, read> off : array<u32>;
    \\@group(0) @binding(5) var<storage, read> incq : array<u32>;
    \\@group(0) @binding(6) var<storage, read> ince : array<u32>;
    \\@group(0) @binding(7) var<storage, read> eps : array<f32>;
    \\fn mix(v0 : u32) -> u32 {
    \\  var v = v0;
    \\  v = v ^ (v >> 16u); v = v * 0x85EBCA6Bu;
    \\  v = v ^ (v >> 13u); v = v * 0xC2B2AE35u;
    \\  v = v ^ (v >> 16u);
    \\  return v;
    \\}
    \\fn clip4(v : f32) -> f32 { return clamp(v, -4.0, 4.0); }
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(workgroup_id) wid : vec3<u32>, @builtin(local_invocation_id) lid : vec3<u32>) {
    \\  let pt = (wid.x + tile.xoff) * 256u + lid.x;
    \\  let n = p.n;
    \\  let dims = p.dims;
    \\  if (pt >= n) { return; }
    \\  var yp : array<f32, 4>;
    \\  var acc : array<f32, 4>;
    \\  for (var t = 0u; t < dims; t = t + 1u) { yp[t] = yin[pt * dims + t]; acc[t] = 0.0; }
    \\  let te = f32(p.epoch);
    \\  let a = p.a;
    \\  let b = p.b;
    \\  let alpha = p.alpha;
    \\  let c1 = off[pt + 1u];
    \\  for (var c = off[pt]; c < c1; c = c + 1u) {
    \\    let e = ince[c];
    \\    let qr = incq[c];
    \\    let q = qr & 0x7FFFFFFFu;
    \\    let is_i = (qr >> 31u) == 1u;
    \\    let ep = eps[e];
    \\    if (floor((te + 1.0) / ep) <= floor(te / ep)) { continue; }
    \\    var d2 = 0.0;
    \\    for (var t = 0u; t < dims; t = t + 1u) { let df = yp[t] - yin[q * dims + t]; d2 = d2 + df * df; }
    \\    if (d2 > 0.0) {
    \\      let gc = (-2.0 * a * b * pow(d2, b - 1.0)) / (a * pow(d2, b) + 1.0);
    \\      for (var t = 0u; t < dims; t = t + 1u) { acc[t] = acc[t] + clip4(gc * (yp[t] - yin[q * dims + t])) * alpha * 0.5; }
    \\    }
    \\    if (is_i) {
    \\      for (var s = 0u; s < p.neg; s = s + 1u) {
    \\        let kk = mix(p.seed ^ mix(p.epoch * 0x9E3779B9u + e * 0x85EBCA6Bu + s * 0x27D4EB2Fu + 0x165667B1u)) % n;
    \\        if (kk == pt || kk == q) { continue; }
    \\        var dk = 0.0;
    \\        for (var t = 0u; t < dims; t = t + 1u) { let df = yp[t] - yin[kk * dims + t]; dk = dk + df * df; }
    \\        var gr = 4.0;
    \\        if (dk > 0.0) { gr = (2.0 * p.rep * b) / ((0.001 + dk) * (a * pow(dk, b) + 1.0)); }
    \\        for (var t = 0u; t < dims; t = t + 1u) { acc[t] = acc[t] + clip4(gr * (yp[t] - yin[kk * dims + t])) * alpha; }
    \\      }
    \\    }
    \\  }
    \\  for (var t = 0u; t < dims; t = t + 1u) { yout[pt * dims + t] = yp[t] + acc[t]; }
    \\}
;

const KnnParams = extern struct { n: u32, d: u32, k: u32, pad: u32 };
const StepParams = extern struct { n: u32, dims: u32, epoch: u32, neg: u32, alpha: f32, a: f32, b: f32, rep: f32, seed: u32, p0: u32, p1: u32, p2: u32 };

// compiled once per device life; a failed dispatch forgets them so the next
// caller recompiles (the kernel table is reset by a Shutdown)
var k_knn: [KNN_VARIANTS]i64 = @splat(0);
var k_step: i64 = 0;

fn kernelKnn(v: usize) i64 {
    if (k_knn[v] == 0) {
        const src = knnSource(v);
        k_knn[v] = gpu.stz_gpu_kernel_compile(src.ptr, @floatFromInt(src.len));
    }
    return k_knn[v];
}
fn kernelStep() i64 {
    if (k_step == 0) k_step = gpu.stz_gpu_kernel_compile(WGSL_STEP.ptr, @floatFromInt(WGSL_STEP.len));
    return k_step;
}
fn forgetKernels() void {
    k_knn = @splat(0);
    k_step = 0;
}

fn dispatch(kernel: i64, params: []const u8, bufs: []const i64, wx: usize) i32 {
    return gpu.stz_gpu_dispatch_params(kernel, params.ptr, @floatFromInt(params.len), bufs.ptr, @intCast(bufs.len), @floatFromInt(wx), 1);
}

fn freeBuf(id: i64) void {
    if (id != 0) _ = gpu.stz_gpu_buffer_free(id);
}

fn groups(n: usize) usize {
    return (n + 255) / 256;
}

// ---------------------------------------------------------------- k-NN

/// Exact k nearest neighbours on the device: idx_out (n*k, self excluded,
/// nearest first, ties to the lower index) and dist_out (TRUE distances, as
/// umap.zig's contract wants). false = the CPU scans, as before; a refusal
/// after eligibility is counted. `force` is a guard's door past the gate.
pub fn knn(x: []const f64, n: usize, d: usize, k: usize, idx_out: []u32, dist_out: []f64, force: bool) bool {
    if (n < 2 or d == 0 or k == 0 or k > KNN_MAX_K or k >= n) return false;
    if (!force and n < g_knn_min_n) return false;
    if (!tsne_gpu.ensureDevice()) return refuse();
    const xf = alloc.alloc(f32, n * d) catch return refuse();
    defer alloc.free(xf);
    for (x, 0..) |v, i| xf[i] = @floatCast(v);
    const b_x = gpu.stz_gpu_buffer_new(@floatFromInt(n * d * 4));
    defer freeBuf(b_x);
    const b_o = gpu.stz_gpu_buffer_new(@floatFromInt(2 * n * k * 4));
    defer freeBuf(b_o);
    if (b_x == 0 or b_o == 0) return refuse();
    if (gpu.stz_gpu_buffer_write(b_x, @ptrCast(xf.ptr), @floatFromInt(n * d * 4)) != gpu.OK) return refuse();
    const v = knnVariantFor(n, d, k);
    const kern = kernelKnn(v);
    if (kern == 0) return refuse();
    _ = verify.stz_gpu_wake(400);
    const params = KnnParams{ .n = @intCast(n), .d = @intCast(d), .k = @intCast(k), .pad = 0 };
    if (dispatch(kern, std.mem.asBytes(&params), &.{ b_x, b_o }, groups(n)) != gpu.OK) {
        forgetKernels();
        return refuse();
    }
    const outf = alloc.alloc(f32, 2 * n * k) catch return refuse();
    defer alloc.free(outf);
    if (gpu.stz_gpu_buffer_read(b_o, @ptrCast(outf.ptr), @floatFromInt(2 * n * k * 4)) != gpu.OK) return refuse();
    for (0..n * k) |i| {
        dist_out[i] = @sqrt(@as(f64, outf[i]));
        idx_out[i] = @intFromFloat(outf[n * k + i]);
    }
    counters[C_KNN_GPU] += 1;
    if (v != KNN_GENERIC) counters[C_KNN_VARIANT] += 1;
    return true;
}

// ---------------------------------------------------------------- the foundry for the k-NN

pub const F_COUNT = 0; // real variants beyond the generic
pub const F_REF_GPU_MS = 1;
pub const F_REF_WALL_MS = 2;
pub const F_WINNER = 3; // 0 = the generic stays
pub const F_WINNER_RATIO = 4;
pub const F_CLOCKS = 5;
pub const F_HIDDEN_N = 6;
pub const F_BASE = 8; // per variant v: F_BASE + v*5 + {0 verified (-2 not asked, -1 not eligible, 0 refused, 1), 1 gpu_ms, 2 wall_ms, 3 ratio_gpu, 4 ratio_wall}
pub const F_STRIDE = 5;
pub const F_SLOTS = F_BASE + KNN_VARIANTS * F_STRIDE;
var foundry_result: [F_SLOTS]f64 = @splat(0);
pub const MARGIN: f64 = 1.3;

pub fn stz_umap_knn_foundry_result(idx: i32) callconv(.c) f64 {
    if (idx < 0 or idx >= F_SLOTS) return 0;
    return foundry_result[@intCast(idx)];
}

fn fillLcg(id: i64, count: usize, seed: u32) bool {
    const host = alloc.alloc(f32, count) catch return false;
    defer alloc.free(host);
    var r: u32 = seed;
    for (host) |*v| {
        r = r *% 1664525 +% 1013904223;
        v.* = @as(f32, @floatFromInt(r >> 8)) / 16777216.0;
    }
    return gpu.stz_gpu_buffer_write(id, @ptrCast(host.ptr), @floatFromInt(count * 4)) == gpu.OK;
}

/// Enumerate the k-NN variants at shape (n, d, k) under GK0's checker: each
/// against the GENERIC on the same device buffers at this shape and at a
/// hidden one (a different, odd, tile-uneven n with different data), timed
/// on the GPU clock with the device awake; the winner, if it clears the
/// margin, lands in F_WINNER -- the caller records it. `mask` selects
/// variants (bit v); 0 = every real one. The broken variant is reachable
/// only through the mask. The verdicts are slots.
pub fn stz_umap_knn_foundry(nf: f64, df: f64, kf: f64, reps: f64, maskf: f64) callconv(.c) i32 {
    foundry_result = @splat(0);
    if (!tsne_gpu.ensureDevice()) return gpu.FALLBACK;
    const n: usize = @intFromFloat(nf);
    const d: usize = @intFromFloat(df);
    const k: usize = @intFromFloat(kf);
    if (!knnVariantEligible(KNN_GENERIC, n, d, k)) return gpu.BAD_ARG;
    var mask: u32 = @intFromFloat(maskf);
    if (mask == 0) mask = (@as(u32, 1) << KNN_REAL) - 2; // bits 1..KNN_REAL-1
    const n2: usize = @max(k + 1, ((n * 5) / 7) | 1);
    foundry_result[F_COUNT] = @floatFromInt(KNN_REAL - 1);
    foundry_result[F_HIDDEN_N] = @floatFromInt(n2);
    _ = verify.stz_gpu_wake(400);

    const ids = [_]i64{
        gpu.stz_gpu_buffer_new(@floatFromInt(n * d * 4)),
        gpu.stz_gpu_buffer_new(@floatFromInt(2 * n * k * 4)),
        gpu.stz_gpu_buffer_new(@floatFromInt(n2 * d * 4)),
        gpu.stz_gpu_buffer_new(@floatFromInt(2 * n2 * k * 4)),
    };
    defer {
        for (ids) |id| freeBuf(id);
    }
    for (ids) |id| if (id == 0) return gpu.GPU_ERROR;
    if (!fillLcg(ids[0], n * d, 777)) return gpu.GPU_ERROR;
    if (!fillLcg(ids[2], n2 * d, 99991)) return gpu.GPU_ERROR;
    const kref = kernelKnn(KNN_GENERIC);
    if (kref == 0) return gpu.GPU_ERROR;
    const pa = KnnParams{ .n = @intCast(n), .d = @intCast(d), .k = @intCast(k), .pad = 0 };
    const pb = KnnParams{ .n = @intCast(n2), .d = @intCast(d), .k = @intCast(k), .pad = 0 };
    const ba = std.mem.asBytes(&pa);
    const bb = std.mem.asBytes(&pb);
    const ids_a = [_]i64{ ids[0], ids[1] };
    const ids_b = [_]i64{ ids[2], ids[3] };
    // the band: an index that differs is off by >= 1.0; distances differ by
    // f32 accumulation only, and scale with d
    const band: f64 = 1e-4 * @as(f64, @floatFromInt(d));
    var best_v: usize = 0;
    var best_ratio: f64 = 1.0;
    var v: usize = 1;
    while (v < KNN_VARIANTS) : (v += 1) {
        const base = F_BASE + v * F_STRIDE;
        if ((mask & (@as(u32, 1) << @intCast(v))) == 0) {
            foundry_result[base] = -2;
            continue;
        }
        if (!knnVariantEligible(v, n, d, k)) {
            foundry_result[base] = -1;
            continue;
        }
        const kv = kernelKnn(v);
        if (kv == 0) return gpu.GPU_ERROR;
        const st = verify.stz_gpu_verify(kref, kv, ba.ptr, @floatFromInt(ba.len), &ids_a, 2, @floatFromInt(2 * n * k), @floatFromInt(groups(n)), @floatFromInt(groups(n)), bb.ptr, @floatFromInt(bb.len), &ids_b, 2, @floatFromInt(2 * n2 * k), @floatFromInt(groups(n2)), @floatFromInt(groups(n2)), reps, band);
        if (st != gpu.OK) return st;
        const verdict: i32 = @intFromFloat(verify.stz_gpu_verify_result(verify.R_VERDICT));
        const clocks = verify.stz_gpu_verify_result(verify.R_CLOCKS);
        foundry_result[F_CLOCKS] = clocks;
        foundry_result[F_REF_WALL_MS] = verify.stz_gpu_verify_result(verify.R_REF_MS);
        foundry_result[F_REF_GPU_MS] = verify.stz_gpu_verify_result(verify.R_REF_GPU_MS);
        if (verdict != verify.V_VERIFIED) {
            foundry_result[base] = 0; // refused: never a winner
            continue;
        }
        foundry_result[base] = 1;
        foundry_result[base + 1] = verify.stz_gpu_verify_result(verify.R_CAND_GPU_MS);
        foundry_result[base + 2] = verify.stz_gpu_verify_result(verify.R_CAND_MS);
        foundry_result[base + 3] = verify.stz_gpu_verify_result(verify.R_SPEEDUP_GPU);
        foundry_result[base + 4] = verify.stz_gpu_verify_result(verify.R_SPEEDUP);
        const ratio = if (clocks >= 2) foundry_result[base + 3] else foundry_result[base + 4];
        if (v < KNN_REAL and ratio > best_ratio) {
            best_ratio = ratio;
            best_v = v;
        }
    }
    foundry_result[F_WINNER] = if (best_v != 0 and best_ratio >= MARGIN) @floatFromInt(best_v) else 0;
    foundry_result[F_WINNER_RATIO] = best_ratio;
    return gpu.OK;
}

fn refuse() bool {
    counters[C_FALLBACK] += 1;
    return false;
}

// ---------------------------------------------------------------- the trustworthiness witness on the device
//
// Two passes of the k-NN kernel (the input, the embedding) and one RANK pass:
// one thread per (point, embedding-neighbour slot). A neighbour also in the
// input's k set costs nothing; otherwise its input rank is one more than the
// count of points nearer under the kernel's tie rule (equal distance: the
// lower index is nearer), and the penalty is rank - k. The n*k penalties come
// back and are summed here in f64. See trustworthiness.zig for the formula.

const WGSL_TRUST_RANK = PRELUDE ++
    \\struct P { n : u32, d : u32, k : u32, pad : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> x : array<f32>;
    \\@group(0) @binding(3) var<storage, read> kin : array<f32>;
    \\@group(0) @binding(4) var<storage, read> kem : array<f32>;
    \\@group(0) @binding(5) var<storage, read_write> pen : array<f32>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(workgroup_id) wid : vec3<u32>, @builtin(local_invocation_id) lid : vec3<u32>) {
    \\  let t = (wid.x + tile.xoff) * 256u + lid.x;
    \\  let n = p.n;
    \\  let d = p.d;
    \\  let k = p.k;
    \\  if (t >= n * k) { return; }
    \\  let i = t / k;
    \\  let j = u32(kem[n * k + t]);
    \\  for (var s = 0u; s < k; s = s + 1u) {
    \\    if (u32(kin[n * k + i * k + s]) == j) { pen[t] = 0.0; return; }
    \\  }
    \\  var dj = 0.0;
    \\  for (var q = 0u; q < d; q = q + 1u) { let df = x[i * d + q] - x[j * d + q]; dj = dj + df * df; }
    \\  var count = 0u;
    \\  for (var l = 0u; l < n; l = l + 1u) {
    \\    if (l == i || l == j) { continue; }
    \\    var dl = 0.0;
    \\    for (var q = 0u; q < d; q = q + 1u) { let df = x[i * d + q] - x[l * d + q]; dl = dl + df * df; }
    \\    if (dl < dj || (dl == dj && l < j)) { count = count + 1u; }
    \\  }
    \\  pen[t] = f32(count + 1u) - f32(k);
    \\}
;

var k_trust: i64 = 0;
var g_trust_min_n: usize = 1024;

pub fn stz_umap_gpu_set_trust_min_n(nf: f64) callconv(.c) void {
    g_trust_min_n = @intFromFloat(@max(nf, 1));
}
pub fn stz_umap_gpu_trust_min_n() callconv(.c) f64 {
    return @floatFromInt(g_trust_min_n);
}

/// One k-NN pass on the device into `b_out` (2*n*k f32: [d2 | index]).
fn knnInto(b_x: i64, n: usize, d: usize, k: usize, b_out: i64) bool {
    const kern = kernelKnn(KNN_GENERIC);
    if (kern == 0) return false;
    const params = KnnParams{ .n = @intCast(n), .d = @intCast(d), .k = @intCast(k), .pad = 0 };
    return dispatch(kern, std.mem.asBytes(&params), &.{ b_x, b_out }, groups(n)) == gpu.OK;
}

/// The witness on the device; null = the CPU computes it (under the gate,
/// no device, a shape the kernels do not take, or a refusal -- counted).
pub fn trustworthiness(x: []const f64, n: usize, d: usize, y: []const f64, dims: usize, k: usize, force: bool) ?f64 {
    if (n < 2 or d == 0 or d > 1024 or dims == 0 or dims > 1024 or k == 0 or k > KNN_MAX_K or k >= n) return null;
    if (2 * n < 3 * k + 1) return null;
    if (!force and n < g_trust_min_n) return null;
    if (!tsne_gpu.ensureDevice()) {
        counters[C_FALLBACK] += 1;
        return null;
    }
    const xf = alloc.alloc(f32, n * d) catch return refuseT();
    defer alloc.free(xf);
    for (x[0 .. n * d], 0..) |v, i| xf[i] = @floatCast(v);
    const yf = alloc.alloc(f32, n * dims) catch return refuseT();
    defer alloc.free(yf);
    for (y[0 .. n * dims], 0..) |v, i| yf[i] = @floatCast(v);
    const b_x = gpu.stz_gpu_buffer_new(@floatFromInt(n * d * 4));
    defer freeBuf(b_x);
    const b_y = gpu.stz_gpu_buffer_new(@floatFromInt(n * dims * 4));
    defer freeBuf(b_y);
    const b_kin = gpu.stz_gpu_buffer_new(@floatFromInt(2 * n * k * 4));
    defer freeBuf(b_kin);
    const b_kem = gpu.stz_gpu_buffer_new(@floatFromInt(2 * n * k * 4));
    defer freeBuf(b_kem);
    const b_pen = gpu.stz_gpu_buffer_new(@floatFromInt(n * k * 4));
    defer freeBuf(b_pen);
    if (b_x == 0 or b_y == 0 or b_kin == 0 or b_kem == 0 or b_pen == 0) return refuseT();
    if (gpu.stz_gpu_buffer_write(b_x, @ptrCast(xf.ptr), @floatFromInt(n * d * 4)) != gpu.OK) return refuseT();
    if (gpu.stz_gpu_buffer_write(b_y, @ptrCast(yf.ptr), @floatFromInt(n * dims * 4)) != gpu.OK) return refuseT();
    if (k_trust == 0) k_trust = gpu.stz_gpu_kernel_compile(WGSL_TRUST_RANK.ptr, @floatFromInt(WGSL_TRUST_RANK.len));
    if (k_trust == 0) return refuseT();
    _ = verify.stz_gpu_wake(400);
    _ = gpu.stz_gpu_batch_begin();
    var ok = knnInto(b_x, n, d, k, b_kin);
    if (ok) ok = knnInto(b_y, n, dims, k, b_kem);
    if (ok) {
        const params = KnnParams{ .n = @intCast(n), .d = @intCast(d), .k = @intCast(k), .pad = 0 };
        ok = dispatch(k_trust, std.mem.asBytes(&params), &.{ b_x, b_kin, b_kem, b_pen }, groups(n * k)) == gpu.OK;
    }
    _ = gpu.stz_gpu_batch_end();
    if (!ok) {
        forgetKernels();
        k_trust = 0;
        return refuseT();
    }
    const pen = alloc.alloc(f32, n * k) catch return refuseT();
    defer alloc.free(pen);
    if (gpu.stz_gpu_buffer_read(b_pen, @ptrCast(pen.ptr), @floatFromInt(n * k * 4)) != gpu.OK) return refuseT();
    var penalty: f64 = 0;
    for (pen) |v| penalty += @as(f64, v);
    const nf: f64 = @floatFromInt(n);
    const kf: f64 = @floatFromInt(k);
    counters[C_TRUST_GPU] += 1;
    return 1.0 - 2.0 / (nf * kf * (2.0 * nf - 3.0 * kf - 1.0)) * penalty;
}

fn refuseT() ?f64 {
    counters[C_FALLBACK] += 1;
    return null;
}

// ---------------------------------------------------------------- the epoch chain

pub const Session = struct {
    n: usize,
    dims: usize,
    b_y: [2]i64,
    cur: usize, // which of b_y holds the current positions
    b_off: i64,
    b_q: i64,
    b_e: i64,
    b_eps: i64,
    yf: []f32,
    neg: u32,
    a: f32,
    b: f32,
    rep: f32,
    seed: u32,
    epochs: usize,
};

/// Prepare a fit's chain: eligibility, the device, the graph resident as a
/// per-point incidence list, the positions up. `edges` is any slice whose
/// items carry `.i` and `.j`; `eps` is the per-edge sampling interval.
/// null = the CPU loop, with a counted fallback when the fit WAS eligible.
pub fn prepare(edges: anytype, eps: []const f64, y: []const f64, n: usize, dims: usize, a: f64, b: f64, neg: usize, rep: f64, seed: u64, n_epochs: usize) ?Session {
    if (dims == 0 or dims > 4 or n < g_min_n or edges.len == 0) return null;
    if (!tsne_gpu.ensureDevice()) {
        counters[C_FALLBACK] += 1;
        return null;
    }
    const m = edges.len;
    // incidence: for each point, the edges it touches, with the other end and its role
    const off = alloc.alloc(u32, n + 1) catch return refuseS();
    defer alloc.free(off);
    @memset(off, 0);
    for (edges) |e| {
        off[@as(usize, e.i) + 1] += 1;
        off[@as(usize, e.j) + 1] += 1;
    }
    for (0..n) |i| off[i + 1] += off[i];
    const total: usize = off[n];
    const incq = alloc.alloc(u32, total) catch return refuseS();
    defer alloc.free(incq);
    const ince = alloc.alloc(u32, total) catch return refuseS();
    defer alloc.free(ince);
    const cursor = alloc.alloc(u32, n) catch return refuseS();
    defer alloc.free(cursor);
    @memcpy(cursor, off[0..n]);
    for (edges, 0..) |e, ei| {
        const ci = cursor[e.i];
        incq[ci] = e.j | 0x80000000;
        ince[ci] = @intCast(ei);
        cursor[e.i] += 1;
        const cj = cursor[e.j];
        incq[cj] = e.i;
        ince[cj] = @intCast(ei);
        cursor[e.j] += 1;
    }
    const epsf = alloc.alloc(f32, m) catch return refuseS();
    defer alloc.free(epsf);
    for (eps, 0..) |v, i| epsf[i] = @floatCast(v);

    var s = Session{
        .n = n,
        .dims = dims,
        .b_y = .{ gpu.stz_gpu_buffer_new(@floatFromInt(n * dims * 4)), gpu.stz_gpu_buffer_new(@floatFromInt(n * dims * 4)) },
        .cur = 0,
        .b_off = gpu.stz_gpu_buffer_new(@floatFromInt((n + 1) * 4)),
        .b_q = gpu.stz_gpu_buffer_new(@floatFromInt(total * 4)),
        .b_e = gpu.stz_gpu_buffer_new(@floatFromInt(total * 4)),
        .b_eps = gpu.stz_gpu_buffer_new(@floatFromInt(m * 4)),
        .yf = &[_]f32{},
        .neg = @intCast(neg),
        .a = @floatCast(a),
        .b = @floatCast(b),
        .rep = @floatCast(rep),
        .seed = @truncate(seed ^ (seed >> 32)),
        .epochs = n_epochs,
    };
    var ok = s.b_y[0] != 0 and s.b_y[1] != 0 and s.b_off != 0 and s.b_q != 0 and s.b_e != 0 and s.b_eps != 0 and kernelStep() != 0;
    if (ok) ok = gpu.stz_gpu_buffer_write(s.b_off, @ptrCast(off.ptr), @floatFromInt((n + 1) * 4)) == gpu.OK and
        gpu.stz_gpu_buffer_write(s.b_q, @ptrCast(incq.ptr), @floatFromInt(total * 4)) == gpu.OK and
        gpu.stz_gpu_buffer_write(s.b_e, @ptrCast(ince.ptr), @floatFromInt(total * 4)) == gpu.OK and
        gpu.stz_gpu_buffer_write(s.b_eps, @ptrCast(epsf.ptr), @floatFromInt(m * 4)) == gpu.OK;
    if (ok) {
        s.yf = alloc.alloc(f32, n * dims) catch &[_]f32{};
        ok = s.yf.len > 0;
    }
    if (ok) ok = upload(&s, y);
    if (!ok) {
        release(&s);
        counters[C_FALLBACK] += 1;
        return null;
    }
    _ = verify.stz_gpu_wake(400);
    return s;
}

/// Positions up (the density term, or the start).
pub fn upload(s: *Session, y: []const f64) bool {
    for (0..s.n * s.dims) |i| s.yf[i] = @floatCast(y[i]);
    return gpu.stz_gpu_buffer_write(s.b_y[s.cur], @ptrCast(s.yf.ptr), @floatFromInt(s.n * s.dims * 4)) == gpu.OK;
}

/// Positions down.
pub fn download(s: *Session, y: []f64) bool {
    if (gpu.stz_gpu_buffer_read(s.b_y[s.cur], @ptrCast(s.yf.ptr), @floatFromInt(s.n * s.dims * 4)) != gpu.OK) return false;
    for (0..s.n * s.dims) |i| y[i] = @as(f64, s.yf[i]);
    return true;
}

const BATCH_EPOCHS = 256;

/// Run epochs [from, to) on the device, batched. false = a refusal; the
/// caller restarts the fit on the CPU (the positions are not recoverable
/// mid-chain and a deterministic fit restarted from its seed is the same
/// fit). Counted here.
pub fn epochs(s: *Session, from: usize, to: usize, learning_rate: f64) bool {
    var e = from;
    while (e < to) {
        const stop = @min(to, e + BATCH_EPOCHS);
        _ = gpu.stz_gpu_batch_begin();
        var st: i32 = gpu.OK;
        var t = e;
        while (t < stop and st == gpu.OK) : (t += 1) {
            const alpha = learning_rate * (1.0 - @as(f64, @floatFromInt(t)) / @as(f64, @floatFromInt(s.epochs)));
            const params = StepParams{
                .n = @intCast(s.n),
                .dims = @intCast(s.dims),
                .epoch = @intCast(t),
                .neg = s.neg,
                .alpha = @floatCast(alpha),
                .a = s.a,
                .b = s.b,
                .rep = s.rep,
                .seed = s.seed,
                .p0 = 0,
                .p1 = 0,
                .p2 = 0,
            };
            const nxt = 1 - s.cur;
            st = dispatch(kernelStep(), std.mem.asBytes(&params), &.{ s.b_y[s.cur], s.b_y[nxt], s.b_off, s.b_q, s.b_e, s.b_eps }, groups(s.n));
            if (st == gpu.OK) s.cur = nxt;
        }
        _ = gpu.stz_gpu_batch_end();
        if (st != gpu.OK) {
            forgetKernels();
            counters[C_FALLBACK] += 1;
            return false;
        }
        counters[C_EPOCHS_GPU] += @floatFromInt(stop - e);
        e = stop;
    }
    return true;
}

pub fn served(s: *Session) void {
    _ = s;
    counters[C_FITS_GPU] += 1;
}

pub fn release(s: *Session) void {
    freeBuf(s.b_y[0]);
    freeBuf(s.b_y[1]);
    freeBuf(s.b_off);
    freeBuf(s.b_q);
    freeBuf(s.b_e);
    freeBuf(s.b_eps);
    s.b_y = .{ 0, 0 };
    s.b_off = 0;
    s.b_q = 0;
    s.b_e = 0;
    s.b_eps = 0;
    if (s.yf.len > 0) alloc.free(s.yf);
    s.yf = &[_]f32{};
}

fn refuseS() ?Session {
    counters[C_FALLBACK] += 1;
    return null;
}

// ---------------------------------------------------------------- tests

test "the gates refuse without asking the device, and count nothing" {
    counters = @splat(0);
    const saved = g_min_n;
    defer g_min_n = saved;
    g_min_n = 1000;
    const E = struct { i: u32, j: u32 };
    const edges = [_]E{.{ .i = 0, .j = 1 }};
    const eps = [_]f64{1};
    const y = [_]f64{ 0, 0, 1, 1 };
    try std.testing.expect(prepare(edges[0..], eps[0..], y[0..], 2, 2, 1.5, 0.8, 5, 1.0, 42, 10) == null);
    var idx: [4]u32 = undefined;
    var dist: [4]f64 = undefined;
    const x = [_]f64{ 0, 0, 1, 1, 2, 2 };
    try std.testing.expect(!knn(x[0..], 3, 2, 2, idx[0..], dist[0..], false)); // under the gate
    try std.testing.expect(!knn(x[0..], 3, 2, 3, idx[0..], dist[0..], true)); // k >= n: not a shape the kernel takes
    try std.testing.expectEqual(@as(f64, 0), counters[C_FALLBACK]);
}

test "the k-NN variant table never holds the broken sibling, and eligibility names the shapes" {
    stz_umap_knn_variant_clear();
    try std.testing.expect(stz_umap_knn_variant_set(4096, 8, 15, KNN_BROKEN) == gpu.BAD_ARG);
    try std.testing.expect(stz_umap_knn_variant_set(4096, 8, 15, KNN_TILE4) == gpu.OK);
    try std.testing.expectEqual(@as(f64, KNN_TILE4), stz_umap_knn_variant_get(4096, 8, 15));
    try std.testing.expectEqual(@as(f64, 0), stz_umap_knn_variant_get(4096, 128, 15)); // another d-class
    try std.testing.expect(!knnVariantEligible(KNN_TILE, 4096, 128, 15)); // tiles stage the point: d <= 64
    try std.testing.expect(knnVariantEligible(KNN_CHUNK, 4096, 128, 15));
    try std.testing.expect(!knnVariantEligible(KNN_CHUNK, 4096, 2048, 15));
    try std.testing.expectEqual(KNN_GENERIC, knnVariantFor(4096, 128, 15)); // no row: the generic
    _ = stz_umap_knn_variant_set(4096, 128, 15, KNN_TILE); // a row a tile cannot honour at d = 128
    try std.testing.expectEqual(KNN_GENERIC, knnVariantFor(4096, 128, 15)); // degrades, never dispatches an ineligible kernel
    stz_umap_knn_variant_clear();
}
