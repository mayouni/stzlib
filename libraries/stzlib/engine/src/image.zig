//! image.zig -- the image plane's core (IM0): ONE image type, gen-keyed
//! handles, codecs, and the first classical operations.
//!
//! SOFTANZA_IMAGE_INTELLIGENCE.md section 1.1: classical image processing is
//! NATIVE Zig, not OpenCV -- and OpenCV is the ORACLE, so where a choice of
//! convention exists this file takes OpenCV's: bilinear sampling with
//! half-pixel centres, BORDER_REFLECT_101 for filters, the 8-bit Gaussian
//! kernel size round(sigma*6+1)|1, THRESH_BINARY's "> t", Otsu over a
//! 256-bin histogram. The guard states the tolerance per operation.
//!
//! An image is 1, 3 or 4 channels of u8, rows top-down, tightly packed.
//! What an ANALYSIS returns is a GRID (rows x cols of f64), never a picture
//! (SOFTANZA_VISION_PLAN.md section 3); a grid that IS the pixels converts
//! back to an image without loss.
//!
//! Handles are (gen << 32) | (slot + 1), as every engine table: a freed
//! handle is refused rather than reused silently.

const std = @import("std");
const png = @import("png_encode.zig");
const core = @import("image_core.zig");
const stbi = @cImport({
    @cDefine("STBI_NO_STDIO", "1");
    @cInclude("stb_image.h");
});
const stbw = @cImport({
    @cDefine("STBI_WRITE_NO_STDIO", "1");
    @cInclude("stb_image_write.h");
});

const alloc = std.heap.c_allocator;

pub const Image = struct {
    w: u32,
    h: u32,
    c: u8,
    px: []u8,
    /// IM9b: the EXIF orientation (1..8) the file carried, 1 when it carried none -- kept even when it was applied.
    stored: u8 = 1,
    /// IM9b: true when decode turned the pixels upright by `stored` (a raw load leaves them as the file stores them).
    applied: bool = false,

    fn at(self: *const Image, x: usize, y: usize, ch: usize) u8 {
        return self.px[(y * self.w + x) * self.c + ch];
    }
};

pub const Grid = struct {
    rows: usize,
    cols: usize,
    data: []f64,
};

fn Table(comptime T: type) type {
    return struct {
        const Slot = struct { v: T = undefined, gen: u32 = 1, live: bool = false };
        items: std.ArrayList(Slot) = .{},

        fn put(self: *@This(), v: T) i64 {
            for (self.items.items, 0..) |*s, i| {
                if (!s.live) {
                    s.v = v;
                    s.live = true;
                    return (@as(i64, s.gen) << 32) | @as(i64, @intCast(i + 1));
                }
            }
            self.items.append(alloc, .{ .v = v, .gen = 1, .live = true }) catch return 0;
            return (@as(i64, 1) << 32) | @as(i64, @intCast(self.items.items.len));
        }

        fn get(self: *@This(), id: i64) ?*T {
            const idx = id & 0xffff_ffff;
            if (idx <= 0 or idx > @as(i64, @intCast(self.items.items.len))) return null;
            const s = &self.items.items[@intCast(idx - 1)];
            const gen: u32 = @intCast((id >> 32) & 0xffff_ffff);
            if (!s.live or s.gen != gen) return null;
            return &s.v;
        }

        fn release(self: *@This(), id: i64) ?T {
            const p = self.get(id) orelse return null;
            const v = p.*;
            const s = &self.items.items[@intCast((id & 0xffff_ffff) - 1)];
            s.live = false;
            s.gen +%= 1;
            if (s.gen == 0) s.gen = 1;
            return v;
        }

        fn live(self: *@This()) usize {
            var n: usize = 0;
            for (self.items.items) |s| {
                if (s.live) n += 1;
            }
            return n;
        }
    };
}

var images: Table(Image) = .{};
var grids: Table(Grid) = .{};

var err_buf: [256]u8 = undefined;
var err_len: usize = 0;

pub fn fail(comptime fmt: []const u8, args: anytype) i64 {
    const s = std.fmt.bufPrint(&err_buf, fmt, args) catch "image: error text too long";
    err_len = s.len;
    return 0;
}

pub fn lastError() []const u8 {
    return err_buf[0..err_len];
}

pub fn adopt(w: u32, h: u32, c: u8, px: []u8) i64 {
    const id = images.put(.{ .w = w, .h = h, .c = c, .px = px });
    if (id == 0) {
        alloc.free(px);
        return fail("image: out of handles", .{});
    }
    return id;
}

fn newBlank(w: u32, h: u32, c: u8) ?[]u8 {
    return alloc.alloc(u8, @as(usize, w) * h * c) catch null;
}

pub fn get(id: i64) ?*Image {
    return images.get(id);
}

// ------------------------------------------------------------------ lifetime

pub fn new(w: u32, h: u32, c: u8, fill: u8) i64 {
    if (w == 0 or h == 0) return fail("image: a size of {d} x {d} has no pixel", .{ w, h });
    if (c != 1 and c != 3 and c != 4) return fail("image: {d} channels -- an image has 1, 3 or 4", .{c});
    const px = newBlank(w, h, c) orelse return fail("image: out of memory", .{});
    @memset(px, fill);
    return adopt(w, h, c, px);
}

pub fn fromRaw(w: u32, h: u32, c: u8, bytes: []const u8) i64 {
    if (c != 1 and c != 3 and c != 4) return fail("image: {d} channels -- an image has 1, 3 or 4", .{c});
    const need = @as(usize, w) * h * c;
    if (w == 0 or h == 0 or bytes.len != need)
        return fail("image: {d} bytes given, {d} x {d} x {d} needs {d}", .{ bytes.len, w, h, c, need });
    const px = alloc.dupe(u8, bytes) catch return fail("image: out of memory", .{});
    return adopt(w, h, c, px);
}

pub fn free(id: i64) i64 {
    const v = images.release(id) orelse return 0;
    alloc.free(v.px);
    return 1;
}

