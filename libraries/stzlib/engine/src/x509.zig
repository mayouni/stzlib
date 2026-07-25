const std = @import("std");

// ── X.509 certificates -> a usable public key ─────────────────
//
// Real identity federation hands you CERTIFICATES, not raw key material. A SAML
// IdP's metadata carries <ds:X509Certificate> (base64 DER); a JWKS entry may
// carry x5c instead of n/e. Our verifiers want the key's components, so something
// has to open the certificate -- and that something should not be hand-rolled
// ASN.1: X.509 parsing is a notorious source of memory-safety bugs.
//
// So this leans on mbedTLS, which is ALREADY vendored and linked for TLS. No new
// dependency: the certificate path reuses the same battle-tested parser that
// terminates our TLS connections.
//
// Output is one delimited ASCII record -- "RSA|n|e" or "EC|x|y", every component
// base64url, exactly the form the engine's verifiers already take. Nothing binary
// crosses the boundary.
//
// NOTE ON TRUST: parsing a certificate says NOTHING about trusting it. This
// extracts a key; whether that key belongs to the issuer you mean is a decision
// the caller makes (by pinning the certificate, or by validating a chain). A
// certificate is self-describing, so an attacker can present a perfectly
// well-formed one for any name they like.

const c = @cImport({
    @cInclude("mbedtls/x509_crt.h");
    @cInclude("mbedtls/pk.h");
    @cInclude("mbedtls/rsa.h");
    @cInclude("mbedtls/ecp.h");
    @cInclude("mbedtls/bignum.h");
    @cInclude("mbedtls/ctr_drbg.h");
    @cInclude("mbedtls/entropy.h");
    @cInclude("mbedtls/md.h");
});

var g_der: [8192]u8 = undefined;

fn isSpace(ch: u8) bool {
    return ch == ' ' or ch == '\t' or ch == '\r' or ch == '\n';
}

/// Accept either PEM ("-----BEGIN CERTIFICATE-----...") or the bare base64 DER
/// that SAML metadata and JWKS x5c actually carry. Returns the DER bytes.
fn toDer(src: []const u8) ?[]u8 {
    var body = src;
    if (std.mem.indexOf(u8, src, "-----BEGIN")) |b| {
        const after = std.mem.indexOfScalarPos(u8, src, b, '\n') orelse return null;
        const end = std.mem.indexOfPos(u8, src, after, "-----END") orelse return null;
        body = src[after..end];
    }
    // strip every whitespace character (PEM wraps at 64 columns; XML indents)
    var clean: [16384]u8 = undefined;
    var n: usize = 0;
    for (body) |ch| {
        if (isSpace(ch)) continue;
        if (n >= clean.len) return null;
        clean[n] = ch;
        n += 1;
    }
    if (n == 0) return null;
    const dec = std.base64.standard.Decoder;
    const len = dec.calcSizeForSlice(clean[0..n]) catch return null;
    if (len > g_der.len) return null;
    dec.decode(g_der[0..len], clean[0..n]) catch return null;
    return g_der[0..len];
}

fn b64u(src: []const u8, dest: []u8) []const u8 {
    return std.base64.url_safe_no_pad.Encoder.encode(dest, src);
}

