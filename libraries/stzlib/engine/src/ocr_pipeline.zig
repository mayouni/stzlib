//! OCR PIPELINE -- an image file in, its text lines out, read by the three PP-OCR graphs that
//! ocr_graph.zig runs on ggml (the detector, the angle classifier, the recogniser). This is the
//! model implementation of the :ocr faculty; the platform engine stays its floor until the golden
//! set says otherwise.
//!
//! The steps and their constants are RapidOCR's (the reference the graphs were converted from,
//! rapidocr/config.yaml and its ch_ppocr_* modules), so that a difference in what is read is a
//! difference in this code and can be found:
//!
//!   1. the page is brought within 2000 px on its long side (and 30 px on its short one), each side a
//!      multiple of 32; a long thin strip is letterboxed (black above and below)
//!   2. the DETECTOR sees it with its short side raised to 736 (multiples of 32), normalised
//!      (x/255 - 0.5)/0.5, channels B, G, R; its map is thresholded at 0.3 and dilated 2x2
//!   3. each 8-connected region of the map is a candidate; kept when its short side is 3 or more and
//!      its mean probability 0.5 or more; it is grown by area * 1.6 / perimeter on every side (the
//!      DB "unclip") and scaled back to the page
//!   4. the boxes are sorted into reading order: by top, lines broken where the tops differ by 10 px
//!      or more, then left to right
//!   5. each box is cropped (a crop taller than 1.5 times its width is turned a quarter); the
//!      CLASSIFIER sees it at height 48 within 192 and VOTES: the page is turned over when most of its
//!      lines are called "180" above 0.9 (RapidOCR turns each line on its own vote -- see read());
//!      a recogniser whose script the classifier was not trained on skips it (stz.ocr.classifier=off)
//!   6. the RECOGNISER sees it at height 48, width at least 320, and its CTC output is decoded against
//!      the dictionary the converter carried in the GGUF (blank at 0, space last); a line whose mean
//!      confidence is under 0.5 is dropped
//!
//! What this code does NOT do that RapidOCR does, stated so a measurement can be read against it:
//!   - the angle classifier turns the PAGE on a majority vote, not each line on its own (measured, read())
//!   - boxes are AXIS-ALIGNED: a region's box is its bounding rectangle, where RapidOCR takes the
//!     minimum-area rotated rectangle of its contour. On an upright page the two agree; skewed text
//!     is boxed loosely and read from an unrotated crop
//!   - the recogniser reads ONE line at a time, where RapidOCR batches six of similar width and pads
//!     them to the widest; the zero padding differs, so a confidence can differ in its last digits
//!   - resizing is bilinear in floating point; OpenCV's is bilinear in 11-bit fixed point
//!
//! Every graph runs with the input shape of the moment (ocr_graph builds the graph per call), so a
//! page of any size and a line of any width are read without a fixed canvas.

const std = @import("std");
const graph = @import("ocr_graph.zig");
const c = graph.c;
const stbi = @cImport({
    @cInclude("stb_image.h");
});

const gpa = std.heap.c_allocator;

// RapidOCR's constants (config.yaml, Global / Det / Cls / Rec)
const MAX_SIDE: f64 = 2000;
const MIN_SIDE: f64 = 30;
const MIN_HEIGHT: f64 = 30;
const WIDTH_HEIGHT_RATIO: f64 = 8;
const DET_LIMIT: f64 = 736;
const DET_THRESH: f32 = 0.3;
const BOX_THRESH: f64 = 0.5;
const UNCLIP: f64 = 1.6;
const MIN_SIZE: f64 = 3;
const MAX_CANDIDATES: usize = 1000;
const LINE_DY: f64 = 10;
const CLS_H: usize = 48;
const CLS_W: usize = 192;
const CLS_THRESH: f32 = 0.9;
const REC_H: usize = 48;
const REC_W: usize = 320;
const TEXT_SCORE: f64 = 0.5;

// --------------------------------------------------------------------------------------------- images

/// An 8-bit RGB image, rows top to bottom, 3 bytes per pixel.
pub const Image = struct {
    w: usize,
    h: usize,
    px: []u8,

    pub fn free(im: *Image) void {
        gpa.free(im.px);
        im.px = &.{};
    }

    fn at(im: *const Image, x: usize, y: usize) [*]const u8 {
        return im.px.ptr + (y * im.w + x) * 3;
    }
};

fn newImage(w: usize, h: usize) !Image {
    const px = try gpa.alloc(u8, w * h * 3);
    @memset(px, 0);
    return .{ .w = w, .h = h, .px = px };
}

/// Decodes a PNG, JPEG or BMP file into RGB.
pub fn loadImage(path: []const u8) !Image {
    const f = std.fs.cwd().openFile(path, .{}) catch |e| {
        graph.setError("the image could not be opened: {s} ({s})", .{ path, @errorName(e) });
        return e;
    };
    defer f.close();
    const bytes = try f.readToEndAlloc(gpa, 512 << 20);
    defer gpa.free(bytes);
    var w: c_int = 0;
    var h: c_int = 0;
    var comp: c_int = 0;
    const p = stbi.stbi_load_from_memory(bytes.ptr, @intCast(bytes.len), &w, &h, &comp, 3) orelse {
        graph.setError("the image could not be decoded (PNG, JPEG or BMP): {s}", .{path});
        return error.BadImage;
    };
    defer stbi.stbi_image_free(p);
    const n: usize = @as(usize, @intCast(w)) * @as(usize, @intCast(h)) * 3;
    const px = try gpa.alloc(u8, n);
    @memcpy(px, p[0..n]);
    return .{ .w = @intCast(w), .h = @intCast(h), .px = px };
}

/// Bilinear resize with half-pixel centres (OpenCV's INTER_LINEAR geometry), rounded to 8 bits.
fn resize(src: *const Image, dw: usize, dh: usize) !Image {
    const dst = try newImage(dw, dh);
    const sx = @as(f64, @floatFromInt(src.w)) / @as(f64, @floatFromInt(dw));
    const sy = @as(f64, @floatFromInt(src.h)) / @as(f64, @floatFromInt(dh));
    const xs = try gpa.alloc(usize, dw * 2);
    defer gpa.free(xs);
    const xa = try gpa.alloc(f64, dw);
    defer gpa.free(xa);
    for (0..dw) |x| {
        const f = (@as(f64, @floatFromInt(x)) + 0.5) * sx - 0.5;
        var x0f = @floor(f);
        var a = f - x0f;
        if (x0f < 0) {
            x0f = 0;
            a = 0;
        }
        var x0: usize = @intFromFloat(x0f);
        if (x0 >= src.w - 1) {
            x0 = src.w - 1;
            a = 0;
        }
        xs[x * 2] = x0;
        xs[x * 2 + 1] = @min(x0 + 1, src.w - 1);
        xa[x] = a;
    }
    for (0..dh) |y| {
        const f = (@as(f64, @floatFromInt(y)) + 0.5) * sy - 0.5;
        var y0f = @floor(f);
        var b = f - y0f;
        if (y0f < 0) {
            y0f = 0;
            b = 0;
        }
        var y0: usize = @intFromFloat(y0f);
        if (y0 >= src.h - 1) {
            y0 = src.h - 1;
            b = 0;
        }
        const y1 = @min(y0 + 1, src.h - 1);
        for (0..dw) |x| {
            const a = xa[x];
            const p00 = src.at(xs[x * 2], y0);
            const p10 = src.at(xs[x * 2 + 1], y0);
            const p01 = src.at(xs[x * 2], y1);
            const p11 = src.at(xs[x * 2 + 1], y1);
            const o = dst.px.ptr + (y * dw + x) * 3;
            for (0..3) |k| {
                const top = @as(f64, @floatFromInt(p00[k])) * (1 - a) + @as(f64, @floatFromInt(p10[k])) * a;
                const bot = @as(f64, @floatFromInt(p01[k])) * (1 - a) + @as(f64, @floatFromInt(p11[k])) * a;
                const v = top * (1 - b) + bot * b;
                o[k] = @intFromFloat(@min(255.0, @max(0.0, @round(v))));
            }
        }
    }
    return dst;
}

