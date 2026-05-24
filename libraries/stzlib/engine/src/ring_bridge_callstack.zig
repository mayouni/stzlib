const callstack = @import("callstack.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs2 = R.ring_vm_api_retstring2;

fn ring_CallstackPush(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(callstack.callstack_push(ptr, len)));
}

fn ring_CallstackPop(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(callstack.callstack_pop()));
}

fn ring_CallstackDepth(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(callstack.callstack_depth()));
}

fn ring_CallstackFrame(p: *anyopaque) callconv(.c) void {
    const idx: u32 = @intFromFloat(gn(p, 1));
    var buf: [128]u8 = undefined;
    const len = callstack.callstack_frame(idx, &buf, 128);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

fn ring_CallstackTop(p: *anyopaque) callconv(.c) void {
    var buf: [128]u8 = undefined;
    const len = callstack.callstack_top(&buf, 128);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

fn ring_CallstackClear(p: *anyopaque) callconv(.c) void {
    _ = p;
    callstack.callstack_clear();
}

fn ring_CallstackToString(p: *anyopaque) callconv(.c) void {
    var buf: [4096]u8 = undefined;
    const len = callstack.callstack_to_string(&buf, 4096);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

pub const regs = [_]R.Reg{
    .{ .name = "stzenginecallstackpush", .func = &ring_CallstackPush },
    .{ .name = "stzenginecallstackpop", .func = &ring_CallstackPop },
    .{ .name = "stzenginecallstackdepth", .func = &ring_CallstackDepth },
    .{ .name = "stzenginecallstackframe", .func = &ring_CallstackFrame },
    .{ .name = "stzenginecallstacktop", .func = &ring_CallstackTop },
    .{ .name = "stzenginecallstackclear", .func = &ring_CallstackClear },
    .{ .name = "stzenginecallstacktostring", .func = &ring_CallstackToString },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
