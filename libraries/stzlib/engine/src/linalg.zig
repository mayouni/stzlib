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
    /// FIXED in slice 9, and it was a SILENT WRONG ANSWER of the worst kind.
    ///
    /// This tested `d == 0` exactly. Householder QR does not leave a dependent
    /// column's diagonal at exactly zero -- it leaves it at rounding level, and how
    /// close to zero depends on the size of the matrix. On a 3x2 with a duplicated
    /// column it happens to come out exact, which is why slice 7's test passed. On a
    /// 200x4 design matrix with a redundant predictor it does not, so `isFullRank`
    /// answered TRUE for a rank-deficient system and `qrSolve` then back-substituted
    /// through a near-zero pivot and returned COEFFICIENTS AROUND -9.7e12 -- garbage,
    /// presented as a fit.
    ///
    /// Slice 9 found this by building the SVD rank and noticing the two disagreed:
    /// `rankOf` said 3 of 4 columns while `LeastSquaresFor` happily produced an
    /// answer. Same root cause as the condition-number defect below -- an exact
    /// `== 0` where the quantity is only ever approximately zero -- and it asks the
    /// same authority for the answer now.
    pub fn isFullRank(self: *const QR) bool {
        var largest: f64 = 0;
        for (self.rdiag) |d| largest = @max(largest, @abs(d));
        if (largest == 0) return false;
        const tol = negligibleThreshold(largest, @max(self.m, self.n));
        for (self.rdiag) |d| {
            if (@abs(d) <= tol) return false;
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

// ─── Symmetric eigenvalues by cyclic Jacobi rotations ───
//
// The last decomposition phase 4 needs, and the one that EXPLAINS the others. A
// symmetric matrix is positive definite exactly when every eigenvalue is positive,
// so this gives an independent check on the Cholesky test above -- two algorithms
// sharing no code answering one question.
//
// WHY JACOBI AND NOT QR ITERATION, which is what LAPACK uses. Jacobi is O(n^3) per
// sweep with a small number of sweeps, so it is slower than tridiagonal-QR on large
// matrices. In exchange it is about eighty lines, needs no tridiagonal reduction, no
// shift strategy and no deflation logic, and it computes the SMALL eigenvalues to
// high relative accuracy -- which is exactly what a condition number and a rank test
// depend on. Our matrices are table- and covariance-sized. This is the right point
// on that curve; if large dense symmetric problems ever become real, the answer is
// tridiagonal QR, not a faster Jacobi.
//
// SYMMETRY IS REQUIRED, NOT ASSUMED. A non-symmetric matrix has complex eigenvalues
// in general, which needs a different algorithm and a complex type we do not have.
// Handed one, this REPORTS rather than returning the eigenvalues of the symmetric
// part and letting the caller believe them.

pub const Eigen = struct {
    /// n eigenvalues, sorted DESCENDING -- the convention PCA expects, so the first
    /// principal component comes first.
    values: []f64,
    /// n*n, row-major. Column j is the unit eigenvector for values[j].
    vectors: []f64,
    n: usize,
    /// FALSE when the input was not symmetric, in which case nothing was computed.
    symmetric: bool,
    /// FALSE when the sweeps ran out before the off-diagonal mass fell below
    /// tolerance. The values are still the best available, but say so.
    converged: bool,
    allocator: std.mem.Allocator,

    pub fn deinit(self: *Eigen) void {
        self.allocator.free(self.values);
        self.allocator.free(self.vectors);
    }

    /// Element i of column j of the eigenvector matrix.
    pub inline fn vec(self: *const Eigen, i: usize, j: usize) f64 {
        return self.vectors[i * self.n + j];
    }
};

const JACOBI_SWEEPS = 100;

/// Is A symmetric to within a relative tolerance? Data that came out of a real
/// computation is rarely symmetric to the last bit, so an exact test would reject
/// matrices that are symmetric in every meaningful sense.
pub fn isSymmetric(data: []const f64, n: usize) bool {
    var scale: f64 = 0;
    for (data[0 .. n * n]) |v| scale = @max(scale, @abs(v));
    if (scale == 0) return true;
    const tol = 1e-12 * scale;
    for (0..n) |i| {
        for (i + 1..n) |j| {
            if (@abs(data[i * n + j] - data[j * n + i]) > tol) return false;
        }
    }
    return true;
}

pub fn eigenSymmetric(allocator: std.mem.Allocator, data: []const f64, n: usize) !Eigen {
    const values = try allocator.alloc(f64, n);
    errdefer allocator.free(values);
    const vectors = try allocator.alloc(f64, n * n);
    errdefer allocator.free(vectors);

    if (!isSymmetric(data, n)) {
        @memset(values, 0);
        @memset(vectors, 0);
        return .{
            .values = values,
            .vectors = vectors,
            .n = n,
            .symmetric = false,
            .converged = false,
            .allocator = allocator,
        };
    }

    // working copy of A, and V starting as the identity
    const a = try allocator.alloc(f64, n * n);
    defer allocator.free(a);
    @memcpy(a, data[0 .. n * n]);
    @memset(vectors, 0);
    for (0..n) |i| vectors[i * n + i] = 1.0;

    var converged = false;
    var sweep: usize = 0;
    while (sweep < JACOBI_SWEEPS) : (sweep += 1) {
        // the off-diagonal mass: what the rotations are driving to zero
        var off: f64 = 0;
        for (0..n) |i| {
            for (i + 1..n) |j| off += a[i * n + j] * a[i * n + j];
        }
        if (off <= 1e-30) {
            converged = true;
            break;
        }

        for (0..n) |p| {
            for (p + 1..n) |q| {
                const apq = a[p * n + q];
                if (@abs(apq) <= 1e-300) continue;

                // The rotation that zeroes (p,q), by the stable formula: t is the
                // SMALLER root, so c stays near 1 and no cancellation occurs however
                // close app and aqq are.
                const theta = (a[q * n + q] - a[p * n + p]) / (2.0 * apq);
                const sgn: f64 = if (theta >= 0) 1.0 else -1.0;
                const t = sgn / (@abs(theta) + @sqrt(theta * theta + 1.0));
                const c = 1.0 / @sqrt(t * t + 1.0);
                const sn = t * c;

                // rotate A on both sides
                for (0..n) |k| {
                    if (k != p and k != q) {
                        const akp = a[k * n + p];
                        const akq = a[k * n + q];
                        const newp = c * akp - sn * akq;
                        const newq = sn * akp + c * akq;
                        a[k * n + p] = newp;
                        a[p * n + k] = newp;
                        a[k * n + q] = newq;
                        a[q * n + k] = newq;
                    }
                }
                const app = a[p * n + p];
                const aqq = a[q * n + q];
                a[p * n + p] = app - t * apq;
                a[q * n + q] = aqq + t * apq;
                a[p * n + q] = 0;
                a[q * n + p] = 0;

                // accumulate the rotation into V
                for (0..n) |k| {
                    const vkp = vectors[k * n + p];
                    const vkq = vectors[k * n + q];
                    vectors[k * n + p] = c * vkp - sn * vkq;
                    vectors[k * n + q] = sn * vkp + c * vkq;
                }
            }
        }
    }

    for (0..n) |i| values[i] = a[i * n + i];

    // Sort DESCENDING, carrying each eigenvector with its value. A selection sort:
    // n is small here and the swap has to move a whole column.
    for (0..n) |i| {
        var best = i;
        for (i + 1..n) |j| {
            if (values[j] > values[best]) best = j;
        }
        if (best != i) {
            const tv = values[i];
            values[i] = values[best];
            values[best] = tv;
            for (0..n) |k| {
                const tmp = vectors[k * n + i];
                vectors[k * n + i] = vectors[k * n + best];
                vectors[k * n + best] = tmp;
            }
        }
    }

    return .{
        .values = values,
        .vectors = vectors,
        .n = n,
        .symmetric = true,
        .converged = converged,
        .allocator = allocator,
    };
}

// ── WHAT COUNTS AS ZERO LIVES HERE, AND ONLY HERE ──────────────────────
//
// A rank test and a condition number are the SAME QUESTION asked twice: "is the
// smallest value negligible?" Rank counts the ones that are not; a condition number
// divides by the smallest one that is not. So they must use ONE threshold, or they
// disagree -- which they did.
//
// Found by building the rectangular case (slice 9) and checking it against the
// symmetric one (slice 8). One-sided Jacobi leaves a rank-deficient column at
// rounding level rather than exactly zero, so for a 5x3 matrix of rank 2:
//
//     singular values   5.418285e0   2.577243e0   6.037497e-17
//     rankOf                 -> 2                (correct: relative threshold)
//     conditionNumberOf      -> 8.974391e16      (WRONG: a finite number)
//
// And slice 8 had it too -- a singular symmetric matrix reported rank 2 with a
// condition number of 1.2213e16. Its test passed only because the matrix I happened
// to choose, [[1,1],[1,1]], produces an EXACT zero eigenvalue. The general case does
// not.
//
// A matrix whose smallest value is at rounding level IS numerically singular, and an
// infinite condition number is the honest report: no solve with it can be trusted.
// Both families ask this function now, so the two answers cannot drift apart.
//
// RELATIVE to the largest value, and scaled by the dimension, because error
// accumulates with size. An absolute threshold would call a matrix of uniformly tiny
// entries singular, when scaling a matrix cannot change its rank.
pub fn negligibleThreshold(largest: f64, dim: usize) f64 {
    return 1e-12 * largest * @as(f64, @floatFromInt(dim));
}

/// The 2-norm condition number of a SYMMETRIC matrix: the largest eigenvalue in
/// magnitude over the smallest. Infinity for a singular matrix, which is the honest
/// answer -- and this is the number that says how many digits a solve can lose.
pub fn conditionNumberSymmetric(allocator: std.mem.Allocator, data: []const f64, n: usize) !f64 {
    var e = try eigenSymmetric(allocator, data, n);
    defer e.deinit();
    if (!e.symmetric) return std.math.nan(f64);
    var lo = std.math.inf(f64);
    var hi: f64 = 0;
    for (e.values) |v| {
        const m = @abs(v);
        lo = @min(lo, m);
        hi = @max(hi, m);
    }
    // negligible, not just zero -- see negligibleThreshold above
    if (lo <= negligibleThreshold(hi, n)) return std.math.inf(f64);
    return hi / lo;
}

/// The RANK of a symmetric matrix: how many eigenvalues are non-negligible RELATIVE
/// to the largest. The relative threshold matters -- an absolute one would call a
/// matrix of uniformly tiny entries rank zero.
pub fn rankSymmetric(allocator: std.mem.Allocator, data: []const f64, n: usize) !usize {
    var e = try eigenSymmetric(allocator, data, n);
    defer e.deinit();
    if (!e.symmetric) return 0;
    var hi: f64 = 0;
    for (e.values) |v| hi = @max(hi, @abs(v));
    if (hi == 0) return 0;
    const tol = negligibleThreshold(hi, n);
    var r: usize = 0;
    for (e.values) |v| {
        if (@abs(v) > tol) r += 1;
    }
    return r;
}

// ─── SVD by one-sided Jacobi, and the RECTANGULAR rank and conditioning it gives ───
//
// The last decomposition. Slice 8's symmetric eigen answers rank and conditioning
// for a SQUARE SYMMETRIC matrix; a design matrix is neither. Fitting 200
// observations to 4 predictors and asking "are my predictors collinear?" needs the
// singular values of a 200x4, which no route in the library reached.
//
// ONE-SIDED JACOBI rather than Golub-Kahan bidiagonalisation. Golub-Kahan is what
// LAPACK uses and is faster on large matrices, but it is two algorithms (bidiagonal
// reduction, then an implicit-shift QR sweep on the bidiagonal form) and several
// hundred lines. One-sided Jacobi is the SAME ROTATION IDEA as the symmetric eigen
// next door: orthogonalise pairs of COLUMNS until every pair is orthogonal, at which
// point the column norms ARE the singular values. It reuses a rotation this file
// already had to get right, and it is the variant known for high relative accuracy on
// the SMALL singular values -- which, exactly as with the eigenvalues, is what a rank
// test and a condition number are decided by.
//
// A note on what is NOT returned: U is m*n and V is n*n here (the "thin" SVD), which
// is all that rank, conditioning and a least-squares diagnosis need. The full m*m U
// costs more and has no consumer yet.

/// The SVD OF ANY SHAPE, wide included.
///
/// `svd` below computes the thin decomposition for m >= n, which is what rank,
/// conditioning and a least-squares diagnosis need. A WIDE matrix (m < n) was
/// refused at the Ring surface with "transpose it -- the singular values are the
/// same", which is true for the VALUES and quietly incomplete for the factors: the
/// singular values of A and A' agree, but U and V SWAP. Making the caller transpose
/// leaves them to remember that, and forgetting it produces a decomposition that
/// multiplies back to A' rather than to A.
///
/// So the transpose happens here, once, with the swap done correctly:
///
///     A = B'  where B = A'  and  B = U_B S V_B'
///     A = (U_B S V_B')' = V_B S U_B'
///     so  U_A = V_B  and  V_A = U_B
///
/// ONE IMPLEMENTATION either way -- this calls the same one-sided Jacobi routine.
pub fn svdAnyShape(
    allocator: std.mem.Allocator,
    data: []const f64,
    m: usize,
    n: usize,
) !Svd {
    if (m >= n) return svd(allocator, data, m, n);

    // transpose into B (n x m), decompose, then swap the factors back
    const bt = try allocator.alloc(f64, m * n);
    defer allocator.free(bt);
    for (0..m) |i| {
        for (0..n) |j| bt[j * m + i] = data[i * n + j];
    }

    var d = try svd(allocator, bt, n, m);
    // d.u is n x m, d.v is m x m, d.values is m -- and A = d.v * S * d.u'
    const u = try allocator.alloc(f64, m * m);
    errdefer allocator.free(u);
    const v = try allocator.alloc(f64, n * m);
    errdefer allocator.free(v);
    const values = try allocator.alloc(f64, m);
    errdefer allocator.free(values);

    @memcpy(u, d.v);
    @memcpy(v, d.u);
    @memcpy(values, d.values);
    const conv = d.converged;
    d.deinit();

    return Svd{
        .values = values,
        .u = u,
        .v = v,
        .m = m,
        .n = m,
        .converged = conv,
        .allocator = allocator,
    };
}

pub const Svd = struct {
    /// min(m,n) singular values, sorted DESCENDING. Always non-negative.
    values: []f64,
    /// m*n, row-major: column j is the j-th left singular vector.
    u: []f64,
    /// n*n, row-major: column j is the j-th right singular vector.
    v: []f64,
    m: usize,
    n: usize,
    converged: bool,
    allocator: std.mem.Allocator,

    pub fn deinit(self: *Svd) void {
        self.allocator.free(self.values);
        self.allocator.free(self.u);
        self.allocator.free(self.v);
    }
};

const SVD_SWEEPS = 60;

/// Thin SVD of an m*n matrix with m >= n.
pub fn svd(allocator: std.mem.Allocator, data: []const f64, m: usize, n: usize) !Svd {
    const u = try allocator.alloc(f64, m * n);
    errdefer allocator.free(u);
    const v = try allocator.alloc(f64, n * n);
    errdefer allocator.free(v);
    const values = try allocator.alloc(f64, n);
    errdefer allocator.free(values);

    @memcpy(u, data[0 .. m * n]);
    @memset(v, 0);
    for (0..n) |i| v[i * n + i] = 1.0;

    var converged = false;
    var sweep: usize = 0;
    while (sweep < SVD_SWEEPS) : (sweep += 1) {
        var off: f64 = 0;
        for (0..n) |p| {
            for (p + 1..n) |q| {
                // the three inner products that describe the (p,q) column pair
                var alpha: f64 = 0;
                var beta: f64 = 0;
                var gamma: f64 = 0;
                for (0..m) |i| {
                    const up = u[i * n + p];
                    const uq = u[i * n + q];
                    alpha += up * up;
                    beta += uq * uq;
                    gamma += up * uq;
                }

                // how far from orthogonal this pair is, measured RELATIVE to the two
                // column norms -- an absolute test would spin forever on tiny columns
                // and stop too early on large ones
                const scale = @sqrt(alpha * beta);
                if (scale == 0) continue;
                const rel = @abs(gamma) / scale;
                off = @max(off, rel);
                if (rel <= 1e-15) continue;

                // the rotation that orthogonalises them, by the stable smaller-root
                // formula so c stays near 1 however close alpha and beta are
                const zeta = (beta - alpha) / (2.0 * gamma);
                const sgn: f64 = if (zeta >= 0) 1.0 else -1.0;
                const t = sgn / (@abs(zeta) + @sqrt(1.0 + zeta * zeta));
                const c = 1.0 / @sqrt(1.0 + t * t);
                const s = c * t;

                for (0..m) |i| {
                    const up = u[i * n + p];
                    const uq = u[i * n + q];
                    u[i * n + p] = c * up - s * uq;
                    u[i * n + q] = s * up + c * uq;
                }
                for (0..n) |i| {
                    const vp = v[i * n + p];
                    const vq = v[i * n + q];
                    v[i * n + p] = c * vp - s * vq;
                    v[i * n + q] = s * vp + c * vq;
                }
            }
        }
        if (off <= 1e-15) {
            converged = true;
            break;
        }
    }

    // once the columns are mutually orthogonal, their norms ARE the singular values
    for (0..n) |j| {
        var norm: f64 = 0;
        for (0..m) |i| norm = std.math.hypot(norm, u[i * n + j]);
        values[j] = norm;
        if (norm > 0) {
            for (0..m) |i| u[i * n + j] /= norm;
        }
    }

    // sort descending, carrying both singular vectors with each value
    for (0..n) |i| {
        var best = i;
        for (i + 1..n) |j| {
            if (values[j] > values[best]) best = j;
        }
        if (best != i) {
            const tv = values[i];
            values[i] = values[best];
            values[best] = tv;
            for (0..m) |k| {
                const tmp = u[k * n + i];
                u[k * n + i] = u[k * n + best];
                u[k * n + best] = tmp;
            }
            for (0..n) |k| {
                const tmp = v[k * n + i];
                v[k * n + i] = v[k * n + best];
                v[k * n + best] = tmp;
            }
        }
    }

    return .{
        .values = values,
        .u = u,
        .v = v,
        .m = m,
        .n = n,
        .converged = converged,
        .allocator = allocator,
    };
}

/// The rank of ANY m*n matrix (m >= n): singular values that are non-negligible
/// relative to the largest. This is the general answer that rankSymmetric could only
/// give for the square symmetric case.
pub fn rankOf(allocator: std.mem.Allocator, data: []const f64, m: usize, n: usize) !usize {
    if (m == 0 or n == 0) return 0;
    // ANY SHAPE since phase 7. Rank is a property of the matrix, not of how it
    // happens to be oriented -- rank(A) = rank(A') always -- so refusing a wide
    // matrix was never defensible on mathematical grounds, only on the SVD's.
    var d = try svdAnyShape(allocator, data, m, n);
    defer d.deinit();
    const hi = d.values[0];
    if (hi == 0) return 0;
    const tol = negligibleThreshold(hi, @max(m, n));
    var r: usize = 0;
    for (d.values) |sv| {
        if (sv > tol) r += 1;
    }
    return r;
}

/// The 2-norm condition number of any m*n matrix: largest singular value over
/// smallest. Infinity when rank deficient -- the honest answer, and the number that
/// says how many digits a least-squares fit can lose.
pub fn conditionNumberOf(allocator: std.mem.Allocator, data: []const f64, m: usize, n: usize) !f64 {
    if (m == 0 or n == 0) return std.math.nan(f64);
    var d = try svdAnyShape(allocator, data, m, n);
    defer d.deinit();
    const k = @min(m, n);
    const hi = d.values[0];
    const lo = d.values[k - 1];
    // negligible, not just zero: one-sided Jacobi leaves a dependent column at
    // rounding level, so `lo == 0` would report a finite 9e16 for a matrix rankOf
    // has already called deficient
    if (lo <= negligibleThreshold(hi, @max(m, n))) return std.math.inf(f64);
    return hi / lo;
}

// ─── The Moore-Penrose pseudo-inverse, and the MINIMUM-NORM solution ───
//
// A+ = V * S+ * U', where S+ inverts every singular value that is not negligible
// and sets the rest to zero. Two lines of linear algebra on top of the SVD, and the
// only subtle part is that "negligible" must be the SAME judgement rank and the
// condition number use -- so it asks negligibleThreshold, like everything else.
//
// WHAT IT IS FOR, and it is not "inverting a matrix that has no inverse" for its own
// sake. Slice 7's leastSquares REFUSES a rank-deficient system, on the stated grounds
// that infinitely many coefficient vectors share the minimum residual and least
// squares has no opinion about which to prefer -- "that is minimum-norm, a different
// problem needing a different decomposition." THIS IS THAT DECOMPOSITION. A+b is the
// solution that both minimises ||Ax - b|| AND, among all the vectors that do, has the
// smallest norm itself. That is a principled choice rather than an arbitrary one,
// which is why it can be offered where least squares declines.
//
// It generalises everything either side of it:
//   * A square and invertible  -> A+ is exactly the inverse
//   * A tall and full rank     -> A+b is exactly the least-squares solution
//   * A rank deficient         -> A+b is the minimum-norm least-squares solution
//   * A wide                   -> A+b is the minimum-norm EXACT solution
//
// THE FOUR PENROSE CONDITIONS define A+ uniquely, and the tests check all four rather
// than any computed number:  A A+ A = A,  A+ A A+ = A+,  (A A+)' = A A+,  (A+ A)' = A+ A.

/// A+ for any m*n matrix, written into `out` as n*m, row-major.
///
/// Handles the WIDE case (m < n) by transposing: pinv(A) = pinv(A')', and the SVD
/// here needs at least as many rows as columns. Doing it internally is worth the few
/// lines -- a pseudo-inverse that refused half of all shapes would be a poor
/// generalisation of an inverse.
pub fn pseudoInverse(allocator: std.mem.Allocator, data: []const f64, m: usize, n: usize, out: []f64) !bool {
    if (m == 0 or n == 0) return false;

    if (m < n) {
        // transpose, recurse, transpose the result back
        const at = try allocator.alloc(f64, n * m);
        defer allocator.free(at);
        for (0..m) |i| {
            for (0..n) |j| at[j * m + i] = data[i * n + j];
        }
        const pt = try allocator.alloc(f64, m * n);
        defer allocator.free(pt);
        if (!try pseudoInverse(allocator, at, n, m, pt)) return false;
        // pt is m*n (the pinv of the n*m transpose); out wants n*m
        for (0..m) |i| {
            for (0..n) |j| out[j * m + i] = pt[i * n + j];
        }
        return true;
    }

    var d = try svd(allocator, data, m, n);
    defer d.deinit();

    const tol = negligibleThreshold(d.values[0], @max(m, n));

    // out[i][j] = sum_k V[i][k] * (1/s_k) * U[j][k], skipping negligible s_k
    @memset(out[0 .. n * m], 0);
    for (0..n) |k| {
        const s = d.values[k];
        if (s <= tol) continue; // a direction the matrix destroys; A+ sends it to 0
        const inv = 1.0 / s;
        for (0..n) |i| {
            const vik = d.v[i * n + k] * inv;
            if (vik == 0) continue;
            for (0..m) |j| out[i * m + j] += vik * d.u[j * n + k];
        }
    }
    return true;
}

/// The MINIMUM-NORM least-squares solution x = A+b, for an m*n A of any rank.
///
/// Where leastSquares refuses, this answers -- and answers with the one vector that
/// is both a minimiser of ||Ax - b|| and the smallest such vector. Writes n values.
pub fn minimumNormSolve(allocator: std.mem.Allocator, data: []const f64, m: usize, n: usize, b: []const f64, x: []f64) !bool {
    if (m == 0 or n == 0) return false;
    const pinv = try allocator.alloc(f64, n * m);
    defer allocator.free(pinv);
    if (!try pseudoInverse(allocator, data, m, n, pinv)) return false;
    for (0..n) |i| {
        var acc: f64 = 0;
        for (0..m) |j| acc += pinv[i * m + j] * b[j];
        x[i] = acc;
    }
    return true;
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

test "eigen: the defining property, A v = lambda v" {
    // A symmetric matrix with eigenvalues that are not round numbers, so nothing
    // can pass by accident.
    const n = 3;
    const a = [_]f64{
        4, 1, 2,
        1, 5, 3,
        2, 3, 6,
    };
    var e = try eigenSymmetric(testing.allocator, &a, n);
    defer e.deinit();
    try testing.expect(e.symmetric);
    try testing.expect(e.converged);

    // THE DEFINITION. For every eigenpair, A times the vector must equal the value
    // times the vector -- checked componentwise. This is the whole contract, and it
    // needs no reference constants at all.
    for (0..n) |j| {
        for (0..n) |i| {
            var av: f64 = 0;
            for (0..n) |k| av += a[i * n + k] * e.vec(k, j);
            try testing.expectApproxEqAbs(e.values[j] * e.vec(i, j), av, 1e-9);
        }
    }

    // the eigenvectors of a symmetric matrix are ORTHONORMAL
    for (0..n) |j1| {
        for (0..n) |j2| {
            var dot: f64 = 0;
            for (0..n) |i| dot += e.vec(i, j1) * e.vec(i, j2);
            const want: f64 = if (j1 == j2) 1.0 else 0.0;
            try testing.expectApproxEqAbs(want, dot, 1e-9);
        }
    }

    // sorted descending, which is what PCA expects
    try testing.expect(e.values[0] >= e.values[1]);
    try testing.expect(e.values[1] >= e.values[2]);
}

test "eigen: trace and determinant tie it to the rest of linalg" {
    // Two invariants that connect the eigenvalues to quantities computed by
    // completely different code: the trace is their SUM, and the determinant --
    // which comes from LU -- is their PRODUCT.
    const n = 4;
    const a = [_]f64{
        6,  -2, 1,  0,
        -2, 7,  3,  1,
        1,  3,  9,  -4,
        0,  1,  -4, 5,
    };
    var e = try eigenSymmetric(testing.allocator, &a, n);
    defer e.deinit();

    var trace: f64 = 0;
    for (0..n) |i| trace += a[i * n + i];
    var sum: f64 = 0;
    for (e.values) |v| sum += v;
    try testing.expectApproxEqRel(trace, sum, 1e-12);

    var prod: f64 = 1;
    for (e.values) |v| prod *= v;
    const det = try determinant(testing.allocator, &a, n);
    try testing.expectApproxEqRel(det, prod, 1e-9);
}

test "eigen: positive-definiteness, answered twice by unrelated algorithms" {
    // A symmetric matrix is positive definite exactly when every eigenvalue is
    // positive. Cholesky answers the same question by whether its factorisation
    // exists. The two share no code, so agreeing is real evidence -- and it
    // independently checks slice 7's IsPositiveDefinite.
    const cases = [_][4]f64{
        .{ 4, 2, 2, 3 }, // positive definite
        .{ 1, 2, 2, 1 }, // indefinite
        .{ -1, 0, 0, -1 }, // negative definite
        .{ 0, 0, 0, 1 }, // semi-definite
        .{ 1, 0, 0, 1 }, // the identity
        .{ 2, -1, -1, 2 }, // positive definite
    };
    for (cases) |c| {
        var e = try eigenSymmetric(testing.allocator, &c, 2);
        defer e.deinit();
        var all_positive = true;
        for (e.values) |v| {
            if (!(v > 1e-12)) all_positive = false;
        }

        var f = try cholesky(testing.allocator, &c, 2);
        defer f.deinit();

        try testing.expectEqual(all_positive, f.positive_definite);
    }
}

test "eigen: a known spectrum, and a repeated eigenvalue" {
    // A diagonal matrix's eigenvalues ARE its diagonal -- the one case where the
    // answer is known by inspection.
    const d = [_]f64{ 3, 0, 0, 0, 7, 0, 0, 0, 1 };
    var ed = try eigenSymmetric(testing.allocator, &d, 3);
    defer ed.deinit();
    try testing.expectApproxEqAbs(@as(f64, 7), ed.values[0], 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 3), ed.values[1], 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 1), ed.values[2], 1e-12);

    // [[2,1],[1,2]] has eigenvalues 3 and 1 exactly
    const t = [_]f64{ 2, 1, 1, 2 };
    var et = try eigenSymmetric(testing.allocator, &t, 2);
    defer et.deinit();
    try testing.expectApproxEqAbs(@as(f64, 3), et.values[0], 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 1), et.values[1], 1e-12);

    // A REPEATED eigenvalue, which is where a naive rotation formula divides by
    // zero: 2*I has eigenvalue 2 twice, and the vectors must still come out
    // orthonormal.
    const r = [_]f64{ 2, 0, 0, 2 };
    var er = try eigenSymmetric(testing.allocator, &r, 2);
    defer er.deinit();
    try testing.expectApproxEqAbs(@as(f64, 2), er.values[0], 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 2), er.values[1], 1e-12);
    var dot: f64 = 0;
    for (0..2) |i| dot += er.vec(i, 0) * er.vec(i, 1);
    try testing.expectApproxEqAbs(@as(f64, 0), dot, 1e-12);
}

