//! gpu_verify.zig -- GK0: THE CHECKER as an engine primitive
//! (SOFTANZA_GPU_PLAN.md, section GK).
//!
//! Proteus's lesson, applied: the proposer never times its own work, and a
//! number that beats the bus is a measurement defect, not a win. So:
//!
//!   - a candidate kernel is checked against a REFERENCE on the same device
//!     buffers with the same inputs, at a VISIBLE shape and at a HIDDEN one
//!     (different size, different data -- the checker's, never the caller's);
//!   - both are timed THE SAME WAY, here, by the engine: warm on both sides
//!     (the compile cache is a feature and a confound -- never one warm and
//!     one cold), alternating A B A B so drift lands on both arms, warm-min;
//!   - TWO clocks where the adapter has them: the wall clock around
//!     dispatch+sync, and GPU timestamp queries inside the pass. One clock is
//!     a recorded limit, never a failure;
//!   - a ROOFLINE measured on this device (bytes/s of a copy kernel, and the
//!     cost of the smallest dispatch) refuses BY NAME any time that could not
//!     have happened -- on the candidate AND on the reference.
//!
//! The verdict is DATA in result slots; Ring only reads them.

const std = @import("std");
const gpu = @import("gpu.zig");
const c = gpu.c;

pub const V_VERIFIED: i32 = 0;
pub const V_MISMATCH: i32 = 1; // wrong at the visible shape
pub const V_MISMATCH_HIDDEN: i32 = 2; // right where it was shown, wrong where it was not
pub const V_IMPOSSIBLE: i32 = 3; // the candidate's time beats the measured floor
pub const V_REF_IMPOSSIBLE: i32 = 4; // the REFERENCE beats the floor: the measurement is broken
pub const V_ERROR: i32 = 5;

// result slots -- read back with stz_gpu_verify_result(i)
pub const R_VERDICT = 0;
pub const R_MAXABS_A = 1;
pub const R_MAXABS_B = 2;
pub const R_FIRST_BAD = 3; // 0-based index of the first out-of-band element, -1 = none
pub const R_REF_MS = 4; // warm-min wall, dispatch+sync
pub const R_CAND_MS = 5;
pub const R_REF_GPU_MS = 6; // GPU timestamps; -1 = no second clock
pub const R_CAND_GPU_MS = 7;
pub const R_SPEEDUP = 8; // ref / cand, wall
pub const R_SPEEDUP_GPU = 9;
pub const R_FLOOR_GBS = 10; // measured copy bandwidth, GB/s
pub const R_SUBMIT_FLOOR_MS = 11; // measured smallest dispatch+sync
pub const R_BYTES = 12; // bytes the candidate's bound buffers hold
pub const R_MIN_MS = 13; // the floor for THIS candidate
pub const R_CLOCKS = 14; // 1 or 2
pub const R_REPS = 15;
pub const R_JITTER_MS = 16; // max - min of the reference's reps
pub const RESULT_SLOTS = 24;

var result: [RESULT_SLOTS]f64 = @splat(0);

pub fn stz_gpu_verify_result(idx: i32) callconv(.c) f64 {
    if (idx < 0 or idx >= RESULT_SLOTS) return 0;
    return result[@intCast(idx)];
}

// ---------------------------------------------------------------- the floors
// Measured ONCE per device (reset when it closes), never quoted from a plan.
var floor_bps: f64 = 0; // bytes per second, copy kernel, warm-min
var submit_floor_ms: f64 = 0; // the smallest dispatch + sync, warm-min
var floors_ready = false;
var hooked = false;

const COPY_N: usize = 4 * 1024 * 1024; // 16 MB in + 16 MB out per copy

const SUBMIT_WGSL =
    \\struct StzTile { xoff: u32, p0: u32, p1: u32, p2: u32 };
    \\@group(0) @binding(0) var<uniform> tile : StzTile;
    \\@group(0) @binding(1) var<storage, read_write> o : array<f32>;
    \\@compute @workgroup_size(1)
    \\fn main() { o[0] = o[0] + f32(tile.xoff); }
