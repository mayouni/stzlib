//! L-BFGS: limited-memory quasi-Newton minimisation of a smooth function.
//!
//! PHASE 6 SLICE 2. Slice 1 built the tape; this is what the plan said it unlocks.
//! Newton's method needs the Hessian -- n² storage and a solve per step. BFGS
//! approximates the inverse Hessian from successive gradients, which is n² storage.
//! L-BFGS never forms it at all: it keeps the last m pairs (s, y) = (step, gradient
//! change) and reconstructs the action of the inverse Hessian on a vector by a
//! two-loop recursion. Storage is O(m·n) with m about 7, so a thousand-variable
//! problem costs kilobytes instead of megabytes.
//!
//! IT TAKES A FUNCTION POINTER, NOT A TAPE. The obvious thing was to hand it an
//! autodiff Program, since that is the only consumer today. But an optimiser that
//! can only minimise parsed expressions cannot minimise a logistic loss over a
//! resident dataset, or anything else this library already computes gradients for --
//! and the whole argument for building autodiff was that gradients unlock
//! optimisation generally. The objective is `fn(ctx, x, grad) -> f64`; the tape is
//! one implementation of it.
//!
//! THE LINE SEARCH IS THE PART THAT IS EASY TO GET WRONG, so it is the standard
//! bracket-and-zoom search for the STRONG WOLFE conditions (Nocedal & Wright
//! Algorithms 3.5 and 3.6), not a plain backtracking Armijo. The difference matters
//! specifically for L-BFGS: the curvature condition |g(α)ᵀd| ≤ c₂|g(0)ᵀd| is what
//! guarantees sᵀy > 0, and sᵀy > 0 is what keeps the implicit inverse-Hessian
//! positive definite. Armijo alone does not give it, so the update has to be skipped
//! often, and the method degrades toward gradient descent without saying so.
//!
//! A CURVATURE SAFEGUARD REMAINS ANYWAY: if sᵀy is not comfortably positive the pair
//! is discarded rather than stored. Floating point can produce a non-positive sᵀy
//! even when the line search reports success, and one bad pair poisons every
//! subsequent direction.

const std = @import("std");

/// An accepted line-search step. A NAMED type: two functions returning the same
/// anonymous struct give two DIFFERENT types in Zig, and zoom() returning into
/// lineSearch() is exactly that case.
pub const Step = struct { alpha: f64, value: f64 };

pub const ObjectiveFn = *const fn (ctx: ?*anyopaque, x: []const f64, grad: []f64) f64;

pub const Status = enum(u8) {
    converged_gradient,
    converged_step,
    max_iterations,
    line_search_failed,
    not_finite,
};

pub const Options = struct {
    max_iterations: usize = 500,
    /// stop when the infinity norm of the gradient falls below this
    gradient_tolerance: f64 = 1e-8,
    /// stop when a step moves the value by less than this, relatively
    value_tolerance: f64 = 1e-12,
    /// how many (s, y) pairs to remember
    history: usize = 7,
    /// Armijo (sufficient decrease) and Wolfe (curvature) constants. The classic
    /// values; c1 must be well below c2 or the conditions are unsatisfiable.
    c1: f64 = 1e-4,
    c2: f64 = 0.9,
    max_line_search: usize = 40,
};

pub const Result = struct {
    status: Status,
    value: f64,
    iterations: usize,
    /// evaluations of the objective, which is the honest cost measure -- an
    /// iteration that line-searched twelve times is not one unit of work
    evaluations: usize,
    gradient_norm: f64,
};

const Ctx = struct {
    f: ObjectiveFn,
    user: ?*anyopaque,
    evals: usize = 0,

    fn call(self: *Ctx, x: []const f64, g: []f64) f64 {
        self.evals += 1;
        return self.f(self.user, x, g);
    }
};

fn dot(a: []const f64, b: []const f64) f64 {
    var s: f64 = 0;
    for (a, b) |x, y| s += x * y;
    return s;
}

fn infNorm(a: []const f64) f64 {
    var m: f64 = 0;
    for (a) |v| {
        const t = @abs(v);
        if (t > m) m = t;
    }
    return m;
}

