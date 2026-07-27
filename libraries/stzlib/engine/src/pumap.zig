//! PARAMETRIC UMAP -- the layout produced by a network rather than by free coordinates.
//!
//! Sainburg, McInnes and Gentner (2021), and the fourth corner of a square this library
//! now fills in completely:
//!
//!                      free coordinates          learned map
//!     t-SNE            tsne.zig                  ptsne.zig
//!     UMAP             umap.zig                  THIS FILE
//!
//! ── WHAT CHANGES, AND WHAT DOES NOT ──
//!
//! NOT the objective. UMAP's fuzzy simplicial set, its a/b curve, its attraction along
//! an edge and its repulsion from sampled non-neighbours are all imported from
//! `umap.zig` -- `buildGraph`, `attractCoeff`, `repelCoeff`. Nothing about what UMAP
//! MEANS is restated here, because a second transcription of those two coefficient
//! lines would be a second algorithm wearing the same name.
//!
//! What changes is only where the answer is allowed to live. The free-form optimiser
//! moves n*dims numbers that answer to nothing. Here those numbers are the output of
//! f(x; W), and the same gradient is pushed back into W instead -- which is exactly
//! what `nn.backwardFromDelta` is for.
//!
//! ── WHAT IT BUYS, AND WHAT IT COSTS ──
//!
//! BUYS: a transform that is EXACT. A new point is placed by a forward pass, and a
//! training row put back through it returns the number it was fitted to. UMAP's
//! free-form transform re-optimises against a frozen map and lands about 0.2 of the
//! typical spacing away, with only a quarter of rows nearest their own position.
//!
//! COSTS: the layout can only be as good as a function of x can be. Free coordinates
//! can put any point anywhere; a network must map nearby inputs to nearby outputs, so
//! anything the data does not express smoothly cannot be drawn.
//!
//! AND IT INHERITS THE PARAMETRIC BLINDNESS. Because the map is a bounded function, a
//! row far outside the training range saturates onto an ordinary-looking position --
//! measured at three thousandths for parametric t-SNE, and the same mechanism applies
//! here. Use `umap.localRadiiOfNew` for that; it asks the data, not the model.

const std = @import("std");
const umap = @import("umap.zig");
const nn = @import("nn.zig");
const density = @import("density.zig");

pub const Options = struct {
    n_neighbors: usize = 15,
    dims: usize = 2,
    min_dist: f64 = 0.1,
    spread: f64 = 1.0,
    epochs: usize = 400,
    /// the NETWORK's step size. The free-form optimiser's decaying alpha has no
    /// counterpart in the gradient here -- the schedule belongs to the weights, so it
    /// is applied to this instead and the gradient is left pure.
    learning_rate: f64 = 0.01,
    repulsion: f64 = 1.0,
    negative_samples: usize = 5,
    seed: u64 = 42,
    /// how far to trust supplied labels -- see umap.applyLabels
    target_weight: f64 = 0.5,
    /// density preservation (parametric densMAP)
    density_lambda: f64 = 0,
    density_frac: f64 = 0.3,
};

pub const Result = struct {
    /// n * dims -- f(X) for the training data
    embedding: []f64,
    /// the trained network, flattened, and its shape -- the same encoding ptsne uses,
    /// so its `transform` serves here unchanged: a forward pass is a forward pass, and
    /// which objective trained the weights is not its business
    weights: []f64,
    shape: []f64,
    /// the fitted curve parameters, reported because they are derived rather than given
    a: f64,
    b: f64,
    n: usize,
    dims: usize,
    local_radii: []f64,
    density_correlation: f64,
    allocator: std.mem.Allocator,

    pub fn deinit(self: *Result) void {
        self.allocator.free(self.embedding);
        self.allocator.free(self.weights);
        self.allocator.free(self.shape);
        if (self.local_radii.len > 0) self.allocator.free(self.local_radii);
        self.allocator.destroy(self);
    }
};

