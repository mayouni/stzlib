const std = @import("std");

// ─── Section Merge Engine ───
// Merge ordered sections (start, end) into non-overlapping ranges.

const MAX_SECTIONS: usize = 256;

const Section = struct {
    start: i64 = 0,
    end: i64 = 0,
    active: bool = false,
};

var sections: [MAX_SECTIONS]Section = [_]Section{.{}} ** MAX_SECTIONS;
var section_count: usize = 0;

// ─── C ABI ───

pub export fn stz_sm_add(start: i64, end: i64) i32 {
    if (section_count >= MAX_SECTIONS) return -1;
    for (0..MAX_SECTIONS) |i| {
        if (!sections[i].active) {
            sections[i] = .{ .start = start, .end = end, .active = true };
            section_count += 1;
            return @intCast(i);
        }
    }
    return -1;
}

pub export fn stz_sm_count() i32 {
    return @intCast(section_count);
}

pub export fn stz_sm_merge(out_starts: [*]i64, out_ends: [*]i64) i32 {
    // collect active sections
    var buf_starts: [MAX_SECTIONS]i64 = undefined;
    var buf_ends: [MAX_SECTIONS]i64 = undefined;
    var n: usize = 0;
    for (0..MAX_SECTIONS) |i| {
        if (sections[i].active) {
            buf_starts[n] = sections[i].start;
            buf_ends[n] = sections[i].end;
            n += 1;
        }
    }
    if (n == 0) return 0;
    // sort by start (insertion sort)
    for (1..n) |j| {
        const ks = buf_starts[j];
        const ke = buf_ends[j];
        var k: usize = j;
        while (k > 0 and buf_starts[k - 1] > ks) {
            buf_starts[k] = buf_starts[k - 1];
            buf_ends[k] = buf_ends[k - 1];
            k -= 1;
        }
        buf_starts[k] = ks;
        buf_ends[k] = ke;
    }
    // merge overlapping
    out_starts[0] = buf_starts[0];
    out_ends[0] = buf_ends[0];
    var merged: usize = 0;
    for (1..n) |i| {
        if (buf_starts[i] <= out_ends[merged]) {
            out_ends[merged] = @max(out_ends[merged], buf_ends[i]);
        } else {
            merged += 1;
            out_starts[merged] = buf_starts[i];
            out_ends[merged] = buf_ends[i];
        }
    }
    return @intCast(merged + 1);
}

pub export fn stz_sm_contains(point: i64) i32 {
    for (0..MAX_SECTIONS) |i| {
        if (sections[i].active and point >= sections[i].start and point <= sections[i].end) return 1;
    }
    return 0;
}

pub export fn stz_sm_total_span() i64 {
    var total: i64 = 0;
    // merge first, then sum
    var out_starts: [MAX_SECTIONS]i64 = undefined;
    var out_ends: [MAX_SECTIONS]i64 = undefined;
    const merged = stz_sm_merge(&out_starts, &out_ends);
    const m: usize = @intCast(merged);
    for (0..m) |i| {
        total += out_ends[i] - out_starts[i];
    }
    return total;
}

pub export fn stz_sm_overlap_count() i32 {
    var overlaps: i32 = 0;
    var indices: [MAX_SECTIONS]usize = undefined;
    var n: usize = 0;
    for (0..MAX_SECTIONS) |i| {
        if (sections[i].active) {
            indices[n] = i;
            n += 1;
        }
    }
    for (0..n) |i| {
        for ((i + 1)..n) |j| {
            const a = indices[i];
            const b = indices[j];
            if (sections[a].start <= sections[b].end and sections[b].start <= sections[a].end) {
                overlaps += 1;
            }
        }
    }
    return overlaps;
}

pub export fn stz_sm_clear() void {
    for (0..MAX_SECTIONS) |i| {
        sections[i].active = false;
    }
    section_count = 0;
}

// ─── Tests ───

test "add and count" {
    stz_sm_clear();
    _ = stz_sm_add(0, 10);
    _ = stz_sm_add(5, 15);
    try std.testing.expectEqual(@as(i32, 2), stz_sm_count());
    stz_sm_clear();
}

test "merge overlapping" {
    stz_sm_clear();
    _ = stz_sm_add(0, 10);
    _ = stz_sm_add(5, 15);
    _ = stz_sm_add(20, 30);
    var starts: [256]i64 = undefined;
    var ends: [256]i64 = undefined;
    const n = stz_sm_merge(&starts, &ends);
    try std.testing.expectEqual(@as(i32, 2), n);
    try std.testing.expectEqual(@as(i64, 0), starts[0]);
    try std.testing.expectEqual(@as(i64, 15), ends[0]);
    try std.testing.expectEqual(@as(i64, 20), starts[1]);
    try std.testing.expectEqual(@as(i64, 30), ends[1]);
    stz_sm_clear();
}

test "contains point" {
    stz_sm_clear();
    _ = stz_sm_add(10, 20);
    try std.testing.expectEqual(@as(i32, 1), stz_sm_contains(15));
    try std.testing.expectEqual(@as(i32, 0), stz_sm_contains(25));
    stz_sm_clear();
}

test "total span" {
    stz_sm_clear();
    _ = stz_sm_add(0, 10);
    _ = stz_sm_add(5, 15);
    try std.testing.expectEqual(@as(i64, 15), stz_sm_total_span());
    stz_sm_clear();
}

test "overlap count" {
    stz_sm_clear();
    _ = stz_sm_add(0, 10);
    _ = stz_sm_add(5, 15);
    _ = stz_sm_add(20, 30);
    try std.testing.expectEqual(@as(i32, 1), stz_sm_overlap_count());
    stz_sm_clear();
}

test "clear" {
    stz_sm_clear();
    _ = stz_sm_add(0, 10);
    stz_sm_clear();
    try std.testing.expectEqual(@as(i32, 0), stz_sm_count());
}
