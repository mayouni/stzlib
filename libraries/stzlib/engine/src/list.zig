// Softanza Engine -- StzList: typed dynamic list
//
// Handle-based list operating on StzValue items. Provides the operations
// that Ring's stzList subclasses currently implement in O(n^2):
// find, find_all, contains, sort, reverse, deduplicate, flatten.
// Case-sensitive operations use Unicode casefold via utf8proc.
//
// C ABI: stz_list_* prefix.

const std = @import("std");
const allocator = std.heap.c_allocator;
const value_mod = @import("value.zig");
const StzValue = value_mod.StzValue;
const ValueType = value_mod.ValueType;

pub const StzList = struct {
    // Tri storage (unboxed typed-storage refactor). Normally `items` holds
    // boxed *StzValue. Exactly one of these dense modes may be active instead
    // (then `items` is empty -- no per-item heap boxing):
    //   * INT-MODE   : `ints` non-null  -- dense i64.
    //   * FLOAT-MODE : `floats` non-null -- dense f64 (all-numeric incl. ints
    //                  promoted to f64 once any float appears).
    //   * STR-MODE   : `strs` non-null  -- dense owned []u8 (all-string), no
    //                  per-item *StzValue wrapper.
    // ensureBoxed() materializes any dense mode into `items` on demand; the
    // bridge handle-resolvers call it for any op not specialized for dense
    // storage, so the hundreds of `items`-based ops keep working unchanged.
    // Specialized hot ops + marshal + unmarshal read the dense array directly.
    items: std.ArrayList(*StzValue) = .{},
    ints: ?std.ArrayList(i64) = null,
    floats: ?std.ArrayList(f64) = null,
    strs: ?std.ArrayList([]u8) = null,

    pub fn init() !*StzList {
        const self = try allocator.create(StzList);
        self.* = .{};
        return self;
    }

    // Build an empty dense int-mode list (optionally pre-sized).
    pub fn initInts(capacity: usize) !*StzList {
        const self = try allocator.create(StzList);
        self.* = .{ .ints = std.ArrayList(i64){} };
        if (capacity > 0) try self.ints.?.ensureTotalCapacity(allocator, capacity);
        return self;
    }

    // Build an empty dense float-mode list (optionally pre-sized).
    pub fn initFloats(capacity: usize) !*StzList {
        const self = try allocator.create(StzList);
        self.* = .{ .floats = std.ArrayList(f64){} };
        if (capacity > 0) try self.floats.?.ensureTotalCapacity(allocator, capacity);
        return self;
    }

    // Build an empty dense str-mode list (optionally pre-sized).
    pub fn initStrs(capacity: usize) !*StzList {
        const self = try allocator.create(StzList);
        self.* = .{ .strs = std.ArrayList([]u8){} };
        if (capacity > 0) try self.strs.?.ensureTotalCapacity(allocator, capacity);
        return self;
    }

    pub fn isInts(self: *const StzList) bool {
        return self.ints != null;
    }
    pub fn isFloats(self: *const StzList) bool {
        return self.floats != null;
    }
    pub fn isStrs(self: *const StzList) bool {
        return self.strs != null;
    }

    // Promote dense int-mode to dense float-mode (i64 -> f64). Called when a
    // float appears in an otherwise all-int list during marshal. No-op if
    // already float-mode or boxed.
    pub fn ensureFloats(self: *StzList) void {
        if (self.ints) |*arr| {
            var f = std.ArrayList(f64){};
            f.ensureTotalCapacity(allocator, arr.items.len) catch {};
            for (arr.items) |x| f.append(allocator, @floatFromInt(x)) catch {};
            arr.deinit(allocator);
            self.ints = null;
            self.floats = f;
        }
    }

    // Materialize either dense mode into boxed *StzValue items (one-time,
    // idempotent). After this the list is in normal boxed mode.
    pub fn ensureBoxed(self: *StzList) void {
        if (self.ints) |*arr| {
            self.items.ensureTotalCapacity(allocator, arr.items.len) catch {};
            for (arr.items) |iv| {
                const v = value_mod.stz_value_new_int(iv) orelse continue;
                self.items.append(allocator, v) catch {
                    v.deinit();
                    allocator.destroy(v);
                };
            }
            arr.deinit(allocator);
            self.ints = null;
        } else if (self.floats) |*arr| {
            self.items.ensureTotalCapacity(allocator, arr.items.len) catch {};
            for (arr.items) |fv| {
                const v = value_mod.stz_value_new_float(fv) orelse continue;
                self.items.append(allocator, v) catch {
                    v.deinit();
                    allocator.destroy(v);
                };
            }
            arr.deinit(allocator);
            self.floats = null;
        } else if (self.strs) |*arr| {
            self.items.ensureTotalCapacity(allocator, arr.items.len) catch {};
            for (arr.items) |s| {
                const v = value_mod.stz_value_new_string(s.ptr, s.len);
                if (v) |vv| {
                    self.items.append(allocator, vv) catch {
                        vv.deinit();
                        allocator.destroy(vv);
                    };
                }
                allocator.free(s);
            }
            arr.deinit(allocator);
            self.strs = null;
        }
    }

    pub fn deinit(self: *StzList) void {
        if (self.ints) |*arr| {
            arr.deinit(allocator);
        } else if (self.floats) |*arr| {
            arr.deinit(allocator);
        } else if (self.strs) |*arr| {
            for (arr.items) |s| allocator.free(s);
            arr.deinit(allocator);
        } else {
            for (self.items.items) |item| {
                item.deinit();
                allocator.destroy(item);
            }
        }
        self.items.deinit(allocator);
        allocator.destroy(self);
    }

    pub fn len(self: *const StzList) usize {
        if (self.ints) |arr| return arr.items.len;
        if (self.floats) |arr| return arr.items.len;
        if (self.strs) |arr| return arr.items.len;
        return self.items.items.len;
    }

    pub fn appendClone(self: *StzList, v: *const StzValue) !void {
        if (self.ints != null or self.floats != null or self.strs != null) self.ensureBoxed();
        const cloned = try v.clone();
        try self.items.append(allocator, cloned);
    }

    // get/getMut require boxed mode. In a dense mode they return null --
    // callers that may see dense mode must ensureBoxed first (resolvers do).
    pub fn get(self: *const StzList, index: usize) ?*const StzValue {
        if (self.ints != null or self.floats != null or self.strs != null) return null;
        if (index >= self.items.items.len) return null;
        return self.items.items[index];
    }

    pub fn getMut(self: *StzList, index: usize) ?*StzValue {
        if (self.ints != null or self.floats != null or self.strs != null) return null;
        if (index >= self.items.items.len) return null;
        return self.items.items[index];
    }
};

// ─── Helpers ───

fn strEqlCI(a_ptr: [*]const u8, a_len: usize, b_ptr: [*]const u8, b_len: usize) bool {
    if (a_len != b_len) return false;
    if (a_len == 0) return true;
    const a = a_ptr[0..a_len];
    const b = b_ptr[0..b_len];
    for (a, b) |ca, cb| {
        const la = if (ca >= 'A' and ca <= 'Z') ca + 32 else ca;
        const lb = if (cb >= 'A' and cb <= 'Z') cb + 32 else cb;
        if (la != lb) return false;
    }
    return true;
}

fn strCompareCI(a_ptr: [*]const u8, a_len: usize, b_ptr: [*]const u8, b_len: usize) i32 {
    const min_len = @min(a_len, b_len);
    if (min_len > 0) {
        const a = a_ptr[0..min_len];
        const b = b_ptr[0..min_len];
        for (a, b) |ca, cb| {
            const la = if (ca >= 'A' and ca <= 'Z') ca + 32 else ca;
            const lb = if (cb >= 'A' and cb <= 'Z') cb + 32 else cb;
            if (la < lb) return -1;
            if (la > lb) return 1;
        }
    }
    if (a_len < b_len) return -1;
    if (a_len > b_len) return 1;
    return 0;
}

fn valueCompareCS(a: *const StzValue, b: *const StzValue, case_sensitive: bool) i32 {
    if (case_sensitive) return a.compare(b);
    if (a.tag != b.tag) {
        return @as(i32, @intCast(@intFromEnum(a.tag))) - @as(i32, @intCast(@intFromEnum(b.tag)));
    }
    if (a.tag == .string_val) {
        const sa = a.data.string_val;
        const sb = b.data.string_val;
        return strCompareCI(sa.ptr, sa.len, sb.ptr, sb.len);
    }
    return a.compare(b);
}

fn valueEqlCS(a: *const StzValue, b: *const StzValue, case_sensitive: bool) bool {
    if (case_sensitive) return a.eql(b);
    if (a.tag != b.tag) return false;
    if (a.tag == .string_val) {
        const sa = a.data.string_val;
        const sb = b.data.string_val;
        return strEqlCI(sa.ptr, sa.len, sb.ptr, sb.len);
    }
    return a.eql(b);
}

// ─── Value hash-set (for O(n) set ops / classify) ───
//
// A HashMap keyed by *StzValue, hashing/comparing BY VALUE (structurally,
// case-sensitivity-aware) -- not by pointer. Lets union/intersection/
// difference/classify run in O(n+m) instead of O(n*m). Correct (no silent
// hash-collision merges): equality is the engine's valueEqlCS.

fn hashValueInto(h: *std.hash.Wyhash, v: *const StzValue, cs: bool) void {
    h.update(&[_]u8{@intFromEnum(v.tag)});
    switch (v.tag) {
        .null_val => {},
        .bool_val => h.update(&[_]u8{if (v.data.bool_val) 1 else 0}),
        .int_val => h.update(std.mem.asBytes(&v.data.int_val)),
        .float_val => h.update(std.mem.asBytes(&v.data.float_val)),
        .string_val => {
            const s = v.data.string_val;
            if (cs) {
                h.update(s.ptr[0..s.len]);
            } else {
                for (s.ptr[0..s.len]) |c| {
                    const lc: u8 = if (c >= 'A' and c <= 'Z') c + 32 else c;
                    h.update(&[_]u8{lc});
                }
            }
        },
        .list_val => {
            const ld = v.data.list_val;
            var i: usize = 0;
            while (i < ld.len) : (i += 1) hashValueInto(h, ld.items[i], cs);
        },
    }
}

// splitmix64 finalizer -- a few multiplies, excellent distribution. Used to
// hash scalar values directly without spinning up Wyhash (init+byte-update+
// final) per item, which dominated set-op/classify/dedup hashing at scale.
inline fn mix64(x: u64) u64 {
    var z = x +% 0x9E3779B97F4A7C15;
    z = (z ^ (z >> 30)) *% 0xBF58476D1CE4E5B9;
    z = (z ^ (z >> 27)) *% 0x94D049BB133111EB;
    return z ^ (z >> 31);
}

const ValueSetCtx = struct {
    cs: bool,
    pub fn hash(self: @This(), v: *const StzValue) u64 {
        // Fast path for scalars (tag folded in as salt -- eql requires equal
        // tags, so types never need to collide). Strings/lists keep the
        // structural Wyhash (case-fold-aware for strings).
        const tagsalt = @as(u64, @intFromEnum(v.tag)) << 56;
        switch (v.tag) {
            .int_val => return mix64(@as(u64, @bitCast(v.data.int_val)) ^ tagsalt),
            .float_val => return mix64(@as(u64, @bitCast(v.data.float_val)) ^ tagsalt),
            .bool_val => return mix64((if (v.data.bool_val) @as(u64, 1) else @as(u64, 0)) ^ tagsalt),
            .null_val => return mix64(tagsalt),
            .string_val, .list_val => {
                var h = std.hash.Wyhash.init(0);
                hashValueInto(&h, v, self.cs);
                return h.final();
            },
        }
    }
    pub fn eql(self: @This(), a: *const StzValue, b: *const StzValue) bool {
        return valueEqlCS(a, b, self.cs);
    }
};

const ValueSet = std.HashMap(*const StzValue, void, ValueSetCtx, std.hash_map.default_max_load_percentage);

fn newValueSet(cs: bool) ValueSet {
    return ValueSet.initContext(allocator, ValueSetCtx{ .cs = cs });
}

// ─── C ABI: Lifecycle ───

pub fn stz_list_new() callconv(.c) ?*StzList {
    return StzList.init() catch null;
}

pub fn stz_list_free(list: ?*StzList) callconv(.c) void {
    const l = list orelse return;
    l.deinit();
}

pub fn stz_list_len(list: ?*const StzList) callconv(.c) usize {
    const l = list orelse return 0;
    return l.len();
}

// ─── C ABI: Add Items ───

// Empty dense int-mode list (used by marshal to build all-int lists without
// per-item boxing). Appending a non-int via append_float/string/value will
// transparently ensureBoxed().
pub fn stz_list_new_ints() callconv(.c) ?*StzList {
    return StzList.initInts(0) catch null;
}

pub fn stz_list_append_int(list: ?*StzList, n: i64) callconv(.c) i32 {
    const l = list orelse return -1;
    // Dense int-mode: append the raw i64, no boxing.
    if (l.ints) |*arr| {
        arr.append(allocator, n) catch return -1;
        return 0;
    }
    // Dense float-mode: store the int as f64 (keeps the list dense-numeric).
    if (l.floats) |*arr| {
        arr.append(allocator, @floatFromInt(n)) catch return -1;
        return 0;
    }
    if (l.strs != null) l.ensureBoxed(); // int after strings -> mixed -> box
    const v = value_mod.stz_value_new_int(n) orelse return -1;
    l.items.append(allocator, v) catch {
        v.deinit();
        allocator.destroy(v);
        return -1;
    };
    return 0;
}

pub fn stz_list_append_float(list: ?*StzList, f: f64) callconv(.c) i32 {
    const l = list orelse return -1;
    // A float in an all-int list promotes it to dense float-mode (i64 -> f64),
    // keeping the list dense-numeric instead of boxing.
    if (l.ints != null) l.ensureFloats();
    if (l.floats) |*arr| {
        arr.append(allocator, f) catch return -1;
        return 0;
    }
    if (l.strs != null) l.ensureBoxed(); // float after strings -> mixed -> box
    const v = value_mod.stz_value_new_float(f) orelse return -1;
    l.items.append(allocator, v) catch {
        v.deinit();
        allocator.destroy(v);
        return -1;
    };
    return 0;
}

pub fn stz_list_append_string(list: ?*StzList, ptr: [*]const u8, str_len: usize) callconv(.c) i32 {
    const l = list orelse return -1;
    // Dense str-mode: append an owned byte copy, no *StzValue wrapper.
    if (l.strs) |*arr| {
        const copy = allocator.dupe(u8, ptr[0..str_len]) catch return -1;
        arr.append(allocator, copy) catch {
            allocator.free(copy);
            return -1;
        };
        return 0;
    }
    // Fresh marshal whose FIRST item is a string (empty int-mode, no floats):
    // switch to dense str-mode for an all-string list.
    if (l.ints) |*iarr| {
        if (iarr.items.len == 0 and l.floats == null) {
            iarr.deinit(allocator);
            l.ints = null;
            l.strs = std.ArrayList([]u8){};
            const copy = allocator.dupe(u8, ptr[0..str_len]) catch return -1;
            l.strs.?.append(allocator, copy) catch {
                allocator.free(copy);
                return -1;
            };
            return 0;
        }
    }
    // Mixed (had ints/floats) or already boxed -> box.
    l.ensureBoxed();
    const v = value_mod.stz_value_new_string(ptr, str_len) orelse return -1;
    l.items.append(allocator, v) catch {
        v.deinit();
        allocator.destroy(v);
        return -1;
    };
    return 0;
}

pub fn stz_list_append_value(list: ?*StzList, v: ?*const StzValue) callconv(.c) i32 {
    const l = list orelse return -1;
    const src = v orelse return -1;
    l.appendClone(src) catch return -1;
    return 0;
}

// ─── C ABI: Insert ───

pub fn stz_list_insert(list: ?*StzList, index: usize, v: ?*const StzValue) callconv(.c) i32 {
    const l = list orelse return -1;
    const src = v orelse return -1;
    if (index > l.len()) return -1;
    const cloned = src.clone() catch return -1;
    l.items.insert(allocator, index, cloned) catch {
        cloned.deinit();
        allocator.destroy(cloned);
        return -1;
    };
    return 0;
}

// ─── C ABI: Remove ───

pub fn stz_list_remove_at(list: ?*StzList, index: usize) callconv(.c) i32 {
    const l = list orelse return -1;
    if (index >= l.len()) return -1;
    const removed = l.items.orderedRemove(index);
    removed.deinit();
    allocator.destroy(removed);
    return 0;
}

pub fn stz_list_remove_cs(list: ?*StzList, v: ?*const StzValue, case_sensitive: i32) callconv(.c) i32 {
    const l = list orelse return -1;
    const needle = v orelse return -1;
    const cs = case_sensitive != 0;
    var i: usize = 0;
    var removed: i32 = 0;
    while (i < l.items.items.len) {
        if (valueEqlCS(l.items.items[i], needle, cs)) {
            const item = l.items.orderedRemove(i);
            item.deinit();
            allocator.destroy(item);
            removed += 1;
        } else {
            i += 1;
        }
    }
    return removed;
}

pub fn stz_list_replace_cs(list: ?*StzList, old_v: ?*const StzValue, new_v: ?*const StzValue, case_sensitive: i32) callconv(.c) i32 {
    const l = list orelse return -1;
    const needle = old_v orelse return -1;
    const replacement = new_v orelse return -1;
    const cs = case_sensitive != 0;
    var replaced: i32 = 0;
    for (l.items.items) |item| {
        if (valueEqlCS(item, needle, cs)) {
            const cloned = replacement.clone() catch return -1;
            item.deinit();
            item.* = cloned.*;
            allocator.destroy(cloned);
            replaced += 1;
        }
    }
    return replaced;
}

/// String-direct Replace variant. Takes raw string pointers + lengths
/// instead of value handles. This avoids the cross-DLL handle-table
/// issue where a value handle minted in stz_value.dll cant be looked
/// up in stz_list.dll's table.
pub fn stz_list_replace_all_string_cs(list: ?*StzList, old_ptr: [*]const u8, old_len: usize, new_ptr: [*]const u8, new_len: usize, case_sensitive: i32) callconv(.c) i32 {
    const l = list orelse return -1;
    const needle = value_mod.stz_value_new_string(old_ptr, old_len) orelse return -1;
    defer {
        needle.deinit();
        allocator.destroy(needle);
    }
    const replacement = value_mod.stz_value_new_string(new_ptr, new_len) orelse return -1;
    defer {
        replacement.deinit();
        allocator.destroy(replacement);
    }
    const cs = case_sensitive != 0;
    var replaced: i32 = 0;
    for (l.items.items) |item| {
        if (valueEqlCS(item, needle, cs)) {
            const cloned = replacement.clone() catch return -1;
            item.deinit();
            item.* = cloned.*;
            allocator.destroy(cloned);
            replaced += 1;
        }
    }
    return replaced;
}

/// String-direct Remove variant. Same cross-DLL handle workaround as
/// stz_list_replace_all_string_cs.
pub fn stz_list_remove_all_string_cs(list: ?*StzList, str_ptr: [*]const u8, str_len: usize, case_sensitive: i32) callconv(.c) i32 {
    const l = list orelse return -1;
    const needle = value_mod.stz_value_new_string(str_ptr, str_len) orelse return -1;
    defer {
        needle.deinit();
        allocator.destroy(needle);
    }
    const cs = case_sensitive != 0;
    var i: usize = 0;
    var removed: i32 = 0;
    while (i < l.items.items.len) {
        if (valueEqlCS(l.items.items[i], needle, cs)) {
            const item = l.items.orderedRemove(i);
            item.deinit();
            allocator.destroy(item);
            removed += 1;
        } else {
            i += 1;
        }
    }
    return removed;
}

/// String-direct Set variant for setting a single position to a string.
/// Same cross-DLL workaround.
pub fn stz_list_set_string(list: ?*StzList, index: usize, str_ptr: [*]const u8, str_len: usize) callconv(.c) i32 {
    const l = list orelse return -1;
    if (index >= l.items.items.len) return -1;
    const new_val = value_mod.stz_value_new_string(str_ptr, str_len) orelse return -1;
    defer allocator.destroy(new_val);
    const old = l.items.items[index];
    old.deinit();
    old.* = new_val.*;
    return 0;
}

/// Replace multiple items at once: for each item in the list, if it matches
/// old_values[i], replace with new_values[i]. First match wins (no cascading).
/// Returns the number of items replaced, or -1 on error.
pub fn stz_list_replace_many_cs(list: ?*StzList, old_values: ?*const StzList, new_values: ?*const StzList, case_sensitive: i32) callconv(.c) i32 {
    const l = list orelse return -1;
    const olds = old_values orelse return -1;
    const news = new_values orelse return -1;
    const n_pairs = olds.len();
    if (n_pairs != news.len()) return -1;
    if (n_pairs == 0) return 0;
    const cs = case_sensitive != 0;
    var replaced: i32 = 0;
    for (l.items.items) |item| {
        for (0..n_pairs) |k| {
            const old_v = olds.get(k) orelse continue;
            if (valueEqlCS(item, old_v, cs)) {
                const new_v = news.get(k) orelse continue;
                const cloned = new_v.clone() catch return -1;
                item.deinit();
                item.* = cloned.*;
                allocator.destroy(cloned);
                replaced += 1;
                break; // first match wins, move to next item
            }
        }
    }
    return replaced;
}

/// Count items matching a predicate string value (empty strings).
pub fn stz_list_count_empty_strings(list: ?*const StzList) callconv(.c) i32 {
    const l = list orelse return 0;
    var count: i32 = 0;
    for (l.items.items) |item| {
        if (item.tag == .string_val) {
            if (item.data.string_val.len == 0) {
                count += 1;
            }
        }
    }
    return count;
}

/// Find positions of empty strings in the list (0-based). Returns a new list
/// of integer values, or null on error. Caller must free the result.
pub fn stz_list_find_empty_strings(list: ?*const StzList) callconv(.c) ?*StzList {
    const l = list orelse return null;
    const result = StzList.init() catch return null;
    for (l.items.items, 0..) |item, idx| {
        if (item.tag == .string_val and item.data.string_val.len == 0) {
            const v = value_mod.stz_value_new_int(@intCast(idx)) orelse {
                result.deinit();
                allocator.destroy(result);
                return null;
            };
            result.appendClone(v) catch {
                v.deinit();
                allocator.destroy(v);
                result.deinit();
                allocator.destroy(result);
                return null;
            };
            v.deinit();
            allocator.destroy(v);
        }
    }
    return result;
}

// ─── C ABI: Get ───

pub fn stz_list_get(list: ?*const StzList, index: usize) callconv(.c) ?*const StzValue {
    const l = list orelse return null;
    return l.get(index);
}

pub fn stz_list_get_int(list: ?*const StzList, index: usize) callconv(.c) i64 {
    const l = list orelse return 0;
    const v = l.get(index) orelse return 0;
    return value_mod.stz_value_get_int(v);
}

pub fn stz_list_get_float(list: ?*const StzList, index: usize) callconv(.c) f64 {
    const l = list orelse return 0.0;
    const v = l.get(index) orelse return 0.0;
    return value_mod.stz_value_get_float(v);
}

pub fn stz_list_get_string(list: ?*const StzList, index: usize, buf: [*]u8, buf_len: usize) callconv(.c) usize {
    const l = list orelse return 0;
    const v = l.get(index) orelse return 0;
    if (v.tag != .string_val) return 0;
    const s = v.data.string_val;
    const copy_len = @min(s.len, buf_len);
    if (copy_len > 0) @memcpy(buf[0..copy_len], s.ptr[0..copy_len]);
    return copy_len;
}

// ─── C ABI: Find First ───

pub fn stz_list_find_first_cs(list: ?*const StzList, v: ?*const StzValue, case_sensitive: i32) callconv(.c) i64 {
    const l = list orelse return -1;
    const needle = v orelse return -1;
    const cs = case_sensitive != 0;
    for (l.items.items, 0..) |item, i| {
        if (valueEqlCS(item, needle, cs)) return @intCast(i);
    }
    return -1;
}

pub fn stz_list_find_first_string_cs(list: ?*const StzList, ptr: [*]const u8, str_len: usize, case_sensitive: i32) callconv(.c) i64 {
    const l = list orelse return -1;
    const cs = case_sensitive != 0;
    for (l.items.items, 0..) |item, i| {
        if (item.tag != .string_val) continue;
        const s = item.data.string_val;
        if (cs) {
            if (s.len == str_len and s.len > 0 and std.mem.eql(u8, s.ptr[0..s.len], ptr[0..str_len])) return @intCast(i);
            if (s.len == 0 and str_len == 0) return @intCast(i);
        } else {
            if (strEqlCI(s.ptr, s.len, ptr, str_len)) return @intCast(i);
        }
    }
    return -1;
}

pub fn stz_list_contains_cs(list: ?*const StzList, v: ?*const StzValue, case_sensitive: i32) callconv(.c) i32 {
    return if (stz_list_find_first_cs(list, v, case_sensitive) >= 0) 1 else 0;
}

// ─── C ABI: Find ───

pub fn stz_list_find_cs(list: ?*const StzList, v: ?*const StzValue, case_sensitive: i32, out_buf: [*]i64, out_cap: usize) callconv(.c) usize {
    const l = list orelse return 0;
    const needle = v orelse return 0;
    const cs = case_sensitive != 0;
    var count: usize = 0;
    for (l.items.items, 0..) |item, i| {
        if (valueEqlCS(item, needle, cs)) {
            if (count < out_cap) out_buf[count] = @intCast(i);
            count += 1;
        }
    }
    return count;
}

/// Find the nth occurrence of a value (0-based nth). Returns 0-based index or -1.
pub fn stz_list_find_nth_cs(list_ptr: ?*const StzList, v: ?*const StzValue, nth: usize, case_sensitive: i32) callconv(.c) i64 {
    const l = list_ptr orelse return -1;
    const needle = v orelse return -1;
    const cs = case_sensitive != 0;
    var occurrence: usize = 0;
    for (l.items.items, 0..) |item, i| {
        if (valueEqlCS(item, needle, cs)) {
            if (occurrence == nth) return @intCast(i);
            occurrence += 1;
        }
    }
    return -1;
}

/// Find the last occurrence of a value. Returns 0-based index or -1.
pub fn stz_list_find_last_cs(list_ptr: ?*const StzList, v: ?*const StzValue, case_sensitive: i32) callconv(.c) i64 {
    const l = list_ptr orelse return -1;
    const needle = v orelse return -1;
    const cs = case_sensitive != 0;
    const n = l.len();
    if (n == 0) return -1;
    var i = n;
    while (i > 0) {
        i -= 1;
        const item = l.get(i) orelse continue;
        if (valueEqlCS(item, needle, cs)) return @intCast(i);
    }
    return -1;
}

pub fn stz_list_count_cs(list: ?*const StzList, v: ?*const StzValue, case_sensitive: i32) callconv(.c) usize {
    const l = list orelse return 0;
    const needle = v orelse return 0;
    const cs = case_sensitive != 0;
    var count: usize = 0;
    for (l.items.items) |item| {
        if (valueEqlCS(item, needle, cs)) count += 1;
    }
    return count;
}

// ─── C ABI: Sort ───

