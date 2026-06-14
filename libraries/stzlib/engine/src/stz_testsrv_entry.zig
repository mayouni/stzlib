pub const testserver = @import("testserver.zig");
pub const ring_bridge = @import("ring_bridge_testsrv.zig");

comptime {
    @export(&ringlib_init, .{ .name = "ringlib_init" });
}

fn ringlib_init(pState: ?*anyopaque) callconv(.c) void {
    if (pState) |s| ring_bridge.registerAll(s);
}

test {
    _ = testserver;
}
