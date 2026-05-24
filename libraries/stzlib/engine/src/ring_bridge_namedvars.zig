const R = @import("ring_api.zig");
const nv = @import("namedvars.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gl = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring2;

fn ring_set_int(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(nv.nv_set_int(gs(p, 1), @intCast(gl(p, 1)), @intFromFloat(gn(p, 2)))));
}

fn ring_set_float(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(nv.nv_set_float(gs(p, 1), @intCast(gl(p, 1)), gn(p, 2))));
}

fn ring_set_string(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(nv.nv_set_string(gs(p, 1), @intCast(gl(p, 1)), gs(p, 2), @intCast(gl(p, 2)))));
}

fn ring_set_bool(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(nv.nv_set_bool(gs(p, 1), @intCast(gl(p, 1)), @intFromFloat(gn(p, 2)))));
}

fn ring_get_type(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(nv.nv_get_type(gs(p, 1), @intCast(gl(p, 1)))));
}

fn ring_get_int(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(nv.nv_get_int(gs(p, 1), @intCast(gl(p, 1)))));
}

fn ring_get_float(p: *anyopaque) callconv(.c) void {
    rn(p, nv.nv_get_float(gs(p, 1), @intCast(gl(p, 1))));
}

fn ring_get_string(p: *anyopaque) callconv(.c) void {
    var buf: [256]u8 = undefined;
    const len = nv.nv_get_string(gs(p, 1), @intCast(gl(p, 1)), &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_has(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(nv.nv_has(gs(p, 1), @intCast(gl(p, 1)))));
}

fn ring_remove(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(nv.nv_remove(gs(p, 1), @intCast(gl(p, 1)))));
}

fn ring_count(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(nv.nv_count()));
}

fn ring_clear(p: *anyopaque) callconv(.c) void {
    _ = p;
    nv.nv_clear();
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = "stzengine_nv_set_int", .func = ring_set_int },
    .{ .name = "stzengine_nv_set_float", .func = ring_set_float },
    .{ .name = "stzengine_nv_set_string", .func = ring_set_string },
    .{ .name = "stzengine_nv_set_bool", .func = ring_set_bool },
    .{ .name = "stzengine_nv_get_type", .func = ring_get_type },
    .{ .name = "stzengine_nv_get_int", .func = ring_get_int },
    .{ .name = "stzengine_nv_get_float", .func = ring_get_float },
    .{ .name = "stzengine_nv_get_string", .func = ring_get_string },
    .{ .name = "stzengine_nv_has", .func = ring_has },
    .{ .name = "stzengine_nv_remove", .func = ring_remove },
    .{ .name = "stzengine_nv_count", .func = ring_count },
    .{ .name = "stzengine_nv_clear", .func = ring_clear },
};
