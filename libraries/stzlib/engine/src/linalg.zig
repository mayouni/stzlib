// Softanza Engine -- linalg: matrix DECOMPOSITIONS.
//
// Phase 4 of the numeric foundation, pillar 4 item 4. The plan's argument for
// writing these rather than vendoring: reference LAPACK is Fortran, which breaks
// this build model outright, and we need perhaps six decompositions rather than
// 1700 routines. All eleven existing vendored dependencies are C.
//
// LU with partial pivoting comes first because it is the one that unlocks the
// others: a determinant, a linear solve, an inverse and (with QR later) least
// squares are all the same factorisation read differently.
//
// WHY THIS WAS URGENT. matrix.zig's determinant was naive COFACTOR EXPANSION --
// O(n!) time, and it allocated a fresh submatrix at every level of the recursion,
// so O(n!) allocations too. A 10x10 determinant is 3.6 million recursive calls; a
// 20x20 is not finishable. The inconsistency is the striking part: the SAME FILE's
// `inverse` has always done Gauss-Jordan with partial pivoting in O(n^3), so the
// pivoting machinery was sitting ten lines away the whole time.
//
// This module holds the algorithms; matrix.zig keeps the C ABI and asks here.

const std = @import("std");

/// An LU factorisation with partial pivoting: PA = LU.
///
/// L and U share one n*n buffer -- U on and above the diagonal, L's strictly
/// lower part below it, with L's unit diagonal implied. That is the standard
/// packing and it is why no second allocation is needed.
pub const LU = struct {
    /// n*n, row-major, holding L and U together as described above.
    lu: []f64,
    /// perm[i] is the original row now sitting at row i.
    perm: []usize,
    /// The determinant of the permutation: +1 for an even number of row swaps,
    /// -1 for an odd number. Carried during the factorisation because recovering
    /// it afterwards means counting cycles.
    sign: f64,
    n: usize,
    /// TRUE when a pivot column was numerically zero. The factorisation is still
    /// returned (it is the best available), but the matrix has no inverse and its
    /// determinant is 0.
    singular: bool,
    allocator: std.mem.Allocator,

    pub fn deinit(self: *LU) void {
        self.allocator.free(self.lu);
        self.allocator.free(self.perm);
    }

    pub inline fn at(self: *const LU, r: usize, c: usize) f64 {
        return self.lu[r * self.n + c];
    }
};

/// Factorise a square row-major matrix. `data` is copied, not modified.
///
/// Partial pivoting -- choosing the largest-magnitude candidate in the column as
/// the pivot -- is not an optimisation but a correctness requirement: without it
/// a perfectly invertible matrix with a zero in the wrong place divides by zero,
/// and a merely SMALL pivot amplifies rounding error by the ratio it is small by.
pub fn decompose(allocator: std.mem.Allocator, data: []const f64, n: usize) !LU {
    const lu = try allocator.alloc(f64, n * n);
    errdefer allocator.free(lu);
    @memcpy(lu, data[0 .. n * n]);

    const perm = try allocator.alloc(usize, n);
    errdefer allocator.free(perm);
    for (perm, 0..) |*p, i| p.* = i;

    var sign: f64 = 1.0;
    var singular = false;

    for (0..n) |k| {
        // find the pivot
        var pivot_row = k;
        var pivot_mag = @abs(lu[k * n + k]);
        for (k + 1..n) |r| {
            const v = @abs(lu[r * n + k]);
            if (v > pivot_mag) {
                pivot_mag = v;
                pivot_row = r;
            }
        }

        if (pivot_mag == 0.0) {
            // The whole remaining column is zero: singular. Keep going rather
            // than bailing, so the caller still gets a usable factorisation and
            // one consistent answer (determinant 0) instead of an error path.
            singular = true;
            continue;
        }

        if (pivot_row != k) {
            for (0..n) |c| {
                const t = lu[k * n + c];
                lu[k * n + c] = lu[pivot_row * n + c];
                lu[pivot_row * n + c] = t;
            }
            const tp = perm[k];
            perm[k] = perm[pivot_row];
            perm[pivot_row] = tp;
            sign = -sign;
        }

        // eliminate below, storing the multipliers in place as L
        const pivot = lu[k * n + k];
        for (k + 1..n) |r| {
            const factor = lu[r * n + k] / pivot;
            lu[r * n + k] = factor;
            if (factor == 0.0) continue;
            for (k + 1..n) |c| {
                lu[r * n + c] -= factor * lu[k * n + c];
            }
        }
    }

    return .{
        .lu = lu,
        .perm = perm,
        .sign = sign,
        .n = n,
        .singular = singular,
        .allocator = allocator,
    };
}

