const R = @import("ring_api.zig");
const mod = @import("similarity.zig");

const gn = R.ring_vm_api_getnumber;
const rn = R.ring_vm_api_retnumber;

fn ring_Cosine3(p: *anyopaque) callconv(.c) void {
    var a = [3]f64{ gn(p, 1), gn(p, 2), gn(p, 3) };
    var b = [3]f64{ gn(p, 4), gn(p, 5), gn(p, 6) };
    rn(p, mod.stz_sim_cosine(&a, &b, 3));
}

fn ring_Euclidean3(p: *anyopaque) callconv(.c) void {
    var a = [3]f64{ gn(p, 1), gn(p, 2), gn(p, 3) };
    var b = [3]f64{ gn(p, 4), gn(p, 5), gn(p, 6) };
    rn(p, mod.stz_sim_euclidean(&a, &b, 3));
}

fn ring_Manhattan3(p: *anyopaque) callconv(.c) void {
    var a = [3]f64{ gn(p, 1), gn(p, 2), gn(p, 3) };
    var b = [3]f64{ gn(p, 4), gn(p, 5), gn(p, 6) };
    rn(p, mod.stz_sim_manhattan(&a, &b, 3));
}

fn ring_DotProduct3(p: *anyopaque) callconv(.c) void {
    var a = [3]f64{ gn(p, 1), gn(p, 2), gn(p, 3) };
    var b = [3]f64{ gn(p, 4), gn(p, 5), gn(p, 6) };
    rn(p, mod.stz_sim_dot_product(&a, &b, 3));
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = "stzenginesimcosine3", .func = ring_Cosine3 },
    .{ .name = "stzenginesimeuclidean3", .func = ring_Euclidean3 },
    .{ .name = "stzenginesimmanhattan3", .func = ring_Manhattan3 },
    .{ .name = "stzenginesimdotproduct3", .func = ring_DotProduct3 },
};
