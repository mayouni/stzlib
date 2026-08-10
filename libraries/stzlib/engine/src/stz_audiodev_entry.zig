pub const audiodev = @import("audiodev.zig");
pub const ring_bridge = @import("ring_bridge_audiodev.zig");

comptime {
    @export(&ringlib_init, .{ .name = "ringlib_init" });
}

fn ringlib_init(pState: ?*anyopaque) callconv(.c) void {
    if (pState) |s| ring_bridge.registerAll(s);
}

test {
    _ = audiodev;
}
