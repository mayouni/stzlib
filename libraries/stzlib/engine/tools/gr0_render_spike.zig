//! GR0 render spike -- measurement only, no product code.
//!
//! Plan of record: libraries/stzlib/base/graphics/SOFTANZA_GRAPHICS_PLAN.md
//! (phase GR0). Precedent: tools/gpu_spike.zig (G0). This standalone exe
//! exercises the VENDORED wgpu-native's render surface (never touched by the
//! G-plane) and produces the decomposition table the plan requires:
//!
//!   - offscreen render target (RGBA8Unorm), one SHADED triangle (per-vertex
//!     color interpolation) + one TEXTURED quad (8x8 checker, nearest)
//!   - texture -> buffer readback (256-byte row alignment handled + de-padded)
//!   - pure-Zig PNG encoder over the vendored zlib (chunks + CRC) -- the
//!     encoder GR1 needs anyway, proven and measured here
//!   - {render, readback, PNG-encode} at 800x600 and 1920x1080
//!   - a 10k-primitive 2D batch (one draw call) vs a naive CPU fill of the
//!     SAME pixels, verified byte-identical
//!   - the composition witness: a COMPUTE pass writes the vertex buffer a
//!     RENDER pass consumes, in ONE submit -- the zero-copy compute<->render
//!     claim of the plan, exercised rather than assumed (kill criterion 2)
//!
//! Build (from libraries/stzlib/engine; exe emits in the cwd you run it from):
//!     zig build-exe tools/gr0_render_spike.zig -OReleaseSafe \
//!         -I vendor/wgpu/include -I vendor/zlib \
//!         vendor/zlib/adler32.c vendor/zlib/compress.c vendor/zlib/crc32.c \
//!         vendor/zlib/deflate.c vendor/zlib/trees.c vendor/zlib/zutil.c \
//!         vendor/wgpu/lib/wgpu_native.dll.lib -lc --name gr0_render_spike
//! Run (wgpu_native.dll next to the exe or on PATH):
//!     gr0_render_spike list        -- enumerate adapters
//!     gr0_render_spike run <idx>   -- full suite on adapter <idx>
//!
//! Methodology (the house timing laws, same as gpu_spike.zig):
//!   monotonic clock; warm = 3 warmups + 5 timed reps (min AND median);
//!   sustained = 3 s continuous, first 1 s discarded; CPU samples inner-loop
//!   scaled to >= 1 ms; every GPU op timed as submit + wait-idle.

const std = @import("std");
const c = @cImport({
    @cInclude("webgpu/webgpu.h");
    @cInclude("webgpu/wgpu.h");
    @cInclude("zlib.h");
});

const alloc = std.heap.c_allocator;

const WARMUPS = 3;
const REPS = 5; // house rule: 5 runs minimum
const SUSTAIN_TOTAL_NS: u64 = 3_000_000_000;
const SUSTAIN_SKIP_NS: u64 = 1_000_000_000;
const SUSTAIN_MAX_ITERS = 4096;
const CPU_TARGET_NS: u64 = 1_000_000;

const SIZES = [_][2]u32{ .{ 800, 600 }, .{ 1920, 1080 } };
const N_RECTS = 10_000;

// ---------------------------------------------------------------- WGSL

// Shaded triangle / colored batch: pos NDC + per-vertex color, interpolated.
const WGSL_COLOR =
    \\struct VSOut { @builtin(position) pos: vec4<f32>, @location(0) col: vec4<f32> }
    \\@vertex
    \\fn vmain(@location(0) pos: vec2<f32>, @location(1) col: vec4<f32>) -> VSOut {
    \\  var o: VSOut;
    \\  o.pos = vec4<f32>(pos, 0.0, 1.0);
    \\  o.col = col;
    \\  return o;
    \\}
    \\@fragment
    \\fn fmain(in: VSOut) -> @location(0) vec4<f32> { return in.col; }
;

// Textured quad: pos NDC + uv, nearest-sampled texture.
const WGSL_TEX =
    \\struct VSOut { @builtin(position) pos: vec4<f32>, @location(0) uv: vec2<f32> }
    \\@vertex
    \\fn vmain(@location(0) pos: vec2<f32>, @location(1) uv: vec2<f32>) -> VSOut {
    \\  var o: VSOut;
    \\  o.pos = vec4<f32>(pos, 0.0, 1.0);
    \\  o.uv = uv;
    \\  return o;
    \\}
    \\@group(0) @binding(0) var tex: texture_2d<f32>;
    \\@group(0) @binding(1) var smp: sampler;
    \\@fragment
    \\fn fmain(in: VSOut) -> @location(0) vec4<f32> { return textureSample(tex, smp, in.uv); }
;

