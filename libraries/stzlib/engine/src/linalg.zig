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
const calib = @import("calib.zig");

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

/// dst -= factor * src, over two non-overlapping row tails.
///
/// THE SLICES ARE THE OPTIMISATION. There is no @Vector here, and that is the
/// point: this loop was written as `lu[r*n + c] -= factor * lu[k*n + c]`, and
/// LLVM cannot vectorise that, because it cannot prove two computed offsets
/// into the SAME array never alias. Handed the same work as two slices, it
/// proves independence and emits the wide code itself. Measured at
/// ReleaseSafe, LU factorisation of the real thing:
///
///     n     index loop      slices      explicit @Vector
///     100    1108.79 ms    162.17 ms    244.24 ms
///     400    3909.74 ms    695.37 ms   1042.07 ms
///     800    7915.62 ms   2083.86 ms   2513.64 ms
///
/// So the slice form is 3.8-6.8x over what shipped, and a HAND-WRITTEN vector
/// version is consistently SLOWER than it -- my explicit tail handling and
/// fixed lane count get in the way of a job the compiler does better. The
/// obstacle was never the compiler's ability; it was the index arithmetic
/// hiding the independence from it. Reach for @Vector where the compiler
/// cannot see the structure (search, masking, mixed predicates), not where it
/// merely needs to be shown.
///
/// BIT-IDENTICAL either way, which is what made this safe under the oracle
/// tier: every output cell is computed from its own two inputs, so there is no
/// reduction and no summation order to change. Note the contrast with the
/// dot-product loops in cholesky() and qr(): same visual shape, but they
/// accumulate into ONE scalar, so vectorising them WOULD re-associate the
/// additions. LLVM will not do that to floats on its own, and neither should
/// we without re-arguing every kappa(A)*eps tolerance in the oracle corpus.
fn axpyNeg(dst: []f64, src: []const f64, factor: f64) void {
    for (dst, src) |*d, s| d.* -= factor * s;
}

// --- Parallel elimination for decompose (M2 of the multicore tier) ---
//
// LU's k loop is SEQUENTIAL (each pivot depends on the previous step), so
// only the per-k elimination fans out: rows k+1..n are independent axpys.
// Workers are spawned ONCE per factorisation and synchronised with a
// spinning generation barrier -- spawn-per-k would cost n * ~0.4 ms and
// drown the work (measured, cpu_spike).
//
// MEASURED (tools/lu_spike.zig, two runs on the shared dev box):
//     n=256   parallel LOSES at every config (0.45-0.72x)  -> serial
//     n=512   1.16-1.40x, real but thin                    -> serial
//     n=1024  2.8-3.4x                                     -> parallel
//     n=1536  2.4-3.0x (one T4 reading collapsed to 1.34x under machine
//             contention; T8 held on both runs -- T8 chosen for robustness
//             on shared machines, not for the best quiet-machine number)
//
// BIT-IDENTICAL to the serial path, value-for-value AND pivot-for-pivot:
// pivot search stays on the main thread, each row is eliminated by exactly
// one worker in the same axpy order, no cross-thread reduction. The parity
// test below pins it, singular case included.
//
// The gate sits where the measurement supports it, PROVISIONAL until the
// shared calibration store (M5). Tests may lower it to exercise the
// parallel path on small fixtures.
pub var lu_gate = calib.Gate.init("cpu.lu.par_min_n", 1024);
const LU_WORKERS = 8;
const LU_MIN_ROWS_PER_STEP = 64; // triangle tail: barrier tax exceeds work

const LuPar = struct {
    lu: []f64,
    n: usize,
    k: std.atomic.Value(usize),
    gen: std.atomic.Value(usize),
    done: std.atomic.Value(usize),
    nt: usize,
    quit: std.atomic.Value(bool),
};

fn luEliminateRows(lu: []f64, n: usize, k: usize, r0: usize, r1: usize) void {
    const pivot = lu[k * n + k];
    var r = r0;
    while (r < r1) : (r += 1) {
        const factor = lu[r * n + k] / pivot;
        lu[r * n + k] = factor;
        if (factor != 0.0) {
            axpyNeg(lu[r * n + k + 1 .. r * n + n], lu[k * n + k + 1 .. k * n + n], factor);
        }
    }
}

