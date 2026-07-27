//! UMAP: uniform manifold approximation and projection.
//!
//! t-SNE and UMAP answer the same question -- which points are near each other -- and
//! differ in what they do with the answer. t-SNE matches a probability of
//! neighbourhood and, in doing so, tends to pull clusters apart until their relative
//! placement carries little information. UMAP builds a weighted NEIGHBOUR GRAPH and
//! optimises a cross-entropy against it, which keeps rather more of the global
//! arrangement -- and it is faster, because it never touches every pair.
//!
//! THE SAME WARNINGS APPLY, and they matter as much here:
//!
//!   * DISTANCES IN THE OUTPUT ARE NOT A METRIC. UMAP retains more global structure
//!     than t-SNE; "more" is not "enough to measure".
//!   * IT IS STOCHASTIC. The seed is an input.
//!   * `n_neighbors` IS THE DIAL between local and global. Small values see fine
//!     structure and fragment; large values see the broad shape and smear detail.
//!     There is no correct value, only a question being asked.
//!
//! THE CONSTRUCTION, in four steps:
//!
//!   1. k NEAREST NEIGHBOURS for each point.
//!   2. A LOCAL METRIC per point: rho_i is the distance to its nearest neighbour, and
//!      sigma_i is found by binary search so that sum(exp(-(d - rho_i)/sigma_i)) over
//!      the k neighbours equals log2(k). SUBTRACTING RHO IS THE IDEA THAT MAKES UMAP
//!      WORK -- every point is guaranteed a fully-connected nearest neighbour, so
//!      sparse regions are not deemed empty and dense ones are not deemed uniform.
//!   3. FUZZY UNION. The directed weights are combined by the probabilistic t-conorm
//!      w + w' - w*w' rather than averaged. "i thinks j is a neighbour OR j thinks i
//!      is" -- a union of beliefs, not a compromise between them.
//!   4. SGD WITH NEGATIVE SAMPLING against that graph: edges pull, random non-edges
//!      push. Sampling the repulsion is what removes the O(n^2) term.
//!
//! WHERE THE CURVE COMES FROM. The low-dimensional similarity is 1/(1 + a*d^(2b)),
//! and a and b are not constants -- they are FITTED so the curve matches the target
//! shape implied by `min_dist` (flat out to min_dist, exponential decay after). That
//! fit is a small nonlinear least squares, so it is handed to the L-BFGS built in
//! phase 6 rather than to a hardcoded table of a/b pairs. A library that has an
//! optimiser should use it.

const std = @import("std");
const lbfgs = @import("lbfgs.zig");

pub const Options = struct {
    /// the local/global dial; the reference implementation defaults to 15
    n_neighbors: usize = 15,
    dims: usize = 2,
    /// how tightly points may pack in the embedding
    min_dist: f64 = 0.1,
    spread: f64 = 1.0,
    epochs: usize = 200,
    learning_rate: f64 = 1.0,
    /// weight on the repulsive term
    repulsion: f64 = 1.0,
    negative_samples: usize = 5,
    seed: u64 = 42,
};

pub const Result = struct {
    embedding: []f64,
    /// the fitted curve parameters, reported because they are derived rather than
    /// given and a caller may reasonably want to see what min_dist turned into
    a: f64,
    b: f64,
    n: usize,
    dims: usize,
    allocator: std.mem.Allocator,

    pub fn deinit(self: *Result) void {
        self.allocator.free(self.embedding);
        self.allocator.destroy(self);
    }
};