fn round32(v: f64) usize {
    const r = @round(v / 32.0) * 32.0;
    return if (r < 32) 32 else @intFromFloat(r);
}

/// A rectangle of the image, rows and columns clamped at the border (OpenCV's BORDER_REPLICATE).
fn crop(src: *const Image, x0: i64, y0: i64, w: usize, h: usize) !Image {
    const dst = try newImage(w, h);
    for (0..h) |y| {
        const sy: usize = @intCast(std.math.clamp(y0 + @as(i64, @intCast(y)), 0, @as(i64, @intCast(src.h - 1))));
        for (0..w) |x| {
            const sx: usize = @intCast(std.math.clamp(x0 + @as(i64, @intCast(x)), 0, @as(i64, @intCast(src.w - 1))));
            const s = src.at(sx, sy);
            const o = dst.px.ptr + (y * w + x) * 3;
            o[0] = s[0];
            o[1] = s[1];
            o[2] = s[2];
        }
    }
    return dst;
}

/// A quarter turn counter-clockwise (numpy's rot90): the new row i is the old column w-1-i.
fn rot90(src: *const Image) !Image {
    const dst = try newImage(src.h, src.w);
    for (0..dst.h) |i| {
        for (0..dst.w) |j| {
            const s = src.at(src.w - 1 - i, j);
            const o = dst.px.ptr + (i * dst.w + j) * 3;
            o[0] = s[0];
            o[1] = s[1];
            o[2] = s[2];
        }
    }
    return dst;
}

fn rot180(im: *Image) void {
    const n = im.w * im.h;
    var i: usize = 0;
    while (i < n / 2) : (i += 1) {
        const a = im.px.ptr + i * 3;
        const b = im.px.ptr + (n - 1 - i) * 3;
        for (0..3) |k| std.mem.swap(u8, &a[k], &b[k]);
    }
}

/// The network's input: [1, 3, H, W] in channels B, G, R, each (x/255 - 0.5)/0.5; columns beyond the
/// image's width stay 0 (the padding RapidOCR leaves for the classifier and the recogniser).
fn tensorOf(im: *const Image, w_total: usize) ![]f32 {
    const plane = im.h * w_total;
    const t = try gpa.alloc(f32, plane * 3);
    @memset(t, 0);
    for (0..im.h) |y| {
        for (0..im.w) |x| {
            const s = im.at(x, y);
            const i = y * w_total + x;
            t[i] = (@as(f32, @floatFromInt(s[2])) / 255.0 - 0.5) / 0.5; // B
            t[plane + i] = (@as(f32, @floatFromInt(s[1])) / 255.0 - 0.5) / 0.5; // G
            t[2 * plane + i] = (@as(f32, @floatFromInt(s[0])) / 255.0 - 0.5) / 0.5; // R
        }
    }
    return t;
}

// --------------------------------------------------------------------------------------------- the models

// a recogniser and its dictionary (the CTC classes in output order, carried in its GGUF by the converter)
const Rec = struct { name: []const u8, model: *graph.Model, chars: [][]const u8, rtl: bool, use_cls: bool };

const Models = struct {
    dir: []u8,
    det: *graph.Model,
    cls: *graph.Model,
    recs: [8]Rec,
    n_recs: usize,
    arena: std.heap.ArenaAllocator,
};

// the graphs stay loaded for the process (a golden set reads many pages); the detector and the classifier are
// shared, a recogniser is loaded the first time a page asks for it (one per script); a new folder replaces them
var cached: ?Models = null;

fn models(dir: []const u8) !*Models {
    if (cached) |*m| {
        if (std.mem.eql(u8, m.dir, dir)) return m;
        m.det.free();
        m.cls.free();
        for (m.recs[0..m.n_recs]) |r| r.model.free();
        m.arena.deinit();
        gpa.free(m.dir);
        cached = null;
    }
    var arena = std.heap.ArenaAllocator.init(gpa);
    errdefer arena.deinit();
    const a = arena.allocator();
    const det = try graph.load(try std.fs.path.join(a, &.{ dir, "ppocr_det.gguf" }));
    errdefer det.free();
    const cls = try graph.load(try std.fs.path.join(a, &.{ dir, "ppocr_cls.gguf" }));
    cached = .{ .dir = try gpa.dupe(u8, dir), .det = det, .cls = cls, .recs = undefined, .n_recs = 0, .arena = arena };
    return &cached.?;
}

/// The recogniser named `file` in the models folder ("" = ppocr_rec.gguf, the Latin/CJK one), loaded once.
fn recognizer(m: *Models, file: []const u8) !*Rec {
    const name = if (file.len == 0) "ppocr_rec.gguf" else file;
    for (m.recs[0..m.n_recs]) |*r| {
        if (std.mem.eql(u8, r.name, name)) return r;
    }
    if (m.n_recs == m.recs.len) {
        graph.setError("more than {d} recognisers asked for in one process", .{m.recs.len});
        return error.TooManyRecognisers;
    }
    const a = m.arena.allocator();
    const rec = try graph.load(try std.fs.path.join(a, &.{ m.dir, name }));
    errdefer rec.free();
    const kid = c.gguf_find_key(rec.gguf, "stz.ocr.character");
    if (kid < 0) {
        graph.setError("the recogniser {s} carries no dictionary (stz.ocr.character): re-convert it with tools/onnx_to_gguf.py", .{name});
        return error.NoDictionary;
    }
    const n: usize = @intCast(c.gguf_get_arr_n(rec.gguf, kid));
    const chars = try a.alloc([]const u8, n);
    for (0..n) |i| chars[i] = try a.dupe(u8, std.mem.span(c.gguf_get_arr_str(rec.gguf, kid, i)));
    const did = c.gguf_find_key(rec.gguf, "stz.ocr.direction");
    const rtl = did >= 0 and std.mem.eql(u8, std.mem.span(c.gguf_get_val_str(rec.gguf, did)), "rtl");
    // a recogniser may say the angle classifier does not apply to its script (stz.ocr.classifier = "off")
    const kcl = c.gguf_find_key(rec.gguf, "stz.ocr.classifier");
    const use_cls = !(kcl >= 0 and std.mem.eql(u8, std.mem.span(c.gguf_get_val_str(rec.gguf, kcl)), "off"));
    m.recs[m.n_recs] = .{ .name = try a.dupe(u8, name), .model = rec, .chars = chars, .rtl = rtl, .use_cls = use_cls };
    m.n_recs += 1;
    return &m.recs[m.n_recs - 1];
}

// --------------------------------------------------------------------------------------------- detection

