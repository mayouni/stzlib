//! GPU routing for the neural tier's forward pass -- the constructive route
//! the G6 decision recorded (SOFTANZA_GPU_PLAN.md): the matmul-shaped share
//! of the BERT-family graphs runs on the SHIPPED wgpu plane, no second GPU
//! stack, no SDK. This module compiles into stz_neural.dll and @imports
//! gpu.zig -- the lawful per-DLL pattern: its device, buffers and counters
//! are THIS DLL's own (handle ids never cross DLLs).
//!
//! The seam: ggml's own extra-compute hook. traits.cpp (vendored, patched --
//! see vendor/ggml/NOTICE) forwards big GGML_OP_MUL_MAT nodes here from
//! ggml_graph_compute; a claimed node skips ggml's CPU kernel entirely.
//!
//! The threading contract (ggml runs the hook on EVERY worker thread):
//!   - eligibility is SHAPE-DETERMINISTIC (dims/types/threshold only), so
//!     every thread reaches the same verdict with no shared-state race;
//!   - thread 0 computes; the others spin only while the ONE-TIME device
//!     init settles, then return immediately -- ggml's per-node barrier
//!     (ggml-cpu.c) holds them until thread 0's result is in place;
//!   - if the device dies MID-NODE after threads already returned "claimed",
//!     thread 0 keeps the promise with a scalar f32 fallback (correctness
//!     first, counted), and the state latches to failed -- every LATER node
//!     goes back to ggml's CPU kernels.
//!
//! Residency: weight tensors (F32/F16/Q8_0) are dequantized once, TRANSPOSED
//! once (ggml's mul_mat contracts over rows; the wgpu op wants k x n), and
//! kept resident keyed by (data pointer, model generation) -- a model reload
//! frees the lot. Activations stream through two reused buffers. Per call,
//! only the activation crosses in and the result crosses out.
//!
//! The gate: work = m*k*n against a settable threshold whose DEFAULT is set
//! by end-to-end measurement (see g_threshold below): per-node interception
//! only pays for multi-GFLOP nodes, so BERT-small/MiniLM class models stay
//! on ggml's CPU kernels BY MEASUREMENT, and the decode matvec -- G0's
//! killed 1-flop/byte shape -- stays CPU forever. The tiny parity fixture
//! (32-dim) never comes near it: bit-parity guards keep their CPU truth.

const std = @import("std");
const gpu = @import("gpu.zig");
const gpu_ops = @import("gpu_ops.zig");
const embed = @import("neural_embed.zig");

const c = @cImport({
    @cInclude("ggml.h");
});

const gpa = std.heap.c_allocator;

// ---------------------------------------------------------------- state

const ST_UNKNOWN: u8 = 0;
const ST_OK: u8 = 1;
const ST_FAILED: u8 = 2;
var g_state = std.atomic.Value(u8).init(ST_UNKNOWN);

var g_runtime_path: [512]u8 = @splat(0);
var g_runtime_path_len: usize = 0;

// work = m*k*n admission line; settable from Ring (calibration owns it).
//
// THE DEFAULT IS SET BY MEASUREMENT, AND IT IS DELIBERATELY HIGH. The first
// seed (16M, from the G6 census) admitted MiniLM's seq~130 shapes -- and the
// guard's end-to-end timing showed the GPU route at 0.45x: the census's
// 2.7-4.8x was measured on RESIDENT chains, but per-NODE interception pays
// an activation upload + a staged readback + a sync on every matmul while
// ggml's CPU ops interleave -- a graph that hops CPU<->GPU per node is not
// a resident chain (G0's transfer law, resurfacing at graph level). At
// ~300 GF/s device throughput against a ~10 ms per-node round-trip floor,
// a node breaks even near 3 GFLOP => work ~ 1.5e9 (bert-large at long
// sequence lengths). Everything smaller MEASURED slower and stays CPU.
// The full win at small-model scale needs the RESIDENT backbone (every op
// on-device, one upload, one readback) -- recorded as the follow-up.
var g_threshold: f64 = 1_500_000_000;

// counters beyond gpu.zig's own: how often the hook claimed / fell back scalar
var g_claimed: f64 = 0;
var g_scalar_fallbacks: f64 = 0;

// ---------------------------------------------------------------- weight cache

const WEIGHT_SLOTS = 160;
const WeightSlot = struct {
    ptr: usize = 0,
    id: i64 = 0,
    k: usize = 0,
    n: usize = 0,
};
var g_weights: [WEIGHT_SLOTS]WeightSlot = @splat(.{});
var g_weight_fifo: usize = 0;
var g_cache_gen: usize = std.math.maxInt(usize);

var g_act_id: i64 = 0;
var g_act_cap: usize = 0;
var g_res_id: i64 = 0;
var g_res_cap: usize = 0;

