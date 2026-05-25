const std = @import("std");

// ─── Confidence Score Engine ───
// 64-slot named confidence scores (0.0-1.0) with weighted aggregation.

const MAX_SLOTS: usize = 64;
const MAX_NAME: usize = 64;

const Slot = struct {
    name: [MAX_NAME]u8 = undefined,
    name_len: usize = 0,
    score: f64 = 0.0,
    weight: f64 = 1.0,
    active: bool = false,
};

var slots: [MAX_SLOTS]Slot = [_]Slot{.{}} ** MAX_SLOTS;
var slot_count: usize = 0;

fn findByName(name: [*]const u8, len: usize) ?usize {
    for (0..MAX_SLOTS) |idx| {
        if (slots[idx].active and slots[idx].name_len == len) {
            if (std.mem.eql(u8, slots[idx].name[0..len], name[0..len])) return idx;
        }
    }
    return null;
}

fn findFreeSlot() ?usize {
    for (0..MAX_SLOTS) |idx| {
        if (!slots[idx].active) return idx;
    }
    return null;
}

fn clamp01(v: f64) f64 {
    if (v < 0.0) return 0.0;
    if (v > 1.0) return 1.0;
    return v;
}

// ─── C ABI ───

pub export fn stz_conf_set(name: [*]const u8, name_len: usize, score: f64, weight: f64) i32 {
    if (findByName(name, name_len)) |idx| {
        slots[idx].score = clamp01(score);
        slots[idx].weight = weight;
        return @intCast(idx);
    }
    const slot = findFreeSlot() orelse return -1;
    const clamped = @min(name_len, MAX_NAME);
    @memcpy(slots[slot].name[0..clamped], name[0..clamped]);
    slots[slot].name_len = clamped;
    slots[slot].score = clamp01(score);
    slots[slot].weight = weight;
    slots[slot].active = true;
    slot_count += 1;
    return @intCast(slot);
}

pub export fn stz_conf_get(name: [*]const u8, name_len: usize) f64 {
    const idx = findByName(name, name_len) orelse return -1.0;
    return slots[idx].score;
}

pub export fn stz_conf_count() i32 {
    return @intCast(slot_count);
}

pub export fn stz_conf_weighted_avg() f64 {
    var sum_weighted: f64 = 0.0;
    var sum_weights: f64 = 0.0;
    for (0..MAX_SLOTS) |idx| {
        if (slots[idx].active) {
            sum_weighted += slots[idx].score * slots[idx].weight;
            sum_weights += slots[idx].weight;
        }
    }
    if (sum_weights == 0.0) return 0.0;
    return sum_weighted / sum_weights;
}

pub export fn stz_conf_min() f64 {
    var min_val: f64 = 2.0;
    for (0..MAX_SLOTS) |idx| {
        if (slots[idx].active and slots[idx].score < min_val) {
            min_val = slots[idx].score;
        }
    }
    if (min_val > 1.0) return 0.0;
    return min_val;
}

pub export fn stz_conf_max() f64 {
    var max_val: f64 = -1.0;
    for (0..MAX_SLOTS) |idx| {
        if (slots[idx].active and slots[idx].score > max_val) {
            max_val = slots[idx].score;
        }
    }
    if (max_val < 0.0) return 0.0;
    return max_val;
}

pub export fn stz_conf_remove(name: [*]const u8, name_len: usize) i32 {
    const idx = findByName(name, name_len) orelse return 0;
    slots[idx].active = false;
    slot_count -= 1;
    return 1;
}

pub export fn stz_conf_clear() void {
    for (0..MAX_SLOTS) |idx| {
        slots[idx].active = false;
    }
    slot_count = 0;
}

// ─── Tests ───

test "set and get confidence" {
    stz_conf_clear();
    const idx = stz_conf_set("accuracy", 8, 0.95, 1.0);
    try std.testing.expect(idx >= 0);
    try std.testing.expectApproxEqAbs(@as(f64, 0.95), stz_conf_get("accuracy", 8), 0.001);
    try std.testing.expectEqual(@as(i32, 1), stz_conf_count());
    stz_conf_clear();
}

test "weighted average" {
    stz_conf_clear();
    _ = stz_conf_set("a", 1, 0.8, 2.0);
    _ = stz_conf_set("b", 1, 0.6, 1.0);
    // weighted avg = (0.8*2 + 0.6*1) / (2+1) = 2.2/3 = 0.7333
    try std.testing.expectApproxEqAbs(@as(f64, 0.7333), stz_conf_weighted_avg(), 0.01);
    stz_conf_clear();
}

test "min and max" {
    stz_conf_clear();
    _ = stz_conf_set("low", 3, 0.2, 1.0);
    _ = stz_conf_set("mid", 3, 0.5, 1.0);
    _ = stz_conf_set("high", 4, 0.9, 1.0);
    try std.testing.expectApproxEqAbs(@as(f64, 0.2), stz_conf_min(), 0.001);
    try std.testing.expectApproxEqAbs(@as(f64, 0.9), stz_conf_max(), 0.001);
    stz_conf_clear();
}

test "clamping" {
    stz_conf_clear();
    _ = stz_conf_set("over", 4, 1.5, 1.0);
    try std.testing.expectApproxEqAbs(@as(f64, 1.0), stz_conf_get("over", 4), 0.001);
    _ = stz_conf_set("under", 5, -0.5, 1.0);
    try std.testing.expectApproxEqAbs(@as(f64, 0.0), stz_conf_get("under", 5), 0.001);
    stz_conf_clear();
}

test "remove" {
    stz_conf_clear();
    _ = stz_conf_set("tmp", 3, 0.5, 1.0);
    try std.testing.expectEqual(@as(i32, 1), stz_conf_count());
    _ = stz_conf_remove("tmp", 3);
    try std.testing.expectEqual(@as(i32, 0), stz_conf_count());
    stz_conf_clear();
}
