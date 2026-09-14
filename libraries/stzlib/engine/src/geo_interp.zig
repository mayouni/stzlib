// GE7c -- INTERPOLATION: WHAT IS THE VALUE WHERE NOBODY MEASURED?
//
// GE7b made a field out of a pattern by SMOOTHING it -- the density of
// places. This makes a field out of MEASUREMENTS: sixty rain gauges, and
// the rainfall everywhere between them. It is a different question and it
// has a different honest answer.
//
// THREE THINGS, IN THE ORDER AN ANALYST USES THEM:
//
//   1. IDW -- inverse distance weighting. Every sample votes with a weight
//      of 1/d^p. Needs no model, assumes nothing, and tells you nothing
//      about how wrong it is. It is the baseline, and its one real virtue
//      is that it CANNOT leave the data's range: a weighted average of
//      measurements is between the smallest and the largest.
//
//   2. THE VARIOGRAM -- the diagnostic almost nobody outside geostatistics
//      draws, and the reason kriging is not guesswork. Plot half the mean
//      squared difference of every pair against how far apart they are:
//      near zero for close pairs, rising to a plateau at the distance where
//      two measurements stop being related. That distance is the RANGE, the
//      plateau is the SILL, and the jump at the origin is the NUGGET --
//      measurement error plus structure finer than the closest pair.
//      Everything kriging does is read off this curve.
//
//   3. ORDINARY KRIGING -- the best linear unbiased predictor for the
//      variogram it is given, and the ONLY one of the three that answers
//      "how wrong might this be" at every point. That variance surface is
//      the deliverable, not a diagnostic: it is low where the samples are
//      and high in the gaps, and it is the map that says which parts of
//      the pretty coloured picture nobody should act on.
//
// FOUR DECISIONS:
//
//   1. THE KRIGING VARIANCE DEPENDS ON THE GEOMETRY AND NOT ON THE VALUES.
//      Multiply every measurement by ten and the variance surface does not
//      move. That is a property of the method, it surprises people, and
//      the tests pin it -- because it means the variance answers "how
//      densely did we sample here", which is a question worth a map.
//   2. ONE FACTORISATION FOR THE WHOLE GRID. The left-hand side of the
//      kriging system is the samples against each other; it does not
//      depend on where you are predicting. So it is LU-factorised ONCE and
//      every grid node is a back-substitution. Naively refactorising per
//      node would be n^3 per node instead of n^2.
//   3. LU WITH PARTIAL PIVOTING, NOT CHOLESKY. The bordered variogram
//      matrix is symmetric but NOT positive definite -- it is conditionally
//      negative definite with a row and column of ones round it -- so a
//      Cholesky would fail on the first pivot. This is the commonest
//      mistake in a home-made kriging.
//   4. THE RANGE IS FITTED BY SEARCH AND THE SILLS BY ALGEBRA. gamma(h) =
//      nugget + sill * f(h/range) is LINEAR in the two sills and non-linear
//      only in the range, so the range is swept over a grid of candidates
//      and the two sills solved exactly by weighted least squares at each.
//      No optimiser, no starting guess, no local minimum.

const std = @import("std");
const gs = @import("geo_stats.zig");

pub const Model = enum(u8) { spherical = 0, exponential = 1, gaussian = 2 };

/// The shape of the three models, normalised to 1 at the range.
///
/// Exponential and gaussian never actually reach their sill, so "range"
/// means the PRACTICAL range -- the distance at which 95% of the sill is
/// reached, which is the convention every GIS prints and the only one that
/// makes a range comparable between models.
fn shape(m: Model, t: f64) f64 {
    if (t <= 0) return 0;
    return switch (m) {
        .spherical => if (t >= 1) 1 else 1.5 * t - 0.5 * t * t * t,
        .exponential => 1 - @exp(-3 * t),
        .gaussian => 1 - @exp(-3 * t * t),
    };
}