/// Moves the pixels of `src` into the handle `dst` and retires `src`: how a
/// mutating verb keeps ONE handle, so every copy of a Ring face sees the
/// change (Ring copies objects on assignment; the engine-wrapper copy law).
pub fn take(dst: i64, src: i64) i64 {
    if (dst == src) return fail("image: an image cannot take itself", .{});
    const d = images.get(dst) orelse return fail("image: no such image (the target)", .{});
    const s = images.release(src) orelse return fail("image: no such image (the source)", .{});
    alloc.free(d.px);
    d.* = s;
    return 1;
}

pub fn liveImages() usize {
    return images.live();
}

// ------------------------------------------------------------------ codecs

// ---- IM9b: EXIF orientation. A phone stores the pixels as the sensor saw them and a tag says how to turn them;
// a viewer turns them, so decode does too (decodeKeep and loadKeep do not). Read from a JPEG's APP1 segment, a PNG's
// eXIf chunk, or a TIFF's own first directory; anything absent, malformed or out of 1..8 reads as 1 (upright).

fn rd16(t: []const u8, o: usize, le: bool) u16 {
    return std.mem.readInt(u16, t[o..][0..2], if (le) .little else .big);
}

fn rd32(t: []const u8, o: usize, le: bool) u32 {
    return std.mem.readInt(u32, t[o..][0..4], if (le) .little else .big);
}

/// The Orientation tag (0x0112) of the first directory of a TIFF stream (the body of an Exif segment is one).
fn tiffOrientation(t: []const u8) u8 {
    if (t.len < 8) return 1;
    const le = t[0] == 'I' and t[1] == 'I';
    if (!le and !(t[0] == 'M' and t[1] == 'M')) return 1;
    if (rd16(t, 2, le) != 42) return 1;
    const ifd: usize = rd32(t, 4, le);
    if (ifd + 2 > t.len) return 1;
    const n: usize = rd16(t, ifd, le);
    var k: usize = 0;
    while (k < n) : (k += 1) {
        const e = ifd + 2 + 12 * k;
        if (e + 12 > t.len) return 1;
        if (rd16(t, e, le) == 0x0112) {
            const v = rd16(t, e + 8, le);
            return if (v >= 1 and v <= 8) @intCast(v) else 1;
        }
    }
    return 1;
}

fn jpegOrientation(b: []const u8) u8 {
    var i: usize = 2;
    while (i + 4 <= b.len) {
        if (b[i] != 0xFF) return 1;
        const m = b[i + 1];
        if (m == 0xFF) {
            i += 1;
            continue;
        }
        if (m == 0xD9 or m == 0xDA) return 1;
        if (m == 0x01 or (m >= 0xD0 and m <= 0xD7)) {
            i += 2;
            continue;
        }
        const len: usize = std.mem.readInt(u16, b[i + 2 ..][0..2], .big);
        if (len < 2 or i + 2 + len > b.len) return 1;
        if (m == 0xE1 and len >= 8 and std.mem.eql(u8, b[i + 4 ..][0..6], "Exif\x00\x00")) {
            return tiffOrientation(b[i + 10 .. i + 2 + len]);
        }
        i += 2 + len;
    }
    return 1;
}

fn pngOrientation(b: []const u8) u8 {
    var i: usize = 8;
    while (i + 12 <= b.len) {
        const len: usize = std.mem.readInt(u32, b[i..][0..4], .big);
        if (i + 12 + len > b.len) return 1;
        const typ = b[i + 4 ..][0..4];
        if (std.mem.eql(u8, typ, "eXIf")) return tiffOrientation(b[i + 8 ..][0..len]);
        if (std.mem.eql(u8, typ, "IEND")) return 1;
        i += 12 + len;
    }
    return 1;
}

/// The EXIF orientation (1..8) a file's bytes carry; 1 when none.
pub fn exifOrientation(b: []const u8) u8 {
    if (b.len >= 4 and b[0] == 0xFF and b[1] == 0xD8) return jpegOrientation(b);
    if (b.len >= 8 and std.mem.eql(u8, b[0..8], "\x89PNG\r\n\x1a\n")) return pngOrientation(b);
    if (b.len >= 8 and ((b[0] == 'I' and b[1] == 'I' and b[2] == 42 and b[3] == 0) or
        (b[0] == 'M' and b[1] == 'M' and b[2] == 0 and b[3] == 42))) return tiffOrientation(b);
    return 1;
}

/// Turn the pixels upright by an EXIF orientation, in place. 2 mirror, 3 half turn, 4 flip, 5 transpose,
/// 6 quarter turn clockwise, 7 transverse, 8 quarter turn counter-clockwise (5 to 8 swap width and height).
fn orientInPlace(im: *Image, o: u8) bool {
    if (o < 2 or o > 8) return true;
    const w: usize = im.w;
    const h: usize = im.h;
    const c: usize = im.c;
    const swap = o >= 5;
    const dw: usize = if (swap) h else w;
    const dh: usize = if (swap) w else h;
    const out = alloc.alloc(u8, dw * dh * c) catch return false;
    var y: usize = 0;
    while (y < dh) : (y += 1) {
        var x: usize = 0;
        while (x < dw) : (x += 1) {
            var sx: usize = 0;
            var sy: usize = 0;
            switch (o) {
                2 => {
                    sx = w - 1 - x;
                    sy = y;
                },
                3 => {
                    sx = w - 1 - x;
                    sy = h - 1 - y;
                },
                4 => {
                    sx = x;
                    sy = h - 1 - y;
                },
                5 => {
                    sx = y;
                    sy = x;
                },
                6 => {
                    sx = y;
                    sy = h - 1 - x;
                },
                7 => {
                    sx = w - 1 - y;
                    sy = h - 1 - x;
                },
                else => {
                    sx = w - 1 - y;
                    sy = x;
                },
            }
            @memcpy(out[(y * dw + x) * c ..][0..c], im.px[(sy * w + sx) * c ..][0..c]);
        }
    }
    alloc.free(im.px);
    im.px = out;
    im.w = @intCast(dw);
    im.h = @intCast(dh);
    return true;
}

/// PNG/JPEG/BMP/GIF/TGA/PSD bytes -> an image with the file's own channels, the pixels as the file stores them and
/// the EXIF orientation it carried recorded (`stored`) and NOT applied. decode applies it.
pub fn decodeKeep(bytes: []const u8) i64 {
    const id = decodeRaw(bytes);
    if (id == 0) return 0;
    if (images.get(id)) |im| im.stored = exifOrientation(bytes);
    return id;
}