const Box = struct { x0: f64, y0: f64, x1: f64, y1: f64, score: f64 };
const Keyed = struct { line: usize, b: Box };

/// The detector's probability map turned into boxes in the coordinates of an image dw x dh.
fn boxesOf(alloc: std.mem.Allocator, pred: []const f32, mw: usize, mh: usize, dw: usize, dh: usize, rtl: bool) ![]Box {
    const n = mw * mh;
    const bit = try alloc.alloc(u8, n);
    for (0..n) |i| bit[i] = @intFromBool(pred[i] > DET_THRESH);
    // the 2x2 dilation (anchor at its centre: each pixel takes the max of itself, its left, its top, its top-left)
    const mask = try alloc.alloc(u8, n);
    for (0..mh) |y| {
        for (0..mw) |x| {
            var v = bit[y * mw + x];
            if (x > 0) v |= bit[y * mw + x - 1];
            if (y > 0) {
                v |= bit[(y - 1) * mw + x];
                if (x > 0) v |= bit[(y - 1) * mw + x - 1];
            }
            mask[y * mw + x] = v;
        }
    }
    // 8-connected regions, each with its bounding rectangle
    const seen = try alloc.alloc(u8, n);
    @memset(seen, 0);
    var stack: std.ArrayList(u32) = .empty;
    var out: std.ArrayList(Box) = .empty;
    const fw: f64 = @floatFromInt(mw);
    const fh: f64 = @floatFromInt(mh);
    const fdw: f64 = @floatFromInt(dw);
    const fdh: f64 = @floatFromInt(dh);
    var regions: usize = 0;
    for (0..n) |start| {
        if (mask[start] == 0 or seen[start] != 0) continue;
        if (regions >= MAX_CANDIDATES) break;
        regions += 1;
        var x0: usize = start % mw;
        var x1 = x0;
        var y0: usize = start / mw;
        var y1 = y0;
        seen[start] = 1;
        try stack.append(alloc, @intCast(start));
        while (stack.pop()) |p32| {
            const p: usize = p32;
            const px = p % mw;
            const py = p / mw;
            x0 = @min(x0, px);
            x1 = @max(x1, px);
            y0 = @min(y0, py);
            y1 = @max(y1, py);
            const ylo = if (py > 0) py - 1 else py;
            const yhi = @min(py + 1, mh - 1);
            const xlo = if (px > 0) px - 1 else px;
            const xhi = @min(px + 1, mw - 1);
            var yy = ylo;
            while (yy <= yhi) : (yy += 1) {
                var xx = xlo;
                while (xx <= xhi) : (xx += 1) {
                    const q = yy * mw + xx;
                    if (mask[q] != 0 and seen[q] == 0) {
                        seen[q] = 1;
                        try stack.append(alloc, @intCast(q));
                    }
                }
            }
        }
        const w: f64 = @floatFromInt(x1 - x0);
        const h: f64 = @floatFromInt(y1 - y0);
        if (@min(w, h) < MIN_SIZE) continue;
        // the mean probability over the rectangle (box_score_fast)
        var sum: f64 = 0;
        for (y0..y1 + 1) |yy| {
            for (x0..x1 + 1) |xx| sum += pred[yy * mw + xx];
        }
        const score = sum / @as(f64, @floatFromInt((x1 - x0 + 1) * (y1 - y0 + 1)));
        if (score < BOX_THRESH) continue;
        // the unclip: every side moves out by area * ratio / perimeter
        const d = w * h * UNCLIP / (2 * (w + h));
        if (@min(w, h) + 2 * d < MIN_SIZE + 2) continue;
        var b = Box{
            .x0 = std.math.clamp(@round((@as(f64, @floatFromInt(x0)) - d) / fw * fdw), 0, fdw),
            .y0 = std.math.clamp(@round((@as(f64, @floatFromInt(y0)) - d) / fh * fdh), 0, fdh),
            .x1 = std.math.clamp(@round((@as(f64, @floatFromInt(x1)) + d) / fw * fdw), 0, fdw),
            .y1 = std.math.clamp(@round((@as(f64, @floatFromInt(y1)) + d) / fh * fdh), 0, fdh),
            .score = score,
        };
        // filter_det_res: clipped to the last pixel, and dropped when 3 px or less on a side
        b.x0 = @min(b.x0, fdw - 1);
        b.x1 = @min(b.x1, fdw - 1);
        b.y0 = @min(b.y0, fdh - 1);
        b.y1 = @min(b.y1, fdh - 1);
        if (@trunc(b.x1 - b.x0) <= 3 or @trunc(b.y1 - b.y0) <= 3) continue;
        try out.append(alloc, b);
    }
    // reading order: by top (stable), a new line where consecutive tops differ by 10 or more, then by left
    const boxes = try out.toOwnedSlice(alloc);
    std.sort.insertion(Box, boxes, {}, struct {
        fn lt(_: void, a: Box, b: Box) bool {
            return a.y0 < b.y0;
        }
    }.lt);
    const keyed = try alloc.alloc(Keyed, boxes.len);
    var line: usize = 0;
    for (boxes, 0..) |b, i| {
        if (i > 0 and b.y0 - boxes[i - 1].y0 >= LINE_DY) line += 1;
        keyed[i] = .{ .line = line, .b = b };
    }
    // within a line, left to right -- or right to left when the script is (the right edge leads)
    if (rtl) {
        std.sort.insertion(Keyed, keyed, {}, struct {
            fn lt(_: void, a: Keyed, b: Keyed) bool {
                if (a.line != b.line) return a.line < b.line;
                return a.b.x1 > b.b.x1;
            }
        }.lt);
    } else {
        std.sort.insertion(Keyed, keyed, {}, struct {
            fn lt(_: void, a: Keyed, b: Keyed) bool {
                if (a.line != b.line) return a.line < b.line;
                return a.b.x0 < b.b.x0;
            }
        }.lt);
    }
    for (keyed, 0..) |k, i| boxes[i] = k.b;
    return boxes;
}

// --------------------------------------------------------------------------------------------- direction

const Dir = enum { l, r, n };

// the class of a codepoint for putting a visual right-to-left line back in logical order: L for what is laid out
// left to right inside it (Latin letters, European and Arabic-Indic digits), R for the right-to-left letters
// (Hebrew, Arabic, Syriac, Thaana, N'Ko and their presentation forms), N for the rest (spaces, punctuation)
fn dirOf(cp: u21) Dir {
    if ((cp >= '0' and cp <= '9') or (cp >= 'A' and cp <= 'Z') or (cp >= 'a' and cp <= 'z')) return .l;
    if (cp >= 0x0660 and cp <= 0x0669) return .l; // Arabic-Indic digits are laid out left to right
    if (cp >= 0x06F0 and cp <= 0x06F9) return .l;
    if (cp >= 0x00C0 and cp <= 0x024F and cp != 0x00D7 and cp != 0x00F7) return .l;
    if (cp >= 0x0590 and cp <= 0x08FF) return .r;
    if (cp >= 0xFB1D and cp <= 0xFDFF) return .r;
    if (cp >= 0xFE70 and cp <= 0xFEFF) return .r;
    if (cp >= 0x0370 and cp <= 0x058F) return .l; // Greek, Cyrillic, Armenian
    return .n;
}

