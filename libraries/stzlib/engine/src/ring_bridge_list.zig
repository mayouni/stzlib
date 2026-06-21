const std = @import("std");
const list = @import("list.zig");
const value = @import("value.zig");
const R = @import("ring_api.zig");

const g = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring;
const rs2 = R.ring_vm_api_retstring2;

// Shadow the real cpointer functions: store/resolve via handle table.
fn rcp(p: *anyopaque, ptr: ?*anyopaque, _: [*:0]const u8) void {
    R.retHandle(p, ptr);
}

fn gcp(p: *anyopaque, n: c_int, _: [*:0]const u8) ?*anyopaque {
    return R.getHandle(p, n);
}

const HL: [*:0]const u8 = "StzListHandle";
const HV: [*:0]const u8 = "StzValueHandle";

fn getL(p: *anyopaque, n: c_int) ?*list.StzList {
    const ptr = gcp(p, n, HL);
    if (ptr) |raw| return @ptrCast(@alignCast(raw));
    return null;
}

fn getLC(p: *anyopaque, n: c_int) ?*const list.StzList {
    const ptr = gcp(p, n, HL);
    if (ptr) |raw| return @ptrCast(@alignCast(raw));
    return null;
}

fn getV(p: *anyopaque, n: c_int) ?*const value.StzValue {
    const ptr = gcp(p, n, HV);
    if (ptr) |raw| return @ptrCast(@alignCast(raw));
    return null;
}

// Build & return a ready Ring list of 1-based positions from a raw 0-based
// i64 slice -- the split/loop happens here (Zig side), never in Ring.
fn retPositions(p: *anyopaque, positions: []const i64) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    for (positions) |v| {
        R.ring_list_adddouble(out, @floatFromInt(v + 1));
    }
    R.ring_vm_api_retlist(p, out);
}

// Lifecycle
fn ring_New(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_new()), HL);
}
fn ring_Free(p: *anyopaque) callconv(.c) void {
    const raw = R.releaseHandle(p, 1);
    if (raw) |ptr| {
        const h: ?*list.StzList = @ptrCast(@alignCast(ptr));
        list.stz_list_free(h);
    }
}
fn ring_Len(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_len(getLC(p, 1))));
}

// Append
fn ring_AppendInt(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_append_int(getL(p, 1), @intFromFloat(g(p, 2)))));
}
fn ring_AppendFloat(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_append_float(getL(p, 1), g(p, 2))));
}
fn ring_AppendString(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_append_string(getL(p, 1), gs(p, 2), @intCast(gss(p, 2)))));
}
fn ring_AppendValue(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_append_value(getL(p, 1), getV(p, 2))));
}

// Insert (INDEX_BASE=1: subtract 1)
fn ring_Insert(p: *anyopaque) callconv(.c) void {
    const idx: usize = @intFromFloat(g(p, 2));
    const adjusted = if (idx > 0) idx - 1 else 0;
    rn(p, @floatFromInt(list.stz_list_insert(getL(p, 1), adjusted, getV(p, 3))));
}

// Remove (INDEX_BASE=1: subtract 1)
fn ring_Remove(p: *anyopaque) callconv(.c) void {
    const idx: usize = @intFromFloat(g(p, 2));
    const adjusted = if (idx > 0) idx - 1 else 0;
    rn(p, @floatFromInt(list.stz_list_remove_at(getL(p, 1), adjusted)));
}

// RemoveAllCS(list, value, caseSensitive) -> count removed
fn ring_RemoveAllCS(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_remove_cs(getL(p, 1), getV(p, 2), @intFromFloat(g(p, 3)))));
}

// ReplaceAllCS(list, oldValue, newValue, caseSensitive) -> count replaced
fn ring_ReplaceAllCS(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_replace_cs(getL(p, 1), getV(p, 2), getV(p, 3), @intFromFloat(g(p, 4)))));
}

// String-direct variants -- avoid the cross-DLL handle-table bug
// where StzValue handles minted in stz_value.dll dont resolve in
// stz_list.dlls own static handle table.

// ReplaceAllStringCS(list, oldStr, newStr, caseSensitive) -> count
fn ring_ReplaceAllStringCS(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_replace_all_string_cs(
        getL(p, 1),
        @ptrCast(gs(p, 2)),
        @intCast(gss(p, 2)),
        @ptrCast(gs(p, 3)),
        @intCast(gss(p, 3)),
        @intFromFloat(g(p, 4)),
    )));
}

// RemoveAllStringCS(list, str, caseSensitive) -> count
fn ring_RemoveAllStringCS(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_remove_all_string_cs(
        getL(p, 1),
        @ptrCast(gs(p, 2)),
        @intCast(gss(p, 2)),
        @intFromFloat(g(p, 3)),
    )));
}

// SetString(list, index, str) -> 0 or -1.  INDEX_BASE=1.
fn ring_SetString(p: *anyopaque) callconv(.c) void {
    const idx: usize = @intFromFloat(g(p, 2));
    const adjusted = if (idx > 0) idx - 1 else 0;
    rn(p, @floatFromInt(list.stz_list_set_string(
        getL(p, 1),
        adjusted,
        @ptrCast(gs(p, 3)),
        @intCast(gss(p, 3)),
    )));
}

// Get (INDEX_BASE=1: subtract 1)
fn ring_Get(p: *anyopaque) callconv(.c) void {
    const idx: usize = @intFromFloat(g(p, 2));
    const adjusted = if (idx > 0) idx - 1 else 0;
    rcp(p, @constCast(@ptrCast(list.stz_list_get(getLC(p, 1), adjusted))), HV);
}
fn ring_GetInt(p: *anyopaque) callconv(.c) void {
    const idx: usize = @intFromFloat(g(p, 2));
    const adjusted = if (idx > 0) idx - 1 else 0;
    rn(p, @floatFromInt(list.stz_list_get_int(getLC(p, 1), adjusted)));
}
fn ring_GetFloat(p: *anyopaque) callconv(.c) void {
    const idx: usize = @intFromFloat(g(p, 2));
    const adjusted = if (idx > 0) idx - 1 else 0;
    rn(p, list.stz_list_get_float(getLC(p, 1), adjusted));
}
fn ring_GetString(p: *anyopaque) callconv(.c) void {
    const idx: usize = @intFromFloat(g(p, 2));
    const adjusted = if (idx > 0) idx - 1 else 0;
    var buf: [8192]u8 = undefined;
    const n = list.stz_list_get_string(getLC(p, 1), adjusted, &buf, 8192);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}

