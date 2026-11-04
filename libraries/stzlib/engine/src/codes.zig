//! codes.zig -- the codes in a picture: QR and the common 1D barcodes (IM9c of SOFTANZA_IMAGE_INTELLIGENCE.md).
//!
//! QR is read by quirc (vendor/quirc, ISC, v1.2): finder patterns, perspective, the format and version, Reed-Solomon,
//! the data modes. A code quirc finds but cannot decode is tried once mirrored. The 1D symbologies are read natively
//! (codes_1d.zig: EAN-13, EAN-8, UPC-A, Code 128), by scanning at many angles and accepting only a read whose own
//! check digit agrees -- so a read is a statement, never a guess.
//!
//! What it returns is a LIST of codes, each its kind, its text (the bytes of the payload) and its place in the picture:
//! four corners for a QR (from the top left, clockwise) or the two ends of the scan line for a 1D code. Pixels are
//! 0-based here; the Ring face makes them 1-based like every Ring face. A picture with no code answers an empty list.

const std = @import("std");
const image = @import("image.zig");
const core = @import("image_core.zig");
const one = @import("codes_1d.zig");
const qr = @cImport({
    @cInclude("quirc.h");
});

const alloc = std.heap.c_allocator;

pub const Code = struct {
    kind: []const u8, // a static string: "qr", "ean13", "ean8", "upca", "code128"
    text: []u8, // owned
    pts: [8]f64 = [_]f64{0} ** 8,
    npts: u8 = 0, // 8 numbers (4 corners) for a QR, 4 (two ends) for a 1D code
};

pub fn freeAll(list: []Code) void {
    for (list) |c| alloc.free(c.text);
    alloc.free(list);
}

/// one quirc pass over a gray buffer; every code it decodes is added unless the same text is already there from
/// about the same place. `scale` is how many times larger this buffer is than the picture (corners are divided by it).
fn scanQrPass(gray: []const u8, w: usize, h: usize, scale: f64, out: *std.ArrayList(Code)) void {
    const q = qr.quirc_new() orelse return;
    defer qr.quirc_destroy(q);
    if (qr.quirc_resize(q, @intCast(w), @intCast(h)) < 0) return;
    const buf = qr.quirc_begin(q, null, null);
    @memcpy(buf[0 .. w * h], gray[0 .. w * h]);
    qr.quirc_end(q);
    const n: usize = @intCast(qr.quirc_count(q));
    var i: usize = 0;
    while (i < n) : (i += 1) {
        var code: qr.quirc_code = undefined;
        var data: qr.quirc_data = undefined;
        qr.quirc_extract(q, @intCast(i), &code);
        var err = qr.quirc_decode(&code, &data);
        if (err != qr.QUIRC_SUCCESS) {
            qr.quirc_flip(&code);
            err = qr.quirc_decode(&code, &data);
        }
        if (err != qr.QUIRC_SUCCESS) continue;
        const payload = data.payload[0..@intCast(data.payload_len)];
        var c = Code{ .kind = "qr", .text = undefined, .npts = 8 };
        var k: usize = 0;
        var cx: f64 = 0;
        var cy: f64 = 0;
        while (k < 4) : (k += 1) {
            c.pts[k * 2] = @as(f64, @floatFromInt(code.corners[k].x)) / scale;
            c.pts[k * 2 + 1] = @as(f64, @floatFromInt(code.corners[k].y)) / scale;
            cx += c.pts[k * 2] / 4;
            cy += c.pts[k * 2 + 1] / 4;
        }
        const side = @abs(c.pts[0] - c.pts[4]) + @abs(c.pts[1] - c.pts[5]);
        var dup = false;
        for (out.items) |o| {
            if (!std.mem.eql(u8, o.kind, "qr") or !std.mem.eql(u8, o.text, payload)) continue;
            const ox = (o.pts[0] + o.pts[2] + o.pts[4] + o.pts[6]) / 4;
            const oy = (o.pts[1] + o.pts[3] + o.pts[5] + o.pts[7]) / 4;
            if (@abs(ox - cx) + @abs(oy - cy) < side) dup = true;
        }
        if (dup) continue;
        c.text = alloc.dupe(u8, payload) catch continue;
        out.append(alloc, c) catch alloc.free(c.text);
    }
}

/// `f` times the size, bilinear: a code whose modules are 3 or 4 pixels gets modules quirc's geometry can measure
fn upscale(gray: []const u8, w: usize, h: usize, f: usize) ?[]u8 {
    const ff: f32 = @floatFromInt(f);
    const W = w * f;
    const H = h * f;
    const out = alloc.alloc(u8, W * H) catch return null;
    var y: usize = 0;
    while (y < H) : (y += 1) {
        const fy = @max(0.0, (@as(f32, @floatFromInt(y)) + 0.5) / ff - 0.5);
        const y0: usize = @min(h - 1, @as(usize, @intFromFloat(fy)));
        const y1 = @min(h - 1, y0 + 1);
        const ay = fy - @as(f32, @floatFromInt(y0));
        var x: usize = 0;
        while (x < W) : (x += 1) {
            const fx = @max(0.0, (@as(f32, @floatFromInt(x)) + 0.5) / ff - 0.5);
            const x0: usize = @min(w - 1, @as(usize, @intFromFloat(fx)));
            const x1 = @min(w - 1, x0 + 1);
            const ax = fx - @as(f32, @floatFromInt(x0));
            const a = @as(f32, @floatFromInt(gray[y0 * w + x0]));
            const b = @as(f32, @floatFromInt(gray[y0 * w + x1]));
            const c = @as(f32, @floatFromInt(gray[y1 * w + x0]));
            const d = @as(f32, @floatFromInt(gray[y1 * w + x1]));
            const v = (a * (1 - ax) + b * ax) * (1 - ay) + (c * (1 - ax) + d * ax) * ay;
            out[y * W + x] = @intFromFloat(@max(0.0, @min(255.0, v + 0.5)));
        }
    }
    return out;
}

