// Softanza Engine -- String Encode/Decode Operations
//
// Encoding, decoding, cipher, and data-representation functions.
// Extracted from string.zig as part of Phase D module separation.
//
// Categories:
//   URL encode/decode, Hex encode/decode, Base64 encode/decode,
//   Binary encode/decode, HTML escape/unescape, Morse code,
//   CSV field encoding, Quote/unquote, Ciphers (Caesar, Vigenere,
//   Atbash, ROT47, XOR, Zigzag), Hash (FNV-1a), Entropy.

const std = @import("std");
const core = @import("core.zig");

const mem = core.mem;
const gpa = core.gpa;
const StzString = core.StzString;
const StzStringHandle = core.StzStringHandle;
const setError = core.setError;
const str_new = core.str_new;
const str_from = core.str_from;

// ─── URL Encode/Decode ───

pub fn str_url_encode(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    const hex = "0123456789ABCDEF";
    for (buf) |byte| {
        if (isUnreserved(byte)) {
            result.data.append(gpa, byte) catch {
                result.deinit();
                gpa.destroy(result);
                return null;
            };
        } else {
            result.data.appendSlice(gpa, &[_]u8{
                '%',
                hex[byte >> 4],
                hex[byte & 0x0F],
            }) catch {
                result.deinit();
                gpa.destroy(result);
                return null;
            };
        }
    }
    return result;
}

fn isUnreserved(c: u8) bool {
    return (c >= 'A' and c <= 'Z') or
        (c >= 'a' and c <= 'z') or
        (c >= '0' and c <= '9') or
        c == '-' or c == '_' or c == '.' or c == '~';
}

