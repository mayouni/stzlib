//! stz_audiodev -- the PER-OS half of the sound plane. SN1 of SOFTANZA_SOUND_PLAN.md.
//!
//! miniaudio's device backends, and nothing else. WASAPI / DirectSound / WinMM
//! on Windows, ALSA / PulseAudio / JACK on Linux, CoreAudio on macOS -- selected
//! by miniaudio's own #ifdefs, no SDK, no cmake.
//!
//! ── WHY THIS IS ITS OWN DLL ──
//!
//! FACT 3 of the plan, adopted up front from the GR5 windowing lesson rather
//! than rediscovered: device code must not live in a DLL that has to
//! cross-compile. SN0 then measured the shape precisely, and it is BETTER than
//! FACT 3 assumed:
//!
//!     target             stz_sound (portable)   stz_audiodev (this)
//!     x86_64-windows     OK                     OK
//!     x86_64-linux-gnu   OK                     OK   <- GLFW could not do this
//!     x86_64-macos       OK                     FAIL (CoreAudio headers)
//!     aarch64-macos      OK                     FAIL (CoreAudio headers)
//!
//! GLFW's X11 backend needs X11/Xlib.h at COMPILE time. miniaudio's ALSA and
//! PulseAudio backends declare what they need themselves and dlopen the .so at
//! RUNTIME, so this DLL cross-compiles to Linux from a Windows box, which
//! stz_window.dll never could. Only macOS is genuinely per-OS.
//!
//! The split still earns its keep for its original reason: it is what keeps
//! stz_sound.dll buildable for every target regardless of any of this.
//!
//! ── WHAT SN1 DOES AND DOES NOT DO HERE ──
//!
//! SN1 is "the two DLLs and the sample foundation". This file therefore answers
//! only the questions that do not need a running stream: does a device tier
//! exist, which backend, what devices are there, what are their names. **The
//! device SINK -- the callback, the lock-free control queue, the pre-rendered
//! ring buffer, the underrun counter -- is SN3**, and it is deliberately absent
//! rather than half-built, because the plan puts SN2 (prove the samples with no
//! clock) before SN3 (add the clock).
//!
//! ── ABSENCE IS A COUNTED STATE, NOT AN ERROR ──
//!
//! CI has no audio device. A headless server has no audio device. Both must run
//! every offline path. So every entry point here answers a refusal and COUNTS
//! it, and the Ring loader treats a missing DLL as a legitimate state.

const std = @import("std");

const c = @cImport({
    @cDefine("MA_NO_ENGINE", "1");
    @cDefine("MA_NO_RESOURCE_MANAGER", "1");
    @cDefine("MA_NO_NODE_GRAPH", "1");
    @cInclude("miniaudio.h");
});

const alloc = std.heap.c_allocator;

pub const OK: i32 = 0;
pub const FALLBACK: i32 = 1; // no device tier on this machine
pub const BAD_ARG: i32 = 3;

pub const KIND_PLAYBACK: u32 = 0;
pub const KIND_CAPTURE: u32 = 1;

// ---------------------------------------------------------------- counters

pub const CTR_REFUSALS = 0; // sound.device.refusals -- a call with no device
pub const CTR_ENUMERATIONS = 1; // sound.device.enumerations
pub const CTR_CONTEXT_FAILS = 2; // sound.device.context.fails
pub const CTR_COUNT = 3;

var counters: [CTR_COUNT]f64 = @splat(0);

pub fn counter(i: usize) f64 {
    if (i >= CTR_COUNT) return 0;
    return counters[i];
}

pub fn countersReset() void {
    counters = @splat(0);
}

fn refuse(msg: []const u8) void {
    counters[CTR_REFUSALS] += 1;
    setErr(msg);
}

// ---------------------------------------------------------------- errors

var last_error_buf: [512]u8 = @splat(0);
var last_error_len: usize = 0;

