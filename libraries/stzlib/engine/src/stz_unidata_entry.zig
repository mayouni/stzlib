// Per-domain entry point for stz_unidata.dll
pub const unicode_data = @import("unicode_data.zig");
pub const ring_bridge = @import("ring_bridge_unidata.zig");

comptime {
    @export(&unicode_data.stz_unidata_open, .{ .name = "stz_unidata_open" });
    @export(&unicode_data.stz_unidata_close, .{ .name = "stz_unidata_close" });
    @export(&unicode_data.stz_unidata_import, .{ .name = "stz_unidata_import" });
    @export(&unicode_data.stz_unidata_import_file, .{ .name = "stz_unidata_import_file" });
    @export(&unicode_data.stz_unidata_char_name, .{ .name = "stz_unidata_char_name" });
    @export(&unicode_data.stz_unidata_char_category, .{ .name = "stz_unidata_char_category" });
    @export(&unicode_data.stz_unidata_find_by_name, .{ .name = "stz_unidata_find_by_name" });
    @export(&unicode_data.stz_unidata_chars_in_range, .{ .name = "stz_unidata_chars_in_range" });
    @export(&unicode_data.stz_unidata_count, .{ .name = "stz_unidata_count" });
    @export(&unicode_data.stz_unidata_char_info, .{ .name = "stz_unidata_char_info" });
}

comptime {
    @export(&ring_bridge.ringlib_init, .{ .name = "ringlib_init" });
}

test { _ = unicode_data; }
