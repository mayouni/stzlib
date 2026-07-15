// Fuzz harness for utf8proc -- Unicode normalization/segmentation, run on
// EVERY user string (including invalid UTF-8). Compiled under UBSan-trap.
// Feeds random bytes (much of it invalid UTF-8) to the normalization map and
// the codepoint iterator; both must reject bad input without crashing / UB.

const std = @import("std");
const c = @cImport({
    @cDefine("UTF8PROC_STATIC", "1");
    @cInclude("utf8proc.h");
});

fn fuzzMap(bytes: []const u8) void {
    var dst: [*c]u8 = null;
    // NFC normalization (STABLE|COMPOSE) -- allocates *dst on success.
    const n = c.utf8proc_map(bytes.ptr, @intCast(bytes.len), &dst, c.UTF8PROC_STABLE | c.UTF8PROC_COMPOSE);
    if (n >= 0 and dst != null) std.c.free(dst);
}

fn fuzzIterate(bytes: []const u8) void {
    var pos: usize = 0;
    var guard: usize = 0;
    while (pos < bytes.len and guard < 4096) : (guard += 1) {
        var cp: c.utf8proc_int32_t = 0;
        const n = c.utf8proc_iterate(bytes.ptr + pos, @intCast(bytes.len - pos), &cp);
        if (n <= 0) break; // invalid sequence -> stop, no crash
        pos += @intCast(n);
    }
}

pub fn main() void {
    var prng = std.Random.DefaultPrng.init(0xABCDEF01_5678);
    const rand = prng.random();
    var buf: [512]u8 = undefined;
    var iter: usize = 0;
    const rounds: usize = 500_000;
    while (iter < rounds) : (iter += 1) {
        const len = rand.uintLessThan(usize, buf.len);
        for (buf[0..len]) |*ch| {
            // mix: raw random + high bytes (multibyte lead/continuation) so we
            // hit both valid and truncated/overlong UTF-8 sequences
            ch.* = switch (rand.uintLessThan(u8, 4)) {
                0 => rand.int(u8) | 0x80, // continuation/lead-ish
                1 => rand.intRangeAtMost(u8, 0xC0, 0xFF), // lead bytes
                else => rand.int(u8),
            };
        }
        fuzzMap(buf[0..len]);
        fuzzIterate(buf[0..len]);
    }
    std.debug.print("PASS: {d} utf8proc map+iterate inputs, no crash / UB.\n", .{rounds});
    std.process.exit(0);
}
