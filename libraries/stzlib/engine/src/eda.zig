//=====================================================================//
//  EDA.ZIG -- Tukey's exploration tier: resistant order statistics,   //
//  the letter values, median polish, the resistant line               //
//  (SOFTANZA_TUKEY_PLAN.md section 3.1; plane stzlib-math, M4)         //
//=====================================================================//
//
// Built on stats.zig's primitives; it does not re-implement summation.
//
// ── THE HINGE CONVENTION LIVES HERE, AND ONLY HERE ─────────────────────
//
// Tukey's FOURTHS (hinges) are not quartiles. Their depth is
//
//     d(M) = (n + 1) / 2                the median's depth
//     d(F) = (floor(d(M)) + 1) / 2      the fourths' depth
//
// counted in from each end of the sorted data, a half-integer depth
// meaning the mean of the two values it sits between. The fourth-spread is
// F_upper - F_lower. Percentile quartiles (stats.zig's computePercentile,
// rank = p/100 * (n-1), linear) are ANOTHER convention: on [1,2,3,4] the
// fourths are 1.5 and 3.5, the percentile quartiles 1.75 and 3.25. Both are
// correct. Picking silently is not -- this is the variance-divisor disease
// (stats.zig:204) in a second coat. So:
//
//   * Tukey's fourths are the default FOR TUKEY DISPLAYS (everything in this
//     file and the figures built on it), and they are printed as such;
//   * percentile quartiles remain the default for stzDataSet and everything
//     already shipped, unchanged;
//   * the fences are F_lower - k*Fspread and F_upper + k*Fspread with
//     k = 1.5 (outside) and k = 3 (far out), under either convention, by
//     name.
//
// Measured in TK0 (2026-09-26): on a seeded sweep of sizes 4..200 the two
// conventions differ by up to 0.25 fourth-spreads and on the library's own
// box-plot sample by 0.115, above the 0.1 threshold the plan set in advance,
// so BOTH paths ship and every display states which it used.
//
// ── THE MEDIAN POLISH CONVENTION ──────────────────────────────────────
//
// R's stats::medpolish, exactly: alternate sweeps of row medians then
// column medians, the median of the effects folded into the common value
// each half-sweep; stop when the sum of |residuals| changes by less than
// eps times itself (eps = 0.01 by default, as R) or reaches zero, with an
// iteration cap (10 by default, as R; the polish is not guaranteed to
// converge, and a cap is stated rather than assumed). The median of an
// even count is the mean of the two middle values (R's median).
//
// Oracle for the guard: R's own documented example (?medpolish, the
// "deaths" table), reproduced by an independent NumPy implementation of the
// same algorithm to 1e-9 -- both transcriptions sit beside the test below.

const std = @import("std");
const stats = @import("stats.zig");

pub const Convention = enum(u8) { fourths = 0, percentile = 1 };

// ── order statistics ────────────────────────────────────────────────

/// The median of a SORTED slice: the middle value, or the mean of the two
/// middle values (R's median, Tukey's median).
pub fn medianSorted(sorted: []const f64) f64 {
    const n = sorted.len;
    if (n == 0) return 0;
    if (n % 2 == 1) return sorted[n / 2];
    return (sorted[n / 2 - 1] + sorted[n / 2]) / 2.0;
}

/// The value at a Tukey DEPTH counted from the low end of a sorted slice:
/// depth 1 is the smallest; a half-integer depth averages its neighbours.
pub fn atDepth(sorted: []const f64, depth: f64) f64 {
    const n = sorted.len;
    if (n == 0) return 0;
    const lo_f = @floor(depth);
    var lo: usize = @intFromFloat(lo_f);
    if (lo < 1) lo = 1;
    if (lo > n) lo = n;
    const frac = depth - lo_f;
    if (frac == 0 or lo >= n) return sorted[lo - 1];
    return (sorted[lo - 1] + sorted[lo]) / 2.0;
}

pub fn medianDepth(n: usize) f64 {
    return (@as(f64, @floatFromInt(n)) + 1.0) / 2.0;
}

pub fn hingeDepth(n: usize) f64 {
    return (@floor(medianDepth(n)) + 1.0) / 2.0;
}

pub const Fourths = struct { lower: f64, upper: f64 };