/// The determinant, from a factorisation already in hand: the permutation sign
/// times the product of U's diagonal. O(n) once the O(n^3) work is done, which is
/// the whole point of going through LU.
pub fn determinantOf(f: *const LU) f64 {
    if (f.singular) return 0.0;
    var d = f.sign;
    for (0..f.n) |i| d *= f.at(i, i);
    return d;
}

/// The determinant of a square matrix. O(n^3) rather than O(n!).
///
/// DIRECT FORMULAE FOR n <= 3, and the reason is exactness rather than speed.
/// Gaussian elimination divides by the pivot, so it rounds: the determinant of
/// [[1,2,3],[0,1,4],[5,6,0]] is exactly 1, and LU answers 0.9999999999999964 --
/// the same value NumPy gives, so the error is normal rather than a defect. But
/// the direct expansion of a 3x3 is six products and two additions of the INPUT
/// values, with no division at all, so for integer entries it is exact. Taking it
/// costs nothing and keeps every small determinant in the library exact, which is
/// what the existing tests had reasonably come to expect from cofactor expansion.
///
/// The cut is at 3 because that is where a closed form stops being small: a 4x4
/// needs 24 products, and by then the elimination is both shorter and accurate
/// enough. n <= 2 was already special-cased for the same reason.
pub fn determinant(allocator: std.mem.Allocator, data: []const f64, n: usize) !f64 {
    if (n == 0) return 0.0;
    if (n == 1) return data[0];
    if (n == 2) return data[0] * data[3] - data[1] * data[2];
    if (n == 3) {
        // rule of Sarrus
        return data[0] * (data[4] * data[8] - data[5] * data[7]) -
            data[1] * (data[3] * data[8] - data[5] * data[6]) +
            data[2] * (data[3] * data[7] - data[4] * data[6]);
    }
    var f = try decompose(allocator, data, n);
    defer f.deinit();
    return determinantOf(&f);
}

/// Solve Ax = b for one right-hand side, given a factorisation. Forward
/// substitution through L, then back substitution through U, with b permuted the
/// same way the rows were. Writes the solution into `x`.
///
/// This is the capability the library did not have: `inverse` existed, but
/// inverting a matrix in order to solve a system is both slower and less accurate
/// than solving it directly.
pub fn solveWith(f: *const LU, b: []const f64, x: []f64) bool {
    if (f.singular) return false;
    const n = f.n;

    // forward: Ly = Pb, L unit-diagonal
    for (0..n) |i| {
        var acc = b[f.perm[i]];
        for (0..i) |j| acc -= f.at(i, j) * x[j];
        x[i] = acc;
    }

    // backward: Ux = y
    var i = n;
    while (i > 0) {
        i -= 1;
        var acc = x[i];
        for (i + 1..n) |j| acc -= f.at(i, j) * x[j];
        const d = f.at(i, i);
        if (d == 0.0) return false;
        x[i] = acc / d;
    }
    return true;
}

/// Solve Ax = b, factorising as we go.
pub fn solve(allocator: std.mem.Allocator, data: []const f64, n: usize, b: []const f64, x: []f64) !bool {
    if (n == 0) return false;
    var f = try decompose(allocator, data, n);
    defer f.deinit();
    return solveWith(&f, b, x);
}

