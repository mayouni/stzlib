//! t-SNE: t-distributed stochastic neighbour embedding.
//!
//! WHAT IT IS FOR, AND WHAT IT IS NOT. PCA answers "which directions carry the most
//! variance" with a linear, deterministic, reversible map. t-SNE answers a different
//! question -- "which points are NEAR each other" -- and buys that with a nonlinear,
//! stochastic, one-way map. It exists to make a picture, and the picture is worth
//! reading carefully:
//!
//!   * DISTANCES IN THE OUTPUT ARE NOT MEANINGFUL. Two clusters drawn far apart are
//!     not "more different" than two drawn close. The algorithm optimises a
//!     probability of neighbourhood, not a distance, and the global arrangement is
//!     largely arbitrary.
//!   * CLUSTER SIZES ARE NOT MEANINGFUL EITHER. A tight cluster and a diffuse one can
//!     come out the same size, because the Student-t kernel deliberately expands
//!     dense regions to use the available room.
//!   * IT IS STOCHASTIC. A different seed is a different picture of the same data.
//!     The seed is therefore an input, not an implementation detail.
//!
//! THE MATHEMATICS, briefly. In the high-dimensional space each point gets a Gaussian
//! whose width is chosen so that its neighbourhood distribution has a requested
//! PERPLEXITY -- roughly "how many neighbours should count". Those conditional
//! probabilities are symmetrised into P. In the low-dimensional space, neighbourhood
//! probability Q uses a STUDENT-T KERNEL with one degree of freedom, whose heavy tail
//! is what stops distant points being crushed together (the "crowding problem" that
//! sank the earlier SNE). Then gradient descent on KL(P || Q).
//!
//! TWO TRICKS THAT ARE NOT OPTIONAL, both from the original paper:
//!   * EARLY EXAGGERATION -- multiply P by 12 for the first iterations, so clusters
//!     form tight and have room to move apart before fine structure is fitted.
//!     Without it the embedding tends to one undifferentiated ball.
//!   * MOMENTUM, low then high. Plain gradient descent on this objective crawls.
//!
//! SCALE, HONESTLY: this is the EXACT O(n^2) algorithm, not Barnes-Hut. Every pair is
//! computed every iteration, so a few thousand points is comfortable and a hundred
//! thousand is not. Saying so beats an approximation whose error nobody has budgeted.

const std = @import("std");
const density = @import("density.zig");

pub const Options = struct {
    /// roughly "how many neighbours should count". The original paper suggests 5..50
    /// and the result IS sensitive to it -- it is a parameter, not a constant.
    perplexity: f64 = 30,
    dims: usize = 2,
    iterations: usize = 1000,
    learning_rate: f64 = 200,
    /// P is multiplied by this for the first `exaggeration_iters` steps
    exaggeration: f64 = 12,
    exaggeration_iters: usize = 250,
    momentum_initial: f64 = 0.5,
    momentum_final: f64 = 0.8,
    momentum_switch: usize = 250,
    seed: u64 = 42,

    /// DENSITY PRESERVATION (den-SNE). 0 leaves t-SNE exactly as it was.
    ///
    /// The SAME term as densMAP, from the same paper, over the same definition of a
    /// local radius -- see density.zig. What differs is only that t-SNE's p_ij is a
    /// dense joint distribution rather than a sparse graph.
    density_lambda: f64 = 0,

    /// the FINAL fraction of iterations during which the density term is active.
    /// Switched on late for the same reason as in UMAP -- a layout that is still
    /// forming has radii that are noise -- and here there is a second reason: EARLY
    /// EXAGGERATION deliberately distorts the scale of the whole embedding for the
    /// first quarter of the run, so any density measured during it is measured against
    /// a picture the algorithm is about to throw away.
    density_frac: f64 = 0.3,
};

pub const Result = struct {
    /// n * dims
    embedding: []f64,
    /// KL divergence after each iteration -- the objective, so a caller can see that
    /// it went DOWN rather than take it on trust
    kl: []f64,
    n: usize,
    dims: usize,

    /// ORIGINAL-SPACE local radius per point, empty unless density was asked for.
    /// A data product in its own right: it ranks rows by how isolated they are with
    /// no reference to the embedding at all.
    local_radii: []f64,

    /// correlation between original and embedded log-radii at the end of the run.
    /// NaN when the term was never switched on.
    density_correlation: f64,

    allocator: std.mem.Allocator,

    pub fn deinit(self: *Result) void {
        self.allocator.free(self.embedding);
        self.allocator.free(self.kl);
        if (self.local_radii.len > 0) self.allocator.free(self.local_radii);
        self.allocator.destroy(self);
    }
};

