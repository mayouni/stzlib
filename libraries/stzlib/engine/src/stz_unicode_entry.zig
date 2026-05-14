pub const unicode = @import("unicode.zig");
pub const ring_bridge = @import("ring_bridge_unicode.zig");

comptime {
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
}

comptime {
    @export(&ring_bridge.ringlib_init, .{ .name = "ringlib_init" });
}
