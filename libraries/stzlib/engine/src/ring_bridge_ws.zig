const ws = @import("ws.zig");
const echo = @import("ws_echo.zig");
const srv = @import("ws_server.zig");
const R = @import("ring_api.zig");

const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const gn = R.ring_vm_api_getnumber;
const rs2 = R.ring_vm_api_retstring2;
const rs = R.ring_vm_api_retstring;
const rn = R.ring_vm_api_retnumber;

// A Ring number outside a parameter's type must never stop the host
// (SUBSTRATE-INPUT-01): every number read here is clamped first.
fn clampU32(x: f64) u32 {
    if (!(x > 0)) return 0;
    if (x >= 4294967295.0) return 4294967295;
    return @intFromFloat(x);
}
fn clampU16(x: f64) u16 {
    if (!(x > 0)) return 0;
    if (x >= 65535.0) return 65535;
    return @intFromFloat(x);
}
fn clampI32(x: f64) i32 {
    if (x != x) return 0;
    if (x <= -2147483648.0) return -2147483648;
    if (x >= 2147483647.0) return 2147483647;
    return @intFromFloat(x);
}
fn clampU64(x: f64) u64 {
    if (!(x > 0)) return 0;
    if (x >= 18446744073709551615.0) return 18446744073709551615;
    return @intFromFloat(x);
}

fn getClient(p: *anyopaque, n: c_int) ?*ws.Client {
    const raw = R.getHandleOrRaise(p, n, "WebSocket client") orelse return null;
    return @ptrCast(@alignCast(raw));
}

fn str(p: *anyopaque, n: c_int) []const u8 {
    const ptr: [*]const u8 = @ptrCast(gs(p, n));
    const len: usize = @intCast(gss(p, n));
    return ptr[0..len];
}

fn retBytes(p: *anyopaque, bytes: []const u8) void {
    if (bytes.len > 0) rs2(p, bytes.ptr, @intCast(bytes.len)) else rs(p, @constCast(""));
}

// ── client ──

fn ring_WsNew(p: *anyopaque) callconv(.c) void {
    if (ws.ws_client_new()) |c| R.retHandleOnce(p, @ptrCast(c)) else rn(p, 0);
}

fn ring_WsFree(p: *anyopaque) callconv(.c) void {
    const c = getClient(p, 1);
    R.releaseParam(p, 1); // every copy of this id goes stale before the memory is freed (R16)
    ws.ws_client_free(c);
}

fn ring_WsSetMaxMessage(p: *anyopaque) callconv(.c) void {
    ws.ws_set_max_message(getClient(p, 1), clampU64(gn(p, 2)));
}
fn ring_WsSetConnectTimeout(p: *anyopaque) callconv(.c) void {
    ws.ws_set_connect_timeout(getClient(p, 1), clampU32(gn(p, 2)));
}
fn ring_WsSetCloseWait(p: *anyopaque) callconv(.c) void {
    ws.ws_set_close_wait(getClient(p, 1), clampU32(gn(p, 2)));
}
fn ring_WsSetSubprotocols(p: *anyopaque) callconv(.c) void {
    const s = str(p, 2);
    ws.ws_set_subprotocols(getClient(p, 1), s.ptr, s.len);
}
fn ring_WsSetHeaders(p: *anyopaque) callconv(.c) void {
    const s = str(p, 2);
    ws.ws_set_headers(getClient(p, 1), s.ptr, s.len);
}
fn ring_WsSetCaFile(p: *anyopaque) callconv(.c) void {
    const s = str(p, 2);
    ws.ws_set_ca_file(getClient(p, 1), s.ptr, s.len);
}
fn ring_WsSetInsecure(p: *anyopaque) callconv(.c) void {
    ws.ws_set_insecure(getClient(p, 1), clampI32(gn(p, 2)));
}

fn ring_WsSetCompression(p: *anyopaque) callconv(.c) void {
    ws.ws_set_compression(getClient(p, 1), clampI32(gn(p, 2)));
}
fn ring_WsCompressionActive(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ws.ws_compression_active(getClient(p, 1))));
}
fn ring_WsLastWireIn(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ws.ws_last_wire_in(getClient(p, 1))));
}
fn ring_WsLastWireOut(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ws.ws_last_wire_out(getClient(p, 1))));
}
fn ring_WsServerSetCompression(p: *anyopaque) callconv(.c) void {
    srv.ws_server_set_compression(getServer(p, 1), clampI32(gn(p, 2)));
}

