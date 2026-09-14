// GE7a -- POINT PATTERNS ON THE SPHERE.
//
// The questions an analyst asks of a table of places before any other:
// are these clinics CLUSTERED, SCATTERED, or as random as thrown rice?
// Where is the middle of them, and which way do they spread? Every one of
// those is a spatial statistic, and this file is where they are computed --
// in the engine, because the honest ones are all-pairs and ten thousand
// places is fifty million distances.
//
// FOUR DECISIONS, EACH THE STANDARD ONE:
//
//   1. DISTANCES ARE GREAT-CIRCLE, ON THE SPHERE, from unit vectors. The
//      chord form 2R asin(|a-b|/2) is used rather than acos of a dot
//      product, because the acos form loses every digit that matters at
//      the small angles a nearest-neighbour distance is.
//   2. THE WINDOW IS PART OF THE PATTERN. Ripley's K, the F function and
//      the Clark-Evans index are meaningless without the area the points
//      were observed in: a hundred wells in Tunisia and a hundred in Niger
//      are the same list and opposite answers. Every function that needs
//      it takes the window's area or its outline.
//   3. NO ANALYTIC EDGE CORRECTION. K is reported UNCORRECTED and the null
//      is drawn by SIMULATION -- the same count of uniform points in the
//      same window, many times, and the band they make. That is what
//      spatstat's envelope() does and it subjects the null to exactly the
//      edge effect the data has, so no correction formula has to be
//      trusted. The cost is compute, and compute is the engine's to spend.
//   4. UNIFORM MEANS UNIFORM ON THE SPHERE. A point drawn with latitude
//      uniform in degrees piles up toward the poles; the latitude is drawn
//      uniform in SIN(latitude), which is exact.
//
// The ellipse -- the "standard deviational ellipse" every GIS reports -- is
// computed in a tangent plane about the mean centre, which is how every GIS
// computes it and is right to a part in a thousand at country scale.

const std = @import("std");
const gp = @import("geo_projection.zig");

const DEG: f64 = std.math.pi / 180.0;
const EARTH_KM: f64 = 6371.0088;

// ------------------------------------------------------------------ vectors

const V3 = struct { x: f64, y: f64, z: f64 };

fn unit(lon_deg: f64, lat_deg: f64) V3 {
    const l = lon_deg * DEG;
    const f = lat_deg * DEG;
    const c = @cos(f);
    return .{ .x = c * @cos(l), .y = c * @sin(l), .z = @sin(f) };
}

fn toLonLat(v: V3) [2]f64 {
    const n = @sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
    if (n < 1e-300) return .{ 0, 0 };
    return .{ std.math.atan2(v.y, v.x) / DEG, std.math.asin(v.z / n) / DEG };
}

/// great-circle distance in km between two unit vectors, by the chord
fn distKm(a: V3, b: V3) f64 {
    const dx = a.x - b.x;
    const dy = a.y - b.y;
    const dz = a.z - b.z;
    const chord = @sqrt(dx * dx + dy * dy + dz * dz);
    var h = chord / 2;
    if (h > 1) h = 1;
    return 2 * EARTH_KM * std.math.asin(h);
}

/// great-circle distance in km between two places. The public door on the
/// chord form above -- GE7b's fields ask it per cell per point, and a second
/// implementation of one distance is the defect shape this plane has already
/// met three times.
pub fn distanceKm(lon1: f64, lat1: f64, lon2: f64, lat2: f64) f64 {
    return distKm(unit(lon1, lat1), unit(lon2, lat2));
}

fn toUnits(alloc: std.mem.Allocator, lonlat: []const f64) ![]V3 {
    const n = lonlat.len / 2;
    const out = try alloc.alloc(V3, n);
    for (0..n) |i| out[i] = unit(lonlat[i * 2], lonlat[i * 2 + 1]);
    return out;
}

