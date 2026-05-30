const yielder = @import("yielder.zig");
const list_mod = @import("list.zig");
const StzList = list_mod.StzList;
const R = @import("ring_api.zig");
const value_mod = @import("value.zig");
const StzValue = value_mod.StzValue;

const STZ_HANDLE: [*:0]const u8 = "StzListHandle";

// Item-type codes used by the Ring runtime when introspecting a Ring list.
const ITEMTYPE_STRING: c_uint = 1;
const ITEMTYPE_NUMBER: c_uint = 2;
const ITEMTYPE_LIST: c_uint = 4;

const g = R.ring_vm_api_getnumber;
const rn = R.ring_vm_api_retnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rs2 = R.ring_vm_api_retstring2;

// Shadow the real cpointer functions: store/resolve via handle table.
fn rp(p: *anyopaque, ptr: ?*anyopaque, _: [*:0]const u8) void {
    R.retHandle(p, ptr);
}

fn gp(p: *anyopaque, n: c_int, _: [*:0]const u8) ?*anyopaque {
    return R.getHandle(p, n);
}

// Map: StzEngineYielderMap(handle, op) -> handle
fn ring_YielderMap(p: *anyopaque) callconv(.c) void {
    const h = gp(p, 1, STZ_HANDLE) orelse return;
    const op: u8 = @intFromFloat(g(p, 2));
    const result = yielder.stz_yielder_map(h, op);
    if (result) |r| {
        rp(p, r, STZ_HANDLE);
    } else {
        rp(p, null, STZ_HANDLE);
    }
}

// Filter: StzEngineYielderFilter(handle, op) -> handle
fn ring_YielderFilter(p: *anyopaque) callconv(.c) void {
    const h = gp(p, 1, STZ_HANDLE) orelse return;
    const op: u8 = @intFromFloat(g(p, 2));
    const result = yielder.stz_yielder_filter(h, op);
    if (result) |r| {
        rp(p, r, STZ_HANDLE);
    } else {
        rp(p, null, STZ_HANDLE);
    }
}

// Reduce: StzEngineYielderReduce(handle, op) -> number
fn ring_YielderReduce(p: *anyopaque) callconv(.c) void {
    const h = gp(p, 1, STZ_HANDLE) orelse return;
    const op: u8 = @intFromFloat(g(p, 2));
    rn(p, yielder.stz_yielder_reduce(h, op));
}

// ReduceConcat: StzEngineYielderReduceConcat(handle, sep) -> string
fn ring_YielderReduceConcat(p: *anyopaque) callconv(.c) void {
    const h = gp(p, 1, STZ_HANDLE) orelse return;
    const sep: [*]const u8 = @ptrCast(gs(p, 2));
    const sep_len: u32 = @intCast(gss(p, 2));
    const result = yielder.stz_yielder_reduce_concat(h, sep, sep_len);
    if (result) |r| {
        const val: *StzValue = @ptrCast(@alignCast(r));
        if (val.tag == .string_val) {
            rs2(p, @constCast(val.data.string_val.ptr), @intCast(val.data.string_val.len));
        } else {
            rs2(p, @constCast(""), 0);
        }
        val.deinit();
        @import("std").heap.c_allocator.destroy(val);
    } else {
        rs2(p, @constCast(""), 0);
    }
}

// FilterMap: StzEngineYielderFilterMap(handle, filter_op, transform_op) -> handle
fn ring_YielderFilterMap(p: *anyopaque) callconv(.c) void {
    const h = gp(p, 1, STZ_HANDLE) orelse return;
    const filter_op: u8 = @intFromFloat(g(p, 2));
    const transform_op: u8 = @intFromFloat(g(p, 3));
    const result = yielder.stz_yielder_filter_map(h, filter_op, transform_op);
    if (result) |r| {
        rp(p, r, STZ_HANDLE);
    } else {
        rp(p, null, STZ_HANDLE);
    }
}

// CountWhere: StzEngineYielderCountWhere(handle, op) -> number
fn ring_YielderCountWhere(p: *anyopaque) callconv(.c) void {
    const h = gp(p, 1, STZ_HANDLE) orelse return;
    const op: u8 = @intFromFloat(g(p, 2));
    rn(p, @floatFromInt(yielder.stz_yielder_count_where(h, op)));
}

// Free: StzEngineYielderFree(handle)
fn ring_YielderFree(p: *anyopaque) callconv(.c) void {
    const raw = R.releaseHandle(p, 1);
    if (raw) |ptr| {
        yielder.stz_yielder_free(ptr);
    }
}

// MapIndexed: StzEngineYielderMapIndexed(handle, op) -> handle
fn ring_YielderMapIndexed(p: *anyopaque) callconv(.c) void {
    const h = gp(p, 1, STZ_HANDLE) orelse return;
    const op: u8 = @intFromFloat(g(p, 2));
    const result = yielder.stz_yielder_map_indexed(h, op);
    if (result) |r| {
        rp(p, r, STZ_HANDLE);
    } else {
        rp(p, null, STZ_HANDLE);
    }
}

