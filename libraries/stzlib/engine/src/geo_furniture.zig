//! GE10 -- MAP FURNITURE, AND THE TWO PLOTS A FIELD STILL OWED.
//!
//! The things a map has around it and over it: a scale bar, the line
//! between day and night, and the arrows and streamlines that show which
//! way a field is going. They are called furniture because they are not
//! the data -- and the scale bar at least is where more maps tell a lie
//! than anywhere else on the sheet.
//!
//! WHY A SCALE BAR IS USUALLY A LIE. It says "this length is 500 km". On a
//! world map that is true along ONE line and nowhere else: a Mercator's
//! scale doubles by 60 degrees and is eight and a half times the equator's
//! by 70, so a bar drawn once is wrong by a factor of eight at the top of
//! the same sheet. Almost every world map carries one anyway.
//!
//! GE9 measured exactly that, so this module can do the honest thing:
//! compute the bar AT A STATED LATITUDE, and report how far the scale
//! varies across the sheet so a caller can refuse to draw one at all. A
//! scale bar is legitimate on a city plan and a fiction on a world map,
//! and the number that separates them is now available.
//!
//! THE TERMINATOR IS ASTRONOMY AND IS CHECKABLE. The line between day and
//! night is the great circle ninety degrees from the point the sun is
//! directly over, so all it needs is where that point is -- which is the
//! solar declination and the Greenwich hour angle, from a date. Those come
//! from the Astronomical Almanac's low-precision series, good to about a
//! hundredth of a degree, and THEY ARE CONSTANTS SOMEBODY HAD TO TYPE. So
//! they are held to facts nobody needs an almanac to know: the declination
//! is +23.44 at the June solstice and -23.44 at the December one, it is
//! zero at both equinoxes, and the subsolar longitude advances fifteen
//! degrees an hour. That is the same discipline GE9's gallery used and for
//! the same reason.

const std = @import("std");
const math = std.math;
const gp = @import("geo_projection.zig");
const gf = @import("geo_field.zig");

const DEG: f64 = math.pi / 180.0;

// --------------------------------------------------------- where the sun is

pub const Sun = struct {
    /// the latitude the sun is directly over, degrees. It is the solar
    /// DECLINATION, and it is what the seasons are.
    lat: f64,
    /// ...and the longitude, which is simply where noon is.
    lon: f64,
    /// the declination again, named as astronomy names it
    declination: f64,
    /// how far the true sun runs ahead of or behind a clock sun, minutes.
    /// It reaches sixteen minutes in November and is why the earliest
    /// sunset is not on the shortest day.
    equation_of_time: f64,
};

/// THE JULIAN DAY of a civil date and time in UTC. Days since noon on
/// 1 January 4713 BC, which is the epoch astronomy counts from because it
/// puts every recorded observation on one positive number line.
pub fn julianDay(year: i32, month: i32, day: i32, hour: f64) f64 {
    var y = year;
    var m = month;
    if (m <= 2) {
        y -= 1;
        m += 12;
    }
    const a = @divFloor(y, 100);
    const b = 2 - a + @divFloor(a, 4);
    const yf: f64 = @floatFromInt(y);
    const mf: f64 = @floatFromInt(m);
    const df: f64 = @floatFromInt(day);
    return @floor(365.25 * (yf + 4716)) + @floor(30.6001 * (mf + 1)) +
        df + @as(f64, @floatFromInt(b)) - 1524.5 + hour / 24.0;
}

