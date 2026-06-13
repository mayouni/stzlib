// Custom HTTP/1.1 client on raw std.net.Stream.
//
// Gap-analysis Tier 1 items 1+2 (engine-side half). std.http.Client
// does not expose per-socket timeouts and its internal connection_pool
// gives limited control. To get socket-level timeouts AND a connection
// pool we control, we skip std.http.Client and speak HTTP/1.1 directly
// over std.net.Stream, layering TLS via std.crypto.tls.Client for https.
//
// This module is the transport: connect (with a connect deadline),
// send a request, read a response (Content-Length + chunked aware),
// close. The pool that keeps connections alive lives in http_pool.zig;
// the C-ABI surface + error reporting lives in http.zig.
//
// Timeout model:
//   * connect_timeout_ms -- enforced cross-platform via a non-blocking
//     connect + poll(POLLOUT) with a deadline. This is what makes an
//     unreachable host fail fast instead of blocking on the OS connect
//     timeout (~21s on Windows).
//   * io_timeout_ms -- SO_RCVTIMEO / SO_SNDTIMEO on the socket. On
//     POSIX a blocking recv/send honours these. On Windows the std
//     Stream reader/writer use overlapped WSARecv/WSASend, for which
//     SO_RCVTIMEO is best-effort only; the caller-side deadline
//     (pool_poll_with_deadline, shipped session 64) remains the
//     cross-platform guarantee for freeing the caller. We still set
//     the option -- it is correct where the platform honours it and
//     harmless where it does not.

const std = @import("std");
const builtin = @import("builtin");
const posix = std.posix;
const tls = std.crypto.tls;
const dns = @import("dns.zig");

const gpa = std.heap.c_allocator;

// Socket reader buffer must hold a full TLS ciphertext record for the
// https path; the plaintext read buffer must hold a full HTTP header
// line for takeDelimiterInclusive. Generous so real-world headers fit.
const TLS_MIN: usize = tls.Client.min_buffer_len; // ~16640
const PLAIN_READ_BUF: usize = 64 * 1024;
const PLAIN_WRITE_BUF: usize = 16 * 1024;
const TLS_PLAIN_READ_BUF: usize = 64 * 1024; // decrypted header/body buffer
const TLS_PLAIN_WRITE_BUF: usize = 16 * 1024; // plaintext to encrypt

// Shared CA bundle for https verification, loaded once.
var ca_bundle: std.crypto.Certificate.Bundle = .{};
var ca_loaded: bool = false;
var ca_mutex: std.Thread.Mutex = .{};

fn ensureCaBundle() void {
    ca_mutex.lock();
    defer ca_mutex.unlock();
    if (ca_loaded) return;
    ca_bundle.rescan(gpa) catch {};
    ca_loaded = true;
}

pub const ConnectError = error{
    DnsFailed,
    SocketFailed,
    ConnectTimeout,
    ConnectRefused,
    TlsFailed,
    OutOfMemory,
};

pub const RequestError = error{
    WriteFailed,
    ReadFailed,
    BadResponse,
    BodyOverflow,
};

pub const Response = struct {
    status: i32,
    body_len: usize,
    keep_alive: bool,
};

pub const Connection = struct {
    is_tls: bool,
    host: []u8, // owned copy, used as the pool key + Host header
    port: u16,
    stream: std.net.Stream,
    last_used_ns: i128,
    closing: bool,

    // Socket-level reader/writer. Must live at a stable address: the
    // TLS client and the Io interfaces store pointers into these.
    sreader: std.net.Stream.Reader,
    swriter: std.net.Stream.Writer,
    sread_buf: []u8,
    swrite_buf: []u8,

    // https only -- heap-allocated so its inline Io.Reader/Writer
    // vtables (which recover the client via @fieldParentPtr) stay valid.
    tls_client: ?*tls.Client,
    tls_read_buf: []u8,
    tls_write_buf: []u8,

    fn appReader(c: *Connection) *std.Io.Reader {
        if (c.tls_client) |t| return &t.reader;
        return c.sreader.interface();
    }

    fn appWriter(c: *Connection) *std.Io.Writer {
        if (c.tls_client) |t| return &t.writer;
        return &c.swriter.interface;
    }

    fn flush(c: *Connection) RequestError!void {
        if (c.tls_client) |t| t.writer.flush() catch return error.WriteFailed;
        c.swriter.interface.flush() catch return error.WriteFailed;
    }
};