test "eigen: a NON-symmetric matrix is reported, not silently symmetrised" {
    // [[1,2],[3,4]] has real but distinct eigenvalues; a general matrix can have
    // complex ones. Either way Jacobi does not apply, and returning the spectrum of
    // (A + A')/2 while calling it the spectrum of A would be a wrong answer wearing
    // a right answer's face.
    const ns = [_]f64{ 1, 2, 3, 4 };
    var e = try eigenSymmetric(testing.allocator, &ns, 2);
    defer e.deinit();
    try testing.expect(!e.symmetric);
    try testing.expect(!e.converged);

    try testing.expect(std.math.isNan(try conditionNumberSymmetric(testing.allocator, &ns, 2)));
    try testing.expectEqual(@as(usize, 0), try rankSymmetric(testing.allocator, &ns, 2));

    // ...but a matrix that is symmetric only to rounding IS accepted, because
    // insisting on the last bit would reject data from any real computation
    const almost = [_]f64{ 1, 2, 2 + 1e-16, 4 };
    try testing.expect(isSymmetric(&almost, 2));
    const notquite = [_]f64{ 1, 2, 2.001, 4 };
    try testing.expect(!isSymmetric(&notquite, 2));
}

test "eigen: condition number and rank" {
    // The identity is perfectly conditioned: every eigenvalue is 1.
    const id = [_]f64{ 1, 0, 0, 0, 1, 0, 0, 0, 1 };
    try testing.expectApproxEqAbs(@as(f64, 1), try conditionNumberSymmetric(testing.allocator, &id, 3), 1e-12);
    try testing.expectEqual(@as(usize, 3), try rankSymmetric(testing.allocator, &id, 3));

    // A diagonal matrix's condition number is its largest over its smallest.
    const d = [_]f64{ 1000, 0, 0, 0, 10, 0, 0, 0, 1 };
    try testing.expectApproxEqRel(@as(f64, 1000), try conditionNumberSymmetric(testing.allocator, &d, 3), 1e-10);

    // A singular matrix is infinitely ill-conditioned, and that is the honest
    // answer rather than a large finite number.
    const sing = [_]f64{ 1, 1, 1, 1 };
    try testing.expect(std.math.isInf(try conditionNumberSymmetric(testing.allocator, &sing, 2)));
    try testing.expectEqual(@as(usize, 1), try rankSymmetric(testing.allocator, &sing, 2));

    // rank is RELATIVE: a matrix of uniformly tiny entries is still full rank
    const tiny = [_]f64{ 1e-200, 0, 0, 1e-200 };
    try testing.expectEqual(@as(usize, 2), try rankSymmetric(testing.allocator, &tiny, 2));

    // the zero matrix has rank zero
    const zero = [_]f64{ 0, 0, 0, 0 };
    try testing.expectEqual(@as(usize, 0), try rankSymmetric(testing.allocator, &zero, 2));
}