/// Like decodeKeep, then turned upright by the stored orientation: the picture as a viewer shows it.
pub fn decode(bytes: []const u8) i64 {
    const id = decodeKeep(bytes);
    if (id == 0) return 0;
    const im = images.get(id) orelse return id;
    if (im.stored > 1) {
        if (!orientInPlace(im, im.stored)) {
            _ = free(id);
            return fail("image: out of memory", .{});
        }
        im.applied = true;
    }
    return id;
}

/// PNG/JPEG/BMP/GIF/TGA/PSD bytes -> an image with the file's own channels
/// (gray+alpha widens to RGBA: the type holds 1, 3 or 4).
fn decodeRaw(bytes: []const u8) i64 {
    if (bytes.len == 0) return fail("image: nothing to decode", .{});
    var w: c_int = 0;
    var h: c_int = 0;
    var comp: c_int = 0;
    const info = stbi.stbi_info_from_memory(bytes.ptr, @intCast(bytes.len), &w, &h, &comp);
    if (info == 0) return fail("image: not a format stb_image reads ({s})", .{std.mem.span(stbi.stbi_failure_reason())});
    const want: c_int = if (comp == 2) 4 else comp;
    const p = stbi.stbi_load_from_memory(bytes.ptr, @intCast(bytes.len), &w, &h, &comp, want);
    if (p == null) return fail("image: decode failed ({s})", .{std.mem.span(stbi.stbi_failure_reason())});
    defer stbi.stbi_image_free(p);
    const n: usize = @as(usize, @intCast(w)) * @as(usize, @intCast(h)) * @as(usize, @intCast(want));
    const px = alloc.dupe(u8, p[0..n]) catch return fail("image: out of memory", .{});
    return adopt(@intCast(w), @intCast(h), @intCast(want), px);
}

pub fn load(path: []const u8) i64 {
    const bytes = std.fs.cwd().readFileAlloc(alloc, path, 1 << 30) catch
        return fail("image: cannot read '{s}'", .{path});
    defer alloc.free(bytes);
    return decode(bytes);
}

/// load, with the pixels as the file stores them (see decodeKeep).
pub fn loadKeep(path: []const u8) i64 {
    const bytes = std.fs.cwd().readFileAlloc(alloc, path, 1 << 30) catch
        return fail("image: cannot read '{s}'", .{path});
    defer alloc.free(bytes);
    return decodeKeep(bytes);
}

/// The EXIF orientation (1..8) the file carried, 0 for a handle that is not an image.
pub fn storedOrientation(id: i64) i64 {
    const im = images.get(id) orelse return 0;
    return im.stored;
}

/// 1 when decode turned the pixels upright by the stored orientation.
pub fn orientationApplied(id: i64) i64 {
    const im = images.get(id) orelse return 0;
    return if (im.applied) 1 else 0;
}

fn toRgba(im: *const Image) ?[]u8 {
    const n = @as(usize, im.w) * im.h;
    const out = alloc.alloc(u8, n * 4) catch return null;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        switch (im.c) {
            1 => {
                const g = im.px[i];
                out[i * 4] = g;
                out[i * 4 + 1] = g;
                out[i * 4 + 2] = g;
                out[i * 4 + 3] = 255;
            },
            3 => {
                @memcpy(out[i * 4 ..][0..3], im.px[i * 3 ..][0..3]);
                out[i * 4 + 3] = 255;
            },
            else => @memcpy(out[i * 4 ..][0..4], im.px[i * 4 ..][0..4]),
        }
    }
    return out;
}

/// PNG bytes through the engine's one encoder (caller frees with alloc).
pub fn encodePng(id: i64) ?[]u8 {
    const im = images.get(id) orelse return null;
    const rgba = toRgba(im) orelse return null;
    defer alloc.free(rgba);
    return png.pngEncode(im.w, im.h, rgba, 6) catch null;
}

pub fn savePng(id: i64, path: []const u8) i64 {
    const bytes = encodePng(id) orelse return fail("image: no such image, or it could not be encoded", .{});
    defer alloc.free(bytes);
    std.fs.cwd().writeFile(.{ .sub_path = path, .data = bytes }) catch
        return fail("image: cannot write '{s}'", .{path});
    return 1;
}

fn jpgSink(ctx: ?*anyopaque, data: ?*anyopaque, size: c_int) callconv(.c) void {
    const list: *std.ArrayList(u8) = @ptrCast(@alignCast(ctx.?));
    const p: [*]const u8 = @ptrCast(data.?);
    list.appendSlice(alloc, p[0..@intCast(size)]) catch {};
}

/// JPEG bytes through stb_image_write (baseline, 4:2:0 for colour), quality
/// 1..100; alpha is dropped (JPEG has none). Caller frees with alloc.
pub fn encodeJpeg(id: i64, quality: i64) ?[]u8 {
    const im = images.get(id) orelse return null;
    var list: std.ArrayList(u8) = .{};
    const q: c_int = @intCast(@max(1, @min(100, quality)));
    const ok = stbw.stbi_write_jpg_to_func(jpgSink, &list, @intCast(im.w), @intCast(im.h), im.c, im.px.ptr, q);
    if (ok == 0 or list.items.len == 0) {
        list.deinit(alloc);
        return null;
    }
    return list.toOwnedSlice(alloc) catch null;
}

pub fn saveJpeg(id: i64, path: []const u8, quality: i64) i64 {
    const bytes = encodeJpeg(id, quality) orelse return fail("image: no such image, or it could not be encoded", .{});
    defer alloc.free(bytes);
    std.fs.cwd().writeFile(.{ .sub_path = path, .data = bytes }) catch
        return fail("image: cannot write '{s}'", .{path});
    return 1;
}

/// 24-bit BMP (alpha dropped): the format every viewer opens.
pub fn saveBmp(id: i64, path: []const u8) i64 {
    const im = images.get(id) orelse return fail("image: no such image", .{});
    const out = core.bmp24(alloc, .{ .w = im.w, .h = im.h, .c = im.c, .px = im.px }) catch return fail("image: out of memory", .{});
    defer alloc.free(out);
    std.fs.cwd().writeFile(.{ .sub_path = path, .data = out }) catch
        return fail("image: cannot write '{s}'", .{path});
    return 1;
}

