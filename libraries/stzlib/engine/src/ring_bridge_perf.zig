const perf = @import("perf.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const rn = R.ring_vm_api_retnumber;

const SERIES_HANDLE: [*:0]const u8 = "StzPerfSeries";

fn getSeries(p: *anyopaque, n: c_int) ?*perf.Series {
    const raw = R.ring_vm_api_getcpointer(p, n, SERIES_HANDLE) orelse return null;
    const addr = @intFromPtr(raw);
    if (addr == 0) return null;
    return @ptrFromInt(addr);
}

// ── senses ───────────────────────────────────────────────────

fn ring_PerfMemRss(p: *anyopaque) callconv(.c) void {
    rn(p, perf.stz_perf_mem_rss());
}

fn ring_PerfMemPeak(p: *anyopaque) callconv(.c) void {
    rn(p, perf.stz_perf_mem_peak());
}

fn ring_PerfSysMemTotal(p: *anyopaque) callconv(.c) void {
    rn(p, perf.stz_perf_sys_mem_total());
}

fn ring_PerfSysMemFree(p: *anyopaque) callconv(.c) void {
    rn(p, perf.stz_perf_sys_mem_free());
}

fn ring_PerfCpuNs(p: *anyopaque) callconv(.c) void {
    rn(p, perf.stz_perf_cpu_ns());
}

// ── series ───────────────────────────────────────────────────

fn ring_SeriesCreate(p: *anyopaque) callconv(.c) void {
    const handle = perf.perf_series_create(gn(p, 1));
    if (handle) |s| {
        R.ring_vm_api_retcpointer(p, @ptrCast(s), SERIES_HANDLE);
    } else {
        R.ring_vm_api_retcpointer(p, @ptrFromInt(0), SERIES_HANDLE);
    }
}

fn ring_SeriesRecord(p: *anyopaque) callconv(.c) void {
    perf.perf_series_record(getSeries(p, 1), gn(p, 2), gn(p, 3));
    rn(p, 0);
}

fn ring_SeriesCount(p: *anyopaque) callconv(.c) void {
    rn(p, perf.perf_series_count(getSeries(p, 1)));
}

fn ring_SeriesSize(p: *anyopaque) callconv(.c) void {
    rn(p, perf.perf_series_size(getSeries(p, 1)));
}

fn ring_SeriesTimeAt(p: *anyopaque) callconv(.c) void {
    rn(p, perf.perf_series_time_at(getSeries(p, 1), gn(p, 2)));
}

fn ring_SeriesValueAt(p: *anyopaque) callconv(.c) void {
    rn(p, perf.perf_series_value_at(getSeries(p, 1), gn(p, 2)));
}

fn ring_SeriesLast(p: *anyopaque) callconv(.c) void {
    rn(p, perf.perf_series_last(getSeries(p, 1)));
}

fn ring_SeriesMin(p: *anyopaque) callconv(.c) void {
    rn(p, perf.perf_series_min(getSeries(p, 1)));
}

fn ring_SeriesMax(p: *anyopaque) callconv(.c) void {
    rn(p, perf.perf_series_max(getSeries(p, 1)));
}

fn ring_SeriesMean(p: *anyopaque) callconv(.c) void {
    rn(p, perf.perf_series_mean(getSeries(p, 1)));
}

fn ring_SeriesSlopePerMs(p: *anyopaque) callconv(.c) void {
    rn(p, perf.perf_series_slope_per_ms(getSeries(p, 1)));
}

fn ring_SeriesPercentile(p: *anyopaque) callconv(.c) void {
    rn(p, perf.perf_series_percentile(getSeries(p, 1), gn(p, 2)));
}

fn ring_SeriesReset(p: *anyopaque) callconv(.c) void {
    perf.perf_series_reset(getSeries(p, 1));
    rn(p, 0);
}

fn ring_SeriesDestroy(p: *anyopaque) callconv(.c) void {
    perf.perf_series_destroy(getSeries(p, 1));
    rn(p, 0);
}

const regs = [_]R.Reg{
    .{ .name = "stzengineperfmemrss", .func = ring_PerfMemRss },
    .{ .name = "stzengineperfmempeak", .func = ring_PerfMemPeak },
    .{ .name = "stzengineperfsysmemtotal", .func = ring_PerfSysMemTotal },
    .{ .name = "stzengineperfsysmemfree", .func = ring_PerfSysMemFree },
    .{ .name = "stzengineperfcpuns", .func = ring_PerfCpuNs },
    .{ .name = "stzengineperfseriescreate", .func = ring_SeriesCreate },
    .{ .name = "stzengineperfseriesrecord", .func = ring_SeriesRecord },
    .{ .name = "stzengineperfseriescount", .func = ring_SeriesCount },
    .{ .name = "stzengineperfseriessize", .func = ring_SeriesSize },
    .{ .name = "stzengineperfseriestimeat", .func = ring_SeriesTimeAt },
    .{ .name = "stzengineperfseriesvalueat", .func = ring_SeriesValueAt },
    .{ .name = "stzengineperfserieslast", .func = ring_SeriesLast },
    .{ .name = "stzengineperfseriesmin", .func = ring_SeriesMin },
    .{ .name = "stzengineperfseriesmax", .func = ring_SeriesMax },
    .{ .name = "stzengineperfseriesmean", .func = ring_SeriesMean },
    .{ .name = "stzengineperfseriesslopeperms", .func = ring_SeriesSlopePerMs },
    .{ .name = "stzengineperfseriespercentile", .func = ring_SeriesPercentile },
    .{ .name = "stzengineperfseriesreset", .func = ring_SeriesReset },
    .{ .name = "stzengineperfseriesdestroy", .func = ring_SeriesDestroy },
};

pub fn registerAll(state: *anyopaque) void {
    R.registerAll(state, &regs);
}
