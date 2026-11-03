//! gpu_scan.zig -- GB0's first op: the prefix scan (running total) on the GPU
//! (SOFTANZA_GPU_PLAN.md, GB0, "scan"; the library layer's foundation: sort,
//! top-k by selection and segmented reductions are all built on it).
//!
//! `out[i] = in[0] + ... + in[i]` (inclusive) or `in[0] + ... + in[i-1]`
//! (exclusive, `out[0] = 0`) over n f32s, entirely on the device: the data is
//! never read back, so a scan can sit inside a resident chain like the other
//! ops (G0's whole case).
//!
//! The algorithm is the standard three-phase one, recursive in the middle:
//!   1. BLOCKS   every group of 256 scans its 256 elements in workgroup memory
//!               (Hillis-Steele: eight steps, two barriers each) and writes the
//!               block's total;
//!   2. TOTALS   the block totals are scanned the same way, one level up, until
//!               a level fits one group: n up to 256^k needs k levels;
//!   3. OFFSETS  walking back down, every block of every level adds the scanned
//!               total of the blocks before it.
//! A scan of n elements is `2 * levels - 1` dispatches in ONE batched submit;
//! `stz_gpu_scan_dispatches(n)` says how many, so a guard can read the
//! counters against it.
//!
//! The exclusive form is the inclusive one SHIFTED, in the group: the value
//! written at l is the running total through l - 1, the very adds the
//! inclusive form made, so inside a block the two agree bit for bit and no
//! subtraction (which would not be exact) is ever done. Across a block's edge
//! the offset is added to a different partial, so on data whose partials are
//! not exact the two can differ in the last bit; on exact data they never do.
//! The upper levels are always inclusive.
//!
//! Float adds are not associative, so the result is not the sequential f64
//! sum's: the order is a fixed tree, deterministic from run to run, and the
//! guard sets its band from measurement. On integer-valued data below 2^24
//! every partial is exact and the answer is bit for bit the sequential one.
//!
//! Binding contract, the ops family's: @binding(0) tile, @binding(1) params,
//! @binding(2..) buffers in call order; every kernel reads the tile uniform.

const std = @import("std");
const gpu = @import("gpu.zig");

const WG: usize = 256;
const MAX_LEVELS = 6; // 256^6 elements: past any buffer a device grants

const PRELUDE =
    \\struct StzTile { xoff : u32, p0 : u32, p1 : u32, p2 : u32 }
    \\@group(0) @binding(0) var<uniform> tile : StzTile;
    \\
;

const ScanParams = extern struct { n: u32, mode: u32, p1: u32, p2: u32 };

// phase 1: a group scans its block; the block's total goes to sums[g]
const WGSL_SCAN_BLOCKS = PRELUDE ++
    \\struct P { n : u32, mode : u32, p1 : u32, p2 : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> src : array<f32>;
    \\@group(0) @binding(3) var<storage, read_write> dst : array<f32>;
    \\@group(0) @binding(4) var<storage, read_write> sums : array<f32>;
    \\var<workgroup> a : array<f32, 256>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>,
    \\        @builtin(local_invocation_id) lid : vec3<u32>,
    \\        @builtin(workgroup_id) wid : vec3<u32>) {
    \\  let i = gid.x + tile.xoff * 256u;
    \\  let g = wid.x + tile.xoff;
    \\  let l = lid.x;
    \\  var x = 0.0;
    \\  if (i < p.n) { x = src[i]; }
    \\  a[l] = x;
    \\  workgroupBarrier();
    \\  for (var s = 1u; s < 256u; s = s << 1u) {
    \\    var v = a[l];
    \\    if (l >= s) { v = v + a[l - s]; }
    \\    workgroupBarrier();
    \\    a[l] = v;
    \\    workgroupBarrier();
    \\  }
    \\  var r = a[l];
    \\  if (p.mode == 1u) {
    \\    r = 0.0;
    \\    if (l > 0u) { r = a[l - 1u]; }
    \\  }
    \\  if (i < p.n) { dst[i] = r; }
    \\  if (l == 255u) { sums[g] = a[255]; }
    \\}
;

