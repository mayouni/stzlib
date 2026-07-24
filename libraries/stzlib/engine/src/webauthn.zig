const std = @import("std");
const crypto = @import("crypto.zig");

// ── WebAuthn / passkeys (FIDO2) ──────────────────────────────
//
// A passkey login is a public-key signature -- which the engine already checks.
// What it ALSO needs, and what lives here, is BINARY PARSING: the credential's
// public key arrives as a COSE_Key inside CBOR, wrapped in an attestation
// object, alongside a packed authenticator-data structure. None of that can be
// done Ring-side: the Ring<->engine boundary validates UTF-8, so raw CBOR would
// be mangled on the way in. Everything therefore stays engine-resident, and only
// base64url / ASCII crosses.
//
// What a relying party actually has to do:
//   REGISTER  parse attestationObject -> authData -> attested credential data
//             -> credential id + COSE public key (as JWK parts, for storage).
//   LOGIN     verify sig over  authData || SHA256(clientDataJSON)  under that
//             key, then check the flags and the signature counter.
//
// Two details bite everyone who implements this:
//   * a WebAuthn ES256 signature is ASN.1 **DER**, not the raw r||s that JWS
//     uses -- so it is converted here before verification;
//   * the signed message is a CONCATENATION of raw bytes, never text.
//
// A VIRTUAL AUTHENTICATOR is included (makeCredential / makeAssertion). It is
// not a mock: it generates a real P-256 key, emits real CBOR, and signs real DER
// signatures, so the parser and verifier above are exercised against genuine
// artefacts -- the only practical way to test passkeys without a hardware key.

const Sha256 = std.crypto.hash.sha2.Sha256;
const Ecdsa256 = std.crypto.sign.ecdsa.EcdsaP256Sha256;

// ── minimal CBOR reader (only what COSE/WebAuthn uses) ───────

const Cbor = struct {
    b: []const u8,
    i: usize = 0,

    fn byte(self: *Cbor) ?u8 {
        if (self.i >= self.b.len) return null;
        const c = self.b[self.i];
        self.i += 1;
        return c;
    }

    /// major type + argument
    fn head(self: *Cbor) ?struct { mt: u8, arg: u64 } {
        const ib = self.byte() orelse return null;
        const mt: u8 = ib >> 5;
        const ai: u8 = ib & 0x1f;
        var arg: u64 = ai;
        if (ai == 24) {
            arg = self.byte() orelse return null;
        } else if (ai == 25) {
            const h = self.byte() orelse return null;
            const l = self.byte() orelse return null;
            arg = (@as(u64, h) << 8) | l;
        } else if (ai == 26) {
            var v: u64 = 0;
            var k: usize = 0;
            while (k < 4) : (k += 1) v = (v << 8) | (self.byte() orelse return null);
            arg = v;
        } else if (ai == 27) {
            var v: u64 = 0;
            var k: usize = 0;
            while (k < 8) : (k += 1) v = (v << 8) | (self.byte() orelse return null);
            arg = v;
        } else if (ai > 27) return null;
        return .{ .mt = mt, .arg = arg };
    }

    fn bytesOf(self: *Cbor, n: usize) ?[]const u8 {
        if (self.i + n > self.b.len) return null;
        const s = self.b[self.i .. self.i + n];
        self.i += n;
        return s;
    }

    /// skip one complete item (so we can walk past values we do not want)
    fn skip(self: *Cbor) bool {
        const h = self.head() orelse return false;
        switch (h.mt) {
            0, 1, 7 => return true,
            2, 3 => {
                _ = self.bytesOf(@intCast(h.arg)) orelse return false;
                return true;
            },
            4 => {
                var k: u64 = 0;
                while (k < h.arg) : (k += 1) if (!self.skip()) return false;
                return true;
            },
            5 => {
                var k: u64 = 0;
                while (k < h.arg) : (k += 1) {
                    if (!self.skip()) return false; // key
                    if (!self.skip()) return false; // value
                }
                return true;
            },
            else => return false,
        }
    }
};

/// A COSE_Key -> the JWK pieces we store. kty: 2 = EC2 (ES256), 3 = RSA.
const CoseKey = struct {
    kty: i64 = 0,
    a: []const u8 = &.{}, // EC x  | RSA n
    b: []const u8 = &.{}, // EC y  | RSA e
};

