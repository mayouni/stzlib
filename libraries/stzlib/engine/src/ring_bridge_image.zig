// ring_bridge_image.zig -- the Ring face of image.zig (stz_image.dll, IM0).
//
// Every image and every grid is a gen-keyed handle (a number). Coordinates,
// rows, columns and channels are 1-BASED here and 0-based in the engine;
// channel 0 means "the BT.601 gray of the pixel". A refused call answers 0
// and StzEngineImageLastError() says why.

const std = @import("std");
const img = @import("image.zig");
const ops = @import("image_ops.zig");
const geom = @import("image_geom.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const rn = R.ring_vm_api_retnumber;
const alloc = std.heap.c_allocator;

fn getStr(p: *anyopaque, n: c_int) []const u8 {
    const ptr = R.ring_vm_api_getstring(p, n);
    const len = R.ring_vm_api_getstringsize(p, n);
    return ptr[0..len];
}

fn id(p: *anyopaque, n: c_int) i64 {
    return @intFromFloat(gn(p, n));
}

fn u(p: *anyopaque, n: c_int) u32 {
    const v = gn(p, n);
    if (!(v >= 0) or v > 4_000_000_000) return 0;
    return @intFromFloat(v);
}

fn retF(p: *anyopaque, v: i64) void {
    rn(p, @floatFromInt(v));
}

fn retBytes(p: *anyopaque, b: []const u8) void {
    R.ring_vm_api_retstring2(p, b.ptr, @intCast(b.len));
}

fn ring_LastError(p: *anyopaque) callconv(.c) void {
    retBytes(p, img.lastError());
}

fn ring_New(p: *anyopaque) callconv(.c) void {
    const c = u(p, 3);
    retF(p, img.new(u(p, 1), u(p, 2), if (c > 255) 0 else @intCast(c), @intCast(@min(u(p, 4), 255))));
}

fn ring_FromRaw(p: *anyopaque) callconv(.c) void {
    const c = u(p, 3);
    retF(p, img.fromRaw(u(p, 1), u(p, 2), if (c > 255) 0 else @intCast(c), getStr(p, 4)));
}

fn ring_Free(p: *anyopaque) callconv(.c) void {
    retF(p, img.free(id(p, 1)));
}

fn ring_Take(p: *anyopaque) callconv(.c) void {
    retF(p, img.take(id(p, 1), id(p, 2)));
}

fn rgbArg(p: *anyopaque, n: c_int) [3]u8 {
    return .{ @intCast(@min(u(p, n), 255)), @intCast(@min(u(p, n + 1), 255)), @intCast(@min(u(p, n + 2), 255)) };
}

// (image, x, y, w, h, r, g, b, thickness) -- 0-based, in place
fn ring_Box(p: *anyopaque) callconv(.c) void {
    retF(p, img.box(id(p, 1), @intFromFloat(gn(p, 2)), @intFromFloat(gn(p, 3)), @intFromFloat(gn(p, 4)), @intFromFloat(gn(p, 5)), rgbArg(p, 6), @intFromFloat(gn(p, 9))));
}

// (image, x, y, radius, r, g, b) -- 0-based, in place
fn ring_Dot(p: *anyopaque) callconv(.c) void {
    retF(p, img.dot(id(p, 1), gn(p, 2), gn(p, 3), gn(p, 4), rgbArg(p, 5)));
}

fn ring_Live(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(img.liveImages()));
}

fn ring_Decode(p: *anyopaque) callconv(.c) void {
    retF(p, img.decode(getStr(p, 1)));
}

fn ring_Load(p: *anyopaque) callconv(.c) void {
    retF(p, img.load(getStr(p, 1)));
}

fn ring_ToPng(p: *anyopaque) callconv(.c) void {
    const b = img.encodePng(id(p, 1)) orelse {
        retBytes(p, "");
        return;
    };
    defer alloc.free(b);
    retBytes(p, b);
}

fn ring_SavePng(p: *anyopaque) callconv(.c) void {
    retF(p, img.savePng(id(p, 1), getStr(p, 2)));
}

fn ring_SaveBmp(p: *anyopaque) callconv(.c) void {
    retF(p, img.saveBmp(id(p, 1), getStr(p, 2)));
}

