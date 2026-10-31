// Loopback WebSocket ECHO server -- TEST SUPPORT for the guards, not a product
// server. One global instance on 127.0.0.1, a thread per connection, plain or
// TLS (mbedTLS with a PEM cert + key the caller names).
//
// It accepts, handshakes (RFC 6455 section 4.2), echoes text and binary
// (fragments reassembled, echoed as ONE frame), answers pings, counts pongs and
// completes the close handshake. Then it misbehaves ON COMMAND, so a client
// can be shown refusing each violation of the protocol. A text message that
// starts with "!" is a command and is not echoed:
//
//   !ping:<data>        the server pings the client, then sends the text "pinged"
//   !frag:<n>:<text>    sends <text> back in <n> fragments
//   !fragbig:<n>:<k>    sends <n> pattern bytes as a binary message in <k> fragments
//   !big:<n>            sends <n> pattern bytes as one binary frame
//   !text:<n>           sends <n> letters as one text frame
//   !close:<code>:<r>   the server starts the close handshake with that code and reason
//   !drop               closes the socket with no close frame
//   !cut                sends three bytes of a frame header, then closes the socket
//   !masked             sends a MASKED frame (a server must not)
//   !rsv                a frame with a reserved bit set
//   !badop              a frame with opcode 3
//   !bigctrl            a ping of 126 bytes
//   !fragctrl           a ping with FIN = 0
//   !cont               a continuation frame with no message started
//   !badutf8            a text frame holding bytes that are not UTF-8
//   !badutf8frag        the same, split so the bad byte sits in the second fragment
//   !close1             a close frame with a 1-byte body
//   !closebad           a close frame with code 999
//   !huge               a header declaring 2^40 bytes, then nothing
//   !garbage            40 bytes that are not a frame
//   !nopong             the server stops answering pings on this connection
//   !headers            sends the handshake request head it received, as text
//
// The HANDSHAKE misbehaves by a mode set before the client connects:
//   0 correct   1 status 403   2 wrong Sec-WebSocket-Accept   3 no Upgrade header
//   4 no Connection header   5 no Sec-WebSocket-Accept   6 a subprotocol the client
//   did not offer   7 claims an extension   8 Upgrade: h2c
//   9 answers permessage-deflate with client_max_window_bits (never offered)
//   10 answers permessage-deflate with a parameter nobody defined   11 answers another extension
//   12 answers permessage-deflate with server_max_window_bits=7 (outside 8..15)

const std = @import("std");
const ws = @import("ws.zig");
const posix = std.posix;
const gpa = std.heap.c_allocator;
const tls = if (ws.tls_enabled) @import("ws_tls.zig") else struct {};

const SERVER_MAX: u64 = 32 * 1024 * 1024;
const IDLE_MS: i32 = 30_000;

const State = struct {
    server: std.net.Server,
    thread: std.Thread,
    port: u16,
    stop: std.atomic.Value(bool),
    use_tls: bool,
    cert_pem: []u8,
    key_pem: []u8,
};

var state: ?*State = null;
pub var handshake_mode = std.atomic.Value(i32).init(0);
pub var connections = std.atomic.Value(u32).init(0);
pub var messages = std.atomic.Value(u32).init(0);
pub var pings = std.atomic.Value(u32).init(0);
pub var pongs = std.atomic.Value(u32).init(0);
var last_err_buf: [256]u8 = undefined;
var last_err_len: usize = 0;

fn setErr(msg: []const u8) void {
    const n = @min(msg.len, last_err_buf.len);
    @memcpy(last_err_buf[0..n], msg[0..n]);
    last_err_len = n;
}

pub fn ws_echo_last_error(out: [*]u8, max: usize) callconv(.c) i32 {
    const n = @min(last_err_len, max);
    if (n > 0) @memcpy(out[0..n], last_err_buf[0..n]);
    return @intCast(n);
}