pub const Variogram = struct {
    model: Model,
    nugget: f64,
    sill: f64, // the PARTIAL sill: the rise above the nugget
    range_km: f64,
    rss: f64, // weighted residual sum of squares of the fit

    /// gamma(h): the expected half-squared-difference of two measurements
    /// h apart. gamma(0) is 0 by definition -- a place does not differ from
    /// itself -- and the nugget is the LIMIT as h approaches 0, not the
    /// value at it. Getting that wrong makes kriging smooth through its own
    /// data points instead of honouring them.
    pub fn gamma(self: Variogram, h: f64) f64 {
        if (h <= 0) return 0;
        if (self.range_km <= 0) return self.nugget + self.sill;
        return self.nugget + self.sill * shape(self.model, h / self.range_km);
    }

    pub fn total(self: Variogram) f64 {
        return self.nugget + self.sill;
    }
};

// ------------------------------------------------------------------- IDW

/// INVERSE DISTANCE WEIGHTING at one place. Exact at a sample: a place
/// within a metre of a measurement IS that measurement, which is what an
/// interpolator (as against a smoother) means.
pub fn idwAt(lonlatz: []const f64, lon: f64, lat: f64, power: f64) f64 {
    const n = lonlatz.len / 3;
    if (n == 0) return std.math.nan(f64);
    var acc: f64 = 0;
    var wsum: f64 = 0;
    for (0..n) |i| {
        const d = gs.distanceKm(lon, lat, lonlatz[i * 3], lonlatz[i * 3 + 1]);
        if (d < 1e-6) return lonlatz[i * 3 + 2];
        const w = 1 / std.math.pow(f64, d, power);
        acc += w * lonlatz[i * 3 + 2];
        wsum += w;
    }
    if (wsum <= 0) return std.math.nan(f64);
    return acc / wsum;
}

// ------------------------------------------------------- the variogram

pub const Bin = struct { h_km: f64, gamma: f64, pairs: usize };

/// THE EMPIRICAL VARIOGRAM: every pair of samples, binned by how far apart
/// they are, and half the mean squared difference in each bin.
///
/// `max_km` defaults (pass 0) to HALF the greatest distance in the data.
/// That is the standard cut and it is not arbitrary: beyond half the
/// extent, only the pairs at opposite corners contribute, so the far bins
/// are computed from a handful of pairs that all share the same few points.
/// A variogram plotted to the full extent always looks like it does
/// something interesting at the right-hand end, and it never does.
pub fn empiricalVariogram(alloc: std.mem.Allocator, lonlatz: []const f64, lags: usize, max_km: f64, out: []Bin) !usize {
    const n = lonlatz.len / 3;
    if (n < 2 or lags == 0) return 0;
    var hi = max_km;
    if (hi <= 0) {
        var far: f64 = 0;
        for (0..n) |i| {
            for (i + 1..n) |j| {
                const d = gs.distanceKm(lonlatz[i * 3], lonlatz[i * 3 + 1], lonlatz[j * 3], lonlatz[j * 3 + 1]);
                if (d > far) far = d;
            }
        }
        hi = far / 2;
    }
    if (hi <= 0) return 0;
    const k = @min(lags, out.len);
    const sums = try alloc.alloc(f64, k);
    defer alloc.free(sums);
    const hsum = try alloc.alloc(f64, k);
    defer alloc.free(hsum);
    const cnt = try alloc.alloc(usize, k);
    defer alloc.free(cnt);
    @memset(sums, 0);
    @memset(hsum, 0);
    @memset(cnt, 0);
    const w = hi / @as(f64, @floatFromInt(k));
    for (0..n) |i| {
        for (i + 1..n) |j| {
            const d = gs.distanceKm(lonlatz[i * 3], lonlatz[i * 3 + 1], lonlatz[j * 3], lonlatz[j * 3 + 1]);
            if (d <= 0 or d > hi) continue;
            var b: usize = @intFromFloat(@floor(d / w));
            if (b >= k) b = k - 1;
            const dz = lonlatz[i * 3 + 2] - lonlatz[j * 3 + 2];
            sums[b] += dz * dz;
            hsum[b] += d;
            cnt[b] += 1;
        }
    }
    var m: usize = 0;
    for (0..k) |b| {
        if (cnt[b] == 0) continue;
        const c: f64 = @floatFromInt(cnt[b]);
        out[m] = .{ .h_km = hsum[b] / c, .gamma = sums[b] / (2 * c), .pairs = cnt[b] };
        m += 1;
    }
    return m;
}

