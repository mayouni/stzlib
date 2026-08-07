const std = @import("std");
const calib = @import("calib.zig");
const allocator = std.heap.c_allocator;
const math = std.math;

pub const StzStats = struct {
    data: []f64,
    sorted: []f64,
    n: usize,

    pub fn init(values: []const f64) !*StzStats {
        const self = try allocator.create(StzStats);
        self.n = values.len;
        self.data = try allocator.alloc(f64, self.n);
        @memcpy(self.data, values);
        self.sorted = try allocator.alloc(f64, self.n);
        @memcpy(self.sorted, values);
        std.mem.sort(f64, self.sorted, {}, std.sort.asc(f64));
        return self;
    }

    pub fn deinit(self: *StzStats) void {
        allocator.free(self.data);
        allocator.free(self.sorted);
        allocator.destroy(self);
    }
};

// ─── Helpers ───

// ── THE SUMMATION LIVES HERE, AND ONLY HERE ────────────────────────────
//
// Adding f64s left to right silently loses the low bits of every addend once
// the running total grows large relative to them. Sum 1e16 and then a thousand
// 1.0s and a naive loop answers exactly 1e16: each 1.0 falls off the end of the
// mantissa and is gone. NEUMAIER COMPENSATION carries that lost part in a second
// accumulator and adds it back at the end -- one extra add per element, and an
// error class that is invisible until the data gets big simply disappears.
//
// It is defined once because it was, briefly, defined twice. numbuf.zig arrived
// with a compensated sum while this module and list.zig kept naive ones, so the
// SAME 1001 numbers gave two different answers depending on which door they went
// through:
//
//     stzListOfNumbers.Sum()  ->  10000000000000000     the thousand ones lost
//     stzDataSet.Sum()        ->  10000000000000000     lost again
//     stzNumBuffer.Sum()      ->  10000000000001000     right
//
// Same disease as the variance divisor below, in a new place, and introduced by
// the very phase that added the correct version. So: one authority, and everyone
// asks it.
//
// Two shapes, because callers store their numbers differently. Slices use
// `compensatedSum`; anything that must filter or convert as it walks (list.zig
// skips non-numeric items, and has separate int/float/generic representations)
// feeds `Compensated` one value at a time.
pub const Compensated = struct {
    total: f64 = 0,
    c: f64 = 0,

    pub fn add(self: *Compensated, x: f64) void {
        const t = self.total + x;
        if (@abs(self.total) >= @abs(x)) {
            self.c += (self.total - t) + x;
        } else {
            self.c += (x - t) + self.total;
        }
        self.total = t;
    }

    pub fn value(self: Compensated) f64 {
        return self.total + self.c;
    }
};

// The vector width for the lane-parallel form below. Eight f64s is 512 bits --
// one AVX-512 register, two AVX2 registers, four NEON. @Vector lowers to whatever
// the target actually has, so this is a tuning number and not a portability one.
const SUM_LANES = 8;

// --- Threaded reductions (M3 of the multicore tier) ---
//
// Per-thread chunks run the SAME compensated kernels below and the partials
// are combined compensated -- threads are just BIGGER independent groups
// than the SIMD lanes this file already justified ("summing in several
// independent groups is if anything better conditioned"). The pathological
// case stays EXACT through the threaded path, uneven chunks included; the
// tests pin it. Worst observed grouping drift on mixed-sign data: ~1e-14
// relative, the same order the lane split already introduces.
//
// GATES FROM MEASUREMENT (tools/stats_spike.zig, two runs, ship bar =
// >= 1.5x on BOTH):
//
//     compensatedSum   256k 0.14-0.21x | 1M ~1.0x | 4M 1.6-1.8x | 16M 2.2-2.5x
//     centeredSS       256k 0.54-0.94x | 1M 1.6-1.9x | 4M 2.5-3.0x | 16M 2.8-3.9x
//
// The heavier kernel admits earlier (more work per element amortises the
// spawn), which is why the two gates differ. PROVISIONAL until M5's shared
// calibration store. Tests may lower them.
pub var sum_gate = calib.Gate.init("cpu.stats.sum_par_min_n", 4 * 1024 * 1024);
pub var css_gate = calib.Gate.init("cpu.stats.css_par_min_n", 1024 * 1024);
const STATS_WORKERS = 8;

const RedJob = struct {
    data: []const f64,
    mean: f64,
    out: *f64,
    which: u8, // 0 = compensated sum, 1 = centered sum of squares
    fn run(self: *const RedJob) void {
        self.out.* = if (self.which == 0)
            compensatedSumSerial(self.data)
        else
            centeredSumOfSquaresSerial(self.data, self.mean);
    }
};

fn threadedReduce(data: []const f64, mean: f64, which: u8) ?f64 {
    const cpus = std.Thread.getCpuCount() catch return null;
    const nt = @min(STATS_WORKERS, cpus);
    if (nt < 2) return null;
    var partials: [STATS_WORKERS]f64 = undefined;
    var jobs: [STATS_WORKERS]RedJob = undefined;
    var threads: [STATS_WORKERS]std.Thread = undefined;
    const chunk = data.len / nt;
    var spawned: usize = 0;
    for (0..nt) |t| {
        const lo = t * chunk;
        const hi = if (t == nt - 1) data.len else lo + chunk;
        jobs[t] = .{ .data = data[lo..hi], .mean = mean, .out = &partials[t], .which = which };
        // Compact handles (threads[spawned], not threads[t]): a failed spawn
        // computes its chunk inline, and an index-aligned join would join an
        // UNDEFINED slot -- the M1 lesson, kept.
        threads[spawned] = std.Thread.spawn(.{}, RedJob.run, .{&jobs[t]}) catch {
            jobs[t].run();
            continue;
        };
        spawned += 1;
    }
    for (threads[0..spawned]) |th| th.join();
    var acc = Compensated{};
    for (partials[0..nt]) |v| acc.add(v);
    return acc.value();
}

