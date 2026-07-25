const std = @import("std");
const crypto = @import("crypto.zig");
const xmlmod = @import("xml.zig");

// ── XML Signature + SAML (on the shared XML parser) ──────────
//
// SAML's security does not rest on its cryptography -- it rests on answering
// "WHICH BYTES were signed, and is the element I am about to TRUST the same one
// the signature covers?" Nearly every serious SAML vulnerability is a wrong
// answer to that: signature WRAPPING (an attacker appends their own assertion;
// the signature still validates over the original, but the reader consumes the
// attacker's), canonicalization mismatches, XXE through entity expansion, and
// comment splicing inside a NameID.
//
// The parser and canonicalizer come from xml.zig, SHARED with stzXml. That is a
// security property, not just tidiness: signing and verifying must digest bytes
// produced by the same implementation, and the only way to be certain of that is
// for there to be one.
//
// The wrapping defense is structural, not a heuristic: verification returns the
// BYTE RANGE of the element the signature actually covers, so claims are read
// from THAT element and nothing else -- see saml_verify, which re-parses only
// the covered range.

// the shared parser, under local names so this module reads as before
const XmlError = xmlmod.XmlError;
const Attr = xmlmod.Attr;
const Node = xmlmod.Node;
const Doc = xmlmod.Doc;
const parse = xmlmod.parse;
const canonicalize = xmlmod.canonicalize;
const isSpace = xmlmod.isSpace;
const MAX_DEPTH = xmlmod.MAX_DEPTH;

const Sha256 = std.crypto.hash.sha2.Sha256;

// ── XML signature verification ───────────────────────────────

const DS = "http://www.w3.org/2000/09/xmldsig#";

pub const SigResult = struct {
    ok: bool,
    /// byte range of the element the signature actually covers
    signed_start: usize = 0,
    signed_end: usize = 0,
    why: []const u8 = "",
};

/// Verify an ENVELOPED signature found inside `doc`.
/// kty "EC" -> (k1,k2) = (x,y); "RSA" -> (n,e). Keys + result are base64url,
/// matching the rest of the engine's crypto surface.
pub fn verifySignature(
    doc: *const Doc,
    kty: []const u8,
    k1: []const u8,
    k2: []const u8,
    scratch: []u8,
) SigResult {
    // STRICTNESS: exactly one Signature, exactly one Reference. Multiple of
    // either is the shape signature-wrapping attacks take, so it is refused
    // rather than disambiguated.
    if (doc.countOf(DS, "Signature") != 1) return .{ .ok = false, .why = "expected exactly one Signature" };
    if (doc.countOf(DS, "Reference") != 1) return .{ .ok = false, .why = "expected exactly one Reference" };

    const sig = doc.find(DS, "Signature") orelse return .{ .ok = false, .why = "no Signature" };
    const si = doc.find(DS, "SignedInfo") orelse return .{ .ok = false, .why = "no SignedInfo" };
    const ref = doc.find(DS, "Reference") orelse return .{ .ok = false, .why = "no Reference" };
    const dv = doc.find(DS, "DigestValue") orelse return .{ .ok = false, .why = "no DigestValue" };
    const sv = doc.find(DS, "SignatureValue") orelse return .{ .ok = false, .why = "no SignatureValue" };

    // the URI must point at an element by id -- never an empty (whole-document)
    // reference, which is far easier to wrap around.
    const uri = doc.attrValue(ref, "", "URI") orelse return .{ .ok = false, .why = "Reference has no URI" };
    if (uri.len < 2 or uri[0] != '#') return .{ .ok = false, .why = "only same-document #id references are accepted" };
    const want_id = uri[1..];

    // find the referenced element by its ID attribute
    var target: ?*const Node = null;
    var i: usize = 0;
    while (i < doc.node_count) : (i += 1) {
        const n = &doc.nodes[i];
        if (doc.attrValue(n, "", "ID")) |v| {
            if (std.mem.eql(u8, v, want_id)) {
                if (target != null) return .{ .ok = false, .why = "duplicate ID in document" };
                target = n;
            }
        }
    }
    const tgt = target orelse return .{ .ok = false, .why = "the Reference points at no element" };

    // the Signature must be INSIDE the element it covers (enveloped), otherwise
    // it is signing something other than what we will read.
    if (!(sig.start > tgt.start and sig.end <= tgt.end)) {
        return .{ .ok = false, .why = "the signature is not enveloped in the element it references" };
    }

    const inclusive = inclusivePrefixes(doc);

    // ---- 1. the DIGEST, over the referenced element minus the Signature ----
    const half = scratch.len / 2;
    const c14n_len = canonicalize(doc, tgt, scratch[0..half], @intCast(doc.indexOf(sig)), inclusive) orelse
        return .{ .ok = false, .why = "could not canonicalise the referenced element" };
    var digest: [32]u8 = undefined;
    Sha256.hash(scratch[0..c14n_len], &digest, .{});
    var want_digest: [64]u8 = undefined;
    const wd = b64StdDecode(doc.textOf(dv), &want_digest) orelse
        return .{ .ok = false, .why = "DigestValue is not valid base64" };
    if (wd.len != 32 or !std.mem.eql(u8, wd, &digest)) {
        return .{ .ok = false, .why = "the digest does not match -- the signed content was altered" };
    }

    // ---- 2. the SIGNATURE, over the canonical SignedInfo ----
    const si_len = canonicalize(doc, si, scratch[half..], -1, inclusive) orelse
        return .{ .ok = false, .why = "could not canonicalise SignedInfo" };
    const signed_info = scratch[half .. half + si_len];

    var raw_sig: [512]u8 = undefined;
    const rs = b64StdDecode(doc.textOf(sv), &raw_sig) orelse
        return .{ .ok = false, .why = "SignatureValue is not valid base64" };

    var sig_b64u: [1024]u8 = undefined;
    const sb = std.base64.url_safe_no_pad.Encoder.encode(&sig_b64u, rs);

    var v: i32 = -1;
    if (std.mem.eql(u8, kty, "EC")) {
        v = crypto.crypto_verify_es256(signed_info.ptr, signed_info.len, sb.ptr, sb.len, k1.ptr, k1.len, k2.ptr, k2.len);
    } else if (std.mem.eql(u8, kty, "RSA")) {
        v = crypto.crypto_verify_rs256(signed_info.ptr, signed_info.len, sb.ptr, sb.len, k1.ptr, k1.len, k2.ptr, k2.len);
    } else {
        return .{ .ok = false, .why = "unsupported key type" };
    }
    if (v != 1) return .{ .ok = false, .why = "the signature does not verify against the key" };

    return .{ .ok = true, .signed_start = tgt.start, .signed_end = tgt.end, .why = "" };
}

