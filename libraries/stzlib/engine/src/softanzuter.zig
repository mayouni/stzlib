const std = @import("std");

// ─── Softanzuter Agent Substrate ───
// Named agent slots with state (idle/active/done/error), message passing.
//
// THE MAILBOX IS A QUEUE (2026-08-20). It used to be one 512-byte buffer
// that stz_agent_send_msg OVERWROTE: a second message sent before the
// first was received destroyed the first, silently, with rc 0 reported to
// the sender. That is not a mailbox, and "drain the mailboxes" -- what the
// tick loop in agentloop.zig is obliged to do -- has no meaning against a
// buffer of one. It is a bounded ring of MAX_INBOX messages now; a send
// into a full queue is REFUSED with rc -2 and counted, never dropped
// quietly. Single send / single receive behaves exactly as before, which
// is why the original tests below are unchanged.

const MAX_AGENTS: usize = 64;
const MAX_NAME: usize = 128;
const MAX_MSG: usize = 512;
const MAX_INBOX: usize = 8;

const AgentState = enum(u8) {
    idle = 0,
    active = 1,
    done = 2,
    err = 3,
};

const Msg = struct {
    buf: [MAX_MSG]u8 = undefined,
    len: usize = 0,
};

const Agent = struct {
    name: [MAX_NAME]u8 = undefined,
    name_len: usize = 0,
    state: AgentState = .idle,
    inbox: [MAX_INBOX]Msg = [_]Msg{.{}} ** MAX_INBOX,
    inbox_head: usize = 0,
    inbox_count: usize = 0,
    active: bool = false,
};

var agents: [MAX_AGENTS]Agent = [_]Agent{.{}} ** MAX_AGENTS;
var agent_count: usize = 0;
var refused_sends: u64 = 0;

// ─── in-process helpers (agentloop.zig reads these; same DLL) ───

pub fn isActive(idx: usize) bool {
    if (idx >= MAX_AGENTS) return false;
    return agents[idx].active;
}

pub fn inboxCount(idx: usize) usize {
    if (idx >= MAX_AGENTS) return 0;
    return agents[idx].inbox_count;
}

pub fn nameOf(idx: usize) []const u8 {
    if (idx >= MAX_AGENTS) return "";
    return agents[idx].name[0..agents[idx].name_len];
}

pub const MAX_SLOTS: usize = MAX_AGENTS;

// ─── C ABI ───

pub export fn stz_agent_create(name: [*]const u8, name_len: usize) i32 {
    if (agent_count >= MAX_AGENTS) return -1;
    for (0..MAX_AGENTS) |i| {
        if (!agents[i].active) {
            const nl = @min(name_len, MAX_NAME);
            @memcpy(agents[i].name[0..nl], name[0..nl]);
            agents[i].name_len = nl;
            agents[i].state = .idle;
            agents[i].inbox_head = 0;
            agents[i].inbox_count = 0;
            agents[i].active = true;
            agent_count += 1;
            return @intCast(i);
        }
    }
    return -1;
}

pub export fn stz_agent_set_state(idx: i32, state: i32) i32 {
    if (idx < 0 or idx >= @as(i32, MAX_AGENTS)) return -1;
    const i: usize = @intCast(idx);
    if (!agents[i].active) return -1;
    if (state < 0 or state > 3) return -1;
    agents[i].state = @enumFromInt(@as(u8, @intCast(state)));
    return 0;
}

pub export fn stz_agent_get_state(idx: i32) i32 {
    if (idx < 0 or idx >= @as(i32, MAX_AGENTS)) return -1;
    const i: usize = @intCast(idx);
    if (!agents[i].active) return -1;
    return @intFromEnum(agents[i].state);
}

// rc 0 = queued, -1 = no such agent, -2 = mailbox FULL (refused and
// counted -- the caller is told, which the overwriting version never did).
pub export fn stz_agent_send_msg(from_idx: i32, to_idx: i32, msg: [*]const u8, msg_len: usize) i32 {
    _ = from_idx; // sender tracked for future routing
    if (to_idx < 0 or to_idx >= @as(i32, MAX_AGENTS)) return -1;
    const to: usize = @intCast(to_idx);
    if (!agents[to].active) return -1;
    if (agents[to].inbox_count >= MAX_INBOX) {
        refused_sends += 1;
        return -2;
    }
    const ml = @min(msg_len, MAX_MSG);
    const at = (agents[to].inbox_head + agents[to].inbox_count) % MAX_INBOX;
    @memcpy(agents[to].inbox[at].buf[0..ml], msg[0..ml]);
    agents[to].inbox[at].len = ml;
    agents[to].inbox_count += 1;
    return 0;
}

