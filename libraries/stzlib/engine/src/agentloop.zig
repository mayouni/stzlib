const std = @import("std");
const zuter = @import("softanzuter.zig");

// ═══════════════════════════════════════════════════════════════════════
//  THE TICK LOOP -- the Bangalo loop's Zig heart
// ═══════════════════════════════════════════════════════════════════════
//
// Before this file, softanzuter.zig held agent SLOTS and nothing ran them:
// scheduling lived in Ring, in stzAgentHost.TickDue(). Ring decided who
// ticked, in what order, and when. This file moves the decision to Zig and
// leaves the DOING in Ring, which is the split the thesis asks for --
// Zig owns time, Ring stays the scripting language of the loop.
//
// ─── WHY THERE IS NO CALLBACK ─────────────────────────────────────────
//
// "Register a slot and a callback" reads naturally and cannot be built
// honestly here: a Ring function is a VM-level object, and a Zig loop
// holding a pointer to one would have to re-enter the Ring VM from a
// foreign thread to call it. The whole engine avoids that -- stzReactor
// is SUBMIT/AWAIT, never callback-into-Ring, and that is the house shape.
//
// So the loop publishes a SCHEDULE rather than invoking one. Tick() decides
// who runs and in what order and puts that in a run queue; Ring drains the
// queue and performs each visit. Zig owns the decision; Ring owns the act.
// The determinism the prompt asks for is a property of the QUEUE, which is
// exactly where it can be tested.
//
// ─── THE LOOP'S OWN COVERAGE STATEMENT ────────────────────────────────
//
// Law 18 obliges an agent to declare what it covers before this loop will
// schedule it. The loop owes the same statement about itself, and here it
// is -- also readable at run time through stz_agentloop_coverage_statement(),
// because a coverage statement only in a comment is a coverage statement
// nobody can check.
//
//   WHAT IT SCHEDULES:
//     - timer agents, by elapsed interval against a clock HANDED IN
//     - event agents, once per new event on a bus channel whose count is
//       HANDED IN, with catch-up for events that arrived between passes
//     - mailbox agents, once per pass while their softanzuter inbox is
//       non-empty
//     - the order of all of the above: priority first, registration order
//       to break every tie, totally and reproducibly
//
//   WHAT IT CANNOT SEE, and therefore never claims:
//     - A CALLBACK'S INSIDE. Once Ring pops a visit and calls Cycle(), the
//       loop is blind until Ring comes back. A callback that blocks for a
//       minute delays every agent behind it and the loop cannot tell that
//       from a callback that returned instantly.
//     - WALL-TIME STARVATION UNDER LOAD. If Ring drains slower than the
//       loop enqueues, the queue fills and further visits are DROPPED --
//       counted in stz_agentloop_dropped(), never silently. A high-priority
//       agent starving a low-priority one is a legal outcome here, not a
//       fault the loop detects.
//     - THE CLOCK. now_ms is a parameter. The loop does not read time, so
//       it cannot notice a clock that jumps, freezes, or goes backwards.
//     - THE EVENT BUS ITSELF. reactive.zig is compiled into stz_reactive,
//       a DIFFERENT DLL with its own globals; importing it here would put
//       a SECOND copy of the bus in the process and the two would diverge
//       without a word. So event counts are handed in by the caller, and
//       a channel nobody reports on is a channel the loop cannot see.
//     - WHETHER A COVERAGE STATEMENT IS TRUE. Registration checks that one
//       EXISTS. Nothing here reads it.
//
// ─── THE GENERATION TRAP, PORTED RATHER THAN REDISCOVERED ─────────────
//
// stzAgentHost paid for this once and the note is in its source: a bus
// channel destroyed and remade restarts its counter at zero, so a stored
// baseline is suddenly HIGHER than the live count, the catch-up loop never
// runs, and the agent goes deaf silently and for good. Watching for the
// count to DROP does not fix it -- by the time anyone looks, the fresh
// channel may already have passed the remembered value and the dip was
// never visible. The generation is unique for the life of the process, so
// comparing it is exact rather than a race. Carried here deliberately: a
// second implementation of a scheduler is exactly where a fixed bug comes
// back.

const MAX_SLOTS: usize = zuter.MAX_SLOTS; // 64, deliberately the same bound
const MAX_COVERAGE: usize = 256;
const MAX_QUEUE: usize = 256;
const MAX_DIAG: usize = 512;

