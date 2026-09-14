// GE7b -- A FIELD: A QUANTITY THAT HAS A VALUE EVERYWHERE.
//
// GE7a answered "are these places clustered", which is a question about a
// LIST. This file answers the other half of spatial analysis: rainfall,
// elevation, temperature, the smoothed intensity of an outbreak -- things
// that are not a list of places at all but a quantity defined over ground.
// Wolfram spends three of its twelve geo plot types on them
// (GeoSmoothHistogram, GeoContourPlot, GeoDensityPlot) and they are all
// the same substrate seen three ways: A GRID OF NUMBERS.
//
// So there is one type here and three things done to it.
//
// THE GRID IS NODE-CENTRED AND ROW 0 IS SOUTH. Value (i, j) is the value AT
// lon0 + i*dlon, lat0 + j*dlat -- a sample at a point, not an average over a
// box. Marching squares wants nodes, a projection wants nodes, and a reader
// that thinks in boxes converts once on the way in. ESRI's ASCII grid is
// cell-centred and its first data row is NORTH, so the reader here shifts by
// half a cell and flips; getting either wrong moves a whole map half a cell
// or turns it upside down, and both are the kind of error that looks
// plausible.
//
// FOUR DECISIONS:
//
//   1. DENSITY IS AN INTENSITY, NOT A PROBABILITY. The kernel estimate
//      answers PLACES PER SQUARE KILOMETRE, which is what a legend can
//      label and what can be compared between two maps. Dividing by n --
//      which is what a statistics library's density() does -- gives a
//      number that integrates to 1 and means nothing on a map.
//   2. THE KERNEL IS QUARTIC BY DEFAULT. It has compact support, so the
//      cost is points x cells-within-the-bandwidth and not points x cells,
//      and it is what every GIS calls "kernel density". Gaussian is offered
//      and truncated at four bandwidths, which holds 99.97% of its mass.
//   3. THE EDGE IS CORRECTED, OR SAID NOT TO BE. A kernel centred near the
//      window's border spills its mass outside, so the estimate there is
//      too low -- the same bias GE7a met in Clark-Evans. The correction
//      divides by the fraction of the kernel that lands INSIDE the window,
//      integrated over the grid itself (Diggle's). It costs one more pass
//      and it is off by default only because a caller drawing a raster of
//      elevation has no window at all.
//   4. A CELL'S AREA IS NOT A CONSTANT. It is R^2 dlon dlat cos(lat), so it
//      shrinks toward the poles. Every integral here weighs by it. A field
//      summed as if cells were equal is the same lie as a choropleth on a
//      Mercator.

const std = @import("std");
const gp = @import("geo_projection.zig");
const gs = @import("geo_stats.zig");

const DEG: f64 = std.math.pi / 180.0;
const EARTH_KM: f64 = 6371.0088;

pub const Kernel = enum(u8) { quartic = 0, gaussian = 1 };

/// A regular lon/lat lattice. Values are stored row-major with row 0 SOUTH,
/// so `values[j * nx + i]` is the value at (lon0 + i*dlon, lat0 + j*dlat).
/// A value that is not known is NaN, never a sentinel number: -9999 read as
/// a depth is how a nodata cell becomes the deepest trench on the map.
pub const Grid = struct {
    lon0: f64,
    lat0: f64,
    dlon: f64,
    dlat: f64,
    nx: usize,
    ny: usize,

    pub fn count(self: Grid) usize {
        return self.nx * self.ny;
    }

    pub fn lonAt(self: Grid, i: usize) f64 {
        return self.lon0 + @as(f64, @floatFromInt(i)) * self.dlon;
    }

    pub fn latAt(self: Grid, j: usize) f64 {
        return self.lat0 + @as(f64, @floatFromInt(j)) * self.dlat;
    }

    /// the ground a node stands for, km2 -- the cell around it
    pub fn cellAreaKm2(self: Grid, j: usize) f64 {
        const lat = self.latAt(j);
        return EARTH_KM * EARTH_KM * (self.dlon * DEG) * (self.dlat * DEG) * @cos(lat * DEG);
    }
};

/// A GRID THAT COVERS THIS GROUND WITH ROUGHLY SQUARE CELLS. Longitude is
/// stretched by 1/cos(lat) at the middle of the box, so a 5 km cell is 5 km
/// both ways where the map actually is -- which is what a bandwidth in
/// kilometres assumes when it decides how many cells to reach.
pub fn gridOver(bbox: [4]f64, cell_km: f64) Grid {
    const lat_mid = (bbox[1] + bbox[3]) / 2;
    const dlat = (cell_km / EARTH_KM) / DEG;
    var c = @cos(lat_mid * DEG);
    if (c < 0.05) c = 0.05;
    const dlon = dlat / c;
    var nx: usize = @intFromFloat(@floor((bbox[2] - bbox[0]) / dlon) + 1);
    var ny: usize = @intFromFloat(@floor((bbox[3] - bbox[1]) / dlat) + 1);
    if (nx < 2) nx = 2;
    if (ny < 2) ny = 2;
    return .{ .lon0 = bbox[0], .lat0 = bbox[1], .dlon = dlon, .dlat = dlat, .nx = nx, .ny = ny };
}

// --------------------------------------------------------------- the mask