// Find (INDEX_BASE=1: return 1-based, 0 for not-found)
fn ring_FindCS(p: *anyopaque) callconv(.c) void {
    const result = list.stz_list_find_first_cs(getLC(p, 1), getV(p, 2), @intFromFloat(g(p, 3)));
    rn(p, if (result >= 0) @as(f64, @floatFromInt(result + 1)) else 0);
}
fn ring_FindStringCS(p: *anyopaque) callconv(.c) void {
    const result = list.stz_list_find_first_string_cs(getLC(p, 1), gs(p, 2), @intCast(gss(p, 2)), @intFromFloat(g(p, 3)));
    rn(p, if (result >= 0) @as(f64, @floatFromInt(result + 1)) else 0);
}
fn ring_ContainsCS(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_contains_cs(getLC(p, 1), getV(p, 2), @intFromFloat(g(p, 3)))));
}
fn ring_CountCS(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_count_cs(getLC(p, 1), getV(p, 2), @intFromFloat(g(p, 3)))));
}

// Sort
fn ring_SortCS(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_sort_cs(getL(p, 1), @intFromFloat(g(p, 2)))));
}
fn ring_Sort(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_sort(getL(p, 1))));
}
fn ring_SortDescendingCS(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_sort_descending_cs(getL(p, 1), @intFromFloat(g(p, 2)))));
}
fn ring_SortDescending(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_sort_descending(getL(p, 1))));
}

// Reverse
fn ring_Reverse(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_reverse(getL(p, 1))));
}

// Deduplicate
fn ring_UniqueCS(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_unique_cs(getLC(p, 1), @intFromFloat(g(p, 2)))), HL);
}
fn ring_RemoveDuplicatesCS(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_remove_duplicates_cs(getL(p, 1), @intFromFloat(g(p, 2)))));
}

// Clone / Slice
fn ring_Clone(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_clone(getLC(p, 1))), HL);
}
fn ring_Slice(p: *anyopaque) callconv(.c) void {
    const start: usize = @intFromFloat(g(p, 2));
    const end: usize = @intFromFloat(g(p, 3));
    const adj_start = if (start > 0) start - 1 else 0;
    const adj_end = if (end > 0) end else 0;
    rcp(p, @ptrCast(list.stz_list_slice(getLC(p, 1), adj_start, adj_end)), HL);
}

// Clear
fn ring_Clear(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_clear(getL(p, 1))));
}

// Set (INDEX_BASE=1: subtract 1)
fn ring_Set(p: *anyopaque) callconv(.c) void {
    const idx: usize = @intFromFloat(g(p, 2));
    const adjusted = if (idx > 0) idx - 1 else 0;
    rn(p, @floatFromInt(list.stz_list_set(getL(p, 1), adjusted, getV(p, 3))));
}

// Flatten
fn ring_Flatten(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_flatten(getLC(p, 1))), HL);
}

// Type query
fn ring_ItemType(p: *anyopaque) callconv(.c) void {
    const idx: usize = @intFromFloat(g(p, 2));
    const adjusted = if (idx > 0) idx - 1 else 0;
    rn(p, @floatFromInt(list.stz_list_item_type(getLC(p, 1), adjusted)));
}
fn ring_IsAllStrings(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_is_all_strings(getLC(p, 1))));
}
fn ring_IsAllNumbers(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_is_all_numbers(getLC(p, 1))));
}

// Equality
fn ring_EqualsCS(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_equals_cs(getLC(p, 1), getLC(p, 2), @intFromFloat(g(p, 3)))));
}

// Expression-based operations (Map/Filter/Reduce/FindW)
fn ring_MapExpr(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_map_expr(getLC(p, 1), gs(p, 2), @intCast(gss(p, 2)))), HL);
}
fn ring_FilterExpr(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_filter_expr(getLC(p, 1), gs(p, 2), @intCast(gss(p, 2)))), HL);
}
// Return the reduce result as a PLAIN scalar, extracted in-DLL. Passing the
// StzValue across the stz_list <-> stz_value DLL boundary as a handle is the
// cross-DLL handle trap (init handle panicked; result handle read back as 0).
fn retReduceValue(p: *anyopaque, r: ?*value.StzValue) void {
    const v = r orelse {
        rn(p, 0);
        return;
    };
    switch (v.tag) {
        .int_val => rn(p, @floatFromInt(v.data.int_val)),
        .float_val => rn(p, v.data.float_val),
        .string_val => rs2(p, @ptrCast(v.data.string_val.ptr), @intCast(v.data.string_val.len)),
        else => rn(p, 0),
    }
    value.stz_value_free(v);
}
fn ring_ReduceExpr(p: *anyopaque) callconv(.c) void {
    // Build the init value INSIDE this DLL from a raw number (arg 3).
    const initv = value.stz_value_new_int(@intFromFloat(g(p, 3)));
    const r = list.stz_list_reduce_expr(getLC(p, 1), gs(p, 2), @intCast(gss(p, 2)), initv);
    if (initv) |iv| value.stz_value_free(iv);
    retReduceValue(p, r);
}
fn ring_ReduceExprNoInit(p: *anyopaque) callconv(.c) void {
    retReduceValue(p, list.stz_list_reduce_expr(getLC(p, 1), gs(p, 2), @intCast(gss(p, 2)), null));
}
fn ring_FindW(p: *anyopaque) callconv(.c) void {
    const result = list.stz_list_find_first_w(getLC(p, 1), gs(p, 2), @intCast(gss(p, 2)));
    rn(p, if (result >= 0) @as(f64, @floatFromInt(result + 1)) else 0);
}
fn ring_FindAllCS(p: *anyopaque) callconv(.c) void {
    var positions: [65536]i64 = undefined;
    const count = list.stz_list_find_cs(getLC(p, 1), getV(p, 2), @intFromFloat(g(p, 3)), &positions, 65536);
    retPositions(p, positions[0..count]);
}
fn ring_FindAllStringCS(p: *anyopaque) callconv(.c) void {
    const l = getLC(p, 1) orelse {
        rcp(p, @as(?*anyopaque, null), HL);
        return;
    };
    const needle_ptr = gs(p, 2);
    const needle_len: usize = @intCast(gss(p, 2));
    const cs: i32 = @intFromFloat(g(p, 3));
    const needle_val = value.stz_value_new_string(needle_ptr, needle_len) orelse {
        rcp(p, @as(?*anyopaque, null), HL);
        return;
    };
    defer value.stz_value_free(needle_val);
    var positions: [65536]i64 = undefined;
    const count = list.stz_list_find_cs(l, needle_val, cs, &positions, 65536);
    const result = list.StzList.init() catch {
        rcp(p, @as(?*anyopaque, null), HL);
        return;
    };
    for (0..count) |ci| {
        _ = list.stz_list_append_int(result, positions[ci] + 1);
    }
    rcp(p, @ptrCast(result), HL);
}

