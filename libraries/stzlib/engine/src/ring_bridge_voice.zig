//! ring_bridge_voice.zig -- the Ring surface of stz_voice.dll (VC1).
//!
//! The one thing worth reading here is how a voice crosses INTO the sound
//! plane. `voice.zig` produces a complete WAV in memory; `stz_sound.dll` owns
//! the sample-buffer table. A handle from one DLL means nothing in the other, so
//! BYTES cross and a handle never does -- the same discipline SN3 used for the
//! lock-free ring.
//!
//! The bytes cross as a **Ring string**, which is length-delimited and
//! byte-safe:
//!
//!     StzEngineSoundLoadMemory(StzEngineVoiceLastBytes(nV))   // -> a stzSound
//!
//! Two calls, no temporary file, and no new coupling between the two DLLs. See
//! `ring_LastBytes` for why this is a string and not the address it was first
//! written as.

const std = @import("std");
const R = @import("ring_api.zig");
const vc = @import("voice.zig");

fn gn(p: *anyopaque, i: c_int) f64 {
    return R.ring_vm_api_getnumber(p, i);
}

fn id(p: *anyopaque, i: c_int) i64 {
    return @intFromFloat(gn(p, i));
}

fn rn(p: *anyopaque, v: f64) void {
    R.ring_vm_api_retnumber(p, v);
}

// LENGTH-DELIMITED, not NUL-terminated: Ring strings carry their own size, and
// a phrase to be spoken may legitimately contain anything. The sound bridge
// reads them the same way.
fn gs(p: *anyopaque, i: c_int) []const u8 {
    const ptr = R.ring_vm_api_getstring(p, i);
    const len = R.ring_vm_api_getstringsize(p, i);
    return ptr[0..len];
}

fn rs(p: *anyopaque, s: []const u8) void {
    R.ring_vm_api_retstring2(p, s.ptr, @intCast(s.len));
}

// ---------------------------------------------------------------- lifecycle

fn ring_IsAvailable(p: *anyopaque) callconv(.c) void {
    rn(p, if (vc.isAvailable()) 1 else 0);
}

fn ring_LastError(p: *anyopaque) callconv(.c) void {
    rs(p, vc.lastError());
}

fn ring_Open(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(vc.open()));
}

fn ring_Free(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(vc.free(id(p, 1))));
}

fn ring_LiveCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(vc.liveCount()));
}

// ---------------------------------------------------------------- speaking

fn ring_Speak(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(vc.speak(id(p, 1), gs(p, 2), false)));
}

fn ring_SpeakSsml(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(vc.speak(id(p, 1), gs(p, 2), true)));
}

// THE HANDOFF, and it is a RING STRING rather than an address.
//
// The first cut returned the address and the length and expected the caller to
// pass both to LoadMemory. That was wrong twice over: LoadMemory takes a Ring
// string, not a pointer -- so the call crashed the interpreter -- and putting a
// raw address into user code invites exactly that. A Ring string is
// length-delimited and byte-safe, which makes it the language's own carrier for
// a block of bytes, so the whole DLL boundary is crossed with:
//
//     StzEngineSoundLoadMemory(StzEngineVoiceLastBytes(nV))
//
// The cost is one copy of a few hundred kilobytes; the benefit is that no
// address ever appears in a script.
fn ring_LastBytes(p: *anyopaque) callconv(.c) void {
    const ptr = vc.lastBytesPtr(id(p, 1));
    const len: usize = @intCast(vc.lastBytesLen(id(p, 1)));
    if (ptr == 0 or len == 0) {
        rs(p, &.{});
        return;
    }
    rs(p, @as([*]const u8, @ptrFromInt(ptr))[0..len]);
}

// Kept for a diagnostic that wants to see the address, and NOT the path a
// caller should use -- see the note above.
fn ring_LastBytesPtr(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(vc.lastBytesPtr(id(p, 1))));
}

fn ring_LastBytesLen(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(vc.lastBytesLen(id(p, 1))));
}

// ---------------------------------------------------------------- the voices

fn ring_InstalledCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(vc.installedCount()));
}

// 1-BASED at the face, 0-based in the engine -- translated here, and said so,
// per the plane's own trap list.
fn ring_InstalledName(p: *anyopaque) callconv(.c) void {
    rs(p, vc.installedName(id(p, 1) - 1));
}

fn ring_SelectVoice(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(vc.selectVoice(id(p, 1), id(p, 2) - 1)));
}

// ---------------------------------------------------------------- prosody

fn ring_SetRate(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(vc.setRate(id(p, 1), id(p, 2))));
}

fn ring_SetVolume(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(vc.setVolume(id(p, 1), id(p, 2))));
}

// ---------------------------------------------------------------- format

fn ring_SampleRate(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(vc.sampleRate()));
}

fn ring_ChannelCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(vc.channelCount()));
}

fn ring_BitsPerSample(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(vc.bitsPerSample()));
}

// ---------------------------------------------------------------- counters

fn ring_Counter(p: *anyopaque) callconv(.c) void {
    rn(p, vc.counter(@intFromFloat(gn(p, 1))));
}

fn ring_CountersReset(p: *anyopaque) callconv(.c) void {
    vc.countersReset();
    rn(p, 0);
}

const regs = [_]R.Reg{
    .{ .name = "stzenginevoiceisavailable", .func = &ring_IsAvailable },
    .{ .name = "stzenginevoicelasterror", .func = &ring_LastError },
    .{ .name = "stzenginevoiceopen", .func = &ring_Open },
    .{ .name = "stzenginevoicefree", .func = &ring_Free },
    .{ .name = "stzenginevoicelivecount", .func = &ring_LiveCount },
    .{ .name = "stzenginevoicespeak", .func = &ring_Speak },
    .{ .name = "stzenginevoicespeakssml", .func = &ring_SpeakSsml },
    .{ .name = "stzenginevoicelastbytes", .func = &ring_LastBytes },
    .{ .name = "stzenginevoicelastbytesptr", .func = &ring_LastBytesPtr },
    .{ .name = "stzenginevoicelastbyteslen", .func = &ring_LastBytesLen },
    .{ .name = "stzenginevoiceinstalledcount", .func = &ring_InstalledCount },
    .{ .name = "stzenginevoiceinstalledname", .func = &ring_InstalledName },
    .{ .name = "stzenginevoiceselectvoice", .func = &ring_SelectVoice },
    .{ .name = "stzenginevoicesetrate", .func = &ring_SetRate },
    .{ .name = "stzenginevoicesetvolume", .func = &ring_SetVolume },
    .{ .name = "stzenginevoicesamplerate", .func = &ring_SampleRate },
    .{ .name = "stzenginevoicechannelcount", .func = &ring_ChannelCount },
    .{ .name = "stzenginevoicebitspersample", .func = &ring_BitsPerSample },
    .{ .name = "stzenginevoicecounter", .func = &ring_Counter },
    .{ .name = "stzenginevoicecountersreset", .func = &ring_CountersReset },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