test "svd: U * S * V' reconstructs A -- the whole contract" {
    const m = 5;
    const n = 3;
    const a = [_]f64{
        1,  2,  3,
        4,  5,  6,
        7,  8,  10,
        2,  -1, 4,
        -3, 6,  1,
    };
    var d = try svd(testing.allocator, &a, m, n);
    defer d.deinit();
    try testing.expect(d.converged);

    // A[i][j] must equal sum_k U[i][k] * s[k] * V[j][k]
    for (0..m) |i| {
        for (0..n) |j| {
            var acc: f64 = 0;
            for (0..n) |k| acc += d.u[i * n + k] * d.values[k] * d.v[j * n + k];
            try testing.expectApproxEqAbs(a[i * n + j], acc, 1e-9);
        }
    }

    // singular values are non-negative and sorted descending
    for (d.values) |s| try testing.expect(s >= 0);
    try testing.expect(d.values[0] >= d.values[1]);
    try testing.expect(d.values[1] >= d.values[2]);

    // U's columns are orthonormal, and so are V's
    for (0..n) |j1| {
        for (0..n) |j2| {
            var du: f64 = 0;
            var dv: f64 = 0;
            for (0..m) |i| du += d.u[i * n + j1] * d.u[i * n + j2];
            for (0..n) |i| dv += d.v[i * n + j1] * d.v[i * n + j2];
            const want: f64 = if (j1 == j2) 1.0 else 0.0;
            try testing.expectApproxEqAbs(want, du, 1e-9);
            try testing.expectApproxEqAbs(want, dv, 1e-9);
        }
    }
}

