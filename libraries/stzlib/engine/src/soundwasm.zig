//! soundwasm.zig -- the sound graph, for a target with no libc and no device.
//!
//! ── WHAT THIS IS, AND WHAT IT IS NOT ────────────────────────────────────────
//!
//! SN6's fourth sink: the browser. The native tier (soundgraph.zig) owns a
//! handle table, a decoder, a lock-free ring and a device thread, and none of
//! those exist here. A browser gives you exactly one thing -- an AudioWorklet
//! asking "give me 128 frames" on the audio thread -- so that is the whole
//! shape of this module: build a graph, then fill a block on demand.
//!
//! NO ALLOCATOR. Every graph lives in a fixed static array in linear memory,
//! sized at comptime. `std.heap.c_allocator` is what made soundgraph.zig
//! unbuildable for freestanding wasm32 in the first place, and reaching for a
//! wasm allocator here would import the same problem wearing a different coat.
//! A bounded record COUNTS what it drops (working discipline, rule 4), so
//! asking for a node past the cap is a counted refusal rather than a growth.
//!
//! NO SAMPLE BUFFERS, therefore no source nodes. The native tier's KIND_SOURCE
//! plays a decoded file from the handle table; a browser already has
//! `decodeAudioData` and its own buffers, and duplicating a decoder into wasm to
//! avoid using the one the platform ships would be absurd. So this tier
//! SYNTHESISES: oscillators, gain, mix, pan, filter, delay, envelope. Stated
//! rather than discovered.
//!
//! ── THE ARITHMETIC IS NOT REDEFINED HERE ────────────────────────────────────
//!
//! Every sample comes from sounddsp.zig, which the native tier also calls. That
//! is the entire reason sounddsp.zig exists: two tiers, one definition of what a
//! sawtooth is. A guard renders the same graph through both and asserts the
//! blocks are bit-identical -- which is only meaningful because neither tier
//! owns a second copy of the oscillator.
//!
//! ── THE ABI ─────────────────────────────────────────────────────────────────
//!
//! Scalars by value; the audio block is read by JS straight out of linear memory
//! at `snd_block_ptr()`, INTERLEAVED f32, `frames * channels` long -- which is
//! the layout an AudioWorklet wants, so nothing shuffles on the JS side.
//!
//! ── THE LATENCY WARNING THAT BELONGS ON THIS FILE ───────────────────────────
//!
//! The native path measured 329 ms of ring sitting ahead of the device, and the
//! plan's S.5 records why that puts a sound outside Rule 18's 100 ms. This tier
//! has NO ring at all: the worklet asks, we fill, it plays. A browser's own
//! output latency (`AudioContext.outputLatency`) is typically 10-30 ms. So the
//! browser sink is the LOWER-latency path of the two, and that is a genuine
//! finding rather than a consolation -- it means an eyes-free surface has a
//! better chance of a lawful acknowledgement in a browser than on native
//! Windows shared-mode WASAPI. Measure it there before believing it.

const std = @import("std");
const dsp = @import("sounddsp.zig");

// ── bounds, all comptime ────────────────────────────────────────────────────

// ── THE SIZES, AND WHY THEY ARE SMALL ───────────────────────────────────────
//
// wasm-ld emits INITIALISED static data as real bytes in the module. The first
// cut gave every node its own one-second delay line and a 1024-frame bus, and
// produced a **26 MB stz.wasm** -- unshippable to a browser, and the kind of
// mistake that is invisible until you look at the artefact. Two causes, both
// fixed here:
//
//   1. `Node` has non-zero defaults (hz 440, amp 1.0, gate maxInt), so an array
//      of them is .data rather than .bss and every byte is written into the
//      module. The arrays below are `undefined` and initialised at RUNTIME.
//   2. A per-node delay line at 48000 frames x 64 nodes x 2 channels is 24 MB
//      on its own. Delay lines now come from a SHARED pool of four, because a
//      graph with five echoes is not the case worth 24 MB.
// MEASURED, because the first two guesses were both wrong: a static array's
// size is DOWNLOAD size here. `--import-memory` means wasm-ld cannot assume the
// memory arrives zeroed, so even `undefined` statics are emitted as real bytes.
// The sizes below were chosen against the artefact:
//
//   per-node 1 s delay lines, 1024-frame bus  ->  26 MB   (unshippable)
//   shared pool of 4 x 250 ms, 256-frame bus  ->  515 KB
//   shared pool of 2 x 125 ms, 128-frame bus  ->  ~180 KB (this)
//
// So the caps are not defensive habit -- each one is bytes on someone's
// connection. A graph that needs a third echo or a 256-frame quantum raises a
// cap and pays for it, visibly.
pub const MAX_NODES = 48;
pub const MAX_INPUTS = 16;
pub const MAX_CHANNELS = 2;
pub const MAX_BLOCK = 128; // exactly an AudioWorklet quantum
pub const MAX_DELAY_NODES = 2;
pub const MAX_DELAY_FRAMES = 6000; // 125 ms at 48k -- an echo, not a reverb

