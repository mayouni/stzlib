//! GE7d -- POINT PROCESSES AS THINGS, AND NULL MODELS THAT ARE NOT CSR.
//!
//! GE7a can already ask whether a pattern is clustered. It asks by
//! simulating COMPLETE SPATIAL RANDOMNESS and seeing whether the observed K
//! escapes the band -- and that is the least interesting question in the
//! subject, because almost nothing real is completely random. Trees are
//! clustered because seeds fall near their parent. Clinics are clustered
//! because people are. Rejecting CSR tells you the world is not a uniform
//! scatter, which nobody thought it was.
//!
//! THE QUESTION WORTH ASKING IS AGAINST A MODEL THAT ALREADY EXPLAINS
//! SOMETHING. "Is this more clustered than seed dispersal alone would
//! make it?" "Is this clustered beyond where the people already are?" Each
//! of those needs a null model that is NOT uniform, and therefore needs a
//! point process to be a THING a caller can name, parameterise and hand to
//! the envelope -- not a generator buried inside one method.
//!
//! SO THIS MODULE MAKES A PROCESS FIRST CLASS. Seven of them, each a
//! mechanism rather than a shape:
//!
//!   POISSON            no interaction at all: every point is placed
//!                      without reference to any other. The number of
//!                      points is RANDOM -- that is what makes it Poisson.
//!   BINOMIAL           the same, conditioned on a fixed count. It is what
//!                      GE7a has been simulating all along without saying
//!                      so, and it has LESS VARIANCE than Poisson, so an
//!                      envelope built on it is narrower than the one the
//!                      reader thinks they are looking at.
//!   INHOMOGENEOUS      no interaction either, but a varying intensity --
//!                      the null model that says "the pattern follows the
//!                      population" and lets you test for clustering ON TOP
//!                      of that.
//!   MATERN CLUSTER     parents you never see, children uniform in a disc
//!                      around each. Seed fall, essentially.
//!   THOMAS             the same but children scattered by a GAUSSIAN, so a
//!                      cluster has no edge. The choice between this and
//!                      Matern is a claim about whether the mechanism has a
//!                      range or a scale.
//!   MATERN II          inhibition by DELETION: propose a Poisson pattern,
//!                      then remove any point that has an older neighbour
//!                      too close. Territories claimed in order.
//!   SSI                inhibition by REFUSAL: propose points one at a time
//!                      and keep only those that land clear. Packing.
//!
//! MATERN II AND SSI LOOK THE SAME AND ARE NOT, and the difference is the
//! reason both are here. Matern II thins a pattern that already exists, so
//! it cannot reach a high density however hard it tries -- past a point,
//! every new point deletes as many as it adds. SSI builds one up, so it
//! packs tighter and its points are NOT a thinning of anything. Reporting a
//! hard-core model without saying which mechanism produced it is reporting
//! a number without its units.
//!
//! WHY THE POISSON COUNT IS DRAWN BY KNUTH'S METHOD. It multiplies uniforms
//! until the product falls below exp(-lambda), which is exact, is four
//! lines, and can be read against the definition. The fast alternatives are
//! rejection schemes with transcribed constants, and this file takes the
//! same view of those that geo_geodesy.zig takes of Karney's series: a
//! mistyped constant there produces a distribution that is subtly wrong,
//! passes every smoke test, and is caught by nothing. Knuth's underflows
//! above lambda of about 700, which is handled by SPLITTING rather than by
//! an approximation -- a Poisson variable is the sum of independent Poisson
//! variables whose rates add, so a rate of 5000 is ten draws at 500. That
//! identity is the definition of the distribution, not a trick.

const std = @import("std");
const math = std.math;
const gs = @import("geo_stats.zig");
const gf = @import("geo_field.zig");

const DEG: f64 = math.pi / 180.0;
const EARTH_KM: f64 = 6371.0088;

