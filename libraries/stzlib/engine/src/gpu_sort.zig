//! gpu_sort.zig -- GB0's third op: the radix sort on the GPU
//! (SOFTANZA_GPU_PLAN.md, GB0; built on gpu_scan.zig, as compaction is).
//!
//! Sort n f32 keys ascending or descending, STABLY, with the values that follow
//! them (a key-value sort) or the permutation that sorts them (an argsort), all
//! on the device: nothing comes back until the caller asks for the output.
//!
//! Least-significant-digit radix sort, four bits a digit, eight passes. The
//! f32 key is first turned into an unsigned integer that orders like the float
//! (flip every bit of a negative, only the sign bit of a positive; descending
//! flips them all once more), and turned back at the end. One pass:
//!   LOCAL    a group of 256 sorts its 256 keys by the digit in shared memory,
//!            four stable one-bit splits (each a scan of the "bit is 0" flags),
//!            in place, and writes how many keys of each digit it holds and
//!            where each digit starts in it (two 16-entry columns of a table
//!            laid out digit-major: entry digit * blocks + group);
//!   SCAN     an exclusive scan of that table (the scan of gpu_scan.zig) says
//!            where each group's run of each digit lands in the whole output:
//!            every smaller digit of every group, then this digit of every
//!            earlier group;
//!   SCATTER  every key writes itself at its group's offset for its digit plus
//!            its place among that digit's keys in the group.
//! Stability is the order of the table and of the splits: equal keys keep their
//! places. A last, short block is padded with the largest key, which sorts to
//! its end and lands past n, so nothing real is displaced.
//!
//! Eight passes is even, so the sorted keys end up in the buffer they began in,
//! and a pass costs 2 + (2 * levels - 1) dispatches for a table of 16 * blocks
//! entries; the whole sort is one batched submit. The tables and the two
//! ping-pong vectors are kept between calls, as compaction keeps its scratch,
//! and given back by `stz_gpu_sort_release`.
//!
//! What it does with the awkward floats: the order is the order of the
//! transformed bits, so -0 sorts before +0 (they compare equal as values but
//! the sort tells them apart and keeps -0 first), a positive NaN sorts after
//! +inf and a negative NaN before -inf. The scan and the tables are f32,
//! exact below 2^24, so n is limited to 16,777,216 and a larger one is refused
//! by name (TOO_LARGE). In an argsort the indices are f32, exact to the same
//! bound.
//!
//! Binding contract, the ops family's: @binding(0) tile, @binding(1) params,
//! @binding(2..) buffers in call order; every kernel reads the tile uniform. A
//! keys-only sort binds two 4-byte stand-ins where the values would go, and
//! never touches them.

const std = @import("std");
const gpu = @import("gpu.zig");
const scan = @import("gpu_scan.zig");

const WG: usize = 256;
const BINS: usize = 16;
const PASSES: usize = 8;
pub const MAX_N: usize = 1 << 24;

const PRELUDE =
    \\struct StzTile { xoff : u32, p0 : u32, p1 : u32, p2 : u32 }
    \\@group(0) @binding(0) var<uniform> tile : StzTile;
    \\
;

const SortParams = extern struct { n: u32, a: u32, b: u32, c: u32 };

// keys -> orderable unsigned integers into X; the values follow (mode 1) or become the index (mode 2)
const WGSL_PREP = PRELUDE ++
    \\struct P { n : u32, desc : u32, mode : u32, c : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> kin : array<u32>;
    \\@group(0) @binding(3) var<storage, read> vin : array<f32>;
    \\@group(0) @binding(4) var<storage, read_write> xk : array<u32>;
    \\@group(0) @binding(5) var<storage, read_write> xv : array<f32>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
    \\  let i = gid.x + tile.xoff * 256u;
    \\  if (i >= p.n) { return; }
    \\  let u = kin[i];
    \\  var o = u ^ select(0x80000000u, 0xFFFFFFFFu, (u >> 31u) == 1u);
    \\  if (p.desc == 1u) { o = ~o; }
    \\  xk[i] = o;
    \\  if (p.mode == 1u) { xv[i] = vin[i]; }
    \\  if (p.mode == 2u) { xv[i] = f32(i); }
    \\}
;

