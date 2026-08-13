//! The 2D display list and its TWO renderers -- GR2b of
//! SOFTANZA_GRAPHICS_PLAN.md.
//!
//! ONE model, two backends. A scene is a painter-ordered list of shape and
//! text commands in PIXEL space (y down, like SVG and like a screen). From
//! that single list:
//!
//!   - `sceneToSvg`  emits vector text -- the CI-safe floor of the tier
//!     ladder. No device, no GPU, always available.
//!   - `sceneToPng`  tessellates to triangles, draws through the GR1 render
//!     surface in ONE pass, reads back, and encodes.
//!
//! They are sister backends of the same model, which is the whole point:
//! the SVG path and the GPU path cannot disagree about WHERE anything sits,
//! because neither owns the geometry -- the display list does. Text goes
//! through the GR2a pipeline (bidi -> shape -> glyph ids) on BOTH sides, so
//! Arabic is correct on both or broken on both; there is no per-backend
//! text logic to drift.
//!
//! Deliberate design choices, each with its reason:
//!
//!   - **Circle segment count is chosen BY AN ERROR BOUND**, not by a magic
//!     number: segments = ceil(pi / acos(1 - MAX_SAG/r)), so the chord
//!     sagitta never exceeds MAX_SAG (0.15 px) at any radius. SVG emits a
//!     true <circle>, so this bound IS the honest parity band between the
//!     backends for curves -- and it is computed, not hoped for.
//!   - **Polygon fill is ear clipping** (simple polygons; a self-
//!     intersecting outline stops honestly rather than emitting garbage --
//!     that case is the plan's CPU-rasterizer/PlutoVG line, not a silent
//!     wrong answer).
//!   - **Strokes are round-joined and round-capped** on both backends (a
//!     disc at every vertex plus a quad per segment; SVG says
//!     stroke-linejoin/linecap="round"). Matching cap semantics is what
//!     keeps the two backends' silhouettes the same shape.
//!   - **Buffers are RETAINED and rebuilt only when the list changes** (the
//!     §3b game-plane door): a still redraws for free, and a future frame
//!     loop does not re-upload static geometry 60x a second. `build_count`
//!     exists so a guard can PROVE it rather than trust it.
//!   - **Draw segments preserve painter order across kinds**: shapes and
//!     text live in separate vertex buffers (different formats), but the
//!     ordered segment list interleaves their draws inside the one pass, so
//!     text is not silently forced above shapes.
//!
//! Blending is standard alpha on both pipelines. With a=1 that reduces to
//! plain overwrite, so opaque fills stay BYTE-EXACT against a CPU
//! reference -- the GR0/GR1 parity witness survives the arrival of alpha.

const std = @import("std");
const gpu = @import("gpu.zig");
const render = @import("gpu_render.zig");
const gtext = @import("gpu_text.zig");
const atlas = @import("gpu_atlas.zig");

const alloc = std.heap.c_allocator;

pub const OK: i32 = 0;
pub const STALE: i32 = 2;
pub const BAD_ARG: i32 = 3;

/// Max chord sagitta for curve tessellation, in pixels. The parity band for
/// circles between the SVG (<circle>, exact) and GPU (polygon) backends.
pub const MAX_SAGITTA: f64 = 0.15;

// ---------------------------------------------------------------- WGSL

const WGSL_SHAPE =
    \\struct VSOut { @builtin(position) pos: vec4<f32>, @location(0) col: vec4<f32> }
    \\@vertex
    \\fn vmain(@location(0) pos: vec2<f32>, @location(1) col: vec4<f32>) -> VSOut {
    \\  var o: VSOut;
    \\  o.pos = vec4<f32>(pos, 0.0, 1.0);
    \\  o.col = col;
    \\  return o;
    \\}
    \\@fragment
    \\fn fmain(in: VSOut) -> @location(0) vec4<f32> { return in.col; }
;

// Glyph quads: the atlas holds coverage in ALPHA with white rgb, so one
// atlas serves every text color -- tint by the vertex color, modulate its
// alpha by coverage.
const WGSL_TEXT =
    \\struct VSOut { @builtin(position) pos: vec4<f32>, @location(0) uv: vec2<f32>, @location(1) col: vec4<f32> }
    \\@vertex
    \\fn vmain(@location(0) pos: vec2<f32>, @location(1) uv: vec2<f32>, @location(2) col: vec4<f32>) -> VSOut {
    \\  var o: VSOut;
    \\  o.pos = vec4<f32>(pos, 0.0, 1.0);
    \\  o.uv = uv;
    \\  o.col = col;
    \\  return o;
    \\}
    \\@group(0) @binding(0) var tex: texture_2d<f32>;
    \\@group(0) @binding(1) var smp: sampler;
    \\@fragment
    \\fn fmain(in: VSOut) -> @location(0) vec4<f32> {
    \\  let cov = textureSample(tex, smp, in.uv).a;
    \\  return vec4<f32>(in.col.rgb, in.col.a * cov);
    \\}
;

// An IMAGE quad. Same vertex format as text (pos, uv, colour) so it shares
// the vertex buffer, but the FRAGMENT differs and the difference matters:
// the text shader reads only the atlas's ALPHA as coverage and paints the
// vertex colour through it -- exactly right for a glyph, and it would turn
// a photograph into a silhouette. Here the sample IS the colour and the
// vertex colour is a tint (white leaves it untouched).
const WGSL_IMAGE =
    \\struct VSOut { @builtin(position) pos: vec4<f32>, @location(0) uv: vec2<f32>, @location(1) col: vec4<f32> }
    \\@vertex
    \\fn vmain(@location(0) pos: vec2<f32>, @location(1) uv: vec2<f32>, @location(2) col: vec4<f32>) -> VSOut {
    \\  var o: VSOut;
    \\  o.pos = vec4<f32>(pos, 0.0, 1.0);
    \\  o.uv = uv;
    \\  o.col = col;
    \\  return o;
    \\}
    \\@group(0) @binding(0) var tex: texture_2d<f32>;
    \\@group(0) @binding(1) var smp: sampler;
    \\@fragment
    \\fn fmain(in: VSOut) -> @location(0) vec4<f32> {
    \\  return textureSample(tex, smp, in.uv) * in.col;
    \\}
;

// ---------------------------------------------------------------- commands

const Rgba = struct {
    r: f32,
    g: f32,
    b: f32,
    a: f32,

    fn unpack(v: u32) Rgba {
        return .{
            .r = @as(f32, @floatFromInt((v >> 24) & 0xff)) / 255.0,
            .g = @as(f32, @floatFromInt((v >> 16) & 0xff)) / 255.0,
            .b = @as(f32, @floatFromInt((v >> 8) & 0xff)) / 255.0,
            .a = @as(f32, @floatFromInt(v & 0xff)) / 255.0,
        };
    }
};

const Cmd = union(enum) {
    rect: struct { x: f32, y: f32, w: f32, h: f32, c0: u32, c1: u32, gradient: bool, vertical: bool },
    circle: struct { cx: f32, cy: f32, r: f32, col: u32 },
    stroke: struct { pts: []f32, width: f32, col: u32 }, // line == 2-point stroke
    polygon: struct { pts: []f32, col: u32 },
    text: struct { font: i64, str: []u8, x: f32, y: f32, size: f32, col: u32 },
    // A grid of samples drawn in ONE operation. Owed to the sound plane
    // since SN5: a spectrogram was 1,574 rects, 88 ms and ~104 KB of SVG
    // for one 760x260 picture, because the canvas had no way to say
    // "here is a field of values, draw it".
    //
    // `tex` is created lazily at build time and RETAINED, so a still image
    // uploads once instead of per frame -- the same discipline the vertex
    // buffers already follow.
    image: struct { x: f32, y: f32, w: f32, h: f32, iw: u32, ih: u32, rgba: []u8, tex: i64, col: u32 },
    // ALREADY-TESSELLATED triangles with a colour PER VERTEX -- the shape
    // a UI toolkit emits. G1 of SOFTANZA_GUI_PLAN.md: RmlUi's
    // RenderInterface hands out vertices and indices, not shapes, so the
    // display list needs a way to say "here are triangles" without
    // pretending they are rectangles.
    //
    // `verts` is x,y,r,g,b,a per vertex in PIXEL space with 0..255 colour
    // channels -- the same information the shape buffer holds, so a mesh
    // costs no new shader, no new segment kind and no new draw.
    // `idx` is triangle indices into it.
    mesh: struct { verts: []f32, idx: []u32 },
};

