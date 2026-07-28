//! Principal component analysis, on the SVD.
//!
//! PCA asks: along which directions does this data vary most? The answer is the SVD
//! of the CENTERED data matrix -- the right singular vectors are the directions, the
//! singular values say how much variance each accounts for, and U*S puts every sample
//! into those coordinates. So almost nothing here is new arithmetic; the work is in
//! the three decisions around it, each of which changes the answer.
//!
//! ── 1. CENTERING IS NOT OPTIONAL ──
//!
//! PCA on uncentered data does not find the direction of greatest VARIANCE; it finds
//! the direction of greatest SECOND MOMENT, which for data far from the origin is
//! approximately the direction of the mean. The first component comes back pointing
//! at the centroid, explaining most of the "variance", and it is not variance at all.
//! This is the single most common way to get a wrong PCA, so it is done here rather
//! than documented as a caller's duty.
//!
//! ── 2. STANDARDISING IS A GENUINE CHOICE, AND THE CALLER MUST MAKE IT ──
//!
//! Centering alone gives COVARIANCE PCA: each feature contributes in proportion to
//! its own variance, in its own units. Measure someone's height in metres and their
//! mass in grams and the mass axis has variance a million times larger -- the first
//! component will be "mass", and that is an artefact of the unit, not a finding.
//! Dividing each column by its standard deviation first gives CORRELATION PCA, where
//! every feature contributes equally.
//!
//! Neither is right in general. Same units and comparable scales: covariance.
//! Different units: correlation, nearly always. There is no safe default, so the flag
//! is required at the call site rather than being given one.
//!
//! ── 3. THE VARIANCE DIVISOR IS NOT PCA'S TO CHOOSE ──
//!
//! The variance a component explains is s_j^2 / divisor, and this library settled
//! what "divisor" means in phase 0, after finding two modules disagreeing about it:
//! `stats.varianceDivisor(count, kind)` is the one authority. PCA asks it rather than
//! writing `n - 1`, so that the variances reported here and the variances reported by
//! stzDataSet can never drift apart.
//!
//! ── WHAT IS CHECKABLE WITHOUT A REFERENCE ──
//!
//! The explained variances must SUM to the total variance of the prepared data, and
//! the variance of column j of the scores must EQUAL explained variance j. Both are
//! identities, both are checked in the tests, and neither needs a tabulated answer --
//! which is what makes them worth more than a comparison against numbers copied out
//! of some other package.

const std = @import("std");
const linalg = @import("linalg.zig");
const stats = @import("stats.zig");

pub const Pca = struct {
    /// p column means, subtracted from every row. Kept because projecting NEW data
    /// requires exactly the same centering -- a caller who centers new rows by their
    /// own mean is projecting into a different space.
    means: []f64,
    /// p column scales. All 1.0 for covariance PCA.
    scales: []f64,
    /// p*k, COLUMN j is principal component j (the loadings)
    loadings: []f64,
    /// k singular values of the prepared matrix
    values: []f64,
    /// k explained variances, through stats.varianceDivisor
    variance: []f64,
    /// the sum of the variances of the prepared columns -- the denominator of every
    /// "proportion of variance explained"
    total_variance: f64,
    /// n*k, row i is sample i in principal-component coordinates (U*S)
    scores: []f64,
    n: usize,
    p: usize,
    k: usize,
    allocator: std.mem.Allocator,

    pub fn deinit(self: *Pca) void {
        self.allocator.free(self.means);
        self.allocator.free(self.scales);
        self.allocator.free(self.loadings);
        self.allocator.free(self.values);
        self.allocator.free(self.variance);
        self.allocator.free(self.scores);
        self.allocator.destroy(self);
    }
};

pub const Error = error{ TooFewSamples, NoFeatures, OutOfMemory, DidNotConverge };

