const std = @import("std");

// ─── Deep Operations Engine ───
// Flatten depth, recursive find, path-based access on nested structures.
// Simulates up to 16 nesting levels with fixed-size arrays.

const MAX_DEPTH: usize = 16;
const MAX_ELEMENTS_PER_LEVEL: usize = 64;

var nesting_depth: usize = 0;
var level_sizes: [MAX_DEPTH]usize = [_]usize{0} ** MAX_DEPTH;
// Each level stores its elements (simulated as i32 values = level_index * 100 + element_index)
var level_data: [MAX_DEPTH][MAX_ELEMENTS_PER_LEVEL]i32 = [_][MAX_ELEMENTS_PER_LEVEL]i32{[_]i32{0} ** MAX_ELEMENTS_PER_LEVEL} ** MAX_DEPTH;

// ─── C ABI ───

pub export fn stz_deep_set_nesting(depth: i32, sizes_ptr: [*]const i32, count: i32) void {
    const d: usize = @intCast(@min(depth, @as(i32, MAX_DEPTH)));
    const c: usize = @intCast(@min(count, @as(i32, MAX_DEPTH)));
    const actual = @min(d, c);
    nesting_depth = actual;
    for (0..MAX_DEPTH) |i| {
        level_sizes[i] = 0;
    }
    for (0..actual) |i| {
        const sz: usize = @intCast(@min(sizes_ptr[i], @as(i32, MAX_ELEMENTS_PER_LEVEL)));
        level_sizes[i] = sz;
        // populate with synthetic values
        for (0..sz) |j| {
            level_data[i][j] = @as(i32, @intCast(i)) * 100 + @as(i32, @intCast(j));
        }
    }
}

pub export fn stz_deep_total_elements() i32 {
    var total: usize = 0;
    for (0..nesting_depth) |i| {
        total += level_sizes[i];
    }
    return @intCast(total);
}

pub export fn stz_deep_element_at_flat(flat_idx: i32) i32 {
    if (flat_idx < 0) return -1;
    var remaining: usize = @intCast(flat_idx);
    for (0..nesting_depth) |level| {
        if (remaining < level_sizes[level]) {
            return level_data[level][remaining];
        }
        remaining -= level_sizes[level];
    }
    return -1;
}

pub export fn stz_deep_depth() i32 {
    return @intCast(nesting_depth);
}

pub export fn stz_deep_flatten(out: [*]i32) i32 {
    var idx: usize = 0;
    for (0..nesting_depth) |level| {
        for (0..level_sizes[level]) |j| {
            out[idx] = level_data[level][j];
            idx += 1;
        }
    }
    return @intCast(idx);
}

pub export fn stz_deep_find(value: i32, results: [*]i32) i32 {
    var count: usize = 0;
    var flat_idx: usize = 0;
    for (0..nesting_depth) |level| {
        for (0..level_sizes[level]) |j| {
            if (level_data[level][j] == value) {
                results[count] = @intCast(flat_idx);
                count += 1;
            }
            flat_idx += 1;
        }
    }
    return @intCast(count);
}

pub export fn stz_deep_clear() void {
    nesting_depth = 0;
    for (0..MAX_DEPTH) |i| {
        level_sizes[i] = 0;
    }
}

// ─── Tests ───

test "set nesting and depth" {
    stz_deep_clear();
    var sizes = [_]i32{ 3, 2, 4 };
    stz_deep_set_nesting(3, &sizes, 3);
    try std.testing.expectEqual(@as(i32, 3), stz_deep_depth());
    try std.testing.expectEqual(@as(i32, 9), stz_deep_total_elements());
    stz_deep_clear();
}

test "flatten" {
    stz_deep_clear();
    var sizes = [_]i32{ 2, 3 };
    stz_deep_set_nesting(2, &sizes, 2);
    var out: [64]i32 = undefined;
    const n = stz_deep_flatten(&out);
    try std.testing.expectEqual(@as(i32, 5), n);
    // level 0: 0,1  level 1: 100,101,102
    try std.testing.expectEqual(@as(i32, 0), out[0]);
    try std.testing.expectEqual(@as(i32, 1), out[1]);
    try std.testing.expectEqual(@as(i32, 100), out[2]);
    stz_deep_clear();
}

test "element at flat index" {
    stz_deep_clear();
    var sizes = [_]i32{ 2, 3 };
    stz_deep_set_nesting(2, &sizes, 2);
    try std.testing.expectEqual(@as(i32, 0), stz_deep_element_at_flat(0));
    try std.testing.expectEqual(@as(i32, 1), stz_deep_element_at_flat(1));
    try std.testing.expectEqual(@as(i32, 100), stz_deep_element_at_flat(2));
    try std.testing.expectEqual(@as(i32, -1), stz_deep_element_at_flat(99));
    stz_deep_clear();
}

test "find value" {
    stz_deep_clear();
    var sizes = [_]i32{ 3, 3 };
    stz_deep_set_nesting(2, &sizes, 2);
    var results: [16]i32 = undefined;
    const n = stz_deep_find(101, &results);
    try std.testing.expectEqual(@as(i32, 1), n);
    try std.testing.expectEqual(@as(i32, 4), results[0]); // flat index 4
    stz_deep_clear();
}

test "clear resets" {
    var sizes = [_]i32{5};
    stz_deep_set_nesting(1, &sizes, 1);
    stz_deep_clear();
    try std.testing.expectEqual(@as(i32, 0), stz_deep_depth());
    try std.testing.expectEqual(@as(i32, 0), stz_deep_total_elements());
}
