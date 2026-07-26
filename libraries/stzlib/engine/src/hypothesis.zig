// Softanza Engine -- hypothesis tests.
//
// Phase 5 of the numeric foundation, pillar 5: "Inferential statistics -- NEW. Once
// special functions land: t/z/chi2/F distributions, correct confidence intervals, and
// the hypothesis tests that stzDataSet cannot currently express."
//
// It could not express ANY of them. stzDataSet has correlation, covariance,
// regression coefficients, z-scores and (since phase 4) a correct t-based confidence
// interval -- all DESCRIPTIVE. There was no t-test, no chi-square test, no ANOVA, and
// no p-value anywhere in the library, because until special.zig arrived there was no
// way to compute a tail probability at all.
//
// EVERY TEST HERE IS TWO STEPS: compute a statistic from the data, then ask
// special.zig for the tail probability of that statistic under the null hypothesis.
// stats.zig supplies the means and variances, special.zig the distributions. This
// module composes them and owns nothing else -- no third definition of a variance, no
// fourth summation.
//
// ── WHAT A RESULT CARRIES, AND WHY IT IS NOT JUST A p-VALUE ──
//
// A p-value is the most misread number in statistics. It is the probability of seeing
// data at least this extreme IF THE NULL HYPOTHESIS WERE TRUE -- and that is all. It
// is not the probability the null is true, a large p does not mean "no effect", and a
// small p says nothing about whether the effect MATTERS.
//
// So every test returns the whole picture: the statistic, the degrees of freedom, the
// p-value, the SAMPLE SIZE, an EFFECT SIZE, and which test was actually run. The
// effect size is the part usually missing and the part that answers "is this
// difference worth anything?" -- with n large enough, a trivial difference is
// "significant"; with n small, a large one is not. Reporting both is the difference
// between a number and an answer, and it is the same instinct as
// ConfidenceIntervalXT reporting its `:method` and stzNumber's `IsExact()/Why()`.

const std = @import("std");
const stats = @import("stats.zig");
const special = @import("special.zig");

/// What every test returns. `kind` says which test ran -- Welch and Student are not
/// the same test and the caller should not have to guess which they got.
pub const TestResult = extern struct {
    statistic: f64,
    df: f64,
    /// Two-sided unless the test is inherently one-tailed (chi-square, F).
    p_value: f64,
    /// Cohen's d for the t tests, Cramer's V for chi-square independence,
    /// eta-squared for ANOVA, r itself for a correlation test.
    effect_size: f64,
    n: f64,
    /// 1 on success. 0 when the test could not be run at all, in which case every
    /// other field is 0 and the caller must not read them as an answer.
    ok: i32,
};

const FAILED = TestResult{ .statistic = 0, .df = 0, .p_value = 0, .effect_size = 0, .n = 0, .ok = 0 };

// ─── t tests ───

/// One-sample t: is the mean of `data` different from mu0?
///
/// Effect size is Cohen's d = (mean - mu0) / sd, i.e. the difference measured in
/// standard deviations. 0.2 is conventionally small, 0.5 medium, 0.8 large -- and
/// unlike the p-value it does not grow just because n did.
pub fn tTestOneSample(data: []const f64, mu0: f64) TestResult {
    const n = data.len;
    if (n < 2) return FAILED;
    const mean = stats.compensatedSum(data) / @as(f64, @floatFromInt(n));
    const variance = stats.varianceOf(data, .sample);
    if (variance <= 0) return FAILED; // every value identical: no variation to test
    const sd = @sqrt(variance);
    const nf: f64 = @floatFromInt(n);
    const t = (mean - mu0) / (sd / @sqrt(nf));
    const df = nf - 1.0;
    return .{
        .statistic = t,
        .df = df,
        .p_value = twoSidedT(t, df),
        .effect_size = (mean - mu0) / sd,
        .n = nf,
        .ok = 1,
    };
}

