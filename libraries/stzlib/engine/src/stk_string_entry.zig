// Core entry point for stk_string.dll
// Minimal string + char operations for speed and constrained environments.
// Base (str.dll) is a strict superset of this.

pub const string = @import("string.zig");
pub const char = @import("char.zig");
pub const ring_bridge = @import("ring_bridge_string.zig");

comptime {
    // String lifecycle
    @export(&string.str_new, .{ .name = "str_new" });
    @export(&string.str_from, .{ .name = "str_from" });
    @export(&string.str_free, .{ .name = "str_free" });

    // String content
    @export(&string.str_data, .{ .name = "str_data" });
    @export(&string.str_size, .{ .name = "str_size" });

    // String mutation
    @export(&string.str_append, .{ .name = "str_append" });

    // String search
    @export(&string.str_find_first, .{ .name = "str_find_first" });
    @export(&string.str_contains, .{ .name = "str_contains" });

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
