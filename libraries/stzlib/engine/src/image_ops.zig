//! image_ops.zig -- the image plane's analysis operations (IM1).
//!
//! SOFTANZA_IMAGE_INTELLIGENCE.md IM1 / SOFTANZA_VISION_PLAN.md V2: morphology,
//! median, histogram equalisation, Sobel/Scharr, Canny, adaptive and Sauvola
//! thresholds, integral images, template matching, connected components with
//! statistics, and the 2D FFT. Each one copies OpenCV's convention (OpenCV is
//! the oracle, `base/test/image/_rig/oracle_opencv.py`), named at the function.
//! Images are read through BT.601 gray where an operation is defined on gray.

const std = @import("std");
const img = @import("image.zig");
const fft = @import("fft.zig");
const core = @import("image_core.zig");

const alloc = std.heap.c_allocator;
const Image = img.Image;

fn grayPlane(im: *const Image) ?[]u8 {
    const n = @as(usize, im.w) * im.h;
    const g = alloc.alloc(u8, n) catch return null;
    var i: usize = 0;
    while (i < n) : (i += 1) g[i] = img.grayOf(im, i);
    return g;
}

fn clampIdx(i: i64, n: i64) usize {
    return @intCast(@max(0, @min(n - 1, i)));
}

// ------------------------------------------------------------------ morphology

pub const Shape = enum(u8) { rect = 0, cross = 1, ellipse = 2 };

/// OpenCV's getStructuringElement(shape, (k, k)) as a k*k mask.
fn structuring(shape: Shape, k: usize, mask: []bool) void {
    @memset(mask, false);
    const r: i64 = @intCast(k / 2);
    switch (shape) {
        .rect => @memset(mask, true),
        .cross => {
            var i: usize = 0;
            while (i < k) : (i += 1) {
                mask[@as(usize, @intCast(r)) * k + i] = true;
                mask[i * k + @as(usize, @intCast(r))] = true;
            }
        },
        .ellipse => {
            const inv_r2: f64 = if (r > 0) 1.0 / @as(f64, @floatFromInt(r * r)) else 0;
            var i: i64 = 0;
            while (i < @as(i64, @intCast(k))) : (i += 1) {
                const dy = i - r;
                var j1: i64 = 0;
                var j2: i64 = 0;
                if (@abs(dy) <= r) {
                    const v = @as(f64, @floatFromInt(r)) * @sqrt(@as(f64, @floatFromInt(r * r - dy * dy)) * inv_r2);
                    const dx: i64 = @intFromFloat(@round(v));
                    j1 = @max(r - dx, 0);
                    j2 = @min(r + dx + 1, @as(i64, @intCast(k)));
                }
                var j = j1;
                while (j < j2) : (j += 1) mask[@as(usize, @intCast(i)) * k + @as(usize, @intCast(j))] = true;
            }
        },
    }
}

/// One erosion (min) or dilation (max) pass; pixels outside the image are
/// IGNORED -- OpenCV's default border value for morphology means exactly that.
fn morphPass(im: *const Image, src: []const u8, dst: []u8, mask: []const bool, k: usize, dilate: bool) void {
    const r: i64 = @intCast(k / 2);
    const W: i64 = im.w;
    const H: i64 = im.h;
    var y: i64 = 0;
    while (y < H) : (y += 1) {
        var x: i64 = 0;
        while (x < W) : (x += 1) {
            var ch: usize = 0;
            while (ch < im.c) : (ch += 1) {
                var best: u8 = if (dilate) 0 else 255;
                var dy: i64 = -r;
                while (dy <= r) : (dy += 1) {
                    const yy = y + dy;
                    if (yy < 0 or yy >= H) continue;
                    var dx: i64 = -r;
                    while (dx <= r) : (dx += 1) {
                        if (!mask[@as(usize, @intCast(dy + r)) * k + @as(usize, @intCast(dx + r))]) continue;
                        const xx = x + dx;
                        if (xx < 0 or xx >= W) continue;
                        const v = src[(@as(usize, @intCast(yy)) * im.w + @as(usize, @intCast(xx))) * im.c + ch];
                        best = if (dilate) @max(best, v) else @min(best, v);
                    }
                }
                dst[(@as(usize, @intCast(y)) * im.w + @as(usize, @intCast(x))) * im.c + ch] = best;
            }
        }
    }
}

