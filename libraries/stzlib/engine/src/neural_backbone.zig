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
const ops = @import("gpu_ops.zig"); // GK2b: the matmul variants and their table
const verify = @import("gpu_verify.zig"); // GK2c: the checker, for the attention foundry

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
// The matmul-with-bias kernel is the op library's (gpu_ops.mmSource with the
// bias fused): GK2b's foundry judges the variants there, the variant table
// names one per (m, n, k) class, and mmBias compiles THAT one for each of the
// backbone's three shapes -- the generic when the table names none. The
// generic text is the 16x16 tile this file carried until 2026-09-10.
// ---- FUSED multi-head attention, and its variants (GK2c, under the checker) ----
//
// One workgroup per (head, query row) on a LINEAR grid (head = id % n_head,
// row = id / n_head) so the checker, which dispatches (wx, 1), judges every
// kernel here at every shape: scores -> softmax -> context, Q/K/V kept WHOLE
// (token-major, head h at dims [h*hd, (h+1)*hd)), scores in workgroup memory
// (n_tok <= 256). The generic is the kernel this file carried until
// 2026-09-10, whose softmax had EVERY thread scan max and sum over n_tok
// serially -- 64 threads doing the same n_tok exps -- and whose context
// phase used head_dim threads of the 64. The RED variants reduce max and sum
// through workgroup memory and split the context's token range across the
// threads a head does not need (parts = W / head_dim), at W = 64, 128, 256.
// A BROKEN sibling (RED64 with one output nudged) exists for the checker to
// refuse. Eligibility: n_tok <= 256 for all; head_dim <= W and W % head_dim
// == 0 for the RED family.

pub const ATT_GENERIC: usize = 0;
pub const ATT_RED64: usize = 1;
pub const ATT_RED128: usize = 2;
pub const ATT_RED256: usize = 3;
pub const ATT_BROKEN: usize = 4;
pub const ATT_REAL: usize = 4;
pub const ATT_VARIANTS: usize = 5;
pub const att_variant_names = [_][]const u8{ "scan64", "red64", "red128", "red256", "broken" };

