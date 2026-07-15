// Property-based + mutation testing for the engine crypto primitives that
// underpin request signing + the Commons KDF (quality track #3).
//
// SHA-256 invariants (over random inputs): DETERMINISM (same input -> same
// digest), SENSITIVITY (any changed byte -> a different digest -- the basis
// of signing's tamper detection), FIXED LENGTH (64 hex chars). Then MUTATION:
// a constant hash and a first-byte-only hash are each KILLED by SENSITIVITY.
//
// PBKDF2 invariants (Commons KDF -- password verification relies on these):
// DETERMINISM, SALT-SENSITIVITY, PASSWORD-SENSITIVITY.

const std = @import("std");
const crypto = @import("crypto.zig");

const HashFn = *const fn ([*]const u8, usize, [*]u8) callconv(.c) i32;

// mutants (same signature as crypto_sha256)
fn mutConst(ptr: [*]const u8, len: usize, out: [*]u8) callconv(.c) i32 {
    _ = ptr;
    _ = len;
    @memset(out[0..64], 'a'); // ignores the input entirely
    return 64;
}
fn mutFirstByte(ptr: [*]const u8, len: usize, out: [*]u8) callconv(.c) i32 {
    var one = [_]u8{if (len > 0) ptr[0] else 0}; // hashes ONLY the first byte
    return crypto.crypto_sha256(&one, 1, out);
}

// Check SHA-256 properties for a hash fn over random inputs. Returns true iff
// determinism + fixed length + sensitivity all hold.
fn hashHolds(f: HashFn, rand: std.Random) bool {
    var x: [64]u8 = undefined;
    var y: [64]u8 = undefined;
    var h1: [64]u8 = undefined;
    var h2: [64]u8 = undefined;
    const len = rand.intRangeAtMost(usize, 1, 64);
    for (x[0..len]) |*b| b.* = rand.int(u8);
    // DETERMINISM + FIXED LENGTH
    const n1 = f(&x, len, &h1);
    const n2 = f(&x, len, &h2);
    if (n1 != 64 or n2 != 64) return false;
    if (!std.mem.eql(u8, &h1, &h2)) return false;
    // SENSITIVITY: flip one byte -> a different digest
    @memcpy(y[0..len], x[0..len]);
    const idx = rand.uintLessThan(usize, len);
    y[idx] = x[idx] ^ (rand.intRangeAtMost(u8, 1, 255)); // guaranteed different byte
    var hy: [64]u8 = undefined;
    _ = f(&y, len, &hy);
    if (std.mem.eql(u8, &h1, &hy)) return false; // same digest for different input -> fail
    return true;
}

fn killHashMutant(f: HashFn, comptime name: []const u8, rand: std.Random) void {
    var i: usize = 0;
    while (i < 5000) : (i += 1) {
        if (!hashHolds(f, rand)) {
            std.debug.print("mutant killed: {s}\n", .{name});
            return;
        }
    }
    std.debug.print("FAIL: hash mutant '{s}' SURVIVED.\n", .{name});
    std.process.exit(1);
}

fn kdf(pw: []const u8, salt: []const u8, rounds: u32, out: []u8) usize {
    const n = crypto.crypto_pbkdf2_sha256(pw.ptr, pw.len, salt.ptr, salt.len, rounds, 16, out.ptr);
    return if (n > 0) @intCast(n) else 0;
}

pub fn main() void {
    var prng = std.Random.DefaultPrng.init(0xC0DE_C0FFEE_22);
    const rand = prng.random();

    // 1) SHA-256 properties on the real hash
    var i: usize = 0;
    const rounds: usize = 300_000;
    while (i < rounds) : (i += 1) {
        if (!hashHolds(crypto.crypto_sha256, rand)) {
            std.debug.print("FAIL: real sha256 violated a property (iter {d})\n", .{i});
            std.process.exit(1);
        }
    }
    std.debug.print("sha256: {d} inputs, determinism + sensitivity + length hold.\n", .{rounds});

    // 2) mutation: constant + first-byte-only hashes must be killed
    killHashMutant(mutConst, "constant-hash", rand);
    killHashMutant(mutFirstByte, "first-byte-only-hash", rand);

    // 3) PBKDF2 properties (Commons KDF)
    var pw: [32]u8 = undefined;
    var salt: [32]u8 = undefined;
    var a: [64]u8 = undefined;
    var b: [64]u8 = undefined;
    var kiter: usize = 0;
    const krounds: usize = 20_000;
    while (kiter < krounds) : (kiter += 1) {
        const pl = rand.intRangeAtMost(usize, 1, 32);
        const sl = rand.intRangeAtMost(usize, 1, 32);
        for (pw[0..pl]) |*x| x.* = rand.int(u8);
        for (salt[0..sl]) |*x| x.* = rand.int(u8);
        const r = rand.intRangeAtMost(u32, 1, 8);
        // DETERMINISM
        const n1 = kdf(pw[0..pl], salt[0..sl], r, &a);
        const n2 = kdf(pw[0..pl], salt[0..sl], r, &b);
        if (n1 == 0 or n1 != n2 or !std.mem.eql(u8, a[0..n1], b[0..n2])) {
            std.debug.print("FAIL: pbkdf2 not deterministic (iter {d})\n", .{kiter});
            std.process.exit(1);
        }
        // SALT SENSITIVITY (flip a salt byte)
        const si = rand.uintLessThan(usize, sl);
        salt[si] ^= rand.intRangeAtMost(u8, 1, 255);
        const n3 = kdf(pw[0..pl], salt[0..sl], r, &b);
        if (n3 == n1 and std.mem.eql(u8, a[0..n1], b[0..n3])) {
            std.debug.print("FAIL: pbkdf2 not salt-sensitive (iter {d})\n", .{kiter});
            std.process.exit(1);
        }
        // PASSWORD SENSITIVITY (flip a pw byte; salt now differs too, still must differ)
        const pi = rand.uintLessThan(usize, pl);
        pw[pi] ^= rand.intRangeAtMost(u8, 1, 255);
        const n4 = kdf(pw[0..pl], salt[0..sl], r, &b);
        if (n4 == n1 and std.mem.eql(u8, a[0..n1], b[0..n4])) {
            std.debug.print("FAIL: pbkdf2 not password-sensitive (iter {d})\n", .{kiter});
            std.process.exit(1);
        }
    }
    std.debug.print("pbkdf2: {d} inputs, determinism + salt/password sensitivity hold.\n", .{krounds});

    std.debug.print("PASS: crypto primitives hold all properties; hash mutants killed.\n", .{});
    std.process.exit(0);
}