/// unsharp mask: the picture plus twice its difference from a [1 2 1] x [1 2 1] blur -- a blurred code's edges back
fn sharpen(gray: []const u8, w: usize, h: usize) ?[]u8 {
    const out = alloc.alloc(u8, w * h) catch return null;
    var y: usize = 0;
    while (y < h) : (y += 1) {
        var x: usize = 0;
        while (x < w) : (x += 1) {
            var acc: f32 = 0;
            var dy: i32 = -1;
            while (dy <= 1) : (dy += 1) {
                var dx: i32 = -1;
                while (dx <= 1) : (dx += 1) {
                    const yy: usize = @intCast(@max(0, @min(@as(i32, @intCast(h)) - 1, @as(i32, @intCast(y)) + dy)));
                    const xx: usize = @intCast(@max(0, @min(@as(i32, @intCast(w)) - 1, @as(i32, @intCast(x)) + dx)));
                    const wgt: f32 = @floatFromInt((2 - @abs(dx)) * (2 - @abs(dy)));
                    acc += wgt * @as(f32, @floatFromInt(gray[yy * w + xx]));
                }
            }
            const blur = acc / 16.0;
            const g = @as(f32, @floatFromInt(gray[y * w + x]));
            out[y * w + x] = @intFromFloat(@max(0.0, @min(255.0, g + 2.0 * (g - blur) + 0.5)));
        }
    }
    return out;
}

/// The QR codes of a picture, read in passes whose results are MERGED: as it is, sharpened, at 2 and 3 times the size, plain
/// and sharpened. A code any pass decodes is returned once; a pass never removes what another found. The enlarged passes are
/// skipped for a picture too large to enlarge cheaply (the plain and sharpened passes still run).
fn scanQr(gray: []const u8, w: usize, h: usize, out: *std.ArrayList(Code)) void {
    scanQrPass(gray, w, h, 1.0, out);
    const sh = sharpen(gray, w, h);
    defer if (sh) |x| alloc.free(x);
    if (sh) |x| scanQrPass(x, w, h, 1.0, out);
    const factors = [_]usize{ 2, 3 };
    for (factors) |f| {
        if (w * h * f * f > 12_000_000) break;
        if (upscale(gray, w, h, f)) |big| {
            defer alloc.free(big);
            scanQrPass(big, w * f, h * f, @floatFromInt(f), out);
        }
        if (sh) |x| {
            if (upscale(x, w, h, f)) |big| {
                defer alloc.free(big);
                scanQrPass(big, w * f, h * f, @floatFromInt(f), out);
            }
        }
    }
}

/// the point lies inside the quadrilateral of four corners (convex, either winding)
fn insideQuad(px: f64, py: f64, pts: [8]f64) bool {
    var pos: usize = 0;
    var neg: usize = 0;
    var k: usize = 0;
    while (k < 4) : (k += 1) {
        const ax = pts[k * 2];
        const ay = pts[k * 2 + 1];
        const bx = pts[((k + 1) % 4) * 2];
        const by = pts[((k + 1) % 4) * 2 + 1];
        const cr = (bx - ax) * (py - ay) - (by - ay) * (px - ax);
        if (cr > 0) pos += 1;
        if (cr < 0) neg += 1;
    }
    return pos == 0 or neg == 0;
}

/// Every code the picture holds, or null for a handle that is not an image. The caller frees with freeAll.
pub fn scan(id: i64) ?[]Code {
    const im = image.get(id) orelse return null;
    const w: usize = im.w;
    const h: usize = im.h;
    const gray = alloc.alloc(u8, w * h) catch return null;
    defer alloc.free(gray);
    core.toGray(core.view(.{ .w = w, .h = h, .c = @as(usize, im.c), .px = im.px }), gray);
    var list: std.ArrayList(Code) = .{};
    scanQr(gray, w, h, &list);
    var bars: std.ArrayList(one.Hit) = .{};
    defer bars.deinit(alloc);
    one.scan(gray, w, h, &bars);
    for (bars.items) |b| {
        // a QR's rows look like bars: a 1D read whose ends both lie inside a decoded QR is a part of that QR, not a code
        var inside = false;
        for (list.items) |q| {
            if (std.mem.eql(u8, q.kind, "qr") and insideQuad(b.x0, b.y0, q.pts) and insideQuad(b.x1, b.y1, q.pts)) inside = true;
        }
        if (inside) {
            alloc.free(b.text);
            continue;
        }
        var c = Code{ .kind = b.kind, .text = b.text, .npts = 4 };
        c.pts[0] = b.x0;
        c.pts[1] = b.y0;
        c.pts[2] = b.x1;
        c.pts[3] = b.y1;
        list.append(alloc, c) catch alloc.free(b.text);
    }
    return list.toOwnedSlice(alloc) catch null;
}
