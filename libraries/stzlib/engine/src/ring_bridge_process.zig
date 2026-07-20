const process = @import("process.zig");
const R = @import("ring_api.zig");

const rn = R.ring_vm_api_retnumber;
const rs2 = R.ring_vm_api_retstring2;

fn ring_ProcessPid(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(process.process_pid()));
}

fn ring_ProcessUptimeNs(p: *anyopaque) callconv(.c) void {
    rn(p, process.process_uptime_ns());
}

fn ring_ProcessUptimeMs(p: *anyopaque) callconv(.c) void {
    rn(p, process.process_uptime_ms());
}

fn ring_ProcessUptimeS(p: *anyopaque) callconv(.c) void {
    rn(p, process.process_uptime_s());
}

fn ring_ProcessArch(p: *anyopaque) callconv(.c) void {
    var buf: [64]u8 = undefined;
    const len = process.process_arch(&buf, 64);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

fn ring_ProcessOs(p: *anyopaque) callconv(.c) void {
    var buf: [64]u8 = undefined;
    const len = process.process_os(&buf, 64);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

fn ring_ProcessEndian(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(process.process_endian()));
}

fn ring_ProcessPtrSize(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(process.process_ptr_size()));
}

pub const regs = [_]R.Reg{
    .{ .name = "stzengineprocesspid", .func = &ring_ProcessPid },
    .{ .name = "stzengineprocessuptimens", .func = &ring_ProcessUptimeNs },
    .{ .name = "stzengineprocessuptimems", .func = &ring_ProcessUptimeMs },
    .{ .name = "stzengineprocessuptimes", .func = &ring_ProcessUptimeS },
    .{ .name = "stzengineprocessarch", .func = &ring_ProcessArch },
    .{ .name = "stzengineprocessos", .func = &ring_ProcessOs },
    .{ .name = "stzengineprocessendian", .func = &ring_ProcessEndian },
    .{ .name = "stzengineprocessptrsize", .func = &ring_ProcessPtrSize },
};

pub fn registerAll(pState: *anyopaque) void {
    // Capture the uptime baseline at DLL load, so uptime counts from process
    // start rather than the Unix epoch.
    process.process_init();
    R.registerAll(pState, &regs);
}
