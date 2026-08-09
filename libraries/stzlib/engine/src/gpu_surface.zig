//! Presentation -- GR5 of SOFTANZA_GRAPHICS_PLAN.md.
//!
//! Everything shipped so far renders into an OFFSCREEN target and reads the
//! pixels back. That is the right shape for a picture you save; it is the
//! wrong shape for a picture you watch, because the readback is the single
//! most expensive thing in the frame. This module removes it: the surface's
//! own texture becomes the render target, and the picture never crosses the
//! bus at all.
//!
//! THE DESIGN DECISION, in one line: a swapchain frame is ADOPTED into the
//! ordinary texture table as a render target (gpu.adoptTarget). So every
//! draw path already written -- the pass machine, the 2D scene, the 3D
//! scene, the GPU-driven instancing -- draws to a window with NO new code
//! and no second implementation to keep in sync. `ToPixels` and `Present`
//! are the same renderer pointed at different targets.
//!
//! WHAT CROSSES THE DLL BOUNDARY: an HWND / X11 Window / NSWindow, as a
//! number, from stz_window.dll. That is an OS handle, not an engine handle,
//! so it does not break the house law that gen-keyed ids stay inside their
//! own DLL. The window tier knows nothing about wgpu, and this tier knows
//! nothing about GLFW.
//!
//! FORMAT: the surface names the formats it supports and we take the first
//! one the render stack can already produce -- RGBA8Unorm if offered, else
//! BGRA8Unorm, and the pipeline cache is keyed by format so both work. That
//! key is the difference between "works on my machine" and "works".

const std = @import("std");
const gpu = @import("gpu.zig");
const render = @import("gpu_render.zig");
const c = gpu.c;

const alloc = std.heap.c_allocator;

fn sv(s: []const u8) c.WGPUStringView {
    return .{ .data = s.ptr, .length = s.len };
}

pub const OK: i32 = 0;
pub const FALLBACK: i32 = 1;
pub const STALE: i32 = 2;
pub const BAD_ARG: i32 = 3;

// present modes, as the Ring face names them
pub const PRESENT_FIFO: i32 = 0; // vsync, always supported
pub const PRESENT_IMMEDIATE: i32 = 1; // no vsync, may tear
pub const PRESENT_MAILBOX: i32 = 2; // no tear, no wait (triple buffer)

const SurfSlot = struct {
    surface: c.WGPUSurface = null,
    gen: u32 = 1,
    live: bool = false,
    w: u32 = 0,
    h: u32 = 0,
    format: c.WGPUTextureFormat = 0,
    present_mode: c.WGPUPresentMode = c.WGPUPresentMode_Fifo,
    configured: bool = false,
    // the frame in flight: an adopted target id, 0 between frames
    frame_target: i64 = 0,
    frames_presented: u64 = 0,
    reconfigures: u64 = 0,
    last_status: i32 = 0, // the raw WGPUSurfaceGetCurrentTextureStatus
};

var surfaces: std.ArrayList(SurfSlot) = .{};
var registered = false;

fn ensureRegistered() void {
    if (!registered) {
        gpu.registerDeviceCloseHook(&onDeviceClose);
        registered = true;
    }
}

/// The device is going away. A configured surface holds device-scoped
/// swapchain textures; drop them all rather than presenting into a dead
/// device later.
fn onDeviceClose() void {
    for (surfaces.items, 0..) |*s, i| {
        if (!s.live) continue;
        if (s.frame_target != 0) {
            gpu.releaseAdopted(s.frame_target);
            s.frame_target = 0;
        }
        if (s.configured) {
            gpu.wfns().wgpuSurfaceUnconfigure(s.surface);
            s.configured = false;
        }
        _ = i;
    }
}

fn slotOf(id: i64) ?usize {
    const idx = id & 0xffff_ffff;
    if (idx <= 0 or idx > @as(i64, @intCast(surfaces.items.len))) return null;
    const s: usize = @intCast(idx - 1);
    const gen: u32 = @intCast((id >> 32) & 0xffff_ffff);
    if (!surfaces.items[s].live or surfaces.items[s].gen != gen) return null;
    return s;
}

