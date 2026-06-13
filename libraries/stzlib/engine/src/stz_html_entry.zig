pub const html = @import("html.zig");
pub const html_dom = @import("html_dom.zig");
pub const ring_bridge = @import("ring_bridge_html.zig");

comptime {
    @export(&ringlib_init, .{ .name = "ringlib_init" });
}

fn ringlib_init(pState: ?*anyopaque) callconv(.c) void {
    if (pState) |s| ring_bridge.registerAll(s);
}

test {
    _ = html;
    _ = html_dom;
}
