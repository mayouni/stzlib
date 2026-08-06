//! DENSITY PRESERVATION for neighbour embeddings -- the densMAP / den-SNE term.
//!
//! ── THE PROBLEM THIS SOLVES, AND IT IS ONE THE LIBRARY ALREADY WARNS ABOUT ──
//!
//! UMAP and t-SNE preserve NEIGHBOURHOODS. They do not preserve DENSITY, and the
//! difference is not a technicality: a tight cluster of near-identical points and a
//! diffuse cloud of quite different ones come out the same visual size. Every honest
//! description of these methods therefore carries the instruction "do not read cluster
//! size", printed on a picture whose sizes people read anyway.
//!
//! Narayan, Berger and Cho (Nature Biotechnology, 2021) add one term to the objective
//! and turn that instruction into a readable quantity. Give each point a LOCAL RADIUS
//!
//!     R_i = sum_j p_ij * d(x_i, x_j)^2 / sum_j p_ij
//!
//! -- the membership-weighted mean squared distance to its neighbours, where p is the
//! fuzzy graph the embedding already built. Big radius means the point sits in a
//! sparse region; small means dense. Compute the same quantity in the EMBEDDING, and
//! ask the layout to make the two agree.
//!
//! ── WHAT "AGREE" MEANS, PRECISELY, BECAUSE THE WEAKER CLAIM IS THE TRUE ONE ──
//!
//! The objective is the PEARSON CORRELATION of log R_original against log R_embedded.
//! Correlation -- not equality, not proportionality. So the claim this module can
//! support is "denser regions come out tighter THAN sparser ones", and the claim it
//! cannot support is "cluster area is proportional to density". Log space because
//! densities span orders of magnitude and a linear correlation would be dominated by
//! whichever handful of points sit in the emptiest region.
//!
//! ── THE COST, WHICH IS STRUCTURAL RATHER THAN ARITHMETIC ──
//!
//! UMAP's optimiser is embarrassingly local: sample an edge, pull its ends together,
//! push a few random points away, repeat. Nothing anywhere needs to know anything
//! global. A correlation is a statistic over ALL points -- its derivative at point i
//! involves the mean and the variance of log-radii across the entire embedding. So
//! this term inserts a per-epoch REDUCTION into a loop that had no synchronisation
//! point at all. Two extra passes over the edge list per epoch: one to accumulate the
//! embedding radii, one to apply the gradient once the statistics are known.
//!
//! That is also why it is switched on LATE (see `frac`). On a random initialisation
//! the embedding radii are noise, their correlation with anything is noise, and its
//! gradient is noise with a lever arm. The layout has to be roughly right before the
//! question "are the dense parts tight?" has a meaningful answer.
//!
//! ── SHARED ON PURPOSE, AND WHAT "SHARED" HAD TO MEAN ──
//!
//! The same term defines den-SNE in the same paper, so the radius, the correlation and
//! its gradient are written ONCE, here.
//!
//! But the two algorithms do not hold p_ij the same way, and pretending otherwise
//! would have cost more than it saved. UMAP builds a SPARSE fuzzy graph -- an edge
//! list of the few pairs that are actually joined. t-SNE builds a DENSE n-by-n joint
//! distribution in which every pair has some weight. Forcing t-SNE to materialise an
//! edge list of n(n-1)/2 entries to reuse one loop would double its memory for nothing.
//!
//! So what is shared is the MATH -- `pointCoefficients` and everything it calls -- and
//! what differs is only the traversal: `buildTarget`/`applyGradient` walk an edge list,
//! `buildTargetDense`/`accumulateGradientDense` walk a matrix. There is still exactly
//! one definition of what local density means, which was the point.
//!
//! They also differ in where the answer goes. UMAP's optimiser has no gradient buffer
//! -- it writes each edge straight into the layout -- so the edge version moves `y`.
//! t-SNE accumulates a gradient and then puts it through momentum and adaptive gains,
//! so the dense version accumulates into `dy` instead, and its contribution is
//! NEGATED: t-SNE descends its buffer, and this term is being maximised.

const std = @import("std");
const similarity = @import("similarity.zig");

/// Below this a radius is treated as "everything coincident" rather than fed to log().
const MIN_RADIUS: f64 = 1e-12;

/// Below this a standard deviation means the radii carry no spread, so the correlation
/// is undefined and there is nothing to push towards.
const MIN_SPREAD: f64 = 1e-12;

/// An edge of the fuzzy graph, in the shape both callers already hold.
pub const Edge = struct { i: u32, j: u32, w: f64 };