pub const Kind = enum(u8) {
    poisson = 0,
    binomial = 1,
    inhomogeneous = 2,
    matern_cluster = 3,
    thomas = 4,
    matern_ii = 5,
    ssi = 6,

    pub fn name(k: Kind) [:0]const u8 {
        return switch (k) {
            .poisson => "Poisson",
            .binomial => "Binomial",
            .inhomogeneous => "Inhomogeneous",
            .matern_cluster => "MaternCluster",
            .thomas => "Thomas",
            .matern_ii => "MaternII",
            .ssi => "SSI",
        };
    }
    /// does this process place points WITHOUT reference to one another?
    /// The three that do are the honest null models; the four that do not
    /// are mechanisms with an interaction to be tested for.
    pub fn isPoissonFamily(k: Kind) bool {
        return k == .poisson or k == .binomial or k == .inhomogeneous;
    }
};

/// A PROCESS IS ITS KIND AND FOUR NUMBERS, and what the four mean depends
/// on the kind. That is an unpleasant shape for a struct and the right one
/// for a bridge: the Ring face gives them names, so a caller never meets
/// `p.c` -- they meet RadiusKm. Anything richer would be a second place
/// where a process is defined.
pub const Process = struct {
    kind: Kind,
    /// intensity per km2, or a count, or the PARENT intensity
    a: f64 = 0,
    /// the mean number of children per parent
    b: f64 = 0,
    /// a length in km: a cluster radius, a Gaussian sigma, a hard-core distance
    c: f64 = 0,
    /// spare: the retention probability where one applies
    d: f64 = 1,
};

// ------------------------------------------------------------- the counts

/// A POISSON COUNT, by Knuth: multiply uniforms until the product drops
/// below exp(-lambda). Exact, and readable against the definition.
fn knuth(rnd: std.Random, lambda: f64) usize {
    const limit = @exp(-lambda);
    var k: usize = 0;
    var p: f64 = 1;
    while (true) {
        p *= rnd.float(f64);
        if (p <= limit) return k;
        k += 1;
        if (k > 1_000_000) return k; // a runaway is a bug, not a sample
    }
}

/// ...and the same for any rate, by splitting. Poisson(a) + Poisson(b) is
/// Poisson(a+b) when the two are independent -- the defining property of
/// the distribution -- so a rate too large for exp() to represent is drawn
/// as a sum of rates that are not.
pub fn poissonCount(rnd: std.Random, lambda: f64) usize {
    if (lambda <= 0) return 0;
    var left = lambda;
    var total: usize = 0;
    while (left > 500) {
        total += knuth(rnd, 500);
        left -= 500;
    }
    return total + knuth(rnd, left);
}

/// a standard normal, by Box-Muller -- two uniforms in, one normal out,
/// and the derivation is the polar form of the normal's own density
fn normal(rnd: std.Random) f64 {
    var ua = rnd.float(f64);
    if (ua < 1e-300) ua = 1e-300;
    const ub = rnd.float(f64);
    return @sqrt(-2 * @log(ua)) * @cos(2 * math.pi * ub);
}

/// WHERE YOU ARRIVE going km on a bearing, on the SPHERE. GE8's ellipsoid
/// is the right surface for a measurement; a simulation scattering children
/// round a parent at cluster scale does not need it, and asking for it
/// would put a geodesic solve inside the innermost loop of an envelope that
/// runs it a hundred thousand times. Stated here so the choice is a choice.
fn destination(lon: f64, lat: f64, bearing_deg: f64, km: f64) [2]f64 {
    const f1 = lat * DEG;
    const l1 = lon * DEG;
    const br = bearing_deg * DEG;
    const ad = km / EARTH_KM;
    const f2 = math.asin(@sin(f1) * @cos(ad) + @cos(f1) * @sin(ad) * @cos(br));
    const l2 = l1 + math.atan2(@sin(br) * @sin(ad) * @cos(f1), @cos(ad) - @sin(f1) * @sin(f2));
    return .{ l2 / DEG, f2 / DEG };
}