/// the length of a ring in km along great circles, closed
pub fn ringLengthKm(lonlat: []const f64) f64 {
    const n = lonlat.len / 2;
    if (n < 2) return 0;
    var total: f64 = 0;
    const first = unit(lonlat[0], lonlat[1]);
    var prev = first;
    var i: usize = 1;
    while (i < n) : (i += 1) {
        const cur = unit(lonlat[i * 2], lonlat[i * 2 + 1]);
        total += distKm(prev, cur);
        prev = cur;
    }
    return total + distKm(prev, first);
}

// ------------------------------------------------------------- the window

/// The study region as a set of outer rings, and its bounding box in
/// degrees [lon0, lat0, lon1, lat1]. A point is in the window when it is in
/// ANY ring. HOLES ARE NOT HONOURED: a lake inside a governorate counts as
/// governorate, which for an administrative window is wrong by the area of
/// the lake and no more.
pub const Window = struct {
    rings: []const []const f64,
    bbox: [4]f64,

    pub fn contains(self: *const Window, lon: f64, lat: f64) bool {
        for (self.rings) |r| if (gp.ringContains(r, lon, lat)) return true;
        return false;
    }
};

/// Draw `n` points uniform on the sphere inside the window, by rejection
/// in the bounding box. Returns how many were placed -- fewer than n when
/// the window is a sliver of its box and the try budget ran out, which the
/// caller must read rather than assume.
pub fn sampleInside(w: *const Window, n: usize, seed: u64, out: []f64) usize {
    var prng = std.Random.DefaultPrng.init(seed);
    const rnd = prng.random();
    const lon0 = w.bbox[0];
    const lon1 = w.bbox[2];
    const s0 = @sin(w.bbox[1] * DEG);
    const s1 = @sin(w.bbox[3] * DEG);
    var placed: usize = 0;
    var tries: usize = 0;
    const cap: usize = n * 400 + 4000;
    while (placed < n and tries < cap) : (tries += 1) {
        const lon = lon0 + (lon1 - lon0) * rnd.float(f64);
        const lat = std.math.asin(s0 + (s1 - s0) * rnd.float(f64)) / DEG;
        if (!w.contains(lon, lat)) continue;
        out[placed * 2] = lon;
        out[placed * 2 + 1] = lat;
        placed += 1;
    }
    return placed;
}

// ------------------------------------------------------ nearest neighbours

/// the distance from every point to its nearest other point, km. O(n^2).
pub fn nearestNeighbourKm(alloc: std.mem.Allocator, lonlat: []const f64, out: []f64) !void {
    const u = try toUnits(alloc, lonlat);
    defer alloc.free(u);
    const n = u.len;
    for (0..n) |i| out[i] = std.math.inf(f64);
    for (0..n) |i| {
        var j = i + 1;
        while (j < n) : (j += 1) {
            const d = distKm(u[i], u[j]);
            if (d < out[i]) out[i] = d;
            if (d < out[j]) out[j] = d;
        }
    }
}

pub const ClarkEvans = struct {
    r: f64, // observed mean NN distance over the expected one
    z: f64, // standardised: below -1.96 clustered, above +1.96 dispersed
    observed_km: f64,
    expected_km: f64,
};

/// Clark and Evans (1954), with DONNELLY'S EDGE CORRECTION (1978).
///
/// Uncorrected, the index leans toward "dispersed" on every real window:
/// a point near the border has no neighbours beyond it, so its nearest one
/// is farther than it would be in an unbounded plane, and the mean rises.
/// Five hundred uniform points in a window the shape of a country read as
/// DISPERSED at z = 2.0 before this correction, and as random at 1.2 after
/// it -- the first end-to-end run of this file said so. Donnelly adds
/// (0.0514 + 0.041 / sqrt n) P / n to the expected distance and
/// 0.037 P sqrt(A / n^5) to its variance, P being the window's perimeter;
/// the constants are his and are the ones spatstat applies. They were
/// fitted for rectangles and are approximate on a ragged coast, which is
/// said here so that nobody reads the third decimal. Pass a perimeter of
/// zero for the uncorrected index.
pub fn clarkEvans(nn_km: []const f64, area_km2: f64, perimeter_km: f64) ClarkEvans {
    const n: f64 = @floatFromInt(nn_km.len);
    if (nn_km.len < 2 or area_km2 <= 0) return .{ .r = 0, .z = 0, .observed_km = 0, .expected_km = 0 };
    var s: f64 = 0;
    for (nn_km) |d| s += d;
    const obs = s / n;
    const exp = 0.5 * @sqrt(area_km2 / n) + (0.0514 + 0.041 / @sqrt(n)) * perimeter_km / n;
    const variance = 0.070 * area_km2 / (n * n) + 0.037 * perimeter_km * @sqrt(area_km2 / (n * n * n * n * n));
    const se = @sqrt(variance);
    return .{ .r = obs / exp, .z = (obs - exp) / se, .observed_km = obs, .expected_km = exp };
}

