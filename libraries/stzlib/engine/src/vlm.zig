//! vlm.zig -- the vision half of a vision-language model (IM7 of SOFTANZA_IMAGE_INTELLIGENCE.md).
//!
//! SmolVLM's picture path, on ggml: a SigLIP tower read from the model's projector GGUF (the "mmproj" file
//! llama.cpp's converter writes, clip.projector_type = idefics3), then idefics3's connector -- a pixel
//! shuffle that folds each 4 x 4 block of patches into one token, and one linear layer into the decoder's
//! width. A 512 x 512 picture becomes 32 x 32 patches, then 64 embeddings the decoder (neural_gen.zig)
//! reads in place of 64 <image> tokens.
//!
//! The projector is its OWN model slot: it never touches the decoder's. The graph is built by hand from
//! the GGUF's tensors (llama.cpp's MIT clip.cpp read as reference, not vendored) and its parity is with
//! Hugging Face's own SmolVLM code loaded with the same weights (base/test/image/_rig/smolvlm_reference.py).
//!
//! The pixels are prepared as SmolVLMImageProcessor prepares them without tiling: RGB, two PIL Lanczos resizes
//! (the long side to the tower's size, then the square), then (v / 255 - mean) / std per channel.

const std = @import("std");
const og = @import("ocr_graph.zig");
const vision = @import("vision.zig");
const nvit = @import("neural_vit.zig");
const digest = @import("model_digest.zig");
const c = og.c;
const gr = @import("gguf_read.zig"); // SECURITY-MODELDATA-01b

const gpa = std.heap.c_allocator;

pub const Projector = struct {
    gg: *c.gguf_context,
    ctx: *c.ggml_context,
    path: []u8,
    n_layer: usize,
    hidden: usize,
    heads: usize,
    image: usize,
    patch: usize,
    scale: usize,
    eps: f32,
    mean: [3]f32,
    sd: [3]f32,
    n_out: usize,

    /// tokens one picture becomes: (image / patch / scale)^2
    pub fn tokens(p: *const Projector) usize {
        const g = p.image / p.patch / p.scale;
        return g * g;
    }
};

var g_proj: ?Projector = null;
var g_err: [256]u8 = undefined;
var g_err_len: usize = 0;

pub fn lastError() []const u8 {
    return g_err[0..g_err_len];
}

fn setError(comptime fmt: []const u8, args: anytype) void {
    const s = std.fmt.bufPrint(&g_err, fmt, args) catch g_err[0..0];
    g_err_len = s.len;
}

fn kvInt(gg: *c.gguf_context, key: [*:0]const u8) ?usize {
    // a size: non-negative and bounded (u64 max panicked in @intCast); anything else is absent
    const v = gr.intAt(gg, gr.find(gg, key)) orelse return null;
    if (v < 0 or v > std.math.maxInt(i32)) return null;
    return @intCast(v);
}

fn kvF32(gg: *c.gguf_context, key: [*:0]const u8, dflt: f32) f32 {
    return gr.float(gg, key, dflt);
}

fn kvF32x3(gg: *c.gguf_context, key: [*:0]const u8, dflt: [3]f32) [3]f32 {
    // three f32s, or the default: an array of strings asserted inside gguf_get_arr_data
    const p = gr.arrOf(f32, gg, gr.find(gg, key)) orelse return dflt;
    if (p.len != 3) return dflt;
    return .{ p[0], p[1], p[2] };
}

fn tensor(p: *const Projector, comptime fmt: []const u8, args: anytype) ?*c.ggml_tensor {
    var buf: [96]u8 = undefined;
    const name = std.fmt.bufPrintZ(&buf, fmt, args) catch return null;
    return c.ggml_get_tensor(p.ctx, name.ptr);
}

