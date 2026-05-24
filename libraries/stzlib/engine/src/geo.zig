const std = @import("std");
const math = std.math;

const EARTH_RADIUS_KM: f64 = 6371.0;
const DEG_TO_RAD: f64 = math.pi / 180.0;
const RAD_TO_DEG: f64 = 180.0 / math.pi;

// ── Distance ─────────────────────────────────────────────────

pub fn geo_haversine(lat1: f64, lon1: f64, lat2: f64, lon2: f64) callconv(.c) f64 {
    const dlat = (lat2 - lat1) * DEG_TO_RAD;
    const dlon = (lon2 - lon1) * DEG_TO_RAD;
    const rlat1 = lat1 * DEG_TO_RAD;
    const rlat2 = lat2 * DEG_TO_RAD;

    const a = math.sin(dlat / 2.0) * math.sin(dlat / 2.0) +
        math.cos(rlat1) * math.cos(rlat2) * math.sin(dlon / 2.0) * math.sin(dlon / 2.0);
    const c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a));
    return EARTH_RADIUS_KM * c;
}

pub fn geo_haversine_miles(lat1: f64, lon1: f64, lat2: f64, lon2: f64) callconv(.c) f64 {
    return geo_haversine(lat1, lon1, lat2, lon2) * 0.621371;
}

// ── Bearing ──────────────────────────────────────────────────

pub fn geo_bearing(lat1: f64, lon1: f64, lat2: f64, lon2: f64) callconv(.c) f64 {
    const rlat1 = lat1 * DEG_TO_RAD;
    const rlat2 = lat2 * DEG_TO_RAD;
    const dlon = (lon2 - lon1) * DEG_TO_RAD;

    const y = math.sin(dlon) * math.cos(rlat2);
    const x = math.cos(rlat1) * math.sin(rlat2) - math.sin(rlat1) * math.cos(rlat2) * math.cos(dlon);
    var bearing = math.atan2(y, x) * RAD_TO_DEG;
    bearing = @mod(bearing + 360.0, 360.0);
    return bearing;
}

// ── Midpoint ─────────────────────────────────────────────────

pub fn geo_midpoint_lat(lat1: f64, lon1: f64, lat2: f64, lon2: f64) callconv(.c) f64 {
    const rlat1 = lat1 * DEG_TO_RAD;
    const rlat2 = lat2 * DEG_TO_RAD;
    const dlon = (lon2 - lon1) * DEG_TO_RAD;

    const bx = math.cos(rlat2) * math.cos(dlon);
    const by = math.cos(rlat2) * math.sin(dlon);
    return math.atan2(math.sin(rlat1) + math.sin(rlat2), math.sqrt((math.cos(rlat1) + bx) * (math.cos(rlat1) + bx) + by * by)) * RAD_TO_DEG;
}

pub fn geo_midpoint_lon(lat1: f64, lon1: f64, lat2: f64, lon2: f64) callconv(.c) f64 {
    const rlat1 = lat1 * DEG_TO_RAD;
    const rlat2 = lat2 * DEG_TO_RAD;
    const rlon1 = lon1 * DEG_TO_RAD;
    const dlon = (lon2 - lon1) * DEG_TO_RAD;

    const bx = math.cos(rlat2) * math.cos(dlon);
    const by = math.cos(rlat2) * math.sin(dlon);
    _ = rlat1;
    return (rlon1 + math.atan2(by, math.cos(lat1 * DEG_TO_RAD) + bx)) * RAD_TO_DEG;
}

// ── Destination Point ────────────────────────────────────────

pub fn geo_destination_lat(lat: f64, lon: f64, bearing_deg: f64, distance_km: f64) callconv(.c) f64 {
    _ = lon;
    const rlat = lat * DEG_TO_RAD;
    const rbearing = bearing_deg * DEG_TO_RAD;
    const d = distance_km / EARTH_RADIUS_KM;

    return math.asin(math.sin(rlat) * math.cos(d) + math.cos(rlat) * math.sin(d) * math.cos(rbearing)) * RAD_TO_DEG;
}

pub fn geo_destination_lon(lat: f64, lon: f64, bearing_deg: f64, distance_km: f64) callconv(.c) f64 {
    const rlat = lat * DEG_TO_RAD;
    const rlon = lon * DEG_TO_RAD;
    const rbearing = bearing_deg * DEG_TO_RAD;
    const d = distance_km / EARTH_RADIUS_KM;

    const dest_lat = math.asin(math.sin(rlat) * math.cos(d) + math.cos(rlat) * math.sin(d) * math.cos(rbearing));
    return (rlon + math.atan2(math.sin(rbearing) * math.sin(d) * math.cos(rlat), math.cos(d) - math.sin(rlat) * math.sin(dest_lat))) * RAD_TO_DEG;
}

// ── Coordinate Validation ────────────────────────────────────

pub fn geo_is_valid_lat(lat: f64) callconv(.c) i32 {
    return if (lat >= -90.0 and lat <= 90.0) 1 else 0;
}

pub fn geo_is_valid_lon(lon: f64) callconv(.c) i32 {
    return if (lon >= -180.0 and lon <= 180.0) 1 else 0;
}

pub fn geo_is_valid_coord(lat: f64, lon: f64) callconv(.c) i32 {
    return if (geo_is_valid_lat(lat) == 1 and geo_is_valid_lon(lon) == 1) 1 else 0;
}