fn ring_Width(p: *anyopaque) callconv(.c) void {
    const im = img.get(id(p, 1)) orelse return rn(p, 0);
    rn(p, @floatFromInt(im.w));
}

fn ring_Height(p: *anyopaque) callconv(.c) void {
    const im = img.get(id(p, 1)) orelse return rn(p, 0);
    rn(p, @floatFromInt(im.h));
}

fn ring_Channels(p: *anyopaque) callconv(.c) void {
    const im = img.get(id(p, 1)) orelse return rn(p, 0);
    rn(p, @floatFromInt(im.c));
}

// (image, x, y, channel) -> 0..255; -1 when out of range
fn ring_At(p: *anyopaque) callconv(.c) void {
    const im = img.get(id(p, 1)) orelse return rn(p, -1);
    const x = u(p, 2);
    const y = u(p, 3);
    const k = u(p, 4);
    if (x < 1 or y < 1 or k < 1 or x > im.w or y > im.h or k > im.c) return rn(p, -1);
    rn(p, @floatFromInt(im.px[((y - 1) * @as(usize, im.w) + (x - 1)) * im.c + (k - 1)]));
}

fn ring_Raw(p: *anyopaque) callconv(.c) void {
    const im = img.get(id(p, 1)) orelse return retBytes(p, "");
    retBytes(p, im.px);
}

fn ring_Convert(p: *anyopaque) callconv(.c) void {
    const c = u(p, 2);
    retF(p, img.convert(id(p, 1), if (c > 255) 0 else @intCast(c)));
}

fn ring_Invert(p: *anyopaque) callconv(.c) void {
    retF(p, img.invert(id(p, 1)));
}

// IM6: (cMaskA, cMaskB, nLevel) -> the IoU of two one-byte-per-pixel masks of the same size, each pixel IN
// when its byte is >= nLevel; 1 when both are empty, -1 when the sizes differ
fn ring_MaskIou(p: *anyopaque) callconv(.c) void {
    const a = getStr(p, 1);
    const b2 = getStr(p, 2);
    const lv: u8 = @intCast(@min(255, @max(0, id(p, 3))));
    if (a.len != b2.len) return rn(p, -1);
    var inter: u64 = 0;
    var uni: u64 = 0;
    for (a, b2) |x, y| {
        const ia = x >= lv;
        const ib = y >= lv;
        if (ia and ib) inter += 1;
        if (ia or ib) uni += 1;
    }
    rn(p, if (uni == 0) 1.0 else @as(f64, @floatFromInt(inter)) / @as(f64, @floatFromInt(uni)));
}

// IM6: (nRows, nCols, cF32) -> a grid of float32 little-endian values (a depth map from stz_neural); 0 on a
// size mismatch
fn ring_GridFromF32(p: *anyopaque) callconv(.c) void {
    const rows: usize = @intCast(@max(0, id(p, 1)));
    const cols: usize = @intCast(@max(0, id(p, 2)));
    const bytes = getStr(p, 3);
    if (rows * cols * 4 != bytes.len or rows * cols == 0) return rn(p, 0);
    const data = alloc.alloc(f64, rows * cols) catch return rn(p, 0);
    for (0..rows * cols) |i| data[i] = @floatCast(std.mem.bytesToValue(f32, bytes[i * 4 ..][0..4]));
    rn(p, @floatFromInt(img.adoptGrid(rows, cols, data)));
}

// IM6: (grid, mask image, nLevel) -> [ mean inside, mean outside ] of a grid over a mask of its size (pixels
// whose gray is >= nLevel are inside); [] on a size mismatch
fn ring_GridMeanByMask(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    defer R.ring_vm_api_retlist(p, out);
    const g = img.getGrid(id(p, 1)) orelse return;
    const mk = img.get(id(p, 2)) orelse return;
    if (g.rows != mk.h or g.cols != mk.w) return;
    const lv: u8 = @intCast(@min(255, @max(0, id(p, 3))));
    var si: f64 = 0;
    var so: f64 = 0;
    var ni: f64 = 0;
    var no: f64 = 0;
    for (g.data, 0..) |v, i| {
        if (img.grayOf(mk, i) >= lv) {
            si += v;
            ni += 1;
        } else {
            so += v;
            no += 1;
        }
    }
    R.ring_list_adddouble(out, if (ni > 0) si / ni else 0);
    R.ring_list_adddouble(out, if (no > 0) so / no else 0);
}

