//! stz_window -- windows and input, GR5 of SOFTANZA_GRAPHICS_PLAN.md.
//!
//! ITS OWN DLL, and that is a measured decision rather than a preference:
//! GLFW is the only vendored dependency that cannot cross-compile from a
//! Windows box (Zig bundles libc, not X11 or Cocoa; Apple's frameworks are
//! not redistributable). Linking it into stz_gpu.dll would have cost the
//! GPU plane its cross-compilability, which is already a guarded property.
//! So the engine stays portable and only the window is per-OS.
//!
//! WHAT THIS MODULE DOES NOT DO: it never touches wgpu. It hands out the
//! NATIVE handle (an HWND / X11 window / NSWindow), and stz_gpu makes the
//! surface from it. That keeps the house law intact -- engine handles never
//! cross DLLs -- because an OS window handle is not an engine handle.
//!
//! §3b door 5, taken at the start rather than retrofitted: presentation is
//! a LOOP WITH INPUT, with delta time, not "render once and show a window".
//! A frame loop bolted onto a render-once API is a rewrite, so the shape is
//! here from the first commit:
//!
//!     while (window is open) { poll -> read input -> draw -> present }
//!
//! Windows are gen-keyed handles in the same discipline as every other
//! table in this engine.

const std = @import("std");

const c = @cImport({
    @cDefine("GLFW_INCLUDE_NONE", "1"); // we bring our own graphics API
    @cInclude("GLFW/glfw3.h");
});

const alloc = std.heap.c_allocator;

pub const OK: i32 = 0;
pub const FALLBACK: i32 = 1; // no windowing available on this machine
pub const STALE: i32 = 2;
pub const BAD_ARG: i32 = 3;

// ---------------------------------------------------------------- state

var glfw_ready = false;
var glfw_failed = false;
var last_error_buf: [256]u8 = @splat(0);
var last_error_len: usize = 0;

fn setErr(msg: []const u8) void {
    const n = @min(msg.len, last_error_buf.len);
    @memcpy(last_error_buf[0..n], msg[0..n]);
    last_error_len = n;
}

pub fn lastError() []const u8 {
    return last_error_buf[0..last_error_len];
}

fn onGlfwError(code: c_int, desc: [*c]const u8) callconv(.c) void {
    _ = code;
    if (desc != null) setErr(std.mem.span(desc));
}

/// Initialise GLFW ONCE. A machine with no display (CI, a headless server,
/// an SSH session) fails here, and that is a COUNTED refusal, not a crash:
/// every entry point below answers FALLBACK from then on.
fn ensureGlfw() bool {
    if (glfw_ready) return true;
    if (glfw_failed) return false;
    _ = c.glfwSetErrorCallback(onGlfwError);
    if (c.glfwInit() == 0) {
        glfw_failed = true;
        if (last_error_len == 0) setErr("glfwInit failed (no display?)");
        return false;
    }
    glfw_ready = true;
    return true;
}

const KEY_SLOTS = 512;

const WinSlot = struct {
    handle: ?*c.GLFWwindow = null,
    gen: u32 = 1,
    live: bool = false,
    // input state, sampled at Poll() so a frame sees ONE consistent picture
    keys: [KEY_SLOTS]bool = @splat(false),
    keys_pressed: [KEY_SLOTS]bool = @splat(false), // edge, cleared each poll
    mouse_x: f64 = 0,
    mouse_y: f64 = 0,
    mouse_down: [8]bool = @splat(false),
    mouse_clicked: [8]bool = @splat(false),
    width: i32 = 0,
    height: i32 = 0,
    resized: bool = false,
    last_time: f64 = 0,
    delta: f64 = 0,
    frames: u64 = 0,
};

var windows: std.ArrayList(WinSlot) = .{};

fn makeId(slot: usize, gen: u32) i64 {
    return (@as(i64, gen) << 32) | @as(i64, @intCast(slot + 1));
}

fn slotOf(id: i64) ?usize {
    const idx = id & 0xffff_ffff;
    if (idx <= 0 or idx > @as(i64, @intCast(windows.items.len))) return null;
    const s: usize = @intCast(idx - 1);
    const gen: u32 = @intCast((id >> 32) & 0xffff_ffff);
    if (!windows.items[s].live or windows.items[s].gen != gen) return null;
    return s;
}

// ---------------------------------------------------------------- api

pub fn isAvailable() i32 {
    return if (ensureGlfw()) 1 else 0;
}

