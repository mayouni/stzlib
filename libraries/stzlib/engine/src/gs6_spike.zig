//! GS6 SPIKE -- measurement only, no product code (SOFTANZA_GPU_PLAN.md, GS6).
//!
//! The question, asked once: does the ML tier's per-epoch O(n^2) kernel --
//! t-SNE's klGradient, two passes over an n x n matrix per epoch, a thousand
//! epochs per fit -- pay on the GPU as a RESIDENT chain (P uploaded once as
//! f32, y uploaded per epoch, the gradient and KL read back per epoch)?
//!
//! KILL CRITERIA, written before the numbers:
//!   GO   if at n = 4000 the GPU epoch is >= 3x faster than tsne.zig's f64
//!        klGradient (a 1000-epoch fit moves from tens of seconds to seconds)
//!        AND the gradient agrees within 1e-4 of the f64 one, relative to the
//!        gradient's peak (f32 accumulation order; the optimiser's step
//!        direction, on a stochastic method)
//!   NO-GO otherwise -- recorded, and GS6 stays a survey row.
//!   The memory wall is measured beside: P is n^2 f32 on the device.
//!
//! Lives in src/ because Zig forbids ../ imports from tools/ and this drives
//! the REAL gpu.zig and tsne.zig, not copies.
//!
//! Build (from libraries/stzlib/engine):
//!     zig build-exe -j2 src/gs6_spike.zig -OReleaseSafe -I vendor/wgpu/include -lc --name gs6_spike
//! Run: gs6_spike <path-to-wgpu_native.dll> [n ...]

const std = @import("std");
const gpu = @import("gpu.zig");
const verify = @import("gpu_verify.zig");
const tsne = @import("tsne.zig");

const alloc = std.heap.c_allocator;

const PRELUDE =
    \\struct StzTile { xoff : u32, p0 : u32, p1 : u32, p2 : u32 }
    \\@group(0) @binding(0) var<uniform> tile : StzTile;
    \\
;

// one workgroup per row i: qpart[i] = sum_{j != i} 1 / (1 + |y_i - y_j|^2)
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

// qsum[0] = sum of the partials (one workgroup)
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

// one workgroup per row i: dy[i] and the KL partial, reading P once
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

fn ms(ns: u64) f64 {
    return @as(f64, @floatFromInt(ns)) / 1e6;
}

fn lcg(state: *u64) f64 {
    state.* = state.* *% 6364136223846793005 +% 1442695040888963407;
    return @as(f64, @floatFromInt(state.* >> 11)) / 9007199254740992.0;
}

