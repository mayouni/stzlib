// Ring bridge for stz_sound -- the portable sample tier (SN1).
//
// THE 0-BASED / 1-BASED SEAM IS HERE, and it is stated rather than assumed:
// sound.zig is 0-based like every engine module; the Ring surface is 1-based
// like every Ring face. Frame and channel indices are translated in THIS file,
// once, so neither side has to remember. (Plan bootstrap, the traps list:
// "Engine bridges are 0-based; Ring faces are 1-based -- translate at the face,
// and say so.")
const std = @import("std");
const snd = @import("sound.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const rn = R.ring_vm_api_retnumber;
const allocator = std.heap.c_allocator;

fn getStr(p: *anyopaque, n: c_int) []const u8 {
    const ptr = R.ring_vm_api_getstring(p, n);
    const len = R.ring_vm_api_getstringsize(p, n);
    return ptr[0..len];
}

fn id(p: *anyopaque, n: c_int) i64 {
    return @intFromFloat(gn(p, n));
}

/// Ring 1-based -> engine 0-based. A caller passing 0 or less is out of range
/// on the Ring side, and the engine's own bound check catches the rest.
fn idx0(p: *anyopaque, n: c_int) usize {
    const v = gn(p, n);
    if (v < 1) return std.math.maxInt(usize); // guaranteed out of range -> counted refusal
    return @intFromFloat(v - 1);
}

fn ring_IsAvailable(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(snd.isAvailable()));
}

fn ring_LastError(p: *anyopaque) callconv(.c) void {
    const e = snd.lastError();
    R.ring_vm_api_retstring2(p, e.ptr, @intCast(e.len));
}

fn ring_LoadFile(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(snd.loadFile(getStr(p, 1))));
}

fn ring_LoadMemory(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(snd.loadMemory(getStr(p, 1))));
}

fn ring_NewSilent(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(snd.newSilent(
        @intFromFloat(gn(p, 1)),
        @intFromFloat(gn(p, 2)),
        @intFromFloat(gn(p, 3)),
    )));
}

fn ring_Free(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(snd.free(id(p, 1))));
}

fn ring_Frames(p: *anyopaque) callconv(.c) void {
    rn(p, snd.frameCount(id(p, 1)));
}

fn ring_Channels(p: *anyopaque) callconv(.c) void {
    rn(p, snd.channelCount(id(p, 1)));
}

fn ring_Rate(p: *anyopaque) callconv(.c) void {
    rn(p, snd.sampleRate(id(p, 1)));
}

fn ring_Duration(p: *anyopaque) callconv(.c) void {
    rn(p, snd.duration(id(p, 1)));
}

fn ring_Peak(p: *anyopaque) callconv(.c) void {
    rn(p, snd.peak(id(p, 1)));
}

fn ring_Rms(p: *anyopaque) callconv(.c) void {
    rn(p, snd.rms(id(p, 1)));
}

fn ring_Get(p: *anyopaque) callconv(.c) void {
    rn(p, snd.getSample(id(p, 1), idx0(p, 2), @intCast(idx0(p, 3) & 0xffff_ffff)));
}

fn ring_Set(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(snd.setSample(
        id(p, 1),
        idx0(p, 2),
        @intCast(idx0(p, 3) & 0xffff_ffff),
        gn(p, 4),
    )));
}

fn ring_SaveWav(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(snd.saveWav(id(p, 1), getStr(p, 2), @intFromFloat(gn(p, 3)))));
}

fn ring_SaveFlac(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(snd.saveFlac(id(p, 1), getStr(p, 2))));
}

fn ring_Resample(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(snd.resample(
        id(p, 1),
        @intFromFloat(gn(p, 2)),
        @intFromFloat(gn(p, 3)),
    )));
}

fn ring_ToChannels(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(snd.toChannels(id(p, 1), @intFromFloat(gn(p, 2)))));
}

fn ring_LiveCount(p: *anyopaque) callconv(.c) void {
    rn(p, snd.liveCount());
}

fn ring_Counter(p: *anyopaque) callconv(.c) void {
    rn(p, snd.counter(@intFromFloat(gn(p, 1))));
}

fn ring_CountersReset(p: *anyopaque) callconv(.c) void {
    snd.countersReset();
    rn(p, 1);
}

pub const regs = [_]R.Reg{
    .{ .name = "stzenginesoundisavailable", .func = &ring_IsAvailable },
    .{ .name = "stzenginesoundlasterror", .func = &ring_LastError },
    .{ .name = "stzenginesoundloadfile", .func = &ring_LoadFile },
    .{ .name = "stzenginesoundloadmemory", .func = &ring_LoadMemory },
    .{ .name = "stzenginesoundnewsilent", .func = &ring_NewSilent },
    .{ .name = "stzenginesoundfree", .func = &ring_Free },
    .{ .name = "stzenginesoundframes", .func = &ring_Frames },
    .{ .name = "stzenginesoundchannels", .func = &ring_Channels },
    .{ .name = "stzenginesoundrate", .func = &ring_Rate },
    .{ .name = "stzenginesoundduration", .func = &ring_Duration },
    .{ .name = "stzenginesoundpeak", .func = &ring_Peak },
    .{ .name = "stzenginesoundrms", .func = &ring_Rms },
    .{ .name = "stzenginesoundget", .func = &ring_Get },
    .{ .name = "stzenginesoundset", .func = &ring_Set },
    .{ .name = "stzenginesoundsavewav", .func = &ring_SaveWav },
    .{ .name = "stzenginesoundsaveflac", .func = &ring_SaveFlac },
    .{ .name = "stzenginesoundresample", .func = &ring_Resample },
    .{ .name = "stzenginesoundtochannels", .func = &ring_ToChannels },
    .{ .name = "stzenginesoundlivecount", .func = &ring_LiveCount },
    .{ .name = "stzenginesoundcounter", .func = &ring_Counter },
    .{ .name = "stzenginesoundcountersreset", .func = &ring_CountersReset },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
