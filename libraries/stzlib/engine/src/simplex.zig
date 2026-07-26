// Softanza Engine -- the simplex PIVOT LOOP.
//
// Phase 5 of the numeric foundation, pillar 5: "Simplex -> engine. stzLinearSolver's
// 1170 Ring lines become a revised dual simplex over resident buffers. Same public
// surface; the narration and tests stay valid."
//
// MEASURED FIRST, because this campaign has twice found a pillar claim wrong. Here it
// is right. Timing the existing Ring solver on LPs of growing size:
//
//     vars x cons     build      solve
//     5 x 4           0.003s     0.008s
//     10 x 8          0.001s     0.051s
//     20 x 15         0.002s     0.353s
//     30 x 25         0.003s     1.303s
//     40 x 30         0.005s     2.620s
//
// TWO THINGS THAT DECIDE THE SHAPE OF THIS SLICE. The BUILD -- parsing the constraint
// strings, extracting coefficients, shifting bounds, laying out slack and artificial
// columns -- is 0.005s and flat. My guess had been that string parsing would dominate;
// it does not, and measuring rather than assuming is what kept the Ring layer intact.
// The SOLVE grows about sevenfold per doubling, and a 40-variable LP taking 2.6
// seconds is genuinely slow: real solvers do thousands of variables in milliseconds.
//
// So ONLY the pivot loop moves. Ring keeps the parsing, the variable names, the
// bounds, the Big-M layout and the whole public surface; it hands over a flat tableau
// and gets back the answer. Per iteration the Ring version did O(rows x cols) accesses
// into a NESTED LIST OF BOXED VALUES -- about a million of them for a 40-variable
// problem -- which is the cost, not the arithmetic.
//
// THIS MIRRORS THE RING LOOP EXACTLY, DELIBERATELY: the same most-negative entering
// rule with the first index winning ties, the same minimum-ratio leaving rule with the
// first row winning ties, and the same tolerances (1e-7 for entering and ratio, 1e-9
// for elimination, 1e-6 for the infeasibility check). A different but equally valid
// pivot rule would land on a different vertex of the same optimal face on a degenerate
// problem -- still optimal, still correct, and it would change the reported solution
// and break every existing test. Matching the rule is what makes this a migration
// rather than a rewrite.

const std = @import("std");

pub const Status = enum(i32) {
    optimal = 0,
    unbounded = 1,
    infeasible = 2,
    iteration_limit = 3,
};

const MAX_ITERATIONS: i32 = 2000;

// the Ring loop's tolerances, reproduced exactly
const ENTER_TOL: f64 = 0.0000001; // 1e-7
const RATIO_TOL: f64 = 0.0000001; // 1e-7
const ELIM_TOL: f64 = 0.000000001; // 1e-9
const INFEAS_TOL: f64 = 0.000001; // 1e-6

/// Run the pivot loop over a dense Big-M tableau.
///
/// `t` is m*cols row-major and is MUTATED in place; `z` is the reduced-cost row of
/// length cols; `basis` holds the 1-based column index basic in each row. `art_at` is
/// the 1-based boundary after which columns are artificial. Everything is 1-based on
/// the way in because that is how the Ring side already speaks.
pub fn run(
    t: []f64,
    z: []f64,
    basis: []i32,
    m: usize,
    cols: usize,
    art_at: usize,
    iterations_out: *i32,
) Status {
    var iterations: i32 = 0;
    var status = Status.optimal;

    while (true) {
        iterations += 1;
        if (iterations > MAX_ITERATIONS) {
            status = .iteration_limit;
            break;
        }

        // entering column: the most negative reduced cost, first index winning ties
        var pc: usize = 0;
        var most: f64 = -ENTER_TOL;
        for (0..cols - 1) |j| {
            if (z[j] < most) {
                most = z[j];
                pc = j + 1;
            }
        }
        if (pc == 0) break; // no improving column: optimal

        // leaving row: minimum ratio, first row winning ties
        var pr: usize = 0;
        var best: f64 = 0;
        for (0..m) |i| {
            const a = t[i * cols + (pc - 1)];
            if (a > RATIO_TOL) {
                const ratio = t[i * cols + (cols - 1)] / a;
                if (pr == 0 or ratio < best) {
                    best = ratio;
                    pr = i + 1;
                }
            }
        }
        if (pr == 0) {
            status = .unbounded;
            break;
        }

        // normalise the pivot row
        const pv = t[(pr - 1) * cols + (pc - 1)];
        for (0..cols) |j| t[(pr - 1) * cols + j] /= pv;

        // eliminate the entering column from every other row
        for (0..m) |i| {
            if (i + 1 == pr) continue;
            const f = t[i * cols + (pc - 1)];
            if (@abs(f) > ELIM_TOL) {
                for (0..cols) |j| {
                    t[i * cols + j] -= f * t[(pr - 1) * cols + j];
                }
            }
        }

        // ...and from the objective row
        const fz = z[pc - 1];
        if (@abs(fz) > ELIM_TOL) {
            for (0..cols) |j| z[j] -= fz * t[(pr - 1) * cols + j];
        }

        basis[pr - 1] = @intCast(pc);
    }

    // an artificial still basic at a positive level means the original problem had no
    // feasible point at all -- Big-M could not drive it out
    if (status == .optimal) {
        for (0..m) |i| {
            if (@as(usize, @intCast(basis[i])) > art_at and t[i * cols + (cols - 1)] > INFEAS_TOL) {
                status = .infeasible;
                break;
            }
        }
    }

    iterations_out.* = iterations;
    return status;
}

