const j = @import("json.zig");
const R = @import("ring_api.zig");

const g = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const gcp = R.ring_vm_api_getcpointer;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring;
const rs2 = R.ring_vm_api_retstring2;
const rcp = R.ring_vm_api_retcpointer;

const H: [*:0]const u8 = "StzJsonHandle";

fn getH(p: *anyopaque, n: c_int) j.StzJsonHandle {
    const ptr = gcp(p, n, H);
    if (ptr) |raw| return @ptrCast(@alignCast(raw));
    return null;
}

fn ring_Parse(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(j.stz_json_parse(gs(p, 1), @intCast(gss(p, 1)))), H);
}
fn ring_Free(p: *anyopaque) callconv(.c) void { j.stz_json_free(getH(p, 1)); }
fn ring_IsValid(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(j.stz_json_is_valid(getH(p, 1)))); }
fn ring_IsArray(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(j.stz_json_is_array(getH(p, 1)))); }
fn ring_Size(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(j.stz_json_size(getH(p, 1)))); }
fn ring_HasKey(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(j.stz_json_has_key(getH(p, 1), gs(p, 2), @intCast(gss(p, 2)))));
}
fn ring_GetString(p: *anyopaque) callconv(.c) void {
    var buf: [4096]u8 = undefined;
    const n = j.stz_json_get_string(getH(p, 1), gs(p, 2), @intCast(gss(p, 2)), &buf, 4096);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_GetInt(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(j.stz_json_get_int(getH(p, 1), gs(p, 2), @intCast(gss(p, 2)))));
}
fn ring_GetBool(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(j.stz_json_get_bool(getH(p, 1), gs(p, 2), @intCast(gss(p, 2)))));
}
fn ring_ArrayAtString(p: *anyopaque) callconv(.c) void {
    var buf: [4096]u8 = undefined;
    const n = j.stz_json_array_at_string(getH(p, 1), @intFromFloat(g(p, 2)), &buf, 4096);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_ArrayAtInt(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(j.stz_json_array_at_int(getH(p, 1), @intFromFloat(g(p, 2)))));
}
fn ring_ToString(p: *anyopaque) callconv(.c) void {
    var out_len: usize = 0;
    const ptr = j.stz_json_to_string(getH(p, 1), &out_len);
    if (ptr != null and out_len > 0) {
        rs2(p, ptr, @intCast(out_len));
        j.stz_json_string_free(ptr, out_len);
    } else rs(p, "");
}
fn ring_ToStringPretty(p: *anyopaque) callconv(.c) void {
    var out_len: usize = 0;
    const ptr = j.stz_json_to_string_pretty(getH(p, 1), &out_len);
    if (ptr != null and out_len > 0) {
        rs2(p, ptr, @intCast(out_len));
        j.stz_json_string_free(ptr, out_len);
    } else rs(p, "");
}
fn ring_Keys(p: *anyopaque) callconv(.c) void {
    var buf: [4096]u8 = undefined;
    const n = j.stz_json_keys(getH(p, 1), &buf, 4096);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_Error(p: *anyopaque) callconv(.c) void {
    var buf: [256]u8 = undefined;
    const n = j.stz_json_error(getH(p, 1), &buf, 256);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}

pub const regs = [_]R.Reg{
    .{ .name = "stzenginejsonparse", .func = &ring_Parse },
    .{ .name = "stzenginejsonfree", .func = &ring_Free },
    .{ .name = "stzenginejsonisvalid", .func = &ring_IsValid },
    .{ .name = "stzenginejsonisarray", .func = &ring_IsArray },
    .{ .name = "stzenginejsonsize", .func = &ring_Size },
    .{ .name = "stzenginejsonhaskey", .func = &ring_HasKey },
    .{ .name = "stzenginejsongetstring", .func = &ring_GetString },
    .{ .name = "stzenginejsongetint", .func = &ring_GetInt },
    .{ .name = "stzenginejsongetbool", .func = &ring_GetBool },
    .{ .name = "stzenginejsonarrayatstring", .func = &ring_ArrayAtString },
    .{ .name = "stzenginejsonarrayatint", .func = &ring_ArrayAtInt },
    .{ .name = "stzenginejsontostring", .func = &ring_ToString },
    .{ .name = "stzenginejsontostringpretty", .func = &ring_ToStringPretty },
    .{ .name = "stzenginejsonkeys", .func = &ring_Keys },
    .{ .name = "stzenginejsonerror", .func = &ring_Error },
};

pub fn ringlib_init(pRingState: ?*anyopaque) callconv(.c) void {
    if (pRingState) |state| R.registerAll(state, &regs);
}
