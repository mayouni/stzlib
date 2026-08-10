//! stz_gpu -- the GPU plane's lifecycle layer (phase G1 of SOFTANZA_GPU_PLAN.md).
//!
//! What lives here, and why (each traced to a G0 measurement or a house law):
//!
//!   - DYNAMIC wgpu loading. wgpu_native.dll is resolved at Init() time via
//!     LoadLibrary, never at link time, so stz_gpu.dll ALWAYS loads. A machine
//!     without the runtime (or without any adapter) degrades to counted
//!     fallback -- CI has no GPU and every guard must pass there.
//!   - HANDLE TABLES, generation-keyed. Ring never sees a pointer: buffers and
//!     kernels are integer ids of the form (generation << 32) | (slot + 1). An
//!     evicted or freed buffer bumps its slot's generation, so a stale id is
//!     DETECTED (status STALE), never silently reused -- the ring_api handle
//!     cliff lesson, applied to VRAM.
//!   - BOUNDED VRAM CACHE, FIFO eviction. Ring has no destructors; explicit
//!     Free plus a budget is the only honest lifetime story (the stzList
//!     residency keystone). Creation that would exceed the budget evicts the
//!     OLDEST live buffer first, and every eviction is COUNTED (a bounded
//!     record must count what it drops).
//!   - WGSL COMPILE-CACHE keyed by kernel text hash. G0 measured pipeline
//!     compile at 5-34 ms cold vs 0.4 ms driver-warm; the cache turns repeat
//!     compiles into hits, and hits are counted separately from compiles so a
//!     guard can assert the MECHANISM (1 compile + N-1 hits), not the vibe.
//!   - TDR-SAFE TILING. Windows kills kernels at ~2 s. Every kernel compiled
//!     through this layer binds a layer-owned tile uniform at @binding(0)
//!     (struct StzTile { xoff: u32 } -- xoff counts WORKGROUPS along x); user
//!     buffers start at @binding(1). A dispatch whose total workgroup count
//!     exceeds the tile limit is split into multiple submits along x, with
//!     xoff advanced per tile. queue.writeBuffer/submit interleaving is
//!     queue-ordered, so ONE shared uniform buffer serves every tile.
//!   - CALIBRATION STORE. Thresholds are per-op-name, SET from measurement
//!     (G0's crossovers seed them; G3 recalibrates per install). ShouldDispatch
//!     answers the routing question and answers CPU whenever the GPU is absent
//!     or the op unknown -- conservative by construction. G0's clock-inversion
//!     finding stands: store WARM-MIN numbers, not sustained.
//!   - INSTRUMENTS with house names: gpu.dispatch.ms, gpu.transfer.bytes,
//!     gpu.fallback.count (counter indices below). Fallback increments ONLY
//!     when an op that was asked for could not run on the device.
//!
//! Threading: single-threaded by contract, like every other bridge -- the Ring
//! VM is the only caller.

const std = @import("std");
// pub: gpu_render.zig (GR1) must share THIS @cImport -- a second @cImport of
// the same headers is a distinct type universe and nothing would assign.
pub const c = @cImport({
    @cInclude("webgpu/webgpu.h");
    @cInclude("webgpu/wgpu.h");
});

const alloc = std.heap.c_allocator;

// ---------------------------------------------------------------- status codes
// Kept as plain ints; the Ring face documents them.
pub const OK: i32 = 0;
pub const FALLBACK: i32 = 1; // no device (not initialized / lost / no runtime)
pub const STALE: i32 = 2; // generation mismatch: buffer was evicted or freed
pub const BAD_ARG: i32 = 3;
pub const TOO_LARGE: i32 = 4; // exceeds device limits or the whole VRAM budget
pub const GPU_ERROR: i32 = 5; // device-side validation/internal error captured

// ---------------------------------------------------------------- counters
pub const CTR_DISPATCH_COUNT = 0; // gpu.dispatch.count
pub const CTR_DISPATCH_MS = 1; // gpu.dispatch.ms (submit-side wall time, total)
pub const CTR_TRANSFER_BYTES = 2; // gpu.transfer.bytes (upload + readback)
pub const CTR_FALLBACK_COUNT = 3; // gpu.fallback.count
pub const CTR_COMPILE_COUNT = 4; // real WGSL->pipeline compiles
pub const CTR_COMPILE_HITS = 5; // compile-cache hits
pub const CTR_SUBMIT_COUNT = 6; // queue submits (tiling multiplies these)
pub const CTR_EVICT_COUNT = 7; // buffers evicted by the VRAM bound
pub const CTR_BUFFER_LIVE = 8; // live device buffers right now
pub const CTR_GPU_ERRORS = 9; // uncaptured device errors
// GR1 render lifecycle (indices are a public contract -- append, never renumber)
pub const CTR_RPIPE_COMPILE = 10; // real WGSL->render-pipeline compiles
pub const CTR_RPIPE_HITS = 11; // render-pipeline cache hits
pub const CTR_DRAW_COUNT = 12; // draw calls encoded
pub const CTR_TEXTURE_LIVE = 13; // live textures/targets right now
const N_COUNTERS = 14;

var counters: [N_COUNTERS]f64 = @splat(0);