pub fn str_url_decode(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    var i: usize = 0;
    while (i < buf.len) {
        if (buf[i] == '%' and i + 2 < buf.len) {
            const hi = hexVal(buf[i + 1]);
            const lo = hexVal(buf[i + 2]);
            if (hi != null and lo != null) {
                result.data.append(gpa, (hi.? << 4) | lo.?) catch {
                    result.deinit();
                    gpa.destroy(result);
                    return null;
                };
                i += 3;
                continue;
            }
        }
        result.data.append(gpa, buf[i]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
        i += 1;
    }
    return result;
}

fn hexVal(c: u8) ?u8 {
    if (c >= '0' and c <= '9') return c - '0';
    if (c >= 'A' and c <= 'F') return c - 'A' + 10;
    if (c >= 'a' and c <= 'f') return c - 'a' + 10;
    return null;
}

// ─── Hex Encode/Decode ───

/// Encode each byte as two lowercase hex characters. Returns new handle.
pub fn str_encode_hex(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    const hex_chars = "0123456789abcdef";

    for (src) |byte| {
        const hi: u8 = hex_chars[byte >> 4];
        const lo: u8 = hex_chars[byte & 0x0F];
        result.data.appendSlice(gpa, &[_]u8{ hi, lo }) catch break;
    }
    return result;
}

/// Decode a hex string (pairs of hex digits) back to bytes. Returns new handle.
pub fn str_decode_hex(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;

    var i: usize = 0;
    while (i + 1 < src.len) {
        const hi = hexDigitValue(src[i]);
        const lo = hexDigitValue(src[i + 1]);
        if (hi != null and lo != null) {
            const byte: u8 = (@as(u8, hi.?) << 4) | @as(u8, lo.?);
            result.data.appendSlice(gpa, &[_]u8{byte}) catch break;
        }
        i += 2;
    }
    return result;
}

fn hexDigitValue(c: u8) ?u4 {
    if (c >= '0' and c <= '9') return @intCast(c - '0');
    if (c >= 'a' and c <= 'f') return @intCast(c - 'a' + 10);
    if (c >= 'A' and c <= 'F') return @intCast(c - 'A' + 10);
    return null;
}

/// Alias: encode each byte as two lowercase hex characters.
pub fn str_to_hex(handle: ?*StzString) callconv(.c) ?*StzString {
    return str_encode_hex(handle);
}

/// Alias: decode hex string back to bytes.
pub fn str_from_hex(handle: ?*StzString) callconv(.c) ?*StzString {
    return str_decode_hex(handle);
}

// ─── HTML Escape/Unescape ───

/// Escape HTML special characters: & < > " '
pub fn str_escape_html(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return str_from(src.ptr, 0);

    const result = str_new() orelse return null;
    for (src) |c| {
        switch (c) {
            '&' => result.data.appendSlice(gpa, "&amp;") catch break,
            '<' => result.data.appendSlice(gpa, "&lt;") catch break,
            '>' => result.data.appendSlice(gpa, "&gt;") catch break,
            '"' => result.data.appendSlice(gpa, "&quot;") catch break,
            '\'' => result.data.appendSlice(gpa, "&#39;") catch break,
            else => result.data.appendSlice(gpa, &[_]u8{c}) catch break,
        }
    }
    return result;
}

/// Unescape HTML entities: &amp; &lt; &gt; &quot; &#39;
pub fn str_unescape_html(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return str_from(src.ptr, 0);

    const result = str_new() orelse return null;
    var off: usize = 0;
    while (off < src.len) {
        if (src[off] == '&') {
            if (off + 4 <= src.len and mem.eql(u8, src[off..][0..4], "&lt;")) {
                result.data.appendSlice(gpa, "<") catch break;
                off += 4;
            } else if (off + 4 <= src.len and mem.eql(u8, src[off..][0..4], "&gt;")) {
                result.data.appendSlice(gpa, ">") catch break;
                off += 4;
            } else if (off + 5 <= src.len and mem.eql(u8, src[off..][0..5], "&amp;")) {
                result.data.appendSlice(gpa, "&") catch break;
                off += 5;
            } else if (off + 6 <= src.len and mem.eql(u8, src[off..][0..6], "&quot;")) {
                result.data.appendSlice(gpa, "\"") catch break;
                off += 6;
            } else if (off + 5 <= src.len and mem.eql(u8, src[off..][0..5], "&#39;")) {
                result.data.appendSlice(gpa, "'") catch break;
                off += 5;
            } else {
                result.data.appendSlice(gpa, &[_]u8{src[off]}) catch break;
                off += 1;
            }
        } else {
            result.data.appendSlice(gpa, &[_]u8{src[off]}) catch break;
            off += 1;
        }
    }
    return result;
}

// ─── Base64 Encode/Decode ───

const base64_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

pub fn str_to_base64(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;

    var i: usize = 0;
    while (i < src.len) {
        const b0: u32 = src[i];
        const b1: u32 = if (i + 1 < src.len) src[i + 1] else 0;
        const b2: u32 = if (i + 2 < src.len) src[i + 2] else 0;
        const triple = (b0 << 16) | (b1 << 8) | b2;

        result.data.appendSlice(gpa, &[_]u8{base64_chars[@intCast((triple >> 18) & 0x3F)]}) catch break;
        result.data.appendSlice(gpa, &[_]u8{base64_chars[@intCast((triple >> 12) & 0x3F)]}) catch break;
        if (i + 1 < src.len) {
            result.data.appendSlice(gpa, &[_]u8{base64_chars[@intCast((triple >> 6) & 0x3F)]}) catch break;
        } else {
            result.data.appendSlice(gpa, "=") catch break;
        }
        if (i + 2 < src.len) {
            result.data.appendSlice(gpa, &[_]u8{base64_chars[@intCast(triple & 0x3F)]}) catch break;
        } else {
            result.data.appendSlice(gpa, "=") catch break;
        }
        i += 3;
    }
    return result;
}

pub fn str_from_base64(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;

    var i: usize = 0;
    while (i + 3 < src.len) {
        const c0 = base64Decode(src[i]);
        const c1 = base64Decode(src[i + 1]);
        const c2 = base64Decode(src[i + 2]);
        const c3 = base64Decode(src[i + 3]);
        if (c0 == 255 or c1 == 255) break;

        const byte0: u8 = @intCast((c0 << 2) | (c1 >> 4));
        result.data.appendSlice(gpa, &[_]u8{byte0}) catch break;

        if (c2 != 255) {
            const byte1: u8 = @intCast(((c1 & 0x0F) << 4) | (c2 >> 2));
            result.data.appendSlice(gpa, &[_]u8{byte1}) catch break;
        }
        if (c3 != 255) {
            const byte2: u8 = @intCast(((c2 & 0x03) << 6) | c3);
            result.data.appendSlice(gpa, &[_]u8{byte2}) catch break;
        }
        i += 4;
    }
    return result;
}

fn base64Decode(c: u8) u8 {
    if (c >= 'A' and c <= 'Z') return c - 'A';
    if (c >= 'a' and c <= 'z') return c - 'a' + 26;
    if (c >= '0' and c <= '9') return c - '0' + 52;
    if (c == '+') return 62;
    if (c == '/') return 63;
    return 255; // padding or invalid
}

// ─── Binary Encode/Decode ───

/// Convert string to binary representation: each byte as 8 binary digits, space-separated.
pub fn str_to_binary(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;

    for (src, 0..) |byte, idx| {
        if (idx > 0) result.data.appendSlice(gpa, " ") catch break;
        var buf: [8]u8 = undefined;
        for (0..8) |bit| {
            buf[bit] = if ((byte >> @intCast(7 - bit)) & 1 == 1) '1' else '0';
        }
        result.data.appendSlice(gpa, &buf) catch break;
    }
    return result;
}

/// Decode binary representation (space-separated 8-bit groups) back to string.
pub fn str_from_binary(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;

    var ii: usize = 0;
    while (ii < src.len) {
        // Skip spaces
        while (ii < src.len and src[ii] == ' ') : (ii += 1) {}
        if (ii >= src.len) break;
        // Read 8 binary digits
        if (ii + 8 > src.len) break;
        var byte: u8 = 0;
        var valid = true;
        for (0..8) |bit| {
            if (src[ii + bit] == '1') {
                byte |= @as(u8, 1) << @intCast(7 - bit);
            } else if (src[ii + bit] != '0') {
                valid = false;
                break;
            }
        }
        if (!valid) break;
        result.data.appendSlice(gpa, &[_]u8{byte}) catch break;
        ii += 8;
    }
    return result;
}

// ─── Morse Code ───

/// Convert text to Morse code (ASCII letters and digits only, space-separated, / for word breaks).
pub fn str_to_morse(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;

    const morse_table = [_][]const u8{
        ".-", "-...", "-.-.", "-..", ".", "..-.", "--.", "....", "..", // a-i
        ".---", "-.-", ".-..", "--", "-.", "---", ".--.", "--.-", ".-.", // j-r
        "...", "-", "..-", "...-", ".--", "-..-", "-.--", "--..", // s-z
    };
    const digit_table = [_][]const u8{
        "-----", ".----", "..---", "...--", "....-", // 0-4
        ".....", "-....", "--...", "---..", "----.", // 5-9
    };

    var first = true;
    for (src) |c| {
        if (c == ' ') {
            result.data.appendSlice(gpa, " / ") catch break;
            first = true;
            continue;
        }
        const code: ?[]const u8 = if (c >= 'a' and c <= 'z')
            morse_table[c - 'a']
        else if (c >= 'A' and c <= 'Z')
            morse_table[c - 'A']
        else if (c >= '0' and c <= '9')
            digit_table[c - '0']
        else
            null;

        if (code) |morse| {
            if (!first) result.data.appendSlice(gpa, " ") catch break;
            result.data.appendSlice(gpa, morse) catch break;
            first = false;
        }
    }
    return result;
}

// ─── Quote/Unquote/CSV ───

pub fn str_quote(handle: ?*StzString, quote_char: u8) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    result.data.appendSlice(gpa, &[_]u8{quote_char}) catch { setError(.out_of_memory); };
    result.data.appendSlice(gpa, src) catch { setError(.out_of_memory); };
    result.data.appendSlice(gpa, &[_]u8{quote_char}) catch { setError(.out_of_memory); };
    return result;
}