;

const COPY_WGSL =
    \\struct StzTile { xoff: u32, p0: u32, p1: u32, p2: u32 };
    \\@group(0) @binding(0) var<uniform> tile : StzTile;
    \\@group(0) @binding(1) var<storage, read> a : array<f32>;
    \\@group(0) @binding(2) var<storage, read_write> o : array<f32>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
    \\  let i = gid.x + tile.xoff * 256u;
    \\  if (i < 4194304u) { o[i] = a[i]; }
    \\}
;

fn onDeviceClose() void {
    floors_ready = false;
    floor_bps = 0;
    submit_floor_ms = 0;
    releaseTs();
}

fn ensureHook() void {
    if (hooked) return;
    gpu.registerDeviceCloseHook(&onDeviceClose);
    hooked = true;
}

/// warm-min wall ms of `reps` plain dispatches (no params) of `kernel`.
fn minPlainDispatchMs(kernel: i64, ids: []const i64, wx: f64, reps: usize) ?f64 {
    var best: f64 = std.math.inf(f64);
    var r: usize = 0;
    while (r < reps) : (r += 1) {
        var timer = std.time.Timer.start() catch return null;
        if (gpu.stz_gpu_dispatch(kernel, ids.ptr, @intCast(ids.len), wx, 1) != gpu.OK) return null;
        if (gpu.stz_gpu_sync() != gpu.OK) return null;
        const ms = @as(f64, @floatFromInt(timer.read())) / 1e6;
        if (ms < best) best = ms;
    }
    return best;
}

/// WAKE the device: bandwidth-bound copies for `budget_ms` of wall time.
/// Measured 2026-09-09 (GK1) on the RTX 3050 laptop GPU: after ~10 s idle the
/// device drops into a power state where EVERY submit pays a fixed ~2 ms and
/// the copy floor reads 13 GB/s instead of 85 -- and 330 tiny queries do not
/// lift it, while ~150 ms of heavy work does. A measurement taken in that
/// state is a measurement of the state, not of the kernel. Returns the
/// number of copies dispatched (0 = no device).
pub fn stz_gpu_wake(budget_ms: f64) callconv(.c) i32 {
    if (!gpu.isAvail()) return 0;
    const kc = gpu.stz_gpu_kernel_compile(COPY_WGSL.ptr, @floatFromInt(COPY_WGSL.len));
    if (kc == 0) return 0;
    const nbytes: f64 = @floatFromInt(COPY_N * 4);
    const src = gpu.stz_gpu_buffer_new(nbytes);
    if (src == 0) return 0;
    defer _ = gpu.stz_gpu_buffer_free(src);
    const dst = gpu.stz_gpu_buffer_new(nbytes);
    if (dst == 0) return 0;
    defer _ = gpu.stz_gpu_buffer_free(dst);
    const ids = [_]i64{ src, dst };
    const wx: f64 = @floatFromInt(COPY_N / 256);
    // ADAPTIVE: copy until a copy runs at full speed -- an asleep 3050 takes
    // ~9 ms per 32 MB copy, awake ~0.4 ms; the flip happens mid-burst after
    // ~250 ms of sustained work -- then settle for a few more, and stop.
    // The budget is a CAP, not a duration: an awake device is recognised on
    // its first copies and the burst costs milliseconds.
    const awake_ns: u64 = 2_000_000; // 32 MB in under 2 ms = 16 GB/s = awake
    const settle: i32 = 20;
    var timer = std.time.Timer.start() catch return 0;
    var count: i32 = 0;
    var settled: i32 = 0;
    const budget_ns: u64 = @intFromFloat(@max(budget_ms, 1) * 1e6);
    while (timer.read() < budget_ns and count < 100000) : (count += 1) {
        var one = std.time.Timer.start() catch return count;
        if (gpu.stz_gpu_dispatch(kc, &ids, 2, wx, 1) != gpu.OK) return count;
        if (gpu.stz_gpu_sync() != gpu.OK) return count;
        if (one.read() < awake_ns) {
            settled += 1;
            if (settled >= settle) {
                count += 1;
                break;
            }
        } else {
            settled = 0;
        }
    }
    return count;
}