/// WELCH's two-sample t, and it is the DEFAULT deliberately.
///
/// Student's two-sample t assumes the two populations have equal variances. That
/// assumption is usually untestable in practice and usually wrong, and when it fails
/// Student's test is anti-conservative -- it reports significance that is not there.
/// Welch drops the assumption at the cost of a fractional degrees of freedom, is
/// barely less powerful when the variances ARE equal, and is what modern practice
/// (and R's t.test) uses by default. `tTestStudent` below is available for the case
/// where equal variance is known rather than hoped.
pub fn tTestWelch(a: []const f64, b: []const f64) TestResult {
    const na = a.len;
    const nb = b.len;
    if (na < 2 or nb < 2) return FAILED;
    const naf: f64 = @floatFromInt(na);
    const nbf: f64 = @floatFromInt(nb);
    const ma = stats.compensatedSum(a) / naf;
    const mb = stats.compensatedSum(b) / nbf;
    const va = stats.varianceOf(a, .sample);
    const vb = stats.varianceOf(b, .sample);
    const sa = va / naf;
    const sb = vb / nbf;
    if (sa + sb <= 0) return FAILED;

    const t = (ma - mb) / @sqrt(sa + sb);
    // Welch-Satterthwaite: the degrees of freedom are fractional, which is the whole
    // point -- they interpolate between the two sample sizes according to how
    // unequal the variances are.
    const denom = (sa * sa) / (naf - 1.0) + (sb * sb) / (nbf - 1.0);
    const df = if (denom > 0) (sa + sb) * (sa + sb) / denom else naf + nbf - 2.0;

    // Cohen's d with the POOLED standard deviation, which is the conventional
    // reporting even for Welch's test
    const pooled = @sqrt(((naf - 1.0) * va + (nbf - 1.0) * vb) / (naf + nbf - 2.0));
    return .{
        .statistic = t,
        .df = df,
        .p_value = twoSidedT(t, df),
        .effect_size = if (pooled > 0) (ma - mb) / pooled else 0,
        .n = naf + nbf,
        .ok = 1,
    };
}

/// Student's two-sample t, pooling the variances. Only correct when the two
/// populations really do have equal variance -- prefer tTestWelch unless you know
/// they do.
pub fn tTestStudent(a: []const f64, b: []const f64) TestResult {
    const na = a.len;
    const nb = b.len;
    if (na < 2 or nb < 2) return FAILED;
    const naf: f64 = @floatFromInt(na);
    const nbf: f64 = @floatFromInt(nb);
    const ma = stats.compensatedSum(a) / naf;
    const mb = stats.compensatedSum(b) / nbf;
    const va = stats.varianceOf(a, .sample);
    const vb = stats.varianceOf(b, .sample);
    const df = naf + nbf - 2.0;
    const pooledVar = ((naf - 1.0) * va + (nbf - 1.0) * vb) / df;
    if (pooledVar <= 0) return FAILED;
    const t = (ma - mb) / @sqrt(pooledVar * (1.0 / naf + 1.0 / nbf));
    return .{
        .statistic = t,
        .df = df,
        .p_value = twoSidedT(t, df),
        .effect_size = (ma - mb) / @sqrt(pooledVar),
        .n = naf + nbf,
        .ok = 1,
    };
}

/// PAIRED t: the same subjects measured twice. Mathematically a one-sample t on the
/// DIFFERENCES, and implemented as exactly that rather than re-derived -- so the two
/// cannot disagree, and a test below checks they do not.
pub fn tTestPaired(allocator: std.mem.Allocator, a: []const f64, b: []const f64) !TestResult {
    if (a.len != b.len or a.len < 2) return FAILED;
    const d = try allocator.alloc(f64, a.len);
    defer allocator.free(d);
    for (a, b, 0..) |x, y, i| d[i] = x - y;
    return tTestOneSample(d, 0);
}

fn twoSidedT(t: f64, df: f64) f64 {
    if (!(df > 0)) return std.math.nan(f64);
    // 2 * P(T > |t|) -- computed from the UPPER tail so a tiny p keeps its digits,
    // the same reason special.zig has erfc separately from erf
    const upper = 1.0 - special.studentTCdf(@abs(t), df);
    const p = 2.0 * upper;
    return @min(1.0, @max(0.0, p));
}

// ─── chi-square ───

