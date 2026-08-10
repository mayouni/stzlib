// Synchronous TCP client + server backed by Zig std.net.
//
// M-DEP4 slice 2: the libuv-based async TCP wrappers in stzTcpClient
// and stzTcpServer get replaced with a blocking engine surface so
// they stop depending on libuv.ring. Real async is deferred to the
// cross-platform Zig event loop arc (months of work).
//
// Surface:
//   tcp_connect(host, port) -> opaque client handle (or null)
//   tcp_send(handle, data, len) -> bytes sent (or -1)
//   tcp_recv(handle, out, max) -> bytes read (or -1 / 0 on EOF)
//   tcp_close(handle)
//
//   tcp_listen(host, port) -> opaque server handle (or null)
//   tcp_accept(server) -> opaque client handle (or null)
//   tcp_server_close(server)
//
//   tcp_last_error_len() / tcp_last_error(buf, max)
//
// Every operation is blocking. The L99 / Windows test-loop guardrail
// excludes network IO from CI; live integration tests run outside
// the harness.

const std = @import("std");
const dns = @import("dns.zig");

const gpa = std.heap.c_allocator;

var last_error_buf: [512]u8 = undefined;
var last_error_len: usize = 0;

fn setError(msg: []const u8) void {
    const n = @min(msg.len, last_error_buf.len);
    @memcpy(last_error_buf[0..n], msg[0..n]);
    last_error_len = n;
}

fn clearError() void {
    last_error_len = 0;
}

pub fn tcp_last_error_len() callconv(.c) usize {
    return last_error_len;
}

pub fn tcp_last_error(out: [*]u8, max: usize) callconv(.c) i32 {
    const n = @min(last_error_len, max);
    if (n == 0) return 0;
    @memcpy(out[0..n], last_error_buf[0..n]);
    return @intCast(n);
}

// ── Client ───────────────────────────────────────────────────

pub const TcpClient = struct {
    stream: std.net.Stream,
};

pub fn tcp_connect(
    host_ptr: [*]const u8,
    host_len: usize,
    port: u16,
) callconv(.c) ?*TcpClient {
    clearError();
    if (host_len == 0) {
        setError("empty host");
        return null;
    }
    const host = host_ptr[0..host_len];
    // Resolve through the shared DNS cache (item 3), then connect.
    const addr = dns.lookup(host, port) catch {
        setError("connect failed: dns resolution failed");
        return null;
    };
    const stream = std.net.tcpConnectToAddress(addr) catch |err| {
        var fbuf: [200]u8 = undefined;
        const msg = std.fmt.bufPrint(&fbuf, "connect failed: {s}", .{@errorName(err)}) catch "connect failed";
        setError(msg);
        return null;
    };
    const c = gpa.create(TcpClient) catch {
        stream.close();
        setError("oom");
        return null;
    };
    c.* = .{ .stream = stream };
    return c;
}

pub fn tcp_send(
    client: ?*TcpClient,
    data_ptr: [*]const u8,
    data_len: usize,
) callconv(.c) i32 {
    clearError();
    const c = client orelse {
        setError("null handle");
        return -1;
    };
    if (data_len == 0) return 0;
    const n = c.stream.write(data_ptr[0..data_len]) catch |err| {
        var fbuf: [200]u8 = undefined;
        const msg = std.fmt.bufPrint(&fbuf, "send failed: {s}", .{@errorName(err)}) catch "send failed";
        setError(msg);
        return -1;
    };
    return @intCast(n);
}

pub fn tcp_recv(client: ?*TcpClient, out: [*]u8, max: usize) callconv(.c) i32 {
    clearError();
    const c = client orelse {
        setError("null handle");
        return -1;
    };
    if (max == 0) return 0;
    // std.posix.recv, NOT stream.read.
    //
    // On Windows, Zig's Stream.read goes through ReadFile, and that does not
    // work on a socket returned by accept() -- it fails with the unmapped
    // "Unexpected". Writing was fine, so the symptom was a server that could
    // answer but never hear: every server-side read returned
    // "recv failed: Unexpected" while Send worked perfectly.
    //
    // testserver.zig has always used std.posix.recv on the raw handle, which
    // is why the HTTP-client suite never caught this -- the only std.net
    // server in the tree that reads was already doing it the right way.
    const n = std.posix.recv(c.stream.handle, out[0..max], 0) catch |err| {
        var fbuf: [200]u8 = undefined;
        const msg = std.fmt.bufPrint(&fbuf, "recv failed: {s}", .{@errorName(err)}) catch "recv failed";
        setError(msg);
        return -1;
    };
    return @intCast(n);
}

