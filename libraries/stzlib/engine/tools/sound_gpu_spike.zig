//! SN0 GPU-FFT-CONVOLUTION SPIKE -- measurement only, no product code.
//!
//! Plan of record: libraries/stzlib/base/sound/SOFTANZA_SOUND_PLAN.md (phase SN0).
//! Answers ONE question, once, so no later phase re-litigates it (plan sec.4):
//!
//!     KILL CRITERION #3 -- "if the GPU FFT convolution does not beat CPU by
//!     >=2x at 60 s, the GPU stays OUT of this plane entirely."
//!
//! The op is convolution reverb: a dry signal convolved with a 1 s impulse
//! response, rendered OFFLINE. FACT 5 already rules the GPU out of the
//! real-time callback (a 5 ms buffer is 1,920 bytes against a ~60 us dispatch
//! floor); offline batch is the only place it could pay, so offline batch is
//! what this measures.
//!
//! THREE IMPLEMENTATIONS, NOT TWO -- and the third is the point.
//!
//!   1. fft.zig convolveReal (f64)   -- the CPU capability as SHIPPED. This is
//!                                      the "CPU" the kill criterion names.
//!   2. a twiddle-TABLE radix-2 (f32) -- the same algorithm with the twiddle
//!                                      factors precomputed instead of
//!                                      recomputed per butterfly.
//!   3. WGSL Stockham radix-2 (f32)  -- the GPU.
//!
//! (2) exists because a criterion that compares a GPU against an unoptimised
//! CPU answers the wrong question. fft.zig recomputes @cos/@sin at every
//! butterfly ON PURPOSE -- its header says so, for accuracy against a
//! LAPACK-grade reference. That is right for a numeric oracle and expensive
//! for a convolution. If the GPU's win over (1) is really (1) leaving a factor
//! on the table, the honest answer is "fix the CPU FFT", not "buy a GPU" --
//! which is exactly the mistake GR0's decomposition caught in the graphics
//! plane, where 95% of a frame turned out to be CPU zlib.
//!
//! Build (from libraries/stzlib/engine). Unlike tools/gpu_spike.zig this one
//! IMPORTS the engine's real src/fft.zig rather than copying it -- the whole
//! question is how the SHIPPED FFT compares, so a copy that could drift from it
//! would be measuring the wrong thing. That needs the explicit-module form, and
//! -I MUST come before the first -M (a flag after -Mroot is silently dropped
//! once a second module is declared, which costs a confusing "webgpu.h not
//! found" if you put it where the single-module form wants it):
//!     zig build-exe -OReleaseSafe -I vendor/wgpu/include \
//!         -lc vendor/wgpu/lib/wgpu_native.dll.lib \
//!         --dep fft -Mroot=tools/sound_gpu_spike.zig -Mfft=src/fft.zig \
//!         --name sound_gpu_spike
//! Run (wgpu_native.dll must sit next to the exe or on PATH):
//!     sound_gpu_spike list        -- enumerate adapters
//!     sound_gpu_spike cpu         -- CPU baselines only (run FIRST, uncontended)
//!     sound_gpu_spike run <idx>   -- CPU + GPU on adapter <idx>

const std = @import("std");
const fft = @import("fft");

const c = @cImport({
    @cInclude("webgpu/webgpu.h");
    @cInclude("webgpu/wgpu.h");
});

const alloc = std.heap.c_allocator;

const SAMPLE_RATE: usize = 48000;
const IR_SECONDS: f64 = 1.0;
const SIGNAL_SECONDS = [_]f64{ 1.0, 60.0 };
const REPS = 5; // house rule: 5 runs minimum
const WARMUPS = 1; // a 4M-point f64 FFT is not cheap enough to warm 3 times

// ---------------------------------------------------------------- helpers

fn ms(ns: u64) f64 {
    return @as(f64, @floatFromInt(ns)) / 1e6;
}

fn sv(s: []const u8) c.WGPUStringView {
    return .{ .data = s.ptr, .length = s.len };
}

fn svSlice(s: c.WGPUStringView) []const u8 {
    if (s.data == null) return "";
    return s.data[0..s.length];
}

fn backendName(b: c.WGPUBackendType) []const u8 {
    return switch (b) {
        c.WGPUBackendType_Vulkan => "Vulkan",
        c.WGPUBackendType_D3D12 => "D3D12",
        c.WGPUBackendType_Metal => "Metal",
        c.WGPUBackendType_OpenGL => "OpenGL",
        else => "other",
    };
}

fn nextPow2(n: usize) usize {
    var m: usize = 1;
    while (m < n) m <<= 1;
    return m;
}

fn log2int(n: usize) u32 {
    var k: u32 = 0;
    var m: usize = 1;
    while (m < n) : (m <<= 1) k += 1;
    return k;
}