// ------------------------------------------------------------------ drawing (IM3)

fn paint(im: *Image, x: i64, y: i64, rgb: [3]u8) void {
    if (x < 0 or y < 0 or x >= im.w or y >= im.h) return;
    const o = im.px[(@as(usize, @intCast(y)) * im.w + @as(usize, @intCast(x))) * im.c ..];
    if (im.c == 1) {
        o[0] = gray601(rgb[0], rgb[1], rgb[2]);
        return;
    }
    o[0] = rgb[0];
    o[1] = rgb[1];
    o[2] = rgb[2];
    if (im.c == 4) o[3] = 255;
}

/// Draws a rectangle's outline IN PLACE (the handle keeps its pixels): (x, y) its top-left, `t` pixels
/// thick, inward. Parts outside the image are clipped.
pub fn box(id: i64, x: i64, y: i64, w: i64, h: i64, rgb: [3]u8, t: i64) i64 {
    const im = images.get(id) orelse return fail("image: no such image", .{});
    if (w <= 0 or h <= 0) return 1;
    const th = @max(1, @min(t, @divTrunc(@min(w, h) + 1, 2)));
    var k: i64 = 0;
    while (k < th) : (k += 1) {
        var xx = x;
        while (xx < x + w) : (xx += 1) {
            paint(im, xx, y + k, rgb);
            paint(im, xx, y + h - 1 - k, rgb);
        }
        var yy = y;
        while (yy < y + h) : (yy += 1) {
            paint(im, x + k, yy, rgb);
            paint(im, x + w - 1 - k, yy, rgb);
        }
    }
    return 1;
}

/// Draws a filled disc IN PLACE, centre (x, y), radius r.
pub fn dot(id: i64, x: f64, y: f64, r: f64, rgb: [3]u8) i64 {
    const im = images.get(id) orelse return fail("image: no such image", .{});
    const x0: i64 = @intFromFloat(@floor(x - r));
    const x1: i64 = @intFromFloat(@ceil(x + r));
    const y0: i64 = @intFromFloat(@floor(y - r));
    const y1: i64 = @intFromFloat(@ceil(y + r));
    var yy = y0;
    while (yy <= y1) : (yy += 1) {
        var xx = x0;
        while (xx <= x1) : (xx += 1) {
            const dx = @as(f64, @floatFromInt(xx)) - x;
            const dy = @as(f64, @floatFromInt(yy)) - y;
            if (dx * dx + dy * dy <= r * r) paint(im, xx, yy, rgb);
        }
    }
    return 1;
}

// ------------------------------------------------------------------ channels

fn gray601(r: u8, g: u8, b: u8) u8 {
    return core.gray(r, g, b); // OpenCV 5's RGB2GRAY, bit for bit (image_core)
}

/// A copy with `c` channels: 1 (gray, OpenCV 5's BT.601), 3 (RGB) or 4 (RGBA, alpha 255
/// when the source has none).
pub fn convert(id: i64, c: u8) i64 {
    const im = images.get(id) orelse return fail("image: no such image", .{});
    if (c != 1 and c != 3 and c != 4) return fail("image: {d} channels -- an image has 1, 3 or 4", .{c});
    const n = @as(usize, im.w) * im.h;
    const out = newBlank(im.w, im.h, c) orelse return fail("image: out of memory", .{});
    var i: usize = 0;
    while (i < n) : (i += 1) {
        const s = im.px[i * im.c ..];
        const r: u8 = s[0];
        var g: u8 = s[0];
        var b: u8 = s[0];
        var a: u8 = 255;
        if (im.c >= 3) {
            g = s[1];
            b = s[2];
        }
        if (im.c == 4) a = s[3];
        const d = out[i * c ..];
        switch (c) {
            1 => d[0] = if (im.c == 1) r else gray601(r, g, b),
            3 => {
                d[0] = r;
                d[1] = g;
                d[2] = b;
            },
            else => {
                d[0] = r;
                d[1] = g;
                d[2] = b;
                d[3] = a;
            },
        }
    }
    return adopt(im.w, im.h, c, out);
}

/// A copy with the colour channels inverted; alpha is kept.
pub fn invert(id: i64) i64 {
    const im = images.get(id) orelse return fail("image: no such image", .{});
    const out = alloc.dupe(u8, im.px) catch return fail("image: out of memory", .{});
    const n = @as(usize, im.w) * im.h;
    const colour: usize = if (im.c == 4) 3 else im.c;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        var k: usize = 0;
        while (k < colour) : (k += 1) out[i * im.c + k] = 255 - out[i * im.c + k];
    }
    return adopt(im.w, im.h, im.c, out);
}

/// An RGBA copy whose alpha is a mask's gray (IM6: a cut-out); the mask must have the image's size.
pub fn withMask(id: i64, mask_id: i64) i64 {
    const im = images.get(id) orelse return fail("image: no such image", .{});
    const mk = images.get(mask_id) orelse return fail("image: no such mask", .{});
    if (mk.w != im.w or mk.h != im.h)
        return fail("image: the mask is {d}x{d}, the image {d}x{d}", .{ mk.w, mk.h, im.w, im.h });
    const n = @as(usize, im.w) * im.h;
    const out = alloc.alloc(u8, n * 4) catch return fail("image: out of memory", .{});
    var i: usize = 0;
    while (i < n) : (i += 1) {
        const s0 = im.px[i * im.c ..];
        out[i * 4] = s0[0];
        out[i * 4 + 1] = if (im.c >= 3) s0[1] else s0[0];
        out[i * 4 + 2] = if (im.c >= 3) s0[2] else s0[0];
        out[i * 4 + 3] = grayOf(mk, i);
    }
    return adopt(im.w, im.h, 4, out);
}

