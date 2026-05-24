const profiler = @import("profiler.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;

fn ring_ProfilerBegin(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(profiler.profiler_begin(ptr, len)));
}

fn ring_ProfilerEnd(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(profiler.profiler_end(ptr, len)));
}

fn ring_ProfilerTotalNs(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    rn(p, profiler.profiler_total_ns(ptr, len));
}

fn ring_ProfilerTotalMs(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    rn(p, profiler.profiler_total_ms(ptr, len));
}

fn ring_ProfilerCalls(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(profiler.profiler_calls(ptr, len)));
}

fn ring_ProfilerAvgNs(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    rn(p, profiler.profiler_avg_ns(ptr, len));
}

fn ring_ProfilerReset(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(profiler.profiler_reset(ptr, len)));
}

fn ring_ProfilerClear(p: *anyopaque) callconv(.c) void {
    _ = p;
    profiler.profiler_clear();
}

fn ring_ProfilerCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(profiler.profiler_count()));
}

pub const regs = [_]R.Reg{
    .{ .name = "stzengineprofilerbegin", .func = &ring_ProfilerBegin },
    .{ .name = "stzengineprofilerend", .func = &ring_ProfilerEnd },
    .{ .name = "stzengineprofilertotalns", .func = &ring_ProfilerTotalNs },
    .{ .name = "stzengineprofilertotalms", .func = &ring_ProfilerTotalMs },
    .{ .name = "stzengineprofilermetacalls", .func = &ring_ProfilerCalls },
    .{ .name = "stzengineprofileravgns", .func = &ring_ProfilerAvgNs },
    .{ .name = "stzengineprofilerreset", .func = &ring_ProfilerReset },
    .{ .name = "stzengineprofilermetaclear", .func = &ring_ProfilerClear },
    .{ .name = "stzengineprofilercnt", .func = &ring_ProfilerCount },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
