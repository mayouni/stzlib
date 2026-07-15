// Fuzz harness for TLS input parsing -- the mbedTLS surfaces that process
// bytes from an untrusted peer: X.509 certificate parsing (a malicious peer
// cert) and private-key parsing (config robustness). Exercises BOTH mbedTLS's
// own hardening AND our calling convention (buffer sizes, the PEM NUL-
// terminator contract that bit us in slice 1). Built ReleaseSafe: any OOB at
// the Zig boundary panics; the goal is "no input crashes the parser".

const std = @import("std");
const c = @cImport({
    @cInclude("mbedtls/ssl.h");
    @cInclude("mbedtls/x509_crt.h");
    @cInclude("mbedtls/pk.h");
    @cInclude("mbedtls/ctr_drbg.h");
    @cInclude("mbedtls/entropy.h");
});

const srv_crt_pem = @embedFile("mtls_certs/node.crt.pem");
const srv_key_pem = @embedFile("mtls_certs/node.key.pem");

var drbg: c.mbedtls_ctr_drbg_context = undefined;

// --- record-layer BIO: the server reads garbage "ciphertext" from rec_in ---
var rec_in: []const u8 = &.{};
var rec_pos: usize = 0;

fn recBioSend(ctx: ?*anyopaque, buf: [*c]const u8, len: usize) callconv(.c) c_int {
    _ = ctx;
    _ = buf;
    return @intCast(len); // discard the server's output
}
fn recBioRecv(ctx: ?*anyopaque, buf: [*c]u8, len: usize) callconv(.c) c_int {
    _ = ctx;
    const avail = rec_in.len - rec_pos;
    if (avail == 0) return c.MBEDTLS_ERR_SSL_WANT_READ;
    const n = @min(len, avail);
    @memcpy(buf[0..n], rec_in[rec_pos .. rec_pos + n]);
    rec_pos += n;
    return @intCast(n);
}

// Feed `input` to a server handshake as if a hostile client sent it. The
// server must reject it without crashing / UB (caught by UBSan-trap).
fn fuzzRecord(ssl: *c.mbedtls_ssl_context, input: []const u8) void {
    _ = c.mbedtls_ssl_session_reset(ssl);
    rec_in = input;
    rec_pos = 0;
    var guard: usize = 0;
    while (guard < 64) : (guard += 1) {
        const rc = c.mbedtls_ssl_handshake(ssl);
        if (rc == c.MBEDTLS_ERR_SSL_WANT_READ or rc == c.MBEDTLS_ERR_SSL_WANT_WRITE) break;
        break; // 0 (impossible w/ garbage) or an error -> both fine, just no crash
    }
}

// Parse `buf` (NUL-terminated, len includes the terminator) as a cert chain.
fn fuzzCert(buf: []const u8) void {
    var crt: c.mbedtls_x509_crt = undefined;
    c.mbedtls_x509_crt_init(&crt);
    defer c.mbedtls_x509_crt_free(&crt);
    _ = c.mbedtls_x509_crt_parse(&crt, buf.ptr, buf.len);
}

// Parse `buf` as a private key.
fn fuzzKey(buf: []const u8) void {
    var pk: c.mbedtls_pk_context = undefined;
    c.mbedtls_pk_init(&pk);
    defer c.mbedtls_pk_free(&pk);
    _ = c.mbedtls_pk_parse_key(&pk, buf.ptr, buf.len, null, 0, c.mbedtls_ctr_drbg_random, &drbg);
}

