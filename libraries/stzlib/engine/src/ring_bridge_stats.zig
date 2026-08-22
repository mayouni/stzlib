const stats = @import("stats.zig");
const numbuf = @import("numbuf.zig");
const special = @import("special.zig");
const hyp = @import("hypothesis.zig");
const simplex = @import("simplex.zig");
const optim = @import("optim.zig");
const logistic = @import("logistic.zig");
const cluster = @import("cluster.zig");
const tree = @import("tree.zig");
const apriori = @import("apriori.zig");
const bayes = @import("bayes.zig");
const autodiff = @import("autodiff.zig");
const lbfgs = @import("lbfgs.zig");
const nn = @import("nn.zig");
const eigen_general = @import("eigen_general.zig");
const fft_mod = @import("fft.zig");
const ann_mod = @import("ann.zig");
const knn_mod = @import("knn.zig");
const poly_mod = @import("poly.zig");
const frame_mod = @import("frame.zig");
const plot_mod = @import("plot.zig");
const pca_mod = @import("pca.zig");
const tsne_mod = @import("tsne.zig");
const umap_mod = @import("umap.zig");
const pumap_mod = @import("pumap.zig");
const decoder_mod = @import("decoder.zig");
const ptsne_mod = @import("ptsne.zig");
const cmplx = @import("complex.zig");
const std = @import("std");
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


// ─── Special functions and distributions (phase 4 slice 5) ───
//
// Plain numeric in / numeric out: no handles, no allocation, nothing to free.
fn ring_Erf(p: *anyopaque) callconv(.c) void { rn(p, special.erf(g(p, 1))); }
fn ring_Erfc(p: *anyopaque) callconv(.c) void { rn(p, special.erfc(g(p, 1))); }
fn ring_LogGamma(p: *anyopaque) callconv(.c) void { rn(p, special.stz_special_lgamma(g(p, 1))); }
fn ring_Gamma(p: *anyopaque) callconv(.c) void { rn(p, special.stz_special_tgamma(g(p, 1))); }
fn ring_GammaP(p: *anyopaque) callconv(.c) void { rn(p, special.gammaP(g(p, 1), g(p, 2))); }
fn ring_GammaQ(p: *anyopaque) callconv(.c) void { rn(p, special.gammaQ(g(p, 1), g(p, 2))); }
fn ring_BetaI(p: *anyopaque) callconv(.c) void { rn(p, special.betaI(g(p, 1), g(p, 2), g(p, 3))); }
fn ring_NormalCdf(p: *anyopaque) callconv(.c) void { rn(p, special.normalCdf(g(p, 1))); }
fn ring_NormalQuantile(p: *anyopaque) callconv(.c) void { rn(p, special.normalQuantile(g(p, 1))); }
fn ring_TCdf(p: *anyopaque) callconv(.c) void { rn(p, special.studentTCdf(g(p, 1), g(p, 2))); }
fn ring_TQuantile(p: *anyopaque) callconv(.c) void { rn(p, special.studentTQuantile(g(p, 1), g(p, 2))); }
fn ring_Chi2Cdf(p: *anyopaque) callconv(.c) void { rn(p, special.chiSquareCdf(g(p, 1), g(p, 2))); }
fn ring_Chi2Quantile(p: *anyopaque) callconv(.c) void { rn(p, special.chiSquareQuantile(g(p, 1), g(p, 2))); }
fn ring_FCdf(p: *anyopaque) callconv(.c) void { rn(p, special.fCdf(g(p, 1), g(p, 2), g(p, 3))); }
fn ring_FQuantile(p: *anyopaque) callconv(.c) void { rn(p, special.fQuantile(g(p, 1), g(p, 2), g(p, 3))); }
fn ring_CriticalValue(p: *anyopaque) callconv(.c) void { rn(p, special.criticalValue(g(p, 1), g(p, 2))); }


// ─── Hypothesis tests (phase 5 slice 1) ───
//
// Each returns a Ring LIST, never a bare p-value -- that number alone is the most
// misread quantity in statistics, and handing it back on its own invites exactly the
// misreading. The shape is
//
//     [ statistic, df, p_value, effect_size, n, ok ]
//
// which the Ring layer turns into a named record. `ok = 0` means NO TEST WAS RUN, and
// every other field is 0: the caller must not read that zero p-value as overwhelming
// significance, which is the misreading the flag exists to stop.
fn retResult(p: *anyopaque, r: hyp.TestResult) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    R.ring_list_adddouble(out, r.statistic);
    R.ring_list_adddouble(out, r.df);
    R.ring_list_adddouble(out, r.p_value);
    R.ring_list_adddouble(out, r.effect_size);
    R.ring_list_adddouble(out, r.n);
    R.ring_list_adddouble(out, @floatFromInt(r.ok));
    R.ring_vm_api_retlist(p, out);
}

fn ring_TOneSample(p: *anyopaque) callconv(.c) void {
    const a = listToF64(p, 1) orelse return retResult(p, .{ .statistic = 0, .df = 0, .p_value = 0, .effect_size = 0, .n = 0, .ok = 0 });
    defer allocator.free(a);
    retResult(p, hyp.tTestOneSample(a, g(p, 2)));
}

fn ring_TWelch(p: *anyopaque) callconv(.c) void {
    const a = listToF64(p, 1) orelse return retResult(p, .{ .statistic = 0, .df = 0, .p_value = 0, .effect_size = 0, .n = 0, .ok = 0 });
    defer allocator.free(a);
    const b = listToF64(p, 2) orelse return retResult(p, .{ .statistic = 0, .df = 0, .p_value = 0, .effect_size = 0, .n = 0, .ok = 0 });
    defer allocator.free(b);
    retResult(p, hyp.tTestWelch(a, b));
}

fn ring_TStudent(p: *anyopaque) callconv(.c) void {
    const a = listToF64(p, 1) orelse return retResult(p, .{ .statistic = 0, .df = 0, .p_value = 0, .effect_size = 0, .n = 0, .ok = 0 });
    defer allocator.free(a);
    const b = listToF64(p, 2) orelse return retResult(p, .{ .statistic = 0, .df = 0, .p_value = 0, .effect_size = 0, .n = 0, .ok = 0 });
    defer allocator.free(b);
    retResult(p, hyp.tTestStudent(a, b));
}

fn ring_TPaired(p: *anyopaque) callconv(.c) void {
    const a = listToF64(p, 1) orelse return retResult(p, .{ .statistic = 0, .df = 0, .p_value = 0, .effect_size = 0, .n = 0, .ok = 0 });
    defer allocator.free(a);
    const b = listToF64(p, 2) orelse return retResult(p, .{ .statistic = 0, .df = 0, .p_value = 0, .effect_size = 0, .n = 0, .ok = 0 });
    defer allocator.free(b);
    if (a.len != b.len) return retResult(p, .{ .statistic = 0, .df = 0, .p_value = 0, .effect_size = 0, .n = 0, .ok = 0 });
    retResult(p, hyp.tTestPaired(allocator, a, b) catch .{ .statistic = 0, .df = 0, .p_value = 0, .effect_size = 0, .n = 0, .ok = 0 });
}

fn ring_Chi2Gof(p: *anyopaque) callconv(.c) void {
    const o = listToF64(p, 1) orelse return retResult(p, .{ .statistic = 0, .df = 0, .p_value = 0, .effect_size = 0, .n = 0, .ok = 0 });
    defer allocator.free(o);
    const e = listToF64(p, 2) orelse return retResult(p, .{ .statistic = 0, .df = 0, .p_value = 0, .effect_size = 0, .n = 0, .ok = 0 });
    defer allocator.free(e);
    if (o.len != e.len) return retResult(p, .{ .statistic = 0, .df = 0, .p_value = 0, .effect_size = 0, .n = 0, .ok = 0 });
    retResult(p, hyp.chiSquareGoodnessOfFit(o, e));
}

fn ring_Chi2Independence(p: *anyopaque) callconv(.c) void {
    const flat = listToF64(p, 1) orelse return retResult(p, .{ .statistic = 0, .df = 0, .p_value = 0, .effect_size = 0, .n = 0, .ok = 0 });
    defer allocator.free(flat);
    const rows: usize = @intFromFloat(g(p, 2));
    const cols: usize = @intFromFloat(g(p, 3));
    if (rows * cols != flat.len) return retResult(p, .{ .statistic = 0, .df = 0, .p_value = 0, .effect_size = 0, .n = 0, .ok = 0 });
    retResult(p, hyp.chiSquareIndependence(allocator, flat, rows, cols) catch .{ .statistic = 0, .df = 0, .p_value = 0, .effect_size = 0, .n = 0, .ok = 0 });
}

fn ring_Anova(p: *anyopaque) callconv(.c) void {
    const flat = listToF64(p, 1) orelse return retResult(p, .{ .statistic = 0, .df = 0, .p_value = 0, .effect_size = 0, .n = 0, .ok = 0 });
    defer allocator.free(flat);
    const szf = listToF64(p, 2) orelse return retResult(p, .{ .statistic = 0, .df = 0, .p_value = 0, .effect_size = 0, .n = 0, .ok = 0 });
    defer allocator.free(szf);
    const sizes = allocator.alloc(usize, szf.len) catch return retResult(p, .{ .statistic = 0, .df = 0, .p_value = 0, .effect_size = 0, .n = 0, .ok = 0 });
    defer allocator.free(sizes);
    for (szf, 0..) |v, i| {
        if (v < 1) return retResult(p, .{ .statistic = 0, .df = 0, .p_value = 0, .effect_size = 0, .n = 0, .ok = 0 });
        sizes[i] = @intFromFloat(v);
    }
    retResult(p, hyp.anovaOneWay(flat, sizes));
}

fn ring_CorrelationTest(p: *anyopaque) callconv(.c) void {
    const a = listToF64(p, 1) orelse return retResult(p, .{ .statistic = 0, .df = 0, .p_value = 0, .effect_size = 0, .n = 0, .ok = 0 });
    defer allocator.free(a);
    const b = listToF64(p, 2) orelse return retResult(p, .{ .statistic = 0, .df = 0, .p_value = 0, .effect_size = 0, .n = 0, .ok = 0 });
    defer allocator.free(b);
    retResult(p, hyp.correlationTest(a, b));
}


// ─── The simplex pivot loop (phase 5 slice 2) ───
//
// Ring builds the Big-M tableau -- parsing, bounds, slack/artificial layout, all of
// which measured at 0.005s and flat -- and hands the flat arrays here. Only the
// pivoting moves, because only the pivoting was slow.
//
//   StzEngineSimplexRun(aTableauFlat, aZ, aBasis, nRows, nCols, nArtAt, nVars)
//     -> [ status, iterations, x1, x2, ... ]
//
// status: 0 optimal, 1 unbounded, 2 infeasible, 3 iteration limit.
fn ring_SimplexRun(p: *anyopaque) callconv(.c) void {
    const tt = listToF64(p, 1) orelse {
        R.ring_vm_api_retnumber(p, 0);
        return;
    };
    defer allocator.free(tt);
    const zz = listToF64(p, 2) orelse {
        R.ring_vm_api_retnumber(p, 0);
        return;
    };
    defer allocator.free(zz);
    const bf = listToF64(p, 3) orelse {
        R.ring_vm_api_retnumber(p, 0);
        return;
    };
    defer allocator.free(bf);

    const m: usize = @intFromFloat(g(p, 4));
    const cols: usize = @intFromFloat(g(p, 5));
    const art_at: usize = @intFromFloat(g(p, 6));
    const nv: usize = @intFromFloat(g(p, 7));

    if (m == 0 or cols == 0 or tt.len != m * cols or zz.len != cols or bf.len != m or nv > cols) {
        R.ring_vm_api_retnumber(p, 0);
        return;
    }

    const basis = allocator.alloc(i32, m) catch {
        R.ring_vm_api_retnumber(p, 0);
        return;
    };
    defer allocator.free(basis);
    for (bf, 0..) |v, i| basis[i] = @intFromFloat(v);

    const x = allocator.alloc(f64, nv) catch {
        R.ring_vm_api_retnumber(p, 0);
        return;
    };
    defer allocator.free(x);

    var iters: i32 = 0;
    const st = simplex.run(tt, zz, basis, m, cols, art_at, &iters);
    simplex.extract(tt, basis, m, cols, x, nv);

    const out = R.ring_vm_api_newlist(p) orelse return;
    R.ring_list_adddouble(out, @floatFromInt(@intFromEnum(st)));
    R.ring_list_adddouble(out, @floatFromInt(iters));
    for (x) |v| R.ring_list_adddouble(out, v);
    R.ring_vm_api_retlist(p, out);
}

