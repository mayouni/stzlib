const crypto = @import("crypto.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs2 = R.ring_vm_api_retstring2;

fn ring_Sha256(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    var buf: [64]u8 = undefined;
    const n = crypto.crypto_sha256(ptr, len, &buf);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs2(p, &buf, 0);
}

fn ring_Md5(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    var buf: [32]u8 = undefined;
    const n = crypto.crypto_md5(ptr, len, &buf);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs2(p, &buf, 0);
}

fn ring_Crc32(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(crypto.crypto_crc32(ptr, len)));
}

fn ring_Fnv32(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(crypto.crypto_fnv32(ptr, len)));
}

fn ring_Fnv64(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(crypto.crypto_fnv64(ptr, len)));
}

fn ring_ConstEqual(p: *anyopaque) callconv(.c) void {
    const a: [*]const u8 = @ptrCast(gs(p, 1));
    const al: usize = @intCast(gss(p, 1));
    const b: [*]const u8 = @ptrCast(gs(p, 2));
    const bl: usize = @intCast(gss(p, 2));
    if (al != bl) {
        rn(p, 0);
        return;
    }
    rn(p, @floatFromInt(crypto.crypto_equal(a, b, al)));
}

// StzEngineCryptoPbkdf2(cPassword, cSalt, nRounds, nDkLen) -> hex derived key.
fn ring_Pbkdf2(p: *anyopaque) callconv(.c) void {
    const pw: [*]const u8 = @ptrCast(gs(p, 1));
    const pl: usize = @intCast(gss(p, 1));
    const s: [*]const u8 = @ptrCast(gs(p, 2));
    const sl: usize = @intCast(gss(p, 2));
    const rounds: u32 = @intFromFloat(gn(p, 3));
    const dk_len: usize = @intFromFloat(gn(p, 4));
    var buf: [128]u8 = undefined;
    const n = crypto.crypto_pbkdf2_sha256(pw, pl, s, sl, rounds, dk_len, &buf);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs2(p, &buf, 0);
}

// StzEngineCryptoRandomHex(nBytes) -> hex string of nBytes CSPRNG bytes.
fn ring_RandomHex(p: *anyopaque) callconv(.c) void {
    const nbytes: usize = @intFromFloat(gn(p, 1));
    var buf: [128]u8 = undefined;
    const n = crypto.crypto_random_hex(nbytes, &buf);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs2(p, &buf, 0);
}

// StzEngineCryptoTotp(cKeyHex, nCounter, nDigits, nAlgo) -> the decimal code.
// Key is hex (base32 decode happens Ring-side); algo 1 = SHA1, 2 = SHA256.
fn ring_Totp(p: *anyopaque) callconv(.c) void {
    const k: [*]const u8 = @ptrCast(gs(p, 1));
    const kl: usize = @intCast(gss(p, 1));
    const counter: u64 = @intFromFloat(gn(p, 2));
    const digits: u32 = @intFromFloat(gn(p, 3));
    const algo: u32 = @intFromFloat(gn(p, 4));
    var buf: [16]u8 = undefined;
    const n = crypto.crypto_totp(k, kl, counter, digits, algo, &buf);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs2(p, &buf, 0);
}

// StzEngineCryptoVerifyEs256(cSigningInput, cSigB64Url, cXB64Url, cYB64Url) -> 1/0/-1
// ES256 = ECDSA P-256 + SHA-256; x/y are the JWK coordinates.
fn ring_VerifyEs256(p: *anyopaque) callconv(.c) void {
    const m: [*]const u8 = @ptrCast(gs(p, 1));
    const ml: usize = @intCast(gss(p, 1));
    const s: [*]const u8 = @ptrCast(gs(p, 2));
    const sl: usize = @intCast(gss(p, 2));
    const x: [*]const u8 = @ptrCast(gs(p, 3));
    const xl: usize = @intCast(gss(p, 3));
    const y: [*]const u8 = @ptrCast(gs(p, 4));
    const yl: usize = @intCast(gss(p, 4));
    rn(p, @floatFromInt(crypto.crypto_verify_es256(m, ml, s, sl, x, xl, y, yl)));
}