// one pass, phase one: a group sorts its keys by the digit, in place, and counts the digits
const WGSL_LOCAL = PRELUDE ++
    \\struct P { n : u32, shift : u32, nb : u32, pairs : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read_write> xk : array<u32>;
    \\@group(0) @binding(3) var<storage, read_write> xv : array<f32>;
    \\@group(0) @binding(4) var<storage, read_write> counts : array<f32>;
    \\@group(0) @binding(5) var<storage, read_write> starts : array<f32>;
    \\var<workgroup> ka : array<u32, 256>;
    \\var<workgroup> kb : array<u32, 256>;
    \\var<workgroup> va : array<f32, 256>;
    \\var<workgroup> sc : array<u32, 256>;
    \\var<workgroup> st : array<u32, 16>;
    \\var<workgroup> en : array<u32, 16>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(local_invocation_id) lid : vec3<u32>,
    \\        @builtin(workgroup_id) wid : vec3<u32>) {
    \\  let l = lid.x;
    \\  let g = wid.x + tile.xoff;
    \\  let i = g * 256u + l;
    \\  var k = 0xFFFFFFFFu;
    \\  var v = 0.0;
    \\  if (i < p.n) {
    \\    k = xk[i];
    \\    if (p.pairs == 1u) { v = xv[i]; }
    \\  }
    \\  for (var b = 0u; b < 4u; b = b + 1u) {
    \\    let f = select(0u, 1u, ((k >> (p.shift + b)) & 1u) == 0u);
    \\    sc[l] = f;
    \\    workgroupBarrier();
    \\    for (var s = 1u; s < 256u; s = s << 1u) {
    \\      var t = sc[l];
    \\      if (l >= s) { t = t + sc[l - s]; }
    \\      workgroupBarrier();
    \\      sc[l] = t;
    \\      workgroupBarrier();
    \\    }
    \\    let tz = sc[255];
    \\    let ex = sc[l] - f;
    \\    let dst = select(tz + l - ex, ex, f == 1u);
    \\    workgroupBarrier();
    \\    kb[dst] = k;
    \\    if (p.pairs == 1u) { va[dst] = v; }
    \\    workgroupBarrier();
    \\    k = kb[l];
    \\    if (p.pairs == 1u) { v = va[l]; }
    \\    workgroupBarrier();
    \\  }
    \\  if (l < 16u) { st[l] = 0u; en[l] = 0u; }
    \\  ka[l] = k;
    \\  workgroupBarrier();
    \\  let d = (k >> p.shift) & 15u;
    \\  var dprev = 99u;
    \\  if (l > 0u) { dprev = (ka[l - 1u] >> p.shift) & 15u; }
    \\  var dnext = 99u;
    \\  if (l < 255u) { dnext = (ka[l + 1u] >> p.shift) & 15u; }
    \\  if (d != dprev) { st[d] = l; }
    \\  if (d != dnext) { en[d] = l + 1u; }
    \\  workgroupBarrier();
    \\  if (l < 16u) {
    \\    counts[l * p.nb + g] = f32(en[l] - st[l]);
    \\    starts[l * p.nb + g] = f32(st[l]);
    \\  }
    \\  if (i < p.n) {
    \\    xk[i] = k;
    \\    if (p.pairs == 1u) { xv[i] = v; }
    \\  }
    \\}
;

// one pass, phase three: every key lands at its group's offset for its digit plus its place in the group's run
const WGSL_SCATTER = PRELUDE ++
    \\struct P { n : u32, shift : u32, nb : u32, pairs : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> xk : array<u32>;
    \\@group(0) @binding(3) var<storage, read> xv : array<f32>;
    \\@group(0) @binding(4) var<storage, read> offs : array<f32>;
    \\@group(0) @binding(5) var<storage, read> starts : array<f32>;
    \\@group(0) @binding(6) var<storage, read_write> yk : array<u32>;
    \\@group(0) @binding(7) var<storage, read_write> yv : array<f32>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
    \\  let i = gid.x + tile.xoff * 256u;
    \\  if (i >= p.n) { return; }
    \\  let g = i / 256u;
    \\  let l = i % 256u;
    \\  let k = xk[i];
    \\  let d = (k >> p.shift) & 15u;
    \\  let dest = u32(offs[d * p.nb + g]) + l - u32(starts[d * p.nb + g]);
    \\  yk[dest] = k;
    \\  if (p.pairs == 1u) { yv[dest] = xv[i]; }
    \\}
;