/// one uniform point in the window's bounding box, EQUAL-AREA on the
/// sphere: uniform in sin(latitude), not in latitude, or every simulation
/// would crowd the poles
fn boxPoint(w: *const gs.Window, rnd: std.Random) [2]f64 {
    const s0 = @sin(w.bbox[1] * DEG);
    const s1 = @sin(w.bbox[3] * DEG);
    const lon = w.bbox[0] + (w.bbox[2] - w.bbox[0]) * rnd.float(f64);
    const lat = math.asin(s0 + (s1 - s0) * rnd.float(f64)) / DEG;
    return .{ lon, lat };
}

// ------------------------------------------------------- the seven kinds

/// HOMOGENEOUS POISSON: the count is drawn, then the points are placed.
/// Returns how many landed in the window.
pub fn poisson(w: *const gs.Window, intensity_per_km2: f64, area_km2: f64, seed: u64, out: []f64) usize {
    var prng = std.Random.DefaultPrng.init(seed);
    const rnd = prng.random();
    const n = poissonCount(rnd, intensity_per_km2 * area_km2);
    return placeUniform(w, n, rnd, out);
}

/// BINOMIAL: the same placement with the count FIXED. It is the Poisson
/// conditioned on n, which is what GE7a's envelope has always simulated.
pub fn binomial(w: *const gs.Window, n: usize, seed: u64, out: []f64) usize {
    var prng = std.Random.DefaultPrng.init(seed);
    const rnd = prng.random();
    return placeUniform(w, n, rnd, out);
}

fn placeUniform(w: *const gs.Window, n: usize, rnd: std.Random, out: []f64) usize {
    const cap = out.len / 2;
    var placed: usize = 0;
    var tries: usize = 0;
    const budget: usize = n * 400 + 4000;
    while (placed < n and placed < cap and tries < budget) : (tries += 1) {
        const q = boxPoint(w, rnd);
        if (!w.contains(q[0], q[1])) continue;
        out[placed * 2] = q[0];
        out[placed * 2 + 1] = q[1];
        placed += 1;
    }
    return placed;
}

/// INHOMOGENEOUS POISSON, BY THINNING (Lewis and Shedler 1979). Generate a
/// homogeneous pattern at the HIGHEST intensity the surface reaches, then
/// keep each point with probability lambda(x)/lambda_max. What survives is
/// exactly a Poisson process with intensity lambda -- which is a result, not
/// an approximation, and it is why nobody needs to invert an intensity
/// surface to sample from it.
///
/// The surface arrives as a GRID, because a callback into the Ring VM is
/// not a thing this engine does. That is not a workaround: GE7b's kernel
/// density already PRODUCES such a grid, so the natural workflow -- estimate
/// an intensity from one pattern, then simulate from it as a null model --
/// is two calls with nothing in between.
pub fn inhomogeneous(w: *const gs.Window, g: gf.Grid, lambda: []const f64, area_km2: f64, seed: u64, out: []f64) usize {
    var prng = std.Random.DefaultPrng.init(seed);
    const rnd = prng.random();
    var lmax: f64 = 0;
    for (lambda) |v| {
        if (!math.isNan(v) and v > lmax) lmax = v;
    }
    if (lmax <= 0) return 0;
    const n = poissonCount(rnd, lmax * area_km2);
    const cap = out.len / 2;
    var placed: usize = 0;
    var made: usize = 0;
    var tries: usize = 0;
    const budget: usize = n * 400 + 4000;
    while (made < n and placed < cap and tries < budget) : (tries += 1) {
        const q = boxPoint(w, rnd);
        if (!w.contains(q[0], q[1])) continue;
        made += 1;
        const lam = bilinear(g, lambda, q[0], q[1]);
        if (math.isNan(lam) or lam <= 0) continue;
        if (rnd.float(f64) * lmax > lam) continue;
        out[placed * 2] = q[0];
        out[placed * 2 + 1] = q[1];
        placed += 1;
    }
    return placed;
}

