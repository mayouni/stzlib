const R = @import("ring_api.zig");
const stringart = @import("stringart.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs2 = R.ring_vm_api_retstring2;

fn ring_pad_left(p: *anyopaque) callconv(.c) void {
    const s: [*]const u8 = @ptrCast(gs(p, 1));
    const sl: usize = @intCast(gss(p, 1));
    const w: i32 = @intFromFloat(gn(p, 2));
    const c: u8 = @intFromFloat(gn(p, 3));
    var buf: [4096]u8 = undefined;
    const len = stringart.pad_left(s, sl, w, c, &buf);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

fn ring_pad_right(p: *anyopaque) callconv(.c) void {
    const s: [*]const u8 = @ptrCast(gs(p, 1));
    const sl: usize = @intCast(gss(p, 1));
    const w: i32 = @intFromFloat(gn(p, 2));
    const c: u8 = @intFromFloat(gn(p, 3));
    var buf: [4096]u8 = undefined;
    const len = stringart.pad_right(s, sl, w, c, &buf);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

fn ring_center(p: *anyopaque) callconv(.c) void {
    const s: [*]const u8 = @ptrCast(gs(p, 1));
    const sl: usize = @intCast(gss(p, 1));
    const w: i32 = @intFromFloat(gn(p, 2));
    const c: u8 = @intFromFloat(gn(p, 3));
    var buf: [4096]u8 = undefined;
    const len = stringart.center(s, sl, w, c, &buf);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

fn ring_repeat(p: *anyopaque) callconv(.c) void {
    const s: [*]const u8 = @ptrCast(gs(p, 1));
    const sl: usize = @intCast(gss(p, 1));
    const n: i32 = @intFromFloat(gn(p, 2));
    var buf: [4096]u8 = undefined;
    const len = stringart.repeat_str(s, sl, n, &buf);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

fn ring_box_line(p: *anyopaque) callconv(.c) void {
    const s: [*]const u8 = @ptrCast(gs(p, 1));
    const sl: usize = @intCast(gss(p, 1));
    const w: i32 = @intFromFloat(gn(p, 2));
    const b: u8 = @intFromFloat(gn(p, 3));
    var buf: [4096]u8 = undefined;
    const len = stringart.box_line(s, sl, w, b, &buf);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

fn ring_box_top(p: *anyopaque) callconv(.c) void {
    const w: i32 = @intFromFloat(gn(p, 1));
    const c: u8 = @intFromFloat(gn(p, 2));
    const h: u8 = @intFromFloat(gn(p, 3));
    var buf: [4096]u8 = undefined;
    const len = stringart.box_top(w, c, h, &buf);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

fn ring_indent(p: *anyopaque) callconv(.c) void {
    const s: [*]const u8 = @ptrCast(gs(p, 1));
    const sl: usize = @intCast(gss(p, 1));
    const sp: i32 = @intFromFloat(gn(p, 2));
    var buf: [4096]u8 = undefined;
    const len = stringart.indent(s, sl, sp, &buf);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

fn ring_truncate(p: *anyopaque) callconv(.c) void {
    const s: [*]const u8 = @ptrCast(gs(p, 1));
    const sl: usize = @intCast(gss(p, 1));
    const mw: i32 = @intFromFloat(gn(p, 2));
    var buf: [4096]u8 = undefined;
    const len = stringart.truncate_ellipsis(s, sl, mw, &buf);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

fn ring_visible_len(p: *anyopaque) callconv(.c) void {
    const s: [*]const u8 = @ptrCast(gs(p, 1));
    const sl: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(stringart.visible_len(s, sl)));
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = "stzengine_stringart_pad_left", .func = ring_pad_left },
    .{ .name = "stzengine_stringart_pad_right", .func = ring_pad_right },
    .{ .name = "stzengine_stringart_center", .func = ring_center },
    .{ .name = "stzengine_stringart_repeat", .func = ring_repeat },
    .{ .name = "stzengine_stringart_box_line", .func = ring_box_line },
    .{ .name = "stzengine_stringart_box_top", .func = ring_box_top },
    .{ .name = "stzengine_stringart_indent", .func = ring_indent },
    .{ .name = "stzengine_stringart_truncate", .func = ring_truncate },
    .{ .name = "stzengine_stringart_visible_len", .func = ring_visible_len },
};
