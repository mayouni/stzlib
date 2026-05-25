const R = @import("ring_api.zig");
const mod = @import("explain.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gsl = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring2;

fn ring_Add(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_expl_add(gs(p, 1), @intCast(gsl(p, 1)), gs(p, 2), @intCast(gsl(p, 2)), gs(p, 3), @intCast(gsl(p, 3)))));
}

fn ring_Get(p: *anyopaque) callconv(.c) void {
    var buf: [512]u8 = undefined;
    const len = mod.stz_expl_get(gs(p, 1), @intCast(gsl(p, 1)), &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_Category(p: *anyopaque) callconv(.c) void {
    var buf: [128]u8 = undefined;
    const len = mod.stz_expl_category(gs(p, 1), @intCast(gsl(p, 1)), &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_Count(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_expl_count()));
}

fn ring_CountByCategory(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_expl_count_by_category(gs(p, 1), @intCast(gsl(p, 1)))));
}

fn ring_Has(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_expl_has(gs(p, 1), @intCast(gsl(p, 1)))));
}

fn ring_Remove(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_expl_remove(gs(p, 1), @intCast(gsl(p, 1)))));
}

fn ring_Clear(p: *anyopaque) callconv(.c) void {
    _ = p;
    mod.stz_expl_clear();
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = "stzengineexpladd", .func = ring_Add },
    .{ .name = "stzengineexplget", .func = ring_Get },
    .{ .name = "stzengineexplcategory", .func = ring_Category },
    .{ .name = "stzengineexplcount", .func = ring_Count },
    .{ .name = "stzengineexplcountbycategory", .func = ring_CountByCategory },
    .{ .name = "stzengineexplhas", .func = ring_Has },
    .{ .name = "stzengineexplremove", .func = ring_Remove },
    .{ .name = "stzengineexplclear", .func = ring_Clear },
};
