const std = @import("std");
const linalg = @import("linalg.zig");
const eigen_general = @import("eigen_general.zig");

pub const StzMatrix = struct {
    data: []f64,
    rows: usize,
    cols: usize,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, rows: usize, cols: usize) !*StzMatrix {
        const m = try allocator.create(StzMatrix);
        m.* = .{
            .data = try allocator.alloc(f64, rows * cols),
            .rows = rows,
            .cols = cols,
            .allocator = allocator,
        };
        @memset(m.data, 0.0);
        return m;
    }

    pub fn deinit(self: *StzMatrix) void {
        self.allocator.free(self.data);
        self.allocator.destroy(self);
    }

    pub inline fn at(self: *const StzMatrix, r: usize, c: usize) f64 {
        return self.data[r * self.cols + c];
    }

    pub inline fn setAt(self: *StzMatrix, r: usize, c: usize, val: f64) void {
        self.data[r * self.cols + c] = val;
    }
};

const gpa = std.heap.page_allocator;

pub fn stz_matrix_new(rows: i32, cols: i32) callconv(.c) ?*StzMatrix {
    if (rows <= 0 or cols <= 0) return null;
    return StzMatrix.init(gpa, @intCast(rows), @intCast(cols)) catch null;
}

pub fn stz_matrix_free(m: ?*StzMatrix) callconv(.c) void {
    if (m) |mat| mat.deinit();
}

pub fn stz_matrix_rows(m: ?*const StzMatrix) callconv(.c) i32 {
    return if (m) |mat| @intCast(mat.rows) else 0;
}

pub fn stz_matrix_cols(m: ?*const StzMatrix) callconv(.c) i32 {
    return if (m) |mat| @intCast(mat.cols) else 0;
}

pub fn stz_matrix_set(m: ?*StzMatrix, row: i32, col: i32, val: f64) callconv(.c) void {
    const mat = m orelse return;
    const r: usize = @intCast(row);
    const c: usize = @intCast(col);
    if (r >= mat.rows or c >= mat.cols) return;
    mat.setAt(r, c, val);
}

pub fn stz_matrix_get(m: ?*const StzMatrix, row: i32, col: i32) callconv(.c) f64 {
    const mat = m orelse return 0.0;
    const r: usize = @intCast(row);
    const c: usize = @intCast(col);
    if (r >= mat.rows or c >= mat.cols) return 0.0;
    return mat.at(r, c);
}

pub fn stz_matrix_sum(m: ?*const StzMatrix) callconv(.c) f64 {
    const mat = m orelse return 0.0;
    var total: f64 = 0.0;
    for (mat.data) |v| total += v;
    return total;
}

pub fn stz_matrix_min(m: ?*const StzMatrix) callconv(.c) f64 {
    const mat = m orelse return 0.0;
    if (mat.data.len == 0) return 0.0;
    var result = mat.data[0];
    for (mat.data[1..]) |v| {
        if (v < result) result = v;
    }
    return result;
}

pub fn stz_matrix_max(m: ?*const StzMatrix) callconv(.c) f64 {
    const mat = m orelse return 0.0;
    if (mat.data.len == 0) return 0.0;
    var result = mat.data[0];
    for (mat.data[1..]) |v| {
        if (v > result) result = v;
    }
    return result;
}

pub fn stz_matrix_mean(m: ?*const StzMatrix) callconv(.c) f64 {
    const mat = m orelse return 0.0;
    const n = mat.rows * mat.cols;
    if (n == 0) return 0.0;
    return stz_matrix_sum(m) / @as(f64, @floatFromInt(n));
}

pub fn stz_matrix_add_scalar(m: ?*StzMatrix, val: f64) callconv(.c) void {
    const mat = m orelse return;
    for (mat.data) |*v| v.* += val;
}

pub fn stz_matrix_multiply_scalar(m: ?*StzMatrix, val: f64) callconv(.c) void {
    const mat = m orelse return;
    for (mat.data) |*v| v.* *= val;
}

// Apply +val (op=0) or *val (op=1) to every cell in the rectangular region
// rows r1..r2 x cols c1..c2 (1-based, inclusive). Coords are clamped to the
// matrix bounds. Covers add/mul on a single row/col, a row/col range, or the
// whole matrix -- the operation the Ring stzMatrix used to delegate to the
// (now-removed) RingFastPro updateList().
pub fn stz_matrix_update_region(m: ?*StzMatrix, op: i32, r1: i32, r2: i32, c1: i32, c2: i32, val: f64) callconv(.c) void {
    const mat = m orelse return;
    const nrows: i32 = @intCast(mat.rows);
    const ncols: i32 = @intCast(mat.cols);
    var rr1 = if (r1 < 1) 1 else r1;
    const cc1 = if (c1 < 1) 1 else c1;
    const rr2 = if (r2 > nrows) nrows else r2;
    const cc2 = if (c2 > ncols) ncols else c2;
    while (rr1 <= rr2) : (rr1 += 1) {
        var c = cc1;
        while (c <= cc2) : (c += 1) {
            const idx: usize = @intCast((rr1 - 1) * ncols + (c - 1));
            if (op == 1) {
                mat.data[idx] *= val;
            } else {
                mat.data[idx] += val;
            }
        }
    }
}

pub fn stz_matrix_add_matrix(a: ?*StzMatrix, b: ?*const StzMatrix) callconv(.c) i32 {
    const ma = a orelse return -1;
    const mb = b orelse return -1;
    if (ma.rows != mb.rows or ma.cols != mb.cols) return -2;
    for (ma.data, mb.data) |*va, vb| va.* += vb;
    return 0;
}

/// C = A*B, row-major, SIMD over the output row.
///
/// THE LOOP ORDER IS THE WHOLE OPTIMISATION. The obvious i-j-k form
/// accumulates one output element at a time and reads B down a COLUMN
/// (`b[k*N + j]` with k moving), so every one of the K reads lands in a
/// different cache line -- at n=512 that is a miss per multiply, and the
/// measured rate was 1.98 GFLOP/s on hardware that should do far better.
///
/// Reordered to i-k-j, the inner loop walks a ROW of B and a ROW of C
/// contiguously, which is both cache-friendly and vectorisable: one
/// scalar from A is broadcast against a run of B.
///
/// THE ARITHMETIC IS UNCHANGED, BIT FOR BIT. Each output element still
/// sums its K products in ascending k; only the place the partial sum
/// lives moves (a register, now a memory cell). Floating-point addition
/// is not associative, so that mattered -- had the order changed, every
/// oracle tolerance in the numeric tier would have had to be re-argued.
/// The guard asserts equality against a scalar reference, not nearness.
///
/// THE SPLIT, MEASURED (512x512, ReleaseSafe -- the mode we ship):
///     i-j-k scalar          343.43 ms    0.78 GFLOP/s
///     i-k-j scalar           21.10 ms   12.72 GFLOP/s   16.28x
///     i-k-j + @Vector        17.77 ms   15.10 GFLOP/s    1.19x on top
/// The reorder is the win; vectorising adds 19%. Both shipped in one
/// commit, which let the headline call it "SIMD matmul" -- it is a CACHE
/// fix with a vector bonus. Two optimisations landed together cannot be
/// attributed without measuring them apart, however obvious the story.
///
/// Width comes from the target, not from the machine I benchmarked on:
/// hardcoding 4 was right for this AVX2 box, idle-half on AVX-512, and
/// double-wide on NEON.
const VEC_WIDTH = std.simd.suggestVectorLength(f64) orelse 4;
const Vec = @Vector(VEC_WIDTH, f64);