// ── connect ──────────────────────────────────────────────────

/// Resolve `host`, open a TCP connection enforcing `connect_timeout_ms`,
/// then layer TLS when `is_tls`. Returns an owned Connection.
pub fn connect(
    host: []const u8,
    port: u16,
    is_tls: bool,
    connect_timeout_ms: u32,
) ConnectError!*Connection {
    // Resolve through the DNS cache (item 3) -- a warm cache skips the
    // resolver syscall on repeat connects to the same host.
    const addr = dns.lookup(host, port) catch return error.DnsFailed;
    const s = connectAddr(addr, connect_timeout_ms) catch |err| return err;
    errdefer s.close();

    const c = gpa.create(Connection) catch return error.OutOfMemory;
    errdefer gpa.destroy(c);

    const host_copy = gpa.dupe(u8, host) catch return error.OutOfMemory;
    errdefer gpa.free(host_copy);

    const sread_len: usize = if (is_tls) TLS_MIN else PLAIN_READ_BUF;
    const swrite_len: usize = if (is_tls) TLS_MIN else PLAIN_WRITE_BUF;
    const sread_buf = gpa.alloc(u8, sread_len) catch return error.OutOfMemory;
    errdefer gpa.free(sread_buf);
    const swrite_buf = gpa.alloc(u8, swrite_len) catch return error.OutOfMemory;
    errdefer gpa.free(swrite_buf);

    c.* = .{
        .is_tls = is_tls,
        .host = host_copy,
        .port = port,
        .stream = s,
        .last_used_ns = std.time.nanoTimestamp(),
        .closing = false,
        .sreader = s.reader(sread_buf),
        .swriter = s.writer(swrite_buf),
        .sread_buf = sread_buf,
        .swrite_buf = swrite_buf,
        .tls_client = null,
        .tls_read_buf = &.{},
        .tls_write_buf = &.{},
    };

    if (is_tls) {
        ensureCaBundle();
        const tls_read_buf = gpa.alloc(u8, TLS_PLAIN_READ_BUF) catch return error.OutOfMemory;
        errdefer gpa.free(tls_read_buf);
        const tls_write_buf = gpa.alloc(u8, TLS_PLAIN_WRITE_BUF) catch return error.OutOfMemory;
        errdefer gpa.free(tls_write_buf);
        const client = gpa.create(tls.Client) catch return error.OutOfMemory;
        errdefer gpa.destroy(client);

        client.* = tls.Client.init(
            c.sreader.interface(),
            &c.swriter.interface,
            .{
                .host = .{ .explicit = host_copy },
                .ca = .{ .bundle = ca_bundle },
                .read_buffer = tls_read_buf,
                .write_buffer = tls_write_buf,
                // HTTP verifies length via Content-Length / chunked, so
                // forwarding end-of-stream to us is the documented choice.
                .allow_truncation_attacks = true,
            },
        ) catch return error.TlsFailed;

        c.tls_client = client;
        c.tls_read_buf = tls_read_buf;
        c.tls_write_buf = tls_write_buf;
    }

    return c;
}