pub fn str_unquote(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    if (src.len < 2) {
        result.data.appendSlice(gpa, src) catch { setError(.out_of_memory); };
        return result;
    }
    const first = src[0];
    const last = src[src.len - 1];
    if ((first == '"' and last == '"') or (first == '\'' and last == '\'') or (first == '`' and last == '`')) {
        result.data.appendSlice(gpa, src[1 .. src.len - 1]) catch { setError(.out_of_memory); };
    } else {
        result.data.appendSlice(gpa, src) catch { setError(.out_of_memory); };
    }
    return result;
}

pub fn str_to_csv_field(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    // Check if quoting needed (contains comma, quote, or newline)
    var needs_quote = false;
    for (src) |c| {
        if (c == ',' or c == '"' or c == '\n' or c == '\r') {
            needs_quote = true;
            break;
        }
    }
    if (!needs_quote) {
        result.data.appendSlice(gpa, src) catch { setError(.out_of_memory); };
        return result;
    }
    result.data.appendSlice(gpa, "\"") catch { setError(.out_of_memory); };
    for (src) |c| {
        if (c == '"') {
            result.data.appendSlice(gpa, "\"\"") catch break;
        } else {
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
        }
    }
    result.data.appendSlice(gpa, "\"") catch { setError(.out_of_memory); };
    return result;
}