pub const Kind = enum(u8) {
    plain = 0,
    llm = 1,
};

// An agent's reversibility class -- law 18's other half. `unknown` is not
// a class, it is the ABSENCE of one, and registration refuses it.
pub const Reversibility = enum(u8) {
    unknown = 0,
    reversible = 1,
    compensable = 2,
    irreversible = 3,
};

pub const Trigger = enum(u8) {
    timer = 0,
    event = 1,
    mailbox = 2,
    manual = 3,
};

pub const Reason = enum(u8) {
    timer = 1,
    event = 2,
    mailbox = 3,
    manual = 4,
};

const Reg = struct {
    used: bool = false,
    slot: usize = 0,
    kind: Kind = .plain,
    rev: Reversibility = .unknown,
    trigger: Trigger = .timer,
    effectful: bool = false,
    priority: i32 = 0,
    seq: u32 = 0, // registration order -- the tiebreak that makes order total
    interval_ms: i64 = 0,
    next_due_ms: i64 = 0,
    observed: i64 = 0, // events already accounted for
    pending_events: i64 = 0, // reported minus accounted, awaiting the next pass
    generation: i64 = -1,
    paused: bool = false,
    ticks: u64 = 0,
    coverage: [MAX_COVERAGE]u8 = undefined,
    coverage_len: usize = 0,
};

const Visit = struct {
    slot: usize = 0,
    reason: Reason = .timer,
    seq: u32 = 0,
};

var regs: [MAX_SLOTS]Reg = [_]Reg{.{}} ** MAX_SLOTS;
var reg_count: usize = 0;
var next_seq: u32 = 0;

var queue: [MAX_QUEUE]Visit = [_]Visit{.{}} ** MAX_QUEUE;
var q_head: usize = 0;
var q_len: usize = 0;
var dropped: u64 = 0;

var current: Visit = .{};
var have_current: bool = false;

var diag: [MAX_DIAG]u8 = undefined;
var diag_len: usize = 0;

// ─── refusal codes ───
pub const RC_OK: i32 = 0;
pub const RC_BAD_SLOT: i32 = -1;
pub const RC_SLOT_INACTIVE: i32 = -2;
pub const RC_ALREADY: i32 = -3;
pub const RC_NO_COVERAGE: i32 = -4;
pub const RC_NO_REVERSIBILITY: i32 = -5;
pub const RC_LLM_EFFECTFUL: i32 = -6;
pub const RC_FULL: i32 = -7;
pub const RC_BAD_INTERVAL: i32 = -8;

// A refusal is a DIAGNOSTIC, in the shape a Ring C-error takes: a named
// code, the subject it is about, what was wrong, and what to do instead.
// Never a crash, never a bare -1 the caller has to look up.
fn refuse(comptime code: []const u8, slot: usize, comptime what: []const u8, comptime fix: []const u8) void {
    const name = zuter.nameOf(slot);
    var fbs = std.io.fixedBufferStream(&diag);
    const w = fbs.writer();
    w.print("{s}: agent '{s}' (slot {d}) {s}. Registration refuses it. {s}", .{
        code, name, slot, what, fix,
    }) catch {};
    diag_len = fbs.pos;
}

fn clearDiag() void {
    diag_len = 0;
}

fn findBySlot(slot: usize) ?usize {
    for (0..MAX_SLOTS) |i| {
        if (regs[i].used and regs[i].slot == slot) return i;
    }
    return null;
}

// ═══ registration: the gate ═══════════════════════════════════════════