/// the intensity at a place, interpolated between the four nodes around it.
/// NEAREST-NODE would put visible square steps into the simulated pattern
/// at the grid's own resolution -- an artefact of the sampling that a
/// reader would take for structure in the model.
fn bilinear(g: gf.Grid, v: []const f64, lon: f64, lat: f64) f64 {
    if (g.nx == 0 or g.ny == 0 or g.dlon == 0 or g.dlat == 0) return math.nan(f64);
    const fx = (lon - g.lon0) / g.dlon;
    const fy = (lat - g.lat0) / g.dlat;
    if (fx < 0 or fy < 0) return math.nan(f64);
    const ix: usize = @intFromFloat(@floor(fx));
    const jy: usize = @intFromFloat(@floor(fy));
    if (ix + 1 >= g.nx or jy + 1 >= g.ny) return math.nan(f64);
    const tx = fx - @floor(fx);
    const ty = fy - @floor(fy);
    const a = v[jy * g.nx + ix];
    const b = v[jy * g.nx + ix + 1];
    const c = v[(jy + 1) * g.nx + ix];
    const d = v[(jy + 1) * g.nx + ix + 1];
    if (math.isNan(a) or math.isNan(b) or math.isNan(c) or math.isNan(d)) return math.nan(f64);
    return a * (1 - tx) * (1 - ty) + b * tx * (1 - ty) + c * (1 - tx) * ty + d * tx * ty;
}

/// MATERN CLUSTER: parents from a Poisson process you never see, then a
/// Poisson number of children uniform in a disc around each.
///
/// BOTH COUNTS ARE POISSON, and GE7a's version had neither. It took a fixed
/// parent count and a fixed number of children each, which is a different
/// process with a different variance -- fine for DRAWING a clustered
/// picture, wrong as a null model, because the envelope it generates is too
/// narrow and rejects patterns it should not.
///
/// The parents are drawn in the BOUNDING BOX and not in the window: a
/// cluster whose centre falls just outside still throws children in, and
/// dropping those parents would leave the window's edge visibly emptier
/// than its middle. That is the same edge effect Ripley's K corrects for,
/// met on the generating side.
pub fn maternCluster(w: *const gs.Window, parent_per_km2: f64, mean_children: f64, radius_km: f64, box_area_km2: f64, seed: u64, out: []f64) usize {
    var prng = std.Random.DefaultPrng.init(seed ^ 0xA5A5A5A5);
    const rnd = prng.random();
    const np = poissonCount(rnd, parent_per_km2 * box_area_km2);
    const cap = out.len / 2;
    var placed: usize = 0;
    for (0..np) |_| {
        const p = boxPoint(w, rnd);
        const nc = poissonCount(rnd, mean_children);
        for (0..nc) |_| {
            if (placed >= cap) return placed;
            const r = radius_km * @sqrt(rnd.float(f64)); // uniform IN the disc
            const b = 360 * rnd.float(f64);
            const q = destination(p[0], p[1], b, r);
            if (!w.contains(q[0], q[1])) continue;
            out[placed * 2] = q[0];
            out[placed * 2 + 1] = q[1];
            placed += 1;
        }
    }
    return placed;
}

/// THOMAS: the same, with children scattered by a GAUSSIAN about the
/// parent instead of uniformly in a disc -- so a cluster has a scale but no
/// edge, and a few children land far out.
///
/// Choosing between this and Matern is a claim about the mechanism, not
/// about the picture: a disc says "there is a range beyond which nothing
/// goes", a Gaussian says "there is a typical distance and no hard limit".
/// Seeds from a tree are Thomas; territories within a fixed reach are
/// Matern.
pub fn thomas(w: *const gs.Window, parent_per_km2: f64, mean_children: f64, sigma_km: f64, box_area_km2: f64, seed: u64, out: []f64) usize {
    var prng = std.Random.DefaultPrng.init(seed ^ 0x7C0FFEE7);
    const rnd = prng.random();
    const np = poissonCount(rnd, parent_per_km2 * box_area_km2);
    const cap = out.len / 2;
    var placed: usize = 0;
    for (0..np) |_| {
        const p = boxPoint(w, rnd);
        const nc = poissonCount(rnd, mean_children);
        for (0..nc) |_| {
            if (placed >= cap) return placed;
            // two independent normals are an isotropic scatter, which is
            // what "a Gaussian cluster" means in two dimensions
            const dx = sigma_km * normal(rnd);
            const dy = sigma_km * normal(rnd);
            const r = @sqrt(dx * dx + dy * dy);
            const b = math.atan2(dx, dy) / DEG;
            const q = destination(p[0], p[1], b, r);
            if (!w.contains(q[0], q[1])) continue;
            out[placed * 2] = q[0];
            out[placed * 2 + 1] = q[1];
            placed += 1;
        }
    }
    return placed;
}

