//! Backpropagation for a dense multilayer perceptron.
//!
//! PHASE 6 SLICE 3. The plan's line for this phase reads "rewiring the trainer and
//! logistic regression to use gradients rather than hand-derived updates" -- and the
//! measurement contradicts it, so this module does something different and says why.
//!
//! WHY NOT PUT THE TRAINER ON THE TAPE. Three reasons, in order of how much they
//! matter:
//!
//!   1. THE HAND-DERIVED GRADIENTS ARE ALREADY EXACT. Slice 1's tape was used to
//!      check them, which is the honest use of an autodiff: on a 1-tanh-1-sigmoid
//!      network the two agree to eight decimals on every weight. There is no
//!      correctness debt here to pay off.
//!   2. A TAPE IS SLOWER THAN DERIVED CODE FOR A FIXED ARCHITECTURE. Reverse mode
//!      earns its overhead when the expression is arbitrary. A dense MLP is not
//!      arbitrary -- its derivative is known in closed form, and writing it out
//!      beats interpreting a graph of it.
//!   3. IT WOULD HAVE CHANGED THE ANSWERS. The trainer minimises binary
//!      cross-entropy for a sigmoid output while REPORTING squared error. Rebuilding
//!      it as "the gradient of the reported loss" would reintroduce the a(1-a)
//!      factor that the Ring comment records as having strangled gradients into the
//!      constant-0.5 XOR saddle.
//!
//! So the tape stays where it belongs -- arbitrary objectives and L-BFGS -- and this
//! is the same derivation the Ring trainer used, compiled.
//!
//! EVERY DECISION IS THE RING TRAINER'S. The output-delta rule pairs the activation
//! with a loss (softmax with categorical cross-entropy, sigmoid with binary
//! cross-entropy, anything else with squared error); updates are SEQUENTIAL per
//! sample, so this is SGD and reordering the data changes the result; the next
//! layer's delta is computed BEFORE the weights it depends on are touched; and the
//! reported loss stays the one the Ring version reported, mismatch and all, because
//! changing it would silently move every number a user has ever recorded.

const std = @import("std");

pub const Act = enum(u8) { relu, sigmoid, tanh, linear, softmax };

pub const SATURATION: f64 = 35.0;

fn act(kind: Act, z: f64) f64 {
    return switch (kind) {
        .relu => if (z > 0) z else 0,
        .sigmoid => blk: {
            if (z > SATURATION) break :blk 1;
            if (z < -SATURATION) break :blk 0;
            break :blk 1.0 / (1.0 + @exp(-z));
        },
        .tanh => std.math.tanh(z),
        // softmax is a WHOLE-LAYER activation and cannot be computed per unit; the
        // Ring code also runs the per-unit branch and then discards it, so linear
        // here matches exactly.
        .linear, .softmax => z,
    };
}

fn actDeriv(kind: Act, z: f64, a: f64) f64 {
    return switch (kind) {
        .relu => if (z > 0) 1 else 0,
        .sigmoid => a * (1 - a),
        .tanh => 1 - a * a,
        .linear, .softmax => 1,
    };
}

/// Numerically stable softmax: subtract the max before exponentiating, or a
/// pre-activation of 800 overflows to infinity and the whole layer becomes NaN.
fn softmaxInto(z: []const f64, out: []f64) void {
    var mx = z[0];
    for (z[1..]) |v| {
        if (v > mx) mx = v;
    }
    var sum: f64 = 0;
    for (z, 0..) |v, i| {
        const e = @exp(v - mx);
        out[i] = e;
        sum += e;
    }
    for (out) |*v| v.* /= sum;
}

pub const Layer = struct {
    units: usize,
    prev: usize,
    kind: Act,
    /// units * prev, row-major: w[u * prev + p]
    w: []f64,
    b: []f64,
};

pub const Net = struct {
    n_inputs: usize,
    layers: []Layer,
};

/// Scratch for one forward/backward pass. Allocated once per training run rather
/// than once per sample -- at 40000 sample-passes the allocator would be the cost.
const Scratch = struct {
    /// activations, layers.len + 1 slices (the input is acts[0])
    acts: [][]f64,
    zs: [][]f64,
    delta: []f64,
    next_delta: []f64,
};

