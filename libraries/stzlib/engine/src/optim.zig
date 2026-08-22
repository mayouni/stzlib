// Softanza Engine -- the OPTIMIZATION FLOOR: LP + branch-and-bound MIP.
//
// R4 step 5 (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md 5.5). The design names two
// execution tiers: this zero-dependency Zig floor -- honest, small models and
// teaching -- and a vendored HiGHS upgrade later. SolveWith(:auto) picks and
// Why() names which ran. This file is the floor, and nothing here depends on
// anything outside the standard library.
//
// WHAT THIS ADDS OVER simplex.zig, WHICH ALREADY WORKED. simplex.zig owns the
// PIVOT LOOP and expects a tableau somebody else laid out -- Ring built it, and
// stzLinearSolver still does. That split was right when the caller had one
// model to solve: the build measured 0.005s and flat, so only the pivot loop
// earned the crossing (simplex.zig's own header records the measurement).
//
// BRANCH-AND-BOUND CHANGES THE ARITHMETIC OF THAT DECISION, which is the whole
// reason this file exists rather than one more Ring loop. B&B does not solve
// one LP; it solves a TREE of them, each a copy of the parent with one bound
// tightened. Rebuilding the tableau in Ring per node would pay the build cost
// -- and a full Ring-list traversal -- once per node instead of once per solve,
// and the node count is what grows. So the MODEL crosses once, and the whole
// tree is explored on this side.
//
// THE MODEL IS A CLEAN DESCRIPTION, NOT A TABLEAU. The caller sends objective
// coefficients, a constraint matrix, senses, right-hand sides, bounds and
// integrality flags. Laying out slacks, surpluses, artificials and the Big-M
// objective row is this file's job, per node. That is deliberate: a caller that
// has to know where the artificial columns start is a caller that can put them
// in the wrong place, and stzCoeffExtractor's history is what that costs.

const std = @import("std");
const simplex = @import("simplex.zig");

pub const INF: f64 = std.math.inf(f64);

pub const Status = enum(i32) {
    optimal = 0,
    unbounded = 1,
    infeasible = 2,
    iteration_limit = 3,
    node_limit = 4,
    /// a lower bound of -infinity: v1 models are bounded below, and a free
    /// variable is REFUSED rather than silently clamped to something arbitrary
    unbounded_below = 5,
};

/// -1 = <= , 0 = == , 1 = >=
pub const LE: i8 = -1;
pub const EQ: i8 = 0;
pub const GE: i8 = 1;

const INT_TOL: f64 = 0.000001; // 1e-6 -- a value this close to whole IS whole
const PRUNE_TOL: f64 = 0.000001;
const DEFAULT_MAX_NODES: i32 = 5000;

pub const Model = struct {
    n: usize, // variables
    m: usize, // constraints
    obj: []const f64, // n objective coefficients
    maximize: bool,
    lb: []const f64, // n lower bounds (finite)
    ub: []const f64, // n upper bounds (INF = none)
    is_int: []const bool, // n integrality flags
    mat: []const f64, // m*n row-major
    sense: []const i8, // m
    rhs: []const f64, // m
};

pub const Result = struct {
    status: Status,
    objective: f64,
    nodes: i32,
    iterations: i32,
    /// true when at least one variable was integral and the tree ran
    branched: bool,
};

// ─── the LP relaxation ───────────────────────────────────────────────────────
//
// One node's bounds, laid out as a Big-M tableau and handed to the pivot loop.
// Every variable is shifted to x = lb + x' so the tableau's implicit x' >= 0 is
// the true lower bound, and a finite upper bound becomes an ordinary row.

