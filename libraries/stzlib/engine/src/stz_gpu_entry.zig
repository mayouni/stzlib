pub const gpu = @import("gpu.zig");
pub const gpu_ops = @import("gpu_ops.zig");
pub const gpu_wgsl = @import("gpu_wgsl.zig");
pub const gpu_verify = @import("gpu_verify.zig");
pub const gpu_foundry = @import("gpu_foundry.zig");
pub const gpu_fft = @import("gpu_fft.zig");
pub const gpu_surface = @import("gpu_surface.zig");
pub const ring_bridge = @import("ring_bridge_gpu.zig");

comptime {
    @export(&ringlib_init, .{ .name = "ringlib_init" });
}

fn ringlib_init(pState: ?*anyopaque) callconv(.c) void {
    if (pState) |s| ring_bridge.registerAll(s);
}

test {
    _ = gpu;
    _ = gpu_verify;
    _ = gpu_foundry;
    _ = gpu_fft;
    _ = gpu_ops;
}
