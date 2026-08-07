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

/// StzEngineReactorTlsRequest(cHost, nPort, cRequest, cCertPath, cKeyPath,
/// cCaPath, nVerify) -> response bytes ("" on failure). A synchronous mTLS
/// client: presents cCertPath/cKeyPath (this node's client cert), validates
/// the peer against cCaPath when nVerify != 0. Status via TlsClientStatus.
/// NOTE: no reactor handle -- it's a standalone blocking client (its own
/// socket), separate from the Schannel curl path.
fn ring_ReactorTlsRequest(p: *anyopaque) callconv(.c) void {
    const host_ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const host_len: usize = @intCast(gss(p, 1));
    const port: u16 = @intFromFloat(gn(p, 2));
    const req_ptr: [*]const u8 = @ptrCast(gs(p, 3));
    const req_len: usize = @intCast(gss(p, 3));
    const cert_ptr: [*]const u8 = @ptrCast(gs(p, 4));
    const cert_len: usize = @intCast(gss(p, 4));
    const key_ptr: [*]const u8 = @ptrCast(gs(p, 5));
    const key_len: usize = @intCast(gss(p, 5));
    const ca_ptr: [*]const u8 = @ptrCast(gs(p, 6));
    const ca_len: usize = @intCast(gss(p, 6));
    const verify: i32 = @intFromFloat(gn(p, 7));
    const n = reactor.reactor_tls_request(host_ptr, host_len, port, req_ptr, req_len, cert_ptr, cert_len, key_ptr, key_len, ca_ptr, ca_len, verify, &tcp_body_buf, TCP_BODY_CAP);
    if (n >= 0) rs2(p, &tcp_body_buf, @intCast(n)) else rs(p, @constCast(""));
}

/// StzEngineReactorTlsClientStatus() -> last TLS-client result (0 ok, -1
/// connect, -2 handshake, -3 cert verify, -4 setup).
fn ring_ReactorTlsClientStatus(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(reactor.reactor_tls_client_status()));
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

/// StzEngineReactorListenTls(reactor, cHost, nPort, nHttpMode, cCertPath,
/// cKeyPath, cCaPath, nRequireClient) -> server id (>0) or negative error.
/// The listener terminates TLS with the given cert/key; a non-empty CA path
/// enables client-cert verification (mandatory when nRequireClient != 0).
fn ring_ReactorListenTls(p: *anyopaque) callconv(.c) void {
    const r = getReactor(p, 1);
    const host_ptr: [*]const u8 = @ptrCast(gs(p, 2));
    const host_len: usize = @intCast(gss(p, 2));
    const port: u16 = @intFromFloat(gn(p, 3));
    const http_mode: i32 = @intFromFloat(gn(p, 4));
    const cert_ptr: [*]const u8 = @ptrCast(gs(p, 5));
    const cert_len: usize = @intCast(gss(p, 5));
    const key_ptr: [*]const u8 = @ptrCast(gs(p, 6));
    const key_len: usize = @intCast(gss(p, 6));
    const ca_ptr: [*]const u8 = @ptrCast(gs(p, 7));
    const ca_len: usize = @intCast(gss(p, 7));
    const require_client: i32 = @intFromFloat(gn(p, 8));
    rn(p, @floatFromInt(reactor.reactor_listen_tls(r, host_ptr, host_len, port, http_mode, cert_ptr, cert_len, key_ptr, key_len, ca_ptr, ca_len, require_client)));
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

/// StzEngineReactorServerSetInbox(reactor, nServerId, nCap, nPolicy) ->
/// 0 or -2. Bounded inbox (D1): nPolicy 1 DropOldest, 2 DropNewest,
/// 3 Refuse (close). nCap 0 = unbounded.
fn ring_ReactorServerSetInbox(p: *anyopaque) callconv(.c) void {
    const r = getReactor(p, 1);
    const sid: u64 = @intFromFloat(gn(p, 2));
    const cap: u64 = @intFromFloat(gn(p, 3));
    const policy: i32 = @intFromFloat(gn(p, 4));
    rn(p, @floatFromInt(reactor.reactor_server_set_inbox(r, sid, cap, policy)));
}

/// StzEngineReactorServerOverflow(reactor, nServerId) -> counted
/// overflow events since birth (-1 unknown server).
fn ring_ReactorServerOverflow(p: *anyopaque) callconv(.c) void {
    const r = getReactor(p, 1);
    const sid: u64 = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(reactor.reactor_server_overflow(r, sid)));
}