fn ring_CountStringCS(p: *anyopaque) callconv(.c) void {
    const l = getLC(p, 1) orelse {
        rn(p, 0);
        return;
    };
    const needle_ptr = gs(p, 2);
    const needle_len: usize = @intCast(gss(p, 2));
    const cs: i32 = @intFromFloat(g(p, 3));
    const needle_val = value.stz_value_new_string(needle_ptr, needle_len) orelse {
        rn(p, 0);
        return;
    };
    defer value.stz_value_free(needle_val);
    rn(p, @floatFromInt(list.stz_list_count_cs(l, needle_val, cs)));
}
fn ring_ContainsStringCS(p: *anyopaque) callconv(.c) void {
    const l = getLC(p, 1) orelse {
        rn(p, 0);
        return;
    };
    const needle_ptr = gs(p, 2);
    const needle_len: usize = @intCast(gss(p, 2));
    const cs: i32 = @intFromFloat(g(p, 3));
    const needle_val = value.stz_value_new_string(needle_ptr, needle_len) orelse {
        rn(p, 0);
        return;
    };
    defer value.stz_value_free(needle_val);
    rn(p, @floatFromInt(list.stz_list_contains_cs(l, needle_val, cs)));
}

fn ring_FindAllW(p: *anyopaque) callconv(.c) void {
    var positions: [65536]i64 = undefined;
    const count = list.stz_list_find_w(getLC(p, 1), gs(p, 2), @intCast(gss(p, 2)), &positions, 65536);
    retPositions(p, positions[0..count]);
}
fn ring_CountW(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_count_w(getLC(p, 1), gs(p, 2), @intCast(gss(p, 2)))));
}

// Sort by expression: ring_SortByExpr(handle, expr_string, ascending_flag)
fn ring_SortByExpr(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_sort_by_expr(getL(p, 1), gs(p, 2), @intCast(gss(p, 2)), @intFromFloat(g(p, 3)))));
}

// Zip / Interleave / Partition
fn ring_GetSubList(p: *anyopaque) callconv(.c) void {
    const idx: usize = @intFromFloat(g(p, 2));
    const adjusted = if (idx > 0) idx - 1 else 0;
    rcp(p, @ptrCast(list.stz_list_get_sublist(getLC(p, 1), adjusted)), HL);
}
fn ring_Zip(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_zip(getLC(p, 1), getLC(p, 2))), HL);
}
fn ring_Interleave(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_interleave(getLC(p, 1), getLC(p, 2))), HL);
}
fn ring_Partition(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_partition(getLC(p, 1), @intFromFloat(g(p, 2)))), HL);
}
fn ring_RotateLeft(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_rotate_left(getL(p, 1), @intFromFloat(g(p, 2)))));
}
fn ring_RotateRight(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_rotate_right(getL(p, 1), @intFromFloat(g(p, 2)))));
}
fn ring_Chunked(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_chunked(getLC(p, 1), @intFromFloat(g(p, 2)))), HL);
}
fn ring_Paired(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_paired(getLC(p, 1))), HL);
}
fn ring_DeepFlatten(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_deep_flatten(getLC(p, 1))), HL);
}
fn ring_FlattenToDepth(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_flatten_to_depth(getLC(p, 1), @intFromFloat(g(p, 2)))), HL);
}

fn ring_SortOn(p: *anyopaque) callconv(.c) void {
    const col = @as(usize, @intFromFloat(g(p, 2)));
    const col0 = if (col > 0) col - 1 else 0;
    rn(p, @floatFromInt(list.stz_list_sort_on(getL(p, 1), col0)));
}

fn ring_IsSortedAscending(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_is_sorted_ascending(getLC(p, 1))));
}

fn ring_IsSortedDescending(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_is_sorted_descending(getLC(p, 1))));
}

fn ring_Repeat(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_repeat(getLC(p, 1), @intFromFloat(g(p, 2)))), HL);
}

fn ring_Shuffle(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_shuffle(getL(p, 1))));
}

fn ring_RandomItem(p: *anyopaque) callconv(.c) void {
    if (list.stz_list_random_item(getLC(p, 1))) |v| {
        rcp(p, @ptrCast(@constCast(v)), HL);
    } else {
        rs(p, "");
    }
}

fn ring_RandomItems(p: *anyopaque) callconv(.c) void {
    const count = @as(usize, @intFromFloat(g(p, 2)));
    rcp(p, @ptrCast(list.stz_list_random_items(getLC(p, 1), count)), HL);
}

fn ring_Section(p: *anyopaque) callconv(.c) void {
    const from = @as(usize, @intFromFloat(g(p, 2)));
    const to = @as(usize, @intFromFloat(g(p, 3)));
    const from0 = if (from > 0) from - 1 else 0;
    const to0 = if (to > 0) to - 1 else 0;
    rcp(p, @ptrCast(list.stz_list_section(getLC(p, 1), from0, to0)), HL);
}

fn ring_Swap(p: *anyopaque) callconv(.c) void {
    const si = @as(usize, @intFromFloat(g(p, 2)));
    const sj = @as(usize, @intFromFloat(g(p, 3)));
    const si0 = if (si > 0) si - 1 else 0;
    const sj0 = if (sj > 0) sj - 1 else 0;
    rn(p, @floatFromInt(list.stz_list_swap(getL(p, 1), si0, sj0)));
}

// String expression operations
fn ring_StringFindCharsW(p: *anyopaque) callconv(.c) void {
    var buf: [65536]u8 = undefined;
    const n = list.stz_string_find_chars_w(gs(p, 1), @intCast(gss(p, 1)), gs(p, 2), @intCast(gss(p, 2)), &buf, 65536);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}

fn ring_StringMapChars(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_string_map_chars(gs(p, 1), @intCast(gss(p, 1)), gs(p, 2), @intCast(gss(p, 2)))), HL);
}

