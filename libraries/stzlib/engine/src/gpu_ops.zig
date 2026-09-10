//! The G2 op library -- the catalog G0's kill criteria approved, built on the
//! G1 lifecycle layer (SOFTANZA_GPU_PLAN.md).
//!
//! Ops take G1 BUFFER IDS, not host arrays: the residency law. A caller
//! uploads once, chains ops (each is submit-only, no waits), and reads back
//! once. Scalars (sum/dot) are the exception -- a reduction's answer lives on
//! the CPU by definition, so those ops read back their partials.
//!
//! Kernel sourcing: every op's WGSL is a comptime constant compiled through
//! the G1 compile-cache (stz_gpu_kernel_compile). The per-call cost of the
//! cache lookup is a text hash (sub-microsecond against a 60 us dispatch
//! floor), and it makes ops self-healing across device re-init: a Shutdown /
//! SelectAdapter clears the pipeline cache, and the next op call simply
//! recompiles. No epoch bookkeeping.
//!
//! Binding contract (the ops family, via stz_gpu_dispatch_params):
//!   @binding(0) tile uniform (G1-owned; xoff in workgroups along x)
//!   @binding(1) op params uniform (this layer; <= 64 bytes)
//!   @binding(2..) data buffers, in call order
//!
//! Reduction shape: one dispatch produces per-workgroup partials (shared-mem
//! tree, 256 lanes), partials read back and folded in f64 on the CPU. The
//! fold order is fixed (ascending), so for integer-valued inputs the result
//! is EXACT -- the parity guard exploits that. For general data the
//! GPU-vs-CPU difference is f32 accumulation order; the guard's tolerance
//! bands are SET FROM MEASUREMENT, per the plan.
//!
//! Aliasing rule: an op's OUT buffer must be distinct from its inputs
//! (WebGPU usage-scope validation rejects read|read_write aliasing in one
//! bind group). In-place mutation is offered only where the kernel is
//! WRITTEN in-place (ScaleInPlace, and softmax's internal passes).

const std = @import("std");
const gpu = @import("gpu.zig");

const alloc = std.heap.c_allocator;

const WG = 256; // elementwise/reduction workgroup width
const TILE = 16; // matmul/pairdist tile edge

// ---------------------------------------------------------------- helpers

/// Every op's first gate: no device means FALLBACK, counted here -- the
/// layer that refuses is the layer that counts (before any buffer checks,
/// so a dead device answers FALLBACK, not STALE-because-ids-died-with-it).
fn gateAvailable() i32 {
    if (gpu.stz_gpu_is_available() == 0) {
        gpu.countFallback();
        return gpu.FALLBACK;
    }
    return gpu.OK;
}

/// Validate a buffer id can hold `n` f32 elements. OK / STALE / BAD_ARG.
fn checkBuf(id: i64, n: usize) i32 {
    const sz = gpu.stz_gpu_buffer_size(id);
    if (sz < 0) return gpu.STALE;
    if (@as(f64, @floatFromInt(n * 4)) > sz) return gpu.BAD_ARG;
    return gpu.OK;
}

fn ceilDiv(a: usize, b: usize) usize {
    return (a + b - 1) / b;
}

fn compile(text: []const u8) i64 {
    return gpu.stz_gpu_kernel_compile(text.ptr, @floatFromInt(text.len));
}

fn dispatchP(kernel: i64, params: anytype, bufs: []const i64, wx: usize, wy: usize) i32 {
    const bytes = std.mem.asBytes(params);
    return gpu.stz_gpu_dispatch_params(
        kernel,
        bytes.ptr,
        @floatFromInt(bytes.len),
        bufs.ptr,
        @intCast(bufs.len),
        @floatFromInt(wx),
        @floatFromInt(wy),
    );
}

// the shared preamble every ops kernel starts with
const PRELUDE =
    \\struct StzTile { xoff : u32, p0 : u32, p1 : u32, p2 : u32 }
    \\@group(0) @binding(0) var<uniform> tile : StzTile;
    \\
;

// ---------------------------------------------------------------- elementwise

const EwParams = extern struct { n: u32, pad: u32, alpha: f32, beta: f32 };

const WGSL_AXPBY = PRELUDE ++
    \\struct P { n : u32, pad : u32, alpha : f32, beta : f32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> a : array<f32>;
    \\@group(0) @binding(3) var<storage, read> b : array<f32>;
    \\@group(0) @binding(4) var<storage, read_write> outv : array<f32>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
    \\  let i = gid.x + tile.xoff * 256u;
    \\  if (i < p.n) { outv[i] = p.alpha * a[i] + p.beta * b[i]; }
    \\}
;

const WGSL_MUL = PRELUDE ++
    \\struct P { n : u32, pad : u32, alpha : f32, beta : f32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> a : array<f32>;
    \\@group(0) @binding(3) var<storage, read> b : array<f32>;
    \\@group(0) @binding(4) var<storage, read_write> outv : array<f32>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
    \\  let i = gid.x + tile.xoff * 256u;
    \\  if (i < p.n) { outv[i] = a[i] * b[i]; }
    \\}
;

const WGSL_SCALE_INPLACE = PRELUDE ++
    \\struct P { n : u32, pad : u32, alpha : f32, beta : f32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read_write> v : array<f32>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
    \\  let i = gid.x + tile.xoff * 256u;
    \\  if (i < p.n) { v[i] = v[i] * p.alpha; }
    \\}
;

/// out = alpha*a + beta*b, elementwise over n f32s. out must be distinct.
pub fn stz_gpu_op_axpby(alpha: f64, a: i64, beta: f64, b: i64, out: i64, nf: f64) callconv(.c) i32 {
    const gate = gateAvailable();
    if (gate != gpu.OK) return gate;
    const n: usize = @intFromFloat(nf);
    if (n == 0) return gpu.BAD_ARG;
    for ([_]i64{ a, b, out }) |id| {
        const st = checkBuf(id, n);
        if (st != gpu.OK) return st;
    }
    const kern = compile(WGSL_AXPBY);
    if (kern == 0) return if (gpu.stz_gpu_is_available() == 0) gpu.FALLBACK else gpu.GPU_ERROR;
    const p = EwParams{ .n = @intCast(n), .pad = 0, .alpha = @floatCast(alpha), .beta = @floatCast(beta) };
    return dispatchP(kern, &p, &.{ a, b, out }, ceilDiv(n, WG), 1);
}

