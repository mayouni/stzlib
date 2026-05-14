// Per-domain entry point for stz_regex.dll
pub const regex = @import("regex.zig");

comptime {
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
}

test { _ = regex; }
