const std = @import("std");

// ─── State Machine Engine ───
// 16 named state machines, each with up to 32 states and 64 transitions.

const MAX_MACHINES: usize = 16;
const MAX_STATES: usize = 32;
const MAX_TRANSITIONS: usize = 64;
const MAX_NAME: usize = 64;

const Transition = struct {
    from_state: usize = 0,
    to_state: usize = 0,
    event: [MAX_NAME]u8 = undefined,
    event_len: usize = 0,
    active: bool = false,
};

const State = struct {
    name: [MAX_NAME]u8 = undefined,
    name_len: usize = 0,
    active: bool = false,
};

const Machine = struct {
    name: [MAX_NAME]u8 = undefined,
    name_len: usize = 0,
    states: [MAX_STATES]State = [_]State{.{}} ** MAX_STATES,
    state_count: usize = 0,
    transitions: [MAX_TRANSITIONS]Transition = [_]Transition{.{}} ** MAX_TRANSITIONS,
    transition_count: usize = 0,
    current_state: usize = 0,
    active: bool = false,
};

var machines: [MAX_MACHINES]Machine = [_]Machine{.{}} ** MAX_MACHINES;
var machine_count: usize = 0;

fn findMachine(name: [*]const u8, len: usize) ?usize {
    for (0..MAX_MACHINES) |idx| {
        if (machines[idx].active and machines[idx].name_len == len) {
            if (std.mem.eql(u8, machines[idx].name[0..len], name[0..len])) return idx;
        }
    }
    return null;
}

fn findState(mi: usize, name: [*]const u8, len: usize) ?usize {
    for (0..MAX_STATES) |si| {
        if (machines[mi].states[si].active and machines[mi].states[si].name_len == len) {
            if (std.mem.eql(u8, machines[mi].states[si].name[0..len], name[0..len])) return si;
        }
    }
    return null;
}

// ─── C ABI ───

pub export fn stz_fsm_create(name: [*]const u8, name_len: usize) i32 {
    for (0..MAX_MACHINES) |idx| {
        if (!machines[idx].active) {
            const nl = @min(name_len, MAX_NAME);
            @memcpy(machines[idx].name[0..nl], name[0..nl]);
            machines[idx].name_len = nl;
            machines[idx].state_count = 0;
            machines[idx].transition_count = 0;
            machines[idx].current_state = 0;
            for (0..MAX_STATES) |si| machines[idx].states[si].active = false;
            for (0..MAX_TRANSITIONS) |ti| machines[idx].transitions[ti].active = false;
            machines[idx].active = true;
            machine_count += 1;
            return @intCast(idx);
        }
    }
    return -1;
}

pub export fn stz_fsm_add_state(mi: i32, name: [*]const u8, name_len: usize) i32 {
    if (mi < 0 or mi >= @as(i32, MAX_MACHINES)) return -1;
    const m: usize = @intCast(mi);
    if (!machines[m].active) return -1;
    for (0..MAX_STATES) |si| {
        if (!machines[m].states[si].active) {
            const nl = @min(name_len, MAX_NAME);
            @memcpy(machines[m].states[si].name[0..nl], name[0..nl]);
            machines[m].states[si].name_len = nl;
            machines[m].states[si].active = true;
            machines[m].state_count += 1;
            return @intCast(si);
        }
    }
    return -1;
}

pub export fn stz_fsm_add_transition(mi: i32, from: [*]const u8, from_len: usize, event: [*]const u8, event_len: usize, to: [*]const u8, to_len: usize) i32 {
    if (mi < 0 or mi >= @as(i32, MAX_MACHINES)) return 0;
    const m: usize = @intCast(mi);
    if (!machines[m].active) return 0;
    const from_si = findState(m, from, from_len) orelse return 0;
    const to_si = findState(m, to, to_len) orelse return 0;
    for (0..MAX_TRANSITIONS) |ti| {
        if (!machines[m].transitions[ti].active) {
            machines[m].transitions[ti].from_state = from_si;
            machines[m].transitions[ti].to_state = to_si;
            const el = @min(event_len, MAX_NAME);
            @memcpy(machines[m].transitions[ti].event[0..el], event[0..el]);
            machines[m].transitions[ti].event_len = el;
            machines[m].transitions[ti].active = true;
            machines[m].transition_count += 1;
            return 1;
        }
    }
    return 0;
}

pub export fn stz_fsm_set_state(mi: i32, name: [*]const u8, name_len: usize) i32 {
    if (mi < 0 or mi >= @as(i32, MAX_MACHINES)) return 0;
    const m: usize = @intCast(mi);
    if (!machines[m].active) return 0;
    const si = findState(m, name, name_len) orelse return 0;
    machines[m].current_state = si;
    return 1;
}

