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
const ana = @import("soundanalysis.zig");
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

// The symmetric half of LoadMemory: a sound OUT as WAV bytes, so a buffer can
// cross to another tier without a temporary file.
fn ring_ToWavBytes(p: *anyopaque) callconv(.c) void {
    const n = snd.saveWavToMemory(id(p, 1));
    const ptr = snd.wavMemoryPtr();
    if (n <= 0 or ptr == 0) {
        R.ring_vm_api_retstring2(p, "", 0);
        return;
    }
    R.ring_vm_api_retstring2(p, @ptrFromInt(ptr), @intCast(n));
}

fn ring_LoadMemory(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(snd.loadMemory(getStr(p, 1))));
}

// SS5: the earcon vocabulary, rendered by the seam both tiers share. The Ring
// face used to build these motifs itself, in Ring; the browser could not reach
// that code, and a JavaScript copy would have been a SECOND author of what
// :Danger sounds like.
fn ring_EarconOf(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(snd.earconOf(
        @intFromFloat(gn(p, 1)),
        @intFromFloat(gn(p, 2)),
    )));
}

fn ring_EarconFrames(p: *anyopaque) callconv(.c) void {
    rn(p, snd.earconFrames(@intFromFloat(gn(p, 1)), @intFromFloat(gn(p, 2))));
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

fn ring_GraphAddEnvelopeAt(p: *anyopaque) callconv(.c) void {
    retNode(p, gph.addEnvelopeAt(id(p, 1), nodeIn(p, 2), gn(p, 3), gn(p, 4), gn(p, 5), gn(p, 6), gn(p, 7), gn(p, 8)));
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

// SN6: restart one voice without disturbing the rest of the graph. Safe to
// call while the producer thread is rendering -- the engine takes the request
// as an atomic flag and acts on it at the top of the next block.
// nodeIn, NOT a raw number: node handles are 1-based on the Ring side and
// 0-based in the engine. The first draft passed the raw value, so "retrigger
// A's envelope" silently retriggered B's OSCILLATOR -- a real node, in range,
// whose reset happens to be inaudible. It refused nothing and did nothing,
// which is the failure mode an off-by-one on a handle always has.
fn ring_GraphTriggerNode(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gph.triggerNode(id(p, 1), nodeIn(p, 2))));
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


// ---------------------------------------------------------------- stream (SN3)

fn ring_StreamStart(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gph.streamStart(id(p, 1), @intFromFloat(gn(p, 2)))));
}

fn ring_StreamStop(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gph.streamStop(id(p, 1))));
}

/// The ring's ADDRESS, to hand to the device tier in the other DLL. A number,
/// not an engine handle -- the same seam stz_window uses for an HWND.
fn ring_StreamRingPtr(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gph.streamRingPtr(id(p, 1))));
}

fn ring_StreamUnderruns(p: *anyopaque) callconv(.c) void {
    rn(p, gph.streamUnderruns(id(p, 1)));
}

fn ring_StreamUnderrunEvents(p: *anyopaque) callconv(.c) void {
    rn(p, gph.streamUnderrunEvents(id(p, 1)));
}

fn ring_StreamFramesWritten(p: *anyopaque) callconv(.c) void {
    rn(p, gph.streamFramesWritten(id(p, 1)));
}

fn ring_StreamFramesRead(p: *anyopaque) callconv(.c) void {
    rn(p, gph.streamFramesRead(id(p, 1)));
}

fn ring_StreamReadable(p: *anyopaque) callconv(.c) void {
    rn(p, gph.streamReadable(id(p, 1)));
}

/// Drain on THIS thread -- the device-free consumer that lets a CI box with no
/// sound card exercise the whole real-time path.
fn ring_StreamDrain(p: *anyopaque) callconv(.c) void {
    rn(p, gph.streamDrain(id(p, 1), @intFromFloat(gn(p, 2)), id(p, 3)));
}

fn ring_StreamCounter(p: *anyopaque) callconv(.c) void {
    rn(p, gph.streamCounter(@intFromFloat(gn(p, 1))));
}

fn ring_GraphSetGain(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gph.setGain(id(p, 1), nodeIn(p, 2), gn(p, 3), gn(p, 4))));
}

fn ring_GraphCurrentGain(p: *anyopaque) callconv(.c) void {
    rn(p, gph.currentGain(id(p, 1), nodeIn(p, 2)));
}

// ---------------------------------------------------------------- recorder (SN4)

fn ring_RecorderNew(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(snd.recorderNew(
        @intFromFloat(gn(p, 1)),
        @intFromFloat(gn(p, 2)),
        gn(p, 3),
    )));
}

fn ring_RecorderRingPtr(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(snd.recorderRingPtr(id(p, 1))));
}

fn ring_RecorderDrain(p: *anyopaque) callconv(.c) void {
    rn(p, snd.recorderDrain(id(p, 1)));
}

fn ring_RecorderFrames(p: *anyopaque) callconv(.c) void {
    rn(p, snd.recorderFrames(id(p, 1)));
}

