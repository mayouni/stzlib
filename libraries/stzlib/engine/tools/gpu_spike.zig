//! G0 GPU crossover spike -- measurement only, no product code.
//!
//! Plan of record: libraries/stzlib/base/gpu/SOFTANZA_GPU_PLAN.md (phase G0).
//! This standalone exe produces the {upload, dispatch, readback} decomposition
//! table for TWO kernels (saxpy, f32 tiled matmul) across sizes and adapters,
//! against in-process CPU baselines (including a verbatim copy of the engine's
//! i-k-j f64 matmul loop -- the 15.6 GFLOP/s baseline from src/matrix.zig).
//! G1 grows this into stz_gpu.dll; nothing here is a public surface.
//!
//! Build (from libraries/stzlib/engine, out-of-tree emit keeps the repo clean):
//!     zig build-exe tools/gpu_spike.zig -OReleaseSafe -I vendor/wgpu/include \
//!         vendor/wgpu/lib/wgpu_native.dll.lib -lc --name gpu_spike
//! Run (wgpu_native.dll must sit next to the exe or on PATH):
//!     gpu_spike list           -- enumerate adapters with indices
//!     gpu_spike cpu            -- CPU baselines only (run FIRST, uncontended)
//!     gpu_spike run <index>    -- full GPU suite on adapter <index>
//!
//! Methodology (the house timing laws):
//!   - monotonic clock only (std.time.Timer)
//!   - warm = 3 warmups then 5 timed reps, min AND median reported
//!   - sustained = 3 s continuous, first 1 s discarded (laptop clocks lie)
//!   - CPU samples inner-loop scaled until a rep is >= ~1 ms
//!   - every GPU op timed as submit + wait-idle: the price a silent service
//!     actually pays per call, submission overhead included
//!   - chain10 = 10 dispatches in ONE pass, amortized /10: the resident-chain
//!     number the kill criteria ask about (upload once -> N kernels -> read once)

const std = @import("std");
const c = @cImport({
    @cInclude("webgpu/webgpu.h");
    @cInclude("webgpu/wgpu.h");
});

const alloc = std.heap.c_allocator;

// ---------------------------------------------------------------- sizes

const SAXPY_SIZES = [_]usize{ 4096, 65536, 262144, 1048576, 4194304 };
const MATMUL_SIZES = [_]usize{ 64, 128, 256, 512, 1024, 2048 };

const WARMUPS = 3;
const REPS = 5; // house rule: 5 runs minimum
const SUSTAIN_TOTAL_NS: u64 = 3_000_000_000;
const SUSTAIN_SKIP_NS: u64 = 1_000_000_000;
const SUSTAIN_MAX_ITERS = 4096;
const CPU_TARGET_NS: u64 = 1_000_000; // scale reps until a sample is measurable

// ---------------------------------------------------------------- WGSL

const WGSL_SAXPY =
    \\struct Params { n: u32, a: f32 }
    \\@group(0) @binding(0) var<uniform> p: Params;
    \\@group(0) @binding(1) var<storage, read> x: array<f32>;
    \\@group(0) @binding(2) var<storage, read_write> y: array<f32>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid: vec3<u32>) {
    \\  let i = gid.x;
    \\  if (i < p.n) { y[i] = p.a * x[i] + y[i]; }
    \\}
;

// 16x16 workgroup-memory tiles: the standard portable WGSL matmul shape.
// Deliberately NOT further tuned (no per-thread register blocking) -- G0 asks
// whether the floor beats CPU, not what the ceiling is.
const WGSL_MATMUL =
    \\struct Dims { m: u32, k: u32, n: u32, pad: u32 }
    \\@group(0) @binding(0) var<uniform> d: Dims;
    \\@group(0) @binding(1) var<storage, read> a: array<f32>;
    \\@group(0) @binding(2) var<storage, read> b: array<f32>;
    \\@group(0) @binding(3) var<storage, read_write> cc: array<f32>;
    \\var<workgroup> ta: array<f32, 256>;
    \\var<workgroup> tb: array<f32, 256>;
    \\@compute @workgroup_size(16, 16)
    \\fn main(@builtin(global_invocation_id) gid: vec3<u32>,
    \\        @builtin(local_invocation_id) lid: vec3<u32>) {
    \\  let row = gid.y;
    \\  let col = gid.x;
    \\  var acc = 0.0;
    \\  let tiles = (d.k + 15u) / 16u;
    \\  for (var t = 0u; t < tiles; t = t + 1u) {
    \\    let k0 = t * 16u;
    \\    let acol = k0 + lid.x;
    \\    let brow = k0 + lid.y;
    \\    ta[lid.y * 16u + lid.x] = select(0.0, a[row * d.k + acol], row < d.m && acol < d.k);
    \\    tb[lid.y * 16u + lid.x] = select(0.0, b[brow * d.n + col], brow < d.k && col < d.n);
    \\    workgroupBarrier();
    \\    for (var k = 0u; k < 16u; k = k + 1u) {
    \\      acc = acc + ta[lid.y * 16u + k] * tb[k * 16u + lid.x];
    \\    }
    \\    workgroupBarrier();
    \\  }
    \\  if (row < d.m && col < d.n) { cc[row * d.n + col] = acc; }
    \\}