pub fn stz_list_sort_cs(list: ?*StzList, case_sensitive: i32) callconv(.c) i32 {
    const l = list orelse return -1;
    // Dense int-mode: native i64 sort (no per-compare pointer-deref/tag-switch).
    if (l.ints) |*arr| {
        std.mem.sort(i64, arr.items, {}, struct {
            fn lt(_: void, a: i64, b: i64) bool {
                return a < b;
            }
        }.lt);
        return 0;
    }
    if (l.floats) |*arr| {
        std.mem.sort(f64, arr.items, {}, struct {
            fn lt(_: void, a: f64, b: f64) bool {
                return a < b;
            }
        }.lt);
        return 0;
    }
    if (l.strs != null) l.ensureBoxed(); // string sort via boxed path (S1)
    if (l.len() <= 1) return 0;
    const cs = case_sensitive != 0;
    std.mem.sort(*StzValue, l.items.items, cs, struct {
        fn lessThan(cs_ctx: bool, a: *StzValue, b: *StzValue) bool {
            return valueCompareCS(a, b, cs_ctx) < 0;
        }
    }.lessThan);
    return 0;
}

pub fn stz_list_sort(list: ?*StzList) callconv(.c) i32 {
    return stz_list_sort_cs(list, 1);
}

pub fn stz_list_sort_descending_cs(list: ?*StzList, case_sensitive: i32) callconv(.c) i32 {
    const l = list orelse return -1;
    if (l.ints) |*arr| {
        std.mem.sort(i64, arr.items, {}, struct {
            fn gt(_: void, a: i64, b: i64) bool {
                return a > b;
            }
        }.gt);
        return 0;
    }
    if (l.floats) |*arr| {
        std.mem.sort(f64, arr.items, {}, struct {
            fn gt(_: void, a: f64, b: f64) bool {
                return a > b;
            }
        }.gt);
        return 0;
    }
    if (l.strs != null) l.ensureBoxed(); // string sort via boxed path (S1)
    if (l.len() <= 1) return 0;
    const cs = case_sensitive != 0;
    std.mem.sort(*StzValue, l.items.items, cs, struct {
        fn greaterThan(cs_ctx: bool, a: *StzValue, b: *StzValue) bool {
            return valueCompareCS(a, b, cs_ctx) > 0;
        }
    }.greaterThan);
    return 0;
}

pub fn stz_list_sort_descending(list: ?*StzList) callconv(.c) i32 {
    return stz_list_sort_descending_cs(list, 1);
}

// ─── C ABI: Reverse ───

pub fn stz_list_reverse(list: ?*StzList) callconv(.c) i32 {
    const l = list orelse return -1;
    if (l.ints) |*arr| {
        std.mem.reverse(i64, arr.items);
        return 0;
    }
    if (l.floats) |*arr| {
        std.mem.reverse(f64, arr.items);
        return 0;
    }
    if (l.strs) |*arr| {
        std.mem.reverse([]u8, arr.items);
        return 0;
    }
    const items = l.items.items;
    if (items.len <= 1) return 0;
    var lo: usize = 0;
    var hi: usize = items.len - 1;
    while (lo < hi) {
        const tmp = items[lo];
        items[lo] = items[hi];
        items[hi] = tmp;
        lo += 1;
        hi -= 1;
    }
    return 0;
}

// ─── C ABI: Deduplicate ───

pub fn stz_list_unique_cs(list: ?*const StzList, case_sensitive: i32) callconv(.c) ?*StzList {
    const l = list orelse return null;
    const cs = case_sensitive != 0;
    // Dense int-mode: native O(n) dedup -> dense result.
    if (l.ints != null) return uniqueIntsFast(l.ints.?.items);
    // Dense str-mode, case-sensitive: native string hash-set dedup.
    if (l.strs != null and cs) return uniqueStrsFast(l.strs.?.items);
    @constCast(l).ensureBoxed();
    const result = StzList.init() catch return null;

    // O(n) via the value hash-set (was O(n^2): a nested scan of the result --
    // fine only when the distinct count is tiny, catastrophic otherwise).
    var seen = newValueSet(cs);
    defer seen.deinit();
    for (l.items.items) |item| {
        const gop = seen.getOrPut(item) catch {
            result.deinit();
            return null;
        };
        if (!gop.found_existing) {
            result.appendClone(item) catch {
                result.deinit();
                return null;
            };
        }
    }
    return result;
}

pub fn stz_list_remove_duplicates_cs(list: ?*StzList, case_sensitive: i32) callconv(.c) i32 {
    const l = list orelse return -1;
    const cs = case_sensitive != 0;
    if (l.len() <= 1) return 0;

    var i: usize = 1;
    while (i < l.items.items.len) {
        var is_dup = false;
        for (l.items.items[0..i]) |prev| {
            if (valueEqlCS(prev, l.items.items[i], cs)) {
                is_dup = true;
                break;
            }
        }
        if (is_dup) {
            const removed = l.items.orderedRemove(i);
            removed.deinit();
            allocator.destroy(removed);
        } else {
            i += 1;
        }
    }
    return 0;
}

// ─── C ABI: Clone / Slice ───

pub fn stz_list_clone(list: ?*const StzList) callconv(.c) ?*StzList {
    const l = list orelse return null;
    const result = StzList.init() catch return null;
    for (l.items.items) |item| {
        result.appendClone(item) catch {
            result.deinit();
            return null;
        };
    }
    return result;
}

pub fn stz_list_slice(list: ?*const StzList, start: usize, end: usize) callconv(.c) ?*StzList {
    const l = list orelse return null;
    const actual_end = @min(end, l.len());
    if (start >= actual_end) {
        return StzList.init() catch null;
    }
    const result = StzList.init() catch return null;
    for (l.items.items[start..actual_end]) |item| {
        result.appendClone(item) catch {
            result.deinit();
            return null;
        };
    }
    return result;
}

// ─── C ABI: Clear ───

pub fn stz_list_clear(list: ?*StzList) callconv(.c) i32 {
    const l = list orelse return -1;
    for (l.items.items) |item| {
        item.deinit();
        allocator.destroy(item);
    }
    l.items.clearRetainingCapacity();
    return 0;
}

// ─── C ABI: Bulk String Load (null-delimited) ───

pub fn stz_list_from_null_delimited(ptr: [*]const u8, total_len: usize) callconv(.c) ?*StzList {
    const l = StzList.init() catch return null;
    if (total_len == 0) return l;

    var start: usize = 0;
    for (0..total_len) |i| {
        if (ptr[i] == 0) {
            _ = stz_list_append_string(l, ptr + start, i - start);
            start = i + 1;
        }
    }
    if (start < total_len) {
        _ = stz_list_append_string(l, ptr + start, total_len - start);
    }
    return l;
}

pub fn stz_list_to_null_delimited(list: ?*const StzList, buf: [*]u8, buf_len: usize) callconv(.c) usize {
    const l = list orelse return 0;
    var pos: usize = 0;
    for (l.items.items, 0..) |item, idx| {
        if (item.tag != .string_val) continue;
        const s = item.data.string_val;
        if (pos + s.len + 1 > buf_len) break;
        if (s.len > 0) @memcpy(buf[pos .. pos + s.len], s.ptr[0..s.len]);
        pos += s.len;
        if (idx + 1 < l.items.items.len) {
            buf[pos] = 0;
            pos += 1;
        }
    }
    return pos;
}

// ─── C ABI: Set ───

pub fn stz_list_set(list: ?*StzList, index: usize, v: ?*const StzValue) callconv(.c) i32 {
    const l = list orelse return -1;
    const src = v orelse return -1;
    if (index >= l.len()) return -1;
    const cloned = src.clone() catch return -1;
    l.items.items[index].deinit();
    allocator.destroy(l.items.items[index]);
    l.items.items[index] = cloned;
    return 0;
}

// ─── C ABI: Flatten (nested lists) ───

fn flattenInto(dest: *StzList, src: *const StzValue) !void {
    if (src.tag == .list_val) {
        const inner = src.data.list_val;
        for (0..inner.len) |i| {
            try flattenInto(dest, inner.items[i]);
        }
    } else {
        try dest.appendClone(src);
    }
}

pub fn stz_list_flatten(list: ?*const StzList) callconv(.c) ?*StzList {
    const l = list orelse return null;
    const result = StzList.init() catch return null;
    for (l.items.items) |item| {
        flattenInto(result, item) catch {
            result.deinit();
            return null;
        };
    }
    return result;
}

// ─── C ABI: Type Query ───

pub fn stz_list_item_type(list: ?*const StzList, index: usize) callconv(.c) i32 {
    const l = list orelse return -1;
    const v = l.get(index) orelse return -1;
    return @intCast(@intFromEnum(v.tag));
}

pub fn stz_list_is_all_strings(list: ?*const StzList) callconv(.c) i32 {
    const l = list orelse return 0;
    for (l.items.items) |item| {
        if (item.tag != .string_val) return 0;
    }
    return 1;
}

pub fn stz_list_is_all_numbers(list: ?*const StzList) callconv(.c) i32 {
    const l = list orelse return 0;
    for (l.items.items) |item| {
        if (item.tag != .int_val and item.tag != .float_val) return 0;
    }
    return 1;
}

// ─── C ABI: List Type Checkers ───

/// Check if all items are lists.
pub fn stz_list_is_all_lists(list: ?*const StzList) callconv(.c) i32 {
    const l = list orelse return 0;
    if (l.len() == 0) return 0;
    for (l.items.items) |item| {
        if (item.tag != .list_val) return 0;
    }
    return 1;
}

/// Check if all items are pairs (lists of exactly 2 elements).
pub fn stz_list_is_all_pairs(list: ?*const StzList) callconv(.c) i32 {
    const l = list orelse return 0;
    if (l.len() == 0) return 0;
    for (l.items.items) |item| {
        if (item.tag != .list_val) return 0;
        if (item.data.list_val.len != 2) return 0;
    }
    return 1;
}

/// Check if all items are sections (pairs of numbers).
pub fn stz_list_is_all_sections(list: ?*const StzList) callconv(.c) i32 {
    const l = list orelse return 0;
    if (l.len() == 0) return 0;
    for (l.items.items) |item| {
        if (item.tag != .list_val) return 0;
        const sub = item.data.list_val;
        if (sub.len != 2) return 0;
        const a = sub.items[0];
        const b = sub.items[1];
        if ((a.tag != .int_val and a.tag != .float_val) or
            (b.tag != .int_val and b.tag != .float_val)) return 0;
    }
    return 1;
}

/// Check if list has mixed value types (hybrid).
pub fn stz_list_is_hybrid(list: ?*const StzList) callconv(.c) i32 {
    const l = list orelse return 0;
    if (l.len() <= 1) return 0;
    const first_tag = l.items.items[0].tag;
    for (l.items.items[1..]) |item| {
        if (item.tag != first_tag) return 1;
    }
    return 0;
}

/// Check if all items are equal (using case-sensitive comparison).
pub fn stz_list_all_items_equal_cs(list: ?*const StzList, case_sensitive: i32) callconv(.c) i32 {
    const l = list orelse return 1;
    const n = l.len();
    if (n <= 1) return 1;
    const cs = case_sensitive != 0;
    const first = l.get(0) orelse return 1;
    var i: usize = 1;
    while (i < n) : (i += 1) {
        const v = l.get(i) orelse return 0;
        if (!valueEqlCS(first, v, cs)) return 0;
    }
    return 1;
}

/// Check if list is a palindrome.
pub fn stz_list_is_palindrome_cs(list: ?*const StzList, case_sensitive: i32) callconv(.c) i32 {
    const l = list orelse return 1;
    const n = l.len();
    if (n <= 1) return 1;
    const cs = case_sensitive != 0;
    var i: usize = 0;
    while (i < n / 2) : (i += 1) {
        const a = l.get(i) orelse return 0;
        const b = l.get(n - 1 - i) orelse return 0;
        if (!valueEqlCS(a, b, cs)) return 0;
    }
    return 1;
}

/// Check if numeric list forms a continuous sequence (1,2,3,...).
pub fn stz_list_is_continuous(list: ?*const StzList) callconv(.c) i32 {
    const l = list orelse return 0;
    const n = l.len();
    if (n <= 1) return 1;
    // First check all numbers
    for (l.items.items) |item| {
        if (item.tag != .int_val and item.tag != .float_val) return 0;
    }
    // Sort a copy and check consecutive difference = 1
    const sorted = stz_list_clone(list) orelse return 0;
    defer stz_list_free(sorted);
    _ = stz_list_sort_cs(sorted, 1);
    var i: usize = 0;
    while (i + 1 < n) : (i += 1) {
        const a = sorted.get(i) orelse return 0;
        const b = sorted.get(i + 1) orelse return 0;
        const va: f64 = if (a.tag == .int_val) @floatFromInt(a.data.int_val) else a.data.float_val;
        const vb: f64 = if (b.tag == .int_val) @floatFromInt(b.data.int_val) else b.data.float_val;
        if (vb - va != 1.0) return 0;
    }
    return 1;
}

/// Check if all items are lists of the same size.
pub fn stz_list_is_all_lists_same_size(list: ?*const StzList) callconv(.c) i32 {
    const l = list orelse return 0;
    if (l.len() == 0) return 0;
    const first = l.get(0) orelse return 0;
    if (first.tag != .list_val) return 0;
    const expected_size = first.data.list_val.len;
    var i: usize = 1;
    while (i < l.len()) : (i += 1) {
        const item = l.get(i) orelse return 0;
        if (item.tag != .list_val) return 0;
        if (item.data.list_val.len != expected_size) return 0;
    }
    return 1;
}

/// Check if strictly increasing (no equal consecutive elements).
pub fn stz_list_is_strictly_increasing(list: ?*const StzList) callconv(.c) i32 {
    const l = list orelse return 0;
    const n = l.len();
    if (n <= 1) return 1;
    var i: usize = 0;
    while (i + 1 < n) : (i += 1) {
        const a = l.get(i) orelse return 0;
        const b = l.get(i + 1) orelse return 0;
        if (a.compare(b) >= 0) return 0;
    }
    return 1;
}

/// Check if strictly decreasing (no equal consecutive elements).
pub fn stz_list_is_strictly_decreasing(list: ?*const StzList) callconv(.c) i32 {
    const l = list orelse return 0;
    const n = l.len();
    if (n <= 1) return 1;
    var i: usize = 0;
    while (i + 1 < n) : (i += 1) {
        const a = l.get(i) orelse return 0;
        const b = l.get(i + 1) orelse return 0;
        if (a.compare(b) <= 0) return 0;
    }
    return 1;
}

/// Check if list is monotonic (either non-decreasing or non-increasing).
pub fn stz_list_is_monotonic(list: ?*const StzList) callconv(.c) i32 {
    return if (stz_list_is_sorted_ascending(list) != 0 or stz_list_is_sorted_descending(list) != 0) 1 else 0;
}

// ─── C ABI: Equality ───

pub fn stz_list_equals_cs(a: ?*const StzList, b: ?*const StzList, case_sensitive: i32) callconv(.c) i32 {
    const la = a orelse return if (b == null) 1 else 0;
    const lb = b orelse return 0;
    if (la.len() != lb.len()) return 0;
    const cs = case_sensitive != 0;
    for (la.items.items, lb.items.items) |ia, ib| {
        if (!valueEqlCS(ia, ib, cs)) return 0;
    }
    return 1;
}

// ─── C ABI: Classify / Frequencies ───

fn valueToString(v: *const StzValue, buf: []u8) usize {
    return switch (v.tag) {
        .null_val => blk: {
            const s = "null";
            if (s.len <= buf.len) @memcpy(buf[0..s.len], s);
            break :blk @min(s.len, buf.len);
        },
        .bool_val => blk: {
            const s = if (v.data.bool_val) "true" else "false";
            if (s.len <= buf.len) @memcpy(buf[0..s.len], s);
            break :blk @min(s.len, buf.len);
        },
        .int_val => blk: {
            const n = std.fmt.bufPrint(buf, "{d}", .{v.data.int_val}) catch break :blk 0;
            break :blk n.len;
        },
        .float_val => blk: {
            const n = std.fmt.bufPrint(buf, "{d}", .{v.data.float_val}) catch break :blk 0;
            break :blk n.len;
        },
        .string_val => blk: {
            const s = v.data.string_val;
            const copy_len = @min(s.len, buf.len);
            if (copy_len > 0) @memcpy(buf[0..copy_len], s.ptr[0..copy_len]);
            break :blk copy_len;
        },
        .list_val => blk: {
            // Content-based key so distinct sub-lists classify into distinct
            // groups (e.g. [1,2,3] vs [4,5]); recurses for nested lists.
            // Truncates at buf.len (keys only need to disambiguate).
            const ld = v.data.list_val;
            if (ld.len == 0) {
                const s = "[ ]";
                if (s.len <= buf.len) @memcpy(buf[0..s.len], s);
                break :blk @min(s.len, buf.len);
            }
            var pos: usize = 0;
            // matches @@ rendering: "[ a, b, c ]"
            if (pos + 2 <= buf.len) {
                buf[pos] = '[';
                buf[pos + 1] = ' ';
                pos += 2;
            }
            var i: usize = 0;
            while (i < ld.len) : (i += 1) {
                if (i > 0 and pos + 2 <= buf.len) {
                    buf[pos] = ',';
                    buf[pos + 1] = ' ';
                    pos += 2;
                }
                if (pos < buf.len) {
                    pos += valueToString(ld.items[i], buf[pos..]);
                }
            }
            if (pos + 2 <= buf.len) {
                buf[pos] = ' ';
                buf[pos + 1] = ']';
                pos += 2;
            }
            break :blk pos;
        },
    };
}

fn findInSeen(seen: []const []const u8, key: []const u8, case_sensitive: bool) ?usize {
    for (seen, 0..) |s, i| {
        if (case_sensitive) {
            if (s.len == key.len and std.mem.eql(u8, s, key)) return i;
        } else {
            if (strEqlCI(s.ptr, s.len, key.ptr, key.len)) return i;
        }
    }
    return null;
}

// Native dense str-mode classify -> nested [ [repString, [pos...]], ... ].
// Groups by content (cs: exact bytes; !cs: ASCII case-fold, matching the boxed
// engine semantics). Representative key = first ORIGINAL occurrence.
fn classifyStrsFast(arr: []const []u8, cs: bool) ?*StzList {
    const result = StzList.init() catch return null;
    if (arr.len == 0) return result;

    var group_of = std.StringHashMapUnmanaged(usize){};
    var groups = std.ArrayList(std.ArrayList(i64)){};
    var reps = std.ArrayList([]const u8){};
    var keys_owned = std.ArrayList([]u8){}; // folded keys (cs=0) to free at end
    defer {
        group_of.deinit(allocator);
        for (groups.items) |*g| g.deinit(allocator);
        groups.deinit(allocator);
        reps.deinit(allocator);
        for (keys_owned.items) |k| allocator.free(k);
        keys_owned.deinit(allocator);
    }

    for (arr, 0..) |s, i| {
        var key: []const u8 = s;
        var folded: ?[]u8 = null;
        if (!cs) {
            const fb = allocator.alloc(u8, s.len) catch continue;
            for (s, 0..) |c, j| fb[j] = if (c >= 'A' and c <= 'Z') c + 32 else c;
            key = fb;
            folded = fb;
        }
        const gop = group_of.getOrPut(allocator, key) catch {
            if (folded) |f| allocator.free(f);
            continue;
        };
        if (!gop.found_existing) {
            gop.value_ptr.* = groups.items.len;
            groups.append(allocator, .{}) catch {};
            reps.append(allocator, s) catch {};
            if (folded) |f| keys_owned.append(allocator, f) catch {};
        } else if (folded) |f| {
            allocator.free(f); // duplicate key -> drop the folded copy
        }
        groups.items[gop.value_ptr.*].append(allocator, @intCast(i + 1)) catch {};
    }

    for (groups.items, 0..) |grp, gi| {
        const pair = value_mod.stz_value_new_list() orelse {
            result.deinit();
            return null;
        };
        const rep = reps.items[gi];
        const kval = value_mod.stz_value_new_string(rep.ptr, rep.len) orelse {
            value_mod.stz_value_free(pair);
            result.deinit();
            return null;
        };
        _ = value_mod.stz_value_list_append(pair, kval);
        value_mod.stz_value_free(kval);
        const pos_val = value_mod.stz_value_new_list() orelse {
            value_mod.stz_value_free(pair);
            result.deinit();
            return null;
        };
        for (grp.items) |pos| {
            const iv = value_mod.stz_value_new_int(pos) orelse continue;
            _ = value_mod.stz_value_list_append(pos_val, iv);
            value_mod.stz_value_free(iv);
        }
        _ = value_mod.stz_value_list_append(pair, pos_val);
        value_mod.stz_value_free(pos_val);
        _ = stz_list_append_value(result, pair);
        value_mod.stz_value_free(pair);
    }
    return result;
}

pub fn stz_list_classify_cs(list_arg: ?*const StzList, case_sensitive: i32) callconv(.c) ?*StzList {
    const l = list_arg orelse return null;
    const cs = case_sensitive != 0;
    if (l.strs) |arr| return classifyStrsFast(arr.items, cs);
    const n = l.len();
    const result = StzList.init() catch return null;
    if (n == 0) return result;

    // O(n) grouping: a value-set maps each distinct value to its group index.
    // Each group keeps its 1-based positions in a growable list, plus a
    // representative item (for the key string). Output is a flat list of
    // [ keyString, [pos1, pos2, ...] ] pairs -- positions as a NATIVE nested
    // int list (no CSV string), so Ring never re-parses them.
    var group_of = std.HashMap(*const StzValue, usize, ValueSetCtx, std.hash_map.default_max_load_percentage).initContext(allocator, ValueSetCtx{ .cs = cs });
    defer group_of.deinit();

    var groups = std.ArrayList(std.ArrayList(i64)){};
    defer {
        for (groups.items) |*g| g.deinit(allocator);
        groups.deinit(allocator);
    }
    var reps = std.ArrayList(*const StzValue){};
    defer reps.deinit(allocator);

    for (l.items.items, 0..) |item, i| {
        const gop = group_of.getOrPut(item) catch {
            result.deinit();
            return null;
        };
        if (!gop.found_existing) {
            gop.value_ptr.* = groups.items.len;
            groups.append(allocator, .{}) catch {
                result.deinit();
                return null;
            };
            reps.append(allocator, item) catch {
                result.deinit();
                return null;
            };
        }
        groups.items[gop.value_ptr.*].append(allocator, @intCast(i + 1)) catch {};
    }

    for (groups.items, 0..) |grp, gi| {
        var kbuf: [256]u8 = undefined;
        const klen = valueToString(reps.items[gi], &kbuf);

        // Emit each group as a nested [ keyString, [pos1, pos2, ...] ] PAIR so
        // the Ring side receives the FINAL shape directly. Previously this
        // returned a flat [ key, posList, key, posList, ... ] and Ring had to
        // repackage into pairs -- which copied every position sublist in
        // interpreted Ring (O(n)), the real cost of Classify() at scale.
        const pair = value_mod.stz_value_new_list() orelse {
            result.deinit();
            return null;
        };

        const kval = value_mod.stz_value_new_string(&kbuf, klen) orelse {
            value_mod.stz_value_free(pair);
            result.deinit();
            return null;
        };
        _ = value_mod.stz_value_list_append(pair, kval);
        value_mod.stz_value_free(kval);

        const pos_val = value_mod.stz_value_new_list() orelse {
            value_mod.stz_value_free(pair);
            result.deinit();
            return null;
        };
        for (grp.items) |pos| {
            const iv = value_mod.stz_value_new_int(pos) orelse continue;
            _ = value_mod.stz_value_list_append(pos_val, iv);
            value_mod.stz_value_free(iv);
        }
        _ = value_mod.stz_value_list_append(pair, pos_val);
        value_mod.stz_value_free(pos_val);

        _ = stz_list_append_value(result, pair);
        value_mod.stz_value_free(pair);
    }
    return result;
}

pub fn stz_list_frequencies_cs(list_arg: ?*const StzList, case_sensitive: i32) callconv(.c) ?*StzList {
    const l = list_arg orelse return null;
    const cs = case_sensitive != 0;
    const n = l.len();
    const result = StzList.init() catch return null;
    if (n == 0) return result;

    const key_bufs = allocator.alloc([256]u8, n) catch { result.deinit(); return null; };
    defer allocator.free(key_bufs);
    const key_lens = allocator.alloc(usize, n) catch { result.deinit(); return null; };
    defer allocator.free(key_lens);

    for (l.items.items, 0..) |item, i| {
        key_lens[i] = valueToString(item, &key_bufs[i]);
        if (!cs) {
            for (key_bufs[i][0..key_lens[i]]) |*c| {
                if (c.* >= 'A' and c.* <= 'Z') c.* += 32;
            }
        }
    }

    const max_groups = n;
    const seen_keys = allocator.alloc([]const u8, max_groups) catch { result.deinit(); return null; };
    defer allocator.free(seen_keys);
    const counts = allocator.alloc(usize, max_groups) catch { result.deinit(); return null; };
    defer allocator.free(counts);
    const first_indices = allocator.alloc(usize, max_groups) catch { result.deinit(); return null; };
    defer allocator.free(first_indices);

    var num_groups: usize = 0;

    for (0..n) |i| {
        const key = key_bufs[i][0..key_lens[i]];
        if (findInSeen(seen_keys[0..num_groups], key, true)) |gi| {
            counts[gi] += 1;
        } else {
            seen_keys[num_groups] = key;
            counts[num_groups] = 1;
            first_indices[num_groups] = i;
            num_groups += 1;
        }
    }

    // Result: alternating [key_string, count_int]
    for (0..num_groups) |gi| {
        const orig_item = l.items.items[first_indices[gi]];
        var orig_buf: [256]u8 = undefined;
        const orig_len = valueToString(orig_item, &orig_buf);
        _ = stz_list_append_string(result, &orig_buf, orig_len);
        _ = stz_list_append_int(result, @intCast(counts[gi]));
    }
    return result;
}

// ─── Expression-based operations ───
// Replace Ring's eval() with native bytecode evaluation for
// Map, Filter, Reduce, FindW, and all ...W() predicates.

const expr = @import("expr.zig");

fn stzValueToVal(v: *const StzValue) expr.Val {
    return switch (v.tag) {
        .null_val => expr.Val.initNull(),
        .bool_val => expr.Val.initBool(v.data.bool_val),
        .int_val => expr.Val.initInt(v.data.int_val),
        .float_val => expr.Val.initFloat(v.data.float_val),
        .string_val => expr.Val.initStr(v.data.string_val.ptr, v.data.string_val.len),
        .list_val => expr.Val.initList(v.data.list_val.len),
    };
}

// Bridge for expr.EvalCtx.list_get: convert the StzList element at a
// 0-based index into an expr.Val, enabling This[<expr>] in W conditions.
fn listGetVal(ctx_ptr: ?*const anyopaque, idx: usize) expr.Val {
    const l: *const StzList = @ptrCast(@alignCast(ctx_ptr.?));
    if (idx >= l.items.items.len) return expr.Val.initNull();
    return stzValueToVal(l.items.items[idx]);
}

fn valToStzValue(v: expr.Val) ?*StzValue {
    return switch (v.tag) {
        .null_v => value_mod.stz_value_new_null(),
        .bool_v => value_mod.stz_value_new_bool(if (v.data.b) 1 else 0),
        .int_v => value_mod.stz_value_new_int(v.data.i),
        .float_v => value_mod.stz_value_new_float(v.data.f),
        .str_v => value_mod.stz_value_new_string(v.data.s.ptr, v.data.s.len),
        .list_v => value_mod.stz_value_new_null(),
    };
}