// ------------------------------------------------------- K, G and F

/// first index whose radius is >= d, or radii.len when d is beyond them all
fn binOf(radii: []const f64, d: f64) usize {
    var lo: usize = 0;
    var hi: usize = radii.len;
    while (lo < hi) {
        const mid = (lo + hi) / 2;
        if (radii[mid] < d) lo = mid + 1 else hi = mid;
    }
    return lo;
}

/// Ripley's K at each radius, UNCORRECTED for the edge:
///   K(r) = A / (n (n-1)) * sum over ordered pairs of 1[d_ij <= r]
/// Radii must ascend. All pair distances are taken once and binned, so the
/// cost is n^2 / 2 distances and not n^2 * radii.
pub fn ripleyK(alloc: std.mem.Allocator, lonlat: []const f64, area_km2: f64, radii: []const f64, out: []f64) !void {
    const u = try toUnits(alloc, lonlat);
    defer alloc.free(u);
    const n = u.len;
    const counts = try alloc.alloc(f64, radii.len + 1);
    defer alloc.free(counts);
    @memset(counts, 0);
    for (0..n) |i| {
        var j = i + 1;
        while (j < n) : (j += 1) counts[binOf(radii, distKm(u[i], u[j]))] += 2;
    }
    const nf: f64 = @floatFromInt(n);
    const scale = if (n > 1) area_km2 / (nf * (nf - 1)) else 0;
    var acc: f64 = 0;
    for (0..radii.len) |k| {
        acc += counts[k];
        out[k] = acc * scale;
    }
}

/// the fraction of values <= each radius (radii ascending): the G function
/// when given nearest-neighbour distances, the F function when given
/// empty-space distances
pub fn cdfAt(values: []const f64, radii: []const f64, out: []f64) void {
    for (0..radii.len) |k| out[k] = 0;
    if (values.len == 0) return;
    for (values) |v| {
        const b = binOf(radii, v);
        if (b < radii.len) out[b] += 1;
    }
    const n: f64 = @floatFromInt(values.len);
    var acc: f64 = 0;
    for (0..radii.len) |k| {
        acc += out[k];
        out[k] = acc / n;
    }
}

/// distance from each of m uniform test points in the window to the nearest
/// data point: the raw material of the F (empty space) function
pub fn emptySpaceKm(alloc: std.mem.Allocator, lonlat: []const f64, w: *const Window, m: usize, seed: u64, out: []f64) !usize {
    const tests = try alloc.alloc(f64, m * 2);
    defer alloc.free(tests);
    const got = sampleInside(w, m, seed, tests);
    const u = try toUnits(alloc, lonlat);
    defer alloc.free(u);
    for (0..got) |t| {
        const tv = unit(tests[t * 2], tests[t * 2 + 1]);
        var best = std.math.inf(f64);
        for (u) |pv| {
            const d = distKm(tv, pv);
            if (d < best) best = d;
        }
        out[t] = best;
    }
    return got;
}