;

// ---------------------------------------------------------------- helpers

fn sv(s: []const u8) c.WGPUStringView {
    return .{ .data = s.ptr, .length = s.len };
}

fn svSlice(v: c.WGPUStringView) []const u8 {
    if (v.data == null) return "";
    if (v.length == std.math.maxInt(usize)) return std.mem.span(@as([*:0]const u8, @ptrCast(v.data)));
    return v.data[0..v.length];
}

fn backendName(t: c.WGPUBackendType) []const u8 {
    return switch (t) {
        c.WGPUBackendType_D3D12 => "D3D12",
        c.WGPUBackendType_Vulkan => "Vulkan",
        c.WGPUBackendType_Metal => "Metal",
        c.WGPUBackendType_OpenGL => "OpenGL",
        c.WGPUBackendType_OpenGLES => "OpenGLES",
        else => "other",
    };
}

const Stats = struct {
    min_ns: u64,
    med_ns: u64,

    fn from(samples: []u64) Stats {
        std.mem.sort(u64, samples, {}, std.sort.asc(u64));
        return .{ .min_ns = samples[0], .med_ns = samples[samples.len / 2] };
    }
};

fn ms(ns: u64) f64 {
    return @as(f64, @floatFromInt(ns)) / 1e6;
}

fn gflops(flops: usize, ns: u64) f64 {
    if (ns == 0) return 0;
    return @as(f64, @floatFromInt(flops)) / @as(f64, @floatFromInt(ns));
}

fn gbps(bytes: usize, ns: u64) f64 {
    if (ns == 0) return 0;
    return @as(f64, @floatFromInt(bytes)) / @as(f64, @floatFromInt(ns));
}

fn fillRandomF32(buf: []f32, seed: u64) void {
    var prng = std.Random.DefaultPrng.init(seed);
    const r = prng.random();
    for (buf) |*v| v.* = r.float(f32);
}

fn fillRandomF64(buf: []f64, seed: u64) void {
    var prng = std.Random.DefaultPrng.init(seed);
    const r = prng.random();
    for (buf) |*v| v.* = r.float(f64);
}

// ---------------------------------------------------------------- CPU kernels

fn cpuSaxpyF32(a: f32, x: []const f32, y: []f32) void {
    const W = std.simd.suggestVectorLength(f32) orelse 8;
    const V = @Vector(W, f32);
    const splat: V = @splat(a);
    var i: usize = 0;
    while (i + W <= y.len) : (i += W) {
        const xv: V = x[i..][0..W].*;
        const yv: V = y[i..][0..W].*;
        y[i..][0..W].* = yv + splat * xv;
    }
    while (i < y.len) : (i += 1) y[i] += a * x[i];
}

fn cpuSaxpyF64(a: f64, x: []const f64, y: []f64) void {
    const W = std.simd.suggestVectorLength(f64) orelse 4;
    const V = @Vector(W, f64);
    const splat: V = @splat(a);
    var i: usize = 0;
    while (i + W <= y.len) : (i += W) {
        const xv: V = x[i..][0..W].*;
        const yv: V = y[i..][0..W].*;
        y[i..][0..W].* = yv + splat * xv;
    }
    while (i < y.len) : (i += 1) y[i] += a * x[i];
}

// Verbatim shape of src/matrix.zig stz_matrix_multiply -- the shipped
// i-k-j + @Vector loop that measures 15.6 GFLOP/s f64. Copied, not imported:
// the spike must not couple to engine internals, and the loop IS the baseline.
fn cpuMatmulF64(av: []const f64, bv: []const f64, cv: []f64, n: usize) void {
    const W = std.simd.suggestVectorLength(f64) orelse 4;
    const V = @Vector(W, f64);
    @memset(cv, 0);
    for (0..n) |i| {
        const c_row = cv[i * n .. i * n + n];
        for (0..n) |k| {
            const aik = av[i * n + k];
            const b_row = bv[k * n .. k * n + n];
            const splat: V = @splat(aik);
            var j: usize = 0;
            while (j + W <= n) : (j += W) {
                const bvec: V = b_row[j..][0..W].*;
                const cvec: V = c_row[j..][0..W].*;
                c_row[j..][0..W].* = cvec + splat * bvec;
            }
            while (j < n) : (j += 1) c_row[j] += aik * b_row[j];
        }
    }
}

