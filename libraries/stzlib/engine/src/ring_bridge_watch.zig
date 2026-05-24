const watch = @import("watch.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const rn = R.ring_vm_api_retnumber;

fn ring_WatchStart(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(watch.watch_start(@intFromFloat(gn(p, 1)))));
}

fn ring_WatchStop(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(watch.watch_stop(@intFromFloat(gn(p, 1)))));
}

fn ring_WatchResume(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(watch.watch_resume(@intFromFloat(gn(p, 1)))));
}

fn ring_WatchReset(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(watch.watch_reset(@intFromFloat(gn(p, 1)))));
}

fn ring_WatchElapsedNs(p: *anyopaque) callconv(.c) void {
    rn(p, watch.watch_elapsed_ns(@intFromFloat(gn(p, 1))));
}

fn ring_WatchElapsedUs(p: *anyopaque) callconv(.c) void {
    rn(p, watch.watch_elapsed_us(@intFromFloat(gn(p, 1))));
}

fn ring_WatchElapsedMs(p: *anyopaque) callconv(.c) void {
    rn(p, watch.watch_elapsed_ms(@intFromFloat(gn(p, 1))));
}

fn ring_WatchElapsedS(p: *anyopaque) callconv(.c) void {
    rn(p, watch.watch_elapsed_s(@intFromFloat(gn(p, 1))));
}

fn ring_WatchIsRunning(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(watch.watch_is_running(@intFromFloat(gn(p, 1)))));
}

fn ring_WatchTimestampNs(p: *anyopaque) callconv(.c) void {
    rn(p, watch.watch_timestamp_ns());
}

fn ring_WatchTimestampMs(p: *anyopaque) callconv(.c) void {
    rn(p, watch.watch_timestamp_ms());
}

pub const regs = [_]R.Reg{
    .{ .name = "stzenginewatchstart", .func = &ring_WatchStart },
    .{ .name = "stzenginewatchstop", .func = &ring_WatchStop },
    .{ .name = "stzenginewatchresume", .func = &ring_WatchResume },
    .{ .name = "stzenginewatchreset", .func = &ring_WatchReset },
    .{ .name = "stzenginewatchelapsedns", .func = &ring_WatchElapsedNs },
    .{ .name = "stzenginewatchelapsedus", .func = &ring_WatchElapsedUs },
    .{ .name = "stzenginewatchelapsedms", .func = &ring_WatchElapsedMs },
    .{ .name = "stzenginewatchelapseds", .func = &ring_WatchElapsedS },
    .{ .name = "stzenginewatchisrunning", .func = &ring_WatchIsRunning },
    .{ .name = "stzenginewatchtimestampns", .func = &ring_WatchTimestampNs },
    .{ .name = "stzenginewatchtimestampms", .func = &ring_WatchTimestampMs },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