fn setErr(msg: []const u8) void {
    const n = @min(msg.len, last_error_buf.len);
    @memcpy(last_error_buf[0..n], msg[0..n]);
    last_error_len = n;
}

pub fn lastError() []const u8 {
    return last_error_buf[0..last_error_len];
}

// ---------------------------------------------------------------- context

var ctx: c.ma_context = undefined;
var ctx_ready = false;
var ctx_failed = false;

/// Initialise the miniaudio context ONCE. A machine with no audio service
/// (a container, a CI runner, an SSH session) fails here, and that is a COUNTED
/// refusal from then on -- never a crash, and never a retry storm.
fn ensureContext() bool {
    if (ctx_ready) return true;
    if (ctx_failed) return false;
    if (c.ma_context_init(null, 0, null, &ctx) != c.MA_SUCCESS) {
        ctx_failed = true;
        counters[CTR_CONTEXT_FAILS] += 1;
        setErr("no audio backend available on this machine");
        return false;
    }
    ctx_ready = true;
    return true;
}

pub fn isAvailable() i32 {
    return if (ensureContext()) 1 else 0;
}

pub fn backendName() []const u8 {
    if (!ensureContext()) return "none";
    return std.mem.span(c.ma_get_backend_name(ctx.backend));
}

// ---------------------------------------------------------------- enumeration

var play_infos: [*c]c.ma_device_info = undefined;
var play_n: c.ma_uint32 = 0;
var cap_infos: [*c]c.ma_device_info = undefined;
var cap_n: c.ma_uint32 = 0;
var enumerated = false;

/// Refresh the device lists. Devices come and go (a USB interface, a headset),
/// so this is explicit rather than cached forever -- a face that wants a fresh
/// list asks for one.
pub fn refresh() i32 {
    if (!ensureContext()) {
        refuse("refresh: no audio backend");
        return FALLBACK;
    }
    if (c.ma_context_get_devices(&ctx, &play_infos, &play_n, &cap_infos, &cap_n) != c.MA_SUCCESS) {
        refuse("refresh: device enumeration failed");
        return FALLBACK;
    }
    counters[CTR_ENUMERATIONS] += 1;
    enumerated = true;
    return OK;
}

fn ensureEnumerated() bool {
    if (enumerated) return true;
    return refresh() == OK;
}

pub fn deviceCount(kind: u32) f64 {
    if (!ensureEnumerated()) return -1;
    return switch (kind) {
        KIND_PLAYBACK => @floatFromInt(play_n),
        KIND_CAPTURE => @floatFromInt(cap_n),
        else => blk: {
            refuse("deviceCount: kind must be 0 (playback) or 1 (capture)");
            break :blk -1;
        },
    };
}

/// miniaudio pads the name field to a fixed width and it is UTF-8 -- SN0 found
/// this machine's devices are literally "Haut-parleurs (Realtek(R) Audio)" and
/// "Reseau de microphones (Intel(R) Smart Sound)". Trim at the NUL and hand back
/// the bytes; never assume a device name is ASCII, and never assume it is short.
pub fn deviceName(kind: u32, index: u32) []const u8 {
    if (!ensureEnumerated()) return "";
    const infos = switch (kind) {
        KIND_PLAYBACK => play_infos,
        KIND_CAPTURE => cap_infos,
        else => {
            refuse("deviceName: kind must be 0 (playback) or 1 (capture)");
            return "";
        },
    };
    const n = if (kind == KIND_PLAYBACK) play_n else cap_n;
    if (index >= n) {
        refuse("deviceName: index out of range");
        return "";
    }
    const raw: []const u8 = &infos[index].name;
    const nul = std.mem.indexOfScalar(u8, raw, 0) orelse raw.len;
    return std.mem.trim(u8, raw[0..nul], " \t");
}