/// which nodes stand on the window. Used to clip a density to the ground it
/// was observed on, and to integrate the edge correction.
pub fn maskInside(g: Grid, w: *const gs.Window, out: []bool) void {
    for (0..g.ny) |j| {
        const lat = g.latAt(j);
        for (0..g.nx) |i| out[j * g.nx + i] = w.contains(g.lonAt(i), lat);
    }
}

// ------------------------------------------------------- kernel density

fn kernelAt(k: Kernel, u: f64) f64 {
    return switch (k) {
        // quartic (biweight): integrates to 1 over the unit disk
        .quartic => if (u >= 1) 0 else (3.0 / std.math.pi) * (1 - u * u) * (1 - u * u),
        .gaussian => if (u >= 4) 0 else (1.0 / (2 * std.math.pi)) * @exp(-0.5 * u * u),
    };
}

fn kernelReach(k: Kernel) f64 {
    return switch (k) {
        .quartic => 1,
        .gaussian => 4,
    };
}

/// THE SMOOTHED INTENSITY OF A POINT PATTERN, in points per km2.
///
/// Each point spreads `1/h^2 K(d/h)` over the ground around it; the field is
/// the sum. Only cells within the kernel's reach of a point are touched, so
/// the cost is points x cells-in-reach.
///
/// `mask` (optional) is what the estimate is clipped to: a node outside it
/// comes back NaN rather than zero, because "no ground here" and "no places
/// here" are different statements and a legend must not merge them.
///
/// `edge_correct` divides each node by the fraction of its kernel that lands
/// inside the mask, which needs the mask and is ignored without one.
pub fn kernelDensity(
    alloc: std.mem.Allocator,
    lonlat: []const f64,
    g: Grid,
    bandwidth_km: f64,
    kind: Kernel,
    mask: ?[]const bool,
    edge_correct: bool,
    out: []f64,
) !void {
    @memset(out, 0);
    if (bandwidth_km <= 0) return;
    const reach_km = bandwidth_km * kernelReach(kind);
    const inv_h2 = 1 / (bandwidth_km * bandwidth_km);
    const n = lonlat.len / 2;

    // how many cells a reach spans, at the worst (highest) latitude here
    const dlat_km = g.dlat * DEG * EARTH_KM;
    const jr: usize = @intFromFloat(@ceil(reach_km / dlat_km) + 1);

    for (0..n) |p| {
        const plon = lonlat[p * 2];
        const plat = lonlat[p * 2 + 1];
        const jc_f = (plat - g.lat0) / g.dlat;
        if (jc_f < -@as(f64, @floatFromInt(jr)) or jc_f > @as(f64, @floatFromInt(g.ny + jr))) continue;
        const jc: i64 = @intFromFloat(@round(jc_f));
        var j: i64 = jc - @as(i64, @intCast(jr));
        while (j <= jc + @as(i64, @intCast(jr))) : (j += 1) {
            if (j < 0 or j >= @as(i64, @intCast(g.ny))) continue;
            const ju: usize = @intCast(j);
            const lat = g.latAt(ju);
            // longitude reach widens as cos(lat) shrinks
            var c = @cos(lat * DEG);
            if (c < 0.01) c = 0.01;
            const dlon_km = g.dlon * DEG * EARTH_KM * c;
            const ir: usize = @intFromFloat(@ceil(reach_km / dlon_km) + 1);
            const ic: i64 = @intFromFloat(@round((plon - g.lon0) / g.dlon));
            var i: i64 = ic - @as(i64, @intCast(ir));
            while (i <= ic + @as(i64, @intCast(ir))) : (i += 1) {
                if (i < 0 or i >= @as(i64, @intCast(g.nx))) continue;
                const iu: usize = @intCast(i);
                const d = gs.distanceKm(g.lonAt(iu), lat, plon, plat);
                if (d > reach_km) continue;
                out[ju * g.nx + iu] += inv_h2 * kernelAt(kind, d / bandwidth_km);
            }
        }
    }

    const m = mask orelse return;

    if (edge_correct) {
        // DIGGLE'S CORRECTION: divide by the kernel mass that landed inside
        // the window. Integrated over the grid itself rather than by a
        // formula, so it is right for a ragged coast and not only for a
        // rectangle. A node whose whole kernel is inside divides by ~1.
        // Right to about HALF A CELL at the border: a node on the boundary
        // is weighed as a whole cell though half of it lies outside, so the
        // corrected border sits a few per cent under the truth at 20 km
        // cells. A finer cell is the cure, and it costs what it costs.
        const corr = try alloc.alloc(f64, g.count());
        defer alloc.free(corr);
        @memset(corr, 0);
        for (0..g.ny) |j| {
            const lat = g.latAt(j);
            var c = @cos(lat * DEG);
            if (c < 0.01) c = 0.01;
            const dlon_km = g.dlon * DEG * EARTH_KM * c;
            const ir: usize = @intFromFloat(@ceil(reach_km / dlon_km) + 1);
            for (0..g.nx) |i| {
                if (!m[j * g.nx + i]) continue;
                const lon = g.lonAt(i);
                var acc: f64 = 0;
                var jj: i64 = @as(i64, @intCast(j)) - @as(i64, @intCast(jr));
                while (jj <= @as(i64, @intCast(j)) + @as(i64, @intCast(jr))) : (jj += 1) {
                    if (jj < 0 or jj >= @as(i64, @intCast(g.ny))) continue;
                    const jv: usize = @intCast(jj);
                    const lat2 = g.latAt(jv);
                    const area = g.cellAreaKm2(jv);
                    var ii: i64 = @as(i64, @intCast(i)) - @as(i64, @intCast(ir));
                    while (ii <= @as(i64, @intCast(i)) + @as(i64, @intCast(ir))) : (ii += 1) {
                        if (ii < 0 or ii >= @as(i64, @intCast(g.nx))) continue;
                        const iv: usize = @intCast(ii);
                        if (!m[jv * g.nx + iv]) continue;
                        const dd = gs.distanceKm(lon, lat, g.lonAt(iv), lat2);
                        if (dd > reach_km) continue;
                        acc += inv_h2 * kernelAt(kind, dd / bandwidth_km) * area;
                    }
                }
                corr[j * g.nx + i] = acc;
            }
        }
        for (0..g.count()) |k| {
            if (!m[k]) continue;
            if (corr[k] > 0.02) out[k] /= corr[k];
        }
    }

    // clipped LAST, so a corrected node is not divided by a mask it left
    for (0..g.count()) |k| {
        if (!m[k]) out[k] = std.math.nan(f64);
    }
}