fn ring_WsConnect(p: *anyopaque) callconv(.c) void {
    const u = str(p, 2);
    rn(p, @floatFromInt(ws.ws_connect(getClient(p, 1), u.ptr, u.len)));
}

fn ring_WsSend(p: *anyopaque) callconv(.c) void {
    const d = str(p, 3);
    const op: u8 = @intCast(@min(clampU32(gn(p, 2)), 15));
    rn(p, @floatFromInt(ws.ws_send(getClient(p, 1), op, d.ptr, d.len)));
}

fn ring_WsSendFragmented(p: *anyopaque) callconv(.c) void {
    const d = str(p, 3);
    const op: u8 = @intCast(@min(clampU32(gn(p, 2)), 15));
    rn(p, @floatFromInt(ws.ws_send_fragmented(getClient(p, 1), op, d.ptr, d.len, clampU32(gn(p, 4)))));
}

fn ring_WsPing(p: *anyopaque) callconv(.c) void {
    const d = str(p, 2);
    rn(p, @floatFromInt(ws.ws_ping(getClient(p, 1), d.ptr, d.len)));
}

fn ring_WsRecv(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ws.ws_recv(getClient(p, 1), clampI32(gn(p, 2)))));
}

fn ring_WsLastPayload(p: *anyopaque) callconv(.c) void {
    const c = getClient(p, 1);
    retBytes(p, ws.ws_last_payload_ptr(c)[0..ws.ws_last_payload_len(c)]);
}

fn ring_WsLastKind(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ws.ws_last_kind(getClient(p, 1))));
}

fn ring_WsClose(p: *anyopaque) callconv(.c) void {
    const r = str(p, 3);
    rn(p, @floatFromInt(ws.ws_close(getClient(p, 1), clampU16(gn(p, 2)), r.ptr, r.len)));
}

fn ring_WsIsOpen(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ws.ws_is_open(getClient(p, 1))));
}
fn ring_WsCloseCode(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ws.ws_close_code(getClient(p, 1))));
}
fn ring_WsCloseReason(p: *anyopaque) callconv(.c) void {
    const c = getClient(p, 1);
    retBytes(p, ws.ws_close_reason_ptr(c)[0..ws.ws_close_reason_len(c)]);
}
fn ring_WsCloseByPeer(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ws.ws_close_by_peer(getClient(p, 1))));
}
fn ring_WsCloseHandshakeDone(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ws.ws_close_handshake_done(getClient(p, 1))));
}
fn ring_WsSubprotocol(p: *anyopaque) callconv(.c) void {
    const c = getClient(p, 1);
    retBytes(p, ws.ws_subprotocol_ptr(c)[0..ws.ws_subprotocol_len(c)]);
}
fn ring_WsLastError(p: *anyopaque) callconv(.c) void {
    const c = getClient(p, 1);
    retBytes(p, ws.ws_last_error_ptr(c)[0..ws.ws_last_error_len(c)]);
}
fn ring_WsPingsReceived(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ws.ws_pings_received(getClient(p, 1))));
}
fn ring_WsPongsSent(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ws.ws_pongs_sent(getClient(p, 1))));
}
fn ring_WsFramesSent(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ws.ws_frames_sent(getClient(p, 1))));
}

// ── what a server learned from the request, and the role ──

fn ring_WsRequestTarget(p: *anyopaque) callconv(.c) void {
    const c = getClient(p, 1);
    retBytes(p, ws.ws_request_target_ptr(c)[0..ws.ws_request_target_len(c)]);
}
fn ring_WsRequestHeader(p: *anyopaque) callconv(.c) void {
    const c = getClient(p, 1);
    const name = str(p, 2);
    const n = ws.ws_request_header(c, name.ptr, name.len);
    retBytes(p, ws.ws_scratch_ptr(c)[0..n]);
}
fn ring_WsIsServerSide(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ws.ws_is_server_side(getClient(p, 1))));
}

// ── server ──

