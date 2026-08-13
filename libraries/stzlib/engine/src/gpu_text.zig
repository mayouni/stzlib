//! stz_gpu text pipeline -- GR2 of SOFTANZA_GRAPHICS_PLAN.md.
//!
//! THE three-stage pipeline the plan mandates, one engine entry serving
//! every renderer (GPU batch and SVG emitter alike), so the two backends
//! cannot disagree about where letters sit:
//!
//!   1. SheenBidi  -- UAX#9: the paragraph is split into VISUAL-ORDER runs
//!                    with embedding levels (mixed RTL/LTR handled here).
//!   2. HarfBuzz   -- OpenType shaping per run: Arabic contextual joining,
//!                    mandatory ligatures (lam-alef), GSUB/GPOS. Codepoints
//!                    go in; positioned GLYPH IDS come out. Shaping is run
//!                    with full-paragraph context (item offset/length), so
//!                    joining sees its neighbors even across run edges.
//!   3. stb_truetype -- rasterization BY GLYPH ID (exactly what a shaper
//!                    outputs; stb never sees codepoints).
//!
//! Everything here is CPU-side: fonts and layout work with NO device --
//! the SVG tier and CI shape Arabic without a GPU. Per-codepoint Arabic
//! is WRONG, not degraded (the plan's words); this file is why the
//! library never has to do it.
//!
//! Scale contract: HarfBuzz positions are computed at scale size_px*64
//! against the face's units-per-em and divided out to px (1/64 px
//! precision). Glyph rasters use stbtt_ScaleForMappingEmToPixels -- the
//! SAME em->px mapping -- so metrics and bitmaps agree.
//!
//! Single-line contract (GR2a): layout covers the FIRST paragraph of the
//! text (up to a paragraph separator); line breaking is a later, workload-
//! justified increment. Baseline at y=0, x advancing right; glyph y is the
//! HarfBuzz y-offset (positive up, as HarfBuzz reports it).
//!
//! Threading: single-threaded by contract, like the whole bridge.

const std = @import("std");

const c = @cImport({
    @cInclude("hb.h");
    @cInclude("SheenBidi/SheenBidi.h");
    @cInclude("stb_truetype.h");
});

const alloc = std.heap.c_allocator;

pub const OK: i32 = 0;
pub const STALE: i32 = 2;
pub const BAD_ARG: i32 = 3;

// ---------------------------------------------------------------- font table
// Gen-keyed like every other handle table in this DLL. CPU-side resources:
// no VRAM budget, explicit Free only (fonts are few and long-lived).

const FontSlot = struct {
    data: []u8 = &.{}, // owned copy of the font file bytes (stbtt reads it)
    blob: ?*c.hb_blob_t = null,
    face: ?*c.hb_face_t = null,
    font: ?*c.hb_font_t = null,
    stbtt: c.stbtt_fontinfo = undefined,
    upem: u32 = 0,
    gen: u32 = 1,
    live: bool = false,
};

var fonts: std.ArrayList(FontSlot) = .{};

fn makeId(slot: usize, gen: u32) i64 {
    return (@as(i64, gen) << 32) | @as(i64, @intCast(slot + 1));
}

fn slotOf(id: i64) ?usize {
    const idx = id & 0xffff_ffff;
    if (idx <= 0 or idx > @as(i64, @intCast(fonts.items.len))) return null;
    const slot: usize = @intCast(idx - 1);
    const gen: u32 = @intCast((id >> 32) & 0xffff_ffff);
    if (!fonts.items[slot].live or fonts.items[slot].gen != gen) return null;
    return slot;
}

