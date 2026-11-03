//! gpu_segscan.zig -- GB0's fourth op: segmented scan and segmented reduction on the GPU
//! (SOFTANZA_GPU_PLAN.md, GB0; the scan of gpu_scan.zig with a reset, and compaction on top).
//!
//! A vector is cut into SEGMENTS by a flags buffer: a nonzero flag at i starts a new
//! segment there, and element 0 always starts one (a leading orphan segment would have
//! nothing to be). Two ops, each with an operator (0 sum, 1 max, 2 min):
//!   segscan     out[i] = the operator over the elements of i's segment up to and including i
//!               (a running total that starts over at every flag);
//!   segreduce   out[s] = the operator over the whole of segment s, one number per segment, packed
//!               at the front of out, and how many segments there were.
//!
//! The scan carries PAIRS (flag, value), combined as
//!     (f1, v1) + (f2, v2) = (f1 or f2, if f2 then v2 else v1 op v2)
//! which is associative, so the three-phase scan of gpu_scan.zig applies unchanged in shape:
//!   BLOCKS   every group of 256 scans its pairs in shared memory (Hillis-Steele), writes each
//!            element's value and its CARRIED flag (is there a start at or before it in this
//!            block?), and the block's total pair;
//!   TOTALS   the block totals, pairs, are scanned the same way one level up, until one group holds them;
//!   OFFSETS  walking back down, an element with no start before it in its block takes the scanned
//!            total of the blocks before it: value = offset op value. One that has a start before it
//!            already holds its whole segment.
//! A segmented scan is `2 * levels - 1` dispatches in ONE batched submit, as the plain scan is.
//!
//! The reduction is the scan plus the compaction of gpu_compact.zig: the last element of each
//! segment (the one before a flag, and element n - 1) holds the segment's total, so a mask of
//! segment ends keeps exactly those. The output buffer must hold n numbers (as many segments as
//! elements is the worst case); the first `nseg` are written. It is two submits and the count's read.
//!
//! Float adds are not associative, so a sum's order is the fixed tree, not left to right: exact on
//! whole numbers below 2^24, within f32 rounding otherwise; a max or a min is exact always.
//! The reduction is limited to 16,777,216 elements (the compaction's counts are f32); the scan alone is not.
//!
//! Binding contract, the ops family's: @binding(0) tile, @binding(1) params, @binding(2..)
//! buffers in call order; every kernel reads the tile uniform.

const std = @import("std");
const gpu = @import("gpu.zig");
const compactop = @import("gpu_compact.zig");

const WG: usize = 256;
const MAX_LEVELS = 6;
pub const OP_SUM: u32 = 0;
pub const OP_MAX: u32 = 1;
pub const OP_MIN: u32 = 2;

const PRELUDE =
    \\struct StzTile { xoff : u32, p0 : u32, p1 : u32, p2 : u32 }
    \\@group(0) @binding(0) var<uniform> tile : StzTile;
    \\
;

const SegParams = extern struct { n: u32, op: u32, p1: u32, p2: u32 };

const COMB =
    \\fn comb(op : u32, a : f32, b : f32) -> f32 {
    \\  if (op == 0u) { return a + b; }
    \\  if (op == 1u) { return max(a, b); }
    \\  return min(a, b);
    \\}
    \\fn ident(op : u32) -> f32 {
    \\  if (op == 0u) { return 0.0; }
    \\  if (op == 1u) { return -3.4028235e38; }
    \\  return 3.4028235e38;
    \\}
    \\
;

// phase 1: a group scans its (flag, value) pairs; every element's value and carried flag go out, and the block's total pair
const WGSL_SEG_BLOCKS = PRELUDE ++ COMB ++
    \\struct P { n : u32, op : u32, p1 : u32, p2 : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> srcv : array<f32>;
    \\@group(0) @binding(3) var<storage, read> srcf : array<f32>;
    \\@group(0) @binding(4) var<storage, read_write> dstv : array<f32>;
    \\@group(0) @binding(5) var<storage, read_write> carried : array<f32>;
    \\@group(0) @binding(6) var<storage, read_write> totv : array<f32>;
    \\@group(0) @binding(7) var<storage, read_write> totf : array<f32>;
    \\var<workgroup> av : array<f32, 256>;
    \\var<workgroup> af : array<u32, 256>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>,
    \\        @builtin(local_invocation_id) lid : vec3<u32>,
    \\        @builtin(workgroup_id) wid : vec3<u32>) {
    \\  let i = gid.x + tile.xoff * 256u;
    \\  let g = wid.x + tile.xoff;
    \\  let l = lid.x;
    \\  var x = ident(p.op);
    \\  var f = 0u;
    \\  if (i < p.n) {
    \\    x = srcv[i];
    \\    f = select(0u, 1u, srcf[i] != 0.0);
    \\    if (i == 0u) { f = 1u; }
    \\  }
    \\  av[l] = x;
    \\  af[l] = f;
    \\  workgroupBarrier();
    \\  for (var s = 1u; s < 256u; s = s << 1u) {
    \\    var nv = av[l];
    \\    var nf = af[l];
    \\    if (l >= s) {
    \\      let lv = av[l - s];
    \\      let lf = af[l - s];
    \\      if (nf == 0u) { nv = comb(p.op, lv, nv); }
    \\      nf = nf | lf;
    \\    }
    \\    workgroupBarrier();
    \\    av[l] = nv;
    \\    af[l] = nf;
    \\    workgroupBarrier();
    \\  }
    \\  if (i < p.n) {
    \\    dstv[i] = av[l];
    \\    carried[i] = f32(af[l]);
    \\  }
    \\  if (l == 255u) {
    \\    totv[g] = av[255];
    \\    totf[g] = f32(af[255]);
    \\  }
    \\}
