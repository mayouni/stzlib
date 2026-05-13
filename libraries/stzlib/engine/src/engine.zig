// Softanza Engine -- the power substrate
//
// A Zig shared library providing string, unicode, datetime, file,
// locale, regex, and JSON operations via C ABI. Ring calls these
// through FFI; Zin links them directly.
//
// Tier 1: Strings + Unicode (replaces QString2 + QChar)
// Tier 2: DateTime + File + Locale (future)
// Tier 3: Regex + JSON (future)

pub const string = @import("string.zig");
pub const char = @import("char.zig");

// Re-export C ABI symbols
comptime {
    // String operations
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

    // Unicode character operations
    @export(&char.stz_char_unicode, .{ .name = "stz_char_unicode" });
    @export(&char.stz_char_to_utf8, .{ .name = "stz_char_to_utf8" });
    @export(&char.stz_char_is_letter, .{ .name = "stz_char_is_letter" });
    @export(&char.stz_char_is_digit, .{ .name = "stz_char_is_digit" });
    @export(&char.stz_char_is_upper, .{ .name = "stz_char_is_upper" });
    @export(&char.stz_char_is_lower, .{ .name = "stz_char_is_lower" });
}

// Version
pub export fn stz_engine_version() callconv(.c) u32 {
    return 0x00_01_00_00; // 0.1.0.0
}

test {
    _ = string;
    _ = char;
}
