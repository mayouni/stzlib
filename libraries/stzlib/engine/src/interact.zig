const std = @import("std");

// ─── Interaction Engine ───
// 64-slot interaction sessions: prompt/response pairs with timing,
// turn tracking, and conversation history.

const MAX_SESSIONS: usize = 16;
const MAX_TURNS: usize = 64;
const MAX_STR: usize = 256;
const MAX_NAME: usize = 64;

const Turn = struct {
    prompt: [MAX_STR]u8 = undefined,
    prompt_len: usize = 0,
    response: [MAX_STR]u8 = undefined,
    response_len: usize = 0,
    timestamp: i64 = 0,
    active: bool = false,
};

const Session = struct {
    name: [MAX_NAME]u8 = undefined,
    name_len: usize = 0,
    turns: [MAX_TURNS]Turn = [_]Turn{.{}} ** MAX_TURNS,
    turn_count: usize = 0,
    mode: [MAX_NAME]u8 = undefined,
    mode_len: usize = 0,
    active: bool = false,
};

var sessions: [MAX_SESSIONS]Session = [_]Session{.{}} ** MAX_SESSIONS;
var session_count: usize = 0;

fn findByName(name: [*]const u8, len: usize) ?usize {
    for (0..MAX_SESSIONS) |idx| {
        if (sessions[idx].active and sessions[idx].name_len == len) {
            if (std.mem.eql(u8, sessions[idx].name[0..len], name[0..len])) return idx;
        }
    }
    return null;
}

// ─── C ABI ───

pub export fn stz_interact_create(name: [*]const u8, name_len: usize, mode: [*]const u8, mode_len: usize) i32 {
    for (0..MAX_SESSIONS) |idx| {
        if (!sessions[idx].active) {
            const nl = @min(name_len, MAX_NAME);
            @memcpy(sessions[idx].name[0..nl], name[0..nl]);
            sessions[idx].name_len = nl;
            const ml = @min(mode_len, MAX_NAME);
            @memcpy(sessions[idx].mode[0..ml], mode[0..ml]);
            sessions[idx].mode_len = ml;
            sessions[idx].turn_count = 0;
            for (0..MAX_TURNS) |ti| sessions[idx].turns[ti].active = false;
            sessions[idx].active = true;
            session_count += 1;
            return @intCast(idx);
        }
    }
    return -1;
}

pub export fn stz_interact_add_turn(si: i32, prompt: [*]const u8, prompt_len: usize, response: [*]const u8, response_len: usize, timestamp: i64) i32 {
    if (si < 0 or si >= @as(i32, MAX_SESSIONS)) return -1;
    const s: usize = @intCast(si);
    if (!sessions[s].active) return -1;
    if (sessions[s].turn_count >= MAX_TURNS) return -1;
    const ti = sessions[s].turn_count;
    const pl = @min(prompt_len, MAX_STR);
    @memcpy(sessions[s].turns[ti].prompt[0..pl], prompt[0..pl]);
    sessions[s].turns[ti].prompt_len = pl;
    const rl = @min(response_len, MAX_STR);
    @memcpy(sessions[s].turns[ti].response[0..rl], response[0..rl]);
    sessions[s].turns[ti].response_len = rl;
    sessions[s].turns[ti].timestamp = timestamp;
    sessions[s].turns[ti].active = true;
    sessions[s].turn_count += 1;
    return @intCast(ti);
}

pub export fn stz_interact_turn_count(si: i32) i32 {
    if (si < 0 or si >= @as(i32, MAX_SESSIONS)) return 0;
    const s: usize = @intCast(si);
    if (!sessions[s].active) return 0;
    return @intCast(sessions[s].turn_count);
}

pub export fn stz_interact_prompt(si: i32, ti: i32, out: [*]u8) i32 {
    if (si < 0 or si >= @as(i32, MAX_SESSIONS)) return 0;
    if (ti < 0 or ti >= @as(i32, MAX_TURNS)) return 0;
    const s: usize = @intCast(si);
    const t: usize = @intCast(ti);
    if (!sessions[s].active or !sessions[s].turns[t].active) return 0;
    const len = sessions[s].turns[t].prompt_len;
    @memcpy(out[0..len], sessions[s].turns[t].prompt[0..len]);
    return @intCast(len);
}