/// The per-point quantities that stay FIXED for the whole run: the total membership
/// of each point, and the centered log of its original-space radius. Computed once.
pub const Target = struct {
    /// P_i = sum_j p_ij -- the denominator of the radius, needed again by the gradient
    total: []f64,
    /// log R_i in the original space, already mean-centered
    centered: []f64,
    /// the norm of `centered`; zero means the data has no density variation to preserve
    norm: f64,
    allocator: std.mem.Allocator,

    pub fn deinit(self: *Target) void {
        self.allocator.free(self.total);
        self.allocator.free(self.centered);
    }

    /// Uncentered log radii are what a caller actually wants to SEE -- centering is an
    /// internal convenience of the correlation, not a property of the data. Returns
    /// the radii themselves (not logs), which is the quantity with a unit.
    pub fn radii(self: *const Target, alloc: std.mem.Allocator, mean_log: f64) ![]f64 {
        const out = try alloc.alloc(f64, self.centered.len);
        for (self.centered, 0..) |c, i| out[i] = @exp(c + mean_log);
        return out;
    }
};

/// Original-space radii from the graph and the data itself.
///
/// The distances are recomputed from `x` rather than looked up in the kNN distance
/// buffer. That buffer is indexed by (point, neighbour-slot) while the edge list is
/// symmetrised -- an edge j->i exists whose distance was only ever stored under i's
/// row. Recomputing is O(|E| * d) ONCE, and is exactly right by construction.
pub fn buildTarget(
    alloc: std.mem.Allocator,
    edges: []const Edge,
    x: []const f64,
    n: usize,
    d: usize,
) !Target {
    const total = try alloc.alloc(f64, n);
    errdefer alloc.free(total);
    const centered = try alloc.alloc(f64, n);
    errdefer alloc.free(centered);
    @memset(total, 0);
    @memset(centered, 0);

    for (edges) |e| {
        const ii: usize = e.i;
        const jj: usize = e.j;
        var s: f64 = 0;
        for (0..d) |t| {
            const diff = x[ii * d + t] - x[jj * d + t];
            s += diff * diff;
        }
        // an edge contributes to BOTH its endpoints' radii -- p is symmetric
        centered[ii] += e.w * s;
        centered[jj] += e.w * s;
        total[ii] += e.w;
        total[jj] += e.w;
    }

    var mean: f64 = 0;
    for (0..n) |i| {
        const r = if (total[i] > 0) centered[i] / total[i] else 0;
        centered[i] = @log(@max(r, MIN_RADIUS));
        mean += centered[i];
    }
    mean /= @floatFromInt(n);

    var norm: f64 = 0;
    for (centered) |*c| {
        c.* -= mean;
        norm += c.* * c.*;
    }

    return .{
        .total = total,
        .centered = centered,
        .norm = @sqrt(norm),
        .allocator = alloc,
    };
}

/// The mean of the uncentered log radii, which `buildTarget` subtracts away. Kept
/// separate so `Target.radii` can put it back without storing a redundant copy.
pub fn meanLogRadius(edges: []const Edge, x: []const f64, n: usize, d: usize, alloc: std.mem.Allocator) !f64 {
    const acc = try alloc.alloc(f64, n);
    defer alloc.free(acc);
    const tot = try alloc.alloc(f64, n);
    defer alloc.free(tot);
    @memset(acc, 0);
    @memset(tot, 0);
    for (edges) |e| {
        // Was this loop written out in index form. See the note on the dense
        // variant below.
        const s = similarity.stz_sim_euclidean_sq(x[e.i * d ..].ptr, x[e.j * d ..].ptr, @intCast(d));
        acc[e.i] += e.w * s;
        acc[e.j] += e.w * s;
        tot[e.i] += e.w;
        tot[e.j] += e.w;
    }
    var mean: f64 = 0;
    for (0..n) |i| {
        const r = if (tot[i] > 0) acc[i] / tot[i] else 0;
        mean += @log(@max(r, MIN_RADIUS));
    }
    return mean / @as(f64, @floatFromInt(n));
}

/// Scratch buffers for the per-epoch reduction, allocated once and reused.
pub const Workspace = struct {
    /// embedding radius per point, then its centered log, then dCorr/du_i
    radius: []f64,
    grad: []f64,
    /// set when the radii carry no spread, so the correlation is undefined and the
    /// only correct push is none at all
    degenerate: bool = false,
    allocator: std.mem.Allocator,

    pub fn init(alloc: std.mem.Allocator, n: usize) !Workspace {
        return .{
            .radius = try alloc.alloc(f64, n),
            .grad = try alloc.alloc(f64, n),
            .allocator = alloc,
        };
    }

    pub fn deinit(self: *Workspace) void {
        self.allocator.free(self.radius);
        self.allocator.free(self.grad);
    }
};

/// The Pearson correlation between the original and current embedding log-radii.
/// Returned for its own sake -- it is the number that says whether the term is doing
/// anything, and a caller who cannot see it has to take the effect on faith.
pub fn correlation(
    target: *const Target,
    ws: *Workspace,
    edges: []const Edge,
    y: []const f64,
    n: usize,
    dims: usize,
) f64 {
    computeRadii(ws, edges, y, n, dims, target.total);
    const st = centerLogs(ws.radius, n);
    if (st.norm < MIN_SPREAD or target.norm < MIN_SPREAD) return 0;
    var dot: f64 = 0;
    for (0..n) |i| dot += ws.radius[i] * target.centered[i];
    return dot / (st.norm * target.norm);
}