/// MATERN II: inhibition by DELETION. Propose a Poisson pattern, give each
/// point a birth time, and delete any point that has an OLDER point within
/// the hard-core distance. The survivors are what is left, not what was
/// packed in.
///
/// This is why it differs from SSI however similar the pictures look: the
/// deletion is applied to a pattern that already exists, so above a
/// proposal intensity of about 1/(pi r^2) the survivors stop increasing --
/// every additional proposed point deletes roughly as many as it adds.
/// Matern II has a CEILING and sequential inhibition does not.
pub fn maternII(alloc: std.mem.Allocator, w: *const gs.Window, intensity_per_km2: f64, min_km: f64, area_km2: f64, seed: u64, out: []f64) !usize {
    var prng = std.Random.DefaultPrng.init(seed ^ 0x2222AAAA);
    const rnd = prng.random();
    const n = poissonCount(rnd, intensity_per_km2 * area_km2);
    if (n == 0) return 0;
    const prop = try alloc.alloc(f64, n * 2);
    defer alloc.free(prop);
    const got = placeUniform(w, n, rnd, prop);
    if (got == 0) return 0;
    // the birth times; a point dies if an OLDER one is too close
    const age = try alloc.alloc(f64, got);
    defer alloc.free(age);
    for (0..got) |i| age[i] = rnd.float(f64);
    // THE SURVIVAL SCAN IS GRIDDED, because the proposal is the large set
    // and the survivors are not. At a proposal rate well above the ceiling
    // -- which is exactly where a caller goes to SEE the ceiling -- this
    // window takes a quarter of a million points, and comparing every pair
    // is thirty billion distances. Measured before the grid: 1.9 seconds
    // for one pattern, and the gate called it four times.
    //
    // A point can only be killed by one within min_km, so it only ever has
    // to look at the nine cells around it in a grid of that size. The cells
    // are in DEGREES and sized from the latitude the window sits at, since
    // a degree of longitude is not a degree of ground anywhere but the
    // equator -- getting that backwards would make the cells too narrow
    // near the poles and miss a neighbour.
    const lat_mid = (w.bbox[1] + w.bbox[3]) / 2;
    const km_per_deg_lat = EARTH_KM * DEG;
    const cos_lat = @max(0.01, @cos(lat_mid * DEG));
    const cell_lat = min_km / km_per_deg_lat;
    const cell_lon = min_km / (km_per_deg_lat * cos_lat);
    const nx: usize = @max(1, @min(2048, @as(usize, @intFromFloat(@ceil((w.bbox[2] - w.bbox[0]) / @max(1e-12, cell_lon)) + 1))));
    const ny: usize = @max(1, @min(2048, @as(usize, @intFromFloat(@ceil((w.bbox[3] - w.bbox[1]) / @max(1e-12, cell_lat)) + 1))));

    // the points of each cell, as a counted bucket list built in two passes
    const ncell = nx * ny;
    const head = try alloc.alloc(usize, ncell + 1);
    defer alloc.free(head);
    @memset(head, 0);
    const cell_of = try alloc.alloc(usize, got);
    defer alloc.free(cell_of);
    for (0..got) |i| {
        const cx: usize = @min(nx - 1, @as(usize, @intFromFloat(@max(0, (prop[i * 2] - w.bbox[0]) / @max(1e-12, cell_lon)))));
        const cy: usize = @min(ny - 1, @as(usize, @intFromFloat(@max(0, (prop[i * 2 + 1] - w.bbox[1]) / @max(1e-12, cell_lat)))));
        cell_of[i] = cy * nx + cx;
        head[cell_of[i] + 1] += 1;
    }
    for (1..ncell + 1) |c| head[c] += head[c - 1];
    const bucket = try alloc.alloc(usize, got);
    defer alloc.free(bucket);
    const fill = try alloc.alloc(usize, ncell);
    defer alloc.free(fill);
    @memset(fill, 0);
    for (0..got) |i| {
        const c = cell_of[i];
        bucket[head[c] + fill[c]] = i;
        fill[c] += 1;
    }

    const cap = out.len / 2;
    var placed: usize = 0;
    for (0..got) |i| {
        if (placed >= cap) break;
        const cx = cell_of[i] % nx;
        const cy = cell_of[i] / nx;
        var survives = true;
        var dy: i64 = -1;
        outer: while (dy <= 1) : (dy += 1) {
            const yy: i64 = @as(i64, @intCast(cy)) + dy;
            if (yy < 0 or yy >= @as(i64, @intCast(ny))) continue;
            var dx: i64 = -1;
            while (dx <= 1) : (dx += 1) {
                const xx: i64 = @as(i64, @intCast(cx)) + dx;
                if (xx < 0 or xx >= @as(i64, @intCast(nx))) continue;
                const c: usize = @intCast(yy * @as(i64, @intCast(nx)) + xx);
                for (bucket[head[c]..head[c + 1]]) |j| {
                    if (i == j) continue;
                    if (age[j] >= age[i]) continue; // younger or same: no claim
                    const d = gs.distanceKm(prop[i * 2], prop[i * 2 + 1], prop[j * 2], prop[j * 2 + 1]);
                    if (d < min_km) {
                        survives = false;
                        break :outer;
                    }
                }
            }
        }
        if (!survives) continue;
        out[placed * 2] = prop[i * 2];
        out[placed * 2 + 1] = prop[i * 2 + 1];
        placed += 1;
    }
    return placed;
}

