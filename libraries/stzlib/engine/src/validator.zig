const std = @import("std");

// ─── Validator Engine ───
// 64-slot named validation rules with results tracking.

const MAX_RULES: usize = 64;
const MAX_NAME: usize = 64;
const MAX_MSG: usize = 256;

const RuleKind = enum(u8) {
    required = 0,
    min_value = 1,
    max_value = 2,
    min_length = 3,
    max_length = 4,
    pattern = 5,
    custom = 6,
};

const Rule = struct {
    name: [MAX_NAME]u8 = undefined,
    name_len: usize = 0,
    kind: RuleKind = .required,
    threshold: i64 = 0,
    message: [MAX_MSG]u8 = undefined,
    message_len: usize = 0,
    active: bool = false,
};

const MAX_VIOLATIONS: usize = 128;

const Violation = struct {
    rule_idx: usize = 0,
    active: bool = false,
};

var rules: [MAX_RULES]Rule = [_]Rule{.{}} ** MAX_RULES;
var rule_count: usize = 0;
var violations: [MAX_VIOLATIONS]Violation = [_]Violation{.{}} ** MAX_VIOLATIONS;
var violation_count: usize = 0;

fn findByName(name: [*]const u8, len: usize) ?usize {
    for (0..MAX_RULES) |idx| {
        if (rules[idx].active and rules[idx].name_len == len) {
            if (std.mem.eql(u8, rules[idx].name[0..len], name[0..len])) return idx;
        }
    }
    return null;
}

// ─── C ABI ───

pub export fn stz_val_add_rule(name: [*]const u8, name_len: usize, kind: i32, threshold: i64, msg: [*]const u8, msg_len: usize) i32 {
    for (0..MAX_RULES) |idx| {
        if (!rules[idx].active) {
            const nl = @min(name_len, MAX_NAME);
            @memcpy(rules[idx].name[0..nl], name[0..nl]);
            rules[idx].name_len = nl;
            rules[idx].kind = @enumFromInt(@as(u8, @intCast(@min(kind, 6))));
            rules[idx].threshold = threshold;
            const ml = @min(msg_len, MAX_MSG);
            @memcpy(rules[idx].message[0..ml], msg[0..ml]);
            rules[idx].message_len = ml;
            rules[idx].active = true;
            rule_count += 1;
            return @intCast(idx);
        }
    }
    return -1;
}

pub export fn stz_val_check_int(name: [*]const u8, name_len: usize, value: i64) i32 {
    const idx = findByName(name, name_len) orelse return -1;
    return switch (rules[idx].kind) {
        .required => 1,
        .min_value => if (value >= rules[idx].threshold) @as(i32, 1) else @as(i32, 0),
        .max_value => if (value <= rules[idx].threshold) @as(i32, 1) else @as(i32, 0),
        else => 1,
    };
}

pub export fn stz_val_check_len(name: [*]const u8, name_len: usize, length: i64) i32 {
    const idx = findByName(name, name_len) orelse return -1;
    return switch (rules[idx].kind) {
        .min_length => if (length >= rules[idx].threshold) @as(i32, 1) else @as(i32, 0),
        .max_length => if (length <= rules[idx].threshold) @as(i32, 1) else @as(i32, 0),
        else => 1,
    };
}

pub export fn stz_val_message(rule_idx: i32, out: [*]u8) i32 {
    if (rule_idx < 0 or rule_idx >= @as(i32, MAX_RULES)) return 0;
    const idx: usize = @intCast(rule_idx);
    if (!rules[idx].active) return 0;
    const len = rules[idx].message_len;
    @memcpy(out[0..len], rules[idx].message[0..len]);
    return @intCast(len);
}

pub export fn stz_val_rule_count() i32 {
    return @intCast(rule_count);
}

pub export fn stz_val_add_violation(rule_idx: i32) i32 {
    if (rule_idx < 0 or rule_idx >= @as(i32, MAX_RULES)) return 0;
    for (0..MAX_VIOLATIONS) |vi| {
        if (!violations[vi].active) {
            violations[vi].rule_idx = @intCast(rule_idx);
            violations[vi].active = true;
            violation_count += 1;
            return 1;
        }
    }
    return 0;
}

pub export fn stz_val_violation_count() i32 {
    return @intCast(violation_count);
}

pub export fn stz_val_is_valid() i32 {
    return if (violation_count == 0) @as(i32, 1) else @as(i32, 0);
}

pub export fn stz_val_clear_violations() void {
    for (0..MAX_VIOLATIONS) |vi| {
        violations[vi].active = false;
    }
    violation_count = 0;
}

pub export fn stz_val_clear() void {
    for (0..MAX_RULES) |idx| {
        rules[idx].active = false;
    }
    rule_count = 0;
    stz_val_clear_violations();
}

// ─── Tests ───

test "add rule and check int" {
    stz_val_clear();
    _ = stz_val_add_rule("min_age", 7, 1, 18, "Must be 18+", 11);
    try std.testing.expectEqual(@as(i32, 1), stz_val_check_int("min_age", 7, 25));
    try std.testing.expectEqual(@as(i32, 0), stz_val_check_int("min_age", 7, 15));
    stz_val_clear();
}

test "check length" {
    stz_val_clear();
    _ = stz_val_add_rule("min_name", 8, 3, 2, "Too short", 9);
    try std.testing.expectEqual(@as(i32, 1), stz_val_check_len("min_name", 8, 5));
    try std.testing.expectEqual(@as(i32, 0), stz_val_check_len("min_name", 8, 1));
    stz_val_clear();
}

test "violations" {
    stz_val_clear();
    const r = stz_val_add_rule("r1", 2, 0, 0, "required", 8);
    try std.testing.expectEqual(@as(i32, 1), stz_val_is_valid());
    _ = stz_val_add_violation(r);
    try std.testing.expectEqual(@as(i32, 0), stz_val_is_valid());
    try std.testing.expectEqual(@as(i32, 1), stz_val_violation_count());
    stz_val_clear_violations();
    try std.testing.expectEqual(@as(i32, 1), stz_val_is_valid());
    stz_val_clear();
}

test "rule message" {
    stz_val_clear();
    const r = stz_val_add_rule("test", 4, 2, 100, "Max is 100", 10);
    var buf: [256]u8 = undefined;
    const len = stz_val_message(r, &buf);
    try std.testing.expectEqualSlices(u8, "Max is 100", buf[0..@intCast(len)]);
    stz_val_clear();
}
