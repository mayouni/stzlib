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
//!   - a ROOFLINE measured on this device (bytes/s of a copy kernel, the cost
//!     of the smallest dispatch, and -- GK3, 2026-10-24 -- the FLOP/s of a
//!     register-only fma kernel) refuses BY NAME any time that could not have
//!     happened -- on the candidate AND on the reference. The compute ceiling
//!     applies where the caller DECLARES the candidate's FLOPs (the foundry
//!     does, for every op it enumerates); a kernel with no declared work is
//!     judged by the bus alone, as before.
//!
//! GK3's three findings, each paid for on 2026-10-24 (gpu_peak_probe.zig):
//!   - a peak kernel must be DENSE: 8 fma per loop round measured the loop
//!     (2.7 TFLOP/s on the RTX 3050), 256 per round measured the ALU (8.4);
//!   - a power-capped laptop part has TWO peaks, burst (4 ms dispatch) and
//!     sustained (80 ms, 15% lower); a foundry candidate runs for
//!     milliseconds, so the ceiling is the burst and PEAK_ALLOW covers the
//!     8% run-to-run on it;
//!   - Wake's old awake test (one 32 MB copy under 2 ms) was the 3050 ASLEEP
//!     and the Intel iGPU never passed it: the floors were measured mid-ramp
//!     at half the awake bandwidth. Wake now settles when the copy stops
//!     IMPROVING, whatever the adapter's speed.
//!
//! The verdict is DATA in result slots; Ring only reads them.

const std = @import("std");
const gpu = @import("gpu.zig");
const wgsl = @import("gpu_wgsl.zig");
const c = gpu.c;

pub const V_VERIFIED: i32 = 0;
pub const V_MISMATCH: i32 = 1; // wrong at the visible shape
pub const V_MISMATCH_HIDDEN: i32 = 2; // right where it was shown, wrong where it was not
pub const V_IMPOSSIBLE: i32 = 3; // the candidate's time beats the measured floor
pub const V_REF_IMPOSSIBLE: i32 = 4; // the REFERENCE beats the floor: the measurement is broken
pub const V_ERROR: i32 = 5;
pub const V_WRITE_OUTSIDE: i32 = 6; // GK6: the candidate stored past its output region (into the NaN margin)

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
pub const R_PEAK_GFLOPS = 17; // GK3: the compute peak the judge used, GFLOP/s (0 = unmeasured)
pub const R_FLOPS = 18; // GK3: the FLOPs the caller declared for the candidate (0 = none)
pub const R_MIN_MS_COMPUTE = 19; // GK3: the compute-only floor for those FLOPs, ms
pub const R_PEAK_WARM = 20; // GK3: dispatches of the peak kernel until its time stopped improving
pub const R_MARGIN = 21; // GK6: floats of NaN margin after the output region (0 = none)
// KP3: a kernel under the two roofs (stz_gpu_verify_roofline)
pub const R_ROOF_MS = 24; // best dispatch+sync wall time, the floor's own instrument
pub const R_ROOF_GPU_MS = 25; // best GPU-clock time, -1 without timestamps
pub const R_ROOF_GBS = 26; // bytes over the wall time
pub const R_ROOF_BW_FRACTION = 27; // of the measured copy floor
pub const R_ROOF_GFLOPS = 28;
pub const R_ROOF_PEAK_FRACTION = 29; // of the measured (or pinned) compute peak
pub const R_ROOF_BOUND = 30; // 1 = under the bandwidth roof, 2 = under the compute roof (by intensity)
pub const RESULT_SLOTS = 32;

/// GK6: the NaN margin after a spec-checked candidate's output region. One
/// workgroup's worth: a kernel that drops its bounds guard writes up to 255
/// elements past n (the last workgroup's tail), and every one of them lands
/// here. WHAT IT CATCHES: a store to index n or beyond -- the missing or
/// wrong guard, which is the learner's mistake. WHAT IT CANNOT: a store
/// below 0 (u32 cannot say it; it wraps to a huge index that WGSL's robust
/// access drops outside the binding), and a store INSIDE 0..n-1 at the
/// wrong index, which is a value mismatch and the compare's to catch. A
/// front margin would be unreachable for the same reason -- the binding is
/// the kernel's whole world -- so there is one margin, at the end, INSIDE
/// the binding, which is the only place a kernel can reach past its region.
pub const MARGIN: usize = 256;

// GK6: the checker's own error text, for the refusals that happen before a
// dispatch (a spec that does not compile; a shape that disagrees with its
// buffers), read with stz_gpu_verify_error
var verr_buf: [256]u8 = @splat(0);
var verr_len: usize = 0;
fn verr(comptime fmt: []const u8, args: anytype) void {
    const m = std.fmt.bufPrint(&verr_buf, fmt, args) catch {
        verr_len = 0;
        return;
    };
    verr_len = m.len;
}
pub fn stz_gpu_verify_error(out: [*]u8, cap: f64) callconv(.c) i32 {
    const n = @min(verr_len, @as(usize, @intFromFloat(cap)));
    @memcpy(out[0..n], verr_buf[0..n]);
    return @intCast(n);
}

var result: [RESULT_SLOTS]f64 = @splat(0);

pub fn stz_gpu_verify_result(idx: i32) callconv(.c) f64 {
    if (idx < 0 or idx >= RESULT_SLOTS) return 0;
    return result[@intCast(idx)];
}

// ---------------------------------------------------------------- the floors
// Measured ONCE per device (reset when it closes), never quoted from a plan.
var floor_bps: f64 = 0; // bytes per second, copy kernel, warm-min
var submit_floor_ms: f64 = 0; // the smallest dispatch + sync, warm-min
var peak_fps: f64 = 0; // GK3: FLOP/s of the dense fma kernel, warm-min, burst
var peak_warm: usize = 0; // GK3: dispatches it took the peak kernel's time to stop improving
var wake_best_ns: u64 = std.math.maxInt(u64); // GK3: the fastest 32 MB copy the PREVIOUS Wake saw on this device
var floors_ready = false;
var hooked = false;

/// GK3: the allowance over the stored burst peak before a time is refused by
/// compute. Measured 2026-10-24 on the RTX 3050: the 4 ms burst moved 8%
/// between two runs (8.02 vs 8.36 TFLOP/s) and sits 15% over the sustained
/// figure; a ceiling too LOW refuses legitimate kernels, which is the worse
/// failure, so the allowance covers the run-to-run and a little more.
pub const PEAK_ALLOW: f64 = 1.15;
/// The names under which the face RECORDS the peak and the copy floor in the
/// adapter's calibration file, beside the ops' thresholds. A record, not an
/// authority: the engine never reads them back. Found by the probe on
/// 2026-10-24 when it was otherwise -- the flat store is keyed by name and is
/// process-wide, so after a switch of adapter the RTX 3050 read the iGPU's
/// 957 GFLOP/s and 20 GB/s as its own and would have refused everything above
/// 1.1 TFLOP/s. The authority order here is EXPLICIT (a pin set in this
/// process, stz_gpu_verify_peak_set) > MEASURED (this device, this process).
pub const PEAK_NAME = "peak_gflops";
pub const COPY_NAME = "copy_gbs";
var peak_explicit_fps: f64 = 0; // a pin; 0 = none

