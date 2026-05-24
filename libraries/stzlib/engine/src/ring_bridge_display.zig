const R = @import("ring_api.zig");
const display = @import("display.zig");

const gn = R.ring_vm_api_getnumber;
const rn = R.ring_vm_api_retnumber;
const rs2 = R.ring_vm_api_retstring2;

fn ring_format_number(p: *anyopaque) callconv(.c) void {
    const v = gn(p, 1);
    const d: i32 = @intFromFloat(gn(p, 2));
    var buf: [64]u8 = undefined;
    const len = display.format_number(v, d, &buf);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

fn ring_format_int_grouped(p: *anyopaque) callconv(.c) void {
    const v: i64 = @intFromFloat(gn(p, 1));
    const s: u8 = @intFromFloat(gn(p, 2));
    const g: i32 = @intFromFloat(gn(p, 3));
    var buf: [64]u8 = undefined;
    const len = display.format_int_grouped(v, s, g, &buf);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

fn ring_format_percent(p: *anyopaque) callconv(.c) void {
    const v = gn(p, 1);
    const d: i32 = @intFromFloat(gn(p, 2));
    var buf: [64]u8 = undefined;
    const len = display.format_percent(v, d, &buf);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

fn ring_format_bytes(p: *anyopaque) callconv(.c) void {
    const v: i64 = @intFromFloat(gn(p, 1));
    var buf: [64]u8 = undefined;
    const len = display.format_bytes_human(v, &buf);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

fn ring_bar_chart(p: *anyopaque) callconv(.c) void {
    const v = gn(p, 1);
    const m = gn(p, 2);
    const w: i32 = @intFromFloat(gn(p, 3));
    const f: u8 = @intFromFloat(gn(p, 4));
    const e: u8 = @intFromFloat(gn(p, 5));
    var buf: [4096]u8 = undefined;
    const len = display.bar_chart(v, m, w, f, e, &buf);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

fn ring_progress_bar(p: *anyopaque) callconv(.c) void {
    const c: i64 = @intFromFloat(gn(p, 1));
    const t: i64 = @intFromFloat(gn(p, 2));
    const w: i32 = @intFromFloat(gn(p, 3));
    var buf: [4096]u8 = undefined;
    const len = display.progress_bar(c, t, w, &buf);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

fn ring_tree_prefix(p: *anyopaque) callconv(.c) void {
    const d: i32 = @intFromFloat(gn(p, 1));
    const l: i32 = @intFromFloat(gn(p, 2));
    var buf: [256]u8 = undefined;
    const len = display.tree_prefix(d, l, &buf);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

fn ring_ruler(p: *anyopaque) callconv(.c) void {
    const w: i32 = @intFromFloat(gn(p, 1));
    const m: i32 = @intFromFloat(gn(p, 2));
    var buf: [4096]u8 = undefined;
    const len = display.ruler(w, m, &buf);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = "stzengine_display_format_number", .func = ring_format_number },
    .{ .name = "stzengine_display_format_int_grouped", .func = ring_format_int_grouped },
    .{ .name = "stzengine_display_format_percent", .func = ring_format_percent },
    .{ .name = "stzengine_display_format_bytes", .func = ring_format_bytes },
    .{ .name = "stzengine_display_bar_chart", .func = ring_bar_chart },
    .{ .name = "stzengine_display_progress_bar", .func = ring_progress_bar },
    .{ .name = "stzengine_display_tree_prefix", .func = ring_tree_prefix },
    .{ .name = "stzengine_display_ruler", .func = ring_ruler },
};
