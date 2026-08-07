// STZM -- the Softanza message-plane wire format (distribution plan D0).
//
// One frame carries one serialized Ring value between nodes:
//
//   off  0: magic "STZM"          (4)
//   off  4: u8 version            (1)
//   off  5: u8 flags              (1)
//   off  6: u32 LE payload_len    (4)
//   off 10: u64 LE correlation_id (8)
//   off 18: hmac                  (32, all-zero when unsigned)
//   off 50: payload               (payload_len bytes)
//
// Like http_framing.zig -- whose fuzz discipline this module inherits --
// this parses PEER-CONTROLLED bytes on every node link, so everything here
// is pure slice logic: no allocation, no globals, bounds-safe on hostile
// input by construction.
//
// The payload is one Ring value (number/string/list, nested) in one of two
// candidate encodings measured against each other in the D0 spike:
//   - STZB: the in-house tag+length encoding (little-endian, 3 tags)
//   - MSGPACK: the msgpack subset covering the same three types
//     (big-endian where the msgpack spec says so -- the byte-order cost is
//     part of what the spike measures)
// The epoch-nanos law from the perf grind applies ABOVE this layer: time
// crosses as ms-exact strings, never raw f64 -- both encodings just carry
// what they are given.

const std = @import("std");

pub const MAGIC = "STZM";
pub const VERSION: u8 = 1;
pub const HEADER_LEN: usize = 50;
pub const HMAC_OFF: usize = 18;
pub const HMAC_LEN: usize = 32;

// flags bits
pub const FLAG_SIGNED: u8 = 1;
pub const FLAG_REPLY_EXPECTED: u8 = 2;
pub const FLAG_IDEMPOTENCY: u8 = 4;
pub const FLAG_COMPRESSED: u8 = 8; // reserved
pub const FLAG_MSGPACK: u8 = 16; // payload encoding: set = msgpack, clear = stzb

pub const Enc = enum(u8) { stzb = 0, msgpack = 1 };

// ── frame header ─────────────────────────────────────────────

pub const Header = struct {
    version: u8,
    flags: u8,
    payload_len: u32,
    corr_id: u64,
};

/// True unless the buffer already holds enough bytes to PROVE it is not an
/// STZM stream (bad magic, or a version we do not speak). A short prefix
/// of a valid header stays true -- "not yet decidable" is not a violation.
pub fn magicOk(bytes: []const u8) bool {
    const n = @min(bytes.len, MAGIC.len);
    if (!std.mem.eql(u8, bytes[0..n], MAGIC[0..n])) return false;
    if (bytes.len > 4 and bytes[4] != VERSION) return false;
    return true;
}

/// Parse the fixed header, or null if fewer than HEADER_LEN bytes or the
/// magic/version does not match.
pub fn parseHeader(bytes: []const u8) ?Header {
    if (bytes.len < HEADER_LEN) return null;
    if (!magicOk(bytes)) return null;
    return .{
        .version = bytes[4],
        .flags = bytes[5],
        .payload_len = std.mem.readInt(u32, bytes[6..10], .little),
        .corr_id = std.mem.readInt(u64, bytes[10..18], .little),
    };
}

/// Total byte length of the first complete frame in `bytes`, or null if
/// incomplete (or not yet provably a frame). A hostile payload_len cannot
/// overflow: the sum is computed in u64.
pub fn frameLen(bytes: []const u8) ?usize {
    const h = parseHeader(bytes) orelse return null;
    const need: u64 = @as(u64, HEADER_LEN) + h.payload_len;
    if (@as(u64, bytes.len) >= need) return @intCast(need);
    return null;
}

/// Write the 50-byte header into out (asserts capacity). The hmac field is
/// zeroed -- signing (D5) overwrites it after the payload is in place.
pub fn writeHeader(out: []u8, flags: u8, payload_len: u32, corr_id: u64) void {
    std.debug.assert(out.len >= HEADER_LEN);
    @memcpy(out[0..4], MAGIC);
    out[4] = VERSION;
    out[5] = flags;
    std.mem.writeInt(u32, out[6..10], payload_len, .little);
    std.mem.writeInt(u64, out[10..18], corr_id, .little);
    @memset(out[HMAC_OFF .. HMAC_OFF + HMAC_LEN], 0);
}

// ── payload emit (both encodings, caller-owned buffer) ───────