// IM6: (nPredGrid, nTruthGrid, nMask) -> [ AbsRel, delta1, valid pixels ] of a RELATIVE depth prediction
// against a measured depth (DIODE's laser scan, metres), over the mask's pixels >= 128 whose depth is > 0.
// The prediction is inverse depth in no unit, so it is first fitted to the truth's inverse depth by least
// squares (a scale and a shift, the MiDaS protocol); the fitted depth is held at or below the scan's
// farthest depth. nPredGrid 0 scores the classical floor instead: the row number as inverse depth, the
// lower in the picture the nearer. [] on a size mismatch or no valid pixel.
fn ring_DepthScore(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    defer R.ring_vm_api_retlist(p, out);
    const pg = if (id(p, 1) != 0) (img.getGrid(id(p, 1)) orelse return) else null;
    const tg = img.getGrid(id(p, 2)) orelse return;
    const mk = img.get(id(p, 3)) orelse return;
    if (tg.rows != mk.h or tg.cols != mk.w) return;
    if (pg) |g| if (g.rows != tg.rows or g.cols != tg.cols) return;
    var n: f64 = 0;
    var sx: f64 = 0;
    var sy: f64 = 0;
    var sxx: f64 = 0;
    var sxy: f64 = 0;
    var dmax: f64 = 0;
    for (tg.data, 0..) |d, i| {
        if (d <= 0 or img.grayOf(mk, i) < 128) continue;
        const x = if (pg) |g| g.data[i] else @as(f64, @floatFromInt(i / tg.cols));
        const y = 1.0 / d;
        n += 1;
        sx += x;
        sy += y;
        sxx += x * x;
        sxy += x * y;
        dmax = @max(dmax, d);
    }
    if (n == 0) return;
    const vx = sxx - sx * sx / n;
    const sc = if (vx > 0) (sxy - sx * sy / n) / vx else 0;
    const sh = (sy - sc * sx) / n;
    var rel: f64 = 0;
    var good: f64 = 0;
    for (tg.data, 0..) |d, i| {
        if (d <= 0 or img.grayOf(mk, i) < 128) continue;
        const x = if (pg) |g| g.data[i] else @as(f64, @floatFromInt(i / tg.cols));
        const inv = sc * x + sh;
        const e = if (inv > 1.0 / dmax) 1.0 / inv else dmax;
        rel += @abs(e - d) / d;
        if (@max(e / d, d / e) < 1.25) good += 1;
    }
    R.ring_list_adddouble(out, rel / n);
    R.ring_list_adddouble(out, good / n);
    R.ring_list_adddouble(out, n);
}

// IM7 facts: (image, x0, y0, x1, y1) 0-based box, both ends included -> [ text luminance, background luminance,
// background spread, ink pixels, background pixels, Otsu split ] (image.textLuminance); [] on a flat box
fn ring_TextLuminance(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    defer R.ring_vm_api_retlist(p, out);
    const r = img.textLuminance(id(p, 1), id(p, 2), id(p, 3), id(p, 4), id(p, 5)) orelse return;
    R.ring_list_adddouble(out, r.fg);
    R.ring_list_adddouble(out, r.bg);
    R.ring_list_adddouble(out, r.spread);
    R.ring_list_adddouble(out, @floatFromInt(r.n_ink));
    R.ring_list_adddouble(out, @floatFromInt(r.n_bg));
    R.ring_list_adddouble(out, @floatFromInt(r.t));
}

// IM6: (image, mask) -> an RGBA copy whose alpha is the mask's gray
fn ring_WithMask(p: *anyopaque) callconv(.c) void {
    retF(p, img.withMask(id(p, 1), id(p, 2)));
}

// IM6: (nMask, nX, nY, nLevel) -> the connected part of the mask holding the 1-based pixel (x, y)
fn ring_ComponentAt(p: *anyopaque) callconv(.c) void {
    const x = u(p, 2);
    const y = u(p, 3);
    if (x < 1 or y < 1) {
        retF(p, 0);
        return;
    }
    retF(p, img.componentAt(id(p, 1), x - 1, y - 1, @intCast(@min(255, u(p, 4)))));
}