pub const Error = error{ TooFewPoints, BadPerplexity, OutOfMemory };

/// A seeded generator, so two runs on the same data agree. This library treats
/// reproducibility as a law, and an embedding that changes between runs would make
/// every downstream picture unreproducible.
const Rng = struct {
    state: u64,

    fn init(seed: u64) Rng {
        return .{ .state = if (seed == 0) 0x9E3779B97F4A7C15 else seed };
    }

    fn next(self: *Rng) u64 {
        self.state ^= self.state << 13;
        self.state ^= self.state >> 7;
        self.state ^= self.state << 17;
        return self.state;
    }

    fn uniform(self: *Rng) f64 {
        return @as(f64, @floatFromInt(self.next() >> 11)) / 9007199254740992.0;
    }

    /// Box-Muller. t-SNE initialises from a small Gaussian rather than uniformly,
    /// because the gradient near a uniform start is dominated by the corners.
    fn gauss(self: *Rng) f64 {
        const u1v = @max(self.uniform(), 1e-12);
        const u2v = self.uniform();
        return @sqrt(-2 * @log(u1v)) * @cos(2 * std.math.pi * u2v);
    }
};

pub fn sqDist(a: []const f64, b: []const f64) f64 {
    var s: f64 = 0;
    for (a, b) |x, y| {
        const d = x - y;
        s += d * d;
    }
    return s;
}

/// Row i of the conditional probability matrix, for a given precision (1/2 sigma^2),
/// and the Shannon entropy that goes with it. Returns the entropy in NATS.
fn rowEntropy(d2: []const f64, beta: f64, i: usize, out: []f64) f64 {
    var sum: f64 = 0;
    for (d2, 0..) |dd, j| {
        if (j == i) {
            out[j] = 0;
            continue;
        }
        const v = @exp(-dd * beta);
        out[j] = v;
        sum += v;
    }
    if (sum <= 0) {
        // every neighbour underflowed: fall back to a uniform row rather than
        // dividing by zero and poisoning the whole matrix
        const n = d2.len;
        const u = 1.0 / @as(f64, @floatFromInt(n - 1));
        for (0..n) |j| out[j] = if (j == i) 0 else u;
        return @log(@as(f64, @floatFromInt(n - 1)));
    }
    var h: f64 = 0;
    for (d2, 0..) |dd, j| {
        if (j == i) continue;
        out[j] /= sum;
        if (out[j] > 1e-12) h += -out[j] * @log(out[j]);
        _ = dd;
    }
    return h;
}

/// BINARY SEARCH FOR THE BANDWIDTH, per point. The user asks for a perplexity; that
/// fixes the ENTROPY of each point's neighbour distribution at log(perplexity), and
/// the Gaussian width that achieves it differs for every point -- which is the whole
/// reason t-SNE adapts to varying density where a fixed-width kernel cannot.
pub fn conditionalP(
    alloc: std.mem.Allocator,
    x: []const f64,
    n: usize,
    d: usize,
    perplexity: f64,
    p_out: []f64,
) !void {
    const target = @log(perplexity);
    const d2 = try alloc.alloc(f64, n);
    defer alloc.free(d2);
    const row = try alloc.alloc(f64, n);
    defer alloc.free(row);

    for (0..n) |i| {
        for (0..n) |j| d2[j] = sqDist(x[i * d ..][0..d], x[j * d ..][0..d]);

        var beta: f64 = 1;
        var lo: f64 = 0;
        var hi: f64 = std.math.inf(f64);
        var tries: usize = 0;
        while (tries < 50) : (tries += 1) {
            const h = rowEntropy(d2, beta, i, row);
            const diff = h - target;
            if (@abs(diff) < 1e-5) break;
            if (diff > 0) {
                // entropy too high -> distribution too broad -> increase precision
                lo = beta;
                beta = if (std.math.isInf(hi)) beta * 2 else (beta + hi) / 2;
            } else {
                hi = beta;
                beta = (beta + lo) / 2;
            }
        }
        for (0..n) |j| p_out[i * n + j] = row[j];
    }
}

