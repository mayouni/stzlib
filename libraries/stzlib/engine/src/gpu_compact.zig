//! gpu_compact.zig -- GB0's second op: stream compaction on the GPU
//! (SOFTANZA_GPU_PLAN.md, GB0; built on gpu_scan.zig).
//!
//! Keep some of n f32s and pack them, IN ORDER, at the front of an output
//! buffer; say how many were kept. Two ways to say which:
//!   compact        keep in[i] where mask[i] is not 0 (the mask is a device buffer, so a
//!                  kernel, a comparison or another op can have made it)
//!   compact_where  keep in[i] where `in[i] cmp threshold` holds (gt ge lt le eq ne), the mask
//!                  never written out
//!
//! The classic three steps, in ONE submit: FLAGS (1.0 where kept, else 0.0), an EXCLUSIVE SCAN
//! of the flags (the scan of gpu_scan.zig: each kept element's scan value is the place it goes),
//! and a SCATTER (a kept element writes itself at its place; the last thread also writes the
//! count, flags[n-1] + scan[n-1]). The count comes back through a 4-byte buffer: the only read.
//!
//! The scan and the counts are f32, exact for whole numbers below 2^24, so n is limited to
//! 16,777,216 and a larger one is refused by name (TOO_LARGE). Elements past the count are NOT
//! written: the output keeps whatever it held. A NaN compares false with everything but `ne`, and
//! in a mask NaN is not 0, so it keeps its element.
//!
//! Binding contract, the ops family's: @binding(0) tile, @binding(1) params, @binding(2..)
//! buffers in call order; every kernel reads the tile uniform.

const std = @import("std");
const gpu = @import("gpu.zig");
const scan = @import("gpu_scan.zig");

const WG: usize = 256;
pub const MAX_N: usize = 1 << 24;

const PRELUDE =
    \\struct StzTile { xoff : u32, p0 : u32, p1 : u32, p2 : u32 }
    \\@group(0) @binding(0) var<uniform> tile : StzTile;
    \\
;

const CmpParams = extern struct { n: u32, cmp: u32, thr: f32, pad: u32 };

// flags from a mask buffer: 1.0 where it is not 0
const WGSL_FLAGS_MASK = PRELUDE ++
    \\struct P { n : u32, cmp : u32, thr : f32, pad : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> mask : array<f32>;
    \\@group(0) @binding(3) var<storage, read_write> flags : array<f32>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
    \\  let i = gid.x + tile.xoff * 256u;
    \\  if (i >= p.n) { return; }
    \\  flags[i] = select(0.0, 1.0, mask[i] != 0.0);
    \\}
;

// flags from a comparison of the input with a threshold
const WGSL_FLAGS_CMP = PRELUDE ++
    \\struct P { n : u32, cmp : u32, thr : f32, pad : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> src : array<f32>;
    \\@group(0) @binding(3) var<storage, read_write> flags : array<f32>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
    \\  let i = gid.x + tile.xoff * 256u;
    \\  if (i >= p.n) { return; }
    \\  let x = src[i];
    \\  var k = false;
    \\  switch (p.cmp) {
    \\    case 0u: { k = x > p.thr; }
    \\    case 1u: { k = x >= p.thr; }
    \\    case 2u: { k = x < p.thr; }
    \\    case 3u: { k = x <= p.thr; }
    \\    case 4u: { k = x == p.thr; }
    \\    default: { k = x != p.thr; }
    \\  }
    \\  flags[i] = select(0.0, 1.0, k);
    \\}
;

