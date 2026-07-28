//! THE INVERSE TRANSFORM -- from the picture back to the data.
//!
//! Lifted out of pumap.zig once t-SNE needed it too, because it never belonged to
//! either algorithm: this regresses (position, row) PAIRS and has no idea what produced
//! the positions. A module named for one caller would have misled the next.
//!
//! Everything else in this family runs one way -- data to embedding. This runs the
//! other, and it is the only direction that needs a second model, because the forward
//! map threw information away and no amount of cleverness gets it back.
//!
//! ── WHAT IT CAN AND CANNOT BE ──
//!
//! Two dimensions cannot hold thirty. The inverse therefore recovers what the embedding
//! KEPT and invents the rest, and the honest way to say that is with a number: compare
//! its reconstruction against what you would get by simply returning the nearest
//! training row. If a trained decoder cannot beat that lookup it has added nothing but
//! a model to maintain.
//!
//! ── WHY A SEPARATE MODEL RATHER THAN A JOINT ONE ──
//!
//! The paper's parametric UMAP can be trained as an autoencoder, with a reconstruction
//! loss added to the UMAP objective. That makes the embedding MORE invertible and less
//! faithful to the neighbourhood structure -- a real trade, and one that changes the
//! picture the caller already looked at. Training the decoder afterwards, against the
//! frozen embedding, leaves the map exactly as it was. The map is the deliverable; the
//! inverse is a convenience on top of it.

const std = @import("std");
const nn = @import("nn.zig");


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


pub const Error = error{ TooFewPoints, BadShape, OutOfMemory };
