const R = @import("ring_api.zig");
const mod = @import("reaxis.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gl = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring2;

fn ring_AddRule(p: *anyopaque) callconv(.c) void {
    const pattern = gs(p, 1);
    const pat_len: usize = @intCast(gl(p, 1));
    const action = gs(p, 2);
    const act_len: usize = @intCast(gl(p, 2));
    rn(p, @floatFromInt(mod.stz_rx_add_rule(pattern, pat_len, action, act_len)));
}

fn ring_Emit(p: *anyopaque) callconv(.c) void {
    const event = gs(p, 1);
    const event_len: usize = @intCast(gl(p, 1));
    var buf: [16384]u8 = undefined;
    const n = mod.stz_rx_emit(event, event_len, &buf);
    rn(p, @floatFromInt(n));
}

fn ring_RuleCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_rx_rule_count()));
}

fn ring_MatchCount(p: *anyopaque) callconv(.c) void {
    const pattern = gs(p, 1);
    const pat_len: usize = @intCast(gl(p, 1));
    rn(p, @floatFromInt(mod.stz_rx_match_count(pattern, pat_len)));
}

fn ring_RemoveRule(p: *anyopaque) callconv(.c) void {
    const idx: i32 = @intFromFloat(gn(p, 1));
    mod.stz_rx_remove_rule(idx);
}

fn ring_Clear(p: *anyopaque) callconv(.c) void {
    _ = p;
    mod.stz_rx_clear();
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = "stzenginereaxisaddrule", .func = ring_AddRule },
    .{ .name = "stzenginereaxisemit", .func = ring_Emit },
    .{ .name = "stzenginereaxisrulecount", .func = ring_RuleCount },
    .{ .name = "stzenginereaxismatchcount", .func = ring_MatchCount },
    .{ .name = "stzenginereaxisremoverule", .func = ring_RemoveRule },
    .{ .name = "stzenginereaxisclear", .func = ring_Clear },
};
