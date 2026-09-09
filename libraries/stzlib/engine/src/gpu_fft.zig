//! gpu_fft.zig -- GS1's engine half: FFT convolution as an op of the GPU
//! plane (SOFTANZA_GPU_PLAN.md, GS1; SOFTANZA_SOUND_PLAN.md, SN0 criterion #3).
//!
//! SN0 measured the verdict -- 19-23x over fft.zig at 60 s of audio on the
//! 3050, 12.9x on the iGPU, f32 error 1.75e-6 -- and signed "the GPU is IN,
//! for offline batch convolution". No GPU code followed. This is that code,
//! as an op over G1 buffer ids so any plane with a signal on the device can
//! use it, and so the sound desk owes only a route.
//!
//! The algorithm is the spike's: Stockham autosort radix-2 (no bit-reversal
//! pass -- pure scattered traffic on a GPU), ping-ponging between two
//! buffers, one dispatch per stage, both operands transformed, a pointwise
//! complex product, the inverse chain, and the real part scaled by 1/N.
//! Every dispatch of the chain lands in ONE batched pass (G1's batching:
//! 4 + 3*log2(N) dispatches, one submit).
//!
//! ONE THING THE SPIKE DID NOT DO, on purpose here: twiddles come from an
//! UPLOADED TABLE computed in f64, not from cos/sin per butterfly. SN0
//! measured the iGPU's transcendentals 16x worse (2.75e-5, above a 16-bit
//! noise floor) and named the table as the prerequisite for any reverb
//! render there. The table is built once per transform size per device and
//! cached (one entry: the size a render uses is the size it keeps using).
//!
//! Binding contract, the ops family's: @binding(0) tile, @binding(1) params,
//! @binding(2..) buffers in call order. Every kernel READS the tile uniform:
//! a declared-but-unread binding is dropped by layout:auto and invalidates
//! the bind group (paid for once, in the backbone).

const std = @import("std");
const gpu = @import("gpu.zig");

const alloc = std.heap.c_allocator;
const WG: usize = 256;

const PRELUDE =
    \\struct StzTile { xoff : u32, p0 : u32, p1 : u32, p2 : u32 }
    \\@group(0) @binding(0) var<uniform> tile : StzTile;
    \\
;

// real f32 -> complex (re, 0), zero-padded to m
const WGSL_PACK = PRELUDE ++
    \\struct P { n : u32, m : u32, p1 : u32, p2 : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> src : array<f32>;
    \\@group(0) @binding(3) var<storage, read_write> dst : array<vec2<f32>>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
    \\  let i = gid.x + tile.xoff * 256u;
    \\  if (i >= p.m) { return; }
    \\  var x = 0.0;
    \\  if (i < p.n) { x = src[i]; }
    \\  dst[i] = vec2<f32>(x, 0.0);
    \\}
;

// one Stockham stage; tw[k] = exp(-i*pi*k/half); sign +1 forward, -1 inverse
const WGSL_STAGE = PRELUDE ++
    \\struct P { n : u32, ns : u32, sign : f32, pad : f32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> src : array<vec2<f32>>;
    \\@group(0) @binding(3) var<storage, read_write> dst : array<vec2<f32>>;
    \\@group(0) @binding(4) var<storage, read> tw : array<vec2<f32>>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
    \\  let t = gid.x + tile.xoff * 256u;
    \\  let half = p.n >> 1u;
    \\  if (t >= half) { return; }
    \\  let ns = p.ns;
    \\  let j = t & (ns - 1u);
    \\  let base = (t - j) << 1u;
    \\  let a = src[t];
    \\  let b = src[t + half];
    \\  let w0 = tw[j * (half / ns)];
    \\  let w = vec2<f32>(w0.x, p.sign * w0.y);
    \\  let bw = vec2<f32>(b.x * w.x - b.y * w.y, b.x * w.y + b.y * w.x);
    \\  dst[base + j] = a + bw;
    \\  dst[base + j + ns] = a - bw;
    \\}
;

// pointwise complex product, a <- a * b
const WGSL_CMUL = PRELUDE ++
    \\struct P { n : u32, p0 : u32, p1 : u32, p2 : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> b : array<vec2<f32>>;
    \\@group(0) @binding(3) var<storage, read_write> a : array<vec2<f32>>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
    \\  let i = gid.x + tile.xoff * 256u;
    \\  if (i >= p.n) { return; }
    \\  let x = a[i];
    \\  let y = b[i];
    \\  a[i] = vec2<f32>(x.x * y.x - x.y * y.y, x.x * y.y + x.y * y.x);
    \\}
;

