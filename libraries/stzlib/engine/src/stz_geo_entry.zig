pub const geo = @import("geo.zig");
pub const geo_projection = @import("geo_projection.zig");
pub const ring_bridge = @import("ring_bridge_geo.zig");

comptime {
    @export(&ringlib_init, .{ .name = "ringlib_init" });
}

fn ringlib_init(pState: ?*anyopaque) callconv(.c) void {
    if (pState) |s| ring_bridge.registerAll(s);
}

test {
    _ = geo;
    _ = geo_projection;
}