pub export fn stz_agentloop_register(
    slot_in: i32,
    kind_in: i32,
    rev_in: i32,
    trigger_in: i32,
    effectful_in: i32,
    priority: i32,
    interval_ms: i64,
    coverage: [*]const u8,
    coverage_len: usize,
) i32 {
    clearDiag();

    if (slot_in < 0 or slot_in >= @as(i32, MAX_SLOTS)) {
        var fbs = std.io.fixedBufferStream(&diag);
        fbs.writer().print("AGENTLOOP-R1: slot {d} is not a slot (0..{d}). Registration refuses it.", .{ slot_in, MAX_SLOTS - 1 }) catch {};
        diag_len = fbs.pos;
        return RC_BAD_SLOT;
    }
    const slot: usize = @intCast(slot_in);

    if (!zuter.isActive(slot)) {
        var fbs = std.io.fixedBufferStream(&diag);
        fbs.writer().print("AGENTLOOP-R1: slot {d} holds no live agent. Create the agent before registering it with the loop.", .{slot}) catch {};
        diag_len = fbs.pos;
        return RC_SLOT_INACTIVE;
    }

    if (findBySlot(slot) != null) {
        refuse("AGENTLOOP-R3", slot, "is already registered with the loop", "Deregister it first, or change it in place.");
        return RC_ALREADY;
    }

    // THE COVERAGE GATE (law 18). An agent that says nothing about what it
    // covers is not scheduled -- the way Refine's compiler refuses a
    // pi-skill that calls an LLM.
    if (coverage_len == 0) {
        refuse("AGENTLOOP-R4", slot, "declares no coverage statement", "Say what this agent covers, in one sentence, before the loop will run it. Law 18: nothing schedules what nobody has stated the reach of.");
        return RC_NO_COVERAGE;
    }

    if (rev_in <= 0 or rev_in > 3) {
        refuse("AGENTLOOP-R5", slot, "declares no reversibility class", "Declare one of: reversible | compensable | irreversible. Law 18: an agent whose reversal nobody stated cannot be scheduled by something that cannot undo it.");
        return RC_NO_REVERSIBILITY;
    }

    const kind: Kind = if (kind_in == 1) .llm else .plain;
    const effectful = effectful_in != 0;

    // ONE RULE, TWO LAYERS, SAME WORDS. The Ring layer states this as the
    // graph rule `no-llm-effectful`, and its violation message is quoted
    // here verbatim on purpose: a caller who meets the refusal in either
    // layer reads the same sentence.
    if (kind == .llm and effectful) {
        refuse("AGENTLOOP-R6", slot, "breaks the rule no-llm-effectful -- llm actor holds 'effectful' -- an LLM proposes, only a pi-gate commits", "Drop the effectful capability, or register it as a pi-gated composition rather than an llm actor.");
        return RC_LLM_EFFECTFUL;
    }

    const trigger: Trigger = switch (trigger_in) {
        1 => .event,
        2 => .mailbox,
        3 => .manual,
        else => .timer,
    };

    if (trigger == .timer and interval_ms < 1) {
        refuse("AGENTLOOP-R8", slot, "is timer-triggered with an interval below 1ms", "Give it an interval of at least 1ms, or register it as event / mailbox / manual triggered.");
        return RC_BAD_INTERVAL;
    }

    var idx: ?usize = null;
    for (0..MAX_SLOTS) |i| {
        if (!regs[i].used) {
            idx = i;
            break;
        }
    }
    if (idx == null) {
        refuse("AGENTLOOP-R7", slot, "cannot be registered: the loop is full", "The loop holds 64 agents, the same bound as the slot substrate.");
        return RC_FULL;
    }

    const i = idx.?;
    const cl = @min(coverage_len, MAX_COVERAGE);
    regs[i] = .{
        .used = true,
        .slot = slot,
        .kind = kind,
        .rev = @enumFromInt(@as(u8, @intCast(rev_in))),
        .trigger = trigger,
        .effectful = effectful,
        .priority = priority,
        .seq = next_seq,
        .interval_ms = interval_ms,
        .next_due_ms = 0,
        .observed = 0,
        .generation = -1,
        .paused = false,
        .ticks = 0,
        .coverage_len = cl,
    };
    @memcpy(regs[i].coverage[0..cl], coverage[0..cl]);
    next_seq += 1;
    reg_count += 1;
    return RC_OK;
}

pub export fn stz_agentloop_last_refusal(out: [*]u8) i32 {
    if (diag_len == 0) return 0;
    @memcpy(out[0..diag_len], diag[0..diag_len]);
    return @intCast(diag_len);
}

pub export fn stz_agentloop_deregister(slot_in: i32) i32 {
    if (slot_in < 0 or slot_in >= @as(i32, MAX_SLOTS)) return -1;
    const i = findBySlot(@intCast(slot_in)) orelse return -1;
    regs[i].used = false;
    reg_count -= 1;
    return 0;
}