fn ring_Crop(p: *anyopaque) callconv(.c) void {
    const x = u(p, 2);
    const y = u(p, 3);
    if (x < 1 or y < 1) {
        retF(p, 0);
        return;
    }
    retF(p, img.crop(id(p, 1), x - 1, y - 1, u(p, 4), u(p, 5)));
}

fn ring_Flip(p: *anyopaque) callconv(.c) void {
    retF(p, img.flip(id(p, 1), gn(p, 2) != 0));
}

fn ring_Rotate(p: *anyopaque) callconv(.c) void {
    retF(p, img.rotate(id(p, 1), id(p, 2)));
}

fn ring_Resize(p: *anyopaque) callconv(.c) void {
    const m = u(p, 4);
    const mode: img.Resample = switch (m) {
        0 => .nearest,
        2 => .area,
        else => .bilinear,
    };
    retF(p, img.resize(id(p, 1), u(p, 2), u(p, 3), mode));
}

fn ring_Blur(p: *anyopaque) callconv(.c) void {
    retF(p, img.blur(id(p, 1), gn(p, 2)));
}

fn ring_Otsu(p: *anyopaque) callconv(.c) void {
    retF(p, img.otsu(id(p, 1)));
}

fn ring_Threshold(p: *anyopaque) callconv(.c) void {
    retF(p, img.threshold(id(p, 1), id(p, 2)));
}

// channel 0 = gray
fn ring_Histogram(p: *anyopaque) callconv(.c) void {
    retF(p, img.histogram(id(p, 1), id(p, 2) - 1));
}

fn ring_ToGrid(p: *anyopaque) callconv(.c) void {
    retF(p, img.toGrid(id(p, 1), id(p, 2) - 1));
}

fn ring_FromGrid(p: *anyopaque) callconv(.c) void {
    retF(p, img.fromGrid(id(p, 1)));
}

fn ring_FromGridScaled(p: *anyopaque) callconv(.c) void {
    retF(p, img.fromGridScaled(id(p, 1)));
}

fn ring_GridRows(p: *anyopaque) callconv(.c) void {
    const g = img.getGrid(id(p, 1)) orelse return rn(p, 0);
    rn(p, @floatFromInt(g.rows));
}

fn ring_GridCols(p: *anyopaque) callconv(.c) void {
    const g = img.getGrid(id(p, 1)) orelse return rn(p, 0);
    rn(p, @floatFromInt(g.cols));
}

fn ring_GridAt(p: *anyopaque) callconv(.c) void {
    const g = img.getGrid(id(p, 1)) orelse return rn(p, 0);
    const r = u(p, 2);
    const c = u(p, 3);
    if (r < 1 or c < 1 or r > g.rows or c > g.cols) return rn(p, 0);
    rn(p, g.data[(r - 1) * g.cols + (c - 1)]);
}

fn ring_GridMax(p: *anyopaque) callconv(.c) void {
    const g = img.getGrid(id(p, 1)) orelse return rn(p, 0);
    var m: f64 = -std.math.inf(f64);
    for (g.data) |v| m = @max(m, v);
    rn(p, m);
}

fn ring_GridMin(p: *anyopaque) callconv(.c) void {
    const g = img.getGrid(id(p, 1)) orelse return rn(p, 0);
    var m: f64 = std.math.inf(f64);
    for (g.data) |v| m = @min(m, v);
    rn(p, m);
}

fn ring_GridSum(p: *anyopaque) callconv(.c) void {
    const g = img.getGrid(id(p, 1)) orelse return rn(p, 0);
    var s: f64 = 0;
    for (g.data) |v| s += v;
    rn(p, s);
}

fn ring_GridFree(p: *anyopaque) callconv(.c) void {
    retF(p, img.freeGrid(id(p, 1)));
}

fn ring_GridLive(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(img.liveGrids()));
}

// ---------------------------------------------------------------- IM1

fn ring_SaveJpeg(p: *anyopaque) callconv(.c) void {
    retF(p, img.saveJpeg(id(p, 1), getStr(p, 2), id(p, 3)));
}

