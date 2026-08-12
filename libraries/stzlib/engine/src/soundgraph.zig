//! THE SOUND GRAPH, offline first. SN2 of SOFTANZA_SOUND_PLAN.md.
//!
//! NAMED soundgraph.zig, NOT graph.zig: `src/graph.zig` is already taken by the
//! graph-THEORY module behind stz_graph.dll (nodes, edges, shortest path). Two
//! unrelated meanings of "graph" live in this engine, and the file names have
//! to say which is which.
//!
//! A graph is ONE handle owning a COMPILED NODE LIST -- not a web of per-node
//! handles. That choice is made here rather than in SN3 because SN3's callback
//! is a no-allocation, no-lock, no-Ring zone: it must walk a flat array of
//! nodes whose buffers were all allocated at Prepare(). A graph of individually
//! handled nodes would need pointer chasing and a live table lookup per node,
//! inside the one place in this plane that cannot afford either.
//!
//! ── THE TWO-PHASE CONTRACT, WHICH IS THE WHOLE POINT ──
//!
//!     Add*(...)     -- describe the graph. Allocates freely.
//!     Prepare()     -- validate, allocate EVERY buffer the render will need.
//!     RenderBlock() -- pure arithmetic over those buffers. ZERO allocation.
//!
//! This is enforced, not requested: every allocation in this module goes
//! through a counting allocator, and a guard asserts the count does not move
//! across a RenderBlock. If someone later adds an allocating node, the guard
//! fails rather than the audio glitching six months later.
//!
//! ── PLANAR, BECAUSE SN0 MEASURED IT ──
//!
//! Every node's output bus is PLANAR (channels x block frames, one contiguous
//! run per channel), and interleaving happens once, at the sink. SN0 measured
//! planar accumulation at 1.38x interleaved for a 128-voice mix, and also that
//! hand-written @Vector code is SLOWER than plain slice loops here -- so the
//! loops below are written as slices and left for the compiler to widen, which
//! is the law linalg.zig minted and this plane re-measured in its own domain.
//!
//! ── THE SINK IS A PARAMETER, NOT A FORK (lesson 5) ──
//!
//! RenderToBuffer and RenderToFile drive the SAME node list through the SAME
//! RenderBlock. SN3's device sink will be a third caller of that one function,
//! so what you hear and what you export cannot drift apart.
//!
//! ── ACYCLIC BY CONSTRUCTION ──
//!
//! A node may only reference inputs that already exist, so creation order is
//! always a valid topological order and a cycle cannot be built. Delay
//! feedback is INTERNAL to the delay node (its own line), not a graph edge --
//! which is what lets feedback exist without cycles existing.

const std = @import("std");
/// PUBLIC so a single-module consumer can reach the sample tier through this
/// one import. Declaring sound.zig as a SECOND module alongside soundgraph.zig
/// puts the same file in two modules, which Zig rejects outright.
pub const snd = @import("sound.zig");
const sr = @import("soundring.zig");
/// Also public, and for the same reason: the studio server wants the device
/// tier without declaring a second module over the same files.
pub const dev = @import("audiodev.zig");

// ---------------------------------------------------------------- counting allocator
//
// The witness for "Render allocates nothing". Wrapping the allocator rather
// than counting our own call sites means it also catches an allocation made by
// something we call, which is the failure a hand-rolled counter would miss.

var alloc_calls: u64 = 0;

const base_alloc = std.heap.c_allocator;

fn cAlloc(ctx: *anyopaque, len: usize, alignment: std.mem.Alignment, ra: usize) ?[*]u8 {
    alloc_calls += 1;
    return base_alloc.vtable.alloc(ctx, len, alignment, ra);
}

fn cResize(ctx: *anyopaque, memory: []u8, alignment: std.mem.Alignment, new_len: usize, ra: usize) bool {
    alloc_calls += 1;
    return base_alloc.vtable.resize(ctx, memory, alignment, new_len, ra);
}

fn cRemap(ctx: *anyopaque, memory: []u8, alignment: std.mem.Alignment, new_len: usize, ra: usize) ?[*]u8 {
    alloc_calls += 1;
    return base_alloc.vtable.remap(ctx, memory, alignment, new_len, ra);
}

fn cFree(ctx: *anyopaque, memory: []u8, alignment: std.mem.Alignment, ra: usize) void {
    base_alloc.vtable.free(ctx, memory, alignment, ra);
}

const counting_vtable = std.mem.Allocator.VTable{
    .alloc = cAlloc,
    .resize = cResize,
    .remap = cRemap,
    .free = cFree,
};

const alloc = std.mem.Allocator{ .ptr = base_alloc.ptr, .vtable = &counting_vtable };

/// Total allocations since load. A guard reads it either side of a render and
/// asserts it did not move.
pub fn allocCount() f64 {
    return @floatFromInt(alloc_calls);
}

// ---------------------------------------------------------------- status

pub const OK: i32 = 0;
pub const STALE: i32 = 2;
pub const BAD_ARG: i32 = 3;
pub const NOT_PREPARED: i32 = 7;
pub const ALREADY_PREPARED: i32 = 8;

// ---------------------------------------------------------------- counters

pub const CTR_GRAPHS_LIVE = 0; // sound.graphs.live
pub const CTR_BLOCKS_RENDERED = 1; // sound.graph.blocks
pub const CTR_FRAMES_RENDERED = 2; // sound.graph.frames
pub const CTR_REFUSALS = 3; // sound.graph.refusals
pub const CTR_STALE_HITS = 4; // sound.graph.stale.hits
pub const CTR_COUNT = 5;

var counters: [CTR_COUNT]f64 = @splat(0);

pub fn counter(i: usize) f64 {
    if (i >= CTR_COUNT) return 0;
    return counters[i];
}

pub fn countersReset() void {
    counters = @splat(0);
    var live: f64 = 0;
    for (graphs.items) |g| {
        if (g.live) live += 1;
    }
    counters[CTR_GRAPHS_LIVE] = live;
}

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

fn refuse(msg: []const u8) void {
    counters[CTR_REFUSALS] += 1;
    setErr(msg);
}

// ---------------------------------------------------------------- node kinds

pub const KIND_OSC: u32 = 0;
pub const KIND_SOURCE: u32 = 1;
pub const KIND_GAIN: u32 = 2;
pub const KIND_MIX: u32 = 3;
pub const KIND_PAN: u32 = 4;
pub const KIND_FILTER: u32 = 5;
pub const KIND_DELAY: u32 = 6;
pub const KIND_ENVELOPE: u32 = 7;

pub const WAVE_SINE: u32 = 0;
pub const WAVE_SQUARE: u32 = 1;
pub const WAVE_SAW: u32 = 2;
pub const WAVE_TRIANGLE: u32 = 3;

pub const FILTER_LOWPASS: u32 = 0;
pub const FILTER_HIGHPASS: u32 = 1;
pub const FILTER_BANDPASS: u32 = 2;

const MAX_INPUTS = 32;
const MAX_CHANNELS = 8;

const Node = struct {
    kind: u32,
    inputs: [MAX_INPUTS]u32 = @splat(0),
    n_inputs: u32 = 0,

    // OSC
    waveform: u32 = 0,
    hz: f64 = 440,
    amp: f64 = 1.0,
    phase: f64 = 0, // advanced across blocks; reset by rewind()

    // SOURCE
    buffer_id: i64 = 0,
    pos: usize = 0,
    loop: bool = false,

    // GAIN / PAN
    gain: f64 = 1.0,
    pan: f64 = 0.5,

    // SN3 CONTROL: the value another thread asks for, and the ramp that gets
    // us there. `gain_target` is written by whoever calls setGain (the Ring
    // thread) and read by the render (the producer thread) -- atomically, so
    // no lock is needed on either side. `gain_now` belongs to the render alone.
    //
    // THE RAMP IS THE POINT. Jumping a gain from 1.0 to 0.0 between two samples
    // is a step discontinuity, and a step is a CLICK -- broadband energy the
    // signal never contained. Spreading the change over a few milliseconds
    // makes it inaudible. Guards assert exactly this: the sample-to-sample
    // delta stays small while the value still ARRIVES at the target.
    gain_target: f32 = 1.0,
    gain_now: f32 = 1.0,
    gain_ramp_frames: u32 = 0, // 0 = apply instantly (a legitimate choice, and
    //                            the negative sibling the click guard needs)
    // The step is computed ONCE, when a new target is first seen, and then
    // walked until it arrives. The first cut recomputed it every block as
    // (target - now) / ramp, which is an exponential approach rather than a
    // ramp: the step shrank as the gap closed and the value never arrived
    // (measured 0.101 where 0.0 was asked for). Storing the step is what makes
    // "a 10 ms ramp" mean ten milliseconds.
    gain_step: f32 = 0,
    gain_seen: f32 = 1.0, // the target this node has already planned a step for

    // SN6 CONTROL: "start this voice again, from the top". Written by the Ring
    // thread, consumed by the render, atomically -- the same discipline as
    // gain_target above, and for the same reason: the producer thread is
    // walking these nodes while the caller writes to them.
    //
    // A FLAG AND NOT A RESET, because resetting from the calling thread is a
    // data race by construction. The render swaps the flag to 0 at the TOP of
    // a block, before any node has produced a sample, so a retriggered voice
    // starts at the first frame of the next block rather than part way in.
    trigger_req: u32 = 0,

    // FILTER (RBJ biquad, per channel state)
    f_kind: u32 = 0,
    freq: f64 = 1000,
    q: f64 = 0.707,
    b0: f64 = 1,
    b1: f64 = 0,
    b2: f64 = 0,
    a1: f64 = 0,
    a2: f64 = 0,
    x1: [MAX_CHANNELS]f64 = @splat(0),
    x2: [MAX_CHANNELS]f64 = @splat(0),
    y1: [MAX_CHANNELS]f64 = @splat(0),
    y2: [MAX_CHANNELS]f64 = @splat(0),

    // DELAY
    delay_frames: usize = 0,
    feedback: f64 = 0,
    wet: f64 = 0.5,
    line: []f32 = &.{}, // channels * delay_frames, planar; allocated at Prepare
    line_pos: usize = 0,

    // ENVELOPE (ADSR, in frames; gate_frames is how long the note is held)
    a_frames: usize = 0,
    d_frames: usize = 0,
    sustain: f64 = 1.0,
    r_frames: usize = 0,
    gate_frames: usize = std.math.maxInt(usize),
    env_pos: usize = 0,
    // Silence before the attack. This one field is what turns a graph of
    // voices into a PIECE: without it every note begins at t=0 and the only
    // composition possible is one chord. With it, a voice is a note at a time.
    start_frames: usize = 0,

    // output bus: channels planar runs of block_frames, inside the graph's
    // one allocation. An OFFSET, not a pointer, so the arena can move at
    // Prepare without every node needing to be patched.
    out_off: usize = 0,
};