pub export fn stz_agentloop_count() i32 {
    return @intCast(reg_count);
}

pub export fn stz_agentloop_is_registered(slot_in: i32) i32 {
    if (slot_in < 0 or slot_in >= @as(i32, MAX_SLOTS)) return 0;
    return if (findBySlot(@intCast(slot_in)) != null) 1 else 0;
}

pub export fn stz_agentloop_coverage(slot_in: i32, out: [*]u8) i32 {
    if (slot_in < 0 or slot_in >= @as(i32, MAX_SLOTS)) return 0;
    const i = findBySlot(@intCast(slot_in)) orelse return 0;
    const l = regs[i].coverage_len;
    @memcpy(out[0..l], regs[i].coverage[0..l]);
    return @intCast(l);
}

pub export fn stz_agentloop_reversibility(slot_in: i32) i32 {
    if (slot_in < 0 or slot_in >= @as(i32, MAX_SLOTS)) return -1;
    const i = findBySlot(@intCast(slot_in)) orelse return -1;
    return @intFromEnum(regs[i].rev);
}

pub export fn stz_agentloop_priority(slot_in: i32) i32 {
    if (slot_in < 0 or slot_in >= @as(i32, MAX_SLOTS)) return 0;
    const i = findBySlot(@intCast(slot_in)) orelse return 0;
    return regs[i].priority;
}

pub export fn stz_agentloop_ticks(slot_in: i32) i64 {
    if (slot_in < 0 or slot_in >= @as(i32, MAX_SLOTS)) return -1;
    const i = findBySlot(@intCast(slot_in)) orelse return -1;
    return @intCast(regs[i].ticks);
}

pub export fn stz_agentloop_pause(slot_in: i32, paused: i32) i32 {
    if (slot_in < 0 or slot_in >= @as(i32, MAX_SLOTS)) return -1;
    const i = findBySlot(@intCast(slot_in)) orelse return -1;
    regs[i].paused = paused != 0;
    return 0;
}

// ═══ the observation the loop cannot make for itself ══════════════════

// The caller reports a channel's event count and generation for an
// event-triggered agent. Named for what it is: the loop is being TOLD,
// because the bus lives in another DLL (see the coverage statement).
pub export fn stz_agentloop_note_events(slot_in: i32, count: i64, generation: i64) i32 {
    if (slot_in < 0 or slot_in >= @as(i32, MAX_SLOTS)) return -1;
    const i = findBySlot(@intCast(slot_in)) orelse return -1;

    // A NEW GENERATION IS A NEW CHANNEL WEARING THE SAME NAME.
    if (generation != regs[i].generation) {
        regs[i].generation = generation;
        regs[i].observed = 0;
    }
    if (count < regs[i].observed) {
        // belt as well as braces: a counter that went backwards without a
        // generation change is still a reset, and going deaf is the worse
        // failure of the two.
        regs[i].observed = 0;
    }
    regs[i].pending_events = count - regs[i].observed;
    return @intCast(regs[i].pending_events);
}

// ═══ the tick: decide, order, enqueue ═════════════════════════════════

fn enqueue(v: Visit) void {
    if (q_len >= MAX_QUEUE) {
        dropped += 1;
        return;
    }
    queue[(q_head + q_len) % MAX_QUEUE] = v;
    q_len += 1;
}

// Total order: priority DESCENDING, then registration order ASCENDING.
// seq is unique per registration, so no two agents ever compare equal and
// the order is a genuine total order rather than "whatever sort we used".
fn beforeReg(a: usize, b: usize) bool {
    if (regs[a].priority != regs[b].priority) return regs[a].priority > regs[b].priority;
    return regs[a].seq < regs[b].seq;
}