pub export fn stz_fsm_send(mi: i32, event: [*]const u8, event_len: usize) i32 {
    if (mi < 0 or mi >= @as(i32, MAX_MACHINES)) return 0;
    const m: usize = @intCast(mi);
    if (!machines[m].active) return 0;
    for (0..MAX_TRANSITIONS) |ti| {
        if (machines[m].transitions[ti].active and
            machines[m].transitions[ti].from_state == machines[m].current_state and
            machines[m].transitions[ti].event_len == event_len)
        {
            if (std.mem.eql(u8, machines[m].transitions[ti].event[0..event_len], event[0..event_len])) {
                machines[m].current_state = machines[m].transitions[ti].to_state;
                return 1;
            }
        }
    }
    return 0;
}

pub export fn stz_fsm_current_state(mi: i32, out: [*]u8) i32 {
    if (mi < 0 or mi >= @as(i32, MAX_MACHINES)) return 0;
    const m: usize = @intCast(mi);
    if (!machines[m].active) return 0;
    const si = machines[m].current_state;
    if (!machines[m].states[si].active) return 0;
    const len = machines[m].states[si].name_len;
    @memcpy(out[0..len], machines[m].states[si].name[0..len]);
    return @intCast(len);
}

pub export fn stz_fsm_state_count(mi: i32) i32 {
    if (mi < 0 or mi >= @as(i32, MAX_MACHINES)) return 0;
    const m: usize = @intCast(mi);
    if (!machines[m].active) return 0;
    return @intCast(machines[m].state_count);
}

pub export fn stz_fsm_transition_count(mi: i32) i32 {
    if (mi < 0 or mi >= @as(i32, MAX_MACHINES)) return 0;
    const m: usize = @intCast(mi);
    if (!machines[m].active) return 0;
    return @intCast(machines[m].transition_count);
}

pub export fn stz_fsm_destroy(mi: i32) void {
    if (mi < 0 or mi >= @as(i32, MAX_MACHINES)) return;
    const m: usize = @intCast(mi);
    if (machines[m].active) {
        machines[m].active = false;
        machine_count -= 1;
    }
}

pub export fn stz_fsm_clear() void {
    for (0..MAX_MACHINES) |idx| machines[idx].active = false;
    machine_count = 0;
}

// ─── Tests ───

test "create machine with states and transitions" {
    stz_fsm_clear();
    const m = stz_fsm_create("traffic", 7);
    try std.testing.expect(m >= 0);
    _ = stz_fsm_add_state(m, "red", 3);
    _ = stz_fsm_add_state(m, "green", 5);
    _ = stz_fsm_add_state(m, "yellow", 6);
    try std.testing.expectEqual(@as(i32, 3), stz_fsm_state_count(m));
    _ = stz_fsm_add_transition(m, "red", 3, "go", 2, "green", 5);
    _ = stz_fsm_add_transition(m, "green", 5, "slow", 4, "yellow", 6);
    _ = stz_fsm_add_transition(m, "yellow", 6, "stop", 4, "red", 3);
    try std.testing.expectEqual(@as(i32, 3), stz_fsm_transition_count(m));
    stz_fsm_clear();
}

test "state transitions via send" {
    stz_fsm_clear();
    const m = stz_fsm_create("door", 4);
    _ = stz_fsm_add_state(m, "closed", 6);
    _ = stz_fsm_add_state(m, "open", 4);
    _ = stz_fsm_add_transition(m, "closed", 6, "push", 4, "open", 4);
    _ = stz_fsm_add_transition(m, "open", 4, "pull", 4, "closed", 6);
    _ = stz_fsm_set_state(m, "closed", 6);
    var buf: [64]u8 = undefined;
    var len = stz_fsm_current_state(m, &buf);
    try std.testing.expectEqualSlices(u8, "closed", buf[0..@intCast(len)]);
    _ = stz_fsm_send(m, "push", 4);
    len = stz_fsm_current_state(m, &buf);
    try std.testing.expectEqualSlices(u8, "open", buf[0..@intCast(len)]);
    stz_fsm_clear();
}

test "invalid event ignored" {
    stz_fsm_clear();
    const m = stz_fsm_create("sm", 2);
    _ = stz_fsm_add_state(m, "a", 1);
    _ = stz_fsm_add_state(m, "b", 1);
    _ = stz_fsm_add_transition(m, "a", 1, "go", 2, "b", 1);
    _ = stz_fsm_set_state(m, "a", 1);
    try std.testing.expectEqual(@as(i32, 0), stz_fsm_send(m, "invalid", 7));
    var buf: [64]u8 = undefined;
    const len = stz_fsm_current_state(m, &buf);
    try std.testing.expectEqualSlices(u8, "a", buf[0..@intCast(len)]);
    stz_fsm_clear();
}

test "destroy" {
    stz_fsm_clear();
    const m = stz_fsm_create("x", 1);
    stz_fsm_destroy(m);
    try std.testing.expectEqual(@as(i32, 0), stz_fsm_state_count(m));
    stz_fsm_clear();
}
