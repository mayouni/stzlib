//! stz_geo -- THE SPHERE (GE0 of SOFTANZA_GRAPHICS_PLAN.md).
//!
//! Everything a map needs before it is a map: a projection from the
//! sphere to the paper, the rotation that turns the sphere first, the
//! resampling that turns a straight edge on the sphere into the curve it
//! really is, the clipping that keeps the far side of a globe off the page,
//! and the measures -- distance, interpolation, area -- that a picture's
//! rules will ask about.
//!
//! WHAT IS COPIED FROM d3-geo, on purpose, and named: the shape of the
//! pipeline. A projection is a STREAM every point passes through --
//!
//!     rotate -> clip on the sphere -> project -> resample -> scale, translate
//!
//! -- written once, so no picture can skip a stage. That is the same shape
//! as this engine's text pipeline (bidi, shape, rasterise) and for the same
//! reason: one entry, every renderer, no two backends disagreeing about
//! where a coastline sits. The projections themselves are textbook
//! (Snyder, "Map Projections: A Working Manual", 1987), spherical case.
//!
//! WHAT IS NOT HERE, said now so it is not implied: the ellipsoid. Every
//! projection below treats the Earth as a sphere, which is what every map
//! at continental scale does and what no surveyor would accept. Polygon
//! FILL across the antimeridian or the horizon of a globe is GE0c, not
//! this file: a ring is projected here as the line it is, and a fill that
//! straddles a cut is drawn wrong until then. Albers-USA (the composite
//! with Alaska and Hawaii inset) and Robinson (table-driven) are absent.
//!
//! Units: the public API takes DEGREES and gives PIXELS. Inside, radians.
//! A raw projection answers in the unit sphere's own units; `scale`
//! multiplies and `translate` places, with y flipped so north is up, the
//! way the choropleth learnt the hard way it must be.

const std = @import("std");
const math = std.math;
const alloc = std.heap.c_allocator;

const PI: f64 = math.pi;
const HALF_PI: f64 = math.pi / 2.0;
const TAU: f64 = math.pi * 2.0;
const DEG: f64 = math.pi / 180.0;
const EPS: f64 = 1e-6;

pub const Kind = enum(u8) {
    equirectangular = 0,
    mercator = 1,
    transverse_mercator = 2,
    cylindrical_equal_area = 3,
    natural_earth = 4,
    mollweide = 5,
    sinusoidal = 6,
    conic_equal_area = 7,
    conic_conformal = 8,
    conic_equidistant = 9,
    orthographic = 10,
    stereographic = 11,
    gnomonic = 12,
    azimuthal_equal_area = 13,
    azimuthal_equidistant = 14,
    equal_earth = 15,

    pub fn name(k: Kind) [:0]const u8 {
        return switch (k) {
            .equirectangular => "Equirectangular",
            .mercator => "Mercator",
            .transverse_mercator => "TransverseMercator",
            .cylindrical_equal_area => "CylindricalEqualArea",
            .natural_earth => "NaturalEarth",
            .mollweide => "Mollweide",
            .sinusoidal => "Sinusoidal",
            .conic_equal_area => "ConicEqualArea",
            .conic_conformal => "ConicConformal",
            .conic_equidistant => "ConicEquidistant",
            .orthographic => "Orthographic",
            .stereographic => "Stereographic",
            .gnomonic => "Gnomonic",
            .azimuthal_equal_area => "AzimuthalEqualArea",
            .azimuthal_equidistant => "AzimuthalEquidistant",
            .equal_earth => "EqualEarth",
        };
    }

    /// Azimuthal projections see ONE side of the sphere: what lies beyond
    /// the clip angle from the centre is behind the globe and is not drawn.
    pub fn isAzimuthal(k: Kind) bool {
        return switch (k) {
            .orthographic, .stereographic, .gnomonic, .azimuthal_equal_area, .azimuthal_equidistant => true,
            else => false,
        };
    }

    /// d3's defaults, which are the textbook's: a hemisphere for the
    /// orthographic, a little less than the whole sphere where the far
    /// pole would be at infinity.
    pub fn defaultClipAngle(k: Kind) f64 {
        return switch (k) {
            .orthographic => 90.0,
            .stereographic => 142.0,
            .gnomonic => 60.0,
            .azimuthal_equal_area, .azimuthal_equidistant => 180.0 - 1e-3,
            else => 0.0,
        };
    }

    /// Is the drawn area of every region proportional to its true area?
    /// The property a choropleth cannot do without, and a rule will ask.
    pub fn isEqualArea(k: Kind) bool {
        return switch (k) {
            .cylindrical_equal_area, .mollweide, .sinusoidal, .conic_equal_area, .azimuthal_equal_area, .equal_earth => true,
            else => false,
        };
    }

    /// Does a small circle on the sphere stay a circle on the paper?
    pub fn isConformal(k: Kind) bool {
        return switch (k) {
            .mercator, .transverse_mercator, .conic_conformal, .stereographic => true,
            else => false,
        };
    }
};

pub const Projection = struct {
    kind: Kind = .equirectangular,
    /// the rotation applied to the sphere BEFORE projecting: yaw about the
    /// poles, then pitch, then roll -- d3's [lambda, phi, gamma], radians
    rot: [3]f64 = .{ 0, 0, 0 },
    /// the standard parallels of a conic, or the one parallel of a
    /// cylindrical equal-area; radians
    par: [2]f64 = .{ 0, 0 },
    scale: f64 = 150,
    tx: f64 = 480,
    ty: f64 = 250,
    /// radians; zero means "not clipped on the sphere"
    clip_angle: f64 = 0,
    /// px: a resampled edge is subdivided until its projected midpoint is
    /// within this of the chord's midpoint
    precision: f64 = 0.7,

    pub fn fromKind(k: Kind) Projection {
        var p = Projection{ .kind = k };
        p.clip_angle = k.defaultClipAngle() * DEG;
        p.par = switch (k) {
            .conic_equal_area, .conic_conformal, .conic_equidistant => .{ 30 * DEG, 30 * DEG },
            else => .{ 0, 0 },
        };
        return p;
    }
};

// ------------------------------------------------------------- rotation
//
// d3's rotateRadians, spherical case: yaw is a shift in longitude; pitch
// and roll are a rotation of the unit vector. Written as forward and
// inverse pairs so invert() undoes exactly what forward() did.

fn rotLambda(l: f64, delta: f64) f64 {
    var r = l + delta;
    if (r > PI) r -= TAU else if (r < -PI) r += TAU;
    return r;
}

/// phi-gamma rotation of the point (lambda, phi), radians in and out
fn rotPhiGamma(lambda: f64, phi: f64, d_phi: f64, d_gamma: f64) [2]f64 {
    const cos_d_phi = @cos(d_phi);
    const sin_d_phi = @sin(d_phi);
    const cos_d_gamma = @cos(d_gamma);
    const sin_d_gamma = @sin(d_gamma);
    const cos_phi = @cos(phi);
    const x = @cos(lambda) * cos_phi;
    const y = @sin(lambda) * cos_phi;
    const z = @sin(phi);
    const k = z * cos_d_phi + x * sin_d_phi;
    return .{
        math.atan2(y * cos_d_gamma - k * sin_d_gamma, x * cos_d_phi - z * sin_d_phi),
        math.asin(math.clamp(k * cos_d_gamma + y * sin_d_gamma, -1.0, 1.0)),
    };
}

fn rotPhiGammaInv(lambda: f64, phi: f64, d_phi: f64, d_gamma: f64) [2]f64 {
    const cos_d_phi = @cos(d_phi);
    const sin_d_phi = @sin(d_phi);
    const cos_d_gamma = @cos(d_gamma);
    const sin_d_gamma = @sin(d_gamma);
    const cos_phi = @cos(phi);
    const x = @cos(lambda) * cos_phi;
    const y = @sin(lambda) * cos_phi;
    const z = @sin(phi);
    const k = z * cos_d_gamma - y * sin_d_gamma;
    return .{
        math.atan2(y * cos_d_gamma + z * sin_d_gamma, x * cos_d_phi + k * sin_d_phi),
        math.asin(math.clamp(k * cos_d_phi - x * sin_d_phi, -1.0, 1.0)),
    };
}

/// the sphere, turned: geographic (lambda, phi) -> rotated frame
pub fn rotate(p: *const Projection, lambda: f64, phi: f64) [2]f64 {
    const l = rotLambda(lambda, p.rot[0]);
    var r: [2]f64 = .{ l, phi };
    if (p.rot[1] != 0 or p.rot[2] != 0) r = rotPhiGamma(l, phi, p.rot[1], p.rot[2]);
    // THE TRANSVERSE MERCATOR IS A MERCATOR OF A ROLLED SPHERE, and the
    // roll belongs HERE, in the rotation, not inside the raw projection:
    // put there, the map's seam and its poles are the rolled ones too, so
    // the outline and the seam-cutting find the right great circle. The
    // first version rolled inside the raw and drew the seam through the
    // middle of the map as a sheet of vertical stripes. This is how d3
    // writes it: the user's rotation composed with a gamma of ninety.
    if (p.kind == .transverse_mercator) r = rotPhiGamma(r[0], r[1], 0, HALF_PI);
    return r;
}

