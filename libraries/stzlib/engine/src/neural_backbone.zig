//! THE RESIDENT BACKBONE -- a whole BERT encoder forward pass on the GPU,
//! one upload in and one small readback out (SOFTANZA_GPU_PLAN.md, "THE
//! RESIDENT BACKBONE"). The per-node router (neural_gpu.zig) measured
//! 0.45-0.67x because a graph that hops CPU<->GPU per node is not a
//! resident chain; this module IS the chain: embeddings upload once, every
//! LayerNorm / projection / attention / FFN runs as a dispatch inside ONE
//! batched pass, and only the pooled sentence vector comes back.
//!
//! FIVE KERNELS, and the reason there are only five:
//!   - matmul_bias   C = A*B + bias        (every projection and FFN leg)
//!   - attention     FUSED multi-head: one workgroup per (head, query row)
//!                   does scores -> softmax -> context. Keeping Q/K/V WHOLE
//!                   is what avoids per-head slicing -- which would have
//!                   demanded buffer OFFSETS in the op API (the R2 trap the
//!                   spike found before any of this was written).
//!   - add_ln        LayerNorm(x + residual) * w + b -- BERT is post-LN, so
//!                   both residual joins are this one kernel
//!   - gelu          in place
//!   - pool_l2       mean over tokens then L2 normalize, ON DEVICE, so the
//!                   readback is n_embd floats and not n_tok*n_embd
//!
//! SCOPE, deliberately narrow: classic BERT/MiniLM shape only -- learned
//! position embeddings, standard (non-gated) FFN, no ALiBi, seq <= 256,
//! F32/F16/Q8_0 weights. Anything else returns false and the caller keeps
//! its CPU path. A backbone that silently mis-handled jina-bert-v2's GEGLU
//! or ALiBi would be worse than no backbone at all.
//!
//! NUMERIC NOTE: this path computes GELU with the tanh approximation in
//! f32, while ggml's CPU kernels use a GGML_GELU_FP16 lookup table (f16
//! in AND out) and quantize activations for Q8_0 matmuls. The two therefore
//! agree semantically, not bitwise -- the guard asserts cosine against the
//! INDEPENDENT numpy reference, the same standard the per-node route met.

const std = @import("std");
const gpu = @import("gpu.zig");
const embed = @import("neural_embed.zig");
const ngpu = @import("neural_gpu.zig");

const c = @cImport({
    @cInclude("ggml.h");
});

const gpa = std.heap.c_allocator;

const MAX_SEQ = 256;
const WG = 256;

// ---------------------------------------------------------------- kernels

const PRELUDE =
    \\struct StzTile { xoff : u32, p0 : u32, p1 : u32, p2 : u32 }
    \\@group(0) @binding(0) var<uniform> tile : StzTile;
    \\
;

// C[m,n] = A[m,k] * B[k,n] + bias[n]   (bias skipped when has_bias == 0)
const WGSL_MATMUL_BIAS = PRELUDE ++
    \\struct P { m : u32, k : u32, n : u32, has_bias : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> a : array<f32>;
    \\@group(0) @binding(3) var<storage, read> b : array<f32>;
    \\@group(0) @binding(4) var<storage, read> bias : array<f32>;
    \\@group(0) @binding(5) var<storage, read_write> outv : array<f32>;
    \\var<workgroup> ta : array<f32, 256>;
    \\var<workgroup> tb : array<f32, 256>;
    \\@compute @workgroup_size(16, 16)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>,
    \\        @builtin(local_invocation_id) lid : vec3<u32>) {
    \\  let row = gid.y;
    \\  let col = gid.x + tile.xoff * 16u;
    \\  var acc = 0.0;
    \\  let tiles = (p.k + 15u) / 16u;
    \\  for (var t = 0u; t < tiles; t = t + 1u) {
    \\    let k0 = t * 16u;
    \\    let acol = k0 + lid.x;
    \\    let brow = k0 + lid.y;
    \\    ta[lid.y * 16u + lid.x] = select(0.0, a[row * p.k + acol], row < p.m && acol < p.k);
    \\    tb[lid.y * 16u + lid.x] = select(0.0, b[brow * p.n + col], brow < p.k && col < p.n);
    \\    workgroupBarrier();
    \\    for (var kk = 0u; kk < 16u; kk = kk + 1u) {
    \\      acc = acc + ta[lid.y * 16u + kk] * tb[kk * 16u + lid.x];
    \\    }
    \\    workgroupBarrier();
    \\  }
    \\  if (row < p.m && col < p.n) {
    \\    if (p.has_bias == 1u) { acc = acc + bias[col]; }
    \\    outv[row * p.n + col] = acc;
    \\  }
    \\}
