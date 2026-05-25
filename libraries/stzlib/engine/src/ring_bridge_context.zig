const R = @import("ring_api.zig");
const mod = @import("context.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gsl = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring2;

fn ring_Create(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_ctx_create(gs(p, 1), @intCast(gsl(p, 1)), @intFromFloat(gn(p, 2)))));
}

fn ring_Set(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_ctx_set(@intFromFloat(gn(p, 1)), gs(p, 2), @intCast(gsl(p, 2)), gs(p, 3), @intCast(gsl(p, 3)))));
}

fn ring_Get(p: *anyopaque) callconv(.c) void {
    var buf: [128]u8 = undefined;
    const len = mod.stz_ctx_get(@intFromFloat(gn(p, 1)), gs(p, 2), @intCast(gsl(p, 2)), &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_Has(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_ctx_has(@intFromFloat(gn(p, 1)), gs(p, 2), @intCast(gsl(p, 2)))));
}

fn ring_PairCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_ctx_pair_count(@intFromFloat(gn(p, 1)))));
}

fn ring_ScopeCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_ctx_scope_count()));
}

fn ring_Destroy(p: *anyopaque) callconv(.c) void {
    mod.stz_ctx_destroy(@intFromFloat(gn(p, 1)));
}

fn ring_Clear(p: *anyopaque) callconv(.c) void {
    _ = p;
    mod.stz_ctx_clear();
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = "stzenginecontextcreate", .func = ring_Create },
    .{ .name = "stzenginecontextset", .func = ring_Set },
    .{ .name = "stzenginecontextget", .func = ring_Get },
    .{ .name = "stzenginecontexthas", .func = ring_Has },
    .{ .name = "stzenginecontextpaircount", .func = ring_PairCount },
    .{ .name = "stzenginecontextscopecount", .func = ring_ScopeCount },
    .{ .name = "stzenginecontextdestroy", .func = ring_Destroy },
    .{ .name = "stzenginecontextclear", .func = ring_Clear },
};