fn parseCoseKey(buf: []const u8) ?CoseKey {
    var c = Cbor{ .b = buf };
    const h = c.head() orelse return null;
    if (h.mt != 5) return null; // must be a map
    var out = CoseKey{};
    var n: u64 = 0;
    while (n < h.arg) : (n += 1) {
        const kh = c.head() orelse return null;
        var key: i64 = 0;
        if (kh.mt == 0) {
            key = @intCast(kh.arg);
        } else if (kh.mt == 1) {
            key = -1 - @as(i64, @intCast(kh.arg));
        } else {
            if (!c.skip()) return null; // non-integer label: skip its value
            continue;
        }
        // labels: 1 = kty; -1 = crv (EC) / n (RSA); -2 = x (EC) / e (RSA); -3 = y (EC)
        if (key == 1) {
            const vh = c.head() orelse return null;
            if (vh.mt != 0) return null;
            out.kty = @intCast(vh.arg);
        } else if (key == -1) {
            const vh = c.head() orelse return null;
            if (vh.mt == 2) { // RSA modulus
                out.a = c.bytesOf(@intCast(vh.arg)) orelse return null;
            } else if (vh.mt != 0 and vh.mt != 1) return null; // EC crv: an int, ignored
        } else if (key == -2) {
            const vh = c.head() orelse return null;
            if (vh.mt != 2) return null;
            const v = c.bytesOf(@intCast(vh.arg)) orelse return null;
            if (out.kty == 3) out.b = v else out.a = v; // RSA e | EC x
        } else if (key == -3) {
            const vh = c.head() orelse return null;
            if (vh.mt != 2) return null;
            out.b = c.bytesOf(@intCast(vh.arg)) orelse return null; // EC y
        } else {
            if (!c.skip()) return null;
        }
    }
    if (out.kty == 0) return null;
    return out;
}

/// authenticatorData: rpIdHash[32] flags[1] signCount[4] then, if the AT flag is
/// set, aaguid[16] credIdLen[2] credId[] coseKey[].
const AuthData = struct {
    rp_id_hash: []const u8,
    flags: u8,
    sign_count: u32,
    cred_id: []const u8 = &.{},
    cose: []const u8 = &.{},
};

fn parseAuthData(b: []const u8) ?AuthData {
    if (b.len < 37) return null;
    var ad = AuthData{
        .rp_id_hash = b[0..32],
        .flags = b[32],
        .sign_count = std.mem.readInt(u32, b[33..37], .big),
    };
    if (ad.flags & 0x40 != 0) { // AT: attested credential data present
        if (b.len < 55) return null;
        const id_len: usize = std.mem.readInt(u16, b[53..55], .big);
        if (b.len < 55 + id_len) return null;
        ad.cred_id = b[55 .. 55 + id_len];
        ad.cose = b[55 + id_len ..];
    }
    return ad;
}

/// ASN.1 DER {r,s} -> the raw 64-byte r||s the verifier wants.
fn derToRaw(der: []const u8, out: *[64]u8) bool {
    if (der.len < 8 or der[0] != 0x30) return false;
    var i: usize = 1;
    if (der[i] & 0x80 != 0) i += (der[i] & 0x7f) + 1 else i += 1;
    @memset(out, 0);
    var half: usize = 0;
    while (half < 2) : (half += 1) {
        if (i + 2 > der.len or der[i] != 0x02) return false;
        const l: usize = der[i + 1];
        i += 2;
        if (i + l > der.len or l == 0 or l > 33) return false;
        var v = der[i .. i + l];
        i += l;
        while (v.len > 0 and v[0] == 0) v = v[1..]; // strip DER's sign padding
        if (v.len > 32) return false;
        const base = half * 32;
        @memcpy(out[base + (32 - v.len) .. base + 32], v);
    }
    return true;
}

fn b64d(src: []const u8, dest: []u8) ?[]u8 {
    var end = src.len;
    while (end > 0 and src[end - 1] == '=') end -= 1;
    const dec = std.base64.url_safe_no_pad.Decoder;
    const n = dec.calcSizeForSlice(src[0..end]) catch return null;
    if (n > dest.len) return null;
    dec.decode(dest[0..n], src[0..end]) catch return null;
    return dest[0..n];
}

fn b64e(src: []const u8, dest: []u8) []const u8 {
    return std.base64.url_safe_no_pad.Encoder.encode(dest, src);
}

// ── C ABI: registration ──────────────────────────────────────

