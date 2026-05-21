// Softanza Engine -- StzHashMap: string-keyed map
//
// Handle-based associative container mapping string keys to StzValue items.
// Case-sensitive key lookup by default; _cs variants support both modes.
//
// C ABI: stz_hashmap_* prefix.

const std = @import("std");
const allocator = std.heap.c_allocator;
const value_mod = @import("value.zig");
const StzValue = value_mod.StzValue;

const Entry = struct {
    key: []u8,
    value: *StzValue,
};

pub const StzHashMap = struct {
    entries: std.ArrayList(Entry),

    pub fn init() !*StzHashMap {
        const self = try allocator.create(StzHashMap);
        self.* = .{ .entries = .{} };
        return self;
    }

    pub fn deinit(self: *StzHashMap) void {
        for (self.entries.items) |entry| {
            allocator.free(entry.key);
            entry.value.deinit();
            allocator.destroy(entry.value);
        }
        self.entries.deinit(allocator);
        allocator.destroy(self);
    }

    pub fn len(self: *const StzHashMap) usize {
        return self.entries.items.len;
    }

    fn findIndex(self: *const StzHashMap, key: []const u8, case_sensitive: bool) ?usize {
        for (self.entries.items, 0..) |entry, i| {
            if (case_sensitive) {
                if (std.mem.eql(u8, entry.key, key)) return i;
            } else {
                if (entry.key.len == key.len and asciiEqlCI(entry.key, key)) return i;
            }
        }
        return null;
    }
};

fn asciiEqlCI(a: []const u8, b: []const u8) bool {
    if (a.len != b.len) return false;
    for (a, b) |ca, cb| {
        const la = if (ca >= 'A' and ca <= 'Z') ca + 32 else ca;
        const lb = if (cb >= 'A' and cb <= 'Z') cb + 32 else cb;
        if (la != lb) return false;
    }
    return true;
}

fn dupeKey(key_ptr: [*]const u8, key_len: usize) ?[]u8 {
    const k = allocator.alloc(u8, key_len) catch return null;
    @memcpy(k, key_ptr[0..key_len]);
    return k;
}

// ─── C ABI: Lifecycle ───

pub fn stz_hashmap_new() callconv(.c) ?*StzHashMap {
    return StzHashMap.init() catch null;
}

pub fn stz_hashmap_free(map: ?*StzHashMap) callconv(.c) void {
    const m = map orelse return;
    m.deinit();
}

pub fn stz_hashmap_len(map: ?*const StzHashMap) callconv(.c) usize {
    const m = map orelse return 0;
    return m.len();
}

// ─── C ABI: Put (upsert) ───

pub fn stz_hashmap_put(map: ?*StzHashMap, key_ptr: [*]const u8, key_len: usize, v: ?*const StzValue) callconv(.c) i32 {
    const m = map orelse return -1;
    const src = v orelse return -1;
    const key = key_ptr[0..key_len];

    if (m.findIndex(key, true)) |idx| {
        const cloned = src.clone() catch return -1;
        m.entries.items[idx].value.deinit();
        allocator.destroy(m.entries.items[idx].value);
        m.entries.items[idx].value = cloned;
        return 0;
    }

    const k = dupeKey(key_ptr, key_len) orelse return -1;
    const cloned = src.clone() catch {
        allocator.free(k);
        return -1;
    };
    m.entries.append(allocator, .{ .key = k, .value = cloned }) catch {
        allocator.free(k);
        cloned.deinit();
        allocator.destroy(cloned);
        return -1;
    };
    return 0;
}

pub fn stz_hashmap_put_int(map: ?*StzHashMap, key_ptr: [*]const u8, key_len: usize, n: i64) callconv(.c) i32 {
    const v = value_mod.stz_value_new_int(n) orelse return -1;
    const result = stz_hashmap_put(map, key_ptr, key_len, v);
    value_mod.stz_value_free(v);
    return result;
}

pub fn stz_hashmap_put_float(map: ?*StzHashMap, key_ptr: [*]const u8, key_len: usize, f: f64) callconv(.c) i32 {
    const v = value_mod.stz_value_new_float(f) orelse return -1;
    const result = stz_hashmap_put(map, key_ptr, key_len, v);
    value_mod.stz_value_free(v);
    return result;
}

