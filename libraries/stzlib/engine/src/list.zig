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
    items: std.ArrayList(*StzValue),

    pub fn init() !*StzList {
        const self = try allocator.create(StzList);
        self.* = .{ .items = .{} };
        return self;
    }

    pub fn deinit(self: *StzList) void {
        for (self.items.items) |item| {
            item.deinit();
            allocator.destroy(item);
        }
        self.items.deinit(allocator);
        allocator.destroy(self);
    }

    pub fn len(self: *const StzList) usize {
        return self.items.items.len;
    }

    pub fn appendClone(self: *StzList, v: *const StzValue) !void {
        const cloned = try v.clone();
        try self.items.append(allocator, cloned);
    }

    pub fn get(self: *const StzList, index: usize) ?*const StzValue {
        if (index >= self.items.items.len) return null;
        return self.items.items[index];
    }

    pub fn getMut(self: *StzList, index: usize) ?*StzValue {
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

pub fn stz_list_append_int(list: ?*StzList, n: i64) callconv(.c) i32 {
    const l = list orelse return -1;
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

pub fn stz_list_remove(list: ?*StzList, index: usize) callconv(.c) i32 {
    const l = list orelse return -1;
    if (index >= l.len()) return -1;
    const removed = l.items.orderedRemove(index);
    removed.deinit();
    allocator.destroy(removed);
    return 0;
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

// ─── C ABI: Find ───

pub fn stz_list_find_cs(list: ?*const StzList, v: ?*const StzValue, case_sensitive: i32) callconv(.c) i64 {
    const l = list orelse return -1;
    const needle = v orelse return -1;
    const cs = case_sensitive != 0;
    for (l.items.items, 0..) |item, i| {
        if (valueEqlCS(item, needle, cs)) return @intCast(i);
    }
    return -1;
}

pub fn stz_list_find_string_cs(list: ?*const StzList, ptr: [*]const u8, str_len: usize, case_sensitive: i32) callconv(.c) i64 {
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
    return if (stz_list_find_cs(list, v, case_sensitive) >= 0) 1 else 0;
}

// ─── C ABI: Find All ───

pub fn stz_list_find_all_cs(list: ?*const StzList, v: ?*const StzValue, case_sensitive: i32, out_buf: [*]i64, out_cap: usize) callconv(.c) usize {
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
    const result = StzList.init() catch return null;

    for (l.items.items) |item| {
        var found = false;
        for (result.items.items) |existing| {
            if (valueEqlCS(existing, item, cs)) {
                found = true;
                break;
            }
        }
        if (!found) {
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
            const s = "[list]";
            if (s.len <= buf.len) @memcpy(buf[0..s.len], s);
            break :blk @min(s.len, buf.len);
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

pub fn stz_list_classify_cs(list_arg: ?*const StzList, case_sensitive: i32) callconv(.c) ?*StzList {
    const l = list_arg orelse return null;
    const cs = case_sensitive != 0;
    const n = l.len();
    const result = StzList.init() catch return null;
    if (n == 0) return result;

    // Build key strings for each item
    const key_bufs = allocator.alloc([256]u8, n) catch { result.deinit(); return null; };
    defer allocator.free(key_bufs);
    const key_lens = allocator.alloc(usize, n) catch { result.deinit(); return null; };
    defer allocator.free(key_lens);

    for (l.items.items, 0..) |item, i| {
        key_lens[i] = valueToString(item, &key_bufs[i]);
        if (!cs) {
            // lowercase in-place for comparison
            for (key_bufs[i][0..key_lens[i]]) |*c| {
                if (c.* >= 'A' and c.* <= 'Z') c.* += 32;
            }
        }
    }

    // Group: seen_keys[], position_lists[]
    const max_groups = n;
    const seen_keys = allocator.alloc([]const u8, max_groups) catch { result.deinit(); return null; };
    defer allocator.free(seen_keys);

    // For each group, store positions as a dynamic list of indices
    const PosGroup = struct { positions: std.ArrayList(usize) };
    const groups = allocator.alloc(PosGroup, max_groups) catch { result.deinit(); return null; };
    defer {
        for (groups[0..]) |*grp| grp.positions.deinit(allocator);
        allocator.free(groups);
    }
    for (groups) |*grp| grp.* = .{ .positions = .{} };

    var num_groups: usize = 0;

    for (0..n) |i| {
        const key = key_bufs[i][0..key_lens[i]];
        if (findInSeen(seen_keys[0..num_groups], key, true)) |gi| {
            // Already comparing lowercased keys if CI, so always use true here
            groups[gi].positions.append(allocator, i) catch {};
        } else {
            seen_keys[num_groups] = key;
            groups[num_groups].positions = .{};
            groups[num_groups].positions.append(allocator, i) catch {};
            num_groups += 1;
        }
    }

    // Build result: alternating [key_string, positions_csv_string]
    for (0..num_groups) |gi| {
        // Append the key (use original casing from first occurrence)
        const first_idx = groups[gi].positions.items[0];
        const orig_item = l.items.items[first_idx];
        var orig_buf: [256]u8 = undefined;
        const orig_len = valueToString(orig_item, &orig_buf);
        _ = stz_list_append_string(result, &orig_buf, orig_len);

        // Build positions CSV (1-based)
        var csv_buf: [65536]u8 = undefined;
        var pos: usize = 0;
        for (groups[gi].positions.items, 0..) |idx, pi| {
            const val_1based = idx + 1;
            const slice = std.fmt.bufPrint(csv_buf[pos..], "{d}", .{val_1based}) catch break;
            pos += slice.len;
            if (pi + 1 < groups[gi].positions.items.len) {
                csv_buf[pos] = ',';
                pos += 1;
            }
        }
        _ = stz_list_append_string(result, &csv_buf, pos);
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
        .list_val => expr.Val.initNull(),
    };
}

fn valToStzValue(v: expr.Val) ?*StzValue {
    return switch (v.tag) {
        .null_v => value_mod.stz_value_new_null(),
        .bool_v => value_mod.stz_value_new_bool(if (v.data.b) 1 else 0),
        .int_v => value_mod.stz_value_new_int(v.data.i),
        .float_v => value_mod.stz_value_new_float(v.data.f),
        .str_v => value_mod.stz_value_new_string(v.data.s.ptr, v.data.s.len),
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
            .index = @as(i64, @intCast(i)) + 1,
            .count = @intCast(l.len()),
            .accum = accum,
        };
        accum = expr.eval(prog, &ctx);
    }

    return valToStzValue(accum);
}

pub fn stz_list_find_w(list: ?*const StzList, expr_ptr: [*]const u8, expr_len: usize) callconv(.c) i64 {
    const l = list orelse return -1;
    const prog = expr.compile(expr_ptr, expr_len) orelse return -1;
    defer prog.deinit();

    const count: i64 = @intCast(l.len());

    for (l.items.items, 0..) |item, i| {
        var ctx = expr.EvalCtx{
            .item = stzValueToVal(item),
            .index = @as(i64, @intCast(i)) + 1,
            .count = count,
        };
        const val = expr.eval(prog, &ctx);
        if (val.isTruthy()) return @intCast(i);
    }
    return -1;
}

pub fn stz_list_find_all_w(list: ?*const StzList, expr_ptr: [*]const u8, expr_len: usize, out_buf: [*]i64, out_cap: usize) callconv(.c) usize {
    const l = list orelse return 0;
    const prog = expr.compile(expr_ptr, expr_len) orelse return 0;
    defer prog.deinit();

    var found: usize = 0;
    const count: i64 = @intCast(l.len());

    for (l.items.items, 0..) |item, i| {
        var ctx = expr.EvalCtx{
            .item = stzValueToVal(item),
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

pub fn stz_list_intersection_cs(a: ?*const StzList, b: ?*const StzList, case_sensitive: i32) callconv(.c) ?*StzList {
    const la = a orelse return StzList.init() catch null;
    const lb = b orelse return StzList.init() catch null;
    const cs = case_sensitive != 0;
    const result = StzList.init() catch return null;

    for (la.items.items) |item| {
        // Check item is in b
        var in_b = false;
        for (lb.items.items) |bi| {
            if (valueEqlCS(item, bi, cs)) { in_b = true; break; }
        }
        if (!in_b) continue;
        // Check not already in result
        var in_r = false;
        for (result.items.items) |ri| {
            if (valueEqlCS(item, ri, cs)) { in_r = true; break; }
        }
        if (!in_r) {
            result.appendClone(item) catch { result.deinit(); return null; };
        }
    }
    return result;
}

pub fn stz_list_union_cs(a: ?*const StzList, b: ?*const StzList, case_sensitive: i32) callconv(.c) ?*StzList {
    const la = a orelse return if (b != null) stz_list_clone(b) else StzList.init() catch null;
    const lb = b orelse return stz_list_clone(a);
    const cs = case_sensitive != 0;
    const result = stz_list_clone(la) orelse return null;

    for (lb.items.items) |item| {
        var found = false;
        for (result.items.items) |ri| {
            if (valueEqlCS(item, ri, cs)) { found = true; break; }
        }
        if (!found) {
            result.appendClone(item) catch { result.deinit(); return null; };
        }
    }
    return result;
}

pub fn stz_list_difference_cs(a: ?*const StzList, b: ?*const StzList, case_sensitive: i32) callconv(.c) ?*StzList {
    const la = a orelse return StzList.init() catch null;
    const lb = b orelse return stz_list_clone(a);
    const cs = case_sensitive != 0;
    const result = StzList.init() catch return null;

    for (la.items.items) |item| {
        var in_b = false;
        for (lb.items.items) |bi| {
            if (valueEqlCS(item, bi, cs)) { in_b = true; break; }
        }
        if (!in_b) {
            result.appendClone(item) catch { result.deinit(); return null; };
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

// ─── Tests ───

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

test "list find CS" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_string(l, "Alpha", 5);
    _ = stz_list_append_string(l, "Beta", 4);
    _ = stz_list_append_string(l, "Gamma", 5);

    try std.testing.expectEqual(@as(i64, 1), stz_list_find_string_cs(l, "Beta", 4, 1));
    try std.testing.expectEqual(@as(i64, -1), stz_list_find_string_cs(l, "beta", 4, 1));
    try std.testing.expectEqual(@as(i64, 1), stz_list_find_string_cs(l, "beta", 4, 0));
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

test "list find all" {
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
    const count = stz_list_find_all_cs(l, needle, 1, &positions, 10);
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

test "list insert and remove" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 3);

    const v2 = value_mod.stz_value_new_int(2) orelse return error.AllocFailed;
    defer value_mod.stz_value_free(v2);
    _ = stz_list_insert(l, 1, v2);

    try std.testing.expectEqual(@as(usize, 3), stz_list_len(l));
    try std.testing.expectEqual(@as(i64, 2), stz_list_get_int(l, 1));

    _ = stz_list_remove(l, 1);
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

test "find_w first match" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_int(l, 5);
    _ = stz_list_append_int(l, 12);
    _ = stz_list_append_int(l, 3);
    _ = stz_list_append_int(l, 15);

    const e = "@item > 10";
    try std.testing.expectEqual(@as(i64, 1), stz_list_find_w(l, e.ptr, e.len));
}

test "find_w no match returns -1" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 2);

    const e = "@item > 100";
    try std.testing.expectEqual(@as(i64, -1), stz_list_find_w(l, e.ptr, e.len));
}

test "find_w null list returns -1" {
    const e = "@item > 0";
    try std.testing.expectEqual(@as(i64, -1), stz_list_find_w(null, e.ptr, e.len));
}

test "find_all_w positions" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 20);
    _ = stz_list_append_int(l, 3);
    _ = stz_list_append_int(l, 40);
    _ = stz_list_append_int(l, 5);

    const e = "@item > 10";
    var positions: [10]i64 = undefined;
    const count = stz_list_find_all_w(l, e.ptr, e.len, &positions, 10);
    try std.testing.expectEqual(@as(usize, 2), count);
    try std.testing.expectEqual(@as(i64, 1), positions[0]);
    try std.testing.expectEqual(@as(i64, 3), positions[1]);
}

test "find_all_w empty result" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_int(l, 1);

    const e = "@item > 100";
    var positions: [10]i64 = undefined;
    const count = stz_list_find_all_w(l, e.ptr, e.len, &positions, 10);
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
    // 3 groups * 2 entries each = 6 items
    try std.testing.expectEqual(@as(usize, 6), stz_list_len(r));

    var buf: [256]u8 = undefined;
    // Group 0: "a", "1,3"
    var n = stz_list_get_string(r, 0, &buf, 256);
    try std.testing.expectEqualStrings("a", buf[0..n]);
    n = stz_list_get_string(r, 1, &buf, 256);
    try std.testing.expectEqualStrings("1,3", buf[0..n]);

    // Group 1: "b", "2,5"
    n = stz_list_get_string(r, 2, &buf, 256);
    try std.testing.expectEqualStrings("b", buf[0..n]);
    n = stz_list_get_string(r, 3, &buf, 256);
    try std.testing.expectEqualStrings("2,5", buf[0..n]);

    // Group 2: "c", "4"
    n = stz_list_get_string(r, 4, &buf, 256);
    try std.testing.expectEqualStrings("c", buf[0..n]);
    n = stz_list_get_string(r, 5, &buf, 256);
    try std.testing.expectEqualStrings("4", buf[0..n]);
}

test "classify_cs case insensitive" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_string(l, "Hello", 5);
    _ = stz_list_append_string(l, "hello", 5);
    _ = stz_list_append_string(l, "World", 5);

    const r = stz_list_classify_cs(l, 0) orelse return error.AllocFailed;
    defer stz_list_free(r);
    // 2 groups
    try std.testing.expectEqual(@as(usize, 4), stz_list_len(r));
}

test "classify_cs integers" {
    const l = stz_list_new() orelse return error.AllocFailed;
    defer stz_list_free(l);

    _ = stz_list_append_int(l, 1);
    _ = stz_list_append_int(l, 2);
    _ = stz_list_append_int(l, 1);

    const r = stz_list_classify_cs(l, 1) orelse return error.AllocFailed;
    defer stz_list_free(r);
    try std.testing.expectEqual(@as(usize, 4), stz_list_len(r));

    var buf: [256]u8 = undefined;
    var n = stz_list_get_string(r, 0, &buf, 256);
    try std.testing.expectEqualStrings("1", buf[0..n]);
    n = stz_list_get_string(r, 1, &buf, 256);
    try std.testing.expectEqualStrings("1,3", buf[0..n]);
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