/// GK3: pin the compute peak (GFLOP/s) for this process -- a guard's way to
/// make the ceiling refuse what the measured one accepted. 0 clears the pin.
/// Takes effect at the next judgement; survives a device close.
pub fn stz_gpu_verify_peak_set(gflops: f64) callconv(.c) void {
    peak_explicit_fps = if (gflops > 0) gflops * 1e9 else 0;
}

/// The peak the judge reads against: the pin if there is one, else the measurement.
fn effectivePeak() f64 {
    return if (peak_explicit_fps > 0) peak_explicit_fps else peak_fps;
}

// the caller may DECLARE the FLOPs of the next verify's candidate at the
// visible and the hidden shape; consumed by that call and reset
var declared_flops_a: f64 = 0;
var declared_flops_b: f64 = 0;

/// GK3: declare the candidate's FLOPs for the NEXT stz_gpu_verify call, so
/// its time is judged against the compute ceiling too. 0 = no declaration.
pub fn stz_gpu_verify_declare_flops(visible: f64, hidden: f64) callconv(.c) void {
    declared_flops_a = if (visible > 0) visible else 0;
    declared_flops_b = if (hidden > 0) hidden else 0;
}

pub const COPY_N = wgsl.COPY_N;

pub const SUBMIT_WGSL =
    \\struct StzTile { xoff: u32, p0: u32, p1: u32, p2: u32 };
    \\@group(0) @binding(0) var<uniform> tile : StzTile;
    \\@group(0) @binding(1) var<storage, read_write> o : array<f32>;
    \\@compute @workgroup_size(1)
    \\fn main() { o[0] = o[0] + f32(tile.xoff); }
;

// KP3: the copy kernel and the peak kernel live in gpu_wgsl.zig, which the wasm
// carries, so a browser measures its roofs with the same texts.
pub const COPY_WGSL = wgsl.COPY_WGSL;

pub const fmaSource = wgsl.fmaSource;

pub const PeakParams = extern struct { iters: u32, n: u32, m: f32, b: f32 };
pub const PEAK_CHAINS = wgsl.PEAK_CHAINS;
pub const PEAK_UNROLL = wgsl.PEAK_UNROLL;
pub const PEAK_WGSL = wgsl.PEAK_WGSL;
pub const PEAK_THREADS = wgsl.PEAK_THREADS;
pub const PEAK_ROUNDS = wgsl.PEAK_ROUNDS;
pub const PEAK_FLOPS = wgsl.PEAK_FLOPS;

fn onDeviceClose() void {
    floors_ready = false;
    floor_bps = 0;
    submit_floor_ms = 0;
    peak_fps = 0;
    peak_warm = 0;
    wake_best_ns = std.math.maxInt(u64);
    declared_flops_a = 0;
    declared_flops_b = 0;
    releaseTs();
}

fn ensureHook() void {
    if (hooked) return;
    gpu.registerDeviceCloseHook(&onDeviceClose);
    hooked = true;
}

/// warm-min wall ms of `reps` plain dispatches (no params) of `kernel`.
pub fn minPlainDispatchMs(kernel: i64, ids: []const i64, wx: f64, reps: usize) ?f64 {
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
    // THE GOVERNOR, MEASURED (GK3, 2026-10-24, nvidia-smi sampled at 250 ms
    // while the guards ran): the RTX 3050 sits at 990 MHz (P3, reasons
    // 0x24 = software power cap + thermal slowdown) and rises to 1477-1740
    // only after roughly a quarter second of SUSTAINED work; an asleep card
    // copies 32 MB in ~9 ms and that is a plateau too, so a rule that stops
    // on "no longer improving" stopped on the sleep itself and read a 5.9
    // GB/s floor. And the Intel iGPU copies at ~1.5 ms whatever one does, so
    // the old test -- one copy under 2 ms -- never settled there.
    //
    // So, two regimes. The FIRST Wake on a device: at least `min_warm` of
    // sustained copies, then stop when `settle` copies in a row fail to
    // beat the running minimum by 10%; the best copy seen is remembered.
    // EVERY LATER Wake: a copy within 3x of that best says awake, and
    // `settle` such copies end the burst at once (an awake 3050: ~21
    // copies, ~10 ms -- the shaped-calibration guard's "second burst stops
    // at the settle count" is the gate on this). Why 3x and not less: the
    // best is an outlier minimum (0.39 ms against 0.43-0.48 typical on the
    // 3050) and a 1.3x bound failed that gate at 669 copies; an asleep card
    // copies 20x slower, so 3x cannot mistake sleep for awake. Asleep, the
    // loop runs until the flip or the cap. The budget stays a CAP. (A
    // measured copy floor, when there is one, is a second reference.)
    // The reference is the PREVIOUS Wake's best, not an all-time best: on a
    // laptop on battery (measured 2026-10-24, 72%, software power cap active)
    // the awake copy itself moved between 16 and 77 GB/s across an hour, and
    // an all-time best from a fast state made every later copy look asleep.
    const settle: i32 = 20;
    const min_warm_ns: u64 = 300_000_000;
    var awake_ns: ?u64 = null;
    if (wake_best_ns != std.math.maxInt(u64)) awake_ns = wake_best_ns * 3;
    var this_best_ns: u64 = std.math.maxInt(u64);
    defer {
        if (this_best_ns != std.math.maxInt(u64)) wake_best_ns = this_best_ns;
    }
    if (floors_ready and floor_bps > 0) {
        const f: u64 = @intFromFloat((2.0 * nbytes / floor_bps) * 3e9);
        awake_ns = if (awake_ns) |a| @min(a, f) else f;
    }
    const floor_copy_ns: ?u64 = awake_ns;
    var timer = std.time.Timer.start() catch return 0;
    var count: i32 = 0;
    var settled: i32 = 0;
    var best_ns: u64 = std.math.maxInt(u64);
    const budget_ns: u64 = @intFromFloat(@max(budget_ms, 1) * 1e6);
    while (timer.read() < budget_ns and count < 100000) : (count += 1) {
        var one = std.time.Timer.start() catch return count;
        if (gpu.stz_gpu_dispatch(kc, &ids, 2, wx, 1) != gpu.OK) return count;
        if (gpu.stz_gpu_sync() != gpu.OK) return count;
        const ns = one.read();
        if (ns < this_best_ns) this_best_ns = ns;
        if (floor_copy_ns) |awake| {
            if (ns < awake) {
                settled += 1;
                if (settled >= settle) {
                    count += 1;
                    break;
                }
            } else settled = 0;
            continue;
        }
        if (ns < best_ns - best_ns / 10) {
            best_ns = ns; // still improving: the ramp, or the flip out of sleep
            settled = 0;
        } else {
            settled += 1;
            if (timer.read() >= min_warm_ns and settled >= settle) {
                count += 1;
                break;
            }
        }
    }
    return count;
}

