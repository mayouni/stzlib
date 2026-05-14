const dt = @import("datetime.zig");
const R = @import("ring_api.zig");

const g = R.ring_vm_api_getnumber;
const gcp = R.ring_vm_api_getcpointer;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring;
const rs2 = R.ring_vm_api_retstring2;
const rcp = R.ring_vm_api_retcpointer;

const DH: [*:0]const u8 = "StzDateHandle";
const TH: [*:0]const u8 = "StzTimeHandle";
const DTH: [*:0]const u8 = "StzDateTimeHandle";

fn getD(p: *anyopaque, n: c_int) dt.StzDateHandle {
    const ptr = gcp(p, n, DH);
    if (ptr) |raw| return @ptrCast(@alignCast(raw));
    return null;
}
fn getT(p: *anyopaque, n: c_int) dt.StzTimeHandle {
    const ptr = gcp(p, n, TH);
    if (ptr) |raw| return @ptrCast(@alignCast(raw));
    return null;
}
fn getDT(p: *anyopaque, n: c_int) dt.StzDateTimeHandle {
    const ptr = gcp(p, n, DTH);
    if (ptr) |raw| return @ptrCast(@alignCast(raw));
    return null;
}

// ─── Date ───
fn ring_DateNew(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(dt.stz_date_new(@intFromFloat(g(p, 1)), @intFromFloat(g(p, 2)), @intFromFloat(g(p, 3)))), DH);
}
fn ring_DateToday(p: *anyopaque) callconv(.c) void { rcp(p, @ptrCast(dt.stz_date_today()), DH); }
fn ring_DateFree(p: *anyopaque) callconv(.c) void { dt.stz_date_free(getD(p, 1)); }
fn ring_DateYear(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(dt.stz_date_year(getD(p, 1)))); }
fn ring_DateMonth(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(dt.stz_date_month(getD(p, 1)))); }
fn ring_DateDay(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(dt.stz_date_day(getD(p, 1)))); }
fn ring_DateDayOfWeek(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(dt.stz_date_day_of_week(getD(p, 1)))); }
fn ring_DateDayOfYear(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(dt.stz_date_day_of_year(getD(p, 1)))); }
fn ring_DateDaysInMonth(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(dt.stz_date_days_in_month(getD(p, 1)))); }
fn ring_DateDaysInYear(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(dt.stz_date_days_in_year(getD(p, 1)))); }
fn ring_DateIsLeapYear(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(dt.stz_date_is_leap_year(getD(p, 1)))); }
fn ring_DateAddDays(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(dt.stz_date_add_days(getD(p, 1), @intFromFloat(g(p, 2)))), DH);
}
fn ring_DateDiffDays(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(dt.stz_date_diff_days(getD(p, 1), getD(p, 2))));
}
fn ring_DateToString(p: *anyopaque) callconv(.c) void {
    var buf: [64]u8 = undefined;
    const n = dt.stz_date_to_string(getD(p, 1), &buf, 64);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_DateToIso(p: *anyopaque) callconv(.c) void {
    var buf: [32]u8 = undefined;
    const n = dt.stz_date_to_iso(getD(p, 1), &buf, 32);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_DateFormat(p: *anyopaque) callconv(.c) void {
    var buf: [256]u8 = undefined;
    const fmt = R.ring_vm_api_getstring(p, 2);
    const fmt_len: usize = @intCast(R.ring_vm_api_getstringsize(p, 2));
    const n = dt.stz_date_format(getD(p, 1), fmt, fmt_len, &buf, 256);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_DateCompare(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(dt.stz_date_compare(getD(p, 1), getD(p, 2))));
}
fn ring_DateDayName(p: *anyopaque) callconv(.c) void {
    var buf: [32]u8 = undefined;
    const n = dt.stz_date_day_name(getD(p, 1), &buf, 32);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_DateMonthName(p: *anyopaque) callconv(.c) void {
    var buf: [32]u8 = undefined;
    const n = dt.stz_date_month_name(getD(p, 1), &buf, 32);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}

// ─── Time ───
fn ring_TimeNew(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(dt.stz_time_new(@intFromFloat(g(p, 1)), @intFromFloat(g(p, 2)), @intFromFloat(g(p, 3)))), TH);
}
fn ring_TimeNewMs(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(dt.stz_time_new_ms(@intFromFloat(g(p, 1)), @intFromFloat(g(p, 2)), @intFromFloat(g(p, 3)), @intFromFloat(g(p, 4)))), TH);
}
fn ring_TimeNow(p: *anyopaque) callconv(.c) void { rcp(p, @ptrCast(dt.stz_time_now()), TH); }
fn ring_TimeFree(p: *anyopaque) callconv(.c) void { dt.stz_time_free(getT(p, 1)); }
fn ring_TimeHour(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(dt.stz_time_hour(getT(p, 1)))); }
fn ring_TimeMinute(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(dt.stz_time_minute(getT(p, 1)))); }
fn ring_TimeSecond(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(dt.stz_time_second(getT(p, 1)))); }
fn ring_TimeMillisecond(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(dt.stz_time_millisecond(getT(p, 1)))); }
fn ring_TimeHour12(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(dt.stz_time_hour12(getT(p, 1)))); }
fn ring_TimeIsPm(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(dt.stz_time_is_pm(getT(p, 1)))); }
fn ring_TimeAddSeconds(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(dt.stz_time_add_seconds(getT(p, 1), @intFromFloat(g(p, 2)))), TH);
}
fn ring_TimeAddMs(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(dt.stz_time_add_ms(getT(p, 1), @intFromFloat(g(p, 2)))), TH);
}
fn ring_TimeToString(p: *anyopaque) callconv(.c) void {
    var buf: [32]u8 = undefined;
    const n = dt.stz_time_to_string(getT(p, 1), &buf, 32);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_TimeToString12h(p: *anyopaque) callconv(.c) void {
    var buf: [32]u8 = undefined;
    const n = dt.stz_time_to_string_12h(getT(p, 1), &buf, 32);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_TimeCompare(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(dt.stz_time_compare(getT(p, 1), getT(p, 2))));
}

// ─── DateTime ───
fn ring_DTNew(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(dt.stz_datetime_new(@intFromFloat(g(p, 1)), @intFromFloat(g(p, 2)), @intFromFloat(g(p, 3)), @intFromFloat(g(p, 4)), @intFromFloat(g(p, 5)), @intFromFloat(g(p, 6)))), DTH);
}
fn ring_DTNow(p: *anyopaque) callconv(.c) void { rcp(p, @ptrCast(dt.stz_datetime_now()), DTH); }
fn ring_DTFromUnix(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(dt.stz_datetime_from_unix(@intFromFloat(g(p, 1)))), DTH);
}
fn ring_DTFree(p: *anyopaque) callconv(.c) void { dt.stz_datetime_free(getDT(p, 1)); }
fn ring_DTYear(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(dt.stz_datetime_year(getDT(p, 1)))); }
fn ring_DTMonth(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(dt.stz_datetime_month(getDT(p, 1)))); }
fn ring_DTDay(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(dt.stz_datetime_day(getDT(p, 1)))); }
fn ring_DTHour(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(dt.stz_datetime_hour(getDT(p, 1)))); }
fn ring_DTMinute(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(dt.stz_datetime_minute(getDT(p, 1)))); }
fn ring_DTSecond(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(dt.stz_datetime_second(getDT(p, 1)))); }
fn ring_DTAddDays(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(dt.stz_datetime_add_days(getDT(p, 1), @intFromFloat(g(p, 2)))), DTH);
}
fn ring_DTAddSeconds(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(dt.stz_datetime_add_seconds(getDT(p, 1), @intFromFloat(g(p, 2)))), DTH);
}
fn ring_DTToUnix(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(dt.stz_datetime_to_unix(getDT(p, 1))));
}
fn ring_DTToIso(p: *anyopaque) callconv(.c) void {
    var buf: [64]u8 = undefined;
    const n = dt.stz_datetime_to_iso(getDT(p, 1), &buf, 64);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_DTCompare(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(dt.stz_datetime_compare(getDT(p, 1), getDT(p, 2))));
}
fn ring_DTIsBetween(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(dt.stz_datetime_is_between(getDT(p, 1), getDT(p, 2), getDT(p, 3))));
}

