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
pub const meta = @import("meta.zig");
pub const named_params = @import("named_params.zig");
pub const method_gen = @import("method_gen.zig");
pub const error_catalog = @import("error_catalog.zig");
pub const value = @import("value.zig");
pub const number = @import("number.zig");
pub const list = @import("list.zig");
pub const hashmap = @import("hashmap.zig");
pub const unicode_data = @import("unicode_data.zig");

// Re-export C ABI symbols
comptime {
    // ─── Error reporting ───
    @export(&string.str_last_error, .{ .name = "str_last_error" });
    @export(&string.str_clear_error, .{ .name = "str_clear_error" });
    // ─── Tier 1: String operations ───
    @export(&string.str_new, .{ .name = "str_new" });
    @export(&string.str_from, .{ .name = "str_from" });
    @export(&string.str_free, .{ .name = "str_free" });
    @export(&string.str_data, .{ .name = "str_data" });
    @export(&string.str_size, .{ .name = "str_size" });
    @export(&string.str_count, .{ .name = "str_count" });
    @export(&string.str_append, .{ .name = "str_append" });
    @export(&string.str_insert, .{ .name = "str_insert" });
    @export(&string.str_mid, .{ .name = "str_mid" });
    @export(&string.str_left, .{ .name = "str_left" });
    @export(&string.str_right, .{ .name = "str_right" });
    @export(&string.str_trimmed, .{ .name = "str_trimmed" });
    @export(&string.str_index_of, .{ .name = "str_index_of" });
    @export(&string.str_index_of_from, .{ .name = "str_index_of_from" });
    @export(&string.str_byte_to_cp, .{ .name = "str_byte_to_cp" });
    @export(&string.str_count_of, .{ .name = "str_count_of" });
    @export(&string.str_replace_range, .{ .name = "str_replace_range" });
    @export(&string.str_split_count, .{ .name = "str_split_count" });
    @export(&string.str_split_get, .{ .name = "str_split_get" });
    @export(&string.str_last_index_of, .{ .name = "str_last_index_of" });
    @export(&string.str_contains, .{ .name = "str_contains" });
    @export(&string.str_starts_with, .{ .name = "str_starts_with" });
    @export(&string.str_ends_with, .{ .name = "str_ends_with" });
    @export(&string.str_replace, .{ .name = "str_replace" });
    @export(&string.str_to_upper, .{ .name = "str_to_upper" });
    @export(&string.str_to_lower, .{ .name = "str_to_lower" });
    @export(&string.str_to_title, .{ .name = "str_to_title" });
    @export(&string.str_char_at, .{ .name = "str_char_at" });
    @export(&string.str_mid_cp, .{ .name = "str_mid_cp" });
    @export(&string.str_left_cp, .{ .name = "str_left_cp" });
    @export(&string.str_right_cp, .{ .name = "str_right_cp" });
    @export(&string.str_insert_cp, .{ .name = "str_insert_cp" });
    @export(&string.str_grapheme_count, .{ .name = "str_grapheme_count" });
    @export(&string.str_normalize, .{ .name = "str_normalize" });
    @export(&string.str_strip_marks, .{ .name = "str_strip_marks" });

    // ─── String regex integration (Phase E) ───
    @export(&string.str_regex_is_match, .{ .name = "str_regex_is_match" });
    @export(&string.str_regex_count, .{ .name = "str_regex_count" });
    @export(&string.str_regex_find_first, .{ .name = "str_regex_find_first" });
    @export(&string.str_regex_find_all, .{ .name = "str_regex_find_all" });
    @export(&string.str_regex_replace_all, .{ .name = "str_regex_replace_all" });
    @export(&string.str_regex_split_count, .{ .name = "str_regex_split_count" });
    @export(&string.str_regex_split_get, .{ .name = "str_regex_split_get" });

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
    @export(&regex.stz_regex_capture_by_name, .{ .name = "stz_regex_capture_by_name" });
    @export(&regex.stz_regex_named_group_count, .{ .name = "stz_regex_named_group_count" });
    @export(&regex.stz_regex_named_group_name, .{ .name = "stz_regex_named_group_name" });
    @export(&regex.stz_regex_partial_match, .{ .name = "stz_regex_partial_match" });

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

    // ─── Foundation: Value operations ───
    @export(&value.stz_value_new_null, .{ .name = "stz_value_new_null" });
    @export(&value.stz_value_new_bool, .{ .name = "stz_value_new_bool" });
    @export(&value.stz_value_new_int, .{ .name = "stz_value_new_int" });
    @export(&value.stz_value_new_float, .{ .name = "stz_value_new_float" });
    @export(&value.stz_value_new_string, .{ .name = "stz_value_new_string" });
    @export(&value.stz_value_new_list, .{ .name = "stz_value_new_list" });
    @export(&value.stz_value_free, .{ .name = "stz_value_free" });
    @export(&value.stz_value_type, .{ .name = "stz_value_type" });
    @export(&value.stz_value_is_null, .{ .name = "stz_value_is_null" });
    @export(&value.stz_value_get_bool, .{ .name = "stz_value_get_bool" });
    @export(&value.stz_value_get_int, .{ .name = "stz_value_get_int" });
    @export(&value.stz_value_get_float, .{ .name = "stz_value_get_float" });
    @export(&value.stz_value_get_string, .{ .name = "stz_value_get_string" });
    @export(&value.stz_value_get_string_len, .{ .name = "stz_value_get_string_len" });
    @export(&value.stz_value_list_len, .{ .name = "stz_value_list_len" });
    @export(&value.stz_value_list_get, .{ .name = "stz_value_list_get" });
    @export(&value.stz_value_list_append, .{ .name = "stz_value_list_append" });
    @export(&value.stz_value_list_set, .{ .name = "stz_value_list_set" });
    @export(&value.stz_value_list_remove, .{ .name = "stz_value_list_remove" });
    @export(&value.stz_value_list_insert, .{ .name = "stz_value_list_insert" });
    @export(&value.stz_value_equals, .{ .name = "stz_value_equals" });
    @export(&value.stz_value_compare, .{ .name = "stz_value_compare" });
    @export(&value.stz_value_clone, .{ .name = "stz_value_clone" });
    @export(&value.stz_value_to_string, .{ .name = "stz_value_to_string" });
    @export(&value.stz_value_type_name, .{ .name = "stz_value_type_name" });
    @export(&value.stz_value_type_name_len, .{ .name = "stz_value_type_name_len" });
    @export(&value.stz_value_list_find, .{ .name = "stz_value_list_find" });
    @export(&value.stz_value_list_contains, .{ .name = "stz_value_list_contains" });
    @export(&value.stz_value_list_reverse, .{ .name = "stz_value_list_reverse" });
    @export(&value.stz_value_list_sort, .{ .name = "stz_value_list_sort" });
    @export(&value.stz_value_list_clear, .{ .name = "stz_value_list_clear" });

    // ─── Foundation: Number operations ───
    @export(&number.stz_bigint_new, .{ .name = "stz_bigint_new" });
    @export(&number.stz_bigint_from_int, .{ .name = "stz_bigint_from_int" });
    @export(&number.stz_bigint_from_string, .{ .name = "stz_bigint_from_string" });
    @export(&number.stz_bigint_free, .{ .name = "stz_bigint_free" });
    @export(&number.stz_bigint_add, .{ .name = "stz_bigint_add" });
    @export(&number.stz_bigint_sub, .{ .name = "stz_bigint_sub" });
    @export(&number.stz_bigint_mul, .{ .name = "stz_bigint_mul" });
    @export(&number.stz_bigint_div, .{ .name = "stz_bigint_div" });
    @export(&number.stz_bigint_mod, .{ .name = "stz_bigint_mod" });
    @export(&number.stz_bigint_negate, .{ .name = "stz_bigint_negate" });
    @export(&number.stz_bigint_abs, .{ .name = "stz_bigint_abs" });
    @export(&number.stz_bigint_compare, .{ .name = "stz_bigint_compare" });
    @export(&number.stz_bigint_equals, .{ .name = "stz_bigint_equals" });
    @export(&number.stz_bigint_is_zero, .{ .name = "stz_bigint_is_zero" });
    @export(&number.stz_bigint_is_negative, .{ .name = "stz_bigint_is_negative" });
    @export(&number.stz_bigint_to_int, .{ .name = "stz_bigint_to_int" });
    @export(&number.stz_bigint_to_string, .{ .name = "stz_bigint_to_string" });
    @export(&number.stz_bigint_to_string_base, .{ .name = "stz_bigint_to_string_base" });
    @export(&number.stz_bigint_clone, .{ .name = "stz_bigint_clone" });
    @export(&number.stz_bigint_pow, .{ .name = "stz_bigint_pow" });
    @export(&number.stz_bigint_bit_count, .{ .name = "stz_bigint_bit_count" });
    @export(&number.stz_number_gcd, .{ .name = "stz_number_gcd" });
    @export(&number.stz_number_lcm, .{ .name = "stz_number_lcm" });
    @export(&number.stz_number_is_prime, .{ .name = "stz_number_is_prime" });
    @export(&number.stz_number_factorial, .{ .name = "stz_number_factorial" });
    @export(&number.stz_number_fibonacci, .{ .name = "stz_number_fibonacci" });
    @export(&number.stz_number_is_perfect, .{ .name = "stz_number_is_perfect" });
    @export(&number.stz_number_digit_count, .{ .name = "stz_number_digit_count" });
    @export(&number.stz_number_digit_sum, .{ .name = "stz_number_digit_sum" });
    @export(&number.stz_number_reverse_digits, .{ .name = "stz_number_reverse_digits" });
    @export(&number.stz_number_is_palindrome, .{ .name = "stz_number_is_palindrome" });

    // ─── Foundation: List operations ───
    @export(&list.stz_list_new, .{ .name = "stz_list_new" });
    @export(&list.stz_list_free, .{ .name = "stz_list_free" });
    @export(&list.stz_list_len, .{ .name = "stz_list_len" });
    @export(&list.stz_list_append_int, .{ .name = "stz_list_append_int" });
    @export(&list.stz_list_append_float, .{ .name = "stz_list_append_float" });
    @export(&list.stz_list_append_string, .{ .name = "stz_list_append_string" });
    @export(&list.stz_list_append_value, .{ .name = "stz_list_append_value" });
    @export(&list.stz_list_insert, .{ .name = "stz_list_insert" });
    @export(&list.stz_list_remove, .{ .name = "stz_list_remove" });
    @export(&list.stz_list_get, .{ .name = "stz_list_get" });
    @export(&list.stz_list_get_int, .{ .name = "stz_list_get_int" });
    @export(&list.stz_list_get_float, .{ .name = "stz_list_get_float" });
    @export(&list.stz_list_get_string, .{ .name = "stz_list_get_string" });
    @export(&list.stz_list_find_cs, .{ .name = "stz_list_find_cs" });
    @export(&list.stz_list_find_string_cs, .{ .name = "stz_list_find_string_cs" });
    @export(&list.stz_list_contains_cs, .{ .name = "stz_list_contains_cs" });
    @export(&list.stz_list_find_all_cs, .{ .name = "stz_list_find_all_cs" });
    @export(&list.stz_list_count_cs, .{ .name = "stz_list_count_cs" });
    @export(&list.stz_list_sort_cs, .{ .name = "stz_list_sort_cs" });
    @export(&list.stz_list_sort, .{ .name = "stz_list_sort" });
    @export(&list.stz_list_sort_descending_cs, .{ .name = "stz_list_sort_descending_cs" });
    @export(&list.stz_list_sort_descending, .{ .name = "stz_list_sort_descending" });
    @export(&list.stz_list_reverse, .{ .name = "stz_list_reverse" });
    @export(&list.stz_list_unique_cs, .{ .name = "stz_list_unique_cs" });
    @export(&list.stz_list_remove_duplicates_cs, .{ .name = "stz_list_remove_duplicates_cs" });
    @export(&list.stz_list_clone, .{ .name = "stz_list_clone" });
    @export(&list.stz_list_slice, .{ .name = "stz_list_slice" });
    @export(&list.stz_list_clear, .{ .name = "stz_list_clear" });
    @export(&list.stz_list_from_null_delimited, .{ .name = "stz_list_from_null_delimited" });
    @export(&list.stz_list_to_null_delimited, .{ .name = "stz_list_to_null_delimited" });
    @export(&list.stz_list_set, .{ .name = "stz_list_set" });
    @export(&list.stz_list_flatten, .{ .name = "stz_list_flatten" });
    @export(&list.stz_list_item_type, .{ .name = "stz_list_item_type" });
    @export(&list.stz_list_is_all_strings, .{ .name = "stz_list_is_all_strings" });
    @export(&list.stz_list_is_all_numbers, .{ .name = "stz_list_is_all_numbers" });
    @export(&list.stz_list_equals_cs, .{ .name = "stz_list_equals_cs" });

    // ─── Foundation: HashMap operations ───
    @export(&hashmap.stz_hashmap_new, .{ .name = "stz_hashmap_new" });
    @export(&hashmap.stz_hashmap_free, .{ .name = "stz_hashmap_free" });
    @export(&hashmap.stz_hashmap_len, .{ .name = "stz_hashmap_len" });
    @export(&hashmap.stz_hashmap_put, .{ .name = "stz_hashmap_put" });
    @export(&hashmap.stz_hashmap_put_int, .{ .name = "stz_hashmap_put_int" });
    @export(&hashmap.stz_hashmap_put_float, .{ .name = "stz_hashmap_put_float" });
    @export(&hashmap.stz_hashmap_put_string, .{ .name = "stz_hashmap_put_string" });
    @export(&hashmap.stz_hashmap_get, .{ .name = "stz_hashmap_get" });
    @export(&hashmap.stz_hashmap_get_cs, .{ .name = "stz_hashmap_get_cs" });
    @export(&hashmap.stz_hashmap_get_int, .{ .name = "stz_hashmap_get_int" });
    @export(&hashmap.stz_hashmap_get_float, .{ .name = "stz_hashmap_get_float" });
    @export(&hashmap.stz_hashmap_get_string, .{ .name = "stz_hashmap_get_string" });
    @export(&hashmap.stz_hashmap_has_key, .{ .name = "stz_hashmap_has_key" });
    @export(&hashmap.stz_hashmap_has_key_cs, .{ .name = "stz_hashmap_has_key_cs" });
    @export(&hashmap.stz_hashmap_remove, .{ .name = "stz_hashmap_remove" });
    @export(&hashmap.stz_hashmap_key_at, .{ .name = "stz_hashmap_key_at" });
    @export(&hashmap.stz_hashmap_key_len_at, .{ .name = "stz_hashmap_key_len_at" });
    @export(&hashmap.stz_hashmap_value_at, .{ .name = "stz_hashmap_value_at" });
    @export(&hashmap.stz_hashmap_clear, .{ .name = "stz_hashmap_clear" });
    @export(&hashmap.stz_hashmap_clone, .{ .name = "stz_hashmap_clone" });
    @export(&hashmap.stz_hashmap_keys, .{ .name = "stz_hashmap_keys" });
    @export(&hashmap.stz_hashmap_merge, .{ .name = "stz_hashmap_merge" });

    // ─── Unicode Data (SQLite-backed) ───
    @export(&unicode_data.stz_unidata_open, .{ .name = "stz_unidata_open" });
    @export(&unicode_data.stz_unidata_close, .{ .name = "stz_unidata_close" });
    @export(&unicode_data.stz_unidata_import, .{ .name = "stz_unidata_import" });
    @export(&unicode_data.stz_unidata_import_file, .{ .name = "stz_unidata_import_file" });
    @export(&unicode_data.stz_unidata_char_name, .{ .name = "stz_unidata_char_name" });
    @export(&unicode_data.stz_unidata_char_category, .{ .name = "stz_unidata_char_category" });
    @export(&unicode_data.stz_unidata_find_by_name, .{ .name = "stz_unidata_find_by_name" });
    @export(&unicode_data.stz_unidata_chars_in_range, .{ .name = "stz_unidata_chars_in_range" });
    @export(&unicode_data.stz_unidata_count, .{ .name = "stz_unidata_count" });
    @export(&unicode_data.stz_unidata_char_info, .{ .name = "stz_unidata_char_info" });
}

// Ring extension entry point (no-op -- we use CallCFunc for raw FFI)
pub export fn ringlib_init(_: ?*anyopaque) callconv(.c) void {}

// Version -- bumped for Unicode
pub export fn stz_engine_version() callconv(.c) u32 {
    return 0x00_07_00_00; // 0.7.0.0
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
    _ = meta;
    _ = named_params;
    _ = method_gen;
    _ = error_catalog;
    _ = value;
    _ = number;
    _ = list;
    _ = hashmap;
    _ = unicode_data;
}