pub fn stz_matrix_multiply(a: ?*const StzMatrix, b: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    const ma = a orelse return null;
    const mb = b orelse return null;
    if (ma.cols != mb.rows) return null;
    const result = StzMatrix.init(gpa, ma.rows, mb.cols) catch return null;

    const m = ma.rows;
    const k_dim = ma.cols;
    const n = mb.cols;
    const av = ma.data;
    const bv = mb.data;
    const cv = result.data;
    // init() already zeroed cv, which i-k-j relies on.

    for (0..m) |i| {
        const c_row = cv[i * n .. i * n + n];
        for (0..k_dim) |k| {
            const aik = av[i * k_dim + k];
            // NO `if (aik == 0) continue` here, tempting as it is on
            // sparse-ish data: 0 * inf is NaN, so skipping would change
            // the answer for non-finite inputs and cost the bit-identity
            // property above. Sparsity gets its own path, not a branch
            // that quietly makes the dense one approximate.
            const b_row = bv[k * n .. k * n + n];
            const splat: Vec = @splat(aik);
            var j: usize = 0;
            while (j + VEC_WIDTH <= n) : (j += VEC_WIDTH) {
                const bvec: Vec = b_row[j..][0..VEC_WIDTH].*;
                const cvec: Vec = c_row[j..][0..VEC_WIDTH].*;
                c_row[j..][0..VEC_WIDTH].* = cvec + splat * bvec;
            }
            while (j < n) : (j += 1) c_row[j] += aik * b_row[j];
        }
    }
    return result;
}

pub fn stz_matrix_transpose(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    const mat = m orelse return null;
    const result = StzMatrix.init(gpa, mat.cols, mat.rows) catch return null;
    for (0..mat.rows) |i| {
        for (0..mat.cols) |j| {
            result.setAt(j, i, mat.at(i, j));
        }
    }
    return result;
}

/// O(n^3), via the LU factorisation in linalg.zig.
///
/// This was naive COFACTOR EXPANSION until phase 4 -- O(n!) time, and it allocated
/// a fresh submatrix at every level of the recursion, so O(n!) allocations as well.
/// A 10x10 determinant was 3.6 million recursive calls and a 20x20 was not
/// finishable; a probe written during phase 3 hung the machine on a 60x60 before
/// the cause was understood.
///
/// The striking part is that `stz_matrix_inverse` immediately below has always
/// done Gauss-Jordan with partial pivoting in O(n^3), so the pivoting machinery
/// this needed was sitting a few lines away the whole time.
pub fn stz_matrix_determinant(m: ?*const StzMatrix) callconv(.c) f64 {
    const mat = m orelse return 0.0;
    if (mat.rows != mat.cols) return 0.0;
    return linalg.determinant(gpa, mat.data, mat.rows) catch 0.0;
}

/// Solve Ax = b in one factorisation. NEW in phase 4: the library could invert a
/// matrix but not solve a system, and inverting in order to solve is both slower
/// and less accurate than solving directly.
///
/// Returns a new n*1 matrix, or null if A is singular or the shapes disagree.
pub fn stz_matrix_solve(a: ?*const StzMatrix, b: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    const ma = a orelse return null;
    const mb = b orelse return null;
    if (ma.rows != ma.cols) return null;
    const n = ma.rows;
    if (mb.rows != n or mb.cols != 1) return null;

    const out = StzMatrix.init(gpa, n, 1) catch return null;
    const ok = linalg.solve(gpa, ma.data, n, mb.data, out.data) catch {
        out.deinit();
        return null;
    };
    if (!ok) {
        out.deinit();
        return null;
    }
    return out;
}

/// Least squares: the coefficient vector minimising ||Ax - b|| for an m*n A with
/// m >= n, via Householder QR in linalg.zig.
///
/// NEW in phase 4 slice 7, and it is a capability rather than a speedup: an
/// OVERDETERMINED system -- more equations than unknowns -- had no answer in this
/// library at all. `stats.zig`'s regression is SIMPLE regression, one predictor
/// giving a slope and an intercept; this is multiple regression.
///
/// Returns a new n*1 matrix, or null when A is rank deficient (no unique
/// minimiser), when b's shape disagrees, or when the system is underdetermined.
pub fn stz_matrix_least_squares(a: ?*const StzMatrix, b: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    const ma = a orelse return null;
    const mb = b orelse return null;
    if (mb.cols != 1 or mb.rows != ma.rows) return null;
    if (ma.rows < ma.cols or ma.cols == 0) return null;

    const out = StzMatrix.init(gpa, ma.cols, 1) catch return null;
    const ok = linalg.leastSquares(gpa, ma.data, ma.rows, ma.cols, mb.data, out.data) catch {
        out.deinit();
        return null;
    };
    if (!ok) {
        out.deinit();
        return null;
    }
    return out;
}

/// The Cholesky factor L of a symmetric positive-definite A, as a new n*n matrix
/// with zeros above the diagonal. Returns null when A is not positive definite --
/// which makes this the cheapest positive-definiteness TEST available, since the
/// factorisation exists if and only if the property holds.
pub fn stz_matrix_cholesky(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    const mat = m orelse return null;
    if (mat.rows != mat.cols or mat.rows == 0) return null;
    var f = linalg.cholesky(gpa, mat.data, mat.rows) catch return null;
    defer f.deinit();
    if (!f.positive_definite) return null;
    const out = StzMatrix.init(gpa, mat.rows, mat.rows) catch return null;
    @memcpy(out.data, f.l);
    return out;
}

/// 1 when the matrix is symmetric positive definite, 0 otherwise. Asked of the
/// Cholesky factorisation rather than of eigenvalues, which we do not have yet.
pub fn stz_matrix_is_positive_definite(m: ?*const StzMatrix) callconv(.c) i32 {
    const mat = m orelse return 0;
    if (mat.rows != mat.cols or mat.rows == 0) return 0;
    var f = linalg.cholesky(gpa, mat.data, mat.rows) catch return 0;
    defer f.deinit();
    return if (f.positive_definite) 1 else 0;
}