pub fn main() void {
    var entropy: c.mbedtls_entropy_context = undefined;
    c.mbedtls_entropy_init(&entropy);
    c.mbedtls_ctr_drbg_init(&drbg);
    const pers = "softanza-fuzz-tls";
    _ = c.mbedtls_ctr_drbg_seed(&drbg, c.mbedtls_entropy_func, &entropy, pers, pers.len);

    // a few crafted inputs first (the NUL-terminator + PEM edge cases)
    const corpus = [_][]const u8{
        "\x00",
        "-----BEGIN CERTIFICATE-----\n\x00",
        "-----BEGIN CERTIFICATE-----\n-----END CERTIFICATE-----\n\x00",
        "-----BEGIN CERTIFICATE-----\nZm9vYmFy\n-----END CERTIFICATE-----\n\x00",
        "-----BEGIN EC PRIVATE KEY-----\n!!!!\n-----END EC PRIVATE KEY-----\n\x00",
        "\x30\x82\xFF\xFF\x00", // DER-ish length way past the buffer
    };
    for (corpus) |ct| {
        fuzzCert(ct);
        fuzzKey(ct);
    }

    var prng = std.Random.DefaultPrng.init(0xF0F0_ABCD);
    const rand = prng.random();
    const pem_hdr = "-----BEGIN CERTIFICATE-----\n";
    const b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    var buf: [4096]u8 = undefined;
    var iter: usize = 0;
    const rounds: usize = 150_000;
    while (iter < rounds) : (iter += 1) {
        var len: usize = 0;
        if (rand.boolean()) {
            // PEM-ish: a real header + base64-ish garbage (exercises the PEM +
            // base64 decoders, the richest parsing path)
            @memcpy(buf[0..pem_hdr.len], pem_hdr);
            len = pem_hdr.len;
            const n = rand.uintLessThan(usize, 1500);
            var k: usize = 0;
            while (k < n and len < buf.len - 1) : (k += 1) {
                buf[len] = if (rand.uintLessThan(u8, 8) == 0) '\n' else b64[rand.uintLessThan(usize, b64.len)];
                len += 1;
            }
        } else {
            // raw random bytes (DER path + anything)
            len = rand.uintLessThan(usize, buf.len - 1);
            for (buf[0..len]) |*b| b.* = rand.int(u8);
        }
        buf[len] = 0; // NUL terminator (PEM detection needs it)
        fuzzCert(buf[0 .. len + 1]);
        if (iter % 3 == 0) fuzzKey(buf[0 .. len + 1]);
    }
    std.debug.print("cert/key: {d} corpus + {d} inputs, no crash.\n", .{ corpus.len, rounds });

    // --- phase 2: record-layer handshake fuzz (hostile ClientHello bytes) ---
    var srvcert: c.mbedtls_x509_crt = undefined;
    var pkey: c.mbedtls_pk_context = undefined;
    var conf: c.mbedtls_ssl_config = undefined;
    var ssl: c.mbedtls_ssl_context = undefined;
    c.mbedtls_x509_crt_init(&srvcert);
    c.mbedtls_pk_init(&pkey);
    c.mbedtls_ssl_config_init(&conf);
    c.mbedtls_ssl_init(&ssl);
    var cb: [4096]u8 = undefined;
    @memcpy(cb[0..srv_crt_pem.len], srv_crt_pem);
    cb[srv_crt_pem.len] = 0;
    _ = c.mbedtls_x509_crt_parse(&srvcert, &cb, srv_crt_pem.len + 1);
    var kb: [4096]u8 = undefined;
    @memcpy(kb[0..srv_key_pem.len], srv_key_pem);
    kb[srv_key_pem.len] = 0;
    _ = c.mbedtls_pk_parse_key(&pkey, &kb, srv_key_pem.len + 1, null, 0, c.mbedtls_ctr_drbg_random, &drbg);
    _ = c.mbedtls_ssl_config_defaults(&conf, c.MBEDTLS_SSL_IS_SERVER, c.MBEDTLS_SSL_TRANSPORT_STREAM, c.MBEDTLS_SSL_PRESET_DEFAULT);
    c.mbedtls_ssl_conf_rng(&conf, c.mbedtls_ctr_drbg_random, &drbg);
    _ = c.mbedtls_ssl_conf_own_cert(&conf, &srvcert, &pkey);
    _ = c.mbedtls_ssl_setup(&ssl, &conf);
    c.mbedtls_ssl_set_bio(&ssl, null, recBioSend, recBioRecv, null);

    var rbuf: [2048]u8 = undefined;
    var riter: usize = 0;
    const rec_rounds: usize = 60_000;
    while (riter < rec_rounds) : (riter += 1) {
        const len = rand.uintLessThan(usize, rbuf.len);
        for (rbuf[0..len]) |*b| {
            // bias the first bytes toward a real TLS record header (0x16 =
            // handshake, 0x03 0x03 = TLS 1.2) so the parser goes deep
            b.* = switch (rand.uintLessThan(u8, 6)) {
                0 => 0x16,
                1 => 0x03,
                else => rand.int(u8),
            };
        }
        fuzzRecord(&ssl, rbuf[0..len]);
    }
    c.mbedtls_ssl_free(&ssl);
    c.mbedtls_ssl_config_free(&conf);
    c.mbedtls_x509_crt_free(&srvcert);
    c.mbedtls_pk_free(&pkey);

    std.debug.print("PASS: cert/key + {d} record-layer handshake inputs, no crash / UB.\n", .{rec_rounds});
    std.process.exit(0);
}
