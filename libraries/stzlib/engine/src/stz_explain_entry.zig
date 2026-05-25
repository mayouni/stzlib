pub const explain = @import("explain.zig");
pub const ring_bridge = @import("ring_bridge_explain.zig");
const R = @import("ring_api.zig");

comptime {
    @export(&ringlib_init, .{ .name = "ringlib_init" });
}

fn ringlib_init(pState: ?*anyopaque) callconv(.c) void {
    if (pState) |s| R.registerAll(s, &ring_bridge.ring_funcs);
}

test {
    _ = explain;
}