// ---------------------------------------------------------------- wgpu, loaded at runtime
// Only the functions the lifecycle needs. Field name == exported symbol name;
// loadWgpu resolves every field or fails as a unit (no half-loaded state).
pub const Fns = struct {
    wgpuCreateInstance: *const @TypeOf(c.wgpuCreateInstance),
    wgpuInstanceRelease: *const @TypeOf(c.wgpuInstanceRelease),
    wgpuInstanceProcessEvents: *const @TypeOf(c.wgpuInstanceProcessEvents),
    wgpuInstanceEnumerateAdapters: *const @TypeOf(c.wgpuInstanceEnumerateAdapters),
    wgpuAdapterGetInfo: *const @TypeOf(c.wgpuAdapterGetInfo),
    wgpuAdapterInfoFreeMembers: *const @TypeOf(c.wgpuAdapterInfoFreeMembers),
    wgpuAdapterRequestDevice: *const @TypeOf(c.wgpuAdapterRequestDevice),
    wgpuDeviceGetQueue: *const @TypeOf(c.wgpuDeviceGetQueue),
    wgpuDeviceCreateBuffer: *const @TypeOf(c.wgpuDeviceCreateBuffer),
    wgpuDeviceCreateShaderModule: *const @TypeOf(c.wgpuDeviceCreateShaderModule),
    wgpuDeviceCreateComputePipeline: *const @TypeOf(c.wgpuDeviceCreateComputePipeline),
    wgpuDeviceCreateCommandEncoder: *const @TypeOf(c.wgpuDeviceCreateCommandEncoder),
    wgpuDeviceCreateBindGroup: *const @TypeOf(c.wgpuDeviceCreateBindGroup),
    wgpuDevicePoll: *const @TypeOf(c.wgpuDevicePoll),
    wgpuDeviceRelease: *const @TypeOf(c.wgpuDeviceRelease),
    wgpuQueueSubmit: *const @TypeOf(c.wgpuQueueSubmit),
    wgpuQueueWriteBuffer: *const @TypeOf(c.wgpuQueueWriteBuffer),
    wgpuQueueRelease: *const @TypeOf(c.wgpuQueueRelease),
    wgpuBufferMapAsync: *const @TypeOf(c.wgpuBufferMapAsync),
    wgpuBufferGetConstMappedRange: *const @TypeOf(c.wgpuBufferGetConstMappedRange),
    wgpuBufferUnmap: *const @TypeOf(c.wgpuBufferUnmap),
    wgpuBufferRelease: *const @TypeOf(c.wgpuBufferRelease),
    wgpuShaderModuleRelease: *const @TypeOf(c.wgpuShaderModuleRelease),
    wgpuComputePipelineGetBindGroupLayout: *const @TypeOf(c.wgpuComputePipelineGetBindGroupLayout),
    wgpuComputePipelineRelease: *const @TypeOf(c.wgpuComputePipelineRelease),
    wgpuBindGroupLayoutRelease: *const @TypeOf(c.wgpuBindGroupLayoutRelease),
    wgpuBindGroupRelease: *const @TypeOf(c.wgpuBindGroupRelease),
    wgpuCommandEncoderBeginComputePass: *const @TypeOf(c.wgpuCommandEncoderBeginComputePass),
    wgpuCommandEncoderCopyBufferToBuffer: *const @TypeOf(c.wgpuCommandEncoderCopyBufferToBuffer),
    wgpuCommandEncoderFinish: *const @TypeOf(c.wgpuCommandEncoderFinish),
    wgpuCommandEncoderRelease: *const @TypeOf(c.wgpuCommandEncoderRelease),
    wgpuComputePassEncoderSetPipeline: *const @TypeOf(c.wgpuComputePassEncoderSetPipeline),
    wgpuComputePassEncoderSetBindGroup: *const @TypeOf(c.wgpuComputePassEncoderSetBindGroup),
    wgpuComputePassEncoderDispatchWorkgroups: *const @TypeOf(c.wgpuComputePassEncoderDispatchWorkgroups),
    wgpuComputePassEncoderEnd: *const @TypeOf(c.wgpuComputePassEncoderEnd),
    wgpuComputePassEncoderRelease: *const @TypeOf(c.wgpuComputePassEncoderRelease),
    wgpuCommandBufferRelease: *const @TypeOf(c.wgpuCommandBufferRelease),
    // GR1 render surface (same DLL exports them all; resolved as a unit)
    wgpuDeviceCreateTexture: *const @TypeOf(c.wgpuDeviceCreateTexture),
    wgpuTextureCreateView: *const @TypeOf(c.wgpuTextureCreateView),
    wgpuTextureViewRelease: *const @TypeOf(c.wgpuTextureViewRelease),
    wgpuTextureRelease: *const @TypeOf(c.wgpuTextureRelease),
    wgpuDeviceCreateSampler: *const @TypeOf(c.wgpuDeviceCreateSampler),
    wgpuSamplerRelease: *const @TypeOf(c.wgpuSamplerRelease),
    wgpuDeviceCreateRenderPipeline: *const @TypeOf(c.wgpuDeviceCreateRenderPipeline),
    wgpuRenderPipelineGetBindGroupLayout: *const @TypeOf(c.wgpuRenderPipelineGetBindGroupLayout),
    wgpuRenderPipelineRelease: *const @TypeOf(c.wgpuRenderPipelineRelease),
    wgpuCommandEncoderBeginRenderPass: *const @TypeOf(c.wgpuCommandEncoderBeginRenderPass),
    wgpuCommandEncoderCopyTextureToBuffer: *const @TypeOf(c.wgpuCommandEncoderCopyTextureToBuffer),
    wgpuRenderPassEncoderSetPipeline: *const @TypeOf(c.wgpuRenderPassEncoderSetPipeline),
    wgpuRenderPassEncoderSetBindGroup: *const @TypeOf(c.wgpuRenderPassEncoderSetBindGroup),
    wgpuRenderPassEncoderSetVertexBuffer: *const @TypeOf(c.wgpuRenderPassEncoderSetVertexBuffer),
    wgpuRenderPassEncoderSetIndexBuffer: *const @TypeOf(c.wgpuRenderPassEncoderSetIndexBuffer),
    wgpuRenderPassEncoderDraw: *const @TypeOf(c.wgpuRenderPassEncoderDraw),
    wgpuRenderPassEncoderDrawIndexed: *const @TypeOf(c.wgpuRenderPassEncoderDrawIndexed),
    wgpuRenderPassEncoderEnd: *const @TypeOf(c.wgpuRenderPassEncoderEnd),
    wgpuRenderPassEncoderRelease: *const @TypeOf(c.wgpuRenderPassEncoderRelease),
    wgpuQueueWriteTexture: *const @TypeOf(c.wgpuQueueWriteTexture),
    // GR5 presentation. Resolved with the rest: a wgpu_native that can
    // render can also present, so a partial table is not a state worth
    // modelling.
    wgpuInstanceCreateSurface: *const @TypeOf(c.wgpuInstanceCreateSurface),
    wgpuSurfaceGetCapabilities: *const @TypeOf(c.wgpuSurfaceGetCapabilities),
    wgpuSurfaceCapabilitiesFreeMembers: *const @TypeOf(c.wgpuSurfaceCapabilitiesFreeMembers),
    wgpuSurfaceConfigure: *const @TypeOf(c.wgpuSurfaceConfigure),
    wgpuSurfaceUnconfigure: *const @TypeOf(c.wgpuSurfaceUnconfigure),
    wgpuSurfaceGetCurrentTexture: *const @TypeOf(c.wgpuSurfaceGetCurrentTexture),
    wgpuSurfacePresent: *const @TypeOf(c.wgpuSurfacePresent),
    wgpuSurfaceRelease: *const @TypeOf(c.wgpuSurfaceRelease),
};

var fns: Fns = undefined;
var wgpu_lib: ?std.DynLib = null;

fn loadWgpu(path: []const u8) bool {
    if (wgpu_lib != null) return true;
    var dl = std.DynLib.open(path) catch return false;
    inline for (@typeInfo(Fns).@"struct".fields) |f| {
        @field(fns, f.name) = dl.lookup(f.type, f.name) orelse {
            dl.close();
            return false;
        };
    }
    wgpu_lib = dl;
    return true;
}

// ---------------------------------------------------------------- device state
var instance: c.WGPUInstance = null;
var adapters: []c.WGPUAdapter = &.{};
var device: c.WGPUDevice = null;
var queue: c.WGPUQueue = null;
var tile_uniform: c.WGPUBuffer = null; // the ONE shared StzTile uniform
pub const PARAMS_BYTES: usize = 64;
var params_uniform: c.WGPUBuffer = null; // shared op-params uniform (see dispatch_params)
var available = false;
var selected_adapter: i32 = -1;

var last_error_buf: [512]u8 = @splat(0);
var last_error_len: usize = 0;

fn setLastError(msg: []const u8) void {
    const n = @min(msg.len, last_error_buf.len);
    @memcpy(last_error_buf[0..n], msg[0..n]);
    last_error_len = n;
}

pub fn lastError() []const u8 {
    return last_error_buf[0..last_error_len];
}

fn sv(s: []const u8) c.WGPUStringView {
    return .{ .data = s.ptr, .length = s.len };
}

fn svSlice(v: c.WGPUStringView) []const u8 {
    if (v.data == null) return "";
    if (v.length == std.math.maxInt(usize)) return std.mem.span(@as([*:0]const u8, @ptrCast(v.data)));
    return v.data[0..v.length];
}

var g_device_ready = false;
var g_requested_device: c.WGPUDevice = null;

fn onDevice(status: c.WGPURequestDeviceStatus, dev: c.WGPUDevice, message: c.WGPUStringView, _: ?*anyopaque, _: ?*anyopaque) callconv(.c) void {
    if (status == c.WGPURequestDeviceStatus_Success) {
        g_requested_device = dev;
    } else {
        setLastError(svSlice(message));
    }
    g_device_ready = true;
}

fn onUncapturedError(_: [*c]const c.WGPUDevice, _: c.WGPUErrorType, message: c.WGPUStringView, _: ?*anyopaque, _: ?*anyopaque) callconv(.c) void {
    counters[CTR_GPU_ERRORS] += 1;
    setLastError(svSlice(message));
}

fn onDeviceLost(_: [*c]const c.WGPUDevice, _: c.WGPUDeviceLostReason, message: c.WGPUStringView, _: ?*anyopaque, _: ?*anyopaque) callconv(.c) void {
    // TDR / driver reset / teardown: from here on every op is a counted
    // fallback until a fresh Init. (During Shutdown this fires too -- benign,
    // available is already false by then.)
    if (available) {
        counters[CTR_GPU_ERRORS] += 1;
        setLastError(svSlice(message));
        available = false;
    }
}

var g_map_done = false;
var g_map_ok = false;

