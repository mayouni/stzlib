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
var counters: [4]f64 = @splat(0);

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

const WGSL_KNN = PRELUDE ++
    \\struct P { n : u32, d : u32, k : u32, pad : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> x : array<f32>;
    \\@group(0) @binding(3) var<storage, read_write> oidx : array<u32>;
    \\@group(0) @binding(4) var<storage, read_write> od2 : array<f32>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(workgroup_id) wid : vec3<u32>, @builtin(local_invocation_id) lid : vec3<u32>) {
    \\  let i = (wid.x + tile.xoff) * 256u + lid.x;
    \\  let n = p.n;
    \\  let d = p.d;
    \\  let k = p.k;
    \\  if (i >= n) { return; }
    \\  var xi : array<f32, 64>;
    \\  var bd : array<f32, 64>;
    \\  var bi : array<u32, 64>;
    \\  let staged = d <= 64u;
    \\  if (staged) { for (var t = 0u; t < d; t = t + 1u) { xi[t] = x[i * d + t]; } }
    \\  for (var s = 0u; s < k; s = s + 1u) { bd[s] = 3.0e38; bi[s] = 0u; }
    \\  var worst = 3.0e38;
    \\  for (var j = 0u; j < n; j = j + 1u) {
    \\    if (j == i) { continue; }
    \\    var acc = 0.0;
    \\    if (staged) {
    \\      for (var t = 0u; t < d; t = t + 1u) { let df = xi[t] - x[j * d + t]; acc = acc + df * df; }
    \\    } else {
    \\      for (var t = 0u; t < d; t = t + 1u) { let df = x[i * d + t] - x[j * d + t]; acc = acc + df * df; }
    \\    }
    \\    if (acc < worst) {
    \\      var pos = k - 1u;
    \\      while (pos > 0u && bd[pos - 1u] > acc) { bd[pos] = bd[pos - 1u]; bi[pos] = bi[pos - 1u]; pos = pos - 1u; }
    \\      bd[pos] = acc;
    \\      bi[pos] = j;
    \\      worst = bd[k - 1u];
    \\    }
    \\  }
    \\  for (var s = 0u; s < k; s = s + 1u) { oidx[i * k + s] = bi[s]; od2[i * k + s] = bd[s]; }
    \\}
;

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
var k_knn: i64 = 0;
var k_step: i64 = 0;

fn kernelKnn() i64 {
    if (k_knn == 0) k_knn = gpu.stz_gpu_kernel_compile(WGSL_KNN.ptr, @floatFromInt(WGSL_KNN.len));
    return k_knn;
}
fn kernelStep() i64 {
    if (k_step == 0) k_step = gpu.stz_gpu_kernel_compile(WGSL_STEP.ptr, @floatFromInt(WGSL_STEP.len));
    return k_step;
}
fn forgetKernels() void {
    k_knn = 0;
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
    const b_i = gpu.stz_gpu_buffer_new(@floatFromInt(n * k * 4));
    defer freeBuf(b_i);
    const b_d = gpu.stz_gpu_buffer_new(@floatFromInt(n * k * 4));
    defer freeBuf(b_d);
    if (b_x == 0 or b_i == 0 or b_d == 0) return refuse();
    if (gpu.stz_gpu_buffer_write(b_x, @ptrCast(xf.ptr), @floatFromInt(n * d * 4)) != gpu.OK) return refuse();
    const kern = kernelKnn();
    if (kern == 0) return refuse();
    _ = verify.stz_gpu_wake(400);
    const params = KnnParams{ .n = @intCast(n), .d = @intCast(d), .k = @intCast(k), .pad = 0 };
    if (dispatch(kern, std.mem.asBytes(&params), &.{ b_x, b_i, b_d }, groups(n)) != gpu.OK) {
        forgetKernels();
        return refuse();
    }
    const d2 = alloc.alloc(f32, n * k) catch return refuse();
    defer alloc.free(d2);
    if (gpu.stz_gpu_buffer_read(b_i, @ptrCast(idx_out.ptr), @floatFromInt(n * k * 4)) != gpu.OK) return refuse();
    if (gpu.stz_gpu_buffer_read(b_d, @ptrCast(d2.ptr), @floatFromInt(n * k * 4)) != gpu.OK) return refuse();
    for (d2, 0..) |v, i| dist_out[i] = @sqrt(@as(f64, v));
    counters[C_KNN_GPU] += 1;
    return true;
}

fn refuse() bool {
    counters[C_FALLBACK] += 1;
    return false;
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