// Same loop at f32 -- the honest same-precision comparison the table needs.
fn cpuMatmulF32(av: []const f32, bv: []const f32, cv: []f32, n: usize) void {
    const W = std.simd.suggestVectorLength(f32) orelse 8;
    const V = @Vector(W, f32);
    @memset(cv, 0);
    for (0..n) |i| {
        const c_row = cv[i * n .. i * n + n];
        for (0..n) |k| {
            const aik = av[i * n + k];
            const b_row = bv[k * n .. k * n + n];
            const splat: V = @splat(aik);
            var j: usize = 0;
            while (j + W <= n) : (j += W) {
                const bvec: V = b_row[j..][0..W].*;
                const cvec: V = c_row[j..][0..W].*;
                c_row[j..][0..W].* = cvec + splat * bvec;
            }
            while (j < n) : (j += 1) c_row[j] += aik * b_row[j];
        }
    }
}

// ---------------------------------------------------------------- CPU phase

fn timeCpu(comptime f: anytype, args: anytype) Stats {
    // calibrate inner reps so one sample is measurable (timing-assertions law)
    var timer = std.time.Timer.start() catch unreachable;
    @call(.auto, f, args);
    const once = timer.read();
    const inner: usize = if (once >= CPU_TARGET_NS) 1 else @intCast(CPU_TARGET_NS / @max(once, 1) + 1);

    var samples: [REPS]u64 = undefined;
    for (0..WARMUPS) |_| @call(.auto, f, args);
    for (&samples) |*s| {
        timer.reset();
        for (0..inner) |_| @call(.auto, f, args);
        s.* = timer.read() / inner;
    }
    return Stats.from(&samples);
}

fn runCpuPhase() !void {
    std.debug.print("== CPU BASELINES (ReleaseSafe, the shipped mode) ==\n", .{});
    std.debug.print("-- saxpy: y = a*x + y --\n", .{});
    for (SAXPY_SIZES) |n| {
        const x32 = try alloc.alloc(f32, n);
        defer alloc.free(x32);
        const y32 = try alloc.alloc(f32, n);
        defer alloc.free(y32);
        fillRandomF32(x32, 1);
        fillRandomF32(y32, 2);
        const s32 = timeCpu(cpuSaxpyF32, .{ @as(f32, 2.5), x32, y32 });

        const x64 = try alloc.alloc(f64, n);
        defer alloc.free(x64);
        const y64 = try alloc.alloc(f64, n);
        defer alloc.free(y64);
        fillRandomF64(x64, 1);
        fillRandomF64(y64, 2);
        const s64 = timeCpu(cpuSaxpyF64, .{ @as(f64, 2.5), x64, y64 });

        const flops = 2 * n;
        std.debug.print(
            "n={d:>8}  f32 min {d:>10.4} ms ({d:>7.2} GFLOP/s, {d:>6.2} GB/s)  med {d:>10.4} | f64 min {d:>10.4} ms ({d:>7.2} GFLOP/s, {d:>6.2} GB/s)  med {d:>10.4}\n",
            .{
                n,
                ms(s32.min_ns),
                gflops(flops, s32.min_ns),
                gbps(n * 4 * 3, s32.min_ns), // read x, read y, write y
                ms(s32.med_ns),
                ms(s64.min_ns),
                gflops(flops, s64.min_ns),
                gbps(n * 8 * 3, s64.min_ns),
                ms(s64.med_ns),
            },
        );
    }

    std.debug.print("-- matmul: C = A*B, square n, i-k-j + @Vector (the engine loop) --\n", .{});
    for (MATMUL_SIZES) |n| {
        const a32 = try alloc.alloc(f32, n * n);
        defer alloc.free(a32);
        const b32 = try alloc.alloc(f32, n * n);
        defer alloc.free(b32);
        const c32 = try alloc.alloc(f32, n * n);
        defer alloc.free(c32);
        fillRandomF32(a32, 3);
        fillRandomF32(b32, 4);
        const s32 = timeCpu(cpuMatmulF32, .{ a32, b32, c32, n });

        const a64 = try alloc.alloc(f64, n * n);
        defer alloc.free(a64);
        const b64 = try alloc.alloc(f64, n * n);
        defer alloc.free(b64);
        const c64 = try alloc.alloc(f64, n * n);
        defer alloc.free(c64);
        fillRandomF64(a64, 3);
        fillRandomF64(b64, 4);
        const s64 = timeCpu(cpuMatmulF64, .{ a64, b64, c64, n });

        const flops = 2 * n * n * n;
        std.debug.print(
            "n={d:>5}  f32 min {d:>10.3} ms ({d:>7.2} GFLOP/s)  med {d:>10.3} | f64 min {d:>10.3} ms ({d:>7.2} GFLOP/s)  med {d:>10.3}\n",
            .{ n, ms(s32.min_ns), gflops(flops, s32.min_ns), ms(s32.med_ns), ms(s64.min_ns), gflops(flops, s64.min_ns), ms(s64.med_ns) },
        );
    }
}