/// StzEngineReactorServerPendingData(reactor, nServerId) -> data events
/// currently queued (-1 unknown server).
fn ring_ReactorServerPendingData(p: *anyopaque) callconv(.c) void {
    const r = getReactor(p, 1);
    const sid: u64 = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(reactor.reactor_server_pending_data(r, sid)));
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

/// StzEngineReactorConnect(reactor, cHost, nPort, nMode) -> channel id
/// (>0) or -1. Async dial: link-up arrives as an :accept event on
/// ServerPoll/Await, a failed dial as :closed. nMode: 0 raw, 2 STZM
/// frames. The channel then uses the same ServerWrite/Poll/Stop calls.
fn ring_ReactorConnect(p: *anyopaque) callconv(.c) void {
    const r = getReactor(p, 1);
    const host_ptr: [*]const u8 = @ptrCast(gs(p, 2));
    const host_len: usize = @intCast(gss(p, 2));
    const port: u16 = @intFromFloat(gn(p, 3));
    const mode: i32 = @intFromFloat(gn(p, 4));
    rn(p, @floatFromInt(reactor.reactor_connect(r, host_ptr, host_len, port, mode)));
}

// ── STZM serialization (distribution D0) ─────────────────────
//
// One Ring value (number/string/list, nested) crosses the boundary ONCE,
// here: pack walks the Ring value into a complete STZM frame; unpack
// parses a frame back into a Ring value. Both payload encoding candidates
// are live behind nEncoding so the D0 spike can measure them against each
// other on identical values; the loser is deleted, not kept.

const stzmw = @import("stzm.zig");

const STZM_CAP: usize = 4 * 1024 * 1024;
var stzm_buf: [STZM_CAP]u8 = undefined;
var stzm_last_status: f64 = 0; // 0 ok, -1 malformed/unsupported/overflow
var stzm_last_corr: f64 = 0;
var stzm_last_flags: f64 = 0;

const ITEMTYPE_STRING: c_uint = 1;
const ITEMTYPE_NUMBER: c_uint = 2;
const ITEMTYPE_LIST: c_uint = 4;

const PackError = error{ Overflow, Unsupported };

fn stzmPackList(e: *stzmw.Emit, enc: stzmw.Enc, pList: *anyopaque) PackError!void {
    const n: u32 = @intCast(R.ringListSize(pList));
    try e.listBegin(enc, n);
    var i: c_uint = 1;
    while (i <= n) : (i += 1) {
        const itemType = R.ring_list_gettype_gc(null, pList, i);
        if (itemType == ITEMTYPE_NUMBER) {
            const pItem = R.ring_list_getitem_gc(null, pList, i) orelse return error.Unsupported;
            try e.num(enc, R.ring_item_getnumber(pItem));
        } else if (itemType == ITEMTYPE_STRING) {
            const pItem = R.ring_list_getitem_gc(null, pList, i) orelse return error.Unsupported;
            const sPtr = R.ringItemStringPtr(pItem) orelse return error.Unsupported;
            const sLen = R.ringItemStringSize(pItem);
            try e.str(enc, sPtr[0..sLen]);
        } else if (itemType == ITEMTYPE_LIST) {
            const pSub = R.ring_list_getlist_gc(null, pList, i) orelse return error.Unsupported;
            try stzmPackList(e, enc, pSub);
        } else {
            // objects/pointers do not cross the wire -- messages are VALUES
            return error.Unsupported;
        }
    }
}

