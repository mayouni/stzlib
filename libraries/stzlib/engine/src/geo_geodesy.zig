//! GE8 -- GEODESY ON THE ELLIPSOID.
//!
//! Everything this plane measured until now ran on a SPHERE of radius
//! 6371.0088 km. That is a defensible sphere -- it is the one whose volume
//! matches the Earth's -- and it is still a sphere. The Earth is flattened
//! by about 1/298, so a sphere gets a distance wrong by up to ~0.5%: a
//! north-south line comes out short and an east-west line long, and an
//! analyst comparing our answer to a GPS or to Wolfram finds the gap and is
//! right to. This module is where that ends.
//!
//! WHAT A GEODESIC IS. On a sphere the shortest path between two points is
//! an arc of a great circle, and every great circle closes. On an ellipsoid
//! neither is true: the shortest path generally does NOT close on itself,
//! it is not planar, and there is no elementary formula for its length. So
//! geodesy does not guess -- it reduces the problem to one that IS solvable
//! and carries the reduction exactly.
//!
//! THE REDUCTION (Bessel 1825, in the arrangement Karney gave it in 2013).
//! Map each point to its REDUCED latitude, tan(beta) = (1-f) tan(phi) --
//! geometrically, project the point vertically onto a sphere of radius a.
//! A geodesic on the ellipsoid maps to a GREAT CIRCLE on that auxiliary
//! sphere, exactly. Spherical trigonometry then answers the angles for
//! free, and the only work left is two integrals that carry the distance
//! and the longitude back to the ellipsoid:
//!
//!     s / b   = I1(sigma) = INTEGRAL sqrt(1 + k^2 sin^2 s') ds'
//!     lambda  = omega - f sin(alpha0) I3(sigma)
//!     I3      = INTEGRAL (2-f) / (1 + (1-f) sqrt(1 + k^2 sin^2 s')) ds'
//!
//! with k^2 = e'^2 cos^2(alpha0), alpha0 the azimuth where the geodesic
//! crosses the equator, and sigma the arc along the auxiliary sphere.
//!
//! TWO CHECKS OF THAT, DERIVED RATHER THAN REMEMBERED, because a wrong
//! coefficient in a series like this produces a plausible number and no
//! symptom at all:
//!
//!   * A MERIDIAN has alpha0 = 0, so k^2 = e'^2 and s = b INTEGRAL
//!     sqrt(1 + e'^2 sin^2 t) dt over the reduced latitude -- which is the
//!     standard closed form of the meridian arc in the parametric
//!     latitude. It agrees.
//!   * THE EQUATOR has alpha0 = 90 degrees, so k = 0, I1(sigma) = sigma
//!     and s = b sigma. Meanwhile I3(sigma) = sigma (2-f)/(2-f) = sigma,
//!     so lambda = sigma - f sigma = (1-f) sigma, and therefore
//!     s = b sigma = a (1-f) sigma = a lambda. The length of a stretch of
//!     equator is its longitude times the equatorial radius, which is the
//!     one distance on this surface everybody already knows.
//!
//! WHY THE INTEGRALS ARE QUADRATURE AND NOT KARNEY'S SERIES. Karney expands
//! I1 and I3 as trigonometric series in eps = (sqrt(1+k^2)-1)/(sqrt(1+k^2)+1)
//! to sixth order, which is fast and is what GeographicLib ships. Those
//! series are two dozen rational coefficients, and a single mistyped one --
//! 205/1536 for 209/1536, say -- yields distances wrong in the eighth
//! digit, which no picture shows, no round trip catches, and no reviewer
//! sees. The INTEGRANDS above, by contrast, are the definition: they are
//! three lines each, they can be read against the derivation, and the two
//! checks above test them. So the integrals are evaluated by Gauss-Legendre
//! quadrature whose own nodes are computed from the Legendre recurrence at
//! startup rather than transcribed. NOTHING IN THIS FILE IS A CONSTANT
//! SOMEBODY HAD TO COPY CORRECTLY except the defining a and 1/f of each
//! reference ellipsoid, which are four-digit numbers a reader can check
//! against a standards document in seconds.
//!
//! The cost is speed, not accuracy: sixteen-point Gauss-Legendre on an
//! integrand this smooth is at machine precision, and an inverse solve runs
//! a few hundred square roots instead of a few dozen multiplies. For a
//! plane that draws maps and measures countries that is not the binding
//! constraint; if it ever becomes one, the series can be added BESIDE this
//! and gated by a test that the two agree, which is the only safe way to
//! introduce coefficients nobody can eyeball.

const std = @import("std");
const math = std.math;

pub const DEG: f64 = math.pi / 180.0;

// ------------------------------------------------------------------ the
// ------------------------------------------------- reference ellipsoids
//
// A DATUM IS A CLAIM ABOUT WHICH ELLIPSOID THE COORDINATES ARE ON, and a
// coordinate without one is not a position. The difference is not
// academic: the same latitude and longitude on Airy 1830 and on WGS84 are
// a few hundred metres apart in Britain, which is why a walker's map and
// a phone disagree about where a path is.
//
// Each row is the DEFINING pair -- the equatorial radius in metres and the
// inverse flattening -- exactly as the defining document gives it. Every
// other quantity (b, e^2, the authalic radius) is derived here rather than
// tabulated, so no two numbers in this file can disagree with each other.

pub const Ellipsoid = struct {
    a: f64,
    f: f64,

    pub fn fromInvF(a: f64, inv_f: f64) Ellipsoid {
        return .{ .a = a, .f = if (inv_f == 0) 0 else 1 / inv_f };
    }
    pub fn sphere(r: f64) Ellipsoid {
        return .{ .a = r, .f = 0 };
    }
    pub fn b(self: Ellipsoid) f64 {
        return self.a * (1 - self.f);
    }
    /// first eccentricity squared
    pub fn e2(self: Ellipsoid) f64 {
        return self.f * (2 - self.f);
    }
    /// second eccentricity squared, e'^2 = e^2/(1-e^2)
    pub fn ep2(self: Ellipsoid) f64 {
        const t = self.e2();
        return t / (1 - t);
    }
    pub fn ecc(self: Ellipsoid) f64 {
        return @sqrt(self.e2());
    }
    /// third flattening, n = f/(2-f)
    pub fn thirdFlattening(self: Ellipsoid) f64 {
        return self.f / (2 - self.f);
    }
    /// THE WHOLE SURFACE, m^2 -- 2 pi [a^2 + b^2 atanh(e)/e], the closed
    /// form for an oblate spheroid. Used as its own check: a polygon area
    /// may never exceed it, and a polygon that encloses a pole is
    /// recognised by coming out larger than half of it.
    pub fn surfaceArea(self: Ellipsoid) f64 {
        const bb = self.b();
        if (self.f == 0) return 4 * math.pi * self.a * self.a;
        const e = self.ecc();
        return 2 * math.pi * (self.a * self.a + bb * bb * atanh(e) / e);
    }
    /// the radius of the sphere with the same surface area
    pub fn authalicRadius(self: Ellipsoid) f64 {
        return @sqrt(self.surfaceArea() / (4 * math.pi));
    }
};

