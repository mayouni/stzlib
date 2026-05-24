pub const async_task = @import("async_task.zig");
pub const ring_bridge = @import("ring_bridge_async.zig");

comptime {
    @export(&ringlib_init, .{ .name = "ringlib_init" });
}

fn ringlib_init(pState: ?*anyopaque) callconv(.c) void {
    if (pState) |s| ring_bridge.registerAll(s);
}

test { _ = async_task; }