pub const MorphOp = enum(u8) { erode = 0, dilate = 1, open = 2, close = 3, gradient = 4, tophat = 5, blackhat = 6 };

/// cv2.morphologyEx(op, getStructuringElement(shape, (k, k))), one iteration.
pub fn morph(id: i64, op: MorphOp, shape: Shape, k: u32) i64 {
    const im = img.get(id) orelse return img.fail("image: no such image", .{});
    if (k < 1 or k % 2 == 0 or k > 255) return img.fail("image: a morphology kernel is odd, 1..255, not {d}", .{k});
    const n = im.px.len;
    const mask = alloc.alloc(bool, @as(usize, k) * k) catch return img.fail("image: out of memory", .{});
    defer alloc.free(mask);
    structuring(shape, k, mask);
    const a = alloc.alloc(u8, n) catch return img.fail("image: out of memory", .{});
    const b = alloc.alloc(u8, n) catch {
        alloc.free(a);
        return img.fail("image: out of memory", .{});
    };
    defer alloc.free(b);
    switch (op) {
        .erode => morphPass(im, im.px, a, mask, k, false),
        .dilate => morphPass(im, im.px, a, mask, k, true),
        .open => {
            morphPass(im, im.px, b, mask, k, false);
            morphPass(im, b, a, mask, k, true);
        },
        .close => {
            morphPass(im, im.px, b, mask, k, true);
            morphPass(im, b, a, mask, k, false);
        },
        .gradient => {
            morphPass(im, im.px, a, mask, k, true);
            morphPass(im, im.px, b, mask, k, false);
            for (a, b) |*x, y| x.* = x.* - y;
        },
        .tophat => {
            morphPass(im, im.px, b, mask, k, false);
            morphPass(im, b, a, mask, k, true);
            for (a, im.px) |*x, s| x.* = s -| x.*;
        },
        .blackhat => {
            morphPass(im, im.px, b, mask, k, true);
            morphPass(im, b, a, mask, k, false);
            for (a, im.px) |*x, s| x.* = x.* -| s;
        },
    }
    return img.adopt(im.w, im.h, im.c, a);
}

/// cv2.medianBlur(k): the median of the k*k window, border REPLICATE.
pub fn median(id: i64, k: u32) i64 {
    const im = img.get(id) orelse return img.fail("image: no such image", .{});
    if (k < 1 or k % 2 == 0 or k > 255) return img.fail("image: a median window is odd, 1..255, not {d}", .{k});
    const out = alloc.alloc(u8, im.px.len) catch return img.fail("image: out of memory", .{});
    const r: i64 = @intCast(k / 2);
    const half: u32 = (k * k) / 2;
    const W: i64 = im.w;
    const H: i64 = im.h;
    var y: i64 = 0;
    while (y < H) : (y += 1) {
        var x: i64 = 0;
        while (x < W) : (x += 1) {
            var ch: usize = 0;
            while (ch < im.c) : (ch += 1) {
                var hist = [_]u32{0} ** 256;
                var dy: i64 = -r;
                while (dy <= r) : (dy += 1) {
                    const yy = clampIdx(y + dy, H);
                    var dx: i64 = -r;
                    while (dx <= r) : (dx += 1) {
                        const xx = clampIdx(x + dx, W);
                        hist[im.px[(yy * im.w + xx) * im.c + ch]] += 1;
                    }
                }
                var acc: u32 = 0;
                var v: usize = 0;
                while (v < 256) : (v += 1) {
                    acc += hist[v];
                    if (acc > half) break;
                }
                out[(@as(usize, @intCast(y)) * im.w + @as(usize, @intCast(x))) * im.c + ch] = @intCast(@min(v, 255));
            }
        }
    }
    return img.adopt(im.w, im.h, im.c, out);
}