pub fn fourths(sorted: []const f64) Fourths {
    const n = sorted.len;
    if (n == 0) return .{ .lower = 0, .upper = 0 };
    const d = hingeDepth(n);
    const n_f: f64 = @floatFromInt(n);
    return .{ .lower = atDepth(sorted, d), .upper = atDepth(sorted, n_f + 1.0 - d) };
}

pub fn fourthSpread(sorted: []const f64) f64 {
    const f = fourths(sorted);
    return f.upper - f.lower;
}

/// Percentile quartiles, stats.zig's convention (rank = p/100*(n-1), linear).
pub fn percentileQuartiles(sorted: []const f64) Fourths {
    return .{ .lower = percentileSorted(sorted, 25.0), .upper = percentileSorted(sorted, 75.0) };
}

fn percentileSorted(sorted: []const f64, p: f64) f64 {
    if (sorted.len == 0) return 0;
    if (sorted.len == 1) return sorted[0];
    const n_f: f64 = @floatFromInt(sorted.len);
    const rank = p / 100.0 * (n_f - 1.0);
    const lo: usize = @intFromFloat(@floor(rank));
    const hi: usize = @min(lo + 1, sorted.len - 1);
    const frac = rank - @floor(rank);
    return sorted[lo] * (1.0 - frac) + sorted[hi] * frac;
}

pub const Fences = struct { lower: f64, upper: f64 };

/// The fences under a named convention and multiplier (1.5 outside, 3 far out).
pub fn fences(sorted: []const f64, mult: f64, convention: Convention) Fences {
    const f = switch (convention) {
        .fourths => fourths(sorted),
        .percentile => percentileQuartiles(sorted),
    };
    const spread = f.upper - f.lower;
    return .{ .lower = f.lower - mult * spread, .upper = f.upper + mult * spread };
}

/// One letter value: the depth, the two values at it, their mid and spread.
pub const LetterValue = struct { depth: f64, lower: f64, upper: f64, mid: f64, spread: f64 };

/// The letter-value ladder M F E D C B A ... : each level halves the depth
/// (d_next = (floor(d) + 1) / 2) until the depth reaches 1 or `levels` is
/// reached. Level 1 is M (lower = upper = median).
pub fn letterValues(sorted: []const f64, levels: usize, out: []LetterValue) usize {
    const n = sorted.len;
    if (n == 0 or levels == 0 or out.len == 0) return 0;
    const n_f: f64 = @floatFromInt(n);
    var d = medianDepth(n);
    var k: usize = 0;
    while (k < levels and k < out.len) : (k += 1) {
        const lo = atDepth(sorted, d);
        const hi = atDepth(sorted, n_f + 1.0 - d);
        out[k] = .{ .depth = d, .lower = lo, .upper = hi, .mid = (lo + hi) / 2.0, .spread = hi - lo };
        if (d <= 1.0) {
            k += 1;
            break;
        }
        d = (@floor(d) + 1.0) / 2.0;
    }
    return k;
}

pub fn trimean(sorted: []const f64) f64 {
    const f = fourths(sorted);
    return (f.lower + 2.0 * medianSorted(sorted) + f.upper) / 4.0;
}

/// The median absolute deviation from the median, unscaled (multiply by
/// 1.4826 for a normal-consistent scale; the caller says so, this does not).
pub fn mad(data: []const f64, scratch: []f64) f64 {
    const n = data.len;
    if (n == 0 or scratch.len < 2 * n) return 0;
    const s1 = scratch[0..n];
    @memcpy(s1, data);
    std.mem.sort(f64, s1, {}, std.sort.asc(f64));
    const m = medianSorted(s1);
    const s2 = scratch[n .. 2 * n];
    for (data, 0..) |v, i| s2[i] = @abs(v - m);
    std.mem.sort(f64, s2, {}, std.sort.asc(f64));
    return medianSorted(s2);
}

