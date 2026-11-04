//! image_quality.zig -- is a picture sharp, and is it the same as another? (IM9d of SOFTANZA_IMAGE_INTELLIGENCE.md)
//!
//! Two measures, both classical and both defined by a formula another library computes, so the guard can hold them to it:
//!
//!   laplacianVariance  the variance of the Laplacian of the gray picture: OpenCV's cv2.Laplacian(gray, CV_64F, ksize=1)
//!                      -- the kernel [0 1 0; 1 -4 1; 0 1 0], borders REFLECT_101 -- then numpy's var (population).
//!                      A sharp picture has strong second derivatives at its edges; a blurred one has none.
//!   phash              a 64-bit perceptual hash, imagehash's phash by definition: the gray picture reduced to 32 x 32,
//!                      its 2D DCT-II (scipy.fftpack.dct along both axes, unnormalised), the 8 x 8 low-frequency block,
//!                      one bit per coefficient: above the block's median or not, row-major, the first bit the most
//!                      significant. Two pictures of the same scene (resized, re-encoded, brightened, slightly cropped)
//!                      differ in few bits; two different scenes in about half of them. The reduction is the engine's
//!                      AREA resize, which is OpenCV's INTER_AREA.

const std = @import("std");
const image = @import("image.zig");
const core = @import("image_core.zig");

const alloc = std.heap.c_allocator;

fn grayOf(im: *const image.Image) ?[]u8 {
    const w: usize = im.w;
    const h: usize = im.h;
    const g = alloc.alloc(u8, w * h) catch return null;
    core.toGray(core.view(.{ .w = w, .h = h, .c = @as(usize, im.c), .px = im.px }), g);
    return g;
}

/// The variance of the Laplacian of the gray picture; -1 for a handle that is not an image.
pub fn laplacianVariance(id: i64) f64 {
    const im = image.get(id) orelse return -1;
    const g = grayOf(im) orelse return -1;
    defer alloc.free(g);
    const w: i64 = im.w;
    const h: i64 = im.h;
    var sum: i64 = 0;
    var sumsq: i64 = 0;
    var y: i64 = 0;
    while (y < h) : (y += 1) {
        const ym = image.reflect101(y - 1, h);
        const yp = image.reflect101(y + 1, h);
        var x: i64 = 0;
        while (x < w) : (x += 1) {
            const xm = image.reflect101(x - 1, w);
            const xp = image.reflect101(x + 1, w);
            const uy: usize = @intCast(y);
            const ux: usize = @intCast(x);
            const wu: usize = @intCast(w);
            const c: i64 = g[uy * wu + ux];
            const v: i64 = @as(i64, g[ym * wu + ux]) + @as(i64, g[yp * wu + ux]) + @as(i64, g[uy * wu + xm]) + @as(i64, g[uy * wu + xp]) - 4 * c;
            sum += v;
            sumsq += v * v;
        }
    }
    const n: f64 = @floatFromInt(w * h);
    const mean = @as(f64, @floatFromInt(sum)) / n;
    return @as(f64, @floatFromInt(sumsq)) / n - mean * mean;
}

/// The 64-bit perceptual hash of the picture (see the header); 0 with `ok` false for a handle that is not an image.
pub fn phash(id: i64, ok: *bool) u64 {
    ok.* = false;
    const im = image.get(id) orelse return 0;
    const g = grayOf(im) orelse return 0;
    const tmp = image.adopt(im.w, im.h, 1, g); // adopt takes the buffer
    if (tmp == 0) return 0;
    defer _ = image.free(tmp);
    const small = image.resize(tmp, 32, 32, .area);
    if (small == 0) return 0;
    defer _ = image.free(small);
    const sm = image.get(small) orelse return 0;
    // the DCT-II, unnormalised: X[k] = 2 * sum x[n] cos(pi k (2n + 1) / 64) along each axis
    var cs: [32][32]f64 = undefined;
    for (0..32) |k| {
        for (0..32) |n| cs[k][n] = @cos(std.math.pi * @as(f64, @floatFromInt(k)) * (2.0 * @as(f64, @floatFromInt(n)) + 1.0) / 64.0);
    }
    var low: [8][8]f64 = undefined;
    // only the 8 x 8 low-frequency block is needed: rows k < 8 of C * X, then columns l < 8 against C
    var tmp1: [8][32]f64 = undefined; // (C X)[k][col]
    for (0..8) |k| {
        for (0..32) |col| {
            var acc: f64 = 0;
            for (0..32) |row| acc += cs[k][row] * @as(f64, @floatFromInt(sm.px[row * 32 + col]));
            tmp1[k][col] = 2.0 * acc;
        }
    }
    for (0..8) |k| {
        for (0..8) |l| {
            var acc: f64 = 0;
            for (0..32) |col| acc += tmp1[k][col] * cs[l][col];
            low[k][l] = 2.0 * acc;
        }
    }
    var flat: [64]f64 = undefined;
    for (0..8) |k| {
        for (0..8) |l| flat[k * 8 + l] = low[k][l];
    }
    var sorted = flat;
    std.mem.sort(f64, &sorted, {}, std.sort.asc(f64));
    const med = (sorted[31] + sorted[32]) / 2.0;
    var h: u64 = 0;
    for (flat) |v| h = (h << 1) | @as(u64, if (v > med) 1 else 0);
    ok.* = true;
    return h;
}
