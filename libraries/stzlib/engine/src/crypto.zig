const std = @import("std");

// ── Cryptographic Hashing (SHA-256, MD5, CRC-32) ──────────
// Pure Zig implementations via std.crypto / std.hash.

pub fn crypto_sha256(data_ptr: [*]const u8, data_len: usize, out: [*]u8) callconv(.c) i32 {
    var hash: [32]u8 = undefined;
    if (data_len == 0) {
        std.crypto.hash.sha2.Sha256.hash("", &hash, .{});
    } else {
        std.crypto.hash.sha2.Sha256.hash(data_ptr[0..data_len], &hash, .{});
    }
    @memcpy(out[0..64], &hexEncode(hash));
    return 64;
}

pub fn crypto_md5(data_ptr: [*]const u8, data_len: usize, out: [*]u8) callconv(.c) i32 {
    var hash: [16]u8 = undefined;
    if (data_len == 0) {
        std.crypto.hash.Md5.hash("", &hash, .{});
    } else {
        std.crypto.hash.Md5.hash(data_ptr[0..data_len], &hash, .{});
    }
    @memcpy(out[0..32], &hexEncodeMd5(hash));
    return 32;
}

pub fn crypto_sha256_raw(data_ptr: [*]const u8, data_len: usize, out: [*]u8) callconv(.c) i32 {
    var hash: [32]u8 = undefined;
    if (data_len == 0) {
        std.crypto.hash.sha2.Sha256.hash("", &hash, .{});
    } else {
        std.crypto.hash.sha2.Sha256.hash(data_ptr[0..data_len], &hash, .{});
    }
    @memcpy(out[0..32], &hash);
    return 32;
}

pub fn crypto_crc32(data_ptr: [*]const u8, data_len: usize) callconv(.c) u32 {
    if (data_len == 0) return 0;
    return std.hash.crc.Crc32IsoHdlc.hash(data_ptr[0..data_len]);
}

pub fn crypto_fnv32(data_ptr: [*]const u8, data_len: usize) callconv(.c) u32 {
    if (data_len == 0) return 0x811c9dc5;
    return std.hash.Fnv1a_32.hash(data_ptr[0..data_len]);
}

pub fn crypto_fnv64(data_ptr: [*]const u8, data_len: usize) callconv(.c) u64 {
    if (data_len == 0) return 0xcbf29ce484222325;
    return std.hash.Fnv1a_64.hash(data_ptr[0..data_len]);
}

pub fn crypto_equal(a_ptr: [*]const u8, b_ptr: [*]const u8, len: usize) callconv(.c) i32 {
    if (len == 0) return 1;
    var diff: u8 = 0;
    for (0..len) |i| {
        diff |= a_ptr[i] ^ b_ptr[i];
    }
    return if (diff == 0) 1 else 0;
}

// ── Key derivation (PBKDF2-HMAC-SHA256) + CSPRNG salt ─────────
// The password-hashing floor for the Commons (stzPlatform/stzSuperApp
// identity): store a per-user salt + an iterated derived key, never the
// plaintext secret. PBKDF2 is deliberately slow (configurable rounds)
// so an offline attacker pays per guess.

const HmacSha256 = std.crypto.auth.hmac.sha2.HmacSha256;

/// PBKDF2-HMAC-SHA256. Derives `dk_len` bytes into `out` (hex-encoded,
/// 2*dk_len chars) from password+salt over `rounds` iterations.
/// Returns the number of hex chars written, or -1 on error.
pub fn crypto_pbkdf2_sha256(
    pw_ptr: [*]const u8,
    pw_len: usize,
    salt_ptr: [*]const u8,
    salt_len: usize,
    rounds: u32,
    dk_len: usize,
    out: [*]u8,
) callconv(.c) i32 {
    if (dk_len == 0 or dk_len > 64 or rounds == 0) return -1;
    var dk: [64]u8 = undefined;
    std.crypto.pwhash.pbkdf2(
        dk[0..dk_len],
        pw_ptr[0..pw_len],
        salt_ptr[0..salt_len],
        rounds,
        HmacSha256,
    ) catch return -1;
    const hex = "0123456789abcdef";
    var i: usize = 0;
    while (i < dk_len) : (i += 1) {
        out[i * 2] = hex[dk[i] >> 4];
        out[i * 2 + 1] = hex[dk[i] & 0x0f];
    }
    return @intCast(dk_len * 2);
}

/// Fill `out[0..n]` with CSPRNG bytes, hex-encoded (2*n chars written).
/// Returns hex chars written, or -1 on error.
pub fn crypto_random_hex(n: usize, out: [*]u8) callconv(.c) i32 {
    if (n == 0 or n > 64) return -1;
    var buf: [64]u8 = undefined;
    std.crypto.random.bytes(buf[0..n]);
    const hex = "0123456789abcdef";
    var i: usize = 0;
    while (i < n) : (i += 1) {
        out[i * 2] = hex[buf[i] >> 4];
        out[i * 2 + 1] = hex[buf[i] & 0x0f];
    }
    return @intCast(n * 2);
}