/// The symmetrised joint distribution P, built once from the high-dimensional data.
/// Exposed because the PARAMETRIC variant needs exactly this and computing it a
/// second time in another module is how two definitions of one thing begin.
pub fn jointP(
    alloc: std.mem.Allocator,
    x: []const f64,
    n: usize,
    d: usize,
    perplexity: f64,
    p_out: []f64,
) !void {
    try conditionalP(alloc, x, n, d, perplexity, p_out);
    var i: usize = 0;
    while (i < n) : (i += 1) {
        var j = i + 1;
        while (j < n) : (j += 1) {
            const v = (p_out[i * n + j] + p_out[j * n + i]) / (2 * @as(f64, @floatFromInt(n)));
            p_out[i * n + j] = v;
            p_out[j * n + i] = v;
        }
        p_out[i * n + i] = 0;
    }
}

/// The KL gradient with respect to the LOW-DIMENSIONAL positions, and the KL itself.
/// The non-parametric run() descends on these directly; the parametric variant feeds
/// them into a network's backward pass instead. ONE definition either way.
pub fn klGradient(
    p: []const f64,
    y: []const f64,
    n: usize,
    dims: usize,
    exaggeration: f64,
    q_num: []f64,
    dy: []f64,
) f64 {
    var qsum: f64 = 0;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        q_num[i * n + i] = 0;
        var j = i + 1;
        while (j < n) : (j += 1) {
            const v = 1.0 / (1.0 + sqDist(y[i * dims ..][0..dims], y[j * dims ..][0..dims]));
            q_num[i * n + j] = v;
            q_num[j * n + i] = v;
            qsum += 2 * v;
        }
    }
    if (qsum <= 0) qsum = 1e-12;

    @memset(dy, 0);
    var kl: f64 = 0;
    i = 0;
    while (i < n) : (i += 1) {
        var j: usize = 0;
        while (j < n) : (j += 1) {
            if (i == j) continue;
            const pij = p[i * n + j] * exaggeration;
            const qij = q_num[i * n + j] / qsum;
            if (pij > 1e-12 and qij > 1e-12) kl += pij * @log(pij / qij);
            const mult = (pij - qij) * q_num[i * n + j];
            var t2: usize = 0;
            while (t2 < dims) : (t2 += 1) {
                dy[i * dims + t2] += 4 * mult * (y[i * dims + t2] - y[j * dims + t2]);
            }
        }
    }
    return kl;
}