const Graph = struct {
    nodes: std.ArrayList(Node) = .{},
    channels: u32 = 2,
    rate: u32 = 48000,
    block: usize = 512,
    output: i64 = -1, // node index, -1 = none set
    bus: []f32 = &.{}, // ONE allocation: nodes * channels * block
    inter: []f32 = &.{}, // interleave scratch for the sinks
    prepared: bool = false,
    gen: u32 = 1,
    live: bool = false,
};

var graphs: std.ArrayList(Graph) = .{};

fn makeId(slot: usize, gen: u32) i64 {
    return (@as(i64, gen) << 32) | @as(i64, @intCast(slot + 1));
}

fn slotOf(id: i64) ?usize {
    const idx = id & 0xffff_ffff;
    if (idx <= 0 or idx > @as(i64, @intCast(graphs.items.len))) return null;
    const s: usize = @intCast(idx - 1);
    const gen: u32 = @intCast((id >> 32) & 0xffff_ffff);
    if (!graphs.items[s].live or graphs.items[s].gen != gen) {
        counters[CTR_STALE_HITS] += 1;
        return null;
    }
    return s;
}

// ---------------------------------------------------------------- lifecycle

pub fn graphNew(channels: u32, rate: u32, block: usize) i64 {
    if (channels == 0 or channels > MAX_CHANNELS or rate == 0 or block == 0 or block > 1 << 20) {
        refuse("graphNew: channels 1..8, rate > 0, block 1..1048576");
        return 0;
    }
    var g = Graph{ .channels = channels, .rate = rate, .block = block, .live = true };
    for (graphs.items, 0..) |*slot, i| {
        if (!slot.live) {
            g.gen = slot.gen;
            slot.* = g;
            counters[CTR_GRAPHS_LIVE] += 1;
            return makeId(i, g.gen);
        }
    }
    graphs.append(alloc, g) catch {
        setErr("out of memory growing the graph table");
        return 0;
    };
    counters[CTR_GRAPHS_LIVE] += 1;
    return makeId(graphs.items.len - 1, 1);
}

pub fn graphFree(id: i64) i32 {
    const s = slotOf(id) orelse return STALE;
    const g = &graphs.items[s];
    for (g.nodes.items) |*n| {
        if (n.line.len > 0) alloc.free(n.line);
    }
    g.nodes.deinit(alloc);
    if (g.bus.len > 0) alloc.free(g.bus);
    if (g.inter.len > 0) alloc.free(g.inter);
    g.bus = &.{};
    g.inter = &.{};
    g.live = false;
    g.prepared = false;
    g.gen +%= 1;
    if (g.gen == 0) g.gen = 1;
    counters[CTR_GRAPHS_LIVE] -= 1;
    return OK;
}

pub fn nodeCount(id: i64) f64 {
    const s = slotOf(id) orelse return -1;
    return @floatFromInt(graphs.items[s].nodes.items.len);
}

pub fn isPrepared(id: i64) f64 {
    const s = slotOf(id) orelse return -1;
    return if (graphs.items[s].prepared) 1 else 0;
}

// ---------------------------------------------------------------- building

/// Adding a node after Prepare() is refused: the arena is sized for the node
/// count, and growing it silently would move every node's output from under a
/// render already in flight. Rebuild the graph, or Prepare a new one.
fn addNode(g: *Graph, n: Node) i64 {
    if (g.prepared) {
        refuse("cannot add nodes after Prepare -- build the graph, then prepare it");
        return -1;
    }
    g.nodes.append(alloc, n) catch {
        setErr("out of memory adding a node");
        return -1;
    };
    return @intCast(g.nodes.items.len - 1);
}

fn validInput(g: *Graph, input: i64) bool {
    // ACYCLIC BY CONSTRUCTION: an input must already exist, so creation order
    // is a topological order and no cycle can be expressed.
    return input >= 0 and input < @as(i64, @intCast(g.nodes.items.len));
}

pub fn addOsc(id: i64, waveform: u32, hz: f64, amp: f64) i64 {
    const s = slotOf(id) orelse return -1;
    const g = &graphs.items[s];
    if (waveform > WAVE_TRIANGLE or hz <= 0) {
        refuse("addOsc: waveform 0..3 and hz > 0");
        return -1;
    }
    return addNode(g, .{ .kind = KIND_OSC, .waveform = waveform, .hz = hz, .amp = amp });
}

pub fn addSource(id: i64, buffer_id: i64, loop: bool) i64 {
    const s = slotOf(id) orelse return -1;
    const g = &graphs.items[s];
    if (snd.frameCount(buffer_id) < 0) {
        refuse("addSource: the sample buffer id is stale or unknown");
        return -1;
    }
    return addNode(g, .{ .kind = KIND_SOURCE, .buffer_id = buffer_id, .loop = loop });
}

pub fn addGain(id: i64, input: i64, gain: f64) i64 {
    const s = slotOf(id) orelse return -1;
    const g = &graphs.items[s];
    if (!validInput(g, input)) {
        refuse("addGain: input must be an existing earlier node");
        return -1;
    }
    var n = Node{
        .kind = KIND_GAIN,
        .gain = gain,
        .gain_target = @floatCast(gain),
        .gain_now = @floatCast(gain),
        .gain_seen = @floatCast(gain),
    };
    n.inputs[0] = @intCast(input);
    n.n_inputs = 1;
    return addNode(g, n);
}

/// SN3: change a gain WHILE the graph is rendering, from another thread.
///
/// Lock-free by construction rather than by a queue: the target is one aligned
/// f32 written atomically by the caller and read atomically by the render. A
/// queue would be needed if the ORDER of several changes mattered; for a single
/// scalar the last writer wins, which is exactly the desired semantics for a
/// fader. When SN4 needs ordered, multi-parameter, sample-accurate automation,
/// THAT is when the queue earns its complexity -- said here so the next session
/// does not read this as an oversight.
///
/// `ramp_ms` of 0 applies the change instantly, which clicks. That is on
/// purpose: it is what lets a guard PROVE the ramp is doing something.
pub fn setGain(id: i64, node: i64, value: f64, ramp_ms: f64) i32 {
    const s = slotOf(id) orelse return STALE;
    const g = &graphs.items[s];
    if (!validInput(g, node)) {
        refuse("setGain: that node does not exist");
        return BAD_ARG;
    }
    const n = &g.nodes.items[@intCast(node)];
    if (n.kind != KIND_GAIN) {
        refuse("setGain: that node is not a gain");
        return BAD_ARG;
    }
    const frames: u32 = if (ramp_ms <= 0) 0 else @intFromFloat(ramp_ms * @as(f64, @floatFromInt(g.rate)) / 1000.0);
    @atomicStore(u32, &n.gain_ramp_frames, frames, .monotonic);
    // released LAST, so a render that sees the new target also sees the ramp
    // length that belongs with it
    @atomicStore(f32, &n.gain_target, @floatCast(value), .release);
    return OK;
}

/// The gain a render is currently applying -- which during a ramp is somewhere
/// between the old value and the target. A guard reads it to prove the ramp
/// both MOVES and ARRIVES.
pub fn currentGain(id: i64, node: i64) f64 {
    const s = slotOf(id) orelse return -1;
    const g = &graphs.items[s];
    if (!validInput(g, node)) return -1;
    return @atomicLoad(f32, &g.nodes.items[@intCast(node)].gain_now, .monotonic);
}

pub fn addMix(id: i64) i64 {
    const s = slotOf(id) orelse return -1;
    return addNode(&graphs.items[s], .{ .kind = KIND_MIX });
}

pub fn mixAdd(id: i64, mix_node: i64, input: i64) i32 {
    const s = slotOf(id) orelse return STALE;
    const g = &graphs.items[s];
    if (g.prepared) {
        refuse("mixAdd: cannot change the graph after Prepare");
        return ALREADY_PREPARED;
    }
    if (!validInput(g, mix_node) or !validInput(g, input) or input >= mix_node) {
        refuse("mixAdd: both must exist and the input must precede the mix");
        return BAD_ARG;
    }
    const m = &g.nodes.items[@intCast(mix_node)];
    if (m.kind != KIND_MIX) {
        refuse("mixAdd: that node is not a mix");
        return BAD_ARG;
    }
    if (m.n_inputs >= MAX_INPUTS) {
        refuse("mixAdd: a mix takes at most 32 inputs");
        return BAD_ARG;
    }
    m.inputs[m.n_inputs] = @intCast(input);
    m.n_inputs += 1;
    return OK;
}

pub fn addPan(id: i64, input: i64, pan: f64) i64 {
    const s = slotOf(id) orelse return -1;
    const g = &graphs.items[s];
    if (!validInput(g, input)) {
        refuse("addPan: input must be an existing earlier node");
        return -1;
    }
    var n = Node{ .kind = KIND_PAN, .pan = @max(0, @min(1, pan)) };
    n.inputs[0] = @intCast(input);
    n.n_inputs = 1;
    return addNode(g, n);
}