/// SSI -- SIMPLE SEQUENTIAL INHIBITION: inhibition by REFUSAL. Propose
/// points one at a time and keep only those landing clear of everything
/// already kept. It PACKS, so it reaches densities Matern II cannot, and
/// its points are not a thinning of anything.
///
/// GE7a already had this, under the name hardCore, and it is delegated to
/// rather than rewritten -- one sequential inhibition in the library, and
/// its termination rule (twenty thousand refusals in a row is a full
/// window) was paid for once.
pub fn ssi(alloc: std.mem.Allocator, w: *const gs.Window, n: usize, min_km: f64, seed: u64, out: []f64) !usize {
    return gs.hardCore(alloc, w, n, min_km, seed, out);
}

/// INDEPENDENT THINNING of a pattern that already exists: keep each point
/// with probability p, deciding separately for each. It is the one
/// operation that turns an OBSERVED pattern into a null model -- a thinned
/// pattern has the same intensity surface and the same clustering, so
/// anything a statistic still sees in it is not caused by either.
pub fn thin(points: []const f64, p: f64, seed: u64, out: []f64) usize {
    var prng = std.Random.DefaultPrng.init(seed ^ 0x7417);
    const rnd = prng.random();
    const n = points.len / 2;
    const cap = out.len / 2;
    var placed: usize = 0;
    for (0..n) |i| {
        if (placed >= cap) break;
        if (rnd.float(f64) > p) continue;
        out[placed * 2] = points[i * 2];
        out[placed * 2 + 1] = points[i * 2 + 1];
        placed += 1;
    }
    return placed;
}

// --------------------------------------------------------- one entry point