fn connectAddr(addr: std.net.Address, connect_timeout_ms: u32) ConnectError!std.net.Stream {
    const sock_flags = posix.SOCK.STREAM |
        (if (builtin.os.tag == .windows) 0 else posix.SOCK.CLOEXEC);
    const fd = posix.socket(addr.any.family, sock_flags, posix.IPPROTO.TCP) catch
        return error.SocketFailed;
    errdefer posix.close(fd);

    if (connect_timeout_ms == 0) {
        // No deadline -- plain blocking connect.
        posix.connect(fd, &addr.any, addr.getOsSockLen()) catch return error.ConnectRefused;
        return .{ .handle = fd };
    }

    setNonBlocking(fd, true) catch return error.SocketFailed;
    posix.connect(fd, &addr.any, addr.getOsSockLen()) catch |err| switch (err) {
        error.WouldBlock => {}, // connection in progress -- poll below
        else => return error.ConnectRefused,
    };

    var pfd = [_]posix.pollfd{.{
        .fd = fd,
        .events = posix.POLL.OUT,
        .revents = 0,
    }};
    const ready = posix.poll(&pfd, @intCast(connect_timeout_ms)) catch return error.SocketFailed;
    if (ready == 0) return error.ConnectTimeout;
    if (pfd[0].revents & posix.POLL.ERR != 0) return error.ConnectRefused;

    // Confirm the connect actually succeeded (poll can wake on error).
    posix.getsockoptError(fd) catch return error.ConnectRefused;

    setNonBlocking(fd, false) catch return error.SocketFailed;
    return .{ .handle = fd };
}

fn setNonBlocking(fd: posix.socket_t, on: bool) !void {
    if (builtin.os.tag == .windows) {
        var mode: u32 = if (on) 1 else 0;
        const rc = std.os.windows.ws2_32.ioctlsocket(fd, std.os.windows.ws2_32.FIONBIO, &mode);
        if (rc == std.os.windows.ws2_32.SOCKET_ERROR) return error.SetNonBlockFailed;
    } else {
        const flags = try posix.fcntl(fd, posix.F.GETFL, 0);
        const nb: usize = @bitCast(posix.O{ .NONBLOCK = true });
        const new_flags = if (on) flags | nb else flags & ~nb;
        _ = try posix.fcntl(fd, posix.F.SETFL, new_flags);
    }
}

/// Apply SO_RCVTIMEO / SO_SNDTIMEO. ms == 0 clears the timeout.
pub fn setIoTimeout(c: *Connection, ms: u32) void {
    const fd = c.stream.handle;
    if (builtin.os.tag == .windows) {
        // Windows wants a DWORD of milliseconds.
        var v: u32 = ms;
        posix.setsockopt(fd, posix.SOL.SOCKET, posix.SO.RCVTIMEO, std.mem.asBytes(&v)) catch {};
        posix.setsockopt(fd, posix.SOL.SOCKET, posix.SO.SNDTIMEO, std.mem.asBytes(&v)) catch {};
    } else {
        var tv = posix.timeval{
            .sec = @intCast(ms / 1000),
            .usec = @intCast((ms % 1000) * 1000),
        };
        posix.setsockopt(fd, posix.SOL.SOCKET, posix.SO.RCVTIMEO, std.mem.asBytes(&tv)) catch {};
        posix.setsockopt(fd, posix.SOL.SOCKET, posix.SO.SNDTIMEO, std.mem.asBytes(&tv)) catch {};
    }
}

// ── request / response ───────────────────────────────────────

/// Send a request and read the response into `out[0..max]`.
/// `target` is the request-target ("/path?query"). `headers_blob` is a
/// newline-separated "Name: Value" block (may be empty). `content_type`
/// and `body` may be null for bodiless verbs.
pub fn request(
    c: *Connection,
    method_str: []const u8,
    target: []const u8,
    host_header: []const u8,
    headers_blob: []const u8,
    content_type: ?[]const u8,
    body: ?[]const u8,
    out: [*]u8,
    max: usize,
) RequestError!Response {
    try sendRequest(c, method_str, target, host_header, headers_blob, content_type, body);
    return readResponse(c, out, max);
}

