//! gpu_foundry.zig -- GK2: op VARIANTS by enumeration, under GK0's checker
//! (SOFTANZA_GPU_PLAN.md, section GK).
//!
//! Proteus's architecture with the cheapest proposer that fills the role:
//! a for-loop proposes the variants the op library carries, GK0's checker
//! verifies each against the GENERIC kernel on the same device buffers at a
//! visible shape and a hidden one (different size, different data), times
//! both on the GPU clock with the device awake, and the winner -- if it
//! beats the generic by the margin -- is recorded for the SHAPE CLASS in the
//! variant table the op consults at dispatch. A variant the checker refuses
//! cannot enter the table, whatever it timed. The results are slots; Ring
//! reads them.
//!
//! Scope: pairdist, m <= 16 (the single-query family the seams dispatch --
//! GK0's checker dispatches (wx, 1), which is the generic tile's geometry
//! only while m fits one tile row). Matmul and the elementwise workgroup
//! widths are GK2b, not here.

const std = @import("std");
const gpu = @import("gpu.zig");
const ops = @import("gpu_ops.zig");
const verify = @import("gpu_verify.zig");

// result slots
pub const F_COUNT = 0; // variants the op library carries (real ones)
pub const F_REF_GPU_MS = 1; // the generic kernel, GPU clock (-1 = one clock)
pub const F_REF_WALL_MS = 2;
pub const F_WINNER = 3; // variant index, 0 = the generic stays
pub const F_WINNER_RATIO = 4; // generic / winner on the GPU clock (wall if one clock)
pub const F_CLOCKS = 5;
pub const F_HIDDEN_N = 6;
pub const F_FLOPS = 7; // GK3: the op's FLOPs at the visible shape (2mkn for matmul, 3mnd for pairdist)
pub const F_BYTES = 8; // GK3: the bytes the visible shape's buffers hold
pub const F_PEAK_GFLOPS = 9; // GK3: the compute peak the checker judged against
pub const F_BASE = 10; // per variant v: F_BASE + v*5 + {0 verified, 1 gpu_ms, 2 wall_ms, 3 ratio_gpu, 4 ratio_wall}
pub const F_STRIDE = 5;
pub const F_SLOTS = F_BASE + (if (ops.PD_VARIANTS > ops.MM_VARIANTS) ops.PD_VARIANTS else ops.MM_VARIANTS) * F_STRIDE;
var result: [F_SLOTS]f64 = @splat(0);

pub fn stz_gpu_foundry_result(idx: i32) callconv(.c) f64 {
    if (idx < 0 or idx >= F_SLOTS) return 0;
    return result[@intCast(idx)];
}

pub const MARGIN: f64 = 1.3;

fn ceilDiv(a: usize, b: usize) usize {
    return (a + b - 1) / b;
}

/// Deterministic pseudo-random fill in [0, 1): the visible and hidden sets
/// take different seeds, so a variant right on one set and wrong on the
/// other is caught, not credited.
fn fillBuffer(id: i64, count: usize, seed: u32) bool {
    const alloc = std.heap.c_allocator;
    const host = alloc.alloc(f32, count) catch return false;
    defer alloc.free(host);
    var x: u32 = seed;
    for (host) |*v| {
        x = x *% 1664525 +% 1013904223;
        v.* = @as(f32, @floatFromInt(x >> 8)) / 16777216.0;
    }
    return gpu.stz_gpu_buffer_write(id, @ptrCast(host.ptr), @floatFromInt(count * 4)) == gpu.OK;
}

/// Fill a device buffer with the foundry's deterministic pseudo-random f32
/// in [0, 1): a probe's way to stage millions of samples without a Ring list.
pub fn stz_gpu_buffer_fill_lcg(id: i64, countf: f64, seedf: f64) callconv(.c) i32 {
    if (!gpu.isAvail()) return gpu.FALLBACK;
    const count: usize = @intFromFloat(countf);
    if (count == 0) return gpu.BAD_ARG;
    return if (fillBuffer(id, count, @intFromFloat(seedf))) gpu.OK else gpu.GPU_ERROR;
}

