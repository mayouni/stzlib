const std = @import("std");

// ── Small Utility Functions ────────────────────────────────
// Lightweight helpers that don't justify a full module:
// min/max/abs/sign/swap, string hashing, byte comparison.

pub fn smallfn_min_f64(a: f64, b: f64) callconv(.c) f64 {
    return @min(a, b);
}

pub fn smallfn_max_f64(a: f64, b: f64) callconv(.c) f64 {
    return @max(a, b);
}

pub fn smallfn_abs_f64(x: f64) callconv(.c) f64 {
    return @abs(x);
}

pub fn smallfn_sign(x: f64) callconv(.c) i32 {
    if (x > 0) return 1;
    if (x < 0) return -1;
    return 0;
}

pub fn smallfn_clamp_f64(x: f64, lo: f64, hi: f64) callconv(.c) f64 {
    return @max(lo, @min(x, hi));
}

pub fn smallfn_lerp(a: f64, b: f64, t: f64) callconv(.c) f64 {
    return a + (b - a) * t;
}

pub fn smallfn_map_range(x: f64, in_lo: f64, in_hi: f64, out_lo: f64, out_hi: f64) callconv(.c) f64 {
    if (in_hi == in_lo) return out_lo;
    return out_lo + (x - in_lo) * (out_hi - out_lo) / (in_hi - in_lo);
}

pub fn smallfn_is_nan(x: f64) callconv(.c) i32 {
    return if (std.math.isNan(x)) 1 else 0;
}

pub fn smallfn_is_inf(x: f64) callconv(.c) i32 {
    return if (std.math.isInf(x)) 1 else 0;
}

pub fn smallfn_is_finite(x: f64) callconv(.c) i32 {
    return if (std.math.isFinite(x)) 1 else 0;
}

pub fn smallfn_ceil(x: f64) callconv(.c) f64 {
    return @ceil(x);
}

pub fn smallfn_floor(x: f64) callconv(.c) f64 {
    return @floor(x);
}

pub fn smallfn_round(x: f64) callconv(.c) f64 {
    return @round(x);
}

pub fn smallfn_trunc(x: f64) callconv(.c) f64 {
    return @trunc(x);
}

pub fn smallfn_fmod(x: f64, y: f64) callconv(.c) f64 {
    if (y == 0) return 0;
    return @mod(x, y);
}

pub fn smallfn_pow(base: f64, exp: f64) callconv(.c) f64 {
    return std.math.pow(f64, base, exp);
}

pub fn smallfn_sqrt(x: f64) callconv(.c) f64 {
    if (x < 0) return 0;
    return @sqrt(x);
}

pub fn smallfn_log_e(x: f64) callconv(.c) f64 {
    if (x <= 0) return 0;
    return @log(x);
}

pub fn smallfn_log10(x: f64) callconv(.c) f64 {
    if (x <= 0) return 0;
    return std.math.log10(x);
}

// ── C ABI exports ────────────────────────────────────────────