/// Fit on `x`, an n*p row-major matrix of n samples and p features.
///
/// `standardize` selects correlation PCA over covariance PCA -- see the module note;
/// there is deliberately no default. `kind` selects the variance convention and goes
/// straight to the library's one divisor authority.
pub fn fit(
    alloc: std.mem.Allocator,
    x: []const f64,
    n: usize,
    p: usize,
    standardize: bool,
    kind: stats.VarianceKind,
) !*Pca {
    if (p == 0) return Error.NoFeatures;
    // a sample variance needs two observations, and one sample has no spread to
    // decompose in any case
    if (n < 2) return Error.TooFewSamples;

    const div = stats.varianceDivisor(n, kind);
    if (div == 0) return Error.TooFewSamples;

    const means = try alloc.alloc(f64, p);
    errdefer alloc.free(means);
    const scales = try alloc.alloc(f64, p);
    errdefer alloc.free(scales);

    // column means
    @memset(means, 0);
    for (0..n) |i| {
        for (0..p) |j| means[j] += x[i * p + j];
    }
    for (means) |*m| m.* /= @floatFromInt(n);

    // column scales: the standard deviation under the SAME convention, or 1
    @memset(scales, 1);
    if (standardize) {
        for (0..p) |j| {
            var ss: f64 = 0;
            for (0..n) |i| {
                const d = x[i * p + j] - means[j];
                ss += d * d;
            }
            const sd = @sqrt(ss / div);
            // A CONSTANT COLUMN HAS NO SPREAD TO NORMALISE. Dividing by its zero
            // standard deviation would produce NaN and poison the whole
            // decomposition, so it is left alone -- it contributes nothing to any
            // component, which is the truth about a feature that never varies.
            scales[j] = if (sd > 0) sd else 1;
        }
    }

    // the prepared matrix
    const prepared = try alloc.alloc(f64, n * p);
    defer alloc.free(prepared);
    for (0..n) |i| {
        for (0..p) |j| prepared[i * p + j] = (x[i * p + j] - means[j]) / scales[j];
    }

    // the total variance, from the prepared columns -- computed BEFORE the SVD so it
    // is an independent number rather than a restatement of the singular values
    var total: f64 = 0;
    for (0..p) |j| {
        var ss: f64 = 0;
        for (0..n) |i| {
            const v = prepared[i * p + j];
            ss += v * v; // already centered, so this IS the centered sum of squares
        }
        total += ss / div;
    }

    var d = linalg.svdAnyShape(alloc, prepared, n, p) catch return Error.DidNotConverge;
    defer d.deinit();
    if (!d.converged) return Error.DidNotConverge;

    const k = @min(n, p);
    const loadings = try alloc.alloc(f64, p * k);
    errdefer alloc.free(loadings);
    const values = try alloc.alloc(f64, k);
    errdefer alloc.free(values);
    const variance = try alloc.alloc(f64, k);
    errdefer alloc.free(variance);
    const scores = try alloc.alloc(f64, n * k);
    errdefer alloc.free(scores);

    @memcpy(loadings, d.v[0 .. p * k]);
    @memcpy(values, d.values[0..k]);
    for (0..k) |j| variance[j] = (d.values[j] * d.values[j]) / div;

    // scores = U * S, which is the same as (prepared * V) and cheaper
    for (0..n) |i| {
        for (0..j_end(k)) |j| scores[i * k + j] = d.u[i * k + j] * d.values[j];
    }

    signFix(loadings, scores, p, n, k);

    const out = try alloc.create(Pca);
    out.* = .{
        .means = means,
        .scales = scales,
        .loadings = loadings,
        .values = values,
        .variance = variance,
        .total_variance = total,
        .scores = scores,
        .n = n,
        .p = p,
        .k = k,
        .allocator = alloc,
    };
    return out;
}

inline fn j_end(k: usize) usize {
    return k;
}