/// FIT ONE MODEL to the binned variogram, by weighted least squares.
///
/// gamma(h) = nugget + sill * f(h / range) is linear in (nugget, sill) once
/// the range is fixed, so the range is SWEPT over a grid of candidates and
/// the two sills are solved exactly at each by a 2x2 normal equation. The
/// best of the sweep is refined once around itself. Weights are the pair
/// counts: a bin built from four hundred pairs should not be argued with by
/// one built from three.
///
/// A negative sill or nugget is not a fit, it is an artefact of least
/// squares on a curve that does not suit; both are clamped to zero and the
/// other refitted, which is what every geostatistics package does.
pub fn fitVariogram(bins: []const Bin, m: Model) Variogram {
    var best = Variogram{ .model = m, .nugget = 0, .sill = 0, .range_km = 0, .rss = std.math.inf(f64) };
    if (bins.len < 2) return best;
    var hmax: f64 = 0;
    for (bins) |b| {
        if (b.h_km > hmax) hmax = b.h_km;
    }
    if (hmax <= 0) return best;

    var lo = hmax * 0.05;
    var hi = hmax * 2.0;
    var pass: usize = 0;
    while (pass < 3) : (pass += 1) {
        const steps: usize = 60;
        var s: usize = 0;
        while (s <= steps) : (s += 1) {
            const a = lo + (hi - lo) * @as(f64, @floatFromInt(s)) / @as(f64, @floatFromInt(steps));
            if (a <= 0) continue;
            const cand = solveSills(bins, m, a);
            if (cand.rss < best.rss) best = cand;
        }
        // refine around the winner
        const span = (hi - lo) / 8;
        lo = @max(best.range_km - span, hmax * 0.01);
        hi = best.range_km + span;
    }
    return best;
}

/// the two sills at a fixed range, by weighted least squares, then clamped
fn solveSills(bins: []const Bin, m: Model, range: f64) Variogram {
    var s11: f64 = 0;
    var s12: f64 = 0;
    var s22: f64 = 0;
    var b1: f64 = 0;
    var b2: f64 = 0;
    for (bins) |bn| {
        const w: f64 = @floatFromInt(bn.pairs);
        const f = shape(m, bn.h_km / range);
        s11 += w;
        s12 += w * f;
        s22 += w * f * f;
        b1 += w * bn.gamma;
        b2 += w * f * bn.gamma;
    }
    const det = s11 * s22 - s12 * s12;
    var c0: f64 = 0;
    var c1: f64 = 0;
    if (@abs(det) > 1e-300) {
        c0 = (b1 * s22 - b2 * s12) / det;
        c1 = (s11 * b2 - s12 * b1) / det;
    }
    // NEITHER PIECE MAY BE NEGATIVE. A negative nugget says two places
    // agree better than a place agrees with itself; a negative sill says
    // things get MORE alike the further apart they are.
    if (c0 < 0) {
        c0 = 0;
        var num: f64 = 0;
        var den: f64 = 0;
        for (bins) |bn| {
            const w: f64 = @floatFromInt(bn.pairs);
            const f = shape(m, bn.h_km / range);
            num += w * f * bn.gamma;
            den += w * f * f;
        }
        c1 = if (den > 1e-300) num / den else 0;
        if (c1 < 0) c1 = 0;
    } else if (c1 < 0) {
        c1 = 0;
        var num: f64 = 0;
        var den: f64 = 0;
        for (bins) |bn| {
            const w: f64 = @floatFromInt(bn.pairs);
            num += w * bn.gamma;
            den += w;
        }
        c0 = if (den > 1e-300) num / den else 0;
    }
    var v = Variogram{ .model = m, .nugget = c0, .sill = c1, .range_km = range, .rss = 0 };
    for (bins) |bn| {
        const w: f64 = @floatFromInt(bn.pairs);
        const r = bn.gamma - v.gamma(bn.h_km);
        v.rss += w * r * r;
    }
    return v;
}

