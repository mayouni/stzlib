// Softanza Engine -- the power substrate
//
// A Zig shared library providing string, unicode, datetime, file,
// locale, regex, and JSON operations via C ABI. Ring calls these
// through FFI; Zin links them directly.
//
// Tier 1: Strings + Unicode (replaces QString2 + QChar)
// Tier 2: DateTime + File + Locale (replaces QDate/QTime/QFile/QDir/QLocale)
// Tier 3: Regex + JSON + Bytes + URL + System

pub const string = @import("string.zig");
pub const char = @import("char.zig");
pub const unicode = @import("unicode.zig");
pub const datetime = @import("datetime.zig");
pub const file = @import("file.zig");
pub const locale = @import("locale.zig");
pub const regex = @import("regex.zig");
pub const bytes = @import("bytes.zig");
pub const json = @import("json.zig");
pub const url = @import("url.zig");
pub const system = @import("system.zig");

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
    @export(&string.stz_string_index_of_from, .{ .name = "stz_string_index_of_from" });
    @export(&string.stz_string_index_of_ci, .{ .name = "stz_string_index_of_ci" });
    @export(&string.stz_string_byte_to_cp, .{ .name = "stz_string_byte_to_cp" });
    @export(&string.stz_string_count_of, .{ .name = "stz_string_count_of" });
    @export(&string.stz_string_last_index_of, .{ .name = "stz_string_last_index_of" });
    @export(&string.stz_string_contains, .{ .name = "stz_string_contains" });
    @export(&string.stz_string_starts_with, .{ .name = "stz_string_starts_with" });
    @export(&string.stz_string_ends_with, .{ .name = "stz_string_ends_with" });
    @export(&string.stz_string_replace, .{ .name = "stz_string_replace" });
    @export(&string.stz_string_to_upper, .{ .name = "stz_string_to_upper" });
    @export(&string.stz_string_to_lower, .{ .name = "stz_string_to_lower" });
    @export(&string.stz_string_to_title, .{ .name = "stz_string_to_title" });
    @export(&string.stz_string_char_at, .{ .name = "stz_string_char_at" });
    @export(&string.stz_string_mid_cp, .{ .name = "stz_string_mid_cp" });
    @export(&string.stz_string_left_cp, .{ .name = "stz_string_left_cp" });
    @export(&string.stz_string_right_cp, .{ .name = "stz_string_right_cp" });
    @export(&string.stz_string_insert_cp, .{ .name = "stz_string_insert_cp" });
    @export(&string.stz_string_grapheme_count, .{ .name = "stz_string_grapheme_count" });
    @export(&string.stz_string_normalize, .{ .name = "stz_string_normalize" });
    @export(&string.stz_string_strip_marks, .{ .name = "stz_string_strip_marks" });

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

    // ─── Tier 3: Regex operations ───
    @export(&regex.stz_regex_new, .{ .name = "stz_regex_new" });
    @export(&regex.stz_regex_free, .{ .name = "stz_regex_free" });
    @export(&regex.stz_regex_match, .{ .name = "stz_regex_match" });
    @export(&regex.stz_regex_match_all, .{ .name = "stz_regex_match_all" });
    @export(&regex.stz_regex_has_match, .{ .name = "stz_regex_has_match" });
    @export(&regex.stz_regex_capture_count, .{ .name = "stz_regex_capture_count" });
    @export(&regex.stz_regex_capture_start, .{ .name = "stz_regex_capture_start" });
    @export(&regex.stz_regex_capture_end, .{ .name = "stz_regex_capture_end" });
    @export(&regex.stz_regex_capture_text, .{ .name = "stz_regex_capture_text" });
    @export(&regex.stz_regex_replace, .{ .name = "stz_regex_replace" });
    @export(&regex.stz_regex_replace_free, .{ .name = "stz_regex_replace_free" });
    @export(&regex.stz_regex_set_limits, .{ .name = "stz_regex_set_limits" });

    // ─── Tier 3: Bytes operations ───
    @export(&bytes.stz_bytes_new, .{ .name = "stz_bytes_new" });
    @export(&bytes.stz_bytes_from, .{ .name = "stz_bytes_from" });
    @export(&bytes.stz_bytes_free, .{ .name = "stz_bytes_free" });
    @export(&bytes.stz_bytes_data, .{ .name = "stz_bytes_data" });
    @export(&bytes.stz_bytes_size, .{ .name = "stz_bytes_size" });
    @export(&bytes.stz_bytes_is_empty, .{ .name = "stz_bytes_is_empty" });
    @export(&bytes.stz_bytes_clear, .{ .name = "stz_bytes_clear" });
    @export(&bytes.stz_bytes_append, .{ .name = "stz_bytes_append" });
    @export(&bytes.stz_bytes_at, .{ .name = "stz_bytes_at" });
    @export(&bytes.stz_bytes_insert, .{ .name = "stz_bytes_insert" });
    @export(&bytes.stz_bytes_remove, .{ .name = "stz_bytes_remove" });
    @export(&bytes.stz_bytes_left, .{ .name = "stz_bytes_left" });
    @export(&bytes.stz_bytes_right, .{ .name = "stz_bytes_right" });
    @export(&bytes.stz_bytes_mid, .{ .name = "stz_bytes_mid" });
    @export(&bytes.stz_bytes_fill, .{ .name = "stz_bytes_fill" });
    @export(&bytes.stz_bytes_replace, .{ .name = "stz_bytes_replace" });
    @export(&bytes.stz_bytes_resize, .{ .name = "stz_bytes_resize" });
    @export(&bytes.stz_bytes_to_lower, .{ .name = "stz_bytes_to_lower" });
    @export(&bytes.stz_bytes_to_upper, .{ .name = "stz_bytes_to_upper" });
    @export(&bytes.stz_bytes_to_base64, .{ .name = "stz_bytes_to_base64" });
    @export(&bytes.stz_bytes_from_base64, .{ .name = "stz_bytes_from_base64" });
    @export(&bytes.stz_bytes_to_hex, .{ .name = "stz_bytes_to_hex" });
    @export(&bytes.stz_bytes_from_hex, .{ .name = "stz_bytes_from_hex" });
    @export(&bytes.stz_bytes_to_percent, .{ .name = "stz_bytes_to_percent" });
    @export(&bytes.stz_bytes_from_percent, .{ .name = "stz_bytes_from_percent" });

    // ─── Tier 3: JSON operations ───
    @export(&json.stz_json_parse, .{ .name = "stz_json_parse" });
    @export(&json.stz_json_free, .{ .name = "stz_json_free" });
    @export(&json.stz_json_is_valid, .{ .name = "stz_json_is_valid" });
    @export(&json.stz_json_is_array, .{ .name = "stz_json_is_array" });
    @export(&json.stz_json_size, .{ .name = "stz_json_size" });
    @export(&json.stz_json_has_key, .{ .name = "stz_json_has_key" });
    @export(&json.stz_json_get_string, .{ .name = "stz_json_get_string" });
    @export(&json.stz_json_get_int, .{ .name = "stz_json_get_int" });
    @export(&json.stz_json_get_bool, .{ .name = "stz_json_get_bool" });
    @export(&json.stz_json_array_at_string, .{ .name = "stz_json_array_at_string" });
    @export(&json.stz_json_array_at_int, .{ .name = "stz_json_array_at_int" });
    @export(&json.stz_json_to_string, .{ .name = "stz_json_to_string" });
    @export(&json.stz_json_to_string_pretty, .{ .name = "stz_json_to_string_pretty" });
    @export(&json.stz_json_string_free, .{ .name = "stz_json_string_free" });
    @export(&json.stz_json_keys, .{ .name = "stz_json_keys" });
    @export(&json.stz_json_error, .{ .name = "stz_json_error" });

    // ─── Tier 3: URL operations ───
    @export(&url.stz_url_parse, .{ .name = "stz_url_parse" });
    @export(&url.stz_url_free, .{ .name = "stz_url_free" });
    @export(&url.stz_url_is_valid, .{ .name = "stz_url_is_valid" });
    @export(&url.stz_url_scheme, .{ .name = "stz_url_scheme" });
    @export(&url.stz_url_host, .{ .name = "stz_url_host" });
    @export(&url.stz_url_port, .{ .name = "stz_url_port" });
    @export(&url.stz_url_path, .{ .name = "stz_url_path" });
    @export(&url.stz_url_query, .{ .name = "stz_url_query" });
    @export(&url.stz_url_fragment, .{ .name = "stz_url_fragment" });
    @export(&url.stz_url_user, .{ .name = "stz_url_user" });
    @export(&url.stz_url_password, .{ .name = "stz_url_password" });
    @export(&url.stz_url_reconstruct, .{ .name = "stz_url_reconstruct" });

    // ─── Tier 1: Unicode operations (utf8proc) ───
    @export(&unicode.stz_unicode_category, .{ .name = "stz_unicode_category" });
    @export(&unicode.stz_unicode_category_string, .{ .name = "stz_unicode_category_string" });
    @export(&unicode.stz_unicode_is_letter, .{ .name = "stz_unicode_is_letter" });
    @export(&unicode.stz_unicode_is_digit, .{ .name = "stz_unicode_is_digit" });
    @export(&unicode.stz_unicode_is_number, .{ .name = "stz_unicode_is_number" });
    @export(&unicode.stz_unicode_is_upper, .{ .name = "stz_unicode_is_upper" });
    @export(&unicode.stz_unicode_is_lower, .{ .name = "stz_unicode_is_lower" });
    @export(&unicode.stz_unicode_is_space, .{ .name = "stz_unicode_is_space" });
    @export(&unicode.stz_unicode_is_punctuation, .{ .name = "stz_unicode_is_punctuation" });
    @export(&unicode.stz_unicode_is_symbol, .{ .name = "stz_unicode_is_symbol" });
    @export(&unicode.stz_unicode_is_mark, .{ .name = "stz_unicode_is_mark" });
    @export(&unicode.stz_unicode_is_control, .{ .name = "stz_unicode_is_control" });
    @export(&unicode.stz_unicode_is_valid, .{ .name = "stz_unicode_is_valid" });
    @export(&unicode.stz_unicode_bidi_class, .{ .name = "stz_unicode_bidi_class" });
    @export(&unicode.stz_unicode_charwidth, .{ .name = "stz_unicode_charwidth" });
    @export(&unicode.stz_unicode_to_lower, .{ .name = "stz_unicode_to_lower" });
    @export(&unicode.stz_unicode_to_upper, .{ .name = "stz_unicode_to_upper" });
    @export(&unicode.stz_unicode_to_title, .{ .name = "stz_unicode_to_title" });
    @export(&unicode.stz_unicode_to_lower_str, .{ .name = "stz_unicode_to_lower_str" });
    @export(&unicode.stz_unicode_to_upper_str, .{ .name = "stz_unicode_to_upper_str" });
    @export(&unicode.stz_unicode_to_title_str, .{ .name = "stz_unicode_to_title_str" });
    @export(&unicode.stz_unicode_normalize, .{ .name = "stz_unicode_normalize" });
    @export(&unicode.stz_unicode_normalize_free, .{ .name = "stz_unicode_normalize_free" });
    @export(&unicode.stz_unicode_casefold, .{ .name = "stz_unicode_casefold" });
    @export(&unicode.stz_unicode_casefold_free, .{ .name = "stz_unicode_casefold_free" });
    @export(&unicode.stz_unicode_strip_marks, .{ .name = "stz_unicode_strip_marks" });
    @export(&unicode.stz_unicode_strip_marks_free, .{ .name = "stz_unicode_strip_marks_free" });
    @export(&unicode.stz_unicode_grapheme_count, .{ .name = "stz_unicode_grapheme_count" });
    @export(&unicode.stz_unicode_grapheme_break, .{ .name = "stz_unicode_grapheme_break" });
    @export(&unicode.stz_unicode_iterate, .{ .name = "stz_unicode_iterate" });
    @export(&unicode.stz_unicode_cp_byte_len, .{ .name = "stz_unicode_cp_byte_len" });
    @export(&unicode.stz_unicode_encode, .{ .name = "stz_unicode_encode" });
    @export(&unicode.stz_unicode_cp_to_byte, .{ .name = "stz_unicode_cp_to_byte" });
    @export(&unicode.stz_unicode_byte_to_cp, .{ .name = "stz_unicode_byte_to_cp" });

    // ─── Tier 3: System operations ───
    @export(&system.stz_system_run, .{ .name = "stz_system_run" });
    @export(&system.stz_system_run_free, .{ .name = "stz_system_run_free" });
    @export(&system.stz_system_exec, .{ .name = "stz_system_exec" });
    @export(&system.stz_system_env, .{ .name = "stz_system_env" });
    @export(&system.stz_system_is_windows, .{ .name = "stz_system_is_windows" });
    @export(&system.stz_system_is_linux, .{ .name = "stz_system_is_linux" });
    @export(&system.stz_system_is_macos, .{ .name = "stz_system_is_macos" });
}

// Version -- bumped for Unicode
pub export fn stz_engine_version() callconv(.c) u32 {
    return 0x00_05_00_00; // 0.5.0.0
}

test {
    _ = string;
    _ = char;
    _ = unicode;
    _ = datetime;
    _ = file;
    _ = locale;
    _ = regex;
    _ = bytes;
    _ = json;
    _ = url;
    _ = system;
}