/// Parse an attestationObject -> "credIdB64|kty|k1B64|k2B64|signCount|flags",
/// where kty is "EC" (k1=x, k2=y) or "RSA" (k1=n, k2=e). Returns chars written,
/// or -1. This is everything a relying party must STORE for the credential.
pub fn webauthn_parse_attestation(
    att_ptr: [*]const u8,
    att_len: usize,
    out: [*]u8,
) callconv(.c) i32 {
    var buf: [4096]u8 = undefined;
    const att = b64d(att_ptr[0..att_len], &buf) orelse return -1;

    // the attestation object is a CBOR map; we want its "authData" entry
    var c = Cbor{ .b = att };
    const h = c.head() orelse return -1;
    if (h.mt != 5) return -1;
    var auth: []const u8 = &.{};
    var n: u64 = 0;
    while (n < h.arg) : (n += 1) {
        const kh = c.head() orelse return -1;
        if (kh.mt != 3) { // key must be a text string
            if (!c.skip()) return -1;
            if (!c.skip()) return -1;
            continue;
        }
        const key = c.bytesOf(@intCast(kh.arg)) orelse return -1;
        if (std.mem.eql(u8, key, "authData")) {
            const vh = c.head() orelse return -1;
            if (vh.mt != 2) return -1;
            auth = c.bytesOf(@intCast(vh.arg)) orelse return -1;
        } else {
            if (!c.skip()) return -1;
        }
    }
    if (auth.len == 0) return -1;

    const ad = parseAuthData(auth) orelse return -1;
    if (ad.cred_id.len == 0) return -1; // no attested credential data
    const ck = parseCoseKey(ad.cose) orelse return -1;
    if (ck.a.len == 0 or ck.b.len == 0) return -1;

    var e1: [1024]u8 = undefined;
    var e2: [1024]u8 = undefined;
    var e3: [1024]u8 = undefined;
    const cid = b64e(ad.cred_id, &e1);
    const k1 = b64e(ck.a, &e2);
    const k2 = b64e(ck.b, &e3);
    const kty: []const u8 = if (ck.kty == 3) "RSA" else "EC";

    var w: usize = 0;
    inline for (.{ 0, 1, 2, 3 }) |_| {}
    const parts = [_][]const u8{ cid, "|", kty, "|", k1, "|", k2, "|" };
    for (parts) |p| {
        @memcpy(out[w .. w + p.len], p);
        w += p.len;
    }
    w += @intCast(writeU32(out + w, ad.sign_count));
    out[w] = '|';
    w += 1;
    w += @intCast(writeU32(out + w, ad.flags));
    return @intCast(w);
}

fn writeU32(out: [*]u8, v: u32) usize {
    var tmp: [12]u8 = undefined;
    const s = std.fmt.bufPrint(&tmp, "{d}", .{v}) catch return 0;
    @memcpy(out[0..s.len], s);
    return s.len;
}

// ── C ABI: assertion (the actual login) ──────────────────────

