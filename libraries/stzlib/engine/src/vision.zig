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
const bpe = @import("bpe.zig");

const gpa = std.heap.c_allocator;

var cache_paths: std.ArrayList([]u8) = .empty;
var cache_models: std.ArrayList(*graph.Model) = .empty;

pub fn modelFor(path: []const u8) !*graph.Model {
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

// ------------------------------------------------------------------ embeddings (IM5)
// SigLIP2 base patch16-224 (Google, Apache-2.0): an image and a text land in ONE 768-dimensional space, so a
// cosine between them says how well the words describe the picture -- zero-shot labels in the caller's own
// words, and image search by text. Both vectors come back L2-normalized: their dot product IS the cosine.

/// PIL's antialiased resize (Image.resize, BILINEAR) in its own fixed-point arithmetic, which HF's
/// SiglipImageProcessor calls: a triangle filter widened by the scale when shrinking, horizontal pass then
/// vertical, an 8-bit image between the passes (PIL's ImagingResample, PRECISION_BITS = 22).
pub const PilFilter = enum { bilinear, bicubic, lanczos };

fn pilSupport(f: PilFilter) f64 {
    return switch (f) {
        .bilinear => 1.0,
        .bicubic => 2.0,
        .lanczos => 3.0,
    };
}

fn sinc(x: f64) f64 {
    if (x == 0) return 1.0;
    const px = x * std.math.pi;
    return @sin(px) / px;
}

fn pilWeight(f: PilFilter, x: f64) f64 {
    return switch (f) {
        .bilinear => if (@abs(x) < 1.0) 1.0 - @abs(x) else 0.0,
        .lanczos => if (x > -3.0 and x < 3.0) sinc(x) * sinc(x / 3.0) else 0.0,
        .bicubic => blk: {
            // PIL's bicubic_filter, a = -0.5
            const a = -0.5;
            const t = @abs(x);
            if (t < 1.0) break :blk ((a + 2.0) * t - (a + 3.0)) * t * t + 1.0;
            if (t < 2.0) break :blk (((t - 5.0) * t + 8.0) * t - 4.0) * a;
            break :blk 0.0;
        },
    };
}

fn pilCoeffs(f: PilFilter, in_size: usize, out_size: usize, bounds: []usize, kk: *std.ArrayList(i32), ksize: *usize) !void {
    const scale = @as(f64, @floatFromInt(in_size)) / @as(f64, @floatFromInt(out_size));
    const fscale = @max(scale, 1.0);
    const support = pilSupport(f) * fscale;
    ksize.* = @as(usize, @intFromFloat(@ceil(support))) * 2 + 1;
    try kk.resize(gpa, out_size * ksize.*);
    @memset(kk.items, 0);
    const w = try gpa.alloc(f64, ksize.*);
    defer gpa.free(w);
    for (0..out_size) |xx| {
        const center = (@as(f64, @floatFromInt(xx)) + 0.5) * scale;
        const ss = 1.0 / fscale;
        var xmin: i64 = @intFromFloat(center - support + 0.5);
        if (xmin < 0) xmin = 0;
        var xmax: i64 = @intFromFloat(center + support + 0.5);
        if (xmax > @as(i64, @intCast(in_size))) xmax = @intCast(in_size);
        xmax -= xmin;
        var total: f64 = 0;
        for (0..@intCast(xmax)) |x| {
            const d = (@as(f64, @floatFromInt(@as(i64, @intCast(x)) + xmin)) - center + 0.5) * ss;
            const wt = pilWeight(f, d);
            w[x] = wt;
            total += wt;
        }
        for (0..@intCast(xmax)) |x| {
            const k = if (total != 0) w[x] / total else 0;
            kk.items[xx * ksize.* + x] = @intFromFloat(if (k < 0) k * (1 << 22) - 0.5 else k * (1 << 22) + 0.5);
        }
        bounds[xx * 2] = @intCast(xmin);
        bounds[xx * 2 + 1] = @intCast(xmax);
    }
}

fn clip8(v: i64) u8 {
    const s = v >> 22;
    return if (s < 0) 0 else if (s > 255) 255 else @intCast(s);
}

fn resizePil(rgb: []const u8, w: usize, h: usize, ow: usize, oh: usize, out: []u8) !void {
    return resizePilXT(.bilinear, 3, rgb, w, h, ow, oh, out);
}

/// PIL's Image.resize for a filter and nc interleaved channels (1..4), in its fixed-point arithmetic.
pub fn resizePilXT(f: PilFilter, nc: usize, rgb: []const u8, w: usize, h: usize, ow: usize, oh: usize, out: []u8) !void {
    var kx: std.ArrayList(i32) = .empty;
    defer kx.deinit(gpa);
    var ky: std.ArrayList(i32) = .empty;
    defer ky.deinit(gpa);
    const bx = try gpa.alloc(usize, ow * 2);
    defer gpa.free(bx);
    const by = try gpa.alloc(usize, oh * 2);
    defer gpa.free(by);
    var nx: usize = 0;
    var ny: usize = 0;
    try pilCoeffs(f, w, ow, bx, &kx, &nx);
    try pilCoeffs(f, h, oh, by, &ky, &ny);
    const mid = try gpa.alloc(u8, ow * h * nc);
    defer gpa.free(mid);
    for (0..h) |y| {
        for (0..ow) |xx| {
            const x0 = bx[xx * 2];
            const n = bx[xx * 2 + 1];
            const k = kx.items[xx * nx ..];
            for (0..nc) |ch| {
                var ss: i64 = 1 << 21;
                for (0..n) |x| ss += @as(i64, rgb[(y * w + x0 + x) * nc + ch]) * k[x];
                mid[(y * ow + xx) * nc + ch] = clip8(ss);
            }
        }
    }
    for (0..oh) |yy| {
        const y0 = by[yy * 2];
        const n = by[yy * 2 + 1];
        const k = ky.items[yy * ny ..];
        for (0..ow) |xx| {
            for (0..nc) |ch| {
                var ss: i64 = 1 << 21;
                for (0..n) |y| ss += @as(i64, mid[((y0 + y) * ow + xx) * nc + ch]) * k[y];
                out[(yy * ow + xx) * nc + ch] = clip8(ss);
            }
        }
    }
}

pub const Embedded = struct {
    v: []f32, // owned, L2-normalized
    ms: f64,
};

fn normalized(o: graph.Output) Embedded {
    var s: f64 = 0;
    for (o.data) |x| s += @as(f64, x) * x;
    const n: f32 = @floatCast(@sqrt(s));
    if (n > 0) {
        for (o.data) |*x| x.* /= n;
    }
    return .{ .v = o.data, .ms = o.ms };
}

/// The model's input tensor for a picture: resized to the side (PIL bilinear), RGB, (x/255 - 0.5) / 0.5, NCHW.
pub fn siglipPixels(px: []const u8, w: usize, h: usize, c: usize, side: usize) ![]f32 {
    const rgb = try toRgb(px, w, h, c);
    defer gpa.free(rgb);
    const rs = try gpa.alloc(u8, side * side * 3);
    defer gpa.free(rs);
    try resizePil(rgb, w, h, side, side, rs);
    const plane = side * side;
    const t = try gpa.alloc(f32, plane * 3);
    for (0..plane) |i| {
        for (0..3) |ch| t[ch * plane + i] = (@as(f32, @floatFromInt(rs[i * 3 + ch])) / 255.0 - 0.5) / 0.5;
    }
    return t;
}

pub fn embedImage(model_path: []const u8, px: []const u8, w: usize, h: usize, c: usize, n_threads: c_int) !Embedded {
    const m = try modelFor(model_path);
    const side: usize = if (m.input_w > 0) m.input_w else 224;
    const t = try siglipPixels(px, w, h, c, side);
    defer gpa.free(t);
    return normalized(try graph.run(m, t, .{ 1, 3, @intCast(side), @intCast(side) }, n_threads));
}

var tok_paths: std.ArrayList([]u8) = .empty;
var tok_list: std.ArrayList(*bpe.Bpe) = .empty;

fn tokenizerFor(path: []const u8, m: *graph.Model) !*bpe.Bpe {
    for (tok_paths.items, 0..) |p, i| {
        if (std.mem.eql(u8, p, path)) return tok_list.items[i];
    }
    const t = (try bpe.fromGguf(m.gguf, gpa)) orelse {
        graph.setError("the model carries no tokenizer: {s}", .{path});
        return error.NoTokenizer;
    };
    try tok_paths.append(gpa, try gpa.dupe(u8, path));
    try tok_list.append(gpa, t);
    return t;
}

fn seqOf(m: *graph.Model) usize {
    const id = graph.c.gguf_find_key(m.gguf, "stz.graph.seq");
    return if (id >= 0) graph.c.gguf_get_val_u32(m.gguf, id) else 64;
}

/// The token ids a text model reads for a text (padded to its fixed length). Caller frees.
pub fn tokens(model_path: []const u8, text: []const u8) ![]i32 {
    const m = try modelFor(model_path);
    return bpe.encode(try tokenizerFor(model_path, m), text, seqOf(m), gpa);
}

pub fn embedText(model_path: []const u8, text: []const u8, n_threads: c_int) !Embedded {
    const m = try modelFor(model_path);
    const ids = try bpe.encode(try tokenizerFor(model_path, m), text, seqOf(m), gpa);
    defer gpa.free(ids);
    return normalized(try graph.runIds(m, ids, n_threads));
}

// ------------------------------------------------------------------ saliency (IM6)
// U2-Net-p (Qin et al. 2020, Apache-2.0; the file rembg ships): the salient object of a picture as a mask,
// computed as rembg computes it -- PIL LANCZOS to 320 x 320, x / max(x), ImageNet mean/std; the fused
// output (a sigmoid) min-max normalised to 0..255 and resized back to the picture with LANCZOS.

pub const Mask = struct {
    px: []u8, // owned, w * h, 0..255
    ms: f64,
};

pub fn saliency(model_path: []const u8, px: []const u8, w: usize, h: usize, c: usize, n_threads: c_int) !Mask {
    const m = try modelFor(model_path);
    const side: usize = if (m.input_w > 0) m.input_w else 320;
    const rgb = try toRgb(px, w, h, c);
    defer gpa.free(rgb);
    const rs = try gpa.alloc(u8, side * side * 3);
    defer gpa.free(rs);
    try resizePilXT(.lanczos, 3, rgb, w, h, side, side, rs);
    var mx: u8 = 1;
    for (rs) |v| mx = @max(mx, v);
    const plane = side * side;
    const t = try gpa.alloc(f32, plane * 3);
    defer gpa.free(t);
    const mean = [3]f32{ 0.485, 0.456, 0.406 };
    const stdv = [3]f32{ 0.229, 0.224, 0.225 };
    const fmx: f32 = @floatFromInt(mx);
    for (0..plane) |i| {
        for (0..3) |ch| t[ch * plane + i] = (@as(f32, @floatFromInt(rs[i * 3 + ch])) / fmx - mean[ch]) / stdv[ch];
    }
    const o = try graph.run(m, t, .{ 1, 3, @intCast(side), @intCast(side) }, n_threads);
    defer gpa.free(o.data);
    var lo: f32 = std.math.inf(f32);
    var hi: f32 = -std.math.inf(f32);
    for (o.data[0..plane]) |v| {
        lo = @min(lo, v);
        hi = @max(hi, v);
    }
    const small = try gpa.alloc(u8, plane);
    defer gpa.free(small);
    const span = if (hi > lo) hi - lo else 1;
    // PIL's "F" -> "L" conversion truncates toward zero after clipping (rembg: Image.fromarray(pred * 255).convert("L"))
    for (o.data[0..plane], 0..) |v, i| small[i] = @intFromFloat(@min(255.0, @max(0.0, (v - lo) / span * 255.0)));
    const out = try gpa.alloc(u8, w * h);
    errdefer gpa.free(out);
    try resizePilXT(.lanczos, 1, small, side, side, w, h, out);
    return .{ .px = out, .ms = o.ms };
}

// ------------------------------------------------------------------ depth (IM6)
// Depth-Anything-V2-Small (Apache-2.0): RELATIVE inverse depth -- larger is nearer, in no unit. The picture is
// resized to the model's fixed side (518) by PIL BICUBIC, as HF's DPT processor resizes, /255, ImageNet mean/std;
// the map comes back at the picture's own size through a float bicubic (PyTorch's: a = -0.75, half-pixel,
// borders clamped), as HF's post-processing interpolates it.

pub const Depth = struct {
    v: []f32, // owned, w * h, row-major
    ms: f64,
};

fn cubicW(t0: f64) f64 {
    const a = -0.75;
    const t = @abs(t0);
    if (t <= 1.0) return ((a + 2.0) * t - (a + 3.0)) * t * t + 1.0;
    if (t < 2.0) return ((a * t - 5.0 * a) * t + 8.0 * a) * t - 4.0 * a;
    return 0.0;
}

/// A float map resized by PyTorch's bicubic (align_corners false), one axis then the other.
fn resizeCubicF(src: []const f32, w: usize, h: usize, ow: usize, oh: usize, out: []f32) !void {
    const mid = try gpa.alloc(f32, ow * h);
    defer gpa.free(mid);
    const sx = @as(f64, @floatFromInt(w)) / @as(f64, @floatFromInt(ow));
    const sy = @as(f64, @floatFromInt(h)) / @as(f64, @floatFromInt(oh));
    for (0..ow) |x| {
        const cx = (@as(f64, @floatFromInt(x)) + 0.5) * sx - 0.5;
        const fx: i64 = @intFromFloat(@floor(cx));
        var wts: [4]f64 = undefined;
        var idx: [4]usize = undefined;
        for (0..4) |k| {
            const kk = fx - 1 + @as(i64, @intCast(k));
            wts[k] = cubicW(cx - @as(f64, @floatFromInt(kk)));
            idx[k] = @intCast(std.math.clamp(kk, 0, @as(i64, @intCast(w)) - 1));
        }
        for (0..h) |y| {
            var acc: f64 = 0;
            for (0..4) |k| acc += wts[k] * src[y * w + idx[k]];
            mid[y * ow + x] = @floatCast(acc);
        }
    }
    for (0..oh) |y| {
        const cy = (@as(f64, @floatFromInt(y)) + 0.5) * sy - 0.5;
        const fy: i64 = @intFromFloat(@floor(cy));
        var wts: [4]f64 = undefined;
        var idx: [4]usize = undefined;
        for (0..4) |k| {
            const kk = fy - 1 + @as(i64, @intCast(k));
            wts[k] = cubicW(cy - @as(f64, @floatFromInt(kk)));
            idx[k] = @intCast(std.math.clamp(kk, 0, @as(i64, @intCast(h)) - 1));
        }
        for (0..ow) |x| {
            var acc: f64 = 0;
            for (0..4) |k| acc += wts[k] * mid[idx[k] * ow + x];
            out[y * ow + x] = @floatCast(acc);
        }
    }
}

pub fn depth(model_path: []const u8, px: []const u8, w: usize, h: usize, c: usize, n_threads: c_int) !Depth {
    const m = try modelFor(model_path);
    const side: usize = if (m.input_w > 0) m.input_w else 518;
    const rgb = try toRgb(px, w, h, c);
    defer gpa.free(rgb);
    const rs = try gpa.alloc(u8, side * side * 3);
    defer gpa.free(rs);
    try resizePilXT(.bicubic, 3, rgb, w, h, side, side, rs);
    const plane = side * side;
    const t = try gpa.alloc(f32, plane * 3);
    defer gpa.free(t);
    const mean = [3]f32{ 0.485, 0.456, 0.406 };
    const stdv = [3]f32{ 0.229, 0.224, 0.225 };
    for (0..plane) |i| {
        for (0..3) |ch| t[ch * plane + i] = (@as(f32, @floatFromInt(rs[i * 3 + ch])) / 255.0 - mean[ch]) / stdv[ch];
    }
    const o = try graph.run(m, t, .{ 1, 3, @intCast(side), @intCast(side) }, n_threads);
    defer gpa.free(o.data);
    const out = try gpa.alloc(f32, w * h);
    errdefer gpa.free(out);
    try resizeCubicF(o.data[0..plane], side, side, w, h, out);
    return .{ .v = out, .ms = o.ms };
}

// ------------------------------------------------------------------ promptable masks (IM6: MobileSAM)
// MobileSAM (Apache-2.0): a TinyViT encoder makes the picture's embedding ONCE (256 x 64 x 64), and a small decoder
// turns each prompt -- a point on the object, or a box around it -- into a mask. Computed as SAM's predictor
// computes it: the longest side resized to 1024 by PIL BILINEAR (torchvision's resize of a PIL image), the rest of
// the 1024 x 1024 square filled with the pixel mean (the exported encoder normalises, then pads with zeros, which
// is the same picture); the prompt's points in that resized frame, a lone point followed by SAM's padding point
// (0, 0, label -1). The decoder's four masks come back with their predicted IoUs and one is chosen as the export
// chooses it -- argmax of iou + (points - 2.5) x [1000, 0, 0, 0] -- then resized as SAM's postprocess_masks does:
// bilinear to 1024, cropped to the resized picture, bilinear to the picture, logits above 0.

pub const SamEmbedding = struct { id: u32, v: []f32, w: usize, h: usize, rw: usize, rh: usize, key: u64 };

var sam_list: std.ArrayList(SamEmbedding) = .empty;
var sam_next: u32 = 1;
const SAM_KEEP = 8; // embeddings kept at once (4 MB each); the oldest goes first

const SAM_MEAN = [3]f32{ 123.675, 116.28, 103.53 };

pub fn samEmbed(model_path: []const u8, px: []const u8, w: usize, h: usize, c: usize, n_threads: c_int) !struct { id: u32, ms: f64, cached: bool } {
    // the same pixels (and the same encoder) come back as the same embedding: a picture is encoded once,
    // however many prompts follow
    var hs = std.hash.Wyhash.init(0);
    hs.update(model_path);
    hs.update(std.mem.asBytes(&[3]usize{ w, h, c }));
    hs.update(px);
    const key = hs.final();
    for (sam_list.items, 0..) |e, k| {
        if (e.key == key) {
            const keep = sam_list.orderedRemove(k);
            try sam_list.append(gpa, keep);
            return .{ .id = keep.id, .ms = 0, .cached = true };
        }
    }
    const m = try modelFor(model_path);
    const side: usize = 1024;
    const scale = @as(f64, @floatFromInt(side)) / @as(f64, @floatFromInt(@max(w, h)));
    const rw: usize = @intFromFloat(@as(f64, @floatFromInt(w)) * scale + 0.5);
    const rh: usize = @intFromFloat(@as(f64, @floatFromInt(h)) * scale + 0.5);
    const rgb = try toRgb(px, w, h, c);
    defer gpa.free(rgb);
    const rs = try gpa.alloc(u8, rw * rh * 3);
    defer gpa.free(rs);
    try resizePilXT(.bilinear, 3, rgb, w, h, rw, rh, rs);
    const t = try gpa.alloc(f32, side * side * 3);
    defer gpa.free(t);
    for (0..side) |y| {
        for (0..side) |x| {
            const o = (y * side + x) * 3;
            for (0..3) |ch| t[o + ch] = if (x < rw and y < rh) @floatFromInt(rs[(y * rw + x) * 3 + ch]) else SAM_MEAN[ch];
        }
    }
    const out = try graph.runInputs(m, &.{t}, n_threads);
    errdefer gpa.free(out.data);
    if (sam_list.items.len >= SAM_KEEP) {
        gpa.free(sam_list.items[0].v);
        _ = sam_list.orderedRemove(0);
    }
    const id = sam_next;
    sam_next += 1;
    try sam_list.append(gpa, .{ .id = id, .v = out.data, .w = w, .h = h, .rw = rw, .rh = rh, .key = key });
    return .{ .id = id, .ms = out.ms, .cached = false };
}

pub fn samFree(id: u32) void {
    for (sam_list.items, 0..) |e, k| {
        if (e.id == id) {
            gpa.free(e.v);
            _ = sam_list.orderedRemove(k);
            return;
        }
    }
}

fn samFind(id: u32) ?SamEmbedding {
    for (sam_list.items) |e| if (e.id == id) return e;
    return null;
}

/// A float map resized as PyTorch's bilinear without aligned corners (half-pixel centres, borders clamped).
fn resizeLinearF(src: []const f32, w: usize, h: usize, sw: usize, ow: usize, oh: usize, out: []f32) !void {
    // (src rows are sw apart: a crop of a wider map is read in place)
    const fx = try gpa.alloc(f32, ow);
    defer gpa.free(fx);
    const ix = try gpa.alloc(usize, ow);
    defer gpa.free(ix);
    const sx = @as(f64, @floatFromInt(w)) / @as(f64, @floatFromInt(ow));
    const sy = @as(f64, @floatFromInt(h)) / @as(f64, @floatFromInt(oh));
    for (0..ow) |x| {
        const cx = @max(0.0, (@as(f64, @floatFromInt(x)) + 0.5) * sx - 0.5);
        const x0: usize = @min(@as(usize, @intFromFloat(@floor(cx))), w - 1);
        ix[x] = x0;
        fx[x] = @floatCast(cx - @as(f64, @floatFromInt(x0)));
    }
    for (0..oh) |y| {
        const cy = @max(0.0, (@as(f64, @floatFromInt(y)) + 0.5) * sy - 0.5);
        const y0: usize = @min(@as(usize, @intFromFloat(@floor(cy))), h - 1);
        const y1 = @min(y0 + 1, h - 1);
        const ly: f32 = @floatCast(cy - @as(f64, @floatFromInt(y0)));
        for (0..ow) |x| {
            const x0 = ix[x];
            const x1 = @min(x0 + 1, w - 1);
            const lx = fx[x];
            const top = src[y0 * sw + x0] * (1 - lx) + src[y0 * sw + x1] * lx;
            const bot = src[y1 * sw + x0] * (1 - lx) + src[y1 * sw + x1] * lx;
            out[y * ow + x] = top * (1 - ly) + bot * ly;
        }
    }
}

pub const SamMask = struct { px: []u8, iou: f32, which: usize, ms: f64 };

/// The mask for a prompt of exactly two points in the PICTURE's pixels: a point and SAM's padding point
/// (labels 1 or 0, then -1), or a box's two corners (labels 2, 3).
pub fn samMask(model_path: []const u8, id: u32, pts: [4]f32, labels: [2]f32, n_threads: c_int) !SamMask {
    const m = try modelFor(model_path);
    const e = samFind(id) orelse {
        graph.setError("no picture embedding {d} (an embedding is kept until {d} newer ones exist)", .{ id, SAM_KEEP });
        return error.NoEmbedding;
    };
    const kx = @as(f32, @floatFromInt(e.rw)) / @as(f32, @floatFromInt(e.w));
    const ky = @as(f32, @floatFromInt(e.rh)) / @as(f32, @floatFromInt(e.h));
    var coords = [4]f32{ pts[0] * kx, pts[1] * ky, pts[2] * kx, pts[3] * ky };
    if (labels[1] == -1) {
        coords[2] = 0;
        coords[3] = 0;
    }
    const o = try graph.runInputs(m, &.{ e.v, &coords, &labels }, n_threads);
    defer gpa.free(o.data);
    const lp: usize = 256 * 256;
    if (o.data.len != 4 * lp + 4) {
        graph.setError("the decoder gave {d} values, not 4 masks and 4 scores", .{o.data.len});
        return error.BadDecoder;
    }
    const ious = o.data[4 * lp ..];
    var best: usize = 0;
    var bs: f32 = -std.math.inf(f32);
    for (0..4) |k| {
        const s = ious[k] + (if (k == 0) @as(f32, (2.0 - 2.5) * 1000.0) else 0.0);
        if (s > bs) {
            bs = s;
            best = k;
        }
    }
    const big = try gpa.alloc(f32, 1024 * 1024);
    defer gpa.free(big);
    try resizeLinearF(o.data[best * lp .. (best + 1) * lp], 256, 256, 256, 1024, 1024, big);
    const fin = try gpa.alloc(f32, e.w * e.h);
    defer gpa.free(fin);
    try resizeLinearF(big, e.rw, e.rh, 1024, e.w, e.h, fin);
    const out = try gpa.alloc(u8, e.w * e.h);
    for (fin, 0..) |v, i| out[i] = if (v > 0) 255 else 0;
    return .{ .px = out, .iou = ious[best], .which = best, .ms = o.ms };
}