// ─── DIRECT BRIDGE: Ring list in / Ring list (or scalar) out ───
// These variants avoid the cross-DLL handle table problem (a handle
// minted in stz_list.dll can't be resolved in stz_yielder.dll). They
// take a Ring list directly, marshal it into a *StzList inside the
// yielder DLL, run the op, and either write the result back into a
// fresh Ring list (Map / Filter / FilterMap / MapIndexed) or return
// the scalar directly (Reduce / CountWhere / ReduceConcat).
//
// Same pattern as the session-43 string-direct list fix.

fn marshalRingListToValue(pRingList: *anyopaque) ?*StzValue {
    const nSize = R.ringListSize(pRingList);
    const vList = value_mod.stz_value_new_list() orelse return null;
    var i: c_uint = 1;
    while (i <= nSize) : (i += 1) {
        const itemType = R.ring_list_gettype_gc(null, pRingList, i);
        const pItem = R.ring_list_getitem_gc(null, pRingList, i) orelse continue;
        if (itemType == ITEMTYPE_NUMBER) {
            const num = R.ring_item_getnumber(pItem);
            const iVal: i64 = @intFromFloat(num);
            const vItem = if (@as(f64, @floatFromInt(iVal)) == num)
                value_mod.stz_value_new_int(iVal)
            else
                value_mod.stz_value_new_float(num);
            if (vItem) |vi| {
                _ = value_mod.stz_value_list_append(vList, vi);
                value_mod.stz_value_free(vi);
            }
        } else if (itemType == ITEMTYPE_STRING) {
            const sPtr = R.ringItemStringPtr(pItem) orelse continue;
            const sLen = R.ringItemStringSize(pItem);
            const vItem = value_mod.stz_value_new_string(sPtr, @intCast(sLen));
            if (vItem) |vi| {
                _ = value_mod.stz_value_list_append(vList, vi);
                value_mod.stz_value_free(vi);
            }
        } else if (itemType == ITEMTYPE_LIST) {
            const pSubList = R.ring_list_getlist_gc(null, pRingList, i) orelse continue;
            const subVal = marshalRingListToValue(pSubList);
            if (subVal) |sv| {
                _ = value_mod.stz_value_list_append(vList, sv);
                value_mod.stz_value_free(sv);
            }
        }
    }
    return vList;
}

// IMPORTANT: every internal call below uses a callconv(.c) function
// (stz_list_new / stz_list_append_* / stz_list_free etc). Calling
// regular `pub fn StzList.init()` directly from inside a callconv(.c)
// Ring bridge function crashes on Windows (Zig vs C calling-convention
// mismatch). All list manipulation goes through the C ABI exports.

fn marshalRingList(pRingList: *anyopaque) ?*anyopaque {
    const nSize = R.ringListSize(pRingList);
    const result = list_mod.stz_list_new() orelse return null;
    if (nSize == 0) return @ptrCast(result);
    var i: c_uint = 1;
    while (i <= nSize) : (i += 1) {
        const itemType = R.ring_list_gettype_gc(null, pRingList, i);
        const pItem = R.ring_list_getitem_gc(null, pRingList, i) orelse continue;
        if (itemType == ITEMTYPE_NUMBER) {
            const num = R.ring_item_getnumber(pItem);
            const iVal: i64 = @intFromFloat(num);
            if (@as(f64, @floatFromInt(iVal)) == num) {
                _ = list_mod.stz_list_append_int(result, iVal);
            } else {
                _ = list_mod.stz_list_append_float(result, num);
            }
        } else if (itemType == ITEMTYPE_STRING) {
            const sPtr = R.ringItemStringPtr(pItem) orelse continue;
            const sLen = R.ringItemStringSize(pItem);
            _ = list_mod.stz_list_append_string(result, sPtr, @intCast(sLen));
        } else if (itemType == ITEMTYPE_LIST) {
            const pSubList = R.ring_list_getlist_gc(null, pRingList, i) orelse continue;
            const subVal = marshalRingListToValue(pSubList);
            if (subVal) |sv| {
                _ = list_mod.stz_list_append_value(result, sv);
                value_mod.stz_value_free(sv);
            }
        }
    }
    return @ptrCast(result);
}