fn dropAllResidency() void {
    for (&g_weights) |*w| {
        if (w.ptr != 0) {
            _ = gpu.stz_gpu_buffer_free(w.id);
            w.* = .{};
        }
    }
    g_weight_fifo = 0;
    if (g_act_id != 0) {
        _ = gpu.stz_gpu_buffer_free(g_act_id);
        g_act_id = 0;
        g_act_cap = 0;
    }
    if (g_res_id != 0) {
        _ = gpu.stz_gpu_buffer_free(g_res_id);
        g_res_id = 0;
        g_res_cap = 0;
    }
}

// ---------------------------------------------------------------- Ring-facing knobs

pub export fn neural_gpu_set_runtime_path(path: [*c]const u8, len: usize) callconv(.c) void {
    const n = @min(len, g_runtime_path.len - 1);
    if (path != null and n > 0) {
        @memcpy(g_runtime_path[0..n], path[0..n]);
        g_runtime_path[n] = 0;
        g_runtime_path_len = n;
    }
}

pub export fn neural_gpu_set_threshold(work: f64) callconv(.c) void {
    if (work >= 1) g_threshold = work;
}

pub export fn neural_gpu_threshold() callconv(.c) f64 {
    return g_threshold;
}

// 0 = untried, 1 = live, 2 = failed/absent
pub export fn neural_gpu_state() callconv(.c) c_int {
    return @intCast(g_state.load(.acquire));
}

// which: 0 claimed-nodes, 1 scalar-fallbacks, 2.. -> gpu.zig counter (which-2)
pub export fn neural_gpu_counter(which: c_int) callconv(.c) f64 {
    return switch (which) {
        0 => g_claimed,
        1 => g_scalar_fallbacks,
        else => gpu.stz_gpu_counter(which - 2),
    };
}

pub export fn neural_gpu_counters_reset() callconv(.c) void {
    g_claimed = 0;
    g_scalar_fallbacks = 0;
    gpu.stz_gpu_counters_reset();
}

// ---------------------------------------------------------------- eligibility

fn shapeEligible(op: *c.ggml_tensor) bool {
    if (g_state.load(.acquire) == ST_FAILED) return false;
    const w = op.src[0];
    const x = op.src[1];
    if (w == null or x == null) return false;
    // 2D weight x 2D activation -> 2D f32 result, all contiguous
    if (w.*.ne[2] != 1 or w.*.ne[3] != 1 or x.*.ne[2] != 1 or x.*.ne[3] != 1) return false;
    if (op.type != c.GGML_TYPE_F32 or x.*.type != c.GGML_TYPE_F32) return false;
    if (w.*.type != c.GGML_TYPE_F32 and w.*.type != c.GGML_TYPE_F16 and
        w.*.type != c.GGML_TYPE_Q8_0) return false;
    if (c.ggml_is_contiguous(x) == false or c.ggml_is_contiguous(op) == false or
        c.ggml_is_contiguous(w) == false) return false;
    const k: f64 = @floatFromInt(w.*.ne[0]);
    const n: f64 = @floatFromInt(w.*.ne[1]);
    const m: f64 = @floatFromInt(x.*.ne[1]);
    if (x.*.ne[0] != w.*.ne[0]) return false;
    return m * k * n >= g_threshold;
}

// ---------------------------------------------------------------- device

/// Shared with the resident backbone: BOTH GPU paths in this DLL must come
/// up through the same one-time init (this module owns the runtime path).
pub fn ensureDevicePub() bool {
    return ensureDevice() == ST_OK;
}

fn ensureDevice() u8 {
    const cur = g_state.load(.acquire);
    if (cur != ST_UNKNOWN) return cur;
    var st: u8 = ST_FAILED;
    if (g_runtime_path_len > 0) {
        const z: [*:0]const u8 = @ptrCast(&g_runtime_path[0]);
        if (gpu.stz_gpu_init(z) == 1) st = ST_OK;
    }
    g_state.store(st, .release);
    return st;
}

// ---------------------------------------------------------------- weights

fn dequantRows(w: *c.ggml_tensor, out: []f32, k: usize, n: usize) bool {
    const traits = c.ggml_get_type_traits(w.*.type);
    if (w.*.type == c.GGML_TYPE_F32) {
        const src: [*]const f32 = @ptrCast(@alignCast(w.*.data));
        @memcpy(out[0 .. k * n], src[0 .. k * n]);
        return true;
    }
    const to_float = traits.*.to_float orelse return false;
    const base: [*]const u8 = @ptrCast(w.*.data);
    for (0..n) |row| {
        to_float(base + row * w.*.nb[1], out.ptr + row * k, @intCast(k));
    }
    return true;
}