fn solveRelaxation(
    alloc: std.mem.Allocator,
    mo: Model,
    lb: []const f64,
    ub: []const f64,
    x_out: []f64,
    iters_out: *i32,
) !Status {
    const n = mo.n;

    for (0..n) |j| {
        if (lb[j] == -INF) return Status.unbounded_below;
        if (ub[j] != INF and ub[j] < lb[j] - INT_TOL) return Status.infeasible;
    }

    // rows = the model's constraints, plus one per finite upper bound
    var extra: usize = 0;
    for (0..n) |j| {
        if (ub[j] != INF) extra += 1;
    }
    const m = mo.m + extra;

    const a = try alloc.alloc(f64, m * n);
    defer alloc.free(a);
    @memset(a, 0);
    const b = try alloc.alloc(f64, m);
    defer alloc.free(b);
    const sn = try alloc.alloc(i8, m);
    defer alloc.free(sn);

    // the model's own rows, shifted by the lower bounds
    for (0..mo.m) |i| {
        var shift: f64 = 0;
        for (0..n) |j| {
            const c = mo.mat[i * n + j];
            a[i * n + j] = c;
            shift += c * lb[j];
        }
        b[i] = mo.rhs[i] - shift;
        sn[i] = mo.sense[i];
    }
    // a finite upper bound is a row: x'_j <= ub_j - lb_j
    var r: usize = mo.m;
    for (0..n) |j| {
        if (ub[j] == INF) continue;
        a[r * n + j] = 1;
        b[r] = ub[j] - lb[j];
        sn[r] = LE;
        r += 1;
    }

    // the pivot loop needs a non-negative right-hand side, so a negative one
    // flips the whole row -- and the sense with it
    for (0..m) |i| {
        if (b[i] < 0) {
            b[i] = -b[i];
            for (0..n) |j| a[i * n + j] = -a[i * n + j];
            sn[i] = -sn[i]; // <= <-> >= ; == is 0 and stays 0
        }
    }

    // column layout: structurals, slack/surplus, artificials, rhs -- the same
    // order stzLinearSolver lays out, so both sides speak one tableau
    var n_ss: usize = 0;
    var n_art: usize = 0;
    for (0..m) |i| {
        if (sn[i] == LE) n_ss += 1;
        if (sn[i] == GE) {
            n_ss += 1;
            n_art += 1;
        }
        if (sn[i] == EQ) n_art += 1;
    }
    const cols = n + n_ss + n_art + 1;
    const art_at = n + n_ss;

    const t = try alloc.alloc(f64, m * cols);
    defer alloc.free(t);
    @memset(t, 0);
    const z = try alloc.alloc(f64, cols);
    defer alloc.free(z);
    @memset(z, 0);
    const basis = try alloc.alloc(i32, m);
    defer alloc.free(basis);

    var ss_col: usize = n;
    var art_col: usize = art_at;
    for (0..m) |i| {
        for (0..n) |j| t[i * cols + j] = a[i * n + j];
        t[i * cols + (cols - 1)] = b[i];
        switch (sn[i]) {
            LE => {
                t[i * cols + ss_col] = 1;
                basis[i] = @intCast(ss_col + 1);
                ss_col += 1;
            },
            GE => {
                t[i * cols + ss_col] = -1; // surplus
                ss_col += 1;
                t[i * cols + art_col] = 1;
                basis[i] = @intCast(art_col + 1);
                art_col += 1;
            },
            else => { // EQ
                t[i * cols + art_col] = 1;
                basis[i] = @intCast(art_col + 1);
                art_col += 1;
            },
        }
    }

    // Big-M: minimise -c'x' + M * (sum of artificials). M is scaled to the
    // objective so a large coefficient cannot out-vote the penalty.
    var max_c: f64 = 0;
    for (0..n) |j| {
        const v = @abs(mo.obj[j]);
        if (v > max_c) max_c = v;
    }
    const big_m: f64 = 1000000.0 * (1.0 + max_c);

    const sign: f64 = if (mo.maximize) 1 else -1;
    for (0..n) |j| z[j] = -sign * mo.obj[j];
    for (art_at..art_at + n_art) |c| z[c] = big_m;
    // a basic artificial must price out at zero
    for (0..m) |i| {
        if (@as(usize, @intCast(basis[i])) > art_at) {
            for (0..cols) |j| z[j] -= big_m * t[i * cols + j];
        }
    }

    const xp = try alloc.alloc(f64, n);
    defer alloc.free(xp);

    var iters: i32 = 0;
    const st = simplex.run(t, z, basis, m, cols, art_at, &iters);
    iters_out.* = iters;
    if (st != .optimal) {
        return switch (st) {
            .unbounded => Status.unbounded,
            .infeasible => Status.infeasible,
            else => Status.iteration_limit,
        };
    }
    simplex.extract(t, basis, m, cols, xp, n);
    for (0..n) |j| x_out[j] = lb[j] + xp[j];
    return Status.optimal;
}

