//! PARAMETRIC t-SNE: van der Maaten (2009), "Learning a Parametric Embedding by
//! Preserving Local Structure".
//!
//! ── THE PROBLEM IT SOLVES ──
//!
//! Ordinary t-SNE optimises the POSITIONS of the points it was given. There is no
//! function anywhere in it, so there is nothing to apply to a new point -- which is
//! why stzTSNE has no Transform() and stzUMAP does.
//!
//! The parametric variant changes what is being optimised. Instead of n*2 free
//! coordinates, it trains a NEURAL NETWORK f(x) -> R^2 against the SAME objective,
//! KL(P || Q). The embedding is then whatever the network outputs, and a new point
//! is one forward pass. The map exists because it was made to exist.
//!
//! ── WHAT IT COSTS, AND THE PAPER SAYS SO TOO ──
//!
//! The embedding is generally SOMEWHAT WORSE than non-parametric t-SNE on the same
//! data. Free coordinates can go anywhere; a network's outputs are constrained to
//! what the network can express, so the optimiser is searching a smaller space. You
//! are trading some quality of the picture for the ability to place new points in
//! it. That is a real trade and not a free upgrade.
//!
//! ── WHAT THIS IS BUILT FROM, WHICH IS THE POINT ──
//!
//! Almost nothing here is new. The high-dimensional distribution P and the KL
//! gradient come from `tsne.zig`; the forward pass and the backward pass come from
//! `nn.zig`, built in phase 6. Parametric t-SNE is those two pieces joined:
//!
//!     P            <- tsne.jointP          (perplexity, binary search, symmetrise)
//!     Y = f(X)     <- nn.forwardInto       (the network IS the embedding)
//!     dKL/dY       <- tsne.klGradient      (the same gradient the direct form uses)
//!     dKL/dweights <- nn.backwardFromDelta (chain it through the network)
//!
//! `nn.train` computes its own output delta from per-sample TARGETS, which is what
//! supervised learning is. This objective has no targets -- the gradient at point i
//! depends on every other point -- so phase 6's backward pass was split out to take
//! a SUPPLIED delta. That is the whole extension.
//!
//! ── ONE APPROXIMATION, STATED ──
//!
//! The gradient dKL/dY is computed once per epoch from the positions at the START of
//! that epoch, and then applied point by point while the weights move. So the later
//! points in an epoch are corrected using a slightly stale gradient. This is what
//! minibatch training does in general and what the paper does with minibatches; the
//! alternative is accumulating the whole epoch's weight gradient before applying it,
//! which converges more slowly per unit of work.

const std = @import("std");
const tsne = @import("tsne.zig");
const nn = @import("nn.zig");
const density = @import("density.zig");
const umap = @import("umap.zig");

pub const Options = struct {
    perplexity: f64 = 30,
    dims: usize = 2,
    epochs: usize = 400,
    learning_rate: f64 = 0.01,
    exaggeration: f64 = 12,
    exaggeration_epochs: usize = 100,
    seed: u64 = 42,

    /// DENSITY PRESERVATION (parametric den-SNE). 0 leaves the algorithm as it was.
    ///
    /// THIS IS WHERE den-SNE GAINS A TRANSFORM. Classic t-SNE has none -- it optimises
    /// the points it was given and a new point has no position -- so the density
    /// contract had nowhere to go. Here the network IS the map, the density gradient
    /// chains back into its weights like any other, and the transform is then density
    /// preserving BY CONSTRUCTION rather than by a correction applied afterwards.
    density_lambda: f64 = 0,

    /// the FINAL fraction of epochs during which the term is active
    density_frac: f64 = 0.3,
};

pub const Result = struct {
    /// n * dims -- f(X) for the training data
    embedding: []f64,
    /// KL per epoch
    kl: []f64,
    /// the trained network, flattened: per layer W (units*prev) then b (units)
    weights: []f64,
    /// [ n_inputs, n_layers, units1, act1, ... ] -- the same encoding the nn bridge
    /// uses, so Transform is an ordinary forward pass and needs no new machinery
    shape: []f64,
    n: usize,
    dims: usize,

    /// ORIGINAL-space local radius per training point; empty unless density was used
    local_radii: []f64,
    /// correlation between original and embedded log-radii at the end of training.
    /// NaN when the term was never switched on.
    density_correlation: f64,

    allocator: std.mem.Allocator,

    pub fn deinit(self: *Result) void {
        if (self.local_radii.len > 0) self.allocator.free(self.local_radii);
        self.allocator.free(self.embedding);
        self.allocator.free(self.kl);
        self.allocator.free(self.weights);
        self.allocator.free(self.shape);
        self.allocator.destroy(self);
    }
};