pub export fn stz_interact_response(si: i32, ti: i32, out: [*]u8) i32 {
    if (si < 0 or si >= @as(i32, MAX_SESSIONS)) return 0;
    if (ti < 0 or ti >= @as(i32, MAX_TURNS)) return 0;
    const s: usize = @intCast(si);
    const t: usize = @intCast(ti);
    if (!sessions[s].active or !sessions[s].turns[t].active) return 0;
    const len = sessions[s].turns[t].response_len;
    @memcpy(out[0..len], sessions[s].turns[t].response[0..len]);
    return @intCast(len);
}

pub export fn stz_interact_last_prompt(si: i32, out: [*]u8) i32 {
    if (si < 0 or si >= @as(i32, MAX_SESSIONS)) return 0;
    const s: usize = @intCast(si);
    if (!sessions[s].active or sessions[s].turn_count == 0) return 0;
    const t = sessions[s].turn_count - 1;
    const len = sessions[s].turns[t].prompt_len;
    @memcpy(out[0..len], sessions[s].turns[t].prompt[0..len]);
    return @intCast(len);
}

pub export fn stz_interact_session_count() i32 {
    return @intCast(session_count);
}

pub export fn stz_interact_mode(si: i32, out: [*]u8) i32 {
    if (si < 0 or si >= @as(i32, MAX_SESSIONS)) return 0;
    const s: usize = @intCast(si);
    if (!sessions[s].active) return 0;
    const len = sessions[s].mode_len;
    @memcpy(out[0..len], sessions[s].mode[0..len]);
    return @intCast(len);
}

pub export fn stz_interact_destroy(si: i32) void {
    if (si < 0 or si >= @as(i32, MAX_SESSIONS)) return;
    const s: usize = @intCast(si);
    if (sessions[s].active) {
        sessions[s].active = false;
        session_count -= 1;
    }
}

pub export fn stz_interact_clear() void {
    for (0..MAX_SESSIONS) |idx| sessions[idx].active = false;
    session_count = 0;
}

// ─── Tests ───

test "create session and add turns" {
    stz_interact_clear();
    const s = stz_interact_create("chat1", 5, "qa", 2);
    try std.testing.expect(s >= 0);
    _ = stz_interact_add_turn(s, "hello", 5, "hi there", 8, 1000);
    _ = stz_interact_add_turn(s, "how?", 4, "fine", 4, 2000);
    try std.testing.expectEqual(@as(i32, 2), stz_interact_turn_count(s));
    stz_interact_clear();
}

test "retrieve prompt and response" {
    stz_interact_clear();
    const s = stz_interact_create("s", 1, "m", 1);
    _ = stz_interact_add_turn(s, "question", 8, "answer", 6, 100);
    var buf: [256]u8 = undefined;
    const pl = stz_interact_prompt(s, 0, &buf);
    try std.testing.expectEqualSlices(u8, "question", buf[0..@intCast(pl)]);
    const rl = stz_interact_response(s, 0, &buf);
    try std.testing.expectEqualSlices(u8, "answer", buf[0..@intCast(rl)]);
    stz_interact_clear();
}

test "last prompt" {
    stz_interact_clear();
    const s = stz_interact_create("x", 1, "y", 1);
    _ = stz_interact_add_turn(s, "first", 5, "r1", 2, 1);
    _ = stz_interact_add_turn(s, "second", 6, "r2", 2, 2);
    var buf: [256]u8 = undefined;
    const len = stz_interact_last_prompt(s, &buf);
    try std.testing.expectEqualSlices(u8, "second", buf[0..@intCast(len)]);
    stz_interact_clear();
}

test "mode and destroy" {
    stz_interact_clear();
    const s = stz_interact_create("test", 4, "dialog", 6);
    var buf: [64]u8 = undefined;
    const ml = stz_interact_mode(s, &buf);
    try std.testing.expectEqualSlices(u8, "dialog", buf[0..@intCast(ml)]);
    stz_interact_destroy(s);
    try std.testing.expectEqual(@as(i32, 0), stz_interact_session_count());
    stz_interact_clear();
}
