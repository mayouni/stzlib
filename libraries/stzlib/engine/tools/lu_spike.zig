// LU THREADING SPIKE (M2) -- measure before promising anything.
//
// Run:  zig run tools/lu_spike.zig -OReleaseSafe
//
// LU factorisation is the solver tier's core (determinant/solve/inverse all
// sit on decompose). Its parallel shape is UNLIKE matmul's: the k loop is
// sequential (each step eliminates below the pivot chosen from the PREVIOUS
// step's state), so only the per-k elimination fans out -- rows k+1..n are
// independent axpy's. That means:
//   - a BARRIER per k step (n-1 barriers),
//   - per-step work that SHRINKS as the triangle closes (at k = n-2 there
//     is one row of two elements -- pure barrier tax),
//   - axpy-shaped inner work, which the cpu spike showed is bandwidth-bound
//     (saxpy failed K2 at 1.44x).
// The counter-argument: the pivot row is HOT in cache across all eliminating
// rows of a step, so arithmetic intensity beats pure saxpy. Which force wins
// is exactly what this spike measures.
//
// Workers are spawned ONCE per factorisation and synchronised with a
// spinning generation barrier -- spawn-per-k would cost n * 0.4 ms and
// drown everything (measured in cpu_spike).
//
// KILL CRITERIA, written before the first number:
//   L1  if the best configuration at n=1024 gains < 1.8x over serial, LU
//       threading is NOT SHIPPED -- the barrier tax wins, the verdict is
//       recorded in the plan, and the solver tier keeps its single-core
//       + SIMD form. "Measured and deliberately left alone" is a result.
//   L2  bit-identity is mandatory: same pivots (search stays serial), each
//       row eliminated by exactly one thread in the same axpy order. Any
//       mismatch vs serial = harness bug, stop.

const std = @import("std");

fn axpyNeg(dst: []f64, src: []const f64, factor: f64) void {
    for (dst, src) |*d, s| d.* -= factor * s;
}

// Serial reference: the shipped decompose's shape (partial pivoting),
// minus the allocator scaffolding.
fn luSerial(lu: []f64, perm: []usize, n: usize) void {
    for (perm, 0..) |*p, i| p.* = i;
    for (0..n) |k| {
        var pivot_row = k;
        var pivot_mag = @abs(lu[k * n + k]);
        for (k + 1..n) |r| {
            const mag = @abs(lu[r * n + k]);
            if (mag > pivot_mag) {
                pivot_mag = mag;
                pivot_row = r;
            }
        }
        if (pivot_mag == 0) continue;
        if (pivot_row != k) {
            for (0..n) |c| {
                const t = lu[k * n + c];
                lu[k * n + c] = lu[pivot_row * n + c];
                lu[pivot_row * n + c] = t;
            }
            const tp = perm[k];
            perm[k] = perm[pivot_row];
            perm[pivot_row] = tp;
        }
        const pivot = lu[k * n + k];
        for (k + 1..n) |r| {
            const factor = lu[r * n + k] / pivot;
            lu[r * n + k] = factor;
            if (factor == 0.0) continue;
            axpyNeg(lu[r * n + k + 1 .. r * n + n], lu[k * n + k + 1 .. k * n + n], factor);
        }
    }
}

// Parallel: persistent workers, spinning generation barrier per k step.
const LuShared = struct {
    lu: []f64,
    n: usize,
    k: std.atomic.Value(usize),
    gen: std.atomic.Value(usize),
    done: std.atomic.Value(usize),
    nt: usize,
    quit: std.atomic.Value(bool),
    // Rows below a threshold count are eliminated by the MAIN thread alone;
    // workers skip the generation. Set per measurement variant.
    min_rows_parallel: usize,
};

fn luWorker(sh: *LuShared, tid: usize) void {
    var seen_gen: usize = 0;
    while (true) {
        // wait for the next generation (or quit)
        while (sh.gen.load(.acquire) == seen_gen) {
            if (sh.quit.load(.acquire)) return;
            std.atomic.spinLoopHint();
        }
        seen_gen = sh.gen.load(.acquire);
        const n = sh.n;
        const k = sh.k.load(.acquire);
        const rows = n - (k + 1);
        const per = (rows + sh.nt - 1) / sh.nt;
        const r0 = k + 1 + tid * per;
        const r1 = @min(r0 + per, n);
        const pivot = sh.lu[k * n + k];
        var r = r0;
        while (r < r1) : (r += 1) {
            const factor = sh.lu[r * n + k] / pivot;
            sh.lu[r * n + k] = factor;
            if (factor != 0.0) {
                axpyNeg(sh.lu[r * n + k + 1 .. r * n + n], sh.lu[k * n + k + 1 .. k * n + n], factor);
            }
        }
        _ = sh.done.fetchAdd(1, .release);
    }
}