pub const OK: i32 = 0;
pub const BAD_ARG: i32 = 1;
pub const FULL: i32 = 2;
pub const NOT_PREPARED: i32 = 3;

pub const KIND_OSC: u32 = 0;
pub const KIND_GAIN: u32 = 1;
pub const KIND_MIX: u32 = 2;
pub const KIND_PAN: u32 = 3;
pub const KIND_FILTER: u32 = 4;
pub const KIND_DELAY: u32 = 5;
pub const KIND_ENVELOPE: u32 = 6;

const Node = struct {
    kind: u32 = 0,
    inputs: [MAX_INPUTS]u32 = @splat(0),
    n_inputs: u32 = 0,

    // OSC
    waveform: u32 = 0,
    hz: f64 = 440,
    amp: f64 = 1.0,
    phase: f64 = 0,

    // GAIN / PAN
    gain: f64 = 1.0,
    pan: f64 = 0.5,

    // FILTER
    bq: dsp.Biquad = .{},
    x1: [MAX_CHANNELS]f64 = @splat(0),
    x2: [MAX_CHANNELS]f64 = @splat(0),
    y1: [MAX_CHANNELS]f64 = @splat(0),
    y2: [MAX_CHANNELS]f64 = @splat(0),

    // DELAY -- an INDEX into the shared line pool, or -1 for "not a delay".
    // The line itself is not part of a Node, which is what keeps the node array
    // small enough to ship.
    delay_slot: i32 = -1,
    delay_frames: usize = 0,
    feedback: f64 = 0,
    wet: f64 = 0.5,
    line_pos: usize = 0,

    // ENVELOPE
    env: dsp.Envelope = .{},
    env_pos: usize = 0,

    // the retrigger flag, same discipline as the native tier: a FLAG the render
    // consumes at the top of a block, never a reset from the caller's side
    trigger_req: u32 = 0,

    // where this node's output lives for the current block, planar
    bus: [MAX_CHANNELS][MAX_BLOCK]f32 = undefined,
};

// `undefined`, NOT @splat(.{}) -- see the sizes note above. Every slot is fully
// assigned by addNode before it is ever read.
var nodes: [MAX_NODES]Node = undefined;
var n_nodes: u32 = 0;

// the shared delay pool
var delay_lines: [MAX_DELAY_NODES][MAX_CHANNELS][MAX_DELAY_FRAMES]f32 = undefined;
var n_delay_used: u32 = 0;
var out_node: u32 = 0;
var rate: u32 = 48000;
var channels: u32 = 2;
var block: u32 = 128;
var prepared: bool = false;

// interleaved f32, what the worklet reads
var out_block: [MAX_BLOCK * MAX_CHANNELS]f32 = undefined;

// counters -- a bounded record counts what it drops
var ctr_refused: u32 = 0;
var ctr_blocks: u32 = 0;

// ── building ────────────────────────────────────────────────────────────────

