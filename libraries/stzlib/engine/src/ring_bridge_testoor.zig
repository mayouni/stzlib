//! Testoor core -- the Ring bridge. Five calls, each takes one string and answers one string
//! (or a number): the request formats are the golden logbooks' own, see testoor_api.zig.
//! A call allocates from an arena that dies with it and copies the answer out through
//! retstring2, which is length-aware, so a byte 0 in a tour's output cannot cut it.
//! A request the core cannot read raises a Ring error the caller can `try`/`catch`.

const api = @import("testoor_api.zig");
const T = @import("testoor_text.zig");
const clock = @import("testoor_clock.zig");
const counters_mod = @import("testoor_counters.zig");
const R = @import("ring_api.zig");
const std = @import("std");

const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rs2 = R.ring_vm_api_retstring2;
const rn = R.ring_vm_api_retnumber;

/// One scratch arena per thread, reused by every call. A fresh arena over the page allocator costs a
/// system allocation per call -- measured at 10.8 us a call, as slow as the Ring trace hook -- and a
/// reused one costs nothing once it has grown to the size the calls need (up to 1 MB is kept).
threadlocal var scratch_arena: ?std.heap.ArenaAllocator = null;

fn scratchArena() *std.heap.ArenaAllocator {
    if (scratch_arena == null) scratch_arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    return &scratch_arena.?;
}

fn scratchDone(a: *std.heap.ArenaAllocator) void {
    _ = a.reset(.{ .retain_with_limit = 1 << 20 });
}

