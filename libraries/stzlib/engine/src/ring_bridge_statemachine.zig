const mod = @import("statemachine.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gl = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring2;

fn ring_Create(p: *anyopaque) callconv(.c) void {
    const name: [*]const u8 = @ptrCast(gs(p, 1));
    const name_len: usize = @intCast(gl(p, 1));
    rn(p, @floatFromInt(mod.stz_fsm_create(name, name_len)));
}

fn ring_AddState(p: *anyopaque) callconv(.c) void {
    const mi: i32 = @intFromFloat(gn(p, 1));
    const name: [*]const u8 = @ptrCast(gs(p, 2));
    const name_len: usize = @intCast(gl(p, 2));
    rn(p, @floatFromInt(mod.stz_fsm_add_state(mi, name, name_len)));
}

fn ring_AddTransition(p: *anyopaque) callconv(.c) void {
    const mi: i32 = @intFromFloat(gn(p, 1));
    const from: [*]const u8 = @ptrCast(gs(p, 2));
    const from_len: usize = @intCast(gl(p, 2));
    const event: [*]const u8 = @ptrCast(gs(p, 3));
    const event_len: usize = @intCast(gl(p, 3));
    const to: [*]const u8 = @ptrCast(gs(p, 4));
    const to_len: usize = @intCast(gl(p, 4));
    rn(p, @floatFromInt(mod.stz_fsm_add_transition(mi, from, from_len, event, event_len, to, to_len)));
}

fn ring_SetState(p: *anyopaque) callconv(.c) void {
    const mi: i32 = @intFromFloat(gn(p, 1));
    const name: [*]const u8 = @ptrCast(gs(p, 2));
    const name_len: usize = @intCast(gl(p, 2));
    rn(p, @floatFromInt(mod.stz_fsm_set_state(mi, name, name_len)));
}

fn ring_Send(p: *anyopaque) callconv(.c) void {
    const mi: i32 = @intFromFloat(gn(p, 1));
    const event: [*]const u8 = @ptrCast(gs(p, 2));
    const event_len: usize = @intCast(gl(p, 2));
    rn(p, @floatFromInt(mod.stz_fsm_send(mi, event, event_len)));
}

fn ring_CurrentState(p: *anyopaque) callconv(.c) void {
    const mi: i32 = @intFromFloat(gn(p, 1));
    var buf: [64]u8 = undefined;
    const len = mod.stz_fsm_current_state(mi, &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_StateCount(p: *anyopaque) callconv(.c) void {
    const mi: i32 = @intFromFloat(gn(p, 1));
    rn(p, @floatFromInt(mod.stz_fsm_state_count(mi)));
}

fn ring_TransitionCount(p: *anyopaque) callconv(.c) void {
    const mi: i32 = @intFromFloat(gn(p, 1));
    rn(p, @floatFromInt(mod.stz_fsm_transition_count(mi)));
}

fn ring_Destroy(p: *anyopaque) callconv(.c) void {
    const mi: i32 = @intFromFloat(gn(p, 1));
    mod.stz_fsm_destroy(mi);
    rn(p, 1);
}

fn ring_Clear(p: *anyopaque) callconv(.c) void {
    _ = p;
    mod.stz_fsm_clear();
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = @constCast("stzenginefsmcreate"), .func = ring_Create },
    .{ .name = @constCast("stzenginefsmaddstate"), .func = ring_AddState },
    .{ .name = @constCast("stzenginefsmaddtransition"), .func = ring_AddTransition },
    .{ .name = @constCast("stzenginefsmsetstate"), .func = ring_SetState },
    .{ .name = @constCast("stzenginefsmsend"), .func = ring_Send },
    .{ .name = @constCast("stzenginefsmcurrentstate"), .func = ring_CurrentState },
    .{ .name = @constCast("stzenginefsmstatecount"), .func = ring_StateCount },
    .{ .name = @constCast("stzenginefsmtransitioncount"), .func = ring_TransitionCount },
    .{ .name = @constCast("stzenginefsmdestroy"), .func = ring_Destroy },
    .{ .name = @constCast("stzenginefsmclear"), .func = ring_Clear },
};