/// Certificate -> "RSA|n|e" or "EC|x|y" (base64url). Returns chars written,
/// or -1 when the certificate cannot be parsed / the key type is unsupported.
pub fn x509_public_key(
    cert_ptr: [*]const u8,
    cert_len: usize,
    out: [*]u8,
    out_cap: usize,
) callconv(.c) i32 {
    const der = toDer(cert_ptr[0..cert_len]) orelse return -1;

    var crt: c.mbedtls_x509_crt = undefined;
    c.mbedtls_x509_crt_init(&crt);
    defer c.mbedtls_x509_crt_free(&crt);
    if (c.mbedtls_x509_crt_parse_der(&crt, der.ptr, der.len) != 0) return -1;

    const kind = c.mbedtls_pk_get_type(&crt.pk);

    if (kind == c.MBEDTLS_PK_RSA) {
        const rsa = c.mbedtls_pk_rsa(crt.pk);
        var N: c.mbedtls_mpi = undefined;
        var E: c.mbedtls_mpi = undefined;
        c.mbedtls_mpi_init(&N);
        c.mbedtls_mpi_init(&E);
        defer c.mbedtls_mpi_free(&N);
        defer c.mbedtls_mpi_free(&E);
        if (c.mbedtls_rsa_export(rsa, &N, null, null, null, &E) != 0) return -1;

        var nb: [1024]u8 = undefined;
        var eb: [64]u8 = undefined;
        const nlen = c.mbedtls_mpi_size(&N);
        const elen = c.mbedtls_mpi_size(&E);
        if (nlen == 0 or nlen > nb.len or elen == 0 or elen > eb.len) return -1;
        if (c.mbedtls_mpi_write_binary(&N, &nb, nlen) != 0) return -1;
        if (c.mbedtls_mpi_write_binary(&E, &eb, elen) != 0) return -1;

        var n64: [1400]u8 = undefined;
        var e64: [96]u8 = undefined;
        return writeRecord(out, out_cap, "RSA", b64u(nb[0..nlen], &n64), b64u(eb[0..elen], &e64));
    }

    if (kind == c.MBEDTLS_PK_ECKEY or kind == c.MBEDTLS_PK_ECDSA) {
        // write the point in uncompressed SEC1 form (0x04 || X || Y) -- a PUBLIC
        // mbedTLS call, so no reaching into private struct fields
        const ec = c.mbedtls_pk_ec(crt.pk);
        var grp: c.mbedtls_ecp_group = undefined;
        var Q: c.mbedtls_ecp_point = undefined;
        c.mbedtls_ecp_group_init(&grp);
        c.mbedtls_ecp_point_init(&Q);
        defer c.mbedtls_ecp_group_free(&grp);
        defer c.mbedtls_ecp_point_free(&Q);
        if (c.mbedtls_ecp_export(ec, &grp, null, &Q) != 0) return -1;

        var pt: [256]u8 = undefined;
        var olen: usize = 0;
        if (c.mbedtls_ecp_point_write_binary(&grp, &Q, c.MBEDTLS_ECP_PF_UNCOMPRESSED, &olen, &pt, pt.len) != 0) return -1;
        // our ES256 verifier is P-256 only: 0x04 + 32 + 32
        if (olen != 65 or pt[0] != 0x04) return -1;

        var x64: [64]u8 = undefined;
        var y64: [64]u8 = undefined;
        return writeRecord(out, out_cap, "EC", b64u(pt[1..33], &x64), b64u(pt[33..65], &y64));
    }

    return -1;
}

fn writeRecord(out: [*]u8, out_cap: usize, kty: []const u8, k1: []const u8, k2: []const u8) i32 {
    var w: usize = 0;
    for ([_][]const u8{ kty, "|", k1, "|", k2 }) |part| {
        if (w + part.len > out_cap) return -1;
        @memcpy(out[w .. w + part.len], part);
        w += part.len;
    }
    return @intCast(w);
}

/// The certificate's SHA-256 fingerprint, hex -- what you PIN when you cannot
/// validate a chain, and what IdP documentation publishes for out-of-band checks.
pub fn x509_fingerprint(cert_ptr: [*]const u8, cert_len: usize, out: [*]u8) callconv(.c) i32 {
    const der = toDer(cert_ptr[0..cert_len]) orelse return -1;
    var h: [32]u8 = undefined;
    std.crypto.hash.sha2.Sha256.hash(der, &h, .{});
    const hex = "0123456789abcdef";
    var i: usize = 0;
    while (i < 32) : (i += 1) {
        out[i * 2] = hex[h[i] >> 4];
        out[i * 2 + 1] = hex[h[i] & 0x0f];
    }
    return 64;
}