fn makeId(slot: usize, gen: u32) i64 {
    return (@as(i64, gen) << 32) | @as(i64, @intCast(slot + 1));
}

// ---------------------------------------------------------------- creation

/// Make a surface from a native window handle.
///   handle  -- HWND (Windows) / Window (X11) / NSWindow* (macOS)
///   display -- X11 Display*; ignored elsewhere
fn createNative(handle: usize, display: usize) c.WGPUSurface {
    const builtin = @import("builtin");
    var desc = std.mem.zeroes(c.WGPUSurfaceDescriptor);
    desc.label = sv("stz_surface");

    switch (builtin.os.tag) {
        .windows => {
            var src = std.mem.zeroes(c.WGPUSurfaceSourceWindowsHWND);
            src.chain.sType = c.WGPUSType_SurfaceSourceWindowsHWND;
            src.hinstance = @ptrFromInt(@intFromPtr(std.os.windows.kernel32.GetModuleHandleW(null)));
            src.hwnd = @ptrFromInt(handle);
            desc.nextInChain = @ptrCast(&src.chain);
            return gpu.wfns().wgpuInstanceCreateSurface(gpu.instanceHandle(), &desc);
        },
        .linux => {
            var src = std.mem.zeroes(c.WGPUSurfaceSourceXlibWindow);
            src.chain.sType = c.WGPUSType_SurfaceSourceXlibWindow;
            src.display = @ptrFromInt(display);
            src.window = @intCast(handle);
            desc.nextInChain = @ptrCast(&src.chain);
            return gpu.wfns().wgpuInstanceCreateSurface(gpu.instanceHandle(), &desc);
        },
        .macos => {
            // wgpu wants a CAMetalLayer, and GLFW hands out an NSWindow. The
            // bridge is four Objective-C messages, sent through the runtime
            // rather than through Cocoa headers (which do not exist on this
            // build host). UNVERIFIED FROM HERE -- see vendor/glfw/VERSION.txt;
            // it is written so a macOS build has something to test, not so a
            // claim can be made about it.
            const objc_getClass = @extern(*const fn ([*:0]const u8) callconv(.c) ?*anyopaque, .{ .name = "objc_getClass" });
            const sel_registerName = @extern(*const fn ([*:0]const u8) callconv(.c) ?*anyopaque, .{ .name = "sel_registerName" });
            const msg0 = @extern(*const fn (?*anyopaque, ?*anyopaque) callconv(.c) ?*anyopaque, .{ .name = "objc_msgSend" });
            const msg1p = @extern(*const fn (?*anyopaque, ?*anyopaque, ?*anyopaque) callconv(.c) ?*anyopaque, .{ .name = "objc_msgSend" });
            const msg1b = @extern(*const fn (?*anyopaque, ?*anyopaque, bool) callconv(.c) ?*anyopaque, .{ .name = "objc_msgSend" });

            const nswindow: ?*anyopaque = @ptrFromInt(handle);
            const view = msg0(nswindow, sel_registerName("contentView")) orelse return null;
            const layer_class = objc_getClass("CAMetalLayer") orelse return null;
            const layer = msg0(msg0(layer_class, sel_registerName("alloc")), sel_registerName("init")) orelse return null;
            _ = msg1p(view, sel_registerName("setLayer:"), layer);
            _ = msg1b(view, sel_registerName("setWantsLayer:"), true);

            var src = std.mem.zeroes(c.WGPUSurfaceSourceMetalLayer);
            src.chain.sType = c.WGPUSType_SurfaceSourceMetalLayer;
            src.layer = layer;
            desc.nextInChain = @ptrCast(&src.chain);
            return gpu.wfns().wgpuInstanceCreateSurface(gpu.instanceHandle(), &desc);
        },
        else => return null,
    }
}