/// Start on 127.0.0.1:`port` (0 = ephemeral). `use_tls` != 0 reads the PEM
/// certificate and key files. Returns the bound port, or -1 (last error set).
pub fn ws_echo_start(port: u16, use_tls: i32, cert_ptr: [*]const u8, cert_len: usize, key_ptr: [*]const u8, key_len: usize) callconv(.c) i32 {
    last_err_len = 0;
    if (state != null) {
        setErr("echo server already running");
        return -1;
    }
    var cert_pem: []u8 = &.{};
    var key_pem: []u8 = &.{};
    if (use_tls != 0) {
        if (!ws.tls_enabled) {
            setErr("tls not available in this build");
            return -1;
        }
        cert_pem = std.fs.cwd().readFileAlloc(gpa, cert_ptr[0..cert_len], 1 << 20) catch {
            setErr("certificate file unreadable");
            return -1;
        };
        key_pem = std.fs.cwd().readFileAlloc(gpa, key_ptr[0..key_len], 1 << 20) catch {
            gpa.free(cert_pem);
            setErr("key file unreadable");
            return -1;
        };
    }
    const addr = std.net.Address.parseIp("127.0.0.1", port) catch {
        setErr("bad port");
        return -1;
    };
    var srv = addr.listen(.{ .reuse_address = true }) catch {
        setErr("listen failed");
        return -1;
    };
    const s = gpa.create(State) catch {
        srv.deinit();
        setErr("oom");
        return -1;
    };
    s.* = .{
        .server = srv,
        .thread = undefined,
        .port = srv.listen_address.getPort(),
        .stop = std.atomic.Value(bool).init(false),
        .use_tls = use_tls != 0,
        .cert_pem = cert_pem,
        .key_pem = key_pem,
    };
    s.thread = std.Thread.spawn(.{}, acceptLoop, .{s}) catch {
        srv.deinit();
        gpa.destroy(s);
        setErr("thread spawn failed");
        return -1;
    };
    state = s;
    return @intCast(s.port);
}

pub fn ws_echo_stop() callconv(.c) void {
    const s = state orelse return;
    s.stop.store(true, .release);
    const addr = std.net.Address.parseIp("127.0.0.1", s.port) catch s.server.listen_address;
    if (std.net.tcpConnectToAddress(addr)) |c| {
        c.close();
    } else |_| {}
    s.thread.join();
    s.server.deinit();
    if (s.cert_pem.len > 0) gpa.free(s.cert_pem);
    if (s.key_pem.len > 0) gpa.free(s.key_pem);
    gpa.destroy(s);
    state = null;
}

pub fn ws_echo_set_handshake_mode(mode: i32) callconv(.c) void {
    handshake_mode.store(mode, .release);
}
pub fn ws_echo_connections() callconv(.c) u32 {
    return connections.load(.acquire);
}
pub fn ws_echo_messages() callconv(.c) u32 {
    return messages.load(.acquire);
}
pub fn ws_echo_pings() callconv(.c) u32 {
    return pings.load(.acquire);
}
pub fn ws_echo_pongs() callconv(.c) u32 {
    return pongs.load(.acquire);
}
pub fn ws_echo_reset_counters() callconv(.c) void {
    connections.store(0, .release);
    messages.store(0, .release);
    pings.store(0, .release);
    pongs.store(0, .release);
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
        if (std.Thread.spawn(.{}, handleConn, .{ s, conn.stream.handle })) |t| {
            t.detach();
        } else |_| {
            handleConn(s, conn.stream.handle);
        }
    }
}

const Conn = struct {
    tr: ws.Transport,
    rbuf: std.ArrayList(u8) = .{},
    rpos: usize = 0,
    msg: std.ArrayList(u8) = .{},
    msg_op: u8 = 0,
    fragmented: bool = false,
    pong_enabled: bool = true,
    head: std.ArrayList(u8) = .{},

    fn deinit(self: *Conn) void {
        self.tr.close();
        self.rbuf.deinit(gpa);
        self.msg.deinit(gpa);
        self.head.deinit(gpa);
    }

    fn compact(self: *Conn) void {
        if (self.rpos == 0) return;
        const remaining = self.rbuf.items.len - self.rpos;
        if (remaining > 0) std.mem.copyForwards(u8, self.rbuf.items[0..remaining], self.rbuf.items[self.rpos..]);
        self.rbuf.items.len = remaining;
        self.rpos = 0;
    }

    fn fill(self: *Conn, at_least: usize, timeout_ms: i32) error{ Timeout, Closed, Failed }!void {
        self.compact();
        self.rbuf.ensureTotalCapacity(gpa, @max(at_least, self.rbuf.items.len + 4096)) catch return error.Failed;
        const n = try self.tr.readSome(self.rbuf.unusedCapacitySlice(), timeout_ms);
        self.rbuf.items.len += n;
    }

    fn sendRaw(self: *Conn, bytes: []const u8) void {
        self.tr.writeAll(bytes) catch {};
    }

    fn sendFrame(self: *Conn, fin: bool, op: u8, payload: []const u8) void {
        var hdr: [14]u8 = undefined;
        const hl = ws.writeHeader(&hdr, fin, op, false, payload.len, .{ 0, 0, 0, 0 });
        self.tr.writeAll(hdr[0..hl]) catch return;
        self.tr.writeAll(payload) catch {};
    }

    fn sendClose(self: *Conn, code: u16, reason: []const u8) void {
        var body: [125]u8 = undefined;
        std.mem.writeInt(u16, body[0..2], code, .big);
        const rl = @min(reason.len, 123);
        @memcpy(body[2 .. 2 + rl], reason[0..rl]);
        self.sendFrame(true, ws.OP_CLOSE, body[0 .. 2 + rl]);
    }

    const Frame = struct { hdr: ws.Header, payload: []u8 };

    /// The next client frame, unmasked in place. Protocol errors come back as
    /// the parser's error; the caller closes with 1002.
    fn readFrame(self: *Conn, timeout_ms: i32) (ws.ParseError || error{ Timeout, Closed, Failed })!Frame {
        while (true) {
            const avail = self.rbuf.items[self.rpos..];
            const hdr = ws.parseHeader(avail, true, SERVER_MAX) catch |e| switch (e) {
                error.Incomplete => {
                    try self.fill(0, timeout_ms);
                    continue;
                },
                else => return e,
            };
            const need = hdr.header_len + @as(usize, @intCast(hdr.len));
            if (avail.len < need) {
                try self.fill(need, timeout_ms);
                continue;
            }
            const payload = self.rbuf.items[self.rpos + hdr.header_len .. self.rpos + need];
            ws.applyMask(payload, hdr.mask, 0);
            self.rpos += need;
            return .{ .hdr = hdr, .payload = payload };
        }
    }
};