// ─── The LP/MIP floor (R4 step 5) ───
//
// Where SimplexRun takes a TABLEAU somebody else laid out, this takes a MODEL
// and owns the layout -- because branch-and-bound solves a tree of LPs and
// rebuilding that tableau Ring-side would pay the build cost once per node.
//
//   StzEngineOptimSolve(aObj, nMaximize, aLb, aUb, aUbFinite, aIsInt,
//                       aMat, aSense, aRhs, nVars, nCons, nMaxNodes)
//     -> [ status, objective, nodes, iterations, branched, x1, x2, ... ]
//
// status: 0 optimal, 1 unbounded, 2 infeasible, 3 iteration limit,
//         4 node limit (an incumbent exists but nothing proved it optimal),
//         5 a lower bound of -infinity, which v1 refuses rather than clamps.
// aUbFinite is a parallel 1/0 list rather than a magic number in aUb: a
// sentinel large enough to mean "no bound" is also a number somebody's model
// could legitimately hold.
fn ring_OptimSolve(p: *anyopaque) callconv(.c) void {
    const obj = listToF64(p, 1) orelse {
        R.ring_vm_api_retnumber(p, 0);
        return;
    };
    defer allocator.free(obj);
    const maximize = g(p, 2) != 0;
    const lb = listToF64(p, 3) orelse {
        R.ring_vm_api_retnumber(p, 0);
        return;
    };
    defer allocator.free(lb);
    const ubf = listToF64(p, 4) orelse {
        R.ring_vm_api_retnumber(p, 0);
        return;
    };
    defer allocator.free(ubf);
    const ubfin = listToF64(p, 5) orelse {
        R.ring_vm_api_retnumber(p, 0);
        return;
    };
    defer allocator.free(ubfin);
    const isint = listToF64(p, 6) orelse {
        R.ring_vm_api_retnumber(p, 0);
        return;
    };
    defer allocator.free(isint);
    const mat = listToF64(p, 7) orelse {
        R.ring_vm_api_retnumber(p, 0);
        return;
    };
    defer allocator.free(mat);
    const sensef = listToF64(p, 8) orelse {
        R.ring_vm_api_retnumber(p, 0);
        return;
    };
    defer allocator.free(sensef);
    const rhs = listToF64(p, 9) orelse {
        R.ring_vm_api_retnumber(p, 0);
        return;
    };
    defer allocator.free(rhs);

    const n: usize = @intFromFloat(g(p, 10));
    const m: usize = @intFromFloat(g(p, 11));
    const max_nodes: i32 = @intFromFloat(g(p, 12));

    if (n == 0 or obj.len != n or lb.len != n or ubf.len != n or
        ubfin.len != n or isint.len != n or mat.len != m * n or
        sensef.len != m or rhs.len != m)
    {
        R.ring_vm_api_retnumber(p, 0);
        return;
    }

    const ub = allocator.alloc(f64, n) catch {
        R.ring_vm_api_retnumber(p, 0);
        return;
    };
    defer allocator.free(ub);
    const flags = allocator.alloc(bool, n) catch {
        R.ring_vm_api_retnumber(p, 0);
        return;
    };
    defer allocator.free(flags);
    for (0..n) |j| {
        ub[j] = if (ubfin[j] != 0) ubf[j] else optim.INF;
        flags[j] = isint[j] != 0;
    }

    const sense = allocator.alloc(i8, m) catch {
        R.ring_vm_api_retnumber(p, 0);
        return;
    };
    defer allocator.free(sense);
    for (0..m) |i| sense[i] = @intFromFloat(sensef[i]);

    const x = allocator.alloc(f64, n) catch {
        R.ring_vm_api_retnumber(p, 0);
        return;
    };
    defer allocator.free(x);
    @memset(x, 0);

    const mo = optim.Model{
        .n = n,
        .m = m,
        .obj = obj,
        .maximize = maximize,
        .lb = lb,
        .ub = ub,
        .is_int = flags,
        .mat = mat,
        .sense = sense,
        .rhs = rhs,
    };

    const res = optim.solve(allocator, mo, x, max_nodes) catch {
        R.ring_vm_api_retnumber(p, 0);
        return;
    };

    const out = R.ring_vm_api_newlist(p) orelse return;
    R.ring_list_adddouble(out, @floatFromInt(@intFromEnum(res.status)));
    R.ring_list_adddouble(out, res.objective);
    R.ring_list_adddouble(out, @floatFromInt(res.nodes));
    R.ring_list_adddouble(out, @floatFromInt(res.iterations));
    R.ring_list_adddouble(out, if (res.branched) 1 else 0);
    for (x) |v| R.ring_list_adddouble(out, v);
    R.ring_vm_api_retlist(p, out);
}

// ─── LOGISTIC REGRESSION (phase 5) ───────────────────────────────────────────
//
//   StzEngineLogisticTrain(aXflat, aY, nRows, nFeat, nLr, nEpochs)
//     -> [ w1, w2, ..., wd, bias ]     (d+1 entries), or 0 on a refusal
//
// The features arrive FLAT rather than as a list of lists: the caller already
// has to walk its examples to build the y vector, so flattening costs it nothing,
// and it saves this side one Ring list traversal per row. n and d are passed
// rather than inferred, so a ragged input is REFUSED here instead of being
// silently truncated to the first row's width -- which is what the Ring loop did.
fn ring_LogisticTrain(p: *anyopaque) callconv(.c) void {
    const x = listToF64(p, 1) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(x);
    const y = listToF64(p, 2) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(y);

    const n: usize = @intFromFloat(g(p, 3));
    const d: usize = @intFromFloat(g(p, 4));
    const lr = g(p, 5);
    const epochs: usize = @intFromFloat(g(p, 6));

    if (n == 0 or d == 0 or x.len != n * d or y.len != n) {
        rn(p, 0);
        return;
    }

    const w = allocator.alloc(f64, d) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(w);

    const b = logistic.train(x, y, n, d, lr, epochs, w);

    const out = R.ring_vm_api_newlist(p) orelse return;
    for (w) |v| R.ring_list_adddouble(out, v);
    R.ring_list_adddouble(out, b);
    R.ring_vm_api_retlist(p, out);
}

//   StzEngineLogisticPredict(aXflat, nRows, nFeat, aW, nBias) -> [ p1, ..., pm ]
//
// Prediction goes through the engine too, and not for speed -- a single row is
// dominated by marshalling. It is here so that a model is SCORED BY THE RULE IT
// WAS FITTED BY. Ring's exp and Zig's exp agree to within an ulp, which is
// invisible in one prediction and not invisible after a hundred epochs of
// feedback; keeping both sides on one definition removes the question.
fn ring_LogisticPredict(p: *anyopaque) callconv(.c) void {
    const x = listToF64(p, 1) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(x);
    const m: usize = @intFromFloat(g(p, 2));
    const d: usize = @intFromFloat(g(p, 3));
    const w = listToF64(p, 4) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(w);
    const b = g(p, 5);

    if (m == 0 or d == 0 or x.len != m * d or w.len != d) {
        rn(p, 0);
        return;
    }

    const out_p = allocator.alloc(f64, m) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(out_p);

    logistic.predict(x, m, d, w, b, out_p);

    const out = R.ring_vm_api_newlist(p) orelse return;
    for (out_p) |v| R.ring_list_adddouble(out, v);
    R.ring_vm_api_retlist(p, out);
}

// ─── CLUSTERING (phase 5, second pass) ───────────────────────────────────────
//
//   StzEngineKnnTopK(aPointsFlat, nRows, nDim, aQuery, nK)
//     -> [ idx1, dist1, idx2, dist2, ... ]   ascending, 1-based indices
//
// ONE CROSSING PER QUERY instead of one per (query, example). The Ring loop asked
// the engine for a single distance N times, which meant marshalling two vectors N
// times to do N cheap subtractions -- the bridge cost more than the arithmetic by
// two orders of magnitude. Sending the whole matrix once inverts that.
fn ring_KnnTopK(p: *anyopaque) callconv(.c) void {
    const pts = listToF64(p, 1) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(pts);
    const n: usize = @intFromFloat(g(p, 2));
    const d: usize = @intFromFloat(g(p, 3));
    const q = listToF64(p, 4) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(q);
    const k: usize = @intFromFloat(g(p, 5));

    if (n == 0 or d == 0 or k == 0 or pts.len != n * d or q.len != d) {
        rn(p, 0);
        return;
    }
    const take = @min(k, n);

    const idx = allocator.alloc(i32, take) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(idx);
    const dst = allocator.alloc(f64, take) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(dst);

    const got = cluster.topK(pts, n, d, q, k, idx, dst);

    const out = R.ring_vm_api_newlist(p) orelse return;
    for (0..got) |i| {
        R.ring_list_adddouble(out, @floatFromInt(idx[i]));
        R.ring_list_adddouble(out, dst[i]);
    }
    R.ring_vm_api_retlist(p, out);
}

//   StzEngineKMeansRun(aPointsFlat, nRows, nDim, nK, nMaxIter)
//     -> [ iterations, seeded, c11..c1d, c21..c2d, ..., a1, a2, ... aN ]
//
// The WHOLE run in one crossing -- seeding, every assignment pass and every
// centroid update. The Ring version crossed once per (point, centroid, iteration).
fn ring_KMeansRun(p: *anyopaque) callconv(.c) void {
    const pts = listToF64(p, 1) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(pts);
    const n: usize = @intFromFloat(g(p, 2));
    const d: usize = @intFromFloat(g(p, 3));
    const k: usize = @intFromFloat(g(p, 4));
    const max_iter: usize = @intFromFloat(g(p, 5));

    if (n == 0 or d == 0 or k == 0 or pts.len != n * d) {
        rn(p, 0);
        return;
    }

    const cent = allocator.alloc(f64, k * d) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(cent);
    const asg = allocator.alloc(i32, n) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(asg);
    const cnt = allocator.alloc(usize, k) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(cnt);

    const res = cluster.kmeansRun(pts, n, d, k, max_iter, cent, asg, cnt);

    const out = R.ring_vm_api_newlist(p) orelse return;
    R.ring_list_adddouble(out, @floatFromInt(res.iterations));
    R.ring_list_adddouble(out, @floatFromInt(res.seeded));
    // on a refusal (too few distinct points) only the header is sent, so the
    // caller can raise with the real reason instead of clustering into fewer groups
    if (res.seeded == k) {
        for (cent) |v| R.ring_list_adddouble(out, v);
        for (asg) |v| R.ring_list_adddouble(out, @floatFromInt(v));
    }
    R.ring_vm_api_retlist(p, out);
}

//   StzEngineClusterDataNew(aPointsFlat, nRows, nDim) -> handle
//   StzEngineClusterDataFree(handle)
//   StzEngineKnnTopKOn(handle, aQuery, nK) -> [ idx1, dist1, ... ]
//
// The dataset is written once and read by every query, so it lives here rather
// than being re-marshalled per call. Measured at 10000 x 16, twenty queries:
// 2.254 s flattening per query, 0.679 s flattening once and re-sending, 0.021 s
// resident. The bridge, not the arithmetic, was the whole remaining cost.
fn ring_ClusterDataNew(p: *anyopaque) callconv(.c) void {
    const pts = listToF64(p, 1) orelse {
        rcp(p, null, H);
        return;
    };
    defer allocator.free(pts);
    const n: usize = @intFromFloat(g(p, 2));
    const d: usize = @intFromFloat(g(p, 3));
    if (n == 0 or d == 0 or pts.len != n * d) {
        rcp(p, null, H);
        return;
    }
    const ds = cluster.Dataset.init(allocator, n, d) catch {
        rcp(p, null, H);
        return;
    };
    @memcpy(ds.data, pts);
    rcp(p, ds, H);
}

fn ring_ClusterDataFree(p: *anyopaque) callconv(.c) void {
    const raw = gcp(p, 1, H) orelse {
        rn(p, 0);
        return;
    };
    const ds: *cluster.Dataset = @ptrCast(@alignCast(raw));
    ds.deinit();
    rn(p, 1);
}

fn ring_KnnTopKOn(p: *anyopaque) callconv(.c) void {
    const raw = gcp(p, 1, H) orelse {
        rn(p, 0);
        return;
    };
    const ds: *cluster.Dataset = @ptrCast(@alignCast(raw));
    const q = listToF64(p, 2) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(q);
    const k: usize = @intFromFloat(g(p, 3));
    if (k == 0 or q.len != ds.d) {
        rn(p, 0);
        return;
    }
    const take = @min(k, ds.n);
    const idx = allocator.alloc(i32, take) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(idx);
    const dst = allocator.alloc(f64, take) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(dst);

    const got = cluster.topKResident(ds, q, k, idx, dst);
    const out = R.ring_vm_api_newlist(p) orelse return;
    for (0..got) |i| {
        R.ring_list_adddouble(out, @floatFromInt(idx[i]));
        R.ring_list_adddouble(out, dst[i]);
    }
    R.ring_vm_api_retlist(p, out);
}

// ─── ID3 (phase 5, second pass) ──────────────────────────────────────────────
//
//   StzEngineTreeId3(aFeatCodes, aLabelCodes, nRows, nCols, nLabels, nValues)
//     -> flat tree: [ nodeCount, then per node:
//                     kind(0 leaf / 1 decision),
//                     leaf ? labelCode
//                          : featureIdx, defaultLabel, branchCount,
//                            (value, childNode) * branchCount ]
//     child indices are 1-based node numbers, so Ring can index its own array
//
// CODES, NOT STRINGS. Ring interns the feature values and the labels once -- work
// it already did, since it had to case-fold and scan them -- so nothing here
// compares a string and counting becomes an array index instead of a hash.
fn ring_TreeId3(p: *anyopaque) callconv(.c) void {
    const fv = listToF64(p, 1) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(fv);
    const lv = listToF64(p, 2) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(lv);

    const n: usize = @intFromFloat(g(p, 3));
    const d: usize = @intFromFloat(g(p, 4));
    const n_labels: usize = @intFromFloat(g(p, 5));
    const n_values: usize = @intFromFloat(g(p, 6));

    if (n == 0 or d == 0 or fv.len != n * d or lv.len != n or n_labels == 0) {
        rn(p, 0);
        return;
    }

    const feat = allocator.alloc(i32, fv.len) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(feat);
    for (fv, 0..) |v, i| feat[i] = @intFromFloat(v);

    const labels = allocator.alloc(i32, lv.len) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(labels);
    for (lv, 0..) |v, i| labels[i] = @intFromFloat(v);

    var t = tree.id3(allocator, feat, labels, n, d, n_labels, n_values) catch {
        rn(p, 0);
        return;
    };
    defer t.deinit(allocator);

    const out = R.ring_vm_api_newlist(p) orelse return;
    R.ring_list_adddouble(out, @floatFromInt(t.nodes.items.len));
    for (t.nodes.items) |nd| {
        if (nd.leaf_label >= 0) {
            R.ring_list_adddouble(out, 0);
            R.ring_list_adddouble(out, @floatFromInt(nd.leaf_label));
        } else {
            R.ring_list_adddouble(out, 1);
            R.ring_list_adddouble(out, @floatFromInt(nd.feature));
            R.ring_list_adddouble(out, @floatFromInt(nd.default_label));
            R.ring_list_adddouble(out, @floatFromInt(nd.branch_count));
            for (0..nd.branch_count) |b| {
                const at = nd.branch_start + b;
                R.ring_list_adddouble(out, @floatFromInt(t.branch_values.items[at]));
                R.ring_list_adddouble(out, @floatFromInt(t.branch_children.items[at] + 1));
            }
        }
    }
    R.ring_vm_api_retlist(p, out);
}