// STZB tags
const STZB_NUM: u8 = 0x01; // + 8 bytes f64 LE
const STZB_STR: u8 = 0x02; // + u32 LE len + bytes
const STZB_LIST: u8 = 0x03; // + u32 LE count, then count values

pub const EmitError = error{Overflow};

/// Append-only emitter over a caller-owned buffer. The recursion over the
/// value tree lives in the caller (the Ring bridge walks Ring lists); this
/// type owns only the byte grammar of each encoding.
pub const Emit = struct {
    buf: []u8,
    pos: usize = 0,

    fn put(self: *Emit, bytes: []const u8) EmitError!void {
        if (self.pos + bytes.len > self.buf.len) return error.Overflow;
        @memcpy(self.buf[self.pos .. self.pos + bytes.len], bytes);
        self.pos += bytes.len;
    }

    fn putByte(self: *Emit, b: u8) EmitError!void {
        if (self.pos >= self.buf.len) return error.Overflow;
        self.buf[self.pos] = b;
        self.pos += 1;
    }

    pub fn num(self: *Emit, enc: Enc, v: f64) EmitError!void {
        switch (enc) {
            .stzb => {
                try self.putByte(STZB_NUM);
                var b: [8]u8 = undefined;
                std.mem.writeInt(u64, &b, @bitCast(v), .little);
                try self.put(&b);
            },
            .msgpack => {
                // msgpack's density pitch is integer packing -- use it for
                // integral values (bit-exact through f64 below 2^31), else
                // float64. Decode always returns f64, so round-trips are
                // bit-identical either way.
                if (std.math.isFinite(v) and @floor(v) == v and
                    v >= -2147483648.0 and v <= 2147483647.0)
                {
                    const i: i64 = @intFromFloat(v);
                    if (i >= 0 and i <= 127) {
                        try self.putByte(@intCast(i));
                    } else if (i < 0 and i >= -32) {
                        try self.putByte(@bitCast(@as(i8, @intCast(i))));
                    } else if (i >= 0 and i <= 255) {
                        try self.putByte(0xcc);
                        try self.putByte(@intCast(i));
                    } else if (i >= -128 and i < 0) {
                        try self.putByte(0xd0);
                        try self.putByte(@bitCast(@as(i8, @intCast(i))));
                    } else if (i >= -32768 and i <= 32767) {
                        try self.putByte(0xd1);
                        var b: [2]u8 = undefined;
                        std.mem.writeInt(i16, &b, @intCast(i), .big);
                        try self.put(&b);
                    } else {
                        try self.putByte(0xd2);
                        var b: [4]u8 = undefined;
                        std.mem.writeInt(i32, &b, @intCast(i), .big);
                        try self.put(&b);
                    }
                } else {
                    try self.putByte(0xcb);
                    var b: [8]u8 = undefined;
                    std.mem.writeInt(u64, &b, @bitCast(v), .big);
                    try self.put(&b);
                }
            },
        }
    }

    pub fn str(self: *Emit, enc: Enc, s: []const u8) EmitError!void {
        switch (enc) {
            .stzb => {
                if (s.len > std.math.maxInt(u32)) return error.Overflow;
                try self.putByte(STZB_STR);
                var b: [4]u8 = undefined;
                std.mem.writeInt(u32, &b, @intCast(s.len), .little);
                try self.put(&b);
                try self.put(s);
            },
            .msgpack => {
                if (s.len <= 31) {
                    try self.putByte(0xa0 | @as(u8, @intCast(s.len)));
                } else if (s.len <= 255) {
                    try self.putByte(0xd9);
                    try self.putByte(@intCast(s.len));
                } else if (s.len <= 65535) {
                    try self.putByte(0xda);
                    var b: [2]u8 = undefined;
                    std.mem.writeInt(u16, &b, @intCast(s.len), .big);
                    try self.put(&b);
                } else if (s.len <= std.math.maxInt(u32)) {
                    try self.putByte(0xdb);
                    var b: [4]u8 = undefined;
                    std.mem.writeInt(u32, &b, @intCast(s.len), .big);
                    try self.put(&b);
                } else return error.Overflow;
                try self.put(s);
            },
        }
    }

    pub fn listBegin(self: *Emit, enc: Enc, count: u32) EmitError!void {
        switch (enc) {
            .stzb => {
                try self.putByte(STZB_LIST);
                var b: [4]u8 = undefined;
                std.mem.writeInt(u32, &b, count, .little);
                try self.put(&b);
            },
            .msgpack => {
                if (count <= 15) {
                    try self.putByte(0x90 | @as(u8, @intCast(count)));
                } else if (count <= 65535) {
                    try self.putByte(0xdc);
                    var b: [2]u8 = undefined;
                    std.mem.writeInt(u16, &b, @intCast(count), .big);
                    try self.put(&b);
                } else {
                    try self.putByte(0xdd);
                    var b: [4]u8 = undefined;
                    std.mem.writeInt(u32, &b, count, .big);
                    try self.put(&b);
                }
            },
        }
    }
};