// The name is sentinel-terminated on purpose: it crosses to Ring as a C
// string, and a slice that merely happens to sit next to a zero byte is
// the kind of thing that works until somebody reorders the table.
pub const Named = struct { name: [:0]const u8, e: Ellipsoid };

pub const table = [_]Named{
    .{ .name = "WGS84", .e = Ellipsoid.fromInvF(6378137.0, 298.257223563) },
    .{ .name = "GRS80", .e = Ellipsoid.fromInvF(6378137.0, 298.257222101) },
    .{ .name = "WGS72", .e = Ellipsoid.fromInvF(6378135.0, 298.26) },
    .{ .name = "GRS67", .e = Ellipsoid.fromInvF(6378160.0, 298.247167427) },
    .{ .name = "Airy1830", .e = Ellipsoid.fromInvF(6377563.396, 299.3249646) },
    .{ .name = "AiryModified", .e = Ellipsoid.fromInvF(6377340.189, 299.3249646) },
    .{ .name = "Bessel1841", .e = Ellipsoid.fromInvF(6377397.155, 299.1528128) },
    .{ .name = "Clarke1866", .e = Ellipsoid.fromInvF(6378206.4, 294.9786982) },
    .{ .name = "Clarke1880", .e = Ellipsoid.fromInvF(6378249.145, 293.465) },
    .{ .name = "International1924", .e = Ellipsoid.fromInvF(6378388.0, 297.0) },
    .{ .name = "Krassovsky1940", .e = Ellipsoid.fromInvF(6378245.0, 298.3) },
    .{ .name = "Everest1830", .e = Ellipsoid.fromInvF(6377276.345, 300.8017) },
    .{ .name = "AustralianNational", .e = Ellipsoid.fromInvF(6378160.0, 298.25) },
    .{ .name = "SouthAmerican1969", .e = Ellipsoid.fromInvF(6378160.0, 298.25) },
    // THE SPHERE THIS PLANE USED UNTIL NOW, kept as a row rather than
    // deleted: it is what every measure in GE0-GE7 answers, so a caller can
    // ask this module for the OLD number and see the gap for themselves.
    .{ .name = "Sphere", .e = Ellipsoid.sphere(6371008.8) },
};

pub fn byIndex(i: usize) ?Ellipsoid {
    if (i >= table.len) return null;
    return table[i].e;
}
pub fn nameOf(i: usize) [:0]const u8 {
    if (i >= table.len) return "";
    return table[i].name;
}
pub fn indexOf(name: []const u8) ?usize {
    for (table, 0..) |row, i| {
        if (row.name.len != name.len) continue;
        var same = true;
        for (row.name, name) |x, y| {
            if (lower(x) != lower(y)) {
                same = false;
                break;
            }
        }
        if (same) return i;
    }
    return null;
}
fn lower(c: u8) u8 {
    return if (c >= 'A' and c <= 'Z') c + 32 else c;
}

pub const WGS84 = Ellipsoid.fromInvF(6378137.0, 298.257223563);

fn atanh(x: f64) f64 {
    return 0.5 * @log((1 + x) / (1 - x));
}

// --------------------------------------------------------------- the
// -------------------------------------------- quadrature, built not typed
//
// Gauss-Legendre of order N integrates a polynomial of degree 2N-1 exactly
// and an integrand as smooth as these to machine precision with N = 16. Its
// nodes are the roots of the Legendre polynomial P_N, and its weights are
// 2/((1-x^2) P'_N(x)^2). Both are COMPUTED HERE, by Newton on the three-term
// recurrence, for the reason the file header gives: a table of sixteen
// sixteen-digit numbers is sixteen chances to introduce an error that no
// test in this repository would catch.
//
// It is built ONCE at load rather than lazily on first use -- the perf
// plane's rule for anything a copied object might otherwise rebuild, and
// here also the answer to "is this table racy", which it cannot be if
// nothing writes it after startup.

const GL_N: usize = 16;

var gl_x: [GL_N]f64 = undefined;
var gl_w: [GL_N]f64 = undefined;
var gl_ready: bool = false;

pub fn initQuadrature() void {
    if (gl_ready) return;
    const n = GL_N;
    const nf: f64 = @floatFromInt(n);
    var i: usize = 0;
    while (i < n) : (i += 1) {
        // Chebyshev's approximation to the i-th root, which Newton then
        // sharpens; any starting point in the right well would do.
        const if_: f64 = @floatFromInt(i);
        var x = @cos(math.pi * (if_ + 0.75) / (nf + 0.5));
        var it: usize = 0;
        var dp: f64 = 0;
        while (it < 100) : (it += 1) {
            // P_n(x) and P'_n(x) by the recurrence
            //   k P_k = (2k-1) x P_{k-1} - (k-1) P_{k-2}
            var p0: f64 = 1;
            var p1: f64 = x;
            var k: usize = 2;
            while (k <= n) : (k += 1) {
                const kf: f64 = @floatFromInt(k);
                const p2 = ((2 * kf - 1) * x * p1 - (kf - 1) * p0) / kf;
                p0 = p1;
                p1 = p2;
            }
            dp = nf * (x * p1 - p0) / (x * x - 1);
            const dx = p1 / dp;
            x -= dx;
            if (@abs(dx) < 1e-16) break;
        }
        gl_x[i] = x;
        gl_w[i] = 2 / ((1 - x * x) * dp * dp);
    }
    gl_ready = true;
}