fn inclusivePrefixes(doc: *const Doc) []const u8 {
    const EXC = "http://www.w3.org/2001/10/xml-exc-c14n#";
    if (doc.find(EXC, "InclusiveNamespaces")) |n| {
        if (doc.attrValue(n, "", "PrefixList")) |v| return v;
    }
    return "";
}

/// base64url -> bytes (the engine's crypto surface speaks base64url; XML speaks
/// standard base64, so signatures cross between the two here)
fn b64UrlDecode(src: []const u8, dest: []u8) ?[]u8 {
    var end = src.len;
    while (end > 0 and src[end - 1] == '=') end -= 1;
    const dec = std.base64.url_safe_no_pad.Decoder;
    const n = dec.calcSizeForSlice(src[0..end]) catch return null;
    if (n > dest.len) return null;
    dec.decode(dest[0..n], src[0..end]) catch return null;
    return dest[0..n];
}

/// standard base64 (XML-DSig uses it, not base64url), tolerating whitespace
fn b64StdDecode(src: []const u8, dest: []u8) ?[]u8 {
    var clean: [2048]u8 = undefined;
    var n: usize = 0;
    for (src) |c| {
        if (isSpace(c)) continue;
        if (n >= clean.len) return null;
        clean[n] = c;
        n += 1;
    }
    const dec = std.base64.standard.Decoder;
    const len = dec.calcSizeForSlice(clean[0..n]) catch return null;
    if (len > dest.len) return null;
    dec.decode(dest[0..len], clean[0..n]) catch return null;
    return dest[0..len];
}

// ── SAML: verify a response, and read claims ONLY from signed bytes ──
//
// The structural guarantee: after the signature is checked we RE-PARSE just the
// byte range it covered, and every claim is read from that second document. A
// forged assertion injected next to the genuine one is not merely ignored -- it
// is not in the bytes we parse, so it cannot be reached at all.
//
// Output is one delimited record (ASCII/UTF-8 -- never raw bytes across the
// boundary):  ok|why|issuer|nameID|audience|notBefore|notOnOrAfter|sessionIndex
// with ok = 1/0. Values are emitted with '|' stripped so the record cannot be
// forged by a crafted claim.

const SAMLNS = "urn:oasis:names:tc:SAML:2.0:assertion";

// A Doc is over a megabyte (fixed node/attr tables), so these live in STATIC
// storage, never on the stack: inside the Ring DLL the thread stack is far
// smaller than a test binary's, and two stack Docs overflowed it -- which shows
// up as a silent process death, not an error. Single-threaded per engine call.
var g_doc: Doc = undefined;
var g_sdoc: Doc = undefined;
var g_scratch: [65536]u8 = undefined;

/// our own literals (separators, reasons): written verbatim
fn putRaw(out: [*]u8, w: *usize, cap: usize, v: []const u8) void {
    for (v) |c| {
        if (w.* + 1 >= cap) return;
        out[w.*] = c;
        w.* += 1;
    }
}

/// UNTRUSTED values (claims): the separator is stripped so a crafted claim can
/// never forge an extra field
fn putField(out: [*]u8, w: *usize, cap: usize, v: []const u8) void {
    for (v) |c| {
        if (w.* + 1 >= cap) return;
        // a claim can never inject a field separator or a newline
        out[w.*] = if (c == '|' or c == '\n' or c == '\r') '_' else c;
        w.* += 1;
    }
}

fn childText(doc: *const Doc, uri: []const u8, local: []const u8) []const u8 {
    if (doc.find(uri, local)) |n| return doc.textOf(n);
    return "";
}

