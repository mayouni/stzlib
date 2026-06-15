const std = @import("std");

pub const StzMatrix = struct {
    data: []f64,
    rows: usize,
    cols: usize,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, rows: usize, cols: usize) !*StzMatrix {
        const m = try allocator.create(StzMatrix);
        m.* = .{
            .data = try allocator.alloc(f64, rows * cols),
            .rows = rows,
            .cols = cols,
            .allocator = allocator,
        };
        @memset(m.data, 0.0);
        return m;
    }

    pub fn deinit(self: *StzMatrix) void {
        self.allocator.free(self.data);
        self.allocator.destroy(self);
    }

    pub inline fn at(self: *const StzMatrix, r: usize, c: usize) f64 {
        return self.data[r * self.cols + c];
    }

    pub inline fn setAt(self: *StzMatrix, r: usize, c: usize, val: f64) void {
        self.data[r * self.cols + c] = val;
    }
};

const gpa = std.heap.page_allocator;

pub fn stz_matrix_new(rows: i32, cols: i32) callconv(.c) ?*StzMatrix {
    if (rows <= 0 or cols <= 0) return null;
    return StzMatrix.init(gpa, @intCast(rows), @intCast(cols)) catch null;
}

pub fn stz_matrix_free(m: ?*StzMatrix) callconv(.c) void {
    if (m) |mat| mat.deinit();
}

pub fn stz_matrix_rows(m: ?*const StzMatrix) callconv(.c) i32 {
    return if (m) |mat| @intCast(mat.rows) else 0;
}

pub fn stz_matrix_cols(m: ?*const StzMatrix) callconv(.c) i32 {
    return if (m) |mat| @intCast(mat.cols) else 0;
}

pub fn stz_matrix_set(m: ?*StzMatrix, row: i32, col: i32, val: f64) callconv(.c) void {
    const mat = m orelse return;
    const r: usize = @intCast(row);
    const c: usize = @intCast(col);
    if (r >= mat.rows or c >= mat.cols) return;
    mat.setAt(r, c, val);
}

pub fn stz_matrix_get(m: ?*const StzMatrix, row: i32, col: i32) callconv(.c) f64 {
    const mat = m orelse return 0.0;
    const r: usize = @intCast(row);
    const c: usize = @intCast(col);
    if (r >= mat.rows or c >= mat.cols) return 0.0;
    return mat.at(r, c);
}

pub fn stz_matrix_sum(m: ?*const StzMatrix) callconv(.c) f64 {
    const mat = m orelse return 0.0;
    var total: f64 = 0.0;
    for (mat.data) |v| total += v;
    return total;
}

pub fn stz_matrix_min(m: ?*const StzMatrix) callconv(.c) f64 {
    const mat = m orelse return 0.0;
    if (mat.data.len == 0) return 0.0;
    var result = mat.data[0];
    for (mat.data[1..]) |v| {
        if (v < result) result = v;
    }
    return result;
}

pub fn stz_matrix_max(m: ?*const StzMatrix) callconv(.c) f64 {
    const mat = m orelse return 0.0;
    if (mat.data.len == 0) return 0.0;
    var result = mat.data[0];
    for (mat.data[1..]) |v| {
        if (v > result) result = v;
    }
    return result;
}

pub fn stz_matrix_mean(m: ?*const StzMatrix) callconv(.c) f64 {
    const mat = m orelse return 0.0;
    const n = mat.rows * mat.cols;
    if (n == 0) return 0.0;
    return stz_matrix_sum(m) / @as(f64, @floatFromInt(n));
}

pub fn stz_matrix_add_scalar(m: ?*StzMatrix, val: f64) callconv(.c) void {
    const mat = m orelse return;
    for (mat.data) |*v| v.* += val;
}

pub fn stz_matrix_multiply_scalar(m: ?*StzMatrix, val: f64) callconv(.c) void {
    const mat = m orelse return;
    for (mat.data) |*v| v.* *= val;
}