// ---------------------------------------------------------------- GPU plumbing

var g_device_ready = false;
var g_device: c.WGPUDevice = null;
var g_map_done = false;
var g_map_ok = false;

fn onDevice(status: c.WGPURequestDeviceStatus, device: c.WGPUDevice, message: c.WGPUStringView, _: ?*anyopaque, _: ?*anyopaque) callconv(.c) void {
    if (status == c.WGPURequestDeviceStatus_Success) {
        g_device = device;
    } else {
        std.debug.print("RequestDevice FAILED: {s}\n", .{svSlice(message)});
    }
    g_device_ready = true;
}

fn onMap(status: c.WGPUMapAsyncStatus, message: c.WGPUStringView, _: ?*anyopaque, _: ?*anyopaque) callconv(.c) void {
    g_map_ok = status == c.WGPUMapAsyncStatus_Success;
    if (!g_map_ok) std.debug.print("MapAsync FAILED: {s}\n", .{svSlice(message)});
    g_map_done = true;
}

fn onUncapturedError(_: [*c]const c.WGPUDevice, typ: c.WGPUErrorType, message: c.WGPUStringView, _: ?*anyopaque, _: ?*anyopaque) callconv(.c) void {
    std.debug.print("!! GPU ERROR (type {d}): {s}\n", .{ typ, svSlice(message) });
}

const Gpu = struct {
    instance: c.WGPUInstance,
    adapter: c.WGPUAdapter,
    device: c.WGPUDevice,
    queue: c.WGPUQueue,

    fn waitIdle(self: *const Gpu) void {
        while (c.wgpuDevicePoll(self.device, 1, null) == 0) {}
    }
};

fn enumerateAdapters(instance: c.WGPUInstance) ![]c.WGPUAdapter {
    const count = c.wgpuInstanceEnumerateAdapters(instance, null, null);
    const adapters = try alloc.alloc(c.WGPUAdapter, count);
    _ = c.wgpuInstanceEnumerateAdapters(instance, null, adapters.ptr);
    return adapters;
}

fn printAdapter(idx: usize, adapter: c.WGPUAdapter) void {
    var info = std.mem.zeroes(c.WGPUAdapterInfo);
    _ = c.wgpuAdapterGetInfo(adapter, &info);
    std.debug.print("[{d}] {s}  ({s}, vendor 0x{x:0>4}, device 0x{x:0>4})\n", .{
        idx, svSlice(info.device), backendName(info.backendType), info.vendorID, info.deviceID,
    });
    c.wgpuAdapterInfoFreeMembers(info);
}

fn openDevice(adapterIndex: usize) !Gpu {
    const instance = c.wgpuCreateInstance(null) orelse return error.NoInstance;
    const adapters = try enumerateAdapters(instance);
    if (adapterIndex >= adapters.len) return error.BadAdapterIndex;
    const adapter = adapters[adapterIndex];

    var desc = std.mem.zeroes(c.WGPUDeviceDescriptor);
    desc.label = sv("g0-spike");
    desc.uncapturedErrorCallbackInfo = .{
        .nextInChain = null,
        .callback = onUncapturedError,
        .userdata1 = null,
        .userdata2 = null,
    };
    const cbinfo = c.WGPURequestDeviceCallbackInfo{
        .nextInChain = null,
        .mode = c.WGPUCallbackMode_AllowProcessEvents,
        .callback = onDevice,
        .userdata1 = null,
        .userdata2 = null,
    };
    g_device_ready = false;
    g_device = null;
    _ = c.wgpuAdapterRequestDevice(adapter, &desc, cbinfo);
    while (!g_device_ready) c.wgpuInstanceProcessEvents(instance);
    const device = g_device orelse return error.NoDevice;
    const queue = c.wgpuDeviceGetQueue(device) orelse return error.NoQueue;
    return .{ .instance = instance, .adapter = adapter, .device = device, .queue = queue };
}