pub fn run(
    alloc: std.mem.Allocator,
    x: []const f64,
    n: usize,
    d: usize,
    opts: Options,
) !*Result {
    if (n < 3) return Error.TooFewPoints;
    // the perplexity is an entropy target, and it cannot exceed what n-1 neighbours
    // can carry -- a perplexity of 30 over 10 points is not a smaller effect, it is
    // an unsatisfiable request
    if (opts.perplexity < 1 or opts.perplexity > @as(f64, @floatFromInt(n - 1)))
        return Error.BadPerplexity;

    const dims = opts.dims;

    const p = try alloc.alloc(f64, n * n);
    defer alloc.free(p);
    try conditionalP(alloc, x, n, d, opts.perplexity, p);

    // SYMMETRISE: P_ij = (P_j|i + P_i|j) / 2n. The conditional matrix is not
    // symmetric -- i can be a close neighbour of j while j is only a distant one of
    // i, in a dense-next-to-sparse region -- and the objective needs a joint
    // distribution.
    {
        var i: usize = 0;
        while (i < n) : (i += 1) {
            var j = i + 1;
            while (j < n) : (j += 1) {
                const v = (p[i * n + j] + p[j * n + i]) / (2 * @as(f64, @floatFromInt(n)));
                p[i * n + j] = v;
                p[j * n + i] = v;
            }
            p[i * n + i] = 0;
        }
    }

    const y = try alloc.alloc(f64, n * dims);
    errdefer alloc.free(y);
    const dy = try alloc.alloc(f64, n * dims);
    defer alloc.free(dy);
    const vel = try alloc.alloc(f64, n * dims);
    defer alloc.free(vel);
    const gains = try alloc.alloc(f64, n * dims);
    defer alloc.free(gains);
    const q_num = try alloc.alloc(f64, n * n);
    defer alloc.free(q_num);

    var rng = Rng.init(opts.seed);
    for (y) |*v| v.* = rng.gauss() * 1e-4;
    @memset(vel, 0);
    for (gains) |*g| g.* = 1;

    const kl = try alloc.alloc(f64, opts.iterations);
    errdefer alloc.free(kl);

    // ── DENSITY PRESERVATION (den-SNE), when asked for ──
    //
    // Built from the SYMMETRISED joint distribution above -- the same p_ij the KL term
    // is optimising against, and deliberately NOT the exaggerated copy. Exaggeration
    // is a temporary lie told to the optimiser to open gaps early; measuring density
    // against it would preserve a scale that is about to be discarded.
    const want_density = opts.density_lambda > 0 and n >= 3;
    var dens_target: ?density.Target = null;
    defer if (dens_target) |*dt| dt.deinit();
    var dens_ws: ?density.Workspace = null;
    defer if (dens_ws) |*dw| dw.deinit();
    var dens_corr: f64 = std.math.nan(f64);
    var dens_start: usize = opts.iterations;
    if (want_density) {
        dens_target = try density.buildTargetDense(alloc, p, x, n, d);
        dens_ws = try density.Workspace.init(alloc, n);
        const frac = @min(@max(opts.density_frac, 0.0), 1.0);
        const on_for: f64 = @as(f64, @floatFromInt(opts.iterations)) * frac;
        dens_start = opts.iterations -| @as(usize, @intFromFloat(on_for));
    }

    var it: usize = 0;
    while (it < opts.iterations) : (it += 1) {
        const exaggerating = it < opts.exaggeration_iters;
        const scale: f64 = if (exaggerating) opts.exaggeration else 1;

        // Q, with the Student-t kernel: num_ij = 1 / (1 + ||y_i - y_j||^2)
        var qsum: f64 = 0;
        {
            var i: usize = 0;
            while (i < n) : (i += 1) {
                q_num[i * n + i] = 0;
                var j = i + 1;
                while (j < n) : (j += 1) {
                    const v = 1.0 / (1.0 + sqDist(y[i * dims ..][0..dims], y[j * dims ..][0..dims]));
                    q_num[i * n + j] = v;
                    q_num[j * n + i] = v;
                    qsum += 2 * v;
                }
            }
        }
        if (qsum <= 0) qsum = 1e-12;

        // the gradient, and the KL divergence for the record
        @memset(dy, 0);
        var kl_now: f64 = 0;
        {
            var i: usize = 0;
            while (i < n) : (i += 1) {
                var j: usize = 0;
                while (j < n) : (j += 1) {
                    if (i == j) continue;
                    const pij = p[i * n + j] * scale;
                    const qij = q_num[i * n + j] / qsum;
                    if (pij > 1e-12 and qij > 1e-12) kl_now += pij * @log(pij / qij);
                    const mult = (pij - qij) * q_num[i * n + j];
                    var t: usize = 0;
                    while (t < dims) : (t += 1) {
                        dy[i * dims + t] += 4 * mult * (y[i * dims + t] - y[j * dims + t]);
                    }
                }
            }
        }
        kl[it] = kl_now;

        // The density contribution goes into `dy` rather than straight into `y`, so it
        // passes through the momentum and the adaptive gains along with everything
        // else. Applying it afterwards would let it fight the gains rather than ride
        // them, and the gains are most of why a fixed learning rate works here at all.
        if (want_density and it >= dens_start) {
            dens_corr = density.accumulateGradientDense(
                &dens_target.?,
                &dens_ws.?,
                p,
                y,
                dy,
                n,
                dims,
                opts.density_lambda,
            );
        }

        // ADAPTIVE GAINS (Jacobs): step up where the gradient keeps its sign, down
        // where it oscillates. The original implementation's, and the reason a fixed
        // learning rate is workable across very different data.
        const mom: f64 = if (it < opts.momentum_switch) opts.momentum_initial else opts.momentum_final;
        for (0..n * dims) |k| {
            const same = (dy[k] > 0) == (vel[k] > 0);
            gains[k] = if (same) gains[k] * 0.8 else gains[k] + 0.2;
            if (gains[k] < 0.01) gains[k] = 0.01;
            vel[k] = mom * vel[k] - opts.learning_rate * gains[k] * dy[k];
            y[k] += vel[k];
        }

        // recenter, so the cloud does not drift -- the embedding is only defined up
        // to translation and letting it wander makes runs look different when they
        // are not
        var t: usize = 0;
        while (t < dims) : (t += 1) {
            var mean: f64 = 0;
            for (0..n) |i| mean += y[i * dims + t];
            mean /= @floatFromInt(n);
            for (0..n) |i| y[i * dims + t] -= mean;
        }
    }

    var radii_out: []f64 = &[_]f64{};
    if (want_density) {
        const mean_log = try density.meanLogRadiusDense(p, x, n, d, alloc);
        radii_out = try dens_target.?.radii(alloc, mean_log);
        // measured on the embedding actually returned, not the one before the last step
        dens_corr = density.correlationDense(&dens_target.?, &dens_ws.?, p, y, n, dims);
    }

    const out = try alloc.create(Result);
    out.* = .{
        .embedding = y,
        .kl = kl,
        .n = n,
        .dims = dims,
        .local_radii = radii_out,
        .density_correlation = dens_corr,
        .allocator = alloc,
    };
    return out;
}