/// THE SUMMATION. Lane-parallel Neumaier: SUM_LANES independent compensated
/// accumulators run down the data at once and are combined -- themselves
/// compensated -- at the end.
///
/// WHY THIS IS THE VECTORISED ONE, when the naive sum is the more obvious
/// candidate. The compensated loop carries a dependence: every step reads the
/// running total the previous step wrote, so LLVM cannot unroll it into parallel
/// lanes the way it partly can with a plain `s += x`. BEING CAREFUL IS WHAT
/// BLOCKED THE COMPILER. Splitting into lanes gives the parallelism back, and
/// measured over 4M f64s at ReleaseSafe, thirty passes:
///
///     sum naive          scalar  67.6ms   @Vector(8)  35.8ms   1.9x
///     sum COMPENSATED    scalar 145.1ms   @Vector(8)  58.5ms   2.5x
///     dot                scalar  77.5ms   @Vector(8)  62.9ms   1.2x
///
/// So the algorithm we chose for correctness gains the most from vectorising, and
/// ends up costing little more than the naive one it replaced. (Dot gains least
/// because it streams two arrays and is bandwidth-bound, not compute-bound.)
///
/// ACCURACY IS NOT TRADED FOR SPEED. Each lane compensates its own subtotal and
/// the final combine compensates again, so this sums no worse than the scalar
/// form -- summing in several independent groups is if anything better
/// conditioned. The pathological case is pinned by a test below.
pub fn compensatedSum(data: []const f64) f64 {
    if (data.len >= sum_gate.valueUsize()) {
        if (threadedReduce(data, 0, 0)) |v| return v;
    }
    return compensatedSumSerial(data);
}

fn compensatedSumSerial(data: []const f64) f64 {
    const V = @Vector(SUM_LANES, f64);
    var total: V = @splat(0);
    var c: V = @splat(0);

    var i: usize = 0;
    while (i + SUM_LANES <= data.len) : (i += SUM_LANES) {
        const x: V = data[i..][0..SUM_LANES].*;
        const t = total + x;
        // per lane: if |total| >= |x| the low bits of x were lost, else those of
        // total were -- the same branch as the scalar form, chosen lane-wise
        c += @select(f64, @abs(total) >= @abs(x), (total - t) + x, (x - t) + total);
        total = t;
    }

    // combine the lanes, and the tail, through the scalar accumulator so the
    // compensation is not dropped at the seam
    const lanes: [SUM_LANES]f64 = total + c;
    var acc = Compensated{};
    for (lanes) |v| acc.add(v);
    while (i < data.len) : (i += 1) acc.add(data[i]);
    return acc.value();
}

fn computeMean(data: []const f64) f64 {
    if (data.len == 0) return 0;
    return compensatedSum(data) / @as(f64, @floatFromInt(data.len));
}

// ── THE VARIANCE CONVENTION LIVES HERE, AND ONLY HERE ──────────────────
//
// "Variance" is ambiguous: divide the sum of squares by N (you are describing
// the whole population) or by N-1 (you are estimating a population from a
// sample). Both are correct; picking silently is not. list.zig used to divide
// by N while this module divided by N-1, so stzList.Variance() answered 4 where
// stzDataSet.Variance() answered 4.57 for the same data, and neither said which
// it meant.
//
// So the DIVISOR -- the only genuinely ambiguous part -- is defined once, here,
// and every caller in the engine asks for it by name.
//
// The sum-of-squares loop was ORIGINALLY left with its data, on the reasoning that
// only the divisor was ever in doubt. That was a mistake of a milder kind: nobody
// disagreed about the arithmetic, but it still ended up written out FIVE times,
// and the fifth (pivot.zig) quietly hardcoded its own divisor as well and summed
// without compensation. Duplication invites divergence even where there is no
// ambiguity to diverge about, so it lives here too now -- see
// centeredSumOfSquaresOf below, which is generic over the element type so that
// list.zig's dense i64 and dense f64 storage share the one implementation.
//
// THE DEFAULT IS SAMPLE (N-1), matching this module's long-standing behaviour,
// stzDataSet, R's var() and pandas' .var(). NumPy's np.var defaults to
// population, which is exactly why a library must name its choice.
pub const VarianceKind = enum { population, sample };

/// The divisor for a given count and convention. 0 when undefined (a sample
/// variance needs at least two observations; a population variance needs one).
pub fn varianceDivisor(count: usize, kind: VarianceKind) f64 {
    return switch (kind) {
        .population => if (count < 1) 0 else @as(f64, @floatFromInt(count)),
        .sample => if (count < 2) 0 else @as(f64, @floatFromInt(count - 1)),
    };
}

/// The centered sum of squares, vectorised. The second half of every variance,
/// standard deviation, coefficient of variation and z-score in the library.
///
/// It was written out FIVE times -- here, numbuf.zig, list.zig and twice in
/// pivot.zig -- which is the same disease the divisor below and the summation
/// above were each cured of. Measured over 4M f64s, thirty passes: scalar 66.2ms,
/// @Vector(8) 36.0ms, 1.8x.
///
/// NO CHAN-GOLUB-LEVEQUE CORRECTION, and that is a measured decision rather than
/// an omission. The textbook improvement to a two-pass variance also accumulates
/// the sum of deviations -- zero in exact arithmetic, so what remains measures the
/// error in the mean -- and subtracts its square. Implemented and benchmarked, it
/// cost 11% (40.1ms) and changed no digit of the answer on either well- or
/// badly-conditioned data (values offset by 1e9 with unit spread). The reason is
/// pleasing: THE MEAN IS ALREADY COMPENSATED, so the correction has nothing left
/// to correct. Fixing the summation authority upstream removed the need for the
/// patch downstream.
/// Generic over the element type so that ONE implementation serves every dense
/// storage the library has. list.zig keeps its numbers as dense i64 or dense f64
/// depending on what Ring handed it, and both want this loop -- writing it twice
/// to satisfy the type system is how five copies happened in the first place.
pub fn centeredSumOfSquaresOf(comptime T: type, data: []const T, mean: f64) f64 {
    const V = @Vector(SUM_LANES, f64);
    const vm: V = @splat(mean);
    var acc: V = @splat(0);

    var i: usize = 0;
    while (i + SUM_LANES <= data.len) : (i += SUM_LANES) {
        const chunk: @Vector(SUM_LANES, T) = data[i..][0..SUM_LANES].*;
        const as_f: V = if (T == f64) chunk else @floatFromInt(chunk);
        const d = as_f - vm;
        acc += d * d;
    }

    var ss = @reduce(.Add, acc);
    while (i < data.len) : (i += 1) {
        const x: f64 = if (T == f64) data[i] else @floatFromInt(data[i]);
        const d = x - mean;
        ss += d * d;
    }
    return ss;
}