// Walks a StzValue and appends one Ring-list item that mirrors it.
fn unmarshalValueToRing(pRingList: *anyopaque, v: *const StzValue) void {
    switch (v.tag) {
        .null_val => R.ring_list_addstring2(pRingList, @constCast(""), 0),
        .int_val => R.ring_list_adddouble(pRingList, @floatFromInt(v.data.int_val)),
        .float_val => R.ring_list_adddouble(pRingList, v.data.float_val),
        .bool_val => R.ring_list_adddouble(pRingList, if (v.data.bool_val) 1.0 else 0.0),
        .string_val => {
            const s = v.data.string_val;
            if (s.len > 0) {
                R.ring_list_addstring2(pRingList, s.ptr, @intCast(s.len));
            } else {
                R.ring_list_addstring2(pRingList, @constCast(""), 0);
            }
        },
        .list_val => {
            const sub = R.ring_list_newlist(pRingList) orelse return;
            const ld = v.data.list_val;
            var i: usize = 0;
            while (i < ld.len) : (i += 1) {
                unmarshalValueToRing(sub, ld.items[i]);
            }
        },
    }
}

// Walks a *StzList via the C ABI exports + direct struct field reads
// and writes its items into a freshly-created Ring list. Function calls
// go through callconv(.c) entries (Zig vs C calling-convention mismatch
// crashes the DLL otherwise); struct field reads are bare memory access
// and are safe.
fn unmarshalListToRing(pRingList: *anyopaque, src: *anyopaque) void {
    const stzList: *StzList = @ptrCast(@alignCast(src));
    const n = list_mod.stz_list_len(stzList);
    var i: usize = 0;
    while (i < n) : (i += 1) {
        const item = stzList.items.items[i];
        switch (item.tag) {
            .null_val => R.ring_list_addstring2(pRingList, @constCast(""), 0),
            .int_val => R.ring_list_adddouble(pRingList, @floatFromInt(item.data.int_val)),
            .float_val => R.ring_list_adddouble(pRingList, item.data.float_val),
            .bool_val => R.ring_list_adddouble(pRingList, if (item.data.bool_val) 1.0 else 0.0),
            .string_val => {
                const s = item.data.string_val;
                if (s.len > 0) {
                    R.ring_list_addstring2(pRingList, s.ptr, @intCast(s.len));
                } else {
                    R.ring_list_addstring2(pRingList, @constCast(""), 0);
                }
            },
            .list_val => {
                // Nested list-valued items are flattened to "<list>"
                // marker for now; nested round-trip via value tree is
                // rare and not exercised by the yielder ops.
                R.ring_list_addstring2(pRingList, @constCast("<list>"), 6);
            },
        }
    }
}

// Helper -- read Ring list arg 1, marshal it, run a yielder op that
// produces a *StzList, write the result into a fresh Ring list, ret it.
// Inlined into each of the four list-returning direct variants below
// because Zig closures over function pointers + threadlocal stash were
// unreliable in the DLL.

fn runListOpInline(p: *anyopaque, raw_out: ?*anyopaque) void {
    const pOut = R.ring_vm_api_newlist(p) orelse return;
    if (raw_out) |r| {
        unmarshalListToRing(pOut, r);
        list_mod.stz_list_free(@ptrCast(@alignCast(r)));
    }
    R.ring_vm_api_retlist(p, pOut);
}

fn marshalArg1(p: *anyopaque) ?*anyopaque {
    if (R.ring_vm_api_islist(p, 1) == 0) return null;
    const pRingIn = R.ring_vm_api_getlist(p, 1) orelse return null;
    return marshalRingList(pRingIn);
}

fn ring_YielderMapDirect(p: *anyopaque) callconv(.c) void {
    const stzIn = marshalArg1(p) orelse {
        const empty = R.ring_vm_api_newlist(p) orelse return;
        R.ring_vm_api_retlist(p, empty);
        return;
    };
    defer list_mod.stz_list_free(@ptrCast(@alignCast(stzIn)));
    const op: u8 = @intFromFloat(g(p, 2));
    runListOpInline(p, yielder.stz_yielder_map(stzIn, op));
}

fn ring_YielderMapIndexedDirect(p: *anyopaque) callconv(.c) void {
    const stzIn = marshalArg1(p) orelse {
        const empty = R.ring_vm_api_newlist(p) orelse return;
        R.ring_vm_api_retlist(p, empty);
        return;
    };
    defer list_mod.stz_list_free(@ptrCast(@alignCast(stzIn)));
    const op: u8 = @intFromFloat(g(p, 2));
    runListOpInline(p, yielder.stz_yielder_map_indexed(@ptrCast(stzIn), op));
}

fn ring_YielderFilterDirect(p: *anyopaque) callconv(.c) void {
    const stzIn = marshalArg1(p) orelse {
        const empty = R.ring_vm_api_newlist(p) orelse return;
        R.ring_vm_api_retlist(p, empty);
        return;
    };
    defer list_mod.stz_list_free(@ptrCast(@alignCast(stzIn)));
    const op: u8 = @intFromFloat(g(p, 2));
    runListOpInline(p, yielder.stz_yielder_filter(@ptrCast(stzIn), op));
}

