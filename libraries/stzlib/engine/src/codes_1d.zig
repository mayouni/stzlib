//! codes_1d.zig -- the common 1D barcodes read natively: EAN-13, EAN-8, UPC-A and Code 128 (IM9c).
//!
//! HOW A READ IS MADE. The picture is scanned along straight lines at 24 angles (every 7.5 degrees, so a rotated or
//! upside-down code is met squarely by some line), several lines per angle. Each line is sampled with bilinear
//! interpolation, thresholded by a LOCAL mid-level (the window follows the lighting, so a code on a shaded surface
//! reads), and cut into runs at sub-pixel edge positions. From each bar that could begin a code, both ways along the
//! line, the runs are matched against the symbology's own tables as WIDTHS in modules, each symbol normalised by its own
//! total (so a code that is slightly stretched or in perspective still matches), and a read is ACCEPTED ONLY when the
//! symbology's check digit agrees. A read is a statement, never a guess: nothing that fails its check is returned.
//!
//! The tables are the standard's. Both were typed from memory and then compared, entry by entry, with a second
//! implementation's (python-barcode, the generator the guard uses): the 106 Code 128 patterns and the EAN L/G/R digit
//! codes and parity table agree with it exactly.

const std = @import("std");

const alloc = std.heap.c_allocator;

pub const Hit = struct { kind: []const u8, text: []u8, x0: f64, y0: f64, x1: f64, y1: f64 };

// ---- the tables ------------------------------------------------------------------------------------------------

const EAN_L = [10][]const u8{ "0001101", "0011001", "0010011", "0111101", "0100011", "0110001", "0101111", "0111011", "0110111", "0001011" };
const EAN_G = [10][]const u8{ "0100111", "0110011", "0011011", "0100001", "0011101", "0111001", "0000101", "0010001", "0001001", "0010111" };
const EAN_PARITY = [10][]const u8{ "LLLLLL", "LLGLGG", "LLGGLG", "LLGGGL", "LGLLGG", "LGGLLG", "LGGGLL", "LGLGLG", "LGLGGL", "LGGLGL" };

/// the run lengths (4 of them) of a 7-module digit pattern; a right-half digit has L's widths (its bits are L's complement)
fn widths4(comptime bits: []const u8) [4]f32 {
    var out: [4]f32 = undefined;
    var n: usize = 0;
    var i: usize = 0;
    while (i < bits.len) {
        var j = i;
        while (j < bits.len and bits[j] == bits[i]) j += 1;
        out[n] = @floatFromInt(j - i);
        n += 1;
        i = j;
    }
    return out;
}

const L4: [10][4]f32 = blk: {
    var t: [10][4]f32 = undefined;
    for (EAN_L, 0..) |b, i| t[i] = widths4(b);
    break :blk t;
};
const G4: [10][4]f32 = blk: {
    var t: [10][4]f32 = undefined;
    for (EAN_G, 0..) |b, i| t[i] = widths4(b);
    break :blk t;
};

const C128 = [106][]const u8{
    "212222", "222122", "222221", "121223", "121322", "131222", "122213", "122312", "132212", "221213", "221312", "231212",
    "112232", "122132", "122231", "113222", "123122", "123221", "223211", "221132", "221231", "213212", "223112", "312131",
    "311222", "321122", "321221", "312212", "322112", "322211", "212123", "212321", "232121", "111323", "131123", "131321",
    "112313", "132113", "132311", "211313", "231113", "231311", "112133", "112331", "132131", "113123", "113321", "133121",
    "313121", "211331", "231131", "213113", "213311", "213131", "311123", "311321", "331121", "312113", "312311", "332111",
    "314111", "221411", "431111", "111224", "111422", "121124", "121421", "141122", "141221", "112214", "112412", "122114",
    "122411", "142112", "142211", "241211", "221114", "413111", "241112", "134111", "111242", "121142", "121241", "114212",
    "124112", "124211", "411212", "421112", "421211", "212141", "214121", "412121", "111143", "111341", "131141", "114113",
    "114311", "411113", "411311", "113141", "114131", "311141", "411131", "211412", "211214", "211232",
};
const STOP7 = [7]f32{ 2, 3, 3, 1, 1, 1, 2 };