/// the best of the three, by the same weighted residual
pub fn fitBest(bins: []const Bin) Variogram {
    var best = fitVariogram(bins, .spherical);
    for ([_]Model{ .exponential, .gaussian }) |m| {
        const c = fitVariogram(bins, m);
        if (c.rss < best.rss) best = c;
    }
    return best;
}

// --------------------------------------------------------- ordinary kriging

/// LU with partial pivoting. The kriging matrix is symmetric and NOT
/// positive definite -- it is conditionally negative definite with a
/// bordering row and column of ones -- so a Cholesky fails at the first
/// pivot. This is the commonest mistake in a home-made kriging.
const Lu = struct {
    a: []f64,
    piv: []usize,
    n: usize,
    singular: bool,

    fn deinit(self: *Lu, alloc: std.mem.Allocator) void {
        alloc.free(self.a);
        alloc.free(self.piv);
    }

    fn solve(self: *const Lu, b: []f64) void {
        const n = self.n;
        for (0..n) |i| {
            const p = self.piv[i];
            if (p != i) std.mem.swap(f64, &b[i], &b[p]);
            for (0..i) |k| b[i] -= self.a[i * n + k] * b[k];
        }
        var i: usize = n;
        while (i > 0) {
            i -= 1;
            for (i + 1..n) |k| b[i] -= self.a[i * n + k] * b[k];
            b[i] /= self.a[i * n + i];
        }
    }
};

fn factorise(alloc: std.mem.Allocator, m: []f64, n: usize) !Lu {
    const piv = try alloc.alloc(usize, n);
    var lu = Lu{ .a = m, .piv = piv, .n = n, .singular = false };
    for (0..n) |k| {
        var p = k;
        var big = @abs(m[k * n + k]);
        for (k + 1..n) |i| {
            const v = @abs(m[i * n + k]);
            if (v > big) {
                big = v;
                p = i;
            }
        }
        piv[k] = p;
        if (big < 1e-300) {
            lu.singular = true;
            return lu;
        }
        if (p != k) {
            for (0..n) |j| std.mem.swap(f64, &m[k * n + j], &m[p * n + j]);
        }
        for (k + 1..n) |i| {
            m[i * n + k] /= m[k * n + k];
            const f = m[i * n + k];
            if (f == 0) continue;
            for (k + 1..n) |j| m[i * n + j] -= f * m[k * n + j];
        }
    }
    return lu;
}

pub const Kriged = struct { estimate: f64, variance: f64 };

/// The factorised sample-to-sample system, reusable for every target.
pub const Krig = struct {
    lu: Lu,
    v: Variogram,
    xyz: []const f64,
    n: usize,
    alloc: std.mem.Allocator,
    rhs: []f64,

    pub fn deinit(self: *Krig) void {
        self.lu.deinit(self.alloc);
        self.alloc.free(self.rhs);
    }

    /// THE ESTIMATE AND ITS VARIANCE at one place.
    ///
    /// variance = sum(w_i * gamma(d_0i)) + mu, and note what is NOT in it:
    /// the measured values. The kriging variance is a function of WHERE the
    /// samples are and of the variogram, and of nothing else -- so it
    /// answers "how densely was this neighbourhood sampled", which is the
    /// map worth drawing beside the estimate.
    pub fn at(self: *Krig, lon: f64, lat: f64) Kriged {
        const n = self.n;
        for (0..n) |i| {
            self.rhs[i] = self.v.gamma(gs.distanceKm(lon, lat, self.xyz[i * 3], self.xyz[i * 3 + 1]));
        }
        self.rhs[n] = 1;
        if (self.lu.singular) return .{ .estimate = std.math.nan(f64), .variance = std.math.nan(f64) };
        const g0 = self.alloc.alloc(f64, n + 1) catch
            return .{ .estimate = std.math.nan(f64), .variance = std.math.nan(f64) };
        defer self.alloc.free(g0);
        @memcpy(g0, self.rhs);
        self.lu.solve(self.rhs);
        var est: f64 = 0;
        var vr: f64 = self.rhs[n]; // the Lagrange multiplier
        for (0..n) |i| {
            est += self.rhs[i] * self.xyz[i * 3 + 2];
            vr += self.rhs[i] * g0[i];
        }
        if (vr < 0) vr = 0; // rounding, at a sample where it is exactly zero
        return .{ .estimate = est, .variance = vr };
    }
};

