// Core entry point for stk_locale.dll
// Minimal locale: basic case conversion only.
// Base (stz_locale.dll) is a strict superset of this.

pub const locale = @import("locale.zig");

comptime {
    @export(&locale.stz_locale_to_upper, .{ .name = "stz_locale_to_upper" });
    @export(&locale.stz_locale_to_lower, .{ .name = "stz_locale_to_lower" });
}

test {
    _ = locale;
}