const C128W: [106][6]f32 = blk: {
    var t: [106][6]f32 = undefined;
    for (C128, 0..) |p, i| {
        for (0..6) |k| t[i][k] = @floatFromInt(p[k] - '0');
    }
    break :blk t;
};

// ---- a scan line as runs -----------------------------------------------------------------------------------------

/// The edges of a line: the position (in samples, fractional) of each light/dark transition, and what lies AFTER it.
const Edges = struct {
    pos: std.ArrayList(f32) = .{},
    dark_after: std.ArrayList(bool) = .{},

    fn deinit(self: *Edges) void {
        self.pos.deinit(alloc);
        self.dark_after.deinit(alloc);
    }
};

const BLOCK: usize = 16;
const WIN_BLOCKS: usize = 6; // the threshold window: 6 blocks (96 samples) each side
const MIN_CONTRAST: f32 = 32;

fn edgesOf(line: []const f32, bmin: []f32, bmax: []f32, e: *Edges) void {
    const n = line.len;
    const nb = (n + BLOCK - 1) / BLOCK;
    var b: usize = 0;
    while (b < nb) : (b += 1) {
        var mn: f32 = 255;
        var mx: f32 = 0;
        const hi = @min(n, (b + 1) * BLOCK);
        var i = b * BLOCK;
        while (i < hi) : (i += 1) {
            mn = @min(mn, line[i]);
            mx = @max(mx, line[i]);
        }
        bmin[b] = mn;
        bmax[b] = mx;
    }
    var prev_dark = false;
    var prev_thr: f32 = 0;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        const bi = i / BLOCK;
        const lo = if (bi >= WIN_BLOCKS) bi - WIN_BLOCKS else 0;
        const hib = @min(nb - 1, bi + WIN_BLOCKS);
        var mn: f32 = 255;
        var mx: f32 = 0;
        var k = lo;
        while (k <= hib) : (k += 1) {
            mn = @min(mn, bmin[k]);
            mx = @max(mx, bmax[k]);
        }
        const thr = (mn + mx) * 0.5;
        const dark = (mx - mn) >= MIN_CONTRAST and line[i] < thr;
        if (i > 0 and dark != prev_dark) {
            const tm = (thr + prev_thr) * 0.5;
            const d = line[i] - line[i - 1];
            var f: f32 = 0.5;
            if (@abs(d) > 1e-6) f = (tm - line[i - 1]) / d;
            f = @max(0, @min(1, f));
            e.pos.append(alloc, @as(f32, @floatFromInt(i - 1)) + f) catch return;
            e.dark_after.append(alloc, dark) catch return;
        }
        prev_dark = dark;
        prev_thr = thr;
    }
}

// ---- the decoders ----------------------------------------------------------------------------------------------

const Read = struct { kind: []const u8, text: [64]u8, len: usize, end_edge: usize };

fn wd(pos: []const f32, j: usize, e: usize) f32 {
    return pos[j + e + 1] - pos[j + e];
}

/// quiet zone before edge j: the space before it must be wide (or the line must begin there)
fn quietBefore(pos: []const f32, j: usize, u: f32) bool {
    if (j == 0) return true;
    return pos[j] - pos[j - 1] >= 4.0 * u;
}

/// the best digit for 4 widths in a table (and its error): widths are normalised to 7 modules first
fn bestDigit(a: [4]f32, tables: []const [10][4]f32) struct { d: u8, set: u8, err: f32 } {
    const s = a[0] + a[1] + a[2] + a[3];
    var best: f32 = 1e9;
    var bd: u8 = 0;
    var bs: u8 = 0;
    for (tables, 0..) |t, ti| {
        for (0..10) |d| {
            var err: f32 = 0;
            for (0..4) |k| {
                const m = a[k] * 7.0 / s - t[d][k];
                err += m * m;
            }
            if (err < best) {
                best = err;
                bd = @intCast(d);
                bs = @intCast(ti);
            }
        }
    }
    return .{ .d = bd, .set = bs, .err = best };
}

const DIGIT_ERR: f32 = 1.1;