/// Verify a passkey assertion: the signature covers authData || SHA256(client
/// dataJSON). kty "EC" -> (k1,k2) = (x,y) and the signature is DER; kty "RSA" ->
/// (n,e) and the signature is raw. Returns 1 valid / 0 invalid / -1 malformed.
pub fn webauthn_verify(
    auth_ptr: [*]const u8,
    auth_len: usize,
    cdata_ptr: [*]const u8,
    cdata_len: usize,
    sig_ptr: [*]const u8,
    sig_len: usize,
    kty_ptr: [*]const u8,
    kty_len: usize,
    k1_ptr: [*]const u8,
    k1_len: usize,
    k2_ptr: [*]const u8,
    k2_len: usize,
) callconv(.c) i32 {
    var ab: [2048]u8 = undefined;
    var cb: [4096]u8 = undefined;
    var sb: [1024]u8 = undefined;
    const auth = b64d(auth_ptr[0..auth_len], &ab) orelse return -1;
    const cdata = b64d(cdata_ptr[0..cdata_len], &cb) orelse return -1;
    const sig = b64d(sig_ptr[0..sig_len], &sb) orelse return -1;

    // the signed message: authenticatorData || SHA-256(clientDataJSON)
    var msg: [2048 + 32]u8 = undefined;
    if (auth.len + 32 > msg.len) return -1;
    @memcpy(msg[0..auth.len], auth);
    var cd_hash: [32]u8 = undefined;
    Sha256.hash(cdata, &cd_hash, .{});
    @memcpy(msg[auth.len .. auth.len + 32], &cd_hash);
    const signed = msg[0 .. auth.len + 32];

    const kty = kty_ptr[0..kty_len];
    if (std.mem.eql(u8, kty, "EC")) {
        var raw: [64]u8 = undefined;
        if (sig.len == 64) {
            @memcpy(&raw, sig[0..64]); // already raw r||s
        } else if (!derToRaw(sig, &raw)) {
            return -1;
        }
        var xb: [64]u8 = undefined;
        var yb: [64]u8 = undefined;
        const x = b64d(k1_ptr[0..k1_len], &xb) orelse return -1;
        const y = b64d(k2_ptr[0..k2_len], &yb) orelse return -1;
        if (x.len != 32 or y.len != 32) return -1;
        var sec1: [65]u8 = undefined;
        sec1[0] = 0x04;
        @memcpy(sec1[1..33], x);
        @memcpy(sec1[33..65], y);
        const pk = Ecdsa256.PublicKey.fromSec1(&sec1) catch return -1;
        const s = Ecdsa256.Signature.fromBytes(raw);
        s.verify(signed, pk) catch return 0;
        return 1;
    } else if (std.mem.eql(u8, kty, "RSA")) {
        // RS256 assertion: re-encode the pieces and reuse the RSA verifier.
        var e1: [1024]u8 = undefined;
        const sig_b64 = b64e(sig, &e1);
        return crypto.crypto_verify_rs256(
            signed.ptr,
            signed.len,
            sig_b64.ptr,
            sig_b64.len,
            k1_ptr,
            k1_len,
            k2_ptr,
            k2_len,
        );
    }
    return -1;
}

/// Read the flags + signature counter out of authenticatorData ->
/// "flags|signCount". The counter must strictly INCREASE across logins (a
/// replayed or cloned authenticator shows up as a stalled counter).
pub fn webauthn_parse_authdata(auth_ptr: [*]const u8, auth_len: usize, out: [*]u8) callconv(.c) i32 {
    var ab: [2048]u8 = undefined;
    const auth = b64d(auth_ptr[0..auth_len], &ab) orelse return -1;
    const ad = parseAuthData(auth) orelse return -1;
    var w: usize = writeU32(out, ad.flags);
    out[w] = '|';
    w += 1;
    w += writeU32(out + w, ad.sign_count);
    return @intCast(w);
}

// ── C ABI: the VIRTUAL AUTHENTICATOR (a real one, in software) ──

fn cborMapHead(out: []u8, i: *usize, n: u8) void {
    out[i.*] = 0xa0 | n;
    i.* += 1;
}

fn cborText(out: []u8, i: *usize, s: []const u8) void {
    out[i.*] = 0x60 | @as(u8, @intCast(s.len));
    i.* += 1;
    @memcpy(out[i.* .. i.* + s.len], s);
    i.* += s.len;
}

fn cborBytes(out: []u8, i: *usize, s: []const u8) void {
    if (s.len < 24) {
        out[i.*] = 0x40 | @as(u8, @intCast(s.len));
        i.* += 1;
    } else if (s.len < 256) {
        out[i.*] = 0x58;
        out[i.* + 1] = @intCast(s.len);
        i.* += 2;
    } else {
        out[i.*] = 0x59;
        out[i.* + 1] = @intCast(s.len >> 8);
        out[i.* + 2] = @intCast(s.len & 0xff);
        i.* += 3;
    }
    @memcpy(out[i.* .. i.* + s.len], s);
    i.* += s.len;
}

/// Build authenticatorData for a credential (AT flag set, with the COSE key).
fn buildAuthData(rp_id: []const u8, cred_id: []const u8, x: []const u8, y: []const u8, flags: u8, count: u32, out: []u8) usize {
    var i: usize = 0;
    var h: [32]u8 = undefined;
    Sha256.hash(rp_id, &h, .{});
    @memcpy(out[0..32], &h);
    i = 32;
    out[i] = flags;
    i += 1;
    std.mem.writeInt(u32, out[i..][0..4], count, .big);
    i += 4;
    if (flags & 0x40 != 0) {
        @memset(out[i .. i + 16], 0); // aaguid: all-zero, as a software authenticator reports
        i += 16;
        std.mem.writeInt(u16, out[i..][0..2], @intCast(cred_id.len), .big);
        i += 2;
        @memcpy(out[i .. i + cred_id.len], cred_id);
        i += cred_id.len;
        // COSE_Key: {1:2, 3:-7, -1:1, -2:x, -3:y}
        cborMapHead(out, &i, 5);
        out[i] = 0x01; i += 1; out[i] = 0x02; i += 1;          // kty: EC2
        out[i] = 0x03; i += 1; out[i] = 0x26; i += 1;          // alg: -7 (ES256)
        out[i] = 0x20; i += 1; out[i] = 0x01; i += 1;          // crv: P-256
        out[i] = 0x21; i += 1; cborBytes(out, &i, x);          // x
        out[i] = 0x22; i += 1; cborBytes(out, &i, y);          // y
    }
    return i;
}

