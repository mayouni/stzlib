// WebSocket client (RFC 6455) -- framing, handshake, client and a loopback
// test server, all in the engine; Ring is a thin face over the C-ABI below.
//
// ws:// runs over a blocking std.net socket (the same kind tcp.zig opens);
// wss:// runs over mbedTLS (ws_tls.zig), the engine's own TLS socket path --
// the one reactor.zig uses, with the operating system's trust store and
// hostname verification ON. http.zig does NOT share it: its TLS is libcurl's
// (Schannel on Windows), a request-scoped library with no raw stream to hand
// out, so this module takes the reactor's path rather than curl's.
//
// Surface (every function is C-ABI; the Ring bridge is ring_bridge_ws.zig):
//   ws_client_new / ws_client_free
//   ws_set_* (max message, connect timeout, close wait, subprotocols, headers,
//             CA file, insecure)
//   ws_connect(client, url) -> 1 ok / 0 failed (ws_last_error says why)
//   ws_send(client, opcode, data) / ws_ping(client, data)
//   ws_recv(client, timeout_ms) -> 0 nothing yet, 1 text, 2 binary, 3 pong,
//             4 the peer closed (code + reason readable), -1 failed and closed
//   ws_last_payload_ptr/len -- the last message, binary-safe
//   ws_close(client, code, reason) -- the close handshake, bounded wait
//   ws_echo_start/stop -- a loopback echo server for guards (test support)
//
// STRICTNESS, because a frame length is attacker-controlled: nothing is
// allocated from a length before it has been checked against the configured
// maximum; a server frame that is masked, carries a reserved bit, an unknown
// opcode, a control frame over 125 bytes or fragmented, a continuation with no
// start, a text that is not UTF-8 (1007) or a message over the maximum (1009)
// closes the connection with a NAMED error and the matching close code.
//
// Timeouts are wall-clock bounded on the socket (poll), never spin loops.

const std = @import("std");
const builtin = @import("builtin");
const posix = std.posix;
const dns = @import("dns.zig");

const gpa = std.heap.c_allocator;

/// TLS is compiled out of `zig test src/ws.zig` (no mbedTLS there); every
/// other build has it. A wss:// URL in a test build fails with a named error.
pub const tls_enabled = !builtin.is_test;
const tls = if (tls_enabled) @import("ws_tls.zig") else struct {
    pub const Session = struct {};
};

pub const GUID = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";
pub const DEFAULT_MAX_MESSAGE: u64 = 16 * 1024 * 1024;
const MAX_HANDSHAKE: usize = 16 * 1024;
const CHUNK: usize = 64 * 1024;

pub const OP_CONT: u8 = 0x0;
pub const OP_TEXT: u8 = 0x1;
pub const OP_BINARY: u8 = 0x2;
pub const OP_CLOSE: u8 = 0x8;
pub const OP_PING: u8 = 0x9;
pub const OP_PONG: u8 = 0xA;

// ── Frame codec ──────────────────────────────────────────────

pub const Header = struct {
    fin: bool,
    opcode: u8,
    masked: bool,
    len: u64,
    mask: [4]u8,
    /// bytes the header occupies; the payload starts here
    header_len: usize,
};

pub const ParseError = error{
    /// not enough bytes yet: read more
    Incomplete,
    ReservedBits,
    BadOpcode,
    ControlTooLong,
    FragmentedControl,
    /// a length not minimally encoded, or with the top bit set
    BadLength,
    /// over the configured maximum (close 1009)
    TooLarge,
    /// a server frame must not be masked (close 1002)
    MaskedFromServer,
    /// a client frame must be masked (close 1002)
    UnmaskedFromClient,
};

/// Parse one frame header from `buf`. `expect_masked` is true on a server
/// reading a client, false on a client reading a server. `max_payload` bounds
/// the declared length BEFORE any caller allocates for it. Never reads past
/// `buf`; Incomplete says how the caller should proceed (read more).
pub fn parseHeader(buf: []const u8, expect_masked: bool, max_payload: u64) ParseError!Header {
    if (buf.len < 2) return error.Incomplete;
    const b0 = buf[0];
    const b1 = buf[1];
    if ((b0 & 0x70) != 0) return error.ReservedBits;
    const opcode: u8 = b0 & 0x0F;
    const fin = (b0 & 0x80) != 0;
    const control = opcode >= 0x8;
    switch (opcode) {
        OP_CONT, OP_TEXT, OP_BINARY, OP_CLOSE, OP_PING, OP_PONG => {},
        else => return error.BadOpcode,
    }
    const masked = (b1 & 0x80) != 0;
    if (masked and !expect_masked) return error.MaskedFromServer;
    if (!masked and expect_masked) return error.UnmaskedFromClient;
    const len7: u8 = b1 & 0x7F;
    var pos: usize = 2;
    var len: u64 = len7;
    if (control) {
        if (!fin) return error.FragmentedControl;
        if (len7 > 125) return error.ControlTooLong;
    } else if (len7 == 126) {
        if (buf.len < 4) return error.Incomplete;
        len = (@as(u64, buf[2]) << 8) | buf[3];
        if (len < 126) return error.BadLength;
        pos = 4;
    } else if (len7 == 127) {
        if (buf.len < 10) return error.Incomplete;
        if ((buf[2] & 0x80) != 0) return error.BadLength;
        len = std.mem.readInt(u64, buf[2..10], .big);
        if (len < 65536) return error.BadLength;
        pos = 10;
    }
    if (len > max_payload) return error.TooLarge;
    var mask: [4]u8 = .{ 0, 0, 0, 0 };
    if (masked) {
        if (buf.len < pos + 4) return error.Incomplete;
        @memcpy(&mask, buf[pos .. pos + 4]);
        pos += 4;
    }
    return .{ .fin = fin, .opcode = opcode, .masked = masked, .len = len, .mask = mask, .header_len = pos };
}

/// Write a frame header into `out`; returns its length (2 to 14 bytes).
pub fn writeHeader(out: *[14]u8, fin: bool, opcode: u8, masked: bool, len: u64, mask: [4]u8) usize {
    out[0] = (if (fin) @as(u8, 0x80) else 0) | (opcode & 0x0F);
    var pos: usize = 2;
    if (len <= 125) {
        out[1] = @intCast(len);
    } else if (len <= 65535) {
        out[1] = 126;
        std.mem.writeInt(u16, out[2..4], @intCast(len), .big);
        pos = 4;
    } else {
        out[1] = 127;
        std.mem.writeInt(u64, out[2..10], len, .big);
        pos = 10;
    }
    if (masked) {
        out[1] |= 0x80;
        @memcpy(out[pos .. pos + 4], &mask);
        pos += 4;
    }
    return pos;
}

/// XOR `data` in place with the 4-byte key, starting at key offset `start`
/// (so a payload can be masked in chunks). Eight bytes at a time.
pub fn applyMask(data: []u8, key: [4]u8, start: usize) void {
    var i: usize = 0;
    var k: usize = start & 3;
    // align the key offset first
    while (i < data.len and k != 0) : (i += 1) {
        data[i] ^= key[k];
        k = (k + 1) & 3;
    }
    const key64: u64 = @bitCast([8]u8{ key[0], key[1], key[2], key[3], key[0], key[1], key[2], key[3] });
    while (i + 8 <= data.len) : (i += 8) {
        const w: *align(1) u64 = @ptrCast(data[i..].ptr);
        w.* ^= key64;
    }
    while (i < data.len) : (i += 1) {
        data[i] ^= key[k];
        k = (k + 1) & 3;
    }
}

/// Encode a whole frame (header + payload, masked when `mask` is given) into a
/// caller buffer of at least 14 + payload.len bytes. Returns the frame length.
pub fn encodeFrame(out: []u8, fin: bool, opcode: u8, payload: []const u8, mask: ?[4]u8) usize {
    var hdr: [14]u8 = undefined;
    const hl = writeHeader(&hdr, fin, opcode, mask != null, payload.len, mask orelse .{ 0, 0, 0, 0 });
    @memcpy(out[0..hl], hdr[0..hl]);
    @memcpy(out[hl .. hl + payload.len], payload);
    if (mask) |m| applyMask(out[hl .. hl + payload.len], m, 0);
    return hl + payload.len;
}