// ─── APRIORI (phase 5, second pass) ──────────────────────────────────────────
//
//   StzEngineAprioriCount(aItemCodes, aOffsets, nTx)
//     -> [ size, c1, c2, c3, count ] * k     (c2/c3 are -1 when unused)
//   keys come back in FIRST-COUNTED order, which FrequentItemsets() publishes
//
// The Ring version scanned a key list linearly. That beat HasKey by 479x and was
// still a scan over every singleton, pair and triple in the data.
fn ring_AprioriCount(p: *anyopaque) callconv(.c) void {
    const iv = listToF64(p, 1) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(iv);
    const ov = listToF64(p, 2) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(ov);
    const n_tx: usize = @intFromFloat(g(p, 3));

    if (n_tx == 0 or ov.len != n_tx + 1) {
        rn(p, 0);
        return;
    }

    const items = allocator.alloc(i32, iv.len) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(items);
    for (iv, 0..) |v, i| items[i] = @intFromFloat(v);

    const offs = allocator.alloc(u32, ov.len) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(offs);
    for (ov, 0..) |v, i| offs[i] = @intFromFloat(v);

    var res = apriori.countAll(allocator, items, offs, n_tx) catch {
        rn(p, 0);
        return;
    };
    defer res.deinit(allocator);

    const out = R.ring_vm_api_newlist(p) orelse return;
    for (res.keys.items, res.counts.items) |k, c| {
        R.ring_list_adddouble(out, @floatFromInt(k[0]));
        R.ring_list_adddouble(out, @floatFromInt(k[1]));
        R.ring_list_adddouble(out, @floatFromInt(k[2]));
        R.ring_list_adddouble(out, @floatFromInt(k[3]));
        R.ring_list_adddouble(out, @floatFromInt(c));
    }
    R.ring_vm_api_retlist(p, out);
}

// ─── NAIVE BAYES (phase 5, second pass) ──────────────────────────────────────
//
//   StzEngineBayesNew() -> handle          StzEngineBayesFree(handle)
//   StzEngineBayesTrain(handle, cText, cLabel)
//   StzEngineBayesScores(handle, cText) -> [ score-per-label, in label order ]
//   StzEngineBayesLabels(handle) -> [ label, ... ] first-seen order
//
// The MODEL is resident, not just the counting. Ring's _TokensOf built a whole
// stzText per document to reach the word iterator -- about a third of the cost at
// 3000 documents -- so tokenization crossed too, using the SAME UAX#29 WordIter
// str_extract_words walks and the same case fold StzLower applies. A different
// tokenizer here would be a different model, agreeing on "the cat sat" and
// disagreeing on "don't", "3.14", "word2vec" and anything CJK.
const BH: [*:0]const u8 = "StzBayesHandle";

/// A string parameter as a slice. ring_vm_api_getstring returns the bytes and
/// getstringsize the length -- the pointer alone is not NUL-terminated for
/// arbitrary Ring strings, so both are needed.
fn strParam(p: *anyopaque, n: c_int) []const u8 {
    const ptr = R.ring_vm_api_getstring(p, n);
    const len: usize = @intCast(R.ring_vm_api_getstringsize(p, n));
    return ptr[0..len];
}

fn getBayes(p: *anyopaque, n: c_int) ?*bayes.Model {
    const raw = gcp(p, n, BH) orelse return null;
    return @ptrCast(@alignCast(raw));
}

fn ring_BayesNew(p: *anyopaque) callconv(.c) void {
    const m = bayes.Model.init(allocator) catch {
        rcp(p, null, BH);
        return;
    };
    rcp(p, m, BH);
}

fn ring_BayesFree(p: *anyopaque) callconv(.c) void {
    const m = getBayes(p, 1) orelse {
        rn(p, 0);
        return;
    };
    m.deinit();
    rn(p, 1);
}

fn ring_BayesTrain(p: *anyopaque) callconv(.c) void {
    const m = getBayes(p, 1) orelse {
        rn(p, 0);
        return;
    };
    const text = strParam(p, 2);
    const label = strParam(p, 3);
    bayes.train(m, text, label) catch {
        rn(p, 0);
        return;
    };
    rn(p, 1);
}

fn ring_BayesScores(p: *anyopaque) callconv(.c) void {
    const m = getBayes(p, 1) orelse {
        rn(p, 0);
        return;
    };
    const text = strParam(p, 2);
    const n = m.labels.items.len;
    if (n == 0 or m.n_docs == 0) {
        rn(p, 0);
        return;
    }
    const scores = allocator.alloc(f64, n) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(scores);
    _ = bayes.classify(m, text, scores) catch {
        rn(p, 0);
        return;
    };
    const out = R.ring_vm_api_newlist(p) orelse return;
    for (scores) |v| R.ring_list_adddouble(out, v);
    R.ring_vm_api_retlist(p, out);
}

fn ring_BayesLabels(p: *anyopaque) callconv(.c) void {
    const m = getBayes(p, 1) orelse {
        rn(p, 0);
        return;
    };
    const out = R.ring_vm_api_newlist(p) orelse return;
    for (m.labels.items) |l| R.ring_list_addstring2(out, l.ptr, @intCast(l.len));
    R.ring_vm_api_retlist(p, out);
}

fn ring_BayesStats(p: *anyopaque) callconv(.c) void {
    const m = getBayes(p, 1) orelse {
        rn(p, 0);
        return;
    };
    const out = R.ring_vm_api_newlist(p) orelse return;
    R.ring_list_adddouble(out, @floatFromInt(m.n_docs));
    R.ring_list_adddouble(out, @floatFromInt(m.vocab.count()));
    R.ring_vm_api_retlist(p, out);
}

// ─── AUTODIFF (phase 6 slice 1) ──────────────────────────────────────────────
//
//   StzEngineGradCompile(cExpr, cCommaSeparatedNames) -> handle (0 on failure)
//   StzEngineGradWhy()  -> why the last compile failed, in words
//   StzEngineGradAt(handle, anValues)      -> [ value, d/dv1, d/dv2, ... ]
//   StzEngineGradValueAt(handle, anValues) -> value only
//   StzEngineGradFree(handle)
//
// Names arrive as one comma-separated string rather than a Ring list because the
// bridge has no string-list reader and one delimiter is a smaller thing to add
// than one. Values arrive as a list, in the same order as the names.
//
// THE FAILURE REASON IS A SEPARATE CALL because a null handle says only "no". A
// caller who typed `x + zz` deserves to be told which name is unknown, not to be
// handed a null and left guessing -- this library has been bitten before by an
// error that named the wrong cause (see :CanNotCreateDecimalNumber2).
const GH: [*:0]const u8 = "StzGradHandle";
var grad_last_error: []const u8 = "";

fn ring_GradCompile(p: *anyopaque) callconv(.c) void {
    const src = strParam(p, 1);
    const names_raw = strParam(p, 2);

    var names: [autodiff.MAX_VARS][]const u8 = undefined;
    var n: usize = 0;
    var it = std.mem.splitScalar(u8, names_raw, ',');
    while (it.next()) |raw| {
        const nm = std.mem.trim(u8, raw, &[_]u8{ ' ', '\t' });
        if (nm.len == 0) continue;
        if (n >= autodiff.MAX_VARS) {
            grad_last_error = "too many variables";
            rcp(p, null, GH);
            return;
        }
        names[n] = nm;
        n += 1;
    }

    const prog = autodiff.compile(allocator, src, names[0..n]) catch |e| {
        grad_last_error = switch (e) {
            error.UnknownName => "there is a name in the expression that is not one of the variables",
            error.UnknownFunction => "there is a function call the engine does not know",
            error.MissingParen => "a parenthesis is not closed",
            error.BadArity => "a function was given the wrong number of arguments",
            error.UnexpectedCharacter => "there is a character the expression cannot use",
            error.UnexpectedEnd => "the expression stops in the middle",
            error.TooManyVars => "too many variables",
            error.Empty => "the expression is empty",
            error.OutOfMemory => "out of memory",
        };
        rcp(p, null, GH);
        return;
    };
    grad_last_error = "";
    rcp(p, prog, GH);
}

fn ring_GradWhy(p: *anyopaque) callconv(.c) void {
    R.ring_vm_api_retstring2(p, grad_last_error.ptr, @intCast(grad_last_error.len));
}

fn getGrad(p: *anyopaque, n: c_int) ?*autodiff.Program {
    const raw = gcp(p, n, GH) orelse return null;
    return @ptrCast(@alignCast(raw));
}

fn ring_GradFree(p: *anyopaque) callconv(.c) void {
    const prog = getGrad(p, 1) orelse {
        rn(p, 0);
        return;
    };
    prog.deinit();
    rn(p, 1);
}

fn ring_GradAt(p: *anyopaque) callconv(.c) void {
    const prog = getGrad(p, 1) orelse {
        rn(p, 0);
        return;
    };
    const xs = listToF64(p, 2) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(xs);
    if (xs.len != prog.n_vars) {
        rn(p, 0);
        return;
    }
    const n_nodes = prog.nodes.items.len;
    const val = allocator.alloc(f64, n_nodes) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(val);
    const adj = allocator.alloc(f64, n_nodes) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(adj);
    const grad = allocator.alloc(f64, prog.n_vars) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(grad);

    const v = autodiff.valueAndGradient(prog, xs, val, adj, grad);
    const out = R.ring_vm_api_newlist(p) orelse return;
    R.ring_list_adddouble(out, v);
    for (grad) |gv| R.ring_list_adddouble(out, gv);
    R.ring_vm_api_retlist(p, out);
}

fn ring_GradValueAt(p: *anyopaque) callconv(.c) void {
    const prog = getGrad(p, 1) orelse {
        rn(p, 0);
        return;
    };
    const xs = listToF64(p, 2) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(xs);
    if (xs.len != prog.n_vars) {
        rn(p, 0);
        return;
    }
    const val = allocator.alloc(f64, prog.nodes.items.len) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(val);
    rn(p, autodiff.value(prog, xs, val));
}

// ─── L-BFGS (phase 6 slice 2) ────────────────────────────────────────────────
//
//   StzEngineMinimize(gradHandle, anStart, nMaxIter, nGradTol)
//     -> [ status, value, iterations, evaluations, gradNorm, x1, x2, ... ]
//
// status: 0 gradient converged, 1 step converged, 2 iteration limit,
//         3 line search failed, 4 objective was not finite at the start.
//
// The optimiser takes a function pointer, so the tape is only ONE objective it can
// minimise; this bridge is the tape's adapter, not the optimiser's only door.
const TapeObjective = struct {
    prog: *autodiff.Program,
    val: []f64,
    adj: []f64,
};

fn tapeEval(ctx: ?*anyopaque, x: []const f64, grad: []f64) f64 {
    const t: *TapeObjective = @ptrCast(@alignCast(ctx.?));
    return autodiff.valueAndGradient(t.prog, x, t.val, t.adj, grad);
}

fn ring_Minimize(p: *anyopaque) callconv(.c) void {
    const prog = getGrad(p, 1) orelse {
        rn(p, 0);
        return;
    };
    const start = listToF64(p, 2) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(start);
    const max_it: usize = @intFromFloat(g(p, 3));
    const gtol = g(p, 4);

    if (start.len != prog.n_vars) {
        rn(p, 0);
        return;
    }

    const n_nodes = prog.nodes.items.len;
    const val = allocator.alloc(f64, n_nodes) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(val);
    const adj = allocator.alloc(f64, n_nodes) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(adj);

    const x = allocator.alloc(f64, start.len) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(x);
    @memcpy(x, start);

    var obj = TapeObjective{ .prog = prog, .val = val, .adj = adj };
    const res = lbfgs.minimize(allocator, tapeEval, &obj, x, .{
        .max_iterations = if (max_it == 0) 500 else max_it,
        .gradient_tolerance = if (gtol <= 0) 1e-8 else gtol,
    }) catch {
        rn(p, 0);
        return;
    };

    const out = R.ring_vm_api_newlist(p) orelse return;
    R.ring_list_adddouble(out, @floatFromInt(@intFromEnum(res.status)));
    R.ring_list_adddouble(out, res.value);
    R.ring_list_adddouble(out, @floatFromInt(res.iterations));
    R.ring_list_adddouble(out, @floatFromInt(res.evaluations));
    R.ring_list_adddouble(out, res.gradient_norm);
    for (x) |v| R.ring_list_adddouble(out, v);
    R.ring_vm_api_retlist(p, out);
}

// ─── NEURAL TRAINING (phase 6 slice 3) ───────────────────────────────────────
//
//   StzEngineNNTrain(aShape, aWeights, aInputs, aTargets, nSamples, nLr, nEpochs)
//     -> [ loss-per-epoch (nEpochs), then the trained weights in the same layout ]
//
//   aShape   = [ nInputs, nLayers, units1, act1, units2, act2, ... ]
//   act code = 0 relu, 1 sigmoid, 2 tanh, 3 linear, 4 softmax
//   aWeights = per layer: W row-major (units * prev) then b (units)
//
// NOT on the autodiff tape, deliberately -- see the note at the top of nn.zig. The
// hand-derived gradients were already exact (checked against that very tape), a
// tape is slower than closed-form code for a fixed architecture, and rebuilding
// the trainer around "the gradient of the reported loss" would have reintroduced
// the saddle the Ring comment records.
fn ring_NNTrain(p: *anyopaque) callconv(.c) void {
    const shape = listToF64(p, 1) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(shape);
    const wflat = listToF64(p, 2) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(wflat);
    const inputs = listToF64(p, 3) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(inputs);
    const targets = listToF64(p, 4) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(targets);
    const n_samples: usize = @intFromFloat(g(p, 5));
    const lr = g(p, 6);
    const epochs: usize = @intFromFloat(g(p, 7));

    if (shape.len < 4 or n_samples == 0 or epochs == 0) {
        rn(p, 0);
        return;
    }
    const n_in: usize = @intFromFloat(shape[0]);
    const n_layers: usize = @intFromFloat(shape[1]);
    if (n_layers == 0 or shape.len != 2 + n_layers * 2) {
        rn(p, 0);
        return;
    }

    const layers = allocator.alloc(nn.Layer, n_layers) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(layers);

    var prev = n_in;
    var at: usize = 0;
    var ok_shape = true;
    for (0..n_layers) |i| {
        const units: usize = @intFromFloat(shape[2 + i * 2]);
        const code: u8 = @intFromFloat(shape[3 + i * 2]);
        if (units == 0 or code > 4) {
            ok_shape = false;
            break;
        }
        const need = units * prev + units;
        if (at + need > wflat.len) {
            ok_shape = false;
            break;
        }
        layers[i] = .{
            .units = units,
            .prev = prev,
            .kind = @enumFromInt(code),
            .w = wflat[at..][0 .. units * prev],
            .b = wflat[at + units * prev ..][0..units],
        };
        at += need;
        prev = units;
    }
    const n_out = prev;
    if (!ok_shape or at != wflat.len or
        inputs.len != n_samples * n_in or targets.len != n_samples * n_out)
    {
        rn(p, 0);
        return;
    }

    var net = nn.Net{ .n_inputs = n_in, .layers = layers };
    const losses = allocator.alloc(f64, epochs) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(losses);

    // trains IN PLACE over wflat, which is this bridge's own copy of the Ring list
    nn.train(allocator, &net, inputs, targets, n_samples, n_out, lr, epochs, losses) catch {
        rn(p, 0);
        return;
    };

    const out = R.ring_vm_api_newlist(p) orelse return;
    for (losses) |v| R.ring_list_adddouble(out, v);
    for (wflat) |v| R.ring_list_adddouble(out, v);
    R.ring_vm_api_retlist(p, out);
}

