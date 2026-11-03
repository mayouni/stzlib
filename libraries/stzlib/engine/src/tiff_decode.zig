//! tiff_decode.zig -- baseline TIFF into 8-bit pixels (IM9b, slice 2). Native: stb_image does not read TIFF
//! and a TIFF library is a large dependency for what a phone, a scanner or a fax is asked to hand over.
//!
//! READ: the first image of the file, striped, one plane (PlanarConfiguration 1), 8 bits per sample; compression
//! none, PackBits, LZW and Deflate (both numbers it goes by); the horizontal predictor; photometric
//! WhiteIsZero, BlackIsZero, RGB and palette; 1 (gray), 2 (gray + alpha), 3 (RGB) or 4 (RGBA) samples. Little and
//! big endian. The result has 1, 3 or 4 channels, as every image of the plane (gray + alpha widens to RGBA).
//!
//! REFUSED BY NAME, never guessed: tiles, other bit depths (1, 4, 16, 32), planar separate, CMYK, YCbCr, float,
//! JPEG-in-TIFF and the fax codecs. A refusal says what the file has, so a reader knows what to convert.
//!
//! The ORACLE is Pillow (libtiff) writing every variant: the guard is pixel-exact (lossless, no tolerance).

const std = @import("std");
const z = @cImport({
    @cInclude("zlib.h");
});

const alloc = std.heap.c_allocator;

pub const Decoded = struct { w: u32, h: u32, c: u8, px: []u8 };

var err_buf: [200]u8 = undefined;
var err_len: usize = 0;

pub fn lastError() []const u8 {
    return err_buf[0..err_len];
}

fn fail(comptime fmt: []const u8, args: anytype) ?Decoded {
    const s = std.fmt.bufPrint(&err_buf, fmt, args) catch "tiff: error text too long";
    err_len = s.len;
    return null;
}

pub fn isTiff(b: []const u8) bool {
    return b.len >= 8 and ((b[0] == 'I' and b[1] == 'I' and b[2] == 42 and b[3] == 0) or
        (b[0] == 'M' and b[1] == 'M' and b[2] == 0 and b[3] == 42));
}

fn rd16(t: []const u8, o: usize, le: bool) u16 {
    return std.mem.readInt(u16, t[o..][0..2], if (le) .little else .big);
}

fn rd32(t: []const u8, o: usize, le: bool) u32 {
    return std.mem.readInt(u32, t[o..][0..4], if (le) .little else .big);
}

/// One directory entry's values: where they start in the file, how many, and of what type.
const Entry = struct { typ: u16, count: u32, vo: usize };

fn entryAt(t: []const u8, e: usize, le: bool) ?Entry {
    const typ = rd16(t, e + 2, le);
    const count = rd32(t, e + 4, le);
    const sz: usize = switch (typ) {
        1, 2, 6, 7 => 1,
        3, 8 => 2,
        4, 9, 11 => 4,
        else => return null,
    };
    const total: usize = @as(usize, count) * sz;
    const vo: usize = if (total <= 4) e + 8 else rd32(t, e + 8, le);
    if (vo + total > t.len) return null;
    return .{ .typ = typ, .count = count, .vo = vo };
}

fn val(t: []const u8, en: Entry, i: usize, le: bool) u32 {
    return switch (en.typ) {
        3 => rd16(t, en.vo + 2 * i, le),
        4 => rd32(t, en.vo + 4 * i, le),
        else => t[en.vo + i],
    };
}

// ---- the codecs: each fills exactly `dst` (a strip's rows) or says it could not

fn packBits(src: []const u8, dst: []u8) bool {
    var i: usize = 0;
    var o: usize = 0;
    while (o < dst.len) {
        if (i >= src.len) return false;
        const n: i8 = @bitCast(src[i]);
        i += 1;
        if (n >= 0) {
            const run: usize = @as(usize, @intCast(n)) + 1;
            if (i + run > src.len or o + run > dst.len) return false;
            @memcpy(dst[o..][0..run], src[i..][0..run]);
            i += run;
            o += run;
        } else if (n != -128) {
            if (i >= src.len) return false;
            const run: usize = @as(usize, @intCast(1 - @as(i16, n)));
            if (o + run > dst.len) return false;
            @memset(dst[o..][0..run], src[i]);
            i += 1;
            o += run;
        }
    }
    return true;
}

/// The string of a code, written last character first (the first character ends up at out[n - 1]).
fn expand(code: usize, prefix: *const [4096]u16, suffix: *const [4096]u8, out: []u8) usize {
    var c = code;
    var n: usize = 0;
    while (c >= 258) : (c = prefix[c]) {
        out[n] = suffix[c];
        n += 1;
    }
    out[n] = @intCast(c);
    return n + 1;
}

