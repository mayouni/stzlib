const R = @import("ring_api.zig");
const constraint = @import("constraint.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs2 = R.ring_vm_api_retstring2;

fn ring_add_range(p: *anyopaque) callconv(.c) void {
    const n: [*]const u8 = @ptrCast(gs(p, 1));
    const nl: usize = @intCast(gss(p, 1));
    const min = gn(p, 2);
    const max = gn(p, 3);
    rn(p, @floatFromInt(constraint.add_range(n, nl, min, max)));
}

fn ring_add_not_empty(p: *anyopaque) callconv(.c) void {
    const n: [*]const u8 = @ptrCast(gs(p, 1));
    const nl: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(constraint.add_not_empty(n, nl)));
}

fn ring_add_min_len(p: *anyopaque) callconv(.c) void {
    const n: [*]const u8 = @ptrCast(gs(p, 1));
    const nl: usize = @intCast(gss(p, 1));
    const m: i32 = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(constraint.add_min_len(n, nl, m)));
}

fn ring_add_max_len(p: *anyopaque) callconv(.c) void {
    const n: [*]const u8 = @ptrCast(gs(p, 1));
    const nl: usize = @intCast(gss(p, 1));
    const m: i32 = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(constraint.add_max_len(n, nl, m)));
}

fn ring_check_range(p: *anyopaque) callconv(.c) void {
    const i: i32 = @intFromFloat(gn(p, 1));
    const v = gn(p, 2);
    rn(p, @floatFromInt(constraint.check_range(i, v)));
}

fn ring_check_not_empty(p: *anyopaque) callconv(.c) void {
    const i: i32 = @intFromFloat(gn(p, 1));
    const l: usize = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(constraint.check_not_empty(i, l)));
}

fn ring_check_min_len(p: *anyopaque) callconv(.c) void {
    const i: i32 = @intFromFloat(gn(p, 1));
    const l: usize = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(constraint.check_min_len(i, l)));
}

fn ring_check_max_len(p: *anyopaque) callconv(.c) void {
    const i: i32 = @intFromFloat(gn(p, 1));
    const l: usize = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(constraint.check_max_len(i, l)));
}

fn ring_last_violation(p: *anyopaque) callconv(.c) void {
    var buf: [256]u8 = undefined;
    const len = constraint.last_violation(&buf);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

fn ring_name(p: *anyopaque) callconv(.c) void {
    const i: i32 = @intFromFloat(gn(p, 1));
    var buf: [64]u8 = undefined;
    const len = constraint.constraint_name(i, &buf);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

fn ring_count(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(constraint.count()));
}

fn ring_clear(p: *anyopaque) callconv(.c) void {
    _ = p;
    constraint.clear();
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = "stzengine_constraint_add_range", .func = ring_add_range },
    .{ .name = "stzengine_constraint_add_not_empty", .func = ring_add_not_empty },
    .{ .name = "stzengine_constraint_add_min_len", .func = ring_add_min_len },
    .{ .name = "stzengine_constraint_add_max_len", .func = ring_add_max_len },
    .{ .name = "stzengine_constraint_check_range", .func = ring_check_range },
    .{ .name = "stzengine_constraint_check_not_empty", .func = ring_check_not_empty },
    .{ .name = "stzengine_constraint_check_min_len", .func = ring_check_min_len },
    .{ .name = "stzengine_constraint_check_max_len", .func = ring_check_max_len },
    .{ .name = "stzengine_constraint_last_violation", .func = ring_last_violation },
    .{ .name = "stzengine_constraint_name", .func = ring_name },
    .{ .name = "stzengine_constraint_count", .func = ring_count },
    .{ .name = "stzengine_constraint_clear", .func = ring_clear },
};
