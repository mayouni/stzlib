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
//! ── SHARED ON PURPOSE ──
//!
//! The same term defines den-SNE in the same paper. The radius, the correlation and
//! its gradient are written ONCE, here, so that a t-SNE variant cannot drift into a
//! second definition of what local density means.

const std = @import("std");

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
        var s: f64 = 0;
        for (0..d) |t| {
            const diff = x[e.i * d + t] - x[e.j * d + t];
            s += diff * diff;
        }
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

    const st = centerLogs(ws.radius, n);
    if (st.norm < MIN_SPREAD or target.norm < MIN_SPREAD) return 0;

    var dot: f64 = 0;
    for (0..n) |k| dot += ws.radius[k] * target.centered[k];
    const corr = dot / (st.norm * target.norm);

    // dCorr/du_i for the centered logs u. The mean-subtraction cross-terms sum to
    // zero, which is why this is the plain two-term expression and not something
    // involving 1/n.
    //
    // Folded into it: du_i/dR_i = 1/R_i, and the 2/P_i from the radius itself. What
    // is left multiplying each edge is then just p_ij * (y_i - y_j).
    for (0..n) |k| {
        const dcorr = target.centered[k] / (st.norm * target.norm) -
            corr * ws.radius[k] / (st.norm * st.norm);
        const p = target.total[k];
        ws.grad[k] = if (p > 0) 2.0 * dcorr / (p * ws.grad[k]) else 0;
    }

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

// --- internals --------------------------------------------------------------

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