/// Add lambda * d(correlation)/dy to the embedding, in place.
///
/// MAXIMISING the correlation, so the step is along +gradient -- the opposite sign to
/// the cross-entropy terms around it, which minimise. Returns the correlation before
/// the step, so a caller can report or trace it without a second reduction.
pub fn applyGradient(
    target: *const Target,
    ws: *Workspace,
    edges: []const Edge,
    y: []f64,
    n: usize,
    dims: usize,
    lambda: f64,
    alpha: f64,
    clipFn: *const fn (f64) f64,
) f64 {
    computeRadii(ws, edges, y, n, dims, target.total);

    // keep the radii: the gradient needs 1/R_i, and centerLogs overwrites in place
    var i: usize = 0;
    while (i < n) : (i += 1) ws.grad[i] = @max(ws.radius[i], MIN_RADIUS);

    const corr = pointCoefficients(target, ws, n);
    if (corr == 0 and target.norm < MIN_SPREAD) return 0;
    if (ws.degenerate) return 0;

    // ONE pass over the edges. An edge (i,j) enters BOTH radii, so its two endpoints
    // move by the same vector in opposite directions -- the term cannot translate the
    // embedding, only stretch and shrink it. Which is right: density is a statement
    // about spacing, and where the whole picture sits is not part of it.
    for (edges) |e| {
        const ii: usize = e.i;
        const jj: usize = e.j;
        const c = e.w * (ws.grad[ii] + ws.grad[jj]) * lambda * alpha;
        for (0..dims) |t| {
            const delta = clipFn(c * (y[ii * dims + t] - y[jj * dims + t]));
            y[ii * dims + t] += delta;
            y[jj * dims + t] -= delta;
        }
    }
    return corr;
}

/// ACCUMULATE lambda * d(-correlation)/dy into a gradient buffer, sparse edges.
///
/// The counterpart of `applyGradient` for an optimiser that has a gradient buffer
/// rather than writing the layout directly -- parametric UMAP, where the answer has to
/// reach the network's weights and cannot be written into y at all. NEGATED for the
/// same reason the dense one is: the caller subtracts what it is given.
pub fn accumulateGradient(
    target: *const Target,
    ws: *Workspace,
    edges: []const Edge,
    y: []const f64,
    dy: []f64,
    n: usize,
    dims: usize,
    lambda: f64,
) f64 {
    computeRadii(ws, edges, y, n, dims, target.total);
    for (0..n) |i| ws.grad[i] = @max(ws.radius[i], MIN_RADIUS);

    const corr = pointCoefficients(target, ws, n);
    if (ws.degenerate) return 0;

    for (edges) |e| {
        const ii: usize = e.i;
        const jj: usize = e.j;
        const c = e.w * (ws.grad[ii] + ws.grad[jj]) * lambda;
        for (0..dims) |t| {
            const g = c * (y[ii * dims + t] - y[jj * dims + t]);
            dy[ii * dims + t] -= g;
            dy[jj * dims + t] += g;
        }
    }
    return corr;
}

// --- DENSE VARIANT: the same density, a different p_ij ----------------------
//
// t-SNE's joint distribution is a full n-by-n matrix summing to 1, so its p_ij are
// tiny (order 1/n^2) where UMAP's are order 1. THAT SCALE CANCELS in the radius,
// which divides by P_i, and again in the gradient, where the 1/P_i meets a p_ij --
// so a lambda tuned for one algorithm is not therefore meaningless in the other.
// It is not transferable either; the surrounding optimisers differ far more.

/// Original-space radii from a DENSE joint distribution. Same formula as
/// `buildTarget`; only the enumeration of pairs differs.
pub fn buildTargetDense(
    alloc: std.mem.Allocator,
    pmat: []const f64,
    x: []const f64,
    n: usize,
    d: usize,
) !Target {
    const total = try alloc.alloc(f64, n);
    errdefer alloc.free(total);
    const centered = try alloc.alloc(f64, n);
    errdefer alloc.free(centered);
    @memset(total, 0);
    @memset(centered, 0);

    for (0..n) |i| {
        for (i + 1..n) |j| {
            const w = pmat[i * n + j];
            if (w <= 0) continue;
            // A squared euclidean distance, written out here in index form
            // inside an O(n^2) loop while similarity.zig held the same sum
            // lane-parallel. It is the fifth place in this engine that had
            // its own copy of one of these; it delegates now.
            //
            // Lane summation re-associates, so this is not bit-identical --
            // the same trade the ann change made, and acceptable for the same
            // reason: these are distances between data points, all terms
            // non-negative and of like magnitude, so the cancellation regime
            // that makes re-association matter cannot arise. The result feeds
            // a @log of a mean radius in t-SNE/UMAP calibration, whose guards
            // assert behaviour, not last bits.
            const s = similarity.stz_sim_euclidean_sq(x[i * d ..].ptr, x[j * d ..].ptr, @intCast(d));
            centered[i] += w * s;
            centered[j] += w * s;
            total[i] += w;
            total[j] += w;
        }
    }

    var mean: f64 = 0;
    for (0..n) |i| {
        const r = if (total[i] > 0) centered[i] / total[i] else 0;
        centered[i] = @log(@max(r, MIN_RADIUS));
        mean += centered[i];
    }
    mean /= @floatFromInt(n);

    var norm: f64 = 0;
    for (centered) |*c| {
        c.* -= mean;
        norm += c.* * c.*;
    }
    return .{ .total = total, .centered = centered, .norm = @sqrt(norm), .allocator = alloc };
}