/// GENERATE FROM A DECLARED PROCESS. The dispatch is here rather than in
/// the caller so that the envelope below and a caller drawing one pattern
/// take the SAME path -- otherwise the null model an envelope simulates and
/// the one a reader plots are two pieces of code that have to be kept in
/// step, which is the defect shape this plane has met repeatedly.
pub fn generate(alloc: std.mem.Allocator, w: *const gs.Window, pr: Process, g: gf.Grid, lambda: []const f64, area_km2: f64, box_area_km2: f64, seed: u64, out: []f64) !usize {
    return switch (pr.kind) {
        .poisson => poisson(w, pr.a, area_km2, seed, out),
        .binomial => binomial(w, @intFromFloat(@max(0, pr.a)), seed, out),
        .inhomogeneous => inhomogeneous(w, g, lambda, area_km2, seed, out),
        .matern_cluster => maternCluster(w, pr.a, pr.b, pr.c, box_area_km2, seed, out),
        .thomas => thomas(w, pr.a, pr.b, pr.c, box_area_km2, seed, out),
        .matern_ii => try maternII(alloc, w, pr.a, pr.c, area_km2, seed, out),
        .ssi => try ssi(alloc, w, @intFromFloat(@max(0, pr.a)), pr.c, seed, out),
    };
}

/// HOW MANY POINTS A PROCESS PRODUCES ON AVERAGE, which a caller needs in
/// order to compare an envelope with an observed pattern at all: an
/// envelope simulated at the wrong intensity is an envelope of the wrong
/// question.
pub fn expectedCount(pr: Process, lambda: []const f64, area_km2: f64, box_area_km2: f64) f64 {
    return switch (pr.kind) {
        .poisson => pr.a * area_km2,
        // AN INHOMOGENEOUS PROCESS'S RATE IS IN ITS SURFACE and nowhere
        // else, so its expected count is the surface's MEAN times the
        // area. Reading pr.a instead -- which is unset for this kind --
        // answered zero, and the envelope sized its buffer from that.
        .inhomogeneous => meanOf(lambda) * area_km2,
        // MATERN II DELETES, so its expected count is NOT its proposal
        // rate: the survivors of a hard-core deletion at distance r are
        // (1 - exp(-lambda pi r^2)) / (pi r^2) per km2, which saturates
        // however high lambda goes. Sizing a buffer from the proposal
        // would over-allocate by whatever factor the thinning removes.
        .matern_ii => maternIIIntensity(pr.a, pr.c) * area_km2,
        .binomial, .ssi => pr.a,
        .matern_cluster, .thomas => pr.a * box_area_km2 * pr.b * (area_km2 / box_area_km2),
    };
}

fn meanOf(v: []const f64) f64 {
    var sum: f64 = 0;
    var n: usize = 0;
    for (v) |x| {
        if (math.isNan(x)) continue;
        sum += x;
        n += 1;
    }
    if (n == 0) return 0;
    return sum / @as(f64, @floatFromInt(n));
}

/// THE CEILING OF MATERN II, per km2. A proposed point survives when no
/// older point lies within r, which happens with probability
/// (1 - exp(-lambda pi r^2)) / (lambda pi r^2) -- so the surviving
/// intensity is (1 - exp(-lambda pi r^2)) / (pi r^2) and tends to
/// 1/(pi r^2) however large lambda becomes. It is the closed form of the
/// saturation the probe measured: 0.02 per km2 proposed gives 157
/// survivors and 20 per km2 -- a thousand times as many -- gives 258.
pub fn maternIIIntensity(proposal: f64, r_km: f64) f64 {
    if (r_km <= 0) return proposal;
    const t = proposal * math.pi * r_km * r_km;
    if (t <= 0) return 0;
    return (1 - @exp(-t)) / (math.pi * r_km * r_km);
}

// ------------------------------------------------------------ the envelope

/// WHICH STATISTIC THE BAND IS DRAWN FOR. K grows like the area of a disc
/// and is hard to read by eye; L is its square root, which is a straight
/// line under randomness and is what anybody actually plots; G is the
/// distribution of nearest-neighbour distances, which answers a different
/// question -- K is about how many neighbours, G about how close the
/// closest one is.
pub const Stat = enum(u8) { k = 0, l = 1, g = 2 };

