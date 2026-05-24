const std = @import("std");

// ── Stopwatch (nanosecond precision) ─────────────────────────

var watches: [64]i128 = [_]i128{0} ** 64;
var watch_running: [64]bool = [_]bool{false} ** 64;
var watch_elapsed: [64]i128 = [_]i128{0} ** 64;

fn now() i128 {
    return std.time.nanoTimestamp();
}

pub fn watch_start(id: u32) callconv(.c) i32 {
    if (id >= 64) return -1;
    watches[id] = now();
    watch_running[id] = true;
    watch_elapsed[id] = 0;
    return 0;
}

pub fn watch_stop(id: u32) callconv(.c) i32 {
    if (id >= 64) return -1;
    if (!watch_running[id]) return -2;
    watch_elapsed[id] += now() - watches[id];
    watch_running[id] = false;
    return 0;
}

pub fn watch_resume(id: u32) callconv(.c) i32 {
    if (id >= 64) return -1;
    if (watch_running[id]) return -2;
    watches[id] = now();
    watch_running[id] = true;
    return 0;
}

pub fn watch_reset(id: u32) callconv(.c) i32 {
    if (id >= 64) return -1;
    watches[id] = 0;
    watch_running[id] = false;
    watch_elapsed[id] = 0;
    return 0;
}

pub fn watch_elapsed_ns(id: u32) callconv(.c) f64 {
    if (id >= 64) return -1.0;
    var total = watch_elapsed[id];
    if (watch_running[id]) {
        total += now() - watches[id];
    }
    return @floatFromInt(total);
}

pub fn watch_elapsed_us(id: u32) callconv(.c) f64 {
    return watch_elapsed_ns(id) / 1000.0;
}

pub fn watch_elapsed_ms(id: u32) callconv(.c) f64 {
    return watch_elapsed_ns(id) / 1_000_000.0;
}

pub fn watch_elapsed_s(id: u32) callconv(.c) f64 {
    return watch_elapsed_ns(id) / 1_000_000_000.0;
}

pub fn watch_is_running(id: u32) callconv(.c) i32 {
    if (id >= 64) return -1;
    return if (watch_running[id]) 1 else 0;
}

// ── Timestamp ────────────────────────────────────────────────

pub fn watch_timestamp_ns() callconv(.c) f64 {
    return @floatFromInt(now());
}

pub fn watch_timestamp_ms() callconv(.c) f64 {
    return @as(f64, @floatFromInt(now())) / 1_000_000.0;
}

// ── C ABI exports ────────────────────────────────────────────

pub export fn stz_watch_start(id: u32) callconv(.c) i32 { return watch_start(id); }
pub export fn stz_watch_stop(id: u32) callconv(.c) i32 { return watch_stop(id); }
pub export fn stz_watch_resume(id: u32) callconv(.c) i32 { return watch_resume(id); }
pub export fn stz_watch_reset(id: u32) callconv(.c) i32 { return watch_reset(id); }
pub export fn stz_watch_elapsed_ns(id: u32) callconv(.c) f64 { return watch_elapsed_ns(id); }
pub export fn stz_watch_elapsed_us(id: u32) callconv(.c) f64 { return watch_elapsed_us(id); }
pub export fn stz_watch_elapsed_ms(id: u32) callconv(.c) f64 { return watch_elapsed_ms(id); }
pub export fn stz_watch_elapsed_s(id: u32) callconv(.c) f64 { return watch_elapsed_s(id); }
pub export fn stz_watch_is_running(id: u32) callconv(.c) i32 { return watch_is_running(id); }
pub export fn stz_watch_timestamp_ns() callconv(.c) f64 { return watch_timestamp_ns(); }
pub export fn stz_watch_timestamp_ms() callconv(.c) f64 { return watch_timestamp_ms(); }

// ── Tests ────────────────────────────────────────────────────

test "watch: start/stop/elapsed" {
    _ = watch_start(0);
    try std.testing.expectEqual(@as(i32, 1), watch_is_running(0));
    _ = watch_stop(0);
    try std.testing.expectEqual(@as(i32, 0), watch_is_running(0));
    const elapsed = watch_elapsed_ns(0);
    try std.testing.expect(elapsed >= 0);
}

test "watch: resume" {
    _ = watch_start(1);
    _ = watch_stop(1);
    try std.testing.expectEqual(@as(i32, 0), watch_resume(1));
    try std.testing.expectEqual(@as(i32, 1), watch_is_running(1));
    _ = watch_stop(1);
}

test "watch: reset clears" {
    _ = watch_start(2);
    _ = watch_stop(2);
    _ = watch_reset(2);
    try std.testing.expectApproxEqAbs(@as(f64, 0.0), watch_elapsed_ns(2), 1.0);
}

test "watch: bounds check" {
    try std.testing.expectEqual(@as(i32, -1), watch_start(64));
    try std.testing.expectEqual(@as(i32, -1), watch_is_running(65));
}

test "watch: timestamp" {
    const ts = watch_timestamp_ns();
    try std.testing.expect(ts > 0);
    const ms = watch_timestamp_ms();
    try std.testing.expect(ms > 0);
}

test "watch: unit conversions" {
    _ = watch_start(3);
    _ = watch_stop(3);
    const us = watch_elapsed_us(3);
    const ms = watch_elapsed_ms(3);
    const s = watch_elapsed_s(3);
    try std.testing.expect(us >= 0);
    try std.testing.expect(ms >= 0);
    try std.testing.expect(s >= 0);
}