/// StzEngineStzmPack(vValue, nEncoding, nCorrelationId, nFlags) -> the
/// complete STZM frame bytes ("" on failure; see StzmLastStatus).
/// nEncoding: 0 = stzb (in-house tag+length), 1 = msgpack. The encoding
/// bit is carried in the frame flags so the receiver needs no side channel.
fn ring_StzmPack(p: *anyopaque) callconv(.c) void {
    stzm_last_status = 0;
    const enc: stzmw.Enc = if (gn(p, 2) == 1) .msgpack else .stzb;
    const corr: u64 = @intFromFloat(gn(p, 3));
    var flags: u8 = @intFromFloat(gn(p, 4));
    if (enc == .msgpack) flags |= stzmw.FLAG_MSGPACK else flags &= ~stzmw.FLAG_MSGPACK;
    var e = stzmw.Emit{ .buf = stzm_buf[stzmw.HEADER_LEN..] };
    const ok = blk: {
        if (R.ring_vm_api_isnumber(p, 1) != 0) {
            e.num(enc, gn(p, 1)) catch break :blk false;
        } else if (R.ring_vm_api_isstring(p, 1) != 0) {
            const sp: [*]const u8 = @ptrCast(gs(p, 1));
            const sn: usize = @intCast(gss(p, 1));
            e.str(enc, sp[0..sn]) catch break :blk false;
        } else if (R.ring_vm_api_islist(p, 1) != 0) {
            const pList = R.gl(p, 1) orelse break :blk false;
            stzmPackList(&e, enc, pList) catch break :blk false;
        } else break :blk false;
        break :blk true;
    };
    if (!ok) {
        stzm_last_status = -1;
        rs(p, @constCast(""));
        return;
    }
    stzmw.writeHeader(stzm_buf[0..], flags, @intCast(e.pos), corr);
    rs2(p, &stzm_buf, @intCast(stzmw.HEADER_LEN + e.pos));
}

fn stzmUnpackListInto(cur: *stzmw.Cursor, enc: stzmw.Enc, pList: *anyopaque, count: u32) stzmw.ParseError!void {
    var i: u32 = 0;
    while (i < count) : (i += 1) {
        const tok = try cur.next(enc);
        switch (tok) {
            .num => |v| R.ring_list_adddouble(pList, v),
            .str => |s| R.ring_list_addstring2(pList, s.ptr, @intCast(s.len)),
            .list => |n| {
                const pSub = R.ring_list_newlist(pList) orelse return error.Malformed;
                try stzmUnpackListInto(cur, enc, pSub, n);
            },
        }
    }
}

/// StzEngineStzmUnpack(cFrame) -> the Ring value carried by the frame
/// ("" + StzmLastStatus() = -1 on a malformed frame). Correlation id and
/// flags of the frame are readable via StzmLastCorrelation/StzmLastFlags.
fn ring_StzmUnpack(p: *anyopaque) callconv(.c) void {
    stzm_last_status = 0;
    const bp: [*]const u8 = @ptrCast(gs(p, 1));
    const bn: usize = @intCast(gss(p, 1));
    const bytes = bp[0..bn];
    const flen = stzmw.frameLen(bytes) orelse {
        stzm_last_status = -1;
        rs(p, @constCast(""));
        return;
    };
    const h = stzmw.parseHeader(bytes).?;
    stzm_last_corr = @floatFromInt(h.corr_id);
    stzm_last_flags = @floatFromInt(h.flags);
    const enc: stzmw.Enc = if (h.flags & stzmw.FLAG_MSGPACK != 0) .msgpack else .stzb;
    var cur = stzmw.Cursor{ .bytes = bytes[stzmw.HEADER_LEN..flen] };
    const tok = cur.next(enc) catch {
        stzm_last_status = -1;
        rs(p, @constCast(""));
        return;
    };
    switch (tok) {
        .num => |v| rn(p, v),
        .str => |s| rs2(p, @constCast(s.ptr), @intCast(s.len)),
        .list => |n| {
            const pList = R.ring_vm_api_newlist(p) orelse {
                stzm_last_status = -1;
                rs(p, @constCast(""));
                return;
            };
            stzmUnpackListInto(&cur, enc, pList, n) catch {
                stzm_last_status = -1;
                // the partial list is VM-owned for this call; return it
                // anyway is wrong -- report the malformed status with ""
                rs(p, @constCast(""));
                return;
            };
            R.ring_vm_api_retlist(p, pList);
        },
    }
}

/// StzEngineStzmFrameLen(cBytes) -> total length of the first complete
/// frame in cBytes, or 0 if incomplete / not a frame.
fn ring_StzmFrameLen(p: *anyopaque) callconv(.c) void {
    const bp: [*]const u8 = @ptrCast(gs(p, 1));
    const bn: usize = @intCast(gss(p, 1));
    const flen = stzmw.frameLen(bp[0..bn]) orelse 0;
    rn(p, @floatFromInt(flen));
}

/// StzEngineStzmLastStatus() -> 0 ok, -1 the last pack/unpack failed.
fn ring_StzmLastStatus(p: *anyopaque) callconv(.c) void {
    rn(p, stzm_last_status);
}