/// Load a font from memory (TTF/OTF bytes). Both stages must accept it:
/// HarfBuzz (a face with glyphs) AND stb_truetype (an offset-0 font).
/// Returns a gen-keyed id, 0 on refusal.
pub fn fontLoad(bytes: []const u8) i64 {
    if (bytes.len < 12) return 0;
    const copy = alloc.dupe(u8, bytes) catch return 0;

    const blob = c.hb_blob_create(copy.ptr, @intCast(copy.len), c.HB_MEMORY_MODE_READONLY, null, null);
    const face = c.hb_face_create(blob, 0);
    const nglyphs = c.hb_face_get_glyph_count(face);
    if (nglyphs == 0) {
        c.hb_face_destroy(face);
        c.hb_blob_destroy(blob);
        alloc.free(copy);
        return 0;
    }
    const font = c.hb_font_create(face);

    var slot: usize = fonts.items.len;
    for (fonts.items, 0..) |s, i| {
        if (!s.live) {
            slot = i;
            break;
        }
    }
    if (slot == fonts.items.len) {
        fonts.append(alloc, .{}) catch {
            c.hb_font_destroy(font);
            c.hb_face_destroy(face);
            c.hb_blob_destroy(blob);
            alloc.free(copy);
            return 0;
        };
    }
    const s = &fonts.items[slot];
    if (c.stbtt_InitFont(&s.stbtt, copy.ptr, 0) == 0) {
        c.hb_font_destroy(font);
        c.hb_face_destroy(face);
        c.hb_blob_destroy(blob);
        alloc.free(copy);
        return 0;
    }
    s.data = copy;
    s.blob = blob;
    s.face = face;
    s.font = font;
    s.upem = c.hb_face_get_upem(face);
    s.live = true;
    return makeId(slot, s.gen);
}

pub fn fontFree(id: i64) i32 {
    const slot = slotOf(id) orelse return STALE;
    const s = &fonts.items[slot];
    if (s.font) |f| c.hb_font_destroy(f);
    if (s.face) |f| c.hb_face_destroy(f);
    if (s.blob) |b| c.hb_blob_destroy(b);
    alloc.free(s.data);
    s.data = &.{};
    s.font = null;
    s.face = null;
    s.blob = null;
    s.live = false;
    s.gen +%= 1;
    return OK;
}

pub fn fontGlyphCount(id: i64) f64 {
    const slot = slotOf(id) orelse return -1;
    return @floatFromInt(c.hb_face_get_glyph_count(fonts.items[slot].face));
}

// ---------------------------------------------------------------- layout

pub const Glyph = struct {
    gid: u32,
    x: f64, // pen position + x-offset, px, visual left-to-right -- the DRAW x
    y: f64, // y-offset from baseline, px (positive up, HarfBuzz convention)
    cluster: u32, // BYTE index into the utf8 input: the cluster's FIRST byte
    // --- the reversibility fields (§0 of SOFTANZA_GUI_PLAN.md) ---------
    // x is the draw position and carries the mark x-offset, so it is NOT
    // the hit-test box. pen/adv are: the glyph occupies [pen, pen+adv).
    pen: f64, // pen position, px, before this glyph's offset
    adv: f64, // x-advance, px
    cl_end: u32, // BYTE index one past the cluster's last byte
    level: u8, // UAX#9 embedding level of the glyph's run; odd = RTL
};

pub const Layout = struct {
    glyphs: []Glyph,
    width: f64, // total advance, px
    run_count: usize, // visual runs (bidi witness: "abc عربي xyz" = 3)
    // --- vertical metrics, px (y grows DOWN from the baseline at 0) -----
    ascender: f64, // distance ABOVE the baseline, positive
    descender: f64, // distance BELOW the baseline, positive
    line_gap: f64,
    para_rtl: bool, // the paragraph's own base direction (UAX#9 base level)

    pub fn deinit(self: *const Layout) void {
        alloc.free(self.glyphs);
    }

    pub fn lineHeight(self: *const Layout) f64 {
        return self.ascender + self.descender + self.line_gap;
    }
};

var shape_buf: ?*c.hb_buffer_t = null; // reused; single-threaded contract

/// Shape ONE bidi run (a byte range of `utf8` with full-text context) and
/// append positioned glyphs, advancing the pen.
/// Fill cl_end for one run's glyphs. Within a run HarfBuzz clusters are
/// monotonic in LOGICAL order, so the byte a cluster ends at is the next
/// DISTINCT cluster value logically after it -- the next entry FORWARD in
/// an LTR run's array, and the next entry BACKWARD in an RTL one, because
/// RTL glyphs come out visually, i.e. logically reversed. The logically
/// last cluster ends at the run's end.
fn fillClusterEnds(slice: []Glyph, rtl: bool, run_end: u32) void {
    if (slice.len == 0) return;
    var next: u32 = run_end;
    if (!rtl) {
        var i: usize = slice.len;
        while (i > 0) {
            i -= 1;
            if (i + 1 < slice.len and slice[i].cluster != slice[i + 1].cluster) next = slice[i + 1].cluster;
            slice[i].cl_end = next;
        }
    } else {
        for (0..slice.len) |i| {
            if (i > 0 and slice[i].cluster != slice[i - 1].cluster) next = slice[i - 1].cluster;
            slice[i].cl_end = next;
        }
    }
}

