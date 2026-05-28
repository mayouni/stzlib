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

const H: [*:0]const u8 = "StzValueHandle";

fn getH(p: *anyopaque, n: c_int) ?*value.StzValue {
    const ptr = gcp(p, n, H);
    if (ptr) |raw| return @ptrCast(@alignCast(raw));
    return null;
}

fn getHC(p: *anyopaque, n: c_int) ?*const value.StzValue {
    const ptr = gcp(p, n, H);
    if (ptr) |raw| return @ptrCast(@alignCast(raw));
    return null;
}

// Constructors
fn ring_NewNull(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(value.stz_value_new_null()), H);
}
fn ring_NewBool(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(value.stz_value_new_bool(@intFromFloat(g(p, 1)))), H);
}
fn ring_NewInt(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(value.stz_value_new_int(@intFromFloat(g(p, 1)))), H);
}
fn ring_NewFloat(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(value.stz_value_new_float(g(p, 1))), H);
}
fn ring_NewString(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(value.stz_value_new_string(gs(p, 1), @intCast(gss(p, 1)))), H);
}
fn ring_NewList(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(value.stz_value_new_list()), H);
}

// Destructor
fn ring_Free(p: *anyopaque) callconv(.c) void {
    const raw = R.releaseHandle(p, 1);
    if (raw) |ptr| {
        const h: ?*value.StzValue = @ptrCast(@alignCast(ptr));
        value.stz_value_free(h);
    }
}

// Type query
fn ring_Type(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(value.stz_value_type(getHC(p, 1))));
}
fn ring_IsNull(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(value.stz_value_is_null(getHC(p, 1))));
}
fn ring_TypeName(p: *anyopaque) callconv(.c) void {
    const v = getHC(p, 1);
    const name = value.stz_value_type_name(v);
    const name_len = value.stz_value_type_name_len(v);
    rs2(p, name, @intCast(name_len));
}

// Getters
fn ring_GetBool(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(value.stz_value_get_bool(getHC(p, 1))));
}
fn ring_GetInt(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(value.stz_value_get_int(getHC(p, 1))));
}
fn ring_GetFloat(p: *anyopaque) callconv(.c) void {
    rn(p, value.stz_value_get_float(getHC(p, 1)));
}
fn ring_GetString(p: *anyopaque) callconv(.c) void {
    const v = getHC(p, 1);
    const ptr = value.stz_value_get_string(v);
    const len = value.stz_value_get_string_len(v);
    if (len > 0) rs2(p, ptr, @intCast(len)) else rs(p, "");
}

// List operations
fn ring_ListLen(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(value.stz_value_list_len(getHC(p, 1))));
}
fn ring_ListGet(p: *anyopaque) callconv(.c) void {
    const idx: usize = @intFromFloat(g(p, 2));
    const adjusted = if (idx > 0) idx - 1 else 0;
    rcp(p, @constCast(@ptrCast(value.stz_value_list_get(getHC(p, 1), adjusted))), H);
}
fn ring_ListAppend(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(value.stz_value_list_append(getH(p, 1), getHC(p, 2))));
}
fn ring_ListSet(p: *anyopaque) callconv(.c) void {
    const idx: usize = @intFromFloat(g(p, 2));
    const adjusted = if (idx > 0) idx - 1 else 0;
    rn(p, @floatFromInt(value.stz_value_list_set(getH(p, 1), adjusted, getHC(p, 3))));
}
fn ring_ListRemove(p: *anyopaque) callconv(.c) void {
    const idx: usize = @intFromFloat(g(p, 2));
    const adjusted = if (idx > 0) idx - 1 else 0;
    rn(p, @floatFromInt(value.stz_value_list_remove(getH(p, 1), adjusted)));
}
fn ring_ListInsert(p: *anyopaque) callconv(.c) void {
    const idx: usize = @intFromFloat(g(p, 2));
    const adjusted = if (idx > 0) idx - 1 else 0;
    rn(p, @floatFromInt(value.stz_value_list_insert(getH(p, 1), adjusted, getHC(p, 3))));
}
fn ring_ListFind(p: *anyopaque) callconv(.c) void {
    const result = value.stz_value_list_find(getHC(p, 1), getHC(p, 2));
    rn(p, if (result >= 0) @as(f64, @floatFromInt(result + 1)) else 0);
}
fn ring_ListContains(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(value.stz_value_list_contains(getHC(p, 1), getHC(p, 2))));
}
fn ring_ListReverse(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(value.stz_value_list_reverse(getH(p, 1))));
}
fn ring_ListSort(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(value.stz_value_list_sort(getH(p, 1))));
}
fn ring_ListClear(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(value.stz_value_list_clear(getH(p, 1))));
}

