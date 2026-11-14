const process = @import("process.zig");
const R = @import("ring_api.zig");

const rn = R.ring_vm_api_retnumber;
const rs2 = R.ring_vm_api_retstring2;
const boundary = @import("boundary.zig");

fn str(p: *anyopaque, n: c_int) []const u8 {
    if (R.ring_vm_api_isstring(p, n) == 0) return "";
    return R.ring_vm_api_getstring(p, n)[0..@intCast(R.ring_vm_api_getstringsize(p, n))];
}

fn num(p: *anyopaque, n: c_int) f64 {
    if (R.ring_vm_api_isnumber(p, n) == 0) return 0;
    return R.ring_vm_api_getnumber(p, n);
}

fn id(p: *anyopaque) i64 {
    return @intFromFloat(num(p, 1));
}

fn retBool(p: *anyopaque, b: bool) void {
    rn(p, if (b) 1 else 0);
}

fn ring_ProcessPid(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(process.process_pid()));
}

fn ring_ProcessUptimeNs(p: *anyopaque) callconv(.c) void {
    rn(p, process.process_uptime_ns());
}

fn ring_ProcessUptimeMs(p: *anyopaque) callconv(.c) void {
    rn(p, process.process_uptime_ms());
}

fn ring_ProcessUptimeS(p: *anyopaque) callconv(.c) void {
    rn(p, process.process_uptime_s());
}

fn ring_ProcessArch(p: *anyopaque) callconv(.c) void {
    var buf: [64]u8 = undefined;
    const len = process.process_arch(&buf, 64);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

fn ring_ProcessOs(p: *anyopaque) callconv(.c) void {
    var buf: [64]u8 = undefined;
    const len = process.process_os(&buf, 64);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

fn ring_ProcessEndian(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(process.process_endian()));
}

fn ring_ProcessPtrSize(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(process.process_ptr_size()));
}

// --- the OS boundary (rung B1, boundary.zig) -------------------------------------------------------------------------

// StzEngineBoundaryNew(cName) -> a grant id, 0 when refused (StzEngineBoundaryError(0) says why)
fn ring_BoundaryNew(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(boundary.new(str(p, 1))));
}
fn ring_BoundaryRead(p: *anyopaque) callconv(.c) void {
    retBool(p, boundary.addRead(id(p), str(p, 2)));
}
fn ring_BoundaryWrite(p: *anyopaque) callconv(.c) void {
    retBool(p, boundary.addWrite(id(p), str(p, 2)));
}
fn ring_BoundaryNetwork(p: *anyopaque) callconv(.c) void {
    retBool(p, boundary.setNetwork(id(p), num(p, 2) != 0));
}
fn ring_BoundaryChildren(p: *anyopaque) callconv(.c) void {
    retBool(p, boundary.setChildren(id(p), @intFromFloat(num(p, 2))));
}
fn ring_BoundaryMemory(p: *anyopaque) callconv(.c) void {
    retBool(p, boundary.setMemory(id(p), @intFromFloat(num(p, 2))));
}
fn ring_BoundaryProcessor(p: *anyopaque) callconv(.c) void {
    retBool(p, boundary.setProcessor(id(p), num(p, 2)));
}
fn ring_BoundaryOutput(p: *anyopaque) callconv(.c) void {
    retBool(p, boundary.setOutput(id(p), str(p, 2), str(p, 3)));
}
// StzEngineBoundaryStart(nId, cCommandLine) -> the process id, 0 when it did not start
fn ring_BoundaryStart(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(boundary.start(id(p), str(p, 2))));
}
// StzEngineBoundaryWait(nId, nMs) -> 1 ended, 0 still running (nMs < 0 waits for ever)
fn ring_BoundaryWait(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(boundary.wait(id(p), @intFromFloat(num(p, 2)))));
}
fn ring_BoundaryEnd(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(boundary.end(id(p))));
}
fn ring_BoundaryFree(p: *anyopaque) callconv(.c) void {
    retBool(p, boundary.free(id(p)));
}
fn ring_BoundaryPid(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(boundary.pid(id(p))));
}
fn ring_BoundaryExitCode(p: *anyopaque) callconv(.c) void {
    rn(p, boundary.exitCode(id(p)));
}
fn ring_BoundaryPeakMb(p: *anyopaque) callconv(.c) void {
    rn(p, boundary.peakMb(id(p)));
}
fn ring_BoundaryWallMs(p: *anyopaque) callconv(.c) void {
    rn(p, boundary.wallMs(id(p)));
}
fn ring_BoundaryGrantMs(p: *anyopaque) callconv(.c) void {
    rn(p, boundary.grantMs(id(p)));
}
fn ring_BoundaryGranted(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(boundary.grantedCount(id(p))));
}
fn ring_BoundaryMessages(p: *anyopaque) callconv(.c) void {
    var buf: [1024]u8 = undefined;
    const got = boundary.messages(id(p), &buf);
    rs2(p, got.ptr, @intCast(got.len));
}
fn ring_BoundaryError(p: *anyopaque) callconv(.c) void {
    const e = boundary.errorText(id(p));
    rs2(p, e.ptr, @intCast(e.len));
}
// StzEngineBoundaryHasRule(cName, cPath) -> 1 the path's list names the container, 0 not, -1 unreadable
fn ring_BoundaryHasRule(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(boundary.hasRule(str(p, 1), str(p, 2))));
}
// StzEngineBoundaryRevoke(cName, cPath) -> 0, or the Windows error
fn ring_BoundaryRevoke(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(boundary.revoke(str(p, 1), str(p, 2))));
}
// StzEngineBoundaryDeleteProfile(cName) -> 0, or the HRESULT
fn ring_BoundaryDeleteProfile(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(boundary.deleteProfile(str(p, 1))));
}