fn ring_ToJpeg(p: *anyopaque) callconv(.c) void {
    const b = img.encodeJpeg(id(p, 1), id(p, 2)) orelse return retBytes(p, "");
    defer alloc.free(b);
    retBytes(p, b);
}

// IM5: (image, quality 1..100, or 0 for PNG) -> "data:image/jpeg;base64,..." -- the picture ready for an HTML
// page, encoded here so its bytes never cross Ring as text (a JPEG holds NULs, and Ring-side base64 helpers
// were capped at 8 KB). "" on failure.
fn ring_ToDataUri(p: *anyopaque) callconv(.c) void {
    const q = id(p, 2);
    const raw = (if (q > 0) img.encodeJpeg(id(p, 1), q) else img.encodePng(id(p, 1))) orelse return retBytes(p, "");
    defer alloc.free(raw);
    const head: []const u8 = if (q > 0) "data:image/jpeg;base64," else "data:image/png;base64,";
    const enc = std.base64.standard.Encoder;
    const out = alloc.alloc(u8, head.len + enc.calcSize(raw.len)) catch return retBytes(p, "");
    defer alloc.free(out);
    @memcpy(out[0..head.len], head);
    _ = enc.encode(out[head.len..], raw);
    retBytes(p, out);
}

// (image, op 0..6, shape 0 rect 1 cross 2 ellipse, k)
fn ring_Morph(p: *anyopaque) callconv(.c) void {
    const op = u(p, 2);
    const sh = u(p, 3);
    if (op > 6 or sh > 2) return retF(p, img.fail("image: morphology op 0..6 and shape 0..2", .{}));
    retF(p, ops.morph(id(p, 1), @enumFromInt(op), @enumFromInt(sh), u(p, 4)));
}

fn ring_Median(p: *anyopaque) callconv(.c) void {
    retF(p, ops.median(id(p, 1), u(p, 2)));
}

fn ring_Equalize(p: *anyopaque) callconv(.c) void {
    retF(p, ops.equalize(id(p, 1)));
}

// (image, dx, dy, scharr) -> grid
fn ring_Sobel(p: *anyopaque) callconv(.c) void {
    retF(p, ops.sobel(id(p, 1), u(p, 2), u(p, 3), gn(p, 4) != 0));
}

fn ring_Canny(p: *anyopaque) callconv(.c) void {
    retF(p, ops.canny(id(p, 1), gn(p, 2), gn(p, 3), gn(p, 4) != 0));
}

fn ring_Integral(p: *anyopaque) callconv(.c) void {
    retF(p, ops.integral(id(p, 1)));
}

fn ring_AdaptiveMean(p: *anyopaque) callconv(.c) void {
    retF(p, ops.adaptiveMean(id(p, 1), u(p, 2), gn(p, 3)));
}

fn ring_Sauvola(p: *anyopaque) callconv(.c) void {
    retF(p, ops.sauvola(id(p, 1), u(p, 2), gn(p, 3), gn(p, 4)));
}

fn ring_MatchTemplate(p: *anyopaque) callconv(.c) void {
    retF(p, ops.matchTemplate(id(p, 1), id(p, 2)));
}

// (image, conn8) -> [ labelsGrid, statsGrid ]
fn ring_Components(p: *anyopaque) callconv(.c) void {
    var st: i64 = 0;
    const lg = ops.components(id(p, 1), gn(p, 2) != 0, &st);
    const list = R.ring_vm_api_newlist(p) orelse return rn(p, 0);
    R.ring_list_adddouble(list, @floatFromInt(lg));
    R.ring_list_adddouble(list, @floatFromInt(st));
    R.ring_vm_api_retlist(p, list);
}

// (image, shift, log) -> grid
fn ring_Fft2(p: *anyopaque) callconv(.c) void {
    retF(p, ops.fft2(id(p, 1), gn(p, 2) != 0, gn(p, 3) != 0));
}

// grid -> [ row, column, value ]
fn ring_GridArgMax(p: *anyopaque) callconv(.c) void {
    var o: [3]f64 = undefined;
    const list = R.ring_vm_api_newlist(p) orelse return rn(p, 0);
    if (ops.gridArgMax(id(p, 1), &o)) {
        for (o) |v| R.ring_list_adddouble(list, v);
    }
    R.ring_vm_api_retlist(p, list);
}

