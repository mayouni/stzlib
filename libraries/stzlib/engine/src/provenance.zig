const std = @import("std");

// ─── Provenance Tracking Engine ───
// 128-slot provenance records: who created/modified what, when, from where.

const MAX_RECORDS: usize = 128;
const MAX_STR: usize = 128;

const Record = struct {
    entity: [MAX_STR]u8 = undefined,
    entity_len: usize = 0,
    origin: [MAX_STR]u8 = undefined,
    origin_len: usize = 0,
    author: [MAX_STR]u8 = undefined,
    author_len: usize = 0,
    timestamp: i64 = 0,
    version: i32 = 1,
    active: bool = false,
};

var records: [MAX_RECORDS]Record = [_]Record{.{}} ** MAX_RECORDS;
var record_count: usize = 0;

fn findFreeSlot() ?usize {
    for (0..MAX_RECORDS) |idx| {
        if (!records[idx].active) return idx;
    }
    return null;
}

fn copyStr(dest: *[MAX_STR]u8, src: [*]const u8, len: usize) usize {
    const clamped = @min(len, MAX_STR);
    @memcpy(dest[0..clamped], src[0..clamped]);
    return clamped;
}

// ─── C ABI ───

pub export fn stz_prov_add(entity: [*]const u8, entity_len: usize, origin: [*]const u8, origin_len: usize, author: [*]const u8, author_len: usize, timestamp: i64) i32 {
    const slot = findFreeSlot() orelse return -1;
    records[slot].entity_len = copyStr(&records[slot].entity, entity, entity_len);
    records[slot].origin_len = copyStr(&records[slot].origin, origin, origin_len);
    records[slot].author_len = copyStr(&records[slot].author, author, author_len);
    records[slot].timestamp = timestamp;
    records[slot].version = 1;
    records[slot].active = true;
    record_count += 1;
    return @intCast(slot);
}

pub export fn stz_prov_count() i32 {
    return @intCast(record_count);
}

pub export fn stz_prov_entity(idx: i32, out: [*]u8) i32 {
    if (idx < 0 or idx >= @as(i32, MAX_RECORDS)) return 0;
    const i: usize = @intCast(idx);
    if (!records[i].active) return 0;
    const len = records[i].entity_len;
    @memcpy(out[0..len], records[i].entity[0..len]);
    return @intCast(len);
}

pub export fn stz_prov_origin(idx: i32, out: [*]u8) i32 {
    if (idx < 0 or idx >= @as(i32, MAX_RECORDS)) return 0;
    const i: usize = @intCast(idx);
    if (!records[i].active) return 0;
    const len = records[i].origin_len;
    @memcpy(out[0..len], records[i].origin[0..len]);
    return @intCast(len);
}

pub export fn stz_prov_author(idx: i32, out: [*]u8) i32 {
    if (idx < 0 or idx >= @as(i32, MAX_RECORDS)) return 0;
    const i: usize = @intCast(idx);
    if (!records[i].active) return 0;
    const len = records[i].author_len;
    @memcpy(out[0..len], records[i].author[0..len]);
    return @intCast(len);
}

pub export fn stz_prov_time(idx: i32) i64 {
    if (idx < 0 or idx >= @as(i32, MAX_RECORDS)) return 0;
    const i: usize = @intCast(idx);
    if (!records[i].active) return 0;
    return records[i].timestamp;
}

pub export fn stz_prov_version(idx: i32) i32 {
    if (idx < 0 or idx >= @as(i32, MAX_RECORDS)) return 0;
    const i: usize = @intCast(idx);
    if (!records[i].active) return 0;
    return records[i].version;
}

pub export fn stz_prov_bump_version(idx: i32) i32 {
    if (idx < 0 or idx >= @as(i32, MAX_RECORDS)) return 0;
    const i: usize = @intCast(idx);
    if (!records[i].active) return 0;
    records[i].version += 1;
    return records[i].version;
}

pub export fn stz_prov_remove(idx: i32) void {
    if (idx < 0 or idx >= @as(i32, MAX_RECORDS)) return;
    const i: usize = @intCast(idx);
    if (records[i].active) {
        records[i].active = false;
        record_count -= 1;
    }
}

pub export fn stz_prov_clear() void {
    for (0..MAX_RECORDS) |i| {
        records[i].active = false;
    }
    record_count = 0;
}

// ─── Tests ───

test "add and query provenance" {
    stz_prov_clear();
    const idx = stz_prov_add("data.csv", 8, "import", 6, "alice", 5, 1000);
    try std.testing.expect(idx >= 0);
    try std.testing.expectEqual(@as(i32, 1), stz_prov_count());

    var buf: [128]u8 = undefined;
    const elen = stz_prov_entity(idx, &buf);
    try std.testing.expectEqualSlices(u8, "data.csv", buf[0..@intCast(elen)]);

    const olen = stz_prov_origin(idx, &buf);
    try std.testing.expectEqualSlices(u8, "import", buf[0..@intCast(olen)]);

    const alen = stz_prov_author(idx, &buf);
    try std.testing.expectEqualSlices(u8, "alice", buf[0..@intCast(alen)]);

    try std.testing.expectEqual(@as(i64, 1000), stz_prov_time(idx));
    stz_prov_clear();
}

test "version bumping" {
    stz_prov_clear();
    const idx = stz_prov_add("file", 4, "src", 3, "bob", 3, 2000);
    try std.testing.expectEqual(@as(i32, 1), stz_prov_version(idx));
    _ = stz_prov_bump_version(idx);
    try std.testing.expectEqual(@as(i32, 2), stz_prov_version(idx));
    _ = stz_prov_bump_version(idx);
    try std.testing.expectEqual(@as(i32, 3), stz_prov_version(idx));
    stz_prov_clear();
}

test "remove provenance" {
    stz_prov_clear();
    const idx = stz_prov_add("x", 1, "y", 1, "z", 1, 100);
    try std.testing.expectEqual(@as(i32, 1), stz_prov_count());
    stz_prov_remove(idx);
    try std.testing.expectEqual(@as(i32, 0), stz_prov_count());
    try std.testing.expectEqual(@as(i32, 0), stz_prov_version(idx));
    stz_prov_clear();
}

test "clear all" {
    stz_prov_clear();
    _ = stz_prov_add("a", 1, "b", 1, "c", 1, 1);
    _ = stz_prov_add("d", 1, "e", 1, "f", 1, 2);
    try std.testing.expectEqual(@as(i32, 2), stz_prov_count());
    stz_prov_clear();
    try std.testing.expectEqual(@as(i32, 0), stz_prov_count());
}
