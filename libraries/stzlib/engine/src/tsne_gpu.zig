//! tsne_gpu.zig -- GS6a: the t-SNE epoch on the GPU, as a silent seam inside
//! tsne.run (SOFTANZA_GPU_PLAN.md, GS6).
//!
//! The spike (src/gs6_spike.zig, 2026-09-10) measured the chain this module
//! ships: P uploaded ONCE as f32, the positions uploaded per epoch, three
//! dispatches in one batched pass -- per-row q-sums with a shared-memory
//! reduction, a one-workgroup total, a per-row gradient pass that reads each
//! P entry once and RECOMPUTES q from the positions -- the gradient and the
//! KL partials read back. 12x / 38x / 71x over the f64 CPU pass at 1k / 2k /
//! 4k points on the RTX 3050, 6.6x / 19.7x on the Intel iGPU, gradient within
//! 1.2e-7 of f64 relative to its peak; the band written here is 1e-6.
//!
//! THIS DLL OWNS ITS OWN DEVICE (the per-DLL handle law, the neural tier's
//! precedent): stz_stats.dll cannot call into stz_gpu.dll, so gpu.zig is
//! compiled in here too and the Ring loader hands over the runtime's path.
//! No device, no runtime, a shape the kernels do not cover (dims != 2), a
//! corpus under the gate, or any refusal mid-run: the CPU block in tsne.run
//! answers, exactly as before, and the refusal is COUNTED.
//!
//! The optimiser stays where it was: momentum, adaptive gains, the
//! exaggeration schedule, recentering and the density term all run in
//! tsne.run on the gradient this module returns. Only the two n^2 passes
//! moved.

const std = @import("std");
const gpu = @import("gpu.zig");
const verify = @import("gpu_verify.zig");

const alloc = std.heap.c_allocator;

const ST_UNKNOWN: u8 = 0;
const ST_OK: u8 = 1;
const ST_FAILED: u8 = 2;
var g_state: u8 = ST_UNKNOWN;
var g_runtime_path: [512]u8 = @splat(0);
var g_runtime_path_len: usize = 0;

/// The gate: corpora below this stay on the CPU. Measured GO at 1,000
/// (12x); 500 is the conservative default until a calibration pass moves
/// it. Explicitly settable (a guard forces both sides through it).
var g_min_n: usize = 500;

pub const C_EPOCHS_GPU = 0; // epochs served by the device
pub const C_FALLBACK = 1; // eligible fits (or epochs) the device could not serve
pub const C_FITS_GPU = 2; // fits that ran at least one epoch on the device
var counters: [4]f64 = @splat(0);

pub fn stz_tsne_gpu_runtime_path(path: [*]const u8, lenf: f64) callconv(.c) void {
    const len: usize = @intFromFloat(lenf);
    const n = @min(len, g_runtime_path.len - 1);
    @memcpy(g_runtime_path[0..n], path[0..n]);
    g_runtime_path[n] = 0;
    g_runtime_path_len = n;
}

pub fn stz_tsne_gpu_set_min_n(nf: f64) callconv(.c) void {
    g_min_n = @intFromFloat(@max(nf, 1));
}

pub fn stz_tsne_gpu_min_n() callconv(.c) f64 {
    return @floatFromInt(g_min_n);
}

pub fn stz_tsne_gpu_state() callconv(.c) f64 {
    return @floatFromInt(g_state);
}

pub fn stz_tsne_gpu_counter(i: i32) callconv(.c) f64 {
    if (i < 0 or i >= counters.len) return 0;
    return counters[@intCast(i)];
}

pub fn stz_tsne_gpu_counters_reset() callconv(.c) void {
    counters = @splat(0);
}

fn ensureDevice() bool {
    if (g_state != ST_UNKNOWN) return g_state == ST_OK;
    g_state = ST_FAILED;
    if (g_runtime_path_len > 0) {
        const z: [*:0]const u8 = @ptrCast(&g_runtime_path[0]);
        if (gpu.stz_gpu_init(z) == 1) g_state = ST_OK;
    }
    return g_state == ST_OK;
}

// ---------------------------------------------------------------- the kernels