// ── Handshake ────────────────────────────────────────────────

/// Sec-WebSocket-Accept for a key: base64(SHA-1(key ++ GUID)), 28 chars.
pub fn acceptKey(key: []const u8, out: *[28]u8) []const u8 {
    var h = std.crypto.hash.Sha1.init(.{});
    h.update(key);
    h.update(GUID);
    var digest: [20]u8 = undefined;
    h.final(&digest);
    return std.base64.standard.Encoder.encode(out, &digest);
}

/// A fresh random 16-byte key, base64 (24 chars).
pub fn newKey(out: *[24]u8) []const u8 {
    var raw: [16]u8 = undefined;
    std.crypto.random.bytes(&raw);
    return std.base64.standard.Encoder.encode(out, &raw);
}

fn eqlNoCase(a: []const u8, b: []const u8) bool {
    return std.ascii.eqlIgnoreCase(a, b);
}

/// The value of header `name` in a header block (after the first line), or
/// null. Case-insensitive name, value trimmed.
pub fn headerValue(block: []const u8, name: []const u8) ?[]const u8 {
    var it = std.mem.splitSequence(u8, block, "\r\n");
    _ = it.next(); // the request / status line
    while (it.next()) |line| {
        const colon = std.mem.indexOfScalar(u8, line, ':') orelse continue;
        if (eqlNoCase(std.mem.trim(u8, line[0..colon], " \t"), name)) {
            return std.mem.trim(u8, line[colon + 1 ..], " \t");
        }
    }
    return null;
}

/// TRUE if a comma-separated token list contains `token` (case-insensitive).
pub fn hasToken(list: []const u8, token: []const u8) bool {
    var it = std.mem.splitScalar(u8, list, ',');
    while (it.next()) |t| {
        if (eqlNoCase(std.mem.trim(u8, t, " \t"), token)) return true;
    }
    return false;
}

pub const Url = struct {
    secure: bool,
    host: []const u8,
    port: u16,
    /// path + query as written; empty or starting with ? or # gets "/" in front
    target: []const u8,
};

pub const UrlError = error{ BadScheme, NoHost, BadPort };

pub fn parseUrl(url: []const u8) UrlError!Url {
    var secure = false;
    var rest: []const u8 = undefined;
    if (url.len >= 5 and eqlNoCase(url[0..5], "ws://")) {
        rest = url[5..];
    } else if (url.len >= 6 and eqlNoCase(url[0..6], "wss://")) {
        secure = true;
        rest = url[6..];
    } else return error.BadScheme;
    const slash = std.mem.indexOfAny(u8, rest, "/?#") orelse rest.len;
    const authority = rest[0..slash];
    // the request target as written; empty or starting with ? means "/" + it
    const target = rest[slash..];
    if (authority.len == 0) return error.NoHost;
    var host = authority;
    var port: u16 = if (secure) 443 else 80;
    if (authority[0] == '[') {
        const close = std.mem.indexOfScalar(u8, authority, ']') orelse return error.NoHost;
        host = authority[1..close];
        if (close + 1 < authority.len) {
            if (authority[close + 1] != ':') return error.BadPort;
            port = std.fmt.parseInt(u16, authority[close + 2 ..], 10) catch return error.BadPort;
        }
    } else if (std.mem.lastIndexOfScalar(u8, authority, ':')) |c| {
        host = authority[0..c];
        port = std.fmt.parseInt(u16, authority[c + 1 ..], 10) catch return error.BadPort;
    }
    if (host.len == 0) return error.NoHost;
    return .{ .secure = secure, .host = host, .port = port, .target = target };
}

// ── Transport: a blocking socket, plain or TLS, with timed reads ─

const ReadError = error{ Timeout, Closed, Failed };

fn setNonBlocking(sock: posix.socket_t, on: bool) void {
    if (builtin.os.tag == .windows) {
        var mode: u32 = if (on) 1 else 0;
        _ = std.os.windows.ws2_32.ioctlsocket(sock, std.os.windows.ws2_32.FIONBIO, &mode);
    } else {
        const fl = posix.fcntl(sock, posix.F.GETFL, 0) catch return;
        var o: posix.O = @bitCast(@as(u32, @intCast(fl)));
        o.NONBLOCK = on;
        _ = posix.fcntl(sock, posix.F.SETFL, @as(u32, @bitCast(o))) catch {};
    }
}

/// Wait for the socket to be readable; false on timeout.
fn waitReadable(sock: posix.socket_t, timeout_ms: i32) ReadError!void {
    var pfd = [_]posix.pollfd{.{ .fd = sock, .events = posix.POLL.IN, .revents = 0 }};
    const ready = posix.poll(&pfd, timeout_ms) catch return error.Failed;
    if (ready == 0) return error.Timeout;
}

pub const Transport = struct {
    sock: posix.socket_t,
    tls: ?*tls.Session = null,

    /// Connect a plain socket within `timeout_ms` (0 = the system's own limit).
    pub fn connectPlain(addr: std.net.Address, timeout_ms: u32) error{ Timeout, Refused, Failed }!Transport {
        const sock = posix.socket(addr.any.family, posix.SOCK.STREAM, posix.IPPROTO.TCP) catch return error.Failed;
        errdefer posix.close(sock);
        if (timeout_ms == 0) {
            posix.connect(sock, &addr.any, addr.getOsSockLen()) catch |e| return if (e == error.ConnectionRefused) error.Refused else error.Failed;
            return .{ .sock = sock };
        }
        setNonBlocking(sock, true);
        posix.connect(sock, &addr.any, addr.getOsSockLen()) catch |e| switch (e) {
            error.WouldBlock => {
                var pfd = [_]posix.pollfd{.{ .fd = sock, .events = posix.POLL.OUT, .revents = 0 }};
                const ready = posix.poll(&pfd, @intCast(timeout_ms)) catch return error.Failed;
                if (ready == 0) return error.Timeout;
                // connected iff the socket has a peer
                var peer: posix.sockaddr.storage = undefined;
                var plen: posix.socklen_t = @sizeOf(posix.sockaddr.storage);
                posix.getpeername(sock, @ptrCast(&peer), &plen) catch return error.Refused;
            },
            error.ConnectionRefused => return error.Refused,
            else => return error.Failed,
        };
        setNonBlocking(sock, false);
        return .{ .sock = sock };
    }

    /// Read what is there, waiting at most `timeout_ms` (-1 = forever). Never 0.
    pub fn readSome(self: *Transport, buf: []u8, timeout_ms: i32) ReadError!usize {
        if (self.tls) |s| {
            if (comptime tls_enabled) return tls.read(s, buf, timeout_ms);
            return error.Failed;
        }
        try waitReadable(self.sock, timeout_ms);
        const n = posix.recv(self.sock, buf, 0) catch return error.Failed;
        if (n == 0) return error.Closed;
        return n;
    }

    pub fn writeAll(self: *Transport, bytes: []const u8) error{Failed}!void {
        if (self.tls) |s| {
            if (comptime tls_enabled) return tls.writeAll(s, bytes);
            return error.Failed;
        }
        var off: usize = 0;
        while (off < bytes.len) {
            const n = posix.send(self.sock, bytes[off..], 0) catch return error.Failed;
            if (n == 0) return error.Failed;
            off += n;
        }
    }

    pub fn close(self: *Transport) void {
        if (self.tls) |s| {
            if (comptime tls_enabled) tls.deinit(s);
            self.tls = null;
        }
        posix.shutdown(self.sock, .both) catch {};
        posix.close(self.sock);
    }
};

// ── Client ───────────────────────────────────────────────────

const State = enum { idle, open, closing, closed };

