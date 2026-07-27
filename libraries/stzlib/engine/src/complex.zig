//! Complex arithmetic.
//!
//! PHASE 7. This phase is explicitly gated -- "each gated on a genuine consumer, not
//! on completeness" -- so the census came first, and four of the five candidates
//! failed it:
//!
//!   * mpdecimal: the plan said "if the big-int-backed decimal proves insufficient".
//!     It was measured and it does not: 0.1 + 0.2 is exactly 0.3, a 29-place product
//!     is exact, a 30-digit integer plus 1e-9 is exact, and a non-terminating
//!     division reports itself approximate WITH A REASON. Not needed.
//!   * OSQP: nothing in the library poses a quadratic program.
//!   * HiGHS: nothing poses a mixed-integer program.
//!   * KISS FFT: there is no spectral or signal code to serve.
//!
//! COMPLEX NUMBERS PASSED, on one documented consumer. Phase 4 slice 8 built
//! symmetric eigenvalues and REFUSED the general case in writing: "a general matrix
//! has COMPLEX eigenvalues, which needs a different algorithm and a complex type the
//! library does not have. Handed a non-symmetric matrix this raises, instead of
//! returning the eigenvalues of (A + A')/2 and letting you believe they belong to A."
//! That refusal was right, and this is what lifts it.
//!
//! THE OPERATIONS HERE ARE THE ONES THAT CONSUMER NEEDS, plus the small closure
//! around them. This is not a general complex tower and does not pretend to be: no
//! branch-cut policy for log or the inverse trigonometric functions, because nothing
//! asks for them yet and guessing a branch cut is how a library acquires a wrong
//! answer it cannot remove later.

const std = @import("std");

pub const Complex = extern struct {
    re: f64,
    im: f64,

    pub inline fn init(re: f64, im: f64) Complex {
        return .{ .re = re, .im = im };
    }

    pub inline fn real(re: f64) Complex {
        return .{ .re = re, .im = 0 };
    }

    pub inline fn add(a: Complex, b: Complex) Complex {
        return .{ .re = a.re + b.re, .im = a.im + b.im };
    }

    pub inline fn sub(a: Complex, b: Complex) Complex {
        return .{ .re = a.re - b.re, .im = a.im - b.im };
    }

    pub inline fn mul(a: Complex, b: Complex) Complex {
        return .{
            .re = a.re * b.re - a.im * b.im,
            .im = a.re * b.im + a.im * b.re,
        };
    }

    /// SMITH'S FORMULA, not the textbook one. The naive
    /// (ac+bd)/(c²+d²), (bc−ad)/(c²+d²) squares the denominator's parts, so it
    /// overflows for |c| or |d| above about 1e154 and underflows below 1e-154 --
    /// on inputs the result itself handles perfectly well. Dividing through by the
    /// larger part first keeps the intermediates near 1.
    pub fn div(a: Complex, b: Complex) Complex {
        if (@abs(b.re) >= @abs(b.im)) {
            if (b.re == 0 and b.im == 0) return .{ .re = std.math.nan(f64), .im = std.math.nan(f64) };
            const r = b.im / b.re;
            const d = b.re + b.im * r;
            return .{ .re = (a.re + a.im * r) / d, .im = (a.im - a.re * r) / d };
        }
        const r = b.re / b.im;
        const d = b.re * r + b.im;
        return .{ .re = (a.re * r + a.im) / d, .im = (a.im * r - a.re) / d };
    }

    pub inline fn conj(a: Complex) Complex {
        return .{ .re = a.re, .im = -a.im };
    }

    pub inline fn neg(a: Complex) Complex {
        return .{ .re = -a.re, .im = -a.im };
    }

    /// |z|, via hypot rather than sqrt(re² + im²) -- same overflow argument as div.
    pub inline fn abs(a: Complex) f64 {
        return std.math.hypot(a.re, a.im);
    }

    pub inline fn absSquared(a: Complex) f64 {
        return a.re * a.re + a.im * a.im;
    }

    /// The principal argument, in (-pi, pi].
    pub inline fn arg(a: Complex) f64 {
        return std.math.atan2(a.im, a.re);
    }

    /// The principal square root: the one with non-negative real part. Computed
    /// through the magnitude rather than through arg/2, which loses accuracy for
    /// values near the negative real axis.
    pub fn sqrt(a: Complex) Complex {
        if (a.re == 0 and a.im == 0) return .{ .re = 0, .im = 0 };
        const m = abs(a);
        const t = @sqrt((m + @abs(a.re)) / 2);
        if (a.re >= 0) return .{ .re = t, .im = a.im / (2 * t) };
        const s = @sqrt((m - a.re) / 2);
        return .{ .re = @abs(a.im) / (2 * s), .im = if (a.im >= 0) s else -s };
    }

    pub fn exp(a: Complex) Complex {
        const e = @exp(a.re);
        return .{ .re = e * @cos(a.im), .im = e * @sin(a.im) };
    }

    pub inline fn isReal(a: Complex, tol: f64) bool {
        return @abs(a.im) <= tol;
    }
};