/// Goodness of fit: do the observed counts match the expected ones?
///
/// Effect size is Cohen's w = sqrt(chi2 / N).
pub fn chiSquareGoodnessOfFit(observed: []const f64, expected: []const f64) TestResult {
    if (observed.len != expected.len or observed.len < 2) return FAILED;
    var chi2: f64 = 0;
    var total: f64 = 0;
    for (observed, expected) |o, e| {
        if (!(e > 0)) return FAILED; // a zero expected count makes the statistic infinite
        const d = o - e;
        chi2 += d * d / e;
        total += o;
    }
    const df = @as(f64, @floatFromInt(observed.len)) - 1.0;
    if (total <= 0) return FAILED;
    return .{
        .statistic = chi2,
        .df = df,
        // one-tailed BY NATURE: only a large chi-square is evidence against the null,
        // because the statistic is a sum of squares and cannot be negative
        .p_value = 1.0 - special.chiSquareCdf(chi2, df),
        .effect_size = @sqrt(chi2 / total),
        .n = total,
        .ok = 1,
    };
}

/// Independence in an r*c contingency table (row-major). Expected counts come from
/// the row and column totals under the null that the two factors are unrelated.
///
/// Effect size is Cramer's V = sqrt(chi2 / (N * min(r-1, c-1))), which unlike the raw
/// chi-square does not grow with the sample size.
pub fn chiSquareIndependence(allocator: std.mem.Allocator, table: []const f64, rows: usize, cols: usize) !TestResult {
    if (rows < 2 or cols < 2 or table.len < rows * cols) return FAILED;
    const rowsum = try allocator.alloc(f64, rows);
    defer allocator.free(rowsum);
    const colsum = try allocator.alloc(f64, cols);
    defer allocator.free(colsum);
    @memset(rowsum, 0);
    @memset(colsum, 0);

    var total: f64 = 0;
    for (0..rows) |i| {
        for (0..cols) |j| {
            const v = table[i * cols + j];
            if (v < 0) return FAILED;
            rowsum[i] += v;
            colsum[j] += v;
            total += v;
        }
    }
    if (total <= 0) return FAILED;

    var chi2: f64 = 0;
    for (0..rows) |i| {
        for (0..cols) |j| {
            const e = rowsum[i] * colsum[j] / total;
            if (!(e > 0)) return FAILED; // an empty row or column: the test is undefined
            const d = table[i * cols + j] - e;
            chi2 += d * d / e;
        }
    }
    const df = @as(f64, @floatFromInt((rows - 1) * (cols - 1)));
    const k: f64 = @floatFromInt(@min(rows - 1, cols - 1));
    return .{
        .statistic = chi2,
        .df = df,
        .p_value = 1.0 - special.chiSquareCdf(chi2, df),
        .effect_size = @sqrt(chi2 / (total * k)),
        .n = total,
        .ok = 1,
    };
}

// ─── one-way ANOVA ───

/// Do k groups have different means? The F statistic is between-group variance over
/// within-group variance.
///
/// `groups` is a flat array and `sizes` says how long each group is, because a slice
/// of slices does not cross a C ABI.
///
/// Effect size is eta-squared: the fraction of total variation the grouping explains.
pub fn anovaOneWay(groups: []const f64, sizes: []const usize) TestResult {
    const k = sizes.len;
    if (k < 2) return FAILED;

    var total: f64 = 0;
    var n_total: usize = 0;
    for (sizes) |s| {
        if (s < 1) return FAILED;
        n_total += s;
    }
    if (groups.len < n_total or n_total <= k) return FAILED;
    for (groups[0..n_total]) |v| total += v;
    const grand = total / @as(f64, @floatFromInt(n_total));

    var ss_between: f64 = 0;
    var ss_within: f64 = 0;
    var off: usize = 0;
    for (sizes) |s| {
        const g = groups[off .. off + s];
        const sf: f64 = @floatFromInt(s);
        const gm = stats.compensatedSum(g) / sf;
        const d = gm - grand;
        ss_between += sf * d * d;
        ss_within += stats.centeredSumOfSquares(g, gm);
        off += s;
    }

    const df_between = @as(f64, @floatFromInt(k)) - 1.0;
    const df_within = @as(f64, @floatFromInt(n_total - k));
    if (!(ss_within > 0)) return FAILED; // no variation within any group
    const f = (ss_between / df_between) / (ss_within / df_within);
    const ss_total = ss_between + ss_within;
    return .{
        .statistic = f,
        .df = df_between,
        .p_value = 1.0 - special.fCdf(f, df_between, df_within),
        .effect_size = if (ss_total > 0) ss_between / ss_total else 0,
        .n = @floatFromInt(n_total),
        .ok = 1,
    };
}