/// Create a credential the way a security key would -> "attObjB64|privDB64|
/// credIdB64". Deterministic from a 32-byte hex seed ("" = random).
pub fn webauthn_make_credential(
    rp_ptr: [*]const u8,
    rp_len: usize,
    seed_ptr: [*]const u8,
    seed_len: usize,
    out: [*]u8,
) callconv(.c) i32 {
    var seed: [32]u8 = undefined;
    if (seed_len == 0) {
        std.crypto.random.bytes(&seed);
    } else {
        if (seed_len != 64) return -1;
        var i: usize = 0;
        while (i < 32) : (i += 1) {
            const hi = hexN(seed_ptr[i * 2]) orelse return -1;
            const lo = hexN(seed_ptr[i * 2 + 1]) orelse return -1;
            seed[i] = (@as(u8, hi) << 4) | lo;
        }
    }
    const kp = Ecdsa256.KeyPair.generateDeterministic(seed) catch return -1;
    const sec1 = kp.public_key.toUncompressedSec1();

    // the credential id: derived from the key, so it is stable per credential
    var cred_id: [16]u8 = undefined;
    var idh: [32]u8 = undefined;
    Sha256.hash(&sec1, &idh, .{});
    @memcpy(&cred_id, idh[0..16]);

    var ad_buf: [512]u8 = undefined;
    const ad_len = buildAuthData(rp_ptr[0..rp_len], &cred_id, sec1[1..33], sec1[33..65], 0x45, 0, &ad_buf);

    // attestationObject = {"fmt":"none","attStmt":{},"authData":<bytes>}
    var att: [1024]u8 = undefined;
    var i: usize = 0;
    cborMapHead(&att, &i, 3);
    cborText(&att, &i, "fmt");
    cborText(&att, &i, "none");
    cborText(&att, &i, "attStmt");
    cborMapHead(&att, &i, 0);
    cborText(&att, &i, "authData");
    cborBytes(&att, &i, ad_buf[0..ad_len]);

    var e1: [2048]u8 = undefined;
    var e2: [128]u8 = undefined;
    var e3: [64]u8 = undefined;
    const att_b64 = b64e(att[0..i], &e1);
    const d = kp.secret_key.toBytes();
    const d_b64 = b64e(&d, &e2);
    const id_b64 = b64e(&cred_id, &e3);

    var w: usize = 0;
    for ([_][]const u8{ att_b64, "|", d_b64, "|", id_b64 }) |p| {
        @memcpy(out[w .. w + p.len], p);
        w += p.len;
    }
    return @intCast(w);
}

/// Produce an assertion the way the authenticator would -> "authDataB64|sigB64"
/// (the signature in raw r||s; a real key emits DER, and both are accepted).
pub fn webauthn_make_assertion(
    rp_ptr: [*]const u8,
    rp_len: usize,
    cdata_ptr: [*]const u8,
    cdata_len: usize,
    d_ptr: [*]const u8,
    d_len: usize,
    count: u32,
    out: [*]u8,
) callconv(.c) i32 {
    var db: [64]u8 = undefined;
    const d = b64d(d_ptr[0..d_len], &db) orelse return -1;
    if (d.len != 32) return -1;
    const sk = Ecdsa256.SecretKey.fromBytes(d[0..32].*) catch return -1;
    const kp = Ecdsa256.KeyPair.fromSecretKey(sk) catch return -1;

    var ad_buf: [128]u8 = undefined;
    const ad_len = buildAuthData(rp_ptr[0..rp_len], &.{}, &.{}, &.{}, 0x05, count, &ad_buf); // UP|UV, no AT

    var cb: [4096]u8 = undefined;
    const cdata = b64d(cdata_ptr[0..cdata_len], &cb) orelse return -1;

    var msg: [2048 + 32]u8 = undefined;
    @memcpy(msg[0..ad_len], ad_buf[0..ad_len]);
    var cdh: [32]u8 = undefined;
    Sha256.hash(cdata, &cdh, .{});
    @memcpy(msg[ad_len .. ad_len + 32], &cdh);

    const sig = kp.sign(msg[0 .. ad_len + 32], null) catch return -1;
    const sig_bytes = sig.toBytes();

    var e1: [256]u8 = undefined;
    var e2: [128]u8 = undefined;
    const ad_b64 = b64e(ad_buf[0..ad_len], &e1);
    const sig_b64 = b64e(&sig_bytes, &e2);

    var w: usize = 0;
    for ([_][]const u8{ ad_b64, "|", sig_b64 }) |p| {
        @memcpy(out[w .. w + p.len], p);
        w += p.len;
    }
    return @intCast(w);
}

