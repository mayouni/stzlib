//! GE9 -- WHAT A PROJECTION DOES TO THE GROUND, MEASURED.
//!
//! Every projection lies. A sphere cannot be flattened without tearing,
//! stretching or shearing it, so the only question is WHERE the lie is put
//! and how big it is -- and until now this plane could answer that only in
//! words: `isEqualArea`, `isConformal`, two booleans and a rule that reads
//! them. That is enough to refuse a choropleth on a Mercator and not enough
//! to tell a reader that Greenland on that map is fourteen times its area.
//!
//! THE JACOBIAN ANSWERS ALL OF IT. A projection is a map from (lambda, phi)
//! to (x, y); its derivative at a point is four numbers; and every classical
//! distortion measure is a function of those four:
//!
//!     h  the scale along the MERIDIAN      sqrt(xp^2 + yp^2)
//!     k  the scale along the PARALLEL      sqrt(xl^2 + yl^2) / cos(phi)
//!     s  the AREAL scale                   |det J| / cos(phi)
//!     w  the maximum ANGULAR deformation   2 asin((a - b)/(a + b))
//!
//! with a and b the semi-axes of Tissot's indicatrix -- the ellipse an
//! infinitesimal circle on the sphere becomes on the paper. The cos(phi)
//! divisions are not cosmetic: the metric on the sphere is
//! ds^2 = cos^2(phi) dlambda^2 + dphi^2, so a derivative with respect to
//! longitude has to be divided by cos(phi) to become a scale factor. Forget
//! it and every projection looks conformal at the equator and wrong
//! everywhere else.
//!
//! AND THE SAME JACOBIAN INVERTS THE PROJECTION. Most of the gallery has no
//! closed-form inverse -- the Winkel tripel famously has none, and nor do
//! the Eckerts, the Aitoff or the polyconic without a page of algebra
//! each -- so the inverse here is Newton's method in two dimensions on the
//! forward map, using this derivative. One mechanism, two jobs, and adding a
//! projection to the gallery means adding ONE function.
//!
//! WHICH IS ALSO WHY THE ROUND TRIP PROVES NOTHING ABOUT A NEW FORMULA. A
//! generic inverse is consistent with whatever forward it is given, right or
//! wrong. What catches a wrong formula is the MEASURES: a projection that
//! claims equal area must show areal scale 1 everywhere, and that number is
//! computed from the derivative rather than from the formula's own
//! arithmetic. See the note at the top of rawForwardGallery.
//!
//! THE DERIVATIVE IS TAKEN NUMERICALLY, by central differences, and that is
//! a deliberate choice of the same kind geo_geodesy.zig made about Karney's
//! series. Analytic derivatives for forty-four projections would be
//! forty-four more formulas to transcribe correctly, each one able to be
//! subtly wrong while looking right, and there would be no independent thing
//! left to check them against -- the measures ARE the check. A central
//! difference at a well-chosen step is accurate to about twelve digits on a
//! smooth map, which is far past what any picture or any test needs.

const std = @import("std");
const math = std.math;
const gp = @import("geo_projection.zig");

const DEG: f64 = math.pi / 180.0;

// THE JACOBIAN ITSELF LIVES IN geo_projection.zig, not here, because the
// numeric INVERSE needs it too and geo_projection cannot import this file
// without the two importing each other. One derivative, two callers, and
// the file that owns the projections owns the derivative of a projection.

/// WHAT THE PROJECTION DOES TO AN INFINITESIMAL CIRCLE AT ONE PLACE --
/// Tissot's indicatrix, as numbers rather than as a drawn ellipse.
pub const Distortion = struct {
    /// the scale along the meridian, 1 meaning true
    h: f64,
    /// the scale along the parallel
    k: f64,
    /// the semi-axes of the ellipse: the greatest and least scale in ANY
    /// direction, which are not generally h and k -- those two are the
    /// scales along two particular directions that need not be the
    /// extremes, and confusing the pairs is the classic error here
    a: f64,
    b: f64,
    /// the AREAL scale: 1 on an equal-area projection, everywhere
    areal: f64,
    /// the MAXIMUM ANGULAR DEFORMATION, degrees: 0 on a conformal
    /// projection, everywhere. The largest amount by which any angle at
    /// this point is bent.
    angular: f64,
    /// the angle the meridian and the parallel cross at on the paper,
    /// degrees -- 90 where the projection keeps them square
    crossing: f64,
    ok: bool,
};

