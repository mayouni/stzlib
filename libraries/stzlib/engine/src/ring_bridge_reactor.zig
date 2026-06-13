const reactor = @import("reactor.zig");
const std = @import("std");
const R = @import("ring_api.zig");

const rs2 = R.ring_vm_api_retstring2;
const rs = R.ring_vm_api_retstring;
const rn = R.ring_vm_api_retnumber;

/// StzEngineReactorVersion() -> libuv version string.
fn ring_ReactorVersion(p: *anyopaque) callconv(.c) void {
    const v = reactor.reactor_version();
    if (v == null) {
        rs(p, @constCast(""));
        return;
    }
    const s = std.mem.span(v);
    rs2(p, @constCast(s.ptr), @intCast(s.len));
}

/// StzEngineReactorSelfTest() -> number of timer callbacks fired (1 = OK).
fn ring_ReactorSelfTest(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(reactor.reactor_selftest()));
}

const regs = [_]R.Reg{
    .{ .name = "stzenginereactorversion", .func = ring_ReactorVersion },
    .{ .name = "stzenginereactorselftest", .func = ring_ReactorSelfTest },
};

pub fn registerAll(state: *anyopaque) void {
    R.registerAll(state, &regs);
}
