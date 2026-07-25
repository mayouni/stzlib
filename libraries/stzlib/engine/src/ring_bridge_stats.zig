const stats = @import("stats.zig");
const numbuf = @import("numbuf.zig");
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

fn ring_VarianceSample(p: *anyopaque) callconv(.c) void {
    rn(p, stats.stz_stats_variance_sample(getH(p, 1)));
}
fn ring_VariancePopulation(p: *anyopaque) callconv(.c) void {
    rn(p, stats.stz_stats_variance_population(getH(p, 1)));
}
fn ring_StdDevSample(p: *anyopaque) callconv(.c) void {
    rn(p, stats.stz_stats_std_dev_sample(getH(p, 1)));
}
fn ring_StdDevPopulation(p: *anyopaque) callconv(.c) void {
    rn(p, stats.stz_stats_std_dev_population(getH(p, 1)));
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

// ── NUMBUF: the resident buffer (numeric foundation phase 3) ────────────
//
// Hosted in this DLL because numbuf.zig asks stats.zig for the variance
// convention, and because a handle table is PER-DLL: a buffer created here must
// be consumed here.

fn getB(p: *anyopaque, n: c_int) ?*numbuf.StzNumBuffer {
    const ptr = R.getHandle(p, n);
    if (ptr) |raw| return @ptrCast(@alignCast(raw));
    return null;
}

fn getBC(p: *anyopaque, n: c_int) ?*const numbuf.StzNumBuffer {
    return getB(p, n);
}

fn ring_BufNew(p: *anyopaque) callconv(.c) void {
    R.retHandle(p, @ptrCast(numbuf.stz_numbuf_new(@intFromFloat(g(p, 1)))));
}

/// ONE crossing: the whole Ring list becomes resident memory here, and every
/// operation after this point costs nothing at the boundary.
fn ring_BufFromList(p: *anyopaque) callconv(.c) void {
    const arr = listToF64(p, 1) orelse {
        R.retHandle(p, null);
        return;
    };
    defer allocator.free(arr);
    const b = numbuf.stz_numbuf_new(arr.len) orelse {
        R.retHandle(p, null);
        return;
    };
    @memcpy(b.data, arr);
    R.retHandle(p, @ptrCast(b));
}

/// ...and one crossing back, when the answer is actually wanted.
fn ring_BufToList(p: *anyopaque) callconv(.c) void {
    const b = getBC(p, 1) orelse {
        R.ring_vm_api_retnumber(p, 0);
        return;
    };
    const out = R.ring_vm_api_newlist(p) orelse return;
    for (b.data) |v| R.ring_list_adddouble(out, v);
    R.ring_vm_api_retlist(p, out);
}

fn ring_BufFree(p: *anyopaque) callconv(.c) void {
    numbuf.stz_numbuf_free(getB(p, 1));
    rn(p, 1);
}
fn ring_BufLen(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(numbuf.stz_numbuf_len(getBC(p, 1))));
}
fn ring_BufClone(p: *anyopaque) callconv(.c) void {
    R.retHandle(p, @ptrCast(numbuf.stz_numbuf_clone(getBC(p, 1))));
}
fn ring_BufGet(p: *anyopaque) callconv(.c) void {
    rn(p, numbuf.stz_numbuf_get(getBC(p, 1), @intFromFloat(g(p, 2))));
}
fn ring_BufSet(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(numbuf.stz_numbuf_set(getB(p, 1), @intFromFloat(g(p, 2)), g(p, 3))));
}
fn ring_BufFill(p: *anyopaque) callconv(.c) void {
    numbuf.stz_numbuf_fill(getB(p, 1), g(p, 2));
    rn(p, 1);
}
fn ring_BufRange(p: *anyopaque) callconv(.c) void {
    numbuf.stz_numbuf_range(getB(p, 1), g(p, 2), g(p, 3));
    rn(p, 1);
}
fn ring_BufAddScalar(p: *anyopaque) callconv(.c) void {
    numbuf.stz_numbuf_add_scalar(getB(p, 1), g(p, 2));
    rn(p, 1);
}
fn ring_BufScale(p: *anyopaque) callconv(.c) void {
    numbuf.stz_numbuf_scale(getB(p, 1), g(p, 2));
    rn(p, 1);
}
fn ring_BufAdd(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(numbuf.stz_numbuf_add(getB(p, 1), getBC(p, 2))));
}
fn ring_BufSub(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(numbuf.stz_numbuf_sub(getB(p, 1), getBC(p, 2))));
}
fn ring_BufMul(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(numbuf.stz_numbuf_mul(getB(p, 1), getBC(p, 2))));
}
fn ring_BufSum(p: *anyopaque) callconv(.c) void {
    rn(p, numbuf.stz_numbuf_sum(getBC(p, 1)));
}
fn ring_BufMean(p: *anyopaque) callconv(.c) void {
    rn(p, numbuf.stz_numbuf_mean(getBC(p, 1)));
}
fn ring_BufMin(p: *anyopaque) callconv(.c) void {
    rn(p, numbuf.stz_numbuf_min(getBC(p, 1)));
}
fn ring_BufMax(p: *anyopaque) callconv(.c) void {
    rn(p, numbuf.stz_numbuf_max(getBC(p, 1)));
}
fn ring_BufDot(p: *anyopaque) callconv(.c) void {
    rn(p, numbuf.stz_numbuf_dot(getBC(p, 1), getBC(p, 2)));
}
fn ring_BufVariance(p: *anyopaque) callconv(.c) void {
    rn(p, numbuf.stz_numbuf_variance(getBC(p, 1), @intFromFloat(g(p, 2))));
}
fn ring_BufStdDev(p: *anyopaque) callconv(.c) void {
    rn(p, numbuf.stz_numbuf_stddev(getBC(p, 1), @intFromFloat(g(p, 2))));
}