// ─── Cholesky: A = L L^T, for symmetric positive-definite A ───
//
// Half the work of LU (n^3/3 against 2n^3/3) and needs no pivoting, because a
// positive-definite matrix cannot produce a zero pivot. That is not a shortcut but
// a theorem, and it is why Cholesky is the right factorisation for a covariance or
// normal-equations matrix.
//
// It is also the cheapest POSITIVE-DEFINITENESS TEST there is: the factorisation
// exists if and only if the matrix is positive definite, so a failure is an answer
// rather than an error.

pub const Cholesky = struct {
    /// n*n, row-major. Only the lower triangle (including the diagonal) is
    /// meaningful; the upper is zero.
    l: []f64,
    n: usize,
    /// TRUE when A really was symmetric positive definite. When FALSE, `l` holds
    /// whatever had been computed when the first non-positive pivot appeared.
    positive_definite: bool,
    allocator: std.mem.Allocator,

    pub fn deinit(self: *Cholesky) void {
        self.allocator.free(self.l);
    }

    pub inline fn at(self: *const Cholesky, r: usize, c: usize) f64 {
        return self.l[r * self.n + c];
    }
};

pub fn cholesky(allocator: std.mem.Allocator, data: []const f64, n: usize) !Cholesky {
    const l = try allocator.alloc(f64, n * n);
    errdefer allocator.free(l);
    @memset(l, 0);

    var pd = true;
    for (0..n) |j| {
        var d = data[j * n + j];
        for (0..j) |k| {
            const ljk = l[j * n + k];
            d -= ljk * ljk;
        }
        if (!(d > 0)) {
            pd = false;
            break;
        }
        const ljj = @sqrt(d);
        l[j * n + j] = ljj;
        for (j + 1..n) |i| {
            var sum = data[i * n + j];
            for (0..j) |k| sum -= l[i * n + k] * l[j * n + k];
            l[i * n + j] = sum / ljj;
        }
    }

    return .{ .l = l, .n = n, .positive_definite = pd, .allocator = allocator };
}

/// Solve Ax = b given a Cholesky factorisation: forward through L, then backward
/// through L transposed.
pub fn choleskySolve(f: *const Cholesky, b: []const f64, x: []f64) bool {
    if (!f.positive_definite) return false;
    const n = f.n;

    // Ly = b
    for (0..n) |i| {
        var acc = b[i];
        for (0..i) |k| acc -= f.at(i, k) * x[k];
        x[i] = acc / f.at(i, i);
    }
    // L^T x = y
    var i = n;
    while (i > 0) {
        i -= 1;
        var acc = x[i];
        for (i + 1..n) |k| acc -= f.at(k, i) * x[k];
        x[i] = acc / f.at(i, i);
    }
    return true;
}

// ─── QR by Householder reflections, and LEAST SQUARES on top of it ───
//
// The decomposition that makes an OVERDETERMINED system answerable: more equations
// than unknowns, no exact solution, and the best answer is the one minimising the
// squared residual. That is linear regression with more than one predictor, and the
// library could not do it -- `stats.zig`'s regression is SIMPLE regression, a single
// slope and intercept from two data series.
//
// Householder rather than Gram-Schmidt, and normal equations avoided entirely.
// Forming A^T A (the normal-equations route) SQUARES THE CONDITION NUMBER: a
// problem that loses 8 digits becomes one that loses 16, which in f64 is all of
// them. Householder reflections are unconditionally stable and cost about twice as
// much, which is the right trade for a fit computed once.
//
// PACKING (the classic one): the working array holds R above the diagonal and the
// Householder vectors below it, with R's diagonal kept separately in `rdiag`. Q is
// never formed -- it is only ever applied, which is cheaper and is all a solve needs.

pub const QR = struct {
    /// m*n, row-major: R strictly above the diagonal, Householder vectors on and
    /// below it.
    qr: []f64,
    /// n entries: the diagonal of R.
    rdiag: []f64,
    m: usize,
    n: usize,
    allocator: std.mem.Allocator,

    pub fn deinit(self: *QR) void {
        self.allocator.free(self.qr);
        self.allocator.free(self.rdiag);
    }

    /// TRUE when every diagonal entry of R is non-zero, i.e. A's columns are
    /// linearly independent and the least-squares solution is unique.
    pub fn isFullRank(self: *const QR) bool {
        for (self.rdiag) |d| {
            if (d == 0) return false;
        }
        return true;
    }
};