pub fn unrotate(p: *const Projection, lambda: f64, phi: f64) [2]f64 {
    var l = lambda;
    var f = phi;
    if (p.kind == .transverse_mercator) {
        const t = rotPhiGammaInv(l, f, 0, HALF_PI);
        l = t[0];
        f = t[1];
    }
    if (p.rot[1] != 0 or p.rot[2] != 0) {
        const r = rotPhiGammaInv(l, f, p.rot[1], p.rot[2]);
        l = r[0];
        f = r[1];
    }
    return .{ rotLambda(l, -p.rot[0]), f };
}

// ------------------------------------------------- the raw projections
//
// Each answers in the unit sphere's units for a point ALREADY ROTATED, and
// each has its inverse beside it so a picture can be asked what is under
// the cursor. Null where the point has no image: Mercator's poles, a
// conic's far pole, the inside-out of a gnomonic.

const MERCATOR_LIMIT: f64 = 85.0511287798 * DEG; // where Web Mercator stops

fn rawForward(p: *const Projection, l: f64, f: f64) ?[2]f64 {
    switch (p.kind) {
        .equirectangular => return .{ l, f },
        .mercator => {
            if (@abs(f) > MERCATOR_LIMIT) return null;
            return .{ l, @log(@tan((HALF_PI + f) / 2.0)) };
        },
        .transverse_mercator => {
            // the Mercator with its axes swapped; the roll is in rotate()
            if (@abs(f) > MERCATOR_LIMIT) return null;
            return .{ @log(@tan((HALF_PI + f) / 2.0)), -l };
        },
        .cylindrical_equal_area => {
            const c = @cos(p.par[0]);
            return .{ l * c, @sin(f) / c };
        },
        .natural_earth => {
            const f2 = f * f;
            const f4 = f2 * f2;
            return .{
                l * (0.8707 - 0.131979 * f2 + f4 * (-0.013791 + f4 * (0.003971 * f2 - 0.001529 * f4))),
                f * (1.007226 + f2 * (0.015085 + f4 * (-0.044475 + 0.028874 * f2 - 0.005916 * f4))),
            };
        },
        .equal_earth => {
            // Šavrič, Patterson, Jenny 2018 -- the equal-area world map
            // that reads like a Robinson
            const a1 = 1.340264;
            const a2 = -0.081106;
            const a3 = 0.000893;
            const a4 = 0.003796;
            const m = @sqrt(3.0) / 2.0;
            const t = math.asin(math.clamp(m * @sin(f), -1, 1));
            const t2 = t * t;
            const t6 = t2 * t2 * t2;
            return .{
                l * @cos(t) / (m * (a1 + 3 * a2 * t2 + t6 * (7 * a3 + 9 * a4 * t2))),
                t * (a1 + a2 * t2 + t6 * (a3 + a4 * t2)),
            };
        },
        .mollweide => {
            // solve 2t + sin 2t = pi sin f, Newton
            const k = PI * @sin(f);
            var t = f;
            var i: usize = 0;
            while (i < 30) : (i += 1) {
                const d = (t + @sin(t) - k) / (1 + @cos(t));
                t -= d;
                if (@abs(d) < 1e-12) break;
            }
            t /= 2;
            return .{ 2 * @sqrt(2.0) / PI * l * @cos(t), @sqrt(2.0) * @sin(t) };
        },
        .sinusoidal => return .{ l * @cos(f), f },
        .conic_equal_area => {
            const sy0 = @sin(p.par[0]);
            const n = (sy0 + @sin(p.par[1])) / 2;
            if (@abs(n) < EPS) {
                const c = @cos(p.par[0]);
                return .{ l * c, @sin(f) / c };
            }
            const cc = 1 + sy0 * (2 * n - sy0);
            const r0 = @sqrt(cc) / n;
            const rr = @sqrt(cc - 2 * n * @sin(f)) / n;
            return .{ rr * @sin(l * n), r0 - rr * @cos(l * n) };
        },
        .conic_conformal => {
            const y0 = p.par[0];
            const y1 = p.par[1];
            const cy0 = @cos(y0);
            const n = if (@abs(y0 - y1) < EPS) @sin(y0) else @log(cy0 / @cos(y1)) / @log(@tan(HALF_PI / 2 + y1 / 2) / @tan(HALF_PI / 2 + y0 / 2));
            if (@abs(n) < EPS) return .{ l, @log(@tan((HALF_PI + f) / 2.0)) };
            const ff = cy0 * math.pow(f64, @tan(HALF_PI / 2 + y0 / 2), n) / n;
            if (ff * n > 0) {
                if (f < -HALF_PI + EPS) return null;
            } else {
                if (f > HALF_PI - EPS) return null;
            }
            const rr = ff / math.pow(f64, @tan(HALF_PI / 2 + f / 2), n);
            return .{ rr * @sin(n * l), ff - rr * @cos(n * l) };
        },
        .conic_equidistant => {
            const y0 = p.par[0];
            const y1 = p.par[1];
            const cy0 = @cos(y0);
            const n = if (@abs(y0 - y1) < EPS) @sin(y0) else (cy0 - @cos(y1)) / (y1 - y0);
            if (@abs(n) < EPS) return .{ l, f };
            const g = cy0 / n + y0;
            const rr = g - f;
            return .{ rr * @sin(n * l), g - rr * @cos(n * l) };
        },
        .orthographic => {
            if (@cos(f) * @cos(l) < 0) return null;
            return .{ @cos(f) * @sin(l), @sin(f) };
        },
        .stereographic => {
            const cy = @cos(f);
            const k = 1 + @cos(l) * cy;
            if (k < EPS) return null;
            return .{ cy * @sin(l) / k, @sin(f) / k };
        },
        .gnomonic => {
            const cy = @cos(f);
            const k = @cos(l) * cy;
            if (k < EPS) return null;
            return .{ cy * @sin(l) / k, @sin(f) / k };
        },
        .azimuthal_equal_area => {
            const cy = @cos(f);
            const c = 1 + @cos(l) * cy;
            // null only AT the antipode: the world disc's rim is a
            // thousandth of a degree from it, and the rim must project
            if (c < 1e-14) return null;
            const k = @sqrt(2 / c);
            return .{ k * cy * @sin(l), k * @sin(f) };
        },
        .azimuthal_equidistant => {
            const cy = @cos(f);
            const cc = math.clamp(@cos(l) * cy, -1, 1);
            const c = math.acos(cc);
            const k = if (c < EPS) 1.0 else c / @sin(c);
            return .{ k * cy * @sin(l), k * @sin(f) };
        },
    }
}

fn azimuthalInvert(x: f64, y: f64, angle: *const fn (f64) f64) ?[2]f64 {
    const z = @sqrt(x * x + y * y);
    const c = angle(z);
    const sc = @sin(c);
    const cc = @cos(c);
    return .{ math.atan2(x * sc, z * cc), math.asin(if (z == 0) 0 else math.clamp(y * sc / z, -1, 1)) };
}
fn angOrtho(z: f64) f64 {
    return math.asin(math.clamp(z, -1, 1));
}
fn angStereo(z: f64) f64 {
    return 2 * math.atan(z);
}
fn angGnomonic(z: f64) f64 {
    return math.atan(z);
}
fn angAeqa(z: f64) f64 {
    return 2 * math.asin(math.clamp(z / 2, -1, 1));
}
fn angAeqd(z: f64) f64 {
    return z;
}

