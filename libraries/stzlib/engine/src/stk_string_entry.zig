// Core entry point for stk_string.dll
// Minimal string + char operations for speed and constrained environments.
// Base (stz_string.dll) is a strict superset of this.

pub const string = @import("string.zig");
pub const char = @import("char.zig");
pub const ring_bridge = @import("ring_bridge_string.zig");

comptime {
    // String lifecycle
    @export(&string.stz_string_new, .{ .name = "stz_string_new" });
    @export(&string.stz_string_from, .{ .name = "stz_string_from" });
    @export(&string.stz_string_free, .{ .name = "stz_string_free" });

    // String content
    @export(&string.stz_string_data, .{ .name = "stz_string_data" });
    @export(&string.stz_string_size, .{ .name = "stz_string_size" });

    // String mutation
    @export(&string.stz_string_append, .{ .name = "stz_string_append" });

    // String search
    @export(&string.stz_string_index_of, .{ .name = "stz_string_index_of" });
    @export(&string.stz_string_contains, .{ .name = "stz_string_contains" });

    // Char fundamentals
    @export(&char.stz_char_unicode, .{ .name = "stz_char_unicode" });
    @export(&char.stz_char_to_utf8, .{ .name = "stz_char_to_utf8" });
    @export(&char.stz_char_is_letter, .{ .name = "stz_char_is_letter" });
    @export(&char.stz_char_is_digit, .{ .name = "stz_char_is_digit" });
}

comptime {
    @export(&ring_bridge.ringlib_init, .{ .name = "ringlib_init" });
}

test {
    _ = string;
    _ = char;
}