pub fn stz_gpu_surface_new(handle: f64, display: f64, wf: f64, hf: f64) callconv(.c) i64 {
    if (!gpu.isAvail()) {
        gpu.countFallback();
        return 0;
    }
    if (handle == 0 or wf < 1 or hf < 1) return 0;
    ensureRegistered();

    const surface = createNative(@intFromFloat(handle), @intFromFloat(display)) orelse return 0;

    var slot: usize = surfaces.items.len;
    for (surfaces.items, 0..) |s, i| {
        if (!s.live) {
            slot = i;
            break;
        }
    }
    if (slot == surfaces.items.len) {
        surfaces.append(alloc, .{}) catch {
            gpu.wfns().wgpuSurfaceRelease(surface);
            return 0;
        };
    }
    const s = &surfaces.items[slot];
    const keep_gen = s.gen;
    s.* = .{};
    s.gen = keep_gen;
    s.surface = surface;
    s.live = true;
    s.w = @intFromFloat(wf);
    s.h = @intFromFloat(hf);
    s.format = pickFormat(surface);
    if (s.format == c.WGPUTextureFormat_Undefined) {
        gpu.wfns().wgpuSurfaceRelease(surface);
        s.live = false;
        s.gen +%= 1;
        return 0;
    }
    if (!configure(s)) {
        gpu.wfns().wgpuSurfaceRelease(surface);
        s.live = false;
        s.gen +%= 1;
        return 0;
    }
    return makeId(slot, s.gen);
}

/// Take RGBA8Unorm when the surface offers it -- it is what every offscreen
/// target in this engine already is, so a scene renders identically to a
/// window and to a file. Otherwise BGRA8Unorm, which the pipeline cache
/// handles because it is keyed by format.
fn pickFormat(surface: c.WGPUSurface) c.WGPUTextureFormat {
    var caps = std.mem.zeroes(c.WGPUSurfaceCapabilities);
    const st = gpu.wfns().wgpuSurfaceGetCapabilities(surface, gpu.adapterHandle(), &caps);
    if (st != c.WGPUStatus_Success or caps.formatCount == 0) return c.WGPUTextureFormat_Undefined;
    defer gpu.wfns().wgpuSurfaceCapabilitiesFreeMembers(caps);

    var first: c.WGPUTextureFormat = c.WGPUTextureFormat_Undefined;
    for (0..caps.formatCount) |i| {
        const f = caps.formats[i];
        if (f == c.WGPUTextureFormat_RGBA8Unorm) return f;
        if (f == c.WGPUTextureFormat_BGRA8Unorm) first = f;
    }
    if (first != c.WGPUTextureFormat_Undefined) return first;
    return caps.formats[0];
}

fn supportsPresentMode(surface: c.WGPUSurface, mode: c.WGPUPresentMode) bool {
    if (mode == c.WGPUPresentMode_Fifo) return true; // guaranteed by spec
    var caps = std.mem.zeroes(c.WGPUSurfaceCapabilities);
    const st = gpu.wfns().wgpuSurfaceGetCapabilities(surface, gpu.adapterHandle(), &caps);
    if (st != c.WGPUStatus_Success) return false;
    defer gpu.wfns().wgpuSurfaceCapabilitiesFreeMembers(caps);
    for (0..caps.presentModeCount) |i| {
        if (caps.presentModes[i] == mode) return true;
    }
    return false;
}

fn configure(s: *SurfSlot) bool {
    var cfg = std.mem.zeroes(c.WGPUSurfaceConfiguration);
    cfg.device = gpu.deviceHandle();
    cfg.format = s.format;
    cfg.usage = c.WGPUTextureUsage_RenderAttachment | c.WGPUTextureUsage_CopySrc;
    cfg.width = s.w;
    cfg.height = s.h;
    cfg.alphaMode = c.WGPUCompositeAlphaMode_Auto;
    cfg.presentMode = s.present_mode;
    gpu.wfns().wgpuSurfaceConfigure(s.surface, &cfg);
    s.configured = true;
    return true;
}

