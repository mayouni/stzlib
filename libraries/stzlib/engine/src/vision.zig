//! vision.zig -- the image plane's models on ggml (IM3 of SOFTANZA_IMAGE_INTELLIGENCE.md).
//!
//! Three faculties over the graphs onnx_to_gguf.py converts and ocr_graph.zig runs:
//!   classify   MobileNetV3-Large (timm, ImageNet-1k): shorter side 256 (bilinear), centre crop 224,
//!              RGB, ImageNet mean/std -> softmax -> the k best labels
//!   faces      YuNet 2023mar (OpenCV model zoo): letterbox 640 (pad 0), BGR, raw 0..255 -> per anchor
//!              score = sqrt(cls * obj), box and five landmarks decoded on strides 8/16/32 -> NMS 0.3
//!   objects    YOLOX nano/tiny (Megvii, COCO-80): letterbox to the model's side (pad 114), BGR, raw
//!              0..255 -> box decoded on strides 8/16/32, score = obj * best class -> per-class NMS 0.45
//! The preprocessing runs through image_core (the engine's one resize), the decoding is each model's own,
//! as its reference implementation writes it (OpenCV's face_detect.cpp; YOLOX's demo postprocess).
//! Models stay loaded per path for the process. Boxes come back in the INPUT image's pixels.

const std = @import("std");
const graph = @import("ocr_graph.zig");
const core = @import("image_core.zig");

const gpa = std.heap.c_allocator;

var cache_paths: std.ArrayList([]u8) = .empty;
var cache_models: std.ArrayList(*graph.Model) = .empty;

fn modelFor(path: []const u8) !*graph.Model {
    for (cache_paths.items, 0..) |p, i| {
        if (std.mem.eql(u8, p, path)) return cache_models.items[i];
    }
    const m = try graph.load(path);
    try cache_paths.append(gpa, try gpa.dupe(u8, path));
    try cache_models.append(gpa, m);
    return m;
}

/// An RGB (3-channel) copy of any 1/3/4-channel pixel buffer.
fn toRgb(px: []const u8, w: usize, h: usize, c: usize) ![]u8 {
    const out = try gpa.alloc(u8, w * h * 3);
    for (0..w * h) |i| {
        const s = px[i * c ..];
        out[i * 3] = s[0];
        out[i * 3 + 1] = if (c >= 3) s[1] else s[0];
        out[i * 3 + 2] = if (c >= 3) s[2] else s[0];
    }
    return out;
}

// ------------------------------------------------------------------ classify

pub const Class = struct { index: usize, score: f32 };

pub const Classified = struct {
    best: []Class, // owned
    labels: [][]const u8, // the model's, not owned
    ms: f64,
};

pub fn classify(model_path: []const u8, px: []const u8, w: usize, h: usize, c: usize, k: usize, n_threads: c_int) !Classified {
    const m = try modelFor(model_path);
    const side: usize = if (m.input_w > 0) m.input_w else 224;
    const rgb = try toRgb(px, w, h, c);
    defer gpa.free(rgb);
    // shorter side to 256/224 of the crop (timm's crop_pct 0.875 at 224 gives 256)
    const short: usize = (side * 256 + 112) / 224;
    const s = @as(f64, @floatFromInt(short)) / @as(f64, @floatFromInt(@min(w, h)));
    const rw: usize = @intFromFloat(@round(@as(f64, @floatFromInt(w)) * s));
    const rh: usize = @intFromFloat(@round(@as(f64, @floatFromInt(h)) * s));
    const rs = try gpa.alloc(u8, rw * rh * 3);
    defer gpa.free(rs);
    try core.resizeBilinear(.{ .w = w, .h = h, .c = 3, .px = rgb }, .{ .w = rw, .h = rh, .c = 3, .px = rs }, gpa);
    const y0 = (rh - side) / 2;
    const x0 = (rw - side) / 2;
    const plane = side * side;
    const t = try gpa.alloc(f32, plane * 3);
    defer gpa.free(t);
    const mean = [3]f32{ 0.485, 0.456, 0.406 };
    const stdv = [3]f32{ 0.229, 0.224, 0.225 };
    for (0..side) |y| {
        for (0..side) |x| {
            const p = rs[((y0 + y) * rw + x0 + x) * 3 ..];
            for (0..3) |ch| t[ch * plane + y * side + x] = (@as(f32, @floatFromInt(p[ch])) / 255.0 - mean[ch]) / stdv[ch];
        }
    }
    const o = try graph.run(m, t, .{ 1, 3, @intCast(side), @intCast(side) }, n_threads);
    defer gpa.free(o.data);
    // softmax over the logits, then the k best
    var mx: f32 = -std.math.inf(f32);
    for (o.data) |v| mx = @max(mx, v);
    var sum: f64 = 0;
    for (o.data) |v| sum += @exp(@as(f64, v - mx));
    const kk = @min(k, o.data.len);
    const best = try gpa.alloc(Class, kk);
    const taken = try gpa.alloc(bool, o.data.len);
    defer gpa.free(taken);
    @memset(taken, false);
    for (0..kk) |j| {
        var bi: usize = 0;
        var bv: f32 = -std.math.inf(f32);
        for (o.data, 0..) |v, i| {
            if (!taken[i] and v > bv) {
                bv = v;
                bi = i;
            }
        }
        taken[bi] = true;
        best[j] = .{ .index = bi, .score = @floatCast(@exp(@as(f64, bv - mx)) / sum) };
    }
    return .{ .best = best, .labels = m.labels, .ms = o.ms };
}