pub const Error = error{ TooFewPoints, BadNeighbors, OutOfMemory, DidNotConverge, BadShape };

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
    fn below(self: *Rng, m: usize) usize {
        return @intCast(self.next() % @as(u64, @intCast(m)));
    }
    fn uniform(self: *Rng) f64 {
        return @as(f64, @floatFromInt(self.next() >> 11)) / 9007199254740992.0;
    }
};

pub fn run(
    alloc: std.mem.Allocator,
    x: []const f64,
    n: usize,
    d: usize,
    hidden: []const usize,
    labels: ?[]const i32,
    opts: Options,
) !*Result {
    if (n < 3) return Error.TooFewPoints;
    if (hidden.len == 0) return Error.BadShape;
    const dims = opts.dims;
    if (dims == 0 or dims > 8) return Error.BadShape;

    // ── THE GRAPH, from umap.zig. Supervision included, because it is a property of
    //    the graph and not of the optimiser -- so it composes here for free. ──
    var graph = try umap.buildGraph(alloc, x, n, d, labels, .{
        .n_neighbors = opts.n_neighbors,
        .dims = dims,
        .min_dist = opts.min_dist,
        .spread = opts.spread,
        .target_weight = opts.target_weight,
    });
    defer graph.deinit();

    // THE SAME NETWORK CONVENTION AS ptsne.zig -- tanh hidden layers, a linear output,
    // Xavier initialisation, and one flat weight buffer the layers slice into. Two
    // parametric forms in one library disagreeing about how to build a network would
    // make every comparison between them a comparison of two things at once.
    const n_layers = hidden.len + 1;
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

    const y = try alloc.alloc(f64, n * dims);
    errdefer alloc.free(y);
    const dy = try alloc.alloc(f64, n * dims);
    defer alloc.free(dy);
    // how many edges touched each point this epoch -- see the note in the loop
    const visits = try alloc.alloc(usize, n);
    defer alloc.free(visits);

    var ws = try nn.Workspace.init(alloc, &net);
    defer ws.deinit();

    // the SAME edge schedule the free-form optimiser uses: a maximal edge is visited
    // every epoch, a weaker one proportionally less often. Keeping it means the two
    // forms are optimising the same stochastic realisation of the same objective, and
    // a difference between their pictures is a difference of parameterisation only.
    const eps = try alloc.alloc(f64, graph.edges.items.len);
    defer alloc.free(eps);
    const next_sample = try alloc.alloc(f64, graph.edges.items.len);
    defer alloc.free(next_sample);
    for (graph.edges.items, 0..) |e, i| {
        eps[i] = graph.wmax / e.w;
        next_sample[i] = eps[i];
    }

    // ── density preservation, when asked for ──
    const want_density = opts.density_lambda > 0 and n >= 3;
    var dens_target: ?density.Target = null;
    defer if (dens_target) |*dt| dt.deinit();
    var dens_ws: ?density.Workspace = null;
    defer if (dens_ws) |*dw| dw.deinit();
    var dens_corr: f64 = std.math.nan(f64);
    var dens_start: usize = opts.epochs;
    const de: []const density.Edge = @ptrCast(graph.edges.items);
    if (want_density) {
        dens_target = try density.buildTarget(alloc, de, x, n, d);
        dens_ws = try density.Workspace.init(alloc, n);
        const frac = @min(@max(opts.density_frac, 0.0), 1.0);
        const on_for: f64 = @as(f64, @floatFromInt(opts.epochs)) * frac;
        dens_start = opts.epochs -| @as(usize, @intFromFloat(on_for));
    }

    var scratch: [64]f64 = undefined;

    var epoch: usize = 0;
    while (epoch < opts.epochs) : (epoch += 1) {
        // forward everything, with the weights fixed for the whole pass
        for (0..n) |i| {
            nn.forwardInto(&net, &ws, x[i * d ..][0..d], y[i * dims ..][0..dims]);
        }

        @memset(dy, 0);
        @memset(visits, 0);

        // ── THE SIGN, which is the one thing easy to get wrong here ──
        //
        // The free-form optimiser writes `y[i] += g * alpha`, so +g is the direction
        // of improvement. `nn.backwardFromDelta` SUBTRACTS what it is given, so the
        // buffer must hold -g. Backwards would not crash; it would drive the layout
        // apart while looking like it was training.
        for (graph.edges.items, 0..) |e, ei| {
            if (next_sample[ei] > @as(f64, @floatFromInt(epoch + 1))) continue;
            next_sample[ei] += eps[ei];

            const ii: usize = e.i;
            const jj: usize = e.j;
            const yi = y[ii * dims ..][0..dims];
            const yj = y[jj * dims ..][0..dims];

            visits[ii] += 1;
            visits[jj] += 1;

            const d2 = umap.sqDist(yi, yj);
            const gc = umap.attractCoeff(d2, graph.a, graph.b);
            if (gc != 0) {
                for (0..dims) |t| {
                    const g = umap.clipGrad(gc * (yi[t] - yj[t]));
                    dy[ii * dims + t] -= g;
                    dy[jj * dims + t] += g;
                }
            }

            var s: usize = 0;
            while (s < opts.negative_samples) : (s += 1) {
                const kk = rng.below(n);
                if (kk == ii or kk == jj) continue;
                const yk = y[kk * dims ..][0..dims];
                const rc = umap.repelCoeff(umap.sqDist(yi, yk), graph.a, graph.b, opts.repulsion);
                for (0..dims) |t| {
                    dy[ii * dims + t] -= umap.clipGrad(rc * (yi[t] - yk[t]));
                }
            }
        }

        // ── AVERAGE, DO NOT SUM ──
        //
        // The free-form optimiser applies each edge's correction immediately with a
        // small decaying step. Accumulating a whole epoch and applying it once makes
        // the effective step proportional to HOW MANY EDGES TOUCH A POINT -- so a
        // hub in a dense region takes a stride, a leaf takes a shuffle, and the
        // learning rate that suits one ruins the other.
        //
        // MEASURED before this line existed, on three well-separated blobs:
        //
        //     lr      within-cluster   between   separation
        //     0.005      0.404          10.07       24.9
        //     0.01       0.482          42.0        87.1
        //     0.02       0.000004       27.08     6471293    <- MODE COLLAPSE
        //     0.05     437.2          1430.9         3.27    <- divergence
        //
        // A factor of two from the default and every point of a cluster mapped to the
        // SAME output -- and the separation ratio reported 6.5 million, which reads
        // like a triumph. Both failures produce a plausible-looking summary number,
        // which is exactly why the within-cluster spread has to be looked at too.
        //
        // Dividing by each point's visit count makes the step independent of graph
        // density and of n. It is the difference between a summed gradient and a mean
        // one, not a fudge factor.
        for (0..n) |i| {
            if (visits[i] > 0) {
                const inv = 1.0 / @as(f64, @floatFromInt(visits[i]));
                for (0..dims) |t| dy[i * dims + t] *= inv;
            }
        }

        if (want_density and epoch >= dens_start) {
            dens_corr = density.accumulateGradient(
                &dens_target.?,
                &dens_ws.?,
                de,
                y,
                dy,
                n,
                dims,
                opts.density_lambda,
            );
        }

        // the decay lives on the WEIGHTS' step, not on the gradient -- see Options
        const lr = opts.learning_rate *
            (1.0 - @as(f64, @floatFromInt(epoch)) / @as(f64, @floatFromInt(opts.epochs)) * 0.9);
        for (0..n) |i| {
            // the forward is repeated because the workspace holds only the LAST point's
            // activations, and a backward pass run against a stale forward is the
            // classic way to get a plausible-looking wrong gradient
            nn.forwardInto(&net, &ws, x[i * d ..][0..d], scratch[0..dims]);
            nn.backwardFromDelta(&net, &ws, dy[i * dims ..][0..dims], lr);
        }
    }

    // a final forward, so the reported embedding matches the FINAL weights rather than
    // the ones the last gradient was computed from
    for (0..n) |i| {
        nn.forwardInto(&net, &ws, x[i * d ..][0..d], y[i * dims ..][0..dims]);
    }

    var radii_out: []f64 = &[_]f64{};
    if (want_density) {
        const mean_log = try density.meanLogRadius(de, x, n, d, alloc);
        radii_out = try dens_target.?.radii(alloc, mean_log);
        dens_corr = density.correlation(&dens_target.?, &dens_ws.?, de, y, n, dims);
    }

    // the weight buffer IS already the flat encoding ptsne.transform understands --
    // the layers are slices into it, so training wrote through to it
    const shape = try alloc.alloc(f64, 2 + layers.len * 2);
    errdefer alloc.free(shape);
    shape[0] = @floatFromInt(d);
    shape[1] = @floatFromInt(layers.len);
    for (layers, 0..) |l, i| {
        shape[2 + i * 2] = @floatFromInt(l.units);
        shape[3 + i * 2] = @floatFromInt(@intFromEnum(l.kind));
    }

    const out = try alloc.create(Result);
    out.* = .{
        .embedding = y,
        .weights = weights,
        .shape = shape,
        .a = graph.a,
        .b = graph.b,
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
const ptsne = @import("ptsne.zig");

fn blobs(alloc: std.mem.Allocator, per: usize, d: usize) ![]f64 {
    const n = per * 3;
    const x = try alloc.alloc(f64, n * d);
    var st: u64 = 7;
    const centers = [_]f64{ 0, 20, 40 };
    for (0..3) |c| {
        for (0..per) |q| {
            const i = c * per + q;
            for (0..d) |j| {
                st = st *% 6364136223846793005 +% 1442695040888963407;
                const u = @as(f64, @floatFromInt(st >> 11)) / 9007199254740992.0;
                x[i * d + j] = centers[c] + (u - 0.5) * 1.0;
            }
        }
    }
    return x;
}

fn separation(v: []const f64, per: usize, dims: usize) f64 {
    var within: f64 = 0;
    var wc: f64 = 0;
    var between: f64 = 0;
    var bc: f64 = 0;
    const n = per * 3;
    for (0..n) |i| {
        for (i + 1..n) |j| {
            const dd = @sqrt(umap.sqDist(v[i * dims ..][0..dims], v[j * dims ..][0..dims]));
            if (i / per == j / per) {
                within += dd;
                wc += 1;
            } else {
                between += dd;
                bc += 1;
            }
        }
    }
    if (wc == 0 or bc == 0 or within == 0) return 0;
    return (between / bc) / (within / wc);
}

fn withinSpread(v: []const f64, per: usize, n: usize) f64 {
    var w: f64 = 0;
    var c: f64 = 0;
    for (0..n) |i| {
        for (i + 1..n) |j| {
            if (i / per != j / per) continue;
            w += @sqrt(umap.sqDist(v[i * 2 ..][0..2], v[j * 2 ..][0..2]));
            c += 1;
        }
    }
    return if (c > 0) w / c else 0;
}

test "the learned layout stands beside the free-form one" {
    const alloc = testing.allocator;
    const per = 20;
    const n = per * 3;
    const d = 4;
    const x = try blobs(alloc, per, d);
    defer alloc.free(x);
    const hidden = [_]usize{ 24, 24 };

    var f = try umap.run(alloc, x, n, d, .{ .n_neighbors = 6, .epochs = 400 });
    defer f.deinit();
    var r = try run(alloc, x, n, d, &hidden, null, .{
        .n_neighbors = 6,
        .epochs = 400,
        .learning_rate = 0.01,
    });
    defer r.deinit();

    // MEASURED: free-form separates these blobs 9.76, the network 30.3. Both find the
    // structure, which is all the data supports -- three well-separated blobs are not
    // a hard problem, and a larger ratio is not therefore a better picture.
    //
    // The a/b curve is the SAME one, because it came from umap.zig rather than being
    // written out again here: 1.5769 and 0.8951, which are the published values.
    try testing.expect(separation(r.embedding, per, 2) > 5.0);
    try testing.expectEqual(f.a, r.a);
    try testing.expectEqual(f.b, r.b);
}

test "AVERAGING THE GRADIENT is what makes the learning rate usable" {
    const alloc = testing.allocator;
    const per = 20;
    const n = per * 3;
    const d = 4;
    const x = try blobs(alloc, per, d);
    defer alloc.free(x);
    const hidden = [_]usize{ 24, 24 };

    // BEFORE the per-point average existed, on this data:
    //
    //     lr      within-cluster   between   separation
    //     0.005      0.404          10.07       24.9
    //     0.01       0.482          42.0        87.1
    //     0.02       0.000004       27.08     6471293    <- MODE COLLAPSE
    //     0.05     437.2          1430.9         3.27    <- divergence
    //
    // AFTER:
    //
    //     0.005      0.408          10.89       26.7
    //     0.01       0.385          11.67       30.3
    //     0.02       0.408           4.87       11.9
    //     0.05       3.933          40.01       10.2
    //
    // A summed epoch gradient makes each point's step proportional to how many edges
    // touch it, so a hub strides while a leaf shuffles and no single rate suits both.
    // Dividing by the visit count is the difference between a summed gradient and a
    // mean one.
    //
    // WHAT IS PINNED HERE IS THE FAILURE, NOT THE FIX: across a tenfold range of
    // learning rate the within-cluster spread stays finite and non-zero. A collapse
    // reads as ~0 and a divergence as hundreds, and BOTH used to report a plausible
    // separation ratio -- 6.5 million looks like a triumph and is every point of a
    // cluster mapped to the same output. Which is why a summary ratio is never checked
    // on its own here.
    const lrs = [_]f64{ 0.005, 0.01, 0.02, 0.05 };
    for (lrs) |lr| {
        var r = try run(alloc, x, n, d, &hidden, null, .{
            .n_neighbors = 6,
            .epochs = 400,
            .learning_rate = lr,
        });
        defer r.deinit();
        const w = withinSpread(r.embedding, per, n);
        try testing.expect(w > 1e-3); // not collapsed
        try testing.expect(w < 50); // not diverged
        try testing.expect(separation(r.embedding, per, 2) > 3.0);
    }
}

test "THE TRANSFORM IS EXACT, which is the whole reason to parameterise" {
    const alloc = testing.allocator;
    const per = 12;
    const n = per * 3;
    const d = 4;
    const x = try blobs(alloc, per, d);
    defer alloc.free(x);
    const hidden = [_]usize{16};

    var r = try run(alloc, x, n, d, &hidden, null, .{
        .n_neighbors = 5,
        .epochs = 200,
        .learning_rate = 0.01,
    });
    defer r.deinit();

    // ptsne's transform, unchanged: a forward pass is a forward pass, and which
    // objective trained the weights is not its business. Reusing it is the point --
    // two identical forward passes would be one too many.
    //
    // MEASURED over all training rows: displacement 0.0000000000. Free-form UMAP's
    // transform gives 0.807 on the same data, because it re-optimises against a frozen
    // map rather than evaluating a function.
    const back = try alloc.alloc(f64, n * 2);
    defer alloc.free(back);
    try ptsne.transform(alloc, r.shape, r.weights, x, n, back);
    for (back, r.embedding) |a, b| try testing.expectEqual(b, a);
}

test "and it inherits the parametric blindness, exactly as t-SNE's does" {
    const alloc = testing.allocator;
    const per = 20;
    const n = per * 3;
    const d = 4;
    const x = try blobs(alloc, per, d);
    defer alloc.free(x);
    const hidden = [_]usize{ 24, 24 };

    var r = try run(alloc, x, n, d, &hidden, null, .{
        .n_neighbors = 6,
        .epochs = 400,
        .learning_rate = 0.01,
    });
    defer r.deinit();

    // a legitimate row and one far outside anything the fit saw. MEASURED: they come
    // back 0.000001 apart. Bounded activations send everything past a certain
    // magnitude to the same place, so the exactness that makes this transform
    // attractive is the same property that makes it blind.
    //
    // The free-form UMAP transform, for all that it is only approximate, WOULD have
    // placed that row outside the map.
    const newx = [_]f64{
        20.0, 20.0, 20.0, 20.0,
        900,  900,  900,  900,
    };
    const out = try alloc.alloc(f64, 2 * 2);
    defer alloc.free(out);
    try ptsne.transform(alloc, r.shape, r.weights, &newx, 2, out);
    try testing.expect(@sqrt(umap.sqDist(out[0..2], out[2..4])) < 0.01);

    // THE ANSWER COMES FROM THE DATA. umap.localRadiiOfNew asks the training set, and
    // the training set has not saturated.
    const radii = try alloc.alloc(f64, 2);
    defer alloc.free(radii);
    try umap.localRadiiOfNew(alloc, x, n, d, &newx, 2, 6, radii);
    try testing.expect(radii[1] > radii[0] * 100);
}

test "supervision composes, because it is a property of the GRAPH" {
    const alloc = testing.allocator;
    const per = 12;
    const n = per * 3;
    const d = 4;
    const x = try blobs(alloc, per, d);
    defer alloc.free(x);
    const hidden = [_]usize{16};
    const y = try alloc.alloc(i32, n);
    defer alloc.free(y);
    for (0..n) |i| y[i] = @intCast(i % 2);

    var r = try run(alloc, x, n, d, &hidden, y, .{
        .n_neighbors = 5,
        .epochs = 200,
        .learning_rate = 0.01,
        .target_weight = 0.2,
    });
    defer r.deinit();
    // nothing new was written to make this work: buildGraph applies the labels before
    // any optimiser sees the edges, so every optimiser gets it for free. That is the
    // dividend of extracting the graph rather than copying it.
    for (r.embedding) |v| try testing.expect(!std.math.isNan(v) and !std.math.isInf(v));
}

test "density preservation composes too" {
    const alloc = testing.allocator;
    const per = 12;
    const n = per * 3;
    const d = 4;
    const x = try blobs(alloc, per, d);
    defer alloc.free(x);
    const hidden = [_]usize{16};

    var r = try run(alloc, x, n, d, &hidden, null, .{
        .n_neighbors = 5,
        .epochs = 200,
        .learning_rate = 0.01,
        .density_lambda = 0.1,
    });
    defer r.deinit();
    try testing.expectEqual(n, r.local_radii.len);
    try testing.expect(!std.math.isNan(r.density_correlation));

    var plain = try run(alloc, x, n, d, &hidden, null, .{
        .n_neighbors = 5,
        .epochs = 200,
        .learning_rate = 0.01,
    });
    defer plain.deinit();
    try testing.expectEqual(@as(usize, 0), plain.local_radii.len);
    try testing.expect(std.math.isNan(plain.density_correlation));
}

test "a network with no hidden layer is refused rather than silently linear" {
    const alloc = testing.allocator;
    const per = 5;
    const n = per * 3;
    const d = 3;
    const x = try blobs(alloc, per, d);
    defer alloc.free(x);
    const none = [_]usize{};
    try testing.expectError(Error.BadShape, run(alloc, x, n, d, &none, null, .{ .n_neighbors = 3, .epochs = 10 }));
}
