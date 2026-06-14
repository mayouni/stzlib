const reactor = @import("reactor.zig");
const std = @import("std");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rs2 = R.ring_vm_api_retstring2;
const rs = R.ring_vm_api_retstring;
const rn = R.ring_vm_api_retnumber;

const REACTOR_HANDLE: [*:0]const u8 = "StzReactor";

// Response buffer for async TCP requests (generous for scrape/API use).
const TCP_BODY_CAP: usize = 4 * 1024 * 1024;
var tcp_body_buf: [TCP_BODY_CAP]u8 = undefined;

fn getReactor(p: *anyopaque, n: c_int) ?*reactor.Reactor {
    const raw = R.ring_vm_api_getcpointer(p, n, REACTOR_HANDLE) orelse return null;
    const addr = @intFromPtr(raw);
    if (addr == 0) return null;
    return @ptrFromInt(addr);
}

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

/// StzEngineReactorCreate() -> opaque reactor handle (loop on a thread).
fn ring_ReactorCreate(p: *anyopaque) callconv(.c) void {
    const handle = reactor.reactor_create();
    if (handle) |h| {
        R.ring_vm_api_retcpointer(p, @ptrCast(h), REACTOR_HANDLE);
    } else {
        R.ring_vm_api_retcpointer(p, @ptrFromInt(0), REACTOR_HANDLE);
    }
}

/// StzEngineReactorSubmitTimer(reactor, nDelayMs) -> job id (>0) or -1.
fn ring_ReactorSubmitTimer(p: *anyopaque) callconv(.c) void {
    const r = getReactor(p, 1);
    const delay_ms: u64 = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(reactor.reactor_submit_timer(r, delay_ms)));
}

/// StzEngineReactorPoll(reactor, nJobId) -> -2 not found, -1 running, 0 done.
fn ring_ReactorPoll(p: *anyopaque) callconv(.c) void {
    const r = getReactor(p, 1);
    const id: u64 = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(reactor.reactor_poll(r, id)));
}

/// StzEngineReactorAwait(reactor, nJobId, nTimeoutMs) -> same codes (-1 on timeout).
fn ring_ReactorAwait(p: *anyopaque) callconv(.c) void {
    const r = getReactor(p, 1);
    const id: u64 = @intFromFloat(gn(p, 2));
    const timeout_ms: u64 = @intFromFloat(gn(p, 3));
    rn(p, @floatFromInt(reactor.reactor_await(r, id, timeout_ms)));
}

/// StzEngineReactorPending(reactor) -> jobs submitted but not yet started.
fn ring_ReactorPending(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(reactor.reactor_pending(getReactor(p, 1))));
}

/// StzEngineReactorSubmitTcp(reactor, cHost, nPort, cPayload) -> job id.
fn ring_ReactorSubmitTcp(p: *anyopaque) callconv(.c) void {
    const r = getReactor(p, 1);
    const host_ptr: [*]const u8 = @ptrCast(gs(p, 2));
    const host_len: usize = @intCast(gss(p, 2));
    const port: u16 = @intFromFloat(gn(p, 3));
    const payload_ptr: [*]const u8 = @ptrCast(gs(p, 4));
    const payload_len: usize = @intCast(gss(p, 4));
    rn(p, @floatFromInt(reactor.reactor_submit_tcp_request(r, host_ptr, host_len, port, payload_ptr, payload_len)));
}

/// StzEngineReactorTcpAwait(reactor, nJobId, nTimeoutMs) -> response body
/// (empty on error/timeout). Status via StzEngineReactorTcpLastStatus().
fn ring_ReactorTcpAwait(p: *anyopaque) callconv(.c) void {
    const r = getReactor(p, 1);
    const id: u64 = @intFromFloat(gn(p, 2));
    const timeout_ms: u64 = @intFromFloat(gn(p, 3));
    const n = reactor.reactor_tcp_await(r, id, timeout_ms, &tcp_body_buf, TCP_BODY_CAP);
    if (n >= 0) rs2(p, &tcp_body_buf, @intCast(n)) else rs(p, @constCast(""));
}

/// StzEngineReactorTcpPoll(reactor, nJobId) -> response body or "" (also
/// "" while still running -- check StzEngineReactorTcpLastStatus / Poll
/// returns -1 via the status path). Non-blocking.
fn ring_ReactorTcpPoll(p: *anyopaque) callconv(.c) void {
    const r = getReactor(p, 1);
    const id: u64 = @intFromFloat(gn(p, 2));
    const n = reactor.reactor_tcp_poll(r, id, &tcp_body_buf, TCP_BODY_CAP);
    if (n >= 0) rs2(p, &tcp_body_buf, @intCast(n)) else rs(p, @constCast(""));
}

/// StzEngineReactorTcpLastStatus() -> 0 ok, negative = uv/engine error.
fn ring_ReactorTcpLastStatus(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(reactor.reactor_tcp_last_status()));
}

/// StzEngineReactorDestroy(reactor) -- stops the loop, joins the thread.
fn ring_ReactorDestroy(p: *anyopaque) callconv(.c) void {
    reactor.reactor_destroy(getReactor(p, 1));
    rn(p, 0);
}

const regs = [_]R.Reg{
    .{ .name = "stzenginereactorversion", .func = ring_ReactorVersion },
    .{ .name = "stzenginereactorselftest", .func = ring_ReactorSelfTest },
    .{ .name = "stzenginereactorcreate", .func = ring_ReactorCreate },
    .{ .name = "stzenginereactorsubmittimer", .func = ring_ReactorSubmitTimer },
    .{ .name = "stzenginereactorpoll", .func = ring_ReactorPoll },
    .{ .name = "stzenginereactorawait", .func = ring_ReactorAwait },
    .{ .name = "stzenginereactorpending", .func = ring_ReactorPending },
    .{ .name = "stzenginereactorsubmittcp", .func = ring_ReactorSubmitTcp },
    .{ .name = "stzenginereactortcpawait", .func = ring_ReactorTcpAwait },
    .{ .name = "stzenginereactortcppoll", .func = ring_ReactorTcpPoll },
    .{ .name = "stzenginereactortcplaststatus", .func = ring_ReactorTcpLastStatus },
    .{ .name = "stzenginereactordestroy", .func = ring_ReactorDestroy },
};

pub fn registerAll(state: *anyopaque) void {
    R.registerAll(state, &regs);
}