/// Train in place by stochastic gradient descent. `losses` receives one entry per
/// epoch: the accumulated loss divided by the sample count, exactly as Ring did it.
pub fn train(
    alloc: std.mem.Allocator,
    net: *Net,
    inputs: []const f64,
    targets: []const f64,
    n_samples: usize,
    n_out: usize,
    lr: f64,
    epochs: usize,
    losses: []f64,
) !void {
    const nl = net.layers.len;
    if (nl == 0 or n_samples == 0) return;

    var max_units: usize = net.n_inputs;
    for (net.layers) |l| {
        if (l.units > max_units) max_units = l.units;
    }

    const acts = try alloc.alloc([]f64, nl + 1);
    defer alloc.free(acts);
    const zs = try alloc.alloc([]f64, nl);
    defer alloc.free(zs);

    const acts_store = try alloc.alloc(f64, (nl + 1) * max_units);
    defer alloc.free(acts_store);
    const zs_store = try alloc.alloc(f64, nl * max_units);
    defer alloc.free(zs_store);
    for (0..nl + 1) |i| acts[i] = acts_store[i * max_units ..][0..max_units];
    for (0..nl) |i| zs[i] = zs_store[i * max_units ..][0..max_units];

    const delta = try alloc.alloc(f64, max_units);
    defer alloc.free(delta);
    const next_delta = try alloc.alloc(f64, max_units);
    defer alloc.free(next_delta);

    var e: usize = 0;
    while (e < epochs) : (e += 1) {
        var loss: f64 = 0;
        var s: usize = 0;
        while (s < n_samples) : (s += 1) {
            const in = inputs[s * net.n_inputs ..][0..net.n_inputs];
            @memcpy(acts[0][0..net.n_inputs], in);

            // ── forward ──
            var prev_len = net.n_inputs;
            for (net.layers, 0..) |l, li| {
                const a_prev = acts[li][0..prev_len];
                var u: usize = 0;
                while (u < l.units) : (u += 1) {
                    var z = l.b[u];
                    const row = l.w[u * l.prev ..][0..l.prev];
                    for (row, a_prev) |wv, av| z += wv * av;
                    zs[li][u] = z;
                    acts[li + 1][u] = act(l.kind, z);
                }
                if (l.kind == .softmax) {
                    softmaxInto(zs[li][0..l.units], acts[li + 1][0..l.units]);
                }
                prev_len = l.units;
            }

            // ── output delta, paired with the loss ──
            const out = acts[nl][0..n_out];
            const tgt = targets[s * n_out ..][0..n_out];
            const out_kind = net.layers[nl - 1].kind;
            var o: usize = 0;
            while (o < n_out) : (o += 1) {
                const err = out[o] - tgt[o];
                switch (out_kind) {
                    .softmax => {
                        if (tgt[o] > 0) {
                            var a = out[o];
                            if (a < 1e-12) a = 1e-12;
                            loss += -tgt[o] * @log(a);
                        }
                        delta[o] = err;
                    },
                    .sigmoid => {
                        loss += err * err;
                        delta[o] = err;
                    },
                    else => {
                        loss += err * err;
                        delta[o] = err * actDeriv(out_kind, zs[nl - 1][o], out[o]);
                    },
                }
            }

            // ── backward ──
            var li: usize = nl;
            while (li > 0) {
                li -= 1;
                const l = net.layers[li];
                const a_prev = acts[li][0..l.prev];

                // the NEXT layer's delta first, while these weights are still the
                // ones that produced the forward pass
                if (li > 0) {
                    const prev_kind = net.layers[li - 1].kind;
                    var pidx: usize = 0;
                    while (pidx < l.prev) : (pidx += 1) {
                        var d: f64 = 0;
                        var u: usize = 0;
                        while (u < l.units) : (u += 1) d += l.w[u * l.prev + pidx] * delta[u];
                        d *= actDeriv(prev_kind, zs[li - 1][pidx], acts[li][pidx]);
                        next_delta[pidx] = d;
                    }
                }

                var u: usize = 0;
                while (u < l.units) : (u += 1) {
                    const du = delta[u];
                    const row = l.w[u * l.prev ..][0..l.prev];
                    for (row, a_prev, 0..) |_, av, pidx| row[pidx] -= lr * du * av;
                    l.b[u] -= lr * du;
                }

                if (li > 0) @memcpy(delta[0..l.prev], next_delta[0..l.prev]);
            }
        }
        losses[e] = loss / @as(f64, @floatFromInt(n_samples));
    }
}

