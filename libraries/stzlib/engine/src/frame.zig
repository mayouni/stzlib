//! TABULAR STATISTICS -- a table's columns, described.
//!
//! ── WHY THIS EXISTS SEPARATELY FROM stats.zig ──
//!
//! stats.zig answers questions about ONE sample: its mean, its quartiles, its
//! correlation with another sample. That is the right shape for a sample and the wrong
//! shape for a TABLE, where the questions are "describe every numeric column" and "how
//! does each column relate to each other one".
//!
//! Left to the host, those become loops: build a sample per column, call eight
//! accessors, assemble a row; then a double loop for the pairwise matrix, remembering
//! that the diagonal is 1 and the matrix is symmetric. Ring wrote exactly that, and it
//! wrote it by delegating to ANOTHER RING CLASS -- so a Python or C face over this
//! engine got a table type with no statistics at all.
//!
//! So the operations here are whole: hand over a column and get a description; hand
//! over a matrix and get its correlation matrix. Nothing is left to assemble.
//!
//! ── ONE DEFINITION OF EVERY STATISTIC ──
//!
//! Nothing is recomputed here. Each column becomes an `StzStats` and the answers come
//! from stats.zig's own functions, so a table's mean is the same mean a sample reports,
//! down to the compensated summation. A second implementation that merely agreed to
//! fifteen digits would be a second implementation.

const std = @import("std");
const stats = @import("stats.zig");

pub const FrameError = error{ OutOfMemory, BadShape };

/// The eight numbers a describe() ought to give, in this fixed order.
pub const DESCRIBE_LEN: usize = 8;
pub const Describe = enum(usize) {
    count = 0,
    mean = 1,
    median = 2,
    stddev = 3,
    min = 4,
    max = 5,
    q1 = 6,
    q3 = 7,
};

/// Describe one column. `out` must hold DESCRIBE_LEN.
pub fn describeColumn(values: []const f64, out: []f64) !void {
    if (out.len < DESCRIBE_LEN) return FrameError.BadShape;
    if (values.len == 0) {
        @memset(out[0..DESCRIBE_LEN], 0);
        return;
    }
    const s = stats.StzStats.init(values) catch return FrameError.OutOfMemory;
    defer s.deinit();

    out[@intFromEnum(Describe.count)] = @floatFromInt(stats.stz_stats_count(s));
    out[@intFromEnum(Describe.mean)] = stats.stz_stats_mean(s);
    out[@intFromEnum(Describe.median)] = stats.stz_stats_median(s);
    out[@intFromEnum(Describe.stddev)] = stats.stz_stats_std_dev(s);
    out[@intFromEnum(Describe.min)] = stats.stz_stats_min(s);
    out[@intFromEnum(Describe.max)] = stats.stz_stats_max(s);
    out[@intFromEnum(Describe.q1)] = stats.stz_stats_q1(s);
    out[@intFromEnum(Describe.q3)] = stats.stz_stats_q3(s);
}

/// Describe every column of a row-major nrows x ncols matrix.
///
/// `out` must hold ncols * DESCRIBE_LEN, one description per column in order.
pub fn describeAll(
    alloc: std.mem.Allocator,
    data: []const f64,
    nrows: usize,
    ncols: usize,
    out: []f64,
) !void {
    if (nrows == 0 or ncols == 0 or data.len < nrows * ncols) return FrameError.BadShape;
    if (out.len < ncols * DESCRIBE_LEN) return FrameError.BadShape;

    const col = try alloc.alloc(f64, nrows);
    defer alloc.free(col);
    for (0..ncols) |c| {
        for (0..nrows) |r| col[r] = data[r * ncols + c];
        try describeColumn(col, out[c * DESCRIBE_LEN ..][0..DESCRIBE_LEN]);
    }
}

/// THE PAIRWISE CORRELATION MATRIX over the columns, row-major ncols x ncols.
///
/// The diagonal is exactly 1 and the matrix is exactly symmetric -- both by
/// construction rather than by arithmetic that ought to come out that way. A host
/// computing all n^2 cells independently gets a diagonal of 0.9999999999999998 and a
/// matrix that is symmetric only to rounding, and then someone tests it for symmetry.
pub fn correlationMatrix(
    alloc: std.mem.Allocator,
    data: []const f64,
    nrows: usize,
    ncols: usize,
    out: []f64,
) !void {
    if (nrows == 0 or ncols == 0 or data.len < nrows * ncols) return FrameError.BadShape;
    if (out.len < ncols * ncols) return FrameError.BadShape;

    // one sample per column, built once -- not once per pair
    const cols = try alloc.alloc(*stats.StzStats, ncols);
    defer alloc.free(cols);
    var made: usize = 0;
    errdefer {
        var i: usize = 0;
        while (i < made) : (i += 1) cols[i].deinit();
    }
    const buf = try alloc.alloc(f64, nrows);
    defer alloc.free(buf);
    while (made < ncols) : (made += 1) {
        for (0..nrows) |r| buf[r] = data[r * ncols + made];
        cols[made] = stats.StzStats.init(buf) catch return FrameError.OutOfMemory;
    }
    defer {
        var i: usize = 0;
        while (i < ncols) : (i += 1) cols[i].deinit();
    }

    for (0..ncols) |i| {
        out[i * ncols + i] = 1;
        for (i + 1..ncols) |j| {
            const r = stats.stz_stats_correlation(cols[i], cols[j]);
            out[i * ncols + j] = r;
            out[j * ncols + i] = r; // symmetric BY CONSTRUCTION
        }
    }
}