/// INTEGRATE f from 0 to sigma. The interval is split into panels of at
/// most pi/2 so that a long geodesic -- sigma up to pi, and up to 2 pi for
/// a rhumb's meridian work -- is not asked of one rule over a wide arc.
fn integrate(sigma: f64, ctx: anytype, comptime f: fn (@TypeOf(ctx), f64) f64) f64 {
    return integrateRange(0, sigma, ctx, f);
}

/// ...and over an interval that does not start at zero. Differencing two
/// integrals-from-zero gives the same answer in exact arithmetic and a much
/// worse one in floating point: for a short edge far from the origin it
/// subtracts two large numbers to get a small one, and the area routine
/// below has edges exactly like that.
fn integrateRange(lo: f64, hi: f64, ctx: anytype, comptime f: fn (@TypeOf(ctx), f64) f64) f64 {
    if (hi == lo) return 0;
    initQuadrature();
    const span = @abs(hi - lo);
    var panels: usize = @intFromFloat(@ceil(span / (math.pi / 2.0)));
    if (panels < 1) panels = 1;
    const h = (hi - lo) / @as(f64, @floatFromInt(panels));
    var total: f64 = 0;
    var p: usize = 0;
    while (p < panels) : (p += 1) {
        const a0 = lo + h * @as(f64, @floatFromInt(p));
        const b0 = a0 + h;
        const mid = (a0 + b0) / 2.0;
        const half = (b0 - a0) / 2.0;
        var s: f64 = 0;
        for (0..GL_N) |i| s += gl_w[i] * f(ctx, mid + half * gl_x[i]);
        total += s * half;
    }
    return total;
}

// ------------------------------------------------------------ the three
// ----------------------------------------------- integrands, as defined

const Arc = struct {
    k2: f64,
    f: f64,

    /// ds/dsigma / b
    fn dI1(self: Arc, s: f64) f64 {
        const ss = @sin(s);
        return @sqrt(1 + self.k2 * ss * ss);
    }
    /// dI2/dsigma -- the reciprocal, which carries the REDUCED LENGTH
    fn dI2(self: Arc, s: f64) f64 {
        const ss = @sin(s);
        return 1 / @sqrt(1 + self.k2 * ss * ss);
    }
    /// dI3/dsigma -- the longitude's correction
    fn dI3(self: Arc, s: f64) f64 {
        return self.dI3Sin(@sin(s));
    }
    /// the same, taken at a sin(sigma) the caller already has. The area
    /// integral works in omega and never forms sigma, so it hands the sine
    /// straight in rather than taking an arcsine only to undo it.
    fn dI3Sin(self: Arc, ss: f64) f64 {
        const t = @sqrt(1 + self.k2 * ss * ss);
        return (2 - self.f) / (1 + (1 - self.f) * t);
    }
};

fn intI1(arc: Arc, sigma: f64) f64 {
    return integrate(sigma, arc, Arc.dI1);
}
fn intI2(arc: Arc, sigma: f64) f64 {
    return integrate(sigma, arc, Arc.dI2);
}
fn intI3(arc: Arc, sigma: f64) f64 {
    return integrate(sigma, arc, Arc.dI3);
}

// ------------------------------------------------------------------ the
// ----------------------------------------------------- geodesic problems

pub const Inverse = struct {
    /// metres
    s12: f64,
    /// degrees, clockwise from north, at point 1 and at point 2
    azi1: f64,
    azi2: f64,
    /// the REDUCED LENGTH, metres. Two geodesics leaving point 1 a tiny
    /// angle apart are m12 times that angle apart at point 2 -- so it is
    /// how much the surface has spread or squeezed the pencil of paths,
    /// and where it passes through zero the two points are CONJUGATE and
    /// the geodesic has stopped being the shortest path.
    m12: f64,
    /// arc on the auxiliary sphere, degrees
    a12: f64,
    /// iterations the solver took; 0 for a case answered in closed form
    iterations: usize,
};

pub const Direct = struct {
    lat2: f64,
    lon2: f64,
    azi2: f64,
    m12: f64,
    a12: f64,
};

fn hypot2(x: f64, y: f64) f64 {
    return @sqrt(x * x + y * y);
}

/// reduced (parametric) latitude from geodetic, radians in and out
fn reduced(e: Ellipsoid, phi: f64) f64 {
    return math.atan2((1 - e.f) * @sin(phi), @cos(phi));
}
fn geodetic(e: Ellipsoid, beta: f64) f64 {
    return math.atan2(@sin(beta), (1 - e.f) * @cos(beta));
}

/// normalise an angle in radians to (-pi, pi]
fn wrapPi(x: f64) f64 {
    var t = @mod(x + math.pi, 2 * math.pi);
    if (t < 0) t += 2 * math.pi;
    return t - math.pi;
}

/// THE STATE OF ONE CANDIDATE GEODESIC, given where it starts and which way
/// it leaves. Everything the solver needs comes out of this one function,
/// which is why the inverse problem below is a root find over a single
/// number and not a special case per quadrant.
const Leg = struct {
    lam12: f64, // the longitude difference this azimuth produces
    s12: f64,
    azi2: f64,
    m12: f64,
    sig12: f64,
};

fn legFor(e: Ellipsoid, beta1: f64, beta2: f64, alpha1: f64) Leg {
    const f = e.f;
    const sb1 = @sin(beta1);
    const cb1 = @cos(beta1);
    const sb2 = @sin(beta2);
    const cb2 = @cos(beta2);
    const sa1 = @sin(alpha1);
    const ca1 = @cos(alpha1);

    // the equator crossing: sin(alpha0) is conserved along the geodesic
    // (Clairaut), which is the whole reason this reduction works
    const sa0 = sa1 * cb1;
    const ca0 = hypot2(ca1, sa1 * sb1);

    const sig1 = math.atan2(sb1, ca1 * cb1);
    const om1 = math.atan2(sa0 * @sin(sig1), @cos(sig1));

    // the azimuth at point 2, again from Clairaut: sin(a2) cos(b2) = sin(a0)
    const sa2 = if (cb2 == 0) 1.0 else sa0 / cb2;
    var ca2sq = (ca1 * cb1) * (ca1 * cb1) + (cb2 * cb2 - cb1 * cb1);
    if (ca2sq < 0) ca2sq = 0;
    const ca2 = @sqrt(ca2sq) / (if (cb2 == 0) 1.0 else cb2);

    const sig2 = math.atan2(sb2, ca2 * cb2);
    const om2 = math.atan2(sa0 * @sin(sig2), @cos(sig2));

    const arc = Arc{ .k2 = e.ep2() * ca0 * ca0, .f = f };
    const lam1 = om1 - f * sa0 * intI3(arc, sig1);
    const lam2 = om2 - f * sa0 * intI3(arc, sig2);

    const j1 = intI1(arc, sig1) - intI2(arc, sig1);
    const j2 = intI1(arc, sig2) - intI2(arc, sig2);
    const b = e.b();
    const m12 = b * (arc.dI1(sig2) * @sin(sig2) * @cos(sig1) -
        arc.dI1(sig1) * @sin(sig1) * @cos(sig2) -
        @cos(sig1) * @cos(sig2) * (j2 - j1));

    return .{
        .lam12 = lam2 - lam1,
        .s12 = b * (intI1(arc, sig2) - intI1(arc, sig1)),
        .azi2 = math.atan2(sa2, ca2),
        .m12 = m12,
        .sig12 = sig2 - sig1,
    };
}