/// Open a window. No graphics API is created for it -- GLFW_NO_API -- because
/// wgpu owns the surface; this only produces something to draw on.
pub fn windowNew(w: i32, h: i32, title: [*:0]const u8) i64 {
    if (!ensureGlfw()) return 0;
    if (w < 1 or h < 1) return 0;
    c.glfwWindowHint(c.GLFW_CLIENT_API, c.GLFW_NO_API);
    c.glfwWindowHint(c.GLFW_VISIBLE, c.GLFW_TRUE);
    const handle = c.glfwCreateWindow(w, h, title, null, null) orelse {
        if (last_error_len == 0) setErr("glfwCreateWindow failed");
        return 0;
    };
    var slot: usize = windows.items.len;
    for (windows.items, 0..) |s, i| {
        if (!s.live) {
            slot = i;
            break;
        }
    }
    if (slot == windows.items.len) {
        windows.append(alloc, .{}) catch {
            c.glfwDestroyWindow(handle);
            return 0;
        };
    }
    const s = &windows.items[slot];
    s.* = .{};
    s.handle = handle;
    s.live = true;
    s.width = w;
    s.height = h;
    s.last_time = c.glfwGetTime();
    return makeId(slot, s.gen);
}

pub fn windowFree(id: i64) i32 {
    const slot = slotOf(id) orelse return STALE;
    const s = &windows.items[slot];
    if (s.handle) |hnd| c.glfwDestroyWindow(hnd);
    s.handle = null;
    s.live = false;
    s.gen +%= 1;
    return OK;
}

/// The NATIVE handle, as a number. This is what stz_gpu turns into a wgpu
/// surface -- an OS handle, not an engine handle, so it may legitimately
/// cross the DLL boundary.
pub fn nativeHandle(id: i64) f64 {
    const slot = slotOf(id) orelse return 0;
    const s = &windows.items[slot];
    const hnd = s.handle orelse return 0;
    return nativeOf(hnd);
}

fn nativeOf(hnd: *c.GLFWwindow) f64 {
    const builtin = @import("builtin");
    switch (builtin.os.tag) {
        .windows => {
            const f = @extern(*const fn (?*c.GLFWwindow) callconv(.c) ?*anyopaque, .{ .name = "glfwGetWin32Window" });
            const p = f(hnd) orelse return 0;
            return @floatFromInt(@intFromPtr(p));
        },
        .linux => {
            const f = @extern(*const fn (?*c.GLFWwindow) callconv(.c) c_ulong, .{ .name = "glfwGetX11Window" });
            return @floatFromInt(f(hnd));
        },
        .macos => {
            const f = @extern(*const fn (?*c.GLFWwindow) callconv(.c) ?*anyopaque, .{ .name = "glfwGetCocoaWindow" });
            const p = f(hnd) orelse return 0;
            return @floatFromInt(@intFromPtr(p));
        },
        else => return 0,
    }
}

/// On Linux the surface also needs the DISPLAY pointer; everywhere else
/// this is 0 and the caller ignores it.
pub fn nativeDisplay(id: i64) f64 {
    _ = slotOf(id) orelse return 0;
    const builtin = @import("builtin");
    if (builtin.os.tag != .linux) return 0;
    const f = @extern(*const fn () callconv(.c) ?*anyopaque, .{ .name = "glfwGetX11Display" });
    const p = f() orelse return 0;
    return @floatFromInt(@intFromPtr(p));
}

pub fn isOpen(id: i64) i32 {
    const slot = slotOf(id) orelse return 0;
    const s = &windows.items[slot];
    const hnd = s.handle orelse return 0;
    return if (c.glfwWindowShouldClose(hnd) == 0) 1 else 0;
}

pub fn requestClose(id: i64) i32 {
    const slot = slotOf(id) orelse return STALE;
    const hnd = windows.items[slot].handle orelse return STALE;
    c.glfwSetWindowShouldClose(hnd, c.GLFW_TRUE);
    return OK;
}