/// TIFF LZW: most significant bit first, codes of 9 to 12 bits, 256 clears, 257 ends, and the width grows one code
/// EARLY (at 511, 1023, 2047 entries) -- the one place TIFF differs from GIF's LZW.
fn lzw(src: []const u8, dst: []u8) bool {
    var prefix: [4096]u16 = undefined;
    var suffix: [4096]u8 = undefined;
    var stack: [4100]u8 = undefined;
    var next: usize = 258;
    var bits: u5 = 9;
    var acc: u32 = 0;
    var nacc: u5 = 0;
    var si: usize = 0;
    var o: usize = 0;
    var prev: i32 = -1;
    while (true) {
        while (nacc < bits) {
            if (si >= src.len) return o == dst.len;
            acc = ((acc << 8) | src[si]) & 0xffffff;
            si += 1;
            nacc += 8;
        }
        const code: usize = (acc >> (nacc - bits)) & ((@as(u32, 1) << bits) - 1);
        nacc -= bits;
        if (code == 257) break;
        if (code == 256) {
            next = 258;
            bits = 9;
            prev = -1;
            continue;
        }
        var sp: usize = 0;
        if (code < next and !(code >= 258 and prev < 0)) {
            sp = expand(code, &prefix, &suffix, &stack);
        } else if (code == next and prev >= 0) {
            // KwKwK: the string of prev followed by its own first character
            const m = expand(@intCast(prev), &prefix, &suffix, stack[1..]);
            stack[0] = stack[m];
            sp = m + 1;
        } else {
            return false;
        }
        if (o + sp > dst.len) return false;
        var q: usize = sp;
        while (q > 0) {
            q -= 1;
            dst[o] = stack[q];
            o += 1;
        }
        if (prev >= 0 and next < 4096) {
            prefix[next] = @intCast(prev);
            suffix[next] = stack[sp - 1];
            next += 1;
            if (next == 511) {
                bits = 10;
            } else if (next == 1023) {
                bits = 11;
            } else if (next == 2047) {
                bits = 12;
            }
        }
        prev = @intCast(code);
        if (o == dst.len) return true;
    }
    return o == dst.len;
}

fn deflate(src: []const u8, dst: []u8) bool {
    var dlen: z.uLongf = @intCast(dst.len);
    const r = z.uncompress(dst.ptr, &dlen, src.ptr, @intCast(src.len));
    return r == z.Z_OK and dlen == dst.len;
}