const SegKind = enum { shape, text, image };
// `tex` is 0 for shape and text segments -- text draws through the shared
// glyph atlas. An IMAGE segment names its own texture, because two images
// in one scene are two textures and one draw each.
const Seg = struct { kind: SegKind, first: u32, count: u32, tex: i64 = 0 };

const SceneSlot = struct {
    w: u32 = 0,
    h: u32 = 0,
    clear: u32 = 0x00000000,
    cmds: std.ArrayList(Cmd) = .{},
    // built state (retained; rebuilt only when dirty)
    dirty: bool = true,
    shape_verts: std.ArrayList(f32) = .{},
    text_verts: std.ArrayList(f32) = .{},
    segs: std.ArrayList(Seg) = .{},
    build_count: u64 = 0,
    // retained GPU objects
    vbuf_shape: i64 = 0,
    vbuf_text: i64 = 0,
    target: i64 = 0,
    // GR5 presentation: when non-zero, draw into THIS target (a swapchain
    // frame) instead of the scene's own. One renderer, two destinations --
    // a window and a file cannot drift apart because there is nothing to
    // drift.
    ext_target: i64 = 0,
    ext_tfmt: i32 = 0,
    // An OVERLAY pass PRESERVES the target instead of clearing it, so a HUD
    // can sit on top of the 3D frame it annotates.
    ext_over: bool = false,
    // Which build generation is sitting in the vertex buffers. `builds`
    // already witnessed that a still scene re-TESSELLATES once; this makes
    // the same true of the UPLOAD. Found by the window: a static scene was
    // moving its whole vertex set across the bus 60 times a second while
    // reporting builds = 1, which is exactly the kind of thing an offscreen
    // renderer never notices because it only ever draws one frame.
    uploaded_build: u64 = 0,
    vertex_uploads: u64 = 0, // the witness for the line above
    gen: u32 = 1,
    live: bool = false,
};

var scenes: std.ArrayList(SceneSlot) = .{};
var hooked = false;

fn ensureHooked() void {
    if (!hooked) {
        gpu.registerDeviceCloseHook(&forgetDeviceObjects);
        hooked = true;
    }
}

fn makeId(slot: usize, gen: u32) i64 {
    return (@as(i64, gen) << 32) | @as(i64, @intCast(slot + 1));
}

fn slotOf(id: i64) ?usize {
    const idx = id & 0xffff_ffff;
    if (idx <= 0 or idx > @as(i64, @intCast(scenes.items.len))) return null;
    const slot: usize = @intCast(idx - 1);
    const gen: u32 = @intCast((id >> 32) & 0xffff_ffff);
    if (!scenes.items[slot].live or scenes.items[slot].gen != gen) return null;
    return slot;
}

fn freeCmdPayloads(s: *SceneSlot) void {
    for (s.cmds.items) |cmd| {
        switch (cmd) {
            .stroke => |k| alloc.free(k.pts),
            .polygon => |k| alloc.free(k.pts),
            .mesh => |k| {
                alloc.free(k.verts);
                alloc.free(k.idx);
            },
            .text => |k| alloc.free(k.str),
            .image => |im| {
                alloc.free(im.rgba);
                if (im.tex != 0) _ = gpu.stz_gpu_texture_free(im.tex);
            },
            else => {},
        }
    }
    s.cmds.clearRetainingCapacity();
}

pub fn sceneNew(w: f64, h: f64) i64 {
    ensureHooked();
    if (w < 1 or h < 1 or w > 16384 or h > 16384) return 0;
    var slot: usize = scenes.items.len;
    for (scenes.items, 0..) |s, i| {
        if (!s.live) {
            slot = i;
            break;
        }
    }
    if (slot == scenes.items.len) {
        scenes.append(alloc, .{}) catch return 0;
    }
    const s = &scenes.items[slot];
    s.w = @intFromFloat(w);
    s.h = @intFromFloat(h);
    s.clear = 0;
    s.dirty = true;
    s.build_count = 0;
    s.live = true;
    return makeId(slot, s.gen);
}

pub fn sceneFree(id: i64) i32 {
    const slot = slotOf(id) orelse return STALE;
    const s = &scenes.items[slot];
    freeCmdPayloads(s);
    s.cmds.clearAndFree(alloc);
    s.shape_verts.clearAndFree(alloc);
    s.text_verts.clearAndFree(alloc);
    s.segs.clearAndFree(alloc);
    if (s.vbuf_shape != 0) _ = gpu.stz_gpu_buffer_free(s.vbuf_shape);
    if (s.vbuf_text != 0) _ = gpu.stz_gpu_buffer_free(s.vbuf_text);
    if (s.target != 0) _ = gpu.stz_gpu_texture_free(s.target);
    s.vbuf_shape = 0;
    s.vbuf_text = 0;
    s.target = 0;
    s.live = false;
    s.gen +%= 1;
    return OK;
}

fn push(id: i64, cmd: Cmd) i32 {
    const slot = slotOf(id) orelse return STALE;
    const s = &scenes.items[slot];
    s.cmds.append(alloc, cmd) catch return BAD_ARG;
    s.dirty = true;
    return OK;
}

pub fn sceneClear(id: i64, col: u32) i32 {
    const slot = slotOf(id) orelse return STALE;
    scenes.items[slot].clear = col;
    scenes.items[slot].dirty = true;
    return OK;
}

/// Empty the display list, keeping the background colour and the GPU
/// buffers. This is what an ANIMATED scene calls at the top of each frame:
/// without it a frame loop appends its shapes forever and the display list
/// grows without bound -- a defect a one-shot renderer can never expose,
/// because it only ever draws frame 1.
///
/// The retained buffers are deliberately NOT freed: their capacity is what
/// makes the next frame cheap, and the vertex data is re-uploaded only
/// because the build generation moved.
/// Change a scene's extents. THE one implementation -- the presentation
/// path calls it too, so a scene resized by a window and a scene resized by
/// a caller cannot end up meaning different things.
pub fn sceneResize(id: i64, w: u32, h: u32) i32 {
    const slot = slotOf(id) orelse return STALE;
    if (w == 0 or h == 0 or w > 16384 or h > 16384) return BAD_ARG;
    const s = &scenes.items[slot];
    if (s.w == w and s.h == h) return OK;
    s.w = w;
    s.h = h;
    s.dirty = true; // extents changed: clipping and the clear quad follow
    return OK;
}

pub fn sceneReset(id: i64) i32 {
    const slot = slotOf(id) orelse return STALE;
    const s = &scenes.items[slot];
    s.cmds.clearRetainingCapacity();
    s.dirty = true;
    return OK;
}

pub fn sceneRect(id: i64, x: f64, y: f64, w: f64, h: f64, col: u32) i32 {
    if (w <= 0 or h <= 0) return BAD_ARG;
    return push(id, .{ .rect = .{
        .x = @floatCast(x),
        .y = @floatCast(y),
        .w = @floatCast(w),
        .h = @floatCast(h),
        .c0 = col,
        .c1 = col,
        .gradient = false,
        .vertical = false,
    } });
}

pub fn sceneRectGradient(id: i64, x: f64, y: f64, w: f64, h: f64, c0: u32, c1: u32, vertical: bool) i32 {
    if (w <= 0 or h <= 0) return BAD_ARG;
    return push(id, .{ .rect = .{
        .x = @floatCast(x),
        .y = @floatCast(y),
        .w = @floatCast(w),
        .h = @floatCast(h),
        .c0 = c0,
        .c1 = c1,
        .gradient = true,
        .vertical = vertical,
    } });
}