test "svd: the singular values of A are the square roots of the eigenvalues of A'A" {
    // THE IDENTITY THAT TIES THIS SLICE TO SLICE 8. Two entirely different
    // algorithms -- one-sided Jacobi on A's columns, and two-sided Jacobi on the
    // symmetric matrix A'A -- must produce the same numbers.
    const m = 4;
    const n = 3;
    const a = [_]f64{
        2, 1,  0,
        1, 3,  1,
        0, 1,  4,
        1, -1, 2,
    };
    var d = try svd(testing.allocator, &a, m, n);
    defer d.deinit();

    // form A'A (n*n, symmetric by construction)
    var ata: [9]f64 = undefined;
    for (0..n) |i| {
        for (0..n) |j| {
            var acc: f64 = 0;
            for (0..m) |k| acc += a[k * n + i] * a[k * n + j];
            ata[i * n + j] = acc;
        }
    }
    var e = try eigenSymmetric(testing.allocator, &ata, n);
    defer e.deinit();

    for (0..n) |k| {
        try testing.expectApproxEqRel(@sqrt(@max(0.0, e.values[k])), d.values[k], 1e-8);
    }

    // ...and therefore the condition numbers agree too, one computed from singular
    // values and one from eigenvalues of a different matrix
    const cond_svd = try conditionNumberOf(testing.allocator, &a, m, n);
    const cond_eig = try conditionNumberSymmetric(testing.allocator, &ata, n);
    try testing.expectApproxEqRel(cond_eig, cond_svd * cond_svd, 1e-7);
    // squared, because A'A squares every singular value -- which is exactly why
    // slice 7 refused to solve least squares through the normal equations
}

