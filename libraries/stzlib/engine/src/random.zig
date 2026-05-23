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
    const range: u64 = @intCast(max - min + 1);
    const r = prng.random().intRangeLessThan(u64, 0, range);
    return min + @as(i64, @intCast(r));
}

pub fn stz_random_float(min: f64, max: f64) callconv(.c) f64 {
    ensureSeeded();
    if (min >= max) return min;
    const r = prng.random().float(f64);
    return min + r * (max - min);
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

    var count: usize = 0;
    outer: while (count < actual_n) {
        const candidate = stz_random_int(min, max);
        var j: usize = 0;
        while (j < count) : (j += 1) {
            if (buf[j] == candidate) continue :outer;
        }
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
