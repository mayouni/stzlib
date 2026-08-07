// STATS REDUCTION THREADING SPIKE (M3) -- find the crossover, or the absence
// of one, before touching stats.zig.
//
// Run:  zig run tools/stats_spike.zig -OReleaseSafe
//
// The cpu spike showed a plain sum at 32M gains 3.9x from threads. The
// library's summation authority is NOT the plain sum: it is the
// lane-parallel Neumaier compensatedSum (stats.zig), which does more work
// per element -- and more work per element means threads amortise better on
// data that misses cache, worse on data that fits. Where the crossover sits
// is a measurement, not an argument. Same for centeredSumOfSquares, the
// variance workhorse (one multiply more per element).
//
// SHIP BAR, written first:
//   S1  a size is admitted for threading only where the measured gain is
//       >= 1.5x at some thread count on BOTH runs of this spike. Below the
//       smallest admitted size, the serial form stays -- unconditionally.
//   S2  accuracy: per-thread chunks are summed with the SAME compensated
//       kernel and combined compensated. The pathological case (1e16 + 1
//       repeated) must come out EXACT through the threaded path, exactly as
//       the in-file test pins it for the lane version. Any loss = stop.

const std = @import("std");

const SUM_LANES = 8;

// compensatedSum, replicated verbatim from stats.zig for isolation.
const Compensated = struct {
    sum: f64 = 0,
    c: f64 = 0,
    fn add(self: *Compensated, x: f64) void {
        const t = self.sum + x;
        if (@abs(self.sum) >= @abs(x)) {
            self.c += (self.sum - t) + x;
        } else {
            self.c += (x - t) + self.sum;
        }
        self.sum = t;
    }
    fn value(self: *const Compensated) f64 {
        return self.sum + self.c;
    }
};

fn compensatedSum(data: []const f64) f64 {
    const V = @Vector(SUM_LANES, f64);
    var total: V = @splat(0);
    var c: V = @splat(0);
    var i: usize = 0;
    while (i + SUM_LANES <= data.len) : (i += SUM_LANES) {
        const x: V = data[i..][0..SUM_LANES].*;
        const t = total + x;
        c += @select(f64, @abs(total) >= @abs(x), (total - t) + x, (x - t) + total);
        total = t;
    }
    const lanes: [SUM_LANES]f64 = total + c;
    var acc = Compensated{};
    for (lanes) |v| acc.add(v);
    while (i < data.len) : (i += 1) acc.add(data[i]);
    return acc.value();
}

fn centeredSS(data: []const f64, mean: f64) f64 {
    var acc = Compensated{};
    for (data) |v| {
        const d = v - mean;
        acc.add(d * d);
    }
    return acc.value();
}

const Job = struct {
    data: []const f64,
    mean: f64,
    out: *f64,
    which: u8, // 0 sum, 1 css
    fn run(self: *const Job) void {
        self.out.* = if (self.which == 0) compensatedSum(self.data) else centeredSS(self.data, self.mean);
    }
};

fn threaded(data: []const f64, mean: f64, which: u8, nt: usize, partials: []f64, jobs: []Job, ths: []std.Thread) !f64 {
    const chunk = data.len / nt;
    for (0..nt) |t| {
        const lo = t * chunk;
        const hi = if (t == nt - 1) data.len else lo + chunk;
        jobs[t] = .{ .data = data[lo..hi], .mean = mean, .out = &partials[t], .which = which };
        ths[t] = try std.Thread.spawn(.{}, Job.run, .{&jobs[t]});
    }
    for (ths[0..nt]) |th| th.join();
    var acc = Compensated{};
    for (partials[0..nt]) |p| acc.add(p);
    return acc.value();
}

fn ms(ns: u64) f64 {
    return @as(f64, @floatFromInt(ns)) / 1_000_000.0;
}

pub fn main() !void {
    var gpa_state = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa_state.allocator();
    var timer = try std.time.Timer.start();
    const REPS = 5;

    // S2 first: the pathological case through the threaded path.
    {
        var patho: [4096]f64 = undefined;
        patho[0] = 1e16;
        for (patho[1..]) |*v| v.* = 1.0;
        var partials: [12]f64 = undefined;
        var jobs: [12]Job = undefined;
        var ths: [12]std.Thread = undefined;
        const want = 1e16 + 4095.0;
        const got8 = try threaded(&patho, 0, 0, 8, &partials, &jobs, &ths);
        const got3 = try threaded(&patho, 0, 0, 3, &partials, &jobs, &ths); // uneven chunks
        std.debug.print("S2 pathological: serial={d} T8={d} T3={d} exact={}\n\n", .{ compensatedSum(&patho), got8, got3, got8 == want and got3 == want });
        if (got8 != want or got3 != want) return error.AccuracyLost;
    }

    var partials: [12]f64 = undefined;
    var jobs: [12]Job = undefined;
    var ths: [12]std.Thread = undefined;

    for ([_]usize{ 256 * 1024, 1024 * 1024, 4 * 1024 * 1024, 16 * 1024 * 1024 }) |n| {
        const data = try alloc.alloc(f64, n);
        defer alloc.free(data);
        var seed: u64 = 5;
        for (data) |*v| {
            seed = seed *% 6364136223846793005 +% 1442695040888963407;
            v.* = @as(f64, @floatFromInt((seed >> 33) % 1000)) / 999.0 - 0.5;
        }

        inline for ([_]u8{ 0, 1 }) |which| {
            const name = if (which == 0) "csum" else "css ";
            var t_ser: u64 = std.math.maxInt(u64);
            var ref: f64 = 0;
            for (0..REPS) |_| {
                timer.reset();
                ref = if (which == 0) compensatedSum(data) else centeredSS(data, 0.25);
                std.mem.doNotOptimizeAway(&ref);
                t_ser = @min(t_ser, timer.read());
            }
            std.debug.print("{s} n={d:>9}: serial {d:7.2} ms  ", .{ name, n, ms(t_ser) });
            for ([_]usize{ 4, 8 }) |nt| {
                var t_par: u64 = std.math.maxInt(u64);
                var got: f64 = 0;
                for (0..REPS) |_| {
                    timer.reset();
                    got = try threaded(data, 0.25, which, nt, &partials, &jobs, &ths);
                    std.mem.doNotOptimizeAway(&got);
                    t_par = @min(t_par, timer.read());
                }
                const sp = @as(f64, @floatFromInt(t_ser)) / @as(f64, @floatFromInt(t_par));
                const rel = if (ref != 0) @abs(got - ref) / @abs(ref) else @abs(got - ref);
                std.debug.print("T{d}={d:4.2}x(rel {e:8.1}) ", .{ nt, sp, rel });
            }
            std.debug.print("\n", .{});
        }
    }
}
