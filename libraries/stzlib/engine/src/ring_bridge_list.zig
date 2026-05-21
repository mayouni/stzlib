const std = @import("std");
const list = @import("list.zig");
const value = @import("value.zig");
const R = @import("ring_api.zig");

const g = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const gcp = R.ring_vm_api_getcpointer;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring;
const rs2 = R.ring_vm_api_retstring2;
const rcp = R.ring_vm_api_retcpointer;

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

// Lifecycle
fn ring_New(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_new()), HL);
}
fn ring_Free(p: *anyopaque) callconv(.c) void {
    list.stz_list_free(getL(p, 1));
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
    rn(p, @floatFromInt(list.stz_list_remove(getL(p, 1), adjusted)));
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
    const result = list.stz_list_find_cs(getLC(p, 1), getV(p, 2), @intFromFloat(g(p, 3)));
    rn(p, if (result >= 0) @as(f64, @floatFromInt(result + 1)) else 0);
}
fn ring_FindStringCS(p: *anyopaque) callconv(.c) void {
    const result = list.stz_list_find_string_cs(getLC(p, 1), gs(p, 2), @intCast(gss(p, 2)), @intFromFloat(g(p, 3)));
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
fn ring_ReduceExpr(p: *anyopaque) callconv(.c) void {
    rcp(p, @constCast(@ptrCast(list.stz_list_reduce_expr(getLC(p, 1), gs(p, 2), @intCast(gss(p, 2)), getV(p, 3)))), HV);
}
fn ring_ReduceExprNoInit(p: *anyopaque) callconv(.c) void {
    rcp(p, @constCast(@ptrCast(list.stz_list_reduce_expr(getLC(p, 1), gs(p, 2), @intCast(gss(p, 2)), null))), HV);
}
fn ring_FindW(p: *anyopaque) callconv(.c) void {
    const result = list.stz_list_find_w(getLC(p, 1), gs(p, 2), @intCast(gss(p, 2)));
    rn(p, if (result >= 0) @as(f64, @floatFromInt(result + 1)) else 0);
}
fn ring_FindAllW(p: *anyopaque) callconv(.c) void {
    var positions: [65536]i64 = undefined;
    const count = list.stz_list_find_all_w(getLC(p, 1), gs(p, 2), @intCast(gss(p, 2)), &positions, 65536);
    if (count == 0) {
        rs(p, "");
        return;
    }
    var buf: [65536 * 12]u8 = undefined;
    var pos: usize = 0;
    for (0..count) |ci| {
        const val_1based = positions[ci] + 1;
        const slice = std.fmt.bufPrint(buf[pos..], "{d}", .{val_1based}) catch break;
        pos += slice.len;
        if (ci + 1 < count) {
            buf[pos] = ',';
            pos += 1;
        }
    }
    if (pos > 0) rs2(p, &buf, @intCast(pos)) else rs(p, "");
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
fn ring_FindDuplicatesCS(p: *anyopaque) callconv(.c) void {
    const dup_list = list.stz_list_find_duplicates_cs(getLC(p, 1), @intFromFloat(g(p, 2)));
    if (dup_list == null or list.stz_list_len(dup_list) == 0) {
        if (dup_list) |dl| list.stz_list_free(dl);
        rs(p, "");
        return;
    }
    const dl = dup_list.?;
    defer list.stz_list_free(dl);
    const count = list.stz_list_len(dl);
    var buf: [65536 * 12]u8 = undefined;
    var pos: usize = 0;
    for (0..count) |ci| {
        const val_1based = list.stz_list_get_int(dl, ci) + 1;
        const slice = std.fmt.bufPrint(buf[pos..], "{d}", .{val_1based}) catch break;
        pos += slice.len;
        if (ci + 1 < count) {
            buf[pos] = ',';
            pos += 1;
        }
    }
    if (pos > 0) rs2(p, &buf, @intCast(pos)) else rs(p, "");
}

fn ring_FindNonDuplicatedCS(p: *anyopaque) callconv(.c) void {
    const nd_list = list.stz_list_find_non_duplicated_cs(getLC(p, 1), @intFromFloat(g(p, 2)));
    if (nd_list == null or list.stz_list_len(nd_list) == 0) {
        if (nd_list) |nl| list.stz_list_free(nl);
        rs(p, "");
        return;
    }
    const nl = nd_list.?;
    defer list.stz_list_free(nl);
    const count = list.stz_list_len(nl);
    var buf: [65536 * 12]u8 = undefined;
    var pos: usize = 0;
    for (0..count) |ci| {
        const val_1based = list.stz_list_get_int(nl, ci) + 1;
        const slice = std.fmt.bufPrint(buf[pos..], "{d}", .{val_1based}) catch break;
        pos += slice.len;
        if (ci + 1 < count) {
            buf[pos] = ',';
            pos += 1;
        }
    }
    if (pos > 0) rs2(p, &buf, @intCast(pos)) else rs(p, "");
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
fn ring_UnionCS(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_union_cs(getLC(p, 1), getLC(p, 2), @intFromFloat(g(p, 3)))), HL);
}
fn ring_DifferenceCS(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(list.stz_list_difference_cs(getLC(p, 1), getLC(p, 2), @intFromFloat(g(p, 3)))), HL);
}
fn ring_IsSubsetCS(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(list.stz_list_is_subset_cs(getLC(p, 1), getLC(p, 2), @intFromFloat(g(p, 3)))));
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
    .{ .name = "stzenginelistunioncs", .func = &ring_UnionCS },
    .{ .name = "stzenginelistdifferencecs", .func = &ring_DifferenceCS },
    .{ .name = "stzenginelistissubsetcs", .func = &ring_IsSubsetCS },
    .{ .name = "stzenginelistfindduplicatescs", .func = &ring_FindDuplicatesCS },
    .{ .name = "stzenginelistfindnonduplicatedcs", .func = &ring_FindNonDuplicatedCS },
    .{ .name = "stzenginelistalluniquecs", .func = &ring_AllUniqueCS },
    .{ .name = "stzenginelistgetsublist", .func = &ring_GetSubList },
    .{ .name = "stzenginelistzip", .func = &ring_Zip },
    .{ .name = "stzenginelistinterleave", .func = &ring_Interleave },
    .{ .name = "stzenginelistpartition", .func = &ring_Partition },
    .{ .name = "stzenginelistfromnulldelimited", .func = &ring_FromNullDelimited },
    .{ .name = "stzenginelisttonulldelimited", .func = &ring_ToNullDelimited },
};

pub fn ringlib_init(pRingState: ?*anyopaque) callconv(.c) void {
    if (pRingState) |state| R.registerAll(state, &regs);
}
