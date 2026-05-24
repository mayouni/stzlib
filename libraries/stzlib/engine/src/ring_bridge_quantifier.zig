const R = @import("ring_api.zig");
const q = @import("quantifier.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gl = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring2;

fn ring_define(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(q.q_define(gs(p, 1), @intCast(gl(p, 1)), gn(p, 2), gn(p, 3))));
}

fn ring_check(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(q.q_check(gs(p, 1), @intCast(gl(p, 1)), @intFromFloat(gn(p, 2)), @intFromFloat(gn(p, 3)))));
}

fn ring_classify(p: *anyopaque) callconv(.c) void {
    var buf: [64]u8 = undefined;
    const len = q.q_classify(@intFromFloat(gn(p, 1)), @intFromFloat(gn(p, 2)), &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_count(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(q.q_count()));
}

fn ring_name_at(p: *anyopaque) callconv(.c) void {
    var buf: [64]u8 = undefined;
    const len = q.q_name_at(@intFromFloat(gn(p, 1)), &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_clear(p: *anyopaque) callconv(.c) void {
    _ = p;
    q.q_clear();
}

fn ring_init_defaults(p: *anyopaque) callconv(.c) void {
    _ = p;
    q.q_init_defaults();
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = "stzengine_quantifier_define", .func = ring_define },
    .{ .name = "stzengine_quantifier_check", .func = ring_check },
    .{ .name = "stzengine_quantifier_classify", .func = ring_classify },
    .{ .name = "stzengine_quantifier_count", .func = ring_count },
    .{ .name = "stzengine_quantifier_name_at", .func = ring_name_at },
    .{ .name = "stzengine_quantifier_clear", .func = ring_clear },
    .{ .name = "stzengine_quantifier_init_defaults", .func = ring_init_defaults },
};
