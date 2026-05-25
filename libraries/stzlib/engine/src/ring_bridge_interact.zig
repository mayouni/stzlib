const mod = @import("interact.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gl = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring2;

fn ring_Create(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_interact_create(gs(p, 1), @intCast(gl(p, 1)), gs(p, 2), @intCast(gl(p, 2)))));
}

fn ring_AddTurn(p: *anyopaque) callconv(.c) void {
    const si: i32 = @intFromFloat(gn(p, 1));
    rn(p, @floatFromInt(mod.stz_interact_add_turn(si, gs(p, 2), @intCast(gl(p, 2)), gs(p, 3), @intCast(gl(p, 3)), @intFromFloat(gn(p, 4)))));
}

fn ring_TurnCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_interact_turn_count(@intFromFloat(gn(p, 1)))));
}

fn ring_Prompt(p: *anyopaque) callconv(.c) void {
    const si: i32 = @intFromFloat(gn(p, 1));
    const ti: i32 = @intFromFloat(gn(p, 2));
    var buf: [256]u8 = undefined;
    const len = mod.stz_interact_prompt(si, ti, &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_Response(p: *anyopaque) callconv(.c) void {
    const si: i32 = @intFromFloat(gn(p, 1));
    const ti: i32 = @intFromFloat(gn(p, 2));
    var buf: [256]u8 = undefined;
    const len = mod.stz_interact_response(si, ti, &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_LastPrompt(p: *anyopaque) callconv(.c) void {
    var buf: [256]u8 = undefined;
    const len = mod.stz_interact_last_prompt(@intFromFloat(gn(p, 1)), &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_SessionCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_interact_session_count()));
}

fn ring_Mode(p: *anyopaque) callconv(.c) void {
    var buf: [64]u8 = undefined;
    const len = mod.stz_interact_mode(@intFromFloat(gn(p, 1)), &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_Destroy(p: *anyopaque) callconv(.c) void {
    mod.stz_interact_destroy(@intFromFloat(gn(p, 1)));
    rn(p, 1);
}

fn ring_Clear(p: *anyopaque) callconv(.c) void {
    _ = p;
    mod.stz_interact_clear();
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = @constCast("stzengineinteractcreate"), .func = ring_Create },
    .{ .name = @constCast("stzengineinteractaddturn"), .func = ring_AddTurn },
    .{ .name = @constCast("stzengineinteractturncount"), .func = ring_TurnCount },
    .{ .name = @constCast("stzengineinteractprompt"), .func = ring_Prompt },
    .{ .name = @constCast("stzengineinteractresponse"), .func = ring_Response },
    .{ .name = @constCast("stzengineinteractlastprompt"), .func = ring_LastPrompt },
    .{ .name = @constCast("stzengineinteractsessioncount"), .func = ring_SessionCount },
    .{ .name = @constCast("stzengineinteractmode"), .func = ring_Mode },
    .{ .name = @constCast("stzengineinteractdestroy"), .func = ring_Destroy },
    .{ .name = @constCast("stzengineinteractclear"), .func = ring_Clear },
};
