// WebSocket SERVER -- a listener that hands out server-side connections.
//
// This is a product surface, unlike ws_echo.zig (which is test support and
// misbehaves on command). Listen binds, Accept waits for a client, runs the
// opening handshake (Client.acceptHandshake in ws.zig) and returns the open
// connection as a *Client in server mode: the same handle type, the same
// Send / Recv / Close functions, frames not masked on the way out and REQUIRED
// to be masked on the way in. wss is served with a PEM certificate and key.
//
// Accept is single-threaded by design: it takes the connection and runs its
// handshake before it returns, bounded by the handshake timeout, so a client
// that connects and stays silent costs the loop up to that timeout. Keep it
// short (the default is 5 s). The connections themselves are independent and
// a caller may drive each from its own thread.

const std = @import("std");
const ws = @import("ws.zig");
const posix = std.posix;
const gpa = std.heap.c_allocator;
const tls = if (ws.tls_enabled) @import("ws_tls.zig") else struct {};

pub const Server = struct {
    listener: std.net.Server,
    port: u16,
    use_tls: bool = false,
    cert_pem: []u8 = &.{},
    key_pem: []u8 = &.{},
    max_message: u64 = ws.DEFAULT_MAX_MESSAGE,
    handshake_ms: u32 = 5000,
    close_wait_ms: u32 = 2000,
    subprotocols: std.ArrayList(u8) = .{},
    origins: std.ArrayList(u8) = .{},
    timed_out: bool = false,
    /// a BeginAccept in flight: the thread waiting for a client, and what it will hand over
    async_thread: ?std.Thread = null,
    async_result: ?*ws.Client = null,
    accepted: u32 = 0,
    refused: u32 = 0,
    err_buf: [256]u8 = undefined,
    err_len: usize = 0,

    fn setErr(self: *Server, msg: []const u8) void {
        const n = @min(msg.len, self.err_buf.len);
        @memcpy(self.err_buf[0..n], msg[0..n]);
        self.err_len = n;
    }
};

pub fn ws_server_listen(host: [*]const u8, host_len: usize, port: u16, cert: [*]const u8, cert_len: usize, key: [*]const u8, key_len: usize) callconv(.c) ?*Server {
    const h: []const u8 = if (host_len == 0) "127.0.0.1" else host[0..host_len];
    const addr = std.net.Address.parseIp(h, port) catch return null;
    var cert_pem: []u8 = &.{};
    var key_pem: []u8 = &.{};
    const want_tls = cert_len > 0 or key_len > 0;
    if (want_tls) {
        if (!ws.tls_enabled or cert_len == 0 or key_len == 0) return null;
        cert_pem = std.fs.cwd().readFileAlloc(gpa, cert[0..cert_len], 1 << 20) catch return null;
        key_pem = std.fs.cwd().readFileAlloc(gpa, key[0..key_len], 1 << 20) catch {
            gpa.free(cert_pem);
            return null;
        };
    }
    var listener = addr.listen(.{ .reuse_address = true }) catch {
        if (want_tls) {
            gpa.free(cert_pem);
            gpa.free(key_pem);
        }
        return null;
    };
    const s = gpa.create(Server) catch {
        listener.deinit();
        return null;
    };
    s.* = .{ .listener = listener, .port = listener.listen_address.getPort(), .use_tls = want_tls, .cert_pem = cert_pem, .key_pem = key_pem };
    return s;
}

pub fn ws_server_close(s: ?*Server) callconv(.c) void {
    const sv = s orelse return;
    // an accept still waiting on its thread is joined first (it is bounded by its timeout), and a
    // connection it already took is closed rather than leaked
    if (ws_server_end_accept(sv)) |c| {
        c.deinit();
        gpa.destroy(c);
    }
    sv.listener.deinit();
    sv.subprotocols.deinit(gpa);
    sv.origins.deinit(gpa);
    if (sv.cert_pem.len > 0) gpa.free(sv.cert_pem);
    if (sv.key_pem.len > 0) gpa.free(sv.key_pem);
    gpa.destroy(sv);
}

pub fn ws_server_port(s: ?*Server) callconv(.c) i32 {
    const sv = s orelse return 0;
    return sv.port;
}

pub fn ws_server_set_max_message(s: ?*Server, max: u64) callconv(.c) void {
    const sv = s orelse return;
    sv.max_message = if (max == 0) ws.DEFAULT_MAX_MESSAGE else max;
}

pub fn ws_server_set_handshake_timeout(s: ?*Server, ms: u32) callconv(.c) void {
    const sv = s orelse return;
    sv.handshake_ms = ms;
}

pub fn ws_server_set_close_wait(s: ?*Server, ms: u32) callconv(.c) void {
    const sv = s orelse return;
    sv.close_wait_ms = ms;
}

pub fn ws_server_set_subprotocols(s: ?*Server, p: [*]const u8, len: usize) callconv(.c) void {
    const sv = s orelse return;
    ws.Client.setText(&sv.subprotocols, p[0..len]);
}