fn makePipeline(g: *const Gpu, wgsl: []const u8, label: []const u8) c.WGPUComputePipeline {
    var src = std.mem.zeroes(c.WGPUShaderSourceWGSL);
    src.chain.sType = c.WGPUSType_ShaderSourceWGSL;
    src.code = sv(wgsl);
    var mdesc = std.mem.zeroes(c.WGPUShaderModuleDescriptor);
    mdesc.nextInChain = @ptrCast(&src.chain);
    mdesc.label = sv(label);
    const module = c.wgpuDeviceCreateShaderModule(g.device, &mdesc);
    defer c.wgpuShaderModuleRelease(module);

    var pdesc = std.mem.zeroes(c.WGPUComputePipelineDescriptor);
    pdesc.label = sv(label);
    pdesc.compute.module = module;
    pdesc.compute.entryPoint = sv("main");
    return c.wgpuDeviceCreateComputePipeline(g.device, &pdesc);
}

fn makeBuffer(g: *const Gpu, size: usize, usage: c.WGPUBufferUsage, label: []const u8) c.WGPUBuffer {
    var desc = std.mem.zeroes(c.WGPUBufferDescriptor);
    desc.label = sv(label);
    desc.usage = usage;
    desc.size = size;
    return c.wgpuDeviceCreateBuffer(g.device, &desc);
}

fn bindEntry(binding: u32, buffer: c.WGPUBuffer, size: usize) c.WGPUBindGroupEntry {
    var e = std.mem.zeroes(c.WGPUBindGroupEntry);
    e.binding = binding;
    e.buffer = buffer;
    e.offset = 0;
    e.size = size;
    return e;
}

fn makeBindGroup(g: *const Gpu, pipeline: c.WGPUComputePipeline, entries: []const c.WGPUBindGroupEntry) c.WGPUBindGroup {
    const layout = c.wgpuComputePipelineGetBindGroupLayout(pipeline, 0);
    defer c.wgpuBindGroupLayoutRelease(layout);
    var desc = std.mem.zeroes(c.WGPUBindGroupDescriptor);
    desc.layout = layout;
    desc.entryCount = entries.len;
    desc.entries = entries.ptr;
    return c.wgpuDeviceCreateBindGroup(g.device, &desc);
}

/// Encode `count` dispatches of one pipeline+bindgroup in ONE pass, submit, wait.
fn dispatchAndWait(g: *const Gpu, pipeline: c.WGPUComputePipeline, bg: c.WGPUBindGroup, wx: u32, wy: u32, count: usize) void {
    const enc = c.wgpuDeviceCreateCommandEncoder(g.device, null);
    const pass = c.wgpuCommandEncoderBeginComputePass(enc, null);
    c.wgpuComputePassEncoderSetPipeline(pass, pipeline);
    c.wgpuComputePassEncoderSetBindGroup(pass, 0, bg, 0, null);
    for (0..count) |_| c.wgpuComputePassEncoderDispatchWorkgroups(pass, wx, wy, 1);
    c.wgpuComputePassEncoderEnd(pass);
    c.wgpuComputePassEncoderRelease(pass);
    const cmd = c.wgpuCommandEncoderFinish(enc, null);
    c.wgpuCommandEncoderRelease(enc);
    c.wgpuQueueSubmit(g.queue, 1, &cmd);
    c.wgpuCommandBufferRelease(cmd);
    g.waitIdle();
}

fn uploadAndWait(g: *const Gpu, buffers: []const c.WGPUBuffer, datas: []const []const u8) void {
    for (buffers, datas) |b, d| c.wgpuQueueWriteBuffer(g.queue, b, 0, d.ptr, d.len);
    c.wgpuQueueSubmit(g.queue, 0, null); // flush staged writes
    g.waitIdle();
}