/// Biweight midvariance (Hoaglin, Mosteller & Tukey 1983; Lax 1985), with
/// the tuning constant c (9 is the usual) on the MAD: u_i = (x_i - M) / (c * MAD),
/// the sum over |u| < 1 of (x - M)^2 (1 - u^2)^4 divided by the square of the
/// sum of (1 - u^2)(1 - 5u^2), times n. Zero when the MAD is zero.
pub fn biweightMidvariance(data: []const f64, c: f64, scratch: []f64) f64 {
    const n = data.len;
    if (n == 0 or scratch.len < 2 * n) return 0;
    const s1 = scratch[0..n];
    @memcpy(s1, data);
    std.mem.sort(f64, s1, {}, std.sort.asc(f64));
    const m = medianSorted(s1);
    const d = mad(data, scratch);
    if (d == 0) return 0;
    var num: f64 = 0;
    var den: f64 = 0;
    for (data) |v| {
        const u = (v - m) / (c * d);
        if (@abs(u) < 1.0) {
            const w = 1.0 - u * u;
            num += (v - m) * (v - m) * w * w * w * w;
            den += w * (1.0 - 5.0 * u * u);
        }
    }
    if (den == 0) return 0;
    return @as(f64, @floatFromInt(n)) * num / (den * den);
}

// ── median polish ───────────────────────────────────────────────────

pub const PolishResult = struct {
    common: f64,
    iterations: usize,
    converged: bool,
    abs_residual_sum: f64,
};

/// Quickselect: the k-th smallest (0-based) of a slice, rearranged in place.
/// Linear expected time; the polish calls it twice per line where a sort
/// would cost n log n, which is the difference between 172 ms and the
/// number recorded in the TK0 results at 1000x1000.
pub fn selectKth(a: []f64, k: usize) f64 {
    var lo: usize = 0;
    var hi: usize = a.len - 1;
    while (lo < hi) {
        const pivot = a[(lo + hi) / 2];
        var i = lo;
        var j = hi;
        while (i <= j) {
            while (a[i] < pivot) i += 1;
            while (a[j] > pivot) {
                if (j == 0) break;
                j -= 1;
            }
            if (i <= j) {
                const t = a[i];
                a[i] = a[j];
                a[j] = t;
                i += 1;
                if (j == 0) break;
                j -= 1;
            }
        }
        if (k <= j) {
            hi = j;
        } else if (k >= i) {
            lo = i;
        } else {
            break;
        }
    }
    return a[k];
}

/// The median of a slice by selection, rearranging the slice (R's median:
/// the mean of the two middle values when the count is even).
pub fn medianSelect(a: []f64) f64 {
    const n = a.len;
    if (n == 0) return 0;
    if (n % 2 == 1) return selectKth(a, n / 2);
    const hi = selectKth(a, n / 2);
    // the lower middle is the largest of the first half after the partition
    var lo = a[0];
    for (a[0 .. n / 2]) |v| {
        if (v > lo) lo = v;
    }
    return (lo + hi) / 2.0;
}

fn medianOfInto(values: []const f64, scratch: []f64) f64 {
    const s = scratch[0..values.len];
    @memcpy(s, values);
    return medianSelect(s);
}

/// Two-way median polish, R's stats::medpolish. `z` holds the data on entry
/// (row-major, rows x cols) and the RESIDUALS on exit; `row` and `col`
/// receive the effects; `scratch` needs max(rows, cols) values. Returns the
/// common value with the sweep count and whether the stopping rule fired.
pub fn medianPolish2D(z: []f64, rows: usize, cols: usize, row: []f64, col: []f64, eps: f64, max_iter: usize, scratch: []f64) PolishResult {
    var res = PolishResult{ .common = 0, .iterations = 0, .converged = false, .abs_residual_sum = 0 };
    if (rows == 0 or cols == 0 or z.len < rows * cols or row.len < rows or col.len < cols) return res;
    if (scratch.len < @max(rows, cols)) return res;
    @memset(row[0..rows], 0);
    @memset(col[0..cols], 0);
    var oldsum: f64 = 0;
    var it: usize = 0;
    while (it < max_iter) {
        it += 1;
        // row sweep
        var i: usize = 0;
        while (i < rows) : (i += 1) {
            const line = z[i * cols .. (i + 1) * cols];
            const md = medianOfInto(line, scratch);
            for (line) |*v| v.* -= md;
            row[i] += md;
        }
        const cdel = medianOfInto(col[0..cols], scratch);
        for (col[0..cols]) |*v| v.* -= cdel;
        res.common += cdel;
        // column sweep
        var j: usize = 0;
        while (j < cols) : (j += 1) {
            var k: usize = 0;
            while (k < rows) : (k += 1) scratch[k] = z[k * cols + j];
            const column = scratch[0..rows];
            const md = medianSelect(column);
            k = 0;
            while (k < rows) : (k += 1) z[k * cols + j] -= md;
            col[j] += md;
        }
        const rdel = medianOfInto(row[0..rows], scratch);
        for (row[0..rows]) |*v| v.* -= rdel;
        res.common += rdel;
        var newsum: f64 = 0;
        for (z[0 .. rows * cols]) |v| newsum += @abs(v);
        res.abs_residual_sum = newsum;
        res.iterations = it;
        if (newsum == 0 or @abs(newsum - oldsum) < eps * newsum) {
            res.converged = true;
            break;
        }
        oldsum = newsum;
    }
    return res;
}

