//! image_geom.zig -- the image plane's geometry (IM2 of SOFTANZA_IMAGE_INTELLIGENCE.md).
//!
//! Warps (affine, perspective), the matrices that drive them (from point
//! pairs, from an angle), contours (Suzuki border following, as OpenCV's
//! findContours with RETR_EXTERNAL), polygon approximation (Douglas-Peucker),
//! the convex hull and the rotated minimum-area rectangle. OpenCV is the
//! oracle; where OpenCV quantises, this file quantises the same way, because
//! a warp that is "more precise" than the oracle cannot be checked against it.

const std = @import("std");
const img = @import("image.zig");

const alloc = std.heap.c_allocator;

// ------------------------------------------------------------------ matrices

/// Solves A x = b (n x n, row-major) by Gaussian elimination with partial
/// pivoting; false when A is singular.
fn solve(comptime n: usize, A: *[n * n]f64, b: *[n]f64) bool {
    for (0..n) |col| {
        var piv = col;
        for (col + 1..n) |r| {
            if (@abs(A[r * n + col]) > @abs(A[piv * n + col])) piv = r;
        }
        if (@abs(A[piv * n + col]) < 1e-12) return false;
        if (piv != col) {
            for (0..n) |k| std.mem.swap(f64, &A[col * n + k], &A[piv * n + k]);
            std.mem.swap(f64, &b[col], &b[piv]);
        }
        for (col + 1..n) |r| {
            const f = A[r * n + col] / A[col * n + col];
            for (col..n) |k| A[r * n + k] -= f * A[col * n + k];
            b[r] -= f * b[col];
        }
    }
    var i: usize = n;
    while (i > 0) {
        i -= 1;
        var s = b[i];
        for (i + 1..n) |k| s -= A[i * n + k] * b[k];
        b[i] = s / A[i * n + i];
    }
    return true;
}

/// cv2.getPerspectiveTransform: the 3x3 homography (m[8] = 1) taking the four
/// src points onto the four dst points; false when three are collinear.
pub fn perspectiveFrom(src: [4][2]f64, dst: [4][2]f64, m: *[9]f64) bool {
    var A: [64]f64 = undefined;
    var b: [8]f64 = undefined;
    for (0..4) |i| {
        const x = src[i][0];
        const y = src[i][1];
        const u = dst[i][0];
        const v = dst[i][1];
        const r0 = i * 8;
        const r1 = (i + 4) * 8;
        A[r0 + 0] = x;
        A[r0 + 1] = y;
        A[r0 + 2] = 1;
        A[r0 + 3] = 0;
        A[r0 + 4] = 0;
        A[r0 + 5] = 0;
        A[r0 + 6] = -x * u;
        A[r0 + 7] = -y * u;
        A[r1 + 0] = 0;
        A[r1 + 1] = 0;
        A[r1 + 2] = 0;
        A[r1 + 3] = x;
        A[r1 + 4] = y;
        A[r1 + 5] = 1;
        A[r1 + 6] = -x * v;
        A[r1 + 7] = -y * v;
        b[i] = u;
        b[i + 4] = v;
    }
    if (!solve(8, &A, &b)) return false;
    for (0..8) |k| m[k] = b[k];
    m[8] = 1;
    return true;
}

/// cv2.getAffineTransform: the 2x3 matrix (as a 3x3 with last row 0 0 1)
/// taking three src points onto three dst points.
pub fn affineFrom(src: [3][2]f64, dst: [3][2]f64, m: *[9]f64) bool {
    var A: [36]f64 = undefined;
    var b: [6]f64 = undefined;
    for (0..3) |i| {
        const r0 = i * 6;
        const r1 = (i + 3) * 6;
        A[r0 + 0] = src[i][0];
        A[r0 + 1] = src[i][1];
        A[r0 + 2] = 1;
        A[r0 + 3] = 0;
        A[r0 + 4] = 0;
        A[r0 + 5] = 0;
        A[r1 + 0] = 0;
        A[r1 + 1] = 0;
        A[r1 + 2] = 0;
        A[r1 + 3] = src[i][0];
        A[r1 + 4] = src[i][1];
        A[r1 + 5] = 1;
        b[i] = dst[i][0];
        b[i + 3] = dst[i][1];
    }
    if (!solve(6, &A, &b)) return false;
    m.* = .{ b[0], b[1], b[2], b[3], b[4], b[5], 0, 0, 1 };
    return true;
}