pub fn distortionAt(p: *const gp.Projection, lon_deg: f64, lat_deg: f64) Distortion {
    const j = gp.jacobian(p, lon_deg, lat_deg);
    const none = Distortion{ .h = 0, .k = 0, .a = 0, .b = 0, .areal = 0, .angular = 0, .crossing = 0, .ok = false };
    if (!j.ok) return none;
    const cf = @cos(lat_deg * DEG);
    if (@abs(cf) < 1e-9) return none; // at a pole the parallel has no length
    const h = @sqrt(j.xp * j.xp + j.yp * j.yp);
    const k = @sqrt(j.xl * j.xl + j.yl * j.yl) / cf;
    const areal = @abs(j.det()) / cf;
    if (h <= 0 or k <= 0) return none;
    // sin of the angle between the two, from the area they span
    const sin_t = math.clamp(areal / (h * k), -1, 1);
    // THE SEMI-AXES, by the standard construction: a+b and a-b come out of
    // h, k and that angle, and the two are then separated. Writing a and b
    // directly is where the h/k confusion above gets made.
    const sum = @sqrt(@max(0, h * h + k * k + 2 * h * k * sin_t));
    const dif = @sqrt(@max(0, h * h + k * k - 2 * h * k * sin_t));
    const a = (sum + dif) / 2;
    const b = (sum - dif) / 2;
    var ang: f64 = 0;
    if (a + b > 0) {
        ang = 2 * math.asin(math.clamp((a - b) / (a + b), -1, 1)) / DEG;
    }
    return .{
        .h = h,
        .k = k,
        .a = a,
        .b = b,
        .areal = areal,
        .angular = ang,
        .crossing = math.asin(sin_t) / DEG,
        .ok = true,
    };
}

/// THE WORST AND THE AVERAGE OVER THE WHOLE MAP, which is how two
/// projections get compared at all. The average is weighted by GROUND --
/// cos(phi) per cell -- because an unweighted average over a latitude grid
/// counts the polar rows, which are slivers, as heavily as the equatorial
/// ones, which are not, and that flatters exactly the projections that are
/// worst at the poles.
pub const Summary = struct {
    areal_min: f64,
    areal_max: f64,
    areal_mean: f64,
    angular_max: f64,
    angular_mean: f64,
    sampled: usize,
};

pub fn summarise(p: *const gp.Projection, nx: usize, ny: usize) Summary {
    var out = Summary{
        .areal_min = math.inf(f64),
        .areal_max = 0,
        .areal_mean = 0,
        .angular_max = 0,
        .angular_mean = 0,
        .sampled = 0,
    };
    var wsum: f64 = 0;
    var j: usize = 0;
    while (j < ny) : (j += 1) {
        const t = (@as(f64, @floatFromInt(j)) + 0.5) / @as(f64, @floatFromInt(ny));
        const lat = -90 + 180 * t;
        const w = @cos(lat * DEG);
        if (w <= 0) continue;
        var i: usize = 0;
        while (i < nx) : (i += 1) {
            const u = (@as(f64, @floatFromInt(i)) + 0.5) / @as(f64, @floatFromInt(nx));
            const lon = -180 + 360 * u;
            const d = distortionAt(p, lon, lat);
            if (!d.ok or !math.isFinite(d.areal) or !math.isFinite(d.angular)) continue;
            if (d.areal < out.areal_min) out.areal_min = d.areal;
            if (d.areal > out.areal_max) out.areal_max = d.areal;
            if (d.angular > out.angular_max) out.angular_max = d.angular;
            out.areal_mean += d.areal * w;
            out.angular_mean += d.angular * w;
            wsum += w;
            out.sampled += 1;
        }
    }
    if (wsum > 0) {
        out.areal_mean /= wsum;
        out.angular_mean /= wsum;
    }
    if (out.sampled == 0) out.areal_min = 0;
    return out;
}

