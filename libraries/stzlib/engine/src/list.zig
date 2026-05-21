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