// ------------------------------------------------------------------ detections

pub const Det = struct {
    x: f32,
    y: f32,
    w: f32,
    h: f32,
    score: f32,
    class: usize = 0,
    lm: [10]f32 = .{0} ** 10, // five landmarks (faces)
};

pub const Detected = struct {
    dets: []Det, // owned
    labels: [][]const u8,
    ms: f64,
};

/// Letterbox into a side x side BGR float tensor (NCHW, raw 0..255): the image scaled by r to fit,
/// placed top-left, the rest `pad`. Returns r.
fn letterbox(rgb: []const u8, w: usize, h: usize, side: usize, pad: f32, t: []f32) !f64 {
    const r = @min(@as(f64, @floatFromInt(side)) / @as(f64, @floatFromInt(h)), @as(f64, @floatFromInt(side)) / @as(f64, @floatFromInt(w)));
    const nw: usize = @max(1, @as(usize, @intFromFloat(@round(@as(f64, @floatFromInt(w)) * r))));
    const nh: usize = @max(1, @as(usize, @intFromFloat(@round(@as(f64, @floatFromInt(h)) * r))));
    const rs = try gpa.alloc(u8, nw * nh * 3);
    defer gpa.free(rs);
    try core.resizeBilinear(.{ .w = w, .h = h, .c = 3, .px = rgb }, .{ .w = nw, .h = nh, .c = 3, .px = rs }, gpa);
    const plane = side * side;
    @memset(t, pad);
    for (0..nh) |y| {
        for (0..nw) |x| {
            const p = rs[(y * nw + x) * 3 ..];
            const i = y * side + x;
            t[i] = @floatFromInt(p[2]); // B
            t[plane + i] = @floatFromInt(p[1]); // G
            t[2 * plane + i] = @floatFromInt(p[0]); // R
        }
    }
    return r;
}

fn iou(a: Det, b: Det) f32 {
    const x1 = @max(a.x, b.x);
    const y1 = @max(a.y, b.y);
    const x2 = @min(a.x + a.w, b.x + b.w);
    const y2 = @min(a.y + a.h, b.y + b.h);
    const inter = @max(0, x2 - x1) * @max(0, y2 - y1);
    const u = a.w * a.h + b.w * b.h - inter;
    return if (u > 0) inter / u else 0;
}

fn byScore(_: void, a: Det, b: Det) bool {
    return a.score > b.score;
}

/// Greedy non-maximum suppression, best first; `per_class` keeps boxes of different classes apart.
fn nms(cands: []Det, thr: f32, per_class: bool) ![]Det {
    std.mem.sort(Det, cands, {}, byScore);
    var keep: std.ArrayList(Det) = .empty;
    for (cands) |d| {
        var ok = true;
        for (keep.items) |k| {
            if (per_class and k.class != d.class) continue;
            if (iou(d, k) > thr) {
                ok = false;
                break;
            }
        }
        if (ok) try keep.append(gpa, d);
    }
    return keep.toOwnedSlice(gpa);
}

pub fn faces(model_path: []const u8, px: []const u8, w: usize, h: usize, c: usize, thr: f32, nms_thr: f32, n_threads: c_int) !Detected {
    const m = try modelFor(model_path);
    const side: usize = if (m.input_w > 0) m.input_w else 640;
    const rgb = try toRgb(px, w, h, c);
    defer gpa.free(rgb);
    const t = try gpa.alloc(f32, side * side * 3);
    defer gpa.free(t);
    const r = try letterbox(rgb, w, h, side, 0, t);
    const o = try graph.run(m, t, .{ 1, 3, @intCast(side), @intCast(side) }, n_threads);
    defer gpa.free(o.data);
    var cands: std.ArrayList(Det) = .empty;
    defer cands.deinit(gpa);
    var base: usize = 0;
    const rf: f32 = @floatCast(r);
    for ([_]usize{ 8, 16, 32 }) |st| {
        const cols = side / st;
        const n = cols * cols;
        const sf: f32 = @floatFromInt(st);
        for (0..n) |idx| {
            const v = o.data[(base + idx) * 16 ..][0..16];
            const cls = std.math.clamp(v[0], 0, 1);
            const obj = std.math.clamp(v[1], 0, 1);
            const score = @sqrt(cls * obj);
            if (score < thr) continue;
            const col: f32 = @floatFromInt(idx % cols);
            const row: f32 = @floatFromInt(idx / cols);
            const cx = (col + v[2]) * sf;
            const cy = (row + v[3]) * sf;
            const bw = @exp(v[4]) * sf;
            const bh = @exp(v[5]) * sf;
            var d = Det{ .x = (cx - bw / 2) / rf, .y = (cy - bh / 2) / rf, .w = bw / rf, .h = bh / rf, .score = score };
            for (0..5) |q| {
                d.lm[q * 2] = (v[6 + q * 2] + col) * sf / rf;
                d.lm[q * 2 + 1] = (v[7 + q * 2] + row) * sf / rf;
            }
            try cands.append(gpa, d);
        }
        base += n;
    }
    return .{ .dets = try nms(cands.items, nms_thr, false), .labels = &.{}, .ms = o.ms };
}