// ------------------------------------------------------- reading a field

pub const Stats = struct { min: f64, max: f64, known: usize, unknown: usize };

pub fn stats(values: []const f64) Stats {
    var s = Stats{ .min = std.math.inf(f64), .max = -std.math.inf(f64), .known = 0, .unknown = 0 };
    for (values) |v| {
        if (std.math.isNan(v)) {
            s.unknown += 1;
            continue;
        }
        s.known += 1;
        if (v < s.min) s.min = v;
        if (v > s.max) s.max = v;
    }
    if (s.known == 0) {
        s.min = 0;
        s.max = 0;
    }
    return s;
}

/// bilinear where all four neighbours are known, nearest where they are not,
/// NaN off the grid or with no known neighbour at all
pub fn sampleAt(values: []const f64, g: Grid, lon: f64, lat: f64) f64 {
    const fx = (lon - g.lon0) / g.dlon;
    const fy = (lat - g.lat0) / g.dlat;
    // STRICTLY INSIDE THE GRID. The first version allowed half a cell of
    // overhang and answered with the edge node there, which painted a band
    // of colour along the western edge of a map where the grid's own border
    // ran down the coast -- ground the field does not cover, drawn as
    // though it did. A hairline of unpainted data at the very edge is the
    // honest trade.
    if (fx < 0 or fy < 0) return std.math.nan(f64);
    if (fx > @as(f64, @floatFromInt(g.nx - 1)) or fy > @as(f64, @floatFromInt(g.ny - 1))) return std.math.nan(f64);
    // i0/j0 would shadow Zig's i0 primitive
    var ci: i64 = @intFromFloat(@floor(fx));
    var cj: i64 = @intFromFloat(@floor(fy));
    if (ci < 0) ci = 0;
    if (cj < 0) cj = 0;
    if (ci > @as(i64, @intCast(g.nx)) - 2) ci = @as(i64, @intCast(g.nx)) - 2;
    if (cj > @as(i64, @intCast(g.ny)) - 2) cj = @as(i64, @intCast(g.ny)) - 2;
    const iu: usize = @intCast(ci);
    const ju: usize = @intCast(cj);
    const a = values[ju * g.nx + iu];
    const b = values[ju * g.nx + iu + 1];
    const c = values[(ju + 1) * g.nx + iu];
    const d = values[(ju + 1) * g.nx + iu + 1];
    const tx = fx - @as(f64, @floatFromInt(iu));
    const ty = fy - @as(f64, @floatFromInt(ju));
    if (!std.math.isNan(a) and !std.math.isNan(b) and !std.math.isNan(c) and !std.math.isNan(d)) {
        return (a * (1 - tx) + b * tx) * (1 - ty) + (c * (1 - tx) + d * tx) * ty;
    }
    // nearest of the four that is known
    const ni: usize = if (tx < 0.5) iu else iu + 1;
    const nj: usize = if (ty < 0.5) ju else ju + 1;
    return values[nj * g.nx + ni];
}

// --------------------------------------------------------- the raster

/// WHICH CLASS A VALUE FALLS IN, 1-based, or 0 for none. Edges ascend and
/// the last one is closed, so the maximum of a field is in the top class
/// and not outside the legend -- which is how the highest peak on a relief
/// map comes out as "no data".
pub fn classOf(v: f64, edges: []const f64) usize {
    if (std.math.isNan(v) or edges.len < 2) return 0;
    if (v < edges[0]) return 0;
    for (1..edges.len) |k| {
        if (v <= edges[k]) return k;
    }
    return 0;
}