;

// phase 3: an element with no start before it in its block takes the scanned total of the blocks before it
const WGSL_SEG_ADD = PRELUDE ++ COMB ++
    \\struct P { n : u32, op : u32, p1 : u32, p2 : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read_write> dst : array<f32>;
    \\@group(0) @binding(3) var<storage, read> carried : array<f32>;
    \\@group(0) @binding(4) var<storage, read> offs : array<f32>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
    \\  let i = gid.x + tile.xoff * 256u;
    \\  if (i >= p.n) { return; }
    \\  let g = i / 256u;
    \\  if (g > 0u && carried[i] == 0.0) { dst[i] = comb(p.op, offs[g - 1u], dst[i]); }
    \\}
;

// the last element of each segment: the one before a flag, and the last of all
const WGSL_SEG_ENDS = PRELUDE ++
    \\struct P { n : u32, op : u32, p1 : u32, p2 : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> flags : array<f32>;
    \\@group(0) @binding(3) var<storage, read_write> ends : array<f32>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
    \\  let i = gid.x + tile.xoff * 256u;
    \\  if (i >= p.n) { return; }
    \\  var e = 0.0;
    \\  if (i == p.n - 1u) { e = 1.0; } else { if (flags[i + 1u] != 0.0) { e = 1.0; } }
    \\  ends[i] = e;
    \\}
;

fn ceilDiv(a: usize, b: usize) usize {
    return (a + b - 1) / b;
}

fn compile(text: []const u8) i64 {
    return gpu.stz_gpu_kernel_compile(text.ptr, @floatFromInt(text.len));
}

fn dispatchP(kernel: i64, params: anytype, bufs: []const i64, wx: usize) i32 {
    const bytes = std.mem.asBytes(params);
    return gpu.stz_gpu_dispatch_params(kernel, bytes.ptr, @floatFromInt(bytes.len), bufs.ptr, @intCast(bufs.len), @floatFromInt(wx), 1);
}

fn levelsFor(n: usize) usize {
    var lv: usize = 1;
    var m = n;
    while (m > WG) : (lv += 1) m = ceilDiv(m, WG);
    return lv;
}

/// How many dispatches a segmented scan of n elements makes (a block pass at every level, an
/// offsets pass at every level but the top); a reduction adds the segment-ends pass and a compaction.
pub fn stz_gpu_segscan_dispatches(nf: f64) callconv(.c) f64 {
    const n: usize = @intFromFloat(nf);
    if (n == 0) return 0;
    return @floatFromInt(2 * levelsFor(n) - 1);
}

// ---------------------------------------------------------------- the scratch
// The carried flags of the first level (as long as the input), the scan's value vector and the
// segment-ends mask of a reduction: kept between calls, as compaction keeps its scratch (making
// them on every call was the whole cost there), grown when a larger input comes, freed by
// `stz_gpu_segscan_release` or when the device closes.
var sc_carried: i64 = 0;
var sc_scan: i64 = 0;
var sc_ends: i64 = 0;
var sc_cap: usize = 0;
var hooked = false;

fn onDeviceClose() void {
    sc_carried = 0;
    sc_scan = 0;
    sc_ends = 0;
    sc_cap = 0;
}

fn scratchFree() void {
    for ([_]i64{ sc_carried, sc_scan, sc_ends }) |id| {
        if (id != 0) _ = gpu.stz_gpu_buffer_free(id);
    }
    onDeviceClose();
}

fn alive(id: i64) bool {
    return id != 0 and gpu.stz_gpu_buffer_size(id) >= 0;
}