fn ensureFloors() bool {
    if (floors_ready) return true;
    if (!gpu.isAvail()) return false;
    ensureHook();
    // the floors are AWAKE numbers by construction (see stz_gpu_wake). The
    // cap is 2000 ms here, not the 400 the op sites use: the floors are
    // measured ONCE per device and are what every verdict reads against,
    // and the iGPU's ramp is ~600 ms. An awake device still returns in ~36 ms.
    _ = stz_gpu_wake(2000);

    // 0. GK3: the compute warm-up FIRST. Copies leave sleep but do not lift
    //    the SM clock; the dense kernel does, and the copy and submit floors
    //    measured at the lifted clock are the device's (77 GB/s and 0.13 ms
    //    on the 3050, against 27 GB/s and 0.89 ms read before it once).
    if (!measurePeak()) return false;

    // 1-2. the submit floor and the copy floor, as the MINIMUM over three
    //    rounds separated by ~100 ms of dense compute. Measured from a cold
    //    card on 2026-10-24: copies ran at 6 GB/s for the first 250 ms and
    //    then at 49-67; and once, after a second of compute, the smallest
    //    dispatch read 0.82 ms and the copy 16 GB/s where the awake device
    //    does 0.13 and 77 -- a floor measured in a slow state refuses awake
    //    work as impossible (the GK0 control itself read "impossible" that
    //    way). A floor is the fastest the device does; the minimum across
    //    states, with compute between to move the governor, is that.
    const ks = gpu.stz_gpu_kernel_compile(SUBMIT_WGSL.ptr, @floatFromInt(SUBMIT_WGSL.len));
    if (ks == 0) return false;
    const tiny = gpu.stz_gpu_buffer_new(256);
    if (tiny == 0) return false;
    defer _ = gpu.stz_gpu_buffer_free(tiny);
    const ids1 = [_]i64{tiny};
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
    submit_floor_ms = std.math.inf(f64);
    var copy_ms: f64 = std.math.inf(f64);
    var round: usize = 0;
    while (round < 3) : (round += 1) {
        _ = minPlainDispatchMs(ks, &ids1, 1, 1); // warm
        const sm = minPlainDispatchMs(ks, &ids1, 1, 7) orelse return false;
        if (sm < submit_floor_ms) submit_floor_ms = sm;
        _ = minPlainDispatchMs(kc, &ids2, wx, 1); // warm
        const cm = minPlainDispatchMs(kc, &ids2, wx, 5) orelse return false;
        if (cm < copy_ms) copy_ms = cm;
        if (round < 2 and !burstCompute(100)) return false;
    }
    if (copy_ms <= 0 or copy_ms == std.math.inf(f64) or submit_floor_ms == std.math.inf(f64)) return false;
    floor_bps = (2.0 * nbytes) / (copy_ms / 1000.0);

    floors_ready = true;
    return true;
}

/// KP3: one fresh round of the bus floors, FOLDED IN: the submit floor only
/// gets smaller and the copy bandwidth only larger, because a floor is the
/// fastest the device does. Measured 2026-10-27: the System's checker runs four
/// learner programs side by side, each measuring its floors while the others
/// had the device; a floor read in that slow state made a 4,096-element SAXPY
/// "impossible" in 2 of 8 self-proofs -- the GK0 control's failure, under
/// contention instead of a cold card. Returns whether either floor improved.
fn foldBusFloors() bool {
    const ks = gpu.stz_gpu_kernel_compile(SUBMIT_WGSL.ptr, @floatFromInt(SUBMIT_WGSL.len));
    if (ks == 0) return false;
    const tiny = gpu.stz_gpu_buffer_new(256);
    if (tiny == 0) return false;
    defer _ = gpu.stz_gpu_buffer_free(tiny);
    const ids1 = [_]i64{tiny};
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
    _ = minPlainDispatchMs(ks, &ids1, 1, 1);
    const sm = minPlainDispatchMs(ks, &ids1, 1, 7) orelse return false;
    _ = minPlainDispatchMs(kc, &ids2, wx, 1);
    const cm = minPlainDispatchMs(kc, &ids2, wx, 5) orelse return false;
    var better = false;
    if (sm < submit_floor_ms) {
        submit_floor_ms = sm;
        better = true;
    }
    if (cm > 0) {
        const bps = (2.0 * nbytes) / (cm / 1000.0);
        if (bps > floor_bps) {
            floor_bps = bps;
            better = true;
        }
    }
    return better;
}

/// Before a time is refused as impossible by the BUS floors, measure them again
/// (twice at most) and judge against the faster reading. Returns the new floor.
fn confirmBusRefusal(bytes: f64, flops: f64, ms: f64, min_ms: f64) f64 {
    var m = min_ms;
    var tries: usize = 0;
    while (ms < m and tries < 2) : (tries += 1) {
        if (!foldBusFloors()) break;
        m = minPossibleMs(bytes, flops, floor_bps, submit_floor_ms, effectivePeak());
    }
    result[R_FLOOR_GBS] = floor_bps / 1e9;
    result[R_SUBMIT_FLOOR_MS] = submit_floor_ms;
    return m;
}

/// ~`ms` of back-to-back dense dispatches: the thing that moves the governor.
fn burstCompute(ms: u64) bool {
    const kp = gpu.stz_gpu_kernel_compile(PEAK_WGSL.ptr, @floatFromInt(PEAK_WGSL.len));
    if (kp == 0) return false;
    const pbytes: f64 = @floatFromInt(PEAK_THREADS * 4);
    const pin = gpu.stz_gpu_buffer_new(pbytes);
    if (pin == 0) return false;
    defer _ = gpu.stz_gpu_buffer_free(pin);
    const pout = gpu.stz_gpu_buffer_new(pbytes);
    if (pout == 0) return false;
    defer _ = gpu.stz_gpu_buffer_free(pout);
    const pids = [_]i64{ pin, pout };
    const prm = PeakParams{ .iters = PEAK_ROUNDS / @as(u32, @intCast(PEAK_UNROLL)), .n = @intCast(PEAK_THREADS), .m = 0.999, .b = 0.001 };
    const params = std.mem.asBytes(&prm);
    const wxp: f64 = @floatFromInt(PEAK_THREADS / 256);
    var timer = std.time.Timer.start() catch return false;
    var g: f64 = -1;
    while (timer.read() < ms * 1_000_000) {
        _ = timedDispatch(kp, params, &pids, wxp, false, &g) orelse return false;
    }
    return true;
}