const Stats = struct {
    min_ns: u64,
    med_ns: u64,
    fn from(s: []u64) Stats {
        std.mem.sort(u64, s, {}, std.sort.asc(u64));
        return .{ .min_ns = s[0], .med_ns = s[s.len / 2] };
    }
};

/// A reverb-shaped impulse response: exponentially decaying noise. Not a real
/// hall, but the right SHAPE and the right length, which is what the timing
/// depends on. (SN5 will convolve real IRs; the arithmetic does not care.)
fn makeIR(h: []f64, seed: u64) void {
    var prng = std.Random.DefaultPrng.init(seed);
    const r = prng.random();
    const n: f64 = @floatFromInt(h.len);
    for (h, 0..) |*v, i| {
        const t = @as(f64, @floatFromInt(i)) / n;
        v.* = (r.float(f64) * 2.0 - 1.0) * @exp(-6.0 * t);
    }
    h[0] = 1.0; // the direct path
}

fn makeSignal(x: []f64, seed: u64) void {
    var prng = std.Random.DefaultPrng.init(seed);
    const r = prng.random();
    for (x) |*v| v.* = r.float(f64) * 2.0 - 1.0;
}

// ---------------------------------------------------------------- CPU #2
//
// The same radix-2 Cooley-Tukey as fft.zig, at f32, with ONE difference: the
// twiddle factors come from a precomputed table instead of a @cos/@sin pair per
// butterfly. Everything else -- bit reversal, butterfly order, the
// conjugate-forward-conjugate inverse -- is fft.zig's, so the comparison
// isolates exactly one decision.

const TwiddleFft = struct {
    n: usize,
    wr: []f32,
    wi: []f32,

    fn init(n: usize) !TwiddleFft {
        const half = n / 2;
        const wr = try alloc.alloc(f32, half);
        const wi = try alloc.alloc(f32, half);
        for (0..half) |k| {
            const ang = -2.0 * std.math.pi * @as(f64, @floatFromInt(k)) / @as(f64, @floatFromInt(n));
            wr[k] = @floatCast(@cos(ang));
            wi[k] = @floatCast(@sin(ang));
        }
        return .{ .n = n, .wr = wr, .wi = wi };
    }

    fn deinit(self: *TwiddleFft) void {
        alloc.free(self.wr);
        alloc.free(self.wi);
    }

    fn forward(self: *const TwiddleFft, re: []f32, im: []f32) void {
        const n = re.len;
        var j: usize = 0;
        var i: usize = 1;
        while (i < n) : (i += 1) {
            var bit = n >> 1;
            while (j & bit != 0) {
                j ^= bit;
                bit >>= 1;
            }
            j |= bit;
            if (i < j) {
                std.mem.swap(f32, &re[i], &re[j]);
                std.mem.swap(f32, &im[i], &im[j]);
            }
        }
        var span: usize = 2;
        while (span <= n) : (span <<= 1) {
            const half = span / 2;
            const step = n / span; // stride into the full-length twiddle table
            var start: usize = 0;
            while (start < n) : (start += span) {
                var k: usize = 0;
                while (k < half) : (k += 1) {
                    const w = k * step;
                    const wr = self.wr[w];
                    const wi = self.wi[w];
                    const lo = start + k;
                    const hi = lo + half;
                    const xr = re[hi] * wr - im[hi] * wi;
                    const xi = re[hi] * wi + im[hi] * wr;
                    re[hi] = re[lo] - xr;
                    im[hi] = im[lo] - xi;
                    re[lo] += xr;
                    im[lo] += xi;
                }
            }
        }
    }
};

const CpuF32Conv = struct {
    tw: TwiddleFft,
    ar: []f32,
    ai: []f32,
    br: []f32,
    bi: []f32,
    m: usize,

    fn init(m: usize) !CpuF32Conv {
        return .{
            .tw = try TwiddleFft.init(m),
            .ar = try alloc.alloc(f32, m),
            .ai = try alloc.alloc(f32, m),
            .br = try alloc.alloc(f32, m),
            .bi = try alloc.alloc(f32, m),
            .m = m,
        };
    }

    fn deinit(self: *CpuF32Conv) void {
        self.tw.deinit();
        alloc.free(self.ar);
        alloc.free(self.ai);
        alloc.free(self.br);
        alloc.free(self.bi);
    }

    fn run(self: *CpuF32Conv, a: []const f64, b: []const f64, out: []f32) void {
        const m = self.m;
        @memset(self.ar, 0);
        @memset(self.ai, 0);
        @memset(self.br, 0);
        @memset(self.bi, 0);
        for (a, 0..) |v, i| self.ar[i] = @floatCast(v);
        for (b, 0..) |v, i| self.br[i] = @floatCast(v);

        self.tw.forward(self.ar, self.ai);
        self.tw.forward(self.br, self.bi);
        for (0..m) |t| {
            const pr = self.ar[t] * self.br[t] - self.ai[t] * self.bi[t];
            const pi = self.ar[t] * self.bi[t] + self.ai[t] * self.br[t];
            self.ar[t] = pr;
            self.ai[t] = -pi; // conjugate for the inverse pass
        }
        self.tw.forward(self.ar, self.ai);
        const inv: f32 = 1.0 / @as(f32, @floatFromInt(m));
        const lim = @min(out.len, m);
        for (0..lim) |t| out[t] = self.ar[t] * inv;
    }
};