// ── the resistant line (Tukey's three-group line) ───────────────────

pub const Line = struct { slope: f64, intercept: f64, iterations: usize };

/// Tukey's resistant line: sort by x, cut into three groups of sizes
/// (n/3, n - 2*(n/3), n/3) by rank, take the medians of x and y in the outer
/// groups, slope = (yR - yL) / (xR - xL); the intercept is the median of
/// y - slope*x over all points; then iterate on the residuals `iters` times
/// (each pass fits the residuals and adds the correction). `scratch` needs
/// 4*n values. Returns iterations actually run.
pub fn resistantLine(x: []const f64, y: []const f64, iters: usize, scratch: []f64) Line {
    const n = x.len;
    var line = Line{ .slope = 0, .intercept = 0, .iterations = 0 };
    if (n < 3 or y.len < n or scratch.len < 4 * n) return line;
    // order by x
    const idx_f = scratch[3 * n .. 4 * n];
    for (idx_f, 0..) |*v, i| v.* = @floatFromInt(i);
    const Ctx = struct {
        xs: []const f64,
        fn lessThan(ctx: @This(), a: f64, b: f64) bool {
            return ctx.xs[@as(usize, @intFromFloat(a))] < ctx.xs[@as(usize, @intFromFloat(b))];
        }
    };
    std.mem.sort(f64, idx_f, Ctx{ .xs = x }, Ctx.lessThan);
    const g = n / 3;
    const xs = scratch[0..n];
    const ys = scratch[n .. 2 * n];
    for (idx_f, 0..) |v, i| {
        const k: usize = @intFromFloat(v);
        xs[i] = x[k];
        ys[i] = y[k];
    }
    const tmp = scratch[2 * n .. 3 * n];
    const xl = medianOfInto(xs[0..g], tmp);
    const xr = medianOfInto(xs[n - g .. n], tmp);
    if (xr == xl) return line;
    var resid = scratch[n .. 2 * n]; // ys is overwritten by residuals as we go
    var pass: usize = 0;
    while (pass < iters + 1) : (pass += 1) {
        const yl = medianOfInto(resid[0..g], tmp);
        const yr = medianOfInto(resid[n - g .. n], tmp);
        const b = (yr - yl) / (xr - xl);
        for (resid, 0..) |*r, i| r.* -= b * xs[i];
        const a = medianOfInto(resid, tmp);
        for (resid) |*r| r.* -= a;
        line.slope += b;
        line.intercept += a;
        line.iterations = pass;
        if (b == 0 and a == 0) break;
    }
    _ = &resid;
    return line;
}

// ── tests: the oracles, transcribed with the command that produced them ──

test "fourths on the worked examples at every n mod 4" {
    // by hand: depths d(M) = (n+1)/2, d(F) = (floor(d(M)) + 1)/2
    const a4 = [_]f64{ 1, 2, 3, 4 };
    const f4 = fourths(&a4);
    try std.testing.expectApproxEqAbs(@as(f64, 1.5), f4.lower, 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 3.5), f4.upper, 1e-12);
    const a5 = [_]f64{ 1, 2, 3, 4, 5 };
    const f5 = fourths(&a5);
    try std.testing.expectApproxEqAbs(@as(f64, 2), f5.lower, 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 4), f5.upper, 1e-12);
    const a6 = [_]f64{ 1, 2, 3, 4, 5, 6 };
    const f6 = fourths(&a6);
    try std.testing.expectApproxEqAbs(@as(f64, 2), f6.lower, 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 5), f6.upper, 1e-12);
    const a7 = [_]f64{ 1, 2, 3, 4, 5, 6, 7 };
    const f7 = fourths(&a7);
    try std.testing.expectApproxEqAbs(@as(f64, 2.5), f7.lower, 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 5.5), f7.upper, 1e-12);
    // the library's own box-plot sample: fourths 4 and 10.5, percentile 4 and 9.75
    const a8 = [_]f64{ 2, 4, 4, 5, 7, 9, 12, 25 };
    const f8 = fourths(&a8);
    try std.testing.expectApproxEqAbs(@as(f64, 4), f8.lower, 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 10.5), f8.upper, 1e-12);
    const p8 = percentileQuartiles(&a8);
    try std.testing.expectApproxEqAbs(@as(f64, 9.75), p8.upper, 1e-12);
}