fn shapeRun(font: *c.hb_font_t, utf8: []const u8, offset: usize, length: usize, level: u8, pen_x: *f64, out: *std.ArrayList(Glyph)) !void {
    const rtl = (level & 1) == 1;
    const first = out.items.len;
    if (shape_buf == null) shape_buf = c.hb_buffer_create();
    const buf = shape_buf.?;
    c.hb_buffer_reset(buf);
    // full text in, item window = this run: joining context crosses run edges
    c.hb_buffer_add_utf8(buf, utf8.ptr, @intCast(utf8.len), @intCast(offset), @intCast(length));
    c.hb_buffer_guess_segment_properties(buf); // script + language from content
    c.hb_buffer_set_direction(buf, if (rtl) c.HB_DIRECTION_RTL else c.HB_DIRECTION_LTR);
    c.hb_shape(font, buf, null, 0);

    var n: c_uint = 0;
    const infos = c.hb_buffer_get_glyph_infos(buf, &n);
    const poss = c.hb_buffer_get_glyph_positions(buf, &n);
    for (0..n) |i| {
        const info = infos[i];
        const pos = poss[i];
        const adv = @as(f64, @floatFromInt(pos.x_advance)) / 64.0;
        try out.append(alloc, .{
            .gid = info.codepoint, // post-shaping: a GLYPH id, not a codepoint
            .x = pen_x.* + @as(f64, @floatFromInt(pos.x_offset)) / 64.0,
            .y = @as(f64, @floatFromInt(pos.y_offset)) / 64.0,
            .cluster = info.cluster,
            .pen = pen_x.*,
            .adv = adv,
            .cl_end = 0, // filled below, once the whole run is known
            .level = level,
        });
        pen_x.* += adv;
    }
    fillClusterEnds(out.items[first..], rtl, @intCast(offset + length));
}

/// The pipeline entry: utf8 text + font + pixel size -> positioned glyph
/// ids in VISUAL order (SheenBidi's runs left to right, each run shaped by
/// HarfBuzz). Caller owns the returned Layout (deinit frees).
pub fn textLayout(font_id: i64, utf8: []const u8, size_px: f64) !Layout {
    const slot = slotOf(font_id) orelse return error.StaleFont;
    if (size_px <= 0 or utf8.len == 0) return error.BadArg;
    const s = &fonts.items[slot];

    // scale contract: size_px * 64 across the em (see file header)
    const hb_scale: c_int = @intFromFloat(@round(size_px * 64.0));
    c.hb_font_set_scale(s.font, hb_scale, hb_scale);

    var glyphs: std.ArrayList(Glyph) = .{};
    errdefer glyphs.deinit(alloc);
    var pen_x: f64 = 0;
    var run_count: usize = 0;

    // UAX#9: first paragraph, visual-order runs with levels
    var seq = c.SBCodepointSequence{
        .stringEncoding = c.SBStringEncodingUTF8,
        .stringBuffer = @constCast(@ptrCast(utf8.ptr)),
        .stringLength = @intCast(utf8.len),
    };
    const algorithm = c.SBAlgorithmCreate(&seq) orelse return error.BidiFailed;
    defer c.SBAlgorithmRelease(algorithm);
    const paragraph = c.SBAlgorithmCreateParagraph(algorithm, 0, @intCast(utf8.len), c.SBLevelDefaultLTR) orelse return error.BidiFailed;
    defer c.SBParagraphRelease(paragraph);
    const par_len = c.SBParagraphGetLength(paragraph);
    const line = c.SBParagraphCreateLine(paragraph, 0, par_len) orelse return error.BidiFailed;
    defer c.SBLineRelease(line);

    const n_runs = c.SBLineGetRunCount(line);
    const runs = c.SBLineGetRunsPtr(line);
    for (0..n_runs) |i| {
        const run = runs[i];
        if (run.length == 0) continue;
        run_count += 1;
        try shapeRun(s.font.?, utf8, @intCast(run.offset), @intCast(run.length), @intCast(run.level), &pen_x, &glyphs);
    }

    // Vertical metrics from the SAME scaled font the positions came from,
    // so a caret rect and the glyphs it sits among agree by construction.
    var ext: c.hb_font_extents_t = undefined;
    var asc: f64 = 0;
    var desc: f64 = 0;
    var gap: f64 = 0;
    if (c.hb_font_get_h_extents(s.font, &ext) != 0) {
        asc = @as(f64, @floatFromInt(ext.ascender)) / 64.0;
        desc = -@as(f64, @floatFromInt(ext.descender)) / 64.0; // hb reports it negative
        gap = @as(f64, @floatFromInt(ext.line_gap)) / 64.0;
    }

    return .{
        .glyphs = try glyphs.toOwnedSlice(alloc),
        .width = pen_x,
        .run_count = run_count,
        .ascender = asc,
        .descender = desc,
        .line_gap = gap,
        .para_rtl = (c.SBParagraphGetBaseLevel(paragraph) & 1) == 1,
    };
}