pub fn addFilter(id: i64, input: i64, kind: u32, freq: f64, q: f64) i64 {
    const s = slotOf(id) orelse return -1;
    const g = &graphs.items[s];
    if (!validInput(g, input)) {
        refuse("addFilter: input must be an existing earlier node");
        return -1;
    }
    if (kind > FILTER_BANDPASS or freq <= 0 or freq >= @as(f64, @floatFromInt(g.rate)) / 2 or q <= 0) {
        refuse("addFilter: kind 0..2, 0 < freq < Nyquist, q > 0");
        return -1;
    }
    var n = Node{ .kind = KIND_FILTER, .f_kind = kind, .freq = freq, .q = q };
    n.inputs[0] = @intCast(input);
    n.n_inputs = 1;
    computeBiquad(&n, g.rate);
    return addNode(g, n);
}

pub fn addDelay(id: i64, input: i64, seconds: f64, feedback: f64, wet: f64) i64 {
    const s = slotOf(id) orelse return -1;
    const g = &graphs.items[s];
    if (!validInput(g, input)) {
        refuse("addDelay: input must be an existing earlier node");
        return -1;
    }
    // feedback >= 1 is an oscillator that grows without bound, not an effect
    if (seconds <= 0 or seconds > 60 or feedback < 0 or feedback >= 1) {
        refuse("addDelay: 0 < seconds <= 60 and 0 <= feedback < 1");
        return -1;
    }
    var n = Node{
        .kind = KIND_DELAY,
        .delay_frames = @intFromFloat(seconds * @as(f64, @floatFromInt(g.rate))),
        .feedback = feedback,
        .wet = wet,
    };
    if (n.delay_frames == 0) n.delay_frames = 1;
    n.inputs[0] = @intCast(input);
    n.n_inputs = 1;
    return addNode(g, n);
}

pub fn addEnvelope(id: i64, input: i64, a: f64, d: f64, sus: f64, r: f64, gate: f64) i64 {
    return addEnvelopeAt(id, input, a, d, sus, r, gate, 0);
}

/// The same envelope, but silent until `start` seconds have passed. A voice
/// that knows WHEN it sounds is the difference between a chord and a piece.
pub fn addEnvelopeAt(id: i64, input: i64, a: f64, d: f64, sus: f64, r: f64, gate: f64, start: f64) i64 {
    const s = slotOf(id) orelse return -1;
    const g = &graphs.items[s];
    if (!validInput(g, input)) {
        refuse("addEnvelope: input must be an existing earlier node");
        return -1;
    }
    if (a < 0 or d < 0 or r < 0 or sus < 0 or sus > 1) {
        refuse("addEnvelope: times >= 0 and 0 <= sustain <= 1");
        return -1;
    }
    const fr = @as(f64, @floatFromInt(g.rate));
    var n = Node{
        .kind = KIND_ENVELOPE,
        .a_frames = @intFromFloat(a * fr),
        .d_frames = @intFromFloat(d * fr),
        .sustain = sus,
        .r_frames = @intFromFloat(r * fr),
        .gate_frames = if (gate <= 0) std.math.maxInt(usize) else @intFromFloat(gate * fr),
        .start_frames = if (start <= 0) 0 else @intFromFloat(start * fr),
    };
    n.inputs[0] = @intCast(input);
    n.n_inputs = 1;
    return addNode(g, n);
}

pub fn setOutput(id: i64, node: i64) i32 {
    const s = slotOf(id) orelse return STALE;
    const g = &graphs.items[s];
    if (!validInput(g, node)) {
        refuse("setOutput: that node does not exist");
        return BAD_ARG;
    }
    g.output = node;
    return OK;
}

// RBJ cookbook coefficients, normalised by a0. Computed at BUILD time, not per
// block: they depend only on freq/q/rate, none of which change during a render
// in SN2. SN3's control queue is what will make them movable.
fn computeBiquad(n: *Node, rate: u32) void {
    const w0 = 2.0 * std.math.pi * n.freq / @as(f64, @floatFromInt(rate));
    const cw = @cos(w0);
    const sw = @sin(w0);
    const alpha = sw / (2.0 * n.q);
    var b0: f64 = 0;
    var b1: f64 = 0;
    var b2: f64 = 0;
    const a0 = 1 + alpha;
    const a1 = -2 * cw;
    const a2 = 1 - alpha;
    switch (n.f_kind) {
        FILTER_LOWPASS => {
            b0 = (1 - cw) / 2;
            b1 = 1 - cw;
            b2 = (1 - cw) / 2;
        },
        FILTER_HIGHPASS => {
            b0 = (1 + cw) / 2;
            b1 = -(1 + cw);
            b2 = (1 + cw) / 2;
        },
        else => { // bandpass, constant 0 dB peak gain
            b0 = alpha;
            b1 = 0;
            b2 = -alpha;
        },
    }
    n.b0 = b0 / a0;
    n.b1 = b1 / a0;
    n.b2 = b2 / a0;
    n.a1 = a1 / a0;
    n.a2 = a2 / a0;
}

// ---------------------------------------------------------------- prepare

/// Validate the graph and allocate EVERY buffer the render will touch: the
/// node arena, the interleave scratch, and each delay line. After this returns
/// OK, RenderBlock does arithmetic and nothing else.
pub fn prepare(id: i64) i32 {
    const s = slotOf(id) orelse return STALE;
    const g = &graphs.items[s];
    if (g.prepared) {
        refuse("prepare: already prepared");
        return ALREADY_PREPARED;
    }
    if (g.nodes.items.len == 0) {
        refuse("prepare: the graph has no nodes");
        return BAD_ARG;
    }
    if (g.output < 0) {
        refuse("prepare: no output node was set");
        return BAD_ARG;
    }

    const per_node = g.channels * g.block;
    const total = g.nodes.items.len * per_node;
    g.bus = alloc.alloc(f32, total) catch {
        setErr("out of memory allocating the node arena");
        return BAD_ARG;
    };
    @memset(g.bus, 0);
    g.inter = alloc.alloc(f32, g.block * g.channels) catch {
        setErr("out of memory allocating the interleave scratch");
        return BAD_ARG;
    };

    for (g.nodes.items, 0..) |*n, i| {
        n.out_off = i * per_node;
        if (n.kind == KIND_DELAY) {
            n.line = alloc.alloc(f32, g.channels * n.delay_frames) catch {
                setErr("out of memory allocating a delay line");
                return BAD_ARG;
            };
            @memset(n.line, 0);
            n.line_pos = 0;
        }
    }
    g.prepared = true;
    return OK;
}

/// Rewind every stateful node to the start WITHOUT reallocating. This is what
/// makes a prepared graph reusable -- and it is also how a guard proves that
/// two renders of the same graph are identical rather than merely similar.
pub fn rewind(id: i64) i32 {
    const s = slotOf(id) orelse return STALE;
    const g = &graphs.items[s];
    if (!g.prepared) {
        refuse("rewind: prepare the graph first");
        return NOT_PREPARED;
    }
    @memset(g.bus, 0);
    for (g.nodes.items) |*n| {
        n.phase = 0;
        n.pos = 0;
        n.env_pos = 0;
        n.line_pos = 0;
        n.x1 = @splat(0);
        n.x2 = @splat(0);
        n.y1 = @splat(0);
        n.y2 = @splat(0);
        if (n.line.len > 0) @memset(n.line, 0);
    }
    return OK;
}

// ---------------------------------------------------------------- render

fn chanSlice(g: *Graph, n: *const Node, ch: usize) []f32 {
    return g.bus[n.out_off + ch * g.block ..][0..g.block];
}

/// Render exactly one block into every node's output bus, in creation order.
/// ZERO ALLOCATION. Every slice below points into the arena Prepare built.
// ── RETRIGGER: a voice, started again from the top ──────────────────────────
//
// rewind() takes the WHOLE graph back to zero, which is right for "render this
// again" and useless for a game, where thirty sounds share one graph and one
// of them has to fire without disturbing the other twenty-nine.
//
// So: a per-node trigger. The caller names a node and everything feeding it
// goes back to its beginning -- the source to frame zero, the oscillator to
// phase zero, the envelope to the top of its attack. Nothing downstream, and
// nothing on any other branch, is touched.
//
// The flag is written by the caller's thread and read by the render's. See
// Node.trigger_req for why it is a flag rather than the reset itself.

/// Ask that the node, and everything upstream of it, start again. Safe to call
/// from another thread while the graph is rendering -- that is the point.
pub fn triggerNode(id: i64, node: i64) i32 {
    const s = slotOf(id) orelse return STALE;
    const g = &graphs.items[s];
    if (node < 0 or node >= @as(i64, @intCast(g.nodes.items.len))) {
        refuse("triggerNode: no such node");
        return BAD_ARG;
    }
    const n = &g.nodes.items[@intCast(node)];
    @atomicStore(u32, &n.trigger_req, 1, .release);
    return OK;
}

fn applyTriggers(g: *Graph) void {
    for (g.nodes.items, 0..) |*n, idx| {
        if (@atomicRmw(u32, &n.trigger_req, .Xchg, 0, .acquire) == 0) continue;
        resetSubtree(g, idx, 0);
    }
}

// Everything that feeds this node, back to its beginning. The depth cap is a
// backstop, not a policy: the graph is acyclic by construction, so a walk
// cannot loop -- but a diamond can visit a shared node twice, and resetting a
// node twice is harmless while recursing forever is not.
fn resetSubtree(g: *Graph, idx: usize, depth: u32) void {
    if (depth > 64) return;
    const n = &g.nodes.items[idx];
    n.phase = 0;
    n.pos = 0;
    n.env_pos = 0;
    n.line_pos = 0;
    n.x1 = @splat(0);
    n.x2 = @splat(0);
    n.y1 = @splat(0);
    n.y2 = @splat(0);
    if (n.line.len > 0) @memset(n.line, 0);
    var k: usize = 0;
    while (k < n.n_inputs) : (k += 1) {
        resetSubtree(g, n.inputs[k], depth + 1);
    }
}