/// THE FIELD AS A PICTURE, RESAMPLED THROUGH THE PROJECTION.
///
/// One RGBA buffer the size of the box on the paper: for every pixel, invert
/// to a place, read the field there, and take the class's colour. Drawing
/// the grid's cells as quads instead would be forty thousand polygons that
/// are the wrong shape anyway -- a lon/lat cell is not a rectangle once a
/// conic has had it -- and would need the caller to do the projection's job.
/// Inverting per pixel is how every GIS draws a raster under a projection.
///
/// `palette` is 3 bytes per class; a pixel with no class, no inverse, or no
/// value is left fully transparent, so the map beneath shows through.
pub fn fieldImage(
    values: []const f64,
    g: Grid,
    p: *const gp.Projection,
    x0: f64,
    y0: f64,
    w: usize,
    h: usize,
    edges: []const f64,
    palette: []const u8,
    alpha: u8,
    out: []u8,
) void {
    @memset(out, 0);
    const classes = if (edges.len >= 2) edges.len - 1 else 0;
    for (0..h) |py| {
        const y = y0 + @as(f64, @floatFromInt(py)) + 0.5;
        for (0..w) |px| {
            const x = x0 + @as(f64, @floatFromInt(px)) + 0.5;
            const gpos = gp.invert(p, x, y) orelse continue;
            const v = sampleAt(values, g, gpos[0], gpos[1]);
            const c = classOf(v, edges);
            if (c == 0 or c > classes) continue;
            const o = (py * w + px) * 4;
            out[o] = palette[(c - 1) * 3];
            out[o + 1] = palette[(c - 1) * 3 + 1];
            out[o + 2] = palette[(c - 1) * 3 + 2];
            out[o + 3] = alpha;
        }
    }
}

// ----------------------------------------------------- marching squares

/// where a contour crosses the segment between two values
fn cross(va: f64, vb: f64, level: f64) f64 {
    const d = vb - va;
    if (@abs(d) < 1e-300) return 0.5;
    const t = (level - va) / d;
    if (t < 0) return 0;
    if (t > 1) return 1;
    return t;
}

/// THE CONTOUR AT ONE LEVEL, as joined lon/lat polylines.
///
/// Marching squares over every 2x2 of nodes: sixteen cases, the two
/// ambiguous ones (opposite corners above, the other two below) resolved by
/// the CENTRE VALUE -- the average of the four -- which is the standard
/// disambiguation and the one that keeps a ridge from being cut in half.
///
/// Segments are indexed BY THE EDGE THEY CROSS, not by their coordinates, so
/// joining them into lines is exact rather than a tolerance on floating
/// point: two segments meet when they name the same edge. A cell has at most
/// one crossing per edge, which is what makes the index a key.
///
/// A cell with ANY unknown corner is skipped: a contour drawn across nodata
/// is a line through ground nobody measured.
pub fn contour(
    alloc: std.mem.Allocator,
    values: []const f64,
    g: Grid,
    level: f64,
    out: *gp.Pieces,
) !void {
    if (g.nx < 2 or g.ny < 2) return;
    const nh = (g.nx - 1) * g.ny; // horizontal edges
    const nv = g.nx * (g.ny - 1); // vertical edges
    const total = nh + nv;

    // where each edge is crossed, in grid coordinates
    const ex = try alloc.alloc(f64, total);
    defer alloc.free(ex);
    const ey = try alloc.alloc(f64, total);
    defer alloc.free(ey);
    // up to two segment ends meet at an edge
    const link = try alloc.alloc(i32, total * 2);
    defer alloc.free(link);
    @memset(link, -1);

    var segs = std.ArrayList([2]usize){};
    defer segs.deinit(alloc);

    const hid = struct {
        fn f(gg: Grid, i: usize, j: usize) usize {
            return j * (gg.nx - 1) + i;
        }
    }.f;
    const vid = struct {
        fn f(gg: Grid, i: usize, j: usize, base: usize) usize {
            return base + j * gg.nx + i;
        }
    }.f;

    for (0..g.ny - 1) |j| {
        for (0..g.nx - 1) |i| {
            const v00 = values[j * g.nx + i];
            const v10 = values[j * g.nx + i + 1];
            const v01 = values[(j + 1) * g.nx + i];
            const v11 = values[(j + 1) * g.nx + i + 1];
            if (std.math.isNan(v00) or std.math.isNan(v10) or
                std.math.isNan(v01) or std.math.isNan(v11)) continue;

            var code: u4 = 0;
            if (v00 >= level) code |= 1;
            if (v10 >= level) code |= 2;
            if (v11 >= level) code |= 4;
            if (v01 >= level) code |= 8;
            if (code == 0 or code == 15) continue;

            const fi: f64 = @floatFromInt(i);
            const fj: f64 = @floatFromInt(j);
            const eB = hid(g, i, j); // bottom
            const eT = hid(g, i, j + 1); // top
            const eL = vid(g, i, j, nh); // left
            const eR = vid(g, i + 1, j, nh); // right
            ex[eB] = fi + cross(v00, v10, level);
            ey[eB] = fj;
            ex[eT] = fi + cross(v01, v11, level);
            ey[eT] = fj + 1;
            ex[eL] = fi;
            ey[eL] = fj + cross(v00, v01, level);
            ex[eR] = fi + 1;
            ey[eR] = fj + cross(v10, v11, level);

            var pairs: [2][2]usize = undefined;
            var np: usize = 0;
            switch (code) {
                1, 14 => {
                    pairs[0] = .{ eL, eB };
                    np = 1;
                },
                2, 13 => {
                    pairs[0] = .{ eB, eR };
                    np = 1;
                },
                3, 12 => {
                    pairs[0] = .{ eL, eR };
                    np = 1;
                },
                4, 11 => {
                    pairs[0] = .{ eR, eT };
                    np = 1;
                },
                6, 9 => {
                    pairs[0] = .{ eB, eT };
                    np = 1;
                },
                7, 8 => {
                    pairs[0] = .{ eL, eT };
                    np = 1;
                },
                5, 10 => {
                    // THE SADDLE. The centre decides which way the two lines
                    // bend; without it the choice is arbitrary and a ridge
                    // comes out cut in half.
                    const centre = (v00 + v10 + v01 + v11) / 4;
                    const joined = (centre >= level) == (code == 5);
                    if (joined) {
                        pairs[0] = .{ eL, eT };
                        pairs[1] = .{ eB, eR };
                    } else {
                        pairs[0] = .{ eL, eB };
                        pairs[1] = .{ eR, eT };
                    }
                    np = 2;
                },
                else => np = 0,
            }
            for (0..np) |k| {
                const idx: i32 = @intCast(segs.items.len);
                try segs.append(alloc, pairs[k]);
                for (pairs[k]) |e| {
                    if (link[e * 2] < 0) link[e * 2] = idx else if (link[e * 2 + 1] < 0) link[e * 2 + 1] = idx;
                }
            }
        }
    }
    if (segs.items.len == 0) return;

    // --- join the segments into chains ---------------------------------
    const used = try alloc.alloc(bool, segs.items.len);
    defer alloc.free(used);
    @memset(used, false);

    const other = struct {
        fn f(sg: [2]usize, e: usize) usize {
            return if (sg[0] == e) sg[1] else sg[0];
        }
    }.f;
    const nextSeg = struct {
        fn f(lk: []const i32, e: usize, from: usize) ?usize {
            const a = lk[e * 2];
            const b = lk[e * 2 + 1];
            if (a >= 0 and @as(usize, @intCast(a)) != from) return @intCast(a);
            if (b >= 0 and @as(usize, @intCast(b)) != from) return @intCast(b);
            return null;
        }
    }.f;

    var chain = std.ArrayList(usize){};
    defer chain.deinit(alloc);

    // open chains first (an edge touched by exactly one segment is an end),
    // then whatever is left, which is closed loops
    for (0..2) |pass| {
        for (0..segs.items.len) |s0| {
            if (used[s0]) continue;
            var start_edge: usize = segs.items[s0][0];
            if (pass == 0) {
                // only start where a line actually ends
                const e0 = segs.items[s0][0];
                const e1 = segs.items[s0][1];
                if (link[e0 * 2 + 1] < 0) {
                    start_edge = e0;
                } else if (link[e1 * 2 + 1] < 0) {
                    start_edge = e1;
                } else continue;
            }
            chain.clearRetainingCapacity();
            try chain.append(alloc, start_edge);
            var cur: usize = s0;
            var e: usize = start_edge;
            while (true) {
                used[cur] = true;
                e = other(segs.items[cur], e);
                try chain.append(alloc, e);
                const nx = nextSeg(link, e, cur) orelse break;
                if (used[nx]) break;
                cur = nx;
            }
            if (chain.items.len < 2) continue;
            try out.begin();
            for (chain.items) |ee| {
                try out.point(.{ g.lon0 + ex[ee] * g.dlon, g.lat0 + ey[ee] * g.dlat });
            }
        }
    }
}