/// The connected part (8-connected) of a mask's pixels at `level` or above that holds the pixel (x, y),
/// 0-based, as a one-channel mask of 0 and 255 -- empty when the pixel itself is below the level (IM6: the
/// classical floor of an object picked by a point, the foreground region the point falls in).
pub fn componentAt(id: i64, x: u32, y: u32, level: u8) i64 {
    const im = images.get(id) orelse return fail("image: no such image", .{});
    if (x >= im.w or y >= im.h) return fail("image: the point {d},{d} is outside the {d}x{d} image", .{ x, y, im.w, im.h });
    const n = @as(usize, im.w) * im.h;
    const out = alloc.alloc(u8, n) catch return fail("image: out of memory", .{});
    @memset(out, 0);
    const W: usize = im.w;
    const H: usize = im.h;
    const start = @as(usize, y) * W + x;
    if (grayOf(im, start) >= level) {
        var stack: std.ArrayList(usize) = .empty;
        defer stack.deinit(alloc);
        out[start] = 255;
        stack.append(alloc, start) catch return fail("image: out of memory", .{});
        while (stack.pop()) |i| {
            const cx = i % W;
            const cy = i / W;
            var dy: i64 = -1;
            while (dy <= 1) : (dy += 1) {
                var dx: i64 = -1;
                while (dx <= 1) : (dx += 1) {
                    const nx = @as(i64, @intCast(cx)) + dx;
                    const ny = @as(i64, @intCast(cy)) + dy;
                    if (nx < 0 or ny < 0 or nx >= W or ny >= H) continue;
                    const j = @as(usize, @intCast(ny)) * W + @as(usize, @intCast(nx));
                    if (out[j] == 0 and grayOf(im, j) >= level) {
                        out[j] = 255;
                        stack.append(alloc, j) catch return fail("image: out of memory", .{});
                    }
                }
            }
        }
    }
    return adopt(im.w, im.h, 1, out);
}

// ------------------------------------------------------------------ geometry

/// A copy of the rectangle (x, y, w, h); refused when it leaves the image.
pub fn crop(id: i64, x: u32, y: u32, w: u32, h: u32) i64 {
    const im = images.get(id) orelse return fail("image: no such image", .{});
    if (w == 0 or h == 0 or @as(u64, x) + w > im.w or @as(u64, y) + h > im.h)
        return fail("image: the rectangle {d},{d} {d}x{d} leaves the {d}x{d} image", .{ x, y, w, h, im.w, im.h });
    const out = newBlank(w, h, im.c) orelse return fail("image: out of memory", .{});
    const rb = @as(usize, w) * im.c;
    var r: usize = 0;
    while (r < h) : (r += 1) {
        const src = ((y + r) * @as(usize, im.w) + x) * im.c;
        @memcpy(out[r * rb ..][0..rb], im.px[src..][0..rb]);
    }
    return adopt(w, h, im.c, out);
}

/// A mirrored copy: horizontal (left-right) when `horizontal` is 1, else top-bottom.
pub fn flip(id: i64, horizontal: bool) i64 {
    const im = images.get(id) orelse return fail("image: no such image", .{});
    const out = newBlank(im.w, im.h, im.c) orelse return fail("image: out of memory", .{});
    var y: usize = 0;
    while (y < im.h) : (y += 1) {
        var x: usize = 0;
        while (x < im.w) : (x += 1) {
            const sx = if (horizontal) im.w - 1 - x else x;
            const sy = if (horizontal) y else im.h - 1 - y;
            @memcpy(out[(y * im.w + x) * im.c ..][0..im.c], im.px[(sy * im.w + sx) * im.c ..][0..im.c]);
        }
    }
    return adopt(im.w, im.h, im.c, out);
}

/// A copy turned clockwise by `quarters` quarter turns (any integer).
pub fn rotate(id: i64, quarters: i64) i64 {
    const im = images.get(id) orelse return fail("image: no such image", .{});
    const q: u2 = @intCast(@mod(quarters, 4));
    const nw: u32 = if (q % 2 == 1) im.h else im.w;
    const nh: u32 = if (q % 2 == 1) im.w else im.h;
    const out = newBlank(nw, nh, im.c) orelse return fail("image: out of memory", .{});
    core.quarterTurn(.{ .w = im.w, .h = im.h, .c = im.c, .px = im.px }, q, .{ .w = nw, .h = nh, .c = im.c, .px = out });
    return adopt(nw, nh, im.c, out);
}

pub const Resample = enum(u8) { nearest = 0, bilinear = 1, area = 2 };

fn clampF(v: f64, lo: f64, hi: f64) f64 {
    return @max(lo, @min(hi, v));
}

pub fn round8(v: f64) u8 {
    return @intFromFloat(clampF(@floor(v + 0.5), 0, 255));
}

/// A resampled copy at w x h. nearest: OpenCV INTER_NEAREST (floor(dst*scale));
/// bilinear: half-pixel centres, edges clamped (INTER_LINEAR geometry);
/// area: the exact average of the source area each target pixel covers
/// (INTER_AREA when shrinking; bilinear when growing, as OpenCV does).
pub fn resize(id: i64, w: u32, h: u32, mode: Resample) i64 {
    const im = images.get(id) orelse return fail("image: no such image", .{});
    if (w == 0 or h == 0) return fail("image: a size of {d} x {d} has no pixel", .{ w, h });
    const out = newBlank(w, h, im.c) orelse return fail("image: out of memory", .{});
    const sx: f64 = @as(f64, @floatFromInt(im.w)) / @as(f64, @floatFromInt(w));
    const sy: f64 = @as(f64, @floatFromInt(im.h)) / @as(f64, @floatFromInt(h));
    const m = if (mode == .area and (w > im.w or h > im.h)) Resample.bilinear else mode;
    if (m == .bilinear) {
        // image_core's arithmetic: the one the OCR pipeline was measured on
        core.resizeBilinear(.{ .w = im.w, .h = im.h, .c = im.c, .px = im.px }, .{ .w = w, .h = h, .c = im.c, .px = out }, alloc) catch {
            alloc.free(out);
            return fail("image: out of memory", .{});
        };
        return adopt(w, h, im.c, out);
    }
    var y: usize = 0;
    while (y < h) : (y += 1) {
        var x: usize = 0;
        while (x < w) : (x += 1) {
            const d = out[(y * w + x) * im.c ..];
            switch (m) {
                .nearest => {
                    const px: usize = @min(im.w - 1, @as(usize, @intFromFloat(@floor(@as(f64, @floatFromInt(x)) * sx))));
                    const py: usize = @min(im.h - 1, @as(usize, @intFromFloat(@floor(@as(f64, @floatFromInt(y)) * sy))));
                    @memcpy(d[0..im.c], im.px[(py * im.w + px) * im.c ..][0..im.c]);
                },
                .bilinear => unreachable, // handled above by image_core
                .area => {
                    const x0 = @as(f64, @floatFromInt(x)) * sx;
                    const x1 = x0 + sx;
                    const y0 = @as(f64, @floatFromInt(y)) * sy;
                    const y1 = y0 + sy;
                    var k: usize = 0;
                    while (k < im.c) : (k += 1) {
                        var acc: f64 = 0;
                        var yy: usize = @intFromFloat(@floor(y0));
                        while (@as(f64, @floatFromInt(yy)) < y1 and yy < im.h) : (yy += 1) {
                            const wy = @min(y1, @as(f64, @floatFromInt(yy + 1))) - @max(y0, @as(f64, @floatFromInt(yy)));
                            var xx: usize = @intFromFloat(@floor(x0));
                            while (@as(f64, @floatFromInt(xx)) < x1 and xx < im.w) : (xx += 1) {
                                const wx = @min(x1, @as(f64, @floatFromInt(xx + 1))) - @max(x0, @as(f64, @floatFromInt(xx)));
                                acc += wx * wy * @as(f64, @floatFromInt(im.at(xx, yy, k)));
                            }
                        }
                        d[k] = round8(acc / (sx * sy));
                    }
                },
            }
        }
    }
    return adopt(w, h, im.c, out);
}