pub fn centeredSumOfSquares(data: []const f64, mean: f64) f64 {
    if (data.len >= css_gate.valueUsize()) {
        if (threadedReduce(data, mean, 1)) |v| return v;
    }
    return centeredSumOfSquaresSerial(data, mean);
}

fn centeredSumOfSquaresSerial(data: []const f64, mean: f64) f64 {
    return centeredSumOfSquaresOf(f64, data, mean);
}

/// A variance, end to end: the compensated mean, the vectorised centered sum of
/// squares, and the divisor for the named convention. THE one place a variance is
/// computed from a slice -- every caller in the engine that holds contiguous f64s
/// asks this rather than assembling its own three pieces.
pub fn varianceOf(data: []const f64, kind: VarianceKind) f64 {
    const divisor = varianceDivisor(data.len, kind);
    if (divisor == 0) return 0;
    return centeredSumOfSquares(data, computeMean(data)) / divisor;
}

fn computeVarianceKind(data: []const f64, mean: f64, kind: VarianceKind) f64 {
    const divisor = varianceDivisor(data.len, kind);
    if (divisor == 0) return 0;
    return centeredSumOfSquares(data, mean) / divisor;
}

fn computeVariance(data: []const f64, mean: f64) f64 {
    return computeVarianceKind(data, mean, .sample);
}

fn computePercentile(sorted: []const f64, p: f64) f64 {
    if (sorted.len == 0) return 0;
    if (sorted.len == 1) return sorted[0];
    const n_f: f64 = @floatFromInt(sorted.len);
    const rank = p / 100.0 * (n_f - 1.0);
    const lo: usize = @intFromFloat(@floor(rank));
    const hi: usize = @min(lo + 1, sorted.len - 1);
    const frac = rank - @floor(rank);
    return sorted[lo] * (1.0 - frac) + sorted[hi] * frac;
}

// ─── C ABI ───

pub fn stz_stats_create(ptr: [*]const f64, len: usize) callconv(.c) ?*StzStats {
    if (len == 0) return null;
    return StzStats.init(ptr[0..len]) catch null;
}

pub fn stz_stats_free(s: ?*StzStats) callconv(.c) void {
    if (s) |st| st.deinit();
}

pub fn stz_stats_count(s: ?*const StzStats) callconv(.c) usize {
    const st = s orelse return 0;
    return st.n;
}

pub fn stz_stats_mean(s: ?*const StzStats) callconv(.c) f64 {
    const st = s orelse return 0;
    return computeMean(st.data);
}

pub fn stz_stats_sum(s: ?*const StzStats) callconv(.c) f64 {
    const st = s orelse return 0;
    return compensatedSum(st.data);
}

pub fn stz_stats_min(s: ?*const StzStats) callconv(.c) f64 {
    const st = s orelse return 0;
    if (st.n == 0) return 0;
    return st.sorted[0];
}

pub fn stz_stats_max(s: ?*const StzStats) callconv(.c) f64 {
    const st = s orelse return 0;
    if (st.n == 0) return 0;
    return st.sorted[st.n - 1];
}

pub fn stz_stats_range(s: ?*const StzStats) callconv(.c) f64 {
    const st = s orelse return 0;
    if (st.n == 0) return 0;
    return st.sorted[st.n - 1] - st.sorted[0];
}

pub fn stz_stats_median(s: ?*const StzStats) callconv(.c) f64 {
    const st = s orelse return 0;
    return computePercentile(st.sorted, 50.0);
}

/// The documented default: SAMPLE variance (N-1). Prefer the explicitly named
/// twins below in new code -- a reader should not have to know the default.
pub fn stz_stats_variance(s: ?*const StzStats) callconv(.c) f64 {
    return stz_stats_variance_sample(s);
}

pub fn stz_stats_std_dev(s: ?*const StzStats) callconv(.c) f64 {
    return stz_stats_std_dev_sample(s);
}

pub fn stz_stats_variance_sample(s: ?*const StzStats) callconv(.c) f64 {
    const st = s orelse return 0;
    return computeVarianceKind(st.data, computeMean(st.data), .sample);
}

pub fn stz_stats_variance_population(s: ?*const StzStats) callconv(.c) f64 {
    const st = s orelse return 0;
    return computeVarianceKind(st.data, computeMean(st.data), .population);
}

pub fn stz_stats_std_dev_sample(s: ?*const StzStats) callconv(.c) f64 {
    return @sqrt(stz_stats_variance_sample(s));
}

pub fn stz_stats_std_dev_population(s: ?*const StzStats) callconv(.c) f64 {
    return @sqrt(stz_stats_variance_population(s));
}

pub fn stz_stats_coeff_of_variation(s: ?*const StzStats) callconv(.c) f64 {
    const st = s orelse return 0;
    const m = computeMean(st.data);
    if (m == 0) return 0;
    return (@sqrt(computeVariance(st.data, m)) / @abs(m)) * 100.0;
}

pub fn stz_stats_percentile(s: ?*const StzStats, p: f64) callconv(.c) f64 {
    const st = s orelse return 0;
    return computePercentile(st.sorted, p);
}

pub fn stz_stats_q1(s: ?*const StzStats) callconv(.c) f64 {
    const st = s orelse return 0;
    return computePercentile(st.sorted, 25.0);
}

pub fn stz_stats_q2(s: ?*const StzStats) callconv(.c) f64 {
    const st = s orelse return 0;
    return computePercentile(st.sorted, 50.0);
}

pub fn stz_stats_q3(s: ?*const StzStats) callconv(.c) f64 {
    const st = s orelse return 0;
    return computePercentile(st.sorted, 75.0);
}

pub fn stz_stats_iqr(s: ?*const StzStats) callconv(.c) f64 {
    const st = s orelse return 0;
    return computePercentile(st.sorted, 75.0) - computePercentile(st.sorted, 25.0);
}

