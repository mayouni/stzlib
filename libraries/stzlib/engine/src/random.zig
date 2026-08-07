const std = @import("std");
const allocator = std.heap.c_allocator;

var prng: std.Random.DefaultPrng = std.Random.DefaultPrng.init(0);
var seeded: bool = false;

fn ensureSeeded() void {
    if (!seeded) {
        const seed: u64 = @bitCast(std.time.milliTimestamp());
        prng = std.Random.DefaultPrng.init(seed);
        seeded = true;
    }
}

// ─── C ABI: Seed ───

pub fn stz_random_seed(s: u64) callconv(.c) void {
    prng = std.Random.DefaultPrng.init(s);
    seeded = true;
}

// ─── C ABI: Single Random Numbers ───

pub fn stz_random_int(min: i64, max: i64) callconv(.c) i64 {
    ensureSeeded();
    if (min >= max) return min;
    // Span arithmetic is MODULAR on purpose. `max - min + 1` overflowed i64
    // for spans wider than 2^63 (e.g. minInt..maxInt), which panicked in
    // ReleaseSafe. `max -% min` bit-cast to u64 is the exact span for ANY
    // i64 pair, because the true span always fits in u64.
    const span: u64 = @bitCast(max -% min);
    if (span == std.math.maxInt(u64)) {
        // The full [minInt, maxInt] range: every i64 equally likely.
        return @bitCast(prng.random().int(u64));
    }
    // Unchanged draw path for every range that worked before -- seeded
    // sequences must not move for an edge fix.
    const r = prng.random().intRangeLessThan(u64, 0, span + 1);
    // Wrapping add is exact here: min + r lands in [min, max] by
    // construction, so the modular result IS the mathematical one.
    return min +% @as(i64, @bitCast(r));
}

pub fn stz_random_float(min: f64, max: f64) callconv(.c) f64 {
    ensureSeeded();
    if (min >= max) return min;
    const r = prng.random().float(f64);
    return min + r * (max - min);
}

// ─── C ABI: Gaussian / Exponential (F3 of the random audit) ───
//
// The library had ONLY uniform draws (int/float/bool/weighted) -- no normal,
// no exponential -- which a stats/ML tier cannot live on. Both ride Zig's
// std ziggurat samplers on the SAME seeded stream as everything else, so
// SeedRandom() governs them too and "seed once, reproduce everything" stays
// true. The N-variants fill a caller buffer and draw in the same order as N
// scalar calls would -- the bulk form IS the scalar sequence, and the guard
// asserts exactly that.

pub fn stz_random_gauss(mean: f64, stddev: f64) callconv(.c) f64 {
    ensureSeeded();
    return mean + stddev * prng.random().floatNorm(f64);
}

pub fn stz_random_exp(lambda: f64) callconv(.c) f64 {
    ensureSeeded();
    if (lambda <= 0) return 0;
    return prng.random().floatExp(f64) / lambda;
}

pub fn stz_random_n_gauss(n: usize, mean: f64, stddev: f64, buf: [*]f64) callconv(.c) usize {
    ensureSeeded();
    for (buf[0..n]) |*v| v.* = mean + stddev * prng.random().floatNorm(f64);
    return n;
}

pub fn stz_random_n_exp(n: usize, lambda: f64, buf: [*]f64) callconv(.c) usize {
    ensureSeeded();
    if (lambda <= 0) return 0;
    for (buf[0..n]) |*v| v.* = prng.random().floatExp(f64) / lambda;
    return n;
}

// ─── C ABI: N Random Integers in Range ───

pub fn stz_random_n_in_range(n: usize, min: i64, max: i64, buf: [*]i64) callconv(.c) usize {
    ensureSeeded();
    if (n == 0 or min > max) return 0;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        buf[i] = stz_random_int(min, max);
    }
    return n;
}

