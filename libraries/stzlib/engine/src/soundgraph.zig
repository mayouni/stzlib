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

// THE ARITHMETIC OF A SOUND lives in one place, so the native tier and the
// browser tier cannot drift on what a sawtooth is. See sounddsp.zig for why
// that seam had to exist at all -- freestanding wasm32 has no libc, and this
// file's sample table does.
pub const dsp = @import("sounddsp.zig");
/// Also public, and for the same reason: the studio server wants the device
/// tier without declaring a second module over the same files.
pub const dev = @import("audiodev.zig");
/// And the analysis tier, so the studio can DRAW what it just rendered. Same
/// reason again: one module, reached through one import.
pub const ana = @import("soundanalysis.zig");

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
pub const KIND_TIMELINE: u32 = 8;

pub const WAVE_SINE = dsp.WAVE_SINE;
pub const WAVE_SQUARE = dsp.WAVE_SQUARE;
pub const WAVE_SAW = dsp.WAVE_SAW;
pub const WAVE_TRIANGLE = dsp.WAVE_TRIANGLE;

pub const FILTER_LOWPASS = dsp.FILTER_LOWPASS;
pub const FILTER_HIGHPASS = dsp.FILTER_HIGHPASS;
pub const FILTER_BANDPASS = dsp.FILTER_BANDPASS;

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
    // MU1: a source played at a RATE -- how one recording becomes an instrument
    // at any pitch. -1 means never set, and then the source takes the original
    // integer path unchanged, so every guard written before MU1 stays
    // bit-identical. `pos_f` is the fractional read position; -1 = seed from pos.
    rate_target: f64 = -1,
    pos_f: f64 = -1,

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

    // MU0 CONTROL: pitch per note. The same three-field discipline as the gain
    // above -- a target another thread writes, a value the render owns, a step
    // planned ONCE when a new target is first seen -- because a frequency that
    // jumps between two samples is a phase discontinuity, and a phase
    // discontinuity is a click exactly as an amplitude step is. `n.hz` stays
    // what the node was DECLARED with; `freq_now` is what renders. Both are
    // lazily seeded from `hz` on the first block (a sentinel of -1 means
    // "never set"), so adding a node needs no change to know about ramps.
    freq_target: f64 = -1,
    freq_now: f64 = -1,
    freq_ramp_frames: u32 = 0,
    freq_step: f64 = 0,
    freq_seen: f64 = -1,

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

    // MU2 TIMELINE: notes placed at exact frames. Heap-allocated when the node
    // is added (before Prepare, like everything the render will touch), so the
    // node table stays small and the slots never move.
    tl: ?*Timeline = null,

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

// THE TABLES ARE ADDRESS-STABLE, AND THAT IS A CORRECTNESS PROPERTY, NOT A
// TUNING CHOICE.
//
// A running producer thread holds `&streams.items[slot]` and `&graphs.items[gs]`
// for its whole life (see producerLoop). An ArrayList that GROWS reallocates its
// backing buffer and frees the old one -- so opening a SECOND stream, or even
// creating a second graph, pulled the memory out from under the first producer
// while it was reading. It then rendered from freed memory and the process died
// inside @intCast with "integer does not fit in destination type": a
// use-after-free wearing a bounds-check's clothes.
//
// Reserving the whole table up front and REFUSING past the cap makes the
// addresses permanent, so the cached pointers stay valid for as long as the
// slot lives. The cap is what turns an unbounded hazard into a counted refusal.
// Both tables already reuse dead slots first, so the cap bounds LIVE objects,
// not objects ever created.
const MAX_GRAPHS = 64;
const MAX_STREAMS = 16;

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
    if (graphs.items.len >= MAX_GRAPHS) {
        refuse("graphNew: 64 graphs are already live -- free one first");
        return 0;
    }
    // reserve ONCE, to the cap: after this the buffer never moves, so the
    // pointers a producer thread caches stay pointing at their own slot
    graphs.ensureTotalCapacity(alloc, MAX_GRAPHS) catch {
        setErr("out of memory growing the graph table");
        return 0;
    };
    graphs.appendAssumeCapacity(g);
    counters[CTR_GRAPHS_LIVE] += 1;
    return makeId(graphs.items.len - 1, 1);
}

