//! owl.zig -- find what WORDS name in a picture: OWL-ViT (Google, Apache-2.0; google/owlvit-base-patch32) on ggml (IM9f).
//!
//! The vision graph (a CLIP ViT-B/32 at 768 x 768, 576 patches; onnx_to_gguf.py's output of owlvit_export.py) gives, per patch, a class embedding
//! (512), a logit shift, a raw logit scale and a box (cx, cy, w, h in 0..1). The query side is clip_text.zig (the same CLIP space). What this
//! file does is what the reference does AROUND the graph, which the converter's op set cannot hold:
//!   preprocess   the picture is SQUASHED to 768 x 768 (PIL bicubic, aspect ratio not kept, no crop) and normalised with CLIP's mean and std
//!   per patch    e = the class embedding, L2-normalised; scale = elu(raw) + 1; logit(q) = (e . query_q + shift) * scale; score = sigmoid(logit)
//!   per query    the patches at or above the threshold, boxes scaled back to the picture's own pixels, non-maximum suppression within the query
//! A patch may fire for two queries ("cat", "animal"): each query is answered on its own, which is what asking for it means. The reference's own
//! post-processing keeps one label per patch and does no suppression; the engine's per-patch SCORES are the reference's (held to it in the guard).
//!
//! Costs kept honest: the graph is the expensive step (about 0.7 s on the CPU), so the LAST picture's graph output is kept and a second set of
//! words about the same picture pays only for the words; a query's embedding is kept by its text for the process.

const std = @import("std");
const graph = @import("ocr_graph.zig");
const vis = @import("vision.zig");
const clip = @import("clip_text.zig");

const gpa = std.heap.c_allocator;

const side: usize = 768;
const patches: usize = 576;
const dim: usize = 512;
const width: usize = 518; // dim + shift + scale + 4 box numbers
const mean = [3]f32{ 0.48145466, 0.4578275, 0.40821073 };
const stdv = [3]f32{ 0.26862954, 0.26130258, 0.27577711 };

var last_key: u64 = 0;
var last_feats: ?[]f32 = null;
var last_ms: f64 = 0;

var q_keys: std.ArrayList([]u8) = .empty;
var q_vecs: std.ArrayList([]f32) = .empty;

pub const Found = struct {
    dets: []vis.Det, // owned: x, y, w, h in the picture's pixels; class = the index of the query (0-based)
    ms: f64, // the graph's compute time for THIS call (0 when the picture's features were kept)
    cached: bool,
};

fn fnv(px: []const u8, w: usize, h: usize, c: usize) u64 {
    var hsh: u64 = 0xcbf29ce484222325;
    for (px) |b| {
        hsh ^= b;
        hsh *%= 0x100000001b3;
    }
    hsh ^= @as(u64, w) << 40 ^ @as(u64, h) << 20 ^ @as(u64, c);
    return hsh;
}

/// The pixel tensor the graph reads: NCHW, 768 x 768, CLIP-normalised. Caller frees.
pub fn pixels(px: []const u8, w: usize, h: usize, c: usize) ![]f32 {
    const rgb = try vis.toRgb(px, w, h, c);
    defer gpa.free(rgb);
    const rs = try gpa.alloc(u8, side * side * 3);
    defer gpa.free(rs);
    try vis.resizePilXT(.bicubic, 3, rgb, w, h, side, side, rs);
    const plane = side * side;
    const t = try gpa.alloc(f32, plane * 3);
    for (0..plane) |i| {
        for (0..3) |ch| t[ch * plane + i] = (@as(f32, @floatFromInt(rs[i * 3 + ch])) / 255.0 - mean[ch]) / stdv[ch];
    }
    return t;
}

fn features(vision_path: []const u8, px: []const u8, w: usize, h: usize, c: usize, n_threads: c_int) !struct { f: []const f32, ms: f64, cached: bool } {
    const k = fnv(px, w, h, c);
    if (last_feats) |f| {
        if (k == last_key) return .{ .f = f, .ms = 0, .cached = true };
    }
    const m = try vis.modelFor(vision_path);
    const t = try pixels(px, w, h, c);
    defer gpa.free(t);
    const o = try graph.run(m, t, .{ 1, 3, @intCast(side), @intCast(side) }, n_threads);
    if (o.data.len != patches * width) {
        graph.setError("owl: the graph gave {d} numbers, {d} were expected", .{ o.data.len, patches * width });
        gpa.free(o.data);
        return error.BadShape;
    }
    if (last_feats) |old| gpa.free(old);
    last_feats = o.data;
    last_key = k;
    last_ms = o.ms;
    return .{ .f = o.data, .ms = o.ms, .cached = false };
}