fn onMap(status: c.WGPUMapAsyncStatus, message: c.WGPUStringView, _: ?*anyopaque, _: ?*anyopaque) callconv(.c) void {
    g_map_ok = status == c.WGPUMapAsyncStatus_Success;
    if (!g_map_ok) setLastError(svSlice(message));
    g_map_done = true;
}

// ---------------------------------------------------------------- buffer table
// Slot ids: (generation << 32) | (slot_index + 1). Generation bumps on free
// AND on eviction, so both produce STALE, and 0 is never a valid id.
const BufferSlot = struct {
    buf: c.WGPUBuffer = null,
    size: usize = 0,
    gen: u32 = 1,
    live: bool = false,
    birth: u64 = 0, // creation order for FIFO eviction
};

var buffers: std.ArrayList(BufferSlot) = .{};
var birth_counter: u64 = 0;
var vram_budget: usize = 1 << 30; // 1 GB default; the face calibrates this
var vram_in_use: usize = 0;

fn makeId(slot: usize, gen: u32) i64 {
    return (@as(i64, gen) << 32) | @as(i64, @intCast(slot + 1));
}

fn slotOf(id: i64) ?usize {
    const idx = id & 0xffff_ffff;
    if (idx <= 0 or idx > @as(i64, @intCast(buffers.items.len))) return null;
    const slot: usize = @intCast(idx - 1);
    const gen: u32 = @intCast((id >> 32) & 0xffff_ffff);
    if (!buffers.items[slot].live or buffers.items[slot].gen != gen) return null;
    return slot;
}

fn destroySlot(slot: usize) void {
    const s = &buffers.items[slot];
    if (s.buf) |b| fns.wgpuBufferRelease(b);
    s.buf = null;
    s.live = false;
    s.gen +%= 1;
    vram_in_use -= s.size;
    s.size = 0;
    counters[CTR_BUFFER_LIVE] -= 1;
}

// ---------------------------------------------------------------- texture table
// GR1: textures and render targets join the SAME discipline -- gen-keyed ids
// (their own table, so a texture id and a buffer id are separate namespaces,
// like kernels), the SAME vram budget, and FIFO eviction ACROSS both kinds.
pub const TEX_TARGET: i32 = 0; // offscreen render target (RenderAttachment|CopySrc)
pub const TEX_NEAREST: i32 = 1; // sampled texture, nearest filtering
pub const TEX_LINEAR: i32 = 2; // sampled texture, linear filtering
pub const TEX_DEPTH: i32 = 3; // depth buffer, Depth32Float (GR3; never sampled,
// never read back -- it exists so the GPU can decide what is in front)

const TextureSlot = struct {
    tex: c.WGPUTexture = null,
    view: c.WGPUTextureView = null,
    w: u32 = 0,
    h: u32 = 0,
    kind: i32 = 0,
    bytes: usize = 0,
    gen: u32 = 1,
    live: bool = false,
    birth: u64 = 0,
    // GR5: a swapchain frame adopted for one frame. It is NOT ours to
    // budget (the surface allocated it) and it must NEVER be evicted --
    // eviction mid-frame would free the thing being drawn into.
    pinned: bool = false,
};

var textures: std.ArrayList(TextureSlot) = .{};

fn texSlotOf(id: i64) ?usize {
    const idx = id & 0xffff_ffff;
    if (idx <= 0 or idx > @as(i64, @intCast(textures.items.len))) return null;
    const slot: usize = @intCast(idx - 1);
    const gen: u32 = @intCast((id >> 32) & 0xffff_ffff);
    if (!textures.items[slot].live or textures.items[slot].gen != gen) return null;
    return slot;
}

fn destroyTextureSlot(slot: usize) void {
    const s = &textures.items[slot];
    if (s.view) |v| fns.wgpuTextureViewRelease(v);
    if (s.tex) |t| fns.wgpuTextureRelease(t);
    s.view = null;
    s.tex = null;
    s.live = false;
    s.pinned = false;
    s.gen +%= 1;
    vram_in_use -= s.bytes;
    s.bytes = 0;
    counters[CTR_TEXTURE_LIVE] -= 1;
}

/// FIFO across live buffers AND textures: evict the oldest until `need` fits
/// the budget. Returns false if even an empty cache cannot fit it.
fn evictUntilFits(need: usize) bool {
    if (need > vram_budget) return false;
    while (vram_in_use + need > vram_budget) {
        var oldest_buf: ?usize = null;
        var oldest_tex: ?usize = null;
        var oldest_birth: u64 = std.math.maxInt(u64);
        for (buffers.items, 0..) |s, i| {
            if (s.live and s.birth < oldest_birth) {
                oldest_birth = s.birth;
                oldest_buf = i;
            }
        }
        for (textures.items, 0..) |s, i| {
            if (s.live and !s.pinned and s.birth < oldest_birth) {
                oldest_birth = s.birth;
                oldest_tex = i;
                oldest_buf = null;
            }
        }
        if (oldest_tex) |t| {
            destroyTextureSlot(t);
        } else if (oldest_buf) |bslot| {
            destroySlot(bslot);
        } else return false;
        counters[CTR_EVICT_COUNT] += 1;
    }
    return true;
}

// ---------------------------------------------------------------- kernel cache
const KernelSlot = struct {
    pipeline: c.WGPUComputePipeline = null,
    layout: c.WGPUBindGroupLayout = null,
    hash: u64 = 0,
    len: usize = 0,
};

var kernels: std.ArrayList(KernelSlot) = .{};

// ---------------------------------------------------------------- calibration store
// Op name -> crossover threshold (problem size n at which the GPU starts
// winning, warm-min basis). In-memory; the Ring face persists across runs.
const CalibEntry = struct { hash: u64, threshold: f64 };
var calib: std.ArrayList(CalibEntry) = .{};

// ---------------------------------------------------------------- tiling
var tile_limit: u32 = 32768; // max workgroups per submit. From G0: 16384 wg of
// 2048^2-matmul weight = 65 ms (3050) / 275 ms (iGPU); 2x that stays far under
// the 2 s TDR watchdog on both populations. Configurable; G2 refines per op.

// ---------------------------------------------------------------- public API

pub fn stz_gpu_init(path: [*:0]const u8) callconv(.c) i32 {
    if (available) return 1;
    setLastError("");
    if (!loadWgpu(std.mem.span(path))) {
        setLastError("wgpu runtime not loadable");
        return 0;
    }
    if (instance == null) {
        instance = fns.wgpuCreateInstance(null);
        if (instance == null) {
            setLastError("wgpuCreateInstance failed");
            return 0;
        }
    }
    if (adapters.len == 0) {
        const count = fns.wgpuInstanceEnumerateAdapters(instance, null, null);
        if (count == 0) {
            setLastError("no adapters");
            return 0;
        }
        adapters = alloc.alloc(c.WGPUAdapter, count) catch return 0;
        _ = fns.wgpuInstanceEnumerateAdapters(instance, null, adapters.ptr);
    }
    // Default adapter: first discrete, else adapter 0. (Vulkan and D3D12 both
    // enumerate; first-discrete lands on the 3050-class card when present.)
    var pick: usize = 0;
    for (adapters, 0..) |a, i| {
        var info = std.mem.zeroes(c.WGPUAdapterInfo);
        _ = fns.wgpuAdapterGetInfo(a, &info);
        const discrete = info.adapterType == c.WGPUAdapterType_DiscreteGPU;
        fns.wgpuAdapterInfoFreeMembers(info);
        if (discrete) {
            pick = i;
            break;
        }
    }
    return openDeviceOn(pick);
}