pub fn reset(the_rate: u32, the_channels: u32, the_block: u32) i32 {
    if (the_channels == 0 or the_channels > MAX_CHANNELS or
        the_block == 0 or the_block > MAX_BLOCK or the_rate == 0)
    {
        ctr_refused += 1;
        return BAD_ARG;
    }
    n_nodes = 0;
    n_delay_used = 0;
    out_node = 0;
    prepared = false;
    rate = the_rate;
    channels = the_channels;
    block = the_block;
    @memset(&out_block, 0);
    // The delay lines are the expensive part of a Node and clearing all of them
    // on every reset costs 64 * 2 * 48000 floats. Only the nodes that exist can
    // hold state, and n_nodes is now 0, so a later addNode clears its own.
    return OK;
}

fn addNode(n: Node) i32 {
    if (n_nodes >= MAX_NODES) {
        ctr_refused += 1;
        return -1;
    }
    const idx = n_nodes;
    nodes[idx] = n;
    n_nodes += 1;
    return @intCast(idx);
}

fn valid(i: i32) bool {
    return i >= 0 and i < @as(i32, @intCast(n_nodes));
}

pub fn addOsc(waveform: u32, hz: f64, amp: f64) i32 {
    if (waveform > dsp.WAVE_TRIANGLE or hz <= 0) {
        ctr_refused += 1;
        return -1;
    }
    return addNode(.{ .kind = KIND_OSC, .waveform = waveform, .hz = hz, .amp = amp });
}

pub fn addGain(input: i32, gain: f64) i32 {
    if (!valid(input)) {
        ctr_refused += 1;
        return -1;
    }
    var n = Node{ .kind = KIND_GAIN, .gain = gain };
    n.inputs[0] = @intCast(input);
    n.n_inputs = 1;
    return addNode(n);
}

pub fn addMix() i32 {
    return addNode(.{ .kind = KIND_MIX });
}

pub fn mixAdd(mix: i32, input: i32) i32 {
    if (!valid(mix) or !valid(input) or nodes[@intCast(mix)].kind != KIND_MIX) {
        ctr_refused += 1;
        return BAD_ARG;
    }
    // ACYCLIC BY CONSTRUCTION: an input must already exist, so it has a lower
    // index, so a cycle is not representable. The native tier does the same.
    if (input >= mix) {
        ctr_refused += 1;
        return BAD_ARG;
    }
    const n = &nodes[@intCast(mix)];
    if (n.n_inputs >= MAX_INPUTS) {
        ctr_refused += 1;
        return FULL;
    }
    n.inputs[n.n_inputs] = @intCast(input);
    n.n_inputs += 1;
    return OK;
}

pub fn addPan(input: i32, pan: f64) i32 {
    if (!valid(input)) {
        ctr_refused += 1;
        return -1;
    }
    var n = Node{ .kind = KIND_PAN, .pan = @max(0, @min(1, pan)) };
    n.inputs[0] = @intCast(input);
    n.n_inputs = 1;
    return addNode(n);
}

pub fn addFilter(input: i32, kind: u32, freq: f64, q: f64) i32 {
    if (!valid(input) or kind > dsp.FILTER_BANDPASS or freq <= 0 or q <= 0) {
        ctr_refused += 1;
        return -1;
    }
    var n = Node{ .kind = KIND_FILTER };
    n.bq = dsp.biquadOf(kind, freq, q, rate);
    n.inputs[0] = @intCast(input);
    n.n_inputs = 1;
    return addNode(n);
}

pub fn addDelay(input: i32, seconds: f64, feedback: f64, wet: f64) i32 {
    // feedback >= 1 grows without bound; that is an oscillator, not an effect
    if (!valid(input) or seconds <= 0 or feedback >= 1.0 or feedback < 0) {
        ctr_refused += 1;
        return -1;
    }
    const frames: usize = @intFromFloat(seconds * @as(f64, @floatFromInt(rate)));
    if (frames == 0 or frames > MAX_DELAY_FRAMES) {
        ctr_refused += 1;
        return -1;
    }
    if (n_delay_used >= MAX_DELAY_NODES) {
        ctr_refused += 1; // four echoes is the pool; a fifth is counted, not grown
        return -1;
    }
    const slot = n_delay_used;
    n_delay_used += 1;
    for (0..MAX_CHANNELS) |ch| @memset(&delay_lines[slot][ch], 0);
    var n = Node{
        .kind = KIND_DELAY,
        .delay_slot = @intCast(slot),
        .delay_frames = frames,
        .feedback = feedback,
        .wet = @max(0, @min(1, wet)),
    };
    n.inputs[0] = @intCast(input);
    n.n_inputs = 1;
    return addNode(n);
}

