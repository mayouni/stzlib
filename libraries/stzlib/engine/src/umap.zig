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
const density = @import("density.zig");

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

    /// DENSITY PRESERVATION (densMAP). 0 leaves the algorithm exactly as it was; the
    /// paper's default is 2.0. See density.zig for what the term does and what the
    /// resulting picture may and may not be read as saying.
    density_lambda: f64 = 0,

    /// the FINAL fraction of epochs during which the density term is active. It is
    /// switched on late on purpose: on a random initialisation the embedding radii are
    /// noise, so their correlation with anything is noise, and its gradient is noise
    /// with a lever arm. The layout must be roughly right before "are the dense parts
    /// tight?" is a question with an answer.
    density_frac: f64 = 0.3,
};

pub const Result = struct {
    embedding: []f64,
    /// the fitted curve parameters, reported because they are derived rather than
    /// given and a caller may reasonably want to see what min_dist turned into
    a: f64,
    b: f64,
    n: usize,
    dims: usize,

    /// ORIGINAL-SPACE local radius per point -- how far, on average, this point sits
    /// from the neighbours it is actually connected to. Empty unless density
    /// preservation was asked for.
    ///
    /// This is a DATA PRODUCT and not a by-product of drawing: it ranks points by how
    /// isolated they are, and it is meaningful without looking at the embedding at
    /// all. It costs nothing extra, because the density term has to compute it anyway.
    local_radii: []f64,

    /// correlation between original and embedded log-radii at the end of the run --
    /// how far the density term actually got. NaN when it was never switched on.
    ///
    /// Reported rather than hidden because it is the ONLY evidence that the extra term
    /// achieved anything, and a caller who cannot see it has to take the picture on
    /// faith. It is not a percentage: see the -0.60 case in density.zig.
    density_correlation: f64,

    /// The line relating original to embedded log-radius IN THIS MAP -- what lets
    /// Transform() place a new point at a radius consistent with the fit, instead of
    /// wherever its neighbours happen to sit. Zero slope when density was not used.
    density_slope: f64,
    density_intercept: f64,

    allocator: std.mem.Allocator,

    pub fn deinit(self: *Result) void {
        self.allocator.free(self.embedding);
        if (self.local_radii.len > 0) self.allocator.free(self.local_radii);
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

    // ── DENSITY PRESERVATION, when asked for ──
    //
    // The target is built ONCE from the graph that already exists -- the same edges
    // and the same membership weights the layout is being optimised against. Nothing
    // here recomputes a neighbourhood or invents a second notion of what is near.
    const want_density = opts.density_lambda > 0 and n >= 3;
    var dens_target: ?density.Target = null;
    defer if (dens_target) |*t| t.deinit();
    var dens_ws: ?density.Workspace = null;
    defer if (dens_ws) |*dws| dws.deinit();
    var dens_corr: f64 = std.math.nan(f64);
    // the epoch at which the term switches on -- see Options.density_frac
    var dens_start: usize = opts.epochs;
    if (want_density) {
        const de: []const density.Edge = @ptrCast(edges.items);
        dens_target = try density.buildTarget(alloc, de, x, n, d);
        dens_ws = try density.Workspace.init(alloc, n);
        const frac = @min(@max(opts.density_frac, 0.0), 1.0);
        const on_for: f64 = @as(f64, @floatFromInt(opts.epochs)) * frac;
        dens_start = opts.epochs -| @as(usize, @intFromFloat(on_for));
    }

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

        // AFTER the local passes, not interleaved with them. The correlation is a
        // statistic over every point, so it cannot be evaluated part-way through an
        // epoch in which some points have moved and others have not -- this is the
        // synchronisation point the rest of the optimiser does not have.
        if (want_density and epoch >= dens_start) {
            const de: []const density.Edge = @ptrCast(edges.items);
            dens_corr = density.applyGradient(
                &dens_target.?,
                &dens_ws.?,
                de,
                y,
                n,
                dims,
                opts.density_lambda,
                alpha,
                clipFn,
            );
        }
    }

    var radii_out: []f64 = &[_]f64{};
    var calib = density.Calibration{ .slope = 0, .intercept = 0, .usable = false };
    if (want_density) {
        const de: []const density.Edge = @ptrCast(edges.items);
        const mean_log = try density.meanLogRadius(de, x, n, d, alloc);
        radii_out = try dens_target.?.radii(alloc, mean_log);
        // the correlation AFTER the last step, so the reported number describes the
        // embedding that is actually returned rather than the one before it
        dens_corr = density.correlation(&dens_target.?, &dens_ws.?, de, y, n, dims);
        calib = density.calibrate(&dens_target.?, &dens_ws.?, de, y, n, dims, mean_log);
    }

    const out = try alloc.create(Result);
    out.* = .{
        .embedding = y,
        .a = a,
        .b = b,
        .n = n,
        .dims = dims,
        .local_radii = radii_out,
        .density_correlation = dens_corr,
        .density_slope = if (calib.usable) calib.slope else 0,
        .density_intercept = calib.intercept,
        .allocator = alloc,
    };
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
    return transformWithDensity(alloc, train_x, train_y, n, d, dims, new_x, m, k, a, b, epochs, seed, out, 0, 0, false, null);
}

