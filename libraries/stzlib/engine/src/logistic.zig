//! Binary logistic regression by sequential stochastic gradient descent.
//!
//! PHASE 5. The training loop came down from Ring because, unlike the simplex, the
//! loop really was the cost. Measured on 5000 examples x 16 features x 100 epochs:
//! hoisting the Ring version by hand (label comparison done once instead of once per
//! epoch, the feature vector never passed as an argument) gave exactly 2x with
//! bit-identical weights -- so half the time was interpreter overhead and half was
//! genuine arithmetic. The remaining half is what this module is for.
//!
//! THE ARITHMETIC IS DELIBERATELY UNCHANGED, NOT MERELY EQUIVALENT. Gradient descent
//! is a feedback loop: each step's weights determine the next step's gradient, so a
//! last-bit difference does not stay a last-bit difference. It compounds. The Ring
//! class promises "deterministic: zero weight init, fixed order -- reproducible runs",
//! and that promise is only worth something if moving the loop keeps it. So:
//!
//!   * updates stay SEQUENTIAL per example (this is SGD, not batch -- the weights move
//!     before the next example is scored, and reordering examples changes the answer);
//!   * the dot product accumulates SEQUENTIALLY, in index order, even though a
//!     lane-parallel reduction would be faster. Reassociating a floating-point sum
//!     changes its last bits, and here those bits feed back;
//!   * the saturation cutoff stays at |z| > 35, matching the Ring `_Sigmoid` exactly.
//!
//! The weight update, by contrast, vectorises for free: `w[i] += c * x[i]` is
//! elementwise, so lane width cannot change any individual result. THAT ASYMMETRY IS
//! THE WHOLE STORY OF THIS MODULE -- half the inner work vectorises at no cost to
//! reproducibility, and half must not, and knowing which is which is the engineering.
//!
//! What is NOT bit-identical, and cannot be, is `exp`. Ring calls the C library's;
//! this calls Zig's. They agree to within an ulp, but an ulp inside a feedback loop
//! does not stay an ulp -- the guard measures the drift rather than assuming it away.

const std = @import("std");

/// Where the sigmoid is treated as saturated. Matches the Ring class exactly.
///
/// AN EARLIER VERSION OF THIS COMMENT CLAIMED THE CUTOFF IS FREE -- that beyond
/// |z| = 35 the f64 sigmoid is already exactly 1.0. It is not, and a test caught
/// it: sigmoid(35) is 0.9999999999999993, about three ulps short, because
/// exp(-35) = 6.3e-16 does not vanish against 1.0. So clamping introduces a
/// discontinuity of ~6.7e-16 at the boundary. That is negligible against anything
/// a probability is used for, and the clamp earns its place by keeping exp away
/// from arguments that overflow it -- but "negligible" and "free" are different
/// claims, and only one of them is true.
pub const SATURATION: f64 = 35.0;

pub inline fn sigmoid(z: f64) f64 {
    if (z > SATURATION) return 1.0;
    if (z < -SATURATION) return 0.0;
    return 1.0 / (1.0 + @exp(-z));
}

/// THE ONE DEFINITION OF THE LINEAR SCORE. Both training and prediction go through
/// here, so a model can never be scored by a different rule than it was fitted by.
///
/// Sequential on purpose: see the module note. A `@reduce(.Add, ...)` here would be
/// measurably faster and would silently change every trained model.
pub inline fn score(w: []const f64, x: []const f64, b: f64) f64 {
    var z = b;
    for (w, 0..) |wi, i| z += wi * x[i];
    return z;
}

/// w += c * x, elementwise. Vectorised, and bit-identical to the scalar loop
/// BECAUSE it is elementwise -- no accumulation crosses lanes, so no reassociation
/// can occur. Zig does not contract multiply-add into FMA without an explicit
/// request, so the vector and scalar forms compute the same expression.
inline fn axpy(w: []f64, x: []const f64, c: f64) void {
    const L = 4;
    const V = @Vector(L, f64);
    const cv: V = @splat(c);
    var i: usize = 0;
    while (i + L <= w.len) : (i += L) {
        const wv: V = w[i..][0..L].*;
        const xv: V = x[i..][0..L].*;
        w[i..][0..L].* = wv + cv * xv;
    }
    while (i < w.len) : (i += 1) w[i] += c * x[i];
}

/// Fit weights and bias. `x` is n*d row-major, `y` is n entries each 0 or 1,
/// `w` is the d-element output. Returns the bias.
///
/// Weights start at zero, which for logistic regression is a real choice and not a
/// placeholder: the loss is convex, so there is one optimum and no symmetry to break
/// -- zero init is both reproducible and harmless here, unlike in a neural network.
pub fn train(
    x: []const f64,
    y: []const f64,
    n: usize,
    d: usize,
    lr: f64,
    epochs: usize,
    w: []f64,
) f64 {
    @memset(w, 0);
    var b: f64 = 0;
    var e: usize = 0;
    while (e < epochs) : (e += 1) {
        var i: usize = 0;
        while (i < n) : (i += 1) {
            const row = x[i * d ..][0..d];
            const p = sigmoid(score(w, row, b));
            // (lr * err) first, then * x[f] -- the same grouping Ring's
            // left-to-right `@nLr * _nErr_ * x` produces.
            const c = lr * (y[i] - p);
            axpy(w, row, c);
            b += c;
        }
    }
    return b;
}