test "svd: rank of a RECTANGULAR matrix, which nothing else could answer" {
    // Full rank: three independent columns in a 5x3
    const full = [_]f64{ 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 0, 0, 1, 1 };
    try testing.expectEqual(@as(usize, 3), try rankOf(testing.allocator, &full, 5, 3));

    // Column 3 is column 1 + column 2, so the rank is 2 -- and this is exactly the
    // collinearity that makes a least-squares fit non-unique. Slice 7 refuses such a
    // system; now the caller can find out WHY before asking.
    const dep = [_]f64{
        1, 0, 1,
        0, 1, 1,
        1, 1, 2,
        2, 0, 2,
        0, 3, 3,
    };
    try testing.expectEqual(@as(usize, 2), try rankOf(testing.allocator, &dep, 5, 3));
    try testing.expect(std.math.isInf(try conditionNumberOf(testing.allocator, &dep, 5, 3)));

    // ...and QR agrees that it has no unique least-squares solution
    var x: [3]f64 = undefined;
    const b = [_]f64{ 1, 2, 3, 4, 5 };
    try testing.expect(!try leastSquares(testing.allocator, &dep, 5, 3, &b, &x));

    // a single column is rank 1, and a zero matrix rank 0
    const one = [_]f64{ 3, 4, 0, 12 };
    try testing.expectEqual(@as(usize, 1), try rankOf(testing.allocator, &one, 4, 1));
    const zero = [_]f64{ 0, 0, 0, 0, 0, 0 };
    try testing.expectEqual(@as(usize, 0), try rankOf(testing.allocator, &zero, 3, 2));
}

test "svd: known singular values, and rank is scale-invariant" {
    // A diagonal matrix's singular values are the absolute values of its diagonal.
    const diag = [_]f64{ 3, 0, 0, 0, -7, 0, 0, 0, 1 };
    var d = try svd(testing.allocator, &diag, 3, 3);
    defer d.deinit();
    try testing.expectApproxEqAbs(@as(f64, 7), d.values[0], 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 3), d.values[1], 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 1), d.values[2], 1e-12);
    // note the -7 became +7: a singular value is never negative
    try testing.expectApproxEqRel(@as(f64, 7), try conditionNumberOf(testing.allocator, &diag, 3, 3), 1e-10);

    // the identity is perfectly conditioned
    const id = [_]f64{ 1, 0, 0, 0, 1, 0, 0, 0, 1 };
    try testing.expectApproxEqAbs(@as(f64, 1), try conditionNumberOf(testing.allocator, &id, 3, 3), 1e-12);

    // SCALE INVARIANCE: multiplying a matrix by 1e-8 divides every singular value by
    // 1e-8, so neither the rank nor the condition number may change. An absolute
    // threshold would get both wrong.
    var tiny: [9]f64 = undefined;
    for (&tiny, diag) |*t, x| t.* = x * 1e-8;
    try testing.expectEqual(@as(usize, 3), try rankOf(testing.allocator, &tiny, 3, 3));
    try testing.expectApproxEqRel(@as(f64, 7), try conditionNumberOf(testing.allocator, &tiny, 3, 3), 1e-10);
}

