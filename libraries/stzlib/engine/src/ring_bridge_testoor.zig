//! Testoor core -- the Ring bridge. Five calls, each takes one string and answers one string
//! (or a number): the request formats are the golden logbooks' own, see testoor_api.zig.
//! A call allocates from an arena that dies with it and copies the answer out through
//! retstring2, which is length-aware, so a byte 0 in a tour's output cannot cut it.
//! A request the core cannot read raises a Ring error the caller can `try`/`catch`.

const api = @import("testoor_api.zig");
const R = @import("ring_api.zig");
const std = @import("std");

const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rs2 = R.ring_vm_api_retstring2;
const rn = R.ring_vm_api_retnumber;

fn raise(p: *anyopaque, e: api.Error) void {
    switch (e) {
        error.BadRequest => R.ring_vm_error(p, "Testoor: the request is missing a field the core reads"),
        error.BadJson => R.ring_vm_error(p, "Testoor: the request is not a JSON document"),
        error.BadOutputLine => R.ring_vm_error(p, "Testoor: a line of the tour's output has no numeric arrival time"),
        error.OutOfMemory => R.ring_vm_error(p, "Testoor: out of memory"),
    }
}

fn request(p: *anyopaque) ?[]const u8 {
    if (R.ring_vm_api_paracount(p) != 1 or R.ring_vm_api_isstring(p, 1) == 0) {
        R.ring_vm_error(p, "Testoor: one string argument is expected");
        return null;
    }
    return gs(p, 1)[0..@as(usize, @intCast(gss(p, 1)))];
}

fn ring_Verdict(p: *anyopaque) callconv(.c) void {
    const req = request(p) orelse return;
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const out = api.verdictJson(arena.allocator(), req) catch |e| return raise(p, e);
    rs2(p, out.ptr, @intCast(out.len));
}

fn ring_RunJson(p: *anyopaque) callconv(.c) void {
    const req = request(p) orelse return;
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const out = api.runJson(arena.allocator(), req) catch |e| return raise(p, e);
    rs2(p, out.ptr, @intCast(out.len));
}

fn ring_RunProse(p: *anyopaque) callconv(.c) void {
    const req = request(p) orelse return;
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const out = api.runProse(arena.allocator(), req) catch |e| return raise(p, e);
    rs2(p, out.ptr, @intCast(out.len));
}

fn ring_RunExit(p: *anyopaque) callconv(.c) void {
    const req = request(p) orelse return;
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const code = api.runExit(arena.allocator(), req) catch |e| return raise(p, e);
    rn(p, @floatFromInt(code));
}

fn ring_TourProse(p: *anyopaque) callconv(.c) void {
    const req = request(p) orelse return;
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const out = api.tourProseJson(arena.allocator(), req) catch |e| return raise(p, e);
    rs2(p, out.ptr, @intCast(out.len));
}

const regs = [_]R.Reg{
    .{ .name = "stzenginetestoorverdict", .func = ring_Verdict },
    .{ .name = "stzenginetestoorrunjson", .func = ring_RunJson },
    .{ .name = "stzenginetestoorrunprose", .func = ring_RunProse },
    .{ .name = "stzenginetestoorrunexit", .func = ring_RunExit },
    .{ .name = "stzenginetestoortourprose", .func = ring_TourProse },
};

pub fn registerAll(state: *anyopaque) void {
    R.registerAll(state, &regs);
}