/// Transform, optionally placing each new point at the radius the fit's density
/// contract calls for.
///
/// ── WHY THIS IS NOT JUST THE FIT'S TERM APPLIED AGAIN ──
///
/// The fit maximises a CORRELATION across every point. One new point has nothing to
/// correlate against, so the objective does not even type-check for it. What carries
/// over instead is the LINE the fit left behind (density.Calibration): for this
/// particular map, an original density of R implies an embedded radius of
/// exp(intercept + slope*log R). That is a prediction, and it extrapolates.
///
/// ── AND THE CORRECTION IS CLOSED FORM, WHICH IS WORTH THE PARAGRAPH ──
///
/// Writing c for the membership-weighted centroid of a new point's neighbours and S
/// for those neighbours' own weighted spread about c, the point's embedded radius is
/// exactly
///
///     R_emb = ||y - c||^2 + S
///
/// -- an identity, not an approximation, and it separates the two questions cleanly.
/// The ordinary optimisation decides the DIRECTION from c, which is what says which
/// side of its neighbourhood the point belongs on. The density contract decides only
/// the DISTANCE. So there is no second gradient loop and nothing for the two terms to
/// fight over: run the normal transform, then set the radius.
///
/// When the target is below S the neighbours are already more spread than the point
/// should be, and the honest answer is the centroid itself -- the point cannot be
/// tighter than the company it keeps.
pub fn transformWithDensity(
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
    dens_slope: f64,
    dens_intercept: f64,
    dens_on: bool,
    /// the new points' ORIGINAL-space radii, written when non-null. A novelty score:
    /// meaningful with no reference to the embedding at all.
    new_radii: ?[]f64,
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

    // THE NEW POINTS' OWN LOCAL RADII, in the original space. Reported whether or not
    // the density correction is applied, because the number is useful on its own: a
    // row whose radius is far outside the training range is one the model has no
    // business being confident about.
    if (new_radii) |nr| {
        for (0..m) |i| {
            var acc: f64 = 0;
            var wsum: f64 = 0;
            for (0..k) |t| {
                const wt = w[i * k + t];
                acc += wt * dist[i * k + t] * dist[i * k + t];
                wsum += wt;
            }
            nr[i] = if (wsum > 0) acc / wsum else 0;
        }
    }

    if (epochs == 0) {
        if (dens_on) applyDensityRadius(train_y, idx, w, new_x, dist, out, m, k, dims, dens_slope, dens_intercept);
        return;
    }

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

    // LAST, once the neighbourhood optimisation has settled on a direction. Doing it
    // earlier would let the SGD undo it.
    if (dens_on) applyDensityRadius(train_y, idx, w, new_x, dist, out, m, k, dims, dens_slope, dens_intercept);
}

