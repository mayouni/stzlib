//! neural_vit.zig -- the SigLIP vision tower resident on the GPU (IM8a of SOFTANZA_IMAGE_INTELLIGENCE.md).
//!
//! The per-node router (neural_gpu.zig) measured why a graph that hops CPU<->GPU per matmul does not pay: lowered to claim
//! the tower's attention-sized matmuls it ran SLOWER (3.3 to 3.7 s a view against 2.0 to 2.5 s on the CPU, 2026-11-03).
//! This module IS the resident chain, built from the BERT backbone's kernels (neural_backbone.zig): the page's
//! patches go up once, every LayerNorm, projection, attention, GELU and residual join of the 12 layers is a dispatch in
//! ONE batched pass, and only the 1024 x 768 hidden state comes back, for the connector's pixel shuffle on the host.
//!
//! What a ViT needs that BERT does not, and what is built here:
//!   - PRE-LayerNorm (x + proj(att(LN(x)))): the backbone's add_ln kernel with use_res = 0 is the LN, and a new
//!     elementwise ADD kernel is the residual join (also adds the position embedding)
//!   - 1024 tokens: the backbone's fused attention keeps its scores in a 256-entry workgroup array; the same kernel text
//!     is compiled here with a 1024-entry array (4 KB of workgroup memory)
//!   - patch embedding: the 16 x 16 convolution is a matmul over im2col'd patches (the weight's memory order is the im2col's)
//!   - the connector: the pixel shuffle is an index permutation, done on the host over the one readback, and its linear
//!     layer is one more matmul
//!
//! AGREEMENT is asserted against the CPU graph (vlm.encode) and against Hugging Face's own tower; the CPU graph stays the
//! fallback for anything this module declines (no device, a tensor type it does not read, a larger grid).

const std = @import("std");
const gpu = @import("gpu.zig");
const ngpu = @import("neural_gpu.zig");
const nbb = @import("neural_backbone.zig");
const ops = @import("gpu_ops.zig");

const c = @cImport({
    @cInclude("ggml.h");
});

const gpa = std.heap.c_allocator;

pub const MAX_PATCHES = 1024;

/// What the tower is, read from the projector by vlm.zig
pub const Spec = struct {
    ctx: *anyopaque, // the projector's ggml context (its tensors, by name)
    n_layer: usize,
    hidden: usize,
    heads: usize,
    image: usize,
    patch: usize,
    scale: usize,
    eps: f32,
    n_out: usize,
};

// ---------------------------------------------------------------- knobs and counters

var g_on: bool = true; // ON by default: measured 2.6 to 3.5 times faster on a page and closer to the reference (IM8a); StzEngineNeuralVisionGpu(0) puts the CPU graph back
var g_views: f64 = 0;
var g_last_ms: f64 = 0;
// the stage the last forward reached (0 none, 1 eligible, 2 device, 3 kernels, 4 weights named, 5 buffers, 6 pass enqueued, 7 synced, 8 hidden read,
// 9 connector enqueued, 10 done): where a declined forward stopped
var g_stage: f64 = 0;
var g_msg: [600]u8 = @splat(0);
var g_msg_len: usize = 0;
/// the GPU layer's first error of the last forward (what a declined pass said), "" when none
pub fn message() []const u8 {
    return g_msg[0..g_msg_len];
}
var g_phase: [3]f64 = .{ 0, 0, 0 }; // ms of the last forward: the host's im2col and upload, the GPU pass (enqueue + sync), the readback + shuffle + connector
pub fn phases() [3]f64 {
    return g_phase;
}
fn msSince(t: i128) f64 {
    return @as(f64, @floatFromInt(std.time.nanoTimestamp() - t)) / 1e6;
}
// PROFILING ONLY: a mask of kernel families the pass leaves out (1 attention, 2 LayerNorm, 4 GELU, 8 add, 16 matmul); the rows are then wrong
var g_skip: u32 = 0;
pub fn setSkip(m: u32) void {
    g_skip = m;
}
fn skipped(b: u32) bool {
    return g_skip & b != 0;
}
var g_fail: f64 = 0; // the number of the first step of the pass that returned false (0 none)
pub fn failedStep() f64 {
    return g_fail;
}
pub fn stage() f64 {
    return g_stage;
}

