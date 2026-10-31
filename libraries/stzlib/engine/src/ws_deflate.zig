// permessage-deflate (RFC 7692) -- the compression half of the WebSocket engine.
//
// A message is compressed with raw DEFLATE (no zlib header), flushed with
// Z_SYNC_FLUSH, and the four bytes 00 00 ff ff that flush leaves at the end are
// NOT sent; the receiver puts them back before it inflates. RSV1 on the first
// frame of a message says it is compressed (ws.zig reads and writes that bit).
//
// CONTEXT TAKEOVER: by default the LZ77 window carries from one message to the
// next, on both sides, which is what makes many small similar messages cheap.
// `server_no_context_takeover` / `client_no_context_takeover` turn it off for
// one direction, and then the sender resets its deflater after every message.
// A receiver never needs to reset: a sender that does not take over references
// nothing earlier, so an inflater that kept its window decodes it all the same.
//
// DECOMPRESSION BOMBS: a few hundred bytes can inflate to gigabytes. Inflation
// here is bounded by the caller's limit on the OUTPUT, checked as it grows, so a
// bomb costs at most `limit` bytes plus one output chunk before it is refused.
//
// zlib is the vendored copy (vendor/zlib), the one the PNG encoder uses.

const std = @import("std");
const c = @cImport({
    @cInclude("zlib.h");
});

const gpa = std.heap.c_allocator;
const CHUNK: usize = 64 * 1024;

/// The four bytes a Z_SYNC_FLUSH ends with; sent never, restored on receipt.
pub const TAIL = [4]u8{ 0x00, 0x00, 0xff, 0xff };

pub const Deflater = struct {
    z: c.z_stream = undefined,
    ready: bool = false,
    window_bits: c_int = 15,

    /// Start (or restart with a new window) a raw deflater. window_bits is 9..15.
    pub fn init(self: *Deflater, window_bits: c_int) bool {
        self.deinit();
        self.z = std.mem.zeroes(c.z_stream);
        const rc = c.deflateInit2_(&self.z, c.Z_DEFAULT_COMPRESSION, c.Z_DEFLATED, -window_bits, 8, c.Z_DEFAULT_STRATEGY, c.zlibVersion(), @sizeOf(c.z_stream));
        if (rc != c.Z_OK) return false;
        self.ready = true;
        self.window_bits = window_bits;
        return true;
    }

    pub fn deinit(self: *Deflater) void {
        if (self.ready) _ = c.deflateEnd(&self.z);
        self.ready = false;
    }

    /// Forget the window (no_context_takeover): the next message references nothing before it.
    pub fn reset(self: *Deflater) void {
        if (self.ready) _ = c.deflateReset(&self.z);
    }

    /// Compress `input` as one message into `out` (cleared first), without the tail.
    pub fn compress(self: *Deflater, input: []const u8, out: *std.ArrayList(u8)) bool {
        if (!self.ready or input.len > std.math.maxInt(c_uint)) return false;
        out.clearRetainingCapacity();
        self.z.next_in = @ptrCast(@constCast(input.ptr));
        self.z.avail_in = @intCast(input.len);
        while (true) {
            out.ensureUnusedCapacity(gpa, CHUNK) catch return false;
            const spare = out.unusedCapacitySlice();
            self.z.next_out = spare.ptr;
            self.z.avail_out = @intCast(@min(spare.len, std.math.maxInt(c_uint)));
            const before = self.z.avail_out;
            const rc = c.deflate(&self.z, c.Z_SYNC_FLUSH);
            if (rc != c.Z_OK and rc != c.Z_BUF_ERROR) return false;
            out.items.len += before - self.z.avail_out;
            // zlib asks to be called again, with the same flush, until it leaves room unused
            if (self.z.avail_out != 0) break;
        }
        if (out.items.len >= 4 and std.mem.eql(u8, out.items[out.items.len - 4 ..], &TAIL)) out.items.len -= 4;
        return true;
    }
};

pub const InflateResult = enum { ok, too_large, bad, oom };