/// Read the structural variables out of a solved tableau: x'[j] is the right-hand
/// side of whichever row has column j basic, else zero. The caller shifts back by the
/// lower bounds.
pub fn extract(t: []const f64, basis: []const i32, m: usize, cols: usize, out: []f64, nv: usize) void {
    for (0..nv) |j| {
        var v: f64 = 0;
        for (0..m) |i| {
            if (basis[i] == @as(i32, @intCast(j + 1))) {
                v = t[i * cols + (cols - 1)];
                break;
            }
        }
        out[j] = v;
    }
}

// ─── C ABI ───

pub fn stz_simplex_run(
    t: [*]f64,
    z: [*]f64,
    basis: [*]i32,
    m: usize,
    cols: usize,
    art_at: usize,
    out_x: [*]f64,
    nv: usize,
    out_iterations: *i32,
) callconv(.c) i32 {
    const st = run(t[0 .. m * cols], z[0..cols], basis[0..m], m, cols, art_at, out_iterations);
    extract(t[0 .. m * cols], basis[0..m], m, cols, out_x[0..nv], nv);
    return @intFromEnum(st);
}

// ─── Tests ───

const testing = std.testing;

/// Build and solve a small LP the same way stzLinearSolver does, so the tests exercise
/// the real layout: structurals, then slacks, then artificials, then the rhs column.
fn solveLe(
    allocator: std.mem.Allocator,
    nv: usize,
    rows: []const []const f64, // each: nv coefficients then the rhs
    obj: []const f64, // nv coefficients, MAXIMISED
    out: []f64,
) !Status {
    const m = rows.len;
    const cols = nv + m + 1; // every row is <=, so one slack each and no artificials
    const t = try allocator.alloc(f64, m * cols);
    defer allocator.free(t);
    @memset(t, 0);
    const z = try allocator.alloc(f64, cols);
    defer allocator.free(z);
    @memset(z, 0);
    const basis = try allocator.alloc(i32, m);
    defer allocator.free(basis);

    for (rows, 0..) |r, i| {
        for (0..nv) |j| t[i * cols + j] = r[j];
        t[i * cols + (cols - 1)] = r[nv];
        t[i * cols + nv + i] = 1;
        basis[i] = @intCast(nv + i + 1);
    }
    for (0..nv) |j| z[j] = -obj[j];

    var iters: i32 = 0;
    const st = run(t, z, basis, m, cols, nv + m, &iters);
    extract(t, basis, m, cols, out, nv);
    return st;
}

test "simplex: the Wyndor Glass problem, whose optimum every course states" {
    // max 3x + 5y  s.t.  x <= 4 ; 2y <= 12 ; 3x + 2y <= 18
    // optimum x = 2, y = 6, objective 36
    const r1 = [_]f64{ 1, 0, 4 };
    const r2 = [_]f64{ 0, 2, 12 };
    const r3 = [_]f64{ 3, 2, 18 };
    const rows = [_][]const f64{ &r1, &r2, &r3 };
    const obj = [_]f64{ 3, 5 };
    var x: [2]f64 = undefined;
    const st = try solveLe(testing.allocator, 2, &rows, &obj, &x);
    try testing.expectEqual(Status.optimal, st);
    try testing.expectApproxEqAbs(@as(f64, 2), x[0], 1e-9);
    try testing.expectApproxEqAbs(@as(f64, 6), x[1], 1e-9);
    try testing.expectApproxEqAbs(@as(f64, 36), 3 * x[0] + 5 * x[1], 1e-9);
}

