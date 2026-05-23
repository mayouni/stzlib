const csv = @import("csv.zig");
const R = @import("ring_api.zig");

const g = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const gcp = R.ring_vm_api_getcpointer;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring;
const rs2 = R.ring_vm_api_retstring2;
const rcp = R.ring_vm_api_retcpointer;

const H: [*:0]const u8 = "StzCSVHandle";

fn getH(p: *anyopaque, n: c_int) ?*const csv.StzCSV {
    const ptr = gcp(p, n, H);
    if (ptr) |raw| return @ptrCast(@alignCast(raw));
    return null;
}

fn ring_Parse(p: *anyopaque) callconv(.c) void {
    const ptr = gs(p, 1);
    const len: usize = @intCast(gss(p, 1));
    const sep_str = gs(p, 2);
    const sep: u8 = if (@as(usize, @intCast(gss(p, 2))) > 0) sep_str[0] else ';';
    rcp(p, @ptrCast(csv.stz_csv_parse(ptr, len, sep)), H);
}

fn ring_Free(p: *anyopaque) callconv(.c) void {
    const ptr = gcp(p, 1, H);
    if (ptr) |raw| {
        const c: ?*csv.StzCSV = @ptrCast(@alignCast(raw));
        csv.stz_csv_free(c);
    }
}

fn ring_RowCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(csv.stz_csv_row_count(getH(p, 1))));
}

fn ring_ColCount(p: *anyopaque) callconv(.c) void {
    const row: usize = @intFromFloat(g(p, 2));
    rn(p, @floatFromInt(csv.stz_csv_col_count(getH(p, 1), row)));
}

fn ring_GetCell(p: *anyopaque) callconv(.c) void {
    const row: usize = @intFromFloat(g(p, 2));
    const col: usize = @intFromFloat(g(p, 3));
    var buf: [8192]u8 = undefined;
    const len = csv.stz_csv_get_cell(getH(p, 1), row, col, &buf, 8192);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs(p, "");
}

fn ring_IsValid(p: *anyopaque) callconv(.c) void {
    const ptr = gs(p, 1);
    const len: usize = @intCast(gss(p, 1));
    const sep_str = gs(p, 2);
    const sep: u8 = if (@as(usize, @intCast(gss(p, 2))) > 0) sep_str[0] else ';';
    rn(p, @floatFromInt(csv.stz_csv_is_valid(ptr, len, sep)));
}

fn ring_ToString(p: *anyopaque) callconv(.c) void {
    var buf: [65536]u8 = undefined;
    const len = csv.stz_csv_to_string(getH(p, 1), &buf, 65536);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs(p, "");
}

pub const regs = [_]R.Reg{
    .{ .name = "stzenginecsvparse", .func = &ring_Parse },
    .{ .name = "stzenginecsvfree", .func = &ring_Free },
    .{ .name = "stzenginecsvrowcount", .func = &ring_RowCount },
    .{ .name = "stzenginecsvcolcount", .func = &ring_ColCount },
    .{ .name = "stzenginecsvgetcell", .func = &ring_GetCell },
    .{ .name = "stzenginecsvIsvalid", .func = &ring_IsValid },
    .{ .name = "stzenginecsvtostring", .func = &ring_ToString },
};

pub fn ringlib_init(pRingState: ?*anyopaque) callconv(.c) void {
    if (pRingState) |state| R.registerAll(state, &regs);
}