/// The index of the default device for `kind`, or -1 if there is none.
pub fn defaultIndex(kind: u32) f64 {
    if (!ensureEnumerated()) return -1;
    const infos = switch (kind) {
        KIND_PLAYBACK => play_infos,
        KIND_CAPTURE => cap_infos,
        else => {
            refuse("defaultIndex: kind must be 0 (playback) or 1 (capture)");
            return -1;
        },
    };
    const n = if (kind == KIND_PLAYBACK) play_n else cap_n;
    for (0..n) |i| {
        if (infos[i].isDefault != 0) return @floatFromInt(i);
    }
    return -1;
}

pub fn shutdown() void {
    if (ctx_ready) {
        _ = c.ma_context_uninit(&ctx);
        ctx_ready = false;
        enumerated = false;
    }
}

// ---------------------------------------------------------------- tests
//
// Run directly (from libraries/stzlib/engine):
//     zig test src/audiodev.zig -I vendor/miniaudio \
//         vendor/miniaudio/stz_miniaudio_impl.c -lc
//
// These MUST pass on a machine with no audio device, because CI is such a
// machine. Every assertion below is therefore written as "either a device tier
// exists and answers coherently, or it refuses and the refusal is counted" --
// never "a device exists".

const testing = std.testing;

test "absence is a counted refusal, presence is coherent -- and CI gets the first" {
    countersReset();
    const avail = isAvailable();
    try testing.expect(avail == 0 or avail == 1);

    if (avail == 0) {
        // the CI path: every query refuses, and the refusal COUNTS
        const before = counter(CTR_REFUSALS);
        try testing.expectEqual(FALLBACK, refresh());
        try testing.expect(counter(CTR_REFUSALS) > before);
        try testing.expectEqual(@as(f64, -1), deviceCount(KIND_PLAYBACK));
        try testing.expect(counter(CTR_CONTEXT_FAILS) > 0);
        try testing.expect(lastError().len > 0);
        return;
    }

    // the machine-with-audio path
    try testing.expect(backendName().len > 0);
    try testing.expectEqual(OK, refresh());
    try testing.expectEqual(@as(f64, 1), counter(CTR_ENUMERATIONS));
    const np = deviceCount(KIND_PLAYBACK);
    const nc = deviceCount(KIND_CAPTURE);
    try testing.expect(np >= 0);
    try testing.expect(nc >= 0);

    // a name for every device, and the default index is inside the range
    var i: u32 = 0;
    while (i < @as(u32, @intFromFloat(np))) : (i += 1) {
        try testing.expect(deviceName(KIND_PLAYBACK, i).len > 0);
    }
    const d = defaultIndex(KIND_PLAYBACK);
    try testing.expect(d == -1 or (d >= 0 and d < np));
}

test "an out-of-range index refuses and is counted, rather than reading past the list" {
    if (isAvailable() == 0) return; // nothing to index on a device-free box
    _ = refresh();
    countersReset();
    const before = counter(CTR_REFUSALS);
    try testing.expectEqualStrings("", deviceName(KIND_PLAYBACK, 9999));
    try testing.expect(counter(CTR_REFUSALS) > before);
    // and a bad KIND is refused the same way -- the negative sibling of the
    // kind switch, not just of the index bound
    const before2 = counter(CTR_REFUSALS);
    try testing.expectEqual(@as(f64, -1), deviceCount(7));
    try testing.expect(counter(CTR_REFUSALS) > before2);
}

// ---------------------------------------------------------------- the device sink (SN3)
//
// THE CONSUMER SIDE OF THE DEADLINE.
//
// The callback below is the one piece of this plane that the OS calls on its
// own thread, on its own schedule, and that must finish before a deadline it
// does not control. FACT 4's three forbidden habits are therefore absent from
// it by construction, not by care:
//
//   NO ALLOCATION -- it copies into a buffer miniaudio hands it.
//   NO LOCK       -- the ring is single-producer/single-consumer, two atomics.
//   NO RING/VM    -- it never crosses back into the interpreter.
//
// It does exactly two things: drain the ring, and record how long that took.
//
// SN0 MEASURED WHAT THIS HAS TO HOLD. On this machine WASAPI shared mode wakes
// every 10 ms (480 frames) and issues a BURST of callbacks per wake-up, so what
// must fit the period is the burst TOTAL, not one callback. The budget was
// 0.14-0.32% for a plain mix -- the copy below is far cheaper still, because
// the rendering already happened on the other thread.