/// Verify a SAML Response/Assertion and extract its claims.
/// xml is the RAW document (already base64-decoded by the caller).
pub fn saml_verify(
    xml_ptr: [*]const u8,
    xml_len: usize,
    kty_ptr: [*]const u8,
    kty_len: usize,
    k1_ptr: [*]const u8,
    k1_len: usize,
    k2_ptr: [*]const u8,
    k2_len: usize,
    out: [*]u8,
    out_cap: usize,
) callconv(.c) i32 {
    const xml = xml_ptr[0..xml_len];
    var w: usize = 0;

    parse(&g_doc, xml) catch {
        putRaw(out, &w, out_cap, "0|the document is not well-formed XML (or declares a DOCTYPE/ENTITY, which is refused)");
        return @intCast(w);
    };

    const r = verifySignature(&g_doc, kty_ptr[0..kty_len], k1_ptr[0..k1_len], k2_ptr[0..k2_len], &g_scratch);
    if (!r.ok) {
        putRaw(out, &w, out_cap, "0|");
        putRaw(out, &w, out_cap, r.why);
        return @intCast(w);
    }

    // ---- re-parse ONLY what the signature covered ----
    const signed_bytes = xml[r.signed_start..r.signed_end];
    parse(&g_sdoc, signed_bytes) catch {
        putRaw(out, &w, out_cap, "0|the signed region does not parse on its own");
        return @intCast(w);
    };

    // the covered element must BE an Assertion, and there must be exactly one:
    // a signature over something else cannot vouch for a subject.
    const root = g_sdoc.root() orelse {
        putRaw(out, &w, out_cap, "0|the signed region is empty");
        return @intCast(w);
    };
    if (!std.mem.eql(u8, root.local, "Assertion")) {
        putRaw(out, &w, out_cap, "0|the signature does not cover an Assertion");
        return @intCast(w);
    }
    if (g_sdoc.countOf(SAMLNS, "Assertion") != 1) {
        putRaw(out, &w, out_cap, "0|the signed region holds more than one Assertion");
        return @intCast(w);
    }

    var cond_nb: []const u8 = "";
    var cond_na: []const u8 = "";
    if (g_sdoc.find(SAMLNS, "Conditions")) |c| {
        cond_nb = g_sdoc.attrValue(c, "", "NotBefore") orelse "";
        cond_na = g_sdoc.attrValue(c, "", "NotOnOrAfter") orelse "";
    }
    var session: []const u8 = "";
    if (g_sdoc.find(SAMLNS, "AuthnStatement")) |a| {
        session = g_sdoc.attrValue(a, "", "SessionIndex") orelse "";
    }

    putRaw(out, &w, out_cap, "1||");
    putField(out, &w, out_cap, childText(&g_sdoc, SAMLNS, "Issuer"));
    putRaw(out, &w, out_cap, "|");
    putField(out, &w, out_cap, childText(&g_sdoc, SAMLNS, "NameID"));
    putRaw(out, &w, out_cap, "|");
    putField(out, &w, out_cap, childText(&g_sdoc, SAMLNS, "Audience"));
    putRaw(out, &w, out_cap, "|");
    putField(out, &w, out_cap, cond_nb);
    putRaw(out, &w, out_cap, "|");
    putField(out, &w, out_cap, cond_na);
    putRaw(out, &w, out_cap, "|");
    putField(out, &w, out_cap, session);
    return @intCast(w);
}

pub export fn stz_saml_verify(x: [*]const u8, xl: usize, kt: [*]const u8, ktl: usize, k1: [*]const u8, k1l: usize, k2: [*]const u8, k2l: usize, o: [*]u8, oc: usize) callconv(.c) i32 {
    return saml_verify(x, xl, kt, ktl, k1, k1l, k2, k2l, o, oc);
}

// ── SAML: ISSUE a signed assertion (being the IdP) ───────────
//
// The mirror of verification, and it reuses the same canonicalizer -- which is
// the point: an IdP that signs with a DIFFERENT c14n than its verifier is the
// classic source of "works with vendor A, fails with vendor B". Here both sides
// digest bytes produced by one implementation, itself checked against libxml2.
//
// ECDSA-SHA256 (xmldsig-more#ecdsa-sha256). XML-DSig carries an ECDSA signature
// as the RAW r||s pair, not DER -- the opposite of WebAuthn, which is exactly the
// kind of detail that makes cross-stack SAML painful.

var g_sign_doc: Doc = undefined;
var g_si_doc: Doc = undefined;
var g_c14n: [65536]u8 = undefined;
var g_si_buf: [4096]u8 = undefined;
var g_out: [131072]u8 = undefined;

fn b64StdEncode(src: []const u8, dest: []u8) []const u8 {
    return std.base64.standard.Encoder.encode(dest, src);
}

