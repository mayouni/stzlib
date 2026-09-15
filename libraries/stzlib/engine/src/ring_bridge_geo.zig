const std = @import("std");
const geo = @import("geo.zig");
const gp = @import("geo_projection.zig");
const gs = @import("geo_stats.zig");
const gf = @import("geo_field.zig");
const gi = @import("geo_interp.zig");
const gg = @import("geo_geodesy.zig");
const gpr = @import("geo_process.zig");
const gdi = @import("geo_distortion.zig");
const gfu = @import("geo_furniture.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const rn = R.ring_vm_api_retnumber;
const alloc = std.heap.c_allocator;

// ------------------------------------------------ GE0: the sphere
//
// A PROJECTION CROSSES THE BRIDGE AS ELEVEN NUMBERS, not as a handle:
//   [ kind, rotLambda, rotPhi, rotGamma, par0, par1, scale, tx, ty,
//     clipAngle, precision ]   -- angles in DEGREES
// so the Ring object that owns them is the single source of truth and
// nothing engine-side can go stale. Fit answers the three numbers it
// changed and the Ring side writes them back.

fn readF64s(lst: *anyopaque) ?[]f64 {
    const n: usize = @intCast(R.ringListSize(lst));
    const buf = alloc.alloc(f64, n) catch return null;
    for (0..n) |i| {
        const item = R.ring_list_getitem_gc(null, lst, @intCast(i + 1)) orelse {
            buf[i] = 0;
            continue;
        };
        buf[i] = R.ring_item_getnumber(item);
    }
    return buf;
}

fn readProjection(p: *anyopaque, arg: c_int) ?gp.Projection {
    if (R.il(p, arg) == 0) return null;
    const lst = R.gl(p, arg) orelse return null;
    const v = readF64s(lst) orelse return null;
    defer alloc.free(v);
    if (v.len < 11) return null;
    const ki: i64 = @intFromFloat(v[0]);
    // ...AND THIS WAS THE THIRD COPY OF THE SAME LITERAL, and the one that
    // mattered most: readProjection is what EVERY projection call goes
    // through, so a kind past the sixteenth would have been refused at the
    // bridge and every gallery projection would have drawn nothing at all.
    if (ki < 0 or ki >= @as(i64, @intCast(@typeInfo(gp.Kind).@"enum".fields.len))) return null;
    var pr = gp.Projection.fromKind(@enumFromInt(@as(u8, @intCast(ki))));
    const deg = std.math.pi / 180.0;
    pr.rot = .{ v[1] * deg, v[2] * deg, v[3] * deg };
    pr.par = .{ v[4] * deg, v[5] * deg };
    pr.scale = v[6];
    pr.tx = v[7];
    pr.ty = v[8];
    pr.clip_angle = v[9] * deg;
    pr.precision = v[10];
    return pr;
}

fn readPoints(p: *anyopaque, arg: c_int) ?[]f64 {
    if (R.il(p, arg) == 0) return null;
    const lst = R.gl(p, arg) orelse return null;
    return readF64s(lst);
}

fn retEmpty(p: *anyopaque) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    R.ring_vm_api_retlist(p, out);
}

fn retPair(p: *anyopaque, a: f64, b: f64) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    R.ring_list_adddouble(out, a);
    R.ring_list_adddouble(out, b);
    R.ring_vm_api_retlist(p, out);
}

/// pieces -> a list of flat [x1, y1, x2, y2, ...] lists, one per piece
fn retPieces(p: *anyopaque, pieces: *const gp.Pieces) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    const n = pieces.starts.items.len;
    for (0..n) |i| {
        const from = pieces.starts.items[i];
        const to = if (i + 1 < n) pieces.starts.items[i + 1] else pieces.xy.items.len;
        if (to <= from) continue;
        const piece = R.ring_list_newlist(out) orelse continue;
        var j = from;
        while (j < to) : (j += 1) R.ring_list_adddouble(piece, pieces.xy.items[j]);
    }
    R.ring_vm_api_retlist(p, out);
}

// GeoProject(aProj, nLon, nLat) -> [x, y], or [] when the point is behind
// the globe or has no image
fn ring_GeoProject(p: *anyopaque) callconv(.c) void {
    const pr = readProjection(p, 1) orelse return retEmpty(p);
    const q = gp.forward(&pr, gn(p, 2), gn(p, 3)) orelse return retEmpty(p);
    retPair(p, q[0], q[1]);
}

// GeoInvert(aProj, nX, nY) -> [lon, lat], or [] off the sphere
fn ring_GeoInvert(p: *anyopaque) callconv(.c) void {
    const pr = readProjection(p, 1) orelse return retEmpty(p);
    const q = gp.invert(&pr, gn(p, 2), gn(p, 3)) orelse return retEmpty(p);
    retPair(p, q[0], q[1]);
}

// GeoProjectLine(aProj, aLonLat) -> the visible pieces, each [x1,y1,...]
fn ring_GeoProjectLine(p: *anyopaque) callconv(.c) void {
    const pr = readProjection(p, 1) orelse return retEmpty(p);
    const pts = readPoints(p, 2) orelse return retEmpty(p);
    defer alloc.free(pts);
    var pieces = gp.Pieces{};
    defer pieces.deinit();
    gp.projectLine(&pr, pts, &pieces) catch return retEmpty(p);
    retPieces(p, &pieces);
}

// GeoProjectRing(aProj, aLonLat) -> the same, the ring closed first
fn ring_GeoProjectRing(p: *anyopaque) callconv(.c) void {
    const pr = readProjection(p, 1) orelse return retEmpty(p);
    const pts = readPoints(p, 2) orelse return retEmpty(p);
    defer alloc.free(pts);
    var pieces = gp.Pieces{};
    defer pieces.deinit();
    gp.projectRing(&pr, pts, &pieces) catch return retEmpty(p);
    retPieces(p, &pieces);
}

// GeoProjectRingFilled(aProj, aLonLat) -> CLOSED polygons: where the map
// cut the ring, its pieces are rejoined along the map's own edge, so each
// answer can be filled (GE0c)
fn ring_GeoProjectRingFilled(p: *anyopaque) callconv(.c) void {
    const pr = readProjection(p, 1) orelse return retEmpty(p);
    const pts = readPoints(p, 2) orelse return retEmpty(p);
    defer alloc.free(pts);
    var pieces = gp.Pieces{};
    defer pieces.deinit();
    gp.projectRingFilled(&pr, pts, &pieces) catch return retEmpty(p);
    retPieces(p, &pieces);
}

// GeoRingContains(aLonLat, nLon, nLat) -> 1 when the place is inside the
// ring on the SPHERE
fn ring_GeoRingContains(p: *anyopaque) callconv(.c) void {
    const pts = readPoints(p, 1) orelse return rn(p, 0);
    defer alloc.free(pts);
    rn(p, if (gp.ringContains(pts, gn(p, 2), gn(p, 3))) 1 else 0);
}

// GeoProjectPolygonFilled(aProj, aRings) -> CLOSED polygons. aRings is a
// list of flat [lon,lat,...] rings: the first is the outer edge and every
// one after it is a HOLE, bridged into it (GE1). GeoHolesDropped() says
// how many holes the last call could not give -- a cut ring cannot carry
// a bridge, and that is counted rather than hidden.
/// a list of flat [lon,lat,...] rings, read as one owned block; free with
/// freeRings. Written once for the polygon filler and read by every point
/// pattern function since, because two readers of one shape drift.
const Rings = struct { rings: [][]f64, view: [][]const f64 };

fn readRings(p: *anyopaque, arg: c_int) ?Rings {
    if (R.il(p, arg) == 0) return null;
    const lst = R.gl(p, arg) orelse return null;
    const n: usize = @intCast(R.ringListSize(lst));
    if (n == 0) return null;
    const rings = alloc.alloc([]f64, n) catch return null;
    var made: usize = 0;
    for (0..n) |i| {
        const item = R.ring_list_getlist_gc(null, lst, @intCast(i + 1)) orelse {
            rings[i] = alloc.alloc(f64, 0) catch return null;
            made += 1;
            continue;
        };
        rings[i] = readF64s(item) orelse (alloc.alloc(f64, 0) catch return null);
        made += 1;
    }
    const view = alloc.alloc([]const f64, n) catch return null;
    for (0..n) |i| view[i] = rings[i];
    return .{ .rings = rings, .view = view };
}

fn freeRings(r: Rings) void {
    for (r.rings) |x| alloc.free(x);
    alloc.free(r.rings);
    alloc.free(r.view);
}

fn ring_GeoProjectPolygonFilled(p: *anyopaque) callconv(.c) void {
    const pr = readProjection(p, 1) orelse return retEmpty(p);
    const rr = readRings(p, 2) orelse return retEmpty(p);
    defer freeRings(rr);
    var pieces = gp.Pieces{};
    defer pieces.deinit();
    gp.projectPolygonFilled(&pr, rr.view, &pieces) catch return retEmpty(p);
    retPieces(p, &pieces);
}

// ------------------------------------------------ GE7a: point patterns
//
// A WINDOW CROSSES THE BRIDGE AS ITS OUTER RINGS AND ITS BOX: a list of
// flat rings and [lon0, lat0, lon1, lat1]. Holes are not carried -- see
// geo_stats.Window for what that costs, which is the area of a lake.

const WindowRead = struct { rr: Rings, w: gs.Window };