// the real part, scaled, for the first nout samples
const WGSL_UNPACK = PRELUDE ++
    \\struct P { nout : u32, pad : u32, scale : f32, pad2 : f32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> src : array<vec2<f32>>;
    \\@group(0) @binding(3) var<storage, read_write> out : array<f32>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
    \\  let i = gid.x + tile.xoff * 256u;
    \\  if (i >= p.nout) { return; }
    \\  out[i] = src[i].x * p.scale;
    \\}
;

const PackParams = extern struct { n: u32, m: u32, p1: u32, p2: u32 };
const StageParams = extern struct { n: u32, ns: u32, sign: f32, pad: f32 };
const CmulParams = extern struct { n: u32, p0: u32, p1: u32, p2: u32 };
const UnpackParams = extern struct { nout: u32, pad: u32, scale: f32, pad2: f32 };

fn ceilDiv(a: usize, b: usize) usize {
    return (a + b - 1) / b;
}

fn nextPow2(n: usize) usize {
    var m: usize = 2;
    while (m < n) m <<= 1;
    return m;
}

fn log2int(m: usize) u32 {
    var s: u32 = 0;
    var v = m;
    while (v > 1) : (v >>= 1) s += 1;
    return s;
}

fn compile(text: []const u8) i64 {
    return gpu.stz_gpu_kernel_compile(text.ptr, @floatFromInt(text.len));
}

fn dispatchP(kernel: i64, params: anytype, bufs: []const i64, wx: usize) i32 {
    const bytes = std.mem.asBytes(params);
    return gpu.stz_gpu_dispatch_params(kernel, bytes.ptr, @floatFromInt(bytes.len), bufs.ptr, @intCast(bufs.len), @floatFromInt(wx), 1);
}

// ---------------------------------------------------------------- the twiddle table
var tw_id: i64 = 0;
var tw_m: usize = 0;
var hooked = false;

fn onDeviceClose() void {
    tw_id = 0;
    tw_m = 0;
}

/// exp(-i*pi*k/half) for k in [0, half), computed in f64, held as f32 on the
/// device. One cached entry: freed and rebuilt when the size changes, and
/// forgotten when the device closes (a stale id answers by name anyway).
fn ensureTwiddles(m: usize) i64 {
    if (!hooked) {
        gpu.registerDeviceCloseHook(&onDeviceClose);
        hooked = true;
    }
    if (tw_m == m and tw_id != 0 and gpu.stz_gpu_buffer_size(tw_id) >= 0) return tw_id;
    if (tw_id != 0) _ = gpu.stz_gpu_buffer_free(tw_id);
    tw_id = 0;
    tw_m = 0;
    const half = m / 2;
    const host = alloc.alloc(f32, half * 2) catch return 0;
    defer alloc.free(host);
    for (0..half) |k| {
        const ang: f64 = -std.math.pi * @as(f64, @floatFromInt(k)) / @as(f64, @floatFromInt(half));
        host[2 * k] = @floatCast(@cos(ang));
        host[2 * k + 1] = @floatCast(@sin(ang));
    }
    const id = gpu.stz_gpu_buffer_new(@floatFromInt(half * 8));
    if (id == 0) return 0;
    if (gpu.stz_gpu_buffer_write(id, @ptrCast(host.ptr), @floatFromInt(half * 8)) != gpu.OK) {
        _ = gpu.stz_gpu_buffer_free(id);
        return 0;
    }
    tw_id = id;
    tw_m = m;
    return id;
}

/// The transform size the op will use for na + nb - 1 samples (a guard's
/// witness for the dispatch count: 4 + 3 * log2(size)).
pub fn stz_gpu_convolve_size(naf: f64, nbf: f64) callconv(.c) f64 {
    const na: usize = @intFromFloat(naf);
    const nb: usize = @intFromFloat(nbf);
    if (na == 0 or nb == 0) return 0;
    return @floatFromInt(nextPow2(na + nb - 1));
}