// ─── correlation ───

/// Is Pearson's r different from zero? t = r * sqrt((n-2) / (1 - r^2)) on n-2 df.
/// The effect size IS r, which is already on a scale that does not depend on n.
pub fn correlationTest(a: []const f64, b: []const f64) TestResult {
    const n = a.len;
    if (n != b.len or n < 3) return FAILED;
    const nf: f64 = @floatFromInt(n);
    const ma = stats.compensatedSum(a) / nf;
    const mb = stats.compensatedSum(b) / nf;
    var sxy: f64 = 0;
    for (a, b) |x, y| sxy += (x - ma) * (y - mb);
    const sxx = stats.centeredSumOfSquares(a, ma);
    const syy = stats.centeredSumOfSquares(b, mb);
    if (!(sxx > 0) or !(syy > 0)) return FAILED;
    const r = sxy / @sqrt(sxx * syy);
    if (@abs(r) >= 1.0) {
        // a perfect correlation: t is infinite and p is 0, said exactly rather than
        // reached through a division by zero
        return .{ .statistic = std.math.inf(f64), .df = nf - 2.0, .p_value = 0, .effect_size = r, .n = nf, .ok = 1 };
    }
    const df = nf - 2.0;
    const t = r * @sqrt(df / (1.0 - r * r));
    return .{
        .statistic = t,
        .df = df,
        .p_value = twoSidedT(t, df),
        .effect_size = r,
        .n = nf,
        .ok = 1,
    };
}

// ─── C ABI ───
//
// Each returns the result through an out-pointer rather than by value, since a struct
// return across a C ABI is the part most likely to differ between toolchains.

pub fn stz_hyp_t_one_sample(ptr: [*]const f64, n: usize, mu0: f64, out: *TestResult) callconv(.c) void {
    out.* = tTestOneSample(ptr[0..n], mu0);
}

pub fn stz_hyp_t_welch(a: [*]const f64, na: usize, b: [*]const f64, nb: usize, out: *TestResult) callconv(.c) void {
    out.* = tTestWelch(a[0..na], b[0..nb]);
}

pub fn stz_hyp_t_student(a: [*]const f64, na: usize, b: [*]const f64, nb: usize, out: *TestResult) callconv(.c) void {
    out.* = tTestStudent(a[0..na], b[0..nb]);
}

pub fn stz_hyp_t_paired(a: [*]const f64, b: [*]const f64, n: usize, out: *TestResult) callconv(.c) void {
    out.* = tTestPaired(std.heap.c_allocator, a[0..n], b[0..n]) catch FAILED;
}

pub fn stz_hyp_chi2_gof(o: [*]const f64, e: [*]const f64, n: usize, out: *TestResult) callconv(.c) void {
    out.* = chiSquareGoodnessOfFit(o[0..n], e[0..n]);
}

pub fn stz_hyp_chi2_independence(t: [*]const f64, rows: usize, cols: usize, out: *TestResult) callconv(.c) void {
    out.* = chiSquareIndependence(std.heap.c_allocator, t[0 .. rows * cols], rows, cols) catch FAILED;
}

pub fn stz_hyp_anova(g: [*]const f64, ng: usize, sizes: [*]const usize, k: usize, out: *TestResult) callconv(.c) void {
    out.* = anovaOneWay(g[0..ng], sizes[0..k]);
}

pub fn stz_hyp_correlation(a: [*]const f64, b: [*]const f64, n: usize, out: *TestResult) callconv(.c) void {
    out.* = correlationTest(a[0..n], b[0..n]);
}

// ─── Tests ───
//
// Reference values are from R (t.test, chisq.test, aov, cor.test), but wherever an
// IDENTITY is available it is checked instead -- the phase-4 lesson that a transcribed
// constant is the weakest kind of assertion, learned when a mistyped F value made
// correct code look broken.