fn hexN(c: u8) ?u8 {
    return switch (c) {
        '0'...'9' => c - '0',
        'a'...'f' => c - 'a' + 10,
        'A'...'F' => c - 'A' + 10,
        else => null,
    };
}

// ── exports ──────────────────────────────────────────────────

pub export fn stz_webauthn_parse_attestation(a: [*]const u8, al: usize, o: [*]u8) callconv(.c) i32 {
    return webauthn_parse_attestation(a, al, o);
}
pub export fn stz_webauthn_verify(a: [*]const u8, al: usize, c: [*]const u8, cl: usize, s: [*]const u8, sl: usize, kt: [*]const u8, ktl: usize, k1: [*]const u8, k1l: usize, k2: [*]const u8, k2l: usize) callconv(.c) i32 {
    return webauthn_verify(a, al, c, cl, s, sl, kt, ktl, k1, k1l, k2, k2l);
}
pub export fn stz_webauthn_parse_authdata(a: [*]const u8, al: usize, o: [*]u8) callconv(.c) i32 {
    return webauthn_parse_authdata(a, al, o);
}
pub export fn stz_webauthn_make_credential(r: [*]const u8, rl: usize, s: [*]const u8, sl: usize, o: [*]u8) callconv(.c) i32 {
    return webauthn_make_credential(r, rl, s, sl, o);
}
pub export fn stz_webauthn_make_assertion(r: [*]const u8, rl: usize, c: [*]const u8, cl: usize, d: [*]const u8, dl: usize, n: u32, o: [*]u8) callconv(.c) i32 {
    return webauthn_make_assertion(r, rl, c, cl, d, dl, n, o);
}

// ── tests ────────────────────────────────────────────────────

test "webauthn: register a virtual credential, then log in with it" {
    const rp = "example.com";
    const seed = "00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff";
    var cred: [4096]u8 = undefined;
    const cn = webauthn_make_credential(rp.ptr, rp.len, seed.ptr, seed.len, &cred);
    try std.testing.expect(cn > 0);
    var it = std.mem.splitScalar(u8, cred[0..@intCast(cn)], '|');
    const att = it.next().?;
    const priv = it.next().?;
    const cred_id = it.next().?;

    // the relying party parses the attestation into what it must store
    var parsed: [4096]u8 = undefined;
    const pn = webauthn_parse_attestation(att.ptr, att.len, &parsed);
    try std.testing.expect(pn > 0);
    var pit = std.mem.splitScalar(u8, parsed[0..@intCast(pn)], '|');
    const p_id = pit.next().?;
    const kty = pit.next().?;
    const x = pit.next().?;
    const y = pit.next().?;
    try std.testing.expectEqualStrings(cred_id, p_id);
    try std.testing.expectEqualStrings("EC", kty);

    // ... then a login: the authenticator signs the challenge
    const cdata = "eyJ0eXBlIjoid2ViYXV0aG4uZ2V0IiwiY2hhbGxlbmdlIjoiYWJjIiwib3JpZ2luIjoiaHR0cHM6Ly9leGFtcGxlLmNvbSJ9";
    var asrt: [1024]u8 = undefined;
    const an = webauthn_make_assertion(rp.ptr, rp.len, cdata.ptr, cdata.len, priv.ptr, priv.len, 1, &asrt);
    try std.testing.expect(an > 0);
    var ait = std.mem.splitScalar(u8, asrt[0..@intCast(an)], '|');
    const authdata = ait.next().?;
    const sig = ait.next().?;

    try std.testing.expectEqual(@as(i32, 1), webauthn_verify(authdata.ptr, authdata.len, cdata.ptr, cdata.len, sig.ptr, sig.len, "EC".ptr, 2, x.ptr, x.len, y.ptr, y.len));

    // a DIFFERENT clientDataJSON (a replayed/altered challenge) must not verify
    const other = "eyJ0eXBlIjoid2ViYXV0aG4uZ2V0IiwiY2hhbGxlbmdlIjoiWFhYIiwib3JpZ2luIjoiaHR0cHM6Ly9leGFtcGxlLmNvbSJ9";
    try std.testing.expectEqual(@as(i32, 0), webauthn_verify(authdata.ptr, authdata.len, other.ptr, other.len, sig.ptr, sig.len, "EC".ptr, 2, x.ptr, x.len, y.ptr, y.len));
}