// ---------------------------------------------------------------- WGSL

/// Stockham AUTOSORT radix-2. No bit-reversal permutation: the data is
/// reordered by the addressing at every stage, which is what makes it the right
/// FFT for a GPU (a bit-reversal pass is pure scattered memory traffic).
/// Ping-pongs between two buffers, one dispatch per stage, log2(N) stages.
const WGSL_FFT_STAGE =
    \\struct P { n: u32, ns: u32, sign: f32, pad: f32 }
    \\@group(0) @binding(0) var<uniform> p: P;
    \\@group(0) @binding(1) var<storage, read> src: array<vec2<f32>>;
    \\@group(0) @binding(2) var<storage, read_write> dst: array<vec2<f32>>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid: vec3<u32>) {
    \\  let t = gid.x;
    \\  let half = p.n >> 1u;
    \\  if (t >= half) { return; }
    \\  let ns = p.ns;
    \\  let j = t & (ns - 1u);
    \\  let base = (t - j) << 1u;
    \\  let a = src[t];
    \\  let b = src[t + half];
    \\  let ang = p.sign * 3.1415926535897932 * f32(j) / f32(ns);
    \\  let w = vec2<f32>(cos(ang), sin(ang));
    \\  let bw = vec2<f32>(b.x * w.x - b.y * w.y, b.x * w.y + b.y * w.x);
    \\  dst[base + j]      = a + bw;
    \\  dst[base + j + ns] = a - bw;
    \\}
;

/// Pointwise complex product, A <- A * B. The 1/N of the inverse transform is
/// folded into B before upload, so no separate scaling pass is dispatched.
const WGSL_CMUL =
    \\struct P { n: u32, pad0: u32, pad1: f32, pad2: f32 }
    \\@group(0) @binding(0) var<uniform> p: P;
    \\@group(0) @binding(1) var<storage, read> b: array<vec2<f32>>;
    \\@group(0) @binding(2) var<storage, read_write> a: array<vec2<f32>>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid: vec3<u32>) {
    \\  let i = gid.x;
    \\  if (i >= p.n) { return; }
    \\  let x = a[i];
    \\  let y = b[i];
    \\  a[i] = vec2<f32>(x.x * y.x - x.y * y.y, x.x * y.y + x.y * y.x);
    \\}
;

// ---------------------------------------------------------------- GPU plumbing

var g_device_ready = false;
var g_device: c.WGPUDevice = null;
var g_map_done = false;
var g_map_ok = false;