pub const Error = error{ TooFewPoints, BadPerplexity, NoLayers, OutOfMemory };

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
};

/// Train a network to embed `x` (n*d). `hidden` gives the hidden layer widths; the
/// output layer is always LINEAR and `dims` wide, because an embedding coordinate is
/// unbounded and squashing it through a tanh would cap the layout at a box.
pub fn run(
    alloc: std.mem.Allocator,
    x: []const f64,
    n: usize,
    d: usize,
    hidden: []const usize,
    opts: Options,
) !*Result {
    if (n < 3) return Error.TooFewPoints;
    if (opts.perplexity < 1 or opts.perplexity > @as(f64, @floatFromInt(n - 1)))
        return Error.BadPerplexity;
    if (hidden.len == 0) return Error.NoLayers;

    const dims = opts.dims;
    const n_layers = hidden.len + 1;

    // ── the network ──
    const layers = try alloc.alloc(nn.Layer, n_layers);
    defer alloc.free(layers);

    var total_w: usize = 0;
    var prev = d;
    for (hidden, 0..) |h, i| {
        layers[i] = .{ .units = h, .prev = prev, .kind = .tanh, .w = &[_]f64{}, .b = &[_]f64{} };
        total_w += h * prev + h;
        prev = h;
    }
    layers[n_layers - 1] = .{ .units = dims, .prev = prev, .kind = .linear, .w = &[_]f64{}, .b = &[_]f64{} };
    total_w += dims * prev + dims;

    const weights = try alloc.alloc(f64, total_w);
    errdefer alloc.free(weights);

    // XAVIER INITIALISATION, not the +-1 the supervised trainer uses. That scheme was
    // tuned for a 2-input XOR net; here the input can be thirty-dimensional, and
    // weights of order 1 would drive every tanh straight into saturation where its
    // derivative is zero and nothing learns.
    var rng = Rng.init(opts.seed);
    var at: usize = 0;
    for (layers) |*l| {
        const fan_in: f64 = @floatFromInt(l.prev);
        const fan_out: f64 = @floatFromInt(l.units);
        const lim = @sqrt(6.0 / (fan_in + fan_out));
        l.w = weights[at..][0 .. l.units * l.prev];
        at += l.units * l.prev;
        l.b = weights[at..][0..l.units];
        at += l.units;
        for (l.w) |*v| v.* = (rng.uniform() * 2 - 1) * lim;
        for (l.b) |*v| v.* = 0;
    }

    var net = nn.Net{ .n_inputs = d, .layers = layers };

    // ── P, from tsne.zig -- one definition of it in the library ──
    const p = try alloc.alloc(f64, n * n);
    defer alloc.free(p);
    try tsne.jointP(alloc, x, n, d, opts.perplexity, p);

    const y = try alloc.alloc(f64, n * dims);
    errdefer alloc.free(y);
    const dy = try alloc.alloc(f64, n * dims);
    defer alloc.free(dy);
    const q_num = try alloc.alloc(f64, n * n);
    defer alloc.free(q_num);

    var ws = try nn.Workspace.init(alloc, &net);
    defer ws.deinit();

    const kl = try alloc.alloc(f64, opts.epochs);
    errdefer alloc.free(kl);

    // ── DENSITY PRESERVATION, when asked for ──
    //
    // Built from the same symmetrised P the KL term uses, and NOT from the exaggerated
    // copy -- exaggeration is a temporary distortion of scale, and density measured
    // against it would preserve a picture about to be discarded.
    const want_density = opts.density_lambda > 0 and n >= 3;
    var dens_target: ?density.Target = null;
    defer if (dens_target) |*dt| dt.deinit();
    var dens_ws: ?density.Workspace = null;
    defer if (dens_ws) |*dw| dw.deinit();
    var dens_corr: f64 = std.math.nan(f64);
    var dens_start: usize = opts.epochs;
    if (want_density) {
        dens_target = try density.buildTargetDense(alloc, p, x, n, d);
        dens_ws = try density.Workspace.init(alloc, n);
        const frac = @min(@max(opts.density_frac, 0.0), 1.0);
        const on_for: f64 = @as(f64, @floatFromInt(opts.epochs)) * frac;
        dens_start = opts.epochs -| @as(usize, @intFromFloat(on_for));
    }

    var epoch: usize = 0;
    while (epoch < opts.epochs) : (epoch += 1) {
        // forward everything, with the weights fixed for the whole pass
        for (0..n) |i| {
            nn.forwardInto(&net, &ws, x[i * d ..][0..d], y[i * dims ..][0..dims]);
        }

        const scale: f64 = if (epoch < opts.exaggeration_epochs) opts.exaggeration else 1;
        kl[epoch] = tsne.klGradient(p, y, n, dims, scale, q_num, dy);

        // Straight into `dy`, which is the network's OUTPUT DELTA. Nothing else is
        // needed: backwardFromDelta chains whatever it is given through the weights,
        // and it exists precisely so a caller can supply a delta the network could not
        // have derived from targets of its own. The density term is that caller.
        if (want_density and epoch >= dens_start) {
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

        // push each point's share of the gradient back through the network. The
        // forward is repeated because the workspace holds only the LAST point's
        // activations, and a backward pass run against a stale forward is the classic
        // way to get a plausible-looking wrong gradient.
        var scratch: [64]f64 = undefined;
        for (0..n) |i| {
            nn.forwardInto(&net, &ws, x[i * d ..][0..d], scratch[0..dims]);
            nn.backwardFromDelta(&net, &ws, dy[i * dims ..][0..dims], opts.learning_rate);
        }
    }

    // a final forward, so the reported embedding matches the FINAL weights rather
    // than the ones the last gradient was computed from
    for (0..n) |i| {
        nn.forwardInto(&net, &ws, x[i * d ..][0..d], y[i * dims ..][0..dims]);
    }

    const shape = try alloc.alloc(f64, 2 + n_layers * 2);
    errdefer alloc.free(shape);
    shape[0] = @floatFromInt(d);
    shape[1] = @floatFromInt(n_layers);
    for (layers, 0..) |l, i| {
        shape[2 + i * 2] = @floatFromInt(l.units);
        shape[3 + i * 2] = @floatFromInt(@intFromEnum(l.kind));
    }

    const p_mat = p;
    var radii_out: []f64 = &[_]f64{};
    if (want_density) {
        const mean_log = try density.meanLogRadiusDense(p_mat, x, n, d, alloc);
        radii_out = try dens_target.?.radii(alloc, mean_log);
        // measured against the FINAL forward pass, so the number describes the network
        // actually returned rather than the one the last gradient came from
        dens_corr = density.correlationDense(&dens_target.?, &dens_ws.?, p_mat, y, n, dims);
    }

    const out = try alloc.create(Result);
    out.* = .{
        .embedding = y,
        .kl = kl,
        .weights = weights,
        .shape = shape,
        .n = n,
        .dims = dims,
        .local_radii = radii_out,
        .density_correlation = dens_corr,
        .allocator = alloc,
    };
    return out;
}

/// Place new points: ONE FORWARD PASS. Nothing is optimised, nothing is stochastic,
/// and the same input always gives the same output -- which is the entire reason the
/// parametric variant exists.
pub fn transform(
    alloc: std.mem.Allocator,
    shape: []const f64,
    weights: []f64,
    new_x: []const f64,
    m: usize,
    out: []f64,
) !void {
    const d: usize = @intFromFloat(shape[0]);
    const n_layers: usize = @intFromFloat(shape[1]);
    const layers = try alloc.alloc(nn.Layer, n_layers);
    defer alloc.free(layers);

    var prev = d;
    var at: usize = 0;
    for (0..n_layers) |i| {
        const units: usize = @intFromFloat(shape[2 + i * 2]);
        const code: u8 = @intFromFloat(shape[3 + i * 2]);
        layers[i] = .{
            .units = units,
            .prev = prev,
            .kind = @enumFromInt(code),
            .w = weights[at..][0 .. units * prev],
            .b = weights[at + units * prev ..][0..units],
        };
        at += units * prev + units;
        prev = units;
    }

    var net = nn.Net{ .n_inputs = d, .layers = layers };
    var ws = try nn.Workspace.init(alloc, &net);
    defer ws.deinit();
    for (0..m) |i| {
        nn.forwardInto(&net, &ws, new_x[i * d ..][0..d], out[i * prev ..][0..prev]);
    }
}

// ─── tests ───────────────────────────────────────────────────────────────────

const testing = std.testing;

fn blobs(alloc: std.mem.Allocator, per: usize, d: usize) ![]f64 {
    const n = per * 3;
    const x = try alloc.alloc(f64, n * d);
    var rng = Rng.init(7);
    const centers = [_]f64{ 0, 20, 40 };
    for (0..3) |c| {
        for (0..per) |k| {
            const i = c * per + k;
            for (0..d) |j| x[i * d + j] = centers[c] + rng.uniform() * 0.5;
        }
    }
    return x;
}

fn sq(a: []const f64, b: []const f64) f64 {
    var s: f64 = 0;
    for (a, b) |p, q| {
        const dd = p - q;
        s += dd * dd;
    }
    return s;
}

test "the objective goes down -- the network IS learning the embedding" {
    const alloc = testing.allocator;
    const per = 12;
    const n = per * 3;
    const d = 5;
    const x = try blobs(alloc, per, d);
    defer alloc.free(x);

    var r = try run(alloc, x, n, d, &.{ 20, 10 }, .{
        .perplexity = 5,
        .epochs = 400,
        .learning_rate = 0.02,
    });
    defer r.deinit();
    // after early exaggeration ends, where the objective stops changing shape
    try testing.expect(r.kl[399] < r.kl[150]);
    try testing.expect(r.kl[399] >= 0);
    for (r.embedding) |v| try testing.expect(std.math.isFinite(v));
}

test "TRANSFORM IS A FUNCTION -- the whole point of the parametric variant" {
    const alloc = testing.allocator;
    const per = 12;
    const n = per * 3;
    const d = 5;
    const x = try blobs(alloc, per, d);
    defer alloc.free(x);

    var r = try run(alloc, x, n, d, &.{ 20, 10 }, .{ .perplexity = 5, .epochs = 300, .learning_rate = 0.02 });
    defer r.deinit();

    // transforming the TRAINING data must reproduce the training embedding EXACTLY.
    // Not approximately -- the embedding IS f(X), so this is the same computation.
    // UMAP's transform could only manage "lands in the right cluster", because it
    // re-optimises; here there is nothing to re-optimise.
    const back = try alloc.alloc(f64, n * 2);
    defer alloc.free(back);
    try transform(alloc, r.shape, r.weights, x, n, back);
    for (r.embedding, back) |p, q| try testing.expectEqual(p, q);
}

test "a new point lands with the cluster it resembles" {
    const alloc = testing.allocator;
    const per = 12;
    const n = per * 3;
    const d = 5;
    const x = try blobs(alloc, per, d);
    defer alloc.free(x);

    var r = try run(alloc, x, n, d, &.{ 20, 10 }, .{ .perplexity = 5, .epochs = 500, .learning_rate = 0.02 });
    defer r.deinit();

    var newx: [15]f64 = undefined;
    for (0..3) |c| {
        for (0..d) |j| newx[c * d + j] = @as(f64, @floatFromInt(c)) * 20.0 + 0.25;
    }
    var out: [6]f64 = undefined;
    try transform(alloc, r.shape, r.weights, &newx, 3, &out);

    for (0..3) |c| {
        var best: usize = 0;
        var bestv = std.math.inf(f64);
        for (0..n) |j| {
            const dd = sq(out[c * 2 ..][0..2], r.embedding[j * 2 ..][0..2]);
            if (dd < bestv) {
                bestv = dd;
                best = j;
            }
        }
        try testing.expectEqual(c, best / per);
    }
}

test "transform is stateless and repeatable" {
    const alloc = testing.allocator;
    const per = 8;
    const n = per * 3;
    const d = 4;
    const x = try blobs(alloc, per, d);
    defer alloc.free(x);
    var r = try run(alloc, x, n, d, &.{12}, .{ .perplexity = 4, .epochs = 150, .learning_rate = 0.02 });
    defer r.deinit();

    const nx = [_]f64{ 0.2, 0.2, 0.2, 0.2 };
    var o1: [2]f64 = undefined;
    var o2: [2]f64 = undefined;
    try transform(alloc, r.shape, r.weights, &nx, 1, &o1);
    try transform(alloc, r.shape, r.weights, &nx, 1, &o2);
    try testing.expectEqual(o1[0], o2[0]);
    try testing.expectEqual(o1[1], o2[1]);
}

test "the same seed gives the same network" {
    const alloc = testing.allocator;
    const per = 8;
    const n = per * 3;
    const d = 4;
    const x = try blobs(alloc, per, d);
    defer alloc.free(x);
    var a = try run(alloc, x, n, d, &.{10}, .{ .perplexity = 4, .epochs = 100, .seed = 3 });
    defer a.deinit();
    var b = try run(alloc, x, n, d, &.{10}, .{ .perplexity = 4, .epochs = 100, .seed = 3 });
    defer b.deinit();
    for (a.weights, b.weights) |p, q| try testing.expectEqual(p, q);
}

test "what it refuses" {
    const alloc = testing.allocator;
    const x = [_]f64{ 0, 0, 1, 1, 2, 2, 3, 3, 4, 4 };
    try testing.expectError(Error.BadPerplexity, run(alloc, &x, 5, 2, &.{4}, .{ .perplexity = 30 }));
    try testing.expectError(Error.TooFewPoints, run(alloc, &x, 2, 2, &.{4}, .{ .perplexity = 1 }));
    try testing.expectError(Error.NoLayers, run(alloc, &x, 5, 2, &.{}, .{ .perplexity = 2 }));
}

/// two clusters differing TWENTYFOLD in spread
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

fn spreadOf(v: []const f64, lo: usize, hi: usize) f64 {
    var s: f64 = 0;
    var c: f64 = 0;
    for (lo..hi) |i| {
        for (i + 1..hi) |j| {
            s += @sqrt(tsne.sqDist(v[i * 2 ..][0..2], v[j * 2 ..][0..2]));
            c += 1;
        }
    }
    return if (c > 0) s / c else 0;
}

test "A SMOOTH MAP PRESERVES DENSITY FOR FREE -- 0.975 with no density term at all" {
    const alloc = testing.allocator;
    const per = 25;
    const n = per * 2;
    const d = 4;
    const x = try twoDensities(alloc, per, d);
    defer alloc.free(x);
    const hidden = [_]usize{ 16, 16 };

    var r = try run(alloc, x, n, d, &hidden, .{
        .perplexity = 10,
        .epochs = 600,
        // small enough to move nothing; large enough to report the correlation
        .density_lambda = 1e-300,
    });
    defer r.deinit();

    // THE FINDING, AND IT IS THE OPPOSITE OF THE CLASSIC ALGORITHM'S -- ON THIS DATA.
    // Plain t-SNE scores about 0.04 here, which is noise. Plain PARAMETRIC t-SNE scores
    // 0.975 with no density term whatever.
    //
    // The reason is the parameterisation. A network is a SMOOTH function of its input,
    // so it cannot tear the space arbitrarily: rows close in the input stay close in the
    // output, and a tight cluster therefore stays tight. The constraint that makes
    // parametric t-SNE less expressive than the free-form kind is the same constraint
    // that keeps its densities honest.
    //
    // BUT IT IS NOT A GUARANTEE, and a second dataset says so plainly: the same
    // configuration there scores -0.42 with no density term -- inverted. Smoothness
    // makes density preservation LIKELY, not certain, and which way a particular fit
    // went is not deducible from the algorithm. It has to be read off the correlation.
    //
    // Which is the conclusion this whole family of work keeps arriving at from a
    // different direction each time.
    try testing.expect(r.density_correlation > 0.9);
    try testing.expect(spreadOf(r.embedding, per, n) / spreadOf(r.embedding, 0, per) > 3.0);
}

test "the density term still adds something, in a NARROW usable range" {
    const alloc = testing.allocator;
    const per = 25;
    const n = per * 2;
    const d = 4;
    const x = try twoDensities(alloc, per, d);
    defer alloc.free(x);
    const hidden = [_]usize{ 16, 16 };

    // MEASURED:
    //
    //     lambda    corr     drawn ratio    KL
    //      ~0      0.975        5.25       0.795
    //      0.5     0.989        8.80       0.778
    //      1.0     0.992       10.55       0.774
    //      5.0    -0.933        0.05       0.788      INVERTED
    //     20.0    -0.993        0.00       1.070      INVERTED
    //
    // Below about 1 it sharpens a picture that was already good, pushing the drawn
    // ratio from 5.2 toward the true 20 -- and the KL slightly IMPROVES, which the
    // classic algorithm never did. Past about 5 the map turns INSIDE OUT: the diffuse
    // cluster is drawn at essentially zero spread and the correlation goes to -0.99.
    //
    // The violence of that failure is a consequence of the parameterisation too. The
    // classic algorithm has n independent points to absorb a heavy push; a network has
    // a few hundred weights SHARED by every point, so an overweighted term does not
    // distort one region, it deforms the whole function.
    //
    // AND THE THRESHOLD MOVES WITH THE NETWORK. At 50 points, two layers of 16 and 600
    // epochs, lambda 1 gives +0.992. At 30 points, two layers of 12 and 300 epochs, THE
    // SAME lambda 1 gives -0.973 -- fully inverted. Fewer weights and fewer epochs mean
    // less capacity to satisfy both terms, and the density term wins outright.
    //
    // So there is no safe default to be had here, only a safe HABIT: read the
    // correlation. It is reported for exactly this reason, and a negative value means
    // the map is inside out however sensible the settings looked.
    var lo = try run(alloc, x, n, d, &hidden, .{ .perplexity = 10, .epochs = 600, .density_lambda = 1e-300 });
    defer lo.deinit();
    var mid = try run(alloc, x, n, d, &hidden, .{ .perplexity = 10, .epochs = 600, .density_lambda = 1.0 });
    defer mid.deinit();
    var over = try run(alloc, x, n, d, &hidden, .{ .perplexity = 10, .epochs = 600, .density_lambda = 20.0 });
    defer over.deinit();

    try testing.expect(mid.density_correlation > lo.density_correlation);
    try testing.expect(spreadOf(mid.embedding, per, n) / spreadOf(mid.embedding, 0, per) >
        spreadOf(lo.embedding, per, n) / spreadOf(lo.embedding, 0, per));

    // and the inversion, pinned so that nobody discovers it in a plot
    try testing.expect(over.density_correlation < -0.5);
}

test "THE TRANSFORM IS EXACT, which is what the parametric form is for" {
    const alloc = testing.allocator;
    const per = 25;
    const n = per * 2;
    const d = 4;
    const x = try twoDensities(alloc, per, d);
    defer alloc.free(x);
    const hidden = [_]usize{ 16, 16 };

    var r = try run(alloc, x, n, d, &hidden, .{ .perplexity = 10, .epochs = 600, .density_lambda = 1.0 });
    defer r.deinit();

    // Put a training row back through Transform and it reproduces its fitted position
    // TO THE LAST BIT -- the forward pass IS the embedding, so there is nothing to
    // approximate. UMAP's transform re-optimises and lands about 0.2 of the typical
    // spacing away; this one does not land near, it returns the same number.
    const one = try alloc.alloc(f64, 2);
    defer alloc.free(one);
    try transform(alloc, r.shape, r.weights, x[0..d], 1, one);
    try testing.expectEqual(r.embedding[0], one[0]);
    try testing.expectEqual(r.embedding[1], one[1]);

    // and the density it learned comes with it, because the network IS density
    // preserving rather than being corrected afterwards
    try testing.expect(r.density_correlation > 0.8);
}

test "the exactness holds whatever the density term did" {
    const alloc = testing.allocator;
    // deliberately the configuration where lambda 1 INVERTS -- see the note in the
    // narrow-range test. Exactness is a property of the forward pass and owes nothing
    // to whether the map is any good, which is worth separating: a transform can be
    // perfectly faithful to a map that is perfectly wrong.
    const per = 15;
    const n = per * 2;
    const d = 4;
    const x = try twoDensities(alloc, per, d);
    defer alloc.free(x);
    const hidden = [_]usize{ 12, 12 };

    var r = try run(alloc, x, n, d, &hidden, .{ .perplexity = 6, .epochs = 300, .density_lambda = 1.0 });
    defer r.deinit();
    try testing.expect(r.density_correlation < 0);

    const one = try alloc.alloc(f64, 2);
    defer alloc.free(one);
    try transform(alloc, r.shape, r.weights, x[0..d], 1, one);
    try testing.expectEqual(r.embedding[0], one[0]);
    try testing.expectEqual(r.embedding[1], one[1]);
}

test "BUT THE NETWORK SATURATES, so the transform is blind to an outlier" {
    const alloc = testing.allocator;
    const per = 25;
    const n = per * 2;
    const d = 4;
    const x = try twoDensities(alloc, per, d);
    defer alloc.free(x);
    const hidden = [_]usize{ 16, 16 };

    var r = try run(alloc, x, n, d, &hidden, .{ .perplexity = 10, .epochs = 600, .density_lambda = 1.0 });
    defer r.deinit();
    try testing.expect(r.density_correlation > 0.8);

    // a legitimate diffuse-cluster row, and one TEN TIMES further out in every
    // coordinate than anything the fit ever saw
    const newx = [_]f64{
        20.0, 20.0, 20.0, 20.0,
        200,  200,  200,  200,
    };
    const out = try alloc.alloc(f64, 2 * 2);
    defer alloc.free(out);
    try transform(alloc, r.shape, r.weights, &newx, 2, out);

    // MEASURED: they land 0.65 apart, against a distance of 5.39 between the two
    // clusters -- so the outlier moves 12% of the map's own scale and stays firmly
    // inside the group it does not belong to. At a heavier weight it is starker still:
    // (-2.1100, -9.7090) against (-2.1118, -9.7117), three thousandths apart.
    //
    // Bounded activations send everything past a certain magnitude to the same place,
    // so the parametric transform is not merely inaccurate on unfamiliar input -- it is
    // STRUCTURALLY BLIND to it, and it fails SILENTLY, returning a perfectly ordinary
    // looking pair of coordinates.
    //
    // THIS IS THE EXACT INVERSE OF THE UMAP TRANSFORM'S PROFILE. That one re-optimises,
    // so it is only approximate on training rows, but it CAN place an outlier outside
    // the map (reach 5.99 against 0.79). This one is exact on training rows and cannot
    // see an outlier at all. Neither is better -- they fail in opposite directions, and
    // a caller ought to know which one they are holding.
    var between: f64 = 0;
    for (0..per) |i| {
        for (per..n) |j| between += @sqrt(tsne.sqDist(r.embedding[i * 2 ..][0..2], r.embedding[j * 2 ..][0..2]));
    }
    between /= @floatFromInt(per * per);
    const gap = @sqrt(tsne.sqDist(out[0..2], out[2..4]));
    try testing.expect(gap / between < 0.3);

    // THE ANSWER HAS TO COME FROM THE DATA, NOT THE NETWORK. This measures the new row
    // against the training set, where 356 units from anything is 356 units from
    // anything no matter what any model believes.
    const radii = try alloc.alloc(f64, 2);
    defer alloc.free(radii);
    try umap.localRadiiOfNew(alloc, x, n, d, &newx, 2, 8, radii);
    try testing.expect(radii[1] > radii[0] * 100);
    var train_max: f64 = 0;
    for (r.local_radii) |v| train_max = @max(train_max, v);
    try testing.expect(radii[0] < train_max * 2);
    try testing.expect(radii[1] > train_max * 10);
}

test "lambda 0 is EXACTLY the ordinary parametric fit" {
    const alloc = testing.allocator;
    const per = 10;
    const n = per * 2;
    const d = 3;
    const x = try twoDensities(alloc, per, d);
    defer alloc.free(x);
    const hidden = [_]usize{8};

    var plain = try run(alloc, x, n, d, &hidden, .{ .perplexity = 5, .epochs = 200 });
    defer plain.deinit();
    var zero = try run(alloc, x, n, d, &hidden, .{ .perplexity = 5, .epochs = 200, .density_lambda = 0 });
    defer zero.deinit();
    for (plain.embedding, zero.embedding) |a, b| try testing.expectEqual(a, b);
    try testing.expectEqual(@as(usize, 0), zero.local_radii.len);
    try testing.expect(std.math.isNan(zero.density_correlation));
}