/// Least-squares regression of y ON x: slope, intercept, r-squared.
///
/// `out` must hold 3. Returns false when the fit is undefined (fewer than two points,
/// or an x with no spread -- a vertical line has no slope, and reporting one would be
/// a plausible wrong answer).
pub fn regression(x: []const f64, y: []const f64, out: []f64) !bool {
    if (out.len < 3) return FrameError.BadShape;
    const n = @min(x.len, y.len);
    if (n < 2) return false;

    const sx = stats.StzStats.init(x[0..n]) catch return FrameError.OutOfMemory;
    defer sx.deinit();
    const sy = stats.StzStats.init(y[0..n]) catch return FrameError.OutOfMemory;
    defer sy.deinit();

    var slope: f64 = 0;
    var intercept: f64 = 0;
    if (stats.stz_stats_regression(sx, sy, &slope, &intercept) == 0) return false;

    // r^2 is the squared correlation, which is why it is not computed a second way
    const r = stats.stz_stats_correlation(sx, sy);
    out[0] = slope;
    out[1] = intercept;
    out[2] = r * r;
    return true;
}

// ── tests ────────────────────────────────────────────────────────────────────

const testing = std.testing;

test "a column description is the eight numbers, in order" {
    const col = [_]f64{ 30, 42, 51, 66, 80 };
    var d = [_]f64{0} ** DESCRIBE_LEN;
    try describeColumn(&col, &d);

    try testing.expectApproxEqAbs(@as(f64, 5), d[@intFromEnum(Describe.count)], 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 53.8), d[@intFromEnum(Describe.mean)], 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 51), d[@intFromEnum(Describe.median)], 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 30), d[@intFromEnum(Describe.min)], 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 80), d[@intFromEnum(Describe.max)], 1e-12);
    // the spread is the SAMPLE deviation, the same one stats.zig reports
    try testing.expectApproxEqAbs(@as(f64, 19.677398), d[@intFromEnum(Describe.stddev)], 1e-6);

    // an empty column describes as zeros rather than erroring: a table may hold one
    var e = [_]f64{9} ** DESCRIBE_LEN;
    try describeColumn(&[_]f64{}, &e);
    for (e) |v| try testing.expectApproxEqAbs(@as(f64, 0), v, 1e-15);
}

test "describeAll walks a row-major matrix column by column" {
    const alloc = testing.allocator;
    // two columns: age and income, three rows
    const m = [_]f64{ 20, 30, 25, 42, 30, 51 };
    var out = [_]f64{0} ** (2 * DESCRIBE_LEN);
    try describeAll(alloc, &m, 3, 2, &out);

    // column 0 is 20, 25, 30
    try testing.expectApproxEqAbs(@as(f64, 25), out[@intFromEnum(Describe.mean)], 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 20), out[@intFromEnum(Describe.min)], 1e-12);
    // column 1 is 30, 42, 51
    try testing.expectApproxEqAbs(@as(f64, 41), out[DESCRIBE_LEN + @intFromEnum(Describe.mean)], 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 51), out[DESCRIBE_LEN + @intFromEnum(Describe.max)], 1e-12);
}

test "the correlation matrix is 1 on the diagonal and symmetric BY CONSTRUCTION" {
    const alloc = testing.allocator;
    // age and income move together; a third column moves against them
    const m = [_]f64{
        20, 30, 9,
        25, 42, 7,
        30, 51, 5,
        35, 66, 3,
        40, 80, 1,
    };
    var out = [_]f64{0} ** 9;
    try correlationMatrix(alloc, &m, 5, 3, &out);

    // EXACTLY one, not 0.9999999999999998 -- the diagonal is written, not computed
    try testing.expectEqual(@as(f64, 1), out[0]);
    try testing.expectEqual(@as(f64, 1), out[4]);
    try testing.expectEqual(@as(f64, 1), out[8]);
    // EXACTLY symmetric, for the same reason
    try testing.expectEqual(out[1], out[3]);
    try testing.expectEqual(out[2], out[6]);
    try testing.expectEqual(out[5], out[7]);

    try testing.expect(out[1] > 0.99); // age vs income, strongly positive
    try testing.expect(out[2] < -0.99); // age vs the falling column
}

test "regression reports slope, intercept and r-squared, and refuses a vertical line" {
    const x = [_]f64{ 20, 25, 30, 35, 40 };
    const y = [_]f64{ 30, 42, 51, 66, 80 };
    var out = [_]f64{0} ** 3;
    try testing.expect(try regression(&x, &y, &out));
    try testing.expectApproxEqAbs(@as(f64, 2.48), out[0], 1e-9);
    try testing.expectApproxEqAbs(@as(f64, -20.6), out[1], 1e-9);
    try testing.expectApproxEqAbs(@as(f64, 0.992769), out[2], 1e-6);

    // r^2 IS the squared correlation, not a second derivation of the same idea
    const alloc = testing.allocator;
    var cm = [_]f64{0} ** 4;
    const both = [_]f64{ 20, 30, 25, 42, 30, 51, 35, 66, 40, 80 };
    try correlationMatrix(alloc, &both, 5, 2, &cm);
    try testing.expectApproxEqAbs(cm[1] * cm[1], out[2], 1e-12);

    // an x with no spread has no slope, and the answer is "no fit" rather than a number
    const flat = [_]f64{ 7, 7, 7, 7 };
    const anyy = [_]f64{ 1, 2, 3, 4 };
    try testing.expect(!try regression(&flat, &anyy, &out));
    // and a single point is not a line either
    try testing.expect(!try regression(x[0..1], y[0..1], &out));
}