/// The resident, TRANSPOSED (k x n) f32 copy of a weight tensor; uploads on
/// first sight, then serves from VRAM. 0 on any failure.
fn residentWeight(w: *c.ggml_tensor) i64 {
    if (g_cache_gen != embed.model_generation) {
        dropAllResidency();
        g_cache_gen = embed.model_generation;
    }
    const key = @intFromPtr(w.*.data);
    const k: usize = @intCast(w.*.ne[0]);
    const n: usize = @intCast(w.*.ne[1]);
    for (&g_weights) |*slot| {
        if (slot.ptr == key and slot.k == k and slot.n == n) return slot.id;
    }
    // dequant [n][k] then transpose to [k][n]
    const rows = gpa.alloc(f32, k * n) catch return 0;
    defer gpa.free(rows);
    if (!dequantRows(w, rows, k, n)) return 0;
    const t = gpa.alloc(f32, k * n) catch return 0;
    defer gpa.free(t);
    for (0..n) |row| {
        for (0..k) |col| t[col * n + row] = rows[row * k + col];
    }
    const id = gpu.stz_gpu_buffer_new(@floatFromInt(k * n * 4));
    if (id == 0) return 0;
    if (gpu.stz_gpu_buffer_write(id, @ptrCast(t.ptr), @floatFromInt(k * n * 4)) != gpu.OK) {
        _ = gpu.stz_gpu_buffer_free(id);
        return 0;
    }
    const slot = &g_weights[g_weight_fifo % WEIGHT_SLOTS];
    if (slot.ptr != 0) _ = gpu.stz_gpu_buffer_free(slot.id);
    slot.* = .{ .ptr = key, .id = id, .k = k, .n = n };
    g_weight_fifo += 1;
    return id;
}

fn ensureScratch(id: *i64, cap: *usize, need: usize) bool {
    if (id.* != 0 and cap.* >= need) return true;
    if (id.* != 0) _ = gpu.stz_gpu_buffer_free(id.*);
    id.* = gpu.stz_gpu_buffer_new(@floatFromInt(need));
    cap.* = if (id.* != 0) need else 0;
    return id.* != 0;
}

// ---------------------------------------------------------------- the fallback

// The promise-keeper: threads already skipped this node, the GPU just died --
// compute it here, scalar f32, from a fresh dequant. Slow once, never wrong.
fn scalarMatmul(op: *c.ggml_tensor) void {
    const w = op.src[0];
    const x = op.src[1];
    const k: usize = @intCast(w.*.ne[0]);
    const n: usize = @intCast(w.*.ne[1]);
    const m: usize = @intCast(x.*.ne[1]);
    const rows = gpa.alloc(f32, k * n) catch return;
    defer gpa.free(rows);
    if (!dequantRows(w, rows, k, n)) return;
    const xd: [*]const f32 = @ptrCast(@alignCast(x.*.data));
    const rd: [*]f32 = @ptrCast(@alignCast(op.data));
    for (0..m) |i| {
        for (0..n) |j| {
            var acc: f32 = 0;
            for (0..k) |t| acc += xd[i * k + t] * rows[j * k + t];
            rd[i * n + j] = acc;
        }
    }
}

// ---------------------------------------------------------------- the hook

/// Called from vendored traits.cpp for every MUL_MAT node, on every worker
/// thread. Returns 1 iff this node is (being) computed here.
pub export fn stz_neural_gpu_try_mul_mat(ith: c_int, op_raw: ?*anyopaque) callconv(.c) c_int {
    const op: *c.ggml_tensor = @ptrCast(@alignCast(op_raw orelse return 0));
    if (!shapeEligible(op)) return 0;

    if (ith != 0) {
        // same shape verdict as thread 0; wait only for the one-time init
        while (g_state.load(.acquire) == ST_UNKNOWN) std.atomic.spinLoopHint();
        return if (g_state.load(.acquire) == ST_OK) 1 else 0;
    }

    if (ensureDevice() != ST_OK) return 0;

    const w = op.src[0];
    const x = op.src[1];
    const k: usize = @intCast(w.*.ne[0]);
    const n: usize = @intCast(w.*.ne[1]);
    const m: usize = @intCast(x.*.ne[1]);

    var ok = true;
    const wid = residentWeight(w);
    if (wid == 0) ok = false;
    if (ok) ok = ensureScratch(&g_act_id, &g_act_cap, m * k * 4);
    if (ok) ok = ensureScratch(&g_res_id, &g_res_cap, m * n * 4);
    if (ok) ok = gpu.stz_gpu_buffer_write(g_act_id, @ptrCast(x.*.data), @floatFromInt(m * k * 4)) == gpu.OK;
    if (ok) ok = gpu_ops.stz_gpu_op_matmul(g_act_id, wid, g_res_id, @floatFromInt(m), @floatFromInt(k), @floatFromInt(n)) == gpu.OK;
    if (ok) ok = gpu.stz_gpu_buffer_read(g_res_id, @ptrCast(op.data), @floatFromInt(m * n * 4)) == gpu.OK;

    if (!ok) {
        // keep the promise scalar-side; stop volunteering for later nodes
        g_state.store(ST_FAILED, .release);
        scalarMatmul(op);
        g_scalar_fallbacks += 1;
        return 1;
    }
    g_claimed += 1;
    return 1;
}