// Apply +val (op=0) or *val (op=1) to every cell in the rectangular region
// rows r1..r2 x cols c1..c2 (1-based, inclusive). Coords are clamped to the
// matrix bounds. Covers add/mul on a single row/col, a row/col range, or the
// whole matrix -- the operation the Ring stzMatrix used to delegate to the
// (now-removed) RingFastPro updateList().
pub fn stz_matrix_update_region(m: ?*StzMatrix, op: i32, r1: i32, r2: i32, c1: i32, c2: i32, val: f64) callconv(.c) void {
    const mat = m orelse return;
    const nrows: i32 = @intCast(mat.rows);
    const ncols: i32 = @intCast(mat.cols);
    var rr1 = if (r1 < 1) 1 else r1;
    const cc1 = if (c1 < 1) 1 else c1;
    const rr2 = if (r2 > nrows) nrows else r2;
    const cc2 = if (c2 > ncols) ncols else c2;
    while (rr1 <= rr2) : (rr1 += 1) {
        var c = cc1;
        while (c <= cc2) : (c += 1) {
            const idx: usize = @intCast((rr1 - 1) * ncols + (c - 1));
            if (op == 1) {
                mat.data[idx] *= val;
            } else {
                mat.data[idx] += val;
            }
        }
    }
}

pub fn stz_matrix_add_matrix(a: ?*StzMatrix, b: ?*const StzMatrix) callconv(.c) i32 {
    const ma = a orelse return -1;
    const mb = b orelse return -1;
    if (ma.rows != mb.rows or ma.cols != mb.cols) return -2;
    for (ma.data, mb.data) |*va, vb| va.* += vb;
    return 0;
}

pub fn stz_matrix_multiply(a: ?*const StzMatrix, b: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    const ma = a orelse return null;
    const mb = b orelse return null;
    if (ma.cols != mb.rows) return null;
    const result = StzMatrix.init(gpa, ma.rows, mb.cols) catch return null;
    for (0..ma.rows) |i| {
        for (0..mb.cols) |j| {
            var sum: f64 = 0.0;
            for (0..ma.cols) |k| {
                sum += ma.at(i, k) * mb.at(k, j);
            }
            result.setAt(i, j, sum);
        }
    }
    return result;
}

pub fn stz_matrix_transpose(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    const mat = m orelse return null;
    const result = StzMatrix.init(gpa, mat.cols, mat.rows) catch return null;
    for (0..mat.rows) |i| {
        for (0..mat.cols) |j| {
            result.setAt(j, i, mat.at(i, j));
        }
    }
    return result;
}

pub fn stz_matrix_determinant(m: ?*const StzMatrix) callconv(.c) f64 {
    const mat = m orelse return 0.0;
    if (mat.rows != mat.cols) return 0.0;
    return det(mat.data, mat.rows) catch 0.0;
}

fn det(data: []const f64, n: usize) !f64 {
    if (n == 1) return data[0];
    if (n == 2) return data[0] * data[3] - data[1] * data[2];

    const sub = try gpa.alloc(f64, (n - 1) * (n - 1));
    defer gpa.free(sub);

    var result: f64 = 0.0;
    var sign: f64 = 1.0;

    for (0..n) |j| {
        var si: usize = 0;
        for (1..n) |row| {
            for (0..n) |col| {
                if (col == j) continue;
                sub[si] = data[row * n + col];
                si += 1;
            }
        }
        result += sign * data[j] * try det(sub, n - 1);
        sign = -sign;
    }
    return result;
}

pub fn stz_matrix_inverse(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    const mat = m orelse return null;
    if (mat.rows != mat.cols) return null;
    const n = mat.rows;

    const aug = gpa.alloc(f64, n * 2 * n) catch return null;
    defer gpa.free(aug);

    const w = 2 * n;
    for (0..n) |i| {
        for (0..n) |j| {
            aug[i * w + j] = mat.at(i, j);
            aug[i * w + n + j] = if (i == j) 1.0 else 0.0;
        }
    }

    for (0..n) |i| {
        var pivot_row = i;
        var pivot_val = @abs(aug[i * w + i]);
        for (i + 1..n) |r| {
            const v = @abs(aug[r * w + i]);
            if (v > pivot_val) {
                pivot_val = v;
                pivot_row = r;
            }
        }
        if (pivot_val < 1e-15) return null;

        if (pivot_row != i) {
            for (0..w) |c| {
                const tmp = aug[i * w + c];
                aug[i * w + c] = aug[pivot_row * w + c];
                aug[pivot_row * w + c] = tmp;
            }
        }

        const div = aug[i * w + i];
        for (0..w) |c| aug[i * w + c] /= div;

        for (0..n) |r| {
            if (r == i) continue;
            const factor = aug[r * w + i];
            for (0..w) |c| aug[r * w + c] -= factor * aug[i * w + c];
        }
    }

    const result = StzMatrix.init(gpa, n, n) catch return null;
    for (0..n) |i| {
        for (0..n) |j| {
            result.setAt(i, j, aug[i * w + n + j]);
        }
    }
    return result;
}

