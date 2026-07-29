const std = @import("std");

// ── Stopwatch (nanosecond precision, MONOTONIC) ──────────────
//
// now() used to be std.time.nanoTimestamp() -- wall-clock UTC, which
// jumps on NTP corrections, so a stopwatch spanning a clock adjustment
// could report negative or wildly wrong elapsed time. Same defect the
// process-uptime fix removed (process.zig). The clock is now a
// monotonic std.time.Instant against a baseline captured at DLL load
// (watch_init, called from the bridge's registerAll), with a lazy
// fallback on first use. Consequence: watch_timestamp_ns/ms are
// monotonic nanos/millis SINCE MODULE LOAD, not since the Unix epoch
// -- the right semantics for a duration clock, and f64-exact at ns
// for ~104 days (Ring numbers are doubles). Wall time for absolute
// timestamps lives in time.zig (stz_time_wall_*).

var watches: [64]i128 = [_]i128{0} ** 64;
var watch_running: [64]bool = [_]bool{false} ** 64;
var watch_elapsed: [64]i128 = [_]i128{0} ** 64;

var g_base: ?std.time.Instant = null;

pub fn watch_init() callconv(.c) void {
    g_base = std.time.Instant.now() catch null;
}

fn now() i128 {
    if (g_base == null) {
        g_base = std.time.Instant.now() catch return 0;
    }
    const base = g_base orelse return 0;
    const t = std.time.Instant.now() catch return 0;
    return @intCast(t.since(base));
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

// ── Timestamp (monotonic, since module load) ─────────────────

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

test "watch: timestamp is monotonic since load, not the epoch" {
    std.Thread.sleep(2 * std.time.ns_per_ms);
    const ts = watch_timestamp_ns();
    try std.testing.expect(ts > 0);
    const ms = watch_timestamp_ms();
    try std.testing.expect(ms > 0);
    // Regression pin (same property as the process-uptime fix): a
    // wall-clock timestamp would be ~1.7e18 ns since 1970; a monotonic
    // since-load one is far under an hour in a test run.
    try std.testing.expect(ms < 3_600_000.0);
    // And it advances.
    std.Thread.sleep(2 * std.time.ns_per_ms);
    try std.testing.expect(watch_timestamp_ns() > ts);
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
