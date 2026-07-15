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

/// StzEngineReactorJobState(reactor, nJobId) -> -2 not found, -1 running,
/// 0 ready. NON-draining peek (the result stays fetchable).
fn ring_ReactorJobState(p: *anyopaque) callconv(.c) void {
    const r = getReactor(p, 1);
    const id: u64 = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(reactor.reactor_job_state(r, id)));
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

// ── async process spawn ──────────────────────────────────────

/// StzEngineReactorSubmitSpawn(reactor, cCmd) -> job id. cCmd is the
/// program and args joined by '\n' (argv[0] = program).
fn ring_ReactorSubmitSpawn(p: *anyopaque) callconv(.c) void {
    const r = getReactor(p, 1);
    const cmd_ptr: [*]const u8 = @ptrCast(gs(p, 2));
    const cmd_len: usize = @intCast(gss(p, 2));
    rn(p, @floatFromInt(reactor.reactor_submit_spawn(r, cmd_ptr, cmd_len)));
}

/// StzEngineReactorSpawnAwait(reactor, nJobId, nTimeoutMs) -> child
/// stdout (empty on error/timeout). Exit code via SpawnLastStatus().
fn ring_ReactorSpawnAwait(p: *anyopaque) callconv(.c) void {
    const r = getReactor(p, 1);
    const id: u64 = @intFromFloat(gn(p, 2));
    const timeout_ms: u64 = @intFromFloat(gn(p, 3));
    const n = reactor.reactor_spawn_await(r, id, timeout_ms, &tcp_body_buf, TCP_BODY_CAP);
    if (n >= 0) rs2(p, &tcp_body_buf, @intCast(n)) else rs(p, @constCast(""));
}

/// StzEngineReactorSpawnPoll(reactor, nJobId) -> child stdout or "".
fn ring_ReactorSpawnPoll(p: *anyopaque) callconv(.c) void {
    const r = getReactor(p, 1);
    const id: u64 = @intFromFloat(gn(p, 2));
    const n = reactor.reactor_spawn_poll(r, id, &tcp_body_buf, TCP_BODY_CAP);
    if (n >= 0) rs2(p, &tcp_body_buf, @intCast(n)) else rs(p, @constCast(""));
}

/// StzEngineReactorSpawnLastStatus() -> child exit code (0 = ok).
fn ring_ReactorSpawnLastStatus(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(reactor.reactor_spawn_last_status()));
}

/// StzEngineReactorSpawnKill(reactor, nJobId, nSignum) -> 0 ok, negative
/// on error (-2 not found, -3 already exited, -4 not a spawn/no handle).
fn ring_ReactorSpawnKill(p: *anyopaque) callconv(.c) void {
    const r = getReactor(p, 1);
    const id: u64 = @intFromFloat(gn(p, 2));
    const signum: c_int = @intFromFloat(gn(p, 3));
    rn(p, @floatFromInt(reactor.reactor_spawn_kill(r, id, signum)));
}

// ── async HTTP/HTTPS (native TLS via curl/Schannel, off the loop) ──

/// StzEngineReactorSubmitCurl(reactor, nMethod, cUrl, cBody) -> job id.
/// method: 0=GET 1=POST 2=PUT 3=DELETE 4=HEAD 5=OPTIONS 6=PATCH.
fn ring_ReactorSubmitCurl(p: *anyopaque) callconv(.c) void {
    const r = getReactor(p, 1);
    const method: i32 = @intFromFloat(gn(p, 2));
    const url_ptr: [*]const u8 = @ptrCast(gs(p, 3));
    const url_len: usize = @intCast(gss(p, 3));
    const body_ptr: [*]const u8 = @ptrCast(gs(p, 4));
    const body_len: usize = @intCast(gss(p, 4));
    rn(p, @floatFromInt(reactor.reactor_submit_curl(r, method, url_ptr, url_len, body_ptr, body_len)));
}

/// StzEngineReactorCurlAwait(reactor, nJobId, nTimeoutMs) -> response
/// body (empty on error/timeout). HTTP status via CurlLastStatus().
fn ring_ReactorCurlAwait(p: *anyopaque) callconv(.c) void {
    const r = getReactor(p, 1);
    const id: u64 = @intFromFloat(gn(p, 2));
    const timeout_ms: u64 = @intFromFloat(gn(p, 3));
    const n = reactor.reactor_curl_await(r, id, timeout_ms, &tcp_body_buf, TCP_BODY_CAP);
    if (n >= 0) rs2(p, &tcp_body_buf, @intCast(n)) else rs(p, @constCast(""));
}