pub fn stz_matrix_power(m: ?*StzMatrix, p: f64) callconv(.c) void {
    const mat = m orelse return;
    for (mat.data) |*v| v.* = std.math.pow(f64, v.*, p);
}

pub fn stz_matrix_find(m: ?*const StzMatrix, val: f64) callconv(.c) i64 {
    const mat = m orelse return -1;
    for (0..mat.rows) |i| {
        for (0..mat.cols) |j| {
            if (mat.at(i, j) == val) {
                return @as(i64, @intCast(i)) * @as(i64, @intCast(mat.cols)) + @as(i64, @intCast(j));
            }
        }
    }
    return -1;
}

pub fn stz_matrix_find_row(m: ?*const StzMatrix) callconv(.c) i32 {
    const r = stz_matrix_find(m, 0);
    if (r < 0) return -1;
    const mat = m orelse return -1;
    return @intCast(@as(usize, @intCast(r)) / mat.cols);
}

pub fn stz_matrix_find_col(m: ?*const StzMatrix) callconv(.c) i32 {
    const r = stz_matrix_find(m, 0);
    if (r < 0) return -1;
    const mat = m orelse return -1;
    return @intCast(@as(usize, @intCast(r)) % mat.cols);
}

test "matrix new/free" {
    const m = stz_matrix_new(3, 4);
    try std.testing.expect(m != null);
    try std.testing.expectEqual(@as(i32, 3), stz_matrix_rows(m));
    try std.testing.expectEqual(@as(i32, 4), stz_matrix_cols(m));
    stz_matrix_free(m);

    try std.testing.expect(stz_matrix_new(0, 5) == null);
    try std.testing.expect(stz_matrix_new(-1, 3) == null);
}

test "matrix set/get" {
    const m = stz_matrix_new(2, 3).?;
    defer stz_matrix_free(m);

    stz_matrix_set(m, 0, 0, 1.0);
    stz_matrix_set(m, 0, 1, 2.0);
    stz_matrix_set(m, 0, 2, 3.0);
    stz_matrix_set(m, 1, 0, 4.0);
    stz_matrix_set(m, 1, 1, 5.0);
    stz_matrix_set(m, 1, 2, 6.0);

    try std.testing.expectEqual(@as(f64, 1.0), stz_matrix_get(m, 0, 0));
    try std.testing.expectEqual(@as(f64, 6.0), stz_matrix_get(m, 1, 2));
    try std.testing.expectEqual(@as(f64, 0.0), stz_matrix_get(m, 5, 5));
}

test "matrix aggregates" {
    const m = stz_matrix_new(2, 2).?;
    defer stz_matrix_free(m);

    stz_matrix_set(m, 0, 0, 1.0);
    stz_matrix_set(m, 0, 1, 2.0);
    stz_matrix_set(m, 1, 0, 3.0);
    stz_matrix_set(m, 1, 1, 4.0);

    try std.testing.expectEqual(@as(f64, 10.0), stz_matrix_sum(m));
    try std.testing.expectEqual(@as(f64, 1.0), stz_matrix_min(m));
    try std.testing.expectEqual(@as(f64, 4.0), stz_matrix_max(m));
    try std.testing.expectEqual(@as(f64, 2.5), stz_matrix_mean(m));
}