/// A PRINCIPAL COMPONENT IS A DIRECTION, AND A DIRECTION HAS NO PREFERRED SIGN:
/// v and -v describe the same axis and explain the same variance. Left alone, the
/// sign falls out of the arithmetic and can flip between builds or between
/// near-identical inputs, which makes two runs look like they disagree.
///
/// The convention here is the common one: the largest-magnitude loading of each
/// component is made positive, and the corresponding score column is negated with it
/// so that scores = prepared * loadings continues to hold.
fn signFix(loadings: []f64, scores: []f64, p: usize, n: usize, k: usize) void {
    for (0..k) |j| {
        var big: f64 = 0;
        for (0..p) |i| {
            if (@abs(loadings[i * k + j]) > @abs(big)) big = loadings[i * k + j];
        }
        if (big < 0) {
            for (0..p) |i| loadings[i * k + j] = -loadings[i * k + j];
            for (0..n) |i| scores[i * k + j] = -scores[i * k + j];
        }
    }
}

/// Project `rows` (m*p) into the fitted component space, writing m*k scores.
/// Centered and scaled by the FIT's means and scales, not by their own -- new data
/// centered on itself lands in a different space and the coordinates are meaningless.
pub fn transform(pca: *const Pca, rows: []const f64, m: usize, out: []f64) void {
    for (0..m) |i| {
        for (0..pca.k) |j| {
            var acc: f64 = 0;
            for (0..pca.p) |t| {
                const v = (rows[i * pca.p + t] - pca.means[t]) / pca.scales[t];
                acc += v * pca.loadings[t * pca.k + j];
            }
            out[i * pca.k + j] = acc;
        }
    }
}

/// THE INVERSE, AND IT IS THE TRANSPOSE.
///
/// This is where PCA differs in kind from everything else in the embedding family. The
/// forward map is a ROTATION onto an orthonormal basis, so undoing it needs no second
/// model, no training and no lookup -- multiply by the same loadings the other way
/// round, put the scale back, put the mean back:
///
///     x ~ (scores . Loadings') * scale + mean
///
/// t-SNE and UMAP have no analytic inverse at all and must fit a decoder to (position,
/// row) pairs; this one is exact arithmetic that was already sitting in the fit.
///
/// ── AND THE ERROR IS NOT MYSTERIOUS EITHER ──
///
/// It is exactly the variance living in the components that were dropped. Not
/// approximately, not typically -- the residual is the projection onto the discarded
/// eigenvectors, so the mean squared reconstruction error over the training rows EQUALS
/// the sum of the discarded eigenvalues. That identity is testable, and it is a far
/// stronger check than any reconstruction number the learned inverses can offer: it
/// says the arithmetic is right rather than that it looked plausible.
///
/// Keep every component and the reconstruction is the data back, to rounding.
/// `k_use` is how many leading components the scores carry, so that reconstructing
/// from the first two of five is a question this can answer rather than a slice the
/// caller has to assemble. The loadings are still indexed by the fit's full k.
pub fn inverse(pca: *const Pca, scores: []const f64, m: usize, k_use: usize, out: []f64) void {
    const ku = @min(k_use, pca.k);
    for (0..m) |i| {
        for (0..pca.p) |t| {
            var acc: f64 = 0;
            for (0..ku) |j| {
                acc += scores[i * ku + j] * pca.loadings[t * pca.k + j];
            }
            out[i * pca.p + t] = acc * pca.scales[t] + pca.means[t];
        }
    }
}

/// How many components are needed to reach `wanted` of the total variance (0..1).
/// Returns k when even all of them fall short, which happens only through rounding.
pub fn componentsFor(pca: *const Pca, wanted: f64) usize {
    if (pca.total_variance <= 0) return 0;
    var acc: f64 = 0;
    for (0..pca.k) |j| {
        acc += pca.variance[j];
        if (acc / pca.total_variance >= wanted) return j + 1;
    }
    return pca.k;
}

// ─── tests ───────────────────────────────────────────────────────────────────

const testing = std.testing;

test "the explained variances SUM to the total variance" {
    // An identity, not a tabulated value: the decomposition redistributes the
    // variance among the components and cannot create or destroy any.
    const alloc = testing.allocator;
    const x = [_]f64{
        2.5, 2.4, 0.5, 0.7, 2.2, 2.9, 1.9, 2.2, 3.1, 3.0,
        2.3, 2.7, 2.0, 1.6, 1.0, 1.1, 1.5, 1.6, 1.1, 0.9,
    };
    var pca = try fit(alloc, &x, 10, 2, false, .sample);
    defer pca.deinit();
    var sum: f64 = 0;
    for (pca.variance) |v| sum += v;
    try testing.expectApproxEqRel(pca.total_variance, sum, 1e-12);
}