/// cv2.equalizeHist on the gray: lut[j] = round(cdf'(j) * 255 / (N - h[first])).
pub fn equalize(id: i64) i64 {
    const im = img.get(id) orelse return img.fail("image: no such image", .{});
    const g = grayPlane(im) orelse return img.fail("image: out of memory", .{});
    var hist = [_]u64{0} ** 256;
    for (g) |v| hist[v] += 1;
    var first: usize = 0;
    while (first < 255 and hist[first] == 0) first += 1;
    const total: u64 = g.len;
    var lut = [_]u8{0} ** 256;
    if (hist[first] == total) {
        for (&lut, 0..) |*l, i| l.* = @intCast(i);
    } else {
        const scale: f64 = 255.0 / @as(f64, @floatFromInt(total - hist[first]));
        var sum: u64 = 0;
        var j = first + 1;
        while (j < 256) : (j += 1) {
            sum += hist[j];
            lut[j] = img.round8(@as(f64, @floatFromInt(sum)) * scale);
        }
    }
    for (g) |*v| v.* = lut[v.*];
    return img.adopt(im.w, im.h, 1, g);
}

// ------------------------------------------------------------------ derivatives

/// The gray's first derivative as a grid: Sobel 3x3 (smooth 1 2 1) or Scharr
/// (smooth 3 10 3), dx/dy in {0,1}, border REFLECT_101 (cv2.Sobel / cv2.Scharr
/// with ddepth CV_64F).
fn derivative(g: []const u8, w: u32, h: u32, dx: u32, dy: u32, scharr: bool, replicate: bool, out: []f64) void {
    const sm = if (scharr) [3]f64{ 3, 10, 3 } else [3]f64{ 1, 2, 1 };
    const de = [3]f64{ -1, 0, 1 };
    const kx = if (dx == 1) de else sm;
    const ky = if (dy == 1) de else sm;
    const W: i64 = w;
    const H: i64 = h;
    var y: i64 = 0;
    while (y < H) : (y += 1) {
        var x: i64 = 0;
        while (x < W) : (x += 1) {
            var acc: f64 = 0;
            var j: i64 = -1;
            while (j <= 1) : (j += 1) {
                const yy = if (replicate) clampIdx(y + j, H) else img.reflect101(y + j, H);
                var i: i64 = -1;
                while (i <= 1) : (i += 1) {
                    const xx = if (replicate) clampIdx(x + i, W) else img.reflect101(x + i, W);
                    acc += ky[@intCast(j + 1)] * kx[@intCast(i + 1)] * @as(f64, @floatFromInt(g[yy * w + xx]));
                }
            }
            out[@as(usize, @intCast(y)) * w + @as(usize, @intCast(x))] = acc;
        }
    }
}

pub fn sobel(id: i64, dx: u32, dy: u32, scharr: bool) i64 {
    const im = img.get(id) orelse return img.fail("image: no such image", .{});
    if (dx > 1 or dy > 1 or dx + dy == 0) return img.fail("image: a first derivative takes dx, dy in 0..1, not both 0", .{});
    if (scharr and dx + dy != 1) return img.fail("image: Scharr is one direction at a time", .{});
    const g = grayPlane(im) orelse return img.fail("image: out of memory", .{});
    defer alloc.free(g);
    const out = alloc.alloc(f64, g.len) catch return img.fail("image: out of memory", .{});
    derivative(g, im.w, im.h, dx, dy, scharr, false, out);
    return img.adoptGrid(im.h, im.w, out);
}

