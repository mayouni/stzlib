const R = @import("ring_api.zig");
const univops = @import("univops.zig");

const gn = R.ring_vm_api_getnumber;
const rn = R.ring_vm_api_retnumber;
const rs2 = R.ring_vm_api_retstring2;

fn ring_type_name(p: *anyopaque) callconv(.c) void {
    const t: i32 = @intFromFloat(gn(p, 1));
    var buf: [16]u8 = undefined;
    const len = univops.type_name(t, &buf);
    rs2(p, &buf, @intCast(len));
}

fn ring_type_is_numeric(p: *anyopaque) callconv(.c) void {
    const t: i32 = @intFromFloat(gn(p, 1));
    rn(p, @floatFromInt(univops.type_is_numeric(t)));
}

fn ring_type_is_collection(p: *anyopaque) callconv(.c) void {
    const t: i32 = @intFromFloat(gn(p, 1));
    rn(p, @floatFromInt(univops.type_is_collection(t)));
}

fn ring_type_is_scalar(p: *anyopaque) callconv(.c) void {
    const t: i32 = @intFromFloat(gn(p, 1));
    rn(p, @floatFromInt(univops.type_is_scalar(t)));
}

fn ring_int_min(p: *anyopaque) callconv(.c) void {
    const a: i64 = @intFromFloat(gn(p, 1));
    const b: i64 = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(univops.int_min(a, b)));
}

fn ring_int_max(p: *anyopaque) callconv(.c) void {
    const a: i64 = @intFromFloat(gn(p, 1));
    const b: i64 = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(univops.int_max(a, b)));
}

fn ring_int_clamp(p: *anyopaque) callconv(.c) void {
    const v: i64 = @intFromFloat(gn(p, 1));
    const lo: i64 = @intFromFloat(gn(p, 2));
    const hi: i64 = @intFromFloat(gn(p, 3));
    rn(p, @floatFromInt(univops.int_clamp(v, lo, hi)));
}

fn ring_int_abs(p: *anyopaque) callconv(.c) void {
    const n: i64 = @intFromFloat(gn(p, 1));
    rn(p, @floatFromInt(univops.int_abs(n)));
}

fn ring_int_sign(p: *anyopaque) callconv(.c) void {
    const n: i64 = @intFromFloat(gn(p, 1));
    rn(p, @floatFromInt(univops.int_sign(n)));
}

fn ring_int_in_range(p: *anyopaque) callconv(.c) void {
    const n: i64 = @intFromFloat(gn(p, 1));
    const lo: i64 = @intFromFloat(gn(p, 2));
    const hi: i64 = @intFromFloat(gn(p, 3));
    rn(p, @floatFromInt(univops.int_in_range(n, lo, hi)));
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = "stzengine_univops_type_name", .func = ring_type_name },
    .{ .name = "stzengine_univops_type_is_numeric", .func = ring_type_is_numeric },
    .{ .name = "stzengine_univops_type_is_collection", .func = ring_type_is_collection },
    .{ .name = "stzengine_univops_type_is_scalar", .func = ring_type_is_scalar },
    .{ .name = "stzengine_univops_int_min", .func = ring_int_min },
    .{ .name = "stzengine_univops_int_max", .func = ring_int_max },
    .{ .name = "stzengine_univops_int_clamp", .func = ring_int_clamp },
    .{ .name = "stzengine_univops_int_abs", .func = ring_int_abs },
    .{ .name = "stzengine_univops_int_sign", .func = ring_int_sign },
    .{ .name = "stzengine_univops_int_in_range", .func = ring_int_in_range },
};