/// A line the recogniser read in VISUAL order (its pixels left to right) put back in LOGICAL order, the paragraph
/// being right to left: the runs are taken in reverse, a right-to-left run is reversed codepoint by codepoint and a
/// left-to-right run (a number, a Latin word) is kept as it is. A neutral (a space, a comma) between two
/// left-to-right characters belongs to their run ("20,000", "HP 2026"); any other neutral is right to left.
/// This is the inverse of the bidi algorithm's reordering for the two cases a recogniser's line holds; it is not
/// the whole of UAX #9 (no embedding, no mirroring).
fn logicalOrder(a: std.mem.Allocator, text: *std.ArrayList(u8)) !void {
    var cps: std.ArrayList(u21) = .empty;
    var view = std.unicode.Utf8View.init(text.items) catch return; // not UTF-8: left as it is
    var it = view.iterator();
    while (it.nextCodepoint()) |cp| try cps.append(a, cp);
    const n = cps.items.len;
    if (n == 0) return;
    const dirs = try a.alloc(Dir, n);
    for (cps.items, 0..) |cp, i| dirs[i] = dirOf(cp);
    // resolve the neutrals: L only when the strong characters on both sides are L
    var i: usize = 0;
    while (i < n) {
        if (dirs[i] != .n) {
            i += 1;
            continue;
        }
        var j = i;
        while (j < n and dirs[j] == .n) j += 1;
        const before: Dir = if (i > 0) dirs[i - 1] else .r;
        const after: Dir = if (j < n) dirs[j] else .r;
        const d: Dir = if (before == .l and after == .l) .l else .r;
        for (i..j) |k| dirs[k] = d;
        i = j;
    }
    // the runs, last first
    var out: std.ArrayList(u8) = .empty;
    var buf: [4]u8 = undefined;
    var end = n;
    while (end > 0) {
        var start = end - 1;
        while (start > 0 and dirs[start - 1] == dirs[end - 1]) start -= 1;
        if (dirs[end - 1] == .l) {
            for (start..end) |k| {
                const len = try std.unicode.utf8Encode(cps.items[k], &buf);
                try out.appendSlice(a, buf[0..len]);
            }
        } else {
            var k = end;
            while (k > start) {
                k -= 1;
                const len = try std.unicode.utf8Encode(cps.items[k], &buf);
                try out.appendSlice(a, buf[0..len]);
            }
        }
        end = start;
    }
    text.clearRetainingCapacity();
    try text.appendSlice(a, out.items);
}

// --------------------------------------------------------------------------------------------- reading

pub const Line = struct { text: []const u8, score: f64, x0: f64, y0: f64, x1: f64, y1: f64, flipped: bool };

pub const Result = struct {
    arena: std.heap.ArenaAllocator,
    lines: []Line,
    boxes: usize, // regions the detector kept (lines dropped for low confidence included)
    votes_180: usize, // lines the angle classifier called upside down (the page turns over only on a majority)
    ms_det: f64,
    ms_cls: f64,
    ms_rec: f64,
    ms_total: f64,

    pub fn free(r: *Result) void {
        r.arena.deinit();
    }
};

fn ms(t0: i128) f64 {
    return @as(f64, @floatFromInt(std.time.nanoTimestamp() - t0)) / 1e6;
}