fn onDevice(status: c.WGPURequestDeviceStatus, device: c.WGPUDevice, message: c.WGPUStringView, _: ?*anyopaque, _: ?*anyopaque) callconv(.c) void {
    if (status == c.WGPURequestDeviceStatus_Success) g_device = device else std.debug.print("RequestDevice FAILED: {s}\n", .{svSlice(message)});
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

fn openDevice(idx: usize) !Gpu {
    const instance = c.wgpuCreateInstance(null) orelse return error.NoInstance;
    const adapters = try enumerateAdapters(instance);
    if (idx >= adapters.len) return error.BadAdapterIndex;
    const adapter = adapters[idx];

    // A 60 s convolution needs 4M complex f32 per buffer = 32 MB, and five of
    // them. wgpu's DEFAULT limits cap a storage binding at 128 MB and total
    // buffer size lower on some backends -- ask for what we need explicitly
    // rather than discovering the cap as a validation error mid-measurement.
    var limits = std.mem.zeroes(c.WGPULimits);
    limits = c.WGPULimits{
        .nextInChain = null,
        .maxTextureDimension1D = c.WGPU_LIMIT_U32_UNDEFINED,
        .maxTextureDimension2D = c.WGPU_LIMIT_U32_UNDEFINED,
        .maxTextureDimension3D = c.WGPU_LIMIT_U32_UNDEFINED,
        .maxTextureArrayLayers = c.WGPU_LIMIT_U32_UNDEFINED,
        .maxBindGroups = c.WGPU_LIMIT_U32_UNDEFINED,
        .maxBindGroupsPlusVertexBuffers = c.WGPU_LIMIT_U32_UNDEFINED,
        .maxBindingsPerBindGroup = c.WGPU_LIMIT_U32_UNDEFINED,
        .maxDynamicUniformBuffersPerPipelineLayout = c.WGPU_LIMIT_U32_UNDEFINED,
        .maxDynamicStorageBuffersPerPipelineLayout = c.WGPU_LIMIT_U32_UNDEFINED,
        .maxSampledTexturesPerShaderStage = c.WGPU_LIMIT_U32_UNDEFINED,
        .maxSamplersPerShaderStage = c.WGPU_LIMIT_U32_UNDEFINED,
        .maxStorageBuffersPerShaderStage = c.WGPU_LIMIT_U32_UNDEFINED,
        .maxStorageTexturesPerShaderStage = c.WGPU_LIMIT_U32_UNDEFINED,
        .maxUniformBuffersPerShaderStage = c.WGPU_LIMIT_U32_UNDEFINED,
        .maxUniformBufferBindingSize = c.WGPU_LIMIT_U64_UNDEFINED,
        .maxStorageBufferBindingSize = 256 * 1024 * 1024,
        .minUniformBufferOffsetAlignment = c.WGPU_LIMIT_U32_UNDEFINED,
        .minStorageBufferOffsetAlignment = c.WGPU_LIMIT_U32_UNDEFINED,
        .maxVertexBuffers = c.WGPU_LIMIT_U32_UNDEFINED,
        .maxBufferSize = 512 * 1024 * 1024,
        .maxVertexAttributes = c.WGPU_LIMIT_U32_UNDEFINED,
        .maxVertexBufferArrayStride = c.WGPU_LIMIT_U32_UNDEFINED,
        .maxInterStageShaderVariables = c.WGPU_LIMIT_U32_UNDEFINED,
        .maxColorAttachments = c.WGPU_LIMIT_U32_UNDEFINED,
        .maxColorAttachmentBytesPerSample = c.WGPU_LIMIT_U32_UNDEFINED,
        .maxComputeWorkgroupStorageSize = c.WGPU_LIMIT_U32_UNDEFINED,
        .maxComputeInvocationsPerWorkgroup = c.WGPU_LIMIT_U32_UNDEFINED,
        .maxComputeWorkgroupSizeX = c.WGPU_LIMIT_U32_UNDEFINED,
        .maxComputeWorkgroupSizeY = c.WGPU_LIMIT_U32_UNDEFINED,
        .maxComputeWorkgroupSizeZ = c.WGPU_LIMIT_U32_UNDEFINED,
        .maxComputeWorkgroupsPerDimension = c.WGPU_LIMIT_U32_UNDEFINED,
        .maxImmediateSize = c.WGPU_LIMIT_U32_UNDEFINED,
    };

    var desc = std.mem.zeroes(c.WGPUDeviceDescriptor);
    desc.label = sv("sn0-fft-spike");
    desc.requiredLimits = &limits;
    desc.uncapturedErrorCallbackInfo = .{ .nextInChain = null, .callback = onUncapturedError, .userdata1 = null, .userdata2 = null };
    const cb = c.WGPURequestDeviceCallbackInfo{ .nextInChain = null, .mode = c.WGPUCallbackMode_AllowProcessEvents, .callback = onDevice, .userdata1 = null, .userdata2 = null };
    g_device_ready = false;
    g_device = null;
    _ = c.wgpuAdapterRequestDevice(adapter, &desc, cb);
    while (!g_device_ready) c.wgpuInstanceProcessEvents(instance);
    const device = g_device orelse return error.NoDevice;
    return .{ .instance = instance, .adapter = adapter, .device = device, .queue = c.wgpuDeviceGetQueue(device).? };
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

fn readback(g: *const Gpu, src: c.WGPUBuffer, staging: c.WGPUBuffer, out: []u8) void {
    const enc = c.wgpuDeviceCreateCommandEncoder(g.device, null);
    c.wgpuCommandEncoderCopyBufferToBuffer(enc, src, 0, staging, 0, out.len);
    const cmd = c.wgpuCommandEncoderFinish(enc, null);
    c.wgpuCommandEncoderRelease(enc);
    c.wgpuQueueSubmit(g.queue, 1, &cmd);
    c.wgpuCommandBufferRelease(cmd);
    g_map_done = false;
    g_map_ok = false;
    const cb = c.WGPUBufferMapCallbackInfo{ .nextInChain = null, .mode = c.WGPUCallbackMode_AllowProcessEvents, .callback = onMap, .userdata1 = null, .userdata2 = null };
    _ = c.wgpuBufferMapAsync(staging, c.WGPUMapMode_Read, 0, out.len, cb);
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

// ---------------------------------------------------------------- GPU convolve

const StageParams = extern struct { n: u32, ns: u32, sign: f32, pad: f32 };

/// The whole convolution, decomposed. Every phase is timed as submit+wait --
/// the price a real call pays, submission overhead included (the G0 law).
const GpuConvTiming = struct {
    upload_ns: u64 = 0,
    fwd_ns: u64 = 0,
    mul_ns: u64 = 0,
    inv_ns: u64 = 0,
    readback_ns: u64 = 0,
    total_ns: u64 = 0,
    dispatches: usize = 0,
};

const GpuConv = struct {
    g: *const Gpu,
    m: usize,
    stages: u32,
    stage_pipe: c.WGPUComputePipeline,
    cmul_pipe: c.WGPUComputePipeline,
    // ping-pong pairs for the two operands
    a0: c.WGPUBuffer,
    a1: c.WGPUBuffer,
    b0: c.WGPUBuffer,
    b1: c.WGPUBuffer,
    staging: c.WGPUBuffer,
    // one uniform + bind group per stage per direction, built once
    ubufs: []c.WGPUBuffer,
    bg_fwd_a: []c.WGPUBindGroup,
    bg_fwd_b: []c.WGPUBindGroup,
    bg_inv_a: []c.WGPUBindGroup,
    bg_cmul: c.WGPUBindGroup,
    ucmul: c.WGPUBuffer,
    host: []f32, // interleaved complex staging on the host

    fn init(g: *const Gpu, m: usize) !GpuConv {
        const stages = log2int(m);
        const bytes = m * 8; // vec2<f32>
        const RW = c.WGPUBufferUsage_Storage | c.WGPUBufferUsage_CopyDst | c.WGPUBufferUsage_CopySrc;
        var self = GpuConv{
            .g = g,
            .m = m,
            .stages = stages,
            .stage_pipe = makePipeline(g, WGSL_FFT_STAGE, "fft-stage"),
            .cmul_pipe = makePipeline(g, WGSL_CMUL, "cmul"),
            .a0 = makeBuffer(g, bytes, RW, "a0"),
            .a1 = makeBuffer(g, bytes, RW, "a1"),
            .b0 = makeBuffer(g, bytes, RW, "b0"),
            .b1 = makeBuffer(g, bytes, RW, "b1"),
            .staging = makeBuffer(g, bytes, c.WGPUBufferUsage_MapRead | c.WGPUBufferUsage_CopyDst, "staging"),
            .ubufs = try alloc.alloc(c.WGPUBuffer, stages),
            .bg_fwd_a = try alloc.alloc(c.WGPUBindGroup, stages),
            .bg_fwd_b = try alloc.alloc(c.WGPUBindGroup, stages),
            .bg_inv_a = try alloc.alloc(c.WGPUBindGroup, stages),
            .bg_cmul = undefined,
            .ucmul = makeBuffer(g, 16, c.WGPUBufferUsage_Uniform | c.WGPUBufferUsage_CopyDst, "ucmul"),
            .host = try alloc.alloc(f32, m * 2),
        };

        // Forward and inverse differ only in the sign of the twiddle angle, so
        // the inverse needs its own uniforms. Two uniform buffers per stage.
        const uinv = try alloc.alloc(c.WGPUBuffer, stages);
        defer alloc.free(uinv);

        var ns: u32 = 1;
        for (0..stages) |s| {
            self.ubufs[s] = makeBuffer(g, 16, c.WGPUBufferUsage_Uniform | c.WGPUBufferUsage_CopyDst, "ufwd");
            uinv[s] = makeBuffer(g, 16, c.WGPUBufferUsage_Uniform | c.WGPUBufferUsage_CopyDst, "uinv");
            const pf = StageParams{ .n = @intCast(m), .ns = ns, .sign = -1.0, .pad = 0 };
            const pi = StageParams{ .n = @intCast(m), .ns = ns, .sign = 1.0, .pad = 0 };
            c.wgpuQueueWriteBuffer(g.queue, self.ubufs[s], 0, &pf, 16);
            c.wgpuQueueWriteBuffer(g.queue, uinv[s], 0, &pi, 16);

            // ping-pong: even stages read a0 write a1, odd the reverse
            const src_a = if (s % 2 == 0) self.a0 else self.a1;
            const dst_a = if (s % 2 == 0) self.a1 else self.a0;
            const src_b = if (s % 2 == 0) self.b0 else self.b1;
            const dst_b = if (s % 2 == 0) self.b1 else self.b0;

            self.bg_fwd_a[s] = makeBindGroup(g, self.stage_pipe, &.{
                bindEntry(0, self.ubufs[s], 16), bindEntry(1, src_a, bytes), bindEntry(2, dst_a, bytes),
            });
            self.bg_fwd_b[s] = makeBindGroup(g, self.stage_pipe, &.{
                bindEntry(0, self.ubufs[s], 16), bindEntry(1, src_b, bytes), bindEntry(2, dst_b, bytes),
            });
            // THE INVERSE CHAIN DOES NOT START WHERE THE FORWARD ONE DID.
            // After `stages` ping-pongs the forward result sits in a0 iff
            // `stages` is even; the product is written there, so the inverse's
            // stage 0 must READ that buffer. Phase-shifting the inverse chain by
            // stages%2 does it -- and it also makes the final result land in a0
            // for either parity, since (stages + stages) % 2 == 0 always.
            // (The first cut ignored this and read an untouched buffer: the
            // error check said 1.48e3 against the f64 reference, which is how
            // this was caught rather than shipped as a fast wrong answer.)
            const isrc = if ((stages + s) % 2 == 0) self.a0 else self.a1;
            const idst = if ((stages + s) % 2 == 0) self.a1 else self.a0;
            self.bg_inv_a[s] = makeBindGroup(g, self.stage_pipe, &.{
                bindEntry(0, uinv[s], 16), bindEntry(1, isrc, bytes), bindEntry(2, idst, bytes),
            });
            ns <<= 1;
        }

        // after `stages` ping-pongs the spectra sit in a0/b0 iff stages is even
        const spec_a = if (stages % 2 == 0) self.a0 else self.a1;
        const spec_b = if (stages % 2 == 0) self.b0 else self.b1;
        const pc = StageParams{ .n = @intCast(m), .ns = 0, .sign = 0, .pad = 0 };
        c.wgpuQueueWriteBuffer(g.queue, self.ucmul, 0, &pc, 16);
        self.bg_cmul = makeBindGroup(g, self.cmul_pipe, &.{
            bindEntry(0, self.ucmul, 16), bindEntry(1, spec_b, bytes), bindEntry(2, spec_a, bytes),
        });
        return self;
    }

    fn deinit(self: *GpuConv) void {
        alloc.free(self.ubufs);
        alloc.free(self.bg_fwd_a);
        alloc.free(self.bg_fwd_b);
        alloc.free(self.bg_inv_a);
        alloc.free(self.host);
    }

    fn encodeStages(self: *GpuConv, bgs: []c.WGPUBindGroup) void {
        const wg: u32 = @intCast((self.m / 2 + 255) / 256);
        const enc = c.wgpuDeviceCreateCommandEncoder(self.g.device, null);
        const pass = c.wgpuCommandEncoderBeginComputePass(enc, null);
        c.wgpuComputePassEncoderSetPipeline(pass, self.stage_pipe);
        for (bgs) |bg| {
            c.wgpuComputePassEncoderSetBindGroup(pass, 0, bg, 0, null);
            c.wgpuComputePassEncoderDispatchWorkgroups(pass, wg, 1, 1);
        }
        c.wgpuComputePassEncoderEnd(pass);
        c.wgpuComputePassEncoderRelease(pass);
        const cmd = c.wgpuCommandEncoderFinish(enc, null);
        c.wgpuCommandEncoderRelease(enc);
        c.wgpuQueueSubmit(self.g.queue, 1, &cmd);
        c.wgpuCommandBufferRelease(cmd);
        self.g.waitIdle();
    }

    fn run(self: *GpuConv, a: []const f64, b: []const f64, out: []f32) !GpuConvTiming {
        var t = GpuConvTiming{};
        var timer = try std.time.Timer.start();
        var total = try std.time.Timer.start();
        const bytes = self.m * 8;

        // --- upload. The inverse transform's 1/N is folded into B here, so the
        // GPU never dispatches a scaling pass for it.
        const invn: f32 = 1.0 / @as(f32, @floatFromInt(self.m));
        @memset(self.host, 0);
        for (a, 0..) |v, i| self.host[i * 2] = @floatCast(v);
        c.wgpuQueueWriteBuffer(self.g.queue, self.a0, 0, self.host.ptr, bytes);
        @memset(self.host, 0);
        for (b, 0..) |v, i| self.host[i * 2] = @as(f32, @floatCast(v)) * invn;
        c.wgpuQueueWriteBuffer(self.g.queue, self.b0, 0, self.host.ptr, bytes);
        c.wgpuQueueSubmit(self.g.queue, 0, null);
        self.g.waitIdle();
        t.upload_ns = timer.read();

        // --- forward transforms, both operands
        timer.reset();
        self.encodeStages(self.bg_fwd_a);
        self.encodeStages(self.bg_fwd_b);
        t.fwd_ns = timer.read();
        t.dispatches += 2 * self.stages;

        // --- pointwise product
        timer.reset();
        {
            const wg: u32 = @intCast((self.m + 255) / 256);
            const enc = c.wgpuDeviceCreateCommandEncoder(self.g.device, null);
            const pass = c.wgpuCommandEncoderBeginComputePass(enc, null);
            c.wgpuComputePassEncoderSetPipeline(pass, self.cmul_pipe);
            c.wgpuComputePassEncoderSetBindGroup(pass, 0, self.bg_cmul, 0, null);
            c.wgpuComputePassEncoderDispatchWorkgroups(pass, wg, 1, 1);
            c.wgpuComputePassEncoderEnd(pass);
            c.wgpuComputePassEncoderRelease(pass);
            const cmd = c.wgpuCommandEncoderFinish(enc, null);
            c.wgpuCommandEncoderRelease(enc);
            c.wgpuQueueSubmit(self.g.queue, 1, &cmd);
            c.wgpuCommandBufferRelease(cmd);
            self.g.waitIdle();
        }
        t.mul_ns = timer.read();
        t.dispatches += 1;

        // --- inverse. The product landed where the forward pass left A, so the
        // inverse's ping-pong chain starts from that same buffer.
        timer.reset();
        self.encodeStages(self.bg_inv_a);
        t.inv_ns = timer.read();
        t.dispatches += self.stages;

        // --- readback
        timer.reset();
        // always a0: the inverse chain was phase-shifted by stages%2 at setup
        const result_buf = self.a0;
        readback(self.g, result_buf, self.staging, std.mem.sliceAsBytes(self.host));
        const lim = @min(out.len, self.m);
        for (0..lim) |i| out[i] = self.host[i * 2];
        t.readback_ns = timer.read();
        t.total_ns = total.read();
        return t;
    }
};

// ---------------------------------------------------------------- error check

fn maxRelErr(got: []const f32, want: []const f64) f64 {
    var max_abs: f64 = 1e-30;
    for (want) |w| max_abs = @max(max_abs, @abs(w));
    var mx: f64 = 0;
    for (got, want) |g, w| mx = @max(mx, @abs(@as(f64, g) - w) / max_abs);
    return mx;
}

// ---------------------------------------------------------------- phases

const Case = struct {
    seconds: f64,
    nsig: usize,
    nir: usize,
    m: usize,
    cpu64: Stats = undefined,
    cpu32: Stats = undefined,
    ref: []f64 = &.{},
};

fn buildCases() ![]Case {
    const cases = try alloc.alloc(Case, SIGNAL_SECONDS.len);
    for (SIGNAL_SECONDS, 0..) |secs, i| {
        const nsig: usize = @intFromFloat(secs * @as(f64, @floatFromInt(SAMPLE_RATE)));
        const nir: usize = @intFromFloat(IR_SECONDS * @as(f64, @floatFromInt(SAMPLE_RATE)));
        cases[i] = .{ .seconds = secs, .nsig = nsig, .nir = nir, .m = nextPow2(nsig + nir - 1) };
    }
    return cases;
}

const Conv64 = struct {
    x: []f64,
    h: []f64,
    out: []f64,
    fn run(self: *Conv64) void {
        fft.convolveReal(alloc, self.x, self.h, self.out) catch {};
    }
};

fn runCpuPhase(cases: []Case) !void {
    std.debug.print("\n== CPU CONVOLUTION BASELINES (1 s impulse response, offline render) ==\n", .{});
    std.debug.print("{s:>7} {s:>10} {s:>10} {s:>13} {s:>13} {s:>9} {s:>12}\n", .{
        "audio", "samples", "FFT N", "fft.zig f64", "twiddle f32", "speedup", "x realtime",
    });

    for (cases) |*cs| {
        const x = try alloc.alloc(f64, cs.nsig);
        defer alloc.free(x);
        const h = try alloc.alloc(f64, cs.nir);
        defer alloc.free(h);
        makeSignal(x, 11);
        makeIR(h, 22);

        const need = cs.nsig + cs.nir - 1;
        const out64 = try alloc.alloc(f64, need);
        var hz = Conv64{ .x = x, .h = h, .out = out64 };

        var s64: [REPS]u64 = undefined;
        for (0..WARMUPS) |_| hz.run();
        for (&s64) |*s| {
            var tm = try std.time.Timer.start();
            hz.run();
            s.* = tm.read();
        }
        cs.cpu64 = Stats.from(&s64);
        cs.ref = out64; // kept: the correctness reference for the GPU

        var f32conv = try CpuF32Conv.init(cs.m);
        defer f32conv.deinit();
        const out32 = try alloc.alloc(f32, need);
        defer alloc.free(out32);
        var s32: [REPS]u64 = undefined;
        for (0..WARMUPS) |_| f32conv.run(x, h, out32);
        for (&s32) |*s| {
            var tm = try std.time.Timer.start();
            f32conv.run(x, h, out32);
            s.* = tm.read();
        }
        cs.cpu32 = Stats.from(&s32);

        const err32 = maxRelErr(out32, out64);
        const audio_ns: f64 = 1e9 * cs.seconds;
        std.debug.print("{d:>6.0}s {d:>10} {d:>10} {d:>11.1}ms {d:>11.1}ms {d:>8.2}x {d:>11.1}x\n", .{
            cs.seconds,
            cs.nsig,
            cs.m,
            ms(cs.cpu64.min_ns),
            ms(cs.cpu32.min_ns),
            @as(f64, @floatFromInt(cs.cpu64.min_ns)) / @as(f64, @floatFromInt(cs.cpu32.min_ns)),
            audio_ns / @as(f64, @floatFromInt(cs.cpu32.min_ns)),
        });
        std.debug.print("         twiddle-f32 vs f64 reference: max rel err {e:.2}\n", .{err32});
    }
}

fn runGpuPhase(idx: usize, cases: []Case) !void {
    var g = try openDevice(idx);
    var info = std.mem.zeroes(c.WGPUAdapterInfo);
    _ = c.wgpuAdapterGetInfo(g.adapter, &info);
    std.debug.print("\n== GPU CONVOLUTION on [{d}] {s} ({s}) ==\n", .{ idx, svSlice(info.device), backendName(info.backendType) });
    c.wgpuAdapterInfoFreeMembers(info);

    std.debug.print("{s:>7} {s:>10} {s:>4} {s:>9} {s:>9} {s:>8} {s:>9} {s:>9} {s:>10} {s:>11} {s:>11}\n", .{
        "audio", "FFT N", "disp", "upload", "forward", "mul", "inverse", "readbk", "TOTAL", "vs fft.zig", "vs cpu-f32",
    });

    for (cases) |*cs| {
        const x = try alloc.alloc(f64, cs.nsig);
        defer alloc.free(x);
        const h = try alloc.alloc(f64, cs.nir);
        defer alloc.free(h);
        makeSignal(x, 11);
        makeIR(h, 22);
        const need = cs.nsig + cs.nir - 1;
        const out = try alloc.alloc(f32, need);
        defer alloc.free(out);

        var conv = GpuConv.init(&g, cs.m) catch |e| {
            std.debug.print("{d:>6.0}s  GPU setup FAILED: {s} (counted refusal)\n", .{ cs.seconds, @errorName(e) });
            continue;
        };
        defer conv.deinit();

        var best = GpuConvTiming{ .total_ns = std.math.maxInt(u64) };
        var samples: [REPS]u64 = undefined;
        _ = try conv.run(x, h, out); // warm
        for (&samples) |*s| {
            const t = try conv.run(x, h, out);
            s.* = t.total_ns;
            if (t.total_ns < best.total_ns) best = t;
        }
        const st = Stats.from(&samples);
        const err = maxRelErr(out, cs.ref);

        std.debug.print("{d:>6.0}s {d:>10} {d:>4} {d:>7.2}ms {d:>7.2}ms {d:>6.2}ms {d:>7.2}ms {d:>7.2}ms {d:>8.2}ms {d:>10.2}x {d:>10.2}x\n", .{
            cs.seconds,
            cs.m,
            best.dispatches,
            ms(best.upload_ns),
            ms(best.fwd_ns),
            ms(best.mul_ns),
            ms(best.inv_ns),
            ms(best.readback_ns),
            ms(st.min_ns),
            @as(f64, @floatFromInt(cs.cpu64.min_ns)) / @as(f64, @floatFromInt(st.min_ns)),
            @as(f64, @floatFromInt(cs.cpu32.min_ns)) / @as(f64, @floatFromInt(st.min_ns)),
        });
        std.debug.print("         GPU f32 vs the f64 reference: max rel err {e:.2}   (median total {d:.2} ms)\n", .{ err, ms(st.med_ns) });
    }
}

// ---------------------------------------------------------------- main

pub fn main() !void {
    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);
    const cmd = if (args.len > 1) args[1] else "run";

    if (std.mem.eql(u8, cmd, "list")) {
        const instance = c.wgpuCreateInstance(null) orelse return error.NoInstance;
        const adapters = try enumerateAdapters(instance);
        for (adapters, 0..) |a, i| {
            var info = std.mem.zeroes(c.WGPUAdapterInfo);
            _ = c.wgpuAdapterGetInfo(a, &info);
            std.debug.print("[{d}] {s}  ({s})\n", .{ i, svSlice(info.device), backendName(info.backendType) });
            c.wgpuAdapterInfoFreeMembers(info);
        }
        return;
    }

    const cases = try buildCases();
    try runCpuPhase(cases);

    if (std.mem.eql(u8, cmd, "cpu")) return;
    const idx: usize = if (args.len > 2) try std.fmt.parseInt(usize, args[2], 10) else 0;
    try runGpuPhase(idx, cases);
}