test "matrix scalar ops" {
    const m = stz_matrix_new(2, 2).?;
    defer stz_matrix_free(m);

    stz_matrix_set(m, 0, 0, 1.0);
    stz_matrix_set(m, 0, 1, 2.0);
    stz_matrix_set(m, 1, 0, 3.0);
    stz_matrix_set(m, 1, 1, 4.0);

    stz_matrix_add_scalar(m, 10.0);
    try std.testing.expectEqual(@as(f64, 11.0), stz_matrix_get(m, 0, 0));
    try std.testing.expectEqual(@as(f64, 14.0), stz_matrix_get(m, 1, 1));

    stz_matrix_multiply_scalar(m, 2.0);
    try std.testing.expectEqual(@as(f64, 22.0), stz_matrix_get(m, 0, 0));
}

test "matrix multiply" {
    // [1 2]   [5 6]   [1*5+2*7  1*6+2*8]   [19 22]
    // [3 4] * [7 8] = [3*5+4*7  3*6+4*8] = [43 50]
    const a = stz_matrix_new(2, 2).?;
    defer stz_matrix_free(a);
    stz_matrix_set(a, 0, 0, 1); stz_matrix_set(a, 0, 1, 2);
    stz_matrix_set(a, 1, 0, 3); stz_matrix_set(a, 1, 1, 4);

    const b = stz_matrix_new(2, 2).?;
    defer stz_matrix_free(b);
    stz_matrix_set(b, 0, 0, 5); stz_matrix_set(b, 0, 1, 6);
    stz_matrix_set(b, 1, 0, 7); stz_matrix_set(b, 1, 1, 8);

    const c = stz_matrix_multiply(a, b).?;
    defer stz_matrix_free(c);

    try std.testing.expectEqual(@as(f64, 19.0), stz_matrix_get(c, 0, 0));
    try std.testing.expectEqual(@as(f64, 22.0), stz_matrix_get(c, 0, 1));
    try std.testing.expectEqual(@as(f64, 43.0), stz_matrix_get(c, 1, 0));
    try std.testing.expectEqual(@as(f64, 50.0), stz_matrix_get(c, 1, 1));
}

test "matrix transpose" {
    const m = stz_matrix_new(2, 3).?;
    defer stz_matrix_free(m);
    stz_matrix_set(m, 0, 0, 1); stz_matrix_set(m, 0, 1, 2); stz_matrix_set(m, 0, 2, 3);
    stz_matrix_set(m, 1, 0, 4); stz_matrix_set(m, 1, 1, 5); stz_matrix_set(m, 1, 2, 6);

    const t = stz_matrix_transpose(m).?;
    defer stz_matrix_free(t);

    try std.testing.expectEqual(@as(i32, 3), stz_matrix_rows(t));
    try std.testing.expectEqual(@as(i32, 2), stz_matrix_cols(t));
    try std.testing.expectEqual(@as(f64, 1.0), stz_matrix_get(t, 0, 0));
    try std.testing.expectEqual(@as(f64, 4.0), stz_matrix_get(t, 0, 1));
    try std.testing.expectEqual(@as(f64, 3.0), stz_matrix_get(t, 2, 0));
    try std.testing.expectEqual(@as(f64, 6.0), stz_matrix_get(t, 2, 1));
}

test "matrix determinant" {
    // det([1 2; 3 4]) = 1*4 - 2*3 = -2
    const m2 = stz_matrix_new(2, 2).?;
    defer stz_matrix_free(m2);
    stz_matrix_set(m2, 0, 0, 1); stz_matrix_set(m2, 0, 1, 2);
    stz_matrix_set(m2, 1, 0, 3); stz_matrix_set(m2, 1, 1, 4);
    try std.testing.expectEqual(@as(f64, -2.0), stz_matrix_determinant(m2));

    // det([6 1 1; 4 -2 5; 2 8 7]) = 6(-14-40) - 1(28-10) + 1(32+4) = -306
    const m3 = stz_matrix_new(3, 3).?;
    defer stz_matrix_free(m3);
    stz_matrix_set(m3, 0, 0, 6); stz_matrix_set(m3, 0, 1, 1); stz_matrix_set(m3, 0, 2, 1);
    stz_matrix_set(m3, 1, 0, 4); stz_matrix_set(m3, 1, 1, -2); stz_matrix_set(m3, 1, 2, 5);
    stz_matrix_set(m3, 2, 0, 2); stz_matrix_set(m3, 2, 1, 8); stz_matrix_set(m3, 2, 2, 7);

    const d = stz_matrix_determinant(m3);
    try std.testing.expectApproxEqAbs(@as(f64, -306.0), d, 1e-10);
}