// ── TOTP (RFC 6238 / HOTP RFC 4226) ──────────────────────────
// The one crypto primitive for a time-based second factor (2FA). The shared key
// arrives as HEX (ASCII in), so no raw key bytes ever cross the Ring<->engine
// text boundary (which validates UTF-8 and would mangle them). Computes HMAC
// over the 8-byte big-endian time counter, applies RFC 4226 dynamic truncation,
// and writes a zero-padded decimal code (ASCII out). algo: 1 = SHA1 (the
// authenticator-app default, Google Authenticator compatible), 2 = SHA256.
// digits: 1..9. Returns chars written, or -1 on bad input.

const HmacSha1 = std.crypto.auth.hmac.HmacSha1;

fn hexNibble(c: u8) ?u8 {
    return switch (c) {
        '0'...'9' => c - '0',
        'a'...'f' => c - 'a' + 10,
        'A'...'F' => c - 'A' + 10,
        else => null,
    };
}

pub fn crypto_totp(
    key_hex_ptr: [*]const u8,
    key_hex_len: usize,
    counter: u64,
    digits: u32,
    algo: u32,
    out: [*]u8,
) callconv(.c) i32 {
    if (digits < 1 or digits > 9) return -1;
    if (key_hex_len == 0 or key_hex_len % 2 != 0 or key_hex_len > 256) return -1;
    var key: [128]u8 = undefined;
    const klen: usize = key_hex_len / 2;
    var i: usize = 0;
    while (i < klen) : (i += 1) {
        const hi = hexNibble(key_hex_ptr[i * 2]) orelse return -1;
        const lo = hexNibble(key_hex_ptr[i * 2 + 1]) orelse return -1;
        key[i] = (@as(u8, hi) << 4) | lo;
    }
    var msg: [8]u8 = undefined;
    std.mem.writeInt(u64, &msg, counter, .big);
    var mac: [32]u8 = undefined;
    var mac_len: usize = 20;
    if (algo == 2) {
        HmacSha256.create(mac[0..32], &msg, key[0..klen]);
        mac_len = 32;
    } else {
        HmacSha1.create(mac[0..20], &msg, key[0..klen]);
        mac_len = 20;
    }
    const offset: usize = mac[mac_len - 1] & 0x0f;
    const bin: u32 = (@as(u32, mac[offset] & 0x7f) << 24) |
        (@as(u32, mac[offset + 1]) << 16) |
        (@as(u32, mac[offset + 2]) << 8) |
        (@as(u32, mac[offset + 3]));
    var modv: u32 = 1;
    var d: u32 = 0;
    while (d < digits) : (d += 1) modv *= 10;
    var code: u32 = bin % modv;
    var j: usize = digits;
    while (j > 0) {
        j -= 1;
        out[j] = '0' + @as(u8, @intCast(code % 10));
        code /= 10;
    }
    return @intCast(digits);
}

fn hexEncode(hash: [32]u8) [64]u8 {
    const hex = "0123456789abcdef";
    var out: [64]u8 = undefined;
    for (0..32) |i| {
        out[i * 2] = hex[hash[i] >> 4];
        out[i * 2 + 1] = hex[hash[i] & 0x0f];
    }
    return out;
}

fn hexEncodeMd5(hash: [16]u8) [32]u8 {
    const hex = "0123456789abcdef";
    var out: [32]u8 = undefined;
    for (0..16) |i| {
        out[i * 2] = hex[hash[i] >> 4];
        out[i * 2 + 1] = hex[hash[i] & 0x0f];
    }
    return out;
}

// ── C ABI exports ────────────────────────────────────────────

pub export fn stz_crypto_sha256(p: [*]const u8, l: usize, o: [*]u8) callconv(.c) i32 { return crypto_sha256(p, l, o); }
pub export fn stz_crypto_md5(p: [*]const u8, l: usize, o: [*]u8) callconv(.c) i32 { return crypto_md5(p, l, o); }
pub export fn stz_crypto_sha256_raw(p: [*]const u8, l: usize, o: [*]u8) callconv(.c) i32 { return crypto_sha256_raw(p, l, o); }
pub export fn stz_crypto_crc32(p: [*]const u8, l: usize) callconv(.c) u32 { return crypto_crc32(p, l); }
pub export fn stz_crypto_fnv32(p: [*]const u8, l: usize) callconv(.c) u32 { return crypto_fnv32(p, l); }
pub export fn stz_crypto_fnv64(p: [*]const u8, l: usize) callconv(.c) u64 { return crypto_fnv64(p, l); }
pub export fn stz_crypto_equal(a: [*]const u8, b: [*]const u8, l: usize) callconv(.c) i32 { return crypto_equal(a, b, l); }
pub export fn stz_crypto_pbkdf2_sha256(pw: [*]const u8, pl: usize, s: [*]const u8, sl: usize, r: u32, dl: usize, o: [*]u8) callconv(.c) i32 { return crypto_pbkdf2_sha256(pw, pl, s, sl, r, dl, o); }
pub export fn stz_crypto_random_hex(n: usize, o: [*]u8) callconv(.c) i32 { return crypto_random_hex(n, o); }
pub export fn stz_crypto_totp(k: [*]const u8, kl: usize, c: u64, d: u32, a: u32, o: [*]u8) callconv(.c) i32 { return crypto_totp(k, kl, c, d, a, o); }

