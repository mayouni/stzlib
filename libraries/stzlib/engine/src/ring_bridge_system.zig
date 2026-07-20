const sys = @import("system.zig");
const R = @import("ring_api.zig");

const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring;
const rs2 = R.ring_vm_api_retstring2;

fn ring_Run(p: *anyopaque) callconv(.c) void {
    var out_len: usize = 0;
    var err_len: usize = 0;
    var exit_code: c_int = -1;
    const ptr = sys.stz_system_run(gs(p, 1), @intCast(gss(p, 1)), &out_len, &err_len, &exit_code);
    if (ptr != null and out_len > 0) {
        rs2(p, ptr, @intCast(out_len));
        sys.stz_system_run_free(ptr, out_len);
    } else rs(p, "");
}
// One execution -> Ring list [ stdout, exitcode, stderr ]. Lets Run() read
// the exit code and stderr WITHOUT re-running the command.
fn ring_RunXT(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;

    var out_ptr: [*c]u8 = null;
    var out_len: usize = 0;
    var err_ptr: [*c]u8 = null;
    var err_len: usize = 0;
    var exit_code: c_int = -1;
    sys.stz_system_run2(gs(p, 1), @intCast(gss(p, 1)), &out_ptr, &out_len, &err_ptr, &err_len, &exit_code);

    const empty: [*]const u8 = "";

    if (out_ptr != null and out_len > 0) {
        R.ring_list_addstring2(out, out_ptr, @intCast(out_len));
        sys.stz_system_run_free(out_ptr, out_len);
    } else {
        R.ring_list_addstring2(out, empty, 0);
    }

    R.ring_list_addint(out, exit_code);

    if (err_ptr != null and err_len > 0) {
        R.ring_list_addstring2(out, err_ptr, @intCast(err_len));
        sys.stz_system_run_free(err_ptr, err_len);
    } else {
        R.ring_list_addstring2(out, empty, 0);
    }

    R.ring_vm_api_retlist(p, out);
}
fn ring_Exec(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(sys.stz_system_exec(gs(p, 1), @intCast(gss(p, 1)))));
}
fn ring_Env(p: *anyopaque) callconv(.c) void {
    var buf: [4096]u8 = undefined;
    const n = sys.stz_system_env(gs(p, 1), @intCast(gss(p, 1)), &buf, 4096);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}

// A small helper: run an engine fn that returns an owned [ptr,len] and hand
// the bytes to Ring, freeing them. Empty/failure -> "".
fn retOwned(p: *anyopaque, ptr: [*c]u8, out_len: usize) void {
    if (ptr != null and out_len > 0) {
        rs2(p, ptr, @intCast(out_len));
        sys.stz_system_run_free(ptr, out_len);
    } else rs(p, "");
}

fn ring_EnvGet(p: *anyopaque) callconv(.c) void {
    var out_len: usize = 0;
    const ptr = sys.stz_system_env_get(gs(p, 1), @intCast(gss(p, 1)), &out_len);
    retOwned(p, ptr, out_len);
}
fn ring_EnvSet(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(sys.stz_system_env_set(gs(p, 1), @intCast(gss(p, 1)), gs(p, 2), @intCast(gss(p, 2)))));
}
fn ring_EnvUnset(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(sys.stz_system_env_unset(gs(p, 1), @intCast(gss(p, 1)))));
}
fn ring_EnvList(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    var out_len: usize = 0;
    const ptr = sys.stz_system_env_list(&out_len);
    if (ptr != null) {
        defer sys.stz_system_run_free(ptr, out_len);
        const b = ptr[0..out_len];
        var start: usize = 0;
        var i: usize = 0;
        while (i < b.len) : (i += 1) {
            if (b[i] == 0) {
                if (i > start) R.ring_list_addstring2(out, b.ptr + start, @intCast(i - start));
                start = i + 1;
            }
        }
    }
    R.ring_vm_api_retlist(p, out);
}
fn ring_CwdGet(p: *anyopaque) callconv(.c) void {
    var out_len: usize = 0;
    const ptr = sys.stz_system_cwd_get(&out_len);
    retOwned(p, ptr, out_len);
}
fn ring_CwdSet(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(sys.stz_system_cwd_set(gs(p, 1), @intCast(gss(p, 1)))));
}
fn ring_Hostname(p: *anyopaque) callconv(.c) void {
    var buf: [256]u8 = undefined;
    const n = sys.stz_system_hostname(&buf, 256);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_Username(p: *anyopaque) callconv(.c) void {
    var buf: [256]u8 = undefined;
    const n = sys.stz_system_username(&buf, 256);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_CpuCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(sys.stz_system_cpu_count()));
}
fn ring_IsWindows(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(sys.stz_system_is_windows())); }
fn ring_IsLinux(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(sys.stz_system_is_linux())); }
fn ring_IsMacos(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(sys.stz_system_is_macos())); }

pub const regs = [_]R.Reg{
    .{ .name = "stzenginesystemrun", .func = &ring_Run },
    .{ .name = "stzenginesystemrunxt", .func = &ring_RunXT },
    .{ .name = "stzenginesystemexec", .func = &ring_Exec },
    .{ .name = "stzenginesystemenv", .func = &ring_Env },
    .{ .name = "stzenginesystemenvget", .func = &ring_EnvGet },
    .{ .name = "stzenginesystemenvset", .func = &ring_EnvSet },
    .{ .name = "stzenginesystemenvunset", .func = &ring_EnvUnset },
    .{ .name = "stzenginesystemenvlist", .func = &ring_EnvList },
    .{ .name = "stzenginesystemcwdget", .func = &ring_CwdGet },
    .{ .name = "stzenginesystemcwdset", .func = &ring_CwdSet },
    .{ .name = "stzenginesystemhostname", .func = &ring_Hostname },
    .{ .name = "stzenginesystemusername", .func = &ring_Username },
    .{ .name = "stzenginesystemcpucount", .func = &ring_CpuCount },
    .{ .name = "stzenginesystemiswindows", .func = &ring_IsWindows },
    .{ .name = "stzenginesystemislinux", .func = &ring_IsLinux },
    .{ .name = "stzenginesystemismacos", .func = &ring_IsMacos },
};

pub fn ringlib_init(pRingState: ?*anyopaque) callconv(.c) void {
    if (pRingState) |state| R.registerAll(state, &regs);
}
