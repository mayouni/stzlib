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