/// The mean uncentered log radius for the dense case -- see `meanLogRadius`.
pub fn meanLogRadiusDense(
    pmat: []const f64,
    x: []const f64,
    n: usize,
    d: usize,
    alloc: std.mem.Allocator,
) !f64 {
    const acc = try alloc.alloc(f64, n);
    defer alloc.free(acc);
    const tot = try alloc.alloc(f64, n);
    defer alloc.free(tot);
    @memset(acc, 0);
    @memset(tot, 0);
    for (0..n) |i| {
        for (i + 1..n) |j| {
            const w = pmat[i * n + j];
            if (w <= 0) continue;
            var s: f64 = 0;
            for (0..d) |t| {
                const diff = x[i * d + t] - x[j * d + t];
                s += diff * diff;
            }
            acc[i] += w * s;
            acc[j] += w * s;
            tot[i] += w;
            tot[j] += w;
        }
    }
    var mean: f64 = 0;
    for (0..n) |i| {
        const r = if (tot[i] > 0) acc[i] / tot[i] else 0;
        mean += @log(@max(r, MIN_RADIUS));
    }
    return mean / @as(f64, @floatFromInt(n));
}

/// The correlation for a dense p_ij, without touching the layout.
pub fn correlationDense(
    target: *const Target,
    ws: *Workspace,
    pmat: []const f64,
    y: []const f64,
    n: usize,
    dims: usize,
) f64 {
    computeRadiiDense(ws, pmat, y, n, dims, target.total);
    const st = centerLogs(ws.radius, n);
    if (st.norm < MIN_SPREAD or target.norm < MIN_SPREAD) return 0;
    var dot: f64 = 0;
    for (0..n) |i| dot += ws.radius[i] * target.centered[i];
    return dot / (st.norm * target.norm);
}

/// ACCUMULATE lambda * d(-correlation)/dy into a gradient buffer.
///
/// NEGATED relative to the edge version on purpose. `applyGradient` moves the layout
/// itself and therefore steps along +gradient to maximise. This one feeds a buffer
/// that t-SNE SUBTRACTS, so maximising the correlation means adding its negative.
/// Getting this backwards would not crash -- it would quietly anti-preserve density,
/// which is why the sign is pinned by a test rather than by a comment alone.
pub fn accumulateGradientDense(
    target: *const Target,
    ws: *Workspace,
    pmat: []const f64,
    y: []const f64,
    dy: []f64,
    n: usize,
    dims: usize,
    lambda: f64,
) f64 {
    computeRadiiDense(ws, pmat, y, n, dims, target.total);
    for (0..n) |i| ws.grad[i] = @max(ws.radius[i], MIN_RADIUS);

    const corr = pointCoefficients(target, ws, n);
    if (ws.degenerate) return 0;

    for (0..n) |i| {
        for (i + 1..n) |j| {
            const w = pmat[i * n + j];
            if (w <= 0) continue;
            const c = w * (ws.grad[i] + ws.grad[j]) * lambda;
            for (0..dims) |t| {
                const g = c * (y[i * dims + t] - y[j * dims + t]);
                dy[i * dims + t] -= g;
                dy[j * dims + t] += g;
            }
        }
    }
    return corr;
}

// --- CALIBRATION: carrying the density contract to points the fit never saw --
//
// The fit's objective is a CORRELATION over every point. A single new point has
// nothing to correlate against, so the transform cannot reuse it -- this is a genuinely
// different mechanism rather than the same code applied twice.
//
// What the fit leaves behind is n pairs (log R_original, log R_embedded). A line
// through them says, for any original density, what embedded radius this particular
// map gives it. That line is the contract, and it EXTRAPOLATES: a new point sitting
// further from everything than any training row still gets an answer.
//
// THE LINE IS ONLY AS GOOD AS THE CORRELATION IT WAS DRAWN THROUGH. At a fit
// correlation of 0.9 it is a fair summary; at 0.2 it is a line through a cloud, and
// applying it would dress noise up as a measurement. Callers can see both numbers,
// which is the only reason it is safe to offer at all.

pub const Calibration = struct {
    slope: f64,
    intercept: f64,
    /// false when the fit had no density spread to learn from
    usable: bool,
};

/// Least squares of log R_embedded on log R_original over the training points.
pub fn calibrate(
    target: *const Target,
    ws: *Workspace,
    edges: []const Edge,
    y: []const f64,
    n: usize,
    dims: usize,
    mean_log_orig: f64,
) Calibration {
    computeRadii(ws, edges, y, n, dims, target.total);
    return calibrateFrom(target, ws, n, mean_log_orig);
}