/// THE ENVELOPE BY SIMULATION: `sims` uniform patterns of `n` points in the
/// window, K of each at every radius, and per radius the minimum, the
/// maximum and the mean. `out` is radii.len * 3, laid [lo, hi, mean] per
/// radius. Thirty-nine simulations is the classic count: the observed K
/// outside the band of 39 is significant at 5% on each side.
pub fn kEnvelope(alloc: std.mem.Allocator, w: *const Window, n: usize, area_km2: f64, radii: []const f64, sims: usize, seed: u64, out: []f64) !void {
    const pts = try alloc.alloc(f64, n * 2);
    defer alloc.free(pts);
    const k = try alloc.alloc(f64, radii.len);
    defer alloc.free(k);
    for (0..radii.len) |r| {
        out[r * 3] = std.math.inf(f64);
        out[r * 3 + 1] = -std.math.inf(f64);
        out[r * 3 + 2] = 0;
    }
    var done: usize = 0;
    for (0..sims) |s| {
        const got = sampleInside(w, n, seed +% (s + 1) *% 0x9E3779B97F4A7C15, pts);
        if (got < 2) continue;
        try ripleyK(alloc, pts[0 .. got * 2], area_km2, radii, k);
        done += 1;
        for (0..radii.len) |r| {
            if (k[r] < out[r * 3]) out[r * 3] = k[r];
            if (k[r] > out[r * 3 + 1]) out[r * 3 + 1] = k[r];
            out[r * 3 + 2] += k[r];
        }
    }
    if (done > 0) {
        const df: f64 = @floatFromInt(done);
        for (0..radii.len) |r| out[r * 3 + 2] /= df;
    }
}

// ------------------------------------------------------- centres and spread

/// the mean centre: the normalised sum of the unit vectors
pub fn meanCentre(lonlat: []const f64) [2]f64 {
    var s = V3{ .x = 0, .y = 0, .z = 0 };
    const n = lonlat.len / 2;
    for (0..n) |i| {
        const v = unit(lonlat[i * 2], lonlat[i * 2 + 1]);
        s.x += v.x;
        s.y += v.y;
        s.z += v.z;
    }
    return toLonLat(s);
}

/// the spatial median: the point with the least total distance to all the
/// others, by Weiszfeld's iteration on the sphere from the mean centre
pub fn spatialMedian(alloc: std.mem.Allocator, lonlat: []const f64) ![2]f64 {
    const u = try toUnits(alloc, lonlat);
    defer alloc.free(u);
    if (u.len == 0) return .{ 0, 0 };
    var c = unit(meanCentre(lonlat)[0], meanCentre(lonlat)[1]);
    var it: usize = 0;
    while (it < 200) : (it += 1) {
        var s = V3{ .x = 0, .y = 0, .z = 0 };
        var wsum: f64 = 0;
        for (u) |p| {
            const d = distKm(c, p);
            if (d < 1e-6) continue;
            const wgt = 1 / d;
            s.x += p.x * wgt;
            s.y += p.y * wgt;
            s.z += p.z * wgt;
            wsum += wgt;
        }
        if (wsum == 0) break;
        const nrm = @sqrt(s.x * s.x + s.y * s.y + s.z * s.z);
        if (nrm < 1e-300) break;
        const next = V3{ .x = s.x / nrm, .y = s.y / nrm, .z = s.z / nrm };
        const moved = distKm(c, next);
        c = next;
        if (moved < 1e-7) break;
    }
    return toLonLat(c);
}

pub const Ellipse = struct {
    lon: f64,
    lat: f64,
    sd_km: f64, // the standard distance: root mean square distance from the centre
    major_km: f64, // semi-axes at one standard deviation
    minor_km: f64,
    bearing_deg: f64, // of the major axis, clockwise from north, in [0, 180)
};