fn ring_Foreground(p: *anyopaque) callconv(.c) void {
    retF(p, ops.foreground(id(p, 1), u(p, 2)));
}

fn ring_ForegroundTolerance(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ops.last_tolerance));
}

// (a, b) -> [ differing pixels, max abs, mean abs, mse ], [] when not comparable
fn ring_Compare(p: *anyopaque) callconv(.c) void {
    var o: [4]f64 = undefined;
    const list = R.ring_vm_api_newlist(p) orelse return rn(p, 0);
    if (ops.compare(id(p, 1), id(p, 2), &o)) {
        for (o) |v| R.ring_list_adddouble(list, v);
    }
    R.ring_vm_api_retlist(p, list);
}

// ---------------------------------------------------------------- IM2: geometry
//
// Matrices are 3x3 in OpenCV's 0-based pixel coordinates (an affine one has
// last row 0 0 1). Points cross as text "x y;x y;..." in either direction of
// the Ring face's choosing; the engine itself is 0-based.

fn pointsOf(arg: []const u8) std.ArrayList([2]f64) {
    var out: std.ArrayList([2]f64) = .empty;
    var it = std.mem.splitScalar(u8, arg, ';');
    while (it.next()) |item| {
        var f = std.mem.tokenizeAny(u8, item, " ,");
        var p: [2]f64 = .{ 0, 0 };
        var n: usize = 0;
        while (f.next()) |num| : (n += 1) {
            if (n >= 2) break;
            p[n] = std.fmt.parseFloat(f64, num) catch 0;
        }
        if (n >= 2) out.append(alloc, p) catch {};
    }
    return out;
}

fn retMatrix(p: *anyopaque, m: [9]f64, ok: bool) void {
    const list = R.ring_vm_api_newlist(p) orelse return rn(p, 0);
    if (ok) {
        for (m) |v| R.ring_list_adddouble(list, v);
    }
    R.ring_vm_api_retlist(p, list);
}

fn retPoints(p: *anyopaque, pts: []const [2]f64) void {
    const list = R.ring_vm_api_newlist(p) orelse return rn(p, 0);
    for (pts) |q| {
        const sub = R.ring_list_newlist(list) orelse continue;
        R.ring_list_adddouble(sub, q[0]);
        R.ring_list_adddouble(sub, q[1]);
    }
    R.ring_vm_api_retlist(p, list);
}

// (image, perspective, dw, dh, fill, m0..m8) -> image
fn ring_Warp(p: *anyopaque) callconv(.c) void {
    var m: [9]f64 = undefined;
    for (0..9) |k| m[k] = gn(p, @intCast(6 + k));
    retF(p, geom.warp(id(p, 1), m, gn(p, 2) != 0, u(p, 3), u(p, 4), @intCast(@min(u(p, 5), 255))));
}

// (cSrcPoints, cDstPoints) -> [ m0..m8 ] (4 pairs) ; [] when degenerate
fn ring_PerspectiveFrom(p: *anyopaque) callconv(.c) void {
    var a = pointsOf(getStr(p, 1));
    defer a.deinit(alloc);
    var b = pointsOf(getStr(p, 2));
    defer b.deinit(alloc);
    var m: [9]f64 = undefined;
    if (a.items.len != 4 or b.items.len != 4) return retMatrix(p, m, false);
    const ok = geom.perspectiveFrom(a.items[0..4].*, b.items[0..4].*, &m);
    retMatrix(p, m, ok);
}

// (cSrcPoints, cDstPoints) -> [ m0..m8 ] (3 pairs)
fn ring_AffineFrom(p: *anyopaque) callconv(.c) void {
    var a = pointsOf(getStr(p, 1));
    defer a.deinit(alloc);
    var b = pointsOf(getStr(p, 2));
    defer b.deinit(alloc);
    var m: [9]f64 = undefined;
    if (a.items.len != 3 or b.items.len != 3) return retMatrix(p, m, false);
    const ok = geom.affineFrom(a.items[0..3].*, b.items[0..3].*, &m);
    retMatrix(p, m, ok);
}