/// Sign an UNSIGNED SAML assertion with an ES256 private key (base64url 'd').
/// Returns the signed assertion XML, with the Signature placed after Issuer --
/// the position the SAML profile requires. Returns 0 on failure.
pub fn saml_sign(
    xml_ptr: [*]const u8,
    xml_len: usize,
    d_ptr: [*]const u8,
    d_len: usize,
    out: [*]u8,
    out_cap: usize,
) callconv(.c) i32 {
    const xml = xml_ptr[0..xml_len];
    parse(&g_sign_doc, xml) catch return -1;
    const root = g_sign_doc.root() orelse return -1;
    if (!std.mem.eql(u8, root.local, "Assertion")) return -1;
    const id = g_sign_doc.attrValue(root, "", "ID") orelse return -1;

    // 1. digest the assertion AS IT STANDS (no signature in it yet -- which is
    //    precisely what the enveloped-signature transform reproduces on the
    //    verifying side)
    const c14n_len = canonicalize(&g_sign_doc, root, &g_c14n, -1, "") orelse return -1;
    var digest: [32]u8 = undefined;
    Sha256.hash(g_c14n[0..c14n_len], &digest, .{});
    var db: [64]u8 = undefined;
    const digest_b64 = b64StdEncode(&digest, &db);

    // 2. the SignedInfo that commits to that digest
    const si = std.fmt.bufPrint(&g_si_buf,
        "<ds:SignedInfo xmlns:ds=\"{s}\">" ++
        "<ds:CanonicalizationMethod Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"/>" ++
        "<ds:SignatureMethod Algorithm=\"http://www.w3.org/2001/04/xmldsig-more#ecdsa-sha256\"/>" ++
        "<ds:Reference URI=\"#{s}\">" ++
        "<ds:Transforms>" ++
        "<ds:Transform Algorithm=\"http://www.w3.org/2000/09/xmldsig#enveloped-signature\"/>" ++
        "<ds:Transform Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"/>" ++
        "</ds:Transforms>" ++
        "<ds:DigestMethod Algorithm=\"http://www.w3.org/2001/04/xmlenc#sha256\"/>" ++
        "<ds:DigestValue>{s}</ds:DigestValue>" ++
        "</ds:Reference></ds:SignedInfo>",
        .{ DS, id, digest_b64 }) catch return -1;

    // 3. sign the CANONICAL SignedInfo (never the literal bytes above)
    parse(&g_si_doc, si) catch return -1;
    const si_root = g_si_doc.root() orelse return -1;
    const si_c14n_len = canonicalize(&g_si_doc, si_root, &g_scratch, -1, "") orelse return -1;

    var sig_b64u: [256]u8 = undefined;
    const sn = crypto.crypto_sign_es256(g_scratch[0..si_c14n_len].ptr, si_c14n_len, d_ptr, d_len, &sig_b64u);
    if (sn <= 0) return -1;
    // XML-DSig wants standard base64 of the RAW r||s, so round-trip the engine's
    // base64url form rather than inventing a second encoder
    var raw: [128]u8 = undefined;
    const rawsig = b64UrlDecode(sig_b64u[0..@intCast(sn)], &raw) orelse return -1;
    var sb: [256]u8 = undefined;
    const sig_std = b64StdEncode(rawsig, &sb);

    // 4. splice the Signature in right after </...Issuer>
    const issuer = g_sign_doc.find(SAMLNS, "Issuer") orelse return -1;
    const at = issuer.end;
    var w: usize = 0;
    const head = xml[0..at];
    if (w + head.len > out_cap) return -1;
    @memcpy(out[w .. w + head.len], head);
    w += head.len;

    const parts = [_][]const u8{ "<ds:Signature xmlns:ds=\"", DS, "\">", si, "<ds:SignatureValue>", sig_std, "</ds:SignatureValue></ds:Signature>" };
    for (parts) |part| {
        if (w + part.len > out_cap) return -1;
        @memcpy(out[w .. w + part.len], part);
        w += part.len;
    }
    const tail = xml[at..];
    if (w + tail.len > out_cap) return -1;
    @memcpy(out[w .. w + tail.len], tail);
    w += tail.len;
    return @intCast(w);
}

pub export fn stz_saml_sign(x: [*]const u8, xl: usize, d: [*]const u8, dl: usize, o: [*]u8, oc: usize) callconv(.c) i32 {
    return saml_sign(x, xl, d, dl, o, oc);
}

/// The same, signed RSA-SHA256 with a PEM private key. Many enterprise service
/// providers accept RSA only, so an IdP that can sign only ECDSA cannot federate
/// with them. `signer` is called with the canonical SignedInfo and must return the
/// base64url signature -- that indirection keeps this module free of mbedTLS.
pub fn saml_sign_with(
    xml_ptr: [*]const u8,
    xml_len: usize,
    key_ptr: [*]const u8,
    key_len: usize,
    sig_alg: [*]const u8,
    sig_alg_len: usize,
    signer: *const fn ([*]const u8, usize, [*]const u8, usize, [*]u8, usize) callconv(.c) i32,
    out: [*]u8,
    out_cap: usize,
) callconv(.c) i32 {
    const xml = xml_ptr[0..xml_len];
    parse(&g_sign_doc, xml) catch return -1;
    const root = g_sign_doc.root() orelse return -1;
    if (!std.mem.eql(u8, root.local, "Assertion")) return -1;
    const id = g_sign_doc.attrValue(root, "", "ID") orelse return -1;

    const c14n_len = canonicalize(&g_sign_doc, root, &g_c14n, -1, "") orelse return -1;
    var digest: [32]u8 = undefined;
    Sha256.hash(g_c14n[0..c14n_len], &digest, .{});
    var db: [64]u8 = undefined;
    const digest_b64 = b64StdEncode(&digest, &db);

    const si = std.fmt.bufPrint(&g_si_buf,
        "<ds:SignedInfo xmlns:ds=\"{s}\">" ++
        "<ds:CanonicalizationMethod Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"/>" ++
        "<ds:SignatureMethod Algorithm=\"{s}\"/>" ++
        "<ds:Reference URI=\"#{s}\">" ++
        "<ds:Transforms>" ++
        "<ds:Transform Algorithm=\"http://www.w3.org/2000/09/xmldsig#enveloped-signature\"/>" ++
        "<ds:Transform Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"/>" ++
        "</ds:Transforms>" ++
        "<ds:DigestMethod Algorithm=\"http://www.w3.org/2001/04/xmlenc#sha256\"/>" ++
        "<ds:DigestValue>{s}</ds:DigestValue>" ++
        "</ds:Reference></ds:SignedInfo>",
        .{ DS, sig_alg[0..sig_alg_len], id, digest_b64 }) catch return -1;

    parse(&g_si_doc, si) catch return -1;
    const si_root = g_si_doc.root() orelse return -1;
    const si_c14n_len = canonicalize(&g_si_doc, si_root, &g_scratch, -1, "") orelse return -1;

    var sig_b64u: [2048]u8 = undefined;
    const sn = signer(g_scratch[0..si_c14n_len].ptr, si_c14n_len, key_ptr, key_len, &sig_b64u, sig_b64u.len);
    if (sn <= 0) return -1;
    var raw: [1024]u8 = undefined;
    const rawsig = b64UrlDecode(sig_b64u[0..@intCast(sn)], &raw) orelse return -1;
    var sb: [2048]u8 = undefined;
    const sig_std = b64StdEncode(rawsig, &sb);

    const issuer = g_sign_doc.find(SAMLNS, "Issuer") orelse return -1;
    const at = issuer.end;
    var w: usize = 0;
    const head = xml[0..at];
    if (w + head.len > out_cap) return -1;
    @memcpy(out[w .. w + head.len], head);
    w += head.len;
    const parts = [_][]const u8{ "<ds:Signature xmlns:ds=\"", DS, "\">", si, "<ds:SignatureValue>", sig_std, "</ds:SignatureValue></ds:Signature>" };
    for (parts) |part| {
        if (w + part.len > out_cap) return -1;
        @memcpy(out[w .. w + part.len], part);
        w += part.len;
    }
    const tail = xml[at..];
    if (w + tail.len > out_cap) return -1;
    @memcpy(out[w .. w + tail.len], tail);
    w += tail.len;
    return @intCast(w);
}