pub fn stz_random_n_unique_in_range(n: usize, min: i64, max: i64, buf: [*]i64) callconv(.c) usize {
    ensureSeeded();
    if (min > max) return 0;
    const range: u64 = @intCast(max - min + 1);
    const actual_n = @min(n, range);
    if (actual_n == 0) return 0;

    if (range <= 10000) {
        const pool = allocator.alloc(i64, range) catch return 0;
        defer allocator.free(pool);
        var val = min;
        for (pool) |*slot| {
            slot.* = val;
            val += 1;
        }
        var remaining = range;
        var count: usize = 0;
        while (count < actual_n) : (count += 1) {
            const idx = prng.random().intRangeLessThan(u64, 0, remaining);
            buf[count] = pool[@intCast(idx)];
            remaining -= 1;
            pool[@intCast(idx)] = pool[@intCast(remaining)];
        }
        return actual_n;
    }

    // Same rejection sampling as always -- draw, skip duplicates -- so the
    // draw ORDER and distribution are untouched. Only the membership test
    // changed: it was a linear scan over everything accepted so far, making
    // the whole fill O(n^2); a hash set makes it O(n) expected. At n=5000
    // from a wide range that is ~12.5M comparisons replaced by 5000 probes.
    if (actual_n > std.math.maxInt(u32)) return 0;
    var seen = std.AutoHashMap(i64, void).init(allocator);
    defer seen.deinit();
    seen.ensureTotalCapacity(@intCast(actual_n)) catch return 0;
    var count: usize = 0;
    while (count < actual_n) {
        const candidate = stz_random_int(min, max);
        const gop = seen.getOrPutAssumeCapacity(candidate);
        if (gop.found_existing) continue;
        buf[count] = candidate;
        count += 1;
    }
    return actual_n;
}

// ─── C ABI: Shuffle array in-place ───

pub fn stz_random_shuffle(buf: [*]i64, len: usize) callconv(.c) void {
    ensureSeeded();
    if (len <= 1) return;
    var i = len - 1;
    while (i > 0) : (i -= 1) {
        const j = prng.random().intRangeLessThan(usize, 0, i + 1);
        const tmp = buf[i];
        buf[i] = buf[j];
        buf[j] = tmp;
    }
}

// ─── C ABI: Random boolean with probability ───

pub fn stz_random_bool(probability: f64) callconv(.c) i32 {
    ensureSeeded();
    const r = prng.random().float(f64);
    return if (r < probability) 1 else 0;
}

// ─── C ABI: Random pick from weighted distribution ───

pub fn stz_random_weighted(weights: [*]const f64, n: usize) callconv(.c) usize {
    ensureSeeded();
    if (n == 0) return 0;
    var total: f64 = 0;
    for (weights[0..n]) |w| total += w;
    if (total <= 0) return 0;
    var r = prng.random().float(f64) * total;
    for (weights[0..n], 0..) |w, i| {
        r -= w;
        if (r <= 0) return i;
    }
    return n - 1;
}

// ─── Tests ───

test "random int in range" {
    stz_random_seed(42);
    var i: usize = 0;
    while (i < 100) : (i += 1) {
        const v = stz_random_int(1, 10);
        try std.testing.expect(v >= 1 and v <= 10);
    }
}

test "random int same min max" {
    stz_random_seed(42);
    try std.testing.expectEqual(@as(i64, 5), stz_random_int(5, 5));
}

test "random float in range" {
    stz_random_seed(42);
    var i: usize = 0;
    while (i < 100) : (i += 1) {
        const v = stz_random_float(0.0, 1.0);
        try std.testing.expect(v >= 0.0 and v < 1.0);
    }
}

test "random n in range" {
    stz_random_seed(42);
    var buf: [10]i64 = undefined;
    const count = stz_random_n_in_range(10, 1, 100, &buf);
    try std.testing.expectEqual(@as(usize, 10), count);
    for (buf[0..count]) |v| {
        try std.testing.expect(v >= 1 and v <= 100);
    }
}

test "random n unique in range" {
    stz_random_seed(42);
    var buf: [5]i64 = undefined;
    const count = stz_random_n_unique_in_range(5, 1, 10, &buf);
    try std.testing.expectEqual(@as(usize, 5), count);
    var i: usize = 0;
    while (i < count) : (i += 1) {
        try std.testing.expect(buf[i] >= 1 and buf[i] <= 10);
        var j = i + 1;
        while (j < count) : (j += 1) {
            try std.testing.expect(buf[i] != buf[j]);
        }
    }
}

test "random n unique capped by range" {
    stz_random_seed(42);
    var buf: [10]i64 = undefined;
    const count = stz_random_n_unique_in_range(10, 1, 3, &buf);
    try std.testing.expectEqual(@as(usize, 3), count);
}

test "random shuffle" {
    stz_random_seed(42);
    var arr = [_]i64{ 1, 2, 3, 4, 5 };
    stz_random_shuffle(&arr, 5);
    var sum: i64 = 0;
    for (arr) |v| sum += v;
    try std.testing.expectEqual(@as(i64, 15), sum);
}