/// cv2.Canny(gray, low, high, apertureSize 3, L2gradient), on its own terms:
/// Sobel with BORDER_REPLICATE, magnitude |dx|+|dy| (or dx^2+dy^2 against the
/// squared thresholds), non-maximum suppression with OpenCV's fixed-point
/// tangent tests and its ">" toward the previous neighbour, ">=" toward the
/// next, zero magnitude outside the image, then 8-connected hysteresis.
pub fn canny(id: i64, low_in: f64, high_in: f64, l2: bool) i64 {
    const im = img.get(id) orelse return img.fail("image: no such image", .{});
    var low = low_in;
    var high = high_in;
    if (low > high) std.mem.swap(f64, &low, &high);
    const g = grayPlane(im) orelse return img.fail("image: out of memory", .{});
    defer alloc.free(g);
    const n = g.len;
    const W: usize = im.w;
    const H: usize = im.h;
    const gx = alloc.alloc(f64, n) catch return img.fail("image: out of memory", .{});
    defer alloc.free(gx);
    const gy = alloc.alloc(f64, n) catch return img.fail("image: out of memory", .{});
    defer alloc.free(gy);
    derivative(g, im.w, im.h, 1, 0, false, true, gx);
    derivative(g, im.w, im.h, 0, 1, false, true, gy);
    const mag = alloc.alloc(i64, n) catch return img.fail("image: out of memory", .{});
    defer alloc.free(mag);
    var lo: i64 = @intFromFloat(@floor(low));
    var hi: i64 = @intFromFloat(@floor(high));
    if (l2) {
        // OpenCV clamps to 32767 and squares the thresholds
        lo = @intFromFloat(@floor(@min(low, 32767) * @min(low, 32767)));
        hi = @intFromFloat(@floor(@min(high, 32767) * @min(high, 32767)));
    }
    for (mag, gx, gy) |*m, a, b| {
        const ia: i64 = @intFromFloat(a);
        const ib: i64 = @intFromFloat(b);
        m.* = if (l2) ia * ia + ib * ib else @as(i64, @intCast(@abs(ia))) + @as(i64, @intCast(@abs(ib)));
    }
    // 0 = not an edge, 1 = weak candidate, 2 = strong
    const st = alloc.alloc(u8, n) catch return img.fail("image: out of memory", .{});
    defer alloc.free(st);
    @memset(st, 0);
    const TG22: i64 = 13573; // (int)(tan(22.5 deg) * 2^15 + 0.5)
    const M = struct {
        fn at(mg: []const i64, w: usize, h: usize, x: i64, y: i64) i64 {
            if (x < 0 or y < 0 or x >= @as(i64, @intCast(w)) or y >= @as(i64, @intCast(h))) return 0;
            return mg[@as(usize, @intCast(y)) * w + @as(usize, @intCast(x))];
        }
    };
    var y: usize = 0;
    while (y < H) : (y += 1) {
        var x: usize = 0;
        while (x < W) : (x += 1) {
            const i = y * W + x;
            const m = mag[i];
            if (m <= lo) continue;
            const xs: i64 = @intFromFloat(gx[i]);
            const ys: i64 = @intFromFloat(gy[i]);
            const ax: i64 = @intCast(@abs(xs));
            const ay: i64 = @as(i64, @intCast(@abs(ys))) << 15;
            const tg22x = ax * TG22;
            const X: i64 = @intCast(x);
            const Y: i64 = @intCast(y);
            var keep = false;
            if (ay < tg22x) {
                keep = m > M.at(mag, W, H, X - 1, Y) and m >= M.at(mag, W, H, X + 1, Y);
            } else {
                const tg67x = tg22x + (ax << 16);
                if (ay > tg67x) {
                    keep = m > M.at(mag, W, H, X, Y - 1) and m >= M.at(mag, W, H, X, Y + 1);
                } else {
                    const s: i64 = if ((xs ^ ys) < 0) -1 else 1;
                    keep = m > M.at(mag, W, H, X - s, Y - 1) and m > M.at(mag, W, H, X + s, Y + 1);
                }
            }
            if (keep) st[i] = if (m > hi) 2 else 1;
        }
    }
    // hysteresis: grow strong pixels into 8-connected weak ones
    var stack: std.ArrayList(usize) = .{};
    defer stack.deinit(alloc);
    var iseed: usize = 0;
    while (iseed < n) : (iseed += 1) {
        if (st[iseed] == 2) stack.append(alloc, iseed) catch return img.fail("image: out of memory", .{});
    }
    while (stack.pop()) |i| {
        const cx: i64 = @intCast(i % W);
        const cy: i64 = @intCast(i / W);
        var dy: i64 = -1;
        while (dy <= 1) : (dy += 1) {
            var dx: i64 = -1;
            while (dx <= 1) : (dx += 1) {
                const nx = cx + dx;
                const ny = cy + dy;
                if (nx < 0 or ny < 0 or nx >= @as(i64, @intCast(W)) or ny >= @as(i64, @intCast(H))) continue;
                const j = @as(usize, @intCast(ny)) * W + @as(usize, @intCast(nx));
                if (st[j] == 1) {
                    st[j] = 2;
                    stack.append(alloc, j) catch return img.fail("image: out of memory", .{});
                }
            }
        }
    }
    const out = alloc.alloc(u8, n) catch return img.fail("image: out of memory", .{});
    for (out, st) |*o, s| o.* = if (s == 2) 255 else 0;
    return img.adopt(im.w, im.h, 1, out);
}

