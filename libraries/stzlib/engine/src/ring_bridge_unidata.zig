const std = @import("std");
const unidata = @import("unicode_data.zig");
const R = @import("ring_api.zig");

const g = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const gcp = R.ring_vm_api_getcpointer;
const rn = R.ring_vm_api_retnumber;
const rs2 = R.ring_vm_api_retstring2;
const rcp = R.ring_vm_api_retcpointer;

const HU: [*:0]const u8 = "StzUnidataHandle";

fn getDb(p: *anyopaque, n: c_int) ?*unidata.StzUnicodeDb {
    const ptr = gcp(p, n, HU);
    if (ptr) |raw| return @ptrCast(@alignCast(raw));
    return null;
}

fn ring_Open(p: *anyopaque) callconv(.c) void {
    const path_ptr: ?[*]const u8 = if (gss(p, 1) > 0) @ptrCast(gs(p, 1)) else null;
    const path_len: usize = if (path_ptr != null) @intCast(gss(p, 1)) else 0;
    const db = unidata.stz_unidata_open(path_ptr, path_len);
    if (db) |d| {
        rcp(p, @ptrCast(d), HU);
    } else {
        rcp(p, @as(?*anyopaque, null), HU);
    }
}

fn ring_Close(p: *anyopaque) callconv(.c) void {
    unidata.stz_unidata_close(getDb(p, 1));
}

fn ring_CharName(p: *anyopaque) callconv(.c) void {
    const db = getDb(p, 1);
    const cp: i32 = @intFromFloat(g(p, 2));
    var buf: [256]u8 = undefined;
    const len = unidata.stz_unidata_char_name(db, cp, &buf, buf.len);
    rs2(p, &buf, @intCast(len));
}

fn ring_CharCategory(p: *anyopaque) callconv(.c) void {
    const db = getDb(p, 1);
    const cp: i32 = @intFromFloat(g(p, 2));
    var buf: [16]u8 = undefined;
    const len = unidata.stz_unidata_char_category(db, cp, &buf, buf.len);
    rs2(p, &buf, @intCast(len));
}

fn ring_FindByName(p: *anyopaque) callconv(.c) void {
    const db = getDb(p, 1);
    const pattern: [*]const u8 = @ptrCast(gs(p, 2));
    const pattern_len: usize = @intCast(gss(p, 2));
    var buf: [65536]u8 = undefined;
    const len = unidata.stz_unidata_find_by_name(db, pattern, pattern_len, &buf, buf.len);
    rs2(p, &buf, @intCast(len));
}

fn ring_CharsInRange(p: *anyopaque) callconv(.c) void {
    const db = getDb(p, 1);
    const from: i32 = @intFromFloat(g(p, 2));
    const to: i32 = @intFromFloat(g(p, 3));
    var buf: [65536]u8 = undefined;
    const len = unidata.stz_unidata_chars_in_range(db, from, to, &buf, buf.len);
    rs2(p, &buf, @intCast(len));
}

fn ring_Count(p: *anyopaque) callconv(.c) void {
    const db = getDb(p, 1);
    rn(p, @floatFromInt(unidata.stz_unidata_count(db)));
}

fn ring_CharInfo(p: *anyopaque) callconv(.c) void {
    const db = getDb(p, 1);
    const cp: i32 = @intFromFloat(g(p, 2));
    var buf: [1024]u8 = undefined;
    const len = unidata.stz_unidata_char_info(db, cp, &buf, buf.len);
    rs2(p, &buf, @intCast(len));
}

pub const regs = [_]R.Reg{
    .{ .name = "stzengineunidataopen", .func = &ring_Open },
    .{ .name = "stzengineunidataclose", .func = &ring_Close },
    .{ .name = "stzengineunidatacharname", .func = &ring_CharName },
    .{ .name = "stzengineunidatacharcategory", .func = &ring_CharCategory },
    .{ .name = "stzengineunidatafindbyname", .func = &ring_FindByName },
    .{ .name = "stzengineunidatacharsinrange", .func = &ring_CharsInRange },
    .{ .name = "stzengineunidatacount", .func = &ring_Count },
    .{ .name = "stzengineunidatacharinfo", .func = &ring_CharInfo },
};

pub fn ringlib_init(pState: ?*anyopaque) callconv(.c) void {
    if (pState) |s| R.registerAll(s, &regs);
}
