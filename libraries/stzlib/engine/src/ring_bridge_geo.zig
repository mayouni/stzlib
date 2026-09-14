const std = @import("std");
const geo = @import("geo.zig");
const gp = @import("geo_projection.zig");
const gs = @import("geo_stats.zig");
const gf = @import("geo_field.zig");
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
    if (ki < 0 or ki > 15) return null;
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
    const ki: i64 = @intFromFloat(gn(p, 1));
    if (ki < 0 or ki > 15) {
        R.ring_vm_api_retstring(p, "");
        return;
    }
    const k: gp.Kind = @enumFromInt(@as(u8, @intCast(ki)));
    R.ring_vm_api_retstring(p, k.name().ptr);
}

fn ring_GeoKindTraits(p: *anyopaque) callconv(.c) void {
    const ki: i64 = @intFromFloat(gn(p, 1));
    if (ki < 0 or ki > 15) return retEmpty(p);
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
//               nAlpha) -> an RGBA buffer of nW x nH, ready for AddImage
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
    gf.fieldImage(v, g, &pr, gn(p, 4), gn(p, 5), w, h, edges, bytes, a, img);
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
};

pub fn registerAll(state: *anyopaque) void {
    R.registerAll(state, &regs);
}