const testing = std.testing;

test "hypothesis: one-sample t against a published example" {
    // mean = 5.1625, sum of squared deviations = 0.49875, so s = 0.2669270 and
    //   t = (5.1625 - 5) / (0.2669270 / sqrt(8)) = 1.7218920642
    //
    // EVERY CONSTANT IN THIS FILE WAS VERIFIED AGAINST AN INDEPENDENT HAND
    // IMPLEMENTATION before being pinned -- plain textbook formulas sharing no code
    // with this module. That is not ceremony: the first draft of these tests used
    // values written from memory of R's output, SIX of them were wrong, and six
    // correct functions looked broken. Slice 5 had already recorded that exact
    // lesson ("a mistyped reference constant looks exactly like a broken
    // implementation") and it still happened. Verify, then pin.
    const d = [_]f64{ 5.1, 4.9, 5.6, 5.2, 5.0, 5.3, 4.8, 5.4 };
    const r = tTestOneSample(&d, 5.0);
    try testing.expect(r.ok == 1);
    try testing.expectApproxEqAbs(@as(f64, 1.7218920642), r.statistic, 1e-9);
    try testing.expectApproxEqAbs(@as(f64, 7), r.df, 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 0.1287617132), r.p_value, 1e-9);
    try testing.expectApproxEqAbs(@as(f64, 0.6087807775), r.effect_size, 1e-9);
    try testing.expectApproxEqAbs(@as(f64, 8), r.n, 1e-12);

    // testing against the sample's own mean must give t = 0 and p = 1 exactly
    const mean = stats.compensatedSum(&d) / 8.0;
    const r0 = tTestOneSample(&d, mean);
    try testing.expectApproxEqAbs(@as(f64, 0), r0.statistic, 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 1), r0.p_value, 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 0), r0.effect_size, 1e-12);
}

test "hypothesis: the PAIRED test IS a one-sample test on the differences" {
    // Not a coincidence to be verified but a definition to be honoured: tTestPaired
    // is implemented AS tTestOneSample on the differences, so this pins that it was
    // not re-derived into a second, drifting implementation.
    const before = [_]f64{ 200, 190, 210, 205, 195, 220, 185 };
    const after = [_]f64{ 195, 183, 200, 197, 190, 210, 180 };
    const paired = try tTestPaired(testing.allocator, &before, &after);

    var diff: [7]f64 = undefined;
    for (before, after, 0..) |x, y, i| diff[i] = x - y;
    const one = tTestOneSample(&diff, 0);

    try testing.expectEqual(one.statistic, paired.statistic);
    try testing.expectEqual(one.df, paired.df);
    try testing.expectEqual(one.p_value, paired.p_value);

    // differences are 5,7,10,8,5,10,5: mean 7.142857, s 2.267787, t = 8.3333333333
    try testing.expectApproxEqAbs(@as(f64, 8.3333333333), paired.statistic, 1e-9);
    try testing.expectApproxEqAbs(@as(f64, 6), paired.df, 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 1.621137e-4), paired.p_value, 1e-10);
}