pub fn stz_gpu_surface_free(id: i64) callconv(.c) i32 {
    const slot = slotOf(id) orelse return STALE;
    const s = &surfaces.items[slot];
    if (s.frame_target != 0) {
        gpu.releaseAdopted(s.frame_target);
        s.frame_target = 0;
    }
    if (s.configured) gpu.wfns().wgpuSurfaceUnconfigure(s.surface);
    if (s.surface) |sf| gpu.wfns().wgpuSurfaceRelease(sf);
    s.surface = null;
    s.live = false;
    s.configured = false;
    s.gen +%= 1;
    return OK;
}

/// Resize. A swapchain that does not match the window produces a stretched
/// or torn picture, so a resize MUST reconfigure -- this is the call a frame
/// loop makes when the window reports WasResized.
pub fn stz_gpu_surface_resize(id: i64, wf: f64, hf: f64) callconv(.c) i32 {
    const slot = slotOf(id) orelse return STALE;
    const s = &surfaces.items[slot];
    const w: u32 = @intFromFloat(@max(1, wf));
    const h: u32 = @intFromFloat(@max(1, hf));
    if (w == s.w and h == s.h) return OK; // idempotent: reconfiguring costs a swapchain
    if (s.frame_target != 0) {
        gpu.releaseAdopted(s.frame_target);
        s.frame_target = 0;
    }
    s.w = w;
    s.h = h;
    s.reconfigures += 1;
    _ = configure(s);
    return OK;
}

pub fn stz_gpu_surface_set_present_mode(id: i64, mode: f64) callconv(.c) i32 {
    const slot = slotOf(id) orelse return STALE;
    const s = &surfaces.items[slot];
    const m: c.WGPUPresentMode = switch (@as(i32, @intFromFloat(mode))) {
        PRESENT_IMMEDIATE => c.WGPUPresentMode_Immediate,
        PRESENT_MAILBOX => c.WGPUPresentMode_Mailbox,
        else => c.WGPUPresentMode_Fifo,
    };
    // An unsupported mode is a REFUSAL, not a silent downgrade: a caller
    // asking for Immediate to measure raw frame cost must be told when it
    // did not get it, or the measurement is a lie.
    if (!supportsPresentMode(s.surface, m)) return BAD_ARG;
    if (m == s.present_mode) return OK;
    s.present_mode = m;
    s.reconfigures += 1;
    _ = configure(s);
    return OK;
}

/// Acquire this frame's texture and hand it back as an ORDINARY render
/// target id. Everything downstream is the code that already existed.
/// Returns 0 on refusal; Outdated/Lost reconfigure and refuse ONE frame
/// rather than dying -- that is what a window being dragged between
/// monitors looks like from here.
pub fn stz_gpu_surface_acquire(id: i64) callconv(.c) i64 {
    const slot = slotOf(id) orelse return 0;
    const s = &surfaces.items[slot];
    if (!gpu.isAvail()) {
        gpu.countFallback();
        return 0;
    }
    if (s.frame_target != 0) return s.frame_target; // already holding this frame

    var st = std.mem.zeroes(c.WGPUSurfaceTexture);
    gpu.wfns().wgpuSurfaceGetCurrentTexture(s.surface, &st);
    s.last_status = @intCast(st.status);
    switch (st.status) {
        c.WGPUSurfaceGetCurrentTextureStatus_SuccessOptimal,
        c.WGPUSurfaceGetCurrentTextureStatus_SuccessSuboptimal,
        => {},
        c.WGPUSurfaceGetCurrentTextureStatus_Outdated,
        c.WGPUSurfaceGetCurrentTextureStatus_Lost,
        => {
            if (st.texture) |t| gpu.wfns().wgpuTextureRelease(t);
            s.reconfigures += 1;
            _ = configure(s);
            gpu.countFallback();
            return 0;
        },
        else => {
            if (st.texture) |t| gpu.wfns().wgpuTextureRelease(t);
            gpu.countFallback();
            return 0;
        },
    }
    const tex = st.texture orelse return 0;
    const view = gpu.wfns().wgpuTextureCreateView(tex, null);
    if (view == null) {
        gpu.wfns().wgpuTextureRelease(tex);
        return 0;
    }
    const tid = gpu.adoptTarget(tex, view, s.w, s.h);
    if (tid == 0) {
        gpu.wfns().wgpuTextureViewRelease(view);
        gpu.wfns().wgpuTextureRelease(tex);
        return 0;
    }
    s.frame_target = tid;
    return tid;
}