// ------------------------------------------------------------------ integral / local thresholds

/// cv2.integral of the gray: an (h+1) x (w+1) grid, S(y, x) = sum of the
/// pixels above and left of (x, y); row 0 and column 0 are 0.
fn integralOf(g: []const u8, w: usize, h: usize, sq: bool, out: []f64) void {
    @memset(out[0 .. w + 1], 0);
    var y: usize = 0;
    while (y < h) : (y += 1) {
        out[(y + 1) * (w + 1)] = 0;
        var row: f64 = 0;
        var x: usize = 0;
        while (x < w) : (x += 1) {
            const v: f64 = @floatFromInt(g[y * w + x]);
            row += if (sq) v * v else v;
            out[(y + 1) * (w + 1) + x + 1] = out[y * (w + 1) + x + 1] + row;
        }
    }
}

pub fn integral(id: i64) i64 {
    const im = img.get(id) orelse return img.fail("image: no such image", .{});
    const g = grayPlane(im) orelse return img.fail("image: out of memory", .{});
    defer alloc.free(g);
    const out = alloc.alloc(f64, (@as(usize, im.w) + 1) * (@as(usize, im.h) + 1)) catch return img.fail("image: out of memory", .{});
    integralOf(g, im.w, im.h, false, out);
    return img.adoptGrid(@as(usize, im.h) + 1, @as(usize, im.w) + 1, out);
}

/// Window sum through an integral image of the REPLICATE-padded gray.
const Padded = struct {
    w: usize,
    r: usize,
    s: []f64,
    q: []f64,

    fn make(g: []const u8, w: usize, h: usize, r: usize) ?Padded {
        const pw = w + 2 * r;
        const ph = h + 2 * r;
        const pg = alloc.alloc(u8, pw * ph) catch return null;
        defer alloc.free(pg);
        var y: usize = 0;
        while (y < ph) : (y += 1) {
            var x: usize = 0;
            while (x < pw) : (x += 1) {
                const sy = clampIdx(@as(i64, @intCast(y)) - @as(i64, @intCast(r)), @intCast(h));
                const sx = clampIdx(@as(i64, @intCast(x)) - @as(i64, @intCast(r)), @intCast(w));
                pg[y * pw + x] = g[sy * w + sx];
            }
        }
        const s = alloc.alloc(f64, (pw + 1) * (ph + 1)) catch return null;
        const q = alloc.alloc(f64, (pw + 1) * (ph + 1)) catch {
            alloc.free(s);
            return null;
        };
        integralOf(pg, pw, ph, false, s);
        integralOf(pg, pw, ph, true, q);
        return .{ .w = pw, .r = r, .s = s, .q = q };
    }

    fn free(self: Padded) void {
        alloc.free(self.s);
        alloc.free(self.q);
    }

    // sum over the (2r+1)^2 window centred on (x, y) of the ORIGINAL image
    fn sum(self: Padded, t: []const f64, x: usize, y: usize) f64 {
        const k = 2 * self.r + 1;
        const W1 = self.w + 1;
        return t[(y + k) * W1 + x + k] - t[y * W1 + x + k] - t[(y + k) * W1 + x] + t[y * W1 + x];
    }
};

