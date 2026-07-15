// Fuzz harness for the reactor's HTTP framing (the most-exposed untrusted-
// input parser -- it runs on every server connection's raw bytes).
//
// Built with safety checks ON (ReleaseSafe); any out-of-bounds read, integer
// overflow, or bad slice inside the parser PANICS with a stack trace, failing
// the `zig build fuzz-http` step. Two phases: a hand-curated regression
// corpus of nasty edge cases, then millions of PRNG-mutated inputs biased
// toward HTTP-ish bytes so the parser is exercised deeply.

const std = @import("std");
const framing = @import("http_framing.zig");

// The invariant every call must uphold, whatever the input: never read out of
// bounds, never overflow, and never claim a frame LONGER than the input.
fn run(input: []const u8) void {
    if (framing.httpRequestLen(input)) |n| {
        if (n > input.len) @panic("httpRequestLen returned a length past the buffer");
        _ = framing.httpContentLength(input[0..n]);
    }
    _ = framing.httpContentLength(input);
}

pub fn main() void {
    // 1) regression corpus -- crafted edge cases (incl. the Content-Length
    //    overflow that used to panic the server thread).
    const corpus = [_][]const u8{
        "",
        "\r",
        "\n",
        "\r\n",
        "\r\n\r\n",
        ":",
        "Content-Length:",
        "GET / HTTP/1.1\r\n\r\n",
        "GET / HTTP/1.1\r\nContent-Length: 5\r\n\r\nhello",
        "GET / HTTP/1.1\r\nContent-Length: 5\r\n\r\nhi", // body not yet complete
        "GET / HTTP/1.1\r\nContent-Length: 0\r\n\r\n",
        "POST / HTTP/1.1\r\nContent-Length: 18446744073709551615\r\n\r\nx", // usize-max overflow attempt
        "POST / HTTP/1.1\r\nContent-Length: 99999999999999999999999999\r\n\r\n", // > usize
        "POST / HTTP/1.1\r\nContent-Length: -1\r\n\r\n",
        "POST / HTTP/1.1\r\nContent-Length:    7   \r\n\r\nabcdefg",
        "POST / HTTP/1.1\r\ncontent-LENGTH: 3\r\n\r\nxyz",
        "\r\n\r\nContent-Length: 3\r\n\r\n",
        ":::::\r\n\r\n:::::",
        "X\r\nContent-Length\r\n\r\n",
        "Content-Length: \r\n\r\n",
    };
    for (corpus) |ct| run(ct);

    // 2) mutation fuzzing -- seeded so a failure reproduces exactly.
    var prng = std.Random.DefaultPrng.init(0xC0FFEE_1234);
    const rand = prng.random();
    const clen = "content-length";
    var buf: [8192]u8 = undefined;
    var iter: usize = 0;
    const rounds: usize = 1_000_000;
    while (iter < rounds) : (iter += 1) {
        const len = rand.uintLessThan(usize, buf.len);
        for (buf[0..len]) |*b| {
            b.* = switch (rand.uintLessThan(u8, 12)) {
                0 => '\r',
                1 => '\n',
                2 => ':',
                3 => ' ',
                4 => '\t',
                5, 6 => clen[rand.uintLessThan(usize, clen.len)],
                7 => "0123456789"[rand.uintLessThan(usize, 10)],
                else => rand.int(u8),
            };
        }
        run(buf[0..len]);
    }
    std.debug.print("PASS: {d} corpus + {d} fuzzed inputs, no OOB / overflow / bad frame.\n", .{ corpus.len, rounds });
    std.process.exit(0);
}
