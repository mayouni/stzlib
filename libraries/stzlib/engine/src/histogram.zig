// Latency histogram with logarithmic buckets.
//
// Gap-analysis Tier 1 item 6. Computing exact percentiles needs every
// sample retained; a bucketed histogram trades a little precision for
// O(1) memory and record cost. Each sample lands in the first bucket
// whose upper bound it does not exceed; a percentile query returns the
// upper bound of the bucket the percentile rank falls in.
//
//   histogram_create()                 -> opaque handle
//   histogram_record(h, value_ms)      -> tally one sample
//   histogram_percentile(h, p)         -> ms upper bound for percentile p
//   histogram_count(h)                 -> total samples
//   histogram_reset(h)                 -> clear all buckets
//   histogram_destroy(h)
//
// Buckets are fixed log-scale millisecond bounds; values above the
// largest bound fall into an overflow bucket and report OVERFLOW_MS.

const std = @import("std");

const gpa = std.heap.c_allocator;

// Upper bounds (ms) on a log-ish scale. A sample <= BOUNDS[i] and
// > BOUNDS[i-1] lands in bucket i. Anything > the last bound lands in
// the overflow bucket.
const BOUNDS = [_]f64{ 0.1, 0.2, 0.5, 1, 2, 5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000 };
const NBUCKETS = BOUNDS.len + 1; // + overflow

/// Reported by histogram_percentile when the percentile falls in the
/// overflow bucket (sample larger than the largest finite bound).
pub const OVERFLOW_MS: f64 = BOUNDS[BOUNDS.len - 1] * 10.0; // 100_000 ms

pub const Histogram = struct {
    buckets: [NBUCKETS]u64,
    total: u64,
    mutex: std.Thread.Mutex,
};

pub fn histogram_create() callconv(.c) ?*Histogram {
    const h = gpa.create(Histogram) catch return null;
    h.* = .{ .buckets = [_]u64{0} ** NBUCKETS, .total = 0, .mutex = .{} };
    return h;
}

pub fn histogram_record(h_opt: ?*Histogram, value_ms: f64) callconv(.c) void {
    const h = h_opt orelse return;
    h.mutex.lock();
    defer h.mutex.unlock();
    var idx: usize = NBUCKETS - 1; // overflow unless a bound matches
    for (BOUNDS, 0..) |b, i| {
        if (value_ms <= b) {
            idx = i;
            break;
        }
    }
    h.buckets[idx] += 1;
    h.total += 1;
}

pub fn histogram_percentile(h_opt: ?*Histogram, p: f64) callconv(.c) f64 {
    const h = h_opt orelse return 0;
    h.mutex.lock();
    defer h.mutex.unlock();
    if (h.total == 0) return 0;

    var pp = p;
    if (pp < 0) pp = 0;
    if (pp > 100) pp = 100;

    // Rank of the percentile sample (1-based), rounded up.
    const target_f = @as(f64, @floatFromInt(h.total)) * pp / 100.0;
    var target: u64 = @intFromFloat(@ceil(target_f));
    if (target < 1) target = 1;

    var cum: u64 = 0;
    for (h.buckets, 0..) |c, i| {
        cum += c;
        if (cum >= target) {
            if (i < BOUNDS.len) return BOUNDS[i];
            return OVERFLOW_MS;
        }
    }
    return OVERFLOW_MS;
}

pub fn histogram_count(h_opt: ?*Histogram) callconv(.c) u64 {
    const h = h_opt orelse return 0;
    h.mutex.lock();
    defer h.mutex.unlock();
    return h.total;
}

pub fn histogram_reset(h_opt: ?*Histogram) callconv(.c) void {
    const h = h_opt orelse return;
    h.mutex.lock();
    defer h.mutex.unlock();
    h.buckets = [_]u64{0} ** NBUCKETS;
    h.total = 0;
}

pub fn histogram_destroy(h_opt: ?*Histogram) callconv(.c) void {
    const h = h_opt orelse return;
    gpa.destroy(h);
}

// ── tests ────────────────────────────────────────────────────

test "histogram: empty percentile + count are zero" {
    const h = histogram_create().?;
    defer histogram_destroy(h);
    try std.testing.expectEqual(@as(u64, 0), histogram_count(h));
    try std.testing.expectEqual(@as(f64, 0), histogram_percentile(h, 50));
}

test "histogram: 1000 uniform samples place p50 mid-range, p99 near top" {
    const h = histogram_create().?;
    defer histogram_destroy(h);

    var i: u32 = 1;
    while (i <= 1000) : (i += 1) {
        histogram_record(h, @floatFromInt(i)); // 1..1000 ms, uniform
    }
    try std.testing.expectEqual(@as(u64, 1000), histogram_count(h));

    // 500th value is 500 -> bucket bound 500.
    try std.testing.expectEqual(@as(f64, 500), histogram_percentile(h, 50));
    // 990th value is 990 -> first bound >= 990 is 1000.
    try std.testing.expectEqual(@as(f64, 1000), histogram_percentile(h, 99));
    // p1 -> rank 10 -> value 10 -> bound 10.
    try std.testing.expectEqual(@as(f64, 10), histogram_percentile(h, 1));
}

test "histogram: reset clears all buckets" {
    const h = histogram_create().?;
    defer histogram_destroy(h);
    histogram_record(h, 5);
    histogram_record(h, 50);
    try std.testing.expectEqual(@as(u64, 2), histogram_count(h));
    histogram_reset(h);
    try std.testing.expectEqual(@as(u64, 0), histogram_count(h));
    try std.testing.expectEqual(@as(f64, 0), histogram_percentile(h, 90));
}

test "histogram: values past the top bound report overflow" {
    const h = histogram_create().?;
    defer histogram_destroy(h);
    histogram_record(h, 999_999);
    try std.testing.expectEqual(OVERFLOW_MS, histogram_percentile(h, 50));
}