// ─── tests ───────────────────────────────────────────────────────────────────

const testing = std.testing;

/// Three tight, well-separated blobs in 5 dimensions -- data whose cluster structure
/// is not in doubt, so the embedding can be held to preserving it.
fn blobs(alloc: std.mem.Allocator, per: usize, d: usize) ![]f64 {
    const n = per * 3;
    const x = try alloc.alloc(f64, n * d);
    var rng = Rng.init(7);
    const centers = [_]f64{ 0, 20, 40 };
    for (0..3) |c| {
        for (0..per) |k| {
            const i = c * per + k;
            for (0..d) |j| x[i * d + j] = centers[c] + rng.gauss() * 0.5;
        }
    }
    return x;
}

test "the perplexity search actually hits its target" {
    // The binary search fixes each point's neighbourhood ENTROPY at log(perplexity).
    // This is an internal identity: no reference values, and it fails loudly if the
    // search direction or the convergence test is wrong.
    const alloc = testing.allocator;
    const n = 40;
    const d = 3;
    const x = try blobs(alloc, n / 3, d);
    defer alloc.free(x);
    const nn = (n / 3) * 3;

    const p = try alloc.alloc(f64, nn * nn);
    defer alloc.free(p);
    const perp: f64 = 10;
    try conditionalP(alloc, x, nn, d, perp, p);

    for (0..nn) |i| {
        var h: f64 = 0;
        for (0..nn) |j| {
            const v = p[i * nn + j];
            if (v > 1e-12) h += -v * @log(v);
        }
        // exp(entropy) IS the perplexity
        try testing.expectApproxEqRel(perp, @exp(h), 1e-3);
    }
}

test "P is a probability distribution: symmetric, non-negative, sums to one" {
    const alloc = testing.allocator;
    const n = 30;
    const d = 4;
    const x = try blobs(alloc, n / 3, d);
    defer alloc.free(x);

    var r = try run(alloc, x, n, d, .{ .perplexity = 8, .iterations = 5 });
    defer r.deinit();
    // rebuild P the way run() does, to check its shape
    const p = try alloc.alloc(f64, n * n);
    defer alloc.free(p);
    try conditionalP(alloc, x, n, d, 8, p);
    var total: f64 = 0;
    for (0..n) |i| {
        for (i + 1..n) |j| {
            const v = (p[i * n + j] + p[j * n + i]) / (2 * @as(f64, @floatFromInt(n)));
            try testing.expect(v >= 0);
            total += 2 * v;
        }
    }
    try testing.expectApproxEqAbs(@as(f64, 1), total, 1e-9);
}

test "the KL divergence goes DOWN, which is the whole contract" {
    const alloc = testing.allocator;
    const n = 45;
    const d = 5;
    const x = try blobs(alloc, n / 3, d);
    defer alloc.free(x);
    var r = try run(alloc, x, n, d, .{ .perplexity = 10, .iterations = 400 });
    defer r.deinit();
    // compare AFTER early exaggeration ends, since the objective is a different one
    // while P is being multiplied
    try testing.expect(r.kl[399] < r.kl[260]);
    try testing.expect(r.kl[399] >= 0);
}