test "the variance of score column j IS explained variance j" {
    // The other identity. The scores are the data in component coordinates, so
    // their spread along axis j is exactly what component j was said to explain.
    const alloc = testing.allocator;
    const x = [_]f64{
        1, 2, 3, 4, 5, 7, 7, 8, 2, 1, 9, 3, 4, 4, 4, 6, 8, 2, 3, 5,
        5, 5, 5, 1, 2, 8, 9, 1, 7, 3,
    };
    const n = 10;
    const p = 3;
    var pca = try fit(alloc, &x, n, p, false, .sample);
    defer pca.deinit();

    const div = stats.varianceDivisor(n, .sample);
    for (0..pca.k) |j| {
        var mean: f64 = 0;
        for (0..n) |i| mean += pca.scores[i * pca.k + j];
        mean /= @floatFromInt(n);
        var ss: f64 = 0;
        for (0..n) |i| {
            const d = pca.scores[i * pca.k + j] - mean;
            ss += d * d;
        }
        try testing.expectApproxEqAbs(pca.variance[j], ss / div, 1e-9);
    }
}

test "the scores are centered -- which is what proves the centering happened" {
    const alloc = testing.allocator;
    const x = [_]f64{ 100, 200, 101, 202, 99, 198, 103, 205, 97, 195 };
    var pca = try fit(alloc, &x, 5, 2, false, .sample);
    defer pca.deinit();
    for (0..pca.k) |j| {
        var mean: f64 = 0;
        for (0..5) |i| mean += pca.scores[i * pca.k + j];
        try testing.expectApproxEqAbs(@as(f64, 0), mean / 5, 1e-10);
    }
}

test "a perfectly correlated pair collapses onto ONE component" {
    // y = 2x exactly: all the variance lies along one direction, so the second
    // component explains nothing at all.
    const alloc = testing.allocator;
    const x = [_]f64{ 1, 2, 2, 4, 3, 6, 4, 8, 5, 10 };
    var pca = try fit(alloc, &x, 5, 2, false, .sample);
    defer pca.deinit();
    try testing.expect(pca.variance[0] > 0);
    try testing.expect(pca.variance[1] < 1e-20);
    try testing.expectApproxEqRel(@as(f64, 1), pca.variance[0] / pca.total_variance, 1e-12);
    try testing.expectEqual(@as(usize, 1), componentsFor(pca, 0.99));
}

test "STANDARDISING changes the answer, which is why it is a required choice" {
    // Two features, one with a thousand times the spread. Covariance PCA follows
    // the big one almost entirely; correlation PCA weighs them equally.
    const alloc = testing.allocator;
    var x: [40]f64 = undefined;
    for (0..20) |i| {
        const t: f64 = @floatFromInt(i);
        x[i * 2] = t * 1000; // huge spread
        x[i * 2 + 1] = @sin(t); // small spread, unrelated
    }

    var cov = try fit(alloc, &x, 20, 2, false, .sample);
    defer cov.deinit();
    var cor = try fit(alloc, &x, 20, 2, true, .sample);
    defer cor.deinit();

    // covariance: the first component is essentially the big feature
    try testing.expect(@abs(cov.loadings[0 * 2 + 0]) > 0.999);
    try testing.expect(cov.variance[0] / cov.total_variance > 0.999);

    // correlation: both features contribute materially
    try testing.expect(@abs(cor.loadings[0 * 2 + 0]) < 0.99);
    try testing.expect(cor.variance[0] / cor.total_variance < 0.999);
}