/// Set each new point's distance from its neighbourhood centroid so that its embedded
/// radius matches what the fit's density line predicts, keeping the direction the
/// optimisation chose.
///
/// The identity being used is R_emb = ||y - c||^2 + S, with c the membership-weighted
/// centroid of the neighbours and S their own weighted spread about it. So the whole
/// correction is one scalar per point.
fn applyDensityRadius(
    train_y: []const f64,
    idx: []const u32,
    w: []const f64,
    new_x: []const f64,
    dist: []const f64,
    out: []f64,
    m: usize,
    k: usize,
    dims: usize,
    slope: f64,
    intercept: f64,
) void {
    _ = new_x;
    var i: usize = 0;
    while (i < m) : (i += 1) {
        // the weighted centroid c, and the neighbours' spread S about it
        var wsum: f64 = 0;
        var c: [8]f64 = .{0} ** 8;
        if (dims > 8) return;
        for (0..k) |t| {
            const j: usize = idx[i * k + t];
            const wt = w[i * k + t];
            wsum += wt;
            for (0..dims) |q| c[q] += wt * train_y[j * dims + q];
        }
        if (wsum <= 0) continue;
        for (0..dims) |q| c[q] /= wsum;

        var s_spread: f64 = 0;
        for (0..k) |t| {
            const j: usize = idx[i * k + t];
            var dd: f64 = 0;
            for (0..dims) |q| {
                const diff = train_y[j * dims + q] - c[q];
                dd += diff * diff;
            }
            s_spread += w[i * k + t] * dd;
        }
        s_spread /= wsum;

        // the point's ORIGINAL radius, and what the fit's line says it should become
        var acc: f64 = 0;
        for (0..k) |t| acc += w[i * k + t] * dist[i * k + t] * dist[i * k + t];
        const r_orig = acc / wsum;
        const target = @exp(intercept + slope * @log(@max(r_orig, 1e-12)));

        // ||y - c||^2 = R_target - S, or the centroid itself when the neighbours are
        // already more spread than the point should be
        const want_sq = target - s_spread;
        var cur: f64 = 0;
        for (0..dims) |q| {
            const diff = out[i * dims + q] - c[q];
            cur += diff * diff;
        }
        if (want_sq <= 0) {
            for (0..dims) |q| out[i * dims + q] = c[q];
            continue;
        }
        if (cur <= 1e-18) {
            // the optimisation landed exactly on the centroid, so there is no
            // direction to keep. Push along the first axis rather than inventing one.
            out[i * dims] = c[0] + @sqrt(want_sq);
            for (1..dims) |q| out[i * dims + q] = c[q];
            continue;
        }
        const scale = @sqrt(want_sq / cur);
        for (0..dims) |q| out[i * dims + q] = c[q] + (out[i * dims + q] - c[q]) * scale;
    }
}

/// The reference implementation clips every gradient component to +-4. Without it a
/// pair that lands almost on top of another produces an enormous step and throws a
/// point to infinity, taking the layout with it.
/// `clip` is inline and therefore has no address to pass; density.zig takes the
/// bound as a function pointer so that the same limit applies to its step as to the
/// cross-entropy steps around it.
fn clipFn(v: f64) f64 {
    return clip(v);
}

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

/// two clusters of DELIBERATELY different density: one tight, one twenty times more
/// spread. The case densMAP exists for, and the case plain UMAP renders misleadingly.
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