fn ensureScratch(n: usize) i32 {
    if (!hooked) {
        gpu.registerDeviceCloseHook(&onDeviceClose);
        hooked = true;
    }
    const live = alive(sc_carried) and alive(sc_scan) and alive(sc_ends);
    if (live and sc_cap >= n) return gpu.OK;
    if (live) scratchFree() else onDeviceClose();
    sc_carried = gpu.stz_gpu_buffer_new(@floatFromInt(n * 4));
    sc_scan = gpu.stz_gpu_buffer_new(@floatFromInt(n * 4));
    sc_ends = gpu.stz_gpu_buffer_new(@floatFromInt(n * 4));
    if (!(alive(sc_carried) and alive(sc_scan) and alive(sc_ends))) {
        const dead = gpu.stz_gpu_is_available() == 0;
        scratchFree();
        return if (dead) gpu.FALLBACK else gpu.TOO_LARGE;
    }
    sc_cap = n;
    return gpu.OK;
}

/// Give the scratch back. The next call makes it again.
pub fn stz_gpu_segscan_release() callconv(.c) void {
    scratchFree();
}

/// The levels' own buffers, small except the first level's carried flags, which are the scratch.
const Plan = struct {
    lv: usize = 0,
    sizes: [MAX_LEVELS]usize = undefined,
    totv: [MAX_LEVELS]i64 = @splat(0),
    totf: [MAX_LEVELS]i64 = @splat(0),
    scanv: [MAX_LEVELS]i64 = @splat(0), // level l >= 1: its own scanned values
    carr: [MAX_LEVELS]i64 = @splat(0), // level l >= 1: its carried flags (level 0 uses the scratch)
    k_blocks: i64 = 0,
    k_add: i64 = 0,
};

fn planFree(pl: *Plan) void {
    for (0..pl.lv) |l| {
        for ([_]i64{ pl.totv[l], pl.totf[l], pl.scanv[l], pl.carr[l] }) |id| {
            if (id != 0) _ = gpu.stz_gpu_buffer_free(id);
        }
        pl.totv[l] = 0;
        pl.totf[l] = 0;
        pl.scanv[l] = 0;
        pl.carr[l] = 0;
    }
}

fn planNew(n: usize, pl: *Plan) i32 {
    pl.* = .{};
    pl.k_blocks = compile(WGSL_SEG_BLOCKS);
    pl.k_add = compile(WGSL_SEG_ADD);
    if (pl.k_blocks == 0 or pl.k_add == 0) return gpu.GPU_ERROR;
    const lv = levelsFor(n);
    if (lv > MAX_LEVELS) return gpu.TOO_LARGE;
    var m = n;
    for (0..lv) |l| {
        pl.sizes[l] = m;
        m = ceilDiv(m, WG);
    }
    pl.lv = lv;
    for (0..lv) |l| {
        const nbl = ceilDiv(pl.sizes[l], WG);
        pl.totv[l] = gpu.stz_gpu_buffer_new(@floatFromInt(nbl * 4));
        pl.totf[l] = gpu.stz_gpu_buffer_new(@floatFromInt(nbl * 4));
        var ok = pl.totv[l] != 0 and pl.totf[l] != 0;
        if (l > 0) {
            pl.scanv[l] = gpu.stz_gpu_buffer_new(@floatFromInt(pl.sizes[l] * 4));
            pl.carr[l] = gpu.stz_gpu_buffer_new(@floatFromInt(pl.sizes[l] * 4));
            ok = ok and pl.scanv[l] != 0 and pl.carr[l] != 0;
        }
        if (!ok) {
            const dead = gpu.stz_gpu_is_available() == 0;
            planFree(pl);
            return if (dead) gpu.FALLBACK else gpu.TOO_LARGE;
        }
    }
    return gpu.OK;
}

fn record(pl: *const Plan, in: i64, flags: i64, out: i64, op: u32) i32 {
    var st: i32 = gpu.OK;
    var l: usize = 0;
    while (st == gpu.OK and l < pl.lv) : (l += 1) {
        const sv = if (l == 0) in else pl.totv[l - 1];
        const sf = if (l == 0) flags else pl.totf[l - 1];
        const dv = if (l == 0) out else pl.scanv[l];
        const cf = if (l == 0) sc_carried else pl.carr[l];
        st = dispatchP(pl.k_blocks, &SegParams{ .n = @intCast(pl.sizes[l]), .op = op, .p1 = 0, .p2 = 0 }, &.{ sv, sf, dv, cf, pl.totv[l], pl.totf[l] }, ceilDiv(pl.sizes[l], WG));
    }
    var u: usize = pl.lv - 1;
    while (st == gpu.OK and u > 0) {
        u -= 1;
        const dv = if (u == 0) out else pl.scanv[u];
        const cf = if (u == 0) sc_carried else pl.carr[u];
        st = dispatchP(pl.k_add, &SegParams{ .n = @intCast(pl.sizes[u]), .op = op, .p1 = 0, .p2 = 0 }, &.{ dv, cf, pl.scanv[u + 1] }, ceilDiv(pl.sizes[u], WG));
    }
    return st;
}