// ── Tests ────────────────────────────────────────────────────

test "crypto: sha256" {
    var out: [64]u8 = undefined;
    const len = crypto_sha256("hello".ptr, 5, &out);
    try std.testing.expectEqual(@as(i32, 64), len);
    try std.testing.expectEqualStrings("2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824", &out);
}

test "crypto: md5" {
    var out: [32]u8 = undefined;
    const len = crypto_md5("hello".ptr, 5, &out);
    try std.testing.expectEqual(@as(i32, 32), len);
    try std.testing.expectEqualStrings("5d41402abc4b2a76b9719d911017c592", &out);
}

test "crypto: sha256 empty" {
    var out: [64]u8 = undefined;
    const len = crypto_sha256("".ptr, 0, &out);
    try std.testing.expectEqual(@as(i32, 64), len);
    try std.testing.expectEqualStrings("e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855", &out);
}

test "crypto: crc32" {
    const crc = crypto_crc32("hello".ptr, 5);
    try std.testing.expectEqual(@as(u32, 0x3610a686), crc);
}

test "crypto: fnv32" {
    const h = crypto_fnv32("hello".ptr, 5);
    try std.testing.expect(h != 0);
}

test "crypto: fnv64" {
    const h = crypto_fnv64("hello".ptr, 5);
    try std.testing.expect(h != 0);
}

test "crypto: constant-time equal" {
    try std.testing.expectEqual(@as(i32, 1), crypto_equal("abc".ptr, "abc".ptr, 3));
    try std.testing.expectEqual(@as(i32, 0), crypto_equal("abc".ptr, "abd".ptr, 3));
}

test "crypto: sha256 raw" {
    var out: [32]u8 = undefined;
    const len = crypto_sha256_raw("hello".ptr, 5, &out);
    try std.testing.expectEqual(@as(i32, 32), len);
}

test "crypto: totp sha1 rfc6238 vector (8 digits, t=59)" {
    // RFC 6238 App.B seed "12345678901234567890" (20 ascii bytes) as hex; T=59 -> counter 1.
    const keyhex = "3132333435363738393031323334353637383930";
    var out: [9]u8 = undefined;
    const n = crypto_totp(keyhex.ptr, keyhex.len, 1, 8, 1, &out);
    try std.testing.expectEqual(@as(i32, 8), n);
    try std.testing.expectEqualStrings("94287082", out[0..8]);
}

test "crypto: totp sha1 6-digit (authenticator default)" {
    const keyhex = "3132333435363738393031323334353637383930";
    var out: [9]u8 = undefined;
    const n = crypto_totp(keyhex.ptr, keyhex.len, 1, 6, 1, &out);
    try std.testing.expectEqual(@as(i32, 6), n);
    try std.testing.expectEqualStrings("287082", out[0..6]);
}

test "crypto: totp sha1 later counter (t=1234567890)" {
    const keyhex = "3132333435363738393031323334353637383930";
    var out: [9]u8 = undefined;
    // T = floor(1234567890/30) = 41152263 = 0x273EF07
    const n = crypto_totp(keyhex.ptr, keyhex.len, 41152263, 8, 1, &out);
    try std.testing.expectEqual(@as(i32, 8), n);
    try std.testing.expectEqualStrings("89005924", out[0..8]);
}

test "crypto: totp sha256 rfc6238 vector (8 digits, t=59)" {
    // SHA256 seed is 32 ascii bytes "12345678901234567890123456789012".
    const keyhex = "3132333435363738393031323334353637383930313233343536373839303132";
    var out: [9]u8 = undefined;
    const n = crypto_totp(keyhex.ptr, keyhex.len, 1, 8, 2, &out);
    try std.testing.expectEqual(@as(i32, 8), n);
    try std.testing.expectEqualStrings("46119246", out[0..8]);
}

test "crypto: totp rejects bad input" {
    var out: [9]u8 = undefined;
    try std.testing.expectEqual(@as(i32, -1), crypto_totp("abc".ptr, 3, 1, 6, 1, &out)); // odd hex
    try std.testing.expectEqual(@as(i32, -1), crypto_totp("3132".ptr, 4, 1, 0, 1, &out)); // 0 digits
    try std.testing.expectEqual(@as(i32, -1), crypto_totp("zz".ptr, 2, 1, 6, 1, &out)); // non-hex
}