test "random bool" {
    stz_random_seed(42);
    var trues: u32 = 0;
    var i: usize = 0;
    while (i < 1000) : (i += 1) {
        if (stz_random_bool(0.5) == 1) trues += 1;
    }
    try std.testing.expect(trues > 300 and trues < 700);
}

test "random weighted" {
    stz_random_seed(42);
    const weights = [_]f64{ 1.0, 0.0, 0.0 };
    const idx = stz_random_weighted(&weights, 3);
    try std.testing.expectEqual(@as(usize, 0), idx);
}

test "gaussian: seeded moments inside bands, bulk equals scalar sequence" {
    stz_random_seed(4242);
    var sum: f64 = 0;
    var sumsq: f64 = 0;
    const N = 20000;
    var i: usize = 0;
    while (i < N) : (i += 1) {
        const v = stz_random_gauss(0, 1);
        sum += v;
        sumsq += v * v;
    }
    const mean = sum / N;
    const sd = @sqrt(sumsq / N - mean * mean);
    // stderr(mean)=0.0071, stderr(sd)~0.005: these bands are >5 sigma wide,
    // set from arithmetic, not from a run that happened to pass.
    try std.testing.expect(@abs(mean) < 0.04);
    try std.testing.expect(sd > 0.96 and sd < 1.04);

    // mean/stddev transform actually applies
    stz_random_seed(7);
    const a = stz_random_gauss(10, 2);
    stz_random_seed(7);
    const z = stz_random_gauss(0, 1);
    try std.testing.expectApproxEqAbs(10 + 2 * z, a, 1e-12);

    // bulk IS the scalar sequence
    var bulk: [8]f64 = undefined;
    stz_random_seed(99);
    _ = stz_random_n_gauss(8, 1.5, 0.5, &bulk);
    stz_random_seed(99);
    for (bulk) |b| {
        try std.testing.expectApproxEqAbs(stz_random_gauss(1.5, 0.5), b, 0);
    }
}

test "exponential: positive, mean 1/lambda, bulk equals scalar sequence" {
    stz_random_seed(1234);
    var sum2: f64 = 0;
    const N = 20000;
    var i: usize = 0;
    while (i < N) : (i += 1) {
        const v = stz_random_exp(2.0);
        try std.testing.expect(v > 0);
        sum2 += v;
    }
    const mean = sum2 / N;
    try std.testing.expect(mean > 0.47 and mean < 0.53); // true 0.5, stderr 0.0035

    try std.testing.expectEqual(@as(f64, 0), stz_random_exp(0));
    try std.testing.expectEqual(@as(f64, 0), stz_random_exp(-1));

    var bulk: [8]f64 = undefined;
    stz_random_seed(55);
    _ = stz_random_n_exp(8, 3.0, &bulk);
    stz_random_seed(55);
    for (bulk) |b| {
        try std.testing.expectApproxEqAbs(stz_random_exp(3.0), b, 0);
    }
}

test "random int survives the extremes of i64" {
    stz_random_seed(1);
    // The full span used to overflow the range computation and panic.
    var i: usize = 0;
    while (i < 50) : (i += 1) {
        _ = stz_random_int(std.math.minInt(i64), std.math.maxInt(i64));
    }
    // Narrow ranges pressed against both ends stay in range.
    i = 0;
    while (i < 200) : (i += 1) {
        const hi = stz_random_int(std.math.maxInt(i64) - 3, std.math.maxInt(i64));
        try std.testing.expect(hi >= std.math.maxInt(i64) - 3);
        const lo = stz_random_int(std.math.minInt(i64), std.math.minInt(i64) + 3);
        try std.testing.expect(lo <= std.math.minInt(i64) + 3);
        const mid = stz_random_int(-2, 1);
        try std.testing.expect(mid >= -2 and mid <= 1);
    }
}

test "n unique above the pool cutoff: unique, in range, complete" {
    stz_random_seed(7);
    var buf: [5000]i64 = undefined;
    // range 1e6 > 10000 forces the rejection path (the old O(n^2) one).
    const got = stz_random_n_unique_in_range(5000, 1, 1_000_000, &buf);
    try std.testing.expectEqual(@as(usize, 5000), got);
    var seen = std.AutoHashMap(i64, void).init(std.testing.allocator);
    defer seen.deinit();
    for (buf[0..got]) |v| {
        try std.testing.expect(v >= 1 and v <= 1_000_000);
        const gop = try seen.getOrPut(v);
        try std.testing.expect(!gop.found_existing);
    }
}
