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
extern fn stz_gui_counters(out8: [*]i32) callconv(.c) void;
extern fn stz_gui_font_register(family: [*:0]const u8, bytes: [*]const u8, len: i32) callconv(.c) i64;
extern fn stz_gui_font_count() callconv(.c) i32;
extern fn stz_gui_text_count() callconv(.c) i32;
extern fn stz_gui_text_at(i: i32, font: *i64, size: *f32, x: *f32, y: *f32, colour: *u32, bytes: *[*]const u8, len: *i32) callconv(.c) i32;
extern fn stz_gui_element_box(id: i64, elem: [*:0]const u8, out4: [*]f32) callconv(.c) i32;
// G5: the update path. Until these, the engine could only LOAD -- so the
// only way to change a screen was to build the whole document again.
extern fn stz_gui_set_text(id: i64, elem: [*:0]const u8, text: [*:0]const u8) callconv(.c) i32;
extern fn stz_gui_set_style(id: i64, elem: [*:0]const u8, prop: [*:0]const u8, value: [*:0]const u8) callconv(.c) i32;
extern fn stz_gui_last_error() callconv(.c) [*:0]const u8;
extern fn stz_gui_set_time(seconds: f64) callconv(.c) void;
extern fn stz_gui_set_input_source(source: i32) callconv(.c) void;
extern fn stz_gui_pointer_move(id: i64, x: f32, y: f32, mods: i32) callconv(.c) i32;
extern fn stz_gui_pointer_button(id: i64, button: i32, down: i32, mods: i32) callconv(.c) i32;
extern fn stz_gui_pointer_leave(id: i64) callconv(.c) i32;
extern fn stz_gui_key(id: i64, k: i32, down: i32, mods: i32) callconv(.c) i32;
extern fn stz_gui_text_input(id: i64, utf8: [*]const u8, len: i32) callconv(.c) i32;
extern fn stz_gui_focus(id: i64, elem: [*:0]const u8) callconv(.c) i32;
extern fn stz_gui_focused(id: i64) callconv(.c) [*:0]const u8;
extern fn stz_gui_focus_move(id: i64, dir: i32) callconv(.c) i32;
extern fn stz_gui_element_at(id: i64, x: f32, y: f32) callconv(.c) [*:0]const u8;
extern fn stz_gui_event_count() callconv(.c) i32;
extern fn stz_gui_events_dropped() callconv(.c) i32;
extern fn stz_gui_events_clear() callconv(.c) void;
extern fn stz_gui_event_at(i: i32, t: *i32, src: *i32, x: *f32, y: *f32, button: *i32, k: *i32, mods: *i32, target: *[*]const u8, tlen: *i32) callconv(.c) i32;

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
///  generateCalls, keyboardActivations, widthCacheHits, shapeCalls] --
/// the bounded record's own account of what it drew and what it could
/// not. Appended, never reordered: G1 readers of the first six still read
/// the same truths.
pub fn counters() [12]i32 {
    var out: [12]i32 = .{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    stz_gui_counters(&out);
    return out;
}

/// Register a font family from memory (G2). The same bytes the Ring side
/// gives stzFont, so both DLLs hold the identical file. Answers this
/// DLL's font id -- the one text commands carry -- or 0 on refusal.
pub fn fontRegister(family: [:0]const u8, bytes: []const u8) i64 {
    if (bytes.len == 0) return 0;
    return stz_gui_font_register(family.ptr, bytes.ptr, @intCast(bytes.len));
}

pub fn fontCount() i32 {
    return stz_gui_font_count();
}

pub const TextCmd = struct {
    font: i64,
    size: f32,
    x: f32,
    y: f32,
    colour: u32, // 0xRRGGBBAA, straight alpha
    text: []const u8, // valid until the next render
};

pub fn textCount() i32 {
    return stz_gui_text_count();
}

pub fn textAt(i: i32) ?TextCmd {
    var font: i64 = 0;
    var size: f32 = 0;
    var x: f32 = 0;
    var y: f32 = 0;
    var colour: u32 = 0;
    var bytes: [*]const u8 = undefined;
    var len: i32 = 0;
    if (stz_gui_text_at(i, &font, &size, &x, &y, &colour, &bytes, &len) != 0) return null;
    if (len < 0) return null;
    return .{ .font = font, .size = size, .x = x, .y = y, .colour = colour, .text = bytes[0..@intCast(len)] };
}

pub fn elementBox(id: i64, elem: [:0]const u8, out4: *[4]f32) i32 {
    return stz_gui_element_box(id, elem.ptr, out4);
}

pub fn setText(id: i64, elem: [:0]const u8, text: [:0]const u8) i32 {
    return stz_gui_set_text(id, elem.ptr, text.ptr);
}

pub fn setStyle(id: i64, elem: [:0]const u8, prop: [:0]const u8, value: [:0]const u8) i32 {
    return stz_gui_set_style(id, elem.ptr, prop.ptr, value.ptr);
}

pub fn lastError() []const u8 {
    return std.mem.span(stz_gui_last_error());
}

pub fn setTime(seconds: f64) void {
    stz_gui_set_time(seconds);
}

// ------------------------------------------------------------ G3: input
//
// Every verb takes PANEL pixels. The coordinate-space frame is dissolved
// rather than surfaced (the plan's §7 M3): one space per panel, converted
// at the boundary by a named function, so there is nothing to confuse it
// with.

pub fn setInputSource(source: i32) void {
    stz_gui_set_input_source(source);
}

pub fn pointerMove(id: i64, x: f32, y: f32, mods: i32) i32 {
    return stz_gui_pointer_move(id, x, y, mods);
}

pub fn pointerButton(id: i64, button: i32, down: bool, mods: i32) i32 {
    return stz_gui_pointer_button(id, button, if (down) 1 else 0, mods);
}

pub fn pointerLeave(id: i64) i32 {
    return stz_gui_pointer_leave(id);
}

pub fn key(id: i64, k: i32, down: bool, mods: i32) i32 {
    return stz_gui_key(id, k, if (down) 1 else 0, mods);
}

pub fn textInput(id: i64, utf8: []const u8) i32 {
    if (utf8.len == 0) return BAD_ARG;
    return stz_gui_text_input(id, utf8.ptr, @intCast(utf8.len));
}

pub fn focus(id: i64, elem: [:0]const u8) i32 {
    return stz_gui_focus(id, elem.ptr);
}

pub fn focused(id: i64) []const u8 {
    return std.mem.span(stz_gui_focused(id));
}

pub fn focusMove(id: i64, dir: i32) i32 {
    return stz_gui_focus_move(id, dir);
}

pub fn elementAt(id: i64, x: f32, y: f32) []const u8 {
    return std.mem.span(stz_gui_element_at(id, x, y));
}

pub const Event = struct {
    kind: i32,
    source: i32,
    x: f32,
    y: f32,
    button: i32,
    key: i32,
    mods: i32,
    target: []const u8,
};

pub fn eventCount() i32 {
    return stz_gui_event_count();
}

pub fn eventsDropped() i32 {
    return stz_gui_events_dropped();
}

pub fn eventsClear() void {
    stz_gui_events_clear();
}

pub fn eventAt(i: i32) ?Event {
    var t: i32 = 0;
    var src: i32 = 0;
    var x: f32 = 0;
    var y: f32 = 0;
    var button: i32 = 0;
    var k: i32 = 0;
    var mods: i32 = 0;
    var target: [*]const u8 = undefined;
    var tlen: i32 = 0;
    if (stz_gui_event_at(i, &t, &src, &x, &y, &button, &k, &mods, &target, &tlen) != 0) return null;
    if (tlen < 0) return null;
    return .{ .kind = t, .source = src, .x = x, .y = y, .button = button, .key = k, .mods = mods, .target = target[0..@intCast(tlen)] };
}
