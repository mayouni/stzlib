const stats = @import("stats.zig");
const R = @import("ring_api.zig");

const g = R.ring_vm_api_getnumber;
const gl = R.ring_vm_api_getlist;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring;
const rs2 = R.ring_vm_api_retstring2;

// Shadow the real cpointer functions: store/resolve via handle table.
fn rcp(p: *anyopaque, ptr: ?*anyopaque, _: [*:0]const u8) void {
    R.retHandle(p, ptr);
}

fn gcp(p: *anyopaque, n: c_int, _: [*:0]const u8) ?*anyopaque {
    return R.getHandle(p, n);
}

const H: [*:0]const u8 = "StzStatsHandle";
const allocator = @import("std").heap.c_allocator;

fn getH(p: *anyopaque, n: c_int) ?*const stats.StzStats {
    const ptr = gcp(p, n, H);
    if (ptr) |raw| return @ptrCast(@alignCast(raw));
    return null;
}

fn listToF64(p: *anyopaque, param: c_int) ?[]f64 {
    const lst = gl(p, param) orelse return null;
    const n: usize = @intCast(R.ringListSize(lst));
    if (n == 0) return null;
    const arr = allocator.alloc(f64, n) catch return null;
    for (0..n) |i| {
        const item = R.ring_list_getitem_gc(null, lst, @intCast(i + 1)) orelse {
            arr[i] = 0;
            continue;
        };
        arr[i] = R.ring_item_getnumber(item);
    }
    return arr;
}

fn ring_Create(p: *anyopaque) callconv(.c) void {
    const arr = listToF64(p, 1) orelse {
        rcp(p, null, H);
        return;
    };
    defer allocator.free(arr);
    rcp(p, @ptrCast(stats.stz_stats_create(arr.ptr, arr.len)), H);
}

fn ring_Free(p: *anyopaque) callconv(.c) void {
    const raw = R.releaseHandle(p, 1);
    if (raw) |ptr| {
        const c: ?*stats.StzStats = @ptrCast(@alignCast(ptr));
        stats.stz_stats_free(c);
    }
}

fn ring_Count(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(stats.stz_stats_count(getH(p, 1))));
}

fn ring_Mean(p: *anyopaque) callconv(.c) void {
    rn(p, stats.stz_stats_mean(getH(p, 1)));
}

fn ring_Sum(p: *anyopaque) callconv(.c) void {
    rn(p, stats.stz_stats_sum(getH(p, 1)));
}

fn ring_Min(p: *anyopaque) callconv(.c) void {
    rn(p, stats.stz_stats_min(getH(p, 1)));
}

fn ring_Max(p: *anyopaque) callconv(.c) void {
    rn(p, stats.stz_stats_max(getH(p, 1)));
}

fn ring_Range(p: *anyopaque) callconv(.c) void {
    rn(p, stats.stz_stats_range(getH(p, 1)));
}

fn ring_Median(p: *anyopaque) callconv(.c) void {
    rn(p, stats.stz_stats_median(getH(p, 1)));
}

fn ring_Variance(p: *anyopaque) callconv(.c) void {
    rn(p, stats.stz_stats_variance(getH(p, 1)));
}

fn ring_StdDev(p: *anyopaque) callconv(.c) void {
    rn(p, stats.stz_stats_std_dev(getH(p, 1)));
}

fn ring_CoeffOfVariation(p: *anyopaque) callconv(.c) void {
    rn(p, stats.stz_stats_coeff_of_variation(getH(p, 1)));
}

fn ring_Percentile(p: *anyopaque) callconv(.c) void {
    rn(p, stats.stz_stats_percentile(getH(p, 1), g(p, 2)));
}

fn ring_Q1(p: *anyopaque) callconv(.c) void {
    rn(p, stats.stz_stats_q1(getH(p, 1)));
}

fn ring_Q2(p: *anyopaque) callconv(.c) void {
    rn(p, stats.stz_stats_q2(getH(p, 1)));
}

fn ring_Q3(p: *anyopaque) callconv(.c) void {
    rn(p, stats.stz_stats_q3(getH(p, 1)));
}

fn ring_IQR(p: *anyopaque) callconv(.c) void {
    rn(p, stats.stz_stats_iqr(getH(p, 1)));
}

fn ring_Skewness(p: *anyopaque) callconv(.c) void {
    rn(p, stats.stz_stats_skewness(getH(p, 1)));
}

fn ring_Kurtosis(p: *anyopaque) callconv(.c) void {
    rn(p, stats.stz_stats_kurtosis(getH(p, 1)));
}