// ─── tests ───────────────────────────────────────────────────────────────────

const testing = std.testing;

test "the arithmetic every complex number owes" {
    const a = Complex.init(3, 4);
    const b = Complex.init(1, -2);
    try testing.expectEqual(@as(f64, 4), Complex.add(a, b).re);
    try testing.expectEqual(@as(f64, 2), Complex.add(a, b).im);
    try testing.expectEqual(@as(f64, 2), Complex.sub(a, b).re);
    try testing.expectEqual(@as(f64, 6), Complex.sub(a, b).im);
    // (3+4i)(1-2i) = 3 - 6i + 4i + 8 = 11 - 2i
    try testing.expectEqual(@as(f64, 11), Complex.mul(a, b).re);
    try testing.expectEqual(@as(f64, -2), Complex.mul(a, b).im);
    try testing.expectEqual(@as(f64, 5), Complex.abs(a));
}

test "division agrees with multiplication, which is the only real check" {
    const a = Complex.init(3, 4);
    const b = Complex.init(1, -2);
    const q = Complex.div(a, b);
    const back = Complex.mul(q, b);
    try testing.expectApproxEqAbs(a.re, back.re, 1e-12);
    try testing.expectApproxEqAbs(a.im, back.im, 1e-12);
}

test "Smith's formula survives magnitudes the textbook one cannot" {
    // |b|^2 would be 1e320 -- infinity in f64 -- yet the quotient is ordinary
    const a = Complex.init(1e200, 1e200);
    const b = Complex.init(1e160, 1e160);
    const q = Complex.div(a, b);
    try testing.expect(std.math.isFinite(q.re));
    try testing.expect(std.math.isFinite(q.im));
    try testing.expectApproxEqRel(@as(f64, 1e40), q.re, 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 0), q.im, 1e28);

    // and the same at the small end, where c^2 + d^2 would underflow to zero
    const c = Complex.init(1e-200, 0);
    const d = Complex.init(1e-200, 0);
    const q2 = Complex.div(c, d);
    try testing.expectApproxEqRel(@as(f64, 1), q2.re, 1e-12);
}

test "the principal square root, including the awkward side" {
    // sqrt(-1) = i
    const r1 = Complex.sqrt(Complex.init(-1, 0));
    try testing.expectApproxEqAbs(@as(f64, 0), r1.re, 1e-15);
    try testing.expectApproxEqAbs(@as(f64, 1), r1.im, 1e-15);
    // sqrt(3+4i) = 2+i
    const r2 = Complex.sqrt(Complex.init(3, 4));
    try testing.expectApproxEqAbs(@as(f64, 2), r2.re, 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 1), r2.im, 1e-12);
    // and squaring gets back where it started, for a spread of inputs
    const cases = [_]Complex{
        Complex.init(-4, 0),   Complex.init(0, -9),  Complex.init(-3, -4),
        Complex.init(1e-8, 0), Complex.init(0, 0),   Complex.init(5, -12),
    };
    for (cases) |z| {
        const s = Complex.sqrt(z);
        const back = Complex.mul(s, s);
        try testing.expectApproxEqAbs(z.re, back.re, 1e-9);
        try testing.expectApproxEqAbs(z.im, back.im, 1e-9);
        // principal: non-negative real part
        try testing.expect(s.re >= 0);
    }
}

test "exp of i*pi is -1, as it had better be" {
    const z = Complex.exp(Complex.init(0, std.math.pi));
    try testing.expectApproxEqAbs(@as(f64, -1), z.re, 1e-15);
    try testing.expectApproxEqAbs(@as(f64, 0), z.im, 1e-15);
}

test "dividing by zero gives NaN rather than a plausible number" {
    const q = Complex.div(Complex.init(1, 1), Complex.init(0, 0));
    try testing.expect(std.math.isNan(q.re));
    try testing.expect(std.math.isNan(q.im));
}
