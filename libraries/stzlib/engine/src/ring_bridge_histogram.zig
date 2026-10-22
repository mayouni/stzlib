const histogram = @import("histogram.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const rn = R.ring_vm_api_retnumber;

const HIST_HANDLE: [*:0]const u8 = "StzHistogram";

fn getHist(p: *anyopaque, n: c_int) ?*histogram.Histogram {
    // Two kinds of histogram reach here. One this DLL made: an id in its own,
    // generation-checked table. One a perf family owns (stz_perf.dll): a raw
    // pointer, since that DLL's table ids mean nothing here (R16).
    const raw = blk: {
        if (R.ring_vm_api_ispointer(p, n) == 1) break :blk R.ring_vm_api_getcpointer(p, n, HIST_HANDLE) orelse return null;
        break :blk R.getHandleOrRaise(p, n, "latency histogram") orelse return null;
    };
    const addr = @intFromPtr(raw);
    if (addr == 0) return null;
    return @ptrFromInt(addr);
}

fn ring_HistogramCreate(p: *anyopaque) callconv(.c) void {
    const handle = histogram.histogram_create();
    if (handle) |h| {
        R.retHandleOnce(p, @ptrCast(h));
    } else {
        R.ring_vm_api_retnumber(p, 0);
    }
}

fn ring_HistogramRecord(p: *anyopaque) callconv(.c) void {
    histogram.histogram_record(getHist(p, 1), gn(p, 2));
    rn(p, 0);
}

fn ring_HistogramPercentile(p: *anyopaque) callconv(.c) void {
    rn(p, histogram.histogram_percentile(getHist(p, 1), gn(p, 2)));
}

fn ring_HistogramCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(histogram.histogram_count(getHist(p, 1))));
}

fn ring_HistogramSum(p: *anyopaque) callconv(.c) void {
    rn(p, histogram.histogram_sum(getHist(p, 1)));
}

fn ring_HistogramReset(p: *anyopaque) callconv(.c) void {
    histogram.histogram_reset(getHist(p, 1));
    rn(p, 0);
}

fn ring_HistogramDestroy(p: *anyopaque) callconv(.c) void {
    const _obj = getHist(p, 1);
    R.releaseParam(p, 1); // every copy of this id goes stale before the memory is freed (R16)
    histogram.histogram_destroy(_obj);
    rn(p, 0);
}

const regs = [_]R.Reg{
    .{ .name = "stzenginehistogramcreate", .func = ring_HistogramCreate },
    .{ .name = "stzenginehistogramrecord", .func = ring_HistogramRecord },
    .{ .name = "stzenginehistogrampercentile", .func = ring_HistogramPercentile },
    .{ .name = "stzenginehistogramcount", .func = ring_HistogramCount },
    .{ .name = "stzenginehistogramsum", .func = ring_HistogramSum },
    .{ .name = "stzenginehistogramreset", .func = ring_HistogramReset },
    .{ .name = "stzenginehistogramdestroy", .func = ring_HistogramDestroy },
};

pub fn registerAll(state: *anyopaque) void {
    R.registerAll(state, &regs);
}
