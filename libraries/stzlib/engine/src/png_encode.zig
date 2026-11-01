//! png_encode.zig -- the engine's one PNG encoder (RGBA8 in, PNG bytes out).
//!
//! Moved out of gpu_render.zig on 2026-11-01 so a DLL without a GPU device can
//! write a PNG: stz_image (the image plane) and stz_gpu both import THIS file,
//! so there is one encoder and no copy to drift. gpu_render re-exports it, so
//! every existing caller is unchanged.
const std = @import("std");
const z = @cImport({
    @cInclude("zlib.h");
});
const alloc = std.heap.c_allocator;

// Pure Zig over the vendored zlib -- the GR0 spike's encoder, engine-resident.
// Filter 0 rows, one IDAT. Level 1 is the measured default (GR0: identical
// pixels, half the time of level 6); callers may pass 1..9.

fn be32(buf: []u8, v: u32) void {
    buf[0] = @intCast((v >> 24) & 0xff);
    buf[1] = @intCast((v >> 16) & 0xff);
    buf[2] = @intCast((v >> 8) & 0xff);
    buf[3] = @intCast(v & 0xff);
}

fn pngChunk(out: []u8, pos: usize, typ: *const [4]u8, data: []const u8) usize {
    be32(out[pos..][0..4], @intCast(data.len));
    @memcpy(out[pos + 4 ..][0..4], typ);
    @memcpy(out[pos + 8 ..][0..data.len], data);
    var crc: z.uLong = z.crc32(0, null, 0);
    crc = z.crc32(crc, out[pos + 4 ..].ptr, @intCast(4 + data.len));
    be32(out[pos + 8 + data.len ..][0..4], @intCast(crc));
    return pos + 12 + data.len;
}

// WHAT A RENDERER OWES THE FILE IT WRITES.
//
// Central re-encoded a 594 KB diagram to 103 KB and handed over the method.
// Its picture was large because something upstream had been through a lossy
// step and left 16,414 distinct colours in a drawing that has about twelve:
// PNG compresses RUNS, and noise destroys runs. Its remedy was to quantise.
//
// THIS PLANE'S ANSWER IS DIFFERENT, AND THE DIFFERENCE IS THE POINT. There is
// no lossy upstream here. This encoder is handed the exact pixels the renderer
// drew, so quantising would INVENT loss where none exists -- it would be this
// library damaging its own output to fix somebody else's problem. What a
// renderer owes its file is exactness, and then not spending bytes on defaults
// it is in a position to know are wrong.
//
// Two things it was in a position to know and did not use:
//
//   1. THE FILTER. Every row was written with filter None. PNG's whole
//      compression story is that a row is usually cheaper as a DIFFERENCE
//      from its neighbours, and the standard remedy is per-row selection by
//      minimum sum of absolute differences (PNG spec 12.8). Lossless, always
//      applicable, and it costs one extra pass over the rows.
//
//   2. THE COLOUR TYPE. Colour type 6 -- 8-bit RGBA -- regardless of what was
//      drawn. A canvas that drew line art KNOWS its colours; it never has to
//      infer a palette the way an external optimiser does. Where the image
//      genuinely holds 256 distinct RGBA values or fewer, indexed colour is
//      EXACT: every pixel keeps its own colour, and the file carries one byte
//      per pixel instead of four. Where it holds more, this says so and stays
//      RGBA rather than quantising.
//
// Both are lossless, so rule 3 of Central's method -- decode your own output
// back and diff it -- becomes an assertion rather than a distribution: the
// guard demands byte-for-byte equality with the input, and would catch a
// filter or palette bug that still opens in a viewer.

/// What the encoder saw and what it decided. Returned beside the bytes so a
/// caller who wants to know can, and a guard can assert on it.
pub const PngStat = struct {
    colors: u32, // distinct RGBA values, or 257 meaning "more than 256"
    color_type: u8, // 3 indexed, 6 RGBA
    bytes: u32,
    /// how many rows chose each filter, 0..4 -- the profile that says whether
    /// adaptive filtering earned its pass
    filters: [5]u32,
};