// ─── Ciphers ───

/// Caesar cipher: shift each ASCII letter by n positions (wrapping). Non-letters unchanged.
pub fn str_caesar(handle: ?*StzString, shift: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;

    // Normalize shift to 0-25 range
    const n: u8 = @intCast(@mod(shift, 26));

    for (src) |c| {
        if (c >= 'a' and c <= 'z') {
            const shifted: u8 = 'a' + @as(u8, @intCast((@as(u16, c - 'a') + n) % 26));
            result.data.appendSlice(gpa, &[_]u8{shifted}) catch break;
        } else if (c >= 'A' and c <= 'Z') {
            const shifted: u8 = 'A' + @as(u8, @intCast((@as(u16, c - 'A') + n) % 26));
            result.data.appendSlice(gpa, &[_]u8{shifted}) catch break;
        } else {
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
        }
    }
    return result;
}

/// XOR cipher: XOR each byte with key byte.
pub fn str_xor_cipher(handle: ?*StzString, key: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    const k: u8 = @intCast(key & 0xFF);

    for (src) |c| {
        result.data.appendSlice(gpa, &[_]u8{c ^ k}) catch break;
    }
    return result;
}

/// Vigenere cipher encryption.
pub fn str_vigenere_encrypt(handle: ?*StzString, key_ptr: [*c]const u8, key_len: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const klen: usize = if (key_len < 1) return null else @intCast(key_len);
    const key = key_ptr[0..klen];
    const result = str_new() orelse return null;
    var ki: usize = 0;
    for (src) |c| {
        if (c >= 'a' and c <= 'z') {
            var k = key[ki % klen];
            if (k >= 'A' and k <= 'Z') k += 32;
            if (k >= 'a' and k <= 'z') {
                const shift_val: u8 = k - 'a';
                const enc: u8 = 'a' + @as(u8, @intCast((@as(u16, c - 'a') + shift_val) % 26));
                result.data.appendSlice(gpa, &[_]u8{enc}) catch break;
            } else {
                result.data.appendSlice(gpa, &[_]u8{c}) catch break;
            }
            ki += 1;
        } else if (c >= 'A' and c <= 'Z') {
            var k = key[ki % klen];
            if (k >= 'A' and k <= 'Z') k += 32;
            if (k >= 'a' and k <= 'z') {
                const shift_val: u8 = k - 'a';
                const enc: u8 = 'A' + @as(u8, @intCast((@as(u16, c - 'A') + shift_val) % 26));
                result.data.appendSlice(gpa, &[_]u8{enc}) catch break;
            } else {
                result.data.appendSlice(gpa, &[_]u8{c}) catch break;
            }
            ki += 1;
        } else {
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
        }
    }
    return result;
}

/// Atbash cipher: reverse alphabet substitution.
pub fn str_atbash(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    for (src) |c| {
        if (c >= 'a' and c <= 'z') {
            result.data.appendSlice(gpa, &[_]u8{'z' - (c - 'a')}) catch break;
        } else if (c >= 'A' and c <= 'Z') {
            result.data.appendSlice(gpa, &[_]u8{'Z' - (c - 'A')}) catch break;
        } else {
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
        }
    }
    return result;
}

/// ROT47: rotate printable ASCII characters (33-126) by 47 positions.
pub fn str_rot47(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    for (src) |c| {
        if (c >= 33 and c <= 126) {
            const rotated: u8 = 33 + ((c - 33 + 47) % 94);
            result.data.appendSlice(gpa, &[_]u8{rotated}) catch break;
        } else {
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
        }
    }
    return result;
}