pub fn ws_server_set_origins(s: ?*Server, p: [*]const u8, len: usize) callconv(.c) void {
    const sv = s orelse return;
    ws.Client.setText(&sv.origins, p[0..len]);
}

pub fn ws_server_timed_out(s: ?*Server) callconv(.c) i32 {
    const sv = s orelse return 0;
    return if (sv.timed_out) 1 else 0;
}

pub fn ws_server_accepted(s: ?*Server) callconv(.c) u32 {
    const sv = s orelse return 0;
    return sv.accepted;
}

pub fn ws_server_refused(s: ?*Server) callconv(.c) u32 {
    const sv = s orelse return 0;
    return sv.refused;
}

pub fn ws_server_last_error_len(s: ?*Server) callconv(.c) usize {
    const sv = s orelse return 0;
    return sv.err_len;
}

pub fn ws_server_last_error_ptr(s: ?*Server) callconv(.c) [*]const u8 {
    const sv = s orelse return "";
    return &sv.err_buf;
}

/// Wait up to `timeout_ms` (-1 = forever, 0 = poll) for a client and run its
/// handshake. Returns the open server-side connection, or null: with
/// timed_out set when nobody came, with the cause in last_error when a client
/// came and was refused (the refusal was answered on the wire).
pub fn ws_server_accept(s: ?*Server, timeout_ms: i32) callconv(.c) ?*ws.Client {
    const sv = s orelse return null;
    sv.err_len = 0;
    sv.timed_out = false;
    var pfd = [_]posix.pollfd{.{ .fd = sv.listener.stream.handle, .events = posix.POLL.IN, .revents = 0 }};
    const ready = posix.poll(&pfd, timeout_ms) catch {
        sv.setErr("accept poll failed");
        return null;
    };
    if (ready == 0) {
        sv.timed_out = true;
        return null;
    }
    const conn = sv.listener.accept() catch {
        sv.setErr("accept failed");
        return null;
    };
    const c = gpa.create(ws.Client) catch {
        conn.stream.close();
        sv.setErr("out of memory");
        return null;
    };
    c.* = .{};
    c.max_message = sv.max_message;
    c.connect_timeout_ms = sv.handshake_ms;
    c.close_wait_ms = sv.close_wait_ms;
    c.tr = .{ .sock = conn.stream.handle };
    if (sv.use_tls) {
        if (comptime ws.tls_enabled) {
            c.tr.?.tls = tls.accept(conn.stream.handle, sv.cert_pem, sv.key_pem, sv.handshake_ms) catch |e| {
                var buf: [96]u8 = undefined;
                sv.setErr(std.fmt.bufPrint(&buf, "tls: {s}", .{tls.describe(e)}) catch "tls failed");
                sv.refused += 1;
                c.deinit();
                gpa.destroy(c);
                return null;
            };
        }
    }
    if (!c.acceptHandshake(sv.subprotocols.items, sv.origins.items)) {
        sv.setErr(c.lastError());
        sv.refused += 1;
        c.deinit();
        gpa.destroy(c);
        return null;
    }
    sv.accepted += 1;
    return c;
}

fn acceptOnThread(sv: *Server, timeout_ms: i32) void {
    sv.async_result = ws_server_accept(sv, timeout_ms);
}

/// Start waiting for a client on a background thread, so the calling program can
/// go on -- connect a client from the same process, say -- and collect the
/// connection with ws_server_end_accept. `timeout_ms` bounds the wait and must be
/// positive (a thread that waits for ever could not be joined). Returns 1 started,
/// 0 when one is already in flight or the thread could not start.
pub fn ws_server_begin_accept(s: ?*Server, timeout_ms: i32) callconv(.c) i32 {
    const sv = s orelse return 0;
    if (sv.async_thread != null or timeout_ms <= 0) return 0;
    sv.async_result = null;
    sv.async_thread = std.Thread.spawn(.{}, acceptOnThread, .{ sv, timeout_ms }) catch return 0;
    return 1;
}

/// Join the background accept and hand over what it got: the open connection, or
/// null (timed_out / last_error say which). Null too when none was started.
pub fn ws_server_end_accept(s: ?*Server) callconv(.c) ?*ws.Client {
    const sv = s orelse return null;
    const t = sv.async_thread orelse return null;
    t.join();
    sv.async_thread = null;
    const c = sv.async_result;
    sv.async_result = null;
    return c;
}

// ── Tests ────────────────────────────────────────────────────

const testing = std.testing;

fn serveOne(sv: *Server, ok: *bool) void {
    const c = ws_server_accept(sv, 5000) orelse return;
    defer {
        c.deinit();
        gpa.destroy(c);
    }
    ok.* = true;
    // echo until the peer closes
    while (true) {
        const k = c.recv(3000);
        if (k == 1 or k == 2) {
            _ = c.send(@intCast(k), c.last.items);
        } else if (k != 3) break;
    }
}

