const b = @import("bytes.zig");
const R = @import("ring_api.zig");

const g = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const gcp = R.ring_vm_api_getcpointer;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring;
const rs2 = R.ring_vm_api_retstring2;
const rcp = R.ring_vm_api_retcpointer;

const H: [*:0]const u8 = "StzBytesHandle";

fn getH(p: *anyopaque, n: c_int) b.StzBytesHandle {
    const ptr = gcp(p, n, H);
    if (ptr) |raw| return @ptrCast(@alignCast(raw));
    return null;
}

fn ring_New(p: *anyopaque) callconv(.c) void { rcp(p, @ptrCast(b.stz_bytes_new()), H); }
fn ring_From(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(b.stz_bytes_from(gs(p, 1), @intCast(gss(p, 1)))), H);
}
fn ring_Free(p: *anyopaque) callconv(.c) void { b.stz_bytes_free(getH(p, 1)); }
fn ring_Data(p: *anyopaque) callconv(.c) void {
    const h = getH(p, 1);
    const data = b.stz_bytes_data(h);
    const sz = b.stz_bytes_size(h);
    if (data != null and sz > 0) rs2(p, data, @intCast(sz)) else rs(p, "");
}
fn ring_Size(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(b.stz_bytes_size(getH(p, 1)))); }
fn ring_IsEmpty(p: *anyopaque) callconv(.c) void { rn(p, @floatFromInt(b.stz_bytes_is_empty(getH(p, 1)))); }
fn ring_Clear(p: *anyopaque) callconv(.c) void { b.stz_bytes_clear(getH(p, 1)); }
fn ring_Append(p: *anyopaque) callconv(.c) void {
    b.stz_bytes_append(getH(p, 1), gs(p, 2), @intCast(gss(p, 2)));
}
fn ring_At(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(b.stz_bytes_at(getH(p, 1), @intFromFloat(g(p, 2)))));
}
fn ring_Insert(p: *anyopaque) callconv(.c) void {
    b.stz_bytes_insert(getH(p, 1), @intFromFloat(g(p, 2)), gs(p, 3), @intCast(gss(p, 3)));
}
fn ring_Remove(p: *anyopaque) callconv(.c) void {
    b.stz_bytes_remove(getH(p, 1), @intFromFloat(g(p, 2)), @intFromFloat(g(p, 3)));
}
fn ring_Left(p: *anyopaque) callconv(.c) void {
    var buf: [4096]u8 = undefined;
    const n = b.stz_bytes_left(getH(p, 1), @intFromFloat(g(p, 2)), &buf, 4096);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_Right(p: *anyopaque) callconv(.c) void {
    var buf: [4096]u8 = undefined;
    const n = b.stz_bytes_right(getH(p, 1), @intFromFloat(g(p, 2)), &buf, 4096);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_Mid(p: *anyopaque) callconv(.c) void {
    var buf: [4096]u8 = undefined;
    const n = b.stz_bytes_mid(getH(p, 1), @intFromFloat(g(p, 2)), @intFromFloat(g(p, 3)), &buf, 4096);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_Fill(p: *anyopaque) callconv(.c) void {
    b.stz_bytes_fill(getH(p, 1), @intFromFloat(g(p, 2)), @intFromFloat(g(p, 3)));
}
fn ring_Replace(p: *anyopaque) callconv(.c) void {
    b.stz_bytes_replace(getH(p, 1), @intFromFloat(g(p, 2)), @intFromFloat(g(p, 3)), gs(p, 4), @intCast(gss(p, 4)));
}
fn ring_Resize(p: *anyopaque) callconv(.c) void {
    b.stz_bytes_resize(getH(p, 1), @intFromFloat(g(p, 2)));
}
fn ring_ToLower(p: *anyopaque) callconv(.c) void {
    var buf: [4096]u8 = undefined;
    const n = b.stz_bytes_to_lower(getH(p, 1), &buf, 4096);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_ToUpper(p: *anyopaque) callconv(.c) void {
    var buf: [4096]u8 = undefined;
    const n = b.stz_bytes_to_upper(getH(p, 1), &buf, 4096);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_ToBase64(p: *anyopaque) callconv(.c) void {
    var buf: [8192]u8 = undefined;
    const n = b.stz_bytes_to_base64(getH(p, 1), &buf, 8192);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_FromBase64(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(b.stz_bytes_from_base64(getH(p, 1), gs(p, 2), @intCast(gss(p, 2)))));
}
fn ring_ToHex(p: *anyopaque) callconv(.c) void {
    var buf: [8192]u8 = undefined;
    const n = b.stz_bytes_to_hex(getH(p, 1), &buf, 8192);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_FromHex(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(b.stz_bytes_from_hex(getH(p, 1), gs(p, 2), @intCast(gss(p, 2)))));
}
fn ring_ToPercent(p: *anyopaque) callconv(.c) void {
    var buf: [8192]u8 = undefined;
    const n = b.stz_bytes_to_percent(getH(p, 1), &buf, 8192);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_FromPercent(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(b.stz_bytes_from_percent(getH(p, 1), gs(p, 2), @intCast(gss(p, 2)))));
}

pub const regs = [_]R.Reg{
    .{ .name = "stzenginebytesnew", .func = &ring_New },
    .{ .name = "stzenginebytesfrom", .func = &ring_From },
    .{ .name = "stzenginebytesfree", .func = &ring_Free },
    .{ .name = "stzenginebytesdata", .func = &ring_Data },
    .{ .name = "stzenginebytessize", .func = &ring_Size },
    .{ .name = "stzenginebytesisempty", .func = &ring_IsEmpty },
    .{ .name = "stzenginebytesclear", .func = &ring_Clear },
    .{ .name = "stzenginebytesappend", .func = &ring_Append },
    .{ .name = "stzenginebytesat", .func = &ring_At },
    .{ .name = "stzenginebytesinsert", .func = &ring_Insert },
    .{ .name = "stzenginebytesremove", .func = &ring_Remove },
    .{ .name = "stzenginebytesleft", .func = &ring_Left },
    .{ .name = "stzenginebytesright", .func = &ring_Right },
    .{ .name = "stzenginebytesmid", .func = &ring_Mid },
    .{ .name = "stzenginebytesfill", .func = &ring_Fill },
    .{ .name = "stzenginebytesreplace", .func = &ring_Replace },
    .{ .name = "stzenginebytesresize", .func = &ring_Resize },
    .{ .name = "stzenginebytestolower", .func = &ring_ToLower },
    .{ .name = "stzenginebytestoupper", .func = &ring_ToUpper },
    .{ .name = "stzenginebytestobase64", .func = &ring_ToBase64 },
    .{ .name = "stzenginebytesfrombase64", .func = &ring_FromBase64 },
    .{ .name = "stzenginebytestohex", .func = &ring_ToHex },
    .{ .name = "stzenginebytesfromhex", .func = &ring_FromHex },
    .{ .name = "stzenginebytestopercent", .func = &ring_ToPercent },
    .{ .name = "stzenginebytesfrompercent", .func = &ring_FromPercent },
};

pub fn ringlib_init(pRingState: ?*anyopaque) callconv(.c) void {
    if (pRingState) |state| R.registerAll(state, &regs);
}
