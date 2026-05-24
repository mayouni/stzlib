const async_task = @import("async_task.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs2 = R.ring_vm_api_retstring2;

fn ring_AsyncCreate(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    const pri: u8 = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(async_task.async_create(ptr, len, pri)));
}

fn ring_AsyncStatus(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(async_task.async_status(@intFromFloat(gn(p, 1)))));
}

fn ring_AsyncStart(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(async_task.async_start(@intFromFloat(gn(p, 1)))));
}

fn ring_AsyncComplete(p: *anyopaque) callconv(.c) void {
    const id: u32 = @intFromFloat(gn(p, 1));
    const ptr: [*]const u8 = @ptrCast(gs(p, 2));
    const len: usize = @intCast(gss(p, 2));
    rn(p, @floatFromInt(async_task.async_complete(id, ptr, len)));
}

fn ring_AsyncFail(p: *anyopaque) callconv(.c) void {
    const id: u32 = @intFromFloat(gn(p, 1));
    const ptr: [*]const u8 = @ptrCast(gs(p, 2));
    const len: usize = @intCast(gss(p, 2));
    rn(p, @floatFromInt(async_task.async_fail(id, ptr, len)));
}

fn ring_AsyncResult(p: *anyopaque) callconv(.c) void {
    const id: u32 = @intFromFloat(gn(p, 1));
    var buf: [1024]u8 = undefined;
    const len = async_task.async_result(id, &buf, 1024);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

fn ring_AsyncCancel(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(async_task.async_cancel(@intFromFloat(gn(p, 1)))));
}

fn ring_AsyncPendingCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(async_task.async_pending_count()));
}

fn ring_AsyncNextPending(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(async_task.async_next_pending()));
}

fn ring_AsyncClear(p: *anyopaque) callconv(.c) void {
    _ = p;
    async_task.async_clear();
}

pub const regs = [_]R.Reg{
    .{ .name = "stzengineasynccreate", .func = &ring_AsyncCreate },
    .{ .name = "stzengineasyncstatus", .func = &ring_AsyncStatus },
    .{ .name = "stzengineasyncstart", .func = &ring_AsyncStart },
    .{ .name = "stzengineasynccomplete", .func = &ring_AsyncComplete },
    .{ .name = "stzengineasyncfail", .func = &ring_AsyncFail },
    .{ .name = "stzengineasyncresult", .func = &ring_AsyncResult },
    .{ .name = "stzengineasynccancel", .func = &ring_AsyncCancel },
    .{ .name = "stzengineasyncpendingcount", .func = &ring_AsyncPendingCount },
    .{ .name = "stzengineasyncnextpending", .func = &ring_AsyncNextPending },
    .{ .name = "stzengineasyncclear", .func = &ring_AsyncClear },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