/// Zigzag cipher encode with n rails.
pub fn str_zigzag(handle: ?*StzString, rails: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    const n: usize = if (rails >= 2) @intCast(rails) else {
        result.data.appendSlice(gpa, src) catch { setError(.out_of_memory); };
        return result;
    };
    if (src.len == 0) return result;

    // Build rail contents
    const cycle = 2 * (n - 1);
    var rail: usize = 0;
    while (rail < n) : (rail += 1) {
        var i: usize = 0;
        while (i < src.len) {
            // Determine which rail this index belongs to
            const pos_in_cycle = i % cycle;
            const r = if (pos_in_cycle < n) pos_in_cycle else cycle - pos_in_cycle;
            if (r == rail) {
                result.data.appendSlice(gpa, &[_]u8{src[i]}) catch break;
            }
            i += 1;
        }
    }
    return result;
}

// ─── Cryptographic Hashes ───

const crypto_hex = "0123456789abcdef";

fn hexDigest(comptime digest_len: usize, digest: *const [digest_len]u8) ?*StzString {
    var buf: [digest_len * 2]u8 = undefined;
    for (digest, 0..) |byte, i| {
        buf[i * 2] = crypto_hex[byte >> 4];
        buf[i * 2 + 1] = crypto_hex[byte & 0x0f];
    }
    return str_from(&buf, digest_len * 2);
}

pub fn str_sha256(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    var digest: [std.crypto.hash.sha2.Sha256.digest_length]u8 = undefined;
    std.crypto.hash.sha2.Sha256.hash(buf, &digest, .{});
    return hexDigest(std.crypto.hash.sha2.Sha256.digest_length, &digest);
}

pub fn str_md5(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    var digest: [std.crypto.hash.Md5.digest_length]u8 = undefined;
    std.crypto.hash.Md5.hash(buf, &digest, .{});
    return hexDigest(std.crypto.hash.Md5.digest_length, &digest);
}

pub fn str_blake3(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    var digest: [std.crypto.hash.Blake3.digest_length]u8 = undefined;
    std.crypto.hash.Blake3.hash(buf, &digest, .{});
    return hexDigest(std.crypto.hash.Blake3.digest_length, &digest);
}

pub fn str_hmac_sha256(handle: StzStringHandle, key_ptr: [*c]const u8, key_len: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (key_ptr == null or key_len <= 0) return null;
    const klen: usize = @intCast(key_len);
    const key = key_ptr[0..klen];
    var mac: [std.crypto.auth.hmac.sha2.HmacSha256.mac_length]u8 = undefined;
    std.crypto.auth.hmac.sha2.HmacSha256.create(&mac, buf, key);
    return hexDigest(std.crypto.auth.hmac.sha2.HmacSha256.mac_length, &mac);
}

pub fn str_sha256_raw(handle: StzStringHandle, out_buf: [*c]u8, out_len: usize) callconv(.c) usize {
    const s = handle orelse return 0;
    const buf = s.slice();
    const dlen = std.crypto.hash.sha2.Sha256.digest_length;
    if (out_len < dlen) return 0;
    var digest: [dlen]u8 = undefined;
    std.crypto.hash.sha2.Sha256.hash(buf, &digest, .{});
    @memcpy(out_buf[0..dlen], &digest);
    return dlen;
}

// ─── Hash & Entropy ───

/// FNV-1a hash of the string bytes.
pub fn str_hash(handle: StzStringHandle) callconv(.c) u64 {
    const s = handle orelse return 0;
    const buf = s.slice();
    var hash: u64 = 0xcbf29ce484222325; // FNV offset basis
    for (buf) |byte| {
        hash ^= byte;
        hash *%= 0x100000001b3; // FNV prime
    }
    return hash;
}

/// Shannon entropy * 100 (integer, to avoid floating point in C API). 0 for empty.
pub fn str_entropy(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;

    // Count frequencies
    var freq: [256]u32 = [_]u32{0} ** 256;
    for (src) |c| {
        freq[c] += 1;
    }

    // Calculate entropy: -sum(p * log2(p))
    var entropy_x1000: i64 = 0;
    const len_f: f64 = @floatFromInt(src.len);
    for (freq) |f| {
        if (f > 0) {
            const p: f64 = @as(f64, @floatFromInt(f)) / len_f;
            const log2p: f64 = @log2(p);
            entropy_x1000 -= @intFromFloat(p * log2p * 1000.0);
        }
    }
    // Return entropy * 100 (divide by 10 from *1000)
    return @intCast(@divTrunc(entropy_x1000, 10));
}

// ─── Tests ───

const testing = std.testing;

