//! kmeans_gpu.zig -- GS7: Lloyd's k-means assignment on the GPU, a silent
//! seam inside cluster.kmeansRun (SOFTANZA_GPU_PLAN.md, GS7).
//!
//! THE LAW THIS SEAM KEEPS: k-means here is deterministic by design -- the
//! first k distinct points seed, a strict `<` sends a tie to the lower index,
//! convergence is "no assignment changed" checked before the update, an
//! empty cluster keeps its centroid -- and two runs on the same data agree.
//! A device that answered differently from the CPU would break that law on
//! the same data the moment a corpus crossed the gate, or a machine had a
//! GPU. So the device route reproduces the CPU's answer BIT FOR BIT, not
//! approximately.
//!
//! What f32 cannot promise, measured 2026-09-10 (100k x 64 into 16, seeds
//! all in one blob): a point's two best centroids sat 1e-6 to 1e-4 apart in
//! relative terms -- inside f32's accumulated rounding over 64 terms -- and
//! a plain f32 assignment sent whole blobs to the other seed; the CPU itself
//! did not move under a 1e-9 perturbation of the data. Not a bug: a near-tie
//! that f64 resolves and f32 cannot.
//!
//! So the division of labour is:
//!
//!   * the DEVICE assigns every point (one thread per point, the points
//!     transposed so a warp reads consecutive addresses, four centroids per
//!     pass through the row, the argmin fused -- no n x k matrix is ever
//!     written) and keeps the runner-up: when the two best are within the
//!     f32 error bound of each other the point is FLAGGED into a compact
//!     list; an exact tie is flagged too;
//!   * the CPU resolves every flagged point in f64 with cluster.zig's own
//!     nearestCentroid -- the same strict `<` in index order -- and runs the
//!     update in f64 with cluster.zig's own updateCentroids;
//!   * the device only ever sees f32 copies of the CPU's f64 centroids.
//!
//! The labels and the centroids are therefore the CPU's exactly; what moved
//! is the n x k x d of every iteration, minus the flagged few. On a
//! well-seeded corpus almost nothing is flagged after the first iteration;
//! on the pathological seed above, the first iteration flags most points
//! and costs one CPU assignment, and the rest run on the device. The count
//! of resolved points is a counter a guard can read.
//!
//! One submit and one readback per iteration (the CPU is in the loop, so
//! iterations cannot batch); the gate is therefore on the WORK of an
//! iteration, n * k * d, measured against the round trip. Any refusal drops
//! to the CPU loop, exactly as before, and is COUNTED.
//!
//! THE STATS DLL'S DEVICE is tsne_gpu's (one device per DLL, one owner).

const std = @import("std");
const gpu = @import("gpu.zig");
const verify = @import("gpu_verify.zig");
const tsne_gpu = @import("tsne_gpu.zig");
const cluster = @import("cluster.zig");

const alloc = std.heap.c_allocator;

/// The gate on the work of one iteration, n * k * d. Measured 2026-09-10 on
/// the RTX 3050 against the sequential f64 CPU loop, per iteration: 2x at
/// 6 M terms, 4x at 100 M (k = 32), 6x at 330 M (k = 64, d = 256) -- and
/// the whole call carries a fixed cost (the transposed upload, the first
/// iteration's f64 resolution) of 10-30 ms, so the CALL wins from about
/// 100 M terms per iteration and the gate sits at 64 M. Explicitly settable.
var g_min_work: u64 = 64_000_000;

pub const C_ITERS_GPU = 0; // iterations whose assignment ran on the device
pub const C_FALLBACK = 1; // eligible runs the device could not serve
pub const C_RUNS_GPU = 2; // runs served end to end by the device
pub const C_RESOLVED = 3; // points f32 could not certify, resolved by the CPU in f64
var counters: [4]f64 = @splat(0);

pub fn stz_kmeans_gpu_set_min_work(wf: f64) callconv(.c) void {
    g_min_work = @intFromFloat(@max(wf, 1));
}
pub fn stz_kmeans_gpu_min_work() callconv(.c) f64 {
    return @floatFromInt(g_min_work);
}
pub fn stz_kmeans_gpu_counter(i: i32) callconv(.c) f64 {
    if (i < 0 or i >= counters.len) return 0;
    return counters[@intCast(i)];
}
pub fn stz_kmeans_gpu_counters_reset() callconv(.c) void {
    counters = @splat(0);
}

// ---------------------------------------------------------------- the kernel

const PRELUDE =
    \\struct StzTile { xoff : u32, p0 : u32, p1 : u32, p2 : u32 }
    \\@group(0) @binding(0) var<uniform> tile : StzTile;
    \\
;

const MAX_K = 1024;
const MAX_D = 4096;