/// The eigenvalues of a SYMMETRIC matrix, as a new n*1 matrix, sorted descending.
/// Null when the matrix is not square or not symmetric -- a general matrix has
/// complex eigenvalues, and returning the spectrum of its symmetric part while
/// calling it the spectrum of A would be a wrong answer wearing a right one's face.
pub fn stz_matrix_eigenvalues(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    const mat = m orelse return null;
    if (mat.rows != mat.cols or mat.rows == 0) return null;
    var e = linalg.eigenSymmetric(gpa, mat.data, mat.rows) catch return null;
    defer e.deinit();
    if (!e.symmetric) return null;
    const out = StzMatrix.init(gpa, mat.rows, 1) catch return null;
    @memcpy(out.data, e.values);
    return out;
}

/// The eigenvectors of a symmetric matrix as a new n*n matrix; COLUMN j is the unit
/// eigenvector belonging to eigenvalue j. Column order matches the eigenvalues, so
/// column 1 is the first principal component.
pub fn stz_matrix_eigenvectors(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    const mat = m orelse return null;
    if (mat.rows != mat.cols or mat.rows == 0) return null;
    var e = linalg.eigenSymmetric(gpa, mat.data, mat.rows) catch return null;
    defer e.deinit();
    if (!e.symmetric) return null;
    const out = StzMatrix.init(gpa, mat.rows, mat.rows) catch return null;
    @memcpy(out.data, e.vectors);
    return out;
}

/// The 2-norm condition number of a symmetric matrix. Infinity when singular, NaN
/// when the matrix is not symmetric.
pub fn stz_matrix_condition_number(m: ?*const StzMatrix) callconv(.c) f64 {
    const mat = m orelse return std.math.nan(f64);
    if (mat.rows != mat.cols or mat.rows == 0) return std.math.nan(f64);
    return linalg.conditionNumberSymmetric(gpa, mat.data, mat.rows) catch std.math.nan(f64);
}

/// The rank of a symmetric matrix, counted by eigenvalues that are non-negligible
/// RELATIVE to the largest.
pub fn stz_matrix_rank(m: ?*const StzMatrix) callconv(.c) i32 {
    const mat = m orelse return -1;
    if (mat.rows != mat.cols or mat.rows == 0) return -1;
    const r = linalg.rankSymmetric(gpa, mat.data, mat.rows) catch return -1;
    return @intCast(r);
}

/// The singular values of ANY m*n matrix with m >= n, as a new n*1 matrix, sorted
/// descending. Null for a wide matrix -- transpose it, since A and A-transpose have
/// identical singular values.
pub fn stz_matrix_singular_values(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    const mat = m orelse return null;
    if (mat.cols == 0 or mat.rows == 0) return null;
    // ANY SHAPE since phase 7: min(rows, cols) singular values, wide included.
    var d = linalg.svdAnyShape(gpa, mat.data, mat.rows, mat.cols) catch return null;
    defer d.deinit();
    const k = @min(mat.rows, mat.cols);
    const out = StzMatrix.init(gpa, k, 1) catch return null;
    @memcpy(out.data, d.values[0..k]);
    return out;
}

/// The rank of ANY m*n matrix (m >= n), from its singular values. This is the general
/// answer; stz_matrix_rank only covers the square symmetric case.
pub fn stz_matrix_rank_general(m: ?*const StzMatrix) callconv(.c) i32 {
    const mat = m orelse return -1;
    if (mat.cols == 0 or mat.rows == 0) return -1;
    const r = linalg.rankOf(gpa, mat.data, mat.rows, mat.cols) catch return -1;
    return @intCast(r);
}

/// The 2-norm condition number of ANY m*n matrix (m >= n): largest singular value
/// over smallest. Infinity when rank deficient -- and this is the number that says how
/// many digits a least-squares fit through this design matrix can lose.
pub fn stz_matrix_condition_general(m: ?*const StzMatrix) callconv(.c) f64 {
    const mat = m orelse return std.math.nan(f64);
    if (mat.cols == 0 or mat.rows == 0) return std.math.nan(f64);
    return linalg.conditionNumberOf(gpa, mat.data, mat.rows, mat.cols) catch std.math.nan(f64);
}

/// The Moore-Penrose pseudo-inverse of ANY m*n matrix, as a new n*m matrix. Every
/// shape and every rank -- wide, tall, square, singular. Null only for an empty one.
pub fn stz_matrix_pseudo_inverse(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    const mat = m orelse return null;
    if (mat.rows == 0 or mat.cols == 0) return null;
    const out = StzMatrix.init(gpa, mat.cols, mat.rows) catch return null;
    const ok = linalg.pseudoInverse(gpa, mat.data, mat.rows, mat.cols, out.data) catch {
        out.deinit();
        return null;
    };
    if (!ok) {
        out.deinit();
        return null;
    }
    return out;
}

/// THE SQUARE ROOT OF A GENERAL REAL MATRIX -- what stz_matrix_matrix_power cannot do,
/// because that one refuses every non-symmetric matrix by construction.
///
/// Null when A has a negative real eigenvalue: the root exists but is COMPLEX, and this
/// returns real matrices. A complex eigenvalue PAIR is fine, and so is a DEFECTIVE
/// matrix -- which has no eigendecomposition at all and a perfectly good square root.
pub fn stz_matrix_sqrt_general(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    const mat = m orelse return null;
    if (mat.rows == 0 or mat.rows != mat.cols) return null;
    const out = StzMatrix.init(gpa, mat.rows, mat.cols) catch return null;
    eigen_general.sqrtGeneral(gpa, mat.data, mat.rows, out.data) catch {
        out.deinit();
        return null;
    };
    return out;
}

/// THE MATRIX ARCSECANT acos(A^-1) and ARCCOSECANT asin(A^-1), with asech and acsch.
///
/// These INVERT THE DOMAIN of the arcsine and arccosine: asin/acos want every eigenvalue
/// inside the unit interval, asec/acsc want every one outside it, and the boundary
/// |L| = 1 belongs to neither -- both routes pass through (I - A^2)^(-1/2), which dies
/// exactly there.
///
/// The identity asec(x) = atan(sqrt(x^2 - 1)) would avoid the inverse entirely, and it is
/// correct for positive x and wrong for negative x by an amount that VARIES with the
/// eigenvalue -- a reflection, not a branch shift, and no constant repairs it. So the
/// inverse is taken, and with it the requirement that A be invertible.
pub fn stz_matrix_asec(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    return matFn(m, eigen_general.asecGeneral);
}