pub fn renderBlock(id: i64) i32 {
    const s = slotOf(id) orelse return STALE;
    const g = &graphs.items[s];
    if (!g.prepared) {
        refuse("renderBlock: prepare the graph first");
        return NOT_PREPARED;
    }
    const nch = g.channels;
    const blk = g.block;

    // RETRIGGERS FIRST, before a single sample is produced. Doing it inline
    // as each node is reached would reset a voice's SOURCE after the source
    // had already rendered this block -- the note would start a block late,
    // and only sometimes, depending on where the flag landed.
    applyTriggers(g);

    var i: usize = 0;
    while (i < g.nodes.items.len) : (i += 1) {
        const n = &g.nodes.items[i];
        switch (n.kind) {
            KIND_OSC => {
                const inc = n.hz / @as(f64, @floatFromInt(g.rate));
                var ph = n.phase;
                const dst = chanSlice(g, n, 0);
                for (dst) |*o| {
                    o.* = @floatCast(n.amp * waveAtBl(n.waveform, ph, inc));
                    ph += inc;
                    if (ph >= 1.0) ph -= 1.0;
                }
                n.phase = ph;
                // an oscillator is mono; every other channel carries the same
                var ch: usize = 1;
                while (ch < nch) : (ch += 1) @memcpy(chanSlice(g, n, ch), dst);
            },
            KIND_SOURCE => {
                const src_ch: usize = @intFromFloat(@max(0, snd.channelCount(n.buffer_id)));
                const src_frames: usize = @intFromFloat(@max(0, snd.frameCount(n.buffer_id)));
                var ch: usize = 0;
                while (ch < nch) : (ch += 1) {
                    const dst = chanSlice(g, n, ch);
                    const use_ch = if (src_ch == 0) 0 else @min(ch, src_ch - 1);
                    var p = n.pos;
                    for (dst) |*o| {
                        if (p >= src_frames) {
                            if (n.loop and src_frames > 0) {
                                p = 0;
                            } else {
                                o.* = 0;
                                continue;
                            }
                        }
                        o.* = @floatCast(snd.getSample(n.buffer_id, p, @intCast(use_ch)));
                        p += 1;
                    }
                }
                // advance once, after every channel has read the same span
                var p2 = n.pos + blk;
                if (n.loop and src_frames > 0) p2 %= src_frames;
                n.pos = p2;
            },
            KIND_GAIN => {
                const src = &g.nodes.items[n.inputs[0]];
                // ACQUIRE, pairing with the release in setGain: if we see the
                // new target we also see the ramp length stored before it.
                const target = @atomicLoad(f32, &n.gain_target, .acquire);
                const ramp = @atomicLoad(u32, &n.gain_ramp_frames, .monotonic);
                // A target we have not planned for yet: fix the step NOW, from
                // where we actually are, and do not recompute it again.
                if (target != n.gain_seen) {
                    n.gain_seen = target;
                    if (ramp == 0) {
                        n.gain_now = target;
                        n.gain_step = 0;
                    } else {
                        n.gain_step = (target - n.gain_now) / @as(f32, @floatFromInt(ramp));
                    }
                }
                const from = n.gain_now;

                if (from == target) {
                    const gf = target;
                    var ch: usize = 0;
                    while (ch < nch) : (ch += 1) {
                        // slices, not computed indices: the compiler widens
                        // this itself, and SN0 measured that beating a
                        // hand-written @Vector by 10-30%
                        const a = chanSlice(g, src, ch);
                        const o = chanSlice(g, n, ch);
                        for (o, a) |*d, x| d.* = x * gf;
                    }
                } else if (ramp == 0) {
                    // instant: a step, and therefore a click. Offered because
                    // some callers genuinely want it, and because a guard needs
                    // it to prove the ramped path is doing something.
                    var ch: usize = 0;
                    while (ch < nch) : (ch += 1) {
                        const a = chanSlice(g, src, ch);
                        const o = chanSlice(g, n, ch);
                        for (o, a) |*d, x| d.* = x * target;
                    }
                    n.gain_now = target;
                } else {
                    // Walk the PRE-COMPUTED step. Every channel walks the same
                    // ramp, so a stereo image cannot shift while a fader moves.
                    const step = n.gain_step;
                    var ch: usize = 0;
                    while (ch < nch) : (ch += 1) {
                        const a = chanSlice(g, src, ch);
                        const o = chanSlice(g, n, ch);
                        var cur = from;
                        for (o, a) |*d, x| {
                            d.* = x * cur;
                            cur += step;
                            // clamp so the last block of a ramp lands exactly
                            // on the target rather than overshooting past it
                            if ((step > 0 and cur > target) or (step < 0 and cur < target)) cur = target;
                        }
                        if (ch + 1 == nch) @atomicStore(f32, &n.gain_now, cur, .monotonic);
                    }
                }
            },
            KIND_MIX => {
                var ch: usize = 0;
                while (ch < nch) : (ch += 1) {
                    const o = chanSlice(g, n, ch);
                    @memset(o, 0);
                    var k: u32 = 0;
                    while (k < n.n_inputs) : (k += 1) {
                        const a = chanSlice(g, &g.nodes.items[n.inputs[k]], ch);
                        for (o, a) |*d, x| d.* += x;
                    }
                }
            },
            KIND_PAN => {
                const src = &g.nodes.items[n.inputs[0]];
                // constant-power: a centred signal keeps its ENERGY, so a pan
                // sweep does not dip in the middle the way a linear law does
                const ang = n.pan * std.math.pi / 2.0;
                const gl: f32 = @floatCast(@cos(ang));
                const gr: f32 = @floatCast(@sin(ang));
                const a0 = chanSlice(g, src, 0);
                if (nch >= 2) {
                    const l = chanSlice(g, n, 0);
                    const r = chanSlice(g, n, 1);
                    for (l, a0) |*d, x| d.* = x * gl;
                    for (r, a0) |*d, x| d.* = x * gr;
                    var ch: usize = 2;
                    while (ch < nch) : (ch += 1) @memset(chanSlice(g, n, ch), 0);
                } else {
                    @memcpy(chanSlice(g, n, 0), a0);
                }
            },
            KIND_FILTER => {
                const src = &g.nodes.items[n.inputs[0]];
                var ch: usize = 0;
                while (ch < nch) : (ch += 1) {
                    const a = chanSlice(g, src, ch);
                    const o = chanSlice(g, n, ch);
                    // Direct Form I in f64. The state is per channel and
                    // carries across blocks -- which is exactly why a block
                    // boundary must not be audible, and why a guard renders
                    // the same signal at two block sizes and compares.
                    var x1 = n.x1[ch];
                    var x2 = n.x2[ch];
                    var y1 = n.y1[ch];
                    var y2 = n.y2[ch];
                    for (o, a) |*d, xs| {
                        const x: f64 = xs;
                        const y = n.b0 * x + n.b1 * x1 + n.b2 * x2 - n.a1 * y1 - n.a2 * y2;
                        x2 = x1;
                        x1 = x;
                        y2 = y1;
                        y1 = y;
                        d.* = @floatCast(y);
                    }
                    n.x1[ch] = x1;
                    n.x2[ch] = x2;
                    n.y1[ch] = y1;
                    n.y2[ch] = y2;
                }
            },
            KIND_DELAY => {
                const src = &g.nodes.items[n.inputs[0]];
                const dl = n.delay_frames;
                const fb: f32 = @floatCast(n.feedback);
                const wet: f32 = @floatCast(n.wet);
                const dry: f32 = 1.0 - wet;
                var ch: usize = 0;
                while (ch < nch) : (ch += 1) {
                    const a = chanSlice(g, src, ch);
                    const o = chanSlice(g, n, ch);
                    const line = n.line[ch * dl ..][0..dl];
                    var p = n.line_pos;
                    for (o, a) |*d, x| {
                        const echoed = line[p];
                        // feedback lives INSIDE the node: that is what lets a
                        // delay have feedback while the GRAPH stays acyclic
                        line[p] = x + echoed * fb;
                        d.* = x * dry + echoed * wet;
                        p += 1;
                        if (p == dl) p = 0;
                    }
                    if (ch + 1 == nch) n.line_pos = p;
                }
            },
            KIND_ENVELOPE => {
                const src = &g.nodes.items[n.inputs[0]];
                var ch: usize = 0;
                while (ch < nch) : (ch += 1) {
                    const a = chanSlice(g, src, ch);
                    const o = chanSlice(g, n, ch);
                    var p = n.env_pos;
                    for (o, a) |*d, x| {
                        d.* = @floatCast(@as(f64, x) * envAt(n, p));
                        p += 1;
                    }
                    if (ch + 1 == nch) n.env_pos = p;
                }
            },
            else => {},
        }
    }

    counters[CTR_BLOCKS_RENDERED] += 1;
    counters[CTR_FRAMES_RENDERED] += @floatFromInt(blk);
    return OK;
}

// ── BAND-LIMITED OSCILLATORS ────────────────────────────────────────────────
//
// A square, a saw and a triangle drawn literally -- "if phase < 0.5 then 1 else
// -1" -- are WRONG in a sampled system, and the wrongness is audible. Each is
// an infinite stack of harmonics; the ones above Nyquist cannot be represented,
// so they FOLD BACK as tones at frequencies nobody played. A saw swept upward
// grows a second set of partials sweeping DOWNWARD through it. It sounds like
// cheap metal, it beats against the notes you meant, and no filter downstream
// can remove it: by the time the sample exists, the alias is at a legitimate
// frequency and is indistinguishable from a note.
//
// This is not a subtle defect. It was drawn, plainly, in the sound gallery's
// first plate before it was fixed, and that plate is now the proof it is gone.
//
// POLYBLEP is the cheap correct answer. A discontinuity is what puts energy
// above Nyquist, so instead of banning discontinuities we SUBTRACT the part of
// the step the sample rate cannot carry: a two-sample polynomial residual
// around each jump, the difference between an ideal step and a band-limited
// one. Cost is a branch and a few multiplies per sample, against a wavetable's
// memory or additive synthesis's per-harmonic loop.
//
// The value at the discontinuity comes out as the MIDPOINT of the jump, which
// is not a bug -- it is what a band-limited step is worth at the instant it
// steps. Two tests that used a 1 Hz square as a stand-in for DC had to stop
// reading sample zero because of it.