fn openDeviceOn(idx: usize) i32 {
    if (idx >= adapters.len) return 0;
    var desc = std.mem.zeroes(c.WGPUDeviceDescriptor);
    desc.label = sv("stz_gpu");
    desc.uncapturedErrorCallbackInfo = .{ .nextInChain = null, .callback = onUncapturedError, .userdata1 = null, .userdata2 = null };
    desc.deviceLostCallbackInfo = .{ .nextInChain = null, .mode = c.WGPUCallbackMode_AllowProcessEvents, .callback = onDeviceLost, .userdata1 = null, .userdata2 = null };
    const cbinfo = c.WGPURequestDeviceCallbackInfo{
        .nextInChain = null,
        .mode = c.WGPUCallbackMode_AllowProcessEvents,
        .callback = onDevice,
        .userdata1 = null,
        .userdata2 = null,
    };
    g_device_ready = false;
    g_requested_device = null;
    _ = fns.wgpuAdapterRequestDevice(adapters[idx], &desc, cbinfo);
    while (!g_device_ready) fns.wgpuInstanceProcessEvents(instance);
    device = g_requested_device orelse return 0;
    queue = fns.wgpuDeviceGetQueue(device);
    if (queue == null) return 0;

    var tdesc = std.mem.zeroes(c.WGPUBufferDescriptor);
    tdesc.label = sv("stz_tile");
    tdesc.usage = c.WGPUBufferUsage_Uniform | c.WGPUBufferUsage_CopyDst;
    tdesc.size = 16;
    tile_uniform = fns.wgpuDeviceCreateBuffer(device, &tdesc);
    if (tile_uniform == null) return 0;

    var pdesc2 = std.mem.zeroes(c.WGPUBufferDescriptor);
    pdesc2.label = sv("stz_params");
    pdesc2.usage = c.WGPUBufferUsage_Uniform | c.WGPUBufferUsage_CopyDst;
    pdesc2.size = PARAMS_BYTES;
    params_uniform = fns.wgpuDeviceCreateBuffer(device, &pdesc2);
    if (params_uniform == null) return 0;

    selected_adapter = @intCast(idx);
    available = true;
    return 1;
}

/// Tear down device-scoped state (buffers, kernels, tile uniform, device).
/// Keeps the instance + adapter list so SelectAdapter/Init can rebuild.
fn closeDevice() void {
    if (!available and device == null) return;
    available = false;
    runCloseHooks(); // render/scene layers: abort pass, drop device objects
    for (buffers.items, 0..) |s, i| {
        if (s.live) destroySlot(i);
    }
    for (textures.items, 0..) |s, i| {
        if (s.live) destroyTextureSlot(i);
    }
    for (kernels.items) |*k| {
        if (k.layout) |l| fns.wgpuBindGroupLayoutRelease(l);
        if (k.pipeline) |p| fns.wgpuComputePipelineRelease(p);
        k.pipeline = null;
        k.layout = null;
    }
    kernels.clearRetainingCapacity();
    if (g_batching) {
        // a device going away mid-batch: drop the encoding, keep no dangling
        // references (nothing was submitted, so nothing is owed)
        g_batching = false;
        if (g_batch_pass) |p| fns.wgpuComputePassEncoderRelease(p);
        if (g_batch_enc) |e| fns.wgpuCommandEncoderRelease(e);
        g_batch_pass = null;
        g_batch_enc = null;
        for (0..g_batch_n) |i| {
            if (g_batch_bgs[i]) |bg| fns.wgpuBindGroupRelease(bg);
            g_batch_bgs[i] = null;
        }
        g_batch_n = 0;
    }
    releasePool();
    if (tile_uniform) |t| fns.wgpuBufferRelease(t);
    tile_uniform = null;
    if (params_uniform) |t| fns.wgpuBufferRelease(t);
    params_uniform = null;
    if (queue) |q| fns.wgpuQueueRelease(q);
    queue = null;
    if (device) |d| fns.wgpuDeviceRelease(d);
    device = null;
    selected_adapter = -1;
}

pub fn stz_gpu_shutdown() callconv(.c) void {
    closeDevice();
    // instance + adapters stay resident: re-Init is cheap and adapter ids
    // stay stable for the process lifetime. The DLL stays loaded.
}

pub fn stz_gpu_is_available() callconv(.c) i32 {
    return if (available) 1 else 0;
}

pub fn stz_gpu_adapter_count() callconv(.c) i32 {
    return @intCast(adapters.len);
}

pub fn stz_gpu_adapter_name(idx: i32, out: [*]u8, cap: i32) callconv(.c) i32 {
    if (idx < 0 or idx >= adapters.len or cap <= 0) return 0;
    var info = std.mem.zeroes(c.WGPUAdapterInfo);
    _ = fns.wgpuAdapterGetInfo(adapters[@intCast(idx)], &info);
    defer fns.wgpuAdapterInfoFreeMembers(info);
    const name = svSlice(info.device);
    const n = @min(name.len, @as(usize, @intCast(cap)));
    @memcpy(out[0..n], name[0..n]);
    return @intCast(n);
}

pub fn stz_gpu_selected_adapter() callconv(.c) i32 {
    return selected_adapter;
}

/// Switch adapters. Device-scoped handles (buffers, kernels) are invalidated
/// -- their ids go STALE, they do not silently migrate.
pub fn stz_gpu_select_adapter(idx: i32) callconv(.c) i32 {
    if (idx < 0 or idx >= adapters.len) return 0;
    if (selected_adapter == idx and available) return 1;
    closeDevice();
    return openDeviceOn(@intCast(idx));
}

pub fn stz_gpu_set_vram_budget(bytes: f64) callconv(.c) void {
    if (bytes > 0) vram_budget = @intFromFloat(bytes);
}

pub fn stz_gpu_vram_budget() callconv(.c) f64 {
    return @floatFromInt(vram_budget);
}

pub fn stz_gpu_vram_in_use() callconv(.c) f64 {
    return @floatFromInt(vram_in_use);
}

pub fn stz_gpu_set_tile_limit(wg: f64) callconv(.c) void {
    if (wg >= 1) tile_limit = @intFromFloat(wg);
}

pub fn stz_gpu_tile_limit() callconv(.c) f64 {
    return @floatFromInt(tile_limit);
}

pub fn stz_gpu_counter(which: i32) callconv(.c) f64 {
    if (which < 0 or which >= N_COUNTERS) return -1;
    return counters[@intCast(which)];
}

/// For higher layers (the op library) refusing an op because the device is
/// absent: the refusal must be COUNTED at the layer that refuses.
pub fn countFallback() void {
    counters[CTR_FALLBACK_COUNT] += 1;
}

pub fn stz_gpu_counters_reset() callconv(.c) void {
    // Structural gauges survive a reset -- they describe state, not history.
    const live = counters[CTR_BUFFER_LIVE];
    const tex_live = counters[CTR_TEXTURE_LIVE];
    counters = @splat(0);
    counters[CTR_BUFFER_LIVE] = live;
    counters[CTR_TEXTURE_LIVE] = tex_live;
}

// ---------------- buffers

pub fn stz_gpu_buffer_new(nbytes: f64) callconv(.c) i64 {
    if (!available) {
        counters[CTR_FALLBACK_COUNT] += 1;
        return 0;
    }
    if (nbytes < 4) return 0;
    const size: usize = @intFromFloat(nbytes);
    if (!evictUntilFits(size)) {
        counters[CTR_FALLBACK_COUNT] += 1; // asked for GPU memory, could not have it
        return 0;
    }
    var desc = std.mem.zeroes(c.WGPUBufferDescriptor);
    desc.label = sv("stz_buf");
    // Vertex|Index joined in GR1: ANY lifecycle buffer can feed a draw, and a
    // compute kernel can write vertices a render pass consumes (the GR0
    // composition witness as a property of the layer, not a special kind).
    desc.usage = c.WGPUBufferUsage_Storage | c.WGPUBufferUsage_CopyDst | c.WGPUBufferUsage_CopySrc |
        c.WGPUBufferUsage_Vertex | c.WGPUBufferUsage_Index;
    desc.size = size;
    const buf = fns.wgpuDeviceCreateBuffer(device, &desc);
    if (buf == null) {
        counters[CTR_FALLBACK_COUNT] += 1;
        return 0;
    }
    // reuse a dead slot or grow
    var slot: usize = buffers.items.len;
    for (buffers.items, 0..) |s, i| {
        if (!s.live) {
            slot = i;
            break;
        }
    }
    if (slot == buffers.items.len) {
        buffers.append(alloc, .{}) catch {
            fns.wgpuBufferRelease(buf);
            return 0;
        };
    }
    const s = &buffers.items[slot];
    s.buf = buf;
    s.size = size;
    s.live = true;
    birth_counter += 1;
    s.birth = birth_counter;
    vram_in_use += size;
    counters[CTR_BUFFER_LIVE] += 1;
    return makeId(slot, s.gen);
}