fn rawInvert(p: *const Projection, x: f64, y: f64) ?[2]f64 {
    switch (p.kind) {
        .equirectangular => return .{ x, y },
        .mercator => return .{ x, 2 * math.atan(@exp(y)) - HALF_PI },
        .transverse_mercator => return .{ -y, 2 * math.atan(@exp(x)) - HALF_PI },
        .cylindrical_equal_area => {
            const c = @cos(p.par[0]);
            return .{ x / c, math.asin(math.clamp(y * c, -1, 1)) };
        },
        .natural_earth => {
            var f = y;
            var i: usize = 0;
            while (i < 25) : (i += 1) {
                const f2 = f * f;
                const f4 = f2 * f2;
                const fy = f * (1.007226 + f2 * (0.015085 + f4 * (-0.044475 + 0.028874 * f2 - 0.005916 * f4))) - y;
                const dfy = 1.007226 + f2 * (0.015085 * 3 + f4 * (-0.044475 * 7 + 0.028874 * 9 * f2 - 0.005916 * 11 * f4));
                const d = fy / dfy;
                f -= d;
                if (@abs(d) < 1e-12) break;
            }
            const f2 = f * f;
            const f4 = f2 * f2;
            return .{ x / (0.8707 - 0.131979 * f2 + f4 * (-0.013791 + f4 * (0.003971 * f2 - 0.001529 * f4))), f };
        },
        .equal_earth => {
            const a1 = 1.340264;
            const a2 = -0.081106;
            const a3 = 0.000893;
            const a4 = 0.003796;
            const m = @sqrt(3.0) / 2.0;
            var t = y;
            var i: usize = 0;
            while (i < 12) : (i += 1) {
                const t2 = t * t;
                const t6 = t2 * t2 * t2;
                const fy = t * (a1 + a2 * t2 + t6 * (a3 + a4 * t2)) - y;
                const dfy = a1 + 3 * a2 * t2 + t6 * (7 * a3 + 9 * a4 * t2);
                const d = fy / dfy;
                t -= d;
                if (@abs(d) < 1e-12) break;
            }
            const t2 = t * t;
            const t6 = t2 * t2 * t2;
            return .{
                m * x * (a1 + 3 * a2 * t2 + t6 * (7 * a3 + 9 * a4 * t2)) / @cos(t),
                math.asin(math.clamp(@sin(t) / m, -1, 1)),
            };
        },
        .mollweide => {
            const t = math.asin(math.clamp(y / @sqrt(2.0), -1, 1));
            return .{ PI * x / (2 * @sqrt(2.0) * @cos(t)), math.asin(math.clamp((2 * t + @sin(2 * t)) / PI, -1, 1)) };
        },
        .sinusoidal => return .{ x / @cos(y), y },
        .conic_equal_area => {
            const sy0 = @sin(p.par[0]);
            const n = (sy0 + @sin(p.par[1])) / 2;
            if (@abs(n) < EPS) {
                const c = @cos(p.par[0]);
                return .{ x / c, math.asin(math.clamp(y * c, -1, 1)) };
            }
            const cc = 1 + sy0 * (2 * n - sy0);
            const r0 = @sqrt(cc) / n;
            const r0y = r0 - y;
            var lx = math.atan2(x, @abs(r0y)) * math.sign(r0y);
            if (r0y * n < 0) lx -= PI * math.sign(x) * math.sign(r0y);
            return .{ lx / n, math.asin(math.clamp((cc - (x * x + r0y * r0y) * n * n) / (2 * n), -1, 1)) };
        },
        .conic_conformal => {
            const y0 = p.par[0];
            const y1 = p.par[1];
            const cy0 = @cos(y0);
            const n = if (@abs(y0 - y1) < EPS) @sin(y0) else @log(cy0 / @cos(y1)) / @log(@tan(HALF_PI / 2 + y1 / 2) / @tan(HALF_PI / 2 + y0 / 2));
            if (@abs(n) < EPS) return .{ x, 2 * math.atan(@exp(y)) - HALF_PI };
            const ff = cy0 * math.pow(f64, @tan(HALF_PI / 2 + y0 / 2), n) / n;
            const fy = ff - y;
            const rr = math.sign(n) * @sqrt(x * x + fy * fy);
            var lx = math.atan2(x, @abs(fy)) * math.sign(fy);
            if (fy * n < 0) lx -= PI * math.sign(x) * math.sign(fy);
            return .{ lx / n, 2 * math.atan(math.pow(f64, ff / rr, 1 / n)) - HALF_PI };
        },
        .conic_equidistant => {
            const y0 = p.par[0];
            const y1 = p.par[1];
            const cy0 = @cos(y0);
            const n = if (@abs(y0 - y1) < EPS) @sin(y0) else (cy0 - @cos(y1)) / (y1 - y0);
            if (@abs(n) < EPS) return .{ x, y };
            const g = cy0 / n + y0;
            const gy = g - y;
            var lx = math.atan2(x, @abs(gy)) * math.sign(gy);
            if (gy * n < 0) lx -= PI * math.sign(x) * math.sign(gy);
            return .{ lx / n, g - math.sign(n) * @sqrt(x * x + gy * gy) };
        },
        .orthographic => return azimuthalInvert(x, y, angOrtho),
        .stereographic => return azimuthalInvert(x, y, angStereo),
        .gnomonic => return azimuthalInvert(x, y, angGnomonic),
        .azimuthal_equal_area => return azimuthalInvert(x, y, angAeqa),
        .azimuthal_equidistant => return azimuthalInvert(x, y, angAeqd),
    }
}

// ------------------------------------------------------------ the point

/// Is this ROTATED point on the page at all -- on the visible side of the
/// sphere AND somewhere the projection can put it? The second half is why
/// a ring around Tunis wide enough to pass near the pole no longer draws a
/// chord across the top of the Mercator square: the polar cap above 85N
/// has no image, so a line entering it is cut at the edge exactly as a
/// line going behind a globe is, by the same bisection.
fn visible(p: *const Projection, l: f64, f: f64) bool {
    if (p.clip_angle > 0) {
        // angular distance from the rotated centre (0, 0)
        const cos_c = @cos(f) * @cos(l);
        if (cos_c < @cos(p.clip_angle) - 1e-9) return false;
    }
    return rawForward(p, l, f) != null;
}

fn place(p: *const Projection, raw: [2]f64) [2]f64 {
    return .{ raw[0] * p.scale + p.tx, p.ty - raw[1] * p.scale };
}

/// The whole stream for one point: degrees in, pixels out, null when the
/// point is behind the globe or has no image.
pub fn forward(p: *const Projection, lon_deg: f64, lat_deg: f64) ?[2]f64 {
    const r = rotate(p, lon_deg * DEG, lat_deg * DEG);
    if (!visible(p, r[0], r[1])) return null;
    const raw = rawForward(p, r[0], r[1]) orelse return null;
    return place(p, raw);
}

/// ...and back: pixels in, degrees out. Null off the sphere.
pub fn invert(p: *const Projection, x: f64, y: f64) ?[2]f64 {
    const rx = (x - p.tx) / p.scale;
    const ry = (p.ty - y) / p.scale;
    const r = rawInvert(p, rx, ry) orelse return null;
    if (math.isNan(r[0]) or math.isNan(r[1])) return null;
    if (!visible(p, r[0], r[1])) return null;
    const g = unrotate(p, r[0], r[1]);
    return .{ g[0] / DEG, g[1] / DEG };
}

// -------------------------------------------------- spherical geometry

fn toVec(l: f64, f: f64) [3]f64 {
    const c = @cos(f);
    return .{ c * @cos(l), c * @sin(l), @sin(f) };
}
fn fromVec(v: [3]f64) [2]f64 {
    return .{ math.atan2(v[1], v[0]), math.asin(math.clamp(v[2], -1, 1)) };
}
fn normalize(v: [3]f64) [3]f64 {
    const n = @sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);
    if (n == 0) return v;
    return .{ v[0] / n, v[1] / n, v[2] / n };
}

/// The point a fraction t of the way from a to b along the GREAT CIRCLE,
/// radians. This is what "the line between two places" means on a sphere,
/// and it is why a flight route bends on a flat map.
pub fn interpolate(a: [2]f64, b: [2]f64, t: f64) [2]f64 {
    const va = toVec(a[0], a[1]);
    const vb = toVec(b[0], b[1]);
    const dot = math.clamp(va[0] * vb[0] + va[1] * vb[1] + va[2] * vb[2], -1, 1);
    const d = math.acos(dot);
    if (d < 1e-12) return a;
    const sd = @sin(d);
    const ka = @sin((1 - t) * d) / sd;
    const kb = @sin(t * d) / sd;
    return fromVec(.{ ka * va[0] + kb * vb[0], ka * va[1] + kb * vb[1], ka * va[2] + kb * vb[2] });
}

/// Angular distance between two points, radians (multiply by a radius for
/// a length). The haversine, which is stable for close points.
pub fn distance(a: [2]f64, b: [2]f64) f64 {
    const dl = b[0] - a[0];
    const df = b[1] - a[1];
    const h = @sin(df / 2) * @sin(df / 2) + @cos(a[1]) * @cos(b[1]) * @sin(dl / 2) * @sin(dl / 2);
    return 2 * math.atan2(@sqrt(h), @sqrt(1 - h));
}

/// The signed area of a ring on the unit sphere, steradians: the sum of
/// the spherical excesses of the triangles fanned from the first vertex
/// (Van Oosterom & Strackee 1983). Positive counter-clockwise. Correct for
/// a ring smaller than a hemisphere, which is every region a map colours;
/// a ring that contains the fan point's antipode is answered wrong, and
/// that is a limit named here rather than hidden.
pub fn ringArea(lonlat: []const f64) f64 {
    const n = lonlat.len / 2;
    if (n < 3) return 0;
    const a = toVec(lonlat[0] * DEG, lonlat[1] * DEG);
    var sum: f64 = 0;
    var i: usize = 1;
    while (i + 1 < n) : (i += 1) {
        const b = toVec(lonlat[i * 2] * DEG, lonlat[i * 2 + 1] * DEG);
        const c = toVec(lonlat[(i + 1) * 2] * DEG, lonlat[(i + 1) * 2 + 1] * DEG);
        const triple = a[0] * (b[1] * c[2] - b[2] * c[1]) - a[1] * (b[0] * c[2] - b[2] * c[0]) + a[2] * (b[0] * c[1] - b[1] * c[0]);
        const ab = a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
        const bc = b[0] * c[0] + b[1] * c[1] + b[2] * c[2];
        const ca = c[0] * a[0] + c[1] * a[1] + c[2] * a[2];
        sum += 2 * math.atan2(triple, 1 + ab + bc + ca);
    }
    return sum;
}