// -------------------------------------------------- ESRI ASCII grid

pub const AsciiGrid = struct { g: Grid, values: []f64 };

fn nextToken(text: []const u8, at: *usize) ?[]const u8 {
    var i = at.*;
    while (i < text.len and (text[i] == ' ' or text[i] == '\t' or text[i] == '\r' or text[i] == '\n')) i += 1;
    if (i >= text.len) return null;
    const s = i;
    while (i < text.len and text[i] != ' ' and text[i] != '\t' and text[i] != '\r' and text[i] != '\n') i += 1;
    at.* = i;
    return text[s..i];
}

fn eqIgnoreCase(a: []const u8, b: []const u8) bool {
    if (a.len != b.len) return false;
    for (a, b) |x, y| {
        if (std.ascii.toLower(x) != std.ascii.toLower(y)) return false;
    }
    return true;
}

/// THE FORMAT EVERY GIS CAN WRITE, and the two traps in it.
///
/// Header: ncols, nrows, then either xllcorner/yllcorner (the CORNER of the
/// bottom-left cell) or xllcenter/yllcenter (its centre), then cellsize and
/// an optional NODATA_value. Data follows row by row, and THE FIRST ROW IS
/// THE NORTHERNMOST -- the opposite of this file's own order, so it is
/// flipped here rather than left for a caller to discover from an upside-down
/// map.
///
/// NODATA becomes NaN. It is usually -9999, and read as a number it is the
/// deepest trench on every elevation map that ever forgot.
pub fn readAsciiGrid(alloc: std.mem.Allocator, text: []const u8) !AsciiGrid {
    var at: usize = 0;
    var ncols: usize = 0;
    var nrows: usize = 0;
    var xll: f64 = 0;
    var yll: f64 = 0;
    var cell: f64 = 0;
    var nodata: f64 = -9999;
    var centred = false;
    var seen: u8 = 0;

    // THE HEADER ENDS WHERE THE DATA BEGINS, not when a count is reached.
    // The first version stopped after the five required keys, and
    // NODATA_value -- which is optional and comes last -- was then read as
    // the first two numbers of the grid.
    while (true) {
        const save = at;
        const key = nextToken(text, &at) orelse return error.BadHeader;
        if (key.len == 0 or (key[0] >= '0' and key[0] <= '9') or key[0] == '-' or key[0] == '.') {
            at = save;
            break;
        }
        const val = nextToken(text, &at) orelse return error.BadHeader;
        if (eqIgnoreCase(key, "ncols")) {
            ncols = std.fmt.parseInt(usize, val, 10) catch return error.BadHeader;
            seen += 1;
        } else if (eqIgnoreCase(key, "nrows")) {
            nrows = std.fmt.parseInt(usize, val, 10) catch return error.BadHeader;
            seen += 1;
        } else if (eqIgnoreCase(key, "xllcorner") or eqIgnoreCase(key, "xllcenter") or eqIgnoreCase(key, "xllcentre")) {
            xll = std.fmt.parseFloat(f64, val) catch return error.BadHeader;
            centred = !eqIgnoreCase(key, "xllcorner");
            seen += 1;
        } else if (eqIgnoreCase(key, "yllcorner") or eqIgnoreCase(key, "yllcenter") or eqIgnoreCase(key, "yllcentre")) {
            yll = std.fmt.parseFloat(f64, val) catch return error.BadHeader;
            seen += 1;
        } else if (eqIgnoreCase(key, "cellsize")) {
            cell = std.fmt.parseFloat(f64, val) catch return error.BadHeader;
            seen += 1;
        } else if (eqIgnoreCase(key, "nodata_value")) {
            nodata = std.fmt.parseFloat(f64, val) catch return error.BadHeader;
        } else {
            return error.BadHeader;
        }
    }
    if (seen < 5 or ncols < 2 or nrows < 2 or cell <= 0) return error.BadHeader;

    const values = try alloc.alloc(f64, ncols * nrows);
    errdefer alloc.free(values);
    @memset(values, std.math.nan(f64));

    // the file runs north to south; this grid runs south to north
    var row: usize = 0;
    while (row < nrows) : (row += 1) {
        const j = nrows - 1 - row;
        var col: usize = 0;
        while (col < ncols) : (col += 1) {
            const tok = nextToken(text, &at) orelse return error.ShortData;
            const v = std.fmt.parseFloat(f64, tok) catch return error.BadNumber;
            values[j * ncols + col] = if (v == nodata) std.math.nan(f64) else v;
        }
    }
    const half: f64 = if (centred) 0 else cell / 2;
    return .{
        .g = .{
            .lon0 = xll + half,
            .lat0 = yll + half,
            .dlon = cell,
            .dlat = cell,
            .nx = ncols,
            .ny = nrows,
        },
        .values = values,
    };
}

