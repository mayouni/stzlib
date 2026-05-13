// Core entry point for stk_datetime.dll
// Minimal date/time/datetime: lifecycle, components, compare.
// Base (stz_datetime.dll) is a strict superset of this.

pub const datetime = @import("datetime.zig");

comptime {
    // Date lifecycle + components + compare
    @export(&datetime.stz_date_new, .{ .name = "stz_date_new" });
    @export(&datetime.stz_date_today, .{ .name = "stz_date_today" });
    @export(&datetime.stz_date_free, .{ .name = "stz_date_free" });
    @export(&datetime.stz_date_year, .{ .name = "stz_date_year" });
    @export(&datetime.stz_date_month, .{ .name = "stz_date_month" });
    @export(&datetime.stz_date_day, .{ .name = "stz_date_day" });
    @export(&datetime.stz_date_compare, .{ .name = "stz_date_compare" });

    // Time lifecycle + components + compare
    @export(&datetime.stz_time_new, .{ .name = "stz_time_new" });
    @export(&datetime.stz_time_now, .{ .name = "stz_time_now" });
    @export(&datetime.stz_time_free, .{ .name = "stz_time_free" });
    @export(&datetime.stz_time_hour, .{ .name = "stz_time_hour" });
    @export(&datetime.stz_time_minute, .{ .name = "stz_time_minute" });
    @export(&datetime.stz_time_second, .{ .name = "stz_time_second" });
    @export(&datetime.stz_time_compare, .{ .name = "stz_time_compare" });

    // DateTime lifecycle + components + compare
    @export(&datetime.stz_datetime_new, .{ .name = "stz_datetime_new" });
    @export(&datetime.stz_datetime_now, .{ .name = "stz_datetime_now" });
    @export(&datetime.stz_datetime_free, .{ .name = "stz_datetime_free" });
    @export(&datetime.stz_datetime_year, .{ .name = "stz_datetime_year" });
    @export(&datetime.stz_datetime_month, .{ .name = "stz_datetime_month" });
    @export(&datetime.stz_datetime_day, .{ .name = "stz_datetime_day" });
    @export(&datetime.stz_datetime_hour, .{ .name = "stz_datetime_hour" });
    @export(&datetime.stz_datetime_minute, .{ .name = "stz_datetime_minute" });
    @export(&datetime.stz_datetime_second, .{ .name = "stz_datetime_second" });
    @export(&datetime.stz_datetime_compare, .{ .name = "stz_datetime_compare" });
}

test {
    _ = datetime;
}
