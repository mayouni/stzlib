pub const geo = @import("geo.zig");
pub const geo_projection = @import("geo_projection.zig");
pub const geo_stats = @import("geo_stats.zig");
pub const geo_field = @import("geo_field.zig");
pub const geo_interp = @import("geo_interp.zig");
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
    _ = geo_stats;
    _ = geo_field;
    _ = geo_interp;
}
