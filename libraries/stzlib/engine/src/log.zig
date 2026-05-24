const std = @import("std");

// ── Log Level ────────────────────────────────────────────────

pub const LogLevel = enum(u8) {
    trace = 0,
    debug = 1,
    info = 2,
    warn = 3,
    err = 4,
    fatal = 5,
};

var current_level: LogLevel = .info;
var log_buffer: [4096]u8 = undefined;
var log_buffer_len: usize = 0;
var log_count: u64 = 0;
var log_enabled: bool = true;

// ── Level Control ────────────────────────────────────────────

pub fn log_set_level(level: u8) callconv(.c) void {
    if (level <= 5) current_level = @enumFromInt(level);
}

pub fn log_get_level() callconv(.c) u8 {
    return @intFromEnum(current_level);
}

pub fn log_enable() callconv(.c) void {
    log_enabled = true;
}

pub fn log_disable() callconv(.c) void {
    log_enabled = false;
}

pub fn log_is_enabled() callconv(.c) i32 {
    return if (log_enabled) 1 else 0;
}

// ── Logging ──────────────────────────────────────────────────

pub fn log_write(level: u8, msg_ptr: [*]const u8, msg_len: usize) callconv(.c) i32 {
    if (!log_enabled) return 0;
    if (level > 5) return -1;
    const lvl: LogLevel = @enumFromInt(level);
    if (@intFromEnum(lvl) < @intFromEnum(current_level)) return 0;

    const prefix = switch (lvl) {
        .trace => "[TRACE] ",
        .debug => "[DEBUG] ",
        .info => "[INFO]  ",
        .warn => "[WARN]  ",
        .err => "[ERROR] ",
        .fatal => "[FATAL] ",
    };

    const total = prefix.len + msg_len;
    if (total > log_buffer.len) return -2;

    @memcpy(log_buffer[0..prefix.len], prefix);
    if (msg_len > 0) {
        @memcpy(log_buffer[prefix.len .. prefix.len + msg_len], msg_ptr[0..msg_len]);
    }
    log_buffer_len = total;
    log_count += 1;
    return @intCast(total);
}

// ── Last Message ─────────────────────────────────────────────

pub fn log_last_message(out: [*]u8, max: usize) callconv(.c) i32 {
    if (log_buffer_len == 0) return 0;
    const n = @min(log_buffer_len, max);
    @memcpy(out[0..n], log_buffer[0..n]);
    return @intCast(n);
}

pub fn log_message_count() callconv(.c) u64 {
    return log_count;
}

pub fn log_clear() callconv(.c) void {
    log_buffer_len = 0;
    log_count = 0;
}

// ── Level Name ───────────────────────────────────────────────

pub fn log_level_name(level: u8, out: [*]u8, max: usize) callconv(.c) i32 {
    const name: []const u8 = switch (level) {
        0 => "TRACE",
        1 => "DEBUG",
        2 => "INFO",
        3 => "WARN",
        4 => "ERROR",
        5 => "FATAL",
        else => return -1,
    };
    if (name.len > max) return -2;
    @memcpy(out[0..name.len], name);
    return @intCast(name.len);
}

// ── C ABI exports ────────────────────────────────────────────

pub export fn stz_log_set_level(l: u8) callconv(.c) void { log_set_level(l); }
pub export fn stz_log_get_level() callconv(.c) u8 { return log_get_level(); }
pub export fn stz_log_enable() callconv(.c) void { log_enable(); }
pub export fn stz_log_disable() callconv(.c) void { log_disable(); }
pub export fn stz_log_is_enabled() callconv(.c) i32 { return log_is_enabled(); }
pub export fn stz_log_write(l: u8, p: [*]const u8, n: usize) callconv(.c) i32 { return log_write(l, p, n); }
pub export fn stz_log_last_message(o: [*]u8, m: usize) callconv(.c) i32 { return log_last_message(o, m); }
pub export fn stz_log_message_count() callconv(.c) u64 { return log_message_count(); }
pub export fn stz_log_clear() callconv(.c) void { log_clear(); }
pub export fn stz_log_level_name(l: u8, o: [*]u8, m: usize) callconv(.c) i32 { return log_level_name(l, o, m); }

// ── Tests ────────────────────────────────────────────────────

test "log: set/get level" {
    log_set_level(0);
    try std.testing.expectEqual(@as(u8, 0), log_get_level());
    log_set_level(3);
    try std.testing.expectEqual(@as(u8, 3), log_get_level());
}

test "log: write and read" {
    log_clear();
    log_set_level(0);
    const msg = "hello world";
    const len = log_write(2, msg.ptr, msg.len);
    try std.testing.expect(len > 0);

    var buf: [256]u8 = undefined;
    const read_len = log_last_message(&buf, 256);
    try std.testing.expect(read_len > 0);
    const result = buf[0..@intCast(read_len)];
    try std.testing.expect(std.mem.indexOf(u8, result, "hello world") != null);
}

test "log: level filtering" {
    log_clear();
    log_set_level(3);
    const len = log_write(1, "debug msg".ptr, 9);
    try std.testing.expectEqual(@as(i32, 0), len);
}

test "log: enable/disable" {
    log_enable();
    try std.testing.expectEqual(@as(i32, 1), log_is_enabled());
    log_disable();
    try std.testing.expectEqual(@as(i32, 0), log_is_enabled());
    const len = log_write(4, "error".ptr, 5);
    try std.testing.expectEqual(@as(i32, 0), len);
    log_enable();
}

test "log: message count" {
    log_clear();
    log_set_level(0);
    _ = log_write(2, "a".ptr, 1);
    _ = log_write(2, "b".ptr, 1);
    try std.testing.expectEqual(@as(u64, 2), log_message_count());
}

test "log: level name" {
    var buf: [32]u8 = undefined;
    const len = log_level_name(2, &buf, 32);
    try std.testing.expectEqualStrings("INFO", buf[0..@intCast(len)]);
    try std.testing.expectEqual(@as(i32, -1), log_level_name(6, &buf, 32));
}