fn ring_StringCountCharsW(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_string_count_chars_w(gs(p, 1), @intCast(gss(p, 1)), gs(p, 2), @intCast(gss(p, 2)))));
}

// Duplicate analysis
// Build & return a ready Ring list of 1-based positions from an engine
// StzList of 0-based ints (Zig-side), freeing the temporary StzList.
fn retPositionsFromList(p: *anyopaque, maybe_list: ?*list.StzList) void {
    const out = R.ring_vm_api_newlist(p) orelse {
        if (maybe_list) |l| list.stz_list_free(l);
        return;
    };
    if (maybe_list) |l| {
        defer list.stz_list_free(l);
        const count = list.stz_list_len(l);
        for (0..count) |ci| {
            R.ring_list_adddouble(out, @floatFromInt(list.stz_list_get_int(l, ci) + 1));
        }
    }
    R.ring_vm_api_retlist(p, out);
}

fn ring_FindDuplicatesCS(p: *anyopaque) callconv(.c) void {
    retPositionsFromList(p, list.stz_list_find_duplicates_cs(getLC(p, 1), @intFromFloat(g(p, 2))));
}

fn ring_FindNonDuplicatedCS(p: *anyopaque) callconv(.c) void {
    retPositionsFromList(p, list.stz_list_find_non_duplicated_cs(getLC(p, 1), @intFromFloat(g(p, 2))));
}

fn ring_AllUniqueCS(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_all_unique_cs(getLC(p, 1), @intFromFloat(g(p, 2)))));
}

// Classify / Frequencies
fn ring_ClassifyCS(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_classify_cs(getLC(p, 1), @intFromFloat(g(p, 2)))), HL);
}
fn ring_FrequenciesCS(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_frequencies_cs(getLC(p, 1), @intFromFloat(g(p, 2)))), HL);
}

// Set operations
fn ring_IntersectionCS(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_intersection_cs(getLC(p, 1), getLC(p, 2), @intFromFloat(g(p, 3)))), HL);
}
fn ring_CommonItemsCS(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_common_items_cs(getLC(p, 1), getLC(p, 2), @intFromFloat(g(p, 3)))), HL);
}
fn ring_UnionCS(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_union_cs(getLC(p, 1), getLC(p, 2), @intFromFloat(g(p, 3)))), HL);
}
fn ring_DifferenceCS(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_difference_cs(getLC(p, 1), getLC(p, 2), @intFromFloat(g(p, 3)))), HL);
}
fn ring_ModifiedItemsCS(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_modified_items_cs(getLC(p, 1), getLC(p, 2), @intFromFloat(g(p, 3)))), HL);
}
fn ring_IsSubsetCS(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_is_subset_cs(getLC(p, 1), getLC(p, 2), @intFromFloat(g(p, 3)))));
}

// Trim
fn ring_TrimLeadingString(p: *anyopaque) callconv(.c) void {
    const l = getL(p, 1) orelse return rn(p, -1);
    const s = gs(p, 2);
    const slen = gss(p, 2);
    const v = value.stz_value_new_string(s, @intCast(slen)) orelse return rn(p, -1);
    defer value.stz_value_free(v);
    rn(p, @floatFromInt(list.stz_list_trim_leading(l, v)));
}
fn ring_TrimTrailingString(p: *anyopaque) callconv(.c) void {
    const l = getL(p, 1) orelse return rn(p, -1);
    const s = gs(p, 2);
    const slen = gss(p, 2);
    const v = value.stz_value_new_string(s, @intCast(slen)) orelse return rn(p, -1);
    defer value.stz_value_free(v);
    rn(p, @floatFromInt(list.stz_list_trim_trailing(l, v)));
}
fn ring_TrimString(p: *anyopaque) callconv(.c) void {
    const l = getL(p, 1) orelse return rn(p, -1);
    const s = gs(p, 2);
    const slen = gss(p, 2);
    const v = value.stz_value_new_string(s, @intCast(slen)) orelse return rn(p, -1);
    defer value.stz_value_free(v);
    rn(p, @floatFromInt(list.stz_list_trim(l, v)));
}

// Null-delimited
fn ring_FromNullDelimited(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_from_null_delimited(gs(p, 1), @intCast(gss(p, 1)))), HL);
}
fn ring_ToNullDelimited(p: *anyopaque) callconv(.c) void {
    var buf: [65536]u8 = undefined;
    const n = list.stz_list_to_null_delimited(getLC(p, 1), &buf, 65536);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}