fn queryVec(text_path: []const u8, vocab: []const u8, merges: []const u8, q: []const u8, n_threads: c_int) ![]const f32 {
    var kb: std.ArrayList(u8) = .empty;
    defer kb.deinit(gpa);
    try kb.appendSlice(gpa, text_path);
    try kb.append(gpa, 0);
    try kb.appendSlice(gpa, q);
    for (q_keys.items, 0..) |kk, i| {
        if (std.mem.eql(u8, kk, kb.items)) return q_vecs.items[i];
    }
    const e = try clip.embed(text_path, vocab, merges, q, n_threads);
    try q_keys.append(gpa, try gpa.dupe(u8, kb.items));
    try q_vecs.append(gpa, e.v);
    return e.v;
}

fn sigmoid(x: f32) f32 {
    return 1.0 / (1.0 + @exp(-x));
}

/// queries: the words, separated by newlines. Every patch's score for every query is computed; those at or above thr become boxes.
pub fn find(vision_path: []const u8, text_path: []const u8, vocab: []const u8, merges: []const u8, queries: []const u8, px: []const u8, w: usize, h: usize, c: usize, thr: f32, nms_thr: f32, n_threads: c_int) !Found {
    var qv: std.ArrayList([]const f32) = .empty;
    defer qv.deinit(gpa);
    var it = std.mem.splitScalar(u8, queries, '\n');
    while (it.next()) |q| try qv.append(gpa, try queryVec(text_path, vocab, merges, q, n_threads));
    const fe = try features(vision_path, px, w, h, c, n_threads);
    var cands: std.ArrayList(vis.Det) = .empty;
    defer cands.deinit(gpa);
    const fw: f32 = @floatFromInt(w);
    const fh: f32 = @floatFromInt(h);
    var e: [dim]f32 = undefined;
    for (0..patches) |p| {
        const row = fe.f[p * width .. (p + 1) * width];
        var ss: f64 = 0;
        for (0..dim) |i| ss += @as(f64, row[i]) * row[i];
        const inv: f32 = @floatCast(1.0 / (@sqrt(ss) + 1e-6));
        for (0..dim) |i| e[i] = row[i] * inv;
        const shift = row[dim];
        const raw = row[dim + 1];
        const scale: f32 = if (raw > 0) raw + 1.0 else @exp(raw);
        for (qv.items, 0..) |q, qi| {
            var dot: f32 = 0;
            for (0..dim) |i| dot += e[i] * q[i];
            const score = sigmoid((dot + shift) * scale);
            if (score < thr) continue;
            const cx = row[dim + 2];
            const cy = row[dim + 3];
            const bw = row[dim + 4];
            const bh = row[dim + 5];
            const x0 = @max(0.0, (cx - bw / 2) * fw);
            const y0 = @max(0.0, (cy - bh / 2) * fh);
            const x1 = @min(fw, (cx + bw / 2) * fw);
            const y1 = @min(fh, (cy + bh / 2) * fh);
            if (x1 <= x0 or y1 <= y0) continue;
            try cands.append(gpa, .{ .x = x0, .y = y0, .w = x1 - x0, .h = y1 - y0, .score = score, .class = qi });
        }
    }
    return .{ .dets = try vis.nms(cands.items, nms_thr, true), .ms = fe.ms, .cached = fe.cached };
}

/// Every patch's raw numbers for the reference check: the engine's score for each patch and query, without threshold or suppression. Caller frees.
pub fn scores(vision_path: []const u8, text_path: []const u8, vocab: []const u8, merges: []const u8, queries: []const u8, px: []const u8, w: usize, h: usize, c: usize, n_threads: c_int) ![]f32 {
    var qv: std.ArrayList([]const f32) = .empty;
    defer qv.deinit(gpa);
    var it = std.mem.splitScalar(u8, queries, '\n');
    while (it.next()) |q| try qv.append(gpa, try queryVec(text_path, vocab, merges, q, n_threads));
    const fe = try features(vision_path, px, w, h, c, n_threads);
    const out = try gpa.alloc(f32, patches * qv.items.len);
    var e: [dim]f32 = undefined;
    for (0..patches) |p| {
        const row = fe.f[p * width .. (p + 1) * width];
        var ss: f64 = 0;
        for (0..dim) |i| ss += @as(f64, row[i]) * row[i];
        const inv: f32 = @floatCast(1.0 / (@sqrt(ss) + 1e-6));
        for (0..dim) |i| e[i] = row[i] * inv;
        const raw = row[dim + 1];
        const scale: f32 = if (raw > 0) raw + 1.0 else @exp(raw);
        for (qv.items, 0..) |q, qi| {
            var dot: f32 = 0;
            for (0..dim) |i| dot += e[i] * q[i];
            out[p * qv.items.len + qi] = (dot + row[dim]) * scale; // the LOGIT, as the reference's logits.npy holds it
        }
    }
    return out;
}