// ------------------------------------------------------------------ filters

/// BORDER_REFLECT_101: ... 2 1 | 0 1 2 ... n-1 | n-2 ...
pub fn reflect101(i: i64, n: i64) usize {
    if (n == 1) return 0;
    var v = i;
    while (v < 0 or v >= n) {
        if (v < 0) v = -v;
        if (v >= n) v = 2 * (n - 1) - v;
    }
    return @intCast(v);
}

/// A Gaussian-blurred copy: separable, kernel size round(sigma*6+1)|1 and
/// weights exp(-x^2 / 2 sigma^2) normalised (OpenCV's 8-bit rule), border
/// REFLECT_101. Alpha is blurred like any channel.
pub fn blur(id: i64, sigma: f64) i64 {
    const im = images.get(id) orelse return fail("image: no such image", .{});
    if (!(sigma > 0) or sigma > 100) return fail("image: a blur needs 0 < sigma <= 100, not {d}", .{sigma});
    var ks: usize = @intFromFloat(@floor(sigma * 6 + 1 + 0.5));
    ks |= 1;
    const r: i64 = @intCast(ks / 2);
    const kern = alloc.alloc(f64, ks) catch return fail("image: out of memory", .{});
    defer alloc.free(kern);
    var sum: f64 = 0;
    for (kern, 0..) |*k, i| {
        const t: f64 = @as(f64, @floatFromInt(@as(i64, @intCast(i)) - r));
        k.* = @exp(-(t * t) / (2 * sigma * sigma));
        sum += k.*;
    }
    for (kern) |*k| k.* /= sum;

    const n = @as(usize, im.w) * im.h * im.c;
    const tmp = alloc.alloc(f64, n) catch return fail("image: out of memory", .{});
    defer alloc.free(tmp);
    const W: i64 = im.w;
    const H: i64 = im.h;
    // horizontal pass into f64, vertical pass back to u8 (one rounding)
    var y: i64 = 0;
    while (y < H) : (y += 1) {
        var x: i64 = 0;
        while (x < W) : (x += 1) {
            var k: usize = 0;
            while (k < im.c) : (k += 1) {
                var acc: f64 = 0;
                var j: i64 = -r;
                while (j <= r) : (j += 1) {
                    const sx = reflect101(x + j, W);
                    acc += kern[@intCast(j + r)] * @as(f64, @floatFromInt(im.at(sx, @intCast(y), k)));
                }
                tmp[(@as(usize, @intCast(y)) * im.w + @as(usize, @intCast(x))) * im.c + k] = acc;
            }
        }
    }
    const out = newBlank(im.w, im.h, im.c) orelse return fail("image: out of memory", .{});
    y = 0;
    while (y < H) : (y += 1) {
        var x: i64 = 0;
        while (x < W) : (x += 1) {
            var k: usize = 0;
            while (k < im.c) : (k += 1) {
                var acc: f64 = 0;
                var j: i64 = -r;
                while (j <= r) : (j += 1) {
                    const sy = reflect101(y + j, H);
                    acc += kern[@intCast(j + r)] * tmp[(sy * im.w + @as(usize, @intCast(x))) * im.c + k];
                }
                out[(@as(usize, @intCast(y)) * im.w + @as(usize, @intCast(x))) * im.c + k] = round8(acc);
            }
        }
    }
    return adopt(im.w, im.h, im.c, out);
}

// ------------------------------------------------------------------ threshold

pub fn grayOf(im: *const Image, i: usize) u8 {
    const s = im.px[i * im.c ..];
    return if (im.c == 1) s[0] else gray601(s[0], s[1], s[2]);
}

fn histogram256(im: *const Image, channel: i64) [256]u64 {
    var hist = [_]u64{0} ** 256;
    const n = @as(usize, im.w) * im.h;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        const v = if (channel < 0) grayOf(im, i) else im.px[i * im.c + @as(usize, @intCast(channel))];
        hist[v] += 1;
    }
    return hist;
}

/// Otsu's threshold of the image's gray levels: the t maximising the
/// between-class variance of {<= t} and {> t}; the first t on a tie.
/// Answers -1 for a missing image.
pub fn otsu(id: i64) i64 {
    const im = images.get(id) orelse return -1;
    const hist = histogram256(im, -1);
    const total: f64 = @floatFromInt(@as(usize, im.w) * im.h);
    var sum_all: f64 = 0;
    for (hist, 0..) |c, v| sum_all += @as(f64, @floatFromInt(v)) * @as(f64, @floatFromInt(c));
    var w0: f64 = 0;
    var sum0: f64 = 0;
    var best: f64 = -1;
    var best_t: i64 = 0;
    for (hist, 0..) |c, t| {
        w0 += @floatFromInt(c);
        sum0 += @as(f64, @floatFromInt(t)) * @as(f64, @floatFromInt(c));
        const w1 = total - w0;
        if (w0 == 0 or w1 == 0) continue;
        const m0 = sum0 / w0;
        const m1 = (sum_all - sum0) / w1;
        const between = w0 * w1 * (m0 - m1) * (m0 - m1);
        if (between > best + 1e-9) {
            best = between;
            best_t = @intCast(t);
        }
    }
    return best_t;
}

