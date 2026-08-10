// Ring bridge for stz_audiodev -- the per-OS device tier (SN1).
//
// Deliberately small, like ring_bridge_window.zig and for the same reason:
// this DLL owns exactly one thing the portable engine cannot own, and SN1's
// share of it is only "what devices are there". The device SINK is SN3.
//
// Device INDICES are 1-based on the Ring side and 0-based in the engine,
// translated here.
const std = @import("std");
const dev = @import("audiodev.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const rn = R.ring_vm_api_retnumber;

fn ring_IsAvailable(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(dev.isAvailable()));
}

fn ring_LastError(p: *anyopaque) callconv(.c) void {
    const e = dev.lastError();
    R.ring_vm_api_retstring2(p, e.ptr, @intCast(e.len));
}

fn ring_BackendName(p: *anyopaque) callconv(.c) void {
    const b = dev.backendName();
    R.ring_vm_api_retstring2(p, b.ptr, @intCast(b.len));
}

fn ring_Refresh(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(dev.refresh()));
}

fn ring_Count(p: *anyopaque) callconv(.c) void {
    rn(p, dev.deviceCount(@intFromFloat(gn(p, 1))));
}

fn ring_Name(p: *anyopaque) callconv(.c) void {
    const i = gn(p, 2);
    if (i < 1) {
        R.ring_vm_api_retstring2(p, "", 0);
        return;
    }
    const n = dev.deviceName(@intFromFloat(gn(p, 1)), @intFromFloat(i - 1));
    R.ring_vm_api_retstring2(p, n.ptr, @intCast(n.len));
}

/// 1-based on the way out, and -1 stays -1: "there is no default" is a real
/// answer and must not be confused with "device 1".
fn ring_DefaultIndex(p: *anyopaque) callconv(.c) void {
    const d = dev.defaultIndex(@intFromFloat(gn(p, 1)));
    rn(p, if (d < 0) -1 else d + 1);
}

fn ring_Counter(p: *anyopaque) callconv(.c) void {
    rn(p, dev.counter(@intFromFloat(gn(p, 1))));
}

fn ring_CountersReset(p: *anyopaque) callconv(.c) void {
    dev.countersReset();
    rn(p, 1);
}

fn ring_Shutdown(p: *anyopaque) callconv(.c) void {
    dev.shutdown();
    rn(p, 1);
}

pub const regs = [_]R.Reg{
    .{ .name = "stzengineaudiodevisavailable", .func = &ring_IsAvailable },
    .{ .name = "stzengineaudiodevlasterror", .func = &ring_LastError },
    .{ .name = "stzengineaudiodevbackendname", .func = &ring_BackendName },
    .{ .name = "stzengineaudiodevrefresh", .func = &ring_Refresh },
    .{ .name = "stzengineaudiodevcount", .func = &ring_Count },
    .{ .name = "stzengineaudiodevname", .func = &ring_Name },
    .{ .name = "stzengineaudiodevdefaultindex", .func = &ring_DefaultIndex },
    .{ .name = "stzengineaudiodevcounter", .func = &ring_Counter },
    .{ .name = "stzengineaudiodevcountersreset", .func = &ring_CountersReset },
    .{ .name = "stzengineaudiodevshutdown", .func = &ring_Shutdown },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