/// Reads the text lines of one image file with the graphs in models_dir: ppocr_det.gguf, ppocr_cls.gguf and the
/// recogniser `rec_file` ("" = ppocr_rec.gguf).
pub fn read(models_dir: []const u8, rec_file: []const u8, image_path: []const u8, n_threads: c_int) !Result {
    const t_all = std.time.nanoTimestamp();
    graph.clearError();
    const m = try models(models_dir);
    const rc = try recognizer(m, rec_file);
    var res = Result{ .arena = std.heap.ArenaAllocator.init(gpa), .lines = &.{}, .boxes = 0, .votes_180 = 0, .ms_det = 0, .ms_cls = 0, .ms_rec = 0, .ms_total = 0 };
    errdefer res.arena.deinit();
    const a = res.arena.allocator();

    var orig = try loadImage(image_path);
    defer orig.free();

    // 1. within 2000 px (and at least 30) -- each a multiple of 32 only when a resize happens
    var page = try newImage(1, 1);
    defer page.free();
    var ratio_w: f64 = 1;
    var ratio_h: f64 = 1;
    {
        var cur = try crop(&orig, 0, 0, orig.w, orig.h);
        const fw: f64 = @floatFromInt(cur.w);
        const fh: f64 = @floatFromInt(cur.h);
        if (@max(fw, fh) > MAX_SIDE) {
            const r = MAX_SIDE / @max(fw, fh);
            const nw = round32(@trunc(fw * r));
            const nh = round32(@trunc(fh * r));
            const nx = try resize(&cur, nw, nh);
            cur.free();
            cur = nx;
            ratio_w = fw / @as(f64, @floatFromInt(nw));
            ratio_h = fh / @as(f64, @floatFromInt(nh));
        }
        const gw: f64 = @floatFromInt(cur.w);
        const gh: f64 = @floatFromInt(cur.h);
        if (@min(gw, gh) < MIN_SIDE) {
            const r = MIN_SIDE / @min(gw, gh);
            const nw = round32(@trunc(gw * r));
            const nh = round32(@trunc(gh * r));
            const nx = try resize(&cur, nw, nh);
            cur.free();
            cur = nx;
            ratio_w = @as(f64, @floatFromInt(orig.w)) / @as(f64, @floatFromInt(nw));
            ratio_h = @as(f64, @floatFromInt(orig.h)) / @as(f64, @floatFromInt(nh));
        }
        page.free();
        page = cur;
    }
    // the letterbox of a thin strip
    var pad_top: usize = 0;
    {
        const fw: f64 = @floatFromInt(page.w);
        const fh: f64 = @floatFromInt(page.h);
        if (fh <= MIN_HEIGHT or fw / fh > WIDTH_HEIGHT_RATIO) {
            const new_h = @max(@trunc(fw / WIDTH_HEIGHT_RATIO), MIN_HEIGHT) * 2;
            pad_top = @intFromFloat(@trunc(@abs(new_h - fh) / 2));
            var lb = try newImage(page.w, page.h + 2 * pad_top);
            @memcpy(lb.px[pad_top * page.w * 3 ..][0 .. page.px.len], page.px);
            page.free();
            page = lb;
        }
    }

    // 2. the detector
    const t_det = std.time.nanoTimestamp();
    var boxes: []Box = &.{};
    {
        const fw: f64 = @floatFromInt(page.w);
        const fh: f64 = @floatFromInt(page.h);
        var r: f64 = 1;
        if (@min(fw, fh) < DET_LIMIT) r = DET_LIMIT / @min(fw, fh);
        const dw = round32(@trunc(fw * r));
        const dh = round32(@trunc(fh * r));
        var din = try resize(&page, dw, dh);
        defer din.free();
        const t = try tensorOf(&din, dw);
        defer gpa.free(t);
        const o = try graph.run(m.det, t, .{ 1, 3, @intCast(dh), @intCast(dw) }, n_threads);
        defer gpa.free(o.data);
        // the map is [1, 1, H, W]: ggml ne = [W, H, 1, 1]
        const mw: usize = @intCast(o.ne[0]);
        const mh: usize = @intCast(o.ne[1]);
        boxes = try boxesOf(a, o.data, mw, mh, page.w, page.h, rc.rtl);
    }
    res.ms_det = ms(t_det);
    res.boxes = boxes.len;

    var lines: std.ArrayList(Line) = .empty;
    var text: std.ArrayList(u8) = .empty;
    // 5. the classifier VOTES, and the page is turned over only when most of its lines vote "180". RapidOCR turns
    // each line over on its own vote; measured on five upright golden pages (z09 fr, u06 ru), that turned 13 lines
    // over and none rightly -- a long line squeezed into 192 px is near chance for this classifier -- and a turned
    // line is read as noise. A whole page scanned upside down still turns over; a single upside-down line on an
    // upright page does not (no golden has one).
    var page_flip = false;
    if (rc.use_cls and boxes.len > 0) {
        const t_cls = std.time.nanoTimestamp();
        var votes: usize = 0;
        var voters: usize = 0;
        for (boxes) |b| {
            const cw: usize = @intFromFloat(@trunc(b.x1 - b.x0));
            const ch: usize = @intFromFloat(@trunc(b.y1 - b.y0));
            if (cw == 0 or ch == 0) continue;
            var im = try crop(&page, @intFromFloat(b.x0), @intFromFloat(b.y0), cw, ch);
            defer im.free();
            if (@as(f64, @floatFromInt(im.h)) / @as(f64, @floatFromInt(im.w)) >= 1.5) {
                const r = try rot90(&im);
                im.free();
                im = r;
            }
            const ratio = @as(f64, @floatFromInt(im.w)) / @as(f64, @floatFromInt(im.h));
            const rw: usize = @min(CLS_W, @as(usize, @intFromFloat(@ceil(@as(f64, CLS_H) * ratio))));
            var ci = try resize(&im, @max(rw, 1), CLS_H);
            defer ci.free();
            const t = try tensorOf(&ci, CLS_W);
            defer gpa.free(t);
            const o = try graph.run(m.cls, t, .{ 1, 3, CLS_H, CLS_W }, n_threads);
            defer gpa.free(o.data);
            voters += 1;
            if (o.data.len >= 2 and o.data[1] > o.data[0] and o.data[1] > CLS_THRESH) votes += 1;
        }
        page_flip = votes * 2 > voters;
        res.votes_180 = votes;
        res.ms_cls = ms(t_cls);
    }

    for (boxes) |b| {
        // 6. the crop, the quarter turn of a tall one, the page's turn if it voted for one
        const cw: usize = @intFromFloat(@trunc(b.x1 - b.x0));
        const ch: usize = @intFromFloat(@trunc(b.y1 - b.y0));
        if (cw == 0 or ch == 0) continue;
        var im = try crop(&page, @intFromFloat(b.x0), @intFromFloat(b.y0), cw, ch);
        defer im.free();
        if (@as(f64, @floatFromInt(im.h)) / @as(f64, @floatFromInt(im.w)) >= 1.5) {
            const r = try rot90(&im);
            im.free();
            im = r;
        }
        const ratio = @as(f64, @floatFromInt(im.w)) / @as(f64, @floatFromInt(im.h));
        var flipped = false;
        if (page_flip) {
            rot180(&im);
            flipped = true;
        }
        // 7. the recogniser and the CTC decode
        const t_rec = std.time.nanoTimestamp();
        const max_ratio = @max(@as(f64, REC_W) / @as(f64, REC_H), ratio);
        const tw: usize = @intFromFloat(@trunc(@as(f64, REC_H) * max_ratio));
        const rw: usize = @min(tw, @as(usize, @intFromFloat(@ceil(@as(f64, REC_H) * ratio))));
        var ri = try resize(&im, @max(rw, 1), REC_H);
        defer ri.free();
        const t = try tensorOf(&ri, tw);
        defer gpa.free(t);
        const o = try graph.run(rc.model, t, .{ 1, 3, REC_H, @intCast(tw) }, n_threads);
        defer gpa.free(o.data);
        // [1, T, C]: ggml ne = [C, T, 1]
        const nc: usize = @intCast(o.ne[0]);
        const nt: usize = @intCast(o.ne[1]);
        text.clearRetainingCapacity();
        var conf_sum: f64 = 0;
        var conf_n: usize = 0;
        var prev: usize = std.math.maxInt(usize);
        for (0..nt) |ti| {
            const row = o.data[ti * nc ..][0..nc];
            var best: usize = 0;
            for (row, 0..) |v, k| {
                if (v > row[best]) best = k;
            }
            if (best != 0 and best != prev) {
                if (best < rc.chars.len) try text.appendSlice(a, rc.chars[best]);
                conf_sum += row[best];
                conf_n += 1;
            }
            prev = best;
        }
        res.ms_rec += ms(t_rec);
        const score = if (conf_n == 0) 0 else conf_sum / @as(f64, @floatFromInt(conf_n));
        if (rc.rtl) try logicalOrder(a, &text);
        // STZ_OCR_LINES=1 prints every box the detector kept, the dropped lines too (stderr): box, confidence, text
        if (std.process.hasNonEmptyEnvVarConstant("STZ_OCR_LINES"))
            std.debug.print("[ocr line] {d:.0},{d:.0},{d:.0},{d:.0} {d:.2}{s} {s}\n", .{ b.x0, b.y0, b.x1, b.y1, score, if (score < TEXT_SCORE) " DROPPED" else "", text.items });
        if (score < TEXT_SCORE) continue;
        // back to the coordinates of the file: the letterbox removed, the resize undone
        const pt: f64 = @floatFromInt(pad_top);
        const ow: f64 = @floatFromInt(orig.w);
        const oh: f64 = @floatFromInt(orig.h);
        try lines.append(a, .{
            .text = try a.dupe(u8, text.items),
            .score = score,
            .x0 = std.math.clamp(b.x0 * ratio_w, 0, ow),
            .y0 = std.math.clamp((b.y0 - pt) * ratio_h, 0, oh),
            .x1 = std.math.clamp(b.x1 * ratio_w, 0, ow),
            .y1 = std.math.clamp((b.y1 - pt) * ratio_h, 0, oh),
            .flipped = flipped,
        });
    }
    res.lines = try lines.toOwnedSlice(a);
    res.ms_total = ms(t_all);
    return res;
}

// --------------------------------------------------------------------------------------------- page marks (O4)

// What a scanned page shows besides its letters, recovered from its pixels, in the shapes the PDF reader takes
// from a born-digital page's vector paths (pdf.zig Interp): a RULE (a thin stroke: table borders, separators), a
// DOT (a small filled shape: a list bullet) and a FILL (a shaded rectangle: a code block, a table header). And
// per OCR line, the width of its strokes, the cue for bold. Thresholds are the reader's, in pixels at the page's
// own resolution: `ppt` pixels per point.

pub const Mark = struct { kind: u8, x0: f32, y0: f32, x1: f32, y1: f32 }; // kind 'r' rule, 'd' dot, 'f' fill

pub const Marks = struct {
    arena: std.heap.ArenaAllocator,
    marks: []Mark,
    strokes: []f32, // per box given: the median width of its dark strokes, in pixels (0 when none)

    pub fn free(r: *Marks) void {
        r.arena.deinit();
    }
};

