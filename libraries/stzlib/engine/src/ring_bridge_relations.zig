const mod = @import("relations.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gl = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring2;

fn ring_Add(p: *anyopaque) callconv(.c) void {
    const subj: [*]const u8 = @ptrCast(gs(p, 1));
    const subj_len: usize = @intCast(gl(p, 1));
    const rel: [*]const u8 = @ptrCast(gs(p, 2));
    const rel_len: usize = @intCast(gl(p, 2));
    const obj: [*]const u8 = @ptrCast(gs(p, 3));
    const obj_len: usize = @intCast(gl(p, 3));
    const weight: f64 = gn(p, 4);
    rn(p, @floatFromInt(mod.stz_rel_add(subj, subj_len, rel, rel_len, obj, obj_len, weight)));
}

fn ring_Count(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_rel_count()));
}

fn ring_Subject(p: *anyopaque) callconv(.c) void {
    const idx: i32 = @intFromFloat(gn(p, 1));
    var buf: [64]u8 = undefined;
    const len = mod.stz_rel_subject(idx, &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_Object(p: *anyopaque) callconv(.c) void {
    const idx: i32 = @intFromFloat(gn(p, 1));
    var buf: [64]u8 = undefined;
    const len = mod.stz_rel_object(idx, &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_Type(p: *anyopaque) callconv(.c) void {
    const idx: i32 = @intFromFloat(gn(p, 1));
    var buf: [64]u8 = undefined;
    const len = mod.stz_rel_type(idx, &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_Weight(p: *anyopaque) callconv(.c) void {
    const idx: i32 = @intFromFloat(gn(p, 1));
    rn(p, mod.stz_rel_weight(idx));
}

fn ring_Remove(p: *anyopaque) callconv(.c) void {
    const idx: i32 = @intFromFloat(gn(p, 1));
    mod.stz_rel_remove(idx);
    rn(p, 1);
}

fn ring_Clear(p: *anyopaque) callconv(.c) void {
    _ = p;
    mod.stz_rel_clear();
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = @constCast("stzenginereladd"), .func = ring_Add },
    .{ .name = @constCast("stzenginerelcount"), .func = ring_Count },
    .{ .name = @constCast("stzenginerelsubject"), .func = ring_Subject },
    .{ .name = @constCast("stzenginerelobject"), .func = ring_Object },
    .{ .name = @constCast("stzenginereltype"), .func = ring_Type },
    .{ .name = @constCast("stzenginerelweight"), .func = ring_Weight },
    .{ .name = @constCast("stzenginerelremove"), .func = ring_Remove },
    .{ .name = @constCast("stzenginerelclear"), .func = ring_Clear },
};
