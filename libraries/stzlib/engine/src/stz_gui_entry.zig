pub const gui = @import("gui.zig");
pub const ring_bridge = @import("ring_bridge_gui.zig");

comptime {
    @export(&ringlib_init, .{ .name = "ringlib_init" });
    // gui_font.zig's C ABI exports (stz_guifont_*) are consumed by the
    // C++ font engine in stz_rmlui.cpp; referencing the module here is
    // what makes Zig emit them.
    _ = @import("gui_font.zig");
}

fn ringlib_init(pState: ?*anyopaque) callconv(.c) void {
    if (pState) |s| ring_bridge.registerAll(s);
}

test {
    _ = gui;
}