pub fn stz_list_map_expr(list: ?*const StzList, expr_ptr: [*]const u8, expr_len: usize) callconv(.c) ?*StzList {
    const l = list orelse return null;
    const prog = expr.compile(expr_ptr, expr_len) orelse return null;
    defer prog.deinit();

    const result = StzList.init() catch return null;
    const count: i64 = @intCast(l.len());

    for (l.items.items, 0..) |item, i| {
        var ctx = expr.EvalCtx{
            .item = stzValueToVal(item),
            .list_ctx = l,
            .list_len = l.len(),
            .list_get = &listGetVal,
            .index = @as(i64, @intCast(i)) + 1,
            .count = count,
        };
        const val = expr.eval(prog, &ctx);
        const sv = valToStzValue(val) orelse {
            result.deinit();
            return null;
        };
        result.items.append(allocator, sv) catch {
            sv.deinit();
            allocator.destroy(sv);
            result.deinit();
            return null;
        };
    }
    return result;
}

pub fn stz_list_filter_expr(list: ?*const StzList, expr_ptr: [*]const u8, expr_len: usize) callconv(.c) ?*StzList {
    const l = list orelse return null;
    const prog = expr.compile(expr_ptr, expr_len) orelse return null;
    defer prog.deinit();

    const result = StzList.init() catch return null;
    const count: i64 = @intCast(l.len());

    for (l.items.items, 0..) |item, i| {
        var ctx = expr.EvalCtx{
            .item = stzValueToVal(item),
            .list_ctx = l,
            .list_len = l.len(),
            .list_get = &listGetVal,
            .index = @as(i64, @intCast(i)) + 1,
            .count = count,
        };
        const val = expr.eval(prog, &ctx);
        if (val.isTruthy()) {
            result.appendClone(item) catch {
                result.deinit();
                return null;
            };
        }
    }
    return result;
}

// Column-mode cell accessor for stz_expr_eval_columns: This[k] in the formula
// reads column k (1-based; idx arrives 0-based) at the row currently under
// evaluation. ctx_ptr points to a ColCtx carrying the columns and the row.
const ColCtx = struct { cols: *const StzList, row: usize };

fn colCellGetVal(ctx_ptr: ?*const anyopaque, idx: usize) expr.Val {
    const cc: *const ColCtx = @ptrCast(@alignCast(ctx_ptr.?));
    if (idx >= cc.cols.items.items.len) return expr.Val.initNull();
    const col = cc.cols.items.items[idx];
    if (col.tag != .list_val) return expr.Val.initNull();
    const ld = col.data.list_val;
    if (cc.row >= ld.len) return expr.Val.initNull();
    return stzValueToVal(ld.items[cc.row]);
}

// Evaluate ONE compiled formula for every row, reading cells straight from the
// COLUMNS (the table's native layout). The formula compiles ONCE and the
// engine does ALL per-row work, so Ring never transposes rows nor re-runs its
// compiler (the old path ran the Ring compiler with eval() on every single
// row -- ~11us each). `columns` is a list of column lists; This[k] reads
// column k at the current row. Returns null if the formula does not compile,
// so the Ring caller can fall back to its own eval path.
pub fn stz_expr_eval_columns(columns: ?*const StzList, nrows: usize, expr_ptr: [*]const u8, expr_len: usize) callconv(.c) ?*StzList {
    const cols = columns orelse return null;
    const prog = expr.compile(expr_ptr, expr_len) orelse return null;
    defer prog.deinit();

    const result = StzList.init() catch return null;
    const ncols = cols.items.items.len;
    var cc = ColCtx{ .cols = cols, .row = 0 };
    const count: i64 = @intCast(nrows);

    var r: usize = 0;
    while (r < nrows) : (r += 1) {
        cc.row = r;
        var ctx = expr.EvalCtx{
            .list_ctx = &cc,
            .list_len = ncols,
            .list_get = &colCellGetVal,
            .index = @as(i64, @intCast(r)) + 1,
            .count = count,
        };
        const val = expr.eval(prog, &ctx);
        const sv = valToStzValue(val) orelse {
            result.deinit();
            return null;
        };
        result.items.append(allocator, sv) catch {
            sv.deinit();
            allocator.destroy(sv);
            result.deinit();
            return null;
        };
    }
    return result;
}

pub fn stz_list_reduce_expr(list: ?*const StzList, expr_ptr: [*]const u8, expr_len: usize, init_val: ?*const StzValue) callconv(.c) ?*StzValue {
    const l = list orelse return null;
    const prog = expr.compile(expr_ptr, expr_len) orelse return null;
    defer prog.deinit();

    if (l.len() == 0) {
        if (init_val) |iv| return iv.clone() catch null;
        return null;
    }

    var accum: expr.Val = if (init_val) |iv| stzValueToVal(iv) else stzValueToVal(l.items.items[0]);
    const start: usize = if (init_val != null) 0 else 1;

    for (l.items.items[start..], start..) |item, i| {
        var ctx = expr.EvalCtx{
            .item = stzValueToVal(item),
            .list_ctx = l,
            .list_len = l.len(),
            .list_get = &listGetVal,
            .index = @as(i64, @intCast(i)) + 1,
            .count = @intCast(l.len()),
            .accum = accum,
        };
        accum = expr.eval(prog, &ctx);
    }

    return valToStzValue(accum);
}

pub fn stz_list_find_first_w(list: ?*const StzList, expr_ptr: [*]const u8, expr_len: usize) callconv(.c) i64 {
    const l = list orelse return -1;
    const prog = expr.compile(expr_ptr, expr_len) orelse return -1;
    defer prog.deinit();

    const count: i64 = @intCast(l.len());

    for (l.items.items, 0..) |item, i| {
        var ctx = expr.EvalCtx{
            .item = stzValueToVal(item),
            .list_ctx = l,
            .list_len = l.len(),
            .list_get = &listGetVal,
            .index = @as(i64, @intCast(i)) + 1,
            .count = count,
        };
        const val = expr.eval(prog, &ctx);
        if (val.isTruthy()) return @intCast(i);
    }
    return -1;
}

pub fn stz_list_find_w(list: ?*const StzList, expr_ptr: [*]const u8, expr_len: usize, out_buf: [*]i64, out_cap: usize) callconv(.c) usize {
    const l = list orelse return 0;
    const prog = expr.compile(expr_ptr, expr_len) orelse return 0;
    defer prog.deinit();

    var found: usize = 0;
    const count: i64 = @intCast(l.len());

    for (l.items.items, 0..) |item, i| {
        var ctx = expr.EvalCtx{
            .item = stzValueToVal(item),
            .list_ctx = l,
            .list_len = l.len(),
            .list_get = &listGetVal,
            .index = @as(i64, @intCast(i)) + 1,
            .count = count,
        };
        const val = expr.eval(prog, &ctx);
        if (val.isTruthy()) {
            if (found < out_cap) out_buf[found] = @intCast(i);
            found += 1;
        }
    }
    return found;
}

pub fn stz_list_count_w(list: ?*const StzList, expr_ptr: [*]const u8, expr_len: usize) callconv(.c) usize {
    const l = list orelse return 0;
    const prog = expr.compile(expr_ptr, expr_len) orelse return 0;
    defer prog.deinit();

    var found: usize = 0;
    const count: i64 = @intCast(l.len());

    for (l.items.items, 0..) |item, i| {
        var ctx = expr.EvalCtx{
            .item = stzValueToVal(item),
            .list_ctx = l,
            .list_len = l.len(),
            .list_get = &listGetVal,
            .index = @as(i64, @intCast(i)) + 1,
            .count = count,
        };
        const val = expr.eval(prog, &ctx);
        if (val.isTruthy()) found += 1;
    }
    return found;
}

pub fn stz_list_sort_by_expr(list: ?*StzList, expr_ptr: [*]const u8, expr_len: usize, ascending: i32) callconv(.c) i32 {
    const l = list orelse return -1;
    const prog = expr.compile(expr_ptr, expr_len) orelse return -1;
    defer prog.deinit();

    const n = l.len();
    if (n <= 1) return 0;

    const keys = allocator.alloc(expr.Val, n) catch return -1;
    defer allocator.free(keys);

    const indices = allocator.alloc(usize, n) catch return -1;
    defer allocator.free(indices);

    const count: i64 = @intCast(n);
    for (l.items.items, 0..) |item, i| {
        var ctx = expr.EvalCtx{
            .item = stzValueToVal(item),
            .list_ctx = l,
            .list_len = l.len(),
            .list_get = &listGetVal,
            .index = @as(i64, @intCast(i)) + 1,
            .count = count,
        };
        keys[i] = expr.eval(prog, &ctx);
        indices[i] = i;
    }

    const asc = ascending != 0;

    const SortCtx = struct {
        k: []expr.Val,
        a: bool,
    };
    const sort_ctx = SortCtx{ .k = keys, .a = asc };
    const S = struct {
        fn lessThan(ctx: SortCtx, lhs: usize, rhs: usize) bool {
            const cmp = keyCmp(ctx.k[lhs], ctx.k[rhs]);
            return if (ctx.a) cmp < 0 else cmp > 0;
        }
    };
    std.sort.pdq(usize, indices, sort_ctx, S.lessThan);

    // Permute items according to sorted indices
    const tmp = allocator.alloc(*StzValue, n) catch return -1;
    defer allocator.free(tmp);
    for (indices, 0..) |src, dst| {
        tmp[dst] = l.items.items[src];
    }
    @memcpy(l.items.items[0..n], tmp[0..n]);

    return 0;
}

fn keyCmp(a: expr.Val, b: expr.Val) i32 {
    if ((a.tag == .int_v or a.tag == .float_v) and (b.tag == .int_v or b.tag == .float_v)) {
        const af = a.asFloat();
        const bf = b.asFloat();
        if (af < bf) return -1;
        if (af > bf) return 1;
        return 0;
    }
    if (a.tag == .str_v and b.tag == .str_v) {
        const sa = a.data.s;
        const sb = b.data.s;
        const min_len = @min(sa.len, sb.len);
        if (min_len > 0) {
            const ord = std.mem.order(u8, sa.ptr[0..min_len], sb.ptr[0..min_len]);
            if (ord != .eq) return if (ord == .lt) @as(i32, -1) else @as(i32, 1);
        }
        if (sa.len < sb.len) return -1;
        if (sa.len > sb.len) return 1;
        return 0;
    }
    if (a.tag == .bool_v and b.tag == .bool_v) {
        const ai: i32 = if (a.data.b) 1 else 0;
        const bi: i32 = if (b.data.b) 1 else 0;
        return ai - bi;
    }
    return 0;
}

// ─── C ABI: Duplicate Analysis ───

pub fn stz_list_find_duplicates_cs(list_arg: ?*const StzList, case_sensitive: i32) callconv(.c) ?*StzList {
    const l = list_arg orelse return null;
    const cs = case_sensitive != 0;
    const n = l.len();
    const result = StzList.init() catch return null;
    if (n <= 1) return result;

    // Track first-seen index for each unique item; duplicates get appended to result
    var i: usize = 0;
    while (i < n) : (i += 1) {
        const item = l.items.items[i];
        var is_dup = false;
        for (l.items.items[0..i]) |prev| {
            if (valueEqlCS(prev, item, cs)) {
                is_dup = true;
                break;
            }
        }
        if (is_dup) {
            _ = stz_list_append_int(result, @intCast(i));
        }
    }
    return result;
}

pub fn stz_list_find_non_duplicated_cs(list_arg: ?*const StzList, case_sensitive: i32) callconv(.c) ?*StzList {
    const l = list_arg orelse return null;
    const cs = case_sensitive != 0;
    const n = l.len();
    const result = StzList.init() catch return null;

    // For each item, count occurrences. If exactly 1, it's non-duplicated.
    var i: usize = 0;
    while (i < n) : (i += 1) {
        const item = l.items.items[i];
        var count: usize = 0;
        for (l.items.items) |other| {
            if (valueEqlCS(other, item, cs)) {
                count += 1;
                if (count > 1) break;
            }
        }
        if (count == 1) {
            _ = stz_list_append_int(result, @intCast(i));
        }
    }
    return result;
}

pub fn stz_list_all_unique_cs(list_arg: ?*const StzList, case_sensitive: i32) callconv(.c) i32 {
    const l = list_arg orelse return 1;
    const cs = case_sensitive != 0;
    const n = l.len();
    if (n <= 1) return 1;

    var i: usize = 0;
    while (i < n) : (i += 1) {
        var j: usize = i + 1;
        while (j < n) : (j += 1) {
            if (valueEqlCS(l.items.items[i], l.items.items[j], cs)) return 0;
        }
    }
    return 1;
}

// ─── C ABI: Set Operations ───

// ─── Dense int-mode set-op / dedup fast paths (native i64 hash-set) ───
//
// When inputs are dense INT-MODE, set-ops run on contiguous i64 arrays with a
// native AutoHashMap(i64) -- no pointer-chasing boxed values, no structural
// value hashing -- and build a dense int-mode result. Near-native speed.

const IntSet = std.AutoHashMapUnmanaged(i64, void);

fn unionIntsFast(a: []const i64, b: []const i64) ?*StzList {
    const result = StzList.initInts(a.len) catch return null;
    var seen = IntSet{};
    defer seen.deinit(allocator);
    seen.ensureTotalCapacity(allocator, @intCast(a.len + b.len)) catch {};
    for (a) |x| {
        const gop = seen.getOrPut(allocator, x) catch {
            result.deinit();
            return null;
        };
        if (!gop.found_existing) result.ints.?.append(allocator, x) catch {};
    }
    for (b) |x| {
        const gop = seen.getOrPut(allocator, x) catch {
            result.deinit();
            return null;
        };
        if (!gop.found_existing) result.ints.?.append(allocator, x) catch {};
    }
    return result;
}

fn intersectionIntsFast(a: []const i64, b: []const i64, keep_dups: bool) ?*StzList {
    const result = StzList.initInts(0) catch return null;
    var bset = IntSet{};
    defer bset.deinit(allocator);
    bset.ensureTotalCapacity(allocator, @intCast(b.len)) catch {};
    for (b) |x| bset.put(allocator, x, {}) catch {};
    if (keep_dups) {
        // common-items: keep left order AND duplicates
        for (a) |x| {
            if (bset.contains(x)) result.ints.?.append(allocator, x) catch {};
        }
        return result;
    }
    var seen = IntSet{};
    defer seen.deinit(allocator);
    for (a) |x| {
        if (!bset.contains(x)) continue;
        const gop = seen.getOrPut(allocator, x) catch {
            result.deinit();
            return null;
        };
        if (!gop.found_existing) result.ints.?.append(allocator, x) catch {};
    }
    return result;
}

fn differenceIntsFast(a: []const i64, b: []const i64) ?*StzList {
    const result = StzList.initInts(0) catch return null;
    var bset = IntSet{};
    defer bset.deinit(allocator);
    bset.ensureTotalCapacity(allocator, @intCast(b.len)) catch {};
    for (b) |x| bset.put(allocator, x, {}) catch {};
    for (a) |x| {
        if (!bset.contains(x)) result.ints.?.append(allocator, x) catch {};
    }
    return result;
}

fn uniqueIntsFast(a: []const i64) ?*StzList {
    const result = StzList.initInts(0) catch return null;
    var seen = IntSet{};
    defer seen.deinit(allocator);
    seen.ensureTotalCapacity(allocator, @intCast(a.len)) catch {};
    for (a) |x| {
        const gop = seen.getOrPut(allocator, x) catch {
            result.deinit();
            return null;
        };
        if (!gop.found_existing) result.ints.?.append(allocator, x) catch {};
    }
    return result;
}

// Dense str-mode dedup, CASE-SENSITIVE (exact bytes). Native string hash-set
// over the []u8 array -> dense str result. (cs=0 keeps the boxed fold path.)
fn uniqueStrsFast(a: []const []u8) ?*StzList {
    const result = StzList.initStrs(0) catch return null;
    var seen = std.StringHashMapUnmanaged(void){};
    defer seen.deinit(allocator);
    for (a) |s| {
        const gop = seen.getOrPut(allocator, s) catch {
            result.deinit();
            return null;
        };
        if (!gop.found_existing) {
            const copy = allocator.dupe(u8, s) catch continue;
            result.strs.?.append(allocator, copy) catch {
                allocator.free(copy);
            };
        }
    }
    return result;
}

const StrSet = std.StringHashMapUnmanaged(void);

fn appendStrCopy(result: *StzList, s: []const u8) void {
    const copy = allocator.dupe(u8, s) catch return;
    result.strs.?.append(allocator, copy) catch allocator.free(copy);
}

// Native dense str-mode set-ops (case-sensitive). Mirror the int fast paths.
fn unionStrsFast(a: []const []u8, b: []const []u8) ?*StzList {
    const result = StzList.initStrs(a.len) catch return null;
    var seen = StrSet{};
    defer seen.deinit(allocator);
    seen.ensureTotalCapacity(allocator, @intCast(a.len + b.len)) catch {};
    for (a) |s| {
        const gop = seen.getOrPut(allocator, s) catch {
            result.deinit();
            return null;
        };
        if (!gop.found_existing) appendStrCopy(result, s);
    }
    for (b) |s| {
        const gop = seen.getOrPut(allocator, s) catch {
            result.deinit();
            return null;
        };
        if (!gop.found_existing) appendStrCopy(result, s);
    }
    return result;
}

fn intersectionStrsFast(a: []const []u8, b: []const []u8, keep_dups: bool) ?*StzList {
    const result = StzList.initStrs(0) catch return null;
    var bset = StrSet{};
    defer bset.deinit(allocator);
    bset.ensureTotalCapacity(allocator, @intCast(b.len)) catch {};
    for (b) |s| bset.put(allocator, s, {}) catch {};
    if (keep_dups) {
        for (a) |s| {
            if (bset.contains(s)) appendStrCopy(result, s);
        }
        return result;
    }
    var seen = StrSet{};
    defer seen.deinit(allocator);
    for (a) |s| {
        if (!bset.contains(s)) continue;
        const gop = seen.getOrPut(allocator, s) catch {
            result.deinit();
            return null;
        };
        if (!gop.found_existing) appendStrCopy(result, s);
    }
    return result;
}

fn differenceStrsFast(a: []const []u8, b: []const []u8) ?*StzList {
    const result = StzList.initStrs(0) catch return null;
    var bset = StrSet{};
    defer bset.deinit(allocator);
    bset.ensureTotalCapacity(allocator, @intCast(b.len)) catch {};
    for (b) |s| bset.put(allocator, s, {}) catch {};
    for (a) |s| {
        if (!bset.contains(s)) appendStrCopy(result, s);
    }
    return result;
}

pub fn stz_list_intersection_cs(a: ?*const StzList, b: ?*const StzList, case_sensitive: i32) callconv(.c) ?*StzList {
    const la = a orelse return StzList.init() catch null;
    const lb = b orelse return StzList.init() catch null;
    const cs = case_sensitive != 0;
    if (la.ints != null and lb.ints != null)
        return intersectionIntsFast(la.ints.?.items, lb.ints.?.items, false);
    if (cs and la.strs != null and lb.strs != null)
        return intersectionStrsFast(la.strs.?.items, lb.strs.?.items, false);
    @constCast(la).ensureBoxed();
    @constCast(lb).ensureBoxed();
    const result = StzList.init() catch return null;

    // O(n+m): hash-set of b's values, plus a "seen" set to dedup the result.
    var bset = newValueSet(cs);
    defer bset.deinit();
    for (lb.items.items) |bi| bset.put(bi, {}) catch {};
    var seen = newValueSet(cs);
    defer seen.deinit();

    for (la.items.items) |item| {
        if (!bset.contains(item)) continue;
        if (seen.contains(item)) continue;
        seen.put(item, {}) catch {};
        result.appendClone(item) catch {
            result.deinit();
            return null;
        };
    }
    return result;
}

// Like intersection, but keeps the LEFT list's order AND duplicates (no
// dedup) -- the stzList "common items" / multiset semantic, distinct from the
// deduping set intersection above.
pub fn stz_list_common_items_cs(a: ?*const StzList, b: ?*const StzList, case_sensitive: i32) callconv(.c) ?*StzList {
    const la = a orelse return StzList.init() catch null;
    const lb = b orelse return StzList.init() catch null;
    const cs = case_sensitive != 0;
    if (la.ints != null and lb.ints != null)
        return intersectionIntsFast(la.ints.?.items, lb.ints.?.items, true);
    if (cs and la.strs != null and lb.strs != null)
        return intersectionStrsFast(la.strs.?.items, lb.strs.?.items, true);
    @constCast(la).ensureBoxed();
    @constCast(lb).ensureBoxed();
    const result = StzList.init() catch return null;

    // O(n+m): keep left order AND duplicates; just test membership in b.
    var bset = newValueSet(cs);
    defer bset.deinit();
    for (lb.items.items) |bi| bset.put(bi, {}) catch {};

    for (la.items.items) |item| {
        if (bset.contains(item)) {
            result.appendClone(item) catch {
                result.deinit();
                return null;
            };
        }
    }
    return result;
}

pub fn stz_list_union_cs(a: ?*const StzList, b: ?*const StzList, case_sensitive: i32) callconv(.c) ?*StzList {
    const la = a orelse return if (b != null) stz_list_clone(b) else StzList.init() catch null;
    const lb = b orelse return stz_list_clone(a);
    const cs = case_sensitive != 0;
    if (la.ints != null and lb.ints != null)
        return unionIntsFast(la.ints.?.items, lb.ints.?.items);
    if (cs and la.strs != null and lb.strs != null)
        return unionStrsFast(la.strs.?.items, lb.strs.?.items);
    @constCast(la).ensureBoxed();
    @constCast(lb).ensureBoxed();
    const result = stz_list_clone(la) orelse return null;

    // O(n+m): seed the seen-set from a's items, then add b-items not seen.
    var seen = newValueSet(cs);
    defer seen.deinit();
    for (la.items.items) |ai| seen.put(ai, {}) catch {};

    for (lb.items.items) |item| {
        const gop = seen.getOrPut(item) catch {
            result.deinit();
            return null;
        };
        if (!gop.found_existing) {
            result.appendClone(item) catch {
                result.deinit();
                return null;
            };
        }
    }
    return result;
}

pub fn stz_list_difference_cs(a: ?*const StzList, b: ?*const StzList, case_sensitive: i32) callconv(.c) ?*StzList {
    const la = a orelse return StzList.init() catch null;
    const lb = b orelse return stz_list_clone(a);
    const cs = case_sensitive != 0;
    if (la.ints != null and lb.ints != null)
        return differenceIntsFast(la.ints.?.items, lb.ints.?.items);
    if (cs and la.strs != null and lb.strs != null)
        return differenceStrsFast(la.strs.?.items, lb.strs.?.items);
    @constCast(la).ensureBoxed();
    @constCast(lb).ensureBoxed();
    const result = StzList.init() catch return null;

    // O(n+m): items of a not present in b.
    var bset = newValueSet(cs);
    defer bset.deinit();
    for (lb.items.items) |bi| bset.put(bi, {}) catch {};

    for (la.items.items) |item| {
        if (!bset.contains(item)) {
            result.appendClone(item) catch {
                result.deinit();
                return null;
            };
        }
    }
    return result;
}

// ─── DiffXTT support: "modified" item pairing ───
//
// Two items are "modified" (changed, not added/removed) when:
//   - both strings and one is a substring of the other, OR
//   - both lists and they share at least one element.
// Returns a list of [ old, new ] pairs (old from `a`, new from `b`),
// considering only unique items and only `b`-items absent from `a`.

fn strContainsCS(hay: []const u8, needle: []const u8, cs: bool) bool {
    if (needle.len == 0) return true;
    if (needle.len > hay.len) return false;
    if (cs) return std.mem.indexOf(u8, hay, needle) != null;
    var i: usize = 0;
    while (i + needle.len <= hay.len) : (i += 1) {
        if (strEqlCI(hay.ptr + i, needle.len, needle.ptr, needle.len)) return true;
    }
    return false;
}

fn listsOverlapCS(la: *const StzValue, lb: *const StzValue, cs: bool) bool {
    const a = la.data.list_val;
    const b = lb.data.list_val;
    for (0..a.len) |i| {
        for (0..b.len) |j| {
            if (valueEqlCS(a.items[i], b.items[j], cs)) return true;
        }
    }
    return false;
}

fn itemsAreModified(x: *const StzValue, y: *const StzValue, cs: bool) bool {
    if (x.tag == .string_val and y.tag == .string_val) {
        const sx = x.data.string_val;
        const sy = y.data.string_val;
        return strContainsCS(sx.ptr[0..sx.len], sy.ptr[0..sy.len], cs) or
            strContainsCS(sy.ptr[0..sy.len], sx.ptr[0..sx.len], cs);
    }
    if (x.tag == .list_val and y.tag == .list_val) {
        return listsOverlapCS(x, y, cs);
    }
    return false;
}

fn makePairValue(x: *const StzValue, y: *const StzValue) ?*StzValue {
    const items = allocator.alloc(*StzValue, 2) catch return null;
    items[0] = x.clone() catch {
        allocator.free(items);
        return null;
    };
    items[1] = y.clone() catch {
        items[0].deinit();
        allocator.destroy(items[0]);
        allocator.free(items);
        return null;
    };
    const v = allocator.create(StzValue) catch return null;
    v.* = .{ .tag = .list_val, .data = .{ .list_val = .{ .items = items.ptr, .len = 2, .cap = 2 } } };
    return v;
}

pub fn stz_list_modified_items_cs(a: ?*const StzList, b: ?*const StzList, case_sensitive: i32) callconv(.c) ?*StzList {
    const la = a orelse return StzList.init() catch null;
    const lb = b orelse return StzList.init() catch null;
    const cs = case_sensitive != 0;
    const result = StzList.init() catch return null;

    // Unique items of `a`, in order.
    var this_u = std.ArrayList(*StzValue){};
    defer this_u.deinit(allocator);
    for (la.items.items) |item| {
        var seen = false;
        for (this_u.items) |u| {
            if (valueEqlCS(item, u, cs)) { seen = true; break; }
        }
        if (!seen) this_u.append(allocator, item) catch { result.deinit(); return null; };
    }

    // Unique items of `b` that are absent from `a`, in order.
    var other_u = std.ArrayList(*StzValue){};
    defer other_u.deinit(allocator);
    for (lb.items.items) |item| {
        var in_a = false;
        for (la.items.items) |ai| {
            if (valueEqlCS(item, ai, cs)) { in_a = true; break; }
        }
        if (in_a) continue;
        var seen = false;
        for (other_u.items) |u| {
            if (valueEqlCS(item, u, cs)) { seen = true; break; }
        }
        if (!seen) other_u.append(allocator, item) catch { result.deinit(); return null; };
    }

    for (this_u.items) |ti| {
        for (other_u.items) |oj| {
            if (itemsAreModified(ti, oj, cs)) {
                const pair = makePairValue(ti, oj) orelse { result.deinit(); return null; };
                result.items.append(allocator, pair) catch {
                    pair.deinit();
                    allocator.destroy(pair);
                    result.deinit();
                    return null;
                };
            }
        }
    }

    return result;
}

pub fn stz_list_is_subset_cs(a: ?*const StzList, b: ?*const StzList, case_sensitive: i32) callconv(.c) i32 {
    const la = a orelse return 1; // empty set is subset of everything
    const lb = b orelse return if (la.len() == 0) @as(i32, 1) else @as(i32, 0);
    const cs = case_sensitive != 0;

    for (la.items.items) |item| {
        var found = false;
        for (lb.items.items) |bi| {
            if (valueEqlCS(item, bi, cs)) { found = true; break; }
        }
        if (!found) return 0;
    }
    return 1;
}

// ─── String expression operations ───

fn utf8CharLen(byte: u8) usize {
    if (byte < 0x80) return 1;
    if (byte & 0xE0 == 0xC0) return 2;
    if (byte & 0xF0 == 0xE0) return 3;
    if (byte & 0xF8 == 0xF0) return 4;
    return 1;
}