// ── Unit Conversion ──────────────────────────────────────────

pub fn geo_km_to_miles(km: f64) callconv(.c) f64 {
    return km * 0.621371;
}

pub fn geo_miles_to_km(miles: f64) callconv(.c) f64 {
    return miles / 0.621371;
}

pub fn geo_deg_to_rad(deg: f64) callconv(.c) f64 {
    return deg * DEG_TO_RAD;
}

pub fn geo_rad_to_deg(rad: f64) callconv(.c) f64 {
    return rad * RAD_TO_DEG;
}

// ── C ABI exports ────────────────────────────────────────────

pub export fn stz_geo_haversine(a1: f64, o1: f64, a2: f64, o2: f64) callconv(.c) f64 { return geo_haversine(a1, o1, a2, o2); }
pub export fn stz_geo_haversine_miles(a1: f64, o1: f64, a2: f64, o2: f64) callconv(.c) f64 { return geo_haversine_miles(a1, o1, a2, o2); }
pub export fn stz_geo_bearing(a1: f64, o1: f64, a2: f64, o2: f64) callconv(.c) f64 { return geo_bearing(a1, o1, a2, o2); }
pub export fn stz_geo_midpoint_lat(a1: f64, o1: f64, a2: f64, o2: f64) callconv(.c) f64 { return geo_midpoint_lat(a1, o1, a2, o2); }
pub export fn stz_geo_midpoint_lon(a1: f64, o1: f64, a2: f64, o2: f64) callconv(.c) f64 { return geo_midpoint_lon(a1, o1, a2, o2); }
pub export fn stz_geo_destination_lat(a: f64, o: f64, b: f64, d: f64) callconv(.c) f64 { return geo_destination_lat(a, o, b, d); }
pub export fn stz_geo_destination_lon(a: f64, o: f64, b: f64, d: f64) callconv(.c) f64 { return geo_destination_lon(a, o, b, d); }
pub export fn stz_geo_is_valid_lat(a: f64) callconv(.c) i32 { return geo_is_valid_lat(a); }
pub export fn stz_geo_is_valid_lon(o: f64) callconv(.c) i32 { return geo_is_valid_lon(o); }
pub export fn stz_geo_is_valid_coord(a: f64, o: f64) callconv(.c) i32 { return geo_is_valid_coord(a, o); }
pub export fn stz_geo_km_to_miles(k: f64) callconv(.c) f64 { return geo_km_to_miles(k); }
pub export fn stz_geo_miles_to_km(m: f64) callconv(.c) f64 { return geo_miles_to_km(m); }
pub export fn stz_geo_deg_to_rad(d: f64) callconv(.c) f64 { return geo_deg_to_rad(d); }
pub export fn stz_geo_rad_to_deg(r: f64) callconv(.c) f64 { return geo_rad_to_deg(r); }

// ── Tests ────────────────────────────────────────────────────

test "geo: haversine London to Paris" {
    const dist = geo_haversine(51.5074, -0.1278, 48.8566, 2.3522);
    try std.testing.expect(dist > 340.0 and dist < 345.0);
}

test "geo: haversine same point" {
    const dist = geo_haversine(13.5117, 2.1251, 13.5117, 2.1251);
    try std.testing.expectApproxEqAbs(@as(f64, 0.0), dist, 0.001);
}

test "geo: haversine miles" {
    const km = geo_haversine(51.5074, -0.1278, 48.8566, 2.3522);
    const miles = geo_haversine_miles(51.5074, -0.1278, 48.8566, 2.3522);
    try std.testing.expectApproxEqAbs(km * 0.621371, miles, 0.01);
}

test "geo: bearing" {
    const b = geo_bearing(51.5074, -0.1278, 48.8566, 2.3522);
    try std.testing.expect(b > 140.0 and b < 160.0);
}

test "geo: midpoint" {
    const mid_lat = geo_midpoint_lat(0.0, 0.0, 0.0, 10.0);
    const mid_lon = geo_midpoint_lon(0.0, 0.0, 0.0, 10.0);
    try std.testing.expectApproxEqAbs(@as(f64, 0.0), mid_lat, 0.01);
    try std.testing.expectApproxEqAbs(@as(f64, 5.0), mid_lon, 0.01);
}

test "geo: coordinate validation" {
    try std.testing.expectEqual(@as(i32, 1), geo_is_valid_lat(45.0));
    try std.testing.expectEqual(@as(i32, 0), geo_is_valid_lat(91.0));
    try std.testing.expectEqual(@as(i32, 1), geo_is_valid_lon(-180.0));
    try std.testing.expectEqual(@as(i32, 0), geo_is_valid_lon(181.0));
    try std.testing.expectEqual(@as(i32, 1), geo_is_valid_coord(13.5117, 2.1251));
}

test "geo: unit conversion" {
    try std.testing.expectApproxEqAbs(@as(f64, 1.0), geo_km_to_miles(geo_miles_to_km(1.0)), 0.001);
    try std.testing.expectApproxEqAbs(math.pi, geo_deg_to_rad(180.0), 0.001);
    try std.testing.expectApproxEqAbs(@as(f64, 180.0), geo_rad_to_deg(math.pi), 0.001);
}

test "geo: destination point" {
    const lat = geo_destination_lat(13.5117, 2.1251, 0.0, 100.0);
    try std.testing.expect(lat > 13.5117);
    try std.testing.expect(lat < 15.0);
}