/// A circle of angular radius r around (lon, lat) on the sphere, n points,
/// degrees in and out, as a closed ring. Tissot's indicatrix is one of
/// these projected; a range ring is one of these with a radius in km.
pub fn circle(out: *std.ArrayList(f64), lon_deg: f64, lat_deg: f64, radius_deg: f64, n: usize) !void {
    const l0 = lon_deg * DEG;
    const f0 = lat_deg * DEG;
    const r = radius_deg * DEG;
    const sf0 = @sin(f0);
    const cf0 = @cos(f0);
    const sr = @sin(r);
    const cr = @cos(r);
    var i: usize = 0;
    while (i <= n) : (i += 1) {
        const bearing = TAU * @as(f64, @floatFromInt(i % n)) / @as(f64, @floatFromInt(n));
        const f = math.asin(math.clamp(sf0 * cr + cf0 * sr * @cos(bearing), -1, 1));
        const l = l0 + math.atan2(@sin(bearing) * sr * cf0, cr - sf0 * @sin(f));
        try out.append(alloc, rotLambda(l, 0) / DEG);
        try out.append(alloc, f / DEG);
    }
}

// ------------------------------------------- the stream: lines on paper
//
// A polyline arrives in degrees and leaves as PIECES of pixels: one piece
// per visible stretch, cut where the line goes behind the globe or crosses
// the seam of the map. Between two given points the line follows the
// great circle and is RESAMPLED -- subdivided until its projected
// midpoint sits within `precision` of the chord -- so a parallel on a
// conic comes out as the arc it is and not as a chord.

pub const Pieces = struct {
    /// flat pixel coordinates of every piece, back to back
    xy: std.ArrayList(f64) = .{},
    /// where each piece begins in `xy` (index into xy, always even)
    starts: std.ArrayList(usize) = .{},

    pub fn deinit(self: *Pieces) void {
        self.xy.deinit(alloc);
        self.starts.deinit(alloc);
    }
    fn begin(self: *Pieces) !void {
        if (self.starts.items.len > 0 and self.starts.items[self.starts.items.len - 1] == self.xy.items.len) return;
        try self.starts.append(alloc, self.xy.items.len);
    }
    fn point(self: *Pieces, xy: [2]f64) !void {
        // never the same point twice in a row: a duplicate vertex is a
        // zero-length edge, and a filler downstream chokes on it
        const n = self.xy.items.len;
        const start = if (self.starts.items.len > 0) self.starts.items[self.starts.items.len - 1] else 0;
        if (n >= start + 2) {
            const dx = self.xy.items[n - 2] - xy[0];
            const dy = self.xy.items[n - 1] - xy[1];
            if (dx * dx + dy * dy < 1e-12) return;
        }
        try self.xy.append(alloc, xy[0]);
        try self.xy.append(alloc, xy[1]);
    }
    pub fn count(self: *const Pieces) usize {
        return self.starts.items.len;
    }
};

const MAX_DEPTH: u8 = 16;

/// Does the rotated segment a->b cross the map's seam (the antimeridian of
/// the rotated frame)? Only meaningful where the seam is drawn as an edge,
/// i.e. every projection that is not azimuthal.
fn crossesSeam(p: *const Projection, la: f64, lb: f64) bool {
    if (p.kind.isAzimuthal()) return false;
    return @abs(lb - la) > PI;
}

const Sampler = struct {
    p: *const Projection,
    out: *Pieces,
    // last emitted rotated point, to know a piece is open
    open: bool = false,

    fn emit(self: *Sampler, r: [2]f64) !void {
        // A POINT WITH NO IMAGE ENDS THE PIECE. A ring around Tunis wide
        // enough to enclose the pole leaves the Mercator square at 85N and
        // comes back on the other side; the first version skipped the
        // unprojectable points and kept the piece open, so the line drew a
        // chord straight across the top of the map. It vanishes off the
        // edge now and reappears as a new piece, which is what happened.
        const raw = rawForward(self.p, r[0], r[1]) orelse {
            self.open = false;
            return;
        };
        if (!self.open) {
            try self.out.begin();
            self.open = true;
        }
        try self.out.point(place(self.p, raw));
    }

    fn close(self: *Sampler) void {
        self.open = false;
    }

    /// resample the rotated great-circle arc a->b (both visible, no seam
    /// crossing), emitting b and whatever lies between
    fn arc(self: *Sampler, a: [2]f64, b: [2]f64, depth: u8) !void {
        if (depth < MAX_DEPTH) {
            const pa = rawForward(self.p, a[0], a[1]);
            const pb = rawForward(self.p, b[0], b[1]);
            const m = interpolate(a, b, 0.5);
            const pm = rawForward(self.p, m[0], m[1]);
            if (pa != null and pb != null and pm != null) {
                const cx = (pa.?[0] + pb.?[0]) / 2;
                const cy = (pa.?[1] + pb.?[1]) / 2;
                const dx = (pm.?[0] - cx) * self.p.scale;
                const dy = (pm.?[1] - cy) * self.p.scale;
                const chord2 = ((pb.?[0] - pa.?[0]) * (pb.?[0] - pa.?[0]) + (pb.?[1] - pa.?[1]) * (pb.?[1] - pa.?[1])) * self.p.scale * self.p.scale;
                // subdivide while the midpoint strays, and while the chord
                // is long enough for straying to be visible at all
                if (dx * dx + dy * dy > self.p.precision * self.p.precision and chord2 > 1e-6) {
                    try self.arc(a, m, depth + 1);
                    try self.arc(m, b, depth + 1);
                    return;
                }
            }
        }
        try self.emit(b);
    }
};

/// The point on the great circle a->b where visibility flips, found by
/// bisection: a is visible and b is not (or the reverse). Twenty halvings
/// put it within a millionth of the arc.
fn horizonBetween(p: *const Projection, a: [2]f64, b: [2]f64) [2]f64 {
    var lo: f64 = 0;
    var hi: f64 = 1;
    const a_vis = visible(p, a[0], a[1]);
    var i: usize = 0;
    while (i < 24) : (i += 1) {
        const t = (lo + hi) / 2;
        const m = interpolate(a, b, t);
        if (visible(p, m[0], m[1]) == a_vis) lo = t else hi = t;
    }
    return interpolate(a, b, lo);
}

/// Where the rotated segment a->b crosses the seam lambda = +-pi: the
/// crossing point on both sides of the seam, [on a's side, on b's side].
fn seamBetween(a: [2]f64, b: [2]f64) [2][2]f64 {
    // walk the great circle until the longitude jumps; bisection on t
    var lo: f64 = 0;
    var hi: f64 = 1;
    const side_a = a[0] > 0;
    var i: usize = 0;
    while (i < 24) : (i += 1) {
        const t = (lo + hi) / 2;
        const m = interpolate(a, b, t);
        if ((m[0] > 0) == side_a) lo = t else hi = t;
    }
    const m = interpolate(a, b, (lo + hi) / 2);
    const s: f64 = if (side_a) PI else -PI;
    return .{ .{ s, m[1] }, .{ -s, m[1] } };
}

/// A polyline in degrees, projected: the pieces of it that are on the page.
pub fn projectLine(p: *const Projection, lonlat: []const f64, out: *Pieces) !void {
    const n = lonlat.len / 2;
    if (n == 0) return;
    var s = Sampler{ .p = p, .out = out };
    var prev = rotate(p, lonlat[0] * DEG, lonlat[1] * DEG);
    var prev_vis = visible(p, prev[0], prev[1]);
    if (prev_vis) try s.emit(prev);
    var i: usize = 1;
    while (i < n) : (i += 1) {
        const cur = rotate(p, lonlat[i * 2] * DEG, lonlat[i * 2 + 1] * DEG);
        const cur_vis = visible(p, cur[0], cur[1]);
        if (prev_vis and cur_vis) {
            if (crossesSeam(p, prev[0], cur[0])) {
                const x = seamBetween(prev, cur);
                try s.arc(prev, x[0], 0);
                s.close();
                try s.emit(x[1]);
                try s.arc(x[1], cur, 0);
            } else {
                try s.arc(prev, cur, 0);
            }
        } else if (prev_vis and !cur_vis) {
            const h = horizonBetween(p, prev, cur);
            try s.arc(prev, h, 0);
            s.close();
        } else if (!prev_vis and cur_vis) {
            const h = horizonBetween(p, cur, prev);
            try s.emit(h);
            try s.arc(h, cur, 0);
        }
        // both invisible: nothing to draw
        prev = cur;
        prev_vis = cur_vis;
    }
}