/// A one-channel copy: 255 where the gray level is > t, 0 elsewhere
/// (THRESH_BINARY). A colour image is read through BT.601 gray.
pub fn threshold(id: i64, t: i64) i64 {
    const im = images.get(id) orelse return fail("image: no such image", .{});
    const n = @as(usize, im.w) * im.h;
    const out = newBlank(im.w, im.h, 1) orelse return fail("image: out of memory", .{});
    var i: usize = 0;
    while (i < n) : (i += 1) out[i] = if (@as(i64, grayOf(im, i)) > t) 255 else 0;
    return adopt(im.w, im.h, 1, out);
}

// ------------------------------------------------------------------ text luminance

/// WCAG 2.x relative luminance of one sRGB pixel, 0 (black) to 1 (white).
fn wcagLuminance(im: *const Image, i: usize) f64 {
    const s = im.px[i * im.c ..];
    const r = srgbLinear(s[0]);
    if (im.c == 1) return r;
    return 0.2126 * r + 0.7152 * srgbLinear(s[1]) + 0.0722 * srgbLinear(s[2]);
}

fn srgbLinear(v: u8) f64 {
    const x = @as(f64, @floatFromInt(v)) / 255.0;
    return if (x <= 0.04045) x / 12.92 else std.math.pow(f64, (x + 0.055) / 1.055, 2.4);
}

fn quantile(sorted: []const f64, q: f64) f64 {
    const pos = q * @as(f64, @floatFromInt(sorted.len - 1));
    const lo: usize = @intFromFloat(@floor(pos));
    const hi = @min(lo + 1, sorted.len - 1);
    return sorted[lo] + (sorted[hi] - sorted[lo]) * (pos - @floor(pos));
}

pub const TextLuminance = struct {
    fg: f64,
    bg: f64,
    spread: f64,
    n_ink: usize,
    n_bg: usize,
    t: i64,
};

/// The text and background luminance inside the box x0..x1, y0..y1 (0-based, both ends included, clamped to
/// the image) -- what a contrast ratio is computed from. MEASURES, never judges:
///   - the box's gray levels are split by Otsu; the side with FEWER pixels is the ink
///   - the text colour is the median luminance of the quarter of the ink pixels farthest from the split
///     (antialiased edges lie near the split, so a median over all ink would lighten thin text)
///   - the background is the median luminance of the other side's pixels at least 3 pixels from any ink pixel
///     (Chebyshev distance), and its spread is their 2nd to 98th percentile range
/// null when the box is flat (one gray level), and n_bg 0 when no background pixel is far enough from ink.
pub fn textLuminance(id: i64, bx0: i64, by0: i64, bx1: i64, by1: i64) ?TextLuminance {
    const im = images.get(id) orelse return null;
    const W: i64 = im.w;
    const H: i64 = im.h;
    const x0: usize = @intCast(std.math.clamp(bx0, 0, W - 1));
    const y0: usize = @intCast(std.math.clamp(by0, 0, H - 1));
    const x1: usize = @intCast(std.math.clamp(bx1, 0, W - 1));
    const y1: usize = @intCast(std.math.clamp(by1, 0, H - 1));
    if (x1 < x0 or y1 < y0) return null;
    const bw = x1 - x0 + 1;
    const bh = y1 - y0 + 1;
    const n = bw * bh;
    // Otsu over the box's own histogram
    var hist = [_]u64{0} ** 256;
    for (0..bh) |yy| {
        for (0..bw) |xx| hist[grayOf(im, (y0 + yy) * im.w + x0 + xx)] += 1;
    }
    const total: f64 = @floatFromInt(n);
    var sum_all: f64 = 0;
    for (hist, 0..) |c, v| sum_all += @as(f64, @floatFromInt(v)) * @as(f64, @floatFromInt(c));
    var w0: f64 = 0;
    var sum0: f64 = 0;
    var best: f64 = -1;
    var t: usize = 0;
    for (hist, 0..) |c, v| {
        w0 += @floatFromInt(c);
        sum0 += @as(f64, @floatFromInt(v)) * @as(f64, @floatFromInt(c));
        const w1 = total - w0;
        if (w0 == 0 or w1 == 0) continue;
        const m0 = sum0 / w0;
        const m1 = (sum_all - sum0) / w1;
        const between = w0 * w1 * (m0 - m1) * (m0 - m1);
        if (between > best + 1e-9) {
            best = between;
            t = v;
        }
    }
    if (best < 0) return null;
    var n_dark: usize = 0;
    for (hist[0 .. t + 1]) |c| n_dark += c;
    const ink_dark = n_dark <= n - n_dark;
    const ink = alloc.alloc(u8, n) catch return null;
    defer alloc.free(ink);
    var n_ink: usize = 0;
    for (0..bh) |yy| {
        for (0..bw) |xx| {
            const g = grayOf(im, (y0 + yy) * im.w + x0 + xx);
            const is_ink = if (ink_dark) g <= t else g > t;
            ink[yy * bw + xx] = @intFromBool(is_ink);
            n_ink += @intFromBool(is_ink);
        }
    }
    // the ink pixels, farthest from the split first
    const Far = struct { d: usize, l: f64 };
    const inks = alloc.alloc(Far, n_ink) catch return null;
    defer alloc.free(inks);
    var k: usize = 0;
    for (0..bh) |yy| {
        for (0..bw) |xx| {
            if (ink[yy * bw + xx] == 0) continue;
            const i = (y0 + yy) * im.w + x0 + xx;
            const g: usize = grayOf(im, i);
            inks[k] = .{ .d = if (g > t) g - t else t - g, .l = wcagLuminance(im, i) };
            k += 1;
        }
    }
    std.sort.pdq(Far, inks, {}, struct {
        fn gt(_: void, a: Far, b: Far) bool {
            return a.d > b.d;
        }
    }.gt);
    const n_core = @max(1, n_ink / 4);
    const far = alloc.alloc(f64, n_core) catch return null;
    defer alloc.free(far);
    for (0..n_core) |j| far[j] = inks[j].l;
    std.sort.pdq(f64, far, {}, std.sort.asc(f64));
    // the background far from any ink: a 7x7 dilation of the ink (two passes of a running max)
    const near = alloc.alloc(u8, n) catch return null;
    defer alloc.free(near);
    const R: usize = 3;
    for (0..bh) |yy| {
        for (0..bw) |xx| {
            var v: u8 = 0;
            const xa = if (xx >= R) xx - R else 0;
            const xb = @min(bw - 1, xx + R);
            for (xa..xb + 1) |q| v |= ink[yy * bw + q];
            near[yy * bw + xx] = v;
        }
    }
    const bgs = alloc.alloc(f64, n) catch return null;
    defer alloc.free(bgs);
    var n_bg: usize = 0;
    for (0..bh) |yy| {
        for (0..bw) |xx| {
            const ya = if (yy >= R) yy - R else 0;
            const yb = @min(bh - 1, yy + R);
            var v: u8 = 0;
            for (ya..yb + 1) |q| v |= near[q * bw + xx];
            if (v != 0) continue;
            bgs[n_bg] = wcagLuminance(im, (y0 + yy) * im.w + x0 + xx);
            n_bg += 1;
        }
    }
    const bg = bgs[0..n_bg];
    std.sort.pdq(f64, bg, {}, std.sort.asc(f64));
    return .{
        .fg = quantile(far, 0.5),
        .bg = if (n_bg > 0) quantile(bg, 0.5) else 0,
        .spread = if (n_bg > 0) quantile(bg, 0.98) - quantile(bg, 0.02) else 0,
        .n_ink = n_ink,
        .n_bg = n_bg,
        .t = @intCast(t),
    };
}