/// Candidate boxes (before NMS) of one YOLOX run on an RGB buffer, offset by (ox, oy).
fn objectCands(m: *graph.Model, rgb: []const u8, w: usize, h: usize, thr: f32, ox: f32, oy: f32, cands: *std.ArrayList(Det), n_threads: c_int) !f64 {
    const side: usize = if (m.input_w > 0) m.input_w else 416;
    const t = try gpa.alloc(f32, side * side * 3);
    defer gpa.free(t);
    const r = try letterbox(rgb, w, h, side, 114, t);
    const o = try graph.run(m, t, .{ 1, 3, @intCast(side), @intCast(side) }, n_threads);
    defer gpa.free(o.data);
    const nc: usize = @intCast(o.ne[0]); // 85 = 4 box + obj + 80 classes
    var row_i: usize = 0;
    const rf: f32 = @floatCast(r);
    for ([_]usize{ 8, 16, 32 }) |st| {
        const g = side / st;
        const sf: f32 = @floatFromInt(st);
        for (0..g) |gy| {
            for (0..g) |gx| {
                const v = o.data[row_i * nc ..][0..nc];
                row_i += 1;
                var bc: usize = 0;
                var bs: f32 = 0;
                for (5..nc) |k| {
                    if (v[k] > bs) {
                        bs = v[k];
                        bc = k - 5;
                    }
                }
                const score = v[4] * bs;
                if (score < thr) continue;
                const cx = (v[0] + @as(f32, @floatFromInt(gx))) * sf;
                const cy = (v[1] + @as(f32, @floatFromInt(gy))) * sf;
                const bw = @exp(v[2]) * sf;
                const bh = @exp(v[3]) * sf;
                try cands.append(gpa, .{ .x = (cx - bw / 2) / rf + ox, .y = (cy - bh / 2) / rf + oy, .w = bw / rf, .h = bh / rf, .score = score, .class = bc });
            }
        }
    }
    return o.ms;
}

/// Objects in the whole image; with `tiles` = 2, also in four overlapping tiles (each 55% of the
/// width and height, overlapping by 10%), all merged by one per-class NMS. A small detector squeezes a
/// 1280-pixel street into 416 and loses the people in it; the tiles give them back (measured on
/// Times Square: 2 detections whole, 9 with the tiles), at five runs' cost.
pub fn objects(model_path: []const u8, px: []const u8, w: usize, h: usize, c: usize, thr: f32, nms_thr: f32, tiles: usize, n_threads: c_int) !Detected {
    const m = try modelFor(model_path);
    const rgb = try toRgb(px, w, h, c);
    defer gpa.free(rgb);
    var cands: std.ArrayList(Det) = .empty;
    defer cands.deinit(gpa);
    var ms = try objectCands(m, rgb, w, h, thr, 0, 0, &cands, n_threads);
    if (tiles == 2 and w >= 64 and h >= 64) {
        const tw = (w * 55) / 100;
        const th = (h * 55) / 100;
        for ([_]usize{ 0, 1 }) |ty| {
            for ([_]usize{ 0, 1 }) |tx| {
                const x0 = if (tx == 0) 0 else w - tw;
                const y0 = if (ty == 0) 0 else h - th;
                const cut = try gpa.alloc(u8, tw * th * 3);
                defer gpa.free(cut);
                core.cropReplicate(.{ .w = w, .h = h, .c = 3, .px = rgb }, @intCast(x0), @intCast(y0), .{ .w = tw, .h = th, .c = 3, .px = cut });
                ms += try objectCands(m, cut, tw, th, thr, @floatFromInt(x0), @floatFromInt(y0), &cands, n_threads);
            }
        }
    }
    return .{ .dets = try nms(cands.items, nms_thr, true), .labels = m.labels, .ms = ms };
}