pub const regs = [_]R.Reg{
    .{ .name = "stzenginedatenew", .func = &ring_DateNew },
    .{ .name = "stzenginedatetoday", .func = &ring_DateToday },
    .{ .name = "stzenginedatefree", .func = &ring_DateFree },
    .{ .name = "stzenginedateyear", .func = &ring_DateYear },
    .{ .name = "stzenginedatemonth", .func = &ring_DateMonth },
    .{ .name = "stzenginedateday", .func = &ring_DateDay },
    .{ .name = "stzenginedatedayofweek", .func = &ring_DateDayOfWeek },
    .{ .name = "stzenginedatedayofyear", .func = &ring_DateDayOfYear },
    .{ .name = "stzenginedatedaysinmonth", .func = &ring_DateDaysInMonth },
    .{ .name = "stzenginedatedaysinyear", .func = &ring_DateDaysInYear },
    .{ .name = "stzenginedateisleapyear", .func = &ring_DateIsLeapYear },
    .{ .name = "stzenginedateadddays", .func = &ring_DateAddDays },
    .{ .name = "stzenginedatediffdays", .func = &ring_DateDiffDays },
    .{ .name = "stzenginedatetostring", .func = &ring_DateToString },
    .{ .name = "stzenginedatetoiso", .func = &ring_DateToIso },
    .{ .name = "stzenginedateformat", .func = &ring_DateFormat },
    .{ .name = "stzenginedatecompare", .func = &ring_DateCompare },
    .{ .name = "stzenginedatedayname", .func = &ring_DateDayName },
    .{ .name = "stzenginedatemonthname", .func = &ring_DateMonthName },
    .{ .name = "stzenginetimenew", .func = &ring_TimeNew },
    .{ .name = "stzenginetimenewms", .func = &ring_TimeNewMs },
    .{ .name = "stzenginetimenow", .func = &ring_TimeNow },
    .{ .name = "stzenginetimefree", .func = &ring_TimeFree },
    .{ .name = "stzenginetimehour", .func = &ring_TimeHour },
    .{ .name = "stzenginetimeminute", .func = &ring_TimeMinute },
    .{ .name = "stzenginetimesecond", .func = &ring_TimeSecond },
    .{ .name = "stzenginetimemillisecond", .func = &ring_TimeMillisecond },
    .{ .name = "stzenginetimehour12", .func = &ring_TimeHour12 },
    .{ .name = "stzenginetimeispm", .func = &ring_TimeIsPm },
    .{ .name = "stzenginetimeaddseconds", .func = &ring_TimeAddSeconds },
    .{ .name = "stzenginetimeaddms", .func = &ring_TimeAddMs },
    .{ .name = "stzenginetimetostring", .func = &ring_TimeToString },
    .{ .name = "stzenginetimetostring12h", .func = &ring_TimeToString12h },
    .{ .name = "stzenginetimecompare", .func = &ring_TimeCompare },
    .{ .name = "stzenginedatetimenew", .func = &ring_DTNew },
    .{ .name = "stzenginedatetimenow", .func = &ring_DTNow },
    .{ .name = "stzenginedatetimefromunix", .func = &ring_DTFromUnix },
    .{ .name = "stzenginedatetimefree", .func = &ring_DTFree },
    .{ .name = "stzenginedatetimeyear", .func = &ring_DTYear },
    .{ .name = "stzenginedatetimemonth", .func = &ring_DTMonth },
    .{ .name = "stzenginedatetimeday", .func = &ring_DTDay },
    .{ .name = "stzenginedatetimehour", .func = &ring_DTHour },
    .{ .name = "stzenginedatetimeminute", .func = &ring_DTMinute },
    .{ .name = "stzenginedatetimesecond", .func = &ring_DTSecond },
    .{ .name = "stzenginedatetimeadddays", .func = &ring_DTAddDays },
    .{ .name = "stzenginedatetimeaddseconds", .func = &ring_DTAddSeconds },
    .{ .name = "stzenginedatetimetounix", .func = &ring_DTToUnix },
    .{ .name = "stzenginedatetimetoiso", .func = &ring_DTToIso },
    .{ .name = "stzenginedatetimecompare", .func = &ring_DTCompare },
    .{ .name = "stzenginedatetimeisbetween", .func = &ring_DTIsBetween },
};

pub fn ringlib_init(pRingState: ?*anyopaque) callconv(.c) void {
    if (pRingState) |state| R.registerAll(state, &regs);
}
