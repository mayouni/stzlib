const R = @import("ring_api.zig");
const mod = @import("softanzuter.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gl = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring2;

fn ring_Create(p: *anyopaque) callconv(.c) void {
    const name = gs(p, 1);
    const name_len: usize = @intCast(gl(p, 1));
    rn(p, @floatFromInt(mod.stz_agent_create(name, name_len)));
}

fn ring_SetState(p: *anyopaque) callconv(.c) void {
    const idx: i32 = @intFromFloat(gn(p, 1));
    const state: i32 = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(mod.stz_agent_set_state(idx, state)));
}

fn ring_GetState(p: *anyopaque) callconv(.c) void {
    const idx: i32 = @intFromFloat(gn(p, 1));
    rn(p, @floatFromInt(mod.stz_agent_get_state(idx)));
}

fn ring_SendMsg(p: *anyopaque) callconv(.c) void {
    const from: i32 = @intFromFloat(gn(p, 1));
    const to: i32 = @intFromFloat(gn(p, 2));
    const msg = gs(p, 3);
    const msg_len: usize = @intCast(gl(p, 3));
    rn(p, @floatFromInt(mod.stz_agent_send_msg(from, to, msg, msg_len)));
}

fn ring_RecvMsg(p: *anyopaque) callconv(.c) void {
    const idx: i32 = @intFromFloat(gn(p, 1));
    var buf: [512]u8 = undefined;
    const len = mod.stz_agent_recv_msg(idx, &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_Count(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_agent_count()));
}

fn ring_Name(p: *anyopaque) callconv(.c) void {
    const idx: i32 = @intFromFloat(gn(p, 1));
    var buf: [128]u8 = undefined;
    const len = mod.stz_agent_name(idx, &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_Clear(p: *anyopaque) callconv(.c) void {
    _ = p;
    mod.stz_agent_clear();
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = "stzenginezutercreate", .func = ring_Create },
    .{ .name = "stzenginezutersetstate", .func = ring_SetState },
    .{ .name = "stzenginezutergetstate", .func = ring_GetState },
    .{ .name = "stzenginezutersendmsg", .func = ring_SendMsg },
    .{ .name = "stzenginezuterrecvmsg", .func = ring_RecvMsg },
    .{ .name = "stzenginezutercount", .func = ring_Count },
    .{ .name = "stzenginezutername", .func = ring_Name },
    .{ .name = "stzenginezuterclear", .func = ring_Clear },
};
