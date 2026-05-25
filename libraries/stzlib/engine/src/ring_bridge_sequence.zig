const mod = @import("sequence.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gl = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;

fn ring_Create(p: *anyopaque) callconv(.c) void {
    const name: [*]const u8 = @ptrCast(gs(p, 1));
    const name_len: usize = @intCast(gl(p, 1));
    const start: i64 = @intFromFloat(gn(p, 2));
    const step_val: i64 = @intFromFloat(gn(p, 3));
    const mode: i32 = @intFromFloat(gn(p, 4));
    rn(p, @floatFromInt(mod.stz_seq_create(name, name_len, start, step_val, mode)));
}

fn ring_SetBounds(p: *anyopaque) callconv(.c) void {
    const name: [*]const u8 = @ptrCast(gs(p, 1));
    const name_len: usize = @intCast(gl(p, 1));
    const min_v: i64 = @intFromFloat(gn(p, 2));
    const max_v: i64 = @intFromFloat(gn(p, 3));
    rn(p, @floatFromInt(mod.stz_seq_set_bounds(name, name_len, min_v, max_v)));
}

fn ring_Next(p: *anyopaque) callconv(.c) void {
    const name: [*]const u8 = @ptrCast(gs(p, 1));
    const name_len: usize = @intCast(gl(p, 1));
    rn(p, @floatFromInt(mod.stz_seq_next(name, name_len)));
}

fn ring_Current(p: *anyopaque) callconv(.c) void {
    const name: [*]const u8 = @ptrCast(gs(p, 1));
    const name_len: usize = @intCast(gl(p, 1));
    rn(p, @floatFromInt(mod.stz_seq_current(name, name_len)));
}

fn ring_Iteration(p: *anyopaque) callconv(.c) void {
    const name: [*]const u8 = @ptrCast(gs(p, 1));
    const name_len: usize = @intCast(gl(p, 1));
    rn(p, @floatFromInt(mod.stz_seq_iteration(name, name_len)));
}

fn ring_Reset(p: *anyopaque) callconv(.c) void {
    const name: [*]const u8 = @ptrCast(gs(p, 1));
    const name_len: usize = @intCast(gl(p, 1));
    mod.stz_seq_reset(name, name_len);
    rn(p, 1);
}

fn ring_Count(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_seq_count()));
}

fn ring_Destroy(p: *anyopaque) callconv(.c) void {
    const name: [*]const u8 = @ptrCast(gs(p, 1));
    const name_len: usize = @intCast(gl(p, 1));
    mod.stz_seq_destroy(name, name_len);
    rn(p, 1);
}

fn ring_Clear(p: *anyopaque) callconv(.c) void {
    _ = p;
    mod.stz_seq_clear();
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = @constCast("stzengineseqcreate"), .func = ring_Create },
    .{ .name = @constCast("stzengineseqsetbounds"), .func = ring_SetBounds },
    .{ .name = @constCast("stzengineseqnext"), .func = ring_Next },
    .{ .name = @constCast("stzengineseqcurrent"), .func = ring_Current },
    .{ .name = @constCast("stzengineseqiteration"), .func = ring_Iteration },
    .{ .name = @constCast("stzengineseqreset"), .func = ring_Reset },
    .{ .name = @constCast("stzengineseqcount"), .func = ring_Count },
    .{ .name = @constCast("stzengineseqdestroy"), .func = ring_Destroy },
    .{ .name = @constCast("stzengineseqclear"), .func = ring_Clear },
};