fn raise(p: *anyopaque, e: api.Error) void {
    switch (e) {
        error.BadRequest => R.ring_vm_error(p, "Testoor: the request is missing a field the core reads"),
        error.BadJson => R.ring_vm_error(p, "Testoor: the request is not a JSON document"),
        error.BadOutputLine => R.ring_vm_error(p, "Testoor: a line of the tour's output has no numeric arrival time"),
        error.OutOfMemory => R.ring_vm_error(p, "Testoor: out of memory"),
        error.BadDomain => R.ring_vm_error(p, "Testoor: the domain cannot be read, or the input is not one of its values"),
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
    const arena = scratchArena();
    defer scratchDone(arena);
    const out = api.verdictJson(arena.allocator(), req) catch |e| return raise(p, e);
    rs2(p, out.ptr, @intCast(out.len));
}

fn ring_RunJson(p: *anyopaque) callconv(.c) void {
    const req = request(p) orelse return;
    const arena = scratchArena();
    defer scratchDone(arena);
    const out = api.runJson(arena.allocator(), req) catch |e| return raise(p, e);
    rs2(p, out.ptr, @intCast(out.len));
}

fn ring_RunProse(p: *anyopaque) callconv(.c) void {
    const req = request(p) orelse return;
    const arena = scratchArena();
    defer scratchDone(arena);
    const out = api.runProse(arena.allocator(), req) catch |e| return raise(p, e);
    rs2(p, out.ptr, @intCast(out.len));
}

fn ring_RunExit(p: *anyopaque) callconv(.c) void {
    const req = request(p) orelse return;
    const arena = scratchArena();
    defer scratchDone(arena);
    const code = api.runExit(arena.allocator(), req) catch |e| return raise(p, e);
    rn(p, @floatFromInt(code));
}

fn ring_TourProse(p: *anyopaque) callconv(.c) void {
    const req = request(p) orelse return;
    const arena = scratchArena();
    defer scratchDone(arena);
    const out = api.tourProseJson(arena.allocator(), req) catch |e| return raise(p, e);
    rs2(p, out.ptr, @intCast(out.len));
}

fn ring_Property(p: *anyopaque) callconv(.c) void {
    const req = request(p) orelse return;
    const arena = scratchArena();
    defer scratchDone(arena);
    const out = api.propertyJson(arena.allocator(), req) catch |e| return raise(p, e);
    rs2(p, out.ptr, @intCast(out.len));
}

fn ring_Impact(p: *anyopaque) callconv(.c) void {
    const req = request(p) orelse return;
    const arena = scratchArena();
    defer scratchDone(arena);
    const out = api.impactJson(arena.allocator(), req) catch |e| return raise(p, e);
    rs2(p, out.ptr, @intCast(out.len));
}

fn ring_Routes(p: *anyopaque) callconv(.c) void {
    const req = request(p) orelse return;
    const arena = scratchArena();
    defer scratchDone(arena);
    const out = api.routesJson(arena.allocator(), req) catch |e| return raise(p, e);
    rs2(p, out.ptr, @intCast(out.len));
}

fn ring_RoutesProse(p: *anyopaque) callconv(.c) void {
    const req = request(p) orelse return;
    const arena = scratchArena();
    defer scratchDone(arena);
    const out = api.routesProse(arena.allocator(), req) catch |e| return raise(p, e);
    rs2(p, out.ptr, @intCast(out.len));
}

/// The node counters of one tour (P3.4): one set per thread, in the engine, never in a Ring object.
/// The HOT calls (NodeSlot once, NodeHit per event) take and return numbers and allocate nothing.
threadlocal var nodes: counters_mod.Counters = .{};

fn toSlot(v: f64) u32 {
    if (!(v >= 1) or v > 4.0e9) return 0;
    return @intFromFloat(v);
}

fn toCount(v: f64) u64 {
    if (!(v >= 0)) return 0;
    if (v >= 1.0e15) return counters_mod.max_hits;
    return @intFromFloat(v);
}

/// StzEngineTestoorNodeSlot(cId) -> the slot of a node, registering it; 0 when the id cannot be a node line's
fn ring_NodeSlot(p: *anyopaque) callconv(.c) void {
    if (R.ring_vm_api_paracount(p) != 1 or R.ring_vm_api_isstring(p, 1) == 0) {
        R.ring_vm_error(p, "Testoor: NodeSlot wants one string, the node's id");
        return;
    }
    const id = gs(p, 1)[0..@as(usize, @intCast(gss(p, 1)))];
    const k = nodes.slot(std.heap.page_allocator, id) catch return R.ring_vm_error(p, "Testoor: out of memory");
    rn(p, @floatFromInt(k));
}

/// StzEngineTestoorNodeHit(nSlot [, nHits]) -> the count after; 0 for a slot never registered
fn ring_NodeHit(p: *anyopaque) callconv(.c) void {
    const n = R.ring_vm_api_paracount(p);
    if ((n != 1 and n != 2) or R.ring_vm_api_isnumber(p, 1) == 0 or (n == 2 and R.ring_vm_api_isnumber(p, 2) == 0)) {
        R.ring_vm_error(p, "Testoor: NodeHit wants a slot and, optionally, a number of hits");
        return;
    }
    const by: u64 = if (n == 2) toCount(R.ring_vm_api_getnumber(p, 2)) else 1;
    rn(p, @floatFromInt(nodes.hit(toSlot(R.ring_vm_api_getnumber(p, 1)), by)));
}

/// StzEngineTestoorNodeHitId(cId [, nHits]) -> the count after; 0 for an id that cannot be a node line's
fn ring_NodeHitId(p: *anyopaque) callconv(.c) void {
    const n = R.ring_vm_api_paracount(p);
    if ((n != 1 and n != 2) or R.ring_vm_api_isstring(p, 1) == 0 or (n == 2 and R.ring_vm_api_isnumber(p, 2) == 0)) {
        R.ring_vm_error(p, "Testoor: NodeHitId wants an id and, optionally, a number of hits");
        return;
    }
    const id = gs(p, 1)[0..@as(usize, @intCast(gss(p, 1)))];
    const by: u64 = if (n == 2) toCount(R.ring_vm_api_getnumber(p, 2)) else 1;
    const c = nodes.hitId(std.heap.page_allocator, id, by) catch return R.ring_vm_error(p, "Testoor: out of memory");
    rn(p, @floatFromInt(c));
}

/// StzEngineTestoorNodes(cOp, cText) -> a string. report: the `[testoor node ID N]` lines, one to a line;
/// registered: how many ids; get: the count of the id in cText; reset: every count to zero, slots kept
fn ring_Nodes(p: *anyopaque) callconv(.c) void {
    if (R.ring_vm_api_paracount(p) != 2 or R.ring_vm_api_isstring(p, 1) == 0 or R.ring_vm_api_isstring(p, 2) == 0) {
        R.ring_vm_error(p, "Testoor: Nodes wants (operation, text)");
        return;
    }
    const op = gs(p, 1)[0..@as(usize, @intCast(gss(p, 1)))];
    const text = gs(p, 2)[0..@as(usize, @intCast(gss(p, 2)))];
    const arena = scratchArena();
    defer scratchDone(arena);
    const a = arena.allocator();
    if (std.mem.eql(u8, op, "report")) {
        var b = T.Buf.init(a);
        nodes.report(&b) catch return R.ring_vm_error(p, "Testoor: out of memory");
        const out = b.done() catch return R.ring_vm_error(p, "Testoor: out of memory");
        rs2(p, out.ptr, @intCast(out.len));
        return;
    }
    const out: []u8 = blk: {
        if (std.mem.eql(u8, op, "registered")) break :blk std.fmt.allocPrint(a, "{d}", .{nodes.registered()}) catch return R.ring_vm_error(p, "Testoor: out of memory");
        if (std.mem.eql(u8, op, "get")) break :blk std.fmt.allocPrint(a, "{d}", .{nodes.count(text)}) catch return R.ring_vm_error(p, "Testoor: out of memory");
        if (std.mem.eql(u8, op, "reset")) {
            nodes.reset();
            break :blk a.dupe(u8, "1") catch return R.ring_vm_error(p, "Testoor: out of memory");
        }
        return R.ring_vm_error(p, "Testoor: unknown nodes operation");
    };
    rs2(p, out.ptr, @intCast(out.len));
}

/// The world of one tour: its seed, its stepped clock and its weather. Ring keeps ONE of these
/// per virtual machine as a global, so the engine keeps one per thread; the state is in the
/// engine, never in a Ring object, because Ring copies an object it stores (CLAUDE.md,
/// "engine-wrapper copy law"). The call is `(cOp, cText, nA, nB)` -> string: see testoor_clock.zig.
threadlocal var world: clock.World = .{};

fn ring_World(p: *anyopaque) callconv(.c) void {
    if (R.ring_vm_api_paracount(p) != 4 or R.ring_vm_api_isstring(p, 1) == 0 or R.ring_vm_api_isstring(p, 2) == 0 or
        R.ring_vm_api_isnumber(p, 3) == 0 or R.ring_vm_api_isnumber(p, 4) == 0)
    {
        R.ring_vm_error(p, "Testoor: the world call wants (operation, text, number, number)");
        return;
    }
    const op = gs(p, 1)[0..@as(usize, @intCast(gss(p, 1)))];
    const text = gs(p, 2)[0..@as(usize, @intCast(gss(p, 2)))];
    const arena = scratchArena();
    defer scratchDone(arena);
    // the weather list lives past the call, so it takes the page allocator, not the arena
    const out = clock.call(&world, std.heap.page_allocator, arena.allocator(), op, text, R.ring_vm_api_getnumber(p, 3), R.ring_vm_api_getnumber(p, 4)) catch |e| switch (e) {
        error.UnknownOp => return R.ring_vm_error(p, "Testoor: unknown world operation"),
        error.OutOfMemory => return R.ring_vm_error(p, "Testoor: out of memory"),
    };
    rs2(p, out.ptr, @intCast(out.len));
}

const regs = [_]R.Reg{
    .{ .name = "stzenginetestoorworld", .func = ring_World },
    .{ .name = "stzenginetestoornodeslot", .func = ring_NodeSlot },
    .{ .name = "stzenginetestoornodehit", .func = ring_NodeHit },
    .{ .name = "stzenginetestoornodehitid", .func = ring_NodeHitId },
    .{ .name = "stzenginetestoornodes", .func = ring_Nodes },
    .{ .name = "stzenginetestoorimpact", .func = ring_Impact },
    .{ .name = "stzenginetestoorproperty", .func = ring_Property },
    .{ .name = "stzenginetestoorroutes", .func = ring_Routes },
    .{ .name = "stzenginetestoorroutesprose", .func = ring_RoutesProse },
    .{ .name = "stzenginetestoorverdict", .func = ring_Verdict },
    .{ .name = "stzenginetestoorrunjson", .func = ring_RunJson },
    .{ .name = "stzenginetestoorrunprose", .func = ring_RunProse },
    .{ .name = "stzenginetestoorrunexit", .func = ring_RunExit },
    .{ .name = "stzenginetestoortourprose", .func = ring_TourProse },
};

pub fn registerAll(state: *anyopaque) void {
    R.registerAll(state, &regs);
}