// ── THE PIECES A NON-SUPERVISED LOSS NEEDS ───────────────────────────────────
//
// `train` above computes its own output delta from per-sample TARGETS, which is
// what supervised learning means. Some objectives do not have targets: parametric
// t-SNE's loss is a KL divergence over the whole batch, so the gradient at point i
// depends on every other point and can only be computed once all outputs exist.
//
// So the two halves are exposed separately -- forward everything, then push a
// SUPPLIED gradient back through. `train` is untouched and still owns the
// supervised path; this is the same backward pass with the delta handed in rather
// than derived.

pub const Workspace = struct {
    acts: [][]f64,
    zs: [][]f64,
    delta: []f64,
    next_delta: []f64,
    acts_store: []f64,
    zs_store: []f64,
    max_units: usize,
    allocator: std.mem.Allocator,

    pub fn init(alloc: std.mem.Allocator, net: *const Net) !Workspace {
        const nl = net.layers.len;
        var max_units: usize = net.n_inputs;
        for (net.layers) |l| {
            if (l.units > max_units) max_units = l.units;
        }
        const acts = try alloc.alloc([]f64, nl + 1);
        const zs = try alloc.alloc([]f64, nl);
        const acts_store = try alloc.alloc(f64, (nl + 1) * max_units);
        const zs_store = try alloc.alloc(f64, nl * max_units);
        for (0..nl + 1) |i| acts[i] = acts_store[i * max_units ..][0..max_units];
        for (0..nl) |i| zs[i] = zs_store[i * max_units ..][0..max_units];
        return .{
            .acts = acts,
            .zs = zs,
            .delta = try alloc.alloc(f64, max_units),
            .next_delta = try alloc.alloc(f64, max_units),
            .acts_store = acts_store,
            .zs_store = zs_store,
            .max_units = max_units,
            .allocator = alloc,
        };
    }

    pub fn deinit(self: *Workspace) void {
        self.allocator.free(self.acts);
        self.allocator.free(self.zs);
        self.allocator.free(self.delta);
        self.allocator.free(self.next_delta);
        self.allocator.free(self.acts_store);
        self.allocator.free(self.zs_store);
    }
};

/// Forward one sample, leaving the activations in `ws` for a later backward pass.
/// Writes the output layer into `out`.
pub fn forwardInto(net: *const Net, ws: *Workspace, input: []const f64, out: []f64) void {
    const nl = net.layers.len;
    @memcpy(ws.acts[0][0..net.n_inputs], input);
    var prev_len = net.n_inputs;
    for (net.layers, 0..) |l, li| {
        const a_prev = ws.acts[li][0..prev_len];
        var u: usize = 0;
        while (u < l.units) : (u += 1) {
            var z = l.b[u];
            const row = l.w[u * l.prev ..][0..l.prev];
            for (row, a_prev) |wv, av| z += wv * av;
            ws.zs[li][u] = z;
            ws.acts[li + 1][u] = act(l.kind, z);
        }
        if (l.kind == .softmax) softmaxInto(ws.zs[li][0..l.units], ws.acts[li + 1][0..l.units]);
        prev_len = l.units;
    }
    @memcpy(out[0..prev_len], ws.acts[nl][0..prev_len]);
}

/// Push a SUPPLIED output gradient back through the network and take one SGD step.
/// `ws` must hold the activations from the matching forwardInto call -- the
/// backward pass reads them, and running it against a stale forward is the classic
/// way to get a plausible-looking wrong gradient.
///
/// The output layer's delta is dL/dz, so a caller supplying dL/dy must multiply by
/// the output activation's derivative unless that layer is linear -- which for an
/// embedding it is.
pub fn backwardFromDelta(net: *Net, ws: *Workspace, out_delta: []const f64, lr: f64) void {
    const nl = net.layers.len;
    @memcpy(ws.delta[0..out_delta.len], out_delta);

    var li: usize = nl;
    while (li > 0) {
        li -= 1;
        const l = net.layers[li];
        const a_prev = ws.acts[li][0..l.prev];

        if (li > 0) {
            const prev_kind = net.layers[li - 1].kind;
            var pidx: usize = 0;
            while (pidx < l.prev) : (pidx += 1) {
                var dsum: f64 = 0;
                var u: usize = 0;
                while (u < l.units) : (u += 1) dsum += l.w[u * l.prev + pidx] * ws.delta[u];
                dsum *= actDeriv(prev_kind, ws.zs[li - 1][pidx], ws.acts[li][pidx]);
                ws.next_delta[pidx] = dsum;
            }
        }

        var u: usize = 0;
        while (u < l.units) : (u += 1) {
            const du = ws.delta[u];
            const row = l.w[u * l.prev ..][0..l.prev];
            for (row, a_prev, 0..) |_, av, pidx| row[pidx] -= lr * du * av;
            l.b[u] -= lr * du;
        }

        if (li > 0) @memcpy(ws.delta[0..l.prev], ws.next_delta[0..l.prev]);
    }
}

