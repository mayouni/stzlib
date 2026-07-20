// Softanza Engine -- System/Process Operations (Tier 3)
//
// Replaces QProcess/QStringList with Zig std.process.
// All functions use C ABI for Ring FFI compatibility.

const std = @import("std");
const builtin = @import("builtin");
const mem = std.mem;
const gpa = std.heap.c_allocator;

// Declared locally so we do not depend on this symbol being present in the
// std kernel32 binding across Zig versions. Used only on Windows, where the
// Win32 environment (what SetEnvironmentVariableW writes and getEnvVarOwned
// reads) is the store child processes inherit -- so set and get stay
// consistent.
extern "kernel32" fn SetEnvironmentVariableW(name: [*:0]const u16, value: ?[*:0]const u16) callconv(.winapi) i32;

// ─── Run command and capture output ───

pub fn stz_system_run(cmd: [*c]const u8, cmd_len: usize, out_len: *usize, err_len: *usize, exit_code: *c_int) callconv(.c) [*c]u8 {
    out_len.* = 0;
    err_len.* = 0;
    exit_code.* = -1;
    if (cmd == null or cmd_len == 0) return null;

    const command = cmd[0..cmd_len];
    const result = runShellCommand(command) catch return null;
    defer if (result.stderr.len > 0) gpa.free(result.stderr);

    exit_code.* = result.exit_code;
    out_len.* = result.stdout.len;
    err_len.* = result.stderr.len;

    if (result.stdout.len > 0) {
        return result.stdout.ptr;
    }
    return null;
}

const RunResult = struct {
    stdout: []u8,
    stderr: []u8,
    exit_code: c_int,
};

fn runShellCommand(command: []const u8) !RunResult {
    const shell = getShell();
    const argv: []const []const u8 = if (shell.flag) |f|
        &[_][]const u8{ shell.name, f, command }
    else
        &[_][]const u8{ shell.name, command };

    var child = std.process.Child.init(argv, gpa);
    child.stdout_behavior = .Pipe;
    child.stderr_behavior = .Pipe;

    // Hide the console window on Windows (replaces old Qt QProcess behavior)
    child.create_no_window = true;

    try child.spawn();

    const stdout = child.stdout.?.readToEndAlloc(gpa, 10 * 1024 * 1024) catch "";
    const stderr = child.stderr.?.readToEndAlloc(gpa, 1 * 1024 * 1024) catch "";

    const term = try child.wait();
    const code: c_int = switch (term) {
        .Exited => |c| @intCast(c),
        else => -1,
    };

    return .{ .stdout = @constCast(stdout), .stderr = @constCast(stderr), .exit_code = code };
}

const Shell = struct { name: []const u8, flag: ?[]const u8 };

fn getShell() Shell {
    if (@import("builtin").os.tag == .windows) {
        return .{ .name = "cmd.exe", .flag = "/c" };
    }
    return .{ .name = "/bin/sh", .flag = "-c" };
}

pub fn stz_system_run_free(ptr: [*c]u8, len: usize) callconv(.c) void {
    if (ptr != null and len > 0) gpa.free(ptr[0..len]);
}

// Run a command ONCE and hand back stdout, stderr AND the exit code.
//
// stz_system_run above returns only stdout and FREES stderr (its length
// survives but the bytes are gone), and its exit_code out-param is the sole
// way to learn success. The Ring side, unable to get the exit code and
// stderr from one call, RE-EXECUTED the command via stz_system_exec to read
// the code -- so any side-effecting command ran twice, and stderr was lost.
//
// This returns everything from a single spawn. Both buffers are the caller's
// to free with stz_system_run_free (matching the existing convention: only
// len > 0 buffers are handed back, so only those are freed).
pub fn stz_system_run2(
    cmd: [*c]const u8,
    cmd_len: usize,
    out_ptr: *[*c]u8,
    out_len: *usize,
    err_ptr: *[*c]u8,
    err_len: *usize,
    exit_code: *c_int,
) callconv(.c) void {
    out_ptr.* = null;
    out_len.* = 0;
    err_ptr.* = null;
    err_len.* = 0;
    exit_code.* = -1;
    if (cmd == null or cmd_len == 0) return;

    const command = cmd[0..cmd_len];
    const result = runShellCommand(command) catch return;

    exit_code.* = result.exit_code;
    if (result.stdout.len > 0) {
        out_ptr.* = result.stdout.ptr;
        out_len.* = result.stdout.len;
    }
    if (result.stderr.len > 0) {
        err_ptr.* = result.stderr.ptr;
        err_len.* = result.stderr.len;
    }
}

// ─── Simple synchronous exec (no capture) ───

pub fn stz_system_exec(cmd: [*c]const u8, cmd_len: usize) callconv(.c) c_int {
    if (cmd == null or cmd_len == 0) return -1;
    const command = cmd[0..cmd_len];

    const shell = getShell();
    const argv: []const []const u8 = if (shell.flag) |f|
        &[_][]const u8{ shell.name, f, command }
    else
        &[_][]const u8{ shell.name, command };

    var child = std.process.Child.init(argv, gpa);
    child.create_no_window = true;
    child.spawn() catch return -1;
    const term = child.wait() catch return -1;
    return switch (term) {
        .Exited => |c| @intCast(c),
        else => -1,
    };
}

