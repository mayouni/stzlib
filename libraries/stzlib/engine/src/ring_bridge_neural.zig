const neural = @import("neural.zig");
const R = @import("ring_api.zig");

const rn = R.ring_vm_api_retnumber;

fn ring_NeuralSmoke(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(neural.neural_ggml_smoke()));
}

fn ring_NeuralVersion(p: *anyopaque) callconv(.c) void {
    const v: [*:0]const u8 = @ptrCast(neural.neural_ggml_version());
    R.ring_vm_api_retstring(p, v);
}

pub const regs = [_]R.Reg{
    .{ .name = "stzengineneuralsmoke", .func = &ring_NeuralSmoke },
    .{ .name = "stzengineneuralversion", .func = &ring_NeuralVersion },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
