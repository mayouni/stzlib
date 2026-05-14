// Per-domain entry point for stz_url.dll
pub const url = @import("url.zig");
pub const ring_bridge = @import("ring_bridge_url.zig");

comptime {
    @export(&url.stz_url_parse, .{ .name = "stz_url_parse" });
    @export(&url.stz_url_free, .{ .name = "stz_url_free" });
    @export(&url.stz_url_is_valid, .{ .name = "stz_url_is_valid" });
    @export(&url.stz_url_scheme, .{ .name = "stz_url_scheme" });
    @export(&url.stz_url_host, .{ .name = "stz_url_host" });
    @export(&url.stz_url_port, .{ .name = "stz_url_port" });
    @export(&url.stz_url_path, .{ .name = "stz_url_path" });
    @export(&url.stz_url_query, .{ .name = "stz_url_query" });
    @export(&url.stz_url_fragment, .{ .name = "stz_url_fragment" });
    @export(&url.stz_url_user, .{ .name = "stz_url_user" });
    @export(&url.stz_url_password, .{ .name = "stz_url_password" });
    @export(&url.stz_url_reconstruct, .{ .name = "stz_url_reconstruct" });
}

comptime {
    @export(&ring_bridge.ringlib_init, .{ .name = "ringlib_init" });
}

test { _ = url; }
