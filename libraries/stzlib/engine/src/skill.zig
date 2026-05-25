const std = @import("std");

// ─── Skill Engine ───
// 64-slot named skills with levels, prerequisites, and assessment tracking.

const MAX_SKILLS: usize = 64;
const MAX_NAME: usize = 64;
const MAX_PREREQS: usize = 8;

const Level = enum(u8) {
    novice = 0,
    beginner = 1,
    intermediate = 2,
    advanced = 3,
    expert = 4,
};

const Skill = struct {
    name: [MAX_NAME]u8 = undefined,
    name_len: usize = 0,
    category: [MAX_NAME]u8 = undefined,
    category_len: usize = 0,
    level: Level = .novice,
    score: f64 = 0.0,
    attempts: u32 = 0,
    successes: u32 = 0,
    prereqs: [MAX_PREREQS]usize = undefined,
    prereq_count: usize = 0,
    active: bool = false,
};

var skills: [MAX_SKILLS]Skill = [_]Skill{.{}} ** MAX_SKILLS;
var skill_count: usize = 0;

fn findByName(name: [*]const u8, len: usize) ?usize {
    for (0..MAX_SKILLS) |idx| {
        if (skills[idx].active and skills[idx].name_len == len) {
            if (std.mem.eql(u8, skills[idx].name[0..len], name[0..len])) return idx;
        }
    }
    return null;
}

// ─── C ABI ───

pub export fn stz_skill_register(name: [*]const u8, name_len: usize, cat: [*]const u8, cat_len: usize) i32 {
    if (findByName(name, name_len) != null) return -2;
    for (0..MAX_SKILLS) |idx| {
        if (!skills[idx].active) {
            const nl = @min(name_len, MAX_NAME);
            @memcpy(skills[idx].name[0..nl], name[0..nl]);
            skills[idx].name_len = nl;
            const cl = @min(cat_len, MAX_NAME);
            @memcpy(skills[idx].category[0..cl], cat[0..cl]);
            skills[idx].category_len = cl;
            skills[idx].level = .novice;
            skills[idx].score = 0.0;
            skills[idx].attempts = 0;
            skills[idx].successes = 0;
            skills[idx].prereq_count = 0;
            skills[idx].active = true;
            skill_count += 1;
            return @intCast(idx);
        }
    }
    return -1;
}

pub export fn stz_skill_record_attempt(name: [*]const u8, name_len: usize, success: i32) i32 {
    const idx = findByName(name, name_len) orelse return 0;
    skills[idx].attempts += 1;
    if (success != 0) skills[idx].successes += 1;
    if (skills[idx].attempts > 0) {
        skills[idx].score = @as(f64, @floatFromInt(skills[idx].successes)) / @as(f64, @floatFromInt(skills[idx].attempts));
    }
    if (skills[idx].score >= 0.9 and skills[idx].attempts >= 10) {
        skills[idx].level = .expert;
    } else if (skills[idx].score >= 0.75 and skills[idx].attempts >= 7) {
        skills[idx].level = .advanced;
    } else if (skills[idx].score >= 0.5 and skills[idx].attempts >= 5) {
        skills[idx].level = .intermediate;
    } else if (skills[idx].attempts >= 3) {
        skills[idx].level = .beginner;
    }
    return 1;
}

pub export fn stz_skill_level(name: [*]const u8, name_len: usize) i32 {
    const idx = findByName(name, name_len) orelse return -1;
    return @intFromEnum(skills[idx].level);
}

pub export fn stz_skill_score(name: [*]const u8, name_len: usize) f64 {
    const idx = findByName(name, name_len) orelse return 0.0;
    return skills[idx].score;
}

pub export fn stz_skill_attempts(name: [*]const u8, name_len: usize) i32 {
    const idx = findByName(name, name_len) orelse return 0;
    return @intCast(skills[idx].attempts);
}

pub export fn stz_skill_successes(name: [*]const u8, name_len: usize) i32 {
    const idx = findByName(name, name_len) orelse return 0;
    return @intCast(skills[idx].successes);
}