pub fn stz_hashmap_put_string(map: ?*StzHashMap, key_ptr: [*]const u8, key_len: usize, val_ptr: [*]const u8, val_len: usize) callconv(.c) i32 {
    const v = value_mod.stz_value_new_string(val_ptr, val_len) orelse return -1;
    const result = stz_hashmap_put(map, key_ptr, key_len, v);
    value_mod.stz_value_free(v);
    return result;
}

// ─── C ABI: Get ───

pub fn stz_hashmap_get(map: ?*const StzHashMap, key_ptr: [*]const u8, key_len: usize) callconv(.c) ?*const StzValue {
    const m = map orelse return null;
    const idx = m.findIndex(key_ptr[0..key_len], true) orelse return null;
    return m.entries.items[idx].value;
}

pub fn stz_hashmap_get_cs(map: ?*const StzHashMap, key_ptr: [*]const u8, key_len: usize, case_sensitive: i32) callconv(.c) ?*const StzValue {
    const m = map orelse return null;
    const idx = m.findIndex(key_ptr[0..key_len], case_sensitive != 0) orelse return null;
    return m.entries.items[idx].value;
}

pub fn stz_hashmap_get_int(map: ?*const StzHashMap, key_ptr: [*]const u8, key_len: usize) callconv(.c) i64 {
    const v = stz_hashmap_get(map, key_ptr, key_len) orelse return 0;
    return value_mod.stz_value_get_int(v);
}

pub fn stz_hashmap_get_float(map: ?*const StzHashMap, key_ptr: [*]const u8, key_len: usize) callconv(.c) f64 {
    const v = stz_hashmap_get(map, key_ptr, key_len) orelse return 0;
    return value_mod.stz_value_get_float(v);
}

pub fn stz_hashmap_get_string(map: ?*const StzHashMap, key_ptr: [*]const u8, key_len: usize, buf: [*]u8, buf_len: usize) callconv(.c) usize {
    const v = stz_hashmap_get(map, key_ptr, key_len) orelse return 0;
    if (v.tag != .string_val) return 0;
    const s = v.data.string_val;
    const copy_len = @min(s.len, buf_len);
    if (copy_len > 0) @memcpy(buf[0..copy_len], s.ptr[0..copy_len]);
    return copy_len;
}

// ─── C ABI: Has / Remove ───

pub fn stz_hashmap_has_key(map: ?*const StzHashMap, key_ptr: [*]const u8, key_len: usize) callconv(.c) i32 {
    const m = map orelse return 0;
    return if (m.findIndex(key_ptr[0..key_len], true) != null) 1 else 0;
}

pub fn stz_hashmap_has_key_cs(map: ?*const StzHashMap, key_ptr: [*]const u8, key_len: usize, case_sensitive: i32) callconv(.c) i32 {
    const m = map orelse return 0;
    return if (m.findIndex(key_ptr[0..key_len], case_sensitive != 0) != null) 1 else 0;
}

pub fn stz_hashmap_remove(map: ?*StzHashMap, key_ptr: [*]const u8, key_len: usize) callconv(.c) i32 {
    const m = map orelse return -1;
    const idx = m.findIndex(key_ptr[0..key_len], true) orelse return -1;
    const entry = m.entries.orderedRemove(idx);
    allocator.free(entry.key);
    entry.value.deinit();
    allocator.destroy(entry.value);
    return 0;
}

// ─── C ABI: Keys ───

pub fn stz_hashmap_key_at(map: ?*const StzHashMap, index: usize) callconv(.c) [*]const u8 {
    const m = map orelse return "".ptr;
    if (index >= m.entries.items.len) return "".ptr;
    return m.entries.items[index].key.ptr;
}

pub fn stz_hashmap_key_len_at(map: ?*const StzHashMap, index: usize) callconv(.c) usize {
    const m = map orelse return 0;
    if (index >= m.entries.items.len) return 0;
    return m.entries.items[index].key.len;
}

pub fn stz_hashmap_value_at(map: ?*const StzHashMap, index: usize) callconv(.c) ?*const StzValue {
    const m = map orelse return null;
    if (index >= m.entries.items.len) return null;
    return m.entries.items[index].value;
}

// ─── C ABI: Clear / Clone ───

pub fn stz_hashmap_clear(map: ?*StzHashMap) callconv(.c) i32 {
    const m = map orelse return -1;
    for (m.entries.items) |entry| {
        allocator.free(entry.key);
        entry.value.deinit();
        allocator.destroy(entry.value);
    }
    m.entries.clearRetainingCapacity();
    return 0;
}