test "svd: wide matrices are ANSWERED now, and degenerate ones still refused" {
    // UPDATED IN PHASE 7. This used to assert that a wide matrix returned rank 0 and
    // a NaN condition number -- "transpose it, the singular values are identical".
    // True for the VALUES, and never defensible for the QUESTIONS: rank(A) = rank(A')
    // and cond(A) = cond(A') always, so refusing one orientation was an artefact of
    // the SVD's precondition, not a fact about the matrix. svdAnyShape does the
    // transpose internally, so both are answered.
    const a = [_]f64{ 1, 2, 3, 4, 5, 6 };
    const at = [_]f64{ 1, 4, 2, 5, 3, 6 };

    const r_wide = try rankOf(testing.allocator, &a, 2, 3);
    const r_tall = try rankOf(testing.allocator, &at, 3, 2);
    try testing.expectEqual(@as(usize, 2), r_wide);
    try testing.expectEqual(r_tall, r_wide);

    const c_wide = try conditionNumberOf(testing.allocator, &a, 2, 3);
    const c_tall = try conditionNumberOf(testing.allocator, &at, 3, 2);
    try testing.expect(!std.math.isNan(c_wide));
    try testing.expectApproxEqRel(c_tall, c_wide, 1e-10);

    // an EMPTY dimension is still refused -- there is no matrix there to ask about
    try testing.expectEqual(@as(usize, 0), try rankOf(testing.allocator, &a, 3, 0));
    try testing.expect(std.math.isNan(try conditionNumberOf(testing.allocator, &a, 0, 3)));
}

test "rank and the condition number cannot disagree about singularity" {
    // The defect this pins. A rank test and a condition number ask the same question
    // -- "is the smallest value negligible?" -- so a matrix called rank deficient
    // must have an INFINITE condition number, and a full-rank one a finite one.
    // Before negligibleThreshold existed they used separate rules, and for values
    // left at rounding level rather than exactly zero they contradicted each other:
    // rank 2 with a condition number of 8.97e16.

    // --- rectangular, via SVD ---
    const rect_cases = [_]struct { m: usize, n: usize, d: []const f64 }{
        // rank 2 of 3: column 3 = column 1 + column 2
        .{ .m = 5, .n = 3, .d = &[_]f64{ 1, 0, 1, 0, 1, 1, 1, 1, 2, 2, 0, 2, 0, 3, 3 } },
        // full rank
        .{ .m = 5, .n = 3, .d = &[_]f64{ 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 0, 0, 1, 1 } },
        // rank 1 of 2: identical columns
        .{ .m = 3, .n = 2, .d = &[_]f64{ 1, 1, 2, 2, 3, 3 } },
        // full rank, tiny scale -- must behave exactly like the unscaled version
        .{ .m = 3, .n = 2, .d = &[_]f64{ 1e-9, 0, 0, 1e-9, 0, 0 } },
    };
    for (rect_cases) |c| {
        const r = try rankOf(testing.allocator, c.d, c.m, c.n);
        const k = try conditionNumberOf(testing.allocator, c.d, c.m, c.n);
        const deficient = r < c.n;
        try testing.expectEqual(deficient, std.math.isInf(k));
    }

    // --- square symmetric, via eigen: the same invariant, and the case that had the
    // bug latent. Its zero eigenvalue comes out at 1.15e-15, not 0.
    const sym_cases = [_][9]f64{
        .{ 2, 1, 3, 1, 5, 6, 3, 6, 9 }, // row 3 = row 1 + row 2 -> singular
        .{ 1, 1, 1, 1, 1, 1, 1, 1, 1 }, // rank 1
        .{ 4, 1, 0, 1, 5, 2, 0, 2, 6 }, // full rank
        .{ 1, 0, 0, 0, 1, 0, 0, 0, 1 }, // the identity
    };
    for (sym_cases) |c| {
        const r = try rankSymmetric(testing.allocator, &c, 3);
        const k = try conditionNumberSymmetric(testing.allocator, &c, 3);
        try testing.expectEqual(r < 3, std.math.isInf(k));
    }

    // and the specific numbers from the finding, so the regression is unmistakable
    const dep = [_]f64{ 2, 1, 3, 1, 5, 6, 3, 6, 9 };
    try testing.expectEqual(@as(usize, 2), try rankSymmetric(testing.allocator, &dep, 3));
    try testing.expect(std.math.isInf(try conditionNumberSymmetric(testing.allocator, &dep, 3)));
}

test "QR rank deficiency at SCALE -- the case an exact == 0 test missed" {
    // The defect slice 9 found in slice 7. A 3x2 with a duplicated column leaves
    // rdiag exactly zero, so the old `d == 0` test caught it and slice 7's test
    // passed. A 200x4 design matrix with a redundant predictor does NOT: rounding
    // leaves the diagonal near zero but not at it, so isFullRank answered TRUE, and
    // qrSolve back-substituted through a near-zero pivot and returned coefficients
    // around -9.7e12 -- garbage, presented as a fit.
    const m = 200;
    const n = 4;
    var a: [m * n]f64 = undefined;
    var b: [m]f64 = undefined;
    for (0..m) |i| {
        const fi: f64 = @floatFromInt(i + 1);
        const u = @mod(fi, 13.0) + 1.0;
        const v = @mod(fi, 7.0) + 1.0;
        a[i * n + 0] = 1;
        a[i * n + 1] = u;
        a[i * n + 2] = v;
        a[i * n + 3] = u + v; // REDUNDANT: column 4 = column 2 + column 3
        b[i] = 10 - 3 * u + 0.5 * v;
    }

    // the SVD says rank 3 of 4 columns
    try testing.expectEqual(@as(usize, 3), try rankOf(testing.allocator, &a, m, n));
    try testing.expect(std.math.isInf(try conditionNumberOf(testing.allocator, &a, m, n)));

    // ...and QR must agree, rather than producing an answer
    var f = try qr(testing.allocator, &a, m, n);
    defer f.deinit();
    try testing.expect(!f.isFullRank());

    var x: [n]f64 = undefined;
    try testing.expect(!try leastSquares(testing.allocator, &a, m, n, &b, &x));

    // and the same design WITHOUT the redundant column is still answered
    const n3 = 3;
    var a3: [m * n3]f64 = undefined;
    for (0..m) |i| {
        a3[i * n3 + 0] = a[i * n + 0];
        a3[i * n3 + 1] = a[i * n + 1];
        a3[i * n3 + 2] = a[i * n + 2];
    }
    try testing.expectEqual(@as(usize, 3), try rankOf(testing.allocator, &a3, m, n3));
    var x3: [n3]f64 = undefined;
    try testing.expect(try leastSquares(testing.allocator, &a3, m, n3, &b, &x3));
    try testing.expectApproxEqAbs(@as(f64, 10), x3[0], 1e-8);
    try testing.expectApproxEqAbs(@as(f64, -3), x3[1], 1e-8);
    try testing.expectApproxEqAbs(@as(f64, 0.5), x3[2], 1e-8);
}

