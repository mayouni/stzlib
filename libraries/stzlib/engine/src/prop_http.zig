// Property-based + mutation testing for the HTTP framing (quality track #3).
//
// Where the fuzzer asserts "never crashes", this asserts CORRECTNESS via
// invariants that must hold over generated well-formed requests:
//   A. SELF-CONSISTENCY  -- a complete request frames to exactly its length.
//   B. PREFIX STABILITY  -- trailing bytes (a pipelined next request) never
//      change the first frame's length. This is the pipelining-safety
//      guarantee the server relies on.
//   C. INCREMENTAL       -- every proper prefix is "incomplete" (null): a
//      partial request is never mistaken for a complete one.
//
// Then MUTATION TESTING: the same properties are run against deliberately
// buggy framers (off-by-one, wrong comparison, ignored Content-Length). Each
// mutant MUST be killed (fail a property on some input) -- proving the
// properties actually have teeth, not that they pass vacuously.

const std = @import("std");
const framing = @import("http_framing.zig");

const Framer = *const fn ([]const u8) ?usize;

// The real implementation under test.
fn real(b: []const u8) ?usize {
    return framing.httpRequestLen(b);
}

// --- mutants: plausible bugs the properties should catch ---
fn mutContentLen0(b: []const u8) ?usize {
    // "forgets" the body: frames at the header terminator, ignoring Content-Length
    const he = std.mem.indexOf(u8, b, "\r\n\r\n") orelse return null;
    return he + 4;
}
fn mutHeaderOffBy1(b: []const u8) ?usize {
    // off-by-one: header_end = he + 3 instead of + 4
    const he = std.mem.indexOf(u8, b, "\r\n\r\n") orelse return null;
    const header_end = he + 3;
    const clen = framing.httpContentLength(b[0..@min(header_end, b.len)]);
    if (b.len >= header_end + clen) return header_end + clen;
    return null;
}
fn mutStrictGt(b: []const u8) ?usize {
    // wrong comparison: > instead of >= (an exact-fit request reads as incomplete)
    const he = std.mem.indexOf(u8, b, "\r\n\r\n") orelse return null;
    const header_end = he + 4;
    const clen = framing.httpContentLength(b[0..header_end]);
    if (b.len > header_end + clen) return header_end + clen;
    return null;
}

// Check all three properties for one generated request + a trailing suffix.
// Returns true iff EVERY property holds (a correct framer over clean input).
fn holds(f: Framer, req: []const u8, combined: []const u8, comb_len: usize) bool {
    // A: self-consistency
    if (f(req)) |n| {
        if (n != req.len) return false;
    } else return false;
    // B: prefix stability -- req + suffix still frames the first msg at req.len
    if (f(combined[0..comb_len])) |n| {
        if (n != req.len) return false;
    } else return false;
    // C: incremental -- a few proper prefixes must be incomplete (null)
    var k: usize = req.len - 1;
    var tries: usize = 0;
    while (tries < 4 and k > 0) : (tries += 1) {
        if (f(req[0..k]) != null) return false;
        k = k / 2;
    }
    return true;
}

// Generate a clean HTTP request into `buf`; the ONLY "\r\n\r\n" is the header
// terminator and the body carries no CR, so the frame boundary is unambiguous.
fn genRequest(rand: std.Random, buf: []u8) usize {
    const methods = [_][]const u8{ "GET", "POST", "PUT", "DELETE" };
    var len: usize = 0;
    const w = struct {
        fn put(dst: []u8, at: *usize, s: []const u8) void {
            @memcpy(dst[at.* .. at.* + s.len], s);
            at.* += s.len;
        }
    };
    w.put(buf, &len, methods[rand.uintLessThan(usize, methods.len)]);
    w.put(buf, &len, " /");
    const path_n = rand.uintLessThan(usize, 12);
    var i: usize = 0;
    while (i < path_n) : (i += 1) {
        buf[len] = "abcdefghij0123456789"[rand.uintLessThan(usize, 20)];
        len += 1;
    }
    w.put(buf, &len, " HTTP/1.1\r\n");
    // a few safe headers (names/values carry no CR/LF, name != content-length)
    const hn = rand.uintLessThan(usize, 4);
    var h: usize = 0;
    while (h < hn) : (h += 1) {
        w.put(buf, &len, "X-h");
        buf[len] = "abcd"[rand.uintLessThan(usize, 4)];
        len += 1;
        w.put(buf, &len, ": v");
        buf[len] = "wxyz"[rand.uintLessThan(usize, 4)];
        len += 1;
        w.put(buf, &len, "\r\n");
    }
    // the body length, then Content-Length + terminator + body (no CR bytes)
    const clen = rand.uintLessThan(usize, 200);
    var nb: [24]u8 = undefined;
    const ns = std.fmt.bufPrint(&nb, "Content-Length: {d}\r\n\r\n", .{clen}) catch unreachable;
    w.put(buf, &len, ns);
    var bcount: usize = 0;
    while (bcount < clen) : (bcount += 1) {
        var by = rand.int(u8);
        if (by == '\r') by = 'X'; // never a CR in the body -> no spurious terminator
        buf[len] = by;
        len += 1;
    }
    return len;
}

pub fn main() void {
    var prng = std.Random.DefaultPrng.init(0x50_5052_4F50);
    const rand = prng.random();
    var reqbuf: [1024]u8 = undefined;
    var comb: [1152]u8 = undefined;

    // 1) PROPERTY TEST the real implementation: every clean request must hold.
    const rounds: usize = 300_000;
    var iter: usize = 0;
    while (iter < rounds) : (iter += 1) {
        const rlen = genRequest(rand, &reqbuf);
        @memcpy(comb[0..rlen], reqbuf[0..rlen]);
        const extra = rand.uintLessThan(usize, 128);
        var e: usize = 0;
        while (e < extra) : (e += 1) comb[rlen + e] = rand.int(u8);
        if (!holds(real, reqbuf[0..rlen], &comb, rlen + extra)) {
            std.debug.print("FAIL: real framer violated a property (seeded, iter {d})\n", .{iter});
            std.process.exit(1);
        }
    }
    std.debug.print("properties: {d} inputs, real framer holds A/B/C.\n", .{rounds});

    // 2) MUTATION TEST: each mutant must be KILLED (fail a property somewhere).
    const mutants = [_]struct { name: []const u8, f: Framer }{
        .{ .name = "content-length-ignored", .f = mutContentLen0 },
        .{ .name = "header-end-off-by-one", .f = mutHeaderOffBy1 },
        .{ .name = "strict-greater-than", .f = mutStrictGt },
    };
    for (mutants) |m| {
        var killed = false;
        var mi: usize = 0;
        while (mi < 20_000) : (mi += 1) {
            const rlen = genRequest(rand, &reqbuf);
            @memcpy(comb[0..rlen], reqbuf[0..rlen]);
            const extra = rand.uintLessThan(usize, 64);
            var e: usize = 0;
            while (e < extra) : (e += 1) comb[rlen + e] = rand.int(u8);
            if (!holds(m.f, reqbuf[0..rlen], &comb, rlen + extra)) {
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

    std.debug.print("PASS: real framer holds all properties; all mutants killed.\n", .{});
    std.process.exit(0);
}