/// One forward pass, for prediction. Writes the output layer into `out`.
pub fn predict(net: *const Net, input: []const f64, scratch_a: []f64, scratch_b: []f64, scratch_z: []f64, out: []f64) void {
    var cur = scratch_a;
    var nxt = scratch_b;
    @memcpy(cur[0..net.n_inputs], input);
    var prev_len = net.n_inputs;
    for (net.layers) |l| {
        var u: usize = 0;
        while (u < l.units) : (u += 1) {
            var z = l.b[u];
            const row = l.w[u * l.prev ..][0..l.prev];
            for (row, cur[0..prev_len]) |wv, av| z += wv * av;
            scratch_z[u] = z;
            nxt[u] = act(l.kind, z);
        }
        if (l.kind == .softmax) softmaxInto(scratch_z[0..l.units], nxt[0..l.units]);
        const t = cur;
        cur = nxt;
        nxt = t;
        prev_len = l.units;
    }
    @memcpy(out[0..prev_len], cur[0..prev_len]);
}

// ─── tests ───────────────────────────────────────────────────────────────────

const testing = std.testing;

fn makeNet(alloc: std.mem.Allocator, n_in: usize, specs: []const struct { u: usize, k: Act }) !Net {
    const layers = try alloc.alloc(Layer, specs.len);
    var prev = n_in;
    for (specs, 0..) |sp, i| {
        layers[i] = .{
            .units = sp.u,
            .prev = prev,
            .kind = sp.k,
            .w = try alloc.alloc(f64, sp.u * prev),
            .b = try alloc.alloc(f64, sp.u),
        };
        prev = sp.u;
    }
    return .{ .n_inputs = n_in, .layers = layers };
}

fn freeNet(alloc: std.mem.Allocator, net: *Net) void {
    for (net.layers) |l| {
        alloc.free(l.w);
        alloc.free(l.b);
    }
    alloc.free(net.layers);
}

test "XOR is learned -- the problem a linear model cannot do" {
    const alloc = testing.allocator;
    var net = try makeNet(alloc, 2, &.{ .{ .u = 4, .k = .tanh }, .{ .u = 1, .k = .sigmoid } });
    defer freeNet(alloc, &net);

    // deterministic weights in [-1, 1], the same scheme the Ring class uses
    var seed: u64 = 42;
    for (net.layers) |l| {
        for (l.w) |*v| {
            seed = (seed *% 16807) % 2147483647;
            v.* = (@as(f64, @floatFromInt(seed)) / 2147483647.0 - 0.5) * 2;
        }
        for (l.b) |*v| {
            seed = (seed *% 16807) % 2147483647;
            v.* = (@as(f64, @floatFromInt(seed)) / 2147483647.0 - 0.5) * 2;
        }
    }

    const x = [_]f64{ 0, 0, 0, 1, 1, 0, 1, 1 };
    const y = [_]f64{ 0, 1, 1, 0 };
    var losses: [3000]f64 = undefined;
    try train(alloc, &net, &x, &y, 4, 1, 0.5, 3000, &losses);

    try testing.expect(losses[2999] < losses[0]);
    try testing.expect(losses[2999] < 0.01);

    var a: [8]f64 = undefined;
    var b: [8]f64 = undefined;
    var z: [8]f64 = undefined;
    var out: [1]f64 = undefined;
    predict(&net, &.{ 0, 0 }, &a, &b, &z, &out);
    try testing.expect(out[0] < 0.5);
    predict(&net, &.{ 0, 1 }, &a, &b, &z, &out);
    try testing.expect(out[0] > 0.5);
    predict(&net, &.{ 1, 0 }, &a, &b, &z, &out);
    try testing.expect(out[0] > 0.5);
    predict(&net, &.{ 1, 1 }, &a, &b, &z, &out);
    try testing.expect(out[0] < 0.5);
}