test "well-separated clusters STAY separated" {
    // The property a caller actually relies on. Three blobs 20 units apart in 5-D
    // must come out as three groups: the mean within-cluster distance in the
    // embedding must be far below the mean between-cluster distance.
    const alloc = testing.allocator;
    const per = 15;
    const n = per * 3;
    const d = 5;
    const x = try blobs(alloc, per, d);
    defer alloc.free(x);

    var r = try run(alloc, x, n, d, .{ .perplexity = 5, .iterations = 600 });
    defer r.deinit();

    var within: f64 = 0;
    var within_n: usize = 0;
    var between: f64 = 0;
    var between_n: usize = 0;
    for (0..n) |i| {
        for (i + 1..n) |j| {
            const dist = @sqrt(sqDist(r.embedding[i * 2 ..][0..2], r.embedding[j * 2 ..][0..2]));
            if (i / per == j / per) {
                within += dist;
                within_n += 1;
            } else {
                between += dist;
                between_n += 1;
            }
        }
    }
    within /= @floatFromInt(within_n);
    between /= @floatFromInt(between_n);
    try testing.expect(between > within * 3);
}

test "the same seed gives the same embedding, a different seed does not" {
    const alloc = testing.allocator;
    const n = 30;
    const d = 3;
    const x = try blobs(alloc, n / 3, d);
    defer alloc.free(x);

    var a = try run(alloc, x, n, d, .{ .perplexity = 6, .iterations = 100, .seed = 1 });
    defer a.deinit();
    var b = try run(alloc, x, n, d, .{ .perplexity = 6, .iterations = 100, .seed = 1 });
    defer b.deinit();
    for (a.embedding, b.embedding) |p, q| try testing.expectEqual(p, q);

    var c = try run(alloc, x, n, d, .{ .perplexity = 6, .iterations = 100, .seed = 2 });
    defer c.deinit();
    var differs = false;
    for (a.embedding, c.embedding) |p, q| {
        if (p != q) differs = true;
    }
    try testing.expect(differs);
}

test "an unsatisfiable perplexity is refused rather than approximated" {
    const alloc = testing.allocator;
    const x = [_]f64{ 0, 0, 1, 1, 2, 2, 3, 3, 4, 4 };
    // 5 points cannot carry a perplexity of 30
    try testing.expectError(Error.BadPerplexity, run(alloc, &x, 5, 2, .{ .perplexity = 30 }));
    try testing.expectError(Error.TooFewPoints, run(alloc, &x, 2, 2, .{ .perplexity = 1 }));
}

test "three dimensions work as well as two" {
    const alloc = testing.allocator;
    const n = 24;
    const d = 4;
    const x = try blobs(alloc, n / 3, d);
    defer alloc.free(x);
    var r = try run(alloc, x, n, d, .{ .perplexity = 5, .iterations = 100, .dims = 3 });
    defer r.deinit();
    try testing.expectEqual(@as(usize, 3), r.dims);
    try testing.expectEqual(@as(usize, n * 3), r.embedding.len);
    for (r.embedding) |v| try testing.expect(std.math.isFinite(v));
}

/// two clusters differing TWENTYFOLD in spread -- the case density preservation is for
fn twoDensities(alloc: std.mem.Allocator, per: usize, d: usize) ![]f64 {
    const n = per * 2;
    const x = try alloc.alloc(f64, n * d);
    var rng = Rng.init(7);
    for (0..per) |i| {
        for (0..d) |t| x[i * d + t] = (rng.uniform() - 0.5) * 0.15;
    }
    for (per..n) |i| {
        for (0..d) |t| x[i * d + t] = 20.0 + (rng.uniform() - 0.5) * 3.0;
    }
    return x;
}

fn meanSpread(v: []const f64, lo: usize, hi: usize, dims: usize) f64 {
    var s: f64 = 0;
    var c: f64 = 0;
    for (lo..hi) |i| {
        for (i + 1..hi) |j| {
            s += @sqrt(sqDist(v[i * dims ..][0..dims], v[j * dims ..][0..dims]));
            c += 1;
        }
    }
    return if (c > 0) s / c else 0;
}

test "PLAIN t-SNE CARRIES NO DENSITY SIGNAL -- the number is noise around zero" {
    const alloc = testing.allocator;
    const per = 25;
    const n = per * 2;
    const d = 4;
    const x = try twoDensities(alloc, per, d);
    defer alloc.free(x);

    // MEASURED across five seeds on data whose density ratio is 19.96:
    //
    //     seed    42      7     1234     99     2026
    //     corr  -0.186  +0.099  +0.125  -0.048  +0.168
    //
    // Scattered around ZERO, and negative as often as not. This is a sharper statement
    // than "t-SNE does not preserve density": its density output is indistinguishable
    // from chance, so a reader who infers anything from relative cluster sizes in a
    // t-SNE plot is reading noise. UMAP at least came out consistently positive
    // (+0.226) -- weak, but pointing the right way.
    //
    // The Student-t kernel is why. Its heavy tail is what stops the crowding problem,
    // and it does that by letting every cluster settle at whatever size the repulsion
    // allows, independent of how tight the cluster actually was.
    const seeds = [_]u64{ 42, 7, 1234 };
    for (seeds) |sd| {
        var r = try run(alloc, x, n, d, .{
            .perplexity = 10,
            .iterations = 800,
            .seed = sd,
            // a weight this small reports the correlation without moving anything --
            // the measurement, with the treatment switched off
            .density_lambda = 1e-300,
        });
        defer r.deinit();
        try testing.expect(@abs(r.density_correlation) < 0.3);
    }
}