/// Show the frame. Releases the adopted target first -- holding a reference
/// to a presented texture is how a swapchain runs out of frames.
pub fn stz_gpu_surface_present(id: i64) callconv(.c) i32 {
    const slot = slotOf(id) orelse return STALE;
    const s = &surfaces.items[slot];
    if (s.frame_target == 0) return BAD_ARG; // nothing acquired: presenting nothing
    const f = gpu.wfns();
    // PRESENT FIRST, THEN RELEASE. wgpuSurfacePresent acts on the texture
    // the surface is currently handing out; dropping our reference before
    // presenting leaves the swapchain unable to retire the image, and it
    // answers Timeout from the third frame on -- forever.
    _ = f.wgpuSurfacePresent(s.surface);
    gpu.releaseAdopted(s.frame_target);
    s.frame_target = 0;
    s.frames_presented += 1;

    // Every submit in this engine is asynchronous (the compute plane's law:
    // submit, and let a readback establish completion). Offscreen rendering
    // always ended in a readback, so something always drove the device's
    // callbacks. Presentation deliberately does NOT read back, so this is
    // what runs them -- without it a validation error inside a frame loop
    // would never be reported and the window would just look wrong.
    //
    // It is NOT what keeps the swapchain alive: a control run with these two
    // lines removed still rendered every frame. The Timeout-from-frame-3 bug
    // was the release order above, and this poll was measured innocent
    // rather than left in as a lucky charm.
    f.wgpuInstanceProcessEvents(gpu.instanceHandle());
    _ = f.wgpuDevicePoll(gpu.deviceHandle(), 0, null);
    return OK;
}

pub fn stz_gpu_surface_format(id: i64) callconv(.c) f64 {
    const slot = slotOf(id) orelse return -1;
    return @floatFromInt(surfaces.items[slot].format);
}

/// The format as the render stack names it -- "rgba8" or "bgra8". This is
/// what a pipeline must be compiled for, so the face passes it straight
/// through rather than re-deriving it.
pub fn stz_gpu_surface_format_name(id: i64, out: [*]u8, cap: f64) callconv(.c) i32 {
    const slot = slotOf(id) orelse return 0;
    const name = switch (surfaces.items[slot].format) {
        c.WGPUTextureFormat_RGBA8Unorm => "rgba8",
        c.WGPUTextureFormat_BGRA8Unorm => "bgra8",
        c.WGPUTextureFormat_RGBA8UnormSrgb => "rgba8srgb",
        c.WGPUTextureFormat_BGRA8UnormSrgb => "bgra8srgb",
        else => "other",
    };
    const n = @min(name.len, @as(usize, @intFromFloat(cap)));
    @memcpy(out[0..n], name[0..n]);
    return @intCast(n);
}

pub fn stz_gpu_surface_stat(id: i64, which: f64) callconv(.c) f64 {
    const slot = slotOf(id) orelse return -1;
    const s = &surfaces.items[slot];
    return switch (@as(i32, @intFromFloat(which))) {
        0 => @floatFromInt(s.w),
        1 => @floatFromInt(s.h),
        2 => @floatFromInt(s.frames_presented),
        3 => @floatFromInt(s.reconfigures),
        4 => if (s.frame_target != 0) 1 else 0,
        5 => @floatFromInt(@as(i32, @intCast(s.present_mode))),
        6 => @floatFromInt(s.last_status),
        else => -1,
    };
}
