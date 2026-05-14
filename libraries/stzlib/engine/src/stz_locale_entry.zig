// Per-domain entry point for stz_locale.dll
// Bundles locale operations (Tier 2) into one shared library.

pub const locale = @import("locale.zig");
pub const ring_bridge = @import("ring_bridge_locale.zig");

comptime {
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
}

comptime {
    @export(&ring_bridge.ringlib_init, .{ .name = "ringlib_init" });
}

test {
    _ = locale;
}
