const std = @import("std");

// ── Execution Model (state machine + event dispatch) ────────
// A lightweight state machine for modeling execution flows.
// States have names, transitions have source→target with event name.

const MAX_STATES = 64;
const MAX_TRANSITIONS = 256;
const MAX_NAME = 32;

const State = struct {
    name: [MAX_NAME]u8 = [_]u8{0} ** MAX_NAME,
    name_len: usize = 0,
    active: bool = false,
};

const Transition = struct {
    from: u32 = 0,
    to: u32 = 0,
    event: [MAX_NAME]u8 = [_]u8{0} ** MAX_NAME,
    event_len: usize = 0,
    active: bool = false,
};

var states: [MAX_STATES]State = [_]State{.{}} ** MAX_STATES;
var transitions: [MAX_TRANSITIONS]Transition = [_]Transition{.{}} ** MAX_TRANSITIONS;
var current_state: i32 = -1;
var transition_count_val: u64 = 0;

fn findState(name_ptr: [*]const u8, name_len: usize) ?u32 {
    for (0..MAX_STATES) |i| {
        if (states[i].active and states[i].name_len == name_len and
            std.mem.eql(u8, states[i].name[0..name_len], name_ptr[0..name_len]))
        {
            return @intCast(i);
        }
    }
    return null;
}

pub fn exec_add_state(name_ptr: [*]const u8, name_len: usize) callconv(.c) i32 {
    if (name_len > MAX_NAME) return -1;
    if (findState(name_ptr, name_len) != null) return -3;
    for (0..MAX_STATES) |i| {
        if (!states[i].active) {
            @memcpy(states[i].name[0..name_len], name_ptr[0..name_len]);
            states[i].name_len = name_len;
            states[i].active = true;
            return @intCast(i);
        }
    }
    return -2;
}

pub fn exec_add_transition(from: u32, to: u32, event_ptr: [*]const u8, event_len: usize) callconv(.c) i32 {
    if (from >= MAX_STATES or to >= MAX_STATES) return -1;
    if (!states[from].active or !states[to].active) return -2;
    if (event_len > MAX_NAME) return -3;
    for (0..MAX_TRANSITIONS) |i| {
        if (!transitions[i].active) {
            transitions[i].from = from;
            transitions[i].to = to;
            @memcpy(transitions[i].event[0..event_len], event_ptr[0..event_len]);
            transitions[i].event_len = event_len;
            transitions[i].active = true;
            return @intCast(i);
        }
    }
    return -4;
}

pub fn exec_set_state(id: u32) callconv(.c) i32 {
    if (id >= MAX_STATES or !states[id].active) return -1;
    current_state = @intCast(id);
    return 0;
}

pub fn exec_current_state() callconv(.c) i32 {
    return current_state;
}

pub fn exec_current_state_name(out: [*]u8, max: usize) callconv(.c) i32 {
    if (current_state < 0) return -1;
    const idx: u32 = @intCast(current_state);
    const nlen = states[idx].name_len;
    if (nlen > max) return -2;
    @memcpy(out[0..nlen], states[idx].name[0..nlen]);
    return @intCast(nlen);
}

pub fn exec_dispatch(event_ptr: [*]const u8, event_len: usize) callconv(.c) i32 {
    if (current_state < 0) return -1;
    const from: u32 = @intCast(current_state);
    for (0..MAX_TRANSITIONS) |i| {
        if (transitions[i].active and transitions[i].from == from and
            transitions[i].event_len == event_len and
            std.mem.eql(u8, transitions[i].event[0..event_len], event_ptr[0..event_len]))
        {
            current_state = @intCast(transitions[i].to);
            transition_count_val += 1;
            return @intCast(transitions[i].to);
        }
    }
    return -2;
}

pub fn exec_state_count() callconv(.c) u32 {
    var count: u32 = 0;
    for (0..MAX_STATES) |i| {
        if (states[i].active) count += 1;
    }
    return count;
}

pub fn exec_transition_count() callconv(.c) u64 {
    return transition_count_val;
}

pub fn exec_clear() callconv(.c) void {
    for (0..MAX_STATES) |i| states[i].active = false;
    for (0..MAX_TRANSITIONS) |i| transitions[i].active = false;
    current_state = -1;
    transition_count_val = 0;
}

// ── C ABI exports ────────────────────────────────────────────

pub export fn stz_exec_add_state(p: [*]const u8, l: usize) callconv(.c) i32 { return exec_add_state(p, l); }
pub export fn stz_exec_add_transition(f: u32, t: u32, p: [*]const u8, l: usize) callconv(.c) i32 { return exec_add_transition(f, t, p, l); }
pub export fn stz_exec_set_state(id: u32) callconv(.c) i32 { return exec_set_state(id); }
pub export fn stz_exec_current_state() callconv(.c) i32 { return exec_current_state(); }
pub export fn stz_exec_current_state_name(o: [*]u8, m: usize) callconv(.c) i32 { return exec_current_state_name(o, m); }
pub export fn stz_exec_dispatch(p: [*]const u8, l: usize) callconv(.c) i32 { return exec_dispatch(p, l); }
pub export fn stz_exec_state_count() callconv(.c) u32 { return exec_state_count(); }
pub export fn stz_exec_transition_count() callconv(.c) u64 { return exec_transition_count(); }
pub export fn stz_exec_clear() callconv(.c) void { exec_clear(); }

// ── Tests ────────────────────────────────────────────────────

test "exec: add states" {
    exec_clear();
    const idle = exec_add_state("idle".ptr, 4);
    try std.testing.expect(idle >= 0);
    const running = exec_add_state("running".ptr, 7);
    try std.testing.expect(running >= 0);
    try std.testing.expectEqual(@as(u32, 2), exec_state_count());
}

test "exec: transitions" {
    exec_clear();
    const idle: u32 = @intCast(exec_add_state("idle".ptr, 4));
    const run: u32 = @intCast(exec_add_state("running".ptr, 7));
    _ = exec_add_transition(idle, run, "start".ptr, 5);
    _ = exec_add_transition(run, idle, "stop".ptr, 4);
    _ = exec_set_state(idle);
    const next = exec_dispatch("start".ptr, 5);
    try std.testing.expectEqual(@as(i32, @intCast(run)), next);
    try std.testing.expectEqual(@as(i32, @intCast(run)), exec_current_state());
}

test "exec: state name" {
    exec_clear();
    const s: u32 = @intCast(exec_add_state("ready".ptr, 5));
    _ = exec_set_state(s);
    var buf: [32]u8 = undefined;
    const len = exec_current_state_name(&buf, 32);
    try std.testing.expectEqualStrings("ready", buf[0..@intCast(len)]);
}

test "exec: invalid dispatch" {
    exec_clear();
    const s: u32 = @intCast(exec_add_state("only".ptr, 4));
    _ = exec_set_state(s);
    try std.testing.expectEqual(@as(i32, -2), exec_dispatch("nope".ptr, 4));
}

test "exec: transition count" {
    exec_clear();
    const a: u32 = @intCast(exec_add_state("a".ptr, 1));
    const b: u32 = @intCast(exec_add_state("b".ptr, 1));
    _ = exec_add_transition(a, b, "go".ptr, 2);
    _ = exec_set_state(a);
    _ = exec_dispatch("go".ptr, 2);
    try std.testing.expectEqual(@as(u64, 1), exec_transition_count());
}

test "exec: clear" {
    exec_clear();
    _ = exec_add_state("x".ptr, 1);
    exec_clear();
    try std.testing.expectEqual(@as(u32, 0), exec_state_count());
}