pub fn setEnabled(on: bool) void {
    g_on = on;
}
pub fn enabled() bool {
    return g_on;
}
pub fn viewsDone() f64 {
    return g_views;
}
pub fn lastMs() f64 {
    return g_last_ms;
}

// ---------------------------------------------------------------- kernels

const WGSL_ADD = nbb.PRELUDE ++
    \\struct P { n : u32, p0 : u32, p1 : u32, p2 : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read_write> a : array<f32>;
    \\@group(0) @binding(3) var<storage, read> b : array<f32>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
    \\  let i = gid.x + tile.xoff * 256u;
    \\  if (i < p.n) { a[i] = a[i] + b[i]; }
    \\}
;

// ATTENTION. The backbone's fused kernel (one workgroup per (head, query row)) re-reads every key and value from GLOBAL
// memory for every query row: 12 layers x 12 heads x 1024 rows x 2 x 262 KB = 77 GB, a second of bandwidth (MEASURED, 2026-11-03:
// 1.0 s of the 1.9 s pass; its tree-reduction variants made it WORSE at 1024 tokens, 1.5 s and 2.9 s, and one lost the device).
// This kernel is the flash form: a workgroup owns 32 query rows of one head, each thread one row (its q and its running
// output in registers), and the keys and values come in 16-key tiles through workgroup memory, ONCE for the 32 rows, with
// the softmax kept online (a running max and sum), rescaled once a TILE and not once a key. Vectors of 4 keep q and the
// output in 16 vec4 registers each. head_dim is 64 (checked before the pass).
const WGSL_FLASH = nbb.PRELUDE ++
    \\struct P { n_tok : u32, n_embd : u32, n_head : u32, head_dim : u32, scale : f32, pad0 : u32, pad1 : u32, pad2 : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> q : array<f32>;
    \\@group(0) @binding(3) var<storage, read> k : array<f32>;
    \\@group(0) @binding(4) var<storage, read> v : array<f32>;
    \\@group(0) @binding(5) var<storage, read_write> outv : array<f32>;
    \\var<workgroup> ks : array<vec4<f32>, 256>;
    \\var<workgroup> vs : array<vec4<f32>, 256>;
    \\@compute @workgroup_size(32)
    \\fn main(@builtin(workgroup_id) wid : vec3<u32>,
    \\        @builtin(local_invocation_id) lid : vec3<u32>) {
    \\  let id = wid.x + tile.xoff;
    \\  let nblk = (p.n_tok + 31u) / 32u;
    \\  let head = id / nblk;
    \\  let blk = id % nblk;
    \\  let raw = blk * 32u + lid.x;
    \\  let row = min(raw, p.n_tok - 1u);
    \\  let base = head * 64u;
    \\  var qv : array<vec4<f32>, 16>;
    \\  var av : array<vec4<f32>, 16>;
    \\  for (var i = 0u; i < 16u; i = i + 1u) {
    \\    let o = row * p.n_embd + base + i * 4u;
    \\    qv[i] = vec4<f32>(q[o], q[o + 1u], q[o + 2u], q[o + 3u]) * p.scale;
    \\    av[i] = vec4<f32>(0.0);
    \\  }
    \\  var m = -3.4028235e38;
    \\  var l = 0.0;
    \\  for (var j0 = 0u; j0 < p.n_tok; j0 = j0 + 16u) {
    \\    for (var i = lid.x; i < 256u; i = i + 32u) {
    \\      let jj = i / 16u;
    \\      let dd = i % 16u;
    \\      let j = min(j0 + jj, p.n_tok - 1u);
    \\      let o = j * p.n_embd + base + dd * 4u;
    \\      ks[i] = vec4<f32>(k[o], k[o + 1u], k[o + 2u], k[o + 3u]);
    \\      vs[i] = vec4<f32>(v[o], v[o + 1u], v[o + 2u], v[o + 3u]);
    \\    }
    \\    workgroupBarrier();
    \\    var sc : array<f32, 16>;
    \\    var mt = -3.4028235e38;
    \\    for (var jj = 0u; jj < 16u; jj = jj + 1u) {
    \\      var s = 0.0;
    \\      for (var i = 0u; i < 16u; i = i + 1u) { s = s + dot(qv[i], ks[jj * 16u + i]); }
    \\      if (j0 + jj >= p.n_tok) { s = -3.4028235e38; }
    \\      sc[jj] = s;
    \\      mt = max(mt, s);
    \\    }
    \\    let mn = max(m, mt);
    \\    let alpha = exp(m - mn);
    \\    l = l * alpha;
    \\    for (var i = 0u; i < 16u; i = i + 1u) { av[i] = av[i] * alpha; }
    \\    for (var jj = 0u; jj < 16u; jj = jj + 1u) {
    \\      let pw = exp(sc[jj] - mn);
    \\      l = l + pw;
    \\      for (var i = 0u; i < 16u; i = i + 1u) { av[i] = av[i] + pw * vs[jj * 16u + i]; }
    \\    }
    \\    m = mn;
    \\    workgroupBarrier();
    \\  }
    \\  if (raw < p.n_tok) {
    \\    for (var i = 0u; i < 16u; i = i + 1u) {
    \\      let o = row * p.n_embd + base + i * 4u;
    \\      let r = av[i] / l;
    \\      outv[o] = r.x;
    \\      outv[o + 1u] = r.y;
    \\      outv[o + 2u] = r.z;
    \\      outv[o + 3u] = r.w;
    \\    }
    \\  }
    \\}
;

var g_att_kernel: i64 = 0;
fn attKernel() i64 {
    if (g_att_kernel == 0) g_att_kernel = gpu.stz_gpu_kernel_compile(WGSL_FLASH.ptr, @floatFromInt(WGSL_FLASH.len));
    return g_att_kernel;
}

const AddParams = extern struct { n: u32, p0: u32 = 0, p1: u32 = 0, p2: u32 = 0 };

const K_MM = 0;
const K_ATT = 1;
const K_LN = 2;
const K_GELU = 3;
const K_ADD = 4;
var g_kernels: [5]i64 = @splat(0);

fn kernels() bool {
    if (g_kernels[0] != 0) return true;
    const srcs = [_][]const u8{ ops.mmSource(ops.MM_GENERIC, true), nbb.WGSL_ADD_LN, nbb.WGSL_ADD_LN, nbb.WGSL_GELU, WGSL_ADD };
    // (slot K_ATT repeats the LN text: the attention kernel is compiled by attKernel())
    for (&g_kernels, srcs) |*kid, src| {
        kid.* = gpu.stz_gpu_kernel_compile(src.ptr, @floatFromInt(src.len));
        if (kid.* == 0) {
            g_kernels[0] = 0;
            return false;
        }
    }
    return true;
}

// The matmul variant the table names for a shape class is the generic 16 x 16 tile unless a calibration filed another, and the
// tower's shapes (1024 x 768 x 768, 1024 x 3072 x 768 ...) MEASURED 6.3 times faster at the register-tiled 8 x 8 variant
// (620 ms against 98 ms for the pass without attention, RTX 3050, 2026-11-03): the first forward files it for any of the
// tower's shapes the table leaves at the generic. A verdict someone else filed is never overwritten.
var g_variants_done = false;
fn preferReg8(m: usize, n: usize, k: usize) void {
    const op = "matmul";
    const want = ops.stz_gpu_variant_get(op.ptr, @floatFromInt(op.len), @floatFromInt(m), @floatFromInt(n), @floatFromInt(k));
    if (want == 0) _ = ops.stz_gpu_variant_set(op.ptr, @floatFromInt(op.len), @floatFromInt(m), @floatFromInt(n), @floatFromInt(k), @floatFromInt(ops.MM_REG8));
}

// ---------------------------------------------------------------- residency (this module's own: keyed by the tensor's data pointer
// AND the projector's generation, so a projector freed and another loaded at the same address never reads old weights)

const SLOTS = 256; // 16 weights a layer x 12 layers + the patch, position, post-LN and connector weights = 199
const Slot = struct { key: usize = 0, id: i64 = 0, transposed: bool = false };
var g_slots: [SLOTS]Slot = @splat(.{});
var g_slot_n: usize = 0;

var g_bufs: [9]i64 = @splat(0);
var g_buf_cap: [9]usize = @splat(0);

/// The projector was freed or another one loaded: its weights are not valid any more
pub fn invalidate() void {
    for (g_slots[0..g_slot_n]) |s| _ = gpu.stz_gpu_buffer_free(s.id);
    g_slots = @splat(.{});
    g_slot_n = 0;
}

fn scratch(i: usize, need: usize) i64 {
    if (g_bufs[i] != 0 and g_buf_cap[i] >= need) return g_bufs[i];
    if (g_bufs[i] != 0) _ = gpu.stz_gpu_buffer_free(g_bufs[i]);
    g_bufs[i] = gpu.stz_gpu_buffer_new(@floatFromInt(need));
    g_buf_cap[i] = if (g_bufs[i] != 0) need else 0;
    return g_bufs[i];
}

/// A tensor's values as f32 rows: k = ne0 floats a row, n rows (F32, F16 and the quantised types ggml can convert)
fn dequant(w: *c.ggml_tensor, out: []f32, k: usize, n: usize) bool {
    if (w.*.type == c.GGML_TYPE_F32) {
        const src: [*]const f32 = @ptrCast(@alignCast(w.*.data));
        @memcpy(out[0 .. k * n], src[0 .. k * n]);
        return true;
    }
    const traits = c.ggml_get_type_traits(w.*.type);
    const to_float = traits.*.to_float orelse return false;
    const base: [*]const u8 = @ptrCast(w.*.data);
    for (0..n) |row| to_float(base + row * w.*.nb[1], out.ptr + row * k, @intCast(k));
    return true;
}

/// A weight on the device: as an n-row matrix of k floats (a 4-D patch kernel is read as the matrix its memory order is:
/// ne0 * ne1 * ne2 floats a row, ne3 rows), transposed to [k][n] when it is a matmul's B
fn resident(w: *c.ggml_tensor, transpose: bool) i64 {
    const key = @intFromPtr(w.*.data);
    for (g_slots[0..g_slot_n]) |s| {
        if (s.key == key and s.transposed == transpose) return s.id;
    }
    if (g_slot_n == SLOTS) return 0;
    var k: usize = @intCast(w.*.ne[0]);
    var n: usize = if (w.*.ne[1] > 0) @intCast(w.*.ne[1]) else 1;
    if (w.*.ne[3] > 1 or w.*.ne[2] > 1) {
        // the patch kernel: only F32 is read this way (its rows are not ggml rows of one type block)
        if (w.*.type != c.GGML_TYPE_F32) return 0;
        k = @intCast(w.*.ne[0] * w.*.ne[1] * w.*.ne[2]);
        n = @intCast(w.*.ne[3]);
    }
    const total = k * n;
    const rows = gpa.alloc(f32, total) catch return 0;
    defer gpa.free(rows);
    if (w.*.ne[3] > 1 or w.*.ne[2] > 1) {
        const src: [*]const f32 = @ptrCast(@alignCast(w.*.data));
        @memcpy(rows, src[0..total]);
    } else if (!dequant(w, rows, k, n)) return 0;
    var upload = rows;
    var t: []f32 = &[_]f32{};
    defer if (t.len > 0) gpa.free(t);
    if (transpose) {
        t = gpa.alloc(f32, total) catch return 0;
        for (0..n) |row| {
            for (0..k) |col| t[col * n + row] = rows[row * k + col];
        }
        upload = t;
    }
    const id = gpu.stz_gpu_buffer_new(@floatFromInt(total * 4));
    if (id == 0) return 0;
    if (gpu.stz_gpu_buffer_write(id, @ptrCast(upload.ptr), @floatFromInt(total * 4)) != gpu.OK) {
        _ = gpu.stz_gpu_buffer_free(id);
        return 0;
    }
    g_slots[g_slot_n] = .{ .key = key, .id = id, .transposed = transpose };
    g_slot_n += 1;
    return id;
}

fn named(ctx: *c.ggml_context, comptime fmt: []const u8, args: anytype) ?*c.ggml_tensor {
    var buf: [96]u8 = undefined;
    const nm = std.fmt.bufPrintZ(&buf, fmt, args) catch return null;
    return c.ggml_get_tensor(ctx, nm.ptr);
}

fn rid(ctx: *c.ggml_context, comptime fmt: []const u8, args: anytype, transpose: bool) i64 {
    const t = named(ctx, fmt, args) orelse return 0;
    return resident(t, transpose);
}

// ---------------------------------------------------------------- the pass

/// The tower and the connector for one picture: `input` is 3 x image x image floats (channel-major, as vlm.pixelsFor makes
/// it), `out` is (image/patch/scale)^2 rows of n_out floats. true when the device did it; false leaves `out` untouched and
/// the caller runs the CPU graph.
pub fn forward(s: Spec, input: []const f32, out: []f32) bool {
    if (!g_on) return false;
    const t0 = std.time.nanoTimestamp();
    g_stage = 0;
    g_fail = 0;
    g_msg_len = 0;
    gpu.clearErrors();
    const D = s.hidden;
    const S = s.image;
    const P = s.patch;
    const g = S / P;
    const n_pat = g * g;
    const H = s.heads;
    if (n_pat > MAX_PATCHES or n_pat == 0 or D == 0 or H == 0 or D % H != 0 or s.scale == 0 or g % s.scale != 0) return false;
    const hd = D / H;
    if (hd != 64) return false; // the attention kernel is written for 64-wide heads
    const K = 3 * P * P;
    const n_tok_out = n_pat / (s.scale * s.scale);
    if (input.len != 3 * S * S or out.len != n_tok_out * s.n_out) return false;
    g_stage = 1;
    if (!ngpu.ensureDevicePub()) return false;
    g_stage = 2;
    if (!kernels()) return false;
    g_stage = 3;
    nbb.setHalf(false);
    const ctx: *c.ggml_context = @ptrCast(@alignCast(s.ctx));

    // the MLP's two layers are named either way round in a projector file: the one that reads D is the first
    const up0 = named(ctx, "v.blk.0.ffn_up.weight", .{}) orelse return false;
    const dn0 = named(ctx, "v.blk.0.ffn_down.weight", .{}) orelse return false;
    const swap = up0.*.ne[0] != @as(i64, @intCast(D));
    const n_ffn: usize = @intCast(if (swap) dn0.*.ne[1] else up0.*.ne[1]);

    g_stage = 4;
    var tp = std.time.nanoTimestamp();
    // ---- the patches, im2col'd on the host: row (py, px) = the 3 x P x P pixels under that patch, channel-major
    const a = gpa.alloc(f32, n_pat * K) catch return false;
    defer gpa.free(a);
    for (0..g) |py| {
        for (0..g) |px| {
            const row = py * g + px;
            for (0..3) |ch| {
                for (0..P) |kh| {
                    const src = input[ch * S * S + (py * P + kh) * S + px * P ..][0..P];
                    @memcpy(a[row * K + ch * P * P + kh * P ..][0..P], src);
                }
            }
        }
    }

    const act = n_pat * D * 4;
    const bx = scratch(0, act);
    const by = scratch(1, act);
    const bq = scratch(2, act);
    const bk = scratch(3, act);
    const bv = scratch(4, act);
    const bt = scratch(5, act);
    const bf = scratch(6, n_pat * n_ffn * 4);
    const ba = scratch(7, n_pat * K * 4);
    if (bx == 0 or by == 0 or bq == 0 or bk == 0 or bv == 0 or bt == 0 or bf == 0 or ba == 0) return false;
    if (gpu.stz_gpu_buffer_write(ba, @ptrCast(a.ptr), @floatFromInt(n_pat * K * 4)) != gpu.OK) return false;

    g_stage = 5;
    const t_bufs = tp;
    _ = t_bufs;
    if (!g_variants_done) {
        preferReg8(n_pat, D, K); // the patch embedding and the four projections (n = D, k = D or K)
        preferReg8(n_pat, D, D);
        preferReg8(n_pat, n_ffn, D);
        preferReg8(n_pat, D, n_ffn);
        preferReg8(n_tok_out, s.n_out, D * s.scale * s.scale);
        g_variants_done = true;
    }
    const scale: f32 = 1.0 / @sqrt(@as(f32, @floatFromInt(hd)));
    var ok = true;
    g_phase[0] = msSince(tp);
    tp = std.time.nanoTimestamp();
    if (gpu.stz_gpu_batch_begin() != gpu.OK) return false;
    // patch embedding (a matmul over the patches) and the position embedding
    ok = ok and (skipped(16) or nbb.mmBias(g_kernels[K_MM], ba, rid(ctx, "v.patch_embd.weight", .{}, true), rid(ctx, "v.patch_embd.bias", .{}, false), bx, n_pat, K, D));
    if (!ok and g_fail == 0) g_fail = 1;
    const pos = rid(ctx, "v.position_embd.weight", .{}, false);
    if (pos == 0) ok = false;
    const addp = AddParams{ .n = @intCast(n_pat * D) };
    ok = ok and (skipped(8) or nbb.dispatchP(g_kernels[K_ADD], &addp, &.{ bx, pos }, nbb.ceilDiv(n_pat * D, 256), 1));
    if (!ok and g_fail == 0) g_fail = 2;

    var L: usize = 0;
    while (L < s.n_layer and ok) : (L += 1) {
        // x = x + O(attention(LN1(x)))
        ok = ok and (skipped(2) or nbb.lnStep(g_kernels[K_LN], bx, bx, rid(ctx, "v.blk.{d}.ln1.weight", .{L}, false), rid(ctx, "v.blk.{d}.ln1.bias", .{L}, false), by, n_pat, D, s.eps, 0));
        if (!ok and g_fail == 0) g_fail = 3;
        ok = ok and (skipped(16) or nbb.mmBias(g_kernels[K_MM], by, rid(ctx, "v.blk.{d}.attn_q.weight", .{L}, true), rid(ctx, "v.blk.{d}.attn_q.bias", .{L}, false), bq, n_pat, D, D));
        if (!ok and g_fail == 0) g_fail = 4;
        ok = ok and (skipped(16) or nbb.mmBias(g_kernels[K_MM], by, rid(ctx, "v.blk.{d}.attn_k.weight", .{L}, true), rid(ctx, "v.blk.{d}.attn_k.bias", .{L}, false), bk, n_pat, D, D));
        if (!ok and g_fail == 0) g_fail = 5;
        ok = ok and (skipped(16) or nbb.mmBias(g_kernels[K_MM], by, rid(ctx, "v.blk.{d}.attn_v.weight", .{L}, true), rid(ctx, "v.blk.{d}.attn_v.bias", .{L}, false), bv, n_pat, D, D));
        if (!ok and g_fail == 0) g_fail = 6;
        const ap = nbb.AttParams{ .n_tok = @intCast(n_pat), .n_embd = @intCast(D), .n_head = @intCast(H), .head_dim = @intCast(hd), .scale = scale };
        ok = ok and (skipped(1) or nbb.dispatchP(attKernel(), &ap, &.{ bq, bk, bv, bt }, H * nbb.ceilDiv(n_pat, 32), 1));
        if (!ok and g_fail == 0) g_fail = 7;
        ok = ok and (skipped(16) or nbb.mmBias(g_kernels[K_MM], bt, rid(ctx, "v.blk.{d}.attn_out.weight", .{L}, true), rid(ctx, "v.blk.{d}.attn_out.bias", .{L}, false), bq, n_pat, D, D));
        if (!ok and g_fail == 0) g_fail = 8;
        ok = ok and (skipped(8) or nbb.dispatchP(g_kernels[K_ADD], &addp, &.{ bx, bq }, nbb.ceilDiv(n_pat * D, 256), 1));
        if (!ok and g_fail == 0) g_fail = 9;
        // x = x + MLP(LN2(x))
        ok = ok and (skipped(2) or nbb.lnStep(g_kernels[K_LN], bx, bx, rid(ctx, "v.blk.{d}.ln2.weight", .{L}, false), rid(ctx, "v.blk.{d}.ln2.bias", .{L}, false), by, n_pat, D, s.eps, 0));
        if (!ok and g_fail == 0) g_fail = 10;
        if (swap) {
            ok = ok and (skipped(16) or nbb.mmBias(g_kernels[K_MM], by, rid(ctx, "v.blk.{d}.ffn_down.weight", .{L}, true), rid(ctx, "v.blk.{d}.ffn_down.bias", .{L}, false), bf, n_pat, D, n_ffn));
            if (!ok and g_fail == 0) g_fail = 11;
        } else {
            ok = ok and (skipped(16) or nbb.mmBias(g_kernels[K_MM], by, rid(ctx, "v.blk.{d}.ffn_up.weight", .{L}, true), rid(ctx, "v.blk.{d}.ffn_up.bias", .{L}, false), bf, n_pat, D, n_ffn));
            if (!ok and g_fail == 0) g_fail = 12;
        }
        const gp = nbb.GeluParams{ .n = @intCast(n_pat * n_ffn) };
        ok = ok and (skipped(4) or nbb.dispatchP(g_kernels[K_GELU], &gp, &.{bf}, nbb.ceilDiv(n_pat * n_ffn, 256), 1));
        if (!ok and g_fail == 0) g_fail = 13;
        if (swap) {
            ok = ok and (skipped(16) or nbb.mmBias(g_kernels[K_MM], bf, rid(ctx, "v.blk.{d}.ffn_up.weight", .{L}, true), rid(ctx, "v.blk.{d}.ffn_up.bias", .{L}, false), bq, n_pat, n_ffn, D));
            if (!ok and g_fail == 0) g_fail = 14;
        } else {
            ok = ok and (skipped(16) or nbb.mmBias(g_kernels[K_MM], bf, rid(ctx, "v.blk.{d}.ffn_down.weight", .{L}, true), rid(ctx, "v.blk.{d}.ffn_down.bias", .{L}, false), bq, n_pat, n_ffn, D));
            if (!ok and g_fail == 0) g_fail = 15;
        }
        ok = ok and (skipped(8) or nbb.dispatchP(g_kernels[K_ADD], &addp, &.{ bx, bq }, nbb.ceilDiv(n_pat * D, 256), 1));
        if (!ok and g_fail == 0) g_fail = 16;
    }
    // the post-LayerNorm
    ok = ok and (skipped(2) or nbb.lnStep(g_kernels[K_LN], bx, bx, rid(ctx, "v.post_ln.weight", .{}, false), rid(ctx, "v.post_ln.bias", .{}, false), by, n_pat, D, s.eps, 0));
    if (!ok and g_fail == 0) g_fail = 17;
    _ = gpu.stz_gpu_batch_end();
    g_stage = 6;
    if (!ok) {
        const m = gpu.firstError();
        g_msg_len = @min(m.len, g_msg.len);
        @memcpy(g_msg[0..g_msg_len], m[0..g_msg_len]);
        return false;
    }
    if (gpu.stz_gpu_sync() != gpu.OK) return false;
    g_stage = 7;
    g_phase[1] = msSince(tp);
    tp = std.time.nanoTimestamp();

    // ---- the connector: the hidden state back (n_pat x D), pixel shuffle on the host, then one matmul
    const hid = gpa.alloc(f32, n_pat * D) catch return false;
    defer gpa.free(hid);
    if (gpu.stz_gpu_buffer_read(by, @ptrCast(hid.ptr), @floatFromInt(act)) != gpu.OK) return false;
    g_stage = 8;
    const sf = s.scale;
    const feat = D * sf * sf;
    const sh = gpa.alloc(f32, n_tok_out * feat) catch return false;
    defer gpa.free(sh);
    // token (hb, wb) = the sf x sf block of patches at rows sf*hb.., cols sf*wb..; its feature is (rl, cl, channel)
    for (0..g / sf) |hb| {
        for (0..g / sf) |wb| {
            const tok = hb * (g / sf) + wb;
            for (0..sf) |rl| {
                for (0..sf) |cl| {
                    const patch = (hb * sf + rl) * g + (wb * sf + cl);
                    @memcpy(sh[tok * feat + (rl * sf + cl) * D ..][0..D], hid[patch * D ..][0..D]);
                }
            }
        }
    }
    const bs = scratch(8, n_tok_out * feat * 4);
    const bo = gpu.stz_gpu_buffer_new(@floatFromInt(n_tok_out * s.n_out * 4));
    if (bs == 0 or bo == 0) return false;
    defer _ = gpu.stz_gpu_buffer_free(bo);
    if (gpu.stz_gpu_buffer_write(bs, @ptrCast(sh.ptr), @floatFromInt(n_tok_out * feat * 4)) != gpu.OK) return false;
    if (gpu.stz_gpu_batch_begin() != gpu.OK) return false;
    g_stage = 9;
    ok = nbb.mmBias(g_kernels[K_MM], bs, rid(ctx, "mm.model.fc.weight", .{}, true), 0, bo, n_tok_out, feat, s.n_out);
    _ = gpu.stz_gpu_batch_end();
    if (!ok) return false;
    if (gpu.stz_gpu_sync() != gpu.OK) return false;
    if (gpu.stz_gpu_buffer_read(bo, @ptrCast(out.ptr), @floatFromInt(n_tok_out * s.n_out * 4)) != gpu.OK) return false;
    g_phase[2] = msSince(tp);
    g_stage = 10;
    g_views += 1;
    g_last_ms = @as(f64, @floatFromInt(std.time.nanoTimestamp() - t0)) / 1e6;
    return true;
}
