const R = @import("ring_api.zig");
const kg = @import("knowgraph.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gl = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring2;

fn ring_add(p: *anyopaque) callconv(.c) void {
    const s = gs(p, 1);
    const sl: i32 = @intCast(gl(p, 1));
    const pred = gs(p, 2);
    const pl: i32 = @intCast(gl(p, 2));
    const o = gs(p, 3);
    const ol: i32 = @intCast(gl(p, 3));
    rn(p, @floatFromInt(kg.kg_add(s, sl, pred, pl, o, ol)));
}

fn ring_count(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(kg.kg_count()));
}

fn ring_remove(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(kg.kg_remove(@intFromFloat(gn(p, 1)))));
}

fn ring_has_triple(p: *anyopaque) callconv(.c) void {
    const s = gs(p, 1);
    const sl: i32 = @intCast(gl(p, 1));
    const pred = gs(p, 2);
    const pl: i32 = @intCast(gl(p, 2));
    const o = gs(p, 3);
    const ol: i32 = @intCast(gl(p, 3));
    rn(p, @floatFromInt(kg.kg_has_triple(s, sl, pred, pl, o, ol)));
}

fn ring_get_subject(p: *anyopaque) callconv(.c) void {
    const idx: i32 = @intFromFloat(gn(p, 1));
    var buf: [128]u8 = undefined;
    const len = kg.kg_get_subject(idx, &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_get_predicate(p: *anyopaque) callconv(.c) void {
    const idx: i32 = @intFromFloat(gn(p, 1));
    var buf: [128]u8 = undefined;
    const len = kg.kg_get_predicate(idx, &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_get_object(p: *anyopaque) callconv(.c) void {
    const idx: i32 = @intFromFloat(gn(p, 1));
    var buf: [128]u8 = undefined;
    const len = kg.kg_get_object(idx, &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_clear(p: *anyopaque) callconv(.c) void {
    _ = p;
    kg.kg_clear();
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = "stzengine_kg_add", .func = ring_add },
    .{ .name = "stzengine_kg_count", .func = ring_count },
    .{ .name = "stzengine_kg_remove", .func = ring_remove },
    .{ .name = "stzengine_kg_has_triple", .func = ring_has_triple },
    .{ .name = "stzengine_kg_get_subject", .func = ring_get_subject },
    .{ .name = "stzengine_kg_get_predicate", .func = ring_get_predicate },
    .{ .name = "stzengine_kg_get_object", .func = ring_get_object },
    .{ .name = "stzengine_kg_clear", .func = ring_clear },
};