// ── SAML metadata: what an IdP actually publishes ────────────
//
// You do not configure a real service provider by typing key components. You
// paste the IdP's METADATA -- an XML document carrying its entityID, its SSO
// endpoint, and its signing CERTIFICATE. Reading it is the difference between
// "SAML works" and "SAML works with Okta".
//
// Returns "entityID|ssoUrl|certificateBase64". The certificate is handed back as
// text for the caller to turn into a key (see x509), so this module stays about
// XML and that one stays about certificates.

var g_meta_doc: Doc = undefined;

const MD = "urn:oasis:names:tc:SAML:2.0:metadata";

pub fn saml_metadata(xml_ptr: [*]const u8, xml_len: usize, out: [*]u8, out_cap: usize) callconv(.c) i32 {
    parse(&g_meta_doc, xml_ptr[0..xml_len]) catch return -1;
    const root = g_meta_doc.root() orelse return -1;

    // entityID lives on EntityDescriptor (which may be the root, or wrapped in an
    // EntitiesDescriptor when a federation publishes several at once)
    var entity: []const u8 = "";
    if (g_meta_doc.attrValue(root, "", "entityID")) |v| {
        entity = v;
    } else if (g_meta_doc.find(MD, "EntityDescriptor")) |ed| {
        entity = g_meta_doc.attrValue(ed, "", "entityID") orelse "";
    }

    // the redirect-binding SSO endpoint, else whichever comes first
    var sso: []const u8 = "";
    var i: usize = 0;
    while (i < g_meta_doc.node_count) : (i += 1) {
        const n = &g_meta_doc.nodes[i];
        if (!std.mem.eql(u8, n.local, "SingleSignOnService")) continue;
        const loc = g_meta_doc.attrValue(n, "", "Location") orelse continue;
        const binding = g_meta_doc.attrValue(n, "", "Binding") orelse "";
        if (sso.len == 0) sso = loc;
        if (std.mem.indexOf(u8, binding, "HTTP-Redirect") != null) {
            sso = loc;
            break;
        }
    }

    // the SIGNING certificate. A metadata document often carries two (signing and
    // encryption); prefer the one whose KeyDescriptor says use="signing".
    var cert: []const u8 = "";
    i = 0;
    while (i < g_meta_doc.node_count) : (i += 1) {
        const n = &g_meta_doc.nodes[i];
        if (!std.mem.eql(u8, n.local, "X509Certificate")) continue;
        const text = g_meta_doc.textOf(n);
        if (text.len == 0) continue;
        if (cert.len == 0) cert = text;
        // walk up to a KeyDescriptor and check its use
        var p2: i32 = n.parent;
        while (p2 >= 0) {
            const anc = &g_meta_doc.nodes[@intCast(p2)];
            if (std.mem.eql(u8, anc.local, "KeyDescriptor")) {
                const use = g_meta_doc.attrValue(anc, "", "use") orelse "";
                if (use.len == 0 or std.mem.eql(u8, use, "signing")) {
                    cert = text;
                    p2 = -1;
                    break;
                }
                break;
            }
            p2 = anc.parent;
        }
        if (cert.ptr == text.ptr and cert.len == text.len) {
            // keep looking only if we have not settled on a signing cert
        }
    }
    if (entity.len == 0 or cert.len == 0) return -1;

    var w: usize = 0;
    for ([_][]const u8{ entity, "|", sso, "|" }) |part| {
        if (w + part.len > out_cap) return -1;
        @memcpy(out[w .. w + part.len], part);
        w += part.len;
    }
    // the certificate arrives wrapped/indented inside XML; hand it over with the
    // whitespace stripped so the caller can feed it straight to a parser
    for (cert) |ch| {
        if (isSpace(ch)) continue;
        if (w + 1 > out_cap) return -1;
        out[w] = ch;
        w += 1;
    }
    return @intCast(w);
}

pub export fn stz_saml_metadata(x: [*]const u8, xl: usize, o: [*]u8, oc: usize) callconv(.c) i32 {
    return saml_metadata(x, xl, o, oc);
}

// ── tests ────────────────────────────────────────────────────

