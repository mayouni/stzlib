const mod = @import("intent.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gl = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring2;

fn ring_Create(p: *anyopaque) callconv(.c) void {
    const name: [*]const u8 = @ptrCast(gs(p, 1));
    const name_len: usize = @intCast(gl(p, 1));
    const priority: i32 = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(mod.stz_intent_create(name, name_len, priority)));
}

fn ring_SetParam(p: *anyopaque) callconv(.c) void {
    const idx: i32 = @intFromFloat(gn(p, 1));
    const name: [*]const u8 = @ptrCast(gs(p, 2));
    const name_len: usize = @intCast(gl(p, 2));
    const val: [*]const u8 = @ptrCast(gs(p, 3));
    const val_len: usize = @intCast(gl(p, 3));
    rn(p, @floatFromInt(mod.stz_intent_set_param(idx, name, name_len, val, val_len)));
}

fn ring_GetParam(p: *anyopaque) callconv(.c) void {
    const idx: i32 = @intFromFloat(gn(p, 1));
    const name: [*]const u8 = @ptrCast(gs(p, 2));
    const name_len: usize = @intCast(gl(p, 2));
    var buf: [64]u8 = undefined;
    const len = mod.stz_intent_get_param(idx, name, name_len, &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_Priority(p: *anyopaque) callconv(.c) void {
    const idx: i32 = @intFromFloat(gn(p, 1));
    rn(p, @floatFromInt(mod.stz_intent_priority(idx)));
}

fn ring_ParamCount(p: *anyopaque) callconv(.c) void {
    const idx: i32 = @intFromFloat(gn(p, 1));
    rn(p, @floatFromInt(mod.stz_intent_param_count(idx)));
}

fn ring_Count(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_intent_count()));
}

fn ring_TopPriority(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_intent_top_priority()));
}

fn ring_Destroy(p: *anyopaque) callconv(.c) void {
    const idx: i32 = @intFromFloat(gn(p, 1));
    mod.stz_intent_destroy(idx);
    rn(p, 1);
}

fn ring_Clear(p: *anyopaque) callconv(.c) void {
    _ = p;
    mod.stz_intent_clear();
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = @constCast("stzengineintentcreate"), .func = ring_Create },
    .{ .name = @constCast("stzengineintentsetparam"), .func = ring_SetParam },
    .{ .name = @constCast("stzengineintentgetparam"), .func = ring_GetParam },
    .{ .name = @constCast("stzengineintentpriority"), .func = ring_Priority },
    .{ .name = @constCast("stzengineintentparamcount"), .func = ring_ParamCount },
    .{ .name = @constCast("stzengineintentcount"), .func = ring_Count },
    .{ .name = @constCast("stzengineintenttoppriority"), .func = ring_TopPriority },
    .{ .name = @constCast("stzengineintentdestroy"), .func = ring_Destroy },
    .{ .name = @constCast("stzengineintentclear"), .func = ring_Clear },
};