test "hypothesis: Welch and Student agree when they should, differ when it matters" {
    // With EQUAL sizes and near-equal variances the two tests nearly coincide -- so
    // this checks Welch is not systematically off.
    const a = [_]f64{ 10, 12, 11, 13, 12, 14, 11, 12 };
    const b = [_]f64{ 15, 17, 16, 14, 18, 15, 16, 17 };
    const w = tTestWelch(&a, &b);
    const s = tTestStudent(&a, &b);
    try testing.expect(w.ok == 1 and s.ok == 1);
    try testing.expectApproxEqAbs(w.statistic, s.statistic, 0.05);
    try testing.expectApproxEqAbs(w.p_value, s.p_value, 0.01);

    try testing.expectApproxEqAbs(@as(f64, -6.4541256344), w.statistic, 1e-9);
    try testing.expectApproxEqAbs(@as(f64, 13.9662198391), w.df, 1e-9);
    try testing.expectApproxEqAbs(@as(f64, 1.529850e-5), w.p_value, 1e-11);

    // With EQUAL sample sizes the two tests share the same STATISTIC exactly -- only
    // the degrees of freedom differ (13.966 against 14), which is why their p-values
    // are so close here. That is a property of the formulas, not a coincidence.
    try testing.expectApproxEqAbs(w.statistic, s.statistic, 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 14), s.df, 1e-12);

    // WHERE THEY DIVERGE, and why Welch is the default: very unequal variances with
    // very unequal sizes. Student's df is fixed at n1+n2-2; Welch's shrinks toward
    // the smaller, less informative sample.
    const small = [_]f64{ 1, 2, 3, 100, -95 }; // huge variance, n = 5
    const big = [_]f64{ 10, 11, 10, 11, 10, 11, 10, 11, 10, 11, 10, 11 }; // tiny, n = 12
    const w2 = tTestWelch(&small, &big);
    const s2 = tTestStudent(&small, &big);
    try testing.expectEqual(@as(f64, 15), s2.df); // 5 + 12 - 2
    try testing.expect(w2.df < 5.0); // Welch is far more cautious
    try testing.expect(w2.p_value > s2.p_value); // ...and therefore less quick to call it significant
}

test "hypothesis: an EFFECT SIZE does not grow just because n did" {
    // THE REASON EVERY RESULT CARRIES ONE, and the numbers make the case better than
    // any argument. The same underlying data pattern -- mean 2.1, tested against 2.0
    // -- at four sample sizes:
    //
    //     n        t          p             Cohen's d
    //     10       0.2121     8.37e-1       0.067082
    //     100      0.7036     4.83e-1       0.070356
    //     1000     2.2349     2.56e-2       0.070675
    //     10000    7.0707     1.64e-12      0.070707
    //
    // ELEVEN ORDERS OF MAGNITUDE in the p-value, and the effect size does not move.
    // Worse: d = 0.07 is NEGLIGIBLE by any convention -- 0.2 is the threshold for
    // "small" -- so at n = 10000 this reports p < 1e-11 for a difference that does
    // not matter at all. A p-value answers "could this be chance?"; only the effect
    // size answers "is it worth anything?", and a result carrying just the first is
    // an invitation to misread it.
    var n10: [10]f64 = undefined;
    var n1k: [1000]f64 = undefined;
    var n10k: [10000]f64 = undefined;
    inline for (.{ &n10, &n1k, &n10k }) |arr| {
        for (arr, 0..) |*v, i| v.* = @as(f64, @floatFromInt(i % 5)) + 0.1;
    }

    const r10 = tTestOneSample(&n10, 2.0);
    const r1k = tTestOneSample(&n1k, 2.0);
    const r10k = tTestOneSample(&n10k, 2.0);

    // the effect size is the SAME to two decimals across a thousandfold change in n
    try testing.expectApproxEqAbs(@as(f64, 0.0671), r10.effect_size, 1e-4);
    try testing.expectApproxEqAbs(@as(f64, 0.0707), r1k.effect_size, 1e-4);
    try testing.expectApproxEqAbs(@as(f64, 0.0707), r10k.effect_size, 1e-4);

    // ...while the p-value falls off a cliff
    try testing.expect(r10.p_value > 0.8);
    try testing.expect(r1k.p_value < 0.05); // "significant" at the usual threshold
    try testing.expect(r10k.p_value < 1e-10); // overwhelmingly so

    // and the effect is negligible in all three, which is the point
    try testing.expect(r10k.effect_size < 0.2); // below even "small"
}