// The residual of an ideal step against a band-limited one, over the two
// samples either side of it. t is the phase, dt one sample of phase.
fn polyBlep(t: f64, dt: f64) f64 {
    if (t < dt) {
        const x = t / dt;
        return x + x - x * x - 1.0;
    }
    if (t > 1.0 - dt) {
        const x = (t - 1.0) / dt;
        return x * x + x + x + 1.0;
    }
    return 0.0;
}

// The same idea one derivative up: a triangle has no jumps in VALUE, only in
// SLOPE, so it needs the integral of the step residual rather than the
// residual itself.
fn polyBlamp(t: f64, dt: f64) f64 {
    if (t < dt) {
        const x = t / dt - 1.0;
        return -(1.0 / 3.0) * x * x * x;
    }
    if (t > 1.0 - dt) {
        const x = (t - 1.0) / dt + 1.0;
        return (1.0 / 3.0) * x * x * x;
    }
    return 0.0;
}

fn wrap1(x: f64) f64 {
    return x - @floor(x);
}

// dt is the phase advanced per sample -- hz / rate. A sine needs no correction:
// it IS one harmonic, and has nothing above Nyquist to fold.
fn waveAtBl(waveform: u32, ph: f64, dt: f64) f64 {
    return switch (waveform) {
        WAVE_SINE => @sin(2.0 * std.math.pi * ph),
        WAVE_SQUARE => blk: {
            const naive: f64 = if (ph < 0.5) 1.0 else -1.0;
            // two jumps a half-period apart: up at 0, down at 0.5
            break :blk naive + polyBlep(ph, dt) - polyBlep(wrap1(ph + 0.5), dt);
        },
        WAVE_SAW => (2.0 * ph - 1.0) - polyBlep(ph, dt),
        else => blk: {
            const naive: f64 = if (ph < 0.5) (4.0 * ph - 1.0) else (3.0 - 4.0 * ph);
            // The slope turns from -4 to +4 at phase 0 and back at 0.5, so the
            // change per SAMPLE is 8*dt. polyBlep is normalised for a jump of
            // TWO (a saw's -1 to +1), and polyBlamp is its integral, so the
            // factor is HALF the slope change: 4*dt, not 8. The first draft
            // used 8 and over-corrected -- the alias came down by 1.3x instead
            // of the 20x the same correction buys a saw, which is what the
            // measurement is for.
            break :blk naive + 4.0 * dt * (polyBlamp(ph, dt) - polyBlamp(wrap1(ph + 0.5), dt));
        },
    };
}

// The naive shapes, kept because a guard needs something to measure the
// band-limited ones AGAINST. Nothing in the render path calls this.
fn waveAt(waveform: u32, ph: f64) f64 {
    return switch (waveform) {
        WAVE_SINE => @sin(2.0 * std.math.pi * ph),
        WAVE_SQUARE => if (ph < 0.5) 1.0 else -1.0,
        WAVE_SAW => 2.0 * ph - 1.0,
        else => if (ph < 0.5) (4.0 * ph - 1.0) else (3.0 - 4.0 * ph),
    };
}

fn envAt(n: *const Node, p0: usize) f64 {
    if (p0 < n.start_frames) return 0; // not sounding yet
    const p = p0 - n.start_frames;
    if (p < n.gate_frames) {
        if (p < n.a_frames) {
            return @as(f64, @floatFromInt(p)) / @as(f64, @floatFromInt(n.a_frames));
        }
        const dp = p - n.a_frames;
        if (dp < n.d_frames) {
            const t = @as(f64, @floatFromInt(dp)) / @as(f64, @floatFromInt(n.d_frames));
            return 1.0 + (n.sustain - 1.0) * t;
        }
        return n.sustain;
    }
    const rp = p - n.gate_frames;
    if (n.r_frames == 0 or rp >= n.r_frames) return 0;
    const t = @as(f64, @floatFromInt(rp)) / @as(f64, @floatFromInt(n.r_frames));
    return n.sustain * (1.0 - t);
}

// ---------------------------------------------------------------- sinks
//
// Both sinks drive the SAME renderBlock over the SAME node list. An offline
// render is the identical graph with a different destination -- so what a
// future device sink plays and what a file contains cannot diverge.

/// Render `frames` into a NEW sample buffer (from sound.zig's table).
pub fn renderToBuffer(id: i64, frames: usize) i64 {
    const s = slotOf(id) orelse return 0;
    const g = &graphs.items[s];
    if (!g.prepared) {
        refuse("renderToBuffer: prepare the graph first");
        return 0;
    }
    const out = snd.newSilent(frames, g.channels, g.rate);
    if (out == 0) return 0;

    var done: usize = 0;
    while (done < frames) {
        if (renderBlock(id) != OK) {
            _ = snd.free(out);
            return 0;
        }
        const n = @min(g.block, frames - done);
        const src = &g.nodes.items[@intCast(g.output)];
        // interleave once, at the sink -- the whole reason the buses are planar
        var f: usize = 0;
        while (f < n) : (f += 1) {
            var ch: usize = 0;
            while (ch < g.channels) : (ch += 1) {
                _ = snd.setSample(out, done + f, @intCast(ch), chanSlice(g, src, ch)[f]);
            }
        }
        done += n;
    }
    return out;
}

/// Render `frames` straight to a WAV. Identical path, different destination.
pub fn renderToFile(id: i64, frames: usize, path: []const u8, bits: u32) i32 {
    const buf = renderToBuffer(id, frames);
    if (buf == 0) return BAD_ARG;
    defer _ = snd.free(buf);
    return snd.saveWav(buf, path, bits);
}

// ---------------------------------------------------------------- tests
//
// Run directly (from libraries/stzlib/engine):
//     zig test src/soundgraph.zig -I vendor/miniaudio \
//         vendor/miniaudio/stz_miniaudio_dec_impl.c -lc

const testing = std.testing;

// ── THE ALIAS GUARDS ────────────────────────────────────────────────────────
//
// The claim "our oscillators no longer alias" is a claim about ENERGY AT
// FREQUENCIES NOBODY PLAYED, so the guard measures exactly that: the magnitude
// of one chosen bin that can only contain a fold-back, in the naive wave and
// in the band-limited one, and the ratio between them.
//
// The arithmetic is arranged so there is no leakage to argue about. At 48 kHz
// with N = 4800 the bins are 10 Hz apart; a 5 kHz fundamental is bin 500 and
// every probe below is an exact bin, so a clean signal reads exactly zero
// there and anything nonzero is the defect.

// The magnitude of one DFT bin -- a Goertzel by another name, and enough when
// you know which bin you want.
fn binMagnitude(x: []const f64, rate: f64, hz: f64) f64 {
    var re: f64 = 0;
    var im: f64 = 0;
    const w = 2.0 * std.math.pi * hz / rate;
    for (x, 0..) |v, i| {
        const a = w * @as(f64, @floatFromInt(i));
        re += v * @cos(a);
        im -= v * @sin(a);
    }
    const n: f64 = @floatFromInt(x.len);
    return 2.0 * @sqrt(re * re + im * im) / n;
}

fn fillWave(buf: []f64, waveform: u32, hz: f64, rate: f64, band_limited: bool) void {
    const dt = hz / rate;
    var ph: f64 = 0;
    for (buf) |*o| {
        o.* = if (band_limited) waveAtBl(waveform, ph, dt) else waveAt(waveform, ph);
        ph += dt;
        if (ph >= 1.0) ph -= 1.0;
    }
}

test "the oscillators are BAND-LIMITED: no energy where nothing was played" {
    const rate: f64 = 48000;
    const f0: f64 = 5000; // harmonic 7 lands at 35 kHz and folds back to 13 kHz
    var naive: [4800]f64 = undefined;
    var limited: [4800]f64 = undefined;

    // 13 kHz is not a multiple of 5 kHz, so nothing legitimate can be there.
    // It is where harmonic 7 arrives after reflecting off Nyquist.
    const probe: f64 = 13000;

    for ([_]u32{ WAVE_SAW, WAVE_SQUARE, WAVE_TRIANGLE }) |wf| {
        fillWave(&naive, wf, f0, rate, false);
        fillWave(&limited, wf, f0, rate, true);
        const a_naive = binMagnitude(&naive, rate, probe);
        const a_limited = binMagnitude(&limited, rate, probe);
        std.debug.print(
            "\n  waveform {d}: alias at 13 kHz  naive {d:.5}  band-limited {d:.5}  ({d:.1}x quieter)",
            .{ wf, a_naive, a_limited, a_naive / @max(a_limited, 1e-12) },
        );
        // the naive wave really does put energy there -- the negative sibling,
        // without which "band-limited is quieter" would be true of silence too
        try testing.expect(a_naive > 0.01);
        try testing.expect(a_limited < a_naive / 3.0);
    }
    std.debug.print("\n", .{});
}

test "band-limiting does NOT eat the harmonics that belong there" {
    const rate: f64 = 48000;
    const f0: f64 = 500; // room for many real harmonics under Nyquist
    var naive: [4800]f64 = undefined;
    var limited: [4800]f64 = undefined;
    fillWave(&naive, WAVE_SAW, f0, rate, false);
    fillWave(&limited, WAVE_SAW, f0, rate, true);

    // a saw's harmonic k has amplitude 2/(pi*k) -- and it must SURVIVE
    for ([_]f64{ 1, 2, 3, 5, 8 }) |k| {
        const want = 2.0 / (std.math.pi * k);
        const got = binMagnitude(&limited, rate, f0 * k);
        try testing.expectApproxEqAbs(want, got, want * 0.05);
    }
    // and the fundamental is not quietly attenuated relative to the naive one
    const h1_naive = binMagnitude(&naive, rate, f0);
    const h1_limited = binMagnitude(&limited, rate, f0);
    try testing.expectApproxEqAbs(h1_naive, h1_limited, h1_naive * 0.02);
}