pub const Inflater = struct {
    z: c.z_stream = undefined,
    ready: bool = false,

    pub fn init(self: *Inflater) bool {
        self.deinit();
        self.z = std.mem.zeroes(c.z_stream);
        if (c.inflateInit2_(&self.z, -15, c.zlibVersion(), @sizeOf(c.z_stream)) != c.Z_OK) return false;
        self.ready = true;
        return true;
    }

    pub fn deinit(self: *Inflater) void {
        if (self.ready) _ = c.inflateEnd(&self.z);
        self.ready = false;
    }

    /// Inflate `input` (one message without its tail) into `out` (cleared
    /// first). The output is bounded by `limit` bytes: past it, too_large.
    pub fn run(self: *Inflater, input: []const u8, out: *std.ArrayList(u8), limit: u64) InflateResult {
        out.clearRetainingCapacity();
        if (!self.ready and !self.init()) return .oom;
        if (input.len > std.math.maxInt(c_uint)) return .too_large;
        const r1 = self.feed(input, out, limit);
        if (r1 != .ok) return r1;
        return self.feed(&TAIL, out, limit);
    }

    fn feed(self: *Inflater, input: []const u8, out: *std.ArrayList(u8), limit: u64) InflateResult {
        self.z.next_in = @ptrCast(@constCast(input.ptr));
        self.z.avail_in = @intCast(input.len);
        while (true) {
            out.ensureUnusedCapacity(gpa, CHUNK) catch return .oom;
            const spare = out.unusedCapacitySlice();
            self.z.next_out = spare.ptr;
            // one chunk per call, however much room the list has: the limit is checked between calls,
            // so it is what bounds a bomb
            self.z.avail_out = @intCast(@min(spare.len, CHUNK));
            const before = self.z.avail_out;
            const rc = c.inflate(&self.z, c.Z_SYNC_FLUSH);
            out.items.len += before - self.z.avail_out;
            if (out.items.len > limit) return .too_large;
            switch (rc) {
                c.Z_OK => {
                    // all input taken and room left over: this feed is done
                    if (self.z.avail_in == 0 and self.z.avail_out != 0) return .ok;
                },
                c.Z_STREAM_END => {
                    // a final block ended the stream; start the next message on a fresh one
                    // (a sender using zlib's sync flush never emits one)
                    _ = c.inflateReset(&self.z);
                    return .ok;
                },
                c.Z_BUF_ERROR => {
                    // no progress possible: with input exhausted that is simply the end
                    if (self.z.avail_in == 0) return .ok;
                    return .bad;
                },
                c.Z_MEM_ERROR => return .oom,
                else => return .bad,
            }
        }
    }
};

// ── Parameters of the extension (RFC 7692 section 7.1) ───────

pub const Params = struct {
    server_nct: bool = false,
    client_nct: bool = false,
    /// 0 = not present
    server_bits: u8 = 0,
    client_bits_present: bool = false,
    client_bits: u8 = 0,
};

fn windowBits(v: []const u8) ?u8 {
    const n = std.fmt.parseInt(u8, std.mem.trim(u8, v, " \t\""), 10) catch return null;
    if (n < 8 or n > 15) return null;
    return n;
}

/// Parse ONE extension offer or response: `permessage-deflate; param; param=v`.
/// Null when it names another extension, repeats a parameter, carries one this
/// engine does not know, or gives a window outside 8..15.
pub fn parseOffer(text: []const u8) ?Params {
    var it = std.mem.splitScalar(u8, text, ';');
    const name = std.mem.trim(u8, it.next() orelse return null, " \t");
    if (!std.ascii.eqlIgnoreCase(name, "permessage-deflate")) return null;
    var p = Params{};
    var seen_snct = false;
    var seen_cnct = false;
    var seen_sbits = false;
    var seen_cbits = false;
    while (it.next()) |raw| {
        const param = std.mem.trim(u8, raw, " \t");
        if (param.len == 0) return null;
        var kv = std.mem.splitScalar(u8, param, '=');
        const k = std.mem.trim(u8, kv.next().?, " \t");
        const v = kv.next();
        if (std.ascii.eqlIgnoreCase(k, "server_no_context_takeover")) {
            if (seen_snct or v != null) return null;
            seen_snct = true;
            p.server_nct = true;
        } else if (std.ascii.eqlIgnoreCase(k, "client_no_context_takeover")) {
            if (seen_cnct or v != null) return null;
            seen_cnct = true;
            p.client_nct = true;
        } else if (std.ascii.eqlIgnoreCase(k, "server_max_window_bits")) {
            if (seen_sbits) return null;
            seen_sbits = true;
            p.server_bits = windowBits(v orelse return null) orelse return null;
        } else if (std.ascii.eqlIgnoreCase(k, "client_max_window_bits")) {
            if (seen_cbits) return null;
            seen_cbits = true;
            p.client_bits_present = true;
            if (v) |vv| p.client_bits = windowBits(vv) orelse return null;
        } else return null;
    }
    return p;
}

