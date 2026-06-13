const fswatch = @import("fswatch.zig");
const R = @import("ring_api.zig");

const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rs2 = R.ring_vm_api_retstring2;
const rs = R.ring_vm_api_retstring;
const rn = R.ring_vm_api_retnumber;

const FSWATCH_HANDLE: [*:0]const u8 = "FsWatcher";

fn getWatcher(p: *anyopaque, n: c_int) ?*fswatch.Watcher {
    const raw = R.ring_vm_api_getcpointer(p, n, FSWATCH_HANDLE) orelse return null;
    const addr = @intFromPtr(raw);
    if (addr == 0) return null;
    return @ptrFromInt(addr);
}

const POLL_BUF_CAP: usize = 64 * 1024;
var poll_buf: [POLL_BUF_CAP]u8 = undefined;

fn ring_FsWatchStart(p: *anyopaque) callconv(.c) void {
    const path_ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const path_len: usize = @intCast(gss(p, 1));
    const w = fswatch.fswatch_start(path_ptr, path_len);
    if (w) |handle| {
        R.ring_vm_api_retcpointer(p, @ptrCast(handle), FSWATCH_HANDLE);
    } else {
        R.ring_vm_api_retcpointer(p, @ptrFromInt(0), FSWATCH_HANDLE);
    }
}

fn ring_FsWatchPoll(p: *anyopaque) callconv(.c) void {
    const w = getWatcher(p, 1);
    const n = fswatch.fswatch_poll(w, &poll_buf, POLL_BUF_CAP);
    if (n > 0) rs2(p, &poll_buf, @intCast(n)) else rs(p, @constCast(""));
}

fn ring_FsWatchStop(p: *anyopaque) callconv(.c) void {
    const w = getWatcher(p, 1);
    fswatch.fswatch_stop(w);
}

fn ring_FsWatchLastError(p: *anyopaque) callconv(.c) void {
    var buf: [512]u8 = undefined;
    const n = fswatch.fswatch_last_error(&buf, 512);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, @constCast(""));
}

const regs = [_]R.Reg{
    .{ .name = "stzenginefswatchstart", .func = ring_FsWatchStart },
    .{ .name = "stzenginefswatchpoll", .func = ring_FsWatchPoll },
    .{ .name = "stzenginefswatchstop", .func = ring_FsWatchStop },
    .{ .name = "stzenginefswatchlasterror", .func = ring_FsWatchLastError },
};

pub fn registerAll(state: *anyopaque) void {
    R.registerAll(state, &regs);
}