pub fn tcp_close(client: ?*TcpClient) callconv(.c) void {
    const c = client orelse return;
    c.stream.close();
    gpa.destroy(c);
}

// ── Server ───────────────────────────────────────────────────

pub const TcpServer = struct {
    listener: std.net.Server,
};

pub fn tcp_listen(
    host_ptr: [*]const u8,
    host_len: usize,
    port: u16,
) callconv(.c) ?*TcpServer {
    clearError();
    const host: []const u8 = if (host_len == 0) "0.0.0.0" else host_ptr[0..host_len];
    const addr = std.net.Address.parseIp(host, port) catch |err| {
        var fbuf: [200]u8 = undefined;
        const msg = std.fmt.bufPrint(&fbuf, "listen parse failed: {s}", .{@errorName(err)}) catch "listen failed";
        setError(msg);
        return null;
    };
    var server = addr.listen(.{ .reuse_address = true }) catch |err| {
        var fbuf: [200]u8 = undefined;
        const msg = std.fmt.bufPrint(&fbuf, "listen bind failed: {s}", .{@errorName(err)}) catch "listen failed";
        setError(msg);
        return null;
    };
    const s = gpa.create(TcpServer) catch {
        server.deinit();
        setError("oom");
        return null;
    };
    s.* = .{ .listener = server };
    return s;
}

pub fn tcp_accept(server: ?*TcpServer) callconv(.c) ?*TcpClient {
    clearError();
    const s = server orelse {
        setError("null handle");
        return null;
    };
    const conn = s.listener.accept() catch |err| {
        var fbuf: [200]u8 = undefined;
        const msg = std.fmt.bufPrint(&fbuf, "accept failed: {s}", .{@errorName(err)}) catch "accept failed";
        setError(msg);
        return null;
    };
    const c = gpa.create(TcpClient) catch {
        conn.stream.close();
        setError("oom");
        return null;
    };
    c.* = .{ .stream = conn.stream };
    return c;
}

/// Accept, but give up after `timeout_ms` and return null with no error set.
///
/// WITHOUT THIS THERE IS NO WAY TO ASSERT THAT NOTHING CONNECTED. tcp_accept
/// blocks forever, so a test whose point is "no connection should have arrived"
/// hangs instead of failing -- which is how a regression in the HTTP batch first
/// showed up: the guard that caught it caught it by never finishing.
///
/// A timeout reports through last_error like every other failure here, because a
/// null handle still reaches Ring as a TcpClient value and cannot be tested. The
/// message is its own -- "accept timed out" -- so a caller who is WAITING to see
/// nothing can tell that apart from an accept that actually broke.
pub fn tcp_accept_timeout(server: ?*TcpServer, timeout_ms: u32) callconv(.c) ?*TcpClient {
    clearError();
    const s = server orelse {
        setError("null handle");
        return null;
    };

    var pfd = [_]std.posix.pollfd{.{
        .fd = s.listener.stream.handle,
        .events = std.posix.POLL.IN,
        .revents = 0,
    }};
    const ready = std.posix.poll(&pfd, @intCast(timeout_ms)) catch |err| {
        var fbuf: [200]u8 = undefined;
        const msg = std.fmt.bufPrint(&fbuf, "accept poll failed: {s}", .{@errorName(err)}) catch "accept failed";
        setError(msg);
        return null;
    };
    if (ready == 0) {
        setError("accept timed out");
        return null;
    }

    return tcp_accept(server);
}

pub fn tcp_server_close(server: ?*TcpServer) callconv(.c) void {
    const s = server orelse return;
    s.listener.deinit();
    gpa.destroy(s);
}

// ── Tests ────────────────────────────────────────────────────
// Network IO is excluded from the default test sweep. These tests
// exercise the error paths only.

test "tcp: connect to nonexistent host returns null" {
    const c = tcp_connect("invalid.host.does.not.exist.example.invalid", 47, 1);
    try std.testing.expect(c == null);
    try std.testing.expect(tcp_last_error_len() > 0);
}

test "tcp: send on null handle returns -1" {
    try std.testing.expectEqual(@as(i32, -1), tcp_send(null, "x", 1));
}

test "tcp: listen on invalid host returns null" {
    const s = tcp_listen("not an ip", 9, 8080);
    try std.testing.expect(s == null);
}