// THE PROJECTOR'S CONTRACT (SECURITY-MODELDATA-01c, 2026-11-08). encode() below takes the tower's weights by name and
// hands ggml the shapes it trusts; a file whose weights disagree with its own sizes failed a GGML_ASSERT and ended
// the process. So a projector loads only when every weight the tower reads (and the GPU tower beside it) is there and
// shaped to its sizes: the patch kernel [patch, patch, 3, D], the positions [D, patches], Q K V and the output [D, D],
// one MLP pair [D, F] and [F, D], the connector [scale^2 * D, n_out], and every bias and norm a vector of f32.
fn pMat(p: *const Projector, comptime fmt: []const u8, args: anytype, ne: [4]i64) bool {
    const t = tensor(p, fmt, args) orelse return false;
    return t.*.ne[0] == ne[0] and t.*.ne[1] == ne[1] and t.*.ne[2] == ne[2] and t.*.ne[3] == ne[3];
}
fn pVec(p: *const Projector, comptime fmt: []const u8, args: anytype, n: i64) bool {
    const t = tensor(p, fmt, args) orelse return false;
    return t.*.type == c.GGML_TYPE_F32 and t.*.ne[0] == n and t.*.ne[1] == 1 and t.*.ne[2] == 1 and t.*.ne[3] == 1;
}

fn contract(p: *const Projector) bool {
    if (p.hidden > 1 << 16 or p.image > 4096 or p.patch > p.image or p.n_layer > 1024 or p.hidden % p.heads != 0) return false;
    const D: i64 = @intCast(p.hidden);
    const P: i64 = @intCast(p.patch);
    const g: i64 = @intCast(p.image / p.patch);
    const s: i64 = @intCast(p.scale);
    if (!pMat(p, "v.patch_embd.weight", .{}, .{ P, P, 3, D }) or !pVec(p, "v.patch_embd.bias", .{}, D)) return false;
    if (!pMat(p, "v.position_embd.weight", .{}, .{ D, g * g, 1, 1 })) return false;
    for (0..p.n_layer) |L| {
        for ([_][]const u8{ "attn_q", "attn_k", "attn_v", "attn_out" }) |w| {
            if (!pMat(p, "v.blk.{d}.{s}.weight", .{ L, w }, .{ D, D, 1, 1 }) or !pVec(p, "v.blk.{d}.{s}.bias", .{ L, w }, D)) return false;
        }
        for ([_][]const u8{ "ln1", "ln2" }) |w| {
            if (!pVec(p, "v.blk.{d}.{s}.weight", .{ L, w }, D) or !pVec(p, "v.blk.{d}.{s}.bias", .{ L, w }, D)) return false;
        }
        // the MLP pair under either name (see encode): the one that reads D first, F wide, then back to D
        const up = tensor(p, "v.blk.{d}.ffn_up.weight", .{L}) orelse return false;
        const first = if (up.*.ne[0] == D) "ffn_up" else "ffn_down";
        const second = if (up.*.ne[0] == D) "ffn_down" else "ffn_up";
        const w1 = tensor(p, "v.blk.{d}.{s}.weight", .{ L, first }) orelse return false;
        const F = w1.*.ne[1];
        if (F < 1 or !pMat(p, "v.blk.{d}.{s}.weight", .{ L, first }, .{ D, F, 1, 1 }) or !pVec(p, "v.blk.{d}.{s}.bias", .{ L, first }, F)) return false;
        if (!pMat(p, "v.blk.{d}.{s}.weight", .{ L, second }, .{ F, D, 1, 1 }) or !pVec(p, "v.blk.{d}.{s}.bias", .{ L, second }, D)) return false;
    }
    if (!pVec(p, "v.post_ln.weight", .{}, D) or !pVec(p, "v.post_ln.bias", .{}, D)) return false;
    const fc = tensor(p, "mm.model.fc.weight", .{}) orelse return false;
    return fc.*.ne[0] == s * s * D and fc.*.ne[1] >= 1 and fc.*.ne[2] == 1 and fc.*.ne[3] == 1;
}

/// SECURITY-MODELDATA-01c, the fuzzer's door: load a projector (digest gate, sizes, contract) and, when run is 1,
/// encode one grey picture through it. 1 it loaded (and ran), 0 it was refused.
pub export fn stz_vlm_probe(path: [*:0]const u8, run: c_int) callconv(.c) c_int {
    const p = load(std.mem.span(path)) orelse return 0;
    if (run != 1) return 1;
    const n_in = 3 * p.image * p.image;
    const input = gpa.alloc(f32, n_in) catch return 0;
    defer gpa.free(input);
    @memset(input, 0);
    const out = gpa.alloc(f32, p.tokens() * p.n_out) catch return 0;
    defer gpa.free(out);
    encode(p, input, 2, out) catch return 0;
    return 1;
}