fn ring_YielderFilterMapDirect(p: *anyopaque) callconv(.c) void {
    const stzIn = marshalArg1(p) orelse {
        const empty = R.ring_vm_api_newlist(p) orelse return;
        R.ring_vm_api_retlist(p, empty);
        return;
    };
    defer list_mod.stz_list_free(@ptrCast(@alignCast(stzIn)));
    const filt_op: u8 = @intFromFloat(g(p, 2));
    const trans_op: u8 = @intFromFloat(g(p, 3));
    runListOpInline(p, yielder.stz_yielder_filter_map(@ptrCast(stzIn), filt_op, trans_op));
}

// Scalar-returning direct variants: marshal in, op, return scalar.

fn ring_YielderReduceDirect(p: *anyopaque) callconv(.c) void {
    const stzIn = marshalArg1(p) orelse { rn(p, 0); return; };
    defer list_mod.stz_list_free(@ptrCast(@alignCast(stzIn)));
    const op: u8 = @intFromFloat(g(p, 2));
    rn(p, yielder.stz_yielder_reduce(stzIn, op));
}

fn ring_YielderCountWhereDirect(p: *anyopaque) callconv(.c) void {
    if (R.ring_vm_api_islist(p, 1) == 0) {
        rn(p, 0);
        return;
    }
    const pRingIn = R.ring_vm_api_getlist(p, 1) orelse {
        rn(p, 0);
        return;
    };
    const stzIn = marshalRingList(pRingIn) orelse {
        rn(p, 0);
        return;
    };
    defer list_mod.stz_list_free(@ptrCast(@alignCast(stzIn)));
    const op: u8 = @intFromFloat(g(p, 2));
    rn(p, @floatFromInt(yielder.stz_yielder_count_where(@ptrCast(stzIn), op)));
}

fn ring_YielderReduceConcatDirect(p: *anyopaque) callconv(.c) void {
    if (R.ring_vm_api_islist(p, 1) == 0) {
        rs2(p, @constCast(""), 0);
        return;
    }
    const pRingIn = R.ring_vm_api_getlist(p, 1) orelse {
        rs2(p, @constCast(""), 0);
        return;
    };
    const stzIn = marshalRingList(pRingIn) orelse {
        rs2(p, @constCast(""), 0);
        return;
    };
    defer list_mod.stz_list_free(@ptrCast(@alignCast(stzIn)));
    const sep: [*]const u8 = @ptrCast(gs(p, 2));
    const sep_len: u32 = @intCast(gss(p, 2));
    const result = yielder.stz_yielder_reduce_concat(@ptrCast(stzIn), sep, sep_len);
    if (result) |r| {
        const val: *StzValue = @ptrCast(@alignCast(r));
        if (val.tag == .string_val) {
            rs2(p, @constCast(val.data.string_val.ptr), @intCast(val.data.string_val.len));
        } else {
            rs2(p, @constCast(""), 0);
        }
        val.deinit();
        @import("std").heap.c_allocator.destroy(val);
    } else {
        rs2(p, @constCast(""), 0);
    }
}

pub const regs = [_]R.Reg{
    .{ .name = @constCast("stzengineyieldermap"), .func = &ring_YielderMap },
    .{ .name = @constCast("stzengineyielderfilter"), .func = &ring_YielderFilter },
    .{ .name = @constCast("stzengineyielderreduce"), .func = &ring_YielderReduce },
    .{ .name = @constCast("stzengineyielderreduceconcat"), .func = &ring_YielderReduceConcat },
    .{ .name = @constCast("stzengineyielderfiltermap"), .func = &ring_YielderFilterMap },
    .{ .name = @constCast("stzengineyieldercountwhere"), .func = &ring_YielderCountWhere },
    .{ .name = @constCast("stzengineyielderfree"), .func = &ring_YielderFree },
    .{ .name = @constCast("stzengineyieldermapindexed"), .func = &ring_YielderMapIndexed },
    // Direct (no handle table) variants:
    .{ .name = @constCast("stzengineyieldermapdirect"), .func = &ring_YielderMapDirect },
    .{ .name = @constCast("stzengineyieldermapindexeddirect"), .func = &ring_YielderMapIndexedDirect },
    .{ .name = @constCast("stzengineyielderfilterdirect"), .func = &ring_YielderFilterDirect },
    .{ .name = @constCast("stzengineyielderfiltermapdirect"), .func = &ring_YielderFilterMapDirect },
    .{ .name = @constCast("stzengineyielderreducedirect"), .func = &ring_YielderReduceDirect },
    .{ .name = @constCast("stzengineyieldercountwheredirect"), .func = &ring_YielderCountWhereDirect },
    .{ .name = @constCast("stzengineyielderreduceconcatdirect"), .func = &ring_YielderReduceConcatDirect },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