/// Interpolate a trial point inside [lo, hi]. Bisection is used rather than cubic
/// interpolation: it cannot fail, and the zoom loop is not where L-BFGS spends its
/// time. A cubic would shave a couple of evaluations per iteration at the cost of
/// several edge cases involving non-finite derivatives.
fn zoom(
    c: *Ctx,
    x0: []const f64,
    d: []const f64,
    x: []f64,
    g: []f64,
    f0: f64,
    dg0: f64,
    opts: Options,
    lo_in: f64,
    hi_in: f64,
    f_lo_in: f64,
) ?Step {
    var lo = lo_in;
    var hi = hi_in;
    var f_lo = f_lo_in;
    var i: usize = 0;
    while (i < opts.max_line_search) : (i += 1) {
        const a = 0.5 * (lo + hi);
        if (@abs(hi - lo) < 1e-16) return null;
        for (x0, d, 0..) |x0i, di, k| x[k] = x0i + a * di;
        const fa = c.call(x, g);
        if (!std.math.isFinite(fa)) {
            hi = a;
            continue;
        }
        if (fa > f0 + opts.c1 * a * dg0 or fa >= f_lo) {
            hi = a;
        } else {
            const dga = dot(g, d);
            if (@abs(dga) <= -opts.c2 * dg0) return Step{ .alpha = a, .value = fa };
            if (dga * (hi - lo) >= 0) hi = lo;
            lo = a;
            f_lo = fa;
        }
    }
    return null;
}

/// Strong Wolfe line search along `d` from `x0`. On success `x` and `g` hold the
/// accepted point and its gradient.
fn lineSearch(
    c: *Ctx,
    x0: []const f64,
    d: []const f64,
    x: []f64,
    g: []f64,
    f0: f64,
    dg0: f64,
    opts: Options,
) ?Step {
    var a_prev: f64 = 0;
    var f_prev: f64 = f0;
    var a: f64 = 1;
    var i: usize = 0;
    while (i < opts.max_line_search) : (i += 1) {
        for (x0, d, 0..) |x0i, di, k| x[k] = x0i + a * di;
        const fa = c.call(x, g);

        if (!std.math.isFinite(fa)) {
            // stepped somewhere the objective is not defined -- pull back rather
            // than declaring failure, which is common with log and sqrt objectives
            a = 0.5 * (a_prev + a);
            if (a <= 1e-30) return null;
            continue;
        }

        if (fa > f0 + opts.c1 * a * dg0 or (i > 0 and fa >= f_prev)) {
            return zoom(c, x0, d, x, g, f0, dg0, opts, a_prev, a, f_prev);
        }
        const dga = dot(g, d);
        if (@abs(dga) <= -opts.c2 * dg0) return Step{ .alpha = a, .value = fa };
        if (dga >= 0) {
            return zoom(c, x0, d, x, g, f0, dg0, opts, a, a_prev, fa);
        }
        a_prev = a;
        f_prev = fa;
        a *= 2;
    }
    return null;
}