pub const Client = struct {
    tr: ?Transport = null,
    state: State = .idle,
    /// undecoded bytes from the peer; rpos is how far they were consumed
    rbuf: std.ArrayList(u8) = .{},
    rpos: usize = 0,
    /// the message being assembled from fragments
    msg: std.ArrayList(u8) = .{},
    msg_opcode: u8 = 0,
    fragmented: bool = false,
    /// the last delivered payload (text, binary, pong data or close reason)
    last: std.ArrayList(u8) = .{},
    last_kind: i32 = 0,

    max_message: u64 = DEFAULT_MAX_MESSAGE,
    connect_timeout_ms: u32 = 5000,
    close_wait_ms: u32 = 2000,
    insecure: bool = false,
    subprotocols: std.ArrayList(u8) = .{},
    headers: std.ArrayList(u8) = .{},
    ca_file: std.ArrayList(u8) = .{},
    negotiated: std.ArrayList(u8) = .{},

    close_code: i32 = 0,
    close_reason: std.ArrayList(u8) = .{},
    close_by_peer: bool = false,
    /// the peer answered our close (or started the close): the handshake ran
    close_handshake_done: bool = false,
    close_sent: bool = false,

    err_buf: [256]u8 = undefined,
    err_len: usize = 0,

    pings_received: u32 = 0,
    pongs_sent: u32 = 0,
    frames_sent: u32 = 0,

    fn setErr(self: *Client, comptime fmt: []const u8, args: anytype) void {
        const s = std.fmt.bufPrint(&self.err_buf, fmt, args) catch {
            self.err_len = self.err_buf.len;
            return;
        };
        self.err_len = s.len;
    }

    pub fn lastError(self: *const Client) []const u8 {
        return self.err_buf[0..self.err_len];
    }

    fn clearErr(self: *Client) void {
        self.err_len = 0;
    }

    pub fn deinit(self: *Client) void {
        if (self.tr) |*t| t.close();
        self.tr = null;
        self.rbuf.deinit(gpa);
        self.msg.deinit(gpa);
        self.last.deinit(gpa);
        self.subprotocols.deinit(gpa);
        self.headers.deinit(gpa);
        self.ca_file.deinit(gpa);
        self.negotiated.deinit(gpa);
        self.close_reason.deinit(gpa);
    }

    fn setText(list: *std.ArrayList(u8), v: []const u8) void {
        list.clearRetainingCapacity();
        list.appendSlice(gpa, v) catch {};
    }

    // ── connect + handshake ──

    pub fn connect(self: *Client, url: []const u8) bool {
        self.clearErr();
        if (self.state != .idle and self.state != .closed) {
            self.setErr("already open", .{});
            return false;
        }
        const u = parseUrl(url) catch |e| {
            switch (e) {
                error.BadScheme => {
                    // the scheme as written, lower-cased, or "none" when there is no ://
                    var sbuf: [32]u8 = undefined;
                    var shown: []const u8 = "none";
                    if (std.mem.indexOf(u8, url, "://")) |sep| {
                        if (sep > 0 and sep <= sbuf.len) shown = std.ascii.lowerString(sbuf[0..sep], url[0..sep]);
                    }
                    self.setErr("Bad WebSocket scheme: {s} (use ws:// or wss://)", .{shown});
                },
                error.NoHost => self.setErr("Bad WebSocket address: no host after {s}://", .{if (url.len >= 4 and std.ascii.eqlIgnoreCase(url[0..3], "wss")) "wss" else "ws"}),
                error.BadPort => self.setErr("Bad WebSocket address: the port is not a number", .{}),
            }
            return false;
        };
        if (u.secure and !tls_enabled) {
            self.setErr("wss not available in this build", .{});
            return false;
        }
        const addr = dns.lookup(u.host, u.port) catch {
            self.setErr("connect failed: dns resolution failed", .{});
            return false;
        };
        var tr = Transport.connectPlain(addr, self.connect_timeout_ms) catch |e| {
            switch (e) {
                error.Timeout => self.setErr("connect timed out after {d} ms", .{self.connect_timeout_ms}),
                error.Refused => self.setErr("connect failed: ConnectionRefused", .{}),
                error.Failed => self.setErr("connect failed", .{}),
            }
            return false;
        };
        if (u.secure) {
            if (comptime tls_enabled) {
                tr.tls = tls.connect(tr.sock, u.host, self.ca_file.items, self.insecure, self.connect_timeout_ms) catch |e| {
                    self.setErr("tls: {s}", .{tls.describe(e)});
                    tr.close();
                    return false;
                };
            }
        }
        self.tr = tr;
        self.rbuf.clearRetainingCapacity();
        self.rpos = 0;
        self.msg.clearRetainingCapacity();
        self.fragmented = false;
        self.negotiated.clearRetainingCapacity();
        self.close_code = 0;
        self.close_reason.clearRetainingCapacity();
        self.close_by_peer = false;
        self.close_handshake_done = false;
        self.close_sent = false;
        self.pings_received = 0;
        self.pongs_sent = 0;
        self.frames_sent = 0;

        if (!self.handshake(u)) {
            self.tr.?.close();
            self.tr = null;
            self.state = .closed;
            return false;
        }
        self.state = .open;
        return true;
    }

    fn handshake(self: *Client, u: Url) bool {
        const tr: *Transport = if (self.tr) |*t| t else return false;
        var key_buf: [24]u8 = undefined;
        const key = newKey(&key_buf);
        var expect_buf: [28]u8 = undefined;
        const expect = acceptKey(key, &expect_buf);

        var req: std.ArrayList(u8) = .{};
        defer req.deinit(gpa);
        const w = req.writer(gpa);
        w.writeAll("GET ") catch return false;
        if (u.target.len == 0 or u.target[0] != '/') w.writeAll("/") catch return false;
        w.print("{s} HTTP/1.1\r\nHost: {s}", .{ u.target, u.host }) catch return false;
        const default_port: u16 = if (u.secure) 443 else 80;
        if (u.port != default_port) w.print(":{d}", .{u.port}) catch return false;
        w.print("\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Key: {s}\r\nSec-WebSocket-Version: 13\r\n", .{key}) catch return false;
        if (self.subprotocols.items.len > 0) w.print("Sec-WebSocket-Protocol: {s}\r\n", .{self.subprotocols.items}) catch return false;
        // extra headers: "Name: Value" lines, newline-separated
        var hit = std.mem.splitScalar(u8, self.headers.items, '\n');
        while (hit.next()) |raw| {
            const line = std.mem.trim(u8, raw, " \t\r");
            if (line.len == 0) continue;
            w.print("{s}\r\n", .{line}) catch return false;
        }
        w.writeAll("\r\n") catch return false;
        tr.writeAll(req.items) catch {
            self.setErr("handshake: send failed", .{});
            return false;
        };

        // read the response head, bounded in size and time
        const deadline = std.time.milliTimestamp() + @as(i64, self.connect_timeout_ms);
        var head_end: usize = 0;
        while (true) {
            if (std.mem.indexOf(u8, self.rbuf.items, "\r\n\r\n")) |he| {
                head_end = he + 4;
                break;
            }
            if (self.rbuf.items.len >= MAX_HANDSHAKE) {
                self.setErr("handshake: response head over {d} bytes", .{MAX_HANDSHAKE});
                return false;
            }
            const left = deadline - std.time.milliTimestamp();
            if (left <= 0) {
                self.setErr("handshake: timed out after {d} ms", .{self.connect_timeout_ms});
                return false;
            }
            self.rbuf.ensureUnusedCapacity(gpa, 4096) catch return false;
            const spare = self.rbuf.unusedCapacitySlice();
            const n = tr.readSome(spare, @intCast(left)) catch |e| {
                switch (e) {
                    error.Timeout => self.setErr("handshake: timed out after {d} ms", .{self.connect_timeout_ms}),
                    error.Closed => self.setErr("handshake: the server closed before answering", .{}),
                    error.Failed => self.setErr("handshake: read failed", .{}),
                }
                return false;
            };
            self.rbuf.items.len += n;
        }
        const head = self.rbuf.items[0..head_end];
        // status line
        const eol = std.mem.indexOf(u8, head, "\r\n") orelse 0;
        const status_line = head[0..eol];
        if (status_line.len < 12 or !std.mem.startsWith(u8, status_line, "HTTP/1.1 ")) {
            self.setErr("handshake: not an HTTP/1.1 response", .{});
            return false;
        }
        const status = std.fmt.parseInt(u16, status_line[9..12], 10) catch 0;
        if (status != 101) {
            self.setErr("handshake: status {d} not 101", .{status});
            return false;
        }
        const upgrade = headerValue(head, "Upgrade") orelse {
            self.setErr("handshake: no Upgrade header", .{});
            return false;
        };
        if (!eqlNoCase(upgrade, "websocket")) {
            self.setErr("handshake: Upgrade is not websocket", .{});
            return false;
        }
        const conn = headerValue(head, "Connection") orelse {
            self.setErr("handshake: no Connection header", .{});
            return false;
        };
        if (!hasToken(conn, "upgrade")) {
            self.setErr("handshake: Connection lacks upgrade", .{});
            return false;
        }
        const accept = headerValue(head, "Sec-WebSocket-Accept") orelse {
            self.setErr("handshake: Sec-WebSocket-Accept missing", .{});
            return false;
        };
        if (!std.mem.eql(u8, accept, expect)) {
            self.setErr("handshake: Sec-WebSocket-Accept mismatch", .{});
            return false;
        }
        if (headerValue(head, "Sec-WebSocket-Extensions")) |ext| {
            if (ext.len > 0) {
                self.setErr("handshake: extension not negotiated: {s}", .{ext});
                return false;
            }
        }
        if (headerValue(head, "Sec-WebSocket-Protocol")) |proto| {
            if (proto.len > 0) {
                if (!hasToken(self.subprotocols.items, proto)) {
                    self.setErr("handshake: subprotocol not offered: {s}", .{proto});
                    return false;
                }
                setText(&self.negotiated, proto);
            }
        }
        // whatever followed the head is the first frame bytes
        self.rpos = head_end;
        self.compact();
        return true;
    }

    fn compact(self: *Client) void {
        if (self.rpos == 0) return;
        const remaining = self.rbuf.items.len - self.rpos;
        if (remaining > 0) std.mem.copyForwards(u8, self.rbuf.items[0..remaining], self.rbuf.items[self.rpos..]);
        self.rbuf.items.len = remaining;
        self.rpos = 0;
    }

    // ── sending ──

    fn sendFrame(self: *Client, fin: bool, opcode: u8, payload: []const u8) bool {
        const tr: *Transport = if (self.tr) |*t| t else return false;
        var mask: [4]u8 = undefined;
        std.crypto.random.bytes(&mask);
        var hdr: [14]u8 = undefined;
        const hl = writeHeader(&hdr, fin, opcode, true, payload.len, mask);
        tr.writeAll(hdr[0..hl]) catch {
            self.setErr("send failed", .{});
            return false;
        };
        // mask and write in chunks: no allocation the size of the payload
        var chunk: [CHUNK]u8 = undefined;
        var off: usize = 0;
        while (off < payload.len) {
            const n = @min(CHUNK, payload.len - off);
            @memcpy(chunk[0..n], payload[off .. off + n]);
            applyMask(chunk[0..n], mask, off);
            tr.writeAll(chunk[0..n]) catch {
                self.setErr("send failed", .{});
                return false;
            };
            off += n;
        }
        self.frames_sent += 1;
        return true;
    }

    /// Send a text (1) or binary (2) message in one frame.
    pub fn send(self: *Client, opcode: u8, payload: []const u8) bool {
        self.clearErr();
        if (self.state != .open) {
            self.setErr("not open", .{});
            return false;
        }
        if (opcode != OP_TEXT and opcode != OP_BINARY) {
            self.setErr("send: opcode must be 1 (text) or 2 (binary)", .{});
            return false;
        }
        if (opcode == OP_TEXT and !std.unicode.utf8ValidateSlice(payload)) {
            self.setErr("send: text is not valid UTF-8 (send it as binary)", .{});
            return false;
        }
        return self.sendFrame(true, opcode, payload);
    }

    /// Send a message as `parts` fragments (test support: the receiver must
    /// reassemble). Parts of 0 are sent as one frame.
    pub fn sendFragmented(self: *Client, opcode: u8, payload: []const u8, parts: usize) bool {
        self.clearErr();
        if (self.state != .open) {
            self.setErr("not open", .{});
            return false;
        }
        if (parts <= 1 or payload.len < parts) return self.sendFrame(true, opcode, payload);
        const each = payload.len / parts;
        var i: usize = 0;
        var off: usize = 0;
        while (i < parts) : (i += 1) {
            const last = i == parts - 1;
            const end = if (last) payload.len else off + each;
            const op: u8 = if (i == 0) opcode else OP_CONT;
            if (!self.sendFrame(last, op, payload[off..end])) return false;
            off = end;
        }
        return true;
    }

    pub fn ping(self: *Client, payload: []const u8) bool {
        self.clearErr();
        if (self.state != .open) {
            self.setErr("not open", .{});
            return false;
        }
        if (payload.len > 125) {
            self.setErr("ping: payload over 125 bytes", .{});
            return false;
        }
        return self.sendFrame(true, OP_PING, payload);
    }

    // ── receiving ──

    /// Close the connection on a protocol failure: send a close frame with
    /// `code`, record the reason as LastError, tear the transport down.
    fn fail(self: *Client, code: u16, comptime what: []const u8, args: anytype) i32 {
        self.setErr(what, args);
        var reason: [125]u8 = undefined;
        const r = std.fmt.bufPrint(&reason, what, args) catch "protocol error";
        if (self.tr != null and !self.close_sent and self.state == .open) {
            var body: [127]u8 = undefined;
            std.mem.writeInt(u16, body[0..2], code, .big);
            const rl = @min(r.len, 123);
            @memcpy(body[2 .. 2 + rl], r[0..rl]);
            // what sat in the buffer was the violation itself: drop it, then wait for the answer
            self.rbuf.clearRetainingCapacity();
            self.rpos = 0;
            if (self.sendFrame(true, OP_CLOSE, body[0 .. 2 + rl])) self.drainForClose(@min(self.close_wait_ms, 1000));
            self.close_sent = true;
            self.setErr(what, args); // the send may have failed on a dead socket: the cause stays the named one
        }
        self.close_code = code;
        setText(&self.close_reason, r);
        self.close_by_peer = false;
        self.teardown();
        return -1;
    }

    /// After our close frame: wait at most `ms` for the peer's close, skipping
    /// anything else; never a failure, the socket is being torn down anyway.
    fn drainForClose(self: *Client, ms: u32) void {
        const tr: *Transport = if (self.tr) |*t| t else return;
        const deadline = std.time.milliTimestamp() + @as(i64, ms);
        while (true) {
            const avail = self.rbuf.items[self.rpos..];
            const hdr = parseHeader(avail, false, self.max_message) catch |e| switch (e) {
                error.Incomplete => {
                    const left = deadline - std.time.milliTimestamp();
                    if (left <= 0) return;
                    self.compact();
                    self.rbuf.ensureUnusedCapacity(gpa, 4096) catch return;
                    const n = tr.readSome(self.rbuf.unusedCapacitySlice(), @intCast(left)) catch return;
                    self.rbuf.items.len += n;
                    continue;
                },
                else => return,
            };
            const need: usize = hdr.header_len + @as(usize, @intCast(hdr.len));
            if (avail.len < need) {
                const left = deadline - std.time.milliTimestamp();
                if (left <= 0) return;
                self.compact();
                self.rbuf.ensureTotalCapacity(gpa, need) catch return;
                const n = tr.readSome(self.rbuf.unusedCapacitySlice(), @intCast(left)) catch return;
                self.rbuf.items.len += n;
                continue;
            }
            self.rpos += need;
            if (hdr.opcode == OP_CLOSE) {
                self.close_handshake_done = true;
                return;
            }
        }
    }

    fn teardown(self: *Client) void {
        if (self.tr) |*t| t.close();
        self.tr = null;
        self.state = .closed;
        self.fragmented = false;
        self.msg.clearRetainingCapacity();
    }

    /// Wait for the next message. Returns 0 when nothing arrived within
    /// `timeout_ms` (0 = poll once, -1 = wait forever), 1 text, 2 binary,
    /// 3 pong, 4 the peer closed (handshake answered), -1 failed (closed).
    pub fn recv(self: *Client, timeout_ms: i32) i32 {
        self.clearErr();
        if (self.state != .open and self.state != .closing) {
            self.setErr("not open", .{});
            return -1;
        }
        const start = std.time.milliTimestamp();
        while (true) {
            const avail = self.rbuf.items[self.rpos..];
            const hdr = parseHeader(avail, false, self.max_message) catch |e| switch (e) {
                error.Incomplete => {
                    // read more, within the time left
                    var wait: i32 = timeout_ms;
                    if (timeout_ms > 0) {
                        const spent = std.time.milliTimestamp() - start;
                        if (spent >= timeout_ms) return 0;
                        wait = @intCast(timeout_ms - spent);
                    }
                    self.compact();
                    self.rbuf.ensureUnusedCapacity(gpa, 4096) catch return self.fail(1011, "out of memory", .{});
                    const tr: *Transport = if (self.tr) |*t| t else return self.fail(1006, "connection lost", .{});
                    const n = tr.readSome(self.rbuf.unusedCapacitySlice(), wait) catch |re| switch (re) {
                        error.Timeout => return 0,
                        error.Closed => {
                            if (self.rbuf.items.len > 0 or self.fragmented) return self.fail(1006, "connection closed mid-frame", .{});
                            if (self.state == .closing) {
                                // we sent close; the peer just dropped the socket
                                self.teardown();
                                return 4;
                            }
                            return self.fail(1006, "connection closed without a close frame", .{});
                        },
                        error.Failed => return self.fail(1006, "read failed", .{}),
                    };
                    self.rbuf.items.len += n;
                    continue;
                },
                error.ReservedBits => return self.fail(1002, "protocol: reserved bits set", .{}),
                error.BadOpcode => return self.fail(1002, "protocol: bad opcode {d}", .{avail[0] & 0x0F}),
                error.ControlTooLong => return self.fail(1002, "protocol: control frame over 125 bytes", .{}),
                error.FragmentedControl => return self.fail(1002, "protocol: fragmented control frame", .{}),
                error.BadLength => return self.fail(1002, "protocol: bad length encoding", .{}),
                error.TooLarge => return self.fail(1009, "protocol: frame over max {d} bytes (1009)", .{self.max_message}),
                error.MaskedFromServer => return self.fail(1002, "protocol: masked server frame", .{}),
                error.UnmaskedFromClient => unreachable,
            };
            // the whole payload must be in the buffer (its length is already
            // checked against the maximum, so growing to it is safe)
            const need: usize = hdr.header_len + @as(usize, @intCast(hdr.len));
            if (avail.len < need) {
                // the assembled message must also stay under the maximum
                if (self.fragmented and hdr.opcode == OP_CONT and self.msg.items.len + hdr.len > self.max_message)
                    return self.fail(1009, "protocol: message over max {d} bytes (1009)", .{self.max_message});
                var wait: i32 = timeout_ms;
                if (timeout_ms > 0) {
                    const spent = std.time.milliTimestamp() - start;
                    if (spent >= timeout_ms) return 0;
                    wait = @intCast(timeout_ms - spent);
                }
                self.compact();
                self.rbuf.ensureTotalCapacity(gpa, need) catch return self.fail(1011, "out of memory", .{});
                const tr: *Transport = if (self.tr) |*t| t else return self.fail(1006, "connection lost", .{});
                const n = tr.readSome(self.rbuf.unusedCapacitySlice(), wait) catch |re| switch (re) {
                    error.Timeout => return 0,
                    error.Closed => return self.fail(1006, "connection closed mid-frame", .{}),
                    error.Failed => return self.fail(1006, "read failed", .{}),
                };
                self.rbuf.items.len += n;
                continue;
            }
            const payload = avail[hdr.header_len..need];
            self.rpos += need;
            switch (hdr.opcode) {
                OP_PING => {
                    self.pings_received += 1;
                    if (self.state == .open and self.sendFrame(true, OP_PONG, payload)) self.pongs_sent += 1;
                    continue;
                },
                OP_PONG => {
                    setText(&self.last, payload);
                    self.last_kind = 3;
                    return 3;
                },
                OP_CLOSE => {
                    var code: u16 = 1005; // no status received
                    var reason: []const u8 = "";
                    if (payload.len == 1) return self.fail(1002, "protocol: close frame with a 1-byte body", .{});
                    if (payload.len >= 2) {
                        code = std.mem.readInt(u16, payload[0..2], .big);
                        reason = payload[2..];
                        if (!validCloseCode(code)) return self.fail(1002, "protocol: bad close code {d}", .{code});
                        if (!std.unicode.utf8ValidateSlice(reason)) return self.fail(1007, "protocol: close reason is not UTF-8 (1007)", .{});
                    }
                    if (self.state == .open or payload.len >= 2) self.close_code = code;
                    if (self.state == .open or reason.len > 0) setText(&self.close_reason, reason);
                    self.close_by_peer = self.state == .open;
                    self.close_handshake_done = true;
                    if (!self.close_sent) {
                        // answer with the same code (or 1000 when none was sent)
                        var body: [2]u8 = undefined;
                        std.mem.writeInt(u16, body[0..2], code, .big);
                        _ = self.sendFrame(true, OP_CLOSE, if (payload.len >= 2) body[0..2] else body[0..0]);
                        self.close_sent = true;
                    }
                    setText(&self.last, reason);
                    self.last_kind = 4;
                    self.teardown();
                    return 4;
                },
                OP_TEXT, OP_BINARY => {
                    if (self.fragmented) return self.fail(1002, "protocol: new message while fragmented", .{});
                    if (hdr.fin) {
                        if (hdr.opcode == OP_TEXT and !std.unicode.utf8ValidateSlice(payload))
                            return self.fail(1007, "protocol: invalid UTF-8 in text (1007)", .{});
                        setText(&self.last, payload);
                        self.last_kind = @intCast(hdr.opcode);
                        return self.last_kind;
                    }
                    self.fragmented = true;
                    self.msg_opcode = hdr.opcode;
                    self.msg.clearRetainingCapacity();
                    self.msg.appendSlice(gpa, payload) catch return self.fail(1011, "out of memory", .{});
                    continue;
                },
                OP_CONT => {
                    if (!self.fragmented) return self.fail(1002, "protocol: continuation without a start", .{});
                    if (self.msg.items.len + payload.len > self.max_message)
                        return self.fail(1009, "protocol: message over max {d} bytes (1009)", .{self.max_message});
                    self.msg.appendSlice(gpa, payload) catch return self.fail(1011, "out of memory", .{});
                    if (!hdr.fin) continue;
                    self.fragmented = false;
                    if (self.msg_opcode == OP_TEXT and !std.unicode.utf8ValidateSlice(self.msg.items))
                        return self.fail(1007, "protocol: invalid UTF-8 in text (1007)", .{});
                    // hand the assembled message over without a copy
                    const done = self.msg;
                    self.msg = self.last;
                    self.last = done;
                    self.msg.clearRetainingCapacity();
                    self.last_kind = @intCast(self.msg_opcode);
                    return self.last_kind;
                },
                else => unreachable,
            }
        }
    }

    // ── closing ──

    /// Start the close handshake with `code` and `reason`, wait up to
    /// close_wait_ms for the peer's close, then close the socket. On a client
    /// that is not open it does nothing. Returns true when the peer answered.
    pub fn close(self: *Client, code: u16, reason: []const u8) bool {
        if (self.state != .open) return false;
        self.clearErr();
        var body: [125]u8 = undefined;
        std.mem.writeInt(u16, body[0..2], code, .big);
        const rl = @min(reason.len, 123);
        @memcpy(body[2 .. 2 + rl], reason[0..rl]);
        self.close_code = code;
        setText(&self.close_reason, reason[0..rl]);
        self.close_by_peer = false;
        if (self.sendFrame(true, OP_CLOSE, body[0 .. 2 + rl])) {
            self.close_sent = true;
            self.state = .closing;
            // drain until the peer's close (4), or the wait runs out
            const deadline = std.time.milliTimestamp() + @as(i64, self.close_wait_ms);
            while (self.state == .closing) {
                const left = deadline - std.time.milliTimestamp();
                if (left <= 0) break;
                const k = self.recv(@intCast(left));
                if (k == 4 or k == -1) break;
                if (k == 0) break;
                // data frames that were in flight are dropped
            }
        }
        if (self.state != .closed) {
            self.teardown();
        }
        return self.close_handshake_done;
    }
};

