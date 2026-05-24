const execmodel = @import("execmodel.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs2 = R.ring_vm_api_retstring2;

fn ring_AddState(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(execmodel.exec_add_state(ptr, len)));
}

fn ring_AddTransition(p: *anyopaque) callconv(.c) void {
    const from: u32 = @intFromFloat(gn(p, 1));
    const to: u32 = @intFromFloat(gn(p, 2));
    const ptr: [*]const u8 = @ptrCast(gs(p, 3));
    const len: usize = @intCast(gss(p, 3));
    rn(p, @floatFromInt(execmodel.exec_add_transition(from, to, ptr, len)));
}

fn ring_SetState(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(execmodel.exec_set_state(@intFromFloat(gn(p, 1)))));
}

fn ring_CurrentState(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(execmodel.exec_current_state()));
}

fn ring_CurrentStateName(p: *anyopaque) callconv(.c) void {
    var buf: [32]u8 = undefined;
    const len = execmodel.exec_current_state_name(&buf, 32);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

fn ring_Dispatch(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(execmodel.exec_dispatch(ptr, len)));
}

fn ring_StateCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(execmodel.exec_state_count()));
}

fn ring_TransitionCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(execmodel.exec_transition_count()));
}

fn ring_ExecClear(p: *anyopaque) callconv(.c) void {
    _ = p;
    execmodel.exec_clear();
}

pub const regs = [_]R.Reg{
    .{ .name = "stzengineexecaddstate", .func = &ring_AddState },
    .{ .name = "stzengineexecaddtransition", .func = &ring_AddTransition },
    .{ .name = "stzengineexecsetstate", .func = &ring_SetState },
    .{ .name = "stzengineexeccurrentstate", .func = &ring_CurrentState },
    .{ .name = "stzengineexeccurrentstatename", .func = &ring_CurrentStateName },
    .{ .name = "stzengineexecdispatch", .func = &ring_Dispatch },
    .{ .name = "stzengineexecstatecount", .func = &ring_StateCount },
    .{ .name = "stzengineexectransitioncount", .func = &ring_TransitionCount },
    .{ .name = "stzengineexecclear", .func = &ring_ExecClear },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