pub fn stz_string_find_chars_w(str_ptr: [*]const u8, str_len: usize, expr_ptr: [*]const u8, expr_len: usize, out_buf: [*]u8, out_cap: usize) callconv(.c) usize {
    const prog = expr.compile(expr_ptr, expr_len) orelse return 0;
    defer prog.deinit();

    const str = str_ptr[0..str_len];
    var off: usize = 0;
    var char_idx: i64 = 0;
    var written: usize = 0;

    var total_chars: i64 = 0;
    {
        var tmp: usize = 0;
        while (tmp < str_len) {
            tmp += utf8CharLen(str[tmp]);
            total_chars += 1;
        }
    }

    while (off < str_len) {
        const cp_len = utf8CharLen(str[off]);
        if (off + cp_len > str_len) break;
        char_idx += 1;

        var ctx = expr.EvalCtx{
            .item = expr.Val.initNull(),
            .index = char_idx,
            .count = total_chars,
        };
        ctx.char_val = expr.Val.initStr(str[off..].ptr, cp_len);

        const val = expr.eval(prog, &ctx);
        if (val.isTruthy()) {
            var num_buf: [20]u8 = undefined;
            const num_str = std.fmt.bufPrint(&num_buf, "{}", .{char_idx}) catch break;
            if (written > 0) {
                if (written >= out_cap) break;
                out_buf[written] = ',';
                written += 1;
            }
            if (written + num_str.len > out_cap) break;
            @memcpy(out_buf[written..][0..num_str.len], num_str);
            written += num_str.len;
        }
        off += cp_len;
    }
    return written;
}

pub fn stz_string_map_chars(str_ptr: [*]const u8, str_len: usize, expr_ptr: [*]const u8, expr_len: usize) callconv(.c) ?*StzList {
    const prog = expr.compile(expr_ptr, expr_len) orelse return null;
    defer prog.deinit();

    const result = StzList.init() catch return null;
    const str = str_ptr[0..str_len];
    var off: usize = 0;
    var char_idx: i64 = 0;

    var total_chars: i64 = 0;
    {
        var tmp: usize = 0;
        while (tmp < str_len) {
            tmp += utf8CharLen(str[tmp]);
            total_chars += 1;
        }
    }

    while (off < str_len) {
        const cp_len = utf8CharLen(str[off]);
        if (off + cp_len > str_len) break;
        char_idx += 1;

        var ctx = expr.EvalCtx{
            .item = expr.Val.initNull(),
            .index = char_idx,
            .count = total_chars,
        };
        ctx.char_val = expr.Val.initStr(str[off..].ptr, cp_len);

        const val = expr.eval(prog, &ctx);
        const sv = valToStzValue(val) orelse continue;
        result.items.append(allocator, sv) catch {
            result.deinit();
            return null;
        };
        off += cp_len;
    }
    return result;
}

pub fn stz_string_count_chars_w(str_ptr: [*]const u8, str_len: usize, expr_ptr: [*]const u8, expr_len: usize) callconv(.c) usize {
    const prog = expr.compile(expr_ptr, expr_len) orelse return 0;
    defer prog.deinit();

    const str = str_ptr[0..str_len];
    var off: usize = 0;
    var char_idx: i64 = 0;
    var count: usize = 0;

    var total_chars: i64 = 0;
    {
        var tmp: usize = 0;
        while (tmp < str_len) {
            tmp += utf8CharLen(str[tmp]);
            total_chars += 1;
        }
    }

    while (off < str_len) {
        const cp_len = utf8CharLen(str[off]);
        if (off + cp_len > str_len) break;
        char_idx += 1;

        var ctx = expr.EvalCtx{
            .item = expr.Val.initNull(),
            .index = char_idx,
            .count = total_chars,
        };
        ctx.char_val = expr.Val.initStr(str[off..].ptr, cp_len);

        const val = expr.eval(prog, &ctx);
        if (val.isTruthy()) count += 1;
        off += cp_len;
    }
    return count;
}

// ─── Get sub-list from a list-typed item ───

pub fn stz_list_get_sublist(l: ?*const StzList, index: usize) callconv(.c) ?*StzList {
    const list = l orelse return null;
    const v = list.get(index) orelse return null;
    if (v.tag != .list_val) return null;
    const sub = v.data.list_val;
    const result = stz_list_new() orelse return null;
    for (0..sub.len) |i| {
        _ = stz_list_append_value(result, sub.items[i]);
    }
    return result;
}

// ─── Zip / Interleave / Partition ───

pub fn stz_list_zip(a: ?*const StzList, b: ?*const StzList) callconv(.c) ?*StzList {
    const la = a orelse return null;
    const lb = b orelse return null;
    const len_a = la.len();
    const len_b = lb.len();
    const min_len = if (len_a < len_b) len_a else len_b;

    const result = stz_list_new() orelse return null;
    for (0..min_len) |i| {
        const pair_val = value_mod.stz_value_new_list() orelse {
            stz_list_free(result);
            return null;
        };
        _ = value_mod.stz_value_list_append(pair_val, la.get(i) orelse continue);
        _ = value_mod.stz_value_list_append(pair_val, lb.get(i) orelse continue);
        _ = stz_list_append_value(result, pair_val);
        value_mod.stz_value_free(pair_val);
    }
    return result;
}

pub fn stz_list_interleave(a: ?*const StzList, b: ?*const StzList) callconv(.c) ?*StzList {
    const la = a orelse return null;
    const lb = b orelse return null;
    const len_a = la.len();
    const len_b = lb.len();
    const max_len = if (len_a > len_b) len_a else len_b;

    const result = stz_list_new() orelse return null;
    for (0..max_len) |i| {
        if (i < len_a) if (la.get(i)) |v| { _ = stz_list_append_value(result, v); };
        if (i < len_b) if (lb.get(i)) |v| { _ = stz_list_append_value(result, v); };
    }
    return result;
}

pub fn stz_list_partition(list_arg: ?*const StzList, n: usize) callconv(.c) ?*StzList {
    const list = list_arg orelse return null;
    if (n == 0) return null;
    const total = list.len();
    if (total == 0) return stz_list_new();

    const group_size = (total + n - 1) / n; // ceil division
    const result = stz_list_new() orelse return null;

    var start: usize = 0;
    for (0..n) |_| {
        if (start >= total) break;
        var end = start + group_size;
        if (end > total) end = total;

        const group_val = value_mod.stz_value_new_list() orelse {
            stz_list_free(result);
            return null;
        };
        for (start..end) |j| {
            if (list.get(j)) |v| { _ = value_mod.stz_value_list_append(group_val, v); }
        }
        _ = stz_list_append_value(result, group_val);
        value_mod.stz_value_free(group_val);
        start = end;
    }
    return result;
}

// ─── Sort On Column ───

pub fn stz_list_sort_on(list_arg: ?*StzList, col: usize) callconv(.c) i32 {
    const l = list_arg orelse return -1;
    const n = l.len();
    if (n <= 1) return 0;

    const indices = allocator.alloc(usize, n) catch return -1;
    defer allocator.free(indices);
    for (0..n) |i| indices[i] = i;

    const keys = allocator.alloc(?*const StzValue, n) catch return -1;
    defer allocator.free(keys);
    for (0..n) |i| {
        const v = l.get(i) orelse {
            keys[i] = null;
            continue;
        };
        if (v.tag == .list_val) {
            const sub = v.data.list_val;
            if (col < sub.len) {
                keys[i] = sub.items[col];
            } else {
                keys[i] = null;
            }
        } else {
            keys[i] = null;
        }
    }

    const SortCtx = struct {
        k: []?*const StzValue,
        fn lessThan(ctx: @This(), a: usize, b: usize) bool {
            const ka = ctx.k[a];
            const kb = ctx.k[b];
            if (ka == null and kb == null) return false;
            if (ka == null) return true;
            if (kb == null) return false;
            return ka.?.compare(kb.?) < 0;
        }
    };
    std.sort.pdq(usize, indices, SortCtx{ .k = keys }, SortCtx.lessThan);

    const tmp = allocator.alloc(*StzValue, n) catch return -1;
    defer allocator.free(tmp);
    for (indices, 0..) |src, dst| {
        tmp[dst] = l.items.items[src];
    }
    @memcpy(l.items.items[0..n], tmp);
    return 0;
}

// ─── Rotate ───

pub fn stz_list_rotate_left(list_arg: ?*StzList, n: usize) callconv(.c) i32 {
    const l = list_arg orelse return -1;
    const total = l.len();
    if (total <= 1 or n == 0) return 0;
    const shift = n % total;
    if (shift == 0) return 0;

    const result = stz_list_new() orelse return -1;
    for (shift..total) |i| {
        if (l.get(i)) |v| { _ = stz_list_append_value(result, v); }
    }
    for (0..shift) |i| {
        if (l.get(i)) |v| { _ = stz_list_append_value(result, v); }
    }
    _ = stz_list_clear(l);
    for (0..result.len()) |i| {
        if (result.get(i)) |v| { _ = stz_list_append_value(l, v); }
    }
    stz_list_free(result);
    return 0;
}

pub fn stz_list_rotate_right(list_arg: ?*StzList, n: usize) callconv(.c) i32 {
    const l = list_arg orelse return -1;
    const total = l.len();
    if (total <= 1 or n == 0) return 0;
    const shift = n % total;
    if (shift == 0) return 0;
    return stz_list_rotate_left(l, total - shift);
}

// ─── Chunked / Paired ───

pub fn stz_list_chunked(list_arg: ?*const StzList, n: usize) callconv(.c) ?*StzList {
    const l = list_arg orelse return null;
    if (n == 0) return null;
    const total = l.len();
    const result = stz_list_new() orelse return null;

    var start: usize = 0;
    while (start < total) {
        var end = start + n;
        if (end > total) end = total;

        const chunk_val = value_mod.stz_value_new_list() orelse {
            stz_list_free(result);
            return null;
        };
        for (start..end) |j| {
            if (l.get(j)) |v| { _ = value_mod.stz_value_list_append(chunk_val, v); }
        }
        _ = stz_list_append_value(result, chunk_val);
        value_mod.stz_value_free(chunk_val);
        start = end;
    }
    return result;
}

pub fn stz_list_paired(list_arg: ?*const StzList) callconv(.c) ?*StzList {
    return stz_list_chunked(list_arg, 2);
}

// ─── Sliding Window ───

pub fn stz_list_sliding_window(list_arg: ?*const StzList, n: usize) callconv(.c) ?*StzList {
    const l = list_arg orelse return null;
    if (n == 0) return null;
    const total = l.len();
    if (total == 0 or n > total) return stz_list_new();
    const result = stz_list_new() orelse return null;

    for (0..total - n + 1) |i| {
        const window_val = value_mod.stz_value_new_list() orelse {
            stz_list_free(result);
            return null;
        };
        for (i..i + n) |j| {
            if (l.get(j)) |v| { _ = value_mod.stz_value_list_append(window_val, v); }
        }
        _ = stz_list_append_value(result, window_val);
        value_mod.stz_value_free(window_val);
    }
    return result;
}

// ─── Deep (nested) list / path API ───
//
// A "path" is a list of 1-based indices locating an item in a nested list,
// e.g. [2,3,2] = 2nd item of the 3rd item of the 2nd item. These power the
// Ring stzDeepList subclass; the recursion runs HERE (engine) for speed and
// Unicode-correct value comparison, never in a Ring loop. Each function takes
// already-marshalled engine StzList handles and returns a fresh StzList whose
// elements are themselves int-list paths -- Ring unmarshals via the usual
// StzEngineContentFromList round-trip (nesting preserved).

// Append `path` (a slice of 1-based indices) as one list_val element of `result`.
fn dplAppendPath(result: *StzList, path: []const i64) void {
    const pv = value_mod.stz_value_new_list() orelse return;
    defer value_mod.stz_value_free(pv);
    for (path) |idx| {
        const iv = value_mod.stz_value_new_int(idx) orelse continue;
        _ = value_mod.stz_value_list_append(pv, iv);
        value_mod.stz_value_free(iv);
    }
    _ = stz_list_append_value(result, pv);
}

fn dplPathsRec(items: []const *StzValue, path: *std.ArrayList(i64), result: *StzList) void {
    for (items, 0..) |item, i| {
        path.append(allocator, @as(i64, @intCast(i + 1))) catch return;
        dplAppendPath(result, path.items);
        if (item.tag == .list_val) {
            const sub = item.data.list_val;
            dplPathsRec(sub.items[0..sub.len], path, result);
        }
        path.items.len -= 1;
    }
}

// All paths of the nested list, pre-order (parent before its children).
pub fn stz_list_deep_paths(list_arg: ?*const StzList) callconv(.c) ?*StzList {
    const l = list_arg orelse return null;
    const result = stz_list_new() orelse return null;
    var path: std.ArrayList(i64) = .{};
    defer path.deinit(allocator);
    dplPathsRec(l.items.items, &path, result);
    return result;
}

fn dplFindRec(items: []const *StzValue, needle: *const StzValue, cs: bool, path: *std.ArrayList(i64), result: *StzList) void {
    for (items, 0..) |item, i| {
        path.append(allocator, @as(i64, @intCast(i + 1))) catch return;
        if (valueEqlCS(item, needle, cs)) {
            dplAppendPath(result, path.items);
        } else if (item.tag == .list_val) {
            const sub = item.data.list_val;
            dplFindRec(sub.items[0..sub.len], needle, cs, path, result);
        }
        path.items.len -= 1;
    }
}

// Paths to every occurrence of a value. The needle is passed wrapped in a
// 1-element list (marshalled in this DLL) -- avoids a cross-DLL value handle.
pub fn stz_list_deep_find(list_arg: ?*const StzList, needle_list: ?*const StzList, case_sensitive: i32) callconv(.c) ?*StzList {
    const l = list_arg orelse return null;
    const result = stz_list_new() orelse return null;
    const nl = needle_list orelse return result;
    if (nl.len() == 0) return result;
    const needle = nl.items.items[0];
    var path: std.ArrayList(i64) = .{};
    defer path.deinit(allocator);
    dplFindRec(l.items.items, needle, case_sensitive != 0, &path, result);
    return result;
}

// Navigate to the value at a path (slice of 1-based int values). Returns the
// borrowed value, or null if the path is invalid / deeper than the structure.
fn dplNavigate(l: *const StzList, path_items: []const *StzValue) ?*const StzValue {
    if (path_items.len == 0) return null;
    var cur: []const *StzValue = l.items.items;
    var found: ?*const StzValue = null;
    for (path_items, 0..) |p, depth| {
        const idx1 = value_mod.stz_value_get_int(p);
        if (idx1 < 1) return null;
        const idx: usize = @intCast(idx1 - 1);
        if (idx >= cur.len) return null;
        const item = cur[idx];
        if (depth + 1 == path_items.len) {
            found = item;
            break;
        }
        if (item.tag != .list_val) return null;
        const sub = item.data.list_val;
        cur = sub.items[0..sub.len];
    }
    return found;
}

// 1-element list wrapping the value at `path_list`, or an EMPTY list if the
// path is invalid (the Ring side raises on an empty result).
pub fn stz_list_item_at_path(list_arg: ?*const StzList, path_list: ?*const StzList) callconv(.c) ?*StzList {
    const l = list_arg orelse return null;
    const result = stz_list_new() orelse return null;
    const pl = path_list orelse return result;
    if (dplNavigate(l, pl.items.items)) |v| {
        _ = stz_list_append_value(result, v);
    }
    return result;
}

// `paths_list` is a list of paths (each a sublist of ints). Returns the located
// values in order; paths that don't resolve are skipped.
pub fn stz_list_items_at_paths(list_arg: ?*const StzList, paths_list: ?*const StzList) callconv(.c) ?*StzList {
    const l = list_arg orelse return null;
    const result = stz_list_new() orelse return null;
    const pl = paths_list orelse return result;
    for (pl.items.items) |path_val| {
        if (path_val.tag != .list_val) continue;
        const sub = path_val.data.list_val;
        if (dplNavigate(l, sub.items[0..sub.len])) |v| {
            _ = stz_list_append_value(result, v);
        }
    }
    return result;
}

// All paths whose length == depth.
pub fn stz_list_paths_at_depth(list_arg: ?*const StzList, depth: usize) callconv(.c) ?*StzList {
    const l = list_arg orelse return null;
    const all = stz_list_deep_paths(l) orelse return null;
    defer stz_list_free(all);
    const result = stz_list_new() orelse return null;
    for (all.items.items) |path_val| {
        if (path_val.tag == .list_val and path_val.data.list_val.len == depth) {
            _ = stz_list_append_value(result, path_val);
        }
    }
    return result;
}

// The deepest paths (those of maximal length).
pub fn stz_list_longest_paths(list_arg: ?*const StzList) callconv(.c) ?*StzList {
    const l = list_arg orelse return null;
    const all = stz_list_deep_paths(l) orelse return null;
    defer stz_list_free(all);
    var max_len: usize = 0;
    for (all.items.items) |path_val| {
        if (path_val.tag == .list_val and path_val.data.list_val.len > max_len) {
            max_len = path_val.data.list_val.len;
        }
    }
    const result = stz_list_new() orelse return null;
    if (max_len == 0) return result;
    for (all.items.items) |path_val| {
        if (path_val.tag == .list_val and path_val.data.list_val.len == max_len) {
            _ = stz_list_append_value(result, path_val);
        }
    }
    return result;
}

// The path itself, followed by every sub-path beneath it (pre-order).
pub fn stz_list_expand_path(list_arg: ?*const StzList, path_list: ?*const StzList) callconv(.c) ?*StzList {
    const l = list_arg orelse return null;
    const result = stz_list_new() orelse return null;
    const pl = path_list orelse return result;
    var base: std.ArrayList(i64) = .{};
    defer base.deinit(allocator);
    for (pl.items.items) |p| {
        base.append(allocator, value_mod.stz_value_get_int(p)) catch return result;
    }
    dplAppendPath(result, base.items);
    if (dplNavigate(l, pl.items.items)) |v| {
        if (v.tag == .list_val) {
            const sub = v.data.list_val;
            dplPathsRec(sub.items[0..sub.len], &base, result);
        }
    }
    return result;
}

// ─── Anti-Sections ───

/// Given a list of length `total` and a set of section pairs [start, end] (0-based),
/// return the complementary sections — the gaps NOT covered by any input section.
pub fn stz_list_anti_sections(list_arg: ?*const StzList, sections: ?*const StzList) callconv(.c) ?*StzList {
    const l = list_arg orelse return null;
    const secs = sections orelse return null;
    const total = l.len();
    if (total == 0) return stz_list_new();

    // Collect and clamp section pairs
    const nsec = secs.len();
    var pairs: [128][2]usize = undefined;
    var npairs: usize = 0;
    var idx: usize = 0;
    while (idx < nsec and npairs < 128) : (idx += 1) {
        const pair_val = secs.get(idx) orelse continue;
        if (pair_val.tag != .list_val) continue;
        const sub = pair_val.data.list_val;
        if (sub.len < 2) continue;
        const v1 = sub.items[0];
        const v2 = sub.items[1];
        if (v1.tag != .int_val or v2.tag != .int_val) continue;
        var s: usize = @intCast(@max(0, v1.data.int_val));
        var e: usize = @intCast(@max(0, v2.data.int_val));
        if (s > e) {
            const tmp = s;
            s = e;
            e = tmp;
        }
        if (s >= total) continue;
        if (e >= total) e = total - 1;
        pairs[npairs] = .{ s, e };
        npairs += 1;
    }

    // Sort pairs by start
    if (npairs > 1) {
        for (0..npairs - 1) |a| {
            for (a + 1..npairs) |b| {
                if (pairs[a][0] > pairs[b][0]) {
                    const tmp = pairs[a];
                    pairs[a] = pairs[b];
                    pairs[b] = tmp;
                }
            }
        }
    }

    // Merge overlapping
    var merged: [128][2]usize = undefined;
    var nmerged: usize = 0;
    if (npairs > 0) {
        merged[0] = pairs[0];
        nmerged = 1;
        for (1..npairs) |i| {
            if (pairs[i][0] <= merged[nmerged - 1][1] + 1) {
                if (pairs[i][1] > merged[nmerged - 1][1]) {
                    merged[nmerged - 1][1] = pairs[i][1];
                }
            } else {
                merged[nmerged] = pairs[i];
                nmerged += 1;
            }
        }
    }

    // Build anti-sections (gaps)
    const result = stz_list_new() orelse return null;
    var prev: usize = 0;

    for (0..nmerged) |i| {
        if (merged[i][0] > prev) {
            // Gap from prev to merged[i][0]-1
            const gap = value_mod.stz_value_new_list() orelse continue;
            const v1 = value_mod.stz_value_new_int(@intCast(prev));
            _ = value_mod.stz_value_list_append(gap, v1);
            value_mod.stz_value_free(v1);
            const v2 = value_mod.stz_value_new_int(@intCast(merged[i][0] - 1));
            _ = value_mod.stz_value_list_append(gap, v2);
            value_mod.stz_value_free(v2);
            _ = stz_list_append_value(result, gap);
            value_mod.stz_value_free(gap);
        }
        prev = merged[i][1] + 1;
    }

    // Trailing gap
    if (prev < total) {
        const gap = value_mod.stz_value_new_list() orelse return result;
        const v1 = value_mod.stz_value_new_int(@intCast(prev));
        _ = value_mod.stz_value_list_append(gap, v1);
        value_mod.stz_value_free(v1);
        const v2 = value_mod.stz_value_new_int(@intCast(total - 1));
        _ = value_mod.stz_value_list_append(gap, v2);
        value_mod.stz_value_free(v2);
        _ = stz_list_append_value(result, gap);
        value_mod.stz_value_free(gap);
    }

    return result;
}

// ─── Deep Flatten ───

fn deepFlattenInto(l: *const StzList, result: *StzList) void {
    for (0..l.len()) |i| {
        const v = l.get(i) orelse continue;
        if (v.tag == .list_val) {
            const sub = v.data.list_val;
            const temp = stz_list_new() orelse continue;
            for (0..sub.len) |j| {
                _ = stz_list_append_value(temp, sub.items[j]);
            }
            deepFlattenInto(temp, result);
            stz_list_free(temp);
        } else {
            _ = stz_list_append_value(result, v);
        }
    }
}

pub fn stz_list_deep_flatten(list_arg: ?*const StzList) callconv(.c) ?*StzList {
    const l = list_arg orelse return null;
    const result = stz_list_new() orelse return null;
    deepFlattenInto(l, result);
    return result;
}

pub fn stz_list_flatten_to_depth(list_arg: ?*const StzList, depth: usize) callconv(.c) ?*StzList {
    const l = list_arg orelse return null;
    if (depth == 0) {
        return stz_list_clone(l);
    }
    const result = stz_list_new() orelse return null;
    for (0..l.len()) |i| {
        const v = l.get(i) orelse continue;
        if (v.tag == .list_val) {
            const sub = v.data.list_val;
            const temp = stz_list_new() orelse continue;
            for (0..sub.len) |j| {
                _ = stz_list_append_value(temp, sub.items[j]);
            }
            const flattened = stz_list_flatten_to_depth(temp, depth - 1);
            stz_list_free(temp);
            if (flattened) |f| {
                for (0..f.len()) |k| {
                    if (f.get(k)) |fv| { _ = stz_list_append_value(result, fv); }
                }
                stz_list_free(f);
            }
        } else {
            _ = stz_list_append_value(result, v);
        }
    }
    return result;
}

// ─── Is Sorted ───

pub fn stz_list_is_sorted_ascending(list_arg: ?*const StzList) callconv(.c) i32 {
    const l = list_arg orelse return 0;
    const n = l.len();
    if (n <= 1) return 1;
    var i: usize = 0;
    while (i + 1 < n) : (i += 1) {
        const a = l.get(i) orelse continue;
        const b = l.get(i + 1) orelse continue;
        if (a.compare(b) > 0) return 0;
    }
    return 1;
}

pub fn stz_list_is_sorted_descending(list_arg: ?*const StzList) callconv(.c) i32 {
    const l = list_arg orelse return 0;
    const n = l.len();
    if (n <= 1) return 1;
    var i: usize = 0;
    while (i + 1 < n) : (i += 1) {
        const a = l.get(i) orelse continue;
        const b = l.get(i + 1) orelse continue;
        if (a.compare(b) < 0) return 0;
    }
    return 1;
}

// ─── Repeat ───

pub fn stz_list_repeat(list_arg: ?*const StzList, count: usize) callconv(.c) ?*StzList {
    const l = list_arg orelse return null;
    const n = l.len();
    if (n == 0 or count == 0) return stz_list_new();

    const result = stz_list_new() orelse return null;
    for (0..count) |_| {
        for (0..n) |i| {
            if (l.get(i)) |v| {
                _ = stz_list_append_value(result, v);
            }
        }
    }
    return result;
}

// ─── Shuffle ───

pub fn stz_list_shuffle(list_arg: ?*StzList) callconv(.c) i32 {
    const l = list_arg orelse return -1;
    const n = l.len();
    if (n <= 1) return 0;

    var prng = std.Random.DefaultPrng.init(@truncate(@as(u128, @bitCast(std.time.nanoTimestamp()))));
    const rng = prng.random();

    var i: usize = n - 1;
    while (i > 0) : (i -= 1) {
        const j = rng.intRangeAtMost(usize, 0, i);
        const tmp = l.items.items[i];
        l.items.items[i] = l.items.items[j];
        l.items.items[j] = tmp;
    }
    return 0;
}

// ─── Random Pick ───

pub fn stz_list_random_item(list_arg: ?*const StzList) callconv(.c) ?*const StzValue {
    const l = list_arg orelse return null;
    const n = l.len();
    if (n == 0) return null;

    var prng = std.Random.DefaultPrng.init(@truncate(@as(u128, @bitCast(std.time.nanoTimestamp()))));
    const idx = prng.random().intRangeLessThan(usize, 0, n);
    return l.get(idx);
}

pub fn stz_list_random_items(list_arg: ?*const StzList, count: usize) callconv(.c) ?*StzList {
    const l = list_arg orelse return null;
    const n = l.len();
    if (n == 0 or count == 0) return null;

    const result = stz_list_new() orelse return null;
    var prng = std.Random.DefaultPrng.init(@truncate(@as(u128, @bitCast(std.time.nanoTimestamp()))));
    const rng = prng.random();

    const pick = @min(count, n);
    const indices = allocator.alloc(usize, n) catch {
        stz_list_free(result);
        return null;
    };
    defer allocator.free(indices);
    for (0..n) |i| indices[i] = i;

    for (0..pick) |i| {
        const j = rng.intRangeAtMost(usize, i, n - 1);
        const tmp = indices[i];
        indices[i] = indices[j];
        indices[j] = tmp;
        if (l.get(indices[i])) |v| {
            _ = stz_list_append_value(result, v);
        }
    }
    return result;
}

// ─── Trim ───

pub fn stz_list_trim_leading(list_arg: ?*StzList, val: ?*const StzValue) callconv(.c) i32 {
    const l = list_arg orelse return -1;
    const v = val orelse return -1;
    while (l.len() > 0) {
        const first = l.get(0) orelse break;
        if (first.compare(v) != 0) break;
        _ = stz_list_remove_at(l, 0);
    }
    return 0;
}

pub fn stz_list_trim_trailing(list_arg: ?*StzList, val: ?*const StzValue) callconv(.c) i32 {
    const l = list_arg orelse return -1;
    const v = val orelse return -1;
    while (l.len() > 0) {
        const last = l.get(l.len() - 1) orelse break;
        if (last.compare(v) != 0) break;
        _ = stz_list_remove_at(l, l.len() - 1);
    }
    return 0;
}