// ------------------------------------------------------------------ tests

const testing = std.testing;
const ta = testing.allocator;

test "a grid over a box has roughly square cells where the map is" {
    const g = gridOver(.{ 8, 30, 12, 38 }, 20);
    const lat_mid = 34.0;
    const dlat_km = g.dlat * DEG * EARTH_KM;
    const dlon_km = g.dlon * DEG * EARTH_KM * @cos(lat_mid * DEG);
    try testing.expect(@abs(dlat_km - 20) < 0.01);
    try testing.expect(@abs(dlon_km - 20) < 0.2);
    try testing.expect(g.nx > 10 and g.ny > 10);
}

test "a cell's area shrinks toward the poles" {
    const g = Grid{ .lon0 = 0, .lat0 = 0, .dlon = 1, .dlat = 1, .nx = 3, .ny = 91 };
    const eq = g.cellAreaKm2(0);
    const sixty = g.cellAreaKm2(60);
    try testing.expect(@abs(sixty / eq - 0.5) < 0.01);
}

test "a kernel density integrates to the number of points it was given" {
    // one point in the middle of a wide grid: summing intensity x area
    // must recover 1, which is what makes the units points per km2
    const g = gridOver(.{ -2, -2, 2, 2 }, 8);
    const vals = try ta.alloc(f64, g.count());
    defer ta.free(vals);
    try kernelDensity(ta, &.{ 0, 0 }, g, 60, .quartic, null, false, vals);
    var total: f64 = 0;
    for (0..g.ny) |j| {
        const a = g.cellAreaKm2(j);
        for (0..g.nx) |i| total += vals[j * g.nx + i] * a;
    }
    try testing.expect(@abs(total - 1) < 0.02);

    // and the gaussian, truncated at four bandwidths, keeps nearly all of it
    try kernelDensity(ta, &.{ 0, 0 }, g, 40, .gaussian, null, false, vals);
    total = 0;
    for (0..g.ny) |j| {
        const a = g.cellAreaKm2(j);
        for (0..g.nx) |i| total += vals[j * g.nx + i] * a;
    }
    try testing.expect(@abs(total - 1) < 0.02);
}

test "the density is highest where the points are, and zero beyond the reach" {
    const g = gridOver(.{ 0, 0, 4, 4 }, 10);
    const vals = try ta.alloc(f64, g.count());
    defer ta.free(vals);
    try kernelDensity(ta, &.{ 1, 1, 1.05, 1.02, 0.98, 0.99 }, g, 30, .quartic, null, false, vals);
    const near = sampleAt(vals, g, 1, 1);
    const far = sampleAt(vals, g, 3.5, 3.5);
    try testing.expect(near > 0);
    try testing.expect(far == 0);
}