// ------------------------------------------------- GE0c: filling a cut ring
//
// A RING CUT BY THE EDGE OF THE MAP IS NO LONGER A POLYGON, and until now
// this file said so and left it: a country crossing the antimeridian, or
// lying half behind a globe, came back as loose pieces and could only be
// stroked. Filling them needs the pieces REJOINED along the edge they were
// cut on -- out of the map at one latitude and back in at another, with the
// map's own border walked between.
//
// THE EDGE IS THE SAME OBJECT IN BOTH CASES, which is what makes one
// algorithm serve both: for a globe it is the horizon circle, for a flat
// map it is the outline -- the two seams and the two pole edges. Each is
// walked with the drawable side on the LEFT and parameterised by one
// number u in [0, 1), so the rejoin does not know or care which it has.
//
// AND THIS IS WHERE ANTARCTICA LIVES. A ring around the south pole crosses
// the seam, leaves on one side and returns on the other, and the fill is
// only right if the walk between them goes along the BOTTOM of the map
// rather than straight across it. It does, because the pole edges are part
// of the parameterisation -- so the continent fills to the bottom corners
// the way an atlas draws it.
//
// NAMED, NOT DONE: holes (a ring inside a ring is drawn as its own
// polygon, not subtracted), and a ring that wraps the sphere more than
// once. Self-intersecting rings are the filler's problem, not this one's.

fn latLimit(p: *const Projection) f64 {
    return switch (p.kind) {
        .conic_conformal => 80 * DEG,
        .mercator, .transverse_mercator => MERCATOR_LIMIT,
        else => HALF_PI - 1e-7,
    };
}

const SEAM_EPS: f64 = 1e-7;

/// The point at parameter u along the edge of the drawable region, in the
/// ROTATED frame. u rises with the drawable side on the left.
fn boundaryPoint(p: *const Projection, u: f64) [2]f64 {
    const uu = u - @floor(u);
    if (p.kind.isAzimuthal()) {
        // the bearing runs BACKWARDS as u rises: a cap's rim walked
        // north-east-south-west keeps the cap on the right, and the whole
        // rejoin is written for the interior being on the left
        const r = p.clip_angle;
        const t = -uu * TAU;
        return .{
            math.atan2(@sin(t) * @sin(r), @cos(r)),
            math.asin(math.clamp(@sin(r) * @cos(t), -1, 1)),
        };
    }
    const l = latLimit(p);
    const e = SEAM_EPS;
    if (uu < 0.25) { // up the eastern seam
        return .{ PI - e, -l + 2 * l * (uu / 0.25) };
    } else if (uu < 0.5) { // west along the top
        return .{ PI - e - (TAU - 2 * e) * ((uu - 0.25) / 0.25), l };
    } else if (uu < 0.75) { // down the western seam
        return .{ -PI + e, l - 2 * l * ((uu - 0.5) / 0.25) };
    } else { // east along the bottom
        return .{ -PI + e + (TAU - 2 * e) * ((uu - 0.75) / 0.25), -l };
    }
}

/// ...and the parameter of a point already known to be ON that edge.
fn boundaryParamOf(p: *const Projection, pt: [2]f64) f64 {
    if (p.kind.isAzimuthal()) {
        const t = math.atan2(@sin(pt[0]) * @cos(pt[1]), @sin(pt[1]));
        var u = -t / TAU;
        u -= @floor(u);
        return u;
    }
    const l = latLimit(p);
    const lat = math.clamp(pt[1], -l, l);
    if (pt[0] > 0 and @abs(@abs(pt[0]) - PI) < 1e-4) return 0.25 * (lat + l) / (2 * l);
    if (pt[0] < 0 and @abs(@abs(pt[0]) - PI) < 1e-4) return 0.5 + 0.25 * (l - lat) / (2 * l);
    // a pole edge: east along the bottom, west along the top
    if (pt[1] > 0) return 0.25 + 0.25 * ((PI - pt[0]) / TAU);
    return 0.75 + 0.25 * ((pt[0] + PI) / TAU);
}

/// DOES THIS RING CONTAIN THIS PLACE? Count how often the ring crosses the
/// half-meridian running NORTH from the place: an odd number means inside.
///
/// THE WHOLE DIFFICULTY IS THE WRAP, and the first version of this had it
/// wrong in the way that is hardest to see. It wrapped each vertex's
/// longitude difference into (-pi, pi] and then asked whether two
/// consecutive ones straddled zero -- which says an edge running the short
/// way ACROSS THE ANTIMERIDIAN crosses the place's meridian, because both
/// its ends wrap to opposite signs. A globe seen from the north pole then
/// reported the Antarctic cap as containing the pole, and filled the whole
/// world blue.
///
/// The edge itself decides now: take the wrapped step from one vertex to
/// the next, and the edge crosses the meridian only if the place's
/// longitude lies ALONG that step. The crossing latitude is then the great
/// circle's, not a straight line in longitude -- a coarse ring would put it
/// in the wrong place otherwise.
fn wrapPi(x: f64) f64 {
    var r = x;
    while (r > PI) r -= TAU;
    while (r <= -PI) r += TAU;
    return r;
}

pub fn ringContains(lonlat: []const f64, lon_deg: f64, lat_deg: f64) bool {
    const n = lonlat.len / 2;
    if (n < 3) return false;
    const l0 = lon_deg * DEG;
    const f0 = lat_deg * DEG;
    var inside = false;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        const j = (i + 1) % n;
        const la = lonlat[i * 2] * DEG;
        const fa = lonlat[i * 2 + 1] * DEG;
        const lb = lonlat[j * 2] * DEG;
        const fb = lonlat[j * 2 + 1] * DEG;
        const d = wrapPi(lb - la); // the step this edge actually takes
        if (@abs(d) < 1e-12) continue;
        const u = wrapPi(l0 - la); // how far the place is along that step
        // HALF-OPEN, so a vertex sitting exactly on the meridian is counted
        // ONCE and not twice or never. The cap round a pole has a vertex on
        // every round longitude, so the strict form missed the crossing
        // entirely and reported the pole as outside its own cap.
        const on_it = if (d > 0) (u >= 0 and u < d) else (u <= 0 and u > d);
        if (!on_it) continue;
        // the latitude at which the great circle through a and b crosses
        // the place's meridian
        const sab = @sin(lb - la);
        if (@abs(sab) < 1e-12) continue;
        const tf = (@tan(fa) * @sin(lb - l0) + @tan(fb) * @sin(l0 - la)) / sab;
        if (math.atan(tf) > f0) inside = !inside;
    }
    return inside;
}

const Seg = struct {
    pts: std.ArrayList([2]f64) = .{},
    entry: ?f64 = null, // u where it begins on the edge; null = began inside
    exit: ?f64 = null, // u where it ends on the edge; null = ended inside
    used: bool = false,

    fn deinit(self: *Seg) void {
        self.pts.deinit(alloc);
    }
};

/// Where a segment leaves the drawable region between a (in) and b (out):
/// bisection, the same instrument the line path uses for a horizon, and it
/// finds the edge of the PROJECTION too -- a Mercator's 85th parallel is an
/// edge exactly as a globe's horizon is.
fn edgeBetween(p: *const Projection, a: [2]f64, b: [2]f64) [2]f64 {
    return horizonBetween(p, a, b);
}

