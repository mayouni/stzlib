const std = @import("std");

// ── Base64 ─────────────────────────────────────────────────────

pub fn codec_base64_encode(ptr: [*]const u8, len: usize, out: [*]u8, max: usize) callconv(.c) i32 {
    if (len == 0) return 0;
    const data = ptr[0..len];
    const needed = std.base64.standard.Encoder.calcSize(data.len);
    if (needed > max) return -1;
    const result = std.base64.standard.Encoder.encode(out[0..needed], data);
    _ = result;
    return @intCast(needed);
}

pub fn codec_base64_decode(ptr: [*]const u8, len: usize, out: [*]u8, max: usize) callconv(.c) i32 {
    if (len == 0) return 0;
    const data = ptr[0..len];
    const needed = std.base64.standard.Decoder.calcSizeUpperBound(data.len) catch return -1;
    if (needed > max) return -1;
    std.base64.standard.Decoder.decode(out[0..needed], data) catch return -2;
    return @intCast(needed);
}

pub fn codec_base64_encode_size(len: usize) callconv(.c) i32 {
    return @intCast(std.base64.standard.Encoder.calcSize(len));
}

// ── Hex ────────────────────────────────────────────────────────

pub fn codec_hex_encode(ptr: [*]const u8, len: usize, out: [*]u8, max: usize) callconv(.c) i32 {
    if (len == 0) return 0;
    const needed = len * 2;
    if (needed > max) return -1;
    const hex = "0123456789abcdef";
    for (0..len) |i| {
        out[i * 2] = hex[ptr[i] >> 4];
        out[i * 2 + 1] = hex[ptr[i] & 0x0f];
    }
    return @intCast(needed);
}

pub fn codec_hex_decode(ptr: [*]const u8, len: usize, out: [*]u8, max: usize) callconv(.c) i32 {
    if (len == 0) return 0;
    if (len % 2 != 0) return -1;
    const needed = len / 2;
    if (needed > max) return -1;
    for (0..needed) |i| {
        const hi = hexVal(ptr[i * 2]) orelse return -2;
        const lo = hexVal(ptr[i * 2 + 1]) orelse return -2;
        out[i] = (hi << 4) | lo;
    }
    return @intCast(needed);
}

fn hexVal(ch: u8) ?u8 {
    if (ch >= '0' and ch <= '9') return ch - '0';
    if (ch >= 'a' and ch <= 'f') return ch - 'a' + 10;
    if (ch >= 'A' and ch <= 'F') return ch - 'A' + 10;
    return null;
}

// ── URL encoding ───────────────────────────────────────────────

pub fn codec_url_encode(ptr: [*]const u8, len: usize, out: [*]u8, max: usize) callconv(.c) i32 {
    if (len == 0) return 0;
    const data = ptr[0..len];
    const hex = "0123456789ABCDEF";
    var pos: usize = 0;
    for (data) |ch| {
        if (isUrlSafe(ch)) {
            if (pos >= max) return -1;
            out[pos] = ch;
            pos += 1;
        } else {
            if (pos + 3 > max) return -1;
            out[pos] = '%';
            out[pos + 1] = hex[ch >> 4];
            out[pos + 2] = hex[ch & 0x0f];
            pos += 3;
        }
    }
    return @intCast(pos);
}

pub fn codec_url_decode(ptr: [*]const u8, len: usize, out: [*]u8, max: usize) callconv(.c) i32 {
    if (len == 0) return 0;
    const data = ptr[0..len];
    var pos: usize = 0;
    var i: usize = 0;
    while (i < data.len) {
        if (pos >= max) return -1;
        if (data[i] == '%' and i + 2 < data.len) {
            const hi = hexVal(data[i + 1]) orelse return -2;
            const lo = hexVal(data[i + 2]) orelse return -2;
            out[pos] = (hi << 4) | lo;
            pos += 1;
            i += 3;
        } else if (data[i] == '+') {
            out[pos] = ' ';
            pos += 1;
            i += 1;
        } else {
            out[pos] = data[i];
            pos += 1;
            i += 1;
        }
    }
    return @intCast(pos);
}

fn isUrlSafe(ch: u8) bool {
    return (ch >= 'A' and ch <= 'Z') or (ch >= 'a' and ch <= 'z') or
        (ch >= '0' and ch <= '9') or ch == '-' or ch == '_' or ch == '.' or ch == '~';
}

// ── ROT13 ──────────────────────────────────────────────────────

pub fn codec_rot13(ptr: [*]const u8, len: usize, out: [*]u8, max: usize) callconv(.c) i32 {
    if (len == 0) return 0;
    const n = @min(len, max);
    for (0..n) |i| {
        const ch = ptr[i];
        if (ch >= 'a' and ch <= 'z') {
            out[i] = ((ch - 'a' + 13) % 26) + 'a';
        } else if (ch >= 'A' and ch <= 'Z') {
            out[i] = ((ch - 'A' + 13) % 26) + 'A';
        } else {
            out[i] = ch;
        }
    }
    return @intCast(n);
}