fn luParallel(lu: []f64, perm: []usize, n: usize, nt: usize, min_rows: usize) !void {
    for (perm, 0..) |*p, i| p.* = i;
    var shared = LuShared{
        .lu = lu,
        .n = n,
        .k = std.atomic.Value(usize).init(0),
        .gen = std.atomic.Value(usize).init(0),
        .done = std.atomic.Value(usize).init(0),
        .nt = nt,
        .quit = std.atomic.Value(bool).init(false),
        .min_rows_parallel = min_rows,
    };
    var threads: [12]std.Thread = undefined;
    for (0..nt) |t| threads[t] = try std.Thread.spawn(.{}, luWorker, .{ &shared, t });
    defer {
        shared.quit.store(true, .release);
        for (threads[0..nt]) |th| th.join();
    }

    for (0..n) |k| {
        var pivot_row = k;
        var pivot_mag = @abs(lu[k * n + k]);
        for (k + 1..n) |r| {
            const mag = @abs(lu[r * n + k]);
            if (mag > pivot_mag) {
                pivot_mag = mag;
                pivot_row = r;
            }
        }
        if (pivot_mag == 0) continue;
        if (pivot_row != k) {
            for (0..n) |c| {
                const t = lu[k * n + c];
                lu[k * n + c] = lu[pivot_row * n + c];
                lu[pivot_row * n + c] = t;
            }
            const tp = perm[k];
            perm[k] = perm[pivot_row];
            perm[pivot_row] = tp;
        }
        const rows = n - (k + 1);
        if (rows == 0) break;
        if (rows < shared.min_rows_parallel) {
            // tail of the triangle: barrier tax exceeds the work
            const pivot = lu[k * n + k];
            for (k + 1..n) |r| {
                const factor = lu[r * n + k] / pivot;
                lu[r * n + k] = factor;
                if (factor != 0.0) {
                    axpyNeg(lu[r * n + k + 1 .. r * n + n], lu[k * n + k + 1 .. k * n + n], factor);
                }
            }
            continue;
        }
        shared.k.store(k, .release);
        shared.done.store(0, .release);
        shared.gen.store(shared.gen.load(.acquire) + 1, .release);
        while (shared.done.load(.acquire) < nt) std.atomic.spinLoopHint();
    }
}

fn ms(ns: u64) f64 {
    return @as(f64, @floatFromInt(ns)) / 1_000_000.0;
}

pub fn main() !void {
    var gpa_state = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa_state.allocator();
    var timer = try std.time.Timer.start();
    const REPS = 5;

    for ([_]usize{ 256, 512, 1024, 1536 }) |n| {
        const base = try alloc.alloc(f64, n * n);
        defer alloc.free(base);
        var seed: u64 = 3;
        for (base, 0..) |*v, idx| {
            seed = seed *% 6364136223846793005 +% 1442695040888963407;
            v.* = @as(f64, @floatFromInt((seed >> 33) % 1000)) / 999.0 +
                (if (idx / n == idx % n) @as(f64, 4.0) else 0.0);
        }
        const work = try alloc.alloc(f64, n * n);
        defer alloc.free(work);
        const ref = try alloc.alloc(f64, n * n);
        defer alloc.free(ref);
        const perm = try alloc.alloc(usize, n);
        defer alloc.free(perm);
        const perm_ref = try alloc.alloc(usize, n);
        defer alloc.free(perm_ref);

        @memcpy(ref, base);
        luSerial(ref, perm_ref, n);

        var t_serial: u64 = std.math.maxInt(u64);
        for (0..REPS) |_| {
            @memcpy(work, base);
            timer.reset();
            luSerial(work, perm, n);
            t_serial = @min(t_serial, timer.read());
        }

        const flops = 2.0 / 3.0 * @as(f64, @floatFromInt(n)) * @as(f64, @floatFromInt(n)) * @as(f64, @floatFromInt(n));
        std.debug.print("LU n={d:>5}: serial {d:7.2} ms ({d:4.1} GF)  ", .{ n, ms(t_serial), flops / @as(f64, @floatFromInt(t_serial)) });

        for ([_]usize{ 4, 8 }) |nt| {
            for ([_]usize{ 64, 256 }) |min_rows| {
                var t_par: u64 = std.math.maxInt(u64);
                for (0..REPS) |_| {
                    @memcpy(work, base);
                    timer.reset();
                    try luParallel(work, perm, n, nt, min_rows);
                    t_par = @min(t_par, timer.read());
                }
                // L2: bit-identity (values AND pivot order)
                for (work, ref) |x, y| {
                    if (x != y) {
                        std.debug.print("\nL2 VIOLATION n={d} nt={d} min={d}\n", .{ n, nt, min_rows });
                        return error.BitMismatch;
                    }
                }
                for (perm, perm_ref) |x, y| {
                    if (x != y) return error.PermMismatch;
                }
                const sp = @as(f64, @floatFromInt(t_serial)) / @as(f64, @floatFromInt(t_par));
                std.debug.print("T{d}/m{d}={d:4.2}x ", .{ nt, min_rows, sp });
            }
        }
        std.debug.print("\n", .{});
    }
}