const PRELUDE =
    \\struct StzTile { xoff : u32, p0 : u32, p1 : u32, p2 : u32 }
    \\@group(0) @binding(0) var<uniform> tile : StzTile;
    \\
;

const WGSL_QSUM = PRELUDE ++
    \\struct P { n : u32, dims : u32, ex : f32, pad : f32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> y : array<f32>;
    \\@group(0) @binding(3) var<storage, read_write> qpart : array<f32>;
    \\var<workgroup> sh : array<f32, 256>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(workgroup_id) wid : vec3<u32>, @builtin(local_invocation_id) lid : vec3<u32>) {
    \\  let i = wid.x + tile.xoff;
    \\  var acc = 0.0;
    \\  if (i < p.n) {
    \\    let yi0 = y[i * 2u];
    \\    let yi1 = y[i * 2u + 1u];
    \\    for (var j = lid.x; j < p.n; j = j + 256u) {
    \\      if (j != i) {
    \\        let dx = yi0 - y[j * 2u];
    \\        let dy = yi1 - y[j * 2u + 1u];
    \\        acc = acc + 1.0 / (1.0 + dx * dx + dy * dy);
    \\      }
    \\    }
    \\  }
    \\  sh[lid.x] = acc;
    \\  workgroupBarrier();
    \\  for (var s = 128u; s > 0u; s = s >> 1u) {
    \\    if (lid.x < s) { sh[lid.x] = sh[lid.x] + sh[lid.x + s]; }
    \\    workgroupBarrier();
    \\  }
    \\  if (lid.x == 0u && i < p.n) { qpart[i] = sh[0]; }
    \\}
;

const WGSL_REDUCE = PRELUDE ++
    \\struct P { n : u32, dims : u32, ex : f32, pad : f32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> qpart : array<f32>;
    \\@group(0) @binding(3) var<storage, read_write> qsum : array<f32>;
    \\var<workgroup> sh : array<f32, 256>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(local_invocation_id) lid : vec3<u32>) {
    \\  var acc = 0.0;
    \\  for (var t = lid.x + tile.xoff; t < p.n; t = t + 256u) { acc = acc + qpart[t]; }
    \\  sh[lid.x] = acc;
    \\  workgroupBarrier();
    \\  for (var s = 128u; s > 0u; s = s >> 1u) {
    \\    if (lid.x < s) { sh[lid.x] = sh[lid.x] + sh[lid.x + s]; }
    \\    workgroupBarrier();
    \\  }
    \\  if (lid.x == 0u) { qsum[0] = sh[0]; }
    \\}
;

const WGSL_GRAD = PRELUDE ++
    \\struct P { n : u32, dims : u32, ex : f32, pad : f32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> pm : array<f32>;
    \\@group(0) @binding(3) var<storage, read> y : array<f32>;
    \\@group(0) @binding(4) var<storage, read> qsum : array<f32>;
    \\@group(0) @binding(5) var<storage, read_write> dy : array<f32>;
    \\@group(0) @binding(6) var<storage, read_write> klpart : array<f32>;
    \\var<workgroup> s0 : array<f32, 256>;
    \\var<workgroup> s1 : array<f32, 256>;
    \\var<workgroup> s2 : array<f32, 256>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(workgroup_id) wid : vec3<u32>, @builtin(local_invocation_id) lid : vec3<u32>) {
    \\  let i = wid.x + tile.xoff;
    \\  var a0 = 0.0;
    \\  var a1 = 0.0;
    \\  var kl = 0.0;
    \\  if (i < p.n) {
    \\    let qs = qsum[0];
    \\    let yi0 = y[i * 2u];
    \\    let yi1 = y[i * 2u + 1u];
    \\    let row = i * p.n;
    \\    for (var j = lid.x; j < p.n; j = j + 256u) {
    \\      if (j != i) {
    \\        let dx = yi0 - y[j * 2u];
    \\        let dyv = yi1 - y[j * 2u + 1u];
    \\        let q = 1.0 / (1.0 + dx * dx + dyv * dyv);
    \\        let qij = q / qs;
    \\        let pij = pm[row + j] * p.ex;
    \\        if (pij > 1e-12 && qij > 1e-12) { kl = kl + pij * log(pij / qij); }
    \\        let mult = (pij - qij) * q;
    \\        a0 = a0 + 4.0 * mult * dx;
    \\        a1 = a1 + 4.0 * mult * dyv;
    \\      }
    \\    }
    \\  }
    \\  s0[lid.x] = a0;
    \\  s1[lid.x] = a1;
    \\  s2[lid.x] = kl;
    \\  workgroupBarrier();
    \\  for (var s = 128u; s > 0u; s = s >> 1u) {
    \\    if (lid.x < s) {
    \\      s0[lid.x] = s0[lid.x] + s0[lid.x + s];
    \\      s1[lid.x] = s1[lid.x] + s1[lid.x + s];
    \\      s2[lid.x] = s2[lid.x] + s2[lid.x + s];
    \\    }
    \\    workgroupBarrier();
    \\  }
    \\  if (lid.x == 0u && i < p.n) {
    \\    dy[i * 2u] = s0[0];
    \\    dy[i * 2u + 1u] = s1[0];
    \\    klpart[i] = s2[0];
    \\  }
    \\}