fn tryEan(pos: []const f32, dark: []const bool, j: usize) ?Read {
    if (!dark[j]) return null;
    const have = pos.len - j; // edges available from j
    if (have < 44) return null;
    const unit0 = (wd(pos, j, 0) + wd(pos, j, 1) + wd(pos, j, 2)) / 3.0;
    if (unit0 < 0.8) return null;
    for (0..3) |e| {
        const r = wd(pos, j, e) / unit0;
        if (r < 0.55 or r > 1.7) return null;
    }
    if (!quietBefore(pos, j, unit0)) return null;
    var digits: [13]u8 = undefined;
    // EAN-13 first, then EAN-8: the same guard
    const shapes = [2]usize{ 6, 4 }; // digits per half
    for (shapes) |half| {
        const elems: usize = 3 + 4 * half + 5 + 4 * half + 3;
        if (have < elems + 1) continue;
        const centre = 3 + 4 * half;
        const lbase: usize = if (half == 6) 1 else 0;
        const rbase: usize = if (half == 6) 7 else 4;
        var ok = true;
        var parity: [6]u8 = undefined;
        var d: usize = 0;
        var total_err: f32 = 0;
        while (d < half and ok) : (d += 1) {
            const base = 3 + 4 * d;
            const a = [4]f32{ wd(pos, j, base), wd(pos, j, base + 1), wd(pos, j, base + 2), wd(pos, j, base + 3) };
            const s = a[0] + a[1] + a[2] + a[3];
            if (s < 5.0 * unit0 or s > 9.5 * unit0) {
                ok = false;
                break;
            }
            const tabs: []const [10][4]f32 = if (half == 6) &[_][10][4]f32{ L4, G4 } else &[_][10][4]f32{L4};
            const r = bestDigit(a, tabs);
            if (r.err > DIGIT_ERR) ok = false;
            total_err += r.err;
            digits[lbase + d] = r.d;
            parity[d] = if (r.set == 0) 'L' else 'G';
        }
        if (!ok) continue;
        // the centre guard: five modules of 1
        for (0..5) |e| {
            const r = wd(pos, j, centre + e) / unit0;
            if (r < 0.5 or r > 1.8) ok = false;
        }
        if (!ok) continue;
        d = 0;
        while (d < half and ok) : (d += 1) {
            const base = centre + 5 + 4 * d;
            const a = [4]f32{ wd(pos, j, base), wd(pos, j, base + 1), wd(pos, j, base + 2), wd(pos, j, base + 3) };
            const s = a[0] + a[1] + a[2] + a[3];
            if (s < 5.0 * unit0 or s > 9.5 * unit0) {
                ok = false;
                break;
            }
            const r = bestDigit(a, &[_][10][4]f32{L4});
            if (r.err > DIGIT_ERR) ok = false;
            total_err += r.err;
            digits[rbase + d] = r.d;
        }
        if (!ok) continue;
        for (0..3) |e| {
            const r = wd(pos, j, elems - 3 + e) / unit0;
            if (r < 0.5 or r > 1.8) ok = false;
        }
        if (!ok) continue;
        var rd: Read = .{ .kind = "ean8", .text = undefined, .len = 0, .end_edge = j + elems };
        if (half == 6) {
            // the first digit from the parity of the six left digits
            var first: ?u8 = null;
            for (EAN_PARITY, 0..) |p, v| {
                if (std.mem.eql(u8, p, parity[0..6])) first = @intCast(v);
            }
            digits[0] = first orelse continue;
            // check digit: EAN-13 mod 10 over the first 12 digits, weights 1,3
            var sum: u32 = 0;
            for (0..12) |k| sum += @as(u32, digits[k]) * (if (k % 2 == 0) @as(u32, 1) else 3);
            const chk: u8 = @intCast((10 - sum % 10) % 10);
            if (chk != digits[12]) continue;
            if (digits[0] == 0) {
                rd.kind = "upca";
                for (0..12) |k| rd.text[k] = '0' + digits[k + 1];
                rd.len = 12;
            } else {
                rd.kind = "ean13";
                for (0..13) |k| rd.text[k] = '0' + digits[k];
                rd.len = 13;
            }
        } else {
            var sum: u32 = 0;
            for (0..7) |k| sum += @as(u32, digits[k]) * (if (k % 2 == 0) @as(u32, 3) else 1);
            const chk: u8 = @intCast((10 - sum % 10) % 10);
            if (chk != digits[7]) continue;
            for (0..8) |k| rd.text[k] = '0' + digits[k];
            rd.len = 8;
        }
        return rd;
    }
    return null;
}