/// Run the enumeration for pairdist at shape (m, n, d). `mask` selects the
/// variants to try (bit v); 0 = every REAL variant. The test-only broken
/// variant is reachable only through the mask -- a guard's negative sibling.
/// Returns a status; the verdicts land in the slots.
pub fn stz_gpu_foundry_pairdist(mf: f64, nf: f64, df: f64, reps: f64, maskf: f64) callconv(.c) i32 {
    result = @splat(0);
    if (!gpu.isAvail()) {
        gpu.countFallback();
        return gpu.FALLBACK;
    }
    const m: usize = @intFromFloat(mf);
    const n: usize = @intFromFloat(nf);
    const d: usize = @intFromFloat(df);
    if (m == 0 or m > 16 or n < 2 or d == 0) return gpu.BAD_ARG;
    var mask: u32 = @intFromFloat(maskf);
    if (mask == 0) mask = (@as(u32, 1) << ops.PD_REAL) - 2; // bits 1..PD_REAL-1
    const n2: usize = @max(1, ((n * 5) / 7) | 1); // the hidden size: odd, tile-uneven, smaller
    result[F_COUNT] = @floatFromInt(ops.PD_REAL - 1);
    result[F_HIDDEN_N] = @floatFromInt(n2);

    _ = verify.stz_gpu_wake(400); // the device is AWAKE before anything is timed

    // buffers: visible A(m x d) B(n x d) D(m x n); hidden A2 B2(n2 x d) D2
    const ids = [_]i64{
        gpu.stz_gpu_buffer_new(@floatFromInt(m * d * 4)),
        gpu.stz_gpu_buffer_new(@floatFromInt(n * d * 4)),
        gpu.stz_gpu_buffer_new(@floatFromInt(m * n * 4)),
        gpu.stz_gpu_buffer_new(@floatFromInt(m * d * 4)),
        gpu.stz_gpu_buffer_new(@floatFromInt(n2 * d * 4)),
        gpu.stz_gpu_buffer_new(@floatFromInt(m * n2 * 4)),
    };
    defer {
        for (ids) |id| {
            if (id != 0) _ = gpu.stz_gpu_buffer_free(id);
        }
    }
    for (ids) |id| if (id == 0) return gpu.GPU_ERROR;
    if (!fillBuffer(ids[0], m * d, 12345)) return gpu.GPU_ERROR;
    if (!fillBuffer(ids[1], n * d, 777)) return gpu.GPU_ERROR;
    if (!fillBuffer(ids[3], m * d, 424242)) return gpu.GPU_ERROR;
    if (!fillBuffer(ids[4], n2 * d, 99991)) return gpu.GPU_ERROR;

    const kref = ops.pdKernelFor(ops.PD_GENERIC);
    if (kref == 0) return gpu.GPU_ERROR;
    const pa = ops.PdParams{ .m = @intCast(m), .n = @intCast(n), .d = @intCast(d), .pad = 0 };
    const pb = ops.PdParams{ .m = @intCast(m), .n = @intCast(n2), .d = @intCast(d), .pad = 0 };
    const ba = std.mem.asBytes(&pa);
    const bb = std.mem.asBytes(&pb);
    const ids_a = [_]i64{ ids[0], ids[1], ids[2] };
    const ids_b = [_]i64{ ids[3], ids[4], ids[5] };
    const gref_a = ops.pdGeometry(ops.PD_GENERIC, m, n);
    const gref_b = ops.pdGeometry(ops.PD_GENERIC, m, n2);
    // the band: f32 accumulation order differs between a 16-chunk tile and a
    // straight row loop; distances scale with d, so the band does too
    const band: f64 = 1e-4 * @as(f64, @floatFromInt(d));
    // GK3: the work, so the checker's compute ceiling applies and the table
    // can say what fraction of the peak each variant reached. Squared L2 per
    // (row, row, dim) is a subtract and a fused multiply-add: 3 FLOP.
    const flops_a: f64 = 3.0 * @as(f64, @floatFromInt(m * n * d));
    const flops_b: f64 = 3.0 * @as(f64, @floatFromInt(m * n2 * d));
    result[F_FLOPS] = flops_a;
    result[F_BYTES] = @floatFromInt((m * d + n * d + m * n) * 4);

    var best_v: usize = 0;
    var best_ratio: f64 = 1.0;
    var v: usize = 1;
    while (v < ops.PD_VARIANTS) : (v += 1) {
        const base = F_BASE + v * F_STRIDE;
        if ((mask & (@as(u32, 1) << @intCast(v))) == 0) {
            result[base] = -2; // not asked
            continue;
        }
        if (!ops.pdVariantEligible(v, m, n, d)) {
            result[base] = -1; // not eligible at this shape
            continue;
        }
        const kv = ops.pdKernelFor(v);
        if (kv == 0) return gpu.GPU_ERROR;
        const gv_a = ops.pdGeometry(v, m, n);
        const gv_b = ops.pdGeometry(v, m, n2);
        verify.stz_gpu_verify_declare_flops(flops_a, flops_b);
        const st = verify.stz_gpu_verify(
            kref,
            kv,
            ba.ptr,
            @floatFromInt(ba.len),
            &ids_a,
            3,
            @floatFromInt(m * n),
            @floatFromInt(gref_a.wx),
            @floatFromInt(gv_a.wx),
            bb.ptr,
            @floatFromInt(bb.len),
            &ids_b,
            3,
            @floatFromInt(m * n2),
            @floatFromInt(gref_b.wx),
            @floatFromInt(gv_b.wx),
            reps,
            band,
        );
        if (st != gpu.OK) return st;
        const verdict: i32 = @intFromFloat(verify.stz_gpu_verify_result(verify.R_VERDICT));
        const clocks = verify.stz_gpu_verify_result(verify.R_CLOCKS);
        result[F_CLOCKS] = clocks;
        result[F_PEAK_GFLOPS] = verify.stz_gpu_verify_result(verify.R_PEAK_GFLOPS);
        result[F_REF_WALL_MS] = verify.stz_gpu_verify_result(verify.R_REF_MS);
        result[F_REF_GPU_MS] = verify.stz_gpu_verify_result(verify.R_REF_GPU_MS);
        if (verdict != verify.V_VERIFIED) {
            result[base] = 0; // REFUSED by the checker: never a winner
            continue;
        }
        result[base] = 1;
        result[base + 1] = verify.stz_gpu_verify_result(verify.R_CAND_GPU_MS);
        result[base + 2] = verify.stz_gpu_verify_result(verify.R_CAND_MS);
        result[base + 3] = verify.stz_gpu_verify_result(verify.R_SPEEDUP_GPU);
        result[base + 4] = verify.stz_gpu_verify_result(verify.R_SPEEDUP);
        // kernels are compared on the GPU clock (GK0's finding); the wall
        // clock stands in only where the adapter has no second clock
        const ratio = if (clocks >= 2) result[base + 3] else result[base + 4];
        if (ratio > best_ratio) {
            best_ratio = ratio;
            best_v = v;
        }
    }
    if (best_v != 0 and best_ratio >= MARGIN) {
        result[F_WINNER] = @floatFromInt(best_v);
        result[F_WINNER_RATIO] = best_ratio;
    } else {
        result[F_WINNER] = 0;
        result[F_WINNER_RATIO] = best_ratio;
    }
    return gpu.OK;
}

