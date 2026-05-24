const std = @import("std");

// ── Constraint Engine ───────────────────────────────────────
// Declarative validation: define constraints, check values,
// collect violations. Up to 128 named constraints.

const MAX_CONSTRAINTS = 128;
const MAX_NAME_LEN = 64;
const MAX_MSG_LEN = 256;

const ConstraintKind = enum(u8) {
    empty = 0,
    range = 1,
    not_empty = 2,
    min_len = 3,
    max_len = 4,
    matches_set = 5,
};

const Constraint = struct {
    kind: ConstraintKind = .empty,
    name: [MAX_NAME_LEN]u8 = undefined,
    name_len: usize = 0,
    msg: [MAX_MSG_LEN]u8 = undefined,
    msg_len: usize = 0,
    min_val: f64 = 0,
    max_val: f64 = 0,
    int_param: i32 = 0,
};

var constraints: [MAX_CONSTRAINTS]Constraint = [_]Constraint{.{}} ** MAX_CONSTRAINTS;
var constraint_count: usize = 0;

var violation_buf: [MAX_MSG_LEN]u8 = undefined;
var violation_len: usize = 0;

pub fn add_range(name_ptr: [*]const u8, name_len: usize, min_val: f64, max_val: f64) callconv(.c) i32 {
    if (constraint_count >= MAX_CONSTRAINTS) return -1;
    var c = &constraints[constraint_count];
    c.kind = .range;
    const nl = @min(name_len, MAX_NAME_LEN);
    @memcpy(c.name[0..nl], name_ptr[0..nl]);
    c.name_len = nl;
    c.min_val = min_val;
    c.max_val = max_val;
    const msg = "value out of range";
    @memcpy(c.msg[0..msg.len], msg);
    c.msg_len = msg.len;
    constraint_count += 1;
    return @intCast(constraint_count - 1);
}

pub fn add_not_empty(name_ptr: [*]const u8, name_len: usize) callconv(.c) i32 {
    if (constraint_count >= MAX_CONSTRAINTS) return -1;
    var c = &constraints[constraint_count];
    c.kind = .not_empty;
    const nl = @min(name_len, MAX_NAME_LEN);
    @memcpy(c.name[0..nl], name_ptr[0..nl]);
    c.name_len = nl;
    const msg = "value must not be empty";
    @memcpy(c.msg[0..msg.len], msg);
    c.msg_len = msg.len;
    constraint_count += 1;
    return @intCast(constraint_count - 1);
}

pub fn add_min_len(name_ptr: [*]const u8, name_len: usize, min: i32) callconv(.c) i32 {
    if (constraint_count >= MAX_CONSTRAINTS) return -1;
    var c = &constraints[constraint_count];
    c.kind = .min_len;
    const nl = @min(name_len, MAX_NAME_LEN);
    @memcpy(c.name[0..nl], name_ptr[0..nl]);
    c.name_len = nl;
    c.int_param = min;
    const msg = "value too short";
    @memcpy(c.msg[0..msg.len], msg);
    c.msg_len = msg.len;
    constraint_count += 1;
    return @intCast(constraint_count - 1);
}

pub fn add_max_len(name_ptr: [*]const u8, name_len: usize, max: i32) callconv(.c) i32 {
    if (constraint_count >= MAX_CONSTRAINTS) return -1;
    var c = &constraints[constraint_count];
    c.kind = .max_len;
    const nl = @min(name_len, MAX_NAME_LEN);
    @memcpy(c.name[0..nl], name_ptr[0..nl]);
    c.name_len = nl;
    c.int_param = max;
    const msg = "value too long";
    @memcpy(c.msg[0..msg.len], msg);
    c.msg_len = msg.len;
    constraint_count += 1;
    return @intCast(constraint_count - 1);
}

pub fn check_range(idx: i32, val: f64) callconv(.c) i32 {
    const i: usize = @intCast(idx);
    if (i >= constraint_count or constraints[i].kind != .range) return -1;
    const c = &constraints[i];
    if (val >= c.min_val and val <= c.max_val) return 1;
    @memcpy(violation_buf[0..c.msg_len], c.msg[0..c.msg_len]);
    violation_len = c.msg_len;
    return 0;
}

pub fn check_not_empty(idx: i32, str_len: usize) callconv(.c) i32 {
    const i: usize = @intCast(idx);
    if (i >= constraint_count or constraints[i].kind != .not_empty) return -1;
    if (str_len > 0) return 1;
    const c = &constraints[i];
    @memcpy(violation_buf[0..c.msg_len], c.msg[0..c.msg_len]);
    violation_len = c.msg_len;
    return 0;
}

pub fn check_min_len(idx: i32, str_len: usize) callconv(.c) i32 {
    const i: usize = @intCast(idx);
    if (i >= constraint_count or constraints[i].kind != .min_len) return -1;
    const c = &constraints[i];
    const min: usize = @intCast(c.int_param);
    if (str_len >= min) return 1;
    @memcpy(violation_buf[0..c.msg_len], c.msg[0..c.msg_len]);
    violation_len = c.msg_len;
    return 0;
}

