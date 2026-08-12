// Perceptual colour, engine-side (C1 of SOFTANZA_COLOR_SYSTEM.md).
//
// WHY THIS EXISTS. The shade algebra was arithmetic in sRGB, and equal RGB
// steps are not equal PERCEIVED steps. Measured on the shipped palette:
//
//     blue   --=227  -=173  base=29  +=91  ++=11
//
// The base is DARKER than both its neighbours -- the ramp zigzags -- and
// yellow's four steps were 6, 18, 180, 34. That is why the `light` theme
// rendered :Success as near-black olive.
//
// Oklab is perceptually uniform: equal steps in L look equal ACROSS HUES,
// so a yellow and a blue at the same L read as the same brightness. Walking
// L while holding H makes a ramp that is monotonic and even BY
// CONSTRUCTION -- a zigzag is not representable.
//
// Engine-side because plots, gradients and scenes will call it in bulk, and
// because Ring must never be the tier doing per-colour arithmetic.
//
// Reference: Björn Ottosson's Oklab. The matrices are his.

const std = @import("std");

pub const Rgb = struct { r: f64, g: f64, b: f64 }; // 0..1, sRGB encoded
pub const Lab = struct { l: f64, a: f64, b: f64 };
pub const Lch = struct { l: f64, c: f64, h: f64 }; // h in degrees

// sRGB transfer function and its inverse. NOT a gamma of 2.2 -- the real
// piecewise curve, because the linear segment near black is exactly where
// dark UI colours live.
pub fn srgbToLinear(v: f64) f64 {
    if (v <= 0.04045) return v / 12.92;
    return std.math.pow(f64, (v + 0.055) / 1.055, 2.4);
}

pub fn linearToSrgb(v: f64) f64 {
    if (v <= 0.0031308) return v * 12.92;
    return 1.055 * std.math.pow(f64, v, 1.0 / 2.4) - 0.055;
}

pub fn rgbToOklab(c: Rgb) Lab {
    const r = srgbToLinear(c.r);
    const g = srgbToLinear(c.g);
    const b = srgbToLinear(c.b);

    const l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b;
    const m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b;
    const s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b;

    const l_ = std.math.cbrt(l);
    const m_ = std.math.cbrt(m);
    const s_ = std.math.cbrt(s);

    return .{
        .l = 0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_,
        .a = 1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_,
        .b = 0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_,
    };
}

pub fn oklabToRgb(c: Lab) Rgb {
    const l_ = c.l + 0.3963377774 * c.a + 0.2158037573 * c.b;
    const m_ = c.l - 0.1055613458 * c.a - 0.0638541728 * c.b;
    const s_ = c.l - 0.0894841775 * c.a - 1.2914855480 * c.b;

    const l = l_ * l_ * l_;
    const m = m_ * m_ * m_;
    const s = s_ * s_ * s_;

    return .{
        .r = linearToSrgb(4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s),
        .g = linearToSrgb(-1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s),
        .b = linearToSrgb(-0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s),
    };
}

pub fn labToLch(c: Lab) Lch {
    const h = std.math.atan2(c.b, c.a) * 180.0 / std.math.pi;
    return .{
        .l = c.l,
        .c = @sqrt(c.a * c.a + c.b * c.b),
        .h = if (h < 0) h + 360.0 else h,
    };
}

pub fn lchToLab(c: Lch) Lab {
    const rad = c.h * std.math.pi / 180.0;
    return .{ .l = c.l, .a = c.c * @cos(rad), .b = c.c * @sin(rad) };
}

fn inGamut(c: Rgb) bool {
    const e = 0.0005; // the round trip is not bit-exact; this is float slack
    return c.r >= -e and c.r <= 1 + e and
        c.g >= -e and c.g <= 1 + e and
        c.b >= -e and c.b <= 1 + e;
}

/// Hold L and H, reduce C until the colour fits in sRGB. Binary search --
/// clipping the RGB channels instead would shift the HUE, which is the one
/// property the ramp exists to preserve.
pub fn gamutClamp(target: Lch) Rgb {
    var direct = oklabToRgb(lchToLab(target));
    if (inGamut(direct)) return .{
        .r = @min(1, @max(0, direct.r)),
        .g = @min(1, @max(0, direct.g)),
        .b = @min(1, @max(0, direct.b)),
    };

    var lo: f64 = 0;
    var hi: f64 = target.c;
    var i: usize = 0;
    while (i < 24) : (i += 1) {
        const mid = (lo + hi) / 2;
        const t = oklabToRgb(lchToLab(.{ .l = target.l, .c = mid, .h = target.h }));
        if (inGamut(t)) lo = mid else hi = mid;
    }
    direct = oklabToRgb(lchToLab(.{ .l = target.l, .c = lo, .h = target.h }));
    return .{
        .r = @min(1, @max(0, direct.r)),
        .g = @min(1, @max(0, direct.g)),
        .b = @min(1, @max(0, direct.b)),
    };
}