var last_stat: PngStat = .{ .colors = 0, .color_type = 6, .bytes = 0, .filters = .{ 0, 0, 0, 0, 0 } };

pub fn pngLastStat() PngStat {
    return last_stat;
}

/// One filtered byte. Split out so the cost pass and the write pass compute
/// the SAME value from one definition -- two copies of Paeth is exactly the
/// kind of duplication that diverges silently.
inline fn filterByte(ft: u8, cur: u8, a: u8, b: u8, ul: u8) u8 {
    return switch (ft) {
        0 => cur,
        1 => cur -% a,
        2 => cur -% b,
        3 => cur -% @as(u8, @intCast((@as(u16, a) + @as(u16, b)) / 2)),
        else => blk: {
            const p: i16 = @as(i16, a) + @as(i16, b) - @as(i16, ul);
            const pa = @abs(p - @as(i16, a));
            const pb = @abs(p - @as(i16, b));
            const pc = @abs(p - @as(i16, ul));
            const pr: u8 = if (pa <= pb and pa <= pc) a else if (pb <= pc) b else ul;
            break :blk cur -% pr;
        },
    };
}

/// Sum of absolute signed differences -- PNG's own filter heuristic -- WITHOUT
/// materialising the candidate row. The first version wrote each candidate to
/// a scratch buffer and then summed it, which is two passes per filter and
/// eleven passes per row; this is six, and it took a 1100x760 encode from
/// 48.1 ms to the number in the guard.
fn filterCostOf(ft: u8, src: []const u8, prev: []const u8, bpp: usize) u64 {
    var s: u64 = 0;
    for (src, 0..) |cur, i| {
        const a: u8 = if (i >= bpp) src[i - bpp] else 0;
        const b: u8 = prev[i];
        const ul: u8 = if (i >= bpp) prev[i - bpp] else 0;
        const v: i16 = @as(i8, @bitCast(filterByte(ft, cur, a, b, ul)));
        s += @intCast(if (v < 0) -@as(i16, v) else v);
    }
    return s;
}

/// Write `src` filtered by `ft` into `dst`, given the previous raw row.
fn applyFilter(ft: u8, src: []const u8, prev: []const u8, bpp: usize, dst: []u8) void {
    for (src, 0..) |cur, i| {
        const a: u8 = if (i >= bpp) src[i - bpp] else 0;
        const b: u8 = prev[i];
        const ul: u8 = if (i >= bpp) prev[i - bpp] else 0; // `c` is the module's zlib alias
        dst[i] = filterByte(ft, cur, a, b, ul);
    }
}

/// Filter every row of `src` (h rows of row_bytes) into `raw`, choosing per
/// row. `raw` holds h*(row_bytes+1) bytes: filter byte then filtered row.
fn filterRows(src: []const u8, h: u32, row_bytes: usize, bpp: usize, raw: []u8, counts: *[5]u32) !void {
    const zero = try alloc.alloc(u8, row_bytes);
    defer alloc.free(zero);
    @memset(zero, 0);
    for (0..h) |y| {
        const cur = src[y * row_bytes ..][0..row_bytes];
        const prev = if (y == 0) zero else src[(y - 1) * row_bytes ..][0..row_bytes];
        // ONE FILTER FOR RGBA, FIVE TRIALS FOR INDEXED, and the split is
        // measured rather than tasteful. On this plane's own diagram --
        // 1100x760, past 256 colours -- trying all five bought 11.5% of the
        // bytes for FOUR TIMES the encode: 35,155 -> 31,111 bytes, 4.7 ->
        // 18.9 ms. That is a bad trade on a path that also serves embedded
        // images. At four bytes a pixel with many colours the deflate stream
        // is already near its floor, so the trials mostly re-discover the
        // same answer over 3.3 MB, five times.
        //
        // On the indexed path the same trials bought 29,189 -> 7,607 bytes
        // for 4.6 -> 6.7 ms, because one byte per pixel over flat art is
        // exactly what row differencing is for.
        //
        // So: indexed rows choose; RGBA rows take Paeth, which is the
        // standard choice for continuous-tone data and costs one pass.
        var best_ft: u8 = 4;
        if (bpp == 1) {
            var best_cost: u64 = std.math.maxInt(u64);
            var ft: u8 = 0;
            while (ft < 5) : (ft += 1) {
                const cost = filterCostOf(ft, cur, prev, bpp);
                if (cost < best_cost) {
                    best_cost = cost;
                    best_ft = ft;
                }
            }
        }
        raw[y * (row_bytes + 1)] = best_ft;
        applyFilter(best_ft, cur, prev, bpp, raw[y * (row_bytes + 1) + 1 ..][0..row_bytes]);
        counts[best_ft] += 1;
    }
}

