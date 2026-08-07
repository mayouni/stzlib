// MULTICORE COMPUTE SPIKE -- the go/no-go measurement for a parallel tier.
//
// Run:  zig run tools/cpu_spike.zig -OReleaseSafe
// (standalone; no engine imports -- the shipped i-k-j matmul kernel is
// replicated inline so the spike measures exactly that shape in isolation)
//
// CONTEXT. Every compute kernel in the engine is single-threaded (matrix,
// linalg, stats, sparse: zero Thread references), while the engine already
// owns a bounded thread pool built for I/O. This spike decides whether a
// multicore COMPUTE tier is worth building, and for which op classes. It is
// the only remaining speed lever for the f64 solver tier, which is excluded
// from the GPU plane by decision (WGSL has no f64).
//
// MACHINE (measured): Intel Core 5 210H -- 8 cores / 12 logical (P+E mix).
// Windows schedules across P and E cores as it pleases; we measure the
// machine AS USERS HAVE IT, no affinity pinning.
//
// KILL CRITERIA, written before the first number:
//   K1  if row-banded matmul at n=1024, best thread count, sustains < 3.0x
//       over single-thread, the tier is memory-bound on real hardware and
//       gets scoped DOWN (bandwidth ops excluded, only cache-friendly
//       compute admitted) -- recorded, not argued around.
//   K2  if pure-bandwidth ops (sum, saxpy) gain < 1.5x at any thread count,
//       the elementwise/reduction family is EXCLUDED from the tier standalone
//       (same verdict shape as GPU G0, which killed standalone elementwise).
//   K3  if thread spawn+join overhead exceeds 20% of an n=512 matmul at 8
//       threads, spawn-per-call is dead and the design REQUIRES the
//       persistent pool (pool.zig) from day one.
//   K4  any bit-mismatch between banded and single-thread matmul: stop --
//       row-banding must be BIT-IDENTICAL by construction (each output row
//       is computed by exactly one thread, same i-k-j order; there is no
//       cross-thread reduction). A mismatch means the harness is wrong.
//
// Reductions (sum) DO re-associate across per-thread partials -- same frame
// as SIMD lanes: not bit-identical, generally better-conditioned, needs its
// per-site justification when productized. The spike reports the delta.

const std = @import("std");

const VEC = 4;
const Vec = @Vector(VEC, f64);

// The shipped kernel shape (matrix.zig stz_matrix_multiply), banded:
// computes output rows [r0, r1).
fn matmulBand(a: []const f64, b: []const f64, c: []f64, n: usize, r0: usize, r1: usize) void {
    for (r0..r1) |i| {
        const c_row = c[i * n .. i * n + n];
        @memset(c_row, 0);
        for (0..n) |k| {
            const aik = a[i * n + k];
            const b_row = b[k * n .. k * n + n];
            const splat: Vec = @splat(aik);
            var j: usize = 0;
            while (j + VEC <= n) : (j += VEC) {
                const bv: Vec = b_row[j..][0..VEC].*;
                const cv: Vec = c_row[j..][0..VEC].*;
                c_row[j..][0..VEC].* = cv + splat * bv;
            }
            while (j < n) : (j += 1) c_row[j] += aik * b_row[j];
        }
    }
}

const MatJob = struct {
    a: []const f64,
    b: []const f64,
    c: []f64,
    n: usize,
    r0: usize,
    r1: usize,
    fn run(self: *const MatJob) void {
        matmulBand(self.a, self.b, self.c, self.n, self.r0, self.r1);
    }
};