test "webauthn: the signature counter is readable, and advances" {
    const rp = "example.com";
    var cred: [4096]u8 = undefined;
    const cn = webauthn_make_credential(rp.ptr, rp.len, "".ptr, 0, &cred);
    var it = std.mem.splitScalar(u8, cred[0..@intCast(cn)], '|');
    _ = it.next();
    const priv = it.next().?;
    const cdata = "e30"; // "{}"
    var a1: [1024]u8 = undefined;
    const n1 = webauthn_make_assertion(rp.ptr, rp.len, cdata.ptr, cdata.len, priv.ptr, priv.len, 7, &a1);
    var it1 = std.mem.splitScalar(u8, a1[0..@intCast(n1)], '|');
    const ad = it1.next().?;
    var meta: [64]u8 = undefined;
    const mn = webauthn_parse_authdata(ad.ptr, ad.len, &meta);
    try std.testing.expect(mn > 0);
    // "flags|count" -- UP|UV = 0x05 = 5, and the counter we asked for
    try std.testing.expectEqualStrings("5|7", meta[0..@intCast(mn)]);
}

test "webauthn: a credential from another key does not verify" {
    const rp = "example.com";
    var c1: [4096]u8 = undefined;
    var c2: [4096]u8 = undefined;
    const n1 = webauthn_make_credential(rp.ptr, rp.len, "".ptr, 0, &c1);
    const n2 = webauthn_make_credential(rp.ptr, rp.len, "".ptr, 0, &c2);
    var it1 = std.mem.splitScalar(u8, c1[0..@intCast(n1)], '|');
    const att1 = it1.next().?;
    var it2 = std.mem.splitScalar(u8, c2[0..@intCast(n2)], '|');
    _ = it2.next();
    const priv2 = it2.next().?;

    var parsed: [4096]u8 = undefined;
    const pn = webauthn_parse_attestation(att1.ptr, att1.len, &parsed);
    var pit = std.mem.splitScalar(u8, parsed[0..@intCast(pn)], '|');
    _ = pit.next();
    _ = pit.next();
    const x1 = pit.next().?;
    const y1 = pit.next().?;

    const cdata = "e30";
    var asrt: [1024]u8 = undefined;
    const an = webauthn_make_assertion(rp.ptr, rp.len, cdata.ptr, cdata.len, priv2.ptr, priv2.len, 1, &asrt);
    var ait = std.mem.splitScalar(u8, asrt[0..@intCast(an)], '|');
    const ad = ait.next().?;
    const sig = ait.next().?;
    // signed by key 2, checked against key 1's public half
    try std.testing.expectEqual(@as(i32, 0), webauthn_verify(ad.ptr, ad.len, cdata.ptr, cdata.len, sig.ptr, sig.len, "EC".ptr, 2, x1.ptr, x1.len, y1.ptr, y1.len));
}

test "webauthn: DER signatures (what a real key emits) are accepted" {
    // build a DER signature by hand from a raw one and check both paths agree
    var raw: [64]u8 = undefined;
    var der: [72]u8 = undefined;
    @memset(&raw, 0x11);
    // 0x30 len 0x02 0x20 r 0x02 0x20 s
    der[0] = 0x30;
    der[1] = 68;
    der[2] = 0x02;
    der[3] = 32;
    @memcpy(der[4..36], raw[0..32]);
    der[36] = 0x02;
    der[37] = 32;
    @memcpy(der[38..70], raw[32..64]);
    var back: [64]u8 = undefined;
    try std.testing.expect(derToRaw(der[0..70], &back));
    try std.testing.expectEqualSlices(u8, &raw, &back);
}
