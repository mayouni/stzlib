const std = @import("std");

// ── CRC-32 ───────────────────────────────────────────────────

pub fn compress_crc32(ptr: [*]const u8, len: usize) callconv(.c) u32 {
    if (len == 0) return 0;
    return std.hash.Crc32.hash(ptr[0..len]);
}

// ── Adler-32 ─────────────────────────────────────────────────

pub fn compress_adler32(ptr: [*]const u8, len: usize) callconv(.c) u32 {
    if (len == 0) return 1;
    const data = ptr[0..len];
    var a: u32 = 1;
    var b: u32 = 0;
    for (data) |byte| {
        a = (a + byte) % 65521;
        b = (b + a) % 65521;
    }
    return (b << 16) | a;
}

// ── Run-Length Encoding ──────────────────────────────────────

pub fn compress_rle_encode(ptr: [*]const u8, len: usize, out: [*]u8, max: usize) callconv(.c) i32 {
    if (len == 0) return 0;
    const data = ptr[0..len];
    var pos: usize = 0;
    var i: usize = 0;
    while (i < data.len) {
        const ch = data[i];
        var count: usize = 1;
        while (i + count < data.len and data[i + count] == ch and count < 255) {
            count += 1;
        }
        if (pos + 2 > max) return -1;
        out[pos] = @intCast(count);
        out[pos + 1] = ch;
        pos += 2;
        i += count;
    }
    return @intCast(pos);
}

pub fn compress_rle_decode(ptr: [*]const u8, len: usize, out: [*]u8, max: usize) callconv(.c) i32 {
    if (len == 0) return 0;
    if (len % 2 != 0) return -1;
    const data = ptr[0..len];
    var pos: usize = 0;
    var i: usize = 0;
    while (i + 1 < data.len) {
        const count: usize = data[i];
        const ch = data[i + 1];
        if (pos + count > max) return -1;
        @memset(out[pos .. pos + count], ch);
        pos += count;
        i += 2;
    }
    return @intCast(pos);
}

// ── LZ77-style Simple Compression ───────────────────────────
// A simple byte-level compression using back-references.
// Format: 0x00 <literal byte> | <offset_hi> <offset_lo> <length>

pub fn compress_simple(ptr: [*]const u8, len: usize, out: [*]u8, max: usize) callconv(.c) i32 {
    if (len == 0) return 0;
    const data = ptr[0..len];
    var pos: usize = 0;
    var i: usize = 0;
    while (i < data.len) {
        var best_offset: usize = 0;
        var best_len: usize = 0;
        const search_start = if (i > 255) i - 255 else 0;
        var s = search_start;
        while (s < i) : (s += 1) {
            var ml: usize = 0;
            while (i + ml < data.len and ml < 255 and data[s + ml] == data[i + ml]) {
                ml += 1;
            }
            if (ml >= 3 and ml > best_len) {
                best_offset = i - s;
                best_len = ml;
            }
        }
        if (best_len >= 3) {
            if (pos + 3 > max) return -1;
            out[pos] = @intCast(best_offset);
            out[pos + 1] = @intCast(best_len);
            out[pos + 2] = 0xFF;
            pos += 3;
            i += best_len;
        } else {
            if (pos + 2 > max) return -1;
            out[pos] = 0x00;
            out[pos + 1] = data[i];
            pos += 2;
            i += 1;
        }
    }
    return @intCast(pos);
}

pub fn compress_simple_decompress(ptr: [*]const u8, len: usize, out: [*]u8, max: usize) callconv(.c) i32 {
    if (len == 0) return 0;
    const data = ptr[0..len];
    var pos: usize = 0;
    var i: usize = 0;
    while (i < data.len) {
        if (i + 1 >= data.len) return -1;
        if (data[i] == 0x00) {
            if (pos >= max) return -1;
            out[pos] = data[i + 1];
            pos += 1;
            i += 2;
        } else {
            if (i + 2 >= data.len) return -1;
            if (data[i + 2] != 0xFF) return -2;
            const offset: usize = data[i];
            const length: usize = data[i + 1];
            if (offset > pos) return -3;
            const src_start = pos - offset;
            for (0..length) |j| {
                if (pos >= max) return -1;
                out[pos] = out[src_start + j];
                pos += 1;
            }
            i += 3;
        }
    }
    return @intCast(pos);
}