// ── payload parse (both encodings, zero-copy tokens) ─────────

pub const ParseError = error{Malformed};

pub const Token = union(enum) {
    num: f64,
    str: []const u8, // slice into the cursor's bytes -- copy before it dies
    list: u32, // count of values that follow
};

pub const Cursor = struct {
    bytes: []const u8,
    pos: usize = 0,

    pub fn done(self: *const Cursor) bool {
        return self.pos >= self.bytes.len;
    }

    fn take(self: *Cursor, n: usize) ParseError![]const u8 {
        if (self.pos + n > self.bytes.len) return error.Malformed;
        const s = self.bytes[self.pos .. self.pos + n];
        self.pos += n;
        return s;
    }

    pub fn next(self: *Cursor, enc: Enc) ParseError!Token {
        return switch (enc) {
            .stzb => self.nextStzb(),
            .msgpack => self.nextMsgpack(),
        };
    }

    fn nextStzb(self: *Cursor) ParseError!Token {
        const tag = (try self.take(1))[0];
        switch (tag) {
            STZB_NUM => {
                const b = try self.take(8);
                return .{ .num = @bitCast(std.mem.readInt(u64, b[0..8], .little)) };
            },
            STZB_STR => {
                const lb = try self.take(4);
                const len = std.mem.readInt(u32, lb[0..4], .little);
                return .{ .str = try self.take(len) };
            },
            STZB_LIST => {
                const cb = try self.take(4);
                return .{ .list = std.mem.readInt(u32, cb[0..4], .little) };
            },
            else => return error.Malformed,
        }
    }

    fn nextMsgpack(self: *Cursor) ParseError!Token {
        const tag = (try self.take(1))[0];
        // positive fixint / negative fixint
        if (tag <= 0x7f) return .{ .num = @floatFromInt(tag) };
        if (tag >= 0xe0) return .{ .num = @floatFromInt(@as(i8, @bitCast(tag))) };
        // fixstr / fixarray
        if (tag >= 0xa0 and tag <= 0xbf) return .{ .str = try self.take(tag & 0x1f) };
        if (tag >= 0x90 and tag <= 0x9f) return .{ .list = tag & 0x0f };
        return switch (tag) {
            0xcc => .{ .num = @floatFromInt((try self.take(1))[0]) },
            0xcd => blk: {
                const b = try self.take(2);
                break :blk .{ .num = @floatFromInt(std.mem.readInt(u16, b[0..2], .big)) };
            },
            0xce => blk: {
                const b = try self.take(4);
                break :blk .{ .num = @floatFromInt(std.mem.readInt(u32, b[0..4], .big)) };
            },
            0xcf => blk: {
                const b = try self.take(8);
                break :blk .{ .num = @floatFromInt(std.mem.readInt(u64, b[0..8], .big)) };
            },
            0xd0 => .{ .num = @floatFromInt(@as(i8, @bitCast((try self.take(1))[0]))) },
            0xd1 => blk: {
                const b = try self.take(2);
                break :blk .{ .num = @floatFromInt(std.mem.readInt(i16, b[0..2], .big)) };
            },
            0xd2 => blk: {
                const b = try self.take(4);
                break :blk .{ .num = @floatFromInt(std.mem.readInt(i32, b[0..4], .big)) };
            },
            0xd3 => blk: {
                const b = try self.take(8);
                break :blk .{ .num = @floatFromInt(std.mem.readInt(i64, b[0..8], .big)) };
            },
            0xca => blk: {
                const b = try self.take(4);
                const f: f32 = @bitCast(std.mem.readInt(u32, b[0..4], .big));
                break :blk .{ .num = f };
            },
            0xcb => blk: {
                const b = try self.take(8);
                break :blk .{ .num = @bitCast(std.mem.readInt(u64, b[0..8], .big)) };
            },
            0xd9 => blk: {
                const len = (try self.take(1))[0];
                break :blk .{ .str = try self.take(len) };
            },
            0xda => blk: {
                const b = try self.take(2);
                break :blk .{ .str = try self.take(std.mem.readInt(u16, b[0..2], .big)) };
            },
            0xdb => blk: {
                const b = try self.take(4);
                break :blk .{ .str = try self.take(std.mem.readInt(u32, b[0..4], .big)) };
            },
            0xdc => blk: {
                const b = try self.take(2);
                break :blk .{ .list = std.mem.readInt(u16, b[0..2], .big) };
            },
            0xdd => blk: {
                const b = try self.take(4);
                break :blk .{ .list = std.mem.readInt(u32, b[0..4], .big) };
            },
            else => error.Malformed, // nil/bool/map/bin/ext: not part of the subset
        };
    }
};