/// cv2.adaptiveThreshold(gray, 255, ADAPTIVE_THRESH_MEAN_C, THRESH_BINARY,
/// block, C): the local mean is OpenCV's boxFilter into 8 bits (rounded),
/// border REPLICATE, and a pixel is 255 when src - mean > -ceil(C).
pub fn adaptiveMean(id: i64, block: u32, c: f64) i64 {
    const im = img.get(id) orelse return img.fail("image: no such image", .{});
    if (block < 3 or block % 2 == 0) return img.fail("image: an adaptive block is odd and >= 3, not {d}", .{block});
    const g = grayPlane(im) orelse return img.fail("image: out of memory", .{});
    defer alloc.free(g);
    const r: usize = block / 2;
    const P = Padded.make(g, im.w, im.h, r) orelse return img.fail("image: out of memory", .{});
    defer P.free();
    const area: f64 = @floatFromInt(@as(usize, block) * block);
    const idelta: i64 = @intFromFloat(@ceil(c));
    const out = alloc.alloc(u8, g.len) catch return img.fail("image: out of memory", .{});
    var y: usize = 0;
    while (y < im.h) : (y += 1) {
        var x: usize = 0;
        while (x < im.w) : (x += 1) {
            const mean: i64 = img.round8(P.sum(P.s, x, y) / area);
            const s: i64 = g[y * im.w + x];
            out[y * im.w + x] = if (s - mean > -idelta) 255 else 0;
        }
    }
    return img.adopt(im.w, im.h, 1, out);
}

/// Sauvola: T = m * (1 + k * (s / R - 1)) over a block x block window (mean m,
/// population standard deviation s, border REPLICATE); 255 where gray > T.
pub fn sauvola(id: i64, block: u32, k: f64, R: f64) i64 {
    const im = img.get(id) orelse return img.fail("image: no such image", .{});
    if (block < 3 or block % 2 == 0) return img.fail("image: a Sauvola window is odd and >= 3, not {d}", .{block});
    if (!(R > 0)) return img.fail("image: Sauvola's R is > 0", .{});
    const g = grayPlane(im) orelse return img.fail("image: out of memory", .{});
    defer alloc.free(g);
    const P = Padded.make(g, im.w, im.h, block / 2) orelse return img.fail("image: out of memory", .{});
    defer P.free();
    const area: f64 = @floatFromInt(@as(usize, block) * block);
    const out = alloc.alloc(u8, g.len) catch return img.fail("image: out of memory", .{});
    var y: usize = 0;
    while (y < im.h) : (y += 1) {
        var x: usize = 0;
        while (x < im.w) : (x += 1) {
            const m = P.sum(P.s, x, y) / area;
            const v = @max(0, P.sum(P.q, x, y) / area - m * m);
            const t = m * (1 + k * (@sqrt(v) / R - 1));
            out[y * im.w + x] = if (@as(f64, @floatFromInt(g[y * im.w + x])) > t) 255 else 0;
        }
    }
    return img.adopt(im.w, im.h, 1, out);
}

// ------------------------------------------------------------------ template matching