fn checkBuf(id: i64, n: usize) i32 {
    const sz = gpu.stz_gpu_buffer_size(id);
    if (sz < 0) return gpu.STALE;
    if (@as(f64, @floatFromInt(n * 4)) > sz) return gpu.BAD_ARG;
    return gpu.OK;
}

/// The checks both ops share: a device, 1 <= n <= limit (TOO_LARGE past it, before any buffer is
/// looked at), a known operator, three distinct buffers that can hold n.
fn check(in: i64, flags: i64, out: i64, n: usize, opf: f64, limit: usize) i32 {
    if (gpu.stz_gpu_is_available() == 0) {
        gpu.countFallback();
        return gpu.FALLBACK;
    }
    if (n == 0) return gpu.BAD_ARG;
    if (n > limit) return gpu.TOO_LARGE;
    if (opf != 0 and opf != 1 and opf != 2) return gpu.BAD_ARG;
    if (in == 0 or flags == 0 or out == 0 or in == flags or in == out or flags == out) return gpu.BAD_ARG;
    var st = checkBuf(in, n);
    if (st != gpu.OK) return st;
    st = checkBuf(flags, n);
    if (st != gpu.OK) return st;
    return checkBuf(out, n);
}

/// out[i] = the operator over the elements of i's segment up to i. A nonzero flag starts a segment;
/// element 0 always does. in, flags and out are distinct buffers of n f32s.
pub fn stz_gpu_op_segscan(in: i64, flags: i64, out: i64, nf: f64, opf: f64) callconv(.c) i32 {
    const n: usize = @intFromFloat(nf);
    var st = check(in, flags, out, n, opf, std.math.maxInt(u32));
    if (st != gpu.OK) return st;
    st = ensureScratch(n);
    if (st != gpu.OK) return st;
    var pl: Plan = .{};
    st = planNew(n, &pl);
    if (st != gpu.OK) return st;
    defer planFree(&pl);
    _ = gpu.stz_gpu_batch_begin();
    st = record(&pl, in, flags, out, @intFromFloat(opf));
    const st_end = gpu.stz_gpu_batch_end();
    if (st != gpu.OK) return st;
    return st_end;
}

/// out[s] = the operator over segment s, for every segment, packed at the front of out; the number
/// of segments in out_count. out must hold n numbers; only the first out_count are written.
pub fn stz_gpu_op_segreduce(in: i64, flags: i64, out: i64, nf: f64, opf: f64, out_count: *f64) callconv(.c) i32 {
    const n: usize = @intFromFloat(nf);
    var st = check(in, flags, out, n, opf, compactop.MAX_N);
    if (st != gpu.OK) return st;
    st = ensureScratch(n);
    if (st != gpu.OK) return st;
    var pl: Plan = .{};
    st = planNew(n, &pl);
    if (st != gpu.OK) return st;
    defer planFree(&pl);
    const k_ends = compile(WGSL_SEG_ENDS);
    if (k_ends == 0) return gpu.GPU_ERROR;
    _ = gpu.stz_gpu_batch_begin();
    st = record(&pl, in, flags, sc_scan, @intFromFloat(opf));
    if (st == gpu.OK) st = dispatchP(k_ends, &SegParams{ .n = @intCast(n), .op = 0, .p1 = 0, .p2 = 0 }, &.{ flags, sc_ends }, ceilDiv(n, WG));
    const st_end = gpu.stz_gpu_batch_end();
    if (st != gpu.OK) return st;
    if (st_end != gpu.OK) return st_end;
    // the last element of each segment holds its total: keep exactly those
    return compactop.stz_gpu_op_compact(sc_scan, sc_ends, out, nf, out_count);
}

test "a segmented scan is as many dispatches as a scan" {
    try std.testing.expectEqual(@as(f64, 1), stz_gpu_segscan_dispatches(256));
    try std.testing.expectEqual(@as(f64, 3), stz_gpu_segscan_dispatches(257));
    try std.testing.expectEqual(@as(f64, 5), stz_gpu_segscan_dispatches(65537));
    try std.testing.expectEqual(@as(f64, 0), stz_gpu_segscan_dispatches(0));
}
