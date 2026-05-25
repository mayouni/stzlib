const R = @import("ring_api.zig");
const mod = @import("provenance.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gsl = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring2;

fn ring_Add(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_prov_add(gs(p, 1), @intCast(gsl(p, 1)), gs(p, 2), @intCast(gsl(p, 2)), gs(p, 3), @intCast(gsl(p, 3)), @intFromFloat(gn(p, 4)))));
}

fn ring_Count(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_prov_count()));
}

fn ring_Entity(p: *anyopaque) callconv(.c) void {
    const idx: i32 = @intFromFloat(gn(p, 1));
    var buf: [128]u8 = undefined;
    const len = mod.stz_prov_entity(idx, &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_Origin(p: *anyopaque) callconv(.c) void {
    const idx: i32 = @intFromFloat(gn(p, 1));
    var buf: [128]u8 = undefined;
    const len = mod.stz_prov_origin(idx, &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_Author(p: *anyopaque) callconv(.c) void {
    const idx: i32 = @intFromFloat(gn(p, 1));
    var buf: [128]u8 = undefined;
    const len = mod.stz_prov_author(idx, &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_Time(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_prov_time(@intFromFloat(gn(p, 1)))));
}

fn ring_Version(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_prov_version(@intFromFloat(gn(p, 1)))));
}

fn ring_BumpVersion(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_prov_bump_version(@intFromFloat(gn(p, 1)))));
}

fn ring_Remove(p: *anyopaque) callconv(.c) void {
    mod.stz_prov_remove(@intFromFloat(gn(p, 1)));
}

fn ring_Clear(p: *anyopaque) callconv(.c) void {
    _ = p;
    mod.stz_prov_clear();
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = "stzengineprovadd", .func = ring_Add },
    .{ .name = "stzengineprovcount", .func = ring_Count },
    .{ .name = "stzengineproventity", .func = ring_Entity },
    .{ .name = "stzengineprovorigin", .func = ring_Origin },
    .{ .name = "stzengineprovauthor", .func = ring_Author },
    .{ .name = "stzengineprovtime", .func = ring_Time },
    .{ .name = "stzengineprovversion", .func = ring_Version },
    .{ .name = "stzengineprovbumpversion", .func = ring_BumpVersion },
    .{ .name = "stzengineprovremove", .func = ring_Remove },
    .{ .name = "stzengineprovclear", .func = ring_Clear },
};