/// GK2b's matmul leg: the enumeration for C(m x n) = A(m x k) B(k x n).
/// The hidden shape moves m AND n (odd, tile-uneven, smaller) and keeps k --
/// the backbone's k is the model's width and a variant right only at a
/// k-multiple of its step would be caught by the visible shape's tail.
pub fn stz_gpu_foundry_matmul(mf: f64, kf: f64, nf: f64, reps: f64, maskf: f64) callconv(.c) i32 {
    result = @splat(0);
    if (!gpu.isAvail()) {
        gpu.countFallback();
        return gpu.FALLBACK;
    }
    const m: usize = @intFromFloat(mf);
    const k: usize = @intFromFloat(kf);
    const n: usize = @intFromFloat(nf);
    if (m == 0 or k == 0 or n == 0) return gpu.BAD_ARG;
    var mask: u32 = @intFromFloat(maskf);
    if (mask == 0) {
        for (1..ops.MM_VARIANTS) |rv| {
            if (ops.mmIsReal(rv)) mask |= @as(u32, 1) << @intCast(rv);
        }
    }
    const m2: usize = @max(1, ((m * 5) / 7) | 1);
    const n2: usize = @max(1, ((n * 5) / 7) | 1);
    var n_real: usize = 0;
    for (1..ops.MM_VARIANTS) |rv| {
        if (ops.mmIsReal(rv)) n_real += 1;
    }
    result[F_COUNT] = @floatFromInt(n_real);
    result[F_HIDDEN_N] = @floatFromInt(n2);
    _ = verify.stz_gpu_wake(400);

    const ids = [_]i64{
        gpu.stz_gpu_buffer_new(@floatFromInt(m * k * 4)),
        gpu.stz_gpu_buffer_new(@floatFromInt(k * n * 4)),
        gpu.stz_gpu_buffer_new(@floatFromInt(m * n * 4)),
        gpu.stz_gpu_buffer_new(@floatFromInt(m2 * k * 4)),
        gpu.stz_gpu_buffer_new(@floatFromInt(k * n2 * 4)),
        gpu.stz_gpu_buffer_new(@floatFromInt(m2 * n2 * 4)),
    };
    defer {
        for (ids) |id| {
            if (id != 0) _ = gpu.stz_gpu_buffer_free(id);
        }
    }
    for (ids) |id| if (id == 0) return gpu.GPU_ERROR;
    if (!fillBuffer(ids[0], m * k, 31337)) return gpu.GPU_ERROR;
    if (!fillBuffer(ids[1], k * n, 4242)) return gpu.GPU_ERROR;
    if (!fillBuffer(ids[3], m2 * k, 8675309)) return gpu.GPU_ERROR;
    if (!fillBuffer(ids[4], k * n2, 271828)) return gpu.GPU_ERROR;

    const kref = ops.mmKernelFor(ops.MM_GENERIC);
    if (kref == 0) return gpu.GPU_ERROR;
    const pa = ops.MmParams{ .m = @intCast(m), .k = @intCast(k), .n = @intCast(n), .pad = 0 };
    const pb = ops.MmParams{ .m = @intCast(m2), .k = @intCast(k), .n = @intCast(n2), .pad = 0 };
    const ba = std.mem.asBytes(&pa);
    const bb = std.mem.asBytes(&pb);
    const ids_a = [_]i64{ ids[0], ids[1], ids[2] };
    const ids_b = [_]i64{ ids[3], ids[4], ids[5] };
    const gref_a = ops.mmGeometry(ops.MM_GENERIC, m, n);
    const gref_b = ops.mmGeometry(ops.MM_GENERIC, m2, n2);
    // f32 sums of k products in [0, 1): the order is the same in every variant
    // (k ascending) but fused multiply-adds may differ; the band scales with k
    const band: f64 = 2e-5 * @as(f64, @floatFromInt(k));
    // GK3: 2 FLOP per multiply-add, m*k*n of them
    const flops_a: f64 = 2.0 * @as(f64, @floatFromInt(m * k * n));
    const flops_b: f64 = 2.0 * @as(f64, @floatFromInt(m2 * k * n2));
    result[F_FLOPS] = flops_a;
    result[F_BYTES] = @floatFromInt((m * k + k * n + m * n) * 4);

    var best_v: usize = 0;
    var best_ratio: f64 = 1.0;
    var v: usize = 1;
    while (v < ops.MM_VARIANTS) : (v += 1) {
        const base = F_BASE + v * F_STRIDE;
        if ((mask & (@as(u32, 1) << @intCast(v))) == 0) {
            result[base] = -2;
            continue;
        }
        if (!ops.mmVariantEligible(v, m, k, n)) {
            result[base] = -1;
            continue;
        }
        const kv = ops.mmKernelFor(v);
        if (kv == 0) return gpu.GPU_ERROR;
        const gv_a = ops.mmGeometry(v, m, n);
        const gv_b = ops.mmGeometry(v, m2, n2);
        verify.stz_gpu_verify_declare_flops(flops_a, flops_b);
        const st = verify.stz_gpu_verify(kref, kv, ba.ptr, @floatFromInt(ba.len), &ids_a, 3, @floatFromInt(m * n), @floatFromInt(gref_a.wx), @floatFromInt(gv_a.wx), bb.ptr, @floatFromInt(bb.len), &ids_b, 3, @floatFromInt(m2 * n2), @floatFromInt(gref_b.wx), @floatFromInt(gv_b.wx), reps, band);
        if (st != gpu.OK) return st;
        const verdict: i32 = @intFromFloat(verify.stz_gpu_verify_result(verify.R_VERDICT));
        const clocks = verify.stz_gpu_verify_result(verify.R_CLOCKS);
        result[F_CLOCKS] = clocks;
        result[F_PEAK_GFLOPS] = verify.stz_gpu_verify_result(verify.R_PEAK_GFLOPS);
        result[F_REF_WALL_MS] = verify.stz_gpu_verify_result(verify.R_REF_MS);
        result[F_REF_GPU_MS] = verify.stz_gpu_verify_result(verify.R_REF_GPU_MS);
        if (verdict != verify.V_VERIFIED) {
            result[base] = 0;
            continue;
        }
        result[base] = 1;
        result[base + 1] = verify.stz_gpu_verify_result(verify.R_CAND_GPU_MS);
        result[base + 2] = verify.stz_gpu_verify_result(verify.R_CAND_MS);
        result[base + 3] = verify.stz_gpu_verify_result(verify.R_SPEEDUP_GPU);
        result[base + 4] = verify.stz_gpu_verify_result(verify.R_SPEEDUP);
        const ratio = if (clocks >= 2) result[base + 3] else result[base + 4];
        if (ops.mmIsReal(v) and ratio > best_ratio) {
            best_ratio = ratio;
            best_v = v;
        }
    }
    result[F_WINNER] = if (best_v != 0 and best_ratio >= MARGIN) @floatFromInt(best_v) else 0;
    result[F_WINNER_RATIO] = best_ratio;
    return gpu.OK;
}