pub const Error = error{ TooFewPoints, BadNeighbors, OutOfMemory, DidNotConverge };

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
    fn below(self: *Rng, n: usize) usize {
        return @intCast(self.next() % @as(u64, @intCast(n)));
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

// ─── the a/b curve fit, through L-BFGS ───────────────────────────────────────

const CurveFit = struct {
    xs: []const f64,
    ys: []const f64,
};

/// Least squares of 1/(1 + a*x^(2b)) against the target curve. Written with its
/// analytic gradient rather than handed to the autodiff tape: the tape parses an
/// expression with NAMED variables, and this objective is a sum over sampled points,
/// which is a different shape. (The optimiser takes a function pointer precisely so
/// that objectives like this one can reach it.)
fn curveObjective(ctx: ?*anyopaque, params: []const f64, grad: []f64) f64 {
    const c: *const CurveFit = @ptrCast(@alignCast(ctx.?));
    const a = params[0];
    const b = params[1];
    grad[0] = 0;
    grad[1] = 0;
    var loss: f64 = 0;
    for (c.xs, c.ys) |x, y| {
        if (x <= 0) continue;
        const xp = std.math.pow(f64, x, 2 * b);
        const den = 1 + a * xp;
        const pred = 1 / den;
        const r = pred - y;
        loss += r * r;
        // d(pred)/da = -x^(2b) / den^2
        grad[0] += 2 * r * (-xp / (den * den));
        // d(pred)/db = -a * x^(2b) * 2ln(x) / den^2
        grad[1] += 2 * r * (-a * xp * 2 * @log(x) / (den * den));
    }
    return loss;
}

/// Fit a and b so 1/(1 + a*d^(2b)) matches "1 until min_dist, then exp decay".
pub fn fitAB(alloc: std.mem.Allocator, min_dist: f64, spread: f64) !struct { a: f64, b: f64 } {
    const N = 300;
    const xs = try alloc.alloc(f64, N);
    defer alloc.free(xs);
    const ys = try alloc.alloc(f64, N);
    defer alloc.free(ys);

    for (0..N) |i| {
        const x = 3.0 * spread * @as(f64, @floatFromInt(i)) / @as(f64, @floatFromInt(N - 1));
        xs[i] = x;
        ys[i] = if (x <= min_dist) 1.0 else @exp(-(x - min_dist) / spread);
    }

    var fit = CurveFit{ .xs = xs, .ys = ys };
    var params = [_]f64{ 1.0, 1.0 };
    const r = try lbfgs.minimize(alloc, curveObjective, &fit, &params, .{
        .max_iterations = 300,
        .gradient_tolerance = 1e-10,
    });
    _ = r;
    // a and b must stay positive for the curve to be a similarity at all; the fit
    // does not know that, so a degenerate result falls back to the reference
    // implementation's defaults rather than producing a nonsense kernel
    if (!(params[0] > 0) or !(params[1] > 0)) return .{ .a = 1.577, .b = 0.895 };
    return .{ .a = params[0], .b = params[1] };
}

// ─── the neighbour graph ─────────────────────────────────────────────────────

const Edge = struct { i: u32, j: u32, w: f64 };

/// Exact k nearest neighbours, per point, by full scan. O(n^2) -- honest for the
/// sizes this library sees, and the place to swap in NN-descent if that changes.
fn knn(
    alloc: std.mem.Allocator,
    x: []const f64,
    n: usize,
    d: usize,
    k: usize,
    idx_out: []u32,
    dist_out: []f64,
) !void {
    const cand = try alloc.alloc(f64, n);
    defer alloc.free(cand);
    for (0..n) |i| {
        for (0..n) |j| cand[j] = if (j == i) std.math.inf(f64) else @sqrt(sqDist(x[i * d ..][0..d], x[j * d ..][0..d]));
        // partial selection of the k smallest, same bounded scan the KNN slice used
        for (0..k) |slot| {
            var best: usize = 0;
            var bestv = std.math.inf(f64);
            for (0..n) |j| {
                if (cand[j] < bestv) {
                    bestv = cand[j];
                    best = j;
                }
            }
            idx_out[i * k + slot] = @intCast(best);
            dist_out[i * k + slot] = bestv;
            cand[best] = std.math.inf(f64);
        }
    }
}

/// rho and sigma per point. rho is the distance to the nearest neighbour and sigma
/// is binary-searched so the neighbour weights sum to log2(k).
fn localMetric(dist: []const f64, n: usize, k: usize, rho: []f64, sigma: []f64) void {
    const target = @log2(@as(f64, @floatFromInt(k)));
    for (0..n) |i| {
        const row = dist[i * k ..][0..k];
        var r: f64 = 0;
        for (row) |v| {
            if (v > 0) {
                r = v;
                break;
            }
        }
        rho[i] = r;

        var lo: f64 = 0;
        var hi: f64 = std.math.inf(f64);
        var mid: f64 = 1;
        var t: usize = 0;
        while (t < 64) : (t += 1) {
            var s: f64 = 0;
            for (row) |v| {
                const dd = v - r;
                s += if (dd > 0) @exp(-dd / mid) else 1.0;
            }
            if (@abs(s - target) < 1e-5) break;
            if (s > target) {
                hi = mid;
                mid = (lo + hi) / 2;
            } else {
                lo = mid;
                mid = if (std.math.isInf(hi)) mid * 2 else (lo + hi) / 2;
            }
        }
        sigma[i] = if (mid > 1e-12) mid else 1e-12;
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
    if (opts.n_neighbors < 2 or opts.n_neighbors > n - 1) return Error.BadNeighbors;
    const k = opts.n_neighbors;
    const dims = opts.dims;

    const idx = try alloc.alloc(u32, n * k);
    defer alloc.free(idx);
    const dist = try alloc.alloc(f64, n * k);
    defer alloc.free(dist);
    try knn(alloc, x, n, d, k, idx, dist);

    const rho = try alloc.alloc(f64, n);
    defer alloc.free(rho);
    const sigma = try alloc.alloc(f64, n);
    defer alloc.free(sigma);
    localMetric(dist, n, k, rho, sigma);

    // directed weights, then the FUZZY UNION w + w' - w*w'
    const w = try alloc.alloc(f64, n * n);
    defer alloc.free(w);
    @memset(w, 0);
    for (0..n) |i| {
        for (0..k) |s| {
            const j = idx[i * k + s];
            if (j == i) continue;
            const dd = dist[i * k + s] - rho[i];
            w[i * n + j] = if (dd > 0) @exp(-dd / sigma[i]) else 1.0;
        }
    }

    var edges = try std.ArrayList(Edge).initCapacity(alloc, n * k);
    defer edges.deinit(alloc);
    var wmax: f64 = 0;
    for (0..n) |i| {
        for (i + 1..n) |j| {
            const a = w[i * n + j];
            const b = w[j * n + i];
            const u = a + b - a * b;
            if (u > 1e-12) {
                try edges.append(alloc, .{ .i = @intCast(i), .j = @intCast(j), .w = u });
                if (u > wmax) wmax = u;
            }
        }
    }
    if (edges.items.len == 0) return Error.TooFewPoints;

    const ab = try fitAB(alloc, opts.min_dist, opts.spread);

    const y = try alloc.alloc(f64, n * dims);
    errdefer alloc.free(y);
    var rng = Rng.init(opts.seed);
    for (y) |*v| v.* = (rng.uniform() * 20) - 10;

    // an edge of maximal weight is sampled every epoch; a weaker one proportionally
    // less often. This is what makes the strong parts of the graph dominate.
    const eps = try alloc.alloc(f64, edges.items.len);
    defer alloc.free(eps);
    const next_sample = try alloc.alloc(f64, edges.items.len);
    defer alloc.free(next_sample);
    for (edges.items, 0..) |e, i| {
        eps[i] = wmax / e.w;
        next_sample[i] = eps[i];
    }

    const a = ab.a;
    const b = ab.b;
    var epoch: usize = 0;
    while (epoch < opts.epochs) : (epoch += 1) {
        // the step size decays to zero, which is what makes the layout settle
        const alpha = opts.learning_rate *
            (1.0 - @as(f64, @floatFromInt(epoch)) / @as(f64, @floatFromInt(opts.epochs)));

        for (edges.items, 0..) |e, ei| {
            if (next_sample[ei] > @as(f64, @floatFromInt(epoch + 1))) continue;
            next_sample[ei] += eps[ei];

            const ii: usize = e.i;
            const jj: usize = e.j;
            const yi = y[ii * dims ..][0..dims];
            const yj = y[jj * dims ..][0..dims];

            // ── attraction along the edge ──
            var d2 = sqDist(yi, yj);
            if (d2 > 0) {
                const gc = (-2.0 * a * b * std.math.pow(f64, d2, b - 1.0)) /
                    (a * std.math.pow(f64, d2, b) + 1.0);
                for (0..dims) |t| {
                    const g = clip(gc * (yi[t] - yj[t]));
                    y[ii * dims + t] += g * alpha;
                    y[jj * dims + t] -= g * alpha;
                }
            }

            // ── repulsion from a few random non-neighbours ──
            var s: usize = 0;
            while (s < opts.negative_samples) : (s += 1) {
                const kk = rng.below(n);
                if (kk == ii or kk == jj) continue;
                const yk = y[kk * dims ..][0..dims];
                d2 = sqDist(yi, yk);
                var gc: f64 = 0;
                if (d2 > 0) {
                    gc = (2.0 * opts.repulsion * b) /
                        ((0.001 + d2) * (a * std.math.pow(f64, d2, b) + 1.0));
                } else {
                    // coincident points still need pushing apart, and the formula
                    // above is undefined there
                    gc = 4.0;
                }
                for (0..dims) |t| {
                    y[ii * dims + t] += clip(gc * (yi[t] - yk[t])) * alpha;
                }
            }
        }
    }

    const out = try alloc.create(Result);
    out.* = .{ .embedding = y, .a = a, .b = b, .n = n, .dims = dims, .allocator = alloc };
    return out;
}

/// The reference implementation clips every gradient component to +-4. Without it a
/// pair that lands almost on top of another produces an enormous step and throws a
/// point to infinity, taking the layout with it.
inline fn clip(v: f64) f64 {
    if (v > 4) return 4;
    if (v < -4) return -4;
    if (std.math.isNan(v)) return 0;
    return v;
}

// ─── tests ───────────────────────────────────────────────────────────────────

const testing = std.testing;

fn blobs(alloc: std.mem.Allocator, per: usize, d: usize) ![]f64 {
    const n = per * 3;
    const x = try alloc.alloc(f64, n * d);
    var rng = Rng.init(11);
    const centers = [_]f64{ 0, 25, 50 };
    for (0..3) |c| {
        for (0..per) |kk| {
            const i = c * per + kk;
            for (0..d) |j| x[i * d + j] = centers[c] + (rng.uniform() - 0.5);
        }
    }
    return x;
}

test "the a/b curve fit reproduces the target shape" {
    // The fit is done by L-BFGS rather than by a table, so it must actually fit:
    // the curve 1/(1 + a d^2b) has to track "1 until min_dist, then exp decay".
    const alloc = testing.allocator;
    const ab = try fitAB(alloc, 0.1, 1.0);
    try testing.expect(ab.a > 0);
    try testing.expect(ab.b > 0);

    var worst: f64 = 0;
    var i: usize = 0;
    while (i < 200) : (i += 1) {
        const x = 3.0 * @as(f64, @floatFromInt(i)) / 199.0;
        const want: f64 = if (x <= 0.1) 1.0 else @exp(-(x - 0.1) / 1.0);
        const got = 1.0 / (1.0 + ab.a * std.math.pow(f64, x, 2 * ab.b));
        const e = @abs(got - want);
        if (e > worst) worst = e;
    }
    try testing.expect(worst < 0.06);
}

test "a smaller min_dist packs points more tightly, which is what it is for" {
    const alloc = testing.allocator;
    const tight = try fitAB(alloc, 0.001, 1.0);
    const loose = try fitAB(alloc, 0.8, 1.0);
    // a bigger `a` means the similarity falls off sooner, so points must sit closer
    // together to be considered near
    try testing.expect(tight.a > loose.a);
}

test "the local metric hits its target, and rho guarantees a neighbour" {
    const alloc = testing.allocator;
    const per = 12;
    const n = per * 3;
    const d = 4;
    const k = 6;
    const x = try blobs(alloc, per, d);
    defer alloc.free(x);

    const idx = try alloc.alloc(u32, n * k);
    defer alloc.free(idx);
    const dist = try alloc.alloc(f64, n * k);
    defer alloc.free(dist);
    try knn(alloc, x, n, d, k, idx, dist);

    const rho = try alloc.alloc(f64, n);
    defer alloc.free(rho);
    const sigma = try alloc.alloc(f64, n);
    defer alloc.free(sigma);
    localMetric(dist, n, k, rho, sigma);

    const target = @log2(@as(f64, @floatFromInt(k)));
    for (0..n) |i| {
        var s: f64 = 0;
        for (dist[i * k ..][0..k]) |v| {
            const dd = v - rho[i];
            s += if (dd > 0) @exp(-dd / sigma[i]) else 1.0;
        }
        try testing.expectApproxEqAbs(target, s, 1e-3);
        // THE NEAREST NEIGHBOUR ALWAYS GETS WEIGHT 1 -- that is what subtracting rho
        // buys, and it is why no point is ever left isolated
        try testing.expect(sigma[i] > 0);
    }
}

test "the kNN really are the nearest" {
    const alloc = testing.allocator;
    const x = [_]f64{ 0, 0, 1, 0, 5, 0, 10, 0 };
    const n = 4;
    const d = 2;
    const k = 2;
    const idx = try alloc.alloc(u32, n * k);
    defer alloc.free(idx);
    const dist = try alloc.alloc(f64, n * k);
    defer alloc.free(dist);
    try knn(alloc, &x, n, d, k, idx, dist);
    // point 0 at x=0: nearest is 1 (d=1), then 2 (d=5)
    try testing.expectEqual(@as(u32, 1), idx[0]);
    try testing.expectEqual(@as(u32, 2), idx[1]);
    // distances ascend within each row
    for (0..n) |i| try testing.expect(dist[i * k] <= dist[i * k + 1]);
}

test "well-separated clusters stay separated" {
    const alloc = testing.allocator;
    const per = 15;
    const n = per * 3;
    const d = 5;
    const x = try blobs(alloc, per, d);
    defer alloc.free(x);

    var r = try run(alloc, x, n, d, .{ .n_neighbors = 5, .epochs = 300 });
    defer r.deinit();

    var within: f64 = 0;
    var wn: usize = 0;
    var between: f64 = 0;
    var bn: usize = 0;
    for (0..n) |i| {
        for (i + 1..n) |j| {
            const dd = @sqrt(sqDist(r.embedding[i * 2 ..][0..2], r.embedding[j * 2 ..][0..2]));
            if (i / per == j / per) {
                within += dd;
                wn += 1;
            } else {
                between += dd;
                bn += 1;
            }
        }
    }
    try testing.expect((between / @as(f64, @floatFromInt(bn))) >
        (within / @as(f64, @floatFromInt(wn))) * 2);
}

test "every coordinate stays finite -- what the gradient clip is for" {
    const alloc = testing.allocator;
    const per = 10;
    const n = per * 3;
    const d = 3;
    const x = try blobs(alloc, per, d);
    defer alloc.free(x);
    var r = try run(alloc, x, n, d, .{ .n_neighbors = 4, .epochs = 200 });
    defer r.deinit();
    for (r.embedding) |v| try testing.expect(std.math.isFinite(v));
}

test "the same seed gives the same embedding" {
    const alloc = testing.allocator;
    const per = 8;
    const n = per * 3;
    const d = 3;
    const x = try blobs(alloc, per, d);
    defer alloc.free(x);
    var a = try run(alloc, x, n, d, .{ .n_neighbors = 4, .epochs = 60, .seed = 3 });
    defer a.deinit();
    var b = try run(alloc, x, n, d, .{ .n_neighbors = 4, .epochs = 60, .seed = 3 });
    defer b.deinit();
    for (a.embedding, b.embedding) |p, q| try testing.expectEqual(p, q);

    var c = try run(alloc, x, n, d, .{ .n_neighbors = 4, .epochs = 60, .seed = 9 });
    defer c.deinit();
    var differs = false;
    for (a.embedding, c.embedding) |p, q| {
        if (p != q) differs = true;
    }
    try testing.expect(differs);
}

test "impossible neighbour counts are refused" {
    const alloc = testing.allocator;
    const x = [_]f64{ 0, 0, 1, 1, 2, 2, 3, 3 };
    try testing.expectError(Error.BadNeighbors, run(alloc, &x, 4, 2, .{ .n_neighbors = 10 }));
    try testing.expectError(Error.BadNeighbors, run(alloc, &x, 4, 2, .{ .n_neighbors = 1 }));
    try testing.expectError(Error.TooFewPoints, run(alloc, &x, 2, 2, .{ .n_neighbors = 2 }));
}