/// cv2.getRotationMatrix2D(centre, angle, scale): angle in degrees, positive
/// = counter-clockwise on screen (y down), about (cx, cy).
pub fn rotationMatrix(cx: f64, cy: f64, deg: f64, scale: f64, m: *[9]f64) void {
    const a = deg * std.math.pi / 180.0;
    const al = scale * @cos(a);
    const be = scale * @sin(a);
    m.* = .{ al, be, (1 - al) * cx - be * cy, -be, al, be * cx + (1 - al) * cy, 0, 0, 1 };
}

fn invert3(m: [9]f64, out: *[9]f64) bool {
    const a = m[0];
    const b = m[1];
    const c = m[2];
    const d = m[3];
    const e = m[4];
    const f = m[5];
    const g = m[6];
    const h = m[7];
    const i = m[8];
    const det = a * (e * i - f * h) - b * (d * i - f * g) + c * (d * h - e * g);
    if (@abs(det) < 1e-15) return false;
    const r = 1.0 / det;
    out.* = .{
        (e * i - f * h) * r, (c * h - b * i) * r, (b * f - c * e) * r,
        (f * g - d * i) * r, (a * i - c * g) * r, (c * d - a * f) * r,
        (d * h - e * g) * r, (b * g - a * h) * r, (a * e - b * d) * r,
    };
    return true;
}

// ------------------------------------------------------------------ warps

/// cv2.warpAffine / cv2.warpPerspective (INTER_LINEAR, BORDER_CONSTANT with
/// `fill`) as OpenCV 5 computes them -- MEASURED against the oracle, not
/// recalled: the forward matrix is inverted; each target pixel's source
/// position is CONTINUOUS (no 1/32-pixel grid -- the pre-4.11 fixed point
/// differed from OpenCV 5 on 874 of 6,912 pixels); the bilinear blend is
/// (p00 (1-ax) + p10 ax)(1-ay) + (p01 (1-ax) + p11 ax) ay, rounded; a tap
/// outside the image reads `fill`.
pub fn warp(id: i64, m_fwd: [9]f64, perspective: bool, dw: u32, dh: u32, fill: u8) i64 {
    const im = img.get(id) orelse return img.fail("image: no such image", .{});
    if (dw == 0 or dh == 0) return img.fail("image: a warp needs a target size", .{});
    var mfwd = m_fwd;
    if (!perspective) {
        mfwd[6] = 0;
        mfwd[7] = 0;
        mfwd[8] = 1;
    }
    var M: [9]f64 = undefined;
    if (!invert3(mfwd, &M)) return img.fail("image: the warp matrix is singular", .{});
    const c: usize = im.c;
    const out = alloc.alloc(u8, @as(usize, dw) * dh * c) catch return img.fail("image: out of memory", .{});
    const W: i64 = im.w;
    const H: i64 = im.h;
    var y: usize = 0;
    while (y < dh) : (y += 1) {
        const fy: f64 = @floatFromInt(y);
        var x: usize = 0;
        while (x < dw) : (x += 1) {
            const fx: f64 = @floatFromInt(x);
            var X = M[0] * fx + M[1] * fy + M[2];
            var Y = M[3] * fx + M[4] * fy + M[5];
            if (perspective) {
                const w = M[6] * fx + M[7] * fy + M[8];
                if (w == 0) {
                    X = -1e9;
                    Y = -1e9;
                } else {
                    X /= w;
                    Y /= w;
                }
            }
            const o = out[(y * dw + x) * c ..];
            if (!(X > -2.0 and Y > -2.0 and X < @as(f64, @floatFromInt(W + 1)) and Y < @as(f64, @floatFromInt(H + 1)))) {
                @memset(o[0..c], fill);
                continue;
            }
            const x0f = @floor(X);
            const y0f = @floor(Y);
            const ax = X - x0f;
            const ay = Y - y0f;
            const ix: i64 = @intFromFloat(x0f);
            const iy: i64 = @intFromFloat(y0f);
            for (0..c) |k| {
                const p00: f64 = @floatFromInt(tap(im, ix, iy, k, W, H, fill));
                const p10: f64 = @floatFromInt(tap(im, ix + 1, iy, k, W, H, fill));
                const p01: f64 = @floatFromInt(tap(im, ix, iy + 1, k, W, H, fill));
                const p11: f64 = @floatFromInt(tap(im, ix + 1, iy + 1, k, W, H, fill));
                const v = (p00 * (1 - ax) + p10 * ax) * (1 - ay) + (p01 * (1 - ax) + p11 * ax) * ay;
                o[k] = img.round8(v);
            }
        }
    }
    return img.adopt(dw, dh, im.c, out);
}