// a kept element writes itself at its scanned place; the last thread writes the count
const WGSL_SCATTER = PRELUDE ++
    \\struct P { n : u32, cmp : u32, thr : f32, pad : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> src : array<f32>;
    \\@group(0) @binding(3) var<storage, read> flags : array<f32>;
    \\@group(0) @binding(4) var<storage, read> pos : array<f32>;
    \\@group(0) @binding(5) var<storage, read_write> outv : array<f32>;
    \\@group(0) @binding(6) var<storage, read_write> cnt : array<f32>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
    \\  let i = gid.x + tile.xoff * 256u;
    \\  if (i >= p.n) { return; }
    \\  if (flags[i] != 0.0) { outv[u32(pos[i])] = src[i]; }
    \\  if (i == p.n - 1u) { cnt[0] = pos[i] + flags[i]; }
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

/// How many dispatches a compaction of n elements makes: the flags, the scan's, the scatter.
pub fn stz_gpu_compact_dispatches(nf: f64) callconv(.c) f64 {
    const n: usize = @intFromFloat(nf);
    if (n == 0) return 0;
    return 2 + scan.stz_gpu_scan_dispatches(nf);
}

fn checkBuf(id: i64, n: usize) i32 {
    const sz = gpu.stz_gpu_buffer_size(id);
    if (sz < 0) return gpu.STALE;
    if (@as(f64, @floatFromInt(n * 4)) > sz) return gpu.BAD_ARG;
    return gpu.OK;
}

// ---------------------------------------------------------------- the scratch
// The flags and the scanned places are two vectors as long as the input: allocating and zeroing
// 128 MB on every call cost more than the whole scan (measured 2026-11-03: 20 ms against 2.6 ms
// at 16,000,000 floats), so they are kept between calls, grown when a larger input comes, freed by
// `stz_gpu_compact_release` or when the device closes (a stale id answers by name anyway).
var sc_flags: i64 = 0;
var sc_pos: i64 = 0;
var sc_cnt: i64 = 0;
var sc_cap: usize = 0; // elements the two vectors hold
var hooked = false;

fn onDeviceClose() void {
    sc_flags = 0;
    sc_pos = 0;
    sc_cnt = 0;
    sc_cap = 0;
}

fn scratchFree() void {
    if (sc_flags != 0) _ = gpu.stz_gpu_buffer_free(sc_flags);
    if (sc_pos != 0) _ = gpu.stz_gpu_buffer_free(sc_pos);
    if (sc_cnt != 0) _ = gpu.stz_gpu_buffer_free(sc_cnt);
    onDeviceClose();
}

fn ensureScratch(n: usize) i32 {
    if (!hooked) {
        gpu.registerDeviceCloseHook(&onDeviceClose);
        hooked = true;
    }
    const live = sc_flags != 0 and gpu.stz_gpu_buffer_size(sc_flags) >= 0 and gpu.stz_gpu_buffer_size(sc_pos) >= 0 and gpu.stz_gpu_buffer_size(sc_cnt) >= 0;
    if (live and sc_cap >= n) return gpu.OK;
    if (live) scratchFree() else onDeviceClose();
    sc_flags = gpu.stz_gpu_buffer_new(@floatFromInt(n * 4));
    sc_pos = gpu.stz_gpu_buffer_new(@floatFromInt(n * 4));
    sc_cnt = gpu.stz_gpu_buffer_new(4);
    if (sc_flags == 0 or sc_pos == 0 or sc_cnt == 0) {
        const dead = gpu.stz_gpu_is_available() == 0;
        scratchFree();
        return if (dead) gpu.FALLBACK else gpu.TOO_LARGE;
    }
    sc_cap = n;
    return gpu.OK;
}

/// Give the scratch back: the two vectors and the count's buffer. The next compaction makes them again.
pub fn stz_gpu_compact_release() callconv(.c) void {
    scratchFree();
}

/// The shared driver. `mask` is 0 for the comparison form.
fn drive(in: i64, mask: i64, out: i64, n: usize, cmp: u32, thr: f32, count: *f64) i32 {
    if (gpu.stz_gpu_is_available() == 0) {
        gpu.countFallback();
        return gpu.FALLBACK;
    }
    if (n == 0) return gpu.BAD_ARG;
    if (n > MAX_N) return gpu.TOO_LARGE;
    if (in == out or (mask != 0 and (mask == out))) return gpu.BAD_ARG;
    var st = checkBuf(in, n);
    if (st != gpu.OK) return st;
    st = checkBuf(out, n);
    if (st != gpu.OK) return st;
    if (mask != 0) {
        st = checkBuf(mask, n);
        if (st != gpu.OK) return st;
    }

    const k_flags = if (mask != 0) compile(WGSL_FLAGS_MASK) else compile(WGSL_FLAGS_CMP);
    const k_scatter = compile(WGSL_SCATTER);
    if (k_flags == 0 or k_scatter == 0) return gpu.GPU_ERROR;

    const sst = ensureScratch(n);
    if (sst != gpu.OK) return sst;
    const flags = sc_flags;
    const pos = sc_pos;
    const cnt = sc_cnt;
    var pl: scan.Plan = .{};
    const pst = scan.planNew(n, &pl);
    if (pst != gpu.OK) return pst;
    defer scan.planFree(&pl);

    const p = CmpParams{ .n = @intCast(n), .cmp = cmp, .thr = thr, .pad = 0 };
    const wx = ceilDiv(n, WG);
    _ = gpu.stz_gpu_batch_begin();
    st = if (mask != 0)
        dispatchP(k_flags, &p, &.{ mask, flags }, wx)
    else
        dispatchP(k_flags, &p, &.{ in, flags }, wx);
    if (st == gpu.OK) st = scan.record(&pl, flags, pos, 1);
    if (st == gpu.OK) st = dispatchP(k_scatter, &p, &.{ in, flags, pos, out, cnt }, wx);
    const st_end = gpu.stz_gpu_batch_end();
    if (st != gpu.OK) return st;
    if (st_end != gpu.OK) return st_end;

    var c: f32 = 0;
    const rst = gpu.stz_gpu_buffer_read(cnt, @ptrCast(&c), 4);
    if (rst != gpu.OK) return rst;
    count.* = @floatCast(c);
    return gpu.OK;
}

/// Keep in[i] where mask[i] is not 0, packed in order at the front of out; the kept count in
/// out_count. in, mask and out are distinct buffers of at least n f32s; out is written only up to
/// the count.
pub fn stz_gpu_op_compact(in: i64, mask: i64, out: i64, nf: f64, out_count: *f64) callconv(.c) i32 {
    const n: usize = @intFromFloat(nf);
    if (mask == 0 or mask == in) return gpu.BAD_ARG;
    return drive(in, mask, out, n, 0, 0, out_count);
}

/// Keep in[i] where `in[i] cmp threshold`; cmp 0 gt, 1 ge, 2 lt, 3 le, 4 eq, 5 ne.
pub fn stz_gpu_op_compact_where(in: i64, out: i64, nf: f64, cmpf: f64, thr: f64, out_count: *f64) callconv(.c) i32 {
    if (cmpf < 0 or cmpf > 5 or cmpf != @floor(cmpf)) return gpu.BAD_ARG;
    const n: usize = @intFromFloat(nf);
    return drive(in, 0, out, n, @intFromFloat(cmpf), @floatCast(thr), out_count);
}

test "a compaction is two passes and a scan" {
    try std.testing.expectEqual(@as(f64, 3), stz_gpu_compact_dispatches(100));
    try std.testing.expectEqual(@as(f64, 5), stz_gpu_compact_dispatches(1000));
    try std.testing.expectEqual(@as(f64, 0), stz_gpu_compact_dispatches(0));
    try std.testing.expectEqual(@as(usize, 16777216), MAX_N);
}
