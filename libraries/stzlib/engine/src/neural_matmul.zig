// R4 step 2 -- THE GGML BRIDGE (seed): stzMatrix matmul through ggml's
// threaded, SIMD kernel. (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md 5.3/5.9:
// stzMatrix and ggml tensors are both contiguous float arrays -- this is
// the feasible-and-strategic wire.)
//
// HOME: compiled into stz_matrix.dll (which links ggml since R4 step 2)
// -- the handle table in ring_api.zig is per-DLL static state, so the
// matmul must live where the matrix handles live (found the hard way:
// a cross-DLL registration resolved handles against the WRONG table).
//
// Precision note: ggml computes in f32; stzMatrix stores f64. The bridge
// narrows/widens at the edges -- fine for ML workloads (the consumer this
// bridge serves), documented for numeric-analysis ones.

const std = @import("std");
const matrix = @import("matrix.zig");

const c = @cImport({
    @cInclude("ggml.h");
    @cInclude("ggml-cpu.h");
});

const gpa = std.heap.c_allocator;

// ---------------------------------------------------------------- resident tensors
//
// The G6 census measured this bridge's per-call cost DOMINATING small
// shapes: a 1x384x1536 matvec spent 2.85 ms in context setup + f64->f32
// conversion + the element-by-element B-transpose, around ~0.02 ms of
// actual compute. The fix: converted tensors stay RESIDENT across calls,
// keyed by the source matrix pointer, so repeated multiplies against the
// same operands pay conversion once.
//
// INVALIDATION IS THE BRIDGE'S JOB: every Ring-visible mutation of a
// matrix flows through ring_bridge_matrix.zig (Set / AddScalar /
// MultiplyScalar / UpdateRegion / AddMatrix / Power / MulGgml's own
// result write / Free), and each of those calls noteMutation() here,
// which DROPS the pointer's entries. Free dropping entries also settles
// pointer-reuse (ABA): a recycled address starts with no cache. No
// version counters, no changes to matrix.zig -- the struct stays as the
// (concurrently active) matrix work knows it.
//
// The cache is BOUNDED (8 slots, LRU) and COUNTED (hits / misses /
// evictions / invalidations) -- the guard asserts the mechanism through
// the counters, and a bounded record counts what it drops.

const ROLE_A: u8 = 0; // A as rows (the tY layout below)
const ROLE_B: u8 = 1; // B transposed into columns (the tX layout below)

const CacheEntry = struct {
    key: usize = 0,
    role: u8 = 0,
    rows: usize = 0,
    cols: usize = 0,
    ctx: ?*c.ggml_context = null,
    tensor: ?*c.ggml_tensor = null,
    last_use: u64 = 0,
};

const CACHE_SLOTS = 8;
var cache: [CACHE_SLOTS]CacheEntry = [_]CacheEntry{.{}} ** CACHE_SLOTS;
var tick: u64 = 0;
var n_hits: f64 = 0;
var n_misses: f64 = 0;
var n_evictions: f64 = 0;
var n_invalidations: f64 = 0;

fn dropSlot(i: usize) void {
    if (cache[i].ctx) |cx| c.ggml_free(cx);
    cache[i] = .{};
}

/// Called by the Ring bridge on EVERY mutable access to a matrix (and on
/// free): the pointer's resident tensors are no longer the matrix's data.
pub fn noteMutation(m: ?*const matrix.StzMatrix) void {
    const ptr = @intFromPtr(m orelse return);
    for (0..CACHE_SLOTS) |i| {
        if (cache[i].tensor != null and cache[i].key == ptr) {
            dropSlot(i);
            n_invalidations += 1;
        }
    }
}

pub fn stz_neural_matmul_stats(out: [*]f64) callconv(.c) void {
    out[0] = n_hits;
    out[1] = n_misses;
    out[2] = n_evictions;
    out[3] = n_invalidations;
}

pub fn stz_neural_matmul_stats_reset() callconv(.c) void {
    n_hits = 0;
    n_misses = 0;
    n_evictions = 0;
    n_invalidations = 0;
}