pub fn stz_stats_skewness(s: ?*const StzStats) callconv(.c) f64 {
    const st = s orelse return 0;
    if (st.n < 3) return 0;
    const m = computeMean(st.data);
    const sd = @sqrt(computeVariance(st.data, m));
    if (sd == 0) return 0;
    const n_f: f64 = @floatFromInt(st.n);
    var sum3: f64 = 0;
    for (st.data) |v| {
        const d = (v - m) / sd;
        sum3 += d * d * d;
    }
    return (n_f / ((n_f - 1.0) * (n_f - 2.0))) * sum3;
}

pub fn stz_stats_kurtosis(s: ?*const StzStats) callconv(.c) f64 {
    const st = s orelse return 0;
    if (st.n < 4) return 0;
    const m = computeMean(st.data);
    const sd = @sqrt(computeVariance(st.data, m));
    if (sd == 0) return 0;
    const n_f: f64 = @floatFromInt(st.n);
    var sum4: f64 = 0;
    for (st.data) |v| {
        const d = (v - m) / sd;
        sum4 += d * d * d * d;
    }
    const k = (n_f * (n_f + 1.0)) / ((n_f - 1.0) * (n_f - 2.0) * (n_f - 3.0)) * sum4;
    return k - (3.0 * (n_f - 1.0) * (n_f - 1.0)) / ((n_f - 2.0) * (n_f - 3.0));
}

pub fn stz_stats_geometric_mean(s: ?*const StzStats) callconv(.c) f64 {
    const st = s orelse return 0;
    if (st.n == 0) return 0;
    var log_sum: f64 = 0;
    for (st.data) |v| {
        if (v <= 0) return 0;
        log_sum += @log(v);
    }
    return @exp(log_sum / @as(f64, @floatFromInt(st.n)));
}

pub fn stz_stats_harmonic_mean(s: ?*const StzStats) callconv(.c) f64 {
    const st = s orelse return 0;
    if (st.n == 0) return 0;
    var recip_sum: f64 = 0;
    for (st.data) |v| {
        if (v == 0) return 0;
        recip_sum += 1.0 / v;
    }
    return @as(f64, @floatFromInt(st.n)) / recip_sum;
}

pub fn stz_stats_z_scores(s: ?*const StzStats, buf: [*]f64, buf_len: usize) callconv(.c) usize {
    const st = s orelse return 0;
    const m = computeMean(st.data);
    const sd = @sqrt(computeVariance(st.data, m));
    if (sd == 0) return 0;
    const copy_len = @min(st.n, buf_len);
    for (0..copy_len) |i| {
        buf[i] = (st.data[i] - m) / sd;
    }
    return copy_len;
}

pub fn stz_stats_outliers(s: ?*const StzStats, buf: [*]f64, buf_len: usize) callconv(.c) usize {
    const st = s orelse return 0;
    const q1 = computePercentile(st.sorted, 25.0);
    const q3 = computePercentile(st.sorted, 75.0);
    const iqr = q3 - q1;
    const lower = q1 - 1.5 * iqr;
    const upper = q3 + 1.5 * iqr;
    var count: usize = 0;
    for (st.data) |v| {
        if (v < lower or v > upper) {
            if (count < buf_len) {
                buf[count] = v;
            }
            count += 1;
        }
    }
    return count;
}

pub fn stz_stats_contains_outliers(s: ?*const StzStats) callconv(.c) i32 {
    const st = s orelse return 0;
    const q1 = computePercentile(st.sorted, 25.0);
    const q3 = computePercentile(st.sorted, 75.0);
    const iqr = q3 - q1;
    const lower = q1 - 1.5 * iqr;
    const upper = q3 + 1.5 * iqr;
    for (st.data) |v| {
        if (v < lower or v > upper) return 1;
    }
    return 0;
}

pub fn stz_stats_mode(s: ?*const StzStats, buf: [*]f64, buf_len: usize) callconv(.c) usize {
    const st = s orelse return 0;
    if (st.n == 0) return 0;
    var max_count: usize = 0;
    var i: usize = 0;
    while (i < st.sorted.len) {
        var count: usize = 1;
        while (i + count < st.sorted.len and st.sorted[i + count] == st.sorted[i]) : (count += 1) {}
        if (count > max_count) max_count = count;
        i += count;
    }
    if (max_count <= 1) return 0;
    var out: usize = 0;
    i = 0;
    while (i < st.sorted.len) {
        var count: usize = 1;
        while (i + count < st.sorted.len and st.sorted[i + count] == st.sorted[i]) : (count += 1) {}
        if (count == max_count and out < buf_len) {
            buf[out] = st.sorted[i];
            out += 1;
        }
        i += count;
    }
    return out;
}

pub fn stz_stats_trimmed_mean(s: ?*const StzStats, trim_pct: f64) callconv(.c) f64 {
    const st = s orelse return 0;
    if (st.n == 0) return 0;
    const trim_n: usize = @intFromFloat(@floor(@as(f64, @floatFromInt(st.n)) * trim_pct / 100.0));
    if (trim_n * 2 >= st.n) return computeMean(st.data);
    const trimmed = st.sorted[trim_n .. st.n - trim_n];
    return computeMean(trimmed);
}

pub fn stz_stats_weighted_mean(data: [*]const f64, weights: [*]const f64, len: usize) callconv(.c) f64 {
    if (len == 0) return 0;
    var wsum: f64 = 0;
    var vwsum: f64 = 0;
    for (0..len) |i| {
        vwsum += data[i] * weights[i];
        wsum += weights[i];
    }
    if (wsum == 0) return 0;
    return vwsum / wsum;
}

pub fn stz_stats_normalize(s: ?*const StzStats, buf: [*]f64, buf_len: usize) callconv(.c) usize {
    const st = s orelse return 0;
    if (st.n == 0) return 0;
    const mn = st.sorted[0];
    const mx = st.sorted[st.n - 1];
    const rng = mx - mn;
    const copy_len = @min(st.n, buf_len);
    for (0..copy_len) |i| {
        buf[i] = if (rng == 0) 0 else (st.data[i] - mn) / rng;
    }
    return copy_len;
}