test "matrix inverse" {
    // inv([4 7; 2 6]) = [6 -7; -2 4] / det = [6 -7; -2 4] / 10
    const m = stz_matrix_new(2, 2).?;
    defer stz_matrix_free(m);
    stz_matrix_set(m, 0, 0, 4); stz_matrix_set(m, 0, 1, 7);
    stz_matrix_set(m, 1, 0, 2); stz_matrix_set(m, 1, 1, 6);

    const inv = stz_matrix_inverse(m).?;
    defer stz_matrix_free(inv);

    try std.testing.expectApproxEqAbs(@as(f64, 0.6), stz_matrix_get(inv, 0, 0), 1e-10);
    try std.testing.expectApproxEqAbs(@as(f64, -0.7), stz_matrix_get(inv, 0, 1), 1e-10);
    try std.testing.expectApproxEqAbs(@as(f64, -0.2), stz_matrix_get(inv, 1, 0), 1e-10);
    try std.testing.expectApproxEqAbs(@as(f64, 0.4), stz_matrix_get(inv, 1, 1), 1e-10);

    // Singular matrix should return null
    const s = stz_matrix_new(2, 2).?;
    defer stz_matrix_free(s);
    stz_matrix_set(s, 0, 0, 1); stz_matrix_set(s, 0, 1, 2);
    stz_matrix_set(s, 1, 0, 2); stz_matrix_set(s, 1, 1, 4);
    try std.testing.expect(stz_matrix_inverse(s) == null);
}

test "matrix add_matrix" {
    const a = stz_matrix_new(2, 2).?;
    defer stz_matrix_free(a);
    stz_matrix_set(a, 0, 0, 1); stz_matrix_set(a, 0, 1, 2);
    stz_matrix_set(a, 1, 0, 3); stz_matrix_set(a, 1, 1, 4);

    const b = stz_matrix_new(2, 2).?;
    defer stz_matrix_free(b);
    stz_matrix_set(b, 0, 0, 10); stz_matrix_set(b, 0, 1, 20);
    stz_matrix_set(b, 1, 0, 30); stz_matrix_set(b, 1, 1, 40);

    try std.testing.expectEqual(@as(i32, 0), stz_matrix_add_matrix(a, b));
    try std.testing.expectEqual(@as(f64, 11.0), stz_matrix_get(a, 0, 0));
    try std.testing.expectEqual(@as(f64, 44.0), stz_matrix_get(a, 1, 1));
}

test "matrix power" {
    const m = stz_matrix_new(2, 2).?;
    defer stz_matrix_free(m);
    stz_matrix_set(m, 0, 0, 2); stz_matrix_set(m, 0, 1, 3);
    stz_matrix_set(m, 1, 0, 4); stz_matrix_set(m, 1, 1, 5);

    stz_matrix_power(m, 2.0);
    try std.testing.expectEqual(@as(f64, 4.0), stz_matrix_get(m, 0, 0));
    try std.testing.expectEqual(@as(f64, 9.0), stz_matrix_get(m, 0, 1));
    try std.testing.expectEqual(@as(f64, 16.0), stz_matrix_get(m, 1, 0));
    try std.testing.expectEqual(@as(f64, 25.0), stz_matrix_get(m, 1, 1));
}

test "matrix null safety" {
    stz_matrix_free(null);
    try std.testing.expectEqual(@as(i32, 0), stz_matrix_rows(null));
    try std.testing.expectEqual(@as(i32, 0), stz_matrix_cols(null));
    try std.testing.expectEqual(@as(f64, 0.0), stz_matrix_sum(null));
    try std.testing.expectEqual(@as(f64, 0.0), stz_matrix_get(null, 0, 0));
    stz_matrix_set(null, 0, 0, 1.0);
    try std.testing.expect(stz_matrix_multiply(null, null) == null);
    try std.testing.expect(stz_matrix_transpose(null) == null);
    try std.testing.expect(stz_matrix_inverse(null) == null);
}