/// Minimise `f` from `x` in place. Returns how it finished.
pub fn minimize(
    alloc: std.mem.Allocator,
    f: ObjectiveFn,
    user: ?*anyopaque,
    x: []f64,
    opts: Options,
) !Result {
    const n = x.len;
    const m = @max(opts.history, 1);

    var c = Ctx{ .f = f, .user = user };

    const g = try alloc.alloc(f64, n);
    defer alloc.free(g);
    const g_new = try alloc.alloc(f64, n);
    defer alloc.free(g_new);
    const x_new = try alloc.alloc(f64, n);
    defer alloc.free(x_new);
    const d = try alloc.alloc(f64, n);
    defer alloc.free(d);
    const q = try alloc.alloc(f64, n);
    defer alloc.free(q);

    const s_hist = try alloc.alloc(f64, m * n);
    defer alloc.free(s_hist);
    const y_hist = try alloc.alloc(f64, m * n);
    defer alloc.free(y_hist);
    const rho = try alloc.alloc(f64, m);
    defer alloc.free(rho);
    const alpha_i = try alloc.alloc(f64, m);
    defer alloc.free(alpha_i);

    var stored: usize = 0;
    var head: usize = 0; // where the NEXT pair goes

    var fx = c.call(x, g);
    if (!std.math.isFinite(fx)) {
        return .{ .status = .not_finite, .value = fx, .iterations = 0, .evaluations = c.evals, .gradient_norm = 0 };
    }

    var it: usize = 0;
    while (it < opts.max_iterations) : (it += 1) {
        const gnorm = infNorm(g);
        if (gnorm <= opts.gradient_tolerance) {
            return .{ .status = .converged_gradient, .value = fx, .iterations = it, .evaluations = c.evals, .gradient_norm = gnorm };
        }

        // two-loop recursion: d = -H*g without ever forming H
        @memcpy(q, g);
        var k: usize = 0;
        while (k < stored) : (k += 1) {
            // walk the history newest first
            const idx = (head + m - 1 - k) % m;
            const s_i = s_hist[idx * n ..][0..n];
            const y_i = y_hist[idx * n ..][0..n];
            alpha_i[idx] = rho[idx] * dot(s_i, q);
            for (y_i, 0..) |yv, j| q[j] -= alpha_i[idx] * yv;
        }

        // initial inverse-Hessian scaling. gamma = sᵀy / yᵀy from the newest pair is
        // what makes L-BFGS take a well-scaled first step; without it the method
        // wastes its early iterations discovering the scale of the problem.
        var gamma: f64 = 1;
        if (stored > 0) {
            const idx = (head + m - 1) % m;
            const s_i = s_hist[idx * n ..][0..n];
            const y_i = y_hist[idx * n ..][0..n];
            const yy = dot(y_i, y_i);
            if (yy > 0) gamma = dot(s_i, y_i) / yy;
        }
        for (q) |*v| v.* *= gamma;

        k = 0;
        while (k < stored) : (k += 1) {
            const idx = (head + m - stored + k) % m; // oldest first
            const s_i = s_hist[idx * n ..][0..n];
            const y_i = y_hist[idx * n ..][0..n];
            const beta = rho[idx] * dot(y_i, q);
            for (s_i, 0..) |sv, j| q[j] += sv * (alpha_i[idx] - beta);
        }

        for (q, 0..) |v, j| d[j] = -v;

        var dg0 = dot(g, d);
        if (dg0 >= 0) {
            // NOT A DESCENT DIRECTION. Rounding, or a history that no longer
            // describes the local curvature, can produce this. Steepest descent is
            // always a descent direction, so restart from it and drop the history
            // rather than stepping uphill.
            for (g, 0..) |gv, j| d[j] = -gv;
            dg0 = dot(g, d);
            stored = 0;
            head = 0;
            if (dg0 >= 0) {
                return .{ .status = .converged_gradient, .value = fx, .iterations = it, .evaluations = c.evals, .gradient_norm = gnorm };
            }
        }

        const ls = lineSearch(&c, x, d, x_new, g_new, fx, dg0, opts) orelse {
            return .{ .status = .line_search_failed, .value = fx, .iterations = it, .evaluations = c.evals, .gradient_norm = gnorm };
        };

        const f_new = ls.value;
        const denom = @max(@abs(fx), 1.0);
        const rel = @abs(fx - f_new) / denom;

        // store the pair, unless the curvature condition says it would poison the
        // approximation
        const idx = head % m;
        var sy: f64 = 0;
        var yy: f64 = 0;
        for (0..n) |j| {
            const sv = x_new[j] - x[j];
            const yv = g_new[j] - g[j];
            s_hist[idx * n + j] = sv;
            y_hist[idx * n + j] = yv;
            sy += sv * yv;
            yy += yv * yv;
        }
        if (sy > 1e-16 * @sqrt(yy) * @sqrt(dot(s_hist[idx * n ..][0..n], s_hist[idx * n ..][0..n]))) {
            rho[idx] = 1.0 / sy;
            head = (head + 1) % m;
            if (stored < m) stored += 1;
        }

        @memcpy(x, x_new);
        @memcpy(g, g_new);
        fx = f_new;

        if (rel <= opts.value_tolerance) {
            return .{ .status = .converged_step, .value = fx, .iterations = it + 1, .evaluations = c.evals, .gradient_norm = infNorm(g) };
        }
    }

    return .{ .status = .max_iterations, .value = fx, .iterations = it, .evaluations = c.evals, .gradient_norm = infNorm(g) };
}

// ─── tests ───────────────────────────────────────────────────────────────────

const testing = std.testing;