fn runSize(n: usize, d: usize) !void {
    std.debug.print("\n=== n = {d}, d = {d}, perplexity 30, 2-D ===\n", .{ n, d });
    // clustered data: 8 blobs, so P has structure
    const x = try alloc.alloc(f64, n * d);
    defer alloc.free(x);
    var rng: u64 = 42;
    for (0..n) |i| {
        const blob: f64 = @floatFromInt(i % 8);
        for (0..d) |k| x[i * d + k] = blob * 3.0 * @as(f64, @floatFromInt((k + @as(usize, @intFromFloat(blob))) % 2)) + (lcg(&rng) - 0.5);
    }
    const p = try alloc.alloc(f64, n * n);
    defer alloc.free(p);
    var t = try std.time.Timer.start();
    try tsne.jointP(alloc, x, n, d, 30, p);
    std.debug.print("  P built (jointP, CPU): {d:.0} ms\n", .{ms(t.read())});

    const y = try alloc.alloc(f64, n * 2);
    defer alloc.free(y);
    for (y) |*v| v.* = (lcg(&rng) - 0.5) * 1e-2;
    const q_num = try alloc.alloc(f64, n * n);
    defer alloc.free(q_num);
    const dy_cpu = try alloc.alloc(f64, n * 2);
    defer alloc.free(dy_cpu);

    // CPU: one epoch of klGradient, warm 1, min of 5
    _ = tsne.klGradient(p, y, n, 2, 12.0, q_num, dy_cpu);
    var cpu_best: f64 = std.math.inf(f64);
    var kl_cpu: f64 = 0;
    for (0..5) |_| {
        t.reset();
        kl_cpu = tsne.klGradient(p, y, n, 2, 12.0, q_num, dy_cpu);
        cpu_best = @min(cpu_best, ms(t.read()));
    }
    std.debug.print("  CPU klGradient per epoch (f64, min of 5): {d:.2} ms   KL {d:.6}\n", .{ cpu_best, kl_cpu });

    // GPU: P resident as f32, y per epoch, 3 dispatches in one batch, dy + kl back
    const pf = try alloc.alloc(f32, n * n);
    defer alloc.free(pf);
    for (p, 0..) |v, i| pf[i] = @floatCast(v);
    const yf = try alloc.alloc(f32, n * 2);
    defer alloc.free(yf);
    for (y, 0..) |v, i| yf[i] = @floatCast(v);

    const b_p = gpu.stz_gpu_buffer_new(@floatFromInt(n * n * 4));
    const b_y = gpu.stz_gpu_buffer_new(@floatFromInt(n * 2 * 4));
    const b_qp = gpu.stz_gpu_buffer_new(@floatFromInt(n * 4));
    const b_qs = gpu.stz_gpu_buffer_new(16);
    const b_dy = gpu.stz_gpu_buffer_new(@floatFromInt(n * 2 * 4));
    const b_kl = gpu.stz_gpu_buffer_new(@floatFromInt(n * 4));
    if (b_p == 0 or b_y == 0 or b_qp == 0 or b_qs == 0 or b_dy == 0 or b_kl == 0) {
        std.debug.print("  device buffers refused (VRAM? {d} MB for P): {s}\n", .{ n * n * 4 / (1024 * 1024), gpu.lastError() });
        return;
    }
    defer {
        _ = gpu.stz_gpu_buffer_free(b_p);
        _ = gpu.stz_gpu_buffer_free(b_y);
        _ = gpu.stz_gpu_buffer_free(b_qp);
        _ = gpu.stz_gpu_buffer_free(b_qs);
        _ = gpu.stz_gpu_buffer_free(b_dy);
        _ = gpu.stz_gpu_buffer_free(b_kl);
    }
    t.reset();
    _ = gpu.stz_gpu_buffer_write(b_p, @ptrCast(pf.ptr), @floatFromInt(n * n * 4));
    _ = gpu.stz_gpu_sync();
    std.debug.print("  P uploaded once as f32 ({d} MB): {d:.2} ms\n", .{ n * n * 4 / (1024 * 1024), ms(t.read()) });

    const k_q = compile(WGSL_QSUM);
    const k_r = compile(WGSL_REDUCE);
    const k_g = compile(WGSL_GRAD);
    if (k_q == 0 or k_r == 0 or k_g == 0) {
        std.debug.print("  kernel compile refused: {s}\n", .{gpu.lastError()});
        return;
    }
    const params = Params{ .n = @intCast(n), .dims = 2, .ex = 12.0, .pad = 0 };
    const dy_gpu = try alloc.alloc(f32, n * 2);
    defer alloc.free(dy_gpu);
    const kl_part = try alloc.alloc(f32, n);
    defer alloc.free(kl_part);

    _ = verify.stz_gpu_wake(400);
    var gpu_best: f64 = std.math.inf(f64);
    var kl_gpu: f64 = 0;
    for (0..6) |rep| {
        t.reset();
        _ = gpu.stz_gpu_buffer_write(b_y, @ptrCast(yf.ptr), @floatFromInt(n * 2 * 4));
        _ = gpu.stz_gpu_batch_begin();
        var st = dispatch(k_q, &params, &.{ b_y, b_qp }, n);
        if (st == gpu.OK) st = dispatch(k_r, &params, &.{ b_qp, b_qs }, 1);
        if (st == gpu.OK) st = dispatch(k_g, &params, &.{ b_p, b_y, b_qs, b_dy, b_kl }, n);
        _ = gpu.stz_gpu_batch_end();
        if (st != gpu.OK) {
            std.debug.print("  dispatch refused ({d}): {s}\n", .{ st, gpu.lastError() });
            return;
        }
        _ = gpu.stz_gpu_buffer_read(b_dy, @ptrCast(dy_gpu.ptr), @floatFromInt(n * 2 * 4));
        _ = gpu.stz_gpu_buffer_read(b_kl, @ptrCast(kl_part.ptr), @floatFromInt(n * 4));
        const e = ms(t.read());
        if (rep > 0) gpu_best = @min(gpu_best, e);
        kl_gpu = 0;
        for (kl_part) |v| kl_gpu += @as(f64, v);
    }

    // agreement: gradient relative to its own peak, KL relative
    var peak: f64 = 0;
    for (dy_cpu) |v| peak = @max(peak, @abs(v));
    var maxd: f64 = 0;
    for (dy_cpu, 0..) |v, i| maxd = @max(maxd, @abs(v - @as(f64, dy_gpu[i])));
    const rel = if (peak > 0) maxd / peak else 0;
    const klrel = if (kl_cpu != 0) @abs(kl_gpu - kl_cpu) / @abs(kl_cpu) else 0;
    std.debug.print("  GPU epoch (y up + 3 dispatches in one batch + dy/kl back, min of 5): {d:.3} ms   KL {d:.6}\n", .{ gpu_best, kl_gpu });
    std.debug.print("  gradient max |gpu - cpu| / peak: {e:.2}   KL rel diff: {e:.2}\n", .{ rel, klrel });
    std.debug.print("  RATIO cpu/gpu per epoch: {d:.1}x   -> a 1000-epoch fit: CPU {d:.1} s vs GPU {d:.2} s\n", .{ cpu_best / gpu_best, cpu_best, gpu_best });
    const go = (cpu_best / gpu_best >= 3.0) and (rel < 1e-4);
    std.debug.print("  verdict at this size: {s}\n", .{if (go) "GO (>= 3x, gradient within 1e-4)" else "NO-GO"});
}