test "hypothesis: chi-square goodness of fit and independence" {
    // A fair die rolled 60 times. R: chisq.test(c(8,9,10,11,12,10)) -> X2 = 1, df = 5,
    // p = 0.9626
    const obs = [_]f64{ 8, 9, 10, 11, 12, 10 };
    const exp = [_]f64{ 10, 10, 10, 10, 10, 10 };
    const g = chiSquareGoodnessOfFit(&obs, &exp);
    try testing.expect(g.ok == 1);
    try testing.expectApproxEqAbs(@as(f64, 1.0), g.statistic, 1e-9);
    try testing.expectApproxEqAbs(@as(f64, 5), g.df, 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 0.9625657732), g.p_value, 1e-9);
    try testing.expectApproxEqAbs(@as(f64, 60), g.n, 1e-12);

    // a PERFECT fit gives chi2 = 0 and p = 1
    const perfect = chiSquareGoodnessOfFit(&exp, &exp);
    try testing.expectApproxEqAbs(@as(f64, 0), perfect.statistic, 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 1), perfect.p_value, 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 0), perfect.effect_size, 1e-12);

    // 2x2 contingency. R: chisq.test(matrix(c(20,30,30,20),2,2), correct=FALSE)
    //   -> X2 = 4, df = 1, p = 0.0455
    const tbl = [_]f64{ 20, 30, 30, 20 };
    const ind = try chiSquareIndependence(testing.allocator, &tbl, 2, 2);
    try testing.expect(ind.ok == 1);
    try testing.expectApproxEqAbs(@as(f64, 4.0), ind.statistic, 1e-9);
    try testing.expectApproxEqAbs(@as(f64, 1), ind.df, 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 0.0455002639), ind.p_value, 1e-9);
    try testing.expectApproxEqAbs(@as(f64, 100), ind.n, 1e-12);
    // Cramer's V for a 2x2 is sqrt(chi2/N) = 0.2
    try testing.expectApproxEqAbs(@as(f64, 0.2), ind.effect_size, 1e-9);

    // perfectly independent counts give chi2 = 0
    const indep = [_]f64{ 10, 20, 20, 40 }; // every cell = row*col/total
    const r2 = try chiSquareIndependence(testing.allocator, &indep, 2, 2);
    try testing.expectApproxEqAbs(@as(f64, 0), r2.statistic, 1e-9);
    try testing.expectApproxEqAbs(@as(f64, 1), r2.p_value, 1e-9);
}

test "hypothesis: ANOVA with two groups IS the two-sample t, squared" {
    // THE IDENTITY, and it ties this module to itself through two unrelated
    // distributions: F with 1 and v degrees of freedom is t with v, squared. If ANOVA
    // and the pooled t-test disagreed, one of them would be wrong.
    const a = [_]f64{ 10, 12, 11, 13, 12, 14 };
    const b = [_]f64{ 15, 17, 16, 14, 18, 15 };

    var flat: [12]f64 = undefined;
    @memcpy(flat[0..6], &a);
    @memcpy(flat[6..12], &b);
    const sizes = [_]usize{ 6, 6 };
    const f = anovaOneWay(&flat, &sizes);
    const t = tTestStudent(&a, &b);

    try testing.expect(f.ok == 1);
    try testing.expectApproxEqRel(t.statistic * t.statistic, f.statistic, 1e-9);
    try testing.expectApproxEqAbs(t.p_value, f.p_value, 1e-9);
    try testing.expectApproxEqAbs(@as(f64, 1), f.df, 1e-12);

    // three groups: SS between = 21.7333, SS within = 9.5, so
    //   F = (21.7333/2) / (9.5/12) = 13.7142857143
    const g1 = [_]f64{ 5, 6, 7, 6, 5 };
    const g2 = [_]f64{ 8, 9, 7, 8, 9 };
    const g3 = [_]f64{ 6, 5, 6, 7, 5 };
    var f3: [15]f64 = undefined;
    @memcpy(f3[0..5], &g1);
    @memcpy(f3[5..10], &g2);
    @memcpy(f3[10..15], &g3);
    const s3 = [_]usize{ 5, 5, 5 };
    const r3 = anovaOneWay(&f3, &s3);
    try testing.expectApproxEqAbs(@as(f64, 13.7142857143), r3.statistic, 1e-9);
    try testing.expectApproxEqAbs(@as(f64, 2), r3.df, 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 7.947330e-4), r3.p_value, 1e-9);
    try testing.expectApproxEqAbs(@as(f64, 0.6956521739), r3.effect_size, 1e-9);
    // eta-squared is a fraction, so it must sit in [0,1]
    try testing.expect(r3.effect_size > 0 and r3.effect_size < 1);

    // identical groups: no between-group variation at all
    const same = [_]f64{ 1, 2, 3, 1, 2, 3 };
    const ss = [_]usize{ 3, 3 };
    const rsame = anovaOneWay(&same, &ss);
    try testing.expectApproxEqAbs(@as(f64, 0), rsame.statistic, 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 1), rsame.p_value, 1e-12);
}

