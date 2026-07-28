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

    // ── THE NETWORK'S INPUT MUST BE STANDARDISED, and this is not a preference ──
    //
    // MEASURED, on two clusters differing twentyfold in spread with the diffuse one
    // centred at 20:
    //
    //     raw input           density correlation -0.9934,  diffuse spread 0.0000
    //     standardised        density correlation +0.9967,  diffuse spread 1.0751
    //
    // The whole diffuse cluster collapsed to a POINT and the density correlation came
    // out fully INVERTED -- from rescaling the input, nothing else. An input of
    // magnitude 20 across four features drives the first tanh to |z| ~ 37, where it is
    // flat to about 1e-32: every row of that cluster becomes literally the same vector
    // to the first layer, and no gradient can pull apart points the network cannot
    // tell apart.
    //
    // This is where the free-form optimiser and this one genuinely differ in their
    // REQUIREMENTS rather than their results. Free coordinates are moved by distances
    // and do not care what units those distances are in. A network's input scale
    // decides whether its activations carry information at all, so the scaling is a
    // requirement of the parameterisation and belongs to the algorithm, not the caller.
    //
    // The GRAPH is still built from the data exactly as given -- see above, it was
    // built before this point. Only the network's view is rescaled.
    const mean = try alloc.alloc(f64, d);
    defer alloc.free(mean);
    const sdev = try alloc.alloc(f64, d);
    defer alloc.free(sdev);
    const xs = try alloc.alloc(f64, n * d);
    defer alloc.free(xs);
    for (0..d) |t| {
        var m: f64 = 0;
        for (0..n) |i| m += x[i * d + t];
        m /= @floatFromInt(n);
        var v: f64 = 0;
        for (0..n) |i| {
            const q = x[i * d + t] - m;
            v += q * q;
        }
        // a constant feature has no scale to divide by, and dividing would be a NaN
        const sd = @sqrt(v / @as(f64, @floatFromInt(n)));
        mean[t] = m;
        sdev[t] = if (sd > 1e-12) sd else 1.0;
        for (0..n) |i| xs[i * d + t] = (x[i * d + t] - m) / sdev[t];
    }

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
    // the PRE-SUPERVISION weights, so that turning labels on cannot redefine what
    // density means -- see umap.Graph.raw_w
    const dens_buf = try alloc.alloc(umap.Edge, graph.edges.items.len);
    defer alloc.free(dens_buf);
    const de: []const density.Edge = @ptrCast(graph.densityEdges(dens_buf));
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
            nn.forwardInto(&net, &ws, xs[i * d ..][0..d], y[i * dims ..][0..dims]);
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
            nn.forwardInto(&net, &ws, xs[i * d ..][0..d], scratch[0..dims]);
            nn.backwardFromDelta(&net, &ws, dy[i * dims ..][0..dims], lr);
        }
    }

    // ── FOLD THE STANDARDISATION INTO THE FIRST LAYER ──
    //
    // The network was trained on (x - m)/s, so a caller handing it a raw row would get
    // a different function. Rather than return m and s and require every caller to
    // remember them -- a standing invitation to forget one -- rewrite the first layer
    // so it does the rescaling itself:
    //
    //     w'[u][p] = w[u][p] / s[p]
    //     b'[u]    = b[u] - sum_p w[u][p] * m[p] / s[p]
    //
    // which gives w'.x + b' = w.((x-m)/s) + b exactly. The returned weights are then a
    // function of the RAW input, ptsne.transform serves unchanged, and the whole thing
    // stays stateless -- no scaling parameters travelling alongside the model, waiting
    // to be lost.
    {
        const l0 = &layers[0];
        for (0..l0.units) |u| {
            var shift: f64 = 0;
            for (0..l0.prev) |q| {
                const w0 = l0.w[u * l0.prev + q];
                shift += w0 * mean[q] / sdev[q];
                l0.w[u * l0.prev + q] = w0 / sdev[q];
            }
            l0.b[u] -= shift;
        }
    }

    // a final forward FROM THE RAW INPUT, which both reports the embedding against the
    // final weights and checks the fold: if it were wrong, every number below would be
    // wrong with it and the tests would say so immediately
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


// ─── INVERSE TRANSFORM: from the picture back to the data ────────────────────
//
// Everything else in this family runs one way -- data to embedding. This runs the
// other, and it is the only direction that needs a second model, because the forward
// map threw information away and no amount of cleverness gets it back.
//
// ── WHAT IT CAN AND CANNOT BE ──
//
// Two dimensions cannot hold thirty. The inverse therefore recovers what the embedding
// KEPT and invents the rest, and the honest way to say that is with a number: compare
// its reconstruction against what you would get by simply returning the nearest
// training row. If a trained decoder cannot beat that lookup it has added nothing but
// a model to maintain.
//
// ── WHY A SEPARATE MODEL RATHER THAN A JOINT ONE ──
//
// The paper's parametric UMAP can be trained as an autoencoder, with a reconstruction
// loss added to the UMAP objective. That makes the embedding MORE invertible and less
// faithful to the neighbourhood structure -- a real trade, and one that changes the
// picture the caller already looked at. Training the decoder afterwards, against the
// frozen embedding, leaves the map exactly as it was. The map is the deliverable; the
// inverse is a convenience on top of it.

pub const Decoder = struct {
    weights: []f64,
    shape: []f64,
    /// mean training loss per epoch, so a caller can see it went down
    loss: []f64,
    allocator: std.mem.Allocator,

    pub fn deinit(self: *Decoder) void {
        self.allocator.free(self.weights);
        self.allocator.free(self.shape);
        self.allocator.free(self.loss);
        self.allocator.destroy(self);
    }
};