// Leading / Trailing
fn ring_LeadingCountCS(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_leading_count_cs(getLC(p, 1), @intFromFloat(g(p, 2)))));
}
fn ring_TrailingCountCS(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_trailing_count_cs(getLC(p, 1), @intFromFloat(g(p, 2)))));
}
fn ring_StartsWithCS(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_starts_with_cs(getLC(p, 1), getV(p, 2), @intFromFloat(g(p, 3)))));
}
fn ring_EndsWithCS(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_ends_with_cs(getLC(p, 1), getV(p, 2), @intFromFloat(g(p, 3)))));
}
fn ring_RemoveLeadingCS(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_remove_leading_cs(getL(p, 1), @intFromFloat(g(p, 2)))));
}
fn ring_RemoveTrailingCS(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_remove_trailing_cs(getL(p, 1), @intFromFloat(g(p, 2)))));
}
fn ring_SplitAt(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_split_at(getLC(p, 1), getLC(p, 2))), HL);
}
// SplitBefore (INDEX_BASE=1: subtract 1)
fn ring_SplitBefore(p: *anyopaque) callconv(.c) void {
    const pos: usize = @intFromFloat(g(p, 2));
    const adjusted = if (pos > 0) pos - 1 else 0;
    rcp(p, @ptrCast(list.stz_list_split_before(getLC(p, 1), adjusted)), HL);
}
// SplitAfter (INDEX_BASE=1: subtract 1)
fn ring_SplitAfter(p: *anyopaque) callconv(.c) void {
    const pos: usize = @intFromFloat(g(p, 2));
    const adjusted = if (pos > 0) pos - 1 else 0;
    rcp(p, @ptrCast(list.stz_list_split_after(getLC(p, 1), adjusted)), HL);
}
fn ring_SplitToPartsOfN(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_split_to_parts_of_n(getLC(p, 1), @intFromFloat(g(p, 2)))), HL);
}
fn ring_SlidingWindow(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_sliding_window(getLC(p, 1), @intFromFloat(g(p, 2)))), HL);
}
fn ring_AntiSections(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_anti_sections(getLC(p, 1), getLC(p, 2))), HL);
}
fn ring_StartsWithListCS(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_starts_with_list_cs(getLC(p, 1), getLC(p, 2), @intFromFloat(g(p, 3)))));
}
fn ring_EndsWithListCS(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_ends_with_list_cs(getLC(p, 1), getLC(p, 2), @intFromFloat(g(p, 3)))));
}
fn ring_SortedInsert(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_sorted_insert(getL(p, 1), getV(p, 2))));
}
// Type-specific sorted inserts -- build the value inside this DLL (no
// cross-DLL value handle, which doesn't resolve in the list DLL).
fn ring_SortedInsertInt(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_sorted_insert_int(getL(p, 1), @intFromFloat(g(p, 2)))));
}
fn ring_SortedInsertFloat(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_sorted_insert_float(getL(p, 1), g(p, 2))));
}
fn ring_SortedInsertString(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_sorted_insert_string(getL(p, 1), gs(p, 2), @intCast(gss(p, 2)))));
}
fn ring_Sum(p: *anyopaque) callconv(.c) void {
    rn(p, list.stz_list_sum(getLC(p, 1)));
}
fn ring_Min(p: *anyopaque) callconv(.c) void {
    rn(p, list.stz_list_min(getLC(p, 1)));
}
fn ring_Max(p: *anyopaque) callconv(.c) void {
    rn(p, list.stz_list_max(getLC(p, 1)));
}
fn ring_Product(p: *anyopaque) callconv(.c) void {
    rn(p, list.stz_list_product(getLC(p, 1)));
}
fn ring_Mean(p: *anyopaque) callconv(.c) void {
    rn(p, list.stz_list_mean(getLC(p, 1)));
}
fn ring_Join(p: *anyopaque) callconv(.c) void {
    var buf: [65536]u8 = undefined;
    const n = list.stz_list_join(getLC(p, 1), gs(p, 2), @intCast(gss(p, 2)), &buf, 65536);
    rs2(p, &buf, @intCast(n));
}

// Checker functions
fn ring_IsAllLists(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_is_all_lists(getLC(p, 1))));
}
fn ring_IsAllPairs(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_is_all_pairs(getLC(p, 1))));
}
fn ring_IsAllSections(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_is_all_sections(getLC(p, 1))));
}
fn ring_IsHybrid(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_is_hybrid(getLC(p, 1))));
}
fn ring_AllItemsEqualCS(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_all_items_equal_cs(getLC(p, 1), @intFromFloat(g(p, 2)))));
}
fn ring_IsPalindromeCS(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_is_palindrome_cs(getLC(p, 1), @intFromFloat(g(p, 2)))));
}
fn ring_IsContinuous(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_is_continuous(getLC(p, 1))));
}
fn ring_IsAllListsSameSize(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_is_all_lists_same_size(getLC(p, 1))));
}
fn ring_IsStrictlyIncreasing(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_is_strictly_increasing(getLC(p, 1))));
}
fn ring_IsStrictlyDecreasing(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_is_strictly_decreasing(getLC(p, 1))));
}
fn ring_IsMonotonic(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_is_monotonic(getLC(p, 1))));
}

// Find nth/last
fn ring_FindNthCS(p: *anyopaque) callconv(.c) void {
    const nth = @as(usize, @intFromFloat(g(p, 3)));
    const adj_nth = if (nth > 0) nth - 1 else 0; // INDEX_BASE=1 (nth is 1-based)
    const result = list.stz_list_find_nth_cs(getLC(p, 1), getV(p, 2), adj_nth, @intFromFloat(g(p, 4)));
    rn(p, if (result >= 0) @as(f64, @floatFromInt(result + 1)) else 0); // INDEX_BASE=1
}
fn ring_FindLastCS(p: *anyopaque) callconv(.c) void {
    const result = list.stz_list_find_last_cs(getLC(p, 1), getV(p, 2), @intFromFloat(g(p, 3)));
    rn(p, if (result >= 0) @as(f64, @floatFromInt(result + 1)) else 0); // INDEX_BASE=1
}

// Statistics functions
fn ring_Median(p: *anyopaque) callconv(.c) void {
    rn(p, list.stz_list_median(getLC(p, 1)));
}
fn ring_NthSmallest(p: *anyopaque) callconv(.c) void {
    const n = @as(usize, @intFromFloat(g(p, 2)));
    const adj = if (n > 0) n - 1 else 0; // INDEX_BASE=1
    rn(p, list.stz_list_nth_smallest(getLC(p, 1), adj));
}
fn ring_NthLargest(p: *anyopaque) callconv(.c) void {
    const n = @as(usize, @intFromFloat(g(p, 2)));
    const adj = if (n > 0) n - 1 else 0; // INDEX_BASE=1
    rn(p, list.stz_list_nth_largest(getLC(p, 1), adj));
}
fn ring_Variance(p: *anyopaque) callconv(.c) void {
    rn(p, list.stz_list_variance(getLC(p, 1)));
}
fn ring_StdDev(p: *anyopaque) callconv(.c) void {
    rn(p, list.stz_list_stddev(getLC(p, 1)));
}
fn ring_Ranked(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_ranked(getLC(p, 1))), HL);
}

fn ring_ReplaceManyCS(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_replace_many_cs(getL(p, 1), getLC(p, 2), getLC(p, 3), @intFromFloat(g(p, 4)))));
}

fn ring_CountEmptyStrings(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_count_empty_strings(getLC(p, 1))));
}

fn ring_FindEmptyStrings(p: *anyopaque) callconv(.c) void {
    const result = list.stz_list_find_empty_strings(getLC(p, 1));
    // Result contains 0-based positions; add INDEX_BASE=1 adjustment
    if (result) |r| {
        for (r.items.items) |item| {
            if (item.tag == .int_val) {
                item.data.int_val += 1; // INDEX_BASE=1
            }
        }
    }
    rcp(p, @ptrCast(result), HL);
}

// Bulk-load: read a Ring list directly in Zig — one FFI call replaces N per-element calls
const ITEMTYPE_STRING: c_uint = 1;
const ITEMTYPE_NUMBER: c_uint = 2;
const ITEMTYPE_LIST: c_uint = 4;

