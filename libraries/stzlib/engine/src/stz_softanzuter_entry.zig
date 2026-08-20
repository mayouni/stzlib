pub const softanzuter = @import("softanzuter.zig");
pub const agentloop = @import("agentloop.zig");
pub const ring_bridge = @import("ring_bridge_softanzuter.zig");
pub const ring_bridge_loop = @import("ring_bridge_agentloop.zig");

const R = @import("ring_api.zig");

comptime {
    @export(&ringlib_init, .{ .name = "ringlib_init" });
}

// ONE DLL, TWO BRIDGES. The tick loop reads the slot substrate's mailboxes
// directly, so they must share a process image -- and a second DLL would
// give the loop a second, empty copy of the agent table. Zero new DLLs.
fn ringlib_init(pState: ?*anyopaque) callconv(.c) void {
    if (pState) |s| {
        R.registerAll(s, &ring_bridge.ring_funcs);
        R.registerAll(s, &ring_bridge_loop.ring_funcs);
    }
}

test {
    _ = softanzuter;
    _ = agentloop;
}
