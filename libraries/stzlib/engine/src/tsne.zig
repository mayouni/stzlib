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
};

pub const Result = struct {
    /// n * dims
    embedding: []f64,
    /// KL divergence after each iteration -- the objective, so a caller can see that
    /// it went DOWN rather than take it on trust
    kl: []f64,
    n: usize,
    dims: usize,
    allocator: std.mem.Allocator,

    pub fn deinit(self: *Result) void {
        self.allocator.free(self.embedding);
        self.allocator.free(self.kl);
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

fn sqDist(a: []const f64, b: []const f64) f64 {
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
fn conditionalP(
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

    const out = try alloc.create(Result);
    out.* = .{ .embedding = y, .kl = kl, .n = n, .dims = dims, .allocator = alloc };
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
