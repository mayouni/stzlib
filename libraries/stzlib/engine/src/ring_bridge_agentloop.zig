const R = @import("ring_api.zig");
const mod = @import("agentloop.zig");

// The Ring face of the tick loop. Ring calls tick() to let Zig DECIDE, then
// drains next()/current_slot()/current_reason() to DO. Nothing here holds a
// Ring callback -- see agentloop.zig's header for why that is deliberate.

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gl = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring2;

fn num(p: *anyopaque, i: c_int) i32 {
    return @intFromFloat(gn(p, i));
}

fn num64(p: *anyopaque, i: c_int) i64 {
    return @intFromFloat(gn(p, i));
}

fn ring_Register(p: *anyopaque) callconv(.c) void {
    const cov = gs(p, 8);
    const cov_len: usize = @intCast(gl(p, 8));
    rn(p, @floatFromInt(mod.stz_agentloop_register(
        num(p, 1), // slot
        num(p, 2), // kind      0 plain | 1 llm
        num(p, 3), // rev       1 reversible | 2 compensable | 3 irreversible
        num(p, 4), // trigger   0 timer | 1 event | 2 mailbox | 3 manual
        num(p, 5), // effectful 0 | 1
        num(p, 6), // priority
        num64(p, 7), // interval ms
        cov,
        cov_len,
    )));
}

fn ring_LastRefusal(p: *anyopaque) callconv(.c) void {
    var buf: [512]u8 = undefined;
    const len = mod.stz_agentloop_last_refusal(&buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_Deregister(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_agentloop_deregister(num(p, 1))));
}

fn ring_Count(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_agentloop_count()));
}

fn ring_IsRegistered(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_agentloop_is_registered(num(p, 1))));
}

fn ring_Coverage(p: *anyopaque) callconv(.c) void {
    var buf: [256]u8 = undefined;
    const len = mod.stz_agentloop_coverage(num(p, 1), &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_Reversibility(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_agentloop_reversibility(num(p, 1))));
}

fn ring_Priority(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_agentloop_priority(num(p, 1))));
}

fn ring_Ticks(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_agentloop_ticks(num(p, 1))));
}

fn ring_Pause(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_agentloop_pause(num(p, 1), num(p, 2))));
}

fn ring_NoteEvents(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_agentloop_note_events(num(p, 1), num64(p, 2), num64(p, 3))));
}

fn ring_Tick(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_agentloop_tick(num64(p, 1))));
}

fn ring_Nudge(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_agentloop_nudge(num(p, 1))));
}

fn ring_Pending(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_agentloop_pending()));
}

fn ring_Next(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_agentloop_next()));
}

fn ring_CurrentSlot(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_agentloop_current_slot()));
}

fn ring_CurrentReason(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_agentloop_current_reason()));
}

fn ring_Dropped(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_agentloop_dropped()));
}

fn ring_Clear(p: *anyopaque) callconv(.c) void {
    _ = p;
    mod.stz_agentloop_clear();
}

fn ring_CoverageStatement(p: *anyopaque) callconv(.c) void {
    var buf: [1024]u8 = undefined;
    const len = mod.stz_agentloop_coverage_statement(&buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = "stzengineagentloopregister", .func = ring_Register },
    .{ .name = "stzengineagentlooplastrefusal", .func = ring_LastRefusal },
    .{ .name = "stzengineagentloopderegister", .func = ring_Deregister },
    .{ .name = "stzengineagentloopcount", .func = ring_Count },
    .{ .name = "stzengineagentloopisregistered", .func = ring_IsRegistered },
    .{ .name = "stzengineagentloopcoverage", .func = ring_Coverage },
    .{ .name = "stzengineagentloopreversibility", .func = ring_Reversibility },
    .{ .name = "stzengineagentlooppriority", .func = ring_Priority },
    .{ .name = "stzengineagentloopticks", .func = ring_Ticks },
    .{ .name = "stzengineagentlooppause", .func = ring_Pause },
    .{ .name = "stzengineagentloopnoteevents", .func = ring_NoteEvents },
    .{ .name = "stzengineagentlooptick", .func = ring_Tick },
    .{ .name = "stzengineagentloopnudge", .func = ring_Nudge },
    .{ .name = "stzengineagentlooppending", .func = ring_Pending },
    .{ .name = "stzengineagentloopnext", .func = ring_Next },
    .{ .name = "stzengineagentloopcurrentslot", .func = ring_CurrentSlot },
    .{ .name = "stzengineagentloopcurrentreason", .func = ring_CurrentReason },
    .{ .name = "stzengineagentloopdropped", .func = ring_Dropped },
    .{ .name = "stzengineagentloopclear", .func = ring_Clear },
    .{ .name = "stzengineagentloopcoveragestatement", .func = ring_CoverageStatement },
};