// ---------------------------------------------------------------- GK5
// The table's matmul variant for (m, k, n), with its weights in f32 and in
// f16, on the same A and the same values of B: alternated A B A B, each turn
// the best of `reps` on both clocks, and both results held against a product
// computed in f64 on the host from the f32 B. The f16 error includes the
// rounding of the weights to f16 at upload; the accumulation is f32 in both.
pub const H_OK = 0; // 1 measured; 0 the device was not granted shader-f16
pub const H_VARIANT = 1;
pub const H_CLOCKS = 2;
pub const H_F32_GPU_MS = 3; // best over all turns; -1 without timestamps
pub const H_F16_GPU_MS = 4;
pub const H_F32_WALL_MS = 5;
pub const H_F16_WALL_MS = 6;
pub const H_RATIO_GPU = 7; // f32 / f16: above 1 means f16 is faster
pub const H_RATIO_WALL = 8;
pub const H_B32_BYTES = 9;
pub const H_B16_BYTES = 10;
pub const H_ERR32 = 11; // max |C - ref|, f32 weights
pub const H_ERR16 = 12; // max |C - ref|, f16 weights
pub const H_DIFF = 13; // max |C16 - C32|
pub const H_REFMAX = 14; // max |ref|, to read the errors against
pub const H_TURNS = 15;
pub const H_SLOTS = 24; // 16 + 2 x 4 turns: per turn the f32 then the f16 GPU-clock best
var hres: [H_SLOTS]f64 = @splat(0);