pub fn addEnvelope(input: i32, a: f64, d: f64, sus: f64, r: f64, gate: f64) i32 {
    if (!valid(input)) {
        ctr_refused += 1;
        return -1;
    }
    const fr: f64 = @floatFromInt(rate);
    var n = Node{ .kind = KIND_ENVELOPE };
    n.env = .{
        .a_frames = @intFromFloat(@max(0, a) * fr),
        .d_frames = @intFromFloat(@max(0, d) * fr),
        .sustain = sus,
        .r_frames = @intFromFloat(@max(0, r) * fr),
        .gate_frames = if (gate <= 0) std.math.maxInt(usize) else @intFromFloat(gate * fr),
    };
    n.inputs[0] = @intCast(input);
    n.n_inputs = 1;
    return addNode(n);
}

pub fn setOutput(node: i32) i32 {
    if (!valid(node)) {
        ctr_refused += 1;
        return BAD_ARG;
    }
    out_node = @intCast(node);
    return OK;
}

pub fn prepare() i32 {
    if (n_nodes == 0) {
        ctr_refused += 1;
        return BAD_ARG;
    }
    prepared = true;
    return OK;
}

/// Restart this node and everything upstream of it. Same contract as the native
/// tier: a FLAG, consumed at the top of a block, so a voice never starts part
/// way into one.
pub fn triggerNode(node: i32) i32 {
    if (!valid(node)) {
        ctr_refused += 1;
        return BAD_ARG;
    }
    nodes[@intCast(node)].trigger_req = 1;
    return OK;
}

fn resetSubtree(idx: usize, depth: u32) void {
    if (depth > 32) return;
    const n = &nodes[idx];
    n.phase = 0;
    n.env_pos = 0;
    n.line_pos = 0;
    n.x1 = @splat(0);
    n.x2 = @splat(0);
    n.y1 = @splat(0);
    n.y2 = @splat(0);
    if (n.delay_slot >= 0) {
        const sl: usize = @intCast(n.delay_slot);
        for (0..MAX_CHANNELS) |ch| @memset(&delay_lines[sl][ch], 0);
    }
    var k: usize = 0;
    while (k < n.n_inputs) : (k += 1) resetSubtree(n.inputs[k], depth + 1);
}

// ── rendering ───────────────────────────────────────────────────────────────

