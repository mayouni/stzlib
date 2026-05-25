const mod = @import("skill.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gl = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring2;

fn ring_Register(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_skill_register(gs(p, 1), @intCast(gl(p, 1)), gs(p, 2), @intCast(gl(p, 2)))));
}

fn ring_RecordAttempt(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_skill_record_attempt(gs(p, 1), @intCast(gl(p, 1)), @intFromFloat(gn(p, 2)))));
}

fn ring_Level(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_skill_level(gs(p, 1), @intCast(gl(p, 1)))));
}

fn ring_Score(p: *anyopaque) callconv(.c) void {
    rn(p, mod.stz_skill_score(gs(p, 1), @intCast(gl(p, 1))));
}

fn ring_Attempts(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_skill_attempts(gs(p, 1), @intCast(gl(p, 1)))));
}

fn ring_Successes(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_skill_successes(gs(p, 1), @intCast(gl(p, 1)))));
}

fn ring_AddPrereq(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_skill_add_prereq(gs(p, 1), @intCast(gl(p, 1)), gs(p, 2), @intCast(gl(p, 2)))));
}

fn ring_PrereqsMet(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_skill_prereqs_met(gs(p, 1), @intCast(gl(p, 1)))));
}

fn ring_Count(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_skill_count()));
}

fn ring_CountByCategory(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_skill_count_by_category(gs(p, 1), @intCast(gl(p, 1)))));
}

fn ring_Unregister(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_skill_unregister(gs(p, 1), @intCast(gl(p, 1)))));
}

fn ring_Clear(p: *anyopaque) callconv(.c) void {
    _ = p;
    mod.stz_skill_clear();
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = @constCast("stzengineskillregister"), .func = ring_Register },
    .{ .name = @constCast("stzengineskillrecordattempt"), .func = ring_RecordAttempt },
    .{ .name = @constCast("stzengineskilllevel"), .func = ring_Level },
    .{ .name = @constCast("stzengineskillscore"), .func = ring_Score },
    .{ .name = @constCast("stzengineskillattempts"), .func = ring_Attempts },
    .{ .name = @constCast("stzengineskillsuccesses"), .func = ring_Successes },
    .{ .name = @constCast("stzengineskilladdprereq"), .func = ring_AddPrereq },
    .{ .name = @constCast("stzengineskillprereqsmet"), .func = ring_PrereqsMet },
    .{ .name = @constCast("stzengineskillcount"), .func = ring_Count },
    .{ .name = @constCast("stzengineskillcountbycategory"), .func = ring_CountByCategory },
    .{ .name = @constCast("stzengineskillunregister"), .func = ring_Unregister },
    .{ .name = @constCast("stzengineskillclear"), .func = ring_Clear },
};