/// THE STANDARD DEVIATIONAL ELLIPSE, in a tangent plane about the mean
/// centre: x east and y north in km, the covariance's eigenvectors are the
/// axes and its eigenvalues their variances. sqrt(2 * eigenvalue) is the
/// convention every GIS prints as "one standard deviation", and is used here
/// so a reader can compare.
pub fn ellipse(lonlat: []const f64) Ellipse {
    const n = lonlat.len / 2;
    const c = meanCentre(lonlat);
    if (n < 2) return .{ .lon = c[0], .lat = c[1], .sd_km = 0, .major_km = 0, .minor_km = 0, .bearing_deg = 0 };
    const cosl = @cos(c[1] * DEG);
    var sxx: f64 = 0;
    var syy: f64 = 0;
    var sxy: f64 = 0;
    for (0..n) |i| {
        var dl = lonlat[i * 2] - c[0];
        if (dl > 180) dl -= 360;
        if (dl < -180) dl += 360;
        const x = dl * DEG * cosl * EARTH_KM;
        const y = (lonlat[i * 2 + 1] - c[1]) * DEG * EARTH_KM;
        sxx += x * x;
        syy += y * y;
        sxy += x * y;
    }
    const nf: f64 = @floatFromInt(n);
    const a = sxx / nf;
    const b = sxy / nf;
    const d = syy / nf;
    const theta = 0.5 * std.math.atan2(2 * b, a - d); // from east, anticlockwise
    const half = (a + d) / 2;
    const rad = @sqrt(((a - d) / 2) * ((a - d) / 2) + b * b);
    var l1 = half + rad;
    var l2 = half - rad;
    if (l1 < 0) l1 = 0;
    if (l2 < 0) l2 = 0;
    var bearing = 90 - theta / DEG;
    while (bearing < 0) bearing += 180;
    while (bearing >= 180) bearing -= 180;
    return .{
        .lon = c[0],
        .lat = c[1],
        .sd_km = @sqrt(a + d),
        .major_km = @sqrt(2 * l1),
        .minor_km = @sqrt(2 * l2),
        .bearing_deg = bearing,
    };
}

/// the ellipse as a ring of lon/lat points, closed, ready to draw
pub fn ellipseRing(lon: f64, lat: f64, major_km: f64, minor_km: f64, bearing_deg: f64, points: usize, out: []f64) void {
    const theta = (90 - bearing_deg) * DEG;
    const ct = @cos(theta);
    const st = @sin(theta);
    const cosl = @cos(lat * DEG);
    for (0..points) |i| {
        const t = 2 * std.math.pi * @as(f64, @floatFromInt(i)) / @as(f64, @floatFromInt(points));
        const u = major_km * @cos(t);
        const v = minor_km * @sin(t);
        const x = u * ct - v * st;
        const y = u * st + v * ct;
        out[i * 2] = lon + (x / (EARTH_KM * cosl)) / DEG;
        out[i * 2 + 1] = lat + (y / EARTH_KM) / DEG;
    }
}

// --------------------------------------------------- two more processes

/// a point at a given bearing and distance from another, on the sphere
fn destination(lon: f64, lat: f64, bearing_deg: f64, km: f64) [2]f64 {
    const f1 = lat * DEG;
    const l1 = lon * DEG;
    const br = bearing_deg * DEG;
    const ad = km / EARTH_KM;
    const f2 = std.math.asin(@sin(f1) * @cos(ad) + @cos(f1) * @sin(ad) * @cos(br));
    const l2 = l1 + std.math.atan2(@sin(br) * @sin(ad) * @cos(f1), @cos(ad) - @sin(f1) * @sin(f2));
    return .{ l2 / DEG, f2 / DEG };
}

