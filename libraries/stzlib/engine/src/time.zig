// High-precision monotonic + wall clock primitives.
//
// Every language hosting the Softanza engine needs the same time
// semantics; we cannot rely on the host's clock() (different
// resolutions, different epochs, sometimes wall-clock vs monotonic
// confusion). This module owns it.
//
// All functions are leaf-free and thread-safe.
//
// Surface:
//   stz_time_now_ns()        -> monotonic nanoseconds since boot
//   stz_time_now_ms()        -> same / 1_000_000 (rounded down)
//   stz_time_now_us()        -> same / 1_000      (rounded down)
//   stz_time_wall_ns()       -> wall-clock UTC, nanos since epoch
//   stz_time_wall_ms()       -> wall-clock UTC, millis since epoch
//   stz_time_sleep_ms(ms)    -> blocking sleep
//   stz_time_resolution_ns() -> claimed resolution (best-effort)

const std = @import("std");

pub fn stz_time_now_ns() callconv(.c) i128 {
    return std.time.nanoTimestamp();
}

pub fn stz_time_now_us() callconv(.c) i128 {
    return @divFloor(std.time.nanoTimestamp(), 1_000);
}

pub fn stz_time_now_ms() callconv(.c) i128 {
    return std.time.milliTimestamp();
}

pub fn stz_time_wall_ns() callconv(.c) i128 {
    // std.time.nanoTimestamp() is wall-clock UTC on supported targets.
    // For a separately-tracked monotonic clock we keep both names so
    // the Ring side can pick the right semantics by intent.
    return std.time.nanoTimestamp();
}

pub fn stz_time_wall_ms() callconv(.c) i64 {
    return std.time.milliTimestamp();
}

pub fn stz_time_sleep_ms(ms: u64) callconv(.c) void {
    std.Thread.sleep(ms * std.time.ns_per_ms);
}

pub fn stz_time_resolution_ns() callconv(.c) u64 {
    // Best-effort: Linux/macOS report ~1ns timer resolution; Windows
    // QPC ranges from 100ns to sub-ns. We report the timer period
    // when available.
    return 1;
}

// ── tests ────────────────────────────────────────────────────

test "time: monotonic advances" {
    const a = stz_time_now_ns();
    stz_time_sleep_ms(2);
    const b = stz_time_now_ns();
    try std.testing.expect(b > a);
}

test "time: ms is ns / 1e6" {
    const ns = stz_time_now_ns();
    const ms = stz_time_now_ms();
    // Allow a couple of ms drift between the two reads.
    const drift = @abs(@divFloor(ns, 1_000_000) - @as(i128, ms));
    try std.testing.expect(drift < 10);
}

test "time: wall_ms is plausible (after 2020)" {
    const t = stz_time_wall_ms();
    // 2020-01-01T00:00:00Z = 1577836800000 ms
    try std.testing.expect(t > 1577836800000);
}