fn ensureFloors() bool {
    if (floors_ready) return true;
    if (!gpu.isAvail()) return false;
    ensureHook();
    // the floors are AWAKE numbers by construction (see stz_gpu_wake; the
    // 400 ms is a cap -- the burst stops once copies run at full speed)
    _ = stz_gpu_wake(400);

    // 1. the submit floor: the smallest possible dispatch, warm
    const ks = gpu.stz_gpu_kernel_compile(SUBMIT_WGSL.ptr, @floatFromInt(SUBMIT_WGSL.len));
    if (ks == 0) return false;
    const tiny = gpu.stz_gpu_buffer_new(256);
    if (tiny == 0) return false;
    defer _ = gpu.stz_gpu_buffer_free(tiny);
    const ids1 = [_]i64{tiny};
    _ = minPlainDispatchMs(ks, &ids1, 1, 1); // warm
    submit_floor_ms = minPlainDispatchMs(ks, &ids1, 1, 7) orelse return false;

    // 2. the bandwidth floor: a straight copy of 16 MB, warm-min
    const kc = gpu.stz_gpu_kernel_compile(COPY_WGSL.ptr, @floatFromInt(COPY_WGSL.len));
    if (kc == 0) return false;
    const nbytes: f64 = @floatFromInt(COPY_N * 4);
    const src = gpu.stz_gpu_buffer_new(nbytes);
    if (src == 0) return false;
    defer _ = gpu.stz_gpu_buffer_free(src);
    const dst = gpu.stz_gpu_buffer_new(nbytes);
    if (dst == 0) return false;
    defer _ = gpu.stz_gpu_buffer_free(dst);
    const ids2 = [_]i64{ src, dst };
    const wx: f64 = @floatFromInt(COPY_N / 256);
    _ = minPlainDispatchMs(kc, &ids2, wx, 1); // warm
    const copy_ms = minPlainDispatchMs(kc, &ids2, wx, 5) orelse return false;
    if (copy_ms <= 0) return false;
    floor_bps = (2.0 * nbytes) / (copy_ms / 1000.0);

    floors_ready = true;
    return true;
}

/// The floor for a dispatch touching `bytes`: it cannot beat the smallest
/// dispatch we measured, and it cannot move bytes faster than the measured
/// copy bandwidth -- with an 8x allowance, because a working set that fits
/// in cache legitimately beats DRAM, and a floor that refuses a legitimate
/// result is worse than one that lets a marginal one through. Pure.
pub fn minPossibleMs(bytes: f64, bps: f64, submit_ms: f64) f64 {
    const by_bus = if (bps > 0) (bytes / (bps * 8.0)) * 1000.0 else 0;
    const by_submit = submit_ms * 0.5;
    return @max(by_bus, by_submit);
}

pub fn judgeWith(bytes: f64, ms: f64, bps: f64, submit_ms: f64) i32 {
    return if (ms < minPossibleMs(bytes, bps, submit_ms)) V_IMPOSSIBLE else V_VERIFIED;
}

/// Is a dispatch over `bytes` in `ms` physically possible on this device?
/// Measures the floors if they are not yet; exposed so a guard can hand it
/// an impossible number and watch it refuse.
pub fn stz_gpu_verify_judge(bytes: f64, ms: f64) callconv(.c) i32 {
    if (!ensureFloors()) return V_ERROR;
    result[R_FLOOR_GBS] = floor_bps / 1e9;
    result[R_SUBMIT_FLOOR_MS] = submit_floor_ms;
    result[R_BYTES] = bytes;
    result[R_MIN_MS] = minPossibleMs(bytes, floor_bps, submit_floor_ms);
    return judgeWith(bytes, ms, floor_bps, submit_floor_ms);
}