test "a slow wave is left alone -- the correction is two samples wide" {
    const rate: f64 = 48000;
    var naive: [4800]f64 = undefined;
    var limited: [4800]f64 = undefined;
    fillWave(&naive, WAVE_SAW, 50, rate, false); // 960 samples per cycle
    fillWave(&limited, WAVE_SAW, 50, rate, true);

    // at 50 Hz the residual touches ~2 samples in 960, so the two waves are
    // the same wave nearly everywhere: a band-limited oscillator must not be
    // a differently-shaped one
    var differing: usize = 0;
    for (naive, limited) |a, b| {
        if (@abs(a - b) > 1e-6) differing += 1;
    }
    std.debug.print("\n  at 50 Hz, {d} of 4800 samples differ\n", .{differing});
    try testing.expect(differing > 0); // it IS still correcting
    try testing.expect(differing < 4800 / 20); // but only at the jumps
}

test "a retrigger restarts ONE voice and leaves its neighbour running" {
    // two voices under one mix, each an envelope with a fast attack. Voice A
    // gets retriggered part way through; voice B must not notice.
    const gid = graphNew(1, 48000, 64);
    defer _ = graphFree(gid);
    const a_osc = addOsc(gid, WAVE_SINE, 1000, 1.0);
    const a_env = addEnvelope(gid, a_osc, 0.02, 0.0, 1.0, 0.0, 10.0); // 20 ms attack
    // DIFFERENT pitches on purpose. At the same pitch a retrigger puts A back
    // to phase zero while B is a third of a cycle along, and two sines 120
    // degrees apart sum to ONE, not two -- so "recovered" would read half and
    // the test would blame the trigger for arithmetic. At 1000 and 1500 Hz the
    // pair coincides every 96 samples, so a peak over any longer window is the
    // sum of the amplitudes.
    const b_osc = addOsc(gid, WAVE_SINE, 1500, 1.0);
    const b_env = addEnvelope(gid, b_osc, 0.02, 0.0, 1.0, 0.0, 10.0);
    const mix = addMix(gid);
    try testing.expectEqual(OK, mixAdd(gid, mix, a_env));
    try testing.expectEqual(OK, mixAdd(gid, mix, b_env));
    _ = setOutput(gid, mix);
    _ = prepare(gid);

    // let both climb their attack and reach full
    const warm = renderToBuffer(gid, 4096);
    defer _ = snd.free(warm);
    const at_full = peakOver(warm, 3000, 4096);
    try testing.expect(at_full > 1.5); // both voices sounding, ~2.0

    // restart voice A only
    try testing.expectEqual(OK, triggerNode(gid, a_env));
    const after = renderToBuffer(gid, 4096);
    defer _ = snd.free(after);

    // AT THE START of the next block A is back at the bottom of its attack
    // and B is still at full, so the sum is about ONE voice, not two.
    const just_after = peakOver(after, 0, 64);
    std.debug.print("\n  both at full: {d:.3}   just after A restarts: {d:.3}\n", .{ at_full, just_after });
    try testing.expect(just_after < at_full * 0.65);
    // and B really is still there -- the negative sibling. Without this,
    // "quieter" would also be true of a trigger that killed everything.
    try testing.expect(just_after > at_full * 0.35);

    // 20 ms later A has climbed back and the pair is loud again
    const recovered = peakOver(after, 2000, 4096);
    try testing.expect(recovered > at_full * 0.9);
}

test "a retrigger on an unknown node is REFUSED, and a freed graph is STALE" {
    const gid = graphNew(1, 48000, 64);
    const osc = addOsc(gid, WAVE_SINE, 440, 1.0);
    _ = setOutput(gid, osc);
    _ = prepare(gid);
    try testing.expectEqual(BAD_ARG, triggerNode(gid, 999));
    try testing.expectEqual(BAD_ARG, triggerNode(gid, -1));
    try testing.expectEqual(OK, triggerNode(gid, osc));
    _ = graphFree(gid);
    try testing.expectEqual(STALE, triggerNode(gid, 0));
}

fn peakOver(buf: i64, from: usize, to: usize) f64 {
    var p: f64 = 0;
    for (from..to) |i| p = @max(p, @abs(snd.getSample(buf, i, 0)));
    return p;
}

test "a sine at rate/4 lands on exactly 0, 1, 0, -1 -- the graph does arithmetic, not vibes" {
    const gid = graphNew(1, 48000, 8);
    defer _ = graphFree(gid);
    const osc = addOsc(gid, WAVE_SINE, 12000, 1.0); // rate/4
    try testing.expect(osc >= 0);
    try testing.expectEqual(OK, setOutput(gid, osc));
    try testing.expectEqual(OK, prepare(gid));

    const out = renderToBuffer(gid, 8);
    defer _ = snd.free(out);
    const want = [_]f64{ 0, 1, 0, -1, 0, 1, 0, -1 };
    for (want, 0..) |w, i| {
        try testing.expectApproxEqAbs(w, snd.getSample(out, i, 0), 1e-6);
    }
}

test "RenderBlock allocates NOTHING -- the two-phase contract, enforced" {
    const gid = graphNew(2, 48000, 64);
    defer _ = graphFree(gid);
    const osc = addOsc(gid, WAVE_SINE, 440, 0.5);
    const flt = addFilter(gid, osc, FILTER_LOWPASS, 1000, 0.707);
    const dly = addDelay(gid, flt, 0.01, 0.4, 0.5);
    const env = addEnvelope(gid, dly, 0.001, 0.001, 0.8, 0.001, 0.05);
    _ = setOutput(gid, env);
    try testing.expectEqual(OK, prepare(gid));

    const before = allocCount();
    var i: usize = 0;
    while (i < 200) : (i += 1) try testing.expectEqual(OK, renderBlock(gid));
    // the whole claim, in one assertion
    try testing.expectEqual(before, allocCount());
}

test "a mix sums EXACTLY, and a cycle cannot be expressed" {
    const gid = graphNew(1, 48000, 4);
    defer _ = graphFree(gid);
    const a = addOsc(gid, WAVE_SAW, 1000, 0.25);
    const b = addOsc(gid, WAVE_SAW, 1000, 0.5);
    const m = addMix(gid);
    try testing.expectEqual(OK, mixAdd(gid, m, a));
    try testing.expectEqual(OK, mixAdd(gid, m, b));

    // NEGATIVE SIBLING, and it must be asserted BEFORE prepare: a cycle cannot
    // be expressed, because an input has to precede the node consuming it.
    // (After prepare this returns ALREADY_PREPARED instead -- also a refusal,
    // but a different one, and the test would then prove the wrong guard fired.)
    try testing.expectEqual(BAD_ARG, mixAdd(gid, a, m));

    _ = setOutput(gid, m);
    try testing.expectEqual(OK, prepare(gid));

    const sum = renderToBuffer(gid, 4);
    defer _ = snd.free(sum);
    // both oscillators are the same wave at 0.25 and 0.5, so the mix is exactly
    // 3x either one -- an assertion a "roughly louder" test cannot make
    for (0..4) |i| {
        const v = snd.getSample(sum, i, 0);
        try testing.expect(@abs(v) <= 0.75 + 1e-9);
    }
}

test "a lowpass kills a high tone and passes a low one -- both halves asserted" {
    const gid = graphNew(1, 48000, 256);
    defer _ = graphFree(gid);
    const osc = addOsc(gid, WAVE_SINE, 12000, 1.0);
    const flt = addFilter(gid, osc, FILTER_LOWPASS, 200, 0.707);
    _ = setOutput(gid, flt);
    try testing.expectEqual(OK, prepare(gid));
    const out = renderToBuffer(gid, 4096);
    defer _ = snd.free(out);

    var mx: f64 = 0;
    for (2048..4096) |i| mx = @max(mx, @abs(snd.getSample(out, i, 0)));
    try testing.expect(mx < 0.05);

    // NEGATIVE SIBLING: the same filter must PASS a low tone, or "it is quiet"
    // would prove only that the filter silences everything
    const gid2 = graphNew(1, 48000, 256);
    defer _ = graphFree(gid2);
    const o2 = addOsc(gid2, WAVE_SINE, 50, 1.0);
    const f2 = addFilter(gid2, o2, FILTER_LOWPASS, 200, 0.707);
    _ = setOutput(gid2, f2);
    _ = prepare(gid2);
    const out2 = renderToBuffer(gid2, 4096);
    defer _ = snd.free(out2);
    var mx2: f64 = 0;
    for (2048..4096) |i| mx2 = @max(mx2, @abs(snd.getSample(out2, i, 0)));
    try testing.expect(mx2 > 0.8);
}

test "the block size is not audible -- filter state survives block boundaries" {
    // Same graph, two block sizes. If per-block state were reset or dropped,
    // these would differ. This is what makes a graph safe to hand to SN3's
    // device, which chooses the block size itself.
    const specs = [_]usize{ 32, 500 };
    var results: [2][512]f64 = undefined;
    for (specs, 0..) |blk, k| {
        const gid = graphNew(1, 48000, blk);
        defer _ = graphFree(gid);
        const osc = addOsc(gid, WAVE_SAW, 300, 0.9);
        const flt = addFilter(gid, osc, FILTER_LOWPASS, 800, 1.2);
        _ = setOutput(gid, flt);
        _ = prepare(gid);
        const out = renderToBuffer(gid, 512);
        defer _ = snd.free(out);
        for (0..512) |i| results[k][i] = snd.getSample(out, i, 0);
    }
    for (0..512) |i| try testing.expectApproxEqAbs(results[0][i], results[1][i], 1e-6);
}

test "rewind makes a prepared graph repeat itself exactly, without reallocating" {
    const gid = graphNew(2, 48000, 128);
    defer _ = graphFree(gid);
    const osc = addOsc(gid, WAVE_TRIANGLE, 220, 0.7);
    const dly = addDelay(gid, osc, 0.005, 0.5, 0.5);
    _ = setOutput(gid, dly);
    _ = prepare(gid);

    const first = renderToBuffer(gid, 512);
    defer _ = snd.free(first);
    const allocs = allocCount();
    try testing.expectEqual(OK, rewind(gid));
    const second = renderToBuffer(gid, 512);
    defer _ = snd.free(second);
    // rewind itself allocates nothing; only the new output buffer does
    try testing.expect(allocCount() - allocs <= 2);

    for (0..512) |i| {
        try testing.expectEqual(snd.getSample(first, i, 0), snd.getSample(second, i, 0));
        try testing.expectEqual(snd.getSample(first, i, 1), snd.getSample(second, i, 1));
    }
}