fn handleConn(s: *State, sock: posix.socket_t) void {
    var conn = Conn{ .tr = .{ .sock = sock } };
    defer conn.deinit();
    if (s.use_tls) {
        if (comptime ws.tls_enabled) {
            conn.tr.tls = tls.accept(sock, s.cert_pem, s.key_pem, 5000) catch return;
        } else return;
    }
    if (!handshake(&conn)) return;
    _ = connections.fetchAdd(1, .monotonic);
    serve(&conn);
}

fn handshake(conn: *Conn) bool {
    // the request head, bounded
    var head_end: usize = 0;
    while (true) {
        if (std.mem.indexOf(u8, conn.rbuf.items, "\r\n\r\n")) |he| {
            head_end = he + 4;
            break;
        }
        if (conn.rbuf.items.len > 16 * 1024) return false;
        conn.fill(0, 5000) catch return false;
    }
    const head = conn.rbuf.items[0..head_end];
    conn.head.appendSlice(gpa, head) catch {};
    const upgrade = ws.headerValue(head, "Upgrade") orelse "";
    const connection = ws.headerValue(head, "Connection") orelse "";
    const key = ws.headerValue(head, "Sec-WebSocket-Key") orelse "";
    const version = ws.headerValue(head, "Sec-WebSocket-Version") orelse "";
    if (!std.ascii.eqlIgnoreCase(upgrade, "websocket") or !ws.hasToken(connection, "upgrade") or key.len != 24 or !std.mem.eql(u8, version, "13")) {
        conn.sendRaw("HTTP/1.1 400 Bad Request\r\nContent-Length: 0\r\nConnection: close\r\n\r\n");
        return false;
    }
    var accept_buf: [28]u8 = undefined;
    const accept = ws.acceptKey(key, &accept_buf);
    const mode = handshake_mode.load(.acquire);
    var resp: std.ArrayList(u8) = .{};
    defer resp.deinit(gpa);
    const w = resp.writer(gpa);
    switch (mode) {
        1 => {
            conn.sendRaw("HTTP/1.1 403 Forbidden\r\nContent-Length: 0\r\nConnection: close\r\n\r\n");
            return false;
        },
        else => {},
    }
    w.writeAll("HTTP/1.1 101 Switching Protocols\r\n") catch return false;
    if (mode == 8) {
        w.writeAll("Upgrade: h2c\r\n") catch return false;
    } else if (mode != 3) {
        w.writeAll("Upgrade: websocket\r\n") catch return false;
    }
    if (mode != 4) w.writeAll("Connection: Upgrade\r\n") catch return false;
    if (mode == 2) {
        w.writeAll("Sec-WebSocket-Accept: AAAAAAAAAAAAAAAAAAAAAAAAAAA=\r\n") catch return false;
    } else if (mode != 5) {
        w.print("Sec-WebSocket-Accept: {s}\r\n", .{accept}) catch return false;
    }
    if (mode == 6) {
        w.writeAll("Sec-WebSocket-Protocol: nope\r\n") catch return false;
    } else if (ws.headerValue(head, "Sec-WebSocket-Protocol")) |offered| {
        // take the first one offered
        var it = std.mem.splitScalar(u8, offered, ',');
        if (it.next()) |first| {
            const f = std.mem.trim(u8, first, " \t");
            if (f.len > 0) w.print("Sec-WebSocket-Protocol: {s}\r\n", .{f}) catch return false;
        }
    }
    if (mode == 7) w.writeAll("Sec-WebSocket-Extensions: permessage-deflate\r\n") catch return false;
    if (mode == 9) w.writeAll("Sec-WebSocket-Extensions: permessage-deflate; client_max_window_bits=10\r\n") catch return false;
    if (mode == 10) w.writeAll("Sec-WebSocket-Extensions: permessage-deflate; bogus\r\n") catch return false;
    if (mode == 11) w.writeAll("Sec-WebSocket-Extensions: x-other\r\n") catch return false;
    if (mode == 12) w.writeAll("Sec-WebSocket-Extensions: permessage-deflate; server_max_window_bits=7\r\n") catch return false;
    w.writeAll("\r\n") catch return false;
    conn.tr.writeAll(resp.items) catch return false;
    conn.rpos = head_end;
    conn.compact();
    return mode == 0 or mode >= 2; // a refused handshake ends the connection
}