fn objectiveOf(mo: Model, x: []const f64) f64 {
    var s: f64 = 0;
    for (0..mo.n) |j| s += mo.obj[j] * x[j];
    return s;
}

/// the first variable whose integrality is violated, or null when every
/// integer variable already holds a whole number
fn firstFractional(mo: Model, x: []const f64) ?usize {
    for (0..mo.n) |j| {
        if (!mo.is_int[j]) continue;
        const v = x[j];
        if (@abs(v - @round(v)) > INT_TOL) return j;
    }
    return null;
}

// ─── branch and bound ────────────────────────────────────────────────────────
//
// Depth-first with an incumbent, because depth-first finds a feasible integer
// point early and every node after that can be pruned against it. A node whose
// RELAXATION is already no better than the incumbent cannot contain a better
// integer point -- that is the bound half of the name, and it is what keeps the
// tree from being the whole lattice.

const Search = struct {
    alloc: std.mem.Allocator,
    mo: Model,
    best_x: []f64,
    best_obj: f64,
    has_best: bool,
    nodes: i32,
    max_nodes: i32,
    iterations: i32,
    hit_limit: bool,

    fn descend(self: *Search, lb: []f64, ub: []f64, depth: u32) !void {
        if (self.nodes >= self.max_nodes or depth > 200) {
            self.hit_limit = true;
            return;
        }
        self.nodes += 1;

        const x = try self.alloc.alloc(f64, self.mo.n);
        defer self.alloc.free(x);

        var iters: i32 = 0;
        const st = try solveRelaxation(self.alloc, self.mo, lb, ub, x, &iters);
        self.iterations += iters;
        if (st != .optimal) return; // infeasible or unbounded subtree: nothing here

        // maximising internally: a relaxation that cannot beat the incumbent
        // bounds away a whole subtree
        const relaxed = objectiveOf(self.mo, x);
        const signed = if (self.mo.maximize) relaxed else -relaxed;
        if (self.has_best) {
            const best_signed = if (self.mo.maximize) self.best_obj else -self.best_obj;
            if (signed <= best_signed + PRUNE_TOL) return;
        }

        const frac = firstFractional(self.mo, x);
        if (frac == null) {
            // an integer point, and better than anything seen
            @memcpy(self.best_x, x);
            self.best_obj = relaxed;
            self.has_best = true;
            return;
        }

        const j = frac.?;
        const v = x[j];

        // DOWN: x_j <= floor(v)
        {
            const lo = try self.alloc.dupe(f64, lb);
            defer self.alloc.free(lo);
            const hi = try self.alloc.dupe(f64, ub);
            defer self.alloc.free(hi);
            const f = @floor(v);
            if (f >= lo[j] - INT_TOL) {
                hi[j] = f;
                try self.descend(lo, hi, depth + 1);
            }
        }
        // UP: x_j >= ceil(v)
        {
            const lo = try self.alloc.dupe(f64, lb);
            defer self.alloc.free(lo);
            const hi = try self.alloc.dupe(f64, ub);
            defer self.alloc.free(hi);
            const c = @ceil(v);
            if (hi[j] == INF or c <= hi[j] + INT_TOL) {
                lo[j] = c;
                try self.descend(lo, hi, depth + 1);
            }
        }
    }
};

