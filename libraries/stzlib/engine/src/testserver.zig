// Loopback HTTP test server -- for HARDENING the HTTP client offline.
//
// A tiny std.net HTTP/1.1 server bound to 127.0.0.1, run on its own
// thread, serving canned responses by path. It lets the Ring HTTP suite
// assert the integration seam's edge cases DETERMINISTICALLY and without
// the public internet: exact status codes, custom headers, oversized
// bodies (the overflow path), redirects, a slow handler (request
// timeout), auth 401/200, and cookie round-trip.
//
// This is a TEST fixture, not a production server: single global instance,
// one request per connection (Connection: close), Content-Length bodies.
//
// Routes:
//   /status/{n}     -> HTTP status n
//   /headers        -> 200 + "X-Test-Header: softanza"
//   /echo           -> 200, body = request body, "X-Method: <method>"
//   /big/{n}        -> 200, body of n 'x' bytes
//   /slow/{ms}      -> sleep ms, then 200
//   /redirect/{n}   -> 302 -> /redirect/{n-1}; at 0 -> 200
//   /auth           -> 401 unless an Authorization header is present
//   /setcookie      -> 200 + "Set-Cookie: sid=abc123"
//   /checkcookie    -> 200, body = the received Cookie header (or "none")
//   (anything else) -> 200 "ok"

const std = @import("std");

const gpa = std.heap.c_allocator;

const State = struct {
    server: std.net.Server,
    thread: std.Thread,
    port: u16,
    stop: std.atomic.Value(bool),
};

var state: ?*State = null;
var big_buf: [65536]u8 = [_]u8{'x'} ** 65536;

/// Start the loopback server on 127.0.0.1:`port` (0 = ephemeral).
/// Returns the actual bound port, or -1 on error.
pub fn server_start(port: u16) callconv(.c) i32 {
    if (state != null) return -1; // already running
    const addr = std.net.Address.parseIp("127.0.0.1", port) catch return -1;
    var srv = addr.listen(.{ .reuse_address = true }) catch return -1;
    const s = gpa.create(State) catch {
        srv.deinit();
        return -1;
    };
    s.* = .{
        .server = srv,
        .thread = undefined,
        .port = srv.listen_address.getPort(),
        .stop = std.atomic.Value(bool).init(false),
    };
    s.thread = std.Thread.spawn(.{}, acceptLoop, .{s}) catch {
        srv.deinit();
        gpa.destroy(s);
        return -1;
    };
    state = s;
    return @intCast(s.port);
}

/// Stop the server: unblock accept with a self-connection, join, close.
pub fn server_stop() callconv(.c) void {
    const s = state orelse return;
    s.stop.store(true, .release);
    // Wake the blocked accept() by connecting to ourselves.
    const addr = std.net.Address.parseIp("127.0.0.1", s.port) catch s.server.listen_address;
    if (std.net.tcpConnectToAddress(addr)) |c| {
        c.close();
    } else |_| {}
    s.thread.join();
    s.server.deinit();
    gpa.destroy(s);
    state = null;
}

fn acceptLoop(s: *State) void {
    while (true) {
        const conn = s.server.accept() catch {
            if (s.stop.load(.acquire)) return;
            continue;
        };
        if (s.stop.load(.acquire)) {
            conn.stream.close();
            return;
        }
        // One detached thread per connection so a /slow handler doesn't
        // block other requests. Detached threads are reaped at process
        // exit; fine for a test fixture. Falls back to inline handling
        // if a thread can't be spawned.
        if (std.Thread.spawn(.{}, handleConn, .{conn.stream})) |t| {
            t.detach();
        } else |_| {
            handleConn(conn.stream);
        }
    }
}

fn handleConn(stream: std.net.Stream) void {
    handle(stream);
    stream.close();
}

fn sendAll(stream: std.net.Stream, bytes: []const u8) void {
    var i: usize = 0;
    while (i < bytes.len) {
        const n = std.posix.send(stream.handle, bytes[i..], 0) catch return;
        if (n == 0) return;
        i += n;
    }
}