inline fn tap(im: *const img.Image, x: i64, y: i64, k: usize, W: i64, H: i64, fill: u8) i64 {
    if (x < 0 or y < 0 or x >= W or y >= H) return fill;
    return im.px[(@as(usize, @intCast(y)) * im.w + @as(usize, @intCast(x))) * im.c + k];
}

// ------------------------------------------------------------------ contours

pub const Pt = struct { x: i32, y: i32 };

// OpenCV's chain codes: 0 E, 1 NE, 2 N, 3 NW, 4 W, 5 SW, 6 S, 7 SE (y down)
const DX = [8]i32{ 1, 1, 0, -1, -1, -1, 0, 1 };
const DY = [8]i32{ 0, -1, -1, -1, 0, 1, 1, 1 };

/// The OUTER contours of the nonzero pixels (cv2.findContours with
/// RETR_EXTERNAL): one polygon per foreground region not enclosed in a hole of
/// another. Points follow OpenCV's border following (icvFetchContour) from the
/// region's first pixel in raster order; with `simple`, only the points where
/// the chain changes direction are kept (CHAIN_APPROX_SIMPLE). Returns the
/// contours flattened into `pts` with their lengths in `lens`.
pub fn contours(id: i64, simple: bool, pts: *std.ArrayList(Pt), lens: *std.ArrayList(usize)) bool {
    const im = img.get(id) orelse return false;
    // a frame of zeros around the image, as OpenCV pads it
    const W: usize = @as(usize, im.w) + 2;
    const H: usize = @as(usize, im.h) + 2;
    const f = alloc.alloc(u8, W * H) catch return false;
    defer alloc.free(f);
    @memset(f, 0);
    for (0..im.h) |y| {
        for (0..im.w) |x| {
            if (img.grayOf(im, y * im.w + x) != 0) f[(y + 1) * W + x + 1] = 1;
        }
    }
    // the outer background: zeros 4-connected to the frame
    const outside = alloc.alloc(u8, W * H) catch return false;
    defer alloc.free(outside);
    @memset(outside, 0);
    var stack: std.ArrayList(usize) = .{};
    defer stack.deinit(alloc);
    stack.append(alloc, 0) catch return false;
    outside[0] = 1;
    while (stack.pop()) |p| {
        const px = p % W;
        const py = p / W;
        const nb = [4][2]i64{ .{ -1, 0 }, .{ 1, 0 }, .{ 0, -1 }, .{ 0, 1 } };
        for (nb) |d| {
            const nx = @as(i64, @intCast(px)) + d[0];
            const ny = @as(i64, @intCast(py)) + d[1];
            if (nx < 0 or ny < 0 or nx >= @as(i64, @intCast(W)) or ny >= @as(i64, @intCast(H))) continue;
            const q = @as(usize, @intCast(ny)) * W + @as(usize, @intCast(nx));
            if (f[q] == 0 and outside[q] == 0) {
                outside[q] = 1;
                stack.append(alloc, q) catch return false;
            }
        }
    }
    // each 8-connected foreground region, once, from its first pixel
    const seen = alloc.alloc(u8, W * H) catch return false;
    defer alloc.free(seen);
    @memset(seen, 0);
    for (1..H - 1) |y| {
        for (1..W - 1) |x| {
            const p = y * W + x;
            if (f[p] == 0 or seen[p] != 0) continue;
            // mark the region and learn whether it touches the outer background
            var external = false;
            stack.append(alloc, p) catch return false;
            seen[p] = 1;
            while (stack.pop()) |q| {
                const qx = q % W;
                const qy = q / W;
                if (outside[q - 1] != 0 or outside[q + 1] != 0 or outside[q - W] != 0 or outside[q + W] != 0) external = true;
                for (0..8) |s| {
                    const nq = @as(usize, @intCast(@as(i64, @intCast(qy)) + DY[s])) * W + @as(usize, @intCast(@as(i64, @intCast(qx)) + DX[s]));
                    if (f[nq] != 0 and seen[nq] == 0) {
                        seen[nq] = 1;
                        stack.append(alloc, nq) catch return false;
                    }
                }
            }
            if (!external) continue;
            const before = pts.items.len;
            traceOuter(f, W, x, y, simple, pts) catch return false;
            lens.append(alloc, pts.items.len - before) catch return false;
        }
    }
    return true;
}