/// THE ENVELOPE OF ANY DECLARED PROCESS. `sims` patterns from the process,
/// the statistic of each at every radius, and per radius the minimum, the
/// maximum and the mean -- laid [lo, hi, mean] per radius, the same shape
/// GE7a's CSR envelope answers in.
///
/// THIRTY-NINE SIMULATIONS IS THE CLASSIC COUNT because the observed
/// statistic being the most extreme of forty is a one-in-forty event under
/// the null, which is 2.5% on each side. Asking for more is not free
/// precision: the band widens with the number of simulations, so an
/// envelope of 999 is a different and stricter test than an envelope of 39,
/// and the two are not comparable. The count belongs in the report.
pub fn envelope(alloc: std.mem.Allocator, w: *const gs.Window, pr: Process, g: gf.Grid, lambda: []const f64, area_km2: f64, box_area_km2: f64, radii: []const f64, sims: usize, seed: u64, stat: Stat, out: []f64) !usize {
    const room: usize = @intFromFloat(@max(64, expectedCount(pr, lambda, area_km2, box_area_km2) * 6 + 256));
    const pts = try alloc.alloc(f64, room * 2);
    defer alloc.free(pts);
    const v = try alloc.alloc(f64, radii.len);
    defer alloc.free(v);
    for (0..radii.len) |r| {
        out[r * 3] = math.inf(f64);
        out[r * 3 + 1] = -math.inf(f64);
        out[r * 3 + 2] = 0;
    }
    var done: usize = 0;
    for (0..sims) |s| {
        const got = try generate(alloc, w, pr, g, lambda, area_km2, box_area_km2,
            seed +% (s + 1) *% 0x9E3779B97F4A7C15, pts);
        if (got < 2) continue;
        const sample = pts[0 .. got * 2];
        switch (stat) {
            .k => try gs.ripleyK(alloc, sample, area_km2, radii, v),
            // L IS CENTRED -- sqrt(K/pi) MINUS r -- because that is what
            // GE7a's L() already answers, and a statistic must not mean two
            // things in one library. The first version returned the
            // uncentred form, so the observed value and the simulated band
            // were on different scales and a pattern fell outside its OWN
            // process's envelope 100 times out of 100. The self-consistency
            // check found it; nothing else would have, because both halves
            // looked entirely reasonable on their own.
            //
            // Centred is also the form worth having: it is zero under
            // randomness, so a reader sees the departure rather than
            // having to subtract a diagonal by eye.
            .l => {
                try gs.ripleyK(alloc, sample, area_km2, radii, v);
                for (0..radii.len) |r| v[r] = @sqrt(v[r] / math.pi) - radii[r];
            },
            // G IS TWO CALLS AND NOT ONE, and it is built here out of the
            // same pair GE7a's own G is built from rather than a third
            // copy: each point's nearest neighbour, then the fraction of
            // those distances at or under each radius.
            .g => {
                const nn = try alloc.alloc(f64, got);
                defer alloc.free(nn);
                try gs.nearestNeighbourKm(alloc, sample, nn);
                gs.cdfAt(nn, radii, v);
            },
        }
        done += 1;
        for (0..radii.len) |r| {
            if (v[r] < out[r * 3]) out[r * 3] = v[r];
            if (v[r] > out[r * 3 + 1]) out[r * 3 + 1] = v[r];
            out[r * 3 + 2] += v[r];
        }
    }
    if (done > 0) {
        const df: f64 = @floatFromInt(done);
        for (0..radii.len) |r| out[r * 3 + 2] /= df;
    } else {
        for (0..radii.len) |r| {
            out[r * 3] = 0;
            out[r * 3 + 1] = 0;
        }
    }
    return done;
}

/// WHERE AN OBSERVED PATTERN ESCAPES ITS ENVELOPE, and in which direction.
/// Answers, per radius: -1 below the band, 0 inside, +1 above. A reader
/// wants the RANGE OF SCALES at which a pattern is unusual, not a single
/// verdict -- a wood can be clustered at ten metres and regular at fifty,
/// and one p-value cannot say that.
pub fn escapes(observed: []const f64, env: []const f64, out: []f64) void {
    for (0..observed.len) |r| {
        if (observed[r] < env[r * 3]) {
            out[r] = -1;
        } else if (observed[r] > env[r * 3 + 1]) {
            out[r] = 1;
        } else {
            out[r] = 0;
        }
    }
}