pub fn free() void {
    nvit.invalidate();
    if (g_proj) |*p| {
        c.ggml_free(p.ctx);
        c.gguf_free(p.gg);
        gpa.free(p.path);
    }
    g_proj = null;
}

/// The projector at `path`, loaded once and kept while the same path is asked for.
pub fn load(path: []const u8) ?*Projector {
    if (g_proj) |*p| {
        if (std.mem.eql(u8, p.path, path)) return p;
    }
    free();
    const pz = gpa.dupeZ(u8, path) catch return null;
    defer gpa.free(pz);
    // parsed only once its SHA-256 is the recorded one, like the decoder beside it (model_digest.zig)
    const vd = digest.verify(pz.ptr);
    if (vd != digest.OK) {
        setError("vlm: the projector {s} was refused before parsing ({s})", .{ path, if (vd == digest.ERR_MISMATCH) "its sha256 is not the recorded one" else if (vd == digest.ERR_UNKNOWN) "no recorded sha256: no SHA256SUMS line beside it" else "unreadable" });
        return null;
    }
    var ctx: ?*c.ggml_context = null;
    const gg = c.gguf_init_from_file(pz.ptr, .{ .no_alloc = false, .ctx = &ctx }) orelse {
        setError("vlm: cannot read the projector {s}", .{path});
        return null;
    };
    const kind: []const u8 = gr.strOr(gg, "clip.projector_type", "");
    if (!std.mem.eql(u8, kind, "idefics3")) {
        setError("vlm: the projector type is '{s}', and only idefics3 (SmolVLM, Granite-Docling) is built", .{kind});
        c.ggml_free(ctx);
        c.gguf_free(gg);
        return null;
    }
    var p = Projector{
        .gg = gg,
        .ctx = ctx.?,
        .path = gpa.dupe(u8, path) catch return null,
        .n_layer = kvInt(gg, "clip.vision.block_count") orelse 0,
        .hidden = kvInt(gg, "clip.vision.embedding_length") orelse 0,
        .heads = kvInt(gg, "clip.vision.attention.head_count") orelse 0,
        .image = kvInt(gg, "clip.vision.image_size") orelse 0,
        .patch = kvInt(gg, "clip.vision.patch_size") orelse 0,
        .scale = kvInt(gg, "clip.vision.projector.scale_factor") orelse 0,
        .eps = kvF32(gg, "clip.vision.attention.layer_norm_epsilon", 1e-6),
        .mean = kvF32x3(gg, "clip.vision.image_mean", .{ 0.5, 0.5, 0.5 }),
        .sd = kvF32x3(gg, "clip.vision.image_std", .{ 0.5, 0.5, 0.5 }),
        .n_out = 0,
    };
    const fc = c.ggml_get_tensor(p.ctx, "mm.model.fc.weight");
    if (p.n_layer == 0 or p.hidden == 0 or p.heads == 0 or p.patch == 0 or p.scale == 0 or fc == null or
        p.image % (p.patch * p.scale) != 0)
    {
        setError("vlm: the projector {s} lacks a size or the connector's weight", .{path});
        c.ggml_free(p.ctx);
        c.gguf_free(gg);
        gpa.free(p.path);
        return null;
    }
    p.n_out = @intCast(fc.?.*.ne[1]);
    if (!contract(&p)) {
        setError("vlm: the projector {s} has a weight whose shape disagrees with its sizes", .{path});
        c.ggml_free(p.ctx);
        c.gguf_free(gg);
        gpa.free(p.path);
        return null;
    }
    g_proj = p;
    return &g_proj.?;
}