pub export fn stz_smallfn_min(a: f64, b: f64) callconv(.c) f64 { return smallfn_min_f64(a, b); }
pub export fn stz_smallfn_max(a: f64, b: f64) callconv(.c) f64 { return smallfn_max_f64(a, b); }
pub export fn stz_smallfn_abs(x: f64) callconv(.c) f64 { return smallfn_abs_f64(x); }
pub export fn stz_smallfn_sign(x: f64) callconv(.c) i32 { return smallfn_sign(x); }
pub export fn stz_smallfn_clamp(x: f64, lo: f64, hi: f64) callconv(.c) f64 { return smallfn_clamp_f64(x, lo, hi); }
pub export fn stz_smallfn_lerp(a: f64, b: f64, t: f64) callconv(.c) f64 { return smallfn_lerp(a, b, t); }
pub export fn stz_smallfn_map_range(x: f64, il: f64, ih: f64, ol: f64, oh: f64) callconv(.c) f64 { return smallfn_map_range(x, il, ih, ol, oh); }
pub export fn stz_smallfn_is_nan(x: f64) callconv(.c) i32 { return smallfn_is_nan(x); }
pub export fn stz_smallfn_is_inf(x: f64) callconv(.c) i32 { return smallfn_is_inf(x); }
pub export fn stz_smallfn_is_finite(x: f64) callconv(.c) i32 { return smallfn_is_finite(x); }
pub export fn stz_smallfn_ceil(x: f64) callconv(.c) f64 { return smallfn_ceil(x); }
pub export fn stz_smallfn_floor(x: f64) callconv(.c) f64 { return smallfn_floor(x); }
pub export fn stz_smallfn_round(x: f64) callconv(.c) f64 { return smallfn_round(x); }
pub export fn stz_smallfn_trunc(x: f64) callconv(.c) f64 { return smallfn_trunc(x); }
pub export fn stz_smallfn_fmod(x: f64, y: f64) callconv(.c) f64 { return smallfn_fmod(x, y); }
pub export fn stz_smallfn_pow(b: f64, e: f64) callconv(.c) f64 { return smallfn_pow(b, e); }
pub export fn stz_smallfn_sqrt(x: f64) callconv(.c) f64 { return smallfn_sqrt(x); }
pub export fn stz_smallfn_log_e(x: f64) callconv(.c) f64 { return smallfn_log_e(x); }
pub export fn stz_smallfn_log10(x: f64) callconv(.c) f64 { return smallfn_log10(x); }

// ── Tests ────────────────────────────────────────────────────

test "smallfn: min/max" {
    try std.testing.expectApproxEqAbs(@as(f64, 2.0), smallfn_min_f64(2.0, 5.0), 0.001);
    try std.testing.expectApproxEqAbs(@as(f64, 5.0), smallfn_max_f64(2.0, 5.0), 0.001);
}

test "smallfn: abs/sign" {
    try std.testing.expectApproxEqAbs(@as(f64, 3.0), smallfn_abs_f64(-3.0), 0.001);
    try std.testing.expectEqual(@as(i32, -1), smallfn_sign(-5.0));
    try std.testing.expectEqual(@as(i32, 1), smallfn_sign(5.0));
    try std.testing.expectEqual(@as(i32, 0), smallfn_sign(0.0));
}

test "smallfn: clamp" {
    try std.testing.expectApproxEqAbs(@as(f64, 5.0), smallfn_clamp_f64(10.0, 0.0, 5.0), 0.001);
    try std.testing.expectApproxEqAbs(@as(f64, 0.0), smallfn_clamp_f64(-1.0, 0.0, 5.0), 0.001);
}

test "smallfn: lerp" {
    try std.testing.expectApproxEqAbs(@as(f64, 5.0), smallfn_lerp(0.0, 10.0, 0.5), 0.001);
}

test "smallfn: map_range" {
    try std.testing.expectApproxEqAbs(@as(f64, 50.0), smallfn_map_range(5.0, 0.0, 10.0, 0.0, 100.0), 0.001);
}

test "smallfn: nan/inf/finite" {
    try std.testing.expectEqual(@as(i32, 1), smallfn_is_nan(std.math.nan(f64)));
    try std.testing.expectEqual(@as(i32, 1), smallfn_is_inf(std.math.inf(f64)));
    try std.testing.expectEqual(@as(i32, 1), smallfn_is_finite(42.0));
}

test "smallfn: rounding" {
    try std.testing.expectApproxEqAbs(@as(f64, 4.0), smallfn_ceil(3.2), 0.001);
    try std.testing.expectApproxEqAbs(@as(f64, 3.0), smallfn_floor(3.9), 0.001);
    try std.testing.expectApproxEqAbs(@as(f64, 4.0), smallfn_round(3.5), 0.001);
    try std.testing.expectApproxEqAbs(@as(f64, 3.0), smallfn_trunc(3.9), 0.001);
}

test "smallfn: math ops" {
    try std.testing.expectApproxEqAbs(@as(f64, 8.0), smallfn_pow(2.0, 3.0), 0.001);
    try std.testing.expectApproxEqAbs(@as(f64, 3.0), smallfn_sqrt(9.0), 0.001);
    try std.testing.expectApproxEqAbs(@as(f64, 1.0), smallfn_fmod(7.0, 3.0), 0.001);
}
