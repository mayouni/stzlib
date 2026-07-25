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