/// WHERE THE SUN IS OVERHEAD at a moment, from the Astronomical Almanac's
/// low-precision solar position -- good to about a hundredth of a degree,
/// which is a hundred times finer than any line this draws.
///
/// The series constants are the only ones in this module somebody had to
/// type, so they are held to facts that need no almanac: see the guard.
pub fn sunAt(jd: f64) Sun {
    const n = jd - 2451545.0;
    // the mean sun: where it would be if the orbit were a circle
    const mean_lon = wrap360(280.460 + 0.9856474 * n);
    const mean_anom = wrap360(357.528 + 0.9856003 * n) * DEG;
    // ...and the true sun, which runs ahead and behind it because the orbit
    // is an ellipse. The two-term correction is the equation of the centre.
    const ecl_lon = (mean_lon + 1.915 * @sin(mean_anom) + 0.020 * @sin(2 * mean_anom)) * DEG;
    // the tilt of the Earth's axis, which is what makes seasons at all
    const obliq = (23.439 - 0.0000004 * n) * DEG;

    const sin_dec = @sin(obliq) * @sin(ecl_lon);
    const dec = math.asin(math.clamp(sin_dec, -1, 1)) / DEG;
    const ra = math.atan2(@cos(obliq) * @sin(ecl_lon), @cos(ecl_lon)) / DEG;

    // Greenwich mean sidereal time: where the sky has turned to
    const gmst_h = @mod(18.697374558 + 24.06570982441908 * n, 24.0);
    const gmst_deg = gmst_h * 15.0;
    const lon = wrap180(ra - gmst_deg);

    // the equation of time: the true sun's hour angle minus the mean sun's
    const eot_deg = wrap180(mean_lon - ra);
    return .{ .lat = dec, .lon = lon, .declination = dec, .equation_of_time = eot_deg * 4.0 };
}

fn wrap360(x: f64) f64 {
    const t = @mod(x, 360.0);
    return if (t < 0) t + 360 else t;
}
fn wrap180(x: f64) f64 {
    var t = @mod(x + 180.0, 360.0);
    if (t < 0) t += 360;
    return t - 180.0;
}

/// THE TERMINATOR: the circle of places where the sun is exactly on the
/// horizon, which is every point ninety degrees from the subsolar point.
///
/// AND TWILIGHT IS THE SAME CIRCLE, FURTHER OUT. Civil twilight ends when
/// the sun is 6 degrees below the horizon, nautical at 12 and astronomical
/// at 18 -- so they are the circles at 96, 102 and 108 degrees. Passing
/// the angle rather than hard-wiring 90 is what makes one routine draw all
/// four, and the names are a caller's business.
pub fn terminator(sun: Sun, angle_deg: f64, n: usize, out: []f64) usize {
    if (n < 3 or out.len < n * 2) return 0;
    const r = angle_deg * DEG;
    const f0 = sun.lat * DEG;
    const l0 = sun.lon * DEG;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        const b = 2 * math.pi * @as(f64, @floatFromInt(i)) / @as(f64, @floatFromInt(n - 1));
        const sf = @sin(f0) * @cos(r) + @cos(f0) * @sin(r) * @cos(b);
        const f2 = math.asin(math.clamp(sf, -1, 1));
        const l2 = l0 + math.atan2(@sin(b) * @sin(r) * @cos(f0), @cos(r) - @sin(f0) * sf);
        out[i * 2] = wrap180(l2 / DEG);
        out[i * 2 + 1] = f2 / DEG;
    }
    return n;
}

/// IS THE SUN UP at a place, at that moment? The angular distance from the
/// subsolar point is the sun's zenith angle, so anything under ninety
/// degrees is daylight -- which is the terminator restated as a question
/// rather than as a line, and is what shades a map rather than outlines it.
pub fn solarElevation(sun: Sun, lon_deg: f64, lat_deg: f64) f64 {
    const f1 = sun.lat * DEG;
    const f2 = lat_deg * DEG;
    const dl = (lon_deg - sun.lon) * DEG;
    const cz = @sin(f1) * @sin(f2) + @cos(f1) * @cos(f2) * @cos(dl);
    return 90.0 - math.acos(math.clamp(cz, -1, 1)) / DEG;
}

// ------------------------------------------------------------ the scale bar

