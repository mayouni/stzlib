const std = @import("std");
const geo = @import("geo.zig");
const gp = @import("geo_projection.zig");
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
    .{ .name = "stzenginegeograticule", .func = ring_GeoGraticule },
    .{ .name = "stzenginegeooutline", .func = ring_GeoOutline },
    .{ .name = "stzenginegeocircle", .func = ring_GeoCircle },
    .{ .name = "stzenginegeofitpoints", .func = ring_GeoFitPoints },
    .{ .name = "stzenginegeofitsphere", .func = ring_GeoFitSphere },
    .{ .name = "stzenginegeointerpolate", .func = ring_GeoInterpolate },
    .{ .name = "stzenginegeoringarea", .func = ring_GeoRingArea },
    .{ .name = "stzenginegeokindcount", .func = ring_GeoKindCount },
    .{ .name = "stzenginegeokindname", .func = ring_GeoKindName },
    .{ .name = "stzenginegeokindtraits", .func = ring_GeoKindTraits },
};

pub fn registerAll(state: *anyopaque) void {
    R.registerAll(state, &regs);
}