/// The certificate's subject and validity, so an operator can SEE what they are
/// about to trust: "subject|notBefore|notAfter". Times are ISO-ish UTC.
pub fn x509_describe(cert_ptr: [*]const u8, cert_len: usize, out: [*]u8, out_cap: usize) callconv(.c) i32 {
    const der = toDer(cert_ptr[0..cert_len]) orelse return -1;
    var crt: c.mbedtls_x509_crt = undefined;
    c.mbedtls_x509_crt_init(&crt);
    defer c.mbedtls_x509_crt_free(&crt);
    if (c.mbedtls_x509_crt_parse_der(&crt, der.ptr, der.len) != 0) return -1;

    var subj: [512]u8 = undefined;
    const sn = c.mbedtls_x509_dn_gets(&subj, subj.len, &crt.subject);
    if (sn < 0) return -1;

    const vf = crt.valid_from;
    const vt = crt.valid_to;
    var buf: [256]u8 = undefined;
    // cast to UNSIGNED before formatting: mbedTLS holds these as signed ints, and
    // a signed value carries a sign through the width/fill spec ("+7" instead of "07")
    const s = std.fmt.bufPrint(&buf, "|{d:0>4}-{d:0>2}-{d:0>2}T{d:0>2}:{d:0>2}:{d:0>2}Z|{d:0>4}-{d:0>2}-{d:0>2}T{d:0>2}:{d:0>2}:{d:0>2}Z", .{
        u(vf.year), u(vf.mon), u(vf.day), u(vf.hour), u(vf.min), u(vf.sec),
        u(vt.year), u(vt.mon), u(vt.day), u(vt.hour), u(vt.min), u(vt.sec),
    }) catch return -1;

    var w: usize = 0;
    const su: usize = @intCast(sn);
    if (w + su > out_cap) return -1;
    @memcpy(out[w .. w + su], subj[0..su]);
    w += su;
    if (w + s.len > out_cap) return -1;
    @memcpy(out[w .. w + s.len], s);
    w += s.len;
    return @intCast(w);
}

fn u(v: c_int) u32 {
    if (v < 0) return 0;
    return @intCast(v);
}

pub export fn stz_x509_public_key(p: [*]const u8, l: usize, o: [*]u8, oc: usize) callconv(.c) i32 {
    return x509_public_key(p, l, o, oc);
}
pub export fn stz_x509_fingerprint(p: [*]const u8, l: usize, o: [*]u8) callconv(.c) i32 {
    return x509_fingerprint(p, l, o);
}
pub export fn stz_x509_describe(p: [*]const u8, l: usize, o: [*]u8, oc: usize) callconv(.c) i32 {
    return x509_describe(p, l, o, oc);
}

// ── RSA: keys and RS256 signatures ───────────────────────────
//
// Our issuers (the OIDC provider, the SAML IdP) signed ES256 only, because Zig's
// standard library verifies RSA but cannot generate or sign with it. That made
// Softanza able to CONSUME identity from anyone while unable to ISSUE to
// everyone: plenty of enterprise SAML service providers and older OIDC clients
// accept RS256 and nothing else.
//
// mbedTLS closes it with no new dependency. And note the direction that matters
// most in practice: a real deployment does not want a freshly generated key, it
// already HAS a key and certificate from its PKI. So loading an existing PEM is
// the primary path; generation exists for development and for a first run.
//
// The private key crosses the boundary as PEM -- ASCII, so it travels safely --
// and never leaves in any other form.

var g_rng_ready: bool = false;
var g_entropy: c.mbedtls_entropy_context = undefined;
var g_drbg: c.mbedtls_ctr_drbg_context = undefined;

fn rng() ?*c.mbedtls_ctr_drbg_context {
    if (!g_rng_ready) {
        c.mbedtls_entropy_init(&g_entropy);
        c.mbedtls_ctr_drbg_init(&g_drbg);
        const pers = "softanza-rsa";
        if (c.mbedtls_ctr_drbg_seed(&g_drbg, c.mbedtls_entropy_func, &g_entropy, pers, pers.len) != 0) return null;
        g_rng_ready = true;
    }
    return &g_drbg;
}

/// mbedtls_pk_parse_key wants a NUL-terminated buffer for PEM.
var g_pem_in: [8192]u8 = undefined;

fn parsePrivateKey(pk: *c.mbedtls_pk_context, pem: []const u8) bool {
    if (pem.len + 1 > g_pem_in.len) return false;
    @memcpy(g_pem_in[0..pem.len], pem);
    g_pem_in[pem.len] = 0;
    const r = rng() orelse return false;
    return c.mbedtls_pk_parse_key(pk, &g_pem_in, pem.len + 1, null, 0, c.mbedtls_ctr_drbg_random, r) == 0;
}

