//! gpu_host.zig -- THE HOST CONTRACT, NUMBERS (GL0, 2026-11-03;
//! base/gpu/SOFTANZA_GPU_HOST_CONTRACT.md is the account for a host's author).
//!
//! A GPU kernel written in the spec language is run by a HOST: the checker in
//! this engine, the Ring face, the browser page, and any host a language
//! written later will have (Haro's). The engine compiles and transpiles; the
//! host owns buffers and dispatch, which are the platform's. Between the two
//! lay a handful of NUMBERS every host used to derive for itself -- the NaN
//! margin, the workgroup count, the hidden shape's size and data, the default
//! band -- and they existed four times (the face twice, the puzzle grader, the
//! page). A copy that drifts is a verdict that differs between hosts. They
//! are defined once, here, and every host asks.
//!
//! Pure: no state, no device, no spec. What depends on a compiled description
//! (a buffer's floats per element, the output's length) is in gpu_wgsl.zig,
//! beside the declarations it reads.

const std = @import("std");

/// Bump when a number or a rule below changes, so a host can refuse an engine
/// that means something else than the document it was written from.
pub const VERSION: u32 = 1;

/// Threads in a group: the transpiler writes @workgroup_size(256) and a width
/// kernel's tile is 16 x 16.
pub const GROUP: usize = 256;
/// Floats of NaN after the output's region. Anything there that is not NaN
/// afterwards was written past the region: "write-outside at element K".
pub const MARGIN: usize = 256;
/// The checker's default allowed difference per element, and its timed repetitions.
pub const DEFAULT_BAND: f64 = 0.000001;
pub const DEFAULT_REPS: usize = 7;
/// The params uniform: a u32 n, a u32 pad, then each scalar as an f32, in the
/// order the description declares them; 64 bytes at most (14 scalars).
pub const PARAMS_HEAD: usize = 8;
pub const PARAMS_MAX: usize = 64;

/// Workgroups to run n elements: one thread each, GROUP to a group.
pub fn groups(n: usize) usize {
    return (n + GROUP - 1) / GROUP;
}

/// The hidden shape's element count for a visible n: five sevenths, at least
/// one, and ODD when above one -- a count that is not a multiple of any tile,
/// so a kernel that hard-codes the visible shape's size fails here.
pub fn hiddenCount(n: usize) usize {
    var b = n * 5 / 7;
    if (b < 1) b = 1;
    if (b > 1 and b % 2 == 0) b -= 1;
    return b;
}

/// How many elements of an input of `len` the hidden shape (nb of n) keeps.
pub fn hiddenLen(len: usize, n: usize, nb: usize) usize {
    if (n == 0) return 1;
    const h = len * nb / n;
    return if (h < 1) 1 else h;
}

/// The hidden shape's input: the TAIL of the visible one, REVERSED, element by
/// element -- an element of a vecN input is its N floats, kept in order. A
/// permutation, so every value stays inside the kernel's domain, and a kernel
/// that answers the visible fixture by position (out[i] = f(i), not f(a[i]))
/// answers wrong here. `src` holds src.len / w elements. Returns the floats
/// written, dst needing hiddenLen(...) * w.
pub fn hiddenInput(src: []const f32, w: usize, n: usize, nb: usize, dst: []f32) usize {
    if (w == 0) return 0;
    const len = src.len / w;
    const hl = hiddenLen(len, n, nb);
    if (dst.len < hl * w) return 0;
    for (0..hl) |j| {
        const e = len - 1 - j;
        for (0..w) |c| dst[j * w + c] = src[e * w + c];
    }
    return hl * w;
}

/// Bytes of the params uniform for k scalars.
pub fn paramsBytes(k: usize) usize {
    return @min(PARAMS_HEAD + 4 * k, PARAMS_MAX);
}