// ─── GENERAL EIGENVALUES (phase 7) ───────────────────────────────────────────
//
//   StzEngineEigenGeneral(aFlatRowMajor, n) -> [ re1, im1, re2, im2, ... ]
//                                              or 0 if the iteration gave up
//
// Lifts the refusal phase 4 slice 8 wrote down: a general matrix has complex
// eigenvalues, so the symmetric Jacobi routine could not be stretched to cover it.
// Francis double-shift QR on the balanced Hessenberg form.
//   StzEngineFft(aRe, aIm, bInverse) -> [ re0, im0, re1, im1, ... ]
//
// Any length: a power of two takes radix-2, anything else takes Bluestein, so the
// caller never has to think about it and is never silently zero-padded. aIm may be
// an empty list for a real signal.
//   StzEngineAnnBuild(aPointsFlat, nRows, nDim, nTrees, bCosine, nSeed) -> handle
//   StzEngineAnnFree(handle)
//   StzEngineAnnSearch(handle, aQuery, nK, nBudget)      -> [ idx, dist, ... ] 0-based
//   StzEngineAnnSearchExact(handle, aQuery, nK)          -> the same, by full scan
//   StzEngineAnnCount(handle) / StzEngineAnnDim(handle)
//
// The corpus is written once and read by every query, so it stays resident here for
// the same reason the k-NN dataset does: the bridge, not the arithmetic, is the cost.
//   StzEngineKnnModelNew(aPoints, nRows, nDim, aCodes, nLabels, bApprox, nTrees, nSeed)
//   StzEngineKnnModelFree(handle)
//   StzEngineKnnModelClassify(handle, aQuery, nK, nBudget)
//       -> [ winCode, winVotes, used, (idx, dist, code) * used ]
//   StzEngineKnnModelAgreement(handle, aQueriesFlat, nQ, nK, nBudget) -> fraction
//
// A COMPLETE CLASSIFIER, not a search a host has to finish. The verdict -- winner,
// vote count, and the neighbours it reasoned from -- comes back in one crossing, so
// every binding gets the same decision and the same tie rule instead of writing its
// own tally loop. Labels cross as codes; interning is the host's marshalling job,
// the same convention the ID3 bridge above uses.
// ─── complete operations that used to be finished in the host ────────────────
//
//   StzEngineFftMagnitudes(aRe, aIm)   -> |X_k| per bin
//   StzEngineFftPhases(aRe, aIm)       -> phase per bin
//   StzEngineFftPower(aRe, aIm)        -> |X_k|^2 per bin
//   StzEngineFftDominantBin(aRe, aIm)  -> 0-based bin, DC excluded, first half only
//   StzEngineAnnRecall(handle, aQueriesFlat, nQ, nK, nBudget) -> recall@k
//   StzEnginePolyRoots(aCoeffs)        -> [ re, im, ... ]
//   StzEnginePolyCompanion(aCoeffs)    -> [ n, row-major n*n ]
//   StzEngineFrameDescribe(aCol)       -> 8 numbers
//   StzEngineFrameDescribeAll(aFlat, nRows, nCols) -> nCols * 8
//   StzEngineFrameCorrMatrix(aFlat, nRows, nCols)  -> nCols * nCols
//   StzEngineFrameRegression(aX, aY)   -> [ slope, intercept, r2 ] or 0
fn fftRead(p: *anyopaque, which: u8) void {
    const re = listToF64(p, 1) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(re);
    const n = re.len;
    if (n == 0) {
        rn(p, 0);
        return;
    }
    const im = allocator.alloc(f64, n) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(im);
    @memset(im, 0);
    if (listToF64(p, 2)) |given| {
        defer allocator.free(given);
        if (given.len == n) @memcpy(im, given);
    }

    if (which == 3) {
        const bin = fft_mod.dominantBin(allocator, re, im) catch {
            rn(p, 0);
            return;
        };
        rn(p, @floatFromInt(bin));
        return;
    }

    const out = allocator.alloc(f64, n) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(out);
    switch (which) {
        0 => fft_mod.magnitudes(allocator, re, im, out) catch {
            rn(p, 0);
            return;
        },
        1 => fft_mod.phases(allocator, re, im, out) catch {
            rn(p, 0);
            return;
        },
        else => fft_mod.powerSpectrum(allocator, re, im, out) catch {
            rn(p, 0);
            return;
        },
    }
    const lst = R.ring_vm_api_newlist(p) orelse return;
    for (out) |v| R.ring_list_adddouble(lst, v);
    R.ring_vm_api_retlist(p, lst);
}

fn ring_FftMagnitudes(p: *anyopaque) callconv(.c) void {
    fftRead(p, 0);
}
fn ring_FftPhases(p: *anyopaque) callconv(.c) void {
    fftRead(p, 1);
}
fn ring_FftPower(p: *anyopaque) callconv(.c) void {
    fftRead(p, 2);
}
fn ring_FftDominantBin(p: *anyopaque) callconv(.c) void {
    fftRead(p, 3);
}

fn ring_AnnRecall(p: *anyopaque) callconv(.c) void {
    const raw = gcp(p, 1, H) orelse {
        rn(p, -1);
        return;
    };
    const ix: *ann_mod.Index = @ptrCast(@alignCast(raw));
    const qs = listToF64(p, 2) orelse {
        rn(p, -1);
        return;
    };
    defer allocator.free(qs);
    const nq: usize = @intFromFloat(g(p, 3));
    const k: usize = @intFromFloat(g(p, 4));
    const budget: usize = @intFromFloat(g(p, 5));
    const r = ann_mod.recallAgainstExact(ix, allocator, qs, nq, k, budget) catch {
        rn(p, -1);
        return;
    };
    rn(p, r);
}

fn ring_PolyRoots(p: *anyopaque) callconv(.c) void {
    const c = listToF64(p, 1) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(c);
    const deg = poly_mod.degreeOf(c);
    if (deg == 0) {
        const empty = R.ring_vm_api_newlist(p) orelse return;
        R.ring_vm_api_retlist(p, empty);
        return;
    }
    const out = allocator.alloc(cmplx.Complex, deg) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(out);
    const got = poly_mod.roots(allocator, c, out) catch {
        rn(p, 0);
        return;
    };
    const lst = R.ring_vm_api_newlist(p) orelse return;
    for (out[0..got]) |z| {
        R.ring_list_adddouble(lst, z.re);
        R.ring_list_adddouble(lst, z.im);
    }
    R.ring_vm_api_retlist(p, lst);
}

fn ring_PolyCompanion(p: *anyopaque) callconv(.c) void {
    const c = listToF64(p, 1) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(c);
    const deg = poly_mod.degreeOf(c);
    if (deg == 0) {
        rn(p, 0);
        return;
    }
    const m = allocator.alloc(f64, deg * deg) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(m);
    _ = poly_mod.companion(c, m) catch {
        rn(p, 0);
        return;
    };
    const lst = R.ring_vm_api_newlist(p) orelse return;
    R.ring_list_adddouble(lst, @floatFromInt(deg));
    for (m) |v| R.ring_list_adddouble(lst, v);
    R.ring_vm_api_retlist(p, lst);
}

//   StzEnginePlotBar(aValues, cLabelsJoined, aOptions) -> the finished text
//
// THE FINISHED PICTURE, not a layout. A host passes data and knobs and prints what
// comes back, so a plot exists for every language over this engine and not only for
// the one that happened to own the renderer.
//
// aOptions is a flat numeric list in the order of plot.BarOptions:
//   height, barWidth, interSpace, vAxisWidth, axisPadding, maxLabelWidth,
//   showHAxis, showVAxis, showLabels, showAxisLabels, showValues, showPercent,
//   showAverage
// A short or empty list keeps the defaults for whatever it does not mention.
fn ring_PlotBar(p: *anyopaque) callconv(.c) void {
    const vals = listToF64(p, 1) orelse {
        rs(p, "");
        return;
    };
    defer allocator.free(vals);
    if (vals.len == 0) {
        rs(p, "");
        return;
    }
    // strParam, not getstring alone: a Ring string is not NUL-terminated, so the
    // length has to come from getstringsize
    const lab = strParam(p, 2);

    var opts = plot_mod.BarOptions{};
    if (listToF64(p, 3)) |o| {
        defer allocator.free(o);
        if (o.len > 0) opts.height = @intFromFloat(o[0]);
        if (o.len > 1) opts.bar_width = @intFromFloat(o[1]);
        if (o.len > 2) opts.inter_space = @intFromFloat(o[2]);
        if (o.len > 3) opts.v_axis_width = @intFromFloat(o[3]);
        if (o.len > 4) opts.axis_padding = @intFromFloat(o[4]);
        if (o.len > 5) opts.max_label_width = @intFromFloat(o[5]);
        if (o.len > 6) opts.show_h_axis = if (o[6] != 0) 1 else 0;
        if (o.len > 7) opts.show_v_axis = if (o[7] != 0) 1 else 0;
        if (o.len > 8) opts.show_labels = if (o[8] != 0) 1 else 0;
        if (o.len > 9) opts.show_axis_labels = if (o[9] != 0) 1 else 0;
        if (o.len > 10) opts.show_values = if (o[10] != 0) 1 else 0;
        if (o.len > 11) opts.show_percent = if (o[11] != 0) 1 else 0;
        if (o.len > 12) opts.show_average = if (o[12] != 0) 1 else 0;
        // THE CHOSEN CHARACTERS RIDE AS CODEPOINTS, on the end of the same list.
        // A character is one number, so it needs no second string argument and no
        // allocation; zero means the caller left it alone.
        if (o.len > 13) opts.bar_char = @intFromFloat(o[13]);
        if (o.len > 14) opts.top_char = @intFromFloat(o[14]);
        if (o.len > 15) opts.h_axis_char = @intFromFloat(o[15]);
        if (o.len > 16) opts.v_axis_char = @intFromFloat(o[16]);
    }

    const txt = plot_mod.renderBar(allocator, vals, lab, opts) catch {
        rs(p, "");
        return;
    };
    defer allocator.free(txt);
    rs2(p, txt.ptr, @intCast(txt.len));
}

//   StzEnginePlotHBar(aValues, cLabelsJoined, aOptions) -> the finished text
//
// aOptions order matches plot.HBarOptions:
//   width, barHeight, maxHeight, maxLabelWidth, interSpace, axisPadding,
//   showHAxis, showVAxis, showLabels, showAxisLabels, showValues, showPercent
//   StzEnginePlotHistogram(aCounts, aEdges, aOptions) -> the finished text
//
// aOptions order matches plot.HistOptions:
//   barWidth, height, maxLabelWidth, barInterSpace, labelInterSpace,
//   axisPadding, vAxisWidth, showHAxis, showVAxis, showLabels,
//   showFrequency, showPercent
//   StzEnginePlotMBar(aValuesFlat, nSeries, nCats, cSeriesJoined, cCatsJoined, aOptions)
//     -> the finished text
//
// aValuesFlat is series-major: series s, category c at s * nCats + c.
// aOptions order matches plot.MBarOptions:
//   barWidth, height, seriesSpace, categorySpace, maxLabelWidth, vAxisWidth,
//   axisPadding, showHAxis, showVAxis, showLabels, showAxisLabels, showLegend
//   StzEnginePlotScatter(aH, aV, aOptions) -> the finished text
//
// aOptions order matches plot.ScatterOptions:
//   maxWidth, maxHeight, hAxisHeight, rightMargin,
//   showHAxis, showVAxis, showLetters
//   StzEnginePlotSurface(anValues, cLabelsJoined, aOptions) -> the finished text
//
// aOptions order matches plot.SurfaceOptions:
//   width, height, minWidth, maxWidth, minLabelWidth,
//   showBorders, showLabels, showValues, showPercent
fn ring_PlotSurface(p: *anyopaque) callconv(.c) void {
    const vals = listToF64(p, 1) orelse {
        rs(p, "");
        return;
    };
    defer allocator.free(vals);
    if (vals.len == 0) {
        rs(p, "");
        return;
    }
    const lab = strParam(p, 2);

    var opts = plot_mod.SurfaceOptions{};
    if (listToF64(p, 3)) |o| {
        defer allocator.free(o);
        if (o.len > 0) opts.width = @intFromFloat(o[0]);
        if (o.len > 1) opts.height = @intFromFloat(o[1]);
        if (o.len > 2) opts.min_width = @intFromFloat(o[2]);
        if (o.len > 3) opts.max_width = @intFromFloat(o[3]);
        if (o.len > 4) opts.min_label_width = @intFromFloat(o[4]);
        if (o.len > 5) opts.show_borders = if (o[5] != 0) 1 else 0;
        if (o.len > 6) opts.show_labels = if (o[6] != 0) 1 else 0;
        if (o.len > 7) opts.show_values = if (o[7] != 0) 1 else 0;
        if (o.len > 8) opts.show_percent = if (o[8] != 0) 1 else 0;
    }

    const txt = plot_mod.renderSurface(allocator, vals, lab, opts) catch {
        rs(p, "");
        return;
    };
    defer allocator.free(txt);
    rs2(p, txt.ptr, @intCast(txt.len));
}