// ── C ABI exports ────────────────────────────────────────────

pub export fn stz_compress_crc32(p: [*]const u8, l: usize) callconv(.c) u32 { return compress_crc32(p, l); }
pub export fn stz_compress_adler32(p: [*]const u8, l: usize) callconv(.c) u32 { return compress_adler32(p, l); }
pub export fn stz_compress_rle_encode(p: [*]const u8, l: usize, o: [*]u8, m: usize) callconv(.c) i32 { return compress_rle_encode(p, l, o, m); }
pub export fn stz_compress_rle_decode(p: [*]const u8, l: usize, o: [*]u8, m: usize) callconv(.c) i32 { return compress_rle_decode(p, l, o, m); }
pub export fn stz_compress_simple(p: [*]const u8, l: usize, o: [*]u8, m: usize) callconv(.c) i32 { return compress_simple(p, l, o, m); }
pub export fn stz_compress_simple_decompress(p: [*]const u8, l: usize, o: [*]u8, m: usize) callconv(.c) i32 { return compress_simple_decompress(p, l, o, m); }

// ── Tests ────────────────────────────────────────────────────

test "compress: crc32" {
    const data = "Hello";
    const crc = compress_crc32(data.ptr, data.len);
    try std.testing.expect(crc != 0);
    try std.testing.expectEqual(compress_crc32(data.ptr, data.len), crc);
}

test "compress: crc32 different data" {
    const a = "Hello";
    const b = "World";
    try std.testing.expect(compress_crc32(a.ptr, a.len) != compress_crc32(b.ptr, b.len));
}

test "compress: adler32" {
    const data = "Hello";
    const adler = compress_adler32(data.ptr, data.len);
    try std.testing.expect(adler != 0);
    try std.testing.expectEqual(@as(u32, 1), compress_adler32("".ptr, 0));
}

test "compress: rle roundtrip" {
    var enc: [256]u8 = undefined;
    var dec: [256]u8 = undefined;
    const data = "AAABBBCCDDDDDD";
    const enc_len = compress_rle_encode(data.ptr, data.len, &enc, 256);
    try std.testing.expect(enc_len > 0);
    const dec_len = compress_rle_decode(&enc, @intCast(enc_len), &dec, 256);
    try std.testing.expectEqualStrings(data, dec[0..@intCast(dec_len)]);
}

test "compress: rle single chars" {
    var enc: [64]u8 = undefined;
    var dec: [64]u8 = undefined;
    const data = "ABC";
    const enc_len = compress_rle_encode(data.ptr, data.len, &enc, 64);
    try std.testing.expectEqual(@as(i32, 6), enc_len);
    const dec_len = compress_rle_decode(&enc, @intCast(enc_len), &dec, 64);
    try std.testing.expectEqualStrings(data, dec[0..@intCast(dec_len)]);
}

test "compress: simple roundtrip" {
    var comp: [4096]u8 = undefined;
    var decomp: [4096]u8 = undefined;
    const data = "ABCABCABCABCDEFDEFDEFDEF";
    const comp_len = compress_simple(data.ptr, data.len, &comp, 4096);
    try std.testing.expect(comp_len > 0);
    const decomp_len = compress_simple_decompress(&comp, @intCast(comp_len), &decomp, 4096);
    try std.testing.expectEqualStrings(data, decomp[0..@intCast(decomp_len)]);
}

test "compress: simple with no repetition" {
    var comp: [256]u8 = undefined;
    var decomp: [256]u8 = undefined;
    const data = "ABCDE";
    const comp_len = compress_simple(data.ptr, data.len, &comp, 256);
    try std.testing.expect(comp_len > 0);
    const decomp_len = compress_simple_decompress(&comp, @intCast(comp_len), &decomp, 256);
    try std.testing.expectEqualStrings(data, decomp[0..@intCast(decomp_len)]);
}

test "compress: empty input" {
    var buf: [64]u8 = undefined;
    try std.testing.expectEqual(@as(i32, 0), compress_rle_encode("".ptr, 0, &buf, 64));
    try std.testing.expectEqual(@as(i32, 0), compress_rle_decode("".ptr, 0, &buf, 64));
    try std.testing.expectEqual(@as(i32, 0), compress_simple("".ptr, 0, &buf, 64));
}