const sr = @import("soundring.zig");

pub const CTR_CALLBACKS = 3; // sound.device.callbacks
pub const CTR_CALLBACK_US_MAX = 4; // sound.callback.us (worst seen)
pub const CTR_FRAMES_OUT = 5; // sound.device.frames
pub const CTR_SINK_COUNT = 6;

var sink_counters: [3]f64 = @splat(0);

pub fn sinkCounter(i: usize) f64 {
    return switch (i) {
        CTR_CALLBACKS => sink_counters[0],
        CTR_CALLBACK_US_MAX => sink_counters[1],
        CTR_FRAMES_OUT => sink_counters[2],
        else => 0,
    };
}

pub fn sinkCountersReset() void {
    sink_counters = @splat(0);
}

const Sink = struct {
    device: c.ma_device = undefined,
    ring: ?*sr.Ring = null,
    started: bool = false,
    gen: u32 = 1,
    live: bool = false,
    // owned by the callback thread alone
    callbacks: u64 = 0,
    worst_ns: u64 = 0,
    frames_out: u64 = 0,
    timer: ?std.time.Timer = null,
};

var sinks: std.ArrayList(Sink) = .{};

// THE SINK AND SOURCE TABLES MUST NEVER MOVE, and here the reason is doubled.
//
// A live sink hands `&sinks.items[slot]` to miniaudio as pUserData, and
// `&sk.device` IS the ma_device -- which keeps internal pointers back into
// itself. An ArrayList that grows reallocates and frees the old buffer, so
// opening a SECOND device left the FIRST device's callback thread reading
// freed memory on every wake-up. That is a segfault with no message, arriving
// from a thread the caller never sees.
//
// Reserving the table up front and REFUSING past the cap makes every address
// permanent. Eight simultaneous output devices is already more than any
// machine here has; a program that wants a ninth has a design problem, and a
// counted refusal says so in a way a crash does not.
const MAX_SINKS = 8;
const MAX_CAPTURES = 8;

fn sinkId(slot: usize, gen: u32) i64 {
    return (@as(i64, gen) << 32) | @as(i64, @intCast(slot + 1));
}

fn sinkSlotOf(id: i64) ?usize {
    const idx = id & 0xffff_ffff;
    if (idx <= 0 or idx > @as(i64, @intCast(sinks.items.len))) return null;
    const s: usize = @intCast(idx - 1);
    const gen: u32 = @intCast((id >> 32) & 0xffff_ffff);
    if (!sinks.items[s].live or sinks.items[s].gen != gen) return null;
    return s;
}

/// THE AUDIO CALLBACK. Everything it touches was allocated before the device
/// started; everything it calls is a bounded copy or an atomic.
fn sinkCallback(dev: [*c]c.ma_device, out: ?*anyopaque, in: ?*const anyopaque, frame_count: c.ma_uint32) callconv(.c) void {
    _ = in;
    const sk: *Sink = @ptrCast(@alignCast(dev.*.pUserData.?));
    const t0 = if (sk.timer) |*t| @constCast(t).read() else 0;

    const buf: [*]f32 = @ptrCast(@alignCast(out.?));
    if (sk.ring) |r| {
        // Short reads are filled with silence and COUNTED, inside the ring.
        // A stale ring (the producer stopped first) fails `valid()` and yields
        // silence rather than reading freed memory.
        _ = r.popInterleaved(buf, frame_count);
    } else {
        @memset(buf[0 .. frame_count * dev.*.playback.channels], 0);
    }

    sk.callbacks += 1;
    sk.frames_out += frame_count;
    if (sk.timer) |*t| {
        const took = @constCast(t).read() - t0;
        if (took > sk.worst_ns) sk.worst_ns = took;
    }
}