// A Ring object is internally a list, so ring_list_gettype reports it as
// ITEMTYPE_LIST. To keep the engine from descending into an object's
// attribute fields during marshaling (deep-walk, DeepLists, etc.) we detect
// the object shape: item 1 is ["self", ...] and item 2 is ["super", ...].
fn ringSubItemFirstStringEql(pList: *anyopaque, idx: c_uint, expected: []const u8) bool {
    if (R.ring_list_gettype_gc(null, pList, idx) != ITEMTYPE_LIST) return false;
    const pSub = R.ring_list_getlist_gc(null, pList, idx) orelse return false;
    if (R.ringListSize(pSub) < 1) return false;
    if (R.ring_list_gettype_gc(null, pSub, 1) != ITEMTYPE_STRING) return false;
    const pItem = R.ring_list_getitem_gc(null, pSub, 1) orelse return false;
    const sPtr = R.ringItemStringPtr(pItem) orelse return false;
    const sLen = R.ringItemStringSize(pItem);
    return std.mem.eql(u8, sPtr[0..@intCast(sLen)], expected);
}

fn isRingObjectList(pList: *anyopaque) bool {
    if (R.ringListSize(pList) < 2) return false;
    return ringSubItemFirstStringEql(pList, 1, "self") and
        ringSubItemFirstStringEql(pList, 2, "super");
}

fn marshalRingListToValue(pRingList: *anyopaque) ?*value.StzValue {
    const nSize = R.ringListSize(pRingList);
    const vList = value.stz_value_new_list() orelse return null;
    var i: c_uint = 1;
    while (i <= nSize) : (i += 1) {
        const itemType = R.ring_list_gettype_gc(null, pRingList, i);
        const pItem = R.ring_list_getitem_gc(null, pRingList, i) orelse continue;
        if (itemType == ITEMTYPE_NUMBER) {
            const num = R.ring_item_getnumber(pItem);
            const iVal: i64 = @intFromFloat(num);
            const vItem = if (@as(f64, @floatFromInt(iVal)) == num)
                value.stz_value_new_int(iVal)
            else
                value.stz_value_new_float(num);
            if (vItem) |vi| {
                _ = value.stz_value_list_append(vList, vi);
                value.stz_value_free(vi);
            }
        } else if (itemType == ITEMTYPE_STRING) {
            const sPtr = R.ringItemStringPtr(pItem) orelse continue;
            const sLen = R.ringItemStringSize(pItem);
            const vItem = value.stz_value_new_string(sPtr, @intCast(sLen));
            if (vItem) |vi| {
                _ = value.stz_value_list_append(vList, vi);
                value.stz_value_free(vi);
            }
        } else if (itemType == ITEMTYPE_LIST) {
            const pSubList = R.ring_list_getlist_gc(null, pRingList, i) orelse continue;
            if (isRingObjectList(pSubList)) {
                // Objects are opaque leaves -- do not descend into their fields.
                const vNull = value.stz_value_new_null();
                if (vNull) |vn| {
                    _ = value.stz_value_list_append(vList, vn);
                    value.stz_value_free(vn);
                }
            } else {
                const subVal = marshalRingListToValue(pSubList);
                if (subVal) |sv| {
                    _ = value.stz_value_list_append(vList, sv);
                    value.stz_value_free(sv);
                }
            }
        }
    }
    return vList;
}

fn marshalRingList(pRingList: *anyopaque) ?*list.StzList {
    const nSize = R.ringListSize(pRingList);
    if (nSize == 0) return list.stz_list_new();
    const result = list.stz_list_new() orelse return null;
    var i: c_uint = 1;
    while (i <= nSize) : (i += 1) {
        const itemType = R.ring_list_gettype_gc(null, pRingList, i);
        const pItem = R.ring_list_getitem_gc(null, pRingList, i) orelse continue;
        if (itemType == ITEMTYPE_NUMBER) {
            const num = R.ring_item_getnumber(pItem);
            const iVal: i64 = @intFromFloat(num);
            if (@as(f64, @floatFromInt(iVal)) == num) {
                _ = list.stz_list_append_int(result, iVal);
            } else {
                _ = list.stz_list_append_float(result, num);
            }
        } else if (itemType == ITEMTYPE_STRING) {
            const sPtr = R.ringItemStringPtr(pItem) orelse continue;
            const sLen = R.ringItemStringSize(pItem);
            _ = list.stz_list_append_string(result, sPtr, @intCast(sLen));
        } else if (itemType == ITEMTYPE_LIST) {
            const pSubList = R.ring_list_getlist_gc(null, pRingList, i) orelse continue;
            if (isRingObjectList(pSubList)) {
                // Objects are opaque leaves -- do not descend into their fields.
                const vNull = value.stz_value_new_null();
                if (vNull) |vn| {
                    _ = list.stz_list_append_value(result, vn);
                    value.stz_value_free(vn);
                }
            } else {
                const subVal = marshalRingListToValue(pSubList);
                if (subVal) |sv| {
                    _ = list.stz_list_append_value(result, sv);
                    value.stz_value_free(sv);
                }
            }
        }
    }
    return result;
}

// Deep (nested) list / path API -- recursion runs in the engine.
fn ring_DeepPaths(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_deep_paths(getLC(p, 1))), HL);
}
fn ring_DeepFind(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_deep_find(getLC(p, 1), getLC(p, 2), @intFromFloat(g(p, 3)))), HL);
}
fn ring_ItemAtPath(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_item_at_path(getLC(p, 1), getLC(p, 2))), HL);
}
fn ring_ItemsAtPaths(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_items_at_paths(getLC(p, 1), getLC(p, 2))), HL);
}
fn ring_PathsAtDepth(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_paths_at_depth(getLC(p, 1), @intFromFloat(g(p, 2)))), HL);
}
fn ring_LongestPaths(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_longest_paths(getLC(p, 1))), HL);
}
fn ring_ExpandPath(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_expand_path(getLC(p, 1), getLC(p, 2))), HL);
}

fn ring_MarshalFromRingList(p: *anyopaque) callconv(.c) void {
    if (R.ring_vm_api_islist(p, 1) == 0) {
        rcp(p, @as(?*anyopaque, null), HL);
        return;
    }
    const pRingList = R.ring_vm_api_getlist(p, 1) orelse {
        rcp(p, @as(?*anyopaque, null), HL);
        return;
    };
    const result = marshalRingList(pRingList);
    if (result) |r| rcp(p, @ptrCast(r), HL) else rcp(p, @as(?*anyopaque, null), HL);
}

