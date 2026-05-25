const std = @import("std");

// ─── Intent Engine ───
// 64-slot named intents with parameters and priority scoring.

const MAX_INTENTS: usize = 64;
const MAX_NAME: usize = 64;
const MAX_PARAMS: usize = 8;

const Param = struct {
    name: [MAX_NAME]u8 = undefined,
    name_len: usize = 0,
    value: [MAX_NAME]u8 = undefined,
    value_len: usize = 0,
    active: bool = false,
};

const Intent = struct {
    name: [MAX_NAME]u8 = undefined,
    name_len: usize = 0,
    priority: i32 = 0,
    params: [MAX_PARAMS]Param = [_]Param{.{}} ** MAX_PARAMS,
    param_count: usize = 0,
    active: bool = false,
};

var intents: [MAX_INTENTS]Intent = [_]Intent{.{}} ** MAX_INTENTS;
var intent_count: usize = 0;

fn findByName(name: [*]const u8, len: usize) ?usize {
    for (0..MAX_INTENTS) |idx| {
        if (intents[idx].active and intents[idx].name_len == len) {
            if (std.mem.eql(u8, intents[idx].name[0..len], name[0..len])) return idx;
        }
    }
    return null;
}

// ─── C ABI ───

pub export fn stz_intent_create(name: [*]const u8, name_len: usize, priority: i32) i32 {
    for (0..MAX_INTENTS) |idx| {
        if (!intents[idx].active) {
            const nl = @min(name_len, MAX_NAME);
            @memcpy(intents[idx].name[0..nl], name[0..nl]);
            intents[idx].name_len = nl;
            intents[idx].priority = priority;
            intents[idx].param_count = 0;
            for (0..MAX_PARAMS) |pi| intents[idx].params[pi].active = false;
            intents[idx].active = true;
            intent_count += 1;
            return @intCast(idx);
        }
    }
    return -1;
}

pub export fn stz_intent_set_param(idx: i32, name: [*]const u8, name_len: usize, val: [*]const u8, val_len: usize) i32 {
    if (idx < 0 or idx >= @as(i32, MAX_INTENTS)) return 0;
    const ii: usize = @intCast(idx);
    if (!intents[ii].active) return 0;
    for (0..MAX_PARAMS) |pi| {
        if (intents[ii].params[pi].active and intents[ii].params[pi].name_len == name_len) {
            if (std.mem.eql(u8, intents[ii].params[pi].name[0..name_len], name[0..name_len])) {
                const vl = @min(val_len, MAX_NAME);
                @memcpy(intents[ii].params[pi].value[0..vl], val[0..vl]);
                intents[ii].params[pi].value_len = vl;
                return 1;
            }
        }
    }
    for (0..MAX_PARAMS) |pi| {
        if (!intents[ii].params[pi].active) {
            const nl = @min(name_len, MAX_NAME);
            @memcpy(intents[ii].params[pi].name[0..nl], name[0..nl]);
            intents[ii].params[pi].name_len = nl;
            const vl = @min(val_len, MAX_NAME);
            @memcpy(intents[ii].params[pi].value[0..vl], val[0..vl]);
            intents[ii].params[pi].value_len = vl;
            intents[ii].params[pi].active = true;
            intents[ii].param_count += 1;
            return 1;
        }
    }
    return 0;
}

pub export fn stz_intent_get_param(idx: i32, name: [*]const u8, name_len: usize, out: [*]u8) i32 {
    if (idx < 0 or idx >= @as(i32, MAX_INTENTS)) return 0;
    const ii: usize = @intCast(idx);
    if (!intents[ii].active) return 0;
    for (0..MAX_PARAMS) |pi| {
        if (intents[ii].params[pi].active and intents[ii].params[pi].name_len == name_len) {
            if (std.mem.eql(u8, intents[ii].params[pi].name[0..name_len], name[0..name_len])) {
                const vl = intents[ii].params[pi].value_len;
                @memcpy(out[0..vl], intents[ii].params[pi].value[0..vl]);
                return @intCast(vl);
            }
        }
    }
    return 0;
}

pub export fn stz_intent_priority(idx: i32) i32 {
    if (idx < 0 or idx >= @as(i32, MAX_INTENTS)) return 0;
    const ii: usize = @intCast(idx);
    if (!intents[ii].active) return 0;
    return intents[ii].priority;
}

pub export fn stz_intent_param_count(idx: i32) i32 {
    if (idx < 0 or idx >= @as(i32, MAX_INTENTS)) return 0;
    const ii: usize = @intCast(idx);
    if (!intents[ii].active) return 0;
    return @intCast(intents[ii].param_count);
}

pub export fn stz_intent_count() i32 {
    return @intCast(intent_count);
}

pub export fn stz_intent_top_priority() i32 {
    var best_idx: i32 = -1;
    var best_pri: i32 = std.math.minInt(i32);
    for (0..MAX_INTENTS) |idx| {
        if (intents[idx].active and intents[idx].priority > best_pri) {
            best_pri = intents[idx].priority;
            best_idx = @intCast(idx);
        }
    }
    return best_idx;
}

pub export fn stz_intent_destroy(idx: i32) void {
    if (idx < 0 or idx >= @as(i32, MAX_INTENTS)) return;
    const ii: usize = @intCast(idx);
    if (intents[ii].active) {
        intents[ii].active = false;
        intent_count -= 1;
    }
}

pub export fn stz_intent_clear() void {
    for (0..MAX_INTENTS) |idx| intents[idx].active = false;
    intent_count = 0;
}

// ─── Tests ───

test "create intent with params" {
    stz_intent_clear();
    const idx = stz_intent_create("search", 6, 10);
    try std.testing.expect(idx >= 0);
    _ = stz_intent_set_param(idx, "query", 5, "hello", 5);
    var buf: [64]u8 = undefined;
    const len = stz_intent_get_param(idx, "query", 5, &buf);
    try std.testing.expectEqualSlices(u8, "hello", buf[0..@intCast(len)]);
    try std.testing.expectEqual(@as(i32, 1), stz_intent_param_count(idx));
    stz_intent_clear();
}

test "priority selection" {
    stz_intent_clear();
    _ = stz_intent_create("low", 3, 1);
    const hi = stz_intent_create("high", 4, 100);
    _ = stz_intent_create("mid", 3, 50);
    try std.testing.expectEqual(hi, stz_intent_top_priority());
    stz_intent_clear();
}

test "destroy" {
    stz_intent_clear();
    const idx = stz_intent_create("tmp", 3, 5);
    try std.testing.expectEqual(@as(i32, 1), stz_intent_count());
    stz_intent_destroy(idx);
    try std.testing.expectEqual(@as(i32, 0), stz_intent_count());
    stz_intent_clear();
}

test "update param" {
    stz_intent_clear();
    const idx = stz_intent_create("act", 3, 1);
    _ = stz_intent_set_param(idx, "k", 1, "old", 3);
    _ = stz_intent_set_param(idx, "k", 1, "new", 3);
    try std.testing.expectEqual(@as(i32, 1), stz_intent_param_count(idx));
    var buf: [64]u8 = undefined;
    const len = stz_intent_get_param(idx, "k", 1, &buf);
    try std.testing.expectEqualSlices(u8, "new", buf[0..@intCast(len)]);
    stz_intent_clear();
}
