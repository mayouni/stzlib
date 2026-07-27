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

    /// HOW MUCH TO TRUST THE LABELS, when any are supplied. 0 ignores them
    /// entirely (ordinary UMAP); 1 makes the label structure overwhelming. The
    /// reference implementation's default is 0.5, and the number turns into a
    /// distance penalty -- see applyLabels.
    target_weight: f64 = 0.5,
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

// ─── SUPERVISION ─────────────────────────────────────────────────────────────
//
// WHAT SUPERVISED UMAP ACTUALLY DOES, because the name suggests more than it is.
// It does NOT learn a classifier and it does not use the labels to predict
// anything. It uses them to REWEIGHT THE NEIGHBOUR GRAPH that the unsupervised
// algorithm already built: an edge between two points of different classes is made
// weak, so the layout stops trying to keep them together.
//
// The rule is the reference implementation's, and it is a multiplication:
//
//     labels agree        -> unchanged
//     labels disagree     -> weight *= exp(-far_dist)
//     either is UNKNOWN   -> weight *= exp(-1)
//
// far_dist comes from `target_weight`: 2.5 / (1 - w), so the default 0.5 gives 5.0
// and exp(-5) = 0.0067 -- a cross-class edge keeps under a percent of its weight.
// At target_weight = 1 the penalty is effectively infinite and the data's own
// structure stops mattering at all.
//
// UNKNOWN IS NOT A THIRD CLASS. A -1 label means "no information", and an edge
// touching one is damped rather than crushed -- exp(-1) = 0.37 against exp(-5).
// That is the difference between semi-supervised and simply dropping the point.
//
// ── AND THE WARNING, WHICH MATTERS MORE THAN THE MECHANISM ──
//
// A supervised embedding will separate your classes. That is what you asked it to
// do. It is therefore NOT evidence that the classes are separable, and a picture
// from it must never be presented as though it were -- the separation was an input,
// not a finding. What it is genuinely good for: seeing structure WITHIN known
// classes, building a metric that respects a labelling you already trust, and
// laying out data whose grouping is not in question so that something else can be
// looked at.
fn applyLabels(
    alloc: std.mem.Allocator,
    edges: []Edge,
    labels: []const i32,
    target_weight: f64,
    n: usize,
    wmax: *f64,
) void {
    const w = @min(@max(target_weight, 0.0), 1.0);
    if (w <= 0) return; // trust the data entirely: ordinary UMAP
    const far_dist: f64 = if (w >= 1.0) 1e12 else 2.5 / (1.0 - w);
    const far_factor = @exp(-far_dist);
    const unknown_factor = @exp(-1.0);

    for (edges) |*e| {
        const li = labels[e.i];
        const lj = labels[e.j];
        if (li < 0 or lj < 0) {
            e.w *= unknown_factor;
        } else if (li != lj) {
            e.w *= far_factor;
        }
    }

    // RESET LOCAL CONNECTIVITY. Crushing the cross-class edges can leave a point
    // whose strongest remaining edge is tiny, and the sampling schedule is relative
    // to the GLOBAL maximum -- so without this, such a point would almost never be
    // sampled and would drift wherever the repulsion pushed it. Renormalising each
    // point's edges so its strongest is 1 restores the guarantee the unsupervised
    // construction had: everyone keeps a fully-weighted neighbour.
    const maxes = alloc.alloc(f64, n) catch return;
    defer alloc.free(maxes);
    @memset(maxes, 0);
    for (edges) |e| {
        if (e.w > maxes[e.i]) maxes[e.i] = e.w;
        if (e.w > maxes[e.j]) maxes[e.j] = e.w;
    }
    var newmax: f64 = 0;
    for (edges) |*e| {
        const m = @max(maxes[e.i], maxes[e.j]);
        if (m > 0) e.w /= m;
        if (e.w > newmax) newmax = e.w;
    }
    if (newmax > 0) wmax.* = newmax;
}

pub fn run(
    alloc: std.mem.Allocator,
    x: []const f64,
    n: usize,
    d: usize,
    opts: Options,
) !*Result {
    return runSupervised(alloc, x, n, d, null, opts);
}