// ── Tests ────────────────────────────────────────────────────

const testing = std.testing;

fn deflateOf(d: *Deflater, text: []const u8) ![]u8 {
    var out: std.ArrayList(u8) = .{};
    defer out.deinit(gpa);
    try testing.expect(d.compress(text, &out));
    return gpa.dupe(u8, out.items);
}

test "deflate: RFC 7692 7.2.3 -- Hello compresses to f2 48 cd c9 c9 07 00" {
    var d = Deflater{};
    defer d.deinit();
    try testing.expect(d.init(15));
    const a = try deflateOf(&d, "Hello");
    defer gpa.free(a);
    try testing.expectEqualSlices(u8, &.{ 0xf2, 0x48, 0xcd, 0xc9, 0xc9, 0x07, 0x00 }, a);
}

test "deflate: with context takeover the second Hello is f2 00 11 00 00, and with a reset it is the first again" {
    var d = Deflater{};
    defer d.deinit();
    try testing.expect(d.init(15));
    const a = try deflateOf(&d, "Hello");
    defer gpa.free(a);
    const b = try deflateOf(&d, "Hello");
    defer gpa.free(b);
    try testing.expectEqualSlices(u8, &.{ 0xf2, 0x00, 0x11, 0x00, 0x00 }, b);
    d.reset();
    const r = try deflateOf(&d, "Hello");
    defer gpa.free(r);
    try testing.expectEqualSlices(u8, a, r);
}

test "inflate: the RFC 7692 examples decode to Hello" {
    var inf = Inflater{};
    defer inf.deinit();
    var out: std.ArrayList(u8) = .{};
    defer out.deinit(gpa);
    const vectors = [_][]const u8{
        &.{ 0xf2, 0x48, 0xcd, 0xc9, 0xc9, 0x07, 0x00 }, // one compressed block
        &.{ 0xf2, 0x48, 0x05, 0x00, 0x00, 0x00, 0xff, 0xff, 0xca, 0xc9, 0xc9, 0x07, 0x00 }, // two blocks in one message
        &.{ 0x00, 0x05, 0x00, 0xfa, 0xff, 0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x00 }, // a stored block
        &.{ 0xf3, 0x48, 0xcd, 0xc9, 0xc9, 0x07, 0x00, 0x00 }, // BFINAL set, then an empty stored block
    };
    for (vectors) |v| {
        try testing.expectEqual(InflateResult.ok, inf.run(v, &out, 1000));
        try testing.expectEqualStrings("Hello", out.items);
    }
    // and the takeover reply, which only decodes after the first message
    var inf2 = Inflater{};
    defer inf2.deinit();
    try testing.expectEqual(InflateResult.ok, inf2.run(&.{ 0xf2, 0x48, 0xcd, 0xc9, 0xc9, 0x07, 0x00 }, &out, 1000));
    try testing.expectEqual(InflateResult.ok, inf2.run(&.{ 0xf2, 0x00, 0x11, 0x00, 0x00 }, &out, 1000));
    try testing.expectEqualStrings("Hello", out.items);
}

test "inflate: the second takeover message alone is not Hello -- the window really carries" {
    var inf = Inflater{};
    defer inf.deinit();
    var out: std.ArrayList(u8) = .{};
    defer out.deinit(gpa);
    const r = inf.run(&.{ 0xf2, 0x00, 0x11, 0x00, 0x00 }, &out, 1000);
    try testing.expect(r == .bad or !std.mem.eql(u8, out.items, "Hello"));
}