/// Solve the model. `x_out` receives the solution when the status is optimal.
pub fn solve(
    alloc: std.mem.Allocator,
    mo: Model,
    x_out: []f64,
    max_nodes: i32,
) !Result {
    var any_int = false;
    for (0..mo.n) |j| {
        if (mo.is_int[j]) any_int = true;
    }

    const lb = try alloc.dupe(f64, mo.lb);
    defer alloc.free(lb);
    const ub = try alloc.dupe(f64, mo.ub);
    defer alloc.free(ub);

    // the pure LP: no tree, and the answer is the relaxation itself
    if (!any_int) {
        var iters: i32 = 0;
        const st = try solveRelaxation(alloc, mo, lb, ub, x_out, &iters);
        return .{
            .status = st,
            .objective = if (st == .optimal) objectiveOf(mo, x_out) else 0,
            .nodes = 1,
            .iterations = iters,
            .branched = false,
        };
    }

    // AN UNBOUNDED RELAXATION IS REPORTED BEFORE THE TREE, not inside it: a
    // subtree that returns "unbounded" is indistinguishable from one that is
    // merely empty once it is being pruned, and answering "infeasible" to an
    // unbounded model would be a lie with a clean-looking status code.
    {
        const probe = try alloc.alloc(f64, mo.n);
        defer alloc.free(probe);
        var iters: i32 = 0;
        const st = try solveRelaxation(alloc, mo, lb, ub, probe, &iters);
        if (st != .optimal) {
            return .{ .status = st, .objective = 0, .nodes = 1, .iterations = iters, .branched = false };
        }
    }

    var s = Search{
        .alloc = alloc,
        .mo = mo,
        .best_x = x_out,
        .best_obj = 0,
        .has_best = false,
        .nodes = 0,
        .max_nodes = if (max_nodes > 0) max_nodes else DEFAULT_MAX_NODES,
        .iterations = 0,
        .hit_limit = false,
    };
    try s.descend(lb, ub, 0);

    if (!s.has_best) {
        return .{
            .status = if (s.hit_limit) Status.node_limit else Status.infeasible,
            .objective = 0,
            .nodes = s.nodes,
            .iterations = s.iterations,
            .branched = true,
        };
    }
    // A TREE THAT RAN OUT OF NODES STILL FOUND SOMETHING, and says so: the
    // incumbent is feasible and may even be optimal, but nothing proved it, so
    // the status is node_limit and the caller is told rather than reassured.
    return .{
        .status = if (s.hit_limit) Status.node_limit else Status.optimal,
        .objective = s.best_obj,
        .nodes = s.nodes,
        .iterations = s.iterations,
        .branched = true,
    };
}

// ─── tests -- the standalone probe (`zig test src/optim.zig`, no DLL) ────────

const testing = std.testing;

const Built = struct {
    x: [8]f64 = undefined,
    res: Result = undefined,
};

fn runModel(
    n: usize,
    m: usize,
    obj: []const f64,
    maximize: bool,
    lb: []const f64,
    ub: []const f64,
    is_int: []const bool,
    mat: []const f64,
    sense: []const i8,
    rhs: []const f64,
    out: *Built,
) !void {
    const mo = Model{
        .n = n,
        .m = m,
        .obj = obj,
        .maximize = maximize,
        .lb = lb,
        .ub = ub,
        .is_int = is_int,
        .mat = mat,
        .sense = sense,
        .rhs = rhs,
    };
    out.res = try solve(testing.allocator, mo, out.x[0..n], 0);
}

test "optim: the design's own example -- max 3x+2y under two constraints" {
    // SOFTANZA_INTELLIGENCE_ARCHITECTURE.md 5.5:
    //   Vars x in [0,40], y >= 0 ; Maximize 3x+2y ; x+y<=50, 2x+y<=80
    var b = Built{};
    try runModel(
        2,
        2,
        &[_]f64{ 3, 2 },
        true,
        &[_]f64{ 0, 0 },
        &[_]f64{ 40, INF },
        &[_]bool{ false, false },
        &[_]f64{ 1, 1, 2, 1 },
        &[_]i8{ LE, LE },
        &[_]f64{ 50, 80 },
        &b,
    );
    try testing.expectEqual(Status.optimal, b.res.status);
    try testing.expectApproxEqAbs(@as(f64, 30), b.x[0], 1e-6);
    try testing.expectApproxEqAbs(@as(f64, 20), b.x[1], 1e-6);
    try testing.expectApproxEqAbs(@as(f64, 130), b.res.objective, 1e-6);
    try testing.expect(!b.res.branched);
}