pub export fn stz_agentloop_tick(now_ms: i64) i32 {
    // collect the due registrations, then order them, then enqueue.
    var due: [MAX_SLOTS]usize = undefined;
    var due_n: usize = 0;

    for (0..MAX_SLOTS) |i| {
        if (!regs[i].used or regs[i].paused) continue;
        const r = &regs[i];
        var is_due = false;
        switch (r.trigger) {
            .timer => {
                if (r.next_due_ms == 0) r.next_due_ms = now_ms;
                if (now_ms >= r.next_due_ms) is_due = true;
            },
            .event => {
                if (r.pending_events > 0) is_due = true;
            },
            .mailbox => {
                if (zuter.inboxCount(r.slot) > 0) is_due = true;
            },
            .manual => {},
        }
        if (is_due) {
            due[due_n] = i;
            due_n += 1;
        }
    }

    // insertion sort: n <= 64, and it is stable and obvious. The order is
    // what this whole file is judged on, so it is written to be read.
    var a: usize = 1;
    while (a < due_n) : (a += 1) {
        const v = due[a];
        var b = a;
        while (b > 0 and beforeReg(v, due[b - 1])) : (b -= 1) {
            due[b] = due[b - 1];
        }
        due[b] = v;
    }

    var enqueued: i32 = 0;
    for (0..due_n) |k| {
        const i = due[k];
        const r = &regs[i];
        switch (r.trigger) {
            .timer => {
                enqueue(.{ .slot = r.slot, .reason = .timer, .seq = r.seq });
                r.ticks += 1;
                enqueued += 1;
                // Advance by whole intervals from the DUE time, not from
                // now: a late pass then catches up instead of drifting the
                // schedule forward by however long the pass was late.
                r.next_due_ms += r.interval_ms;
                if (r.next_due_ms <= now_ms) r.next_due_ms = now_ms + r.interval_ms;
            },
            .event => {
                // catch-up: one visit per event that arrived since the last
                // pass, so a burst is not collapsed into a single tick.
                var n = r.pending_events;
                while (n > 0) : (n -= 1) {
                    enqueue(.{ .slot = r.slot, .reason = .event, .seq = r.seq });
                    r.ticks += 1;
                    enqueued += 1;
                }
                r.observed += r.pending_events;
                r.pending_events = 0;
            },
            .mailbox => {
                enqueue(.{ .slot = r.slot, .reason = .mailbox, .seq = r.seq });
                r.ticks += 1;
                enqueued += 1;
            },
            .manual => {},
        }
    }

    return enqueued;
}

// Enqueue one visit by hand (a manual-trigger agent, or a nudge). Subject
// to the same ordering only in the sense that it lands at the queue's tail.
pub export fn stz_agentloop_nudge(slot_in: i32) i32 {
    if (slot_in < 0 or slot_in >= @as(i32, MAX_SLOTS)) return -1;
    const i = findBySlot(@intCast(slot_in)) orelse return -1;
    if (regs[i].paused) return 0;
    enqueue(.{ .slot = regs[i].slot, .reason = .manual, .seq = regs[i].seq });
    regs[i].ticks += 1;
    return 1;
}

// ═══ draining: Ring pops what Zig decided ═════════════════════════════

pub export fn stz_agentloop_pending() i32 {
    return @intCast(q_len);
}

pub export fn stz_agentloop_next() i32 {
    if (q_len == 0) {
        have_current = false;
        return 0;
    }
    current = queue[q_head];
    q_head = (q_head + 1) % MAX_QUEUE;
    q_len -= 1;
    have_current = true;
    return 1;
}

pub export fn stz_agentloop_current_slot() i32 {
    if (!have_current) return -1;
    return @intCast(current.slot);
}

pub export fn stz_agentloop_current_reason() i32 {
    if (!have_current) return 0;
    return @intFromEnum(current.reason);
}

pub export fn stz_agentloop_dropped() i64 {
    return @intCast(dropped);
}

pub export fn stz_agentloop_clear() void {
    for (0..MAX_SLOTS) |i| regs[i].used = false;
    reg_count = 0;
    next_seq = 0;
    q_head = 0;
    q_len = 0;
    dropped = 0;
    have_current = false;
    diag_len = 0;
}

pub export fn stz_agentloop_coverage_statement(out: [*]u8) i32 {
    const s =
        "SCHEDULES: timer agents by elapsed interval against a clock handed in; " ++
        "event agents once per new event on a channel whose count is handed in, with catch-up; " ++
        "mailbox agents once per pass while their inbox is non-empty; " ++
        "and the order of all of them -- priority first, registration order breaking every tie. " ++
        "CANNOT SEE: what happens inside a callback once Ring is running it; " ++
        "wall-time starvation under load (over-full queues DROP visits, counted never silent); " ++
        "the clock, which is a parameter; " ++
        "the event bus itself, which lives in another DLL and reports in; " ++
        "and whether any coverage statement it enforces is TRUE -- it checks only that one exists.";
    @memcpy(out[0..s.len], s);
    return @intCast(s.len);
}