/// cv2.matchTemplate(gray, tmpl, TM_CCOEFF_NORMED): an (H-h+1) x (W-w+1) grid
/// of normalised correlation in -1..1; a flat window (no variance) scores 0
/// unless the template is flat too, then 1.
pub fn matchTemplate(id: i64, tid: i64) i64 {
    const im = img.get(id) orelse return img.fail("image: no such image", .{});
    const tm = img.get(tid) orelse return img.fail("image: no such template", .{});
    if (tm.w > im.w or tm.h > im.h) return img.fail("image: the template ({d}x{d}) is larger than the image ({d}x{d})", .{ tm.w, tm.h, im.w, im.h });
    const g = grayPlane(im) orelse return img.fail("image: out of memory", .{});
    defer alloc.free(g);
    const t = grayPlane(tm) orelse return img.fail("image: out of memory", .{});
    defer alloc.free(t);
    const tw: usize = tm.w;
    const th: usize = tm.h;
    const tn: f64 = @floatFromInt(tw * th);
    var tmean: f64 = 0;
    for (t) |v| tmean += @floatFromInt(v);
    tmean /= tn;
    var tvar: f64 = 0;
    const tz = alloc.alloc(f64, t.len) catch return img.fail("image: out of memory", .{});
    defer alloc.free(tz);
    for (t, tz) |v, *z| {
        z.* = @as(f64, @floatFromInt(v)) - tmean;
        tvar += z.* * z.*;
    }
    const ow = @as(usize, im.w) - tw + 1;
    const oh = @as(usize, im.h) - th + 1;
    const out = alloc.alloc(f64, ow * oh) catch return img.fail("image: out of memory", .{});
    var y: usize = 0;
    while (y < oh) : (y += 1) {
        var x: usize = 0;
        while (x < ow) : (x += 1) {
            var s: f64 = 0;
            var s2: f64 = 0;
            var cr: f64 = 0;
            var j: usize = 0;
            while (j < th) : (j += 1) {
                var i: usize = 0;
                while (i < tw) : (i += 1) {
                    const v: f64 = @floatFromInt(g[(y + j) * im.w + x + i]);
                    s += v;
                    s2 += v * v;
                    cr += v * tz[j * tw + i];
                }
            }
            const wvar = s2 - s * s / tn;
            const den = @sqrt(@max(0, wvar) * tvar);
            out[y * ow + x] = if (den > 1e-9) cr / den else (if (tvar < 1e-9 and wvar < 1e-9) 1 else 0);
        }
    }
    return img.adoptGrid(oh, ow, out);
}

// ------------------------------------------------------------------ components

/// Connected components of the NONZERO gray pixels (cv2.connectedComponents-
/// WithStats, connectivity 4 or 8). Labels are numbered in raster order of
/// each component's first pixel. Returns the labels grid (0 = background);
/// `stats_out` receives a grid of one row per component:
/// left, top (1-based), width, height, area, centroid x, centroid y (1-based).
pub fn components(id: i64, conn8: bool, stats_out: *i64) i64 {
    stats_out.* = 0;
    const im = img.get(id) orelse return img.fail("image: no such image", .{});
    const W: usize = im.w;
    const H: usize = im.h;
    const n = W * H;
    const g = grayPlane(im) orelse return img.fail("image: out of memory", .{});
    defer alloc.free(g);
    const lab = alloc.alloc(u32, n) catch return img.fail("image: out of memory", .{});
    defer alloc.free(lab);
    const comps = core.components(alloc, g, W, H, .nonzero, conn8, lab) catch return img.fail("image: out of memory", .{});
    defer alloc.free(comps);
    const lg = alloc.alloc(f64, n) catch return img.fail("image: out of memory", .{});
    for (lg, lab) |*o, l| o.* = @floatFromInt(l);
    const sg = alloc.alloc(f64, @max(1, comps.len) * 7) catch {
        alloc.free(lg);
        return img.fail("image: out of memory", .{});
    };
    @memset(sg, 0);
    for (comps, 0..) |s, k| {
        const a: f64 = @floatFromInt(s.n);
        sg[k * 7 + 0] = @floatFromInt(s.x0 + 1);
        sg[k * 7 + 1] = @floatFromInt(s.y0 + 1);
        sg[k * 7 + 2] = @floatFromInt(s.x1 - s.x0 + 1);
        sg[k * 7 + 3] = @floatFromInt(s.y1 - s.y0 + 1);
        sg[k * 7 + 4] = a;
        sg[k * 7 + 5] = s.sx / a + 1;
        sg[k * 7 + 6] = s.sy / a + 1;
    }
    stats_out.* = img.adoptGrid(comps.len, 7, sg);
    return img.adoptGrid(H, W, lg);
}

// ------------------------------------------------------------------ 2D FFT