fn serve(conn: *Conn) void {
    while (true) {
        const f = conn.readFrame(IDLE_MS) catch |e| switch (e) {
            error.Timeout, error.Closed, error.Failed => return,
            else => {
                conn.sendClose(1002, @errorName(e));
                return;
            },
        };
        switch (f.hdr.opcode) {
            ws.OP_PING => {
                _ = pings.fetchAdd(1, .monotonic);
                if (conn.pong_enabled) conn.sendFrame(true, ws.OP_PONG, f.payload);
            },
            ws.OP_PONG => {
                _ = pongs.fetchAdd(1, .monotonic);
            },
            ws.OP_CLOSE => {
                if (f.payload.len >= 2) {
                    conn.sendFrame(true, ws.OP_CLOSE, f.payload[0..2]);
                } else {
                    conn.sendFrame(true, ws.OP_CLOSE, "");
                }
                return;
            },
            ws.OP_TEXT, ws.OP_BINARY => {
                if (conn.fragmented) {
                    conn.sendClose(1002, "new message while fragmented");
                    return;
                }
                if (f.hdr.fin) {
                    if (!process(conn, f.hdr.opcode, f.payload)) return;
                } else {
                    conn.fragmented = true;
                    conn.msg_op = f.hdr.opcode;
                    conn.msg.clearRetainingCapacity();
                    conn.msg.appendSlice(gpa, f.payload) catch return;
                }
            },
            ws.OP_CONT => {
                if (!conn.fragmented) {
                    conn.sendClose(1002, "continuation without a start");
                    return;
                }
                conn.msg.appendSlice(gpa, f.payload) catch return;
                if (f.hdr.fin) {
                    conn.fragmented = false;
                    if (!process(conn, conn.msg_op, conn.msg.items)) return;
                }
            },
            else => unreachable,
        }
    }
}

fn parseNum(s: []const u8) usize {
    return std.fmt.parseInt(usize, s, 10) catch 0;
}

/// Echo, or run a command. False when the connection is to end.
fn process(conn: *Conn, op: u8, data: []const u8) bool {
    _ = messages.fetchAdd(1, .monotonic);
    if (op == ws.OP_TEXT and data.len > 0 and data[0] == '!') return command(conn, data[1..]);
    if (op == ws.OP_TEXT and !std.unicode.utf8ValidateSlice(data)) {
        conn.sendClose(1007, "text is not UTF-8");
        return false;
    }
    conn.sendFrame(true, op, data);
    return true;
}