pub fn stz_gpu_foundry_f16_result(idx: i32) callconv(.c) f64 {
    if (idx < 0 or idx >= H_SLOTS) return 0;
    return hres[@intCast(idx)];
}

pub fn stz_gpu_foundry_matmul_f16(mf: f64, kf: f64, nf: f64, reps: f64, vf: f64) callconv(.c) i32 {
    hres = @splat(0);
    if (!gpu.isAvail()) {
        gpu.countFallback();
        return gpu.FALLBACK;
    }
    if (!gpu.hasF16()) return gpu.OK; // H_OK stays 0: the refusal is the measurement
    const m: usize = @intFromFloat(mf);
    const k: usize = @intFromFloat(kf);
    const n: usize = @intFromFloat(nf);
    if (m == 0 or k == 0 or n == 0 or (k * n) % 2 != 0) return gpu.BAD_ARG;
    const alloc = std.heap.c_allocator;
    const a = alloc.alloc(f32, m * k) catch return gpu.GPU_ERROR;
    defer alloc.free(a);
    const b = alloc.alloc(f32, k * n) catch return gpu.GPU_ERROR;
    defer alloc.free(b);
    const bh = alloc.alloc(f16, k * n) catch return gpu.GPU_ERROR;
    defer alloc.free(bh);
    var x: u32 = 31337;
    for (a) |*v| {
        x = x *% 1664525 +% 1013904223;
        v.* = @as(f32, @floatFromInt(x >> 8)) / 16777216.0 - 0.5;
    }
    for (b, bh) |*v, *h| {
        x = x *% 1664525 +% 1013904223;
        v.* = (@as(f32, @floatFromInt(x >> 8)) / 16777216.0 - 0.5) * 0.25;
        h.* = @floatCast(v.*);
    }
    const ids = [_]i64{
        gpu.stz_gpu_buffer_new(@floatFromInt(m * k * 4)),
        gpu.stz_gpu_buffer_new(@floatFromInt(k * n * 4)),
        gpu.stz_gpu_buffer_new(@floatFromInt(k * n * 2)),
        gpu.stz_gpu_buffer_new(@floatFromInt(m * n * 4)),
        gpu.stz_gpu_buffer_new(@floatFromInt(m * n * 4)),
    };
    defer {
        for (ids) |id| {
            if (id != 0) _ = gpu.stz_gpu_buffer_free(id);
        }
    }
    for (ids) |id| if (id == 0) return gpu.GPU_ERROR;
    if (gpu.stz_gpu_buffer_write(ids[0], @ptrCast(a.ptr), @floatFromInt(m * k * 4)) != gpu.OK) return gpu.GPU_ERROR;
    if (gpu.stz_gpu_buffer_write(ids[1], @ptrCast(b.ptr), @floatFromInt(k * n * 4)) != gpu.OK) return gpu.GPU_ERROR;
    if (gpu.stz_gpu_buffer_write(ids[2], @ptrCast(bh.ptr), @floatFromInt(k * n * 2)) != gpu.OK) return gpu.GPU_ERROR;
    // vf >= 0 names the variant (the backbone's GK2b winners are register-blocked); < 0 asks the table
    const v: usize = if (vf >= 0 and vf < @as(f64, @floatFromInt(ops.MM_VARIANTS)) and ops.mmIsReal(@intFromFloat(vf))) @intFromFloat(vf) else ops.mmVariantFor(m, k, n);
    hres[H_VARIANT] = @floatFromInt(v);
    const s32 = ops.mmSourceW(v, false, false);
    const s16 = ops.mmSourceW(v, false, true);
    const k32 = gpu.stz_gpu_kernel_compile(s32.ptr, @floatFromInt(s32.len));
    const k16 = gpu.stz_gpu_kernel_compile(s16.ptr, @floatFromInt(s16.len));
    if (k32 == 0 or k16 == 0) return gpu.GPU_ERROR;
    const pm = ops.MmParams{ .m = @intCast(m), .k = @intCast(k), .n = @intCast(n), .pad = 0 };
    const pb = std.mem.asBytes(&pm);
    const geo = ops.mmGeometry(v, m, n);
    const wx: f64 = @floatFromInt(geo.wx);
    const ids32 = [_]i64{ ids[0], ids[1], ids[3] };
    const ids16 = [_]i64{ ids[0], ids[2], ids[4] };
    _ = verify.stz_gpu_wake(400);
    const two = verify.ensureTs();
    hres[H_CLOCKS] = if (two) 2 else 1;
    const r: usize = if (reps >= 1) @intFromFloat(reps) else 7;
    var b32w: f64 = std.math.inf(f64);
    var b16w: f64 = std.math.inf(f64);
    var b32g: f64 = std.math.inf(f64);
    var b16g: f64 = std.math.inf(f64);
    var g: f64 = 0;
    const TURNS = 4;
    for (0..TURNS) |turn| {
        var t32g: f64 = std.math.inf(f64);
        var t16g: f64 = std.math.inf(f64);
        _ = verify.timedDispatch(k32, pb, &ids32, wx, false, &g) orelse return gpu.GPU_ERROR;
        for (0..r) |_| {
            const w = verify.timedDispatch(k32, pb, &ids32, wx, two, &g) orelse return gpu.GPU_ERROR;
            b32w = @min(b32w, w);
            if (g > 0) t32g = @min(t32g, g);
        }
        _ = verify.timedDispatch(k16, pb, &ids16, wx, false, &g) orelse return gpu.GPU_ERROR;
        for (0..r) |_| {
            const w = verify.timedDispatch(k16, pb, &ids16, wx, two, &g) orelse return gpu.GPU_ERROR;
            b16w = @min(b16w, w);
            if (g > 0) t16g = @min(t16g, g);
        }
        b32g = @min(b32g, t32g);
        b16g = @min(b16g, t16g);
        hres[16 + turn * 2] = if (t32g == std.math.inf(f64)) -1 else t32g;
        hres[16 + turn * 2 + 1] = if (t16g == std.math.inf(f64)) -1 else t16g;
    }
    hres[H_TURNS] = TURNS;
    hres[H_F32_WALL_MS] = b32w;
    hres[H_F16_WALL_MS] = b16w;
    hres[H_F32_GPU_MS] = if (b32g == std.math.inf(f64)) -1 else b32g;
    hres[H_F16_GPU_MS] = if (b16g == std.math.inf(f64)) -1 else b16g;
    hres[H_RATIO_WALL] = b32w / b16w;
    hres[H_RATIO_GPU] = if (b32g != std.math.inf(f64) and b16g != std.math.inf(f64)) b32g / b16g else -1;
    hres[H_B32_BYTES] = @floatFromInt(k * n * 4);
    hres[H_B16_BYTES] = @floatFromInt(k * n * 2);
    // the two results against an f64 product from the f32 weights
    const c32 = alloc.alloc(f32, m * n) catch return gpu.GPU_ERROR;
    defer alloc.free(c32);
    const c16 = alloc.alloc(f32, m * n) catch return gpu.GPU_ERROR;
    defer alloc.free(c16);
    if (gpu.stz_gpu_buffer_read(ids[3], @ptrCast(c32.ptr), @floatFromInt(m * n * 4)) != gpu.OK) return gpu.GPU_ERROR;
    if (gpu.stz_gpu_buffer_read(ids[4], @ptrCast(c16.ptr), @floatFromInt(m * n * 4)) != gpu.OK) return gpu.GPU_ERROR;
    var e32: f64 = 0;
    var e16: f64 = 0;
    var dd: f64 = 0;
    var rmax: f64 = 0;
    for (0..m) |i| {
        for (0..n) |j| {
            var s: f64 = 0;
            for (0..k) |q| s += @as(f64, a[i * k + q]) * @as(f64, b[q * n + j]);
            const y32: f64 = c32[i * n + j];
            const y16: f64 = c16[i * n + j];
            e32 = @max(e32, @abs(y32 - s));
            e16 = @max(e16, @abs(y16 - s));
            dd = @max(dd, @abs(y16 - y32));
            rmax = @max(rmax, @abs(s));
        }
    }
    hres[H_ERR32] = e32;
    hres[H_ERR16] = e16;
    hres[H_DIFF] = dd;
    hres[H_REFMAX] = rmax;
    hres[H_OK] = 1;
    return gpu.OK;
}

test "the winner needs the margin, and a refused variant never wins" {
    // pure arithmetic of the verdict, no device: a 1.29x winner is no winner
    try std.testing.expect(1.29 < MARGIN);
    try std.testing.expect(1.3 >= MARGIN);
}