/// Factorise an m*n matrix, m >= n. `data` is copied.
pub fn qr(allocator: std.mem.Allocator, data: []const f64, m: usize, n: usize) !QR {
    const a = try allocator.alloc(f64, m * n);
    errdefer allocator.free(a);
    @memcpy(a, data[0 .. m * n]);

    const rdiag = try allocator.alloc(f64, n);
    errdefer allocator.free(rdiag);
    @memset(rdiag, 0);

    for (0..n) |k| {
        // the 2-norm of the column below and including the diagonal, via hypot so
        // that a large entry cannot overflow the sum of squares
        var nrm: f64 = 0;
        for (k..m) |i| nrm = std.math.hypot(nrm, a[i * n + k]);

        if (nrm != 0.0) {
            // choose the sign that avoids cancellation
            if (a[k * n + k] < 0) nrm = -nrm;
            for (k..m) |i| a[i * n + k] /= nrm;
            a[k * n + k] += 1.0;

            // apply the reflection to the remaining columns
            for (k + 1..n) |j| {
                var s: f64 = 0;
                for (k..m) |i| s += a[i * n + k] * a[i * n + j];
                s = -s / a[k * n + k];
                for (k..m) |i| a[i * n + j] += s * a[i * n + k];
            }
        }
        rdiag[k] = -nrm;
    }

    return .{ .qr = a, .rdiag = rdiag, .m = m, .n = n, .allocator = allocator };
}

/// The least-squares solution of Ax = b, given a factorisation. Writes n values
/// into `x`. Returns false when A is rank deficient, where no unique minimiser
/// exists -- reporting that beats returning one of infinitely many.
pub fn qrSolve(f: *const QR, b: []const f64, x: []f64, scratch: []f64) bool {
    if (!f.isFullRank()) return false;
    const m = f.m;
    const n = f.n;
    @memcpy(scratch[0..m], b[0..m]);

    // apply Q^T to b, one reflection at a time
    for (0..n) |k| {
        var s: f64 = 0;
        for (k..m) |i| s += f.qr[i * n + k] * scratch[i];
        s = -s / f.qr[k * n + k];
        for (k..m) |i| scratch[i] += s * f.qr[i * n + k];
    }

    // back-substitute through R
    var k = n;
    while (k > 0) {
        k -= 1;
        x[k] = scratch[k] / f.rdiag[k];
        for (0..k) |i| scratch[i] -= x[k] * f.qr[i * n + k];
    }
    return true;
}

/// Least squares end to end: min ||Ax - b|| for an m*n A with m >= n.
pub fn leastSquares(allocator: std.mem.Allocator, data: []const f64, m: usize, n: usize, b: []const f64, x: []f64) !bool {
    if (n == 0 or m < n) return false;
    var f = try qr(allocator, data, m, n);
    defer f.deinit();
    const scratch = try allocator.alloc(f64, m);
    defer allocator.free(scratch);
    return qrSolve(&f, b, x, scratch);
}

// ─── Tests ───

const testing = std.testing;

test "LU: the determinant agrees with cofactor expansion, which is what it replaced" {
    // 3x3 with a known answer
    const a = [_]f64{ 6, 1, 1, 4, -2, 5, 2, 8, 7 };
    try testing.expectApproxEqAbs(@as(f64, -306), try determinant(testing.allocator, &a, 3), 1e-9);

    // 2x2 and 1x1 shortcuts
    const b = [_]f64{ 1, 2, 3, 4 };
    try testing.expectApproxEqAbs(@as(f64, -2), try determinant(testing.allocator, &b, 2), 1e-12);
    const c = [_]f64{7};
    try testing.expectApproxEqAbs(@as(f64, 7), try determinant(testing.allocator, &c, 1), 1e-12);

    // identity of any size is 1
    inline for (.{ 3, 5, 8 }) |n| {
        var idm: [n * n]f64 = @splat(0);
        for (0..n) |i| idm[i * n + i] = 1;
        try testing.expectApproxEqAbs(@as(f64, 1), try determinant(testing.allocator, &idm, n), 1e-12);
    }

    // a triangular matrix's determinant is the product of its diagonal --
    // independent of the algorithm, so a real check rather than a self-check
    const t = [_]f64{ 2, 9, 9, 9, 0, 3, 9, 9, 0, 0, 4, 9, 0, 0, 0, 5 };
    try testing.expectApproxEqAbs(@as(f64, 120), try determinant(testing.allocator, &t, 4), 1e-9);
}

