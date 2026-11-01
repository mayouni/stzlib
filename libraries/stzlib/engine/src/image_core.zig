//! image_core.zig -- the pixel kernels shared by every engine DLL that reads
//! images (IM1b of SOFTANZA_IMAGE_INTELLIGENCE.md).
//!
//! Pure: no codec, no handle table, no allocator but the caller's. Two DLLs
//! import it -- stz_image (the image plane) and stz_neural (the OCR pipeline)
//! -- so a gray level, a resize or a component means ONE thing in the engine.
//! Before IM1b the OCR pipeline held private copies, and gray alone was
//! computed three ways that disagreed on up to 31,731 of the 16,777,216
//! colours (measured 2026-11-01).
//!
//! A `Raw` is a view: w x h pixels of c bytes (1, 3 or 4), rows top-down,
//! tightly packed. Nothing here owns it.

const std = @import("std");

pub const Raw = struct {
    w: usize,
    h: usize,
    c: usize,
    px: []u8,
};

pub const RawConst = struct {
    w: usize,
    h: usize,
    c: usize,
    px: []const u8,

    pub inline fn at(self: RawConst, x: usize, y: usize) [*]const u8 {
        return self.px.ptr + (y * self.w + x) * self.c;
    }
};

pub fn view(r: Raw) RawConst {
    return .{ .w = r.w, .h = r.h, .c = r.c, .px = r.px };
}

// ------------------------------------------------------------------ gray

/// OpenCV 5's COLOR_RGB2GRAY, bit for bit: 15-bit coefficients with blue
/// taking the remainder so they sum to 2^15, rounded. Derived by search and
/// checked against cv2.cvtColor over ALL 16,777,216 colours (2026-11-01);
/// the textbook 14-bit form (4899/9617/1868) misses 43,864 of them.
pub inline fn gray(r: u8, g: u8, b: u8) u8 {
    const v: u32 = @as(u32, r) * 9798 + @as(u32, g) * 19235 + @as(u32, b) * 3735 + 16384;
    return @intCast(v >> 15);
}

/// The gray of every pixel into `out` (w*h bytes); a 1-channel view is copied.
pub fn toGray(src: RawConst, out: []u8) void {
    const n = src.w * src.h;
    if (src.c == 1) {
        @memcpy(out[0..n], src.px[0..n]);
        return;
    }
    var i: usize = 0;
    while (i < n) : (i += 1) {
        const p = src.px.ptr + i * src.c;
        out[i] = gray(p[0], p[1], p[2]);
    }
}

pub fn histogram(g: []const u8) [256]usize {
    var hist = [_]usize{0} ** 256;
    for (g) |v| hist[v] += 1;
    return hist;
}

// ------------------------------------------------------------------ geometry

/// Bilinear resize with half-pixel centres (OpenCV's INTER_LINEAR geometry),
/// rounded to 8 bits. This is the OCR pipeline's arithmetic, kept exactly:
/// it is the one the PP-OCR parity with onnxruntime was measured on.
pub fn resizeBilinear(src: RawConst, dst: Raw, scratch: std.mem.Allocator) !void {
    const dw = dst.w;
    const dh = dst.h;
    const c = src.c;
    const sx = @as(f64, @floatFromInt(src.w)) / @as(f64, @floatFromInt(dw));
    const sy = @as(f64, @floatFromInt(src.h)) / @as(f64, @floatFromInt(dh));
    const xs = try scratch.alloc(usize, dw * 2);
    defer scratch.free(xs);
    const xa = try scratch.alloc(f64, dw);
    defer scratch.free(xa);
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
            const o = dst.px.ptr + (y * dw + x) * c;
            for (0..c) |k| {
                const top = @as(f64, @floatFromInt(p00[k])) * (1 - a) + @as(f64, @floatFromInt(p10[k])) * a;
                const bot = @as(f64, @floatFromInt(p01[k])) * (1 - a) + @as(f64, @floatFromInt(p11[k])) * a;
                const v = top * (1 - b) + bot * b;
                o[k] = @intFromFloat(@min(255.0, @max(0.0, @round(v))));
            }
        }
    }
}

/// A w x h rectangle at (x0, y0), rows and columns clamped at the border
/// (OpenCV's BORDER_REPLICATE): it may start or end outside the image.
pub fn cropReplicate(src: RawConst, x0: i64, y0: i64, dst: Raw) void {
    const c = src.c;
    for (0..dst.h) |y| {
        const sy: usize = @intCast(std.math.clamp(y0 + @as(i64, @intCast(y)), 0, @as(i64, @intCast(src.h - 1))));
        for (0..dst.w) |x| {
            const sx: usize = @intCast(std.math.clamp(x0 + @as(i64, @intCast(x)), 0, @as(i64, @intCast(src.w - 1))));
            @memcpy(dst.px[(y * dst.w + x) * c ..][0..c], src.at(sx, sy)[0..c]);
        }
    }
}