// ── net.* calibration seeds (distribution plan D0) ───────────
//
// Measured by the D0 spike guard (base/test/cluster/d0_message_plane_
// narrated.ring) on the reference machine (Core 5 210H, loopback, release
// build) and seeded here as compiled defaults, exactly as the cpu.* gates
// were seeded by their spikes. OVERRIDE > FILE > DEFAULT via calib.zig.

const calib = @import("calib.zig");

/// Median loopback round-trip of a small STZM frame, microseconds
/// (engine-await path, i.e. what a mailbox interaction actually pays).
/// D0 measured: busy-poll 1980 us, engine-await 2010 us.
pub var g_net_rtt_us = calib.Gate.init("net.stzm.rtt_loopback_us", 2000);
/// Sustained loopback throughput, messages per second (64 pipelined).
/// D0 measured: 12673 msg/s.
pub var g_net_msgs_per_sec = calib.Gate.init("net.stzm.msgs_per_sec_loopback", 12000);
/// Serialization cost (pack+unpack, stzb -- the D0 winner), ns per KB of
/// payload on the 384-f64 embedding shape. D0 measured: (2.36 + 42.69)
/// us over 3.43 KB of payload = ~13000 ns/KB (unpack dominates: building
/// the Ring value back is the boundary's real cost).
pub var g_net_ser_ns_per_kb = calib.Gate.init("net.stzm.ser_ns_per_kb", 13000);

// ── tests ────────────────────────────────────────────────────

fn expectTok(cur: *Cursor, enc: Enc, want: Token) !void {
    const got = try cur.next(enc);
    switch (want) {
        .num => |v| try std.testing.expectEqual(v, got.num),
        .str => |s| try std.testing.expectEqualStrings(s, got.str),
        .list => |n| try std.testing.expectEqual(n, got.list),
    }
}

test "frame header round-trip and completeness" {
    var buf: [64]u8 = undefined;
    writeHeader(buf[0..], FLAG_REPLY_EXPECTED, 7, 0xDEADBEEF12345678);
    // header alone is not a complete 7-byte-payload frame
    try std.testing.expectEqual(@as(?usize, null), frameLen(buf[0..HEADER_LEN]));
    // with the payload present the frame closes at 57
    try std.testing.expectEqual(@as(?usize, 57), frameLen(buf[0..64]));
    const h = parseHeader(buf[0..]).?;
    try std.testing.expectEqual(@as(u8, VERSION), h.version);
    try std.testing.expectEqual(@as(u8, FLAG_REPLY_EXPECTED), h.flags);
    try std.testing.expectEqual(@as(u32, 7), h.payload_len);
    try std.testing.expectEqual(@as(u64, 0xDEADBEEF12345678), h.corr_id);
}

test "truncated and hostile headers never read out of bounds" {
    // every prefix of a valid header: incomplete, not malformed
    var buf: [64]u8 = undefined;
    writeHeader(buf[0..], 0, 1000, 42);
    var i: usize = 0;
    while (i < HEADER_LEN) : (i += 1) {
        try std.testing.expectEqual(@as(?usize, null), frameLen(buf[0..i]));
        try std.testing.expect(magicOk(buf[0..i]));
    }
    // wrong magic is a violation as soon as it is visible
    try std.testing.expect(!magicOk("HTTP"));
    try std.testing.expect(magicOk("S")); // a matching prefix is not a violation
    // wrong version is a violation once byte 4 is visible
    var bad: [6]u8 = .{ 'S', 'T', 'Z', 'M', 99, 0 };
    try std.testing.expect(!magicOk(bad[0..]));
    // hostile payload_len near u32 max must not overflow the total
    writeHeader(buf[0..], 0, std.math.maxInt(u32), 0);
    try std.testing.expectEqual(@as(?usize, null), frameLen(buf[0..]));
}