// Multiply P (p*q) by Q (q*r) into R (p*r) -- a test helper, so the checks below
// read as mathematics rather than index arithmetic.
fn tmul(p: []const f64, q: []const f64, r: []f64, pr: usize, pc: usize, qc: usize) void {
    @memset(r[0 .. pr * qc], 0);
    for (0..pr) |i| {
        for (0..pc) |k| {
            const v = p[i * pc + k];
            if (v == 0) continue;
            for (0..qc) |j| r[i * qc + j] += v * q[k * qc + j];
        }
    }
}

test "pseudo-inverse: the FOUR PENROSE CONDITIONS, which define it uniquely" {
    // No reference numbers anywhere in this test. A+ is DEFINED as the unique matrix
    // satisfying these four, so checking them checks everything -- and unlike a
    // transcribed constant, they cannot be mistyped into agreement.
    const cases = [_]struct { m: usize, n: usize, d: []const f64 }{
        // tall, full rank
        .{ .m = 4, .n = 2, .d = &[_]f64{ 1, 1, 1, 2, 1, 3, 1, 4 } },
        // tall, RANK DEFICIENT (column 3 = column 1 + column 2)
        .{ .m = 5, .n = 3, .d = &[_]f64{ 1, 0, 1, 0, 1, 1, 1, 1, 2, 2, 0, 2, 0, 3, 3 } },
        // square, invertible
        .{ .m = 3, .n = 3, .d = &[_]f64{ 4, -2, 1, 3, 6, -4, 2, 1, 8 } },
        // square, singular
        .{ .m = 3, .n = 3, .d = &[_]f64{ 1, 2, 3, 2, 4, 6, 1, 1, 1 } },
        // WIDE -- handled by transposing internally
        .{ .m = 2, .n = 4, .d = &[_]f64{ 1, 2, 3, 4, 5, 6, 7, 8 } },
        // a single column, and a single row
        .{ .m = 3, .n = 1, .d = &[_]f64{ 3, 4, 0 } },
        .{ .m = 1, .n = 3, .d = &[_]f64{ 3, 4, 0 } },
        // the zero matrix, whose pseudo-inverse is the zero matrix
        .{ .m = 2, .n = 2, .d = &[_]f64{ 0, 0, 0, 0 } },
    };

    for (cases) |c| {
        const m = c.m;
        const n = c.n;
        const a = c.d;
        const alloc = testing.allocator;

        const p = try alloc.alloc(f64, n * m); // A+ is n*m
        defer alloc.free(p);
        try testing.expect(try pseudoInverse(alloc, a, m, n, p));

        const ap = try alloc.alloc(f64, m * m); // A A+   (m*m)
        defer alloc.free(ap);
        const pa = try alloc.alloc(f64, n * n); // A+ A   (n*n)
        defer alloc.free(pa);
        tmul(a, p, ap, m, n, m);
        tmul(p, a, pa, n, m, n);

        // (1) A A+ A = A
        const apa = try alloc.alloc(f64, m * n);
        defer alloc.free(apa);
        tmul(ap, a, apa, m, m, n);
        for (0..m * n) |i| try testing.expectApproxEqAbs(a[i], apa[i], 1e-8);

        // (2) A+ A A+ = A+
        const pap = try alloc.alloc(f64, n * m);
        defer alloc.free(pap);
        tmul(pa, p, pap, n, n, m);
        for (0..n * m) |i| try testing.expectApproxEqAbs(p[i], pap[i], 1e-8);

        // (3) A A+ is symmetric
        for (0..m) |i| {
            for (i + 1..m) |j| try testing.expectApproxEqAbs(ap[i * m + j], ap[j * m + i], 1e-9);
        }
        // (4) A+ A is symmetric
        for (0..n) |i| {
            for (i + 1..n) |j| try testing.expectApproxEqAbs(pa[i * n + j], pa[j * n + i], 1e-9);
        }
    }
}

test "pseudo-inverse: it GENERALISES the inverse and the least-squares solution" {
    const alloc = testing.allocator;

    // (a) for an invertible square matrix, A+ IS the inverse -- checked against the
    // LU-based inverse, which shares no code with the SVD
    {
        const n = 3;
        const a = [_]f64{ 4, -2, 1, 3, 6, -4, 2, 1, 8 };
        var p: [9]f64 = undefined;
        try testing.expect(try pseudoInverse(alloc, &a, n, n, &p));

        // A * A+ must be the identity
        var prod: [9]f64 = undefined;
        tmul(&a, &p, &prod, n, n, n);
        for (0..n) |i| {
            for (0..n) |j| {
                const want: f64 = if (i == j) 1.0 else 0.0;
                try testing.expectApproxEqAbs(want, prod[i * n + j], 1e-9);
            }
        }
    }

    // (b) for a tall full-rank matrix, A+b IS the least-squares solution -- checked
    // against slice 7's QR route, again sharing no code
    {
        const m = 5;
        const n = 2;
        const a = [_]f64{ 1, 1, 1, 2, 1, 3, 1, 4, 1, 5 };
        const b = [_]f64{ 2.1, 3.9, 6.2, 7.8, 10.1 };
        var x_qr: [n]f64 = undefined;
        var x_pinv: [n]f64 = undefined;
        try testing.expect(try leastSquares(alloc, &a, m, n, &b, &x_qr));
        try testing.expect(try minimumNormSolve(alloc, &a, m, n, &b, &x_pinv));
        for (0..n) |i| try testing.expectApproxEqAbs(x_qr[i], x_pinv[i], 1e-8);
    }
}

test "pseudo-inverse: it ANSWERS where least squares refuses, with the minimum-norm one" {
    // THE CASE THIS EXISTS FOR. Slice 7 declines a rank-deficient system because
    // infinitely many vectors share the minimum residual. A+b picks the one that is
    // ALSO smallest in norm -- a principled choice, not an arbitrary one.
    const alloc = testing.allocator;
    const m = 5;
    const n = 3;
    const a = [_]f64{ 1, 0, 1, 0, 1, 1, 1, 1, 2, 2, 0, 2, 0, 3, 3 }; // col3 = col1+col2
    const b = [_]f64{ 1, 2, 3, 4, 5 };

    // least squares refuses...
    var x_ls: [n]f64 = undefined;
    try testing.expect(!try leastSquares(alloc, &a, m, n, &b, &x_ls));

    // ...and the pseudo-inverse answers
    var x: [n]f64 = undefined;
    try testing.expect(try minimumNormSolve(alloc, &a, m, n, &b, &x));

    // it IS a least-squares solution: the residual is orthogonal to every column
    var resid: [m]f64 = undefined;
    for (0..m) |i| {
        var acc: f64 = 0;
        for (0..n) |j| acc += a[i * n + j] * x[j];
        resid[i] = acc - b[i];
    }
    for (0..n) |j| {
        var dot: f64 = 0;
        for (0..m) |i| dot += a[i * n + j] * resid[i];
        try testing.expectApproxEqAbs(@as(f64, 0), dot, 1e-8);
    }

    // and it is the SMALLEST such solution. The null-space direction here is
    // (1, 1, -1): adding any multiple of it leaves the residual untouched but must
    // make the vector longer.
    var norm0: f64 = 0;
    for (x) |v| norm0 += v * v;
    inline for (.{ 0.5, -0.5, 2.0, -2.0, 0.01, -0.01 }) |t| {
        const cand = [_]f64{ x[0] + t, x[1] + t, x[2] - t };
        var norm1: f64 = 0;
        for (cand) |v| norm1 += v * v;
        try testing.expect(norm1 > norm0);

        // ...and it really is still a minimiser, so the comparison is fair
        var ss: f64 = 0;
        for (0..m) |i| {
            var acc: f64 = 0;
            for (0..n) |j| acc += a[i * n + j] * cand[j];
            const r = acc - b[i];
            ss += r * r;
        }
        var ss0: f64 = 0;
        for (resid) |r| ss0 += r * r;
        try testing.expectApproxEqAbs(ss0, ss, 1e-7);
    }
}