/// StzEngineReactorCurlPoll(reactor, nJobId) -> body or "".
fn ring_ReactorCurlPoll(p: *anyopaque) callconv(.c) void {
    const r = getReactor(p, 1);
    const id: u64 = @intFromFloat(gn(p, 2));
    const n = reactor.reactor_curl_poll(r, id, &tcp_body_buf, TCP_BODY_CAP);
    if (n >= 0) rs2(p, &tcp_body_buf, @intCast(n)) else rs(p, @constCast(""));
}

/// StzEngineReactorCurlLastStatus() -> HTTP status code (or <0 error).
fn ring_ReactorCurlLastStatus(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(reactor.reactor_curl_last_status()));
}

/// StzEngineReactorDestroy(reactor) -- stops the loop, joins the thread.
fn ring_ReactorDestroy(p: *anyopaque) callconv(.c) void {
    reactor.reactor_destroy(getReactor(p, 1));
    rn(p, 0);
}

// ── server side (listen / events / write / close / stop) ─────

// Event-data buffer for the last polled server event (an HTTP request or
// a raw stream chunk).
const SRV_BODY_CAP: usize = 4 * 1024 * 1024;
var srv_body_buf: [SRV_BODY_CAP]u8 = undefined;

/// StzEngineReactorListen(reactor, cHost, nPort, bHttpMode) -> server id
/// (>0) or a negative uv error code. Blocks briefly for the bind result.
fn ring_ReactorListen(p: *anyopaque) callconv(.c) void {
    const r = getReactor(p, 1);
    const host_ptr: [*]const u8 = @ptrCast(gs(p, 2));
    const host_len: usize = @intCast(gss(p, 2));
    const port: u16 = @intFromFloat(gn(p, 3));
    const http_mode: i32 = @intFromFloat(gn(p, 4));
    rn(p, @floatFromInt(reactor.reactor_listen(r, host_ptr, host_len, port, http_mode)));
}

/// StzEngineReactorServerPort(reactor, nServerId) -> bound port or -2.
fn ring_ReactorServerPort(p: *anyopaque) callconv(.c) void {
    const r = getReactor(p, 1);
    const sid: u64 = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(reactor.reactor_server_port(r, sid)));
}

/// StzEngineReactorServerConns(reactor, nServerId) -> live connections.
fn ring_ReactorServerConns(p: *anyopaque) callconv(.c) void {
    const r = getReactor(p, 1);
    const sid: u64 = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(reactor.reactor_server_conns(r, sid)));
}

/// StzEngineReactorServerPoll(reactor, nServerId) -> 0 none, -2 unknown,
/// -3 overflow, else event kind (1 accept, 2 data/request, 3 closed).
/// Conn id via ServerLastConn(), data via ServerLastData().
fn ring_ReactorServerPoll(p: *anyopaque) callconv(.c) void {
    const r = getReactor(p, 1);
    const sid: u64 = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(reactor.reactor_server_poll(r, sid, &srv_body_buf, SRV_BODY_CAP)));
}

/// StzEngineReactorServerAwait(reactor, nServerId, nTimeoutMs) -> same
/// codes as ServerPoll (0 = timed out with no event).
fn ring_ReactorServerAwait(p: *anyopaque) callconv(.c) void {
    const r = getReactor(p, 1);
    const sid: u64 = @intFromFloat(gn(p, 2));
    const timeout_ms: u64 = @intFromFloat(gn(p, 3));
    rn(p, @floatFromInt(reactor.reactor_server_await(r, sid, timeout_ms, &srv_body_buf, SRV_BODY_CAP)));
}

/// StzEngineReactorServerLastConn() -> conn id of the last polled event.
fn ring_ReactorServerLastConn(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(reactor.reactor_server_last_conn()));
}

/// StzEngineReactorServerLastData() -> data bytes of the last polled event.
fn ring_ReactorServerLastData(p: *anyopaque) callconv(.c) void {
    const n = reactor.reactor_server_last_len();
    if (n > 0) rs2(p, &srv_body_buf, @intCast(n)) else rs(p, @constCast(""));
}