;

// FUSED multi-head attention. One workgroup per (head, query row):
// scores -> softmax -> context, Q/K/V kept WHOLE (token-major, head h at
// dims [h*hd, (h+1)*hd)). Scores live in workgroup memory (seq <= 256).
const WGSL_ATTENTION = PRELUDE ++
    \\struct P { n_tok : u32, n_embd : u32, n_head : u32, head_dim : u32, scale : f32, pad0 : u32, pad1 : u32, pad2 : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> q : array<f32>;
    \\@group(0) @binding(3) var<storage, read> k : array<f32>;
    \\@group(0) @binding(4) var<storage, read> v : array<f32>;
    \\@group(0) @binding(5) var<storage, read_write> outv : array<f32>;
    \\var<workgroup> sc : array<f32, 256>;
    \\@compute @workgroup_size(64)
    \\fn main(@builtin(workgroup_id) wid : vec3<u32>,
    \\        @builtin(local_invocation_id) lid : vec3<u32>) {
    \\  let head = wid.x + tile.xoff;
    \\  let row  = wid.y;
    \\  if (head >= p.n_head || row >= p.n_tok) { return; }
    \\  let base = head * p.head_dim;
    \\  let qoff = row * p.n_embd + base;
    \\  // 1. scores for this (head,row), split across the workgroup
    \\  var j = lid.x;
    \\  loop {
    \\    if (j >= p.n_tok) { break; }
    \\    var dot = 0.0;
    \\    let koff = j * p.n_embd + base;
    \\    for (var d = 0u; d < p.head_dim; d = d + 1u) {
    \\      dot = dot + q[qoff + d] * k[koff + d];
    \\    }
    \\    sc[j] = dot * p.scale;
    \\    j = j + 64u;
    \\  }
    \\  workgroupBarrier();
    \\  // 2. every thread scans for max and sum (n_tok <= 256; no extra sync)
    \\  var mx = -3.4028235e38;
    \\  for (var t = 0u; t < p.n_tok; t = t + 1u) { mx = max(mx, sc[t]); }
    \\  var sum = 0.0;
    \\  for (var t = 0u; t < p.n_tok; t = t + 1u) { sum = sum + exp(sc[t] - mx); }
    \\  workgroupBarrier();
    \\  // 3. normalize this thread's slice in place
    \\  var j2 = lid.x;
    \\  loop {
    \\    if (j2 >= p.n_tok) { break; }
    \\    sc[j2] = exp(sc[j2] - mx) / sum;
    \\    j2 = j2 + 64u;
    \\  }
    \\  workgroupBarrier();
    \\  // 4. context: one output dim per thread
    \\  var d2 = lid.x;
    \\  loop {
    \\    if (d2 >= p.head_dim) { break; }
    \\    var acc = 0.0;
    \\    for (var t = 0u; t < p.n_tok; t = t + 1u) {
    \\      acc = acc + sc[t] * v[t * p.n_embd + base + d2];
    \\    }
    \\    outv[row * p.n_embd + base + d2] = acc;
    \\    d2 = d2 + 64u;
    \\  }
    \\}
;

// out = LayerNorm(x + residual) * w + b, one workgroup per token row.
// use_res == 0 skips the residual (the embedding LN).
const WGSL_ADD_LN = PRELUDE ++
    \\struct P { n_tok : u32, n_embd : u32, use_res : u32, pad : u32, eps : f32, pad1 : f32, pad2 : f32, pad3 : f32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> x : array<f32>;
    \\@group(0) @binding(3) var<storage, read> res : array<f32>;
    \\@group(0) @binding(4) var<storage, read> w : array<f32>;
    \\@group(0) @binding(5) var<storage, read> b : array<f32>;
    \\@group(0) @binding(6) var<storage, read_write> outv : array<f32>;
    \\var<workgroup> part : array<f32, 256>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(workgroup_id) wid : vec3<u32>,
    \\        @builtin(local_invocation_id) lid : vec3<u32>) {
    \\  let row = wid.x + tile.xoff;
    \\  if (row >= p.n_tok) { return; }
    \\  let off = row * p.n_embd;
    \\  // mean
    \\  var s = 0.0;
    \\  var i = lid.x;
    \\  loop {
    \\    if (i >= p.n_embd) { break; }
    \\    var val = x[off + i];
    \\    if (p.use_res == 1u) { val = val + res[off + i]; }
    \\    s = s + val;
    \\    i = i + 256u;
    \\  }
    \\  part[lid.x] = s;
    \\  workgroupBarrier();
    \\  for (var st = 128u; st > 0u; st = st >> 1u) {
    \\    if (lid.x < st) { part[lid.x] = part[lid.x] + part[lid.x + st]; }
    \\    workgroupBarrier();
    \\  }
    \\  let mean = part[0] / f32(p.n_embd);
    \\  workgroupBarrier();
    \\  // variance
    \\  var sv = 0.0;
    \\  var i2 = lid.x;
    \\  loop {
    \\    if (i2 >= p.n_embd) { break; }
    \\    var val = x[off + i2];
    \\    if (p.use_res == 1u) { val = val + res[off + i2]; }
    \\    let d = val - mean;
    \\    sv = sv + d * d;
    \\    i2 = i2 + 256u;
    \\  }
    \\  part[lid.x] = sv;
    \\  workgroupBarrier();
    \\  for (var st = 128u; st > 0u; st = st >> 1u) {
    \\    if (lid.x < st) { part[lid.x] = part[lid.x] + part[lid.x + st]; }
    \\    workgroupBarrier();
    \\  }
    \\  let inv = 1.0 / sqrt(part[0] / f32(p.n_embd) + p.eps);
    \\  workgroupBarrier();
    \\  var i3 = lid.x;
    \\  loop {
    \\    if (i3 >= p.n_embd) { break; }
    \\    var val = x[off + i3];
    \\    if (p.use_res == 1u) { val = val + res[off + i3]; }
    \\    outv[off + i3] = (val - mean) * inv * w[i3] + b[i3];
    \\    i3 = i3 + 256u;
    \\  }
    \\}
;

const WGSL_GELU = PRELUDE ++
    \\struct P { n : u32, p0 : u32, p1 : u32, p2 : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read_write> v : array<f32>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
    \\  let i = gid.x + tile.xoff * 256u;
    \\  if (i < p.n) {
    \\    let x = v[i];
    \\    v[i] = 0.5 * x * (1.0 + tanh(0.7978845608 * x * (1.0 + 0.044715 * x * x)));
    \\  }
    \\}
;

// mean-pool over tokens then L2 normalize -- ONE workgroup, so the whole
// sentence vector is finished on-device and the readback is n_embd floats.
const WGSL_POOL_L2 = PRELUDE ++
    \\struct P { n_tok : u32, n_embd : u32, p0 : u32, p1 : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> x : array<f32>;
    \\@group(0) @binding(3) var<storage, read_write> outv : array<f32>;
    \\var<workgroup> part : array<f32, 256>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(local_invocation_id) lid : vec3<u32>) {
    \\  // tile.xoff is ALWAYS 0 here (pool runs as ONE workgroup -- its
    \\  // cross-dimension reduction has no meaning split across workgroups),
    \\  // but the reference must be REAL: a kernel that merely DECLARES the
    \\  // tile uniform without reading it gets an auto-layout WITHOUT binding
    \\  // 0, and then every bind group the layer builds for it is invalid.
    \\  let base = tile.xoff * 256u;
    \\  var ss = 0.0;
    \\  var i = lid.x + base;
    \\  loop {
    \\    if (i >= p.n_embd) { break; }
    \\    var s = 0.0;
    \\    for (var t = 0u; t < p.n_tok; t = t + 1u) { s = s + x[t * p.n_embd + i]; }
    \\    let m = s / f32(p.n_tok);
    \\    outv[i] = m;
    \\    ss = ss + m * m;
    \\    i = i + 256u;
    \\  }
    \\  part[lid.x] = ss;
    \\  workgroupBarrier();
    \\  for (var st = 128u; st > 0u; st = st >> 1u) {
    \\    if (lid.x < st) { part[lid.x] = part[lid.x] + part[lid.x + st]; }
    \\    workgroupBarrier();
    \\  }
    \\  var nrm = sqrt(part[0]);
    \\  if (nrm == 0.0) { nrm = 1.0; }
    \\  workgroupBarrier();
    \\  var i2 = lid.x + base;
    \\  loop {
    \\    if (i2 >= p.n_embd) { break; }
    \\    outv[i2] = outv[i2] / nrm;
    \\    i2 = i2 + 256u;
    \\  }
    \\}
;

// ---------------------------------------------------------------- params

const MmParams = extern struct { m: u32, k: u32, n: u32, has_bias: u32 };
const AttParams = extern struct { n_tok: u32, n_embd: u32, n_head: u32, head_dim: u32, scale: f32, p0: u32 = 0, p1: u32 = 0, p2: u32 = 0 };
const LnParams = extern struct { n_tok: u32, n_embd: u32, use_res: u32, pad: u32, eps: f32, p1: f32 = 0, p2: f32 = 0, p3: f32 = 0 };
const GeluParams = extern struct { n: u32, p0: u32 = 0, p1: u32 = 0, p2: u32 = 0 };
const PoolParams = extern struct { n_tok: u32, n_embd: u32, p0: u32 = 0, p1: u32 = 0 };

fn dispatchP(kernel: i64, params: anytype, bufs: []const i64, wx: usize, wy: usize) bool {
    const bytes = std.mem.asBytes(params);
    return gpu.stz_gpu_dispatch_params(
        kernel,
        bytes.ptr,
        @floatFromInt(bytes.len),
        bufs.ptr,
        @intCast(bufs.len),
        @floatFromInt(wx),
        @floatFromInt(wy),
    ) == gpu.OK;
}

fn ceilDiv(a: usize, b: usize) usize {
    return (a + b - 1) / b;
}

// ---------------------------------------------------------------- residency

const SLOTS = 256;
const Slot = struct { ptr: usize = 0, id: i64 = 0, n: usize = 0, transposed: bool = false };
var g_slots: [SLOTS]Slot = @splat(.{});
var g_slot_n: usize = 0;
var g_gen: usize = std.math.maxInt(usize);

var g_bufs: [8]i64 = @splat(0); // x, y, q, k, v, ffn, pooled, zero
var g_buf_cap: [8]usize = @splat(0);

fn resetResidency() void {
    for (&g_slots) |*s| {
        if (s.ptr != 0) _ = gpu.stz_gpu_buffer_free(s.id);
        s.* = .{};
    }
    g_slot_n = 0;
    for (&g_bufs, 0..) |*b, i| {
        if (b.* != 0) _ = gpu.stz_gpu_buffer_free(b.*);
        b.* = 0;
        g_buf_cap[i] = 0;
    }
}

fn dequantRows(w: *c.ggml_tensor, out: []f32, k: usize, n: usize) bool {
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

/// A tensor, resident. 2-D weights arrive TRANSPOSED to [k][n] (matmul's B);
/// 1-D vectors (bias, LN weight) upload as-is.
fn resident(w: *c.ggml_tensor, transpose: bool) i64 {
    if (g_gen != embed.model_generation) {
        resetResidency();
        g_gen = embed.model_generation;
    }
    const key = @intFromPtr(w.*.data);
    for (g_slots[0..g_slot_n]) |s| {
        if (s.ptr == key and s.transposed == transpose) return s.id;
    }
    if (g_slot_n == SLOTS) return 0;

    const k: usize = @intCast(w.*.ne[0]);
    const n: usize = if (w.*.ne[1] > 0) @intCast(w.*.ne[1]) else 1;
    const total = k * n;
    const rows = gpa.alloc(f32, total) catch return 0;
    defer gpa.free(rows);
    if (!dequantRows(w, rows, k, n)) return 0;

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
    g_slots[g_slot_n] = .{ .ptr = key, .id = id, .n = total, .transposed = transpose };
    g_slot_n += 1;
    return id;
}

fn scratch(i: usize, need: usize) i64 {
    if (g_bufs[i] != 0 and g_buf_cap[i] >= need) return g_bufs[i];
    if (g_bufs[i] != 0) _ = gpu.stz_gpu_buffer_free(g_bufs[i]);
    g_bufs[i] = gpu.stz_gpu_buffer_new(@floatFromInt(need));
    g_buf_cap[i] = if (g_bufs[i] != 0) need else 0;
    return g_bufs[i];
}

// ---------------------------------------------------------------- model access

fn ctxOf() ?*c.ggml_context {
    const h = embed.ctxHandle() orelse return null;
    return @ptrCast(@alignCast(h));
}

fn tensor(ctx: *c.ggml_context, comptime fmt: []const u8, args: anytype) ?*c.ggml_tensor {
    var buf: [128]u8 = undefined;
    const name = std.fmt.bufPrintZ(&buf, fmt, args) catch return null;
    return c.ggml_get_tensor(ctx, name.ptr);
}

/// Is this model the shape the backbone handles? Learned positions,
/// standard FFN, no gate. Anything else -> the caller's CPU path.
pub export fn neural_backbone_supported() callconv(.c) c_int {
    const ctx = ctxOf() orelse return 0;
    if (tensor(ctx, "position_embd.weight", .{}) == null) return 0;
    if (tensor(ctx, "blk.0.ffn_gate.weight", .{}) != null) return 0;
    if (tensor(ctx, "blk.0.ffn_up.weight", .{}) == null) return 0;
    if (tensor(ctx, "blk.0.ffn_up.bias", .{}) == null) return 0;
    return 1;
}

// ---------------------------------------------------------------- the pass

var g_kernels: [5]i64 = @splat(0);

fn kernels() bool {
    const srcs = [_][]const u8{ WGSL_MATMUL_BIAS, WGSL_ATTENTION, WGSL_ADD_LN, WGSL_GELU, WGSL_POOL_L2 };
    for (&g_kernels, srcs) |*kid, src| {
        kid.* = gpu.stz_gpu_kernel_compile(src.ptr, @floatFromInt(src.len));
        if (kid.* == 0) return false;
    }
    return true;
}

/// Run the whole encoder on the device for `n_tok` token ids and leave the
/// pooled, L2-normalized sentence vector in `out` (n_embd floats).
/// Returns 1 on success; 0 means "not run" and the caller uses its CPU path.
pub export fn neural_backbone_forward(ids_ptr: [*c]const i32, n_tok_in: c_int, out: [*c]f32) callconv(.c) c_int {
    // the device comes up lazily, through the SAME init the per-node router
    // uses (it owns the runtime path) -- never a second device in one DLL
    if (!ngpu.ensureDevicePub()) return 0;
    if (neural_backbone_supported() == 0) return 0;
    const ctx = ctxOf() orelse return 0;
    const n_tok: usize = @intCast(n_tok_in);
    if (n_tok < 2 or n_tok > MAX_SEQ) return 0;

    const n_embd: usize = @intCast(embed.neural_model_n_embd());
    const n_head: usize = @intCast(embed.neural_model_n_heads());
    const n_layer: usize = @intCast(embed.neural_model_n_layers());
    if (n_embd == 0 or n_head == 0 or n_layer == 0) return 0;
    const head_dim = n_embd / n_head;
    if (head_dim * n_head != n_embd or n_embd > 4096) return 0;
    const n_ffn: usize = blk: {
        const t = tensor(ctx, "blk.0.ffn_up.weight", .{}) orelse return 0;
        break :blk @intCast(t.*.ne[1]);
    };
    if (!kernels()) return 0;
    if (g_gen != embed.model_generation) {
        resetResidency();
        g_gen = embed.model_generation;
    }

    // ---- CPU-side embedding gather (tiny: n_tok rows), then ONE upload
    const tok_w = tensor(ctx, "token_embd.weight", .{}) orelse return 0;
    const typ_w = tensor(ctx, "token_types.weight", .{}) orelse return 0;
    const pos_w = tensor(ctx, "position_embd.weight", .{}) orelse return 0;
    const n_vocab: usize = @intCast(tok_w.*.ne[1]);

    const host = gpa.alloc(f32, n_tok * n_embd) catch return 0;
    defer gpa.free(host);
    const row = gpa.alloc(f32, n_embd) catch return 0;
    defer gpa.free(row);
    const trow = gpa.alloc(f32, n_embd) catch return 0;
    defer gpa.free(trow);
    const prow = gpa.alloc(f32, n_embd) catch return 0;
    defer gpa.free(prow);
    if (!gatherRow(typ_w, 0, trow)) return 0;
    for (0..n_tok) |t| {
        const id: usize = @intCast(ids_ptr[t]);
        if (id >= n_vocab) return 0;
        if (!gatherRow(tok_w, id, row)) return 0;
        if (!gatherRow(pos_w, t, prow)) return 0;
        for (0..n_embd) |e| host[t * n_embd + e] = row[e] + trow[e] + prow[e];
    }

    const act = n_tok * n_embd * 4;
    const bx = scratch(0, act);
    const by = scratch(1, act);
    const bq = scratch(2, act);
    const bk = scratch(3, act);
    const bv = scratch(4, act);
    const bf = scratch(5, n_tok * n_ffn * 4);
    const bp = scratch(6, n_embd * 4);
    if (bx == 0 or by == 0 or bq == 0 or bk == 0 or bv == 0 or bf == 0 or bp == 0) return 0;
    if (gpu.stz_gpu_buffer_write(bx, @ptrCast(host.ptr), @floatFromInt(act)) != gpu.OK) return 0;

    const eps = kvEps(ctx);
    const scale: f32 = 1.0 / @sqrt(@as(f32, @floatFromInt(head_dim)));
    const K_MM = g_kernels[0];
    const K_ATT = g_kernels[1];
    const K_LN = g_kernels[2];
    const K_GELU = g_kernels[3];
    const K_POOL = g_kernels[4];

    // one batched pass for the WHOLE encoder
    if (gpu.stz_gpu_batch_begin() != gpu.OK) return 0;
    var ok = true;

    // embedding LayerNorm (no residual): by = LN(bx)
    ok = ok and lnStep(K_LN, bx, bx, tensorId(ctx, "token_embd_norm.weight", .{}, false), tensorId(ctx, "token_embd_norm.bias", .{}, false), by, n_tok, n_embd, eps, 0);

    var L: usize = 0;
    while (L < n_layer and ok) : (L += 1) {
        // Q, K, V from by
        ok = ok and mmBias(K_MM, by, tensorId(ctx, "blk.{d}.attn_q.weight", .{L}, true), tensorId(ctx, "blk.{d}.attn_q.bias", .{L}, false), bq, n_tok, n_embd, n_embd);
        ok = ok and mmBias(K_MM, by, tensorId(ctx, "blk.{d}.attn_k.weight", .{L}, true), tensorId(ctx, "blk.{d}.attn_k.bias", .{L}, false), bk, n_tok, n_embd, n_embd);
        ok = ok and mmBias(K_MM, by, tensorId(ctx, "blk.{d}.attn_v.weight", .{L}, true), tensorId(ctx, "blk.{d}.attn_v.bias", .{L}, false), bv, n_tok, n_embd, n_embd);
        // fused attention -> bx
        const ap = AttParams{ .n_tok = @intCast(n_tok), .n_embd = @intCast(n_embd), .n_head = @intCast(n_head), .head_dim = @intCast(head_dim), .scale = scale };
        ok = ok and dispatchP(K_ATT, &ap, &.{ bq, bk, bv, bx }, n_head, n_tok);
        // attn_output projection -> bq (reused), then LN(bq + by) -> by
        ok = ok and mmBias(K_MM, bx, tensorId(ctx, "blk.{d}.attn_output.weight", .{L}, true), tensorId(ctx, "blk.{d}.attn_output.bias", .{L}, false), bq, n_tok, n_embd, n_embd);
        ok = ok and lnStep(K_LN, bq, by, tensorId(ctx, "blk.{d}.attn_output_norm.weight", .{L}, false), tensorId(ctx, "blk.{d}.attn_output_norm.bias", .{L}, false), bx, n_tok, n_embd, eps, 1);
        // FFN: bf = gelu(bx @ Wup + bup); bq = bf @ Wdn + bdn
        ok = ok and mmBias(K_MM, bx, tensorId(ctx, "blk.{d}.ffn_up.weight", .{L}, true), tensorId(ctx, "blk.{d}.ffn_up.bias", .{L}, false), bf, n_tok, n_embd, n_ffn);
        const gp = GeluParams{ .n = @intCast(n_tok * n_ffn) };
        ok = ok and dispatchP(K_GELU, &gp, &.{bf}, ceilDiv(n_tok * n_ffn, WG), 1);
        ok = ok and mmBias(K_MM, bf, tensorId(ctx, "blk.{d}.ffn_down.weight", .{L}, true), tensorId(ctx, "blk.{d}.ffn_down.bias", .{L}, false), bq, n_tok, n_ffn, n_embd);
        // LN(bq + bx) -> by  (input of the next layer)
        ok = ok and lnStep(K_LN, bq, bx, tensorId(ctx, "blk.{d}.layer_output_norm.weight", .{L}, false), tensorId(ctx, "blk.{d}.layer_output_norm.bias", .{L}, false), by, n_tok, n_embd, eps, 1);
    }

    // pool + L2 on device -> bp (n_embd floats)
    const pp = PoolParams{ .n_tok = @intCast(n_tok), .n_embd = @intCast(n_embd) };
    ok = ok and dispatchP(K_POOL, &pp, &.{ by, bp }, 1, 1);

    _ = gpu.stz_gpu_batch_end();
    if (!ok) return 0;
    if (gpu.stz_gpu_sync() != gpu.OK) return 0;
    if (gpu.stz_gpu_buffer_read(bp, @ptrCast(out), @floatFromInt(n_embd * 4)) != gpu.OK) return 0;
    return 1;
}

fn mmBias(kern: i64, a: i64, b: i64, bias: i64, out: i64, m: usize, k: usize, n: usize) bool {
    if (b == 0 or out == 0) return false;
    const has_bias: u32 = if (bias != 0) 1 else 0;
    const p = MmParams{ .m = @intCast(m), .k = @intCast(k), .n = @intCast(n), .has_bias = has_bias };
    const bb = if (bias != 0) bias else b; // a bound buffer is required either way
    return dispatchP(kern, &p, &.{ a, b, bb, out }, ceilDiv(n, 16), ceilDiv(m, 16));
}

fn lnStep(kern: i64, x: i64, res: i64, w: i64, b: i64, out: i64, n_tok: usize, n_embd: usize, eps: f32, use_res: u32) bool {
    if (w == 0 or b == 0) return false;
    const p = LnParams{ .n_tok = @intCast(n_tok), .n_embd = @intCast(n_embd), .use_res = use_res, .pad = 0, .eps = eps };
    return dispatchP(kern, &p, &.{ x, res, w, b, out }, n_tok, 1);
}

fn tensorId(ctx: *c.ggml_context, comptime fmt: []const u8, args: anytype, transpose: bool) i64 {
    const t = tensor(ctx, fmt, args) orelse return 0;
    return resident(t, transpose);
}

fn gatherRow(t: *c.ggml_tensor, row: usize, out: []f32) bool {
    const k: usize = @intCast(t.*.ne[0]);
    if (out.len < k) return false;
    if (t.*.type == c.GGML_TYPE_F32) {
        const src: [*]const f32 = @ptrCast(@alignCast(t.*.data));
        @memcpy(out[0..k], (src + row * k)[0..k]);
        return true;
    }
    const traits = c.ggml_get_type_traits(t.*.type);
    const to_float = traits.*.to_float orelse return false;
    const base: [*]const u8 = @ptrCast(t.*.data);
    to_float(base + row * t.*.nb[1], out.ptr, @intCast(k));
    return true;
}

// the model's own epsilon (BERT ships 1e-12; a model that states another
// value must get it -- a constant here would quietly change every LayerNorm)
fn kvEps(ctx: *c.ggml_context) f32 {
    _ = ctx;
    return embed.neural_model_ln_eps();
}