fn readWindow(p: *anyopaque, ringsArg: c_int, boxArg: c_int) ?WindowRead {
    const rr = readRings(p, ringsArg) orelse return null;
    const box = readPoints(p, boxArg) orelse {
        freeRings(rr);
        return null;
    };
    defer alloc.free(box);
    if (box.len < 4) {
        freeRings(rr);
        return null;
    }
    return .{ .rr = rr, .w = .{ .rings = rr.view, .bbox = .{ box[0], box[1], box[2], box[3] } } };
}

fn retF64s(p: *anyopaque, v: []const f64) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    for (v) |x| R.ring_list_adddouble(out, x);
    R.ring_vm_api_retlist(p, out);
}

fn argUsize(p: *anyopaque, arg: c_int) usize {
    const v = gn(p, arg);
    if (v < 0) return 0;
    return @intFromFloat(v);
}

fn argU64(p: *anyopaque, arg: c_int) u64 {
    const v = gn(p, arg);
    if (v < 0) return 0;
    return @intFromFloat(v);
}

// GeoNearestNeighbour(aLonLat) -> [d1, d2, ...] km, one per point
fn ring_GeoNearestNeighbour(p: *anyopaque) callconv(.c) void {
    const pts = readPoints(p, 1) orelse return retEmpty(p);
    defer alloc.free(pts);
    const n = pts.len / 2;
    const out = alloc.alloc(f64, n) catch return retEmpty(p);
    defer alloc.free(out);
    gs.nearestNeighbourKm(alloc, pts, out) catch return retEmpty(p);
    retF64s(p, out);
}

// GeoClarkEvans(aLonLat, nAreaKm2, nPerimeterKm) -> [R, z, observedKm, expectedKm];
// a perimeter of 0 gives the uncorrected index
fn ring_GeoClarkEvans(p: *anyopaque) callconv(.c) void {
    const pts = readPoints(p, 1) orelse return retEmpty(p);
    defer alloc.free(pts);
    const n = pts.len / 2;
    const nn = alloc.alloc(f64, n) catch return retEmpty(p);
    defer alloc.free(nn);
    gs.nearestNeighbourKm(alloc, pts, nn) catch return retEmpty(p);
    const ce = gs.clarkEvans(nn, gn(p, 2), gn(p, 3));
    retF64s(p, &.{ ce.r, ce.z, ce.observed_km, ce.expected_km });
}

// GeoRingLength(aLonLat) -> km along great circles, closed
fn ring_GeoRingLength(p: *anyopaque) callconv(.c) void {
    const pts = readPoints(p, 1) orelse return rn(p, 0);
    defer alloc.free(pts);
    rn(p, gs.ringLengthKm(pts));
}

// GeoRipleyK(aLonLat, nAreaKm2, aRadiiKm) -> [K(r1), K(r2), ...]
fn ring_GeoRipleyK(p: *anyopaque) callconv(.c) void {
    const pts = readPoints(p, 1) orelse return retEmpty(p);
    defer alloc.free(pts);
    const radii = readPoints(p, 3) orelse return retEmpty(p);
    defer alloc.free(radii);
    const out = alloc.alloc(f64, radii.len) catch return retEmpty(p);
    defer alloc.free(out);
    gs.ripleyK(alloc, pts, gn(p, 2), radii, out) catch return retEmpty(p);
    retF64s(p, out);
}

// GeoGFunction(aLonLat, aRadiiKm) -> [G(r1), ...]: the nearest-neighbour distribution
fn ring_GeoGFunction(p: *anyopaque) callconv(.c) void {
    const pts = readPoints(p, 1) orelse return retEmpty(p);
    defer alloc.free(pts);
    const radii = readPoints(p, 2) orelse return retEmpty(p);
    defer alloc.free(radii);
    const n = pts.len / 2;
    const nn = alloc.alloc(f64, n) catch return retEmpty(p);
    defer alloc.free(nn);
    gs.nearestNeighbourKm(alloc, pts, nn) catch return retEmpty(p);
    const out = alloc.alloc(f64, radii.len) catch return retEmpty(p);
    defer alloc.free(out);
    gs.cdfAt(nn, radii, out);
    retF64s(p, out);
}

// GeoFFunction(aLonLat, aRings, aBox, nTests, nSeed, aRadiiKm) -> [F(r1), ...]: empty space
fn ring_GeoFFunction(p: *anyopaque) callconv(.c) void {
    const pts = readPoints(p, 1) orelse return retEmpty(p);
    defer alloc.free(pts);
    const wd = readWindow(p, 2, 3) orelse return retEmpty(p);
    defer freeRings(wd.rr);
    const m = argUsize(p, 4);
    const radii = readPoints(p, 6) orelse return retEmpty(p);
    defer alloc.free(radii);
    const es = alloc.alloc(f64, m) catch return retEmpty(p);
    defer alloc.free(es);
    const got = gs.emptySpaceKm(alloc, pts, &wd.w, m, argU64(p, 5), es) catch return retEmpty(p);
    const out = alloc.alloc(f64, radii.len) catch return retEmpty(p);
    defer alloc.free(out);
    gs.cdfAt(es[0..got], radii, out);
    retF64s(p, out);
}

// GeoKEnvelope(aRings, aBox, nPoints, nAreaKm2, aRadiiKm, nSims, nSeed) -> [lo, hi, mean] per radius, flat
fn ring_GeoKEnvelope(p: *anyopaque) callconv(.c) void {
    const wd = readWindow(p, 1, 2) orelse return retEmpty(p);
    defer freeRings(wd.rr);
    const n = argUsize(p, 3);
    const radii = readPoints(p, 5) orelse return retEmpty(p);
    defer alloc.free(radii);
    const sims = argUsize(p, 6);
    const out = alloc.alloc(f64, radii.len * 3) catch return retEmpty(p);
    defer alloc.free(out);
    gs.kEnvelope(alloc, &wd.w, n, gn(p, 4), radii, sims, argU64(p, 7), out) catch return retEmpty(p);
    retF64s(p, out);
}

// GeoSampleInside(aRings, aBox, nHowMany, nSeed) -> flat lon/lat, uniform on the sphere
fn ring_GeoSampleInside(p: *anyopaque) callconv(.c) void {
    const wd = readWindow(p, 1, 2) orelse return retEmpty(p);
    defer freeRings(wd.rr);
    const n = argUsize(p, 3);
    const out = alloc.alloc(f64, n * 2) catch return retEmpty(p);
    defer alloc.free(out);
    const got = gs.sampleInside(&wd.w, n, argU64(p, 4), out);
    retF64s(p, out[0 .. got * 2]);
}

// GeoMaternCluster(aRings, aBox, nParents, nChildren, nRadiusKm, nSeed) -> flat lon/lat
fn ring_GeoMaternCluster(p: *anyopaque) callconv(.c) void {
    const wd = readWindow(p, 1, 2) orelse return retEmpty(p);
    defer freeRings(wd.rr);
    const parents = argUsize(p, 3);
    const children = argUsize(p, 4);
    const out = alloc.alloc(f64, parents * children * 2) catch return retEmpty(p);
    defer alloc.free(out);
    const got = gs.maternCluster(&wd.w, parents, children, gn(p, 5), argU64(p, 6), out);
    retF64s(p, out[0 .. got * 2]);
}

// GeoHardCore(aRings, aBox, nHowMany, nMinKm, nSeed) -> flat lon/lat
fn ring_GeoHardCore(p: *anyopaque) callconv(.c) void {
    const wd = readWindow(p, 1, 2) orelse return retEmpty(p);
    defer freeRings(wd.rr);
    const n = argUsize(p, 3);
    const out = alloc.alloc(f64, n * 2) catch return retEmpty(p);
    defer alloc.free(out);
    const got = gs.hardCore(alloc, &wd.w, n, gn(p, 4), argU64(p, 5), out) catch return retEmpty(p);
    retF64s(p, out[0 .. got * 2]);
}

// GeoMeanCentre(aLonLat) -> [lon, lat]
fn ring_GeoMeanCentre(p: *anyopaque) callconv(.c) void {
    const pts = readPoints(p, 1) orelse return retEmpty(p);
    defer alloc.free(pts);
    const c = gs.meanCentre(pts);
    retPair(p, c[0], c[1]);
}

// GeoSpatialMedian(aLonLat) -> [lon, lat]
fn ring_GeoSpatialMedian(p: *anyopaque) callconv(.c) void {
    const pts = readPoints(p, 1) orelse return retEmpty(p);
    defer alloc.free(pts);
    const c = gs.spatialMedian(alloc, pts) catch return retEmpty(p);
    retPair(p, c[0], c[1]);
}

// GeoEllipse(aLonLat) -> [lon, lat, sdKm, majorKm, minorKm, bearingDeg]
fn ring_GeoEllipse(p: *anyopaque) callconv(.c) void {
    const pts = readPoints(p, 1) orelse return retEmpty(p);
    defer alloc.free(pts);
    const e = gs.ellipse(pts);
    retF64s(p, &.{ e.lon, e.lat, e.sd_km, e.major_km, e.minor_km, e.bearing_deg });
}

// GeoEllipseRing(nLon, nLat, nMajorKm, nMinorKm, nBearingDeg, nPoints) -> flat lon/lat ring
fn ring_GeoEllipseRing(p: *anyopaque) callconv(.c) void {
    var n = argUsize(p, 6);
    if (n < 3) n = 3;
    const out = alloc.alloc(f64, n * 2) catch return retEmpty(p);
    defer alloc.free(out);
    gs.ellipseRing(gn(p, 1), gn(p, 2), gn(p, 3), gn(p, 4), gn(p, 5), n, out);
    retF64s(p, out);
}

fn ring_GeoHolesDropped(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gp.holesDropped()));
}