/// The tower's input from a picture of `ch` interleaved channels (1, 3 or 4; alpha is dropped as PIL's
/// convert("RGB") drops it): PIL's Lanczos resize to image x image, then (v / 255 - mean) / std, channel-major.
pub fn pixelsFor(p: *const Projector, px: []const u8, w: usize, h: usize, ch: usize, out: []f32) !void {
    const S = p.image;
    const rgb = try gpa.alloc(u8, w * h * 3);
    defer gpa.free(rgb);
    for (0..w * h) |i| {
        for (0..3) |k| rgb[i * 3 + k] = px[i * ch + (if (ch >= 3) k else 0)];
    }
    // TWO resizes, as SmolVLMImageProcessor makes them without tiling: the longest side to S with the aspect
    // kept (the other side int(S / aspect), made even), then that picture to S x S. One direct resize differs
    // on every picture that is not square (cosine 0.95 against the reference on a 3:2 street)
    var mw: usize = S;
    var mh: usize = S;
    if (w >= h) {
        mh = @intFromFloat(@floor(@as(f64, @floatFromInt(S)) / (@as(f64, @floatFromInt(w)) / @as(f64, @floatFromInt(h)))));
        if (mh % 2 != 0) mh += 1;
    } else {
        mw = @intFromFloat(@floor(@as(f64, @floatFromInt(S)) * (@as(f64, @floatFromInt(w)) / @as(f64, @floatFromInt(h)))));
        if (mw % 2 != 0) mw += 1;
    }
    mw = @max(mw, 1);
    mh = @max(mh, 1);
    const mid = try gpa.alloc(u8, mw * mh * 3);
    defer gpa.free(mid);
    try vision.resizePilXT(.lanczos, 3, rgb, w, h, mw, mh, mid);
    const small = try gpa.alloc(u8, S * S * 3);
    defer gpa.free(small);
    try vision.resizePilXT(.lanczos, 3, mid, mw, mh, S, S, small);
    for (0..3) |k| {
        for (0..S * S) |i| out[k * S * S + i] = (@as(f32, @floatFromInt(small[i * 3 + k])) / 255.0 - p.mean[k]) / p.sd[k];
    }
}

// ---- a PAGE: Idefics3's tiles (Granite-Docling) ---------------------------------------------------------------
//
// A page is too wide a view for one 512 x 512 square, so Idefics3ImageProcessor reads it as tiles: the page is
// resized so its long side is `longest` (2048; the other side int(), made even), each side is then rounded UP to a
// multiple of the tile (the other side recomputed from the new long side), the result is cut into rows x cols
// tiles of tile x tile, row by row, and one more view follows them: the whole page squeezed to tile x tile. Each
// view becomes 64 rows for the decoder, so a 150 dpi A4 page (4 x 3 tiles) is 13 views and 832 rows.

pub const Grid = struct {
    rows: usize, // 0 and 0 when the page is a single view
    cols: usize,
    w: usize, // the page after both resizes (the tiles' canvas)
    h: usize,
    mid_w: usize, // the page after the first resize
    mid_h: usize,

    /// views the page becomes: its tiles, then the whole page
    pub fn views(g: Grid) usize {
        return if (g.rows == 0) 1 else g.rows * g.cols + 1;
    }
};

pub fn gridFor(w: usize, h: usize, longest: usize, tile: usize) Grid {
    const fw: f64 = @floatFromInt(w);
    const fh: f64 = @floatFromInt(h);
    const aspect = fw / fh;
    var mw: usize = longest;
    var mh: usize = longest;
    if (w >= h) {
        mh = @intFromFloat(@floor(@as(f64, @floatFromInt(longest)) / aspect));
        if (mh % 2 != 0) mh += 1;
    } else {
        mw = @intFromFloat(@floor(@as(f64, @floatFromInt(longest)) * aspect));
        if (mw % 2 != 0) mw += 1;
    }
    mw = @max(mw, 1);
    mh = @max(mh, 1);
    // each side rounded up to a multiple of the tile, the aspect kept from the new long side
    const ar = @as(f64, @floatFromInt(mw)) / @as(f64, @floatFromInt(mh));
    var ow: usize = mw;
    var oh: usize = mh;
    if (mw >= mh) {
        ow = (mw + tile - 1) / tile * tile;
        oh = @intFromFloat(@floor(@as(f64, @floatFromInt(ow)) / ar));
        oh = (oh + tile - 1) / tile * tile;
    } else {
        oh = (mh + tile - 1) / tile * tile;
        ow = @intFromFloat(@floor(@as(f64, @floatFromInt(oh)) * ar));
        ow = (ow + tile - 1) / tile * tile;
    }
    const split = oh > tile or ow > tile;
    return .{ .rows = if (split) oh / tile else 0, .cols = if (split) ow / tile else 0, .w = ow, .h = oh, .mid_w = mw, .mid_h = mh };
}

