const std = @import("std");
const math = std.math;

// ── Linear Equation ──────────────────────────────────────────
// ax + b = 0 => x = -b/a

pub fn solver_linear(a: f64, b: f64) callconv(.c) f64 {
    if (a == 0.0) return math.nan(f64);
    return -b / a;
}

// ── Quadratic Equation ───────────────────────────────────────
// ax^2 + bx + c = 0

pub fn solver_quadratic_discriminant(a: f64, b: f64, c: f64) callconv(.c) f64 {
    return b * b - 4.0 * a * c;
}

pub fn solver_quadratic_root1(a: f64, b: f64, c: f64) callconv(.c) f64 {
    if (a == 0.0) return solver_linear(b, c);
    const d = b * b - 4.0 * a * c;
    if (d < 0.0) return math.nan(f64);
    return (-b + math.sqrt(d)) / (2.0 * a);
}

pub fn solver_quadratic_root2(a: f64, b: f64, c: f64) callconv(.c) f64 {
    if (a == 0.0) return solver_linear(b, c);
    const d = b * b - 4.0 * a * c;
    if (d < 0.0) return math.nan(f64);
    return (-b - math.sqrt(d)) / (2.0 * a);
}

// ── Bisection Method ─────────────────────────────────────────
// Find root of f(x)=0 in [a,b] using bisection.
// f is represented by polynomial coefficients: c0 + c1*x + c2*x^2 + ...

fn evalPoly(coeffs: [*]const f64, degree: usize, x: f64) f64 {
    var result: f64 = 0.0;
    var power: f64 = 1.0;
    for (0..degree + 1) |i| {
        result += coeffs[i] * power;
        power *= x;
    }
    return result;
}

pub fn solver_bisection(coeffs: [*]const f64, degree: usize, a: f64, b: f64, tolerance: f64, max_iter: u32) callconv(.c) f64 {
    var lo = a;
    var hi = b;
    var fa = evalPoly(coeffs, degree, lo);
    if (fa * evalPoly(coeffs, degree, hi) > 0.0) return math.nan(f64);

    var i: u32 = 0;
    while (i < max_iter) : (i += 1) {
        const mid = (lo + hi) / 2.0;
        const fm = evalPoly(coeffs, degree, mid);
        if (@abs(fm) < tolerance or (hi - lo) / 2.0 < tolerance) return mid;
        if (fa * fm < 0.0) {
            hi = mid;
        } else {
            lo = mid;
            fa = fm;
        }
    }
    return (lo + hi) / 2.0;
}

// ── Newton-Raphson ───────────────────────────────────────────

fn evalPolyDeriv(coeffs: [*]const f64, degree: usize, x: f64) f64 {
    if (degree == 0) return 0.0;
    var result: f64 = 0.0;
    var power: f64 = 1.0;
    for (1..degree + 1) |i| {
        result += @as(f64, @floatFromInt(i)) * coeffs[i] * power;
        power *= x;
    }
    return result;
}

pub fn solver_newton(coeffs: [*]const f64, degree: usize, x0: f64, tolerance: f64, max_iter: u32) callconv(.c) f64 {
    var x = x0;
    var i: u32 = 0;
    while (i < max_iter) : (i += 1) {
        const fx = evalPoly(coeffs, degree, x);
        if (@abs(fx) < tolerance) return x;
        const dfx = evalPolyDeriv(coeffs, degree, x);
        if (@abs(dfx) < 1e-15) return math.nan(f64);
        x -= fx / dfx;
    }
    return x;
}

// ── Numerical Integration (Simpson's Rule) ───────────────────

pub fn solver_integrate_simpson(coeffs: [*]const f64, degree: usize, a: f64, b: f64, n_intervals: u32) callconv(.c) f64 {
    const n: usize = if (n_intervals % 2 == 0) n_intervals else n_intervals + 1;
    const h = (b - a) / @as(f64, @floatFromInt(n));
    var sum: f64 = evalPoly(coeffs, degree, a) + evalPoly(coeffs, degree, b);

    for (1..n) |i| {
        const x = a + @as(f64, @floatFromInt(i)) * h;
        const coeff: f64 = if (i % 2 == 0) 2.0 else 4.0;
        sum += coeff * evalPoly(coeffs, degree, x);
    }
    return sum * h / 3.0;
}

// ── Polynomial Evaluation ────────────────────────────────────

pub fn solver_eval_poly(coeffs: [*]const f64, degree: usize, x: f64) callconv(.c) f64 {
    return evalPoly(coeffs, degree, x);
}

// ── Linear Interpolation ─────────────────────────────────────

pub fn solver_lerp(a: f64, b: f64, t: f64) callconv(.c) f64 {
    return a + (b - a) * t;
}

pub fn solver_inverse_lerp(a: f64, b: f64, v: f64) callconv(.c) f64 {
    if (a == b) return 0.0;
    return (v - a) / (b - a);
}

pub fn solver_clamp(val: f64, min_val: f64, max_val: f64) callconv(.c) f64 {
    return @max(min_val, @min(max_val, val));
}