// ------------------------------------------------------------------ grids

pub fn adoptGrid(rows: usize, cols: usize, data: []f64) i64 {
    const id = grids.put(.{ .rows = rows, .cols = cols, .data = data });
    if (id == 0) {
        alloc.free(data);
        return fail("image: out of grid handles", .{});
    }
    return id;
}

/// A 1 x 256 grid of pixel counts per level; channel -1 reads BT.601 gray.
pub fn histogram(id: i64, channel: i64) i64 {
    const im = images.get(id) orelse return fail("image: no such image", .{});
    if (channel >= im.c) return fail("image: channel {d} of a {d}-channel image", .{ channel + 1, im.c });
    const hist = histogram256(im, channel);
    const data = alloc.alloc(f64, 256) catch return fail("image: out of memory", .{});
    for (hist, 0..) |c, i| data[i] = @floatFromInt(c);
    return adoptGrid(1, 256, data);
}

/// The pixels of one channel (or BT.601 gray, channel -1) as an h x w grid.
pub fn toGrid(id: i64, channel: i64) i64 {
    const im = images.get(id) orelse return fail("image: no such image", .{});
    if (channel >= im.c) return fail("image: channel {d} of a {d}-channel image", .{ channel + 1, im.c });
    const n = @as(usize, im.w) * im.h;
    const data = alloc.alloc(f64, n) catch return fail("image: out of memory", .{});
    var i: usize = 0;
    while (i < n) : (i += 1) {
        data[i] = @floatFromInt(if (channel < 0) grayOf(im, i) else im.px[i * im.c + @as(usize, @intCast(channel))]);
    }
    return adoptGrid(im.h, im.w, data);
}

/// A one-channel image from a grid: each value rounded and clamped to 0..255.
pub fn fromGrid(gid: i64) i64 {
    const g = grids.get(gid) orelse return fail("image: no such grid", .{});
    const out = newBlank(@intCast(g.cols), @intCast(g.rows), 1) orelse return fail("image: out of memory", .{});
    for (g.data, 0..) |v, i| out[i] = round8(v);
    return adopt(@intCast(g.cols), @intCast(g.rows), 1, out);
}

/// A one-channel image from a grid, its values mapped LINEARLY from
/// min..max onto 0..255 -- how a spectrum, a derivative or a depth map is made
/// visible. A flat grid becomes mid-gray (128).
pub fn fromGridScaled(gid: i64) i64 {
    const g = grids.get(gid) orelse return fail("image: no such grid", .{});
    var lo: f64 = std.math.inf(f64);
    var hi: f64 = -std.math.inf(f64);
    for (g.data) |v| {
        lo = @min(lo, v);
        hi = @max(hi, v);
    }
    const out = newBlank(@intCast(g.cols), @intCast(g.rows), 1) orelse return fail("image: out of memory", .{});
    for (g.data, 0..) |v, i| out[i] = if (hi > lo) round8((v - lo) * 255.0 / (hi - lo)) else 128;
    return adopt(@intCast(g.cols), @intCast(g.rows), 1, out);
}

pub fn getGrid(gid: i64) ?*Grid {
    return grids.get(gid);
}

pub fn freeGrid(gid: i64) i64 {
    const g = grids.release(gid) orelse return 0;
    alloc.free(g.data);
    return 1;
}

pub fn liveGrids() usize {
    return grids.live();
}

test "otsu splits two flat levels between them" {
    var px = [_]u8{ 40, 40, 40, 40, 200, 200, 200, 200 };
    const id = fromRaw(4, 2, 1, &px);
    defer _ = free(id);
    const t = otsu(id);
    try std.testing.expect(t >= 40 and t < 200);
}

test "rotate four quarters is the identity" {
    var px = [_]u8{ 1, 2, 3, 4, 5, 6 };
    const a = fromRaw(3, 2, 1, &px);
    const b = rotate(a, 1);
    try std.testing.expectEqual(@as(u32, 2), get(b).?.w);
    const c = rotate(b, 3);
    try std.testing.expectEqualSlices(u8, &px, get(c).?.px);
    _ = free(a);
    _ = free(b);
    _ = free(c);
}
