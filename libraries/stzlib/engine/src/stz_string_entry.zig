// Per-domain entry point for str.dll (formerly stz_string.dll)
// Bundles string + char (Tier 1) into one shared library.

pub const string = @import("string.zig");
pub const char = @import("char.zig");
pub const ring_bridge = @import("ring_bridge_string.zig");

comptime {
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

    // Regex integration (Phase E)
    @export(&string.str_regex_is_match, .{ .name = "str_regex_is_match" });
    @export(&string.str_regex_count, .{ .name = "str_regex_count" });
    @export(&string.str_regex_find_first, .{ .name = "str_regex_find_first" });
    @export(&string.str_regex_find_all, .{ .name = "str_regex_find_all" });
    @export(&string.str_regex_replace_all, .{ .name = "str_regex_replace_all" });
    @export(&string.str_regex_split_count, .{ .name = "str_regex_split_count" });
    @export(&string.str_regex_split_get, .{ .name = "str_regex_split_get" });

    // Between / Section (base verb = ALL per Softanza convention)
    @export(&string.str_between, .{ .name = "str_between" });
    @export(&string.str_between_cs, .{ .name = "str_between_cs" });
    @export(&string.str_between_all, .{ .name = "str_between_all" });
    @export(&string.str_between_all_cs, .{ .name = "str_between_all_cs" });
    @export(&string.str_between_first_cs, .{ .name = "str_between_first_cs" });
    @export(&string.str_between_last, .{ .name = "str_between_last" });
    @export(&string.str_replace_between, .{ .name = "str_replace_between" });
    @export(&string.str_replace_first_between, .{ .name = "str_replace_first_between" });
    @export(&string.str_replace_nth_between, .{ .name = "str_replace_nth_between" });
    @export(&string.str_replace_last_between, .{ .name = "str_replace_last_between" });
    @export(&string.str_replace_all_between, .{ .name = "str_replace_all_between" });
    @export(&string.str_remove_between, .{ .name = "str_remove_between" });
    @export(&string.str_remove_first_between, .{ .name = "str_remove_first_between" });
    @export(&string.str_remove_nth_between, .{ .name = "str_remove_nth_between" });
    @export(&string.str_remove_last_between, .{ .name = "str_remove_last_between" });
    @export(&string.str_remove_all_between, .{ .name = "str_remove_all_between" });
    @export(&string.str_section_cp, .{ .name = "str_section_cp" });

    @export(&char.stz_char_unicode, .{ .name = "stz_char_unicode" });
    @export(&char.stz_char_to_utf8, .{ .name = "stz_char_to_utf8" });
    @export(&char.stz_char_is_letter, .{ .name = "stz_char_is_letter" });
    @export(&char.stz_char_is_digit, .{ .name = "stz_char_is_digit" });
    @export(&char.stz_char_is_upper, .{ .name = "stz_char_is_upper" });
    @export(&char.stz_char_is_lower, .{ .name = "stz_char_is_lower" });

    @export(&ring_bridge.ringlib_init, .{ .name = "ringlib_init" });
}

test {
    _ = string;
    _ = char;
}