/// ONE RING, CUT AND REJOINED: closed polygons in the ROTATED frame, each
/// ready to be projected and filled.
fn cutAndRejoin(p: *const Projection, rot: []const [2]f64, out: *std.ArrayList(std.ArrayList([2]f64))) !void {
    const n = rot.len;
    if (n < 3) return;

    // does anything happen at all?
    var any_out = false;
    var any_seam = false;
    for (rot) |q| {
        if (!visible(p, q[0], q[1])) any_out = true;
    }
    var i: usize = 0;
    while (i < n) : (i += 1) {
        const a = rot[i];
        const b = rot[(i + 1) % n];
        if (crossesSeam(p, a[0], b[0])) any_seam = true;
    }
    if (!any_out and !any_seam) {
        var whole: std.ArrayList([2]f64) = .{};
        try whole.appendSlice(alloc, rot);
        try out.append(alloc, whole);
        return;
    }

    var segs: std.ArrayList(Seg) = .{};
    defer {
        for (segs.items) |*sg| sg.deinit();
        segs.deinit(alloc);
    }

    var cur: ?Seg = null;
    if (visible(p, rot[0][0], rot[0][1])) {
        cur = Seg{};
        try cur.?.pts.append(alloc, rot[0]);
    }

    i = 0;
    while (i < n) : (i += 1) {
        const a = rot[i];
        const b = rot[(i + 1) % n];
        const a_in = visible(p, a[0], a[1]);
        const b_in = visible(p, b[0], b[1]);
        if (a_in and b_in) {
            if (crossesSeam(p, a[0], b[0])) {
                const x = seamBetween(a, b);
                try cur.?.pts.append(alloc, x[0]);
                cur.?.exit = boundaryParamOf(p, x[0]);
                try segs.append(alloc, cur.?);
                cur = Seg{ .entry = boundaryParamOf(p, x[1]) };
                try cur.?.pts.append(alloc, x[1]);
                try cur.?.pts.append(alloc, b);
            } else {
                try cur.?.pts.append(alloc, b);
            }
        } else if (a_in and !b_in) {
            const h = edgeBetween(p, a, b);
            try cur.?.pts.append(alloc, h);
            cur.?.exit = boundaryParamOf(p, h);
            try segs.append(alloc, cur.?);
            cur = null;
        } else if (!a_in and b_in) {
            const h = edgeBetween(p, b, a);
            cur = Seg{ .entry = boundaryParamOf(p, h) };
            try cur.?.pts.append(alloc, h);
            try cur.?.pts.append(alloc, b);
        }
    }

    if (cur) |*c| {
        // the walk ended inside: it is the same stretch segment 0 began,
        // seen from the other end of the ring
        if (segs.items.len > 0 and segs.items[0].entry == null) {
            try c.pts.appendSlice(alloc, segs.items[0].pts.items);
            c.exit = segs.items[0].exit;
            segs.items[0].deinit();
            segs.items[0] = c.*;
        } else {
            c.deinit();
        }
        cur = null;
    }

    // NOTHING SURVIVED, so the ring is wholly outside and nothing is drawn.
    //
    // AND THERE IS NO OTHER CASE, which is worth saying because the first
    // version of this file believed there was and carried a branch for it:
    // a ring lying entirely beyond the horizon that nevertheless SWALLOWS
    // the whole visible world, to be answered with the disc itself. Under
    // the rule this file actually uses -- INSIDE IS THE SMALLER OF THE TWO
    // REGIONS A RING BOUNDS, counted by crossings of the meridian through
    // the place -- that cannot happen: a ring wholly on the far side
    // bounds its small region over there too. The branch was unreachable,
    // and a picture proved it by drawing a whole globe blue when the test
    // it rested on was wrong in the other direction.
    //
    // THE LIMIT THAT FOLLOWS IS NAMED RATHER THAN HIDDEN: a region LARGER
    // than a hemisphere cannot be written as one ring here. GeoJSON's own
    // rule would express it by winding -- interior on the left -- and real
    // boundary files disagree about winding so often that this file
    // normalises it away before doing anything else. Parity is the answer a
    // reader expects of a simple ring, and it is the answer given.
    if (segs.items.len == 0) return;

    // REJOIN. From a segment's exit, walk the edge FORWARD -- the drawable
    // side on the left -- to the next segment's entry, and keep going until
    // the ring closes on itself.
    var order = try alloc.alloc(usize, segs.items.len);
    defer alloc.free(order);
    for (order, 0..) |*o, k| o.* = k;
    // insertion sort by entry u; a handful of segments, never a corpus
    var a2: usize = 1;
    while (a2 < order.len) : (a2 += 1) {
        const key = order[a2];
        const ku = segs.items[key].entry orelse 0;
        var b2: usize = a2;
        while (b2 > 0 and (segs.items[order[b2 - 1]].entry orelse 0) > ku) : (b2 -= 1) {
            order[b2] = order[b2 - 1];
        }
        order[b2] = key;
    }

    const STEP: f64 = 1.0 / 720.0; // half a degree of the edge

    for (0..segs.items.len) |start| {
        if (segs.items[start].used) continue;
        var poly: std.ArrayList([2]f64) = .{};
        var at = start;
        var guard: usize = 0;
        while (guard < segs.items.len * 4) : (guard += 1) {
            segs.items[at].used = true;
            try poly.appendSlice(alloc, segs.items[at].pts.items);
            const ex = segs.items[at].exit orelse break;
            // the next entry going forward along the edge
            var best: ?usize = null;
            var best_gap: f64 = 2;
            for (order) |k| {
                const en = segs.items[k].entry orelse continue;
                var gap = en - ex;
                while (gap < 0) gap += 1;
                if (gap < best_gap) {
                    best_gap = gap;
                    best = k;
                }
            }
            const nxt = best orelse break;
            // walk the edge from ex to the entry of nxt
            var u = ex;
            var walked: f64 = 0;
            while (walked < best_gap) {
                u += STEP;
                walked += STEP;
                if (walked >= best_gap) break;
                try poly.append(alloc, boundaryPoint(p, u));
            }
            if (nxt == start) break;
            at = nxt;
        }
        if (poly.items.len >= 3) {
            try out.append(alloc, poly);
        } else {
            poly.deinit(alloc);
        }
    }
}

/// A RING, CLOSED ON THE PAPER. Answers polygons that can be FILLED: where
/// the map cuts the ring, its pieces are rejoined along the map's own edge.
///
/// The ring is normalised counter-clockwise first, because the rejoin walks
/// the edge with the drawable side on the left and a clockwise ring would
/// walk it the wrong way -- and real boundary files disagree about winding
/// whatever the GeoJSON specification says.
pub fn projectRingFilled(p: *const Projection, lonlat: []const f64, out: *Pieces) !void {
    var polys: std.ArrayList(std.ArrayList([2]f64)) = .{};
    defer {
        for (polys.items) |*pl| pl.deinit(alloc);
        polys.deinit(alloc);
    }
    try rotateAndCut(p, lonlat, &polys);
    for (polys.items) |pl| try emitPoly(p, pl.items, out);
}

// ----------------------------------------------------- GE1: a ring with holes
//
// A POLYGON IS AN OUTER RING AND THE HOLES IN IT -- Lesotho inside South
// Africa, a lake inside a county -- and a filler that takes one simple
// ring cannot express that. The standard repair is to BRIDGE: cut a
// zero-width channel from the hole to the outer ring so the two become one
// simple ring that the filler already handles, its inside still inside and
// the hole still out.
//
// THE BRIDGE MUST NOT CROSS ANYTHING, which is the whole of the work. This
// takes the hole's rightmost vertex and tries the outer ring's vertices
// nearest to it, rejecting any pair whose segment crosses an edge of the
// outer ring or of a hole, and takes the first that survives. It is a
// search rather than the textbook's ray cast, and it is chosen for being
// obviously correct rather than obviously fast: it runs once per holed
// region per picture, and a region with a hole is a handful in any file.

fn segsCross(a: [2]f64, b: [2]f64, c: [2]f64, d: [2]f64) bool {
    const d1 = cross2(c, d, a);
    const d2 = cross2(c, d, b);
    const d3 = cross2(a, b, c);
    const d4 = cross2(a, b, d);
    return ((d1 > 0 and d2 < 0) or (d1 < 0 and d2 > 0)) and
        ((d3 > 0 and d4 < 0) or (d3 < 0 and d4 > 0));
}

fn cross2(o: [2]f64, a: [2]f64, b: [2]f64) f64 {
    return (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0]);
}

/// Does the segment a-b cross any edge of `ring`, other than at the two
/// vertices it is allowed to touch?
fn hitsRing(ring: []const [2]f64, a: [2]f64, b: [2]f64, skip_i: usize, has_skip: bool) bool {
    const n = ring.len;
    for (0..n) |i| {
        const j = (i + 1) % n;
        if (has_skip and (i == skip_i or j == skip_i)) continue;
        if (segsCross(a, b, ring[i], ring[j])) return true;
    }
    return false;
}

/// One hole, spliced into the outer ring. Answers the new outer ring, or
/// null when no bridge could be found -- in which case the caller keeps the
/// outer ring whole and says the hole was dropped.
fn bridgeHole(outer: []const [2]f64, hole: []const [2]f64, others: []const []const [2]f64) !?[][2]f64 {
    if (outer.len < 3 or hole.len < 3) return null;
    // the hole's rightmost vertex: the one most likely to see the outside
    var hm: usize = 0;
    for (hole, 0..) |q, i| {
        if (q[0] > hole[hm][0]) hm = i;
    }
    const m = hole[hm];

    // the outer ring's vertices, nearest first
    const order = try alloc.alloc(usize, outer.len);
    defer alloc.free(order);
    for (order, 0..) |*o, i| o.* = i;
    const D = struct {
        fn key(pt: [2]f64, q: [2]f64) f64 {
            const dx = pt[0] - q[0];
            const dy = pt[1] - q[1];
            return dx * dx + dy * dy;
        }
    };
    var a: usize = 1;
    while (a < order.len) : (a += 1) {
        const k = order[a];
        const kk = D.key(m, outer[k]);
        var b: usize = a;
        while (b > 0 and D.key(m, outer[order[b - 1]]) > kk) : (b -= 1) order[b] = order[b - 1];
        order[b] = k;
    }

    for (order) |vi| {
        const v = outer[vi];
        if (hitsRing(outer, m, v, vi, true)) continue;
        if (hitsRing(hole, m, v, hm, true)) continue;
        var bad = false;
        for (others) |o| {
            if (hitsRing(o, m, v, 0, false)) {
                bad = true;
                break;
            }
        }
        if (bad) continue;
        // splice: outer up to v, the hole from m all the way round, back to v
        var outp = try alloc.alloc([2]f64, outer.len + hole.len + 2);
        var w: usize = 0;
        for (0..outer.len) |k| {
            outp[w] = outer[(vi + k) % outer.len];
            w += 1;
        }
        outp[w] = v;
        w += 1;
        // the hole is walked the OTHER way round, so its inside stays out
        for (0..hole.len) |k| {
            outp[w] = hole[(hm + hole.len - k) % hole.len];
            w += 1;
        }
        outp[w] = m;
        w += 1;
        return outp[0..w];
    }
    return null;
}