/// The burst compute peak of the open device: PEAK_FLOPS of fused
/// multiply-adds in the warm-min time of 5 dispatches, GPU clock first.
fn measurePeak() bool {
    const kp = gpu.stz_gpu_kernel_compile(PEAK_WGSL.ptr, @floatFromInt(PEAK_WGSL.len));
    if (kp == 0) return false;
    const pbytes: f64 = @floatFromInt(PEAK_THREADS * 4);
    const pin = gpu.stz_gpu_buffer_new(pbytes);
    if (pin == 0) return false;
    defer _ = gpu.stz_gpu_buffer_free(pin);
    const pout = gpu.stz_gpu_buffer_new(pbytes);
    if (pout == 0) return false;
    defer _ = gpu.stz_gpu_buffer_free(pout);
    const pids = [_]i64{ pin, pout };
    const prm = PeakParams{ .iters = PEAK_ROUNDS / @as(u32, @intCast(PEAK_UNROLL)), .n = @intCast(PEAK_THREADS), .m = 0.999, .b = 0.001 };
    const params = std.mem.asBytes(&prm);
    const wxp: f64 = @floatFromInt(PEAK_THREADS / 256);
    const two = ensureTs();
    // WARM FOR COMPUTE, the way Wake warms for bandwidth (GK3, 2026-10-24):
    // this kernel dispatched right after the copy floors read 4.8 TFLOP/s on
    // the RTX 3050 in every run (the card at 990 MHz under its power cap),
    // and the same kernel after seconds of arithmetic read 7.1-7.5 (1477-1740
    // MHz). The SM clock rises with SUSTAINED ARITHMETIC and copies do not
    // raise it, so a peak read cold is a ceiling that refuses legitimate
    // kernels -- the worse failure. So: at least `min_warm` of back-to-back
    // dispatches, then windows of 5 until three windows in a row fail to
    // beat the best by 3%, cap 1500 ms; then the house's warm-min of 5. The
    // peak is the best time seen anywhere in that, and a re-measurement
    // (confirmComputeRefusal) can only raise it.
    // min_warm was 300 ms until a cold card (two minutes idle) plateaued at
    // 990 MHz for the whole of it, read 4.8 TFLOP/s, and the confirmation
    // re-measurement then read 8.4: the governor's jump is discrete and can
    // come late, so the warm-up is a full second, once per device and process.
    const min_warm_ns: u64 = 1_000_000_000;
    const cap_ns: u64 = 2_000_000_000;
    var timer = std.time.Timer.start() catch return false;
    var best: f64 = std.math.inf(f64);
    var stale: usize = 0;
    var warm: usize = 0;
    while (timer.read() < cap_ns and warm < 2000) {
        var wmin: f64 = std.math.inf(f64);
        var k: usize = 0;
        while (k < 5) : (k += 1) {
            var gms: f64 = -1;
            const wall = timedDispatch(kp, params, &pids, wxp, two, &gms) orelse return false;
            const t = if (gms > 0) gms else wall;
            if (t < wmin) wmin = t;
            warm += 1;
        }
        if (best == std.math.inf(f64) or wmin < best * 0.97) {
            best = wmin; // the clock is still rising
            stale = 0;
        } else {
            if (wmin < best) best = wmin;
            stale += 1;
            if (timer.read() >= min_warm_ns and stale >= 3) break;
        }
    }
    peak_warm = warm;
    var r: usize = 0;
    while (r < 5) : (r += 1) {
        var gms: f64 = -1;
        const wall = timedDispatch(kp, params, &pids, wxp, two, &gms) orelse return false;
        const t = if (gms > 0) gms else wall;
        if (t < best) best = t;
    }
    if (!(best > 0) or best == std.math.inf(f64)) return false;
    const measured = PEAK_FLOPS / (best / 1000.0);
    if (measured > peak_fps) peak_fps = measured; // a later, warmer reading only raises the peak
    return true;
}

/// A refusal by compute is pronounced only against a peak measured in the
/// SAME second: the Intel iGPU's peak halved (955 -> 470 GFLOP/s) after
/// eleven seconds of its own full load on 2026-10-24 -- package thermal
/// throttling -- and a kernel timed cool against a ceiling measured hot
/// would be refused for running as fast as the device can. So before the
/// verdict the peak is measured again (it can only rise), and the time is
/// judged once more. A PINNED peak is authoritative and is not re-measured.
fn confirmComputeRefusal(flops: f64, ms: f64) bool {
    if (peak_explicit_fps > 0) return true;
    if (!measurePeak()) return true;
    return ms < minComputeMs(flops, effectivePeak());
}

/// The compute peak the judge reads against, GFLOP/s (0 = no device yet):
/// the pin if there is one, else the measurement.
pub fn stz_gpu_verify_peak_gflops() callconv(.c) f64 {
    if (!ensureFloors()) return 0;
    return effectivePeak() / 1e9;
}

/// The MEASURED peak alone, GFLOP/s, whatever the pin -- the record's value.
pub fn stz_gpu_verify_peak_measured_gflops() callconv(.c) f64 {
    if (!ensureFloors()) return 0;
    return peak_fps / 1e9;
}

/// The floor for a dispatch touching `bytes` and doing `flops`: it cannot
/// beat the smallest dispatch we measured, it cannot move bytes faster than
/// the measured copy bandwidth -- with an 8x allowance, because a working
/// set that fits in cache legitimately beats DRAM, and a floor that refuses
/// a legitimate result is worse than one that lets a marginal one through --
/// and (GK3) it cannot do more fused multiply-adds per second than the
/// measured burst peak times PEAK_ALLOW. flops = 0 means undeclared: the
/// bus floors alone, as before GK3. Pure.
pub fn minPossibleMs(bytes: f64, flops: f64, bps: f64, submit_ms: f64, peak: f64) f64 {
    const by_bus = if (bps > 0) (bytes / (bps * 8.0)) * 1000.0 else 0;
    const by_submit = submit_ms * 0.5;
    const by_compute = minComputeMs(flops, peak);
    return @max(@max(by_bus, by_submit), by_compute);
}

/// The compute-only floor: `flops` at the stored peak with the allowance. Pure.
pub fn minComputeMs(flops: f64, peak: f64) f64 {
    return if (peak > 0 and flops > 0) (flops / (peak * PEAK_ALLOW)) * 1000.0 else 0;
}