// (cx, cy, degrees counter-clockwise, scale) -> [ m0..m8 ]
fn ring_RotationMatrix(p: *anyopaque) callconv(.c) void {
    var m: [9]f64 = undefined;
    geom.rotationMatrix(gn(p, 1), gn(p, 2), gn(p, 3), gn(p, 4), &m);
    retMatrix(p, m, true);
}

// (image, simple) -> [ [ [x, y], ... ], ... ] 0-based, one list per outer contour
fn ring_Contours(p: *anyopaque) callconv(.c) void {
    var pts: std.ArrayList(geom.Pt) = .empty;
    defer pts.deinit(alloc);
    var lens: std.ArrayList(usize) = .empty;
    defer lens.deinit(alloc);
    const list = R.ring_vm_api_newlist(p) orelse return rn(p, 0);
    if (geom.contours(id(p, 1), gn(p, 2) != 0, &pts, &lens)) {
        var at: usize = 0;
        for (lens.items) |n| {
            const c = R.ring_list_newlist(list) orelse break;
            for (pts.items[at .. at + n]) |q| {
                const pt = R.ring_list_newlist(c) orelse break;
                R.ring_list_adddouble(pt, @floatFromInt(q.x));
                R.ring_list_adddouble(pt, @floatFromInt(q.y));
            }
            at += n;
        }
    }
    R.ring_vm_api_retlist(p, list);
}

// (cPoints, epsilon) -> [ [x, y], ... ]
fn ring_ApproxPoly(p: *anyopaque) callconv(.c) void {
    var a = pointsOf(getStr(p, 1));
    defer a.deinit(alloc);
    var out: std.ArrayList([2]f64) = .empty;
    defer out.deinit(alloc);
    geom.approxPoly(a.items, gn(p, 2), &out) catch {};
    retPoints(p, out.items);
}

fn ring_ConvexHull(p: *anyopaque) callconv(.c) void {
    var a = pointsOf(getStr(p, 1));
    defer a.deinit(alloc);
    var out: std.ArrayList([2]f64) = .empty;
    defer out.deinit(alloc);
    geom.convexHull(a.items, &out) catch {};
    retPoints(p, out.items);
}

// (cPoints) -> [ [x, y] x 4 corners, [area, 0] ]
fn ring_MinAreaRect(p: *anyopaque) callconv(.c) void {
    var a = pointsOf(getStr(p, 1));
    defer a.deinit(alloc);
    var box: [4][2]f64 = undefined;
    const area = geom.minAreaRect(a.items, &box) catch 0;
    var all: [5][2]f64 = .{ box[0], box[1], box[2], box[3], .{ area, 0 } };
    retPoints(p, all[0..]);
}