// xt is the points TRANSPOSED (t * n + i): for a fixed t the threads of a
// warp read consecutive words. cent is k4 rows of d, the rows past k padded
// with 3e38 so their distance is +inf and they never win nor flag.
const WGSL_ASSIGN = PRELUDE ++
    \\struct P { n : u32, d : u32, k4 : u32, k : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> xt : array<f32>;
    \\@group(0) @binding(3) var<storage, read> cent : array<f32>;
    \\@group(0) @binding(4) var<storage, read_write> asg : array<u32>;
    \\@group(0) @binding(5) var<storage, read_write> amb : array<u32>;
    \\@group(0) @binding(6) var<storage, read_write> cnt : array<atomic<u32>>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(workgroup_id) wid : vec3<u32>, @builtin(local_invocation_id) lid : vec3<u32>) {
    \\  let i = (wid.x + tile.xoff) * 256u + lid.x;
    \\  let n = p.n;
    \\  let d = p.d;
    \\  if (i >= n) { return; }
    \\  var best = 0u;
    \\  var bd = 3.0e38;
    \\  var sd = 3.0e38;
    \\  for (var c0 = 0u; c0 < p.k4; c0 = c0 + 4u) {
    \\    var a0 = 0.0;
    \\    var a1 = 0.0;
    \\    var a2 = 0.0;
    \\    var a3 = 0.0;
    \\    let b0 = c0 * d;
    \\    for (var t = 0u; t < d; t = t + 1u) {
    \\      let xv = xt[t * n + i];
    \\      let e0 = xv - cent[b0 + t];
    \\      let e1 = xv - cent[b0 + d + t];
    \\      let e2 = xv - cent[b0 + 2u * d + t];
    \\      let e3 = xv - cent[b0 + 3u * d + t];
    \\      a0 = a0 + e0 * e0;
    \\      a1 = a1 + e1 * e1;
    \\      a2 = a2 + e2 * e2;
    \\      a3 = a3 + e3 * e3;
    \\    }
    \\    if (a0 < bd) { sd = bd; bd = a0; best = c0; } else if (a0 < sd) { sd = a0; }
    \\    if (a1 < bd) { sd = bd; bd = a1; best = c0 + 1u; } else if (a1 < sd) { sd = a1; }
    \\    if (a2 < bd) { sd = bd; bd = a2; best = c0 + 2u; } else if (a2 < sd) { sd = a2; }
    \\    if (a3 < bd) { sd = bd; bd = a3; best = c0 + 3u; } else if (a3 < sd) { sd = a3; }
    \\  }
    \\  asg[i] = best + 1u;
    \\  // f32 cannot certify a margin inside its accumulated rounding: d terms,
    \\  // each within 2^-24 of a value up to the larger distance, twice over
    \\  let thr = f32(d) * 2.4e-7 * (bd + sd);
    \\  if (p.k > 1u && sd - bd <= thr) {
    \\    let slot = atomicAdd(&cnt[0], 1u);
    \\    amb[slot] = i;
    \\  }
    \\}
;

const Params = extern struct { n: u32, d: u32, k4: u32, k: u32 };

var k_assign: i64 = 0;

fn kernel() i64 {
    if (k_assign == 0) k_assign = gpu.stz_gpu_kernel_compile(WGSL_ASSIGN.ptr, @floatFromInt(WGSL_ASSIGN.len));
    return k_assign;
}

fn dispatch(kern: i64, params: *const Params, bufs: []const i64, wx: usize) i32 {
    const bytes = std.mem.asBytes(params);
    return gpu.stz_gpu_dispatch_params(kern, bytes.ptr, @floatFromInt(bytes.len), bufs.ptr, @intCast(bufs.len), @floatFromInt(wx), 1);
}

fn freeBuf(id: i64) void {
    if (id != 0) _ = gpu.stz_gpu_buffer_free(id);
}

/// Eligibility without a device: the work of one iteration reaches the gate,
/// and the shapes the kernel takes.
pub fn eligible(n: usize, d: usize, k: usize) bool {
    if (n < 2 or d == 0 or d > MAX_D or k == 0 or k > MAX_K or k > n) return false;
    const work: u64 = @as(u64, n) * @as(u64, d) * @as(u64, k);
    return work >= g_min_work;
}

