pub const sound = @import("sound.zig");
pub const soundgraph = @import("soundgraph.zig");
pub const soundanalysis = @import("soundanalysis.zig");
pub const ring_bridge = @import("ring_bridge_sound.zig");

comptime {
    @export(&ringlib_init, .{ .name = "ringlib_init" });
}

fn ringlib_init(pState: ?*anyopaque) callconv(.c) void {
    if (pState) |s| ring_bridge.registerAll(s);
}

test {
    _ = sound;
    _ = soundgraph;
    _ = soundanalysis;
}
