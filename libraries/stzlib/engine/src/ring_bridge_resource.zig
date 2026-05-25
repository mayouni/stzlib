const R = @import("ring_api.zig");
const mod = @import("resource.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gsl = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;

fn ring_Register(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_res_register(gs(p, 1), @intCast(gsl(p, 1)), gs(p, 2), @intCast(gsl(p, 2)))));
}

fn ring_Acquire(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_res_acquire(gs(p, 1), @intCast(gsl(p, 1)))));
}

fn ring_Release(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_res_release(gs(p, 1), @intCast(gsl(p, 1)))));
}

fn ring_State(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_res_state(gs(p, 1), @intCast(gsl(p, 1)))));
}

fn ring_Count(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_res_count()));
}

fn ring_LeakedCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_res_leaked_count()));
}

fn ring_AcquireCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_res_acquire_count(gs(p, 1), @intCast(gsl(p, 1)))));
}

fn ring_Unregister(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_res_unregister(gs(p, 1), @intCast(gsl(p, 1)))));
}

fn ring_Clear(p: *anyopaque) callconv(.c) void {
    _ = p;
    mod.stz_res_clear();
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = "stzengineresregister", .func = ring_Register },
    .{ .name = "stzengineresacquire", .func = ring_Acquire },
    .{ .name = "stzengineresrelease", .func = ring_Release },
    .{ .name = "stzengineresstate", .func = ring_State },
    .{ .name = "stzenginerescount", .func = ring_Count },
    .{ .name = "stzengineresleakedcount", .func = ring_LeakedCount },
    .{ .name = "stzengineresacquirecount", .func = ring_AcquireCount },
    .{ .name = "stzengineresunregister", .func = ring_Unregister },
    .{ .name = "stzengineresclear", .func = ring_Clear },
};