/// The dense counterpart -- same line, t-SNE's p_ij.
pub fn calibrateDense(
    target: *const Target,
    ws: *Workspace,
    pmat: []const f64,
    y: []const f64,
    n: usize,
    dims: usize,
    mean_log_orig: f64,
) Calibration {
    computeRadiiDense(ws, pmat, y, n, dims, target.total);
    return calibrateFrom(target, ws, n, mean_log_orig);
}

fn calibrateFrom(target: *const Target, ws: *Workspace, n: usize, mean_log_orig: f64) Calibration {
    // ws.radius holds the raw embedded radii; centerLogs turns them into centered logs
    // and hands back the mean it removed, which the intercept needs
    var mean_emb: f64 = 0;
    for (0..n) |i| mean_emb += @log(@max(ws.radius[i], MIN_RADIUS));
    mean_emb /= @floatFromInt(n);

    var num: f64 = 0;
    var den: f64 = 0;
    for (0..n) |i| {
        const xe = target.centered[i];
        const ye = @log(@max(ws.radius[i], MIN_RADIUS)) - mean_emb;
        num += xe * ye;
        den += xe * xe;
    }
    if (den < MIN_SPREAD or target.norm < MIN_SPREAD) {
        return .{ .slope = 0, .intercept = mean_emb, .usable = false };
    }
    const slope = num / den;
    return .{ .slope = slope, .intercept = mean_emb - slope * mean_log_orig, .usable = true };
}

// --- internals --------------------------------------------------------------

/// THE SHARED CORE. Given the raw embedding radii in `ws.radius` and a copy of them
/// in `ws.grad`, leave `ws.grad` holding dCorr/dy's per-point coefficient and return
/// the correlation.
///
/// dCorr/du_i for the centered logs u: the mean-subtraction cross-terms sum to zero,
/// which is why this is the plain two-term expression rather than something involving
/// 1/n. Folded in with it: du_i/dR_i = 1/R_i, and the 2/P_i from the radius. What is
/// left to multiply each pair by is then just p_ij * (y_i - y_j) -- which is the only
/// line either traversal has to write for itself.
fn pointCoefficients(target: *const Target, ws: *Workspace, n: usize) f64 {
    const st = centerLogs(ws.radius, n);
    if (st.norm < MIN_SPREAD or target.norm < MIN_SPREAD) {
        ws.degenerate = true;
        return 0;
    }
    ws.degenerate = false;

    var dot: f64 = 0;
    for (0..n) |k| dot += ws.radius[k] * target.centered[k];
    const corr = dot / (st.norm * target.norm);

    for (0..n) |k| {
        const dcorr = target.centered[k] / (st.norm * target.norm) -
            corr * ws.radius[k] / (st.norm * st.norm);
        const pk = target.total[k];
        ws.grad[k] = if (pk > 0) 2.0 * dcorr / (pk * ws.grad[k]) else 0;
    }
    return corr;
}

fn computeRadiiDense(
    ws: *Workspace,
    pmat: []const f64,
    y: []const f64,
    n: usize,
    dims: usize,
    total: []const f64,
) void {
    @memset(ws.radius[0..n], 0);
    for (0..n) |i| {
        for (i + 1..n) |j| {
            const w = pmat[i * n + j];
            if (w <= 0) continue;
            var s: f64 = 0;
            for (0..dims) |t| {
                const diff = y[i * dims + t] - y[j * dims + t];
                s += diff * diff;
            }
            ws.radius[i] += w * s;
            ws.radius[j] += w * s;
        }
    }
    for (0..n) |i| {
        ws.radius[i] = if (total[i] > 0) ws.radius[i] / total[i] else 0;
    }
}

fn computeRadii(
    ws: *Workspace,
    edges: []const Edge,
    y: []const f64,
    n: usize,
    dims: usize,
    total: []const f64,
) void {
    @memset(ws.radius[0..n], 0);
    for (edges) |e| {
        const ii: usize = e.i;
        const jj: usize = e.j;
        var s: f64 = 0;
        for (0..dims) |t| {
            const diff = y[ii * dims + t] - y[jj * dims + t];
            s += diff * diff;
        }
        ws.radius[ii] += e.w * s;
        ws.radius[jj] += e.w * s;
    }
    for (0..n) |i| {
        ws.radius[i] = if (total[i] > 0) ws.radius[i] / total[i] else 0;
    }
}

const Stats = struct { norm: f64 };

/// log, then center, in place. Returns the norm of the centered values.
fn centerLogs(v: []f64, n: usize) Stats {
    var mean: f64 = 0;
    for (0..n) |i| {
        v[i] = @log(@max(v[i], MIN_RADIUS));
        mean += v[i];
    }
    mean /= @floatFromInt(n);
    var norm: f64 = 0;
    for (0..n) |i| {
        v[i] -= mean;
        norm += v[i] * v[i];
    }
    return .{ .norm = @sqrt(norm) };
}

// --- tests ------------------------------------------------------------------

const testing = std.testing;

fn noClip(v: f64) f64 {
    return v;
}