pub fn sceneCircle(id: i64, cx: f64, cy: f64, r: f64, col: u32) i32 {
    if (r <= 0) return BAD_ARG;
    return push(id, .{ .circle = .{ .cx = @floatCast(cx), .cy = @floatCast(cy), .r = @floatCast(r), .col = col } });
}

/// A circle's OUTLINE, generated engine-side.
///
/// The face used to build these points in Ring -- circleSegments(r) of them
/// per stroked circle, each an append to a Ring list, then the whole list
/// marshalled back across. Measured at 2,000 stroked circles: 168 ms
/// against 67 ms for the same circles filled, and the 101 ms difference was
/// entirely Ring building points the engine already knows how to compute.
///
/// It uses the SAME circleSegments bound as the fill, so a stroked circle
/// traces exactly the filled one rather than almost tracing it.
pub fn sceneCircleStroke(id: i64, cx: f64, cy: f64, r: f64, width: f64, col: u32) i32 {
    if (r <= 0 or width <= 0) return BAD_ARG;
    const segs = circleSegments(r);
    if (segs < 3) return BAD_ARG;
    // +1 point: the ring is CLOSED by repeating the first vertex, which is
    // what makes the join at the seam look like every other join
    const n = (segs + 1) * 2;
    const pts = alloc.alloc(f32, n) catch return BAD_ARG;
    const fr: f32 = @floatCast(r);
    const fx: f32 = @floatCast(cx);
    const fy: f32 = @floatCast(cy);
    for (0..segs + 1) |i| {
        const t = std.math.tau * @as(f32, @floatFromInt(i % segs)) / @as(f32, @floatFromInt(segs));
        pts[i * 2] = fx + fr * @cos(t);
        pts[i * 2 + 1] = fy + fr * @sin(t);
    }
    return push(id, .{ .stroke = .{ .pts = pts, .width = @floatCast(width), .col = col } });
}

/// An ELLIPSE, filled. The primitive the diagram layer was missing: of
/// graphviz's 24 node shapes, twenty are a circle, a rect or a polygon --
/// all of which this scene already draws -- and the remaining four
/// (ellipse, egg, cylinder, doublecircle) all need this one.
///
/// Tessellated ENGINE-side for the same reason sceneCircleStroke is: the
/// alternative is the face building segment points in Ring and marshalling
/// them, which measured 101 ms of pure Ring list-building at 2,000 shapes.
///
/// Segment count comes from the LARGER radius through the shared
/// circleSegments bound, so a wide flat ellipse is not under-tessellated
/// along its long axis.
pub fn sceneEllipse(id: i64, cx: f64, cy: f64, rx: f64, ry: f64, col: u32) i32 {
    if (rx <= 0 or ry <= 0) return BAD_ARG;
    const segs = circleSegments(@max(rx, ry));
    if (segs < 3) return BAD_ARG;
    const pts = alloc.alloc(f64, segs * 2) catch return BAD_ARG;
    defer alloc.free(pts);
    for (0..segs) |i| {
        const t = std.math.tau * @as(f64, @floatFromInt(i)) / @as(f64, @floatFromInt(segs));
        pts[i * 2] = cx + rx * @cos(t);
        pts[i * 2 + 1] = cy + ry * @sin(t);
    }
    return scenePolygon(id, pts, col);
}

/// A ROUNDED rectangle. The visual signature of every diagram graphviz
/// draws with style=rounded, which is what an org chart looks like -- so
/// without it the native tier draws a recognisably different picture from
/// the one the documentation shows.
///
/// Built as a polygon so the SVG and PNG tiers agree by construction, the
/// same way sceneEllipse does. The corner radius is clamped to half the
/// shorter side: a caller asking for a radius larger than the box gets a
/// stadium, not a self-intersecting outline.
fn roundRectPoints(x: f64, y: f64, w: f64, h: f64, r: f64, out: []f64) usize {
    const rr = @min(r, @min(w, h) / 2.0);
    const per: usize = 8; // segments per corner: smooth enough at any size
    var n: usize = 0;
    // corner centres, clockwise from top-left, with the sweep each covers
    const cx = [4]f64{ x + rr, x + w - rr, x + w - rr, x + rr };
    const cy = [4]f64{ y + rr, y + rr, y + h - rr, y + h - rr };
    const a0 = [4]f64{ std.math.pi, -std.math.pi / 2.0, 0.0, std.math.pi / 2.0 };
    for (0..4) |c| {
        for (0..per + 1) |i| {
            const t = a0[c] + (std.math.pi / 2.0) * @as(f64, @floatFromInt(i)) /
                @as(f64, @floatFromInt(per));
            out[n] = cx[c] + rr * @cos(t);
            out[n + 1] = cy[c] + rr * @sin(t);
            n += 2;
        }
    }
    return n;
}

pub fn sceneRoundRect(id: i64, x: f64, y: f64, w: f64, h: f64, r: f64, col: u32) i32 {
    if (w <= 0 or h <= 0 or r < 0) return BAD_ARG;
    var pts: [4 * 9 * 2]f64 = undefined;
    const n = roundRectPoints(x, y, w, h, r, &pts);
    return scenePolygon(id, pts[0..n], col);
}

pub fn sceneRoundRectStroke(id: i64, x: f64, y: f64, w: f64, h: f64, r: f64, width: f64, col: u32) i32 {
    if (w <= 0 or h <= 0 or r < 0 or width <= 0) return BAD_ARG;
    var pts: [4 * 9 * 2]f64 = undefined;
    const n = roundRectPoints(x, y, w, h, r, &pts);
    const out = alloc.alloc(f32, n + 2) catch return BAD_ARG;
    for (0..n) |i| out[i] = @floatCast(pts[i]);
    out[n] = @floatCast(pts[0]); // close the ring so the seam joins
    out[n + 1] = @floatCast(pts[1]);
    return push(id, .{ .stroke = .{ .pts = out, .width = @floatCast(width), .col = col } });
}

/// An ellipse's OUTLINE, on the same tessellation as the fill -- so a
/// stroked ellipse traces exactly the filled one rather than almost
/// tracing it, which is the property sceneCircleStroke had to learn.
pub fn sceneEllipseStroke(id: i64, cx: f64, cy: f64, rx: f64, ry: f64, width: f64, col: u32) i32 {
    if (rx <= 0 or ry <= 0 or width <= 0) return BAD_ARG;
    const segs = circleSegments(@max(rx, ry));
    if (segs < 3) return BAD_ARG;
    const n = (segs + 1) * 2;
    const pts = alloc.alloc(f32, n) catch return BAD_ARG;
    for (0..segs + 1) |i| {
        const t = std.math.tau * @as(f64, @floatFromInt(i % segs)) / @as(f64, @floatFromInt(segs));
        pts[i * 2] = @floatCast(cx + rx * @cos(t));
        pts[i * 2 + 1] = @floatCast(cy + ry * @sin(t));
    }
    return push(id, .{ .stroke = .{ .pts = pts, .width = @floatCast(width), .col = col } });
}

/// pts: flat [x0,y0,x1,y1,...], at least 2 points. A 2-point stroke IS a line.
pub fn sceneStroke(id: i64, pts: []const f64, width: f64, col: u32) i32 {
    if (pts.len < 4 or pts.len % 2 != 0 or width <= 0) return BAD_ARG;
    const copy = alloc.alloc(f32, pts.len) catch return BAD_ARG;
    for (pts, 0..) |v, i| copy[i] = @floatCast(v);
    return push(id, .{ .stroke = .{ .pts = copy, .width = @floatCast(width), .col = col } });
}

pub fn scenePolygon(id: i64, pts: []const f64, col: u32) i32 {
    if (pts.len < 6 or pts.len % 2 != 0) return BAD_ARG;
    const copy = alloc.alloc(f32, pts.len) catch return BAD_ARG;
    for (pts, 0..) |v, i| copy[i] = @floatCast(v);
    return push(id, .{ .polygon = .{ .pts = copy, .col = col } });
}

