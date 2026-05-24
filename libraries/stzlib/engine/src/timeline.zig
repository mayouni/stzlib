const std = @import("std");

// ─── Timeline Event Engine ───
// 256-slot event store with timestamps (i64 epoch ms), labels, ordering.

const MAX_EVENTS: usize = 256;
const MAX_LABEL: usize = 128;

const Event = struct {
    label: [MAX_LABEL]u8 = undefined,
    label_len: usize = 0,
    timestamp: i64 = 0,
    active: bool = false,
};

var events: [MAX_EVENTS]Event = [_]Event{.{}} ** MAX_EVENTS;
var event_count: usize = 0;

fn findFreeSlot() ?usize {
    for (0..MAX_EVENTS) |i| {
        if (!events[i].active) return i;
    }
    return null;
}

// ─── C ABI ───

pub export fn stz_tl_add_event(label: [*]const u8, label_len: usize, timestamp: i64) i32 {
    const slot = findFreeSlot() orelse return -1;
    const clamped = @min(label_len, MAX_LABEL);
    @memcpy(events[slot].label[0..clamped], label[0..clamped]);
    events[slot].label_len = clamped;
    events[slot].timestamp = timestamp;
    events[slot].active = true;
    event_count += 1;
    return @intCast(slot);
}

pub export fn stz_tl_event_count() i32 {
    return @intCast(event_count);
}

pub export fn stz_tl_event_label(idx: i32, out: [*]u8) i32 {
    if (idx < 0 or idx >= @as(i32, MAX_EVENTS)) return 0;
    const i: usize = @intCast(idx);
    if (!events[i].active) return 0;
    const len = events[i].label_len;
    @memcpy(out[0..len], events[i].label[0..len]);
    return @intCast(len);
}

pub export fn stz_tl_event_time(idx: i32) i64 {
    if (idx < 0 or idx >= @as(i32, MAX_EVENTS)) return 0;
    const i: usize = @intCast(idx);
    if (!events[i].active) return 0;
    return events[i].timestamp;
}

pub export fn stz_tl_events_between(t1: i64, t2: i64, out_indices: [*]i32) i32 {
    const lo = @min(t1, t2);
    const hi = @max(t1, t2);
    var count: usize = 0;
    for (0..MAX_EVENTS) |i| {
        if (events[i].active and events[i].timestamp >= lo and events[i].timestamp <= hi) {
            out_indices[count] = @intCast(i);
            count += 1;
        }
    }
    return @intCast(count);
}

pub export fn stz_tl_events_sorted(out_indices: [*]i32) i32 {
    var indices: [MAX_EVENTS]usize = undefined;
    var n: usize = 0;
    for (0..MAX_EVENTS) |i| {
        if (events[i].active) {
            indices[n] = i;
            n += 1;
        }
    }
    // insertion sort by timestamp
    for (1..n) |j| {
        const key = indices[j];
        var k: usize = j;
        while (k > 0 and events[indices[k - 1]].timestamp > events[key].timestamp) {
            indices[k] = indices[k - 1];
            k -= 1;
        }
        indices[k] = key;
    }
    for (0..n) |i| {
        out_indices[i] = @intCast(indices[i]);
    }
    return @intCast(n);
}

pub export fn stz_tl_duration(idx1: i32, idx2: i32) i64 {
    if (idx1 < 0 or idx1 >= @as(i32, MAX_EVENTS)) return 0;
    if (idx2 < 0 or idx2 >= @as(i32, MAX_EVENTS)) return 0;
    const idx_a: usize = @intCast(idx1);
    const idx_b: usize = @intCast(idx2);
    if (!events[idx_a].active or !events[idx_b].active) return 0;
    const diff = events[idx_b].timestamp - events[idx_a].timestamp;
    return if (diff < 0) -diff else diff;
}

pub export fn stz_tl_remove(idx: i32) void {
    if (idx < 0 or idx >= @as(i32, MAX_EVENTS)) return;
    const i: usize = @intCast(idx);
    if (events[i].active) {
        events[i].active = false;
        event_count -= 1;
    }
}

pub export fn stz_tl_clear() void {
    for (0..MAX_EVENTS) |i| {
        events[i].active = false;
    }
    event_count = 0;
}

// ─── Tests ───

test "add and count events" {
    stz_tl_clear();
    const a = stz_tl_add_event("start", 5, 1000);
    const b = stz_tl_add_event("middle", 6, 2000);
    const c = stz_tl_add_event("end", 3, 3000);
    try std.testing.expect(a >= 0);
    try std.testing.expect(b >= 0);
    try std.testing.expect(c >= 0);
    try std.testing.expectEqual(@as(i32, 3), stz_tl_event_count());
    stz_tl_clear();
}

test "event label retrieval" {
    stz_tl_clear();
    const idx = stz_tl_add_event("hello", 5, 100);
    var buf: [128]u8 = undefined;
    const len = stz_tl_event_label(idx, &buf);
    try std.testing.expectEqual(@as(i32, 5), len);
    try std.testing.expectEqualSlices(u8, "hello", buf[0..@intCast(len)]);
    stz_tl_clear();
}

test "event time retrieval" {
    stz_tl_clear();
    const idx = stz_tl_add_event("ts", 2, 42000);
    try std.testing.expectEqual(@as(i64, 42000), stz_tl_event_time(idx));
    stz_tl_clear();
}

test "events between range" {
    stz_tl_clear();
    _ = stz_tl_add_event("a", 1, 100);
    _ = stz_tl_add_event("b", 1, 200);
    _ = stz_tl_add_event("c", 1, 300);
    _ = stz_tl_add_event("d", 1, 400);
    var out: [256]i32 = undefined;
    const n = stz_tl_events_between(150, 350, &out);
    try std.testing.expectEqual(@as(i32, 2), n);
    stz_tl_clear();
}

test "sorted events" {
    stz_tl_clear();
    _ = stz_tl_add_event("c", 1, 300);
    _ = stz_tl_add_event("a", 1, 100);
    _ = stz_tl_add_event("b", 1, 200);
    var out: [256]i32 = undefined;
    const n = stz_tl_events_sorted(&out);
    try std.testing.expectEqual(@as(i32, 3), n);
    try std.testing.expectEqual(@as(i64, 100), stz_tl_event_time(out[0]));
    try std.testing.expectEqual(@as(i64, 200), stz_tl_event_time(out[1]));
    try std.testing.expectEqual(@as(i64, 300), stz_tl_event_time(out[2]));
    stz_tl_clear();
}

test "duration and remove" {
    stz_tl_clear();
    const a = stz_tl_add_event("x", 1, 1000);
    const b = stz_tl_add_event("y", 1, 3500);
    try std.testing.expectEqual(@as(i64, 2500), stz_tl_duration(a, b));
    stz_tl_remove(a);
    try std.testing.expectEqual(@as(i32, 1), stz_tl_event_count());
    stz_tl_clear();
}