pub fn stz_stats_standardize(s: ?*const StzStats, buf: [*]f64, buf_len: usize) callconv(.c) usize {
    const st = s orelse return 0;
    const m = computeMean(st.data);
    const sd = @sqrt(computeVariance(st.data, m));
    if (sd == 0) return 0;
    const copy_len = @min(st.n, buf_len);
    for (0..copy_len) |i| {
        buf[i] = (st.data[i] - m) / sd;
    }
    return copy_len;
}

pub fn stz_stats_moving_average(s: ?*const StzStats, window: usize, buf: [*]f64, buf_len: usize) callconv(.c) usize {
    const st = s orelse return 0;
    if (st.n == 0 or window == 0 or window > st.n) return 0;
    const result_len = st.n - window + 1;
    const copy_len = @min(result_len, buf_len);
    var running_sum: f64 = 0;
    for (0..window) |i| running_sum += st.data[i];
    const w_f: f64 = @floatFromInt(window);
    if (copy_len > 0) buf[0] = running_sum / w_f;
    for (1..copy_len) |i| {
        running_sum += st.data[i + window - 1] - st.data[i - 1];
        buf[i] = running_sum / w_f;
    }
    return copy_len;
}

pub fn stz_stats_correlation(s1: ?*const StzStats, s2: ?*const StzStats) callconv(.c) f64 {
    const a = s1 orelse return 0;
    const b = s2 orelse return 0;
    const n = @min(a.n, b.n);
    if (n < 2) return 0;
    const ma = computeMean(a.data[0..n]);
    const mb = computeMean(b.data[0..n]);
    var cov: f64 = 0;
    var va: f64 = 0;
    var vb: f64 = 0;
    for (0..n) |i| {
        const da = a.data[i] - ma;
        const db = b.data[i] - mb;
        cov += da * db;
        va += da * da;
        vb += db * db;
    }
    const denom = @sqrt(va * vb);
    if (denom == 0) return 0;
    return cov / denom;
}

pub fn stz_stats_covariance(s1: ?*const StzStats, s2: ?*const StzStats) callconv(.c) f64 {
    const a = s1 orelse return 0;
    const b = s2 orelse return 0;
    const n = @min(a.n, b.n);
    if (n < 2) return 0;
    const ma = computeMean(a.data[0..n]);
    const mb = computeMean(b.data[0..n]);
    var cov: f64 = 0;
    for (0..n) |i| {
        cov += (a.data[i] - ma) * (b.data[i] - mb);
    }
    return cov / @as(f64, @floatFromInt(n - 1));
}

pub fn stz_stats_regression(s1: ?*const StzStats, s2: ?*const StzStats, slope: *f64, intercept: *f64) callconv(.c) i32 {
    const a = s1 orelse return 0;
    const b = s2 orelse return 0;
    const n = @min(a.n, b.n);
    if (n < 2) return 0;
    const ma = computeMean(a.data[0..n]);
    const mb = computeMean(b.data[0..n]);
    var ss_xy: f64 = 0;
    var ss_xx: f64 = 0;
    for (0..n) |i| {
        const da = a.data[i] - ma;
        ss_xy += da * (b.data[i] - mb);
        ss_xx += da * da;
    }
    if (ss_xx == 0) return 0;
    slope.* = ss_xy / ss_xx;
    intercept.* = mb - slope.* * ma;
    return 1;
}

pub fn stz_stats_rank_correlation(s1: ?*const StzStats, s2: ?*const StzStats) callconv(.c) f64 {
    const a = s1 orelse return 0;
    const b = s2 orelse return 0;
    const n = @min(a.n, b.n);
    if (n < 2) return 0;
    const ranks_a = allocator.alloc(f64, n) catch return 0;
    defer allocator.free(ranks_a);
    const ranks_b = allocator.alloc(f64, n) catch return 0;
    defer allocator.free(ranks_b);
    computeRanks(a.data[0..n], ranks_a);
    computeRanks(b.data[0..n], ranks_b);
    var d2_sum: f64 = 0;
    for (0..n) |i| {
        const d = ranks_a[i] - ranks_b[i];
        d2_sum += d * d;
    }
    const n_f: f64 = @floatFromInt(n);
    return 1.0 - (6.0 * d2_sum) / (n_f * (n_f * n_f - 1.0));
}

fn computeRanks(data: []const f64, ranks: []f64) void {
    const n = data.len;
    const indices = allocator.alloc(usize, n) catch return;
    defer allocator.free(indices);
    for (0..n) |i| indices[i] = i;
    std.mem.sort(usize, indices, data, struct {
        fn cmp(d: []const f64, ia: usize, ib: usize) bool {
            return d[ia] < d[ib];
        }
    }.cmp);
    var i: usize = 0;
    while (i < n) {
        var j = i + 1;
        while (j < n and data[indices[j]] == data[indices[i]]) : (j += 1) {}
        const avg_rank: f64 = @as(f64, @floatFromInt(i + j)) / 2.0 + 0.5;
        for (i..j) |k| ranks[indices[k]] = avg_rank;
        i = j;
    }
}

pub fn stz_stats_deciles(s: ?*const StzStats, buf: [*]f64, buf_len: usize) callconv(.c) usize {
    const st = s orelse return 0;
    const count = @min(@as(usize, 9), buf_len);
    for (0..count) |i| {
        buf[i] = computePercentile(st.sorted, @as(f64, @floatFromInt(i + 1)) * 10.0);
    }
    return count;
}

pub fn stz_stats_frequency(s: ?*const StzStats, values: [*]f64, counts: [*]usize, buf_len: usize) callconv(.c) usize {
    const st = s orelse return 0;
    if (st.n == 0) return 0;
    var out: usize = 0;
    var i: usize = 0;
    while (i < st.sorted.len and out < buf_len) {
        var count: usize = 1;
        while (i + count < st.sorted.len and st.sorted[i + count] == st.sorted[i]) : (count += 1) {}
        values[out] = st.sorted[i];
        counts[out] = count;
        out += 1;
        i += count;
    }
    return out;
}

// ─── Tests ───