// ---------------------------------------------------------------- the second clock
var qset: c.WGPUQuerySet = null;
var qresolve: c.WGPUBuffer = null;
var qstaging: c.WGPUBuffer = null;
var ts_writes: c.WGPUPassTimestampWrites = undefined;

fn sv(s: []const u8) c.WGPUStringView {
    return .{ .data = s.ptr, .length = s.len };
}

fn releaseTs() void {
    const f = gpu.wfns();
    if (qstaging != null) f.wgpuBufferRelease(qstaging);
    if (qresolve != null) f.wgpuBufferRelease(qresolve);
    if (qset != null) f.wgpuQuerySetRelease(qset);
    qstaging = null;
    qresolve = null;
    qset = null;
}

fn ensureTs() bool {
    if (!gpu.hasTimestamps()) return false;
    if (qset != null) return true;
    const f = gpu.wfns();
    const dev = gpu.deviceHandle();
    var qd = std.mem.zeroes(c.WGPUQuerySetDescriptor);
    qd.label = sv("stz_verify_ts");
    qd.type = c.WGPUQueryType_Timestamp;
    qd.count = 2;
    qset = f.wgpuDeviceCreateQuerySet(dev, &qd);
    if (qset == null) return false;
    var rd = std.mem.zeroes(c.WGPUBufferDescriptor);
    rd.label = sv("stz_verify_resolve");
    rd.usage = c.WGPUBufferUsage_QueryResolve | c.WGPUBufferUsage_CopySrc;
    rd.size = 256;
    qresolve = f.wgpuDeviceCreateBuffer(dev, &rd);
    var sd = std.mem.zeroes(c.WGPUBufferDescriptor);
    sd.label = sv("stz_verify_staging");
    sd.usage = c.WGPUBufferUsage_MapRead | c.WGPUBufferUsage_CopyDst;
    sd.size = 16;
    qstaging = f.wgpuDeviceCreateBuffer(dev, &sd);
    if (qresolve == null or qstaging == null) {
        releaseTs();
        return false;
    }
    ts_writes = std.mem.zeroes(c.WGPUPassTimestampWrites);
    ts_writes.querySet = qset;
    ts_writes.beginningOfPassWriteIndex = 0;
    ts_writes.endOfPassWriteIndex = 1;
    return true;
}

/// Resolve the two timestamps of the last armed pass: ms, or -1.
fn readTimestampsMs() f64 {
    const f = gpu.wfns();
    const dev = gpu.deviceHandle();
    const enc = f.wgpuDeviceCreateCommandEncoder(dev, null);
    f.wgpuCommandEncoderResolveQuerySet(enc, qset, 0, 2, qresolve, 0);
    f.wgpuCommandEncoderCopyBufferToBuffer(enc, qresolve, 0, qstaging, 0, 16);
    const cmd = f.wgpuCommandEncoderFinish(enc, null);
    f.wgpuCommandEncoderRelease(enc);
    f.wgpuQueueSubmit(gpu.queueHandle(), 1, &cmd);
    f.wgpuCommandBufferRelease(cmd);

    gpu.setMapFlags(false, false);
    _ = f.wgpuBufferMapAsync(qstaging, c.WGPUMapMode_Read, 0, 16, gpu.mapCallback());
    while (!gpu.mapDone()) {
        _ = f.wgpuDevicePoll(dev, 1, null);
        f.wgpuInstanceProcessEvents(gpu.instanceHandle());
    }
    if (!gpu.mapOk()) return -1;
    const p = f.wgpuBufferGetConstMappedRange(qstaging, 0, 16) orelse return -1;
    const words: [*]const u64 = @ptrCast(@alignCast(p));
    const t0 = words[0];
    const t1 = words[1];
    f.wgpuBufferUnmap(qstaging);
    if (t1 < t0) return -1;
    const period: f64 = @floatCast(f.wgpuQueueGetTimestampPeriod(gpu.queueHandle()));
    return @as(f64, @floatFromInt(t1 - t0)) * period / 1e6;
}

