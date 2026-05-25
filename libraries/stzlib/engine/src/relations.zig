const std = @import("std");

// ─── Relations Engine ───
// Named binary relations between entities (256 max).

const MAX_RELATIONS: usize = 256;
const MAX_STR: usize = 64;

const Relation = struct {
    subject: [MAX_STR]u8 = undefined,
    subject_len: usize = 0,
    rel_type: [MAX_STR]u8 = undefined,
    rel_type_len: usize = 0,
    object: [MAX_STR]u8 = undefined,
    object_len: usize = 0,
    weight: f64 = 1.0,
    active: bool = false,
};

var relations: [MAX_RELATIONS]Relation = [_]Relation{.{}} ** MAX_RELATIONS;
var rel_count: usize = 0;

fn strEq(a: []const u8, b: [*]const u8, b_len: usize) bool {
    if (a.len != b_len) return false;
    return std.mem.eql(u8, a, b[0..b_len]);
}

// ─── C ABI ───

pub export fn stz_rel_add(subj: [*]const u8, subj_len: usize, rel: [*]const u8, rel_len: usize, obj: [*]const u8, obj_len: usize, weight: f64) i32 {
    for (0..MAX_RELATIONS) |idx| {
        if (!relations[idx].active) {
            const sl = @min(subj_len, MAX_STR);
            @memcpy(relations[idx].subject[0..sl], subj[0..sl]);
            relations[idx].subject_len = sl;
            const rl = @min(rel_len, MAX_STR);
            @memcpy(relations[idx].rel_type[0..rl], rel[0..rl]);
            relations[idx].rel_type_len = rl;
            const ol = @min(obj_len, MAX_STR);
            @memcpy(relations[idx].object[0..ol], obj[0..ol]);
            relations[idx].object_len = ol;
            relations[idx].weight = weight;
            relations[idx].active = true;
            rel_count += 1;
            return @intCast(idx);
        }
    }
    return -1;
}

pub export fn stz_rel_count() i32 {
    return @intCast(rel_count);
}

pub export fn stz_rel_find_by_subject(subj: [*]const u8, subj_len: usize, out: [*]i32) i32 {
    var n: usize = 0;
    for (0..MAX_RELATIONS) |idx| {
        if (relations[idx].active and strEq(relations[idx].subject[0..relations[idx].subject_len], subj, subj_len)) {
            out[n] = @intCast(idx);
            n += 1;
        }
    }
    return @intCast(n);
}

pub export fn stz_rel_find_by_object(obj: [*]const u8, obj_len: usize, out: [*]i32) i32 {
    var n: usize = 0;
    for (0..MAX_RELATIONS) |idx| {
        if (relations[idx].active and strEq(relations[idx].object[0..relations[idx].object_len], obj, obj_len)) {
            out[n] = @intCast(idx);
            n += 1;
        }
    }
    return @intCast(n);
}

pub export fn stz_rel_subject(idx: i32, out: [*]u8) i32 {
    if (idx < 0 or idx >= @as(i32, MAX_RELATIONS)) return 0;
    const ii: usize = @intCast(idx);
    if (!relations[ii].active) return 0;
    const len = relations[ii].subject_len;
    @memcpy(out[0..len], relations[ii].subject[0..len]);
    return @intCast(len);
}

pub export fn stz_rel_object(idx: i32, out: [*]u8) i32 {
    if (idx < 0 or idx >= @as(i32, MAX_RELATIONS)) return 0;
    const ii: usize = @intCast(idx);
    if (!relations[ii].active) return 0;
    const len = relations[ii].object_len;
    @memcpy(out[0..len], relations[ii].object[0..len]);
    return @intCast(len);
}

pub export fn stz_rel_type(idx: i32, out: [*]u8) i32 {
    if (idx < 0 or idx >= @as(i32, MAX_RELATIONS)) return 0;
    const ii: usize = @intCast(idx);
    if (!relations[ii].active) return 0;
    const len = relations[ii].rel_type_len;
    @memcpy(out[0..len], relations[ii].rel_type[0..len]);
    return @intCast(len);
}

pub export fn stz_rel_weight(idx: i32) f64 {
    if (idx < 0 or idx >= @as(i32, MAX_RELATIONS)) return 0.0;
    const ii: usize = @intCast(idx);
    if (!relations[ii].active) return 0.0;
    return relations[ii].weight;
}

pub export fn stz_rel_remove(idx: i32) void {
    if (idx < 0 or idx >= @as(i32, MAX_RELATIONS)) return;
    const ii: usize = @intCast(idx);
    if (relations[ii].active) {
        relations[ii].active = false;
        rel_count -= 1;
    }
}

pub export fn stz_rel_clear() void {
    for (0..MAX_RELATIONS) |idx| relations[idx].active = false;
    rel_count = 0;
}

// ─── Tests ───

test "add and query relations" {
    stz_rel_clear();
    _ = stz_rel_add("cat", 3, "is_a", 4, "animal", 6, 1.0);
    _ = stz_rel_add("dog", 3, "is_a", 4, "animal", 6, 1.0);
    _ = stz_rel_add("cat", 3, "has", 3, "whiskers", 8, 0.9);
    try std.testing.expectEqual(@as(i32, 3), stz_rel_count());

    var out: [256]i32 = undefined;
    const n = stz_rel_find_by_subject("cat", 3, &out);
    try std.testing.expectEqual(@as(i32, 2), n);
    stz_rel_clear();
}

test "find by object" {
    stz_rel_clear();
    _ = stz_rel_add("A", 1, "r", 1, "X", 1, 1.0);
    _ = stz_rel_add("B", 1, "r", 1, "X", 1, 1.0);
    _ = stz_rel_add("C", 1, "r", 1, "Y", 1, 1.0);
    var out: [256]i32 = undefined;
    const n = stz_rel_find_by_object("X", 1, &out);
    try std.testing.expectEqual(@as(i32, 2), n);
    stz_rel_clear();
}

test "relation fields" {
    stz_rel_clear();
    const idx = stz_rel_add("alice", 5, "knows", 5, "bob", 3, 0.8);
    var buf: [64]u8 = undefined;
    const sl = stz_rel_subject(idx, &buf);
    try std.testing.expectEqualSlices(u8, "alice", buf[0..@intCast(sl)]);
    const ol = stz_rel_object(idx, &buf);
    try std.testing.expectEqualSlices(u8, "bob", buf[0..@intCast(ol)]);
    try std.testing.expectApproxEqAbs(@as(f64, 0.8), stz_rel_weight(idx), 0.001);
    stz_rel_clear();
}

test "remove" {
    stz_rel_clear();
    const idx = stz_rel_add("a", 1, "b", 1, "c", 1, 1.0);
    stz_rel_remove(idx);
    try std.testing.expectEqual(@as(i32, 0), stz_rel_count());
    stz_rel_clear();
}