test "stzb round-trips numbers, strings, lists byte-exactly" {
    var buf: [256]u8 = undefined;
    var e = Emit{ .buf = buf[0..] };
    // [ 3.5, "hej", [ -1, "" ] ]
    try e.listBegin(.stzb, 3);
    try e.num(.stzb, 3.5);
    try e.str(.stzb, "hej");
    try e.listBegin(.stzb, 2);
    try e.num(.stzb, -1);
    try e.str(.stzb, "");
    var cur = Cursor{ .bytes = buf[0..e.pos] };
    try expectTok(&cur, .stzb, .{ .list = 3 });
    try expectTok(&cur, .stzb, .{ .num = 3.5 });
    try expectTok(&cur, .stzb, .{ .str = "hej" });
    try expectTok(&cur, .stzb, .{ .list = 2 });
    try expectTok(&cur, .stzb, .{ .num = -1 });
    try expectTok(&cur, .stzb, .{ .str = "" });
    try std.testing.expect(cur.done());
}

test "msgpack integer forms and float64 all decode back exactly" {
    var buf: [256]u8 = undefined;
    var e = Emit{ .buf = buf[0..] };
    const vals = [_]f64{ 0, 5, 127, 128, 255, 256, -1, -32, -33, -128, -129, -32768, 32767, 70000, -70000, 3.25, -0.5, 1e300 };
    try e.listBegin(.msgpack, vals.len);
    for (vals) |v| try e.num(.msgpack, v);
    var cur = Cursor{ .bytes = buf[0..e.pos] };
    try expectTok(&cur, .msgpack, .{ .list = vals.len });
    for (vals) |v| try expectTok(&cur, .msgpack, .{ .num = v });
    try std.testing.expect(cur.done());
}

test "msgpack strings across the fixstr/str8/str16 boundaries" {
    var big: [70000]u8 = undefined;
    @memset(big[0..], 'x');
    var buf: [80000]u8 = undefined;
    for ([_]usize{ 0, 31, 32, 255, 256, 65535, 65536 }) |n| {
        var e = Emit{ .buf = buf[0..] };
        try e.str(.msgpack, big[0..n]);
        var cur = Cursor{ .bytes = buf[0..e.pos] };
        const tok = try cur.next(.msgpack);
        try std.testing.expectEqual(n, tok.str.len);
        try std.testing.expect(cur.done());
    }
}

test "malformed payloads fail closed, never out of bounds" {
    // stzb: truncated number / truncated string body / unknown tag
    var c1 = Cursor{ .bytes = &.{ STZB_NUM, 1, 2 } };
    try std.testing.expectError(error.Malformed, c1.nextStzb());
    var c2 = Cursor{ .bytes = &.{ STZB_STR, 10, 0, 0, 0, 'a' } };
    try std.testing.expectError(error.Malformed, c2.nextStzb());
    var c3 = Cursor{ .bytes = &.{0x77} };
    try std.testing.expectError(error.Malformed, c3.nextStzb());
    // msgpack: truncated float64 / str8 shorter than declared / a map tag
    var c4 = Cursor{ .bytes = &.{ 0xcb, 0, 0 } };
    try std.testing.expectError(error.Malformed, c4.nextMsgpack());
    var c5 = Cursor{ .bytes = &.{ 0xd9, 5, 'a', 'b' } };
    try std.testing.expectError(error.Malformed, c5.nextMsgpack());
    var c6 = Cursor{ .bytes = &.{0x80} };
    try std.testing.expectError(error.Malformed, c6.nextMsgpack());
}

test "emit refuses to overflow its buffer" {
    var tiny: [4]u8 = undefined;
    var e = Emit{ .buf = tiny[0..] };
    try std.testing.expectError(error.Overflow, e.num(.stzb, 1.0));
    var e2 = Emit{ .buf = tiny[0..] };
    try std.testing.expectError(error.Overflow, e2.str(.msgpack, "hello world"));
}