/// THE INVERSE PROBLEM: two points, and what the shortest path between them
/// measures. Degrees in, metres and degrees out.
///
/// HOW THE AZIMUTH IS FOUND, AND WHY NOT KARNEY'S WAY. Karney solves for
/// alpha1 by Newton from a carefully constructed starting guess -- the
/// spherical answer usually, and the root of an ASTROID when the points are
/// nearly antipodal, where the spherical guess is useless. That machinery
/// exists to make Newton converge in two or three steps.
///
/// This solves the same equation by SAFEGUARDED BISECTION with a Newton
/// step inside it, over the bracket [0, pi]. lam12(alpha1) rises
/// monotonically from 0 (leave due north, arrive along the same meridian)
/// to pi (leave due south, over the pole, arrive along the anti-meridian),
/// so the bracket is guaranteed and so is convergence -- INCLUDING for the
/// antipodal points that are the hard case, where a lost bracket is the
/// classic failure and is exactly what Vincenty's method does. It costs
/// more iterations than the astroid start and it cannot fail to terminate.
pub fn inverse(e: Ellipsoid, lat1d: f64, lon1d: f64, lat2d: f64, lon2d: f64) Inverse {
    const f = e.f;
    const a = e.a;

    // ---- normalise, so the solver meets ONE configuration --------------
    // lon12 into [0, pi] remembering the sign; the points ordered so the
    // first is in the southern hemisphere and the farther from the equator.
    var lon12 = wrapPi((lon2d - lon1d) * DEG);
    const lon_sign: f64 = if (lon12 < 0) -1 else 1;
    lon12 = @abs(lon12);

    var phi1 = lat1d * DEG;
    var phi2 = lat2d * DEG;
    var swapped = false;
    if (@abs(phi1) < @abs(phi2)) {
        const t = phi1;
        phi1 = phi2;
        phi2 = t;
        swapped = true;
    }
    var lat_sign: f64 = 1;
    if (phi1 > 0) {
        phi1 = -phi1;
        phi2 = -phi2;
        lat_sign = -1;
    }

    const beta1 = reduced(e, phi1);
    const beta2 = reduced(e, phi2);

    var out: Inverse = .{ .s12 = 0, .azi1 = 0, .azi2 = 0, .m12 = 0, .a12 = 0, .iterations = 0 };

    // ---- the two closed cases -----------------------------------------
    //
    // A MERIDIAN. Both points on one meridian (or on opposite ones through
    // a pole): the geodesic IS that meridian and its length is a difference
    // of meridian arcs, with no azimuth to solve for.
    if (lon12 == 0 or @abs(lon12 - math.pi) < 1e-14) {
        const arc = Arc{ .k2 = e.ep2(), .f = f };
        const b = e.b();
        if (lon12 == 0) {
            const s = b * (intI1(arc, beta2) - intI1(arc, beta1));
            out.s12 = @abs(s);
            // going north if beta2 > beta1
            out.azi1 = if (beta2 >= beta1) 0 else math.pi;
            out.azi2 = out.azi1;
            out.a12 = @abs(beta2 - beta1);
            const j1 = intI1(arc, beta1) - intI2(arc, beta1);
            const j2 = intI1(arc, beta2) - intI2(arc, beta2);
            out.m12 = b * (arc.dI1(beta2) * @sin(beta2) * @cos(beta1) -
                arc.dI1(beta1) * @sin(beta1) * @cos(beta2) -
                @cos(beta1) * @cos(beta2) * (j2 - j1));
        } else {
            // over a pole: south to the pole from 1 then down to 2, or
            // north; take the shorter
            const quarter = b * intI1(arc, math.pi / 2.0);
            const up = (quarter - b * intI1(arc, beta1)) + (quarter - b * intI1(arc, beta2));
            const down = (quarter + b * intI1(arc, beta1)) + (quarter + b * intI1(arc, beta2));
            if (up <= down) {
                out.s12 = up;
                out.azi1 = 0;
                out.azi2 = math.pi;
                out.a12 = (math.pi / 2.0 - beta1) + (math.pi / 2.0 - beta2);
            } else {
                out.s12 = down;
                out.azi1 = math.pi;
                out.azi2 = 0;
                out.a12 = (math.pi / 2.0 + beta1) + (math.pi / 2.0 + beta2);
            }
            out.m12 = 0;
        }
    } else if (beta1 == 0 and beta2 == 0 and lon12 <= (1 - f) * math.pi) {
        // THE EQUATOR IS A GEODESIC, and it is the shortest path as long as
        // the two points are not so far apart that a path over higher
        // latitudes overtakes it -- which happens beyond (1-f) pi, the
        // equator's own share of the auxiliary sphere.
        out.s12 = a * lon12;
        out.azi1 = math.pi / 2.0;
        out.azi2 = math.pi / 2.0;
        out.a12 = lon12 / (1 - f);
        out.m12 = a * @sin(lon12 / (1 - f)) * (1 - f);
    } else {
        // ---- the root find --------------------------------------------
        var lo: f64 = 0;
        var hi: f64 = math.pi;
        var al: f64 = math.pi / 2.0;
        var leg = legFor(e, beta1, beta2, al);
        var it: usize = 0;
        while (it < 100) : (it += 1) {
            const err = leg.lam12 - lon12;
            if (@abs(err) < 1e-15) break;
            if (err > 0) hi = al else lo = al;
            // Newton, using the derivative geodesy gives us in closed form:
            //   d(lam12)/d(alpha1) = m12 / (a cos(alpha2) cos(beta2))
            // and falling back to the bisection midpoint whenever that step
            // would leave the bracket -- which is what makes this safe.
            var next = (lo + hi) / 2;
            const ca2 = @cos(leg.azi2);
            const den = a * ca2 * @cos(beta2);
            if (@abs(den) > 1e-12 and leg.m12 != 0) {
                const step = err * den / leg.m12;
                const cand = al - step;
                if (cand > lo and cand < hi) next = cand;
            }
            if (@abs(next - al) < 1e-16) break;
            al = next;
            leg = legFor(e, beta1, beta2, al);
        }
        out.iterations = it;
        out.s12 = leg.s12;
        out.azi1 = al;
        out.azi2 = leg.azi2;
        out.m12 = leg.m12;
        out.a12 = leg.sig12;
    }

    // ---- undo the normalisation ---------------------------------------
    var a1 = out.azi1;
    var a2 = out.azi2;
    if (swapped) {
        const t = a1;
        a1 = math.pi - a2;
        a2 = math.pi - t;
    }
    // the latitude flip mirrors north and south, which reflects an azimuth
    // about the east-west line
    if (lat_sign < 0) {
        a1 = math.pi - a1;
        a2 = math.pi - a2;
    }
    // and the longitude flip mirrors east and west
    if (lon_sign < 0) {
        a1 = -a1;
        a2 = -a2;
    }
    out.azi1 = wrapPi(a1) / DEG;
    out.azi2 = wrapPi(a2) / DEG;
    out.a12 = out.a12 / DEG;
    return out;
}

