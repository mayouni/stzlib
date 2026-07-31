const perf = @import("perf.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const rn = R.ring_vm_api_retnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rs = R.ring_vm_api_retstring;
const rs2 = R.ring_vm_api_retstring2;

const SERIES_HANDLE: [*:0]const u8 = "StzPerfSeries";
const TRACE_HANDLE: [*:0]const u8 = "StzPerfTraceRing";
const FAMILY_HANDLE: [*:0]const u8 = "StzPerfFamily";
// family children carry the EXISTING tags so the established wrappers
// (stzPerfSeries / stzLatencyHistogram) operate on them unchanged
const HIST_HANDLE: [*:0]const u8 = "StzHistogram";

var str_buf: [128]u8 = undefined;

fn getTrace(p: *anyopaque, n: c_int) ?*perf.TraceRing {
    const raw = R.ring_vm_api_getcpointer(p, n, TRACE_HANDLE) orelse return null;
    const addr = @intFromPtr(raw);
    if (addr == 0) return null;
    return @ptrFromInt(addr);
}

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

// ── trace ring ───────────────────────────────────────────────

fn ring_TraceCreate(p: *anyopaque) callconv(.c) void {
    const handle = perf.perf_trace_create(gn(p, 1));
    if (handle) |t| {
        R.ring_vm_api_retcpointer(p, @ptrCast(t), TRACE_HANDLE);
    } else {
        R.ring_vm_api_retcpointer(p, @ptrFromInt(0), TRACE_HANDLE);
    }
}

fn ring_TraceRecord(p: *anyopaque) callconv(.c) void {
    const id: [*]const u8 = @ptrCast(gs(p, 2));
    const il: usize = @intCast(gss(p, 2));
    const path: [*]const u8 = @ptrCast(gs(p, 3));
    const pl: usize = @intCast(gss(p, 3));
    perf.perf_trace_record(getTrace(p, 1), id, il, path, pl, gn(p, 4), gn(p, 5), gn(p, 6));
    rn(p, 0);
}

fn ring_TraceCount(p: *anyopaque) callconv(.c) void {
    rn(p, perf.perf_trace_count(getTrace(p, 1)));
}

fn ring_TraceSize(p: *anyopaque) callconv(.c) void {
    rn(p, perf.perf_trace_size(getTrace(p, 1)));
}

fn ring_TraceIdAt(p: *anyopaque) callconv(.c) void {
    const n = perf.perf_trace_id_at(getTrace(p, 1), gn(p, 2), &str_buf, str_buf.len);
    if (n > 0) rs2(p, &str_buf, @intCast(n)) else rs(p, @constCast(""));
}

fn ring_TracePathAt(p: *anyopaque) callconv(.c) void {
    const n = perf.perf_trace_path_at(getTrace(p, 1), gn(p, 2), &str_buf, str_buf.len);
    if (n > 0) rs2(p, &str_buf, @intCast(n)) else rs(p, @constCast(""));
}

fn ring_TraceStatusAt(p: *anyopaque) callconv(.c) void {
    rn(p, perf.perf_trace_status_at(getTrace(p, 1), gn(p, 2)));
}

fn ring_TraceDurAt(p: *anyopaque) callconv(.c) void {
    rn(p, perf.perf_trace_dur_at(getTrace(p, 1), gn(p, 2)));
}

fn ring_TraceWallAt(p: *anyopaque) callconv(.c) void {
    rn(p, perf.perf_trace_wall_at(getTrace(p, 1), gn(p, 2)));
}

fn ring_TraceReset(p: *anyopaque) callconv(.c) void {
    perf.perf_trace_reset(getTrace(p, 1));
    rn(p, 0);
}

fn ring_TraceDestroy(p: *anyopaque) callconv(.c) void {
    perf.perf_trace_destroy(getTrace(p, 1));
    rn(p, 0);
}

// ── family (labels / dimensions) ─────────────────────────────

fn getFamily(p: *anyopaque, n: c_int) ?*perf.Family {
    const raw = R.ring_vm_api_getcpointer(p, n, FAMILY_HANDLE) orelse return null;
    const addr = @intFromPtr(raw);
    if (addr == 0) return null;
    return @ptrFromInt(addr);
}

fn ring_FamilyCreate(p: *anyopaque) callconv(.c) void {
    const handle = perf.perf_family_create(gn(p, 1), gn(p, 2), gn(p, 3));
    if (handle) |f| {
        R.ring_vm_api_retcpointer(p, @ptrCast(f), FAMILY_HANDLE);
    } else {
        R.ring_vm_api_retcpointer(p, @ptrFromInt(0), FAMILY_HANDLE);
    }
}

fn ring_FamilyCanAdd(p: *anyopaque) callconv(.c) void {
    const key: [*]const u8 = @ptrCast(gs(p, 2));
    const kl: usize = @intCast(gss(p, 2));
    rn(p, perf.perf_family_can_add(getFamily(p, 1), key, kl));
}

fn ring_FamilyChildSeries(p: *anyopaque) callconv(.c) void {
    const key: [*]const u8 = @ptrCast(gs(p, 2));
    const kl: usize = @intCast(gss(p, 2));
    const s = perf.perf_family_child_series(getFamily(p, 1), key, kl);
    if (s) |sp| {
        R.ring_vm_api_retcpointer(p, @ptrCast(sp), SERIES_HANDLE);
    } else {
        R.ring_vm_api_retcpointer(p, @ptrFromInt(0), SERIES_HANDLE);
    }
}

fn ring_FamilyChildHist(p: *anyopaque) callconv(.c) void {
    const key: [*]const u8 = @ptrCast(gs(p, 2));
    const kl: usize = @intCast(gss(p, 2));
    const h = perf.perf_family_child_hist(getFamily(p, 1), key, kl);
    if (h) |hp| {
        R.ring_vm_api_retcpointer(p, @ptrCast(hp), HIST_HANDLE);
    } else {
        R.ring_vm_api_retcpointer(p, @ptrFromInt(0), HIST_HANDLE);
    }
}

fn ring_FamilySize(p: *anyopaque) callconv(.c) void {
    rn(p, perf.perf_family_size(getFamily(p, 1)));
}

fn ring_FamilyKeyAt(p: *anyopaque) callconv(.c) void {
    const n = perf.perf_family_key_at(getFamily(p, 1), gn(p, 2), &str_buf, str_buf.len);
    if (n > 0) rs2(p, &str_buf, @intCast(n)) else rs(p, @constCast(""));
}

fn ring_FamilyDestroy(p: *anyopaque) callconv(.c) void {
    perf.perf_family_destroy(getFamily(p, 1));
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
    .{ .name = "stzengineperftracecreate", .func = ring_TraceCreate },
    .{ .name = "stzengineperftracerecord", .func = ring_TraceRecord },
    .{ .name = "stzengineperftracecount", .func = ring_TraceCount },
    .{ .name = "stzengineperftracesize", .func = ring_TraceSize },
    .{ .name = "stzengineperftraceidat", .func = ring_TraceIdAt },
    .{ .name = "stzengineperftracepathat", .func = ring_TracePathAt },
    .{ .name = "stzengineperftracestatusat", .func = ring_TraceStatusAt },
    .{ .name = "stzengineperftracedurat", .func = ring_TraceDurAt },
    .{ .name = "stzengineperftracewallat", .func = ring_TraceWallAt },
    .{ .name = "stzengineperftracereset", .func = ring_TraceReset },
    .{ .name = "stzengineperftracedestroy", .func = ring_TraceDestroy },
    .{ .name = "stzengineperffamilycreate", .func = ring_FamilyCreate },
    .{ .name = "stzengineperffamilycanadd", .func = ring_FamilyCanAdd },
    .{ .name = "stzengineperffamilychildseries", .func = ring_FamilyChildSeries },
    .{ .name = "stzengineperffamilychildhist", .func = ring_FamilyChildHist },
    .{ .name = "stzengineperffamilysize", .func = ring_FamilySize },
    .{ .name = "stzengineperffamilykeyat", .func = ring_FamilyKeyAt },
    .{ .name = "stzengineperffamilydestroy", .func = ring_FamilyDestroy },
};

pub fn registerAll(state: *anyopaque) void {
    R.registerAll(state, &regs);
}