test "pseudo-inverse: a WIDE system gets the minimum-norm EXACT solution" {
    // 2 equations, 3 unknowns: infinitely many EXACT solutions. leastSquares refuses
    // this shape outright; A+b returns the shortest of them.
    const alloc = testing.allocator;
    const m = 2;
    const n = 3;
    const a = [_]f64{ 1, 1, 1, 1, -1, 0 };
    const b = [_]f64{ 6, 2 };

    var x: [n]f64 = undefined;
    try testing.expect(try minimumNormSolve(alloc, &a, m, n, &b, &x));

    // it solves the system EXACTLY -- no residual at all
    for (0..m) |i| {
        var acc: f64 = 0;
        for (0..n) |j| acc += a[i * n + j] * x[j];
        try testing.expectApproxEqAbs(b[i], acc, 1e-9);
    }

    // and it is the shortest exact solution. The null space is spanned by
    // (1, 1, -2), so moving along it keeps the equations satisfied and must lengthen
    // the vector.
    var norm0: f64 = 0;
    for (x) |v| norm0 += v * v;
    inline for (.{ 0.3, -0.3, 1.0, -1.0 }) |t| {
        const cand = [_]f64{ x[0] + t, x[1] + t, x[2] - 2.0 * t };
        for (0..m) |i| {
            var acc: f64 = 0;
            for (0..n) |j| acc += a[i * n + j] * cand[j];
            try testing.expectApproxEqAbs(b[i], acc, 1e-9);
        }
        var norm1: f64 = 0;
        for (cand) |v| norm1 += v * v;
        try testing.expect(norm1 > norm0);
    }

    // leastSquares still refuses the shape, which is correct -- it is a different
    // question, and now there is a function that answers this one
    var xl: [n]f64 = undefined;
    try testing.expect(!try leastSquares(alloc, &a, m, n, &b, &xl));
}

// ─── SVD of any shape (phase 7) ──────────────────────────────────────────────

/// max |A - U S V'| over all entries, relative to |A|. THE defining property: it
/// validates the singular values, both factor matrices and the shape handling
/// together, on matrices nobody has tabulated.
fn svdResidual(d: *const Svd, orig: []const f64, m: usize, n: usize) f64 {
    const k = @min(m, n);
    var anorm: f64 = 0;
    for (orig) |x| anorm += @abs(x);
    if (anorm == 0) anorm = 1;

    var worst: f64 = 0;
    for (0..m) |i| {
        for (0..n) |j| {
            var acc: f64 = 0;
            for (0..k) |t| acc += d.u[i * k + t] * d.values[t] * d.v[j * k + t];
            const e = @abs(acc - orig[i * n + j]);
            if (e > worst) worst = e;
        }
    }
    return worst / anorm;
}

test "SVD reconstructs a TALL matrix" {
    const alloc = testing.allocator;
    const a = [_]f64{ 1, 2, 3, 4, 5, 6 }; // 3x2
    var d = try svdAnyShape(alloc, &a, 3, 2);
    defer d.deinit();
    try testing.expect(svdResidual(&d, &a, 3, 2) < 1e-12);
}

test "SVD reconstructs a WIDE matrix -- the case that was refused" {
    const alloc = testing.allocator;
    const a = [_]f64{ 1, 2, 3, 4, 5, 6 }; // 2x3
    var d = try svdAnyShape(alloc, &a, 2, 3);
    defer d.deinit();
    try testing.expect(svdResidual(&d, &a, 2, 3) < 1e-12);
}

test "SVD reconstructs a square matrix, symmetric or not" {
    const alloc = testing.allocator;
    const a = [_]f64{ 4, 1, 0, 1, 3, 1, 0, 1, 2 };
    var d1 = try svdAnyShape(alloc, &a, 3, 3);
    defer d1.deinit();
    try testing.expect(svdResidual(&d1, &a, 3, 3) < 1e-12);

    const b = [_]f64{ 1, -2, 3, 4, 5, -6, 7, 8, 9 };
    var d2 = try svdAnyShape(alloc, &b, 3, 3);
    defer d2.deinit();
    try testing.expect(svdResidual(&d2, &b, 3, 3) < 1e-12);
}

test "the singular values are non-negative and descending, whatever the shape" {
    const alloc = testing.allocator;
    const cases = [_]struct { d: []const f64, m: usize, n: usize }{
        .{ .d = &.{ 1, 2, 3, 4, 5, 6 }, .m = 2, .n = 3 },
        .{ .d = &.{ 1, 2, 3, 4, 5, 6 }, .m = 3, .n = 2 },
        .{ .d = &.{ 3, 0, 0, 0, 2, 0, 0, 0, 1 }, .m = 3, .n = 3 },
        .{ .d = &.{ 1, 1, 1, 1 }, .m = 2, .n = 2 }, // rank 1
        .{ .d = &.{ 5, 4, 3, 2, 1, 0, 9, 8, 7, 6, 5, 4 }, .m = 3, .n = 4 },
    };
    for (cases) |c| {
        var d = try svdAnyShape(alloc, c.d, c.m, c.n);
        defer d.deinit();
        const k = @min(c.m, c.n);
        try testing.expect(svdResidual(&d, c.d, c.m, c.n) < 1e-11);
        for (0..k) |t| try testing.expect(d.values[t] >= 0);
        for (1..k) |t| try testing.expect(d.values[t] <= d.values[t - 1] + 1e-12);
    }
}

test "the factors have orthonormal columns" {
    const alloc = testing.allocator;
    const a = [_]f64{ 1, 2, 3, 4, 5, 6, 7, 8, 10 };
    var d = try svdAnyShape(alloc, &a, 3, 3);
    defer d.deinit();
    // U'U = I and V'V = I
    for (0..3) |p| {
        for (0..3) |q| {
            var du: f64 = 0;
            var dv: f64 = 0;
            for (0..3) |i| {
                du += d.u[i * 3 + p] * d.u[i * 3 + q];
                dv += d.v[i * 3 + p] * d.v[i * 3 + q];
            }
            const want: f64 = if (p == q) 1 else 0;
            try testing.expectApproxEqAbs(want, du, 1e-10);
            try testing.expectApproxEqAbs(want, dv, 1e-10);
        }
    }
}

test "a wide matrix and its transpose share singular values" {
    const alloc = testing.allocator;
    const a = [_]f64{ 1, 2, 3, 4, 5, 6 }; // 2x3
    const at = [_]f64{ 1, 4, 2, 5, 3, 6 }; // 3x2
    var d1 = try svdAnyShape(alloc, &a, 2, 3);
    defer d1.deinit();
    var d2 = try svdAnyShape(alloc, &at, 3, 2);
    defer d2.deinit();
    for (0..2) |t| try testing.expectApproxEqAbs(d1.values[t], d2.values[t], 1e-11);
}

test "a rank-deficient wide matrix has a zero singular value" {
    const alloc = testing.allocator;
    // second row is twice the first: rank 1
    const a = [_]f64{ 1, 2, 3, 2, 4, 6 };
    var d = try svdAnyShape(alloc, &a, 2, 3);
    defer d.deinit();
    try testing.expect(svdResidual(&d, &a, 2, 3) < 1e-12);
    try testing.expect(d.values[1] < 1e-12 * d.values[0] + 1e-12);
}