/// FACTORISE ONCE. Everything here is the samples against each other and
/// does not depend on where the prediction is, so a grid of ten thousand
/// nodes pays this once and a back-substitution each.
pub fn prepare(alloc: std.mem.Allocator, lonlatz: []const f64, v: Variogram) !Krig {
    const n = lonlatz.len / 3;
    const m = try alloc.alloc(f64, (n + 1) * (n + 1));
    errdefer alloc.free(m);
    const w = n + 1;
    for (0..n) |i| {
        for (0..n) |j| {
            m[i * w + j] = if (i == j) 0 else v.gamma(gs.distanceKm(lonlatz[i * 3], lonlatz[i * 3 + 1], lonlatz[j * 3], lonlatz[j * 3 + 1]));
        }
        m[i * w + n] = 1;
        m[n * w + i] = 1;
    }
    m[n * w + n] = 0;
    const lu = try factorise(alloc, m, w);
    const rhs = try alloc.alloc(f64, w);
    return .{ .lu = lu, .v = v, .xyz = lonlatz, .n = n, .alloc = alloc, .rhs = rhs };
}

/// LEAVE-ONE-OUT CROSS-VALIDATION: the honest test of an interpolator, and
/// the one a report owes. Each sample is predicted from all the others.
/// Returns the mean error (bias -- should be near zero) and the root mean
/// squared error.
pub fn crossValidate(alloc: std.mem.Allocator, lonlatz: []const f64, v: Variogram, out_me: *f64, out_rmse: *f64) !void {
    const n = lonlatz.len / 3;
    out_me.* = 0;
    out_rmse.* = 0;
    if (n < 3) return;
    const sub = try alloc.alloc(f64, (n - 1) * 3);
    defer alloc.free(sub);
    var se: f64 = 0;
    var me: f64 = 0;
    for (0..n) |k| {
        var w: usize = 0;
        for (0..n) |i| {
            if (i == k) continue;
            sub[w * 3] = lonlatz[i * 3];
            sub[w * 3 + 1] = lonlatz[i * 3 + 1];
            sub[w * 3 + 2] = lonlatz[i * 3 + 2];
            w += 1;
        }
        var kr = try prepare(alloc, sub, v);
        defer kr.deinit();
        const r = kr.at(lonlatz[k * 3], lonlatz[k * 3 + 1]);
        if (std.math.isNan(r.estimate)) continue;
        const e = r.estimate - lonlatz[k * 3 + 2];
        me += e;
        se += e * e;
    }
    const nf: f64 = @floatFromInt(n);
    out_me.* = me / nf;
    out_rmse.* = @sqrt(se / nf);
}

// ------------------------------------------------------------------ tests

const testing = std.testing;
const ta = testing.allocator;

/// nine gauges on a 3x3 lattice over 4 degrees, value = 10 + 5*lon
fn ramp9() [27]f64 {
    var a: [27]f64 = undefined;
    var k: usize = 0;
    for (0..3) |j| {
        for (0..3) |i| {
            const lon: f64 = @as(f64, @floatFromInt(i)) * 2;
            const lat: f64 = @as(f64, @floatFromInt(j)) * 2;
            a[k * 3] = lon;
            a[k * 3 + 1] = lat;
            a[k * 3 + 2] = 10 + 5 * lon;
            k += 1;
        }
    }
    return a;
}

