const tracectx = @import("tracectx.zig");
const R = @import("ring_api.zig");

const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rs2 = R.ring_vm_api_retstring2;
const rs = R.ring_vm_api_retstring;
const rn = R.ring_vm_api_retnumber;

var buf: [128]u8 = undefined;

/// StzEngineTraceNew() -> a fresh sampled traceparent header value.
fn ring_TraceNew(p: *anyopaque) callconv(.c) void {
    const n = tracectx.tracectx_new(&buf, buf.len);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, @constCast(""));
}

/// StzEngineTraceChild(cParent) -> child header, or "" if parent invalid.
fn ring_TraceChild(p: *anyopaque) callconv(.c) void {
    const tp: [*]const u8 = @ptrCast(gs(p, 1));
    const tl: usize = @intCast(gss(p, 1));
    const n = tracectx.tracectx_child(tp, tl, &buf, buf.len);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, @constCast(""));
}

fn ring_TraceIsValid(p: *anyopaque) callconv(.c) void {
    const tp: [*]const u8 = @ptrCast(gs(p, 1));
    const tl: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(tracectx.tracectx_is_valid(tp, tl)));
}

fn ring_TraceId(p: *anyopaque) callconv(.c) void {
    const tp: [*]const u8 = @ptrCast(gs(p, 1));
    const tl: usize = @intCast(gss(p, 1));
    const n = tracectx.tracectx_trace_id(tp, tl, &buf, buf.len);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, @constCast(""));
}

fn ring_TraceSpanId(p: *anyopaque) callconv(.c) void {
    const tp: [*]const u8 = @ptrCast(gs(p, 1));
    const tl: usize = @intCast(gss(p, 1));
    const n = tracectx.tracectx_span_id(tp, tl, &buf, buf.len);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, @constCast(""));
}

fn ring_TraceSampled(p: *anyopaque) callconv(.c) void {
    const tp: [*]const u8 = @ptrCast(gs(p, 1));
    const tl: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(tracectx.tracectx_sampled(tp, tl)));
}

const regs = [_]R.Reg{
    .{ .name = "stzenginetracenew", .func = ring_TraceNew },
    .{ .name = "stzenginetracechild", .func = ring_TraceChild },
    .{ .name = "stzenginetraceisvalid", .func = ring_TraceIsValid },
    .{ .name = "stzenginetraceid", .func = ring_TraceId },
    .{ .name = "stzenginetracespanid", .func = ring_TraceSpanId },
    .{ .name = "stzenginetracesampled", .func = ring_TraceSampled },
};

pub fn registerAll(state: *anyopaque) void {
    R.registerAll(state, &regs);
}