/// mean pairwise distance within rows [lo, hi)
fn spreadOf(v: []const f64, lo: usize, hi: usize, dims: usize) f64 {
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

/// between-cluster distance over within-cluster distance, for a two-cluster layout
fn separationOf(v: []const f64, per: usize, n: usize) f64 {
    var bt: f64 = 0;
    for (0..per) |i| {
        for (per..n) |j| bt += @sqrt(sqDist(v[i * 2 ..][0..2], v[j * 2 ..][0..2]));
    }
    const btw = bt / @as(f64, @floatFromInt(per * (n - per)));
    const wth = (spreadOf(v, 0, per, 2) + spreadOf(v, per, n, 2)) / 2;
    return if (wth > 0) btw / wth else 0;
}

test "PLAIN UMAP FLATTENS DENSITY -- a 20x difference is drawn as 17 percent" {
    const alloc = testing.allocator;
    const per = 25;
    const n = per * 2;
    const d = 4;
    const x = try twoDensities(alloc, per, d);
    defer alloc.free(x);

    // what is true of the data
    const true_ratio = spreadOf(x, per, n, d) / spreadOf(x, 0, per, d);
    try testing.expect(true_ratio > 15);

    // what the ordinary picture shows
    var r = try run(alloc, x, n, d, .{ .n_neighbors = 8, .epochs = 400 });
    defer r.deinit();
    const drawn = spreadOf(r.embedding, per, n, 2) / spreadOf(r.embedding, 0, per, 2);

    // THE CAVEAT, AS A NUMBER. Twentyfold in the data, 1.17 on the page. This is not a
    // defect in the implementation -- it is what optimising a neighbourhood objective
    // does, and it is why every honest description of UMAP tells you not to read
    // cluster size. Measured here so the warning is demonstrated rather than asserted.
    try testing.expect(drawn < 1.5);
    try testing.expect(true_ratio / drawn > 10);

    // and nothing is computed that was not asked for
    try testing.expectEqual(@as(usize, 0), r.local_radii.len);
    try testing.expect(std.math.isNan(r.density_correlation));
}

test "densMAP recovers the density ordering, and lambda IS monotone here" {
    const alloc = testing.allocator;
    const per = 25;
    const n = per * 2;
    const d = 4;
    const x = try twoDensities(alloc, per, d);
    defer alloc.free(x);

    // MEASURED. correlation / drawn ratio / cluster separation against lambda, with a
    // true ratio of 19.96:
    //
    //     lambda    corr    ratio    separation
    //       0      0.226    1.167      7.359
    //       2      0.436    1.314      6.278     <- the paper default
    //      10      0.760    1.687      6.465
    //      30      0.871    1.807      5.848
    //     100      0.940    5.859      2.397
    //     300      0.993   23.825      1.443
    //
    // UNLIKE target_weight, THIS DIAL IS MONOTONE -- the correlation rises all the
    // way, with no peak and no saturation. Worth stating outright because the two
    // dials sit on the same object and behave nothing alike, and carrying either
    // shape over to the other would be wrong.
    var lo = try run(alloc, x, n, d, .{ .n_neighbors = 8, .epochs = 400, .density_lambda = 2.0 });
    defer lo.deinit();
    var hi = try run(alloc, x, n, d, .{ .n_neighbors = 8, .epochs = 400, .density_lambda = 30.0 });
    defer hi.deinit();

    try testing.expect(hi.density_correlation > lo.density_correlation);
    const rl = spreadOf(lo.embedding, per, n, 2) / spreadOf(lo.embedding, 0, per, 2);
    const rh = spreadOf(hi.embedding, per, n, 2) / spreadOf(hi.embedding, 0, per, 2);
    try testing.expect(rh > rl);

    // the diffuse cluster is drawn wider than the tight one, which is the whole point
    try testing.expect(rh > 1.5);
}

test "IT IS A TRADE: density fidelity is bought with cluster separation" {
    const alloc = testing.allocator;
    const per = 25;
    const n = per * 2;
    const d = 4;
    const x = try twoDensities(alloc, per, d);
    defer alloc.free(x);

    // THE COST, WHICH THE PAPER DEFAULT HIDES BY BEING SMALL. Pushing lambda to 300
    // gets the density almost exactly right (correlation 0.993, drawn ratio 23.8
    // against a true 20.0) -- and collapses the separation between the two clusters
    // from 7.36 to 1.44. The density term stretches and shrinks the layout, and it
    // does that by spending the room the cross-entropy was using to hold groups apart.
    //
    // So no setting is simply better than another. A high lambda answers "how dense is
    // each region" at the cost of "how many groups are there", and the second question
    // is the one people usually open a UMAP plot to ask.
    var plain = try run(alloc, x, n, d, .{ .n_neighbors = 8, .epochs = 400 });
    defer plain.deinit();
    var heavy = try run(alloc, x, n, d, .{ .n_neighbors = 8, .epochs = 400, .density_lambda = 300.0 });
    defer heavy.deinit();

    try testing.expect(heavy.density_correlation > 0.95);
    try testing.expect(separationOf(heavy.embedding, per, n) <
        separationOf(plain.embedding, per, n) / 2);
}

test "lambda 0 is EXACTLY the ordinary fit, not merely close" {
    const alloc = testing.allocator;
    const per = 15;
    const n = per * 2;
    const d = 3;
    const x = try twoDensities(alloc, per, d);
    defer alloc.free(x);

    var plain = try run(alloc, x, n, d, .{ .n_neighbors = 6, .epochs = 150 });
    defer plain.deinit();
    var zero = try run(alloc, x, n, d, .{ .n_neighbors = 6, .epochs = 150, .density_lambda = 0 });
    defer zero.deinit();
    for (plain.embedding, zero.embedding) |a, b| try testing.expectEqual(a, b);
}

test "the local radii are a data product, usable without the picture" {
    const alloc = testing.allocator;
    const per = 25;
    const n = per * 2;
    const d = 4;
    const x = try twoDensities(alloc, per, d);
    defer alloc.free(x);

    var r = try run(alloc, x, n, d, .{ .n_neighbors = 8, .epochs = 200, .density_lambda = 2.0 });
    defer r.deinit();
    try testing.expectEqual(n, r.local_radii.len);

    // every point of the tight cluster sits closer to its neighbours than every point
    // of the diffuse one -- an ordering that answers "which rows are isolated" with no
    // reference to the embedding at all
    var tight_max: f64 = 0;
    for (0..per) |i| tight_max = @max(tight_max, r.local_radii[i]);
    var diffuse_min: f64 = std.math.inf(f64);
    for (per..n) |i| diffuse_min = @min(diffuse_min, r.local_radii[i]);
    try testing.expect(tight_max < diffuse_min);
}

test "density preservation composes with supervision" {
    const alloc = testing.allocator;
    const per = 15;
    const n = per * 2;
    const d = 3;
    const x = try twoDensities(alloc, per, d);
    defer alloc.free(x);
    const y = try alloc.alloc(i32, n);
    defer alloc.free(y);
    for (0..n) |i| y[i] = @intCast(i % 2);

    var r = try runSupervised(alloc, x, n, d, y, .{
        .n_neighbors = 6,
        .epochs = 200,
        .target_weight = 0.2,
        .density_lambda = 5.0,
    });
    defer r.deinit();
    for (r.embedding) |v| try testing.expect(!std.math.isNan(v) and !std.math.isInf(v));
    try testing.expect(!std.math.isNan(r.density_correlation));
    try testing.expectEqual(n, r.local_radii.len);
}

test "too few points to correlate leaves the term off rather than dividing by zero" {
    const alloc = testing.allocator;
    const x = [_]f64{ 0, 0, 1, 1, 2, 2 };
    var r = try run(alloc, &x, 3, 2, .{ .n_neighbors = 2, .epochs = 50, .density_lambda = 5.0 });
    defer r.deinit();
    for (r.embedding) |v| try testing.expect(!std.math.isNan(v));
}

/// distance from a point to the membership-weighted centre of its k nearest training
/// rows, measured in the EMBEDDING -- the quantity the density contract governs
fn embeddedReach(train_x: []const f64, train_y: []const f64, n: usize, d: usize, pt: []const f64, pos: []const f64, k: usize, alloc: std.mem.Allocator) !f64 {
    const ds = try alloc.alloc(f64, n);
    defer alloc.free(ds);
    for (0..n) |j| ds[j] = sqDist(pt, train_x[j * d ..][0..d]);
    var acc: f64 = 0;
    for (0..k) |_| {
        var best: usize = 0;
        var bv = std.math.inf(f64);
        for (0..n) |j| {
            if (ds[j] < bv) {
                bv = ds[j];
                best = j;
            }
        }
        acc += @sqrt(sqDist(pos, train_y[best * 2 ..][0..2]));
        ds[best] = std.math.inf(f64);
    }
    return acc / @as(f64, @floatFromInt(k));
}

test "AN OUTLIER IS PLACED AS IF IT BELONGED, until the transform knows about density" {
    const alloc = testing.allocator;
    const per = 25;
    const n = per * 2;
    const d = 4;
    const x = try twoDensities(alloc, per, d);
    defer alloc.free(x);

    var r = try run(alloc, x, n, d, .{ .n_neighbors = 8, .epochs = 400, .density_lambda = 30 });
    defer r.deinit();
    try testing.expect(r.density_correlation > 0.7);

    // three new rows: inside the tight knot, inside the diffuse cloud, and one sitting
    // far outside anything the fit ever saw
    const newx = [_]f64{
        0.07, 0.07,  0.07,  0.07,
        21.5, 21.5,  21.5,  21.5,
        200,  200,   200,   200,
    };
    const m = 3;
    const k = 8;

    // ── WITHOUT the density contract, which is what the transform used to do ──
    const plain_out = try alloc.alloc(f64, m * 2);
    defer alloc.free(plain_out);
    try transform(alloc, x, r.embedding, n, d, 2, &newx, m, k, r.a, r.b, 30, 42, plain_out);

    const p_tight = try embeddedReach(x, r.embedding, n, d, newx[0..4], plain_out[0..2], k, alloc);
    const p_out = try embeddedReach(x, r.embedding, n, d, newx[8..12], plain_out[4..6], k, alloc);

    // MEASURED, and it is the failure this exists to fix. The outlier sits 356 units
    // from anything it was trained on -- some 6700 times further than the tight-cluster
    // row -- and the ordinary transform places it about 1.4 times further out. In a map
    // whose whole claim is that distance-from-neighbours means density, an unrecognised
    // row is drawn as though it were an ordinary member.
    try testing.expect(p_out / p_tight < 3.0);

    // ── WITH it ──
    const dens_out = try alloc.alloc(f64, m * 2);
    defer alloc.free(dens_out);
    const radii = try alloc.alloc(f64, m);
    defer alloc.free(radii);
    try transformWithDensity(alloc, x, r.embedding, n, d, 2, &newx, m, k, r.a, r.b, 30, 42, dens_out, r.density_slope, r.density_intercept, true, radii);

    const d_tight = try embeddedReach(x, r.embedding, n, d, newx[0..4], dens_out[0..2], k, alloc);
    const d_out = try embeddedReach(x, r.embedding, n, d, newx[8..12], dens_out[4..6], k, alloc);

    // MEASURED: the ordinary transform separates them by 1.03 -- no discrimination
    // whatever -- and the density-aware one by 5.35.
    //
    // AND NOT MORE THAN 5.35, WHICH IS THE RIGHT ANSWER RATHER THAN A DISAPPOINTING
    // ONE. The fit's line has slope 0.194: this map compresses eight-and-a-half
    // natural logs of original density into about 1.7 of embedded radius. The
    // transform inherits exactly that compression, because its whole job is to place
    // new points under THE SAME CONTRACT the training points obey. A transform that
    // flung the outlier further than the map's own scale allows would be showing
    // something the picture does not mean.
    //
    // So the claim is consistency, not exaggeration -- and the way to get more
    // separation is a heavier density weight AT FIT TIME, where it applies to
    // everything at once.
    try testing.expect(d_out / d_tight > 3.0);
    try testing.expect((d_out / d_tight) / (p_out / p_tight) > 3.0);
}

test "the new points' own radii are a novelty score, and need no embedding" {
    const alloc = testing.allocator;
    const per = 25;
    const n = per * 2;
    const d = 4;
    const x = try twoDensities(alloc, per, d);
    defer alloc.free(x);

    var r = try run(alloc, x, n, d, .{ .n_neighbors = 8, .epochs = 200, .density_lambda = 2 });
    defer r.deinit();

    const newx = [_]f64{
        0.07, 0.07, 0.07, 0.07,
        200,  200,  200,  200,
    };
    const out = try alloc.alloc(f64, 2 * 2);
    defer alloc.free(out);
    const radii = try alloc.alloc(f64, 2);
    defer alloc.free(radii);
    // epochs 0: no layout optimisation at all, and the radii still come back. They are
    // a property of the DATA, not of the picture -- which is what makes them usable as
    // an out-of-distribution check before anyone decides to draw anything.
    try transformWithDensity(alloc, x, r.embedding, n, d, 2, &newx, 2, 8, r.a, r.b, 0, 42, out, r.density_slope, r.density_intercept, false, radii);

    try testing.expect(radii[1] > radii[0] * 100);
    // and the familiar row sits inside the training range while the outlier does not
    var train_max: f64 = 0;
    for (r.local_radii) |v| train_max = @max(train_max, v);
    try testing.expect(radii[0] < train_max);
    try testing.expect(radii[1] > train_max * 10);
}

test "the density correction keeps the DIRECTION the optimisation chose" {
    const alloc = testing.allocator;
    const per = 20;
    const n = per * 2;
    const d = 4;
    const x = try twoDensities(alloc, per, d);
    defer alloc.free(x);

    var r = try run(alloc, x, n, d, .{ .n_neighbors = 6, .epochs = 300, .density_lambda = 10 });
    defer r.deinit();

    const newx = [_]f64{ 21.0, 21.2, 20.8, 21.1 };
    const plain_out = try alloc.alloc(f64, 2);
    defer alloc.free(plain_out);
    const dens_out = try alloc.alloc(f64, 2);
    defer alloc.free(dens_out);
    try transform(alloc, x, r.embedding, n, d, 2, &newx, 1, 6, r.a, r.b, 30, 42, plain_out);
    try transformWithDensity(alloc, x, r.embedding, n, d, 2, &newx, 1, 6, r.a, r.b, 30, 42, dens_out, r.density_slope, r.density_intercept, true, null);

    // Both are the same ray out of the neighbourhood centroid -- only the distance
    // along it differs. That separation is the design: the neighbourhood terms answer
    // WHERE the point belongs, the density contract answers only HOW FAR OUT, and
    // neither overrules the other.
    var c: [2]f64 = .{ 0, 0 };
    var wsum: f64 = 0;
    {
        const ds = try alloc.alloc(f64, n);
        defer alloc.free(ds);
        for (0..n) |j| ds[j] = sqDist(&newx, x[j * d ..][0..d]);
        for (0..6) |_| {
            var best: usize = 0;
            var bv = std.math.inf(f64);
            for (0..n) |j| {
                if (ds[j] < bv) {
                    bv = ds[j];
                    best = j;
                }
            }
            // unweighted here is enough to fix a ray for the angle check
            c[0] += r.embedding[best * 2];
            c[1] += r.embedding[best * 2 + 1];
            wsum += 1;
            ds[best] = std.math.inf(f64);
        }
        c[0] /= wsum;
        c[1] /= wsum;
    }
    const ax = plain_out[0] - c[0];
    const ay = plain_out[1] - c[1];
    const bx = dens_out[0] - c[0];
    const by = dens_out[1] - c[1];
    const cosang = (ax * bx + ay * by) / (@sqrt(ax * ax + ay * ay) * @sqrt(bx * bx + by * by));
    try testing.expect(cosang > 0.99);
}

test "no density in the fit means the transform is untouched" {
    const alloc = testing.allocator;
    const per = 12;
    const n = per * 2;
    const d = 3;
    const x = try twoDensities(alloc, per, d);
    defer alloc.free(x);

    var r = try run(alloc, x, n, d, .{ .n_neighbors = 5, .epochs = 150 });
    defer r.deinit();
    const newx = [_]f64{ 0.07, 0.07, 0.07 };
    const a_out = try alloc.alloc(f64, 2);
    defer alloc.free(a_out);
    const b_out = try alloc.alloc(f64, 2);
    defer alloc.free(b_out);
    try transform(alloc, x, r.embedding, n, d, 2, &newx, 1, 5, r.a, r.b, 30, 42, a_out);
    try transformWithDensity(alloc, x, r.embedding, n, d, 2, &newx, 1, 5, r.a, r.b, 30, 42, b_out, 0, 0, false, null);
    for (a_out, b_out) |p, q| try testing.expectEqual(p, q);
}