fn ring_RecorderFinish(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(snd.recorderFinish(id(p, 1))));
}

fn ring_RecorderFree(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(snd.recorderFree(id(p, 1))));
}

// ---------------------------------------------------------------- analysis (SN5)
//
// Analysis results are GRIDS: rows x cols of f64, gen-keyed like every other
// handle. A spectrum is one row, a spectrogram is many, onset times are one.
// Rows and columns are 1-BASED here and 0-based in the engine.

fn ring_Spectrum(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ana.spectrum(
        id(p, 1),
        @intCast(idx0(p, 2) & 0xffff_ffff),
        idx0(p, 3),
        @intFromFloat(gn(p, 4)),
    )));
}

fn ring_Spectrogram(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ana.spectrogram(
        id(p, 1),
        @intCast(idx0(p, 2) & 0xffff_ffff),
        @intFromFloat(gn(p, 3)),
        @intFromFloat(gn(p, 4)),
        @intFromFloat(gn(p, 5)),
    )));
}

fn ring_DominantFrequency(p: *anyopaque) callconv(.c) void {
    rn(p, ana.dominantFrequency(id(p, 1), @intCast(idx0(p, 2) & 0xffff_ffff), @intFromFloat(gn(p, 3))));
}

fn ring_Onsets(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ana.onsets(
        id(p, 1),
        @intCast(idx0(p, 2) & 0xffff_ffff),
        @intFromFloat(gn(p, 3)),
        @intFromFloat(gn(p, 4)),
        gn(p, 5),
    )));
}

fn ring_Tempo(p: *anyopaque) callconv(.c) void {
    rn(p, ana.tempo(id(p, 1), @intCast(idx0(p, 2) & 0xffff_ffff)));
}

fn ring_Loudness(p: *anyopaque) callconv(.c) void {
    rn(p, ana.loudness(id(p, 1)));
}

// SS2: the loudness the audibility floor binds to. Integrated LUFS refuses
// anything shorter than a 400 ms block, which is every earcon -- see the
// sound plan's S.4.
fn ring_LoudnessMomentary(p: *anyopaque) callconv(.c) void {
    rn(p, ana.loudnessMomentary(id(p, 1)));
}

fn ring_LoudnessShortTerm(p: *anyopaque) callconv(.c) void {
    rn(p, ana.loudnessShortTerm(id(p, 1)));
}

fn ring_LoudnessOfSupport(p: *anyopaque) callconv(.c) void {
    rn(p, ana.loudnessOfSupport(id(p, 1)));
}

// The method, so a number never travels without it.
fn ring_LoudnessMetricName(p: *anyopaque) callconv(.c) void {
    const n = ana.loudnessMetricName();
    R.ring_vm_api_retstring2(p, n.ptr, @intCast(n.len));
}

fn ring_GridRows(p: *anyopaque) callconv(.c) void {
    rn(p, ana.gridRows(id(p, 1)));
}

fn ring_GridCols(p: *anyopaque) callconv(.c) void {
    rn(p, ana.gridCols(id(p, 1)));
}

fn ring_GridXStep(p: *anyopaque) callconv(.c) void {
    rn(p, ana.gridXStep(id(p, 1)));
}

fn ring_GridYStep(p: *anyopaque) callconv(.c) void {
    rn(p, ana.gridYStep(id(p, 1)));
}

fn ring_GridAt(p: *anyopaque) callconv(.c) void {
    rn(p, ana.gridAt(id(p, 1), idx0(p, 2), idx0(p, 3)));
}

fn ring_GridMax(p: *anyopaque) callconv(.c) void {
    rn(p, ana.gridMax(id(p, 1)));
}

fn ring_GridArgMaxInRow(p: *anyopaque) callconv(.c) void {
    // 0-based column out of the engine -> 1-based for Ring; -1 stays -1
    const v = ana.gridArgMaxInRow(id(p, 1), idx0(p, 2));
    rn(p, if (v < 0) -1 else v + 1);
}

fn ring_GridFree(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ana.gridFree(id(p, 1))));
}

fn ring_AnalysisCounter(p: *anyopaque) callconv(.c) void {
    rn(p, ana.counter(@intFromFloat(gn(p, 1))));
}

fn ring_AnalysisLastError(p: *anyopaque) callconv(.c) void {
    const e = ana.lastError();
    R.ring_vm_api_retstring2(p, e.ptr, @intCast(e.len));
}