/// |FFT2(gray)| as an h x w grid -- numpy.abs(numpy.fft.fft2(gray)), with the
/// zero frequency moved to the centre when `shift` (numpy.fft.fftshift). Any
/// size: fft.zig is exact for every length (Bluestein when not a power of two).
pub fn fft2(id: i64, shift: bool, log: bool) i64 {
    const im = img.get(id) orelse return img.fail("image: no such image", .{});
    const W: usize = im.w;
    const H: usize = im.h;
    const n = W * H;
    const re = alloc.alloc(f64, n) catch return img.fail("image: out of memory", .{});
    defer alloc.free(re);
    const imv = alloc.alloc(f64, n) catch return img.fail("image: out of memory", .{});
    defer alloc.free(imv);
    var i: usize = 0;
    while (i < n) : (i += 1) {
        re[i] = @floatFromInt(img.grayOf(im, i));
        imv[i] = 0;
    }
    var y: usize = 0;
    while (y < H) : (y += 1) fft.transform(alloc, re[y * W ..][0..W], imv[y * W ..][0..W], false) catch return img.fail("image: out of memory", .{});
    const cr = alloc.alloc(f64, H) catch return img.fail("image: out of memory", .{});
    defer alloc.free(cr);
    const ci = alloc.alloc(f64, H) catch return img.fail("image: out of memory", .{});
    defer alloc.free(ci);
    var x: usize = 0;
    while (x < W) : (x += 1) {
        y = 0;
        while (y < H) : (y += 1) {
            cr[y] = re[y * W + x];
            ci[y] = imv[y * W + x];
        }
        fft.transform(alloc, cr, ci, false) catch return img.fail("image: out of memory", .{});
        y = 0;
        while (y < H) : (y += 1) {
            re[y * W + x] = cr[y];
            imv[y * W + x] = ci[y];
        }
    }
    const out = alloc.alloc(f64, n) catch return img.fail("image: out of memory", .{});
    y = 0;
    while (y < H) : (y += 1) {
        x = 0;
        while (x < W) : (x += 1) {
            const sy = if (shift) (y + H - H / 2) % H else y;
            const sx = if (shift) (x + W - W / 2) % W else x;
            const k = sy * W + sx;
            const m = @sqrt(re[k] * re[k] + imv[k] * imv[k]);
            out[y * W + x] = if (log) @log(1 + m) else m;
        }
    }
    return img.adoptGrid(H, W, out);
}

/// [row, column, value] of a grid's largest value, 1-based; the first on a tie.
pub fn gridArgMax(gid: i64, out: *[3]f64) bool {
    const g = img.getGrid(gid) orelse return false;
    var best: usize = 0;
    for (g.data, 0..) |v, i| {
        if (v > g.data[best]) best = i;
    }
    out.* = .{ @floatFromInt(best / g.cols + 1), @floatFromInt(best % g.cols + 1), g.data[best] };
    return true;
}

/// How two images of one size and channel count differ: [pixels that differ
/// in any channel, largest absolute channel difference, mean absolute channel
/// difference, mean squared channel difference]. False when they cannot be
/// compared (missing, or of different shapes).
pub fn compare(a: i64, b: i64, out: *[4]f64) bool {
    const x = img.get(a) orelse return false;
    const y = img.get(b) orelse return false;
    if (x.w != y.w or x.h != y.h or x.c != y.c) return false;
    const n = @as(usize, x.w) * x.h;
    var npx: usize = 0;
    var mx: u32 = 0;
    var sum: f64 = 0;
    var sq: f64 = 0;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        var differs = false;
        var k: usize = 0;
        while (k < x.c) : (k += 1) {
            const d: u32 = @abs(@as(i32, x.px[i * x.c + k]) - @as(i32, y.px[i * x.c + k]));
            if (d != 0) differs = true;
            mx = @max(mx, d);
            sum += @floatFromInt(d);
            sq += @as(f64, @floatFromInt(d)) * @as(f64, @floatFromInt(d));
        }
        if (differs) npx += 1;
    }
    const m: f64 = @floatFromInt(n * x.c);
    out.* = .{ @floatFromInt(npx), @floatFromInt(mx), sum / m, sq / m };
    return true;
}
