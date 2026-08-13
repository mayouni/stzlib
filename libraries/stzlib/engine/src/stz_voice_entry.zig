// stz_voice.dll -- the per-OS speech tier: synthesis (VC1) and recognition
// (VC3). Both directions live in one DLL because both are the same platform
// service, and a caller that has one almost always wants the other.

pub const voice = @import("voice.zig");
pub const listen = @import("listen.zig");
pub const ring_bridge = @import("ring_bridge_voice.zig");
pub const ring_bridge_listen = @import("ring_bridge_listen.zig");

comptime {
    @export(&ringlib_init, .{ .name = "ringlib_init" });
}

fn ringlib_init(pState: ?*anyopaque) callconv(.c) void {
    if (pState) |s| {
        ring_bridge.registerAll(s);
        ring_bridge_listen.registerAll(s);
    }
}

test {
    _ = voice;
    _ = listen;
}