fn normalizeInto(p: *const Projector, small: []const u8, out: []f32) void {
    const n = p.image * p.image;
    for (0..3) |k| {
        for (0..n) |i| out[k * n + i] = (@as(f32, @floatFromInt(small[i * 3 + k])) / 255.0 - p.mean[k]) / p.sd[k];
    }
}

/// The tower's inputs for a page: grid.views() x (3 x image x image), channel-major, the tiles row by row and the
/// whole page last (the order Idefics3 prompts them in). `out` must hold grid.views() * 3 * image * image floats.
pub fn pageViews(p: *const Projector, px: []const u8, w: usize, h: usize, ch: usize, longest: usize, out: []f32) !Grid {
    const S = p.image;
    const g = gridFor(w, h, longest, S);
    if (out.len != g.views() * 3 * S * S) return error.SizeMismatch;
    const rgb = try gpa.alloc(u8, w * h * 3);
    defer gpa.free(rgb);
    for (0..w * h) |i| {
        for (0..3) |k| rgb[i * 3 + k] = px[i * ch + (if (ch >= 3) k else 0)];
    }
    const mid = try gpa.alloc(u8, g.mid_w * g.mid_h * 3);
    defer gpa.free(mid);
    try vision.resizePilXT(.lanczos, 3, rgb, w, h, g.mid_w, g.mid_h, mid);
    const canvas = try gpa.alloc(u8, g.w * g.h * 3);
    defer gpa.free(canvas);
    try vision.resizePilXT(.lanczos, 3, mid, g.mid_w, g.mid_h, g.w, g.h, canvas);
    const view = 3 * S * S;
    const cut = try gpa.alloc(u8, S * S * 3);
    defer gpa.free(cut);
    if (g.rows == 0) {
        normalizeInto(p, canvas, out[0..view]);
        return g;
    }
    for (0..g.rows) |r| {
        for (0..g.cols) |cc| {
            for (0..S) |y| {
                const src = ((r * S + y) * g.w + cc * S) * 3;
                @memcpy(cut[y * S * 3 ..][0 .. S * 3], canvas[src..][0 .. S * 3]);
            }
            normalizeInto(p, cut, out[(r * g.cols + cc) * view ..][0..view]);
        }
    }
    try vision.resizePilXT(.lanczos, 3, canvas, g.w, g.h, S, S, cut);
    normalizeInto(p, cut, out[g.rows * g.cols * view ..][0..view]);
    return g;
}

fn layerNorm(ctx: *c.ggml_context, x: *c.ggml_tensor, w: *c.ggml_tensor, b: *c.ggml_tensor, eps: f32) *c.ggml_tensor {
    return c.ggml_add(ctx, c.ggml_mul(ctx, c.ggml_norm(ctx, x, eps), w), b).?;
}