/// THE DIRECT PROBLEM: from a point, an azimuth and a distance, where do
/// you arrive. The same reduction, run forwards -- the one thing it needs
/// that the inverse does not is the INVERSE of I1: the arc sigma whose
/// integral is the distance asked for. That is a one-dimensional root find
/// whose derivative is the integrand itself, so Newton converges in three
/// or four steps from the spherical guess and cannot wander: dI1/dsigma is
/// bounded between 1 and sqrt(1+k^2), so the function is strictly
/// increasing everywhere.
pub fn direct(e: Ellipsoid, lat1d: f64, lon1d: f64, azi1d: f64, s12: f64) Direct {
    const f = e.f;
    const b = e.b();
    const phi1 = lat1d * DEG;
    const alpha1 = azi1d * DEG;
    const beta1 = reduced(e, phi1);

    const sb1 = @sin(beta1);
    const cb1 = @cos(beta1);
    const sa1 = @sin(alpha1);
    const ca1 = @cos(alpha1);

    const sa0 = sa1 * cb1;
    const ca0 = hypot2(ca1, sa1 * sb1);

    const sig1 = math.atan2(sb1, ca1 * cb1);
    const om1 = math.atan2(sa0 * @sin(sig1), @cos(sig1));

    const arc = Arc{ .k2 = e.ep2() * ca0 * ca0, .f = f };
    const i1_1 = intI1(arc, sig1);
    const target = s12 / b + i1_1;

    // solve intI1(sigma2) = target
    var sig2 = sig1 + s12 / b;
    var it: usize = 0;
    while (it < 60) : (it += 1) {
        const g = intI1(arc, sig2) - target;
        const dg = arc.dI1(sig2);
        const dx = g / dg;
        sig2 -= dx;
        if (@abs(dx) < 1e-14) break;
    }

    const sb2 = ca0 * @sin(sig2);
    const cb2 = hypot2(sa0, ca0 * @cos(sig2));
    const beta2 = math.atan2(sb2, cb2);
    const om2 = math.atan2(sa0 * @sin(sig2), @cos(sig2));
    const lam12 = (om2 - f * sa0 * intI3(arc, sig2)) - (om1 - f * sa0 * intI3(arc, sig1));

    const j1 = i1_1 - intI2(arc, sig1);
    const j2 = intI1(arc, sig2) - intI2(arc, sig2);
    const m12 = b * (arc.dI1(sig2) * @sin(sig2) * @cos(sig1) -
        arc.dI1(sig1) * @sin(sig1) * @cos(sig2) -
        @cos(sig1) * @cos(sig2) * (j2 - j1));

    return .{
        .lat2 = geodetic(e, beta2) / DEG,
        .lon2 = wrapPi(lon1d * DEG + lam12) / DEG,
        .azi2 = wrapPi(math.atan2(sa0, ca0 * @cos(sig2))) / DEG,
        .m12 = m12,
        .a12 = (sig2 - sig1) / DEG,
    };
}

/// n POINTS ALONG THE GEODESIC, endpoints included, as lon/lat degrees.
/// A geodesic drawn as a straight line on anything but a gnomonic
/// projection is a lie, and this is how a flight path or a boundary gets
/// drawn honestly: sample the curve, then let the projection bend it.
pub fn line(e: Ellipsoid, lat1: f64, lon1: f64, lat2: f64, lon2: f64, n: usize, out: []f64) usize {
    if (n < 2 or out.len < n * 2) return 0;
    const inv = inverse(e, lat1, lon1, lat2, lon2);
    var i: usize = 0;
    while (i < n) : (i += 1) {
        const t = @as(f64, @floatFromInt(i)) / @as(f64, @floatFromInt(n - 1));
        const d = direct(e, lat1, lon1, inv.azi1, inv.s12 * t);
        out[i * 2] = d.lon2;
        out[i * 2 + 1] = d.lat2;
    }
    // the endpoints are what the caller gave, exactly -- a sampled curve
    // that misses its own ends by a nanometre makes a visible gap where two
    // of them meet
    out[0] = lon1;
    out[1] = lat1;
    out[(n - 1) * 2] = lon2;
    out[(n - 1) * 2 + 1] = lat2;
    return n;
}

// ------------------------------------------------------------------ the
// -------------------------------------------------- meridian and parallel

/// THE MERIDIAN ARC from the equator to a latitude, metres. In the reduced
/// latitude this is b INTEGRAL sqrt(1 + e'^2 sin^2 t) dt, which is the
/// k = e'^2 case of the geodesic integral above -- so it is the SAME code,
/// not a second formula that could drift from it.
pub fn meridianArc(e: Ellipsoid, latd: f64) f64 {
    const arc = Arc{ .k2 = e.ep2(), .f = e.f };
    return e.b() * intI1(arc, reduced(e, latd * DEG));
}