// Pops the OLDEST message (FIFO). 0 = the mailbox is empty.
pub export fn stz_agent_recv_msg(idx: i32, out: [*]u8) i32 {
    if (idx < 0 or idx >= @as(i32, MAX_AGENTS)) return 0;
    const i: usize = @intCast(idx);
    if (!agents[i].active or agents[i].inbox_count == 0) return 0;
    const at = agents[i].inbox_head;
    const len = agents[i].inbox[at].len;
    @memcpy(out[0..len], agents[i].inbox[at].buf[0..len]);
    agents[i].inbox_head = (at + 1) % MAX_INBOX;
    agents[i].inbox_count -= 1;
    return @intCast(len);
}

// How many messages are waiting. The tick loop's mailbox trigger reads
// this; a caller can too, rather than discovering emptiness by polling.
pub export fn stz_agent_inbox_count(idx: i32) i32 {
    if (idx < 0 or idx >= @as(i32, MAX_AGENTS)) return -1;
    const i: usize = @intCast(idx);
    if (!agents[i].active) return -1;
    return @intCast(agents[i].inbox_count);
}

pub export fn stz_agent_refused_sends() i64 {
    return @intCast(refused_sends);
}

pub export fn stz_agent_count() i32 {
    return @intCast(agent_count);
}

pub export fn stz_agent_name(idx: i32, out: [*]u8) i32 {
    if (idx < 0 or idx >= @as(i32, MAX_AGENTS)) return 0;
    const i: usize = @intCast(idx);
    if (!agents[i].active) return 0;
    const len = agents[i].name_len;
    @memcpy(out[0..len], agents[i].name[0..len]);
    return @intCast(len);
}

// Find a slot by name; -1 when no active agent carries it. The tick loop's
// Ring face works in names, the substrate works in slots, and something
// has to join them without Ring holding a stale index.
pub export fn stz_agent_find(name: [*]const u8, name_len: usize) i32 {
    const nl = @min(name_len, MAX_NAME);
    for (0..MAX_AGENTS) |i| {
        if (!agents[i].active) continue;
        if (agents[i].name_len != nl) continue;
        if (std.mem.eql(u8, agents[i].name[0..nl], name[0..nl])) return @intCast(i);
    }
    return -1;
}

pub export fn stz_agent_clear() void {
    for (0..MAX_AGENTS) |i| {
        agents[i].active = false;
        agents[i].inbox_head = 0;
        agents[i].inbox_count = 0;
    }
    agent_count = 0;
    refused_sends = 0;
}

// ─── Tests ───

test "create agent and count" {
    stz_agent_clear();
    const a = stz_agent_create("worker", 6);
    try std.testing.expect(a >= 0);
    try std.testing.expectEqual(@as(i32, 1), stz_agent_count());
    stz_agent_clear();
}

test "agent name retrieval" {
    stz_agent_clear();
    const idx = stz_agent_create("parser", 6);
    var buf: [128]u8 = undefined;
    const len = stz_agent_name(idx, &buf);
    try std.testing.expectEqual(@as(i32, 6), len);
    try std.testing.expectEqualSlices(u8, "parser", buf[0..@intCast(len)]);
    stz_agent_clear();
}

test "state transitions" {
    stz_agent_clear();
    const idx = stz_agent_create("agent1", 6);
    try std.testing.expectEqual(@as(i32, 0), stz_agent_get_state(idx)); // idle
    _ = stz_agent_set_state(idx, 1); // active
    try std.testing.expectEqual(@as(i32, 1), stz_agent_get_state(idx));
    _ = stz_agent_set_state(idx, 2); // done
    try std.testing.expectEqual(@as(i32, 2), stz_agent_get_state(idx));
    stz_agent_clear();
}

test "message passing" {
    stz_agent_clear();
    const a = stz_agent_create("sender", 6);
    const b = stz_agent_create("receiver", 8);
    const rc = stz_agent_send_msg(a, b, "hello", 5);
    try std.testing.expectEqual(@as(i32, 0), rc);
    var buf: [512]u8 = undefined;
    const len = stz_agent_recv_msg(b, &buf);
    try std.testing.expectEqual(@as(i32, 5), len);
    try std.testing.expectEqualSlices(u8, "hello", buf[0..@intCast(len)]);
    stz_agent_clear();
}