test "stats basic" {
    const data = [_]f64{ 2, 4, 4, 4, 5, 5, 7, 9 };
    const s = stz_stats_create(&data, data.len) orelse return error.CreateFailed;
    defer stz_stats_free(s);

    try std.testing.expectEqual(@as(usize, 8), stz_stats_count(s));
    try std.testing.expectApproxEqAbs(@as(f64, 5.0), stz_stats_mean(s), 0.001);
    try std.testing.expectApproxEqAbs(@as(f64, 40.0), stz_stats_sum(s), 0.001);
    try std.testing.expectApproxEqAbs(@as(f64, 2.0), stz_stats_min(s), 0.001);
    try std.testing.expectApproxEqAbs(@as(f64, 9.0), stz_stats_max(s), 0.001);
    try std.testing.expectApproxEqAbs(@as(f64, 7.0), stz_stats_range(s), 0.001);
}

test "stats median" {
    const odd = [_]f64{ 1, 3, 5, 7, 9 };
    const s1 = stz_stats_create(&odd, odd.len) orelse return error.CreateFailed;
    defer stz_stats_free(s1);
    try std.testing.expectApproxEqAbs(@as(f64, 5.0), stz_stats_median(s1), 0.001);

    const even = [_]f64{ 1, 2, 3, 4 };
    const s2 = stz_stats_create(&even, even.len) orelse return error.CreateFailed;
    defer stz_stats_free(s2);
    try std.testing.expectApproxEqAbs(@as(f64, 2.5), stz_stats_median(s2), 0.001);
}

test "stats variance and std dev" {
    const data = [_]f64{ 2, 4, 4, 4, 5, 5, 7, 9 };
    const s = stz_stats_create(&data, data.len) orelse return error.CreateFailed;
    defer stz_stats_free(s);
    try std.testing.expectApproxEqAbs(@as(f64, 4.571), stz_stats_variance(s), 0.01);
    try std.testing.expectApproxEqAbs(@as(f64, 2.138), stz_stats_std_dev(s), 0.01);
}

