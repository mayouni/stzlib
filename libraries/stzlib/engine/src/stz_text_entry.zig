pub const text = @import("text.zig");
pub const ring_bridge = @import("ring_bridge_text.zig");
const R = @import("ring_api.zig");

comptime {
    @export(&ringlib_init, .{ .name = "ringlib_init" });
}

fn ringlib_init(pState: ?*anyopaque) callconv(.c) void {
    if (pState) |s| {
        ring_bridge.registerAll(s);
    }
}

test { _ = text; }