fn ring_PlotScatter(p: *anyopaque) callconv(.c) void {
    const hs = listToF64(p, 1) orelse {
        rs(p, "");
        return;
    };
    defer allocator.free(hs);
    const vs = listToF64(p, 2) orelse {
        rs(p, "");
        return;
    };
    defer allocator.free(vs);
    if (hs.len == 0 or vs.len == 0) {
        rs(p, "");
        return;
    }

    var opts = plot_mod.ScatterOptions{};
    if (listToF64(p, 3)) |o| {
        defer allocator.free(o);
        if (o.len > 0) opts.max_width = @intFromFloat(o[0]);
        if (o.len > 1) opts.max_height = @intFromFloat(o[1]);
        if (o.len > 2) opts.h_axis_height = @intFromFloat(o[2]);
        if (o.len > 3) opts.right_margin = @intFromFloat(o[3]);
        if (o.len > 4) opts.show_h_axis = if (o[4] != 0) 1 else 0;
        if (o.len > 5) opts.show_v_axis = if (o[5] != 0) 1 else 0;
        if (o.len > 6) opts.show_letters = if (o[6] != 0) 1 else 0;
        if (o.len > 7) opts.point_char = @intFromFloat(o[7]);
    }

    const txt = plot_mod.renderScatter(allocator, hs, vs, opts) catch {
        rs(p, "");
        return;
    };
    defer allocator.free(txt);
    rs2(p, txt.ptr, @intCast(txt.len));
}

fn ring_PlotMBar(p: *anyopaque) callconv(.c) void {
    const vals = listToF64(p, 1) orelse {
        rs(p, "");
        return;
    };
    defer allocator.free(vals);
    const ns: usize = @intFromFloat(g(p, 2));
    const nc: usize = @intFromFloat(g(p, 3));
    if (ns == 0 or nc == 0 or vals.len < ns * nc) {
        rs(p, "");
        return;
    }
    const snames = strParam(p, 4);
    const cats = strParam(p, 5);
    // one glyph per series, newline-joined; empty means the house palette
    const schars = strParam(p, 7);

    var opts = plot_mod.MBarOptions{};
    if (listToF64(p, 6)) |o| {
        defer allocator.free(o);
        if (o.len > 0) opts.bar_width = @intFromFloat(o[0]);
        if (o.len > 1) opts.height = @intFromFloat(o[1]);
        if (o.len > 2) opts.series_space = @intFromFloat(o[2]);
        if (o.len > 3) opts.category_space = @intFromFloat(o[3]);
        if (o.len > 4) opts.max_label_width = @intFromFloat(o[4]);
        if (o.len > 5) opts.v_axis_width = @intFromFloat(o[5]);
        if (o.len > 6) opts.axis_padding = @intFromFloat(o[6]);
        if (o.len > 7) opts.show_h_axis = if (o[7] != 0) 1 else 0;
        if (o.len > 8) opts.show_v_axis = if (o[8] != 0) 1 else 0;
        if (o.len > 9) opts.show_labels = if (o[9] != 0) 1 else 0;
        if (o.len > 10) opts.show_axis_labels = if (o[10] != 0) 1 else 0;
        if (o.len > 11) opts.show_legend = if (o[11] != 0) 1 else 0;
    }

    const txt = plot_mod.renderMBar(allocator, vals, ns, nc, snames, cats, opts, schars) catch {
        rs(p, "");
        return;
    };
    defer allocator.free(txt);
    rs2(p, txt.ptr, @intCast(txt.len));
}

fn ring_PlotHistogram(p: *anyopaque) callconv(.c) void {
    const cf = listToF64(p, 1) orelse {
        rs(p, "");
        return;
    };
    defer allocator.free(cf);
    if (cf.len == 0) {
        rs(p, "");
        return;
    }
    const counts = allocator.alloc(u32, cf.len) catch {
        rs(p, "");
        return;
    };
    defer allocator.free(counts);
    for (cf, 0..) |v, i| counts[i] = @intFromFloat(v);

    const edges = listToF64(p, 2) orelse {
        rs(p, "");
        return;
    };
    defer allocator.free(edges);

    var opts = plot_mod.HistOptions{};
    if (listToF64(p, 3)) |o| {
        defer allocator.free(o);
        if (o.len > 0) opts.bar_width = @intFromFloat(o[0]);
        if (o.len > 1) opts.height = @intFromFloat(o[1]);
        if (o.len > 2) opts.max_label_width = @intFromFloat(o[2]);
        if (o.len > 3) opts.bar_inter_space = @intFromFloat(o[3]);
        if (o.len > 4) opts.label_inter_space = @intFromFloat(o[4]);
        if (o.len > 5) opts.axis_padding = @intFromFloat(o[5]);
        if (o.len > 6) opts.v_axis_width = @intFromFloat(o[6]);
        if (o.len > 7) opts.show_h_axis = if (o[7] != 0) 1 else 0;
        if (o.len > 8) opts.show_v_axis = if (o[8] != 0) 1 else 0;
        if (o.len > 9) opts.show_labels = if (o[9] != 0) 1 else 0;
        if (o.len > 10) opts.show_frequency = if (o[10] != 0) 1 else 0;
        if (o.len > 11) opts.show_percent = if (o[11] != 0) 1 else 0;
        if (o.len > 12) opts.bar_char = @intFromFloat(o[12]);
        if (o.len > 13) opts.final_bar_char = @intFromFloat(o[13]);
    }

    const txt = plot_mod.renderHistogram(allocator, counts, edges, opts) catch {
        rs(p, "");
        return;
    };
    defer allocator.free(txt);
    rs2(p, txt.ptr, @intCast(txt.len));
}

//   StzEngineBinValues(aValues, nBins) -> [ nbins, edges..., counts... ]
//
// Binning WITHOUT drawing: a host asking how data is distributed wants edges and
// counts, not a picture.
fn ring_BinValues(p: *anyopaque) callconv(.c) void {
    const vals = listToF64(p, 1) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(vals);
    if (vals.len == 0) {
        rn(p, 0);
        return;
    }
    const want: usize = @intFromFloat(g(p, 2));
    const nb = plot_mod.binCountFor(vals.len, want);
    const edges = allocator.alloc(f64, nb + 1) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(edges);
    const counts = allocator.alloc(u32, nb) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(counts);
    const got = plot_mod.binValues(vals, want, edges, counts) catch {
        rn(p, 0);
        return;
    };
    const lst = R.ring_vm_api_newlist(p) orelse return;
    R.ring_list_adddouble(lst, @floatFromInt(got));
    for (edges[0 .. got + 1]) |e| R.ring_list_adddouble(lst, e);
    for (counts[0..got]) |c| R.ring_list_adddouble(lst, @floatFromInt(c));
    R.ring_vm_api_retlist(p, lst);
}

fn ring_PlotHBar(p: *anyopaque) callconv(.c) void {
    const vals = listToF64(p, 1) orelse {
        rs(p, "");
        return;
    };
    defer allocator.free(vals);
    if (vals.len == 0) {
        rs(p, "");
        return;
    }
    const lab = strParam(p, 2);

    var opts = plot_mod.HBarOptions{};
    if (listToF64(p, 3)) |o| {
        defer allocator.free(o);
        if (o.len > 0) opts.width = @intFromFloat(o[0]);
        if (o.len > 1) opts.bar_height = @intFromFloat(o[1]);
        if (o.len > 2) opts.max_height = @intFromFloat(o[2]);
        if (o.len > 3) opts.max_label_width = @intFromFloat(o[3]);
        if (o.len > 4) opts.inter_space = @intFromFloat(o[4]);
        if (o.len > 5) opts.axis_padding = @intFromFloat(o[5]);
        if (o.len > 6) opts.show_h_axis = if (o[6] != 0) 1 else 0;
        if (o.len > 7) opts.show_v_axis = if (o[7] != 0) 1 else 0;
        if (o.len > 8) opts.show_labels = if (o[8] != 0) 1 else 0;
        if (o.len > 9) opts.show_axis_labels = if (o[9] != 0) 1 else 0;
        if (o.len > 10) opts.show_values = if (o[10] != 0) 1 else 0;
        if (o.len > 11) opts.show_percent = if (o[11] != 0) 1 else 0;
        if (o.len > 12) opts.bar_char = @intFromFloat(o[12]);
        if (o.len > 13) opts.h_axis_char = @intFromFloat(o[13]);
        if (o.len > 14) opts.v_axis_char = @intFromFloat(o[14]);
    }

    const txt = plot_mod.renderHBar(allocator, vals, lab, opts) catch {
        rs(p, "");
        return;
    };
    defer allocator.free(txt);
    rs2(p, txt.ptr, @intCast(txt.len));
}

fn ring_FrameDescribe(p: *anyopaque) callconv(.c) void {
    const col = listToF64(p, 1) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(col);
    var out = [_]f64{0} ** frame_mod.DESCRIBE_LEN;
    frame_mod.describeColumn(col, &out) catch {
        rn(p, 0);
        return;
    };
    const lst = R.ring_vm_api_newlist(p) orelse return;
    for (out) |v| R.ring_list_adddouble(lst, v);
    R.ring_vm_api_retlist(p, lst);
}

fn ring_FrameDescribeAll(p: *anyopaque) callconv(.c) void {
    const flat = listToF64(p, 1) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(flat);
    const nr: usize = @intFromFloat(g(p, 2));
    const nc: usize = @intFromFloat(g(p, 3));
    if (nr == 0 or nc == 0) {
        rn(p, 0);
        return;
    }
    const out = allocator.alloc(f64, nc * frame_mod.DESCRIBE_LEN) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(out);
    frame_mod.describeAll(allocator, flat, nr, nc, out) catch {
        rn(p, 0);
        return;
    };
    const lst = R.ring_vm_api_newlist(p) orelse return;
    for (out) |v| R.ring_list_adddouble(lst, v);
    R.ring_vm_api_retlist(p, lst);
}

fn ring_FrameCorrMatrix(p: *anyopaque) callconv(.c) void {
    const flat = listToF64(p, 1) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(flat);
    const nr: usize = @intFromFloat(g(p, 2));
    const nc: usize = @intFromFloat(g(p, 3));
    if (nr == 0 or nc == 0) {
        rn(p, 0);
        return;
    }
    const out = allocator.alloc(f64, nc * nc) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(out);
    frame_mod.correlationMatrix(allocator, flat, nr, nc, out) catch {
        rn(p, 0);
        return;
    };
    const lst = R.ring_vm_api_newlist(p) orelse return;
    for (out) |v| R.ring_list_adddouble(lst, v);
    R.ring_vm_api_retlist(p, lst);
}

fn ring_FrameRegression(p: *anyopaque) callconv(.c) void {
    const x = listToF64(p, 1) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(x);
    const y = listToF64(p, 2) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(y);
    var out = [_]f64{0} ** 3;
    const good = frame_mod.regression(x, y, &out) catch {
        rn(p, 0);
        return;
    };
    if (!good) {
        rn(p, 0);
        return;
    }
    const lst = R.ring_vm_api_newlist(p) orelse return;
    for (out) |v| R.ring_list_adddouble(lst, v);
    R.ring_vm_api_retlist(p, lst);
}

fn ring_KnnModelNew(p: *anyopaque) callconv(.c) void {
    const pts = listToF64(p, 1) orelse {
        rcp(p, null, H);
        return;
    };
    defer allocator.free(pts);
    const n: usize = @intFromFloat(g(p, 2));
    const d: usize = @intFromFloat(g(p, 3));
    const codesf = listToF64(p, 4) orelse {
        rcp(p, null, H);
        return;
    };
    defer allocator.free(codesf);
    const codes = allocator.alloc(u32, codesf.len) catch {
        rcp(p, null, H);
        return;
    };
    defer allocator.free(codes);
    for (codesf, 0..) |v, i| codes[i] = @intFromFloat(v);

    const n_labels: usize = @intFromFloat(g(p, 5));
    const approx = g(p, 6) != 0;
    const trees: usize = @intFromFloat(g(p, 7));
    const seed: u64 = @intFromFloat(g(p, 8));

    const m = knn_mod.modelNew(allocator, pts, n, d, codes, n_labels, approx, trees, seed) catch {
        rcp(p, null, H);
        return;
    };
    rcp(p, m, H);
}

fn ring_KnnModelFree(p: *anyopaque) callconv(.c) void {
    const raw = gcp(p, 1, H) orelse {
        rn(p, 0);
        return;
    };
    const m: *knn_mod.Model = @ptrCast(@alignCast(raw));
    m.deinit();
    rn(p, 1);
}

fn ring_KnnModelClassify(p: *anyopaque) callconv(.c) void {
    const raw = gcp(p, 1, H) orelse {
        rn(p, 0);
        return;
    };
    const m: *knn_mod.Model = @ptrCast(@alignCast(raw));
    const q = listToF64(p, 2) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(q);
    const k: usize = @intFromFloat(g(p, 3));
    const budget: usize = @intFromFloat(g(p, 4));
    if (k == 0 or q.len != m.d) {
        rn(p, 0);
        return;
    }
    const take = @min(k, m.n);

    const idx = allocator.alloc(u32, take) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(idx);
    const dst = allocator.alloc(f64, take) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(dst);
    const cod = allocator.alloc(u32, take) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(cod);

    const v = knn_mod.classify(m, allocator, q, take, budget, idx, dst, cod) catch {
        rn(p, 0);
        return;
    };

    const lst = R.ring_vm_api_newlist(p) orelse return;
    R.ring_list_adddouble(lst, @floatFromInt(v.code));
    R.ring_list_adddouble(lst, @floatFromInt(v.votes));
    R.ring_list_adddouble(lst, @floatFromInt(v.used));
    for (0..v.used) |t| {
        R.ring_list_adddouble(lst, @floatFromInt(idx[t]));
        R.ring_list_adddouble(lst, dst[t]);
        R.ring_list_adddouble(lst, @floatFromInt(cod[t]));
    }
    R.ring_vm_api_retlist(p, lst);
}

fn ring_KnnModelAgreement(p: *anyopaque) callconv(.c) void {
    const raw = gcp(p, 1, H) orelse {
        rn(p, 0);
        return;
    };
    const m: *knn_mod.Model = @ptrCast(@alignCast(raw));
    const qs = listToF64(p, 2) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(qs);
    const nq: usize = @intFromFloat(g(p, 3));
    const k: usize = @intFromFloat(g(p, 4));
    const budget: usize = @intFromFloat(g(p, 5));
    const r = knn_mod.agreementWithExact(m, allocator, qs, nq, k, budget) catch {
        rn(p, -1);
        return;
    };
    rn(p, r);
}

