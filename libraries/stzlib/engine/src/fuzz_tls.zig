// Fuzz harness for TLS input parsing -- the mbedTLS surfaces that process
// bytes from an untrusted peer: X.509 certificate parsing (a malicious peer
// cert) and private-key parsing (config robustness). Exercises BOTH mbedTLS's
// own hardening AND our calling convention (buffer sizes, the PEM NUL-
// terminator contract that bit us in slice 1). Built ReleaseSafe: any OOB at
// the Zig boundary panics; the goal is "no input crashes the parser".

const std = @import("std");
const c = @cImport({
    @cInclude("mbedtls/x509_crt.h");
    @cInclude("mbedtls/pk.h");
    @cInclude("mbedtls/ctr_drbg.h");
    @cInclude("mbedtls/entropy.h");
});

var drbg: c.mbedtls_ctr_drbg_context = undefined;

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
    std.debug.print("PASS: {d} corpus + {d} fuzzed cert/key inputs, no crash.\n", .{ corpus.len, rounds });
    std.process.exit(0);
}