pub export fn stz_skill_add_prereq(name: [*]const u8, name_len: usize, prereq: [*]const u8, prereq_len: usize) i32 {
    const idx = findByName(name, name_len) orelse return 0;
    const pidx = findByName(prereq, prereq_len) orelse return 0;
    if (skills[idx].prereq_count >= MAX_PREREQS) return 0;
    skills[idx].prereqs[skills[idx].prereq_count] = pidx;
    skills[idx].prereq_count += 1;
    return 1;
}

pub export fn stz_skill_prereqs_met(name: [*]const u8, name_len: usize) i32 {
    const idx = findByName(name, name_len) orelse return 0;
    for (0..skills[idx].prereq_count) |pi| {
        const pidx = skills[idx].prereqs[pi];
        if (!skills[pidx].active) return 0;
        if (@intFromEnum(skills[pidx].level) < @intFromEnum(Level.intermediate)) return 0;
    }
    return 1;
}

pub export fn stz_skill_count() i32 {
    return @intCast(skill_count);
}

pub export fn stz_skill_count_by_category(cat: [*]const u8, cat_len: usize) i32 {
    var count: i32 = 0;
    for (0..MAX_SKILLS) |idx| {
        if (skills[idx].active and skills[idx].category_len == cat_len) {
            if (std.mem.eql(u8, skills[idx].category[0..cat_len], cat[0..cat_len])) {
                count += 1;
            }
        }
    }
    return count;
}

pub export fn stz_skill_unregister(name: [*]const u8, name_len: usize) i32 {
    const idx = findByName(name, name_len) orelse return 0;
    skills[idx].active = false;
    skill_count -= 1;
    return 1;
}

pub export fn stz_skill_clear() void {
    for (0..MAX_SKILLS) |idx| skills[idx].active = false;
    skill_count = 0;
}

// ─── Tests ───

test "register and record attempts" {
    stz_skill_clear();
    const idx = stz_skill_register("sorting", 7, "algorithms", 10);
    try std.testing.expect(idx >= 0);
    try std.testing.expectEqual(@as(i32, 0), stz_skill_level("sorting", 7));

    var pass: usize = 0;
    while (pass < 10) : (pass += 1) {
        _ = stz_skill_record_attempt("sorting", 7, 1);
    }
    try std.testing.expectEqual(@as(i32, 4), stz_skill_level("sorting", 7));
    try std.testing.expectApproxEqAbs(@as(f64, 1.0), stz_skill_score("sorting", 7), 0.01);
    stz_skill_clear();
}

test "prerequisites" {
    stz_skill_clear();
    _ = stz_skill_register("basics", 6, "prog", 4);
    _ = stz_skill_register("advanced", 8, "prog", 4);
    _ = stz_skill_add_prereq("advanced", 8, "basics", 6);
    try std.testing.expectEqual(@as(i32, 0), stz_skill_prereqs_met("advanced", 8));

    var pass: usize = 0;
    while (pass < 5) : (pass += 1) {
        _ = stz_skill_record_attempt("basics", 6, 1);
    }
    try std.testing.expectEqual(@as(i32, 1), stz_skill_prereqs_met("advanced", 8));
    stz_skill_clear();
}

test "category counting" {
    stz_skill_clear();
    _ = stz_skill_register("a", 1, "math", 4);
    _ = stz_skill_register("b", 1, "math", 4);
    _ = stz_skill_register("c", 1, "lang", 4);
    try std.testing.expectEqual(@as(i32, 2), stz_skill_count_by_category("math", 4));
    try std.testing.expectEqual(@as(i32, 1), stz_skill_count_by_category("lang", 4));
    stz_skill_clear();
}

test "duplicate rejected" {
    stz_skill_clear();
    _ = stz_skill_register("x", 1, "c", 1);
    try std.testing.expectEqual(@as(i32, -2), stz_skill_register("x", 1, "c", 1));
    stz_skill_clear();
}