test "IDW is exact at a sample and cannot leave the data's range" {
    const s = ramp9();
    // at a sample
    try testing.expect(@abs(idwAt(&s, 0, 0, 2) - 10) < 1e-9);
    try testing.expect(@abs(idwAt(&s, 4, 4, 2) - 30) < 1e-9);
    // between them: inside the range, always
    var lon: f64 = -1;
    while (lon <= 5) : (lon += 0.37) {
        var lat: f64 = -1;
        while (lat <= 5) : (lat += 0.37) {
            const v = idwAt(&s, lon, lat, 2);
            try testing.expect(v >= 10 - 1e-9 and v <= 30 + 1e-9);
        }
    }
}

test "a higher power makes IDW more local" {
    const s = ramp9();
    // near the left edge: a big power leans harder on the nearest sample
    const soft = idwAt(&s, 0.3, 2, 1);
    const hard = idwAt(&s, 0.3, 2, 6);
    try testing.expect(@abs(hard - 10) < @abs(soft - 10));
}

test "the empirical variogram rises from near zero toward a sill" {
    // a field with structure: value = sin of position, sampled on a lattice
    var pts: [300]f64 = undefined;
    var k: usize = 0;
    var seed = std.Random.DefaultPrng.init(7);
    const rnd = seed.random();
    while (k < 100) : (k += 1) {
        const lon = rnd.float(f64) * 6;
        const lat = rnd.float(f64) * 6;
        pts[k * 3] = lon;
        pts[k * 3 + 1] = lat;
        pts[k * 3 + 2] = @sin(lon * 0.9) * 10 + @cos(lat * 0.9) * 10;
    }
    var bins: [12]Bin = undefined;
    const m = try empiricalVariogram(ta, &pts, 12, 0, &bins);
    try testing.expect(m >= 8);
    // the first bin is well under the last: that IS spatial structure
    try testing.expect(bins[0].gamma < bins[m - 1].gamma * 0.5);
    // every bin has pairs, and the near bins have plenty
    for (0..m) |i| try testing.expect(bins[i].pairs > 0);
    // h ascends
    for (1..m) |i| try testing.expect(bins[i].h_km > bins[i - 1].h_km);
}

test "NEGATIVE: pure noise has a flat variogram, all nugget and no range structure" {
    var pts: [300]f64 = undefined;
    var seed = std.Random.DefaultPrng.init(11);
    const rnd = seed.random();
    for (0..100) |k| {
        pts[k * 3] = rnd.float(f64) * 6;
        pts[k * 3 + 1] = rnd.float(f64) * 6;
        pts[k * 3 + 2] = rnd.floatNorm(f64) * 10;
    }
    var bins: [10]Bin = undefined;
    const m = try empiricalVariogram(ta, &pts, 10, 0, &bins);
    const v = fitBest(bins[0..m]);
    // the nugget carries nearly all of it: there is no structure to find
    try testing.expect(v.nugget > v.total() * 0.7);
}

test "a fitted model recovers the parameters it was generated from" {
    // build a variogram cloud straight from a known spherical model, so the
    // right answer is the one written here and not the one the code gives
    const truth = Variogram{ .model = .spherical, .nugget = 2, .sill = 8, .range_km = 300, .rss = 0 };
    var bins: [20]Bin = undefined;
    for (0..20) |i| {
        const h = 30 * @as(f64, @floatFromInt(i + 1));
        bins[i] = .{ .h_km = h, .gamma = truth.gamma(h), .pairs = 100 };
    }
    const got = fitVariogram(&bins, .spherical);
    try testing.expect(@abs(got.nugget - 2) < 0.3);
    try testing.expect(@abs(got.sill - 8) < 0.5);
    try testing.expect(@abs(got.range_km - 300) < 25);
    try testing.expect(got.rss < 1);
    // and the best-of-three picks the spherical it was made from
    try testing.expect(fitBest(&bins).model == .spherical);
}