const C128_ERR: f32 = 1.3;

fn bestC128(a: [6]f32, from: usize, to: usize) struct { v: usize, err: f32 } {
    const s = a[0] + a[1] + a[2] + a[3] + a[4] + a[5];
    var best: f32 = 1e9;
    var bv: usize = 0;
    var v = from;
    while (v < to) : (v += 1) {
        var err: f32 = 0;
        for (0..6) |k| {
            const m = a[k] * 11.0 / s - C128W[v][k];
            err += m * m;
        }
        if (err < best) {
            best = err;
            bv = v;
        }
    }
    return .{ .v = bv, .err = best };
}

fn tryCode128(pos: []const f32, dark: []const bool, j: usize, out: *Read) bool {
    if (!dark[j]) return false;
    if (pos.len - j < 6 + 6 + 6 + 8) return false;
    const w6 = [6]f32{ wd(pos, j, 0), wd(pos, j, 1), wd(pos, j, 2), wd(pos, j, 3), wd(pos, j, 4), wd(pos, j, 5) };
    const unit0 = (w6[0] + w6[1] + w6[2] + w6[3] + w6[4] + w6[5]) / 11.0;
    if (unit0 < 0.8) return false;
    const st = bestC128(w6, 103, 106);
    if (st.err > C128_ERR) return false;
    if (!quietBefore(pos, j, unit0)) return false;
    var vals: [64]usize = undefined;
    var nv: usize = 0;
    vals[nv] = st.v;
    nv += 1;
    var e: usize = 6;
    while (nv < 63) {
        if (j + e + 8 > pos.len) return false;
        // the stop pattern first: seven elements, thirteen modules
        var ss: f32 = 0;
        for (0..7) |k| ss += wd(pos, j, e + k);
        var serr: f32 = 0;
        for (0..7) |k| {
            const m = wd(pos, j, e + k) * 13.0 / ss - STOP7[k];
            serr += m * m;
        }
        if (serr <= C128_ERR * 1.4 and nv >= 3) {
            out.end_edge = j + e + 7;
            break;
        }
        if (j + e + 7 > pos.len) return false;
        const a = [6]f32{ wd(pos, j, e), wd(pos, j, e + 1), wd(pos, j, e + 2), wd(pos, j, e + 3), wd(pos, j, e + 4), wd(pos, j, e + 5) };
        const s = a[0] + a[1] + a[2] + a[3] + a[4] + a[5];
        if (s < 7.0 * unit0 or s > 16.0 * unit0) return false;
        const r = bestC128(a, 0, 103);
        if (r.err > C128_ERR) return false;
        vals[nv] = r.v;
        nv += 1;
        e += 6;
    } else return false;
    if (nv < 3) return false;
    // the check symbol: (start + sum of i * value_i) mod 103
    var sum: usize = vals[0];
    var i: usize = 1;
    while (i < nv - 1) : (i += 1) sum += i * vals[i];
    if (sum % 103 != vals[nv - 1]) return false;
    // the text: subsets A, B and C, with the code switches and the shifts
    var set: u8 = if (vals[0] == 103) 'A' else if (vals[0] == 104) 'B' else 'C';
    var shift: u8 = 0;
    var len: usize = 0;
    i = 1;
    while (i < nv - 1) : (i += 1) {
        const v = vals[i];
        var cur = set;
        if (shift != 0) {
            cur = shift;
            shift = 0;
        }
        if (cur == 'C') {
            if (v < 100) {
                if (len + 2 > out.text.len) return false;
                out.text[len] = '0' + @as(u8, @intCast(v / 10));
                out.text[len + 1] = '0' + @as(u8, @intCast(v % 10));
                len += 2;
            } else if (v == 100) set = 'B' else if (v == 101) set = 'A';
        } else {
            if (v < 96) {
                if (len + 1 > out.text.len) return false;
                const ch: u8 = if (cur == 'A' and v >= 64) @intCast(v - 64) else @intCast(v + 32);
                out.text[len] = ch;
                len += 1;
            } else if (v == 98) {
                shift = if (cur == 'A') 'B' else 'A';
            } else if (v == 99) {
                set = 'C';
            } else if (cur == 'A' and v == 100) {
                set = 'B';
            } else if (cur == 'B' and v == 101) {
                set = 'A';
            }
        }
    }
    out.kind = "code128";
    out.len = len;
    return len > 0;
}

