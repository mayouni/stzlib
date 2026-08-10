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
const gph = @import("soundgraph.zig");
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

// ---------------------------------------------------------------- graph (SN2)
//
// NODE INDICES ARE 1-BASED ON THIS SIDE, and 0 means "failed" -- the same
// convention buffer ids already use, so a Ring caller has one rule for both:
// zero is never a thing you can use. The engine is 0-based; the +1/-1 lives
// here and nowhere else.

fn nodeIn(p: *anyopaque, n: c_int) i64 {
    const v = gn(p, n);
    if (v < 1) return -1; // out of range for the engine -> counted refusal
    return @as(i64, @intFromFloat(v)) - 1;
}

fn retNode(p: *anyopaque, node: i64) void {
    rn(p, if (node < 0) 0 else @floatFromInt(node + 1));
}

fn ring_GraphNew(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gph.graphNew(
        @intFromFloat(gn(p, 1)),
        @intFromFloat(gn(p, 2)),
        @intFromFloat(gn(p, 3)),
    )));
}

fn ring_GraphFree(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gph.graphFree(id(p, 1))));
}

fn ring_GraphLastError(p: *anyopaque) callconv(.c) void {
    const e = gph.lastError();
    R.ring_vm_api_retstring2(p, e.ptr, @intCast(e.len));
}

fn ring_GraphAddOsc(p: *anyopaque) callconv(.c) void {
    retNode(p, gph.addOsc(id(p, 1), @intFromFloat(gn(p, 2)), gn(p, 3), gn(p, 4)));
}

fn ring_GraphAddSource(p: *anyopaque) callconv(.c) void {
    retNode(p, gph.addSource(id(p, 1), @intFromFloat(gn(p, 2)), gn(p, 3) != 0));
}

fn ring_GraphAddGain(p: *anyopaque) callconv(.c) void {
    retNode(p, gph.addGain(id(p, 1), nodeIn(p, 2), gn(p, 3)));
}

fn ring_GraphAddMix(p: *anyopaque) callconv(.c) void {
    retNode(p, gph.addMix(id(p, 1)));
}

fn ring_GraphMixAdd(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gph.mixAdd(id(p, 1), nodeIn(p, 2), nodeIn(p, 3))));
}

fn ring_GraphAddPan(p: *anyopaque) callconv(.c) void {
    retNode(p, gph.addPan(id(p, 1), nodeIn(p, 2), gn(p, 3)));
}

fn ring_GraphAddFilter(p: *anyopaque) callconv(.c) void {
    retNode(p, gph.addFilter(id(p, 1), nodeIn(p, 2), @intFromFloat(gn(p, 3)), gn(p, 4), gn(p, 5)));
}

fn ring_GraphAddDelay(p: *anyopaque) callconv(.c) void {
    retNode(p, gph.addDelay(id(p, 1), nodeIn(p, 2), gn(p, 3), gn(p, 4), gn(p, 5)));
}

fn ring_GraphAddEnvelope(p: *anyopaque) callconv(.c) void {
    retNode(p, gph.addEnvelope(id(p, 1), nodeIn(p, 2), gn(p, 3), gn(p, 4), gn(p, 5), gn(p, 6), gn(p, 7)));
}

fn ring_GraphSetOutput(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gph.setOutput(id(p, 1), nodeIn(p, 2))));
}

fn ring_GraphPrepare(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gph.prepare(id(p, 1))));
}

fn ring_GraphRewind(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gph.rewind(id(p, 1))));
}

fn ring_GraphRenderBlock(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gph.renderBlock(id(p, 1))));
}

fn ring_GraphToBuffer(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gph.renderToBuffer(id(p, 1), @intFromFloat(gn(p, 2)))));
}

fn ring_GraphToFile(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gph.renderToFile(
        id(p, 1),
        @intFromFloat(gn(p, 2)),
        getStr(p, 3),
        @intFromFloat(gn(p, 4)),
    )));
}

fn ring_GraphNodeCount(p: *anyopaque) callconv(.c) void {
    rn(p, gph.nodeCount(id(p, 1)));
}

fn ring_GraphIsPrepared(p: *anyopaque) callconv(.c) void {
    rn(p, gph.isPrepared(id(p, 1)));
}

fn ring_GraphCounter(p: *anyopaque) callconv(.c) void {
    rn(p, gph.counter(@intFromFloat(gn(p, 1))));
}

fn ring_GraphCountersReset(p: *anyopaque) callconv(.c) void {
    gph.countersReset();
    rn(p, 1);
}

/// The witness for "Render allocates nothing". A guard reads it either side of
/// a render and asserts it did not move.
fn ring_GraphAllocCount(p: *anyopaque) callconv(.c) void {
    rn(p, gph.allocCount());
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

    // the graph (SN2)
    .{ .name = "stzenginesoundgraphnew", .func = &ring_GraphNew },
    .{ .name = "stzenginesoundgraphfree", .func = &ring_GraphFree },
    .{ .name = "stzenginesoundgraphlasterror", .func = &ring_GraphLastError },
    .{ .name = "stzenginesoundgraphaddosc", .func = &ring_GraphAddOsc },
    .{ .name = "stzenginesoundgraphaddsource", .func = &ring_GraphAddSource },
    .{ .name = "stzenginesoundgraphaddgain", .func = &ring_GraphAddGain },
    .{ .name = "stzenginesoundgraphaddmix", .func = &ring_GraphAddMix },
    .{ .name = "stzenginesoundgraphmixadd", .func = &ring_GraphMixAdd },
    .{ .name = "stzenginesoundgraphaddpan", .func = &ring_GraphAddPan },
    .{ .name = "stzenginesoundgraphaddfilter", .func = &ring_GraphAddFilter },
    .{ .name = "stzenginesoundgraphadddelay", .func = &ring_GraphAddDelay },
    .{ .name = "stzenginesoundgraphaddenvelope", .func = &ring_GraphAddEnvelope },
    .{ .name = "stzenginesoundgraphsetoutput", .func = &ring_GraphSetOutput },
    .{ .name = "stzenginesoundgraphprepare", .func = &ring_GraphPrepare },
    .{ .name = "stzenginesoundgraphrewind", .func = &ring_GraphRewind },
    .{ .name = "stzenginesoundgraphrenderblock", .func = &ring_GraphRenderBlock },
    .{ .name = "stzenginesoundgraphtobuffer", .func = &ring_GraphToBuffer },
    .{ .name = "stzenginesoundgraphtofile", .func = &ring_GraphToFile },
    .{ .name = "stzenginesoundgraphnodecount", .func = &ring_GraphNodeCount },
    .{ .name = "stzenginesoundgraphisprepared", .func = &ring_GraphIsPrepared },
    .{ .name = "stzenginesoundgraphcounter", .func = &ring_GraphCounter },
    .{ .name = "stzenginesoundgraphcountersreset", .func = &ring_GraphCountersReset },
    .{ .name = "stzenginesoundgraphalloccount", .func = &ring_GraphAllocCount },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