test "optim: branch-and-bound -- the integer answer is NOT the rounded LP one" {
    // max x+y  s.t. 2x+2y <= 5, x,y integer >= 0.
    // The relaxation reaches 2.5; no integer point does. The answer is 2, and
    // rounding the relaxation DOWN componentwise would also give 2 here, so the
    // second model below is the one that makes the tree earn its keep.
    var b = Built{};
    try runModel(
        2,
        1,
        &[_]f64{ 1, 1 },
        true,
        &[_]f64{ 0, 0 },
        &[_]f64{ INF, INF },
        &[_]bool{ true, true },
        &[_]f64{ 2, 2 },
        &[_]i8{LE},
        &[_]f64{5},
        &b,
    );
    try testing.expectEqual(Status.optimal, b.res.status);
    try testing.expectApproxEqAbs(@as(f64, 2), b.res.objective, 1e-6);
    try testing.expect(b.res.branched);
    // and it is a genuine integer point
    try testing.expectApproxEqAbs(b.x[0], @round(b.x[0]), 1e-6);
    try testing.expectApproxEqAbs(b.x[1], @round(b.x[1]), 1e-6);
}

test "optim: a knapsack whose LP optimum rounds to an INFEASIBLE point" {
    // max 5a+4b  s.t. 6a+4b <= 12, a,b integer >= 0, a<=2, b<=2.
    // LP: a=2, b=0 -> 10; but check the fractional frontier: a=1.33,b=1 ...
    // The point of this case is that the tree must not simply round.
    var b = Built{};
    try runModel(
        2,
        1,
        &[_]f64{ 5, 4 },
        true,
        &[_]f64{ 0, 0 },
        &[_]f64{ 2, 2 },
        &[_]bool{ true, true },
        &[_]f64{ 6, 4 },
        &[_]i8{LE},
        &[_]f64{12},
        &b,
    );
    try testing.expectEqual(Status.optimal, b.res.status);
    // feasible
    try testing.expect(6 * b.x[0] + 4 * b.x[1] <= 12 + 1e-6);
    // optimal, proven by brute force over the tiny lattice
    var best: f64 = 0;
    var ai: f64 = 0;
    while (ai <= 2) : (ai += 1) {
        var bi: f64 = 0;
        while (bi <= 2) : (bi += 1) {
            if (6 * ai + 4 * bi <= 12 + 1e-9) {
                const v = 5 * ai + 4 * bi;
                if (v > best) best = v;
            }
        }
    }
    try testing.expectApproxEqAbs(best, b.res.objective, 1e-6);
}

test "optim: minimise, with a >= constraint -- Big-M has to work" {
    // min 2x+3y  s.t. x+y >= 10, x <= 6, y <= 8   ->  x=6, y=4, objective 24
    var b = Built{};
    try runModel(
        2,
        1,
        &[_]f64{ 2, 3 },
        false,
        &[_]f64{ 0, 0 },
        &[_]f64{ 6, 8 },
        &[_]bool{ false, false },
        &[_]f64{ 1, 1 },
        &[_]i8{GE},
        &[_]f64{10},
        &b,
    );
    try testing.expectEqual(Status.optimal, b.res.status);
    try testing.expectApproxEqAbs(@as(f64, 6), b.x[0], 1e-6);
    try testing.expectApproxEqAbs(@as(f64, 4), b.x[1], 1e-6);
    try testing.expectApproxEqAbs(@as(f64, 24), b.res.objective, 1e-6);
}

test "optim: an equality constraint is honoured exactly" {
    // max x + 2y  s.t. x + y == 10, x <= 4  ->  x=0? no: y is free to 10.
    // max is at x=0,y=10 -> 20.
    var b = Built{};
    try runModel(
        2,
        1,
        &[_]f64{ 1, 2 },
        true,
        &[_]f64{ 0, 0 },
        &[_]f64{ 4, INF },
        &[_]bool{ false, false },
        &[_]f64{ 1, 1 },
        &[_]i8{EQ},
        &[_]f64{10},
        &b,
    );
    try testing.expectEqual(Status.optimal, b.res.status);
    try testing.expectApproxEqAbs(@as(f64, 10), b.x[0] + b.x[1], 1e-6);
    try testing.expectApproxEqAbs(@as(f64, 20), b.res.objective, 1e-6);
}