pub fn stz_list_trim(list_arg: ?*StzList, val: ?*const StzValue) callconv(.c) i32 {
    const r1 = stz_list_trim_leading(list_arg, val);
    if (r1 < 0) return r1;
    return stz_list_trim_trailing(list_arg, val);
}

// ─── Section (range extraction) ───

pub fn stz_list_section(list_arg: ?*const StzList, from: usize, to: usize) callconv(.c) ?*StzList {
    const l = list_arg orelse return null;
    const n = l.len();
    if (from >= n) return stz_list_new();
    const end = @min(to + 1, n);
    if (from >= end) return stz_list_new();

    const result = stz_list_new() orelse return null;
    for (from..end) |i| {
        if (l.get(i)) |v| {
            _ = stz_list_append_value(result, v);
        }
    }
    return result;
}

// ─── Swap ───

pub fn stz_list_swap(list_arg: ?*StzList, i: usize, j: usize) callconv(.c) i32 {
    const l = list_arg orelse return -1;
    const n = l.len();
    if (i >= n or j >= n) return -1;
    if (i == j) return 0;
    const tmp = l.items.items[i];
    l.items.items[i] = l.items.items[j];
    l.items.items[j] = tmp;
    return 0;
}

// ─── C ABI: Leading / Trailing ───

pub fn stz_list_leading_count_cs(list: ?*const StzList, case_sensitive: i32) callconv(.c) i64 {
    const l = list orelse return 0;
    const n = l.len();
    if (n < 2) return 0;
    const cs = case_sensitive != 0;
    const first = l.items.items[0];
    var count: i64 = 1;
    var i: usize = 1;
    while (i < n) : (i += 1) {
        if (valueEqlCS(l.items.items[i], first, cs)) {
            count += 1;
        } else break;
    }
    if (count < 2) return 0;
    return count;
}

pub fn stz_list_trailing_count_cs(list: ?*const StzList, case_sensitive: i32) callconv(.c) i64 {
    const l = list orelse return 0;
    const n = l.len();
    if (n < 2) return 0;
    const cs = case_sensitive != 0;
    const last = l.items.items[n - 1];
    var count: i64 = 1;
    var i: usize = n - 1;
    while (i > 0) {
        i -= 1;
        if (valueEqlCS(l.items.items[i], last, cs)) {
            count += 1;
        } else break;
    }
    if (count < 2) return 0;
    return count;
}

pub fn stz_list_starts_with_cs(list: ?*const StzList, v: ?*const StzValue, case_sensitive: i32) callconv(.c) i32 {
    const l = list orelse return 0;
    if (l.len() == 0) return 0;
    const needle = v orelse return 0;
    const cs = case_sensitive != 0;
    return if (valueEqlCS(l.items.items[0], needle, cs)) 1 else 0;
}

pub fn stz_list_ends_with_cs(list: ?*const StzList, v: ?*const StzValue, case_sensitive: i32) callconv(.c) i32 {
    const l = list orelse return 0;
    const n = l.len();
    if (n == 0) return 0;
    const needle = v orelse return 0;
    const cs = case_sensitive != 0;
    return if (valueEqlCS(l.items.items[n - 1], needle, cs)) 1 else 0;
}

// Check if list starts with all items from prefix list (in order)
pub fn stz_list_starts_with_list_cs(list_arg: ?*const StzList, prefix: ?*const StzList, case_sensitive: i32) callconv(.c) i32 {
    const l = list_arg orelse return 0;
    const p = prefix orelse return 0;
    const plen = p.len();
    if (plen == 0) return 1;
    if (plen > l.len()) return 0;
    const cs = case_sensitive != 0;
    for (0..plen) |i| {
        if (!valueEqlCS(l.items.items[i], p.items.items[i], cs)) return 0;
    }
    return 1;
}

// Check if list ends with all items from suffix list (in order)
pub fn stz_list_ends_with_list_cs(list_arg: ?*const StzList, suffix: ?*const StzList, case_sensitive: i32) callconv(.c) i32 {
    const l = list_arg orelse return 0;
    const s = suffix orelse return 0;
    const slen = s.len();
    if (slen == 0) return 1;
    const llen = l.len();
    if (slen > llen) return 0;
    const cs = case_sensitive != 0;
    const offset = llen - slen;
    for (0..slen) |i| {
        if (!valueEqlCS(l.items.items[offset + i], s.items.items[i], cs)) return 0;
    }
    return 1;
}

pub fn stz_list_remove_leading_cs(list: ?*StzList, case_sensitive: i32) callconv(.c) i32 {
    const l = list orelse return -1;
    const count = stz_list_leading_count_cs(l, case_sensitive);
    if (count < 2) return 0;
    const to_remove: usize = @intCast(count - 1);
    var i: usize = 0;
    while (i < to_remove) : (i += 1) {
        const item = l.items.orderedRemove(0);
        item.deinit();
        allocator.destroy(item);
    }
    return @intCast(to_remove);
}

pub fn stz_list_remove_trailing_cs(list: ?*StzList, case_sensitive: i32) callconv(.c) i32 {
    const l = list orelse return -1;
    const count = stz_list_trailing_count_cs(l, case_sensitive);
    if (count < 2) return 0;
    const to_remove: usize = @intCast(count - 1);
    var i: usize = 0;
    while (i < to_remove) : (i += 1) {
        const idx = l.len() - 1;
        const item = l.items.orderedRemove(idx);
        item.deinit();
        allocator.destroy(item);
    }
    return @intCast(to_remove);
}

// ─── C ABI: Split At Positions ───

fn appendGroup(result: *StzList, src: *const StzList, from: usize, to: usize) void {
    const group = value_mod.stz_value_new_list() orelse return;
    for (from..to) |j| {
        _ = value_mod.stz_value_list_append(group, src.items.items[j]);
    }
    _ = stz_list_append_value(result, group);
    value_mod.stz_value_free(group);
}

pub fn stz_list_split_at(list_arg: ?*const StzList, positions: ?*const StzList) callconv(.c) ?*StzList {
    const l = list_arg orelse return null;
    const pos = positions orelse return null;
    const n = l.len();
    if (n == 0) return stz_list_new();

    const np = pos.len();
    if (np == 0) {
        const result = stz_list_new() orelse return null;
        appendGroup(result, l, 0, n);
        return result;
    }

    var cut_points: [256]usize = undefined;
    const max_cuts = @min(np, 256);
    var num_cuts: usize = 0;
    for (0..max_cuts) |i| {
        const v = pos.items.items[i];
        if (v.tag == .int_val) {
            const idx = v.data.int_val;
            if (idx >= 0 and @as(usize, @intCast(idx)) < n) {
                cut_points[num_cuts] = @intCast(idx);
                num_cuts += 1;
            }
        }
    }

    if (num_cuts == 0) {
        const result = stz_list_new() orelse return null;
        appendGroup(result, l, 0, n);
        return result;
    }

    std.mem.sort(usize, cut_points[0..num_cuts], {}, std.sort.asc(usize));

    const result = stz_list_new() orelse return null;
    var prev: usize = 0;

    for (0..num_cuts) |ci| {
        const cp = cut_points[ci];
        if (cp <= prev and ci > 0) continue;
        if (cp > prev) {
            appendGroup(result, l, prev, cp);
        }
        prev = cp;
    }

    if (prev < n) {
        appendGroup(result, l, prev, n);
    }

    return result;
}

// ─── C ABI: Split Before / After Position ───

pub fn stz_list_split_before(list_arg: ?*const StzList, pos: usize) callconv(.c) ?*StzList {
    const l = list_arg orelse return null;
    const n = l.len();
    if (n == 0) return stz_list_new();
    const p = if (pos > n) n else pos;
    const result = stz_list_new() orelse return null;
    if (p > 0) appendGroup(result, l, 0, p);
    if (p < n) appendGroup(result, l, p, n);
    return result;
}

pub fn stz_list_split_after(list_arg: ?*const StzList, pos: usize) callconv(.c) ?*StzList {
    const l = list_arg orelse return null;
    const n = l.len();
    if (n == 0) return stz_list_new();
    const p = if (pos >= n) n else pos + 1;
    const result = stz_list_new() orelse return null;
    if (p > 0) appendGroup(result, l, 0, p);
    if (p < n) appendGroup(result, l, p, n);
    return result;
}

pub fn stz_list_split_to_parts_of_n(list_arg: ?*const StzList, n: usize) callconv(.c) ?*StzList {
    const l = list_arg orelse return null;
    if (n == 0) return null;
    const len = l.len();
    if (len == 0) return stz_list_new();
    const result = stz_list_new() orelse return null;
    var i: usize = 0;
    while (i < len) {
        const end = @min(i + n, len);
        appendGroup(result, l, i, end);
        i = end;
    }
    return result;
}

// ─── C ABI: Sorted Insert ───

// Insert an already-owned StzValue at its sorted position (binary search).
// Takes ownership of new_val; on failure frees it. Returns the index.
fn sortedInsertOwned(l: *StzList, new_val: *StzValue) i32 {
    const n = l.len();
    var lo: usize = 0;
    var hi: usize = n;
    while (lo < hi) {
        const mid = lo + (hi - lo) / 2;
        if (valueCompareCS(l.items.items[mid], new_val, true) < 0) {
            lo = mid + 1;
        } else {
            hi = mid;
        }
    }
    l.items.insert(allocator, lo, new_val) catch {
        new_val.deinit();
        allocator.destroy(new_val);
        return -1;
    };
    return @intCast(lo);
}

pub fn stz_list_sorted_insert(list_arg: ?*StzList, v: ?*const StzValue) callconv(.c) i32 {
    const l = list_arg orelse return -1;
    const val = v orelse return -1;
    const new_val = val.clone() catch return -1;
    return sortedInsertOwned(l, new_val);
}

// Type-specific sorted inserts that BUILD the value inside this DLL. The
// handle-based stz_list_sorted_insert above cannot be used cross-DLL: a
// StzValue handle minted by stz_value.dll does not resolve in stz_list.dll's
// own handle table, so the value reads back as garbage (panic / wrong result).
// These avoid the cross-DLL handle entirely.
pub fn stz_list_sorted_insert_int(list_arg: ?*StzList, n: i64) callconv(.c) i32 {
    const l = list_arg orelse return -1;
    const new_val = value_mod.stz_value_new_int(n) orelse return -1;
    return sortedInsertOwned(l, new_val);
}

pub fn stz_list_sorted_insert_float(list_arg: ?*StzList, f: f64) callconv(.c) i32 {
    const l = list_arg orelse return -1;
    const new_val = value_mod.stz_value_new_float(f) orelse return -1;
    return sortedInsertOwned(l, new_val);
}

pub fn stz_list_sorted_insert_string(list_arg: ?*StzList, ptr: [*c]const u8, slen: usize) callconv(.c) i32 {
    const l = list_arg orelse return -1;
    const new_val = value_mod.stz_value_new_string(ptr, slen) orelse return -1;
    return sortedInsertOwned(l, new_val);
}

// ─── Numeric Aggregates ───

fn numericVal(item: *const StzValue) ?f64 {
    return switch (item.tag) {
        .int_val => @floatFromInt(item.data.int_val),
        .float_val => item.data.float_val,
        else => null,
    };
}

pub fn stz_list_sum(list_arg: ?*const StzList) callconv(.c) f64 {
    const l = list_arg orelse return 0;
    if (l.ints) |arr| {
        var total: f64 = 0;
        for (arr.items) |x| total += @floatFromInt(x);
        return total;
    }
    if (l.floats) |arr| {
        var total: f64 = 0;
        for (arr.items) |x| total += x;
        return total;
    }
    var total: f64 = 0;
    for (l.items.items) |item| {
        if (numericVal(item)) |v| total += v;
    }
    return total;
}

pub fn stz_list_product(list_arg: ?*const StzList) callconv(.c) f64 {
    const l = list_arg orelse return 0;
    if (l.ints) |arr| {
        if (arr.items.len == 0) return 0;
        var result: f64 = 1;
        for (arr.items) |x| result *= @floatFromInt(x);
        return result;
    }
    if (l.floats) |arr| {
        if (arr.items.len == 0) return 0;
        var result: f64 = 1;
        for (arr.items) |x| result *= x;
        return result;
    }
    if (l.len() == 0) return 0;
    var result: f64 = 1;
    var found = false;
    for (l.items.items) |item| {
        if (numericVal(item)) |v| {
            result *= v;
            found = true;
        }
    }
    return if (found) result else 0;
}

pub fn stz_list_min(list_arg: ?*const StzList) callconv(.c) f64 {
    const l = list_arg orelse return 0;
    if (l.ints) |arr| {
        if (arr.items.len == 0) return 0;
        var m: i64 = arr.items[0];
        for (arr.items) |x| {
            if (x < m) m = x;
        }
        return @floatFromInt(m);
    }
    if (l.floats) |arr| {
        if (arr.items.len == 0) return 0;
        var m: f64 = arr.items[0];
        for (arr.items) |x| {
            if (x < m) m = x;
        }
        return m;
    }
    var result: f64 = std.math.inf(f64);
    var found = false;
    for (l.items.items) |item| {
        if (numericVal(item)) |v| {
            if (v < result) result = v;
            found = true;
        }
    }
    return if (found) result else 0;
}

pub fn stz_list_max(list_arg: ?*const StzList) callconv(.c) f64 {
    const l = list_arg orelse return 0;
    if (l.ints) |arr| {
        if (arr.items.len == 0) return 0;
        var m: i64 = arr.items[0];
        for (arr.items) |x| {
            if (x > m) m = x;
        }
        return @floatFromInt(m);
    }
    if (l.floats) |arr| {
        if (arr.items.len == 0) return 0;
        var m: f64 = arr.items[0];
        for (arr.items) |x| {
            if (x > m) m = x;
        }
        return m;
    }
    var result: f64 = -std.math.inf(f64);
    var found = false;
    for (l.items.items) |item| {
        if (numericVal(item)) |v| {
            if (v > result) result = v;
            found = true;
        }
    }
    return if (found) result else 0;
}

pub fn stz_list_mean(list_arg: ?*const StzList) callconv(.c) f64 {
    const l = list_arg orelse return 0;
    if (l.ints) |arr| {
        if (arr.items.len == 0) return 0;
        var total: f64 = 0;
        for (arr.items) |x| total += @floatFromInt(x);
        return total / @as(f64, @floatFromInt(arr.items.len));
    }
    if (l.floats) |arr| {
        if (arr.items.len == 0) return 0;
        var total: f64 = 0;
        for (arr.items) |x| total += x;
        return total / @as(f64, @floatFromInt(arr.items.len));
    }
    var total: f64 = 0;
    var count: f64 = 0;
    for (l.items.items) |item| {
        if (numericVal(item)) |v| {
            total += v;
            count += 1;
        }
    }
    return if (count > 0) total / count else 0;
}

/// Return the median of a numeric list. For odd-length lists returns the middle value;
/// for even-length lists returns the average of the two middle values.
pub fn stz_list_median(list_arg: ?*const StzList) callconv(.c) f64 {
    const l = list_arg orelse return 0;
    const n = l.len();
    if (n == 0) return 0;

    // Clone and sort
    const sorted = stz_list_clone(l) orelse return 0;
    defer stz_list_free(sorted);
    _ = stz_list_sort_cs(sorted, 1);

    if (n % 2 == 1) {
        // Odd: middle element
        const mid = sorted.get(n / 2) orelse return 0;
        return numericVal(mid) orelse 0;
    } else {
        // Even: average of two middle elements
        const a = sorted.get(n / 2 - 1) orelse return 0;
        const b = sorted.get(n / 2) orelse return 0;
        const va = numericVal(a) orelse return 0;
        const vb = numericVal(b) orelse return 0;
        return (va + vb) / 2.0;
    }
}

/// Return the nth smallest value (0-based index into sorted list).
pub fn stz_list_nth_smallest(list_arg: ?*const StzList, n: usize) callconv(.c) f64 {
    const l = list_arg orelse return 0;
    if (n >= l.len()) return 0;
    const sorted = stz_list_clone(l) orelse return 0;
    defer stz_list_free(sorted);
    _ = stz_list_sort_cs(sorted, 1);
    const item = sorted.get(n) orelse return 0;
    return numericVal(item) orelse 0;
}

/// Return the nth largest value (0-based: 0 = largest, 1 = second largest, etc.).
pub fn stz_list_nth_largest(list_arg: ?*const StzList, n: usize) callconv(.c) f64 {
    const l = list_arg orelse return 0;
    if (n >= l.len()) return 0;
    const sorted = stz_list_clone(l) orelse return 0;
    defer stz_list_free(sorted);
    _ = stz_list_sort_descending_cs(sorted, 1);
    const item = sorted.get(n) orelse return 0;
    return numericVal(item) orelse 0;
}

/// Return variance of numeric items in the list.
pub fn stz_list_variance(list_arg: ?*const StzList) callconv(.c) f64 {
    const l = list_arg orelse return 0;
    const m = stz_list_mean(l);
    var sum_sq: f64 = 0;
    var count: f64 = 0;
    for (l.items.items) |item| {
        if (numericVal(item)) |v| {
            const diff = v - m;
            sum_sq += diff * diff;
            count += 1;
        }
    }
    return if (count > 0) sum_sq / count else 0;
}

/// Return standard deviation of numeric items.
pub fn stz_list_stddev(list_arg: ?*const StzList) callconv(.c) f64 {
    return @sqrt(stz_list_variance(list_arg));
}

/// Compute rank of each item (1-based rank in sorted order).
/// Returns a new StzList of integers. Ties get the same rank (min rank).
pub fn stz_list_ranked(list_arg: ?*const StzList) callconv(.c) ?*StzList {
    const l = list_arg orelse return null;
    const n = l.len();
    if (n == 0) return stz_list_new();

    const result = StzList.init() catch return null;

    // Clone and sort
    const sorted = stz_list_clone(l) orelse return null;
    defer stz_list_free(sorted);
    _ = stz_list_sort_cs(sorted, 1);

    // For each item in original, find its position in sorted list
    for (0..n) |i| {
        const item = l.get(i) orelse {
            _ = stz_list_append_int(result, 0);
            continue;
        };
        // Linear scan for rank (position in sorted list, 1-based)
        var rank: i64 = 1;
        for (0..n) |j| {
            const s_item = sorted.get(j) orelse continue;
            if (valueEqlCS(item, s_item, true)) {
                rank = @intCast(j + 1);
                break;
            }
        }
        _ = stz_list_append_int(result, rank);
    }

    return result;
}

// ─── Tests ───

pub fn stz_list_join(list_arg: ?*const StzList, sep: [*c]const u8, sep_len: usize, out_buf: [*c]u8, out_cap: usize) callconv(.c) usize {
    const l = list_arg orelse return 0;
    const n = l.len();
    if (n == 0) return 0;
    const separator = if (sep_len > 0 and sep != null) sep[0..sep_len] else "";
    var pos: usize = 0;
    for (0..n) |i| {
        if (i > 0 and separator.len > 0) {
            if (pos + separator.len > out_cap) break;
            @memcpy(out_buf[pos .. pos + separator.len], separator);
            pos += separator.len;
        }
        const item = l.items.items[i];
        switch (item.tag) {
            .string_val => {
                const sd = item.data.string_val;
                if (sd.len == 0) continue;
                if (pos + sd.len > out_cap) break;
                @memcpy(out_buf[pos .. pos + sd.len], sd.ptr[0..sd.len]);
                pos += sd.len;
            },
            .int_val => {
                var buf: [32]u8 = undefined;
                const s = std.fmt.bufPrint(&buf, "{d}", .{item.data.int_val}) catch continue;
                if (pos + s.len > out_cap) break;
                @memcpy(out_buf[pos .. pos + s.len], s);
                pos += s.len;
            },
            .float_val => {
                var buf: [64]u8 = undefined;
                const s = std.fmt.bufPrint(&buf, "{d}", .{item.data.float_val}) catch continue;
                if (pos + s.len > out_cap) break;
                @memcpy(out_buf[pos .. pos + s.len], s);
                pos += s.len;
            },
            else => {},
        }
    }
    return pos;
}

test "list join basic" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_string(l, "a", 1);
    _ = stz_list_append_string(l, "b", 1);
    _ = stz_list_append_string(l, "c", 1);
    var buf: [64]u8 = undefined;
    const n = stz_list_join(l, ", ", 2, &buf, 64);
    try std.testing.expectEqualStrings("a, b, c", buf[0..n]);
}

test "list join numbers" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 2);
    _ = stz_list_append_int(l, 3);
    var buf: [64]u8 = undefined;
    const n = stz_list_join(l, "-", 1, &buf, 64);
    try std.testing.expectEqualStrings("1-2-3", buf[0..n]);
}

test "list join empty" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    var buf: [64]u8 = undefined;
    const n = stz_list_join(l, ",", 1, &buf, 64);
    try std.testing.expectEqual(@as(usize, 0), n);
}

test "list numeric aggregates" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 10);
    _ = stz_list_append_int(l, 20);
    _ = stz_list_append_int(l, 30);
    _ = stz_list_append_float(l, 5.5);

    try std.testing.expectEqual(@as(f64, 65.5), stz_list_sum(l));
    try std.testing.expectEqual(@as(f64, 5.5), stz_list_min(l));
    try std.testing.expectEqual(@as(f64, 30), stz_list_max(l));
    try std.testing.expectEqual(@as(f64, 33000), stz_list_product(l));

    const mean = stz_list_mean(l);
    try std.testing.expect(mean > 16.37 and mean < 16.38);
}

test "list numeric aggregates empty" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    try std.testing.expectEqual(@as(f64, 0), stz_list_sum(l));
    try std.testing.expectEqual(@as(f64, 0), stz_list_min(l));
    try std.testing.expectEqual(@as(f64, 0), stz_list_max(l));
    try std.testing.expectEqual(@as(f64, 0), stz_list_product(l));
    try std.testing.expectEqual(@as(f64, 0), stz_list_mean(l));
}

test "list basic append and get" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_int(l, 10);
    _ = stz_list_append_int(l, 20);
    _ = stz_list_append_string(l, "hello", 5);

    try std.testing.expectEqual(@as(usize, 3), stz_list_len(l));
    try std.testing.expectEqual(@as(i64, 10), stz_list_get_int(l, 0));
    try std.testing.expectEqual(@as(i64, 20), stz_list_get_int(l, 1));

    var buf: [32]u8 = undefined;
    const n = stz_list_get_string(l, 2, &buf, 32);
    try std.testing.expect(std.mem.eql(u8, buf[0..n], "hello"));
}

test "list find first CS" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_string(l, "Alpha", 5);
    _ = stz_list_append_string(l, "Beta", 4);
    _ = stz_list_append_string(l, "Gamma", 5);

    try std.testing.expectEqual(@as(i64, 1), stz_list_find_first_string_cs(l, "Beta", 4, 1));
    try std.testing.expectEqual(@as(i64, -1), stz_list_find_first_string_cs(l, "beta", 4, 1));
    try std.testing.expectEqual(@as(i64, 1), stz_list_find_first_string_cs(l, "beta", 4, 0));
}

test "list contains" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_int(l, 5);
    _ = stz_list_append_int(l, 10);

    const needle = value_mod.stz_value_new_int(10) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(needle);
    try std.testing.expectEqual(@as(i32, 1), stz_list_contains_cs(l, needle, 1));

    const missing = value_mod.stz_value_new_int(99) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(missing);
    try std.testing.expectEqual(@as(i32, 0), stz_list_contains_cs(l, missing, 1));
}

test "list find" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_string(l, "a", 1);
    _ = stz_list_append_string(l, "b", 1);
    _ = stz_list_append_string(l, "a", 1);
    _ = stz_list_append_string(l, "c", 1);
    _ = stz_list_append_string(l, "a", 1);

    const needle = value_mod.stz_value_new_string("a", 1) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(needle);

    var positions: [10]i64 = undefined;
    const count = stz_list_find_cs(l, needle, 1, &positions, 10);
    try std.testing.expectEqual(@as(usize, 3), count);
    try std.testing.expectEqual(@as(i64, 0), positions[0]);
    try std.testing.expectEqual(@as(i64, 2), positions[1]);
    try std.testing.expectEqual(@as(i64, 4), positions[2]);
}

test "list count" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 2);
    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 3);
    _ = stz_list_append_int(l, 1);

    const needle = value_mod.stz_value_new_int(1) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(needle);
    try std.testing.expectEqual(@as(usize, 3), stz_list_count_cs(l, needle, 1));
}

test "list sort ascending" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_int(l, 5);
    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 3);
    _ = stz_list_append_int(l, 2);
    _ = stz_list_append_int(l, 4);

    _ = stz_list_sort(l);
    const expected = [_]i64{ 1, 2, 3, 4, 5 };
    for (expected, 0..) |exp, i| {
        try std.testing.expectEqual(exp, stz_list_get_int(l, i));
    }
}

test "list sort descending" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 5);
    _ = stz_list_append_int(l, 3);

    _ = stz_list_sort_descending(l);
    try std.testing.expectEqual(@as(i64, 5), stz_list_get_int(l, 0));
    try std.testing.expectEqual(@as(i64, 3), stz_list_get_int(l, 1));
    try std.testing.expectEqual(@as(i64, 1), stz_list_get_int(l, 2));
}

test "list sort strings" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_string(l, "cherry", 6);
    _ = stz_list_append_string(l, "apple", 5);
    _ = stz_list_append_string(l, "banana", 6);

    _ = stz_list_sort(l);
    var buf: [32]u8 = undefined;
    var n = stz_list_get_string(l, 0, &buf, 32);
    try std.testing.expect(std.mem.eql(u8, buf[0..n], "apple"));
    n = stz_list_get_string(l, 1, &buf, 32);
    try std.testing.expect(std.mem.eql(u8, buf[0..n], "banana"));
    n = stz_list_get_string(l, 2, &buf, 32);
    try std.testing.expect(std.mem.eql(u8, buf[0..n], "cherry"));
}

test "list sort_cs case insensitive" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_string(l, "banana", 6);
    _ = stz_list_append_string(l, "Apple", 5);
    _ = stz_list_append_string(l, "cherry", 6);

    _ = stz_list_sort_cs(l, 0);
    var buf: [32]u8 = undefined;
    var n = stz_list_get_string(l, 0, &buf, 32);
    try std.testing.expect(std.mem.eql(u8, buf[0..n], "Apple"));
    n = stz_list_get_string(l, 1, &buf, 32);
    try std.testing.expect(std.mem.eql(u8, buf[0..n], "banana"));
    n = stz_list_get_string(l, 2, &buf, 32);
    try std.testing.expect(std.mem.eql(u8, buf[0..n], "cherry"));

    _ = stz_list_sort_descending_cs(l, 0);
    n = stz_list_get_string(l, 0, &buf, 32);
    try std.testing.expect(std.mem.eql(u8, buf[0..n], "cherry"));
    n = stz_list_get_string(l, 1, &buf, 32);
    try std.testing.expect(std.mem.eql(u8, buf[0..n], "banana"));
    n = stz_list_get_string(l, 2, &buf, 32);
    try std.testing.expect(std.mem.eql(u8, buf[0..n], "Apple"));
}

test "list reverse" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 2);
    _ = stz_list_append_int(l, 3);

    _ = stz_list_reverse(l);
    try std.testing.expectEqual(@as(i64, 3), stz_list_get_int(l, 0));
    try std.testing.expectEqual(@as(i64, 2), stz_list_get_int(l, 1));
    try std.testing.expectEqual(@as(i64, 1), stz_list_get_int(l, 2));
}