fn matmulThreaded(a: []const f64, b: []const f64, c: []f64, n: usize, nt: usize, jobs: []MatJob, threads: []std.Thread) !void {
    if (nt <= 1) {
        matmulBand(a, b, c, n, 0, n);
        return;
    }
    const band = (n + nt - 1) / nt;
    var t: usize = 0;
    var spawned: usize = 0;
    while (t < nt) : (t += 1) {
        const r0 = t * band;
        if (r0 >= n) break;
        const r1 = @min(r0 + band, n);
        jobs[t] = .{ .a = a, .b = b, .c = c, .n = n, .r0 = r0, .r1 = r1 };
        threads[t] = try std.Thread.spawn(.{}, MatJob.run, .{&jobs[t]});
        spawned += 1;
    }
    for (threads[0..spawned]) |th| th.join();
}

const SumJob = struct {
    data: []const f64,
    out: *f64,
    fn run(self: *const SumJob) void {
        var s: f64 = 0;
        for (self.data) |v| s += v;
        self.out.* = s;
    }
};

const AxpyJob = struct {
    x: []const f64,
    y: []f64,
    a: f64,
    fn run(self: *const AxpyJob) void {
        for (self.y, self.x) |*yy, xx| yy.* += self.a * xx;
    }
};

fn ms(ns: u64) f64 {
    return @as(f64, @floatFromInt(ns)) / 1_000_000.0;
}

fn fill(buf: []f64, seed: u64) void {
    var s = seed;
    for (buf) |*v| {
        s = s *% 6364136223846793005 +% 1442695040888963407;
        v.* = @as(f64, @floatFromInt((s >> 33) % 1000)) / 1000.0 + 0.5;
    }
}

