const std = @import("std");

// ─── Softanzuter Agent Substrate ───
// Named agent slots with state (idle/active/done/error), message passing.

const MAX_AGENTS: usize = 64;
const MAX_NAME: usize = 128;
const MAX_MSG: usize = 512;

const AgentState = enum(u8) {
    idle = 0,
    active = 1,
    done = 2,
    err = 3,
};

const Agent = struct {
    name: [MAX_NAME]u8 = undefined,
    name_len: usize = 0,
    state: AgentState = .idle,
    inbox: [MAX_MSG]u8 = undefined,
    inbox_len: usize = 0,
    active: bool = false,
};

var agents: [MAX_AGENTS]Agent = [_]Agent{.{}} ** MAX_AGENTS;
var agent_count: usize = 0;

// ─── C ABI ───

pub export fn stz_agent_create(name: [*]const u8, name_len: usize) i32 {
    if (agent_count >= MAX_AGENTS) return -1;
    for (0..MAX_AGENTS) |i| {
        if (!agents[i].active) {
            const nl = @min(name_len, MAX_NAME);
            @memcpy(agents[i].name[0..nl], name[0..nl]);
            agents[i].name_len = nl;
            agents[i].state = .idle;
            agents[i].inbox_len = 0;
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

pub export fn stz_agent_send_msg(from_idx: i32, to_idx: i32, msg: [*]const u8, msg_len: usize) i32 {
    _ = from_idx; // sender tracked for future routing
    if (to_idx < 0 or to_idx >= @as(i32, MAX_AGENTS)) return -1;
    const to: usize = @intCast(to_idx);
    if (!agents[to].active) return -1;
    const ml = @min(msg_len, MAX_MSG);
    @memcpy(agents[to].inbox[0..ml], msg[0..ml]);
    agents[to].inbox_len = ml;
    return 0;
}

pub export fn stz_agent_recv_msg(idx: i32, out: [*]u8) i32 {
    if (idx < 0 or idx >= @as(i32, MAX_AGENTS)) return 0;
    const i: usize = @intCast(idx);
    if (!agents[i].active or agents[i].inbox_len == 0) return 0;
    const len = agents[i].inbox_len;
    @memcpy(out[0..len], agents[i].inbox[0..len]);
    agents[i].inbox_len = 0; // consume
    return @intCast(len);
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

pub export fn stz_agent_clear() void {
    for (0..MAX_AGENTS) |i| {
        agents[i].active = false;
    }
    agent_count = 0;
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