pub const ScaleBar = struct {
    /// the round number the bar stands for, km
    km: f64,
    /// how long that is on the paper, pixels, AT the reference latitude
    pixels: f64,
    /// the reference latitude the bar is true at
    at_lat: f64,
    /// how far the scale varies across the whole sheet: the largest local
    /// linear scale divided by the smallest. 1 means a bar is true
    /// everywhere; 8 means it is a lie almost everywhere.
    variation: f64,
};

/// A BAR OF A ROUND NUMBER OF KILOMETRES, and the honesty to go with it.
///
/// The length is MEASURED rather than derived from the projection's scale
/// parameter: two points a known distance apart on the ground, projected,
/// and the pixels between them. That works for every projection in the
/// gallery including the twenty-eight with no closed form, and it uses
/// GE8's ellipsoid for the ground distance, so the bar says what a GPS
/// would say.
///
/// `variation` is the number that decides whether a bar should be drawn at
/// all. A caller that ignores it draws the lie every world map carries.
pub fn scaleBar(p: *const gp.Projection, target_px: f64, ref_lat: f64, ref_lon: f64, x0: f64, y0: f64, x1: f64, y1: f64) ScaleBar {
    const ppk = pixelsPerKmAt(p, ref_lon, ref_lat);
    var out = ScaleBar{ .km = 0, .pixels = 0, .at_lat = ref_lat, .variation = 1 };
    if (!(ppk > 0) or !math.isFinite(ppk)) return out;
    // the round number nearest the asked-for length: 1, 2 or 5 times a
    // power of ten, which is what every atlas uses and what a reader can
    // divide by in their head
    const raw = target_px / ppk;
    out.km = niceNumber(raw);
    out.pixels = out.km * ppk;
    out.variation = scaleVariation(p, x0, y0, x1, y1);
    return out;
}

/// pixels per kilometre at a place, measured on the paper
fn pixelsPerKmAt(p: *const gp.Projection, lon: f64, lat: f64) f64 {
    // a tenth of a degree of longitude, east and west of the point
    const d = 0.05;
    const a = gp.forward(p, lon - d, lat) orelse return 0;
    const b = gp.forward(p, lon + d, lat) orelse return 0;
    const px = @sqrt((b[0] - a[0]) * (b[0] - a[0]) + (b[1] - a[1]) * (b[1] - a[1]));
    const km = groundKm(lon - d, lat, lon + d, lat);
    if (km <= 0) return 0;
    return px / km;
}

/// THE GROUND DISTANCE, on WGS84 -- GE8's geodesic, so a scale bar says
/// what a GPS says rather than what a sphere of 6371 km says.
fn groundKm(lon1: f64, lat1: f64, lon2: f64, lat2: f64) f64 {
    const gg = @import("geo_geodesy.zig");
    return gg.inverse(gg.WGS84, lat1, lon1, lat2, lon2).s12 / 1000.0;
}

/// HOW FAR THE SCALE VARIES ACROSS THE SHEET -- over the PAPER the map
/// actually draws, and not over the globe.
///
/// This walked the whole world at first, sampling -80 to +80 of latitude
/// whatever the map showed. On a world map that is right; on a CITY PLAN it
/// is nonsense, and the guard caught it at once: a Mercator fitted to two
/// tenths of a degree around Paris reported a variation of 5.76, because
/// the measure was reading ground the sheet never draws. It then refused to
/// draw a scale bar on the one kind of map where a scale bar is honest.
///
/// So it samples the PAPER RECTANGLE and inverts each sample to find the
/// place -- which every projection can now answer, closed form or Newton,
/// because GE9 gave them all an inverse. A point off the map inverts to
/// nothing and is skipped, so an oval projection's corners cost nothing.
///
/// The extremes are the semi-axes of Tissot's indicatrix, the greatest and
/// least scale in ANY direction. Measuring east-west only -- which was the
/// version before that -- reads a Mercator and an equirectangular alike,
/// since both have x = lambda and are identical along every parallel.
fn scaleVariation(p: *const gp.Projection, x0: f64, y0: f64, x1: f64, y1: f64) f64 {
    const gd = @import("geo_distortion.zig");
    if (!(x1 > x0) or !(y1 > y0)) return 1;
    var lo: f64 = math.inf(f64);
    var hi: f64 = 0;
    var seen: usize = 0;
    var j: usize = 0;
    while (j <= 12) : (j += 1) {
        const py = y0 + (y1 - y0) * @as(f64, @floatFromInt(j)) / 12.0;
        var i: usize = 0;
        while (i <= 12) : (i += 1) {
            const px = x0 + (x1 - x0) * @as(f64, @floatFromInt(i)) / 12.0;
            const g = gp.invert(p, px, py) orelse continue;
            const d = gd.distortionAt(p, g[0], g[1]);
            if (!d.ok or !math.isFinite(d.a) or !math.isFinite(d.b)) continue;
            if (d.b > 0 and d.b < lo) lo = d.b;
            if (d.a > hi) hi = d.a;
            seen += 1;
        }
    }
    if (seen == 0 or !math.isFinite(lo) or lo <= 0) return 1;
    return hi / lo;
}