fn handle(stream: std.net.Stream) void {
    var buf: [65536]u8 = undefined;
    var total: usize = 0;
    // Read until end-of-headers, then any declared body.
    var header_end: usize = 0;
    while (total < buf.len) {
        const n = std.posix.recv(stream.handle, buf[total..], 0) catch return;
        if (n == 0) break;
        total += n;
        if (std.mem.indexOf(u8, buf[0..total], "\r\n\r\n")) |he| {
            header_end = he + 4;
            const clen = contentLength(buf[0..header_end]);
            if (total >= header_end + clen) break;
        }
    }
    if (header_end == 0) return;

    const req = buf[0..total];
    const method = firstToken(req);
    const path = secondToken(req);
    const body = if (total > header_end) req[header_end..total] else req[0..0];

    if (std.mem.startsWith(u8, path, "/status/")) {
        const n = parseTail(path, "/status/") orelse 200;
        respond(stream, @intCast(n), "status", "");
    } else if (std.mem.eql(u8, path, "/headers")) {
        respond(stream, 200, "headers", "X-Test-Header: softanza\r\n");
    } else if (std.mem.eql(u8, path, "/echo")) {
        var hbuf: [64]u8 = undefined;
        const xm = std.fmt.bufPrint(&hbuf, "X-Method: {s}\r\n", .{method}) catch "";
        respondBytes(stream, 200, body, xm);
    } else if (std.mem.startsWith(u8, path, "/big/")) {
        const n = parseTail(path, "/big/") orelse 0;
        respondBig(stream, n);
    } else if (std.mem.startsWith(u8, path, "/slow/")) {
        const ms = parseTail(path, "/slow/") orelse 0;
        std.Thread.sleep(@as(u64, @intCast(ms)) * std.time.ns_per_ms);
        respond(stream, 200, "slow", "");
    } else if (std.mem.startsWith(u8, path, "/redirect/")) {
        const n = parseTail(path, "/redirect/") orelse 0;
        if (n > 0) {
            var lbuf: [64]u8 = undefined;
            const loc = std.fmt.bufPrint(&lbuf, "Location: /redirect/{d}\r\n", .{n - 1}) catch "Location: /\r\n";
            respondStatusLine(stream, 302, "", loc);
        } else {
            respond(stream, 200, "redirected", "");
        }
    } else if (std.mem.eql(u8, path, "/auth")) {
        if (hasHeader(req, "authorization")) {
            respond(stream, 200, "authed", "");
        } else {
            respondStatusLine(stream, 401, "", "WWW-Authenticate: Basic realm=\"softanza\"\r\n");
        }
    } else if (std.mem.eql(u8, path, "/setcookie")) {
        respond(stream, 200, "set", "Set-Cookie: sid=abc123\r\n");
    } else if (std.mem.eql(u8, path, "/checkcookie")) {
        const cv = headerValue(req, "cookie") orelse "none";
        respondBytes(stream, 200, cv, "");
    } else {
        respond(stream, 200, "ok", "");
    }
}

// ── response writers ─────────────────────────────────────────

fn respond(stream: std.net.Stream, status: u16, body: []const u8, extra: []const u8) void {
    respondBytes(stream, status, body, extra);
}

fn respondBytes(stream: std.net.Stream, status: u16, body: []const u8, extra: []const u8) void {
    var head: [512]u8 = undefined;
    const h = std.fmt.bufPrint(&head, "HTTP/1.1 {d} OK\r\nContent-Length: {d}\r\nConnection: close\r\n{s}\r\n", .{ status, body.len, extra }) catch return;
    sendAll(stream, h);
    if (body.len > 0) sendAll(stream, body);
}

fn respondStatusLine(stream: std.net.Stream, status: u16, body: []const u8, extra: []const u8) void {
    respondBytes(stream, status, body, extra);
}

fn respondBig(stream: std.net.Stream, n: usize) void {
    var head: [256]u8 = undefined;
    const h = std.fmt.bufPrint(&head, "HTTP/1.1 200 OK\r\nContent-Length: {d}\r\nConnection: close\r\n\r\n", .{n}) catch return;
    sendAll(stream, h);
    var left = n;
    while (left > 0) {
        const chunk = @min(left, big_buf.len);
        sendAll(stream, big_buf[0..chunk]);
        left -= chunk;
    }
}

// ── request parsing helpers ──────────────────────────────────

fn firstToken(req: []const u8) []const u8 {
    const sp = std.mem.indexOfScalar(u8, req, ' ') orelse return req[0..0];
    return req[0..sp];
}

fn secondToken(req: []const u8) []const u8 {
    const sp1 = std.mem.indexOfScalar(u8, req, ' ') orelse return req[0..0];
    var rest = req[sp1 + 1 ..];
    const sp2 = std.mem.indexOfScalar(u8, rest, ' ') orelse return rest[0..0];
    return rest[0..sp2];
}

fn contentLength(headers: []const u8) usize {
    return std.fmt.parseInt(usize, std.mem.trim(u8, headerValue(headers, "content-length") orelse "0", " \t"), 10) catch 0;
}

fn hasHeader(req: []const u8, name_lower: []const u8) bool {
    return headerValue(req, name_lower) != null;
}

// Case-insensitive header lookup; returns the value (trimmed of leading
// space, excluding CRLF).
fn headerValue(req: []const u8, name_lower: []const u8) ?[]const u8 {
    var it = std.mem.splitSequence(u8, req, "\r\n");
    _ = it.next(); // skip request line
    while (it.next()) |line| {
        if (line.len == 0) break;
        const colon = std.mem.indexOfScalar(u8, line, ':') orelse continue;
        if (std.ascii.eqlIgnoreCase(std.mem.trim(u8, line[0..colon], " \t"), name_lower)) {
            return std.mem.trim(u8, line[colon + 1 ..], " \t");
        }
    }
    return null;
}

fn parseTail(path: []const u8, prefix: []const u8) ?usize {
    const tail = path[prefix.len..];
    return std.fmt.parseInt(usize, tail, 10) catch null;
}
