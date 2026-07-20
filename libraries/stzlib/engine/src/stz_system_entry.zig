// Per-domain entry point for stz_system.dll
pub const system = @import("system.zig");
pub const ring_bridge = @import("ring_bridge_system.zig");

comptime {
    @export(&system.stz_system_run, .{ .name = "stz_system_run" });
    @export(&system.stz_system_run_free, .{ .name = "stz_system_run_free" });
    @export(&system.stz_system_exec, .{ .name = "stz_system_exec" });
    @export(&system.stz_system_env, .{ .name = "stz_system_env" });
    @export(&system.stz_system_run2, .{ .name = "stz_system_run2" });
    @export(&system.stz_system_env_get, .{ .name = "stz_system_env_get" });
    @export(&system.stz_system_env_set, .{ .name = "stz_system_env_set" });
    @export(&system.stz_system_env_unset, .{ .name = "stz_system_env_unset" });
    @export(&system.stz_system_env_list, .{ .name = "stz_system_env_list" });
    @export(&system.stz_system_cwd_get, .{ .name = "stz_system_cwd_get" });
    @export(&system.stz_system_cwd_set, .{ .name = "stz_system_cwd_set" });
    @export(&system.stz_system_hostname, .{ .name = "stz_system_hostname" });
    @export(&system.stz_system_username, .{ .name = "stz_system_username" });
    @export(&system.stz_system_cpu_count, .{ .name = "stz_system_cpu_count" });
    @export(&system.stz_process_spawn, .{ .name = "stz_process_spawn" });
    @export(&system.stz_process_read_stdout, .{ .name = "stz_process_read_stdout" });
    @export(&system.stz_process_read_stderr, .{ .name = "stz_process_read_stderr" });
    @export(&system.stz_process_wait, .{ .name = "stz_process_wait" });
    @export(&system.stz_process_kill, .{ .name = "stz_process_kill" });
    @export(&system.stz_process_pid_of, .{ .name = "stz_process_pid_of" });
    @export(&system.stz_process_spawn_free, .{ .name = "stz_process_spawn_free" });
    @export(&system.stz_system_is_windows, .{ .name = "stz_system_is_windows" });
    @export(&system.stz_system_is_linux, .{ .name = "stz_system_is_linux" });
    @export(&system.stz_system_is_macos, .{ .name = "stz_system_is_macos" });
}

comptime {
    @export(&ring_bridge.ringlib_init, .{ .name = "ringlib_init" });
}

test { _ = system; }