pub fn solver_map_range(val: f64, in_min: f64, in_max: f64, out_min: f64, out_max: f64) callconv(.c) f64 {
    const t = solver_inverse_lerp(in_min, in_max, val);
    return solver_lerp(out_min, out_max, t);
}

// ── C ABI exports ────────────────────────────────────────────

pub export fn stz_solver_linear(a: f64, b: f64) callconv(.c) f64 { return solver_linear(a, b); }
pub export fn stz_solver_quadratic_discriminant(a: f64, b: f64, c: f64) callconv(.c) f64 { return solver_quadratic_discriminant(a, b, c); }
pub export fn stz_solver_quadratic_root1(a: f64, b: f64, c: f64) callconv(.c) f64 { return solver_quadratic_root1(a, b, c); }
pub export fn stz_solver_quadratic_root2(a: f64, b: f64, c: f64) callconv(.c) f64 { return solver_quadratic_root2(a, b, c); }
pub export fn stz_solver_lerp(a: f64, b: f64, t: f64) callconv(.c) f64 { return solver_lerp(a, b, t); }
pub export fn stz_solver_inverse_lerp(a: f64, b: f64, v: f64) callconv(.c) f64 { return solver_inverse_lerp(a, b, v); }
pub export fn stz_solver_clamp(v: f64, mn: f64, mx: f64) callconv(.c) f64 { return solver_clamp(v, mn, mx); }
pub export fn stz_solver_map_range(v: f64, imn: f64, imx: f64, omn: f64, omx: f64) callconv(.c) f64 { return solver_map_range(v, imn, imx, omn, omx); }

// ── Tests ────────────────────────────────────────────────────

test "solver: linear" {
    try std.testing.expectApproxEqAbs(@as(f64, -2.0), solver_linear(3.0, 6.0), 1e-10);
    try std.testing.expectApproxEqAbs(@as(f64, 5.0), solver_linear(1.0, -5.0), 1e-10);
    try std.testing.expect(math.isNan(solver_linear(0.0, 5.0)));
}

test "solver: quadratic" {
    try std.testing.expectApproxEqAbs(@as(f64, 0.0), solver_quadratic_discriminant(1.0, -2.0, 1.0), 1e-10);

    const r1 = solver_quadratic_root1(1.0, -3.0, 2.0);
    const r2 = solver_quadratic_root2(1.0, -3.0, 2.0);
    try std.testing.expectApproxEqAbs(@as(f64, 2.0), r1, 1e-10);
    try std.testing.expectApproxEqAbs(@as(f64, 1.0), r2, 1e-10);

    try std.testing.expect(math.isNan(solver_quadratic_root1(1.0, 0.0, 1.0)));
}

test "solver: bisection on x^2 - 4 = 0" {
    const coeffs = [_]f64{ -4.0, 0.0, 1.0 };
    const root = solver_bisection(&coeffs, 2, 0.0, 10.0, 1e-10, 100);
    try std.testing.expectApproxEqAbs(@as(f64, 2.0), root, 1e-8);
}

test "solver: newton on x^2 - 4 = 0" {
    const coeffs = [_]f64{ -4.0, 0.0, 1.0 };
    const root = solver_newton(&coeffs, 2, 3.0, 1e-10, 100);
    try std.testing.expectApproxEqAbs(@as(f64, 2.0), root, 1e-8);
}

test "solver: simpson integration of x^2 from 0 to 1" {
    const coeffs = [_]f64{ 0.0, 0.0, 1.0 };
    const result = solver_integrate_simpson(&coeffs, 2, 0.0, 1.0, 100);
    try std.testing.expectApproxEqAbs(@as(f64, 1.0 / 3.0), result, 1e-8);
}

test "solver: polynomial eval" {
    const coeffs = [_]f64{ 1.0, 2.0, 3.0 };
    try std.testing.expectApproxEqAbs(@as(f64, 1.0), solver_eval_poly(&coeffs, 2, 0.0), 1e-10);
    try std.testing.expectApproxEqAbs(@as(f64, 6.0), solver_eval_poly(&coeffs, 2, 1.0), 1e-10);
}

test "solver: lerp and inverse_lerp" {
    try std.testing.expectApproxEqAbs(@as(f64, 5.0), solver_lerp(0.0, 10.0, 0.5), 1e-10);
    try std.testing.expectApproxEqAbs(@as(f64, 0.5), solver_inverse_lerp(0.0, 10.0, 5.0), 1e-10);
}

test "solver: clamp and map_range" {
    try std.testing.expectApproxEqAbs(@as(f64, 5.0), solver_clamp(5.0, 0.0, 10.0), 1e-10);
    try std.testing.expectApproxEqAbs(@as(f64, 0.0), solver_clamp(-5.0, 0.0, 10.0), 1e-10);
    try std.testing.expectApproxEqAbs(@as(f64, 10.0), solver_clamp(15.0, 0.0, 10.0), 1e-10);
    try std.testing.expectApproxEqAbs(@as(f64, 50.0), solver_map_range(5.0, 0.0, 10.0, 0.0, 100.0), 1e-10);
}