/// Open a playback device that drains the ring at `ring_ptr` -- the address
/// stz_sound.dll handed out for a running stream. An ADDRESS, not an engine
/// handle: the same seam stz_window uses when it hands an HWND to stz_gpu.
///
/// The ring's magic and version are checked here, so a wrong or stale pointer
/// is refused at open time rather than played as noise.
pub fn playbackOpen(ring_ptr: i64, period_frames: u32) i64 {
    if (!ensureContext()) {
        refuse("playbackOpen: no audio backend");
        return 0;
    }
    if (ring_ptr == 0) {
        refuse("playbackOpen: null ring pointer");
        return 0;
    }
    // ALIGNMENT FIRST, and it is not pedantry: this integer came across a DLL
    // boundary from Ring, where any number can be typed. Ring's hot fields are
    // 64-byte aligned, so dereferencing a misaligned address is an immediate
    // panic -- a whole process killed by a typo in a script. Check, refuse,
    // count. (Found by the guard below, which passed a stack array's address.)
    const addr: usize = @intCast(ring_ptr);
    if (addr % @alignOf(sr.Ring) != 0) {
        refuse("playbackOpen: that address is not a ring buffer (misaligned)");
        return 0;
    }
    const ring: *sr.Ring = @ptrFromInt(addr);
    if (!ring.valid()) {
        refuse("playbackOpen: that is not a live ring buffer (wrong magic or version)");
        return 0;
    }

    var slot: usize = sinks.items.len;
    for (sinks.items, 0..) |*sk0, i| {
        if (!sk0.live) {
            slot = i;
            break;
        }
    }
    if (slot == sinks.items.len) {
        if (sinks.items.len >= MAX_SINKS) {
            refuse("playbackOpen: 8 output devices are already open -- close one first");
            return 0;
        }
        // reserve to the cap, so the table never moves under a live callback
        sinks.ensureTotalCapacity(alloc, MAX_SINKS) catch {
            setErr("out of memory growing the sink table");
            return 0;
        };
        sinks.appendAssumeCapacity(.{});
    }
    const sk = &sinks.items[slot];
    const gen = sk.gen;
    sk.* = .{ .ring = ring, .gen = gen, .live = true };
    sk.timer = std.time.Timer.start() catch null;

    var cfg = c.ma_device_config_init(c.ma_device_type_playback);
    cfg.playback.format = c.ma_format_f32;
    cfg.playback.channels = ring.channels;
    cfg.sampleRate = 0; // let the device pick; the graph must already match it
    cfg.periodSizeInFrames = period_frames;
    cfg.dataCallback = sinkCallback;
    cfg.pUserData = sk;

    if (c.ma_device_init(null, &cfg, &sk.device) != c.MA_SUCCESS) {
        sk.* = .{ .gen = gen };
        refuse("playbackOpen: the device refused this configuration");
        return 0;
    }
    return sinkId(slot, gen);
}

pub fn playbackStart(id: i64) i32 {
    const s = sinkSlotOf(id) orelse return BAD_ARG;
    const sk = &sinks.items[s];
    if (c.ma_device_start(&sk.device) != c.MA_SUCCESS) {
        refuse("playbackStart: the device would not start");
        return FALLBACK;
    }
    sk.started = true;
    return OK;
}

pub fn playbackStop(id: i64) i32 {
    const s = sinkSlotOf(id) orelse return BAD_ARG;
    const sk = &sinks.items[s];
    if (sk.started) {
        _ = c.ma_device_stop(&sk.device);
        sk.started = false;
    }
    return OK;
}