/// Train g(y) ~ x against the frozen embedding.
///
/// BOTH ENDS ARE STANDARDISED AND BOTH ARE FOLDED BACK, for the same reason the encoder
/// standardises its input: a tanh fed coordinates of magnitude 400 -- which parametric
/// embeddings reach -- is flat, and an MSE against targets of magnitude 20 starts
/// enormous. Folding means the returned network maps RAW embedding coordinates to RAW
/// data coordinates, so `ptsne.transform` inverts with no scaling parameters to carry.
///
///     input  fold:  w' = w/s_y,   b' = b - sum(w * m_y / s_y)
///     output fold:  w'' = w * s_x, b'' = b * s_x + m_x
pub fn trainDecoder(
    alloc: std.mem.Allocator,
    y: []const f64,
    x: []const f64,
    n: usize,
    dims: usize,
    d: usize,
    hidden: []const usize,
    lr: f64,
    epochs: usize,
    seed: u64,
) !*Decoder {
    if (n < 2 or dims == 0 or d == 0) return Error.TooFewPoints;
    if (hidden.len == 0) return Error.BadShape;

    const n_layers = hidden.len + 1;
    const layers = try alloc.alloc(nn.Layer, n_layers);
    defer alloc.free(layers);

    var total_w: usize = 0;
    var prev = dims;
    for (hidden, 0..) |h, i| {
        layers[i] = .{ .units = h, .prev = prev, .kind = .tanh, .w = &[_]f64{}, .b = &[_]f64{} };
        total_w += h * prev + h;
        prev = h;
    }
    layers[n_layers - 1] = .{ .units = d, .prev = prev, .kind = .linear, .w = &[_]f64{}, .b = &[_]f64{} };
    total_w += d * prev + d;

    const weights = try alloc.alloc(f64, total_w);
    errdefer alloc.free(weights);

    var rng = Rng.init(seed);
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
    var net = nn.Net{ .n_inputs = dims, .layers = layers };

    // standardise both ends
    const my = try alloc.alloc(f64, dims);
    defer alloc.free(my);
    const sy = try alloc.alloc(f64, dims);
    defer alloc.free(sy);
    const ys = try alloc.alloc(f64, n * dims);
    defer alloc.free(ys);
    standardise(y, n, dims, my, sy, ys);

    const mx = try alloc.alloc(f64, d);
    defer alloc.free(mx);
    const sx = try alloc.alloc(f64, d);
    defer alloc.free(sx);
    const xs = try alloc.alloc(f64, n * d);
    defer alloc.free(xs);
    standardise(x, n, d, mx, sx, xs);

    const loss = try alloc.alloc(f64, epochs);
    errdefer alloc.free(loss);
    try nn.train(alloc, &net, ys, xs, n, d, lr, epochs, loss);

    // fold the input scaling into the first layer
    {
        const l0 = &layers[0];
        for (0..l0.units) |u| {
            var shift: f64 = 0;
            for (0..l0.prev) |q| {
                const w0 = l0.w[u * l0.prev + q];
                shift += w0 * my[q] / sy[q];
                l0.w[u * l0.prev + q] = w0 / sy[q];
            }
            l0.b[u] -= shift;
        }
    }
    // and the output scaling into the last
    {
        const ln = &layers[n_layers - 1];
        for (0..ln.units) |u| {
            for (0..ln.prev) |q| ln.w[u * ln.prev + q] *= sx[u];
            ln.b[u] = ln.b[u] * sx[u] + mx[u];
        }
    }

    const shape = try alloc.alloc(f64, 2 + n_layers * 2);
    errdefer alloc.free(shape);
    shape[0] = @floatFromInt(dims);
    shape[1] = @floatFromInt(n_layers);
    for (layers, 0..) |l, i| {
        shape[2 + i * 2] = @floatFromInt(l.units);
        shape[3 + i * 2] = @floatFromInt(@intFromEnum(l.kind));
    }

    const out = try alloc.create(Decoder);
    out.* = .{ .weights = weights, .shape = shape, .loss = loss, .allocator = alloc };
    return out;
}

fn standardise(v: []const f64, n: usize, w: usize, mean: []f64, sdev: []f64, out: []f64) void {
    for (0..w) |t| {
        var m: f64 = 0;
        for (0..n) |i| m += v[i * w + t];
        m /= @floatFromInt(n);
        var q: f64 = 0;
        for (0..n) |i| {
            const z = v[i * w + t] - m;
            q += z * z;
        }
        const sd = @sqrt(q / @as(f64, @floatFromInt(n)));
        mean[t] = m;
        sdev[t] = if (sd > 1e-12) sd else 1.0;
        for (0..n) |i| out[i * w + t] = (v[i * w + t] - m) / sdev[t];
    }
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

    // BEFORE the per-point average existed, on raw input:
    //
    //     lr      within-cluster   between   separation
    //     0.005      0.404          10.07       24.9
    //     0.01       0.482          42.0        87.1
    //     0.02       0.000004       27.08     6471293    <- MODE COLLAPSE
    //     0.05     437.2          1430.9         3.27    <- divergence
    //
    // A summed epoch gradient makes a point's step proportional to how many edges
    // touch it, so a hub lurches while a leaf shuffles and no single rate suits both.
    // Dividing by the visit count is the difference between a summed gradient and a
    // mean one.
    //
    // AFTER averaging AND standardising the network's input, the usable band MOVED --
    // which it had to, since inputs of order 1 rather than 20 make the same nominal
    // rate a larger effective step:
    //
    //     0.005      0.370   sep      58.8
    //     0.01       0.240   sep     209.6
    //     0.02       0.240   sep     755.7
    //     0.05       0.000532  sep 216168.9   <- collapses again
    //
    // So what is claimed is a WORKING RANGE, not universal stability: 0.005 to 0.02,
    // with the default at 0.01 sitting inside it. Pretending the edge is not there
    // would be the same mistake the 6471293 taught -- a huge separation ratio with a
    // vanishing within-cluster spread is a collapse, not a triumph.
    const lrs = [_]f64{ 0.005, 0.01, 0.02 };
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

    // and the edge, pinned rather than hidden: past the band it collapses, and the
    // separation ratio goes UP as it does
    var over = try run(alloc, x, n, d, &hidden, null, .{
        .n_neighbors = 6,
        .epochs = 400,
        .learning_rate = 0.05,
    });
    defer over.deinit();
    try testing.expect(withinSpread(over.embedding, per, n) < 1e-3);
    try testing.expect(separation(over.embedding, per, 2) > 1000);
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
    // MEASURED against the map's own scale rather than in absolute units, because
    // standardising the input changed the scale. On THIS data the two rows land 4.78
    // apart in a layout whose clusters sit some fifty apart -- a tenth of the way, so
    // a row twenty times beyond anything the fit saw is drawn just outside its
    // neighbours rather than off the map.
    //
    // BUT THE VERDICT IS DATA-DEPENDENT, and that is the more useful fact. Before
    // standardisation the gap was 0.000001 -- blind on every dataset. After it:
    //
    //     this data       gap   4.8 against clusters  50 apart  ->  11%, still blind
    //     another         gap 419.7 against clusters 424 apart  ->  99%, not blind
    //
    // The folded first layer divides by the training spread, so how far a row must be
    // before it saturates depends on how spread the training data was. Standardisation
    // improved the failure without removing it, and NEITHER outcome is something to
    // rely on -- which is why the out-of-distribution answer below comes from the data
    // and not from where the network happened to put the point.
    var between: f64 = 0;
    var bc: f64 = 0;
    for (0..per) |i| {
        for (per * 2..n) |j| {
            between += @sqrt(umap.sqDist(r.embedding[i * 2 ..][0..2], r.embedding[j * 2 ..][0..2]));
            bc += 1;
        }
    }
    between /= bc;
    try testing.expect(@sqrt(umap.sqDist(out[0..2], out[2..4])) < between * 0.25);

    // THE ANSWER COMES FROM THE DATA. umap.localRadiiOfNew asks the training set, and
    // the training set has not saturated.
    const radii = try alloc.alloc(f64, 2);
    defer alloc.free(radii);
    try umap.localRadiiOfNew(alloc, x, n, d, &newx, 2, 6, radii);
    try testing.expect(radii[1] > radii[0] * 100);
}