pub fn validCloseCode(code: u16) bool {
    return switch (code) {
        1000...1003, 1007...1011 => true,
        3000...4999 => true,
        else => false,
    };
}

// ── C ABI ─────────────────────────────────────────────────────

pub fn ws_client_new() callconv(.c) ?*Client {
    const c = gpa.create(Client) catch return null;
    c.* = .{};
    return c;
}

pub fn ws_client_free(c: ?*Client) callconv(.c) void {
    const cl = c orelse return;
    cl.deinit();
    gpa.destroy(cl);
}

pub fn ws_set_max_message(c: ?*Client, max: u64) callconv(.c) void {
    const cl = c orelse return;
    cl.max_message = if (max == 0) DEFAULT_MAX_MESSAGE else max;
}

pub fn ws_set_connect_timeout(c: ?*Client, ms: u32) callconv(.c) void {
    const cl = c orelse return;
    cl.connect_timeout_ms = ms;
}

pub fn ws_set_close_wait(c: ?*Client, ms: u32) callconv(.c) void {
    const cl = c orelse return;
    cl.close_wait_ms = ms;
}

pub fn ws_set_subprotocols(c: ?*Client, p: [*]const u8, len: usize) callconv(.c) void {
    const cl = c orelse return;
    Client.setText(&cl.subprotocols, p[0..len]);
}