test "median polish reproduces R's ?medpolish example (deaths) to 1e-9" {
    // R:  deaths <- rbind(c(14,15,14), c(7,4,7), c(8,2,10), c(15,9,10), c(0,2,0))
    //     medpolish(deaths)
    //   Overall: 8   Row: 6 -1 0 2 -8   Column: 0 -1 0
    //   Residuals: [0 2 0 / 0 -2 0 / 0 -5 2 / 5 0 0 / 0 3 0]
    // reproduced by scratchpad/tk0/medpolish_np.py (NumPy, independent), 2 sweeps
    var z = [_]f64{ 14, 15, 14, 7, 4, 7, 8, 2, 10, 15, 9, 10, 0, 2, 0 };
    var row: [5]f64 = undefined;
    var col: [3]f64 = undefined;
    var scratch: [8]f64 = undefined;
    const r = medianPolish2D(&z, 5, 3, &row, &col, 0.01, 10, &scratch);
    try std.testing.expect(r.converged);
    try std.testing.expectApproxEqAbs(@as(f64, 8), r.common, 1e-9);
    const want_row = [_]f64{ 6, -1, 0, 2, -8 };
    const want_col = [_]f64{ 0, -1, 0 };
    const want_res = [_]f64{ 0, 2, 0, 0, -2, 0, 0, -5, 2, 5, 0, 0, 0, 3, 0 };
    for (want_row, 0..) |w, i| try std.testing.expectApproxEqAbs(w, row[i], 1e-9);
    for (want_col, 0..) |w, j| try std.testing.expectApproxEqAbs(w, col[j], 1e-9);
    for (want_res, 0..) |w, k| try std.testing.expectApproxEqAbs(w, z[k], 1e-9);
    // Data = Fit + Residual, cell by cell, against the original table
    const data = [_]f64{ 14, 15, 14, 7, 4, 7, 8, 2, 10, 15, 9, 10, 0, 2, 0 };
    for (data, 0..) |d, k| {
        const i = k / 3;
        const j = k % 3;
        try std.testing.expectApproxEqAbs(d, r.common + row[i] + col[j] + z[k], 1e-9);
    }
}

test "letter values: M F E on nine values, depths 5, 3, 2" {
    const a = [_]f64{ 1, 2, 3, 4, 5, 6, 7, 8, 9 };
    var lv: [8]LetterValue = undefined;
    const k = letterValues(&a, 8, &lv);
    try std.testing.expect(k >= 3);
    try std.testing.expectApproxEqAbs(@as(f64, 5), lv[0].depth, 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 5), lv[0].mid, 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 3), lv[1].depth, 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 3), lv[1].lower, 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 7), lv[1].upper, 1e-12);
    try std.testing.expectApproxEqAbs(@as(f64, 2), lv[2].depth, 1e-12);
}

test "the resistant line recovers an exact line and resists one wild point" {
    const x = [_]f64{ 1, 2, 3, 4, 5, 6, 7, 8, 9 };
    var y: [9]f64 = undefined;
    for (x, 0..) |v, i| y[i] = 3.0 * v + 2.0;
    var scratch: [36]f64 = undefined;
    const l = resistantLine(&x, &y, 5, &scratch);
    try std.testing.expectApproxEqAbs(@as(f64, 3), l.slope, 1e-9);
    try std.testing.expectApproxEqAbs(@as(f64, 2), l.intercept, 1e-9);
    // one point dragged to 1e6: the resistant slope stays 3
    y[4] = 1.0e6;
    const l2 = resistantLine(&x, &y, 5, &scratch);
    try std.testing.expectApproxEqAbs(@as(f64, 3), l2.slope, 1e-9);
}