/// Generate an RSA key -> "privateKeyPem|n|e" (n,e base64url). Bits 2048..4096.
/// For development and first runs; production loads its own PEM instead.
pub fn rsa_keypair(bits: u32, out: [*]u8, out_cap: usize) callconv(.c) i32 {
    if (bits < 2048 or bits > 4096) return -1;
    const r = rng() orelse return -1;
    var pk: c.mbedtls_pk_context = undefined;
    c.mbedtls_pk_init(&pk);
    defer c.mbedtls_pk_free(&pk);
    if (c.mbedtls_pk_setup(&pk, c.mbedtls_pk_info_from_type(c.MBEDTLS_PK_RSA)) != 0) return -1;
    if (c.mbedtls_rsa_gen_key(c.mbedtls_pk_rsa(pk), c.mbedtls_ctr_drbg_random, r, bits, 65537) != 0) return -1;

    var pem: [8192]u8 = undefined;
    if (c.mbedtls_pk_write_key_pem(&pk, &pem, pem.len) != 0) return -1;
    const plen = std.mem.indexOfScalar(u8, &pem, 0) orelse return -1;

    var w: usize = 0;
    if (plen + 1 > out_cap) return -1;
    @memcpy(out[0..plen], pem[0..plen]);
    w = plen;
    out[w] = '|';
    w += 1;
    const kn = writePublicParts(&pk, out + w, out_cap - w);
    if (kn < 0) return -1;
    return @intCast(w + @as(usize, @intCast(kn)));
}

/// A private-key PEM -> its PUBLIC parts "n|e" (base64url), so an issuer can
/// publish a JWKS from the same key it signs with.
pub fn rsa_public_from_key(pem_ptr: [*]const u8, pem_len: usize, out: [*]u8, out_cap: usize) callconv(.c) i32 {
    var pk: c.mbedtls_pk_context = undefined;
    c.mbedtls_pk_init(&pk);
    defer c.mbedtls_pk_free(&pk);
    if (!parsePrivateKey(&pk, pem_ptr[0..pem_len])) return -1;
    if (c.mbedtls_pk_get_type(&pk) != c.MBEDTLS_PK_RSA) return -1;
    return writePublicParts(&pk, out, out_cap);
}

fn writePublicParts(pk: *c.mbedtls_pk_context, out: [*]u8, out_cap: usize) i32 {
    const rsa = c.mbedtls_pk_rsa(pk.*);
    var N: c.mbedtls_mpi = undefined;
    var E: c.mbedtls_mpi = undefined;
    c.mbedtls_mpi_init(&N);
    c.mbedtls_mpi_init(&E);
    defer c.mbedtls_mpi_free(&N);
    defer c.mbedtls_mpi_free(&E);
    if (c.mbedtls_rsa_export(rsa, &N, null, null, null, &E) != 0) return -1;
    var nb: [1024]u8 = undefined;
    var eb: [64]u8 = undefined;
    const nlen = c.mbedtls_mpi_size(&N);
    const elen = c.mbedtls_mpi_size(&E);
    if (nlen == 0 or nlen > nb.len or elen == 0 or elen > eb.len) return -1;
    if (c.mbedtls_mpi_write_binary(&N, &nb, nlen) != 0) return -1;
    if (c.mbedtls_mpi_write_binary(&E, &eb, elen) != 0) return -1;
    var n64: [1400]u8 = undefined;
    var e64: [96]u8 = undefined;
    const ns = b64u(nb[0..nlen], &n64);
    const es = b64u(eb[0..elen], &e64);
    var w: usize = 0;
    for ([_][]const u8{ ns, "|", es }) |part| {
        if (w + part.len > out_cap) return -1;
        @memcpy(out[w .. w + part.len], part);
        w += part.len;
    }
    return @intCast(w);
}

/// RS256: sign SHA-256(msg) with RSASSA-PKCS1-v1_5 under a PEM private key.
/// Returns the signature base64url (the form JWS wants), or -1.
pub fn rsa_sign(
    msg_ptr: [*]const u8,
    msg_len: usize,
    pem_ptr: [*]const u8,
    pem_len: usize,
    out: [*]u8,
    out_cap: usize,
) callconv(.c) i32 {
    const r = rng() orelse return -1;
    var pk: c.mbedtls_pk_context = undefined;
    c.mbedtls_pk_init(&pk);
    defer c.mbedtls_pk_free(&pk);
    if (!parsePrivateKey(&pk, pem_ptr[0..pem_len])) return -1;
    if (c.mbedtls_pk_get_type(&pk) != c.MBEDTLS_PK_RSA) return -1;

    var hash: [32]u8 = undefined;
    std.crypto.hash.sha2.Sha256.hash(msg_ptr[0..msg_len], &hash, .{});

    var sig: [1024]u8 = undefined;
    var olen: usize = 0;
    if (c.mbedtls_pk_sign(&pk, c.MBEDTLS_MD_SHA256, &hash, hash.len, &sig, sig.len, &olen, c.mbedtls_ctr_drbg_random, r) != 0) return -1;

    var sb: [1400]u8 = undefined;
    const s = b64u(sig[0..olen], &sb);
    if (s.len > out_cap) return -1;
    @memcpy(out[0..s.len], s);
    return @intCast(s.len);
}