/// Fill one block. Returns the number of FRAMES written, or 0 on refusal.
pub fn renderBlock() u32 {
    if (!prepared) {
        ctr_refused += 1;
        return 0;
    }
    const blk: usize = block;
    const nch: usize = channels;

    // retriggers first, before a single sample exists
    var t: usize = 0;
    while (t < n_nodes) : (t += 1) {
        if (nodes[t].trigger_req != 0) {
            nodes[t].trigger_req = 0;
            resetSubtree(t, 0);
        }
    }

    var i: usize = 0;
    while (i < n_nodes) : (i += 1) {
        const n = &nodes[i];
        switch (n.kind) {
            KIND_OSC => {
                const inc = n.hz / @as(f64, @floatFromInt(rate));
                var ph = n.phase;
                var f: usize = 0;
                while (f < blk) : (f += 1) {
                    n.bus[0][f] = @floatCast(n.amp * dsp.waveAtBl(n.waveform, ph, inc));
                    ph += inc;
                    if (ph >= 1.0) ph -= 1.0;
                }
                n.phase = ph;
                // an oscillator is mono; every other channel carries the same
                var ch: usize = 1;
                while (ch < nch) : (ch += 1) @memcpy(n.bus[ch][0..blk], n.bus[0][0..blk]);
            },
            KIND_GAIN => {
                const src = &nodes[n.inputs[0]];
                const g: f32 = @floatCast(n.gain);
                var ch: usize = 0;
                while (ch < nch) : (ch += 1) {
                    var f: usize = 0;
                    while (f < blk) : (f += 1) n.bus[ch][f] = src.bus[ch][f] * g;
                }
            },
            KIND_MIX => {
                var ch: usize = 0;
                while (ch < nch) : (ch += 1) @memset(n.bus[ch][0..blk], 0);
                var k: usize = 0;
                while (k < n.n_inputs) : (k += 1) {
                    const src = &nodes[n.inputs[k]];
                    ch = 0;
                    while (ch < nch) : (ch += 1) {
                        var f: usize = 0;
                        while (f < blk) : (f += 1) n.bus[ch][f] += src.bus[ch][f];
                    }
                }
            },
            KIND_PAN => {
                const src = &nodes[n.inputs[0]];
                // constant-power: equal loudness across the sweep, which a
                // linear pan does not give
                const l: f32 = @floatCast(@cos(n.pan * std.math.pi / 2.0));
                const r: f32 = @floatCast(@sin(n.pan * std.math.pi / 2.0));
                var f: usize = 0;
                while (f < blk) : (f += 1) {
                    const m = src.bus[0][f];
                    n.bus[0][f] = m * l;
                    if (nch > 1) n.bus[1][f] = src.bus[1][f] * r;
                }
            },
            KIND_FILTER => {
                const src = &nodes[n.inputs[0]];
                var ch: usize = 0;
                while (ch < nch) : (ch += 1) {
                    var f: usize = 0;
                    while (f < blk) : (f += 1) {
                        n.bus[ch][f] = @floatCast(dsp.biquadStep(
                            n.bq,
                            @floatCast(src.bus[ch][f]),
                            &n.x1[ch],
                            &n.x2[ch],
                            &n.y1[ch],
                            &n.y2[ch],
                        ));
                    }
                }
            },
            KIND_DELAY => {
                const src = &nodes[n.inputs[0]];
                const wet: f32 = @floatCast(n.wet);
                const fb: f32 = @floatCast(n.feedback);
                const sl: usize = @intCast(n.delay_slot);
                var f: usize = 0;
                while (f < blk) : (f += 1) {
                    const pos = (n.line_pos + f) % n.delay_frames;
                    var ch: usize = 0;
                    while (ch < nch) : (ch += 1) {
                        const echoed = delay_lines[sl][ch][pos];
                        const dry = src.bus[ch][f];
                        delay_lines[sl][ch][pos] = dry + echoed * fb;
                        n.bus[ch][f] = dry * (1 - wet) + echoed * wet;
                    }
                }
                n.line_pos = (n.line_pos + blk) % n.delay_frames;
            },
            KIND_ENVELOPE => {
                const src = &nodes[n.inputs[0]];
                var ch: usize = 0;
                while (ch < nch) : (ch += 1) {
                    var p = n.env_pos;
                    var f: usize = 0;
                    while (f < blk) : (f += 1) {
                        n.bus[ch][f] = @floatCast(@as(f64, src.bus[ch][f]) * dsp.envAt(n.env, p));
                        p += 1;
                    }
                    if (ch + 1 == nch) n.env_pos = p;
                }
            },
            else => {},
        }
    }

    // INTERLEAVE ONCE, at the sink -- the plane's law, and here it also happens
    // to be exactly the layout an AudioWorklet wants.
    const src = &nodes[out_node];
    var f: usize = 0;
    while (f < blk) : (f += 1) {
        var ch: usize = 0;
        while (ch < nch) : (ch += 1) out_block[f * nch + ch] = src.bus[ch][f];
    }
    ctr_blocks += 1;
    return @intCast(blk);
}

// ── what JS reads ───────────────────────────────────────────────────────────

pub fn blockPtr() u32 {
    return @intCast(@intFromPtr(&out_block[0]));
}

pub fn nodeCount() u32 {
    return n_nodes;
}
pub fn refusals() u32 {
    return ctr_refused;
}
pub fn blocksRendered() u32 {
    return ctr_blocks;
}
pub fn isPrepared() bool {
    return prepared;
}

