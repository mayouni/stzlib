// Per-domain entry point for stz_system.dll
pub const system = @import("system.zig");
pub const ring_bridge = @import("ring_bridge_system.zig");

comptime {
    @export(&system.stz_system_run, .{ .name = "stz_system_run" });
    @export(&system.stz_system_run_free, .{ .name = "stz_system_run_free" });
    @export(&system.stz_system_exec, .{ .name = "stz_system_exec" });
    @export(&system.stz_system_env, .{ .name = "stz_system_env" });
    @export(&system.stz_system_is_windows, .{ .name = "stz_system_is_windows" });
    @export(&system.stz_system_is_linux, .{ .name = "stz_system_is_linux" });
    @export(&system.stz_system_is_macos, .{ .name = "stz_system_is_macos" });
}

comptime {
    @export(&ring_bridge.ringlib_init, .{ .name = "ringlib_init" });
}

test { _ = system; }