/// Close the device. THE ORDER MATTERS: the consumer must stop before the
/// producer frees the ring, or the callback would read freed memory. Closing
/// here also drops our pointer, so a later stream stop cannot surprise us.
pub fn playbackClose(id: i64) i32 {
    const s = sinkSlotOf(id) orelse return BAD_ARG;
    const sk = &sinks.items[s];
    if (sk.started) {
        _ = c.ma_device_stop(&sk.device);
        sk.started = false;
    }
    c.ma_device_uninit(&sk.device);
    sink_counters[0] += @floatFromInt(sk.callbacks);
    sink_counters[2] += @floatFromInt(sk.frames_out);
    const us = @as(f64, @floatFromInt(sk.worst_ns)) / 1000.0;
    if (us > sink_counters[1]) sink_counters[1] = us;
    sk.ring = null;
    sk.live = false;
    sk.gen +%= 1;
    if (sk.gen == 0) sk.gen = 1;
    return OK;
}

pub fn playbackCallbacks(id: i64) f64 {
    const s = sinkSlotOf(id) orelse return -1;
    return @floatFromInt(sinks.items[s].callbacks);
}

pub fn playbackFramesOut(id: i64) f64 {
    const s = sinkSlotOf(id) orelse return -1;
    return @floatFromInt(sinks.items[s].frames_out);
}

/// The worst callback seen, in microseconds. SN0's budget was the WAKE-UP
/// period (10 ms on this machine in shared mode), and a burst of callbacks
/// shares it -- so this is a component of the budget, not the whole of it.
pub fn playbackWorstUs(id: i64) f64 {
    const s = sinkSlotOf(id) orelse return -1;
    return @as(f64, @floatFromInt(sinks.items[s].worst_ns)) / 1000.0;
}

pub fn playbackUnderruns(id: i64) f64 {
    const s = sinkSlotOf(id) orelse return -1;
    const r = sinks.items[s].ring orelse return -1;
    return @floatFromInt(@atomicLoad(u64, &r.underruns, .monotonic));
}

test "the sink refuses a pointer that is not a live ring, rather than playing it" {
    if (isAvailable() == 0) return; // nothing to open on a device-free box
    countersReset();
    const before = counter(CTR_REFUSALS);
    try testing.expectEqual(@as(i64, 0), playbackOpen(0, 256));
    try testing.expect(counter(CTR_REFUSALS) > before);

    // a real address that is NOT a ring: the magic check is what catches it
    var junk: [512]u8 = @splat(0);
    const before2 = counter(CTR_REFUSALS);
    try testing.expectEqual(@as(i64, 0), playbackOpen(@intCast(@intFromPtr(&junk)), 256));
    try testing.expect(counter(CTR_REFUSALS) > before2);
}

// ---------------------------------------------------------------- capture (SN4)
//
// The mirror of the sink. Here the DEVICE is the producer: its callback hands
// us frames it just recorded and we push them into the ring, where the Ring
// thread drains them into a sample buffer.
//
// Same three prohibitions as the playback callback, for the same reason -- it
// runs on a thread the OS owns, to a deadline it sets. It copies and returns.

const CapSink = struct {
    device: c.ma_device = undefined,
    ring: ?*sr.Ring = null,
    started: bool = false,
    gen: u32 = 1,
    live: bool = false,
    callbacks: u64 = 0,
    frames_in: u64 = 0,
};

var caps: std.ArrayList(CapSink) = .{};

fn capSlotOf(id: i64) ?usize {
    const idx = id & 0xffff_ffff;
    if (idx <= 0 or idx > @as(i64, @intCast(caps.items.len))) return null;
    const s: usize = @intCast(idx - 1);
    const gen: u32 = @intCast((id >> 32) & 0xffff_ffff);
    if (!caps.items[s].live or caps.items[s].gen != gen) return null;
    return s;
}

fn captureCallbackRing(dev: [*c]c.ma_device, out: ?*anyopaque, in: ?*const anyopaque, frame_count: c.ma_uint32) callconv(.c) void {
    _ = out;
    const sk: *CapSink = @ptrCast(@alignCast(dev.*.pUserData.?));
    if (in == null) return;
    if (sk.ring) |r| {
        _ = r.pushInterleaved(@ptrCast(@alignCast(in.?)), frame_count);
    }
    sk.callbacks += 1;
    sk.frames_in += frame_count;
}