fn ring_GeometricMean(p: *anyopaque) callconv(.c) void {
    rn(p, stats.stz_stats_geometric_mean(getH(p, 1)));
}

fn ring_HarmonicMean(p: *anyopaque) callconv(.c) void {
    rn(p, stats.stz_stats_harmonic_mean(getH(p, 1)));
}

fn ring_ContainsOutliers(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(stats.stz_stats_contains_outliers(getH(p, 1))));
}

fn ring_TrimmedMean(p: *anyopaque) callconv(.c) void {
    rn(p, stats.stz_stats_trimmed_mean(getH(p, 1), g(p, 2)));
}

fn ring_Correlation(p: *anyopaque) callconv(.c) void {
    rn(p, stats.stz_stats_correlation(getH(p, 1), getH(p, 2)));
}

fn ring_Covariance(p: *anyopaque) callconv(.c) void {
    rn(p, stats.stz_stats_covariance(getH(p, 1), getH(p, 2)));
}

fn ring_RankCorrelation(p: *anyopaque) callconv(.c) void {
    rn(p, stats.stz_stats_rank_correlation(getH(p, 1), getH(p, 2)));
}

fn ring_Regression(p: *anyopaque) callconv(.c) void {
    var slope: f64 = 0;
    var intercept: f64 = 0;
    const ok = stats.stz_stats_regression(getH(p, 1), getH(p, 2), &slope, &intercept);
    if (ok == 0) {
        rs(p, "");
        return;
    }
    var buf: [128]u8 = undefined;
    const len = @import("std").fmt.bufPrint(&buf, "{d},{d}", .{ slope, intercept }) catch {
        rs(p, "");
        return;
    };
    rs2(p, @ptrCast(len.ptr), @intCast(len.len));
}

fn ring_WeightedMean(p: *anyopaque) callconv(.c) void {
    const data = listToF64(p, 1) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(data);
    const weights = listToF64(p, 2) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(weights);
    const n = @min(data.len, weights.len);
    rn(p, stats.stz_stats_weighted_mean(data.ptr, weights.ptr, n));
}

pub const regs = [_]R.Reg{
    .{ .name = "stzenginestatscreate", .func = &ring_Create },
    .{ .name = "stzenginestatsfree", .func = &ring_Free },
    .{ .name = "stzenginestatscount", .func = &ring_Count },
    .{ .name = "stzenginestatsmean", .func = &ring_Mean },
    .{ .name = "stzenginestatssum", .func = &ring_Sum },
    .{ .name = "stzenginestatsmin", .func = &ring_Min },
    .{ .name = "stzenginestatsmax", .func = &ring_Max },
    .{ .name = "stzenginestatsrange", .func = &ring_Range },
    .{ .name = "stzenginestatsmedian", .func = &ring_Median },
    .{ .name = "stzenginestatsvariance", .func = &ring_Variance },
    .{ .name = "stzenginestatsstddev", .func = &ring_StdDev },
    .{ .name = "stzenginestatscoeffofvariation", .func = &ring_CoeffOfVariation },
    .{ .name = "stzenginestatspercentile", .func = &ring_Percentile },
    .{ .name = "stzenginestatsq1", .func = &ring_Q1 },
    .{ .name = "stzenginestatsq2", .func = &ring_Q2 },
    .{ .name = "stzenginestatsq3", .func = &ring_Q3 },
    .{ .name = "stzenginestatsiqr", .func = &ring_IQR },
    .{ .name = "stzenginestatsskewness", .func = &ring_Skewness },
    .{ .name = "stzenginestatskurtosis", .func = &ring_Kurtosis },
    .{ .name = "stzenginestatsgeometricmean", .func = &ring_GeometricMean },
    .{ .name = "stzenginestatsharmonicmean", .func = &ring_HarmonicMean },
    .{ .name = "stzenginestatscontainsoutliers", .func = &ring_ContainsOutliers },
    .{ .name = "stzenginestatstrimmedmean", .func = &ring_TrimmedMean },
    .{ .name = "stzenginestatscorrelation", .func = &ring_Correlation },
    .{ .name = "stzenginestatscovariance", .func = &ring_Covariance },
    .{ .name = "stzenginestatsrankcorrelation", .func = &ring_RankCorrelation },
    .{ .name = "stzenginestatsregression", .func = &ring_Regression },
    .{ .name = "stzenginestatsweightedmean", .func = &ring_WeightedMean },
};

pub fn ringlib_init(pRingState: ?*anyopaque) callconv(.c) void {
    if (pRingState) |state| R.registerAll(state, &regs);
}