/// Run Lloyd's iterations with the assignment on the device, from the
/// seeded `centroids` (k*d, f64): fills `assign` (1-based) and the final
/// centroids -- both the CPU's bits -- and returns the CPU's iteration
/// count. `counts` is the k-entry scratch the CPU update needs. null = the
/// CPU loop, as before; a refusal after eligibility is counted. `force` is a
/// guard's door past the gate.
pub fn run(points: []const f64, n: usize, d: usize, k: usize, max_iter: usize, centroids: []f64, assign: []i32, counts: []usize, force: bool) ?i32 {
    if (max_iter == 0) return null;
    if (!force and !eligible(n, d, k)) return null;
    if (force and (n < 2 or d == 0 or d > MAX_D or k == 0 or k > MAX_K or k > n)) return null;
    if (!tsne_gpu.ensureDevice()) return refuse();

    const k4 = (k + 3) / 4 * 4;
    const xt = alloc.alloc(f32, n * d) catch return refuse();
    defer alloc.free(xt);
    for (0..n) |i| {
        for (0..d) |t| xt[t * n + i] = @floatCast(points[i * d + t]);
    }
    const cf = alloc.alloc(f32, k4 * d) catch return refuse();
    defer alloc.free(cf);
    @memset(cf, 3.0e38);
    const af = alloc.alloc(u32, n) catch return refuse();
    defer alloc.free(af);
    const amb = alloc.alloc(u32, n) catch return refuse();
    defer alloc.free(amb);

    const b_x = gpu.stz_gpu_buffer_new(@floatFromInt(n * d * 4));
    defer freeBuf(b_x);
    const b_c = gpu.stz_gpu_buffer_new(@floatFromInt(k4 * d * 4));
    defer freeBuf(b_c);
    const b_a = gpu.stz_gpu_buffer_new(@floatFromInt(n * 4));
    defer freeBuf(b_a);
    const b_amb = gpu.stz_gpu_buffer_new(@floatFromInt(n * 4));
    defer freeBuf(b_amb);
    const b_cnt = gpu.stz_gpu_buffer_new(16);
    defer freeBuf(b_cnt);
    if (b_x == 0 or b_c == 0 or b_a == 0 or b_amb == 0 or b_cnt == 0) return refuse();
    if (gpu.stz_gpu_buffer_write(b_x, @ptrCast(xt.ptr), @floatFromInt(n * d * 4)) != gpu.OK) return refuse();
    if (kernel() == 0) return refuse();
    _ = verify.stz_gpu_wake(400);

    @memset(assign[0..n], 0);
    const params = Params{ .n = @intCast(n), .d = @intCast(d), .k4 = @intCast(k4), .k = @intCast(k) };
    const groups = (n + 255) / 256;
    var zero = [4]u32{ 0, 0, 0, 0 };
    var word = [4]u32{ 0, 0, 0, 0 };
    var iters: i32 = 0;
    var it: usize = 0;
    while (it < max_iter) : (it += 1) {
        iters = @intCast(it + 1);
        // the CPU's f64 centroids, as f32, to the device; the assignment back
        for (centroids[0 .. k * d], 0..) |v, i| cf[i] = @floatCast(v);
        if (gpu.stz_gpu_buffer_write(b_c, @ptrCast(cf.ptr), @floatFromInt(k4 * d * 4)) != gpu.OK) return refuseMid();
        if (gpu.stz_gpu_buffer_write(b_cnt, @ptrCast(&zero), 16) != gpu.OK) return refuseMid();
        _ = gpu.stz_gpu_batch_begin();
        const st = dispatch(k_assign, &params, &.{ b_x, b_c, b_a, b_amb, b_cnt }, groups);
        _ = gpu.stz_gpu_batch_end();
        if (st != gpu.OK) return refuseMid();
        if (gpu.stz_gpu_buffer_read(b_cnt, @ptrCast(&word), 16) != gpu.OK) return refuseMid();
        if (gpu.stz_gpu_buffer_read(b_a, @ptrCast(af.ptr), @floatFromInt(n * 4)) != gpu.OK) return refuseMid();
        const n_amb: usize = @min(@as(usize, word[0]), n);
        if (n_amb > 0) {
            if (gpu.stz_gpu_buffer_read(b_amb, @ptrCast(amb.ptr), @floatFromInt(n_amb * 4)) != gpu.OK) return refuseMid();
            // the points f32 could not certify: the CPU's rule, in f64
            for (amb[0..n_amb]) |pi| {
                const i: usize = pi;
                af[i] = @intCast(cluster.nearestCentroid(points[i * d ..][0..d], centroids, d, k) + 1);
            }
            counters[C_RESOLVED] += @floatFromInt(n_amb);
        }
        counters[C_ITERS_GPU] += 1;
        var changed = false;
        for (af, 0..) |v, i| {
            const a1: i32 = @intCast(v);
            if (assign[i] != a1) {
                assign[i] = a1;
                changed = true;
            }
        }
        if (!changed) break;
        cluster.updateCentroids(points, n, d, k, assign, counts, centroids);
    }
    counters[C_RUNS_GPU] += 1;
    return iters;
}

fn refuse() ?i32 {
    counters[C_FALLBACK] += 1;
    return null;
}

fn refuseMid() ?i32 {
    k_assign = 0;
    counters[C_FALLBACK] += 1;
    return null;
}

// ---------------------------------------------------------------- tests

test "the work gate refuses without asking the device, and counts nothing" {
    counters = @splat(0);
    const saved = g_min_work;
    defer g_min_work = saved;
    g_min_work = 1_000_000;
    try std.testing.expect(!eligible(100, 4, 3)); // 1,200 terms
    try std.testing.expect(eligible(100_000, 4, 3)); // 1.2 M terms
    try std.testing.expect(!eligible(100_000, 4, 0)); // no clusters
    try std.testing.expect(!eligible(10, 4, 11)); // more clusters than points
    const pts = [_]f64{ 0, 0, 1, 1, 2, 2 };
    var cent = [_]f64{ 0, 0, 2, 2 };
    var asg: [3]i32 = undefined;
    var cnt: [2]usize = undefined;
    try std.testing.expect(run(pts[0..], 3, 2, 2, 10, cent[0..], asg[0..], cnt[0..], false) == null);
    try std.testing.expectEqual(@as(f64, 0), counters[C_FALLBACK]);
}