test "list unique CS" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_string(l, "a", 1);
    _ = stz_list_append_string(l, "b", 1);
    _ = stz_list_append_string(l, "a", 1);
    _ = stz_list_append_string(l, "c", 1);
    _ = stz_list_append_string(l, "b", 1);

    const u = stz_list_unique_cs(l, 1) orelse return error.AllocFailed;
    defer stz_list_free(u);
    try std.testing.expectEqual(@as(usize, 3), stz_list_len(u));
}

test "list unique CI" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_string(l, "Hello", 5);
    _ = stz_list_append_string(l, "hello", 5);
    _ = stz_list_append_string(l, "HELLO", 5);
    _ = stz_list_append_string(l, "World", 5);

    const u = stz_list_unique_cs(l, 0) orelse return error.AllocFailed;
    defer stz_list_free(u);
    try std.testing.expectEqual(@as(usize, 2), stz_list_len(u));
}

test "list remove duplicates" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 2);
    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 3);
    _ = stz_list_append_int(l, 2);

    _ = stz_list_remove_duplicates_cs(l, 1);
    try std.testing.expectEqual(@as(usize, 3), stz_list_len(l));
    try std.testing.expectEqual(@as(i64, 1), stz_list_get_int(l, 0));
    try std.testing.expectEqual(@as(i64, 2), stz_list_get_int(l, 1));
    try std.testing.expectEqual(@as(i64, 3), stz_list_get_int(l, 2));
}

test "list clone" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 42);
    _ = stz_list_append_string(l, "test", 4);

    const c = stz_list_clone(l) orelse return error.AllocFailed;
    defer stz_list_free(c);
    try std.testing.expectEqual(@as(usize, 2), stz_list_len(c));
    try std.testing.expectEqual(@as(i64, 42), stz_list_get_int(c, 0));

    _ = stz_list_clear(l);
    try std.testing.expectEqual(@as(usize, 0), stz_list_len(l));
    try std.testing.expectEqual(@as(usize, 2), stz_list_len(c));
}

test "list slice" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    for (1..6) |n| _ = stz_list_append_int(l, @intCast(n));

    const s = stz_list_slice(l, 1, 4) orelse return error.AllocFailed;
    defer stz_list_free(s);
    try std.testing.expectEqual(@as(usize, 3), stz_list_len(s));
    try std.testing.expectEqual(@as(i64, 2), stz_list_get_int(s, 0));
    try std.testing.expectEqual(@as(i64, 4), stz_list_get_int(s, 2));
}

test "list insert and remove_at" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 3);

    const v2 = value_mod.stz_value_new_int(2) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(v2);
    _ = stz_list_insert(l, 1, v2);

    try std.testing.expectEqual(@as(usize, 3), stz_list_len(l));
    try std.testing.expectEqual(@as(i64, 2), stz_list_get_int(l, 1));

    _ = stz_list_remove_at(l, 1);
    try std.testing.expectEqual(@as(usize, 2), stz_list_len(l));
    try std.testing.expectEqual(@as(i64, 3), stz_list_get_int(l, 1));
}

test "list null delimited round-trip" {
    const input = "alpha\x00beta\x00gamma";
    const l = stz_list_from_null_delimited(input.ptr, input.len) orelse return error.AllocFailed;
    defer stz_list_free(l);

    try std.testing.expectEqual(@as(usize, 3), stz_list_len(l));
    var buf: [64]u8 = undefined;
    var n = stz_list_get_string(l, 0, &buf, 64);
    try std.testing.expect(std.mem.eql(u8, buf[0..n], "alpha"));
    n = stz_list_get_string(l, 2, &buf, 64);
    try std.testing.expect(std.mem.eql(u8, buf[0..n], "gamma"));

    var out: [64]u8 = undefined;
    const out_len = stz_list_to_null_delimited(l, &out, 64);
    try std.testing.expect(std.mem.eql(u8, out[0..out_len], input));
}

test "list type queries" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_string(l, "a", 1);
    _ = stz_list_append_string(l, "b", 1);
    try std.testing.expectEqual(@as(i32, 1), stz_list_is_all_strings(l));
    try std.testing.expectEqual(@as(i32, 0), stz_list_is_all_numbers(l));

    _ = stz_list_append_int(l, 1);
    try std.testing.expectEqual(@as(i32, 0), stz_list_is_all_strings(l));
}

test "list equals" {
    const a = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(a);
    const b = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(b);

    _ = stz_list_append_int(a, 1);
    _ = stz_list_append_int(a, 2);
    _ = stz_list_append_int(b, 1);
    _ = stz_list_append_int(b, 2);

    try std.testing.expectEqual(@as(i32, 1), stz_list_equals_cs(a, b, 1));
    _ = stz_list_append_int(b, 3);
    try std.testing.expectEqual(@as(i32, 0), stz_list_equals_cs(a, b, 1));
}

test "list set" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_int(l, 10);
    const v = value_mod.stz_value_new_int(99) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(v);
    _ = stz_list_set(l, 0, v);
    try std.testing.expectEqual(@as(i64, 99), stz_list_get_int(l, 0));
}

test "list item type" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_string(l, "x", 1);
    _ = stz_list_append_float(l, 3.14);

    try std.testing.expectEqual(@as(i32, 2), stz_list_item_type(l, 0)); // int
    try std.testing.expectEqual(@as(i32, 4), stz_list_item_type(l, 1)); // string
    try std.testing.expectEqual(@as(i32, 3), stz_list_item_type(l, 2)); // float
}

test "list null handles" {
    stz_list_free(null);
    try std.testing.expectEqual(@as(usize, 0), stz_list_len(null));
    try std.testing.expectEqual(@as(i32, -1), stz_list_sort(null));
    try std.testing.expectEqual(@as(i32, -1), stz_list_reverse(null));
    try std.testing.expect(stz_list_clone(null) == null);
}

// ─── Expression-based operation tests ───

test "map_expr doubles integers" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 2);
    _ = stz_list_append_int(l, 3);

    const e = "@item * 2";
    const r = stz_list_map_expr(l, e.ptr, e.len) orelse return error.AllocFailed;
    defer stz_list_free(r);

    try std.testing.expectEqual(@as(usize, 3), stz_list_len(r));
    try std.testing.expectEqual(@as(i64, 2), stz_list_get_int(r, 0));
    try std.testing.expectEqual(@as(i64, 4), stz_list_get_int(r, 1));
    try std.testing.expectEqual(@as(i64, 6), stz_list_get_int(r, 2));
}

test "map_expr with @i index" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_string(l, "a", 1);
    _ = stz_list_append_string(l, "b", 1);
    _ = stz_list_append_string(l, "c", 1);

    const e = "@i";
    const r = stz_list_map_expr(l, e.ptr, e.len) orelse return error.AllocFailed;
    defer stz_list_free(r);

    try std.testing.expectEqual(@as(i64, 1), stz_list_get_int(r, 0));
    try std.testing.expectEqual(@as(i64, 2), stz_list_get_int(r, 1));
    try std.testing.expectEqual(@as(i64, 3), stz_list_get_int(r, 2));
}

test "map_expr null list returns null" {
    const e = "@item";
    try std.testing.expect(stz_list_map_expr(null, e.ptr, e.len) == null);
}

test "filter_expr keeps even numbers" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 2);
    _ = stz_list_append_int(l, 3);
    _ = stz_list_append_int(l, 4);
    _ = stz_list_append_int(l, 5);

    const e = "@item % 2 = 0";
    const r = stz_list_filter_expr(l, e.ptr, e.len) orelse return error.AllocFailed;
    defer stz_list_free(r);

    try std.testing.expectEqual(@as(usize, 2), stz_list_len(r));
    try std.testing.expectEqual(@as(i64, 2), stz_list_get_int(r, 0));
    try std.testing.expectEqual(@as(i64, 4), stz_list_get_int(r, 1));
}

test "filter_expr with string predicate" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_string(l, "hello", 5);
    _ = stz_list_append_string(l, "hi", 2);
    _ = stz_list_append_string(l, "world", 5);

    const e = "len(@item) > 3";
    const r = stz_list_filter_expr(l, e.ptr, e.len) orelse return error.AllocFailed;
    defer stz_list_free(r);

    try std.testing.expectEqual(@as(usize, 2), stz_list_len(r));
    var buf: [32]u8 = undefined;
    var n = stz_list_get_string(r, 0, &buf, 32);
    try std.testing.expect(std.mem.eql(u8, buf[0..n], "hello"));
    n = stz_list_get_string(r, 1, &buf, 32);
    try std.testing.expect(std.mem.eql(u8, buf[0..n], "world"));
}

test "filter_expr null list returns null" {
    const e = "@item > 0";
    try std.testing.expect(stz_list_filter_expr(null, e.ptr, e.len) == null);
}

test "reduce_expr sum with init" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 2);
    _ = stz_list_append_int(l, 3);

    const init = value_mod.stz_value_new_int(0) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(init);

    const e = "@accumulator + @item";
    const r = stz_list_reduce_expr(l, e.ptr, e.len, init) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(r);

    try std.testing.expectEqual(ValueType.int_val, r.tag);
    try std.testing.expectEqual(@as(i64, 6), r.data.int_val);
}

test "reduce_expr sum without init" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_int(l, 10);
    _ = stz_list_append_int(l, 20);
    _ = stz_list_append_int(l, 30);

    const e = "@accumulator + @item";
    const r = stz_list_reduce_expr(l, e.ptr, e.len, null) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(r);

    try std.testing.expectEqual(@as(i64, 60), r.data.int_val);
}

test "reduce_expr empty list with init returns init" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    const init = value_mod.stz_value_new_int(42) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(init);

    const e = "@accumulator + @item";
    const r = stz_list_reduce_expr(l, e.ptr, e.len, init) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(r);

    try std.testing.expectEqual(@as(i64, 42), r.data.int_val);
}

test "reduce_expr null list returns null" {
    const e = "@accumulator + @item";
    try std.testing.expect(stz_list_reduce_expr(null, e.ptr, e.len, null) == null);
}

test "find_first_w first match" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_int(l, 5);
    _ = stz_list_append_int(l, 12);
    _ = stz_list_append_int(l, 3);
    _ = stz_list_append_int(l, 15);

    const e = "@item > 10";
    try std.testing.expectEqual(@as(i64, 1), stz_list_find_first_w(l, e.ptr, e.len));
}

test "find_first_w no match returns -1" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 2);

    const e = "@item > 100";
    try std.testing.expectEqual(@as(i64, -1), stz_list_find_first_w(l, e.ptr, e.len));
}

test "find_first_w null list returns -1" {
    const e = "@item > 0";
    try std.testing.expectEqual(@as(i64, -1), stz_list_find_first_w(null, e.ptr, e.len));
}

test "find_w positions" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 20);
    _ = stz_list_append_int(l, 3);
    _ = stz_list_append_int(l, 40);
    _ = stz_list_append_int(l, 5);

    const e = "@item > 10";
    var positions: [10]i64 = undefined;
    const count = stz_list_find_w(l, e.ptr, e.len, &positions, 10);
    try std.testing.expectEqual(@as(usize, 2), count);
    try std.testing.expectEqual(@as(i64, 1), positions[0]);
    try std.testing.expectEqual(@as(i64, 3), positions[1]);
}

test "find_w empty result" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_int(l, 1);

    const e = "@item > 100";
    var positions: [10]i64 = undefined;
    const count = stz_list_find_w(l, e.ptr, e.len, &positions, 10);
    try std.testing.expectEqual(@as(usize, 0), count);
}

test "count_w matching items" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 2);
    _ = stz_list_append_int(l, 3);
    _ = stz_list_append_int(l, 4);
    _ = stz_list_append_int(l, 5);

    const e = "@item > 2";
    try std.testing.expectEqual(@as(usize, 3), stz_list_count_w(l, e.ptr, e.len));
}

test "count_w with isString" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_string(l, "hello", 5);
    _ = stz_list_append_int(l, 42);
    _ = stz_list_append_string(l, "world", 5);

    const e = "isString(@item)";
    try std.testing.expectEqual(@as(usize, 2), stz_list_count_w(l, e.ptr, e.len));
}

test "count_w null list returns 0" {
    const e = "@item > 0";
    try std.testing.expectEqual(@as(usize, 0), stz_list_count_w(null, e.ptr, e.len));
}

test "sort_by_expr ascending by value" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 30);
    _ = stz_list_append_int(l, 10);
    _ = stz_list_append_int(l, 20);

    const e = "@item";
    const rc = stz_list_sort_by_expr(l, e.ptr, e.len, 1);
    try std.testing.expectEqual(@as(i32, 0), rc);

    try std.testing.expectEqual(@as(i64, 10), stz_list_get_int(l, 0));
    try std.testing.expectEqual(@as(i64, 20), stz_list_get_int(l, 1));
    try std.testing.expectEqual(@as(i64, 30), stz_list_get_int(l, 2));
}

test "sort_by_expr descending" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 10);
    _ = stz_list_append_int(l, 30);
    _ = stz_list_append_int(l, 20);

    const e = "@item";
    const rc = stz_list_sort_by_expr(l, e.ptr, e.len, 0);
    try std.testing.expectEqual(@as(i32, 0), rc);

    try std.testing.expectEqual(@as(i64, 30), stz_list_get_int(l, 0));
    try std.testing.expectEqual(@as(i64, 20), stz_list_get_int(l, 1));
    try std.testing.expectEqual(@as(i64, 10), stz_list_get_int(l, 2));
}

test "sort_by_expr by computed key" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    // Sort by negative value = reverse order
    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 3);
    _ = stz_list_append_int(l, 2);

    const e = "0 - @item";
    const rc = stz_list_sort_by_expr(l, e.ptr, e.len, 1);
    try std.testing.expectEqual(@as(i32, 0), rc);

    // ascending by (0-@item) means descending by @item
    try std.testing.expectEqual(@as(i64, 3), stz_list_get_int(l, 0));
    try std.testing.expectEqual(@as(i64, 2), stz_list_get_int(l, 1));
    try std.testing.expectEqual(@as(i64, 1), stz_list_get_int(l, 2));
}

test "sort_by_expr strings" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_string(l, "cherry", 6);
    _ = stz_list_append_string(l, "apple", 5);
    _ = stz_list_append_string(l, "banana", 6);

    const e = "@item";
    const rc = stz_list_sort_by_expr(l, e.ptr, e.len, 1);
    try std.testing.expectEqual(@as(i32, 0), rc);

    var buf: [64]u8 = undefined;
    const n0 = stz_list_get_string(l, 0, &buf, 64);
    try std.testing.expectEqualStrings("apple", buf[0..n0]);
    const n1 = stz_list_get_string(l, 1, &buf, 64);
    try std.testing.expectEqualStrings("banana", buf[0..n1]);
    const n2 = stz_list_get_string(l, 2, &buf, 64);
    try std.testing.expectEqualStrings("cherry", buf[0..n2]);
}

test "sort_by_expr single element" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 42);

    const e = "@item";
    const rc = stz_list_sort_by_expr(l, e.ptr, e.len, 1);
    try std.testing.expectEqual(@as(i32, 0), rc);
    try std.testing.expectEqual(@as(i64, 42), stz_list_get_int(l, 0));
}

test "sort_by_expr null list returns -1" {
    const e = "@item";
    try std.testing.expectEqual(@as(i32, -1), stz_list_sort_by_expr(null, e.ptr, e.len, 1));
}

// ─── Sort on column tests ───

test "sort_on column 0" {
    const l = stz_list_new().?;
    defer stz_list_free(l);

    // Row [3, "c"], [1, "a"], [2, "b"]
    const r0 = value_mod.stz_value_new_list().?;
    _ = value_mod.stz_value_list_append(r0, value_mod.stz_value_new_int(3));
    _ = value_mod.stz_value_list_append(r0, value_mod.stz_value_new_string("c", 1));
    _ = stz_list_append_value(l, r0);
    value_mod.stz_value_free(r0);

    const r1 = value_mod.stz_value_new_list().?;
    _ = value_mod.stz_value_list_append(r1, value_mod.stz_value_new_int(1));
    _ = value_mod.stz_value_list_append(r1, value_mod.stz_value_new_string("a", 1));
    _ = stz_list_append_value(l, r1);
    value_mod.stz_value_free(r1);

    const r2 = value_mod.stz_value_new_list().?;
    _ = value_mod.stz_value_list_append(r2, value_mod.stz_value_new_int(2));
    _ = value_mod.stz_value_list_append(r2, value_mod.stz_value_new_string("b", 1));
    _ = stz_list_append_value(l, r2);
    value_mod.stz_value_free(r2);

    try std.testing.expectEqual(@as(i32, 0), stz_list_sort_on(l, 0));

    // After sort on col 0: [1,"a"], [2,"b"], [3,"c"]
    const v0 = l.get(0).?;
    try std.testing.expectEqual(ValueType.list_val, v0.tag);
    try std.testing.expectEqual(@as(i64, 1), v0.data.list_val.items[0].data.int_val);

    const v1 = l.get(1).?;
    try std.testing.expectEqual(@as(i64, 2), v1.data.list_val.items[0].data.int_val);

    const v2 = l.get(2).?;
    try std.testing.expectEqual(@as(i64, 3), v2.data.list_val.items[0].data.int_val);
}

test "sort_on column 1 strings" {
    const l = stz_list_new().?;
    defer stz_list_free(l);

    const r0 = value_mod.stz_value_new_list().?;
    _ = value_mod.stz_value_list_append(r0, value_mod.stz_value_new_int(1));
    _ = value_mod.stz_value_list_append(r0, value_mod.stz_value_new_string("cherry", 6));
    _ = stz_list_append_value(l, r0);
    value_mod.stz_value_free(r0);

    const r1 = value_mod.stz_value_new_list().?;
    _ = value_mod.stz_value_list_append(r1, value_mod.stz_value_new_int(2));
    _ = value_mod.stz_value_list_append(r1, value_mod.stz_value_new_string("apple", 5));
    _ = stz_list_append_value(l, r1);
    value_mod.stz_value_free(r1);

    const r2 = value_mod.stz_value_new_list().?;
    _ = value_mod.stz_value_list_append(r2, value_mod.stz_value_new_int(3));
    _ = value_mod.stz_value_list_append(r2, value_mod.stz_value_new_string("banana", 6));
    _ = stz_list_append_value(l, r2);
    value_mod.stz_value_free(r2);

    try std.testing.expectEqual(@as(i32, 0), stz_list_sort_on(l, 1));

    // Sorted by col 1: apple < banana < cherry
    const v0 = l.get(0).?;
    try std.testing.expectEqual(@as(i64, 2), v0.data.list_val.items[0].data.int_val);
    const v1 = l.get(1).?;
    try std.testing.expectEqual(@as(i64, 3), v1.data.list_val.items[0].data.int_val);
    const v2 = l.get(2).?;
    try std.testing.expectEqual(@as(i64, 1), v2.data.list_val.items[0].data.int_val);
}

test "sort_on null list returns -1" {
    try std.testing.expectEqual(@as(i32, -1), stz_list_sort_on(null, 0));
}

test "sort_on single element returns 0" {
    const l = stz_list_new().?;
    defer stz_list_free(l);
    const r0 = value_mod.stz_value_new_list().?;
    _ = value_mod.stz_value_list_append(r0, value_mod.stz_value_new_int(42));
    _ = stz_list_append_value(l, r0);
    value_mod.stz_value_free(r0);
    try std.testing.expectEqual(@as(i32, 0), stz_list_sort_on(l, 0));
}

// ─── Is Sorted tests ───

test "is_sorted_ascending on sorted list" {
    const l = stz_list_new().?;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 2);
    _ = stz_list_append_int(l, 3);
    try std.testing.expectEqual(@as(i32, 1), stz_list_is_sorted_ascending(l));
}

test "is_sorted_ascending on unsorted list" {
    const l = stz_list_new().?;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 3);
    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 2);
    try std.testing.expectEqual(@as(i32, 0), stz_list_is_sorted_ascending(l));
}

test "is_sorted_descending on descending list" {
    const l = stz_list_new().?;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 5);
    _ = stz_list_append_int(l, 3);
    _ = stz_list_append_int(l, 1);
    try std.testing.expectEqual(@as(i32, 1), stz_list_is_sorted_descending(l));
}

test "is_sorted on empty list" {
    const l = stz_list_new().?;
    defer stz_list_free(l);
    try std.testing.expectEqual(@as(i32, 1), stz_list_is_sorted_ascending(l));
    try std.testing.expectEqual(@as(i32, 1), stz_list_is_sorted_descending(l));
}

test "is_sorted null returns 0" {
    try std.testing.expectEqual(@as(i32, 0), stz_list_is_sorted_ascending(null));
    try std.testing.expectEqual(@as(i32, 0), stz_list_is_sorted_descending(null));
}

// ─── Repeat tests ───

test "repeat list 3 times" {
    const l = stz_list_new().?;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 2);
    const r = stz_list_repeat(l, 3).?;
    defer stz_list_free(r);
    try std.testing.expectEqual(@as(usize, 6), stz_list_len(r));
    try std.testing.expectEqual(@as(i64, 1), stz_list_get_int(r, 0));
    try std.testing.expectEqual(@as(i64, 2), stz_list_get_int(r, 1));
    try std.testing.expectEqual(@as(i64, 1), stz_list_get_int(r, 2));
}

test "repeat 0 times returns empty" {
    const l = stz_list_new().?;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 1);
    const r = stz_list_repeat(l, 0).?;
    defer stz_list_free(r);
    try std.testing.expectEqual(@as(usize, 0), stz_list_len(r));
}

// ─── Shuffle tests ───

test "shuffle preserves length" {
    const l = stz_list_new().?;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 2);
    _ = stz_list_append_int(l, 3);
    _ = stz_list_append_int(l, 4);
    _ = stz_list_append_int(l, 5);
    try std.testing.expectEqual(@as(i32, 0), stz_list_shuffle(l));
    try std.testing.expectEqual(@as(usize, 5), stz_list_len(l));
}

test "shuffle null returns -1" {
    try std.testing.expectEqual(@as(i32, -1), stz_list_shuffle(null));
}

test "shuffle single element" {
    const l = stz_list_new().?;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 42);
    try std.testing.expectEqual(@as(i32, 0), stz_list_shuffle(l));
    try std.testing.expectEqual(@as(i64, 42), stz_list_get_int(l, 0));
}

// ─── Random pick tests ───

test "random_item from list" {
    const l = stz_list_new().?;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 10);
    _ = stz_list_append_int(l, 20);
    _ = stz_list_append_int(l, 30);
    const v = stz_list_random_item(l);
    try std.testing.expect(v != null);
}

test "random_item null returns null" {
    try std.testing.expectEqual(@as(?*const StzValue, null), stz_list_random_item(null));
}

test "random_items picks correct count" {
    const l = stz_list_new().?;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 2);
    _ = stz_list_append_int(l, 3);
    _ = stz_list_append_int(l, 4);
    _ = stz_list_append_int(l, 5);
    const picked = stz_list_random_items(l, 3).?;
    defer stz_list_free(picked);
    try std.testing.expectEqual(@as(usize, 3), stz_list_len(picked));
}

test "random_items capped at list size" {
    const l = stz_list_new().?;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 2);
    const picked = stz_list_random_items(l, 10).?;
    defer stz_list_free(picked);
    try std.testing.expectEqual(@as(usize, 2), stz_list_len(picked));
}

// ─── Trim tests ───

test "trim_leading removes matching items" {
    const l = stz_list_new().?;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 0);
    _ = stz_list_append_int(l, 0);
    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 2);
    _ = stz_list_append_int(l, 0);
    const zero = value_mod.stz_value_new_int(0);
    defer value_mod.stz_value_free(zero);
    try std.testing.expectEqual(@as(i32, 0), stz_list_trim_leading(l, zero));
    try std.testing.expectEqual(@as(usize, 3), stz_list_len(l));
    try std.testing.expectEqual(@as(i64, 1), stz_list_get_int(l, 0));
}

test "trim_trailing removes matching items" {
    const l = stz_list_new().?;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 2);
    _ = stz_list_append_int(l, 0);
    _ = stz_list_append_int(l, 0);
    const zero = value_mod.stz_value_new_int(0);
    defer value_mod.stz_value_free(zero);
    try std.testing.expectEqual(@as(i32, 0), stz_list_trim_trailing(l, zero));
    try std.testing.expectEqual(@as(usize, 2), stz_list_len(l));
}

test "trim removes both ends" {
    const l = stz_list_new().?;
    defer stz_list_free(l);
    const s = value_mod.stz_value_new_string("", 0);
    defer value_mod.stz_value_free(s);
    _ = stz_list_append_value(l, s);
    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 2);
    _ = stz_list_append_value(l, s);
    _ = stz_list_append_value(l, s);
    try std.testing.expectEqual(@as(i32, 0), stz_list_trim(l, s));
    try std.testing.expectEqual(@as(usize, 2), stz_list_len(l));
}

// ─── Section tests ───

test "section extracts range" {
    const l = stz_list_new().?;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 10);
    _ = stz_list_append_int(l, 20);
    _ = stz_list_append_int(l, 30);
    _ = stz_list_append_int(l, 40);
    _ = stz_list_append_int(l, 50);
    const sec = stz_list_section(l, 1, 3).?;
    defer stz_list_free(sec);
    try std.testing.expectEqual(@as(usize, 3), stz_list_len(sec));
    try std.testing.expectEqual(@as(i64, 20), stz_list_get_int(sec, 0));
    try std.testing.expectEqual(@as(i64, 40), stz_list_get_int(sec, 2));
}

test "section null returns null" {
    try std.testing.expectEqual(@as(?*StzList, null), stz_list_section(null, 0, 1));
}

// ─── Swap tests ───

test "swap exchanges items" {
    const l = stz_list_new().?;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 10);
    _ = stz_list_append_int(l, 20);
    _ = stz_list_append_int(l, 30);
    try std.testing.expectEqual(@as(i32, 0), stz_list_swap(l, 0, 2));
    try std.testing.expectEqual(@as(i64, 30), stz_list_get_int(l, 0));
    try std.testing.expectEqual(@as(i64, 10), stz_list_get_int(l, 2));
}

test "swap null returns -1" {
    try std.testing.expectEqual(@as(i32, -1), stz_list_swap(null, 0, 1));
}

test "swap out of bounds returns -1" {
    const l = stz_list_new().?;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 1);
    try std.testing.expectEqual(@as(i32, -1), stz_list_swap(l, 0, 5));
}

// ─── String expression tests ───

test "string_find_chars_w vowels" {
    const str = "hello";
    const e = "@char = \"e\" or @char = \"o\"";
    var buf: [256]u8 = undefined;
    const n = stz_string_find_chars_w(str.ptr, str.len, e.ptr, e.len, &buf, 256);
    try std.testing.expectEqualStrings("2,5", buf[0..n]);
}

test "string_find_chars_w no match" {
    const str = "abc";
    const e = "@char = \"z\"";
    var buf: [256]u8 = undefined;
    const n = stz_string_find_chars_w(str.ptr, str.len, e.ptr, e.len, &buf, 256);
    try std.testing.expectEqual(@as(usize, 0), n);
}

test "string_find_chars_w by index" {
    const str = "abcde";
    const e = "@i > 3";
    var buf: [256]u8 = undefined;
    const n = stz_string_find_chars_w(str.ptr, str.len, e.ptr, e.len, &buf, 256);
    try std.testing.expectEqualStrings("4,5", buf[0..n]);
}