// A REAL signed SAML assertion: canonicalised by lxml (libxml2) and signed
// by OpenSSL -- neither of them ours. If our parser, our c14n and our digest
// do not agree with both, this does not pass.
const RSA_N = "uPoMB1ET3gL65ZpGaujIg1rtsTkKlIwoiLiW1VN9cyrgE7rgAWcSxl-2J-OCAky4AoS5Nn_wJCCSNbs1Jn_Z6GglGdeqhrvUxiBtA5-HL1wwXkRH7CYCsUXypyHI1BzoSxUvhmiLLHU9JRy_2lGN3nuPvYOxXaCnmU-ebHtl4s_1t3V5YiCoUAAVWv93pDg-q10sGBStvqYNwLZYXIt-Rt24LK92oCxAepzL86PJ0J3O0iQAYSWfQuCMX2SSL2jPGoo1Y5ldCilOpIT05rKvkr3JNxllhz9-CPa2dnt66oahmzFasXrMYuwXTq-ZJbi08IkdX4ztT0XlVN-Ae9bhDQ";
const RSA_E = "AQAB";
const SIGNED_ASSERTION = "<saml:Assertion xmlns:saml=\"urn:oasis:names:tc:SAML:2.0:assertion\" ID=\"_a1\" IssueInstant=\"2026-07-24T10:00:00Z\" Version=\"2.0\"><saml:Issuer>https://idp.acme.com</saml:Issuer><ds:Signature xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\"><ds:SignedInfo xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\"><ds:CanonicalizationMethod Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"/><ds:SignatureMethod Algorithm=\"http://www.w3.org/2001/04/xmldsig-more#rsa-sha256\"/><ds:Reference URI=\"#_a1\"><ds:Transforms><ds:Transform Algorithm=\"http://www.w3.org/2000/09/xmldsig#enveloped-signature\"/><ds:Transform Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"/></ds:Transforms><ds:DigestMethod Algorithm=\"http://www.w3.org/2001/04/xmlenc#sha256\"/><ds:DigestValue>0/28W7qK+tntkD2Eq2AcU58NlD/GHI1xIgAmmg5tlek=</ds:DigestValue></ds:Reference></ds:SignedInfo><ds:SignatureValue>MdoXSYTJbpZfW9TCPXNolSECe096YhXWyiBrHAK7oW2SKqqEYaJDtYoSnfwPA0LHR3ZczIpGUUk73pX0LnhS73jIF5qV2EUqmxfT8vVsJATUFi3UbC0X7INPP9MX2QwwS7f0GHA1e/LNUL+vWddHKfYWOvwm17GlB33t/8sJ/t+J/7bIX2Cd5Kgmk24dEmx+5UQK/7A2l9z40JDiwoiDXtfmqzQ2YJXUwDjcOfxfUv+qkslGT1CEpX/ZcbHNHuR3vdd132iglsCp5Qx7so+u1yTq+wQZJYcFcXDDLChR+GjCMKavV+nhjN96GHuZrMFtjCh/8lFhVVku5sg1urXHBQ==</ds:SignatureValue></ds:Signature><saml:Subject><saml:NameID>dana@acme.com</saml:NameID></saml:Subject><saml:Conditions NotBefore=\"2026-07-24T09:59:00Z\" NotOnOrAfter=\"2026-07-24T10:05:00Z\"><saml:AudienceRestriction><saml:Audience>https://sp.example.com</saml:Audience></saml:AudienceRestriction></saml:Conditions><saml:AttributeStatement><saml:Attribute Name=\"email\"><saml:AttributeValue>dana@acme.com</saml:AttributeValue></saml:Attribute></saml:AttributeStatement></saml:Assertion>";
const TAMPERED_ASSERTION = "<saml:Assertion xmlns:saml=\"urn:oasis:names:tc:SAML:2.0:assertion\" ID=\"_a1\" IssueInstant=\"2026-07-24T10:00:00Z\" Version=\"2.0\"><saml:Issuer>https://idp.acme.com</saml:Issuer><ds:Signature xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\"><ds:SignedInfo xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\"><ds:CanonicalizationMethod Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"/><ds:SignatureMethod Algorithm=\"http://www.w3.org/2001/04/xmldsig-more#rsa-sha256\"/><ds:Reference URI=\"#_a1\"><ds:Transforms><ds:Transform Algorithm=\"http://www.w3.org/2000/09/xmldsig#enveloped-signature\"/><ds:Transform Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"/></ds:Transforms><ds:DigestMethod Algorithm=\"http://www.w3.org/2001/04/xmlenc#sha256\"/><ds:DigestValue>0/28W7qK+tntkD2Eq2AcU58NlD/GHI1xIgAmmg5tlek=</ds:DigestValue></ds:Reference></ds:SignedInfo><ds:SignatureValue>MdoXSYTJbpZfW9TCPXNolSECe096YhXWyiBrHAK7oW2SKqqEYaJDtYoSnfwPA0LHR3ZczIpGUUk73pX0LnhS73jIF5qV2EUqmxfT8vVsJATUFi3UbC0X7INPP9MX2QwwS7f0GHA1e/LNUL+vWddHKfYWOvwm17GlB33t/8sJ/t+J/7bIX2Cd5Kgmk24dEmx+5UQK/7A2l9z40JDiwoiDXtfmqzQ2YJXUwDjcOfxfUv+qkslGT1CEpX/ZcbHNHuR3vdd132iglsCp5Qx7so+u1yTq+wQZJYcFcXDDLChR+GjCMKavV+nhjN96GHuZrMFtjCh/8lFhVVku5sg1urXHBQ==</ds:SignatureValue></ds:Signature><saml:Subject><saml:NameID>admin@acme.com</saml:NameID></saml:Subject><saml:Conditions NotBefore=\"2026-07-24T09:59:00Z\" NotOnOrAfter=\"2026-07-24T10:05:00Z\"><saml:AudienceRestriction><saml:Audience>https://sp.example.com</saml:Audience></saml:AudienceRestriction></saml:Conditions><saml:AttributeStatement><saml:Attribute Name=\"email\"><saml:AttributeValue>dana@acme.com</saml:AttributeValue></saml:Attribute></saml:AttributeStatement></saml:Assertion>";
const WRAPPED_RESPONSE = "<samlp:Response xmlns:samlp=\"urn:oasis:names:tc:SAML:2.0:protocol\" xmlns:saml=\"urn:oasis:names:tc:SAML:2.0:assertion\"><saml:Assertion ID=\"_evil\" Version=\"2.0\" IssueInstant=\"2026-07-24T10:00:00Z\"><saml:Issuer>https://idp.acme.com</saml:Issuer><saml:Subject><saml:NameID>attacker@evil.com</saml:NameID></saml:Subject></saml:Assertion><saml:Assertion xmlns:saml=\"urn:oasis:names:tc:SAML:2.0:assertion\" ID=\"_a1\" IssueInstant=\"2026-07-24T10:00:00Z\" Version=\"2.0\"><saml:Issuer>https://idp.acme.com</saml:Issuer><ds:Signature xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\"><ds:SignedInfo xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\"><ds:CanonicalizationMethod Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"/><ds:SignatureMethod Algorithm=\"http://www.w3.org/2001/04/xmldsig-more#rsa-sha256\"/><ds:Reference URI=\"#_a1\"><ds:Transforms><ds:Transform Algorithm=\"http://www.w3.org/2000/09/xmldsig#enveloped-signature\"/><ds:Transform Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"/></ds:Transforms><ds:DigestMethod Algorithm=\"http://www.w3.org/2001/04/xmlenc#sha256\"/><ds:DigestValue>0/28W7qK+tntkD2Eq2AcU58NlD/GHI1xIgAmmg5tlek=</ds:DigestValue></ds:Reference></ds:SignedInfo><ds:SignatureValue>MdoXSYTJbpZfW9TCPXNolSECe096YhXWyiBrHAK7oW2SKqqEYaJDtYoSnfwPA0LHR3ZczIpGUUk73pX0LnhS73jIF5qV2EUqmxfT8vVsJATUFi3UbC0X7INPP9MX2QwwS7f0GHA1e/LNUL+vWddHKfYWOvwm17GlB33t/8sJ/t+J/7bIX2Cd5Kgmk24dEmx+5UQK/7A2l9z40JDiwoiDXtfmqzQ2YJXUwDjcOfxfUv+qkslGT1CEpX/ZcbHNHuR3vdd132iglsCp5Qx7so+u1yTq+wQZJYcFcXDDLChR+GjCMKavV+nhjN96GHuZrMFtjCh/8lFhVVku5sg1urXHBQ==</ds:SignatureValue></ds:Signature><saml:Subject><saml:NameID>dana@acme.com</saml:NameID></saml:Subject><saml:Conditions NotBefore=\"2026-07-24T09:59:00Z\" NotOnOrAfter=\"2026-07-24T10:05:00Z\"><saml:AudienceRestriction><saml:Audience>https://sp.example.com</saml:Audience></saml:AudienceRestriction></saml:Conditions><saml:AttributeStatement><saml:Attribute Name=\"email\"><saml:AttributeValue>dana@acme.com</saml:AttributeValue></saml:Attribute></saml:AttributeStatement></saml:Assertion></samlp:Response>";




