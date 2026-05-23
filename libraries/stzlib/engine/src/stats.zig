const std = @import("std");
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

fn computeMean(data: []const f64) f64 {
    if (data.len == 0) return 0;
    var sum: f64 = 0;
    for (data) |v| sum += v;
    return sum / @as(f64, @floatFromInt(data.len));
}

fn computeVariance(data: []const f64, mean: f64) f64 {
    if (data.len < 2) return 0;
    var ss: f64 = 0;
    for (data) |v| {
        const d = v - mean;
        ss += d * d;
    }
    return ss / @as(f64, @floatFromInt(data.len - 1));
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
    var sum: f64 = 0;
    for (st.data) |v| sum += v;
    return sum;
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

pub fn stz_stats_variance(s: ?*const StzStats) callconv(.c) f64 {
    const st = s orelse return 0;
    return computeVariance(st.data, computeMean(st.data));
}

pub fn stz_stats_std_dev(s: ?*const StzStats) callconv(.c) f64 {
    const st = s orelse return 0;
    return @sqrt(computeVariance(st.data, computeMean(st.data)));
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
