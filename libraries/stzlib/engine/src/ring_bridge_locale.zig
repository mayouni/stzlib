const loc = @import("locale.zig");
const R = @import("ring_api.zig");

const g = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring;
const rs2 = R.ring_vm_api_retstring2;

fn ring_AmText(p: *anyopaque) callconv(.c) void {
    var buf: [8]u8 = undefined;
    const n = loc.stz_locale_am_text(&buf, 8);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_PmText(p: *anyopaque) callconv(.c) void {
    var buf: [8]u8 = undefined;
    const n = loc.stz_locale_pm_text(&buf, 8);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_ToUpper(p: *anyopaque) callconv(.c) void {
    var buf: [4096]u8 = undefined;
    const n = loc.stz_locale_to_upper(gs(p, 1), @intCast(gss(p, 1)), &buf, 4096);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_ToLower(p: *anyopaque) callconv(.c) void {
    var buf: [4096]u8 = undefined;
    const n = loc.stz_locale_to_lower(gs(p, 1), @intCast(gss(p, 1)), &buf, 4096);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_ToTitlecase(p: *anyopaque) callconv(.c) void {
    var buf: [4096]u8 = undefined;
    const n = loc.stz_locale_to_titlecase(gs(p, 1), @intCast(gss(p, 1)), &buf, 4096);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_FormatNumber(p: *anyopaque) callconv(.c) void {
    var buf: [64]u8 = undefined;
    const n = loc.stz_locale_format_number(g(p, 1), @intFromFloat(g(p, 2)), &buf, 64);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_MonthName(p: *anyopaque) callconv(.c) void {
    var buf: [32]u8 = undefined;
    const n = loc.stz_locale_month_name(@intFromFloat(g(p, 1)), &buf, 32);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_MonthAbbr(p: *anyopaque) callconv(.c) void {
    var buf: [16]u8 = undefined;
    const n = loc.stz_locale_month_abbr(@intFromFloat(g(p, 1)), &buf, 16);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_DayName(p: *anyopaque) callconv(.c) void {
    var buf: [32]u8 = undefined;
    const n = loc.stz_locale_day_name(@intFromFloat(g(p, 1)), &buf, 32);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_DayAbbr(p: *anyopaque) callconv(.c) void {
    var buf: [16]u8 = undefined;
    const n = loc.stz_locale_day_abbr(@intFromFloat(g(p, 1)), &buf, 16);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}

pub const regs = [_]R.Reg{
    .{ .name = "stzenginelocaleamtext", .func = &ring_AmText },
    .{ .name = "stzenginelocalepmtext", .func = &ring_PmText },
    .{ .name = "stzenginelocaletoupper", .func = &ring_ToUpper },
    .{ .name = "stzenginelocaletolower", .func = &ring_ToLower },
    .{ .name = "stzenginelocaletotitlecase", .func = &ring_ToTitlecase },
    .{ .name = "stzenginelocaleformatnumber", .func = &ring_FormatNumber },
    .{ .name = "stzenginelocalemonthname", .func = &ring_MonthName },
    .{ .name = "stzenginelocalemonthabbr", .func = &ring_MonthAbbr },
    .{ .name = "stzenginelocaledayname", .func = &ring_DayName },
    .{ .name = "stzenginelocaledayabbr", .func = &ring_DayAbbr },
};

pub fn ringlib_init(pRingState: ?*anyopaque) callconv(.c) void {
    if (pRingState) |state| R.registerAll(state, &regs);
}