test "neither the nugget nor the sill can come out negative" {
    // a decreasing cloud: least squares would want a negative sill
    var bins: [6]Bin = undefined;
    for (0..6) |i| {
        bins[i] = .{ .h_km = 50 * @as(f64, @floatFromInt(i + 1)), .gamma = 20 - 2 * @as(f64, @floatFromInt(i)), .pairs = 50 };
    }
    const v = fitBest(&bins);
    try testing.expect(v.nugget >= 0 and v.sill >= 0);
}

test "kriging is exact at a sample, and its variance there is zero" {
    const s = ramp9();
    const v = Variogram{ .model = .spherical, .nugget = 0, .sill = 10, .range_km = 500, .rss = 0 };
    var kr = try prepare(ta, &s, v);
    defer kr.deinit();
    for (0..9) |i| {
        const r = kr.at(s[i * 3], s[i * 3 + 1]);
        try testing.expect(@abs(r.estimate - s[i * 3 + 2]) < 1e-6);
        try testing.expect(r.variance < 1e-6);
    }
}

test "THE KRIGING VARIANCE DOES NOT DEPEND ON THE MEASURED VALUES" {
    // the same nine places, values multiplied by ten and shifted: the
    // estimate follows, the variance does not move at all
    const a = ramp9();
    var b = a;
    for (0..9) |i| b[i * 3 + 2] = a[i * 3 + 2] * 10 + 1000;
    const v = Variogram{ .model = .exponential, .nugget = 1, .sill = 9, .range_km = 400, .rss = 0 };
    var ka = try prepare(ta, &a, v);
    defer ka.deinit();
    var kb = try prepare(ta, &b, v);
    defer kb.deinit();
    var lon: f64 = 0.5;
    while (lon < 4) : (lon += 0.7) {
        const ra = ka.at(lon, 1.3);
        const rb = kb.at(lon, 1.3);
        try testing.expect(@abs(ra.variance - rb.variance) < 1e-9);
        try testing.expect(@abs((ra.estimate * 10 + 1000) - rb.estimate) < 1e-6);
    }
}

test "the variance grows away from the samples, and is greatest outside them" {
    const s = ramp9();
    const v = Variogram{ .model = .spherical, .nugget = 0, .sill = 10, .range_km = 400, .rss = 0 };
    var kr = try prepare(ta, &s, v);
    defer kr.deinit();
    const at_sample = kr.at(2, 2).variance;
    const between = kr.at(1, 1).variance;
    const outside = kr.at(9, 9).variance;
    try testing.expect(at_sample < between);
    try testing.expect(between < outside);
}

