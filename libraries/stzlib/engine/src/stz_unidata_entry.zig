// Per-domain entry point for stz_unidata.dll
// The DLL auto-opens unicode.db on load via ringlib_init.
// Ring never sees handles, paths, or init calls.
pub const unicode_data = @import("unicode_data.zig");
pub const ref_data = @import("ref_data.zig");
pub const ring_bridge = @import("ring_bridge_unidata.zig");
pub const ring_bridge_ref = @import("ring_bridge_refdata.zig");

comptime {
    @export(&unicode_data.stz_unidata_char_name, .{ .name = "stz_unidata_char_name" });
    @export(&unicode_data.stz_unidata_char_category, .{ .name = "stz_unidata_char_category" });
    @export(&unicode_data.stz_unidata_find_by_name, .{ .name = "stz_unidata_find_by_name" });
    @export(&unicode_data.stz_unidata_chars_in_range, .{ .name = "stz_unidata_chars_in_range" });
    @export(&unicode_data.stz_unidata_count, .{ .name = "stz_unidata_count" });
    @export(&unicode_data.stz_unidata_char_info, .{ .name = "stz_unidata_char_info" });
    @export(&unicode_data.stz_unidata_codepoint_by_name, .{ .name = "stz_unidata_codepoint_by_name" });
    @export(&unicode_data.stz_unidata_contains_name, .{ .name = "stz_unidata_contains_name" });
}

comptime {
    @export(&ring_bridge.ringlib_init, .{ .name = "ringlib_init" });
}

test { _ = unicode_data; _ = ref_data; }