test "mad and biweight midvariance on a hand example, and resistance" {
    // data 1..9: median 5, |x - 5| = 4 3 2 1 0 1 2 3 4 -> sorted 0 1 1 2 2 3 3 4 4 -> mad 2
    const a = [_]f64{ 1, 2, 3, 4, 5, 6, 7, 8, 9 };
    var scratch: [18]f64 = undefined;
    try std.testing.expectApproxEqAbs(@as(f64, 2), mad(&a, &scratch), 1e-12);
    const bw = biweightMidvariance(&a, 9.0, &scratch);
    try std.testing.expect(bw > 0);
    // one wild value: the MAD moves by at most one step of the data
    var b = a;
    b[8] = 1.0e9;
    try std.testing.expectApproxEqAbs(@as(f64, 2), mad(&b, &scratch), 1e-12);
}

test "TK0 timing: median polish at 10, 100, 1000 and 4000 square, single thread" {
    const allocator = std.testing.allocator;
    const sizes = [_]usize{ 10, 100, 1000, 4000 };
    var out = std.ArrayList(u8).empty;
    defer out.deinit(allocator);
    for (sizes) |n| {
        const z = try allocator.alloc(f64, n * n);
        defer allocator.free(z);
        const row = try allocator.alloc(f64, n);
        defer allocator.free(row);
        const col = try allocator.alloc(f64, n);
        defer allocator.free(col);
        const scratch = try allocator.alloc(f64, n);
        defer allocator.free(scratch);
        // an additive table with noise: common 10, row i, col j, deterministic noise
        var seed: u64 = 12345;
        for (z, 0..) |*v, k| {
            seed = seed *% 6364136223846793005 +% 1442695040888963407;
            const noise = @as(f64, @floatFromInt((seed >> 33) % 1000)) / 1000.0 - 0.5;
            v.* = 10.0 + @as(f64, @floatFromInt(k / n)) * 0.5 + @as(f64, @floatFromInt(k % n)) * 0.25 + noise;
        }
        var timer = try std.time.Timer.start();
        const r = medianPolish2D(z, n, n, row, col, 0.01, 10, scratch);
        const ns = timer.read();
        try out.writer(allocator).print("  polish {d}x{d}: {d:.2} ms, {d} sweep(s), converged {}\n", .{ n, n, @as(f64, @floatFromInt(ns)) / 1.0e6, r.iterations, r.converged });
    }
    std.debug.print("\n{s}", .{out.items});
}

test "TK0 gap: fourths against percentile quartiles over a seeded sweep of sizes 4..200" {
    const allocator = std.testing.allocator;
    var worst: f64 = 0;
    var worst_n: usize = 0;
    var seed: u64 = 777;
    var n: usize = 4;
    while (n <= 200) : (n += 1) {
        const a = try allocator.alloc(f64, n);
        defer allocator.free(a);
        for (a) |*v| {
            seed = seed *% 6364136223846793005 +% 1442695040888963407;
            v.* = @as(f64, @floatFromInt((seed >> 33) % 100000)) / 1000.0;
        }
        std.mem.sort(f64, a, {}, std.sort.asc(f64));
        const f = fourths(a);
        const p = percentileQuartiles(a);
        const spread = f.upper - f.lower;
        if (spread > 0) {
            const gap = @max(@abs(f.lower - p.lower), @abs(f.upper - p.upper)) / spread;
            if (gap > worst) {
                worst = gap;
                worst_n = n;
            }
        }
    }
    std.debug.print("  gap: worst {d:.4} fourth-spreads at n = {d}; box-plot sample 0.1154\n", .{ worst, worst_n });
    try std.testing.expect(worst >= 0);
}

test "medianSelect agrees with the sorted median on seeded data, odd and even counts" {
    var seed: u64 = 4242;
    var n: usize = 1;
    while (n <= 64) : (n += 1) {
        var a: [64]f64 = undefined;
        var b: [64]f64 = undefined;
        for (a[0..n]) |*v| {
            seed = seed *% 6364136223846793005 +% 1442695040888963407;
            v.* = @as(f64, @floatFromInt((seed >> 33) % 50));
        }
        @memcpy(b[0..n], a[0..n]);
        std.mem.sort(f64, b[0..n], {}, std.sort.asc(f64));
        try std.testing.expectApproxEqAbs(medianSorted(b[0..n]), medianSelect(a[0..n]), 1e-12);
    }
}