pub const regs = [_]R.Reg{
    .{ .name = "stzengineimagelasterror", .func = &ring_LastError },
    .{ .name = "stzengineimagenew", .func = &ring_New },
    .{ .name = "stzengineimagefromraw", .func = &ring_FromRaw },
    .{ .name = "stzengineimagefree", .func = &ring_Free },
    .{ .name = "stzengineimagetake", .func = &ring_Take },
    .{ .name = "stzengineimagelive", .func = &ring_Live },
    .{ .name = "stzengineimagebox", .func = &ring_Box },
    .{ .name = "stzengineimagedot", .func = &ring_Dot },
    .{ .name = "stzengineimagedecode", .func = &ring_Decode },
    .{ .name = "stzengineimageload", .func = &ring_Load },
    .{ .name = "stzengineimagetopng", .func = &ring_ToPng },
    .{ .name = "stzengineimagesavepng", .func = &ring_SavePng },
    .{ .name = "stzengineimagesavebmp", .func = &ring_SaveBmp },
    .{ .name = "stzengineimagewidth", .func = &ring_Width },
    .{ .name = "stzengineimageheight", .func = &ring_Height },
    .{ .name = "stzengineimagechannels", .func = &ring_Channels },
    .{ .name = "stzengineimageat", .func = &ring_At },
    .{ .name = "stzengineimageraw", .func = &ring_Raw },
    .{ .name = "stzengineimageconvert", .func = &ring_Convert },
    .{ .name = "stzengineimageinvert", .func = &ring_Invert },
    .{ .name = "stzengineimagecrop", .func = &ring_Crop },
    .{ .name = "stzengineimageflip", .func = &ring_Flip },
    .{ .name = "stzengineimagerotate", .func = &ring_Rotate },
    .{ .name = "stzengineimageresize", .func = &ring_Resize },
    .{ .name = "stzengineimageblur", .func = &ring_Blur },
    .{ .name = "stzengineimageotsu", .func = &ring_Otsu },
    .{ .name = "stzengineimagethreshold", .func = &ring_Threshold },
    .{ .name = "stzengineimagehistogram", .func = &ring_Histogram },
    .{ .name = "stzengineimagetogrid", .func = &ring_ToGrid },
    .{ .name = "stzengineimagefromgrid", .func = &ring_FromGrid },
    .{ .name = "stzengineimagefromgridscaled", .func = &ring_FromGridScaled },
    .{ .name = "stzengineimagegridrows", .func = &ring_GridRows },
    .{ .name = "stzengineimagegridcols", .func = &ring_GridCols },
    .{ .name = "stzengineimagegridat", .func = &ring_GridAt },
    .{ .name = "stzengineimagegridmax", .func = &ring_GridMax },
    .{ .name = "stzengineimagegridmin", .func = &ring_GridMin },
    .{ .name = "stzengineimagegridsum", .func = &ring_GridSum },
    .{ .name = "stzengineimagegridfree", .func = &ring_GridFree },
    .{ .name = "stzengineimagegridlive", .func = &ring_GridLive },
    .{ .name = "stzengineimagesavejpeg", .func = &ring_SaveJpeg },
    .{ .name = "stzengineimagetojpeg", .func = &ring_ToJpeg },
    .{ .name = "stzengineimagetodatauri", .func = &ring_ToDataUri },
    .{ .name = "stzengineimagewithmask", .func = &ring_WithMask },
    .{ .name = "stzengineimagemaskiou", .func = &ring_MaskIou },
    .{ .name = "stzengineimagegridfromf32", .func = &ring_GridFromF32 },
    .{ .name = "stzengineimagegridmeanbymask", .func = &ring_GridMeanByMask },
    .{ .name = "stzengineimagemorph", .func = &ring_Morph },
    .{ .name = "stzengineimagemedian", .func = &ring_Median },
    .{ .name = "stzengineimageequalize", .func = &ring_Equalize },
    .{ .name = "stzengineimagesobel", .func = &ring_Sobel },
    .{ .name = "stzengineimagecanny", .func = &ring_Canny },
    .{ .name = "stzengineimageintegral", .func = &ring_Integral },
    .{ .name = "stzengineimageadaptivemean", .func = &ring_AdaptiveMean },
    .{ .name = "stzengineimagesauvola", .func = &ring_Sauvola },
    .{ .name = "stzengineimagematchtemplate", .func = &ring_MatchTemplate },
    .{ .name = "stzengineimagecomponents", .func = &ring_Components },
    .{ .name = "stzengineimagecomponentat", .func = &ring_ComponentAt },
    .{ .name = "stzengineimagedepthscore", .func = &ring_DepthScore },
    .{ .name = "stzengineimagetextluminance", .func = &ring_TextLuminance },
    .{ .name = "stzengineimagefft2", .func = &ring_Fft2 },
    .{ .name = "stzengineimagegridargmax", .func = &ring_GridArgMax },
    .{ .name = "stzengineimagecompare", .func = &ring_Compare },
    .{ .name = "stzengineimageforeground", .func = &ring_Foreground },
    .{ .name = "stzengineimageforegroundtolerance", .func = &ring_ForegroundTolerance },
    .{ .name = "stzengineimagewarp", .func = &ring_Warp },
    .{ .name = "stzengineimageperspectivefrom", .func = &ring_PerspectiveFrom },
    .{ .name = "stzengineimageaffinefrom", .func = &ring_AffineFrom },
    .{ .name = "stzengineimagerotationmatrix", .func = &ring_RotationMatrix },
    .{ .name = "stzengineimagecontours", .func = &ring_Contours },
    .{ .name = "stzengineimageapproxpoly", .func = &ring_ApproxPoly },
    .{ .name = "stzengineimageconvexhull", .func = &ring_ConvexHull },
    .{ .name = "stzengineimageminarearect", .func = &ring_MinAreaRect },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