/// Post already-tessellated triangles. `verts` is x,y,r,g,b,a per vertex
/// (pixel space, 0..255 channels); `idx` is triangle indices into it.
///
/// Validated at the DOOR rather than at draw time: an out-of-range index
/// would read someone else's memory during tessellation, which is the
/// far side of a C ABI from whoever wrote it.
pub fn sceneMesh(id: i64, verts: []const f32, idx: []const u32) i32 {
    if (verts.len < 18 or verts.len % 6 != 0) return BAD_ARG; // >= 1 triangle
    if (idx.len < 3 or idx.len % 3 != 0) return BAD_ARG;
    const nverts: u32 = @intCast(verts.len / 6);
    for (idx) |i| if (i >= nverts) return BAD_ARG;

    const vcopy = alloc.dupe(f32, verts) catch return BAD_ARG;
    const icopy = alloc.dupe(u32, idx) catch {
        alloc.free(vcopy);
        return BAD_ARG;
    };
    return push(id, .{ .mesh = .{ .verts = vcopy, .idx = icopy } });
}

pub fn sceneText(id: i64, font: i64, str: []const u8, x: f64, y: f64, size: f64, col: u32) i32 {
    if (str.len == 0 or size <= 0) return BAD_ARG;
    const copy = alloc.dupe(u8, str) catch return BAD_ARG;
    return push(id, .{ .text = .{
        .font = font,
        .str = copy,
        .x = @floatCast(x),
        .y = @floatCast(y),
        .size = @floatCast(size),
        .col = col,
    } });
}

pub fn sceneCommandCount(id: i64) f64 {
    const slot = slotOf(id) orelse return -1;
    return @floatFromInt(scenes.items[slot].cmds.items.len);
}

// ---------------------------------------------------------------- geometry

/// Segment count from the ERROR BOUND, not from a magic number: the chord
/// sagitta r*(1 - cos(pi/n)) stays under MAX_SAGITTA at every radius.
pub fn circleSegments(r: f64) u32 {
    if (r <= MAX_SAGITTA) return 12;
    const cosv = 1.0 - MAX_SAGITTA / r;
    const theta = std.math.acos(@min(1.0, @max(-1.0, cosv)));
    if (theta <= 0) return 512;
    const n = @ceil(std.math.pi / theta);
    return @intFromFloat(@min(512.0, @max(12.0, n)));
}

fn cross3(ax: f32, ay: f32, bx: f32, by: f32, cx: f32, cy: f32) f32 {
    return (bx - ax) * (cy - ay) - (by - ay) * (cx - ax);
}

fn pointInTri(px: f32, py: f32, ax: f32, ay: f32, bx: f32, by: f32, cx: f32, cy: f32) bool {
    const d1 = cross3(ax, ay, bx, by, px, py);
    const d2 = cross3(bx, by, cx, cy, px, py);
    const d3 = cross3(cx, cy, ax, ay, px, py);
    const has_neg = (d1 < 0) or (d2 < 0) or (d3 < 0);
    const has_pos = (d1 > 0) or (d2 > 0) or (d3 > 0);
    return !(has_neg and has_pos);
}

/// Ear clipping for a SIMPLE polygon. A self-intersecting outline runs out
/// of ears and stops -- an honest partial fill rather than a garbage one
/// (that case is the PlutoVG kill line, recorded in the plan).
fn earClip(pts: []const f32, out: *std.ArrayList(u32)) !void {
    const n = pts.len / 2;
    if (n < 3) return;
    const idx = try alloc.alloc(u32, n);
    defer alloc.free(idx);
    var area: f64 = 0;
    for (0..n) |i| {
        const j = (i + 1) % n;
        area += @as(f64, pts[i * 2]) * pts[j * 2 + 1] - @as(f64, pts[j * 2]) * pts[i * 2 + 1];
    }
    if (area < 0) {
        for (0..n) |i| idx[i] = @intCast(n - 1 - i);
    } else {
        for (0..n) |i| idx[i] = @intCast(i);
    }
    var m = n;
    while (m > 3) {
        var clipped = false;
        var i: usize = 0;
        while (i < m) : (i += 1) {
            const ia = idx[(i + m - 1) % m];
            const ib = idx[i];
            const ic = idx[(i + 1) % m];
            const ax = pts[ia * 2];
            const ay = pts[ia * 2 + 1];
            const bx = pts[ib * 2];
            const by = pts[ib * 2 + 1];
            const cx = pts[ic * 2];
            const cy = pts[ic * 2 + 1];
            if (cross3(ax, ay, bx, by, cx, cy) <= 0) continue; // reflex or degenerate
            var is_ear = true;
            for (0..m) |k| {
                const ip = idx[k];
                if (ip == ia or ip == ib or ip == ic) continue;
                if (pointInTri(pts[ip * 2], pts[ip * 2 + 1], ax, ay, bx, by, cx, cy)) {
                    is_ear = false;
                    break;
                }
            }
            if (!is_ear) continue;
            try out.append(alloc, ia);
            try out.append(alloc, ib);
            try out.append(alloc, ic);
            var k = i;
            while (k + 1 < m) : (k += 1) idx[k] = idx[k + 1];
            m -= 1;
            clipped = true;
            break;
        }
        if (!clipped) break; // no ear found: stop honestly
    }
    if (m == 3) {
        try out.append(alloc, idx[0]);
        try out.append(alloc, idx[1]);
        try out.append(alloc, idx[2]);
    }
}

// ---------------------------------------------------------------- tessellation

const Builder = struct {
    s: *SceneSlot,
    fw: f32,
    fh: f32,

    fn ndcX(self: *const Builder, x: f32) f32 {
        return x / self.fw * 2.0 - 1.0;
    }

    fn ndcY(self: *const Builder, y: f32) f32 {
        return 1.0 - y / self.fh * 2.0;
    }

    fn shapeVert(self: *Builder, x: f32, y: f32, c: Rgba) !void {
        try self.s.shape_verts.append(alloc, self.ndcX(x));
        try self.s.shape_verts.append(alloc, self.ndcY(y));
        try self.s.shape_verts.append(alloc, c.r);
        try self.s.shape_verts.append(alloc, c.g);
        try self.s.shape_verts.append(alloc, c.b);
        try self.s.shape_verts.append(alloc, c.a);
    }

    fn tri(self: *Builder, x0: f32, y0: f32, c0: Rgba, x1: f32, y1: f32, c1: Rgba, x2: f32, y2: f32, c2: Rgba) !void {
        try self.shapeVert(x0, y0, c0);
        try self.shapeVert(x1, y1, c1);
        try self.shapeVert(x2, y2, c2);
    }

    fn quad(self: *Builder, x0: f32, y0: f32, c0: Rgba, x1: f32, y1: f32, c1: Rgba, x2: f32, y2: f32, c2: Rgba, x3: f32, y3: f32, c3: Rgba) !void {
        try self.tri(x0, y0, c0, x1, y1, c1, x2, y2, c2);
        try self.tri(x0, y0, c0, x2, y2, c2, x3, y3, c3);
    }

    fn disc(self: *Builder, cx: f32, cy: f32, r: f32, c: Rgba) !void {
        const n = circleSegments(r);
        var i: u32 = 0;
        while (i < n) : (i += 1) {
            const a0 = @as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(n)) * std.math.tau;
            const a1 = @as(f32, @floatFromInt(i + 1)) / @as(f32, @floatFromInt(n)) * std.math.tau;
            try self.tri(
                cx,
                cy,
                c,
                cx + r * @cos(a0),
                cy + r * @sin(a0),
                c,
                cx + r * @cos(a1),
                cy + r * @sin(a1),
                c,
            );
        }
    }

    fn textVert(self: *Builder, x: f32, y: f32, u: f32, v: f32, c: Rgba) !void {
        try self.s.text_verts.append(alloc, self.ndcX(x));
        try self.s.text_verts.append(alloc, self.ndcY(y));
        try self.s.text_verts.append(alloc, u);
        try self.s.text_verts.append(alloc, v);
        try self.s.text_verts.append(alloc, c.r);
        try self.s.text_verts.append(alloc, c.g);
        try self.s.text_verts.append(alloc, c.b);
        try self.s.text_verts.append(alloc, c.a);
    }
};