// ---- the sweep ---------------------------------------------------------------------------------------------------

fn bilinear(g: []const u8, w: usize, h: usize, x: f32, y: f32) f32 {
    const fx = @max(0, @min(@as(f32, @floatFromInt(w - 1)), x));
    const fy = @max(0, @min(@as(f32, @floatFromInt(h - 1)), y));
    const x0: usize = @intFromFloat(fx);
    const y0: usize = @intFromFloat(fy);
    const x1 = @min(w - 1, x0 + 1);
    const y1 = @min(h - 1, y0 + 1);
    const ax = fx - @as(f32, @floatFromInt(x0));
    const ay = fy - @as(f32, @floatFromInt(y0));
    const a = @as(f32, @floatFromInt(g[y0 * w + x0]));
    const b = @as(f32, @floatFromInt(g[y0 * w + x1]));
    const c = @as(f32, @floatFromInt(g[y1 * w + x0]));
    const d = @as(f32, @floatFromInt(g[y1 * w + x1]));
    return (a * (1 - ax) + b * ax) * (1 - ay) + (c * (1 - ax) + d * ax) * ay;
}

const STEP: f32 = 0.5;
const ANGLES: usize = 24;

fn addHit(out: *std.ArrayList(Hit), kind: []const u8, text: []const u8, x0: f64, y0: f64, x1: f64, y1: f64) void {
    for (out.items) |h| {
        if (std.mem.eql(u8, h.kind, kind) and std.mem.eql(u8, h.text, text)) return;
    }
    const t = alloc.dupe(u8, text) catch return;
    out.append(alloc, .{ .kind = kind, .text = t, .x0 = x0, .y0 = y0, .x1 = x1, .y1 = y1 }) catch alloc.free(t);
}

pub fn scan(gray: []const u8, w: usize, h: usize, out: *std.ArrayList(Hit)) void {
    if (w < 24 or h < 8) return;
    const diag = std.math.sqrt(@as(f32, @floatFromInt(w * w + h * h)));
    const cx = @as(f32, @floatFromInt(w - 1)) / 2;
    const cy = @as(f32, @floatFromInt(h - 1)) / 2;
    const spacing: f32 = @max(4.0, diag / 220.0);
    const maxn: usize = @as(usize, @intFromFloat(diag / STEP)) + 8;
    const line = alloc.alloc(f32, maxn) catch return;
    defer alloc.free(line);
    const bmin = alloc.alloc(f32, maxn / BLOCK + 2) catch return;
    defer alloc.free(bmin);
    const bmax = alloc.alloc(f32, maxn / BLOCK + 2) catch return;
    defer alloc.free(bmax);
    var a: usize = 0;
    while (a < ANGLES) : (a += 1) {
        const th = std.math.pi * @as(f32, @floatFromInt(a)) / @as(f32, @floatFromInt(ANGLES));
        const dx = @cos(th);
        const dy = @sin(th);
        const nx = -dy;
        const ny = dx;
        var t: f32 = -diag / 2;
        while (t <= diag / 2) : (t += spacing) {
            const ox = cx + nx * t;
            const oy = cy + ny * t;
            // clip o + d*s to the image
            var s0: f32 = -diag;
            var s1: f32 = diag;
            const lim_x = @as(f32, @floatFromInt(w - 1));
            const lim_y = @as(f32, @floatFromInt(h - 1));
            if (@abs(dx) > 1e-6) {
                const sa = (0 - ox) / dx;
                const sb = (lim_x - ox) / dx;
                s0 = @max(s0, @min(sa, sb));
                s1 = @min(s1, @max(sa, sb));
            } else if (ox < 0 or ox > lim_x) continue;
            if (@abs(dy) > 1e-6) {
                const sa = (0 - oy) / dy;
                const sb = (lim_y - oy) / dy;
                s0 = @max(s0, @min(sa, sb));
                s1 = @min(s1, @max(sa, sb));
            } else if (oy < 0 or oy > lim_y) continue;
            if (s1 - s0 < 40) continue;
            const n: usize = @min(maxn, @as(usize, @intFromFloat((s1 - s0) / STEP)) + 1);
            var i: usize = 0;
            while (i < n) : (i += 1) {
                const s = s0 + @as(f32, @floatFromInt(i)) * STEP;
                line[i] = bilinear(gray, w, h, ox + dx * s, oy + dy * s);
            }
            var e: Edges = .{};
            defer e.deinit();
            edgesOf(line[0..n], bmin, bmax, &e);
            if (e.pos.items.len < 12) continue;
            decodeLine(&e, out, ox, oy, dx, dy, s0, false);
            // the same line read from the other end: reversed edges, colours flipped
            var r: Edges = .{};
            defer r.deinit();
            const m = e.pos.items.len;
            var k: usize = 0;
            while (k < m) : (k += 1) {
                r.pos.append(alloc, -e.pos.items[m - 1 - k]) catch break;
                r.dark_after.append(alloc, !e.dark_after.items[m - 1 - k]) catch break;
            }
            if (r.pos.items.len == m) decodeLine(&r, out, ox, oy, dx, dy, s0, true);
        }
    }
    dropNested(out);
}