pub fn stz_gpu_buffer_free(id: i64) callconv(.c) i32 {
    const slot = slotOf(id) orelse return STALE;
    destroySlot(slot);
    return OK;
}

pub fn stz_gpu_buffer_size(id: i64) callconv(.c) f64 {
    const slot = slotOf(id) orelse return -1;
    return @floatFromInt(buffers.items[slot].size);
}

/// Upload raw bytes. Staged by wgpu; flushed by the next submit (a dispatch or
/// a read) -- no extra submit here, residency chains stay one-submit-per-op.
pub fn stz_gpu_buffer_write(id: i64, data: [*]const u8, nbytes: f64) callconv(.c) i32 {
    if (!available) {
        counters[CTR_FALLBACK_COUNT] += 1;
        return FALLBACK;
    }
    const slot = slotOf(id) orelse return STALE;
    const n: usize = @intFromFloat(nbytes);
    if (n > buffers.items[slot].size) return BAD_ARG;
    fns.wgpuQueueWriteBuffer(queue, buffers.items[slot].buf, 0, data, n);
    counters[CTR_TRANSFER_BYTES] += nbytes;
    return OK;
}

/// Read back `nbytes` from the buffer into `out`. Synchronous: encodes a copy
/// to a transient staging buffer, submits, maps, copies out.
pub fn stz_gpu_buffer_read(id: i64, out: [*]u8, nbytes: f64) callconv(.c) i32 {
    if (!available) {
        counters[CTR_FALLBACK_COUNT] += 1;
        return FALLBACK;
    }
    const slot = slotOf(id) orelse return STALE;
    const n: usize = @intFromFloat(nbytes);
    if (n > buffers.items[slot].size) return BAD_ARG;

    var sdesc = std.mem.zeroes(c.WGPUBufferDescriptor);
    sdesc.label = sv("stz_staging");
    sdesc.usage = c.WGPUBufferUsage_MapRead | c.WGPUBufferUsage_CopyDst;
    sdesc.size = n;
    const staging = fns.wgpuDeviceCreateBuffer(device, &sdesc);
    if (staging == null) return GPU_ERROR;
    defer fns.wgpuBufferRelease(staging);

    const enc = fns.wgpuDeviceCreateCommandEncoder(device, null);
    fns.wgpuCommandEncoderCopyBufferToBuffer(enc, buffers.items[slot].buf, 0, staging, 0, n);
    const cmd = fns.wgpuCommandEncoderFinish(enc, null);
    fns.wgpuCommandEncoderRelease(enc);
    fns.wgpuQueueSubmit(queue, 1, &cmd);
    fns.wgpuCommandBufferRelease(cmd);
    counters[CTR_SUBMIT_COUNT] += 1;

    g_map_done = false;
    g_map_ok = false;
    const cbinfo = c.WGPUBufferMapCallbackInfo{
        .nextInChain = null,
        .mode = c.WGPUCallbackMode_AllowProcessEvents,
        .callback = onMap,
        .userdata1 = null,
        .userdata2 = null,
    };
    _ = fns.wgpuBufferMapAsync(staging, c.WGPUMapMode_Read, 0, n, cbinfo);
    while (!g_map_done) {
        _ = fns.wgpuDevicePoll(device, 1, null);
        fns.wgpuInstanceProcessEvents(instance);
    }
    if (!g_map_ok) return GPU_ERROR;
    const p = fns.wgpuBufferGetConstMappedRange(staging, 0, n);
    if (p == null) return GPU_ERROR;
    @memcpy(out[0..n], @as([*]const u8, @ptrCast(p.?))[0..n]);
    fns.wgpuBufferUnmap(staging);
    counters[CTR_TRANSFER_BYTES] += nbytes;
    return OK;
}

// ---------------- textures (GR1)

/// kind: TEX_TARGET (0) offscreen render target, TEX_NEAREST (1) / TEX_LINEAR
/// (2) sampled texture. RGBA8Unorm always -- ONE format, the GR0 contract.
pub fn stz_gpu_texture_new(wf2: f64, hf: f64, kind: f64) callconv(.c) i64 {
    if (!available) {
        counters[CTR_FALLBACK_COUNT] += 1;
        return 0;
    }
    const k: i32 = @intFromFloat(kind);
    if (wf2 < 1 or hf < 1 or k < 0 or k > 3) return 0;
    const w: u32 = @intFromFloat(wf2);
    const h: u32 = @intFromFloat(hf);
    if (w > 16384 or h > 16384) return 0; // WebGPU default maxTextureDimension2D
    const bytes = @as(usize, w) * h * 4; // Depth32Float is 4 bytes too
    if (!evictUntilFits(bytes)) {
        counters[CTR_FALLBACK_COUNT] += 1;
        return 0;
    }
    var desc = std.mem.zeroes(c.WGPUTextureDescriptor);
    desc.label = sv("stz_tex");
    desc.usage = switch (k) {
        // GG4 needs a pass to READ what an earlier pass wrote -- that is
        // what a frame graph's resource edges mean. TextureBinding makes
        // every target samplable, which retires the "which target kind do
        // I need" question rather than answering it with a second kind.
        TEX_TARGET => c.WGPUTextureUsage_RenderAttachment | c.WGPUTextureUsage_CopySrc | c.WGPUTextureUsage_TextureBinding,
        TEX_DEPTH => c.WGPUTextureUsage_RenderAttachment,
        else => c.WGPUTextureUsage_TextureBinding | c.WGPUTextureUsage_CopyDst,
    };
    desc.dimension = c.WGPUTextureDimension_2D;
    desc.size = .{ .width = w, .height = h, .depthOrArrayLayers = 1 };
    desc.format = if (k == TEX_DEPTH) c.WGPUTextureFormat_Depth32Float else c.WGPUTextureFormat_RGBA8Unorm;
    desc.mipLevelCount = 1;
    desc.sampleCount = 1;
    const tex = fns.wgpuDeviceCreateTexture(device, &desc);
    if (tex == null) {
        counters[CTR_FALLBACK_COUNT] += 1;
        return 0;
    }
    const view = fns.wgpuTextureCreateView(tex, null);
    if (view == null) {
        fns.wgpuTextureRelease(tex);
        return 0;
    }
    var slot: usize = textures.items.len;
    for (textures.items, 0..) |s, i| {
        if (!s.live) {
            slot = i;
            break;
        }
    }
    if (slot == textures.items.len) {
        textures.append(alloc, .{}) catch {
            fns.wgpuTextureViewRelease(view);
            fns.wgpuTextureRelease(tex);
            return 0;
        };
    }
    const s = &textures.items[slot];
    s.tex = tex;
    s.view = view;
    s.w = w;
    s.h = h;
    s.kind = k;
    s.bytes = bytes;
    s.live = true;
    birth_counter += 1;
    s.birth = birth_counter;
    vram_in_use += bytes;
    counters[CTR_TEXTURE_LIVE] += 1;
    return makeId(slot, s.gen);
}

/// GR5: adopt a texture the SURFACE owns as a render target for one frame,
/// so that every draw path already shipped -- scenes, 3D, the pass machine
/// -- works against a window with no new code. The slot costs 0 VRAM budget
/// (we did not allocate it) and is PINNED against eviction (freeing the
/// frame being drawn into would be a spectacular way to lose a picture).
/// The caller releases it with releaseAdopted() after present.
pub fn adoptTarget(tex: c.WGPUTexture, view: c.WGPUTextureView, w: u32, h: u32) i64 {
    var slot: usize = textures.items.len;
    for (textures.items, 0..) |s, i| {
        if (!s.live) {
            slot = i;
            break;
        }
    }
    if (slot == textures.items.len) {
        textures.append(alloc, .{}) catch return 0;
    }
    const s = &textures.items[slot];
    s.tex = tex;
    s.view = view;
    s.w = w;
    s.h = h;
    s.kind = TEX_TARGET;
    s.bytes = 0;
    s.live = true;
    s.pinned = true;
    birth_counter += 1;
    s.birth = birth_counter;
    counters[CTR_TEXTURE_LIVE] += 1;
    return makeId(slot, s.gen);
}