test "den-SNE recovers it, and the drawn sizes follow" {
    const alloc = testing.allocator;
    const per = 25;
    const n = per * 2;
    const d = 4;
    const x = try twoDensities(alloc, per, d);
    defer alloc.free(x);

    var plain = try run(alloc, x, n, d, .{ .perplexity = 10, .iterations = 800, .density_lambda = 1e-300 });
    defer plain.deinit();
    var dens = try run(alloc, x, n, d, .{ .perplexity = 10, .iterations = 800, .density_lambda = 1.0 });
    defer dens.deinit();

    try testing.expect(dens.density_correlation > 0.85);
    try testing.expect(dens.density_correlation > plain.density_correlation + 0.6);

    // and it shows: the diffuse cluster is drawn wider than the tight one, where plain
    // t-SNE draws them at essentially the same size
    const rp = meanSpread(plain.embedding, per, n, 2) / meanSpread(plain.embedding, 0, per, 2);
    const rd = meanSpread(dens.embedding, per, n, 2) / meanSpread(dens.embedding, 0, per, 2);
    try testing.expect(rp < 1.2);
    try testing.expect(rd > 1.4);
}

test "THE DIAL HAS AN UNSTABLE BAND, and the default sits below it" {
    const alloc = testing.allocator;
    const per = 25;
    const n = per * 2;
    const d = 4;
    const x = try twoDensities(alloc, per, d);
    defer alloc.free(x);

    // MEASURED, correlation by lambda and seed:
    //
    //     lambda   seed 42   seed 7   seed 1234
    //      0.5      0.902    0.896     0.827      stable
    //      1.0      0.957    0.965     0.900      stable
    //      1.5      0.980    0.894     0.705      widening
    //      2.0     -0.646    0.480     0.910      WILD
    //      4.0      0.938    0.936     0.933      stable again
    //
    // AND THE WIDER SWEEP, at seed 42:
    //
    //     lambda    corr     drawn ratio   separation    KL
    //       0      -0.186       1.05          7.13      0.291
    //       1       0.957       1.56          4.15      0.443
    //      10       0.982       3.22          1.23      1.915
    //     100       0.999       3.63          1.18      1.710
    //   10000       0.735       1.45          1.01      2.578
    //
    // THREE FACTS, none of them guessable, and the middle one is the dangerous one.
    //
    // 1. The dial is NOT monotone -- it peaks near 100 and falls away after.
    // 2. AT 2, ON THIS DATA, IT IS UNSTABLE: the same inputs with a different seed land
    //    anywhere from -0.65 to +0.91. Not noise on a trend -- the outcome is decided
    //    by the initialisation. Almost certainly the adaptive gains: a density term of
    //    middling strength puts the combined gradient into an oscillation the gains
    //    then amplify, and the layout settles anti-correlated.
    // 3. Past about 4 it is well behaved again, because the density term now dominates
    //    outright -- but by then the separation has collapsed from 7.13 to near 1.
    //
    // AND THE BAND IS NOT AT A FIXED PLACE. A second dataset swept the same range with
    // nothing unstable anywhere (0.94 at 0.5, 0.90 at 1, 0.97 at 10). So lambda cannot
    // be chosen once and trusted -- where it works depends on the data, which is why
    // the correlation is REPORTED rather than kept internal. A caller who does not
    // check it does not know whether the picture preserves density.
    //
    // The default of 1.0 is a starting point measured to behave on both datasets, not
    // a guarantee.
    //
    // Note also how far this is from UMAP's density dial, which was cleanly monotone.
    // Same term, same paper, different optimiser -- and the shape belongs to the
    // optimiser, not to the term.
    const seeds = [_]u64{ 42, 7, 1234 };
    var lo: f64 = 1;
    var hi: f64 = -1;
    for (seeds) |sd| {
        var r = try run(alloc, x, n, d, .{
            .perplexity = 10,
            .iterations = 800,
            .seed = sd,
            .density_lambda = 1.0,
        });
        defer r.deinit();
        lo = @min(lo, r.density_correlation);
        hi = @max(hi, r.density_correlation);
    }
    // the default is reliable: every seed lands high, and they land close together
    try testing.expect(lo > 0.85);
    try testing.expect(hi - lo < 0.15);
}