/// two tight points and two spread-out ones, fully connected with equal weights
fn tinyGraph(alloc: std.mem.Allocator) !struct { edges: []Edge, x: []f64 } {
    const x = try alloc.alloc(f64, 4 * 1);
    x[0] = 0.0;
    x[1] = 0.1; // a dense pair
    x[2] = 5.0;
    x[3] = 15.0; // a sparse pair
    const edges = try alloc.alloc(Edge, 3);
    edges[0] = .{ .i = 0, .j = 1, .w = 1.0 };
    edges[1] = .{ .i = 1, .j = 2, .w = 1.0 };
    edges[2] = .{ .i = 2, .j = 3, .w = 1.0 };
    return .{ .edges = edges, .x = x };
}

test "the local radius says which points sit in a sparse region" {
    const alloc = testing.allocator;
    const g = try tinyGraph(alloc);
    defer alloc.free(g.edges);
    defer alloc.free(g.x);

    var t = try buildTarget(alloc, g.edges, g.x, 4, 1);
    defer t.deinit();

    // point 0 has only its close neighbour (0.1 away), point 3 only its far one (10).
    // Their radii must be ordered accordingly, which is the whole premise.
    try testing.expect(t.centered[0] < t.centered[3]);
    // and point 0 is the tightest of all four
    for (1..4) |i| try testing.expect(t.centered[0] < t.centered[i]);
}

test "membership weights the radius -- a strong edge counts for more" {
    const alloc = testing.allocator;
    const x = [_]f64{ 0.0, 1.0, 10.0 };
    // point 0 joined weakly to a near point and strongly to a far one
    var strong = [_]Edge{
        .{ .i = 0, .j = 1, .w = 0.01 },
        .{ .i = 0, .j = 2, .w = 1.0 },
    };
    var weak = [_]Edge{
        .{ .i = 0, .j = 1, .w = 1.0 },
        .{ .i = 0, .j = 2, .w = 0.01 },
    };
    var ts = try buildTarget(alloc, &strong, &x, 3, 1);
    defer ts.deinit();
    var tw = try buildTarget(alloc, &weak, &x, 3, 1);
    defer tw.deinit();

    // NOT a comparison of the centered values across the two runs -- those are
    // centered against different means. Recover the raw radius for point 0 in each.
    const ms = try meanLogRadius(&strong, &x, 3, 1, alloc);
    const mw = try meanLogRadius(&weak, &x, 3, 1, alloc);
    const rs = @exp(ts.centered[0] + ms);
    const rw = @exp(tw.centered[0] + mw);
    try testing.expect(rs > rw * 10);
}

test "correlation is 1 when the embedding already has the right densities" {
    const alloc = testing.allocator;
    const g = try tinyGraph(alloc);
    defer alloc.free(g.edges);
    defer alloc.free(g.x);

    var t = try buildTarget(alloc, g.edges, g.x, 4, 1);
    defer t.deinit();
    var ws = try Workspace.init(alloc, 4);
    defer ws.deinit();

    // the embedding IS the data, so every radius matches exactly
    const c = correlation(&t, &ws, g.edges, g.x, 4, 1);
    try testing.expectApproxEqAbs(@as(f64, 1.0), c, 1e-12);
}

test "densities in the wrong ORDER give -0.60, and the reason is worth knowing" {
    const alloc = testing.allocator;
    const g = try tinyGraph(alloc);
    defer alloc.free(g.edges);
    defer alloc.free(g.x);

    var t = try buildTarget(alloc, g.edges, g.x, 4, 1);
    defer t.deinit();
    var ws = try Workspace.init(alloc, 4);
    defer ws.deinit();

    // mirror the spacing: what was tight is now spread and vice versa. The embedding
    // log-radii come out as the exact REVERSE of the original ones.
    const y = [_]f64{ 0.0, 10.0, 14.9, 15.0 };
    const c = correlation(&t, &ws, g.edges, &y, 4, 1);

    // I asserted this was below -0.9 and it is -0.600. REVERSING THE ORDER OF A
    // VECTOR IS NOT NEGATING IT: correlation -1 requires the embedding log-radii to be
    // an affine DECREASING function of the original ones, and a reversal only achieves
    // that when the values are symmetric about their mean, which these are not (the
    // original radii are -4.6, 2.5, 4.1, 4.6 -- one deep outlier and three bunched).
    //
    // Which matters beyond this test. A caller reading a reported correlation of, say,
    // 0.6 should not conclude "60% right": the scale is not a percentage of orderings
    // recovered, and an embedding that gets every density RANK backwards can still
    // score well above -1.
    try testing.expect(c < -0.5);
    try testing.expect(c > -0.7);
}