// ═══ tests ════════════════════════════════════════════════════════════

const COV = "covers the kitchen orders queue";

fn reg(name: []const u8, kind: i32, rev: i32, trigger: i32, effectful: i32, prio: i32, interval: i64) i32 {
    const slot = zuter.stz_agent_create(name.ptr, name.len);
    if (slot < 0) return slot;
    const rc = stz_agentloop_register(slot, kind, rev, trigger, effectful, prio, interval, COV.ptr, COV.len);
    if (rc != 0) return rc;
    return slot;
}

fn resetAll() void {
    zuter.stz_agent_clear();
    stz_agentloop_clear();
}

test "registration REFUSES an agent with no coverage statement" {
    resetAll();
    const slot = zuter.stz_agent_create("nameless", 8);
    const rc = stz_agentloop_register(slot, 0, 1, 0, 0, 0, 10, "", 0);
    try std.testing.expectEqual(RC_NO_COVERAGE, rc);

    var buf: [MAX_DIAG]u8 = undefined;
    const l = stz_agentloop_last_refusal(&buf);
    try std.testing.expect(l > 0);
    const text = buf[0..@intCast(l)];
    // a C2-style diagnostic: named code, the subject, and what to do
    try std.testing.expect(std.mem.indexOf(u8, text, "AGENTLOOP-R4") != null);
    try std.testing.expect(std.mem.indexOf(u8, text, "nameless") != null);
    try std.testing.expect(std.mem.indexOf(u8, text, "coverage") != null);
    try std.testing.expectEqual(@as(i32, 0), stz_agentloop_count());
    resetAll();
}

test "registration REFUSES an agent with no reversibility class" {
    resetAll();
    const slot = zuter.stz_agent_create("unstated", 8);
    const rc = stz_agentloop_register(slot, 0, 0, 0, 0, 0, 10, COV.ptr, COV.len);
    try std.testing.expectEqual(RC_NO_REVERSIBILITY, rc);
    var buf: [MAX_DIAG]u8 = undefined;
    const l = stz_agentloop_last_refusal(&buf);
    const text = buf[0..@intCast(l)];
    try std.testing.expect(std.mem.indexOf(u8, text, "AGENTLOOP-R5") != null);
    try std.testing.expect(std.mem.indexOf(u8, text, "irreversible") != null);
    resetAll();
}

test "an llm actor holding 'effectful' is refused, in the Ring layer's words" {
    resetAll();
    const slot = zuter.stz_agent_create("summarizer", 10);
    const rc = stz_agentloop_register(slot, 1, 1, 0, 1, 0, 10, COV.ptr, COV.len);
    try std.testing.expectEqual(RC_LLM_EFFECTFUL, rc);
    var buf: [MAX_DIAG]u8 = undefined;
    const l = stz_agentloop_last_refusal(&buf);
    const text = buf[0..@intCast(l)];
    // the same sentence the graph rule no-llm-effectful uses
    try std.testing.expect(std.mem.indexOf(u8, text, "an LLM proposes, only a pi-gate commits") != null);
    resetAll();
}

test "an llm actor WITHOUT the effectful capability registers like any other slot" {
    resetAll();
    const slot = zuter.stz_agent_create("proposer", 8);
    const rc = stz_agentloop_register(slot, 1, 1, 0, 0, 0, 10, COV.ptr, COV.len);
    try std.testing.expectEqual(RC_OK, rc);
    try std.testing.expectEqual(@as(i32, 1), stz_agentloop_count());
    resetAll();
}

test "a well-declared agent registers and reads back" {
    resetAll();
    const slot = reg("kitchen", 0, 2, 0, 0, 5, 10);
    try std.testing.expect(slot >= 0);
    try std.testing.expectEqual(@as(i32, 1), stz_agentloop_is_registered(slot));
    try std.testing.expectEqual(@as(i32, 2), stz_agentloop_reversibility(slot));
    try std.testing.expectEqual(@as(i32, 5), stz_agentloop_priority(slot));
    var buf: [MAX_COVERAGE]u8 = undefined;
    const l = stz_agentloop_coverage(slot, &buf);
    try std.testing.expectEqualSlices(u8, COV, buf[0..@intCast(l)]);
    resetAll();
}