pub fn graphFree(id: i64) i32 {
    const s = slotOf(id) orelse return STALE;
    const g = &graphs.items[s];
    for (g.nodes.items) |*n| {
        if (n.line.len > 0) alloc.free(n.line);
        if (n.tl) |t| alloc.destroy(t);
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

/// MU0: pitch per note. Built as setGain is built -- an atomic target, a ramp
/// length released before it, a step the render plans once -- because the
/// music plan's first engine change had to be the one the whole plane already
/// knows how to guard. A ramp of 0 is a jump, and a jump is a click; it is
/// offered so a guard has its negative sibling, exactly as with the gain.
pub fn setFrequency(id: i64, node: i64, hz: f64, ramp_ms: f64) i32 {
    const s = slotOf(id) orelse return STALE;
    const g = &graphs.items[s];
    if (!validInput(g, node)) {
        refuse("setFrequency: that node does not exist");
        return BAD_ARG;
    }
    const n = &g.nodes.items[@intCast(node)];
    if (n.kind != KIND_OSC) {
        refuse("setFrequency: that node is not an oscillator");
        return BAD_ARG;
    }
    if (hz <= 0 or hz >= @as(f64, @floatFromInt(g.rate)) / 2.0) {
        refuse("setFrequency: a frequency must be positive and below Nyquist");
        return BAD_ARG;
    }
    const frames: u32 = if (ramp_ms <= 0) 0 else @intFromFloat(ramp_ms * @as(f64, @floatFromInt(g.rate)) / 1000.0);
    @atomicStore(u32, &n.freq_ramp_frames, frames, .monotonic);
    @atomicStore(f64, &n.freq_target, hz, .release);
    return OK;
}

/// The frequency the render is applying right now -- mid-ramp, somewhere
/// between the old value and the target. -1 for a node that is not an
/// oscillator or has not rendered yet, and a guard reads it to prove the ramp
/// both MOVES and ARRIVES.
pub fn currentFrequency(id: i64, node: i64) f64 {
    const s = slotOf(id) orelse return -1;
    const g = &graphs.items[s];
    if (!validInput(g, node)) return -1;
    const n = &g.nodes.items[@intCast(node)];
    if (n.kind != KIND_OSC) return -1;
    return @atomicLoad(f64, &n.freq_now, .monotonic);
}

/// MU1: play a source at a RATE -- 2 is an octave up, 0.5 an octave down --
/// by linear interpolation between frames. A rate of exactly 1 returns the
/// source to its original integer path. The change is immediate: a rate jump
/// is a kink in the slope, not an amplitude step, and a pitch BEND with a ramp
/// is a later phase's.
pub fn setRate(id: i64, node: i64, ratio: f64) i32 {
    const s = slotOf(id) orelse return STALE;
    const g = &graphs.items[s];
    if (!validInput(g, node)) {
        refuse("setRate: that node does not exist");
        return BAD_ARG;
    }
    const n = &g.nodes.items[@intCast(node)];
    if (n.kind != KIND_SOURCE) {
        refuse("setRate: that node is not a source");
        return BAD_ARG;
    }
    if (!(ratio >= 0.0625 and ratio <= 16.0)) {
        refuse("setRate: a rate must be between 1/16 and 16");
        return BAD_ARG;
    }
    @atomicStore(f64, &n.rate_target, ratio, .release);
    return OK;
}

fn renderSourceAtRate(g: *Graph, n: *Node, ratio: f64, src_ch: usize, src_frames: usize, nch: usize, blk: usize) void {
    if (n.pos_f < 0) n.pos_f = @floatFromInt(n.pos);
    const last: f64 = if (src_frames >= 2) @floatFromInt(src_frames - 1) else 0;
    var ch: usize = 0;
    while (ch < nch) : (ch += 1) {
        const dst = chanSlice(g, n, ch);
        const use_ch = if (src_ch == 0) 0 else @min(ch, src_ch - 1);
        var p = n.pos_f;
        for (dst) |*o| {
            if (src_frames < 2 or p >= last) {
                if (n.loop and src_frames >= 2) {
                    p = @mod(p, last);
                } else {
                    o.* = 0;
                    p += ratio;
                    continue;
                }
            }
            const k0: usize = @intFromFloat(@floor(p));
            const fr = p - @floor(p);
            const a = snd.getSample(n.buffer_id, k0, @intCast(use_ch));
            const b = snd.getSample(n.buffer_id, k0 + 1, @intCast(use_ch));
            o.* = @floatCast(a + (b - a) * fr);
            p += ratio;
        }
    }
    var p2 = n.pos_f + ratio * @as(f64, @floatFromInt(blk));
    if (n.loop and src_frames >= 2) p2 = @mod(p2, last);
    n.pos_f = p2;
    n.pos = @intFromFloat(@min(@floor(p2), @as(f64, @floatFromInt(src_frames))));
}

// ── MU2: THE TIMELINE -- a note placed at a frame, not at a block ────────────
//
// MU0 spike 2 measured the plane's only way to start a sound in the future:
// ask, and the render honours the request at the top of its next block. Worst
// 9.48 ms late, mean 4.81, against MU2's kill criterion of 1 ms. A trigger at
// a block boundary cannot meet that bar however early it is asked, so the
// question MU0 left to the ear ("is 10.7 ms audible as swing?") is answered by
// the phase's own number before any ear is needed.
//
// The plan (section 3, Gap 2) said the fix is a trigger with a frame offset
// INSIDE a block, applied to any node. That is a change to every node kind's
// render loop -- each would have to split its block at an arbitrary frame.
// A note does not need it. A note is a buffer the instrument already rendered
// (MU1), and placing a buffer at frame F of a block is an offset into the
// block, nothing else. So the timeline is ONE new node kind that mixes placed
// buffers into its output at the frame asked, and every other node is
// untouched. What it does NOT give: a setFrequency or a gain change at a frame
// inside a block. Recorded in the STATUS, not discovered later.
//
// THE THREADING is the plane's existing discipline, one slot at a time. A slot
// is FREE (0) or ARMED (1). Only the caller's thread moves FREE -> ARMED, after
// writing every field, with a release store; only the render moves ARMED ->
// FREE, when the note has played out. So each slot has exactly one writer at a
// time and no lock is needed on either side -- the trigger flag's reasoning,
// widened to a table.
//
// LATENESS IS COUNTED, NEVER HIDDEN. The render sees a slot at the top of a
// block. If its frame has already been rendered, the caller asked too late:
// the note plays from the top of this block (shifted, not truncated), and the
// shift is added to the counters. A scheduler that is not ahead of the
// deadline shows up there as a number.

const TL_SLOTS = 512;

pub const TL_PLACED = 0; // notes accepted
pub const TL_LATE = 1; // notes whose frame had already been rendered
pub const TL_LATE_MAX = 2; // the worst lateness, in frames
pub const TL_REFUSED = 3; // placements refused: no free slot
pub const TL_RETIRED = 4; // notes that played out
pub const TL_ARMED = 5; // slots holding a note right now (read from the table)

const TlSlot = struct {
    state: u32 = 0,
    frame: u64 = 0,
    data: [*]const f32 = undefined,
    frames: usize = 0,
    channels: u32 = 1,
    gain: f32 = 1,
    seq: u64 = 0, // placement order: the tie-break when two notes share a frame
    seen: bool = false, // render-owned once armed
};

const Timeline = struct {
    slots: [TL_SLOTS]TlSlot = @splat(.{}),
    clock: u64 = 0, // frames rendered; written by the render, read by anyone
    ctr: [5]u64 = @splat(0),
};

fn timelineClear(t: *Timeline) void {
    for (&t.slots) |*sl| @atomicStore(u32, &sl.state, 0, .release);
    @atomicStore(u64, &t.clock, 0, .release);
}

fn timelineOf(id: i64, node: i64) ?*Timeline {
    const s = slotOf(id) orelse return null;
    const g = &graphs.items[s];
    if (!validInput(g, node)) return null;
    const n = &g.nodes.items[@intCast(node)];
    if (n.kind != KIND_TIMELINE) return null;
    return n.tl;
}

/// A node whose output is the notes placed on it. It has no input.
pub fn addTimeline(id: i64) i64 {
    const s = slotOf(id) orelse return -1;
    const g = &graphs.items[s];
    if (g.prepared) {
        refuse("cannot add nodes after Prepare -- build the graph, then prepare it");
        return -1;
    }
    const t = alloc.create(Timeline) catch {
        setErr("out of memory allocating a timeline");
        return -1;
    };
    t.* = .{};
    const idx = addNode(g, .{ .kind = KIND_TIMELINE, .tl = t });
    if (idx < 0) alloc.destroy(t);
    return idx;
}

/// Place a buffer on a timeline, to start at timeline frame `frame` (0-based,
/// counted from the timeline's first rendered frame), scaled by `gain`. Safe
/// from any ONE thread while the graph renders on another. The buffer must be
/// at the graph's rate, mono or of the graph's channel count, and must NOT be
/// freed until the timeline has retired it (TL_ARMED reaches 0) or the stream
/// is stopped -- the render reads its samples directly.
pub fn timelinePlace(id: i64, node: i64, buffer_id: i64, frame: f64, gain: f64) i32 {
    const s = slotOf(id) orelse return STALE;
    const g = &graphs.items[s];
    const t = timelineOf(id, node) orelse {
        refuse("timelinePlace: that node is not a timeline");
        return BAD_ARG;
    };
    const v = snd.rawView(buffer_id) orelse {
        refuse("timelinePlace: the buffer is stale, unknown or empty");
        return BAD_ARG;
    };
    if (v.rate != g.rate) {
        refuse("timelinePlace: the note's sample rate is not the graph's -- a different pitch, silently");
        return BAD_ARG;
    }
    if (v.channels != 1 and v.channels != g.channels) {
        refuse("timelinePlace: the note is neither mono nor of the graph's channel count");
        return BAD_ARG;
    }
    if (!(frame >= 0)) {
        refuse("timelinePlace: a frame is 0 or later");
        return BAD_ARG;
    }
    for (&t.slots) |*sl| {
        if (@atomicLoad(u32, &sl.state, .acquire) != 0) continue;
        sl.frame = @intFromFloat(@round(frame));
        sl.data = v.data;
        sl.frames = v.frames;
        sl.channels = v.channels;
        sl.gain = @floatCast(gain);
        sl.seen = false;
        sl.seq = @atomicRmw(u64, &t.ctr[TL_PLACED], .Add, 1, .monotonic);
        @atomicStore(u32, &sl.state, 1, .release);
        return OK;
    }
    _ = @atomicRmw(u64, &t.ctr[TL_REFUSED], .Add, 1, .monotonic);
    refuse("timelinePlace: all 512 slots hold a note -- place fewer at once, or wait for some to play out");
    return BAD_ARG;
}

/// The frames this timeline has rendered: the render clock a scheduler must
/// stay ahead of. The producer runs up to a ring ahead of what is audible, so
/// this is NOT what the listener hears -- that is the stream's frames read.
pub fn timelineNow(id: i64, node: i64) f64 {
    const t = timelineOf(id, node) orelse return -1;
    return @floatFromInt(@atomicLoad(u64, &t.clock, .acquire));
}

pub fn timelineCounter(id: i64, node: i64, which: u32) f64 {
    const t = timelineOf(id, node) orelse return -1;
    if (which == TL_ARMED) {
        var k: f64 = 0;
        for (&t.slots) |*sl| {
            if (@atomicLoad(u32, &sl.state, .acquire) != 0) k += 1;
        }
        return k;
    }
    if (which >= t.ctr.len) return -1;
    return @floatFromInt(@atomicLoad(u64, &t.ctr[which], .monotonic));
}

fn tlBefore(x: *const TlSlot, y: *const TlSlot) bool {
    if (x.frame != y.frame) return x.frame < y.frame;
    return x.seq < y.seq;
}

fn renderTimeline(g: *Graph, n: *Node) void {
    const t = n.tl orelse return;
    const nch: usize = g.channels;
    const blk: u64 = g.block;
    var ch: usize = 0;
    while (ch < nch) : (ch += 1) @memset(chanSlice(g, n, ch), 0);

    const clock = t.clock;

    // Pass 1: which notes sound in this block (and which arrived late).
    var act: [TL_SLOTS]u16 = undefined;
    var na: usize = 0;
    for (&t.slots, 0..) |*sl, si| {
        if (@atomicLoad(u32, &sl.state, .acquire) != 1) continue;
        if (!sl.seen) {
            sl.seen = true;
            if (sl.frame < clock) {
                const late = clock - sl.frame;
                _ = @atomicRmw(u64, &t.ctr[TL_LATE], .Add, 1, .monotonic);
                _ = @atomicRmw(u64, &t.ctr[TL_LATE_MAX], .Max, late, .monotonic);
                sl.frame = clock; // shifted to the top of this block, never cut
            }
        }
        if (sl.frame >= clock + blk) continue; // not yet
        act[na] = @intCast(si);
        na += 1;
    }

    // Pass 2: mix them IN START ORDER -- (frame, then the order they were
    // placed in). The first cut mixed in SLOT order, and which slot a note
    // gets depends on which notes had already retired when it was placed --
    // that is, on thread timing. f32 addition is not associative, so two live
    // renders of the same overlapping score differed in the last bit, and by
    // a different amount each run (30 and then 60 billionths, measured by the
    // MU2 guard). In start order the sum is the one the offline render
    // (mixInto, in the plan's order) computes, so live and offline are the
    // SAME, bit for bit, however the threads interleave.
    var a: usize = 1;
    while (a < na) : (a += 1) {
        const k = act[a];
        var b = a;
        while (b > 0 and tlBefore(&t.slots[k], &t.slots[act[b - 1]])) : (b -= 1) act[b] = act[b - 1];
        act[b] = k;
    }
    for (act[0..na]) |si| {
        const sl = &t.slots[si];
        const off: usize = @intCast(if (sl.frame > clock) sl.frame - clock else 0);
        const from: usize = @intCast(clock + off - sl.frame);
        const count = @min(g.block - off, sl.frames - from);
        ch = 0;
        while (ch < nch) : (ch += 1) {
            const dst = chanSlice(g, n, ch)[off..][0..count];
            const sc: usize = if (sl.channels == 1) 0 else ch;
            const stride: usize = sl.channels;
            for (dst, 0..) |*o, i| o.* += sl.gain * sl.data[(from + i) * stride + sc];
        }
        if (from + count >= sl.frames) {
            _ = @atomicRmw(u64, &t.ctr[TL_RETIRED], .Add, 1, .monotonic);
            @atomicStore(u32, &sl.state, 0, .release);
        }
    }
    @atomicStore(u64, &t.clock, clock + blk, .release);
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
    const bq = dsp.biquadOf(n.f_kind, n.freq, n.q, rate);
    n.b0 = bq.b0;
    n.b1 = bq.b1;
    n.b2 = bq.b2;
    n.a1 = bq.a1;
    n.a2 = bq.a2;
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
        n.pos_f = -1;
        n.env_pos = 0;
        n.line_pos = 0;
        n.x1 = @splat(0);
        n.x2 = @splat(0);
        n.y1 = @splat(0);
        n.y2 = @splat(0);
        if (n.line.len > 0) @memset(n.line, 0);
        if (n.tl) |t| timelineClear(t);
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
    n.pos_f = -1;
    n.env_pos = 0;
    n.line_pos = 0;
    n.x1 = @splat(0);
    n.x2 = @splat(0);
    n.y1 = @splat(0);
    n.y2 = @splat(0);
    if (n.line.len > 0) @memset(n.line, 0);
    if (n.tl) |t| timelineClear(t);
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
                const ratef = @as(f64, @floatFromInt(g.rate));
                // ACQUIRE, pairing with the release in setFrequency
                const t_raw = @atomicLoad(f64, &n.freq_target, .acquire);
                const ramp = @atomicLoad(u32, &n.freq_ramp_frames, .monotonic);
                if (n.freq_now < 0) n.freq_now = n.hz; // first block: seed from the declaration
                const target: f64 = if (t_raw < 0) n.freq_now else t_raw;
                if (target != n.freq_seen) {
                    n.freq_seen = target;
                    if (ramp == 0) {
                        n.freq_now = target;
                        n.freq_step = 0;
                    } else {
                        n.freq_step = (target - n.freq_now) / @as(f64, @floatFromInt(ramp));
                    }
                }
                var fq = n.freq_now;
                const step = n.freq_step;
                var ph = n.phase;
                const dst = chanSlice(g, n, 0);
                for (dst) |*o| {
                    // the increment follows the CURRENT frequency, sample by
                    // sample, so the phase stays continuous through a ramp
                    const inc = fq / ratef;
                    o.* = @floatCast(n.amp * waveAtBl(n.waveform, ph, inc));
                    ph += inc;
                    if (ph >= 1.0) ph -= 1.0;
                    if (fq != target) {
                        fq += step;
                        if ((step > 0 and fq > target) or (step < 0 and fq < target)) fq = target;
                    }
                }
                n.phase = ph;
                n.freq_now = fq;
                @atomicStore(f64, &n.freq_now, fq, .monotonic);
                // an oscillator is mono; every other channel carries the same
                var ch: usize = 1;
                while (ch < nch) : (ch += 1) @memcpy(chanSlice(g, n, ch), dst);
            },
            KIND_SOURCE => {
                const src_ch: usize = @intFromFloat(@max(0, snd.channelCount(n.buffer_id)));
                const src_frames: usize = @intFromFloat(@max(0, snd.frameCount(n.buffer_id)));
                // ACQUIRE, pairing with the release in setRate
                const ratio = @atomicLoad(f64, &n.rate_target, .acquire);
                if (ratio > 0 and ratio != 1.0) {
                    renderSourceAtRate(g, n, ratio, src_ch, src_frames, nch, blk);
                    continue;
                }
                // back at rate 1 after a fractional stretch: resume at the frame
                if (n.pos_f >= 0) {
                    n.pos = @intFromFloat(@floor(n.pos_f));
                    n.pos_f = -1;
                }
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
            KIND_TIMELINE => renderTimeline(g, n),
            else => {},
        }
    }

    counters[CTR_BLOCKS_RENDERED] += 1;
    counters[CTR_FRAMES_RENDERED] += @floatFromInt(blk);
    return OK;
}