pub const regs = [_]R.Reg{
    .{ .name = "stzenginesoundisavailable", .func = &ring_IsAvailable },
    .{ .name = "stzenginesoundlasterror", .func = &ring_LastError },
    .{ .name = "stzenginesoundloadfile", .func = &ring_LoadFile },
    .{ .name = "stzenginesoundloadmemory", .func = &ring_LoadMemory },
    .{ .name = "stzenginesoundtowavbytes", .func = &ring_ToWavBytes },
    .{ .name = "stzenginesoundnewsilent", .func = &ring_NewSilent },
    .{ .name = "stzenginesoundearconof", .func = &ring_EarconOf },
    .{ .name = "stzenginesoundearconframes", .func = &ring_EarconFrames },
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
    .{ .name = "stzenginesoundgraphaddenvelopeat", .func = &ring_GraphAddEnvelopeAt },
    .{ .name = "stzenginesoundgraphsetoutput", .func = &ring_GraphSetOutput },
    .{ .name = "stzenginesoundgraphprepare", .func = &ring_GraphPrepare },
    .{ .name = "stzenginesoundgraphrewind", .func = &ring_GraphRewind },
    .{ .name = "stzenginesoundgraphtriggernode", .func = &ring_GraphTriggerNode },
    .{ .name = "stzenginesoundgraphrenderblock", .func = &ring_GraphRenderBlock },
    .{ .name = "stzenginesoundgraphtobuffer", .func = &ring_GraphToBuffer },
    .{ .name = "stzenginesoundgraphtofile", .func = &ring_GraphToFile },
    .{ .name = "stzenginesoundgraphnodecount", .func = &ring_GraphNodeCount },
    .{ .name = "stzenginesoundgraphisprepared", .func = &ring_GraphIsPrepared },
    .{ .name = "stzenginesoundgraphcounter", .func = &ring_GraphCounter },
    .{ .name = "stzenginesoundgraphcountersreset", .func = &ring_GraphCountersReset },
    .{ .name = "stzenginesoundgraphalloccount", .func = &ring_GraphAllocCount },

    // the real-time tier (SN3)
    .{ .name = "stzenginesoundstreamstart", .func = &ring_StreamStart },
    .{ .name = "stzenginesoundstreamstop", .func = &ring_StreamStop },
    .{ .name = "stzenginesoundstreamringptr", .func = &ring_StreamRingPtr },
    .{ .name = "stzenginesoundstreamunderruns", .func = &ring_StreamUnderruns },
    .{ .name = "stzenginesoundstreamunderrunevents", .func = &ring_StreamUnderrunEvents },
    .{ .name = "stzenginesoundstreamframeswritten", .func = &ring_StreamFramesWritten },
    .{ .name = "stzenginesoundstreamframesread", .func = &ring_StreamFramesRead },
    .{ .name = "stzenginesoundstreamreadable", .func = &ring_StreamReadable },
    .{ .name = "stzenginesoundstreamdrain", .func = &ring_StreamDrain },
    .{ .name = "stzenginesoundstreamcounter", .func = &ring_StreamCounter },
    .{ .name = "stzenginesoundgraphsetgain", .func = &ring_GraphSetGain },
    .{ .name = "stzenginesoundgraphcurrentgain", .func = &ring_GraphCurrentGain },

    // the recorder (SN4)
    .{ .name = "stzenginesoundrecordernew", .func = &ring_RecorderNew },
    .{ .name = "stzenginesoundrecorderringptr", .func = &ring_RecorderRingPtr },
    .{ .name = "stzenginesoundrecorderdrain", .func = &ring_RecorderDrain },
    .{ .name = "stzenginesoundrecorderframes", .func = &ring_RecorderFrames },
    .{ .name = "stzenginesoundrecorderfinish", .func = &ring_RecorderFinish },
    .{ .name = "stzenginesoundrecorderfree", .func = &ring_RecorderFree },

    // analysis (SN5)
    .{ .name = "stzenginesoundspectrum", .func = &ring_Spectrum },
    .{ .name = "stzenginesoundspectrogram", .func = &ring_Spectrogram },
    .{ .name = "stzenginesounddominantfrequency", .func = &ring_DominantFrequency },
    .{ .name = "stzenginesoundonsets", .func = &ring_Onsets },
    .{ .name = "stzenginesoundtempo", .func = &ring_Tempo },
    .{ .name = "stzenginesoundloudness", .func = &ring_Loudness },
    .{ .name = "stzenginesoundloudnessmomentary", .func = &ring_LoudnessMomentary },
    .{ .name = "stzenginesoundloudnessshortterm", .func = &ring_LoudnessShortTerm },
    .{ .name = "stzenginesoundloudnessofsupport", .func = &ring_LoudnessOfSupport },
    .{ .name = "stzenginesoundloudnessmetricname", .func = &ring_LoudnessMetricName },
    .{ .name = "stzenginesoundgridrows", .func = &ring_GridRows },
    .{ .name = "stzenginesoundgridcols", .func = &ring_GridCols },
    .{ .name = "stzenginesoundgridxstep", .func = &ring_GridXStep },
    .{ .name = "stzenginesoundgridystep", .func = &ring_GridYStep },
    .{ .name = "stzenginesoundgridat", .func = &ring_GridAt },
    .{ .name = "stzenginesoundgridmax", .func = &ring_GridMax },
    .{ .name = "stzenginesoundgridargmaxinrow", .func = &ring_GridArgMaxInRow },
    .{ .name = "stzenginesoundgridfree", .func = &ring_GridFree },
    .{ .name = "stzenginesoundanalysiscounter", .func = &ring_AnalysisCounter },
    .{ .name = "stzenginesoundanalysislasterror", .func = &ring_AnalysisLastError },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