// ---------------------------------------------------------------- one timed dispatch
/// Dispatch with params, sync, and time it on both clocks. Returns wall ms.
fn timedDispatch(kernel: i64, params: []const u8, ids: []const i64, wx: f64, two_clocks: bool, gpu_ms: *f64) ?f64 {
    var timer = std.time.Timer.start() catch return null;
    if (two_clocks) gpu.g_pass_ts = &ts_writes;
    const st = gpu.stz_gpu_dispatch_params(kernel, params.ptr, @floatFromInt(params.len), ids.ptr, @intCast(ids.len), wx, 1);
    gpu.g_pass_ts = null;
    if (st != gpu.OK) return null;
    if (gpu.stz_gpu_sync() != gpu.OK) return null;
    const wall = @as(f64, @floatFromInt(timer.read())) / 1e6;
    gpu_ms.* = if (two_clocks) readTimestampsMs() else -1;
    return wall;
}

/// Read `n` f32 from a device buffer into `out`.
fn readF32(id: i64, out: []f32) bool {
    const bytes: [*]u8 = @ptrCast(out.ptr);
    return gpu.stz_gpu_buffer_read(id, bytes, @floatFromInt(out.len * 4)) == gpu.OK;
}

const Compare = struct { maxabs: f64, first_bad: i64 };

fn compare(a: []const f32, b: []const f32, band: f64) Compare {
    var maxabs: f64 = 0;
    var first_bad: i64 = -1;
    for (a, b, 0..) |x, y, i| {
        const d: f64 = @abs(@as(f64, x) - @as(f64, y));
        // NaN fails the band by construction: !(d <= band)
        if (!(d <= band) and first_bad < 0) first_bad = @intCast(i);
        if (d > maxabs or d != d) maxabs = if (d != d) std.math.inf(f64) else d;
    }
    return .{ .maxabs = maxabs, .first_bad = first_bad };
}

/// Run ref and cand at one shape and compare their outputs. ids_ref's last
/// buffer is the reference output; the candidate writes `cand_out` instead.
fn checkShape(kref: i64, kcand: i64, params: []const u8, ids_ref: []const i64, cand_out: i64, n: usize, wx_ref: f64, wx_cand: f64, band: f64, slot_maxabs: usize) ?Compare {
    var ids_cand: [8]i64 = undefined;
    for (ids_ref, 0..) |id, i| ids_cand[i] = id;
    ids_cand[ids_ref.len - 1] = cand_out;
    var dummy: f64 = 0;
    _ = timedDispatch(kref, params, ids_ref, wx_ref, false, &dummy) orelse return null;
    _ = timedDispatch(kcand, params, ids_cand[0..ids_ref.len], wx_cand, false, &dummy) orelse return null;

    const alloc = std.heap.c_allocator;
    const ra = alloc.alloc(f32, n) catch return null;
    defer alloc.free(ra);
    const ca = alloc.alloc(f32, n) catch return null;
    defer alloc.free(ca);
    if (!readF32(ids_ref[ids_ref.len - 1], ra)) return null;
    if (!readF32(cand_out, ca)) return null;
    const cmp = compare(ra, ca, band);
    result[slot_maxabs] = cmp.maxabs;
    return cmp;
}