test "the edge correction lifts the border and leaves the middle alone" {
    const ring = [_]f64{ 0, 0, 4, 0, 4, 4, 0, 4, 0, 0 };
    const rs = [_][]const f64{&ring};
    const w = gs.Window{ .rings = &rs, .bbox = .{ 0, 0, 4, 4 } };
    const g = gridOver(.{ 0, 0, 4, 4 }, 15);
    const mask = try ta.alloc(bool, g.count());
    defer ta.free(mask);
    maskInside(g, &w, mask);

    const pts = try ta.alloc(f64, 600 * 2);
    defer ta.free(pts);
    const got = gs.sampleInside(&w, 600, 5, pts);

    const plain = try ta.alloc(f64, g.count());
    defer ta.free(plain);
    const fixed = try ta.alloc(f64, g.count());
    defer ta.free(fixed);
    try kernelDensity(ta, pts[0 .. got * 2], g, 60, .quartic, mask, false, plain);
    try kernelDensity(ta, pts[0 .. got * 2], g, 60, .quartic, mask, true, fixed);

    // a corner is short of density without the correction and closer with it
    const c_plain = sampleAt(plain, g, 0.15, 0.15);
    const c_fixed = sampleAt(fixed, g, 0.15, 0.15);
    const m_plain = sampleAt(plain, g, 2, 2);
    const m_fixed = sampleAt(fixed, g, 2, 2);
    try testing.expect(c_fixed > c_plain * 1.5);
    try testing.expect(@abs(m_fixed / m_plain - 1) < 0.15);
    // and the middle is nearer the true intensity than the corner was
    try testing.expect(c_fixed / m_fixed > c_plain / m_plain);
}

test "a masked node is unknown, never zero" {
    const ring = [_]f64{ 0, 0, 2, 0, 2, 2, 0, 2, 0, 0 };
    const rs = [_][]const f64{&ring};
    const w = gs.Window{ .rings = &rs, .bbox = .{ -2, -2, 4, 4 } };
    const g = gridOver(.{ -2, -2, 4, 4 }, 25);
    const mask = try ta.alloc(bool, g.count());
    defer ta.free(mask);
    maskInside(g, &w, mask);
    const vals = try ta.alloc(f64, g.count());
    defer ta.free(vals);
    try kernelDensity(ta, &.{ 1, 1 }, g, 80, .quartic, mask, false, vals);
    try testing.expect(std.math.isNan(sampleAt(vals, g, 3.5, 3.5)));
    try testing.expect(sampleAt(vals, g, 1, 1) > 0);
    const s = stats(vals);
    try testing.expect(s.unknown > 0 and s.known > 0);
}

test "a contour of a cone is a circle, closed, at the radius the level names" {
    // v = 100 - r, so the level 60 is the circle r = 40 in grid units
    const g = Grid{ .lon0 = -50, .lat0 = -50, .dlon = 1, .dlat = 1, .nx = 101, .ny = 101 };
    const vals = try ta.alloc(f64, g.count());
    defer ta.free(vals);
    for (0..g.ny) |j| {
        for (0..g.nx) |i| {
            const dx = @as(f64, @floatFromInt(i)) - 50;
            const dy = @as(f64, @floatFromInt(j)) - 50;
            vals[j * g.nx + i] = 100 - @sqrt(dx * dx + dy * dy);
        }
    }
    var pieces = gp.Pieces{};
    defer pieces.deinit();
    try contour(ta, vals, g, 60, &pieces);
    try testing.expect(pieces.starts.items.len == 1);
    const n = pieces.xy.items.len / 2;
    try testing.expect(n > 100);
    // every point is 40 from the centre, and the ring closes
    for (0..n) |k| {
        const r = @sqrt(pieces.xy.items[k * 2] * pieces.xy.items[k * 2] +
            pieces.xy.items[k * 2 + 1] * pieces.xy.items[k * 2 + 1]);
        try testing.expect(@abs(r - 40) < 0.6);
    }
    try testing.expect(@abs(pieces.xy.items[0] - pieces.xy.items[(n - 1) * 2]) < 1e-9);
    try testing.expect(@abs(pieces.xy.items[1] - pieces.xy.items[(n - 1) * 2 + 1]) < 1e-9);
}

test "a contour of a ramp is one open line, and a level outside the data is nothing" {
    const g = Grid{ .lon0 = 0, .lat0 = 0, .dlon = 1, .dlat = 1, .nx = 11, .ny = 11 };
    const vals = try ta.alloc(f64, g.count());
    defer ta.free(vals);
    for (0..g.ny) |j| {
        for (0..g.nx) |i| vals[j * g.nx + i] = @floatFromInt(i);
    }
    var pieces = gp.Pieces{};
    defer pieces.deinit();
    try contour(ta, vals, g, 4.5, &pieces);
    try testing.expect(pieces.starts.items.len == 1);
    const n = pieces.xy.items.len / 2;
    for (0..n) |k| try testing.expect(@abs(pieces.xy.items[k * 2] - 4.5) < 1e-9);
    // it is OPEN: the ends differ
    try testing.expect(@abs(pieces.xy.items[1] - pieces.xy.items[(n - 1) * 2 + 1]) > 5);

    var empty = gp.Pieces{};
    defer empty.deinit();
    try contour(ta, vals, g, 99, &empty);
    try testing.expect(empty.starts.items.len == 0);
}