// ─── Environment ───

pub fn stz_system_env(name: [*c]const u8, name_len: usize, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    if (name == null or name_len == 0) return 0;
    const key = name[0..name_len];

    const key_z = gpa.allocSentinel(u8, key.len, 0) catch return 0;
    defer gpa.free(key_z[0 .. key.len + 1]);
    @memcpy(key_z[0..key.len], key);

    const val = std.c.getenv(key_z) orelse return 0;
    const val_slice = mem.span(val);
    if (val_slice.len > buf_len) return 0;
    @memcpy(buf[0..val_slice.len], val_slice);
    return val_slice.len;
}

// ─── Environment (read / write / enumerate) ───
//
// The existing stz_system_env above reads via std.c.getenv (the CRT copy of
// the environment). The functions here read and write the OS-authoritative
// store -- getEnvVarOwned reads it, and on Windows SetEnvironmentVariableW
// writes it -- so a value set here is (a) seen by a subsequent get here and
// (b) inherited by child processes spawned afterwards. That consistency is
// the whole point of exposing set; get and set must share one store.
//
// env_get / env_list / cwd_get return an OWNED buffer freed with
// stz_system_run_free (only len > 0 is returned, matching the module's
// convention).

pub fn stz_system_env_get(name: [*c]const u8, name_len: usize, out_len: *usize) callconv(.c) [*c]u8 {
    out_len.* = 0;
    if (name == null or name_len == 0) return null;
    const val = std.process.getEnvVarOwned(gpa, name[0..name_len]) catch return null;
    if (val.len == 0) {
        gpa.free(val);
        return null;
    }
    out_len.* = val.len;
    return val.ptr;
}

pub fn stz_system_env_set(name: [*c]const u8, name_len: usize, val: [*c]const u8, val_len: usize) callconv(.c) c_int {
    if (name == null or name_len == 0) return 0;
    const key = name[0..name_len];
    const value = if (val != null and val_len > 0) val[0..val_len] else "";

    if (builtin.os.tag == .windows) {
        const key_w = std.unicode.utf8ToUtf16LeAllocZ(gpa, key) catch return 0;
        defer gpa.free(key_w);
        const val_w = std.unicode.utf8ToUtf16LeAllocZ(gpa, value) catch return 0;
        defer gpa.free(val_w);
        return if (SetEnvironmentVariableW(key_w.ptr, val_w.ptr) == 0) 0 else 1;
    } else {
        const key_z = gpa.dupeZ(u8, key) catch return 0;
        defer gpa.free(key_z);
        const val_z = gpa.dupeZ(u8, value) catch return 0;
        defer gpa.free(val_z);
        return if (std.c.setenv(key_z, val_z, 1) == 0) 1 else 0;
    }
}

pub fn stz_system_env_unset(name: [*c]const u8, name_len: usize) callconv(.c) c_int {
    if (name == null or name_len == 0) return 0;
    const key = name[0..name_len];

    if (builtin.os.tag == .windows) {
        const key_w = std.unicode.utf8ToUtf16LeAllocZ(gpa, key) catch return 0;
        defer gpa.free(key_w);
        // A null value deletes the variable.
        return if (SetEnvironmentVariableW(key_w.ptr, null) == 0) 0 else 1;
    } else {
        const key_z = gpa.dupeZ(u8, key) catch return 0;
        defer gpa.free(key_z);
        _ = std.c.unsetenv(key_z);
        return 1;
    }
}

// Whole environment as "KEY=VALUE\0KEY=VALUE\0..." (drained bridge-side into a
// Ring list, like the dir listing).
pub fn stz_system_env_list(out_len: *usize) callconv(.c) [*c]u8 {
    out_len.* = 0;
    var envmap = std.process.getEnvMap(gpa) catch return null;
    defer envmap.deinit();

    var buf = std.ArrayList(u8){};
    errdefer buf.deinit(gpa);

    var it = envmap.iterator();
    while (it.next()) |kv| {
        buf.appendSlice(gpa, kv.key_ptr.*) catch return null;
        buf.append(gpa, '=') catch return null;
        buf.appendSlice(gpa, kv.value_ptr.*) catch return null;
        buf.append(gpa, 0) catch return null;
    }

    if (buf.items.len == 0) {
        buf.deinit(gpa);
        return null;
    }
    const owned = buf.toOwnedSlice(gpa) catch return null;
    out_len.* = owned.len;
    return owned.ptr;
}

// ─── Working directory ───

pub fn stz_system_cwd_get(out_len: *usize) callconv(.c) [*c]u8 {
    out_len.* = 0;
    const cwd = std.process.getCwdAlloc(gpa) catch return null;
    if (cwd.len == 0) {
        gpa.free(cwd);
        return null;
    }
    out_len.* = cwd.len;
    return cwd.ptr;
}