// The oscillator arithmetic now lives in sounddsp.zig -- one definition of what
// a sawtooth is, shared by the native render and the browser render. The long
// explanation of polyBLEP, and of why a triangle needs polyBLAMP at HALF the
// slope change, is there with it.
const polyBlep = dsp.polyBlep;
const polyBlamp = dsp.polyBlamp;
const wrap1 = dsp.wrap1;
const waveAtBl = dsp.waveAtBl;
const waveAt = dsp.waveAt;

fn envAt(n: *const Node, p0: usize) f64 {
    return dsp.envAt(.{
        .a_frames = n.a_frames,
        .d_frames = n.d_frames,
        .sustain = n.sustain,
        .r_frames = n.r_frames,
        .gate_frames = n.gate_frames,
        .start_frames = n.start_frames,
    }, p0);
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
        .rate = g.rate,
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
        if (streams.items.len >= MAX_STREAMS) {
            alloc.free(mem);
            alloc.destroy(ring);
            refuse("streamStart: 16 streams are already live -- stop one first");
            return 0;
        }
        // reserve to the cap, so the table never moves under a live producer
        streams.ensureTotalCapacity(alloc, MAX_STREAMS) catch {
            alloc.free(mem);
            alloc.destroy(ring);
            setErr("out of memory growing the stream table");
            return 0;
        };
        streams.appendAssumeCapacity(.{});
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

test "a SECOND stream does not pull the table out from under the first" {
    // THE REGRESSION. Two live streams -- two transports, or an earcon pool
    // plus a spoken phrase -- used to kill the process: streams.append grew the
    // table, freed the old buffer, and the first producer thread went on
    // reading the freed slot. It died inside @intCast, which reads like a
    // bounds bug and is really a use-after-free. Both tables are reserved to
    // their cap now, so the addresses are permanent.
    const g1 = graphNew(1, 48000, 64);
    defer _ = graphFree(g1);
    _ = setOutput(g1, addOsc(g1, WAVE_SINE, 12000, 1.0));
    try testing.expectEqual(OK, prepare(g1));
    const s1 = streamStart(g1, 4096);
    try testing.expect(s1 != 0);
    defer _ = streamStop(s1);
    std.Thread.sleep(20 * std.time.ns_per_ms);

    // a second GRAPH first: producerLoop caches &graphs.items[gs] too, so
    // growing THAT table was the same hazard by another door
    const g2 = graphNew(1, 48000, 64);
    defer _ = graphFree(g2);
    _ = setOutput(g2, addOsc(g2, WAVE_SINE, 12000, 0.5));
    try testing.expectEqual(OK, prepare(g2));
    const s2 = streamStart(g2, 4096);
    try testing.expect(s2 != 0);
    defer _ = streamStop(s2);
    std.Thread.sleep(50 * std.time.ns_per_ms);

    // the FIRST stream must still be producing its own signal, untouched
    const out = snd.newSilent(256, 1, 48000);
    defer _ = snd.free(out);
    try testing.expectEqual(@as(f64, 256), streamDrain(s1, 256, out));
    const want = [_]f64{ 0, 1, 0, -1 };
    for (0..256) |i| {
        try testing.expectApproxEqAbs(want[i % 4], snd.getSample(out, i, 0), 1e-6);
    }
    try testing.expectEqual(@as(f64, 0), streamUnderruns(s1));

    // and the second is producing ITS amplitude, so they are not aliased
    const out2 = snd.newSilent(256, 1, 48000);
    defer _ = snd.free(out2);
    try testing.expectEqual(@as(f64, 256), streamDrain(s2, 256, out2));
    try testing.expectApproxEqAbs(@as(f64, 0.5), snd.getSample(out2, 1, 0), 1e-6);
}

test "the stream table REFUSES past its cap rather than reallocating" {
    // The cap is what makes the addresses permanent, so it has to be a
    // refusal -- a table that grows "just this once" is the bug again.
    const gid = graphNew(1, 48000, 64);
    defer _ = graphFree(gid);
    _ = setOutput(gid, addOsc(gid, WAVE_SINE, 440, 0.5));
    try testing.expectEqual(OK, prepare(gid));

    var ids: [MAX_STREAMS]i64 = @splat(0);
    var n: usize = 0;
    while (n < MAX_STREAMS) : (n += 1) {
        ids[n] = streamStart(gid, 256);
        if (ids[n] == 0) break;
    }
    defer for (ids[0..n]) |sid| {
        if (sid != 0) _ = streamStop(sid);
    };
    // whatever the table already held, one more than the cap must be refused
    try testing.expectEqual(@as(i64, 0), streamStart(gid, 256));
}

test "MU0: a frequency ramp MOVES, ARRIVES, and keeps the phase continuous" {
    const gid = graphNew(1, 48000, 64);
    defer _ = graphFree(gid);
    const osc = addOsc(gid, WAVE_SINE, 440, 0.5);
    _ = setOutput(gid, osc);
    try testing.expectEqual(OK, prepare(gid));
    // before any render the reader says -1: nothing has been seeded yet
    try testing.expectEqual(@as(f64, -1), currentFrequency(gid, osc));
    try testing.expectEqual(OK, renderBlock(gid));
    try testing.expectApproxEqAbs(@as(f64, 440), currentFrequency(gid, osc), 1e-9);
    // a 10 ms ramp is 480 frames; after one 64-frame block it has LEFT 440
    // and NOT reached 880
    try testing.expectEqual(OK, setFrequency(gid, osc, 880, 10));
    try testing.expectEqual(OK, renderBlock(gid));
    const mid = currentFrequency(gid, osc);
    try testing.expect(mid > 441 and mid < 879);
    // and after enough blocks it ARRIVES exactly
    var i: usize = 0;
    while (i < 10) : (i += 1) try testing.expectEqual(OK, renderBlock(gid));
    try testing.expectApproxEqAbs(@as(f64, 880), currentFrequency(gid, osc), 1e-9);
    // refusals: not an oscillator, and above Nyquist
    const gn = addGain(gid, osc, 1.0);
    try testing.expectEqual(BAD_ARG, setFrequency(gid, gn, 440, 0));
    try testing.expectEqual(BAD_ARG, setFrequency(gid, osc, 30000, 0));
}

test "MU1: mixInto ADDS at an offset, refuses a rate mismatch, and stops at the end" {
    const d = snd.newSilent(100, 1, 48000);
    defer _ = snd.free(d);
    const s = snd.newSilent(10, 1, 48000);
    defer _ = snd.free(s);
    var i: usize = 0;
    while (i < 10) : (i += 1) _ = snd.setSample(s, i, 0, 0.25);
    try testing.expectEqual(@as(f64, 10), snd.mixInto(d, s, 20, 1.0));
    try testing.expectEqual(@as(f64, 10), snd.mixInto(d, s, 25, 2.0)); // overlaps: ADDS
    try testing.expectApproxEqAbs(@as(f64, 0), snd.getSample(d, 19, 0), 1e-9);
    try testing.expectApproxEqAbs(@as(f64, 0.25), snd.getSample(d, 20, 0), 1e-6);
    try testing.expectApproxEqAbs(@as(f64, 0.75), snd.getSample(d, 27, 0), 1e-6);
    try testing.expectEqual(@as(f64, 5), snd.mixInto(d, s, 95, 1.0)); // five fit
    const r = snd.newSilent(10, 1, 44100);
    defer _ = snd.free(r);
    try testing.expectEqual(@as(f64, -1), snd.mixInto(d, r, 0, 1.0));
}

test "MU1: a source at rate 2 sounds an octave up; rate 1 is the old path" {
    const buf = snd.newSilent(48000, 1, 48000);
    defer _ = snd.free(buf);
    var i: usize = 0;
    while (i < 48000) : (i += 1) _ = snd.setSample(buf, i, 0, @sin(2.0 * std.math.pi * 100.0 * @as(f64, @floatFromInt(i)) / 48000.0));
    const gid = graphNew(1, 48000, 64);
    defer _ = graphFree(gid);
    const src = addSource(gid, buf, false);
    _ = setOutput(gid, src);
    try testing.expectEqual(OK, prepare(gid));
    try testing.expectEqual(OK, setRate(gid, src, 2.0));
    const out = renderToBuffer(gid, 9600); // 0.2 s
    defer _ = snd.free(out);
    var zc: usize = 0;
    i = 1;
    while (i < 9600) : (i += 1) {
        if (snd.getSample(out, i - 1, 0) < 0 and snd.getSample(out, i, 0) >= 0) zc += 1;
    }
    // 100 Hz at twice the rate is 200 Hz: forty rising crossings in 0.2 s
    try testing.expect(zc >= 39 and zc <= 41);
    // refusals
    try testing.expectEqual(BAD_ARG, setRate(gid, src, 0));
    try testing.expectEqual(BAD_ARG, setRate(gid, src, 100));
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

// ── THE TWO TIERS AGREE, SAMPLE FOR SAMPLE ──────────────────────────────────
//
// This is the assertion sounddsp.zig exists to make possible. The native tier
// here and the browser tier in soundwasm.zig share no code EXCEPT the
// arithmetic -- different storage, different lifetimes, different allocators
// (one has none) -- so if the same graph produces the same samples through
// both, the only thing that could have made that true is the shared DSP.
//
// A browser tier with its own copy of the oscillator would pass every test it
// wrote for itself and still drift from native. The drift would be inaudible
// until somebody rendered the same music twice and compared, which is to say:
// after shipping.

const swasm = @import("soundwasm.zig");

test "THE TWO TIERS AGREE: native and wasm render the same graph identically" {
    const rate: u32 = 48000;
    const blk: u32 = 128;

    // the same graph, built twice through two unrelated builders
    const gid = graphNew(2, rate, blk);
    defer _ = graphFree(gid);
    const n_osc = addOsc(gid, WAVE_SAW, 220, 0.5);
    const n_flt = addFilter(gid, n_osc, FILTER_LOWPASS, 1200, 1.4);
    const n_env = addEnvelope(gid, n_flt, 0.01, 0.2, 0.6, 0.3, 0.5);
    const n_o2 = addOsc(gid, WAVE_TRIANGLE, 331, 0.4);
    const n_mix = addMix(gid);
    _ = mixAdd(gid, n_mix, n_env);
    _ = mixAdd(gid, n_mix, n_o2);
    const n_pan = addPan(gid, n_mix, 0.3);
    _ = setOutput(gid, n_pan);
    _ = prepare(gid);

    try testing.expectEqual(swasm.OK, swasm.reset(rate, 2, blk));
    const w_osc = swasm.addOsc(WAVE_SAW, 220, 0.5);
    const w_flt = swasm.addFilter(w_osc, FILTER_LOWPASS, 1200, 1.4);
    const w_env = swasm.addEnvelope(w_flt, 0.01, 0.2, 0.6, 0.3, 0.5);
    const w_o2 = swasm.addOsc(WAVE_TRIANGLE, 331, 0.4);
    const w_mix = swasm.addMix();
    _ = swasm.mixAdd(w_mix, w_env);
    _ = swasm.mixAdd(w_mix, w_o2);
    const w_pan = swasm.addPan(w_mix, 0.3);
    _ = swasm.setOutput(w_pan);
    try testing.expectEqual(swasm.OK, swasm.prepare());

    // eight blocks, so filter state, envelope position and phase all carry
    // across a block boundary in both tiers before anything is compared
    const out = renderToBuffer(gid, blk * 8);
    defer _ = snd.free(out);

    var worst: f64 = 0;
    var b: usize = 0;
    while (b < 8) : (b += 1) {
        try testing.expectEqual(blk, swasm.renderBlock());
        var f: usize = 0;
        while (f < blk) : (f += 1) {
            for (0..2) |ch| {
                const native = snd.getSample(out, b * blk + f, @intCast(ch));
                const wasmv = swasm.sampleAt(@intCast(f), @intCast(ch));
                worst = @max(worst, @abs(native - wasmv));
            }
        }
    }
    std.debug.print("\n  worst native-vs-wasm difference over 8 blocks: {e}\n", .{worst});
    // f32 storage on both sides, same arithmetic in f64 -- so this is EXACT,
    // not close. A tolerance here would hide exactly the drift being hunted.
    try testing.expectEqual(@as(f64, 0), worst);
}

test "and they DISAGREE when the graph differs -- the negative sibling" {
    const rate: u32 = 48000;
    const blk: u32 = 128;
    const gid = graphNew(1, rate, blk);
    defer _ = graphFree(gid);
    const a = addOsc(gid, WAVE_SAW, 220, 0.5);
    _ = setOutput(gid, a);
    _ = prepare(gid);

    _ = swasm.reset(rate, 1, blk);
    const w = swasm.addOsc(WAVE_SAW, 221, 0.5); // one hertz apart, on purpose
    _ = swasm.setOutput(w);
    _ = swasm.prepare();

    const out = renderToBuffer(gid, blk);
    defer _ = snd.free(out);
    _ = swasm.renderBlock();
    var worst: f64 = 0;
    for (0..blk) |f| {
        worst = @max(worst, @abs(snd.getSample(out, f, 0) - swasm.sampleAt(@intCast(f), 0)));
    }
    // if this were also 0, the comparison above would be measuring nothing
    try testing.expect(worst > 1e-4);
}

// ---------------------------------------------------------------- MU2 tests

fn tlTestNote(frames: usize) i64 {
    // 1.0 on the first frame, then a decay: an onset a threshold cannot misread
    const b = snd.newSilent(frames, 1, 48000);
    var f: usize = 0;
    while (f < frames) : (f += 1) {
        _ = snd.setSample(b, f, 0, std.math.pow(f64, 0.999, @floatFromInt(f)));
    }
    return b;
}

test "MU2: a note placed at a frame starts AT that frame, inside a block and across its edge" {
    const gid = graphNew(1, 48000, 64);
    defer _ = graphFree(gid);
    const tl = addTimeline(gid);
    try testing.expect(tl >= 0);
    _ = setOutput(gid, tl);
    try testing.expectEqual(OK, prepare(gid));

    const b = snd.newSilent(5, 1, 48000);
    defer _ = snd.free(b);
    for (0..5) |i| _ = snd.setSample(b, i, 0, 0.1 * @as(f64, @floatFromInt(i + 1)));

    try testing.expectEqual(OK, timelinePlace(gid, tl, b, 0, 1.0)); // the very first frame
    try testing.expectEqual(OK, timelinePlace(gid, tl, b, 100, 1.0)); // offset 36 of block 1
    try testing.expectEqual(OK, timelinePlace(gid, tl, b, 126, 2.0)); // straddles 127|128

    const out = renderToBuffer(gid, 256);
    defer _ = snd.free(out);
    var expect: [256]f64 = @splat(0);
    for (0..5) |i| {
        const v = 0.1 * @as(f64, @floatFromInt(i + 1));
        expect[i] += v;
        expect[100 + i] += v;
        expect[126 + i] += 2.0 * v;
    }
    for (0..256) |f| try testing.expectApproxEqAbs(expect[f], snd.getSample(out, f, 0), 1e-6);
    try testing.expectEqual(@as(f64, 3), timelineCounter(gid, tl, TL_PLACED));
    try testing.expectEqual(@as(f64, 3), timelineCounter(gid, tl, TL_RETIRED));
    try testing.expectEqual(@as(f64, 0), timelineCounter(gid, tl, TL_ARMED));
    try testing.expectEqual(@as(f64, 0), timelineCounter(gid, tl, TL_LATE));
    try testing.expectEqual(@as(f64, 256), timelineNow(gid, tl));
}

test "MU2: a note asked for too late is SHIFTED to the next block and COUNTED" {
    const gid = graphNew(1, 48000, 64);
    defer _ = graphFree(gid);
    const tl = addTimeline(gid);
    _ = setOutput(gid, tl);
    _ = prepare(gid);
    const b = tlTestNote(8);
    defer _ = snd.free(b);

    _ = renderBlock(gid);
    _ = renderBlock(gid); // the clock is at 128
    try testing.expectEqual(OK, timelinePlace(gid, tl, b, 10, 1.0)); // 118 frames in the past
    _ = renderBlock(gid);
    const g = &graphs.items[slotOf(gid).?];
    // it plays from the top of the block -- all of it, not its tail
    try testing.expectApproxEqAbs(@as(f64, 1.0), chanSlice(g, &g.nodes.items[@intCast(tl)], 0)[0], 1e-6);
    try testing.expectEqual(@as(f64, 1), timelineCounter(gid, tl, TL_LATE));
    try testing.expectEqual(@as(f64, 118), timelineCounter(gid, tl, TL_LATE_MAX));
}

test "MU2: the timeline refuses what would sound wrong, and a full table is a counted refusal" {
    const gid = graphNew(2, 48000, 64);
    defer _ = graphFree(gid);
    const osc = addOsc(gid, WAVE_SINE, 440, 1.0);
    const tl = addTimeline(gid);
    _ = setOutput(gid, tl);
    _ = prepare(gid);
    const b = tlTestNote(8);
    defer _ = snd.free(b);
    const b44 = snd.newSilent(8, 1, 44100);
    defer _ = snd.free(b44);
    const b3 = snd.newSilent(8, 3, 48000);
    defer _ = snd.free(b3);
    const dead = snd.newSilent(8, 1, 48000);
    _ = snd.free(dead);

    try testing.expectEqual(BAD_ARG, timelinePlace(gid, osc, b, 0, 1)); // not a timeline
    try testing.expectEqual(BAD_ARG, timelinePlace(gid, tl, b44, 0, 1)); // another rate
    try testing.expectEqual(BAD_ARG, timelinePlace(gid, tl, b3, 0, 1)); // 3 channels into 2
    try testing.expectEqual(BAD_ARG, timelinePlace(gid, tl, dead, 0, 1)); // freed
    try testing.expectEqual(BAD_ARG, timelinePlace(gid, tl, b, -1, 1)); // before the start
    try testing.expectEqual(@as(f64, 0), timelineCounter(gid, tl, TL_PLACED));

    var k: usize = 0;
    while (k < TL_SLOTS) : (k += 1) try testing.expectEqual(OK, timelinePlace(gid, tl, b, 100000, 1));
    try testing.expectEqual(BAD_ARG, timelinePlace(gid, tl, b, 100000, 1));
    try testing.expectEqual(@as(f64, 1), timelineCounter(gid, tl, TL_REFUSED));
    try testing.expectEqual(@as(f64, TL_SLOTS), timelineCounter(gid, tl, TL_ARMED));
    // rewind is "from the top, nothing scheduled"
    try testing.expectEqual(OK, rewind(gid));
    try testing.expectEqual(@as(f64, 0), timelineCounter(gid, tl, TL_ARMED));
    try testing.expectEqual(@as(f64, 0), timelineNow(gid, tl));
}

// THE KILL CRITERION, at the engine. Two hundred notes at 180 BPM, placed from
// THIS thread while the producer thread renders them into a ring, and read
// back out of the ring. The consumer drains as fast as the ring fills, so the
// producer runs at full CPU speed -- far faster than a device would ask --
// which is the hard case for a scheduler that has to stay ahead of it.
const TlRun = struct { late: f64, late_max_ms: f64, worst_ms: f64, found: usize };

fn tlStreamRun(lookahead: u64) !TlRun {
    const rate: u32 = 48000;
    const blk: usize = 512;
    const gid = graphNew(1, rate, blk);
    defer _ = graphFree(gid);
    const tl = addTimeline(gid);
    _ = setOutput(gid, tl);
    _ = prepare(gid);
    const note = tlTestNote(2000);
    defer _ = snd.free(note);

    const n_notes: usize = 200;
    const spacing: u64 = 16000; // one beat at 180 BPM, 48 kHz
    const first: u64 = 4800 + 37; // off the block grid on purpose
    const total: usize = @intCast(first + spacing * n_notes + 4000);

    // PRIME BEFORE START. The first cut placed nothing until the stream was
    // running, and the first note came out LATE: the producer fills the whole
    // ring (16384 frames, 341 ms) the instant it starts, before this thread
    // has placed anything. A scheduler posts its first window, then starts.
    var next: usize = 0;
    while (next < n_notes and first + spacing * next < lookahead) : (next += 1) {
        try testing.expectEqual(OK, timelinePlace(gid, tl, note, @floatFromInt(first + spacing * next), 1.0));
    }
    const sid = streamStart(gid, 16384);
    try testing.expect(sid != 0);
    const ring = streams.items[streamSlotOf(sid).?].ring.?;
    const cap = try alloc.alloc(f32, total);
    defer alloc.free(cap);
    var got: usize = 0;
    while (got < total) {
        const now: u64 = @intFromFloat(timelineNow(gid, tl));
        while (next < n_notes and first + spacing * next < now + lookahead) : (next += 1) {
            try testing.expectEqual(OK, timelinePlace(gid, tl, note, @floatFromInt(first + spacing * next), 1.0));
        }
        const want = @min(total - got, 4096);
        if (ring.readable() < want) {
            std.Thread.sleep(200 * std.time.ns_per_us);
            continue;
        }
        got += ring.popInterleaved(cap[got..].ptr, want);
    }
    const late = timelineCounter(gid, tl, TL_LATE);
    const late_max_ms = timelineCounter(gid, tl, TL_LATE_MAX) * 1000.0 / @as(f64, @floatFromInt(rate));
    _ = streamStop(sid);

    var worst: f64 = 0;
    var found: usize = 0;
    for (0..n_notes) |k| {
        const at: usize = @intCast(first + spacing * k);
        var f = at - 1000;
        while (f < at + 8000 and @abs(cap[f]) < 0.5) : (f += 1) {}
        if (f < at + 8000) found += 1;
        const off = @abs(@as(f64, @floatFromInt(f)) - @as(f64, @floatFromInt(at)));
        worst = @max(worst, off * 1000.0 / @as(f64, @floatFromInt(rate)));
    }
    return .{ .late = late, .late_max_ms = late_max_ms, .worst_ms = worst, .found = found };
}

test "MU2 KILL CRITERION: 200 notes at 180 BPM through a live ring, worst onset error under 1 ms" {
    const r = try tlStreamRun(16384 + 24000);
    std.debug.print("\n  MU2 ahead: late {d}, worst onset error {d:.4} ms, found {d}/200\n", .{ r.late, r.worst_ms, r.found });
    try testing.expectEqual(@as(usize, 200), r.found);
    try testing.expectEqual(@as(f64, 0), r.late);
    try testing.expect(r.worst_ms < 1.0);
}

test "MU2: and a scheduler that is NOT ahead is caught -- the negative sibling" {
    // a lookahead of one block while the producer runs a ring ahead: notes land late
    const r = try tlStreamRun(512);
    // (its onset search stops 8000 frames out, so a note later than that is
    // "not found" -- the engine's own late counter is the number to read)
    std.debug.print("\n  MU2 behind: {d} of 200 late, the worst by {d:.2} ms\n", .{ r.late, r.late_max_ms });
    try testing.expect(r.late > 0);
    try testing.expect(r.late_max_ms > 1.0);
}

test "MU2: notes are mixed in START order, not slot order -- live equals offline to the bit" {
    // Three notes meet at output frame 5 with 1.0, -1.0 and 1e-8. In f32,
    // (1 - 1) + 1e-8 = 1e-8 but (1e-8 + 1) - 1 = 0: the order of the sum is
    // audible to a bit-exact comparison. Start order is A, C, B. They are
    // PLACED B, A, C, so slot order is B, A, C -- the order the first cut
    // summed in, and the one that depended on thread timing.
    const gid = graphNew(1, 48000, 64);
    defer _ = graphFree(gid);
    const tl = addTimeline(gid);
    _ = setOutput(gid, tl);
    _ = prepare(gid);
    const a = snd.newSilent(8, 1, 48000);
    defer _ = snd.free(a);
    const c = snd.newSilent(8, 1, 48000);
    defer _ = snd.free(c);
    const b = snd.newSilent(8, 1, 48000);
    defer _ = snd.free(b);
    _ = snd.setSample(a, 5, 0, 1.0); // A at frame 0 -> output 5
    _ = snd.setSample(c, 3, 0, -1.0); // C at frame 2 -> output 5
    _ = snd.setSample(b, 1, 0, 1e-8); // B at frame 4 -> output 5

    try testing.expectEqual(OK, timelinePlace(gid, tl, b, 4, 1.0));
    try testing.expectEqual(OK, timelinePlace(gid, tl, a, 0, 1.0));
    try testing.expectEqual(OK, timelinePlace(gid, tl, c, 2, 1.0));
    const live = renderToBuffer(gid, 64);
    defer _ = snd.free(live);

    // the offline render: mixInto, in start order
    const off = snd.newSilent(64, 1, 48000);
    defer _ = snd.free(off);
    _ = snd.mixInto(off, a, 0, 1.0);
    _ = snd.mixInto(off, c, 2, 1.0);
    _ = snd.mixInto(off, b, 4, 1.0);

    const want: f32 = (@as(f32, 1.0) + @as(f32, -1.0)) + @as(f32, 1e-8);
    try testing.expect(want != 0); // the order DOES matter for these values
    try testing.expectEqual(@as(f64, want), snd.getSample(off, 5, 0));
    try testing.expectEqual(snd.getSample(off, 5, 0), snd.getSample(live, 5, 0));
}