// orderable integers back to floats; the keys out (modes 0, 1), the values out (modes 1, 2)
const WGSL_FINISH = PRELUDE ++
    \\struct P { n : u32, desc : u32, mode : u32, c : u32 }
    \\@group(0) @binding(1) var<uniform> p : P;
    \\@group(0) @binding(2) var<storage, read> xk : array<u32>;
    \\@group(0) @binding(3) var<storage, read> xv : array<f32>;
    \\@group(0) @binding(4) var<storage, read_write> ok : array<u32>;
    \\@group(0) @binding(5) var<storage, read_write> ov : array<f32>;
    \\@compute @workgroup_size(256)
    \\fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
    \\  let i = gid.x + tile.xoff * 256u;
    \\  if (i >= p.n) { return; }
    \\  var o = xk[i];
    \\  if (p.desc == 1u) { o = ~o; }
    \\  if (p.mode != 2u) { ok[i] = o ^ select(0xFFFFFFFFu, 0x80000000u, (o >> 31u) == 1u); }
    \\  if (p.mode != 0u) { ov[i] = xv[i]; }
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

/// The key a float becomes: an unsigned integer ordered like the float, ascending or descending.
pub fn orderable(bits: u32, desc: bool) u32 {
    const o = bits ^ (if (bits >> 31 == 1) @as(u32, 0xFFFFFFFF) else @as(u32, 0x80000000));
    return if (desc) ~o else o;
}

/// The float bits a key came from.
pub fn unorderable(key: u32, desc: bool) u32 {
    const o = if (desc) ~key else key;
    return o ^ (if (o >> 31 == 1) @as(u32, 0x80000000) else @as(u32, 0xFFFFFFFF));
}

/// How many dispatches a sort of n elements makes: the keys in, eight passes of a local sort, a
/// scan of the table and a scatter, and the keys out.
pub fn stz_gpu_sort_dispatches(nf: f64) callconv(.c) f64 {
    const n: usize = @intFromFloat(nf);
    if (n == 0) return 0;
    const table: f64 = @floatFromInt(BINS * ceilDiv(n, WG));
    return 2 + @as(f64, PASSES) * (2 + scan.stz_gpu_scan_dispatches(table));
}

// ---------------------------------------------------------------- the scratch
// Two ping-pong vectors of keys and of values, three tables of 16 * blocks entries, and two stand-ins
// for the values of a keys-only sort. Kept between calls, grown when a larger input comes (or when a
// keys-and-values sort follows a keys-only one), freed by `stz_gpu_sort_release` or when the device closes.
var sc_xk: i64 = 0;
var sc_yk: i64 = 0;
var sc_xv: i64 = 0;
var sc_yv: i64 = 0;
var sc_counts: i64 = 0;
var sc_starts: i64 = 0;
var sc_offs: i64 = 0;
var sc_cap: usize = 0; // elements the vectors hold
var sc_pairs: bool = false; // whether the value vectors are real
var hooked = false;

fn onDeviceClose() void {
    sc_xk = 0;
    sc_yk = 0;
    sc_xv = 0;
    sc_yv = 0;
    sc_counts = 0;
    sc_starts = 0;
    sc_offs = 0;
    sc_cap = 0;
    sc_pairs = false;
}

fn scratchFree() void {
    for ([_]i64{ sc_xk, sc_yk, sc_xv, sc_yv, sc_counts, sc_starts, sc_offs }) |id| {
        if (id != 0) _ = gpu.stz_gpu_buffer_free(id);
    }
    onDeviceClose();
}

fn alive(id: i64) bool {
    return id != 0 and gpu.stz_gpu_buffer_size(id) >= 0;
}

fn ensureScratch(n: usize, pairs: bool) i32 {
    if (!hooked) {
        gpu.registerDeviceCloseHook(&onDeviceClose);
        hooked = true;
    }
    const live = alive(sc_xk) and alive(sc_yk) and alive(sc_xv) and alive(sc_yv) and alive(sc_counts) and alive(sc_starts) and alive(sc_offs);
    if (live and sc_cap >= n and (sc_pairs or !pairs)) return gpu.OK;
    if (live) scratchFree() else onDeviceClose();
    const vbytes: f64 = if (pairs) @floatFromInt(n * 4) else 4;
    const tbytes: f64 = @floatFromInt(BINS * ceilDiv(n, WG) * 4);
    sc_xk = gpu.stz_gpu_buffer_new(@floatFromInt(n * 4));
    sc_yk = gpu.stz_gpu_buffer_new(@floatFromInt(n * 4));
    sc_xv = gpu.stz_gpu_buffer_new(vbytes);
    sc_yv = gpu.stz_gpu_buffer_new(vbytes);
    sc_counts = gpu.stz_gpu_buffer_new(tbytes);
    sc_starts = gpu.stz_gpu_buffer_new(tbytes);
    sc_offs = gpu.stz_gpu_buffer_new(tbytes);
    if (!(alive(sc_xk) and alive(sc_yk) and alive(sc_xv) and alive(sc_yv) and alive(sc_counts) and alive(sc_starts) and alive(sc_offs))) {
        const dead = gpu.stz_gpu_is_available() == 0;
        scratchFree();
        return if (dead) gpu.FALLBACK else gpu.TOO_LARGE;
    }
    sc_cap = n;
    sc_pairs = pairs;
    return gpu.OK;
}

