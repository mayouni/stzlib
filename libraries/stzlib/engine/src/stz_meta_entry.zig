// Softanza Engine -- stz_meta DLL entry point
//
// Registers all meta-engine functions with Ring's VM.

const R = @import("ring_api.zig");
const bridge = @import("ring_bridge_meta.zig");

pub export fn ringlib_init(state: *anyopaque) callconv(.c) void {
    R.registerAll(state, &bridge.registrations);
}