test "optim: infeasible and unbounded are REPORTED, never guessed" {
    // infeasible: x >= 5 and x <= 2
    var b = Built{};
    try runModel(
        1,
        2,
        &[_]f64{1},
        true,
        &[_]f64{0},
        &[_]f64{INF},
        &[_]bool{false},
        &[_]f64{ 1, 1 },
        &[_]i8{ GE, LE },
        &[_]f64{ 5, 2 },
        &b,
    );
    try testing.expectEqual(Status.infeasible, b.res.status);

    // unbounded: maximise x with nothing bounding it above
    var u = Built{};
    try runModel(
        2,
        1,
        &[_]f64{ 1, 0 },
        true,
        &[_]f64{ 0, 0 },
        &[_]f64{ INF, INF },
        &[_]bool{ false, false },
        &[_]f64{ 1, -1 },
        &[_]i8{LE},
        &[_]f64{1},
        &u,
    );
    try testing.expectEqual(Status.unbounded, u.res.status);

    // ...and an unbounded INTEGER model says unbounded too, not infeasible --
    // the probe before the tree is what makes that answerable
    var ui = Built{};
    try runModel(
        2,
        1,
        &[_]f64{ 1, 0 },
        true,
        &[_]f64{ 0, 0 },
        &[_]f64{ INF, INF },
        &[_]bool{ true, true },
        &[_]f64{ 1, -1 },
        &[_]i8{LE},
        &[_]f64{1},
        &ui,
    );
    try testing.expectEqual(Status.unbounded, ui.res.status);
}

test "optim: a lower bound that is not zero shifts correctly" {
    // max x  s.t. x <= 9, x in [3, 7] -> 7 ; and the shift must not lose the 3
    var b = Built{};
    try runModel(
        1,
        1,
        &[_]f64{1},
        true,
        &[_]f64{3},
        &[_]f64{7},
        &[_]bool{false},
        &[_]f64{1},
        &[_]i8{LE},
        &[_]f64{9},
        &b,
    );
    try testing.expectEqual(Status.optimal, b.res.status);
    try testing.expectApproxEqAbs(@as(f64, 7), b.x[0], 1e-6);

    // minimise the same variable: the lower bound is the answer, and a model
    // that dropped the shift would say 0
    var mn = Built{};
    try runModel(
        1,
        1,
        &[_]f64{1},
        false,
        &[_]f64{3},
        &[_]f64{7},
        &[_]bool{false},
        &[_]f64{1},
        &[_]i8{LE},
        &[_]f64{9},
        &mn,
    );
    try testing.expectEqual(Status.optimal, mn.res.status);
    try testing.expectApproxEqAbs(@as(f64, 3), mn.x[0], 1e-6);
}

test "optim: integer variables with a non-zero lower bound stay integral" {
    // max 3x+2y, x+y<=50, 2x+y<=80, x in [5,40] integer, y >= 0 integer
    var b = Built{};
    try runModel(
        2,
        2,
        &[_]f64{ 3, 2 },
        true,
        &[_]f64{ 5, 0 },
        &[_]f64{ 40, INF },
        &[_]bool{ true, true },
        &[_]f64{ 1, 1, 2, 1 },
        &[_]i8{ LE, LE },
        &[_]f64{ 50, 80 },
        &b,
    );
    try testing.expectEqual(Status.optimal, b.res.status);
    try testing.expectApproxEqAbs(@as(f64, 130), b.res.objective, 1e-6);
    try testing.expect(b.x[0] >= 5 - 1e-6);
    try testing.expectApproxEqAbs(b.x[0], @round(b.x[0]), 1e-6);
    try testing.expectApproxEqAbs(b.x[1], @round(b.x[1]), 1e-6);
}