test "string_map_chars identity" {
    const str = "abc";
    const e = "@char";
    const result = stz_string_map_chars(str.ptr, str.len, e.ptr, e.len) orelse return error.AllocFailed;
    defer stz_list_free(result);

    try std.testing.expectEqual(@as(usize, 3), stz_list_len(result));
    var buf: [64]u8 = undefined;
    const n0 = stz_list_get_string(result, 0, &buf, 64);
    try std.testing.expectEqualStrings("a", buf[0..n0]);
    const n2 = stz_list_get_string(result, 2, &buf, 64);
    try std.testing.expectEqualStrings("c", buf[0..n2]);
}

test "string_map_chars index" {
    const str = "ab";
    const e = "@i";
    const result = stz_string_map_chars(str.ptr, str.len, e.ptr, e.len) orelse return error.AllocFailed;
    defer stz_list_free(result);

    try std.testing.expectEqual(@as(usize, 2), stz_list_len(result));
    try std.testing.expectEqual(@as(i64, 1), stz_list_get_int(result, 0));
    try std.testing.expectEqual(@as(i64, 2), stz_list_get_int(result, 1));
}

test "string_count_chars_w" {
    const str = "hello world";
    const e = "@char = \"l\"";
    try std.testing.expectEqual(@as(usize, 3), stz_string_count_chars_w(str.ptr, str.len, e.ptr, e.len));
}

test "string_count_chars_w empty" {
    const str = "";
    const e = "@char = \"a\"";
    try std.testing.expectEqual(@as(usize, 0), stz_string_count_chars_w(str.ptr, str.len, e.ptr, e.len));
}

// ─── Duplicate analysis tests ───

test "find_duplicates_cs basic" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_string(l, "a", 1);
    _ = stz_list_append_string(l, "b", 1);
    _ = stz_list_append_string(l, "a", 1);
    _ = stz_list_append_string(l, "c", 1);
    _ = stz_list_append_string(l, "b", 1);

    const r = stz_list_find_duplicates_cs(l, 1) orelse return error.AllocFailed;
    defer stz_list_free(r);
    try std.testing.expectEqual(@as(usize, 2), stz_list_len(r));
    try std.testing.expectEqual(@as(i64, 2), stz_list_get_int(r, 0)); // "a" at index 2
    try std.testing.expectEqual(@as(i64, 4), stz_list_get_int(r, 1)); // "b" at index 4
}

test "find_duplicates_cs case insensitive" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_string(l, "Hello", 5);
    _ = stz_list_append_string(l, "hello", 5);
    _ = stz_list_append_string(l, "world", 5);

    const r = stz_list_find_duplicates_cs(l, 0) orelse return error.AllocFailed;
    defer stz_list_free(r);
    try std.testing.expectEqual(@as(usize, 1), stz_list_len(r));
    try std.testing.expectEqual(@as(i64, 1), stz_list_get_int(r, 0)); // "hello" at index 1
}

test "find_duplicates_cs no duplicates" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 2);
    _ = stz_list_append_int(l, 3);

    const r = stz_list_find_duplicates_cs(l, 1) orelse return error.AllocFailed;
    defer stz_list_free(r);
    try std.testing.expectEqual(@as(usize, 0), stz_list_len(r));
}

test "find_non_duplicated_cs basic" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_string(l, "a", 1);
    _ = stz_list_append_string(l, "b", 1);
    _ = stz_list_append_string(l, "a", 1);
    _ = stz_list_append_string(l, "c", 1);

    const r = stz_list_find_non_duplicated_cs(l, 1) orelse return error.AllocFailed;
    defer stz_list_free(r);
    try std.testing.expectEqual(@as(usize, 2), stz_list_len(r));
    try std.testing.expectEqual(@as(i64, 1), stz_list_get_int(r, 0)); // "b" at index 1
    try std.testing.expectEqual(@as(i64, 3), stz_list_get_int(r, 1)); // "c" at index 3
}

test "find_non_duplicated_cs all unique" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_int(l, 10);
    _ = stz_list_append_int(l, 20);
    _ = stz_list_append_int(l, 30);

    const r = stz_list_find_non_duplicated_cs(l, 1) orelse return error.AllocFailed;
    defer stz_list_free(r);
    try std.testing.expectEqual(@as(usize, 3), stz_list_len(r));
}

test "all_unique_cs true" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 2);
    _ = stz_list_append_int(l, 3);

    try std.testing.expectEqual(@as(i32, 1), stz_list_all_unique_cs(l, 1));
}

test "all_unique_cs false" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 2);
    _ = stz_list_append_int(l, 1);

    try std.testing.expectEqual(@as(i32, 0), stz_list_all_unique_cs(l, 1));
}

test "all_unique_cs case insensitive" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_string(l, "Hello", 5);
    _ = stz_list_append_string(l, "hello", 5);

    try std.testing.expectEqual(@as(i32, 1), stz_list_all_unique_cs(l, 1)); // CS: different
    try std.testing.expectEqual(@as(i32, 0), stz_list_all_unique_cs(l, 0)); // CI: same
}

test "all_unique_cs null returns 1" {
    try std.testing.expectEqual(@as(i32, 1), stz_list_all_unique_cs(null, 1));
}

test "all_unique_cs empty returns 1" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    try std.testing.expectEqual(@as(i32, 1), stz_list_all_unique_cs(l, 1));
}

// ─── Set operation tests ───

test "intersection_cs basic" {
    const a = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(a);
    const b = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(b);

    _ = stz_list_append_int(a, 1);
    _ = stz_list_append_int(a, 2);
    _ = stz_list_append_int(a, 3);
    _ = stz_list_append_int(b, 2);
    _ = stz_list_append_int(b, 3);
    _ = stz_list_append_int(b, 4);

    const r = stz_list_intersection_cs(a, b, 1) orelse return error.AllocFailed;
    defer stz_list_free(r);
    try std.testing.expectEqual(@as(usize, 2), stz_list_len(r));
    try std.testing.expectEqual(@as(i64, 2), stz_list_get_int(r, 0));
    try std.testing.expectEqual(@as(i64, 3), stz_list_get_int(r, 1));
}

test "intersection_cs no overlap" {
    const a = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(a);
    const b = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(b);

    _ = stz_list_append_int(a, 1);
    _ = stz_list_append_int(b, 2);

    const r = stz_list_intersection_cs(a, b, 1) orelse return error.AllocFailed;
    defer stz_list_free(r);
    try std.testing.expectEqual(@as(usize, 0), stz_list_len(r));
}

test "intersection_cs case insensitive strings" {
    const a = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(a);
    const b = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(b);

    _ = stz_list_append_string(a, "Hello", 5);
    _ = stz_list_append_string(a, "World", 5);
    _ = stz_list_append_string(b, "hello", 5);
    _ = stz_list_append_string(b, "other", 5);

    const r = stz_list_intersection_cs(a, b, 0) orelse return error.AllocFailed;
    defer stz_list_free(r);
    try std.testing.expectEqual(@as(usize, 1), stz_list_len(r));
}

test "union_cs basic" {
    const a = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(a);
    const b = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(b);

    _ = stz_list_append_int(a, 1);
    _ = stz_list_append_int(a, 2);
    _ = stz_list_append_int(b, 2);
    _ = stz_list_append_int(b, 3);

    const r = stz_list_union_cs(a, b, 1) orelse return error.AllocFailed;
    defer stz_list_free(r);
    try std.testing.expectEqual(@as(usize, 3), stz_list_len(r));
}

test "difference_cs basic" {
    const a = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(a);
    const b = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(b);

    _ = stz_list_append_int(a, 1);
    _ = stz_list_append_int(a, 2);
    _ = stz_list_append_int(a, 3);
    _ = stz_list_append_int(b, 2);

    const r = stz_list_difference_cs(a, b, 1) orelse return error.AllocFailed;
    defer stz_list_free(r);
    try std.testing.expectEqual(@as(usize, 2), stz_list_len(r));
    try std.testing.expectEqual(@as(i64, 1), stz_list_get_int(r, 0));
    try std.testing.expectEqual(@as(i64, 3), stz_list_get_int(r, 1));
}

test "is_subset_cs true" {
    const a = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(a);
    const b = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(b);

    _ = stz_list_append_int(a, 1);
    _ = stz_list_append_int(a, 2);
    _ = stz_list_append_int(b, 1);
    _ = stz_list_append_int(b, 2);
    _ = stz_list_append_int(b, 3);

    try std.testing.expectEqual(@as(i32, 1), stz_list_is_subset_cs(a, b, 1));
}

test "is_subset_cs false" {
    const a = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(a);
    const b = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(b);

    _ = stz_list_append_int(a, 1);
    _ = stz_list_append_int(a, 4);
    _ = stz_list_append_int(b, 1);
    _ = stz_list_append_int(b, 2);

    try std.testing.expectEqual(@as(i32, 0), stz_list_is_subset_cs(a, b, 1));
}

test "is_subset_cs empty is subset" {
    const a = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(a);
    const b = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(b);

    _ = stz_list_append_int(b, 1);

    try std.testing.expectEqual(@as(i32, 1), stz_list_is_subset_cs(a, b, 1));
}

// ─── Classify / Frequencies tests ───

test "classify_cs basic" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_string(l, "a", 1);
    _ = stz_list_append_string(l, "b", 1);
    _ = stz_list_append_string(l, "a", 1);
    _ = stz_list_append_string(l, "c", 1);
    _ = stz_list_append_string(l, "b", 1);

    const r = stz_list_classify_cs(l, 1) orelse return error.AllocFailed;
    defer stz_list_free(r);
    // Result is now a list of nested [ keyString, [positions] ] PAIRS, so the
    // length equals the number of distinct groups (a, b, c -> 3).
    try std.testing.expectEqual(@as(usize, 3), stz_list_len(r));
}

test "classify_cs case insensitive" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_string(l, "Hello", 5);
    _ = stz_list_append_string(l, "hello", 5);
    _ = stz_list_append_string(l, "World", 5);

    const r = stz_list_classify_cs(l, 0) orelse return error.AllocFailed;
    defer stz_list_free(r);
    // 2 groups (nested pairs): {Hello,hello} and {World}
    try std.testing.expectEqual(@as(usize, 2), stz_list_len(r));
}

test "classify_cs integers" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 2);
    _ = stz_list_append_int(l, 1);

    const r = stz_list_classify_cs(l, 1) orelse return error.AllocFailed;
    defer stz_list_free(r);
    // 2 groups (nested pairs): {1 at 1,3} and {2 at 2}
    try std.testing.expectEqual(@as(usize, 2), stz_list_len(r));
}

test "classify_cs empty" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    const r = stz_list_classify_cs(l, 1) orelse return error.AllocFailed;
    defer stz_list_free(r);
    try std.testing.expectEqual(@as(usize, 0), stz_list_len(r));
}

test "frequencies_cs basic" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_string(l, "a", 1);
    _ = stz_list_append_string(l, "b", 1);
    _ = stz_list_append_string(l, "a", 1);
    _ = stz_list_append_string(l, "c", 1);
    _ = stz_list_append_string(l, "a", 1);

    const r = stz_list_frequencies_cs(l, 1) orelse return error.AllocFailed;
    defer stz_list_free(r);
    // 3 groups * 2 entries = 6
    try std.testing.expectEqual(@as(usize, 6), stz_list_len(r));

    var buf: [256]u8 = undefined;
    // "a" => 3
    var n = stz_list_get_string(r, 0, &buf, 256);
    try std.testing.expectEqualStrings("a", buf[0..n]);
    try std.testing.expectEqual(@as(i64, 3), stz_list_get_int(r, 1));

    // "b" => 1
    n = stz_list_get_string(r, 2, &buf, 256);
    try std.testing.expectEqualStrings("b", buf[0..n]);
    try std.testing.expectEqual(@as(i64, 1), stz_list_get_int(r, 3));

    // "c" => 1
    n = stz_list_get_string(r, 4, &buf, 256);
    try std.testing.expectEqualStrings("c", buf[0..n]);
    try std.testing.expectEqual(@as(i64, 1), stz_list_get_int(r, 5));
}

test "frequencies_cs case insensitive" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_string(l, "Hello", 5);
    _ = stz_list_append_string(l, "hello", 5);
    _ = stz_list_append_string(l, "HELLO", 5);

    const r = stz_list_frequencies_cs(l, 0) orelse return error.AllocFailed;
    defer stz_list_free(r);
    // 1 group
    try std.testing.expectEqual(@as(usize, 2), stz_list_len(r));
    try std.testing.expectEqual(@as(i64, 3), stz_list_get_int(r, 1));
}

test "frequencies_cs null returns null" {
    try std.testing.expect(stz_list_frequencies_cs(null, 1) == null);
}

// ─── Zip / Interleave / Partition tests ───

test "zip basic" {
    const a = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(a);
    const b = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(b);

    _ = stz_list_append_int(a, 1);
    _ = stz_list_append_int(a, 2);
    _ = stz_list_append_int(a, 3);
    _ = stz_list_append_string(b, "a", 1);
    _ = stz_list_append_string(b, "b", 1);
    _ = stz_list_append_string(b, "c", 1);

    const r = stz_list_zip(a, b) orelse return error.AllocFailed;
    defer stz_list_free(r);
    try std.testing.expectEqual(@as(usize, 3), stz_list_len(r));
}

test "zip unequal lengths" {
    const a = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(a);
    const b = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(b);

    _ = stz_list_append_int(a, 1);
    _ = stz_list_append_int(a, 2);
    _ = stz_list_append_int(a, 3);
    _ = stz_list_append_string(b, "x", 1);

    const r = stz_list_zip(a, b) orelse return error.AllocFailed;
    defer stz_list_free(r);
    try std.testing.expectEqual(@as(usize, 1), stz_list_len(r));
}

test "zip null returns null" {
    const a = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(a);
    try std.testing.expect(stz_list_zip(a, null) == null);
    try std.testing.expect(stz_list_zip(null, a) == null);
}

test "interleave basic" {
    const a = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(a);
    const b = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(b);

    _ = stz_list_append_int(a, 1);
    _ = stz_list_append_int(a, 3);
    _ = stz_list_append_int(a, 5);
    _ = stz_list_append_int(b, 2);
    _ = stz_list_append_int(b, 4);
    _ = stz_list_append_int(b, 6);

    const r = stz_list_interleave(a, b) orelse return error.AllocFailed;
    defer stz_list_free(r);
    try std.testing.expectEqual(@as(usize, 6), stz_list_len(r));
    try std.testing.expectEqual(@as(i64, 1), stz_list_get_int(r, 0));
    try std.testing.expectEqual(@as(i64, 2), stz_list_get_int(r, 1));
    try std.testing.expectEqual(@as(i64, 3), stz_list_get_int(r, 2));
    try std.testing.expectEqual(@as(i64, 4), stz_list_get_int(r, 3));
    try std.testing.expectEqual(@as(i64, 5), stz_list_get_int(r, 4));
    try std.testing.expectEqual(@as(i64, 6), stz_list_get_int(r, 5));
}

test "interleave unequal lengths" {
    const a = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(a);
    const b = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(b);

    _ = stz_list_append_int(a, 1);
    _ = stz_list_append_int(a, 3);
    _ = stz_list_append_int(b, 2);

    const r = stz_list_interleave(a, b) orelse return error.AllocFailed;
    defer stz_list_free(r);
    try std.testing.expectEqual(@as(usize, 3), stz_list_len(r));
    try std.testing.expectEqual(@as(i64, 1), stz_list_get_int(r, 0));
    try std.testing.expectEqual(@as(i64, 2), stz_list_get_int(r, 1));
    try std.testing.expectEqual(@as(i64, 3), stz_list_get_int(r, 2));
}

test "partition into 3 groups" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    for (1..8) |n| _ = stz_list_append_int(l, @intCast(n));

    const r = stz_list_partition(l, 3) orelse return error.AllocFailed;
    defer stz_list_free(r);
    try std.testing.expectEqual(@as(usize, 3), stz_list_len(r));
}

test "partition into 1 group" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 2);

    const r = stz_list_partition(l, 1) orelse return error.AllocFailed;
    defer stz_list_free(r);
    try std.testing.expectEqual(@as(usize, 1), stz_list_len(r));
}

test "partition more groups than items" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 2);

    const r = stz_list_partition(l, 5) orelse return error.AllocFailed;
    defer stz_list_free(r);
    try std.testing.expectEqual(@as(usize, 2), stz_list_len(r));
}

test "partition null returns null" {
    try std.testing.expect(stz_list_partition(null, 3) == null);
}

test "partition zero returns null" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    try std.testing.expect(stz_list_partition(l, 0) == null);
}

test "rotate left basic" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 2);
    _ = stz_list_append_int(l, 3);
    _ = stz_list_append_int(l, 4);
    _ = stz_list_append_int(l, 5);
    try std.testing.expectEqual(@as(i32, 0), stz_list_rotate_left(l, 2));
    try std.testing.expectEqual(@as(i64, 3), stz_list_get_int(l, 0));
    try std.testing.expectEqual(@as(i64, 4), stz_list_get_int(l, 1));
    try std.testing.expectEqual(@as(i64, 5), stz_list_get_int(l, 2));
    try std.testing.expectEqual(@as(i64, 1), stz_list_get_int(l, 3));
    try std.testing.expectEqual(@as(i64, 2), stz_list_get_int(l, 4));
}

test "rotate right basic" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 2);
    _ = stz_list_append_int(l, 3);
    _ = stz_list_append_int(l, 4);
    _ = stz_list_append_int(l, 5);
    try std.testing.expectEqual(@as(i32, 0), stz_list_rotate_right(l, 2));
    try std.testing.expectEqual(@as(i64, 4), stz_list_get_int(l, 0));
    try std.testing.expectEqual(@as(i64, 5), stz_list_get_int(l, 1));
    try std.testing.expectEqual(@as(i64, 1), stz_list_get_int(l, 2));
    try std.testing.expectEqual(@as(i64, 2), stz_list_get_int(l, 3));
    try std.testing.expectEqual(@as(i64, 3), stz_list_get_int(l, 4));
}

test "rotate wraps around" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 10);
    _ = stz_list_append_int(l, 20);
    _ = stz_list_append_int(l, 30);
    try std.testing.expectEqual(@as(i32, 0), stz_list_rotate_left(l, 5));
    try std.testing.expectEqual(@as(i64, 30), stz_list_get_int(l, 0));
    try std.testing.expectEqual(@as(i64, 10), stz_list_get_int(l, 1));
    try std.testing.expectEqual(@as(i64, 20), stz_list_get_int(l, 2));
}

test "chunked basic" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    for (1..8) |i| { _ = stz_list_append_int(l, @intCast(i)); }
    const result = stz_list_chunked(l, 3) orelse return error.AllocFailed;
    defer stz_list_free(result);
    try std.testing.expectEqual(@as(usize, 3), result.len());
    const c0 = stz_list_get_sublist(result, 0) orelse return error.AllocFailed;
    defer stz_list_free(c0);
    try std.testing.expectEqual(@as(usize, 3), c0.len());
    try std.testing.expectEqual(@as(i64, 1), stz_list_get_int(c0, 0));
    const c2 = stz_list_get_sublist(result, 2) orelse return error.AllocFailed;
    defer stz_list_free(c2);
    try std.testing.expectEqual(@as(usize, 1), c2.len());
    try std.testing.expectEqual(@as(i64, 7), stz_list_get_int(c2, 0));
}

test "paired basic" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    for (1..6) |i| { _ = stz_list_append_int(l, @intCast(i)); }
    const result = stz_list_paired(l) orelse return error.AllocFailed;
    defer stz_list_free(result);
    try std.testing.expectEqual(@as(usize, 3), result.len());
    const p0 = stz_list_get_sublist(result, 0) orelse return error.AllocFailed;
    defer stz_list_free(p0);
    try std.testing.expectEqual(@as(usize, 2), p0.len());
    try std.testing.expectEqual(@as(i64, 1), stz_list_get_int(p0, 0));
    try std.testing.expectEqual(@as(i64, 2), stz_list_get_int(p0, 1));
}

test "sliding window basic" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    for (1..6) |i| { _ = stz_list_append_int(l, @intCast(i)); }
    const result = stz_list_sliding_window(l, 3) orelse return error.AllocFailed;
    defer stz_list_free(result);
    // [1,2,3,4,5] windows of 3 => [[1,2,3],[2,3,4],[3,4,5]]
    try std.testing.expectEqual(@as(usize, 3), result.len());
    const w0 = stz_list_get_sublist(result, 0) orelse return error.AllocFailed;
    defer stz_list_free(w0);
    try std.testing.expectEqual(@as(usize, 3), w0.len());
    try std.testing.expectEqual(@as(i64, 1), stz_list_get_int(w0, 0));
    try std.testing.expectEqual(@as(i64, 3), stz_list_get_int(w0, 2));
    const w2 = stz_list_get_sublist(result, 2) orelse return error.AllocFailed;
    defer stz_list_free(w2);
    try std.testing.expectEqual(@as(i64, 3), stz_list_get_int(w2, 0));
    try std.testing.expectEqual(@as(i64, 5), stz_list_get_int(w2, 2));
}

test "sliding window size equals list" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    for (1..4) |i| { _ = stz_list_append_int(l, @intCast(i)); }
    const result = stz_list_sliding_window(l, 3) orelse return error.AllocFailed;
    defer stz_list_free(result);
    try std.testing.expectEqual(@as(usize, 1), result.len());
}

test "anti sections basic" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    for (1..11) |i| { _ = stz_list_append_int(l, @intCast(i)); }
    // sections: [2,4] (0-based) => items 3,4,5 covered
    // anti-sections: [0,1] and [5,9]
    const secs = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(secs);
    const pair = value_mod.stz_value_new_list() orelse return error.AllocFailed;
    const v1 = value_mod.stz_value_new_int(2) orelse return error.AllocFailed;
    _ = value_mod.stz_value_list_append(pair, v1);
    value_mod.stz_value_free(v1);
    const v2 = value_mod.stz_value_new_int(4) orelse return error.AllocFailed;
    _ = value_mod.stz_value_list_append(pair, v2);
    value_mod.stz_value_free(v2);
    _ = stz_list_append_value(secs, pair);
    value_mod.stz_value_free(pair);

    const result = stz_list_anti_sections(l, secs) orelse return error.AllocFailed;
    defer stz_list_free(result);
    // Should be 2 anti-sections: [0,1] and [5,9]
    try std.testing.expectEqual(@as(usize, 2), result.len());
    const as0 = stz_list_get_sublist(result, 0) orelse return error.AllocFailed;
    defer stz_list_free(as0);
    try std.testing.expectEqual(@as(i64, 0), stz_list_get_int(as0, 0));
    try std.testing.expectEqual(@as(i64, 1), stz_list_get_int(as0, 1));
    const as1 = stz_list_get_sublist(result, 1) orelse return error.AllocFailed;
    defer stz_list_free(as1);
    try std.testing.expectEqual(@as(i64, 5), stz_list_get_int(as1, 0));
    try std.testing.expectEqual(@as(i64, 9), stz_list_get_int(as1, 1));
}

test "starts with list" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    for (1..6) |i| { _ = stz_list_append_int(l, @intCast(i)); }
    const prefix = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(prefix);
    _ = stz_list_append_int(prefix, 1);
    _ = stz_list_append_int(prefix, 2);
    try std.testing.expectEqual(@as(i32, 1), stz_list_starts_with_list_cs(l, prefix, 1));
    _ = stz_list_clear(prefix);
    _ = stz_list_append_int(prefix, 2);
    _ = stz_list_append_int(prefix, 3);
    try std.testing.expectEqual(@as(i32, 0), stz_list_starts_with_list_cs(l, prefix, 1));
}

test "ends with list" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    for (1..6) |i| { _ = stz_list_append_int(l, @intCast(i)); }
    const suffix = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(suffix);
    _ = stz_list_append_int(suffix, 4);
    _ = stz_list_append_int(suffix, 5);
    try std.testing.expectEqual(@as(i32, 1), stz_list_ends_with_list_cs(l, suffix, 1));
    _ = stz_list_clear(suffix);
    _ = stz_list_append_int(suffix, 3);
    _ = stz_list_append_int(suffix, 4);
    try std.testing.expectEqual(@as(i32, 0), stz_list_ends_with_list_cs(l, suffix, 1));
}

test "deep flatten nested" {
    const inner_val = value_mod.stz_value_new_list() orelse return error.AllocFailed;
    defer value_mod.stz_value_free(inner_val);
    _ = value_mod.stz_value_list_append(inner_val, value_mod.stz_value_new_int(3) orelse return error.AllocFailed);

    const mid_val = value_mod.stz_value_new_list() orelse return error.AllocFailed;
    defer value_mod.stz_value_free(mid_val);
    _ = value_mod.stz_value_list_append(mid_val, value_mod.stz_value_new_int(2) orelse return error.AllocFailed);
    _ = value_mod.stz_value_list_append(mid_val, inner_val);

    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_value(l, mid_val);
    _ = stz_list_append_int(l, 4);

    const flat = stz_list_deep_flatten(l) orelse return error.AllocFailed;
    defer stz_list_free(flat);
    try std.testing.expectEqual(@as(usize, 4), flat.len());
    try std.testing.expectEqual(@as(i64, 1), stz_list_get_int(flat, 0));
    try std.testing.expectEqual(@as(i64, 2), stz_list_get_int(flat, 1));
    try std.testing.expectEqual(@as(i64, 3), stz_list_get_int(flat, 2));
    try std.testing.expectEqual(@as(i64, 4), stz_list_get_int(flat, 3));
}

test "flatten to depth 1" {
    const inner_val = value_mod.stz_value_new_list() orelse return error.AllocFailed;
    defer value_mod.stz_value_free(inner_val);
    _ = value_mod.stz_value_list_append(inner_val, value_mod.stz_value_new_int(3) orelse return error.AllocFailed);

    const mid_val = value_mod.stz_value_new_list() orelse return error.AllocFailed;
    defer value_mod.stz_value_free(mid_val);
    _ = value_mod.stz_value_list_append(mid_val, value_mod.stz_value_new_int(2) orelse return error.AllocFailed);
    _ = value_mod.stz_value_list_append(mid_val, inner_val);

    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_value(l, mid_val);
    _ = stz_list_append_int(l, 4);

    const flat = stz_list_flatten_to_depth(l, 1) orelse return error.AllocFailed;
    defer stz_list_free(flat);
    try std.testing.expectEqual(@as(usize, 4), flat.len());
    try std.testing.expectEqual(@as(i64, 1), stz_list_get_int(flat, 0));
    try std.testing.expectEqual(@as(i64, 2), stz_list_get_int(flat, 1));
    const sub = stz_list_get_sublist(flat, 2) orelse return error.AllocFailed;
    defer stz_list_free(sub);
    try std.testing.expectEqual(@as(usize, 1), sub.len());
    try std.testing.expectEqual(@as(i64, 3), stz_list_get_int(sub, 0));
    try std.testing.expectEqual(@as(i64, 4), stz_list_get_int(flat, 3));
}

test "remove_cs removes all matching items" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_string(l, "x", 1);
    _ = stz_list_append_string(l, "a", 1);
    _ = stz_list_append_string(l, "x", 1);
    _ = stz_list_append_string(l, "b", 1);
    _ = stz_list_append_string(l, "x", 1);

    const needle = value_mod.stz_value_new_string("x", 1) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(needle);

    const removed = stz_list_remove_cs(l, needle, 1);
    try std.testing.expectEqual(@as(i32, 3), removed);
    try std.testing.expectEqual(@as(usize, 2), stz_list_len(l));
    var buf: [64]u8 = undefined;
    var n = stz_list_get_string(l, 0, &buf, 64);
    try std.testing.expect(std.mem.eql(u8, buf[0..n], "a"));
    n = stz_list_get_string(l, 1, &buf, 64);
    try std.testing.expect(std.mem.eql(u8, buf[0..n], "b"));
}