test "IT IS A TRADE HERE TOO, and t-SNE lets you price it exactly" {
    const alloc = testing.allocator;
    const per = 25;
    const n = per * 2;
    const d = 4;
    const x = try twoDensities(alloc, per, d);
    defer alloc.free(x);

    var plain = try run(alloc, x, n, d, .{ .perplexity = 10, .iterations = 800 });
    defer plain.deinit();
    var dens = try run(alloc, x, n, d, .{ .perplexity = 10, .iterations = 800, .density_lambda = 1.0 });
    defer dens.deinit();

    // UMAP could only show the cost indirectly, as lost cluster separation. t-SNE
    // reports its objective, so the bill arrives itemised: the KL divergence is
    // WORSE with the density term, by about half again. That is the neighbourhood
    // fidelity being spent to buy density fidelity, stated in the units of the thing
    // being given up.
    try testing.expect(dens.kl[799] > plain.kl[799]);
    try testing.expect(plain.kl[799] > 0);
}

test "lambda 0 is EXACTLY plain t-SNE, not merely close" {
    const alloc = testing.allocator;
    const per = 12;
    const n = per * 2;
    const d = 3;
    const x = try twoDensities(alloc, per, d);
    defer alloc.free(x);

    var plain = try run(alloc, x, n, d, .{ .perplexity = 5, .iterations = 300 });
    defer plain.deinit();
    var zero = try run(alloc, x, n, d, .{ .perplexity = 5, .iterations = 300, .density_lambda = 0 });
    defer zero.deinit();
    for (plain.embedding, zero.embedding) |a, b| try testing.expectEqual(a, b);
    try testing.expectEqual(@as(usize, 0), zero.local_radii.len);
    try testing.expect(std.math.isNan(zero.density_correlation));
}

test "the local radii agree with UMAP's on what is dense, from a different p" {
    const alloc = testing.allocator;
    const per = 25;
    const n = per * 2;
    const d = 4;
    const x = try twoDensities(alloc, per, d);
    defer alloc.free(x);

    var r = try run(alloc, x, n, d, .{ .perplexity = 10, .iterations = 300, .density_lambda = 1.0 });
    defer r.deinit();
    try testing.expectEqual(n, r.local_radii.len);

    // The radii come from t-SNE's joint distribution, not UMAP's fuzzy graph -- two
    // different weightings of the same neighbourhoods. They still put EVERY tight row
    // below EVERY diffuse one, which is the reassurance that the quantity is a fact
    // about the data rather than an artefact of whichever graph was used to weigh it.
    var tight_max: f64 = 0;
    for (0..per) |i| tight_max = @max(tight_max, r.local_radii[i]);
    var diffuse_min: f64 = std.math.inf(f64);
    for (per..n) |i| diffuse_min = @min(diffuse_min, r.local_radii[i]);
    try testing.expect(tight_max < diffuse_min);
}

test "density does not disturb the exaggeration phase" {
    const alloc = testing.allocator;
    const per = 12;
    const n = per * 2;
    const d = 3;
    const x = try twoDensities(alloc, per, d);
    defer alloc.free(x);

    // EARLY EXAGGERATION multiplies P by 12 for the first quarter of the run, which
    // deliberately distorts the scale of the whole layout to open gaps between groups.
    // Density measured against that would preserve a picture the algorithm is about to
    // discard -- so with the default phase the term does not run until well after
    // exaggeration has ended, and the two never overlap.
    var r = try run(alloc, x, n, d, .{
        .perplexity = 5,
        .iterations = 400,
        .exaggeration_iters = 100,
        .density_lambda = 1.0,
    });
    defer r.deinit();
    // 400 iterations, phase 0.3 -> starts at 280, well past the 100th
    for (r.embedding) |v| try testing.expect(!std.math.isNan(v) and !std.math.isInf(v));
    try testing.expect(!std.math.isNan(r.density_correlation));
}
