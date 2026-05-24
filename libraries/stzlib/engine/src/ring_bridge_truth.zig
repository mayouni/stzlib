const R = @import("ring_api.zig");
const truth = @import("truth.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gl = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring2;

fn ring_create_domain(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(truth.truth_create_domain(gs(p, 1), @intCast(gl(p, 1)))));
}

fn ring_add_value(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(truth.truth_add_value(gs(p, 1), @intCast(gl(p, 1)), gs(p, 2), @intCast(gl(p, 2)), @intFromFloat(gn(p, 3)))));
}

fn ring_value_count(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(truth.truth_value_count(gs(p, 1), @intCast(gl(p, 1)))));
}

fn ring_value_name(p: *anyopaque) callconv(.c) void {
    var buf: [32]u8 = undefined;
    const len = truth.truth_value_name(gs(p, 1), @intCast(gl(p, 1)), @intFromFloat(gn(p, 2)), &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_value_rank(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(truth.truth_value_rank(gs(p, 1), @intCast(gl(p, 1)), @intFromFloat(gn(p, 2)))));
}

fn ring_compare(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(truth.truth_compare(gs(p, 1), @intCast(gl(p, 1)), @intFromFloat(gn(p, 2)), @intFromFloat(gn(p, 3)))));
}

fn ring_domain_count(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(truth.truth_domain_count()));
}

fn ring_clear(p: *anyopaque) callconv(.c) void {
    _ = p;
    truth.truth_clear();
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = "stzengine_truth_create_domain", .func = ring_create_domain },
    .{ .name = "stzengine_truth_add_value", .func = ring_add_value },
    .{ .name = "stzengine_truth_value_count", .func = ring_value_count },
    .{ .name = "stzengine_truth_value_name", .func = ring_value_name },
    .{ .name = "stzengine_truth_value_rank", .func = ring_value_rank },
    .{ .name = "stzengine_truth_compare", .func = ring_compare },
    .{ .name = "stzengine_truth_domain_count", .func = ring_domain_count },
    .{ .name = "stzengine_truth_clear", .func = ring_clear },
};