/// StzEngineReactorServerWrite(reactor, nServerId, nConnId, cData,
/// bCloseAfter) -> 0 ok, -1 error.
fn ring_ReactorServerWrite(p: *anyopaque) callconv(.c) void {
    const r = getReactor(p, 1);
    const sid: u64 = @intFromFloat(gn(p, 2));
    const conn_id: u64 = @intFromFloat(gn(p, 3));
    const data_ptr: [*]const u8 = @ptrCast(gs(p, 4));
    const data_len: usize = @intCast(gss(p, 4));
    const close_after: i32 = @intFromFloat(gn(p, 5));
    rn(p, @floatFromInt(reactor.reactor_server_write(r, sid, conn_id, data_ptr, data_len, close_after)));
}

/// StzEngineReactorServerCloseConn(reactor, nServerId, nConnId) -> 0/-1.
fn ring_ReactorServerCloseConn(p: *anyopaque) callconv(.c) void {
    const r = getReactor(p, 1);
    const sid: u64 = @intFromFloat(gn(p, 2));
    const conn_id: u64 = @intFromFloat(gn(p, 3));
    rn(p, @floatFromInt(reactor.reactor_server_close_conn(r, sid, conn_id)));
}

/// StzEngineReactorServerStop(reactor, nServerId) -> 0/-1.
fn ring_ReactorServerStop(p: *anyopaque) callconv(.c) void {
    const r = getReactor(p, 1);
    const sid: u64 = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(reactor.reactor_server_stop(r, sid)));
}

const regs = [_]R.Reg{
    .{ .name = "stzenginereactorversion", .func = ring_ReactorVersion },
    .{ .name = "stzenginereactorselftest", .func = ring_ReactorSelfTest },
    .{ .name = "stzenginereactorcreate", .func = ring_ReactorCreate },
    .{ .name = "stzenginereactorsubmittimer", .func = ring_ReactorSubmitTimer },
    .{ .name = "stzenginereactorpoll", .func = ring_ReactorPoll },
    .{ .name = "stzenginereactorjobstate", .func = ring_ReactorJobState },
    .{ .name = "stzenginereactorawait", .func = ring_ReactorAwait },
    .{ .name = "stzenginereactorpending", .func = ring_ReactorPending },
    .{ .name = "stzenginereactorsubmittcp", .func = ring_ReactorSubmitTcp },
    .{ .name = "stzenginereactortcpawait", .func = ring_ReactorTcpAwait },
    .{ .name = "stzenginereactortcppoll", .func = ring_ReactorTcpPoll },
    .{ .name = "stzenginereactortcplaststatus", .func = ring_ReactorTcpLastStatus },
    .{ .name = "stzenginereactordestroy", .func = ring_ReactorDestroy },
    .{ .name = "stzenginereactorlisten", .func = ring_ReactorListen },
    .{ .name = "stzenginereactorserverport", .func = ring_ReactorServerPort },
    .{ .name = "stzenginereactorserverconns", .func = ring_ReactorServerConns },
    .{ .name = "stzenginereactorserverpoll", .func = ring_ReactorServerPoll },
    .{ .name = "stzenginereactorserverawait", .func = ring_ReactorServerAwait },
    .{ .name = "stzenginereactorserverlastconn", .func = ring_ReactorServerLastConn },
    .{ .name = "stzenginereactorserverlastdata", .func = ring_ReactorServerLastData },
    .{ .name = "stzenginereactorserverwrite", .func = ring_ReactorServerWrite },
    .{ .name = "stzenginereactorservercloseconn", .func = ring_ReactorServerCloseConn },
    .{ .name = "stzenginereactorserverstop", .func = ring_ReactorServerStop },
    .{ .name = "stzenginereactorsubmitspawn", .func = ring_ReactorSubmitSpawn },
    .{ .name = "stzenginereactorspawnawait", .func = ring_ReactorSpawnAwait },
    .{ .name = "stzenginereactorspawnpoll", .func = ring_ReactorSpawnPoll },
    .{ .name = "stzenginereactorspawnlaststatus", .func = ring_ReactorSpawnLastStatus },
    .{ .name = "stzenginereactorspawnkill", .func = ring_ReactorSpawnKill },
    .{ .name = "stzenginereactorsubmitcurl", .func = ring_ReactorSubmitCurl },
    .{ .name = "stzenginereactorcurlawait", .func = ring_ReactorCurlAwait },
    .{ .name = "stzenginereactorcurlpoll", .func = ring_ReactorCurlPoll },
    .{ .name = "stzenginereactorcurllaststatus", .func = ring_ReactorCurlLastStatus },
};

pub fn registerAll(state: *anyopaque) void {
    R.registerAll(state, &regs);
}