fn sendRequest(
    c: *Connection,
    method_str: []const u8,
    target: []const u8,
    host_header: []const u8,
    headers_blob: []const u8,
    content_type: ?[]const u8,
    body: ?[]const u8,
) RequestError!void {
    const w = c.appWriter();
    writeAll(w, method_str) catch return error.WriteFailed;
    writeAll(w, " ") catch return error.WriteFailed;
    writeAll(w, if (target.len == 0) "/" else target) catch return error.WriteFailed;
    writeAll(w, " HTTP/1.1\r\n") catch return error.WriteFailed;

    writeAll(w, "Host: ") catch return error.WriteFailed;
    writeAll(w, host_header) catch return error.WriteFailed;
    writeAll(w, "\r\n") catch return error.WriteFailed;

    // We do not decode gzip/deflate, so ask for identity.
    var seen_accept_encoding = false;
    var seen_user_agent = false;
    if (headers_blob.len > 0) {
        var it = std.mem.splitScalar(u8, headers_blob, '\n');
        while (it.next()) |raw| {
            var line = raw;
            if (line.len > 0 and line[line.len - 1] == '\r') line = line[0 .. line.len - 1];
            if (line.len == 0) continue;
            if (std.ascii.startsWithIgnoreCase(line, "accept-encoding")) seen_accept_encoding = true;
            if (std.ascii.startsWithIgnoreCase(line, "user-agent")) seen_user_agent = true;
            writeAll(w, line) catch return error.WriteFailed;
            writeAll(w, "\r\n") catch return error.WriteFailed;
        }
    }
    if (!seen_accept_encoding) writeAll(w, "Accept-Encoding: identity\r\n") catch return error.WriteFailed;
    if (!seen_user_agent) writeAll(w, "User-Agent: Softanza-HTTP/1.0\r\n") catch return error.WriteFailed;

    if (content_type) |ct| {
        writeAll(w, "Content-Type: ") catch return error.WriteFailed;
        writeAll(w, ct) catch return error.WriteFailed;
        writeAll(w, "\r\n") catch return error.WriteFailed;
    }
    if (body) |b| {
        var num_buf: [24]u8 = undefined;
        const num = std.fmt.bufPrint(&num_buf, "{d}", .{b.len}) catch unreachable;
        writeAll(w, "Content-Length: ") catch return error.WriteFailed;
        writeAll(w, num) catch return error.WriteFailed;
        writeAll(w, "\r\n") catch return error.WriteFailed;
    }
    writeAll(w, "\r\n") catch return error.WriteFailed;
    if (body) |b| writeAll(w, b) catch return error.WriteFailed;

    try c.flush();
}

fn writeAll(w: *std.Io.Writer, bytes: []const u8) !void {
    try w.writeAll(bytes);
}

fn readResponse(c: *Connection, out: [*]u8, max: usize) RequestError!Response {
    const r = c.appReader();

    // ── status line ──
    const status_line = takeLine(r) catch return error.ReadFailed;
    const status = parseStatus(status_line) orelse return error.BadResponse;

    // ── headers ──
    var content_length: ?usize = null;
    var chunked = false;
    var keep_alive = true; // HTTP/1.1 default
    var is_head_like = false; // status with no body
    if (status == 204 or status == 304 or (status >= 100 and status < 200)) is_head_like = true;

    while (true) {
        const line = takeLine(r) catch return error.ReadFailed;
        if (line.len == 0) break; // blank line ends headers
        const colon = std.mem.indexOfScalar(u8, line, ':') orelse continue;
        const name = std.mem.trim(u8, line[0..colon], " \t");
        const value = std.mem.trim(u8, line[colon + 1 ..], " \t");
        if (std.ascii.eqlIgnoreCase(name, "content-length")) {
            content_length = std.fmt.parseInt(usize, value, 10) catch null;
        } else if (std.ascii.eqlIgnoreCase(name, "transfer-encoding")) {
            if (std.ascii.indexOfIgnoreCase(value, "chunked") != null) chunked = true;
        } else if (std.ascii.eqlIgnoreCase(name, "connection")) {
            if (std.ascii.eqlIgnoreCase(value, "close")) keep_alive = false;
        }
    }

    // ── body ──
    var body_len: usize = 0;
    if (is_head_like) {
        body_len = 0;
    } else if (chunked) {
        body_len = readChunked(r, out, max) catch |err| return err;
    } else if (content_length) |n| {
        if (n > max) return error.BodyOverflow;
        readExact(r, out[0..n]) catch return error.ReadFailed;
        body_len = n;
    } else {
        // No length and not chunked: read to EOF. Connection cannot be
        // reused after this.
        keep_alive = false;
        body_len = readToEnd(r, out, max) catch |err| return err;
    }

    return .{ .status = status, .body_len = body_len, .keep_alive = keep_alive };
}

