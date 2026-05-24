const std = @import("std");

// ── Simple String Cache (fixed slots) ────────────────────────

const MAX_SLOTS = 256;
const MAX_KEY = 128;
const MAX_VAL = 4096;

const Slot = struct {
    key: [MAX_KEY]u8 = [_]u8{0} ** MAX_KEY,
    key_len: usize = 0,
    val: [MAX_VAL]u8 = [_]u8{0} ** MAX_VAL,
    val_len: usize = 0,
    active: bool = false,
    hits: u64 = 0,
    ttl_ns: i128 = 0,
    created_ns: i128 = 0,
};

var slots: [MAX_SLOTS]Slot = [_]Slot{.{}} ** MAX_SLOTS;
var cache_hits: u64 = 0;
var cache_misses: u64 = 0;

fn findSlot(key_ptr: [*]const u8, key_len: usize) ?usize {
    const key = key_ptr[0..key_len];
    for (0..MAX_SLOTS) |i| {
        if (slots[i].active and slots[i].key_len == key_len and
            std.mem.eql(u8, slots[i].key[0..key_len], key))
        {
            if (slots[i].ttl_ns > 0) {
                const elapsed = std.time.nanoTimestamp() - slots[i].created_ns;
                if (elapsed > slots[i].ttl_ns) {
                    slots[i].active = false;
                    return null;
                }
            }
            return i;
        }
    }
    return null;
}

fn findFreeSlot() ?usize {
    for (0..MAX_SLOTS) |i| {
        if (!slots[i].active) return i;
    }
    return null;
}

pub fn cache_put(key_ptr: [*]const u8, key_len: usize, val_ptr: [*]const u8, val_len: usize, ttl_ms: u64) callconv(.c) i32 {
    if (key_len > MAX_KEY or val_len > MAX_VAL) return -1;
    const idx = findSlot(key_ptr, key_len) orelse findFreeSlot() orelse return -2;
    @memcpy(slots[idx].key[0..key_len], key_ptr[0..key_len]);
    slots[idx].key_len = key_len;
    @memcpy(slots[idx].val[0..val_len], val_ptr[0..val_len]);
    slots[idx].val_len = val_len;
    slots[idx].active = true;
    slots[idx].hits = 0;
    slots[idx].created_ns = std.time.nanoTimestamp();
    slots[idx].ttl_ns = if (ttl_ms > 0) @as(i128, ttl_ms) * 1_000_000 else 0;
    return 0;
}

pub fn cache_get(key_ptr: [*]const u8, key_len: usize, out: [*]u8, max: usize) callconv(.c) i32 {
    if (findSlot(key_ptr, key_len)) |idx| {
        const vlen = slots[idx].val_len;
        if (vlen > max) return -1;
        @memcpy(out[0..vlen], slots[idx].val[0..vlen]);
        slots[idx].hits += 1;
        cache_hits += 1;
        return @intCast(vlen);
    }
    cache_misses += 1;
    return -2;
}

pub fn cache_has(key_ptr: [*]const u8, key_len: usize) callconv(.c) i32 {
    return if (findSlot(key_ptr, key_len) != null) 1 else 0;
}

pub fn cache_remove(key_ptr: [*]const u8, key_len: usize) callconv(.c) i32 {
    if (findSlot(key_ptr, key_len)) |idx| {
        slots[idx].active = false;
        return 0;
    }
    return -1;
}

pub fn cache_clear() callconv(.c) void {
    for (0..MAX_SLOTS) |i| slots[i].active = false;
    cache_hits = 0;
    cache_misses = 0;
}

pub fn cache_size() callconv(.c) u32 {
    var count: u32 = 0;
    for (0..MAX_SLOTS) |i| {
        if (slots[i].active) count += 1;
    }
    return count;
}

pub fn cache_hit_count() callconv(.c) u64 { return cache_hits; }
pub fn cache_miss_count() callconv(.c) u64 { return cache_misses; }

pub fn cache_hit_rate() callconv(.c) f64 {
    const total = cache_hits + cache_misses;
    if (total == 0) return 0.0;
    return @as(f64, @floatFromInt(cache_hits)) / @as(f64, @floatFromInt(total));
}

// ── C ABI exports ────────────────────────────────────────────

pub export fn stz_cache_put(kp: [*]const u8, kl: usize, vp: [*]const u8, vl: usize, ttl: u64) callconv(.c) i32 { return cache_put(kp, kl, vp, vl, ttl); }
pub export fn stz_cache_get(kp: [*]const u8, kl: usize, o: [*]u8, m: usize) callconv(.c) i32 { return cache_get(kp, kl, o, m); }
pub export fn stz_cache_has(kp: [*]const u8, kl: usize) callconv(.c) i32 { return cache_has(kp, kl); }
pub export fn stz_cache_remove(kp: [*]const u8, kl: usize) callconv(.c) i32 { return cache_remove(kp, kl); }
pub export fn stz_cache_clear() callconv(.c) void { cache_clear(); }
pub export fn stz_cache_size() callconv(.c) u32 { return cache_size(); }
pub export fn stz_cache_hit_count() callconv(.c) u64 { return cache_hit_count(); }
pub export fn stz_cache_miss_count() callconv(.c) u64 { return cache_miss_count(); }
pub export fn stz_cache_hit_rate() callconv(.c) f64 { return cache_hit_rate(); }

// ── Tests ────────────────────────────────────────────────────

test "cache: put and get" {
    cache_clear();
    const key = "mykey";
    const val = "myvalue";
    try std.testing.expectEqual(@as(i32, 0), cache_put(key.ptr, key.len, val.ptr, val.len, 0));
    var buf: [256]u8 = undefined;
    const len = cache_get(key.ptr, key.len, &buf, 256);
    try std.testing.expectEqualStrings("myvalue", buf[0..@intCast(len)]);
}

test "cache: has/remove" {
    cache_clear();
    const key = "testkey";
    const val = "testval";
    _ = cache_put(key.ptr, key.len, val.ptr, val.len, 0);
    try std.testing.expectEqual(@as(i32, 1), cache_has(key.ptr, key.len));
    _ = cache_remove(key.ptr, key.len);
    try std.testing.expectEqual(@as(i32, 0), cache_has(key.ptr, key.len));
}

test "cache: size and clear" {
    cache_clear();
    _ = cache_put("a".ptr, 1, "1".ptr, 1, 0);
    _ = cache_put("b".ptr, 1, "2".ptr, 1, 0);
    try std.testing.expectEqual(@as(u32, 2), cache_size());
    cache_clear();
    try std.testing.expectEqual(@as(u32, 0), cache_size());
}

test "cache: hit/miss stats" {
    cache_clear();
    _ = cache_put("k".ptr, 1, "v".ptr, 1, 0);
    var buf: [16]u8 = undefined;
    _ = cache_get("k".ptr, 1, &buf, 16);
    _ = cache_get("x".ptr, 1, &buf, 16);
    try std.testing.expectEqual(@as(u64, 1), cache_hit_count());
    try std.testing.expectEqual(@as(u64, 1), cache_miss_count());
    try std.testing.expectApproxEqAbs(@as(f64, 0.5), cache_hit_rate(), 0.01);
}

test "cache: overwrite" {
    cache_clear();
    _ = cache_put("k".ptr, 1, "old".ptr, 3, 0);
    _ = cache_put("k".ptr, 1, "new".ptr, 3, 0);
    var buf: [16]u8 = undefined;
    const len = cache_get("k".ptr, 1, &buf, 16);
    try std.testing.expectEqualStrings("new", buf[0..@intCast(len)]);
}