/// The resident tensor for a matrix in a given role, converting (and for
/// ROLE_B transposing) ONLY on a miss. The layouts are byte-for-byte the
/// ones the original per-call code built -- bit-parity by construction.
fn residentTensor(m: *const matrix.StzMatrix, role: u8) ?*c.ggml_tensor {
    const ptr = @intFromPtr(m);
    tick += 1;
    for (0..CACHE_SLOTS) |i| {
        const e = &cache[i];
        if (e.tensor != null and e.key == ptr and e.role == role and
            e.rows == m.rows and e.cols == m.cols)
        {
            e.last_use = tick;
            n_hits += 1;
            return e.tensor;
        }
    }
    n_misses += 1;

    // pick a slot: an empty one, else the least recently used (counted)
    var slot: usize = 0;
    var best: u64 = std.math.maxInt(u64);
    for (0..CACHE_SLOTS) |i| {
        if (cache[i].tensor == null) {
            slot = i;
            best = 0;
            break;
        }
        if (cache[i].last_use < best) {
            best = cache[i].last_use;
            slot = i;
        }
    }
    if (cache[slot].tensor != null) {
        dropSlot(slot);
        n_evictions += 1;
    }

    const nelem = m.rows * m.cols;
    const mem_size: usize = nelem * @sizeOf(f32) + 256 * 1024;
    const ctx = c.ggml_init(.{ .mem_size = mem_size, .mem_buffer = null, .no_alloc = false }) orelse return null;

    var tensor: ?*c.ggml_tensor = null;
    if (role == ROLE_B) {
        // tX: (k, n) with each row j holding COLUMN j of B -- k = B.rows
        const k = m.rows;
        const n = m.cols;
        const t = c.ggml_new_tensor_2d(ctx, c.GGML_TYPE_F32, @intCast(k), @intCast(n)) orelse {
            c.ggml_free(ctx);
            return null;
        };
        const xd: [*]f32 = @ptrCast(@alignCast(t.*.data));
        for (0..n) |j| {
            for (0..k) |ti| {
                xd[j * k + ti] = @floatCast(m.data[ti * n + j]);
            }
        }
        tensor = t;
    } else {
        // tY: (k, m) = A's rows verbatim -- k = A.cols
        const t = c.ggml_new_tensor_2d(ctx, c.GGML_TYPE_F32, @intCast(m.cols), @intCast(m.rows)) orelse {
            c.ggml_free(ctx);
            return null;
        };
        const yd: [*]f32 = @ptrCast(@alignCast(t.*.data));
        for (0..nelem) |i| yd[i] = @floatCast(m.data[i]);
        tensor = t;
    }

    cache[slot] = .{
        .key = ptr,
        .role = role,
        .rows = m.rows,
        .cols = m.cols,
        .ctx = ctx,
        .tensor = tensor,
        .last_use = tick,
    };
    return tensor;
}

/// C = A(m x k) * B(k x n), computed by ggml. Returns 1 on success,
/// 0 on any dimension/context failure (caller falls back to the naive
/// path -- graceful degradation, never a crash).
pub fn stz_neural_matmul_into(
    pa: ?*const matrix.StzMatrix,
    pb: ?*const matrix.StzMatrix,
    pres: ?*matrix.StzMatrix,
) callconv(.c) i32 {
    const A = pa orelse return 0;
    const B = pb orelse return 0;
    const RES = pres orelse return 0;
    if (A.cols != B.rows) return 0;
    if (RES.rows != A.rows or RES.cols != B.cols) return 0;

    const m = A.rows;
    const n = B.cols;

    // ggml_mul_mat(X, Y): X.ne0 == Y.ne0 == the shared k; the result's
    // rows dot X's rows with Y's rows. Feeding X = B-transposed rows
    // (each row = a COLUMN of B) and Y = A's rows yields exactly
    // row-major C = A*B in the result buffer. The operand tensors are
    // RESIDENT (converted on first use, reused until the bridge notes a
    // mutation); only the result + graph live in this per-call context.
    const tX = residentTensor(B, ROLE_B) orelse return 0;
    const tY = residentTensor(A, ROLE_A) orelse return 0;

    const mem_size: usize = (m * n) * @sizeOf(f32) + 3 * 1024 * 1024;
    const ctx = c.ggml_init(.{ .mem_size = mem_size, .mem_buffer = null, .no_alloc = false }) orelse return 0;
    defer c.ggml_free(ctx);

    const res = c.ggml_mul_mat(ctx, tX, tY) orelse return 0;
    const graph = c.ggml_new_graph(ctx) orelse return 0;
    c.ggml_build_forward_expand(graph, res);

    var plan = c.ggml_graph_plan(graph, 4, null);
    var wbuf: ?[]u8 = null;
    if (plan.work_size > 0) {
        wbuf = gpa.alloc(u8, plan.work_size) catch return 0;
        plan.work_data = wbuf.?.ptr;
    }
    defer if (wbuf) |w| gpa.free(w);
    _ = c.ggml_graph_compute(graph, &plan);

    const rd: [*]const f32 = @ptrCast(@alignCast(res.*.data));
    for (0..m * n) |i| RES.data[i] = @floatCast(rd[i]);
    return 1;
}
