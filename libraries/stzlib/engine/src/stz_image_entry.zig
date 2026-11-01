pub const image = @import("image.zig");
pub const image_ops = @import("image_ops.zig");
pub const image_geom = @import("image_geom.zig");
pub const ring_bridge = @import("ring_bridge_image.zig");

comptime {
    @export(&ringlib_init, .{ .name = "ringlib_init" });
}

fn ringlib_init(pState: ?*anyopaque) callconv(.c) void {
    if (pState) |s| ring_bridge.registerAll(s);
}

test {
    _ = image;
    _ = image_ops;
    _ = image_geom;
}