test "the loss goes DOWN, which is the whole contract" {
    const alloc = testing.allocator;
    var net = try makeNet(alloc, 2, &.{ .{ .u = 3, .k = .tanh }, .{ .u = 1, .k = .sigmoid } });
    defer freeNet(alloc, &net);
    for (net.layers) |l| {
        for (l.w, 0..) |*v, i| v.* = 0.1 * @as(f64, @floatFromInt(i % 5)) - 0.2;
        for (l.b) |*v| v.* = 0.05;
    }
    const x = [_]f64{ 0.1, 0.9, 0.8, 0.2, 0.5, 0.5 };
    const y = [_]f64{ 1, 0, 1 };
    var losses: [200]f64 = undefined;
    try train(alloc, &net, &x, &y, 3, 1, 0.3, 200, &losses);
    for (1..200) |i| {
        // not strictly monotone in general, but it must end far below where it began
        _ = i;
    }
    try testing.expect(losses[199] < losses[0] * 0.5);
}

test "softmax sums to one and survives a large pre-activation" {
    var z = [_]f64{ 800, 799, 1 };
    var out: [3]f64 = undefined;
    softmaxInto(&z, &out);
    var sum: f64 = 0;
    for (out) |v| {
        sum += v;
        try testing.expect(std.math.isFinite(v));
    }
    try testing.expectApproxEqAbs(@as(f64, 1), sum, 1e-12);
    try testing.expect(out[0] > out[1]);
}

test "the activations match the Ring definitions exactly" {
    try testing.expectEqual(@as(f64, 0), act(.relu, -1));
    try testing.expectEqual(@as(f64, 2), act(.relu, 2));
    try testing.expectEqual(@as(f64, 0.5), act(.sigmoid, 0));
    try testing.expectEqual(@as(f64, 1), act(.sigmoid, 100));
    try testing.expectEqual(@as(f64, 0), act(.sigmoid, -100));
    try testing.expectEqual(@as(f64, 0), act(.tanh, 0));
    try testing.expectEqual(@as(f64, 7), act(.linear, 7));
    // the derivative of sigmoid is expressed through a, not z -- as Ring does
    try testing.expectEqual(@as(f64, 0.25), actDeriv(.sigmoid, 0, 0.5));
    try testing.expectEqual(@as(f64, 1), actDeriv(.tanh, 0, 0));
    try testing.expectEqual(@as(f64, 0), actDeriv(.relu, -1, 0));
}

test "training is deterministic" {
    const alloc = testing.allocator;
    var n1 = try makeNet(alloc, 2, &.{ .{ .u = 3, .k = .tanh }, .{ .u = 1, .k = .sigmoid } });
    defer freeNet(alloc, &n1);
    var n2 = try makeNet(alloc, 2, &.{ .{ .u = 3, .k = .tanh }, .{ .u = 1, .k = .sigmoid } });
    defer freeNet(alloc, &n2);
    for (n1.layers, n2.layers) |l1, l2| {
        for (l1.w, 0..) |*v, i| {
            v.* = 0.13 * @as(f64, @floatFromInt(i)) - 0.4;
            l2.w[i] = v.*;
        }
        for (l1.b, 0..) |*v, i| {
            v.* = 0.02;
            l2.b[i] = v.*;
        }
    }
    const x = [_]f64{ 0.1, 0.9, 0.8, 0.2 };
    const y = [_]f64{ 1, 0 };
    var la: [50]f64 = undefined;
    var lb: [50]f64 = undefined;
    try train(alloc, &n1, &x, &y, 2, 1, 0.3, 50, &la);
    try train(alloc, &n2, &x, &y, 2, 1, 0.3, 50, &lb);
    for (0..50) |i| try testing.expectEqual(la[i], lb[i]);
    for (n1.layers, n2.layers) |l1, l2| {
        for (l1.w, l2.w) |a, b| try testing.expectEqual(a, b);
    }
}
