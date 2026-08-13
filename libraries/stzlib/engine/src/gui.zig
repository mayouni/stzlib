//! stz_gui -- the GUI plane's engine face. G1 of base/gui/SOFTANZA_GUI_PLAN.md.
//!
//! RmlUi lays out; this module carries its output across the C ABI as a
//! DISPLAY LIST -- vertices and triangle indices -- which the graphics
//! plane draws through `stzCanvas.AddMesh`. Nothing here paints.
//!
//! The C++ half is `src/stz_rmlui.cpp`; read its header for why the
//! recorder exists, why RmlUi gets its own DLL (it needs exceptions AND
//! RTTI, measured in G0), and the two seam details that were paid for
//! rather than assumed (premultiplied colour, per-draw translation).
//!
//! This file is deliberately thin. The handle table, the refusal codes
//! and the gen-keying live on the C++ side because that is where the
//! contexts live; duplicating them here would be two tables that can
//! disagree.

const std = @import("std");

pub const OK: i32 = 0;
pub const STALE: i32 = 2;
pub const BAD_ARG: i32 = 3;

extern fn stz_gui_init() callconv(.c) i32;
extern fn stz_gui_is_ready() callconv(.c) i32;
extern fn stz_gui_shutdown() callconv(.c) void;
extern fn stz_gui_context_new(w: i32, h: i32) callconv(.c) i64;
extern fn stz_gui_context_free(id: i64) callconv(.c) i32;
extern fn stz_gui_context_resize(id: i64, w: i32, h: i32) callconv(.c) i32;
extern fn stz_gui_load_rml(id: i64, rml: [*]const u8, len: i32) callconv(.c) i32;
extern fn stz_gui_update(id: i64) callconv(.c) i32;
extern fn stz_gui_render(id: i64) callconv(.c) i32;
extern fn stz_gui_verts(out_len: *i32) callconv(.c) ?[*]const f32;
extern fn stz_gui_indices(out_len: *i32) callconv(.c) ?[*]const u32;
extern fn stz_gui_counters(out6: [*]i32) callconv(.c) void;
extern fn stz_gui_element_box(id: i64, elem: [*:0]const u8, out4: [*]f32) callconv(.c) i32;
extern fn stz_gui_last_error() callconv(.c) [*:0]const u8;
extern fn stz_gui_set_time(seconds: f64) callconv(.c) void;

pub fn init() i32 {
    return stz_gui_init();
}

pub fn isReady() bool {
    return stz_gui_is_ready() != 0;
}

pub fn shutdown() void {
    stz_gui_shutdown();
}

pub fn contextNew(w: i32, h: i32) i64 {
    if (init() != OK) return 0;
    return stz_gui_context_new(w, h);
}

pub fn contextFree(id: i64) i32 {
    return stz_gui_context_free(id);
}

pub fn contextResize(id: i64, w: i32, h: i32) i32 {
    return stz_gui_context_resize(id, w, h);
}

pub fn loadRml(id: i64, rml: []const u8) i32 {
    if (rml.len == 0) return BAD_ARG;
    return stz_gui_load_rml(id, rml.ptr, @intCast(rml.len));
}

pub fn update(id: i64) i32 {
    return stz_gui_update(id);
}

pub fn render(id: i64) i32 {
    return stz_gui_render(id);
}

/// The recorded vertices: x, y, r, g, b, a per vertex, pixel space,
/// channels 0..255 -- exactly what `sceneMesh` takes. Valid until the
/// next `render`.
pub fn verts() []const f32 {
    var n: i32 = 0;
    const p = stz_gui_verts(&n) orelse return &.{};
    if (n <= 0) return &.{};
    return p[0..@intCast(n)];
}

pub fn indices() []const u32 {
    var n: i32 = 0;
    const p = stz_gui_indices(&n) orelse return &.{};
    if (n <= 0) return &.{};
    return p[0..@intCast(n)];
}

/// [draws, droppedTexturedDraws, ignoredScissors, widthCalls,
///  generateCalls, keyboardActivations] -- the bounded record's own
/// account of what it drew and what it could not.
pub fn counters() [6]i32 {
    var out: [6]i32 = .{ 0, 0, 0, 0, 0, 0 };
    stz_gui_counters(&out);
    return out;
}

pub fn elementBox(id: i64, elem: [:0]const u8, out4: *[4]f32) i32 {
    return stz_gui_element_box(id, elem.ptr, out4);
}

pub fn lastError() []const u8 {
    return std.mem.span(stz_gui_last_error());
}

pub fn setTime(seconds: f64) void {
    stz_gui_set_time(seconds);
}
