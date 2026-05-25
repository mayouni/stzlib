const R = @import("ring_api.zig");
const mod = @import("validator.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gsl = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring2;

fn ring_AddRule(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_val_add_rule(gs(p, 1), @intCast(gsl(p, 1)), @intFromFloat(gn(p, 2)), @intFromFloat(gn(p, 3)), gs(p, 4), @intCast(gsl(p, 4)))));
}

fn ring_CheckInt(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_val_check_int(gs(p, 1), @intCast(gsl(p, 1)), @intFromFloat(gn(p, 2)))));
}

fn ring_CheckLen(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_val_check_len(gs(p, 1), @intCast(gsl(p, 1)), @intFromFloat(gn(p, 2)))));
}

fn ring_Message(p: *anyopaque) callconv(.c) void {
    const idx: i32 = @intFromFloat(gn(p, 1));
    var buf: [256]u8 = undefined;
    const len = mod.stz_val_message(idx, &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_RuleCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_val_rule_count()));
}

fn ring_AddViolation(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_val_add_violation(@intFromFloat(gn(p, 1)))));
}

fn ring_ViolationCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_val_violation_count()));
}

fn ring_IsValid(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_val_is_valid()));
}

fn ring_ClearViolations(p: *anyopaque) callconv(.c) void {
    _ = p;
    mod.stz_val_clear_violations();
}

fn ring_Clear(p: *anyopaque) callconv(.c) void {
    _ = p;
    mod.stz_val_clear();
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = "stzenginevaladdrule", .func = ring_AddRule },
    .{ .name = "stzenginevalcheckint", .func = ring_CheckInt },
    .{ .name = "stzenginevalchecklen", .func = ring_CheckLen },
    .{ .name = "stzenginevalmessage", .func = ring_Message },
    .{ .name = "stzenginevalrulecount", .func = ring_RuleCount },
    .{ .name = "stzenginevaladdviolation", .func = ring_AddViolation },
    .{ .name = "stzenginevalviolationcount", .func = ring_ViolationCount },
    .{ .name = "stzenginevalvalid", .func = ring_IsValid },
    .{ .name = "stzenginevalclearviolations", .func = ring_ClearViolations },
    .{ .name = "stzenginevalclear", .func = ring_Clear },
};