/// Tessellate, and if the glyph atlas ran out of room, GROW IT AND DO IT
/// AGAIN rather than shipping a picture with text missing.
///
/// Growth cannot happen mid-build (entries move, and uvs already emitted
/// would point at the wrong pixels), so the retry restarts the whole
/// tessellation on the larger atlas. Bounded by the atlas's own ceiling:
/// once it stops growing the loop stops, the glyphs that still do not fit
/// are COUNTED, and the caller can see that in AtlasStats rather than
/// wondering where its labels went.
fn build(s: *SceneSlot) !void {
    if (!s.dirty) return;
    var attempt: u8 = 0;
    while (attempt < 4) : (attempt += 1) {
        atlas.clearDropped(); // the gauge describes THIS attempt's result
        try buildOnce(s);
        if (atlas.droppedCount() == 0) return; // nothing lost: done
        const w_before = atlas.atlasWidth();
        atlas.growIfWanted();
        if (atlas.atlasWidth() == w_before) return; // at the ceiling; drops counted
        s.dirty = true; // the larger atlas needs a fresh tessellation
    }
}

fn buildOnce(s: *SceneSlot) !void {
    s.shape_verts.clearRetainingCapacity();
    s.text_verts.clearRetainingCapacity();
    s.segs.clearRetainingCapacity();

    var b = Builder{ .s = s, .fw = @floatFromInt(s.w), .fh = @floatFromInt(s.h) };
    var cur_kind: ?SegKind = null;
    var seg_first: u32 = 0;

    // POINTERS, not copies: the image arm caches its texture id ON the
    // command, and a `for (items) |cmd|` capture is a const copy -- the
    // upload would have happened on a temporary every single build.
    for (s.cmds.items) |*cmd| {
        // An IMAGE shares the TEXT vertex format (pos, uv, colour) and so
        // shares its buffer -- but never its segment: each image draws with
        // its OWN texture, so two adjacent images are two draws.
        const kind: SegKind = switch (cmd.*) {
            .text => .text,
            .image => .image,
            else => .shape,
        };
        const use_text_buf = (kind == .text or kind == .image);
        const vsize: u32 = if (use_text_buf) 8 else 6;
        const cur_len: u32 = @intCast(if (use_text_buf) s.text_verts.items.len / vsize else s.shape_verts.items.len / vsize);
        if (cur_kind == null or cur_kind.? != kind) {
            if (cur_kind) |ck| {
                const prev_len: u32 = @intCast(if (ck == .text or ck == .image) s.text_verts.items.len / 8 else s.shape_verts.items.len / 6);
                if (prev_len > seg_first) try s.segs.append(alloc, .{ .kind = ck, .first = seg_first, .count = prev_len - seg_first, .tex = 0 });
            }
            cur_kind = kind;
            seg_first = cur_len;
        }

        switch (cmd.*) {
            .rect => |k| {
                const a = Rgba.unpack(k.c0);
                const c2 = Rgba.unpack(k.c1);
                // gradient corners: c0 -> c1 along x (or y when vertical)
                const tl = a;
                const tr = if (k.gradient and !k.vertical) c2 else a;
                const br = if (k.gradient) c2 else a;
                const bl = if (k.gradient and k.vertical) c2 else a;
                try b.quad(k.x, k.y, tl, k.x + k.w, k.y, tr, k.x + k.w, k.y + k.h, br, k.x, k.y + k.h, bl);
            },
            .circle => |k| try b.disc(k.cx, k.cy, k.r, Rgba.unpack(k.col)),
            .stroke => |k| {
                const col = Rgba.unpack(k.col);
                const hw = k.width * 0.5;
                const np = k.pts.len / 2;
                for (0..np - 1) |i| {
                    const x0 = k.pts[i * 2];
                    const y0 = k.pts[i * 2 + 1];
                    const x1 = k.pts[(i + 1) * 2];
                    const y1 = k.pts[(i + 1) * 2 + 1];
                    const dx = x1 - x0;
                    const dy = y1 - y0;
                    const len = @sqrt(dx * dx + dy * dy);
                    if (len <= 0) continue;
                    const nx = -dy / len * hw;
                    const ny = dx / len * hw;
                    try b.quad(x0 + nx, y0 + ny, col, x1 + nx, y1 + ny, col, x1 - nx, y1 - ny, col, x0 - nx, y0 - ny, col);
                }
                // round joins AND round caps: a disc at every vertex. Matches
                // the SVG side's stroke-linejoin/linecap="round".
                for (0..np) |i| try b.disc(k.pts[i * 2], k.pts[i * 2 + 1], hw, col);
            },
            .mesh => |k| {
                // No tessellation to do -- the caller already did it. This
                // arm exists only to EXPAND the index buffer, because the
                // shape pipeline draws non-indexed.
                var i: usize = 0;
                while (i + 2 < k.idx.len) : (i += 3) {
                    for (k.idx[i .. i + 3]) |vi| {
                        const v = k.verts[vi * 6 ..];
                        try b.shapeVert(v[0], v[1], .{ .r = v[2] / 255.0, .g = v[3] / 255.0, .b = v[4] / 255.0, .a = v[5] / 255.0 });
                    }
                }
            },
            .polygon => |k| {
                const col = Rgba.unpack(k.col);
                var idx: std.ArrayList(u32) = .{};
                defer idx.deinit(alloc);
                try earClip(k.pts, &idx);
                var i: usize = 0;
                while (i + 2 < idx.items.len + 1 and i + 3 <= idx.items.len) : (i += 3) {
                    try b.tri(
                        k.pts[idx.items[i] * 2],
                        k.pts[idx.items[i] * 2 + 1],
                        col,
                        k.pts[idx.items[i + 1] * 2],
                        k.pts[idx.items[i + 1] * 2 + 1],
                        col,
                        k.pts[idx.items[i + 2] * 2],
                        k.pts[idx.items[i + 2] * 2 + 1],
                        col,
                    );
                }
            },
            .image => |*k| {
                // The texture is made ONCE and kept on the command. A
                // spectrogram redrawn every frame must not re-upload a
                // megabyte a frame -- the same rule the vertex buffers
                // already follow.
                if (k.tex == 0) {
                    k.tex = gpu.stz_gpu_texture_new(@floatFromInt(k.iw), @floatFromInt(k.ih), @floatFromInt(gpu.TEX_LINEAR));
                    if (k.tex != 0)
                        _ = gpu.stz_gpu_texture_write(k.tex, k.rgba.ptr, @floatFromInt(k.rgba.len));
                }
                const col = Rgba.unpack(k.col);
                const x0 = k.x;
                const y0 = k.y;
                const x1 = k.x + k.w;
                const y1 = k.y + k.h;
                try b.textVert(x0, y0, 0, 0, col);
                try b.textVert(x1, y0, 1, 0, col);
                try b.textVert(x1, y1, 1, 1, col);
                try b.textVert(x0, y0, 0, 0, col);
                try b.textVert(x1, y1, 1, 1, col);
                try b.textVert(x0, y1, 0, 1, col);
                const now: u32 = @intCast(s.text_verts.items.len / 8);
                try s.segs.append(alloc, .{ .kind = .image, .first = seg_first, .count = now - seg_first, .tex = k.tex });
                cur_kind = null;   // nothing may merge with an image
                seg_first = now;
            },
            .text => |k| {
                const col = Rgba.unpack(k.col);
                const layout = gtext.textLayout(k.font, k.str, k.size) catch continue;
                defer layout.deinit();
                const aw: f32 = @floatCast(atlas.atlasWidth());
                const ah: f32 = @floatCast(atlas.atlasHeight());
                for (layout.glyphs) |g| {
                    const e = atlas.glyphEntry(k.font, g.gid, k.size) catch continue;
                    if (e.w == 0 or e.h == 0) continue; // ink-free (space)
                    const px = k.x + @as(f32, @floatCast(g.x));
                    const py = k.y - @as(f32, @floatCast(g.y)); // scene y is DOWN
                    const x0 = px + @as(f32, @floatFromInt(e.xoff));
                    const y0 = py + @as(f32, @floatFromInt(e.yoff));
                    const x1 = x0 + @as(f32, @floatFromInt(e.w));
                    const y1 = y0 + @as(f32, @floatFromInt(e.h));
                    const ua = @as(f32, @floatFromInt(e.x)) / aw;
                    const va = @as(f32, @floatFromInt(e.y)) / ah;
                    const ub = @as(f32, @floatFromInt(e.x + e.w)) / aw;
                    const vb = @as(f32, @floatFromInt(e.y + e.h)) / ah;
                    try b.textVert(x0, y0, ua, va, col);
                    try b.textVert(x1, y0, ub, va, col);
                    try b.textVert(x1, y1, ub, vb, col);
                    try b.textVert(x0, y0, ua, va, col);
                    try b.textVert(x1, y1, ub, vb, col);
                    try b.textVert(x0, y1, ua, vb, col);
                }
            },
        }
    }
    if (cur_kind) |ck| {
        const prev_len: u32 = @intCast(if (ck == .text or ck == .image) s.text_verts.items.len / 8 else s.shape_verts.items.len / 6);
        if (prev_len > seg_first) try s.segs.append(alloc, .{ .kind = ck, .first = seg_first, .count = prev_len - seg_first, .tex = 0 });
    }
    s.dirty = false;
    s.build_count += 1;
}