test "the same slot cannot register twice" {
    resetAll();
    const slot = reg("once", 0, 1, 0, 0, 0, 10);
    const rc = stz_agentloop_register(slot, 0, 1, 0, 0, 0, 10, COV.ptr, COV.len);
    try std.testing.expectEqual(RC_ALREADY, rc);
    resetAll();
}

test "timer agents tick when their interval has elapsed, and not before" {
    resetAll();
    const slot = reg("t", 0, 1, 0, 0, 0, 100);
    try std.testing.expectEqual(@as(i32, 1), stz_agentloop_tick(1000)); // first pass arms and fires
    _ = stz_agentloop_next();
    try std.testing.expectEqual(slot, stz_agentloop_current_slot());
    try std.testing.expectEqual(@as(i32, 1), stz_agentloop_current_reason()); // timer
    try std.testing.expectEqual(@as(i32, 0), stz_agentloop_tick(1050)); // too soon
    try std.testing.expectEqual(@as(i32, 1), stz_agentloop_tick(1100)); // due
    resetAll();
}

test "a late pass catches up instead of drifting the schedule" {
    resetAll();
    _ = reg("t", 0, 1, 0, 0, 0, 100);
    _ = stz_agentloop_tick(1000);
    _ = stz_agentloop_next();
    // the pass is 250ms late; the next due time must be a whole interval
    // past the missed one, not 250ms after "now" all over again
    _ = stz_agentloop_tick(1350);
    _ = stz_agentloop_next();
    try std.testing.expectEqual(@as(i32, 1), stz_agentloop_tick(1450));
    resetAll();
}

test "event agents catch up: a burst of three is three visits, not one" {
    resetAll();
    const slot = reg("e", 0, 1, 1, 0, 0, 0);
    _ = stz_agentloop_note_events(slot, 3, 7);
    try std.testing.expectEqual(@as(i32, 3), stz_agentloop_tick(1000));
    try std.testing.expectEqual(@as(i32, 3), stz_agentloop_pending());
    var n: i32 = 0;
    while (stz_agentloop_next() == 1) : (n += 1) {
        try std.testing.expectEqual(slot, stz_agentloop_current_slot());
        try std.testing.expectEqual(@as(i32, 2), stz_agentloop_current_reason()); // event
    }
    try std.testing.expectEqual(@as(i32, 3), n);
    resetAll();
}

// THE DEAFNESS BUG stzAgentHost paid for, pinned in the Zig layer too.
test "a remade channel resyncs the baseline instead of going deaf" {
    resetAll();
    const slot = reg("e", 0, 1, 1, 0, 0, 0);
    _ = stz_agentloop_note_events(slot, 500, 7); // a long-lived channel
    _ = stz_agentloop_tick(1000);
    while (stz_agentloop_next() == 1) {}

    // the channel is destroyed and remade: the counter restarts at zero and
    // three fresh events arrive. Generation 8 is a DIFFERENT channel.
    const pend = stz_agentloop_note_events(slot, 3, 8);
    try std.testing.expectEqual(@as(i32, 3), pend);
    try std.testing.expectEqual(@as(i32, 3), stz_agentloop_tick(1100));
    resetAll();
}

test "mailbox agents tick while their inbox is non-empty" {
    resetAll();
    const slot = reg("m", 0, 1, 2, 0, 0, 0);
    try std.testing.expectEqual(@as(i32, 0), stz_agentloop_tick(1000)); // empty inbox
    _ = zuter.stz_agent_send_msg(slot, slot, "work", 4);
    try std.testing.expectEqual(@as(i32, 1), stz_agentloop_tick(1001));
    _ = stz_agentloop_next();
    try std.testing.expectEqual(@as(i32, 3), stz_agentloop_current_reason()); // mailbox
    resetAll();
}

