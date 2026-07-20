const std = @import("std");

// ── Process Info (lightweight, no child spawning) ──────────

var proc_env_buf: [4096]u8 = undefined;
var proc_env_len: usize = 0;

pub fn process_pid() callconv(.c) i64 {
    if (@import("builtin").os.tag == .windows) {
        return @intCast(std.os.windows.GetCurrentProcessId());
    } else {
        return @intCast(std.os.linux.getpid());
    }
}

// UPTIME -- how long THIS process has been running, from a MONOTONIC clock.
//
// These used to return std.time.nanoTimestamp(), which is wall-clock time
// since the Unix EPOCH -- so uptime_s() answered ~1.75 billion (56 years),
// not "seconds since the process started". A caller asking how long its
// program had been up got the year, in seconds.
//
// The base instant is captured at DLL load (process_init, called from the
// bridge's ringlib_init) -- effectively process start, since stz_process.dll
// loads during library init. A lazy fallback captures it on first use if
// init never ran. std.time.Instant is monotonic, so uptime never jumps
// backwards on an NTP correction the way epoch time can.
var g_start: ?std.time.Instant = null;

pub fn process_init() callconv(.c) void {
    g_start = std.time.Instant.now() catch null;
}

fn uptimeNanos() u64 {
    if (g_start == null) {
        g_start = std.time.Instant.now() catch return 0;
    }
    const start = g_start orelse return 0;
    const now = std.time.Instant.now() catch return 0;
    return now.since(start);
}

pub fn process_uptime_ns() callconv(.c) f64 {
    return @floatFromInt(uptimeNanos());
}

pub fn process_uptime_ms() callconv(.c) f64 {
    return @as(f64, @floatFromInt(uptimeNanos())) / 1_000_000.0;
}

pub fn process_uptime_s() callconv(.c) f64 {
    return @as(f64, @floatFromInt(uptimeNanos())) / 1_000_000_000.0;
}

pub fn process_arch(out: [*]u8, max: usize) callconv(.c) i32 {
    const arch = @tagName(@import("builtin").cpu.arch);
    if (arch.len > max) return -1;
    @memcpy(out[0..arch.len], arch);
    return @intCast(arch.len);
}

pub fn process_os(out: [*]u8, max: usize) callconv(.c) i32 {
    const os_name = @tagName(@import("builtin").os.tag);
    if (os_name.len > max) return -1;
    @memcpy(out[0..os_name.len], os_name);
    return @intCast(os_name.len);
}

pub fn process_endian() callconv(.c) i32 {
    return if (@import("builtin").cpu.arch.endian() == .little) 0 else 1;
}

pub fn process_ptr_size() callconv(.c) i32 {
    return @sizeOf(usize);
}

// ── C ABI exports ────────────────────────────────────────────

pub export fn stz_process_init() callconv(.c) void { process_init(); }
pub export fn stz_process_pid() callconv(.c) i64 { return process_pid(); }
pub export fn stz_process_uptime_ns() callconv(.c) f64 { return process_uptime_ns(); }
pub export fn stz_process_uptime_ms() callconv(.c) f64 { return process_uptime_ms(); }
pub export fn stz_process_uptime_s() callconv(.c) f64 { return process_uptime_s(); }
pub export fn stz_process_arch(o: [*]u8, m: usize) callconv(.c) i32 { return process_arch(o, m); }
pub export fn stz_process_os(o: [*]u8, m: usize) callconv(.c) i32 { return process_os(o, m); }
pub export fn stz_process_endian() callconv(.c) i32 { return process_endian(); }
pub export fn stz_process_ptr_size() callconv(.c) i32 { return process_ptr_size(); }

// ── Tests ────────────────────────────────────────────────────

test "process: pid" {
    const pid = process_pid();
    try std.testing.expect(pid > 0);
}

test "process: uptime" {
    const ns = process_uptime_ns();
    try std.testing.expect(ns > 0);
    const ms = process_uptime_ms();
    try std.testing.expect(ms > 0);
}

test "process: arch" {
    var buf: [64]u8 = undefined;
    const len = process_arch(&buf, 64);
    try std.testing.expect(len > 0);
}

test "process: os" {
    var buf: [64]u8 = undefined;
    const len = process_os(&buf, 64);
    try std.testing.expect(len > 0);
}

test "process: endian" {
    const e = process_endian();
    try std.testing.expect(e == 0 or e == 1);
}

test "process: ptr_size" {
    const s = process_ptr_size();
    try std.testing.expect(s == 4 or s == 8);
}
