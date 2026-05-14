// Per-domain entry point for stz_datetime.dll
// Bundles date + time + datetime (Tier 2) into one shared library.

pub const datetime = @import("datetime.zig");
pub const ring_bridge = @import("ring_bridge_datetime.zig");

comptime {
    // Date
    @export(&datetime.stz_date_new, .{ .name = "stz_date_new" });
    @export(&datetime.stz_date_today, .{ .name = "stz_date_today" });
    @export(&datetime.stz_date_free, .{ .name = "stz_date_free" });
    @export(&datetime.stz_date_year, .{ .name = "stz_date_year" });
    @export(&datetime.stz_date_month, .{ .name = "stz_date_month" });
    @export(&datetime.stz_date_day, .{ .name = "stz_date_day" });
    @export(&datetime.stz_date_day_of_week, .{ .name = "stz_date_day_of_week" });
    @export(&datetime.stz_date_day_of_year, .{ .name = "stz_date_day_of_year" });
    @export(&datetime.stz_date_days_in_month, .{ .name = "stz_date_days_in_month" });
    @export(&datetime.stz_date_days_in_year, .{ .name = "stz_date_days_in_year" });
    @export(&datetime.stz_date_is_leap_year, .{ .name = "stz_date_is_leap_year" });
    @export(&datetime.stz_date_add_days, .{ .name = "stz_date_add_days" });
    @export(&datetime.stz_date_diff_days, .{ .name = "stz_date_diff_days" });
    @export(&datetime.stz_date_to_string, .{ .name = "stz_date_to_string" });
    @export(&datetime.stz_date_to_iso, .{ .name = "stz_date_to_iso" });
    @export(&datetime.stz_date_format, .{ .name = "stz_date_format" });
    @export(&datetime.stz_date_compare, .{ .name = "stz_date_compare" });
    @export(&datetime.stz_date_day_name, .{ .name = "stz_date_day_name" });
    @export(&datetime.stz_date_month_name, .{ .name = "stz_date_month_name" });

    // Time
    @export(&datetime.stz_time_new, .{ .name = "stz_time_new" });
    @export(&datetime.stz_time_new_ms, .{ .name = "stz_time_new_ms" });
    @export(&datetime.stz_time_now, .{ .name = "stz_time_now" });
    @export(&datetime.stz_time_free, .{ .name = "stz_time_free" });
    @export(&datetime.stz_time_hour, .{ .name = "stz_time_hour" });
    @export(&datetime.stz_time_minute, .{ .name = "stz_time_minute" });
    @export(&datetime.stz_time_second, .{ .name = "stz_time_second" });
    @export(&datetime.stz_time_millisecond, .{ .name = "stz_time_millisecond" });
    @export(&datetime.stz_time_hour12, .{ .name = "stz_time_hour12" });
    @export(&datetime.stz_time_is_pm, .{ .name = "stz_time_is_pm" });
    @export(&datetime.stz_time_add_seconds, .{ .name = "stz_time_add_seconds" });
    @export(&datetime.stz_time_add_ms, .{ .name = "stz_time_add_ms" });
    @export(&datetime.stz_time_to_string, .{ .name = "stz_time_to_string" });
    @export(&datetime.stz_time_to_string_12h, .{ .name = "stz_time_to_string_12h" });
    @export(&datetime.stz_time_compare, .{ .name = "stz_time_compare" });

    // DateTime
    @export(&datetime.stz_datetime_new, .{ .name = "stz_datetime_new" });
    @export(&datetime.stz_datetime_now, .{ .name = "stz_datetime_now" });
    @export(&datetime.stz_datetime_from_unix, .{ .name = "stz_datetime_from_unix" });
    @export(&datetime.stz_datetime_free, .{ .name = "stz_datetime_free" });
    @export(&datetime.stz_datetime_year, .{ .name = "stz_datetime_year" });
    @export(&datetime.stz_datetime_month, .{ .name = "stz_datetime_month" });
    @export(&datetime.stz_datetime_day, .{ .name = "stz_datetime_day" });
    @export(&datetime.stz_datetime_hour, .{ .name = "stz_datetime_hour" });
    @export(&datetime.stz_datetime_minute, .{ .name = "stz_datetime_minute" });
    @export(&datetime.stz_datetime_second, .{ .name = "stz_datetime_second" });
    @export(&datetime.stz_datetime_add_days, .{ .name = "stz_datetime_add_days" });
    @export(&datetime.stz_datetime_add_seconds, .{ .name = "stz_datetime_add_seconds" });
    @export(&datetime.stz_datetime_to_unix, .{ .name = "stz_datetime_to_unix" });
    @export(&datetime.stz_datetime_to_iso, .{ .name = "stz_datetime_to_iso" });
    @export(&datetime.stz_datetime_compare, .{ .name = "stz_datetime_compare" });
    @export(&datetime.stz_datetime_is_between, .{ .name = "stz_datetime_is_between" });
}

comptime {
    @export(&ring_bridge.ringlib_init, .{ .name = "ringlib_init" });
}

test {
    _ = datetime;
}
