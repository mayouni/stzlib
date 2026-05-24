const solver = @import("solver.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const rn = R.ring_vm_api_retnumber;

fn ring_Linear(p: *anyopaque) callconv(.c) void {
    rn(p, solver.solver_linear(gn(p, 1), gn(p, 2)));
}

fn ring_QuadraticDiscriminant(p: *anyopaque) callconv(.c) void {
    rn(p, solver.solver_quadratic_discriminant(gn(p, 1), gn(p, 2), gn(p, 3)));
}

fn ring_QuadraticRoot1(p: *anyopaque) callconv(.c) void {
    rn(p, solver.solver_quadratic_root1(gn(p, 1), gn(p, 2), gn(p, 3)));
}

fn ring_QuadraticRoot2(p: *anyopaque) callconv(.c) void {
    rn(p, solver.solver_quadratic_root2(gn(p, 1), gn(p, 2), gn(p, 3)));
}

fn ring_Lerp(p: *anyopaque) callconv(.c) void {
    rn(p, solver.solver_lerp(gn(p, 1), gn(p, 2), gn(p, 3)));
}

fn ring_InverseLerp(p: *anyopaque) callconv(.c) void {
    rn(p, solver.solver_inverse_lerp(gn(p, 1), gn(p, 2), gn(p, 3)));
}

fn ring_Clamp(p: *anyopaque) callconv(.c) void {
    rn(p, solver.solver_clamp(gn(p, 1), gn(p, 2), gn(p, 3)));
}

fn ring_MapRange(p: *anyopaque) callconv(.c) void {
    rn(p, solver.solver_map_range(gn(p, 1), gn(p, 2), gn(p, 3), gn(p, 4), gn(p, 5)));
}

const regs = [_]R.Reg{
    .{ .name = "stzenginesolverlinear", .func = ring_Linear },
    .{ .name = "stzenginesolverquadraticdiscriminant", .func = ring_QuadraticDiscriminant },
    .{ .name = "stzenginesolverquadraticroot1", .func = ring_QuadraticRoot1 },
    .{ .name = "stzenginesolverquadraticroot2", .func = ring_QuadraticRoot2 },
    .{ .name = "stzenginesolverlerp", .func = ring_Lerp },
    .{ .name = "stzenginesolverinverselerp", .func = ring_InverseLerp },
    .{ .name = "stzenginesolverclamp", .func = ring_Clamp },
    .{ .name = "stzenginessolvermaprange", .func = ring_MapRange },
};

pub fn registerAll(state: *anyopaque) void {
    R.registerAll(state, &regs);
}