/// pole to equator, metres -- 10001965.729 m on WGS84, the number the metre
/// was originally meant to make ten million of
pub fn quarterMeridian(e: Ellipsoid) f64 {
    return meridianArc(e, 90);
}

/// the length of a whole parallel of latitude, metres
pub fn parallelLength(e: Ellipsoid, latd: f64) f64 {
    const phi = latd * DEG;
    const s = @sin(phi);
    const nrad = e.a / @sqrt(1 - e.e2() * s * s);
    return 2 * math.pi * nrad * @cos(phi);
}

// ------------------------------------------------------------------ the
// ------------------------------------------------------------ rhumb line
//
// A RHUMB LINE IS THE PATH OF CONSTANT BEARING, and it is NOT the shortest
// path -- it is the one you can steer. Before satellite navigation a ship
// held a compass course, and a Mercator chart exists precisely because it
// draws that course as a straight line. The two differ by a lot: London to
// New York is about 5570 km by geodesic and 5800 km by rhumb, and the rhumb
// to a pole spirals into it with infinite winding and finite length.
//
// On the ellipsoid it is built from two latitudes rather than one:
//   * the ISOMETRIC latitude psi, in which a constant bearing is a
//     straight line -- this is Mercator's own y coordinate;
//   * the MERIDIAN ARC, which carries the distance.
// The azimuth comes from the first and the length from the second.

pub const Rhumb = struct { s12: f64, azi12: f64 };

/// the isometric latitude, radians -- Mercator's y over a
fn isometric(e: Ellipsoid, phi: f64) f64 {
    const ecc = e.ecc();
    const s = @sin(phi);
    return atanh(@sin(phi)) - ecc * atanh(ecc * s);
}

pub fn rhumbInverse(e: Ellipsoid, lat1d: f64, lon1d: f64, lat2d: f64, lon2d: f64) Rhumb {
    const phi1 = lat1d * DEG;
    const phi2 = lat2d * DEG;
    const dlon = wrapPi((lon2d - lon1d) * DEG);
    const dpsi = isometric(e, phi2) - isometric(e, phi1);
    const azi = math.atan2(dlon, dpsi);
    const dm = meridianArc(e, lat2d) - meridianArc(e, lat1d);
    var s: f64 = 0;
    if (@abs(dpsi) > 1e-12) {
        s = @abs(dm / @cos(azi));
    } else {
        // DUE EAST OR WEST -- a parallel sailing. The meridian arc is zero
        // here and dividing by cos(azimuth) would be dividing by zero, so
        // the distance is the length along the parallel instead.
        const s1 = @sin(phi1);
        const nrad = e.a / @sqrt(1 - e.e2() * s1 * s1);
        s = @abs(dlon) * nrad * @cos(phi1);
    }
    return .{ .s12 = s, .azi12 = wrapPi(azi) / DEG };
}

pub fn rhumbDirect(e: Ellipsoid, lat1d: f64, lon1d: f64, azi12d: f64, s12: f64) [2]f64 {
    const azi = azi12d * DEG;
    const phi1 = lat1d * DEG;
    const m1 = meridianArc(e, lat1d);
    const m2 = m1 + s12 * @cos(azi);
    // invert the meridian arc for the arriving latitude
    const lat2 = inverseMeridianArc(e, m2);
    const phi2 = lat2 * DEG;
    var dlon: f64 = 0;
    const dpsi = isometric(e, phi2) - isometric(e, phi1);
    if (@abs(dpsi) > 1e-12) {
        dlon = @tan(azi) * dpsi;
    } else {
        const s1 = @sin(phi1);
        const nrad = e.a / @sqrt(1 - e.e2() * s1 * s1);
        dlon = s12 * @sin(azi) / (nrad * @cos(phi1));
    }
    return .{ wrapPi(lon1d * DEG + dlon) / DEG, lat2 };
}

/// the latitude whose meridian arc is this, degrees -- Newton, with the
/// meridional radius of curvature as the derivative, which is exact
pub fn inverseMeridianArc(e: Ellipsoid, m: f64) f64 {
    const quarter = quarterMeridian(e);
    if (quarter == 0) return 0;
    var phi = (m / quarter) * (math.pi / 2.0);
    var it: usize = 0;
    while (it < 60) : (it += 1) {
        const g = meridianArc(e, phi / DEG) - m;
        const s = @sin(phi);
        const w = 1 - e.e2() * s * s;
        const rho = e.a * (1 - e.e2()) / (w * @sqrt(w)); // meridional radius
        const dx = g / rho;
        phi -= dx;
        if (@abs(dx) < 1e-15) break;
    }
    return phi / DEG;
}

pub fn rhumbLine(e: Ellipsoid, lat1: f64, lon1: f64, lat2: f64, lon2: f64, n: usize, out: []f64) usize {
    if (n < 2 or out.len < n * 2) return 0;
    const r = rhumbInverse(e, lat1, lon1, lat2, lon2);
    var i: usize = 0;
    while (i < n) : (i += 1) {
        const t = @as(f64, @floatFromInt(i)) / @as(f64, @floatFromInt(n - 1));
        const p = rhumbDirect(e, lat1, lon1, r.azi12, r.s12 * t);
        out[i * 2] = p[0];
        out[i * 2 + 1] = p[1];
    }
    out[0] = lon1;
    out[1] = lat1;
    out[(n - 1) * 2] = lon2;
    out[(n - 1) * 2 + 1] = lat2;
    return n;
}

// ------------------------------------------------------------------ the
// --------------------------------------------------------- ECEF and ENU
//
// LATITUDE AND LONGITUDE ARE ANGLES, NOT A VECTOR SPACE. You cannot average
// two of them, subtract them to get a displacement, or hand them to a
// linear algebra routine -- near a pole the same distance is a hundred
// times more degrees of longitude than at the equator. ECEF is the cure:
// one right-handed Cartesian frame, metres on all three axes, origin at the
// Earth's centre, Z through the pole, X through the intersection of the
// equator and the prime meridian.
//
// ENU is the LOCAL frame a person actually lives in: east, north and up,
// metres, about a chosen origin. It is what a radar bearing, a survey
// offset or a drone's position is naturally expressed in, and the round
// trip through ECEF is how such a thing gets back onto the globe.