/// [commands, shape verts, text verts, draw segments, builds]
pub fn sceneStats(id: i64) ?[6]f64 {
    const slot = slotOf(id) orelse return null;
    const s = &scenes.items[slot];
    build(s) catch return null;
    return .{
        @floatFromInt(s.cmds.items.len),
        @floatFromInt(s.shape_verts.items.len / 6),
        @floatFromInt(s.text_verts.items.len / 8),
        @floatFromInt(s.segs.items.len),
        @floatFromInt(s.build_count),
        // GR5: uploads, which a frame loop cares about and a one-shot
        // render cannot distinguish from builds
        @floatFromInt(s.vertex_uploads),
    };
}

// ---------------------------------------------------------------- SVG

fn svgNum(out: *std.ArrayList(u8), v: f64) !void {
    var tmp: [32]u8 = undefined;
    var s = try std.fmt.bufPrint(&tmp, "{d:.3}", .{v});
    if (std.mem.indexOfScalar(u8, s, '.') != null) {
        var end = s.len;
        while (end > 0 and s[end - 1] == '0') end -= 1;
        if (end > 0 and s[end - 1] == '.') end -= 1;
        s = s[0..end];
    }
    try out.appendSlice(alloc, s);
}

fn svgFill(out: *std.ArrayList(u8), attr: []const u8, col: u32) !void {
    var tmp: [64]u8 = undefined;
    const s = try std.fmt.bufPrint(&tmp, " {s}=\"rgb({d},{d},{d})\"", .{
        attr,
        (col >> 24) & 0xff,
        (col >> 16) & 0xff,
        (col >> 8) & 0xff,
    });
    try out.appendSlice(alloc, s);
    const a = col & 0xff;
    if (a != 255) {
        const s2 = try std.fmt.bufPrint(&tmp, " {s}-opacity=\"{d:.3}\"", .{ attr, @as(f64, @floatFromInt(a)) / 255.0 });
        try out.appendSlice(alloc, s2);
    }
}

fn svgAttr(out: *std.ArrayList(u8), name: []const u8, v: f64) !void {
    try out.appendSlice(alloc, " ");
    try out.appendSlice(alloc, name);
    try out.appendSlice(alloc, "=\"");
    try svgNum(out, v);
    try out.appendSlice(alloc, "\"");
}

/// The SVG tier: vector output, no device, always available. Caller owns.
pub fn sceneToSvg(id: i64) !?[]u8 {
    const slot = slotOf(id) orelse return null;
    const s = &scenes.items[slot];

    var defs: std.ArrayList(u8) = .{};
    defer defs.deinit(alloc);
    var body: std.ArrayList(u8) = .{};
    defer body.deinit(alloc);
    var ngrad: u32 = 0;

    if ((s.clear & 0xff) != 0) {
        try body.appendSlice(alloc, "<rect x=\"0\" y=\"0\"");
        try svgAttr(&body, "width", @floatFromInt(s.w));
        try svgAttr(&body, "height", @floatFromInt(s.h));
        try svgFill(&body, "fill", s.clear);
        try body.appendSlice(alloc, "/>\n");
    }

    for (s.cmds.items) |cmd| {
        switch (cmd) {
            // The SVG tier carries the image as a base64 PNG, so a picture
            // with a spectrogram in it is still ONE self-contained file that
            // needs no device -- which is the whole promise of this tier.
            .image => |k| {
                const png = render.pngEncode(k.iw, k.ih, k.rgba, 1) catch continue;
                defer alloc.free(png);
                const Enc = std.base64.standard.Encoder;
                const b64 = alloc.alloc(u8, Enc.calcSize(png.len)) catch continue;
                defer alloc.free(b64);
                _ = Enc.encode(b64, png);
                try body.appendSlice(alloc, "<image");
                try svgAttr(&body, "x", k.x);
                try svgAttr(&body, "y", k.y);
                try svgAttr(&body, "width", k.w);
                try svgAttr(&body, "height", k.h);
                // preserveAspectRatio=none: the caller gave a box and meant
                // it; letterboxing would silently move every pixel.
                try body.appendSlice(alloc, " preserveAspectRatio=\"none\" href=\"data:image/png;base64,");
                try body.appendSlice(alloc, b64);
                try body.appendSlice(alloc, "\"/>\n");
            },
            .rect => |k| {
                try body.appendSlice(alloc, "<rect");
                try svgAttr(&body, "x", k.x);
                try svgAttr(&body, "y", k.y);
                try svgAttr(&body, "width", k.w);
                try svgAttr(&body, "height", k.h);
                if (k.gradient) {
                    var tmp: [256]u8 = undefined;
                    const gid = ngrad;
                    ngrad += 1;
                    const d = try std.fmt.bufPrint(&tmp, "<linearGradient id=\"g{d}\" x1=\"{d}\" y1=\"{d}\" x2=\"{d}\" y2=\"{d}\">" ++
                        "<stop offset=\"0\" stop-color=\"rgb({d},{d},{d})\"/>" ++
                        "<stop offset=\"1\" stop-color=\"rgb({d},{d},{d})\"/></linearGradient>\n", .{
                        gid,
                        @as(u32, 0),
                        @as(u32, 0),
                        @as(u32, if (k.vertical) 0 else 1),
                        @as(u32, if (k.vertical) 1 else 0),
                        (k.c0 >> 24) & 0xff,
                        (k.c0 >> 16) & 0xff,
                        (k.c0 >> 8) & 0xff,
                        (k.c1 >> 24) & 0xff,
                        (k.c1 >> 16) & 0xff,
                        (k.c1 >> 8) & 0xff,
                    });
                    try defs.appendSlice(alloc, d);
                    const f = try std.fmt.bufPrint(&tmp, " fill=\"url(#g{d})\"", .{gid});
                    try body.appendSlice(alloc, f);
                } else {
                    try svgFill(&body, "fill", k.c0);
                }
                try body.appendSlice(alloc, "/>\n");
            },
            .circle => |k| {
                try body.appendSlice(alloc, "<circle");
                try svgAttr(&body, "cx", k.cx);
                try svgAttr(&body, "cy", k.cy);
                try svgAttr(&body, "r", k.r);
                try svgFill(&body, "fill", k.col);
                try body.appendSlice(alloc, "/>\n");
            },
            .stroke => |k| {
                try body.appendSlice(alloc, "<polyline points=\"");
                var i: usize = 0;
                while (i + 1 < k.pts.len) : (i += 2) {
                    if (i > 0) try body.appendSlice(alloc, " ");
                    try svgNum(&body, k.pts[i]);
                    try body.appendSlice(alloc, ",");
                    try svgNum(&body, k.pts[i + 1]);
                }
                try body.appendSlice(alloc, "\" fill=\"none\"");
                try svgFill(&body, "stroke", k.col);
                try svgAttr(&body, "stroke-width", k.width);
                // round joins/caps: the tessellator puts a disc at every
                // vertex -- the two backends must agree on cap semantics
                try body.appendSlice(alloc, " stroke-linejoin=\"round\" stroke-linecap=\"round\"/>\n");
            },
            .mesh => |k| {
                // ONE <polygon> per triangle, filled with the FIRST vertex's
                // colour. Exact for a UI toolkit's geometry, which is
                // flat-coloured quads; an approximation for a gradient mesh,
                // where the GPU tier interpolates and this tier cannot. Said
                // here rather than discovered from a screenshot.
                var i: usize = 0;
                while (i + 2 < k.idx.len) : (i += 3) {
                    const c0 = k.verts[k.idx[i] * 6 ..];
                    try body.appendSlice(alloc, "<polygon points=\"");
                    for (k.idx[i .. i + 3], 0..) |vi, j| {
                        if (j > 0) try body.appendSlice(alloc, " ");
                        try svgNum(&body, k.verts[vi * 6]);
                        try body.appendSlice(alloc, ",");
                        try svgNum(&body, k.verts[vi * 6 + 1]);
                    }
                    const packed_col: u32 = (@as(u32, @intFromFloat(c0[2])) << 24) |
                        (@as(u32, @intFromFloat(c0[3])) << 16) |
                        (@as(u32, @intFromFloat(c0[4])) << 8) |
                        @as(u32, @intFromFloat(c0[5]));
                    try body.appendSlice(alloc, "\"");
                    try svgFill(&body, "fill", packed_col);
                    try body.appendSlice(alloc, "/>\n");
                }
            },
            .polygon => |k| {
                try body.appendSlice(alloc, "<polygon points=\"");
                var i: usize = 0;
                while (i + 1 < k.pts.len) : (i += 2) {
                    if (i > 0) try body.appendSlice(alloc, " ");
                    try svgNum(&body, k.pts[i]);
                    try body.appendSlice(alloc, ",");
                    try svgNum(&body, k.pts[i + 1]);
                }
                try body.appendSlice(alloc, "\"");
                try svgFill(&body, "fill", k.col);
                try body.appendSlice(alloc, "/>\n");
            },
            .text => |k| {
                // glyph OUTLINES from the same layout the GPU path uses:
                // exact positions, no font needed by the viewer
                const layout = gtext.textLayout(k.font, k.str, k.size) catch continue;
                defer layout.deinit();
                var path: std.ArrayList(u8) = .{};
                defer path.deinit(alloc);
                for (layout.glyphs) |g| {
                    _ = gtext.glyphOutlineSvg(
                        k.font,
                        g.gid,
                        k.size,
                        @as(f64, k.x) + g.x,
                        @as(f64, k.y) - g.y,
                        &path,
                    ) catch continue;
                }
                if (path.items.len == 0) continue;
                try body.appendSlice(alloc, "<path d=\"");
                try body.appendSlice(alloc, path.items);
                try body.appendSlice(alloc, "\"");
                try svgFill(&body, "fill", k.col);
                try body.appendSlice(alloc, "/>\n");
            },
        }
    }

    var out: std.ArrayList(u8) = .{};
    errdefer out.deinit(alloc);
    var tmp: [256]u8 = undefined;
    const head = try std.fmt.bufPrint(&tmp, "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"{d}\" height=\"{d}\" viewBox=\"0 0 {d} {d}\">\n", .{ s.w, s.h, s.w, s.h });
    try out.appendSlice(alloc, head);
    if (defs.items.len > 0) {
        try out.appendSlice(alloc, "<defs>\n");
        try out.appendSlice(alloc, defs.items);
        try out.appendSlice(alloc, "</defs>\n");
    }
    try out.appendSlice(alloc, body.items);
    try out.appendSlice(alloc, "</svg>\n");
    return try out.toOwnedSlice(alloc);
}

