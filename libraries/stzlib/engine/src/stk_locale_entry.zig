// Core entry point for stk_locale.dll
// Minimal locale: basic case conversion only.
// Base (stz_locale.dll) is a strict superset of this.

pub const locale = @import("locale.zig");
pub const ring_bridge = @import("ring_bridge_locale.zig");

comptime {
    @export(&locale.stz_locale_to_upper, .{ .name = "stz_locale_to_upper" });
    @export(&locale.stz_locale_to_lower, .{ .name = "stz_locale_to_lower" });
}

comptime {
    @export(&ring_bridge.ringlib_init, .{ .name = "ringlib_init" });
}

test {
    _ = locale;
}