pub fn releaseAdopted(id: i64) void {
    const slot = texSlotOf(id) orelse return;
    textures.items[slot].pinned = false;
    destroyTextureSlot(slot);
}

pub fn stz_gpu_texture_free(id: i64) callconv(.c) i32 {
    const slot = texSlotOf(id) orelse return STALE;
    destroyTextureSlot(slot);
    return OK;
}

pub fn stz_gpu_texture_width(id: i64) callconv(.c) f64 {
    const slot = texSlotOf(id) orelse return -1;
    return @floatFromInt(textures.items[slot].w);
}

pub fn stz_gpu_texture_height(id: i64) callconv(.c) f64 {
    const slot = texSlotOf(id) orelse return -1;
    return @floatFromInt(textures.items[slot].h);
}

/// Full-texture RGBA8 upload (sampled kinds only; a render target's pixels
/// come from rendering). nbytes must be exactly w*h*4.
pub fn stz_gpu_texture_write(id: i64, data: [*]const u8, nbytes: f64) callconv(.c) i32 {
    if (!available) {
        counters[CTR_FALLBACK_COUNT] += 1;
        return FALLBACK;
    }
    const slot = texSlotOf(id) orelse return STALE;
    const s = &textures.items[slot];
    if (s.kind == TEX_TARGET or s.kind == TEX_DEPTH) return BAD_ARG;
    const n: usize = @intFromFloat(nbytes);
    if (n != s.bytes) return BAD_ARG;
    var dst = std.mem.zeroes(c.WGPUTexelCopyTextureInfo);
    dst.texture = s.tex;
    var layout = std.mem.zeroes(c.WGPUTexelCopyBufferLayout);
    layout.bytesPerRow = s.w * 4; // writeTexture has no 256-byte row rule
    layout.rowsPerImage = s.h;
    const ext = c.WGPUExtent3D{ .width = s.w, .height = s.h, .depthOrArrayLayers = 1 };
    fns.wgpuQueueWriteTexture(queue, &dst, data, n, &layout, &ext);
    counters[CTR_TRANSFER_BYTES] += nbytes;
    return OK;
}

// ---------------- accessors for the render module (gpu_render.zig)
// The render pass machinery lives in its own file but is the SAME layer:
// same device, same fns table, same counters. These are engine-internal.

// Device-close hooks. Layers built ON this one (render, scene) hold
// device-scoped objects of their own; when the device goes they must drop
// them. A REGISTRY rather than a single slot, because there is more than
// one such layer now and a second one silently overwriting the first would
// leak exactly the objects this exists to release.
const MAX_CLOSE_HOOKS = 4;
var close_hooks: [MAX_CLOSE_HOOKS]?*const fn () void = @splat(null);

pub fn registerDeviceCloseHook(f: *const fn () void) void {
    for (&close_hooks) |*slot| {
        if (slot.*) |existing| {
            if (existing == f) return; // idempotent
            continue;
        }
        slot.* = f;
        return;
    }
}

fn runCloseHooks() void {
    for (close_hooks) |h| {
        if (h) |f| f();
    }
}

pub fn isAvail() bool {
    return available;
}

pub fn wfns() *const Fns {
    return &fns;
}

pub fn deviceHandle() c.WGPUDevice {
    return device;
}

pub fn queueHandle() c.WGPUQueue {
    return queue;
}

/// The adapter the device was made from -- surface CAPABILITIES are a
/// property of the (surface, adapter) pair, not of the device.
pub fn adapterHandle() c.WGPUAdapter {
    if (selected_adapter < 0 or selected_adapter >= @as(i32, @intCast(adapters.len))) return null;
    return adapters[@intCast(selected_adapter)];
}

pub fn instanceHandle() c.WGPUInstance {
    return instance;
}

pub fn rawBuffer(id: i64) ?c.WGPUBuffer {
    const slot = slotOf(id) orelse return null;
    return buffers.items[slot].buf;
}

pub fn rawBufferSize(id: i64) usize {
    const slot = slotOf(id) orelse return 0;
    return buffers.items[slot].size;
}

pub const RawTexture = struct { view: c.WGPUTextureView, tex: c.WGPUTexture, w: u32, h: u32, kind: i32 };

pub fn rawTexture(id: i64) ?RawTexture {
    const slot = texSlotOf(id) orelse return null;
    const s = &textures.items[slot];
    return .{ .view = s.view, .tex = s.tex, .w = s.w, .h = s.h, .kind = s.kind };
}

pub fn bumpCounter(idx: usize, v: f64) void {
    counters[idx] += v;
}

pub fn setMapFlags(done: bool, ok_: bool) void {
    g_map_done = done;
    g_map_ok = ok_;
}

pub fn mapDone() bool {
    return g_map_done;
}

pub fn mapOk() bool {
    return g_map_ok;
}

pub fn mapCallback() c.WGPUBufferMapCallbackInfo {
    return .{
        .nextInChain = null,
        .mode = c.WGPUCallbackMode_AllowProcessEvents,
        .callback = onMap,
        .userdata1 = null,
        .userdata2 = null,
    };
}

// ---------------- kernels

/// Compile WGSL to a pipeline, or return the cached one for identical text.
/// The kernel MUST follow the layer's binding contract:
///   @binding(0) = uniform StzTile { xoff: u32, ... } (owned by this layer)
///   @binding(1..) = the caller's storage buffers, in dispatch order.
pub fn stz_gpu_kernel_compile(text: [*]const u8, len: f64) callconv(.c) i64 {
    if (!available) {
        counters[CTR_FALLBACK_COUNT] += 1;
        return 0;
    }
    const n: usize = @intFromFloat(len);
    const wgsl = text[0..n];
    const h = std.hash.Wyhash.hash(0, wgsl);
    for (kernels.items, 0..) |k, i| {
        if (k.hash == h and k.len == n and k.pipeline != null) {
            counters[CTR_COMPILE_HITS] += 1;
            return @intCast(i + 1);
        }
    }
    const errs_before = counters[CTR_GPU_ERRORS];

    var src = std.mem.zeroes(c.WGPUShaderSourceWGSL);
    src.chain.sType = c.WGPUSType_ShaderSourceWGSL;
    src.code = sv(wgsl);
    var mdesc = std.mem.zeroes(c.WGPUShaderModuleDescriptor);
    mdesc.nextInChain = @ptrCast(&src.chain);
    mdesc.label = sv("stz_kernel");
    const module = fns.wgpuDeviceCreateShaderModule(device, &mdesc);
    if (module == null) return 0;
    defer fns.wgpuShaderModuleRelease(module);

    var pdesc = std.mem.zeroes(c.WGPUComputePipelineDescriptor);
    pdesc.label = sv("stz_kernel");
    pdesc.compute.module = module;
    pdesc.compute.entryPoint = sv("main");
    const pipeline = fns.wgpuDeviceCreateComputePipeline(device, &pdesc);
    if (pipeline == null) return 0;
    // A malformed WGSL surfaces as an uncaptured VALIDATION error while the
    // create call still returns a non-null (invalid) object. Flush events and
    // refuse to cache a pipeline whose compile errored.
    fns.wgpuInstanceProcessEvents(instance);
    _ = fns.wgpuDevicePoll(device, 0, null);
    if (counters[CTR_GPU_ERRORS] > errs_before) {
        fns.wgpuComputePipelineRelease(pipeline);
        return 0;
    }
    const layout = fns.wgpuComputePipelineGetBindGroupLayout(pipeline, 0);

    kernels.append(alloc, .{ .pipeline = pipeline, .layout = layout, .hash = h, .len = n }) catch {
        if (layout) |l| fns.wgpuBindGroupLayoutRelease(l);
        fns.wgpuComputePipelineRelease(pipeline);
        return 0;
    };
    counters[CTR_COMPILE_COUNT] += 1;
    return @intCast(kernels.items.len);
}