;

const Params = extern struct { n: u32, dims: u32, ex: f32, pad: f32 };

fn compile(text: []const u8) i64 {
    return gpu.stz_gpu_kernel_compile(text.ptr, @floatFromInt(text.len));
}

fn dispatch(kernel: i64, params: *const Params, bufs: []const i64, wx: usize) i32 {
    const bytes = std.mem.asBytes(params);
    return gpu.stz_gpu_dispatch_params(kernel, bytes.ptr, @floatFromInt(bytes.len), bufs.ptr, @intCast(bufs.len), @floatFromInt(wx), 1);
}

// ---------------------------------------------------------------- a fit's session

pub const Session = struct {
    n: usize,
    b_p: i64,
    b_y: i64,
    b_qp: i64,
    b_qs: i64,
    b_dy: i64,
    b_kl: i64,
    k_q: i64,
    k_r: i64,
    k_g: i64,
    yf: []f32,
    dyf: []f32,
    klf: []f32,
    served: bool,
};

fn freeBuf(id: i64) void {
    if (id != 0) _ = gpu.stz_gpu_buffer_free(id);
}

/// Prepare a fit: eligibility, the device, P resident as f32, the buffers.
/// null = the CPU path, with a counted fallback when the fit WAS eligible.
pub fn prepare(p: []const f64, n: usize, dims: usize) ?Session {
    if (dims != 2 or n < g_min_n) return null;
    if (!ensureDevice()) {
        counters[C_FALLBACK] += 1;
        return null;
    }
    const pf = alloc.alloc(f32, n * n) catch {
        counters[C_FALLBACK] += 1;
        return null;
    };
    defer alloc.free(pf);
    for (p, 0..) |v, i| pf[i] = @floatCast(v);

    var s = Session{
        .n = n,
        .b_p = gpu.stz_gpu_buffer_new(@floatFromInt(n * n * 4)),
        .b_y = gpu.stz_gpu_buffer_new(@floatFromInt(n * 2 * 4)),
        .b_qp = gpu.stz_gpu_buffer_new(@floatFromInt(n * 4)),
        .b_qs = gpu.stz_gpu_buffer_new(16),
        .b_dy = gpu.stz_gpu_buffer_new(@floatFromInt(n * 2 * 4)),
        .b_kl = gpu.stz_gpu_buffer_new(@floatFromInt(n * 4)),
        .k_q = compile(WGSL_QSUM),
        .k_r = compile(WGSL_REDUCE),
        .k_g = compile(WGSL_GRAD),
        .yf = &[_]f32{},
        .dyf = &[_]f32{},
        .klf = &[_]f32{},
        .served = false,
    };
    const ok = s.b_p != 0 and s.b_y != 0 and s.b_qp != 0 and s.b_qs != 0 and s.b_dy != 0 and s.b_kl != 0 and
        s.k_q != 0 and s.k_r != 0 and s.k_g != 0 and
        gpu.stz_gpu_buffer_write(s.b_p, @ptrCast(pf.ptr), @floatFromInt(n * n * 4)) == gpu.OK;
    if (!ok) {
        release(&s);
        counters[C_FALLBACK] += 1;
        return null;
    }
    s.yf = alloc.alloc(f32, n * 2) catch {
        release(&s);
        counters[C_FALLBACK] += 1;
        return null;
    };
    s.dyf = alloc.alloc(f32, n * 2) catch {
        release(&s);
        counters[C_FALLBACK] += 1;
        return null;
    };
    s.klf = alloc.alloc(f32, n) catch {
        release(&s);
        counters[C_FALLBACK] += 1;
        return null;
    };
    // a sleeping laptop GPU pays ~2 ms per submit until it is woken (GK1);
    // one wake per fit, before the first epoch, is the cheapest place
    _ = verify.stz_gpu_wake(400);
    return s;
}