pub fn stz_matrix_acsc(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    return matFn(m, eigen_general.acscGeneral);
}

pub fn stz_matrix_asech(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    return matFn(m, eigen_general.asechGeneral);
}

pub fn stz_matrix_acsch(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    return matFn(m, eigen_general.acschGeneral);
}

/// THE MATRIX ARCCOTANGENT (pi/2) I - atan(A), and acoth(A) = atanh(A^-1).
///
/// Two routes again -- and this time they DISAGREE. (pi/2) I - atan(A) and atan(A^-1)
/// agree on a positive eigenvalue and differ by exactly pi on a negative one, so choosing
/// a route is not choosing how much domain to keep; it is choosing which function to
/// implement. The subtraction is taken: the continuous branch, defined at zero where
/// acot(0) = pi/2, and inheriting atan's domain unchanged.
///
/// And cot has period pi, so cot(acot(A)) = A holds for BOTH -- the obvious check is
/// blind to the difference.
pub fn stz_matrix_acot(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    return matFn(m, eigen_general.acotGeneral);
}

/// The hyperbolic arccotangent has no subtraction to take: atanh wants |x| < 1 and acoth
/// wants |x| > 1, disjoint domains connected only by an imaginary constant. So it needs
/// A invertible -- the first place here where the CIRCULAR side is the wider one.
pub fn stz_matrix_acoth(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    return matFn(m, eigen_general.acothGeneral);
}

/// THE MATRIX COTANGENT cos(A) * sin(A)^-1, and coth(A) = cosh(A) * sinh(A)^-1.
///
/// NOT computed as tan(A)^-1, though the scalar identity says it could be. That route has
/// to form the tangent first, so it needs cos(A) invertible on top of sin(A) -- strictly
/// narrower, and narrower exactly where cos(A) is singular, which is where the cotangent
/// is ZERO. Taking the obvious identity as the implementation would have thrown away a
/// piece of the domain at the one point where the answer is easiest.
pub fn stz_matrix_cot(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    return matFn(m, eigen_general.cotGeneral);
}

pub fn stz_matrix_coth(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    return matFn(m, eigen_general.cothGeneral);
}

/// THE MATRIX SECANT cos(A)^-1, COSECANT sin(A)^-1, and their hyperbolic partners.
///
/// No algorithm of their own -- one inverse of a matrix already computed. The whole
/// content is which matrix is singular when, and the answers differ sharply: the
/// COSECANT refuses every SINGULAR matrix, because zero is an eigenvalue of sin(A)
/// whenever it is one of A. Nothing else in this family is that narrow.
pub fn stz_matrix_sec(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    return matFn(m, eigen_general.secGeneral);
}

pub fn stz_matrix_csc(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    return matFn(m, eigen_general.cscGeneral);
}

pub fn stz_matrix_sech(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    return matFn(m, eigen_general.sechGeneral);
}

pub fn stz_matrix_csch(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    return matFn(m, eigen_general.cschGeneral);
}

/// THE MATRIX ARCSINE: atan( A (I - A^2)^(-1/2) ).
///
/// Null when an eigenvalue leaves [-1, 1]: I - A^2 then carries a negative real
/// eigenvalue, which is asin's branch point rather than a limitation of the method.
pub fn stz_matrix_asin(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    return matFn(m, eigen_general.asinGeneral);
}

/// THE MATRIX ARCCOSINE: (pi/2) I - asin(A). Exact, and it inherits asin's domain.
pub fn stz_matrix_acos(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    return matFn(m, eigen_general.acosGeneral);
}

/// THE HYPERBOLIC ARCSINE: log( A + sqrt(A^2 + I) ). Refuses nothing for a REAL
/// spectrum -- though a complex eigenvalue pair can still put it out of reach.
pub fn stz_matrix_asinh(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    return matFn(m, eigen_general.asinhGeneral);
}

/// THE HYPERBOLIC ARCCOSINE: log( A + sqrt(A^2 - I) ). The minus inverts the domain --
/// where acos wants eigenvalues INSIDE [-1, 1], this wants them outside.
pub fn stz_matrix_acosh(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    return matFn(m, eigen_general.acoshGeneral);
}

/// the shape every one of these shares: square in, square out, null on refusal
fn matFn(
    m: ?*const StzMatrix,
    comptime f: fn (std.mem.Allocator, []const f64, usize, []f64) anyerror!void,
) ?*StzMatrix {
    const mat = m orelse return null;
    if (mat.rows == 0 or mat.rows != mat.cols) return null;
    const out = StzMatrix.init(gpa, mat.rows, mat.cols) catch return null;
    f(gpa, mat.data, mat.rows, out.data) catch {
        out.deinit();
        return null;
    };
    return out;
}

/// THE MATRIX ARCTANGENT, by the halving identity
/// atan(A) = 2 atan(A (I + sqrt(I + A^2))^-1) applied until the argument is small.
///
/// Null when A has an eigenvalue on the imaginary axis beyond +/- i: those are the
/// arctangent's branch points, so there is no principal value to return.
pub fn stz_matrix_atan(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    const mat = m orelse return null;
    if (mat.rows == 0 or mat.rows != mat.cols) return null;
    const out = StzMatrix.init(gpa, mat.rows, mat.cols) catch return null;
    eigen_general.atanGeneral(gpa, mat.data, mat.rows, out.data) catch {
        out.deinit();
        return null;
    };
    return out;
}

/// THE HYPERBOLIC ARCTANGENT: (1/2)[log(I + A) - log(I - A)] -- a closed form in the
/// logarithm, where the circular one needed a halving recurrence.
///
/// Null at an eigenvalue of +/- 1, where atanh runs to infinity.
pub fn stz_matrix_atanh(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    const mat = m orelse return null;
    if (mat.rows == 0 or mat.rows != mat.cols) return null;
    const out = StzMatrix.init(gpa, mat.rows, mat.cols) catch return null;
    eigen_general.atanhGeneral(gpa, mat.data, mat.rows, out.data) catch {
        out.deinit();
        return null;
    };
    return out;
}

/// THE MATRIX TANGENT: sin(A) * cos(A)^-1.
///
/// The side does not matter -- sin(A) and cos(A) are both functions of the same A and
/// therefore commute, so there is no left-tangent and right-tangent to choose between.
///
/// Null when cos(A) is singular, which happens exactly when A has an eigenvalue at
/// pi/2 + k*pi. Unlike the sine and cosine, which refuse nothing, that refusal is the
/// mathematics rather than a limitation of the method.
pub fn stz_matrix_tan(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    const mat = m orelse return null;
    if (mat.rows == 0 or mat.rows != mat.cols) return null;
    const out = StzMatrix.init(gpa, mat.rows, mat.cols) catch return null;
    eigen_general.tanGeneral(gpa, mat.data, mat.rows, out.data) catch {
        out.deinit();
        return null;
    };
    return out;
}