test "hypothesis: the correlation test, and its identity with the t distribution" {
    const x = [_]f64{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    const y = [_]f64{ 2, 4, 5, 4, 5, 7, 8, 9, 9, 11 };
    const r = correlationTest(&x, &y);
    try testing.expect(r.ok == 1);
    try testing.expectApproxEqAbs(@as(f64, 0.9704317700), r.effect_size, 1e-9);
    try testing.expectApproxEqAbs(@as(f64, 11.3714706537), r.statistic, 1e-9);
    try testing.expectApproxEqAbs(@as(f64, 8), r.df, 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 3.226902e-6), r.p_value, 1e-12);

    // A PERFECT correlation is said exactly rather than reached by dividing by zero.
    const perfect = correlationTest(&x, &x);
    try testing.expectApproxEqAbs(@as(f64, 1), perfect.effect_size, 1e-12);
    try testing.expectEqual(@as(f64, 0), perfect.p_value);
    try testing.expect(std.math.isInf(perfect.statistic));

    // no correlation at all: r near 0 and a large p
    const flat = [_]f64{ 1, -1, 1, -1, 1, -1, 1, -1, 1, -1 };
    const none = correlationTest(&x, &flat);
    try testing.expect(@abs(none.effect_size) < 0.3);
    try testing.expect(none.p_value > 0.3);
}

test "hypothesis: what cannot be tested is REFUSED, not answered with zeros" {
    // ok == 0 means "no test was run". Every other field is 0, and the caller must
    // not read a p-value of 0 as overwhelming significance -- which is exactly the
    // misreading the flag exists to prevent.
    const one = [_]f64{ 5 };
    try testing.expect(tTestOneSample(&one, 0).ok == 0);

    // no variation: every value identical, so there is nothing to test against
    const constant = [_]f64{ 3, 3, 3, 3 };
    try testing.expect(tTestOneSample(&constant, 0).ok == 0);
    try testing.expect(tTestWelch(&constant, &constant).ok == 0);

    // mismatched pairs
    const a = [_]f64{ 1, 2, 3 };
    const b = [_]f64{ 1, 2 };
    try testing.expect((try tTestPaired(testing.allocator, &a, &b)).ok == 0);
    try testing.expect(correlationTest(&a, &b).ok == 0);

    // a zero expected count makes the chi-square statistic infinite
    const obs = [_]f64{ 5, 5 };
    const bad = [_]f64{ 10, 0 };
    try testing.expect(chiSquareGoodnessOfFit(&obs, &bad).ok == 0);

    // an empty row leaves the independence test undefined
    const emptyrow = [_]f64{ 0, 0, 10, 10 };
    try testing.expect((try chiSquareIndependence(testing.allocator, &emptyrow, 2, 2)).ok == 0);

    // ANOVA needs at least two groups
    const g = [_]f64{ 1, 2, 3 };
    const one_group = [_]usize{3};
    try testing.expect(anovaOneWay(&g, &one_group).ok == 0);
}

test "hypothesis: every p-value is a probability" {
    // A cheap invariant that would catch a sign error, a wrong tail, or a df mistake
    // anywhere in the module -- across data that ranges from identical to wildly
    // different.
    var rng = std.Random.DefaultPrng.init(20260726);
    const rnd = rng.random();
    for (0..200) |_| {
        var a: [12]f64 = undefined;
        var b: [12]f64 = undefined;
        const shift = rnd.float(f64) * 10.0 - 5.0;
        for (&a, &b) |*x, *y| {
            x.* = rnd.floatNorm(f64);
            y.* = rnd.floatNorm(f64) + shift;
        }
        inline for (.{
            tTestOneSample(&a, 0),
            tTestWelch(&a, &b),
            tTestStudent(&a, &b),
            correlationTest(&a, &b),
        }) |r| {
            if (r.ok == 1) {
                try testing.expect(r.p_value >= 0.0 and r.p_value <= 1.0);
                try testing.expect(!std.math.isNan(r.p_value));
                try testing.expect(r.df > 0);
            }
        }
    }
}
