const std = @import("std");

// ─── Sequence Engine ───
// 32 named integer sequences with step/repeat/bounce modes.

const MAX_SEQUENCES: usize = 32;
const MAX_NAME: usize = 64;

const Mode = enum(u8) {
    step = 0,
    repeat = 1,
    bounce = 2,
};

const Sequence = struct {
    name: [MAX_NAME]u8 = undefined,
    name_len: usize = 0,
    start: i64 = 0,
    step_val: i64 = 1,
    current: i64 = 0,
    min_val: i64 = std.math.minInt(i64),
    max_val: i64 = std.math.maxInt(i64),
    mode: Mode = .step,
    direction: i8 = 1,
    iteration: u64 = 0,
    active: bool = false,
};

var sequences: [MAX_SEQUENCES]Sequence = [_]Sequence{.{}} ** MAX_SEQUENCES;
var seq_count: usize = 0;

fn findByName(name: [*]const u8, len: usize) ?usize {
    for (0..MAX_SEQUENCES) |idx| {
        if (sequences[idx].active and sequences[idx].name_len == len) {
            if (std.mem.eql(u8, sequences[idx].name[0..len], name[0..len])) return idx;
        }
    }
    return null;
}

// ─── C ABI ───

pub export fn stz_seq_create(name: [*]const u8, name_len: usize, start: i64, step_val: i64, mode: i32) i32 {
    for (0..MAX_SEQUENCES) |idx| {
        if (!sequences[idx].active) {
            const nl = @min(name_len, MAX_NAME);
            @memcpy(sequences[idx].name[0..nl], name[0..nl]);
            sequences[idx].name_len = nl;
            sequences[idx].start = start;
            sequences[idx].step_val = step_val;
            sequences[idx].current = start;
            sequences[idx].min_val = std.math.minInt(i64);
            sequences[idx].max_val = std.math.maxInt(i64);
            sequences[idx].mode = @enumFromInt(@as(u8, @intCast(@min(mode, 2))));
            sequences[idx].direction = 1;
            sequences[idx].iteration = 0;
            sequences[idx].active = true;
            seq_count += 1;
            return @intCast(idx);
        }
    }
    return -1;
}

pub export fn stz_seq_set_bounds(name: [*]const u8, name_len: usize, min_v: i64, max_v: i64) i32 {
    const idx = findByName(name, name_len) orelse return 0;
    sequences[idx].min_val = min_v;
    sequences[idx].max_val = max_v;
    return 1;
}

pub export fn stz_seq_next(name: [*]const u8, name_len: usize) i64 {
    const idx = findByName(name, name_len) orelse return 0;
    const val = sequences[idx].current;
    sequences[idx].iteration += 1;

    switch (sequences[idx].mode) {
        .step => {
            sequences[idx].current += sequences[idx].step_val;
        },
        .repeat => {
            sequences[idx].current += sequences[idx].step_val;
            if (sequences[idx].current > sequences[idx].max_val) {
                sequences[idx].current = sequences[idx].min_val;
            } else if (sequences[idx].current < sequences[idx].min_val) {
                sequences[idx].current = sequences[idx].max_val;
            }
        },
        .bounce => {
            sequences[idx].current += sequences[idx].step_val * sequences[idx].direction;
            if (sequences[idx].current >= sequences[idx].max_val) {
                sequences[idx].direction = -1;
                sequences[idx].current = sequences[idx].max_val;
            } else if (sequences[idx].current <= sequences[idx].min_val) {
                sequences[idx].direction = 1;
                sequences[idx].current = sequences[idx].min_val;
            }
        },
    }
    return val;
}

pub export fn stz_seq_current(name: [*]const u8, name_len: usize) i64 {
    const idx = findByName(name, name_len) orelse return 0;
    return sequences[idx].current;
}

pub export fn stz_seq_iteration(name: [*]const u8, name_len: usize) i64 {
    const idx = findByName(name, name_len) orelse return 0;
    return @intCast(sequences[idx].iteration);
}

pub export fn stz_seq_reset(name: [*]const u8, name_len: usize) void {
    const idx = findByName(name, name_len) orelse return;
    sequences[idx].current = sequences[idx].start;
    sequences[idx].direction = 1;
    sequences[idx].iteration = 0;
}