const MAX_BIND_BUFFERS = 8; // default WebGPU maxStorageBuffersPerShaderStage

/// Dispatch `kernel` over the given buffers (bound at 1..n in order), with
/// (wx, wy) workgroups. Asynchronous: returns after submit; chain dispatches
/// freely, then Sync() or a read establishes completion.
///
/// TDR tiling: if wx*wy exceeds the tile limit, the dispatch is split along x
/// into ceil-sized chunks; before each chunk the shared tile uniform gets the
/// chunk's x-offset IN WORKGROUPS (queue-ordered, so one buffer serves all).
pub fn stz_gpu_dispatch(kernel: i64, buf_ids: [*]const i64, nbufs: i32, wx: f64, wy: f64) callconv(.c) i32 {
    return dispatchInternal(kernel, null, buf_ids, nbufs, wx, wy);
}

// ---------------- batched passes
//
// G0 measured ~60 us per submit+wait against ~9 us for a dispatch INSIDE a
// pass: a chain of many small ops pays 7x more in submission than in work.
// Batch mode encodes every dispatch into ONE pass and submits once at End.
//
// The correctness catch, and why this needs its own uniform slots: the tile
// and params uniforms are written with queue.writeBuffer, which is ordered
// against SUBMITS, not against dispatches within a pass. Sharing one buffer
// across a batch would give every dispatch the LAST value written. So each
// batched dispatch takes its OWN small uniform pair from a pool; the pool
// and the bind groups stay alive until the submit completes.

const BATCH_MAX = 512;
var g_batching = false;
var g_batch_enc: c.WGPUCommandEncoder = null;
var g_batch_pass: c.WGPUComputePassEncoder = null;
var g_batch_n: usize = 0;
var g_batch_bgs: [BATCH_MAX]c.WGPUBindGroup = @splat(null);
var g_pool_tile: [BATCH_MAX]c.WGPUBuffer = @splat(null);
var g_pool_params: [BATCH_MAX]c.WGPUBuffer = @splat(null);

fn poolSlot(i: usize) bool {
    if (g_pool_tile[i] != null) return true;
    var td = std.mem.zeroes(c.WGPUBufferDescriptor);
    td.usage = c.WGPUBufferUsage_Uniform | c.WGPUBufferUsage_CopyDst;
    td.size = 16;
    g_pool_tile[i] = fns.wgpuDeviceCreateBuffer(device, &td);
    var pd = std.mem.zeroes(c.WGPUBufferDescriptor);
    pd.usage = c.WGPUBufferUsage_Uniform | c.WGPUBufferUsage_CopyDst;
    pd.size = PARAMS_BYTES;
    g_pool_params[i] = fns.wgpuDeviceCreateBuffer(device, &pd);
    return g_pool_tile[i] != null and g_pool_params[i] != null;
}

fn releasePool() void {
    for (0..BATCH_MAX) |i| {
        if (g_pool_tile[i]) |b| fns.wgpuBufferRelease(b);
        if (g_pool_params[i]) |b| fns.wgpuBufferRelease(b);
        g_pool_tile[i] = null;
        g_pool_params[i] = null;
    }
}

// ---------------------------------------------------------------- the frame
//
// GG4 gap 3. A batch already merges many DISPATCHES into one submit, but a
// frame that computes and then draws still paid two -- the compute path and
// the render path each opened their own encoder and submitted it. GR0's
// spike proved compute->render in ONE submit works; the product path never
// adopted it.
//
// A FRAME is one command encoder that both paths encode into. Compute
// passes and render passes take turns on it, and the whole thing is
// finished and submitted ONCE at the end. That is also exactly what a frame
// graph needs to execute a schedule.

var g_frame_enc: c.WGPUCommandEncoder = null;
var g_frame_open = false;
var frame_end_hooks: [4]?*const fn () void = @splat(null);

/// gpu_render registers here so its accumulated bind groups are released
/// AFTER the frame submits, not after each pass -- a bind group referenced
/// by an unsubmitted encoder must outlive the pass that made it.
pub fn registerFrameEndHook(f: *const fn () void) void {
    for (&frame_end_hooks) |*slot| {
        if (slot.* == null) {
            slot.* = f;
            return;
        }
    }
}

pub fn frameOpen() bool {
    return g_frame_open;
}

pub fn frameEncoder() c.WGPUCommandEncoder {
    return g_frame_enc;
}

/// Open a frame. Every dispatch and every render pass until FrameEnd
/// encodes into ONE encoder and costs ONE submit between them.
pub fn stz_gpu_frame_begin() callconv(.c) i32 {
    if (!available) {
        counters[CTR_FALLBACK_COUNT] += 1;
        return FALLBACK;
    }
    if (g_frame_open) return OK; // idempotent, like batch_begin
    g_frame_enc = fns.wgpuDeviceCreateCommandEncoder(device, null);
    if (g_frame_enc == null) return GPU_ERROR;
    g_frame_open = true;
    return OK;
}

/// Finish the frame: ONE submit for everything encoded since FrameBegin.
pub fn stz_gpu_frame_end() callconv(.c) i32 {
    if (!g_frame_open) return BAD_ARG;
    g_frame_open = false;
    const cmd = fns.wgpuCommandEncoderFinish(g_frame_enc, null);
    fns.wgpuCommandEncoderRelease(g_frame_enc);
    g_frame_enc = null;
    fns.wgpuQueueSubmit(queue, 1, &cmd);
    fns.wgpuCommandBufferRelease(cmd);
    counters[CTR_SUBMIT_COUNT] += 1;
    for (frame_end_hooks) |h| {
        if (h) |f| f();
    }
    return OK;
}

pub fn stz_gpu_frame_active() callconv(.c) i32 {
    return if (g_frame_open) 1 else 0;
}

/// Open a batch. Dispatches accumulate into one pass until End.
pub fn stz_gpu_batch_begin() callconv(.c) i32 {
    if (!available) {
        counters[CTR_FALLBACK_COUNT] += 1;
        return FALLBACK;
    }
    if (g_batching) return OK; // already open: idempotent
    g_batch_enc = fns.wgpuDeviceCreateCommandEncoder(device, null);
    if (g_batch_enc == null) return GPU_ERROR;
    g_batch_pass = fns.wgpuCommandEncoderBeginComputePass(g_batch_enc, null);
    if (g_batch_pass == null) return GPU_ERROR;
    g_batch_n = 0;
    g_batching = true;
    return OK;
}

/// Close the batch: end the pass, submit ONCE, release the slots.
pub fn stz_gpu_batch_end() callconv(.c) i32 {
    if (!g_batching) return BAD_ARG;
    g_batching = false;
    fns.wgpuComputePassEncoderEnd(g_batch_pass);
    fns.wgpuComputePassEncoderRelease(g_batch_pass);
    g_batch_pass = null;
    const cmd = fns.wgpuCommandEncoderFinish(g_batch_enc, null);
    fns.wgpuCommandEncoderRelease(g_batch_enc);
    g_batch_enc = null;
    fns.wgpuQueueSubmit(queue, 1, &cmd);
    fns.wgpuCommandBufferRelease(cmd);
    counters[CTR_SUBMIT_COUNT] += 1;
    // the pass is submitted; its bind groups may go
    for (0..g_batch_n) |i| {
        if (g_batch_bgs[i]) |bg| fns.wgpuBindGroupRelease(bg);
        g_batch_bgs[i] = null;
    }
    g_batch_n = 0;
    return OK;
}

pub fn stz_gpu_batch_active() callconv(.c) i32 {
    return if (g_batching) 1 else 0;
}