/// One sample out of the last rendered block -- how a guard or a test reads the
/// output without a JS view over linear memory.
pub fn sampleAt(frame: u32, ch: u32) f64 {
    if (frame >= block or ch >= channels) return 0;
    return out_block[frame * channels + ch];
}

// ── tests ───────────────────────────────────────────────────────────────────

const testing = std.testing;

test "a graph with no allocator renders, and the bus is interleaved" {
    try testing.expectEqual(OK, reset(48000, 2, 128));
    const osc = addOsc(dsp.WAVE_SINE, 12000, 1.0); // rate/4 -> 0, 1, 0, -1
    try testing.expect(osc >= 0);
    try testing.expectEqual(OK, setOutput(osc));
    try testing.expectEqual(OK, prepare());
    try testing.expectEqual(@as(u32, 128), renderBlock());
    // both channels carry the mono oscillator, and they interleave
    try testing.expectApproxEqAbs(@as(f64, 0), sampleAt(0, 0), 1e-6);
    try testing.expectApproxEqAbs(@as(f64, 1), sampleAt(1, 0), 1e-6);
    try testing.expectApproxEqAbs(@as(f64, 0), sampleAt(2, 0), 1e-6);
    try testing.expectApproxEqAbs(@as(f64, -1), sampleAt(3, 0), 1e-6);
    try testing.expectApproxEqAbs(sampleAt(1, 0), sampleAt(1, 1), 1e-9);
}

test "the bounded record COUNTS its refusals rather than growing" {
    _ = reset(48000, 1, 128);
    const before = refusals();
    // past the cap
    var made: u32 = 0;
    while (made < MAX_NODES + 4) : (made += 1) _ = addOsc(dsp.WAVE_SINE, 440, 0.1);
    try testing.expectEqual(@as(u32, MAX_NODES), nodeCount());
    try testing.expect(refusals() > before);
    // and the negative sibling: a graph inside the cap refuses nothing
    _ = reset(48000, 1, 128);
    const clean = refusals();
    _ = addOsc(dsp.WAVE_SINE, 440, 0.5);
    try testing.expectEqual(clean, refusals());
}

test "a cycle is not representable, and bad arguments are refused" {
    _ = reset(48000, 1, 128);
    const a = addOsc(dsp.WAVE_SINE, 440, 0.5);
    const mix = addMix();
    try testing.expectEqual(OK, mixAdd(mix, a));
    // a mix cannot take itself or anything later than itself
    try testing.expectEqual(BAD_ARG, mixAdd(mix, mix));
    try testing.expectEqual(BAD_ARG, mixAdd(mix, 99));
    // feedback at or above 1 is an oscillator, not an effect
    try testing.expect(addDelay(a, 0.01, 1.0, 0.5) < 0);
    try testing.expect(addDelay(a, 0.01, 0.5, 0.5) >= 0);
    // a render before prepare is refused rather than producing noise
    _ = reset(48000, 1, 128);
    const b = addOsc(dsp.WAVE_SINE, 440, 0.5);
    _ = setOutput(b);
    try testing.expectEqual(@as(u32, 0), renderBlock());
}

test "a retrigger restarts a voice from the top of the NEXT block" {
    _ = reset(48000, 1, 128);
    const osc = addOsc(dsp.WAVE_SINE, 1000, 1.0);
    const env = addEnvelope(osc, 0.02, 0.0, 1.0, 0.0, 10.0); // 20 ms attack
    _ = setOutput(env);
    _ = prepare();
    // climb the attack
    var k: usize = 0;
    while (k < 16) : (k += 1) _ = renderBlock();
    var loud: f64 = 0;
    for (0..128) |f| loud = @max(loud, @abs(sampleAt(@intCast(f), 0)));
    try testing.expect(loud > 0.8);
    // restart, and the next block starts at the BOTTOM of the attack
    try testing.expectEqual(OK, triggerNode(env));
    _ = renderBlock();
    var quiet: f64 = 0;
    for (0..16) |f| quiet = @max(quiet, @abs(sampleAt(@intCast(f), 0)));
    try testing.expect(quiet < loud * 0.2);
}
