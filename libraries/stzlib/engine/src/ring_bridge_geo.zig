const geo = @import("geo.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const rn = R.ring_vm_api_retnumber;

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
};

pub fn registerAll(state: *anyopaque) void {
    R.registerAll(state, &regs);
}