test "dsig: a real OpenSSL-signed SAML assertion verifies" {
    var doc: Doc = undefined;
    var scratch: [16384]u8 = undefined;
    try parse(&doc, SIGNED_ASSERTION);
    const r = verifySignature(&doc, "RSA", RSA_N, RSA_E, &scratch);
    try std.testing.expect(r.ok);
    // it reports WHICH bytes are covered -- the whole assertion
    try std.testing.expectEqual(@as(usize, 0), r.signed_start);
    try std.testing.expectEqual(SIGNED_ASSERTION.len, r.signed_end);
}

test "dsig: altering one character breaks the digest" {
    var doc: Doc = undefined;
    var scratch: [16384]u8 = undefined;
    try parse(&doc, TAMPERED_ASSERTION);
    const r = verifySignature(&doc, "RSA", RSA_N, RSA_E, &scratch);
    try std.testing.expect(!r.ok);
}

test "dsig: SIGNATURE WRAPPING is refused" {
    // the classic attack: a forged assertion is injected next to a
    // genuinely signed one. The signature still validates over the
    // original, so a naive reader trusts the WRONG element.
    var doc: Doc = undefined;
    var scratch: [16384]u8 = undefined;
    try parse(&doc, WRAPPED_RESPONSE);
    const r = verifySignature(&doc, "RSA", RSA_N, RSA_E, &scratch);
    // the signature itself still verifies -- so the defense CANNOT be
    // "did it verify"; it must be WHICH element it covered.
    if (r.ok) {
        const covered = WRAPPED_RESPONSE[r.signed_start..r.signed_end];
        // the covered range is the genuine assertion, never the forged one
        try std.testing.expect(std.mem.indexOf(u8, covered, "attacker@evil.com") == null);
        try std.testing.expect(std.mem.indexOf(u8, covered, "dana@acme.com") != null);
        try std.testing.expect(std.mem.indexOf(u8, covered, "_evil") == null);
    }
}