fn readbackAndWait(g: *const Gpu, src: c.WGPUBuffer, staging: c.WGPUBuffer, out: []u8) void {
    const enc = c.wgpuDeviceCreateCommandEncoder(g.device, null);
    c.wgpuCommandEncoderCopyBufferToBuffer(enc, src, 0, staging, 0, out.len);
    const cmd = c.wgpuCommandEncoderFinish(enc, null);
    c.wgpuCommandEncoderRelease(enc);
    c.wgpuQueueSubmit(g.queue, 1, &cmd);
    c.wgpuCommandBufferRelease(cmd);

    g_map_done = false;
    g_map_ok = false;
    const cbinfo = c.WGPUBufferMapCallbackInfo{
        .nextInChain = null,
        .mode = c.WGPUCallbackMode_AllowProcessEvents,
        .callback = onMap,
        .userdata1 = null,
        .userdata2 = null,
    };
    _ = c.wgpuBufferMapAsync(staging, c.WGPUMapMode_Read, 0, out.len, cbinfo);
    while (!g_map_done) {
        _ = c.wgpuDevicePoll(g.device, 1, null);
        c.wgpuInstanceProcessEvents(g.instance);
    }
    if (g_map_ok) {
        const p = c.wgpuBufferGetConstMappedRange(staging, 0, out.len);
        @memcpy(out, @as([*]const u8, @ptrCast(p.?))[0..out.len]);
        c.wgpuBufferUnmap(staging);
    }
}

const TimedOp = struct {
    warm: Stats,
    sustained_avg_ns: u64,
    sustained_iters: usize,
};

/// Warm stats (3 warmups + 5 reps) then sustained (3 s continuous, skip 1 s).
fn timeOp(comptime f: anytype, args: anytype) TimedOp {
    var timer = std.time.Timer.start() catch unreachable;
    for (0..WARMUPS) |_| @call(.auto, f, args);
    var samples: [REPS]u64 = undefined;
    for (&samples) |*s| {
        timer.reset();
        @call(.auto, f, args);
        s.* = timer.read();
    }
    const warm = Stats.from(&samples);

    var total_timer = std.time.Timer.start() catch unreachable;
    var kept_ns: u64 = 0;
    var kept: usize = 0;
    // cap KEPT samples, not total iterations: a fast op burns thousands of
    // iterations inside the 1 s discard window before the first kept one
    while (kept < SUSTAIN_MAX_ITERS) {
        const start = total_timer.read();
        if (start >= SUSTAIN_TOTAL_NS) break;
        timer.reset();
        @call(.auto, f, args);
        const took = timer.read();
        if (start >= SUSTAIN_SKIP_NS) {
            kept_ns += took;
            kept += 1;
        }
    }
    if (kept == 0) kept = 1;
    return .{ .warm = warm, .sustained_avg_ns = kept_ns / kept, .sustained_iters = kept };
}

fn maxRelErrF32(got: []const f32, want: []const f32) f64 {
    var max_abs: f64 = 1e-30;
    for (want) |w| max_abs = @max(max_abs, @abs(@as(f64, w)));
    var max_rel: f64 = 0;
    for (got, want) |g, w| {
        const diff = @abs(@as(f64, g) - @as(f64, w));
        max_rel = @max(max_rel, diff / max_abs);
    }
    return max_rel;
}

// ---------------------------------------------------------------- GPU phase