fn ring_AnnBuild(p: *anyopaque) callconv(.c) void {
    const pts = listToF64(p, 1) orelse {
        rcp(p, null, H);
        return;
    };
    defer allocator.free(pts);
    const n: usize = @intFromFloat(g(p, 2));
    const d: usize = @intFromFloat(g(p, 3));
    const trees: usize = @intFromFloat(g(p, 4));
    const cosine = g(p, 5) != 0;
    const seed: u64 = @intFromFloat(g(p, 6));
    const ix = ann_mod.build(allocator, pts, n, d, trees, cosine, seed) catch {
        rcp(p, null, H);
        return;
    };
    rcp(p, ix, H);
}

fn ring_AnnFree(p: *anyopaque) callconv(.c) void {
    const raw = gcp(p, 1, H) orelse {
        rn(p, 0);
        return;
    };
    const ix: *ann_mod.Index = @ptrCast(@alignCast(raw));
    ix.deinit();
    rn(p, 1);
}

fn ring_AnnCount(p: *anyopaque) callconv(.c) void {
    const raw = gcp(p, 1, H) orelse {
        rn(p, 0);
        return;
    };
    const ix: *ann_mod.Index = @ptrCast(@alignCast(raw));
    rn(p, @floatFromInt(ix.n));
}

fn ring_AnnDim(p: *anyopaque) callconv(.c) void {
    const raw = gcp(p, 1, H) orelse {
        rn(p, 0);
        return;
    };
    const ix: *ann_mod.Index = @ptrCast(@alignCast(raw));
    rn(p, @floatFromInt(ix.d));
}

fn annQuery(p: *anyopaque, exact: bool) void {
    const raw = gcp(p, 1, H) orelse {
        rn(p, 0);
        return;
    };
    const ix: *ann_mod.Index = @ptrCast(@alignCast(raw));
    const q = listToF64(p, 2) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(q);
    const k: usize = @intFromFloat(g(p, 3));
    if (k == 0 or q.len != ix.d) {
        rn(p, 0);
        return;
    }
    const take = @min(k, ix.n);
    const idx = allocator.alloc(u32, take) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(idx);
    const dst = allocator.alloc(f64, take) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(dst);

    const got = if (exact)
        ann_mod.searchExact(ix, allocator, q, take, idx, dst) catch {
            rn(p, 0);
            return;
        }
    else
        ann_mod.search(ix, allocator, q, take, @intFromFloat(g(p, 4)), idx, dst) catch {
            rn(p, 0);
            return;
        };

    const lst = R.ring_vm_api_newlist(p) orelse return;
    for (0..got) |i| {
        R.ring_list_adddouble(lst, @floatFromInt(idx[i]));
        R.ring_list_adddouble(lst, dst[i]);
    }
    R.ring_vm_api_retlist(p, lst);
}

fn ring_AnnSearch(p: *anyopaque) callconv(.c) void {
    annQuery(p, false);
}

fn ring_AnnSearchExact(p: *anyopaque) callconv(.c) void {
    annQuery(p, true);
}

fn ring_Fft(p: *anyopaque) callconv(.c) void {
    const re = listToF64(p, 1) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(re);
    const n = re.len;
    if (n == 0) {
        rn(p, 0);
        return;
    }

    const im = allocator.alloc(f64, n) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(im);
    @memset(im, 0);
    // an imaginary part is optional: a real signal passes []
    if (listToF64(p, 2)) |given| {
        defer allocator.free(given);
        if (given.len == n) @memcpy(im, given);
    }

    const inverse = g(p, 3) != 0;
    fft_mod.transform(allocator, re, im, inverse) catch {
        rn(p, 0);
        return;
    };

    const lst = R.ring_vm_api_newlist(p) orelse return;
    for (0..n) |k| {
        R.ring_list_adddouble(lst, re[k]);
        R.ring_list_adddouble(lst, im[k]);
    }
    R.ring_vm_api_retlist(p, lst);
}

//   StzEngineConvolveReal(aA, aB) -> the linear convolution, length na+nb-1
//
// Which is polynomial multiplication: the coefficients of a*b are the convolution
// of the coefficients of a and b.
fn ring_ConvolveReal(p: *anyopaque) callconv(.c) void {
    const a = listToF64(p, 1) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(a);
    const b = listToF64(p, 2) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(b);
    if (a.len == 0 or b.len == 0) {
        rn(p, 0);
        return;
    }

    const out = allocator.alloc(f64, a.len + b.len - 1) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(out);
    @memset(out, 0);
    fft_mod.convolveReal(allocator, a, b, out) catch {
        rn(p, 0);
        return;
    };

    const lst = R.ring_vm_api_newlist(p) orelse return;
    for (out) |v| R.ring_list_adddouble(lst, v);
    R.ring_vm_api_retlist(p, lst);
}

fn ring_EigenGeneral(p: *anyopaque) callconv(.c) void {
    const flat = listToF64(p, 1) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(flat);
    const n: usize = @intFromFloat(g(p, 2));
    if (n == 0 or flat.len != n * n) {
        rn(p, 0);
        return;
    }

    const out = allocator.alloc(cmplx.Complex, n) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(out);

    // the routine CONSUMES its input, which is fine: `flat` is this bridge's own
    // copy of the Ring list, not the caller's matrix
    eigen_general.eigenvalues(flat, n, out) catch {
        rn(p, 0);
        return;
    };

    const lst = R.ring_vm_api_newlist(p) orelse return;
    for (out) |z| {
        R.ring_list_adddouble(lst, z.re);
        R.ring_list_adddouble(lst, z.im);
    }
    R.ring_vm_api_retlist(p, lst);
}

//   StzEngineEigenSystem(aFlatRowMajor, n)
//     -> [ independentCount,
//          re,im per eigenvalue (2n),
//          re,im per vector entry, COLUMN j being the vector for eigenvalue j (2n*n) ]
//     or 0 if the iteration gave up
//
// independentCount comes first because it is the thing a caller must check before
// trusting the rest: a DEFECTIVE matrix has fewer eigenvectors than eigenvalues, and
// back-substitution returns a near-duplicate rather than admitting it.
fn ring_EigenSystem(p: *anyopaque) callconv(.c) void {
    const flat = listToF64(p, 1) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(flat);
    const n: usize = @intFromFloat(g(p, 2));
    if (n == 0 or flat.len != n * n) {
        rn(p, 0);
        return;
    }

    const vals = allocator.alloc(cmplx.Complex, n) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(vals);
    const vecs = allocator.alloc(cmplx.Complex, n * n) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(vecs);

    eigen_general.eigensystem(allocator, flat, n, vals, vecs) catch {
        rn(p, 0);
        return;
    };
    const rank = eigen_general.independentCount(allocator, vecs, n) catch {
        rn(p, 0);
        return;
    };

    const lst = R.ring_vm_api_newlist(p) orelse return;
    R.ring_list_adddouble(lst, @floatFromInt(rank));
    for (vals) |z| {
        R.ring_list_adddouble(lst, z.re);
        R.ring_list_adddouble(lst, z.im);
    }
    for (vecs) |z| {
        R.ring_list_adddouble(lst, z.re);
        R.ring_list_adddouble(lst, z.im);
    }
    R.ring_vm_api_retlist(p, lst);
}

// ─── PCA (on the SVD) ────────────────────────────────────────────────────────
//
//   StzEnginePcaFit(aX, nRows, nCols, bStandardize, bSample)
//     -> [ k, totalVariance,
//          means (p), scales (p), loadings (p*k), singularValues (k),
//          variance (k), scores (n*k) ]
//     or 0 on a refusal
//
//   StzEnginePcaTransform(aRows, m, p, k, aMeans, aScales, aLoadings) -> m*k scores
//
// Transform is STATELESS -- the model crosses with the call rather than living
// behind a handle. The model is p*(k+2) numbers against m*p for the data, so the
// crossing is dominated by the rows either way, and a stateless call has no
// lifetime to get wrong.
fn ring_PcaFit(p: *anyopaque) callconv(.c) void {
    const x = listToF64(p, 1) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(x);
    const n: usize = @intFromFloat(g(p, 2));
    const cols: usize = @intFromFloat(g(p, 3));
    const standardize = g(p, 4) != 0;
    const sample = g(p, 5) != 0;

    if (n == 0 or cols == 0 or x.len != n * cols) {
        rn(p, 0);
        return;
    }

    var model = pca_mod.fit(
        allocator,
        x,
        n,
        cols,
        standardize,
        if (sample) .sample else .population,
    ) catch {
        rn(p, 0);
        return;
    };
    defer model.deinit();

    const out = R.ring_vm_api_newlist(p) orelse return;
    R.ring_list_adddouble(out, @floatFromInt(model.k));
    R.ring_list_adddouble(out, model.total_variance);
    for (model.means) |v| R.ring_list_adddouble(out, v);
    for (model.scales) |v| R.ring_list_adddouble(out, v);
    for (model.loadings) |v| R.ring_list_adddouble(out, v);
    for (model.values) |v| R.ring_list_adddouble(out, v);
    for (model.variance) |v| R.ring_list_adddouble(out, v);
    for (model.scores) |v| R.ring_list_adddouble(out, v);
    R.ring_vm_api_retlist(p, out);
}

// ─── PCA INVERSE ─────────────────────────────────────────────────────────────
//
//   StzEnginePcaInverse(aScores, m, nCols, k, aMeans, aScales, aLoadings) -> m*nCols
//
// The transpose of the projection. Unlike the embedding decoders this needs no model
// and no training -- the forward map is a rotation, so undoing it is arithmetic that
// was already in the fit.
fn ring_PcaInverse(p: *anyopaque) callconv(.c) void {
    const sc = listToF64(p, 1) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(sc);
    const m: usize = @intFromFloat(g(p, 2));
    const cols: usize = @intFromFloat(g(p, 3));
    const k: usize = @intFromFloat(g(p, 4));
    const means = listToF64(p, 5) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(means);
    const scales = listToF64(p, 6) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(scales);
    const load = listToF64(p, 7) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(load);

    if (m == 0 or cols == 0 or k == 0 or sc.len != m * k or
        means.len != cols or scales.len != cols or load.len != cols * k)
    {
        rn(p, 0);
        return;
    }

    const out_c = allocator.alloc(f64, m * cols) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(out_c);

    for (0..m) |i| {
        for (0..cols) |t| {
            var acc: f64 = 0;
            for (0..k) |j| acc += sc[i * k + j] * load[t * k + j];
            out_c[i * cols + t] = acc * scales[t] + means[t];
        }
    }

    const out = R.ring_vm_api_newlist(p) orelse return;
    for (out_c) |v| R.ring_list_adddouble(out, v);
    R.ring_vm_api_retlist(p, out);
}

fn ring_PcaTransform(p: *anyopaque) callconv(.c) void {
    const rows = listToF64(p, 1) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(rows);
    const m: usize = @intFromFloat(g(p, 2));
    const cols: usize = @intFromFloat(g(p, 3));
    const k: usize = @intFromFloat(g(p, 4));
    const means = listToF64(p, 5) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(means);
    const scales = listToF64(p, 6) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(scales);
    const loadings = listToF64(p, 7) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(loadings);

    if (m == 0 or cols == 0 or k == 0 or rows.len != m * cols or
        means.len != cols or scales.len != cols or loadings.len != cols * k)
    {
        rn(p, 0);
        return;
    }

    const out_scores = allocator.alloc(f64, m * k) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(out_scores);

    // a Pca just wide enough for transform(); the fields it does not read are empty
    const stub = pca_mod.Pca{
        .means = means,
        .scales = scales,
        .loadings = loadings,
        .values = &[_]f64{},
        .variance = &[_]f64{},
        .total_variance = 0,
        .scores = &[_]f64{},
        .n = 0,
        .p = cols,
        .k = k,
        .allocator = allocator,
    };
    pca_mod.transform(&stub, rows, m, out_scores);

    const out = R.ring_vm_api_newlist(p) orelse return;
    for (out_scores) |v| R.ring_list_adddouble(out, v);
    R.ring_vm_api_retlist(p, out);
}

// ─── t-SNE and UMAP (on top of PCA) ──────────────────────────────────────────
//
//   StzEngineTsne(aX, n, d, nPerplexity, nDims, nIterations, nSeed,
//                 nDensityLambda, nDensityFrac)
//     -- when nDensityLambda > 0 the result gains a trailing
//        [ densityCorrelation, localRadii (n) ]
//     -> [ dims, iterations, kl (iterations), embedding (n*dims) ]
//   StzEngineUmap(aX, n, d, nNeighbors, nDims, nMinDist, nSpread, nEpochs, nSeed,
//                 aLabels, nTargetWeight, nDensityLambda, nDensityFrac)
//     -> [ dims, a, b, embedding (n*dims) ]  -- and when nDensityLambda > 0,
//        followed by [ densityCorrelation, localRadii (n) ]
//   aLabels is empty for the ordinary fit, or one integer per point (-1 = unknown)
//   nDensityLambda is 0 for ordinary UMAP; > 0 turns on densMAP density preservation
//
// The KL history comes back in full rather than as a final number: an embedding is
// stochastic and its objective is the only evidence that the optimisation actually
// went anywhere, so a caller should be able to look.
fn ring_Tsne(p: *anyopaque) callconv(.c) void {
    const x = listToF64(p, 1) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(x);
    const n: usize = @intFromFloat(g(p, 2));
    const d: usize = @intFromFloat(g(p, 3));
    const perp = g(p, 4);
    const dims: usize = @intFromFloat(g(p, 5));
    const iters: usize = @intFromFloat(g(p, 6));
    const seed: u64 = @intFromFloat(g(p, 7));

    if (n == 0 or d == 0 or x.len != n * d or dims == 0) {
        rn(p, 0);
        return;
    }

    // DENSITY PRESERVATION (den-SNE). 0 leaves t-SNE untouched.
    const dens_lambda = g(p, 8);
    const dens_frac = g(p, 9);

    var r = tsne_mod.run(allocator, x, n, d, .{
        .perplexity = perp,
        .dims = dims,
        .iterations = if (iters == 0) 1000 else iters,
        .seed = seed,
        .density_lambda = if (dens_lambda < 0) 0 else dens_lambda,
        .density_frac = if (dens_frac <= 0 or dens_frac > 1) 0.3 else dens_frac,
    }) catch {
        rn(p, 0);
        return;
    };
    defer r.deinit();

    const out = R.ring_vm_api_newlist(p) orelse return;
    R.ring_list_adddouble(out, @floatFromInt(r.dims));
    R.ring_list_adddouble(out, @floatFromInt(r.kl.len));
    for (r.kl) |v| R.ring_list_adddouble(out, v);
    for (r.embedding) |v| R.ring_list_adddouble(out, v);
    // APPENDED, so a caller slicing the earlier fields is unaffected. Its ABSENCE is
    // the signal that density was never asked for -- not a failure.
    if (r.local_radii.len > 0) {
        R.ring_list_adddouble(out, r.density_correlation);
        for (r.local_radii) |v| R.ring_list_adddouble(out, v);
        // the density LINE, so the transform can place a new point under the same
        // contract the training rows obey
        R.ring_list_adddouble(out, r.density_slope);
        R.ring_list_adddouble(out, r.density_intercept);
    }
    R.ring_vm_api_retlist(p, out);
}

