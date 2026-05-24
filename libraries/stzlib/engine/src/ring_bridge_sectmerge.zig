const R = @import("ring_api.zig");
const mod = @import("sectmerge.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gl = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring2;

fn ring_Add(p: *anyopaque) callconv(.c) void {
    const start: i64 = @intFromFloat(gn(p, 1));
    const end: i64 = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(mod.stz_sm_add(start, end)));
}

fn ring_Count(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_sm_count()));
}

fn ring_Merge(p: *anyopaque) callconv(.c) void {
    var starts: [256]i64 = undefined;
    var ends: [256]i64 = undefined;
    const n = mod.stz_sm_merge(&starts, &ends);
    rn(p, @floatFromInt(n));
}

fn ring_Contains(p: *anyopaque) callconv(.c) void {
    const point: i64 = @intFromFloat(gn(p, 1));
    rn(p, @floatFromInt(mod.stz_sm_contains(point)));
}

fn ring_TotalSpan(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_sm_total_span()));
}

fn ring_OverlapCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_sm_overlap_count()));
}

fn ring_Clear(p: *anyopaque) callconv(.c) void {
    _ = p;
    mod.stz_sm_clear();
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = "stzenginesmpadd", .func = ring_Add },
    .{ .name = "stzenginesmpcount", .func = ring_Count },
    .{ .name = "stzenginesmpmerge", .func = ring_Merge },
    .{ .name = "stzenginesmpcontains", .func = ring_Contains },
    .{ .name = "stzenginesmptotalspan", .func = ring_TotalSpan },
    .{ .name = "stzenginesmpoverlapcount", .func = ring_OverlapCount },
    .{ .name = "stzenginesmpclear", .func = ring_Clear },
};