// ---------------------------------------------------------------- GPU tier

// One entry per target format (0 = RGBA8 offscreen, 1 = BGRA8 swapchain).
// The SHADER is the same text; only the color-target format differs, which
// is exactly what the pipeline cache key now distinguishes.
var pipe_shape: [2]i64 = @splat(0);
var pipe_text: [2]i64 = @splat(0);
var pipe_image: [2]i64 = @splat(0);

fn ensurePipelines(tfmt: i32) bool {
    const t: usize = if (tfmt == render.TFMT_BGRA8) 1 else 0;
    if (pipe_shape[t] == 0 or gpu.stz_gpu_is_available() == 0) {
        pipe_shape[t] = render.stz_gpu_render_pipeline_fmt(WGSL_SHAPE.ptr, @floatFromInt(WGSL_SHAPE.len), "2,4", 3, 1, 0, 0, @floatFromInt(tfmt));
    }
    if (pipe_text[t] == 0) {
        pipe_text[t] = render.stz_gpu_render_pipeline_fmt(WGSL_TEXT.ptr, @floatFromInt(WGSL_TEXT.len), "2,2,4", 5, 1, 0, 0, @floatFromInt(tfmt));
    }
    if (pipe_image[t] == 0) {
        pipe_image[t] = render.stz_gpu_render_pipeline_fmt(WGSL_IMAGE.ptr, @floatFromInt(WGSL_IMAGE.len), "2,2,4", 5, 1, 0, 0, @floatFromInt(tfmt));
    }
    return pipe_shape[t] != 0 and pipe_text[t] != 0 and pipe_image[t] != 0;
}

/// Device loss: pipelines and scene-owned GPU objects died with it. Ids are
/// gen-keyed, so the stale ones are DETECTED -- but zeroing them here keeps
/// the next render from re-checking every one.
pub fn forgetDeviceObjects() void {
    pipe_shape = @splat(0);
    pipe_text = @splat(0);
    for (scenes.items) |*s| {
        if (!s.live) continue;
        s.vbuf_shape = 0;
        s.vbuf_text = 0;
        s.target = 0;
        s.ext_target = 0;
    }
    atlas.forgetTexture();
}

/// Create-or-reuse a device buffer big enough for `bytes`, replacing it if
/// it went STALE (the VRAM budget may have evicted it between renders).
fn ensureBuffer(cur: i64, bytes: usize) i64 {
    var id = cur;
    if (id != 0) {
        const sz = gpu.stz_gpu_buffer_size(id);
        if (sz < 0) {
            id = 0; // evicted or freed: gen-keyed id answered STALE
        } else if (@as(usize, @intFromFloat(sz)) < bytes) {
            _ = gpu.stz_gpu_buffer_free(id);
            id = 0;
        }
    }
    if (id == 0) id = gpu.stz_gpu_buffer_new(@floatFromInt(bytes));
    return id;
}