pub fn ws_set_headers(c: ?*Client, p: [*]const u8, len: usize) callconv(.c) void {
    const cl = c orelse return;
    Client.setText(&cl.headers, p[0..len]);
}

pub fn ws_set_ca_file(c: ?*Client, p: [*]const u8, len: usize) callconv(.c) void {
    const cl = c orelse return;
    Client.setText(&cl.ca_file, p[0..len]);
}

pub fn ws_set_insecure(c: ?*Client, on: i32) callconv(.c) void {
    const cl = c orelse return;
    cl.insecure = on != 0;
}

pub fn ws_connect(c: ?*Client, url: [*]const u8, len: usize) callconv(.c) i32 {
    const cl = c orelse return 0;
    return if (cl.connect(url[0..len])) 1 else 0;
}

pub fn ws_send(c: ?*Client, opcode: u8, data: [*]const u8, len: usize) callconv(.c) i32 {
    const cl = c orelse return 0;
    return if (cl.send(opcode, data[0..len])) 1 else 0;
}

pub fn ws_send_fragmented(c: ?*Client, opcode: u8, data: [*]const u8, len: usize, parts: u32) callconv(.c) i32 {
    const cl = c orelse return 0;
    return if (cl.sendFragmented(opcode, data[0..len], parts)) 1 else 0;
}