pub const regs = [_]R.Reg{
    .{ .name = "stzenginelistnew", .func = &ring_New },
    .{ .name = "stzenginelistfree", .func = &ring_Free },
    .{ .name = "stzenginelistlen", .func = &ring_Len },
    .{ .name = "stzenginelistappendint", .func = &ring_AppendInt },
    .{ .name = "stzenginelistappendfloat", .func = &ring_AppendFloat },
    .{ .name = "stzenginelistappendstring", .func = &ring_AppendString },
    .{ .name = "stzenginelistappendvalue", .func = &ring_AppendValue },
    .{ .name = "stzenginelistinsert", .func = &ring_Insert },
    .{ .name = "stzenginelistremove", .func = &ring_Remove },
    .{ .name = "stzenginelistremoveallcs", .func = &ring_RemoveAllCS },
    .{ .name = "stzenginelistreplaceallcs", .func = &ring_ReplaceAllCS },
    .{ .name = "stzenginelistreplaceallstringcs", .func = &ring_ReplaceAllStringCS },
    .{ .name = "stzenginelistremoveallstringcs", .func = &ring_RemoveAllStringCS },
    .{ .name = "stzenginelistsetstring", .func = &ring_SetString },
    .{ .name = "stzenginelistget", .func = &ring_Get },
    .{ .name = "stzenginelistgetint", .func = &ring_GetInt },
    .{ .name = "stzenginelistgetfloat", .func = &ring_GetFloat },
    .{ .name = "stzenginelistgetstring", .func = &ring_GetString },
    .{ .name = "stzenginelistfindcs", .func = &ring_FindCS },
    .{ .name = "stzenginelistfindstringcs", .func = &ring_FindStringCS },
    .{ .name = "stzenginelistcontainscs", .func = &ring_ContainsCS },
    .{ .name = "stzenginelistcountcs", .func = &ring_CountCS },
    .{ .name = "stzenginelistsortcs", .func = &ring_SortCS },
    .{ .name = "stzenginelistsort", .func = &ring_Sort },
    .{ .name = "stzenginelistsortdescendingcs", .func = &ring_SortDescendingCS },
    .{ .name = "stzenginelistsortdescending", .func = &ring_SortDescending },
    .{ .name = "stzenginelistreverse", .func = &ring_Reverse },
    .{ .name = "stzenginelistuniquecs", .func = &ring_UniqueCS },
    .{ .name = "stzenginelistremoveduplicatescs", .func = &ring_RemoveDuplicatesCS },
    .{ .name = "stzenginelistclone", .func = &ring_Clone },
    .{ .name = "stzenginelistslice", .func = &ring_Slice },
    .{ .name = "stzenginelistclear", .func = &ring_Clear },
    .{ .name = "stzenginelistset", .func = &ring_Set },
    .{ .name = "stzenginelistflatten", .func = &ring_Flatten },
    .{ .name = "stzenginelistitemtype", .func = &ring_ItemType },
    .{ .name = "stzenginelistisallstrings", .func = &ring_IsAllStrings },
    .{ .name = "stzenginelistisallnumbers", .func = &ring_IsAllNumbers },
    .{ .name = "stzenginelistequalscs", .func = &ring_EqualsCS },
    .{ .name = "stzenginelistmapexpr", .func = &ring_MapExpr },
    .{ .name = "stzenginelistfilterexpr", .func = &ring_FilterExpr },
    .{ .name = "stzenginelistreduceexpr", .func = &ring_ReduceExpr },
    .{ .name = "stzenginelistreduceexprnoinit", .func = &ring_ReduceExprNoInit },
    .{ .name = "stzenginelistfindallcs", .func = &ring_FindAllCS },
    .{ .name = "stzenginelistfindallstringcs", .func = &ring_FindAllStringCS },
    .{ .name = "stzenginelistcountstringcs", .func = &ring_CountStringCS },
    .{ .name = "stzenginelistcontainsstringcs", .func = &ring_ContainsStringCS },
    .{ .name = "stzenginelistfindw", .func = &ring_FindW },
    .{ .name = "stzenginelistfindallw", .func = &ring_FindAllW },
    .{ .name = "stzenginelistcountw", .func = &ring_CountW },
    .{ .name = "stzenginelistsortbyexpr", .func = &ring_SortByExpr },
    .{ .name = "stzenginestringfindcharsw", .func = &ring_StringFindCharsW },
    .{ .name = "stzenginestringmapchars", .func = &ring_StringMapChars },
    .{ .name = "stzenginestringcountcharsw", .func = &ring_StringCountCharsW },
    .{ .name = "stzenginelistclassifycs", .func = &ring_ClassifyCS },
    .{ .name = "stzenginelistfrequenciescs", .func = &ring_FrequenciesCS },
    .{ .name = "stzenginelistintersectioncs", .func = &ring_IntersectionCS },
    .{ .name = "stzenginelistcommonitemscs", .func = &ring_CommonItemsCS },
    .{ .name = "stzenginelistunioncs", .func = &ring_UnionCS },
    .{ .name = "stzenginelistdifferencecs", .func = &ring_DifferenceCS },
    .{ .name = "stzenginelistmodifieditemscs", .func = &ring_ModifiedItemsCS },
    .{ .name = "stzenginelistissubsetcs", .func = &ring_IsSubsetCS },
    .{ .name = "stzenginelistfindduplicatescs", .func = &ring_FindDuplicatesCS },
    .{ .name = "stzenginelistfindnonduplicatedcs", .func = &ring_FindNonDuplicatedCS },
    .{ .name = "stzenginelistalluniquecs", .func = &ring_AllUniqueCS },
    .{ .name = "stzenginelistgetsublist", .func = &ring_GetSubList },
    .{ .name = "stzenginelistzip", .func = &ring_Zip },
    .{ .name = "stzenginelistinterleave", .func = &ring_Interleave },
    .{ .name = "stzenginelistpartition", .func = &ring_Partition },
    .{ .name = "stzenginelistrotateleft", .func = &ring_RotateLeft },
    .{ .name = "stzenginelistrotateright", .func = &ring_RotateRight },
    .{ .name = "stzenginelistchunked", .func = &ring_Chunked },
    .{ .name = "stzenginelistpaired", .func = &ring_Paired },
    .{ .name = "stzenginelistdeepflatten", .func = &ring_DeepFlatten },
    .{ .name = "stzenginelistflattentodepth", .func = &ring_FlattenToDepth },
    .{ .name = "stzenginelistsorton", .func = &ring_SortOn },
    .{ .name = "stzenginelistissortedascending", .func = &ring_IsSortedAscending },
    .{ .name = "stzenginelistissorteddescending", .func = &ring_IsSortedDescending },
    .{ .name = "stzenginelistrepeat", .func = &ring_Repeat },
    .{ .name = "stzenginelistshuffle", .func = &ring_Shuffle },
    .{ .name = "stzenginelistrandomitems", .func = &ring_RandomItems },
    .{ .name = "stzenginelistsection", .func = &ring_Section },
    .{ .name = "stzenginelistswap", .func = &ring_Swap },
    .{ .name = "stzenginelisttrimleadingstring", .func = &ring_TrimLeadingString },
    .{ .name = "stzenginelisttrimtrailingstring", .func = &ring_TrimTrailingString },
    .{ .name = "stzenginelisttrimstring", .func = &ring_TrimString },
    .{ .name = "stzenginelistfromnulldelimited", .func = &ring_FromNullDelimited },
    .{ .name = "stzenginelisttonulldelimited", .func = &ring_ToNullDelimited },
    .{ .name = "stzenginelistleadingcountcs", .func = &ring_LeadingCountCS },
    .{ .name = "stzenginelisttrailingcountcs", .func = &ring_TrailingCountCS },
    .{ .name = "stzengineliststartswithcs", .func = &ring_StartsWithCS },
    .{ .name = "stzenginelistendswithcs", .func = &ring_EndsWithCS },
    .{ .name = "stzenginelistremoveleadingcs", .func = &ring_RemoveLeadingCS },
    .{ .name = "stzenginelistremovetrailingcs", .func = &ring_RemoveTrailingCS },
    .{ .name = "stzenginelistsplitat", .func = &ring_SplitAt },
    .{ .name = "stzenginelistsplitbefore", .func = &ring_SplitBefore },
    .{ .name = "stzenginelistsplitafter", .func = &ring_SplitAfter },
    .{ .name = "stzenginelistsplittopartsofn", .func = &ring_SplitToPartsOfN },
    .{ .name = "stzenginelistsortedinsert", .func = &ring_SortedInsert },
    .{ .name = "stzenginelistsortedinsertint", .func = &ring_SortedInsertInt },
    .{ .name = "stzenginelistsortedinsertfloat", .func = &ring_SortedInsertFloat },
    .{ .name = "stzenginelistsortedinsertstring", .func = &ring_SortedInsertString },
    .{ .name = "stzenginelistjoin", .func = &ring_Join },
    .{ .name = "stzenginelistsum", .func = &ring_Sum },
    .{ .name = "stzenginelistmin", .func = &ring_Min },
    .{ .name = "stzenginelistmax", .func = &ring_Max },
    .{ .name = "stzenginelistproduct", .func = &ring_Product },
    .{ .name = "stzenginelistmean", .func = &ring_Mean },
    .{ .name = "stzenginelistmarshalfromringlist", .func = &ring_MarshalFromRingList },
    .{ .name = "stzenginelistisalllists", .func = &ring_IsAllLists },
    .{ .name = "stzenginelistisallpairs", .func = &ring_IsAllPairs },
    .{ .name = "stzenginelistisallsections", .func = &ring_IsAllSections },
    .{ .name = "stzenginelistishybrid", .func = &ring_IsHybrid },
    .{ .name = "stzenginelistallitemsequalcs", .func = &ring_AllItemsEqualCS },
    .{ .name = "stzenginelistispalindromecs", .func = &ring_IsPalindromeCS },
    .{ .name = "stzenginelistiscontinuous", .func = &ring_IsContinuous },
    .{ .name = "stzenginelistisalllistssamesize", .func = &ring_IsAllListsSameSize },
    .{ .name = "stzenginelistisstrictlyincreasing", .func = &ring_IsStrictlyIncreasing },
    .{ .name = "stzenginelistisstrictlydecreasing", .func = &ring_IsStrictlyDecreasing },
    .{ .name = "stzenginelistismonotonic", .func = &ring_IsMonotonic },
    .{ .name = "stzenginelistmedian", .func = &ring_Median },
    .{ .name = "stzenginelistnthsmallest", .func = &ring_NthSmallest },
    .{ .name = "stzenginelistnthlargest", .func = &ring_NthLargest },
    .{ .name = "stzenginelistvariance", .func = &ring_Variance },
    .{ .name = "stzengineliststddev", .func = &ring_StdDev },
    .{ .name = "stzenginelistranked", .func = &ring_Ranked },
    .{ .name = "stzenginelistfindnthcs", .func = &ring_FindNthCS },
    .{ .name = "stzenginelistfindlastcs", .func = &ring_FindLastCS },
    .{ .name = "stzenginelistreplacemanycs", .func = &ring_ReplaceManyCS },
    .{ .name = "stzenginelistcountemptystrings", .func = &ring_CountEmptyStrings },
    .{ .name = "stzenginelistfindemptystrings", .func = &ring_FindEmptyStrings },
    .{ .name = "stzenginelistslidingwindow", .func = &ring_SlidingWindow },
    .{ .name = "stzenginelistantisections", .func = &ring_AntiSections },
    .{ .name = "stzengineliststartswithlistcs", .func = &ring_StartsWithListCS },
    .{ .name = "stzenginelistendswithlistcs", .func = &ring_EndsWithListCS },
    .{ .name = "stzenginelistdeeppaths", .func = &ring_DeepPaths },
    .{ .name = "stzenginelistdeepfind", .func = &ring_DeepFind },
    .{ .name = "stzenginelistitematpath", .func = &ring_ItemAtPath },
    .{ .name = "stzenginelistitemsatpaths", .func = &ring_ItemsAtPaths },
    .{ .name = "stzenginelistpathsatdepth", .func = &ring_PathsAtDepth },
    .{ .name = "stzenginelistlongestpaths", .func = &ring_LongestPaths },
    .{ .name = "stzenginelistexpandpath", .func = &ring_ExpandPath },
};

pub fn ringlib_init(pRingState: ?*anyopaque) callconv(.c) void {
    if (pRingState) |state| R.registerAll(state, &regs);
}