/// THE HYPERBOLIC TANGENT: sinh(A) * cosh(A)^-1. cosh is singular only at purely
/// imaginary eigenvalues, so a real matrix with a real spectrum can never make this
/// fail -- a genuine difference from the circular tangent.
pub fn stz_matrix_tanh(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    const mat = m orelse return null;
    if (mat.rows == 0 or mat.rows != mat.cols) return null;
    const out = StzMatrix.init(gpa, mat.rows, mat.cols) catch return null;
    eigen_general.tanhGeneral(gpa, mat.data, mat.rows, out.data) catch {
        out.deinit();
        return null;
    };
    return out;
}

/// THE HYPERBOLIC MATRIX SINE. The SAME routine as the circular one with a single sign
/// changed -- the double-angle recurrences are identical between the two families, so
/// only the series alternation differs.
pub fn stz_matrix_sinh(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    const mat = m orelse return null;
    if (mat.rows == 0 or mat.rows != mat.cols) return null;
    const out = StzMatrix.init(gpa, mat.rows, mat.cols) catch return null;
    eigen_general.sinhGeneral(gpa, mat.data, mat.rows, out.data) catch {
        out.deinit();
        return null;
    };
    return out;
}

/// THE HYPERBOLIC MATRIX COSINE.
pub fn stz_matrix_cosh(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    const mat = m orelse return null;
    if (mat.rows == 0 or mat.rows != mat.cols) return null;
    const out = StzMatrix.init(gpa, mat.rows, mat.cols) catch return null;
    eigen_general.coshGeneral(gpa, mat.data, mat.rows, out.data) catch {
        out.deinit();
        return null;
    };
    return out;
}

/// THE MATRIX SINE. Scaling with the double-angle recurrences -- no decomposition of
/// any kind, and nothing to refuse: every real matrix has one.
pub fn stz_matrix_sin(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    const mat = m orelse return null;
    if (mat.rows == 0 or mat.rows != mat.cols) return null;
    const out = StzMatrix.init(gpa, mat.rows, mat.cols) catch return null;
    eigen_general.sinGeneral(gpa, mat.data, mat.rows, out.data) catch {
        out.deinit();
        return null;
    };
    return out;
}

/// THE MATRIX COSINE.
pub fn stz_matrix_cos(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    const mat = m orelse return null;
    if (mat.rows == 0 or mat.rows != mat.cols) return null;
    const out = StzMatrix.init(gpa, mat.rows, mat.cols) catch return null;
    eigen_general.cosGeneral(gpa, mat.data, mat.rows, out.data) catch {
        out.deinit();
        return null;
    };
    return out;
}

/// THE MATRIX LOGARITHM: the X with exp(X) = A, by inverse scaling and squaring.
///
/// Null when A is singular -- exp is never singular, so nothing maps to such a matrix
/// and there is no logarithm to return -- or when a negative real eigenvalue makes the
/// answer complex.
pub fn stz_matrix_log(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    const mat = m orelse return null;
    if (mat.rows == 0 or mat.rows != mat.cols) return null;
    const out = StzMatrix.init(gpa, mat.rows, mat.cols) catch return null;
    eigen_general.logGeneral(gpa, mat.data, mat.rows, out.data) catch {
        out.deinit();
        return null;
    };
    return out;
}

/// A^p for a matrix with no symmetry: exp(p log A). What stz_matrix_matrix_power
/// cannot give, since that one refuses every non-symmetric matrix.
pub fn stz_matrix_power_general(m: ?*const StzMatrix, p: f64) callconv(.c) ?*StzMatrix {
    const mat = m orelse return null;
    if (mat.rows == 0 or mat.rows != mat.cols) return null;
    const out = StzMatrix.init(gpa, mat.rows, mat.cols) catch return null;
    eigen_general.powerGeneral(gpa, mat.data, mat.rows, p, out.data) catch {
        out.deinit();
        return null;
    };
    return out;
}

/// THE MATRIX EXPONENTIAL, by scaling and squaring with a Pade approximant -- and
/// deliberately NOT through a Schur form, which would be slower and no more accurate.
pub fn stz_matrix_exp(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    const mat = m orelse return null;
    if (mat.rows == 0 or mat.rows != mat.cols) return null;
    const out = StzMatrix.init(gpa, mat.rows, mat.cols) catch return null;
    eigen_general.expGeneral(gpa, mat.data, mat.rows, out.data) catch {
        out.deinit();
        return null;
    };
    return out;
}

/// THE ORTHOGONAL SCHUR DECOMPOSITION: A = Q T Q', returned as Q. See
/// stz_matrix_schur_t for T -- two calls rather than one struct, because the handle
/// table carries matrices and not tuples.
pub fn stz_matrix_schur_q(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    const mat = m orelse return null;
    if (mat.rows == 0 or mat.rows != mat.cols) return null;
    var d = eigen_general.schur(gpa, mat.data, mat.rows) catch return null;
    defer d.deinit();
    const out = StzMatrix.init(gpa, mat.rows, mat.cols) catch return null;
    @memcpy(out.data, d.q);
    return out;
}

/// The quasi-upper-triangular factor T of A = Q T Q'.
pub fn stz_matrix_schur_t(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    const mat = m orelse return null;
    if (mat.rows == 0 or mat.rows != mat.cols) return null;
    var d = eigen_general.schur(gpa, mat.data, mat.rows) catch return null;
    defer d.deinit();
    const out = StzMatrix.init(gpa, mat.rows, mat.cols) catch return null;
    @memcpy(out.data, d.t);
    return out;
}

/// A^-1 = Q T^-1 Q'. Correct, and the wrong route to use -- see LUInverse.
pub fn stz_matrix_schur_inverse(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    const mat = m orelse return null;
    if (mat.rows == 0 or mat.rows != mat.cols) return null;
    const out = StzMatrix.init(gpa, mat.rows, mat.cols) catch return null;
    const ok = eigen_general.schurInverse(gpa, mat.data, mat.rows, out.data) catch {
        out.deinit();
        return null;
    };
    if (!ok) {
        out.deinit();
        return null;
    }
    return out;
}

