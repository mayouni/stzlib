// Softanza Engine -- ASCII case primitives, in ONE place.
//
// WHY THIS FILE EXISTS. `if (c >= 'A' and c <= 'Z') c + 32 else c` was written
// out by hand in at least six places -- autodiff.zig, bayes.zig, bytes.zig
// (twice), expr.zig (three times), and string/core.zig -- and only the string
// copy ever got attention. That is the recurring defect in this engine: two
// spellings of one operation stay equally CORRECT while diverging in COST, so
// nothing fails and nobody looks. The fix is always to DELETE a spelling, not
// to speed one up.
//
// Dependency-free ON PURPOSE: `std` and nothing else. string/core.zig pulls in
// unicode.zig and utf8proc, which the bytes/expr/bayes DLLs neither link nor
// need, so the shared home for these had to be somewhere neither side pays for.
//
// (Handle tables are per-DLL, but CODE is not -- every DLL compiles the same
// source tree, so importing a pure function across module lines is free and
// safe. It is handle IDs that must never cross.)

const std = @import("std");

pub fn lower(b: u8) u8 {
    return if (b >= 'A' and b <= 'Z') b | 0x20 else b;
}

pub fn upper(b: u8) u8 {
    return if (b >= 'a' and b <= 'z') b & 0xDF else b;
}

/// `a` equals `b_lower` ignoring ASCII case. `b_lower` must ALREADY be lower.
pub fn eqlIgnoreCase(a: []const u8, b_lower: []const u8) bool {
    if (a.len != b_lower.len) return false;
    for (a, b_lower) |x, y| {
        if (lower(x) != y) return false;
    }
    return true;
}

/// Byte-wise ASCII case transform of `src` into `dst` (same length).
///
/// Callers wrote this as `for (src, 0..) |b, i| dst[i] = ...` and a comment
/// claimed it auto-vectorises. MEASURED, that is true at size and false where
/// it matters: 64 B  auto 8.67 ms / explicit 0.55 ms (15.8x); 4 KB 0.99x;
/// 1 MB 0.98x. LLVM's vectorised loop carries a runtime trip-count guard, so
/// short buffers fall to the scalar path -- and short strings are this
/// library's common case. Pick on the DISTRIBUTION, not the benchmark tail.
///
/// Masked to A-Z rather than an unconditional `| 0x20`: '@' is 'A'-1, '[' is
/// 'Z'+1, '`' is 'a'-1, '{' is 'z'+1, and each pair differs only in bit 5, so
/// the unconditional form corrupts exactly those while leaving every letter
/// correct -- invisible to any test written with words.
pub fn caseInto(src: []const u8, dst: []u8, comptime to_upper: bool) void {
    const lo: u8 = if (to_upper) 'a' else 'A';
    const hi: u8 = if (to_upper) 'z' else 'Z';

    const W = std.simd.suggestVectorLength(u8) orelse {
        for (src, 0..) |b, i| {
            dst[i] = if (b >= lo and b <= hi) (if (to_upper) b - 32 else b + 32) else b;
        }
        return;
    };
    const Vec = @Vector(W, u8);
    const vlo: Vec = @splat(lo);
    const vhi: Vec = @splat(hi);
    const delta: Vec = @splat(32);
    const zero: Vec = @splat(0);

    var i: usize = 0;
    while (i + W <= src.len) : (i += W) {
        const v: Vec = src[i..][0..W].*;
        const in_range = (v >= vlo) & (v <= vhi);
        const adj = @select(u8, in_range, delta, zero);
        dst[i..][0..W].* = if (to_upper) v - adj else v + adj;
    }
    while (i < src.len) : (i += 1) {
        const b = src[i];
        dst[i] = if (b >= lo and b <= hi) (if (to_upper) b - 32 else b + 32) else b;
    }
}

// ─── Tests ───

test "lower/upper leave the bytes ADJACENT to the letter ranges alone" {
    // The whole point: '@'/'`' and '['/'{' differ only in bit 5, so a naive
    // `| 0x20` pairs them. A test using only letters passes against that bug.
    try std.testing.expectEqual(@as(u8, '@'), lower('@'));
    try std.testing.expectEqual(@as(u8, '`'), lower('`'));
    try std.testing.expectEqual(@as(u8, '['), lower('['));
    try std.testing.expectEqual(@as(u8, '{'), lower('{'));
    try std.testing.expectEqual(@as(u8, 'a'), lower('A'));
    try std.testing.expectEqual(@as(u8, 'z'), lower('Z'));
    try std.testing.expectEqual(@as(u8, '@'), upper('@'));
    try std.testing.expectEqual(@as(u8, '`'), upper('`'));
    try std.testing.expectEqual(@as(u8, 'A'), upper('a'));
    try std.testing.expectEqual(@as(u8, 'Z'), upper('z'));
    // Non-ASCII is untouched by both.
    var b: u16 = 128;
    while (b < 256) : (b += 1) {
        const x: u8 = @intCast(b);
        try std.testing.expectEqual(x, lower(x));
        try std.testing.expectEqual(x, upper(x));
    }
}

test "caseInto matches the byte loop it replaced, at every length" {
    var src: [300]u8 = undefined;
    var got: [300]u8 = undefined;
    var want: [300]u8 = undefined;
    for (0..src.len) |n| {
        // Cycle every byte value so the range edges land at many different
        // lane positions as n grows past the vector width.
        for (0..n) |i| src[i] = @intCast((i * 7 + n) % 256);

        caseInto(src[0..n], got[0..n], true);
        for (src[0..n], 0..) |b, i| want[i] = if (b >= 'a' and b <= 'z') b - 32 else b;
        try std.testing.expectEqualSlices(u8, want[0..n], got[0..n]);

        caseInto(src[0..n], got[0..n], false);
        for (src[0..n], 0..) |b, i| want[i] = if (b >= 'A' and b <= 'Z') b + 32 else b;
        try std.testing.expectEqualSlices(u8, want[0..n], got[0..n]);
    }
}

test "eqlIgnoreCase is case-blind for letters and exact otherwise" {
    try std.testing.expect(eqlIgnoreCase("FoX", "fox"));
    try std.testing.expect(!eqlIgnoreCase("fo", "fox"));
    try std.testing.expect(!eqlIgnoreCase("@", "`"));
    try std.testing.expect(!eqlIgnoreCase("[", "{"));
}