test "message consumed after recv" {
    stz_agent_clear();
    const a = stz_agent_create("s", 1);
    const b = stz_agent_create("r", 1);
    _ = stz_agent_send_msg(a, b, "msg", 3);
    var buf: [512]u8 = undefined;
    _ = stz_agent_recv_msg(b, &buf);
    const len2 = stz_agent_recv_msg(b, &buf);
    try std.testing.expectEqual(@as(i32, 0), len2);
    stz_agent_clear();
}

test "invalid index returns error" {
    try std.testing.expectEqual(@as(i32, -1), stz_agent_get_state(999));
    try std.testing.expectEqual(@as(i32, -1), stz_agent_set_state(-1, 0));
}

// THE DEFECT THIS FILE WAS CARRYING, pinned so it cannot come back: three
// sends before any receive used to leave ONE message. They are three now,
// in the order sent.
test "the mailbox is a QUEUE, not a buffer of one" {
    stz_agent_clear();
    const a = stz_agent_create("s", 1);
    const b = stz_agent_create("r", 1);
    try std.testing.expectEqual(@as(i32, 0), stz_agent_send_msg(a, b, "one", 3));
    try std.testing.expectEqual(@as(i32, 0), stz_agent_send_msg(a, b, "two", 3));
    try std.testing.expectEqual(@as(i32, 0), stz_agent_send_msg(a, b, "three", 5));
    try std.testing.expectEqual(@as(i32, 3), stz_agent_inbox_count(b));

    var buf: [512]u8 = undefined;
    var len = stz_agent_recv_msg(b, &buf);
    try std.testing.expectEqualSlices(u8, "one", buf[0..@intCast(len)]);
    len = stz_agent_recv_msg(b, &buf);
    try std.testing.expectEqualSlices(u8, "two", buf[0..@intCast(len)]);
    len = stz_agent_recv_msg(b, &buf);
    try std.testing.expectEqualSlices(u8, "three", buf[0..@intCast(len)]);
    try std.testing.expectEqual(@as(i32, 0), stz_agent_inbox_count(b));
    stz_agent_clear();
}

test "a full mailbox REFUSES and counts, it does not overwrite" {
    stz_agent_clear();
    const a = stz_agent_create("s", 1);
    const b = stz_agent_create("r", 1);
    for (0..MAX_INBOX) |_| {
        try std.testing.expectEqual(@as(i32, 0), stz_agent_send_msg(a, b, "x", 1));
    }
    try std.testing.expectEqual(@as(i32, -2), stz_agent_send_msg(a, b, "overflow", 8));
    try std.testing.expectEqual(@as(i64, 1), stz_agent_refused_sends());
    try std.testing.expectEqual(@as(i32, @intCast(MAX_INBOX)), stz_agent_inbox_count(b));
    stz_agent_clear();
}

test "the ring wraps: drain and refill keeps FIFO order" {
    stz_agent_clear();
    const a = stz_agent_create("s", 1);
    const b = stz_agent_create("r", 1);
    var buf: [512]u8 = undefined;
    // fill, drain half, refill past the wrap point
    for (0..MAX_INBOX) |_| _ = stz_agent_send_msg(a, b, "old", 3);
    for (0..MAX_INBOX / 2) |_| _ = stz_agent_recv_msg(b, &buf);
    _ = stz_agent_send_msg(a, b, "new1", 4);
    _ = stz_agent_send_msg(a, b, "new2", 4);
    // the remaining "old"s come first, then the two new ones in order
    for (0..MAX_INBOX / 2) |_| {
        const l = stz_agent_recv_msg(b, &buf);
        try std.testing.expectEqualSlices(u8, "old", buf[0..@intCast(l)]);
    }
    var l = stz_agent_recv_msg(b, &buf);
    try std.testing.expectEqualSlices(u8, "new1", buf[0..@intCast(l)]);
    l = stz_agent_recv_msg(b, &buf);
    try std.testing.expectEqualSlices(u8, "new2", buf[0..@intCast(l)]);
    stz_agent_clear();
}

test "find by name, and a cleared slot is not found" {
    stz_agent_clear();
    _ = stz_agent_create("alpha", 5);
    const b = stz_agent_create("beta", 4);
    try std.testing.expectEqual(b, stz_agent_find("beta", 4));
    try std.testing.expectEqual(@as(i32, -1), stz_agent_find("gamma", 5));
    stz_agent_clear();
    try std.testing.expectEqual(@as(i32, -1), stz_agent_find("beta", 4));
}