test "url encode/decode round-trip" {
    const s = str_from("hello world!", 12) orelse return error.SkipZigTest;
    defer core.str_free(s);
    const encoded = str_url_encode(s) orelse return error.SkipZigTest;
    defer core.str_free(encoded);
    try testing.expectEqualStrings("hello%20world%21", encoded.slice());
    const decoded = str_url_decode(encoded) orelse return error.SkipZigTest;
    defer core.str_free(decoded);
    try testing.expectEqualStrings("hello world!", decoded.slice());
}

test "hex encode/decode round-trip" {
    const s = str_from("AB", 2) orelse return error.SkipZigTest;
    defer core.str_free(s);
    const hex = str_encode_hex(s) orelse return error.SkipZigTest;
    defer core.str_free(hex);
    try testing.expectEqualStrings("4142", hex.slice());
    const back = str_decode_hex(hex) orelse return error.SkipZigTest;
    defer core.str_free(back);
    try testing.expectEqualStrings("AB", back.slice());
}

test "to_hex/from_hex aliases" {
    const s = str_from("Hi", 2) orelse return error.SkipZigTest;
    defer core.str_free(s);
    const hex = str_to_hex(s) orelse return error.SkipZigTest;
    defer core.str_free(hex);
    try testing.expectEqualStrings("4869", hex.slice());
    const back = str_from_hex(hex) orelse return error.SkipZigTest;
    defer core.str_free(back);
    try testing.expectEqualStrings("Hi", back.slice());
}

test "base64 encode/decode round-trip" {
    const s = str_from("Hello", 5) orelse return error.SkipZigTest;
    defer core.str_free(s);
    const b64 = str_to_base64(s) orelse return error.SkipZigTest;
    defer core.str_free(b64);
    try testing.expectEqualStrings("SGVsbG8=", b64.slice());
    const back = str_from_base64(b64) orelse return error.SkipZigTest;
    defer core.str_free(back);
    try testing.expectEqualStrings("Hello", back.slice());
}

test "binary encode/decode round-trip" {
    const s = str_from("A", 1) orelse return error.SkipZigTest;
    defer core.str_free(s);
    const bin = str_to_binary(s) orelse return error.SkipZigTest;
    defer core.str_free(bin);
    try testing.expectEqualStrings("01000001", bin.slice());
    const back = str_from_binary(bin) orelse return error.SkipZigTest;
    defer core.str_free(back);
    try testing.expectEqualStrings("A", back.slice());
}

test "html escape/unescape round-trip" {
    const s = str_from("<b>A&B</b>", 10) orelse return error.SkipZigTest;
    defer core.str_free(s);
    const escaped = str_escape_html(s) orelse return error.SkipZigTest;
    defer core.str_free(escaped);
    try testing.expectEqualStrings("&lt;b&gt;A&amp;B&lt;/b&gt;", escaped.slice());
    const back = str_unescape_html(escaped) orelse return error.SkipZigTest;
    defer core.str_free(back);
    try testing.expectEqualStrings("<b>A&B</b>", back.slice());
}

test "morse code" {
    const s = str_from("SOS", 3) orelse return error.SkipZigTest;
    defer core.str_free(s);
    const morse = str_to_morse(s) orelse return error.SkipZigTest;
    defer core.str_free(morse);
    try testing.expectEqualStrings("... --- ...", morse.slice());
}

test "caesar cipher" {
    const s = str_from("abc", 3) orelse return error.SkipZigTest;
    defer core.str_free(s);
    const enc = str_caesar(s, 3) orelse return error.SkipZigTest;
    defer core.str_free(enc);
    try testing.expectEqualStrings("def", enc.slice());
}

test "xor cipher round-trip" {
    const s = str_from("Hello", 5) orelse return error.SkipZigTest;
    defer core.str_free(s);
    const enc = str_xor_cipher(s, 42) orelse return error.SkipZigTest;
    defer core.str_free(enc);
    const dec = str_xor_cipher(enc, 42) orelse return error.SkipZigTest;
    defer core.str_free(dec);
    try testing.expectEqualStrings("Hello", dec.slice());
}

test "atbash cipher" {
    const s = str_from("abc", 3) orelse return error.SkipZigTest;
    defer core.str_free(s);
    const enc = str_atbash(s) orelse return error.SkipZigTest;
    defer core.str_free(enc);
    try testing.expectEqualStrings("zyx", enc.slice());
}