// GeoHexBin(aXY, nRadius) -> [ [cx, cy, count], ... ]. Counts PAPER
// coordinates into hexagonal cells; the caller projects first, and the
// map's rules say what that costs on a projection that distorts area.
fn ring_GeoHexBin(p: *anyopaque) callconv(.c) void {
    const pts = readPoints(p, 1) orelse return retEmpty(p);
    defer alloc.free(pts);
    var bins = std.ArrayList(gp.Bin){};
    defer bins.deinit(alloc);
    gp.hexbin(pts, gn(p, 2), &bins) catch return retEmpty(p);
    const out = R.ring_vm_api_newlist(p) orelse return;
    for (bins.items) |b| {
        const row = R.ring_list_newlist(out) orelse continue;
        R.ring_list_adddouble(row, b.cx);
        R.ring_list_adddouble(row, b.cy);
        R.ring_list_adddouble(row, @floatFromInt(b.n));
    }
    R.ring_vm_api_retlist(p, out);
}

// GeoHexagon(nCx, nCy, nRadius) -> the six corners, flat
fn ring_GeoHexagon(p: *anyopaque) callconv(.c) void {
    var ring = std.ArrayList(f64){};
    defer ring.deinit(alloc);
    gp.hexagon(gn(p, 1), gn(p, 2), gn(p, 3), &ring) catch return retEmpty(p);
    const out = R.ring_vm_api_newlist(p) orelse return;
    for (ring.items) |v| R.ring_list_adddouble(out, v);
    R.ring_vm_api_retlist(p, out);
}

// GeoGraticule(aProj, nStepDeg) -> pieces
fn ring_GeoGraticule(p: *anyopaque) callconv(.c) void {
    const pr = readProjection(p, 1) orelse return retEmpty(p);
    var step = gn(p, 2);
    if (step <= 0) step = 10;
    var pieces = gp.Pieces{};
    defer pieces.deinit();
    gp.graticule(&pr, step, &pieces) catch return retEmpty(p);
    retPieces(p, &pieces);
}

// GeoOutline(aProj) -> pieces (one, the world's edge)
fn ring_GeoOutline(p: *anyopaque) callconv(.c) void {
    const pr = readProjection(p, 1) orelse return retEmpty(p);
    var pieces = gp.Pieces{};
    defer pieces.deinit();
    gp.outline(&pr, &pieces) catch return retEmpty(p);
    retPieces(p, &pieces);
}

// GeoCircle(nLon, nLat, nRadiusDeg, nPoints) -> flat [lon1, lat1, ...],
// closed
fn ring_GeoCircle(p: *anyopaque) callconv(.c) void {
    var ring: std.ArrayList(f64) = .{};
    defer ring.deinit(alloc);
    var n: i64 = @intFromFloat(gn(p, 4));
    if (n < 8) n = 8;
    if (n > 3600) n = 3600;
    gp.circle(&ring, gn(p, 1), gn(p, 2), gn(p, 3), @intCast(n)) catch return retEmpty(p);
    const out = R.ring_vm_api_newlist(p) orelse return;
    for (ring.items) |v| R.ring_list_adddouble(out, v);
    R.ring_vm_api_retlist(p, out);
}

// GeoFitPoints(aProj, aLonLat, x0, y0, x1, y1, pad) -> [scale, tx, ty] or []
fn ring_GeoFitPoints(p: *anyopaque) callconv(.c) void {
    var pr = readProjection(p, 1) orelse return retEmpty(p);
    const pts = readPoints(p, 2) orelse return retEmpty(p);
    defer alloc.free(pts);
    if (!gp.fitPoints(&pr, pts, gn(p, 3), gn(p, 4), gn(p, 5), gn(p, 6), gn(p, 7))) return retEmpty(p);
    const out = R.ring_vm_api_newlist(p) orelse return;
    R.ring_list_adddouble(out, pr.scale);
    R.ring_list_adddouble(out, pr.tx);
    R.ring_list_adddouble(out, pr.ty);
    R.ring_vm_api_retlist(p, out);
}

// GeoFitSphere(aProj, x0, y0, x1, y1, pad) -> [scale, tx, ty] or []
fn ring_GeoFitSphere(p: *anyopaque) callconv(.c) void {
    var pr = readProjection(p, 1) orelse return retEmpty(p);
    const ok = gp.fitSphere(&pr, gn(p, 2), gn(p, 3), gn(p, 4), gn(p, 5), gn(p, 6)) catch false;
    if (!ok) return retEmpty(p);
    const out = R.ring_vm_api_newlist(p) orelse return;
    R.ring_list_adddouble(out, pr.scale);
    R.ring_list_adddouble(out, pr.tx);
    R.ring_list_adddouble(out, pr.ty);
    R.ring_vm_api_retlist(p, out);
}

// GeoInterpolate(lon1, lat1, lon2, lat2, t) -> [lon, lat] on the great circle
fn ring_GeoInterpolate(p: *anyopaque) callconv(.c) void {
    const deg = std.math.pi / 180.0;
    const q = gp.interpolate(.{ gn(p, 1) * deg, gn(p, 2) * deg }, .{ gn(p, 3) * deg, gn(p, 4) * deg }, gn(p, 5));
    retPair(p, q[0] / deg, q[1] / deg);
}

// GeoRingArea(aLonLat) -> steradians, signed (counter-clockwise positive)
fn ring_GeoRingArea(p: *anyopaque) callconv(.c) void {
    const pts = readPoints(p, 1) orelse return rn(p, 0);
    defer alloc.free(pts);
    rn(p, gp.ringArea(pts));
}

// GeoKindCount() -> how many projections; GeoKindName(n) -> its name;
// GeoKindTraits(n) -> [equalArea, conformal, azimuthal, defaultClipAngle]
fn ring_GeoKindCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(@typeInfo(gp.Kind).@"enum".fields.len));
}

fn ring_GeoKindName(p: *anyopaque) callconv(.c) void {
    // THE BOUND IS THE ENUM'S OWN LENGTH AND NOT A NUMBER TYPED HERE. It
    // was 15, written when there were sixteen projections, and GE9's
    // twenty-eight arrived to find KindCount answering 44 while KindName
    // answered "" for everything past the sixteenth -- the Ring face built
    // a gallery of 44 names of which 28 were empty, and said nothing. Two
    // places knowing the same length is the defect shape; here one of them
    // was a literal.
    const ki: i64 = @intFromFloat(gn(p, 1));
    const last: i64 = @intCast(@typeInfo(gp.Kind).@"enum".fields.len - 1);
    if (ki < 0 or ki > last) {
        R.ring_vm_api_retstring(p, "");
        return;
    }
    const k: gp.Kind = @enumFromInt(@as(u8, @intCast(ki)));
    R.ring_vm_api_retstring(p, k.name().ptr);
}

fn ring_GeoKindTraits(p: *anyopaque) callconv(.c) void {
    const ki: i64 = @intFromFloat(gn(p, 1));
    const last: i64 = @intCast(@typeInfo(gp.Kind).@"enum".fields.len - 1);
    if (ki < 0 or ki > last) return retEmpty(p);
    const k: gp.Kind = @enumFromInt(@as(u8, @intCast(ki)));
    const out = R.ring_vm_api_newlist(p) orelse return;
    R.ring_list_adddouble(out, if (k.isEqualArea()) 1 else 0);
    R.ring_list_adddouble(out, if (k.isConformal()) 1 else 0);
    R.ring_list_adddouble(out, if (k.isAzimuthal()) 1 else 0);
    R.ring_list_adddouble(out, k.defaultClipAngle());
    R.ring_vm_api_retlist(p, out);
}

fn ring_Haversine(p: *anyopaque) callconv(.c) void {
    rn(p, geo.geo_haversine(gn(p, 1), gn(p, 2), gn(p, 3), gn(p, 4)));
}

fn ring_HaversineMiles(p: *anyopaque) callconv(.c) void {
    rn(p, geo.geo_haversine_miles(gn(p, 1), gn(p, 2), gn(p, 3), gn(p, 4)));
}

fn ring_Bearing(p: *anyopaque) callconv(.c) void {
    rn(p, geo.geo_bearing(gn(p, 1), gn(p, 2), gn(p, 3), gn(p, 4)));
}

fn ring_MidpointLat(p: *anyopaque) callconv(.c) void {
    rn(p, geo.geo_midpoint_lat(gn(p, 1), gn(p, 2), gn(p, 3), gn(p, 4)));
}

fn ring_MidpointLon(p: *anyopaque) callconv(.c) void {
    rn(p, geo.geo_midpoint_lon(gn(p, 1), gn(p, 2), gn(p, 3), gn(p, 4)));
}

fn ring_DestinationLat(p: *anyopaque) callconv(.c) void {
    rn(p, geo.geo_destination_lat(gn(p, 1), gn(p, 2), gn(p, 3), gn(p, 4)));
}

fn ring_DestinationLon(p: *anyopaque) callconv(.c) void {
    rn(p, geo.geo_destination_lon(gn(p, 1), gn(p, 2), gn(p, 3), gn(p, 4)));
}

fn ring_IsValidLat(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(geo.geo_is_valid_lat(gn(p, 1))));
}

fn ring_IsValidLon(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(geo.geo_is_valid_lon(gn(p, 1))));
}

fn ring_IsValidCoord(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(geo.geo_is_valid_coord(gn(p, 1), gn(p, 2))));
}

fn ring_KmToMiles(p: *anyopaque) callconv(.c) void {
    rn(p, geo.geo_km_to_miles(gn(p, 1)));
}

fn ring_MilesToKm(p: *anyopaque) callconv(.c) void {
    rn(p, geo.geo_miles_to_km(gn(p, 1)));
}

