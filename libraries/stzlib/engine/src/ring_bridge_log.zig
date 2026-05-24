const log = @import("log.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs2 = R.ring_vm_api_retstring2;

fn ring_LogSetLevel(p: *anyopaque) callconv(.c) void {
    log.log_set_level(@intFromFloat(gn(p, 1)));
}

fn ring_LogGetLevel(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(log.log_get_level()));
}

fn ring_LogEnable(p: *anyopaque) callconv(.c) void {
    _ = p;
    log.log_enable();
}

fn ring_LogDisable(p: *anyopaque) callconv(.c) void {
    _ = p;
    log.log_disable();
}

fn ring_LogIsEnabled(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(log.log_is_enabled()));
}

fn ring_LogWrite(p: *anyopaque) callconv(.c) void {
    const level: u8 = @intFromFloat(gn(p, 1));
    const ptr: [*]const u8 = @ptrCast(gs(p, 2));
    const len: usize = @intCast(gss(p, 2));
    rn(p, @floatFromInt(log.log_write(level, ptr, len)));
}

fn ring_LogLastMessage(p: *anyopaque) callconv(.c) void {
    var buf: [4096]u8 = undefined;
    const len = log.log_last_message(&buf, 4096);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

fn ring_LogMessageCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(log.log_message_count()));
}

fn ring_LogClear(p: *anyopaque) callconv(.c) void {
    _ = p;
    log.log_clear();
}

fn ring_LogLevelName(p: *anyopaque) callconv(.c) void {
    const level: u8 = @intFromFloat(gn(p, 1));
    var buf: [32]u8 = undefined;
    const len = log.log_level_name(level, &buf, 32);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

pub const regs = [_]R.Reg{
    .{ .name = "stzenginelogsetlevel", .func = &ring_LogSetLevel },
    .{ .name = "stzengineloggetlevel", .func = &ring_LogGetLevel },
    .{ .name = "stzenginelogenable", .func = &ring_LogEnable },
    .{ .name = "stzenginelogdisable", .func = &ring_LogDisable },
    .{ .name = "stzenginelogisenabled", .func = &ring_LogIsEnabled },
    .{ .name = "stzenginelogwrite", .func = &ring_LogWrite },
    .{ .name = "stzengineloglastmessage", .func = &ring_LogLastMessage },
    .{ .name = "stzenginelogmessagecount", .func = &ring_LogMessageCount },
    .{ .name = "stzenginelogclear", .func = &ring_LogClear },
    .{ .name = "stzengineloglevelname", .func = &ring_LogLevelName },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