// The thresholds are set from the PAPER, the page's commonest light grey (255 on a rendered page, lower on a real
// scan): shading is anything 6 levels below it, a rule's ink 30 below (a table's light grey separators, 160-195 on
// golden_v36/z09), a dot's ink 80 below (a grey bullet, 141 there), and a letter's stroke for the bold cue at 128 or
// 100 below the paper, whichever is darker.
const Levels = struct { tint: u8, line: u8, ink: u8, stroke: u8 };

fn levelsOf(gray: []const u8) Levels {
    var hist = [_]usize{0} ** 256;
    for (gray) |v| hist[v] += 1;
    var paper: usize = 255;
    var best: usize = 0;
    for (128..256) |v| {
        if (hist[v] > best) {
            best = hist[v];
            paper = v;
        }
    }
    return .{
        .tint = @intCast(paper -| 6),
        .line = @intCast(paper -| 30),
        .ink = @intCast(paper -| 80),
        .stroke = @intCast(@min(128, paper -| 100)),
    };
}

fn inRects(rects: []const Mark, x: f32, y: f32) bool {
    for (rects) |r| {
        if (x >= r.x0 and x <= r.x1 and y >= r.y0 and y <= r.y1) return true;
    }
    return false;
}

fn inBox(boxes: []const [4]f32, x: f32, y: f32, pad: f32) bool {
    for (boxes) |b| {
        if (x >= b[0] - pad and x <= b[2] + pad and y >= b[1] - pad and y <= b[3] + pad) return true;
    }
    return false;
}

const Seg = struct { s: usize, e: usize, first: usize, last: usize };

/// Runs of `on` pixels at least `min_len` long along one axis, merged across neighbouring lines into segments;
/// a segment at most `max_thick` lines thick is a rule. `horizontal` scans rows, otherwise columns.
fn rulesAlong(a: std.mem.Allocator, gray: []const u8, w: usize, h: usize, horizontal: bool, min_len: usize, max_thick: usize, out: *std.ArrayList(Mark), boxes: []const [4]f32, line: u8, fills: []const Mark) !void {
    const n_lines = if (horizontal) h else w;
    const n_along = if (horizontal) w else h;
    var open: std.ArrayList(Seg) = .empty;
    var next: std.ArrayList(Seg) = .empty;
    for (0..n_lines + 1) |li| {
        next.clearRetainingCapacity();
        if (li < n_lines) {
            var k: usize = 0;
            while (k < n_along) {
                const px = if (horizontal) gray[li * w + k] else gray[k * w + li];
                if (px >= line) {
                    k += 1;
                    continue;
                }
                const s = k;
                while (k < n_along and (if (horizontal) gray[li * w + k] else gray[k * w + li]) < line) k += 1;
                if (k - s < min_len) continue;
                // continue an open segment of the line before when the spans agree within 3 px
                var joined = false;
                for (open.items) |*o| {
                    if (o.last == std.math.maxInt(usize)) continue; // already continued by another run
                    if (o.last + 1 == li and absDiff(o.s, s) <= 3 and absDiff(o.e, k) <= 3) {
                        try next.append(a, .{ .s = @min(o.s, s), .e = @max(o.e, k), .first = o.first, .last = li });
                        o.last = std.math.maxInt(usize); // taken
                        joined = true;
                        break;
                    }
                }
                if (!joined) try next.append(a, .{ .s = s, .e = k, .first = li, .last = li });
            }
        }
        // the segments not continued are finished
        for (open.items) |o| {
            if (o.last == std.math.maxInt(usize)) continue;
            const thick = o.last - o.first + 1;
            if (thick > max_thick) continue;
            const m: Mark = if (horizontal)
                .{ .kind = 'r', .x0 = @floatFromInt(o.s), .x1 = @floatFromInt(o.e), .y0 = @floatFromInt(o.first), .y1 = @floatFromInt(o.last + 1) }
            else
                .{ .kind = 'r', .x0 = @floatFromInt(o.first), .x1 = @floatFromInt(o.last + 1), .y0 = @floatFromInt(o.s), .y1 = @floatFromInt(o.e) };
            // a stroke inside a line of text is a letter's, and one inside a shading is the edge of its letters
            if (inBox(boxes, (m.x0 + m.x1) / 2, (m.y0 + m.y1) / 2, 0)) continue;
            if (inRects(fills, (m.x0 + m.x1) / 2, (m.y0 + m.y1) / 2)) continue;
            // a rule is a dark line with PAPER on both sides: 3 px beyond it, on each side, at least 80% of its
            // length is light. The edge of a dark area (a photographed page's shadow, a stamp, a picture) has a
            // dark side and is no rule: on a real phone scan, 113 such "rules" had a median contrast with their
            // sides of 4 grey levels (vertical) and -16 (horizontal)
            if (!flankedByPaper(gray, w, h, horizontal, o, line)) continue;
            try out.append(a, m);
        }
        open.clearRetainingCapacity();
        try open.appendSlice(a, next.items);
    }
}

fn flankedByPaper(gray: []const u8, w: usize, h: usize, horizontal: bool, o: Seg, line: u8) bool {
    const n_lines = if (horizontal) h else w;
    if (o.first < 3 or o.last + 3 >= n_lines) return false; // at the image's edge: nothing to see on one side
    const before = o.first - 3;
    const after = o.last + 3;
    const len = o.e - o.s;
    const step = @max(1, len / 40);
    var n: usize = 0;
    var ok: usize = 0;
    var k = o.s;
    while (k < o.e) : (k += step) {
        const pb = if (horizontal) gray[before * w + k] else gray[k * w + before];
        const pa = if (horizontal) gray[after * w + k] else gray[k * w + after];
        n += 1;
        if (pb >= line and pa >= line) ok += 1;
    }
    return n > 0 and ok * 10 >= n * 8;
}

fn absDiff(x: usize, y: usize) usize {
    return if (x > y) x - y else y - x;
}

const Comp = struct { x0: usize, y0: usize, x1: usize, y1: usize, n: usize };

/// The 8-connected components of the pixels below `below`.
fn components(a: std.mem.Allocator, gray: []const u8, w: usize, h: usize, below: u8) ![]Comp {
    const seen = try a.alloc(u8, w * h);
    @memset(seen, 0);
    var stack: std.ArrayList(u32) = .empty;
    var out: std.ArrayList(Comp) = .empty;
    for (0..w * h) |start| {
        if (gray[start] >= below or seen[start] != 0) continue;
        var cm = Comp{ .x0 = start % w, .y0 = start / w, .x1 = start % w, .y1 = start / w, .n = 0 };
        seen[start] = 1;
        try stack.append(a, @intCast(start));
        while (stack.pop()) |p32| {
            const p: usize = p32;
            const px = p % w;
            const py = p / w;
            cm.n += 1;
            cm.x0 = @min(cm.x0, px);
            cm.x1 = @max(cm.x1, px);
            cm.y0 = @min(cm.y0, py);
            cm.y1 = @max(cm.y1, py);
            const ylo = if (py > 0) py - 1 else py;
            const yhi = @min(py + 1, h - 1);
            const xlo = if (px > 0) px - 1 else px;
            const xhi = @min(px + 1, w - 1);
            var yy = ylo;
            while (yy <= yhi) : (yy += 1) {
                var xx = xlo;
                while (xx <= xhi) : (xx += 1) {
                    const q = yy * w + xx;
                    if (gray[q] < below and seen[q] == 0) {
                        seen[q] = 1;
                        try stack.append(a, @intCast(q));
                    }
                }
            }
        }
        try out.append(a, cm);
    }
    return out.toOwnedSlice(a);
}

