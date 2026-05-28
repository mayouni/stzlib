const hashmap = @import("hashmap.zig");
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

const HM: [*:0]const u8 = "StzHashMapHandle";
const HV: [*:0]const u8 = "StzValueHandle";

fn getM(p: *anyopaque, n: c_int) ?*hashmap.StzHashMap {
    const ptr = gcp(p, n, HM);
    if (ptr) |raw| return @ptrCast(@alignCast(raw));
    return null;
}

fn getMC(p: *anyopaque, n: c_int) ?*const hashmap.StzHashMap {
    const ptr = gcp(p, n, HM);
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
    rcp(p, @ptrCast(hashmap.stz_hashmap_new()), HM);
}
fn ring_Free(p: *anyopaque) callconv(.c) void {
    const raw = R.releaseHandle(p, 1);
    if (raw) |ptr| {
        const h: ?*hashmap.StzHashMap = @ptrCast(@alignCast(ptr));
        hashmap.stz_hashmap_free(h);
    }
}
fn ring_Len(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(hashmap.stz_hashmap_len(getMC(p, 1))));
}

// Put
fn ring_Put(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(hashmap.stz_hashmap_put(getM(p, 1), gs(p, 2), @intCast(gss(p, 2)), getV(p, 3))));
}
fn ring_PutInt(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(hashmap.stz_hashmap_put_int(getM(p, 1), gs(p, 2), @intCast(gss(p, 2)), @intFromFloat(g(p, 3)))));
}
fn ring_PutFloat(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(hashmap.stz_hashmap_put_float(getM(p, 1), gs(p, 2), @intCast(gss(p, 2)), g(p, 3))));
}
fn ring_PutString(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(hashmap.stz_hashmap_put_string(getM(p, 1), gs(p, 2), @intCast(gss(p, 2)), gs(p, 3), @intCast(gss(p, 3)))));
}

// Get
fn ring_Get(p: *anyopaque) callconv(.c) void {
    rcp(p, @constCast(@ptrCast(hashmap.stz_hashmap_get(getMC(p, 1), gs(p, 2), @intCast(gss(p, 2))))), HV);
}
fn ring_GetCS(p: *anyopaque) callconv(.c) void {
    rcp(p, @constCast(@ptrCast(hashmap.stz_hashmap_get_cs(getMC(p, 1), gs(p, 2), @intCast(gss(p, 2)), @intFromFloat(g(p, 3))))), HV);
}
fn ring_GetInt(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(hashmap.stz_hashmap_get_int(getMC(p, 1), gs(p, 2), @intCast(gss(p, 2)))));
}
fn ring_GetFloat(p: *anyopaque) callconv(.c) void {
    rn(p, hashmap.stz_hashmap_get_float(getMC(p, 1), gs(p, 2), @intCast(gss(p, 2))));
}
fn ring_GetString(p: *anyopaque) callconv(.c) void {
    var buf: [8192]u8 = undefined;
    const n = hashmap.stz_hashmap_get_string(getMC(p, 1), gs(p, 2), @intCast(gss(p, 2)), &buf, 8192);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}

// Has / Remove
fn ring_HasKey(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(hashmap.stz_hashmap_has_key(getMC(p, 1), gs(p, 2), @intCast(gss(p, 2)))));
}
fn ring_HasKeyCS(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(hashmap.stz_hashmap_has_key_cs(getMC(p, 1), gs(p, 2), @intCast(gss(p, 2)), @intFromFloat(g(p, 3)))));
}
fn ring_FindKey(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(hashmap.stz_hashmap_find_key(getMC(p, 1), gs(p, 2), @intCast(gss(p, 2)))));
}
fn ring_FindKeyCS(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(hashmap.stz_hashmap_find_key_cs(getMC(p, 1), gs(p, 2), @intCast(gss(p, 2)), @intFromFloat(g(p, 3)))));
}
fn ring_Remove(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(hashmap.stz_hashmap_remove(getM(p, 1), gs(p, 2), @intCast(gss(p, 2)))));
}

// Key iteration (INDEX_BASE=1: subtract 1)
fn ring_KeyAt(p: *anyopaque) callconv(.c) void {
    const idx: usize = @intFromFloat(g(p, 2));
    const adjusted = if (idx > 0) idx - 1 else 0;
    const ptr = hashmap.stz_hashmap_key_at(getMC(p, 1), adjusted);
    const klen = hashmap.stz_hashmap_key_len_at(getMC(p, 1), adjusted);
    if (klen > 0) rs2(p, ptr, @intCast(klen)) else rs(p, "");
}
fn ring_ValueAt(p: *anyopaque) callconv(.c) void {
    const idx: usize = @intFromFloat(g(p, 2));
    const adjusted = if (idx > 0) idx - 1 else 0;
    rcp(p, @constCast(@ptrCast(hashmap.stz_hashmap_value_at(getMC(p, 1), adjusted))), HV);
}

// Clear / Clone
fn ring_Clear(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(hashmap.stz_hashmap_clear(getM(p, 1))));
}
fn ring_Clone(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(hashmap.stz_hashmap_clone(getMC(p, 1))), HM);
}

// Keys
fn ring_Keys(p: *anyopaque) callconv(.c) void {
    var buf: [65536]u8 = undefined;
    const n = hashmap.stz_hashmap_keys(getMC(p, 1), &buf, 65536);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}

// Merge
fn ring_Merge(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(hashmap.stz_hashmap_merge(getM(p, 1), getMC(p, 2))));
}

pub const regs = [_]R.Reg{
    .{ .name = "stzenginehashmapnew", .func = &ring_New },
    .{ .name = "stzenginehashmapfree", .func = &ring_Free },
    .{ .name = "stzenginehashmaplen", .func = &ring_Len },
    .{ .name = "stzenginehashmapput", .func = &ring_Put },
    .{ .name = "stzenginehashmapputint", .func = &ring_PutInt },
    .{ .name = "stzenginehashmapputfloat", .func = &ring_PutFloat },
    .{ .name = "stzenginehashmapputstring", .func = &ring_PutString },
    .{ .name = "stzenginehashmapget", .func = &ring_Get },
    .{ .name = "stzenginehashmapgetcs", .func = &ring_GetCS },
    .{ .name = "stzenginehashmapgetint", .func = &ring_GetInt },
    .{ .name = "stzenginehashmapgetfloat", .func = &ring_GetFloat },
    .{ .name = "stzenginehashmapgetstring", .func = &ring_GetString },
    .{ .name = "stzenginehashmaphaskey", .func = &ring_HasKey },
    .{ .name = "stzenginehashmaphaskeycs", .func = &ring_HasKeyCS },
    .{ .name = "stzenginehashmapfindkey", .func = &ring_FindKey },
    .{ .name = "stzenginehashmapfindkeycs", .func = &ring_FindKeyCS },
    .{ .name = "stzenginehashmapremove", .func = &ring_Remove },
    .{ .name = "stzenginehashmapkeyat", .func = &ring_KeyAt },
    .{ .name = "stzenginehashmapvalueat", .func = &ring_ValueAt },
    .{ .name = "stzenginehashmapclear", .func = &ring_Clear },
    .{ .name = "stzenginehashmapclone", .func = &ring_Clone },
    .{ .name = "stzenginehashmapkeys", .func = &ring_Keys },
    .{ .name = "stzenginehashmapmerge", .func = &ring_Merge },
};

pub fn ringlib_init(pRingState: ?*anyopaque) callconv(.c) void {
    if (pRingState) |state| R.registerAll(state, &regs);
}