test "-1 needs NEGATED radii, not merely reversed ones" {
    const alloc = testing.allocator;
    // two DISJOINT edges, so each point's radius is exactly its own edge's length and
    // can be set directly -- a path graph averages two edges at its interior points
    // and takes that control away
    var edges = [_]Edge{
        .{ .i = 0, .j = 1, .w = 1.0 },
        .{ .i = 2, .j = 3, .w = 1.0 },
    };
    const x = [_]f64{ 0.0, 1.0, 0.0, 10.0 }; // radii 1, 1, 100, 100
    var t = try buildTarget(alloc, &edges, &x, 4, 1);
    defer t.deinit();
    var ws = try Workspace.init(alloc, 4);
    defer ws.deinit();

    // embedding radii 100, 100, 1, 1 -- so log R_emb = -log R_orig + const, exactly
    const y = [_]f64{ 0.0, 10.0, 0.0, 1.0 };
    const c = correlation(&t, &ws, &edges, &y, 4, 1);
    try testing.expectApproxEqAbs(@as(f64, -1.0), c, 1e-12);
}

test "the gradient IMPROVES the correlation, which is the only claim that matters" {
    const alloc = testing.allocator;
    const g = try tinyGraph(alloc);
    defer alloc.free(g.edges);
    defer alloc.free(g.x);

    var t = try buildTarget(alloc, g.edges, g.x, 4, 1);
    defer t.deinit();
    var ws = try Workspace.init(alloc, 4);
    defer ws.deinit();

    // start from the backwards embedding and take a few steps
    var y = [_]f64{ 0.0, 10.0, 14.9, 15.0 };
    const before = correlation(&t, &ws, g.edges, &y, 4, 1);
    var s: usize = 0;
    while (s < 200) : (s += 1) {
        _ = applyGradient(&t, &ws, g.edges, &y, 4, 1, 1.0, 0.05, noClip);
    }
    const after = correlation(&t, &ws, g.edges, &y, 4, 1);
    try testing.expect(after > before);
    try testing.expect(after > 0.5);
}

test "the term cannot translate the embedding -- only stretch it" {
    const alloc = testing.allocator;
    const g = try tinyGraph(alloc);
    defer alloc.free(g.edges);
    defer alloc.free(g.x);

    var t = try buildTarget(alloc, g.edges, g.x, 4, 1);
    defer t.deinit();
    var ws = try Workspace.init(alloc, 4);
    defer ws.deinit();

    var y = [_]f64{ 0.0, 10.0, 14.9, 15.0 };
    var before: f64 = 0;
    for (y) |v| before += v;
    _ = applyGradient(&t, &ws, g.edges, &y, 4, 1, 1.0, 0.05, noClip);
    var after: f64 = 0;
    for (y) |v| after += v;
    // each edge moves its endpoints by equal and opposite amounts, so the centroid is
    // invariant. Worth pinning: a density term that DRIFTED the layout would fight the
    // cross-entropy for no reason and be very hard to see.
    try testing.expectApproxEqAbs(before, after, 1e-9);
}

test "no density variation to preserve means no gradient at all" {
    const alloc = testing.allocator;
    // four points on a perfectly regular line: every radius identical
    const x = [_]f64{ 0.0, 1.0, 2.0, 3.0 };
    var edges = [_]Edge{
        .{ .i = 0, .j = 1, .w = 1.0 },
        .{ .i = 1, .j = 2, .w = 1.0 },
        .{ .i = 2, .j = 3, .w = 1.0 },
    };
    var t = try buildTarget(alloc, &edges, &x, 4, 1);
    defer t.deinit();
    var ws = try Workspace.init(alloc, 4);
    defer ws.deinit();

    // ends have one neighbour and middles have two, so there IS spread here; the
    // degenerate case is a single point repeated
    const flat = [_]f64{ 2.0, 2.0, 2.0, 2.0 };
    var t2 = try buildTarget(alloc, &edges, &flat, 4, 1);
    defer t2.deinit();
    try testing.expectApproxEqAbs(@as(f64, 0), t2.norm, 1e-12);

    var y = [_]f64{ 0.0, 1.0, 2.0, 3.0 };
    const saved = y;
    const c = applyGradient(&t2, &ws, &edges, &y, 4, 1, 1.0, 0.1, noClip);
    try testing.expectEqual(@as(f64, 0), c);
    // nothing moved: an undefined correlation must produce no push, not a NaN one
    for (y, saved) |a, b| try testing.expectEqual(b, a);
}

test "coincident points do not produce a NaN radius" {
    const alloc = testing.allocator;
    const x = [_]f64{ 3.0, 3.0, 3.0 };
    var edges = [_]Edge{
        .{ .i = 0, .j = 1, .w = 1.0 },
        .{ .i = 1, .j = 2, .w = 1.0 },
    };
    var t = try buildTarget(alloc, &edges, &x, 3, 1);
    defer t.deinit();
    for (t.centered) |c| try testing.expect(!std.math.isNan(c));
    try testing.expect(!std.math.isNan(t.norm));
}