/// The page marks of an image file, and the stroke width of each box in `boxes` (the OCR lines, image pixels).
///   ppt   the image's pixels per point (150 dpi: 2.083)
pub fn marksOf(image_path: []const u8, ppt: f32, boxes: []const [4]f32) !Marks {
    var res = Marks{ .arena = std.heap.ArenaAllocator.init(gpa), .marks = &.{}, .strokes = &.{} };
    errdefer res.arena.deinit();
    const a = res.arena.allocator();
    var im = try loadImage(image_path);
    defer im.free();
    const w = im.w;
    const h = im.h;
    const gray = try a.alloc(u8, w * h);
    for (0..w * h) |i| {
        const p = im.px.ptr + i * 3;
        gray[i] = @intFromFloat(@round(0.299 * @as(f32, @floatFromInt(p[0])) + 0.587 * @as(f32, @floatFromInt(p[1])) + 0.114 * @as(f32, @floatFromInt(p[2]))));
    }
    var out: std.ArrayList(Mark) = .empty;
    const lv = levelsOf(gray);
    // fills: a shaded rectangle at least 20 pt wide and 5 to 80 pt tall, at least 80% of it shaded
    const tint = try components(a, gray, w, h, lv.tint);
    for (tint) |cc| {
        const fw: f32 = @floatFromInt(cc.x1 - cc.x0 + 1);
        const fh: f32 = @floatFromInt(cc.y1 - cc.y0 + 1);
        if (fw < 20 * ppt or fh < 5 * ppt or fh > 80 * ppt) continue;
        if (@as(f32, @floatFromInt(cc.n)) < 0.8 * fw * fh) continue;
        try out.append(a, .{ .kind = 'f', .x0 = @floatFromInt(cc.x0), .y0 = @floatFromInt(cc.y0), .x1 = @floatFromInt(cc.x1 + 1), .y1 = @floatFromInt(cc.y1 + 1) });
    }
    const fills = try a.dupe(Mark, out.items);
    // rules: a horizontal one at least 28 pt long, a vertical one at least 19 pt (longer than any letter's stroke at
    // body sizes, shorter than a table's height), each at most 2.5 pt thick, never inside a line of text or a shading
    const thick: usize = @max(2, @as(usize, @intFromFloat(@ceil(2.5 * ppt))));
    try rulesAlong(a, gray, w, h, true, @intFromFloat(28 * ppt), thick, &out, boxes, lv.line, fills);
    try rulesAlong(a, gray, w, h, false, @intFromFloat(19 * ppt), thick, &out, boxes, lv.line, fills);
    // dots: a filled shape 2.5 to 9 pt on each side, near square, nothing inked just left of it (a bullet opens a line)
    const ink = try components(a, gray, w, h, lv.ink);
    for (ink) |cc| {
        const cw = cc.x1 - cc.x0 + 1;
        const chh = cc.y1 - cc.y0 + 1;
        const fw: f32 = @floatFromInt(cw);
        const fh: f32 = @floatFromInt(chh);
        if (fw < 2.5 * ppt or fh < 2.5 * ppt or fw > 9 * ppt or fh > 9 * ppt) continue;
        if (fw > 1.6 * fh or fh > 1.6 * fw) continue;
        if (@as(f32, @floatFromInt(cc.n)) < 0.7 * fw * fh) continue;
        var clear = true;
        const lx0 = if (cc.x0 > 2 * cw) cc.x0 - 2 * cw else 0;
        var yy = cc.y0;
        while (yy <= cc.y1 and clear) : (yy += 1) {
            var xx = lx0;
            while (xx + 1 < cc.x0) : (xx += 1) {
                if (gray[yy * w + xx] < lv.ink) {
                    clear = false;
                    break;
                }
            }
        }
        if (!clear) continue;
        if (inRects(fills, @floatFromInt((cc.x0 + cc.x1) / 2), @floatFromInt((cc.y0 + cc.y1) / 2))) continue;
        try out.append(a, .{ .kind = 'd', .x0 = @floatFromInt(cc.x0), .y0 = @floatFromInt(cc.y0), .x1 = @floatFromInt(cc.x1 + 1), .y1 = @floatFromInt(cc.y1 + 1) });
    }
    res.marks = try out.toOwnedSlice(a);
    // strokes: in each line's box, the median length of the horizontal runs of ink (a bold face's strokes are wider)
    const strokes = try a.alloc(f32, boxes.len);
    var runs: std.ArrayList(u16) = .empty;
    for (boxes, 0..) |b, bi| {
        runs.clearRetainingCapacity();
        const bx0: usize = @intFromFloat(std.math.clamp(b[0], 0, @as(f32, @floatFromInt(w - 1))));
        const bx1: usize = @intFromFloat(std.math.clamp(b[2], 0, @as(f32, @floatFromInt(w))));
        const by0: usize = @intFromFloat(std.math.clamp(b[1], 0, @as(f32, @floatFromInt(h - 1))));
        const by1: usize = @intFromFloat(std.math.clamp(b[3], 0, @as(f32, @floatFromInt(h))));
        const cap: usize = @max(1, (by1 -| by0) / 2);
        var yy = by0;
        while (yy < by1) : (yy += 1) {
            var xx = bx0;
            while (xx < bx1) {
                if (gray[yy * w + xx] >= lv.stroke) {
                    xx += 1;
                    continue;
                }
                const s = xx;
                while (xx < bx1 and gray[yy * w + xx] < lv.stroke) xx += 1;
                const len = xx - s;
                if (len <= cap) try runs.append(a, @intCast(len));
            }
        }
        if (runs.items.len == 0) {
            strokes[bi] = 0;
            continue;
        }
        std.sort.pdq(u16, runs.items, {}, std.sort.asc(u16));
        strokes[bi] = @floatFromInt(runs.items[runs.items.len / 2]);
    }
    res.strokes = strokes;
    return res;
}

// --------------------------------------------------------------------------------------------- deskew (O4)

// A phone's scan is turned a little: half a degree turns a table's ruled line into a staircase of short runs and
// a line of text into a box taller than its letters. The skew is the angle at which the page's ink falls into the
// sharpest rows: for each candidate angle, the ink pixels are projected onto the axis across the lines, and the sum
// of the squared row counts is largest when the lines are level (the projection-profile method).

// The ink points that vote on the skew: text strokes, sparse in their neighbourhood. A solid dark area -- the
// shadow or table around a photographed page, which is level with the CAMERA'S frame and not with the page -- is
// dense and would pull the answer to 0 (measured: a page turned 0.5 degrees with a dark band along its bottom read
// as level), so a point votes only when at most 60% of the 5x5 sampled points around it are ink.
fn inkPoints(a: std.mem.Allocator, gray: []const u8, w: usize, h: usize, ink: u8, step: usize) ![][2]f32 {
    const sw = (w + step - 1) / step;
    const sh = (h + step - 1) / step;
    const m = try a.alloc(u8, sw * sh);
    for (0..sh) |j| {
        for (0..sw) |i| m[j * sw + i] = @intFromBool(gray[(j * step) * w + i * step] < ink);
    }
    // nor does a point near the image's border, where a photographed page has its shadow: the fringe where a
    // shadow's gradient crosses the ink level is a thin, perfectly level line of points (measured: golden_v33/u06
    // turned 0.5 degrees with a shadowed bottom read as level until the border stopped voting)
    const mx = sw / 20;
    const my = sh / 20;
    var pts: std.ArrayList([2]f32) = .empty;
    for (0..sh) |j| {
        if (j < my or j + my >= sh) continue;
        for (0..sw) |i| {
            if (i < mx or i + mx >= sw) continue;
            if (m[j * sw + i] == 0) continue;
            var n: u32 = 0;
            var jj = if (j >= 2) j - 2 else 0;
            while (jj <= @min(j + 2, sh - 1)) : (jj += 1) {
                var ii = if (i >= 2) i - 2 else 0;
                while (ii <= @min(i + 2, sw - 1)) : (ii += 1) n += m[jj * sw + ii];
            }
            if (n > 15) continue;
            try pts.append(a, .{ @floatFromInt(i * step), @floatFromInt(j * step) });
        }
    }
    return pts.toOwnedSlice(a);
}