fn ring_DegToRad(p: *anyopaque) callconv(.c) void {
    rn(p, geo.geo_deg_to_rad(gn(p, 1)));
}

fn ring_RadToDeg(p: *anyopaque) callconv(.c) void {
    rn(p, geo.geo_rad_to_deg(gn(p, 1)));
}

// ------------------------------------------------ GE7b: fields
//
// A GRID CROSSES THE BRIDGE AS SIX NUMBERS AND A FLAT LIST:
//   [ lon0, lat0, dlon, dlat, nx, ny ]  and  values, row 0 SOUTH.
// Same shape as the projection's eleven: the Ring object owns them, nothing
// engine-side can go stale, and a caller can print the whole thing.
//
// An unknown value is NaN on this side and "" on the Ring side -- Ring has
// no NaN literal, so the two readers below are where that translation is
// done, once.

fn readGrid(p: *anyopaque, arg: c_int) ?gf.Grid {
    const v = readPoints(p, arg) orelse return null;
    defer alloc.free(v);
    if (v.len < 6) return null;
    const nx: usize = @intFromFloat(@max(v[4], 0));
    const ny: usize = @intFromFloat(@max(v[5], 0));
    if (nx < 2 or ny < 2 or nx * ny > 40_000_000) return null;
    return .{ .lon0 = v[0], .lat0 = v[1], .dlon = v[2], .dlat = v[3], .nx = nx, .ny = ny };
}

fn retGrid(p: *anyopaque, g: gf.Grid) void {
    retF64s(p, &.{ g.lon0, g.lat0, g.dlon, g.dlat, @floatFromInt(g.nx), @floatFromInt(g.ny) });
}

/// a Ring list of values where a non-number means "not known"
fn readValues(p: *anyopaque, arg: c_int) ?[]f64 {
    if (R.il(p, arg) == 0) return null;
    const lst = R.gl(p, arg) orelse return null;
    const n: usize = @intCast(R.ringListSize(lst));
    const buf = alloc.alloc(f64, n) catch return null;
    for (0..n) |i| {
        if (R.ring_list_isnumber_gc(null, lst, @intCast(i + 1)) == 0) {
            buf[i] = std.math.nan(f64);
            continue;
        }
        const item = R.ring_list_getitem_gc(null, lst, @intCast(i + 1)) orelse {
            buf[i] = std.math.nan(f64);
            continue;
        };
        buf[i] = R.ring_item_getnumber(item);
    }
    return buf;
}

/// NaN comes back as "", which is the value Ring's own no-data already uses
fn retValues(p: *anyopaque, v: []const f64) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    for (v) |x| {
        if (std.math.isNan(x)) R.ring_list_addstring(out, "") else R.ring_list_adddouble(out, x);
    }
    R.ring_vm_api_retlist(p, out);
}

// GeoGridOver(aBox, nCellKm) -> [ lon0, lat0, dlon, dlat, nx, ny ]
fn ring_GeoGridOver(p: *anyopaque) callconv(.c) void {
    const b = readPoints(p, 1) orelse return retEmpty(p);
    defer alloc.free(b);
    if (b.len < 4) return retEmpty(p);
    retGrid(p, gf.gridOver(.{ b[0], b[1], b[2], b[3] }, gn(p, 2)));
}

// GeoGridMask(aGrid, aRings, aBox) -> 1 per node inside the window, 0 outside
fn ring_GeoGridMask(p: *anyopaque) callconv(.c) void {
    const g = readGrid(p, 1) orelse return retEmpty(p);
    const wd = readWindow(p, 2, 3) orelse return retEmpty(p);
    defer freeRings(wd.rr);
    const m = alloc.alloc(bool, g.count()) catch return retEmpty(p);
    defer alloc.free(m);
    gf.maskInside(g, &wd.w, m);
    const out = R.ring_vm_api_newlist(p) orelse return;
    for (m) |b| R.ring_list_adddouble(out, if (b) 1 else 0);
    R.ring_vm_api_retlist(p, out);
}

// GeoKernelDensity(aLonLat, aGrid, nBandwidthKm, nKernel, aRings, aBox,
//                  nEdgeCorrect) -> values, row 0 south. Pass [] for the
// rings to leave the estimate unclipped.
fn ring_GeoKernelDensity(p: *anyopaque) callconv(.c) void {
    const pts = readPoints(p, 1) orelse return retEmpty(p);
    defer alloc.free(pts);
    const g = readGrid(p, 2) orelse return retEmpty(p);
    const kind: gf.Kernel = if (gn(p, 4) >= 1) .gaussian else .quartic;
    const out = alloc.alloc(f64, g.count()) catch return retEmpty(p);
    defer alloc.free(out);

    var mask: ?[]bool = null;
    const wd: ?WindowRead = readWindow(p, 5, 6);
    defer if (wd) |w| freeRings(w.rr);
    if (wd) |w| {
        const m = alloc.alloc(bool, g.count()) catch return retEmpty(p);
        gf.maskInside(g, &w.w, m);
        mask = m;
    }
    defer if (mask) |m| alloc.free(m);

    gf.kernelDensity(alloc, pts, g, gn(p, 3), kind, mask, gn(p, 7) != 0, out) catch return retEmpty(p);
    retValues(p, out);
}

// GeoFieldStats(aValues) -> [ min, max, known, unknown ]
fn ring_GeoFieldStats(p: *anyopaque) callconv(.c) void {
    const v = readValues(p, 1) orelse return retEmpty(p);
    defer alloc.free(v);
    const s = gf.stats(v);
    retF64s(p, &.{ s.min, s.max, @floatFromInt(s.known), @floatFromInt(s.unknown) });
}

// GeoFieldAt(aValues, aGrid, nLon, nLat) -> the value there, or ""
fn ring_GeoFieldAt(p: *anyopaque) callconv(.c) void {
    const v = readValues(p, 1) orelse return R.ring_vm_api_retstring(p, "");
    defer alloc.free(v);
    const g = readGrid(p, 2) orelse return R.ring_vm_api_retstring(p, "");
    const r = gf.sampleAt(v, g, gn(p, 3), gn(p, 4));
    if (std.math.isNan(r)) return R.ring_vm_api_retstring(p, "");
    rn(p, r);
}

// GeoContour(aValues, aGrid, nLevel) -> a list of flat lon/lat polylines
fn ring_GeoContour(p: *anyopaque) callconv(.c) void {
    const v = readValues(p, 1) orelse return retEmpty(p);
    defer alloc.free(v);
    const g = readGrid(p, 2) orelse return retEmpty(p);
    if (v.len < g.count()) return retEmpty(p);
    var pieces = gp.Pieces{};
    defer pieces.deinit();
    gf.contour(alloc, v, g, gn(p, 3), &pieces) catch return retEmpty(p);
    retPieces(p, &pieces);
}

// GeoFieldImage(aProj, aValues, aGrid, nX0, nY0, nW, nH, aEdges, aPaletteRGB,
//               nAlpha, aClipRings) -> an RGBA buffer of nW x nH, ready for
// AddImage. aClipRings ([] for none) clips the picture to those lon/lat
// rings at pixel resolution, antialiased.
fn ring_GeoFieldImage(p: *anyopaque) callconv(.c) void {
    const pr = readProjection(p, 1) orelse return R.ring_vm_api_retstring(p, "");
    const v = readValues(p, 2) orelse return R.ring_vm_api_retstring(p, "");
    defer alloc.free(v);
    const g = readGrid(p, 3) orelse return R.ring_vm_api_retstring(p, "");
    const w: usize = @intFromFloat(@max(gn(p, 6), 0));
    const h: usize = @intFromFloat(@max(gn(p, 7), 0));
    if (w == 0 or h == 0 or w * h > 64_000_000) return R.ring_vm_api_retstring(p, "");
    const edges = readPoints(p, 8) orelse return R.ring_vm_api_retstring(p, "");
    defer alloc.free(edges);
    const pal = readPoints(p, 9) orelse return R.ring_vm_api_retstring(p, "");
    defer alloc.free(pal);
    if (edges.len < 2 or pal.len < (edges.len - 1) * 3) return R.ring_vm_api_retstring(p, "");
    const bytes = alloc.alloc(u8, pal.len) catch return R.ring_vm_api_retstring(p, "");
    defer alloc.free(bytes);
    for (pal, 0..) |x, i| bytes[i] = @intFromFloat(@min(@max(x, 0), 255));
    const img = alloc.alloc(u8, w * h * 4) catch return R.ring_vm_api_retstring(p, "");
    defer alloc.free(img);
    const a: u8 = @intFromFloat(@min(@max(gn(p, 10), 0), 255));
    const rr: ?Rings = readRings(p, 11);
    defer if (rr) |x| freeRings(x);
    const clip: []const []const f64 = if (rr) |x| x.view else &.{};
    gf.fieldImage(alloc, v, g, &pr, gn(p, 4), gn(p, 5), w, h, edges, bytes, a, clip, img) catch
        return R.ring_vm_api_retstring(p, "");
    R.ring_vm_api_retstring2(p, img.ptr, @intCast(img.len));
}