test "remove_cs no match returns 0" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_string(l, "a", 1);
    _ = stz_list_append_string(l, "b", 1);

    const needle = value_mod.stz_value_new_string("z", 1) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(needle);

    const removed = stz_list_remove_cs(l, needle, 1);
    try std.testing.expectEqual(@as(i32, 0), removed);
    try std.testing.expectEqual(@as(usize, 2), stz_list_len(l));
}

test "replace_cs replaces all matching items" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_string(l, "old", 3);
    _ = stz_list_append_string(l, "keep", 4);
    _ = stz_list_append_string(l, "old", 3);

    const old_v = value_mod.stz_value_new_string("old", 3) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(old_v);
    const new_v = value_mod.stz_value_new_string("new", 3) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(new_v);

    const replaced = stz_list_replace_cs(l, old_v, new_v, 1);
    try std.testing.expectEqual(@as(i32, 2), replaced);
    try std.testing.expectEqual(@as(usize, 3), stz_list_len(l));
    var buf: [64]u8 = undefined;
    var n = stz_list_get_string(l, 0, &buf, 64);
    try std.testing.expect(std.mem.eql(u8, buf[0..n], "new"));
    n = stz_list_get_string(l, 1, &buf, 64);
    try std.testing.expect(std.mem.eql(u8, buf[0..n], "keep"));
    n = stz_list_get_string(l, 2, &buf, 64);
    try std.testing.expect(std.mem.eql(u8, buf[0..n], "new"));
}

test "replace_cs case insensitive" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_string(l, "Hello", 5);
    _ = stz_list_append_string(l, "world", 5);
    _ = stz_list_append_string(l, "HELLO", 5);

    const old_v = value_mod.stz_value_new_string("hello", 5) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(old_v);
    const new_v = value_mod.stz_value_new_string("hi", 2) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(new_v);

    const replaced = stz_list_replace_cs(l, old_v, new_v, 0);
    try std.testing.expectEqual(@as(i32, 2), replaced);
    var buf: [64]u8 = undefined;
    var n = stz_list_get_string(l, 0, &buf, 64);
    try std.testing.expect(std.mem.eql(u8, buf[0..n], "hi"));
    n = stz_list_get_string(l, 1, &buf, 64);
    try std.testing.expect(std.mem.eql(u8, buf[0..n], "world"));
    n = stz_list_get_string(l, 2, &buf, 64);
    try std.testing.expect(std.mem.eql(u8, buf[0..n], "hi"));
}

// ─── Leading / Trailing tests ───

test "leading_count_cs with repeated leading" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_string(l, "a", 1);
    _ = stz_list_append_string(l, "a", 1);
    _ = stz_list_append_string(l, "a", 1);
    _ = stz_list_append_string(l, "b", 1);
    _ = stz_list_append_string(l, "c", 1);
    try std.testing.expectEqual(@as(i64, 3), stz_list_leading_count_cs(l, 1));
}

test "leading_count_cs no repeat" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_string(l, "a", 1);
    _ = stz_list_append_string(l, "b", 1);
    try std.testing.expectEqual(@as(i64, 0), stz_list_leading_count_cs(l, 1));
}

test "leading_count_cs case insensitive" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_string(l, "Hello", 5);
    _ = stz_list_append_string(l, "hello", 5);
    _ = stz_list_append_string(l, "HELLO", 5);
    _ = stz_list_append_string(l, "world", 5);
    try std.testing.expectEqual(@as(i64, 3), stz_list_leading_count_cs(l, 0));
    try std.testing.expectEqual(@as(i64, 0), stz_list_leading_count_cs(l, 1));
}

test "trailing_count_cs with repeated trailing" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_string(l, "a", 1);
    _ = stz_list_append_string(l, "b", 1);
    _ = stz_list_append_string(l, "c", 1);
    _ = stz_list_append_string(l, "c", 1);
    _ = stz_list_append_string(l, "c", 1);
    try std.testing.expectEqual(@as(i64, 3), stz_list_trailing_count_cs(l, 1));
}

test "trailing_count_cs no repeat" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_string(l, "a", 1);
    _ = stz_list_append_string(l, "b", 1);
    try std.testing.expectEqual(@as(i64, 0), stz_list_trailing_count_cs(l, 1));
}

test "starts_with_cs match" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_string(l, "hello", 5);
    _ = stz_list_append_string(l, "world", 5);
    const v = value_mod.stz_value_new_string("hello", 5) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(v);
    try std.testing.expectEqual(@as(i32, 1), stz_list_starts_with_cs(l, v, 1));
}

test "starts_with_cs case insensitive" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_string(l, "Hello", 5);
    _ = stz_list_append_string(l, "world", 5);
    const v = value_mod.stz_value_new_string("hello", 5) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(v);
    try std.testing.expectEqual(@as(i32, 0), stz_list_starts_with_cs(l, v, 1));
    try std.testing.expectEqual(@as(i32, 1), stz_list_starts_with_cs(l, v, 0));
}

test "ends_with_cs match" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_string(l, "hello", 5);
    _ = stz_list_append_string(l, "world", 5);
    const v = value_mod.stz_value_new_string("world", 5) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(v);
    try std.testing.expectEqual(@as(i32, 1), stz_list_ends_with_cs(l, v, 1));
}

test "ends_with_cs no match" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_string(l, "hello", 5);
    _ = stz_list_append_string(l, "world", 5);
    const v = value_mod.stz_value_new_string("hello", 5) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(v);
    try std.testing.expectEqual(@as(i32, 0), stz_list_ends_with_cs(l, v, 1));
}

test "remove_leading_cs removes duplicates" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_string(l, "x", 1);
    _ = stz_list_append_string(l, "x", 1);
    _ = stz_list_append_string(l, "x", 1);
    _ = stz_list_append_string(l, "a", 1);
    _ = stz_list_append_string(l, "b", 1);
    const removed = stz_list_remove_leading_cs(l, 1);
    try std.testing.expectEqual(@as(i32, 2), removed);
    try std.testing.expectEqual(@as(usize, 3), stz_list_len(l));
    var buf: [64]u8 = undefined;
    var n = stz_list_get_string(l, 0, &buf, 64);
    try std.testing.expect(std.mem.eql(u8, buf[0..n], "x"));
    n = stz_list_get_string(l, 1, &buf, 64);
    try std.testing.expect(std.mem.eql(u8, buf[0..n], "a"));
}

test "remove_trailing_cs removes duplicates" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_string(l, "a", 1);
    _ = stz_list_append_string(l, "b", 1);
    _ = stz_list_append_string(l, "y", 1);
    _ = stz_list_append_string(l, "y", 1);
    _ = stz_list_append_string(l, "y", 1);
    const removed = stz_list_remove_trailing_cs(l, 1);
    try std.testing.expectEqual(@as(i32, 2), removed);
    try std.testing.expectEqual(@as(usize, 3), stz_list_len(l));
    var buf: [64]u8 = undefined;
    var n = stz_list_get_string(l, 0, &buf, 64);
    try std.testing.expect(std.mem.eql(u8, buf[0..n], "a"));
    n = stz_list_get_string(l, 2, &buf, 64);
    try std.testing.expect(std.mem.eql(u8, buf[0..n], "y"));
}

test "remove_leading_cs no repeat returns 0" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_string(l, "a", 1);
    _ = stz_list_append_string(l, "b", 1);
    try std.testing.expectEqual(@as(i32, 0), stz_list_remove_leading_cs(l, 1));
    try std.testing.expectEqual(@as(usize, 2), stz_list_len(l));
}

test "split_at basic" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    for (0..5) |i| _ = stz_list_append_int(l, @intCast(i + 1));

    const pos = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(pos);
    _ = stz_list_append_int(pos, 2);

    const result = stz_list_split_at(l, pos) orelse return error.AllocFailed;
    defer stz_list_free(result);
    try std.testing.expectEqual(@as(usize, 2), stz_list_len(result));

    const g0 = stz_list_get_sublist(result, 0) orelse return error.AllocFailed;
    defer stz_list_free(g0);
    try std.testing.expectEqual(@as(usize, 2), stz_list_len(g0));
    try std.testing.expectEqual(@as(i64, 1), stz_list_get_int(g0, 0));
    try std.testing.expectEqual(@as(i64, 2), stz_list_get_int(g0, 1));

    const g1 = stz_list_get_sublist(result, 1) orelse return error.AllocFailed;
    defer stz_list_free(g1);
    try std.testing.expectEqual(@as(usize, 3), stz_list_len(g1));
    try std.testing.expectEqual(@as(i64, 3), stz_list_get_int(g1, 0));
}

test "split_at multiple positions" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    for (0..6) |i| _ = stz_list_append_int(l, @intCast(i + 10));

    const pos = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(pos);
    _ = stz_list_append_int(pos, 2);
    _ = stz_list_append_int(pos, 4);

    const result = stz_list_split_at(l, pos) orelse return error.AllocFailed;
    defer stz_list_free(result);
    try std.testing.expectEqual(@as(usize, 3), stz_list_len(result));
}

test "split_at no positions wraps whole list" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 2);

    const pos = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(pos);

    const result = stz_list_split_at(l, pos) orelse return error.AllocFailed;
    defer stz_list_free(result);
    try std.testing.expectEqual(@as(usize, 1), stz_list_len(result));

    const g0 = stz_list_get_sublist(result, 0) orelse return error.AllocFailed;
    defer stz_list_free(g0);
    try std.testing.expectEqual(@as(usize, 2), stz_list_len(g0));
}

test "split_before position 3 of 5" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    for (1..6) |i| { _ = stz_list_append_int(l, @intCast(i)); }

    const result = stz_list_split_before(l, 3) orelse return error.AllocFailed;
    defer stz_list_free(result);
    try std.testing.expectEqual(@as(usize, 2), stz_list_len(result));
    const g0 = stz_list_get_sublist(result, 0) orelse return error.AllocFailed;
    defer stz_list_free(g0);
    try std.testing.expectEqual(@as(usize, 3), stz_list_len(g0));
    const g1 = stz_list_get_sublist(result, 1) orelse return error.AllocFailed;
    defer stz_list_free(g1);
    try std.testing.expectEqual(@as(usize, 2), stz_list_len(g1));
}

test "split_after position 2 of 5" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    for (1..6) |i| { _ = stz_list_append_int(l, @intCast(i)); }

    const result = stz_list_split_after(l, 2) orelse return error.AllocFailed;
    defer stz_list_free(result);
    try std.testing.expectEqual(@as(usize, 2), stz_list_len(result));
    const g0 = stz_list_get_sublist(result, 0) orelse return error.AllocFailed;
    defer stz_list_free(g0);
    try std.testing.expectEqual(@as(usize, 3), stz_list_len(g0));
    const g1 = stz_list_get_sublist(result, 1) orelse return error.AllocFailed;
    defer stz_list_free(g1);
    try std.testing.expectEqual(@as(usize, 2), stz_list_len(g1));
}

test "split_to_parts_of_n chunks of 2 from 5" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    for (1..6) |i| { _ = stz_list_append_int(l, @intCast(i)); }

    const result = stz_list_split_to_parts_of_n(l, 2) orelse return error.AllocFailed;
    defer stz_list_free(result);
    try std.testing.expectEqual(@as(usize, 3), stz_list_len(result));
}

test "sorted_insert into empty" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    const v = value_mod.stz_value_new_int(42) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(v);
    try std.testing.expectEqual(@as(i32, 0), stz_list_sorted_insert(l, v));
    try std.testing.expectEqual(@as(usize, 1), stz_list_len(l));
    try std.testing.expectEqual(@as(i64, 42), stz_list_get_int(l, 0));
}

test "sorted_insert maintains order" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 10);
    _ = stz_list_append_int(l, 20);
    _ = stz_list_append_int(l, 40);

    const v = value_mod.stz_value_new_int(30) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(v);
    const idx = stz_list_sorted_insert(l, v);
    try std.testing.expectEqual(@as(i32, 2), idx);
    try std.testing.expectEqual(@as(usize, 4), stz_list_len(l));
    try std.testing.expectEqual(@as(i64, 30), stz_list_get_int(l, 2));
}

test "sorted_insert at beginning" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 20);
    _ = stz_list_append_int(l, 30);

    const v = value_mod.stz_value_new_int(5) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(v);
    const idx = stz_list_sorted_insert(l, v);
    try std.testing.expectEqual(@as(i32, 0), idx);
    try std.testing.expectEqual(@as(i64, 5), stz_list_get_int(l, 0));
}

test "sorted_insert at end" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 10);
    _ = stz_list_append_int(l, 20);

    const v = value_mod.stz_value_new_int(100) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(v);
    const idx = stz_list_sorted_insert(l, v);
    try std.testing.expectEqual(@as(i32, 2), idx);
    try std.testing.expectEqual(@as(i64, 100), stz_list_get_int(l, 2));
}

// ===== Checker function tests =====

test "is_all_lists true" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    const sub1 = value_mod.stz_value_new_list() orelse return error.AllocFailed;
    defer value_mod.stz_value_free(sub1);
    const sub2 = value_mod.stz_value_new_list() orelse return error.AllocFailed;
    defer value_mod.stz_value_free(sub2);
    _ = stz_list_append_value(l, sub1);
    _ = stz_list_append_value(l, sub2);
    try std.testing.expectEqual(@as(i32, 1), stz_list_is_all_lists(l));
}

test "is_all_lists false" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 1);
    const sub1 = value_mod.stz_value_new_list() orelse return error.AllocFailed;
    defer value_mod.stz_value_free(sub1);
    _ = stz_list_append_value(l, sub1);
    try std.testing.expectEqual(@as(i32, 0), stz_list_is_all_lists(l));
}

test "is_all_pairs true" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    // Create pair [1, 2]
    const pair = value_mod.stz_value_new_list() orelse return error.AllocFailed;
    defer value_mod.stz_value_free(pair);
    const v1 = value_mod.stz_value_new_int(1) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(v1);
    const v2 = value_mod.stz_value_new_int(2) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(v2);
    _ = value_mod.stz_value_list_append(pair, v1);
    _ = value_mod.stz_value_list_append(pair, v2);
    _ = stz_list_append_value(l, pair);
    try std.testing.expectEqual(@as(i32, 1), stz_list_is_all_pairs(l));
}

test "is_all_pairs false non-pair" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    const sub = value_mod.stz_value_new_list() orelse return error.AllocFailed;
    defer value_mod.stz_value_free(sub);
    const v1 = value_mod.stz_value_new_int(1) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(v1);
    _ = value_mod.stz_value_list_append(sub, v1);
    _ = stz_list_append_value(l, sub);
    try std.testing.expectEqual(@as(i32, 0), stz_list_is_all_pairs(l));
}

test "is_all_sections true" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    // [1, 3] is a section (pair of numbers)
    const sec = value_mod.stz_value_new_list() orelse return error.AllocFailed;
    defer value_mod.stz_value_free(sec);
    const s1 = value_mod.stz_value_new_int(1) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(s1);
    const s2 = value_mod.stz_value_new_int(3) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(s2);
    _ = value_mod.stz_value_list_append(sec, s1);
    _ = value_mod.stz_value_list_append(sec, s2);
    _ = stz_list_append_value(l, sec);
    try std.testing.expectEqual(@as(i32, 1), stz_list_is_all_sections(l));
}

test "is_hybrid true" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_string(l, "hello", 5);
    try std.testing.expectEqual(@as(i32, 1), stz_list_is_hybrid(l));
}

test "is_hybrid false homogeneous" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 2);
    try std.testing.expectEqual(@as(i32, 0), stz_list_is_hybrid(l));
}

test "all_items_equal_cs true" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 5);
    _ = stz_list_append_int(l, 5);
    _ = stz_list_append_int(l, 5);
    try std.testing.expectEqual(@as(i32, 1), stz_list_all_items_equal_cs(l, 1));
}

test "all_items_equal_cs false" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 5);
    _ = stz_list_append_int(l, 6);
    try std.testing.expectEqual(@as(i32, 0), stz_list_all_items_equal_cs(l, 1));
}

test "is_palindrome_cs true" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 2);
    _ = stz_list_append_int(l, 1);
    try std.testing.expectEqual(@as(i32, 1), stz_list_is_palindrome_cs(l, 1));
}

test "is_palindrome_cs false" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 2);
    _ = stz_list_append_int(l, 3);
    try std.testing.expectEqual(@as(i32, 0), stz_list_is_palindrome_cs(l, 1));
}

test "is_continuous true" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 3);
    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 2);
    try std.testing.expectEqual(@as(i32, 1), stz_list_is_continuous(l));
}

test "is_continuous false" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 3);
    _ = stz_list_append_int(l, 5);
    try std.testing.expectEqual(@as(i32, 0), stz_list_is_continuous(l));
}

test "is_all_lists_same_size true" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    const p1 = value_mod.stz_value_new_list() orelse return error.AllocFailed;
    defer value_mod.stz_value_free(p1);
    const a1 = value_mod.stz_value_new_int(1) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(a1);
    const a2 = value_mod.stz_value_new_int(2) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(a2);
    _ = value_mod.stz_value_list_append(p1, a1);
    _ = value_mod.stz_value_list_append(p1, a2);
    const p2 = value_mod.stz_value_new_list() orelse return error.AllocFailed;
    defer value_mod.stz_value_free(p2);
    const b1 = value_mod.stz_value_new_int(3) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(b1);
    const b2 = value_mod.stz_value_new_int(4) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(b2);
    _ = value_mod.stz_value_list_append(p2, b1);
    _ = value_mod.stz_value_list_append(p2, b2);
    _ = stz_list_append_value(l, p1);
    _ = stz_list_append_value(l, p2);
    try std.testing.expectEqual(@as(i32, 1), stz_list_is_all_lists_same_size(l));
}

test "is_strictly_increasing true" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 3);
    _ = stz_list_append_int(l, 7);
    try std.testing.expectEqual(@as(i32, 1), stz_list_is_strictly_increasing(l));
}

test "is_strictly_increasing false" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 3);
    try std.testing.expectEqual(@as(i32, 0), stz_list_is_strictly_increasing(l));
}

test "is_strictly_decreasing true" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 10);
    _ = stz_list_append_int(l, 5);
    _ = stz_list_append_int(l, 1);
    try std.testing.expectEqual(@as(i32, 1), stz_list_is_strictly_decreasing(l));
}

test "is_monotonic true ascending" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 2);
    _ = stz_list_append_int(l, 2);
    _ = stz_list_append_int(l, 3);
    try std.testing.expectEqual(@as(i32, 1), stz_list_is_monotonic(l));
}

test "is_monotonic false" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 3);
    _ = stz_list_append_int(l, 2);
    try std.testing.expectEqual(@as(i32, 0), stz_list_is_monotonic(l));
}

test "checker null handles" {
    try std.testing.expectEqual(@as(i32, 0), stz_list_is_all_lists(null));
    try std.testing.expectEqual(@as(i32, 0), stz_list_is_all_pairs(null));
    try std.testing.expectEqual(@as(i32, 0), stz_list_is_all_sections(null));
    try std.testing.expectEqual(@as(i32, 0), stz_list_is_hybrid(null));
    try std.testing.expectEqual(@as(i32, 1), stz_list_all_items_equal_cs(null, 1));
    try std.testing.expectEqual(@as(i32, 1), stz_list_is_palindrome_cs(null, 1));
    try std.testing.expectEqual(@as(i32, 0), stz_list_is_continuous(null));
    try std.testing.expectEqual(@as(i32, 0), stz_list_is_all_lists_same_size(null));
    try std.testing.expectEqual(@as(i32, 0), stz_list_is_strictly_increasing(null));
    try std.testing.expectEqual(@as(i32, 0), stz_list_is_strictly_decreasing(null));
    try std.testing.expectEqual(@as(i32, 0), stz_list_is_monotonic(null));
}

// ===== Statistics function tests =====

test "median odd list" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 3);
    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 2);
    try std.testing.expectEqual(@as(f64, 2.0), stz_list_median(l));
}

test "median even list" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 4);
    _ = stz_list_append_int(l, 3);
    _ = stz_list_append_int(l, 2);
    try std.testing.expectEqual(@as(f64, 2.5), stz_list_median(l));
}

test "median null returns 0" {
    try std.testing.expectEqual(@as(f64, 0), stz_list_median(null));
}

test "nth_smallest basic" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 30);
    _ = stz_list_append_int(l, 10);
    _ = stz_list_append_int(l, 20);
    try std.testing.expectEqual(@as(f64, 10.0), stz_list_nth_smallest(l, 0));
    try std.testing.expectEqual(@as(f64, 20.0), stz_list_nth_smallest(l, 1));
    try std.testing.expectEqual(@as(f64, 30.0), stz_list_nth_smallest(l, 2));
}

test "nth_largest basic" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 30);
    _ = stz_list_append_int(l, 10);
    _ = stz_list_append_int(l, 20);
    try std.testing.expectEqual(@as(f64, 30.0), stz_list_nth_largest(l, 0));
    try std.testing.expectEqual(@as(f64, 20.0), stz_list_nth_largest(l, 1));
    try std.testing.expectEqual(@as(f64, 10.0), stz_list_nth_largest(l, 2));
}

test "variance basic" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 2);
    _ = stz_list_append_int(l, 4);
    _ = stz_list_append_int(l, 4);
    _ = stz_list_append_int(l, 4);
    _ = stz_list_append_int(l, 5);
    _ = stz_list_append_int(l, 5);
    _ = stz_list_append_int(l, 7);
    _ = stz_list_append_int(l, 9);
    // mean = 5, variance = 4
    try std.testing.expectEqual(@as(f64, 4.0), stz_list_variance(l));
}

test "stddev basic" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 2);
    _ = stz_list_append_int(l, 4);
    _ = stz_list_append_int(l, 4);
    _ = stz_list_append_int(l, 4);
    _ = stz_list_append_int(l, 5);
    _ = stz_list_append_int(l, 5);
    _ = stz_list_append_int(l, 7);
    _ = stz_list_append_int(l, 9);
    // stddev = 2
    try std.testing.expectEqual(@as(f64, 2.0), stz_list_stddev(l));
}

test "ranked basic" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 30);
    _ = stz_list_append_int(l, 10);
    _ = stz_list_append_int(l, 20);
    const ranked = stz_list_ranked(l) orelse return error.AllocFailed;
    defer stz_list_free(ranked);
    try std.testing.expectEqual(@as(usize, 3), ranked.len());
    try std.testing.expectEqual(@as(i64, 3), stz_list_get_int(ranked, 0)); // 30 is rank 3
    try std.testing.expectEqual(@as(i64, 1), stz_list_get_int(ranked, 1)); // 10 is rank 1
    try std.testing.expectEqual(@as(i64, 2), stz_list_get_int(ranked, 2)); // 20 is rank 2
}

test "ranked null returns null" {
    try std.testing.expectEqual(@as(?*StzList, null), stz_list_ranked(null));
}

test "statistics null handles" {
    try std.testing.expectEqual(@as(f64, 0), stz_list_variance(null));
    try std.testing.expectEqual(@as(f64, 0), stz_list_stddev(null));
    try std.testing.expectEqual(@as(f64, 0), stz_list_nth_smallest(null, 0));
    try std.testing.expectEqual(@as(f64, 0), stz_list_nth_largest(null, 0));
}

// ===== Find nth/last tests =====

test "find_nth_cs first occurrence" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 10);
    _ = stz_list_append_int(l, 20);
    _ = stz_list_append_int(l, 10);
    _ = stz_list_append_int(l, 30);
    _ = stz_list_append_int(l, 10);
    const v = value_mod.stz_value_new_int(10) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(v);
    try std.testing.expectEqual(@as(i64, 0), stz_list_find_nth_cs(l, v, 0, 1));
    try std.testing.expectEqual(@as(i64, 2), stz_list_find_nth_cs(l, v, 1, 1));
    try std.testing.expectEqual(@as(i64, 4), stz_list_find_nth_cs(l, v, 2, 1));
    try std.testing.expectEqual(@as(i64, -1), stz_list_find_nth_cs(l, v, 3, 1));
}

test "find_last_cs basic" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 10);
    _ = stz_list_append_int(l, 20);
    _ = stz_list_append_int(l, 10);
    _ = stz_list_append_int(l, 30);
    const v = value_mod.stz_value_new_int(10) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(v);
    try std.testing.expectEqual(@as(i64, 2), stz_list_find_last_cs(l, v, 1));
}

test "find_last_cs not found" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_int(l, 10);
    const v = value_mod.stz_value_new_int(99) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(v);
    try std.testing.expectEqual(@as(i64, -1), stz_list_find_last_cs(l, v, 1));
}

test "find_nth_last null handles" {
    try std.testing.expectEqual(@as(i64, -1), stz_list_find_nth_cs(null, null, 0, 1));
    try std.testing.expectEqual(@as(i64, -1), stz_list_find_last_cs(null, null, 1));
}

// ─── Tests for stz_list_replace_many_cs ───

test "replace_many_cs basic" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_string(l, "a", 1);
    _ = stz_list_append_string(l, "b", 1);
    _ = stz_list_append_string(l, "a", 1);

    const olds = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(olds);
    _ = stz_list_append_string(olds, "a", 1);
    _ = stz_list_append_string(olds, "b", 1);

    const news = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(news);
    _ = stz_list_append_string(news, "X", 1);
    _ = stz_list_append_string(news, "Y", 1);

    const replaced = stz_list_replace_many_cs(l, olds, news, 1);
    try std.testing.expectEqual(@as(i32, 3), replaced);

    // Verify: ["X", "Y", "X"]
    var buf: [64]u8 = undefined;
    const n0 = stz_list_get_string(l, 0, &buf, 64);
    try std.testing.expectEqualSlices(u8, "X", buf[0..n0]);
    const n1 = stz_list_get_string(l, 1, &buf, 64);
    try std.testing.expectEqualSlices(u8, "Y", buf[0..n1]);
    const n2 = stz_list_get_string(l, 2, &buf, 64);
    try std.testing.expectEqualSlices(u8, "X", buf[0..n2]);
}

test "replace_many_cs mismatched sizes" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    const olds = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(olds);
    _ = stz_list_append_string(olds, "a", 1);
    const news = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(news);
    // news is empty, olds has 1 — should return -1
    try std.testing.expectEqual(@as(i32, -1), stz_list_replace_many_cs(l, olds, news, 1));
}

test "replace_many_cs null handles" {
    try std.testing.expectEqual(@as(i32, -1), stz_list_replace_many_cs(null, null, null, 1));
}

// ─── Tests for stz_list_count_empty_strings ───

test "count_empty_strings basic" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_string(l, "a", 1);
    _ = stz_list_append_string(l, "", 0);
    _ = stz_list_append_string(l, "c", 1);
    _ = stz_list_append_string(l, "", 0);
    try std.testing.expectEqual(@as(i32, 2), stz_list_count_empty_strings(l));
}

test "count_empty_strings none" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_string(l, "a", 1);
    _ = stz_list_append_int(l, 42);
    try std.testing.expectEqual(@as(i32, 0), stz_list_count_empty_strings(l));
}

// ─── Tests for stz_list_find_empty_strings ───

test "find_empty_strings basic" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);
    _ = stz_list_append_string(l, "a", 1);
    _ = stz_list_append_string(l, "", 0);
    _ = stz_list_append_string(l, "c", 1);
    _ = stz_list_append_string(l, "", 0);

    const result = stz_list_find_empty_strings(l) orelse return error.AllocFailed;
    defer stz_list_free(result);
    try std.testing.expectEqual(@as(usize, 2), result.len());
    try std.testing.expectEqual(@as(i64, 1), stz_list_get_int(result, 0));
    try std.testing.expectEqual(@as(i64, 3), stz_list_get_int(result, 1));
}