/// A MATERN CLUSTER PROCESS: `parents` uniform in the window, `children`
/// round each, uniform in a disk of `radius_km`, kept only inside the
/// window. The standard clustered null, and the clustered pattern the
/// tests judge Clark-Evans against. Returns the points placed.
pub fn maternCluster(w: *const Window, parents: usize, children: usize, radius_km: f64, seed: u64, out: []f64) usize {
    var prng = std.Random.DefaultPrng.init(seed ^ 0xA5A5A5A5);
    const rnd = prng.random();
    var placed: usize = 0;
    const cap = out.len / 2;
    var pbuf: [2]f64 = undefined;
    for (0..parents) |k| {
        const got = sampleInside(w, 1, seed +% (k + 7) *% 0x9E3779B97F4A7C15, &pbuf);
        if (got == 0) continue;
        for (0..children) |_| {
            if (placed >= cap) return placed;
            const r = radius_km * @sqrt(rnd.float(f64)); // uniform in the disk
            const b = 360 * rnd.float(f64);
            const q = destination(pbuf[0], pbuf[1], b, r);
            if (!w.contains(q[0], q[1])) continue;
            out[placed * 2] = q[0];
            out[placed * 2 + 1] = q[1];
            placed += 1;
        }
    }
    return placed;
}

/// A HARD-CORE PROCESS by simple sequential inhibition: uniform candidates,
/// each kept only if no accepted point lies within `min_km`. Stops at `n`
/// or when the try budget is spent -- a window can hold only so many discs.
pub fn hardCore(alloc: std.mem.Allocator, w: *const Window, n: usize, min_km: f64, seed: u64, out: []f64) !usize {
    var prng = std.Random.DefaultPrng.init(seed ^ 0x5A5A5A5A);
    const rnd = prng.random();
    const kept = try alloc.alloc(V3, n);
    defer alloc.free(kept);
    const lon0 = w.bbox[0];
    const lon1 = w.bbox[2];
    const s0 = @sin(w.bbox[1] * DEG);
    const s1 = @sin(w.bbox[3] * DEG);
    var placed: usize = 0;
    var tries: usize = 0;
    // TWENTY THOUSAND REJECTIONS IN A ROW IS A FULL WINDOW. The first
    // version ran to a try budget proportional to n, and a guard asking
    // for a hundred thousand discs a window could hold forty of spent
    // two hundred million tries finding that out -- fifty seconds for a
    // NEGATIVE assertion. Sequential inhibition stops when it stops
    // placing, which is the standard termination and the honest one.
    var refused: usize = 0;
    const cap: usize = n * 2000 + 4000;
    while (placed < n and tries < cap) : (tries += 1) {
        const lon = lon0 + (lon1 - lon0) * rnd.float(f64);
        const lat = std.math.asin(s0 + (s1 - s0) * rnd.float(f64)) / DEG;
        if (!w.contains(lon, lat)) continue;
        const v = unit(lon, lat);
        var ok = true;
        for (kept[0..placed]) |k| {
            if (distKm(v, k) < min_km) {
                ok = false;
                break;
            }
        }
        if (!ok) {
            refused += 1;
            if (refused > 20000) break;
            continue;
        }
        refused = 0;
        kept[placed] = v;
        out[placed * 2] = lon;
        out[placed * 2 + 1] = lat;
        placed += 1;
    }
    return placed;
}

// ------------------------------------------------------------------ tests

const testing = std.testing;
const ta = testing.allocator;

/// a 4 x 4 degree box on the equator, as a window
fn squareWindow() struct { ring: [10]f64, bbox: [4]f64 } {
    return .{ .ring = .{ 0, 0, 4, 0, 4, 4, 0, 4, 0, 0 }, .bbox = .{ 0, 0, 4, 4 } };
}

test "uniform means uniform on the sphere: a band near the pole is not favoured" {
    // a window from 60N to 80N: in degrees the upper half is as tall as the
    // lower, on the sphere it holds far less area, and must get fewer points
    const ring = [_]f64{ 0, 60, 10, 60, 10, 80, 0, 80, 0, 60 };
    const rs = [_][]const f64{&ring};
    const w = Window{ .rings = &rs, .bbox = .{ 0, 60, 10, 80 } };
    const buf = try ta.alloc(f64, 40000 * 2);
    defer ta.free(buf);
    const got = sampleInside(&w, 40000, 7, buf);
    try testing.expect(got == 40000);
    var upper: usize = 0;
    for (0..got) |i| if (buf[i * 2 + 1] > 70) {
        upper += 1;
    };
    // expected share of the upper half is (sin80 - sin70) / (sin80 - sin60)
    // = 0.04512 / 0.11878 = 0.380; the first draft of this line said 0.3985
    // and put the band's lower edge ON the expectation, so a correct sampler
    // failed it half the time. 40,000 draws give a standard error of 0.0024,
    // so +-0.01 is four of them.
    const share: f64 = @as(f64, @floatFromInt(upper)) / 40000.0;
    try testing.expect(share > 0.37 and share < 0.39);
}

