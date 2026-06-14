const testserver = @import("testserver.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const rn = R.ring_vm_api_retnumber;

/// StzEngineTestServerStart(nPort) -> actual bound port (0 = ephemeral), or -1.
fn ring_TestServerStart(p: *anyopaque) callconv(.c) void {
    const port: u16 = @intFromFloat(gn(p, 1));
    rn(p, @floatFromInt(testserver.server_start(port)));
}

/// StzEngineTestServerStop()
fn ring_TestServerStop(p: *anyopaque) callconv(.c) void {
    testserver.server_stop();
    rn(p, 0);
}

const regs = [_]R.Reg{
    .{ .name = "stzenginetestserverstart", .func = ring_TestServerStart },
    .{ .name = "stzenginetestserverstop", .func = ring_TestServerStop },
};

pub fn registerAll(state: *anyopaque) void {
    R.registerAll(state, &regs);
}