test "a nugget makes the kriged surface DISCONTINUOUS at its own data" {
    // I ASSERTED FOLK WISDOM AND THE CODE WAS RIGHT. The first version of
    // this test said "a nugget makes kriging a smoother: it no longer
    // honours its own data", and failed. It failed because that is not
    // what ordinary kriging does. With a nugget the predictor is STILL
    // EXACT at a sample -- the weight on that sample is 1 -- and the
    // surface JUMPS the instant you step off it. Measured on this ramp at
    // the corner sample, 200 m away:
    //
    //     nugget 0:  10.000 at the sample, 10.007 beside it, variance 0.017
    //     nugget 6:  10.000 at the sample, 15.510 beside it, variance 8.69
    //
    // That discontinuity IS the nugget: the part of the variation that
    // lives at distances shorter than anything was measured at. A
    // smoother would need filtered kriging, which predicts a different
    // quantity and is not this.
    const s = ramp9();
    const clean = Variogram{ .model = .spherical, .nugget = 0, .sill = 10, .range_km = 400, .rss = 0 };
    const noisy = Variogram{ .model = .spherical, .nugget = 6, .sill = 4, .range_km = 400, .rss = 0 };
    var kc = try prepare(ta, &s, clean);
    defer kc.deinit();
    var kn = try prepare(ta, &s, noisy);
    defer kn.deinit();
    const at = s[2]; // the corner sample's value, 10
    const step = 0.002; // about 200 m

    // BOTH are exact at the sample itself, and both have zero variance there
    try testing.expect(@abs(kc.at(s[0], s[1]).estimate - at) < 1e-6);
    try testing.expect(@abs(kn.at(s[0], s[1]).estimate - at) < 1e-6);
    try testing.expect(kc.at(s[0], s[1]).variance < 1e-6);
    try testing.expect(kn.at(s[0], s[1]).variance < 1e-6);

    // without a nugget the surface is continuous: a step of 200 m moves it
    // by hundredths, and the variance with it
    const near_clean = kc.at(s[0] + step, s[1]);
    try testing.expect(@abs(near_clean.estimate - at) < 0.1);
    try testing.expect(near_clean.variance < 0.1);

    // WITH a nugget it has jumped, and the variance has jumped to the
    // nugget's own scale, over the same 200 m
    const near_noisy = kn.at(s[0] + step, s[1]);
    try testing.expect(near_noisy.estimate > at + 3);
    try testing.expect(near_noisy.variance > 5);
    // and the jump is a DISCONTINUITY, not a slope: ten times further out
    // barely moves it again
    const far_noisy = kn.at(s[0] + step * 10, s[1]);
    try testing.expect(@abs(far_noisy.estimate - near_noisy.estimate) < 0.2);
}

test "NEGATIVE: kriging may leave the data's range where IDW may not" {
    // three samples on a line, the middle one much lower: kriging a point
    // beyond the end can overshoot, which is the price of unbiasedness
    const s = [_]f64{ 0, 0, 100, 1, 0, 0, 2, 0, 100 };
    const v = Variogram{ .model = .gaussian, .nugget = 0, .sill = 100, .range_km = 300, .rss = 0 };
    var kr = try prepare(ta, &s, v);
    defer kr.deinit();
    var over = false;
    var lon: f64 = -1.5;
    while (lon < 3.5) : (lon += 0.1) {
        const e = kr.at(lon, 0).estimate;
        if (e > 100.001 or e < -0.001) over = true;
        // IDW never does
        const iv = idwAt(&s, lon, 0, 2);
        try testing.expect(iv >= -1e-9 and iv <= 100 + 1e-9);
    }
    try testing.expect(over);
}

test "cross-validation is near unbiased on a smooth field" {
    var pts: [180]f64 = undefined;
    var seed = std.Random.DefaultPrng.init(3);
    const rnd = seed.random();
    for (0..60) |k| {
        const lon = rnd.float(f64) * 5;
        const lat = rnd.float(f64) * 5;
        pts[k * 3] = lon;
        pts[k * 3 + 1] = lat;
        pts[k * 3 + 2] = 50 + 10 * @sin(lon * 0.8) + 8 * @cos(lat * 0.7);
    }
    var bins: [12]Bin = undefined;
    const m = try empiricalVariogram(ta, &pts, 12, 0, &bins);
    const v = fitBest(bins[0..m]);
    var me: f64 = 0;
    var rmse: f64 = 0;
    try crossValidate(ta, &pts, v, &me, &rmse);
    // the spread of the field itself is about 12; a useful interpolator
    // must beat that, and must not be systematically high or low
    try testing.expect(rmse < 6);
    try testing.expect(@abs(me) < 1.5);
}

test "a singular system answers nothing rather than nonsense" {
    // two samples at the SAME place with different values: the matrix has
    // two identical rows and cannot be solved
    const s = [_]f64{ 1, 1, 10, 1, 1, 20 };
    const v = Variogram{ .model = .spherical, .nugget = 0, .sill = 5, .range_km = 100, .rss = 0 };
    var kr = try prepare(ta, &s, v);
    defer kr.deinit();
    try testing.expect(kr.lu.singular);
    try testing.expect(std.math.isNan(kr.at(2, 2).estimate));
}