// ---------------------------------------------------------------- the C ABI
// Numbers cross as f64, as every export of this plane's wasm does.
pub fn stz_gpu_host_version() callconv(.c) f64 {
    return @floatFromInt(VERSION);
}
pub fn stz_gpu_host_group() callconv(.c) f64 {
    return @floatFromInt(GROUP);
}
pub fn stz_gpu_host_margin() callconv(.c) f64 {
    return @floatFromInt(MARGIN);
}
pub fn stz_gpu_host_default_band() callconv(.c) f64 {
    return DEFAULT_BAND;
}
pub fn stz_gpu_host_default_reps() callconv(.c) f64 {
    return @floatFromInt(DEFAULT_REPS);
}
pub fn stz_gpu_host_groups(n: f64) callconv(.c) f64 {
    return @floatFromInt(groups(@intFromFloat(@max(n, 0))));
}
pub fn stz_gpu_host_hidden_count(n: f64) callconv(.c) f64 {
    return @floatFromInt(hiddenCount(@intFromFloat(@max(n, 0))));
}
pub fn stz_gpu_host_hidden_len(len: f64, n: f64, nb: f64) callconv(.c) f64 {
    return @floatFromInt(hiddenLen(@intFromFloat(@max(len, 0)), @intFromFloat(@max(n, 0)), @intFromFloat(@max(nb, 0))));
}
pub fn stz_gpu_host_params_bytes(k: f64) callconv(.c) f64 {
    return @floatFromInt(paramsBytes(@intFromFloat(@max(k, 0))));
}
/// src: len_floats f32s; dst: hidden_len * w f32s. Returns the floats written.
pub fn stz_gpu_host_hidden_input(src: [*]const f32, len_floats: f64, w: f64, n: f64, nb: f64, dst: [*]f32) callconv(.c) f64 {
    const lf: usize = @intFromFloat(@max(len_floats, 0));
    const wi: usize = @intFromFloat(@max(w, 1));
    const nn: usize = @intFromFloat(@max(n, 1));
    const nbb: usize = @intFromFloat(@max(nb, 1));
    const hl = hiddenLen(lf / wi, nn, nbb);
    return @floatFromInt(hiddenInput(src[0..lf], wi, nn, nbb, dst[0 .. hl * wi]));
}

// ---------------------------------------------------------------- tests
test "GL0 host contract: the numbers, pinned" {
    try std.testing.expectEqual(@as(usize, 1), hiddenCount(0));
    try std.testing.expectEqual(@as(usize, 1), hiddenCount(1));
    try std.testing.expectEqual(@as(usize, 1), hiddenCount(2));
    try std.testing.expectEqual(@as(usize, 5), hiddenCount(7)); // 5, odd
    try std.testing.expectEqual(@as(usize, 181), hiddenCount(256)); // 182, even, one less
    try std.testing.expectEqual(@as(usize, 2857), hiddenCount(4000)); // 2857, odd
    try std.testing.expectEqual(@as(usize, 1), groups(1));
    try std.testing.expectEqual(@as(usize, 1), groups(256));
    try std.testing.expectEqual(@as(usize, 2), groups(257));
    try std.testing.expectEqual(@as(usize, 16), groups(4000));
    try std.testing.expectEqual(@as(usize, 8), paramsBytes(0));
    try std.testing.expectEqual(@as(usize, 20), paramsBytes(3));
    try std.testing.expectEqual(@as(usize, 64), paramsBytes(14));
    try std.testing.expectEqual(@as(usize, 64), paramsBytes(40));
    try std.testing.expectEqual(@as(usize, 1), hiddenLen(1, 10, 3));
    try std.testing.expectEqual(@as(usize, 2857), hiddenLen(4000, 4000, 2857));
    try std.testing.expectEqual(@as(usize, 5714), hiddenLen(8000, 4000, 2857)); // an input twice n keeps twice nb
}

test "GL0 host contract: the hidden input is the reversed tail, element by element" {
    const src = [_]f32{ 1, 2, 3, 4, 5, 6 };
    var dst: [6]f32 = undefined;
    // one float per element: n = 6, nb = 4 keeps the last 4, reversed
    try std.testing.expectEqual(@as(usize, 4), hiddenInput(&src, 1, 6, 4, &dst));
    try std.testing.expectEqualSlices(f32, &.{ 6, 5, 4, 3 }, dst[0..4]);
    // a vec2 input: 3 elements (1,2) (3,4) (5,6); n = 3, nb = 2 keeps 2, each element's pair in order
    try std.testing.expectEqual(@as(usize, 4), hiddenInput(&src, 2, 3, 2, &dst));
    try std.testing.expectEqualSlices(f32, &.{ 5, 6, 3, 4 }, dst[0..4]);
    // too small a destination writes nothing
    var tiny: [1]f32 = undefined;
    try std.testing.expectEqual(@as(usize, 0), hiddenInput(&src, 1, 6, 4, &tiny));
}