/// One rung of a ramp: the seed's HUE, at a chosen perceptual lightness.
///
/// Chroma is scaled down toward the ends, because a fully saturated colour
/// at L=0.95 is not a pale tint, it is a neon smear. The curve peaks in the
/// middle where a solid fill lives.
pub fn rampStep(seed: Rgb, l_target: f64) Rgb {
    const base = labToLch(rgbToOklab(seed));
    const d = @abs(l_target - 0.62);
    const falloff = @max(0.15, 1.0 - (d * d) * 2.2);
    return gamutClamp(.{ .l = l_target, .c = base.c * falloff, .h = base.h });
}

// ------------------------------------------------------------------ C ABI

fn u8f(v: f64) u8 {
    return @intFromFloat(@min(255.0, @max(0.0, @round(v * 255.0))));
}

/// 0xRRGGBB in, 0xRRGGBB out, at perceptual lightness l_target (0..1).
pub fn stz_color_ramp_step(rgb: u32, l_target: f64) callconv(.c) u32 {
    const seed = Rgb{
        .r = @as(f64, @floatFromInt((rgb >> 16) & 0xFF)) / 255.0,
        .g = @as(f64, @floatFromInt((rgb >> 8) & 0xFF)) / 255.0,
        .b = @as(f64, @floatFromInt(rgb & 0xFF)) / 255.0,
    };
    const out = rampStep(seed, l_target);
    return (@as(u32, u8f(out.r)) << 16) | (@as(u32, u8f(out.g)) << 8) | u8f(out.b);
}

/// Oklab L of a colour, 0..1. The honest "how light is this", usable across
/// hues -- unlike the BT.709 figure, which calls a saturated yellow much
/// lighter than a saturated blue of the same perceived weight.
pub fn stz_color_lightness(rgb: u32) callconv(.c) f64 {
    const c = Rgb{
        .r = @as(f64, @floatFromInt((rgb >> 16) & 0xFF)) / 255.0,
        .g = @as(f64, @floatFromInt((rgb >> 8) & 0xFF)) / 255.0,
        .b = @as(f64, @floatFromInt(rgb & 0xFF)) / 255.0,
    };
    return rgbToOklab(c).l;
}

/// OKLCH hue in degrees. Exposed because judging a perceptual ramp with an
/// HSL hue is the wrong instrument: HSL hue is meaningless as chroma tends
/// to zero, and it disagrees with perception at high chroma. A ramp built
/// in OKLCH has to be judged in OKLCH.
pub fn stz_color_hue(rgb: u32) callconv(.c) f64 {
    const c = Rgb{
        .r = @as(f64, @floatFromInt((rgb >> 16) & 0xFF)) / 255.0,
        .g = @as(f64, @floatFromInt((rgb >> 8) & 0xFF)) / 255.0,
        .b = @as(f64, @floatFromInt(rgb & 0xFF)) / 255.0,
    };
    return labToLch(rgbToOklab(c)).h;
}

/// OKLCH chroma. A hue comparison is only meaningful where there is chroma
/// to have a hue, so a guard needs this to know when to stop asking.
pub fn stz_color_chroma(rgb: u32) callconv(.c) f64 {
    const c = Rgb{
        .r = @as(f64, @floatFromInt((rgb >> 16) & 0xFF)) / 255.0,
        .g = @as(f64, @floatFromInt((rgb >> 8) & 0xFF)) / 255.0,
        .b = @as(f64, @floatFromInt(rgb & 0xFF)) / 255.0,
    };
    return labToLch(rgbToOklab(c)).c;
}

test "oklab round trip" {
    const cases = [_]Rgb{
        .{ .r = 1, .g = 0, .b = 0 },
        .{ .r = 0, .g = 0, .b = 1 },
        .{ .r = 0.2, .g = 0.6, .b = 0.4 },
        .{ .r = 1, .g = 1, .b = 1 },
        .{ .r = 0, .g = 0, .b = 0 },
    };
    for (cases) |c| {
        const back = oklabToRgb(rgbToOklab(c));
        try std.testing.expect(@abs(back.r - c.r) < 0.002);
        try std.testing.expect(@abs(back.g - c.g) < 0.002);
        try std.testing.expect(@abs(back.b - c.b) < 0.002);
    }
}

test "a ramp is monotonic in L" {
    const seed = Rgb{ .r = 0, .g = 0, .b = 1 };
    var prev: f64 = 2;
    for ([_]f64{ 0.92, 0.78, 0.62, 0.46, 0.30 }) |lt| {
        const step = rampStep(seed, lt);
        const got = rgbToOklab(step).l;
        try std.testing.expect(got < prev);
        prev = got;
    }
}
