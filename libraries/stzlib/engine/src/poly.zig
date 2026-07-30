//! POLYNOMIALS IN ONE VARIABLE -- and above all their ROOTS.
//!
//! ── WHY THE ROOTS ARE AN EIGENVALUE PROBLEM ──
//!
//! Past degree four no formula exists (Abel-Ruffini), so the honest general method is
//! not a formula at all. For a monic p(x) = x^n + b1 x^(n-1) + ... + bn, the COMPANION
//! MATRIX has p as its characteristic polynomial:
//!
//!     [ -b1  -b2  ...  -bn ]
//!     [   1    0  ...    0 ]
//!     [   0    1  ...    0 ]
//!     [  ...              ]
//!
//! so THE ROOTS OF p ARE EXACTLY THE EIGENVALUES OF C, and eigen_general.zig already
//! owns a Francis double-shift QR that balances on the way in and returns complex
//! eigenvalues. No second iteration is written here.
//!
//! ── WHY THIS IS IN THE ENGINE AND NOT IN A HOST ──
//!
//! Building the companion matrix is four lines, which is exactly why it kept being
//! written in the host: it looks like glue. It is not. The sign, the row that carries
//! the coefficients, the monic division, the degree-zero and leading-zero cases, and
//! the fact that the eigenvalues come back in no particular order are all decisions,
//! and a host that reimplements them gets a subtly different root finder. Ring had one;
//! Python or C over this engine would each have written another.
//!
//! So `roots` takes the coefficients and returns the roots. Nothing is left to assemble.

const std = @import("std");
const eigen_general = @import("eigen_general.zig");
const Complex = @import("complex.zig").Complex;

pub const PolyError = error{ OutOfMemory, NotAPolynomial, DidNotConverge };

/// Strip leading zero coefficients: [0, 0, 1, -3] is the polynomial x - 3, of degree 1,
/// and treating it as degree 3 would invent two roots at the origin.
fn effective(coeffs: []const f64) []const f64 {
    var i: usize = 0;
    while (i < coeffs.len and coeffs[i] == 0) i += 1;
    return coeffs[i..];
}

/// The degree, after leading zeros are discarded. A constant has degree 0.
pub fn degreeOf(coeffs: []const f64) usize {
    const c = effective(coeffs);
    if (c.len == 0) return 0;
    return c.len - 1;
}

/// THE COMPANION MATRIX of the monic form, row-major n*n where n is the degree.
///
/// `out` must hold n*n. Returns the degree actually used.
pub fn companion(coeffs: []const f64, out: []f64) !usize {
    const c = effective(coeffs);
    if (c.len < 2) return PolyError.NotAPolynomial; // a constant has no companion
    const n = c.len - 1;
    if (out.len < n * n) return PolyError.NotAPolynomial;

    const lead = c[0];
    if (lead == 0) return PolyError.NotAPolynomial;

    @memset(out[0 .. n * n], 0);
    // top row carries -b_k, the monic coefficients
    for (0..n) |j| out[j] = -c[j + 1] / lead;
    // subdiagonal ones
    for (1..n) |i| out[i * n + (i - 1)] = 1;
    return n;
}

/// THE ROOTS, complex, in no guaranteed order.
///
/// `out` must hold at least degreeOf(coeffs) entries. Returns how many were written.
pub fn roots(alloc: std.mem.Allocator, coeffs: []const f64, out: []Complex) !usize {
    const c = effective(coeffs);
    if (c.len < 2) return 0; // a constant (or nothing) has no roots
    const n = c.len - 1;
    if (out.len < n) return PolyError.NotAPolynomial;

    const m = try alloc.alloc(f64, n * n);
    defer alloc.free(m);
    _ = try companion(coeffs, m);

    // the QR iteration CONSUMES its input, which is fine: `m` is ours
    eigen_general.eigenvalues(m, n, out[0..n]) catch return PolyError.DidNotConverge;
    return n;
}

/// p(x) by Horner's rule -- fewer multiplications than powers, and better conditioned.
pub fn evalAt(coeffs: []const f64, x: f64) f64 {
    var acc: f64 = 0;
    for (coeffs) |a| acc = acc * x + a;
    return acc;
}

/// The derivative's coefficients, highest degree first. `out` needs coeffs.len - 1.
pub fn derivative(coeffs: []const f64, out: []f64) usize {
    if (coeffs.len < 2) return 0;
    const n = coeffs.len - 1; // degree as given
    for (0..n) |i| {
        out[i] = coeffs[i] * @as(f64, @floatFromInt(n - i));
    }
    return n;
}

// ── tests ────────────────────────────────────────────────────────────────────

const testing = std.testing;

fn hasRoot(rs: []const Complex, re: f64, im: f64, tol: f64) bool {
    for (rs) |z| {
        if (@abs(z.re - re) < tol and @abs(z.im - im) < tol) return true;
    }
    return false;
}