test "DENSE and SPARSE agree when the same graph is expressed both ways" {
    const alloc = testing.allocator;
    // THE CHECK THAT MAKES "one definition" MORE THAN A CLAIM. Build one graph, hand
    // it to each traversal in that traversal's own representation, and require the
    // same answer. If the dense path ever drifted into a different notion of local
    // density, this is what would catch it.
    const n = 5;
    const x = [_]f64{ 0.0, 0.3, 1.0, 5.0, 12.0 };
    var edges = [_]Edge{
        .{ .i = 0, .j = 1, .w = 0.4 },
        .{ .i = 1, .j = 2, .w = 0.25 },
        .{ .i = 2, .j = 3, .w = 0.2 },
        .{ .i = 3, .j = 4, .w = 0.15 },
        .{ .i = 0, .j = 2, .w = 0.05 },
    };
    const pmat = try alloc.alloc(f64, n * n);
    defer alloc.free(pmat);
    @memset(pmat, 0);
    for (edges) |e| {
        pmat[e.i * n + e.j] = e.w;
        pmat[e.j * n + e.i] = e.w;
    }

    var ts = try buildTarget(alloc, &edges, &x, n, 1);
    defer ts.deinit();
    var td = try buildTargetDense(alloc, pmat, &x, n, 1);
    defer td.deinit();

    try testing.expectApproxEqAbs(ts.norm, td.norm, 1e-12);
    for (ts.total, td.total) |a, b| try testing.expectApproxEqAbs(a, b, 1e-12);
    for (ts.centered, td.centered) |a, b| try testing.expectApproxEqAbs(a, b, 1e-12);

    var ws = try Workspace.init(alloc, n);
    defer ws.deinit();
    const y = [_]f64{ 0.0, 1.0, 1.5, 4.0, 9.0 };
    const cs = correlation(&ts, &ws, &edges, &y, n, 1);
    const cd = correlationDense(&td, &ws, pmat, &y, n, 1);
    try testing.expectApproxEqAbs(cs, cd, 1e-12);
}

test "the dense gradient has the sign a DESCENT buffer needs" {
    const alloc = testing.allocator;
    const n = 5;
    const x = [_]f64{ 0.0, 0.3, 1.0, 5.0, 12.0 };
    const pmat = try alloc.alloc(f64, n * n);
    defer alloc.free(pmat);
    @memset(pmat, 0);
    const pairs = [_][3]f64{
        .{ 0, 1, 0.4 }, .{ 1, 2, 0.25 }, .{ 2, 3, 0.2 }, .{ 3, 4, 0.15 },
    };
    for (pairs) |pr| {
        const i: usize = @intFromFloat(pr[0]);
        const j: usize = @intFromFloat(pr[1]);
        pmat[i * n + j] = pr[2];
        pmat[j * n + i] = pr[2];
    }
    var t = try buildTargetDense(alloc, pmat, &x, n, 1);
    defer t.deinit();
    var ws = try Workspace.init(alloc, n);
    defer ws.deinit();

    // Start from a layout whose densities are backwards and DESCEND the buffer, which
    // is what t-SNE does with it. If the sign were flipped this would drive the
    // correlation DOWN while looking like it was working -- silent anti-preservation,
    // and a picture that is confidently wrong rather than merely uninformative. Hence
    // a test rather than a comment.
    //
    // THE STEP SIZE IS 200 ON PURPOSE, and finding that out was the useful part. At a
    // step of 0.02 the correlation improves by 0.015 over four hundred iterations and
    // the test looks like a sign error. The density gradient here is of order 1e-3 --
    // TINY in absolute terms, because p_ij are fractions and the coefficient carries a
    // 1/(P_i R_i). t-SNE's default learning rate of 200 is not an eccentricity; it is
    // what this scale of gradient requires, and the density term inherits it.
    var y = [_]f64{ 0.0, 8.0, 11.0, 11.7, 12.0 };
    const dy = try alloc.alloc(f64, n);
    defer alloc.free(dy);
    const before = correlationDense(&t, &ws, pmat, &y, n, 1);
    try testing.expect(before < -0.9);
    for (0..2000) |_| {
        @memset(dy, 0);
        _ = accumulateGradientDense(&t, &ws, pmat, &y, dy, n, 1, 1.0);
        for (0..n) |k| y[k] -= 200.0 * dy[k];
    }
    const after = correlationDense(&t, &ws, pmat, &y, n, 1);
    try testing.expect(after > 0.99);
}

test "a dense degenerate case pushes nothing rather than NaN" {
    const alloc = testing.allocator;
    const n = 4;
    const x = [_]f64{ 2.0, 2.0, 2.0, 2.0 };
    const pmat = try alloc.alloc(f64, n * n);
    defer alloc.free(pmat);
    for (pmat) |*v| v.* = 0.1;
    for (0..n) |i| pmat[i * n + i] = 0;

    var t = try buildTargetDense(alloc, pmat, &x, n, 1);
    defer t.deinit();
    var ws = try Workspace.init(alloc, n);
    defer ws.deinit();
    var y = [_]f64{ 0.0, 1.0, 2.0, 3.0 };
    const dy = try alloc.alloc(f64, n);
    defer alloc.free(dy);
    @memset(dy, 0);
    const c = accumulateGradientDense(&t, &ws, pmat, &y, dy, n, 1, 1.0);
    try testing.expectEqual(@as(f64, 0), c);
    for (dy) |v| try testing.expectEqual(@as(f64, 0), v);
}