// ------------------------------------------------- reversibility (§0, GUI)
//
// Every platform IME -- Windows TSF (GetTextExt, GetACPFromPoint), macOS
// (firstRectForCharacterRange:, characterIndexForPoint:), Android, and the
// Web's EditContext -- demands the same two queries of a text layout:
//
//   1. the screen rect of a character range
//   2. the character index at a point, with a leading/trailing affinity bit
//
// If a layout cannot answer those, IME is not expensive: it is IMPOSSIBLE,
// and that is discovered late. They live here, beside the layout that owns
// the data, rather than being re-derived (differently, and wrongly) by each
// consumer. Coordinates: x from the text origin, y DOWN from the baseline
// at 0, so `top` is negative for the ascender.

pub const Rect = struct {
    x: f64,
    top: f64,
    w: f64,
    h: f64,
};

fn rectOver(self: *const Layout, x0: f64, x1: f64) Rect {
    return .{ .x = x0, .top = -self.ascender, .w = x1 - x0, .h = self.ascender + self.descender };
}

/// Every visual rect covering the LOGICAL byte range [start, end).
/// Bidi makes this a LIST and not a rect: one logical range can be several
/// disjoint visual spans (select across the seam of "abc عربي xyz" and the
/// selection is genuinely in two pieces). An EMPTY range selects nothing --
/// that is `caretRect`'s job, not this one's.
pub fn rectsForRange(self: *const Layout, start: u32, end: u32, out: *std.ArrayList(Rect)) !void {
    if (end <= start) return;
    var i: usize = 0;
    while (i < self.glyphs.len) {
        const g = self.glyphs[i];
        if (!(g.cluster < end and g.cl_end > start)) {
            i += 1;
            continue;
        }
        // a maximal VISUAL span of selected glyphs = one rect
        var x0 = g.pen;
        var x1 = g.pen + g.adv;
        i += 1;
        while (i < self.glyphs.len) : (i += 1) {
            const h = self.glyphs[i];
            if (!(h.cluster < end and h.cl_end > start)) break;
            x0 = @min(x0, h.pen);
            x1 = @max(x1, h.pen + h.adv);
        }
        try out.append(alloc, rectOver(self, x0, x1));
    }
}

pub const Hit = struct {
    index: u32, // the cluster's FIRST byte -- what the platform APIs return
    trailing: bool, // the caret belongs at the cluster's trailing edge
    caret: u32, // the resolved byte: trailing ? cl_end : cluster
};

