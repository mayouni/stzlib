// Softanza Engine -- the power substrate
//
// A Zig shared library providing string, unicode, datetime, file,
// locale, regex, and JSON operations via C ABI. Ring calls these
// through FFI; Zin links them directly.
//
// Tier 1: Strings + Unicode (replaces QString2 + QChar)
// Tier 2: DateTime + File + Locale (replaces QDate/QTime/QFile/QDir/QLocale)
// Tier 3: Regex + JSON (future)

pub const string = @import("string.zig");
pub const char = @import("char.zig");
pub const datetime = @import("datetime.zig");
pub const file = @import("file.zig");
pub const locale = @import("locale.zig");

// Re-export C ABI symbols
comptime {
    // ─── Tier 1: String operations ───
    @export(&string.stz_string_new, .{ .name = "stz_string_new" });
    @export(&string.stz_string_from, .{ .name = "stz_string_from" });
    @export(&string.stz_string_free, .{ .name = "stz_string_free" });
    @export(&string.stz_string_data, .{ .name = "stz_string_data" });
    @export(&string.stz_string_size, .{ .name = "stz_string_size" });
    @export(&string.stz_string_count, .{ .name = "stz_string_count" });
    @export(&string.stz_string_append, .{ .name = "stz_string_append" });
    @export(&string.stz_string_insert, .{ .name = "stz_string_insert" });
    @export(&string.stz_string_mid, .{ .name = "stz_string_mid" });
    @export(&string.stz_string_left, .{ .name = "stz_string_left" });
    @export(&string.stz_string_right, .{ .name = "stz_string_right" });
    @export(&string.stz_string_trimmed, .{ .name = "stz_string_trimmed" });
    @export(&string.stz_string_index_of, .{ .name = "stz_string_index_of" });
    @export(&string.stz_string_last_index_of, .{ .name = "stz_string_last_index_of" });
    @export(&string.stz_string_contains, .{ .name = "stz_string_contains" });
    @export(&string.stz_string_starts_with, .{ .name = "stz_string_starts_with" });
    @export(&string.stz_string_ends_with, .{ .name = "stz_string_ends_with" });
    @export(&string.stz_string_replace, .{ .name = "stz_string_replace" });
    @export(&string.stz_string_to_upper, .{ .name = "stz_string_to_upper" });
    @export(&string.stz_string_to_lower, .{ .name = "stz_string_to_lower" });

    // ─── Tier 1: Unicode character operations ───
    @export(&char.stz_char_unicode, .{ .name = "stz_char_unicode" });
    @export(&char.stz_char_to_utf8, .{ .name = "stz_char_to_utf8" });
    @export(&char.stz_char_is_letter, .{ .name = "stz_char_is_letter" });
    @export(&char.stz_char_is_digit, .{ .name = "stz_char_is_digit" });
    @export(&char.stz_char_is_upper, .{ .name = "stz_char_is_upper" });
    @export(&char.stz_char_is_lower, .{ .name = "stz_char_is_lower" });

    // ─── Tier 2: Date operations ───
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

    // ─── Tier 2: Time operations ───
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

    // ─── Tier 2: DateTime operations ───
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

    // ─── Tier 2: File operations ───
    @export(&file.stz_file_exists, .{ .name = "stz_file_exists" });
    @export(&file.stz_file_size, .{ .name = "stz_file_size" });
    @export(&file.stz_file_read, .{ .name = "stz_file_read" });
    @export(&file.stz_file_read_free, .{ .name = "stz_file_read_free" });
    @export(&file.stz_file_write, .{ .name = "stz_file_write" });
    @export(&file.stz_file_append, .{ .name = "stz_file_append" });
    @export(&file.stz_file_delete, .{ .name = "stz_file_delete" });
    @export(&file.stz_file_copy, .{ .name = "stz_file_copy" });
    @export(&file.stz_dir_exists, .{ .name = "stz_dir_exists" });
    @export(&file.stz_dir_create, .{ .name = "stz_dir_create" });
    @export(&file.stz_dir_create_path, .{ .name = "stz_dir_create_path" });
    @export(&file.stz_dir_delete, .{ .name = "stz_dir_delete" });
    @export(&file.stz_dir_count_files, .{ .name = "stz_dir_count_files" });
    @export(&file.stz_dir_count_dirs, .{ .name = "stz_dir_count_dirs" });
    @export(&file.stz_path_extension, .{ .name = "stz_path_extension" });
    @export(&file.stz_path_basename, .{ .name = "stz_path_basename" });
    @export(&file.stz_path_dirname, .{ .name = "stz_path_dirname" });

    // ─── Tier 2: Locale operations ───
    @export(&locale.stz_locale_am_text, .{ .name = "stz_locale_am_text" });
    @export(&locale.stz_locale_pm_text, .{ .name = "stz_locale_pm_text" });
    @export(&locale.stz_locale_to_upper, .{ .name = "stz_locale_to_upper" });
    @export(&locale.stz_locale_to_lower, .{ .name = "stz_locale_to_lower" });
    @export(&locale.stz_locale_to_titlecase, .{ .name = "stz_locale_to_titlecase" });
    @export(&locale.stz_locale_format_number, .{ .name = "stz_locale_format_number" });
    @export(&locale.stz_locale_month_name, .{ .name = "stz_locale_month_name" });
    @export(&locale.stz_locale_month_abbr, .{ .name = "stz_locale_month_abbr" });
    @export(&locale.stz_locale_day_name, .{ .name = "stz_locale_day_name" });
    @export(&locale.stz_locale_day_abbr, .{ .name = "stz_locale_day_abbr" });
}

// Version -- bumped for Tier 2
pub export fn stz_engine_version() callconv(.c) u32 {
    return 0x00_02_00_00; // 0.2.0.0
}

test {
    _ = string;
    _ = char;
    _ = datetime;
    _ = file;
    _ = locale;
}
