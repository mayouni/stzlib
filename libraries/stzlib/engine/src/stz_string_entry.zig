// Per-domain entry point for stz_string.dll
// Bundles string + char (Tier 1) into one shared library.

pub const string = @import("string.zig");
pub const char = @import("char.zig");
pub const ring_bridge = @import("ring_bridge_string.zig");

comptime {
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
    @export(&string.stz_string_replace_range, .{ .name = "stz_string_replace_range" });
    @export(&string.stz_string_split_count, .{ .name = "stz_string_split_count" });
    @export(&string.stz_string_split_get, .{ .name = "stz_string_split_get" });
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