/// Pump events and SAMPLE input into the slot, so everything a frame reads
/// describes the same instant. Edge state (pressed / clicked) is computed
/// here and cleared on the NEXT poll -- a frame that asks twice gets the
/// same answer, which is what makes a loop reasonable to write.
pub fn poll(id: i64) i32 {
    const slot = slotOf(id) orelse return STALE;
    const s = &windows.items[slot];
    const hnd = s.handle orelse return STALE;

    const prev_keys: [KEY_SLOTS]bool = s.keys;
    const prev_mouse: [8]bool = s.mouse_down;

    c.glfwPollEvents();

    for (0..KEY_SLOTS) |k| {
        const down = c.glfwGetKey(hnd, @intCast(k)) == c.GLFW_PRESS;
        s.keys[k] = down;
        s.keys_pressed[k] = down and !prev_keys[k];
    }
    for (0..8) |bi| {
        const down = c.glfwGetMouseButton(hnd, @intCast(bi)) == c.GLFW_PRESS;
        s.mouse_down[bi] = down;
        s.mouse_clicked[bi] = down and !prev_mouse[bi];
    }
    c.glfwGetCursorPos(hnd, &s.mouse_x, &s.mouse_y);

    var w: c_int = 0;
    var h: c_int = 0;
    c.glfwGetFramebufferSize(hnd, &w, &h);
    s.resized = (w != s.width or h != s.height);
    s.width = w;
    s.height = h;

    const now = c.glfwGetTime();
    s.delta = now - s.last_time;
    s.last_time = now;
    s.frames += 1;
    return OK;
}

pub fn width(id: i64) f64 {
    const slot = slotOf(id) orelse return -1;
    return @floatFromInt(windows.items[slot].width);
}

pub fn height(id: i64) f64 {
    const slot = slotOf(id) orelse return -1;
    return @floatFromInt(windows.items[slot].height);
}

pub fn wasResized(id: i64) i32 {
    const slot = slotOf(id) orelse return 0;
    return if (windows.items[slot].resized) 1 else 0;
}

/// Seconds since the previous poll. The number a frame loop is written
/// against, so motion is time-based rather than frame-rate-based.
pub fn deltaTime(id: i64) f64 {
    const slot = slotOf(id) orelse return 0;
    return windows.items[slot].delta;
}

pub fn frameCount(id: i64) f64 {
    const slot = slotOf(id) orelse return 0;
    return @floatFromInt(windows.items[slot].frames);
}

pub fn keyDown(id: i64, key: i32) i32 {
    const slot = slotOf(id) orelse return 0;
    if (key < 0 or key >= KEY_SLOTS) return 0;
    return if (windows.items[slot].keys[@intCast(key)]) 1 else 0;
}

pub fn keyPressed(id: i64, key: i32) i32 {
    const slot = slotOf(id) orelse return 0;
    if (key < 0 or key >= KEY_SLOTS) return 0;
    return if (windows.items[slot].keys_pressed[@intCast(key)]) 1 else 0;
}

pub fn mouseX(id: i64) f64 {
    const slot = slotOf(id) orelse return 0;
    return windows.items[slot].mouse_x;
}

pub fn mouseY(id: i64) f64 {
    const slot = slotOf(id) orelse return 0;
    return windows.items[slot].mouse_y;
}

pub fn mouseDown(id: i64, btn: i32) i32 {
    const slot = slotOf(id) orelse return 0;
    if (btn < 0 or btn >= 8) return 0;
    return if (windows.items[slot].mouse_down[@intCast(btn)]) 1 else 0;
}

pub fn mouseClicked(id: i64, btn: i32) i32 {
    const slot = slotOf(id) orelse return 0;
    if (btn < 0 or btn >= 8) return 0;
    return if (windows.items[slot].mouse_clicked[@intCast(btn)]) 1 else 0;
}

/// Resize the window from code. Its reason for existing is not convenience:
/// without it, the resize path -- swapchain reconfigure, depth-buffer
/// rebuild, scene retarget -- can ONLY be driven by a human with a mouse,
/// which means it can never be guarded. The size takes effect at the next
/// poll, exactly as a dragged edge does, so a guard exercises the same code
/// a person does.
pub fn setSize(id: i64, w: i32, h: i32) i32 {
    const slot = slotOf(id) orelse return STALE;
    if (w < 1 or h < 1) return BAD_ARG;
    const hnd = windows.items[slot].handle orelse return STALE;
    c.glfwSetWindowSize(hnd, w, h);
    return OK;
}

pub fn setTitle(id: i64, title: [*:0]const u8) i32 {
    const slot = slotOf(id) orelse return STALE;
    const hnd = windows.items[slot].handle orelse return STALE;
    c.glfwSetWindowTitle(hnd, title);
    return OK;
}

pub fn shutdown() void {
    for (windows.items, 0..) |s, i| {
        if (s.live) _ = windowFree(makeId(i, s.gen));
    }
    if (glfw_ready) {
        c.glfwTerminate();
        glfw_ready = false;
    }
}