/// Give the scratch back. The next sort makes it again.
pub fn stz_gpu_sort_release() callconv(.c) void {
    scratchFree();
}

fn checkBuf(id: i64, n: usize) i32 {
    const sz = gpu.stz_gpu_buffer_size(id);
    if (sz < 0) return gpu.STALE;
    if (@as(f64, @floatFromInt(n * 4)) > sz) return gpu.BAD_ARG;
    return gpu.OK;
}

const Mode = enum(u32) { keys = 0, pairs = 1, arg = 2 };

/// The shared driver. kin: the keys; vin: the values of a pairs sort (else 0); ok / ov: the outputs
/// (ok is 0 for an argsort, ov is 0 for a keys-only sort).
fn drive(mode: Mode, kin: i64, vin: i64, ok: i64, ov: i64, n: usize, desc: bool) i32 {
    if (gpu.stz_gpu_is_available() == 0) {
        gpu.countFallback();
        return gpu.FALLBACK;
    }
    if (n == 0) return gpu.BAD_ARG;
    if (n > MAX_N) return gpu.TOO_LARGE;
    // every buffer the caller names must be a different one: WebGPU forbids a buffer read and written in one dispatch
    const ids = [_]i64{ kin, vin, ok, ov };
    for (ids, 0..) |a, i| {
        if (a == 0) continue;
        for (ids[i + 1 ..]) |b| {
            if (b != 0 and a == b) return gpu.BAD_ARG;
        }
    }
    var st = checkBuf(kin, n);
    if (st != gpu.OK) return st;
    if (vin != 0) {
        st = checkBuf(vin, n);
        if (st != gpu.OK) return st;
    }
    if (ok != 0) {
        st = checkBuf(ok, n);
        if (st != gpu.OK) return st;
    }
    if (ov != 0) {
        st = checkBuf(ov, n);
        if (st != gpu.OK) return st;
    }

    const k_prep = compile(WGSL_PREP);
    const k_local = compile(WGSL_LOCAL);
    const k_scatter = compile(WGSL_SCATTER);
    const k_finish = compile(WGSL_FINISH);
    if (k_prep == 0 or k_local == 0 or k_scatter == 0 or k_finish == 0) return gpu.GPU_ERROR;

    const pairs = mode != .keys;
    const sst = ensureScratch(n, pairs);
    if (sst != gpu.OK) return sst;
    const nb = ceilDiv(n, WG);
    const table = BINS * nb;
    var pl: scan.Plan = .{};
    const pst = scan.planNew(table, &pl);
    if (pst != gpu.OK) return pst;
    defer scan.planFree(&pl);
    // stand-ins for the buffers a mode does not use, distinct from each other and from everything else
    var dummy: [2]i64 = .{ 0, 0 };
    defer {
        for (dummy) |id| {
            if (id != 0) _ = gpu.stz_gpu_buffer_free(id);
        }
    }
    const need_dummy = (vin == 0) or (ok == 0) or (ov == 0);
    if (need_dummy) {
        dummy[0] = gpu.stz_gpu_buffer_new(4);
        dummy[1] = gpu.stz_gpu_buffer_new(4);
        if (dummy[0] == 0 or dummy[1] == 0) return gpu.TOO_LARGE;
    }
    const in_v = if (vin != 0) vin else dummy[0];
    const out_k = if (ok != 0) ok else dummy[0];
    const out_v = if (ov != 0) ov else dummy[1];

    const wx = ceilDiv(n, WG);
    const p0 = SortParams{ .n = @intCast(n), .a = @intFromBool(desc), .b = @intFromEnum(mode), .c = 0 };
    _ = gpu.stz_gpu_batch_begin();
    st = dispatchP(k_prep, &p0, &.{ kin, in_v, sc_xk, sc_xv }, wx);
    var pass: usize = 0;
    while (st == gpu.OK and pass < PASSES) : (pass += 1) {
        const src_k = if (pass % 2 == 0) sc_xk else sc_yk;
        const dst_k = if (pass % 2 == 0) sc_yk else sc_xk;
        const src_v = if (pass % 2 == 0) sc_xv else sc_yv;
        const dst_v = if (pass % 2 == 0) sc_yv else sc_xv;
        const pp = SortParams{ .n = @intCast(n), .a = @intCast(4 * pass), .b = @intCast(nb), .c = @intFromBool(pairs) };
        st = dispatchP(k_local, &pp, &.{ src_k, src_v, sc_counts, sc_starts }, wx);
        if (st == gpu.OK) st = scan.record(&pl, sc_counts, sc_offs, 1);
        if (st == gpu.OK) st = dispatchP(k_scatter, &pp, &.{ src_k, src_v, sc_offs, sc_starts, dst_k, dst_v }, wx);
    }
    // eight passes is even: the sorted keys are back in the buffer they began in
    if (st == gpu.OK) st = dispatchP(k_finish, &p0, &.{ sc_xk, sc_xv, out_k, out_v }, wx);
    const st_end = gpu.stz_gpu_batch_end();
    if (st != gpu.OK) return st;
    return st_end;
}