pub fn judgeWith(bytes: f64, flops: f64, ms: f64, bps: f64, submit_ms: f64, peak: f64) i32 {
    return if (ms < minPossibleMs(bytes, flops, bps, submit_ms, peak)) V_IMPOSSIBLE else V_VERIFIED;
}

/// KP3: where a kernel stands under this device's two roofs. Runs `kernel`
/// on the caller's buffers `reps` times (after two warm dispatches) and keeps
/// the best dispatch+sync wall time -- the instrument the copy floor is
/// measured with, so the fraction is like for like -- and the best GPU-clock
/// time beside it when there are timestamps. `bytes` and `flops` are the
/// kernel's ESSENTIAL traffic and work (each input read once, the output
/// written once; one per operator per element): the roofline's convention,
/// so a kernel that rereads memory shows a lower fraction, which is the point.
/// The kernel's intensity (flops / bytes) against the ridge (peak / bandwidth)
/// says which roof is the lower one for it. 0, or -1 with no device.
pub fn stz_gpu_verify_roofline(kernel: i64, params: [*]const u8, plen: f64, ids: [*]const i64, nids: i32, wx: f64, bytes: f64, flops: f64, reps: f64) callconv(.c) i32 {
    if (!ensureFloors()) return -1;
    const pr = params[0..@intFromFloat(plen)];
    const id = ids[0..@intCast(nids)];
    const two = ensureTs();
    var g: f64 = 0;
    _ = timedDispatch(kernel, pr, id, wx, false, &g) orelse return -1;
    _ = timedDispatch(kernel, pr, id, wx, false, &g) orelse return -1;
    var best_wall: f64 = std.math.inf(f64);
    var best_gpu: f64 = std.math.inf(f64);
    const n: usize = if (reps >= 1) @intFromFloat(reps) else 7;
    for (0..n) |_| {
        const wall = timedDispatch(kernel, pr, id, wx, two, &g) orelse return -1;
        if (wall < best_wall) best_wall = wall;
        if (g > 0 and g < best_gpu) best_gpu = g;
    }
    const peak = effectivePeak();
    result[R_ROOF_MS] = best_wall;
    result[R_ROOF_GPU_MS] = if (best_gpu == std.math.inf(f64)) -1 else best_gpu;
    const gbs = bytes / (best_wall / 1000.0) / 1e9;
    result[R_ROOF_GBS] = gbs;
    result[R_FLOOR_GBS] = floor_bps / 1e9;
    result[R_ROOF_BW_FRACTION] = if (floor_bps > 0) gbs / (floor_bps / 1e9) else 0;
    const gflops = flops / (best_wall / 1000.0) / 1e9;
    result[R_ROOF_GFLOPS] = gflops;
    result[R_PEAK_GFLOPS] = peak / 1e9;
    result[R_ROOF_PEAK_FRACTION] = if (peak > 0) gflops / (peak / 1e9) else 0;
    const ridge = if (floor_bps > 0) peak / floor_bps else 0;
    result[R_ROOF_BOUND] = if (bytes > 0 and flops / bytes >= ridge) 2 else 1;
    result[R_BYTES] = bytes;
    result[R_FLOPS] = flops;
    result[R_SUBMIT_FLOOR_MS] = submit_floor_ms;
    return 0;
}

/// Is a dispatch over `bytes` in `ms` physically possible on this device?
/// Measures the floors if they are not yet; exposed so a guard can hand it
/// an impossible number and watch it refuse. Bus floors only (no FLOPs).
pub fn stz_gpu_verify_judge(bytes: f64, ms: f64) callconv(.c) i32 {
    return stz_gpu_verify_judge_flops(bytes, 0, ms);
}