fn decodeLine(e: *Edges, out: *std.ArrayList(Hit), ox: f32, oy: f32, dx: f32, dy: f32, s0: f32, reversed: bool) void {
    const pos = e.pos.items;
    const dark = e.dark_after.items;
    var j: usize = 0;
    while (j + 20 < pos.len) : (j += 1) {
        if (!dark[j]) continue;
        var found: ?Read = tryEan(pos, dark, j);
        if (found == null) {
            var r: Read = .{ .kind = "", .text = undefined, .len = 0, .end_edge = 0 };
            if (tryCode128(pos, dark, j, &r)) found = r;
        }
        const f = found orelse continue;
        var p0 = pos[j];
        var p1 = pos[@min(f.end_edge, pos.len - 1)];
        if (reversed) {
            p0 = -p0;
            p1 = -p1;
        }
        const sa = s0 + p0 * STEP;
        const sb = s0 + p1 * STEP;
        addHit(out, f.kind, f.text[0..f.len], ox + dx * sa, oy + dy * sa, ox + dx * sb, oy + dy * sb);
        // a symbol that was read is not searched for another inside: its own digits can look like a shorter code (an EAN-8
        // hides in the middle of a UPC-A, with a check digit that agrees one time in ten)
        j = @max(j, f.end_edge);
    }
}

fn hitLen(h: Hit) f32 {
    const dx: f32 = @floatCast(h.x1 - h.x0);
    const dy: f32 = @floatCast(h.y1 - h.y0);
    return @sqrt(dx * dx + dy * dy);
}

/// `a` lies inside `b`: both its ends fall within b's extent along b's line, and beside it by no more than half its length,
/// and `a` is clearly the shorter. A shorter code inside a longer one is a part of it, not another code.
fn nestedIn(a: Hit, b: Hit) bool {
    const l = hitLen(b);
    if (l < 1) return false;
    if (hitLen(a) >= 0.9 * l) return false;
    const bx: f32 = @floatCast(b.x1 - b.x0);
    const by: f32 = @floatCast(b.y1 - b.y0);
    const pts = [2][2]f64{ .{ a.x0, a.y0 }, .{ a.x1, a.y1 } };
    for (pts) |q| {
        const qx: f32 = @floatCast(q[0] - b.x0);
        const qy: f32 = @floatCast(q[1] - b.y0);
        const t = (qx * bx + qy * by) / (l * l);
        const perp = @abs(qx * by - qy * bx) / l;
        if (t < -0.03 or t > 1.03 or perp > 0.5 * l) return false;
    }
    return true;
}

fn dropNested(out: *std.ArrayList(Hit)) void {
    var i: usize = 0;
    while (i < out.items.len) {
        var drop = false;
        for (out.items, 0..) |g, gi| {
            if (gi != i and nestedIn(out.items[i], g)) {
                drop = true;
                break;
            }
        }
        if (drop) {
            alloc.free(out.items[i].text);
            _ = out.orderedRemove(i);
        } else i += 1;
    }
}