/// The ops-family variant: a params blob (<= PARAMS_BYTES) lands in the
/// shared params uniform, bound at @binding(1); user buffers start at
/// @binding(2). Same queue-ordering argument as the tile uniform: write
/// params, then submit -- one shared buffer serves every op in a chain.
pub fn stz_gpu_dispatch_params(kernel: i64, params: [*]const u8, params_len: f64, buf_ids: [*]const i64, nbufs: i32, wx: f64, wy: f64) callconv(.c) i32 {
    const n: usize = @intFromFloat(params_len);
    if (n == 0 or n > PARAMS_BYTES) return BAD_ARG;
    return dispatchInternal(kernel, params[0..n], buf_ids, nbufs, wx, wy);
}

fn dispatchInternal(kernel: i64, params: ?[]const u8, buf_ids: [*]const i64, nbufs: i32, wx: f64, wy: f64) i32 {
    if (!available) {
        counters[CTR_FALLBACK_COUNT] += 1;
        return FALLBACK;
    }
    if (kernel <= 0 or kernel > kernels.items.len) return BAD_ARG;
    if (nbufs < 1 or nbufs > MAX_BIND_BUFFERS) return BAD_ARG;
    if (wx < 1 or wy < 1) return BAD_ARG;
    const k = kernels.items[@intCast(kernel - 1)];

    var timer = std.time.Timer.start() catch unreachable;

    // In a batch, this dispatch gets its OWN uniform slots (see the note on
    // stz_gpu_batch_begin): queue writes are ordered against the submit, not
    // against dispatches inside the pass.
    const batched = g_batching and g_batch_n < BATCH_MAX;
    var tile_buf = tile_uniform;
    var params_buf = params_uniform;
    if (batched) {
        if (!poolSlot(g_batch_n)) return GPU_ERROR;
        tile_buf = g_pool_tile[g_batch_n];
        params_buf = g_pool_params[g_batch_n];
    }

    var entries: [MAX_BIND_BUFFERS + 2]c.WGPUBindGroupEntry = undefined;
    entries[0] = std.mem.zeroes(c.WGPUBindGroupEntry);
    entries[0].binding = 0;
    entries[0].buffer = tile_buf;
    entries[0].size = 16;
    var base: usize = 1;
    if (params) |p| {
        fns.wgpuQueueWriteBuffer(queue, params_buf, 0, p.ptr, p.len);
        entries[1] = std.mem.zeroes(c.WGPUBindGroupEntry);
        entries[1].binding = 1;
        entries[1].buffer = params_buf;
        entries[1].size = PARAMS_BYTES;
        base = 2;
    }
    const nb: usize = @intCast(nbufs);
    for (0..nb) |i| {
        const slot = slotOf(buf_ids[i]) orelse return STALE;
        entries[i + base] = std.mem.zeroes(c.WGPUBindGroupEntry);
        entries[i + base].binding = @intCast(i + base);
        entries[i + base].buffer = buffers.items[slot].buf;
        entries[i + base].size = buffers.items[slot].size;
    }
    var bgdesc = std.mem.zeroes(c.WGPUBindGroupDescriptor);
    bgdesc.layout = k.layout;
    bgdesc.entryCount = nb + base;
    bgdesc.entries = &entries;
    const bg = fns.wgpuDeviceCreateBindGroup(device, &bgdesc);
    if (bg == null) return GPU_ERROR;

    const total_x: u64 = @intFromFloat(wx);
    const y: u32 = @intFromFloat(wy);
    // bound the PER-SUBMIT workgroup count: chunk_x * y <= tile_limit
    const allowed_x: u64 = @max(1, tile_limit / @max(y, 1));

    // BATCHED: one dispatch encoded into the open pass, no submit here.
    // A dispatch needing MORE than one tile can't batch (its tiles want
    // different xoff values from one uniform slot), so it falls through to
    // the immediate path -- correct either way, just not amortized.
    if (batched and total_x <= allowed_x) {
        const tile = [4]u32{ 0, 0, 0, 0 };
        fns.wgpuQueueWriteBuffer(queue, tile_buf, 0, &tile, 16);
        fns.wgpuComputePassEncoderSetPipeline(g_batch_pass, k.pipeline);
        fns.wgpuComputePassEncoderSetBindGroup(g_batch_pass, 0, bg, 0, null);
        fns.wgpuComputePassEncoderDispatchWorkgroups(g_batch_pass, @intCast(total_x), y, 1);
        g_batch_bgs[g_batch_n] = bg; // released after the batch submits
        g_batch_n += 1;
        counters[CTR_DISPATCH_COUNT] += 1;
        counters[CTR_DISPATCH_MS] += @as(f64, @floatFromInt(timer.read())) / 1e6;
        return OK;
    }
    defer fns.wgpuBindGroupRelease(bg);

    var off: u64 = 0;
    while (off < total_x) {
        const chunk: u32 = @intCast(@min(allowed_x, total_x - off));
        const tile = [4]u32{ @intCast(off), 0, 0, 0 };
        fns.wgpuQueueWriteBuffer(queue, tile_uniform, 0, &tile, 16);

        // Inside a FRAME, encode onto the frame's encoder and submit
        // nothing -- FrameEnd owns the one submit. Outside one, behave
        // exactly as before: own encoder, own submit.
        const enc = if (g_frame_open) g_frame_enc else fns.wgpuDeviceCreateCommandEncoder(device, null);
        const pass = fns.wgpuCommandEncoderBeginComputePass(enc, null);
        fns.wgpuComputePassEncoderSetPipeline(pass, k.pipeline);
        fns.wgpuComputePassEncoderSetBindGroup(pass, 0, bg, 0, null);
        fns.wgpuComputePassEncoderDispatchWorkgroups(pass, chunk, y, 1);
        fns.wgpuComputePassEncoderEnd(pass);
        fns.wgpuComputePassEncoderRelease(pass);
        if (!g_frame_open) {
            const cmd = fns.wgpuCommandEncoderFinish(enc, null);
            fns.wgpuCommandEncoderRelease(enc);
            fns.wgpuQueueSubmit(queue, 1, &cmd);
            fns.wgpuCommandBufferRelease(cmd);
            counters[CTR_SUBMIT_COUNT] += 1;
        }
        off += chunk;
    }

    counters[CTR_DISPATCH_COUNT] += 1;
    counters[CTR_DISPATCH_MS] += @as(f64, @floatFromInt(timer.read())) / 1e6;
    return OK;
}

/// Block until all submitted work completes.
pub fn stz_gpu_sync() callconv(.c) i32 {
    if (!available) {
        counters[CTR_FALLBACK_COUNT] += 1;
        return FALLBACK;
    }
    while (fns.wgpuDevicePoll(device, 1, null) == 0) {}
    return OK;
}

// ---------------- calibration

pub fn stz_gpu_calib_set(name: [*]const u8, name_len: f64, threshold: f64) callconv(.c) void {
    const n: usize = @intFromFloat(name_len);
    const h = std.hash.Wyhash.hash(0, name[0..n]);
    for (calib.items) |*e| {
        if (e.hash == h) {
            e.threshold = threshold;
            return;
        }
    }
    calib.append(alloc, .{ .hash = h, .threshold = threshold }) catch {};
}

pub fn stz_gpu_calib_get(name: [*]const u8, name_len: f64) callconv(.c) f64 {
    const n: usize = @intFromFloat(name_len);
    const h = std.hash.Wyhash.hash(0, name[0..n]);
    for (calib.items) |e| {
        if (e.hash == h) return e.threshold;
    }
    return 0; // no calibration recorded
}

/// The routing gate. CPU (0) whenever: GPU absent, op uncalibrated, or the
/// problem is below its crossover. GPU (1) only above a measured line.
pub fn stz_gpu_should_dispatch(name: [*]const u8, name_len: f64, problem_n: f64) callconv(.c) i32 {
    if (!available) return 0;
    const t = stz_gpu_calib_get(name, name_len);
    if (t <= 0) return 0;
    return if (problem_n >= t) 1 else 0;
}

test {
    // exercised end-to-end by the Ring guard (base/test/gpu/); unit surface
    // here is just the id arithmetic
    const id = makeId(5, 3);
    try std.testing.expectEqual(@as(i64, (3 << 32) | 6), id);
}
