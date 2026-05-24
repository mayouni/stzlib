const std = @import("std");

// ─── Grid Navigation Engine ───
// 2D grid with dimensions, position tracking, neighbor queries.

var grid_rows: i32 = 0;
var grid_cols: i32 = 0;
var cur_row: i32 = 0;
var cur_col: i32 = 0;

// ─── C ABI ───

pub export fn stz_grid_create(rows: i32, cols: i32) i32 {
    if (rows <= 0 or cols <= 0) return -1;
    grid_rows = rows;
    grid_cols = cols;
    cur_row = 0;
    cur_col = 0;
    return 0;
}

pub export fn stz_grid_set_pos(row: i32, col: i32) void {
    cur_row = row;
    cur_col = col;
}

pub export fn stz_grid_get_row() i32 {
    return cur_row;
}

pub export fn stz_grid_get_col() i32 {
    return cur_col;
}

pub export fn stz_grid_move(dir: i32) i32 {
    var nr = cur_row;
    var nc = cur_col;
    switch (dir) {
        0 => nr -= 1, // up
        1 => nc += 1, // right
        2 => nr += 1, // down
        3 => nc -= 1, // left
        else => return -1,
    }
    if (nr < 0 or nr >= grid_rows or nc < 0 or nc >= grid_cols) return -1;
    cur_row = nr;
    cur_col = nc;
    return 0;
}

pub export fn stz_grid_neighbors(out_rows: [*]i32, out_cols: [*]i32) i32 {
    const deltas = [_][2]i32{ .{ -1, 0 }, .{ 1, 0 }, .{ 0, -1 }, .{ 0, 1 } };
    var count: usize = 0;
    for (deltas) |d| {
        const nr = cur_row + d[0];
        const nc = cur_col + d[1];
        if (nr >= 0 and nr < grid_rows and nc >= 0 and nc < grid_cols) {
            out_rows[count] = nr;
            out_cols[count] = nc;
            count += 1;
        }
    }
    return @intCast(count);
}

pub export fn stz_grid_is_valid(row: i32, col: i32) i32 {
    if (row >= 0 and row < grid_rows and col >= 0 and col < grid_cols) return 1;
    return 0;
}

pub export fn stz_grid_distance(r1: i32, c1: i32, r2: i32, c2: i32) i32 {
    const dr = if (r2 > r1) r2 - r1 else r1 - r2;
    const dc = if (c2 > c1) c2 - c1 else c1 - c2;
    return dr + dc;
}

pub export fn stz_grid_reset() void {
    grid_rows = 0;
    grid_cols = 0;
    cur_row = 0;
    cur_col = 0;
}

// ─── Tests ───

test "create and position" {
    _ = stz_grid_create(5, 5);
    try std.testing.expectEqual(@as(i32, 0), stz_grid_get_row());
    try std.testing.expectEqual(@as(i32, 0), stz_grid_get_col());
    stz_grid_reset();
}

test "set position" {
    _ = stz_grid_create(10, 10);
    stz_grid_set_pos(3, 7);
    try std.testing.expectEqual(@as(i32, 3), stz_grid_get_row());
    try std.testing.expectEqual(@as(i32, 7), stz_grid_get_col());
    stz_grid_reset();
}

test "move in directions" {
    _ = stz_grid_create(5, 5);
    stz_grid_set_pos(2, 2);
    try std.testing.expectEqual(@as(i32, 0), stz_grid_move(1)); // right
    try std.testing.expectEqual(@as(i32, 3), stz_grid_get_col());
    try std.testing.expectEqual(@as(i32, 0), stz_grid_move(2)); // down
    try std.testing.expectEqual(@as(i32, 3), stz_grid_get_row());
    stz_grid_reset();
}

test "boundary check" {
    _ = stz_grid_create(3, 3);
    stz_grid_set_pos(0, 0);
    try std.testing.expectEqual(@as(i32, -1), stz_grid_move(0)); // up from 0,0
    try std.testing.expectEqual(@as(i32, -1), stz_grid_move(3)); // left from 0,0
    stz_grid_reset();
}

test "neighbors" {
    _ = stz_grid_create(5, 5);
    stz_grid_set_pos(0, 0);
    var rows: [4]i32 = undefined;
    var cols: [4]i32 = undefined;
    const n = stz_grid_neighbors(&rows, &cols);
    try std.testing.expectEqual(@as(i32, 2), n); // corner: 2 neighbors
    stz_grid_set_pos(2, 2);
    const m = stz_grid_neighbors(&rows, &cols);
    try std.testing.expectEqual(@as(i32, 4), m); // center: 4 neighbors
    stz_grid_reset();
}

test "manhattan distance" {
    try std.testing.expectEqual(@as(i32, 7), stz_grid_distance(1, 2, 4, 6));
    try std.testing.expectEqual(@as(i32, 0), stz_grid_distance(3, 3, 3, 3));
}
