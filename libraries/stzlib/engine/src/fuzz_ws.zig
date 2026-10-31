// Fuzz + property + mutation harness for the WebSocket frame parser (ws.zig),
// in the style of fuzz_http.zig and prop_http.zig.
//
// A frame length is attacker-controlled, so the parser is the most exposed
// code in the module. Built ReleaseSafe: any out-of-bounds read or overflow
// PANICS and fails the `zig build fuzz-ws` step.
//
//   1. FUZZ      random and biased bytes never crash the parser, never yield a
//                header longer than the input, a length over the maximum, or a
//                control frame over 125 bytes
//   2. PROPERTY  every well-formed frame round-trips: encode -> parse gives the
//                same fin / opcode / length / mask, the header length matches
//                the length form, and masking is an involution
//   3. MUTATION  deliberately broken parsers (no maximum check, 16-bit length
//                read as little-endian, off-by-one at 125/126) are each KILLED
//                by the properties -- so the properties have teeth

const std = @import("std");
const ws = @import("ws.zig");

fn run(input: []const u8, expect_masked: bool, max: u64) void {
    if (ws.parseHeader(input, expect_masked, max)) |h| {
        if (h.header_len > input.len) @panic("header longer than the input");
        if (h.len > max) @panic("length past the maximum accepted");
        if (h.opcode >= 0x8 and h.len > 125) @panic("control frame over 125 bytes accepted");
        if (h.opcode >= 0x8 and !h.fin) @panic("fragmented control frame accepted");
        if (h.masked != expect_masked) @panic("mask bit disagrees with the side");
    } else |_| {}
}

// Mutants of the parser -- plausible bugs the properties must catch.
const Parser = *const fn ([]const u8, bool, u64) ws.ParseError!ws.Header;

fn mutNoMax(buf: []const u8, em: bool, max: u64) ws.ParseError!ws.Header {
    _ = max;
    return ws.parseHeader(buf, em, std.math.maxInt(u64));
}
fn mutLittleEndian16(buf: []const u8, em: bool, max: u64) ws.ParseError!ws.Header {
    var h = try ws.parseHeader(buf, em, max);
    if (h.header_len >= 4 and (buf[1] & 0x7F) == 126) h.len = (@as(u64, buf[3]) << 8) | buf[2];
    return h;
}
fn mutOffByOne(buf: []const u8, em: bool, max: u64) ws.ParseError!ws.Header {
    // treats 125 as the first two-byte length (a classic boundary slip)
    if (buf.len >= 2 and (buf[1] & 0x7F) == 125) {
        if (buf.len < 4) return error.Incomplete;
        var tmp: [14]u8 = undefined;
        const n = @min(buf.len, 14);
        @memcpy(tmp[0..n], buf[0..n]);
        tmp[1] = (buf[1] & 0x80) | 126;
        return ws.parseHeader(tmp[0..n], em, max);
    }
    return ws.parseHeader(buf, em, max);
}

fn holds(parse: Parser, rand: std.Random, buf: []u8) bool {
    const fin = rand.boolean();
    const data_ops = [_]u8{ ws.OP_CONT, ws.OP_TEXT, ws.OP_BINARY };
    const ctrl_ops = [_]u8{ ws.OP_CLOSE, ws.OP_PING, ws.OP_PONG };
    const control = rand.uintLessThan(u8, 4) == 0;
    const opcode = if (control) ctrl_ops[rand.uintLessThan(usize, 3)] else data_ops[rand.uintLessThan(usize, 3)];
    const masked = rand.boolean();
    // lengths across every form, dense around the boundaries
    const len: u64 = switch (rand.uintLessThan(u8, 6)) {
        0 => rand.uintLessThan(u64, 126),
        1 => 125,
        2 => 126,
        3 => 126 + rand.uintLessThan(u64, 65535 - 126),
        4 => 65535,
        else => 65536 + rand.uintLessThan(u64, 1 << 20),
    };
    const l: u64 = if (control) @min(len, 125) else len;
    var mask: [4]u8 = undefined;
    rand.bytes(&mask);
    var hdr: [14]u8 = undefined;
    const hl = ws.writeHeader(&hdr, if (control) true else fin, opcode, masked, l, mask);
    @memcpy(buf[0..hl], hdr[0..hl]);
    const h = parse(buf[0..hl], masked, 1 << 21) catch return false;
    if (h.len != l or h.opcode != opcode or h.masked != masked or h.header_len != hl) return false;
    if (!control and h.fin != fin) return false;
    if (masked and !std.mem.eql(u8, &h.mask, &mask)) return false;
    const expect_hl: usize = @as(usize, if (l <= 125) 2 else if (l <= 65535) 4 else 10) + @as(usize, if (masked) 4 else 0);
    if (hl != expect_hl) return false;
    // one byte over a small maximum must be refused, exactly at the maximum accepted
    if (parse(buf[0..hl], masked, l)) |_| {} else |_| return false;
    if (l > 0) {
        if (parse(buf[0..hl], masked, l - 1)) |_| {
            return false;
        } else |e| {
            if (e != error.TooLarge) return false;
        }
    }
    return true;
}