pub fn main() !void {
    var gpa_state = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa_state.allocator();
    const cpus = try std.Thread.getCpuCount();
    std.debug.print("logical cpus: {d}\n\n", .{cpus});

    var timer = try std.time.Timer.start();
    const REPS = 5;

    // ── overhead floor: spawn+join of trivial threads ──
    const Trivial = struct {
        fn run() void {}
    };
    inline for ([_]usize{ 4, 8, 12 }) |nt| {
        var best: u64 = std.math.maxInt(u64);
        for (0..REPS) |_| {
            timer.reset();
            var ths: [12]std.Thread = undefined;
            for (0..nt) |t| ths[t] = try std.Thread.spawn(.{}, Trivial.run, .{});
            for (0..nt) |t| ths[t].join();
            best = @min(best, timer.read());
        }
        std.debug.print("spawn+join x{d:>2} trivial threads : {d:6.3} ms\n", .{ nt, ms(best) });
    }
    std.debug.print("\n", .{});

    // ── matmul: sizes x threads ──
    const sizes = [_]usize{ 128, 256, 512, 1024 };
    const thread_counts = [_]usize{ 1, 2, 4, 6, 8, 12 };
    var jobs: [12]MatJob = undefined;
    var threads: [12]std.Thread = undefined;

    for (sizes) |n| {
        const a = try alloc.alloc(f64, n * n);
        defer alloc.free(a);
        const b = try alloc.alloc(f64, n * n);
        defer alloc.free(b);
        const c = try alloc.alloc(f64, n * n);
        defer alloc.free(c);
        const ref = try alloc.alloc(f64, n * n);
        defer alloc.free(ref);
        fill(a, 42);
        fill(b, 4242);

        const flops = 2.0 * @as(f64, @floatFromInt(n)) * @as(f64, @floatFromInt(n)) * @as(f64, @floatFromInt(n));

        matmulBand(a, b, ref, n, 0, n); // single-thread reference

        var base_ns: u64 = 0;
        std.debug.print("matmul n={d:>5}: ", .{n});
        for (thread_counts) |nt| {
            var best: u64 = std.math.maxInt(u64);
            for (0..REPS) |_| {
                timer.reset();
                try matmulThreaded(a, b, c, n, nt, &jobs, &threads);
                best = @min(best, timer.read());
            }
            // K4: banded must be bit-identical to single-thread.
            for (c, ref) |x, y| {
                if (x != y) {
                    std.debug.print("\nK4 VIOLATION at n={d} nt={d}\n", .{ n, nt });
                    return error.BitMismatch;
                }
            }
            if (nt == 1) base_ns = best;
            const gf = flops / @as(f64, @floatFromInt(best));
            const sp = @as(f64, @floatFromInt(base_ns)) / @as(f64, @floatFromInt(best));
            std.debug.print("T{d}={d:5.1}GF({d:4.2}x) ", .{ nt, gf, sp });
        }
        std.debug.print("\n", .{});
    }

    // ── bandwidth-bound: sum 32M and saxpy 32M ──
    std.debug.print("\n", .{});
    const N: usize = 32 * 1024 * 1024;
    const big = try alloc.alloc(f64, N);
    defer alloc.free(big);
    const ybuf = try alloc.alloc(f64, N);
    defer alloc.free(ybuf);
    fill(big, 7);
    fill(ybuf, 77);

    var sum_jobs: [12]SumJob = undefined;
    var partials: [12]f64 = undefined;
    var axpy_jobs: [12]AxpyJob = undefined;

    var ref_sum: f64 = 0;
    for (big) |v| ref_sum += v;

    for ([_]usize{ 1, 4, 8, 12 }) |nt| {
        var best_sum: u64 = std.math.maxInt(u64);
        var got_sum: f64 = 0;
        for (0..REPS) |_| {
            timer.reset();
            if (nt == 1) {
                var s: f64 = 0;
                for (big) |v| s += v;
                got_sum = s;
                // The first run of this spike printed 0.00 ms here: LLVM
                // hoisted the loop-invariant sum out of the REPS loop and
                // the timer measured nothing. A benchmark the optimizer can
                // delete is not a benchmark.
                std.mem.doNotOptimizeAway(&got_sum);
            } else {
                const chunk = N / nt;
                for (0..nt) |t| {
                    const lo = t * chunk;
                    const hi = if (t == nt - 1) N else lo + chunk;
                    sum_jobs[t] = .{ .data = big[lo..hi], .out = &partials[t] };
                    threads[t] = try std.Thread.spawn(.{}, SumJob.run, .{&sum_jobs[t]});
                }
                for (0..nt) |t| threads[t].join();
                var s: f64 = 0;
                for (partials[0..nt]) |p| s += p;
                got_sum = s;
            }
            best_sum = @min(best_sum, timer.read());
        }
        const gbps = @as(f64, @floatFromInt(N * 8)) / @as(f64, @floatFromInt(best_sum));
        std.debug.print("sum 32M   T{d:>2}: {d:7.2} ms ({d:4.1} GB/s)  delta_vs_seq={e:9.2}\n", .{ nt, ms(best_sum), gbps, got_sum - ref_sum });
    }

    for ([_]usize{ 1, 4, 8 }) |nt| {
        var best_ax: u64 = std.math.maxInt(u64);
        for (0..REPS) |_| {
            timer.reset();
            if (nt == 1) {
                for (ybuf, big) |*yy, xx| yy.* += 1.0001 * xx;
                std.mem.doNotOptimizeAway(ybuf.ptr);
            } else {
                const chunk = N / nt;
                for (0..nt) |t| {
                    const lo = t * chunk;
                    const hi = if (t == nt - 1) N else lo + chunk;
                    axpy_jobs[t] = .{ .x = big[lo..hi], .y = ybuf[lo..hi], .a = 1.0001 };
                    threads[t] = try std.Thread.spawn(.{}, AxpyJob.run, .{&axpy_jobs[t]});
                }
                for (0..nt) |t| threads[t].join();
            }
            best_ax = @min(best_ax, timer.read());
        }
        const gbps = @as(f64, @floatFromInt(N * 8 * 3)) / @as(f64, @floatFromInt(best_ax));
        std.debug.print("saxpy 32M T{d:>2}: {d:7.2} ms ({d:4.1} GB/s effective)\n", .{ nt, ms(best_ax), gbps });
    }
}
