// Ring bridge for stz_gui -- layout and markup (G1 of the GUI plane).
//
// Deliberately small, like the window bridge. This DLL owns exactly one
// thing the rest of the engine cannot own on stz_gpu's terms: RmlUi,
// which needs C++ exceptions AND RTTI (measured in G0). It never touches
// wgpu and never paints; it hands out a DISPLAY LIST, and the graphics
// plane draws it.
const std = @import("std");
const gui = @import("gui.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const rn = R.ring_vm_api_retnumber;
const allocator = std.heap.c_allocator;

fn getStr(p: *anyopaque, n: c_int) []const u8 {
    const ptr = R.ring_vm_api_getstring(p, n);
    const len = R.ring_vm_api_getstringsize(p, n);
    return ptr[0..len];
}

fn ring_Init(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gui.init()));
}

fn ring_IsAvailable(p: *anyopaque) callconv(.c) void {
    // Availability is "the DLL loaded AND RmlUi initialised". A machine
    // without this DLL never reaches here at all, which is the graceful
    // absence the window tier already established.
    rn(p, if (gui.init() == gui.OK) 1 else 0);
}

fn ring_Shutdown(p: *anyopaque) callconv(.c) void {
    gui.shutdown();
    rn(p, 0);
}

fn ring_ContextNew(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gui.contextNew(@intFromFloat(gn(p, 1)), @intFromFloat(gn(p, 2)))));
}

fn ring_ContextFree(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gui.contextFree(@intFromFloat(gn(p, 1)))));
}

fn ring_ContextResize(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gui.contextResize(@intFromFloat(gn(p, 1)), @intFromFloat(gn(p, 2)), @intFromFloat(gn(p, 3)))));
}

fn ring_LoadRml(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gui.loadRml(@intFromFloat(gn(p, 1)), getStr(p, 2))));
}

fn ring_Update(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gui.update(@intFromFloat(gn(p, 1)))));
}

fn ring_Render(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gui.render(@intFromFloat(gn(p, 1)))));
}

// Verts() -> a FLAT list of x,y,r,g,b,a per vertex -- the exact shape
// stzCanvas.AddMesh takes, so a panel reaches pixels without Ring
// reshaping anything.
fn ring_Verts(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    for (gui.verts()) |v| R.ring_list_adddouble(out, v);
    R.ring_vm_api_retlist(p, out);
}

// Indices() -> flat 0-based triangle indices.
fn ring_Indices(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    for (gui.indices()) |v| R.ring_list_adddouble(out, @floatFromInt(v));
    R.ring_vm_api_retlist(p, out);
}

// Counters() -> [draws, droppedTexturedDraws, ignoredScissors,
//                widthCalls, generateCalls, keyboardActivations].
// The bounded record's own account of what it drew and what it could not
// -- the house rule is that a record COUNTS what it drops.
fn ring_Counters(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    for (gui.counters()) |v| R.ring_list_adddouble(out, @floatFromInt(v));
    R.ring_vm_api_retlist(p, out);
}

// ElementBox(hCtx, cId) -> [x, y, w, h] or [] when there is no such
// element. The laid-out geometry, which is what an inspector reads.
fn ring_ElementBox(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    const name = getStr(p, 2);
    const z = allocator.dupeZ(u8, name) catch {
        R.ring_vm_api_retlist(p, out);
        return;
    };
    defer allocator.free(z);
    var box: [4]f32 = .{ 0, 0, 0, 0 };
    if (gui.elementBox(@intFromFloat(gn(p, 1)), z, &box) == gui.OK) {
        for (box) |v| R.ring_list_adddouble(out, v);
    }
    R.ring_vm_api_retlist(p, out);
}

fn ring_LastError(p: *anyopaque) callconv(.c) void {
    const e = gui.lastError();
    R.ring_vm_api_retstring2(p, e.ptr, @intCast(e.len));
}

fn ring_SetTime(p: *anyopaque) callconv(.c) void {
    gui.setTime(gn(p, 1));
    rn(p, 0);
}

const regs = [_]R.Reg{
    .{ .name = "stzengineguiinit", .func = &ring_Init },
    .{ .name = "stzengineguiisavailable", .func = &ring_IsAvailable },
    .{ .name = "stzengineguishutdown", .func = &ring_Shutdown },
    .{ .name = "stzengineguicontextnew", .func = &ring_ContextNew },
    .{ .name = "stzengineguicontextfree", .func = &ring_ContextFree },
    .{ .name = "stzengineguicontextresize", .func = &ring_ContextResize },
    .{ .name = "stzengineguiloadrml", .func = &ring_LoadRml },
    .{ .name = "stzengineguiupdate", .func = &ring_Update },
    .{ .name = "stzengineguirender", .func = &ring_Render },
    .{ .name = "stzengineguiverts", .func = &ring_Verts },
    .{ .name = "stzengineguiindices", .func = &ring_Indices },
    .{ .name = "stzengineguicounters", .func = &ring_Counters },
    .{ .name = "stzengineguielementbox", .func = &ring_ElementBox },
    .{ .name = "stzengineguilasterror", .func = &ring_LastError },
    .{ .name = "stzengineguisettime", .func = &ring_SetTime },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