pub const regs = [_]R.Reg{
    .{ .name = "stzenginenumbufnew", .func = &ring_BufNew },
    .{ .name = "stzenginenumbuffromlist", .func = &ring_BufFromList },
    .{ .name = "stzenginenumbuftolist", .func = &ring_BufToList },
    .{ .name = "stzenginenumbuffree", .func = &ring_BufFree },
    .{ .name = "stzenginenumbuflen", .func = &ring_BufLen },
    .{ .name = "stzenginenumbufclone", .func = &ring_BufClone },
    .{ .name = "stzenginenumbufget", .func = &ring_BufGet },
    .{ .name = "stzenginenumbufset", .func = &ring_BufSet },
    .{ .name = "stzenginenumbuffill", .func = &ring_BufFill },
    .{ .name = "stzenginenumbufrange", .func = &ring_BufRange },
    .{ .name = "stzenginenumbufaddscalar", .func = &ring_BufAddScalar },
    .{ .name = "stzenginenumbufscale", .func = &ring_BufScale },
    .{ .name = "stzenginenumbufadd", .func = &ring_BufAdd },
    .{ .name = "stzenginenumbufsub", .func = &ring_BufSub },
    .{ .name = "stzenginenumbufmul", .func = &ring_BufMul },
    .{ .name = "stzenginenumbufsum", .func = &ring_BufSum },
    .{ .name = "stzenginenumbufmean", .func = &ring_BufMean },
    .{ .name = "stzenginenumbufmin", .func = &ring_BufMin },
    .{ .name = "stzenginenumbufmax", .func = &ring_BufMax },
    .{ .name = "stzenginenumbufdot", .func = &ring_BufDot },
    .{ .name = "stzenginenumbufvariance", .func = &ring_BufVariance },
    .{ .name = "stzenginenumbufstddev", .func = &ring_BufStdDev },
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
    .{ .name = "stzenginestatsvariancesample", .func = &ring_VarianceSample },
    .{ .name = "stzenginestatsvariancepopulation", .func = &ring_VariancePopulation },
    .{ .name = "stzenginestatsstddevsample", .func = &ring_StdDevSample },
    .{ .name = "stzenginestatsstddevpopulation", .func = &ring_StdDevPopulation },
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
