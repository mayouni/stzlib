const time = @import("time.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const rn = R.ring_vm_api_retnumber;

// Ring numbers are doubles; nanos overflow precision past 2^53.
// We expose ms for callers that just need a monotonic counter, and
// keep a Float64-safe ns surface for short intervals (any window
// shorter than ~104 days is exact at ms precision).

fn ring_TimeNowMs(p: *anyopaque) callconv(.c) void {
    const t: f64 = @floatFromInt(time.stz_time_now_ms());
    rn(p, t);
}

fn ring_TimeNowUs(p: *anyopaque) callconv(.c) void {
    const t: f64 = @floatFromInt(time.stz_time_now_us());
    rn(p, t);
}

fn ring_TimeNowNs(p: *anyopaque) callconv(.c) void {
    const t: f64 = @floatFromInt(time.stz_time_now_ns());
    rn(p, t);
}

fn ring_TimeWallMs(p: *anyopaque) callconv(.c) void {
    const t: f64 = @floatFromInt(time.stz_time_wall_ms());
    rn(p, t);
}

fn ring_TimeSleepMs(p: *anyopaque) callconv(.c) void {
    const ms: u64 = @intFromFloat(gn(p, 1));
    time.stz_time_sleep_ms(ms);
}

fn ring_TimeResolutionNs(p: *anyopaque) callconv(.c) void {
    const r: f64 = @floatFromInt(time.stz_time_resolution_ns());
    rn(p, r);
}

const regs = [_]R.Reg{
    .{ .name = "stzenginetimenowms", .func = ring_TimeNowMs },
    .{ .name = "stzenginetimenowus", .func = ring_TimeNowUs },
    .{ .name = "stzenginetimenowns", .func = ring_TimeNowNs },
    .{ .name = "stzenginetimewallms", .func = ring_TimeWallMs },
    .{ .name = "stzenginetimesleepms", .func = ring_TimeSleepMs },
    .{ .name = "stzenginetimeresolutionns", .func = ring_TimeResolutionNs },
};

pub fn registerAll(state: *anyopaque) void {
    R.registerAll(state, &regs);
}