/// The character at a point, with affinity. `x` is measured from the text
/// origin. Off either end clamps to the nearest glyph rather than refusing:
/// a click in the margin is a real click, and every platform resolves it.
pub fn indexAtPoint(self: *const Layout, x: f64) Hit {
    if (self.glyphs.len == 0) return .{ .index = 0, .trailing = false, .caret = 0 };
    var pick: usize = 0;
    for (self.glyphs, 0..) |g, i| {
        pick = i;
        if (x < g.pen + g.adv) break;
    }
    const g = self.glyphs[pick];
    // the visually-left half is the LEADING half of an LTR glyph and the
    // TRAILING half of an RTL one -- that asymmetry IS the affinity bit
    const left_half = x < g.pen + g.adv / 2.0;
    const rtl = (g.level & 1) == 1;
    const trailing = if (rtl) left_half else !left_half;
    return .{ .index = g.cluster, .trailing = trailing, .caret = if (trailing) g.cl_end else g.cluster };
}

/// The zero-width caret rect for `(index, trailing)` -- exactly the pair
/// `indexAtPoint` returns, so the round trip is closed and testable.
///
/// `trailing` is not decoration. At a bidi seam one byte offset has TWO
/// legitimate screen positions, and nothing in the text can choose between
/// them; the caller's affinity does. UAX#9 specifies reordering for DISPLAY
/// and says nothing about carets, so this is the implementation's call, and
/// the house makes it LOGICALLY (Blink left visual movement in Chrome M76
/// calling it "hacks with many bugs").
pub fn caretRect(self: *const Layout, index: u32, trailing: bool) Rect {
    if (self.glyphs.len == 0) return rectOver(self, 0, 0);
    var i: usize = 0;
    while (i < self.glyphs.len) : (i += 1) {
        const g = self.glyphs[i];
        if (!(g.cluster <= index and index < g.cl_end)) continue;
        // the whole cluster's visual extent (a cluster can be many glyphs)
        var x0 = g.pen;
        var x1 = g.pen + g.adv;
        var j = i + 1;
        while (j < self.glyphs.len and self.glyphs[j].cluster == g.cluster) : (j += 1) {
            x0 = @min(x0, self.glyphs[j].pen);
            x1 = @max(x1, self.glyphs[j].pen + self.glyphs[j].adv);
        }
        const rtl = (g.level & 1) == 1;
        const at = if (rtl) (if (trailing) x0 else x1) else (if (trailing) x1 else x0);
        return rectOver(self, at, at);
    }
    // past the last character: the paragraph's own direction decides which
    // END of the line the caret sits at
    const at: f64 = if (self.para_rtl) 0 else self.width;
    return rectOver(self, at, at);
}

// ---------------------------------------------------------------- glyph raster

pub const GlyphBitmap = struct {
    w: u32,
    h: u32,
    xoff: i32, // bitmap left relative to pen position
    yoff: i32, // bitmap TOP relative to baseline (stbtt convention: negative = above)
    gray: []u8, // w*h, 0..255 coverage

    pub fn deinit(self: *const GlyphBitmap) void {
        alloc.free(self.gray);
    }
};

/// Raster one glyph BY GLYPH ID at the given pixel size (em-mapped, the
/// same scale contract as layout). Whitespace glyphs yield w=h=0 -- a
/// valid, ink-free answer, not an error.
pub fn glyphBitmap(font_id: i64, gid: u32, size_px: f64) !GlyphBitmap {
    const slot = slotOf(font_id) orelse return error.StaleFont;
    if (size_px <= 0) return error.BadArg;
    const s = &fonts.items[slot];
    const scale = c.stbtt_ScaleForMappingEmToPixels(&s.stbtt, @floatCast(size_px));

    var x0: c_int = 0;
    var y0: c_int = 0;
    var x1: c_int = 0;
    var y1: c_int = 0;
    c.stbtt_GetGlyphBitmapBox(&s.stbtt, @intCast(gid), scale, scale, &x0, &y0, &x1, &y1);
    const w: u32 = @intCast(@max(0, x1 - x0));
    const h: u32 = @intCast(@max(0, y1 - y0));
    if (w == 0 or h == 0) return .{ .w = 0, .h = 0, .xoff = 0, .yoff = 0, .gray = &.{} };

    const gray = try alloc.alloc(u8, @as(usize, w) * h);
    c.stbtt_MakeGlyphBitmap(&s.stbtt, gray.ptr, @intCast(w), @intCast(h), @intCast(w), scale, scale, @intCast(gid));
    return .{ .w = w, .h = h, .xoff = x0, .yoff = y0, .gray = gray };
}