// StzEngineCryptoVerifyRs256(cSigningInput, cSigB64Url, cNB64Url, cEB64Url) -> 1/0/-1
// RS256 = RSASSA-PKCS1-v1_5 + SHA-256; n/e are the JWK modulus and exponent.
fn ring_VerifyRs256(p: *anyopaque) callconv(.c) void {
    const m: [*]const u8 = @ptrCast(gs(p, 1));
    const ml: usize = @intCast(gss(p, 1));
    const s: [*]const u8 = @ptrCast(gs(p, 2));
    const sl: usize = @intCast(gss(p, 2));
    const n: [*]const u8 = @ptrCast(gs(p, 3));
    const nl: usize = @intCast(gss(p, 3));
    const e: [*]const u8 = @ptrCast(gs(p, 4));
    const el: usize = @intCast(gss(p, 4));
    rn(p, @floatFromInt(crypto.crypto_verify_rs256(m, ml, s, sl, n, nl, e, el)));
}

// StzEngineCryptoB64UrlDecode(cB64Url) -> the decoded text (a JWT header/payload).
fn ring_B64UrlDecode(p: *anyopaque) callconv(.c) void {
    const s: [*]const u8 = @ptrCast(gs(p, 1));
    const sl: usize = @intCast(gss(p, 1));
    var buf: [8192]u8 = undefined;
    const n = crypto.crypto_b64url_decode(s, sl, &buf, buf.len);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs2(p, &buf, 0);
}

// StzEngineCryptoEs256KeyPair(cSeedHexOrEmpty) -> "d|x|y" (base64url).
fn ring_Es256KeyPair(p: *anyopaque) callconv(.c) void {
    const s: [*]const u8 = @ptrCast(gs(p, 1));
    const sl: usize = @intCast(gss(p, 1));
    var buf: [256]u8 = undefined;
    const n = crypto.crypto_es256_keypair(s, sl, &buf);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs2(p, &buf, 0);
}

// StzEngineCryptoSignEs256(cSigningInput, cPrivDB64) -> the base64url signature.
fn ring_SignEs256(p: *anyopaque) callconv(.c) void {
    const m: [*]const u8 = @ptrCast(gs(p, 1));
    const ml: usize = @intCast(gss(p, 1));
    const d: [*]const u8 = @ptrCast(gs(p, 2));
    const dl: usize = @intCast(gss(p, 2));
    var buf: [128]u8 = undefined;
    const n = crypto.crypto_sign_es256(m, ml, d, dl, &buf);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs2(p, &buf, 0);
}

pub const regs = [_]R.Reg{
    .{ .name = "stzenginecryptosha256", .func = &ring_Sha256 },
    .{ .name = "stzenginecryptomd5", .func = &ring_Md5 },
    .{ .name = "stzenginecryptocrc32", .func = &ring_Crc32 },
    .{ .name = "stzenginecryptofnv32", .func = &ring_Fnv32 },
    .{ .name = "stzenginecryptofnv64", .func = &ring_Fnv64 },
    .{ .name = "stzenginecryptoconstequal", .func = &ring_ConstEqual },
    .{ .name = "stzenginecryptopbkdf2", .func = &ring_Pbkdf2 },
    .{ .name = "stzenginecryptorandomhex", .func = &ring_RandomHex },
    .{ .name = "stzenginecryptototp", .func = &ring_Totp },
    .{ .name = "stzenginecryptoverifyes256", .func = &ring_VerifyEs256 },
    .{ .name = "stzenginecryptoverifyrs256", .func = &ring_VerifyRs256 },
    .{ .name = "stzenginecryptob64urldecode", .func = &ring_B64UrlDecode },
    .{ .name = "stzenginecryptoes256keypair", .func = &ring_Es256KeyPair },
    .{ .name = "stzenginecryptosignes256", .func = &ring_SignEs256 },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