fn command(conn: *Conn, cmd: []const u8) bool {
    var it = std.mem.splitScalar(u8, cmd, ':');
    const name = it.next() orelse "";
    const a1 = it.next() orelse "";
    const rest = it.rest();
    if (std.mem.eql(u8, name, "ping")) {
        conn.sendFrame(true, ws.OP_PING, a1);
        conn.sendFrame(true, ws.OP_TEXT, "pinged");
    } else if (std.mem.eql(u8, name, "frag")) {
        const parts = @max(parseNum(a1), 1);
        sendFragmented(conn, ws.OP_TEXT, rest, parts);
    } else if (std.mem.eql(u8, name, "fragbig")) {
        const n = parseNum(a1);
        const parts = @max(parseNum(rest), 1);
        const buf = gpa.alloc(u8, n) catch return false;
        defer gpa.free(buf);
        ws.ws_pattern(buf.ptr, buf.len, 3);
        sendFragmented(conn, ws.OP_BINARY, buf, parts);
    } else if (std.mem.eql(u8, name, "big")) {
        const n = parseNum(a1);
        const buf = gpa.alloc(u8, n) catch return false;
        defer gpa.free(buf);
        ws.ws_pattern(buf.ptr, buf.len, 3);
        conn.sendFrame(true, ws.OP_BINARY, buf);
    } else if (std.mem.eql(u8, name, "text")) {
        const n = parseNum(a1);
        const buf = gpa.alloc(u8, n) catch return false;
        defer gpa.free(buf);
        @memset(buf, 'a');
        conn.sendFrame(true, ws.OP_TEXT, buf);
    } else if (std.mem.eql(u8, name, "close")) {
        const code: u16 = @intCast(@min(parseNum(a1), 65535));
        conn.sendClose(code, rest);
        // wait for the client's answer, bounded
        const f = conn.readFrame(2000) catch return false;
        _ = f;
        return false;
    } else if (std.mem.eql(u8, name, "drop")) {
        return false;
    } else if (std.mem.eql(u8, name, "cut")) {
        conn.sendRaw(&.{ 0x82, 0x7E, 0x01 });
        return false;
    } else if (std.mem.eql(u8, name, "masked")) {
        conn.sendRaw(&.{ 0x81, 0x81, 1, 2, 3, 4, 'x' ^ 1 });
    } else if (std.mem.eql(u8, name, "rsv")) {
        conn.sendRaw(&.{ 0xC1, 0x01, 'x' });
    } else if (std.mem.eql(u8, name, "badop")) {
        conn.sendRaw(&.{ 0x83, 0x01, 'x' });
    } else if (std.mem.eql(u8, name, "bigctrl")) {
        var buf: [130]u8 = undefined;
        buf[0] = 0x89;
        buf[1] = 0x7E;
        buf[2] = 0x00;
        buf[3] = 126;
        @memset(buf[4..130], 'p');
        conn.sendRaw(&buf);
    } else if (std.mem.eql(u8, name, "fragctrl")) {
        conn.sendRaw(&.{ 0x09, 0x01, 'x' });
    } else if (std.mem.eql(u8, name, "cont")) {
        conn.sendRaw(&.{ 0x80, 0x01, 'x' });
    } else if (std.mem.eql(u8, name, "badutf8")) {
        conn.sendRaw(&.{ 0x81, 0x02, 0xFF, 0xFE });
    } else if (std.mem.eql(u8, name, "badutf8frag")) {
        conn.sendRaw(&.{ 0x01, 0x01, 'a' });
        conn.sendRaw(&.{ 0x80, 0x01, 0xFF });
    } else if (std.mem.eql(u8, name, "close1")) {
        conn.sendRaw(&.{ 0x88, 0x01, 0x03 });
    } else if (std.mem.eql(u8, name, "closebad")) {
        conn.sendRaw(&.{ 0x88, 0x02, 0x03, 0xE7 });
    } else if (std.mem.eql(u8, name, "huge")) {
        conn.sendRaw(&.{ 0x82, 0x7F, 0, 0, 0, 1, 0, 0, 0, 0 });
    } else if (std.mem.eql(u8, name, "garbage")) {
        conn.sendRaw("GARBAGE GARBAGE GARBAGE GARBAGE GARBAGE!");
    } else if (std.mem.eql(u8, name, "nopong")) {
        conn.pong_enabled = false;
        conn.sendFrame(true, ws.OP_TEXT, "nopong");
    } else if (std.mem.eql(u8, name, "headers")) {
        conn.sendFrame(true, ws.OP_TEXT, conn.head.items);
    } else {
        conn.sendFrame(true, ws.OP_TEXT, "unknown command");
    }
    return true;
}

fn sendFragmented(conn: *Conn, op: u8, data: []const u8, parts: usize) void {
    if (parts <= 1 or data.len < parts) {
        conn.sendFrame(true, op, data);
        return;
    }
    const each = data.len / parts;
    var i: usize = 0;
    var off: usize = 0;
    while (i < parts) : (i += 1) {
        const last = i == parts - 1;
        const end = if (last) data.len else off + each;
        conn.sendFrame(last, if (i == 0) op else ws.OP_CONT, data[off..end]);
        off = end;
    }
}