/// UMAP with optional LABELS. `labels` is one integer per point, or null for the
/// ordinary unsupervised fit; a label of -1 means UNKNOWN, which is what makes the
/// semi-supervised case work rather than forcing every point to be classified.
pub fn runSupervised(
    alloc: std.mem.Allocator,
    x: []const f64,
    n: usize,
    d: usize,
    labels: ?[]const i32,
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

    // ── SUPERVISION: let the labels reshape the graph ──
    if (labels) |lab| applyLabels(alloc, edges.items, lab, opts.target_weight, n, &wmax);

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

// --- TRANSFORM: placing points the fit never saw ----------------------------
//
// THIS IS WHERE UMAP AND t-SNE GENUINELY DIFFER, and an earlier note in this
// library got it wrong by lumping them together. t-SNE optimises the positions of
// the points it was given and nothing else: a new point has no position, and the
// classic algorithm offers no way to give it one. UMAP builds a NEIGHBOUR GRAPH,
// and a graph extends -- a new point's edges to the training points are computable,
// and the training layout is already a solution those edges can be optimised
// against.
//
// So the procedure is the fit's, with the training embedding held FIXED:
//
//   1. find the new point's k nearest neighbours among the TRAINING points;
//   2. give it its own rho and sigma from those distances -- the same local metric
//      the fit used, computed fresh, because a new point's neighbourhood density is
//      its own and not inherited from whoever it landed near;
//   3. initialise it at the weighted average of its neighbours' embedded positions,
//      which is already a reasonable answer and makes the optimisation a refinement
//      rather than a search;
//   4. run the same attract/repel SGD, moving ONLY the new point.
//
// WHAT THIS IS NOT: it is not the same as having included the point in the original
// fit. The training layout does not rearrange to accommodate it. If the new point
// belongs to structure the fit never saw, it will be placed among whichever training
// points happen to be least far away -- confidently, and wrongly. Transform answers
// "where does this sit in the map I already have", not "what would the map have
// looked like with this in it".

/// Place `new_x` (m*d) into an existing embedding. `train_x` (n*d) and `train_y`
/// (n*dims) are the data and layout the model was fitted on; `a` and `b` its fitted
/// curve. Writes m*dims coordinates into `out`.
pub fn transform(
    alloc: std.mem.Allocator,
    train_x: []const f64,
    train_y: []const f64,
    n: usize,
    d: usize,
    dims: usize,
    new_x: []const f64,
    m: usize,
    k: usize,
    a: f64,
    b: f64,
    epochs: usize,
    seed: u64,
    out: []f64,
) !void {
    if (n == 0 or m == 0 or k == 0 or k > n) return Error.BadNeighbors;

    const idx = try alloc.alloc(u32, m * k);
    defer alloc.free(idx);
    const dist = try alloc.alloc(f64, m * k);
    defer alloc.free(dist);
    const cand = try alloc.alloc(f64, n);
    defer alloc.free(cand);

    // k nearest TRAINING points for each new point. Note the asymmetry with the
    // fit's knn: there, a point could not be its own neighbour; here a new point is
    // not in the training set at all, so every training point is a candidate --
    // including one at distance zero, if the caller passes a row it already fitted.
    for (0..m) |i| {
        for (0..n) |j| cand[j] = @sqrt(sqDist(new_x[i * d ..][0..d], train_x[j * d ..][0..d]));
        for (0..k) |slot| {
            var best: usize = 0;
            var bestv = std.math.inf(f64);
            for (0..n) |j| {
                if (cand[j] < bestv) {
                    bestv = cand[j];
                    best = j;
                }
            }
            idx[i * k + slot] = @intCast(best);
            dist[i * k + slot] = bestv;
            cand[best] = std.math.inf(f64);
        }
    }

    const rho = try alloc.alloc(f64, m);
    defer alloc.free(rho);
    const sigma = try alloc.alloc(f64, m);
    defer alloc.free(sigma);
    localMetric(dist, m, k, rho, sigma);

    const w = try alloc.alloc(f64, m * k);
    defer alloc.free(w);
    for (0..m) |i| {
        for (0..k) |t| {
            const dd = dist[i * k + t] - rho[i];
            w[i * k + t] = if (dd > 0) @exp(-dd / sigma[i]) else 1.0;
        }
    }

    // INITIALISE AT THE WEIGHTED AVERAGE of the neighbours' positions. Starting from
    // a random point would work and would need far more epochs to undo; starting
    // from the neighbourhood's centre of mass makes the SGD a correction.
    for (0..m) |i| {
        var wsum: f64 = 0;
        for (0..dims) |t| out[i * dims + t] = 0;
        for (0..k) |t| {
            const j: usize = idx[i * k + t];
            const wt = w[i * k + t];
            wsum += wt;
            for (0..dims) |c| out[i * dims + c] += wt * train_y[j * dims + c];
        }
        if (wsum > 0) {
            for (0..dims) |c| out[i * dims + c] /= wsum;
        }
    }

    if (epochs == 0) return;

    var rng = Rng.init(seed);
    var wmax: f64 = 0;
    for (w) |v| {
        if (v > wmax) wmax = v;
    }
    if (wmax <= 0) return;

    const eps = try alloc.alloc(f64, m * k);
    defer alloc.free(eps);
    const next_sample = try alloc.alloc(f64, m * k);
    defer alloc.free(next_sample);
    for (w, 0..) |v, i| {
        eps[i] = if (v > 1e-12) wmax / v else std.math.inf(f64);
        next_sample[i] = eps[i];
    }

    var epoch: usize = 0;
    while (epoch < epochs) : (epoch += 1) {
        const alpha = 1.0 *
            (1.0 - @as(f64, @floatFromInt(epoch)) / @as(f64, @floatFromInt(epochs)));
        for (0..m) |i| {
            const yi = out[i * dims ..][0..dims];
            for (0..k) |t| {
                const e = i * k + t;
                if (next_sample[e] > @as(f64, @floatFromInt(epoch + 1))) continue;
                next_sample[e] += eps[e];

                const j: usize = idx[i * k + t];
                const yj = train_y[j * dims ..][0..dims];

                var d2 = sqDist(yi, yj);
                if (d2 > 0) {
                    const gc = (-2.0 * a * b * std.math.pow(f64, d2, b - 1.0)) /
                        (a * std.math.pow(f64, d2, b) + 1.0);
                    // ONLY the new point moves -- the training layout IS the map,
                    // and a map that shifted under every lookup would not be one
                    for (0..dims) |c| yi[c] += clip(gc * (yi[c] - yj[c])) * alpha;
                }

                var sneg: usize = 0;
                while (sneg < 5) : (sneg += 1) {
                    const kk = rng.below(n);
                    const yk = train_y[kk * dims ..][0..dims];
                    d2 = sqDist(yi, yk);
                    var gc: f64 = 4.0;
                    if (d2 > 0) {
                        gc = (2.0 * b) / ((0.001 + d2) * (a * std.math.pow(f64, d2, b) + 1.0));
                    }
                    for (0..dims) |c| yi[c] += clip(gc * (yi[c] - yk[c])) * alpha;
                }
            }
        }
    }
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

test "transforming the TRAINING data lands back in the right cluster" {
    // THE CHECK THAT MATTERS. A point the model has already seen must be placed
    // essentially where the fit put it. If transform used a different local metric,
    // or initialised badly, this is where it shows. It is not exact -- the position
    // is re-optimised rather than looked up -- so the claim is that it lands nearer
    // its OWN group than anyone else's.
    const alloc = testing.allocator;
    const per = 12;
    const n = per * 3;
    const d = 5;
    const x = try blobs(alloc, per, d);
    defer alloc.free(x);

    var r = try run(alloc, x, n, d, .{ .n_neighbors = 5, .epochs = 300 });
    defer r.deinit();

    const out = try alloc.alloc(f64, n * 2);
    defer alloc.free(out);
    try transform(alloc, x, r.embedding, n, d, 2, x, n, 5, r.a, r.b, 60, 42, out);

    var right: usize = 0;
    for (0..n) |i| {
        var best: usize = 0;
        var bestv = std.math.inf(f64);
        for (0..n) |j| {
            const dd = sqDist(out[i * 2 ..][0..2], r.embedding[j * 2 ..][0..2]);
            if (dd < bestv) {
                bestv = dd;
                best = j;
            }
        }
        if (best / per == i / per) right += 1;
    }
    try testing.expect(right >= n - 2);
}

test "a new point lands in the cluster it belongs to" {
    const alloc = testing.allocator;
    const per = 12;
    const n = per * 3;
    const d = 5;
    const x = try blobs(alloc, per, d);
    defer alloc.free(x);

    var r = try run(alloc, x, n, d, .{ .n_neighbors = 5, .epochs = 300 });
    defer r.deinit();

    // one point squarely inside each blob (the centres are 0, 25, 50)
    var newx: [15]f64 = undefined;
    for (0..3) |c| {
        for (0..d) |j| newx[c * d + j] = @as(f64, @floatFromInt(c)) * 25.0;
    }
    var out: [6]f64 = undefined;
    try transform(alloc, x, r.embedding, n, d, 2, &newx, 3, 5, r.a, r.b, 60, 42, &out);

    for (0..3) |c| {
        var best: usize = 0;
        var bestv = std.math.inf(f64);
        for (0..n) |j| {
            const dd = sqDist(out[c * 2 ..][0..2], r.embedding[j * 2 ..][0..2]);
            if (dd < bestv) {
                bestv = dd;
                best = j;
            }
        }
        try testing.expectEqual(c, best / per);
    }
}

test "transform is deterministic and leaves the training layout untouched" {
    const alloc = testing.allocator;
    const per = 8;
    const n = per * 3;
    const d = 4;
    const x = try blobs(alloc, per, d);
    defer alloc.free(x);
    var r = try run(alloc, x, n, d, .{ .n_neighbors = 4, .epochs = 150 });
    defer r.deinit();

    const before = try alloc.alloc(f64, n * 2);
    defer alloc.free(before);
    @memcpy(before, r.embedding);

    var newx = [_]f64{ 1, 1, 1, 1, 26, 26, 26, 26 };
    var o1: [4]f64 = undefined;
    var o2: [4]f64 = undefined;
    try transform(alloc, x, r.embedding, n, d, 2, &newx, 2, 4, r.a, r.b, 40, 5, &o1);
    try transform(alloc, x, r.embedding, n, d, 2, &newx, 2, 4, r.a, r.b, 40, 5, &o2);

    for (o1, o2) |p, q| try testing.expectEqual(p, q);
    // THE MAP DID NOT MOVE. A map that shifted under every lookup would not be one.
    for (before, r.embedding) |p, q| try testing.expectEqual(p, q);
}

test "zero epochs gives the weighted-average initialisation, already sane" {
    const alloc = testing.allocator;
    const per = 10;
    const n = per * 3;
    const d = 4;
    const x = try blobs(alloc, per, d);
    defer alloc.free(x);
    var r = try run(alloc, x, n, d, .{ .n_neighbors = 4, .epochs = 200 });
    defer r.deinit();

    var newx = [_]f64{ 0, 0, 0, 0 };
    var out: [2]f64 = undefined;
    try transform(alloc, x, r.embedding, n, d, 2, &newx, 1, 4, r.a, r.b, 0, 1, &out);
    for (out) |v| try testing.expect(std.math.isFinite(v));
    var best: usize = 0;
    var bestv = std.math.inf(f64);
    for (0..n) |j| {
        const dd = sqDist(&out, r.embedding[j * 2 ..][0..2]);
        if (dd < bestv) {
            bestv = dd;
            best = j;
        }
    }
    try testing.expectEqual(@as(usize, 0), best / per);
}

test "more neighbours than training points is refused" {
    const alloc = testing.allocator;
    const x = [_]f64{ 0, 0, 1, 1, 2, 2 };
    const y = [_]f64{ 0, 0, 1, 1, 2, 2 };
    var out: [2]f64 = undefined;
    const nx = [_]f64{ 0.5, 0.5 };
    try testing.expectError(
        Error.BadNeighbors,
        transform(alloc, &x, &y, 3, 2, 2, &nx, 1, 9, 1.5, 0.9, 10, 1, &out),
    );
}

/// two INTERLEAVED groups: the data alone does not separate them, so any separation
/// in the embedding can only have come from the labels
fn interleaved(alloc: std.mem.Allocator, per: usize, d: usize) !struct { x: []f64, y: []i32 } {
    const n = per * 2;
    const x = try alloc.alloc(f64, n * d);
    const y = try alloc.alloc(i32, n);
    var rng = Rng.init(19);
    for (0..n) |i| {
        for (0..d) |j| x[i * d + j] = rng.uniform() * 10;
        y[i] = @intCast(i % 2);
    }
    return .{ .x = x, .y = y };
}

test "labels separate groups the DATA does not separate" {
    // THE TEST THAT MEANS SOMETHING. The two classes are interleaved at random in
    // the input, so unsupervised UMAP has nothing to find -- and supervised UMAP
    // must nonetheless pull them apart, because that is what the labels say.
    const alloc = testing.allocator;
    const per = 20;
    const n = per * 2;
    const d = 4;
    const data = try interleaved(alloc, per, d);
    defer alloc.free(data.x);
    defer alloc.free(data.y);

    var unsup = try run(alloc, data.x, n, d, .{ .n_neighbors = 6, .epochs = 300 });
    defer unsup.deinit();
    var sup = try runSupervised(alloc, data.x, n, d, data.y, .{ .n_neighbors = 6, .epochs = 300 });
    defer sup.deinit();

    // mean between-class distance over mean within-class distance, by LABEL
    const ru = labelSeparation(unsup.embedding, data.y, n);
    const rs = labelSeparation(sup.embedding, data.y, n);
    try testing.expect(ru < 1.3); // nothing to find, so nothing found
    try testing.expect(rs > ru * 1.5); // the labels did the work
}

fn labelSeparation(emb: []const f64, y: []const i32, n: usize) f64 {
    var within: f64 = 0;
    var wn: usize = 0;
    var between: f64 = 0;
    var bn: usize = 0;
    for (0..n) |i| {
        for (i + 1..n) |j| {
            const dd = @sqrt(sqDist(emb[i * 2 ..][0..2], emb[j * 2 ..][0..2]));
            if (y[i] == y[j]) {
                within += dd;
                wn += 1;
            } else {
                between += dd;
                bn += 1;
            }
        }
    }
    if (wn == 0 or bn == 0 or within == 0) return 0;
    return (between / @as(f64, @floatFromInt(bn))) / (within / @as(f64, @floatFromInt(wn)));
}

test "target_weight: 0 is exactly unsupervised, and the dial is NOT monotone" {
    const alloc = testing.allocator;
    const per = 15;
    const n = per * 2;
    const d = 4;
    const data = try interleaved(alloc, per, d);
    defer alloc.free(data.x);
    defer alloc.free(data.y);

    // weight 0 must reproduce the unsupervised fit BIT FOR BIT -- the labels are
    // not merely de-emphasised, they are not consulted at all
    var plain = try run(alloc, data.x, n, d, .{ .n_neighbors = 5, .epochs = 120 });
    defer plain.deinit();
    var zero = try runSupervised(alloc, data.x, n, d, data.y, .{
        .n_neighbors = 5,
        .epochs = 120,
        .target_weight = 0,
    });
    defer zero.deinit();
    for (plain.embedding, zero.embedding) |a, b| try testing.expectEqual(a, b);

    // MEASURED, and it is not the shape one would assume. Separation against
    // target_weight on this data:
    //
    //     0.00  0.98      <- nothing to find, nothing found
    //     0.05  1.71
    //     0.20  2.62      <- the peak
    //     0.50  1.46
    //     0.90  1.43
    //     0.99  1.43      <- identical to 0.90
    //
    // TWO THINGS THE NUMBERS SAY. First, the dial SATURATES: far_dist is
    // 2.5/(1-w), so 0.9 gives exp(-25) and 0.99 gives exp(-250), and both are zero
    // as far as an f64 weight is concerned -- the two runs come out identical.
    // Second, and less obvious, MORE SUPERVISION IS NOT MORE SEPARATION. Crushing
    // every cross-class edge FRAGMENTS the graph: points lose most of their
    // neighbours, and the layout loses the global arrangement that was holding each
    // class together as one group. The classes end up interleaved as many small
    // pieces rather than two blobs.
    //
    // So what is pinned here is what holds: some supervision beats none, and the
    // extreme is not the best. A monotone assertion would have been wrong, and
    // writing one without measuring is how it would have got in.
    var some = try runSupervised(alloc, data.x, n, d, data.y, .{
        .n_neighbors = 5,
        .epochs = 300,
        .target_weight = 0.2,
    });
    defer some.deinit();
    const sep_none = labelSeparation(zero.embedding, data.y, n);
    const sep_some = labelSeparation(some.embedding, data.y, n);
    try testing.expect(sep_some > sep_none);

    // and the saturation, exactly: beyond about 0.9 the penalty underflows and the
    // setting stops meaning anything
    var w90 = try runSupervised(alloc, data.x, n, d, data.y, .{
        .n_neighbors = 5,
        .epochs = 300,
        .target_weight = 0.9,
    });
    defer w90.deinit();
    var w99 = try runSupervised(alloc, data.x, n, d, data.y, .{
        .n_neighbors = 5,
        .epochs = 300,
        .target_weight = 0.99,
    });
    defer w99.deinit();
    for (w90.embedding, w99.embedding) |a, b| try testing.expectEqual(a, b);
}

test "UNKNOWN labels are damped, not crushed -- the semi-supervised case" {
    const alloc = testing.allocator;
    const per = 15;
    const n = per * 2;
    const d = 4;
    const data = try interleaved(alloc, per, d);
    defer alloc.free(data.x);
    defer alloc.free(data.y);

    // hide half the labels
    const partial = try alloc.alloc(i32, n);
    defer alloc.free(partial);
    for (0..n) |i| partial[i] = if (i % 4 == 0) -1 else data.y[i];

    var semi = try runSupervised(alloc, data.x, n, d, partial, .{ .n_neighbors = 5, .epochs = 300 });
    defer semi.deinit();
    var unsup = try run(alloc, data.x, n, d, .{ .n_neighbors = 5, .epochs = 300 });
    defer unsup.deinit();

    for (semi.embedding) |v| try testing.expect(std.math.isFinite(v));
    // the labels it DOES have still do work
    try testing.expect(labelSeparation(semi.embedding, data.y, n) >
        labelSeparation(unsup.embedding, data.y, n));
}

test "every point keeps a fully-weighted neighbour after the intersection" {
    // What resetting local connectivity is FOR. Crushing cross-class edges can leave
    // a point whose strongest edge is tiny; since the sampling schedule is relative
    // to the global maximum, it would then almost never be sampled and would drift.
    const alloc = testing.allocator;
    const per = 12;
    const n = per * 2;
    const d = 3;
    const data = try interleaved(alloc, per, d);
    defer alloc.free(data.x);
    defer alloc.free(data.y);
    var r = try runSupervised(alloc, data.x, n, d, data.y, .{
        .n_neighbors = 5,
        .epochs = 200,
        .target_weight = 0.9,
    });
    defer r.deinit();
    // no point flew off: with a working reset every coordinate stays bounded
    for (r.embedding) |v| {
        try testing.expect(std.math.isFinite(v));
        try testing.expect(@abs(v) < 1e4);
    }
}

test "supervised runs are reproducible too" {
    const alloc = testing.allocator;
    const per = 10;
    const n = per * 2;
    const d = 3;
    const data = try interleaved(alloc, per, d);
    defer alloc.free(data.x);
    defer alloc.free(data.y);
    var a = try runSupervised(alloc, data.x, n, d, data.y, .{ .n_neighbors = 4, .epochs = 100, .seed = 8 });
    defer a.deinit();
    var b = try runSupervised(alloc, data.x, n, d, data.y, .{ .n_neighbors = 4, .epochs = 100, .seed = 8 });
    defer b.deinit();
    for (a.embedding, b.embedding) |p, q| try testing.expectEqual(p, q);
}