/// out[0 .. na+nb-1) = the linear convolution of a[0..na) and b[0..nb), all
/// f32 device buffers. Submits one batched pass and returns; the caller's
/// readback (or Sync) establishes completion -- the residency law.
pub fn stz_gpu_op_convolve_real(a: i64, naf: f64, b: i64, nbf: f64, out: i64) callconv(.c) i32 {
    if (gpu.stz_gpu_is_available() == 0) {
        gpu.countFallback();
        return gpu.FALLBACK;
    }
    const na: usize = @intFromFloat(naf);
    const nb: usize = @intFromFloat(nbf);
    if (na == 0 or nb == 0) return gpu.BAD_ARG;
    const need = na + nb - 1;
    const m = nextPow2(need);
    const stages = log2int(m);
    if (gpu.stz_gpu_buffer_size(a) < @as(f64, @floatFromInt(na * 4))) return gpu.BAD_ARG;
    if (gpu.stz_gpu_buffer_size(b) < @as(f64, @floatFromInt(nb * 4))) return gpu.BAD_ARG;
    if (gpu.stz_gpu_buffer_size(out) < @as(f64, @floatFromInt(need * 4))) return gpu.BAD_ARG;

    const k_pack = compile(WGSL_PACK);
    const k_stage = compile(WGSL_STAGE);
    const k_cmul = compile(WGSL_CMUL);
    const k_unpack = compile(WGSL_UNPACK);
    if (k_pack == 0 or k_stage == 0 or k_cmul == 0 or k_unpack == 0) return gpu.GPU_ERROR;
    const tw = ensureTwiddles(m);
    if (tw == 0) return gpu.GPU_ERROR;

    const bytes: f64 = @floatFromInt(m * 8);
    const work = [_]i64{ gpu.stz_gpu_buffer_new(bytes), gpu.stz_gpu_buffer_new(bytes), gpu.stz_gpu_buffer_new(bytes), gpu.stz_gpu_buffer_new(bytes) };
    defer {
        for (work) |id| {
            if (id != 0) _ = gpu.stz_gpu_buffer_free(id);
        }
    }
    for (work) |id| if (id == 0) return gpu.GPU_ERROR;
    const a0 = work[0];
    const a1 = work[1];
    const b0 = work[2];
    const b1 = work[3];

    const wx_full = ceilDiv(m, WG);
    const wx_half = ceilDiv(m / 2, WG);

    _ = gpu.stz_gpu_batch_begin();
    var st: i32 = gpu.OK;
    st = dispatchP(k_pack, &PackParams{ .n = @intCast(na), .m = @intCast(m), .p1 = 0, .p2 = 0 }, &.{ a, a0 }, wx_full);
    if (st == gpu.OK) st = dispatchP(k_pack, &PackParams{ .n = @intCast(nb), .m = @intCast(m), .p1 = 0, .p2 = 0 }, &.{ b, b0 }, wx_full);

    // forward chains, both operands
    var ns: u32 = 1;
    var s: usize = 0;
    while (st == gpu.OK and s < stages) : (s += 1) {
        const src_a = if (s % 2 == 0) a0 else a1;
        const dst_a = if (s % 2 == 0) a1 else a0;
        const src_b = if (s % 2 == 0) b0 else b1;
        const dst_b = if (s % 2 == 0) b1 else b0;
        const pf = StageParams{ .n = @intCast(m), .ns = ns, .sign = 1.0, .pad = 0 };
        st = dispatchP(k_stage, &pf, &.{ src_a, dst_a, tw }, wx_half);
        if (st == gpu.OK) st = dispatchP(k_stage, &pf, &.{ src_b, dst_b, tw }, wx_half);
        ns <<= 1;
    }
    // the spectra sit in a0/b0 iff the stage count is even
    const spec_a = if (stages % 2 == 0) a0 else a1;
    const spec_b = if (stages % 2 == 0) b0 else b1;
    if (st == gpu.OK) st = dispatchP(k_cmul, &CmulParams{ .n = @intCast(m), .p0 = 0, .p1 = 0, .p2 = 0 }, &.{ spec_b, spec_a }, wx_full);

    // the inverse chain starts where the product sits and, phase-shifted by
    // stages % 2, lands in a0 for either parity (the spike's lesson, kept)
    ns = 1;
    s = 0;
    while (st == gpu.OK and s < stages) : (s += 1) {
        const isrc = if ((stages + s) % 2 == 0) a0 else a1;
        const idst = if ((stages + s) % 2 == 0) a1 else a0;
        const pi = StageParams{ .n = @intCast(m), .ns = ns, .sign = -1.0, .pad = 0 };
        st = dispatchP(k_stage, &pi, &.{ isrc, idst, tw }, wx_half);
        ns <<= 1;
    }
    if (st == gpu.OK) st = dispatchP(k_unpack, &UnpackParams{ .nout = @intCast(need), .pad = 0, .scale = 1.0 / @as(f32, @floatFromInt(m)), .pad2 = 0 }, &.{ a0, out }, wx_full);
    const st_end = gpu.stz_gpu_batch_end();
    if (st != gpu.OK) return st;
    if (st_end != gpu.OK) return st_end;
    // the work buffers are freed by the defer: the submitted pass holds its
    // own references device-side (the same rule the faces rely on)
    return gpu.OK;
}

test "transform sizes and stage counts" {
    try std.testing.expectEqual(@as(usize, 4), nextPow2(4));
    try std.testing.expectEqual(@as(usize, 8), nextPow2(5));
    try std.testing.expectEqual(@as(usize, 131072), nextPow2(48000 + 48000 - 1));
    try std.testing.expectEqual(@as(u32, 17), log2int(131072));
    try std.testing.expectEqual(@as(f64, 4194304), stz_gpu_convolve_size(2880000, 48000));
}