test "saml: a signed assertion yields its claims" {
    var out: [2048]u8 = undefined;
    const n = saml_verify(SIGNED_ASSERTION.ptr, SIGNED_ASSERTION.len, "RSA".ptr, 3,
        RSA_N.ptr, RSA_N.len, RSA_E.ptr, RSA_E.len, &out, out.len);
    try std.testing.expect(n > 0);
    const rec = out[0..@intCast(n)];
    try std.testing.expect(std.mem.startsWith(u8, rec, "1||"));
    try std.testing.expect(std.mem.indexOf(u8, rec, "https://idp.acme.com") != null);
    try std.testing.expect(std.mem.indexOf(u8, rec, "dana@acme.com") != null);
    try std.testing.expect(std.mem.indexOf(u8, rec, "https://sp.example.com") != null);
}

test "saml: wrapping cannot smuggle a claim, because we re-parse only signed bytes" {
    var out: [2048]u8 = undefined;
    const n = saml_verify(WRAPPED_RESPONSE.ptr, WRAPPED_RESPONSE.len, "RSA".ptr, 3,
        RSA_N.ptr, RSA_N.len, RSA_E.ptr, RSA_E.len, &out, out.len);
    const rec = out[0..@intCast(n)];
    // whatever the verdict, the attacker's identity must NEVER appear
    try std.testing.expect(std.mem.indexOf(u8, rec, "attacker@evil.com") == null);
}

test "saml: a tampered assertion yields no claims" {
    var out: [2048]u8 = undefined;
    const n = saml_verify(TAMPERED_ASSERTION.ptr, TAMPERED_ASSERTION.len, "RSA".ptr, 3,
        RSA_N.ptr, RSA_N.len, RSA_E.ptr, RSA_E.len, &out, out.len);
    const rec = out[0..@intCast(n)];
    try std.testing.expect(std.mem.startsWith(u8, rec, "0|"));
    try std.testing.expect(std.mem.indexOf(u8, rec, "admin@acme.com") == null);
}

test "saml: issue a signed assertion, then verify it (IdP <-> SP round trip)" {
    // the IdP's key
    var kp: [256]u8 = undefined;
    const kn = crypto.crypto_es256_keypair("".ptr, 0, &kp);
    var it = std.mem.splitScalar(u8, kp[0..@intCast(kn)], '|');
    const d = it.next().?;
    const x = it.next().?;
    const y = it.next().?;

    const unsigned =
        "<saml:Assertion xmlns:saml=\"urn:oasis:names:tc:SAML:2.0:assertion\" ID=\"_x1\" Version=\"2.0\">" ++
        "<saml:Issuer>https://idp.local</saml:Issuer>" ++
        "<saml:Subject><saml:NameID>bob@corp.com</saml:NameID></saml:Subject>" ++
        "<saml:Conditions NotBefore=\"2026-01-01T00:00:00Z\" NotOnOrAfter=\"2030-01-01T00:00:00Z\">" ++
        "<saml:AudienceRestriction><saml:Audience>https://sp.local</saml:Audience>" ++
        "</saml:AudienceRestriction></saml:Conditions></saml:Assertion>";

    var signed: [16384]u8 = undefined;
    const n = saml_sign(unsigned.ptr, unsigned.len, d.ptr, d.len, &signed, signed.len);
    try std.testing.expect(n > 0);
    const doc_xml = signed[0..@intCast(n)];
    try std.testing.expect(std.mem.indexOf(u8, doc_xml, "<ds:SignatureValue>") != null);

    // ... and our own SP verifies it
    var out: [2048]u8 = undefined;
    const vn = saml_verify(doc_xml.ptr, doc_xml.len, "EC".ptr, 2, x.ptr, x.len, y.ptr, y.len, &out, out.len);
    const rec = out[0..@intCast(vn)];
    try std.testing.expect(std.mem.startsWith(u8, rec, "1||"));
    try std.testing.expect(std.mem.indexOf(u8, rec, "bob@corp.com") != null);
    try std.testing.expect(std.mem.indexOf(u8, rec, "https://sp.local") != null);
}

test "saml: an issued assertion cannot be altered after signing" {
    var kp: [256]u8 = undefined;
    const kn = crypto.crypto_es256_keypair("".ptr, 0, &kp);
    var it = std.mem.splitScalar(u8, kp[0..@intCast(kn)], '|');
    const d = it.next().?;
    const x = it.next().?;
    const y = it.next().?;

    const unsigned =
        "<saml:Assertion xmlns:saml=\"urn:oasis:names:tc:SAML:2.0:assertion\" ID=\"_x2\" Version=\"2.0\">" ++
        "<saml:Issuer>https://idp.local</saml:Issuer>" ++
        "<saml:Subject><saml:NameID>bob@corp.com</saml:NameID></saml:Subject>" ++
        "</saml:Assertion>";
    var signed: [16384]u8 = undefined;
    const n = saml_sign(unsigned.ptr, unsigned.len, d.ptr, d.len, &signed, signed.len);
    var buf: [16384]u8 = undefined;
    @memcpy(buf[0..@intCast(n)], signed[0..@intCast(n)]);
    const doc_xml = buf[0..@intCast(n)];
    // promote bob to root
    const at = std.mem.indexOf(u8, doc_xml, "bob@corp.com").?;
    @memcpy(doc_xml[at .. at + 3], "eve");

    var out: [2048]u8 = undefined;
    const vn = saml_verify(doc_xml.ptr, doc_xml.len, "EC".ptr, 2, x.ptr, x.len, y.ptr, y.len, &out, out.len);
    const rec = out[0..@intCast(vn)];
    try std.testing.expect(std.mem.startsWith(u8, rec, "0|"));
}