test "a uniform pattern reads as random, a Matern one as clustered, a hard-core one as dispersed" {
    const sq = squareWindow();
    const rs = [_][]const f64{&sq.ring};
    const w = Window{ .rings = &rs, .bbox = sq.bbox };
    const area = gp.ringArea(&sq.ring) * EARTH_KM * EARTH_KM;
    const perim = ringLengthKm(&sq.ring);
    const n: usize = 600;
    const pts = try ta.alloc(f64, n * 2);
    defer ta.free(pts);
    const nn = try ta.alloc(f64, n);
    defer ta.free(nn);

    var got = sampleInside(&w, n, 11, pts);
    try nearestNeighbourKm(ta, pts[0 .. got * 2], nn[0..got]);
    const random = clarkEvans(nn[0..got], area, perim);
    try testing.expect(random.r > 0.9 and random.r < 1.1);
    try testing.expect(@abs(random.z) < 3);

    got = maternCluster(&w, 12, 50, 20, 11, pts);
    try nearestNeighbourKm(ta, pts[0 .. got * 2], nn[0..got]);
    const clustered = clarkEvans(nn[0..got], area, perim);
    try testing.expect(clustered.r < 0.6 and clustered.z < -1.96);

    got = try hardCore(ta, &w, n, 12, 11, pts);
    try nearestNeighbourKm(ta, pts[0 .. got * 2], nn[0..got]);
    const dispersed = clarkEvans(nn[0..got], area, perim);
    try testing.expect(dispersed.r > 1.2 and dispersed.z > 1.96);
}

test "a ring's length is its edges' great-circle lengths, closed" {
    // 4 degrees of the equator is 444.8 km; the meridians the same; the top
    // edge at 4N is a great circle a shade shorter than the parallel
    const sq = squareWindow();
    const p = ringLengthKm(&sq.ring);
    try testing.expect(@abs(p / 1779.2 - 1) < 0.01);
    try testing.expect(ringLengthKm(&[_]f64{ 0, 0 }) == 0);
}

test "Donnelly's correction raises the expected distance and lowers z, and by a little" {
    const sq = squareWindow();
    const rs = [_][]const f64{&sq.ring};
    const w = Window{ .rings = &rs, .bbox = sq.bbox };
    const area = gp.ringArea(&sq.ring) * EARTH_KM * EARTH_KM;
    const perim = ringLengthKm(&sq.ring);
    const n: usize = 400;
    const pts = try ta.alloc(f64, n * 2);
    defer ta.free(pts);
    const got = sampleInside(&w, n, 21, pts);
    const nn = try ta.alloc(f64, got);
    defer ta.free(nn);
    try nearestNeighbourKm(ta, pts[0 .. got * 2], nn);
    const naive = clarkEvans(nn, area, 0);
    const donn = clarkEvans(nn, area, perim);
    try testing.expect(donn.expected_km > naive.expected_km);
    try testing.expect(donn.expected_km - naive.expected_km < 2);
    try testing.expect(donn.z < naive.z);
    try testing.expect(donn.observed_km == naive.observed_km);
}