const ATT_HEAD =
    \\struct P { n_tok : u32, n_embd : u32, n_head : u32, head_dim : u32, scale : f32, pad0 : u32, pad1 : u32, pad2 : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> q : array<f32>;
    \\@group(0) @binding(3) var<storage, read> k : array<f32>;
    \\@group(0) @binding(4) var<storage, read> v : array<f32>;
    \\@group(0) @binding(5) var<storage, read_write> outv : array<f32>;
    \\var<workgroup> sc : array<f32, 256>;
    \\
;

const WGSL_ATTENTION = PRELUDE ++ ATT_HEAD ++
    \\@compute @workgroup_size(64)
    \\fn main(@builtin(workgroup_id) wid : vec3<u32>,
    \\        @builtin(local_invocation_id) lid : vec3<u32>) {
    \\  let id = wid.x + tile.xoff;
    \\  let head = id % p.n_head;
    \\  let row  = min(id / p.n_head, p.n_tok - 1u);
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

/// The RED family at workgroup width W: tree reductions for max and sum, the
/// context's token range split W / head_dim ways.
fn attRedSource(comptime W: u32, comptime broken: bool) []const u8 {
    const ws = std.fmt.comptimePrint("{d}", .{W});
    return PRELUDE ++ ATT_HEAD ++
        "var<workgroup> red : array<f32, " ++ ws ++ ">;\n" ++
        "var<workgroup> pc : array<f32, " ++ ws ++ ">;\n" ++
        "@compute @workgroup_size(" ++ ws ++ ")\n" ++
        \\fn main(@builtin(workgroup_id) wid : vec3<u32>,
        \\        @builtin(local_invocation_id) lid : vec3<u32>) {
        \\  let W =
    ++ ws ++ "u;\n" ++
        \\  let id = wid.x + tile.xoff;
        \\  let head = id % p.n_head;
        \\  let row  = min(id / p.n_head, p.n_tok - 1u);
        \\  let base = head * p.head_dim;
        \\  let qoff = row * p.n_embd + base;
        \\  // 1. scores, and this thread's running max
        \\  var lmax = -3.4028235e38;
        \\  var j = lid.x;
        \\  loop {
        \\    if (j >= p.n_tok) { break; }
        \\    var dot = 0.0;
        \\    let koff = j * p.n_embd + base;
        \\    for (var d = 0u; d < p.head_dim; d = d + 1u) { dot = dot + q[qoff + d] * k[koff + d]; }
        \\    let sv = dot * p.scale;
        \\    sc[j] = sv;
        \\    lmax = max(lmax, sv);
        \\    j = j + W;
        \\  }
        \\  red[lid.x] = lmax;
        \\  workgroupBarrier();
        \\  for (var s = W / 2u; s > 0u; s = s >> 1u) {
        \\    if (lid.x < s) { red[lid.x] = max(red[lid.x], red[lid.x + s]); }
        \\    workgroupBarrier();
        \\  }
        \\  let mx = red[0];
        \\  workgroupBarrier();
        \\  // 2. exponentiate in place, and this thread's running sum
        \\  var lsum = 0.0;
        \\  j = lid.x;
        \\  loop {
        \\    if (j >= p.n_tok) { break; }
        \\    let e = exp(sc[j] - mx);
        \\    sc[j] = e;
        \\    lsum = lsum + e;
        \\    j = j + W;
        \\  }
        \\  red[lid.x] = lsum;
        \\  workgroupBarrier();
        \\  for (var s = W / 2u; s > 0u; s = s >> 1u) {
        \\    if (lid.x < s) { red[lid.x] = red[lid.x] + red[lid.x + s]; }
        \\    workgroupBarrier();
        \\  }
        \\  let sum = red[0];
        \\  workgroupBarrier();
        \\  // 3. context: the token range split parts ways per output dim
        \\  let parts = W / p.head_dim;
        \\  let dim = lid.x % p.head_dim;
        \\  let part = lid.x / p.head_dim;
        \\  var acc = 0.0;
        \\  if (part < parts) {
        \\    for (var t = part; t < p.n_tok; t = t + parts) { acc = acc + sc[t] * v[t * p.n_embd + base + dim]; }
        \\  }
        \\  pc[lid.x] = acc;
        \\  workgroupBarrier();
        \\  if (part == 0u) {
        \\    var tot = 0.0;
        \\    for (var qq = 0u; qq < parts; qq = qq + 1u) { tot = tot + pc[qq * p.head_dim + dim]; }
        \\
    ++ (if (broken)
        \\    if (row == 1u && dim == 1u) { tot = tot + 0.001 * sum; }
        \\
    else
        \\
    ) ++
        \\    outv[row * p.n_embd + base + dim] = tot / sum;
        \\  }
        \\}
    ;
}

fn attSource(v: usize) []const u8 {
    return switch (v) {
        ATT_RED64 => comptime attRedSource(64, false),
        ATT_RED128 => comptime attRedSource(128, false),
        ATT_RED256 => comptime attRedSource(256, false),
        ATT_BROKEN => comptime attRedSource(64, true),
        else => WGSL_ATTENTION,
    };
}

pub fn attVariantEligible(v: usize, n_tok: usize, head_dim: usize) bool {
    if (n_tok == 0 or n_tok > 256 or head_dim == 0) return false;
    const w: usize = switch (v) {
        ATT_GENERIC => return true,
        ATT_RED64, ATT_BROKEN => 64,
        ATT_RED128 => 128,
        ATT_RED256 => 256,
        else => return false,
    };
    return head_dim <= w and w % head_dim == 0;
}

var k_att: [ATT_VARIANTS]i64 = @splat(0);

fn attKernelFor(v: usize) i64 {
    if (k_att[v] == 0) {
        const src = attSource(v);
        k_att[v] = gpu.stz_gpu_kernel_compile(src.ptr, @floatFromInt(src.len));
    }
    return k_att[v];
}

/// The table's choice for (n_tok, n_embd, head_dim), degraded to an eligible one.
fn attVariantFor(n_tok: usize, n_embd: usize, head_dim: usize) usize {
    const want: usize = @intFromFloat(ops.stz_gpu_variant_get("attention", 9, @floatFromInt(n_tok), @floatFromInt(n_embd), @floatFromInt(head_dim)));
    var v = if (want < ATT_REAL) want else ATT_GENERIC;
    while (v > ATT_GENERIC and !attVariantEligible(v, n_tok, head_dim)) v -= 1;
    return v;
}

/// the variant the last forward dispatched for its attention -- a guard's witness
var g_att_variant_used: usize = 0;

pub export fn neural_attention_variant_used() callconv(.c) c_int {
    return @intCast(g_att_variant_used);
}

pub export fn neural_attention_variant_name(vf: f64, out: [*]u8, cap: f64) callconv(.c) c_int {
    const i: usize = @intFromFloat(@max(vf, 0));
    if (i >= ATT_VARIANTS) return 0;
    const nm = att_variant_names[i];
    const room: usize = @intFromFloat(cap);
    if (nm.len > room) return 0;
    @memcpy(out[0..nm.len], nm);
    return @intCast(nm.len);
}

// ---- the attention foundry: the enumeration under the checker ----

pub const AF_COUNT = 0;
pub const AF_REF_GPU_MS = 1;
pub const AF_REF_WALL_MS = 2;
pub const AF_WINNER = 3;
pub const AF_WINNER_RATIO = 4;
pub const AF_CLOCKS = 5;
pub const AF_HIDDEN_N = 6;
pub const AF_BASE = 8; // per variant v: AF_BASE + v*5 + {verified, gpu_ms, wall_ms, ratio_gpu, ratio_wall}
pub const AF_STRIDE = 5;
pub const AF_SLOTS = AF_BASE + ATT_VARIANTS * AF_STRIDE;
var af_result: [AF_SLOTS]f64 = @splat(0);
pub const AF_MARGIN: f64 = 1.3;

pub export fn neural_attention_foundry_result(idx: c_int) callconv(.c) f64 {
    if (idx < 0 or idx >= AF_SLOTS) return 0;
    return af_result[@intCast(idx)];
}

fn fillLcg(id: i64, count: usize, seed: u32) bool {
    const host = std.heap.c_allocator.alloc(f32, count) catch return false;
    defer std.heap.c_allocator.free(host);
    var r: u32 = seed;
    for (host) |*x| {
        r = r *% 1664525 +% 1013904223;
        x.* = @as(f32, @floatFromInt(r >> 8)) / 16777216.0 - 0.5;
    }
    return gpu.stz_gpu_buffer_write(id, @ptrCast(host.ptr), @floatFromInt(count * 4)) == gpu.OK;
}

/// Run the enumeration at (n_tok, n_embd, n_head): each variant against the
/// generic on the same Q/K/V at this shape and a hidden odd token count,
/// GPU clock, device awake; the winner past 1.3x into AF_WINNER -- the
/// caller records it. `mask` selects variants (bit v); 0 = every real one.
pub export fn neural_attention_foundry(ntf: f64, nef: f64, nhf: f64, reps: f64, maskf: f64) callconv(.c) c_int {
    af_result = @splat(0);
    if (!ngpu.ensureDevicePub()) return gpu.FALLBACK;
    const n_tok: usize = @intFromFloat(ntf);
    const n_embd: usize = @intFromFloat(nef);
    const n_head: usize = @intFromFloat(nhf);
    if (n_tok < 2 or n_tok > 256 or n_embd == 0 or n_head == 0 or n_embd % n_head != 0) return gpu.BAD_ARG;
    const head_dim = n_embd / n_head;
    var mask: u32 = @intFromFloat(maskf);
    if (mask == 0) mask = (@as(u32, 1) << ATT_REAL) - 2;
    const n_tok2: usize = @max(3, ((n_tok * 5) / 7) | 1);
    af_result[AF_COUNT] = @floatFromInt(ATT_REAL - 1);
    af_result[AF_HIDDEN_N] = @floatFromInt(n_tok2);
    _ = verify.stz_gpu_wake(400);
    const act = n_tok * n_embd * 4;
    const act2 = n_tok2 * n_embd * 4;
    const ids = [_]i64{
        gpu.stz_gpu_buffer_new(@floatFromInt(act)),  gpu.stz_gpu_buffer_new(@floatFromInt(act)),  gpu.stz_gpu_buffer_new(@floatFromInt(act)),  gpu.stz_gpu_buffer_new(@floatFromInt(act)),
        gpu.stz_gpu_buffer_new(@floatFromInt(act2)), gpu.stz_gpu_buffer_new(@floatFromInt(act2)), gpu.stz_gpu_buffer_new(@floatFromInt(act2)), gpu.stz_gpu_buffer_new(@floatFromInt(act2)),
    };
    defer {
        for (ids) |id| {
            if (id != 0) _ = gpu.stz_gpu_buffer_free(id);
        }
    }
    for (ids) |id| if (id == 0) return gpu.GPU_ERROR;
    if (!fillLcg(ids[0], n_tok * n_embd, 101)) return gpu.GPU_ERROR;
    if (!fillLcg(ids[1], n_tok * n_embd, 202)) return gpu.GPU_ERROR;
    if (!fillLcg(ids[2], n_tok * n_embd, 303)) return gpu.GPU_ERROR;
    if (!fillLcg(ids[4], n_tok2 * n_embd, 404)) return gpu.GPU_ERROR;
    if (!fillLcg(ids[5], n_tok2 * n_embd, 505)) return gpu.GPU_ERROR;
    if (!fillLcg(ids[6], n_tok2 * n_embd, 606)) return gpu.GPU_ERROR;
    const kref = attKernelFor(ATT_GENERIC);
    if (kref == 0) return gpu.GPU_ERROR;
    const scale: f32 = 1.0 / @sqrt(@as(f32, @floatFromInt(head_dim)));
    const pa = AttParams{ .n_tok = @intCast(n_tok), .n_embd = @intCast(n_embd), .n_head = @intCast(n_head), .head_dim = @intCast(head_dim), .scale = scale };
    const pb = AttParams{ .n_tok = @intCast(n_tok2), .n_embd = @intCast(n_embd), .n_head = @intCast(n_head), .head_dim = @intCast(head_dim), .scale = scale };
    const ba = std.mem.asBytes(&pa);
    const bb = std.mem.asBytes(&pb);
    const ids_a = [_]i64{ ids[0], ids[1], ids[2], ids[3] };
    const ids_b = [_]i64{ ids[4], ids[5], ids[6], ids[7] };
    const wx_a = n_head * n_tok;
    const wx_b = n_head * n_tok2;
    // softmax weights in [0, 1] over a context of values in [-0.5, 0.5]: the
    // summation orders differ (serial against a tree); the band is f32's
    const band: f64 = 1e-4;
    var best_v: usize = 0;
    var best_ratio: f64 = 1.0;
    var v: usize = 1;
    while (v < ATT_VARIANTS) : (v += 1) {
        const base = AF_BASE + v * AF_STRIDE;
        if ((mask & (@as(u32, 1) << @intCast(v))) == 0) {
            af_result[base] = -2;
            continue;
        }
        if (!attVariantEligible(v, n_tok, head_dim)) {
            af_result[base] = -1;
            continue;
        }
        const kv = attKernelFor(v);
        if (kv == 0) return gpu.GPU_ERROR;
        const st = verify.stz_gpu_verify(kref, kv, ba.ptr, @floatFromInt(ba.len), &ids_a, 4, @floatFromInt(n_tok * n_embd), @floatFromInt(wx_a), @floatFromInt(wx_a), bb.ptr, @floatFromInt(bb.len), &ids_b, 4, @floatFromInt(n_tok2 * n_embd), @floatFromInt(wx_b), @floatFromInt(wx_b), reps, band);
        if (st != gpu.OK) return st;
        const verdict: i32 = @intFromFloat(verify.stz_gpu_verify_result(verify.R_VERDICT));
        const clocks = verify.stz_gpu_verify_result(verify.R_CLOCKS);
        af_result[AF_CLOCKS] = clocks;
        af_result[AF_REF_WALL_MS] = verify.stz_gpu_verify_result(verify.R_REF_MS);
        af_result[AF_REF_GPU_MS] = verify.stz_gpu_verify_result(verify.R_REF_GPU_MS);
        if (verdict != verify.V_VERIFIED) {
            af_result[base] = 0;
            continue;
        }
        af_result[base] = 1;
        af_result[base + 1] = verify.stz_gpu_verify_result(verify.R_CAND_GPU_MS);
        af_result[base + 2] = verify.stz_gpu_verify_result(verify.R_CAND_MS);
        af_result[base + 3] = verify.stz_gpu_verify_result(verify.R_SPEEDUP_GPU);
        af_result[base + 4] = verify.stz_gpu_verify_result(verify.R_SPEEDUP);
        const ratio = if (clocks >= 2) af_result[base + 3] else af_result[base + 4];
        if (v < ATT_REAL and ratio > best_ratio) {
            best_ratio = ratio;
            best_v = v;
        }
    }
    af_result[AF_WINNER] = if (best_v != 0 and best_ratio >= AF_MARGIN) @floatFromInt(best_v) else 0;
    af_result[AF_WINNER_RATIO] = best_ratio;
    return gpu.OK;
}

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

// ---------------------------------------------------------------- the routing gate
//
// The SILENT SEAM (G3's pattern): every embedding call goes through
// neural_embed_routed, which sends long-enough sequences to the backbone and
// leaves everything else on ggml's CPU kernels. The line is in TOKENS and it
// is MEASURED, not guessed -- on the dev machine (RTX 3050, MiniLM-L6-v2):
//
//     tokens   11     20     29     47     74    119    182    254
//     ratio  0.755  1.021  1.341  1.585  1.671  1.567  1.942
//
// The backbone LOSES below ~20 tokens (its per-call floor is not free) and
// only earns a real margin from ~29. The default sits at 32: past break-even
// with room, never AT it. Below the line the CPU keeps the work, and the
// guard asserts that side too.
var g_min_tokens: f64 = 32;
var g_used_backbone: f64 = 0;
var g_used_cpu: f64 = 0;

pub export fn neural_backbone_set_min_tokens(n: f64) callconv(.c) void {
    if (n >= 2) g_min_tokens = n;
}

pub export fn neural_backbone_min_tokens() callconv(.c) f64 {
    return g_min_tokens;
}

/// 0 = embeddings served by the backbone, 1 = served by the CPU forward.
pub export fn neural_backbone_route_count(which: c_int) callconv(.c) f64 {
    return if (which == 0) g_used_backbone else g_used_cpu;
}

pub export fn neural_backbone_route_reset() callconv(.c) void {
    g_used_backbone = 0;
    g_used_cpu = 0;
}

/// THE routed entry point: same contract as neural_embed_text (returns the
/// dimension, vector readable via neural_embed_at), but sends work to the
/// GPU backbone when the sequence is long enough to pay for it. Any refusal
/// -- unsupported architecture, no device, a failed dispatch -- falls
/// through to the CPU forward with the same answer.
pub export fn neural_embed_routed(text: [*c]const u8, len: usize) callconv(.c) c_int {
    const n_tok = embed.neural_tokenize(text, len);
    if (@as(f64, @floatFromInt(n_tok)) >= g_min_tokens and neural_backbone_supported() == 1) {
        const n_embd: usize = @intCast(embed.neural_model_n_embd());
        if (n_embd > 0) {
            const ids = gpa.alloc(i32, @intCast(n_tok)) catch {
                g_used_cpu += 1;
                return embed.neural_embed_text(text, len);
            };
            defer gpa.free(ids);
            for (0..@intCast(n_tok)) |i| ids[i] = embed.neural_token_at(@intCast(i));
            const vec = gpa.alloc(f32, n_embd) catch {
                g_used_cpu += 1;
                return embed.neural_embed_text(text, len);
            };
            defer gpa.free(vec);
            if (neural_backbone_forward(ids.ptr, n_tok, vec.ptr) == 1 and
                embed.installEmbedding(vec))
            {
                g_used_backbone += 1;
                return @intCast(n_embd);
            }
        }
    }
    g_used_cpu += 1;
    return embed.neural_embed_text(text, len);
}

// ---------------------------------------------------------------- the pass

var g_kernels: [5]i64 = @splat(0);

fn kernels() bool {
    const srcs = [_][]const u8{ ops.mmSource(ops.MM_GENERIC, true), WGSL_ATTENTION, WGSL_ADD_LN, WGSL_GELU, WGSL_POOL_L2 };
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
        // GK2c: the table's attention variant for this shape, on the linear grid
        const v_att = attVariantFor(n_tok, n_embd, head_dim);
        var k_use = K_ATT;
        if (v_att != ATT_GENERIC) {
            k_use = attKernelFor(v_att);
            if (k_use == 0) k_use = K_ATT;
        }
        g_att_variant_used = if (k_use == K_ATT) ATT_GENERIC else v_att;
        if (k_use != K_ATT) gpu.bumpCounter(gpu.CTR_VARIANT_DISPATCH, 1);
        ok = ok and dispatchP(k_use, &ap, &.{ bq, bk, bv, bx }, n_head * n_tok, 1);
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

fn mmBias(kern_generic: i64, a: i64, b: i64, bias: i64, out: i64, m: usize, k: usize, n: usize) bool {
    if (b == 0 or out == 0) return false;
    // the table's variant for this shape class, compiled with the bias fused
    // (the compile cache answers by hash after the first time); the generic
    // handle the pass compiled stands in when the table names the generic
    const v = ops.mmVariantFor(m, k, n);
    var kern = kern_generic;
    if (v != ops.MM_GENERIC) {
        const src = ops.mmSource(v, true);
        kern = gpu.stz_gpu_kernel_compile(src.ptr, @floatFromInt(src.len));
        if (kern == 0) kern = kern_generic;
        if (kern != kern_generic) gpu.bumpCounter(gpu.CTR_VARIANT_DISPATCH, 1);
    }
    const has_bias: u32 = if (bias != 0) 1 else 0;
    const p = MmParams{ .m = @intCast(m), .k = @intCast(k), .n = @intCast(n), .has_bias = has_bias };
    const bb = if (bias != 0) bias else b; // a bound buffer is required either way
    const g = ops.mmGeometry(if (kern == kern_generic) ops.MM_GENERIC else v, m, n);
    return dispatchP(kern, &p, &.{ a, b, bb, out }, g.wx, g.wy);
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
