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

// FontRegister(cFamily, cBytes) -> 0 on success. G2: the family name a
// document's font-family refers to, bound to real TTF/OTF bytes -- the
// SAME bytes the caller gives stzFont, so measuring (this DLL) and
// painting (stz_gpu.dll) hold the identical file.
fn ring_FontRegister(p: *anyopaque) callconv(.c) void {
    const family = getStr(p, 1);
    const z = allocator.dupeZ(u8, family) catch {
        rn(p, gui.BAD_ARG);
        return;
    };
    defer allocator.free(z);
    rn(p, @floatFromInt(gui.fontRegister(z, getStr(p, 2))));
}

fn ring_FontCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gui.fontCount()));
}

// Texts() -> [ [nFontId, nSize, nX, nY, nColour, cUtf8], ... ] -- the
// text commands the last render recorded. nFontId names a font in THIS
// DLL's table and is useless to stz_gpu; the Ring face matches commands
// to its own stzFont objects by the family it registered. (nX, nY) is
// the BASELINE origin, the same convention stzCanvas.AddText takes.
fn ring_Texts(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    const n = gui.textCount();
    var i: i32 = 0;
    while (i < n) : (i += 1) {
        const t = gui.textAt(i) orelse continue;
        const item = R.ring_list_newlist(out) orelse continue;
        R.ring_list_adddouble(item, @floatFromInt(t.font));
        R.ring_list_adddouble(item, t.size);
        R.ring_list_adddouble(item, t.x);
        R.ring_list_adddouble(item, t.y);
        R.ring_list_adddouble(item, @floatFromInt(t.colour));
        R.ring_list_addstring2(item, t.text.ptr, @intCast(t.text.len));
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

// ---------------------------------------------------------- G3: input

fn ring_PointerMove(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gui.pointerMove(@intFromFloat(gn(p, 1)), @floatCast(gn(p, 2)), @floatCast(gn(p, 3)), @intFromFloat(gn(p, 4)))));
}

fn ring_PointerButton(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gui.pointerButton(@intFromFloat(gn(p, 1)), @intFromFloat(gn(p, 2)), gn(p, 3) != 0, @intFromFloat(gn(p, 4)))));
}

fn ring_PointerLeave(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gui.pointerLeave(@intFromFloat(gn(p, 1)))));
}

fn ring_Key(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gui.key(@intFromFloat(gn(p, 1)), @intFromFloat(gn(p, 2)), gn(p, 3) != 0, @intFromFloat(gn(p, 4)))));
}

fn ring_TextInput(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gui.textInput(@intFromFloat(gn(p, 1)), getStr(p, 2))));
}

fn ring_SetInputSource(p: *anyopaque) callconv(.c) void {
    gui.setInputSource(@intFromFloat(gn(p, 1)));
    rn(p, 0);
}

fn ring_Focus(p: *anyopaque) callconv(.c) void {
    const name = getStr(p, 2);
    const z = allocator.dupeZ(u8, name) catch {
        rn(p, gui.BAD_ARG);
        return;
    };
    defer allocator.free(z);
    rn(p, @floatFromInt(gui.focus(@intFromFloat(gn(p, 1)), z)));
}

fn ring_Focused(p: *anyopaque) callconv(.c) void {
    const e = gui.focused(@intFromFloat(gn(p, 1)));
    R.ring_vm_api_retstring2(p, e.ptr, @intCast(e.len));
}

fn ring_FocusMove(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gui.focusMove(@intFromFloat(gn(p, 1)), @intFromFloat(gn(p, 2)))));
}

fn ring_ElementAt(p: *anyopaque) callconv(.c) void {
    const e = gui.elementAt(@intFromFloat(gn(p, 1)), @floatCast(gn(p, 2)), @floatCast(gn(p, 3)));
    R.ring_vm_api_retstring2(p, e.ptr, @intCast(e.len));
}

// Events() -> [ [ nKind, nSource, nX, nY, nButton, nKey, nMods, cTarget ], ... ]
// DRAINED by the caller, never dispatched: Ring cannot be re-entered
// safely from a C++ event dispatch, and the house has settled this shape
// twice already (the display list, the text commands).
fn ring_Events(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    const n = gui.eventCount();
    var i: i32 = 0;
    while (i < n) : (i += 1) {
        const e = gui.eventAt(i) orelse continue;
        const item = R.ring_list_newlist(out) orelse continue;
        R.ring_list_adddouble(item, @floatFromInt(e.kind));
        R.ring_list_adddouble(item, @floatFromInt(e.source));
        R.ring_list_adddouble(item, e.x);
        R.ring_list_adddouble(item, e.y);
        R.ring_list_adddouble(item, @floatFromInt(e.button));
        R.ring_list_adddouble(item, @floatFromInt(e.key));
        R.ring_list_adddouble(item, @floatFromInt(e.mods));
        R.ring_list_addstring2(item, e.target.ptr, @intCast(e.target.len));
    }
    R.ring_vm_api_retlist(p, out);
}

fn ring_EventsClear(p: *anyopaque) callconv(.c) void {
    gui.eventsClear();
    rn(p, 0);
}

fn ring_EventsDropped(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gui.eventsDropped()));
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
    .{ .name = "stzengineguifontregister", .func = &ring_FontRegister },
    .{ .name = "stzengineguifontcount", .func = &ring_FontCount },
    .{ .name = "stzengineguitexts", .func = &ring_Texts },
    .{ .name = "stzengineguipointermove", .func = &ring_PointerMove },
    .{ .name = "stzengineguipointerbutton", .func = &ring_PointerButton },
    .{ .name = "stzengineguipointerleave", .func = &ring_PointerLeave },
    .{ .name = "stzengineguikey", .func = &ring_Key },
    .{ .name = "stzengineguitextinput", .func = &ring_TextInput },
    .{ .name = "stzengineguisetinputsource", .func = &ring_SetInputSource },
    .{ .name = "stzengineguifocus", .func = &ring_Focus },
    .{ .name = "stzengineguifocused", .func = &ring_Focused },
    .{ .name = "stzengineguifocusmove", .func = &ring_FocusMove },
    .{ .name = "stzengineguielementat", .func = &ring_ElementAt },
    .{ .name = "stzengineguievents", .func = &ring_Events },
    .{ .name = "stzengineguieventsclear", .func = &ring_EventsClear },
    .{ .name = "stzengineguieventsdropped", .func = &ring_EventsDropped },
    .{ .name = "stzengineguisettime", .func = &ring_SetTime },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