pub fn ws_ping(c: ?*Client, data: [*]const u8, len: usize) callconv(.c) i32 {
    const cl = c orelse return 0;
    return if (cl.ping(data[0..len])) 1 else 0;
}

pub fn ws_recv(c: ?*Client, timeout_ms: i32) callconv(.c) i32 {
    const cl = c orelse return -1;
    return cl.recv(timeout_ms);
}

pub fn ws_last_payload_len(c: ?*Client) callconv(.c) usize {
    const cl = c orelse return 0;
    return cl.last.items.len;
}

pub fn ws_last_payload_ptr(c: ?*Client) callconv(.c) [*]const u8 {
    const cl = c orelse return "";
    return cl.last.items.ptr;
}

pub fn ws_last_kind(c: ?*Client) callconv(.c) i32 {
    const cl = c orelse return 0;
    return cl.last_kind;
}

pub fn ws_close(c: ?*Client, code: u16, reason: [*]const u8, len: usize) callconv(.c) i32 {
    const cl = c orelse return 0;
    return if (cl.close(code, reason[0..len])) 1 else 0;
}

pub fn ws_is_open(c: ?*Client) callconv(.c) i32 {
    const cl = c orelse return 0;
    return if (cl.state == .open) 1 else 0;
}

pub fn ws_close_code(c: ?*Client) callconv(.c) i32 {
    const cl = c orelse return 0;
    return cl.close_code;
}

pub fn ws_close_reason_len(c: ?*Client) callconv(.c) usize {
    const cl = c orelse return 0;
    return cl.close_reason.items.len;
}

pub fn ws_close_reason_ptr(c: ?*Client) callconv(.c) [*]const u8 {
    const cl = c orelse return "";
    return cl.close_reason.items.ptr;
}

pub fn ws_close_by_peer(c: ?*Client) callconv(.c) i32 {
    const cl = c orelse return 0;
    return if (cl.close_by_peer) 1 else 0;
}

pub fn ws_close_handshake_done(c: ?*Client) callconv(.c) i32 {
    const cl = c orelse return 0;
    return if (cl.close_handshake_done) 1 else 0;
}

pub fn ws_subprotocol_len(c: ?*Client) callconv(.c) usize {
    const cl = c orelse return 0;
    return cl.negotiated.items.len;
}

pub fn ws_subprotocol_ptr(c: ?*Client) callconv(.c) [*]const u8 {
    const cl = c orelse return "";
    return cl.negotiated.items.ptr;
}

pub fn ws_last_error_len(c: ?*Client) callconv(.c) usize {
    const cl = c orelse return 0;
    return cl.err_len;
}

pub fn ws_last_error_ptr(c: ?*Client) callconv(.c) [*]const u8 {
    const cl = c orelse return "";
    return &cl.err_buf;
}

pub fn ws_pings_received(c: ?*Client) callconv(.c) u32 {
    const cl = c orelse return 0;
    return cl.pings_received;
}

pub fn ws_pongs_sent(c: ?*Client) callconv(.c) u32 {
    const cl = c orelse return 0;
    return cl.pongs_sent;
}

pub fn ws_frames_sent(c: ?*Client) callconv(.c) u32 {
    const cl = c orelse return 0;
    return cl.frames_sent;
}

/// TRUE if two byte strings are the same length and every byte agrees
/// (memcmp, so a NUL inside counts) -- for guards comparing binary payloads.
pub fn ws_bytes_equal(a: [*]const u8, alen: usize, b: [*]const u8, blen: usize) callconv(.c) i32 {
    if (alen != blen) return 0;
    return if (std.mem.eql(u8, a[0..alen], b[0..blen])) 1 else 0;
}

/// Fill `out` with a deterministic byte pattern that covers every value 0..255
/// (so NUL and 0xFF are in it) -- test support for large payloads.
pub fn ws_pattern(out: [*]u8, len: usize, seed: u32) callconv(.c) void {
    var x: u32 = seed *% 2654435761 +% 1;
    var i: usize = 0;
    while (i < len) : (i += 1) {
        x = x *% 1664525 +% 1013904223;
        out[i] = @truncate(x >> 24);
    }
}