fn getServer(p: *anyopaque, n: c_int) ?*srv.Server {
    const raw = R.getHandleOrRaise(p, n, "WebSocket server") orelse return null;
    return @ptrCast(@alignCast(raw));
}

fn ring_WsServerListen(p: *anyopaque) callconv(.c) void {
    const host = str(p, 1);
    const port = clampU16(gn(p, 2));
    const cert = if (R.ring_vm_api_paracount(p) >= 3) str(p, 3) else "";
    const key = if (R.ring_vm_api_paracount(p) >= 4) str(p, 4) else "";
    if (srv.ws_server_listen(host.ptr, host.len, port, cert.ptr, cert.len, key.ptr, key.len)) |s| {
        R.retHandleOnce(p, @ptrCast(s));
    } else rn(p, 0);
}
fn ring_WsServerClose(p: *anyopaque) callconv(.c) void {
    const s = getServer(p, 1);
    R.releaseParam(p, 1);
    srv.ws_server_close(s);
}
fn ring_WsServerAccept(p: *anyopaque) callconv(.c) void {
    if (srv.ws_server_accept(getServer(p, 1), clampI32(gn(p, 2)))) |c| {
        R.retHandleOnce(p, @ptrCast(c));
    } else rn(p, 0);
}
fn ring_WsServerBeginAccept(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(srv.ws_server_begin_accept(getServer(p, 1), clampI32(gn(p, 2)))));
}
fn ring_WsServerEndAccept(p: *anyopaque) callconv(.c) void {
    if (srv.ws_server_end_accept(getServer(p, 1))) |c| {
        R.retHandleOnce(p, @ptrCast(c));
    } else rn(p, 0);
}
fn ring_WsServerPort(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(srv.ws_server_port(getServer(p, 1))));
}
fn ring_WsServerSetMaxMessage(p: *anyopaque) callconv(.c) void {
    srv.ws_server_set_max_message(getServer(p, 1), clampU64(gn(p, 2)));
}
fn ring_WsServerSetHandshakeTimeout(p: *anyopaque) callconv(.c) void {
    srv.ws_server_set_handshake_timeout(getServer(p, 1), clampU32(gn(p, 2)));
}
fn ring_WsServerSetCloseWait(p: *anyopaque) callconv(.c) void {
    srv.ws_server_set_close_wait(getServer(p, 1), clampU32(gn(p, 2)));
}
fn ring_WsServerSetSubprotocols(p: *anyopaque) callconv(.c) void {
    const v = str(p, 2);
    srv.ws_server_set_subprotocols(getServer(p, 1), v.ptr, v.len);
}
fn ring_WsServerSetOrigins(p: *anyopaque) callconv(.c) void {
    const v = str(p, 2);
    srv.ws_server_set_origins(getServer(p, 1), v.ptr, v.len);
}
fn ring_WsServerTimedOut(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(srv.ws_server_timed_out(getServer(p, 1))));
}
fn ring_WsServerAccepted(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(srv.ws_server_accepted(getServer(p, 1))));
}
fn ring_WsServerRefused(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(srv.ws_server_refused(getServer(p, 1))));
}
fn ring_WsServerLastError(p: *anyopaque) callconv(.c) void {
    const s = getServer(p, 1);
    retBytes(p, srv.ws_server_last_error_ptr(s)[0..srv.ws_server_last_error_len(s)]);
}

// ── bytes helpers (binary payloads across the boundary) ──

fn ring_WsBytesEqual(p: *anyopaque) callconv(.c) void {
    const a = str(p, 1);
    const b = str(p, 2);
    rn(p, @floatFromInt(ws.ws_bytes_equal(a.ptr, a.len, b.ptr, b.len)));
}

/// A deterministic pattern of n bytes covering every value (test support).
fn ring_WsPattern(p: *anyopaque) callconv(.c) void {
    const n: usize = @intCast(@min(clampU64(gn(p, 1)), 256 * 1024 * 1024));
    const seed = if (R.ring_vm_api_paracount(p) >= 2) clampU32(gn(p, 2)) else 1;
    const buf = std.heap.c_allocator.alloc(u8, n) catch {
        rs(p, @constCast(""));
        return;
    };
    defer std.heap.c_allocator.free(buf);
    ws.ws_pattern(buf.ptr, buf.len, seed);
    retBytes(p, buf);
}