fn runGpuPhase(adapterIndex: usize) !void {
    var g = try openDevice(adapterIndex);

    var info = std.mem.zeroes(c.WGPUAdapterInfo);
    _ = c.wgpuAdapterGetInfo(g.adapter, &info);
    std.debug.print("== GPU SUITE on [{d}] {s} ({s}) ==\n", .{ adapterIndex, svSlice(info.device), backendName(info.backendType) });
    c.wgpuAdapterInfoFreeMembers(info);

    // pipeline compile cost, once -- G1's compile-cache justification
    var timer = try std.time.Timer.start();
    const saxpyPipe = makePipeline(&g, WGSL_SAXPY, "saxpy");
    const t_saxpy_compile = timer.read();
    timer.reset();
    const matmulPipe = makePipeline(&g, WGSL_MATMUL, "matmul");
    const t_matmul_compile = timer.read();
    std.debug.print("pipeline compile: saxpy {d:.2} ms, matmul {d:.2} ms\n", .{ ms(t_saxpy_compile), ms(t_matmul_compile) });

    const STORAGE_RW = c.WGPUBufferUsage_Storage | c.WGPUBufferUsage_CopyDst | c.WGPUBufferUsage_CopySrc;
    const STORAGE_RO = c.WGPUBufferUsage_Storage | c.WGPUBufferUsage_CopyDst;

    // ---------------- saxpy
    std.debug.print("-- saxpy f32 (y = a*x + y), workgroup 256 --\n", .{});
    for (SAXPY_SIZES) |n| {
        const bytes = n * 4;
        const x = try alloc.alloc(f32, n);
        defer alloc.free(x);
        const y0 = try alloc.alloc(f32, n);
        defer alloc.free(y0);
        fillRandomF32(x, 1);
        fillRandomF32(y0, 2);

        const bufP = makeBuffer(&g, 16, c.WGPUBufferUsage_Uniform | c.WGPUBufferUsage_CopyDst, "p");
        const bufX = makeBuffer(&g, bytes, STORAGE_RO, "x");
        const bufY = makeBuffer(&g, bytes, STORAGE_RW, "y");
        const bufR = makeBuffer(&g, bytes, c.WGPUBufferUsage_MapRead | c.WGPUBufferUsage_CopyDst, "read");
        defer {
            c.wgpuBufferRelease(bufP);
            c.wgpuBufferRelease(bufX);
            c.wgpuBufferRelease(bufY);
            c.wgpuBufferRelease(bufR);
        }
        const params = extern struct { n: u32, a: f32 }{ .n = @intCast(n), .a = 2.5 };
        c.wgpuQueueWriteBuffer(g.queue, bufP, 0, &params, 8);

        const entries = [_]c.WGPUBindGroupEntry{
            bindEntry(0, bufP, 16),
            bindEntry(1, bufX, bytes),
            bindEntry(2, bufY, bytes),
        };
        const bg = makeBindGroup(&g, saxpyPipe, &entries);
        defer c.wgpuBindGroupRelease(bg);
        const wx: u32 = @intCast((n + 255) / 256);

        // correctness first: fresh upload, ONE dispatch, readback, compare
        uploadAndWait(&g, &.{ bufX, bufY }, &.{ std.mem.sliceAsBytes(x), std.mem.sliceAsBytes(y0) });
        dispatchAndWait(&g, saxpyPipe, bg, wx, 1, 1);
        const got = try alloc.alloc(f32, n);
        defer alloc.free(got);
        readbackAndWait(&g, bufY, bufR, std.mem.sliceAsBytes(got));
        const want = try alloc.alloc(f32, n);
        defer alloc.free(want);
        @memcpy(want, y0);
        cpuSaxpyF32(2.5, x, want);
        const relerr = maxRelErrF32(got, want);

        const up = timeOp(uploadAndWait, .{ &g, &.{ bufX, bufY }, &.{ std.mem.sliceAsBytes(x), std.mem.sliceAsBytes(y0) } });
        const disp = timeOp(dispatchAndWait, .{ &g, saxpyPipe, bg, wx, @as(u32, 1), @as(usize, 1) });
        const chain = timeOp(dispatchAndWait, .{ &g, saxpyPipe, bg, wx, @as(u32, 1), @as(usize, 10) });
        const rb = timeOp(readbackAndWait, .{ &g, bufY, bufR, std.mem.sliceAsBytes(got) });

        std.debug.print(
            "n={d:>8}  up min {d:>8.3} med {d:>8.3} sus {d:>8.3} ({d:>5.2} GB/s) | disp min {d:>8.3} med {d:>8.3} sus {d:>8.3} | chain10/op {d:>8.3} sus {d:>8.3} | rb min {d:>8.3} med {d:>8.3} sus {d:>8.3} ({d:>5.2} GB/s) | relerr {e:.2}\n",
            .{
                n,
                ms(up.warm.min_ns),
                ms(up.warm.med_ns),
                ms(up.sustained_avg_ns),
                gbps(2 * bytes, up.warm.min_ns),
                ms(disp.warm.min_ns),
                ms(disp.warm.med_ns),
                ms(disp.sustained_avg_ns),
                ms(chain.warm.min_ns) / 10.0,
                ms(chain.sustained_avg_ns) / 10.0,
                ms(rb.warm.min_ns),
                ms(rb.warm.med_ns),
                ms(rb.sustained_avg_ns),
                gbps(bytes, rb.warm.min_ns),
                relerr,
            },
        );
    }

    // ---------------- matmul
    std.debug.print("-- matmul f32 (C = A*B, square n), 16x16 tiled --\n", .{});
    for (MATMUL_SIZES) |n| {
        const bytes = n * n * 4;
        const a = try alloc.alloc(f32, n * n);
        defer alloc.free(a);
        const b = try alloc.alloc(f32, n * n);
        defer alloc.free(b);
        fillRandomF32(a, 3);
        fillRandomF32(b, 4);

        const bufD = makeBuffer(&g, 16, c.WGPUBufferUsage_Uniform | c.WGPUBufferUsage_CopyDst, "dims");
        const bufA = makeBuffer(&g, bytes, STORAGE_RO, "A");
        const bufB = makeBuffer(&g, bytes, STORAGE_RO, "B");
        const bufC = makeBuffer(&g, bytes, STORAGE_RW, "C");
        const bufR = makeBuffer(&g, bytes, c.WGPUBufferUsage_MapRead | c.WGPUBufferUsage_CopyDst, "read");
        defer {
            c.wgpuBufferRelease(bufD);
            c.wgpuBufferRelease(bufA);
            c.wgpuBufferRelease(bufB);
            c.wgpuBufferRelease(bufC);
            c.wgpuBufferRelease(bufR);
        }
        const dims = extern struct { m: u32, k: u32, n: u32, pad: u32 }{ .m = @intCast(n), .k = @intCast(n), .n = @intCast(n), .pad = 0 };
        c.wgpuQueueWriteBuffer(g.queue, bufD, 0, &dims, 16);

        const entries = [_]c.WGPUBindGroupEntry{
            bindEntry(0, bufD, 16),
            bindEntry(1, bufA, bytes),
            bindEntry(2, bufB, bytes),
            bindEntry(3, bufC, bytes),
        };
        const bg = makeBindGroup(&g, matmulPipe, &entries);
        defer c.wgpuBindGroupRelease(bg);
        const wgs: u32 = @intCast((n + 15) / 16);

        uploadAndWait(&g, &.{ bufA, bufB }, &.{ std.mem.sliceAsBytes(a), std.mem.sliceAsBytes(b) });
        dispatchAndWait(&g, matmulPipe, bg, wgs, wgs, 1);
        const got = try alloc.alloc(f32, n * n);
        defer alloc.free(got);
        readbackAndWait(&g, bufC, bufR, std.mem.sliceAsBytes(got));
        const want = try alloc.alloc(f32, n * n);
        defer alloc.free(want);
        cpuMatmulF32(a, b, want, n);
        const relerr = maxRelErrF32(got, want);

        const up = timeOp(uploadAndWait, .{ &g, &.{ bufA, bufB }, &.{ std.mem.sliceAsBytes(a), std.mem.sliceAsBytes(b) } });
        const disp = timeOp(dispatchAndWait, .{ &g, matmulPipe, bg, wgs, wgs, @as(usize, 1) });
        const chain = timeOp(dispatchAndWait, .{ &g, matmulPipe, bg, wgs, wgs, @as(usize, 10) });
        const rb = timeOp(readbackAndWait, .{ &g, bufC, bufR, std.mem.sliceAsBytes(got) });

        const flops = 2 * n * n * n;
        std.debug.print(
            "n={d:>5}  up min {d:>8.3} med {d:>8.3} sus {d:>8.3} | disp min {d:>8.3} med {d:>8.3} sus {d:>8.3} ({d:>7.2} GFLOP/s warm, {d:>7.2} sus) | chain10/op {d:>8.3} sus {d:>8.3} ({d:>7.2} GFLOP/s) | rb min {d:>8.3} med {d:>8.3} sus {d:>8.3} | relerr {e:.2}\n",
            .{
                n,
                ms(up.warm.min_ns),
                ms(up.warm.med_ns),
                ms(up.sustained_avg_ns),
                ms(disp.warm.min_ns),
                ms(disp.warm.med_ns),
                ms(disp.sustained_avg_ns),
                gflops(flops, disp.warm.min_ns),
                gflops(flops, disp.sustained_avg_ns),
                ms(chain.warm.min_ns) / 10.0,
                ms(chain.sustained_avg_ns) / 10.0,
                gflops(flops * 10, chain.sustained_avg_ns),
                ms(rb.warm.min_ns),
                ms(rb.warm.med_ns),
                ms(rb.sustained_avg_ns),
                relerr,
            },
        );
    }

    c.wgpuComputePipelineRelease(saxpyPipe);
    c.wgpuComputePipelineRelease(matmulPipe);
    c.wgpuQueueRelease(g.queue);
    c.wgpuDeviceRelease(g.device);
    c.wgpuInstanceRelease(g.instance);
}

// ---------------------------------------------------------------- main

pub fn main() !void {
    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);

    if (args.len < 2) {
        std.debug.print("usage: gpu_spike list | cpu | run <adapterIndex>\n", .{});
        return;
    }
    const cmd = args[1];
    if (std.mem.eql(u8, cmd, "list")) {
        const instance = c.wgpuCreateInstance(null) orelse return error.NoInstance;
        const adapters = try enumerateAdapters(instance);
        for (adapters, 0..) |a2, i| printAdapter(i, a2);
    } else if (std.mem.eql(u8, cmd, "cpu")) {
        try runCpuPhase();
    } else if (std.mem.eql(u8, cmd, "run")) {
        if (args.len < 3) return error.MissingAdapterIndex;
        const idx = try std.fmt.parseInt(usize, args[2], 10);
        try runGpuPhase(idx);
    } else {
        std.debug.print("unknown command: {s}\n", .{cmd});
    }
}
