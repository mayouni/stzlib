const std = @import("std");

// ── Simple Profiler (named timers with call counts) ────────

const MAX_TIMERS = 128;
const MAX_NAME = 64;

const Timer = struct {
    name: [MAX_NAME]u8 = [_]u8{0} ** MAX_NAME,
    name_len: usize = 0,
    total_ns: i128 = 0,
    start_ns: i128 = 0,
    calls: u64 = 0,
    running: bool = false,
    active: bool = false,
};

var timers: [MAX_TIMERS]Timer = [_]Timer{.{}} ** MAX_TIMERS;

fn now() i128 {
    return std.time.nanoTimestamp();
}

fn findTimer(name_ptr: [*]const u8, name_len: usize) ?usize {
    const name = name_ptr[0..name_len];
    for (0..MAX_TIMERS) |i| {
        if (timers[i].active and timers[i].name_len == name_len and
            std.mem.eql(u8, timers[i].name[0..name_len], name))
        {
            return i;
        }
    }
    return null;
}

fn findFree() ?usize {
    for (0..MAX_TIMERS) |i| {
        if (!timers[i].active) return i;
    }
    return null;
}

pub fn profiler_begin(name_ptr: [*]const u8, name_len: usize) callconv(.c) i32 {
    if (name_len > MAX_NAME) return -1;
    var idx = findTimer(name_ptr, name_len);
    if (idx == null) {
        idx = findFree();
        if (idx == null) return -2;
        const i = idx.?;
        @memcpy(timers[i].name[0..name_len], name_ptr[0..name_len]);
        timers[i].name_len = name_len;
        timers[i].total_ns = 0;
        timers[i].calls = 0;
        timers[i].active = true;
    }
    const i = idx.?;
    if (timers[i].running) return -3;
    timers[i].start_ns = now();
    timers[i].running = true;
    return 0;
}

pub fn profiler_end(name_ptr: [*]const u8, name_len: usize) callconv(.c) i32 {
    if (findTimer(name_ptr, name_len)) |i| {
        if (!timers[i].running) return -2;
        timers[i].total_ns += now() - timers[i].start_ns;
        timers[i].calls += 1;
        timers[i].running = false;
        return 0;
    }
    return -1;
}

pub fn profiler_total_ns(name_ptr: [*]const u8, name_len: usize) callconv(.c) f64 {
    if (findTimer(name_ptr, name_len)) |i| {
        return @floatFromInt(timers[i].total_ns);
    }
    return -1.0;
}

pub fn profiler_total_ms(name_ptr: [*]const u8, name_len: usize) callconv(.c) f64 {
    const ns = profiler_total_ns(name_ptr, name_len);
    if (ns < 0) return -1.0;
    return ns / 1_000_000.0;
}

pub fn profiler_calls(name_ptr: [*]const u8, name_len: usize) callconv(.c) u64 {
    if (findTimer(name_ptr, name_len)) |i| {
        return timers[i].calls;
    }
    return 0;
}

pub fn profiler_avg_ns(name_ptr: [*]const u8, name_len: usize) callconv(.c) f64 {
    if (findTimer(name_ptr, name_len)) |i| {
        if (timers[i].calls == 0) return 0.0;
        return @as(f64, @floatFromInt(timers[i].total_ns)) / @as(f64, @floatFromInt(timers[i].calls));
    }
    return -1.0;
}

pub fn profiler_reset(name_ptr: [*]const u8, name_len: usize) callconv(.c) i32 {
    if (findTimer(name_ptr, name_len)) |i| {
        timers[i].total_ns = 0;
        timers[i].calls = 0;
        timers[i].running = false;
        return 0;
    }
    return -1;
}

pub fn profiler_clear() callconv(.c) void {
    for (0..MAX_TIMERS) |i| timers[i].active = false;
}

pub fn profiler_count() callconv(.c) u32 {
    var count: u32 = 0;
    for (0..MAX_TIMERS) |i| {
        if (timers[i].active) count += 1;
    }
    return count;
}

// ── C ABI exports ────────────────────────────────────────────

pub export fn stz_profiler_begin(p: [*]const u8, l: usize) callconv(.c) i32 { return profiler_begin(p, l); }
pub export fn stz_profiler_end(p: [*]const u8, l: usize) callconv(.c) i32 { return profiler_end(p, l); }
pub export fn stz_profiler_total_ns(p: [*]const u8, l: usize) callconv(.c) f64 { return profiler_total_ns(p, l); }
pub export fn stz_profiler_total_ms(p: [*]const u8, l: usize) callconv(.c) f64 { return profiler_total_ms(p, l); }
pub export fn stz_profiler_calls(p: [*]const u8, l: usize) callconv(.c) u64 { return profiler_calls(p, l); }
pub export fn stz_profiler_avg_ns(p: [*]const u8, l: usize) callconv(.c) f64 { return profiler_avg_ns(p, l); }
pub export fn stz_profiler_reset(p: [*]const u8, l: usize) callconv(.c) i32 { return profiler_reset(p, l); }
pub export fn stz_profiler_clear() callconv(.c) void { profiler_clear(); }
pub export fn stz_profiler_count() callconv(.c) u32 { return profiler_count(); }

// ── Tests ────────────────────────────────────────────────────

test "profiler: begin/end" {
    profiler_clear();
    try std.testing.expectEqual(@as(i32, 0), profiler_begin("test".ptr, 4));
    try std.testing.expectEqual(@as(i32, 0), profiler_end("test".ptr, 4));
    try std.testing.expectEqual(@as(u64, 1), profiler_calls("test".ptr, 4));
}

test "profiler: total" {
    profiler_clear();
    _ = profiler_begin("t".ptr, 1);
    _ = profiler_end("t".ptr, 1);
    const ns = profiler_total_ns("t".ptr, 1);
    try std.testing.expect(ns >= 0);
}

test "profiler: multiple calls" {
    profiler_clear();
    _ = profiler_begin("m".ptr, 1);
    _ = profiler_end("m".ptr, 1);
    _ = profiler_begin("m".ptr, 1);
    _ = profiler_end("m".ptr, 1);
    try std.testing.expectEqual(@as(u64, 2), profiler_calls("m".ptr, 1));
}

test "profiler: avg" {
    profiler_clear();
    _ = profiler_begin("a".ptr, 1);
    _ = profiler_end("a".ptr, 1);
    const avg = profiler_avg_ns("a".ptr, 1);
    try std.testing.expect(avg >= 0);
}

test "profiler: count/clear" {
    profiler_clear();
    _ = profiler_begin("x".ptr, 1);
    _ = profiler_end("x".ptr, 1);
    _ = profiler_begin("y".ptr, 1);
    _ = profiler_end("y".ptr, 1);
    try std.testing.expectEqual(@as(u32, 2), profiler_count());
    profiler_clear();
    try std.testing.expectEqual(@as(u32, 0), profiler_count());
}

test "profiler: reset" {
    profiler_clear();
    _ = profiler_begin("r".ptr, 1);
    _ = profiler_end("r".ptr, 1);
    _ = profiler_reset("r".ptr, 1);
    try std.testing.expectEqual(@as(u64, 0), profiler_calls("r".ptr, 1));
}