/// out = a .* b (Hadamard), elementwise over n f32s. out must be distinct.
pub fn stz_gpu_op_mul(a: i64, b: i64, out: i64, nf: f64) callconv(.c) i32 {
    const gate = gateAvailable();
    if (gate != gpu.OK) return gate;
    const n: usize = @intFromFloat(nf);
    if (n == 0) return gpu.BAD_ARG;
    for ([_]i64{ a, b, out }) |id| {
        const st = checkBuf(id, n);
        if (st != gpu.OK) return st;
    }
    const kern = compile(WGSL_MUL);
    if (kern == 0) return if (gpu.stz_gpu_is_available() == 0) gpu.FALLBACK else gpu.GPU_ERROR;
    const p = EwParams{ .n = @intCast(n), .pad = 0, .alpha = 0, .beta = 0 };
    return dispatchP(kern, &p, &.{ a, b, out }, ceilDiv(n, WG), 1);
}

/// v *= alpha, in place over n f32s.
pub fn stz_gpu_op_scale_inplace(v: i64, alpha: f64, nf: f64) callconv(.c) i32 {
    const gate = gateAvailable();
    if (gate != gpu.OK) return gate;
    const n: usize = @intFromFloat(nf);
    if (n == 0) return gpu.BAD_ARG;
    const st = checkBuf(v, n);
    if (st != gpu.OK) return st;
    const kern = compile(WGSL_SCALE_INPLACE);
    if (kern == 0) return if (gpu.stz_gpu_is_available() == 0) gpu.FALLBACK else gpu.GPU_ERROR;
    const p = EwParams{ .n = @intCast(n), .pad = 0, .alpha = @floatCast(alpha), .beta = 0 };
    return dispatchP(kern, &p, &.{v}, ceilDiv(n, WG), 1);
}

// ---------------------------------------------------------------- matmul

pub const MmParams = extern struct { m: u32, k: u32, n: u32, pad: u32 };

// ---- the matmul variants (GK2b's matmul leg, under GK0's checker) ----
//
// C(m x n) = A(m x k) * B(k x n), row-major f32. Every variant maps ONE
// LINEAR workgroup index to an output tile (tile row = id / tiles_x, tile
// col = id % tiles_x), so the checker -- which dispatches (wx, 1) -- can
// judge every one of them at every shape, and the op dispatches them the
// same way. The generic is the G0 spike kernel (16x16 threads, one output
// each, 16-wide K steps through workgroup memory). The variants:
//
//   TILE8   8x8 threads, one output each -- more, smaller workgroups for
//           the backbone's short token counts
//   REG2    16x16 threads, each a 2x2 block: a 32x32 output tile, every
//           staged value used twice as often
//   REG4    16x16 threads, each a 4x4 block: a 64x64 tile, sixteen
//           accumulators per thread -- the classic register-blocked form
//   BROKEN  REG2 with one element wrong: the checker's negative sibling,
//           reachable only through the foundry's mask
//
// `mmSource(v, bias)` generates the text, with or without a fused bias
// (the backbone's projections carry one), so the backbone can compile the
// SAME winner the table names for its shape and the foundry judged.

pub const MM_GENERIC: usize = 0;
pub const MM_TILE8: usize = 1;
pub const MM_REG2: usize = 2;
pub const MM_REG4: usize = 3;
pub const MM_BROKEN: usize = 4; // test only
pub const MM_REAL: usize = 4;
pub const MM_VARIANTS: usize = 5;
pub const mm_variant_names = [_][]const u8{ "tile16", "tile8", "reg2", "reg4", "broken" };

fn mmHead(comptime bias: bool) []const u8 {
    return PRELUDE ++
        \\struct P { m : u32, k : u32, n : u32, has_bias : u32 }
        \\@group(0) @binding(1) var<uniform> p : P;
        \\@group(0) @binding(2) var<storage, read> a : array<f32>;
        \\@group(0) @binding(3) var<storage, read> b : array<f32>;
        \\
    ++ (if (bias)
        \\@group(0) @binding(4) var<storage, read> bias : array<f32>;
        \\@group(0) @binding(5) var<storage, read_write> cc : array<f32>;
        \\
    else
        \\@group(0) @binding(4) var<storage, read_write> cc : array<f32>;
        \\
    );
}

fn mmStore(comptime bias: bool) []const u8 {
    // the store of one output: (r, c, v) already in scope
    return if (bias)
        \\      if (p.has_bias == 1u) { v = v + bias[c]; }
        \\      cc[r * p.n + c] = v;
        \\
    else
        \\      cc[r * p.n + c] = v;
        \\
    ;
}

/// One-output-per-thread tile of edge E (16 = the generic, 8 = TILE8).
fn mmTileSource(comptime edge: u32, comptime bias: bool) []const u8 {
    const es = std.fmt.comptimePrint("{d}", .{edge});
    const es2 = std.fmt.comptimePrint("{d}", .{edge * edge});
    return mmHead(bias) ++
        "var<workgroup> ta : array<f32, " ++ es2 ++ ">;\n" ++
        "var<workgroup> tb : array<f32, " ++ es2 ++ ">;\n" ++
        "@compute @workgroup_size(" ++ es ++ ", " ++ es ++ ")\n" ++
        \\fn main(@builtin(workgroup_id) wid : vec3<u32>, @builtin(local_invocation_id) lid : vec3<u32>) {
        \\  let E =
    ++ es ++ "u;\n" ++
        \\  let id = wid.x + tile.xoff;
        \\  let tiles_x = (p.n + E - 1u) / E;
        \\  let row = (id / tiles_x) * E + lid.y;
        \\  let col = (id % tiles_x) * E + lid.x;
        \\  var acc = 0.0;
        \\  let steps = (p.k + E - 1u) / E;
        \\  for (var t = 0u; t < steps; t = t + 1u) {
        \\    let k0 = t * E;
        \\    let acol = k0 + lid.x;
        \\    let brow = k0 + lid.y;
        \\    ta[lid.y * E + lid.x] = select(0.0, a[row * p.k + acol], row < p.m && acol < p.k);
        \\    tb[lid.y * E + lid.x] = select(0.0, b[brow * p.n + col], brow < p.k && col < p.n);
        \\    workgroupBarrier();
        \\    for (var kk = 0u; kk < E; kk = kk + 1u) {
        \\      acc = acc + ta[lid.y * E + kk] * tb[kk * E + lid.x];
        \\    }
        \\    workgroupBarrier();
        \\  }
        \\  if (row < p.m && col < p.n) {
        \\    let r = row; let c = col; var v = acc;
        \\
    ++ mmStore(bias) ++
        \\  }
        \\}
    ;
}