/// The picture's embeddings for the decoder: tokens() rows of n_out floats, from the tower's input
/// (3 x image x image, channel-major, as pixelsFor makes it).
pub fn encode(p: *const Projector, input: []const f32, n_threads: c_int, out: []f32) !void {
    const S = p.image;
    const D = p.hidden;
    const H = p.heads;
    const hd = D / H;
    const g = S / p.patch; // patches per side
    const n_pat = g * g;
    if (input.len != 3 * S * S or out.len != p.tokens() * p.n_out) return error.SizeMismatch;
    // IM8a: the tower resident on the GPU when it is switched on (neural_vit.zig); anything it declines runs below
    if (nvit.enabled() and nvit.forward(.{ .ctx = @ptrCast(p.ctx), .n_layer = p.n_layer, .hidden = p.hidden, .heads = p.heads, .image = p.image, .patch = p.patch, .scale = p.scale, .eps = p.eps, .n_out = p.n_out }, input, out)) return;

    const MAX_NODES = 4096;
    const meta = c.ggml_init(.{ .mem_size = c.ggml_tensor_overhead() * MAX_NODES + c.ggml_graph_overhead_custom(MAX_NODES, false) + (1 << 20), .mem_buffer = null, .no_alloc = true }) orelse return error.OutOfMemory;
    defer c.ggml_free(meta);
    const dctx = c.ggml_init(.{ .mem_size = input.len * 4 + c.ggml_tensor_overhead() * 2 + 4096, .mem_buffer = null, .no_alloc = false }) orelse return error.OutOfMemory;
    defer c.ggml_free(dctx);
    const xin = c.ggml_new_tensor_4d(dctx, c.GGML_TYPE_F32, @intCast(S), @intCast(S), 3, 1) orelse return error.OutOfMemory;
    @memcpy(@as([*]f32, @ptrCast(@alignCast(xin.*.data)))[0..input.len], input);

    const ctx = meta;
    const need = struct {
        fn t(x: ?*c.ggml_tensor) !*c.ggml_tensor {
            return x orelse error.MissingTensor;
        }
    }.t;
    // patches: a stride-patch convolution, then one row of D per patch, plus its position
    var x = c.ggml_conv_2d(ctx, try need(tensor(p, "v.patch_embd.weight", .{})), xin, @intCast(p.patch), @intCast(p.patch), 0, 0, 1, 1).?;
    x = c.ggml_reshape_2d(ctx, x, @intCast(n_pat), @intCast(D)).?;
    x = c.ggml_cont(ctx, c.ggml_transpose(ctx, x)).?;
    x = c.ggml_add(ctx, x, try need(tensor(p, "v.patch_embd.bias", .{}))).?;
    x = c.ggml_add(ctx, x, try need(tensor(p, "v.position_embd.weight", .{}))).?;

    const kq_scale: f32 = 1.0 / @sqrt(@as(f32, @floatFromInt(hd)));
    for (0..p.n_layer) |L| {
        const res = x;
        var h = layerNorm(ctx, x, try need(tensor(p, "v.blk.{d}.ln1.weight", .{L})), try need(tensor(p, "v.blk.{d}.ln1.bias", .{L})), p.eps);
        const q = c.ggml_add(ctx, c.ggml_mul_mat(ctx, try need(tensor(p, "v.blk.{d}.attn_q.weight", .{L})), h), try need(tensor(p, "v.blk.{d}.attn_q.bias", .{L}))).?;
        const k = c.ggml_add(ctx, c.ggml_mul_mat(ctx, try need(tensor(p, "v.blk.{d}.attn_k.weight", .{L})), h), try need(tensor(p, "v.blk.{d}.attn_k.bias", .{L}))).?;
        const v = c.ggml_add(ctx, c.ggml_mul_mat(ctx, try need(tensor(p, "v.blk.{d}.attn_v.weight", .{L})), h), try need(tensor(p, "v.blk.{d}.attn_v.bias", .{L}))).?;
        // [hd, n_pat, H] per head
        const Q = c.ggml_cont(ctx, c.ggml_permute(ctx, c.ggml_reshape_3d(ctx, q, @intCast(hd), @intCast(H), @intCast(n_pat)), 0, 2, 1, 3)).?;
        const K = c.ggml_cont(ctx, c.ggml_permute(ctx, c.ggml_reshape_3d(ctx, k, @intCast(hd), @intCast(H), @intCast(n_pat)), 0, 2, 1, 3)).?;
        // V as [n_pat, hd, H]
        const Vt = c.ggml_cont(ctx, c.ggml_permute(ctx, c.ggml_reshape_3d(ctx, v, @intCast(hd), @intCast(H), @intCast(n_pat)), 1, 2, 0, 3)).?;
        var kq = c.ggml_mul_mat(ctx, K, Q).?; // [n_pat keys, n_pat queries, H]
        kq = c.ggml_soft_max_ext(ctx, kq, null, kq_scale, 0.0).?;
        var kqv = c.ggml_mul_mat(ctx, Vt, kq).?; // [hd, n_pat, H]
        kqv = c.ggml_cont(ctx, c.ggml_permute(ctx, kqv, 0, 2, 1, 3)).?; // [hd, H, n_pat]
        kqv = c.ggml_reshape_2d(ctx, kqv, @intCast(D), @intCast(n_pat)).?;
        var o = c.ggml_add(ctx, c.ggml_mul_mat(ctx, try need(tensor(p, "v.blk.{d}.attn_out.weight", .{L})), kqv), try need(tensor(p, "v.blk.{d}.attn_out.bias", .{L}))).?;
        x = c.ggml_add(ctx, o, res).?;
        // the MLP. llama.cpp's converter has written its two layers under either name, so their SHAPES say
        // which comes first: the one that reads D
        const res2 = x;
        h = layerNorm(ctx, x, try need(tensor(p, "v.blk.{d}.ln2.weight", .{L})), try need(tensor(p, "v.blk.{d}.ln2.bias", .{L})), p.eps);
        var w1 = try need(tensor(p, "v.blk.{d}.ffn_up.weight", .{L}));
        var b1 = try need(tensor(p, "v.blk.{d}.ffn_up.bias", .{L}));
        var w2 = try need(tensor(p, "v.blk.{d}.ffn_down.weight", .{L}));
        var b2 = try need(tensor(p, "v.blk.{d}.ffn_down.bias", .{L}));
        if (w1.*.ne[0] != @as(i64, @intCast(D))) {
            std.mem.swap(*c.ggml_tensor, &w1, &w2);
            std.mem.swap(*c.ggml_tensor, &b1, &b2);
        }
        h = c.ggml_gelu(ctx, c.ggml_add(ctx, c.ggml_mul_mat(ctx, w1, h), b1)).?;
        o = c.ggml_add(ctx, c.ggml_mul_mat(ctx, w2, h), b2).?;
        x = c.ggml_add(ctx, o, res2).?;
    }
    x = layerNorm(ctx, x, try need(tensor(p, "v.post_ln.weight", .{})), try need(tensor(p, "v.post_ln.bias", .{})), p.eps);

    // idefics3's pixel shuffle: patch (row, col) = (4hb + hr, 4wb + wr) -> token (hb, wb), feature
    // (hr, wr, channel). In memory that is ONE swap: [s*D, g/s, s, g/s] with its middle two axes exchanged
    const s = p.scale;
    x = c.ggml_reshape_4d(ctx, x, @intCast(s * D), @intCast(g / s), @intCast(s), @intCast(g / s)).?;
    x = c.ggml_cont(ctx, c.ggml_permute(ctx, x, 0, 2, 1, 3)).?;
    x = c.ggml_reshape_2d(ctx, x, @intCast(s * s * D), @intCast(n_pat / (s * s))).?;
    x = c.ggml_mul_mat(ctx, try need(tensor(p, "mm.model.fc.weight", .{})), x).?;

    const graph = c.ggml_new_graph_custom(ctx, MAX_NODES, false) orelse return error.OutOfMemory;
    c.ggml_build_forward_expand(graph, x);
    const galloc = c.ggml_gallocr_new(c.ggml_backend_cpu_buffer_type()) orelse return error.OutOfMemory;
    defer c.ggml_gallocr_free(galloc);
    if (!c.ggml_gallocr_alloc_graph(galloc, graph)) return error.OutOfMemory;
    var plan = c.ggml_graph_plan(graph, n_threads, null);
    var wbuf: ?[]u8 = null;
    defer if (wbuf) |w| gpa.free(w);
    if (plan.work_size > 0) {
        wbuf = try gpa.alloc(u8, plan.work_size);
        plan.work_data = wbuf.?.ptr;
    }
    if (c.ggml_graph_compute(graph, &plan) != c.GGML_STATUS_SUCCESS) return error.ComputeFailed;
    const r: [*]const f32 = @ptrCast(@alignCast(x.*.data));
    @memcpy(out, r[0..out.len]);
}
