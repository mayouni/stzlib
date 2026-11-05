const testserver = @import("testserver.zig");
const R = @import("ring_api.zig");
const door = @import("seclog_door.zig");

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

// SECURITY-R18b test support: a model-shaped call from ANOTHER DLL, writing its
// record through the engine door without passing any Ring function.
// StzEngineTestSrvDoorProbe(cSubject, cWhat) -> 1 written, 0 missed
fn ring_DoorProbe(p: *anyopaque) callconv(.c) void {
    const sp: [*]const u8 = @ptrCast(R.ring_vm_api_getstring(p, 1));
    const wp: [*]const u8 = @ptrCast(R.ring_vm_api_getstring(p, 2));
    const subject = sp[0..@intCast(R.ring_vm_api_getstringsize(p, 1))];
    const what = wp[0..@intCast(R.ring_vm_api_getstringsize(p, 2))];
    rn(p, if (door.recordFact("model.call", "stzEngineDoorProbe", subject, "", what)) 1 else 0);
}

// StzEngineTestSrvDoorMissed() -> calls in this DLL whose record could not be written
fn ring_DoorMissed(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(door.missedCount()));
}

const regs = [_]R.Reg{
    .{ .name = "stzenginetestsrvdoorprobe", .func = ring_DoorProbe },
    .{ .name = "stzenginetestsrvdoormissed", .func = ring_DoorMissed },
    .{ .name = "stzenginetestserverstart", .func = ring_TestServerStart },
    .{ .name = "stzenginetestserverstop", .func = ring_TestServerStop },
};

pub fn registerAll(state: *anyopaque) void {
    R.registerAll(state, &regs);
}