// ---------------------------------------------------------------- outlines
// The SVG tier's text (GR2b). Emitting glyph OUTLINES rather than <text>
// keeps the two backends honest: the SVG carries the exact positions this
// pipeline computed, and needs no font installed on the viewer's machine to
// look right. (A selectable-<text> emitter is a later knob, and it would
// hand shaping back to the consumer -- the thing this pipeline exists to
// own.) Font units are y-UP from the baseline; scene space is y-DOWN with
// the baseline at oy, so y_svg = oy - y_font * scale.

fn appendNum(out: *std.ArrayList(u8), v: f64) !void {
    var tmp: [32]u8 = undefined;
    var s = try std.fmt.bufPrint(&tmp, "{d:.2}", .{v});
    if (std.mem.indexOfScalar(u8, s, '.') != null) {
        var end = s.len;
        while (end > 0 and s[end - 1] == '0') end -= 1;
        if (end > 0 and s[end - 1] == '.') end -= 1;
        s = s[0..end];
    }
    try out.appendSlice(alloc, s);
}

/// Append this glyph's outline as SVG path data ("M.. L.. Q.. C.. Z"),
/// placed with its pen at (ox, oy) in scene pixels. An ink-free glyph
/// appends nothing and answers false.
pub fn glyphOutlineSvg(font_id: i64, gid: u32, size_px: f64, ox: f64, oy: f64, out: *std.ArrayList(u8)) !bool {
    const slot = slotOf(font_id) orelse return error.StaleFont;
    if (size_px <= 0) return error.BadArg;
    const s = &fonts.items[slot];
    const scale: f64 = @floatCast(c.stbtt_ScaleForMappingEmToPixels(&s.stbtt, @floatCast(size_px)));

    var verts: [*c]c.stbtt_vertex = undefined;
    const n = c.stbtt_GetGlyphShape(&s.stbtt, @intCast(gid), &verts);
    if (n <= 0) return false;
    defer c.stbtt_FreeShape(&s.stbtt, verts);

    var open = false;
    for (0..@intCast(n)) |i| {
        const v = verts[i];
        const px = ox + @as(f64, @floatFromInt(v.x)) * scale;
        const py = oy - @as(f64, @floatFromInt(v.y)) * scale;
        switch (v.type) {
            1 => { // move
                if (open) try out.appendSlice(alloc, "Z");
                try out.appendSlice(alloc, "M");
                try appendNum(out, px);
                try out.appendSlice(alloc, " ");
                try appendNum(out, py);
                open = true;
            },
            2 => { // line
                try out.appendSlice(alloc, "L");
                try appendNum(out, px);
                try out.appendSlice(alloc, " ");
                try appendNum(out, py);
            },
            3 => { // quadratic
                try out.appendSlice(alloc, "Q");
                try appendNum(out, ox + @as(f64, @floatFromInt(v.cx)) * scale);
                try out.appendSlice(alloc, " ");
                try appendNum(out, oy - @as(f64, @floatFromInt(v.cy)) * scale);
                try out.appendSlice(alloc, " ");
                try appendNum(out, px);
                try out.appendSlice(alloc, " ");
                try appendNum(out, py);
            },
            4 => { // cubic
                try out.appendSlice(alloc, "C");
                try appendNum(out, ox + @as(f64, @floatFromInt(v.cx)) * scale);
                try out.appendSlice(alloc, " ");
                try appendNum(out, oy - @as(f64, @floatFromInt(v.cy)) * scale);
                try out.appendSlice(alloc, " ");
                try appendNum(out, ox + @as(f64, @floatFromInt(v.cx1)) * scale);
                try out.appendSlice(alloc, " ");
                try appendNum(out, oy - @as(f64, @floatFromInt(v.cy1)) * scale);
                try out.appendSlice(alloc, " ");
                try appendNum(out, px);
                try out.appendSlice(alloc, " ");
                try appendNum(out, py);
            },
            else => {},
        }
    }
    if (open) try out.appendSlice(alloc, "Z");
    return open;
}

test {
    // table arithmetic only; the pipeline is guarded end-to-end through the
    // DLL (base/test/gpu/gpu_text_narrated.ring) with the committed fixture
    const id = makeId(2, 7);
    try std.testing.expectEqual(@as(i64, (7 << 32) | 3), id);
}