// phase 3: every block after the first adds the scanned total of the blocks before it
const WGSL_SCAN_ADD = PRELUDE ++
    \\struct P { n : u32, mode : u32, p1 : u32, p2 : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read_write> dst : array<f32>;
    \\@group(0) @binding(3) var<storage, read> offs : array<f32>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
    \\  let i = gid.x + tile.xoff * 256u;
    \\  if (i >= p.n) { return; }
    \\  let g = i / 256u;
    \\  if (g > 0u) { dst[i] = dst[i] + offs[g - 1u]; }
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

/// The levels a scan of n elements takes: 1 while one group holds it, then one more for each
/// time the block totals themselves overflow a group.
pub fn levelsFor(n: usize) usize {
    var lv: usize = 1;
    var m = n;
    while (m > WG) : (lv += 1) m = ceilDiv(m, WG);
    return lv;
}

/// How many dispatches a scan of n elements makes: a block pass at every level and an
/// offsets pass at every level but the top one.
pub fn stz_gpu_scan_dispatches(nf: f64) callconv(.c) f64 {
    const n: usize = @intFromFloat(nf);
    if (n == 0) return 0;
    return @floatFromInt(2 * levelsFor(n) - 1);
}

/// out = the running total of in over n f32s. mode 0 is inclusive, 1 exclusive. in and out are
/// distinct buffers. OK / FALLBACK (no device) / STALE / BAD_ARG / TOO_LARGE / GPU_ERROR.
pub fn stz_gpu_op_scan(in: i64, out: i64, nf: f64, modef: f64) callconv(.c) i32 {
    if (gpu.stz_gpu_is_available() == 0) {
        gpu.countFallback();
        return gpu.FALLBACK;
    }
    const n: usize = @intFromFloat(nf);
    if (n == 0 or n > std.math.maxInt(u32)) return gpu.BAD_ARG;
    if (modef != 0 and modef != 1) return gpu.BAD_ARG;
    if (in == out) return gpu.BAD_ARG;
    const sz_in = gpu.stz_gpu_buffer_size(in);
    const sz_out = gpu.stz_gpu_buffer_size(out);
    if (sz_in < 0 or sz_out < 0) return gpu.STALE;
    if (@as(f64, @floatFromInt(n * 4)) > sz_in or @as(f64, @floatFromInt(n * 4)) > sz_out) return gpu.BAD_ARG;

    const k_blocks = compile(WGSL_SCAN_BLOCKS);
    const k_add = compile(WGSL_SCAN_ADD);
    if (k_blocks == 0 or k_add == 0) return gpu.GPU_ERROR;

    const lv = levelsFor(n);
    if (lv > MAX_LEVELS) return gpu.TOO_LARGE;
    // sizes[L] is the element count of level L; totals[L] holds level L's block totals (the
    // input of level L + 1); scanned[L] (L >= 1) is level L's own inclusive scan
    var sizes: [MAX_LEVELS]usize = undefined;
    var totals: [MAX_LEVELS]i64 = @splat(0);
    var scanned: [MAX_LEVELS]i64 = @splat(0);
    var m = n;
    for (0..lv) |l| {
        sizes[l] = m;
        m = ceilDiv(m, WG);
    }
    defer {
        for (0..lv) |l| {
            if (totals[l] != 0) _ = gpu.stz_gpu_buffer_free(totals[l]);
            if (scanned[l] != 0) _ = gpu.stz_gpu_buffer_free(scanned[l]);
        }
    }
    for (0..lv) |l| {
        totals[l] = gpu.stz_gpu_buffer_new(@floatFromInt(ceilDiv(sizes[l], WG) * 4));
        if (totals[l] == 0) return if (gpu.stz_gpu_is_available() == 0) gpu.FALLBACK else gpu.TOO_LARGE;
        if (l > 0) {
            scanned[l] = gpu.stz_gpu_buffer_new(@floatFromInt(sizes[l] * 4));
            if (scanned[l] == 0) return if (gpu.stz_gpu_is_available() == 0) gpu.FALLBACK else gpu.TOO_LARGE;
        }
    }

    _ = gpu.stz_gpu_batch_begin();
    var st: i32 = gpu.OK;
    // down: a block pass at every level, the totals of one level the input of the next
    var l: usize = 0;
    while (st == gpu.OK and l < lv) : (l += 1) {
        const src = if (l == 0) in else totals[l - 1];
        const dst = if (l == 0) out else scanned[l];
        const mode: u32 = if (l == 0) @intFromFloat(modef) else 0;
        st = dispatchP(k_blocks, &ScanParams{ .n = @intCast(sizes[l]), .mode = mode, .p1 = 0, .p2 = 0 }, &.{ src, dst, totals[l] }, ceilDiv(sizes[l], WG));
    }
    // up: every level but the top adds the scanned totals of the blocks before each of its blocks
    var u: usize = lv - 1;
    while (st == gpu.OK and u > 0) {
        u -= 1;
        const dst = if (u == 0) out else scanned[u];
        st = dispatchP(k_add, &ScanParams{ .n = @intCast(sizes[u]), .mode = 0, .p1 = 0, .p2 = 0 }, &.{ dst, scanned[u + 1] }, ceilDiv(sizes[u], WG));
    }
    const st_end = gpu.stz_gpu_batch_end();
    if (st != gpu.OK) return st;
    if (st_end != gpu.OK) return st_end;
    // the work buffers are freed by the defer: the submitted pass holds its own
    // references device-side (the same rule the fft op and the faces rely on)
    return gpu.OK;
}

test "levels and dispatches of a scan" {
    try std.testing.expectEqual(@as(usize, 1), levelsFor(1));
    try std.testing.expectEqual(@as(usize, 1), levelsFor(256));
    try std.testing.expectEqual(@as(usize, 2), levelsFor(257));
    try std.testing.expectEqual(@as(usize, 2), levelsFor(65536));
    try std.testing.expectEqual(@as(usize, 3), levelsFor(65537));
    try std.testing.expectEqual(@as(usize, 3), levelsFor(16777216));
    try std.testing.expectEqual(@as(usize, 4), levelsFor(16777217));
    try std.testing.expectEqual(@as(f64, 1), stz_gpu_scan_dispatches(100));
    try std.testing.expectEqual(@as(f64, 3), stz_gpu_scan_dispatches(1000));
    try std.testing.expectEqual(@as(f64, 5), stz_gpu_scan_dispatches(100000));
    try std.testing.expectEqual(@as(f64, 0), stz_gpu_scan_dispatches(0));
}