test "K of a uniform pattern is pi r squared, and the envelope brackets it" {
    const sq = squareWindow();
    const rs = [_][]const f64{&sq.ring};
    const w = Window{ .rings = &rs, .bbox = sq.bbox };
    const area = gp.ringArea(&sq.ring) * EARTH_KM * EARTH_KM;
    const n: usize = 800;
    const pts = try ta.alloc(f64, n * 2);
    defer ta.free(pts);
    const got = sampleInside(&w, n, 3, pts);
    const radii = [_]f64{ 10, 20, 30, 40 };
    var k: [4]f64 = undefined;
    try ripleyK(ta, pts[0 .. got * 2], area, &radii, &k);
    // at small r the edge loss is small, so K is close to pi r^2
    try testing.expect(@abs(k[0] / (std.math.pi * 100) - 1) < 0.15);
    var env: [12]f64 = undefined;
    try kEnvelope(ta, &w, got, area, &radii, 19, 99, &env);
    for (0..4) |r| {
        try testing.expect(env[r * 3] <= k[r] + 1e-9 or k[r] <= env[r * 3 + 1] + 1e-9);
        try testing.expect(env[r * 3] <= env[r * 3 + 2] and env[r * 3 + 2] <= env[r * 3 + 1]);
    }
}

test "G and F are distributions: they rise from 0 to 1 and never fall" {
    const sq = squareWindow();
    const rs = [_][]const f64{&sq.ring};
    const w = Window{ .rings = &rs, .bbox = sq.bbox };
    const n: usize = 300;
    const pts = try ta.alloc(f64, n * 2);
    defer ta.free(pts);
    const got = sampleInside(&w, n, 5, pts);
    const nn = try ta.alloc(f64, got);
    defer ta.free(nn);
    try nearestNeighbourKm(ta, pts[0 .. got * 2], nn);
    const radii = [_]f64{ 1, 5, 10, 20, 50, 100, 1000 };
    var g: [7]f64 = undefined;
    cdfAt(nn, &radii, &g);
    var prev: f64 = -1;
    for (g) |v| {
        try testing.expect(v >= prev);
        prev = v;
    }
    try testing.expect(g[6] == 1);
    const es = try ta.alloc(f64, 500);
    defer ta.free(es);
    const m = try emptySpaceKm(ta, pts[0 .. got * 2], &w, 500, 8, es);
    var f: [7]f64 = undefined;
    cdfAt(es[0..m], &radii, &f);
    try testing.expect(f[6] == 1 and f[0] <= f[1]);
}

test "the mean centre of a symmetric pattern is its centre, and the ellipse lies along the spread" {
    // a north-south line of points: major axis bears 0 (north), minor is 0
    const line = [_]f64{ 10, -2, 10, -1, 10, 0, 10, 1, 10, 2 };
    const c = meanCentre(&line);
    try testing.expect(@abs(c[0] - 10) < 1e-9 and @abs(c[1]) < 1e-9);
    const e = ellipse(&line);
    try testing.expect(@abs(e.bearing_deg) < 1e-6 or @abs(e.bearing_deg - 180) < 1e-6);
    try testing.expect(e.minor_km < 1e-6 and e.major_km > 200);
    // an east-west line bears 90
    const ew = [_]f64{ 8, 0, 9, 0, 10, 0, 11, 0, 12, 0 };
    try testing.expect(@abs(ellipse(&ew).bearing_deg - 90) < 1e-6);
    const med = try spatialMedian(ta, &line);
    try testing.expect(@abs(med[0] - 10) < 1e-6 and @abs(med[1]) < 1e-6);
}

test "the ellipse ring closes on itself and sits on the ellipse" {
    var ring: [16]f64 = undefined;
    ellipseRing(10, 30, 100, 50, 45, 8, &ring);
    // every point is on the ellipse: its tangent-plane coordinates satisfy the equation
    const cosl = @cos(30 * DEG);
    for (0..8) |i| {
        const x = (ring[i * 2] - 10) * DEG * cosl * EARTH_KM;
        const y = (ring[i * 2 + 1] - 30) * DEG * EARTH_KM;
        const th = (90 - 45) * DEG;
        const u = x * @cos(th) + y * @sin(th);
        const v = -x * @sin(th) + y * @cos(th);
        const q = (u / 100) * (u / 100) + (v / 50) * (v / 50);
        try testing.expect(@abs(q - 1) < 1e-6);
    }
}