fn ring_Umap(p: *anyopaque) callconv(.c) void {
    const x = listToF64(p, 1) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(x);
    const n: usize = @intFromFloat(g(p, 2));
    const d: usize = @intFromFloat(g(p, 3));
    const nb: usize = @intFromFloat(g(p, 4));
    const dims: usize = @intFromFloat(g(p, 5));
    const min_dist = g(p, 6);
    const spread = g(p, 7);
    const epochs: usize = @intFromFloat(g(p, 8));
    const seed: u64 = @intFromFloat(g(p, 9));

    if (n == 0 or d == 0 or x.len != n * d or dims == 0) {
        rn(p, 0);
        return;
    }

    // LABELS, when there are any. An empty list means unsupervised; a label of -1
    // means "unknown for this point", which is what makes the semi-supervised case
    // work rather than forcing every row to be classified.
    const lv = listToF64(p, 10);
    defer if (lv) |l| allocator.free(l);
    const target_weight = g(p, 11);

    var labels: ?[]i32 = null;
    var labels_buf: ?[]i32 = null;
    defer if (labels_buf) |lb| allocator.free(lb);
    if (lv) |l| {
        if (l.len != n) {
            rn(p, 0);
            return;
        }
        const lb = allocator.alloc(i32, n) catch {
            rn(p, 0);
            return;
        };
        for (l, 0..) |v, i| lb[i] = @intFromFloat(v);
        labels_buf = lb;
        labels = lb;
    }

    // DENSITY PRESERVATION (densMAP). 0 leaves the algorithm untouched.
    const dens_lambda = g(p, 12);
    const dens_frac = g(p, 13);

    var r = umap_mod.runSupervised(allocator, x, n, d, labels, .{
        .n_neighbors = nb,
        .dims = dims,
        .min_dist = min_dist,
        .spread = if (spread <= 0) 1.0 else spread,
        .epochs = if (epochs == 0) 200 else epochs,
        .seed = seed,
        .target_weight = if (target_weight < 0) 0.5 else target_weight,
        .density_lambda = if (dens_lambda < 0) 0 else dens_lambda,
        .density_frac = if (dens_frac <= 0 or dens_frac > 1) 0.3 else dens_frac,
    }) catch {
        rn(p, 0);
        return;
    };
    defer r.deinit();

    const out = R.ring_vm_api_newlist(p) orelse return;
    R.ring_list_adddouble(out, @floatFromInt(r.dims));
    R.ring_list_adddouble(out, r.a);
    R.ring_list_adddouble(out, r.b);
    for (r.embedding) |v| R.ring_list_adddouble(out, v);
    // APPENDED, so a caller that slices the first 3 + n*dims entries is unaffected.
    // The correlation is NaN when density was never asked for, and NaN does not
    // survive the bridge meaningfully -- 0 with an empty radius list is the signal.
    if (r.local_radii.len > 0) {
        R.ring_list_adddouble(out, r.density_correlation);
        for (r.local_radii) |v| R.ring_list_adddouble(out, v);
        // the fit's density LINE, so Transform() can place new points under the same
        // contract instead of wherever their neighbours happen to sit
        R.ring_list_adddouble(out, r.density_slope);
        R.ring_list_adddouble(out, r.density_intercept);
    }
    R.ring_vm_api_retlist(p, out);
}

//   StzEngineUmapTransform(aTrainX, n, d, aTrainY, dims, aNewX, m, k, a, b,
//                          nDensSlope, nDensIntercept, bDensOn)
//     -> [ embedding (m*dims), localRadii (m) ]  -- the radii always, the density
//        placement only when bDensOn
//                          nEpochs, nSeed) -> m*dims coordinates
//
// Places points the fit never saw into an existing layout. Stateless, like the PCA
// transform: the model crosses with the call rather than living behind a handle.
fn ring_UmapTransform(p: *anyopaque) callconv(.c) void {
    const tx = listToF64(p, 1) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(tx);
    const n: usize = @intFromFloat(g(p, 2));
    const d: usize = @intFromFloat(g(p, 3));
    const ty = listToF64(p, 4) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(ty);
    const dims: usize = @intFromFloat(g(p, 5));
    const nx = listToF64(p, 6) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(nx);
    const m: usize = @intFromFloat(g(p, 7));
    const k: usize = @intFromFloat(g(p, 8));
    const a = g(p, 9);
    const b = g(p, 10);
    const epochs: usize = @intFromFloat(g(p, 11));
    const seed: u64 = @intFromFloat(g(p, 12));

    if (n == 0 or d == 0 or m == 0 or dims == 0 or
        tx.len != n * d or ty.len != n * dims or nx.len != m * d)
    {
        rn(p, 0);
        return;
    }

    const out_c = allocator.alloc(f64, m * dims) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(out_c);

    // THE FIT'S DENSITY LINE. Absent (slope 0, flag 0) for an ordinary fit, in which
    // case the transform behaves exactly as it always did.
    const dens_slope = g(p, 13);
    const dens_intercept = g(p, 14);
    const dens_on = g(p, 15) > 0;

    const radii = allocator.alloc(f64, m) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(radii);

    umap_mod.transformWithDensity(allocator, tx, ty, n, d, dims, nx, m, k, a, b, epochs, seed, out_c, dens_slope, dens_intercept, dens_on, radii) catch {
        rn(p, 0);
        return;
    };

    const out = R.ring_vm_api_newlist(p) orelse return;
    for (out_c) |v| R.ring_list_adddouble(out, v);
    // the new rows' ORIGINAL-space radii, always -- they are a property of the data
    // rather than of the placement, and cost nothing since the transform computes them
    for (radii) |v| R.ring_list_adddouble(out, v);
    R.ring_vm_api_retlist(p, out);
}



// ─── CLASSIC t-SNE: PLACING A POINT THE FIT NEVER SAW ────────────────────────
//
//   StzEngineTsneTransform(aTrainX, n, d, aTrainY, dims, aNewX, m, nPerplexity,
//                          nIterations, nLearningRate,
//                          nDensSlope, nDensIntercept, bDensOn)
//     -> [ embedding (m*dims), localRadii (m) ]
//
// t-SNE as published has no transform. This is a CONSTRUCTED extension -- the training
// map frozen, the same KL minimised over one position -- and it is approximate, like
// UMAP's and unlike the parametric variant's. See tsne.transform for what that means.
fn ring_TsneTransform(p: *anyopaque) callconv(.c) void {
    const tx = listToF64(p, 1) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(tx);
    const n: usize = @intFromFloat(g(p, 2));
    const d: usize = @intFromFloat(g(p, 3));
    const ty = listToF64(p, 4) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(ty);
    const dims: usize = @intFromFloat(g(p, 5));
    const nx = listToF64(p, 6) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(nx);
    const m: usize = @intFromFloat(g(p, 7));
    const perp = g(p, 8);
    const iters: usize = @intFromFloat(g(p, 9));
    const lr = g(p, 10);
    const dens_slope = g(p, 11);
    const dens_intercept = g(p, 12);
    const dens_on = g(p, 13) > 0;

    if (n == 0 or d == 0 or m == 0 or dims == 0 or tx.len != n * d or
        ty.len != n * dims or nx.len != m * d)
    {
        rn(p, 0);
        return;
    }

    const out_c = allocator.alloc(f64, m * dims) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(out_c);
    const radii = allocator.alloc(f64, m) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(radii);

    tsne_mod.transform(allocator, tx, ty, n, d, dims, nx, m, perp, iters, lr, out_c, dens_slope, dens_intercept, dens_on, radii) catch {
        rn(p, 0);
        return;
    };

    const out = R.ring_vm_api_newlist(p) orelse return;
    for (out_c) |v| R.ring_list_adddouble(out, v);
    for (radii) |v| R.ring_list_adddouble(out, v);
    R.ring_vm_api_retlist(p, out);
}


// ─── PARAMETRIC UMAP (Sainburg/McInnes/Gentner 2021) ─────────────────────────
//
//   StzEnginePumap(aX, n, d, aHidden, nNeighbors, nDims, nMinDist, nSpread,
//                  nEpochs, nLR, nSeed, aLabels, nTargetWeight,
//                  nDensityLambda, nDensityFrac)
//     -> [ dims, a, b, shapeLen, weightLen,
//          shape, weights, embedding (n*dims) ]
//        and when nDensityLambda > 0, a trailing [ corr, localRadii (n) ]
//
// The weights come back to Ring so Transform is stateless, exactly as for parametric
// t-SNE -- and it IS the parametric t-SNE transform, unchanged, because a forward pass
// does not care which objective trained the weights.
fn ring_Pumap(p: *anyopaque) callconv(.c) void {
    const x = listToF64(p, 1) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(x);
    const n: usize = @intFromFloat(g(p, 2));
    const d: usize = @intFromFloat(g(p, 3));
    const hv = listToF64(p, 4) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(hv);
    const nb: usize = @intFromFloat(g(p, 5));
    const dims: usize = @intFromFloat(g(p, 6));
    const min_dist = g(p, 7);
    const spread = g(p, 8);
    const epochs: usize = @intFromFloat(g(p, 9));
    const lr = g(p, 10);
    const seed: u64 = @intFromFloat(g(p, 11));
    const lv = listToF64(p, 12);
    defer if (lv) |l| allocator.free(l);
    const target_weight = g(p, 13);
    const dens_lambda = g(p, 14);
    const dens_frac = g(p, 15);

    if (n == 0 or d == 0 or x.len != n * d or dims == 0 or hv.len == 0) {
        rn(p, 0);
        return;
    }

    const hidden = allocator.alloc(usize, hv.len) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(hidden);
    for (hv, 0..) |v, i| hidden[i] = @intFromFloat(v);

    var labels: ?[]i32 = null;
    var labels_buf: ?[]i32 = null;
    defer if (labels_buf) |lb| allocator.free(lb);
    if (lv) |l| {
        if (l.len != n) {
            rn(p, 0);
            return;
        }
        const lb = allocator.alloc(i32, n) catch {
            rn(p, 0);
            return;
        };
        for (l, 0..) |v, i| lb[i] = @intFromFloat(v);
        labels_buf = lb;
        labels = lb;
    }

    var r = pumap_mod.run(allocator, x, n, d, hidden, labels, .{
        .n_neighbors = nb,
        .dims = dims,
        .min_dist = min_dist,
        .spread = if (spread <= 0) 1.0 else spread,
        .epochs = if (epochs == 0) 400 else epochs,
        .learning_rate = if (lr <= 0) 0.01 else lr,
        .seed = seed,
        .target_weight = if (target_weight < 0) 0.5 else target_weight,
        .density_lambda = if (dens_lambda < 0) 0 else dens_lambda,
        .density_frac = if (dens_frac <= 0 or dens_frac > 1) 0.3 else dens_frac,
    }) catch {
        rn(p, 0);
        return;
    };
    defer r.deinit();

    const out = R.ring_vm_api_newlist(p) orelse return;
    R.ring_list_adddouble(out, @floatFromInt(r.dims));
    R.ring_list_adddouble(out, r.a);
    R.ring_list_adddouble(out, r.b);
    R.ring_list_adddouble(out, @floatFromInt(r.shape.len));
    R.ring_list_adddouble(out, @floatFromInt(r.weights.len));
    for (r.shape) |v| R.ring_list_adddouble(out, v);
    for (r.weights) |v| R.ring_list_adddouble(out, v);
    for (r.embedding) |v| R.ring_list_adddouble(out, v);
    if (r.local_radii.len > 0) {
        R.ring_list_adddouble(out, r.density_correlation);
        for (r.local_radii) |v| R.ring_list_adddouble(out, v);
    }
    R.ring_vm_api_retlist(p, out);
}


// ─── INVERSE TRANSFORM: a decoder from the picture back to the data ──────────
//
// Named for the embedding rather than for UMAP, because it regresses (position, row)
// pairs and has no idea what produced the positions -- t-SNE uses it unchanged.
//
//   StzEngineEmbeddingDecoder(aEmbedding, aX, n, nDims, d, aHidden, nLR, nEpochs, nSeed)
//     -> [ shapeLen, weightLen, lossLen, shape, weights, loss ]
//
// The inverse itself is StzEnginePtsneTransform with these weights: a forward pass
// does not care which direction it is running.
fn ring_EmbeddingDecoder(p: *anyopaque) callconv(.c) void {
    const y = listToF64(p, 1) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(y);
    const x = listToF64(p, 2) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(x);
    const n: usize = @intFromFloat(g(p, 3));
    const dims: usize = @intFromFloat(g(p, 4));
    const d: usize = @intFromFloat(g(p, 5));
    const hv = listToF64(p, 6) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(hv);
    const lr = g(p, 7);
    const epochs: usize = @intFromFloat(g(p, 8));
    const seed: u64 = @intFromFloat(g(p, 9));

    if (n < 2 or dims == 0 or d == 0 or hv.len == 0 or epochs == 0 or
        y.len != n * dims or x.len != n * d)
    {
        rn(p, 0);
        return;
    }

    const hidden = allocator.alloc(usize, hv.len) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(hidden);
    for (hv, 0..) |v, i| hidden[i] = @intFromFloat(v);

    var dec = decoder_mod.trainDecoder(allocator, y, x, n, dims, d, hidden, if (lr <= 0) 0.02 else lr, epochs, seed) catch {
        rn(p, 0);
        return;
    };
    defer dec.deinit();

    const out = R.ring_vm_api_newlist(p) orelse return;
    R.ring_list_adddouble(out, @floatFromInt(dec.shape.len));
    R.ring_list_adddouble(out, @floatFromInt(dec.weights.len));
    R.ring_list_adddouble(out, @floatFromInt(dec.loss.len));
    for (dec.shape) |v| R.ring_list_adddouble(out, v);
    for (dec.weights) |v| R.ring_list_adddouble(out, v);
    for (dec.loss) |v| R.ring_list_adddouble(out, v);
    R.ring_vm_api_retlist(p, out);
}