test "the divisor comes from the library's authority, not from a literal" {
    const alloc = testing.allocator;
    const x = [_]f64{ 1, 2, 3, 4, 5, 7, 7, 8, 2, 1 };
    var s = try fit(alloc, &x, 5, 2, false, .sample);
    defer s.deinit();
    var p = try fit(alloc, &x, 5, 2, false, .population);
    defer p.deinit();
    // sample divides by n-1 and population by n, so the ratio is exactly n/(n-1)
    try testing.expectApproxEqRel(@as(f64, 5.0 / 4.0), s.variance[0] / p.variance[0], 1e-12);
    // and the PROPORTIONS are identical, because the convention scales every
    // component by the same factor
    try testing.expectApproxEqRel(
        s.variance[0] / s.total_variance,
        p.variance[0] / p.total_variance,
        1e-12,
    );
}

test "transform reproduces the training scores" {
    // Projecting the training data must give back exactly the scores from the fit;
    // if transform centered by its own mean instead of the fit's, it would not.
    const alloc = testing.allocator;
    const x = [_]f64{ 2.5, 2.4, 0.5, 0.7, 2.2, 2.9, 1.9, 2.2, 3.1, 3.0, 2.3, 2.7 };
    const n = 6;
    const p = 2;
    var pca = try fit(alloc, &x, n, p, false, .sample);
    defer pca.deinit();

    const out = try alloc.alloc(f64, n * pca.k);
    defer alloc.free(out);
    transform(pca, &x, n, out);
    for (0..n * pca.k) |i| try testing.expectApproxEqAbs(pca.scores[i], out[i], 1e-10);
}

test "a constant column does not produce NaN when standardising" {
    const alloc = testing.allocator;
    // second feature never varies: its standard deviation is zero
    const x = [_]f64{ 1, 5, 2, 5, 3, 5, 4, 5 };
    var pca = try fit(alloc, &x, 4, 2, true, .sample);
    defer pca.deinit();
    for (pca.loadings) |v| try testing.expect(std.math.isFinite(v));
    for (pca.variance) |v| try testing.expect(std.math.isFinite(v));
    // and it contributes nothing
    try testing.expectApproxEqAbs(@as(f64, 0), pca.variance[1], 1e-20);
}

test "the sign convention makes two runs agree" {
    const alloc = testing.allocator;
    const x = [_]f64{ 1, 2, 3, 4, 5, 7, 7, 8, 2, 1, 9, 3 };
    var a = try fit(alloc, &x, 6, 2, false, .sample);
    defer a.deinit();
    var b = try fit(alloc, &x, 6, 2, false, .sample);
    defer b.deinit();
    for (a.loadings, b.loadings) |p, q| try testing.expectEqual(p, q);
    // the largest loading of each component is positive
    for (0..a.k) |j| {
        var big: f64 = 0;
        for (0..a.p) |i| {
            if (@abs(a.loadings[i * a.k + j]) > @abs(big)) big = a.loadings[i * a.k + j];
        }
        try testing.expect(big > 0);
    }
}

test "too few samples is refused rather than answered" {
    const alloc = testing.allocator;
    const x = [_]f64{ 1, 2 };
    try testing.expectError(Error.TooFewSamples, fit(alloc, &x, 1, 2, false, .sample));
    try testing.expectError(Error.NoFeatures, fit(alloc, &x, 2, 0, false, .sample));
}