/// TISSOT'S INDICATRIX AS A RING TO DRAW: the ellipse that an
/// infinitesimal circle of the given angular radius becomes, in the
/// paper's own coordinates, ready for a canvas.
///
/// It is built by PROJECTING A SMALL CIRCLE rather than by drawing the
/// ellipse the numbers above describe. The two agree in the limit and the
/// first is the honest one: it shows what the projection actually does to
/// a circle of that size, including the bending that an ellipse cannot
/// represent, which at a radius anybody can see is not nothing.
pub fn indicatrix(p: *const gp.Projection, lon_deg: f64, lat_deg: f64, radius_deg: f64, n: usize, out: []f64) usize {
    if (n < 3 or out.len < n * 2) return 0;
    var got: usize = 0;
    const f0 = lat_deg * DEG;
    const l0 = lon_deg * DEG;
    const r = radius_deg * DEG;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        const b = 2 * math.pi * @as(f64, @floatFromInt(i)) / @as(f64, @floatFromInt(n));
        // a point at angular distance r on bearing b -- the same spherical
        // step the range rings use, so a circle here is a circle there
        const sf = @sin(f0) * @cos(r) + @cos(f0) * @sin(r) * @cos(b);
        const f2 = math.asin(math.clamp(sf, -1, 1));
        const l2 = l0 + math.atan2(@sin(b) * @sin(r) * @cos(f0), @cos(r) - @sin(f0) * sf);
        const q = gp.forward(p, l2 / DEG, f2 / DEG) orelse continue;
        out[got * 2] = q[0];
        out[got * 2 + 1] = q[1];
        got += 1;
    }
    return got;
}

// ------------------------------------------------------------ UTM zones
//
// UTM IS SIXTY TRANSVERSE MERCATORS, one per six degrees of longitude, each
// scaled by 0.9996 so the error is shared between the middle of the zone and
// its edges rather than piled at the edges. Within a zone it is accurate to
// about one part in 2500, which is why it is the projection every survey,
// every military map and every GPS receiver falls back to.
//
// THE EXCEPTIONS ARE REAL AND ARE NOT TIDY. Zone 32 was widened in 1950 so
// that south-west Norway is not cut in half, and the Svalbard zones were
// rearranged for the same reason. A library that computes the zone
// arithmetically and stops is wrong for two countries, and it is wrong
// silently.

pub const Utm = struct {
    zone: u8,
    /// true for the northern hemisphere, which decides the false northing
    north: bool,
    central_meridian: f64,
    /// the MGRS latitude band letter, C at 80S through X at 84N, with I and
    /// O left out because they read as 1 and 0
    band: u8,
};

pub fn utmZoneOf(lon_deg: f64, lat_deg: f64) Utm {
    var lon = lon_deg;
    while (lon < -180) lon += 360;
    while (lon >= 180) lon -= 360;
    var z: i32 = @intFromFloat(@floor((lon + 180) / 6) + 1);
    if (z < 1) z = 1;
    if (z > 60) z = 60;

    // Norway: zone 32 widened westward across southern Norway
    if (lat_deg >= 56 and lat_deg < 64 and lon >= 3 and lon < 12) z = 32;
    // Svalbard: 31, 33, 35 and 37 widened, 32, 34 and 36 removed
    if (lat_deg >= 72 and lat_deg < 84) {
        if (lon >= 0 and lon < 9) {
            z = 31;
        } else if (lon >= 9 and lon < 21) {
            z = 33;
        } else if (lon >= 21 and lon < 33) {
            z = 35;
        } else if (lon >= 33 and lon < 42) {
            z = 37;
        }
    }
    return .{
        .zone = @intCast(z),
        .north = lat_deg >= 0,
        .central_meridian = -183.0 + 6.0 * @as(f64, @floatFromInt(z)),
        .band = utmBand(lat_deg),
    };
}

fn utmBand(lat: f64) u8 {
    if (lat < -80 or lat > 84) return 'Z'; // outside UTM's own range
    const letters = "CDEFGHJKLMNPQRSTUVWX";
    var i: usize = @intFromFloat(@floor((lat + 80) / 8));
    if (i > 19) i = 19;
    return letters[i];
}

/// THE PROJECTION FOR A ZONE, ready to use: a transverse Mercator rotated
/// onto the zone's central meridian, at UTM's own scale factor. The false
/// easting and northing are the caller's to add, because they are a
/// coordinate CONVENTION rather than part of the projection -- and because
/// the northing's value depends on the hemisphere, which a projection
/// object has no business knowing.
pub fn utmProjection(zone: u8) gp.Projection {
    var p = gp.Projection.fromKind(.transverse_mercator);
    const cm = -183.0 + 6.0 * @as(f64, @floatFromInt(zone));
    p.rot = .{ -cm * DEG, 0, 0 };
    p.scale = 0.9996;
    p.tx = 0;
    p.ty = 0;
    return p;
}

pub fn utmFalseEasting() f64 {
    return 500000;
}

/// ...and the northing offset, which is zero in the north and ten million
/// in the south so that no coordinate is ever negative. That is the whole
/// reason it exists.
pub fn utmFalseNorthing(north: bool) f64 {
    return if (north) 0 else 10000000;
}
