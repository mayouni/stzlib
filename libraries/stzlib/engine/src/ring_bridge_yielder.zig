const yielder = @import("yielder.zig");
const R = @import("ring_api.zig");
const value_mod = @import("value.zig");
const StzValue = value_mod.StzValue;

const STZ_HANDLE: [*:0]const u8 = "StzListHandle";

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

pub const regs = [_]R.Reg{
    .{ .name = @constCast("stzengineyieldermap"), .func = &ring_YielderMap },
    .{ .name = @constCast("stzengineyielderfilter"), .func = &ring_YielderFilter },
    .{ .name = @constCast("stzengineyielderreduce"), .func = &ring_YielderReduce },
    .{ .name = @constCast("stzengineyielderreduceconcat"), .func = &ring_YielderReduceConcat },
    .{ .name = @constCast("stzengineyielderfiltermap"), .func = &ring_YielderFilterMap },
    .{ .name = @constCast("stzengineyieldercountwhere"), .func = &ring_YielderCountWhere },
    .{ .name = @constCast("stzengineyielderfree"), .func = &ring_YielderFree },
    .{ .name = @constCast("stzengineyieldermapindexed"), .func = &ring_YielderMapIndexed },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