pub fn stz_system_cwd_set(path: [*c]const u8, path_len: usize) callconv(.c) c_int {
    if (path == null or path_len == 0) return 0;
    std.posix.chdir(path[0..path_len]) catch return 0;
    return 1;
}

// ─── Host / user / machine ───

pub fn stz_system_hostname(buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    if (builtin.os.tag == .windows) {
        // COMPUTERNAME is always present; avoids winsock init for gethostname.
        const val = std.process.getEnvVarOwned(gpa, "COMPUTERNAME") catch return 0;
        defer gpa.free(val);
        if (val.len == 0 or val.len > buf_len) return 0;
        @memcpy(buf[0..val.len], val);
        return val.len;
    }
    var hbuf: [std.posix.HOST_NAME_MAX]u8 = undefined;
    const name = std.posix.gethostname(&hbuf) catch return 0;
    if (name.len > buf_len) return 0;
    @memcpy(buf[0..name.len], name);
    return name.len;
}

pub fn stz_system_username(buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    const key = if (builtin.os.tag == .windows) "USERNAME" else "USER";
    const val = std.process.getEnvVarOwned(gpa, key) catch return 0;
    defer gpa.free(val);
    if (val.len == 0 or val.len > buf_len) return 0;
    @memcpy(buf[0..val.len], val);
    return val.len;
}

pub fn stz_system_cpu_count() callconv(.c) c_int {
    const n = std.Thread.getCpuCount() catch return -1;
    return @intCast(n);
}

// ─── Platform info ───

pub fn stz_system_is_windows() callconv(.c) c_int {
    return if (@import("builtin").os.tag == .windows) 1 else 0;
}

pub fn stz_system_is_linux() callconv(.c) c_int {
    return if (@import("builtin").os.tag == .linux) 1 else 0;
}

pub fn stz_system_is_macos() callconv(.c) c_int {
    return if (@import("builtin").os.tag == .macos) 1 else 0;
}

// ─── Tests ───

test "platform detection" {
    const w = stz_system_is_windows();
    const l = stz_system_is_linux();
    const m = stz_system_is_macos();
    try std.testing.expect(w + l + m <= 1);
}

test "platform detection: exactly one true on known OS" {
    const w = stz_system_is_windows();
    const l = stz_system_is_linux();
    const m = stz_system_is_macos();
    const os = @import("builtin").os.tag;
    if (os == .windows or os == .linux or os == .macos) {
        try std.testing.expectEqual(@as(c_int, 1), w + l + m);
    }
}

test "platform detection: individual values are 0 or 1" {
    try std.testing.expect(stz_system_is_windows() == 0 or stz_system_is_windows() == 1);
    try std.testing.expect(stz_system_is_linux() == 0 or stz_system_is_linux() == 1);
    try std.testing.expect(stz_system_is_macos() == 0 or stz_system_is_macos() == 1);
}

test "system env: empty name returns 0" {
    var buf: [256]u8 = undefined;
    const len = stz_system_env("", 0, &buf, buf.len);
    try std.testing.expectEqual(@as(usize, 0), len);
}

test "system env: null name returns 0" {
    var buf: [256]u8 = undefined;
    const len = stz_system_env(null, 0, &buf, buf.len);
    try std.testing.expectEqual(@as(usize, 0), len);
}

test "system env: PATH exists" {
    var buf: [4096]u8 = undefined;
    const key = if (@import("builtin").os.tag == .windows) "PATH" else "PATH";
    const len = stz_system_env(key.ptr, key.len, &buf, buf.len);
    // PATH should exist on all platforms
    try std.testing.expect(len > 0);
}

test "system env: nonexistent var returns 0" {
    var buf: [256]u8 = undefined;
    const key = "ZIN_NONEXISTENT_VAR_12345";
    const len = stz_system_env(key.ptr, key.len, &buf, buf.len);
    try std.testing.expectEqual(@as(usize, 0), len);
}

test "system exec: null command returns -1" {
    const result = stz_system_exec(null, 0);
    try std.testing.expectEqual(@as(c_int, -1), result);
}

test "system exec: empty command returns -1" {
    const result = stz_system_exec("", 0);
    try std.testing.expectEqual(@as(c_int, -1), result);
}

test "system run: null command returns null" {
    var out_len: usize = 0;
    var err_len: usize = 0;
    var exit_code: c_int = 0;
    const ptr = stz_system_run(null, 0, &out_len, &err_len, &exit_code);
    try std.testing.expect(ptr == null);
    try std.testing.expectEqual(@as(c_int, -1), exit_code);
}

test "system run: empty command returns null" {
    var out_len: usize = 0;
    var err_len: usize = 0;
    var exit_code: c_int = 0;
    const ptr = stz_system_run("", 0, &out_len, &err_len, &exit_code);
    try std.testing.expect(ptr == null);
    try std.testing.expectEqual(@as(c_int, -1), exit_code);
}

test "system run free: null pointer is safe" {
    stz_system_run_free(null, 0);
    stz_system_run_free(null, 100);
}

test "getShell returns valid shell" {
    const shell = getShell();
    try std.testing.expect(shell.name.len > 0);
    try std.testing.expect(shell.flag != null);
}