/// Open a capture device that fills the ring at `ring_ptr`. Same address
/// discipline as playbackOpen: alignment, magic and version are all checked
/// before a single frame is written through it.
pub fn captureOpen(ring_ptr: i64, period_frames: u32) i64 {
    if (!ensureContext()) {
        refuse("captureOpen: no audio backend");
        return 0;
    }
    if (ring_ptr == 0) {
        refuse("captureOpen: null ring pointer");
        return 0;
    }
    const addr: usize = @intCast(ring_ptr);
    if (addr % @alignOf(sr.Ring) != 0) {
        refuse("captureOpen: that address is not a ring buffer (misaligned)");
        return 0;
    }
    const ring: *sr.Ring = @ptrFromInt(addr);
    if (!ring.valid()) {
        refuse("captureOpen: that is not a live ring buffer (wrong magic or version)");
        return 0;
    }

    var slot: usize = caps.items.len;
    for (caps.items, 0..) |*k, i| {
        if (!k.live) {
            slot = i;
            break;
        }
    }
    if (slot == caps.items.len) {
        if (caps.items.len >= MAX_CAPTURES) {
            refuse("captureOpen: 8 input devices are already open -- close one first");
            return 0;
        }
        // same reason as the sinks: a live capture callback holds this address
        caps.ensureTotalCapacity(alloc, MAX_CAPTURES) catch {
            setErr("out of memory growing the capture table");
            return 0;
        };
        caps.appendAssumeCapacity(.{});
    }
    const sk = &caps.items[slot];
    const gen = sk.gen;
    sk.* = .{ .ring = ring, .gen = gen, .live = true };

    var cfg = c.ma_device_config_init(c.ma_device_type_capture);
    cfg.capture.format = c.ma_format_f32;
    cfg.capture.channels = ring.channels;
    cfg.sampleRate = 0; // the device picks; the caller asked for this ring's rate
    cfg.periodSizeInFrames = period_frames;
    cfg.dataCallback = captureCallbackRing;
    cfg.pUserData = sk;

    if (c.ma_device_init(null, &cfg, &sk.device) != c.MA_SUCCESS) {
        sk.* = .{ .gen = gen };
        refuse("captureOpen: the device refused this configuration");
        return 0;
    }
    return sinkId(slot, gen);
}

pub fn captureStart(id: i64) i32 {
    const s = capSlotOf(id) orelse return BAD_ARG;
    const sk = &caps.items[s];
    if (c.ma_device_start(&sk.device) != c.MA_SUCCESS) {
        refuse("captureStart: the device would not start");
        return FALLBACK;
    }
    sk.started = true;
    return OK;
}

pub fn captureStop(id: i64) i32 {
    const s = capSlotOf(id) orelse return BAD_ARG;
    const sk = &caps.items[s];
    if (sk.started) {
        _ = c.ma_device_stop(&sk.device);
        sk.started = false;
    }
    return OK;
}

pub fn captureClose(id: i64) i32 {
    const s = capSlotOf(id) orelse return BAD_ARG;
    const sk = &caps.items[s];
    if (sk.started) {
        _ = c.ma_device_stop(&sk.device);
        sk.started = false;
    }
    c.ma_device_uninit(&sk.device);
    sk.ring = null;
    sk.live = false;
    sk.gen +%= 1;
    if (sk.gen == 0) sk.gen = 1;
    return OK;
}

pub fn captureFramesIn(id: i64) f64 {
    const s = capSlotOf(id) orelse return -1;
    return @floatFromInt(caps.items[s].frames_in);
}

pub fn captureOverruns(id: i64) f64 {
    const s = capSlotOf(id) orelse return -1;
    const r = caps.items[s].ring orelse return -1;
    return @floatFromInt(@atomicLoad(u64, &r.underruns, .monotonic));
}