pub fn main() !void {
    const argv = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, argv);
    if (argv.len < 2) {
        std.debug.print("usage: gs6_spike <wgpu_native.dll> [n ...]" ++ [_]u8{10}, .{});
        return;
    }
    const dll = argv[1];
    const dllz = try alloc.dupeZ(u8, dll);
    if (gpu.stz_gpu_init(dllz) == 0) {
        std.debug.print("no device: {s}\n", .{gpu.lastError()});
        return;
    }
    // "adapter=N" among the args selects an adapter (the kill line's habit: both)
    for (argv[2..]) |a| {
        if (std.mem.startsWith(u8, a, "adapter=")) {
            const idx = try std.fmt.parseInt(i32, a[8..], 10);
            if (gpu.stz_gpu_select_adapter(idx) == 0) {
                std.debug.print("adapter {d} could not be opened: {s}" ++ [_]u8{10}, .{ idx, gpu.lastError() });
                return;
            }
        }
    }
    var name: [128]u8 = undefined;
    const nl = gpu.stz_gpu_adapter_name(gpu.stz_gpu_selected_adapter(), &name, @intCast(name.len));
    std.debug.print("device: {s}\n", .{name[0..@intCast(@max(nl, 0))]});
    var any = false;
    for (argv[2..]) |a| {
        if (std.mem.startsWith(u8, a, "adapter=")) continue;
        any = true;
        const n = try std.fmt.parseInt(usize, a, 10);
        try runSize(n, 16);
    }
    if (!any) {
        try runSize(1000, 16);
        try runSize(2000, 16);
        try runSize(4000, 16);
    }
    gpu.stz_gpu_shutdown();
}