test "a contour is not drawn across ground nobody measured" {
    const g = Grid{ .lon0 = 0, .lat0 = 0, .dlon = 1, .dlat = 1, .nx = 11, .ny = 11 };
    const vals = try ta.alloc(f64, g.count());
    defer ta.free(vals);
    for (0..g.ny) |j| {
        for (0..g.nx) |i| vals[j * g.nx + i] = @floatFromInt(i);
    }
    var full = gp.Pieces{};
    defer full.deinit();
    try contour(ta, vals, g, 4.5, &full);
    const n_full = full.xy.items.len;
    // knock a hole out of the middle of the line's path
    vals[5 * g.nx + 4] = std.math.nan(f64);
    vals[5 * g.nx + 5] = std.math.nan(f64);
    var holed = gp.Pieces{};
    defer holed.deinit();
    try contour(ta, vals, g, 4.5, &holed);
    try testing.expect(holed.xy.items.len < n_full);
    try testing.expect(holed.starts.items.len == 2);
}

test "the class of a value is 1-based and the top is closed" {
    const edges = [_]f64{ 0, 10, 20, 30 };
    try testing.expect(classOf(-1, &edges) == 0);
    try testing.expect(classOf(0, &edges) == 1);
    try testing.expect(classOf(10, &edges) == 1);
    try testing.expect(classOf(10.5, &edges) == 2);
    try testing.expect(classOf(30, &edges) == 3);
    try testing.expect(classOf(31, &edges) == 0);
    try testing.expect(classOf(std.math.nan(f64), &edges) == 0);
}

test "an ESRI grid is read, flipped, half-shifted, and its nodata is unknown" {
    const text =
        \\ncols 3
        \\nrows 2
        \\xllcorner 10.0
        \\yllcorner 30.0
        \\cellsize 0.5
        \\NODATA_value -9999
        \\1 2 3
        \\4 -9999 6
    ;
    const a = try readAsciiGrid(ta, text);
    defer ta.free(a.values);
    try testing.expect(a.g.nx == 3 and a.g.ny == 2);
    // the corner became a centre
    try testing.expect(@abs(a.g.lon0 - 10.25) < 1e-12);
    try testing.expect(@abs(a.g.lat0 - 30.25) < 1e-12);
    // the file's LAST row is this grid's row 0
    try testing.expect(a.values[0] == 4);
    try testing.expect(std.math.isNan(a.values[1]));
    try testing.expect(a.values[2] == 6);
    try testing.expect(a.values[3] == 1 and a.values[5] == 3);
    const s = stats(a.values);
    try testing.expect(s.known == 5 and s.unknown == 1 and s.min == 1 and s.max == 6);
}

test "a centred ESRI header is not shifted again" {
    const text =
        \\ncols 2
        \\nrows 2
        \\xllcenter 10.0
        \\yllcenter 30.0
        \\cellsize 1
        \\1 2
        \\3 4
    ;
    const a = try readAsciiGrid(ta, text);
    defer ta.free(a.values);
    try testing.expect(a.g.lon0 == 10 and a.g.lat0 == 30);
    try testing.expect(a.values[0] == 3);
}

test "a truncated or unreadable grid is refused, never half-read" {
    const short =
        \\ncols 3
        \\nrows 2
        \\xllcorner 0
        \\yllcorner 0
        \\cellsize 1
        \\1 2 3
        \\4 5
    ;
    try testing.expectError(error.ShortData, readAsciiGrid(ta, short));
    const junk =
        \\ncols 2
        \\nrows 2
        \\xllcorner 0
        \\yllcorner 0
        \\cellsize 1
        \\1 2
        \\3 wet
    ;
    try testing.expectError(error.BadNumber, readAsciiGrid(ta, junk));
}

test "the picture is painted only where the field has a class" {
    const g = Grid{ .lon0 = 0, .lat0 = 0, .dlon = 1, .dlat = 1, .nx = 5, .ny = 5 };
    const vals = try ta.alloc(f64, g.count());
    defer ta.free(vals);
    for (0..g.count()) |k| vals[k] = 5;
    var p = gp.Projection.fromKind(.equirectangular);
    _ = gp.fitPoints(&p, &.{ 0, 0, 4, 4 }, 0, 0, 40, 40, 0);
    const edges = [_]f64{ 0, 10 };
    const pal = [_]u8{ 200, 100, 50 };
    const img = try ta.alloc(u8, 40 * 40 * 4);
    defer ta.free(img);
    fieldImage(vals, g, &p, 0, 0, 40, 40, &edges, &pal, 255, img);
    var painted: usize = 0;
    for (0..40 * 40) |k| {
        if (img[k * 4 + 3] != 0) {
            painted += 1;
            try testing.expect(img[k * 4] == 200 and img[k * 4 + 1] == 100 and img[k * 4 + 2] == 50);
        }
    }
    try testing.expect(painted > 1200);

    // a value under every class paints nothing at all
    for (0..g.count()) |k| vals[k] = -5;
    fieldImage(vals, g, &p, 0, 0, 40, 40, &edges, &pal, 255, img);
    for (0..40 * 40) |k| try testing.expect(img[k * 4 + 3] == 0);
}