/// 1, 2 or 5 times a power of ten -- the numbers a reader can divide by
fn niceNumber(x: f64) f64 {
    if (!(x > 0) or !math.isFinite(x)) return 0;
    const e = @floor(@log10(x));
    const p10 = math.pow(f64, 10, e);
    const m = x / p10;
    const nice: f64 = if (m < 1.5) 1 else if (m < 3.5) 2 else if (m < 7.5) 5 else 10;
    return nice * p10;
}

// -------------------------------------------------- vectors and streamlines
//
// A FIELD WITH TWO COMPONENTS IS A DIRECTION AT EVERY POINT -- wind,
// current, migration, the gradient of anything. There are two ways to draw
// it and they answer different questions.
//
// ARROWS answer "what is happening HERE": one glyph per place, its length
// the speed and its heading the direction. They are honest and they are
// hard to read as a whole, because the eye has to assemble a flow out of
// separate marks.
//
// STREAMLINES answer "where does this GO": a particle released at a point,
// followed while the field carries it. The eye reads them as motion
// immediately. The price is that a streamline is not a measurement at any
// single place -- it is the integral of many, so an error anywhere along it
// moves everything after.
//
// Both are here because a field usually needs both: the streamlines for the
// shape and the arrows for the magnitude.

/// the field's two components at a place, bilinearly interpolated. NEAREST
/// would put the grid's own steps into a streamline, which a reader would
/// take for structure in the flow.
fn sampleAt(g: gf.Grid, u: []const f64, v: []const f64, lon: f64, lat: f64) ?[2]f64 {
    if (g.nx < 2 or g.ny < 2 or g.dlon == 0 or g.dlat == 0) return null;
    const fx = (lon - g.lon0) / g.dlon;
    const fy = (lat - g.lat0) / g.dlat;
    if (fx < 0 or fy < 0) return null;
    const ix: usize = @intFromFloat(@floor(fx));
    const jy: usize = @intFromFloat(@floor(fy));
    if (ix + 1 >= g.nx or jy + 1 >= g.ny) return null;
    const tx = fx - @floor(fx);
    const ty = fy - @floor(fy);
    const c00 = jy * g.nx + ix;
    const c10 = c00 + 1;
    const c01 = c00 + g.nx;
    const c11 = c01 + 1;
    if (c11 >= u.len or c11 >= v.len) return null;
    const wu = u[c00] * (1 - tx) * (1 - ty) + u[c10] * tx * (1 - ty) +
        u[c01] * (1 - tx) * ty + u[c11] * tx * ty;
    const wv = v[c00] * (1 - tx) * (1 - ty) + v[c10] * tx * (1 - ty) +
        v[c01] * (1 - tx) * ty + v[c11] * tx * ty;
    if (math.isNan(wu) or math.isNan(wv)) return null;
    return .{ wu, wv };
}