/// How many holes the last polygon read could not be given. A record that
/// drops counts what it dropped.
var holes_dropped: u32 = 0;

pub fn holesDropped() u32 {
    return holes_dropped;
}

/// A POLYGON -- an outer ring and its holes -- closed on the paper.
///
/// The outer ring is cut and rejoined as always. A hole is bridged into it
/// only when BOTH came through the cut whole; where the map cut either of
/// them, the hole is dropped and counted, because a bridge across a piece
/// that ends at the map's edge would run outside the picture. That case is
/// a lake on the antimeridian, and it is named rather than guessed at.
pub fn projectPolygonFilled(p: *const Projection, rings: []const []const f64, out: *Pieces) !void {
    holes_dropped = 0;
    if (rings.len == 0) return;
    if (rings.len == 1) return projectRingFilled(p, rings[0], out);

    var outer_polys: std.ArrayList(std.ArrayList([2]f64)) = .{};
    defer {
        for (outer_polys.items) |*pl| pl.deinit(alloc);
        outer_polys.deinit(alloc);
    }
    try rotateAndCut(p, rings[0], &outer_polys);
    if (outer_polys.items.len != 1) {
        // the outer ring was cut: draw it, and say the holes were lost
        holes_dropped = @intCast(rings.len - 1);
        for (outer_polys.items) |pl| try emitPoly(p, pl.items, out);
        return;
    }

    var holes: std.ArrayList(std.ArrayList([2]f64)) = .{};
    defer {
        for (holes.items) |*pl| pl.deinit(alloc);
        holes.deinit(alloc);
    }
    for (rings[1..]) |r| {
        var hp: std.ArrayList(std.ArrayList([2]f64)) = .{};
        defer {
            for (hp.items) |*pl| pl.deinit(alloc);
            hp.deinit(alloc);
        }
        try rotateAndCut(p, r, &hp);
        if (hp.items.len == 1) {
            var keep: std.ArrayList([2]f64) = .{};
            try keep.appendSlice(alloc, hp.items[0].items);
            try holes.append(alloc, keep);
        } else {
            holes_dropped += 1;
        }
    }

    var cur = try alloc.alloc([2]f64, outer_polys.items[0].items.len);
    @memcpy(cur, outer_polys.items[0].items);
    var owned = true;
    defer if (owned) alloc.free(cur);

    for (holes.items, 0..) |h, hi| {
        var others: std.ArrayList([]const [2]f64) = .{};
        defer others.deinit(alloc);
        for (holes.items, 0..) |o, oi| {
            if (oi != hi) try others.append(alloc, o.items);
        }
        const merged = try bridgeHole(cur, h.items, others.items);
        if (merged) |mm| {
            alloc.free(cur);
            cur = mm;
            owned = true;
        } else {
            holes_dropped += 1;
        }
    }
    try emitPoly(p, cur, out);
}

/// the rotate-normalise-cut half of projectRingFilled, on its own so the
/// polygon path can use it for an outer ring and for each hole
fn rotateAndCut(p: *const Projection, lonlat: []const f64, out: *std.ArrayList(std.ArrayList([2]f64))) !void {
    const n0 = lonlat.len / 2;
    if (n0 < 3) return;
    var n = n0;
    if (lonlat[0] == lonlat[(n - 1) * 2] and lonlat[1] == lonlat[(n - 1) * 2 + 1]) n -= 1;
    if (n < 3) return;
    const ccw = ringArea(lonlat) >= 0;
    const rot = try alloc.alloc([2]f64, n);
    defer alloc.free(rot);
    for (0..n) |i| {
        const k = if (ccw) i else n - 1 - i;
        rot[i] = rotate(p, lonlat[k * 2] * DEG, lonlat[k * 2 + 1] * DEG);
    }
    try cutAndRejoin(p, rot, out);
}

/// one closed rotated polygon, projected and resampled onto the paper
fn emitPoly(p: *const Projection, pl: []const [2]f64, out: *Pieces) !void {
    if (pl.len < 3) return;
    try out.begin();
    var s = Sampler{ .p = p, .out = out, .open = true };
    try s.emit(pl[0]);
    var i: usize = 1;
    while (i <= pl.len) : (i += 1) {
        try s.arc(pl[i - 1], pl[i % pl.len], 0);
    }
}

/// A closed ring, projected AS A LINE. Its fill across a seam or a horizon
/// is GE0c's problem and not solved here; what this guarantees is that
/// every visible edge is drawn where it belongs.
pub fn projectRing(p: *const Projection, lonlat: []const f64, out: *Pieces) !void {
    const n = lonlat.len / 2;
    if (n < 2) return;
    const closed = lonlat[0] == lonlat[(n - 1) * 2] and lonlat[1] == lonlat[(n - 1) * 2 + 1];
    if (closed) return projectLine(p, lonlat, out);
    const buf = try alloc.alloc(f64, lonlat.len + 2);
    defer alloc.free(buf);
    @memcpy(buf[0..lonlat.len], lonlat);
    buf[lonlat.len] = lonlat[0];
    buf[lonlat.len + 1] = lonlat[1];
    try projectLine(p, buf, out);
}

/// THE GRATICULE: meridians and parallels every `step` degrees, each
/// sampled every `sample` degrees so the resampler has something to bend.
/// Meridians run to +-80 and the poles' neighbourhoods are left to the
/// outline, as d3 does, because forty meridians converging on a point is
/// ink and not information.
pub fn graticule(p: *const Projection, step_deg: f64, out: *Pieces) !void {
    const sample: f64 = 2.5;
    var line: std.ArrayList(f64) = .{};
    defer line.deinit(alloc);
    // meridians
    var lon: f64 = -180;
    while (lon < 180 - 1e-9) : (lon += step_deg) {
        line.clearRetainingCapacity();
        var lat: f64 = -80;
        while (lat <= 80 + 1e-9) : (lat += sample) {
            try line.append(alloc, lon);
            try line.append(alloc, lat);
        }
        try projectLine(p, line.items, out);
    }
    // parallels
    var lat: f64 = -80;
    while (lat <= 80 + 1e-9) : (lat += step_deg) {
        line.clearRetainingCapacity();
        var l2: f64 = -180;
        while (l2 <= 180 + 1e-9) : (l2 += sample) {
            try line.append(alloc, l2);
            try line.append(alloc, lat);
        }
        try projectLine(p, line.items, out);
    }
}

/// THE OUTLINE OF THE WORLD on this projection: for an azimuthal, the
/// horizon circle; for everything else, the seam and the poles, traced in
/// the ROTATED frame and projected raw -- which is exactly what d3 does
/// with the Sphere type, and why a rotated Mollweide still has a Mollweide
/// outline.
pub fn outline(p: *const Projection, out: *Pieces) !void {
    const n: usize = 360;
    try out.begin();
    if (p.kind.isAzimuthal()) {
        const r = p.clip_angle;
        var i: usize = 0;
        while (i <= n) : (i += 1) {
            const t = TAU * @as(f64, @floatFromInt(i % n)) / @as(f64, @floatFromInt(n));
            // a point at angular distance r from the rotated centre
            const f = math.asin(math.clamp(@sin(r) * @cos(t), -1, 1));
            const l = math.atan2(@sin(t) * @sin(r), @cos(r));
            const raw = rawForward(p, l, f) orelse continue;
            try out.point(place(p, raw));
        }
        return;
    }
    const e: f64 = 1e-7;
    // A POLE AT INFINITY HAS NO EDGE TO TRACE. The conformal conic sends
    // one pole to the apex and the other to infinity, and a first version
    // of this outline followed it there: the fit then shrank the whole map
    // to a sliver to make room for a point that does not exist. Its
    // outline stops at the latitude the graticule stops at, and says so.
    // ...and the Mercators stop where Web Mercator stops, so their outline
    // is the closed square it should be rather than two seams and luck
    const lat_lim: f64 = switch (p.kind) {
        .conic_conformal => 80 * DEG,
        .mercator, .transverse_mercator => MERCATOR_LIMIT,
        else => HALF_PI - e,
    };
    // left seam, south to north
    var i: usize = 0;
    while (i <= n / 2) : (i += 1) {
        const f = -lat_lim + 2 * lat_lim * @as(f64, @floatFromInt(i)) / @as(f64, @floatFromInt(n / 2));
        if (rawForward(p, -PI + e, f)) |raw| try out.point(place(p, raw));
    }
    // north pole, west to east
    i = 0;
    while (i <= n) : (i += 1) {
        const l = -PI + e + (TAU - 2 * e) * @as(f64, @floatFromInt(i)) / @as(f64, @floatFromInt(n));
        if (rawForward(p, l, lat_lim)) |raw| try out.point(place(p, raw));
    }
    // right seam, north to south
    i = 0;
    while (i <= n / 2) : (i += 1) {
        const f = lat_lim - 2 * lat_lim * @as(f64, @floatFromInt(i)) / @as(f64, @floatFromInt(n / 2));
        if (rawForward(p, PI - e, f)) |raw| try out.point(place(p, raw));
    }
    // south pole, east to west
    i = 0;
    while (i <= n) : (i += 1) {
        const l = PI - e - (TAU - 2 * e) * @as(f64, @floatFromInt(i)) / @as(f64, @floatFromInt(n));
        if (rawForward(p, l, -lat_lim)) |raw| try out.point(place(p, raw));
    }
}