/// One epoch: dy (n x 2, f64) and the KL for the record. null = the device
/// refused mid-run; the caller drops to the CPU block and releases.
pub fn epoch(s: *Session, y: []const f64, scale: f64, dy: []f64) ?f64 {
    const n = s.n;
    for (0..n * 2) |i| s.yf[i] = @floatCast(y[i]);
    if (gpu.stz_gpu_buffer_write(s.b_y, @ptrCast(s.yf.ptr), @floatFromInt(n * 2 * 4)) != gpu.OK) return refuse();
    const params = Params{ .n = @intCast(n), .dims = 2, .ex = @floatCast(scale), .pad = 0 };
    _ = gpu.stz_gpu_batch_begin();
    var st = dispatch(s.k_q, &params, &.{ s.b_y, s.b_qp }, n);
    if (st == gpu.OK) st = dispatch(s.k_r, &params, &.{ s.b_qp, s.b_qs }, 1);
    if (st == gpu.OK) st = dispatch(s.k_g, &params, &.{ s.b_p, s.b_y, s.b_qs, s.b_dy, s.b_kl }, n);
    _ = gpu.stz_gpu_batch_end();
    if (st != gpu.OK) return refuse();
    if (gpu.stz_gpu_buffer_read(s.b_dy, @ptrCast(s.dyf.ptr), @floatFromInt(n * 2 * 4)) != gpu.OK) return refuse();
    if (gpu.stz_gpu_buffer_read(s.b_kl, @ptrCast(s.klf.ptr), @floatFromInt(n * 4)) != gpu.OK) return refuse();
    for (0..n * 2) |i| dy[i] = @as(f64, s.dyf[i]);
    var kl: f64 = 0;
    for (s.klf) |v| kl += @as(f64, v);
    counters[C_EPOCHS_GPU] += 1;
    if (!s.served) {
        s.served = true;
        counters[C_FITS_GPU] += 1;
    }
    return kl;
}

fn refuse() ?f64 {
    counters[C_FALLBACK] += 1;
    return null;
}

pub fn release(s: *Session) void {
    freeBuf(s.b_p);
    freeBuf(s.b_y);
    freeBuf(s.b_qp);
    freeBuf(s.b_qs);
    freeBuf(s.b_dy);
    freeBuf(s.b_kl);
    s.b_p = 0;
    s.b_y = 0;
    s.b_qp = 0;
    s.b_qs = 0;
    s.b_dy = 0;
    s.b_kl = 0;
    if (s.yf.len > 0) alloc.free(s.yf);
    if (s.dyf.len > 0) alloc.free(s.dyf);
    if (s.klf.len > 0) alloc.free(s.klf);
    s.yf = &[_]f32{};
    s.dyf = &[_]f32{};
    s.klf = &[_]f32{};
}

test "the gate refuses shapes the kernels do not cover, without touching a device" {
    g_min_n = 500;
    var p = [_]f64{0} ** 16;
    try std.testing.expect(prepare(&p, 4, 2) == null); // under the gate
    try std.testing.expect(prepare(&p, 4, 3) == null); // dims != 2
    try std.testing.expectEqual(@as(f64, 0), stz_tsne_gpu_counter(C_FALLBACK)); // neither is a fallback
}
