const R = @import("ring_api.zig");
const adv = @import("adverb.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gl = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;

fn ring_define(p: *anyopaque) callconv(.c) void {
    const flags: u32 = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(adv.adv_define(gs(p, 1), @intCast(gl(p, 1)), flags)));
}

fn ring_flags(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(adv.adv_flags(gs(p, 1), @intCast(gl(p, 1)))));
}

fn ring_has_flag(p: *anyopaque) callconv(.c) void {
    const flag: u32 = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(adv.adv_has_flag(gs(p, 1), @intCast(gl(p, 1)), flag)));
}

fn ring_compose(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(adv.adv_compose(gs(p, 1), @intCast(gl(p, 1)), gs(p, 2), @intCast(gl(p, 2)))));
}

fn ring_count(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(adv.adv_count()));
}

fn ring_clear(p: *anyopaque) callconv(.c) void {
    _ = p;
    adv.adv_clear();
}

fn ring_init_defaults(p: *anyopaque) callconv(.c) void {
    _ = p;
    adv.adv_init_defaults();
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = "stzengine_adverb_define", .func = ring_define },
    .{ .name = "stzengine_adverb_flags", .func = ring_flags },
    .{ .name = "stzengine_adverb_has_flag", .func = ring_has_flag },
    .{ .name = "stzengine_adverb_compose", .func = ring_compose },
    .{ .name = "stzengine_adverb_count", .func = ring_count },
    .{ .name = "stzengine_adverb_clear", .func = ring_clear },
    .{ .name = "stzengine_adverb_init_defaults", .func = ring_init_defaults },
};
