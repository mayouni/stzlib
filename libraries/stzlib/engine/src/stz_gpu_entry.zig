pub const gpu = @import("gpu.zig");
pub const gpu_ops = @import("gpu_ops.zig");
pub const gpu_wgsl = @import("gpu_wgsl.zig");
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
}
