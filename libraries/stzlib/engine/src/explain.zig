const std = @import("std");

// ─── Explanation Engine ───
// 64-slot named explanations: attach human-readable reasons to operations.

const MAX_SLOTS: usize = 64;
const MAX_KEY: usize = 64;
const MAX_TEXT: usize = 512;

const Explanation = struct {
    key: [MAX_KEY]u8 = undefined,
    key_len: usize = 0,
    text: [MAX_TEXT]u8 = undefined,
    text_len: usize = 0,
    category: [MAX_KEY]u8 = undefined,
    category_len: usize = 0,
    active: bool = false,
};

var explanations: [MAX_SLOTS]Explanation = [_]Explanation{.{}} ** MAX_SLOTS;
var expl_count: usize = 0;

fn findByKey(key: [*]const u8, len: usize) ?usize {
    for (0..MAX_SLOTS) |idx| {
        if (explanations[idx].active and explanations[idx].key_len == len) {
            if (std.mem.eql(u8, explanations[idx].key[0..len], key[0..len])) return idx;
        }
    }
    return null;
}

fn findFreeSlot() ?usize {
    for (0..MAX_SLOTS) |idx| {
        if (!explanations[idx].active) return idx;
    }
    return null;
}

// ─── C ABI ───

pub export fn stz_expl_add(key: [*]const u8, key_len: usize, text: [*]const u8, text_len: usize, cat: [*]const u8, cat_len: usize) i32 {
    if (findByKey(key, key_len)) |idx| {
        const ct = @min(text_len, MAX_TEXT);
        @memcpy(explanations[idx].text[0..ct], text[0..ct]);
        explanations[idx].text_len = ct;
        const cc = @min(cat_len, MAX_KEY);
        @memcpy(explanations[idx].category[0..cc], cat[0..cc]);
        explanations[idx].category_len = cc;
        return @intCast(idx);
    }
    const slot = findFreeSlot() orelse return -1;
    const ck = @min(key_len, MAX_KEY);
    @memcpy(explanations[slot].key[0..ck], key[0..ck]);
    explanations[slot].key_len = ck;
    const ct = @min(text_len, MAX_TEXT);
    @memcpy(explanations[slot].text[0..ct], text[0..ct]);
    explanations[slot].text_len = ct;
    const cc = @min(cat_len, MAX_KEY);
    @memcpy(explanations[slot].category[0..cc], cat[0..cc]);
    explanations[slot].category_len = cc;
    explanations[slot].active = true;
    expl_count += 1;
    return @intCast(slot);
}

pub export fn stz_expl_get(key: [*]const u8, key_len: usize, out: [*]u8) i32 {
    const idx = findByKey(key, key_len) orelse return 0;
    const len = explanations[idx].text_len;
    @memcpy(out[0..len], explanations[idx].text[0..len]);
    return @intCast(len);
}

pub export fn stz_expl_category(key: [*]const u8, key_len: usize, out: [*]u8) i32 {
    const idx = findByKey(key, key_len) orelse return 0;
    const len = explanations[idx].category_len;
    @memcpy(out[0..len], explanations[idx].category[0..len]);
    return @intCast(len);
}

pub export fn stz_expl_count() i32 {
    return @intCast(expl_count);
}

pub export fn stz_expl_count_by_category(cat: [*]const u8, cat_len: usize) i32 {
    var count: i32 = 0;
    for (0..MAX_SLOTS) |idx| {
        if (explanations[idx].active and explanations[idx].category_len == cat_len) {
            if (std.mem.eql(u8, explanations[idx].category[0..cat_len], cat[0..cat_len])) {
                count += 1;
            }
        }
    }
    return count;
}

pub export fn stz_expl_has(key: [*]const u8, key_len: usize) i32 {
    return if (findByKey(key, key_len) != null) @as(i32, 1) else @as(i32, 0);
}

pub export fn stz_expl_remove(key: [*]const u8, key_len: usize) i32 {
    const idx = findByKey(key, key_len) orelse return 0;
    explanations[idx].active = false;
    expl_count -= 1;
    return 1;
}

pub export fn stz_expl_clear() void {
    for (0..MAX_SLOTS) |idx| {
        explanations[idx].active = false;
    }
    expl_count = 0;
}

// ─── Tests ───

test "add and get explanation" {
    stz_expl_clear();
    const idx = stz_expl_add("sort_choice", 11, "Used quicksort because data is random", 37, "algorithm", 9);
    try std.testing.expect(idx >= 0);
    var buf: [512]u8 = undefined;
    const len = stz_expl_get("sort_choice", 11, &buf);
    try std.testing.expectEqualSlices(u8, "Used quicksort because data is random", buf[0..@intCast(len)]);
    stz_expl_clear();
}

test "category query" {
    stz_expl_clear();
    _ = stz_expl_add("a", 1, "reason a", 8, "perf", 4);
    _ = stz_expl_add("b", 1, "reason b", 8, "perf", 4);
    _ = stz_expl_add("c", 1, "reason c", 8, "safety", 6);
    try std.testing.expectEqual(@as(i32, 2), stz_expl_count_by_category("perf", 4));
    try std.testing.expectEqual(@as(i32, 1), stz_expl_count_by_category("safety", 6));
    stz_expl_clear();
}

test "has and remove" {
    stz_expl_clear();
    _ = stz_expl_add("key1", 4, "text1", 5, "cat", 3);
    try std.testing.expectEqual(@as(i32, 1), stz_expl_has("key1", 4));
    _ = stz_expl_remove("key1", 4);
    try std.testing.expectEqual(@as(i32, 0), stz_expl_has("key1", 4));
    stz_expl_clear();
}

test "update existing" {
    stz_expl_clear();
    _ = stz_expl_add("k", 1, "old", 3, "c", 1);
    _ = stz_expl_add("k", 1, "new text", 8, "c", 1);
    try std.testing.expectEqual(@as(i32, 1), stz_expl_count());
    var buf: [512]u8 = undefined;
    const len = stz_expl_get("k", 1, &buf);
    try std.testing.expectEqualSlices(u8, "new text", buf[0..@intCast(len)]);
    stz_expl_clear();
}