pub export fn stz_seq_count() i32 {
    return @intCast(seq_count);
}

pub export fn stz_seq_destroy(name: [*]const u8, name_len: usize) void {
    const idx = findByName(name, name_len) orelse return;
    sequences[idx].active = false;
    seq_count -= 1;
}

pub export fn stz_seq_clear() void {
    for (0..MAX_SEQUENCES) |idx| sequences[idx].active = false;
    seq_count = 0;
}

// ─── Tests ───

test "step sequence" {
    stz_seq_clear();
    _ = stz_seq_create("counter", 7, 0, 1, 0);
    try std.testing.expectEqual(@as(i64, 0), stz_seq_next("counter", 7));
    try std.testing.expectEqual(@as(i64, 1), stz_seq_next("counter", 7));
    try std.testing.expectEqual(@as(i64, 2), stz_seq_next("counter", 7));
    try std.testing.expectEqual(@as(i64, 3), stz_seq_current("counter", 7));
    stz_seq_clear();
}

test "repeat sequence" {
    stz_seq_clear();
    _ = stz_seq_create("cyc", 3, 0, 1, 1);
    _ = stz_seq_set_bounds("cyc", 3, 0, 2);
    try std.testing.expectEqual(@as(i64, 0), stz_seq_next("cyc", 3));
    try std.testing.expectEqual(@as(i64, 1), stz_seq_next("cyc", 3));
    try std.testing.expectEqual(@as(i64, 2), stz_seq_next("cyc", 3));
    try std.testing.expectEqual(@as(i64, 0), stz_seq_next("cyc", 3));
    stz_seq_clear();
}

test "bounce sequence" {
    stz_seq_clear();
    _ = stz_seq_create("b", 1, 0, 1, 2);
    _ = stz_seq_set_bounds("b", 1, 0, 2);
    try std.testing.expectEqual(@as(i64, 0), stz_seq_next("b", 1));
    try std.testing.expectEqual(@as(i64, 1), stz_seq_next("b", 1));
    try std.testing.expectEqual(@as(i64, 2), stz_seq_next("b", 1));
    try std.testing.expectEqual(@as(i64, 1), stz_seq_next("b", 1));
    stz_seq_clear();
}

test "reset" {
    stz_seq_clear();
    _ = stz_seq_create("r", 1, 10, 5, 0);
    _ = stz_seq_next("r", 1);
    _ = stz_seq_next("r", 1);
    stz_seq_reset("r", 1);
    try std.testing.expectEqual(@as(i64, 10), stz_seq_current("r", 1));
    try std.testing.expectEqual(@as(i64, 0), stz_seq_iteration("r", 1));
    stz_seq_clear();
}

test "count and destroy" {
    stz_seq_clear();
    _ = stz_seq_create("s1", 2, 0, 1, 0);
    _ = stz_seq_create("s2", 2, 0, 1, 0);
    try std.testing.expectEqual(@as(i32, 2), stz_seq_count());
    stz_seq_destroy("s1", 2);
    try std.testing.expectEqual(@as(i32, 1), stz_seq_count());
    stz_seq_clear();
    try std.testing.expectEqual(@as(i32, 0), stz_seq_count());
}

test "iteration counter" {
    stz_seq_clear();
    _ = stz_seq_create("it", 2, 0, 3, 0);
    try std.testing.expectEqual(@as(i64, 0), stz_seq_iteration("it", 2));
    _ = stz_seq_next("it", 2);
    try std.testing.expectEqual(@as(i64, 1), stz_seq_iteration("it", 2));
    _ = stz_seq_next("it", 2);
    _ = stz_seq_next("it", 2);
    try std.testing.expectEqual(@as(i64, 3), stz_seq_iteration("it", 2));
    stz_seq_clear();
}

test "step with negative step" {
    stz_seq_clear();
    _ = stz_seq_create("neg", 3, 100, -10, 0);
    try std.testing.expectEqual(@as(i64, 100), stz_seq_next("neg", 3));
    try std.testing.expectEqual(@as(i64, 90), stz_seq_next("neg", 3));
    try std.testing.expectEqual(@as(i64, 80), stz_seq_next("neg", 3));
    stz_seq_clear();
}