pub const regs = [_]R.Reg{
    .{ .name = "stzengineboundarynew", .func = &ring_BoundaryNew },
    .{ .name = "stzengineboundaryread", .func = &ring_BoundaryRead },
    .{ .name = "stzengineboundarywrite", .func = &ring_BoundaryWrite },
    .{ .name = "stzengineboundarynetwork", .func = &ring_BoundaryNetwork },
    .{ .name = "stzengineboundarychildren", .func = &ring_BoundaryChildren },
    .{ .name = "stzengineboundarymemory", .func = &ring_BoundaryMemory },
    .{ .name = "stzengineboundaryprocessor", .func = &ring_BoundaryProcessor },
    .{ .name = "stzengineboundaryoutput", .func = &ring_BoundaryOutput },
    .{ .name = "stzengineboundarystart", .func = &ring_BoundaryStart },
    .{ .name = "stzengineboundarywait", .func = &ring_BoundaryWait },
    .{ .name = "stzengineboundaryend", .func = &ring_BoundaryEnd },
    .{ .name = "stzengineboundaryfree", .func = &ring_BoundaryFree },
    .{ .name = "stzengineboundarypid", .func = &ring_BoundaryPid },
    .{ .name = "stzengineboundaryexitcode", .func = &ring_BoundaryExitCode },
    .{ .name = "stzengineboundarypeakmb", .func = &ring_BoundaryPeakMb },
    .{ .name = "stzengineboundarywallms", .func = &ring_BoundaryWallMs },
    .{ .name = "stzengineboundarygrantms", .func = &ring_BoundaryGrantMs },
    .{ .name = "stzengineboundarygranted", .func = &ring_BoundaryGranted },
    .{ .name = "stzengineboundarymessages", .func = &ring_BoundaryMessages },
    .{ .name = "stzengineboundaryerror", .func = &ring_BoundaryError },
    .{ .name = "stzengineboundaryhasrule", .func = &ring_BoundaryHasRule },
    .{ .name = "stzengineboundaryrevoke", .func = &ring_BoundaryRevoke },
    .{ .name = "stzengineboundarydeleteprofile", .func = &ring_BoundaryDeleteProfile },
    .{ .name = "stzengineprocesspid", .func = &ring_ProcessPid },
    .{ .name = "stzengineprocessuptimens", .func = &ring_ProcessUptimeNs },
    .{ .name = "stzengineprocessuptimems", .func = &ring_ProcessUptimeMs },
    .{ .name = "stzengineprocessuptimes", .func = &ring_ProcessUptimeS },
    .{ .name = "stzengineprocessarch", .func = &ring_ProcessArch },
    .{ .name = "stzengineprocessos", .func = &ring_ProcessOs },
    .{ .name = "stzengineprocessendian", .func = &ring_ProcessEndian },
    .{ .name = "stzengineprocessptrsize", .func = &ring_ProcessPtrSize },
};

pub fn registerAll(pState: *anyopaque) void {
    // Capture the uptime baseline at DLL load, so uptime counts from process
    // start rather than the Unix epoch.
    process.process_init();
    R.registerAll(pState, &regs);
}