// GeoReadAsciiGrid(cText) -> [ aGrid, aValues ], or [] when it will not read
fn ring_GeoReadAsciiGrid(p: *anyopaque) callconv(.c) void {
    if (R.ring_vm_api_isstring(p, 1) == 0) return retEmpty(p);
    const txt = R.ring_vm_api_getstring(p, 1);
    const len: usize = @intCast(R.ring_vm_api_getstringsize(p, 1));
    const a = gf.readAsciiGrid(alloc, txt[0..len]) catch return retEmpty(p);
    defer alloc.free(a.values);
    const out = R.ring_vm_api_newlist(p) orelse return;
    const gl = R.ring_list_newlist(out) orelse return;
    R.ring_list_adddouble(gl, a.g.lon0);
    R.ring_list_adddouble(gl, a.g.lat0);
    R.ring_list_adddouble(gl, a.g.dlon);
    R.ring_list_adddouble(gl, a.g.dlat);
    R.ring_list_adddouble(gl, @floatFromInt(a.g.nx));
    R.ring_list_adddouble(gl, @floatFromInt(a.g.ny));
    const vl = R.ring_list_newlist(out) orelse return;
    for (a.values) |x| {
        if (std.math.isNan(x)) R.ring_list_addstring(vl, "") else R.ring_list_adddouble(vl, x);
    }
    R.ring_vm_api_retlist(p, out);
}

// ------------------------------------------------ GE7c: interpolation
//
// SAMPLES CROSS AS A FLAT [ lon, lat, value, ... ] and a VARIOGRAM as five
// numbers: [ model, nugget, sill, rangeKm, rss ]. Same discipline as the
// projection's eleven and the grid's six -- the Ring object owns them, and
// a caller can print the whole model and argue with it.

fn readVariogram(p: *anyopaque, arg: c_int) ?gi.Variogram {
    const v = readPoints(p, arg) orelse return null;
    defer alloc.free(v);
    if (v.len < 4) return null;
    const mi: i64 = @intFromFloat(v[0]);
    if (mi < 0 or mi > 2) return null;
    return .{
        .model = @enumFromInt(@as(u8, @intCast(mi))),
        .nugget = v[1],
        .sill = v[2],
        .range_km = v[3],
        .rss = if (v.len > 4) v[4] else 0,
    };
}

fn retVariogram(p: *anyopaque, v: gi.Variogram) void {
    retF64s(p, &.{ @floatFromInt(@intFromEnum(v.model)), v.nugget, v.sill, v.range_km, v.rss });
}

// GeoIdwField(aLonLatZ, aGrid, nPower, aRings, aBox) -> values, row 0 south
fn ring_GeoIdwField(p: *anyopaque) callconv(.c) void {
    const sm = readPoints(p, 1) orelse return retEmpty(p);
    defer alloc.free(sm);
    const g = readGrid(p, 2) orelse return retEmpty(p);
    const power = gn(p, 3);
    const out = alloc.alloc(f64, g.count()) catch return retEmpty(p);
    defer alloc.free(out);
    const wd: ?WindowRead = readWindow(p, 4, 5);
    defer if (wd) |x| freeRings(x.rr);
    for (0..g.ny) |j| {
        const lat = g.latAt(j);
        for (0..g.nx) |i| {
            const lon = g.lonAt(i);
            if (wd) |x| {
                if (!x.w.contains(lon, lat)) {
                    out[j * g.nx + i] = std.math.nan(f64);
                    continue;
                }
            }
            out[j * g.nx + i] = gi.idwAt(sm, lon, lat, power);
        }
    }
    retValues(p, out);
}

// GeoVariogram(aLonLatZ, nLags, nMaxKm) -> [ [h, gamma, pairs], ... ]
fn ring_GeoVariogram(p: *anyopaque) callconv(.c) void {
    const sm = readPoints(p, 1) orelse return retEmpty(p);
    defer alloc.free(sm);
    var lags: usize = @intFromFloat(@max(gn(p, 2), 0));
    if (lags == 0) lags = 12;
    if (lags > 200) lags = 200;
    const bins = alloc.alloc(gi.Bin, lags) catch return retEmpty(p);
    defer alloc.free(bins);
    const m = gi.empiricalVariogram(alloc, sm, lags, gn(p, 3), bins) catch return retEmpty(p);
    const out = R.ring_vm_api_newlist(p) orelse return;
    for (0..m) |i| {
        const row = R.ring_list_newlist(out) orelse continue;
        R.ring_list_adddouble(row, bins[i].h_km);
        R.ring_list_adddouble(row, bins[i].gamma);
        R.ring_list_adddouble(row, @floatFromInt(bins[i].pairs));
    }
    R.ring_vm_api_retlist(p, out);
}

fn readBins(p: *anyopaque, arg: c_int) ?[]gi.Bin {
    if (R.il(p, arg) == 0) return null;
    const lst = R.gl(p, arg) orelse return null;
    const n: usize = @intCast(R.ringListSize(lst));
    if (n == 0) return null;
    const bins = alloc.alloc(gi.Bin, n) catch return null;
    for (0..n) |i| {
        const row = R.ring_list_getlist_gc(null, lst, @intCast(i + 1)) orelse {
            bins[i] = .{ .h_km = 0, .gamma = 0, .pairs = 0 };
            continue;
        };
        const v = readF64s(row) orelse {
            bins[i] = .{ .h_km = 0, .gamma = 0, .pairs = 0 };
            continue;
        };
        defer alloc.free(v);
        bins[i] = .{
            .h_km = if (v.len > 0) v[0] else 0,
            .gamma = if (v.len > 1) v[1] else 0,
            .pairs = if (v.len > 2) @intFromFloat(@max(v[2], 0)) else 0,
        };
    }
    return bins;
}

// GeoFitVariogram(aBins, nModel) -> [ model, nugget, sill, rangeKm, rss ];
// a model of -1 fits all three and answers the best
fn ring_GeoFitVariogram(p: *anyopaque) callconv(.c) void {
    const bins = readBins(p, 1) orelse return retEmpty(p);
    defer alloc.free(bins);
    const mi = gn(p, 2);
    if (mi < 0) return retVariogram(p, gi.fitBest(bins));
    const k: i64 = @intFromFloat(mi);
    if (k > 2) return retEmpty(p);
    retVariogram(p, gi.fitVariogram(bins, @enumFromInt(@as(u8, @intCast(k)))));
}

// GeoVariogramAt(aModel, nHkm) -> gamma(h)
fn ring_GeoVariogramAt(p: *anyopaque) callconv(.c) void {
    const v = readVariogram(p, 1) orelse return rn(p, 0);
    rn(p, v.gamma(gn(p, 2)));
}

// GeoKrigeField(aLonLatZ, aModel, aGrid, aRings, aBox) -> [ aEstimate,
// aVariance ], both laid out like a field's values. ONE factorisation for
// the whole grid: the left-hand side is the samples against each other and
// does not depend on where the prediction is.
fn ring_GeoKrigeField(p: *anyopaque) callconv(.c) void {
    const sm = readPoints(p, 1) orelse return retEmpty(p);
    defer alloc.free(sm);
    const n = sm.len / 3;
    // A CAP, AND A NAMED ONE. The factorisation is n^3 and every node is
    // n^2; at 1200 samples that is two seconds and 11 MB, which is the most
    // this should spend without the caller having asked for it.
    if (n < 2 or n > 1200) return retEmpty(p);
    const v = readVariogram(p, 2) orelse return retEmpty(p);
    const g = readGrid(p, 3) orelse return retEmpty(p);
    const wd: ?WindowRead = readWindow(p, 4, 5);
    defer if (wd) |x| freeRings(x.rr);

    var kr = gi.prepare(alloc, sm, v) catch return retEmpty(p);
    defer kr.deinit();
    const est = alloc.alloc(f64, g.count()) catch return retEmpty(p);
    defer alloc.free(est);
    const vr = alloc.alloc(f64, g.count()) catch return retEmpty(p);
    defer alloc.free(vr);
    for (0..g.ny) |j| {
        const lat = g.latAt(j);
        for (0..g.nx) |i| {
            const lon = g.lonAt(i);
            const k = j * g.nx + i;
            if (wd) |x| {
                if (!x.w.contains(lon, lat)) {
                    est[k] = std.math.nan(f64);
                    vr[k] = std.math.nan(f64);
                    continue;
                }
            }
            const r = kr.at(lon, lat);
            est[k] = r.estimate;
            vr[k] = r.variance;
        }
    }
    const out = R.ring_vm_api_newlist(p) orelse return;
    const el = R.ring_list_newlist(out) orelse return;
    for (est) |x| {
        if (std.math.isNan(x)) R.ring_list_addstring(el, "") else R.ring_list_adddouble(el, x);
    }
    const vl = R.ring_list_newlist(out) orelse return;
    for (vr) |x| {
        if (std.math.isNan(x)) R.ring_list_addstring(vl, "") else R.ring_list_adddouble(vl, x);
    }
    R.ring_vm_api_retlist(p, out);
}

// GeoKrigeAt(aLonLatZ, aModel, nLon, nLat) -> [ estimate, variance ]
fn ring_GeoKrigeAt(p: *anyopaque) callconv(.c) void {
    const sm = readPoints(p, 1) orelse return retEmpty(p);
    defer alloc.free(sm);
    const n = sm.len / 3;
    if (n < 2 or n > 1200) return retEmpty(p);
    const v = readVariogram(p, 2) orelse return retEmpty(p);
    var kr = gi.prepare(alloc, sm, v) catch return retEmpty(p);
    defer kr.deinit();
    const r = kr.at(gn(p, 3), gn(p, 4));
    if (std.math.isNan(r.estimate)) return retEmpty(p);
    retPair(p, r.estimate, r.variance);
}

// GeoCrossValidate(aLonLatZ, aModel) -> [ meanError, rmse ]
fn ring_GeoCrossValidate(p: *anyopaque) callconv(.c) void {
    const sm = readPoints(p, 1) orelse return retEmpty(p);
    defer alloc.free(sm);
    const n = sm.len / 3;
    if (n < 3 or n > 400) return retEmpty(p);
    const v = readVariogram(p, 2) orelse return retEmpty(p);
    var me: f64 = 0;
    var rmse: f64 = 0;
    gi.crossValidate(alloc, sm, v, &me, &rmse) catch return retEmpty(p);
    retPair(p, me, rmse);
}