test "stats quartiles" {
    const data = [_]f64{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    const s = stz_stats_create(&data, data.len) orelse return error.CreateFailed;
    defer stz_stats_free(s);
    try std.testing.expectApproxEqAbs(@as(f64, 3.25), stz_stats_q1(s), 0.001);
    try std.testing.expectApproxEqAbs(@as(f64, 5.5), stz_stats_q2(s), 0.001);
    try std.testing.expectApproxEqAbs(@as(f64, 7.75), stz_stats_q3(s), 0.001);
    try std.testing.expectApproxEqAbs(@as(f64, 4.5), stz_stats_iqr(s), 0.001);
}

test "stats skewness and kurtosis" {
    const data = [_]f64{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    const s = stz_stats_create(&data, data.len) orelse return error.CreateFailed;
    defer stz_stats_free(s);
    try std.testing.expectApproxEqAbs(@as(f64, 0.0), stz_stats_skewness(s), 0.01);
    try std.testing.expectApproxEqAbs(@as(f64, -1.2), stz_stats_kurtosis(s), 0.1);
}

test "stats geometric and harmonic mean" {
    const data = [_]f64{ 2, 4, 8 };
    const s = stz_stats_create(&data, data.len) orelse return error.CreateFailed;
    defer stz_stats_free(s);
    try std.testing.expectApproxEqAbs(@as(f64, 4.0), stz_stats_geometric_mean(s), 0.001);
    try std.testing.expectApproxEqAbs(@as(f64, 3.4285), stz_stats_harmonic_mean(s), 0.01);
}

test "stats mode" {
    const data = [_]f64{ 1, 2, 2, 3, 3, 4 };
    const s = stz_stats_create(&data, data.len) orelse return error.CreateFailed;
    defer stz_stats_free(s);
    var buf: [10]f64 = undefined;
    const n = stz_stats_mode(s, &buf, 10);
    try std.testing.expectEqual(@as(usize, 2), n);
    try std.testing.expectApproxEqAbs(@as(f64, 2.0), buf[0], 0.001);
    try std.testing.expectApproxEqAbs(@as(f64, 3.0), buf[1], 0.001);
}

test "stats outliers" {
    const data = [_]f64{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 100 };
    const s = stz_stats_create(&data, data.len) orelse return error.CreateFailed;
    defer stz_stats_free(s);
    try std.testing.expectEqual(@as(i32, 1), stz_stats_contains_outliers(s));
    var buf: [10]f64 = undefined;
    const n = stz_stats_outliers(s, &buf, 10);
    try std.testing.expect(n >= 1);
    try std.testing.expectApproxEqAbs(@as(f64, 100.0), buf[0], 0.001);
}

test "stats z-scores" {
    const data = [_]f64{ 2, 4, 4, 4, 5, 5, 7, 9 };
    const s = stz_stats_create(&data, data.len) orelse return error.CreateFailed;
    defer stz_stats_free(s);
    var buf: [8]f64 = undefined;
    const n = stz_stats_z_scores(s, &buf, 8);
    try std.testing.expectEqual(@as(usize, 8), n);
    try std.testing.expectApproxEqAbs(@as(f64, -1.403), buf[0], 0.01);
}

test "stats correlation" {
    const x = [_]f64{ 1, 2, 3, 4, 5 };
    const y = [_]f64{ 2, 4, 6, 8, 10 };
    const sx = stz_stats_create(&x, x.len) orelse return error.CreateFailed;
    defer stz_stats_free(sx);
    const sy = stz_stats_create(&y, y.len) orelse return error.CreateFailed;
    defer stz_stats_free(sy);
    try std.testing.expectApproxEqAbs(@as(f64, 1.0), stz_stats_correlation(sx, sy), 0.001);
}

test "stats regression" {
    const x = [_]f64{ 1, 2, 3, 4, 5 };
    const y = [_]f64{ 3, 5, 7, 9, 11 };
    const sx = stz_stats_create(&x, x.len) orelse return error.CreateFailed;
    defer stz_stats_free(sx);
    const sy = stz_stats_create(&y, y.len) orelse return error.CreateFailed;
    defer stz_stats_free(sy);
    var slope: f64 = 0;
    var intercept: f64 = 0;
    const ok = stz_stats_regression(sx, sy, &slope, &intercept);
    try std.testing.expectEqual(@as(i32, 1), ok);
    try std.testing.expectApproxEqAbs(@as(f64, 2.0), slope, 0.001);
    try std.testing.expectApproxEqAbs(@as(f64, 1.0), intercept, 0.001);
}

test "stats rank correlation" {
    const x = [_]f64{ 1, 2, 3, 4, 5 };
    const y = [_]f64{ 5, 4, 3, 2, 1 };
    const sx = stz_stats_create(&x, x.len) orelse return error.CreateFailed;
    defer stz_stats_free(sx);
    const sy = stz_stats_create(&y, y.len) orelse return error.CreateFailed;
    defer stz_stats_free(sy);
    try std.testing.expectApproxEqAbs(@as(f64, -1.0), stz_stats_rank_correlation(sx, sy), 0.001);
}

test "stats trimmed mean" {
    const data = [_]f64{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 100 };
    const s = stz_stats_create(&data, data.len) orelse return error.CreateFailed;
    defer stz_stats_free(s);
    const tm = stz_stats_trimmed_mean(s, 10.0);
    try std.testing.expectApproxEqAbs(@as(f64, 5.5), tm, 0.001);
}

test "stats weighted mean" {
    const data = [_]f64{ 10, 20, 30 };
    const weights = [_]f64{ 1, 2, 3 };
    const wm = stz_stats_weighted_mean(&data, &weights, 3);
    try std.testing.expectApproxEqAbs(@as(f64, 23.333), wm, 0.01);
}

test "stats normalize" {
    const data = [_]f64{ 0, 5, 10 };
    const s = stz_stats_create(&data, data.len) orelse return error.CreateFailed;
    defer stz_stats_free(s);
    var buf: [3]f64 = undefined;
    const n = stz_stats_normalize(s, &buf, 3);
    try std.testing.expectEqual(@as(usize, 3), n);
    try std.testing.expectApproxEqAbs(@as(f64, 0.0), buf[0], 0.001);
    try std.testing.expectApproxEqAbs(@as(f64, 0.5), buf[1], 0.001);
    try std.testing.expectApproxEqAbs(@as(f64, 1.0), buf[2], 0.001);
}

test "stats moving average" {
    const data = [_]f64{ 1, 2, 3, 4, 5 };
    const s = stz_stats_create(&data, data.len) orelse return error.CreateFailed;
    defer stz_stats_free(s);
    var buf: [5]f64 = undefined;
    const n = stz_stats_moving_average(s, 3, &buf, 5);
    try std.testing.expectEqual(@as(usize, 3), n);
    try std.testing.expectApproxEqAbs(@as(f64, 2.0), buf[0], 0.001);
    try std.testing.expectApproxEqAbs(@as(f64, 3.0), buf[1], 0.001);
    try std.testing.expectApproxEqAbs(@as(f64, 4.0), buf[2], 0.001);
}

test "stats deciles" {
    const data = [_]f64{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    const s = stz_stats_create(&data, data.len) orelse return error.CreateFailed;
    defer stz_stats_free(s);
    var buf: [9]f64 = undefined;
    const n = stz_stats_deciles(s, &buf, 9);
    try std.testing.expectEqual(@as(usize, 9), n);
    try std.testing.expectApproxEqAbs(@as(f64, 1.9), buf[0], 0.1);
}

test "stats frequency" {
    const data = [_]f64{ 1, 1, 2, 2, 2, 3 };
    const s = stz_stats_create(&data, data.len) orelse return error.CreateFailed;
    defer stz_stats_free(s);
    var vals: [10]f64 = undefined;
    var counts: [10]usize = undefined;
    const n = stz_stats_frequency(s, &vals, &counts, 10);
    try std.testing.expectEqual(@as(usize, 3), n);
    try std.testing.expectApproxEqAbs(@as(f64, 1.0), vals[0], 0.001);
    try std.testing.expectEqual(@as(usize, 2), counts[0]);
    try std.testing.expectApproxEqAbs(@as(f64, 2.0), vals[1], 0.001);
    try std.testing.expectEqual(@as(usize, 3), counts[1]);
}

test "stats null handles" {
    stz_stats_free(null);
    try std.testing.expectEqual(@as(usize, 0), stz_stats_count(null));
    try std.testing.expectEqual(@as(f64, 0), stz_stats_mean(null));
    try std.testing.expectEqual(@as(f64, 0), stz_stats_correlation(null, null));
}

test "stats covariance" {
    const x = [_]f64{ 1, 2, 3, 4, 5 };
    const y = [_]f64{ 2, 4, 6, 8, 10 };
    const sx = stz_stats_create(&x, x.len) orelse return error.CreateFailed;
    defer stz_stats_free(sx);
    const sy = stz_stats_create(&y, y.len) orelse return error.CreateFailed;
    defer stz_stats_free(sy);
    try std.testing.expectApproxEqAbs(@as(f64, 5.0), stz_stats_covariance(sx, sy), 0.001);
}

test "the summation authority: one definition, and it is the compensated one" {
    // The case that separates them. A naive left-to-right total answers exactly
    // 1e16 here: once the running total is 1e16, each 1.0 is smaller than the
    // last bit of the mantissa and is simply dropped.
    var data: [1001]f64 = undefined;
    data[0] = 1e16;
    for (data[1..]) |*v| v.* = 1.0;

    try std.testing.expectEqual(@as(f64, 1e16 + 1000), compensatedSum(&data));

    // ...and this is what everyone used to do instead:
    var naive: f64 = 0;
    for (data) |v| naive += v;
    try std.testing.expectEqual(@as(f64, 1e16), naive);
    try std.testing.expect(naive != compensatedSum(&data));

    // the incremental shape, for callers that filter or convert as they walk
    var acc = Compensated{};
    for (data) |v| acc.add(v);
    try std.testing.expectEqual(compensatedSum(&data), acc.value());

    // and the public door agrees, since it no longer has its own loop
    const s = stz_stats_create(&data, data.len) orelse return error.CreateFailed;
    defer stz_stats_free(s);
    try std.testing.expectEqual(@as(f64, 1e16 + 1000), stz_stats_sum(s));
}

test "the lane-parallel sum is no less accurate than the scalar one" {
    // The pathological case, now with enough elements to cross several vector
    // widths and leave a ragged tail (1001 = 125 * 8 + 1).
    var data: [1001]f64 = undefined;
    data[0] = 1e16;
    for (data[1..]) |*v| v.* = 1.0;
    try std.testing.expectEqual(@as(f64, 1e16 + 1000), compensatedSum(&data));

    // ...and with the big value in the TAIL rather than the head, so it lands in
    // the scalar remainder instead of a lane.
    var tailheavy: [1001]f64 = undefined;
    for (tailheavy[0 .. tailheavy.len - 1]) |*v| v.* = 1.0;
    tailheavy[tailheavy.len - 1] = 1e16;
    try std.testing.expectEqual(@as(f64, 1e16 + 1000), compensatedSum(&tailheavy));

    // Every length from 0 to 40 -- fewer than one vector, exactly one, several
    // plus every possible remainder -- must agree with the scalar accumulator.
    var buf: [40]f64 = undefined;
    for (&buf, 0..) |*v, i| v.* = 1.0 / @as(f64, @floatFromInt(i + 1));
    for (0..buf.len + 1) |n| {
        var acc = Compensated{};
        for (buf[0..n]) |v| acc.add(v);
        try std.testing.expectApproxEqRel(acc.value(), compensatedSum(buf[0..n]), 1e-15);
    }

    // an empty slice is 0, not a read of lane garbage
    const empty: [0]f64 = .{};
    try std.testing.expectEqual(@as(f64, 0), compensatedSum(&empty));

    // signs mixed, so the lane-wise branch is exercised both ways
    var mixed: [37]f64 = undefined;
    for (&mixed, 0..) |*v, i| {
        v.* = if (i % 2 == 0) @as(f64, 1e8) else @as(f64, -1e8) + 1.0;
    }
    var macc = Compensated{};
    for (mixed) |v| macc.add(v);
    try std.testing.expectApproxEqRel(macc.value(), compensatedSum(&mixed), 1e-12);
}

test "one centered sum of squares, whatever the storage" {
    // The five hand-written copies this replaced must all have agreed; the point
    // of one authority is that agreement stops being a coincidence.
    const f = [_]f64{ 2, 4, 4, 4, 5, 5, 7, 9 };
    const i = [_]i64{ 2, 4, 4, 4, 5, 5, 7, 9 };
    const m = computeMean(&f);

    try std.testing.expectEqual(@as(f64, 32), centeredSumOfSquares(&f, m));
    try std.testing.expectEqual(
        centeredSumOfSquaresOf(f64, &f, m),
        centeredSumOfSquaresOf(i64, &i, m),
    );

    // the textbook pair, by name, through the end-to-end door
    try std.testing.expectEqual(@as(f64, 4), varianceOf(&f, .population));
    try std.testing.expectApproxEqRel(@as(f64, 32.0 / 7.0), varianceOf(&f, .sample), 1e-15);

    // undefined cases answer 0 rather than dividing by zero
    const one = [_]f64{ 42 };
    try std.testing.expectEqual(@as(f64, 0), varianceOf(&one, .sample));
    const none: [0]f64 = .{};
    try std.testing.expectEqual(@as(f64, 0), varianceOf(&none, .population));
    try std.testing.expectEqual(@as(f64, 0), centeredSumOfSquares(&none, 0));

    // every length across the vector boundary, against a plain scalar loop
    var buf: [40]f64 = undefined;
    for (&buf, 0..) |*v, k| v.* = @as(f64, @floatFromInt(k % 7)) * 1.5;
    for (0..buf.len + 1) |n| {
        const mm = computeMean(buf[0..n]);
        var want: f64 = 0;
        for (buf[0..n]) |v| {
            const d = v - mm;
            want += d * d;
        }
        try std.testing.expectApproxEqAbs(want, centeredSumOfSquares(buf[0..n], mm), 1e-9);
    }

    // badly conditioned: a large offset must not swamp a small spread. The
    // variance of {1e9, 1e9+1, ...} is exactly that of {0, 1, ...}.
    var off: [1001]f64 = undefined;
    var base: [1001]f64 = undefined;
    for (&off, &base, 0..) |*o, *b, k| {
        b.* = @floatFromInt(k);
        o.* = 1e9 + b.*;
    }
    try std.testing.expectEqual(
        varianceOf(&base, .sample),
        varianceOf(&off, .sample),
    );
}

test "threaded reductions: pathological exactness and serial agreement" {
    const alloc = std.testing.allocator;
    defer {
        sum_gate.reset();
        css_gate.reset();
    }

    // The pathological case the lane version pins, now through THREADS
    // (chunk boundaries land in the middle of the ones).
    const patho = try alloc.alloc(f64, 4096);
    defer alloc.free(patho);
    patho[0] = 1e16;
    for (patho[1..]) |*v| v.* = 1.0;
    sum_gate.overrideUsize(16);
    try std.testing.expectEqual(@as(f64, 1e16 + 4095.0), compensatedSum(patho));

    // Mixed-sign data: threaded within 1e-12 relative of serial (grouping
    // moves the last bits, never more -- measured ~1e-14).
    const data = try alloc.alloc(f64, 100_000);
    defer alloc.free(data);
    var seed: u64 = 17;
    for (data) |*v| {
        seed = seed *% 6364136223846793005 +% 1442695040888963407;
        v.* = @as(f64, @floatFromInt((seed >> 33) % 2000)) / 999.0 - 1.0;
    }
    sum_gate.overrideUsize(std.math.maxInt(usize));
    const ser = compensatedSum(data);
    sum_gate.overrideUsize(16);
    const par = compensatedSum(data);
    const denom = @max(@abs(ser), 1e-300);
    try std.testing.expect(@abs(par - ser) / denom < 1e-12);

    css_gate.overrideUsize(std.math.maxInt(usize));
    const css_ser = centeredSumOfSquares(data, 0.001);
    css_gate.overrideUsize(16);
    const css_par = centeredSumOfSquares(data, 0.001);
    try std.testing.expect(@abs(css_par - css_ser) / @max(css_ser, 1e-300) < 1e-12);
}