fn quadratic(_: ?*anyopaque, x: []const f64, g: []f64) f64 {
    // (x-1)^2 + (y-2)^2, minimum 0 at (1, 2)
    g[0] = 2 * (x[0] - 1);
    g[1] = 2 * (x[1] - 2);
    return (x[0] - 1) * (x[0] - 1) + (x[1] - 2) * (x[1] - 2);
}

fn rosenbrock(_: ?*anyopaque, x: []const f64, g: []f64) f64 {
    // (1-x)^2 + 100(y - x^2)^2, minimum 0 at (1, 1) -- the classic curved valley
    const a = 1 - x[0];
    const b = x[1] - x[0] * x[0];
    g[0] = -2 * a - 400 * x[0] * b;
    g[1] = 200 * b;
    return a * a + 100 * b * b;
}

fn illConditioned(_: ?*anyopaque, x: []const f64, g: []f64) f64 {
    // condition number 1e6 -- steepest descent would crawl
    g[0] = 2 * x[0];
    g[1] = 2e6 * x[1];
    return x[0] * x[0] + 1e6 * x[1] * x[1];
}

test "a quadratic in two steps or so" {
    var x = [_]f64{ -5, 8 };
    const r = try minimize(testing.allocator, quadratic, null, &x, .{});
    try testing.expectEqual(Status.converged_gradient, r.status);
    try testing.expectApproxEqAbs(@as(f64, 1), x[0], 1e-7);
    try testing.expectApproxEqAbs(@as(f64, 2), x[1], 1e-7);
    try testing.expect(r.iterations <= 5);
}

test "Rosenbrock, which a bad line search cannot solve" {
    var x = [_]f64{ -1.2, 1.0 };
    const r = try minimize(testing.allocator, rosenbrock, null, &x, .{ .max_iterations = 500 });
    try testing.expectApproxEqAbs(@as(f64, 1), x[0], 1e-4);
    try testing.expectApproxEqAbs(@as(f64, 1), x[1], 1e-4);
    try testing.expect(r.value < 1e-8);
}

test "ill conditioning is what quasi-Newton is FOR" {
    var x = [_]f64{ 1, 1 };
    const r = try minimize(testing.allocator, illConditioned, null, &x, .{});
    try testing.expect(r.value < 1e-10);
    // steepest descent on a 1e6 condition number needs thousands of iterations
    try testing.expect(r.iterations < 50);
}

test "starting AT the minimum is recognised, not stepped away from" {
    var x = [_]f64{ 1, 2 };
    const r = try minimize(testing.allocator, quadratic, null, &x, .{});
    try testing.expectEqual(Status.converged_gradient, r.status);
    try testing.expectEqual(@as(usize, 0), r.iterations);
    try testing.expectEqual(@as(f64, 1), x[0]);
}

test "it is deterministic -- two runs agree exactly" {
    var a = [_]f64{ -1.2, 1.0 };
    var b = [_]f64{ -1.2, 1.0 };
    const ra = try minimize(testing.allocator, rosenbrock, null, &a, .{});
    const rb = try minimize(testing.allocator, rosenbrock, null, &b, .{});
    try testing.expectEqual(ra.iterations, rb.iterations);
    try testing.expectEqual(ra.evaluations, rb.evaluations);
    try testing.expectEqual(a[0], b[0]);
    try testing.expectEqual(a[1], b[1]);
}

test "a high-dimensional quadratic, where the point of limited memory is the memory" {
    const n = 200;
    const alloc = testing.allocator;
    const x = try alloc.alloc(f64, n);
    defer alloc.free(x);
    for (0..n) |i| x[i] = @floatFromInt(i % 7);

    const S = struct {
        fn f(_: ?*anyopaque, xx: []const f64, gg: []f64) f64 {
            var s: f64 = 0;
            for (xx, 0..) |v, i| {
                const w = @as(f64, @floatFromInt(i + 1));
                const t = v - 1;
                s += w * t * t;
                gg[i] = 2 * w * t;
            }
            return s;
        }
    };
    const r = try minimize(alloc, S.f, null, x, .{ .max_iterations = 1000 });
    try testing.expect(r.value < 1e-9);
    for (x) |v| try testing.expectApproxEqAbs(@as(f64, 1), v, 1e-4);
}