// ------------------------------------------------ GE8: the ellipsoid
//
// THE ELLIPSOID CROSSES THE BRIDGE AS TWO NUMBERS, a and f, exactly as a
// projection crosses as eleven: the Ring object that owns them is the one
// source of truth, and nothing engine-side can go stale behind it. Every
// other quantity -- b, the eccentricity, the surface area -- is DERIVED on
// the far side rather than sent, so the two sides cannot disagree.
//
// Metres, degrees, and square metres. The rest of this plane speaks
// kilometres because a map does; geodesy speaks metres because a survey
// does, and the face converts rather than either side guessing.

fn readEllipsoid(p: *anyopaque, arg: c_int) gg.Ellipsoid {
    return .{ .a = gn(p, arg), .f = gn(p, arg + 1) };
}

fn ring_GeoEllipsoidCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(gg.table.len));
}

fn ring_GeoEllipsoidName(p: *anyopaque) callconv(.c) void {
    const i = argUsize(p, 1);
    if (i < 1 or i > gg.table.len) return R.ring_vm_api_retstring(p, "");
    R.ring_vm_api_retstring(p, gg.table[i - 1].name.ptr);
}

fn ring_GeoEllipsoidAt(p: *anyopaque) callconv(.c) void {
    const i = argUsize(p, 1);
    if (i < 1 or i > gg.table.len) return retEmpty(p);
    const e = gg.table[i - 1].e;
    retF64s(p, &[_]f64{
        e.a,               e.f,                 e.b(),
        e.e2(),            e.ep2(),             e.thirdFlattening(),
        e.surfaceArea(),   e.authalicRadius(),  gg.quarterMeridian(e),
    });
}

fn ring_GeoGeodesicInverse(p: *anyopaque) callconv(.c) void {
    const e = readEllipsoid(p, 1);
    const r = gg.inverse(e, gn(p, 3), gn(p, 4), gn(p, 5), gn(p, 6));
    retF64s(p, &[_]f64{ r.s12, r.azi1, r.azi2, r.m12, r.a12, @floatFromInt(r.iterations) });
}

fn ring_GeoGeodesicDirect(p: *anyopaque) callconv(.c) void {
    const e = readEllipsoid(p, 1);
    const r = gg.direct(e, gn(p, 3), gn(p, 4), gn(p, 5), gn(p, 6));
    retF64s(p, &[_]f64{ r.lat2, r.lon2, r.azi2, r.m12, r.a12 });
}

fn ring_GeoGeodesicLine(p: *anyopaque) callconv(.c) void {
    const e = readEllipsoid(p, 1);
    var n = argUsize(p, 7);
    if (n < 2) n = 2;
    if (n > 100_000) n = 100_000;
    const out = alloc.alloc(f64, n * 2) catch return retEmpty(p);
    defer alloc.free(out);
    const got = gg.line(e, gn(p, 3), gn(p, 4), gn(p, 5), gn(p, 6), n, out);
    retF64s(p, out[0 .. got * 2]);
}

fn ring_GeoRhumbInverse(p: *anyopaque) callconv(.c) void {
    const e = readEllipsoid(p, 1);
    const r = gg.rhumbInverse(e, gn(p, 3), gn(p, 4), gn(p, 5), gn(p, 6));
    retF64s(p, &[_]f64{ r.s12, r.azi12 });
}

fn ring_GeoRhumbDirect(p: *anyopaque) callconv(.c) void {
    const e = readEllipsoid(p, 1);
    const r = gg.rhumbDirect(e, gn(p, 3), gn(p, 4), gn(p, 5), gn(p, 6));
    retPair(p, r[1], r[0]); // lat, lon -- the face's order everywhere
}

fn ring_GeoRhumbLine(p: *anyopaque) callconv(.c) void {
    const e = readEllipsoid(p, 1);
    var n = argUsize(p, 7);
    if (n < 2) n = 2;
    if (n > 100_000) n = 100_000;
    const out = alloc.alloc(f64, n * 2) catch return retEmpty(p);
    defer alloc.free(out);
    const got = gg.rhumbLine(e, gn(p, 3), gn(p, 4), gn(p, 5), gn(p, 6), n, out);
    retF64s(p, out[0 .. got * 2]);
}

fn ring_GeoMeridianArc(p: *anyopaque) callconv(.c) void {
    rn(p, gg.meridianArc(readEllipsoid(p, 1), gn(p, 3)));
}
fn ring_GeoLatitudeAtArc(p: *anyopaque) callconv(.c) void {
    rn(p, gg.inverseMeridianArc(readEllipsoid(p, 1), gn(p, 3)));
}
fn ring_GeoParallelLength(p: *anyopaque) callconv(.c) void {
    rn(p, gg.parallelLength(readEllipsoid(p, 1), gn(p, 3)));
}

fn ring_GeoToEcef(p: *anyopaque) callconv(.c) void {
    const v = gg.toEcef(readEllipsoid(p, 1), gn(p, 3), gn(p, 4), gn(p, 5));
    retF64s(p, &v);
}
fn ring_GeoFromEcef(p: *anyopaque) callconv(.c) void {
    const v = gg.fromEcef(readEllipsoid(p, 1), gn(p, 3), gn(p, 4), gn(p, 5));
    retF64s(p, &v);
}
fn ring_GeoToEnu(p: *anyopaque) callconv(.c) void {
    const v = gg.toEnu(readEllipsoid(p, 1), gn(p, 3), gn(p, 4), gn(p, 5), gn(p, 6), gn(p, 7), gn(p, 8));
    retF64s(p, &v);
}
fn ring_GeoFromEnu(p: *anyopaque) callconv(.c) void {
    const v = gg.fromEnu(readEllipsoid(p, 1), gn(p, 3), gn(p, 4), gn(p, 5), gn(p, 6), gn(p, 7), gn(p, 8));
    retF64s(p, &v);
}

fn ring_GeoGeodesicArea(p: *anyopaque) callconv(.c) void {
    const e = readEllipsoid(p, 1);
    const pts = readPoints(p, 3) orelse return retEmpty(p);
    defer alloc.free(pts);
    const r = gg.polygonArea(e, pts);
    retPair(p, r.area, r.perimeter);
}


// ------------------------------------------------ GE7d: point processes
//
// A PROCESS CROSSES AS ITS KIND AND THREE NUMBERS, the same way an
// ellipsoid crosses as two and a projection as eleven: the Ring object owns
// the parameters and gives them names, and nothing engine-side can go
// stale behind it. The intensity SURFACE of an inhomogeneous process
// crosses as a grid, because a callback into the Ring VM is not a thing
// this engine does -- and GE7b's kernel density already produces exactly
// such a grid, so estimating an intensity and simulating from it is two
// calls with nothing in between.

fn readProcess(p: *anyopaque, arg: c_int) gpr.Process {
    const ki = argUsize(p, arg);
    const k: gpr.Kind = if (ki <= 6) @enumFromInt(@as(u8, @intCast(ki))) else .poisson;
    return .{ .kind = k, .a = gn(p, arg + 1), .b = gn(p, arg + 2), .c = gn(p, arg + 3) };
}

fn ring_GeoProcessCount(p: *anyopaque) callconv(.c) void {
    rn(p, 7);
}

fn ring_GeoProcessName(p: *anyopaque) callconv(.c) void {
    const i = argUsize(p, 1);
    if (i < 1 or i > 7) return R.ring_vm_api_retstring(p, "");
    const k: gpr.Kind = @enumFromInt(@as(u8, @intCast(i - 1)));
    R.ring_vm_api_retstring(p, gpr.Kind.name(k).ptr);
}

// (kind, a, b, c, rings, box, areaKm2, boxAreaKm2, gridParams, gridValues, seed, cap)
fn ring_GeoProcessGenerate(p: *anyopaque) callconv(.c) void {
    const pr = readProcess(p, 1);
    const wd = readWindow(p, 5, 6) orelse return retEmpty(p);
    defer freeRings(wd.rr);
    const g = readGrid(p, 9) orelse gf.Grid{ .lon0 = 0, .lat0 = 0, .dlon = 0, .dlat = 0, .nx = 0, .ny = 0 };
    const lam = readPoints(p, 10) orelse alloc.alloc(f64, 0) catch return retEmpty(p);
    defer alloc.free(lam);
    var cap = argUsize(p, 12);
    if (cap < 1) cap = 1;
    if (cap > 2_000_000) cap = 2_000_000;
    const out = alloc.alloc(f64, cap * 2) catch return retEmpty(p);
    defer alloc.free(out);
    const n = gpr.generate(alloc, &wd.w, pr, g, lam, gn(p, 7), gn(p, 8), argU64(p, 11), out) catch return retEmpty(p);
    retF64s(p, out[0 .. n * 2]);
}

// (kind, a, b, c, gridValues, areaKm2, boxAreaKm2)
fn ring_GeoProcessExpected(p: *anyopaque) callconv(.c) void {
    const pr = readProcess(p, 1);
    const lam = readPoints(p, 5) orelse alloc.alloc(f64, 0) catch return rn(p, 0);
    defer alloc.free(lam);
    rn(p, gpr.expectedCount(pr, lam, gn(p, 6), gn(p, 7)));
}