// Comparison
fn ring_Equals(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(value.stz_value_equals(getHC(p, 1), getHC(p, 2))));
}
fn ring_Compare(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(value.stz_value_compare(getHC(p, 1), getHC(p, 2))));
}

// Clone
fn ring_Clone(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(value.stz_value_clone(getHC(p, 1))), H);
}

// ToString
fn ring_ToString(p: *anyopaque) callconv(.c) void {
    var buf: [8192]u8 = undefined;
    const len = value.stz_value_to_string(getHC(p, 1), &buf, 8192);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs(p, "");
}

pub const regs = [_]R.Reg{
    .{ .name = "stzenginevaluenewnull", .func = &ring_NewNull },
    .{ .name = "stzenginevaluenewbool", .func = &ring_NewBool },
    .{ .name = "stzenginevaluenewint", .func = &ring_NewInt },
    .{ .name = "stzenginevaluenewfloat", .func = &ring_NewFloat },
    .{ .name = "stzenginevaluenewstring", .func = &ring_NewString },
    .{ .name = "stzenginevaluenewlist", .func = &ring_NewList },
    .{ .name = "stzenginevaluefree", .func = &ring_Free },
    .{ .name = "stzenginevaluetype", .func = &ring_Type },
    .{ .name = "stzenginevalueisnull", .func = &ring_IsNull },
    .{ .name = "stzenginevaluetypename", .func = &ring_TypeName },
    .{ .name = "stzenginevaluegetbool", .func = &ring_GetBool },
    .{ .name = "stzenginevaluegetint", .func = &ring_GetInt },
    .{ .name = "stzenginevaluegetfloat", .func = &ring_GetFloat },
    .{ .name = "stzenginevaluegetstring", .func = &ring_GetString },
    .{ .name = "stzenginevaluelistlen", .func = &ring_ListLen },
    .{ .name = "stzenginevaluelistget", .func = &ring_ListGet },
    .{ .name = "stzenginevaluelistappend", .func = &ring_ListAppend },
    .{ .name = "stzenginevaluelistset", .func = &ring_ListSet },
    .{ .name = "stzenginevaluelistremove", .func = &ring_ListRemove },
    .{ .name = "stzenginevaluelistinsert", .func = &ring_ListInsert },
    .{ .name = "stzenginevaluelistfind", .func = &ring_ListFind },
    .{ .name = "stzenginevaluelistcontains", .func = &ring_ListContains },
    .{ .name = "stzenginevaluelistreverse", .func = &ring_ListReverse },
    .{ .name = "stzenginevaluelistsort", .func = &ring_ListSort },
    .{ .name = "stzenginevaluelistclear", .func = &ring_ListClear },
    .{ .name = "stzenginevalueequals", .func = &ring_Equals },
    .{ .name = "stzenginevaluecompare", .func = &ring_Compare },
    .{ .name = "stzenginevalueclone", .func = &ring_Clone },
    .{ .name = "stzenginevaluetostring", .func = &ring_ToString },
};

pub fn ringlib_init(pRingState: ?*anyopaque) callconv(.c) void {
    if (pRingState) |state| R.registerAll(state, &regs);
}