/// GK3: the same judge with the candidate's FLOPs declared, so the compute
/// ceiling applies: `flops` in `ms` claiming more than the measured burst
/// peak times PEAK_ALLOW is refused by name.
pub fn stz_gpu_verify_judge_flops(bytes: f64, flops: f64, ms: f64) callconv(.c) i32 {
    if (!ensureFloors()) return V_ERROR;
    const peak = effectivePeak();
    result[R_FLOOR_GBS] = floor_bps / 1e9;
    result[R_SUBMIT_FLOOR_MS] = submit_floor_ms;
    result[R_PEAK_GFLOPS] = peak / 1e9;
    result[R_PEAK_WARM] = @floatFromInt(peak_warm);
    result[R_BYTES] = bytes;
    result[R_FLOPS] = flops;
    result[R_MIN_MS_COMPUTE] = minComputeMs(flops, peak);
    result[R_MIN_MS] = minPossibleMs(bytes, flops, floor_bps, submit_floor_ms, peak);
    const verdict = judgeWith(bytes, flops, ms, floor_bps, submit_floor_ms, peak);
    if (verdict == V_IMPOSSIBLE and ms >= minPossibleMs(bytes, 0, floor_bps, submit_floor_ms, 0)) {
        // refused by COMPUTE alone (the bus floors accept it): confirm against a fresh peak
        if (!confirmComputeRefusal(flops, ms)) {
            const p2 = effectivePeak();
            result[R_PEAK_GFLOPS] = p2 / 1e9;
            result[R_PEAK_WARM] = @floatFromInt(peak_warm);
            result[R_MIN_MS_COMPUTE] = minComputeMs(flops, p2);
            result[R_MIN_MS] = minPossibleMs(bytes, flops, floor_bps, submit_floor_ms, p2);
            return V_VERIFIED;
        }
    }
    return verdict;
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

pub fn ensureTs() bool {
    if (!gpu.hasTimestamps()) return false;
    // the query set belongs to THIS device: the close hook that releases it
    // must be in place before one is made, whoever asks first (found by the
    // probe's --ramp mode, 2026-10-24, which asked for timestamps before any
    // floor had been measured, switched adapters, and wgpu refused a query
    // set of the old device on the new one)
    ensureHook();
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
pub fn readTimestampsMs() f64 {
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
pub fn timedDispatch(kernel: i64, params: []const u8, ids: []const i64, wx: f64, two_clocks: bool, gpu_ms: *f64) ?f64 {
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

/// GK2e: two dispatches timed as ONE -- the first pass writes the start
/// timestamp and the second the end, so the GPU clock spans both and the
/// gap between their submits, which a two-pass op pays.
pub fn timedPair(k1: i64, p1: []const u8, ids1: []const i64, wx1: f64, k2: i64, p2: []const u8, ids2: []const i64, wx2: f64, two_clocks: bool, gpu_ms: *f64) ?f64 {
    var timer = std.time.Timer.start() catch return null;
    var first: c.WGPUPassTimestampWrites = undefined;
    var second: c.WGPUPassTimestampWrites = undefined;
    if (two_clocks) {
        first = ts_writes;
        first.endOfPassWriteIndex = c.WGPU_QUERY_SET_INDEX_UNDEFINED;
        second = ts_writes;
        second.beginningOfPassWriteIndex = c.WGPU_QUERY_SET_INDEX_UNDEFINED;
        gpu.g_pass_ts = &first;
    }
    const st1 = gpu.stz_gpu_dispatch_params(k1, p1.ptr, @floatFromInt(p1.len), ids1.ptr, @intCast(ids1.len), wx1, 1);
    if (two_clocks) gpu.g_pass_ts = &second;
    const st2 = gpu.stz_gpu_dispatch_params(k2, p2.ptr, @floatFromInt(p2.len), ids2.ptr, @intCast(ids2.len), wx2, 1);
    gpu.g_pass_ts = null;
    if (st1 != gpu.OK or st2 != gpu.OK) return null;
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

/// GK6/KP0: the compare with the interpreter's written mask. An element the
/// reference's guard left unwritten (mask 0) must still be the NaN fill in
/// the candidate -- a kernel that wrote it wrote where the task says not to,
/// and that is the first bad element. A written element follows the band's
/// rule, NaN agreeing with nothing.
fn compareMasked(ref: []const f32, cand: []const f32, mask: []const u8, band: f64) Compare {
    var maxabs: f64 = 0;
    var first_bad: i64 = -1;
    for (ref, cand, mask, 0..) |x, y, m, i| {
        if (m == 0) {
            if (y == y and first_bad < 0) first_bad = @intCast(i); // written where unwritten was owed
            continue;
        }
        const d: f64 = @abs(@as(f64, x) - @as(f64, y));
        if (!(d <= band) and first_bad < 0) first_bad = @intCast(i);
        if (d > maxabs or d != d) maxabs = if (d != d) std.math.inf(f64) else d;
    }
    return .{ .maxabs = maxabs, .first_bad = first_bad };
}

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
    const peak = effectivePeak();
    result[R_PEAK_GFLOPS] = peak / 1e9;
    result[R_PEAK_WARM] = @floatFromInt(peak_warm);
    result[R_REPS] = @floatFromInt(nreps);
    // GK3: the declared FLOPs are this call's and nobody else's
    const flops_a = declared_flops_a;
    declared_flops_a = 0;
    declared_flops_b = 0;
    result[R_FLOPS] = flops_a;

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
    var min_ms = minPossibleMs(bytes, flops_a, floor_bps, submit_floor_ms, peak);
    const bus_ms = minPossibleMs(bytes, 0, floor_bps, submit_floor_ms, 0);
    result[R_MIN_MS] = min_ms;
    result[R_MIN_MS_COMPUTE] = minComputeMs(flops_a, peak);
    // a refusal by compute alone is confirmed against a peak measured now
    const faster = @min(ref_min, cand_min);
    if (faster < min_ms and faster >= bus_ms and !confirmComputeRefusal(flops_a, faster)) {
        const p2 = effectivePeak();
        result[R_PEAK_GFLOPS] = p2 / 1e9;
        result[R_PEAK_WARM] = @floatFromInt(peak_warm);
        min_ms = minPossibleMs(bytes, flops_a, floor_bps, submit_floor_ms, p2);
        result[R_MIN_MS] = min_ms;
        result[R_MIN_MS_COMPUTE] = minComputeMs(flops_a, p2);
    }
    if (faster < min_ms) {
        min_ms = confirmBusRefusal(bytes, flops_a, faster, min_ms);
        result[R_MIN_MS] = min_ms;
    }
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

// ---------------------------------------------------------------- GK6: the spec as the reference
const SpecShape = struct { outside: i64, cmp: Compare, cpu_ms: f64, flops: f64 };

/// One shape: read the inputs back, evaluate the spec on the host (timed),
/// run the candidate into a NaN-filled buffer with a margin, scan the
/// margin, compare the region. `ids` = inputs then the candidate's output.
fn checkSpecShape(kcand: i64, params: []const u8, ids: []const i64, n: usize, wx: f64, band: f64, slot_maxabs: usize) ?SpecShape {
    const alloc = std.heap.c_allocator;
    const n_in = ids.len - 1;
    // the inputs, read back from the device buffers the caller filled
    // each input is read back WHOLE: a neighbour read or a sum is bounded by
    // the input's own length, which need not be n (a first pass of partials
    // writes n outputs over a longer input)
    var host: [8][]f32 = undefined;
    var ptrs: [8][*]const f32 = undefined;
    var lens: [8]f64 = undefined;
    var got: usize = 0;
    defer for (0..got) |k| alloc.free(host[k]);
    for (0..n_in) |k| {
        const len = gpu.rawBufferSize(ids[k]) / 4;
        host[k] = alloc.alloc(f32, len) catch return null;
        got += 1;
        if (!readF32(ids[k], host[k])) return null;
        ptrs[k] = host[k].ptr;
        lens[k] = @floatFromInt(len);
    }
    // the scalars, as the params uniform carries them: n, pad, then f32s
    var scal: [wgsl.MAX_SCALARS]f32 = @splat(0);
    const n_scal: usize = if (params.len > 8) (params.len - 8) / 4 else 0;
    for (0..@min(n_scal, wgsl.MAX_SCALARS)) |k| {
        scal[k] = @bitCast(std.mem.readInt(u32, params[8 + k * 4 ..][0..4], .little));
    }
    // the REFERENCE: the spec, on the CPU, timed
    const ref = alloc.alloc(f32, n) catch return null;
    defer alloc.free(ref);
    const mask = alloc.alloc(u8, n) catch return null;
    defer alloc.free(mask);
    var t = std.time.Timer.start() catch return null;
    if (wgsl.stz_gpu_spec_eval_masked(&ptrs, @intCast(n_in), &lens, &scal, @intCast(n_scal), @floatFromInt(n), ref.ptr, mask.ptr) != 0) return null;
    const cpu_ms = @as(f64, @floatFromInt(t.read())) / 1e6;
    const flops = wgsl.stz_gpu_spec_eval_flops();
    // the candidate's region and margin, NaN before it runs
    const total = n + MARGIN;
    const cand = alloc.alloc(f32, total) catch return null;
    defer alloc.free(cand);
    @memset(cand, std.math.nan(f32));
    if (gpu.stz_gpu_buffer_write(ids[n_in], @ptrCast(cand.ptr), @floatFromInt(total * 4)) != gpu.OK) return null;
    var dummy: f64 = 0;
    _ = timedDispatch(kcand, params, ids, wx, false, &dummy) orelse return null;
    if (!readF32(ids[n_in], cand)) return null;
    // the margin: anything that is not NaN was written past the region
    var outside: i64 = -1;
    for (cand[n..total], 0..) |x, k| {
        if (x == x) {
            outside = @intCast(n + k);
            break;
        }
    }
    const cmp = compareMasked(ref, cand[0..n], mask, band);
    result[slot_maxabs] = cmp.maxabs;
    return .{ .outside = outside, .cmp = cmp, .cpu_ms = cpu_ms, .flops = flops };
}

/// GK6: verify a candidate kernel against a SPEC interpreted on the CPU --
/// the user kernel's own reference, no Zig twin. ids_a / ids_b are the
/// inputs then the candidate's OUTPUT buffer, which must hold n + MARGIN
/// floats (the margin is NaN-filled here and scanned after the dispatch).
/// Shape assert: every input must hold n floats and the output n + MARGIN,
/// or the call refuses with both numbers in stz_gpu_verify_error. The
/// candidate alone is timed (reps, two clocks); the spec's CPU time at the
/// visible shape is reported in R_REF_MS and R_SPEEDUP is cpu / candidate.
/// The spec's operation count declares the FLOPs the compute ceiling reads.
pub fn stz_gpu_verify_spec(
    spec: [*]const u8,
    spec_len: f64,
    kcand: i64,
    params_a: [*]const u8,
    len_a: f64,
    ids_a: [*]const i64,
    nids_a: i32,
    n_a: f64,
    wx_a: f64,
    params_b: [*]const u8,
    len_b: f64,
    ids_b: [*]const i64,
    nids_b: i32,
    n_b: f64,
    wx_b: f64,
    reps: f64,
    band: f64,
) callconv(.c) i32 {
    result = @splat(0);
    verr_len = 0;
    result[R_VERDICT] = V_ERROR;
    result[R_FIRST_BAD] = -1;
    result[R_REF_GPU_MS] = -1;
    result[R_CAND_GPU_MS] = -1;
    result[R_MARGIN] = @floatFromInt(MARGIN);
    if (!gpu.isAvail()) {
        gpu.countFallback();
        return gpu.FALLBACK;
    }
    if (wgsl.stz_gpu_spec_compile(spec, spec_len) != 0) {
        var e: [256]u8 = undefined;
        const el = wgsl.stz_gpu_wgsl_error(&e, e.len);
        verr("spec refused: {s}", .{e[0..@intCast(el)]});
        return gpu.BAD_ARG;
    }
    if (kcand <= 0) return gpu.BAD_ARG;
    if (nids_a < 2 or nids_a > 8 or nids_b < 2 or nids_b > 8) return gpu.BAD_ARG;
    const n_in: usize = @intCast(nids_a - 1);
    if (n_in != @as(usize, @intCast(wgsl.stz_gpu_spec_inputs())) or nids_b != nids_a) {
        verr("the spec declares {d} input(s); {d} buffer(s) were bound before the output", .{ wgsl.stz_gpu_spec_inputs(), n_in });
        return gpu.BAD_ARG;
    }
    const la: usize = @intFromFloat(len_a);
    const lb: usize = @intFromFloat(len_b);
    if (la < 8 or la > gpu.PARAMS_BYTES or lb < 8 or lb > gpu.PARAMS_BYTES) return gpu.BAD_ARG;
    const na: usize = @intFromFloat(n_a);
    const nb: usize = @intFromFloat(n_b);
    if (na == 0 or nb == 0) return gpu.BAD_ARG;
    const ia = ids_a[0..@intCast(nids_a)];
    const ib = ids_b[0..@intCast(nids_b)];
    // THE SHAPE ASSERT: before any dispatch, the declared shape against the buffers
    for ([_]struct { ids: []const i64, n: usize, name: []const u8 }{ .{ .ids = ia, .n = na, .name = "visible" }, .{ .ids = ib, .n = nb, .name = "hidden" } }) |sh| {
        for (sh.ids, 0..) |id, k| {
            const have = gpu.rawBufferSize(id) / 4;
            const need = if (k == sh.ids.len - 1) sh.n + MARGIN else sh.n;
            if (have < need) {
                verr("shape: the {s} shape declares n = {d} but buffer {d} holds {d} floats and needs {d}{s}", .{ sh.name, sh.n, k, have, need, if (k == sh.ids.len - 1) " (n plus the NaN margin)" else "" });
                return gpu.BAD_ARG;
            }
        }
    }
    const nreps: usize = @intFromFloat(@max(reps, 3));
    if (!ensureFloors()) return gpu.GPU_ERROR;
    const pa = params_a[0..la];
    const pb = params_b[0..lb];
    const peak = effectivePeak();
    result[R_FLOOR_GBS] = floor_bps / 1e9;
    result[R_SUBMIT_FLOOR_MS] = submit_floor_ms;
    result[R_PEAK_GFLOPS] = peak / 1e9;
    result[R_PEAK_WARM] = @floatFromInt(peak_warm);
    result[R_REPS] = @floatFromInt(nreps);
    // 1. the visible shape: margin, then values; the FLOPs are what the
    //    interpreter executed there, loops included (KP0)
    const sa = checkSpecShape(kcand, pa, ia, na, wx_a, band, R_MAXABS_A) orelse return gpu.GPU_ERROR;
    result[R_REF_MS] = sa.cpu_ms;
    const flops_a: f64 = sa.flops;
    result[R_FLOPS] = flops_a;
    if (sa.outside >= 0) {
        result[R_VERDICT] = V_WRITE_OUTSIDE;
        result[R_FIRST_BAD] = @floatFromInt(sa.outside);
        return gpu.OK;
    }
    if (sa.cmp.first_bad >= 0) {
        result[R_VERDICT] = V_MISMATCH;
        result[R_FIRST_BAD] = @floatFromInt(sa.cmp.first_bad);
        return gpu.OK;
    }
    // 2. the hidden shape
    const sb = checkSpecShape(kcand, pb, ib, nb, wx_b, band, R_MAXABS_B) orelse return gpu.GPU_ERROR;
    if (sb.outside >= 0) {
        result[R_VERDICT] = V_WRITE_OUTSIDE;
        result[R_FIRST_BAD] = @floatFromInt(sb.outside);
        return gpu.OK;
    }
    if (sb.cmp.first_bad >= 0) {
        result[R_VERDICT] = V_MISMATCH_HIDDEN;
        result[R_FIRST_BAD] = @floatFromInt(sb.cmp.first_bad);
        return gpu.OK;
    }
    // 3. timing: the candidate alone, warm, two clocks where there are two
    const two = ensureTs();
    var cand_min: f64 = std.math.inf(f64);
    var cand_max: f64 = 0;
    var cand_gpu_min: f64 = std.math.inf(f64);
    var r: usize = 0;
    while (r < nreps) : (r += 1) {
        var g: f64 = -1;
        const tc = timedDispatch(kcand, pa, ia, wx_a, two, &g) orelse return gpu.GPU_ERROR;
        if (tc < cand_min) cand_min = tc;
        if (tc > cand_max) cand_max = tc;
        if (g >= 0 and g < cand_gpu_min) cand_gpu_min = g;
    }
    result[R_CAND_MS] = cand_min;
    result[R_JITTER_MS] = cand_max - cand_min;
    result[R_SPEEDUP] = if (cand_min > 0) sa.cpu_ms / cand_min else 0;
    const have_gpu = two and cand_gpu_min < std.math.inf(f64);
    result[R_CLOCKS] = if (have_gpu) 2 else 1;
    if (have_gpu) {
        result[R_CAND_GPU_MS] = cand_gpu_min;
        result[R_SPEEDUP_GPU] = if (cand_gpu_min > 0) sa.cpu_ms / cand_gpu_min else 0;
    }
    // 4. the roofline, with the spec's own FLOP count
    var bytes: f64 = 0;
    for (ia) |id| bytes += @floatFromInt(gpu.rawBufferSize(id));
    result[R_BYTES] = bytes;
    var min_ms = minPossibleMs(bytes, flops_a, floor_bps, submit_floor_ms, peak);
    const bus_ms = minPossibleMs(bytes, 0, floor_bps, submit_floor_ms, 0);
    result[R_MIN_MS] = min_ms;
    result[R_MIN_MS_COMPUTE] = minComputeMs(flops_a, peak);
    if (cand_min < min_ms and cand_min >= bus_ms and !confirmComputeRefusal(flops_a, cand_min)) {
        const p2 = effectivePeak();
        result[R_PEAK_GFLOPS] = p2 / 1e9;
        min_ms = minPossibleMs(bytes, flops_a, floor_bps, submit_floor_ms, p2);
        result[R_MIN_MS] = min_ms;
        result[R_MIN_MS_COMPUTE] = minComputeMs(flops_a, p2);
    }
    if (cand_min < min_ms) {
        min_ms = confirmBusRefusal(bytes, flops_a, cand_min, min_ms);
        result[R_MIN_MS] = min_ms;
    }
    if (cand_min < min_ms) {
        result[R_VERDICT] = V_IMPOSSIBLE;
        return gpu.OK;
    }
    result[R_VERDICT] = V_VERIFIED;
    return gpu.OK;
}

test "the roofline judge is pure and refuses by the floor it is given" {
    // floors: 100 GB/s, 0.06 ms per submit, no peak
    const bps: f64 = 100e9;
    const sub: f64 = 0.06;
    // 1 GB in 0.01 ms is 100 TB/s: impossible even with the 8x cache allowance
    try std.testing.expectEqual(V_IMPOSSIBLE, judgeWith(1e9, 0, 0.01, bps, sub, 0));
    // 32 KB in 1 ms is fine
    try std.testing.expectEqual(V_VERIFIED, judgeWith(32768, 0, 1.0, bps, sub, 0));
    // nothing beats half the submit floor, however few the bytes
    try std.testing.expectEqual(V_IMPOSSIBLE, judgeWith(16, 0, 0.001, bps, sub, 0));
    // the floor for 1 GB at 100 GB/s with 8x allowance is 1.25 ms
    try std.testing.expectApproxEqAbs(@as(f64, 1.25), minPossibleMs(1e9, 0, bps, sub, 0), 1e-9);
}

test "GK3: the compute ceiling refuses more FLOP/s than the peak allows, and only when FLOPs are declared" {
    const bps: f64 = 100e9;
    const sub: f64 = 0.06;
    const peak: f64 = 8.36e12; // the 3050's measured burst, 2026-10-24
    // reg4 at 512 x 384 x 1536: 604 MFLOP. At 0.43 ms it is 1.4 TFLOP/s: possible
    const flops: f64 = 2.0 * 512 * 384 * 1536;
    try std.testing.expectEqual(V_VERIFIED, judgeWith(4e6, flops, 0.43, bps, sub, peak));
    // the same work claimed in 0.04 ms is 15 TFLOP/s: refused by compute
    try std.testing.expectEqual(V_IMPOSSIBLE, judgeWith(4e6, flops, 0.04, bps, sub, peak));
    // the ceiling is peak x PEAK_ALLOW: just under it passes, just over is refused
    const edge = minComputeMs(flops, peak);
    try std.testing.expectApproxEqAbs(flops / (peak * PEAK_ALLOW) * 1000.0, edge, 1e-12);
    try std.testing.expectEqual(V_VERIFIED, judgeWith(4e6, flops, edge * 1.001, bps, sub, peak));
    try std.testing.expectEqual(V_IMPOSSIBLE, judgeWith(4e6, flops, edge * 0.999, bps, sub, peak));
    // undeclared FLOPs: the bus judge of before GK3, whatever the peak
    try std.testing.expectEqual(V_VERIFIED, judgeWith(4e6, 0, 0.04, bps, sub, peak));
    // no peak measured: no compute floor, never a refusal by compute
    try std.testing.expectEqual(@as(f64, 0), minComputeMs(flops, 0));
}

test "GK3: the peak kernel's text is the dense one and its FLOP count follows from it" {
    // 16 chains x 16 unroll = 256 fma lines in the loop body
    try std.testing.expectEqual(@as(usize, 256), std.mem.count(u8, PEAK_WGSL, "= fma("));
    try std.testing.expectApproxEqAbs(@as(f64, 1048576.0 * 16 * 2 * 1024), PEAK_FLOPS, 1);
}

test "KP0: the masked compare wants an unwritten element untouched and a written NaN refused" {
    const ref = [_]f32{ 1, std.math.nan(f32), 3, std.math.nan(f32) };
    const mask = [_]u8{ 1, 0, 1, 1 }; // element 1 unwritten by the guard; element 3 a written NaN
    const good = [_]f32{ 1, std.math.nan(f32), 3, std.math.nan(f32) };
    try std.testing.expectEqual(@as(i64, 3), compareMasked(&ref, &good, &mask, 1e-6).first_bad); // the written NaN
    const wrote = [_]f32{ 1, 2, 3, 5 };
    try std.testing.expectEqual(@as(i64, 1), compareMasked(&ref, &wrote, &mask, 1e-6).first_bad); // wrote the unwritten
    const mask_all = [_]u8{ 1, 1, 1, 1 };
    const a = [_]f32{ 1, 2, 3, 4 };
    const b = [_]f32{ 1, 2, 3.5, 4 };
    try std.testing.expectEqual(@as(i64, 2), compareMasked(&a, &b, &mask_all, 1e-6).first_bad);
    try std.testing.expectEqual(@as(i64, -1), compareMasked(&a, &a, &mask_all, 0).first_bad);
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
