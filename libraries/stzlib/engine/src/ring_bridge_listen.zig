//! ring_bridge_listen.zig -- the Ring surface of recognition (VC3).
//!
//! Lives in stz_voice.dll beside the synthesis bridge: both are the same per-OS
//! speech service, and a caller that has one almost always wants the other.
//!
//! CLOSED GRAMMAR ONLY, because the kill criterion said so. See listen.zig's
//! header for the measurement that decided it -- free dictation 66.7% exact
//! against closed grammar's 100%, on audio this plane synthesised itself.

const std = @import("std");
const R = @import("ring_api.zig");
const ls = @import("listen.zig");

fn gn(p: *anyopaque, i: c_int) f64 {
    return R.ring_vm_api_getnumber(p, i);
}
fn id(p: *anyopaque, i: c_int) i64 {
    return @intFromFloat(gn(p, i));
}
fn rn(p: *anyopaque, v: f64) void {
    R.ring_vm_api_retnumber(p, v);
}
fn gs(p: *anyopaque, i: c_int) []const u8 {
    const ptr = R.ring_vm_api_getstring(p, i);
    const len = R.ring_vm_api_getstringsize(p, i);
    return ptr[0..len];
}
fn rs(p: *anyopaque, s: []const u8) void {
    R.ring_vm_api_retstring2(p, s.ptr, @intCast(s.len));
}

fn ring_IsAvailable(p: *anyopaque) callconv(.c) void {
    rn(p, if (ls.isAvailable()) 1 else 0);
}
fn ring_LastError(p: *anyopaque) callconv(.c) void {
    rs(p, ls.lastError());
}
fn ring_Open(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ls.open()));
}
fn ring_Free(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ls.free(id(p, 1))));
}
fn ring_LiveCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ls.liveCount()));
}

// The grammar arrives as one newline-separated block rather than a Ring list,
// because a list would need a second crossing per phrase and the whole grammar
// is set at once anyway.
fn ring_SetPhrases(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ls.setPhrases(id(p, 1), gs(p, 2))));
}
fn ring_PhraseCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ls.phraseCount(id(p, 1))));
}

// A WHOLE WAV, as a Ring string -- the same carrier the voice tier hands back,
// so a round trip needs no conversion in between.
fn ring_ListenToWav(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ls.listenToWav(id(p, 1), gs(p, 2))));
}
fn ring_ListenToMicrophone(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ls.listenToMicrophone(id(p, 1), id(p, 2))));
}

fn ring_LastText(p: *anyopaque) callconv(.c) void {
    rs(p, ls.lastText(id(p, 1)));
}

// CONFIDENCE IS A SEPARATE CALL ON PURPOSE, so it cannot be skipped by
// accident: a recognised string without its confidence is a guess wearing a
// fact's clothes.
fn ring_LastConfidence(p: *anyopaque) callconv(.c) void {
    rn(p, ls.lastConfidence(id(p, 1)));
}

fn ring_InstalledCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ls.installedCount()));
}
fn ring_InstalledName(p: *anyopaque) callconv(.c) void {
    rs(p, ls.installedName(id(p, 1) - 1));
}
fn ring_InstalledLanguage(p: *anyopaque) callconv(.c) void {
    rs(p, ls.installedLanguage(id(p, 1) - 1));
}
fn ring_Counter(p: *anyopaque) callconv(.c) void {
    rn(p, ls.counter(@intFromFloat(gn(p, 1))));
}
fn ring_CountersReset(p: *anyopaque) callconv(.c) void {
    ls.countersReset();
    rn(p, 0);
}

pub const regs = [_]R.Reg{
    .{ .name = "stzenginelistenisavailable", .func = &ring_IsAvailable },
    .{ .name = "stzenginelistenlasterror", .func = &ring_LastError },
    .{ .name = "stzenginelistenopen", .func = &ring_Open },
    .{ .name = "stzenginelistenfree", .func = &ring_Free },
    .{ .name = "stzenginelistenlivecount", .func = &ring_LiveCount },
    .{ .name = "stzenginelistensetphrases", .func = &ring_SetPhrases },
    .{ .name = "stzenginelistenphrasecount", .func = &ring_PhraseCount },
    .{ .name = "stzenginelistentowav", .func = &ring_ListenToWav },
    .{ .name = "stzenginelistentomicrophone", .func = &ring_ListenToMicrophone },
    .{ .name = "stzenginelistenlasttext", .func = &ring_LastText },
    .{ .name = "stzenginelistenlastconfidence", .func = &ring_LastConfidence },
    .{ .name = "stzenginelisteninstalledcount", .func = &ring_InstalledCount },
    .{ .name = "stzenginelisteninstalledname", .func = &ring_InstalledName },
    .{ .name = "stzenginelisteninstalledlanguage", .func = &ring_InstalledLanguage },
    .{ .name = "stzenginelistencounter", .func = &ring_Counter },
    .{ .name = "stzenginelistencountersreset", .func = &ring_CountersReset },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