/// out = the n keys of in, sorted (ascending, or descending when desc is not 0), stably.
pub fn stz_gpu_op_sort(in: i64, out: i64, nf: f64, descf: f64) callconv(.c) i32 {
    if (out == 0 or in == 0) return gpu.BAD_ARG;
    return drive(.keys, in, 0, out, 0, @intFromFloat(nf), descf != 0);
}

/// The keys sorted into out_keys and each value carried with its key into out_vals.
pub fn stz_gpu_op_sort_pairs(keys: i64, vals: i64, out_keys: i64, out_vals: i64, nf: f64, descf: f64) callconv(.c) i32 {
    if (keys == 0 or vals == 0 or out_keys == 0 or out_vals == 0) return gpu.BAD_ARG;
    return drive(.pairs, keys, vals, out_keys, out_vals, @intFromFloat(nf), descf != 0);
}

/// out_idx[k] = the 0-based place in `keys` of the k-th smallest (largest) key, ties in their original order.
pub fn stz_gpu_op_argsort(keys: i64, out_idx: i64, nf: f64, descf: f64) callconv(.c) i32 {
    if (keys == 0 or out_idx == 0) return gpu.BAD_ARG;
    return drive(.arg, keys, 0, 0, out_idx, @intFromFloat(nf), descf != 0);
}

test "the orderable key orders like the float, and turns back" {
    const f = [_]f32{ -std.math.inf(f32), -3.5, -1.0, -std.math.floatMin(f32), -0.0, 0.0, std.math.floatMin(f32), 1.0, 2.5, std.math.inf(f32) };
    for (f[0 .. f.len - 1], f[1..]) |a, b| {
        const ka = orderable(@bitCast(a), false);
        const kb = orderable(@bitCast(b), false);
        try std.testing.expect(ka < kb);
        // descending reverses it
        try std.testing.expect(orderable(@bitCast(a), true) > orderable(@bitCast(b), true));
    }
    for (f) |x| {
        try std.testing.expectEqual(@as(u32, @bitCast(x)), unorderable(orderable(@bitCast(x), false), false));
        try std.testing.expectEqual(@as(u32, @bitCast(x)), unorderable(orderable(@bitCast(x), true), true));
    }
    // a positive NaN after +inf, a negative NaN before -inf
    const pnan: u32 = 0x7FC00000;
    const nnan: u32 = 0xFFC00000;
    try std.testing.expect(orderable(pnan, false) > orderable(@bitCast(std.math.inf(f32)), false));
    try std.testing.expect(orderable(nnan, false) < orderable(@bitCast(-std.math.inf(f32)), false));
}

test "a sort is a handful of passes" {
    try std.testing.expectEqual(@as(f64, 0), stz_gpu_sort_dispatches(0));
    // 1 block: a table of 16 entries scans in 1 dispatch: 2 + 8 * 3
    try std.testing.expectEqual(@as(f64, 26), stz_gpu_sort_dispatches(100));
    // 16 blocks: still 1 dispatch of scan; 17 blocks: a table of 272, two levels, 3 dispatches
    try std.testing.expectEqual(@as(f64, 26), stz_gpu_sort_dispatches(16 * 256));
    try std.testing.expectEqual(@as(f64, 2 + 8 * 5), stz_gpu_sort_dispatches(17 * 256));
}