/// Tessellate (if dirty), upload what changed, draw the whole scene in ONE
/// render pass. The target holds the result; nothing is read back here --
/// so the two public tiers below each pay exactly one readback, never two.
fn renderToTarget(s: *SceneSlot) !bool {
    if (gpu.stz_gpu_is_available() == 0) {
        gpu.countFallback();
        return false;
    }
    try build(s);
    const tfmt: i32 = if (s.ext_target != 0) s.ext_tfmt else render.TFMT_RGBA8;
    if (!ensurePipelines(tfmt)) {
        gpu.countFallback();
        return false;
    }

    if (s.ext_target == 0) {
        // Drop the offscreen target when it is stale OR when it no longer
        // MATCHES the scene's size. The size case only became reachable in
        // GR5, when sceneDrawToTarget gained the power to retarget a scene
        // to a window -- and it failed silently: ToPng read back through a
        // target of the old dimensions and returned nothing at all. A
        // resized scene saved an EMPTY png while drawing perfectly on
        // screen, which is as quiet as a defect gets.
        if (s.target != 0 and (gpu.stz_gpu_texture_width(s.target) != @as(f64, @floatFromInt(s.w)) or
            gpu.stz_gpu_texture_height(s.target) != @as(f64, @floatFromInt(s.h))))
        {
            _ = gpu.stz_gpu_texture_free(s.target);
            s.target = 0;
        }
        if (s.target == 0) {
            s.target = gpu.stz_gpu_texture_new(@floatFromInt(s.w), @floatFromInt(s.h), @floatFromInt(gpu.TEX_TARGET));
            if (s.target == 0) {
                gpu.countFallback();
                return false;
            }
        }
    }
    const draw_target = if (s.ext_target != 0) s.ext_target else s.target;
    const ti: usize = if (tfmt == render.TFMT_BGRA8) 1 else 0;

    // Re-upload only what CHANGED. `ensureBuffer` may hand back a fresh
    // buffer (the VRAM budget can evict one between frames), and a fresh
    // buffer holds nothing -- so the test is "same generation AND same
    // buffer", not generation alone.
    const shape_buf_before = s.vbuf_shape;
    const text_buf_before = s.vbuf_text;
    var needs_upload = s.uploaded_build != s.build_count;
    if (s.shape_verts.items.len > 0) {
        s.vbuf_shape = ensureBuffer(s.vbuf_shape, s.shape_verts.items.len * 4);
        if (s.vbuf_shape == 0) return false;
        if (s.vbuf_shape != shape_buf_before) needs_upload = true;
    }
    if (s.text_verts.items.len > 0) {
        s.vbuf_text = ensureBuffer(s.vbuf_text, s.text_verts.items.len * 4);
        if (s.vbuf_text == 0) return false;
        if (s.vbuf_text != text_buf_before) needs_upload = true;
    }
    if (needs_upload) {
        if (s.shape_verts.items.len > 0) {
            const bytes = s.shape_verts.items.len * 4;
            if (gpu.stz_gpu_buffer_write(s.vbuf_shape, @ptrCast(s.shape_verts.items.ptr), @floatFromInt(bytes)) != gpu.OK) return false;
        }
        if (s.text_verts.items.len > 0) {
            const bytes = s.text_verts.items.len * 4;
            if (gpu.stz_gpu_buffer_write(s.vbuf_text, @ptrCast(s.text_verts.items.ptr), @floatFromInt(bytes)) != gpu.OK) return false;
        }
        s.uploaded_build = s.build_count;
        s.vertex_uploads += 1;
    }
    const atlas_tex: i64 = if (s.text_verts.items.len > 0) atlas.textureId() else 0;

    const cl = Rgba.unpack(s.clear);
    // An OVERLAY preserves the frame it annotates; anything else clears.
    const begun = if (s.ext_over)
        render.stz_gpu_render_begin_over(draw_target)
    else
        render.stz_gpu_render_begin(draw_target, cl.r, cl.g, cl.b, cl.a);
    if (begun != gpu.OK) return false;
    for (s.segs.items) |seg| {
        if (seg.kind == .shape) {
            _ = render.stz_gpu_render_draw(pipe_shape[ti], s.vbuf_shape, @floatFromInt(seg.first), @floatFromInt(seg.count), 0);
        } else if (seg.kind == .image) {
            if (seg.tex != 0)
                _ = render.stz_gpu_render_draw(pipe_image[ti], s.vbuf_text, @floatFromInt(seg.first), @floatFromInt(seg.count), seg.tex);
        } else if (atlas_tex != 0) {
            _ = render.stz_gpu_render_draw(pipe_text[ti], s.vbuf_text, @floatFromInt(seg.first), @floatFromInt(seg.count), atlas_tex);
        }
    }
    if (render.stz_gpu_render_end() != gpu.OK) return false;
    return true;
}

/// GR5: draw this scene into a target somebody else owns -- a swapchain
/// frame. NO readback and NO encode: the pixels are produced and shown, and
/// the picture never crosses the bus. That absence is the whole point of a
/// window tier; everything else here is the code that was already running.
///
/// `w`/`h` retarget the scene when the window has been resized, so the
/// display list keeps describing the window it is drawn in.
/// Draw this 2D scene OVER whatever the target already holds. Same as
/// sceneDrawToTarget except the pass preserves the existing contents, which
/// is what makes a HUD possible: the 3D frame is drawn first, then this.
/// A field of samples, drawn in one call. rgba is iw*ih*4 bytes, copied --
/// the caller's buffer is theirs to free, and a stored slice of it would be
/// a use-after-free the moment they did.
pub fn sceneImage(id: i64, x: f64, y: f64, w: f64, h: f64, iw: u32, ih: u32, rgba: []const u8, col: u32) i32 {
    if (iw == 0 or ih == 0 or w <= 0 or h <= 0) return BAD_ARG;
    if (rgba.len < @as(usize, iw) * @as(usize, ih) * 4) return BAD_ARG;
    const copy = alloc.alloc(u8, @as(usize, iw) * @as(usize, ih) * 4) catch return BAD_ARG;
    @memcpy(copy, rgba[0..copy.len]);
    return push(id, .{ .image = .{
        .x = @floatCast(x), .y = @floatCast(y),
        .w = @floatCast(w), .h = @floatCast(h),
        .iw = iw, .ih = ih, .rgba = copy, .tex = 0, .col = col,
    } });
}

pub fn sceneDrawOverTarget(id: i64, target_id: i64, tfmt: i32, w: u32, h: u32) bool {
    const slot = slotOf(id) orelse return false;
    const s = &scenes.items[slot];
    if (w != 0 and h != 0) _ = sceneResize(id, w, h);
    s.ext_target = target_id;
    s.ext_tfmt = tfmt;
    s.ext_over = true;
    defer {
        s.ext_target = 0;
        s.ext_tfmt = 0;
        s.ext_over = false;
    }
    return renderToTarget(s) catch false;
}

pub fn sceneDrawToTarget(id: i64, target_id: i64, tfmt: i32, w: u32, h: u32) bool {
    const slot = slotOf(id) orelse return false;
    const s = &scenes.items[slot];
    if (w != 0 and h != 0) _ = sceneResize(id, w, h);
    s.ext_target = target_id;
    s.ext_tfmt = tfmt;
    defer {
        s.ext_target = 0;
        s.ext_tfmt = 0;
    }
    return renderToTarget(s) catch false;
}

/// Raw RGBA8 pixels of the GPU tier. The parity witness: the same bytes the
/// PNG encodes, before any compression can be blamed. Caller owns.
pub fn sceneToPixels(id: i64) !?[]u8 {
    const slot = slotOf(id) orelse return null;
    const s = &scenes.items[slot];
    if (!try renderToTarget(s)) return null;
    const npix = @as(usize, s.w) * s.h * 4;
    const out = try alloc.alloc(u8, npix);
    errdefer alloc.free(out);
    if (render.stz_gpu_target_read(s.target, out.ptr, @floatFromInt(npix)) != gpu.OK) {
        alloc.free(out);
        return null;
    }
    return out;
}

/// The GPU tier: render, read back ONCE, encode. null when there is no
/// device -- and that refusal is COUNTED, so the face can fall to the SVG
/// tier knowing why. Caller owns the returned bytes.
pub fn sceneToPng(id: i64, level: i32) !?[]u8 {
    const px = try sceneToPixels(id) orelse return null;
    defer alloc.free(px);
    const slot = slotOf(id) orelse return null;
    const s = &scenes.items[slot];
    return try render.pngEncode(s.w, s.h, px, level);
}

test "circle segments honour the sagitta bound at every radius" {
    for ([_]f64{ 1, 5, 20, 100, 500, 2000 }) |r| {
        const n = circleSegments(r);
        const sag = r * (1.0 - @cos(std.math.pi / @as(f64, @floatFromInt(n))));
        try std.testing.expect(sag <= MAX_SAGITTA + 1e-9 or n == 512);
    }
}

test "ear clipping fills a concave polygon with n-2 triangles" {
    // an L shape: 6 vertices, one reflex corner
    const pts = [_]f32{ 0, 0, 10, 0, 10, 4, 4, 4, 4, 10, 0, 10 };
    var idx: std.ArrayList(u32) = .{};
    defer idx.deinit(alloc);
    try earClip(&pts, &idx);
    try std.testing.expectEqual(@as(usize, 12), idx.items.len); // (6-2)*3
}