/// icvFetchContour for an outer border starting at (x0, y0), whose left
/// neighbour is background. Points are written in IMAGE coordinates (the
/// frame removed).
fn traceOuter(f: []const u8, W: usize, x0: usize, y0: usize, simple: bool, pts: *std.ArrayList(Pt)) !void {
    const at = struct {
        fn v(ff: []const u8, w: usize, x: i64, y: i64) u8 {
            return ff[@as(usize, @intCast(y)) * w + @as(usize, @intCast(x))];
        }
    };
    const sx: i64 = @intCast(x0);
    const sy: i64 = @intCast(y0);
    var s: u3 = 4;
    const s_end0: u3 = 4;
    var found = false;
    while (true) {
        s = s -% 1;
        if (at.v(f, W, sx + DX[s], sy + DY[s]) != 0) {
            found = true;
            break;
        }
        if (s == s_end0) break;
    }
    if (!found) {
        try pts.append(alloc, .{ .x = @intCast(sx - 1), .y = @intCast(sy - 1) });
        return;
    }
    const x1 = sx + DX[s];
    const y1 = sy + DY[s];
    var x3 = sx;
    var y3 = sy;
    var prev_s: u3 = s ^ 4;
    var ptx = sx;
    var pty = sy;
    while (true) {
        const s_end = s;
        var x4: i64 = 0;
        var y4: i64 = 0;
        while (true) {
            s = s +% 1;
            x4 = x3 + DX[s];
            y4 = y3 + DY[s];
            if (at.v(f, W, x4, y4) != 0) break;
            if (s == s_end) break;
        }
        if (!simple or s != prev_s) {
            try pts.append(alloc, .{ .x = @intCast(ptx - 1), .y = @intCast(pty - 1) });
            prev_s = s;
        }
        ptx += DX[s];
        pty += DY[s];
        if (x4 == sx and y4 == sy and x3 == x1 and y3 == y1) break;
        x3 = x4;
        y3 = y4;
        s = s +% 4;
    }
}

// ------------------------------------------------------------------ polygons

fn segDist(p: [2]f64, a: [2]f64, b: [2]f64) f64 {
    const dx = b[0] - a[0];
    const dy = b[1] - a[1];
    const l2 = dx * dx + dy * dy;
    if (l2 == 0) return @sqrt((p[0] - a[0]) * (p[0] - a[0]) + (p[1] - a[1]) * (p[1] - a[1]));
    return @abs(dy * (p[0] - a[0]) - dx * (p[1] - a[1])) / @sqrt(l2);
}

fn dp(pts: []const [2]f64, lo: usize, hi: usize, eps: f64, keep: []bool) void {
    if (hi <= lo + 1) return;
    var best: f64 = -1;
    var at: usize = lo;
    for (lo + 1..hi) |i| {
        const d = segDist(pts[i], pts[lo], pts[hi]);
        if (d > best) {
            best = d;
            at = i;
        }
    }
    if (best > eps) {
        keep[at] = true;
        dp(pts, lo, at, eps, keep);
        dp(pts, at, hi, eps, keep);
    }
}

/// Douglas-Peucker on a CLOSED polygon (as cv2.approxPolyDP(closed=True)):
/// the polygon is split at its first point and the point farthest from it,
/// each half simplified to `eps`. Writes the kept vertices in order.
pub fn approxPoly(src: []const [2]f64, eps: f64, out: *std.ArrayList([2]f64)) !void {
    const n = src.len;
    if (n < 3) {
        for (src) |p| try out.append(alloc, p);
        return;
    }
    var far: usize = 0;
    var fd: f64 = -1;
    for (src, 0..) |p, i| {
        const d = (p[0] - src[0][0]) * (p[0] - src[0][0]) + (p[1] - src[0][1]) * (p[1] - src[0][1]);
        if (d > fd) {
            fd = d;
            far = i;
        }
    }
    // a closed ring: walk it as 0..far and far..n (back to 0)
    const ring = try alloc.alloc([2]f64, n + 1);
    defer alloc.free(ring);
    @memcpy(ring[0..n], src);
    ring[n] = src[0];
    const keep = try alloc.alloc(bool, n + 1);
    defer alloc.free(keep);
    @memset(keep, false);
    keep[0] = true;
    keep[far] = true;
    dp(ring, 0, far, eps, keep);
    dp(ring, far, n, eps, keep);
    for (0..n) |i| {
        if (keep[i]) try out.append(alloc, src[i]);
    }
}