// ── Test echo server (test support) ──────────────────────────
//
// A loopback server for the guards: accepts, handshakes, echoes text and
// binary (fragments reassembled, echoed as one frame), answers pings, and
// completes the close handshake. A text message starting with "!" is a
// COMMAND that makes the server misbehave on purpose, so a client can be
// shown refusing each violation (see `command`). The handshake mode set
// before a connection makes the HANDSHAKE misbehave.

pub const Echo = @import("ws_echo.zig");

// ── Tests: the RFC 6455 vectors ──────────────────────────────

const testing = std.testing;

test "ws: accept key for the RFC sample nonce" {
    var out: [28]u8 = undefined;
    const a = acceptKey("dGhlIHNhbXBsZSBub25jZQ==", &out);
    try testing.expectEqualStrings("s3pPLMBiTxaQ9kYGzzhZRbK+xOo=", a);
}

test "ws: a wrong nonce does not give the sample accept" {
    var out: [28]u8 = undefined;
    const a = acceptKey("dGhlIHNhbXBsZSBub25jZR==", &out);
    try testing.expect(!std.mem.eql(u8, a, "s3pPLMBiTxaQ9kYGzzhZRbK+xOo="));
}

test "ws: 5.7 unmasked Hello 81 05 48 65 6c 6c 6f" {
    var buf: [32]u8 = undefined;
    const n = encodeFrame(&buf, true, OP_TEXT, "Hello", null);
    try testing.expectEqualSlices(u8, &.{ 0x81, 0x05, 0x48, 0x65, 0x6c, 0x6c, 0x6f }, buf[0..n]);
    const h = try parseHeader(buf[0..n], false, DEFAULT_MAX_MESSAGE);
    try testing.expect(h.fin and h.opcode == OP_TEXT and !h.masked and h.len == 5 and h.header_len == 2);
}

test "ws: 5.7 masked Hello 81 85 37 fa 21 3d 7f 9f 4d 51 58" {
    var buf: [32]u8 = undefined;
    const n = encodeFrame(&buf, true, OP_TEXT, "Hello", .{ 0x37, 0xfa, 0x21, 0x3d });
    try testing.expectEqualSlices(u8, &.{ 0x81, 0x85, 0x37, 0xfa, 0x21, 0x3d, 0x7f, 0x9f, 0x4d, 0x51, 0x58 }, buf[0..n]);
    // a server reading it: unmask gives Hello back
    const h = try parseHeader(buf[0..n], true, DEFAULT_MAX_MESSAGE);
    try testing.expect(h.masked and h.len == 5 and h.header_len == 6);
    var p: [5]u8 = undefined;
    @memcpy(&p, buf[6..11]);
    applyMask(&p, h.mask, 0);
    try testing.expectEqualStrings("Hello", &p);
    // and a CLIENT reading a masked frame refuses it
    try testing.expectError(error.MaskedFromServer, parseHeader(buf[0..n], false, DEFAULT_MAX_MESSAGE));
}

test "ws: 5.7 fragmented Hel + lo: 01 03 48 65 6c then 80 02 6c 6f" {
    var buf: [32]u8 = undefined;
    const n1 = encodeFrame(&buf, false, OP_TEXT, "Hel", null);
    try testing.expectEqualSlices(u8, &.{ 0x01, 0x03, 0x48, 0x65, 0x6c }, buf[0..n1]);
    const n2 = encodeFrame(&buf, true, OP_CONT, "lo", null);
    try testing.expectEqualSlices(u8, &.{ 0x80, 0x02, 0x6c, 0x6f }, buf[0..n2]);
}

test "ws: 5.7 ping 89 05 Hello and pong 8a 05 Hello" {
    var buf: [32]u8 = undefined;
    var n = encodeFrame(&buf, true, OP_PING, "Hello", null);
    try testing.expectEqualSlices(u8, &.{ 0x89, 0x05, 0x48, 0x65, 0x6c, 0x6c, 0x6f }, buf[0..n]);
    n = encodeFrame(&buf, true, OP_PONG, "Hello", null);
    try testing.expectEqualSlices(u8, &.{ 0x8a, 0x05, 0x48, 0x65, 0x6c, 0x6c, 0x6f }, buf[0..n]);
}

test "ws: 5.7 256 bytes binary: 82 7E 01 00" {
    var hdr: [14]u8 = undefined;
    const n = writeHeader(&hdr, true, OP_BINARY, false, 256, .{ 0, 0, 0, 0 });
    try testing.expectEqualSlices(u8, &.{ 0x82, 0x7E, 0x01, 0x00 }, hdr[0..n]);
    const h = try parseHeader(hdr[0..n], false, DEFAULT_MAX_MESSAGE);
    try testing.expect(h.len == 256 and h.header_len == 4);
}

test "ws: 5.7 64 KiB binary: 82 7F 00 00 00 00 00 01 00 00" {
    var hdr: [14]u8 = undefined;
    const n = writeHeader(&hdr, true, OP_BINARY, false, 65536, .{ 0, 0, 0, 0 });
    try testing.expectEqualSlices(u8, &.{ 0x82, 0x7F, 0, 0, 0, 0, 0, 1, 0, 0 }, hdr[0..n]);
    const h = try parseHeader(hdr[0..n], false, DEFAULT_MAX_MESSAGE);
    try testing.expect(h.len == 65536 and h.header_len == 10);
}

test "ws: the length forms at 125, 126, 65535, 65536" {
    var hdr: [14]u8 = undefined;
    try testing.expectEqual(@as(usize, 2), writeHeader(&hdr, true, OP_BINARY, false, 125, .{ 0, 0, 0, 0 }));
    try testing.expectEqual(@as(usize, 4), writeHeader(&hdr, true, OP_BINARY, false, 126, .{ 0, 0, 0, 0 }));
    try testing.expectEqual(@as(usize, 4), writeHeader(&hdr, true, OP_BINARY, false, 65535, .{ 0, 0, 0, 0 }));
    try testing.expectEqual(@as(usize, 10), writeHeader(&hdr, true, OP_BINARY, false, 65536, .{ 0, 0, 0, 0 }));
    // and a masked one adds four
    try testing.expectEqual(@as(usize, 6), writeHeader(&hdr, true, OP_BINARY, true, 125, .{ 1, 2, 3, 4 }));
}

test "ws: strictness -- reserved bits, bad opcode, long or fragmented control, non-minimal length, too large" {
    const max = DEFAULT_MAX_MESSAGE;
    try testing.expectError(error.ReservedBits, parseHeader(&.{ 0xC1, 0x00 }, false, max));
    try testing.expectError(error.BadOpcode, parseHeader(&.{ 0x83, 0x00 }, false, max));
    try testing.expectError(error.BadOpcode, parseHeader(&.{ 0x8B, 0x00 }, false, max));
    try testing.expectError(error.ControlTooLong, parseHeader(&.{ 0x89, 0x7E, 0x00, 0x7E }, false, max));
    try testing.expectError(error.FragmentedControl, parseHeader(&.{ 0x09, 0x00 }, false, max));
    try testing.expectError(error.BadLength, parseHeader(&.{ 0x82, 0x7E, 0x00, 0x05 }, false, max));
    try testing.expectError(error.BadLength, parseHeader(&.{ 0x82, 0x7F, 0, 0, 0, 0, 0, 0, 0, 5 }, false, max));
    try testing.expectError(error.BadLength, parseHeader(&.{ 0x82, 0x7F, 0x80, 0, 0, 0, 0, 0, 0, 0 }, false, max));
    // a frame declaring 2^40 bytes is refused from its header alone
    try testing.expectError(error.TooLarge, parseHeader(&.{ 0x82, 0x7F, 0, 0, 0, 1, 0, 0, 0, 0 }, false, max));
    // the limit is inclusive: exactly max passes, max + 1 does not
    try testing.expect((try parseHeader(&.{ 0x82, 0x7E, 0x01, 0x00 }, false, 256)).len == 256);
    try testing.expectError(error.TooLarge, parseHeader(&.{ 0x82, 0x7E, 0x01, 0x01 }, false, 256));
    // a client frame must be masked
    try testing.expectError(error.UnmaskedFromClient, parseHeader(&.{ 0x81, 0x05 }, true, max));
    // incomplete says so, never reads past the buffer
    try testing.expectError(error.Incomplete, parseHeader(&.{0x81}, false, max));
    try testing.expectError(error.Incomplete, parseHeader(&.{ 0x81, 0x7E, 0x01 }, false, max));
    try testing.expectError(error.Incomplete, parseHeader(&.{ 0x81, 0x85, 0x01, 0x02 }, true, max));
}

