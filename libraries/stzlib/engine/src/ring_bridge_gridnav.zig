const R = @import("ring_api.zig");
const mod = @import("gridnav.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gl = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring2;

fn ring_Create(p: *anyopaque) callconv(.c) void {
    const rows: i32 = @intFromFloat(gn(p, 1));
    const cols: i32 = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(mod.stz_grid_create(rows, cols)));
}

fn ring_SetPos(p: *anyopaque) callconv(.c) void {
    const row: i32 = @intFromFloat(gn(p, 1));
    const col: i32 = @intFromFloat(gn(p, 2));
    mod.stz_grid_set_pos(row, col);
}

fn ring_GetRow(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_grid_get_row()));
}

fn ring_GetCol(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_grid_get_col()));
}

fn ring_Move(p: *anyopaque) callconv(.c) void {
    const dir: i32 = @intFromFloat(gn(p, 1));
    rn(p, @floatFromInt(mod.stz_grid_move(dir)));
}

fn ring_Neighbors(p: *anyopaque) callconv(.c) void {
    _ = p;
    var rows: [4]i32 = undefined;
    var cols: [4]i32 = undefined;
    const n = mod.stz_grid_neighbors(&rows, &cols);
    _ = n;
    // returns count via separate call
}

fn ring_NeighborCount(p: *anyopaque) callconv(.c) void {
    var rows: [4]i32 = undefined;
    var cols: [4]i32 = undefined;
    rn(p, @floatFromInt(mod.stz_grid_neighbors(&rows, &cols)));
}

fn ring_IsValid(p: *anyopaque) callconv(.c) void {
    const row: i32 = @intFromFloat(gn(p, 1));
    const col: i32 = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(mod.stz_grid_is_valid(row, col)));
}

fn ring_Distance(p: *anyopaque) callconv(.c) void {
    const r1: i32 = @intFromFloat(gn(p, 1));
    const c1: i32 = @intFromFloat(gn(p, 2));
    const r2: i32 = @intFromFloat(gn(p, 3));
    const c2: i32 = @intFromFloat(gn(p, 4));
    rn(p, @floatFromInt(mod.stz_grid_distance(r1, c1, r2, c2)));
}

fn ring_Reset(p: *anyopaque) callconv(.c) void {
    _ = p;
    mod.stz_grid_reset();
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = "stzenginegridcreate", .func = ring_Create },
    .{ .name = "stzenginegridsetpos", .func = ring_SetPos },
    .{ .name = "stzenginegridgetrow", .func = ring_GetRow },
    .{ .name = "stzenginegridgetcol", .func = ring_GetCol },
    .{ .name = "stzenginegridmove", .func = ring_Move },
    .{ .name = "stzenginegridneighborcount", .func = ring_NeighborCount },
    .{ .name = "stzenginegridisvalid", .func = ring_IsValid },
    .{ .name = "stzenginegriddistance", .func = ring_Distance },
    .{ .name = "stzenginegridreset", .func = ring_Reset },
};