// ---------------------------------------------------------------- the primitive
/// Verify `kcand` against `kref`.
///   shape A (visible): params_a over ids_a (last = ref output, n_a f32 compared)
///   shape B (hidden):  params_b over ids_b (last = ref output, n_b f32 compared)
/// Both kernels are dispatched with (wx, 1) workgroups -- their own counts.
/// `reps` timed alternations at shape A; `band` = allowed |ref - cand|.
/// Returns a status (OK / BAD_ARG / FALLBACK / GPU_ERROR); the verdict and
/// every measurement land in the result slots.
pub fn stz_gpu_verify(
    kref: i64,
    kcand: i64,
    params_a: [*]const u8,
    len_a: f64,
    ids_a: [*]const i64,
    nids_a: i32,
    n_a: f64,
    wx_ref_a: f64,
    wx_cand_a: f64,
    params_b: [*]const u8,
    len_b: f64,
    ids_b: [*]const i64,
    nids_b: i32,
    n_b: f64,
    wx_ref_b: f64,
    wx_cand_b: f64,
    reps: f64,
    band: f64,
) callconv(.c) i32 {
    result = @splat(0);
    result[R_VERDICT] = V_ERROR;
    result[R_FIRST_BAD] = -1;
    result[R_REF_GPU_MS] = -1;
    result[R_CAND_GPU_MS] = -1;
    if (!gpu.isAvail()) {
        gpu.countFallback();
        return gpu.FALLBACK;
    }
    if (kref <= 0 or kcand <= 0) return gpu.BAD_ARG;
    if (nids_a < 1 or nids_a > 8 or nids_b < 1 or nids_b > 8) return gpu.BAD_ARG;
    const la: usize = @intFromFloat(len_a);
    const lb: usize = @intFromFloat(len_b);
    if (la == 0 or la > gpu.PARAMS_BYTES or lb == 0 or lb > gpu.PARAMS_BYTES) return gpu.BAD_ARG;
    const na: usize = @intFromFloat(n_a);
    const nb: usize = @intFromFloat(n_b);
    if (na == 0 or nb == 0) return gpu.BAD_ARG;
    const nreps: usize = @intFromFloat(@max(reps, 3));
    if (!ensureFloors()) return gpu.GPU_ERROR;

    const pa = params_a[0..la];
    const pb = params_b[0..lb];
    const ia = ids_a[0..@intCast(nids_a)];
    const ib = ids_b[0..@intCast(nids_b)];

    // the candidate gets its OWN outputs -- a candidate must never be
    // compared against a buffer it could have written to
    const out_a = gpu.stz_gpu_buffer_new(@floatFromInt(gpu.rawBufferSize(ia[ia.len - 1])));
    if (out_a == 0) return gpu.GPU_ERROR;
    defer _ = gpu.stz_gpu_buffer_free(out_a);
    const out_b = gpu.stz_gpu_buffer_new(@floatFromInt(gpu.rawBufferSize(ib[ib.len - 1])));
    if (out_b == 0) return gpu.GPU_ERROR;
    defer _ = gpu.stz_gpu_buffer_free(out_b);

    result[R_FLOOR_GBS] = floor_bps / 1e9;
    result[R_SUBMIT_FLOOR_MS] = submit_floor_ms;
    result[R_REPS] = @floatFromInt(nreps);

    // 1. correctness, visible shape (this also WARMS both kernels: compiled
    //    and dispatched once each, so the timing below is warm on both sides)
    const ca = checkShape(kref, kcand, pa, ia, out_a, na, wx_ref_a, wx_cand_a, band, R_MAXABS_A) orelse return gpu.GPU_ERROR;
    if (ca.first_bad >= 0) {
        result[R_VERDICT] = V_MISMATCH;
        result[R_FIRST_BAD] = @floatFromInt(ca.first_bad);
        return gpu.OK;
    }
    // 2. correctness, HIDDEN shape -- different size, different data
    const cb = checkShape(kref, kcand, pb, ib, out_b, nb, wx_ref_b, wx_cand_b, band, R_MAXABS_B) orelse return gpu.GPU_ERROR;
    if (cb.first_bad >= 0) {
        result[R_VERDICT] = V_MISMATCH_HIDDEN;
        result[R_FIRST_BAD] = @floatFromInt(cb.first_bad);
        return gpu.OK;
    }

    // 3. timing at the visible shape: alternate, warm-min, two clocks if we have them
    const two = ensureTs();
    var ids_cand: [8]i64 = undefined;
    for (ia, 0..) |id, i| ids_cand[i] = id;
    ids_cand[ia.len - 1] = out_a;
    var ref_min: f64 = std.math.inf(f64);
    var ref_max: f64 = 0;
    var cand_min: f64 = std.math.inf(f64);
    var ref_gpu_min: f64 = std.math.inf(f64);
    var cand_gpu_min: f64 = std.math.inf(f64);
    var r: usize = 0;
    while (r < nreps) : (r += 1) {
        var g: f64 = -1;
        const tr = timedDispatch(kref, pa, ia, wx_ref_a, two, &g) orelse return gpu.GPU_ERROR;
        if (tr < ref_min) ref_min = tr;
        if (tr > ref_max) ref_max = tr;
        if (g >= 0 and g < ref_gpu_min) ref_gpu_min = g;
        var g2: f64 = -1;
        const tc = timedDispatch(kcand, pa, ids_cand[0..ia.len], wx_cand_a, two, &g2) orelse return gpu.GPU_ERROR;
        if (tc < cand_min) cand_min = tc;
        if (g2 >= 0 and g2 < cand_gpu_min) cand_gpu_min = g2;
    }
    result[R_REF_MS] = ref_min;
    result[R_CAND_MS] = cand_min;
    result[R_JITTER_MS] = ref_max - ref_min;
    result[R_SPEEDUP] = if (cand_min > 0) ref_min / cand_min else 0;
    const have_gpu = two and ref_gpu_min < std.math.inf(f64) and cand_gpu_min < std.math.inf(f64);
    result[R_CLOCKS] = if (have_gpu) 2 else 1;
    if (have_gpu) {
        result[R_REF_GPU_MS] = ref_gpu_min;
        result[R_CAND_GPU_MS] = cand_gpu_min;
        result[R_SPEEDUP_GPU] = if (cand_gpu_min > 0) ref_gpu_min / cand_gpu_min else 0;
    }

    // 4. the roofline: bytes the candidate's bound buffers hold
    var bytes: f64 = 0;
    for (ids_cand[0..ia.len]) |id| bytes += @floatFromInt(gpu.rawBufferSize(id));
    result[R_BYTES] = bytes;
    const min_ms = minPossibleMs(bytes, floor_bps, submit_floor_ms);
    result[R_MIN_MS] = min_ms;
    if (ref_min < min_ms) {
        result[R_VERDICT] = V_REF_IMPOSSIBLE;
        return gpu.OK;
    }
    if (cand_min < min_ms) {
        result[R_VERDICT] = V_IMPOSSIBLE;
        return gpu.OK;
    }
    result[R_VERDICT] = V_VERIFIED;
    return gpu.OK;
}

