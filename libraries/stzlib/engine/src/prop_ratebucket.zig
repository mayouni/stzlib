// Property-based + mutation testing for the token-bucket rate limiter
// (quality track #3). Invariants a correct bucket of capacity C must satisfy,
// checked over random capacities:
//   P1 BURST BOUND     -- exactly C immediate single-takes succeed from a full
//                         bucket, then denials (the "never admit more than the
//                         burst" guarantee rate limiting exists for).
//   P2 CAP             -- available tokens never exceed the capacity.
//   P3 NON-NEGATIVE    -- available tokens never go below 0.
//   P4 DRAINED         -- after draining, an immediate take is denied.
// Then MUTATION: buggy buckets (always-take, off-by-one, lying-available) are
// each KILLED by a property -- proving the invariants have teeth.
//
// The real bucket refills on wall-clock; a low refill rate (1/sec) makes the
// microseconds spent taking C+5 tokens negligible (~0 refill), so the burst
// bound is exact.

const std = @import("std");
const resilience = @import("resilience.zig");

// checkBucket: run all four properties on a bucket type B (duck-typed:
// init(cap)/take()->bool/avail()->f64/deinit()). Returns true iff all hold.
fn checkBucket(comptime B: type, cap: u32) bool {
    var b = B.init(cap);
    defer b.deinit();
    const capf: f64 = @floatFromInt(cap);
    // P2/P3 at start
    const a0 = b.avail();
    if (a0 < -0.001 or a0 > capf + 0.5) return false;
    // P1: exactly `cap` immediate single-takes succeed, then denials
    var oks: u32 = 0;
    var t: u32 = 0;
    while (t < cap + 5) : (t += 1) {
        if (b.take()) oks += 1;
        const av = b.avail();
        if (av < -0.001 or av > capf + 0.5) return false; // P2/P3 throughout
    }
    if (oks != cap) return false;
    // P4: drained -> the next immediate take is denied, and avail < 1
    if (b.avail() >= 1.0) return false;
    if (b.take()) return false;
    return true;
}

const RealBucket = struct {
    r: ?*resilience.RateLimiter,
    fn init(cap: u32) RealBucket {
        return .{ .r = resilience.rate_create(cap, 1) }; // 1 tok/sec -> negligible refill
    }
    fn take(s: *RealBucket) bool {
        return resilience.rate_try_take(s.r, 1) == 1;
    }
    fn avail(s: *RealBucket) f64 {
        return resilience.rate_available(s.r);
    }
    fn deinit(s: *RealBucket) void {
        resilience.rate_destroy(s.r);
    }
};

// --- mutants ---
const MutAlwaysTake = struct { // ignores the budget entirely
    fn init(cap: u32) MutAlwaysTake {
        _ = cap;
        return .{};
    }
    fn take(_: *MutAlwaysTake) bool {
        return true;
    }
    fn avail(_: *MutAlwaysTake) f64 {
        return 0;
    }
    fn deinit(_: *MutAlwaysTake) void {}
};
const MutOffByOne = struct { // allows one token too many
    rem: i64,
    fn init(cap: u32) MutOffByOne {
        return .{ .rem = @as(i64, cap) + 1 };
    }
    fn take(s: *MutOffByOne) bool {
        if (s.rem > 0) {
            s.rem -= 1;
            return true;
        }
        return false;
    }
    fn avail(s: *MutOffByOne) f64 {
        return @floatFromInt(@max(s.rem, 0));
    }
    fn deinit(_: *MutOffByOne) void {}
};
const MutAvailLies = struct { // correct budget, but reports "always full"
    rem: i64,
    cap: u32,
    fn init(cap: u32) MutAvailLies {
        return .{ .rem = cap, .cap = cap };
    }
    fn take(s: *MutAvailLies) bool {
        if (s.rem > 0) {
            s.rem -= 1;
            return true;
        }
        return false;
    }
    fn avail(s: *MutAvailLies) f64 {
        return @floatFromInt(s.cap);
    }
    fn deinit(_: *MutAvailLies) void {}
};

fn killMutant(comptime B: type, comptime name: []const u8, rand: std.Random) void {
    var i: usize = 0;
    while (i < 2000) : (i += 1) {
        const cap = rand.intRangeAtMost(u32, 1, 64);
        if (!checkBucket(B, cap)) {
            std.debug.print("mutant killed: {s}\n", .{name});
            return;
        }
    }
    std.debug.print("FAIL: mutant '{s}' SURVIVED -- the properties miss this bug.\n", .{name});
    std.process.exit(1);
}

pub fn main() void {
    var prng = std.Random.DefaultPrng.init(0x5241_5445_1111);
    const rand = prng.random();

    // 1) property test the REAL bucket over random capacities
    const rounds: usize = 40_000;
    var iter: usize = 0;
    while (iter < rounds) : (iter += 1) {
        const cap = rand.intRangeAtMost(u32, 1, 64);
        if (!checkBucket(RealBucket, cap)) {
            std.debug.print("FAIL: real token bucket violated a property (cap {d}, iter {d})\n", .{ cap, iter });
            std.process.exit(1);
        }
    }
    std.debug.print("properties: {d} configs, real bucket holds P1-P4.\n", .{rounds});

    // 2) mutation test: each mutant must be killed
    killMutant(MutAlwaysTake, "always-take", rand);
    killMutant(MutOffByOne, "off-by-one-burst", rand);
    killMutant(MutAvailLies, "lying-available", rand);

    std.debug.print("PASS: real bucket holds all properties; all mutants killed.\n", .{});
    std.process.exit(0);
}