pub fn toEcef(e: Ellipsoid, latd: f64, lond: f64, h: f64) [3]f64 {
    const phi = latd * DEG;
    const lam = lond * DEG;
    const sp = @sin(phi);
    const cp = @cos(phi);
    const nrad = e.a / @sqrt(1 - e.e2() * sp * sp);
    return .{
        (nrad + h) * cp * @cos(lam),
        (nrad + h) * cp * @sin(lam),
        (nrad * (1 - e.e2()) + h) * sp,
    };
}

/// ECEF back to latitude, longitude and height. Bowring's method: one
/// closed-form step from the PARAMETRIC latitude, then Newton to finish.
/// The naive iteration on phi alone converges slowly near the pole and
/// this does not.
pub fn fromEcef(e: Ellipsoid, x: f64, y: f64, z: f64) [3]f64 {
    const a = e.a;
    const b = e.b();
    const e2v = e.e2();
    const ep2v = e.ep2();
    const p = hypot2(x, y);
    const lon = math.atan2(y, x) / DEG;
    if (p < 1e-9) {
        // ON THE AXIS -- a point over a pole has no longitude, and asking
        // atan2 for one gives whichever the rounding likes. Zero is the
        // convention and it is stated rather than stumbled into.
        const sign: f64 = if (z >= 0) 1 else -1;
        return .{ sign * 90.0, 0, @abs(z) - b };
    }
    const th = math.atan2(z * a, p * b);
    const st = @sin(th);
    const ct = @cos(th);
    var phi = math.atan2(z + ep2v * b * st * st * st, p - e2v * a * ct * ct * ct);
    // two Newton steps take Bowring's already-excellent first answer to
    // the last bit; it converges quadratically and stops moving
    var k: usize = 0;
    while (k < 4) : (k += 1) {
        const sp = @sin(phi);
        const nrad = a / @sqrt(1 - e2v * sp * sp);
        const hh = p / @cos(phi) - nrad;
        const next = math.atan2(z, p * (1 - e2v * nrad / (nrad + hh)));
        if (@abs(next - phi) < 1e-16) {
            phi = next;
            break;
        }
        phi = next;
    }
    const sp = @sin(phi);
    const nrad = a / @sqrt(1 - e2v * sp * sp);
    const h = p / @cos(phi) - nrad;
    return .{ phi / DEG, lon, h };
}

pub fn toEnu(e: Ellipsoid, lat0: f64, lon0: f64, h0: f64, latd: f64, lond: f64, h: f64) [3]f64 {
    const o = toEcef(e, lat0, lon0, h0);
    const p = toEcef(e, latd, lond, h);
    const dx = p[0] - o[0];
    const dy = p[1] - o[1];
    const dz = p[2] - o[2];
    const sp = @sin(lat0 * DEG);
    const cp = @cos(lat0 * DEG);
    const sl = @sin(lon0 * DEG);
    const cl = @cos(lon0 * DEG);
    return .{
        -sl * dx + cl * dy,
        -sp * cl * dx - sp * sl * dy + cp * dz,
        cp * cl * dx + cp * sl * dy + sp * dz,
    };
}

pub fn fromEnu(e: Ellipsoid, lat0: f64, lon0: f64, h0: f64, en: f64, nn: f64, un: f64) [3]f64 {
    const sp = @sin(lat0 * DEG);
    const cp = @cos(lat0 * DEG);
    const sl = @sin(lon0 * DEG);
    const cl = @cos(lon0 * DEG);
    const o = toEcef(e, lat0, lon0, h0);
    const x = o[0] - sl * en - sp * cl * nn + cp * cl * un;
    const y = o[1] + cl * en - sp * sl * nn + cp * sl * un;
    const z = o[2] + cp * nn + sp * un;
    return fromEcef(e, x, y, z);
}

// ------------------------------------------------------------------ the
// ------------------------------------------------------------- the area
//
// THE AREA OF A POLYGON ON THE ELLIPSOID, m^2, its edges taken as geodesics.
//
// The trick is the same one that makes the shoelace formula work on a
// plane: an area enclosed by a closed curve is a LINE INTEGRAL around it.
// Here the quantity integrated is the area of the zone between the equator
// and the curve, per radian of longitude:
//
//   A(phi) = (b^2/2) [ sin(phi)/(1 - e^2 sin^2 phi) + atanh(e sin phi)/e ]
//
// and the polygon's area is the integral of A(phi) d(lambda) around the
// boundary. CHECKED AGAINST THE CLOSED FORM rather than trusted: integrate
// A over a whole revolution from pole to pole and it must give the
// ellipsoid's total surface 2 pi [a^2 + b^2 atanh(e)/e], which it does --
// that identity is the reason this expression can be written down here
// with confidence instead of copied.
//
// Each edge is a geodesic, so phi is followed ALONG the geodesic rather
// than interpolated between the endpoints; interpolating is the usual
// source of a few parts in ten thousand on a long edge.

fn zoneArea(e: Ellipsoid, phi: f64) f64 {
    const bb = e.b();
    if (e.f == 0) return e.a * e.a * @sin(phi);
    const ecc = e.ecc();
    const s = @sin(phi);
    return (bb * bb / 2) * (s / (1 - e.e2() * s * s) + atanh(ecc * s) / ecc);
}

// THE EDGE IS INTEGRATED IN omega, NOT IN sigma, and that is not a taste.
//
// The first version integrated along the arc, d(lambda)/d(sigma) being
// sin(alpha0)/(1 - cos^2(alpha0) sin^2 sigma). For a NEARLY MERIDIONAL edge
// sin(alpha0) is tiny, and that function is a spike: almost zero everywhere
// except a window of width sin(alpha0) around sigma = pi/2, where it rises
// to 1/sin(alpha0). Its integral is finite and correct -- the longitude does
// swing through ninety degrees as the path skirts the pole -- but a fixed
// quadrature steps straight over the spike and reports nearly nothing. A
// quarter-hemisphere came out 3651 times too small, and the two edges that
// lost the area were the two that ran up and over the pole.
//
// omega is the longitude ON THE AUXILIARY SPHERE, and it is exactly the
// variable in which that spike is flat: d(lambda)/d(omega) stays between
// 1-f and 1 for every geodesic there is. So the substitution removes the
// difficulty rather than throwing resolution at it, which is what the
// series Karney fits are doing too, by another route.
//
// sin(sigma) and cos(sigma) come straight out of omega -- tan(sigma) =
// tan(omega)/sin(alpha0) -- so sigma itself is never formed and never has
// to be kept continuous across the pole.
const EdgeCtx = struct {
    e: Ellipsoid,
    arc: Arc,
    sa0: f64,
    ca0: f64,
};

