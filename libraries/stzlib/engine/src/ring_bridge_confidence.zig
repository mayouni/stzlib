const R = @import("ring_api.zig");
const mod = @import("confidence.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gsl = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;

fn ring_Set(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_conf_set(gs(p, 1), @intCast(gsl(p, 1)), gn(p, 2), gn(p, 3))));
}

fn ring_Get(p: *anyopaque) callconv(.c) void {
    rn(p, mod.stz_conf_get(gs(p, 1), @intCast(gsl(p, 1))));
}

fn ring_Count(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_conf_count()));
}

fn ring_WeightedAvg(p: *anyopaque) callconv(.c) void {
    rn(p, mod.stz_conf_weighted_avg());
}

fn ring_Min(p: *anyopaque) callconv(.c) void {
    rn(p, mod.stz_conf_min());
}

fn ring_Max(p: *anyopaque) callconv(.c) void {
    rn(p, mod.stz_conf_max());
}

fn ring_Remove(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_conf_remove(gs(p, 1), @intCast(gsl(p, 1)))));
}

fn ring_Clear(p: *anyopaque) callconv(.c) void {
    _ = p;
    mod.stz_conf_clear();
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = "stzengineconfset", .func = ring_Set },
    .{ .name = "stzengineconfget", .func = ring_Get },
    .{ .name = "stzengineconfcount", .func = ring_Count },
    .{ .name = "stzengineconfweightedavg", .func = ring_WeightedAvg },
    .{ .name = "stzengineconfmin", .func = ring_Min },
    .{ .name = "stzengineconfmax", .func = ring_Max },
    .{ .name = "stzengineconfremove", .func = ring_Remove },
    .{ .name = "stzengineconfclear", .func = ring_Clear },
};