test "LU: pivoting is required, not merely nice" {
    // A zero in the leading position. Without partial pivoting this divides by
    // zero; the matrix is perfectly invertible (determinant -1).
    const a = [_]f64{ 0, 1, 1, 0 };
    try testing.expectApproxEqAbs(@as(f64, -1), try determinant(testing.allocator, &a, 2), 1e-12);

    const b = [_]f64{ 0, 2, 1, 1, 0, 3, 4, 1, 8 };
    // computed by cofactor expansion by hand:
    //   0*(0*8-3*1) - 2*(1*8-3*4) + 1*(1*1-0*4) = 0 + 8 + 1 = 9
    try testing.expectApproxEqAbs(@as(f64, 9), try determinant(testing.allocator, &b, 3), 1e-9);

    // an odd number of swaps must flip the sign: swapping two rows of the
    // identity gives -1
    const s = [_]f64{ 0, 1, 0, 1, 0, 0, 0, 0, 1 };
    try testing.expectApproxEqAbs(@as(f64, -1), try determinant(testing.allocator, &s, 3), 1e-12);
}

test "LU: a singular matrix answers 0 rather than a small lie" {
    const dup_row = [_]f64{ 1, 2, 3, 1, 2, 3, 4, 5, 6 };
    try testing.expectEqual(@as(f64, 0), try determinant(testing.allocator, &dup_row, 3));

    const zero_col = [_]f64{ 1, 0, 3, 4, 0, 6, 7, 0, 9 };
    try testing.expectEqual(@as(f64, 0), try determinant(testing.allocator, &zero_col, 3));

    const all_zero = [_]f64{ 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    try testing.expectEqual(@as(f64, 0), try determinant(testing.allocator, &all_zero, 3));
}

test "LU: PA = LU actually reconstructs the original" {
    // The real test of a factorisation: multiply it back out.
    const n = 4;
    const a = [_]f64{
        4,  -2, 1,  3,
        3,  6,  -4, 2,
        2,  1,  8,  -5,
        -1, 3,  2,  7,
    };
    var f = try decompose(testing.allocator, &a, n);
    defer f.deinit();

    for (0..n) |i| {
        for (0..n) |j| {
            // (LU)[i][j] = sum over k of L[i][k] * U[k][j], with L unit-diagonal
            var acc: f64 = 0;
            for (0..n) |k| {
                const l: f64 = if (k < i) f.at(i, k) else if (k == i) 1.0 else 0.0;
                const u: f64 = if (k <= j) f.at(k, j) else 0.0;
                acc += l * u;
            }
            // ...must equal the permuted original
            try testing.expectApproxEqAbs(a[f.perm[i] * n + j], acc, 1e-9);
        }
    }
}

test "LU: solving a system, which the library could not do before" {
    // 2x + y - z = 8 ; -3x - y + 2z = -11 ; -2x + y + 2z = -3
    // solution (2, 3, -1)
    const a = [_]f64{ 2, 1, -1, -3, -1, 2, -2, 1, 2 };
    const b = [_]f64{ 8, -11, -3 };
    var x: [3]f64 = undefined;
    try testing.expect(try solve(testing.allocator, &a, 3, &b, &x));
    try testing.expectApproxEqAbs(@as(f64, 2), x[0], 1e-9);
    try testing.expectApproxEqAbs(@as(f64, 3), x[1], 1e-9);
    try testing.expectApproxEqAbs(@as(f64, -1), x[2], 1e-9);

    // one factorisation, many right-hand sides -- the reason to keep the LU
    var f = try decompose(testing.allocator, &a, 3);
    defer f.deinit();
    const b2 = [_]f64{ 0, 0, 0 };
    var x2: [3]f64 = undefined;
    try testing.expect(solveWith(&f, &b2, &x2));
    for (x2) |v| try testing.expectApproxEqAbs(@as(f64, 0), v, 1e-12);

    // a singular system is refused, not answered with garbage
    const sing = [_]f64{ 1, 1, 1, 1, 2, 2, 2, 2 };
    var x3: [2]f64 = undefined;
    try testing.expect(!try solve(testing.allocator, sing[0..4], 2, b[0..2], &x3));
}

test "LU: sizes a cofactor expansion could never reach" {
    // 12x12 would be ~479 million recursive calls the old way, each allocating.
    // Here it is a few thousand operations. Built so the answer is known: a
    // triangular matrix, whose determinant is the product of its diagonal.
    const n = 12;
    var a: [n * n]f64 = @splat(0);
    var want: f64 = 1;
    for (0..n) |i| {
        for (i..n) |j| a[i * n + j] = if (i == j) 2.0 else 1.0;
        want *= 2.0;
    }
    try testing.expectApproxEqAbs(want, try determinant(testing.allocator, &a, n), 1e-6);

    // and a 40x40, which is beyond any factorial-time algorithm entirely
    const m = 40;
    const big = try testing.allocator.alloc(f64, m * m);
    defer testing.allocator.free(big);
    @memset(big, 0);
    for (0..m) |i| big[i * m + i] = 1.0;
    try testing.expectApproxEqAbs(@as(f64, 1), try determinant(testing.allocator, big, m), 1e-9);
}

test "LU: small determinants stay EXACT, which the direct formulae are for" {
    // The case that caught this. Exactly 1; LU answers 0.9999999999999964
    // because it divides by the pivot. NumPy gives the same rounded value, so
    // that is normal for elimination -- but a 3x3 needs no elimination.
    const a = [_]f64{ 1, 2, 3, 0, 1, 4, 5, 6, 0 };
    try testing.expectEqual(@as(f64, 1), try determinant(testing.allocator, &a, 3));

    // the same matrix through the general path, to document what it costs
    var f = try decompose(testing.allocator, &a, 3);
    defer f.deinit();
    try testing.expect(determinantOf(&f) != 1.0);
    try testing.expectApproxEqAbs(@as(f64, 1), determinantOf(&f), 1e-12);

    // a few more small integer determinants that must land exactly
    const b = [_]f64{ 3, 8, 4, 6 }; // 18 - 32 = -14
    try testing.expectEqual(@as(f64, -14), try determinant(testing.allocator, &b, 2));
    const c = [_]f64{ 2, 0, 0, 0, 3, 0, 0, 0, 4 }; // 24
    try testing.expectEqual(@as(f64, 24), try determinant(testing.allocator, &c, 3));
    const d = [_]f64{ 1, 2, 3, 4, 5, 6, 7, 8, 9 }; // singular, exactly 0
    try testing.expectEqual(@as(f64, 0), try determinant(testing.allocator, &d, 3));
}

test "Cholesky: L L^T reconstructs A, and it agrees with LU" {
    // A symmetric positive-definite matrix (a Gram matrix, so PD by construction).
    const n = 4;
    const a = [_]f64{
        18, 22,  54,  42,
        22, 70,  86,  62,
        54, 86, 174, 134,
        42, 62, 134, 106,
    };

    var f = try cholesky(testing.allocator, &a, n);
    defer f.deinit();
    try testing.expect(f.positive_definite);

    // multiply the factorisation back out
    for (0..n) |i| {
        for (0..n) |j| {
            var acc: f64 = 0;
            for (0..n) |k| acc += f.at(i, k) * f.at(j, k);
            try testing.expectApproxEqAbs(a[i * n + j], acc, 1e-9);
        }
    }
    // the upper triangle is left zero, not garbage
    for (0..n) |i| {
        for (i + 1..n) |j| try testing.expectEqual(@as(f64, 0), f.at(i, j));
    }

    // TWO INDEPENDENT DECOMPOSITIONS MUST AGREE. Cholesky and LU share no code and
    // no algorithm, so a solve that matches is real evidence rather than a
    // self-check.
    const b = [_]f64{ 1, 2, 3, 4 };
    var x_chol: [n]f64 = undefined;
    var x_lu: [n]f64 = undefined;
    try testing.expect(choleskySolve(&f, &b, &x_chol));
    try testing.expect(try solve(testing.allocator, &a, n, &b, &x_lu));
    for (0..n) |i| try testing.expectApproxEqAbs(x_lu[i], x_chol[i], 1e-9);

    // ...and the solution satisfies the system
    for (0..n) |i| {
        var acc: f64 = 0;
        for (0..n) |j| acc += a[i * n + j] * x_chol[j];
        try testing.expectApproxEqAbs(b[i], acc, 1e-9);
    }
}

test "Cholesky: a non-positive-definite matrix is REPORTED, not approximated" {
    // symmetric but indefinite: eigenvalues of opposite sign
    const indef = [_]f64{ 1, 2, 2, 1 };
    var f1 = try cholesky(testing.allocator, &indef, 2);
    defer f1.deinit();
    try testing.expect(!f1.positive_definite);

    var x: [2]f64 = undefined;
    const b = [_]f64{ 1, 1 };
    try testing.expect(!choleskySolve(&f1, &b, &x));

    // negative on the diagonal
    const neg = [_]f64{ -1, 0, 0, -1 };
    var f2 = try cholesky(testing.allocator, &neg, 2);
    defer f2.deinit();
    try testing.expect(!f2.positive_definite);

    // a zero diagonal is semi-definite at best, which Cholesky also refuses
    const semi = [_]f64{ 0, 0, 0, 1 };
    var f3 = try cholesky(testing.allocator, &semi, 2);
    defer f3.deinit();
    try testing.expect(!f3.positive_definite);

    // the identity is the easiest positive-definite matrix there is
    const id = [_]f64{ 1, 0, 0, 1 };
    var f4 = try cholesky(testing.allocator, &id, 2);
    defer f4.deinit();
    try testing.expect(f4.positive_definite);
    try testing.expectEqual(@as(f64, 1), f4.at(0, 0));
    try testing.expectEqual(@as(f64, 1), f4.at(1, 1));
}

test "QR least squares: an exact fit is found exactly" {
    // Four points on the line y = 2x + 1, fitted with the design matrix [1, x].
    // Overdetermined (4 equations, 2 unknowns) but CONSISTENT, so the residual is
    // zero and the answer must be exactly the line.
    const m = 4;
    const n = 2;
    const a = [_]f64{ 1, 0, 1, 1, 1, 2, 1, 3 };
    const b = [_]f64{ 1, 3, 5, 7 };
    var x: [n]f64 = undefined;
    try testing.expect(try leastSquares(testing.allocator, &a, m, n, &b, &x));
    try testing.expectApproxEqAbs(@as(f64, 1), x[0], 1e-9); // intercept
    try testing.expectApproxEqAbs(@as(f64, 2), x[1], 1e-9); // slope
}

test "QR least squares: MULTIPLE regression, which the library could not do" {
    // z = 3 + 2u - 1.5v over five points. stats.zig's regression takes exactly one
    // predictor; this takes two, and there is no other route to it in the library.
    const m = 5;
    const n = 3;
    const a = [_]f64{
        1, 1, 1,
        1, 2, 1,
        1, 3, 2,
        1, 4, 3,
        1, 5, 5,
    };
    var b: [m]f64 = undefined;
    for (0..m) |i| {
        const u = a[i * n + 1];
        const v = a[i * n + 2];
        b[i] = 3.0 + 2.0 * u - 1.5 * v;
    }
    var x: [n]f64 = undefined;
    try testing.expect(try leastSquares(testing.allocator, &a, m, n, &b, &x));
    try testing.expectApproxEqAbs(@as(f64, 3.0), x[0], 1e-8);
    try testing.expectApproxEqAbs(@as(f64, 2.0), x[1], 1e-8);
    try testing.expectApproxEqAbs(@as(f64, -1.5), x[2], 1e-8);
}

test "QR least squares: an INEXACT fit satisfies the normal equations" {
    // Points that are NOT collinear, so no exact solution exists and the answer is
    // defined by a property rather than by a formula: the residual must be
    // orthogonal to every column of A, i.e. A^T(Ax - b) = 0. Checking that is
    // checking the DEFINITION of least squares, not a remembered number.
    const m = 5;
    const n = 2;
    const a = [_]f64{ 1, 1, 1, 2, 1, 3, 1, 4, 1, 5 };
    const b = [_]f64{ 2.1, 3.9, 6.2, 7.8, 10.1 };
    var x: [n]f64 = undefined;
    try testing.expect(try leastSquares(testing.allocator, &a, m, n, &b, &x));

    var resid: [m]f64 = undefined;
    for (0..m) |i| {
        var acc: f64 = 0;
        for (0..n) |j| acc += a[i * n + j] * x[j];
        resid[i] = acc - b[i];
    }
    for (0..n) |j| {
        var dot: f64 = 0;
        for (0..m) |i| dot += a[i * n + j] * resid[i];
        try testing.expectApproxEqAbs(@as(f64, 0), dot, 1e-9);
    }

    // and no other coefficient vector can do better -- perturb and the residual
    // norm must grow
    var ss: f64 = 0;
    for (resid) |r| ss += r * r;
    inline for (.{ .{ 0.01, 0.0 }, .{ -0.01, 0.0 }, .{ 0.0, 0.01 }, .{ 0.0, -0.01 } }) |d| {
        var ss2: f64 = 0;
        for (0..m) |i| {
            var acc: f64 = 0;
            acc += a[i * n + 0] * (x[0] + d[0]);
            acc += a[i * n + 1] * (x[1] + d[1]);
            const r = acc - b[i];
            ss2 += r * r;
        }
        try testing.expect(ss2 > ss);
    }
}

test "QR: on a SQUARE system it must agree with LU, which shares none of its code" {
    const n = 4;
    const a = [_]f64{
        4,  -2, 1,  3,
        3,  6,  -4, 2,
        2,  1,  8,  -5,
        -1, 3,  2,  7,
    };
    const b = [_]f64{ 5, -3, 8, 1 };
    var x_qr: [n]f64 = undefined;
    var x_lu: [n]f64 = undefined;
    try testing.expect(try leastSquares(testing.allocator, &a, n, n, &b, &x_qr));
    try testing.expect(try solve(testing.allocator, &a, n, &b, &x_lu));
    for (0..n) |i| try testing.expectApproxEqAbs(x_lu[i], x_qr[i], 1e-8);
}

test "QR: rank deficiency and bad shapes are refused" {
    // a duplicated column: the columns are dependent, so no unique minimiser
    const dup = [_]f64{ 1, 1, 2, 2, 3, 3 }; // 3x2, column 2 == column 1
    var x: [2]f64 = undefined;
    const b = [_]f64{ 1, 2, 3 };
    try testing.expect(!try leastSquares(testing.allocator, &dup, 3, 2, &b, &x));

    var f = try qr(testing.allocator, &dup, 3, 2);
    defer f.deinit();
    try testing.expect(!f.isFullRank());

    // an UNDERdetermined system (fewer equations than unknowns) is refused rather
    // than answered: there are infinitely many exact solutions and least squares
    // does not choose between them.
    const wide = [_]f64{ 1, 2, 3, 4, 5, 6 }; // 2x3
    var x3: [3]f64 = undefined;
    try testing.expect(!try leastSquares(testing.allocator, &wide, 2, 3, b[0..2], &x3));

    // zero columns
    try testing.expect(!try leastSquares(testing.allocator, &dup, 3, 0, &b, &x));
}