/// Probabilities for m rows at once, through the SAME score and sigmoid the fit used.
pub fn predict(
    x: []const f64,
    m: usize,
    d: usize,
    w: []const f64,
    b: f64,
    out: []f64,
) void {
    var i: usize = 0;
    while (i < m) : (i += 1) out[i] = sigmoid(score(w, x[i * d ..][0..d], b));
}

// ─── tests ───

test "sigmoid is a half at zero and saturates symmetrically" {
    try std.testing.expectEqual(@as(f64, 0.5), sigmoid(0));
    try std.testing.expectEqual(@as(f64, 1.0), sigmoid(100));
    try std.testing.expectEqual(@as(f64, 0.0), sigmoid(-100));
    // just inside the cutoff the REAL function is used, and it is NOT 1.0 --
    // it is three ulps short, which is why the clamp is a (tiny) discontinuity
    try std.testing.expect(sigmoid(34.9) < 1.0);
    try std.testing.expect(1.0 - sigmoid(34.9) < 1e-15);
    // and immediately past it, the clamp gives exactly 1.0
    try std.testing.expectEqual(@as(f64, 1.0), sigmoid(35.1));
}

test "axpy vectorised equals axpy scalar, bit for bit" {
    // the claim the module note makes -- checked at a length that exercises both
    // the 4-wide body and the scalar tail
    var a: [11]f64 = undefined;
    var b: [11]f64 = undefined;
    var x: [11]f64 = undefined;
    for (0..11) |i| {
        const v = 0.1 * @as(f64, @floatFromInt(i + 1)) + 1e-17;
        a[i] = v;
        b[i] = v;
        x[i] = 1.0 / @as(f64, @floatFromInt(i + 3));
    }
    const c: f64 = 0.7;
    axpy(&a, &x, c);
    for (0..11) |i| b[i] += c * x[i];
    for (0..11) |i| try std.testing.expectEqual(b[i], a[i]);
}

test "a separable problem is learned" {
    // one feature, threshold at 0.5: below is class 0, above is class 1
    const x = [_]f64{ 0.0, 0.1, 0.2, 0.8, 0.9, 1.0 };
    const y = [_]f64{ 0, 0, 0, 1, 1, 1 };
    var w: [1]f64 = undefined;
    const b = train(&x, &y, 6, 1, 0.5, 500, &w);
    try std.testing.expect(w[0] > 0);
    var p: [2]f64 = undefined;
    const q = [_]f64{ 0.05, 0.95 };
    predict(&q, 2, 1, &w, b, &p);
    try std.testing.expect(p[0] < 0.5);
    try std.testing.expect(p[1] > 0.5);
}

test "zero epochs leaves an uninformed model" {
    const x = [_]f64{ 1, 2, 3, 4 };
    const y = [_]f64{ 0, 1 };
    var w: [2]f64 = undefined;
    const b = train(&x, &y, 2, 2, 0.5, 0, &w);
    try std.testing.expectEqual(@as(f64, 0), w[0]);
    try std.testing.expectEqual(@as(f64, 0), w[1]);
    try std.testing.expectEqual(@as(f64, 0), b);
    var p: [1]f64 = undefined;
    predict(&x, 1, 2, &w, b, &p);
    try std.testing.expectEqual(@as(f64, 0.5), p[0]);
}

test "training is reproducible: the same input twice gives the same bits" {
    const x = [_]f64{ 0.1, 0.9, 0.4, 0.2, 0.7, 0.3, 0.8, 0.6 };
    const y = [_]f64{ 0, 0, 1, 1 };
    var w1: [2]f64 = undefined;
    var w2: [2]f64 = undefined;
    const b1 = train(&x, &y, 4, 2, 0.3, 200, &w1);
    const b2 = train(&x, &y, 4, 2, 0.3, 200, &w2);
    try std.testing.expectEqual(b1, b2);
    try std.testing.expectEqual(w1[0], w2[0]);
    try std.testing.expectEqual(w1[1], w2[1]);
}

test "example order matters -- this is SGD, not batch" {
    // Not a defect, and worth pinning so nobody 'optimises' the loop by reordering:
    // the weights move before the next example is scored.
    const xa = [_]f64{ 0.1, 0.9, 0.8, 0.2 };
    const ya = [_]f64{ 0, 1 };
    const xb = [_]f64{ 0.8, 0.2, 0.1, 0.9 };
    const yb = [_]f64{ 1, 0 };
    var wa: [2]f64 = undefined;
    var wb: [2]f64 = undefined;
    _ = train(&xa, &ya, 2, 2, 0.5, 10, &wa);
    _ = train(&xb, &yb, 2, 2, 0.5, 10, &wb);
    try std.testing.expect(wa[0] != wb[0]);
}
