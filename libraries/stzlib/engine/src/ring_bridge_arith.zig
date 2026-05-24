const arith = @import("arith.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;

fn ring_ArithEval(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    var result: f64 = undefined;
    if (arith.arith_eval(ptr, len, &result) == 0) {
        rn(p, result);
    } else {
        rn(p, 0.0);
    }
}

fn ring_ArithEvalDefault(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    const default = gn(p, 2);
    rn(p, arith.arith_eval_default(ptr, len, default));
}

pub const regs = [_]R.Reg{
    .{ .name = "stzenginearitheval", .func = &ring_ArithEval },
    .{ .name = "stzenginearithevald", .func = &ring_ArithEvalDefault },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