// ── C ABI exports ──────────────────────────────────────────────

pub export fn stz_codec_base64_encode(p: [*]const u8, l: usize, o: [*]u8, m: usize) callconv(.c) i32 { return codec_base64_encode(p, l, o, m); }
pub export fn stz_codec_base64_decode(p: [*]const u8, l: usize, o: [*]u8, m: usize) callconv(.c) i32 { return codec_base64_decode(p, l, o, m); }
pub export fn stz_codec_base64_encode_size(l: usize) callconv(.c) i32 { return codec_base64_encode_size(l); }
pub export fn stz_codec_hex_encode(p: [*]const u8, l: usize, o: [*]u8, m: usize) callconv(.c) i32 { return codec_hex_encode(p, l, o, m); }
pub export fn stz_codec_hex_decode(p: [*]const u8, l: usize, o: [*]u8, m: usize) callconv(.c) i32 { return codec_hex_decode(p, l, o, m); }
pub export fn stz_codec_url_encode(p: [*]const u8, l: usize, o: [*]u8, m: usize) callconv(.c) i32 { return codec_url_encode(p, l, o, m); }
pub export fn stz_codec_url_decode(p: [*]const u8, l: usize, o: [*]u8, m: usize) callconv(.c) i32 { return codec_url_decode(p, l, o, m); }
pub export fn stz_codec_rot13(p: [*]const u8, l: usize, o: [*]u8, m: usize) callconv(.c) i32 { return codec_rot13(p, l, o, m); }

// ── Tests ──────────────────────────────────────────────────────

test "codec: base64 encode" {
    var buf: [256]u8 = undefined;
    const text = "Hello, World!";
    const len = codec_base64_encode(text.ptr, text.len, &buf, 256);
    try std.testing.expect(len > 0);
    try std.testing.expectEqualStrings("SGVsbG8sIFdvcmxkIQ==", buf[0..@intCast(len)]);
}

test "codec: base64 roundtrip" {
    var enc: [256]u8 = undefined;
    var dec: [256]u8 = undefined;
    const text = "Softanza Engine";
    const enc_len = codec_base64_encode(text.ptr, text.len, &enc, 256);
    const dec_len = codec_base64_decode(&enc, @intCast(enc_len), &dec, 256);
    try std.testing.expectEqualStrings(text, dec[0..@intCast(dec_len)]);
}

test "codec: hex encode" {
    var buf: [64]u8 = undefined;
    const data = "AB";
    const len = codec_hex_encode(data.ptr, data.len, &buf, 64);
    try std.testing.expectEqualStrings("4142", buf[0..@intCast(len)]);
}

test "codec: hex roundtrip" {
    var enc: [64]u8 = undefined;
    var dec: [64]u8 = undefined;
    const data = "Test";
    const enc_len = codec_hex_encode(data.ptr, data.len, &enc, 64);
    const dec_len = codec_hex_decode(&enc, @intCast(enc_len), &dec, 64);
    try std.testing.expectEqualStrings(data, dec[0..@intCast(dec_len)]);
}

test "codec: url encode" {
    var buf: [256]u8 = undefined;
    const text = "hello world&foo=bar";
    const len = codec_url_encode(text.ptr, text.len, &buf, 256);
    const result = buf[0..@intCast(len)];
    try std.testing.expect(std.mem.indexOf(u8, result, "%20") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "%26") != null);
}

test "codec: url roundtrip" {
    var enc: [256]u8 = undefined;
    var dec: [256]u8 = undefined;
    const text = "name=Mansour&city=Niamey";
    const enc_len = codec_url_encode(text.ptr, text.len, &enc, 256);
    const dec_len = codec_url_decode(&enc, @intCast(enc_len), &dec, 256);
    try std.testing.expectEqualStrings(text, dec[0..@intCast(dec_len)]);
}

test "codec: rot13" {
    var buf: [64]u8 = undefined;
    const text = "Hello";
    const len = codec_rot13(text.ptr, text.len, &buf, 64);
    try std.testing.expectEqualStrings("Uryyb", buf[0..@intCast(len)]);
}

test "codec: rot13 double is identity" {
    var buf1: [64]u8 = undefined;
    var buf2: [64]u8 = undefined;
    const text = "Softanza";
    const len1 = codec_rot13(text.ptr, text.len, &buf1, 64);
    const len2 = codec_rot13(&buf1, @intCast(len1), &buf2, 64);
    try std.testing.expectEqualStrings(text, buf2[0..@intCast(len2)]);
}