/// `q` clockwise quarter turns (0..3); dst is h x w for an odd q. One
/// counter-clockwise turn (numpy's rot90) is q = 3.
pub fn quarterTurn(src: RawConst, q: u2, dst: Raw) void {
    const c = src.c;
    for (0..dst.h) |y| {
        for (0..dst.w) |x| {
            var sx: usize = x;
            var sy: usize = y;
            switch (q) {
                0 => {},
                1 => {
                    sx = y;
                    sy = src.h - 1 - x;
                },
                2 => {
                    sx = src.w - 1 - x;
                    sy = src.h - 1 - y;
                },
                3 => {
                    sx = src.w - 1 - y;
                    sy = x;
                },
            }
            @memcpy(dst.px[(y * dst.w + x) * c ..][0..c], src.at(sx, sy)[0..c]);
        }
    }
}

// ------------------------------------------------------------------ components

pub const Comp = struct {
    x0: usize,
    y0: usize,
    x1: usize,
    y1: usize,
    n: usize,
    sx: f64 = 0, // sums of x and y, for the centroid
    sy: f64 = 0,
};

pub const Select = union(enum) {
    below: u8, // pixels with gray < t (the OCR pipeline's ink)
    nonzero, // pixels with gray > 0 (OpenCV's foreground)
};

/// The connected components of the selected pixels, numbered in raster order
/// of each one's first pixel (8- or 4-connected). When `labels` is given
/// (w*h), it receives 0 for unselected pixels and 1.. per component.
pub fn components(a: std.mem.Allocator, g: []const u8, w: usize, h: usize, sel: Select, conn8: bool, labels: ?[]u32) ![]Comp {
    const lab = labels orelse try a.alloc(u32, w * h);
    defer if (labels == null) a.free(lab);
    @memset(lab, 0);
    var stack: std.ArrayList(u32) = .empty;
    defer stack.deinit(a);
    var out: std.ArrayList(Comp) = .empty;
    errdefer out.deinit(a);
    var next: u32 = 0;
    for (0..w * h) |start| {
        if (lab[start] != 0 or !selected(sel, g[start])) continue;
        next += 1;
        var cm = Comp{ .x0 = start % w, .y0 = start / w, .x1 = start % w, .y1 = start / w, .n = 0 };
        lab[start] = next;
        try stack.append(a, @intCast(start));
        while (stack.pop()) |p32| {
            const p: usize = p32;
            const px = p % w;
            const py = p / w;
            cm.n += 1;
            cm.sx += @floatFromInt(px);
            cm.sy += @floatFromInt(py);
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
                    if (!conn8 and xx != px and yy != py) continue;
                    const q = yy * w + xx;
                    if (lab[q] == 0 and selected(sel, g[q])) {
                        lab[q] = next;
                        try stack.append(a, @intCast(q));
                    }
                }
            }
        }
        try out.append(a, cm);
    }
    return out.toOwnedSlice(a);
}

inline fn selected(sel: Select, v: u8) bool {
    return switch (sel) {
        .below => |t| v < t,
        .nonzero => v > 0,
    };
}

// ------------------------------------------------------------------ BMP

/// A 24-bit BMP of the view (gray repeated, alpha dropped); caller frees.
pub fn bmp24(a: std.mem.Allocator, src: RawConst) ![]u8 {
    const row: usize = (src.w * 3 + 3) & ~@as(usize, 3);
    const size: usize = 54 + row * src.h;
    const out = try a.alloc(u8, size);
    @memset(out, 0);
    out[0] = 'B';
    out[1] = 'M';
    std.mem.writeInt(u32, out[2..6], @intCast(size), .little);
    std.mem.writeInt(u32, out[10..14], 54, .little);
    std.mem.writeInt(u32, out[14..18], 40, .little);
    std.mem.writeInt(i32, out[18..22], @intCast(src.w), .little);
    std.mem.writeInt(i32, out[22..26], @intCast(src.h), .little);
    std.mem.writeInt(u16, out[26..28], 1, .little);
    std.mem.writeInt(u16, out[28..30], 24, .little);
    std.mem.writeInt(u32, out[34..38], @intCast(row * src.h), .little);
    for (0..src.h) |y| {
        const dst = out[54 + (src.h - 1 - y) * row ..];
        for (0..src.w) |x| {
            const p = src.at(x, y);
            const r = p[0];
            const g = if (src.c >= 3) p[1] else r;
            const b = if (src.c >= 3) p[2] else r;
            dst[x * 3] = b;
            dst[x * 3 + 1] = g;
            dst[x * 3 + 2] = r;
        }
    }
    return out;
}

test "gray is OpenCV 5's formula at known points" {
    try std.testing.expectEqual(@as(u8, 23), gray(0, 1, 201)); // 23.501 rounds DOWN in OpenCV 5
    try std.testing.expectEqual(@as(u8, 76), gray(255, 0, 0));
    try std.testing.expectEqual(@as(u8, 150), gray(0, 255, 0));
    try std.testing.expectEqual(@as(u8, 29), gray(0, 0, 255));
    try std.testing.expectEqual(@as(u8, 255), gray(255, 255, 255));
}