/// A list of numbers 0..255 as a byte string, in one call (SendBinary of a list).
fn ring_WsBytesFromList(p: *anyopaque) callconv(.c) void {
    if (R.il(p, 1) == 0) {
        rs(p, @constCast(""));
        return;
    }
    const list = R.gl(p, 1) orelse {
        rs(p, @constCast(""));
        return;
    };
    const n: usize = @intCast(R.ringListSize(list));
    const buf = std.heap.c_allocator.alloc(u8, n) catch {
        rs(p, @constCast(""));
        return;
    };
    defer std.heap.c_allocator.free(buf);
    var i: usize = 0;
    while (i < n) : (i += 1) {
        const item = R.ring_list_getitem_gc(null, list, @intCast(i + 1)) orelse {
            buf[i] = 0;
            continue;
        };
        const v = R.ring_item_getnumber(item);
        buf[i] = if (v >= 0 and v <= 255) @intFromFloat(v) else 0;
    }
    retBytes(p, buf);
}

// ── echo server (test support) ──

fn ring_WsEchoStart(p: *anyopaque) callconv(.c) void {
    const port = clampU16(gn(p, 1));
    const use_tls: i32 = if (R.ring_vm_api_paracount(p) >= 2) clampI32(gn(p, 2)) else 0;
    const cert = if (R.ring_vm_api_paracount(p) >= 3) str(p, 3) else "";
    const key = if (R.ring_vm_api_paracount(p) >= 4) str(p, 4) else "";
    rn(p, @floatFromInt(echo.ws_echo_start(port, use_tls, cert.ptr, cert.len, key.ptr, key.len)));
}
fn ring_WsEchoStop(p: *anyopaque) callconv(.c) void {
    echo.ws_echo_stop();
    rn(p, 1);
}
fn ring_WsEchoSetHandshakeMode(p: *anyopaque) callconv(.c) void {
    echo.ws_echo_set_handshake_mode(clampI32(gn(p, 1)));
}
fn ring_WsEchoConnections(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(echo.ws_echo_connections()));
}
fn ring_WsEchoMessages(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(echo.ws_echo_messages()));
}
fn ring_WsEchoPings(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(echo.ws_echo_pings()));
}
fn ring_WsEchoPongs(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(echo.ws_echo_pongs()));
}
fn ring_WsEchoResetCounters(p: *anyopaque) callconv(.c) void {
    echo.ws_echo_reset_counters();
    rn(p, 1);
}
fn ring_WsEchoLastError(p: *anyopaque) callconv(.c) void {
    var buf: [256]u8 = undefined;
    const n = echo.ws_echo_last_error(&buf, buf.len);
    retBytes(p, buf[0..@intCast(n)]);
}

const std = @import("std");