// Composition witness: compute writes the triangle's vertex buffer (x offset
// from a uniform), a render pass then consumes it -- same encoder, ONE submit.
const WGSL_COMPOSE =
    \\struct P { t: f32 }
    \\@group(0) @binding(0) var<uniform> p: P;
    \\@group(0) @binding(1) var<storage, read_write> v: array<f32>;
    \\@compute @workgroup_size(1)
    \\fn main() {
    \\  let r = 240.0/255.0; let g = 200.0/255.0; let b = 40.0/255.0;
    \\  v[0]  = p.t - 0.4; v[1]  = -0.4; v[2]  = r; v[3]  = g; v[4]  = b; v[5]  = 1.0;
    \\  v[6]  = p.t;       v[7]  =  0.4; v[8]  = r; v[9]  = g; v[10] = b; v[11] = 1.0;
    \\  v[12] = p.t + 0.4; v[13] = -0.4; v[14] = r; v[15] = g; v[16] = b; v[17] = 1.0;
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

fn gbps(bytes: usize, ns: u64) f64 {
    if (ns == 0) return 0;
    return @as(f64, @floatFromInt(bytes)) / @as(f64, @floatFromInt(ns));
}

const TimedOp = struct {
    warm: Stats,
    sustained_avg_ns: u64,
    sustained_iters: usize,
};

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

fn timeCpu(comptime f: anytype, args: anytype) Stats {
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

// ---------------------------------------------------------------- PNG encoder
// Pure Zig over the vendored zlib: 8-byte signature, IHDR, one IDAT
// (filter byte 0 per scanline), IEND. CRC via zlib's crc32. This is the
// encoder GR1 grows into the engine; GR0 proves and measures it.

fn be32(buf: []u8, v: u32) void {
    buf[0] = @intCast((v >> 24) & 0xff);
    buf[1] = @intCast((v >> 16) & 0xff);
    buf[2] = @intCast((v >> 8) & 0xff);
    buf[3] = @intCast(v & 0xff);
}

fn pngChunk(out: []u8, pos: usize, typ: *const [4]u8, data: []const u8) usize {
    be32(out[pos..][0..4], @intCast(data.len));
    @memcpy(out[pos + 4 ..][0..4], typ);
    @memcpy(out[pos + 8 ..][0..data.len], data);
    var crc: c.uLong = c.crc32(0, null, 0);
    crc = c.crc32(crc, out[pos + 4 ..].ptr, @intCast(4 + data.len));
    be32(out[pos + 8 + data.len ..][0..4], @intCast(crc));
    return pos + 12 + data.len;
}

/// RGBA8 rows (tight, w*4 bytes each) -> PNG bytes. Caller frees.
fn pngEncode(w: u32, h: u32, rgba: []const u8, level: i32) ![]u8 {
    const row_bytes: usize = @as(usize, w) * 4;
    const raw_len = (row_bytes + 1) * h; // +1 filter byte per row
    const raw = try alloc.alloc(u8, raw_len);
    defer alloc.free(raw);
    for (0..h) |y| {
        raw[y * (row_bytes + 1)] = 0; // filter: None
        @memcpy(raw[y * (row_bytes + 1) + 1 ..][0..row_bytes], rgba[y * row_bytes ..][0..row_bytes]);
    }

    var clen: c.uLongf = c.compressBound(@intCast(raw_len));
    const comp = try alloc.alloc(u8, @intCast(clen));
    defer alloc.free(comp);
    if (c.compress2(comp.ptr, &clen, raw.ptr, @intCast(raw_len), level) != c.Z_OK)
        return error.DeflateFailed;

    var ihdr: [13]u8 = undefined;
    be32(ihdr[0..4], w);
    be32(ihdr[4..8], h);
    ihdr[8] = 8; // bit depth
    ihdr[9] = 6; // color type RGBA
    ihdr[10] = 0; // compression
    ihdr[11] = 0; // filter method
    ihdr[12] = 0; // no interlace

    const total = 8 + (12 + 13) + (12 + @as(usize, @intCast(clen))) + 12;
    const out = try alloc.alloc(u8, total);
    @memcpy(out[0..8], &[8]u8{ 0x89, 'P', 'N', 'G', '\r', '\n', 0x1a, '\n' });
    var pos: usize = 8;
    pos = pngChunk(out, pos, "IHDR", &ihdr);
    pos = pngChunk(out, pos, "IDAT", comp[0..@intCast(clen)]);
    pos = pngChunk(out, pos, "IEND", &.{});
    std.debug.assert(pos == total);
    return out;
}

// timing wrapper: encode + free, so reps don't accumulate
fn pngEncodeTimed(w: u32, h: u32, rgba: []const u8, level: i32, out_len: *usize) void {
    const png = pngEncode(w, h, rgba, level) catch unreachable;
    out_len.* = png.len;
    alloc.free(png);
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
    desc.label = sv("gr0-spike");
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

fn makeShader(g: *const Gpu, wgsl: []const u8, label: []const u8) c.WGPUShaderModule {
    var src = std.mem.zeroes(c.WGPUShaderSourceWGSL);
    src.chain.sType = c.WGPUSType_ShaderSourceWGSL;
    src.code = sv(wgsl);
    var mdesc = std.mem.zeroes(c.WGPUShaderModuleDescriptor);
    mdesc.nextInChain = @ptrCast(&src.chain);
    mdesc.label = sv(label);
    return c.wgpuDeviceCreateShaderModule(g.device, &mdesc);
}

const TARGET_FORMAT = c.WGPUTextureFormat_RGBA8Unorm;

/// pos vec2 + payload vec4/vec2 render pipeline over the shared target format.
fn makeRenderPipeline(g: *const Gpu, wgsl: []const u8, payload_format: c.WGPUVertexFormat, payload_size: u64, label: []const u8) c.WGPURenderPipeline {
    const module = makeShader(g, wgsl, label);
    defer c.wgpuShaderModuleRelease(module);

    const attrs = [_]c.WGPUVertexAttribute{
        .{ .format = c.WGPUVertexFormat_Float32x2, .offset = 0, .shaderLocation = 0 },
        .{ .format = payload_format, .offset = 8, .shaderLocation = 1 },
    };
    var vbl = std.mem.zeroes(c.WGPUVertexBufferLayout);
    vbl.stepMode = c.WGPUVertexStepMode_Vertex;
    vbl.arrayStride = 8 + payload_size;
    vbl.attributeCount = attrs.len;
    vbl.attributes = &attrs;

    var target = std.mem.zeroes(c.WGPUColorTargetState);
    target.format = TARGET_FORMAT;
    target.blend = null; // opaque overwrite: the CPU-parity contract
    target.writeMask = c.WGPUColorWriteMask_All;

    var frag = std.mem.zeroes(c.WGPUFragmentState);
    frag.module = module;
    frag.entryPoint = sv("fmain");
    frag.targetCount = 1;
    frag.targets = &target;

    var desc = std.mem.zeroes(c.WGPURenderPipelineDescriptor);
    desc.label = sv(label);
    desc.vertex.module = module;
    desc.vertex.entryPoint = sv("vmain");
    desc.vertex.bufferCount = 1;
    desc.vertex.buffers = &vbl;
    desc.primitive.topology = c.WGPUPrimitiveTopology_TriangleList;
    desc.multisample.count = 1;
    desc.multisample.mask = 0xFFFFFFFF;
    desc.fragment = &frag;
    return c.wgpuDeviceCreateRenderPipeline(g.device, &desc);
}

fn makeBuffer(g: *const Gpu, size: usize, usage: c.WGPUBufferUsage, label: []const u8) c.WGPUBuffer {
    var desc = std.mem.zeroes(c.WGPUBufferDescriptor);
    desc.label = sv(label);
    desc.usage = usage;
    desc.size = size;
    return c.wgpuDeviceCreateBuffer(g.device, &desc);
}

fn makeTargetTexture(g: *const Gpu, w: u32, h: u32) c.WGPUTexture {
    var desc = std.mem.zeroes(c.WGPUTextureDescriptor);
    desc.label = sv("target");
    desc.usage = c.WGPUTextureUsage_RenderAttachment | c.WGPUTextureUsage_CopySrc;
    desc.dimension = c.WGPUTextureDimension_2D;
    desc.size = .{ .width = w, .height = h, .depthOrArrayLayers = 1 };
    desc.format = TARGET_FORMAT;
    desc.mipLevelCount = 1;
    desc.sampleCount = 1;
    return c.wgpuDeviceCreateTexture(g.device, &desc);
}

fn paddedRow(w: u32) usize {
    return std.mem.alignForward(usize, @as(usize, w) * 4, 256);
}

// ---------------------------------------------------------------- scene data

const CLEAR_R: u8 = 16;
const CLEAR_G: u8 = 20;
const CLEAR_B: u8 = 24;

fn u8f(v: u8) f32 {
    return @as(f32, @floatFromInt(v)) / 255.0;
}

// shaded triangle: NDC (-0.6,-0.6) red, (0.0,0.7) green, (0.6,-0.6) blue
const TRI_VERTS = [_]f32{
    -0.6, -0.6, 1.0, 0.0, 0.0, 1.0,
    0.0,  0.7,  0.0, 1.0, 0.0, 1.0,
    0.6,  -0.6, 0.0, 0.0, 1.0, 1.0,
};

// textured quad: NDC x [0.3,0.9], y [0.3,0.9] (top-right), uv [0,1]
const QUAD_VERTS = [_]f32{
    0.3, 0.3, 0.0, 1.0,
    0.9, 0.3, 1.0, 1.0,
    0.9, 0.9, 1.0, 0.0,
    0.3, 0.3, 0.0, 1.0,
    0.9, 0.9, 1.0, 0.0,
    0.3, 0.9, 0.0, 0.0,
};

const CHECKER_N = 8;
const CHECK_A = [4]u8{ 200, 60, 60, 255 };
const CHECK_B = [4]u8{ 240, 240, 240, 255 };

fn buildChecker() [CHECKER_N * CHECKER_N * 4]u8 {
    var px: [CHECKER_N * CHECKER_N * 4]u8 = undefined;
    for (0..CHECKER_N) |y| {
        for (0..CHECKER_N) |x| {
            const col = if ((x + y) % 2 == 0) CHECK_A else CHECK_B;
            @memcpy(px[(y * CHECKER_N + x) * 4 ..][0..4], &col);
        }
    }
    return px;
}

// ---------------------------------------------------------------- frame scene

const Frame = struct {
    g: *const Gpu,
    w: u32,
    h: u32,
    target: c.WGPUTexture,
    view: c.WGPUTextureView,
    staging: c.WGPUBuffer,
    tri_pipe: c.WGPURenderPipeline,
    tex_pipe: c.WGPURenderPipeline,
    tri_buf: c.WGPUBuffer,
    quad_buf: c.WGPUBuffer,
    tex_bg: c.WGPUBindGroup,
};

fn colorAttachment(view: c.WGPUTextureView) c.WGPURenderPassColorAttachment {
    var att = std.mem.zeroes(c.WGPURenderPassColorAttachment);
    att.view = view;
    att.depthSlice = c.WGPU_DEPTH_SLICE_UNDEFINED;
    att.loadOp = c.WGPULoadOp_Clear;
    att.storeOp = c.WGPUStoreOp_Store;
    att.clearValue = .{ .r = @as(f64, @floatFromInt(CLEAR_R)) / 255.0, .g = @as(f64, @floatFromInt(CLEAR_G)) / 255.0, .b = @as(f64, @floatFromInt(CLEAR_B)) / 255.0, .a = 1.0 };
    return att;
}

/// Encode + submit + wait: clear, shaded triangle, textured quad. One pass.
fn renderFrameAndWait(f: *const Frame) void {
    const enc = c.wgpuDeviceCreateCommandEncoder(f.g.device, null);
    var att = colorAttachment(f.view);
    var rp = std.mem.zeroes(c.WGPURenderPassDescriptor);
    rp.colorAttachmentCount = 1;
    rp.colorAttachments = &att;
    const pass = c.wgpuCommandEncoderBeginRenderPass(enc, &rp);
    c.wgpuRenderPassEncoderSetPipeline(pass, f.tri_pipe);
    c.wgpuRenderPassEncoderSetVertexBuffer(pass, 0, f.tri_buf, 0, TRI_VERTS.len * 4);
    c.wgpuRenderPassEncoderDraw(pass, 3, 1, 0, 0);
    c.wgpuRenderPassEncoderSetPipeline(pass, f.tex_pipe);
    c.wgpuRenderPassEncoderSetBindGroup(pass, 0, f.tex_bg, 0, null);
    c.wgpuRenderPassEncoderSetVertexBuffer(pass, 0, f.quad_buf, 0, QUAD_VERTS.len * 4);
    c.wgpuRenderPassEncoderDraw(pass, 6, 1, 0, 0);
    c.wgpuRenderPassEncoderEnd(pass);
    c.wgpuRenderPassEncoderRelease(pass);
    const cmd = c.wgpuCommandEncoderFinish(enc, null);
    c.wgpuCommandEncoderRelease(enc);
    c.wgpuQueueSubmit(f.g.queue, 1, &cmd);
    c.wgpuCommandBufferRelease(cmd);
    f.g.waitIdle();
}

/// Copy target -> staging, map, de-pad into `out` (tight w*4 rows).
fn readbackTexture(g: *const Gpu, target: c.WGPUTexture, staging: c.WGPUBuffer, w: u32, h: u32, out: []u8) void {
    const bpr = paddedRow(w);
    const enc = c.wgpuDeviceCreateCommandEncoder(g.device, null);
    var src = std.mem.zeroes(c.WGPUTexelCopyTextureInfo);
    src.texture = target;
    var dst = std.mem.zeroes(c.WGPUTexelCopyBufferInfo);
    dst.layout.offset = 0;
    dst.layout.bytesPerRow = @intCast(bpr);
    dst.layout.rowsPerImage = h;
    dst.buffer = staging;
    const extent = c.WGPUExtent3D{ .width = w, .height = h, .depthOrArrayLayers = 1 };
    c.wgpuCommandEncoderCopyTextureToBuffer(enc, &src, &dst, &extent);
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
    _ = c.wgpuBufferMapAsync(staging, c.WGPUMapMode_Read, 0, bpr * h, cbinfo);
    while (!g_map_done) {
        _ = c.wgpuDevicePoll(g.device, 1, null);
        c.wgpuInstanceProcessEvents(g.instance);
    }
    if (g_map_ok) {
        const p: [*]const u8 = @ptrCast(c.wgpuBufferGetConstMappedRange(staging, 0, bpr * h).?);
        const row_bytes: usize = @as(usize, w) * 4;
        for (0..h) |y| @memcpy(out[y * row_bytes ..][0..row_bytes], p[y * bpr ..][0..row_bytes]);
        c.wgpuBufferUnmap(staging);
    }
}

fn pixelAt(rgba: []const u8, w: u32, x: u32, y: u32) [4]u8 {
    const i = (@as(usize, y) * w + x) * 4;
    return rgba[i..][0..4].*;
}

fn expectPixel(rgba: []const u8, w: u32, x: u32, y: u32, want: [4]u8, band: u8, what: []const u8) bool {
    const got = pixelAt(rgba, w, x, y);
    for (got, want) |gv, wv| {
        const d = if (gv > wv) gv - wv else wv - gv;
        if (d > band) {
            std.debug.print("  FAIL {s} at ({d},{d}): got {any} want {any} band {d}\n", .{ what, x, y, got, want, band });
            return false;
        }
    }
    return true;
}

// ---------------------------------------------------------------- 10k batch

const Rect = struct { x: u32, y: u32, w: u32, h: u32, col: [4]u8 };

const PALETTE = [_][4]u8{
    .{ 220, 60, 60, 255 },
    .{ 60, 180, 90, 255 },
    .{ 70, 110, 230, 255 },
    .{ 235, 200, 60, 255 },
    .{ 180, 90, 200, 255 },
    .{ 90, 200, 210, 255 },
    .{ 240, 140, 70, 255 },
    .{ 200, 200, 200, 255 },
};

fn buildRects(rects: []Rect, fb_w: u32, fb_h: u32) void {
    var state: u64 = 0x9E3779B97F4A7C15;
    for (rects) |*r| {
        state = state *% 6364136223846793005 +% 1442695040888963407;
        const a: u32 = @truncate(state >> 33);
        state = state *% 6364136223846793005 +% 1442695040888963407;
        const b: u32 = @truncate(state >> 33);
        const rw = 8 + a % 64;
        const rh = 8 + b % 64;
        r.* = .{
            .x = (a >> 8) % (fb_w - rw),
            .y = (b >> 8) % (fb_h - rh),
            .w = rw,
            .h = rh,
            .col = PALETTE[@intCast(state >> 61)],
        };
    }
}

/// 6 verts per rect: pixel-integer corners -> NDC. Same painter order as CPU.
fn buildBatchVerts(verts: []f32, rects: []const Rect, fb_w: u32, fb_h: u32) void {
    const fw: f32 = @floatFromInt(fb_w);
    const fh: f32 = @floatFromInt(fb_h);
    for (rects, 0..) |r, i| {
        const x0 = @as(f32, @floatFromInt(r.x)) / fw * 2.0 - 1.0;
        const x1 = @as(f32, @floatFromInt(r.x + r.w)) / fw * 2.0 - 1.0;
        const y0 = 1.0 - @as(f32, @floatFromInt(r.y)) / fh * 2.0;
        const y1 = 1.0 - @as(f32, @floatFromInt(r.y + r.h)) / fh * 2.0;
        const cr = u8f(r.col[0]);
        const cg = u8f(r.col[1]);
        const cb = u8f(r.col[2]);
        const quad = [6][2]f32{ .{ x0, y0 }, .{ x1, y0 }, .{ x1, y1 }, .{ x0, y0 }, .{ x1, y1 }, .{ x0, y1 } };
        for (quad, 0..) |p, j| {
            const o = (i * 6 + j) * 6;
            verts[o] = p[0];
            verts[o + 1] = p[1];
            verts[o + 2] = cr;
            verts[o + 3] = cg;
            verts[o + 4] = cb;
            verts[o + 5] = 1.0;
        }
    }
}

/// The naive CPU fill: clear + per-pixel stores, painter order. The baseline.
fn cpuFillRects(px: []u32, rects: []const Rect, fb_w: u32, clear: u32) void {
    @memset(px, clear);
    for (rects) |r| {
        for (0..r.h) |dy| {
            const row = (@as(usize, r.y) + dy) * fb_w + r.x;
            const col = @as(u32, r.col[0]) | @as(u32, r.col[1]) << 8 | @as(u32, r.col[2]) << 16 | @as(u32, r.col[3]) << 24;
            @memset(px[row .. row + r.w], col);
        }
    }
}

fn uploadAndWait(g: *const Gpu, buf: c.WGPUBuffer, data: []const u8) void {
    c.wgpuQueueWriteBuffer(g.queue, buf, 0, data.ptr, data.len);
    c.wgpuQueueSubmit(g.queue, 0, null);
    g.waitIdle();
}

const Batch = struct {
    g: *const Gpu,
    view: c.WGPUTextureView,
    pipe: c.WGPURenderPipeline,
    vbuf: c.WGPUBuffer,
    n_verts: u32,
};

fn renderBatchAndWait(bt: *const Batch) void {
    const enc = c.wgpuDeviceCreateCommandEncoder(bt.g.device, null);
    var att = colorAttachment(bt.view);
    var rp = std.mem.zeroes(c.WGPURenderPassDescriptor);
    rp.colorAttachmentCount = 1;
    rp.colorAttachments = &att;
    const pass = c.wgpuCommandEncoderBeginRenderPass(enc, &rp);
    c.wgpuRenderPassEncoderSetPipeline(pass, bt.pipe);
    c.wgpuRenderPassEncoderSetVertexBuffer(pass, 0, bt.vbuf, 0, @as(u64, bt.n_verts) * 24);
    c.wgpuRenderPassEncoderDraw(pass, bt.n_verts, 1, 0, 0);
    c.wgpuRenderPassEncoderEnd(pass);
    c.wgpuRenderPassEncoderRelease(pass);
    const cmd = c.wgpuCommandEncoderFinish(enc, null);
    c.wgpuCommandEncoderRelease(enc);
    c.wgpuQueueSubmit(bt.g.queue, 1, &cmd);
    c.wgpuCommandBufferRelease(cmd);
    bt.g.waitIdle();
}

// ---------------------------------------------------------------- main suite

fn runSuite(adapterIndex: usize) !void {
    var g = try openDevice(adapterIndex);

    var info = std.mem.zeroes(c.WGPUAdapterInfo);
    _ = c.wgpuAdapterGetInfo(g.adapter, &info);
    std.debug.print("== GR0 RENDER SUITE on [{d}] {s} ({s}) ==\n", .{ adapterIndex, svSlice(info.device), backendName(info.backendType) });
    c.wgpuAdapterInfoFreeMembers(info);

    // ---- render pipeline compile cost (GR1's cache justification)
    var timer = try std.time.Timer.start();
    const tri_pipe = makeRenderPipeline(&g, WGSL_COLOR, c.WGPUVertexFormat_Float32x4, 16, "tri");
    const t_tri = timer.read();
    timer.reset();
    const tex_pipe = makeRenderPipeline(&g, WGSL_TEX, c.WGPUVertexFormat_Float32x2, 8, "tex");
    const t_tex = timer.read();
    std.debug.print("render pipeline compile: color {d:.2} ms, textured {d:.2} ms\n", .{ ms(t_tri), ms(t_tex) });

    // ---- static scene resources
    const tri_buf = makeBuffer(&g, TRI_VERTS.len * 4, c.WGPUBufferUsage_Vertex | c.WGPUBufferUsage_CopyDst, "tri");
    uploadAndWait(&g, tri_buf, std.mem.sliceAsBytes(&TRI_VERTS));
    const quad_buf = makeBuffer(&g, QUAD_VERTS.len * 4, c.WGPUBufferUsage_Vertex | c.WGPUBufferUsage_CopyDst, "quad");
    uploadAndWait(&g, quad_buf, std.mem.sliceAsBytes(&QUAD_VERTS));

    // checker texture + sampler + bind group
    var tdesc = std.mem.zeroes(c.WGPUTextureDescriptor);
    tdesc.label = sv("checker");
    tdesc.usage = c.WGPUTextureUsage_TextureBinding | c.WGPUTextureUsage_CopyDst;
    tdesc.dimension = c.WGPUTextureDimension_2D;
    tdesc.size = .{ .width = CHECKER_N, .height = CHECKER_N, .depthOrArrayLayers = 1 };
    tdesc.format = TARGET_FORMAT;
    tdesc.mipLevelCount = 1;
    tdesc.sampleCount = 1;
    const checker_tex = c.wgpuDeviceCreateTexture(g.device, &tdesc);
    const checker_px = buildChecker();
    {
        var dst = std.mem.zeroes(c.WGPUTexelCopyTextureInfo);
        dst.texture = checker_tex;
        var layout = std.mem.zeroes(c.WGPUTexelCopyBufferLayout);
        layout.bytesPerRow = CHECKER_N * 4;
        layout.rowsPerImage = CHECKER_N;
        const ext = c.WGPUExtent3D{ .width = CHECKER_N, .height = CHECKER_N, .depthOrArrayLayers = 1 };
        c.wgpuQueueWriteTexture(g.queue, &dst, &checker_px, checker_px.len, &layout, &ext);
    }
    const checker_view = c.wgpuTextureCreateView(checker_tex, null);
    var sdesc = std.mem.zeroes(c.WGPUSamplerDescriptor);
    sdesc.label = sv("nearest");
    sdesc.lodMaxClamp = 32.0;
    sdesc.maxAnisotropy = 1;
    const sampler = c.wgpuDeviceCreateSampler(g.device, &sdesc);

    const tex_bgl = c.wgpuRenderPipelineGetBindGroupLayout(tex_pipe, 0);
    var bge = [2]c.WGPUBindGroupEntry{ std.mem.zeroes(c.WGPUBindGroupEntry), std.mem.zeroes(c.WGPUBindGroupEntry) };
    bge[0].binding = 0;
    bge[0].textureView = checker_view;
    bge[1].binding = 1;
    bge[1].sampler = sampler;
    var bgd = std.mem.zeroes(c.WGPUBindGroupDescriptor);
    bgd.layout = tex_bgl;
    bgd.entryCount = 2;
    bgd.entries = &bge;
    const tex_bg = c.wgpuDeviceCreateBindGroup(g.device, &bgd);
    c.wgpuBindGroupLayoutRelease(tex_bgl);

    // ---- per-size: correctness, PNG artifact, decomposition table
    std.debug.print("-- still frame: clear + shaded triangle + textured quad --\n", .{});
    for (SIZES) |wh| {
        const w = wh[0];
        const h = wh[1];
        const target = makeTargetTexture(&g, w, h);
        const view = c.wgpuTextureCreateView(target, null);
        const staging = makeBuffer(&g, paddedRow(w) * h, c.WGPUBufferUsage_MapRead | c.WGPUBufferUsage_CopyDst, "staging");
        const frame = Frame{ .g = &g, .w = w, .h = h, .target = target, .view = view, .staging = staging, .tri_pipe = tri_pipe, .tex_pipe = tex_pipe, .tri_buf = tri_buf, .quad_buf = quad_buf, .tex_bg = tex_bg };

        const tight = try alloc.alloc(u8, @as(usize, w) * h * 4);
        defer alloc.free(tight);

        // correctness first
        renderFrameAndWait(&frame);
        readbackTexture(&g, target, staging, w, h, tight);
        var ok = true;
        ok = expectPixel(tight, w, 5, 5, .{ CLEAR_R, CLEAR_G, CLEAR_B, 255 }, 0, "clear corner") and ok;
        // triangle centroid (NDC 0,-0.166): equal-ish barycentric mix, banded
        const cx = w / 2;
        const cy = h / 2 + h / 12;
        const got_c = pixelAt(tight, w, cx, cy);
        ok = ok and (got_c[0] > 40 and got_c[1] > 40 and got_c[2] > 40); // all three colors present
        // checker cells: quad px region x [0.65w,0.95w], y [0.05h,0.35h]
        const qx0 = @as(f64, @floatFromInt(w)) * 0.65;
        const qw = @as(f64, @floatFromInt(w)) * 0.30;
        const qy0 = @as(f64, @floatFromInt(h)) * 0.05;
        const qh = @as(f64, @floatFromInt(h)) * 0.30;
        // cell (0,0) top-left (uv 0,0 at quad top-left): CHECK_A; cell (1,0): CHECK_B
        const c00x: u32 = @intFromFloat(qx0 + qw / 16.0);
        const c00y: u32 = @intFromFloat(qy0 + qh / 16.0);
        const c10x: u32 = @intFromFloat(qx0 + qw * 3.0 / 16.0);
        ok = expectPixel(tight, w, c00x, c00y, CHECK_A, 0, "checker(0,0)") and ok;
        ok = expectPixel(tight, w, c10x, c00y, CHECK_B, 0, "checker(1,0)") and ok;
        std.debug.print("{d}x{d}: pixel checks {s}\n", .{ w, h, if (ok) "OK" else "FAILED" });

        // PNG artifact for the eyeball (and to prove the encoder end-to-end)
        const png = try pngEncode(w, h, tight, 6);
        var namebuf: [64]u8 = undefined;
        const name = try std.fmt.bufPrint(&namebuf, "gr0_frame_{d}x{d}.png", .{ w, h });
        try std.fs.cwd().writeFile(.{ .sub_path = name, .data = png });
        alloc.free(png);

        // decomposition
        const rend = timeOp(renderFrameAndWait, .{&frame});
        const rb = timeOp(readbackTexture, .{ &g, target, staging, w, h, tight });
        var len6: usize = 0;
        var len1: usize = 0;
        const e6 = timeCpu(pngEncodeTimed, .{ w, h, tight, @as(i32, 6), &len6 });
        const e1 = timeCpu(pngEncodeTimed, .{ w, h, tight, @as(i32, 1), &len1 });

        const bytes = @as(usize, w) * h * 4;
        std.debug.print(
            "{d}x{d}: render min {d:.3} med {d:.3} sus {d:.3} | readback min {d:.3} med {d:.3} sus {d:.3} ({d:.2} GB/s) | png6 min {d:.3} med {d:.3} ({d} B) | png1 min {d:.3} med {d:.3} ({d} B)\n",
            .{ w, h, ms(rend.warm.min_ns), ms(rend.warm.med_ns), ms(rend.sustained_avg_ns), ms(rb.warm.min_ns), ms(rb.warm.med_ns), ms(rb.sustained_avg_ns), gbps(bytes, rb.warm.min_ns), ms(e6.min_ns), ms(e6.med_ns), len6, ms(e1.min_ns), ms(e1.med_ns), len1 },
        );
        std.debug.print(
            "{d}x{d}: TOTAL still frame  warm-min {d:.3} ms (png6) / {d:.3} ms (png1)   sustained {d:.3} / {d:.3}\n",
            .{ w, h, ms(rend.warm.min_ns + rb.warm.min_ns + e6.min_ns), ms(rend.warm.min_ns + rb.warm.min_ns + e1.min_ns), ms(rend.sustained_avg_ns + rb.sustained_avg_ns + e6.med_ns), ms(rend.sustained_avg_ns + rb.sustained_avg_ns + e1.med_ns) },
        );

        c.wgpuBufferRelease(staging);
        c.wgpuTextureViewRelease(view);
        c.wgpuTextureRelease(target);
    }

    // ---- 10k-primitive batch vs naive CPU fill (1920x1080)
    std.debug.print("-- 10k-rect batch, one draw call, vs naive CPU fill (1920x1080) --\n", .{});
    {
        const w: u32 = 1920;
        const h: u32 = 1080;
        const rects = try alloc.alloc(Rect, N_RECTS);
        defer alloc.free(rects);
        buildRects(rects, w, h);

        const verts = try alloc.alloc(f32, N_RECTS * 6 * 6);
        defer alloc.free(verts);
        const t_build = timeCpu(buildBatchVerts, .{ verts, rects, w, h });

        const vbuf = makeBuffer(&g, verts.len * 4, c.WGPUBufferUsage_Vertex | c.WGPUBufferUsage_CopyDst, "batch");
        const target = makeTargetTexture(&g, w, h);
        const view = c.wgpuTextureCreateView(target, null);
        const staging = makeBuffer(&g, paddedRow(w) * h, c.WGPUBufferUsage_MapRead | c.WGPUBufferUsage_CopyDst, "staging");
        const batch = Batch{ .g = &g, .view = view, .pipe = tri_pipe, .vbuf = vbuf, .n_verts = N_RECTS * 6 };

        uploadAndWait(&g, vbuf, std.mem.sliceAsBytes(verts));
        renderBatchAndWait(&batch);
        const got = try alloc.alloc(u8, @as(usize, w) * h * 4);
        defer alloc.free(got);
        readbackTexture(&g, target, staging, w, h, got);

        // CPU reference: SAME pixels, painter order, clear included
        const cpu_px = try alloc.alloc(u32, @as(usize, w) * h);
        defer alloc.free(cpu_px);
        const clear_u32 = @as(u32, CLEAR_R) | @as(u32, CLEAR_G) << 8 | @as(u32, CLEAR_B) << 16 | @as(u32, 255) << 24;
        cpuFillRects(cpu_px, rects, w, clear_u32);
        const cpu_bytes = std.mem.sliceAsBytes(cpu_px);
        var mismatches: usize = 0;
        for (got, cpu_bytes) |a, b| {
            if (a != b) mismatches += 1;
        }
        std.debug.print("batch parity vs CPU fill: {d} byte mismatches of {d} ({s})\n", .{ mismatches, got.len, if (mismatches == 0) "BYTE-IDENTICAL" else "MISMATCH" });

        const t_up = timeOp(uploadAndWait, .{ &g, vbuf, std.mem.sliceAsBytes(verts) });
        const t_draw = timeOp(renderBatchAndWait, .{&batch});
        const t_rb = timeOp(readbackTexture, .{ &g, target, staging, w, h, got });
        const t_cpu = timeCpu(cpuFillRects, .{ cpu_px, rects, w, clear_u32 });

        std.debug.print(
            "GPU: build verts {d:.3} ms | upload(1.44MB) min {d:.3} sus {d:.3} | draw min {d:.3} med {d:.3} sus {d:.3} | readback min {d:.3} sus {d:.3}\n",
            .{ ms(t_build.min_ns), ms(t_up.warm.min_ns), ms(t_up.sustained_avg_ns), ms(t_draw.warm.min_ns), ms(t_draw.warm.med_ns), ms(t_draw.sustained_avg_ns), ms(t_rb.warm.min_ns), ms(t_rb.sustained_avg_ns) },
        );
        std.debug.print(
            "CPU naive fill: min {d:.3} ms med {d:.3} ms | GPU draw-only vs CPU: {d:.1}x | GPU build+up+draw vs CPU: {d:.1}x | +readback: {d:.1}x\n",
            .{
                ms(t_cpu.min_ns),
                ms(t_cpu.med_ns),
                @as(f64, @floatFromInt(t_cpu.min_ns)) / @as(f64, @floatFromInt(t_draw.warm.min_ns)),
                @as(f64, @floatFromInt(t_cpu.min_ns)) / @as(f64, @floatFromInt(t_build.min_ns + t_up.warm.min_ns + t_draw.warm.min_ns)),
                @as(f64, @floatFromInt(t_cpu.min_ns)) / @as(f64, @floatFromInt(t_build.min_ns + t_up.warm.min_ns + t_draw.warm.min_ns + t_rb.warm.min_ns)),
            },
        );

        c.wgpuBufferRelease(staging);
        c.wgpuBufferRelease(vbuf);
        c.wgpuTextureViewRelease(view);
        c.wgpuTextureRelease(target);
    }

    // ---- composition witness: compute pass -> render pass, ONE submit
    std.debug.print("-- compute->render composition (kill criterion 2 witness) --\n", .{});
    {
        const w: u32 = 800;
        const h: u32 = 600;
        const target = makeTargetTexture(&g, w, h);
        const view = c.wgpuTextureCreateView(target, null);
        const staging = makeBuffer(&g, paddedRow(w) * h, c.WGPUBufferUsage_MapRead | c.WGPUBufferUsage_CopyDst, "staging");

        // vertex buffer the COMPUTE stage writes and the RENDER stage reads
        const vbuf = makeBuffer(&g, 18 * 4, c.WGPUBufferUsage_Vertex | c.WGPUBufferUsage_Storage, "compose-verts");
        const ubuf = makeBuffer(&g, 16, c.WGPUBufferUsage_Uniform | c.WGPUBufferUsage_CopyDst, "compose-t");

        const cmodule = makeShader(&g, WGSL_COMPOSE, "compose");
        var cdesc = std.mem.zeroes(c.WGPUComputePipelineDescriptor);
        cdesc.label = sv("compose");
        cdesc.compute.module = cmodule;
        cdesc.compute.entryPoint = sv("main");
        const cpipe = c.wgpuDeviceCreateComputePipeline(g.device, &cdesc);
        c.wgpuShaderModuleRelease(cmodule);

        const cbgl = c.wgpuComputePipelineGetBindGroupLayout(cpipe, 0);
        var cbge = [2]c.WGPUBindGroupEntry{ std.mem.zeroes(c.WGPUBindGroupEntry), std.mem.zeroes(c.WGPUBindGroupEntry) };
        cbge[0].binding = 0;
        cbge[0].buffer = ubuf;
        cbge[0].size = 16;
        cbge[1].binding = 1;
        cbge[1].buffer = vbuf;
        cbge[1].size = 18 * 4;
        var cbgd = std.mem.zeroes(c.WGPUBindGroupDescriptor);
        cbgd.layout = cbgl;
        cbgd.entryCount = 2;
        cbgd.entries = &cbge;
        const cbg = c.wgpuDeviceCreateBindGroup(g.device, &cbgd);
        c.wgpuBindGroupLayoutRelease(cbgl);

        const tight = try alloc.alloc(u8, @as(usize, w) * h * 4);
        defer alloc.free(tight);

        var ok = true;
        for ([_]f32{ 0.0, 0.5 }) |t| {
            const params = [4]f32{ t, 0, 0, 0 };
            c.wgpuQueueWriteBuffer(g.queue, ubuf, 0, &params, 16);

            // ONE encoder: compute pass writes verts, render pass draws them
            const enc = c.wgpuDeviceCreateCommandEncoder(g.device, null);
            const cpass = c.wgpuCommandEncoderBeginComputePass(enc, null);
            c.wgpuComputePassEncoderSetPipeline(cpass, cpipe);
            c.wgpuComputePassEncoderSetBindGroup(cpass, 0, cbg, 0, null);
            c.wgpuComputePassEncoderDispatchWorkgroups(cpass, 1, 1, 1);
            c.wgpuComputePassEncoderEnd(cpass);
            c.wgpuComputePassEncoderRelease(cpass);
            var att = colorAttachment(view);
            var rp = std.mem.zeroes(c.WGPURenderPassDescriptor);
            rp.colorAttachmentCount = 1;
            rp.colorAttachments = &att;
            const pass = c.wgpuCommandEncoderBeginRenderPass(enc, &rp);
            c.wgpuRenderPassEncoderSetPipeline(pass, tri_pipe);
            c.wgpuRenderPassEncoderSetVertexBuffer(pass, 0, vbuf, 0, 18 * 4);
            c.wgpuRenderPassEncoderDraw(pass, 3, 1, 0, 0);
            c.wgpuRenderPassEncoderEnd(pass);
            c.wgpuRenderPassEncoderRelease(pass);
            const cmd = c.wgpuCommandEncoderFinish(enc, null);
            c.wgpuCommandEncoderRelease(enc);
            c.wgpuQueueSubmit(g.queue, 1, &cmd); // ONE submit: compute + render
            c.wgpuCommandBufferRelease(cmd);
            g.waitIdle();

            readbackTexture(&g, target, staging, w, h, tight);
            // triangle center: NDC (t, -0.1) -> px ((t+1)/2*w, 0.55h)
            const px: u32 = @intFromFloat((@as(f64, t) + 1.0) / 2.0 * @as(f64, @floatFromInt(w)));
            const py: u32 = @intFromFloat(0.55 * @as(f64, @floatFromInt(h)));
            ok = expectPixel(tight, w, px, py, .{ 240, 200, 40, 255 }, 0, "compose tri") and ok;
            // where the t=0 triangle was must be CLEAR when t=0.5
            if (t == 0.5) {
                ok = expectPixel(tight, w, w / 8, py, .{ CLEAR_R, CLEAR_G, CLEAR_B, 255 }, 0, "compose moved-away") and ok;
            }
        }
        std.debug.print("compose: compute-written vertices rendered, ONE submit per frame, moved with t: {s}\n", .{if (ok) "OK" else "FAILED"});

        c.wgpuBindGroupRelease(cbg);
        c.wgpuComputePipelineRelease(cpipe);
        c.wgpuBufferRelease(ubuf);
        c.wgpuBufferRelease(vbuf);
        c.wgpuBufferRelease(staging);
        c.wgpuTextureViewRelease(view);
        c.wgpuTextureRelease(target);
    }

    // ---- teardown
    c.wgpuBindGroupRelease(tex_bg);
    c.wgpuSamplerRelease(sampler);
    c.wgpuTextureViewRelease(checker_view);
    c.wgpuTextureRelease(checker_tex);
    c.wgpuBufferRelease(tri_buf);
    c.wgpuBufferRelease(quad_buf);
    c.wgpuRenderPipelineRelease(tri_pipe);
    c.wgpuRenderPipelineRelease(tex_pipe);
    c.wgpuQueueRelease(g.queue);
    c.wgpuDeviceRelease(g.device);
    c.wgpuInstanceRelease(g.instance);
}

pub fn main() !void {
    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);

    if (args.len < 2) {
        std.debug.print("usage: gr0_render_spike list | run <adapterIndex>\n", .{});
        return;
    }
    const cmd = args[1];
    if (std.mem.eql(u8, cmd, "list")) {
        const instance = c.wgpuCreateInstance(null) orelse return error.NoInstance;
        const adapters = try enumerateAdapters(instance);
        for (adapters, 0..) |a2, i| printAdapter(i, a2);
    } else if (std.mem.eql(u8, cmd, "run")) {
        if (args.len < 3) return error.MissingAdapterIndex;
        const idx = try std.fmt.parseInt(usize, args[2], 10);
        try runSuite(idx);
    } else {
        std.debug.print("unknown command: {s}\n", .{cmd});
    }
}