/// StzEngineStzmLastCorrelation() -> correlation id of the last unpacked frame.
fn ring_StzmLastCorrelation(p: *anyopaque) callconv(.c) void {
    rn(p, stzm_last_corr);
}

/// StzEngineStzmLastFlags() -> flags byte of the last unpacked frame.
fn ring_StzmLastFlags(p: *anyopaque) callconv(.c) void {
    rn(p, stzm_last_flags);
}

/// StzEngineStzmNetDefaults() -> [ rtt_us, msgs_per_sec, ser_ns_per_kb ]
/// -- the net.* calibration gates (OVERRIDE > FILE > DEFAULT), seeded by
/// the D0 spike. Observable from Ring so guards can assert the seed exists.
fn ring_StzmNetDefaults(p: *anyopaque) callconv(.c) void {
    const pList = R.ring_vm_api_newlist(p) orelse {
        rn(p, -1);
        return;
    };
    R.ring_list_adddouble(pList, stzmw.g_net_rtt_us.value());
    R.ring_list_adddouble(pList, stzmw.g_net_msgs_per_sec.value());
    R.ring_list_adddouble(pList, stzmw.g_net_ser_ns_per_kb.value());
    R.ring_vm_api_retlist(p, pList);
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
    .{ .name = "stzenginereactorlistentls", .func = ring_ReactorListenTls },
    .{ .name = "stzenginereactortlsrequest", .func = ring_ReactorTlsRequest },
    .{ .name = "stzenginereactortlsclientstatus", .func = ring_ReactorTlsClientStatus },
    .{ .name = "stzenginereactorserverport", .func = ring_ReactorServerPort },
    .{ .name = "stzenginereactorserverconns", .func = ring_ReactorServerConns },
    .{ .name = "stzenginereactorserverpoll", .func = ring_ReactorServerPoll },
    .{ .name = "stzenginereactorserverawait", .func = ring_ReactorServerAwait },
    .{ .name = "stzenginereactorserverlastconn", .func = ring_ReactorServerLastConn },
    .{ .name = "stzenginereactorserverlastdata", .func = ring_ReactorServerLastData },
    .{ .name = "stzenginereactorserverwrite", .func = ring_ReactorServerWrite },
    .{ .name = "stzenginereactorserversetinbox", .func = ring_ReactorServerSetInbox },
    .{ .name = "stzenginereactorserveroverflow", .func = ring_ReactorServerOverflow },
    .{ .name = "stzenginereactorserverpendingdata", .func = ring_ReactorServerPendingData },
    .{ .name = "stzenginereactorservercloseconn", .func = ring_ReactorServerCloseConn },
    .{ .name = "stzenginereactorserverstop", .func = ring_ReactorServerStop },
    .{ .name = "stzenginereactorsubmitspawn", .func = ring_ReactorSubmitSpawn },
    .{ .name = "stzenginereactorspawnawait", .func = ring_ReactorSpawnAwait },
    .{ .name = "stzenginereactorspawnpoll", .func = ring_ReactorSpawnPoll },
    .{ .name = "stzenginereactorspawnlaststatus", .func = ring_ReactorSpawnLastStatus },
    .{ .name = "stzenginereactorspawnkill", .func = ring_ReactorSpawnKill },
    .{ .name = "stzenginereactorconnect", .func = ring_ReactorConnect },
    .{ .name = "stzenginestzmpack", .func = ring_StzmPack },
    .{ .name = "stzenginestzmunpack", .func = ring_StzmUnpack },
    .{ .name = "stzenginestzmframelen", .func = ring_StzmFrameLen },
    .{ .name = "stzenginestzmlaststatus", .func = ring_StzmLastStatus },
    .{ .name = "stzenginestzmlastcorrelation", .func = ring_StzmLastCorrelation },
    .{ .name = "stzenginestzmlastflags", .func = ring_StzmLastFlags },
    .{ .name = "stzenginestzmnetdefaults", .func = ring_StzmNetDefaults },
    .{ .name = "stzenginereactorsubmitcurl", .func = ring_ReactorSubmitCurl },
    .{ .name = "stzenginereactorcurlawait", .func = ring_ReactorCurlAwait },
    .{ .name = "stzenginereactorcurlpoll", .func = ring_ReactorCurlPoll },
    .{ .name = "stzenginereactorcurllaststatus", .func = ring_ReactorCurlLastStatus },
};

pub fn registerAll(state: *anyopaque) void {
    R.registerAll(state, &regs);
}