test "ws: masking round-trips at every offset and length" {
    var prng = std.Random.DefaultPrng.init(42);
    const rand = prng.random();
    var data: [300]u8 = undefined;
    var copy: [300]u8 = undefined;
    var len: usize = 0;
    while (len < 300) : (len += 7) {
        rand.bytes(data[0..len]);
        @memcpy(copy[0..len], data[0..len]);
        const key: [4]u8 = .{ rand.int(u8), rand.int(u8), rand.int(u8), rand.int(u8) };
        // chunked masking equals whole masking
        var whole: [300]u8 = undefined;
        @memcpy(whole[0..len], data[0..len]);
        applyMask(whole[0..len], key, 0);
        var off: usize = 0;
        while (off < len) {
            const n = @min(13, len - off);
            applyMask(data[off .. off + n], key, off);
            off += n;
        }
        try testing.expectEqualSlices(u8, whole[0..len], data[0..len]);
        applyMask(data[0..len], key, 0);
        try testing.expectEqualSlices(u8, copy[0..len], data[0..len]);
    }
}

test "ws: url parsing" {
    const a = try parseUrl("ws://localhost:8080/chat?x=1");
    try testing.expect(!a.secure and a.port == 8080);
    try testing.expectEqualStrings("localhost", a.host);
    try testing.expectEqualStrings("/chat?x=1", a.target);
    const b = try parseUrl("wss://example.org");
    try testing.expect(b.secure and b.port == 443);
    try testing.expect(b.target.len == 0);
    const c = try parseUrl("WS://[::1]:9/");
    try testing.expectEqualStrings("::1", c.host);
    try testing.expect(c.port == 9);
    try testing.expectError(error.BadScheme, parseUrl("http://h/"));
    try testing.expectError(error.NoHost, parseUrl("ws:///p"));
    try testing.expectError(error.BadPort, parseUrl("ws://h:x/"));
}

test "ws: header lookup is case-insensitive and token lists split on commas" {
    const head = "HTTP/1.1 101 Switching\r\nupgrade: WebSocket\r\nConnection: keep-alive, Upgrade\r\n\r\n";
    try testing.expectEqualStrings("WebSocket", headerValue(head, "Upgrade").?);
    try testing.expect(hasToken(headerValue(head, "connection").?, "upgrade"));
    try testing.expect(!hasToken(headerValue(head, "connection").?, "close"));
    try testing.expect(headerValue(head, "Sec-WebSocket-Accept") == null);
}

test "ws: the frame parser never crashes or claims a length past the maximum on random bytes" {
    var prng = std.Random.DefaultPrng.init(0xB00B_1E55);
    const rand = prng.random();
    var buf: [64]u8 = undefined;
    var iter: usize = 0;
    var ok: usize = 0;
    while (iter < 200_000) : (iter += 1) {
        const len = rand.uintLessThan(usize, buf.len);
        for (buf[0..len]) |*b| b.* = rand.int(u8);
        // bias some bytes toward the long-length forms
        if (len >= 2 and rand.boolean()) buf[1] = (buf[1] & 0x80) | @as(u8, if (rand.boolean()) 126 else 127);
        const max: u64 = @as(u64, 1) << @as(u6, rand.uintLessThan(u6, 40));
        if (parseHeader(buf[0..len], rand.boolean(), max)) |h| {
            if (h.len > max) @panic("length past the maximum accepted");
            if (h.header_len > len) @panic("header longer than the input");
            if (h.opcode >= 0x8 and h.len > 125) @panic("long control frame accepted");
            ok += 1;
        } else |_| {}
    }
    try testing.expect(ok > 0);
}

test "ws: loopback echo over plain TCP -- handshake, text, binary with NUL and 0xFF, fragments, ping, close" {
    const port = Echo.ws_echo_start(0, 0, "", 0, "", 0);
    try testing.expect(port > 0);
    defer Echo.ws_echo_stop();
    var url_buf: [64]u8 = undefined;
    const url = try std.fmt.bufPrint(&url_buf, "ws://127.0.0.1:{d}/echo", .{port});

    var c = Client{};
    defer c.deinit();
    c.subprotocols.appendSlice(gpa, "chat, superchat") catch unreachable;
    try testing.expect(c.connect(url));
    try testing.expectEqualStrings("chat", c.negotiated.items);

    try testing.expect(c.send(OP_TEXT, "Hello"));
    try testing.expectEqual(@as(i32, 1), c.recv(2000));
    try testing.expectEqualStrings("Hello", c.last.items);

    const bin = [_]u8{ 0, 0xFF, 1, 0, 0xFE, 0 };
    try testing.expect(c.send(OP_BINARY, &bin));
    try testing.expectEqual(@as(i32, 2), c.recv(2000));
    try testing.expectEqualSlices(u8, &bin, c.last.items);

    // 70000 bytes: the 64-bit length form both ways
    const big = try gpa.alloc(u8, 70000);
    defer gpa.free(big);
    ws_pattern(big.ptr, big.len, 7);
    try testing.expect(c.send(OP_BINARY, big));
    try testing.expectEqual(@as(i32, 2), c.recv(5000));
    try testing.expectEqualSlices(u8, big, c.last.items);

    // fragmented out, reassembled by the server; fragmented back by command
    try testing.expect(c.sendFragmented(OP_TEXT, "Hello, fragments", 3));
    try testing.expectEqual(@as(i32, 1), c.recv(2000));
    try testing.expectEqualStrings("Hello, fragments", c.last.items);
    try testing.expect(c.send(OP_TEXT, "!frag:3:abcdefghij"));
    try testing.expectEqual(@as(i32, 1), c.recv(2000));
    try testing.expectEqualStrings("abcdefghij", c.last.items);

    // ping -> pong surfaced; a server ping is answered without the caller
    try testing.expect(c.ping("p1"));
    try testing.expectEqual(@as(i32, 3), c.recv(2000));
    try testing.expectEqualStrings("p1", c.last.items);
    try testing.expect(c.send(OP_TEXT, "!ping:hey"));
    try testing.expectEqual(@as(i32, 1), c.recv(2000)); // the echo of the command follows the ping
    try testing.expectEqual(@as(u32, 1), c.pings_received);
    try testing.expectEqual(@as(u32, 1), c.pongs_sent);

    // nothing yet
    try testing.expectEqual(@as(i32, 0), c.recv(50));

    // a masked server frame is refused and the connection closed with 1002
    try testing.expect(c.send(OP_TEXT, "!masked"));
    try testing.expectEqual(@as(i32, -1), c.recv(2000));
    try testing.expectEqual(@as(i32, 1002), c.close_code);
    try testing.expect(std.mem.indexOf(u8, c.lastError(), "masked") != null);
    try testing.expect(c.state == .closed);

    // reconnect: the close handshake both ways
    try testing.expect(c.connect(url));
    try testing.expect(c.close(1000, "bye"));
    try testing.expectEqual(@as(i32, 1000), c.close_code);
    try testing.expect(!c.close_by_peer);
    try testing.expect(c.close_handshake_done);
    try testing.expect(!c.close(1000, "again")); // idempotent: nothing to do

    try testing.expect(c.connect(url));
    try testing.expect(c.send(OP_TEXT, "!close:4000:server says bye"));
    try testing.expectEqual(@as(i32, 4), c.recv(2000));
    try testing.expectEqual(@as(i32, 4000), c.close_code);
    try testing.expect(c.close_by_peer);
    try testing.expectEqualStrings("server says bye", c.close_reason.items);
}