/// A INVERSE THROUGH ITS LU FACTORS -- the fastest route for a general square matrix.
///
/// A = P L U, so each column of the inverse is one forward and one back substitution
/// against a unit vector. Roughly half the work of the QR route, and the one to reach
/// for when the matrix is square and merely invertible.
///
/// Null when the factorisation finds a numerically zero pivot: the matrix has no
/// inverse, and back-substituting through that pivot returns confident garbage.
pub fn stz_matrix_lu_inverse(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    const mat = m orelse return null;
    if (mat.rows == 0 or mat.rows != mat.cols) return null;
    const out = StzMatrix.init(gpa, mat.rows, mat.cols) catch return null;
    const ok = linalg.luInverse(gpa, mat.data, mat.rows, out.data) catch {
        out.deinit();
        return null;
    };
    if (!ok) {
        out.deinit();
        return null;
    }
    return out;
}

/// A INVERSE THROUGH ITS QR FACTORS -- the route for a matrix that is merely
/// invertible, with no symmetry to exploit.
///
/// Fills the gap the other fast routes leave: Cholesky needs positive definiteness and
/// the eigen route needs symmetry, so a general invertible matrix -- a transition
/// matrix, a Jacobian, a change of basis -- had only the SVD until this. For a TALL
/// matrix the same formula is the pseudo-inverse, which is why least squares has always
/// been a QR solve underneath.
///
/// Null when A is rank-deficient: R then has a diagonal entry at rounding level, and
/// back-substituting through it produces confident garbage. That case is the SVD's.
pub fn stz_matrix_qr_inverse(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    const mat = m orelse return null;
    if (mat.rows == 0 or mat.cols == 0 or mat.rows < mat.cols) return null;
    const out = StzMatrix.init(gpa, mat.cols, mat.rows) catch return null;
    const ok = linalg.qrInverse(gpa, mat.data, mat.rows, mat.cols, out.data) catch {
        out.deinit();
        return null;
    };
    if (!ok) {
        out.deinit();
        return null;
    }
    return out;
}

/// A INVERSE THROUGH ITS CHOLESKY FACTOR -- the right tool when A is SPD, and measured
/// at roughly 19x faster than the eigen route and 20x faster than the SVD one on a
/// 120x120 matrix. Null when A is not positive definite, which the factorisation
/// discovers on its own at the first non-positive pivot.
pub fn stz_matrix_cholesky_inverse(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    const mat = m orelse return null;
    if (mat.rows == 0 or mat.rows != mat.cols) return null;
    const out = StzMatrix.init(gpa, mat.rows, mat.cols) catch return null;
    const ok = linalg.choleskyInverse(gpa, mat.data, mat.rows, out.data) catch {
        out.deinit();
        return null;
    };
    if (!ok) {
        out.deinit();
        return null;
    }
    return out;
}

/// L INVERSE -- the inverse of the triangular FACTOR, which is itself a whitening
/// matrix, and a DIFFERENT one from the symmetric whitener the eigen route gives.
pub fn stz_matrix_cholesky_factor_inverse(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    const mat = m orelse return null;
    if (mat.rows == 0 or mat.rows != mat.cols) return null;
    const out = StzMatrix.init(gpa, mat.rows, mat.cols) catch return null;
    const ok = linalg.choleskyFactorInverse(gpa, mat.data, mat.rows, out.data) catch {
        out.deinit();
        return null;
    };
    if (!ok) {
        out.deinit();
        return null;
    }
    return out;
}

/// A RAISED TO A REAL POWER through its eigendecomposition: A^p = Q L^p Q'.
///
/// NOT `stz_matrix_power`, which raises every ELEMENT to a power. That one is an
/// elementwise map and this one is a matrix function; they agree only for a diagonal
/// matrix. Two operations one keystroke apart, so the names have to carry the
/// difference.
///
/// Null when the matrix is not symmetric, is singular for a negative power, or has a
/// negative eigenvalue under a fractional one -- refused rather than returned as NaN,
/// because a NaN propagates quietly through everything downstream.
pub fn stz_matrix_matrix_power(m: ?*const StzMatrix, p: f64) callconv(.c) ?*StzMatrix {
    const mat = m orelse return null;
    if (mat.rows == 0 or mat.rows != mat.cols) return null;
    const out = StzMatrix.init(gpa, mat.rows, mat.cols) catch return null;
    linalg.symmetricPower(gpa, mat.data, mat.rows, p, out.data) catch {
        out.deinit();
        return null;
    };
    return out;
}

/// A rebuilt from its k leading eigenpairs: A_k = Q_k L_k Q_k'.
pub fn stz_matrix_eigen_reconstruct(m: ?*const StzMatrix, k: c_int) callconv(.c) ?*StzMatrix {
    const mat = m orelse return null;
    if (mat.rows == 0 or mat.rows != mat.cols or k <= 0) return null;
    const out = StzMatrix.init(gpa, mat.rows, mat.cols) catch return null;
    linalg.symmetricReconstruct(gpa, mat.data, mat.rows, @intCast(k), out.data) catch {
        out.deinit();
        return null;
    };
    return out;
}

/// THE BEST RANK-k APPROXIMATION of this matrix -- the OTHER sense of inverting an SVD.
///
/// The pseudo-inverse above answers "undo this transformation". This answers "keep the
/// k strongest directions and discard the rest", which is the sense the embedding work
/// means: PCA's reconstruction is exactly this on the centered matrix.
///
/// Its error is an identity rather than a measurement. Eckart and Young proved no
/// rank-k matrix is closer in the Frobenius norm, and that the distance is exactly the
/// squares of the singular values dropped -- so a caller who kept k of them already
/// knows the cost without measuring anything.
pub fn stz_matrix_low_rank(m: ?*const StzMatrix, k: c_int) callconv(.c) ?*StzMatrix {
    const mat = m orelse return null;
    if (mat.rows == 0 or mat.cols == 0 or k <= 0) return null;
    const out = StzMatrix.init(gpa, mat.rows, mat.cols) catch return null;
    const ok = linalg.lowRankApproximation(gpa, mat.data, mat.rows, mat.cols, @intCast(k), out.data) catch {
        out.deinit();
        return null;
    };
    if (!ok) {
        out.deinit();
        return null;
    }
    return out;
}

/// The MINIMUM-NORM least-squares solution x = A+b, as a new n*1 matrix. Where
/// stz_matrix_least_squares refuses -- rank deficiency, or an underdetermined shape --
/// this answers, with the solution that is both a minimiser and the shortest one.
pub fn stz_matrix_min_norm_solve(a: ?*const StzMatrix, b: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    const ma = a orelse return null;
    const mb = b orelse return null;
    if (mb.cols != 1 or mb.rows != ma.rows) return null;
    if (ma.rows == 0 or ma.cols == 0) return null;
    const out = StzMatrix.init(gpa, ma.cols, 1) catch return null;
    const ok = linalg.minimumNormSolve(gpa, ma.data, ma.rows, ma.cols, mb.data, out.data) catch {
        out.deinit();
        return null;
    };
    if (!ok) {
        out.deinit();
        return null;
    }
    return out;
}