test "inflate: a bomb is refused at the limit, not after it has been built" {
    var d = Deflater{};
    defer d.deinit();
    try testing.expect(d.init(15));
    const zeros = try gpa.alloc(u8, 8 * 1024 * 1024);
    defer gpa.free(zeros);
    @memset(zeros, 0);
    const packed_msg = try deflateOf(&d, zeros);
    defer gpa.free(packed_msg);
    try testing.expect(packed_msg.len < 20_000); // 8 MiB in under 20 KB
    var inf = Inflater{};
    defer inf.deinit();
    var out: std.ArrayList(u8) = .{};
    defer out.deinit(gpa);
    try testing.expectEqual(InflateResult.too_large, inf.run(packed_msg, &out, 1000));
    try testing.expect(out.items.len <= 1000 + CHUNK); // one chunk past the limit at most
    // and the same message passes when the limit allows it
    var inf2 = Inflater{};
    defer inf2.deinit();
    try testing.expectEqual(InflateResult.ok, inf2.run(packed_msg, &out, 8 * 1024 * 1024));
    try testing.expectEqual(@as(usize, 8 * 1024 * 1024), out.items.len);
}

test "inflate: garbage is refused without a crash, and a round trip of every size is exact" {
    var prng = std.Random.DefaultPrng.init(0xD3F1A7E);
    const rand = prng.random();
    var inf = Inflater{};
    defer inf.deinit();
    var d = Deflater{};
    defer d.deinit();
    try testing.expect(d.init(15));
    var out: std.ArrayList(u8) = .{};
    defer out.deinit(gpa);
    var buf: [600]u8 = undefined;
    var i: usize = 0;
    while (i < 2000) : (i += 1) {
        const n = rand.uintLessThan(usize, buf.len);
        rand.bytes(buf[0..n]);
        _ = inf.run(buf[0..n], &out, 4096);
        try testing.expect(out.items.len <= 4096 + CHUNK);
        if (!inf.ready) _ = inf.init();
    }
    var inf3 = Inflater{};
    defer inf3.deinit();
    const sizes = [_]usize{ 0, 1, 64, 125, 126, 4096, 65535, 65536, 300000 };
    for (sizes) |sz| {
        const data = try gpa.alloc(u8, sz);
        defer gpa.free(data);
        rand.bytes(data);
        for (data, 0..) |*b, k| if (k % 3 != 0) {
            b.* = @intCast(k % 7); // compressible stretches among noise
        };
        const cm = try deflateOf(&d, data);
        defer gpa.free(cm);
        try testing.expectEqual(InflateResult.ok, inf3.run(cm, &out, 1 << 20));
        try testing.expectEqualSlices(u8, data, out.items);
    }
}

test "offer parsing: the parameters of RFC 7692 section 7.1" {
    const a = parseOffer("permessage-deflate").?;
    try testing.expect(!a.server_nct and !a.client_nct and a.server_bits == 0 and !a.client_bits_present);
    const b = parseOffer("permessage-deflate; client_max_window_bits; server_max_window_bits=10; server_no_context_takeover").?;
    try testing.expect(b.server_nct and b.server_bits == 10 and b.client_bits_present and b.client_bits == 0);
    const e = parseOffer("PermESSage-Deflate ; client_max_window_bits=12").?;
    try testing.expect(e.client_bits_present and e.client_bits == 12);
    try testing.expect(parseOffer("x-webkit-deflate-frame") == null);
    try testing.expect(parseOffer("permessage-deflate; bogus") == null);
    try testing.expect(parseOffer("permessage-deflate; server_no_context_takeover; server_no_context_takeover") == null);
    try testing.expect(parseOffer("permessage-deflate; server_max_window_bits=7") == null);
    try testing.expect(parseOffer("permessage-deflate; server_max_window_bits=16") == null);
    try testing.expect(parseOffer("permessage-deflate; server_max_window_bits") == null);
    try testing.expect(parseOffer("permessage-deflate; server_no_context_takeover=1") == null);
    try testing.expect(parseOffer("permessage-deflate; ") == null);
    try testing.expect(parseOffer("") == null);
}
