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

// HMAC-SHA256, keyed (incident I1). HMAC lived here already, but only
// INSIDE pbkdf2 and totp -- nothing could seal a payload with a key.
// The security ledger's export seal needs exactly that: a digest an
// attacker who can edit the evidence still cannot recompute.
pub fn crypto_hmac_sha256(key_ptr: [*]const u8, key_len: usize, msg_ptr: [*]const u8, msg_len: usize, out: [*]u8) callconv(.c) i32 {
    var mac: [32]u8 = undefined;
    const key = if (key_len == 0) "" else key_ptr[0..key_len];
    const msg = if (msg_len == 0) "" else msg_ptr[0..msg_len];
    HmacSha256.create(&mac, msg, key);
    @memcpy(out[0..64], &hexEncode(mac));
    return 64;
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

// ── Public-key signature VERIFICATION (RS256 / ES256) ────────
// The one primitive the whole external-identity story turns on: OAuth/OIDC
// (JWT id-tokens signed by a provider's JWKS key), SSO, and passkeys/WebAuthn
// all reduce to "verify this signature against a PUBLIC key we fetched".
// Verification only -- Softanza never holds a private signing key here.
//
// EVERYTHING CROSSES AS BASE64URL (ASCII), never raw bytes: the Ring<->engine
// boundary validates UTF-8, so a raw key or signature would be mangled. That is
// also exactly the wire format -- a JWS signature and every JWKS field (n, e,
// x, y) are base64url -- so no conversion is needed on either side.
//
// Returns 1 = signature valid, 0 = invalid, -1 = malformed input.

const Ecdsa256 = std.crypto.sign.ecdsa.EcdsaP256Sha256;
const rsa = std.crypto.Certificate.rsa;
const Sha256 = std.crypto.hash.sha2.Sha256;

/// base64url -> bytes, tolerating optional '=' padding. null on bad input.
fn b64UrlDecode(src: []const u8, dest: []u8) ?[]u8 {
    var end = src.len;
    while (end > 0 and src[end - 1] == '=') end -= 1;
    const s = src[0..end];
    const dec = std.base64.url_safe_no_pad.Decoder;
    const n = dec.calcSizeForSlice(s) catch return null;
    if (n > dest.len) return null;
    dec.decode(dest[0..n], s) catch return null;
    return dest[0..n];
}

/// ES256 (ECDSA P-256 + SHA-256). Key is the JWK's x/y coordinates; signature
/// is the JWS 64-byte r||s form. msg = the signing input ("header.payload").
pub fn crypto_verify_es256(
    msg_ptr: [*]const u8,
    msg_len: usize,
    sig_ptr: [*]const u8,
    sig_len: usize,
    x_ptr: [*]const u8,
    x_len: usize,
    y_ptr: [*]const u8,
    y_len: usize,
) callconv(.c) i32 {
    var sig_buf: [128]u8 = undefined;
    var x_buf: [64]u8 = undefined;
    var y_buf: [64]u8 = undefined;
    const sig = b64UrlDecode(sig_ptr[0..sig_len], &sig_buf) orelse return -1;
    const x = b64UrlDecode(x_ptr[0..x_len], &x_buf) orelse return -1;
    const y = b64UrlDecode(y_ptr[0..y_len], &y_buf) orelse return -1;
    if (x.len != 32 or y.len != 32) return -1;
    if (sig.len != 64) return 0;
    var sec1: [65]u8 = undefined;
    sec1[0] = 0x04; // uncompressed point
    @memcpy(sec1[1..33], x);
    @memcpy(sec1[33..65], y);
    const pk = Ecdsa256.PublicKey.fromSec1(&sec1) catch return -1;
    const s = Ecdsa256.Signature.fromBytes(sig[0..64].*);
    s.verify(msg_ptr[0..msg_len], pk) catch return 0;
    return 1;
}

/// RS256 (RSASSA-PKCS1-v1_5 + SHA-256). Key is the JWK's n (modulus) and e
/// (exponent). Supports 1024/2048/3072/4096-bit moduli.
pub fn crypto_verify_rs256(
    msg_ptr: [*]const u8,
    msg_len: usize,
    sig_ptr: [*]const u8,
    sig_len: usize,
    n_ptr: [*]const u8,
    n_len: usize,
    e_ptr: [*]const u8,
    e_len: usize,
) callconv(.c) i32 {
    var sig_buf: [512]u8 = undefined;
    var n_buf: [512]u8 = undefined;
    var e_buf: [64]u8 = undefined;
    const sig = b64UrlDecode(sig_ptr[0..sig_len], &sig_buf) orelse return -1;
    const n = b64UrlDecode(n_ptr[0..n_len], &n_buf) orelse return -1;
    const e = b64UrlDecode(e_ptr[0..e_len], &e_buf) orelse return -1;
    if (sig.len != n.len) return 0; // a signature is always modulus-sized
    const pk = rsa.PublicKey.fromBytes(e, n) catch return -1;
    const msg = msg_ptr[0..msg_len];
    switch (n.len) {
        inline 128, 256, 384, 512 => |mlen| {
            rsa.PKCS1v1_5Signature.verify(mlen, sig[0..mlen].*, msg, pk, Sha256) catch return 0;
            return 1;
        },
        else => return -1,
    }
}

/// ES256 KEY GENERATION + SIGNING -- for an IDENTITY PROVIDER, not a client.
/// A relying party only ever verifies (above); these exist so Softanza can BE a
/// provider: the service-virtualization OIDC sandbox mints genuinely-signed
/// id-tokens offline, and a future OIDC-provider surface issues real ones.
/// Deterministic from a 32-byte seed (hex) so a test is reproducible; an empty
/// seed draws from the CSPRNG. Writes "d|x|y", each base64url.
pub fn crypto_es256_keypair(seed_ptr: [*]const u8, seed_len: usize, out: [*]u8) callconv(.c) i32 {
    var seed: [32]u8 = undefined;
    if (seed_len == 0) {
        std.crypto.random.bytes(&seed);
    } else {
        if (seed_len != 64) return -1; // 32 bytes, hex
        var i: usize = 0;
        while (i < 32) : (i += 1) {
            const hi = hexNibble(seed_ptr[i * 2]) orelse return -1;
            const lo = hexNibble(seed_ptr[i * 2 + 1]) orelse return -1;
            seed[i] = (@as(u8, hi) << 4) | lo;
        }
    }
    const kp = Ecdsa256.KeyPair.generateDeterministic(seed) catch return -1;
    const d = kp.secret_key.toBytes();
    const sec1 = kp.public_key.toUncompressedSec1();
    const enc = std.base64.url_safe_no_pad.Encoder;
    var db: [64]u8 = undefined;
    var xb: [64]u8 = undefined;
    var yb: [64]u8 = undefined;
    const d64 = enc.encode(&db, &d);
    const x64 = enc.encode(&xb, sec1[1..33]);
    const y64 = enc.encode(&yb, sec1[33..65]);
    var n: usize = 0;
    @memcpy(out[n .. n + d64.len], d64);
    n += d64.len;
    out[n] = '|';
    n += 1;
    @memcpy(out[n .. n + x64.len], x64);
    n += x64.len;
    out[n] = '|';
    n += 1;
    @memcpy(out[n .. n + y64.len], y64);
    n += y64.len;
    return @intCast(n);
}

/// Sign a JWS signing input with an ES256 private key (base64url 'd').
/// Writes the 64-byte r||s signature, base64url. Returns chars written, or -1.
pub fn crypto_sign_es256(
    msg_ptr: [*]const u8,
    msg_len: usize,
    d_ptr: [*]const u8,
    d_len: usize,
    out: [*]u8,
) callconv(.c) i32 {
    var d_buf: [64]u8 = undefined;
    const d = b64UrlDecode(d_ptr[0..d_len], &d_buf) orelse return -1;
    if (d.len != 32) return -1;
    const sk = Ecdsa256.SecretKey.fromBytes(d[0..32].*) catch return -1;
    const kp = Ecdsa256.KeyPair.fromSecretKey(sk) catch return -1;
    const sig = kp.sign(msg_ptr[0..msg_len], null) catch return -1;
    const sig_bytes = sig.toBytes();
    const enc = std.base64.url_safe_no_pad.Encoder;
    var sb: [128]u8 = undefined;
    const s64 = enc.encode(&sb, &sig_bytes);
    @memcpy(out[0..s64.len], s64);
    return @intCast(s64.len);
}

/// base64url -> the decoded bytes (for reading a JWT's header/payload JSON).
/// Returns bytes written, or -1.
pub fn crypto_b64url_decode(
    src_ptr: [*]const u8,
    src_len: usize,
    out: [*]u8,
    out_cap: usize,
) callconv(.c) i32 {
    if (src_len == 0) return 0;
    const decoded = b64UrlDecode(src_ptr[0..src_len], out[0..out_cap]) orelse return -1;
    return @intCast(decoded.len);
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
pub export fn stz_crypto_hmac_sha256(k: [*]const u8, kl: usize, m: [*]const u8, ml: usize, o: [*]u8) callconv(.c) i32 { return crypto_hmac_sha256(k, kl, m, ml, o); }
pub export fn stz_crypto_crc32(p: [*]const u8, l: usize) callconv(.c) u32 { return crypto_crc32(p, l); }
pub export fn stz_crypto_fnv32(p: [*]const u8, l: usize) callconv(.c) u32 { return crypto_fnv32(p, l); }
pub export fn stz_crypto_fnv64(p: [*]const u8, l: usize) callconv(.c) u64 { return crypto_fnv64(p, l); }
pub export fn stz_crypto_equal(a: [*]const u8, b: [*]const u8, l: usize) callconv(.c) i32 { return crypto_equal(a, b, l); }
pub export fn stz_crypto_pbkdf2_sha256(pw: [*]const u8, pl: usize, s: [*]const u8, sl: usize, r: u32, dl: usize, o: [*]u8) callconv(.c) i32 { return crypto_pbkdf2_sha256(pw, pl, s, sl, r, dl, o); }
pub export fn stz_crypto_random_hex(n: usize, o: [*]u8) callconv(.c) i32 { return crypto_random_hex(n, o); }
pub export fn stz_crypto_totp(k: [*]const u8, kl: usize, c: u64, d: u32, a: u32, o: [*]u8) callconv(.c) i32 { return crypto_totp(k, kl, c, d, a, o); }
pub export fn stz_crypto_verify_es256(m: [*]const u8, ml: usize, s: [*]const u8, sl: usize, x: [*]const u8, xl: usize, y: [*]const u8, yl: usize) callconv(.c) i32 { return crypto_verify_es256(m, ml, s, sl, x, xl, y, yl); }
pub export fn stz_crypto_verify_rs256(m: [*]const u8, ml: usize, s: [*]const u8, sl: usize, n: [*]const u8, nl: usize, e: [*]const u8, el: usize) callconv(.c) i32 { return crypto_verify_rs256(m, ml, s, sl, n, nl, e, el); }
pub export fn stz_crypto_b64url_decode(s: [*]const u8, sl: usize, o: [*]u8, oc: usize) callconv(.c) i32 { return crypto_b64url_decode(s, sl, o, oc); }

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

// Vectors below were produced with OpenSSL 3.5 (a real signer, not a self-made
// fixture): sign the JWS signing input, then express key + signature the way a
// JWKS/JWS does (base64url).

test "crypto: verify ES256 against a real OpenSSL signature" {
    const msg = "eyJhbGciOiJFUzI1NiJ9.eyJzdWIiOiJkYW5hIiwiaXNzIjoic29mdGFuemEifQ";
    const sig = "iPuEkgC3Fj-U6UnrG_Iaapk203dCa6xr0L0e5CfkacUVBrN6lSHSZBO70qI-VmAIJkbEi4guG40bOm3_-sOOsg";
    const x = "Fuy532v_Q2jW82IZFXUZByCKHCHqExgJcRC75ZX7zus";
    const y = "inrBEmyylWkf8GUu-RV0OBAyEKQIuz8QkqKhoSdTluI";
    try std.testing.expectEqual(@as(i32, 1), crypto_verify_es256(msg.ptr, msg.len, sig.ptr, sig.len, x.ptr, x.len, y.ptr, y.len));

    // a tampered payload must NOT verify
    const bad = "eyJhbGciOiJFUzI1NiJ9.eyJzdWIiOiJldmlsIiwiaXNzIjoic29mdGFuemEifQ";
    try std.testing.expectEqual(@as(i32, 0), crypto_verify_es256(bad.ptr, bad.len, sig.ptr, sig.len, x.ptr, x.len, y.ptr, y.len));

    // a signature that is the right shape but wrong must NOT verify
    const wrong = "AAuEkgC3Fj-U6UnrG_Iaapk203dCa6xr0L0e5CfkacUVBrN6lSHSZBO70qI-VmAIJkbEi4guG40bOm3_-sOOsg";
    try std.testing.expectEqual(@as(i32, 0), crypto_verify_es256(msg.ptr, msg.len, wrong.ptr, wrong.len, x.ptr, x.len, y.ptr, y.len));
}

test "crypto: verify RS256 against a real OpenSSL signature (2048-bit)" {
    const msg = "eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJkYW5hIiwiaXNzIjoic29mdGFuemEifQ";
    const n = "8s7R1YHtcMoRL3r6kV7gRHluosq_Z6I5Pf-zbBODgkCkSKDcML4JPGgimkEmI_rVc2S03KMD57X6Iicj09rDZzSxSRv1Mowuwh0z_m2Hr8VIUuERHyLYl8CNjuu02GNpfKURC0iGWj50iYVT9WU0LOG8CVuZJlxZMZ-VHE2BDKH1Oua6QbnMxe2eDSn-3G0ozXwdbK9xZ4EoNGpJ7x3_izBwevCjuwQ6o2j7Rrffwyw8jX-0UW17OodV91nL8gDopBGexwdrgdFveHJqkm58PG9C54PzlO3HZxjRvM3q9vXR52Q7Pmy4zNP7E-eLkkoxAhpZsY44fnGCaTLBNH-ONQ";
    const e = "AQAB";
    const sig = "Yx4wqGMqTP2Oi2ahEdw-avE2vcdPUMo53fhwG7BmJxQQTQ6-FUAmUFzXfD_h9k2_2StN2ARDdkJE3QoBZBxQO-f4AJVJ4GDpbfin1ASRize2GIHD7ml6szq71y8lcm5vSZuBlt46qkzsVfgIE7iO8wkMiswcFOZFSYIQfHmJhEpnK_zPGpp95zCKFJayHAMu6bM1UuUntcYoIqsSr4YpwBR0nno6gvyGU7DzKVqZvq37miZZHLtIRolW7rNj7jVcKt_MLgEDasmrNjgGW39XmPsmeqUO8M1MVUYTgsWW_-wHXaCgxztFhqxyonEuRUII6-laG3X3nde-u382w0jFww";
    try std.testing.expectEqual(@as(i32, 1), crypto_verify_rs256(msg.ptr, msg.len, sig.ptr, sig.len, n.ptr, n.len, e.ptr, e.len));

    const bad = "eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJldmlsIiwiaXNzIjoic29mdGFuemEifQ";
    try std.testing.expectEqual(@as(i32, 0), crypto_verify_rs256(bad.ptr, bad.len, sig.ptr, sig.len, n.ptr, n.len, e.ptr, e.len));
}

test "crypto: ES256 round-trip (engine-generated key, engine verify)" {
    const kp = Ecdsa256.KeyPair.generate();
    const msg = "header.payload";
    const sig = try kp.sign(msg, null);
    const sig_bytes = sig.toBytes();
    const sec1 = kp.public_key.toUncompressedSec1();
    const enc = std.base64.url_safe_no_pad.Encoder;
    var sb: [128]u8 = undefined;
    var xb: [64]u8 = undefined;
    var yb: [64]u8 = undefined;
    const s64 = enc.encode(&sb, &sig_bytes);
    const x64 = enc.encode(&xb, sec1[1..33]);
    const y64 = enc.encode(&yb, sec1[33..65]);
    try std.testing.expectEqual(@as(i32, 1), crypto_verify_es256(msg.ptr, msg.len, s64.ptr, s64.len, x64.ptr, x64.len, y64.ptr, y64.len));
}

test "crypto: verification rejects malformed input" {
    const msg = "a.b";
    const good_x = "Fuy532v_Q2jW82IZFXUZByCKHCHqExgJcRC75ZX7zus";
    // not base64url at all
    try std.testing.expectEqual(@as(i32, -1), crypto_verify_es256(msg.ptr, msg.len, "!!!".ptr, 3, good_x.ptr, good_x.len, good_x.ptr, good_x.len));
    // right encoding, wrong coordinate size
    try std.testing.expectEqual(@as(i32, -1), crypto_verify_es256(msg.ptr, msg.len, "AAAA".ptr, 4, "AAAA".ptr, 4, "AAAA".ptr, 4));
}

test "crypto: base64url decode reads a JWT payload" {
    const src = "eyJzdWIiOiJkYW5hIn0";
    var out: [64]u8 = undefined;
    const n = crypto_b64url_decode(src.ptr, src.len, &out, out.len);
    try std.testing.expectEqual(@as(i32, 14), n);
    try std.testing.expectEqualStrings("{\"sub\":\"dana\"}", out[0..14]);
}

test "crypto: totp rejects bad input" {
    var out: [9]u8 = undefined;
    try std.testing.expectEqual(@as(i32, -1), crypto_totp("abc".ptr, 3, 1, 6, 1, &out)); // odd hex
    try std.testing.expectEqual(@as(i32, -1), crypto_totp("3132".ptr, 4, 1, 0, 1, &out)); // 0 digits
    try std.testing.expectEqual(@as(i32, -1), crypto_totp("zz".ptr, 2, 1, 6, 1, &out)); // non-hex
}

test "crypto: ES256 keypair + sign + verify (the sandbox IdP path)" {
    const seed = "00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff";
    var kp_out: [256]u8 = undefined;
    const kn = crypto_es256_keypair(seed.ptr, seed.len, &kp_out);
    try std.testing.expect(kn > 0);
    const triple = kp_out[0..@intCast(kn)];
    var it = std.mem.splitScalar(u8, triple, '|');
    const d = it.next().?;
    const x = it.next().?;
    const y = it.next().?;

    // deterministic: the same seed yields the same key
    var kp2: [256]u8 = undefined;
    const kn2 = crypto_es256_keypair(seed.ptr, seed.len, &kp2);
    try std.testing.expectEqualStrings(triple, kp2[0..@intCast(kn2)]);

    const msg = "eyJhbGciOiJFUzI1NiJ9.eyJzdWIiOiJkYW5hIn0";
    var sig_out: [128]u8 = undefined;
    const sn = crypto_sign_es256(msg.ptr, msg.len, d.ptr, d.len, &sig_out);
    try std.testing.expect(sn > 0);
    const sig = sig_out[0..@intCast(sn)];

    try std.testing.expectEqual(@as(i32, 1), crypto_verify_es256(msg.ptr, msg.len, sig.ptr, sig.len, x.ptr, x.len, y.ptr, y.len));

    const tampered = "eyJhbGciOiJFUzI1NiJ9.eyJzdWIiOiJldmlsIn0";
    try std.testing.expectEqual(@as(i32, 0), crypto_verify_es256(tampered.ptr, tampered.len, sig.ptr, sig.len, x.ptr, x.len, y.ptr, y.len));
}