pub fn stz_matrix_inverse(m: ?*const StzMatrix) callconv(.c) ?*StzMatrix {
    const mat = m orelse return null;
    if (mat.rows != mat.cols) return null;
    const n = mat.rows;

    const aug = gpa.alloc(f64, n * 2 * n) catch return null;
    defer gpa.free(aug);

    const w = 2 * n;
    for (0..n) |i| {
        for (0..n) |j| {
            aug[i * w + j] = mat.at(i, j);
            aug[i * w + n + j] = if (i == j) 1.0 else 0.0;
        }
    }

    for (0..n) |i| {
        var pivot_row = i;
        var pivot_val = @abs(aug[i * w + i]);
        for (i + 1..n) |r| {
            const v = @abs(aug[r * w + i]);
            if (v > pivot_val) {
                pivot_val = v;
                pivot_row = r;
            }
        }
        if (pivot_val < 1e-15) return null;

        if (pivot_row != i) {
            for (0..w) |c| {
                const tmp = aug[i * w + c];
                aug[i * w + c] = aug[pivot_row * w + c];
                aug[pivot_row * w + c] = tmp;
            }
        }

        const div = aug[i * w + i];
        for (0..w) |c| aug[i * w + c] /= div;

        for (0..n) |r| {
            if (r == i) continue;
            const factor = aug[r * w + i];
            for (0..w) |c| aug[r * w + c] -= factor * aug[i * w + c];
        }
    }

    const result = StzMatrix.init(gpa, n, n) catch return null;
    for (0..n) |i| {
        for (0..n) |j| {
            result.setAt(i, j, aug[i * w + n + j]);
        }
    }
    return result;
}

pub fn stz_matrix_power(m: ?*StzMatrix, p: f64) callconv(.c) void {
    const mat = m orelse return;
    for (mat.data) |*v| v.* = std.math.pow(f64, v.*, p);
}

pub fn stz_matrix_find(m: ?*const StzMatrix, val: f64) callconv(.c) i64 {
    const mat = m orelse return -1;
    for (0..mat.rows) |i| {
        for (0..mat.cols) |j| {
            if (mat.at(i, j) == val) {
                return @as(i64, @intCast(i)) * @as(i64, @intCast(mat.cols)) + @as(i64, @intCast(j));
            }
        }
    }
    return -1;
}

pub fn stz_matrix_find_row(m: ?*const StzMatrix) callconv(.c) i32 {
    const r = stz_matrix_find(m, 0);
    if (r < 0) return -1;
    const mat = m orelse return -1;
    return @intCast(@as(usize, @intCast(r)) / mat.cols);
}

pub fn stz_matrix_find_col(m: ?*const StzMatrix) callconv(.c) i32 {
    const r = stz_matrix_find(m, 0);
    if (r < 0) return -1;
    const mat = m orelse return -1;
    return @intCast(@as(usize, @intCast(r)) % mat.cols);
}

test "matrix new/free" {
    const m = stz_matrix_new(3, 4);
    try std.testing.expect(m != null);
    try std.testing.expectEqual(@as(i32, 3), stz_matrix_rows(m));
    try std.testing.expectEqual(@as(i32, 4), stz_matrix_cols(m));
    stz_matrix_free(m);

    try std.testing.expect(stz_matrix_new(0, 5) == null);
    try std.testing.expect(stz_matrix_new(-1, 3) == null);
}

test "matrix set/get" {
    const m = stz_matrix_new(2, 3).?;
    defer stz_matrix_free(m);

    stz_matrix_set(m, 0, 0, 1.0);
    stz_matrix_set(m, 0, 1, 2.0);
    stz_matrix_set(m, 0, 2, 3.0);
    stz_matrix_set(m, 1, 0, 4.0);
    stz_matrix_set(m, 1, 1, 5.0);
    stz_matrix_set(m, 1, 2, 6.0);

    try std.testing.expectEqual(@as(f64, 1.0), stz_matrix_get(m, 0, 0));
    try std.testing.expectEqual(@as(f64, 6.0), stz_matrix_get(m, 1, 2));
    try std.testing.expectEqual(@as(f64, 0.0), stz_matrix_get(m, 5, 5));
}

test "matrix aggregates" {
    const m = stz_matrix_new(2, 2).?;
    defer stz_matrix_free(m);

    stz_matrix_set(m, 0, 0, 1.0);
    stz_matrix_set(m, 0, 1, 2.0);
    stz_matrix_set(m, 1, 0, 3.0);
    stz_matrix_set(m, 1, 1, 4.0);

    try std.testing.expectEqual(@as(f64, 10.0), stz_matrix_sum(m));
    try std.testing.expectEqual(@as(f64, 1.0), stz_matrix_min(m));
    try std.testing.expectEqual(@as(f64, 4.0), stz_matrix_max(m));
    try std.testing.expectEqual(@as(f64, 2.5), stz_matrix_mean(m));
}

test "matrix scalar ops" {
    const m = stz_matrix_new(2, 2).?;
    defer stz_matrix_free(m);

    stz_matrix_set(m, 0, 0, 1.0);
    stz_matrix_set(m, 0, 1, 2.0);
    stz_matrix_set(m, 1, 0, 3.0);
    stz_matrix_set(m, 1, 1, 4.0);

    stz_matrix_add_scalar(m, 10.0);
    try std.testing.expectEqual(@as(f64, 11.0), stz_matrix_get(m, 0, 0));
    try std.testing.expectEqual(@as(f64, 14.0), stz_matrix_get(m, 1, 1));

    stz_matrix_multiply_scalar(m, 2.0);
    try std.testing.expectEqual(@as(f64, 22.0), stz_matrix_get(m, 0, 0));
}

test "matrix multiply" {
    // [1 2]   [5 6]   [1*5+2*7  1*6+2*8]   [19 22]
    // [3 4] * [7 8] = [3*5+4*7  3*6+4*8] = [43 50]
    const a = stz_matrix_new(2, 2).?;
    defer stz_matrix_free(a);
    stz_matrix_set(a, 0, 0, 1); stz_matrix_set(a, 0, 1, 2);
    stz_matrix_set(a, 1, 0, 3); stz_matrix_set(a, 1, 1, 4);

    const b = stz_matrix_new(2, 2).?;
    defer stz_matrix_free(b);
    stz_matrix_set(b, 0, 0, 5); stz_matrix_set(b, 0, 1, 6);
    stz_matrix_set(b, 1, 0, 7); stz_matrix_set(b, 1, 1, 8);

    const c = stz_matrix_multiply(a, b).?;
    defer stz_matrix_free(c);

    try std.testing.expectEqual(@as(f64, 19.0), stz_matrix_get(c, 0, 0));
    try std.testing.expectEqual(@as(f64, 22.0), stz_matrix_get(c, 0, 1));
    try std.testing.expectEqual(@as(f64, 43.0), stz_matrix_get(c, 1, 0));
    try std.testing.expectEqual(@as(f64, 50.0), stz_matrix_get(c, 1, 1));
}