/// Register-blocked: 16x16 threads, each an RxR block of outputs (R = 2 or
/// 4), a (16R)x(16R) tile, 16-wide K steps. FULLY UNROLLED at comptime: a
/// private array indexed by a loop variable lands in local memory, not
/// registers, and the first draft of this kernel measured 0.1x for exactly
/// that reason. Every accumulator, staged value and store is a named scalar.
fn mmRegSource(comptime R: u32, comptime bias: bool, comptime broken: bool) []const u8 {
    const ts = std.fmt.comptimePrint("{d}", .{16 * R});
    const shs = std.fmt.comptimePrint("{d}", .{16 * R * 16});
    comptime var decl: []const u8 = "";
    comptime var stage: []const u8 = "";
    comptime var loads: []const u8 = "";
    comptime var fma: []const u8 = "";
    comptime var store: []const u8 = "";
    inline for (0..R) |i| {
        inline for (0..R) |j| {
            decl = decl ++ std.fmt.comptimePrint("  var acc{d}{d} = 0.0;\n", .{ i, j });
            fma = fma ++ std.fmt.comptimePrint("      acc{d}{d} = acc{d}{d} + av{d} * bv{d};\n", .{ i, j, i, j, i, j });
            store = store ++ std.fmt.comptimePrint(
                \\  {{
                \\    let r = row0 + lid.y * {d}u + {d}u;
                \\    let c = col0 + lid.x * {d}u + {d}u;
                \\    var v = acc{d}{d};
                \\
            , .{ R, i, R, j, i, j }) ++
                (if (broken and i == 1 and j == 1)
                \\    if (r == 1u && c == 1u) { v = v + 1.0; }
                \\
            else
                "") ++
                "    if (r < p.m && c < p.n) {\n" ++ mmStore(bias) ++ "    }\n  }\n";
        }
        stage = stage ++ std.fmt.comptimePrint(
            \\    {{
            \\      let ar = row0 + lid.y * {d}u + {d}u;
            \\      let ac = k0 + lid.x;
            \\      ta[(lid.y * {d}u + {d}u) * 16u + lid.x] = select(0.0, a[ar * p.k + ac], ar < p.m && ac < p.k);
            \\      let br = k0 + lid.y;
            \\      let bc = col0 + lid.x * {d}u + {d}u;
            \\      tb[lid.y * {d}u + lid.x * {d}u + {d}u] = select(0.0, b[br * p.n + bc], br < p.k && bc < p.n);
            \\    }}
            \\
        , .{ R, i, R, i, R, i, 16 * R, R, i });
        loads = loads ++ std.fmt.comptimePrint("      let av{d} = ta[(lid.y * {d}u + {d}u) * 16u + kk];\n      let bv{d} = tb[kk * {d}u + lid.x * {d}u + {d}u];\n", .{ i, R, i, i, 16 * R, R, i });
    }
    return mmHead(bias) ++
        "var<workgroup> ta : array<f32, " ++ shs ++ ">;\n" ++
        "var<workgroup> tb : array<f32, " ++ shs ++ ">;\n" ++
        \\@compute @workgroup_size(16, 16)
        \\fn main(@builtin(workgroup_id) wid : vec3<u32>, @builtin(local_invocation_id) lid : vec3<u32>) {
        \\  let T =
    ++ ts ++ "u;\n" ++
        \\  let id = wid.x + tile.xoff;
        \\  let tiles_x = (p.n + T - 1u) / T;
        \\  let row0 = (id / tiles_x) * T;
        \\  let col0 = (id % tiles_x) * T;
        \\
    ++ decl ++
        \\  let steps = (p.k + 15u) / 16u;
        \\  for (var t = 0u; t < steps; t = t + 1u) {
        \\    let k0 = t * 16u;
        \\
    ++ stage ++
        \\    workgroupBarrier();
        \\    for (var kk = 0u; kk < 16u; kk = kk + 1u) {
        \\
    ++ loads ++ fma ++
        \\    }
        \\    workgroupBarrier();
        \\  }
        \\
    ++ store ++
        \\}
    ;
}

/// The kernel text of variant v, with or without a fused bias. Public so the
/// backbone compiles the table's winner in its own (bias) shape.
pub fn mmSource(v: usize, comptime bias: bool) []const u8 {
    return switch (v) {
        MM_TILE8 => comptime mmTileSource(8, bias),
        MM_REG2 => comptime mmRegSource(2, bias, false),
        MM_REG4 => comptime mmRegSource(4, bias, false),
        MM_BROKEN => comptime mmRegSource(2, bias, true),
        else => comptime mmTileSource(16, bias),
    };
}

pub fn mmVariantEligible(v: usize, m: usize, k: usize, n: usize) bool {
    _ = m;
    _ = k;
    _ = n;
    return v < MM_VARIANTS; // every variant bounds-checks; any shape
}

pub fn mmKernelFor(v: usize) i64 {
    return compile(mmSource(v, false));
}

/// Tiles on the linear grid every matmul variant reads: wy is always 1.
pub fn mmGeometry(v: usize, m: usize, n: usize) Geometry {
    const edge: usize = switch (v) {
        MM_TILE8 => 8,
        MM_REG2, MM_BROKEN => 32,
        MM_REG4 => 64,
        else => 16,
    };
    return .{ .wx = ceilDiv(n, edge) * ceilDiv(m, edge), .wy = 1 };
}

/// The table's choice for (m, n, k), degraded to an eligible variant.
pub fn mmVariantFor(m: usize, k: usize, n: usize) usize {
    const want: usize = @intFromFloat(stz_gpu_variant_get("matmul", 6, @floatFromInt(m), @floatFromInt(n), @floatFromInt(k)));
    var v = if (want < MM_REAL) want else MM_GENERIC;
    while (v > MM_GENERIC and !mmVariantEligible(v, m, k, n)) v -= 1;
    return v;
}

pub fn stz_gpu_mm_variant_name(v: f64, out: [*]u8, cap: f64) callconv(.c) i32 {
    const i: usize = @intFromFloat(@max(v, 0));
    if (i >= MM_VARIANTS) return 0;
    const nm = mm_variant_names[i];
    const c: usize = @intFromFloat(cap);
    if (nm.len > c) return 0;
    @memcpy(out[0..nm.len], nm);
    return @intCast(nm.len);
}

/// C(m x n) = A(m x k) * B(k x n), all row-major f32 -- by the variant the
/// table names for the shape class (the generic when it names none).
pub fn stz_gpu_op_matmul(a: i64, b: i64, cbuf: i64, mf: f64, kf: f64, nf: f64) callconv(.c) i32 {
    const gate = gateAvailable();
    if (gate != gpu.OK) return gate;
    const m: usize = @intFromFloat(mf);
    const k: usize = @intFromFloat(kf);
    const n: usize = @intFromFloat(nf);
    if (m == 0 or k == 0 or n == 0) return gpu.BAD_ARG;
    var st = checkBuf(a, m * k);
    if (st != gpu.OK) return st;
    st = checkBuf(b, k * n);
    if (st != gpu.OK) return st;
    st = checkBuf(cbuf, m * n);
    if (st != gpu.OK) return st;
    const v = mmVariantFor(m, k, n);
    const kern = mmKernelFor(v);
    if (kern == 0) return if (gpu.stz_gpu_is_available() == 0) gpu.FALLBACK else gpu.GPU_ERROR;
    if (v != MM_GENERIC) gpu.bumpCounter(gpu.CTR_VARIANT_DISPATCH, 1);
    const p = MmParams{ .m = @intCast(m), .k = @intCast(k), .n = @intCast(n), .pad = 0 };
    const g = mmGeometry(v, m, n);
    return dispatchP(kern, &p, &.{ a, b, cbuf }, g.wx, g.wy);
}

// ---------------------------------------------------------------- pairwise distance

pub const PdParams = extern struct { m: u32, n: u32, d: u32, pad: u32 };

// Squared L2 between every row of A (m x d) and every row of B (n x d):
// D[i][j] = sum_k (A[i][k] - B[j][k])^2. The embedding kernel -- knn/ann
// rank on squared distance, so no sqrt here (monotone, and exact for the
// integer witnesses).
const WGSL_PAIRDIST = PRELUDE ++
    \\struct P { m : u32, n : u32, d : u32, pad : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> a : array<f32>;
    \\@group(0) @binding(3) var<storage, read> b : array<f32>;
    \\@group(0) @binding(4) var<storage, read_write> dist : array<f32>;
    \\var<workgroup> ta : array<f32, 256>;
    \\var<workgroup> tb : array<f32, 256>;
    \\@compute @workgroup_size(16, 16)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>,
    \\        @builtin(local_invocation_id) lid : vec3<u32>,
    \\        @builtin(workgroup_id) wid : vec3<u32>) {
    \\  let row = gid.y;
    \\  let col = gid.x + tile.xoff * 16u;
    \\  let rowBase = wid.y * 16u;
    \\  let colBase = (wid.x + tile.xoff) * 16u;
    \\  var acc = 0.0;
    \\  let tiles = (p.d + 15u) / 16u;
    \\  for (var t = 0u; t < tiles; t = t + 1u) {
    \\    let k0 = t * 16u;
    \\    let ar = rowBase + lid.y;
    \\    let br = colBase + lid.y;
    \\    let kc = k0 + lid.x;
    \\    ta[lid.y * 16u + lid.x] = select(0.0, a[ar * p.d + kc], ar < p.m && kc < p.d);
    \\    tb[lid.y * 16u + lid.x] = select(0.0, b[br * p.d + kc], br < p.n && kc < p.d);
    \\    workgroupBarrier();
    \\    let kmax = min(16u, p.d - k0);
    \\    for (var kk = 0u; kk < kmax; kk = kk + 1u) {
    \\      let diff = ta[lid.y * 16u + kk] - tb[lid.x * 16u + kk];
    \\      acc = acc + diff * diff;
    \\    }
    \\    workgroupBarrier();
    \\  }
    \\  if (row < p.m && col < p.n) { dist[row * p.n + col] = acc; }
    \\}
;

// ---------------------------------------------------------------- pairdist VARIANTS (GK2)
//
// The tile kernel above is written for m x n. A SINGLE query (m = 1) -- the
// shape every seam dispatches -- drives one row of its sixteen, and GS4
// measured the cost: 24 MB read in 2.5 ms where the bus allows 0.3. These
// are the variants the foundry (gpu_foundry.zig) enumerates under GK0's
// checker; the op picks one per SHAPE CLASS from the table below, and a
// class nobody measured keeps the generic.
//
//   row   -- one thread per corpus row, a straight loop over d
//   row4  -- the same over vec4 (d % 4 == 0)
//   row4s -- row4 with the query rows staged in workgroup memory
//            (m * d/4 <= 1024 vec4)
//   broken -- TEST ONLY: row with a wrong answer, reachable through the
//            foundry's mask alone, never through the table -- the guard's
//            proof that the checker gates the table

const WGSL_PAIRDIST_ROW = PRELUDE ++
    \\struct P { m : u32, n : u32, d : u32, pad : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> a : array<f32>;
    \\@group(0) @binding(3) var<storage, read> b : array<f32>;
    \\@group(0) @binding(4) var<storage, read_write> dist : array<f32>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
    \\  let j = gid.x + tile.xoff * 256u;
    \\  if (j >= p.n) { return; }
    \\  let bo = j * p.d;
    \\  for (var i = 0u; i < p.m; i = i + 1u) {
    \\    let ao = i * p.d;
    \\    var acc = 0.0;
    \\    for (var k = 0u; k < p.d; k = k + 1u) {
    \\      let diff = a[ao + k] - b[bo + k];
    \\      acc = acc + diff * diff;
    \\    }
    \\    dist[i * p.n + j] = acc;
    \\  }
    \\}
;

const WGSL_PAIRDIST_ROW4 = PRELUDE ++
    \\struct P { m : u32, n : u32, d : u32, pad : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> a4 : array<vec4<f32>>;
    \\@group(0) @binding(3) var<storage, read> b4 : array<vec4<f32>>;
    \\@group(0) @binding(4) var<storage, read_write> dist : array<f32>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
    \\  let j = gid.x + tile.xoff * 256u;
    \\  if (j >= p.n) { return; }
    \\  let d4 = p.d / 4u;
    \\  let bo = j * d4;
    \\  for (var i = 0u; i < p.m; i = i + 1u) {
    \\    let ao = i * d4;
    \\    var acc = 0.0;
    \\    for (var k = 0u; k < d4; k = k + 1u) {
    \\      let dv = a4[ao + k] - b4[bo + k];
    \\      acc = acc + dot(dv, dv);
    \\    }
    \\    dist[i * p.n + j] = acc;
    \\  }
    \\}
;

const WGSL_PAIRDIST_ROW4S = PRELUDE ++
    \\struct P { m : u32, n : u32, d : u32, pad : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> a4 : array<vec4<f32>>;
    \\@group(0) @binding(3) var<storage, read> b4 : array<vec4<f32>>;
    \\@group(0) @binding(4) var<storage, read_write> dist : array<f32>;
    \\var<workgroup> qa : array<vec4<f32>, 1024>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>,
    \\        @builtin(local_invocation_id) lid : vec3<u32>) {
    \\  let d4 = p.d / 4u;
    \\  let total = p.m * d4;
    \\  for (var t = lid.x; t < total; t = t + 256u) { qa[t] = a4[t]; }
    \\  workgroupBarrier();
    \\  let j = gid.x + tile.xoff * 256u;
    \\  if (j < p.n) {
    \\    let bo = j * d4;
    \\    for (var i = 0u; i < p.m; i = i + 1u) {
    \\      let ao = i * d4;
    \\      var acc = 0.0;
    \\      for (var k = 0u; k < d4; k = k + 1u) {
    \\        let dv = qa[ao + k] - b4[bo + k];
    \\        acc = acc + dot(dv, dv);
    \\      }
    \\      dist[i * p.n + j] = acc;
    \\    }
    \\  }
    \\}
;

const WGSL_PAIRDIST_BROKEN = PRELUDE ++
    \\struct P { m : u32, n : u32, d : u32, pad : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> a : array<f32>;
    \\@group(0) @binding(3) var<storage, read> b : array<f32>;
    \\@group(0) @binding(4) var<storage, read_write> dist : array<f32>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
    \\  let j = gid.x + tile.xoff * 256u;
    \\  if (j >= p.n) { return; }
    \\  let bo = j * p.d;
    \\  for (var i = 0u; i < p.m; i = i + 1u) {
    \\    let ao = i * p.d;
    \\    var acc = 0.0;
    \\    for (var k = 0u; k < p.d; k = k + 1u) {
    \\      let diff = a[ao + k] - b[bo + k];
    \\      acc = acc + diff * diff;
    \\    }
    \\    dist[i * p.n + j] = acc * 0.5 + 1.0;
    \\  }
    \\}
;

pub const PD_GENERIC: usize = 0;
pub const PD_ROW: usize = 1;
pub const PD_ROW4: usize = 2;
pub const PD_ROW4S: usize = 3;
pub const PD_BROKEN: usize = 4; // test only
pub const PD_REAL: usize = 4; // variants a table may hold: 0..PD_REAL-1
pub const PD_VARIANTS: usize = 5;
pub const pd_variant_names = [_][]const u8{ "tile16", "row", "row4", "row4s", "broken" };

pub fn pdVariantEligible(v: usize, m: usize, n: usize, d: usize) bool {
    _ = n;
    return switch (v) {
        PD_GENERIC => true,
        PD_ROW, PD_BROKEN => m <= 64,
        PD_ROW4 => m <= 64 and d % 4 == 0,
        PD_ROW4S => d % 4 == 0 and m * (d / 4) <= 1024,
        else => false,
    };
}

pub fn pdKernelFor(v: usize) i64 {
    return switch (v) {
        PD_GENERIC => compile(WGSL_PAIRDIST),
        PD_ROW => compile(WGSL_PAIRDIST_ROW),
        PD_ROW4 => compile(WGSL_PAIRDIST_ROW4),
        PD_ROW4S => compile(WGSL_PAIRDIST_ROW4S),
        PD_BROKEN => compile(WGSL_PAIRDIST_BROKEN),
        else => 0,
    };
}

pub const Geometry = struct { wx: usize, wy: usize };

pub fn pdGeometry(v: usize, m: usize, n: usize) Geometry {
    return if (v == PD_GENERIC)
        .{ .wx = ceilDiv(n, TILE), .wy = ceilDiv(m, TILE) }
    else
        .{ .wx = ceilDiv(n, WG), .wy = 1 };
}

// ---- the variant table: (op, m-class, n-class, d-class) -> variant.
// Filled by the foundry (or a persisted file), consulted at dispatch. A
// class with no entry keeps the generic. Never holds the test-only variant.
const VarEntry = struct { hash: u64, cm: u8, cn: u8, cd: u8, variant: u8 };
var variants: std.ArrayList(VarEntry) = .{};

fn nameHash(name: [*]const u8, name_len: f64) u64 {
    const n: usize = @intFromFloat(name_len);
    return std.hash.Wyhash.hash(0, name[0..n]);
}

fn findVariant(h: u64, cm: u8, cn: u8, cd: u8) ?*VarEntry {
    for (variants.items) |*e| {
        if (e.hash == h and e.cm == cm and e.cn == cn and e.cd == cd) return e;
    }
    return null;
}

pub fn stz_gpu_variant_set(name: [*]const u8, name_len: f64, m: f64, n: f64, d: f64, vf: f64) callconv(.c) i32 {
    const v: usize = @intFromFloat(@max(vf, 0));
    if (v >= PD_REAL) return gpu.BAD_ARG; // the table never holds a test variant
    const h = nameHash(name, name_len);
    const cm = gpu.shapeClass(m);
    const cn = gpu.shapeClass(n);
    const cd = gpu.shapeClass(d);
    if (findVariant(h, cm, cn, cd)) |e| {
        e.variant = @intCast(v);
        return gpu.OK;
    }
    variants.append(alloc, .{ .hash = h, .cm = cm, .cn = cn, .cd = cd, .variant = @intCast(v) }) catch return gpu.GPU_ERROR;
    return gpu.OK;
}

pub fn stz_gpu_variant_get(name: [*]const u8, name_len: f64, m: f64, n: f64, d: f64) callconv(.c) f64 {
    if (findVariant(nameHash(name, name_len), gpu.shapeClass(m), gpu.shapeClass(n), gpu.shapeClass(d))) |e| {
        return @floatFromInt(e.variant);
    }
    return 0;
}

pub fn stz_gpu_variant_clear() callconv(.c) void {
    variants.clearRetainingCapacity();
}

pub fn stz_gpu_variant_name(v: f64, out: [*]u8, cap: f64) callconv(.c) i32 {
    const i: usize = @intFromFloat(@max(v, 0));
    if (i >= PD_VARIANTS) return 0;
    const nm = pd_variant_names[i];
    const c: usize = @intFromFloat(cap);
    if (nm.len > c) return 0;
    @memcpy(out[0..nm.len], nm);
    return @intCast(nm.len);
}

/// The variant this dispatch will use: the table's choice for the class,
/// degraded to the nearest eligible one when the actual shape does not fit
/// (a class spans shapes; d % 4 may differ inside it).
fn pdVariantFor(m: usize, n: usize, d: usize) usize {
    const want: usize = @intFromFloat(stz_gpu_variant_get("pairdist", 8, @floatFromInt(m), @floatFromInt(n), @floatFromInt(d)));
    var v = want;
    while (v > PD_GENERIC and !pdVariantEligible(v, m, n, d)) v -= 1;
    return v;
}

/// D(m x n) = squared L2 distances between rows of A(m x d) and B(n x d).
pub fn stz_gpu_op_pairdist(a: i64, b: i64, dbuf: i64, mf: f64, nf: f64, df: f64) callconv(.c) i32 {
    const gate = gateAvailable();
    if (gate != gpu.OK) return gate;
    const m: usize = @intFromFloat(mf);
    const n: usize = @intFromFloat(nf);
    const d: usize = @intFromFloat(df);
    if (m == 0 or n == 0 or d == 0) return gpu.BAD_ARG;
    var st = checkBuf(a, m * d);
    if (st != gpu.OK) return st;
    st = checkBuf(b, n * d);
    if (st != gpu.OK) return st;
    st = checkBuf(dbuf, m * n);
    if (st != gpu.OK) return st;
    const v = pdVariantFor(m, n, d);
    const kern = pdKernelFor(v);
    if (kern == 0) return if (gpu.stz_gpu_is_available() == 0) gpu.FALLBACK else gpu.GPU_ERROR;
    if (v != PD_GENERIC) gpu.bumpCounter(gpu.CTR_VARIANT_DISPATCH, 1);
    const p = PdParams{ .m = @intCast(m), .n = @intCast(n), .d = @intCast(d), .pad = 0 };
    const g = pdGeometry(v, m, n);
    return dispatchP(kern, &p, &.{ a, b, dbuf }, g.wx, g.wy);
}

test "the variant table classes shapes and degrades to an eligible variant" {
    variants.clearRetainingCapacity();
    _ = stz_gpu_variant_set("pairdist", 8, 1, 4096, 384, @floatFromInt(PD_ROW4S));
    try std.testing.expectEqual(@as(usize, PD_ROW4S), pdVariantFor(1, 4096, 384));
    try std.testing.expectEqual(@as(usize, PD_ROW4S), pdVariantFor(1, 3000, 300)); // same classes
    try std.testing.expectEqual(@as(usize, PD_ROW), pdVariantFor(1, 3000, 301)); // d % 4 != 0: degrades
    try std.testing.expectEqual(@as(usize, PD_GENERIC), pdVariantFor(1, 64, 384)); // another class: generic
    try std.testing.expectEqual(gpu.BAD_ARG, stz_gpu_variant_set("pairdist", 8, 1, 4096, 384, @floatFromInt(PD_BROKEN)));
    stz_gpu_variant_clear();
    try std.testing.expectEqual(@as(usize, PD_GENERIC), pdVariantFor(1, 4096, 384));
}

// ---------------------------------------------------------------- reductions

const RedParams = extern struct { n: u32, pad0: u32, pad1: u32, pad2: u32 };

const WGSL_SUM_PARTIALS = PRELUDE ++
    \\struct P { n : u32, pad0 : u32, pad1 : u32, pad2 : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> v : array<f32>;
    \\@group(0) @binding(3) var<storage, read_write> parts : array<f32>;
    \\var<workgroup> sh : array<f32, 256>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>,
    \\        @builtin(local_invocation_id) lid : vec3<u32>,
    \\        @builtin(workgroup_id) wid : vec3<u32>) {
    \\  let i = gid.x + tile.xoff * 256u;
    \\  sh[lid.x] = select(0.0, v[i], i < p.n);
    \\  workgroupBarrier();
    \\  for (var s = 128u; s > 0u; s = s >> 1u) {
    \\    if (lid.x < s) { sh[lid.x] = sh[lid.x] + sh[lid.x + s]; }
    \\    workgroupBarrier();
    \\  }
    \\  if (lid.x == 0u) { parts[wid.x + tile.xoff] = sh[0]; }
    \\}
;

const WGSL_DOT_PARTIALS = PRELUDE ++
    \\struct P { n : u32, pad0 : u32, pad1 : u32, pad2 : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> a : array<f32>;
    \\@group(0) @binding(3) var<storage, read> b : array<f32>;
    \\@group(0) @binding(4) var<storage, read_write> parts : array<f32>;
    \\var<workgroup> sh : array<f32, 256>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>,
    \\        @builtin(local_invocation_id) lid : vec3<u32>,
    \\        @builtin(workgroup_id) wid : vec3<u32>) {
    \\  let i = gid.x + tile.xoff * 256u;
    \\  sh[lid.x] = select(0.0, a[i] * b[i], i < p.n);
    \\  workgroupBarrier();
    \\  for (var s = 128u; s > 0u; s = s >> 1u) {
    \\    if (lid.x < s) { sh[lid.x] = sh[lid.x] + sh[lid.x + s]; }
    \\    workgroupBarrier();
    \\  }
    \\  if (lid.x == 0u) { parts[wid.x + tile.xoff] = sh[0]; }
    \\}
;

const WGSL_MAX_PARTIALS = PRELUDE ++
    \\struct P { n : u32, pad0 : u32, pad1 : u32, pad2 : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> v : array<f32>;
    \\@group(0) @binding(3) var<storage, read_write> parts : array<f32>;
    \\var<workgroup> sh : array<f32, 256>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>,
    \\        @builtin(local_invocation_id) lid : vec3<u32>,
    \\        @builtin(workgroup_id) wid : vec3<u32>) {
    \\  let i = gid.x + tile.xoff * 256u;
    \\  sh[lid.x] = select(-3.4028235e38, v[i], i < p.n);
    \\  workgroupBarrier();
    \\  for (var s = 128u; s > 0u; s = s >> 1u) {
    \\    if (lid.x < s) { sh[lid.x] = max(sh[lid.x], sh[lid.x + s]); }
    \\    workgroupBarrier();
    \\  }
    \\  if (lid.x == 0u) { parts[wid.x + tile.xoff] = sh[0]; }
    \\}
;

const ReduceKind = enum { sum, dot, max };

/// Shared reduction driver: dispatch partials, read them back, fold in f64
/// (ascending order -- deterministic, and exact for integer-valued data).
fn reduceDrive(kind: ReduceKind, a: i64, b: i64, n: usize, out_val: *f64) i32 {
    const nparts = ceilDiv(n, WG);
    const scratch = gpu.stz_gpu_buffer_new(@floatFromInt(nparts * 4));
    if (scratch == 0) return if (gpu.stz_gpu_is_available() == 0) gpu.FALLBACK else gpu.TOO_LARGE;
    defer _ = gpu.stz_gpu_buffer_free(scratch);

    const kern = switch (kind) {
        .sum => compile(WGSL_SUM_PARTIALS),
        .dot => compile(WGSL_DOT_PARTIALS),
        .max => compile(WGSL_MAX_PARTIALS),
    };
    if (kern == 0) return gpu.GPU_ERROR;
    const p = RedParams{ .n = @intCast(n), .pad0 = 0, .pad1 = 0, .pad2 = 0 };
    const st = switch (kind) {
        .dot => dispatchP(kern, &p, &.{ a, b, scratch }, nparts, 1),
        else => dispatchP(kern, &p, &.{ a, scratch }, nparts, 1),
    };
    if (st != gpu.OK) return st;

    const parts = alloc.alloc(f32, nparts) catch return gpu.GPU_ERROR;
    defer alloc.free(parts);
    const rst = gpu.stz_gpu_buffer_read(scratch, @ptrCast(parts.ptr), @floatFromInt(nparts * 4));
    if (rst != gpu.OK) return rst;

    var acc: f64 = if (kind == .max) -std.math.inf(f64) else 0;
    for (parts) |v| {
        switch (kind) {
            .max => acc = @max(acc, @as(f64, v)),
            else => acc += @as(f64, v),
        }
    }
    out_val.* = acc;
    return gpu.OK;
}

/// Sum of n f32s. Partials on GPU, f64 fold on CPU (ascending, deterministic).
pub fn stz_gpu_op_sum(a: i64, nf: f64, out_val: *f64) callconv(.c) i32 {
    const gate = gateAvailable();
    if (gate != gpu.OK) return gate;
    const n: usize = @intFromFloat(nf);
    if (n == 0) return gpu.BAD_ARG;
    const st = checkBuf(a, n);
    if (st != gpu.OK) return st;
    return reduceDrive(.sum, a, 0, n, out_val);
}

/// Dot product of two n-f32 vectors.
pub fn stz_gpu_op_dot(a: i64, b: i64, nf: f64, out_val: *f64) callconv(.c) i32 {
    const gate = gateAvailable();
    if (gate != gpu.OK) return gate;
    const n: usize = @intFromFloat(nf);
    if (n == 0) return gpu.BAD_ARG;
    var st = checkBuf(a, n);
    if (st != gpu.OK) return st;
    st = checkBuf(b, n);
    if (st != gpu.OK) return st;
    return reduceDrive(.dot, a, b, n, out_val);
}

// ---------------------------------------------------------------- softmax

const SoftParams = extern struct { n: u32, pad0: u32, maxv: f32, pad1: f32 };

// exp pass: out[i] = exp(in[i] - max), AND per-workgroup partial sums of the
// exps -- fused so softmax costs 3 dispatches total (max, exp+partials,
// scale), not 4.
const WGSL_EXP_PARTIALS = PRELUDE ++
    \\struct P { n : u32, pad0 : u32, maxv : f32, pad1 : f32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> v : array<f32>;
    \\@group(0) @binding(3) var<storage, read_write> outv : array<f32>;
    \\@group(0) @binding(4) var<storage, read_write> parts : array<f32>;
    \\var<workgroup> sh : array<f32, 256>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>,
    \\        @builtin(local_invocation_id) lid : vec3<u32>,
    \\        @builtin(workgroup_id) wid : vec3<u32>) {
    \\  let i = gid.x + tile.xoff * 256u;
    \\  var e = 0.0;
    \\  if (i < p.n) {
    \\    e = exp(v[i] - p.maxv);
    \\    outv[i] = e;
    \\  }
    \\  sh[lid.x] = e;
    \\  workgroupBarrier();
    \\  for (var s = 128u; s > 0u; s = s >> 1u) {
    \\    if (lid.x < s) { sh[lid.x] = sh[lid.x] + sh[lid.x + s]; }
    \\    workgroupBarrier();
    \\  }
    \\  if (lid.x == 0u) { parts[wid.x + tile.xoff] = sh[0]; }
    \\}
;

/// out = softmax(in) over n f32s (max-shifted, numerically safe).
/// in and out must be distinct buffers.
pub fn stz_gpu_op_softmax(in: i64, out: i64, nf: f64) callconv(.c) i32 {
    const gate = gateAvailable();
    if (gate != gpu.OK) return gate;
    const n: usize = @intFromFloat(nf);
    if (n == 0) return gpu.BAD_ARG;
    var st = checkBuf(in, n);
    if (st != gpu.OK) return st;
    st = checkBuf(out, n);
    if (st != gpu.OK) return st;

    // pass 1: global max (partials + CPU fold)
    var maxv: f64 = 0;
    st = reduceDrive(.max, in, 0, n, &maxv);
    if (st != gpu.OK) return st;

    // pass 2: exp(in - max) into out, with partial sums
    const nparts = ceilDiv(n, WG);
    const scratch = gpu.stz_gpu_buffer_new(@floatFromInt(nparts * 4));
    if (scratch == 0) return if (gpu.stz_gpu_is_available() == 0) gpu.FALLBACK else gpu.TOO_LARGE;
    defer _ = gpu.stz_gpu_buffer_free(scratch);
    const kern = compile(WGSL_EXP_PARTIALS);
    if (kern == 0) return gpu.GPU_ERROR;
    const p = SoftParams{ .n = @intCast(n), .pad0 = 0, .maxv = @floatCast(maxv), .pad1 = 0 };
    st = dispatchP(kern, &p, &.{ in, out, scratch }, nparts, 1);
    if (st != gpu.OK) return st;

    const parts = alloc.alloc(f32, nparts) catch return gpu.GPU_ERROR;
    defer alloc.free(parts);
    st = gpu.stz_gpu_buffer_read(scratch, @ptrCast(parts.ptr), @floatFromInt(nparts * 4));
    if (st != gpu.OK) return st;
    var total: f64 = 0;
    for (parts) |v| total += @as(f64, v);
    if (total <= 0) return gpu.GPU_ERROR;

    // pass 3: out *= 1/total
    return stz_gpu_op_scale_inplace(out, 1.0 / total, nf);
}

// ---------------------------------------------------------------- top-k select

/// The k smallest values in a device buffer of n f32s, with their 0-based
/// indices -- the half of a knn/semantic-search answer that must NOT cross
/// into Ring as raw data (a Ring-side scan of 100k distances would eat the
/// GPU's win). Reads the buffer back engine-side and selects here.
///
/// Selection: insertion into a sorted k-array -- O(n) when the data is not
/// pathological (most values fail the `worst` test in one compare), O(n*k)
/// worst case, and k is single-digits-to-dozens in every real caller.
/// Ties break on the LOWER index, so the answer is deterministic.
///
/// out_idx/out_dist must hold k entries; returns the filled count via
/// out_count (min(k, n)).
pub fn stz_gpu_op_topk(dbuf: i64, nf: f64, kf: f64, out_idx: [*]f64, out_dist: [*]f64, out_count: *i32) callconv(.c) i32 {
    const gate = gateAvailable();
    if (gate != gpu.OK) return gate;
    const n: usize = @intFromFloat(nf);
    const k: usize = @intFromFloat(kf);
    out_count.* = 0;
    if (n == 0 or k == 0) return gpu.BAD_ARG;
    const st = checkBuf(dbuf, n);
    if (st != gpu.OK) return st;

    const vals = alloc.alloc(f32, n) catch return gpu.GPU_ERROR;
    defer alloc.free(vals);
    const rst = gpu.stz_gpu_buffer_read(dbuf, @ptrCast(vals.ptr), @floatFromInt(n * 4));
    if (rst != gpu.OK) return rst;

    const want = @min(k, n);
    const best_d = alloc.alloc(f32, want) catch return gpu.GPU_ERROR;
    defer alloc.free(best_d);
    const best_i = alloc.alloc(usize, want) catch return gpu.GPU_ERROR;
    defer alloc.free(best_i);

    var filled: usize = 0;
    for (vals, 0..) |v, i| {
        if (filled == want and v >= best_d[filled - 1]) continue;
        // find insertion point (strictly-less keeps ties on the lower index,
        // because later i can only displace a strictly GREATER value)
        var pos = filled;
        while (pos > 0 and v < best_d[pos - 1]) : (pos -= 1) {}
        if (pos == want) continue;
        const last = @min(filled, want - 1);
        var j: usize = last;
        while (j > pos) : (j -= 1) {
            best_d[j] = best_d[j - 1];
            best_i[j] = best_i[j - 1];
        }
        best_d[pos] = v;
        best_i[pos] = i;
        if (filled < want) filled += 1;
    }
    for (0..filled) |i| {
        out_idx[i] = @floatFromInt(best_i[i]);
        out_dist[i] = @as(f64, best_d[i]);
    }
    out_count.* = @intCast(filled);
    return gpu.OK;
}

test {
    _ = gpu;
}

test "the matmul table classes shapes and never holds the broken sibling" {
    variants.clearRetainingCapacity();
    _ = stz_gpu_variant_set("matmul", 6, 256, 1536, 384, @floatFromInt(MM_REG4));
    try std.testing.expectEqual(@as(usize, MM_REG4), mmVariantFor(256, 384, 1536));
    try std.testing.expectEqual(@as(usize, MM_REG4), mmVariantFor(200, 300, 1100)); // same classes
    try std.testing.expectEqual(@as(usize, MM_GENERIC), mmVariantFor(256, 384, 384)); // another n-class
    try std.testing.expectEqual(gpu.BAD_ARG, stz_gpu_variant_set("matmul", 6, 256, 1536, 384, @floatFromInt(MM_BROKEN)));
    const g = mmGeometry(MM_REG4, 256, 1536);
    try std.testing.expectEqual(@as(usize, 24 * 4), g.wx); // 64x64 tiles on a linear grid
    try std.testing.expectEqual(@as(usize, 1), g.wy);
    stz_gpu_variant_clear();
}