pub fn stz_hashmap_clone(map: ?*const StzHashMap) callconv(.c) ?*StzHashMap {
    const m = map orelse return null;
    const result = StzHashMap.init() catch return null;
    for (m.entries.items) |entry| {
        const k = dupeKey(entry.key.ptr, entry.key.len) orelse {
            result.deinit();
            return null;
        };
        const v = entry.value.clone() catch {
            allocator.free(k);
            result.deinit();
            return null;
        };
        result.entries.append(allocator, .{ .key = k, .value = v }) catch {
            allocator.free(k);
            v.deinit();
            allocator.destroy(v);
            result.deinit();
            return null;
        };
    }
    return result;
}

// ─── C ABI: Keys as null-delimited ───

pub fn stz_hashmap_keys(map: ?*const StzHashMap, buf: [*]u8, buf_len: usize) callconv(.c) usize {
    const m = map orelse return 0;
    var pos: usize = 0;
    for (m.entries.items, 0..) |entry, idx| {
        if (pos + entry.key.len + 1 > buf_len) break;
        @memcpy(buf[pos .. pos + entry.key.len], entry.key);
        pos += entry.key.len;
        if (idx + 1 < m.entries.items.len) {
            buf[pos] = 0;
            pos += 1;
        }
    }
    return pos;
}

// ─── C ABI: Merge ───

pub fn stz_hashmap_merge(dest: ?*StzHashMap, src: ?*const StzHashMap) callconv(.c) i32 {
    const d = dest orelse return -1;
    const s = src orelse return -1;
    for (s.entries.items) |entry| {
        if (stz_hashmap_put(d, entry.key.ptr, entry.key.len, entry.value) < 0) return -1;
    }
    return 0;
}

// ─── Tests ───

test "hashmap basic put and get" {
    const m = stz_hashmap_new() orelse return error.AllocFailed;
    defer stz_hashmap_free(m);

    _ = stz_hashmap_put_int(m, "age", 3, 42);
    _ = stz_hashmap_put_string(m, "name", 4, "Mansour", 7);
    _ = stz_hashmap_put_float(m, "score", 5, 9.5);

    try std.testing.expectEqual(@as(usize, 3), stz_hashmap_len(m));
    try std.testing.expectEqual(@as(i64, 42), stz_hashmap_get_int(m, "age", 3));
    try std.testing.expectEqual(@as(f64, 9.5), stz_hashmap_get_float(m, "score", 5));

    var buf: [32]u8 = undefined;
    const n = stz_hashmap_get_string(m, "name", 4, &buf, 32);
    try std.testing.expect(std.mem.eql(u8, buf[0..n], "Mansour"));
}

test "hashmap upsert" {
    const m = stz_hashmap_new() orelse return error.AllocFailed;
    defer stz_hashmap_free(m);

    _ = stz_hashmap_put_int(m, "x", 1, 10);
    try std.testing.expectEqual(@as(i64, 10), stz_hashmap_get_int(m, "x", 1));

    _ = stz_hashmap_put_int(m, "x", 1, 20);
    try std.testing.expectEqual(@as(i64, 20), stz_hashmap_get_int(m, "x", 1));
    try std.testing.expectEqual(@as(usize, 1), stz_hashmap_len(m));
}

test "hashmap has_key and remove" {
    const m = stz_hashmap_new() orelse return error.AllocFailed;
    defer stz_hashmap_free(m);

    _ = stz_hashmap_put_int(m, "a", 1, 1);
    _ = stz_hashmap_put_int(m, "b", 1, 2);

    try std.testing.expectEqual(@as(i32, 1), stz_hashmap_has_key(m, "a", 1));
    try std.testing.expectEqual(@as(i32, 0), stz_hashmap_has_key(m, "c", 1));

    _ = stz_hashmap_remove(m, "a", 1);
    try std.testing.expectEqual(@as(i32, 0), stz_hashmap_has_key(m, "a", 1));
    try std.testing.expectEqual(@as(usize, 1), stz_hashmap_len(m));
}