// (kind, a, b, c, rings, box, areaKm2, boxAreaKm2, gridParams, gridValues,
//  radii, sims, seed, stat)
fn ring_GeoProcessEnvelope(p: *anyopaque) callconv(.c) void {
    const pr = readProcess(p, 1);
    const wd = readWindow(p, 5, 6) orelse return retEmpty(p);
    defer freeRings(wd.rr);
    const g = readGrid(p, 9) orelse gf.Grid{ .lon0 = 0, .lat0 = 0, .dlon = 0, .dlat = 0, .nx = 0, .ny = 0 };
    const lam = readPoints(p, 10) orelse alloc.alloc(f64, 0) catch return retEmpty(p);
    defer alloc.free(lam);
    const radii = readPoints(p, 11) orelse return retEmpty(p);
    defer alloc.free(radii);
    const sims = argUsize(p, 12);
    const si = argUsize(p, 14);
    const stat: gpr.Stat = if (si <= 2) @enumFromInt(@as(u8, @intCast(si))) else .k;
    const out = alloc.alloc(f64, radii.len * 3) catch return retEmpty(p);
    defer alloc.free(out);
    _ = gpr.envelope(alloc, &wd.w, pr, g, lam, gn(p, 7), gn(p, 8), radii, sims, argU64(p, 13), stat, out) catch return retEmpty(p);
    retF64s(p, out);
}

fn ring_GeoProcessThin(p: *anyopaque) callconv(.c) void {
    const pts = readPoints(p, 1) orelse return retEmpty(p);
    defer alloc.free(pts);
    const out = alloc.alloc(f64, pts.len) catch return retEmpty(p);
    defer alloc.free(out);
    const n = gpr.thin(pts, gn(p, 2), argU64(p, 3), out);
    retF64s(p, out[0 .. n * 2]);
}

fn ring_GeoProcessEscapes(p: *anyopaque) callconv(.c) void {
    const obs = readPoints(p, 1) orelse return retEmpty(p);
    defer alloc.free(obs);
    const env = readPoints(p, 2) orelse return retEmpty(p);
    defer alloc.free(env);
    if (env.len < obs.len * 3) return retEmpty(p);
    const out = alloc.alloc(f64, obs.len) catch return retEmpty(p);
    defer alloc.free(out);
    gpr.escapes(obs, env, out);
    retF64s(p, out);
}

fn ring_GeoPoissonCount(p: *anyopaque) callconv(.c) void {
    var prng = std.Random.DefaultPrng.init(argU64(p, 2));
    rn(p, @floatFromInt(gpr.poissonCount(prng.random(), gn(p, 1))));
}

fn ring_GeoMaternIICeiling(p: *anyopaque) callconv(.c) void {
    rn(p, gpr.maternIIIntensity(gn(p, 1), gn(p, 2)));
}


// ------------------------------------------- GE9: the gallery's distortion
//
// A projection already crosses as eleven numbers, so these take one exactly
// as every other projection call does. What comes back is the Tissot
// indicatrix as numbers -- and, where a caller wants to DRAW it, as a ring.

fn ring_GeoDistortionAt(p: *anyopaque) callconv(.c) void {
    const pr = readProjection(p, 1) orelse return retEmpty(p);
    const d = gdi.distortionAt(&pr, gn(p, 2), gn(p, 3));
    if (!d.ok) return retEmpty(p);
    retF64s(p, &[_]f64{ d.h, d.k, d.a, d.b, d.areal, d.angular, d.crossing });
}

fn ring_GeoDistortionSummary(p: *anyopaque) callconv(.c) void {
    const pr = readProjection(p, 1) orelse return retEmpty(p);
    var nx = argUsize(p, 2);
    var ny = argUsize(p, 3);
    if (nx < 2) nx = 2;
    if (ny < 2) ny = 2;
    if (nx > 2000) nx = 2000;
    if (ny > 2000) ny = 2000;
    const s2 = gdi.summarise(&pr, nx, ny);
    retF64s(p, &[_]f64{
        s2.areal_min, s2.areal_max,    s2.areal_mean,
        s2.angular_max, s2.angular_mean, @floatFromInt(s2.sampled),
    });
}

fn ring_GeoIndicatrix(p: *anyopaque) callconv(.c) void {
    const pr = readProjection(p, 1) orelse return retEmpty(p);
    var n = argUsize(p, 5);
    if (n < 8) n = 8;
    if (n > 4096) n = 4096;
    const out = alloc.alloc(f64, n * 2) catch return retEmpty(p);
    defer alloc.free(out);
    const got = gdi.indicatrix(&pr, gn(p, 2), gn(p, 3), gn(p, 4), n, out);
    retF64s(p, out[0 .. got * 2]);
}

fn ring_GeoUtmZone(p: *anyopaque) callconv(.c) void {
    const u = gdi.utmZoneOf(gn(p, 1), gn(p, 2));
    retF64s(p, &[_]f64{
        @floatFromInt(u.zone),
        if (u.north) 1 else 0,
        u.central_meridian,
        @floatFromInt(u.band),
        gdi.utmFalseEasting(),
        gdi.utmFalseNorthing(u.north),
    });
}

fn ring_GeoUtmProjection(p: *anyopaque) callconv(.c) void {
    var z = argUsize(p, 1);
    if (z < 1) z = 1;
    if (z > 60) z = 60;
    const pr = gdi.utmProjection(@intCast(z));
    const deg = 180.0 / std.math.pi;
    retF64s(p, &[_]f64{
        @floatFromInt(@intFromEnum(pr.kind)),
        pr.rot[0] * deg, pr.rot[1] * deg, pr.rot[2] * deg,
        pr.par[0] * deg, pr.par[1] * deg,
        pr.scale,        pr.tx,           pr.ty,
        pr.clip_angle * deg, pr.precision,
    });
}

/// DOES THIS PROJECTION KEEP ITS OWN PROMISE, measured rather than declared?
/// Answers [ equalArea, conformal, equatorSymmetric ] as the ENUM claims
/// them, so a caller can hold the gallery to its word.
fn ring_GeoKindClaims(p: *anyopaque) callconv(.c) void {
    const i = argUsize(p, 1);
    const n = @typeInfo(gp.Kind).@"enum".fields.len;
    if (i < 1 or i > n) return retEmpty(p);
    const k: gp.Kind = @enumFromInt(@as(u8, @intCast(i - 1)));
    retF64s(p, &[_]f64{
        if (k.isEqualArea()) 1 else 0,
        if (k.isConformal()) 1 else 0,
        if (k.isEquatorSymmetric()) 1 else 0,
        if (k.isAzimuthal()) 1 else 0,
    });
}


// ---------------------------------------------- GE10: furniture and flow

fn ring_GeoJulianDay(p: *anyopaque) callconv(.c) void {
    rn(p, gfu.julianDay(@intFromFloat(gn(p, 1)), @intFromFloat(gn(p, 2)), @intFromFloat(gn(p, 3)), gn(p, 4)));
}

fn ring_GeoSunAt(p: *anyopaque) callconv(.c) void {
    const sx = gfu.sunAt(gn(p, 1));
    retF64s(p, &[_]f64{ sx.lat, sx.lon, sx.declination, sx.equation_of_time });
}

fn ring_GeoTerminator(p: *anyopaque) callconv(.c) void {
    const sx = gfu.Sun{ .lat = gn(p, 1), .lon = gn(p, 2), .declination = gn(p, 1), .equation_of_time = 0 };
    var n = argUsize(p, 4);
    if (n < 8) n = 8;
    if (n > 4096) n = 4096;
    const out = alloc.alloc(f64, n * 2) catch return retEmpty(p);
    defer alloc.free(out);
    const got = gfu.terminator(sx, gn(p, 3), n, out);
    retF64s(p, out[0 .. got * 2]);
}

fn ring_GeoSolarElevation(p: *anyopaque) callconv(.c) void {
    const sx = gfu.Sun{ .lat = gn(p, 1), .lon = gn(p, 2), .declination = gn(p, 1), .equation_of_time = 0 };
    rn(p, gfu.solarElevation(sx, gn(p, 3), gn(p, 4)));
}

fn ring_GeoScaleBar(p: *anyopaque) callconv(.c) void {
    const pr = readProjection(p, 1) orelse return retEmpty(p);
    const b = gfu.scaleBar(&pr, gn(p, 2), gn(p, 3), gn(p, 4), gn(p, 5), gn(p, 6), gn(p, 7), gn(p, 8));
    retF64s(p, &[_]f64{ b.km, b.pixels, b.at_lat, b.variation });
}

fn ring_GeoStreamline(p: *anyopaque) callconv(.c) void {
    const g = readGrid(p, 1) orelse return retEmpty(p);
    const u = readPoints(p, 2) orelse return retEmpty(p);
    defer alloc.free(u);
    const v = readPoints(p, 3) orelse return retEmpty(p);
    defer alloc.free(v);
    var steps = argUsize(p, 7);
    if (steps < 2) steps = 2;
    if (steps > 200_000) steps = 200_000;
    const out = alloc.alloc(f64, steps * 2) catch return retEmpty(p);
    defer alloc.free(out);
    const n = gfu.streamline(g, u, v, gn(p, 4), gn(p, 5), gn(p, 6), steps, out);
    retF64s(p, out[0 .. n * 2]);
}

fn ring_GeoVectorField(p: *anyopaque) callconv(.c) void {
    const g = readGrid(p, 1) orelse return retEmpty(p);
    const u = readPoints(p, 2) orelse return retEmpty(p);
    defer alloc.free(u);
    const v = readPoints(p, 3) orelse return retEmpty(p);
    defer alloc.free(v);
    const cap = g.nx * g.ny + 8;
    const out = alloc.alloc(f64, cap * 5) catch return retEmpty(p);
    defer alloc.free(out);
    const n = gfu.vectorField(g, u, v, argUsize(p, 4), out);
    retF64s(p, out[0 .. n * 5]);
}