test "the roots of a factored cubic are its factors" {
    const alloc = testing.allocator;
    // (x-1)(x-2)(x-3) = x^3 - 6x^2 + 11x - 6
    const c = [_]f64{ 1, -6, 11, -6 };
    var out: [3]Complex = undefined;
    const n = try roots(alloc, &c, &out);
    try testing.expectEqual(@as(usize, 3), n);
    try testing.expect(hasRoot(out[0..n], 1, 0, 1e-8));
    try testing.expect(hasRoot(out[0..n], 2, 0, 1e-8));
    try testing.expect(hasRoot(out[0..n], 3, 0, 1e-8));
}

test "a complex pair comes back as a pair" {
    const alloc = testing.allocator;
    // x^2 + 1 -> +/- i
    const c = [_]f64{ 1, 0, 1 };
    var out: [2]Complex = undefined;
    const n = try roots(alloc, &c, &out);
    try testing.expectEqual(@as(usize, 2), n);
    try testing.expect(hasRoot(out[0..n], 0, 1, 1e-9));
    try testing.expect(hasRoot(out[0..n], 0, -1, 1e-9));
}

test "a NON-MONIC polynomial is divided down, not mis-rooted" {
    const alloc = testing.allocator;
    // 2x^2 - 6x + 4 = 2(x-1)(x-2)
    const c = [_]f64{ 2, -6, 4 };
    var out: [2]Complex = undefined;
    const n = try roots(alloc, &c, &out);
    try testing.expectEqual(@as(usize, 2), n);
    try testing.expect(hasRoot(out[0..n], 1, 0, 1e-9));
    try testing.expect(hasRoot(out[0..n], 2, 0, 1e-9));
}

test "LEADING ZEROS LOWER THE DEGREE instead of inventing roots at the origin" {
    const alloc = testing.allocator;
    // [0, 0, 1, -3] is x - 3, degree ONE. Read as degree three it would report two
    // extra roots at 0 -- a plausible wrong answer, which is the worst kind.
    const c = [_]f64{ 0, 0, 1, -3 };
    try testing.expectEqual(@as(usize, 1), degreeOf(&c));
    var out: [3]Complex = undefined;
    const n = try roots(alloc, &c, &out);
    try testing.expectEqual(@as(usize, 1), n);
    try testing.expectApproxEqAbs(@as(f64, 3), out[0].re, 1e-12);

    // a constant has no roots at all, and says so rather than erroring
    const k = [_]f64{5};
    try testing.expectEqual(@as(usize, 0), try roots(alloc, &k, &out));
    // and it has no companion matrix
    var cm: [4]f64 = undefined;
    try testing.expectError(PolyError.NotAPolynomial, companion(&k, &cm));
}

test "the companion matrix really has the polynomial as its characteristic one" {
    const alloc = testing.allocator;
    const c = [_]f64{ 1, -6, 11, -6 };
    var m: [9]f64 = undefined;
    const n = try companion(&c, &m);
    try testing.expectEqual(@as(usize, 3), n);
    // top row is -b_k, subdiagonal is 1
    try testing.expectApproxEqAbs(@as(f64, 6), m[0], 1e-15);
    try testing.expectApproxEqAbs(@as(f64, -11), m[1], 1e-15);
    try testing.expectApproxEqAbs(@as(f64, 6), m[2], 1e-15);
    try testing.expectApproxEqAbs(@as(f64, 1), m[3], 1e-15);
    try testing.expectApproxEqAbs(@as(f64, 1), m[7], 1e-15);

    // and its eigenvalues ARE the roots -- the identity the whole file rests on
    var ev: [3]Complex = undefined;
    try eigen_general.eigenvalues(&m, 3, &ev);
    try testing.expect(hasRoot(&ev, 1, 0, 1e-8));
    try testing.expect(hasRoot(&ev, 2, 0, 1e-8));
    try testing.expect(hasRoot(&ev, 3, 0, 1e-8));
    _ = alloc;
}

test "evalAt and derivative agree with hand arithmetic" {
    // p(x) = x^3 - 6x^2 + 11x - 6, p(4) = 64 - 96 + 44 - 6 = 6
    const c = [_]f64{ 1, -6, 11, -6 };
    try testing.expectApproxEqAbs(@as(f64, 6), evalAt(&c, 4), 1e-12);
    // a root evaluates to zero
    try testing.expectApproxEqAbs(@as(f64, 0), evalAt(&c, 2), 1e-12);

    // p'(x) = 3x^2 - 12x + 11
    var d: [3]f64 = undefined;
    const n = derivative(&c, &d);
    try testing.expectEqual(@as(usize, 3), n);
    try testing.expectApproxEqAbs(@as(f64, 3), d[0], 1e-15);
    try testing.expectApproxEqAbs(@as(f64, -12), d[1], 1e-15);
    try testing.expectApproxEqAbs(@as(f64, 11), d[2], 1e-15);
}