fn luWorker(sh: *LuPar, tid: usize) void {
    var seen: usize = 0;
    while (true) {
        while (sh.gen.load(.acquire) == seen) {
            if (sh.quit.load(.acquire)) return;
            std.atomic.spinLoopHint();
        }
        seen = sh.gen.load(.acquire);
        const n = sh.n;
        const k = sh.k.load(.acquire);
        const rows = n - (k + 1);
        const per = (rows + sh.nt - 1) / sh.nt;
        const r0 = k + 1 + tid * per;
        const r1 = @min(r0 + per, n);
        if (r0 < r1) luEliminateRows(sh.lu, n, k, r0, r1);
        _ = sh.done.fetchAdd(1, .release);
    }
}

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
    // the scale the threshold is relative to: an absolute cutoff would call a matrix of
    // uniformly tiny entries singular, when scaling cannot change rank
    var largest_entry: f64 = 0;
    for (data) |v| largest_entry = @max(largest_entry, @abs(v));

    // Parallel workers exist for the whole factorisation or not at all;
    // the per-step branch below only decides who runs a given elimination.
    var par = LuPar{
        .lu = lu,
        .n = n,
        .k = std.atomic.Value(usize).init(0),
        .gen = std.atomic.Value(usize).init(0),
        .done = std.atomic.Value(usize).init(0),
        .nt = 0,
        .quit = std.atomic.Value(bool).init(false),
    };
    var workers: [LU_WORKERS]std.Thread = undefined;
    if (n >= lu_gate.valueUsize()) {
        const cpus = std.Thread.getCpuCount() catch 1;
        const want = @min(LU_WORKERS, cpus);
        var wt: usize = 0;
        while (wt < want) : (wt += 1) {
            workers[par.nt] = std.Thread.spawn(.{}, luWorker, .{ &par, par.nt }) catch break;
            par.nt += 1;
        }
    }
    defer if (par.nt > 0) {
        par.quit.store(true, .release);
        for (workers[0..par.nt]) |th| th.join();
    };

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

        // AGAINST A THRESHOLD, NOT AGAINST ZERO -- and this was an exact `== 0.0`, the
        // THIRD instance of that defect in this file. `isFullRank` had it, the
        // condition number had it, and both are documented below at length.
        //
        // Gaussian elimination does not leave a dependent column's pivot at exactly
        // zero; it leaves it at rounding level, and how close depends on the size of
        // the matrix. So [1,2,3; 4,5,6; 5,7,9] -- row 3 is row 1 plus row 2, rank 2 of
        // 3 -- factored with `singular` FALSE, and `luInverse` then back-substituted
        // through that pivot and returned a matrix it called an inverse.
        //
        // Found by asking the new LU inverse to refuse a singular matrix and watching
        // it accept, which is exactly how the Cholesky symmetry defect surfaced one
        // commit ago. The negative assertions keep being the ones that find things.
        if (pivot_mag <= negligibleThreshold(largest_entry, n)) {
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

        // eliminate below, storing the multipliers in place as L. Parallel
        // dispatch runs the SAME luEliminateRows the serial arm uses --
        // one code path, split or not. (The old inline loop moved into
        // luEliminateRows verbatim; the row tail is contiguous and r != k
        // always, so source and destination never alias.)
        const rows_below = n - (k + 1);
        if (par.nt > 1 and rows_below >= LU_MIN_ROWS_PER_STEP) {
            par.k.store(k, .release);
            par.done.store(0, .release);
            par.gen.store(par.gen.load(.acquire) + 1, .release);
            while (par.done.load(.acquire) < par.nt) std.atomic.spinLoopHint();
        } else if (rows_below > 0) {
            luEliminateRows(lu, n, k, k + 1, n);
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

/// A INVERSE THROUGH ITS LU FACTORS -- the fastest route for a general square matrix.
///
/// A = P L U, so solving A x = e_j for each unit vector gives the inverse a column at a
/// time: one forward and one back substitution each, and the factorisation itself done
/// once. This is the textbook general inverse, and it completes the set:
///
///     choleskyInverse   symmetric positive definite   ~n^3/6   fastest of all
///     THIS              any nonsingular SQUARE        ~n^3/3   fastest general
///     qrInverse         any full-rank square or TALL  ~2n^3/3  more stable
///     symmetricPower    symmetric                     iterative, and gives powers
///     pseudoInverse     everything, incl. rank-def.   iterative, most general
///
/// ── WHY BOTH THIS AND QR, WHEN LU IS CHEAPER ──
///
/// Partial pivoting makes LU stable enough for almost everything, and it does half the
/// work of a QR. What QR buys is behaviour on an ill-conditioned matrix, where LU's
/// error can grow with the condition number faster than QR's -- and the honest way to
/// state that is with a measurement rather than a rule of thumb, which the tests do on
/// a Hilbert matrix.
///
/// It also cannot touch a tall matrix. LU is square-only, so least squares stays QR's.
///
/// Returns false when the factorisation found a numerically zero pivot: the matrix has
/// no inverse, and back-substituting through that pivot would return confident garbage.
pub fn luInverse(
    allocator: std.mem.Allocator,
    data: []const f64,
    n: usize,
    out: []f64,
) !bool {
    if (n == 0) return false;
    var f = try decompose(allocator, data, n);
    defer f.deinit();
    if (f.singular) return false;

    const e = try allocator.alloc(f64, n);
    defer allocator.free(e);
    const col = try allocator.alloc(f64, n);
    defer allocator.free(col);

    for (0..n) |j| {
        @memset(e, 0);
        e[j] = 1;
        if (!solveWith(&f, e, col)) return false;
        for (0..n) |i| out[i * n + j] = col[i];
    }
    return true;
}

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
    // SYMMETRY IS CHECKED, and it was not before -- a real defect, found while adding
    // the QR inverse. This algorithm reads only the LOWER triangle, so a non-symmetric
    // matrix used to factor happily: `positive_definite` came back TRUE and L L' then
    // differed from A by as much as 3.0 on a 4x4. Every caller downstream believed it.
    // `choleskyInverse` returned a matrix that was not A's inverse, and
    // `stz_matrix_is_positive_definite` called a non-symmetric matrix positive definite,
    // which is not even a property it can have.
    //
    // Exactly the shape of the `isFullRank` defect documented above: a check the
    // algorithm never performs because its arithmetic does not happen to need it, and
    // a confident wrong answer downstream. It asks `isSymmetric`, the same function the
    // eigen path asks, so the two cannot drift apart on what symmetric means.
    if (n > 0 and !isSymmetric(data, n)) {
        const l0 = try allocator.alloc(f64, n * n);
        @memset(l0, 0);
        return Cholesky{
            .l = l0,
            .n = n,
            .positive_definite = false,
            .allocator = allocator,
        };
    }
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

/// A INVERSE THROUGH ITS CHOLESKY FACTOR -- the right tool when A is SPD.
///
/// The library can already invert this matrix two other ways: `pseudoInverse` decomposes
/// it with an SVD, `symmetricPower(-1)` with an eigendecomposition. Both are correct and
/// both do far more work than the question needs. A symmetric positive-definite matrix
/// has a triangular factor, and once you have it the inverse is n forward-and-back
/// substitutions -- no iteration, no sweeps, nothing to converge.
///
/// MEASURED rather than asserted, on a 120x120 SPD matrix, five repetitions:
///
///     cholesky      6 ms
///     eigen       112 ms      19x
///     svd         123 ms      20x
///
/// Both of the others are running an iterative diagonalisation to answer a question
/// that direct substitution settles. The number is here rather than in a timing test,
/// which would be flaky for no gain -- what a caller needs is to know which to reach
/// for, and this says it.
///
/// So this is not a fourth opinion about what A-inverse is. It is the same number
/// reached by the cheapest road, and the tests check it against the other two rather
/// than against a tabulated matrix.
///
/// Returns false when A is not positive definite -- which the factorisation discovers
/// on its own, at the first non-positive pivot, and is exactly the condition under
/// which "the Cholesky inverse" is not a thing that exists.
pub fn choleskyInverse(
    allocator: std.mem.Allocator,
    data: []const f64,
    n: usize,
    out: []f64,
) !bool {
    var f = try cholesky(allocator, data, n);
    defer f.deinit();
    if (!f.positive_definite) return false;

    const e = try allocator.alloc(f64, n);
    defer allocator.free(e);
    const col = try allocator.alloc(f64, n);
    defer allocator.free(col);

    for (0..n) |j| {
        @memset(e, 0);
        e[j] = 1;
        if (!choleskySolve(&f, e, col)) return false;
        // column j of the inverse
        for (0..n) |i| out[i * n + j] = col[i];
    }
    return true;
}

/// L INVERSE -- the inverse of the triangular FACTOR, not of A.
///
/// ── AND IT IS A WHITENING MATRIX, WHICH IS THE INTERESTING PART ──
///
/// A = L L', so L^-1 A L^-1' = I. That is the defining property of a whitener, and
/// `symmetricPower(-0.5)` produces one too -- but they are DIFFERENT MATRICES. Both
/// satisfy the identity; neither is more correct.
///
/// Whitening is not unique. Any W with W A W' = I qualifies, and there are as many as
/// there are rotations: if W works then so does QW for any orthogonal Q. The eigen route
/// picks the SYMMETRIC one; this route picks the TRIANGULAR one, which is cheaper and is
/// what a sampler wants, since it turns independent normals into correlated ones by a
/// single multiply.
///
/// This is the same distinction as the two square roots one level up, and for the same
/// reason: a factorisation answers "give me something that squares to A", and that
/// question has many answers.
pub fn choleskyFactorInverse(
    allocator: std.mem.Allocator,
    data: []const f64,
    n: usize,
    out: []f64,
) !bool {
    var f = try cholesky(allocator, data, n);
    defer f.deinit();
    if (!f.positive_definite) return false;

    // forward substitution against each unit vector, which for a triangular matrix is
    // the whole inversion
    @memset(out, 0);
    for (0..n) |j| {
        out[j * n + j] = 1.0 / f.at(j, j);
        for (j + 1..n) |i| {
            var acc: f64 = 0;
            for (j..i) |t| acc += f.at(i, t) * out[t * n + j];
            out[i * n + j] = -acc / f.at(i, i);
        }
    }
    return true;
}

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

/// A INVERSE THROUGH ITS QR FACTORS -- the route for a matrix that is merely
/// invertible, with no symmetry to exploit.
///
/// ── THE GAP THIS FILLS, WHICH IS THE REASON IT EXISTS ──
///
/// The library can invert a matrix four ways now, and until this one the general square
/// case had no fast route at all:
///
///     choleskyInverse    SPD only          fastest, refuses anything else
///     symmetricPower     symmetric only    refuses a non-symmetric matrix
///     THIS               any full rank     square or tall, no symmetry needed
///     pseudoInverse      everything        including rank-deficient, and slowest
///
/// A general invertible matrix -- a transition matrix, a Jacobian, a change of basis --
/// is symmetric only by accident, so the first two decline and the SVD was all that was
/// left. A = QR with Q orthogonal and R triangular gives A^-1 = R^-1 Q', which is one
/// back-substitution per column and no iteration anywhere.
///
/// ── AND FOR A TALL MATRIX IT IS THE PSEUDO-INVERSE ──
///
/// The same formula, unchanged. When A is m*n with m > n and full column rank,
/// R^-1 Q' IS the Moore-Penrose inverse -- which is why `leastSquares` has always been
/// a QR solve underneath. Building it column by column just makes the operator itself
/// available rather than one solution at a time. A test checks it against
/// `pseudoInverse` rather than restating the claim.
///
/// Returns false when A is rank-deficient: R then has a diagonal entry at rounding
/// level, and back-substituting through it produces confident garbage -- the exact
/// defect `isFullRank` was fixed for. Rank-deficient inversion is the SVD's job, and
/// it is the one route that can honestly do it.
pub fn qrInverse(
    allocator: std.mem.Allocator,
    data: []const f64,
    m: usize,
    n: usize,
    out: []f64,
) !bool {
    if (n == 0 or m < n) return false;
    var f = try qr(allocator, data, m, n);
    defer f.deinit();
    if (!f.isFullRank()) return false;

    const scratch = try allocator.alloc(f64, m);
    defer allocator.free(scratch);
    const e = try allocator.alloc(f64, m);
    defer allocator.free(e);
    const col = try allocator.alloc(f64, n);
    defer allocator.free(col);

    // column j of the inverse is the solution of A x = e_j, which for a tall A is the
    // least-squares solution and therefore the pseudo-inverse's column
    for (0..m) |j| {
        @memset(e, 0);
        e[j] = 1;
        if (!qrSolve(&f, e, col, scratch)) return false;
        for (0..n) |i| out[i * m + j] = col[i];
    }
    return true;
}

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
pub const PowerError = error{ NotSymmetric, Singular, NotPositive, DidNotConverge };

/// A RAISED TO A REAL POWER, through its eigendecomposition: A^p = Q * L^p * Q'.
///
/// ── THE INVERSE IS ONE CASE OF THIS, NOT THE POINT OF IT ──
///
/// Undoing an eigendecomposition is `p = 1` -- reassemble Q L Q' and get A back. The
/// inverse is `p = -1`, invert each eigenvalue. But nothing about the machinery cares
/// which function is applied to the diagonal, and the two that earn their keep are the
/// ones no other decomposition here offers:
///
///     p =  0.5   the principal SQUARE ROOT
///     p = -0.5   WHITENING -- the transform that makes a covariance the identity
///
/// So this is the general `f(A) = Q f(L) Q'` with f a power, and the inverse arrives as
/// a special case rather than as the feature.
///
/// ── WHY THE SQUARE ROOT HERE IS NOT THE ONE CHOLESKY GIVES ──
///
/// `cholesky` also produces a "square root": L with L L' = A. This one is Q L^0.5 Q',
/// which is SYMMETRIC and positive semi-definite, and it is the one meant by "the"
/// square root -- unique for a PSD matrix, where Cholesky's factor is triangular and
/// one of many. Both square back to A; only one of them is itself a covariance-shaped
/// object you can hand to something expecting symmetry.
///
/// ── WHAT IT REFUSES, AND WHY THE RULE DEPENDS ON p ──
///
/// A negative power divides by eigenvalues, so any at rounding level make the answer
/// noise -- the same `negligibleThreshold` the pseudo-inverse and `rankOf` ask, so the
/// library cannot hold two opinions about which matrices are singular. A fractional
/// power takes roots, so a negative eigenvalue has no real answer at all. Refused
/// rather than returned as NaN, because a NaN propagates quietly and a refusal does not.
pub fn symmetricPower(
    allocator: std.mem.Allocator,
    data: []const f64,
    n: usize,
    p: f64,
    out: []f64,
) !void {
    var e = try eigenSymmetric(allocator, data, n);
    defer e.deinit();
    if (!e.symmetric) return PowerError.NotSymmetric;
    if (!e.converged) return PowerError.DidNotConverge;

    var largest: f64 = 0;
    for (e.values) |v| largest = @max(largest, @abs(v));
    const tol = negligibleThreshold(largest, n);

    const fractional = p != @trunc(p);
    const f = try allocator.alloc(f64, n);
    defer allocator.free(f);
    for (e.values, 0..) |v, j| {
        if (p < 0 and @abs(v) <= tol) return PowerError.Singular;
        if (fractional and v < -tol) return PowerError.NotPositive;
        const base = if (fractional and v < 0) 0 else v;
        f[j] = if (base == 0 and p > 0) 0 else std.math.pow(f64, base, p);
    }

    for (0..n) |i| {
        for (0..n) |j| {
            var acc: f64 = 0;
            for (0..n) |t| acc += e.vec(i, t) * f[t] * e.vec(j, t);
            out[i * n + j] = acc;
        }
    }
}

/// A REBUILT FROM ITS k LEADING EIGENPAIRS: A_k = Q_k L_k Q_k'.
///
/// The eigen counterpart of the SVD's low-rank approximation, and for a symmetric
/// matrix they coincide -- the singular values are the absolute eigenvalues. Kept
/// separate because a caller holding an eigendecomposition should not have to reach for
/// a different factorisation to ask this.
pub fn symmetricReconstruct(
    allocator: std.mem.Allocator,
    data: []const f64,
    n: usize,
    k: usize,
    out: []f64,
) !void {
    var e = try eigenSymmetric(allocator, data, n);
    defer e.deinit();
    if (!e.symmetric) return PowerError.NotSymmetric;

    const kk = @min(k, n);
    for (0..n) |i| {
        for (0..n) |j| {
            var acc: f64 = 0;
            for (0..kk) |t| acc += e.vec(i, t) * e.values[t] * e.vec(j, t);
            out[i * n + j] = acc;
        }
    }
}

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
/// THE BEST RANK-k APPROXIMATION: A_k = U_k * S_k * V_k'.
///
/// The other thing "inverting an SVD" can mean, and the direct counterpart of PCA's
/// reconstruction: keep the k largest singular values, discard the rest, multiply back.
///
/// Its error is an identity rather than a measurement. Eckart and Young proved this is
/// the CLOSEST rank-k matrix in the Frobenius norm, and that the distance is exactly
///
///     ||A - A_k||_F^2 = sum of the squares of the discarded singular values
///
/// which is the same shape of statement as PCA's "reconstruction error equals discarded
/// variance" -- and for the same reason, since PCA is the SVD of the centered matrix.
pub fn lowRankApproximation(
    allocator: std.mem.Allocator,
    data: []const f64,
    m: usize,
    n: usize,
    k: usize,
    out: []f64,
) !bool {
    var d = try svdAnyShape(allocator, data, m, n);
    defer d.deinit();

    const r = d.values.len;
    const kk = @min(k, r);
    @memset(out, 0);
    for (0..m) |i| {
        for (0..n) |j| {
            var acc: f64 = 0;
            for (0..kk) |t| acc += d.u[i * r + t] * d.values[t] * d.v[j * r + t];
            out[i * n + j] = acc;
        }
    }
    return d.converged;
}

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

// ─── low-rank reconstruction ─────────────────────────────────────────────────
//
// The pseudo-inverse already lived here (see above) and was already checked against all
// four Penrose conditions -- I wrote a second one before looking, which is the mistake
// the *Cp bridges taught and did not stick. What was genuinely missing is the OTHER
// sense of inverting an SVD: the rank-k reconstruction, the counterpart of PCA's.

test "ECKART-YOUNG: the truncation error is the discarded singular values" {
    const alloc = testing.allocator;
    const m = 6;
    const n = 4;
    var a: [m * n]f64 = undefined;
    var st: u64 = 31;
    for (&a) |*v| {
        st = st *% 6364136223846793005 +% 1442695040888963407;
        v.* = @as(f64, @floatFromInt(st >> 11)) / 9007199254740992.0 * 10 - 5;
    }

    var d = try svdAnyShape(alloc, &a, m, n);
    defer d.deinit();

    const back = try alloc.alloc(f64, m * n);
    defer alloc.free(back);

    // KEEPING EVERYTHING returns the matrix itself
    _ = try lowRankApproximation(alloc, &a, m, n, d.values.len, back);
    for (a, back) |x, y| try testing.expectApproxEqAbs(x, y, 1e-9);

    // AND EACH TRUNCATION COSTS EXACTLY the squares of the values it dropped. Eckart
    // and Young proved this is the closest rank-k matrix there is, and that the
    // distance is this and nothing else -- the same shape of statement as PCA's
    // "reconstruction error equals discarded variance", and for the same reason, since
    // PCA is the SVD of the centered matrix.
    for (1..d.values.len) |k| {
        _ = try lowRankApproximation(alloc, &a, m, n, k, back);
        var err: f64 = 0;
        for (a, back) |x, y| err += (x - y) * (x - y);
        var dropped: f64 = 0;
        for (k..d.values.len) |t| dropped += d.values[t] * d.values[t];
        try testing.expectApproxEqRel(dropped, err, 1e-8);
    }
}

// ─── the eigendecomposition inverse, which is one power among several ────────

/// a symmetric positive-definite matrix: B'B + I, which cannot fail to be one
fn spd(alloc: std.mem.Allocator, n: usize, seed: u64) ![]f64 {
    const b = try alloc.alloc(f64, n * n);
    defer alloc.free(b);
    var st: u64 = seed;
    for (b) |*v| {
        st = st *% 6364136223846793005 +% 1442695040888963407;
        v.* = @as(f64, @floatFromInt(st >> 11)) / 9007199254740992.0 * 2 - 1;
    }
    const a = try alloc.alloc(f64, n * n);
    for (0..n) |i| {
        for (0..n) |j| {
            var acc: f64 = 0;
            for (0..n) |t| acc += b[t * n + i] * b[t * n + j];
            a[i * n + j] = acc + (if (i == j) @as(f64, @floatFromInt(n)) else 0);
        }
    }
    return a;
}

test "POWER 1 REBUILDS THE MATRIX -- undoing the decomposition is p = 1" {
    const alloc = testing.allocator;
    const n = 5;
    const a = try spd(alloc, n, 17);
    defer alloc.free(a);
    const out = try alloc.alloc(f64, n * n);
    defer alloc.free(out);

    try symmetricPower(alloc, a, n, 1, out);
    for (a, out) |x, y| try testing.expectApproxEqAbs(x, y, 1e-9);

    // and rebuilding from every eigenpair is the same statement
    try symmetricReconstruct(alloc, a, n, n, out);
    for (a, out) |x, y| try testing.expectApproxEqAbs(x, y, 1e-9);
}

test "POWER -1 IS THE INVERSE, and agrees with the pseudo-inverse" {
    const alloc = testing.allocator;
    const n = 5;
    const a = try spd(alloc, n, 23);
    defer alloc.free(a);
    const inv = try alloc.alloc(f64, n * n);
    defer alloc.free(inv);
    try symmetricPower(alloc, a, n, -1, inv);

    // A * A^-1 = I, which is what "inverse" means
    for (0..n) |i| {
        for (0..n) |j| {
            var acc: f64 = 0;
            for (0..n) |t| acc += a[i * n + t] * inv[t * n + j];
            try testing.expectApproxEqAbs(if (i == j) @as(f64, 1) else 0, acc, 1e-8);
        }
    }

    // AND THE SAME ANSWER THE SVD PATH GIVES, by a different route -- Jacobi
    // eigenvectors here, one-sided Jacobi SVD there. Two roads to one number is the
    // check worth having, and it is available because the library has both.
    const pinv = try alloc.alloc(f64, n * n);
    defer alloc.free(pinv);
    _ = try pseudoInverse(alloc, a, n, n, pinv);
    for (inv, pinv) |x, y| try testing.expectApproxEqAbs(x, y, 1e-8);
}

test "POWER 0.5 IS THE SQUARE ROOT, and it is NOT the one Cholesky gives" {
    const alloc = testing.allocator;
    const n = 4;
    const a = try spd(alloc, n, 41);
    defer alloc.free(a);
    const r = try alloc.alloc(f64, n * n);
    defer alloc.free(r);
    try symmetricPower(alloc, a, n, 0.5, r);

    // the defining property: it squares back to A
    for (0..n) |i| {
        for (0..n) |j| {
            var acc: f64 = 0;
            for (0..n) |t| acc += r[i * n + t] * r[t * n + j];
            try testing.expectApproxEqAbs(a[i * n + j], acc, 1e-8);
        }
    }

    // AND IT IS SYMMETRIC, which is the difference that matters. Cholesky also gives a
    // "square root" -- L with L L' = A -- but that one is TRIANGULAR, and one of many.
    // This is the principal square root: symmetric, positive semi-definite, unique.
    // Both square back to A; only this one is itself a covariance-shaped object.
    for (0..n) |i| {
        for (i + 1..n) |j| try testing.expectApproxEqAbs(r[i * n + j], r[j * n + i], 1e-10);
    }
    var ch = try cholesky(alloc, a, n);
    defer ch.deinit();
    var triangular_somewhere = false;
    for (0..n) |i| {
        for (i + 1..n) |j| {
            if (@abs(ch.l[i * n + j] - ch.l[j * n + i]) > 1e-6) triangular_somewhere = true;
        }
    }
    try testing.expect(triangular_somewhere);
}

test "POWER -0.5 WHITENS: it turns a covariance into the identity" {
    const alloc = testing.allocator;
    const n = 4;
    const a = try spd(alloc, n, 7);
    defer alloc.free(a);
    const w = try alloc.alloc(f64, n * n);
    defer alloc.free(w);
    try symmetricPower(alloc, a, n, -0.5, w);

    // W A W = I. This is what whitening IS -- the transform under which a covariance
    // becomes the identity, so every direction has unit variance and none correlate.
    // It is the operation no other decomposition here provides, and the reason a
    // general power is worth more than an inverse.
    const t = try alloc.alloc(f64, n * n);
    defer alloc.free(t);
    for (0..n) |i| {
        for (0..n) |j| {
            var acc: f64 = 0;
            for (0..n) |q| acc += w[i * n + q] * a[q * n + j];
            t[i * n + j] = acc;
        }
    }
    for (0..n) |i| {
        for (0..n) |j| {
            var acc: f64 = 0;
            for (0..n) |q| acc += t[i * n + q] * w[q * n + j];
            try testing.expectApproxEqAbs(if (i == j) @as(f64, 1) else 0, acc, 1e-8);
        }
    }
}

test "the powers compose, which is the property that says they are real powers" {
    const alloc = testing.allocator;
    const n = 4;
    const a = try spd(alloc, n, 3);
    defer alloc.free(a);
    const half = try alloc.alloc(f64, n * n);
    defer alloc.free(half);
    const quarter = try alloc.alloc(f64, n * n);
    defer alloc.free(quarter);
    try symmetricPower(alloc, a, n, 0.5, half);
    try symmetricPower(alloc, a, n, 0.25, quarter);

    // (A^0.25)^2 = A^0.5 -- a fractional power that did not really exponentiate would
    // pass the squares-back-to-A test and fail this one
    for (0..n) |i| {
        for (0..n) |j| {
            var acc: f64 = 0;
            for (0..n) |t| acc += quarter[i * n + t] * quarter[t * n + j];
            try testing.expectApproxEqAbs(half[i * n + j], acc, 1e-8);
        }
    }
}

test "REFUSED RATHER THAN RETURNED AS NaN" {
    const alloc = testing.allocator;
    const n = 3;
    const out = try alloc.alloc(f64, n * n);
    defer alloc.free(out);

    // a fractional power of a matrix with a NEGATIVE eigenvalue has no real answer
    const indefinite = [_]f64{ 1, 2, 0, 2, 1, 0, 0, 0, 1 }; // eigenvalues 3, 1, -1
    try testing.expectError(PowerError.NotPositive, symmetricPower(alloc, &indefinite, n, 0.5, out));
    // but an integer power of the same matrix is perfectly well defined
    try symmetricPower(alloc, &indefinite, n, -1, out);

    // a negative power of a SINGULAR matrix divides by rounding
    const singular = [_]f64{ 1, 1, 0, 1, 1, 0, 0, 0, 2 };
    try testing.expectError(PowerError.Singular, symmetricPower(alloc, &singular, n, -1, out));

    // and a matrix that is not symmetric has no eigendecomposition of this kind
    const asym = [_]f64{ 1, 2, 3, 0, 1, 4, 0, 0, 1 };
    try testing.expectError(PowerError.NotSymmetric, symmetricPower(alloc, &asym, n, 1, out));

    // NaN would propagate quietly through everything downstream; a refusal does not
}

test "truncating the eigendecomposition matches truncating the SVD" {
    const alloc = testing.allocator;
    const n = 5;
    const a = try spd(alloc, n, 61);
    defer alloc.free(a);
    const eig = try alloc.alloc(f64, n * n);
    defer alloc.free(eig);
    const svd_out = try alloc.alloc(f64, n * n);
    defer alloc.free(svd_out);

    // For a SYMMETRIC POSITIVE-DEFINITE matrix the singular values ARE the eigenvalues,
    // so the two truncations must agree exactly. They come from different algorithms --
    // Jacobi eigenvectors against a one-sided Jacobi SVD -- so agreeing is a statement
    // about the mathematics rather than about shared code.
    for (1..n) |k| {
        try symmetricReconstruct(alloc, a, n, k, eig);
        _ = try lowRankApproximation(alloc, a, n, n, k, svd_out);
        for (eig, svd_out) |x, y| try testing.expectApproxEqAbs(x, y, 1e-7);
    }
}

// ─── the Cholesky inverse ────────────────────────────────────────────────────

test "THREE DECOMPOSITIONS, ONE INVERSE" {
    const alloc = testing.allocator;
    const n = 5;
    const a = try spd(alloc, n, 29);
    defer alloc.free(a);

    const chol = try alloc.alloc(f64, n * n);
    defer alloc.free(chol);
    const eig = try alloc.alloc(f64, n * n);
    defer alloc.free(eig);
    const svd_inv = try alloc.alloc(f64, n * n);
    defer alloc.free(svd_inv);

    try testing.expect(try choleskyInverse(alloc, a, n, chol));
    try symmetricPower(alloc, a, n, -1, eig);
    _ = try pseudoInverse(alloc, a, n, n, svd_inv);

    // A triangular factorisation, a Jacobi eigendecomposition and a one-sided Jacobi
    // SVD. Three genuinely different algorithms, no shared code below the matrix
    // itself, and one answer -- which is a statement about the mathematics rather than
    // about any of the implementations.
    for (chol, eig) |x, y| try testing.expectApproxEqAbs(x, y, 1e-8);
    for (chol, svd_inv) |x, y| try testing.expectApproxEqAbs(x, y, 1e-8);

    // and it is the inverse, not merely three agreeing numbers
    for (0..n) |i| {
        for (0..n) |j| {
            var acc: f64 = 0;
            for (0..n) |t| acc += a[i * n + t] * chol[t * n + j];
            try testing.expectApproxEqAbs(if (i == j) @as(f64, 1) else 0, acc, 1e-8);
        }
    }
}

test "L INVERSE WHITENS TOO -- and whitening is NOT unique" {
    const alloc = testing.allocator;
    const n = 4;
    const a = try spd(alloc, n, 13);
    defer alloc.free(a);

    const li = try alloc.alloc(f64, n * n);
    defer alloc.free(li);
    try testing.expect(try choleskyFactorInverse(alloc, a, n, li));

    // A = L L', so L^-1 A L^-1' = I. That is the DEFINITION of a whitener.
    const t = try alloc.alloc(f64, n * n);
    defer alloc.free(t);
    for (0..n) |i| {
        for (0..n) |j| {
            var acc: f64 = 0;
            for (0..n) |q| acc += li[i * n + q] * a[q * n + j];
            t[i * n + j] = acc;
        }
    }
    for (0..n) |i| {
        for (0..n) |j| {
            var acc: f64 = 0;
            for (0..n) |q| acc += t[i * n + q] * li[j * n + q]; // times L^-1 TRANSPOSED
            try testing.expectApproxEqAbs(if (i == j) @as(f64, 1) else 0, acc, 1e-8);
        }
    }

    // AND IT IS A DIFFERENT MATRIX FROM symmetricPower(-0.5), which also whitens.
    //
    // Neither is more correct. Whitening is not unique -- any W with W A W' = I
    // qualifies, and if W works then so does QW for any orthogonal Q. The eigen route
    // picks the SYMMETRIC whitener; this one picks the TRIANGULAR one, which is cheaper
    // and is what a sampler wants, since it turns independent normals into correlated
    // ones with a single multiply.
    //
    // Exactly the distinction between the two square roots one level up, and for the
    // same reason: "give me something that undoes A" has many answers.
    const sym = try alloc.alloc(f64, n * n);
    defer alloc.free(sym);
    try symmetricPower(alloc, a, n, -0.5, sym);

    var differ = false;
    for (li, sym) |x, y| {
        if (@abs(x - y) > 1e-6) differ = true;
    }
    try testing.expect(differ);

    // the triangular one is triangular, which is how you can tell them apart at sight
    for (0..n) |i| {
        for (i + 1..n) |j| try testing.expectApproxEqAbs(@as(f64, 0), li[i * n + j], 1e-12);
    }
}

test "L L' rebuilds A, which is the whole of undoing this decomposition" {
    const alloc = testing.allocator;
    const n = 4;
    const a = try spd(alloc, n, 71);
    defer alloc.free(a);

    var f = try cholesky(alloc, a, n);
    defer f.deinit();
    try testing.expect(f.positive_definite);

    for (0..n) |i| {
        for (0..n) |j| {
            var acc: f64 = 0;
            for (0..n) |t| acc += f.at(i, t) * f.at(j, t);
            try testing.expectApproxEqAbs(a[i * n + j], acc, 1e-9);
        }
    }
}

test "NOT POSITIVE DEFINITE MEANS THERE IS NO CHOLESKY INVERSE TO HAVE" {
    const alloc = testing.allocator;
    const n = 3;
    const out = try alloc.alloc(f64, n * n);
    defer alloc.free(out);

    // eigenvalues 3, 1, -1: symmetric, invertible, and NOT positive definite
    const indefinite = [_]f64{ 1, 2, 0, 2, 1, 0, 0, 0, 1 };
    try testing.expect(!try choleskyInverse(alloc, &indefinite, n, out));
    try testing.expect(!try choleskyFactorInverse(alloc, &indefinite, n, out));

    // AND THE REFUSAL IS NOT A LIMITATION -- this matrix HAS an inverse, and the other
    // two routes return it. What it does not have is a real triangular factor, so
    // "invert it through its Cholesky decomposition" is a request with no referent.
    // The factorisation discovers this on its own, at the first non-positive pivot,
    // which is why Cholesky doubles as a positive-definiteness test.
    try symmetricPower(alloc, &indefinite, n, -1, out);
    var any: f64 = 0;
    for (out) |v| any += @abs(v);
    try testing.expect(any > 0);
}

// ─── the QR inverse ──────────────────────────────────────────────────────────

test "QR INVERTS WHAT THE OTHER FAST ROUTES REFUSE" {
    const alloc = testing.allocator;
    const n = 4;
    // a general invertible matrix: NOT symmetric, so neither Cholesky nor the
    // eigendecomposition will touch it
    const a = [_]f64{
        4, 1, 2, 0,
        0, 3, 1, 5,
        2, 0, 6, 1,
        1, 2, 0, 4,
    };
    const out = try alloc.alloc(f64, n * n);
    defer alloc.free(out);
    const chol = try alloc.alloc(f64, n * n);
    defer alloc.free(chol);

    // THE GAP, DEMONSTRATED. Both of the fast routes decline this matrix, and until QR
    // the only thing left was the SVD.
    // AND CHOLESKY REFUSES IT TOO -- which it did NOT before this commit. It reads
    // only the lower triangle, so a non-symmetric matrix factored happily and L L'
    // came back differing from A by up to 3.0, with positive_definite reporting TRUE.
    // Found here, by asking a fast route to decline a matrix and watching it accept.
    try testing.expect(!try choleskyInverse(alloc, &a, n, chol));
    try testing.expectError(PowerError.NotSymmetric, symmetricPower(alloc, &a, n, -1, chol));

    // QR does not care about symmetry
    try testing.expect(try qrInverse(alloc, &a, n, n, out));
    for (0..n) |i| {
        for (0..n) |j| {
            var acc: f64 = 0;
            for (0..n) |t| acc += a[i * n + t] * out[t * n + j];
            try testing.expectApproxEqAbs(if (i == j) @as(f64, 1) else 0, acc, 1e-9);
        }
    }

    // and it is the same inverse the SVD route gives -- a fourth algorithm agreeing
    const svd_inv = try alloc.alloc(f64, n * n);
    defer alloc.free(svd_inv);
    _ = try pseudoInverse(alloc, &a, n, n, svd_inv);
    for (out, svd_inv) |x, y| try testing.expectApproxEqAbs(x, y, 1e-8);
}

test "FOR A TALL MATRIX THE SAME FORMULA IS THE PSEUDO-INVERSE" {
    const alloc = testing.allocator;
    const m = 6;
    const n = 3;
    const a = [_]f64{
        1, 1,  1,
        1, 2,  4,
        1, 3,  9,
        1, 4, 16,
        1, 5, 25,
        1, 6, 36,
    };
    const qri = try alloc.alloc(f64, n * m);
    defer alloc.free(qri);
    const svdi = try alloc.alloc(f64, n * m);
    defer alloc.free(svdi);

    try testing.expect(try qrInverse(alloc, &a, m, n, qri));
    _ = try pseudoInverse(alloc, &a, m, n, svdi);

    // R^-1 Q' IS the Moore-Penrose inverse when A has full column rank -- which is why
    // leastSquares has always been a QR solve underneath. Checked against the SVD's
    // answer rather than restated as a claim.
    for (qri, svdi) |x, y| try testing.expectApproxEqAbs(x, y, 1e-8);

    // and applying it to a right-hand side gives what leastSquares gives
    const b = [_]f64{ 2.1, 3.9, 6.2, 7.8, 10.1, 12.2 };
    var x_op: [n]f64 = .{ 0, 0, 0 };
    for (0..n) |i| {
        var acc: f64 = 0;
        for (0..m) |t| acc += qri[i * m + t] * b[t];
        x_op[i] = acc;
    }
    var x_ls: [n]f64 = .{ 0, 0, 0 };
    try testing.expect(try leastSquares(alloc, &a, m, n, &b, &x_ls));
    for (x_op, x_ls) |p2, q2| try testing.expectApproxEqAbs(q2, p2, 1e-8);
}

test "RANK-DEFICIENT IS REFUSED HERE AND ANSWERED BY THE SVD" {
    const alloc = testing.allocator;
    const m = 4;
    const n = 3;
    // column 3 is column 1 plus column 2
    const a = [_]f64{
        1, 2, 3,
        2, 1, 3,
        3, 5, 8,
        4, 1, 5,
    };
    const out = try alloc.alloc(f64, n * m);
    defer alloc.free(out);

    // Back-substituting through a diagonal entry at rounding level produces confident
    // garbage -- the exact defect isFullRank was fixed for, where a 200x4 design matrix
    // returned coefficients around -9.7e12 and presented them as a fit. So this
    // declines, and says so by returning false rather than by returning numbers.
    try testing.expect(!try qrInverse(alloc, &a, m, n, out));

    // AND THE SVD ANSWERS IT, which is the division of labour: a rank-deficient system
    // has infinitely many least-squares solutions, and only the minimum-norm one is a
    // principled choice. That needs singular values, not a triangular factor.
    _ = try pseudoInverse(alloc, &a, m, n, out);
    try testing.expectEqual(@as(usize, 2), try rankOf(alloc, &a, m, n));
    var any: f64 = 0;
    for (out) |v| any += @abs(v);
    try testing.expect(any > 0);
}

test "CHOLESKY MUST NOT FACTOR A MATRIX THAT HAS NO CHOLESKY FACTOR" {
    const alloc = testing.allocator;
    const n = 4;
    // lower triangle looks perfectly positive-definite; the matrix is not symmetric
    const a = [_]f64{
        4, 1, 2, 0,
        0, 3, 1, 5,
        2, 0, 6, 1,
        1, 2, 0, 4,
    };

    // THE DEFECT THIS PINS. The algorithm reads only the LOWER triangle, so before the
    // symmetry check it factored this happily: positive_definite came back TRUE and
    // L L' differed from A by up to 3.0. Every caller downstream believed it --
    // choleskyInverse returned a matrix that was not A's inverse, and the
    // positive-definiteness test called a non-symmetric matrix positive definite, which
    // is not even a property such a matrix can have.
    //
    // Same shape as the isFullRank defect documented in this file: a condition the
    // arithmetic never needed to check, and a confident wrong answer downstream.
    var f = try cholesky(alloc, &a, n);
    defer f.deinit();
    try testing.expect(!f.positive_definite);

    const out = try alloc.alloc(f64, n * n);
    defer alloc.free(out);
    try testing.expect(!try choleskyInverse(alloc, &a, n, out));
    try testing.expect(!try choleskyFactorInverse(alloc, &a, n, out));

    // and a genuinely symmetric positive-definite matrix still passes, so the check
    // tightened the right thing rather than everything
    const good = try spd(alloc, n, 91);
    defer alloc.free(good);
    var g = try cholesky(alloc, good, n);
    defer g.deinit();
    try testing.expect(g.positive_definite);
}

// ─── the LU inverse ──────────────────────────────────────────────────────────

/// the n*n Hilbert matrix, the standard ill-conditioned example: H[i][j] = 1/(i+j+1)
fn hilbert(alloc: std.mem.Allocator, n: usize) ![]f64 {
    const h = try alloc.alloc(f64, n * n);
    for (0..n) |i| {
        for (0..n) |j| {
            h[i * n + j] = 1.0 / @as(f64, @floatFromInt(i + j + 1));
        }
    }
    return h;
}

/// max |A X - I| over all entries -- how far a claimed inverse really is from one
fn inverseResidual(a: []const f64, x: []const f64, n: usize) f64 {
    var worst: f64 = 0;
    for (0..n) |i| {
        for (0..n) |j| {
            var acc: f64 = 0;
            for (0..t_unused(n)) |t| acc += a[i * n + t] * x[t * n + j];
            const want: f64 = if (i == j) 1 else 0;
            worst = @max(worst, @abs(acc - want));
        }
    }
    return worst;
}

inline fn t_unused(n: usize) usize {
    return n;
}

test "LU INVERTS A GENERAL SQUARE MATRIX, and agrees with every other route" {
    const alloc = testing.allocator;
    const n = 4;
    // not symmetric, so Cholesky and the eigen route both decline it
    const a = [_]f64{
        4, 1, 2, 0,
        0, 3, 1, 5,
        2, 0, 6, 1,
        1, 2, 0, 4,
    };
    const lu_inv = try alloc.alloc(f64, n * n);
    defer alloc.free(lu_inv);
    const qr_inv = try alloc.alloc(f64, n * n);
    defer alloc.free(qr_inv);
    const svd_inv = try alloc.alloc(f64, n * n);
    defer alloc.free(svd_inv);

    try testing.expect(try luInverse(alloc, &a, n, lu_inv));
    try testing.expect(try qrInverse(alloc, &a, n, n, qr_inv));
    _ = try pseudoInverse(alloc, &a, n, n, svd_inv);

    try testing.expect(inverseResidual(&a, lu_inv, n) < 1e-12);
    for (lu_inv, qr_inv) |x, y| try testing.expectApproxEqAbs(x, y, 1e-9);
    for (lu_inv, svd_inv) |x, y| try testing.expectApproxEqAbs(x, y, 1e-8);
}

test "LU IS SQUARE-ONLY, which is why least squares stays QR's" {
    const alloc = testing.allocator;
    // a tall matrix has no LU inverse in this sense -- there is nothing to solve
    // A x = e_j for when e_j has more rows than x has entries
    const m = 6;
    const n = 3;
    const a = try alloc.alloc(f64, m * n);
    defer alloc.free(a);
    for (0..m) |i| {
        for (0..n) |j| a[i * n + j] = std.math.pow(f64, @floatFromInt(i + 1), @floatFromInt(j));
    }
    const out = try alloc.alloc(f64, n * m);
    defer alloc.free(out);

    // QR answers it, as the pseudo-inverse
    try testing.expect(try qrInverse(alloc, a, m, n, out));
    // and the division of labour is the point: LU takes the square case faster, QR
    // takes every shape it can and is steadier where it matters
}

test "A SINGULAR MATRIX IS REFUSED, not back-substituted through" {
    const alloc = testing.allocator;
    const n = 3;
    // row 3 = row 1 + row 2
    const a = [_]f64{ 1, 2, 3, 4, 5, 6, 5, 7, 9 };
    const out = try alloc.alloc(f64, n * n);
    defer alloc.free(out);

    // FOUND BY THIS TEST. `decompose` tested its pivot against EXACTLY zero, so this
    // matrix -- row 3 is row 1 plus row 2, rank 2 of 3 -- factored with `singular`
    // FALSE, and luInverse back-substituted through a pivot at rounding level and
    // returned a matrix it called an inverse. The third instance of that defect in this
    // file; see the note in `decompose`.
    try testing.expect(!try luInverse(alloc, &a, n, out));
    // and the SVD still answers, with the minimum-norm pseudo-inverse -- the same
    // division of labour as everywhere else in this family
    _ = try pseudoInverse(alloc, &a, n, n, out);
    try testing.expectEqual(@as(usize, 2), try rankOf(alloc, &a, n, n));
}

test "ON AN ILL-CONDITIONED MATRIX, LU HOLDS UP -- and I had assumed otherwise" {
    const alloc = testing.allocator;
    const n = 9;
    const h = try hilbert(alloc, n);
    defer alloc.free(h);

    const lu_inv = try alloc.alloc(f64, n * n);
    defer alloc.free(lu_inv);
    const qr_inv = try alloc.alloc(f64, n * n);
    defer alloc.free(qr_inv);
    _ = try luInverse(alloc, h, n, lu_inv);
    _ = try qrInverse(alloc, h, n, n, qr_inv);

    const lu_err = inverseResidual(h, lu_inv, n);
    const qr_err = inverseResidual(h, qr_inv, n);

    // MEASURED on the 9x9 Hilbert matrix, whose condition number is around 1e12:
    //
    //     LU   3.81e-6
    //     QR   8.34e-6
    //
    // I WROTE THIS TEST TO ASSERT THE OPPOSITE. "QR is more stable than LU" is the rule
    // of thumb, and it is a rule about LEAST SQUARES, where the alternative is forming
    // A'A and squaring the condition number. For inverting a square matrix that
    // alternative never arises, and LU with partial pivoting is famously well behaved
    // -- here it is twice as accurate as QR, not half.
    //
    // So the reason to keep both is NOT stability. It is SHAPE: QR takes a tall matrix
    // and LU cannot, which is why least squares stays QR's. That is a better reason
    // than the one I was about to write down, and it is the one that is true.
    try testing.expect(lu_err <= qr_err);

    // and both lose about six digits, which is what a condition number of 1e12 means.
    // No algorithm recovers information the matrix does not carry, and a test claiming
    // otherwise would be pinning luck.
    try testing.expect(lu_err > 1e-8);
    try testing.expect(qr_err > 1e-8);
}

test "parallel decompose is bit-identical to serial, pivots included" {
    const alloc = std.testing.allocator;
    const n = 96;
    const data = try alloc.alloc(f64, n * n);
    defer alloc.free(data);
    var seed: u64 = 11;
    for (data, 0..) |*v, idx| {
        seed = seed *% 6364136223846793005 +% 1442695040888963407;
        v.* = @as(f64, @floatFromInt((seed >> 33) % 1000)) / 999.0 +
            (if (idx / n == idx % n) @as(f64, 3.0) else 0.0);
    }

    defer lu_gate.reset();

    lu_gate.overrideUsize(std.math.maxInt(usize)); // force serial
    var f_ser = try decompose(alloc, data, n);
    defer f_ser.deinit();

    lu_gate.overrideUsize(8); // force parallel (min-rows tail still applies)
    var f_par = try decompose(alloc, data, n);
    defer f_par.deinit();

    try std.testing.expectEqual(f_ser.singular, f_par.singular);
    try std.testing.expectEqual(f_ser.sign, f_par.sign);
    for (f_ser.perm, f_par.perm) |x, y| try std.testing.expectEqual(x, y);
    for (f_ser.lu, f_par.lu) |x, y| try std.testing.expect(x == y);

    // And a SINGULAR case through the parallel path: row 3 = row 1 + row 2
    // must be flagged, identically to serial.
    for (data, 0..) |*v, idx| {
        const r = idx / n;
        const c = idx % n;
        if (r == 2) v.* = data[0 * n + c] + data[1 * n + c];
    }
    lu_gate.overrideUsize(std.math.maxInt(usize));
    var s_ser = try decompose(alloc, data, n);
    defer s_ser.deinit();
    lu_gate.overrideUsize(8);
    var s_par = try decompose(alloc, data, n);
    defer s_par.deinit();
    try std.testing.expect(s_ser.singular);
    try std.testing.expectEqual(s_ser.singular, s_par.singular);
    for (s_ser.lu, s_par.lu) |x, y| try std.testing.expect(x == y);
}
