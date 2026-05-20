// Softanza Engine -- System/Process Operations (Tier 3)
//
// Replaces QProcess/QStringList with Zig std.process.
// All functions use C ABI for Ring FFI compatibility.

const std = @import("std");
const mem = std.mem;
const gpa = std.heap.c_allocator;

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