fn cross(o: [2]f64, a: [2]f64, b: [2]f64) f64 {
    return (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0]);
}

fn lessPt(_: void, a: [2]f64, b: [2]f64) bool {
    return a[0] < b[0] or (a[0] == b[0] and a[1] < b[1]);
}

/// The convex hull (Andrew's monotone chain), collinear points dropped.
pub fn convexHull(src: []const [2]f64, out: *std.ArrayList([2]f64)) !void {
    const p = try alloc.dupe([2]f64, src);
    defer alloc.free(p);
    std.mem.sort([2]f64, p, {}, lessPt);
    const n = p.len;
    if (n < 3) {
        for (p) |q| try out.append(alloc, q);
        return;
    }
    const h = try alloc.alloc([2]f64, 2 * n);
    defer alloc.free(h);
    var k: usize = 0;
    for (0..n) |i| {
        while (k >= 2 and cross(h[k - 2], h[k - 1], p[i]) <= 0) k -= 1;
        h[k] = p[i];
        k += 1;
    }
    const t = k + 1;
    var i: usize = n - 1;
    while (i > 0) {
        i -= 1;
        while (k >= t and cross(h[k - 2], h[k - 1], p[i]) <= 0) k -= 1;
        h[k] = p[i];
        k += 1;
    }
    for (h[0 .. k - 1]) |q| try out.append(alloc, q);
}

/// The minimum-area enclosing rectangle (rotating calipers over the hull):
/// its four corners in `box` and its area. An edge of the best box lies on a
/// hull edge, so every hull edge is tried.
pub fn minAreaRect(src: []const [2]f64, box: *[4][2]f64) !f64 {
    var hull: std.ArrayList([2]f64) = .{};
    defer hull.deinit(alloc);
    try convexHull(src, &hull);
    const hp = hull.items;
    if (hp.len == 0) return 0;
    if (hp.len == 1) {
        box.* = .{ hp[0], hp[0], hp[0], hp[0] };
        return 0;
    }
    var best: f64 = std.math.inf(f64);
    for (0..hp.len) |i| {
        const a = hp[i];
        const b = hp[(i + 1) % hp.len];
        var ux = b[0] - a[0];
        var uy = b[1] - a[1];
        const l = @sqrt(ux * ux + uy * uy);
        if (l == 0) continue;
        ux /= l;
        uy /= l;
        var lo_u: f64 = std.math.inf(f64);
        var hi_u: f64 = -std.math.inf(f64);
        var lo_v: f64 = std.math.inf(f64);
        var hi_v: f64 = -std.math.inf(f64);
        for (hp) |q| {
            const du = (q[0] - a[0]) * ux + (q[1] - a[1]) * uy;
            const dv = -(q[0] - a[0]) * uy + (q[1] - a[1]) * ux;
            lo_u = @min(lo_u, du);
            hi_u = @max(hi_u, du);
            lo_v = @min(lo_v, dv);
            hi_v = @max(hi_v, dv);
        }
        const area = (hi_u - lo_u) * (hi_v - lo_v);
        if (area < best) {
            best = area;
            const corner = struct {
                fn at(o: [2]f64, x: f64, y: f64, u: f64, v: f64) [2]f64 {
                    return .{ o[0] + u * x - v * y, o[1] + u * y + v * x };
                }
            };
            box.* = .{
                corner.at(a, ux, uy, lo_u, lo_v), corner.at(a, ux, uy, hi_u, lo_v),
                corner.at(a, ux, uy, hi_u, hi_v), corner.at(a, ux, uy, lo_u, hi_v),
            };
        }
    }
    return best;
}

test "a homography maps its four points" {
    var m: [9]f64 = undefined;
    const src = [4][2]f64{ .{ 0, 0 }, .{ 10, 0 }, .{ 10, 10 }, .{ 0, 10 } };
    const dst = [4][2]f64{ .{ 1, 2 }, .{ 12, 1 }, .{ 11, 13 }, .{ 0, 11 } };
    try std.testing.expect(perspectiveFrom(src, dst, &m));
    for (0..4) |i| {
        const w = m[6] * src[i][0] + m[7] * src[i][1] + m[8];
        const u = (m[0] * src[i][0] + m[1] * src[i][1] + m[2]) / w;
        try std.testing.expectApproxEqAbs(dst[i][0], u, 1e-9);
    }
}