const regs = [_]R.Reg{
    .{ .name = "stzenginewsnew", .func = ring_WsNew },
    .{ .name = "stzenginewsfree", .func = ring_WsFree },
    .{ .name = "stzenginewssetmaxmessage", .func = ring_WsSetMaxMessage },
    .{ .name = "stzenginewssetconnecttimeout", .func = ring_WsSetConnectTimeout },
    .{ .name = "stzenginewssetclosewait", .func = ring_WsSetCloseWait },
    .{ .name = "stzenginewssetsubprotocols", .func = ring_WsSetSubprotocols },
    .{ .name = "stzenginewssetheaders", .func = ring_WsSetHeaders },
    .{ .name = "stzenginewssetcafile", .func = ring_WsSetCaFile },
    .{ .name = "stzenginewssetinsecure", .func = ring_WsSetInsecure },
    .{ .name = "stzenginewssetcompression", .func = ring_WsSetCompression },
    .{ .name = "stzenginewscompressionactive", .func = ring_WsCompressionActive },
    .{ .name = "stzenginewslastwirein", .func = ring_WsLastWireIn },
    .{ .name = "stzenginewslastwireout", .func = ring_WsLastWireOut },
    .{ .name = "stzenginewsserversetcompression", .func = ring_WsServerSetCompression },
    .{ .name = "stzenginewsconnect", .func = ring_WsConnect },
    .{ .name = "stzenginewssend", .func = ring_WsSend },
    .{ .name = "stzenginewssendfragmented", .func = ring_WsSendFragmented },
    .{ .name = "stzenginewsping", .func = ring_WsPing },
    .{ .name = "stzenginewsrecv", .func = ring_WsRecv },
    .{ .name = "stzenginewslastpayload", .func = ring_WsLastPayload },
    .{ .name = "stzenginewslastkind", .func = ring_WsLastKind },
    .{ .name = "stzenginewsclose", .func = ring_WsClose },
    .{ .name = "stzenginewsisopen", .func = ring_WsIsOpen },
    .{ .name = "stzenginewsclosecode", .func = ring_WsCloseCode },
    .{ .name = "stzenginewsclosereason", .func = ring_WsCloseReason },
    .{ .name = "stzenginewsclosebypeer", .func = ring_WsCloseByPeer },
    .{ .name = "stzenginewsclosehandshakedone", .func = ring_WsCloseHandshakeDone },
    .{ .name = "stzenginewssubprotocol", .func = ring_WsSubprotocol },
    .{ .name = "stzenginewslasterror", .func = ring_WsLastError },
    .{ .name = "stzenginewspingsreceived", .func = ring_WsPingsReceived },
    .{ .name = "stzenginewspongssent", .func = ring_WsPongsSent },
    .{ .name = "stzenginewsframessent", .func = ring_WsFramesSent },
    .{ .name = "stzenginewsrequesttarget", .func = ring_WsRequestTarget },
    .{ .name = "stzenginewsrequestheader", .func = ring_WsRequestHeader },
    .{ .name = "stzenginewsisserverside", .func = ring_WsIsServerSide },
    .{ .name = "stzenginewsserverlisten", .func = ring_WsServerListen },
    .{ .name = "stzenginewsserverclose", .func = ring_WsServerClose },
    .{ .name = "stzenginewsserveraccept", .func = ring_WsServerAccept },
    .{ .name = "stzenginewsserverbeginaccept", .func = ring_WsServerBeginAccept },
    .{ .name = "stzenginewsserverendaccept", .func = ring_WsServerEndAccept },
    .{ .name = "stzenginewsserverport", .func = ring_WsServerPort },
    .{ .name = "stzenginewsserversetmaxmessage", .func = ring_WsServerSetMaxMessage },
    .{ .name = "stzenginewsserversethandshaketimeout", .func = ring_WsServerSetHandshakeTimeout },
    .{ .name = "stzenginewsserversetclosewait", .func = ring_WsServerSetCloseWait },
    .{ .name = "stzenginewsserversetsubprotocols", .func = ring_WsServerSetSubprotocols },
    .{ .name = "stzenginewsserversetorigins", .func = ring_WsServerSetOrigins },
    .{ .name = "stzenginewsservertimedout", .func = ring_WsServerTimedOut },
    .{ .name = "stzenginewsserveraccepted", .func = ring_WsServerAccepted },
    .{ .name = "stzenginewsserverrefused", .func = ring_WsServerRefused },
    .{ .name = "stzenginewsserverlasterror", .func = ring_WsServerLastError },
    .{ .name = "stzenginewsbytesequal", .func = ring_WsBytesEqual },
    .{ .name = "stzenginewspattern", .func = ring_WsPattern },
    .{ .name = "stzenginewsbytesfromlist", .func = ring_WsBytesFromList },
    .{ .name = "stzenginewsechostart", .func = ring_WsEchoStart },
    .{ .name = "stzenginewsechostop", .func = ring_WsEchoStop },
    .{ .name = "stzenginewsechosethandshakemode", .func = ring_WsEchoSetHandshakeMode },
    .{ .name = "stzenginewsechoconnections", .func = ring_WsEchoConnections },
    .{ .name = "stzenginewsechomessages", .func = ring_WsEchoMessages },
    .{ .name = "stzenginewsechopings", .func = ring_WsEchoPings },
    .{ .name = "stzenginewsechopongs", .func = ring_WsEchoPongs },
    .{ .name = "stzenginewsechoresetcounters", .func = ring_WsEchoResetCounters },
    .{ .name = "stzenginewsecholasterror", .func = ring_WsEchoLastError },
};

pub fn registerAll(state: *anyopaque) void {
    R.registerAll(state, &regs);
}