/// ONE STREAMLINE, by fourth-order Runge-Kutta.
///
/// Euler's method would be three lines shorter and would spiral outward on
/// a field that rotates -- a closed circular flow would come back as an
/// opening spiral, which a reader would take for a real divergence rather
/// than for the integrator's own error. RK4 costs four samples a step and
/// closes the circle.
///
/// THE STEP IS IN DEGREES AND THE FIELD'S EASTWARD COMPONENT IS DIVIDED BY
/// cos(latitude), because a degree of longitude is not a degree of ground
/// anywhere but the equator. Without it every streamline drifts east as it
/// goes poleward, at exactly the rate that looks like a real jet.
pub fn streamline(g: gf.Grid, u: []const f64, v: []const f64, lon0: f64, lat0: f64, step_deg: f64, max_steps: usize, out: []f64) usize {
    var lon = lon0;
    var lat = lat0;
    var n: usize = 0;
    const cap = out.len / 2;
    var s: usize = 0;
    while (s < max_steps and n < cap) : (s += 1) {
        out[n * 2] = lon;
        out[n * 2 + 1] = lat;
        n += 1;
        const k1 = derivAt(g, u, v, lon, lat) orelse break;
        const k2 = derivAt(g, u, v, lon + step_deg * k1[0] / 2, lat + step_deg * k1[1] / 2) orelse break;
        const k3 = derivAt(g, u, v, lon + step_deg * k2[0] / 2, lat + step_deg * k2[1] / 2) orelse break;
        const k4 = derivAt(g, u, v, lon + step_deg * k3[0], lat + step_deg * k3[1]) orelse break;
        const dlon = step_deg * (k1[0] + 2 * k2[0] + 2 * k3[0] + k4[0]) / 6;
        const dlat = step_deg * (k1[1] + 2 * k2[1] + 2 * k3[1] + k4[1]) / 6;
        if (@abs(dlon) < 1e-12 and @abs(dlat) < 1e-12) break; // a still place
        lon += dlon;
        lat += dlat;
        if (lat > 89.9 or lat < -89.9) break;
    }
    return n;
}

/// the field as a rate of change of DEGREES, which is what a step in
/// degrees needs: the eastward component divided by cos(latitude), and
/// both normalised so the step length is a step and not a speed
fn derivAt(g: gf.Grid, u: []const f64, v: []const f64, lon: f64, lat: f64) ?[2]f64 {
    const w = sampleAt(g, u, v, lon, lat) orelse return null;
    const cf = @cos(lat * DEG);
    if (@abs(cf) < 1e-6) return null;
    const du = w[0] / cf;
    const dv = w[1];
    const m = @sqrt(du * du + dv * dv);
    if (m < 1e-12) return .{ 0, 0 };
    return .{ du / m, dv / m };
}

/// THE ARROWS: one per grid node, as [ lon, lat, eastward, northward,
/// magnitude ] -- the caller decides how to draw them, because an arrow's
/// length is a SCALE choice and this engine does not know how big the paper
/// is. Answers how many it wrote.
pub fn vectorField(g: gf.Grid, u: []const f64, v: []const f64, every: usize, out: []f64) usize {
    const step = if (every < 1) 1 else every;
    var n: usize = 0;
    const cap = out.len / 5;
    var j: usize = 0;
    while (j < g.ny) : (j += step) {
        var i: usize = 0;
        while (i < g.nx) : (i += step) {
            if (n >= cap) return n;
            const idx = j * g.nx + i;
            if (idx >= u.len or idx >= v.len) continue;
            const wu = u[idx];
            const wv = v[idx];
            if (math.isNan(wu) or math.isNan(wv)) continue;
            out[n * 5] = g.lonAt(i);
            out[n * 5 + 1] = g.latAt(j);
            out[n * 5 + 2] = wu;
            out[n * 5 + 3] = wv;
            out[n * 5 + 4] = @sqrt(wu * wu + wv * wv);
            n += 1;
        }
    }
    return n;
}
