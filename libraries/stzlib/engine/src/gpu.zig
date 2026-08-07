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
const c = @cImport({
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
const N_COUNTERS = 10;

var counters: [N_COUNTERS]f64 = @splat(0);

// ---------------------------------------------------------------- wgpu, loaded at runtime
// Only the functions the lifecycle needs. Field name == exported symbol name;
// loadWgpu resolves every field or fails as a unit (no half-loaded state).
const Fns = struct {
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

/// FIFO among live buffers: evict the oldest until `need` fits the budget.
/// Returns false if even an empty cache cannot fit it.
fn evictUntilFits(need: usize) bool {
    if (need > vram_budget) return false;
    while (vram_in_use + need > vram_budget) {
        var oldest: ?usize = null;
        var oldest_birth: u64 = std.math.maxInt(u64);
        for (buffers.items, 0..) |s, i| {
            if (s.live and s.birth < oldest_birth) {
                oldest_birth = s.birth;
                oldest = i;
            }
        }
        const victim = oldest orelse return false;
        destroySlot(victim);
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

    selected_adapter = @intCast(idx);
    available = true;
    return 1;
}

/// Tear down device-scoped state (buffers, kernels, tile uniform, device).
/// Keeps the instance + adapter list so SelectAdapter/Init can rebuild.
fn closeDevice() void {
    if (!available and device == null) return;
    available = false;
    for (buffers.items, 0..) |s, i| {
        if (s.live) destroySlot(i);
    }
    for (kernels.items) |*k| {
        if (k.layout) |l| fns.wgpuBindGroupLayoutRelease(l);
        if (k.pipeline) |p| fns.wgpuComputePipelineRelease(p);
        k.pipeline = null;
        k.layout = null;
    }
    kernels.clearRetainingCapacity();
    if (tile_uniform) |t| fns.wgpuBufferRelease(t);
    tile_uniform = null;
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

pub fn stz_gpu_counters_reset() callconv(.c) void {
    // Structural gauges survive a reset -- they describe state, not history.
    const live = counters[CTR_BUFFER_LIVE];
    counters = @splat(0);
    counters[CTR_BUFFER_LIVE] = live;
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
    desc.usage = c.WGPUBufferUsage_Storage | c.WGPUBufferUsage_CopyDst | c.WGPUBufferUsage_CopySrc;
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
    if (!available) {
        counters[CTR_FALLBACK_COUNT] += 1;
        return FALLBACK;
    }
    if (kernel <= 0 or kernel > kernels.items.len) return BAD_ARG;
    if (nbufs < 1 or nbufs > MAX_BIND_BUFFERS) return BAD_ARG;
    if (wx < 1 or wy < 1) return BAD_ARG;
    const k = kernels.items[@intCast(kernel - 1)];

    var timer = std.time.Timer.start() catch unreachable;

    var entries: [MAX_BIND_BUFFERS + 1]c.WGPUBindGroupEntry = undefined;
    entries[0] = std.mem.zeroes(c.WGPUBindGroupEntry);
    entries[0].binding = 0;
    entries[0].buffer = tile_uniform;
    entries[0].size = 16;
    const nb: usize = @intCast(nbufs);
    for (0..nb) |i| {
        const slot = slotOf(buf_ids[i]) orelse return STALE;
        entries[i + 1] = std.mem.zeroes(c.WGPUBindGroupEntry);
        entries[i + 1].binding = @intCast(i + 1);
        entries[i + 1].buffer = buffers.items[slot].buf;
        entries[i + 1].size = buffers.items[slot].size;
    }
    var bgdesc = std.mem.zeroes(c.WGPUBindGroupDescriptor);
    bgdesc.layout = k.layout;
    bgdesc.entryCount = nb + 1;
    bgdesc.entries = &entries;
    const bg = fns.wgpuDeviceCreateBindGroup(device, &bgdesc);
    if (bg == null) return GPU_ERROR;
    defer fns.wgpuBindGroupRelease(bg);

    const total_x: u64 = @intFromFloat(wx);
    const y: u32 = @intFromFloat(wy);
    // bound the PER-SUBMIT workgroup count: chunk_x * y <= tile_limit
    const allowed_x: u64 = @max(1, tile_limit / @max(y, 1));

    var off: u64 = 0;
    while (off < total_x) {
        const chunk: u32 = @intCast(@min(allowed_x, total_x - off));
        const tile = [4]u32{ @intCast(off), 0, 0, 0 };
        fns.wgpuQueueWriteBuffer(queue, tile_uniform, 0, &tile, 16);

        const enc = fns.wgpuDeviceCreateCommandEncoder(device, null);
        const pass = fns.wgpuCommandEncoderBeginComputePass(enc, null);
        fns.wgpuComputePassEncoderSetPipeline(pass, k.pipeline);
        fns.wgpuComputePassEncoderSetBindGroup(pass, 0, bg, 0, null);
        fns.wgpuComputePassEncoderDispatchWorkgroups(pass, chunk, y, 1);
        fns.wgpuComputePassEncoderEnd(pass);
        fns.wgpuComputePassEncoderRelease(pass);
        const cmd = fns.wgpuCommandEncoderFinish(enc, null);
        fns.wgpuCommandEncoderRelease(enc);
        fns.wgpuQueueSubmit(queue, 1, &cmd);
        fns.wgpuCommandBufferRelease(cmd);
        counters[CTR_SUBMIT_COUNT] += 1;
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