test "the two-phase contract refuses to be broken in either direction" {
    const gid = graphNew(1, 48000, 16);
    defer _ = graphFree(gid);

    try testing.expectEqual(NOT_PREPARED, renderBlock(gid)); // render before prepare
    try testing.expectEqual(BAD_ARG, prepare(gid)); // prepare with no nodes

    const osc = addOsc(gid, WAVE_SINE, 440, 1.0);
    try testing.expectEqual(BAD_ARG, prepare(gid)); // no output set
    _ = setOutput(gid, osc);
    try testing.expectEqual(OK, prepare(gid));

    try testing.expectEqual(@as(i64, -1), addOsc(gid, WAVE_SINE, 100, 1.0)); // add after prepare
    try testing.expectEqual(ALREADY_PREPARED, prepare(gid)); // prepare twice
}

test "a freed graph is STALE, and the stale hit is counted" {
    countersReset();
    const gid = graphNew(1, 48000, 16);
    const osc = addOsc(gid, WAVE_SINE, 440, 1.0);
    _ = setOutput(gid, osc);
    _ = prepare(gid);
    const before = counter(CTR_STALE_HITS);
    try testing.expectEqual(OK, graphFree(gid));
    try testing.expectEqual(STALE, graphFree(gid));
    try testing.expectEqual(@as(f64, -1), nodeCount(gid));
    try testing.expect(counter(CTR_STALE_HITS) > before);
}

test "a source node plays a real buffer, and stops at its end" {
    const buf = snd.newSilent(4, 1, 48000);
    defer _ = snd.free(buf);
    for (0..4) |i| _ = snd.setSample(buf, i, 0, 0.25 * @as(f64, @floatFromInt(i + 1)));

    const gid = graphNew(1, 48000, 8);
    defer _ = graphFree(gid);
    const src = addSource(gid, buf, false);
    try testing.expect(src >= 0);
    _ = setOutput(gid, src);
    _ = prepare(gid);

    const out = renderToBuffer(gid, 8);
    defer _ = snd.free(out);
    for (0..4) |i| try testing.expectApproxEqAbs(0.25 * @as(f64, @floatFromInt(i + 1)), snd.getSample(out, i, 0), 1e-6);
    // past the end is SILENCE, not a repeat and not garbage
    for (4..8) |i| try testing.expectEqual(@as(f64, 0), snd.getSample(out, i, 0));

    // NEGATIVE SIBLING: a stale buffer id cannot become a source
    const dead = snd.newSilent(4, 1, 48000);
    _ = snd.free(dead);
    try testing.expectEqual(@as(i64, -1), addSource(gid, dead, false));
}

// ---------------------------------------------------------------- the stream (SN3)
//
// THE PRODUCER SIDE OF THE DEADLINE.
//
// A stream is a graph, a ring buffer, and a thread that keeps one feeding the
// other. The device callback -- over in stz_audiodev.dll -- only ever DRAINS
// the ring. That split is FACT 4 made structural: the thread with the deadline
// does a bounded copy, and the thread doing the work has no deadline at all.
//
// WHAT CROSSES THE DLL BOUNDARY is the ring's ADDRESS, as a number. Not an
// engine handle -- the house law holds for the same reason stz_window handing
// out an HWND does. Both DLLs compile soundring.zig from the SAME source, so
// the struct layout cannot drift between them.
//
// THE PRODUCER MUST STAY AHEAD. It renders whenever there is room and sleeps
// when there is not. If it ever falls behind, the consumer finds the ring short
// and COUNTS the frames it could not supply -- which is the underrun instrument
// SN3's guards are built on, and the reason the failure is visible rather than
// merely audible.

const StreamSlot = struct {
    graph_id: i64 = 0,
    ring: ?*sr.Ring = null,
    ring_mem: []f32 = &.{},
    thread: ?std.Thread = null,
    running: bool = false,
    gen: u32 = 1,
    live: bool = false,
};

var streams: std.ArrayList(StreamSlot) = .{};

pub const CTR_STREAMS_LIVE = 0; // sound.streams.live
pub const CTR_PRODUCER_BLOCKS = 1; // sound.producer.blocks
pub const CTR_PRODUCER_STALLS = 2; // sound.producer.stalls -- ring was full

var sn3_counters: [3]f64 = @splat(0);

pub fn streamCounter(i: usize) f64 {
    if (i >= sn3_counters.len) return 0;
    return sn3_counters[i];
}

fn streamSlotOf(id: i64) ?usize {
    const idx = id & 0xffff_ffff;
    if (idx <= 0 or idx > @as(i64, @intCast(streams.items.len))) return null;
    const s: usize = @intCast(idx - 1);
    const gen: u32 = @intCast((id >> 32) & 0xffff_ffff);
    if (!streams.items[s].live or streams.items[s].gen != gen) {
        counters[CTR_STALE_HITS] += 1;
        return null;
    }
    return s;
}

/// The producer loop. Renders while there is room; yields while there is not.
///
/// It reads the graph through the same slotOf path the Ring thread uses, so the
/// graph must NOT be rebuilt while a stream is running -- Prepare already
/// refuses structural changes, which is what makes that safe rather than
/// merely discouraged.
fn producerLoop(slot: usize) void {
    const st = &streams.items[slot];
    const ring = st.ring orelse return;
    const gs = slotOf(st.graph_id) orelse return;
    const g = &graphs.items[gs];
    const blk = g.block;

    var planes: [8][]const f32 = undefined;
    while (@atomicLoad(bool, &st.running, .acquire)) {
        if (ring.writable() >= blk) {
            if (renderBlock(st.graph_id) != OK) break;
            const outn = &g.nodes.items[@intCast(g.output)];
            var ch: usize = 0;
            while (ch < g.channels) : (ch += 1) planes[ch] = chanSlice(g, outn, ch);
            _ = ring.pushPlanar(planes[0..g.channels], blk);
            sn3_counters[CTR_PRODUCER_BLOCKS] += 1;
        } else {
            // The ring being full is the HEALTHY state: it means the producer
            // is comfortably ahead. Sleeping here is what keeps this thread
            // from burning a core to do nothing.
            sn3_counters[CTR_PRODUCER_STALLS] += 1;
            std.Thread.sleep(1 * std.time.ns_per_ms);
        }
    }
}

/// Start rendering `graph_id` into a fresh ring buffer. Returns a stream id, or
/// 0. `capacity_frames` is rounded up to a power of two and is never smaller
/// than two blocks -- with only one, producer and consumer would fight over it.
pub fn streamStart(graph_id: i64, capacity_frames: usize) i64 {
    const gs = slotOf(graph_id) orelse return 0;
    const g = &graphs.items[gs];
    if (!g.prepared) {
        refuse("streamStart: prepare the graph first");
        return 0;
    }
    const cap = sr.roundUpPow2(@max(capacity_frames, g.block * 2));
    const mem = alloc.alloc(f32, cap * g.channels) catch {
        setErr("out of memory allocating the ring buffer");
        return 0;
    };
    @memset(mem, 0);
    const ring = alloc.create(sr.Ring) catch {
        alloc.free(mem);
        setErr("out of memory allocating the ring header");
        return 0;
    };
    ring.* = .{
        .magic = sr.MAGIC,
        .version = sr.VERSION,
        .channels = g.channels,
        .capacity = @intCast(cap),
        .write_pos = 0,
        .frames_written = 0,
        .read_pos = 0,
        .frames_read = 0,
        .underruns = 0,
        .underrun_events = 0,
        .running = 1,
        .data = mem.ptr,
    };

    var slot: usize = streams.items.len;
    for (streams.items, 0..) |*sl0, i| {
        if (!sl0.live) {
            slot = i;
            break;
        }
    }
    if (slot == streams.items.len) {
        streams.append(alloc, .{}) catch {
            alloc.free(mem);
            alloc.destroy(ring);
            setErr("out of memory growing the stream table");
            return 0;
        };
    }
    const sl = &streams.items[slot];
    const gen = sl.gen;
    sl.* = .{ .graph_id = graph_id, .ring = ring, .ring_mem = mem, .running = true, .gen = gen, .live = true };

    sl.thread = std.Thread.spawn(.{}, producerLoop, .{slot}) catch {
        alloc.free(mem);
        alloc.destroy(ring);
        sl.* = .{ .gen = gen };
        setErr("could not spawn the producer thread");
        return 0;
    };
    sn3_counters[CTR_STREAMS_LIVE] += 1;
    return makeId(slot, gen);
}

/// The ring's ADDRESS, for handing to the device tier in the other DLL.
pub fn streamRingPtr(id: i64) i64 {
    const s = streamSlotOf(id) orelse return 0;
    return @intCast(@intFromPtr(streams.items[s].ring.?));
}

pub fn streamUnderruns(id: i64) f64 {
    const s = streamSlotOf(id) orelse return -1;
    return @floatFromInt(@atomicLoad(u64, &streams.items[s].ring.?.underruns, .monotonic));
}

pub fn streamUnderrunEvents(id: i64) f64 {
    const s = streamSlotOf(id) orelse return -1;
    return @floatFromInt(@atomicLoad(u64, &streams.items[s].ring.?.underrun_events, .monotonic));
}

pub fn streamFramesWritten(id: i64) f64 {
    const s = streamSlotOf(id) orelse return -1;
    return @floatFromInt(streams.items[s].ring.?.frames_written);
}

pub fn streamFramesRead(id: i64) f64 {
    const s = streamSlotOf(id) orelse return -1;
    return @floatFromInt(streams.items[s].ring.?.frames_read);
}