pub fn main() void {
    // 1) fuzz
    var prng = std.Random.DefaultPrng.init(0x5EC_0FFE);
    const rand = prng.random();
    var buf: [1024]u8 = undefined;
    var iter: usize = 0;
    const rounds: usize = 2_000_000;
    while (iter < rounds) : (iter += 1) {
        const len = rand.uintLessThan(usize, 32);
        for (buf[0..len]) |*b| b.* = rand.int(u8);
        if (len >= 2) {
            switch (rand.uintLessThan(u8, 4)) {
                0 => buf[1] = (buf[1] & 0x80) | 126,
                1 => buf[1] = (buf[1] & 0x80) | 127,
                2 => buf[0] = (buf[0] & 0xF0) | rand.uintLessThan(u8, 11),
                else => {},
            }
        }
        const max: u64 = @as(u64, 1) << @as(u6, rand.uintLessThan(u6, 48));
        run(buf[0..len], rand.boolean(), max);
    }
    std.debug.print("fuzz: {d} inputs, no crash, no length past the maximum.\n", .{rounds});

    // masking is an involution at every offset
    var mi: usize = 0;
    while (mi < 100_000) : (mi += 1) {
        const n = rand.uintLessThan(usize, 300);
        var data: [300]u8 = undefined;
        var copy: [300]u8 = undefined;
        rand.bytes(data[0..n]);
        @memcpy(copy[0..n], data[0..n]);
        var key: [4]u8 = undefined;
        rand.bytes(&key);
        const start = rand.uintLessThan(usize, 8);
        ws.applyMask(data[0..n], key, start);
        ws.applyMask(data[0..n], key, start);
        if (!std.mem.eql(u8, data[0..n], copy[0..n])) {
            std.debug.print("FAIL: masking is not an involution (iter {d})\n", .{mi});
            std.process.exit(1);
        }
    }
    std.debug.print("masking: 100000 round trips, involution holds.\n", .{});

    // 2) properties over the real parser
    var pi: usize = 0;
    while (pi < 300_000) : (pi += 1) {
        if (!holds(ws.parseHeader, rand, &buf)) {
            std.debug.print("FAIL: the real parser violated a round-trip property (iter {d})\n", .{pi});
            std.process.exit(1);
        }
    }
    std.debug.print("properties: 300000 frames, encode -> parse round-trips and the maximum is exact.\n", .{});

    // 3) mutants must die
    const mutants = [_]struct { name: []const u8, f: Parser }{
        .{ .name = "maximum-ignored", .f = mutNoMax },
        .{ .name = "16-bit-length-little-endian", .f = mutLittleEndian16 },
        .{ .name = "off-by-one-at-125", .f = mutOffByOne },
    };
    for (mutants) |m| {
        var killed = false;
        var k: usize = 0;
        while (k < 20_000) : (k += 1) {
            if (!holds(m.f, rand, &buf)) {
                killed = true;
                break;
            }
        }
        if (!killed) {
            std.debug.print("FAIL: mutant '{s}' SURVIVED -- the properties miss this bug.\n", .{m.name});
            std.process.exit(1);
        }
        std.debug.print("mutant killed: {s}\n", .{m.name});
    }
    std.debug.print("PASS: frame parser fuzzed, properties hold, all mutants killed.\n", .{});
    std.process.exit(0);
}