test "rot47 round-trip" {
    const s = str_from("Hello!", 6) orelse return error.SkipZigTest;
    defer core.str_free(s);
    const enc = str_rot47(s) orelse return error.SkipZigTest;
    defer core.str_free(enc);
    const dec = str_rot47(enc) orelse return error.SkipZigTest;
    defer core.str_free(dec);
    try testing.expectEqualStrings("Hello!", dec.slice());
}

test "vigenere encrypt" {
    const s = str_from("hello", 5) orelse return error.SkipZigTest;
    defer core.str_free(s);
    const key = "key";
    const enc = str_vigenere_encrypt(s, key.ptr, 3) orelse return error.SkipZigTest;
    defer core.str_free(enc);
    try testing.expectEqualStrings("rijvs", enc.slice());
}

test "zigzag cipher" {
    const s = str_from("HELLO", 5) orelse return error.SkipZigTest;
    defer core.str_free(s);
    const enc = str_zigzag(s, 3) orelse return error.SkipZigTest;
    defer core.str_free(enc);
    // Rail 0: H, O ; Rail 1: E, L ; Rail 2: L -> "HOELL"
    try testing.expectEqualStrings("HOELL", enc.slice());
}

test "hash non-zero" {
    const s = str_from("test", 4) orelse return error.SkipZigTest;
    defer core.str_free(s);
    const h = str_hash(s);
    try testing.expect(h != 0);
}

test "entropy non-zero for mixed content" {
    const s = str_from("abcdef", 6) orelse return error.SkipZigTest;
    defer core.str_free(s);
    const e = str_entropy(s);
    try testing.expect(e > 0);
}

test "quote/unquote round-trip" {
    const s = str_from("hello", 5) orelse return error.SkipZigTest;
    defer core.str_free(s);
    const quoted = str_quote(s, '"') orelse return error.SkipZigTest;
    defer core.str_free(quoted);
    try testing.expectEqualStrings("\"hello\"", quoted.slice());
    const unquoted = str_unquote(quoted) orelse return error.SkipZigTest;
    defer core.str_free(unquoted);
    try testing.expectEqualStrings("hello", unquoted.slice());
}

test "csv field escaping" {
    const s = str_from("a,b", 3) orelse return error.SkipZigTest;
    defer core.str_free(s);
    const csv = str_to_csv_field(s) orelse return error.SkipZigTest;
    defer core.str_free(csv);
    try testing.expectEqualStrings("\"a,b\"", csv.slice());
}

test "sha256 known vector" {
    const s = str_from("hello", 5) orelse return error.SkipZigTest;
    defer core.str_free(s);
    const h = str_sha256(s) orelse return error.SkipZigTest;
    defer core.str_free(h);
    try testing.expectEqualStrings("2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824", h.slice());
}

test "md5 known vector" {
    const s = str_from("hello", 5) orelse return error.SkipZigTest;
    defer core.str_free(s);
    const h = str_md5(s) orelse return error.SkipZigTest;
    defer core.str_free(h);
    try testing.expectEqualStrings("5d41402abc4b2a76b9719d911017c592", h.slice());
}

test "blake3 produces 64-char hex" {
    const s = str_from("hello", 5) orelse return error.SkipZigTest;
    defer core.str_free(s);
    const h = str_blake3(s) orelse return error.SkipZigTest;
    defer core.str_free(h);
    try testing.expect(h.slice().len == 64);
}

test "hmac-sha256 known vector" {
    const s = str_from("hello", 5) orelse return error.SkipZigTest;
    defer core.str_free(s);
    const h = str_hmac_sha256(s, "key", 3) orelse return error.SkipZigTest;
    defer core.str_free(h);
    try testing.expect(h.slice().len == 64);
}

test "sha256 empty string" {
    const s = str_from("", 0) orelse return error.SkipZigTest;
    defer core.str_free(s);
    const h = str_sha256(s) orelse return error.SkipZigTest;
    defer core.str_free(h);
    try testing.expectEqualStrings("e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855", h.slice());
}

test "sha256_raw returns 32 bytes" {
    const s = str_from("test", 4) orelse return error.SkipZigTest;
    defer core.str_free(s);
    var buf: [32]u8 = undefined;
    const n = str_sha256_raw(s, &buf, 32);
    try testing.expect(n == 32);
}
