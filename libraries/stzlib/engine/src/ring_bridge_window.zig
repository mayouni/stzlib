// Ring bridge for stz_window -- windows and input (GR5).
//
// Deliberately small. This DLL owns exactly one thing the rest of the
// engine cannot own portably: a native window. It never touches wgpu; it
// hands out the OS handle and stz_gpu makes a surface from it.
const std = @import("std");
const win = @import("window.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const rn = R.ring_vm_api_retnumber;
const allocator = std.heap.c_allocator;

fn getStr(p: *anyopaque, n: c_int) []const u8 {
    const ptr = R.ring_vm_api_getstring(p, n);
    const len = R.ring_vm_api_getstringsize(p, n);
    return ptr[0..len];
}

fn ring_IsAvailable(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(win.isAvailable()));
}

fn ring_LastError(p: *anyopaque) callconv(.c) void {
    const e = win.lastError();
    R.ring_vm_api_retstring2(p, e.ptr, @intCast(e.len));
}

fn ring_New(p: *anyopaque) callconv(.c) void {
    const title = getStr(p, 3);
    const z = allocator.dupeZ(u8, title) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(z);
    rn(p, @floatFromInt(win.windowNew(@intFromFloat(gn(p, 1)), @intFromFloat(gn(p, 2)), z)));
}

fn ring_Free(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(win.windowFree(@intFromFloat(gn(p, 1)))));
}

fn ring_NativeHandle(p: *anyopaque) callconv(.c) void {
    rn(p, win.nativeHandle(@intFromFloat(gn(p, 1))));
}

fn ring_NativeDisplay(p: *anyopaque) callconv(.c) void {
    rn(p, win.nativeDisplay(@intFromFloat(gn(p, 1))));
}

fn ring_IsOpen(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(win.isOpen(@intFromFloat(gn(p, 1)))));
}

fn ring_RequestClose(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(win.requestClose(@intFromFloat(gn(p, 1)))));
}

fn ring_Poll(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(win.poll(@intFromFloat(gn(p, 1)))));
}

fn ring_Width(p: *anyopaque) callconv(.c) void {
    rn(p, win.width(@intFromFloat(gn(p, 1))));
}

fn ring_Height(p: *anyopaque) callconv(.c) void {
    rn(p, win.height(@intFromFloat(gn(p, 1))));
}

fn ring_WasResized(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(win.wasResized(@intFromFloat(gn(p, 1)))));
}

fn ring_DeltaTime(p: *anyopaque) callconv(.c) void {
    rn(p, win.deltaTime(@intFromFloat(gn(p, 1))));
}

fn ring_FrameCount(p: *anyopaque) callconv(.c) void {
    rn(p, win.frameCount(@intFromFloat(gn(p, 1))));
}

fn ring_KeyDown(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(win.keyDown(@intFromFloat(gn(p, 1)), @intFromFloat(gn(p, 2)))));
}

fn ring_KeyPressed(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(win.keyPressed(@intFromFloat(gn(p, 1)), @intFromFloat(gn(p, 2)))));
}

fn ring_MouseX(p: *anyopaque) callconv(.c) void {
    rn(p, win.mouseX(@intFromFloat(gn(p, 1))));
}

fn ring_MouseY(p: *anyopaque) callconv(.c) void {
    rn(p, win.mouseY(@intFromFloat(gn(p, 1))));
}

fn ring_MouseDown(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(win.mouseDown(@intFromFloat(gn(p, 1)), @intFromFloat(gn(p, 2)))));
}

fn ring_MouseClicked(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(win.mouseClicked(@intFromFloat(gn(p, 1)), @intFromFloat(gn(p, 2)))));
}

fn ring_SetTitle(p: *anyopaque) callconv(.c) void {
    const title = getStr(p, 2);
    const z = allocator.dupeZ(u8, title) catch {
        rn(p, 0);
        return;
    };
    defer allocator.free(z);
    rn(p, @floatFromInt(win.setTitle(@intFromFloat(gn(p, 1)), z)));
}

fn ring_Shutdown(p: *anyopaque) callconv(.c) void {
    win.shutdown();
    rn(p, 1);
}

pub const regs = [_]R.Reg{
    .{ .name = "stzenginewindowisavailable", .func = &ring_IsAvailable },
    .{ .name = "stzenginewindowlasterror", .func = &ring_LastError },
    .{ .name = "stzenginewindownew", .func = &ring_New },
    .{ .name = "stzenginewindowfree", .func = &ring_Free },
    .{ .name = "stzenginewindownativehandle", .func = &ring_NativeHandle },
    .{ .name = "stzenginewindownativedisplay", .func = &ring_NativeDisplay },
    .{ .name = "stzenginewindowisopen", .func = &ring_IsOpen },
    .{ .name = "stzenginewindowrequestclose", .func = &ring_RequestClose },
    .{ .name = "stzenginewindowpoll", .func = &ring_Poll },
    .{ .name = "stzenginewindowwidth", .func = &ring_Width },
    .{ .name = "stzenginewindowheight", .func = &ring_Height },
    .{ .name = "stzenginewindowwasresized", .func = &ring_WasResized },
    .{ .name = "stzenginewindowdeltatime", .func = &ring_DeltaTime },
    .{ .name = "stzenginewindowframecount", .func = &ring_FrameCount },
    .{ .name = "stzenginewindowkeydown", .func = &ring_KeyDown },
    .{ .name = "stzenginewindowkeypressed", .func = &ring_KeyPressed },
    .{ .name = "stzenginewindowmousex", .func = &ring_MouseX },
    .{ .name = "stzenginewindowmousey", .func = &ring_MouseY },
    .{ .name = "stzenginewindowmousedown", .func = &ring_MouseDown },
    .{ .name = "stzenginewindowmouseclicked", .func = &ring_MouseClicked },
    .{ .name = "stzenginewindowsettitle", .func = &ring_SetTitle },
    .{ .name = "stzenginewindowshutdown", .func = &ring_Shutdown },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
