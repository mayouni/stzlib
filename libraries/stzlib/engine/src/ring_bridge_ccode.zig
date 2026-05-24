const R = @import("ring_api.zig");
const ccode = @import("ccode.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gl = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring2;

fn ring_type_name(p: *anyopaque) callconv(.c) void {
    const t: i32 = @intFromFloat(gn(p, 1));
    var buf: [64]u8 = undefined;
    const len = ccode.ccode_type_name(t, &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_sizeof(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ccode.ccode_sizeof(@intFromFloat(gn(p, 1)))));
}

fn ring_is_keyword(p: *anyopaque) callconv(.c) void {
    const s = gs(p, 1);
    const l: i32 = @intCast(gl(p, 1));
    rn(p, @floatFromInt(ccode.ccode_is_keyword(s, l)));
}

fn ring_include(p: *anyopaque) callconv(.c) void {
    const h = gs(p, 1);
    const hl: i32 = @intCast(gl(p, 1));
    const sys: i32 = @intFromFloat(gn(p, 2));
    var buf: [512]u8 = undefined;
    const len = ccode.ccode_include(h, hl, sys, &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_define(p: *anyopaque) callconv(.c) void {
    const n = gs(p, 1);
    const nl: i32 = @intCast(gl(p, 1));
    const v = gs(p, 2);
    const vl: i32 = @intCast(gl(p, 2));
    var buf: [512]u8 = undefined;
    const len = ccode.ccode_define(n, nl, v, vl, &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_typedef(p: *anyopaque) callconv(.c) void {
    const ot: i32 = @intFromFloat(gn(p, 1));
    const n = gs(p, 2);
    const nl: i32 = @intCast(gl(p, 2));
    var buf: [256]u8 = undefined;
    const len = ccode.ccode_typedef(ot, n, nl, &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_struct_field(p: *anyopaque) callconv(.c) void {
    const t: i32 = @intFromFloat(gn(p, 1));
    const f = gs(p, 2);
    const fl: i32 = @intCast(gl(p, 2));
    var buf: [256]u8 = undefined;
    const len = ccode.ccode_struct_field(t, f, fl, &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_escape_string(p: *anyopaque) callconv(.c) void {
    const s = gs(p, 1);
    const sl: i32 = @intCast(gl(p, 1));
    var buf: [4096]u8 = undefined;
    const len = ccode.ccode_escape_string(s, sl, &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = "stzengine_ccode_type_name", .func = ring_type_name },
    .{ .name = "stzengine_ccode_sizeof", .func = ring_sizeof },
    .{ .name = "stzengine_ccode_is_keyword", .func = ring_is_keyword },
    .{ .name = "stzengine_ccode_include", .func = ring_include },
    .{ .name = "stzengine_ccode_define", .func = ring_define },
    .{ .name = "stzengine_ccode_typedef", .func = ring_typedef },
    .{ .name = "stzengine_ccode_struct_field", .func = ring_struct_field },
    .{ .name = "stzengine_ccode_escape_string", .func = ring_escape_string },
};