/// Read one CRLF-terminated line, returning it without the trailing
/// CR/LF. A bare LF is tolerated.
fn takeLine(r: *std.Io.Reader) ![]const u8 {
    const raw = try r.takeDelimiterInclusive('\n');
    var line = raw;
    if (line.len > 0 and line[line.len - 1] == '\n') line = line[0 .. line.len - 1];
    if (line.len > 0 and line[line.len - 1] == '\r') line = line[0 .. line.len - 1];
    return line;
}

fn parseStatus(line: []const u8) ?i32 {
    // "HTTP/1.1 200 OK"
    const sp = std.mem.indexOfScalar(u8, line, ' ') orelse return null;
    var rest = line[sp + 1 ..];
    rest = std.mem.trimLeft(u8, rest, " ");
    if (rest.len < 3) return null;
    return std.fmt.parseInt(i32, rest[0..3], 10) catch null;
}

fn readExact(r: *std.Io.Reader, buf: []u8) !void {
    var got: usize = 0;
    while (got < buf.len) {
        const n = try r.readSliceShort(buf[got..]);
        if (n == 0) return error.EndOfStream;
        got += n;
    }
}

fn readToEnd(r: *std.Io.Reader, out: [*]u8, max: usize) RequestError!usize {
    var written: usize = 0;
    while (written < max) {
        // readSliceShort returns a short count (possibly 0) at EOF rather
        // than error.EndOfStream; a 0 read means the stream is done.
        const n = r.readSliceShort(out[written..max]) catch return error.ReadFailed;
        if (n == 0) break;
        written += n;
    }
    return written;
}

fn readChunked(r: *std.Io.Reader, out: [*]u8, max: usize) RequestError!usize {
    var written: usize = 0;
    while (true) {
        const size_line = takeLine(r) catch return error.ReadFailed;
        // Chunk size may carry ";ext" extensions -- strip them.
        var hex = size_line;
        if (std.mem.indexOfScalar(u8, hex, ';')) |semi| hex = hex[0..semi];
        hex = std.mem.trim(u8, hex, " \t");
        const size = std.fmt.parseInt(usize, hex, 16) catch return error.BadResponse;
        if (size == 0) {
            // Consume the trailing headers up to the final blank line.
            while (true) {
                const trailer = takeLine(r) catch return error.ReadFailed;
                if (trailer.len == 0) break;
            }
            break;
        }
        if (written + size > max) return error.BodyOverflow;
        readExact(r, out[written .. written + size]) catch return error.ReadFailed;
        written += size;
        // Each chunk is followed by CRLF.
        _ = takeLine(r) catch return error.ReadFailed;
    }
    return written;
}

// ── teardown ─────────────────────────────────────────────────

pub fn close(c: *Connection) void {
    if (c.tls_client) |t| {
        // Best-effort close_notify; ignore failures on a dead socket.
        t.end() catch {};
        gpa.destroy(t);
        gpa.free(c.tls_read_buf);
        gpa.free(c.tls_write_buf);
    }
    c.stream.close();
    gpa.free(c.sread_buf);
    gpa.free(c.swrite_buf);
    gpa.free(c.host);
    gpa.destroy(c);
}

// ── tests ────────────────────────────────────────────────────
// Network IO is excluded from the default test sweep; these cover the
// pure parsing helpers only.

test "httpcore: parseStatus" {
    try std.testing.expectEqual(@as(?i32, 200), parseStatus("HTTP/1.1 200 OK"));
    try std.testing.expectEqual(@as(?i32, 404), parseStatus("HTTP/1.1 404 Not Found"));
    try std.testing.expectEqual(@as(?i32, null), parseStatus("garbage"));
}