test "matrix transpose" {
    const m = stz_matrix_new(2, 3).?;
    defer stz_matrix_free(m);
    stz_matrix_set(m, 0, 0, 1); stz_matrix_set(m, 0, 1, 2); stz_matrix_set(m, 0, 2, 3);
    stz_matrix_set(m, 1, 0, 4); stz_matrix_set(m, 1, 1, 5); stz_matrix_set(m, 1, 2, 6);

    const t = stz_matrix_transpose(m).?;
    defer stz_matrix_free(t);

    try std.testing.expectEqual(@as(i32, 3), stz_matrix_rows(t));
    try std.testing.expectEqual(@as(i32, 2), stz_matrix_cols(t));
    try std.testing.expectEqual(@as(f64, 1.0), stz_matrix_get(t, 0, 0));
    try std.testing.expectEqual(@as(f64, 4.0), stz_matrix_get(t, 0, 1));
    try std.testing.expectEqual(@as(f64, 3.0), stz_matrix_get(t, 2, 0));
    try std.testing.expectEqual(@as(f64, 6.0), stz_matrix_get(t, 2, 1));
}

test "matrix determinant" {
    // det([1 2; 3 4]) = 1*4 - 2*3 = -2
    const m2 = stz_matrix_new(2, 2).?;
    defer stz_matrix_free(m2);
    stz_matrix_set(m2, 0, 0, 1); stz_matrix_set(m2, 0, 1, 2);
    stz_matrix_set(m2, 1, 0, 3); stz_matrix_set(m2, 1, 1, 4);
    try std.testing.expectEqual(@as(f64, -2.0), stz_matrix_determinant(m2));

    // det([6 1 1; 4 -2 5; 2 8 7]) = 6(-14-40) - 1(28-10) + 1(32+4) = -306
    const m3 = stz_matrix_new(3, 3).?;
    defer stz_matrix_free(m3);
    stz_matrix_set(m3, 0, 0, 6); stz_matrix_set(m3, 0, 1, 1); stz_matrix_set(m3, 0, 2, 1);
    stz_matrix_set(m3, 1, 0, 4); stz_matrix_set(m3, 1, 1, -2); stz_matrix_set(m3, 1, 2, 5);
    stz_matrix_set(m3, 2, 0, 2); stz_matrix_set(m3, 2, 1, 8); stz_matrix_set(m3, 2, 2, 7);

    const d = stz_matrix_determinant(m3);
    try std.testing.expectApproxEqAbs(@as(f64, -306.0), d, 1e-10);
}

test "matrix inverse" {
    // inv([4 7; 2 6]) = [6 -7; -2 4] / det = [6 -7; -2 4] / 10
    const m = stz_matrix_new(2, 2).?;
    defer stz_matrix_free(m);
    stz_matrix_set(m, 0, 0, 4); stz_matrix_set(m, 0, 1, 7);
    stz_matrix_set(m, 1, 0, 2); stz_matrix_set(m, 1, 1, 6);

    const inv = stz_matrix_inverse(m).?;
    defer stz_matrix_free(inv);

    try std.testing.expectApproxEqAbs(@as(f64, 0.6), stz_matrix_get(inv, 0, 0), 1e-10);
    try std.testing.expectApproxEqAbs(@as(f64, -0.7), stz_matrix_get(inv, 0, 1), 1e-10);
    try std.testing.expectApproxEqAbs(@as(f64, -0.2), stz_matrix_get(inv, 1, 0), 1e-10);
    try std.testing.expectApproxEqAbs(@as(f64, 0.4), stz_matrix_get(inv, 1, 1), 1e-10);

    // Singular matrix should return null
    const s = stz_matrix_new(2, 2).?;
    defer stz_matrix_free(s);
    stz_matrix_set(s, 0, 0, 1); stz_matrix_set(s, 0, 1, 2);
    stz_matrix_set(s, 1, 0, 2); stz_matrix_set(s, 1, 1, 4);
    try std.testing.expect(stz_matrix_inverse(s) == null);
}

test "matrix add_matrix" {
    const a = stz_matrix_new(2, 2).?;
    defer stz_matrix_free(a);
    stz_matrix_set(a, 0, 0, 1); stz_matrix_set(a, 0, 1, 2);
    stz_matrix_set(a, 1, 0, 3); stz_matrix_set(a, 1, 1, 4);

    const b = stz_matrix_new(2, 2).?;
    defer stz_matrix_free(b);
    stz_matrix_set(b, 0, 0, 10); stz_matrix_set(b, 0, 1, 20);
    stz_matrix_set(b, 1, 0, 30); stz_matrix_set(b, 1, 1, 40);

    try std.testing.expectEqual(@as(i32, 0), stz_matrix_add_matrix(a, b));
    try std.testing.expectEqual(@as(f64, 11.0), stz_matrix_get(a, 0, 0));
    try std.testing.expectEqual(@as(f64, 44.0), stz_matrix_get(a, 1, 1));
}

test "matrix power" {
    const m = stz_matrix_new(2, 2).?;
    defer stz_matrix_free(m);
    stz_matrix_set(m, 0, 0, 2); stz_matrix_set(m, 0, 1, 3);
    stz_matrix_set(m, 1, 0, 4); stz_matrix_set(m, 1, 1, 5);

    stz_matrix_power(m, 2.0);
    try std.testing.expectEqual(@as(f64, 4.0), stz_matrix_get(m, 0, 0));
    try std.testing.expectEqual(@as(f64, 9.0), stz_matrix_get(m, 0, 1));
    try std.testing.expectEqual(@as(f64, 16.0), stz_matrix_get(m, 1, 0));
    try std.testing.expectEqual(@as(f64, 25.0), stz_matrix_get(m, 1, 1));
}

test "matrix null safety" {
    stz_matrix_free(null);
    try std.testing.expectEqual(@as(i32, 0), stz_matrix_rows(null));
    try std.testing.expectEqual(@as(i32, 0), stz_matrix_cols(null));
    try std.testing.expectEqual(@as(f64, 0.0), stz_matrix_sum(null));
    try std.testing.expectEqual(@as(f64, 0.0), stz_matrix_get(null, 0, 0));
    stz_matrix_set(null, 0, 0, 1.0);
    try std.testing.expect(stz_matrix_multiply(null, null) == null);
    try std.testing.expect(stz_matrix_transpose(null) == null);
    try std.testing.expect(stz_matrix_inverse(null) == null);
}