test "ws server: a real client talks to the public server, masked in, plain out" {
    const sv = ws_server_listen("127.0.0.1", 9, 0, "", 0, "", 0) orelse return error.SkipZigTest;
    defer ws_server_close(sv);
    ws_server_set_subprotocols(sv, "chat", 4);
    var served = false;
    const t = try std.Thread.spawn(.{}, serveOne, .{ sv, &served });
    var url_buf: [64]u8 = undefined;
    const url = try std.fmt.bufPrint(&url_buf, "ws://127.0.0.1:{d}/room?x=1", .{sv.port});
    var c = ws.Client{};
    defer c.deinit();
    c.subprotocols.appendSlice(gpa, "other, chat") catch unreachable;
    try testing.expect(c.connect(url));
    try testing.expectEqualStrings("chat", c.negotiated.items);
    const bin = [_]u8{ 0, 0xFF, 7, 0 };
    try testing.expect(c.send(ws.OP_BINARY, &bin));
    try testing.expectEqual(@as(i32, 2), c.recv(3000));
    try testing.expectEqualSlices(u8, &bin, c.last.items);
    try testing.expect(c.close(1000, "bye"));
    t.join();
    try testing.expect(served);
}

test "ws server: one thread is both ends -- BeginAccept, connect, EndAccept" {
    const sv = ws_server_listen("127.0.0.1", 9, 0, "", 0, "", 0) orelse return error.SkipZigTest;
    defer ws_server_close(sv);
    try testing.expectEqual(@as(i32, 1), ws_server_begin_accept(sv, 5000));
    try testing.expectEqual(@as(i32, 0), ws_server_begin_accept(sv, 5000)); // one at a time
    var url_buf: [64]u8 = undefined;
    const url = try std.fmt.bufPrint(&url_buf, "ws://127.0.0.1:{d}/solo", .{sv.port});
    var c = ws.Client{};
    defer c.deinit();
    try testing.expect(c.connect(url));
    const sc = ws_server_end_accept(sv) orelse return error.TestUnexpectedResult;
    defer {
        sc.deinit();
        gpa.destroy(sc);
    }
    try testing.expect(ws_server_end_accept(sv) == null); // nothing left in flight
    try testing.expectEqualStrings("/solo", sc.req_target.items);
    try testing.expect(c.send(ws.OP_TEXT, "one thread"));
    try testing.expectEqual(@as(i32, 1), sc.recv(2000));
    try testing.expectEqualStrings("one thread", sc.last.items);
}

test "ws server: refusals are answered on the wire and named" {
    const sv = ws_server_listen("127.0.0.1", 9, 0, "", 0, "", 0) orelse return error.SkipZigTest;
    defer ws_server_close(sv);
    ws_server_set_origins(sv, "http://good.example", 19);
    const cases = [_]struct { req: []const u8, status: []const u8, why: []const u8 }{
        .{ .req = "POST / HTTP/1.1\r\n\r\n", .status = "HTTP/1.1 400", .why = "handshake: not a GET" },
        .{ .req = "GET / HTTP/1.1\r\nConnection: Upgrade\r\nSec-WebSocket-Version: 13\r\nSec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\n\r\n", .status = "HTTP/1.1 400", .why = "handshake: no Upgrade" },
        .{ .req = "GET / HTTP/1.1\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Version: 8\r\nSec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\n\r\n", .status = "HTTP/1.1 426", .why = "handshake: version is not 13" },
        .{ .req = "GET / HTTP/1.1\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Version: 13\r\nSec-WebSocket-Key: short\r\n\r\n", .status = "HTTP/1.1 400", .why = "handshake: Sec-WebSocket-Key" },
        .{ .req = "GET / HTTP/1.1\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Version: 13\r\nSec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\nOrigin: http://evil.example\r\n\r\n", .status = "HTTP/1.1 403", .why = "handshake: Origin not allowed" },
    };
    for (cases) |cs| {
        const addr = try std.net.Address.parseIp("127.0.0.1", sv.port);
        const stream = try std.net.tcpConnectToAddress(addr);
        defer stream.close();
        _ = try posix.send(stream.handle, cs.req, 0);
        try testing.expect(ws_server_accept(sv, 3000) == null);
        try testing.expect(std.mem.indexOf(u8, sv.err_buf[0..sv.err_len], cs.why) != null);
        var buf: [256]u8 = undefined;
        const n = try posix.recv(stream.handle, &buf, 0);
        try testing.expect(std.mem.startsWith(u8, buf[0..n], cs.status));
    }
    try testing.expectEqual(@as(u32, cases.len), sv.refused);
    // nobody came: a timeout, not an error
    try testing.expect(ws_server_accept(sv, 50) == null);
    try testing.expect(sv.timed_out and sv.err_len == 0);
}