pub fn decode(t: []const u8) ?Decoded {
    if (!isTiff(t)) return fail("tiff: not a TIFF", .{});
    const le = t[0] == 'I';
    const ifd: usize = rd32(t, 4, le);
    if (ifd + 2 > t.len) return fail("tiff: the directory is outside the file", .{});
    const n: usize = rd16(t, ifd, le);

    var w: u32 = 0;
    var h: u32 = 0;
    var spp: u32 = 1;
    var bps: u32 = 1;
    var comp: u32 = 1;
    var photo: u32 = 255;
    var planar: u32 = 1;
    var predictor: u32 = 1;
    var rps: u32 = 0;
    var offsets: ?Entry = null;
    var counts: ?Entry = null;
    var cmap: ?Entry = null;
    var extra: u32 = 0;
    var tiled = false;
    var sample_fmt: u32 = 1;
    var k: usize = 0;
    while (k < n) : (k += 1) {
        const e = ifd + 2 + 12 * k;
        if (e + 12 > t.len) return fail("tiff: the directory is cut short", .{});
        const tag = rd16(t, e, le);
        const en = entryAt(t, e, le) orelse continue;
        switch (tag) {
            256 => w = val(t, en, 0, le),
            257 => h = val(t, en, 0, le),
            258 => {
                bps = val(t, en, 0, le);
                var j: usize = 1;
                while (j < en.count) : (j += 1) {
                    if (val(t, en, j, le) != bps) return fail("tiff: samples of different sizes are not read", .{});
                }
            },
            259 => comp = val(t, en, 0, le),
            262 => photo = val(t, en, 0, le),
            273 => offsets = en,
            277 => spp = val(t, en, 0, le),
            278 => rps = val(t, en, 0, le),
            279 => counts = en,
            284 => planar = val(t, en, 0, le),
            317 => predictor = val(t, en, 0, le),
            320 => cmap = en,
            338 => extra = en.count,
            322, 323, 324, 325 => tiled = true,
            339 => sample_fmt = val(t, en, 0, le),
            else => {},
        }
    }

    if (w == 0 or h == 0) return fail("tiff: the picture has no size", .{});
    if (tiled) return fail("tiff: tiles are not read (this file is tiled); convert it to strips", .{});
    if (planar != 1) return fail("tiff: separate colour planes are not read", .{});
    if (sample_fmt != 1) return fail("tiff: floating-point and signed samples are not read", .{});
    if (bps != 8) return fail("tiff: {d} bits per sample is not read (8 is)", .{bps});
    if (photo == 5) return fail("tiff: CMYK is not read", .{});
    if (photo == 6) return fail("tiff: YCbCr is not read", .{});
    if (photo != 0 and photo != 1 and photo != 2 and photo != 3) return fail("tiff: photometric interpretation {d} is not read", .{photo});
    if (comp != 1 and comp != 5 and comp != 8 and comp != 32946 and comp != 32773)
        return fail("tiff: compression {d} is not read (none, PackBits, LZW and Deflate are)", .{comp});
    if (photo == 3 and (spp != 1 or cmap == null)) return fail("tiff: a palette picture needs one sample and a colour map", .{});
    if ((photo == 0 or photo == 1) and spp != 1 and spp != 2) return fail("tiff: a gray picture with {d} samples is not read", .{spp});
    if (photo == 2 and spp != 3 and spp != 4) return fail("tiff: an RGB picture with {d} samples is not read", .{spp});
    if (@as(u64, w) * h * spp > (1 << 31)) return fail("tiff: the picture is too large", .{});
    const off_e = offsets orelse return fail("tiff: no strip offsets", .{});
    if (rps == 0 or rps > h) rps = h;
    const nstrips: usize = (h + rps - 1) / rps;
    if (off_e.count < nstrips) return fail("tiff: {d} strips declared, {d} offsets given", .{ nstrips, off_e.count });
    if (counts == null and nstrips > 1) return fail("tiff: no strip byte counts", .{});

    const rowbytes: usize = @as(usize, w) * spp;
    const raw = alloc.alloc(u8, rowbytes * h) catch return fail("tiff: out of memory", .{});
    var owned = true;
    defer if (owned) alloc.free(raw);

    var s: usize = 0;
    while (s < nstrips) : (s += 1) {
        const first: usize = s * rps;
        const rows: usize = @min(@as(usize, rps), h - first);
        const want: usize = rows * rowbytes;
        const off: usize = val(t, off_e, s, le);
        var cnt: usize = if (counts) |c| val(t, c, s, le) else t.len - @min(off, t.len);
        if (off > t.len) return fail("tiff: strip {d} starts outside the file", .{s});
        if (off + cnt > t.len) cnt = t.len - off;
        const src = t[off..][0..cnt];
        const dst = raw[first * rowbytes ..][0..want];
        const ok = switch (comp) {
            1 => blk: {
                if (cnt < want) break :blk false;
                @memcpy(dst, src[0..want]);
                break :blk true;
            },
            32773 => packBits(src, dst),
            5 => lzw(src, dst),
            else => deflate(src, dst),
        };
        if (!ok) return fail("tiff: strip {d} could not be decompressed (compression {d})", .{ s, comp });
        if (predictor == 2 and comp != 1) {
            var r: usize = 0;
            while (r < rows) : (r += 1) {
                const row = dst[r * rowbytes ..][0..rowbytes];
                var i: usize = spp;
                while (i < rowbytes) : (i += 1) row[i] +%= row[i - spp];
            }
        } else if (predictor != 1 and predictor != 2) {
            return fail("tiff: predictor {d} is not read", .{predictor});
        }
    }

    // to the plane's own layout: 1, 3 or 4 channels
    const count: usize = @as(usize, w) * h;
    if (photo == 3) {
        const cm = cmap.?;
        if (cm.count < 768) return fail("tiff: the colour map is short", .{});
        const rgb = alloc.alloc(u8, count * 3) catch return fail("tiff: out of memory", .{});
        var pi: usize = 0;
        while (pi < count) : (pi += 1) {
            const idx: usize = raw[pi];
            rgb[pi * 3] = @intCast(val(t, cm, idx, le) >> 8);
            rgb[pi * 3 + 1] = @intCast(val(t, cm, 256 + idx, le) >> 8);
            rgb[pi * 3 + 2] = @intCast(val(t, cm, 512 + idx, le) >> 8);
        }
        owned = false;
        alloc.free(raw);
        return .{ .w = w, .h = h, .c = 3, .px = rgb };
    }
    var c: u8 = @intCast(spp);
    var out = raw;
    if (spp == 2) {
        // gray + alpha widens to RGBA
        const wide = alloc.alloc(u8, count * 4) catch return fail("tiff: out of memory", .{});
        var i: usize = 0;
        while (i < count) : (i += 1) {
            const g = raw[i * 2];
            wide[i * 4] = g;
            wide[i * 4 + 1] = g;
            wide[i * 4 + 2] = g;
            wide[i * 4 + 3] = raw[i * 2 + 1];
        }
        owned = false;
        alloc.free(raw);
        out = wide;
        c = 4;
    }
    if (photo == 0) {
        // WhiteIsZero: 0 is white; the plane's gray is 0 = black
        const stride: usize = c;
        var i: usize = 0;
        while (i < count) : (i += 1) {
            const base = i * stride;
            if (c == 4) {
                out[base] = 255 - out[base];
                out[base + 1] = 255 - out[base + 1];
                out[base + 2] = 255 - out[base + 2];
            } else {
                out[base] = 255 - out[base];
            }
        }
    }
    owned = false;
    return .{ .w = w, .h = h, .c = c, .px = out };
}