// ------------------------------------------------------------------ fit

/// Scale and translate so that the projected bounds of `lonlat` fill the
/// box [x0,y0]-[x1,y1] with `pad` px of air. d3's fitExtent. Answers
/// false when nothing projects.
pub fn fitPoints(p: *Projection, lonlat: []const f64, x0: f64, y0: f64, x1: f64, y1: f64, pad: f64) bool {
    const saved_scale = p.scale;
    const saved_tx = p.tx;
    const saved_ty = p.ty;
    p.scale = 1;
    p.tx = 0;
    p.ty = 0;
    var minx: f64 = math.inf(f64);
    var miny: f64 = math.inf(f64);
    var maxx: f64 = -math.inf(f64);
    var maxy: f64 = -math.inf(f64);
    const n = lonlat.len / 2;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        const q = forward(p, lonlat[i * 2], lonlat[i * 2 + 1]) orelse continue;
        if (q[0] < minx) minx = q[0];
        if (q[0] > maxx) maxx = q[0];
        if (q[1] < miny) miny = q[1];
        if (q[1] > maxy) maxy = q[1];
    }
    if (minx > maxx) {
        p.scale = saved_scale;
        p.tx = saved_tx;
        p.ty = saved_ty;
        return false;
    }
    const w = maxx - minx;
    const h = maxy - miny;
    const bw = x1 - x0 - 2 * pad;
    const bh = y1 - y0 - 2 * pad;
    const k = @min(if (w > 0) bw / w else math.inf(f64), if (h > 0) bh / h else math.inf(f64));
    p.scale = k;
    p.tx = x0 + pad + (bw - w * k) / 2 - minx * k;
    p.ty = y0 + pad + (bh - h * k) / 2 - miny * k;
    return true;
}

/// Fit the WHOLE SPHERE -- the outline -- into the box. What a world map
/// asks for.
pub fn fitSphere(p: *Projection, x0: f64, y0: f64, x1: f64, y1: f64, pad: f64) !bool {
    // the outline in pixels at unit scale, then the same arithmetic
    const saved_scale = p.scale;
    const saved_tx = p.tx;
    const saved_ty = p.ty;
    p.scale = 1;
    p.tx = 0;
    p.ty = 0;
    var pieces = Pieces{};
    defer pieces.deinit();
    try outline(p, &pieces);
    var minx: f64 = math.inf(f64);
    var miny: f64 = math.inf(f64);
    var maxx: f64 = -math.inf(f64);
    var maxy: f64 = -math.inf(f64);
    var i: usize = 0;
    while (i + 1 < pieces.xy.items.len) : (i += 2) {
        const x = pieces.xy.items[i];
        const y = pieces.xy.items[i + 1];
        if (x < minx) minx = x;
        if (x > maxx) maxx = x;
        if (y < miny) miny = y;
        if (y > maxy) maxy = y;
    }
    if (minx > maxx) {
        p.scale = saved_scale;
        p.tx = saved_tx;
        p.ty = saved_ty;
        return false;
    }
    const w = maxx - minx;
    const h = maxy - miny;
    const bw = x1 - x0 - 2 * pad;
    const bh = y1 - y0 - 2 * pad;
    const k = @min(if (w > 0) bw / w else math.inf(f64), if (h > 0) bh / h else math.inf(f64));
    p.scale = k;
    p.tx = x0 + pad + (bw - w * k) / 2 - minx * k;
    p.ty = y0 + pad + (bh - h * k) / 2 - miny * k;
    return true;
}

// ---------------------------------------------------------------- tests

test "every projection inverts its own forward at a plain point" {
    inline for (@typeInfo(Kind).@"enum".fields) |f| {
        const k: Kind = @enumFromInt(f.value);
        var p = Projection.fromKind(k);
        p.scale = 200;
        p.tx = 400;
        p.ty = 300;
        const q = forward(&p, 12.5, 41.9).?;
        const back = invert(&p, q[0], q[1]).?;
        try std.testing.expectApproxEqAbs(@as(f64, 12.5), back[0], 1e-6);
        try std.testing.expectApproxEqAbs(@as(f64, 41.9), back[1], 1e-6);
    }
}

test "a rotated sphere inverts too" {
    var p = Projection.fromKind(.orthographic);
    p.rot = .{ -30 * DEG, -40 * DEG, 10 * DEG };
    const q = forward(&p, 2.35, 48.85).?;
    const back = invert(&p, q[0], q[1]).?;
    try std.testing.expectApproxEqAbs(@as(f64, 2.35), back[0], 1e-6);
    try std.testing.expectApproxEqAbs(@as(f64, 48.85), back[1], 1e-6);
}

test "the far side of the globe is not drawn" {
    const p = Projection.fromKind(.orthographic);
    try std.testing.expect(forward(&p, 170, 0) == null);
    try std.testing.expect(forward(&p, 10, 0) != null);
}

test "the area of an octant is an eighth of the sphere" {
    // (0,0) -> (90,0) -> (0,90): three great-circle edges, exactly 4pi/8
    const a = ringArea(&[_]f64{ 0, 0, 90, 0, 0, 90, 0, 0 });
    try std.testing.expectApproxEqRel(math.pi / 2.0, @abs(a), 1e-9);
}

test "two lat-lon boxes of equal true area measure equal" {
    // A BOX IS NOT A GEODESIC POLYGON: its top and bottom follow parallels,
    // which are not great circles, so the four corners alone describe a
    // different shape. Densify the parallels and the areas agree.
    var r1: std.ArrayList(f64) = .{};
    defer r1.deinit(alloc);
    var r2: std.ArrayList(f64) = .{};
    defer r2.deinit(alloc);
    try boxRing(&r1, 0, 0, 10, 10);
    try boxRing(&r2, 0, 30, 10, 42.347);
    const a1 = @abs(ringArea(r1.items));
    const a2 = @abs(ringArea(r2.items));
    try std.testing.expectApproxEqRel(a1, a2, 1e-3);
    // and the closed form: dLon * (sin lat1 - sin lat0)
    try std.testing.expectApproxEqRel(10 * DEG * @sin(10 * DEG), a1, 1e-4);
}

fn boxRing(out: *std.ArrayList(f64), lon0: f64, lat0: f64, lon1: f64, lat1: f64) !void {
    const n: usize = 100;
    var i: usize = 0;
    while (i <= n) : (i += 1) {
        const t = @as(f64, @floatFromInt(i)) / @as(f64, @floatFromInt(n));
        try out.append(alloc, lon0 + (lon1 - lon0) * t);
        try out.append(alloc, lat0);
    }
    i = 0;
    while (i <= n) : (i += 1) {
        const t = @as(f64, @floatFromInt(i)) / @as(f64, @floatFromInt(n));
        try out.append(alloc, lon1 - (lon1 - lon0) * t);
        try out.append(alloc, lat1);
    }
    try out.append(alloc, lon0);
    try out.append(alloc, lat0);
}

test "interpolation stays on the sphere and ends where it should" {
    const a = [2]f64{ 0, 0 };
    const b = [2]f64{ HALF_PI, 0 };
    const m = interpolate(a, b, 0.5);
    try std.testing.expectApproxEqAbs(HALF_PI / 2, m[0], 1e-9);
    try std.testing.expectApproxEqAbs(@as(f64, 0), m[1], 1e-9);
    const e = interpolate(a, b, 1);
    try std.testing.expectApproxEqAbs(HALF_PI, e[0], 1e-9);
}

test "a ring contains what is inside it, and not what is outside" {
    const box = [_]f64{ -10, -10, 10, -10, 10, 10, -10, 10 };
    try std.testing.expect(ringContains(&box, 0, 0));
    try std.testing.expect(!ringContains(&box, 20, 0));
    try std.testing.expect(!ringContains(&box, 0, 20));
}

test "a ring that wraps the antimeridian does not swallow the far side" {
    // the cap south of 60S, written as a closed ring of longitudes
    var cap: [2 * 48]f64 = undefined;
    for (0..48) |i| {
        cap[i * 2] = -180 + 360 * @as(f64, @floatFromInt(i)) / 48;
        cap[i * 2 + 1] = -60;
    }
    try std.testing.expect(ringContains(&cap, 0, -85)); // the south pole is in it
    try std.testing.expect(!ringContains(&cap, 0, 85)); // the north pole is NOT
    try std.testing.expect(!ringContains(&cap, 0, 0));
}
