const std = @import("std");

// ── Key-Value Registry (string pairs, fixed slots) ─────────
// A simple name→value store for engine configuration, feature
// flags, metadata. Not a cache (no TTL/eviction).

const MAX_ENTRIES = 512;
const MAX_KEY_LEN = 128;
const MAX_VAL_LEN = 512;

const Entry = struct {
    key: [MAX_KEY_LEN]u8 = [_]u8{0} ** MAX_KEY_LEN,
    key_len: usize = 0,
    val: [MAX_VAL_LEN]u8 = [_]u8{0} ** MAX_VAL_LEN,
    val_len: usize = 0,
    active: bool = false,
};

var entries: [MAX_ENTRIES]Entry = [_]Entry{.{}} ** MAX_ENTRIES;

fn findEntry(key_ptr: [*]const u8, key_len: usize) ?usize {
    const key = key_ptr[0..key_len];
    for (0..MAX_ENTRIES) |i| {
        if (entries[i].active and entries[i].key_len == key_len and
            std.mem.eql(u8, entries[i].key[0..key_len], key))
        {
            return i;
        }
    }
    return null;
}

fn findFree() ?usize {
    for (0..MAX_ENTRIES) |i| {
        if (!entries[i].active) return i;
    }
    return null;
}

pub fn registry_set(key_ptr: [*]const u8, key_len: usize, val_ptr: [*]const u8, val_len: usize) callconv(.c) i32 {
    if (key_len > MAX_KEY_LEN or val_len > MAX_VAL_LEN) return -1;
    const idx = findEntry(key_ptr, key_len) orelse findFree() orelse return -2;
    @memcpy(entries[idx].key[0..key_len], key_ptr[0..key_len]);
    entries[idx].key_len = key_len;
    @memcpy(entries[idx].val[0..val_len], val_ptr[0..val_len]);
    entries[idx].val_len = val_len;
    entries[idx].active = true;
    return 0;
}

pub fn registry_get(key_ptr: [*]const u8, key_len: usize, out: [*]u8, max: usize) callconv(.c) i32 {
    if (findEntry(key_ptr, key_len)) |idx| {
        const vlen = entries[idx].val_len;
        if (vlen > max) return -1;
        @memcpy(out[0..vlen], entries[idx].val[0..vlen]);
        return @intCast(vlen);
    }
    return -2;
}

pub fn registry_has(key_ptr: [*]const u8, key_len: usize) callconv(.c) i32 {
    return if (findEntry(key_ptr, key_len) != null) 1 else 0;
}

pub fn registry_remove(key_ptr: [*]const u8, key_len: usize) callconv(.c) i32 {
    if (findEntry(key_ptr, key_len)) |idx| {
        entries[idx].active = false;
        return 0;
    }
    return -1;
}

pub fn registry_clear() callconv(.c) void {
    for (0..MAX_ENTRIES) |i| entries[i].active = false;
}

pub fn registry_count() callconv(.c) u32 {
    var count: u32 = 0;
    for (0..MAX_ENTRIES) |i| {
        if (entries[i].active) count += 1;
    }
    return count;
}

pub fn registry_key_at(index: u32, out: [*]u8, max: usize) callconv(.c) i32 {
    var seen: u32 = 0;
    for (0..MAX_ENTRIES) |i| {
        if (entries[i].active) {
            if (seen == index) {
                const klen = entries[i].key_len;
                if (klen > max) return -1;
                @memcpy(out[0..klen], entries[i].key[0..klen]);
                return @intCast(klen);
            }
            seen += 1;
        }
    }
    return -2;
}

// ── C ABI exports ────────────────────────────────────────────

pub export fn stz_registry_set(kp: [*]const u8, kl: usize, vp: [*]const u8, vl: usize) callconv(.c) i32 { return registry_set(kp, kl, vp, vl); }
pub export fn stz_registry_get(kp: [*]const u8, kl: usize, o: [*]u8, m: usize) callconv(.c) i32 { return registry_get(kp, kl, o, m); }
pub export fn stz_registry_has(kp: [*]const u8, kl: usize) callconv(.c) i32 { return registry_has(kp, kl); }
pub export fn stz_registry_remove(kp: [*]const u8, kl: usize) callconv(.c) i32 { return registry_remove(kp, kl); }
pub export fn stz_registry_clear() callconv(.c) void { registry_clear(); }
pub export fn stz_registry_count() callconv(.c) u32 { return registry_count(); }
pub export fn stz_registry_key_at(i: u32, o: [*]u8, m: usize) callconv(.c) i32 { return registry_key_at(i, o, m); }

// ── Tests ────────────────────────────────────────────────────

test "registry: set/get" {
    registry_clear();
    try std.testing.expectEqual(@as(i32, 0), registry_set("key1".ptr, 4, "val1".ptr, 4));
    var buf: [256]u8 = undefined;
    const len = registry_get("key1".ptr, 4, &buf, 256);
    try std.testing.expectEqualStrings("val1", buf[0..@intCast(len)]);
}

test "registry: has/remove" {
    registry_clear();
    _ = registry_set("x".ptr, 1, "y".ptr, 1);
    try std.testing.expectEqual(@as(i32, 1), registry_has("x".ptr, 1));
    _ = registry_remove("x".ptr, 1);
    try std.testing.expectEqual(@as(i32, 0), registry_has("x".ptr, 1));
}

test "registry: count/clear" {
    registry_clear();
    _ = registry_set("a".ptr, 1, "1".ptr, 1);
    _ = registry_set("b".ptr, 1, "2".ptr, 1);
    try std.testing.expectEqual(@as(u32, 2), registry_count());
    registry_clear();
    try std.testing.expectEqual(@as(u32, 0), registry_count());
}

test "registry: overwrite" {
    registry_clear();
    _ = registry_set("k".ptr, 1, "old".ptr, 3);
    _ = registry_set("k".ptr, 1, "new".ptr, 3);
    var buf: [256]u8 = undefined;
    const len = registry_get("k".ptr, 1, &buf, 256);
    try std.testing.expectEqualStrings("new", buf[0..@intCast(len)]);
    try std.testing.expectEqual(@as(u32, 1), registry_count());
}

test "registry: key_at" {
    registry_clear();
    _ = registry_set("alpha".ptr, 5, "1".ptr, 1);
    _ = registry_set("beta".ptr, 4, "2".ptr, 1);
    var buf: [256]u8 = undefined;
    const len = registry_key_at(0, &buf, 256);
    try std.testing.expect(len > 0);
}