test "THE PCA INVERSE IS THE TRANSPOSE, and its error is the discarded variance" {
    const alloc = testing.allocator;
    const n = 60;
    const p = 5;
    const x = try alloc.alloc(f64, n * p);
    defer alloc.free(x);
    // three genuine directions plus two built from them, so dropping components has a
    // predictable cost rather than an arbitrary one
    var st: u64 = 99;
    for (0..n) |i| {
        st = st *% 6364136223846793005 +% 1442695040888963407;
        const a = @as(f64, @floatFromInt(st >> 11)) / 9007199254740992.0 - 0.5;
        st = st *% 6364136223846793005 +% 1442695040888963407;
        const b = @as(f64, @floatFromInt(st >> 11)) / 9007199254740992.0 - 0.5;
        st = st *% 6364136223846793005 +% 1442695040888963407;
        const c = @as(f64, @floatFromInt(st >> 11)) / 9007199254740992.0 - 0.5;
        x[i * p + 0] = a * 10;
        x[i * p + 1] = b * 4;
        x[i * p + 2] = c * 1;
        x[i * p + 3] = a * 3 + b;
        x[i * p + 4] = a * 2 - c;
    }

    var pc = try fit(alloc, x, n, p, false, .sample);
    defer pc.deinit();
    const sc = try alloc.alloc(f64, n * pc.k);
    defer alloc.free(sc);
    transform(pc, x, n, sc);
    const back = try alloc.alloc(f64, n * p);
    defer alloc.free(back);

    // KEEPING EVERYTHING: the reconstruction is the data back, to rounding
    inverse(pc, sc, n, pc.k, back);
    for (x, back) |a, b| try testing.expectApproxEqAbs(a, b, 1e-9);

    // DROPPING COMPONENTS: the mean squared error EQUALS the discarded variance.
    //
    // An identity, not an approximation -- the residual IS the projection onto the
    // eigenvectors that were dropped, so its size is their eigenvalues and nothing
    // else. This is a far stronger check than any reconstruction number the learned
    // inverses can offer: it says the arithmetic is RIGHT, not that it looked
    // plausible. Transpose the loadings the wrong way, or put the scale back before the
    // mean, and the numbers still look reasonable while this fails.
    const trunc = try alloc.alloc(f64, n * pc.k);
    defer alloc.free(trunc);
    for (1..pc.k) |ku| {
        for (0..n) |i| {
            for (0..ku) |j| trunc[i * ku + j] = sc[i * pc.k + j];
        }
        inverse(pc, trunc, n, ku, back);

        var mse: f64 = 0;
        for (0..n) |i| {
            for (0..p) |t| {
                const e = x[i * p + t] - back[i * p + t];
                mse += e * e;
            }
        }
        // the same divisor the fit used, so the two sides are the same quantity
        mse /= @as(f64, @floatFromInt(n - 1));

        var dropped: f64 = 0;
        for (ku..pc.k) |j| dropped += pc.variance[j];

        // ABSOLUTE, scaled to the data, and not relative -- because this data is
        // genuinely rank three (columns four and five are exact combinations of the
        // first three), so at ku = 3 and 4 BOTH sides are numerical noise: 1.3e-30
        // against 3e-32. A relative tolerance on two zeros compares rounding with
        // rounding and fails for no reason. That the tail comes out zero on both sides
        // is itself the identity holding, at the only precision available there.
        try testing.expectApproxEqAbs(dropped, mse, pc.total_variance * 1e-12);
    }
}

test "the inverse puts standardisation back too" {
    const alloc = testing.allocator;
    const n = 40;
    const p = 3;
    const x = try alloc.alloc(f64, n * p);
    defer alloc.free(x);
    // wildly different units, which is when standardising matters
    var st: u64 = 5;
    for (0..n) |i| {
        st = st *% 6364136223846793005 +% 1442695040888963407;
        const u = @as(f64, @floatFromInt(st >> 11)) / 9007199254740992.0;
        st = st *% 6364136223846793005 +% 1442695040888963407;
        const v = @as(f64, @floatFromInt(st >> 11)) / 9007199254740992.0;
        x[i * p + 0] = u * 1000;
        x[i * p + 1] = v * 0.001 + 0.5;
        x[i * p + 2] = (u - v) * 5 - 2;
    }

    var pc = try fit(alloc, x, n, p, true, .sample);
    defer pc.deinit();
    const sc = try alloc.alloc(f64, n * pc.k);
    defer alloc.free(sc);
    transform(pc, x, n, sc);
    const back = try alloc.alloc(f64, n * p);
    defer alloc.free(back);
    inverse(pc, sc, n, pc.k, back);

    // scale and mean must come back in the right order and the right direction; a
    // column spanning a thousand beside one spanning a thousandth makes that unmissable
    for (x, back) |a, b| try testing.expectApproxEqAbs(a, b, 1e-8);
}