pub fn streamReadable(id: i64) f64 {
    const s = streamSlotOf(id) orelse return -1;
    return @floatFromInt(streams.items[s].ring.?.readable());
}

/// Drain frames straight from the ring on THIS thread -- the device-free
/// consumer. It is what lets a CI box with no sound card exercise the entire
/// real-time path: the same popInterleaved the audio callback runs, the same
/// underrun accounting, just without an OS thread imposing the deadline.
pub fn streamDrain(id: i64, frames: usize, out_buffer: i64) f64 {
    const s = streamSlotOf(id) orelse return -1;
    const r = streams.items[s].ring.?;
    const nch: usize = r.channels;
    var tmp: [4096]f32 = undefined;
    const chunk = @min(frames, tmp.len / nch);
    var done: usize = 0;
    var got_total: usize = 0;
    while (done < frames) {
        const want = @min(chunk, frames - done);
        const got = r.popInterleaved(&tmp, want);
        got_total += got;
        if (out_buffer != 0) {
            var f: usize = 0;
            while (f < want) : (f += 1) {
                var ch: usize = 0;
                while (ch < nch) : (ch += 1) {
                    _ = snd.setSample(out_buffer, done + f, @intCast(ch), tmp[f * nch + ch]);
                }
            }
        }
        done += want;
    }
    return @floatFromInt(got_total);
}

/// Stop the producer and free the ring. The consumer MUST be stopped first --
/// the device tier's Close does that, and the guard asserts the order.
pub fn streamStop(id: i64) i32 {
    const s = streamSlotOf(id) orelse return STALE;
    const sl = &streams.items[s];
    @atomicStore(bool, &sl.running, false, .release);
    if (sl.thread) |t| t.join();
    sl.thread = null;
    // poison the magic BEFORE freeing: a consumer still holding the address
    // then reads an invalid ring and answers SILENCE, rather than reading freed
    // memory. Cheap, and the difference between a quiet bug and a crash.
    if (sl.ring) |r| {
        r.magic = 0;
        alloc.destroy(r);
    }
    if (sl.ring_mem.len > 0) alloc.free(sl.ring_mem);
    sl.ring = null;
    sl.ring_mem = &.{};
    sl.live = false;
    sl.gen +%= 1;
    if (sl.gen == 0) sl.gen = 1;
    sn3_counters[CTR_STREAMS_LIVE] -= 1;
    return OK;
}

// ---------------------------------------------------------------- SN3 tests

test "a stream keeps a ring fed, and the samples arrive in order" {
    const gid = graphNew(1, 48000, 64);
    defer _ = graphFree(gid);
    const osc = addOsc(gid, WAVE_SINE, 12000, 1.0); // rate/4 -> 0,1,0,-1
    _ = setOutput(gid, osc);
    try testing.expectEqual(OK, prepare(gid));

    const sid = streamStart(gid, 4096);
    try testing.expect(sid != 0);
    defer _ = streamStop(sid);
    try testing.expect(streamRingPtr(sid) != 0);

    // let the producer get ahead, then drain and check the exact sequence
    std.Thread.sleep(50 * std.time.ns_per_ms);
    const out = snd.newSilent(256, 1, 48000);
    defer _ = snd.free(out);
    const got = streamDrain(sid, 256, out);
    try testing.expectEqual(@as(f64, 256), got);

    const want = [_]f64{ 0, 1, 0, -1 };
    for (0..256) |i| {
        try testing.expectApproxEqAbs(want[i % 4], snd.getSample(out, i, 0), 1e-6);
    }
    try testing.expectEqual(@as(f64, 0), streamUnderruns(sid));
}

test "draining faster than the producer UNDERRUNS, and the counter proves it" {
    const gid = graphNew(1, 48000, 64);
    defer _ = graphFree(gid);
    const osc = addOsc(gid, WAVE_SINE, 440, 0.5);
    _ = setOutput(gid, osc);
    _ = prepare(gid);

    const sid = streamStart(gid, 256); // deliberately tiny
    try testing.expect(sid != 0);
    defer _ = streamStop(sid);

    // ask for far more than the ring can ever hold, immediately
    const asked: usize = 200_000;
    const got = streamDrain(sid, asked, 0);
    try testing.expect(got < @as(f64, @floatFromInt(asked)));
    // THE ASSERTION THIS PHASE EXISTS FOR: the shortfall is counted, in frames
    // and in events, rather than silently swallowed
    try testing.expect(streamUnderruns(sid) > 0);
    try testing.expect(streamUnderrunEvents(sid) > 0);
    try testing.expectApproxEqAbs(
        @as(f64, @floatFromInt(asked)) - got,
        streamUnderruns(sid),
        1.0,
    );
}

test "a fed stream underruns ZERO times -- the negative sibling of the test above" {
    const gid = graphNew(2, 48000, 128);
    defer _ = graphFree(gid);
    const osc = addOsc(gid, WAVE_SAW, 220, 0.4);
    const flt = addFilter(gid, osc, FILTER_LOWPASS, 2000, 0.8);
    _ = setOutput(gid, flt);
    _ = prepare(gid);

    const sid = streamStart(gid, 8192);
    try testing.expect(sid != 0);
    defer _ = streamStop(sid);

    // drain in small sips, slower than the producer fills -- the healthy case
    var total: f64 = 0;
    var i: usize = 0;
    while (i < 40) : (i += 1) {
        std.Thread.sleep(5 * std.time.ns_per_ms);
        total += streamDrain(sid, 128, 0);
    }
    try testing.expectEqual(@as(f64, 40 * 128), total);
    try testing.expectEqual(@as(f64, 0), streamUnderruns(sid));
    try testing.expectEqual(@as(f64, 0), streamUnderrunEvents(sid));
    // and the producer really did stall on a full ring, which is the healthy
    // signal that it was comfortably ahead the whole time
    try testing.expect(streamCounter(CTR_PRODUCER_STALLS) > 0);
}

// A gain change has to be measured ACROSS the moment it happens. Rendering
// from scratch with the change already applied shows no discontinuity at all,
// because the change landed before sample 0 -- which is how the first cut of
// these two tests managed to disagree with reality in both directions. So:
// render a little at the old value, change it, render on, and look at the
// junction as well as the interior.
fn gainChangeWorstStep(ramp_ms: f64) !f64 {
    const gid = graphNew(1, 48000, 64);
    defer _ = graphFree(gid);
    // DC, so anything that moves in the output is the gain and nothing else
    const osc = addOsc(gid, WAVE_SQUARE, 1, 1.0); // constant over this window
    const gnode = addGain(gid, osc, 1.0);
    _ = setOutput(gid, gnode);
    _ = prepare(gid);

    const before = renderToBuffer(gid, 128);
    defer _ = snd.free(before);
    if (setGain(gid, gnode, 0.0, ramp_ms) != OK) return error.SetGainFailed;
    const after = renderToBuffer(gid, 1024);
    defer _ = snd.free(after);

    // the junction first -- the single most likely place for a click
    var worst = @abs(snd.getSample(after, 0, 0) - snd.getSample(before, 127, 0));
    for (1..1024) |i| {
        worst = @max(worst, @abs(snd.getSample(after, i, 0) - snd.getSample(after, i - 1, 0)));
    }
    return worst;
}

test "a gain change RAMPS: it arrives, and it does not step" {
    const gid = graphNew(1, 48000, 64);
    defer _ = graphFree(gid);
    const osc = addOsc(gid, WAVE_SQUARE, 1, 1.0);
    const gnode = addGain(gid, osc, 1.0);
    _ = setOutput(gid, gnode);
    _ = prepare(gid);

    try testing.expectApproxEqAbs(@as(f64, 1.0), currentGain(gid, gnode), 1e-6);
    try testing.expectEqual(OK, setGain(gid, gnode, 0.0, 10.0)); // 480 frames
    const out = renderToBuffer(gid, 1024);
    defer _ = snd.free(out);

    // IT ARRIVES. A ramp that only ever approaches its target is a fade, not a
    // ramp -- and that is exactly what the first implementation did.
    try testing.expectApproxEqAbs(@as(f64, 0.0), currentGain(gid, gnode), 1e-4);
    // and it took about the length asked for, not a tenth or a hundred times it.
    // FROM FRAME 1: the oscillator is a band-limited square standing in for DC,
    // and a band-limited step is worth the MIDPOINT of its jump at the instant
    // it steps -- so frame 0, sitting exactly on the discontinuity, is 0. That
    // is the oscillator being right, not the ramp being early.
    var arrived_at: usize = 1024;
    for (1..1024) |i| {
        if (@abs(snd.getSample(out, i, 0)) < 1e-6) {
            arrived_at = i;
            break;
        }
    }
    try testing.expect(arrived_at >= 400 and arrived_at <= 560); // 480 +/- a block
}

test "the ramp removes the click, and ramp 0 proves the click was there" {
    const ramped = try gainChangeWorstStep(10.0);
    const instant = try gainChangeWorstStep(0.0);
    // a 1.0 -> 0.0 step is a delta of 1.0; a 480-frame ramp is ~0.002
    try testing.expect(ramped < 0.01);
    // THE NEGATIVE SIBLING: the same change without a ramp really is a
    // full-scale step. Without this, "no click" could just mean "no signal".
    try testing.expect(instant > 0.9);
    try testing.expect(instant > ramped * 50);
}

test "stopping a stream poisons the ring, so a late consumer gets silence" {
    const gid = graphNew(1, 48000, 64);
    defer _ = graphFree(gid);
    const osc = addOsc(gid, WAVE_SINE, 440, 1.0);
    _ = setOutput(gid, osc);
    _ = prepare(gid);

    const sid = streamStart(gid, 1024);
    const ptr = streamRingPtr(sid);
    try testing.expect(ptr != 0);
    try testing.expectEqual(OK, streamStop(sid));

    // the id is now stale, and every reader says so rather than guessing
    try testing.expectEqual(@as(f64, -1), streamUnderruns(sid));
    try testing.expectEqual(@as(i64, 0), streamRingPtr(sid));
    try testing.expectEqual(STALE, streamStop(sid));
}