pub fn check_max_len(idx: i32, str_len: usize) callconv(.c) i32 {
    const i: usize = @intCast(idx);
    if (i >= constraint_count or constraints[i].kind != .max_len) return -1;
    const c = &constraints[i];
    const max: usize = @intCast(c.int_param);
    if (str_len <= max) return 1;
    @memcpy(violation_buf[0..c.msg_len], c.msg[0..c.msg_len]);
    violation_len = c.msg_len;
    return 0;
}

pub fn last_violation(out: [*]u8) callconv(.c) i32 {
    if (violation_len == 0) return 0;
    @memcpy(out[0..violation_len], violation_buf[0..violation_len]);
    return @intCast(violation_len);
}

pub fn constraint_name(idx: i32, out: [*]u8) callconv(.c) i32 {
    const i: usize = @intCast(idx);
    if (i >= constraint_count) return 0;
    const c = &constraints[i];
    @memcpy(out[0..c.name_len], c.name[0..c.name_len]);
    return @intCast(c.name_len);
}

pub fn count() callconv(.c) i32 {
    return @intCast(constraint_count);
}

pub fn clear() callconv(.c) void {
    constraint_count = 0;
    violation_len = 0;
}

// ── C ABI exports ────────────────────────────────────────────

pub export fn stz_constraint_add_range(n: [*]const u8, nl: usize, min: f64, max: f64) callconv(.c) i32 { return add_range(n, nl, min, max); }
pub export fn stz_constraint_add_not_empty(n: [*]const u8, nl: usize) callconv(.c) i32 { return add_not_empty(n, nl); }
pub export fn stz_constraint_add_min_len(n: [*]const u8, nl: usize, m: i32) callconv(.c) i32 { return add_min_len(n, nl, m); }
pub export fn stz_constraint_add_max_len(n: [*]const u8, nl: usize, m: i32) callconv(.c) i32 { return add_max_len(n, nl, m); }
pub export fn stz_constraint_check_range(i: i32, v: f64) callconv(.c) i32 { return check_range(i, v); }
pub export fn stz_constraint_check_not_empty(i: i32, l: usize) callconv(.c) i32 { return check_not_empty(i, l); }
pub export fn stz_constraint_check_min_len(i: i32, l: usize) callconv(.c) i32 { return check_min_len(i, l); }
pub export fn stz_constraint_check_max_len(i: i32, l: usize) callconv(.c) i32 { return check_max_len(i, l); }
pub export fn stz_constraint_last_violation(o: [*]u8) callconv(.c) i32 { return last_violation(o); }
pub export fn stz_constraint_name(i: i32, o: [*]u8) callconv(.c) i32 { return constraint_name(i, o); }
pub export fn stz_constraint_count() callconv(.c) i32 { return count(); }
pub export fn stz_constraint_clear() callconv(.c) void { clear(); }

// ── Tests ────────────────────────────────────────────────────

test "constraint: range" {
    clear();
    const idx = add_range("age", 3, 0, 120);
    try std.testing.expect(idx >= 0);
    try std.testing.expectEqual(@as(i32, 1), check_range(idx, 25));
    try std.testing.expectEqual(@as(i32, 0), check_range(idx, 150));
}

test "constraint: not_empty" {
    clear();
    const idx = add_not_empty("name", 4);
    try std.testing.expectEqual(@as(i32, 1), check_not_empty(idx, 5));
    try std.testing.expectEqual(@as(i32, 0), check_not_empty(idx, 0));
}

test "constraint: min_len" {
    clear();
    const idx = add_min_len("password", 8, 8);
    try std.testing.expectEqual(@as(i32, 1), check_min_len(idx, 10));
    try std.testing.expectEqual(@as(i32, 0), check_min_len(idx, 5));
}

test "constraint: max_len" {
    clear();
    const idx = add_max_len("username", 8, 20);
    try std.testing.expectEqual(@as(i32, 1), check_max_len(idx, 15));
    try std.testing.expectEqual(@as(i32, 0), check_max_len(idx, 25));
}

test "constraint: violation message" {
    clear();
    const idx = add_range("score", 5, 0, 100);
    _ = check_range(idx, 200);
    var buf: [256]u8 = undefined;
    const len = last_violation(&buf);
    try std.testing.expectEqualStrings("value out of range", buf[0..@intCast(len)]);
}

test "constraint: count and clear" {
    clear();
    _ = add_range("a", 1, 0, 10);
    _ = add_not_empty("b", 1);
    try std.testing.expectEqual(@as(i32, 2), count());
    clear();
    try std.testing.expectEqual(@as(i32, 0), count());
}

test "constraint: name retrieval" {
    clear();
    _ = add_range("temperature", 11, -40, 60);
    var buf: [64]u8 = undefined;
    const len = constraint_name(0, &buf);
    try std.testing.expectEqualStrings("temperature", buf[0..@intCast(len)]);
}