test "hashmap case insensitive" {
    const m = stz_hashmap_new() orelse return error.AllocFailed;
    defer stz_hashmap_free(m);

    _ = stz_hashmap_put_int(m, "Name", 4, 42);

    try std.testing.expect(stz_hashmap_get(m, "name", 4) == null);
    try std.testing.expect(stz_hashmap_get_cs(m, "name", 4, 0) != null);
    try std.testing.expectEqual(@as(i32, 1), stz_hashmap_has_key_cs(m, "NAME", 4, 0));
    try std.testing.expectEqual(@as(i32, 0), stz_hashmap_has_key(m, "NAME", 4));
}

test "hashmap key iteration" {
    const m = stz_hashmap_new() orelse return error.AllocFailed;
    defer stz_hashmap_free(m);

    _ = stz_hashmap_put_int(m, "x", 1, 1);
    _ = stz_hashmap_put_int(m, "y", 1, 2);

    const k0 = stz_hashmap_key_at(m, 0);
    const k0_len = stz_hashmap_key_len_at(m, 0);
    try std.testing.expect(std.mem.eql(u8, k0[0..k0_len], "x"));

    const k1 = stz_hashmap_key_at(m, 1);
    const k1_len = stz_hashmap_key_len_at(m, 1);
    try std.testing.expect(std.mem.eql(u8, k1[0..k1_len], "y"));

    try std.testing.expect(stz_hashmap_value_at(m, 0) != null);
    try std.testing.expect(stz_hashmap_value_at(m, 2) == null);
}

test "hashmap clone" {
    const m = stz_hashmap_new() orelse return error.AllocFailed;
    defer stz_hashmap_free(m);

    _ = stz_hashmap_put_int(m, "a", 1, 10);
    _ = stz_hashmap_put_string(m, "b", 1, "hello", 5);

    const c = stz_hashmap_clone(m) orelse return error.AllocFailed;
    defer stz_hashmap_free(c);

    try std.testing.expectEqual(@as(usize, 2), stz_hashmap_len(c));
    try std.testing.expectEqual(@as(i64, 10), stz_hashmap_get_int(c, "a", 1));

    _ = stz_hashmap_clear(m);
    try std.testing.expectEqual(@as(usize, 0), stz_hashmap_len(m));
    try std.testing.expectEqual(@as(usize, 2), stz_hashmap_len(c));
}

test "hashmap keys null-delimited" {
    const m = stz_hashmap_new() orelse return error.AllocFailed;
    defer stz_hashmap_free(m);

    _ = stz_hashmap_put_int(m, "alpha", 5, 1);
    _ = stz_hashmap_put_int(m, "beta", 4, 2);

    var buf: [64]u8 = undefined;
    const n = stz_hashmap_keys(m, &buf, 64);
    try std.testing.expect(std.mem.eql(u8, buf[0..n], "alpha\x00beta"));
}

test "hashmap merge" {
    const a = stz_hashmap_new() orelse return error.AllocFailed;
    defer stz_hashmap_free(a);
    const b = stz_hashmap_new() orelse return error.AllocFailed;
    defer stz_hashmap_free(b);

    _ = stz_hashmap_put_int(a, "x", 1, 1);
    _ = stz_hashmap_put_int(b, "y", 1, 2);
    _ = stz_hashmap_put_int(b, "x", 1, 99);

    _ = stz_hashmap_merge(a, b);
    try std.testing.expectEqual(@as(usize, 2), stz_hashmap_len(a));
    try std.testing.expectEqual(@as(i64, 99), stz_hashmap_get_int(a, "x", 1));
    try std.testing.expectEqual(@as(i64, 2), stz_hashmap_get_int(a, "y", 1));
}

test "hashmap value types" {
    const m = stz_hashmap_new() orelse return error.AllocFailed;
    defer stz_hashmap_free(m);

    const v = value_mod.stz_value_new_null() orelse return error.AllocFailed;
    defer value_mod.stz_value_free(v);
    _ = stz_hashmap_put(m, "nil", 3, v);

    const got = stz_hashmap_get(m, "nil", 3) orelse return error.AllocFailed;
    try std.testing.expectEqual(@as(i32, 1), value_mod.stz_value_is_null(got));
}

test "hashmap null handles" {
    stz_hashmap_free(null);
    try std.testing.expectEqual(@as(usize, 0), stz_hashmap_len(null));
    try std.testing.expectEqual(@as(i32, -1), stz_hashmap_remove(null, "x", 1));
    try std.testing.expect(stz_hashmap_clone(null) == null);
    try std.testing.expect(stz_hashmap_get(null, "x", 1) == null);
}