pub export fn stz_rsa_keypair(bits: u32, o: [*]u8, oc: usize) callconv(.c) i32 {
    return rsa_keypair(bits, o, oc);
}
pub export fn stz_rsa_public_from_key(p: [*]const u8, l: usize, o: [*]u8, oc: usize) callconv(.c) i32 {
    return rsa_public_from_key(p, l, o, oc);
}
pub export fn stz_rsa_sign(m: [*]const u8, ml: usize, p: [*]const u8, pl: usize, o: [*]u8, oc: usize) callconv(.c) i32 {
    return rsa_sign(m, ml, p, pl, o, oc);
}

// ── tests ────────────────────────────────────────────────────

const crypto_mod = @import("crypto.zig");

test "rsa: generate, sign, and verify with our OWN RS256 verifier" {
    var kp: [16384]u8 = undefined;
    const kn = rsa_keypair(2048, &kp, kp.len);
    try std.testing.expect(kn > 0);
    const rec = kp[0..@intCast(kn)];
    // "pem|n|e" -- the PEM itself contains no '|', so split from the right
    const e_at = std.mem.lastIndexOfScalar(u8, rec, '|').?;
    const n_at = std.mem.lastIndexOfScalar(u8, rec[0..e_at], '|').?;
    const pem = rec[0..n_at];
    const n = rec[n_at + 1 .. e_at];
    const e = rec[e_at + 1 ..];
    try std.testing.expect(std.mem.startsWith(u8, pem, "-----BEGIN"));

    const msg = "eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJkYW5hIn0";
    var sig: [2048]u8 = undefined;
    const sn = rsa_sign(msg.ptr, msg.len, pem.ptr, pem.len, &sig, sig.len);
    try std.testing.expect(sn > 0);
    const s = sig[0..@intCast(sn)];

    // the loop closes: mbedTLS signed it, Zig std verifies it
    try std.testing.expectEqual(@as(i32, 1), crypto_mod.crypto_verify_rs256(msg.ptr, msg.len, s.ptr, s.len, n.ptr, n.len, e.ptr, e.len));

    // a tampered message must not verify
    const bad = "eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJldmlsIn0";
    try std.testing.expectEqual(@as(i32, 0), crypto_mod.crypto_verify_rs256(bad.ptr, bad.len, s.ptr, s.len, n.ptr, n.len, e.ptr, e.len));
}

test "rsa: public parts recovered from the private PEM match" {
    var kp: [16384]u8 = undefined;
    const kn = rsa_keypair(2048, &kp, kp.len);
    const rec = kp[0..@intCast(kn)];
    const e_at = std.mem.lastIndexOfScalar(u8, rec, '|').?;
    const n_at = std.mem.lastIndexOfScalar(u8, rec[0..e_at], '|').?;
    const pem = rec[0..n_at];
    const expect = rec[n_at + 1 ..];

    var pub_out: [2048]u8 = undefined;
    const pn = rsa_public_from_key(pem.ptr, pem.len, &pub_out, pub_out.len);
    try std.testing.expect(pn > 0);
    try std.testing.expectEqualStrings(expect, pub_out[0..@intCast(pn)]);
}

test "rsa: bad input is refused" {
    var out: [1024]u8 = undefined;
    try std.testing.expectEqual(@as(i32, -1), rsa_keypair(512, &out, out.len)); // too small
    try std.testing.expectEqual(@as(i32, -1), rsa_sign("x".ptr, 1, "not a pem".ptr, 9, &out, out.len));
    try std.testing.expectEqual(@as(i32, -1), rsa_public_from_key("nope".ptr, 4, &out, out.len));
}