const regs = [_]R.Reg{
    .{ .name = "stzenginegeohaversine", .func = ring_Haversine },
    .{ .name = "stzenginegeohaversinemiles", .func = ring_HaversineMiles },
    .{ .name = "stzenginegeobearing", .func = ring_Bearing },
    .{ .name = "stzenginegeomidpointlat", .func = ring_MidpointLat },
    .{ .name = "stzenginegeomidpointlon", .func = ring_MidpointLon },
    .{ .name = "stzenginegeodestinationlat", .func = ring_DestinationLat },
    .{ .name = "stzenginegeodestinationlon", .func = ring_DestinationLon },
    .{ .name = "stzenginegeoisvalidlat", .func = ring_IsValidLat },
    .{ .name = "stzenginegeoisvalidlon", .func = ring_IsValidLon },
    .{ .name = "stzenginegeoisvalidcoord", .func = ring_IsValidCoord },
    .{ .name = "stzenginegeokm2miles", .func = ring_KmToMiles },
    .{ .name = "stzenginegeomiles2km", .func = ring_MilesToKm },
    .{ .name = "stzenginegeorad2deg", .func = ring_RadToDeg },
    .{ .name = "stzenginegeodeg2rad", .func = ring_DegToRad },
    // GE0
    .{ .name = "stzenginegeoproject", .func = ring_GeoProject },
    .{ .name = "stzenginegeoinvert", .func = ring_GeoInvert },
    .{ .name = "stzenginegeoprojectline", .func = ring_GeoProjectLine },
    .{ .name = "stzenginegeoprojectring", .func = ring_GeoProjectRing },
    .{ .name = "stzenginegeoprojectringfilled", .func = ring_GeoProjectRingFilled },
    .{ .name = "stzenginegeoprojectpolygonfilled", .func = ring_GeoProjectPolygonFilled },
    .{ .name = "stzenginegeoholesdropped", .func = ring_GeoHolesDropped },
    .{ .name = "stzenginegeoringcontains", .func = ring_GeoRingContains },
    .{ .name = "stzenginegeograticule", .func = ring_GeoGraticule },
    .{ .name = "stzenginegeooutline", .func = ring_GeoOutline },
    .{ .name = "stzenginegeocircle", .func = ring_GeoCircle },
    .{ .name = "stzenginegeohexbin", .func = ring_GeoHexBin },
    .{ .name = "stzenginegeohexagon", .func = ring_GeoHexagon },
    .{ .name = "stzenginegeofitpoints", .func = ring_GeoFitPoints },
    .{ .name = "stzenginegeofitsphere", .func = ring_GeoFitSphere },
    .{ .name = "stzenginegeointerpolate", .func = ring_GeoInterpolate },
    .{ .name = "stzenginegeoringarea", .func = ring_GeoRingArea },
    .{ .name = "stzenginegeokindcount", .func = ring_GeoKindCount },
    .{ .name = "stzenginegeokindname", .func = ring_GeoKindName },
    .{ .name = "stzenginegeokindtraits", .func = ring_GeoKindTraits },
    // GE7a
    .{ .name = "stzenginegeonearestneighbour", .func = ring_GeoNearestNeighbour },
    .{ .name = "stzenginegeoclarkevans", .func = ring_GeoClarkEvans },
    .{ .name = "stzenginegeoringlength", .func = ring_GeoRingLength },
    .{ .name = "stzenginegeoripleyk", .func = ring_GeoRipleyK },
    .{ .name = "stzenginegeogfunction", .func = ring_GeoGFunction },
    .{ .name = "stzenginegeoffunction", .func = ring_GeoFFunction },
    .{ .name = "stzenginegeokenvelope", .func = ring_GeoKEnvelope },
    .{ .name = "stzenginegeosampleinside", .func = ring_GeoSampleInside },
    .{ .name = "stzenginegeomaterncluster", .func = ring_GeoMaternCluster },
    .{ .name = "stzenginegeohardcore", .func = ring_GeoHardCore },
    .{ .name = "stzenginegeomeancentre", .func = ring_GeoMeanCentre },
    .{ .name = "stzenginegeospatialmedian", .func = ring_GeoSpatialMedian },
    .{ .name = "stzenginegeoellipse", .func = ring_GeoEllipse },
    .{ .name = "stzenginegeoellipsering", .func = ring_GeoEllipseRing },
    // GE7b
    .{ .name = "stzenginegeogridover", .func = ring_GeoGridOver },
    .{ .name = "stzenginegeogridmask", .func = ring_GeoGridMask },
    .{ .name = "stzenginegeokerneldensity", .func = ring_GeoKernelDensity },
    .{ .name = "stzenginegeofieldstats", .func = ring_GeoFieldStats },
    .{ .name = "stzenginegeofieldat", .func = ring_GeoFieldAt },
    .{ .name = "stzenginegeocontour", .func = ring_GeoContour },
    .{ .name = "stzenginegeofieldimage", .func = ring_GeoFieldImage },
    .{ .name = "stzenginegeoreadasciigrid", .func = ring_GeoReadAsciiGrid },
    // GE7c
    .{ .name = "stzenginegeoidwfield", .func = ring_GeoIdwField },
    .{ .name = "stzenginegeovariogram", .func = ring_GeoVariogram },
    .{ .name = "stzenginegeofitvariogram", .func = ring_GeoFitVariogram },
    .{ .name = "stzenginegeovariogramat", .func = ring_GeoVariogramAt },
    .{ .name = "stzenginegeokrigefield", .func = ring_GeoKrigeField },
    .{ .name = "stzenginegeokrigeat", .func = ring_GeoKrigeAt },
    .{ .name = "stzenginegeocrossvalidate", .func = ring_GeoCrossValidate },
    // GE8
    .{ .name = "stzenginegeoellipsoidcount", .func = ring_GeoEllipsoidCount },
    .{ .name = "stzenginegeoellipsoidname", .func = ring_GeoEllipsoidName },
    .{ .name = "stzenginegeoellipsoidat", .func = ring_GeoEllipsoidAt },
    .{ .name = "stzenginegeogeodesicinverse", .func = ring_GeoGeodesicInverse },
    .{ .name = "stzenginegeogeodesicdirect", .func = ring_GeoGeodesicDirect },
    .{ .name = "stzenginegeogeodesicline", .func = ring_GeoGeodesicLine },
    .{ .name = "stzenginegeorhumbinverse", .func = ring_GeoRhumbInverse },
    .{ .name = "stzenginegeorhumbdirect", .func = ring_GeoRhumbDirect },
    .{ .name = "stzenginegeorhumbline", .func = ring_GeoRhumbLine },
    .{ .name = "stzenginegeomeridianarc", .func = ring_GeoMeridianArc },
    .{ .name = "stzenginegeolatitudeatarc", .func = ring_GeoLatitudeAtArc },
    .{ .name = "stzenginegeoparallellength", .func = ring_GeoParallelLength },
    .{ .name = "stzenginegeotoecef", .func = ring_GeoToEcef },
    .{ .name = "stzenginegeofromecef", .func = ring_GeoFromEcef },
    .{ .name = "stzenginegeotoenu", .func = ring_GeoToEnu },
    .{ .name = "stzenginegeofromenu", .func = ring_GeoFromEnu },
    .{ .name = "stzenginegeogeodesicarea", .func = ring_GeoGeodesicArea },
    // GE7d
    .{ .name = "stzenginegeoprocesscount", .func = ring_GeoProcessCount },
    .{ .name = "stzenginegeoprocessname", .func = ring_GeoProcessName },
    .{ .name = "stzenginegeoprocessgenerate", .func = ring_GeoProcessGenerate },
    .{ .name = "stzenginegeoprocessexpected", .func = ring_GeoProcessExpected },
    .{ .name = "stzenginegeoprocessenvelope", .func = ring_GeoProcessEnvelope },
    .{ .name = "stzenginegeoprocessthin", .func = ring_GeoProcessThin },
    .{ .name = "stzenginegeoprocessescapes", .func = ring_GeoProcessEscapes },
    .{ .name = "stzenginegeopoissoncount", .func = ring_GeoPoissonCount },
    .{ .name = "stzenginegeomaterniiceiling", .func = ring_GeoMaternIICeiling },
    // GE9
    .{ .name = "stzenginegeodistortionat", .func = ring_GeoDistortionAt },
    .{ .name = "stzenginegeodistortionsummary", .func = ring_GeoDistortionSummary },
    .{ .name = "stzenginegeoindicatrix", .func = ring_GeoIndicatrix },
    .{ .name = "stzenginegeoutmzone", .func = ring_GeoUtmZone },
    .{ .name = "stzenginegeoutmprojection", .func = ring_GeoUtmProjection },
    .{ .name = "stzenginegeokindclaims", .func = ring_GeoKindClaims },
    // GE10
    .{ .name = "stzenginegeojulianday", .func = ring_GeoJulianDay },
    .{ .name = "stzenginegeosunat", .func = ring_GeoSunAt },
    .{ .name = "stzenginegeoterminator", .func = ring_GeoTerminator },
    .{ .name = "stzenginegeosolarelevation", .func = ring_GeoSolarElevation },
    .{ .name = "stzenginegeoscalebar", .func = ring_GeoScaleBar },
    .{ .name = "stzenginegeostreamline", .func = ring_GeoStreamline },
    .{ .name = "stzenginegeovectorfield", .func = ring_GeoVectorField },
};

pub fn registerAll(state: *anyopaque) void {
    R.registerAll(state, &regs);
}