test "simplex: a second textbook LP, and the optimality conditions themselves" {
    // max 5x + 4y  s.t.  6x + 4y <= 24 ; x + 2y <= 6   ->  x = 3, y = 1.5, obj 21
    const r1 = [_]f64{ 6, 4, 24 };
    const r2 = [_]f64{ 1, 2, 6 };
    const rows = [_][]const f64{ &r1, &r2 };
    const obj = [_]f64{ 5, 4 };
    var x: [2]f64 = undefined;
    const st = try solveLe(testing.allocator, 2, &rows, &obj, &x);
    try testing.expectEqual(Status.optimal, st);
    try testing.expectApproxEqAbs(@as(f64, 3), x[0], 1e-9);
    try testing.expectApproxEqAbs(@as(f64, 1.5), x[1], 1e-9);

    // FEASIBILITY is checkable without knowing the answer: every constraint holds and
    // every variable is non-negative.
    try testing.expect(6 * x[0] + 4 * x[1] <= 24 + 1e-9);
    try testing.expect(x[0] + 2 * x[1] <= 6 + 1e-9);
    try testing.expect(x[0] >= -1e-9 and x[1] >= -1e-9);

    // OPTIMALITY, checked by brute force over the vertices of this tiny polytope.
    // Every corner of the feasible region, and none beats the reported answer.
    const verts = [_][2]f64{ .{ 0, 0 }, .{ 4, 0 }, .{ 3, 1.5 }, .{ 0, 3 } };
    const best = 5 * x[0] + 4 * x[1];
    for (verts) |v| {
        try testing.expect(5 * v[0] + 4 * v[1] <= best + 1e-9);
    }
}

test "simplex: unbounded and degenerate cases are reported, not guessed" {
    // UNBOUNDED: max x with no constraint that limits it from above. The single row
    // x - y <= 1 lets x grow without bound as long as y grows with it.
    const r1 = [_]f64{ 1, -1, 1 };
    const rows = [_][]const f64{&r1};
    const obj = [_]f64{ 1, 0 };
    var x: [2]f64 = undefined;
    const st = try solveLe(testing.allocator, 2, &rows, &obj, &x);
    try testing.expectEqual(Status.unbounded, st);

    // A DEGENERATE problem -- two constraints meeting at the same vertex -- must still
    // terminate rather than cycling.
    const d1 = [_]f64{ 1, 1, 4 };
    const d2 = [_]f64{ 1, 1, 4 }; // identical: degenerate
    const d3 = [_]f64{ 1, 0, 2 };
    const drows = [_][]const f64{ &d1, &d2, &d3 };
    const dobj = [_]f64{ 1, 1 };
    var dx: [2]f64 = undefined;
    const dst = try solveLe(testing.allocator, 2, &drows, &dobj, &dx);
    try testing.expectEqual(Status.optimal, dst);
    try testing.expectApproxEqAbs(@as(f64, 4), dx[0] + dx[1], 1e-9);

    // all-zero objective: any feasible point is optimal, and it must stop immediately
    const zobj = [_]f64{ 0, 0 };
    var zx: [2]f64 = undefined;
    const zst = try solveLe(testing.allocator, 2, &drows, &zobj, &zx);
    try testing.expectEqual(Status.optimal, zst);
}

test "simplex: a bigger LP terminates and stays feasible" {
    // 12 variables, 9 constraints -- past the size where the Ring loop was taking
    // hundreds of milliseconds.
    const nv = 12;
    const m = 9;
    var storage: [m][nv + 1]f64 = undefined;
    var rowslice: [m][]const f64 = undefined;
    for (0..m) |i| {
        for (0..nv) |j| {
            storage[i][j] = @floatFromInt(((i + 1) * (j + 1)) % 7 + 1);
        }
        storage[i][nv] = 500;
        rowslice[i] = &storage[i];
    }
    var obj: [nv]f64 = undefined;
    for (0..nv) |j| obj[j] = @floatFromInt((j * 3) % 5 + 1);

    var x: [nv]f64 = undefined;
    const st = try solveLe(testing.allocator, nv, &rowslice, &obj, &x);
    try testing.expectEqual(Status.optimal, st);

    // feasible: every row satisfied, every variable non-negative
    for (0..m) |i| {
        var lhs: f64 = 0;
        for (0..nv) |j| lhs += storage[i][j] * x[j];
        try testing.expect(lhs <= 500 + 1e-6);
    }
    for (x) |v| try testing.expect(v >= -1e-9);
}