/// RGBA8 tight rows -> PNG bytes (caller owns the slice; alloc = c_allocator).
pub fn pngEncode(w: u32, h: u32, rgba: []const u8, level: i32) ![]u8 {
    if (w == 0 or h == 0) return error.BadArg;
    const row_bytes: usize = @as(usize, w) * 4;
    if (rgba.len != row_bytes * h) return error.BadArg;
    const lvl = if (level < 1 or level > 9) 1 else level; // z1: the GR0 default

    var counts = [5]u32{ 0, 0, 0, 0, 0 };

    // COUNT THE COLOURS FIRST, and stop at 257. A drawing knows its palette;
    // an optimiser has to infer one. The early exit is what keeps this cheap
    // on a photograph, where the answer is decided in the first few rows.
    var pal: [256]u32 = undefined;
    var npal: usize = 0;
    var over = false;
    var px: usize = 0;
    while (px < rgba.len) : (px += 4) {
        const key = (@as(u32, rgba[px]) << 24) | (@as(u32, rgba[px + 1]) << 16) |
            (@as(u32, rgba[px + 2]) << 8) | @as(u32, rgba[px + 3]);
        var seen = false;
        for (pal[0..npal]) |q| {
            if (q == key) {
                seen = true;
                break;
            }
        }
        if (seen) continue;
        if (npal == 256) {
            over = true;
            break;
        }
        pal[npal] = key;
        npal += 1;
    }

    // ...AND WHETHER THE ALPHA CHANNEL IS CARRYING ANYTHING AT ALL.
    //
    // The colour count above stops at 257, so a picture with more than
    // 256 colours leaves this loop knowing nothing about its alpha. That
    // is the whole gap: the encoder had a palette path and a truecolour
    // path and NOTHING BETWEEN THEM, so a drawing with 800 colours and
    // no transparency wrote a 32-bit file whose fourth channel was the
    // constant 255 in every pixel.
    //
    // Measured over this library's own diagram output, 17 files rendered
    // by the graph plane: every one fully opaque, and dropping the
    // channel is 31.6% to 33.5% of the file. Lossless, so there is no
    // fidelity trade to weigh -- it is the same picture in fewer bytes.
    // Antialiasing is why they clear 256 colours: a line drawing with a
    // dozen intended colours carries several hundred edge blends, which
    // is real information and not the noise an optimiser looks for.
    var opaque_all = true;
    if (over) {
        var ax: usize = 3;
        while (ax < rgba.len) : (ax += 4) {
            if (rgba[ax] != 255) {
                opaque_all = false;
                break;
            }
        }
    }

    var ihdr: [13]u8 = undefined;
    be32(ihdr[0..4], w);
    be32(ihdr[4..8], h);
    ihdr[8] = 8; // bit depth
    ihdr[10] = 0;
    ihdr[11] = 0;
    ihdr[12] = 0;

    var plte_buf: [768]u8 = undefined;
    var trns_buf: [256]u8 = undefined;
    var plte_len: usize = 0;
    var trns_len: usize = 0;

    var raw: []u8 = undefined;
    var raw_len: usize = 0;

    if (!over) {
        // INDEXED, and exactly so -- every pixel keeps its own colour.
        ihdr[9] = 3;
        const idx_row: usize = w;
        const flat = try alloc.alloc(u8, idx_row * h);
        defer alloc.free(flat);
        px = 0;
        var i: usize = 0;
        while (px < rgba.len) : (px += 4) {
            const key = (@as(u32, rgba[px]) << 24) | (@as(u32, rgba[px + 1]) << 16) |
                (@as(u32, rgba[px + 2]) << 8) | @as(u32, rgba[px + 3]);
            var k: usize = 0;
            while (k < npal) : (k += 1) {
                if (pal[k] == key) break;
            }
            flat[i] = @intCast(k);
            i += 1;
        }
        var k: usize = 0;
        var any_alpha = false;
        while (k < npal) : (k += 1) {
            plte_buf[k * 3] = @intCast((pal[k] >> 24) & 0xff);
            plte_buf[k * 3 + 1] = @intCast((pal[k] >> 16) & 0xff);
            plte_buf[k * 3 + 2] = @intCast((pal[k] >> 8) & 0xff);
            trns_buf[k] = @intCast(pal[k] & 0xff);
            if (trns_buf[k] != 255) any_alpha = true;
        }
        plte_len = npal * 3;
        trns_len = if (any_alpha) npal else 0;

        raw_len = (idx_row + 1) * h;
        raw = try alloc.alloc(u8, raw_len);
        try filterRows(flat, h, idx_row, 1, raw, &counts);
    } else if (opaque_all) {
        // TRUECOLOUR WITHOUT THE CHANNEL NOTHING USED. Three quarters of
        // the bytes, the same pixels, and the filters get a stride of 3
        // rather than 4 -- which also helps them, because a horizontal
        // run of one colour now repeats every three bytes instead of
        // every four.
        ihdr[9] = 2; // RGB
        const rgb_row: usize = @as(usize, w) * 3;
        const flat = try alloc.alloc(u8, rgb_row * h);
        defer alloc.free(flat);
        var si: usize = 0;
        var di: usize = 0;
        while (si < rgba.len) : (si += 4) {
            flat[di] = rgba[si];
            flat[di + 1] = rgba[si + 1];
            flat[di + 2] = rgba[si + 2];
            di += 3;
        }
        raw_len = (rgb_row + 1) * h;
        raw = try alloc.alloc(u8, raw_len);
        try filterRows(flat, h, rgb_row, 3, raw, &counts);
    } else {
        ihdr[9] = 6; // RGBA
        raw_len = (row_bytes + 1) * h;
        raw = try alloc.alloc(u8, raw_len);
        try filterRows(rgba, h, row_bytes, 4, raw, &counts);
    }
    defer alloc.free(raw);

    var clen: z.uLongf = z.compressBound(@intCast(raw_len));
    const comp = try alloc.alloc(u8, @intCast(clen));
    defer alloc.free(comp);
    if (z.compress2(comp.ptr, &clen, raw.ptr, @intCast(raw_len), lvl) != z.Z_OK)
        return error.DeflateFailed;

    var total: usize = 8 + (12 + 13) + (12 + @as(usize, @intCast(clen))) + 12;
    if (plte_len > 0) total += 12 + plte_len;
    if (trns_len > 0) total += 12 + trns_len;

    const out = try alloc.alloc(u8, total);
    @memcpy(out[0..8], &[8]u8{ 0x89, 'P', 'N', 'G', '\r', '\n', 0x1a, '\n' });
    var pos: usize = 8;
    pos = pngChunk(out, pos, "IHDR", &ihdr);
    if (plte_len > 0) pos = pngChunk(out, pos, "PLTE", plte_buf[0..plte_len]);
    if (trns_len > 0) pos = pngChunk(out, pos, "tRNS", trns_buf[0..trns_len]);
    pos = pngChunk(out, pos, "IDAT", comp[0..@intCast(clen)]);
    pos = pngChunk(out, pos, "IEND", &.{});
    std.debug.assert(pos == total);

    last_stat = .{
        .colors = if (over) 257 else @intCast(npal),
        .color_type = ihdr[9],
        .bytes = @intCast(total),
        .filters = counts,
    };
    return out;
}