/// randomly placed rows, so that alternating labels carry NO spatial structure
fn scattered(alloc: std.mem.Allocator, n: usize, d: usize) ![]f64 {
    const x = try alloc.alloc(f64, n * d);
    var st: u64 = 12345;
    for (x) |*v| {
        st = st *% 6364136223846793005 +% 1442695040888963407;
        v.* = @as(f64, @floatFromInt(st >> 11)) / 9007199254740992.0 * 10.0;
    }
    return x;
}

fn labelSeparation(v: []const f64, lab: []const i32, n: usize) f64 {
    var w: f64 = 0;
    var wc: f64 = 0;
    var b: f64 = 0;
    var bc: f64 = 0;
    for (0..n) |i| {
        for (i + 1..n) |j| {
            const dd = @sqrt(umap.sqDist(v[i * 2 ..][0..2], v[j * 2 ..][0..2]));
            if (lab[i] == lab[j]) {
                w += dd;
                wc += 1;
            } else {
                b += dd;
                bc += 1;
            }
        }
    }
    if (wc == 0 or bc == 0 or w == 0) return 0;
    return (b / bc) / (w / wc);
}

test "supervision composes -- it is a property of the GRAPH, not the optimiser" {
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

test "SUPERVISION REACHES A LEARNED MAP ONLY PARTLY" {
    const alloc = testing.allocator;
    const n = 40;
    const d = 4;
    const x = try scattered(alloc, n, d);
    defer alloc.free(x);
    const lab = try alloc.alloc(i32, n);
    defer alloc.free(lab);
    for (0..n) |i| lab[i] = @intCast(i % 2);
    const hidden = [_]usize{ 24, 24 };

    // Randomly placed points with alternating labels: data containing NO class
    // structure, so any separation is supervision's doing and nothing else's. Testing
    // this on separable data would prove nothing -- both runs would separate it.
    //
    // THE COMPARISON IS RUN INSIDE THE TEST rather than pinned to a number, because
    // the magnitude moves a lot with the data and only the RELATION is stable:
    //
    //     this data           free-form 1.179 -> 2.413  (x2.05)
    //                        parametric 1.191 -> 1.635  (x1.37)
    //     a second dataset    free-form 0.987 -> 1.597  (x1.62)
    //                        parametric 0.972 -> 1.046  (x1.08)
    //
    // Same direction both times, magnitude quite different -- which is why the claim
    // is "supervision reaches a learned map only PARTLY" and not "barely at all". I
    // wrote the stronger version first, from the second dataset alone, and the control
    // on this one contradicted it.
    //
    // THE REASON IS THE PARAMETERISATION. y = f(x) is smooth, so two points close in x
    // must come out close in y. Free coordinates answer to nothing and can put
    // interleaved points wherever the labels ask; a function cannot. And it is
    // STRUCTURAL rather than undertrained, which was checked: 2x24 units/400 epochs
    // gives 1.046 on the second dataset, 2x64/1500 gives 0.965, and 3x128/3000 gives
    // 1.029. Eight times the parameters and seven times the training buy nothing.
    //
    // This is the mirror of the transform result. Parameterising buys EXACTNESS on new
    // points and costs EXPRESSIVENESS on the old ones; here the cost is the visible
    // half. Anyone reaching for supervised parametric UMAP because they want the
    // classes pulled apart should know they will get part of the way.
    var ff = try umap.run(alloc, x, n, d, .{ .n_neighbors = 6, .epochs = 300 });
    defer ff.deinit();
    var fs = try umap.runSupervised(alloc, x, n, d, lab, .{
        .n_neighbors = 6,
        .epochs = 300,
        .target_weight = 0.9,
    });
    defer fs.deinit();
    var plain = try run(alloc, x, n, d, &hidden, null, .{
        .n_neighbors = 6,
        .epochs = 400,
        .learning_rate = 0.01,
    });
    defer plain.deinit();
    var sup = try run(alloc, x, n, d, &hidden, lab, .{
        .n_neighbors = 6,
        .epochs = 400,
        .learning_rate = 0.01,
        .target_weight = 0.9,
    });
    defer sup.deinit();

    const free_gain = labelSeparation(fs.embedding, lab, n) / labelSeparation(ff.embedding, lab, n);
    const par_gain = labelSeparation(sup.embedding, lab, n) / labelSeparation(plain.embedding, lab, n);

    // the labels DO reach the graph -- this is not a wiring failure
    try testing.expect(par_gain > 1.05);
    try testing.expect(!std.mem.eql(u8, std.mem.sliceAsBytes(plain.embedding), std.mem.sliceAsBytes(sup.embedding)));
    // but a learned map gets meaningfully less of the effect than free coordinates do
    try testing.expect(par_gain < free_gain * 0.85);
}

test "when the labels AGREE with the geometry, supervision changes nothing at all" {
    const alloc = testing.allocator;
    const per = 15;
    const n = per * 3;
    const d = 4;
    const x = try blobs(alloc, per, d);
    defer alloc.free(x);
    const lab = try alloc.alloc(i32, n);
    defer alloc.free(lab);
    for (0..n) |i| lab[i] = @intCast(i / per);
    const hidden = [_]usize{ 24, 24 };

    var plain = try run(alloc, x, n, d, &hidden, null, .{ .n_neighbors = 5, .epochs = 400, .learning_rate = 0.01 });
    defer plain.deinit();
    var sup = try run(alloc, x, n, d, &hidden, lab, .{ .n_neighbors = 5, .epochs = 400, .learning_rate = 0.01, .target_weight = 0.5 });
    defer sup.deinit();

    // BIT-IDENTICAL, and the reason is worth having rather than being a surprise.
    // applyLabels only weakens edges that CROSS a class boundary, and in a graph of
    // five nearest neighbours drawn from well-separated blobs there are none to
    // weaken. Its other step renormalises each point's edges so its strongest is 1 --
    // and each point's strongest is ALREADY 1, because rho is the distance to the
    // nearest neighbour and that neighbour's weight is exp(0).
    //
    // So supervision is not a no-op here by luck. It has nothing to say, and says it.
    for (plain.embedding, sup.embedding) |a, b| try testing.expectEqual(a, b);
}

test "DENSITY PRESERVATION, and the input scaling that decides whether it works" {
    const alloc = testing.allocator;
    const per = 25;
    const n = per * 2;
    const d = 4;
    // two clusters differing TWENTYFOLD in spread, the diffuse one centred at 20
    const x = try alloc.alloc(f64, n * d);
    defer alloc.free(x);
    var st: u64 = 7;
    for (0..n) |i| {
        for (0..d) |t| {
            st = st *% 6364136223846793005 +% 1442695040888963407;
            const u = @as(f64, @floatFromInt(st >> 11)) / 9007199254740992.0;
            x[i * d + t] = if (i < per) (u - 0.5) * 0.15 else 20.0 + (u - 0.5) * 3.0;
        }
    }
    const hidden = [_]usize{ 24, 24 };

    // THE DEFECT THIS FOUND, which had nothing to do with density and everything to do
    // with the network's input:
    //
    //     raw input        density correlation -0.9934,  diffuse spread 0.0000
    //     standardised     density correlation +0.9967,  diffuse spread 1.0751
    //
    // The whole diffuse cluster collapsed to a POINT and the correlation came out
    // fully INVERTED -- from the input scale alone. An input of magnitude 20 over four
    // features drives the first tanh to |z| ~ 37, flat to about 1e-32, so every row of
    // that cluster is literally the same vector to the first layer and no gradient can
    // separate points the network cannot distinguish.
    //
    // A caller passing ordinary unscaled data would have got a confidently inverted
    // picture with nothing to warn them. So the scaling is done by the algorithm and
    // folded back into the first layer afterwards -- see run().
    var r = try run(alloc, x, n, d, &hidden, null, .{
        .n_neighbors = 8,
        .epochs = 400,
        .learning_rate = 0.01,
        .density_lambda = 0.1,
    });
    defer r.deinit();

    try testing.expectEqual(n, r.local_radii.len);
    try testing.expect(!std.math.isNan(r.density_correlation));
    // the sign is the whole result: this was -0.99 before the input was scaled
    try testing.expect(r.density_correlation > 0.8);

    // the diffuse cluster is drawn WIDER than the tight one, which is what density
    // preservation is for and what the collapse made impossible
    var w1: f64 = 0;
    var w2: f64 = 0;
    var c: f64 = 0;
    for (0..per) |i| {
        for (i + 1..per) |j| {
            w1 += @sqrt(umap.sqDist(r.embedding[i * 2 ..][0..2], r.embedding[j * 2 ..][0..2]));
            c += 1;
        }
    }
    for (per..n) |i| {
        for (i + 1..n) |j| w2 += @sqrt(umap.sqDist(r.embedding[i * 2 ..][0..2], r.embedding[j * 2 ..][0..2]));
    }
    try testing.expect(w2 / w1 > 2.0);

    var plain = try run(alloc, x, n, d, &hidden, null, .{
        .n_neighbors = 8,
        .epochs = 400,
        .learning_rate = 0.01,
    });
    defer plain.deinit();
    try testing.expectEqual(@as(usize, 0), plain.local_radii.len);
    try testing.expect(std.math.isNan(plain.density_correlation));
}

test "THE DENSITY CONTRACT EXTENDS TO UNSEEN ROWS WITH NO CALIBRATION" {
    const alloc = testing.allocator;
    const per = 25;
    const n = per * 2;
    const d = 4;
    const x = try alloc.alloc(f64, n * d);
    defer alloc.free(x);
    var st: u64 = 7;
    for (0..n) |i| {
        for (0..d) |t| {
            st = st *% 6364136223846793005 +% 1442695040888963407;
            const u = @as(f64, @floatFromInt(st >> 11)) / 9007199254740992.0;
            x[i * d + t] = if (i < per) (u - 0.5) * 0.15 else 20.0 + (u - 0.5) * 3.0;
        }
    }
    const hidden = [_]usize{ 24, 24 };

    var r = try run(alloc, x, n, d, &hidden, null, .{
        .n_neighbors = 8,
        .epochs = 400,
        .learning_rate = 0.01,
        .density_lambda = 0.1,
    });
    defer r.deinit();

    // HELD-OUT rows from the SAME two distributions -- unseen, but not outliers
    var st2: u64 = 4242;
    const m = 6;
    const nx = try alloc.alloc(f64, m * d);
    defer alloc.free(nx);
    for (0..m) |i| {
        for (0..d) |t| {
            st2 = st2 *% 6364136223846793005 +% 1442695040888963407;
            const u = @as(f64, @floatFromInt(st2 >> 11)) / 9007199254740992.0;
            nx[i * d + t] = if (i < m / 2) (u - 0.5) * 0.15 else 20.0 + (u - 0.5) * 3.0;
        }
    }
    const out = try alloc.alloc(f64, m * 2);
    defer alloc.free(out);
    try ptsne.transform(alloc, r.shape, r.weights, nx, m, out);

    // MEASURED. The training clusters occupy radii 0.0016 and 1.3997 in this map, and
    // the new rows land at 0.0014 and 1.4812 -- each at its own cluster's radius.
    //
    // THE FREE-FORM TRANSFORM NEEDED A WHOLE MECHANISM FOR THIS: a least-squares line
    // through the fit's (log R_original, log R_embedded) pairs, carried to the caller,
    // and a closed-form correction that sets a new point's distance from its
    // neighbourhood centroid. Here nothing is carried and nothing is corrected. The
    // network learned a density-preserving function and a new row simply evaluates it.
    //
    // AND THE CAVEAT SURVIVES THE TRANSFORM INTACT, which is the part worth saying.
    // This map exaggerates: the true spread ratio is about 22 and the drawn one about
    // 875. The new rows reproduce THE MAP's ratio faithfully, not the data's. An exact
    // transform buys fidelity to the picture, never accuracy in what the picture says.
    var tight: f64 = 0;
    var diffuse: f64 = 0;
    for (0..m / 2) |i| tight += reachOf(out[i * 2 ..][0..2], nx[i * d ..][0..d], x, r.embedding, n, d, 8);
    for (m / 2..m) |i| diffuse += reachOf(out[i * 2 ..][0..2], nx[i * d ..][0..d], x, r.embedding, n, d, 8);
    tight /= @floatFromInt(m / 2);
    diffuse /= @floatFromInt(m / 2);

    // a new row from the dense cluster lands tight; one from the sparse cluster spreads
    try testing.expect(diffuse > tight * 50);
    // and each sits at its own cluster's radius in the map, not somewhere between
    const train_tight = spreadOf3(r.embedding, 0, per);
    const train_diffuse = spreadOf3(r.embedding, per, n);
    try testing.expect(tight < train_tight * 5);
    try testing.expect(diffuse > train_diffuse * 0.5 and diffuse < train_diffuse * 2);
}

/// mean distance from a placed row to its k nearest TRAINING rows, in the embedding
fn reachOf(pos: []const f64, pt: []const f64, tx: []const f64, ty: []const f64, n: usize, d: usize, k: usize) f64 {
    var best: [16]usize = undefined;
    var bestv: [16]f64 = undefined;
    for (0..k) |q| bestv[q] = std.math.inf(f64);
    for (0..n) |j| {
        const dd = umap.sqDist(pt, tx[j * d ..][0..d]);
        var q: usize = 0;
        while (q < k) : (q += 1) {
            if (dd < bestv[q]) {
                var z = k - 1;
                while (z > q) : (z -= 1) {
                    bestv[z] = bestv[z - 1];
                    best[z] = best[z - 1];
                }
                bestv[q] = dd;
                best[q] = j;
                break;
            }
        }
    }
    var acc: f64 = 0;
    for (0..k) |q| acc += @sqrt(umap.sqDist(pos, ty[best[q] * 2 ..][0..2]));
    return acc / @as(f64, @floatFromInt(k));
}

fn spreadOf3(v: []const f64, lo: usize, hi: usize) f64 {
    var s: f64 = 0;
    var c: f64 = 0;
    for (lo..hi) |i| {
        for (i + 1..hi) |j| {
            s += @sqrt(umap.sqDist(v[i * 2 ..][0..2], v[j * 2 ..][0..2]));
            c += 1;
        }
    }
    return if (c > 0) s / c else 0;
}

test "SUPERVISION MUST NOT REDEFINE WHAT DENSITY MEANS" {
    const alloc = testing.allocator;
    const per = 25;
    const n = per * 2;
    const d = 4;
    const x = try alloc.alloc(f64, n * d);
    defer alloc.free(x);
    var st: u64 = 7;
    for (0..n) |i| {
        for (0..d) |t| {
            st = st *% 6364136223846793005 +% 1442695040888963407;
            const u = @as(f64, @floatFromInt(st >> 11)) / 9007199254740992.0;
            x[i * d + t] = if (i < per) (u - 0.5) * 0.15 else 20.0 + (u - 0.5) * 3.0;
        }
    }
    // labels that CUT ACROSS the two density clusters, so supervision has real work
    const lab = try alloc.alloc(i32, n);
    defer alloc.free(lab);
    for (0..n) |i| lab[i] = @intCast(i % 2);
    const hidden = [_]usize{ 24, 24 };

    // THE BUG THIS PINS. The local radius is a membership-weighted mean squared
    // distance, and supervision reweights exactly those memberships -- so once
    // applyLabels had crushed the cross-class edges, the same formula was answering a
    // different question: not "how far is this point from its neighbours" but "how far
    // from its neighbours OF THE SAME CLASS".
    //
    // MEASURED before the fix: a point's reported radius moved from 0.005061 to
    // 0.008793 when labels were supplied, and another's from 2.502802 to 3.071464.
    //
    // Two things made that indefensible rather than merely arguable. LocalRadii() is
    // documented as a property of the DATA. And the out-of-distribution check compares
    // a new row's radius -- necessarily computed label-free, since a new row HAS no
    // label -- against the training range, so supervision was quietly making those two
    // quantities incomparable. Same shape as the PCA space mismatch two steps earlier:
    // one seam, two computations, and a comparison that spans them.
    //
    // The graph snapshots its weights before supervision touches them, so the density
    // target is built label-free and the two features are independent again.
    var plain = try run(alloc, x, n, d, &hidden, null, .{
        .n_neighbors = 8,
        .epochs = 200,
        .learning_rate = 0.01,
        .density_lambda = 0.1,
    });
    defer plain.deinit();
    var sup = try run(alloc, x, n, d, &hidden, lab, .{
        .n_neighbors = 8,
        .epochs = 200,
        .learning_rate = 0.01,
        .target_weight = 0.5,
        .density_lambda = 0.1,
    });
    defer sup.deinit();

    // identical to the last bit, not merely close
    for (plain.local_radii, sup.local_radii) |a, b| try testing.expectEqual(a, b);

    // and the supervision DID happen -- this is not two identical runs
    try testing.expect(!std.mem.eql(u8, std.mem.sliceAsBytes(plain.embedding), std.mem.sliceAsBytes(sup.embedding)));
}

test "all four corners compose, and none degrades another" {
    const alloc = testing.allocator;
    const per = 25;
    const n = per * 2;
    const d = 4;
    const x = try alloc.alloc(f64, n * d);
    defer alloc.free(x);
    var st: u64 = 7;
    for (0..n) |i| {
        for (0..d) |t| {
            st = st *% 6364136223846793005 +% 1442695040888963407;
            const u = @as(f64, @floatFromInt(st >> 11)) / 9007199254740992.0;
            x[i * d + t] = if (i < per) (u - 0.5) * 0.15 else 20.0 + (u - 0.5) * 3.0;
        }
    }
    const lab = try alloc.alloc(i32, n);
    defer alloc.free(lab);
    for (0..n) |i| lab[i] = @intCast(i % 2);
    const hidden = [_]usize{ 24, 24 };

    // MEASURED, density correlation at each corner:
    //
    //                    no density   +density
    //     plain            0.9940       0.9940
    //     +supervision     0.9951       0.9951
    //
    // Density adds nothing on a learned map (established separately -- a smooth
    // function already preserves it), and supervision costs nothing either. What is
    // pinned here is the ORTHOGONALITY: after the target was made label-free, turning
    // one on does not move what the other reports.
    var both = try run(alloc, x, n, d, &hidden, lab, .{
        .n_neighbors = 8,
        .epochs = 200,
        .learning_rate = 0.01,
        .target_weight = 0.5,
        .density_lambda = 0.1,
    });
    defer both.deinit();
    try testing.expect(both.density_correlation > 0.9);
    try testing.expectEqual(n, both.local_radii.len);
    for (both.embedding) |v| try testing.expect(!std.math.isNan(v) and !std.math.isInf(v));
}

test "the folded first layer reproduces the standardised network exactly" {
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

    // The network trained on (x-m)/s and the weights returned take RAW x, because the
    // rescaling was folded into the first layer: w' = w/s, b' = b - sum(w*m/s). If
    // that algebra were wrong the reported embedding and a fresh forward pass would
    // disagree, since the embedding is computed FROM THE RAW INPUT after folding.
    //
    // Folding rather than returning m and s keeps the model stateless: no scaling
    // parameters travelling beside the weights, waiting for someone to lose one.
    const back = try alloc.alloc(f64, n * 2);
    defer alloc.free(back);
    try ptsne.transform(alloc, r.shape, r.weights, x, n, back);
    for (back, r.embedding) |a, b| try testing.expectEqual(b, a);
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

/// n points along one smooth curve through six dimensions, so that a midpoint between
/// two of them has a KNOWN true answer
fn curve(alloc: std.mem.Allocator, n: usize, d: usize) ![]f64 {
    const x = try alloc.alloc(f64, n * d);
    for (0..n) |i| {
        const t = @as(f64, @floatFromInt(i)) / @as(f64, @floatFromInt(n)) * 6.2831853;
        curveAt(t, x[i * d ..][0..d]);
    }
    return x;
}

fn curveAt(t: f64, out: []f64) void {
    out[0] = t;
    out[1] = @sin(t) * 5;
    out[2] = @cos(t) * 5;
    out[3] = @sin(2 * t) * 3;
    out[4] = t * t / 6.0;
    out[5] = @cos(3 * t);
}

/// mean error of inverting the MIDPOINTS between consecutive embedded rows, for a
/// trained decoder and for the nearest-stored-row lookup, against the true curve
fn midpointErrors(
    alloc: std.mem.Allocator,
    emb: []const f64,
    x: []const f64,
    n: usize,
    d: usize,
    dec: *Decoder,
) !struct { decoder: f64, lookup: f64 } {
    const m = n - 1;
    const mid = try alloc.alloc(f64, m * 2);
    defer alloc.free(mid);
    const truth = try alloc.alloc(f64, m * d);
    defer alloc.free(truth);
    for (0..m) |i| {
        mid[i * 2 + 0] = (emb[i * 2 + 0] + emb[(i + 1) * 2 + 0]) / 2;
        mid[i * 2 + 1] = (emb[i * 2 + 1] + emb[(i + 1) * 2 + 1]) / 2;
        const t = (@as(f64, @floatFromInt(i)) + 0.5) / @as(f64, @floatFromInt(n)) * 6.2831853;
        curveAt(t, truth[i * d ..][0..d]);
    }
    const inv = try alloc.alloc(f64, m * d);
    defer alloc.free(inv);
    try ptsne.transform(alloc, dec.shape, dec.weights, mid, m, inv);

    var de: f64 = 0;
    var le: f64 = 0;
    for (0..m) |i| {
        de += @sqrt(umap.sqDist(inv[i * d ..][0..d], truth[i * d ..][0..d]));
        var best: usize = 0;
        var bv = std.math.inf(f64);
        for (0..n) |q| {
            const dd = umap.sqDist(mid[i * 2 ..][0..2], emb[q * 2 ..][0..2]);
            if (dd < bv) {
                bv = dd;
                best = q;
            }
        }
        le += @sqrt(umap.sqDist(x[best * d ..][0..d], truth[i * d ..][0..d]));
    }
    return .{
        .decoder = de / @as(f64, @floatFromInt(m)),
        .lookup = le / @as(f64, @floatFromInt(m)),
    };
}

test "the inverse recovers a row far better than knowing nothing" {
    const alloc = testing.allocator;
    const n = 90;
    const d = 6;
    const x = try curve(alloc, n, d);
    defer alloc.free(x);
    const hidden = [_]usize{ 24, 24 };
    var r = try run(alloc, x, n, d, &hidden, null, .{ .n_neighbors = 8, .epochs = 400, .learning_rate = 0.01 });
    defer r.deinit();

    const dh = [_]usize{ 64, 64 };
    var dec = try trainDecoder(alloc, r.embedding, x, n, 2, d, &dh, 0.02, 15000, 11);
    defer dec.deinit();

    const back = try alloc.alloc(f64, n * d);
    defer alloc.free(back);
    try ptsne.transform(alloc, dec.shape, dec.weights, r.embedding, n, back);

    var err: f64 = 0;
    for (0..n) |i| err += @sqrt(umap.sqDist(back[i * d ..][0..d], x[i * d ..][0..d]));
    err /= @floatFromInt(n);

    // the "know nothing" answer: return the mean row every time
    const mean = try alloc.alloc(f64, d);
    defer alloc.free(mean);
    for (0..d) |t| {
        var mm: f64 = 0;
        for (0..n) |i| mm += x[i * d + t];
        mean[t] = mm / @as(f64, @floatFromInt(n));
    }
    var mean_err: f64 = 0;
    for (0..n) |i| mean_err += @sqrt(umap.sqDist(mean, x[i * d ..][0..d]));
    mean_err /= @floatFromInt(n);

    // MEASURED: 0.63 against 6.06 -- a tenfold improvement over knowing nothing, and
    // the loss falls monotonically while it happens
    try testing.expect(err < mean_err / 5);
    try testing.expect(dec.loss[14999] < dec.loss[0]);
}

test "CAPACITY DECIDED IT, and my first reading was of an undertrained net" {
    const alloc = testing.allocator;
    const n = 90;
    const d = 6;
    const x = try curve(alloc, n, d);
    defer alloc.free(x);
    const hidden = [_]usize{ 24, 24 };
    var r = try run(alloc, x, n, d, &hidden, null, .{ .n_neighbors = 8, .epochs = 400, .learning_rate = 0.01 });
    defer r.deinit();

    // MEASURED. Reconstruction error of the training rows, against a nearest-stored-row
    // lookup at 0.9155:
    //
    //     [32,32]   3000 epochs   2.4977     <- what I first measured, and nearly
    //                                           concluded a decoder was worthless from
    //     [64,64]   3000          0.8947
    //     [64,64]  15000          0.6314
    //     [64,64]  40000          0.5771
    //
    // Doubling the width and training longer moved it from three times WORSE than a
    // lookup to a third BETTER. The first reading was of an undertrained network, and
    // the conclusion drawn from it would have been wrong.
    const small = [_]usize{ 32, 32 };
    const big = [_]usize{ 64, 64 };
    var d_small = try trainDecoder(alloc, r.embedding, x, n, 2, d, &small, 0.02, 3000, 11);
    defer d_small.deinit();
    var d_big = try trainDecoder(alloc, r.embedding, x, n, 2, d, &big, 0.02, 15000, 11);
    defer d_big.deinit();

    const bs = try alloc.alloc(f64, n * d);
    defer alloc.free(bs);
    const bb = try alloc.alloc(f64, n * d);
    defer alloc.free(bb);
    try ptsne.transform(alloc, d_small.shape, d_small.weights, r.embedding, n, bs);
    try ptsne.transform(alloc, d_big.shape, d_big.weights, r.embedding, n, bb);

    var es: f64 = 0;
    var eb: f64 = 0;
    for (0..n) |i| {
        es += @sqrt(umap.sqDist(bs[i * d ..][0..d], x[i * d ..][0..d]));
        eb += @sqrt(umap.sqDist(bb[i * d ..][0..d], x[i * d ..][0..d]));
    }
    try testing.expect(eb < es / 2);
}

test "WHICH INVERSE WINS IS DECIDED BY THE SAMPLING GAP" {
    const alloc = testing.allocator;
    const d = 6;
    const dh = [_]usize{ 64, 64 };
    const hidden = [_]usize{ 24, 24 };

    // THE RULE, and it was predicted before it was measured rather than after.
    //
    // A lookup's error IS THE SAMPLING GAP -- it returns a stored row, so it can never
    // be closer to the truth than the nearest row happens to be. A decoder's error is
    // ITS OWN APPROXIMATION ERROR, which has nothing to do with how densely the data
    // was sampled. Whichever is smaller wins.
    //
    // MEASURED at midpoints between consecutive embedded rows, where the generating
    // curve gives a true answer:
    //
    //     fit           points     decoder    lookup
    //     free-form        24       0.5450    1.1516
    //     free-form        90       0.0858    0.2673
    //     parametric       24       0.2191    0.9886
    //     parametric       90       0.6529    0.4654    <- the only loss
    //
    // The lookup's error rises as the gaps widen, exactly as the rule says it must.
    //
    // BUT NOTE WHICH CELL THE DECODER LOSES IN. An earlier version of this comment said
    // "densely sampled data, use a lookup and skip the model", and that was measured on
    // the parametric fit ALONE. A free-form embedding answers to nothing, so the
    // optimiser can lay a curve out cleanly and y -> x comes out a well-behaved
    // function; a parametric encoder is CONSTRAINED to be smooth in x and can settle on
    // a more contorted layout, harder to invert rather than easier. At 90 points the
    // free-form decoder scores 0.0858 against the parametric one's 0.6529 -- sevenfold
    // better on identical data.
    //
    // The rule survived; the recommendation drawn from it did not. Train the decoder
    // unless the data is dense AND the fit is parametric.
    {
        const n = 90;
        const x = try curve(alloc, n, d);
        defer alloc.free(x);
        var r = try run(alloc, x, n, d, &hidden, null, .{ .n_neighbors = 8, .epochs = 400, .learning_rate = 0.01 });
        defer r.deinit();
        var dec = try trainDecoder(alloc, r.embedding, x, n, 2, d, &dh, 0.02, 40000, 11);
        defer dec.deinit();
        const e = try midpointErrors(alloc, r.embedding, x, n, d, dec);
        try testing.expect(e.lookup < e.decoder);
    }
    {
        const n = 24;
        const x = try curve(alloc, n, d);
        defer alloc.free(x);
        var r = try run(alloc, x, n, d, &hidden, null, .{ .n_neighbors = 6, .epochs = 400, .learning_rate = 0.01 });
        defer r.deinit();
        var dec = try trainDecoder(alloc, r.embedding, x, n, 2, d, &dh, 0.02, 40000, 11);
        defer dec.deinit();
        const e = try midpointErrors(alloc, r.embedding, x, n, d, dec);
        // and here it is not close: 0.081 against 0.902
        try testing.expect(e.decoder < e.lookup / 5);
    }
}

test "A FREE-FORM FIT INVERTS TOO, and rather better" {
    const alloc = testing.allocator;
    const d = 6;
    const dh = [_]usize{ 64, 64 };
    const hidden = [_]usize{ 24, 24 };
    const n = 90;
    const x = try curve(alloc, n, d);
    defer alloc.free(x);

    // THE DECODER NEVER INVERTS THE ENCODER. It is a separate model regressed on
    // (position, row) pairs, and a free-form fit has both halves exactly as a
    // parametric one does -- how the positions were arrived at is not its business.
    // A refusal stood in the Ring surface on the opposite reasoning and was wrong.
    var ff = try umap.run(alloc, x, n, d, .{ .n_neighbors = 8, .epochs = 400 });
    defer ff.deinit();
    var pa = try run(alloc, x, n, d, &hidden, null, .{
        .n_neighbors = 8,
        .epochs = 400,
        .learning_rate = 0.01,
    });
    defer pa.deinit();

    var d_ff = try trainDecoder(alloc, ff.embedding, x, n, 2, d, &dh, 0.02, 15000, 11);
    defer d_ff.deinit();
    var d_pa = try trainDecoder(alloc, pa.embedding, x, n, 2, d, &dh, 0.02, 15000, 11);
    defer d_pa.deinit();

    const e_ff = try midpointErrors(alloc, ff.embedding, x, n, d, d_ff);
    const e_pa = try midpointErrors(alloc, pa.embedding, x, n, d, d_pa);

    // MEASURED: 0.0858 for the free-form embedding against 0.6529 for the parametric
    // one -- SEVENFOLD BETTER on identical data.
    //
    // The reason is worth knowing rather than being a curiosity. A free-form layout
    // answers to nothing, so the optimiser can lay this curve out cleanly and y -> x
    // comes out a well-behaved function. A parametric encoder is CONSTRAINED to be
    // smooth in x, and the embedding it settles on can be more contorted -- harder to
    // invert, not easier. The property that makes the forward transform exact is not
    // the property that makes the inverse easy.
    try testing.expect(e_ff.decoder < e_pa.decoder / 2);
    // and here the decoder beats the lookup even at 90 points, where the parametric
    // one did not
    try testing.expect(e_ff.decoder < e_ff.lookup / 2);
}

test "the decoder maps RAW embedding coordinates to RAW data coordinates" {
    const alloc = testing.allocator;
    const n = 40;
    const d = 6;
    const x = try curve(alloc, n, d);
    defer alloc.free(x);
    const hidden = [_]usize{16};
    var r = try run(alloc, x, n, d, &hidden, null, .{ .n_neighbors = 5, .epochs = 200, .learning_rate = 0.01 });
    defer r.deinit();

    const dh = [_]usize{32};
    var dec = try trainDecoder(alloc, r.embedding, x, n, 2, d, &dh, 0.02, 3000, 11);
    defer dec.deinit();

    // Both ends were standardised for training and both were FOLDED BACK, so the
    // returned network takes raw embedding coordinates and returns raw data ones. If
    // either fold were wrong the reconstruction would be shifted or scaled wholesale,
    // and this comparison against the data's own range would catch it.
    const back = try alloc.alloc(f64, n * d);
    defer alloc.free(back);
    try ptsne.transform(alloc, dec.shape, dec.weights, r.embedding, n, back);
    for (0..d) |t| {
        var lo = std.math.inf(f64);
        var hi = -std.math.inf(f64);
        for (0..n) |i| {
            lo = @min(lo, x[i * d + t]);
            hi = @max(hi, x[i * d + t]);
        }
        const pad = (hi - lo) * 0.5 + 1;
        for (0..n) |i| {
            try testing.expect(back[i * d + t] > lo - pad);
            try testing.expect(back[i * d + t] < hi + pad);
        }
    }
}

test "a decoder with no hidden layer is refused" {
    const alloc = testing.allocator;
    const n = 20;
    const d = 6;
    const x = try curve(alloc, n, d);
    defer alloc.free(x);
    const emb = try alloc.alloc(f64, n * 2);
    defer alloc.free(emb);
    for (emb, 0..) |*v, i| v.* = @floatFromInt(i % 7);
    const none = [_]usize{};
    try testing.expectError(Error.BadShape, trainDecoder(alloc, emb, x, n, 2, d, &none, 0.02, 10, 1));
}