// ─── LOCAL RADII OF UNSEEN ROWS ──────────────────────────────────────────────
//
//   StzEngineLocalRadiiOfNew(aTrainX, n, d, aNewX, m, k) -> m radii
//
// Measured against the TRAINING DATA, never against a model. It exists because the
// parametric transform saturates: a row ten times further out than anything the fit
// saw comes back as an ordinary-looking pair of coordinates. This cannot, because 356
// units from anything is 356 units from anything whatever a network believes.
fn ring_LocalRadiiOfNew(p: *anyopaque) callconv(.c) void {
    const tx = listToF64(p, 1) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(tx);
    const n: usize = @intFromFloat(g(p, 2));
    const d: usize = @intFromFloat(g(p, 3));
    const nx = listToF64(p, 4) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(nx);
    const m: usize = @intFromFloat(g(p, 5));
    const k: usize = @intFromFloat(g(p, 6));

    if (n == 0 or d == 0 or m == 0 or k == 0 or k > n or tx.len != n * d or nx.len != m * d) {
        rn(p, 0);
        return;
    }

    const radii = allocator.alloc(f64, m) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(radii);
    umap_mod.localRadiiOfNew(allocator, tx, n, d, nx, m, k, radii) catch {
        rn(p, 0);
        return;
    };

    const out = R.ring_vm_api_newlist(p) orelse return;
    for (radii) |v| R.ring_list_adddouble(out, v);
    R.ring_vm_api_retlist(p, out);
}

// ─── PARAMETRIC t-SNE (van der Maaten 2009) ──────────────────────────────────
//
//   StzEnginePtsne(aX, n, d, aHidden, nPerp, nDims, nEpochs, nLR, nSeed,
//                  nDensityLambda, nDensityFrac)
//     -- when nDensityLambda > 0 the result gains a trailing
//        [ densityCorrelation, localRadii (n) ]
//     -> [ dims, nEpochs, shapeLen, weightLen,
//          kl (nEpochs), shape (shapeLen), weights (weightLen),
//          embedding (n*dims) ]
//   StzEnginePtsneTransform(aShape, aWeights, aX, m, nDims) -> m*dims
//
// The weights and shape come BACK to Ring so that Transform is stateless, like the
// PCA and UMAP transforms: the trained map crosses with the call rather than living
// behind a handle whose lifetime somebody has to get right.
fn ring_Ptsne(p: *anyopaque) callconv(.c) void {
    const x = listToF64(p, 1) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(x);
    const n: usize = @intFromFloat(g(p, 2));
    const d: usize = @intFromFloat(g(p, 3));
    const hv = listToF64(p, 4) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(hv);
    const perp = g(p, 5);
    const dims: usize = @intFromFloat(g(p, 6));
    const epochs: usize = @intFromFloat(g(p, 7));
    const lr = g(p, 8);
    const seed: u64 = @intFromFloat(g(p, 9));

    if (n == 0 or d == 0 or x.len != n * d or dims == 0 or hv.len == 0) {
        rn(p, 0);
        return;
    }

    const hidden = allocator.alloc(usize, hv.len) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(hidden);
    for (hv, 0..) |v, i| {
        if (v < 1) {
            rn(p, 0);
            return;
        }
        hidden[i] = @intFromFloat(v);
    }

    // DENSITY PRESERVATION (parametric den-SNE). 0 leaves the algorithm untouched.
    const dens_lambda = g(p, 10);
    const dens_frac = g(p, 11);

    var r = ptsne_mod.run(allocator, x, n, d, hidden, .{
        .perplexity = perp,
        .dims = dims,
        .epochs = if (epochs == 0) 400 else epochs,
        .learning_rate = if (lr <= 0) 0.01 else lr,
        .seed = seed,
        .density_lambda = if (dens_lambda < 0) 0 else dens_lambda,
        .density_frac = if (dens_frac <= 0 or dens_frac > 1) 0.3 else dens_frac,
    }) catch {
        rn(p, 0);
        return;
    };
    defer r.deinit();

    const out = R.ring_vm_api_newlist(p) orelse return;
    R.ring_list_adddouble(out, @floatFromInt(r.dims));
    R.ring_list_adddouble(out, @floatFromInt(r.kl.len));
    R.ring_list_adddouble(out, @floatFromInt(r.shape.len));
    R.ring_list_adddouble(out, @floatFromInt(r.weights.len));
    for (r.kl) |v| R.ring_list_adddouble(out, v);
    for (r.shape) |v| R.ring_list_adddouble(out, v);
    for (r.weights) |v| R.ring_list_adddouble(out, v);
    for (r.embedding) |v| R.ring_list_adddouble(out, v);
    // APPENDED, and only when density was asked for -- its absence is the signal that
    // this was an ordinary parametric fit rather than a failed one
    if (r.local_radii.len > 0) {
        R.ring_list_adddouble(out, r.density_correlation);
        for (r.local_radii) |v| R.ring_list_adddouble(out, v);
    }
    R.ring_vm_api_retlist(p, out);
}

fn ring_PtsneTransform(p: *anyopaque) callconv(.c) void {
    const shape = listToF64(p, 1) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(shape);
    const weights = listToF64(p, 2) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(weights);
    const x = listToF64(p, 3) orelse {
        rn(p, 0);
        return;
    };
    defer allocator.free(x);
    const m: usize = @intFromFloat(g(p, 4));
    const dims: usize = @intFromFloat(g(p, 5));

    if (shape.len < 4 or m == 0 or dims == 0) {
        rn(p, 0);
        return;
    }
    const out_c = allocator.alloc(f64, m * dims) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(out_c);

    ptsne_mod.transform(allocator, shape, weights, x, m, out_c) catch {
        rn(p, 0);
        return;
    };

    const out = R.ring_vm_api_newlist(p) orelse return;
    for (out_c) |v| R.ring_list_adddouble(out, v);
    R.ring_vm_api_retlist(p, out);
}

pub const regs = [_]R.Reg{
    .{ .name = "stzenginetreeid3", .func = &ring_TreeId3 },
    .{ .name = "stzengineaprioricount", .func = &ring_AprioriCount },
    .{ .name = "stzenginegradcompile", .func = &ring_GradCompile },
    .{ .name = "stzengineminimize", .func = &ring_Minimize },
    .{ .name = "stzenginenntrain", .func = &ring_NNTrain },
    .{ .name = "stzengineeigengeneral", .func = &ring_EigenGeneral },
    .{ .name = "stzenginefftmagnitudes", .func = &ring_FftMagnitudes },
    .{ .name = "stzenginefftphases", .func = &ring_FftPhases },
    .{ .name = "stzenginefftpower", .func = &ring_FftPower },
    .{ .name = "stzenginefftdominantbin", .func = &ring_FftDominantBin },
    .{ .name = "stzengineannrecall", .func = &ring_AnnRecall },
    .{ .name = "stzenginepolyroots", .func = &ring_PolyRoots },
    .{ .name = "stzenginepolycompanion", .func = &ring_PolyCompanion },
    .{ .name = "stzengineplotbar", .func = &ring_PlotBar },
    .{ .name = "stzengineplothbar", .func = &ring_PlotHBar },
    .{ .name = "stzengineplotsurface", .func = &ring_PlotSurface },
    .{ .name = "stzengineplotscatter", .func = &ring_PlotScatter },
    .{ .name = "stzengineplotmbar", .func = &ring_PlotMBar },
    .{ .name = "stzengineplothistogram", .func = &ring_PlotHistogram },
    .{ .name = "stzenginebinvalues", .func = &ring_BinValues },
    .{ .name = "stzengineframedescribe", .func = &ring_FrameDescribe },
    .{ .name = "stzengineframedescribeall", .func = &ring_FrameDescribeAll },
    .{ .name = "stzengineframecorrmatrix", .func = &ring_FrameCorrMatrix },
    .{ .name = "stzengineframeregression", .func = &ring_FrameRegression },
    .{ .name = "stzengineknnmodelnew", .func = &ring_KnnModelNew },
    .{ .name = "stzengineknnmodelfree", .func = &ring_KnnModelFree },
    .{ .name = "stzengineknnmodelclassify", .func = &ring_KnnModelClassify },
    .{ .name = "stzengineknnmodelagreement", .func = &ring_KnnModelAgreement },
    .{ .name = "stzengineannbuild", .func = &ring_AnnBuild },
    .{ .name = "stzengineannfree", .func = &ring_AnnFree },
    .{ .name = "stzengineanncount", .func = &ring_AnnCount },
    .{ .name = "stzengineanndim", .func = &ring_AnnDim },
    .{ .name = "stzengineannsearch", .func = &ring_AnnSearch },
    .{ .name = "stzengineannsearchexact", .func = &ring_AnnSearchExact },
    .{ .name = "stzenginefft", .func = &ring_Fft },
    .{ .name = "stzengineconvolvereal", .func = &ring_ConvolveReal },
    .{ .name = "stzengineeigensystem", .func = &ring_EigenSystem },
    .{ .name = "stzenginepcafit", .func = &ring_PcaFit },
    .{ .name = "stzenginetsne", .func = &ring_Tsne },
    .{ .name = "stzengineptsne", .func = &ring_Ptsne },
    .{ .name = "stzengineptsnetransform", .func = &ring_PtsneTransform },
    .{ .name = "stzengineumap", .func = &ring_Umap },
    .{ .name = "stzengineumaptransform", .func = &ring_UmapTransform },
    .{ .name = "stzenginelocalradiiofnew", .func = &ring_LocalRadiiOfNew },
    .{ .name = "stzenginetsnetransform", .func = &ring_TsneTransform },
    .{ .name = "stzenginepumap", .func = &ring_Pumap },
    .{ .name = "stzengineembeddingdecoder", .func = &ring_EmbeddingDecoder },
    .{ .name = "stzenginepcatransform", .func = &ring_PcaTransform },
    .{ .name = "stzenginepcainverse", .func = &ring_PcaInverse },
    .{ .name = "stzenginegradwhy", .func = &ring_GradWhy },
    .{ .name = "stzenginegradfree", .func = &ring_GradFree },
    .{ .name = "stzenginegradat", .func = &ring_GradAt },
    .{ .name = "stzenginegradvalueat", .func = &ring_GradValueAt },
    .{ .name = "stzenginebayesnew", .func = &ring_BayesNew },
    .{ .name = "stzenginebayesfree", .func = &ring_BayesFree },
    .{ .name = "stzenginebayestrain", .func = &ring_BayesTrain },
    .{ .name = "stzenginebayesscores", .func = &ring_BayesScores },
    .{ .name = "stzenginebayeslabels", .func = &ring_BayesLabels },
    .{ .name = "stzenginebayesstats", .func = &ring_BayesStats },
    .{ .name = "stzengineknntopk", .func = &ring_KnnTopK },
    .{ .name = "stzengineclusterdatanew", .func = &ring_ClusterDataNew },
    .{ .name = "stzengineclusterdatafree", .func = &ring_ClusterDataFree },
    .{ .name = "stzengineknntopkon", .func = &ring_KnnTopKOn },
    .{ .name = "stzenginekmeansrun", .func = &ring_KMeansRun },
    .{ .name = "stzenginelogistictrain", .func = &ring_LogisticTrain },
    .{ .name = "stzenginelogisticpredict", .func = &ring_LogisticPredict },
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
    .{ .name = "stzengineerf", .func = &ring_Erf },
    .{ .name = "stzengineerfc", .func = &ring_Erfc },
    .{ .name = "stzenginelgamma", .func = &ring_LogGamma },
    .{ .name = "stzenginegammafn", .func = &ring_Gamma },
    .{ .name = "stzenginegammap", .func = &ring_GammaP },
    .{ .name = "stzenginegammaq", .func = &ring_GammaQ },
    .{ .name = "stzenginebetai", .func = &ring_BetaI },
    .{ .name = "stzenginenormalcdf", .func = &ring_NormalCdf },
    .{ .name = "stzenginenormalquantile", .func = &ring_NormalQuantile },
    .{ .name = "stzenginetcdf", .func = &ring_TCdf },
    .{ .name = "stzenginetquantile", .func = &ring_TQuantile },
    .{ .name = "stzenginechi2cdf", .func = &ring_Chi2Cdf },
    .{ .name = "stzenginechi2quantile", .func = &ring_Chi2Quantile },
    .{ .name = "stzenginefcdf", .func = &ring_FCdf },
    .{ .name = "stzenginefquantile", .func = &ring_FQuantile },
    .{ .name = "stzenginecriticalvalue", .func = &ring_CriticalValue },
    .{ .name = "stzenginetonesample", .func = &ring_TOneSample },
    .{ .name = "stzenginetwelch", .func = &ring_TWelch },
    .{ .name = "stzenginetstudent", .func = &ring_TStudent },
    .{ .name = "stzenginetpaired", .func = &ring_TPaired },
    .{ .name = "stzenginechi2gof", .func = &ring_Chi2Gof },
    .{ .name = "stzenginechi2independence", .func = &ring_Chi2Independence },
    .{ .name = "stzengineanova", .func = &ring_Anova },
    .{ .name = "stzenginecorrelationtest", .func = &ring_CorrelationTest },
    .{ .name = "stzenginesimplexrun", .func = &ring_SimplexRun },
    .{ .name = "stzengineoptimsolve", .func = &ring_OptimSolve },
};

pub fn ringlib_init(pRingState: ?*anyopaque) callconv(.c) void {
    if (pRingState) |state| R.registerAll(state, &regs);
}