fn edgeIntegrand(c: EdgeCtx, om: f64) f64 {
    const so = @sin(om);
    const co = @cos(om);
    const d = hypot2(so, c.sa0 * co);
    if (d == 0) return 0;
    // INVERTING omega = atan2(sin(alpha0) sin(sigma), cos(sigma)) NEEDS THE
    // SIGN OF sin(alpha0), not just its magnitude. tan(sigma) =
    // tan(omega)/sin(alpha0) fixes sigma only up to half a turn, and the
    // half is decided by which way the geodesic is heading: cos(sigma)
    // follows cos(omega), and sin(sigma) follows sin(omega) THROUGH the
    // sign of sin(alpha0).
    //
    // Written without that sign, every WESTWARD edge got a latitude of the
    // wrong hemisphere -- so its zone area came back negated, and the pair
    // of edges that should have differenced to a thin strip instead summed
    // to twice a hemisphere. A 0.01-degree square measured eleven thousand
    // times its size and a lune measured zero, from the same line.
    const sgn: f64 = if (c.sa0 < 0) -1 else 1;
    const ss = sgn * so / d;
    const cs = @abs(c.sa0) * co / d;
    const sb = c.ca0 * ss;
    const cb = hypot2(c.sa0, c.ca0 * cs);
    const phi = math.atan2(sb, (1 - c.e.f) * cb);
    // d(lambda)/d(omega) = 1 - f (dI3/dsigma) (1 - cos^2(alpha0) sin^2 sigma)
    const dlam = 1 - c.e.f * c.arc.dI3Sin(ss) * (1 - c.ca0 * c.ca0 * ss * ss);
    return zoneArea(c.e, phi) * dlam;
}

pub const AreaResult = struct { area: f64, perimeter: f64 };

pub fn polygonArea(e: Ellipsoid, lonlat: []const f64) AreaResult {
    const n = lonlat.len / 2;
    if (n < 3) return .{ .area = 0, .perimeter = 0 };
    var area: f64 = 0;
    var perim: f64 = 0;
    var sweep: f64 = 0;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        const j = (i + 1) % n;
        const lon1 = lonlat[i * 2];
        const lat1 = lonlat[i * 2 + 1];
        const lon2 = lonlat[j * 2];
        const lat2 = lonlat[j * 2 + 1];
        if (lon1 == lon2 and lat1 == lat2) continue;

        const inv = inverse(e, lat1, lon1, lat2, lon2);
        perim += inv.s12;

        // set the edge up as the direct problem does, then integrate
        const phi1 = lat1 * DEG;
        const beta1 = reduced(e, phi1);
        const alpha1 = inv.azi1 * DEG;
        const sb1 = @sin(beta1);
        const cb1 = @cos(beta1);
        const sa1 = @sin(alpha1);
        const ca1 = @cos(alpha1);
        const sa0 = sa1 * cb1;
        const ca0 = hypot2(ca1, sa1 * sb1);
        const sig1 = math.atan2(sb1, ca1 * cb1);
        const sig12 = inv.a12 * DEG;
        const sig2 = sig1 + sig12;
        const ctx = EdgeCtx{
            .e = e,
            .arc = Arc{ .k2 = e.ep2() * ca0 * ca0, .f = e.f },
            .sa0 = sa0,
            .ca0 = ca0,
        };
        // THE SWEEP IS READ OFF THE ENDPOINTS, NOT OFF atan2 OF THE ARC.
        //
        // The obvious way is omega2 - omega1 with each from atan2(sin(a0)
        // sin(sigma), cos(sigma)), unwrapped by the sign of sin(alpha0).
        // It is wrong for a MERIDIONAL edge, and wrong catastrophically:
        // sin(pi) in floating point is 1.2e-16 rather than zero, so a
        // southward meridian has sin(alpha0) about 1e-16 -- not zero, so a
        // test for zero does not fire -- and both omegas are then atan2 of
        // two quantities that are pure rounding noise. The unwrap took that
        // noise for a sweep and added a whole 2 pi, which multiplied by the
        // zone area is an entire extra ellipsoid. A 0.01-degree square came
        // out eleven thousand times too big and a lune came out as zero.
        //
        // lambda is what the caller actually gave us, so take the sweep
        // from there: an edge shorter than half the world sweeps less than
        // pi of longitude, which makes the unwrap unambiguous, and
        // omega = lambda + f sin(alpha0) I3(sigma) converts it with a
        // correction of order f that cannot change its sign.
        const dlam = wrapPi((lon2 - lon1) * DEG);
        const dom = dlam + e.f * sa0 * (intI3(ctx.arc, sig2) - intI3(ctx.arc, sig1));
        const om1 = math.atan2(sa0 * @sin(sig1), @cos(sig1));
        area += integrateRange(om1, om1 + dom, ctx, edgeIntegrand);
        sweep += dlam;
    }
    // A BOUNDARY THAT WINDS ROUND A POLE MEASURES SOMETHING ELSE, and this
    // is where that gets said.
    //
    // The integral answers "the area between this path and the equator". For
    // an ordinary closed ring the two ends of that statement cancel and what
    // is left is the enclosed area. For a ring that goes right round the
    // world -- Antarctica's coast is the one every world file contains --
    // they do not: the path never comes back, its longitude advances by a
    // full turn, and the integral returns the ZONE from the equator to the
    // coast instead of the continent. Measured on the 110m world file:
    // 242,965,092 km2 for a continent of 12,236,255.
    //
    // The winding says which case this is, and it is free -- the sum of the
    // longitude sweeps the edges already computed. Half the surface then
    // converts one into the other, in both directions: a coast that encloses
    // the pole from far away gives more than half a world and the half is
    // subtracted; a small cap round the pole gives less and the subtraction
    // comes out negative, which is the cap. One line covers both because
    // they are the same statement.
    const total = e.surfaceArea();
    var s = @abs(area);
    if (@abs(sweep) > math.pi) s = @abs(s - total / 2);
    if (s > total) s = total;
    return .{ .area = s, .perimeter = perim };
}