fn profileScore(a: std.mem.Allocator, pts: [][2]f32, h: usize, deg: f32) !f64 {
    const t = @tan(deg * std.math.pi / 180.0);
    const n_bins = h + 4096;
    const bins = try a.alloc(u32, n_bins);
    defer a.free(bins);
    @memset(bins, 0);
    for (pts) |p| {
        // (a bin as wide as the sampling step: with points on every second row, 1-px bins would leave every odd bin
        // empty at exactly 0 degrees and double its score)
        const yy = (p[1] - p[0] * t + 2048) / 2;
        if (yy < 0) continue;
        const b: usize = @intFromFloat(yy);
        if (b < n_bins) bins[b] += 1;
    }
    var sc: f64 = 0;
    for (bins) |v| sc += @as(f64, @floatFromInt(v)) * @as(f64, @floatFromInt(v));
    return sc;
}

/// The page's skew in degrees (positive: the lines rise to the right in image coordinates' terms of y down,
/// i.e. a line's y falls as x grows), searched within +-3 degrees to 0.02 degree.
pub fn skewOf(gray: []const u8, w: usize, h: usize, ink: u8) !f32 {
    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();
    const a = arena.allocator();
    const pts = try inkPoints(a, gray, w, h, ink, 2);
    if (pts.len < 200) return 0;
    var best: f32 = 0;
    var best_sc: f64 = -1;
    var d: f32 = -3.0;
    while (d <= 3.0001) : (d += 0.1) {
        const sc = try profileScore(a, pts, h, d);
        if (sc > best_sc) {
            best_sc = sc;
            best = d;
        }
    }
    const centre = best;
    d = centre - 0.1;
    while (d <= centre + 0.1001) : (d += 0.02) {
        const sc = try profileScore(a, pts, h, d);
        if (sc > best_sc) {
            best_sc = sc;
            best = d;
        }
    }
    return best;
}

fn writeBmp(path: []const u8, im: *const Image) !void {
    const row = (im.w * 3 + 3) & ~@as(usize, 3);
    const size = 54 + row * im.h;
    const buf = try gpa.alloc(u8, size);
    defer gpa.free(buf);
    @memset(buf, 0);
    buf[0] = 'B';
    buf[1] = 'M';
    std.mem.writeInt(u32, buf[2..6], @intCast(size), .little);
    std.mem.writeInt(u32, buf[10..14], 54, .little);
    std.mem.writeInt(u32, buf[14..18], 40, .little);
    std.mem.writeInt(i32, buf[18..22], @intCast(im.w), .little);
    std.mem.writeInt(i32, buf[22..26], @intCast(im.h), .little);
    std.mem.writeInt(u16, buf[26..28], 1, .little);
    std.mem.writeInt(u16, buf[28..30], 24, .little);
    std.mem.writeInt(u32, buf[34..38], @intCast(row * im.h), .little);
    for (0..im.h) |y| {
        const dst = buf[54 + (im.h - 1 - y) * row ..];
        for (0..im.w) |x| {
            const s = im.at(x, y);
            dst[x * 3] = s[2];
            dst[x * 3 + 1] = s[1];
            dst[x * 3 + 2] = s[0];
        }
    }
    const f = try std.fs.cwd().createFile(path, .{});
    defer f.close();
    try f.writeAll(buf);
}

/// Straightens a scanned page: measures its skew and, when it is at least `min_deg`, writes the image turned level
/// to `out_path` (BMP; the corners are filled with the paper's grey). Returns the skew in degrees (0 when level).
pub fn deskew(image_path: []const u8, out_path: []const u8, min_deg: f32) !f32 {
    var im = try loadImage(image_path);
    defer im.free();
    const w = im.w;
    const h = im.h;
    const gray = try gpa.alloc(u8, w * h);
    defer gpa.free(gray);
    for (0..w * h) |i| {
        const p = im.px.ptr + i * 3;
        gray[i] = @intFromFloat(@round(0.299 * @as(f32, @floatFromInt(p[0])) + 0.587 * @as(f32, @floatFromInt(p[1])) + 0.114 * @as(f32, @floatFromInt(p[2]))));
    }
    const lv = levelsOf(gray);
    const deg = try skewOf(gray, w, h, lv.ink);
    if (@abs(deg) < min_deg) return 0;
    // turn by -deg about the centre: each output pixel samples the input bilinearly
    const paper: u8 = lv.tint +| 6;
    var out = try newImage(w, h);
    defer out.free();
    const t = -deg * std.math.pi / 180.0;
    const cs = @cos(t);
    const sn = @sin(t);
    const cx = @as(f32, @floatFromInt(w)) / 2;
    const cy = @as(f32, @floatFromInt(h)) / 2;
    for (0..h) |y| {
        for (0..w) |x| {
            const dx = @as(f32, @floatFromInt(x)) - cx;
            const dy = @as(f32, @floatFromInt(y)) - cy;
            // the source of an output pixel: the output rotated back by +deg
            const sx = cs * dx + sn * dy + cx;
            const sy = -sn * dx + cs * dy + cy;
            const o = out.px.ptr + (y * w + x) * 3;
            if (sx < 0 or sy < 0 or sx > @as(f32, @floatFromInt(w - 1)) or sy > @as(f32, @floatFromInt(h - 1))) {
                o[0] = paper;
                o[1] = paper;
                o[2] = paper;
                continue;
            }
            const x0: usize = @intFromFloat(@floor(sx));
            const y0: usize = @intFromFloat(@floor(sy));
            const x1 = @min(x0 + 1, w - 1);
            const y1 = @min(y0 + 1, h - 1);
            const fx = sx - @as(f32, @floatFromInt(x0));
            const fy = sy - @as(f32, @floatFromInt(y0));
            for (0..3) |k| {
                const v00: f32 = @floatFromInt(im.at(x0, y0)[k]);
                const v10: f32 = @floatFromInt(im.at(x1, y0)[k]);
                const v01: f32 = @floatFromInt(im.at(x0, y1)[k]);
                const v11: f32 = @floatFromInt(im.at(x1, y1)[k]);
                const v = (v00 * (1 - fx) + v10 * fx) * (1 - fy) + (v01 * (1 - fx) + v11 * fx) * fy;
                o[k] = @intFromFloat(@min(255.0, @max(0.0, @round(v))));
            }
        }
    }
    try writeBmp(out_path, &out);
    return deg;
}
