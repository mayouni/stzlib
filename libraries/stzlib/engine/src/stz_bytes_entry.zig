// Per-domain entry point for stz_bytes.dll
pub const bytes = @import("bytes.zig");
pub const ring_bridge = @import("ring_bridge_bytes.zig");

comptime {
    @export(&bytes.stz_bytes_new, .{ .name = "stz_bytes_new" });
    @export(&bytes.stz_bytes_from, .{ .name = "stz_bytes_from" });
    @export(&bytes.stz_bytes_free, .{ .name = "stz_bytes_free" });
    @export(&bytes.stz_bytes_data, .{ .name = "stz_bytes_data" });
    @export(&bytes.stz_bytes_size, .{ .name = "stz_bytes_size" });
    @export(&bytes.stz_bytes_is_empty, .{ .name = "stz_bytes_is_empty" });
    @export(&bytes.stz_bytes_clear, .{ .name = "stz_bytes_clear" });
    @export(&bytes.stz_bytes_append, .{ .name = "stz_bytes_append" });
    @export(&bytes.stz_bytes_at, .{ .name = "stz_bytes_at" });
    @export(&bytes.stz_bytes_insert, .{ .name = "stz_bytes_insert" });
    @export(&bytes.stz_bytes_remove, .{ .name = "stz_bytes_remove" });
    @export(&bytes.stz_bytes_left, .{ .name = "stz_bytes_left" });
    @export(&bytes.stz_bytes_right, .{ .name = "stz_bytes_right" });
    @export(&bytes.stz_bytes_mid, .{ .name = "stz_bytes_mid" });
    @export(&bytes.stz_bytes_fill, .{ .name = "stz_bytes_fill" });
    @export(&bytes.stz_bytes_replace, .{ .name = "stz_bytes_replace" });
    @export(&bytes.stz_bytes_resize, .{ .name = "stz_bytes_resize" });
    @export(&bytes.stz_bytes_to_lower, .{ .name = "stz_bytes_to_lower" });
    @export(&bytes.stz_bytes_to_upper, .{ .name = "stz_bytes_to_upper" });
    @export(&bytes.stz_bytes_to_base64, .{ .name = "stz_bytes_to_base64" });
    @export(&bytes.stz_bytes_from_base64, .{ .name = "stz_bytes_from_base64" });
    @export(&bytes.stz_bytes_to_hex, .{ .name = "stz_bytes_to_hex" });
    @export(&bytes.stz_bytes_from_hex, .{ .name = "stz_bytes_from_hex" });
    @export(&bytes.stz_bytes_to_percent, .{ .name = "stz_bytes_to_percent" });
    @export(&bytes.stz_bytes_from_percent, .{ .name = "stz_bytes_from_percent" });
}

comptime {
    @export(&ring_bridge.ringlib_init, .{ .name = "ringlib_init" });
}

test { _ = bytes; }