test "the roofline judge is pure and refuses by the floor it is given" {
    // floors: 100 GB/s, 0.06 ms per submit
    const bps: f64 = 100e9;
    const sub: f64 = 0.06;
    // 1 GB in 0.01 ms is 100 TB/s: impossible even with the 8x cache allowance
    try std.testing.expectEqual(V_IMPOSSIBLE, judgeWith(1e9, 0.01, bps, sub));
    // 32 KB in 1 ms is fine
    try std.testing.expectEqual(V_VERIFIED, judgeWith(32768, 1.0, bps, sub));
    // nothing beats half the submit floor, however few the bytes
    try std.testing.expectEqual(V_IMPOSSIBLE, judgeWith(16, 0.001, bps, sub));
    // the floor for 1 GB at 100 GB/s with 8x allowance is 1.25 ms
    try std.testing.expectApproxEqAbs(@as(f64, 1.25), minPossibleMs(1e9, bps, sub), 1e-9);
}

test "compare names the FIRST out-of-band element and treats NaN as bad" {
    const a = [_]f32{ 1, 2, 3, 4 };
    const b = [_]f32{ 1, 2, 3.5, 4 };
    const r = compare(&a, &b, 1e-6);
    try std.testing.expectEqual(@as(i64, 2), r.first_bad);
    try std.testing.expectApproxEqAbs(@as(f64, 0.5), r.maxabs, 1e-9);
    const nanb = [_]f32{ 1, std.math.nan(f32), 3, 4 };
    try std.testing.expectEqual(@as(i64, 1), compare(&a, &nanb, 1e-6).first_bad);
    try std.testing.expectEqual(@as(i64, -1), compare(&a, &a, 0).first_bad);
}