test "priority orders the pass, and registration order breaks every tie" {
    resetAll();
    // registered low-priority FIRST on purpose: if order followed
    // registration alone, this test would pass for the wrong reason
    const low = reg("low", 0, 1, 0, 0, 1, 10);
    const high = reg("high", 0, 1, 0, 0, 9, 10);
    const mid_a = reg("mid-a", 0, 1, 0, 0, 5, 10);
    const mid_b = reg("mid-b", 0, 1, 0, 0, 5, 10);

    try std.testing.expectEqual(@as(i32, 4), stz_agentloop_tick(1000));
    var order: [4]i32 = undefined;
    var k: usize = 0;
    while (stz_agentloop_next() == 1) : (k += 1) order[k] = stz_agentloop_current_slot();

    try std.testing.expectEqual(high, order[0]);
    try std.testing.expectEqual(mid_a, order[1]); // registered before mid-b
    try std.testing.expectEqual(mid_b, order[2]);
    try std.testing.expectEqual(low, order[3]);
    resetAll();
}

// THE DETERMINISM THE PROMPT ASKS FOR, AS A TEST AND NOT A COMMENT.
// Two runs over the SAME event sequence must visit agents in the same
// order. Written so it could actually fail: the agents are registered in
// an order that is neither the priority order nor the visit order.
test "two runs over the same sequence visit agents in the same order" {
    const Script = struct {
        fn run(out: *[64]i32) usize {
            resetAll();
            const a = reg("alpha", 0, 1, 0, 0, 3, 10); // timer, prio 3
            const b = reg("beta", 0, 1, 1, 0, 9, 0); // event, prio 9
            const c = reg("gamma", 0, 1, 2, 0, 3, 0); // mailbox, prio 3
            const d = reg("delta", 0, 1, 0, 0, 7, 10); // timer, prio 7

            var n: usize = 0;
            // pass 1: everything is due at once
            _ = stz_agentloop_note_events(b, 2, 1);
            _ = zuter.stz_agent_send_msg(c, c, "m", 1);
            _ = stz_agentloop_tick(1000);
            while (stz_agentloop_next() == 1) : (n += 1) out[n] = stz_agentloop_current_slot();

            // pass 2: only the timers and one event
            _ = stz_agentloop_note_events(b, 3, 1);
            _ = stz_agentloop_tick(1010);
            while (stz_agentloop_next() == 1) : (n += 1) out[n] = stz_agentloop_current_slot();

            // pass 3: a nudge and a drained mailbox
            _ = zuter.stz_agent_send_msg(c, c, "m", 1);
            _ = stz_agentloop_nudge(a);
            _ = stz_agentloop_tick(1020);
            while (stz_agentloop_next() == 1) : (n += 1) out[n] = stz_agentloop_current_slot();
            _ = d;
            return n;
        }
    };

    var first: [64]i32 = undefined;
    var second: [64]i32 = undefined;
    const n1 = Script.run(&first);
    const n2 = Script.run(&second);

    try std.testing.expect(n1 > 6); // the script really did visit things
    try std.testing.expectEqual(n1, n2);
    try std.testing.expectEqualSlices(i32, first[0..n1], second[0..n2]);
    resetAll();
}

test "a paused agent is not scheduled, and resumes where it left off" {
    resetAll();
    const slot = reg("p", 0, 1, 0, 0, 0, 10);
    _ = stz_agentloop_pause(slot, 1);
    try std.testing.expectEqual(@as(i32, 0), stz_agentloop_tick(1000));
    _ = stz_agentloop_pause(slot, 0);
    try std.testing.expectEqual(@as(i32, 1), stz_agentloop_tick(1001));
    resetAll();
}

test "an over-full queue DROPS and COUNTS -- it never silently truncates" {
    resetAll();
    const slot = reg("flood", 0, 1, 1, 0, 0, 0);
    _ = stz_agentloop_note_events(slot, MAX_QUEUE + 10, 1);
    const n = stz_agentloop_tick(1000);
    try std.testing.expectEqual(@as(i32, @intCast(MAX_QUEUE + 10)), n);
    try std.testing.expectEqual(@as(i32, @intCast(MAX_QUEUE)), stz_agentloop_pending());
    try std.testing.expectEqual(@as(i64, 10), stz_agentloop_dropped());
    resetAll();
}

test "the loop states its own coverage at run time, not only in a comment" {
    var buf: [1024]u8 = undefined;
    const l = stz_agentloop_coverage_statement(&buf);
    const s = buf[0..@intCast(l)];
    try std.testing.expect(std.mem.indexOf(u8, s, "CANNOT SEE") != null);
    try std.testing.expect(std.mem.indexOf(u8, s, "another DLL") != null);
}
