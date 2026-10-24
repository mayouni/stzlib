//! pdf.zig -- Softanza's native PDF reader: the TEXT LAYER of a born-digital PDF, read in Zig.
//!
//! It is the deterministic FLOOR of the document faculty (SOFTANZA_DOCUMENT_INTELLIGENCE_MEMO.md): no model,
//! no OCR, no network. A scanned page has no text layer and yields nothing -- that is a model's job, measured
//! against this floor, never hidden inside it.
//!
//! Pipeline: scan every "N G obj" (so a broken or missing xref table does not matter), expand object streams,
//! find the catalog, walk the page tree, decode each page's content (Flate/ASCIIHex/ASCII85/LZW/RunLength),
//! interpret the text operators with the fonts' ToUnicode maps and widths, then LAY OUT the glyphs: rows,
//! fragments, right-to-left lines put back in logical order, tables found from ruling lines, a column-aware
//! reading order (an XY cut that keeps spanning titles apart), and blocks classified as heading, paragraph,
//! list item, code, table or page furniture.
//!
//! Everything a document allocates lives in one arena: a Result is freed whole.

const std = @import("std");
const Allocator = std.mem.Allocator;

// ============================================================================================================
// Objects
// ============================================================================================================

pub const Ref = struct { num: u32, gen: u32 };

pub const Dict = struct {
    keys: []const []const u8,
    vals: []Obj,
    pub fn get(d: *const Dict, k: []const u8) ?Obj {
        for (d.keys, 0..) |key, i| if (std.mem.eql(u8, key, k)) return d.vals[i];
        return null;
    }
};

pub const Stream = struct { dict: *Dict, raw: []const u8 };

pub const Obj = union(enum) {
    nul,
    boolean: bool,
    num: f64,
    name: []const u8,
    str: []const u8,
    arr: []Obj,
    dict: *Dict,
    ref: Ref,
    stream: *Stream,
    op: []const u8,
};

fn isWs(c: u8) bool {
    return c == 0 or c == 9 or c == 10 or c == 12 or c == 13 or c == 32;
}
fn isDelim(c: u8) bool {
    return switch (c) {
        '(', ')', '<', '>', '[', ']', '{', '}', '/', '%' => true,
        else => false,
    };
}

fn parseNumber(t: []const u8) ?f64 {
    if (t.len == 0) return null;
    var i: usize = 0;
    var neg = false;
    while (i < t.len and (t[i] == '+' or t[i] == '-')) : (i += 1) {
        if (t[i] == '-') neg = !neg;
    }
    var v: f64 = 0;
    var seen = false;
    while (i < t.len and t[i] >= '0' and t[i] <= '9') : (i += 1) {
        v = v * 10 + @as(f64, @floatFromInt(t[i] - '0'));
        seen = true;
    }
    if (i < t.len and t[i] == '.') {
        i += 1;
        var f: f64 = 0.1;
        while (i < t.len and t[i] >= '0' and t[i] <= '9') : (i += 1) {
            v += f * @as(f64, @floatFromInt(t[i] - '0'));
            f *= 0.1;
            seen = true;
        }
    }
    if (!seen or i != t.len) return null;
    return if (neg) -v else v;
}

fn isInt(t: []const u8) bool {
    if (t.len == 0) return false;
    for (t) |c| if (c < '0' or c > '9') return false;
    return true;
}

const Parser = struct {
    s: []const u8,
    i: usize,
    a: Allocator,
    doc: ?*Doc,

    fn skipWs(p: *Parser) void {
        while (p.i < p.s.len) {
            const c = p.s[p.i];
            if (isWs(c)) {
                p.i += 1;
            } else if (c == '%') {
                while (p.i < p.s.len and p.s[p.i] != '\n' and p.s[p.i] != '\r') p.i += 1;
            } else break;
        }
    }

    fn regular(p: *Parser) []const u8 {
        const st = p.i;
        while (p.i < p.s.len and !isWs(p.s[p.i]) and !isDelim(p.s[p.i])) p.i += 1;
        return p.s[st..p.i];
    }

    fn parse(p: *Parser) anyerror!Obj {
        p.skipWs();
        if (p.i >= p.s.len) return error.Eof;
        const c = p.s[p.i];
        switch (c) {
            '[' => {
                p.i += 1;
                var list: std.ArrayList(Obj) = .empty;
                while (true) {
                    p.skipWs();
                    if (p.i >= p.s.len) break;
                    if (p.s[p.i] == ']') {
                        p.i += 1;
                        break;
                    }
                    const o = p.parse() catch |e| {
                        if (e == error.Eof) break;
                        continue;
                    };
                    try list.append(p.a, o);
                }
                return .{ .arr = list.items };
            },
            '<' => {
                if (p.i + 1 < p.s.len and p.s[p.i + 1] == '<') return p.parseDict();
                return p.parseHex();
            },
            '(' => return p.parseLiteral(),
            '/' => {
                p.i += 1;
                return .{ .name = try p.decodeName(p.regular()) };
            },
            ')', '>', ']', '{', '}' => {
                p.i += 1;
                return error.Unexpected;
            },
            else => {
                const t = p.regular();
                if (t.len == 0) {
                    p.i += 1;
                    return error.Unexpected;
                }
                if (parseNumber(t)) |v| {
                    if (isInt(t)) {
                        const save = p.i;
                        p.skipWs();
                        const t2 = p.regular();
                        if (isInt(t2)) {
                            p.skipWs();
                            if (p.i < p.s.len and p.s[p.i] == 'R' and (p.i + 1 >= p.s.len or isWs(p.s[p.i + 1]) or isDelim(p.s[p.i + 1]))) {
                                p.i += 1;
                                return .{ .ref = .{ .num = std.fmt.parseInt(u32, t, 10) catch 0, .gen = std.fmt.parseInt(u32, t2, 10) catch 0 } };
                            }
                        }
                        p.i = save;
                    }
                    return .{ .num = v };
                }
                if (std.mem.eql(u8, t, "true")) return .{ .boolean = true };
                if (std.mem.eql(u8, t, "false")) return .{ .boolean = false };
                if (std.mem.eql(u8, t, "null")) return .nul;
                return .{ .op = t };
            },
        }
    }

    fn decodeName(p: *Parser, raw: []const u8) ![]const u8 {
        if (std.mem.indexOfScalar(u8, raw, '#') == null) return raw;
        var out: std.ArrayList(u8) = .empty;
        var i: usize = 0;
        while (i < raw.len) : (i += 1) {
            if (raw[i] == '#' and i + 2 < raw.len) {
                const v = std.fmt.parseInt(u8, raw[i + 1 .. i + 3], 16) catch {
                    try out.append(p.a, raw[i]);
                    continue;
                };
                try out.append(p.a, v);
                i += 2;
            } else try out.append(p.a, raw[i]);
        }
        return out.items;
    }

    fn parseHex(p: *Parser) !Obj {
        p.i += 1;
        var out: std.ArrayList(u8) = .empty;
        var hi: ?u8 = null;
        while (p.i < p.s.len and p.s[p.i] != '>') : (p.i += 1) {
            const v = hexVal(p.s[p.i]) orelse continue;
            if (hi) |h| {
                try out.append(p.a, h * 16 + v);
                hi = null;
            } else hi = v;
        }
        if (hi) |h| try out.append(p.a, h * 16);
        if (p.i < p.s.len) p.i += 1;
        return .{ .str = out.items };
    }

    fn parseLiteral(p: *Parser) !Obj {
        p.i += 1;
        var out: std.ArrayList(u8) = .empty;
        var depth: usize = 1;
        while (p.i < p.s.len) {
            const c = p.s[p.i];
            if (c == '\\') {
                p.i += 1;
                if (p.i >= p.s.len) break;
                const e = p.s[p.i];
                switch (e) {
                    'n' => try out.append(p.a, 10),
                    'r' => try out.append(p.a, 13),
                    't' => try out.append(p.a, 9),
                    'b' => try out.append(p.a, 8),
                    'f' => try out.append(p.a, 12),
                    '\r' => {
                        if (p.i + 1 < p.s.len and p.s[p.i + 1] == '\n') p.i += 1;
                    },
                    '\n' => {},
                    '0'...'7' => {
                        var v: u32 = e - '0';
                        var k: usize = 0;
                        while (k < 2 and p.i + 1 < p.s.len and p.s[p.i + 1] >= '0' and p.s[p.i + 1] <= '7') : (k += 1) {
                            p.i += 1;
                            v = v * 8 + (p.s[p.i] - '0');
                        }
                        try out.append(p.a, @truncate(v));
                    },
                    else => try out.append(p.a, e),
                }
                p.i += 1;
                continue;
            }
            if (c == '(') depth += 1;
            if (c == ')') {
                depth -= 1;
                if (depth == 0) {
                    p.i += 1;
                    break;
                }
            }
            try out.append(p.a, c);
            p.i += 1;
        }
        return .{ .str = out.items };
    }

    fn parseDict(p: *Parser) !Obj {
        p.i += 2;
        var keys: std.ArrayList([]const u8) = .empty;
        var vals: std.ArrayList(Obj) = .empty;
        while (true) {
            p.skipWs();
            if (p.i >= p.s.len) break;
            if (p.s[p.i] == '>' and p.i + 1 < p.s.len and p.s[p.i + 1] == '>') {
                p.i += 2;
                break;
            }
            const k = p.parse() catch |e| {
                if (e == error.Eof) break;
                continue;
            };
            if (k != .name) continue;
            const v = p.parse() catch |e| {
                if (e == error.Eof) break;
                continue;
            };
            try keys.append(p.a, k.name);
            try vals.append(p.a, v);
        }
        const d = try p.a.create(Dict);
        d.* = .{ .keys = keys.items, .vals = vals.items };
        // a stream follows its dictionary
        const save = p.i;
        p.skipWs();
        if (p.i + 6 <= p.s.len and std.mem.eql(u8, p.s[p.i .. p.i + 6], "stream")) {
            p.i += 6;
            if (p.i < p.s.len and p.s[p.i] == '\r') p.i += 1;
            if (p.i < p.s.len and p.s[p.i] == '\n') p.i += 1;
            const start = p.i;
            var len: usize = 0;
            var ok = false;
            if (d.get("Length")) |lo| {
                var l = lo;
                if (l == .ref) {
                    if (p.doc) |doc| l = doc.load(l.ref.num);
                }
                if (l == .num and l.num >= 0) {
                    len = @intFromFloat(l.num);
                    if (start + len <= p.s.len) {
                        // the declared length is believed only when "endstream" follows it
                        const tail = p.s[start + len .. @min(p.s.len, start + len + 32)];
                        if (std.mem.indexOf(u8, tail, "endstream") != null) ok = true;
                    }
                }
            }
            if (!ok) {
                const e = std.mem.indexOfPos(u8, p.s, start, "endstream") orelse p.s.len;
                var end = e;
                if (end > start and p.s[end - 1] == '\n') end -= 1;
                if (end > start and p.s[end - 1] == '\r') end -= 1;
                len = end - start;
            }
            p.i = start + len;
            const st = try p.a.create(Stream);
            st.* = .{ .dict = d, .raw = p.s[start .. start + len] };
            if (std.mem.indexOfPos(u8, p.s, p.i, "endstream")) |e| {
                if (e < p.i + 64) p.i = e + 9;
            }
            return .{ .stream = st };
        }
        p.i = save;
        return .{ .dict = d };
    }
};

fn hexVal(c: u8) ?u8 {
    return switch (c) {
        '0'...'9' => c - '0',
        'a'...'f' => c - 'a' + 10,
        'A'...'F' => c - 'A' + 10,
        else => null,
    };
}

// ============================================================================================================
// Filters
// ============================================================================================================

fn inflate(a: Allocator, data: []const u8, container: std.compress.flate.Container) ![]u8 {
    var in: std.Io.Reader = .fixed(data);
    var aw: std.Io.Writer.Allocating = .init(a);
    const win = try a.alloc(u8, std.compress.flate.max_window_len);
    var dc: std.compress.flate.Decompress = .init(&in, container, win);
    _ = dc.reader.streamRemaining(&aw.writer) catch {
        // a damaged tail is common: keep what decoded
        if (aw.written().len == 0) return error.BadFlate;
    };
    return aw.written();
}

fn flate(a: Allocator, data: []const u8) ![]u8 {
    return inflate(a, data, .zlib) catch inflate(a, data, .raw);
}

fn asciiHex(a: Allocator, data: []const u8) ![]u8 {
    var out: std.ArrayList(u8) = .empty;
    var hi: ?u8 = null;
    for (data) |c| {
        if (c == '>') break;
        const v = hexVal(c) orelse continue;
        if (hi) |h| {
            try out.append(a, h * 16 + v);
            hi = null;
        } else hi = v;
    }
    if (hi) |h| try out.append(a, h * 16);
    return out.items;
}

fn ascii85(a: Allocator, data: []const u8) ![]u8 {
    var out: std.ArrayList(u8) = .empty;
    var tuple: u32 = 0;
    var n: usize = 0;
    var i: usize = 0;
    if (data.len >= 2 and data[0] == '<' and data[1] == '~') i = 2;
    while (i < data.len) : (i += 1) {
        const c = data[i];
        if (c == '~') break;
        if (isWs(c)) continue;
        if (c == 'z' and n == 0) {
            try out.appendSlice(a, &[_]u8{ 0, 0, 0, 0 });
            continue;
        }
        if (c < '!' or c > 'u') continue;
        tuple = tuple *% 85 +% (c - '!');
        n += 1;
        if (n == 5) {
            try out.appendSlice(a, &[_]u8{ @truncate(tuple >> 24), @truncate(tuple >> 16), @truncate(tuple >> 8), @truncate(tuple) });
            tuple = 0;
            n = 0;
        }
    }
    if (n > 1) {
        var k = n;
        while (k < 5) : (k += 1) tuple = tuple *% 85 +% 84;
        const bytes = [_]u8{ @truncate(tuple >> 24), @truncate(tuple >> 16), @truncate(tuple >> 8), @truncate(tuple) };
        try out.appendSlice(a, bytes[0 .. n - 1]);
    }
    return out.items;
}

fn lzw(a: Allocator, data: []const u8, early: bool) ![]u8 {
    var out: std.ArrayList(u8) = .empty;
    var table: std.ArrayList([]const u8) = .empty;
    var singles: [256]u8 = undefined;
    for (0..256) |k| singles[k] = @intCast(k);
    const reset = struct {
        fn f(t: *std.ArrayList([]const u8), al: Allocator, s: *[256]u8) !void {
            t.clearRetainingCapacity();
            for (0..256) |k| try t.append(al, s[k .. k + 1]);
            try t.append(al, "");
            try t.append(al, "");
        }
    }.f;
    try reset(&table, a, &singles);
    var bits: u32 = 9;
    var buf: u32 = 0;
    var nbuf: u32 = 0;
    var prev: ?[]const u8 = null;
    var i: usize = 0;
    while (true) {
        while (nbuf < bits and i < data.len) : (i += 1) {
            buf = (buf << 8) | data[i];
            nbuf += 8;
        }
        if (nbuf < bits) break;
        const code: u32 = (buf >> @intCast(nbuf - bits)) & ((@as(u32, 1) << @intCast(bits)) - 1);
        nbuf -= bits;
        if (code == 256) {
            try reset(&table, a, &singles);
            bits = 9;
            prev = null;
            continue;
        }
        if (code == 257) break;
        var entry: []const u8 = undefined;
        if (code < table.items.len) {
            entry = table.items[code];
        } else if (prev) |pv| {
            const e = try a.alloc(u8, pv.len + 1);
            @memcpy(e[0..pv.len], pv);
            e[pv.len] = pv[0];
            entry = e;
        } else break;
        try out.appendSlice(a, entry);
        if (prev) |pv| {
            const e = try a.alloc(u8, pv.len + 1);
            @memcpy(e[0..pv.len], pv);
            e[pv.len] = entry[0];
            try table.append(a, e);
        }
        prev = entry;
        const lim: usize = if (early) 1 else 0;
        if (table.items.len + lim >= (@as(usize, 1) << @intCast(bits)) and bits < 12) bits += 1;
    }
    return out.items;
}

fn runLength(a: Allocator, data: []const u8) ![]u8 {
    var out: std.ArrayList(u8) = .empty;
    var i: usize = 0;
    while (i < data.len) {
        const l = data[i];
        i += 1;
        if (l == 128) break;
        if (l < 128) {
            const n = @min(@as(usize, l) + 1, data.len - i);
            try out.appendSlice(a, data[i .. i + n]);
            i += n;
        } else {
            if (i >= data.len) break;
            try out.appendNTimes(a, data[i], 257 - @as(usize, l));
            i += 1;
        }
    }
    return out.items;
}

fn pngPredict(a: Allocator, data: []const u8, colors: usize, bpc: usize, columns: usize) ![]u8 {
    const bpp = @max(1, colors * bpc / 8);
    const rowlen = (columns * colors * bpc + 7) / 8;
    var out: std.ArrayList(u8) = .empty;
    const prevrow = try a.alloc(u8, rowlen);
    @memset(prevrow, 0);
    const row = try a.alloc(u8, rowlen);
    var i: usize = 0;
    while (i + 1 + rowlen <= data.len) : (i += 1 + rowlen) {
        const ft = data[i];
        @memcpy(row, data[i + 1 .. i + 1 + rowlen]);
        for (0..rowlen) |k| {
            const left: u8 = if (k >= bpp) row[k - bpp] else 0;
            const up: u8 = prevrow[k];
            const ul: u8 = if (k >= bpp) prevrow[k - bpp] else 0;
            row[k] = switch (ft) {
                1 => row[k] +% left,
                2 => row[k] +% up,
                3 => row[k] +% @as(u8, @truncate((@as(u16, left) + up) / 2)),
                4 => row[k] +% paeth(left, up, ul),
                else => row[k],
            };
        }
        try out.appendSlice(a, row);
        @memcpy(prevrow, row);
    }
    return out.items;
}

fn paeth(l: u8, u: u8, ul: u8) u8 {
    const p: i32 = @as(i32, l) + u - ul;
    const pa = @abs(p - l);
    const pb = @abs(p - u);
    const pc = @abs(p - ul);
    if (pa <= pb and pa <= pc) return l;
    if (pb <= pc) return u;
    return ul;
}

// ============================================================================================================
// The document
// ============================================================================================================

const StmCache = struct { data: []const u8, first: usize, offs: []usize };

pub const Doc = struct {
    a: Allocator,
    s: []const u8,
    offsets: std.AutoHashMapUnmanaged(u32, usize) = .empty,
    instm: std.AutoHashMapUnmanaged(u32, [2]u32) = .empty,
    stms: std.AutoHashMapUnmanaged(u32, StmCache) = .empty,
    cache: std.AutoHashMapUnmanaged(u32, Obj) = .empty,
    loading: std.AutoHashMapUnmanaged(u32, void) = .empty,
    encrypted: bool = false,
    tagged: bool = false,
    version: []const u8 = "",

    pub fn init(a: Allocator, s: []const u8) !Doc {
        var d = Doc{ .a = a, .s = s };
        if (s.len >= 8 and std.mem.eql(u8, s[0..5], "%PDF-")) {
            var e: usize = 5;
            while (e < s.len and e < 12 and !isWs(s[e])) e += 1;
            d.version = s[5..e];
        }
        try d.scan();
        d.encrypted = std.mem.indexOf(u8, s, "/Encrypt") != null;
        return d;
    }

    // Every "N G obj" in the file; a later definition of the same number wins (incremental updates).
    fn scan(d: *Doc) !void {
        const s = d.s;
        var i: usize = 0;
        while (std.mem.indexOfPos(u8, s, i, "obj")) |p| {
            i = p + 3;
            if (p + 3 < s.len and !isWs(s[p + 3]) and !isDelim(s[p + 3])) continue;
            if (p == 0 or !isWs(s[p - 1])) continue;
            var k = p;
            while (k > 0 and isWs(s[k - 1])) k -= 1;
            const ge = k;
            while (k > 0 and s[k - 1] >= '0' and s[k - 1] <= '9') k -= 1;
            if (k == ge) continue;
            while (k > 0 and isWs(s[k - 1])) k -= 1;
            const ne = k;
            while (k > 0 and s[k - 1] >= '0' and s[k - 1] <= '9') k -= 1;
            if (k == ne) continue;
            if (k > 0 and !isWs(s[k - 1]) and !isDelim(s[k - 1])) continue;
            const num = std.fmt.parseInt(u32, s[k..ne], 10) catch continue;
            try d.offsets.put(d.a, num, k);
        }
        // object streams
        var it = d.offsets.iterator();
        var stm_nums: std.ArrayList(u32) = .empty;
        while (it.next()) |e| {
            const off = e.value_ptr.*;
            const win = s[off..@min(s.len, off + 600)];
            if (std.mem.indexOf(u8, win, "/ObjStm") != null) try stm_nums.append(d.a, e.key_ptr.*);
        }
        for (stm_nums.items) |sn| {
            const o = d.load(sn);
            if (o != .stream) continue;
            const st = o.stream;
            const n = numOf(d.resolve(st.dict.get("N") orelse .nul)) orelse continue;
            const first = numOf(d.resolve(st.dict.get("First") orelse .nul)) orelse continue;
            const data = d.decode(st) catch continue;
            var p = Parser{ .s = data, .i = 0, .a = d.a, .doc = null };
            var offs: std.ArrayList(usize) = .empty;
            var idx: u32 = 0;
            while (idx < @as(u32, @intFromFloat(n))) : (idx += 1) {
                const on = p.parse() catch break;
                const oo = p.parse() catch break;
                if (on != .num or oo != .num) break;
                const onum: u32 = @intFromFloat(on.num);
                try offs.append(d.a, @intFromFloat(oo.num));
                if (!d.offsets.contains(onum)) try d.instm.put(d.a, onum, .{ sn, idx });
            }
            try d.stms.put(d.a, sn, .{ .data = data, .first = @intFromFloat(first), .offs = offs.items });
        }
    }

    pub fn load(d: *Doc, num: u32) Obj {
        if (d.cache.get(num)) |o| return o;
        if (d.loading.contains(num)) return .nul;
        d.loading.put(d.a, num, {}) catch return .nul;
        defer _ = d.loading.remove(num);
        var result: Obj = .nul;
        if (d.offsets.get(num)) |off| {
            var p = Parser{ .s = d.s, .i = off, .a = d.a, .doc = d };
            _ = p.regular();
            p.skipWs();
            _ = p.regular();
            p.skipWs();
            const kw = p.regular();
            if (std.mem.eql(u8, kw, "obj")) result = p.parse() catch .nul;
        } else if (d.instm.get(num)) |loc| {
            if (d.stms.get(loc[0])) |sc| {
                if (loc[1] < sc.offs.len) {
                    const at = sc.first + sc.offs[loc[1]];
                    if (at < sc.data.len) {
                        var p = Parser{ .s = sc.data, .i = at, .a = d.a, .doc = d };
                        result = p.parse() catch .nul;
                    }
                }
            }
        }
        d.cache.put(d.a, num, result) catch {};
        return result;
    }

    pub fn resolve(d: *Doc, o: Obj) Obj {
        var x = o;
        var n: usize = 0;
        while (x == .ref and n < 32) : (n += 1) x = d.load(x.ref.num);
        return if (x == .ref) .nul else x;
    }

    fn dictOf(d: *Doc, o: Obj) ?*Dict {
        return switch (d.resolve(o)) {
            .dict => |x| x,
            .stream => |st| st.dict,
            else => null,
        };
    }

    fn get(d: *Doc, dict: *Dict, k: []const u8) Obj {
        return d.resolve(dict.get(k) orelse .nul);
    }

    pub fn decode(d: *Doc, st: *Stream) ![]const u8 {
        var data: []const u8 = st.raw;
        const f = d.get(st.dict, "Filter");
        const parms = d.get(st.dict, "DecodeParms");
        var names: [8][]const u8 = undefined;
        var pars: [8]?*Dict = .{null} ** 8;
        var n: usize = 0;
        switch (f) {
            .name => |nm| {
                names[0] = nm;
                pars[0] = d.dictOf(parms);
                n = 1;
            },
            .arr => |arr| for (arr, 0..) |x, k| {
                if (n >= 8) break;
                const xr = d.resolve(x);
                if (xr != .name) continue;
                names[n] = xr.name;
                if (parms == .arr and k < parms.arr.len) pars[n] = d.dictOf(parms.arr[k]);
                n += 1;
            },
            else => {},
        }
        for (names[0..n], 0..) |nm, k| {
            if (eq(nm, "FlateDecode") or eq(nm, "Fl")) {
                data = try flate(d.a, data);
                data = try d.predict(data, pars[k]);
            } else if (eq(nm, "ASCIIHexDecode") or eq(nm, "AHx")) {
                data = try asciiHex(d.a, data);
            } else if (eq(nm, "ASCII85Decode") or eq(nm, "A85")) {
                data = try ascii85(d.a, data);
            } else if (eq(nm, "LZWDecode") or eq(nm, "LZW")) {
                var early = true;
                if (pars[k]) |pd| if (numOf(d.get(pd, "EarlyChange"))) |v| {
                    early = v != 0;
                };
                data = try lzw(d.a, data, early);
                data = try d.predict(data, pars[k]);
            } else if (eq(nm, "RunLengthDecode") or eq(nm, "RL")) {
                data = try runLength(d.a, data);
            } else return error.UnsupportedFilter; // images (DCT, JPX, CCITT, JBIG2): not text
        }
        return data;
    }

    fn predict(d: *Doc, data: []const u8, parms: ?*Dict) ![]const u8 {
        const pd = parms orelse return data;
        const pred = numOf(d.get(pd, "Predictor")) orelse return data;
        if (pred < 10) return data;
        const colors: usize = @intFromFloat(numOf(d.get(pd, "Colors")) orelse 1);
        const bpc: usize = @intFromFloat(numOf(d.get(pd, "BitsPerComponent")) orelse 8);
        const cols: usize = @intFromFloat(numOf(d.get(pd, "Columns")) orelse 1);
        return pngPredict(d.a, data, colors, bpc, cols);
    }

    // The catalog: the trailer's /Root (latest first), else an XRef stream's /Root, else any /Type /Catalog.
    fn catalog(d: *Doc) ?*Dict {
        var i: usize = d.s.len;
        while (i > 0) {
            const p = std.mem.lastIndexOf(u8, d.s[0..i], "trailer") orelse break;
            var ps = Parser{ .s = d.s, .i = p + 7, .a = d.a, .doc = d };
            if (ps.parse()) |o| {
                if (o == .dict) if (o.dict.get("Root")) |r| if (d.dictOf(r)) |c| return c;
            } else |_| {}
            i = p;
        }
        var best: ?*Dict = null;
        var best_off: usize = 0;
        var it = d.offsets.iterator();
        while (it.next()) |e| {
            const off = e.value_ptr.*;
            const win = d.s[off..@min(d.s.len, off + 1200)];
            const is_cat = std.mem.indexOf(u8, win, "/Catalog") != null;
            const is_x = std.mem.indexOf(u8, win, "/XRef") != null;
            if (!is_cat and !is_x) continue;
            const o = d.load(e.key_ptr.*);
            const dd = d.dictOf(o) orelse continue;
            var cand: ?*Dict = null;
            if (is_x) {
                if (dd.get("Root")) |r| cand = d.dictOf(r);
            }
            if (cand == null) {
                const t = d.get(dd, "Type");
                if (t == .name and eq(t.name, "Catalog")) cand = dd;
            }
            if (cand != null and off >= best_off) {
                best = cand;
                best_off = off;
            }
        }
        if (best == null) {
            var it2 = d.instm.iterator();
            while (it2.next()) |e| {
                const dd = d.dictOf(d.load(e.key_ptr.*)) orelse continue;
                const t = d.get(dd, "Type");
                if (t == .name and eq(t.name, "Catalog")) return dd;
            }
        }
        return best;
    }
};

fn eq(a: []const u8, b: []const u8) bool {
    return std.mem.eql(u8, a, b);
}

fn numOf(o: Obj) ?f64 {
    return switch (o) {
        .num => |v| v,
        else => null,
    };
}

// ============================================================================================================
// Fonts
// ============================================================================================================

const win_hi = [32]u21{ 0x20AC, 0xFFFD, 0x201A, 0x0192, 0x201E, 0x2026, 0x2020, 0x2021, 0x02C6, 0x2030, 0x0160, 0x2039, 0x0152, 0xFFFD, 0x017D, 0xFFFD, 0xFFFD, 0x2018, 0x2019, 0x201C, 0x201D, 0x2022, 0x2013, 0x2014, 0x02DC, 0x2122, 0x0161, 0x203A, 0x0153, 0xFFFD, 0x017E, 0x0178 };

const mac_hi = [128]u21{
    0x00C4, 0x00C5, 0x00C7, 0x00C9, 0x00D1, 0x00D6, 0x00DC, 0x00E1, 0x00E0, 0x00E2, 0x00E4, 0x00E3, 0x00E5, 0x00E7, 0x00E9, 0x00E8,
    0x00EA, 0x00EB, 0x00ED, 0x00EC, 0x00EE, 0x00EF, 0x00F1, 0x00F3, 0x00F2, 0x00F4, 0x00F6, 0x00F5, 0x00FA, 0x00F9, 0x00FB, 0x00FC,
    0x2020, 0x00B0, 0x00A2, 0x00A3, 0x00A7, 0x2022, 0x00B6, 0x00DF, 0x00AE, 0x00A9, 0x2122, 0x00B4, 0x00A8, 0x2260, 0x00C6, 0x00D8,
    0x221E, 0x00B1, 0x2264, 0x2265, 0x00A5, 0x00B5, 0x2202, 0x2211, 0x220F, 0x03C0, 0x222B, 0x00AA, 0x00BA, 0x03A9, 0x00E6, 0x00F8,
    0x00BF, 0x00A1, 0x00AC, 0x221A, 0x0192, 0x2248, 0x2206, 0x00AB, 0x00BB, 0x2026, 0x00A0, 0x00C0, 0x00C3, 0x00D5, 0x0152, 0x0153,
    0x2013, 0x2014, 0x201C, 0x201D, 0x2018, 0x2019, 0x00F7, 0x25CA, 0x00FF, 0x0178, 0x2044, 0x20AC, 0x2039, 0x203A, 0xFB01, 0xFB02,
    0x2021, 0x00B7, 0x201A, 0x201E, 0x2030, 0x00C2, 0x00CA, 0x00C1, 0x00CB, 0x00C8, 0x00CD, 0x00CE, 0x00CF, 0x00CC, 0x00D3, 0x00D4,
    0xF8FF, 0x00D2, 0x00DA, 0x00DB, 0x00D9, 0x0131, 0x02C6, 0x02DC, 0x00AF, 0x02D8, 0x02D9, 0x02DA, 0x00B8, 0x02DD, 0x02DB, 0x02C7,
};

const GlyphName = struct { n: []const u8, c: u21 };
const glyph_names = [_]GlyphName{
    .{ .n = "space", .c = 0x20 },          .{ .n = "exclam", .c = '!' },          .{ .n = "quotedbl", .c = '"' },        .{ .n = "numbersign", .c = '#' },
    .{ .n = "dollar", .c = '$' },          .{ .n = "percent", .c = '%' },         .{ .n = "ampersand", .c = '&' },       .{ .n = "quotesingle", .c = '\'' },
    .{ .n = "parenleft", .c = '(' },       .{ .n = "parenright", .c = ')' },      .{ .n = "asterisk", .c = '*' },        .{ .n = "plus", .c = '+' },
    .{ .n = "comma", .c = ',' },           .{ .n = "hyphen", .c = '-' },          .{ .n = "period", .c = '.' },          .{ .n = "slash", .c = '/' },
    .{ .n = "zero", .c = '0' },            .{ .n = "one", .c = '1' },             .{ .n = "two", .c = '2' },             .{ .n = "three", .c = '3' },
    .{ .n = "four", .c = '4' },            .{ .n = "five", .c = '5' },            .{ .n = "six", .c = '6' },             .{ .n = "seven", .c = '7' },
    .{ .n = "eight", .c = '8' },           .{ .n = "nine", .c = '9' },            .{ .n = "colon", .c = ':' },           .{ .n = "semicolon", .c = ';' },
    .{ .n = "less", .c = '<' },            .{ .n = "equal", .c = '=' },           .{ .n = "greater", .c = '>' },         .{ .n = "question", .c = '?' },
    .{ .n = "at", .c = '@' },              .{ .n = "bracketleft", .c = '[' },     .{ .n = "backslash", .c = '\\' },      .{ .n = "bracketright", .c = ']' },
    .{ .n = "asciicircum", .c = '^' },     .{ .n = "underscore", .c = '_' },      .{ .n = "grave", .c = '`' },           .{ .n = "braceleft", .c = '{' },
    .{ .n = "bar", .c = '|' },             .{ .n = "braceright", .c = '}' },      .{ .n = "asciitilde", .c = '~' },      .{ .n = "quoteleft", .c = 0x2018 },
    .{ .n = "quoteright", .c = 0x2019 },   .{ .n = "quotedblleft", .c = 0x201C }, .{ .n = "quotedblright", .c = 0x201D }, .{ .n = "quotesinglbase", .c = 0x201A },
    .{ .n = "quotedblbase", .c = 0x201E }, .{ .n = "endash", .c = 0x2013 },       .{ .n = "emdash", .c = 0x2014 },       .{ .n = "bullet", .c = 0x2022 },
    .{ .n = "ellipsis", .c = 0x2026 },     .{ .n = "fi", .c = 0xFB01 },           .{ .n = "fl", .c = 0xFB02 },           .{ .n = "ff", .c = 0xFB00 },
    .{ .n = "ffi", .c = 0xFB03 },          .{ .n = "ffl", .c = 0xFB04 },          .{ .n = "Euro", .c = 0x20AC },         .{ .n = "trademark", .c = 0x2122 },
    .{ .n = "copyright", .c = 0xA9 },      .{ .n = "registered", .c = 0xAE },     .{ .n = "degree", .c = 0xB0 },         .{ .n = "section", .c = 0xA7 },
    .{ .n = "paragraph", .c = 0xB6 },      .{ .n = "dagger", .c = 0x2020 },       .{ .n = "daggerdbl", .c = 0x2021 },    .{ .n = "guillemotleft", .c = 0xAB },
    .{ .n = "guillemotright", .c = 0xBB }, .{ .n = "guilsinglleft", .c = 0x2039 }, .{ .n = "guilsinglright", .c = 0x203A }, .{ .n = "periodcentered", .c = 0xB7 },
    .{ .n = "minus", .c = 0x2212 },        .{ .n = "multiply", .c = 0xD7 },       .{ .n = "divide", .c = 0xF7 },         .{ .n = "plusminus", .c = 0xB1 },
    .{ .n = "germandbls", .c = 0xDF },     .{ .n = "AE", .c = 0xC6 },             .{ .n = "ae", .c = 0xE6 },             .{ .n = "OE", .c = 0x152 },
    .{ .n = "oe", .c = 0x153 },            .{ .n = "Oslash", .c = 0xD8 },         .{ .n = "oslash", .c = 0xF8 },         .{ .n = "dotlessi", .c = 0x131 },
    .{ .n = "nbspace", .c = 0xA0 },        .{ .n = "sterling", .c = 0xA3 },       .{ .n = "yen", .c = 0xA5 },            .{ .n = "cent", .c = 0xA2 },
    .{ .n = "exclamdown", .c = 0xA1 },     .{ .n = "questiondown", .c = 0xBF },   .{ .n = "ordfeminine", .c = 0xAA },    .{ .n = "ordmasculine", .c = 0xBA },
    .{ .n = "mu", .c = 0xB5 },             .{ .n = "Eth", .c = 0xD0 },            .{ .n = "eth", .c = 0xF0 },            .{ .n = "Thorn", .c = 0xDE },
    .{ .n = "thorn", .c = 0xFE },          .{ .n = "onehalf", .c = 0xBD },        .{ .n = "onequarter", .c = 0xBC },     .{ .n = "threequarters", .c = 0xBE },
    .{ .n = "brokenbar", .c = 0xA6 },      .{ .n = "logicalnot", .c = 0xAC },     .{ .n = "dieresis", .c = 0xA8 },       .{ .n = "acute", .c = 0xB4 },
    .{ .n = "cedilla", .c = 0xB8 },        .{ .n = "macron", .c = 0xAF },         .{ .n = "circumflex", .c = 0x2C6 },    .{ .n = "tilde", .c = 0x2DC },
};

// A letter with an accent named after it ("eacute", "Ccedilla") composes to its precomposed Latin-1 code point.
const Accent = struct { suffix: []const u8, base: []const u8, cps: []const u21 };
const accents = [_]Accent{
    .{ .suffix = "grave", .base = "AEIOUaeiou", .cps = &.{ 0xC0, 0xC8, 0xCC, 0xD2, 0xD9, 0xE0, 0xE8, 0xEC, 0xF2, 0xF9 } },
    .{ .suffix = "acute", .base = "AEIOUYaeiouy", .cps = &.{ 0xC1, 0xC9, 0xCD, 0xD3, 0xDA, 0xDD, 0xE1, 0xE9, 0xED, 0xF3, 0xFA, 0xFD } },
    .{ .suffix = "circumflex", .base = "AEIOUaeiou", .cps = &.{ 0xC2, 0xCA, 0xCE, 0xD4, 0xDB, 0xE2, 0xEA, 0xEE, 0xF4, 0xFB } },
    .{ .suffix = "dieresis", .base = "AEIOUaeiouy", .cps = &.{ 0xC4, 0xCB, 0xCF, 0xD6, 0xDC, 0xE4, 0xEB, 0xEF, 0xF6, 0xFC, 0xFF } },
    .{ .suffix = "tilde", .base = "ANOano", .cps = &.{ 0xC3, 0xD1, 0xD5, 0xE3, 0xF1, 0xF5 } },
    .{ .suffix = "ring", .base = "Aa", .cps = &.{ 0xC5, 0xE5 } },
    .{ .suffix = "cedilla", .base = "Cc", .cps = &.{ 0xC7, 0xE7 } },
    .{ .suffix = "caron", .base = "SZsz", .cps = &.{ 0x160, 0x17D, 0x161, 0x17E } },
};

fn glyphCodepoint(name_in: []const u8) ?u21 {
    var name = name_in;
    if (std.mem.indexOfScalar(u8, name, '.')) |k| name = name[0..k];
    if (name.len == 0) return null;
    if (name.len == 1 and std.ascii.isAlphabetic(name[0])) return name[0];
    if (name.len == 7 and std.mem.startsWith(u8, name, "uni")) return std.fmt.parseInt(u21, name[3..7], 16) catch null;
    if (name.len >= 5 and name.len <= 7 and name[0] == 'u') return std.fmt.parseInt(u21, name[1..], 16) catch null;
    for (glyph_names) |g| if (eq(g.n, name)) return g.c;
    if (name.len >= 2) {
        for (accents) |ac| {
            if (name.len == 1 + ac.suffix.len and std.mem.endsWith(u8, name, ac.suffix)) {
                if (std.mem.indexOfScalar(u8, ac.base, name[0])) |k| return ac.cps[k];
            }
        }
    }
    return null;
}

const Font = struct {
    two_byte: bool = false,
    cmap: std.AutoHashMapUnmanaged(u32, []const u8) = .empty,
    enc: [256]?[]const u8 = .{null} ** 256,
    widths: std.AutoHashMapUnmanaged(u32, f32) = .empty,
    dw: f32 = 500,
    wscale: f32 = 0.001, // widths to text space: 1/1000, or a Type3 font's own FontMatrix
    bold: bool = false,
    italic: bool = false,
    mono: bool = false,

    fn text(f: *const Font, code: u32) []const u8 {
        if (f.cmap.get(code)) |t| return t;
        if (!f.two_byte and code < 256) {
            if (f.enc[code]) |t| return t;
        }
        return "";
    }
    fn width(f: *const Font, code: u32) f32 {
        return f.widths.get(code) orelse f.dw;
    }
};

fn utf8Of(a: Allocator, cp: u21) ![]const u8 {
    var buf: [4]u8 = undefined;
    const n = std.unicode.utf8Encode(cp, &buf) catch return "";
    return try a.dupe(u8, buf[0..n]);
}

fn latin1ToUtf8(a: Allocator, b: []const u8) ![]const u8 {
    var out: std.ArrayList(u8) = .empty;
    for (b) |c| {
        if (c < 0x80) {
            try out.append(a, c);
            continue;
        }
        var b4: [4]u8 = undefined;
        const n = std.unicode.utf8Encode(@as(u21, c), &b4) catch 0;
        try out.appendSlice(a, b4[0..n]);
    }
    return out.items;
}

fn utf16beToUtf8(a: Allocator, b: []const u8) ![]const u8 {
    var out: std.ArrayList(u8) = .empty;
    var i: usize = 0;
    while (i + 1 < b.len) : (i += 2) {
        var cp: u21 = (@as(u21, b[i]) << 8) | b[i + 1];
        if (cp >= 0xD800 and cp <= 0xDBFF and i + 3 < b.len) {
            const lo: u21 = (@as(u21, b[i + 2]) << 8) | b[i + 3];
            if (lo >= 0xDC00 and lo <= 0xDFFF) {
                cp = 0x10000 + ((cp - 0xD800) << 10) + (lo - 0xDC00);
                i += 2;
            }
        }
        var buf: [4]u8 = undefined;
        const n = std.unicode.utf8Encode(cp, &buf) catch continue;
        try out.appendSlice(a, buf[0..n]);
    }
    return out.items;
}

fn codeOf(b: []const u8) u32 {
    var v: u32 = 0;
    for (b) |c| v = (v << 8) | c;
    return v;
}

// ToUnicode: codespace ranges set the code width; bfchar and bfrange (both forms) map codes to UTF-16BE text.
fn parseToUnicode(f: *Font, a: Allocator, data: []const u8) !void {
    var p = Parser{ .s = data, .i = 0, .a = a, .doc = null };
    var ops: std.ArrayList(Obj) = .empty;
    var mode: enum { none, cs, bfchar, bfrange } = .none;
    while (true) {
        const o = p.parse() catch |e| {
            if (e == error.Eof) break;
            continue;
        };
        if (o == .op) {
            const t = o.op;
            if (eq(t, "begincodespacerange")) {
                mode = .cs;
            } else if (eq(t, "beginbfchar")) {
                mode = .bfchar;
            } else if (eq(t, "beginbfrange")) {
                mode = .bfrange;
            } else if (eq(t, "endcodespacerange")) {
                var k: usize = 0;
                while (k + 1 < ops.items.len) : (k += 2) {
                    if (ops.items[k] == .str) f.two_byte = ops.items[k].str.len >= 2;
                }
                mode = .none;
            } else if (eq(t, "endbfchar")) {
                var k: usize = 0;
                while (k + 1 < ops.items.len) : (k += 2) {
                    if (ops.items[k] != .str or ops.items[k + 1] != .str) continue;
                    try f.cmap.put(a, codeOf(ops.items[k].str), try utf16beToUtf8(a, ops.items[k + 1].str));
                }
                mode = .none;
            } else if (eq(t, "endbfrange")) {
                var k: usize = 0;
                while (k + 2 < ops.items.len) : (k += 3) {
                    if (ops.items[k] != .str or ops.items[k + 1] != .str) continue;
                    const lo = codeOf(ops.items[k].str);
                    const hi = codeOf(ops.items[k + 1].str);
                    if (hi < lo or hi - lo > 65535) continue;
                    switch (ops.items[k + 2]) {
                        .str => |dst| {
                            var c = lo;
                            var cur = try a.dupe(u8, dst);
                            while (c <= hi) : (c += 1) {
                                try f.cmap.put(a, c, try utf16beToUtf8(a, cur));
                                const nxt = try a.dupe(u8, cur);
                                if (nxt.len > 0) nxt[nxt.len - 1] +%= 1;
                                cur = nxt;
                            }
                        },
                        .arr => |arr| for (arr, 0..) |x, j| {
                            if (x != .str) continue;
                            try f.cmap.put(a, lo + @as(u32, @intCast(j)), try utf16beToUtf8(a, x.str));
                        },
                        else => {},
                    }
                }
                mode = .none;
            }
            ops.clearRetainingCapacity();
            continue;
        }
        if (mode != .none) try ops.append(a, o);
    }
}

fn loadFont(d: *Doc, fd: *Dict) !*Font {
    const a = d.a;
    const f = try a.create(Font);
    f.* = .{};
    const sub = d.get(fd, "Subtype");
    const is0 = sub == .name and eq(sub.name, "Type0");
    var base_name: []const u8 = "";
    const bf = d.get(fd, "BaseFont");
    if (bf == .name) base_name = bf.name;
    if (std.mem.indexOfScalar(u8, base_name, '+')) |k| base_name = base_name[k + 1 ..];
    var desc: ?*Dict = d.dictOf(fd.get("FontDescriptor") orelse .nul);
    if (is0) {
        f.two_byte = true;
        f.dw = 1000;
        const dfs = d.get(fd, "DescendantFonts");
        if (dfs == .arr and dfs.arr.len > 0) {
            if (d.dictOf(dfs.arr[0])) |cid| {
                if (numOf(d.get(cid, "DW"))) |v| f.dw = @floatCast(v);
                if (desc == null) desc = d.dictOf(cid.get("FontDescriptor") orelse .nul);
                const w = d.get(cid, "W");
                if (w == .arr) {
                    var k: usize = 0;
                    const items = w.arr;
                    while (k < items.len) {
                        const c0 = numOf(d.resolve(items[k])) orelse break;
                        if (k + 1 >= items.len) break;
                        const nx = d.resolve(items[k + 1]);
                        if (nx == .arr) {
                            for (nx.arr, 0..) |wv, j| if (numOf(d.resolve(wv))) |v| try f.widths.put(a, @as(u32, @intFromFloat(c0)) + @as(u32, @intCast(j)), @floatCast(v));
                            k += 2;
                        } else {
                            if (k + 2 >= items.len) break;
                            const c1 = numOf(nx) orelse break;
                            const v = numOf(d.resolve(items[k + 2])) orelse break;
                            var c: u32 = @intFromFloat(c0);
                            while (c <= @as(u32, @intFromFloat(c1)) and c - @as(u32, @intFromFloat(c0)) < 65536) : (c += 1) try f.widths.put(a, c, @floatCast(v));
                            k += 3;
                        }
                    }
                }
            }
        }
    } else {
        // simple font: base encoding, then /Differences
        var base_enc: enum { win, mac, std_ } = .win;
        const enc = d.get(fd, "Encoding");
        var diffs: ?[]Obj = null;
        switch (enc) {
            .name => |nm| {
                if (eq(nm, "MacRomanEncoding")) base_enc = .mac;
            },
            .dict => |ed| {
                const be = d.get(ed, "BaseEncoding");
                if (be == .name and eq(be.name, "MacRomanEncoding")) base_enc = .mac;
                const df = d.get(ed, "Differences");
                if (df == .arr) diffs = df.arr;
            },
            else => {},
        }
        var c: usize = 0;
        while (c < 256) : (c += 1) {
            var cp: u21 = @intCast(c);
            if (c < 32) continue;
            if (c >= 128) {
                if (base_enc == .mac) cp = mac_hi[c - 128] else if (c < 160) cp = win_hi[c - 128];
            }
            if (cp == 0xFFFD) continue;
            f.enc[c] = try utf8Of(a, cp);
        }
        if (diffs) |arr| {
            var code: u32 = 0;
            for (arr) |x| {
                const xr = d.resolve(x);
                switch (xr) {
                    .num => |v| code = @intFromFloat(v),
                    .name => |nm| {
                        if (code < 256) {
                            if (glyphCodepoint(nm)) |cp| f.enc[code] = try utf8Of(a, cp);
                        }
                        code += 1;
                    },
                    else => {},
                }
            }
        }
        const fc = numOf(d.get(fd, "FirstChar")) orelse 0;
        const ws = d.get(fd, "Widths");
        if (ws == .arr) for (ws.arr, 0..) |wv, j| if (numOf(d.resolve(wv))) |v| try f.widths.put(a, @as(u32, @intFromFloat(fc)) + @as(u32, @intCast(j)), @floatCast(v));
    }
    if (desc) |dd| {
        if (numOf(d.get(dd, "MissingWidth"))) |v| {
            if (!is0 and v > 0) f.dw = @floatCast(v);
        }
        if (numOf(d.get(dd, "Flags"))) |fl| {
            const flags: u32 = @intFromFloat(fl);
            if (flags & 1 != 0) f.mono = true;
            if (flags & 0x40000 != 0) f.bold = true;
            if (flags & 0x40 != 0) f.italic = true;
        }
        if (numOf(d.get(dd, "FontWeight"))) |v| {
            if (v >= 600) f.bold = true;
        }
    }
    var lower_buf: [128]u8 = undefined;
    const ln = @min(base_name.len, lower_buf.len);
    const lower = std.ascii.lowerString(lower_buf[0..ln], base_name[0..ln]);
    if (std.mem.indexOf(u8, lower, "bold") != null or std.mem.indexOf(u8, lower, "black") != null or std.mem.indexOf(u8, lower, "heavy") != null or std.mem.indexOf(u8, lower, "semibold") != null) f.bold = true;
    if (std.mem.indexOf(u8, lower, "italic") != null or std.mem.indexOf(u8, lower, "oblique") != null) f.italic = true;
    if (std.mem.indexOf(u8, lower, "mono") != null or std.mem.indexOf(u8, lower, "courier") != null or std.mem.indexOf(u8, lower, "consol") != null or std.mem.indexOf(u8, lower, "menlo") != null) f.mono = true;
    // a Type3 font gives its widths in glyph units, turned into text space by its own FontMatrix (Chrome draws
    // synthetic bold this way): read as thousandths, every advance would be wrong
    if (sub == .name and eq(sub.name, "Type3")) {
        const fm = d.get(fd, "FontMatrix");
        if (fm == .arr and fm.arr.len >= 1) {
            if (numOf(d.resolve(fm.arr[0]))) |v| {
                if (v != 0) f.wscale = @floatCast(@abs(v));
            }
        }
    }
    const tu = d.resolve(fd.get("ToUnicode") orelse .nul);
    if (tu == .stream) {
        if (d.decode(tu.stream)) |data| {
            const tb = f.two_byte;
            parseToUnicode(f, a, data) catch {};
            if (is0) f.two_byte = tb or f.two_byte;
        } else |_| {}
    }
    return f;
}

// ============================================================================================================
// Content streams
// ============================================================================================================

const M = [6]f64;
const ident: M = .{ 1, 0, 0, 1, 0, 0 };

fn mul(m1: M, m2: M) M {
    return .{
        m1[0] * m2[0] + m1[1] * m2[2],
        m1[0] * m2[1] + m1[1] * m2[3],
        m1[2] * m2[0] + m1[3] * m2[2],
        m1[2] * m2[1] + m1[3] * m2[3],
        m1[4] * m2[0] + m1[5] * m2[2] + m2[4],
        m1[4] * m2[1] + m1[5] * m2[3] + m2[5],
    };
}

fn apply(m: M, x: f64, y: f64) [2]f64 {
    return .{ x * m[0] + y * m[2] + m[4], x * m[1] + y * m[3] + m[5] };
}

pub const Glyph = struct {
    x: f32, // origin, page space with y DOWN from the page top
    y: f32,
    w: f32, // advance
    size: f32,
    bold: bool,
    mono: bool,
    italic: bool,
    t0: u32, // text in Result.text_bytes
    tn: u16,
    actual: bool = false, // its text is a marked span's ActualText: logical, never mirrored
};

const Rule = struct { x0: f32, y0: f32, x1: f32, y1: f32 }; // a thin rectangle or a stroked line: a table ruling

const GState = struct {
    ctm: M = ident,
    font: ?*Font = null,
    fs: f64 = 0,
    tc: f64 = 0,
    tw: f64 = 0,
    th: f64 = 1,
    tl: f64 = 0,
    rise: f64 = 0,
    tr: u8 = 0, // text render mode; 2 = fill and stroke, how a browser draws a bold it has no face for
};

const Interp = struct {
    d: *Doc,
    a: Allocator,
    glyphs: *std.ArrayList(Glyph),
    rules: *std.ArrayList(Rule),
    dots: *std.ArrayList(Rule),
    text: *std.ArrayList(u8),
    fonts: *std.AutoHashMapUnmanaged(usize, *Font),
    page_top: f64,
    page_left: f64,
    gs: GState = .{},
    stack: std.ArrayList(GState) = .empty,
    tm: M = ident,
    tlm: M = ident,
    path: std.ArrayList([4]f64) = .empty, // pending rectangles and segments, user space
    pb: [4]f64 = .{ 1e18, 1e18, -1e18, -1e18 }, // the bounding box of the whole pending path, curves included
    curved: bool = false, // the pending path has a curve (a disc or a circle, not a ruling)
    cur: [2]f64 = .{ 0, 0 },
    start: [2]f64 = .{ 0, 0 },
    depth: u32 = 0,
    // open marked-content spans: the ActualText of each (null when it has none) and the glyph count at its start
    marked: std.ArrayList(struct { actual: ?[]const u8, start: usize }) = .empty,

    fn fontFor(it: *Interp, res: ?*Dict, name: []const u8) ?*Font {
        const r = res orelse return null;
        const fdict = it.d.dictOf(r.get("Font") orelse .nul) orelse return null;
        const fo = fdict.get(name) orelse return null;
        const fd = it.d.dictOf(fo) orelse return null;
        const key = @intFromPtr(fd);
        if (it.fonts.get(key)) |f| return f;
        const f = loadFont(it.d, fd) catch return null;
        it.fonts.put(it.a, key, f) catch {};
        return f;
    }

    fn show(it: *Interp, s: []const u8) !void {
        const f = it.gs.font orelse return;
        var i: usize = 0;
        while (i < s.len) {
            var code: u32 = s[i];
            var single = true;
            if (f.two_byte and i + 1 < s.len) {
                code = (@as(u32, s[i]) << 8) | s[i + 1];
                i += 2;
                single = false;
            } else i += 1;
            const w0: f64 = f.width(code) * f.wscale;
            const fs = it.gs.fs;
            const th = it.gs.th;
            const trm = mul(.{ fs * th, 0, 0, fs, 0, it.gs.rise }, mul(it.tm, it.gs.ctm));
            var tx = w0 * fs + it.gs.tc;
            if (single and code == 32) tx += it.gs.tw;
            tx *= th;
            const m = mul(it.tm, it.gs.ctm);
            const adv = @abs(tx * m[0]);
            const size = @sqrt(trm[2] * trm[2] + trm[3] * trm[3]);
            const upright = m[0] > 0 and @abs(m[1]) < 0.2 * @abs(m[0]);
            var t = f.text(code);
            if (t.len == 3 and t[0] == 0xEF and t[1] == 0xAC and t[2] <= 0x86) t = switch (t[2]) {
                0x80 => "ff",
                0x81 => "fi",
                0x82 => "fl",
                0x83 => "ffi",
                0x84 => "ffl",
                else => "st",
            };
            // a producer may map its space glyph to a TAB (or a line end), and an accent piece to U+0000
            if (t.len == 1 and (t[0] == 9 or t[0] == 10 or t[0] == 13)) t = " ";
            if (t.len == 1 and t[0] == 0) t = "";
            if (upright and t.len > 0 and size > 0.5) {
                const t0: u32 = @intCast(it.text.items.len);
                try it.text.appendSlice(it.a, t);
                try it.glyphs.append(it.a, .{
                    .x = @floatCast(trm[4] - it.page_left),
                    .y = @floatCast(it.page_top - trm[5]),
                    .w = @floatCast(adv),
                    .size = @floatCast(size),
                    .bold = f.bold or it.gs.tr == 2,
                    .mono = f.mono,
                    .italic = f.italic,
                    .t0 = t0,
                    .tn = @intCast(@min(t.len, 65535)),
                });
            }
            it.tm = mul(.{ 1, 0, 0, 1, tx, 0 }, it.tm);
        }
    }

    fn touch(it: *Interp, q: [2]f64) void {
        it.pb = .{ @min(it.pb[0], q[0]), @min(it.pb[1], q[1]), @max(it.pb[2], q[0]), @max(it.pb[3], q[1]) };
    }

    fn flushPath(it: *Interp, keep: bool, fill: bool) !void {
        // a small filled shape is a candidate list bullet (browsers draw list discs as paths, not glyphs)
        if ((fill or it.curved) and it.pb[0] < 1e17) {
            const w = it.pb[2] - it.pb[0];
            const h = it.pb[3] - it.pb[1];
            if (w >= 1 and h >= 1 and w <= 9 and h <= 9 and w <= 2.2 * h and h <= 2.2 * w) {
                try it.dots.append(it.a, .{
                    .x0 = @floatCast(it.pb[0] - it.page_left),
                    .x1 = @floatCast(it.pb[2] - it.page_left),
                    .y0 = @floatCast(it.page_top - it.pb[3]),
                    .y1 = @floatCast(it.page_top - it.pb[1]),
                });
            }
        }
        it.pb = .{ 1e18, 1e18, -1e18, -1e18 };
        it.curved = false;
        if (keep) {
            for (it.path.items) |r| {
                const x0 = @min(r[0], r[2]);
                const x1 = @max(r[0], r[2]);
                const y0 = @min(r[1], r[3]);
                const y1 = @max(r[1], r[3]);
                const w = x1 - x0;
                const h = y1 - y0;
                if ((h <= 2.5 and w > 4) or (w <= 2.5 and h > 4)) {
                    try it.rules.append(it.a, .{
                        .x0 = @floatCast(x0 - it.page_left),
                        .x1 = @floatCast(x1 - it.page_left),
                        .y0 = @floatCast(it.page_top - y1),
                        .y1 = @floatCast(it.page_top - y0),
                    });
                }
            }
        }
        it.path.clearRetainingCapacity();
    }

    fn run(it: *Interp, data: []const u8, res: ?*Dict) anyerror!void {
        if (it.depth > 8) return;
        it.depth += 1;
        defer it.depth -= 1;
        var p = Parser{ .s = data, .i = 0, .a = it.a, .doc = null };
        var ops: std.ArrayList(Obj) = .empty;
        while (true) {
            const o = p.parse() catch |e| {
                if (e == error.Eof) break;
                continue;
            };
            if (o != .op) {
                try ops.append(it.a, o);
                continue;
            }
            const op = o.op;
            const n = ops.items;
            defer ops.clearRetainingCapacity();
            if (eq(op, "BI")) {
                // inline image: skip to EI
                const idp = std.mem.indexOfPos(u8, data, p.i, "ID") orelse break;
                var k = idp + 2;
                while (k + 2 < data.len) : (k += 1) {
                    if (data[k] == 'E' and data[k + 1] == 'I' and isWs(data[k - 1]) and (k + 2 >= data.len or isWs(data[k + 2]))) break;
                }
                p.i = k + 2;
                continue;
            }
            if (eq(op, "BDC") or eq(op, "BMC")) {
                // marked content: a span with an /ActualText says what its glyphs READ as (Chrome writes one round
                // a letter drawn as a base glyph plus an accent glyph its ToUnicode cannot name)
                var actual: ?[]const u8 = null;
                if (eq(op, "BDC") and n.len >= 2 and n[1] == .dict) {
                    if (n[1].dict.get("ActualText")) |v| if (v == .str) {
                        const sv = v.str;
                        // (UTF-16 with its byte-order mark, or PDFDocEncoding -- Latin-1 above 0x9F: a no-break
                        //  space arrives as the byte A0, which copied raw is not UTF-8)
                        const dec = if (sv.len >= 2 and sv[0] == 0xFE and sv[1] == 0xFF) try utf16beToUtf8(it.a, sv[2..]) else try latin1ToUtf8(it.a, sv);
                        // (a soft hyphen marks where a word MAY break: invisible, and a hyphen drawn at a line end is
                        //  a glyph of its own)
                        actual = try std.mem.replaceOwned(u8, it.a, dec, "\u{00AD}", "");
                    };
                }
                try it.marked.append(it.a, .{ .actual = actual, .start = it.glyphs.items.len });
                continue;
            }
            if (eq(op, "EMC")) {
                if (it.marked.pop()) |m| if (m.actual) |act| {
                    const gl = it.glyphs.items;
                    if (gl.len > m.start) {
                        // the span's glyphs become ONE glyph over their width, reading as the ActualText
                        var x0: f32 = gl[m.start].x;
                        var x1: f32 = gl[m.start].x + gl[m.start].w;
                        for (gl[m.start..]) |g| {
                            x0 = @min(x0, g.x);
                            x1 = @max(x1, g.x + g.w);
                        }
                        var first = gl[m.start];
                        first.x = x0;
                        first.w = x1 - x0;
                        first.t0 = @intCast(it.text.items.len);
                        first.tn = @intCast(act.len);
                        first.actual = true;
                        try it.text.appendSlice(it.a, act);
                        it.glyphs.shrinkRetainingCapacity(m.start);
                        if (act.len > 0) try it.glyphs.append(it.a, first);
                    }
                };
                continue;
            }
            if (eq(op, "q")) {
                try it.stack.append(it.a, it.gs);
            } else if (eq(op, "Q")) {
                if (it.stack.items.len > 0) it.gs = it.stack.pop().?;
            } else if (eq(op, "cm")) {
                if (n.len >= 6) it.gs.ctm = mul(nums6(n), it.gs.ctm);
            } else if (eq(op, "BT")) {
                it.tm = ident;
                it.tlm = ident;
            } else if (eq(op, "Tf")) {
                if (n.len >= 2) {
                    if (n[0] == .name) it.gs.font = it.fontFor(res, n[0].name);
                    if (n[1] == .num) it.gs.fs = n[1].num;
                }
            } else if (eq(op, "Td")) {
                if (n.len >= 2) it.td(nv(n[0]), nv(n[1]));
            } else if (eq(op, "TD")) {
                if (n.len >= 2) {
                    it.gs.tl = -nv(n[1]);
                    it.td(nv(n[0]), nv(n[1]));
                }
            } else if (eq(op, "Tm")) {
                if (n.len >= 6) {
                    it.tm = nums6(n);
                    it.tlm = it.tm;
                }
            } else if (eq(op, "T*")) {
                it.td(0, -it.gs.tl);
            } else if (eq(op, "Tc")) {
                if (n.len >= 1) it.gs.tc = nv(n[0]);
            } else if (eq(op, "Tw")) {
                if (n.len >= 1) it.gs.tw = nv(n[0]);
            } else if (eq(op, "Tz")) {
                if (n.len >= 1) it.gs.th = nv(n[0]) / 100.0;
            } else if (eq(op, "TL")) {
                if (n.len >= 1) it.gs.tl = nv(n[0]);
            } else if (eq(op, "Tr")) {
                if (n.len >= 1) it.gs.tr = @intFromFloat(@max(0, @min(7, nv(n[0]))));
            } else if (eq(op, "Ts")) {
                if (n.len >= 1) it.gs.rise = nv(n[0]);
            } else if (eq(op, "Tj")) {
                if (n.len >= 1 and n[0] == .str) try it.show(n[0].str);
            } else if (eq(op, "'")) {
                it.td(0, -it.gs.tl);
                if (n.len >= 1 and n[0] == .str) try it.show(n[0].str);
            } else if (eq(op, "\"")) {
                if (n.len >= 3) {
                    it.gs.tw = nv(n[0]);
                    it.gs.tc = nv(n[1]);
                    it.td(0, -it.gs.tl);
                    if (n[2] == .str) try it.show(n[2].str);
                }
            } else if (eq(op, "TJ")) {
                if (n.len >= 1 and n[0] == .arr) {
                    for (n[0].arr) |x| switch (x) {
                        .str => |s| try it.show(s),
                        .num => |v| it.tm = mul(.{ 1, 0, 0, 1, -v / 1000.0 * it.gs.fs * it.gs.th, 0 }, it.tm),
                        else => {},
                    };
                }
            } else if (eq(op, "re")) {
                if (n.len >= 4) {
                    const x = nv(n[0]);
                    const y = nv(n[1]);
                    const p0 = apply(it.gs.ctm, x, y);
                    const p1 = apply(it.gs.ctm, x + nv(n[2]), y + nv(n[3]));
                    it.touch(p0);
                    it.touch(p1);
                    try it.path.append(it.a, .{ p0[0], p0[1], p1[0], p1[1] });
                }
            } else if (eq(op, "m")) {
                if (n.len >= 2) {
                    it.cur = apply(it.gs.ctm, nv(n[0]), nv(n[1]));
                    it.start = it.cur;
                    it.touch(it.cur);
                }
            } else if (eq(op, "l")) {
                if (n.len >= 2) {
                    const q = apply(it.gs.ctm, nv(n[0]), nv(n[1]));
                    try it.path.append(it.a, .{ it.cur[0], it.cur[1], q[0], q[1] });
                    it.cur = q;
                    it.touch(q);
                }
            } else if (eq(op, "c") or eq(op, "v") or eq(op, "y")) {
                it.curved = true;
                var k: usize = 0;
                while (k + 1 < n.len) : (k += 2) {
                    const q = apply(it.gs.ctm, nv(n[k]), nv(n[k + 1]));
                    it.touch(q);
                    it.cur = q;
                }
            } else if (eq(op, "f") or eq(op, "F") or eq(op, "f*") or eq(op, "B") or eq(op, "B*") or eq(op, "b") or eq(op, "b*")) {
                try it.flushPath(true, true);
            } else if (eq(op, "S") or eq(op, "s")) {
                try it.flushPath(true, false);
            } else if (eq(op, "n")) {
                try it.flushPath(false, false);
            } else if (eq(op, "Do")) {
                if (n.len >= 1 and n[0] == .name) try it.doXObject(res, n[0].name);
            }
        }
    }

    fn td(it: *Interp, tx: f64, ty: f64) void {
        it.tlm = mul(.{ 1, 0, 0, 1, tx, ty }, it.tlm);
        it.tm = it.tlm;
    }

    fn doXObject(it: *Interp, res: ?*Dict, name: []const u8) !void {
        const r = res orelse return;
        const xd = it.d.dictOf(r.get("XObject") orelse .nul) orelse return;
        const xo = it.d.resolve(xd.get(name) orelse return);
        if (xo != .stream) return;
        const st = xo.stream;
        const sub = it.d.get(st.dict, "Subtype");
        if (sub != .name or !eq(sub.name, "Form")) return;
        const data = it.d.decode(st) catch return;
        const saved = it.gs;
        const saved_tm = it.tm;
        const saved_tlm = it.tlm;
        const mt = it.d.get(st.dict, "Matrix");
        if (mt == .arr and mt.arr.len >= 6) it.gs.ctm = mul(nums6(mt.arr), it.gs.ctm);
        const fres = it.d.dictOf(st.dict.get("Resources") orelse .nul) orelse res;
        try it.run(data, fres);
        it.gs = saved;
        it.tm = saved_tm;
        it.tlm = saved_tlm;
    }
};

fn nv(o: Obj) f64 {
    return switch (o) {
        .num => |v| v,
        else => 0,
    };
}

fn nums6(n: []const Obj) M {
    const b = n.len - 6;
    return .{ nv(n[b]), nv(n[b + 1]), nv(n[b + 2]), nv(n[b + 3]), nv(n[b + 4]), nv(n[b + 5]) };
}

// ============================================================================================================
// Layout
// ============================================================================================================

pub const Kind = enum { paragraph, heading, list_item, code, table, caption, page_header, page_footer };

pub const Block = struct {
    page: u32,
    kind: Kind,
    level: u32 = 0,
    x0: f32,
    y0: f32,
    x1: f32,
    y1: f32,
    size: f32,
    bold: bool,
    mono: bool,
    text: []const u8,
    italic: bool = false,
    rows: [][][]const u8 = &.{}, // a table's cells, row by row
    lines: u32 = 1,
    runin: bool = false, // a run-in heading cut from the start of a paragraph
};

const Frag = struct {
    page: u32,
    x0: f32,
    x1: f32,
    base: f32,
    y0: f32,
    y1: f32,
    size: f32,
    bold: bool,
    mono: bool,
    text: []const u8,
    table: i32 = -1, // >= 0: this unit is a whole table
    bullet: bool = false, // a vector bullet sits just left of it
    italic: bool = false,
    lead_bold: usize = 0, // bytes of a bold lead-in that opens a line of regular text (a run-in heading), 0 if none
};

fn isRtlCp(cp: u21) bool {
    if (isArabicDigit(cp)) return false;
    return (cp >= 0x0590 and cp <= 0x08FF) or (cp >= 0xFB1D and cp <= 0xFDFF) or (cp >= 0xFE70 and cp <= 0xFEFF);
}
// Arabic-Indic and Extended (Persian) digits and their separators: a number run, read left to right
fn isArabicDigit(cp: u21) bool {
    return (cp >= 0x0660 and cp <= 0x066C) or (cp >= 0x06F0 and cp <= 0x06F9);
}
fn isDigitCp(cp: u21) bool {
    return (cp >= '0' and cp <= '9') or isArabicDigit(cp);
}
// A combining mark drawn over or under a letter (Arabic harakat and hamza, Hebrew points, Latin accents)
fn isMarkCp(cp: u21) bool {
    return (cp >= 0x0300 and cp <= 0x036F) or (cp >= 0x0591 and cp <= 0x05BD) or cp == 0x05BF or cp == 0x05C1 or cp == 0x05C2 or
        cp == 0x05C4 or cp == 0x05C5 or cp == 0x05C7 or (cp >= 0x0610 and cp <= 0x061A) or (cp >= 0x064B and cp <= 0x065F) or
        cp == 0x0670 or (cp >= 0x06D6 and cp <= 0x06DC) or (cp >= 0x06DF and cp <= 0x06E4) or cp == 0x06E7 or cp == 0x06E8 or
        (cp >= 0x06EA and cp <= 0x06ED);
}
fn isLtrCp(cp: u21) bool {
    return (cp >= 'A' and cp <= 'Z') or (cp >= 'a' and cp <= 'z') or (cp >= 0xC0 and cp <= 0x24F) or (cp >= 0x370 and cp <= 0x52F);
}
fn firstCp(s: []const u8) u21 {
    if (s.len == 0) return 0;
    const n = std.unicode.utf8ByteSequenceLength(s[0]) catch return s[0];
    if (n > s.len) return s[0];
    return std.unicode.utf8Decode(s[0..n]) catch s[0];
}

// Arabic presentation forms (what a font's reverse cmap often yields) back to the logical letters, and, in text
// that is clearly Arabic, the two letters a font shares with Persian and Urdu (yeh, heh) back to their Arabic code.
const PForm = struct { start: u21, n: u21, base: u21 };
const pforms_b = [_]PForm{
    .{ .start = 0xFE80, .n = 1, .base = 0x0621 }, .{ .start = 0xFE81, .n = 2, .base = 0x0622 }, .{ .start = 0xFE83, .n = 2, .base = 0x0623 },
    .{ .start = 0xFE85, .n = 2, .base = 0x0624 }, .{ .start = 0xFE87, .n = 2, .base = 0x0625 }, .{ .start = 0xFE89, .n = 4, .base = 0x0626 },
    .{ .start = 0xFE8D, .n = 2, .base = 0x0627 }, .{ .start = 0xFE8F, .n = 4, .base = 0x0628 }, .{ .start = 0xFE93, .n = 2, .base = 0x0629 },
    .{ .start = 0xFE95, .n = 4, .base = 0x062A }, .{ .start = 0xFE99, .n = 4, .base = 0x062B }, .{ .start = 0xFE9D, .n = 4, .base = 0x062C },
    .{ .start = 0xFEA1, .n = 4, .base = 0x062D }, .{ .start = 0xFEA5, .n = 4, .base = 0x062E }, .{ .start = 0xFEA9, .n = 2, .base = 0x062F },
    .{ .start = 0xFEAB, .n = 2, .base = 0x0630 }, .{ .start = 0xFEAD, .n = 2, .base = 0x0631 }, .{ .start = 0xFEAF, .n = 2, .base = 0x0632 },
    .{ .start = 0xFEB1, .n = 4, .base = 0x0633 }, .{ .start = 0xFEB5, .n = 4, .base = 0x0634 }, .{ .start = 0xFEB9, .n = 4, .base = 0x0635 },
    .{ .start = 0xFEBD, .n = 4, .base = 0x0636 }, .{ .start = 0xFEC1, .n = 4, .base = 0x0637 }, .{ .start = 0xFEC5, .n = 4, .base = 0x0638 },
    .{ .start = 0xFEC9, .n = 4, .base = 0x0639 }, .{ .start = 0xFECD, .n = 4, .base = 0x063A }, .{ .start = 0xFED1, .n = 4, .base = 0x0641 },
    .{ .start = 0xFED5, .n = 4, .base = 0x0642 }, .{ .start = 0xFED9, .n = 4, .base = 0x0643 }, .{ .start = 0xFEDD, .n = 4, .base = 0x0644 },
    .{ .start = 0xFEE1, .n = 4, .base = 0x0645 }, .{ .start = 0xFEE5, .n = 4, .base = 0x0646 }, .{ .start = 0xFEE9, .n = 4, .base = 0x0647 },
    .{ .start = 0xFEED, .n = 2, .base = 0x0648 }, .{ .start = 0xFEEF, .n = 2, .base = 0x0649 }, .{ .start = 0xFEF1, .n = 4, .base = 0x064A },
    .{ .start = 0xFB56, .n = 4, .base = 0x067E }, .{ .start = 0xFB7A, .n = 4, .base = 0x0686 }, .{ .start = 0xFB8A, .n = 2, .base = 0x0698 },
    .{ .start = 0xFB8E, .n = 4, .base = 0x06A9 }, .{ .start = 0xFB92, .n = 4, .base = 0x06AF }, .{ .start = 0xFBAA, .n = 4, .base = 0x06BE },
    .{ .start = 0xFBFC, .n = 4, .base = 0x06CC },
};

// Arabic presentation forms A and B (U+FB50-U+FDFF, U+FE70-U+FEFF) to their letters: the Unicode NFKC
// compatibility mapping, generated from the Unicode database (Python unicodedata 15.1.0).
const PMap = struct { cp: u21, to: []const u8 };
const pforms_nfkc = [_]PMap{
    .{ .cp = 0xFB50, .to = "\u{671}" },
    .{ .cp = 0xFB51, .to = "\u{671}" },
    .{ .cp = 0xFB52, .to = "\u{67B}" },
    .{ .cp = 0xFB53, .to = "\u{67B}" },
    .{ .cp = 0xFB54, .to = "\u{67B}" },
    .{ .cp = 0xFB55, .to = "\u{67B}" },
    .{ .cp = 0xFB56, .to = "\u{67E}" },
    .{ .cp = 0xFB57, .to = "\u{67E}" },
    .{ .cp = 0xFB58, .to = "\u{67E}" },
    .{ .cp = 0xFB59, .to = "\u{67E}" },
    .{ .cp = 0xFB5A, .to = "\u{680}" },
    .{ .cp = 0xFB5B, .to = "\u{680}" },
    .{ .cp = 0xFB5C, .to = "\u{680}" },
    .{ .cp = 0xFB5D, .to = "\u{680}" },
    .{ .cp = 0xFB5E, .to = "\u{67A}" },
    .{ .cp = 0xFB5F, .to = "\u{67A}" },
    .{ .cp = 0xFB60, .to = "\u{67A}" },
    .{ .cp = 0xFB61, .to = "\u{67A}" },
    .{ .cp = 0xFB62, .to = "\u{67F}" },
    .{ .cp = 0xFB63, .to = "\u{67F}" },
    .{ .cp = 0xFB64, .to = "\u{67F}" },
    .{ .cp = 0xFB65, .to = "\u{67F}" },
    .{ .cp = 0xFB66, .to = "\u{679}" },
    .{ .cp = 0xFB67, .to = "\u{679}" },
    .{ .cp = 0xFB68, .to = "\u{679}" },
    .{ .cp = 0xFB69, .to = "\u{679}" },
    .{ .cp = 0xFB6A, .to = "\u{6A4}" },
    .{ .cp = 0xFB6B, .to = "\u{6A4}" },
    .{ .cp = 0xFB6C, .to = "\u{6A4}" },
    .{ .cp = 0xFB6D, .to = "\u{6A4}" },
    .{ .cp = 0xFB6E, .to = "\u{6A6}" },
    .{ .cp = 0xFB6F, .to = "\u{6A6}" },
    .{ .cp = 0xFB70, .to = "\u{6A6}" },
    .{ .cp = 0xFB71, .to = "\u{6A6}" },
    .{ .cp = 0xFB72, .to = "\u{684}" },
    .{ .cp = 0xFB73, .to = "\u{684}" },
    .{ .cp = 0xFB74, .to = "\u{684}" },
    .{ .cp = 0xFB75, .to = "\u{684}" },
    .{ .cp = 0xFB76, .to = "\u{683}" },
    .{ .cp = 0xFB77, .to = "\u{683}" },
    .{ .cp = 0xFB78, .to = "\u{683}" },
    .{ .cp = 0xFB79, .to = "\u{683}" },
    .{ .cp = 0xFB7A, .to = "\u{686}" },
    .{ .cp = 0xFB7B, .to = "\u{686}" },
    .{ .cp = 0xFB7C, .to = "\u{686}" },
    .{ .cp = 0xFB7D, .to = "\u{686}" },
    .{ .cp = 0xFB7E, .to = "\u{687}" },
    .{ .cp = 0xFB7F, .to = "\u{687}" },
    .{ .cp = 0xFB80, .to = "\u{687}" },
    .{ .cp = 0xFB81, .to = "\u{687}" },
    .{ .cp = 0xFB82, .to = "\u{68D}" },
    .{ .cp = 0xFB83, .to = "\u{68D}" },
    .{ .cp = 0xFB84, .to = "\u{68C}" },
    .{ .cp = 0xFB85, .to = "\u{68C}" },
    .{ .cp = 0xFB86, .to = "\u{68E}" },
    .{ .cp = 0xFB87, .to = "\u{68E}" },
    .{ .cp = 0xFB88, .to = "\u{688}" },
    .{ .cp = 0xFB89, .to = "\u{688}" },
    .{ .cp = 0xFB8A, .to = "\u{698}" },
    .{ .cp = 0xFB8B, .to = "\u{698}" },
    .{ .cp = 0xFB8C, .to = "\u{691}" },
    .{ .cp = 0xFB8D, .to = "\u{691}" },
    .{ .cp = 0xFB8E, .to = "\u{6A9}" },
    .{ .cp = 0xFB8F, .to = "\u{6A9}" },
    .{ .cp = 0xFB90, .to = "\u{6A9}" },
    .{ .cp = 0xFB91, .to = "\u{6A9}" },
    .{ .cp = 0xFB92, .to = "\u{6AF}" },
    .{ .cp = 0xFB93, .to = "\u{6AF}" },
    .{ .cp = 0xFB94, .to = "\u{6AF}" },
    .{ .cp = 0xFB95, .to = "\u{6AF}" },
    .{ .cp = 0xFB96, .to = "\u{6B3}" },
    .{ .cp = 0xFB97, .to = "\u{6B3}" },
    .{ .cp = 0xFB98, .to = "\u{6B3}" },
    .{ .cp = 0xFB99, .to = "\u{6B3}" },
    .{ .cp = 0xFB9A, .to = "\u{6B1}" },
    .{ .cp = 0xFB9B, .to = "\u{6B1}" },
    .{ .cp = 0xFB9C, .to = "\u{6B1}" },
    .{ .cp = 0xFB9D, .to = "\u{6B1}" },
    .{ .cp = 0xFB9E, .to = "\u{6BA}" },
    .{ .cp = 0xFB9F, .to = "\u{6BA}" },
    .{ .cp = 0xFBA0, .to = "\u{6BB}" },
    .{ .cp = 0xFBA1, .to = "\u{6BB}" },
    .{ .cp = 0xFBA2, .to = "\u{6BB}" },
    .{ .cp = 0xFBA3, .to = "\u{6BB}" },
    .{ .cp = 0xFBA4, .to = "\u{6C0}" },
    .{ .cp = 0xFBA5, .to = "\u{6C0}" },
    .{ .cp = 0xFBA6, .to = "\u{6C1}" },
    .{ .cp = 0xFBA7, .to = "\u{6C1}" },
    .{ .cp = 0xFBA8, .to = "\u{6C1}" },
    .{ .cp = 0xFBA9, .to = "\u{6C1}" },
    .{ .cp = 0xFBAA, .to = "\u{6BE}" },
    .{ .cp = 0xFBAB, .to = "\u{6BE}" },
    .{ .cp = 0xFBAC, .to = "\u{6BE}" },
    .{ .cp = 0xFBAD, .to = "\u{6BE}" },
    .{ .cp = 0xFBAE, .to = "\u{6D2}" },
    .{ .cp = 0xFBAF, .to = "\u{6D2}" },
    .{ .cp = 0xFBB0, .to = "\u{6D3}" },
    .{ .cp = 0xFBB1, .to = "\u{6D3}" },
    .{ .cp = 0xFBD3, .to = "\u{6AD}" },
    .{ .cp = 0xFBD4, .to = "\u{6AD}" },
    .{ .cp = 0xFBD5, .to = "\u{6AD}" },
    .{ .cp = 0xFBD6, .to = "\u{6AD}" },
    .{ .cp = 0xFBD7, .to = "\u{6C7}" },
    .{ .cp = 0xFBD8, .to = "\u{6C7}" },
    .{ .cp = 0xFBD9, .to = "\u{6C6}" },
    .{ .cp = 0xFBDA, .to = "\u{6C6}" },
    .{ .cp = 0xFBDB, .to = "\u{6C8}" },
    .{ .cp = 0xFBDC, .to = "\u{6C8}" },
    .{ .cp = 0xFBDD, .to = "\u{6C7}\u{674}" },
    .{ .cp = 0xFBDE, .to = "\u{6CB}" },
    .{ .cp = 0xFBDF, .to = "\u{6CB}" },
    .{ .cp = 0xFBE0, .to = "\u{6C5}" },
    .{ .cp = 0xFBE1, .to = "\u{6C5}" },
    .{ .cp = 0xFBE2, .to = "\u{6C9}" },
    .{ .cp = 0xFBE3, .to = "\u{6C9}" },
    .{ .cp = 0xFBE4, .to = "\u{6D0}" },
    .{ .cp = 0xFBE5, .to = "\u{6D0}" },
    .{ .cp = 0xFBE6, .to = "\u{6D0}" },
    .{ .cp = 0xFBE7, .to = "\u{6D0}" },
    .{ .cp = 0xFBE8, .to = "\u{649}" },
    .{ .cp = 0xFBE9, .to = "\u{649}" },
    .{ .cp = 0xFBEA, .to = "\u{626}\u{627}" },
    .{ .cp = 0xFBEB, .to = "\u{626}\u{627}" },
    .{ .cp = 0xFBEC, .to = "\u{626}\u{6D5}" },
    .{ .cp = 0xFBED, .to = "\u{626}\u{6D5}" },
    .{ .cp = 0xFBEE, .to = "\u{626}\u{648}" },
    .{ .cp = 0xFBEF, .to = "\u{626}\u{648}" },
    .{ .cp = 0xFBF0, .to = "\u{626}\u{6C7}" },
    .{ .cp = 0xFBF1, .to = "\u{626}\u{6C7}" },
    .{ .cp = 0xFBF2, .to = "\u{626}\u{6C6}" },
    .{ .cp = 0xFBF3, .to = "\u{626}\u{6C6}" },
    .{ .cp = 0xFBF4, .to = "\u{626}\u{6C8}" },
    .{ .cp = 0xFBF5, .to = "\u{626}\u{6C8}" },
    .{ .cp = 0xFBF6, .to = "\u{626}\u{6D0}" },
    .{ .cp = 0xFBF7, .to = "\u{626}\u{6D0}" },
    .{ .cp = 0xFBF8, .to = "\u{626}\u{6D0}" },
    .{ .cp = 0xFBF9, .to = "\u{626}\u{649}" },
    .{ .cp = 0xFBFA, .to = "\u{626}\u{649}" },
    .{ .cp = 0xFBFB, .to = "\u{626}\u{649}" },
    .{ .cp = 0xFBFC, .to = "\u{6CC}" },
    .{ .cp = 0xFBFD, .to = "\u{6CC}" },
    .{ .cp = 0xFBFE, .to = "\u{6CC}" },
    .{ .cp = 0xFBFF, .to = "\u{6CC}" },
    .{ .cp = 0xFC00, .to = "\u{626}\u{62C}" },
    .{ .cp = 0xFC01, .to = "\u{626}\u{62D}" },
    .{ .cp = 0xFC02, .to = "\u{626}\u{645}" },
    .{ .cp = 0xFC03, .to = "\u{626}\u{649}" },
    .{ .cp = 0xFC04, .to = "\u{626}\u{64A}" },
    .{ .cp = 0xFC05, .to = "\u{628}\u{62C}" },
    .{ .cp = 0xFC06, .to = "\u{628}\u{62D}" },
    .{ .cp = 0xFC07, .to = "\u{628}\u{62E}" },
    .{ .cp = 0xFC08, .to = "\u{628}\u{645}" },
    .{ .cp = 0xFC09, .to = "\u{628}\u{649}" },
    .{ .cp = 0xFC0A, .to = "\u{628}\u{64A}" },
    .{ .cp = 0xFC0B, .to = "\u{62A}\u{62C}" },
    .{ .cp = 0xFC0C, .to = "\u{62A}\u{62D}" },
    .{ .cp = 0xFC0D, .to = "\u{62A}\u{62E}" },
    .{ .cp = 0xFC0E, .to = "\u{62A}\u{645}" },
    .{ .cp = 0xFC0F, .to = "\u{62A}\u{649}" },
    .{ .cp = 0xFC10, .to = "\u{62A}\u{64A}" },
    .{ .cp = 0xFC11, .to = "\u{62B}\u{62C}" },
    .{ .cp = 0xFC12, .to = "\u{62B}\u{645}" },
    .{ .cp = 0xFC13, .to = "\u{62B}\u{649}" },
    .{ .cp = 0xFC14, .to = "\u{62B}\u{64A}" },
    .{ .cp = 0xFC15, .to = "\u{62C}\u{62D}" },
    .{ .cp = 0xFC16, .to = "\u{62C}\u{645}" },
    .{ .cp = 0xFC17, .to = "\u{62D}\u{62C}" },
    .{ .cp = 0xFC18, .to = "\u{62D}\u{645}" },
    .{ .cp = 0xFC19, .to = "\u{62E}\u{62C}" },
    .{ .cp = 0xFC1A, .to = "\u{62E}\u{62D}" },
    .{ .cp = 0xFC1B, .to = "\u{62E}\u{645}" },
    .{ .cp = 0xFC1C, .to = "\u{633}\u{62C}" },
    .{ .cp = 0xFC1D, .to = "\u{633}\u{62D}" },
    .{ .cp = 0xFC1E, .to = "\u{633}\u{62E}" },
    .{ .cp = 0xFC1F, .to = "\u{633}\u{645}" },
    .{ .cp = 0xFC20, .to = "\u{635}\u{62D}" },
    .{ .cp = 0xFC21, .to = "\u{635}\u{645}" },
    .{ .cp = 0xFC22, .to = "\u{636}\u{62C}" },
    .{ .cp = 0xFC23, .to = "\u{636}\u{62D}" },
    .{ .cp = 0xFC24, .to = "\u{636}\u{62E}" },
    .{ .cp = 0xFC25, .to = "\u{636}\u{645}" },
    .{ .cp = 0xFC26, .to = "\u{637}\u{62D}" },
    .{ .cp = 0xFC27, .to = "\u{637}\u{645}" },
    .{ .cp = 0xFC28, .to = "\u{638}\u{645}" },
    .{ .cp = 0xFC29, .to = "\u{639}\u{62C}" },
    .{ .cp = 0xFC2A, .to = "\u{639}\u{645}" },
    .{ .cp = 0xFC2B, .to = "\u{63A}\u{62C}" },
    .{ .cp = 0xFC2C, .to = "\u{63A}\u{645}" },
    .{ .cp = 0xFC2D, .to = "\u{641}\u{62C}" },
    .{ .cp = 0xFC2E, .to = "\u{641}\u{62D}" },
    .{ .cp = 0xFC2F, .to = "\u{641}\u{62E}" },
    .{ .cp = 0xFC30, .to = "\u{641}\u{645}" },
    .{ .cp = 0xFC31, .to = "\u{641}\u{649}" },
    .{ .cp = 0xFC32, .to = "\u{641}\u{64A}" },
    .{ .cp = 0xFC33, .to = "\u{642}\u{62D}" },
    .{ .cp = 0xFC34, .to = "\u{642}\u{645}" },
    .{ .cp = 0xFC35, .to = "\u{642}\u{649}" },
    .{ .cp = 0xFC36, .to = "\u{642}\u{64A}" },
    .{ .cp = 0xFC37, .to = "\u{643}\u{627}" },
    .{ .cp = 0xFC38, .to = "\u{643}\u{62C}" },
    .{ .cp = 0xFC39, .to = "\u{643}\u{62D}" },
    .{ .cp = 0xFC3A, .to = "\u{643}\u{62E}" },
    .{ .cp = 0xFC3B, .to = "\u{643}\u{644}" },
    .{ .cp = 0xFC3C, .to = "\u{643}\u{645}" },
    .{ .cp = 0xFC3D, .to = "\u{643}\u{649}" },
    .{ .cp = 0xFC3E, .to = "\u{643}\u{64A}" },
    .{ .cp = 0xFC3F, .to = "\u{644}\u{62C}" },
    .{ .cp = 0xFC40, .to = "\u{644}\u{62D}" },
    .{ .cp = 0xFC41, .to = "\u{644}\u{62E}" },
    .{ .cp = 0xFC42, .to = "\u{644}\u{645}" },
    .{ .cp = 0xFC43, .to = "\u{644}\u{649}" },
    .{ .cp = 0xFC44, .to = "\u{644}\u{64A}" },
    .{ .cp = 0xFC45, .to = "\u{645}\u{62C}" },
    .{ .cp = 0xFC46, .to = "\u{645}\u{62D}" },
    .{ .cp = 0xFC47, .to = "\u{645}\u{62E}" },
    .{ .cp = 0xFC48, .to = "\u{645}\u{645}" },
    .{ .cp = 0xFC49, .to = "\u{645}\u{649}" },
    .{ .cp = 0xFC4A, .to = "\u{645}\u{64A}" },
    .{ .cp = 0xFC4B, .to = "\u{646}\u{62C}" },
    .{ .cp = 0xFC4C, .to = "\u{646}\u{62D}" },
    .{ .cp = 0xFC4D, .to = "\u{646}\u{62E}" },
    .{ .cp = 0xFC4E, .to = "\u{646}\u{645}" },
    .{ .cp = 0xFC4F, .to = "\u{646}\u{649}" },
    .{ .cp = 0xFC50, .to = "\u{646}\u{64A}" },
    .{ .cp = 0xFC51, .to = "\u{647}\u{62C}" },
    .{ .cp = 0xFC52, .to = "\u{647}\u{645}" },
    .{ .cp = 0xFC53, .to = "\u{647}\u{649}" },
    .{ .cp = 0xFC54, .to = "\u{647}\u{64A}" },
    .{ .cp = 0xFC55, .to = "\u{64A}\u{62C}" },
    .{ .cp = 0xFC56, .to = "\u{64A}\u{62D}" },
    .{ .cp = 0xFC57, .to = "\u{64A}\u{62E}" },
    .{ .cp = 0xFC58, .to = "\u{64A}\u{645}" },
    .{ .cp = 0xFC59, .to = "\u{64A}\u{649}" },
    .{ .cp = 0xFC5A, .to = "\u{64A}\u{64A}" },
    .{ .cp = 0xFC5B, .to = "\u{630}\u{670}" },
    .{ .cp = 0xFC5C, .to = "\u{631}\u{670}" },
    .{ .cp = 0xFC5D, .to = "\u{649}\u{670}" },
    .{ .cp = 0xFC5E, .to = "\u{20}\u{64C}\u{651}" },
    .{ .cp = 0xFC5F, .to = "\u{20}\u{64D}\u{651}" },
    .{ .cp = 0xFC60, .to = "\u{20}\u{64E}\u{651}" },
    .{ .cp = 0xFC61, .to = "\u{20}\u{64F}\u{651}" },
    .{ .cp = 0xFC62, .to = "\u{20}\u{650}\u{651}" },
    .{ .cp = 0xFC63, .to = "\u{20}\u{651}\u{670}" },
    .{ .cp = 0xFC64, .to = "\u{626}\u{631}" },
    .{ .cp = 0xFC65, .to = "\u{626}\u{632}" },
    .{ .cp = 0xFC66, .to = "\u{626}\u{645}" },
    .{ .cp = 0xFC67, .to = "\u{626}\u{646}" },
    .{ .cp = 0xFC68, .to = "\u{626}\u{649}" },
    .{ .cp = 0xFC69, .to = "\u{626}\u{64A}" },
    .{ .cp = 0xFC6A, .to = "\u{628}\u{631}" },
    .{ .cp = 0xFC6B, .to = "\u{628}\u{632}" },
    .{ .cp = 0xFC6C, .to = "\u{628}\u{645}" },
    .{ .cp = 0xFC6D, .to = "\u{628}\u{646}" },
    .{ .cp = 0xFC6E, .to = "\u{628}\u{649}" },
    .{ .cp = 0xFC6F, .to = "\u{628}\u{64A}" },
    .{ .cp = 0xFC70, .to = "\u{62A}\u{631}" },
    .{ .cp = 0xFC71, .to = "\u{62A}\u{632}" },
    .{ .cp = 0xFC72, .to = "\u{62A}\u{645}" },
    .{ .cp = 0xFC73, .to = "\u{62A}\u{646}" },
    .{ .cp = 0xFC74, .to = "\u{62A}\u{649}" },
    .{ .cp = 0xFC75, .to = "\u{62A}\u{64A}" },
    .{ .cp = 0xFC76, .to = "\u{62B}\u{631}" },
    .{ .cp = 0xFC77, .to = "\u{62B}\u{632}" },
    .{ .cp = 0xFC78, .to = "\u{62B}\u{645}" },
    .{ .cp = 0xFC79, .to = "\u{62B}\u{646}" },
    .{ .cp = 0xFC7A, .to = "\u{62B}\u{649}" },
    .{ .cp = 0xFC7B, .to = "\u{62B}\u{64A}" },
    .{ .cp = 0xFC7C, .to = "\u{641}\u{649}" },
    .{ .cp = 0xFC7D, .to = "\u{641}\u{64A}" },
    .{ .cp = 0xFC7E, .to = "\u{642}\u{649}" },
    .{ .cp = 0xFC7F, .to = "\u{642}\u{64A}" },
    .{ .cp = 0xFC80, .to = "\u{643}\u{627}" },
    .{ .cp = 0xFC81, .to = "\u{643}\u{644}" },
    .{ .cp = 0xFC82, .to = "\u{643}\u{645}" },
    .{ .cp = 0xFC83, .to = "\u{643}\u{649}" },
    .{ .cp = 0xFC84, .to = "\u{643}\u{64A}" },
    .{ .cp = 0xFC85, .to = "\u{644}\u{645}" },
    .{ .cp = 0xFC86, .to = "\u{644}\u{649}" },
    .{ .cp = 0xFC87, .to = "\u{644}\u{64A}" },
    .{ .cp = 0xFC88, .to = "\u{645}\u{627}" },
    .{ .cp = 0xFC89, .to = "\u{645}\u{645}" },
    .{ .cp = 0xFC8A, .to = "\u{646}\u{631}" },
    .{ .cp = 0xFC8B, .to = "\u{646}\u{632}" },
    .{ .cp = 0xFC8C, .to = "\u{646}\u{645}" },
    .{ .cp = 0xFC8D, .to = "\u{646}\u{646}" },
    .{ .cp = 0xFC8E, .to = "\u{646}\u{649}" },
    .{ .cp = 0xFC8F, .to = "\u{646}\u{64A}" },
    .{ .cp = 0xFC90, .to = "\u{649}\u{670}" },
    .{ .cp = 0xFC91, .to = "\u{64A}\u{631}" },
    .{ .cp = 0xFC92, .to = "\u{64A}\u{632}" },
    .{ .cp = 0xFC93, .to = "\u{64A}\u{645}" },
    .{ .cp = 0xFC94, .to = "\u{64A}\u{646}" },
    .{ .cp = 0xFC95, .to = "\u{64A}\u{649}" },
    .{ .cp = 0xFC96, .to = "\u{64A}\u{64A}" },
    .{ .cp = 0xFC97, .to = "\u{626}\u{62C}" },
    .{ .cp = 0xFC98, .to = "\u{626}\u{62D}" },
    .{ .cp = 0xFC99, .to = "\u{626}\u{62E}" },
    .{ .cp = 0xFC9A, .to = "\u{626}\u{645}" },
    .{ .cp = 0xFC9B, .to = "\u{626}\u{647}" },
    .{ .cp = 0xFC9C, .to = "\u{628}\u{62C}" },
    .{ .cp = 0xFC9D, .to = "\u{628}\u{62D}" },
    .{ .cp = 0xFC9E, .to = "\u{628}\u{62E}" },
    .{ .cp = 0xFC9F, .to = "\u{628}\u{645}" },
    .{ .cp = 0xFCA0, .to = "\u{628}\u{647}" },
    .{ .cp = 0xFCA1, .to = "\u{62A}\u{62C}" },
    .{ .cp = 0xFCA2, .to = "\u{62A}\u{62D}" },
    .{ .cp = 0xFCA3, .to = "\u{62A}\u{62E}" },
    .{ .cp = 0xFCA4, .to = "\u{62A}\u{645}" },
    .{ .cp = 0xFCA5, .to = "\u{62A}\u{647}" },
    .{ .cp = 0xFCA6, .to = "\u{62B}\u{645}" },
    .{ .cp = 0xFCA7, .to = "\u{62C}\u{62D}" },
    .{ .cp = 0xFCA8, .to = "\u{62C}\u{645}" },
    .{ .cp = 0xFCA9, .to = "\u{62D}\u{62C}" },
    .{ .cp = 0xFCAA, .to = "\u{62D}\u{645}" },
    .{ .cp = 0xFCAB, .to = "\u{62E}\u{62C}" },
    .{ .cp = 0xFCAC, .to = "\u{62E}\u{645}" },
    .{ .cp = 0xFCAD, .to = "\u{633}\u{62C}" },
    .{ .cp = 0xFCAE, .to = "\u{633}\u{62D}" },
    .{ .cp = 0xFCAF, .to = "\u{633}\u{62E}" },
    .{ .cp = 0xFCB0, .to = "\u{633}\u{645}" },
    .{ .cp = 0xFCB1, .to = "\u{635}\u{62D}" },
    .{ .cp = 0xFCB2, .to = "\u{635}\u{62E}" },
    .{ .cp = 0xFCB3, .to = "\u{635}\u{645}" },
    .{ .cp = 0xFCB4, .to = "\u{636}\u{62C}" },
    .{ .cp = 0xFCB5, .to = "\u{636}\u{62D}" },
    .{ .cp = 0xFCB6, .to = "\u{636}\u{62E}" },
    .{ .cp = 0xFCB7, .to = "\u{636}\u{645}" },
    .{ .cp = 0xFCB8, .to = "\u{637}\u{62D}" },
    .{ .cp = 0xFCB9, .to = "\u{638}\u{645}" },
    .{ .cp = 0xFCBA, .to = "\u{639}\u{62C}" },
    .{ .cp = 0xFCBB, .to = "\u{639}\u{645}" },
    .{ .cp = 0xFCBC, .to = "\u{63A}\u{62C}" },
    .{ .cp = 0xFCBD, .to = "\u{63A}\u{645}" },
    .{ .cp = 0xFCBE, .to = "\u{641}\u{62C}" },
    .{ .cp = 0xFCBF, .to = "\u{641}\u{62D}" },
    .{ .cp = 0xFCC0, .to = "\u{641}\u{62E}" },
    .{ .cp = 0xFCC1, .to = "\u{641}\u{645}" },
    .{ .cp = 0xFCC2, .to = "\u{642}\u{62D}" },
    .{ .cp = 0xFCC3, .to = "\u{642}\u{645}" },
    .{ .cp = 0xFCC4, .to = "\u{643}\u{62C}" },
    .{ .cp = 0xFCC5, .to = "\u{643}\u{62D}" },
    .{ .cp = 0xFCC6, .to = "\u{643}\u{62E}" },
    .{ .cp = 0xFCC7, .to = "\u{643}\u{644}" },
    .{ .cp = 0xFCC8, .to = "\u{643}\u{645}" },
    .{ .cp = 0xFCC9, .to = "\u{644}\u{62C}" },
    .{ .cp = 0xFCCA, .to = "\u{644}\u{62D}" },
    .{ .cp = 0xFCCB, .to = "\u{644}\u{62E}" },
    .{ .cp = 0xFCCC, .to = "\u{644}\u{645}" },
    .{ .cp = 0xFCCD, .to = "\u{644}\u{647}" },
    .{ .cp = 0xFCCE, .to = "\u{645}\u{62C}" },
    .{ .cp = 0xFCCF, .to = "\u{645}\u{62D}" },
    .{ .cp = 0xFCD0, .to = "\u{645}\u{62E}" },
    .{ .cp = 0xFCD1, .to = "\u{645}\u{645}" },
    .{ .cp = 0xFCD2, .to = "\u{646}\u{62C}" },
    .{ .cp = 0xFCD3, .to = "\u{646}\u{62D}" },
    .{ .cp = 0xFCD4, .to = "\u{646}\u{62E}" },
    .{ .cp = 0xFCD5, .to = "\u{646}\u{645}" },
    .{ .cp = 0xFCD6, .to = "\u{646}\u{647}" },
    .{ .cp = 0xFCD7, .to = "\u{647}\u{62C}" },
    .{ .cp = 0xFCD8, .to = "\u{647}\u{645}" },
    .{ .cp = 0xFCD9, .to = "\u{647}\u{670}" },
    .{ .cp = 0xFCDA, .to = "\u{64A}\u{62C}" },
    .{ .cp = 0xFCDB, .to = "\u{64A}\u{62D}" },
    .{ .cp = 0xFCDC, .to = "\u{64A}\u{62E}" },
    .{ .cp = 0xFCDD, .to = "\u{64A}\u{645}" },
    .{ .cp = 0xFCDE, .to = "\u{64A}\u{647}" },
    .{ .cp = 0xFCDF, .to = "\u{626}\u{645}" },
    .{ .cp = 0xFCE0, .to = "\u{626}\u{647}" },
    .{ .cp = 0xFCE1, .to = "\u{628}\u{645}" },
    .{ .cp = 0xFCE2, .to = "\u{628}\u{647}" },
    .{ .cp = 0xFCE3, .to = "\u{62A}\u{645}" },
    .{ .cp = 0xFCE4, .to = "\u{62A}\u{647}" },
    .{ .cp = 0xFCE5, .to = "\u{62B}\u{645}" },
    .{ .cp = 0xFCE6, .to = "\u{62B}\u{647}" },
    .{ .cp = 0xFCE7, .to = "\u{633}\u{645}" },
    .{ .cp = 0xFCE8, .to = "\u{633}\u{647}" },
    .{ .cp = 0xFCE9, .to = "\u{634}\u{645}" },
    .{ .cp = 0xFCEA, .to = "\u{634}\u{647}" },
    .{ .cp = 0xFCEB, .to = "\u{643}\u{644}" },
    .{ .cp = 0xFCEC, .to = "\u{643}\u{645}" },
    .{ .cp = 0xFCED, .to = "\u{644}\u{645}" },
    .{ .cp = 0xFCEE, .to = "\u{646}\u{645}" },
    .{ .cp = 0xFCEF, .to = "\u{646}\u{647}" },
    .{ .cp = 0xFCF0, .to = "\u{64A}\u{645}" },
    .{ .cp = 0xFCF1, .to = "\u{64A}\u{647}" },
    .{ .cp = 0xFCF2, .to = "\u{640}\u{64E}\u{651}" },
    .{ .cp = 0xFCF3, .to = "\u{640}\u{64F}\u{651}" },
    .{ .cp = 0xFCF4, .to = "\u{640}\u{650}\u{651}" },
    .{ .cp = 0xFCF5, .to = "\u{637}\u{649}" },
    .{ .cp = 0xFCF6, .to = "\u{637}\u{64A}" },
    .{ .cp = 0xFCF7, .to = "\u{639}\u{649}" },
    .{ .cp = 0xFCF8, .to = "\u{639}\u{64A}" },
    .{ .cp = 0xFCF9, .to = "\u{63A}\u{649}" },
    .{ .cp = 0xFCFA, .to = "\u{63A}\u{64A}" },
    .{ .cp = 0xFCFB, .to = "\u{633}\u{649}" },
    .{ .cp = 0xFCFC, .to = "\u{633}\u{64A}" },
    .{ .cp = 0xFCFD, .to = "\u{634}\u{649}" },
    .{ .cp = 0xFCFE, .to = "\u{634}\u{64A}" },
    .{ .cp = 0xFCFF, .to = "\u{62D}\u{649}" },
    .{ .cp = 0xFD00, .to = "\u{62D}\u{64A}" },
    .{ .cp = 0xFD01, .to = "\u{62C}\u{649}" },
    .{ .cp = 0xFD02, .to = "\u{62C}\u{64A}" },
    .{ .cp = 0xFD03, .to = "\u{62E}\u{649}" },
    .{ .cp = 0xFD04, .to = "\u{62E}\u{64A}" },
    .{ .cp = 0xFD05, .to = "\u{635}\u{649}" },
    .{ .cp = 0xFD06, .to = "\u{635}\u{64A}" },
    .{ .cp = 0xFD07, .to = "\u{636}\u{649}" },
    .{ .cp = 0xFD08, .to = "\u{636}\u{64A}" },
    .{ .cp = 0xFD09, .to = "\u{634}\u{62C}" },
    .{ .cp = 0xFD0A, .to = "\u{634}\u{62D}" },
    .{ .cp = 0xFD0B, .to = "\u{634}\u{62E}" },
    .{ .cp = 0xFD0C, .to = "\u{634}\u{645}" },
    .{ .cp = 0xFD0D, .to = "\u{634}\u{631}" },
    .{ .cp = 0xFD0E, .to = "\u{633}\u{631}" },
    .{ .cp = 0xFD0F, .to = "\u{635}\u{631}" },
    .{ .cp = 0xFD10, .to = "\u{636}\u{631}" },
    .{ .cp = 0xFD11, .to = "\u{637}\u{649}" },
    .{ .cp = 0xFD12, .to = "\u{637}\u{64A}" },
    .{ .cp = 0xFD13, .to = "\u{639}\u{649}" },
    .{ .cp = 0xFD14, .to = "\u{639}\u{64A}" },
    .{ .cp = 0xFD15, .to = "\u{63A}\u{649}" },
    .{ .cp = 0xFD16, .to = "\u{63A}\u{64A}" },
    .{ .cp = 0xFD17, .to = "\u{633}\u{649}" },
    .{ .cp = 0xFD18, .to = "\u{633}\u{64A}" },
    .{ .cp = 0xFD19, .to = "\u{634}\u{649}" },
    .{ .cp = 0xFD1A, .to = "\u{634}\u{64A}" },
    .{ .cp = 0xFD1B, .to = "\u{62D}\u{649}" },
    .{ .cp = 0xFD1C, .to = "\u{62D}\u{64A}" },
    .{ .cp = 0xFD1D, .to = "\u{62C}\u{649}" },
    .{ .cp = 0xFD1E, .to = "\u{62C}\u{64A}" },
    .{ .cp = 0xFD1F, .to = "\u{62E}\u{649}" },
    .{ .cp = 0xFD20, .to = "\u{62E}\u{64A}" },
    .{ .cp = 0xFD21, .to = "\u{635}\u{649}" },
    .{ .cp = 0xFD22, .to = "\u{635}\u{64A}" },
    .{ .cp = 0xFD23, .to = "\u{636}\u{649}" },
    .{ .cp = 0xFD24, .to = "\u{636}\u{64A}" },
    .{ .cp = 0xFD25, .to = "\u{634}\u{62C}" },
    .{ .cp = 0xFD26, .to = "\u{634}\u{62D}" },
    .{ .cp = 0xFD27, .to = "\u{634}\u{62E}" },
    .{ .cp = 0xFD28, .to = "\u{634}\u{645}" },
    .{ .cp = 0xFD29, .to = "\u{634}\u{631}" },
    .{ .cp = 0xFD2A, .to = "\u{633}\u{631}" },
    .{ .cp = 0xFD2B, .to = "\u{635}\u{631}" },
    .{ .cp = 0xFD2C, .to = "\u{636}\u{631}" },
    .{ .cp = 0xFD2D, .to = "\u{634}\u{62C}" },
    .{ .cp = 0xFD2E, .to = "\u{634}\u{62D}" },
    .{ .cp = 0xFD2F, .to = "\u{634}\u{62E}" },
    .{ .cp = 0xFD30, .to = "\u{634}\u{645}" },
    .{ .cp = 0xFD31, .to = "\u{633}\u{647}" },
    .{ .cp = 0xFD32, .to = "\u{634}\u{647}" },
    .{ .cp = 0xFD33, .to = "\u{637}\u{645}" },
    .{ .cp = 0xFD34, .to = "\u{633}\u{62C}" },
    .{ .cp = 0xFD35, .to = "\u{633}\u{62D}" },
    .{ .cp = 0xFD36, .to = "\u{633}\u{62E}" },
    .{ .cp = 0xFD37, .to = "\u{634}\u{62C}" },
    .{ .cp = 0xFD38, .to = "\u{634}\u{62D}" },
    .{ .cp = 0xFD39, .to = "\u{634}\u{62E}" },
    .{ .cp = 0xFD3A, .to = "\u{637}\u{645}" },
    .{ .cp = 0xFD3B, .to = "\u{638}\u{645}" },
    .{ .cp = 0xFD3C, .to = "\u{627}\u{64B}" },
    .{ .cp = 0xFD3D, .to = "\u{627}\u{64B}" },
    .{ .cp = 0xFD50, .to = "\u{62A}\u{62C}\u{645}" },
    .{ .cp = 0xFD51, .to = "\u{62A}\u{62D}\u{62C}" },
    .{ .cp = 0xFD52, .to = "\u{62A}\u{62D}\u{62C}" },
    .{ .cp = 0xFD53, .to = "\u{62A}\u{62D}\u{645}" },
    .{ .cp = 0xFD54, .to = "\u{62A}\u{62E}\u{645}" },
    .{ .cp = 0xFD55, .to = "\u{62A}\u{645}\u{62C}" },
    .{ .cp = 0xFD56, .to = "\u{62A}\u{645}\u{62D}" },
    .{ .cp = 0xFD57, .to = "\u{62A}\u{645}\u{62E}" },
    .{ .cp = 0xFD58, .to = "\u{62C}\u{645}\u{62D}" },
    .{ .cp = 0xFD59, .to = "\u{62C}\u{645}\u{62D}" },
    .{ .cp = 0xFD5A, .to = "\u{62D}\u{645}\u{64A}" },
    .{ .cp = 0xFD5B, .to = "\u{62D}\u{645}\u{649}" },
    .{ .cp = 0xFD5C, .to = "\u{633}\u{62D}\u{62C}" },
    .{ .cp = 0xFD5D, .to = "\u{633}\u{62C}\u{62D}" },
    .{ .cp = 0xFD5E, .to = "\u{633}\u{62C}\u{649}" },
    .{ .cp = 0xFD5F, .to = "\u{633}\u{645}\u{62D}" },
    .{ .cp = 0xFD60, .to = "\u{633}\u{645}\u{62D}" },
    .{ .cp = 0xFD61, .to = "\u{633}\u{645}\u{62C}" },
    .{ .cp = 0xFD62, .to = "\u{633}\u{645}\u{645}" },
    .{ .cp = 0xFD63, .to = "\u{633}\u{645}\u{645}" },
    .{ .cp = 0xFD64, .to = "\u{635}\u{62D}\u{62D}" },
    .{ .cp = 0xFD65, .to = "\u{635}\u{62D}\u{62D}" },
    .{ .cp = 0xFD66, .to = "\u{635}\u{645}\u{645}" },
    .{ .cp = 0xFD67, .to = "\u{634}\u{62D}\u{645}" },
    .{ .cp = 0xFD68, .to = "\u{634}\u{62D}\u{645}" },
    .{ .cp = 0xFD69, .to = "\u{634}\u{62C}\u{64A}" },
    .{ .cp = 0xFD6A, .to = "\u{634}\u{645}\u{62E}" },
    .{ .cp = 0xFD6B, .to = "\u{634}\u{645}\u{62E}" },
    .{ .cp = 0xFD6C, .to = "\u{634}\u{645}\u{645}" },
    .{ .cp = 0xFD6D, .to = "\u{634}\u{645}\u{645}" },
    .{ .cp = 0xFD6E, .to = "\u{636}\u{62D}\u{649}" },
    .{ .cp = 0xFD6F, .to = "\u{636}\u{62E}\u{645}" },
    .{ .cp = 0xFD70, .to = "\u{636}\u{62E}\u{645}" },
    .{ .cp = 0xFD71, .to = "\u{637}\u{645}\u{62D}" },
    .{ .cp = 0xFD72, .to = "\u{637}\u{645}\u{62D}" },
    .{ .cp = 0xFD73, .to = "\u{637}\u{645}\u{645}" },
    .{ .cp = 0xFD74, .to = "\u{637}\u{645}\u{64A}" },
    .{ .cp = 0xFD75, .to = "\u{639}\u{62C}\u{645}" },
    .{ .cp = 0xFD76, .to = "\u{639}\u{645}\u{645}" },
    .{ .cp = 0xFD77, .to = "\u{639}\u{645}\u{645}" },
    .{ .cp = 0xFD78, .to = "\u{639}\u{645}\u{649}" },
    .{ .cp = 0xFD79, .to = "\u{63A}\u{645}\u{645}" },
    .{ .cp = 0xFD7A, .to = "\u{63A}\u{645}\u{64A}" },
    .{ .cp = 0xFD7B, .to = "\u{63A}\u{645}\u{649}" },
    .{ .cp = 0xFD7C, .to = "\u{641}\u{62E}\u{645}" },
    .{ .cp = 0xFD7D, .to = "\u{641}\u{62E}\u{645}" },
    .{ .cp = 0xFD7E, .to = "\u{642}\u{645}\u{62D}" },
    .{ .cp = 0xFD7F, .to = "\u{642}\u{645}\u{645}" },
    .{ .cp = 0xFD80, .to = "\u{644}\u{62D}\u{645}" },
    .{ .cp = 0xFD81, .to = "\u{644}\u{62D}\u{64A}" },
    .{ .cp = 0xFD82, .to = "\u{644}\u{62D}\u{649}" },
    .{ .cp = 0xFD83, .to = "\u{644}\u{62C}\u{62C}" },
    .{ .cp = 0xFD84, .to = "\u{644}\u{62C}\u{62C}" },
    .{ .cp = 0xFD85, .to = "\u{644}\u{62E}\u{645}" },
    .{ .cp = 0xFD86, .to = "\u{644}\u{62E}\u{645}" },
    .{ .cp = 0xFD87, .to = "\u{644}\u{645}\u{62D}" },
    .{ .cp = 0xFD88, .to = "\u{644}\u{645}\u{62D}" },
    .{ .cp = 0xFD89, .to = "\u{645}\u{62D}\u{62C}" },
    .{ .cp = 0xFD8A, .to = "\u{645}\u{62D}\u{645}" },
    .{ .cp = 0xFD8B, .to = "\u{645}\u{62D}\u{64A}" },
    .{ .cp = 0xFD8C, .to = "\u{645}\u{62C}\u{62D}" },
    .{ .cp = 0xFD8D, .to = "\u{645}\u{62C}\u{645}" },
    .{ .cp = 0xFD8E, .to = "\u{645}\u{62E}\u{62C}" },
    .{ .cp = 0xFD8F, .to = "\u{645}\u{62E}\u{645}" },
    .{ .cp = 0xFD92, .to = "\u{645}\u{62C}\u{62E}" },
    .{ .cp = 0xFD93, .to = "\u{647}\u{645}\u{62C}" },
    .{ .cp = 0xFD94, .to = "\u{647}\u{645}\u{645}" },
    .{ .cp = 0xFD95, .to = "\u{646}\u{62D}\u{645}" },
    .{ .cp = 0xFD96, .to = "\u{646}\u{62D}\u{649}" },
    .{ .cp = 0xFD97, .to = "\u{646}\u{62C}\u{645}" },
    .{ .cp = 0xFD98, .to = "\u{646}\u{62C}\u{645}" },
    .{ .cp = 0xFD99, .to = "\u{646}\u{62C}\u{649}" },
    .{ .cp = 0xFD9A, .to = "\u{646}\u{645}\u{64A}" },
    .{ .cp = 0xFD9B, .to = "\u{646}\u{645}\u{649}" },
    .{ .cp = 0xFD9C, .to = "\u{64A}\u{645}\u{645}" },
    .{ .cp = 0xFD9D, .to = "\u{64A}\u{645}\u{645}" },
    .{ .cp = 0xFD9E, .to = "\u{628}\u{62E}\u{64A}" },
    .{ .cp = 0xFD9F, .to = "\u{62A}\u{62C}\u{64A}" },
    .{ .cp = 0xFDA0, .to = "\u{62A}\u{62C}\u{649}" },
    .{ .cp = 0xFDA1, .to = "\u{62A}\u{62E}\u{64A}" },
    .{ .cp = 0xFDA2, .to = "\u{62A}\u{62E}\u{649}" },
    .{ .cp = 0xFDA3, .to = "\u{62A}\u{645}\u{64A}" },
    .{ .cp = 0xFDA4, .to = "\u{62A}\u{645}\u{649}" },
    .{ .cp = 0xFDA5, .to = "\u{62C}\u{645}\u{64A}" },
    .{ .cp = 0xFDA6, .to = "\u{62C}\u{62D}\u{649}" },
    .{ .cp = 0xFDA7, .to = "\u{62C}\u{645}\u{649}" },
    .{ .cp = 0xFDA8, .to = "\u{633}\u{62E}\u{649}" },
    .{ .cp = 0xFDA9, .to = "\u{635}\u{62D}\u{64A}" },
    .{ .cp = 0xFDAA, .to = "\u{634}\u{62D}\u{64A}" },
    .{ .cp = 0xFDAB, .to = "\u{636}\u{62D}\u{64A}" },
    .{ .cp = 0xFDAC, .to = "\u{644}\u{62C}\u{64A}" },
    .{ .cp = 0xFDAD, .to = "\u{644}\u{645}\u{64A}" },
    .{ .cp = 0xFDAE, .to = "\u{64A}\u{62D}\u{64A}" },
    .{ .cp = 0xFDAF, .to = "\u{64A}\u{62C}\u{64A}" },
    .{ .cp = 0xFDB0, .to = "\u{64A}\u{645}\u{64A}" },
    .{ .cp = 0xFDB1, .to = "\u{645}\u{645}\u{64A}" },
    .{ .cp = 0xFDB2, .to = "\u{642}\u{645}\u{64A}" },
    .{ .cp = 0xFDB3, .to = "\u{646}\u{62D}\u{64A}" },
    .{ .cp = 0xFDB4, .to = "\u{642}\u{645}\u{62D}" },
    .{ .cp = 0xFDB5, .to = "\u{644}\u{62D}\u{645}" },
    .{ .cp = 0xFDB6, .to = "\u{639}\u{645}\u{64A}" },
    .{ .cp = 0xFDB7, .to = "\u{643}\u{645}\u{64A}" },
    .{ .cp = 0xFDB8, .to = "\u{646}\u{62C}\u{62D}" },
    .{ .cp = 0xFDB9, .to = "\u{645}\u{62E}\u{64A}" },
    .{ .cp = 0xFDBA, .to = "\u{644}\u{62C}\u{645}" },
    .{ .cp = 0xFDBB, .to = "\u{643}\u{645}\u{645}" },
    .{ .cp = 0xFDBC, .to = "\u{644}\u{62C}\u{645}" },
    .{ .cp = 0xFDBD, .to = "\u{646}\u{62C}\u{62D}" },
    .{ .cp = 0xFDBE, .to = "\u{62C}\u{62D}\u{64A}" },
    .{ .cp = 0xFDBF, .to = "\u{62D}\u{62C}\u{64A}" },
    .{ .cp = 0xFDC0, .to = "\u{645}\u{62C}\u{64A}" },
    .{ .cp = 0xFDC1, .to = "\u{641}\u{645}\u{64A}" },
    .{ .cp = 0xFDC2, .to = "\u{628}\u{62D}\u{64A}" },
    .{ .cp = 0xFDC3, .to = "\u{643}\u{645}\u{645}" },
    .{ .cp = 0xFDC4, .to = "\u{639}\u{62C}\u{645}" },
    .{ .cp = 0xFDC5, .to = "\u{635}\u{645}\u{645}" },
    .{ .cp = 0xFDC6, .to = "\u{633}\u{62E}\u{64A}" },
    .{ .cp = 0xFDC7, .to = "\u{646}\u{62C}\u{64A}" },
    .{ .cp = 0xFDF0, .to = "\u{635}\u{644}\u{6D2}" },
    .{ .cp = 0xFDF1, .to = "\u{642}\u{644}\u{6D2}" },
    .{ .cp = 0xFDF2, .to = "\u{627}\u{644}\u{644}\u{647}" },
    .{ .cp = 0xFDF3, .to = "\u{627}\u{643}\u{628}\u{631}" },
    .{ .cp = 0xFDF4, .to = "\u{645}\u{62D}\u{645}\u{62F}" },
    .{ .cp = 0xFDF5, .to = "\u{635}\u{644}\u{639}\u{645}" },
    .{ .cp = 0xFDF6, .to = "\u{631}\u{633}\u{648}\u{644}" },
    .{ .cp = 0xFDF7, .to = "\u{639}\u{644}\u{64A}\u{647}" },
    .{ .cp = 0xFDF8, .to = "\u{648}\u{633}\u{644}\u{645}" },
    .{ .cp = 0xFDF9, .to = "\u{635}\u{644}\u{649}" },
    .{ .cp = 0xFDFA, .to = "\u{635}\u{644}\u{649}\u{20}\u{627}\u{644}\u{644}\u{647}\u{20}\u{639}\u{644}\u{64A}\u{647}\u{20}\u{648}\u{633}\u{644}\u{645}" },
    .{ .cp = 0xFDFB, .to = "\u{62C}\u{644}\u{20}\u{62C}\u{644}\u{627}\u{644}\u{647}" },
    .{ .cp = 0xFDFC, .to = "\u{631}\u{6CC}\u{627}\u{644}" },
    .{ .cp = 0xFE70, .to = "\u{20}\u{64B}" },
    .{ .cp = 0xFE71, .to = "\u{640}\u{64B}" },
    .{ .cp = 0xFE72, .to = "\u{20}\u{64C}" },
    .{ .cp = 0xFE74, .to = "\u{20}\u{64D}" },
    .{ .cp = 0xFE76, .to = "\u{20}\u{64E}" },
    .{ .cp = 0xFE77, .to = "\u{640}\u{64E}" },
    .{ .cp = 0xFE78, .to = "\u{20}\u{64F}" },
    .{ .cp = 0xFE79, .to = "\u{640}\u{64F}" },
    .{ .cp = 0xFE7A, .to = "\u{20}\u{650}" },
    .{ .cp = 0xFE7B, .to = "\u{640}\u{650}" },
    .{ .cp = 0xFE7C, .to = "\u{20}\u{651}" },
    .{ .cp = 0xFE7D, .to = "\u{640}\u{651}" },
    .{ .cp = 0xFE7E, .to = "\u{20}\u{652}" },
    .{ .cp = 0xFE7F, .to = "\u{640}\u{652}" },
    .{ .cp = 0xFE80, .to = "\u{621}" },
    .{ .cp = 0xFE81, .to = "\u{622}" },
    .{ .cp = 0xFE82, .to = "\u{622}" },
    .{ .cp = 0xFE83, .to = "\u{623}" },
    .{ .cp = 0xFE84, .to = "\u{623}" },
    .{ .cp = 0xFE85, .to = "\u{624}" },
    .{ .cp = 0xFE86, .to = "\u{624}" },
    .{ .cp = 0xFE87, .to = "\u{625}" },
    .{ .cp = 0xFE88, .to = "\u{625}" },
    .{ .cp = 0xFE89, .to = "\u{626}" },
    .{ .cp = 0xFE8A, .to = "\u{626}" },
    .{ .cp = 0xFE8B, .to = "\u{626}" },
    .{ .cp = 0xFE8C, .to = "\u{626}" },
    .{ .cp = 0xFE8D, .to = "\u{627}" },
    .{ .cp = 0xFE8E, .to = "\u{627}" },
    .{ .cp = 0xFE8F, .to = "\u{628}" },
    .{ .cp = 0xFE90, .to = "\u{628}" },
    .{ .cp = 0xFE91, .to = "\u{628}" },
    .{ .cp = 0xFE92, .to = "\u{628}" },
    .{ .cp = 0xFE93, .to = "\u{629}" },
    .{ .cp = 0xFE94, .to = "\u{629}" },
    .{ .cp = 0xFE95, .to = "\u{62A}" },
    .{ .cp = 0xFE96, .to = "\u{62A}" },
    .{ .cp = 0xFE97, .to = "\u{62A}" },
    .{ .cp = 0xFE98, .to = "\u{62A}" },
    .{ .cp = 0xFE99, .to = "\u{62B}" },
    .{ .cp = 0xFE9A, .to = "\u{62B}" },
    .{ .cp = 0xFE9B, .to = "\u{62B}" },
    .{ .cp = 0xFE9C, .to = "\u{62B}" },
    .{ .cp = 0xFE9D, .to = "\u{62C}" },
    .{ .cp = 0xFE9E, .to = "\u{62C}" },
    .{ .cp = 0xFE9F, .to = "\u{62C}" },
    .{ .cp = 0xFEA0, .to = "\u{62C}" },
    .{ .cp = 0xFEA1, .to = "\u{62D}" },
    .{ .cp = 0xFEA2, .to = "\u{62D}" },
    .{ .cp = 0xFEA3, .to = "\u{62D}" },
    .{ .cp = 0xFEA4, .to = "\u{62D}" },
    .{ .cp = 0xFEA5, .to = "\u{62E}" },
    .{ .cp = 0xFEA6, .to = "\u{62E}" },
    .{ .cp = 0xFEA7, .to = "\u{62E}" },
    .{ .cp = 0xFEA8, .to = "\u{62E}" },
    .{ .cp = 0xFEA9, .to = "\u{62F}" },
    .{ .cp = 0xFEAA, .to = "\u{62F}" },
    .{ .cp = 0xFEAB, .to = "\u{630}" },
    .{ .cp = 0xFEAC, .to = "\u{630}" },
    .{ .cp = 0xFEAD, .to = "\u{631}" },
    .{ .cp = 0xFEAE, .to = "\u{631}" },
    .{ .cp = 0xFEAF, .to = "\u{632}" },
    .{ .cp = 0xFEB0, .to = "\u{632}" },
    .{ .cp = 0xFEB1, .to = "\u{633}" },
    .{ .cp = 0xFEB2, .to = "\u{633}" },
    .{ .cp = 0xFEB3, .to = "\u{633}" },
    .{ .cp = 0xFEB4, .to = "\u{633}" },
    .{ .cp = 0xFEB5, .to = "\u{634}" },
    .{ .cp = 0xFEB6, .to = "\u{634}" },
    .{ .cp = 0xFEB7, .to = "\u{634}" },
    .{ .cp = 0xFEB8, .to = "\u{634}" },
    .{ .cp = 0xFEB9, .to = "\u{635}" },
    .{ .cp = 0xFEBA, .to = "\u{635}" },
    .{ .cp = 0xFEBB, .to = "\u{635}" },
    .{ .cp = 0xFEBC, .to = "\u{635}" },
    .{ .cp = 0xFEBD, .to = "\u{636}" },
    .{ .cp = 0xFEBE, .to = "\u{636}" },
    .{ .cp = 0xFEBF, .to = "\u{636}" },
    .{ .cp = 0xFEC0, .to = "\u{636}" },
    .{ .cp = 0xFEC1, .to = "\u{637}" },
    .{ .cp = 0xFEC2, .to = "\u{637}" },
    .{ .cp = 0xFEC3, .to = "\u{637}" },
    .{ .cp = 0xFEC4, .to = "\u{637}" },
    .{ .cp = 0xFEC5, .to = "\u{638}" },
    .{ .cp = 0xFEC6, .to = "\u{638}" },
    .{ .cp = 0xFEC7, .to = "\u{638}" },
    .{ .cp = 0xFEC8, .to = "\u{638}" },
    .{ .cp = 0xFEC9, .to = "\u{639}" },
    .{ .cp = 0xFECA, .to = "\u{639}" },
    .{ .cp = 0xFECB, .to = "\u{639}" },
    .{ .cp = 0xFECC, .to = "\u{639}" },
    .{ .cp = 0xFECD, .to = "\u{63A}" },
    .{ .cp = 0xFECE, .to = "\u{63A}" },
    .{ .cp = 0xFECF, .to = "\u{63A}" },
    .{ .cp = 0xFED0, .to = "\u{63A}" },
    .{ .cp = 0xFED1, .to = "\u{641}" },
    .{ .cp = 0xFED2, .to = "\u{641}" },
    .{ .cp = 0xFED3, .to = "\u{641}" },
    .{ .cp = 0xFED4, .to = "\u{641}" },
    .{ .cp = 0xFED5, .to = "\u{642}" },
    .{ .cp = 0xFED6, .to = "\u{642}" },
    .{ .cp = 0xFED7, .to = "\u{642}" },
    .{ .cp = 0xFED8, .to = "\u{642}" },
    .{ .cp = 0xFED9, .to = "\u{643}" },
    .{ .cp = 0xFEDA, .to = "\u{643}" },
    .{ .cp = 0xFEDB, .to = "\u{643}" },
    .{ .cp = 0xFEDC, .to = "\u{643}" },
    .{ .cp = 0xFEDD, .to = "\u{644}" },
    .{ .cp = 0xFEDE, .to = "\u{644}" },
    .{ .cp = 0xFEDF, .to = "\u{644}" },
    .{ .cp = 0xFEE0, .to = "\u{644}" },
    .{ .cp = 0xFEE1, .to = "\u{645}" },
    .{ .cp = 0xFEE2, .to = "\u{645}" },
    .{ .cp = 0xFEE3, .to = "\u{645}" },
    .{ .cp = 0xFEE4, .to = "\u{645}" },
    .{ .cp = 0xFEE5, .to = "\u{646}" },
    .{ .cp = 0xFEE6, .to = "\u{646}" },
    .{ .cp = 0xFEE7, .to = "\u{646}" },
    .{ .cp = 0xFEE8, .to = "\u{646}" },
    .{ .cp = 0xFEE9, .to = "\u{647}" },
    .{ .cp = 0xFEEA, .to = "\u{647}" },
    .{ .cp = 0xFEEB, .to = "\u{647}" },
    .{ .cp = 0xFEEC, .to = "\u{647}" },
    .{ .cp = 0xFEED, .to = "\u{648}" },
    .{ .cp = 0xFEEE, .to = "\u{648}" },
    .{ .cp = 0xFEEF, .to = "\u{649}" },
    .{ .cp = 0xFEF0, .to = "\u{649}" },
    .{ .cp = 0xFEF1, .to = "\u{64A}" },
    .{ .cp = 0xFEF2, .to = "\u{64A}" },
    .{ .cp = 0xFEF3, .to = "\u{64A}" },
    .{ .cp = 0xFEF4, .to = "\u{64A}" },
    .{ .cp = 0xFEF5, .to = "\u{644}\u{622}" },
    .{ .cp = 0xFEF6, .to = "\u{644}\u{622}" },
    .{ .cp = 0xFEF7, .to = "\u{644}\u{623}" },
    .{ .cp = 0xFEF8, .to = "\u{644}\u{623}" },
    .{ .cp = 0xFEF9, .to = "\u{644}\u{625}" },
    .{ .cp = 0xFEFA, .to = "\u{644}\u{625}" },
    .{ .cp = 0xFEFB, .to = "\u{644}\u{627}" },
    .{ .cp = 0xFEFC, .to = "\u{644}\u{627}" },
};

fn pformOf(cp: u21) ?[]const u8 {
    var lo: usize = 0;
    var hi: usize = pforms_nfkc.len;
    while (lo < hi) {
        const m = (lo + hi) / 2;
        if (pforms_nfkc[m].cp == cp) return pforms_nfkc[m].to;
        if (pforms_nfkc[m].cp < cp) lo = m + 1 else hi = m;
    }
    return null;
}

fn arabicLogical(a: Allocator, t: []const u8) ![]const u8 {
    var cps: std.ArrayList(u21) = .empty;
    var view = std.unicode.Utf8View.init(t) catch return t;
    var it = view.iterator();
    while (it.nextCodepoint()) |cp0| {
        var cp = cp0;
        if (pformOf(cp)) |to| {
            var v2 = std.unicode.Utf8View.init(to) catch continue;
            var it2 = v2.iterator();
            while (it2.nextCodepoint()) |c2| try cps.append(a, c2);
            continue;
        }
        if (cp >= 0xFEF5 and cp <= 0xFEFC) {
            // lam with alef: two letters
            try cps.append(a, 0x0644);
            try cps.append(a, switch ((cp - 0xFEF5) / 2) {
                0 => 0x0622,
                1 => 0x0623,
                2 => 0x0625,
                else => 0x0627,
            });
            continue;
        }
        for (pforms_b) |pf| {
            if (cp >= pf.start and cp < pf.start + pf.n) {
                cp = pf.base;
                break;
            }
        }
        try cps.append(a, cp);
    }
    // Arabic text: teh marbuta or Arabic kaf present, and no letter specific to Persian or Urdu
    var arabic = false;
    var persian = false;
    for (cps.items) |cp| {
        if (cp == 0x0629 or cp == 0x0643) arabic = true;
        switch (cp) {
            0x067E, 0x0686, 0x0698, 0x06AF, 0x06A9, 0x06D2, 0x0679, 0x0688, 0x0691, 0x06BA => persian = true,
            else => {},
        }
    }
    var out: std.ArrayList(u8) = .empty;
    for (cps.items) |cp0| {
        var cp = cp0;
        if (arabic and !persian) {
            if (cp == 0x06CC) cp = 0x064A;
            if (cp == 0x06BE) cp = 0x0647;
        }
        var buf: [4]u8 = undefined;
        const n = std.unicode.utf8Encode(cp, &buf) catch continue;
        try out.appendSlice(a, buf[0..n]);
    }
    return out.items;
}

fn arabicDocFix(a: Allocator, blocks: []Block) !void {
    var arabic = false;
    var persian = false;
    var urdu = false;
    var script = false;
    for (blocks) |b| {
        var view = std.unicode.Utf8View.init(b.text) catch continue;
        var it = view.iterator();
        while (it.nextCodepoint()) |cp| {
            if (cp >= 0x0620 and cp <= 0x06FF) script = true;
            if (cp == 0x0629 or cp == 0x0643) arabic = true;
            switch (cp) {
                0x067E, 0x0686, 0x0698, 0x06AF, 0x06A9 => persian = true,
                0x06D2, 0x0679, 0x0688, 0x0691, 0x06BA, 0x06C1 => urdu = true,
                else => {},
            }
        }
    }
    // a font draws heh in its initial and medial forms with the glyph it shares with U+06BE, which only Urdu writes
    if (script and !urdu) {
        for (blocks) |*b| {
            for (b.rows) |row| for (row) |*c| {
                if (std.mem.indexOf(u8, c.*, "\u{06BE}") != null) c.* = try std.mem.replaceOwned(u8, a, c.*, "\u{06BE}", "\u{0647}");
            };
            if (std.mem.indexOf(u8, b.text, "\u{06BE}") != null) b.text = try std.mem.replaceOwned(u8, a, b.text, "\u{06BE}", "\u{0647}");
        }
    }
    // a Persian page writes the Extended digits; the glyphs it shares with the Arabic-Indic ones read as those
    if (persian and !urdu and !arabic) {
        for (blocks) |*b| {
            for (b.rows) |row| for (row) |*c| {
                c.* = try persianDigits(a, c.*);
            };
            b.text = try persianDigits(a, b.text);
        }
    }
    if (!arabic or persian or urdu) return;
    for (blocks) |*b| {
        for (b.rows) |row| for (row) |*c| {
            if (std.mem.indexOf(u8, c.*, "\u{06CC}") == null and std.mem.indexOf(u8, c.*, "\u{06BE}") == null) continue;
            const t = try std.mem.replaceOwned(u8, a, c.*, "\u{06CC}", "\u{064A}");
            c.* = try std.mem.replaceOwned(u8, a, t, "\u{06BE}", "\u{0647}");
        };
        if (std.mem.indexOf(u8, b.text, "\u{06CC}") == null and std.mem.indexOf(u8, b.text, "\u{06BE}") == null) continue;
        var t = try std.mem.replaceOwned(u8, a, b.text, "\u{06CC}", "\u{064A}");
        t = try std.mem.replaceOwned(u8, a, t, "\u{06BE}", "\u{0647}");
        b.text = t;
    }
}

fn isGreekLetter(cp: u21) bool {
    return (cp >= 0x0386 and cp <= 0x03CE) or (cp >= 0x1F00 and cp <= 0x1FFC);
}

fn greekMu(a: Allocator, t: []const u8) ![]const u8 {
    if (std.mem.indexOf(u8, t, "\u{00B5}") == null) return t;
    var cps: std.ArrayList(u21) = .empty;
    var view = std.unicode.Utf8View.init(t) catch return t;
    var it = view.iterator();
    while (it.nextCodepoint()) |cp| try cps.append(a, cp);
    var out: std.ArrayList(u8) = .empty;
    for (cps.items, 0..) |cp, i| {
        var c = cp;
        if (cp == 0x00B5) {
            const before = i > 0 and isGreekLetter(cps.items[i - 1]);
            const after = i + 1 < cps.items.len and isGreekLetter(cps.items[i + 1]);
            if (before or after) c = 0x03BC;
        }
        var b4: [4]u8 = undefined;
        const n = std.unicode.utf8Encode(c, &b4) catch 0;
        try out.appendSlice(a, b4[0..n]);
    }
    return out.items;
}

fn hasLetter(t: []const u8) bool {
    var view = std.unicode.Utf8View.init(t) catch return true;
    var it = view.iterator();
    while (it.nextCodepoint()) |cp| {
        if (isLtrCp(cp) or isRtlCp(cp)) return true;
        if ((cp >= 0x0900 and cp <= 0x0DFF) or (cp >= 0x1200 and cp <= 0x137F) or cp >= 0x3040) return true;
    }
    return false;
}

fn persianDigits(a: Allocator, t: []const u8) ![]const u8 {
    var out: std.ArrayList(u8) = .empty;
    var view = std.unicode.Utf8View.init(t) catch return t;
    var it = view.iterator();
    var changed = false;
    while (it.nextCodepoint()) |cp| {
        var c = cp;
        if (cp >= 0x0660 and cp <= 0x0669) {
            c = cp - 0x0660 + 0x06F0;
            changed = true;
        }
        var b4: [4]u8 = undefined;
        const n = std.unicode.utf8Encode(c, &b4) catch 0;
        try out.appendSlice(a, b4[0..n]);
    }
    return if (changed) out.items else t;
}

const Page = struct { glyphs: []Glyph, rules: []Rule, dots: []Rule, width: f32, height: f32 };

fn trimSpace(t: []const u8) []const u8 {
    var s0: usize = 0;
    var e: usize = t.len;
    while (true) {
        if (s0 < e and (t[s0] == ' ' or t[s0] == '\t')) {
            s0 += 1;
        } else if (s0 + 1 < e and t[s0] == 0xC2 and t[s0 + 1] == 0xA0) {
            s0 += 2;
        } else break;
    }
    while (true) {
        if (e > s0 and (t[e - 1] == ' ' or t[e - 1] == '\t')) {
            e -= 1;
        } else if (e >= s0 + 2 and t[e - 2] == 0xC2 and t[e - 1] == 0xA0) {
            e -= 2;
        } else break;
    }
    return t[s0..e];
}

fn isBlankGlyph(t: []const u8) bool {
    return trimSpace(t).len == 0;
}

// a space found between two glyphs of a right-to-left line, carried through its reordering
const space_item: u32 = std.math.maxInt(u32);

fn itemText(text: []const u8, gl: []Glyph, k: u32) []const u8 {
    if (k == space_item) return " ";
    return glyphText(text, gl[k]);
}

fn glyphText(text: []const u8, g: Glyph) []const u8 {
    return text[g.t0 .. g.t0 + g.tn];
}

// Rows of glyphs on one baseline, split into fragments wherever the horizontal gap is wider than a word gap.
fn fragments(a: Allocator, pg: Page, page_no: u32, text: []const u8, out: *std.ArrayList(Frag)) !void {
    const gl = pg.glyphs;
    if (gl.len == 0) return;
    var page_spaces = false;
    for (gl) |g| if (isBlankGlyph(glyphText(text, g))) {
        page_spaces = true;
        break;
    };
    const idx = try a.alloc(u32, gl.len);
    for (idx, 0..) |*v, k| v.* = @intCast(k);
    const ByY = struct {
        g: []Glyph,
        fn lt(ctx: @This(), l: u32, r: u32) bool {
            const a_ = ctx.g[l];
            const b_ = ctx.g[r];
            if (@abs(a_.y - b_.y) > 0.01) return a_.y < b_.y;
            return a_.x < b_.x;
        }
    };
    std.mem.sort(u32, idx, ByY{ .g = gl }, ByY.lt);
    var rows: std.ArrayList(std.ArrayList(u32)) = .empty;
    var row_y: f32 = -1e9;
    var row_size: f32 = 0;
    for (idx) |k| {
        const g = gl[k];
        if (rows.items.len == 0 or @abs(g.y - row_y) > 0.45 * @max(row_size, g.size)) {
            try rows.append(a, .empty);
            row_y = g.y;
            row_size = g.size;
        }
        try rows.items[rows.items.len - 1].append(a, k);
        row_size = @max(row_size, g.size);
    }
    const ByX = struct {
        g: []Glyph,
        fn lt(ctx: @This(), l: u32, r: u32) bool {
            return ctx.g[l].x < ctx.g[r].x;
        }
    };
    for (rows.items) |*row| {
        std.mem.sort(u32, row.items, ByX{ .g = gl }, ByX.lt);
        const row_spaces = page_spaces;
        var st: usize = 0;
        var k: usize = 1;
        var right: f32 = gl[row.items[0]].x + gl[row.items[0]].w;
        while (k <= row.items.len) : (k += 1) {
            var cut = k == row.items.len;
            if (!cut) {
                const prev = gl[row.items[k - 1]];
                const g = gl[row.items[k]];
                // (from the furthest right edge so far: a mark drawn inside its letter leaves no gap after it)
                const gap = g.x - right;
                right = @max(right, g.x + g.w);
                if (gap > 1.1 * @max(prev.size, g.size)) cut = true;
                // a producer that writes its spaces leaves no wide gap between two visible glyphs of one phrase
                if (row_spaces and gap > 0.5 * @max(prev.size, g.size) and !isBlankGlyph(glyphText(text, prev)) and !isBlankGlyph(glyphText(text, g))) cut = true;
            }
            if (!cut) continue;
            try out.append(a, try makeFrag(a, gl, row.items[st..k], text, page_no));
            st = k;
            if (k < row.items.len) right = gl[row.items[k]].x + gl[row.items[k]].w;
        }
    }
}

fn makeFrag(a: Allocator, gl: []Glyph, ids_in: []u32, text: []const u8, page_no: u32) !Frag {
    var kept: std.ArrayList(u32) = .empty;
    for (ids_in) |k| {
        const g = gl[k];
        if (isBlankGlyph(glyphText(text, g)) and g.w > 0) {
            var covered = false;
            for (ids_in) |o| {
                if (o == k) continue;
                const h = gl[o];
                if (isBlankGlyph(glyphText(text, h))) continue;
                const ov = @min(g.x + g.w, h.x + h.w) - @max(g.x, h.x);
                if (ov > 0.6 * g.w) {
                    covered = true;
                    break;
                }
            }
            if (covered) continue;
        }
        try kept.append(a, k);
    }
    const ids0: []u32 = try a.dupe(u32, if (kept.items.len > 0) kept.items else ids_in);
    var rtl: usize = 0;
    {
        var r0: usize = 0;
        var l0: usize = 0;
        for (ids0) |k| {
            const cp = firstCp(glyphText(text, gl[k]));
            if (isRtlCp(cp) and !isMarkCp(cp)) r0 += 1;
            if (isLtrCp(cp)) l0 += 1;
        }
        rtl = if (r0 > l0) 1 else 0;
    }
    // a right-to-left line is set from the right: each glyph's RIGHT edge is where the pen put it, and a kerned
    // alef tucked into a ra's tail has its origin right of the ra's ("al-dirasiya" read "al-darisiya")
    if (rtl == 1) {
        const ByRight = struct {
            g: []Glyph,
            fn lt(ctx: @This(), l: u32, r: u32) bool {
                return ctx.g[l].x + ctx.g[l].w < ctx.g[r].x + ctx.g[r].w;
            }
        };
        std.mem.sort(u32, ids0, ByRight{ .g = gl }, ByRight.lt);
    }
    // a combining mark sits over its letter: in the visual (left to right) order it goes right after that letter
    // on a left-to-right line and right before it on a right-to-left one, so the logical order is letter, mark
    var placed: std.ArrayList(u32) = .empty;
    {
        var marks: std.ArrayList(u32) = .empty;
        for (ids0) |k| {
            if (isMarkCp(firstCp(glyphText(text, gl[k])))) try marks.append(a, k) else try placed.append(a, k);
        }
        for (marks.items) |m| {
            const mc = gl[m].x + gl[m].w / 2;
            var at: usize = placed.items.len;
            var bd: f32 = 1e9;
            for (placed.items, 0..) |b, j| {
                // (a mark's base is a letter, never a space or a full stop a leaning mark overhangs)
                const bc = firstCp(glyphText(text, gl[b]));
                if (isMarkCp(bc) or !(isRtlCp(bc) or isLtrCp(bc))) continue;
                const g = gl[b];
                const d: f32 = if (mc >= g.x and mc <= g.x + g.w) 0 else @min(@abs(mc - g.x), @abs(mc - g.x - g.w));
                if (d < bd) {
                    bd = d;
                    at = j;
                }
            }
            if (at == placed.items.len) {
                try placed.append(a, m);
            } else if (rtl == 1) {
                try placed.insert(a, at, m);
            } else try placed.insert(a, at + 1, m);
        }
    }
    const ids: []u32 = placed.items;
    rtl = 0;
    var ltr: usize = 0;
    var sizes: f32 = 0;
    var nb: usize = 0;
    var ni: usize = 0;
    var nm: usize = 0;
    var x0: f32 = 1e9;
    var x1: f32 = -1e9;
    var base: f32 = 0;
    var maxsize: f32 = 0;
    for (ids) |k| {
        const g = gl[k];
        const cp = firstCp(glyphText(text, g));
        if (isRtlCp(cp)) rtl += 1;
        if (isLtrCp(cp)) ltr += 1;
        sizes += g.size;
        if (g.bold) nb += 1;
        if (g.italic) ni += 1;
        if (g.mono) nm += 1;
        const gt = glyphText(text, g);
        if (!isBlankGlyph(gt)) {
            x0 = @min(x0, g.x);
            x1 = @max(x1, g.x + g.w);
        }
        if (g.size >= maxsize) {
            maxsize = g.size;
            base = g.y;
        }
    }
    const size = sizes / @as(f32, @floatFromInt(ids.len));
    // the visual order, then the logical order for a right-to-left line
    var order = try a.dupe(u32, ids);
    var in_ltr: []bool = &.{};
    if (rtl > ltr) {
        var vis: std.ArrayList(u32) = .empty;
        var right: f32 = -1e9;
        var pvk: ?u32 = null;
        for (ids) |k| {
            const g = gl[k];
            const is_mark = isMarkCp(firstCp(glyphText(text, g)));
            if (pvk) |pk| {
                const pv = gl[pk];
                const gap = g.x - right;
                if (!is_mark and gap > 0.2 * @max(pv.size, g.size) and !isBlankGlyph(glyphText(text, pv)) and !isBlankGlyph(glyphText(text, g))) {
                    // the space goes before the marks placed ahead of this letter: they belong to it
                    var at = vis.items.len;
                    while (at > 0 and vis.items[at - 1] != space_item and isMarkCp(firstCp(glyphText(text, gl[vis.items[at - 1]])))) at -= 1;
                    try vis.insert(a, at, space_item);
                }
            }
            try vis.append(a, k);
            if (!is_mark) {
                right = @max(right, g.x + g.w);
                pvk = k;
            }
        }
        order = vis.items;
        std.mem.reverse(u32, order);
        in_ltr = try a.alloc(bool, order.len);
        @memset(in_ltr, false);
        // runs of left-to-right letters and digits inside it read left to right again
        var k: usize = 0;
        while (k < order.len) {
            const cp = firstCp(itemText(text, gl, order[k]));
            if (isLtrCp(cp) or isDigitCp(cp)) {
                var e = k;
                while (e + 1 < order.len) {
                    const c2 = firstCp(itemText(text, gl, order[e + 1]));
                    const strong = isLtrCp(c2) or isDigitCp(c2);
                    const inner = c2 == '.' or c2 == ',' or c2 == '-' or c2 == ':' or c2 == '/';
                    const c3: u21 = if (e + 2 < order.len) firstCp(itemText(text, gl, order[e + 2])) else 0;
                    if (strong or (inner and (isLtrCp(c3) or isDigitCp(c3)))) {
                        e += 1;
                    } else if (c2 == ' ' and e + 2 < order.len and (isLtrCp(firstCp(itemText(text, gl, order[e + 2]))))) {
                        e += 1;
                    } else break;
                }
                std.mem.reverse(u32, order[k .. e + 1]);
                for (k..e + 1) |q| in_ltr[q] = true;
                k = e + 1;
            } else k += 1;
        }
    }
    const mono = nm * 2 > ids.len;
    var space_gap: f32 = 0.2 * size;
    {
        var has_space = false;
        var gaps: std.ArrayList(f32) = .empty;
        for (ids, 0..) |k, j| {
            const t0 = glyphText(text, gl[k]);
            if (isBlankGlyph(t0)) has_space = true;
            if (j == 0) continue;
            const pv = gl[ids[j - 1]];
            if (isBlankGlyph(glyphText(text, pv)) or isBlankGlyph(t0)) continue;
            try gaps.append(a, gl[k].x - (pv.x + pv.w));
        }
        if (has_space and gaps.items.len >= 3) {
            std.mem.sort(f32, gaps.items, {}, std.sort.asc(f32));
            const lg = gaps.items[gaps.items.len / 2];
            if (lg > 0.05 * size) space_gap = @max(space_gap, 2.0 * lg + 0.1 * size);
        }
    }
    var buf: std.ArrayList(u8) = .empty;
    var prev: ?Glyph = null;
    var lead_bold: usize = 0;
    var all_bold = true;
    for (order) |k| {
        if (k != space_item and rtl <= ltr) {
            const gk = gl[k];
            if (!isBlankGlyph(glyphText(text, gk))) {
                if (all_bold and !gk.bold and buf.items.len >= 3) lead_bold = trimSpace(buf.items).len + (buf.items.len - std.mem.trimLeft(u8, buf.items, " ").len);
                if (!gk.bold) all_bold = false;
            }
        }
        if (k == space_item) {
            if (buf.items.len > 0 and buf.items[buf.items.len - 1] != ' ') try buf.append(a, ' ');
            continue;
        }
        const g = gl[k];
        const t = glyphText(text, g);
        if (rtl > ltr) {
            const qi_raw = std.mem.indexOfScalar(u32, order, k) orelse 0;
            // (a glyph whose text is an ActualText already reads logically: mirroring it would undo that)
            const qi = if (g.actual) in_ltr.len else qi_raw;
            const mirrored: ?[]const u8 = if (qi < in_ltr.len and !in_ltr[qi] and eq(t, "\u{00AB}")) "\u{00BB}" else if (qi < in_ltr.len and !in_ltr[qi] and eq(t, "\u{00BB}")) "\u{00AB}" else if (qi < in_ltr.len and !in_ltr[qi] and eq(t, "\u{2039}")) "\u{203A}" else if (qi < in_ltr.len and !in_ltr[qi] and eq(t, "\u{203A}")) "\u{2039}" else if (qi < in_ltr.len and !in_ltr[qi] and t.len == 1) switch (t[0]) {
                '(' => ")",
                ')' => "(",
                '[' => "]",
                ']' => "[",
                '{' => "}",
                '}' => "{",
                '<' => ">",
                '>' => "<",
                else => null,
            } else null;
            if (mirrored) |m| {
                try buf.appendSlice(a, m);
            } else if (!(isBlankGlyph(t) and buf.items.len > 0 and buf.items[buf.items.len - 1] == ' ')) try buf.appendSlice(a, t);
            prev = g;
            continue;
        }
        if (prev) |pv| {
            const gap = if (rtl > ltr) pv.x - (g.x + g.w) else g.x - (pv.x + pv.w);
            const last_space = buf.items.len > 0 and buf.items[buf.items.len - 1] == ' ';
            if (mono) {
                // code: every missing column is a space
                const cw = 0.6 * g.size;
                if (gap > 0.5 * cw) try buf.appendNTimes(a, ' ', @intFromFloat(@min(40, @round(gap / cw))));
            } else if (gap > space_gap and !last_space and !(t.len > 0 and t[0] == ' ')) try buf.append(a, ' ');
        }
        if (mono or !(t.len == 1 and t[0] == ' ' and buf.items.len > 0 and buf.items[buf.items.len - 1] == ' ')) try buf.appendSlice(a, t);
        prev = g;
    }
    var trimmed: []const u8 = trimSpace(buf.items);
    if (rtl > 0) trimmed = try arabicLogical(a, trimmed);
    return .{
        .page = page_no,
        .x0 = x0,
        .x1 = x1,
        .base = base,
        .y0 = base - 0.8 * maxsize,
        .y1 = base + 0.25 * maxsize,
        .size = size,
        .bold = nb * 2 > ids.len,
        .mono = mono,
        .italic = ni * 2 > ids.len,
        .lead_bold = if (lead_bold > 0 and lead_bold < trimmed.len and nb * 2 <= ids.len) @min(lead_bold, trimmed.len) else 0,
        .text = trimmed,
    };
}

// A table: a region boxed by ruling lines that holds several fragments on several rows. Cells come from the rulings.
const TableOut = struct { x0: f32, y0: f32, x1: f32, y1: f32, rows: [][][]const u8, size: f32, cols: [][2]f32 = &.{} };

fn clusterVals(a: Allocator, vals: []f32, tol: f32) ![]f32 {
    std.mem.sort(f32, vals, {}, std.sort.asc(f32));
    var out: std.ArrayList(f32) = .empty;
    for (vals) |v| {
        if (out.items.len == 0 or v - out.items[out.items.len - 1] > tol) try out.append(a, v);
    }
    return out.items;
}

fn findTables(a: Allocator, frags: []Frag, rules: []Rule, tables: *std.ArrayList(TableOut)) !void {
    if (rules.len < 4) return;
    // connected groups of rulings (touching within 3 pt)
    const n = rules.len;
    const grp = try a.alloc(u32, n);
    for (grp, 0..) |*g, k| g.* = @intCast(k);
    const Find = struct {
        fn f(gp: []u32, x: u32) u32 {
            var r = x;
            while (gp[r] != r) r = gp[r];
            return r;
        }
    };
    for (0..n) |i| {
        for (i + 1..n) |j| {
            const r1 = rules[i];
            const r2 = rules[j];
            if (r1.x0 - 3 <= r2.x1 and r2.x0 - 3 <= r1.x1 and r1.y0 - 3 <= r2.y1 and r2.y0 - 3 <= r1.y1) {
                const ri = Find.f(grp, @intCast(i));
                const rj = Find.f(grp, @intCast(j));
                if (ri != rj) grp[ri] = rj;
            }
        }
    }
    var done = try a.alloc(bool, n);
    @memset(done, false);
    for (0..n) |i| {
        const root = Find.f(grp, @intCast(i));
        if (done[root]) continue;
        done[root] = true;
        var xs: std.ArrayList(f32) = .empty;
        var ys: std.ArrayList(f32) = .empty;
        var bx0: f32 = 1e9;
        var by0: f32 = 1e9;
        var bx1: f32 = -1e9;
        var by1: f32 = -1e9;
        for (0..n) |j| {
            if (Find.f(grp, @intCast(j)) != root) continue;
            const r = rules[j];
            bx0 = @min(bx0, r.x0);
            by0 = @min(by0, r.y0);
            bx1 = @max(bx1, r.x1);
            by1 = @max(by1, r.y1);
            if (r.x1 - r.x0 <= 2.5) try xs.append(a, (r.x0 + r.x1) / 2) else try ys.append(a, (r.y0 + r.y1) / 2);
        }
        const cx = try clusterVals(a, xs.items, 3);
        const cy = try clusterVals(a, ys.items, 3);
        if (cx.len < 3 or cy.len < 3) continue; // at least 2 x 2 cells
        // the fragments inside
        var inside: usize = 0;
        for (frags) |f| {
            const mx = (f.x0 + f.x1) / 2;
            const my = (f.y0 + f.y1) / 2;
            if (mx > bx0 and mx < bx1 and my > by0 and my < by1) inside += 1;
        }
        if (inside < 3) continue;
        const nr = cy.len - 1;
        const nc = cx.len - 1;
        var rows = try a.alloc([][]const u8, nr);
        var cells = try a.alloc(std.ArrayList(u8), nr * nc);
        for (cells) |*c| c.* = .empty;
        var size: f32 = 0;
        for (frags) |*f| {
            const mx = (f.x0 + f.x1) / 2;
            const my = (f.y0 + f.y1) / 2;
            if (!(mx > bx0 and mx < bx1 and my > by0 and my < by1)) continue;
            var ri: usize = 0;
            while (ri + 1 < cy.len and my > cy[ri + 1]) ri += 1;
            var ci: usize = 0;
            while (ci + 1 < cx.len and mx > cx[ci + 1]) ci += 1;
            if (ri >= nr or ci >= nc) continue;
            const c = &cells[ri * nc + ci];
            if (c.items.len > 0) try c.append(a, ' ');
            try c.appendSlice(a, f.text);
            f.table = @intCast(tables.items.len);
            size = @max(size, f.size);
        }
        // which internal boundaries carry a ruling
        const hasH = struct {
            fn f(rs: []Rule, rt: u32, gp: []u32, y: f32, x: f32) bool {
                for (rs, 0..) |r, j| {
                    if (Find.f(gp, @intCast(j)) != rt) continue;
                    if (r.y1 - r.y0 > 2.5) continue;
                    if (@abs((r.y0 + r.y1) / 2 - y) <= 3 and r.x0 - 1 <= x and r.x1 + 1 >= x) return true;
                }
                return false;
            }
        }.f;
        const hasV = struct {
            fn f(rs: []Rule, rt: u32, gp: []u32, x: f32, y: f32) bool {
                for (rs, 0..) |r, j| {
                    if (Find.f(gp, @intCast(j)) != rt) continue;
                    if (r.x1 - r.x0 > 2.5) continue;
                    if (@abs((r.x0 + r.x1) / 2 - x) <= 3 and r.y0 - 1 <= y and r.y1 + 1 >= y) return true;
                }
                return false;
            }
        }.f;
        const cg = try a.alloc(u32, nr * nc);
        for (cg, 0..) |*g, k| g.* = @intCast(k);
        for (0..nr) |ri| for (0..nc) |ci| {
            const mx = (cx[ci] + cx[ci + 1]) / 2;
            const my = (cy[ri] + cy[ri + 1]) / 2;
            if (ri + 1 < nr and !hasH(rules, root, grp, cy[ri + 1], mx)) {
                const r1 = Find.f(cg, @intCast(ri * nc + ci));
                const r2 = Find.f(cg, @intCast((ri + 1) * nc + ci));
                if (r1 != r2) cg[r1] = r2;
            }
            if (ci + 1 < nc and !hasV(rules, root, grp, cx[ci + 1], my)) {
                const r1 = Find.f(cg, @intCast(ri * nc + ci));
                const r2 = Find.f(cg, @intCast(ri * nc + ci + 1));
                if (r1 != r2) cg[r1] = r2;
            }
        };
        // a merged cell's text is the text of whichever of its pieces holds some
        const gtext = try a.alloc([]const u8, nr * nc);
        for (gtext) |*g| g.* = "";
        for (0..nr * nc) |k| {
            const r = Find.f(cg, @intCast(k));
            if (gtext[r].len == 0 and cells[k].items.len > 0) gtext[r] = cells[k].items;
        }
        for (0..nr) |ri| {
            rows[ri] = try a.alloc([]const u8, nc);
            for (0..nc) |ci| {
                const k = ri * nc + ci;
                rows[ri][ci] = if (cells[k].items.len > 0) cells[k].items else gtext[Find.f(cg, @intCast(k))];
            }
        }
        var bands = try a.alloc([2]f32, nc);
        for (0..nc) |ci| bands[ci] = .{ cx[ci], cx[ci + 1] };
        // the table ends at its last horizontal rule: column rules running on below it frame rows the grid
        // does not hold (a timetable ruled only in its header), which another table may take
        const tbot = @min(by1, cy[cy.len - 1] + 1);
        try tables.append(a, .{ .x0 = bx0, .y0 = by0, .x1 = bx1, .y1 = tbot, .rows = rows, .size = size, .cols = bands });
    }
}

// A table drawn WITHOUT lines: at least three consecutive rows, each holding two or more fragments, whose
// fragments fall into the same columns (the empty vertical bands they leave), and whose cells are short --
// mostly three words or fewer, which is what tells a table from two or three columns of prose.
fn wordCount(t: []const u8) usize {
    var n: usize = 0;
    var in_word = false;
    for (t) |c| {
        if (c == ' ') {
            in_word = false;
        } else if (!in_word) {
            in_word = true;
            n += 1;
        }
    }
    return n;
}

fn findAlignedTables(a: Allocator, frags: []Frag, tables: *std.ArrayList(TableOut)) !void {
    try findAlignedTablesIn(a, frags, -1e9, 1e9, tables);
}

fn findAlignedTablesIn(a: Allocator, frags: []Frag, lane0: f32, lane1: f32, tables: *std.ArrayList(TableOut)) !void {
    // rows: fragments outside any table, grouped by baseline
    var idx: std.ArrayList(u32) = .empty;
    for (frags, 0..) |f, k| {
        const cxm = (f.x0 + f.x1) / 2;
        if (f.table < 0 and f.text.len > 0 and cxm >= lane0 and cxm < lane1 and !isProseLine(frags, f)) try idx.append(a, @intCast(k));
    }
    if (idx.items.len < 6) return;
    const ByBase = struct {
        f: []Frag,
        fn lt(ctx: @This(), l: u32, r: u32) bool {
            if (@abs(ctx.f[l].base - ctx.f[r].base) > 0.5) return ctx.f[l].base < ctx.f[r].base;
            return ctx.f[l].x0 < ctx.f[r].x0;
        }
    };
    std.mem.sort(u32, idx.items, ByBase{ .f = frags }, ByBase.lt);
    var rows: std.ArrayList([]u32) = .empty;
    {
        var st: usize = 0;
        var k: usize = 1;
        while (k <= idx.items.len) : (k += 1) {
            if (k == idx.items.len or @abs(frags[idx.items[k]].base - frags[idx.items[st]].base) > 0.3 * frags[idx.items[st]].size) {
                try rows.append(a, idx.items[st..k]);
                st = k;
            }
        }
    }
    var r: usize = 0;
    while (r < rows.items.len) {
        if (rows.items[r].len < 2) {
            r += 1;
            continue;
        }
        // grow a run of multi-cell rows close below one another
        var e = r + 1;
        while (e < rows.items.len) : (e += 1) {
            const pf = frags[rows.items[e - 1][0]];
            const cf = frags[rows.items[e][0]];
            if (cf.base - pf.base > 3.2 * pf.size) break;
            if (@abs(cf.size - pf.size) > 0.05 * pf.size) break;
            if (rows.items[e].len >= 2) continue;
            break; // (a wrapped one-cell line was tried as part of the run: it pulled prose into tables -- off)
        }
        const run = rows.items[r..e];
        if (run.len < 3) {
            r = e;
            continue;
        }
        // the cells must be short
        var nf: usize = 0;
        var short: usize = 0;
        for (run) |row| {
            if (row.len < 2) continue;
            for (row) |k| {
                nf += 1;
                if (wordCount(frags[k].text) <= 3) short += 1; // (five words was tried: it let short prose in)
            }
        }
        // a key/value table: every row exactly a short label (four words or fewer) and its value (fifteen or
        // fewer), the labels in one column -- the values may be phrases
        // (likewise a table of short cells whose LAST column holds descriptions: every row as wide, the other cells
        //  four words or fewer)
        var keyval = run.len >= 3;
        {
            var lx: f32 = -1e9;
            const w0 = run[0].len;
            for (run) |row| {
                if (row.len != w0 or w0 < 2 or w0 > 4) {
                    keyval = false;
                    break;
                }
                const l = frags[row[0]];
                const v = frags[row[w0 - 1]];
                // (a list set in two columns is not one: its items carry bullets)
                if (wordCount(v.text) > 15 or l.bullet or v.bullet) keyval = false;
                for (row[0 .. w0 - 1], 0..) |kc, ci| {
                    if (wordCount(frags[kc].text) > 4) keyval = false;
                    if (frags[row[ci + 1]].x0 <= frags[kc].x1) keyval = false;
                }
                if (lx > -1e8 and @abs(l.x0 - lx) > 1.0 * l.size) keyval = false;
                lx = l.x0;
            }
        }
        if (short * 10 < nf * 7 and !keyval) {
            r = e;
            continue;
        }
        // columns: the x bands covered by the run's fragments -- except a cell that SPANS columns (a "Subtotal"
        // label over two of them): one that two cells of ONE other row both overlap
        var spans: std.ArrayList([2]f32) = .empty;
        for (run, 0..) |row, ri| for (row) |k| {
            const f = frags[k];
            var spanning = false;
            for (run, 0..) |row2, rj| {
                if (rj == ri) continue;
                var under: usize = 0;
                for (row2) |k2| {
                    const g = frags[k2];
                    if (g.x1 > f.x0 + 1 and g.x0 < f.x1 - 1) under += 1;
                }
                if (under >= 2) {
                    spanning = true;
                    break;
                }
            }
            if (spanning) continue;
            try spans.append(a, .{ f.x0, f.x1 });
        };
        const BySpan = struct {
            fn lt(_: void, l: [2]f32, rr: [2]f32) bool {
                return l[0] < rr[0];
            }
        };
        std.mem.sort([2]f32, spans.items, {}, BySpan.lt);
        var cols: std.ArrayList([2]f32) = .empty;
        for (spans.items) |sp| {
            if (cols.items.len > 0 and sp[0] < cols.items[cols.items.len - 1][1]) {
                cols.items[cols.items.len - 1][1] = @max(cols.items[cols.items.len - 1][1], sp[1]);
            } else try cols.append(a, sp);
        }
        // a band that only ONE row of a longer run fills is not a column: a header cell centred over
        // right-aligned figures overlaps none of them; its cells go to the nearest band
        if (run.len >= 4 and cols.items.len > 2) {
            var kept_cols: std.ArrayList([2]f32) = .empty;
            const fsz = frags[run[0][0]].size;
            // which bands hold data (a row below the header)
            var has_data = try a.alloc(bool, cols.items.len);
            for (cols.items, 0..) |c, ci| {
                has_data[ci] = false;
                for (run[1..]) |row| for (row) |k| {
                    const mx = (frags[k].x0 + frags[k].x1) / 2;
                    if (mx >= c[0] and mx <= c[1]) has_data[ci] = true;
                };
            }
            for (cols.items, 0..) |c, ci| {
                // a header-only band right beside a band of figures is that column's header, set off-centre;
                // over an empty column (no figures on this page) it is a column of its own
                var beside = false;
                for (cols.items, 0..) |c2, cj| {
                    if (cj == ci or !has_data[cj]) continue;
                    const gap = @max(c2[0] - c[1], c[0] - c2[1]);
                    if (gap < 1.5 * fsz) beside = true;
                }
                if (!beside) {
                    try kept_cols.append(a, c);
                    continue;
                }
                var nrows: usize = 0;
                var data_rows: usize = 0;
                for (run, 0..) |row, ri| {
                    for (row) |k| {
                        const mx = (frags[k].x0 + frags[k].x1) / 2;
                        if (mx >= c[0] and mx <= c[1]) {
                            nrows += 1;
                            if (ri > 0) data_rows += 1;
                            break;
                        }
                    }
                }
                // (only the HEADER row's lonely bands: a sparse column of figures filled once is a real column)
                if (nrows >= 2 or data_rows > 0) try kept_cols.append(a, c);
            }
            if (kept_cols.items.len >= 2) cols = kept_cols;
        }
        if (cols.items.len < 2) {
            r = e;
            continue;
        }
        // every row must use at least two of the columns
        var ok = true;
        for (run) |row| {
            if (row.len < 2) continue;
            // (cells placed as they will be: a spanning cell's centre may fall between two bands)
            const c0 = colOf(cols.items, (frags[row[0]].x0 + frags[row[0]].x1) / 2);
            var two = false;
            for (row[1..]) |k| {
                if (colOf(cols.items, (frags[k].x0 + frags[k].x1) / 2) != c0) two = true;
            }
            if (!two) ok = false;
        }
        if (!ok) {
            r = e;
            continue;
        }
        const nc = cols.items.len;
        var grid = try a.alloc([][]const u8, run.len);
        var bx0: f32 = 1e9;
        var by0: f32 = 1e9;
        var bx1: f32 = -1e9;
        var by1: f32 = -1e9;
        var size: f32 = 0;
        for (run, 0..) |row, ri| {
            var cells = try a.alloc(std.ArrayList(u8), nc);
            for (cells) |*c| c.* = .empty;
            for (row) |k| {
                const f = &frags[k];
                const mx = (f.x0 + f.x1) / 2;
                var ci: usize = colOf(cols.items, mx);
                _ = &ci;
                if (cells[ci].items.len > 0) try cells[ci].append(a, ' ');
                try cells[ci].appendSlice(a, f.text);
                f.table = @intCast(tables.items.len);
                bx0 = @min(bx0, f.x0);
                by0 = @min(by0, f.y0);
                bx1 = @max(bx1, f.x1);
                by1 = @max(by1, f.y1);
                size = @max(size, f.size);
            }
            grid[ri] = try a.alloc([]const u8, nc);
            for (0..nc) |j| grid[ri][j] = cells[j].items;
        }
        // a wrapped line joins the cell above it, in its column
        var kept: std.ArrayList([][]const u8) = .empty;
        for (run, 0..) |row, ri| {
            if (row.len >= 2 or kept.items.len == 0) {
                try kept.append(a, grid[ri]);
                continue;
            }
            const last = kept.items[kept.items.len - 1];
            for (0..nc) |j| {
                if (grid[ri][j].len == 0) continue;
                last[j] = if (last[j].len == 0) grid[ri][j] else try std.mem.concat(a, u8, &.{ last[j], " ", grid[ri][j] });
            }
        }
        try tables.append(a, .{ .x0 = bx0, .y0 = by0, .x1 = bx1, .y1 = by1, .rows = kept.items, .size = size, .cols = try a.dupe([2]f32, cols.items) });
        r = e;
    }
}

// A line of running prose: ten words or more over at least 35 per cent of the text width. It is never a cell
// of a borderless table, even when it shares a baseline with one in the next column.
fn isProseLine(frags: []Frag, f: Frag) bool {
    if (isLongProse(frags, f)) return true;
    // the last line of a paragraph: right under a long prose line that starts where it starts
    for (frags) |o| {
        if (o.text.len == 0) continue;
        if (@abs(o.x0 - f.x0) < 2 and o.y1 <= f.y0 + 1 and f.y0 - o.y1 < 0.8 * f.size and isLongProse(frags, o)) return true;
    }
    return false;
}

fn isLongProse(frags: []Frag, f: Frag) bool {
    if (wordCount(f.text) < 10) return false;
    var minx: f32 = 1e9;
    var maxx: f32 = -1e9;
    for (frags) |o| {
        if (o.text.len == 0) continue;
        minx = @min(minx, o.x0);
        maxx = @max(maxx, o.x1);
    }
    return f.x1 - f.x0 >= 0.35 * (maxx - minx);
}

fn colOf(cols: [][2]f32, x: f32) usize {
    var best: usize = 0;
    var bd: f32 = 1e9;
    for (cols, 0..) |c, j| {
        if (x >= c[0] and x <= c[1]) return j;
        const dd = @min(@abs(x - c[0]), @abs(x - c[1]));
        if (dd < bd) {
            bd = dd;
            best = j;
        }
    }
    return best;
}

// The free fragments of one row (one baseline) inside a table's x range, nearest to y going up (dir -1) or down.
fn rowNear(a: Allocator, frags: []Frag, t: TableOut, dir: i32) ![]u32 {
    var bestb: f32 = if (dir < 0) -1e9 else 1e9;
    for (frags) |f| {
        if (f.table >= 0 or f.text.len == 0) continue;
        const cm = (f.x0 + f.x1) / 2;
        if (cm < t.x0 - 5 or cm > t.x1 + 5) continue;
        if (dir < 0 and f.y1 <= t.y0 + 1 and f.base > bestb) bestb = f.base;
        if (dir > 0 and f.y0 >= t.y1 - 1 and f.base < bestb) bestb = f.base;
    }
    var out: std.ArrayList(u32) = .empty;
    if (@abs(bestb) > 1e8) return out.items;
    for (frags, 0..) |f, k| {
        if (f.table >= 0 or f.text.len == 0) continue;
        const cm = (f.x0 + f.x1) / 2;
        if (cm < t.x0 - 5 or cm > t.x1 + 5) continue;
        if (@abs(f.base - bestb) < 0.3 * f.size) try out.append(a, @intCast(k));
    }
    const ByX = struct {
        f: []Frag,
        fn lt(ctx: @This(), l: u32, r: u32) bool {
            return ctx.f[l].x0 < ctx.f[r].x0;
        }
    };
    std.mem.sort(u32, out.items, ByX{ .f = frags }, ByX.lt);
    return out.items;
}

// The free fragments just above `edge` inside a table's x range: the nearest line, and the lines stacked right
// above it (a header cell wrapped onto several lines), up to three lines.
fn bandAbove(a: Allocator, frags: []Frag, t: TableOut, edge: f32) ![]u32 {
    // the nearest free fragment above the edge, then every free fragment whose height overlaps the band so far
    // (cells of one header row are centred differently when one of them wraps), up to three and a half lines tall
    var nearest: ?u32 = null;
    var nb: f32 = -1e9;
    for (frags, 0..) |f, k| {
        if (f.table >= 0 or f.text.len == 0) continue;
        const cm = (f.x0 + f.x1) / 2;
        if (cm < t.x0 - 5 or cm > t.x1 + 5) continue;
        if (f.y1 <= edge + 1 and f.y1 > nb) {
            nb = f.y1;
            nearest = @intCast(k);
        }
    }
    var out: std.ArrayList(u32) = .empty;
    const n0 = nearest orelse return out.items;
    var top = frags[n0].y0;
    const bottom = frags[n0].y1;
    var in_band = try a.alloc(bool, frags.len);
    @memset(in_band, false);
    in_band[n0] = true;
    var grew = true;
    while (grew) {
        grew = false;
        for (frags, 0..) |f, k| {
            if (in_band[k] or f.table >= 0 or f.text.len == 0) continue;
            const cm = (f.x0 + f.x1) / 2;
            if (cm < t.x0 - 5 or cm > t.x1 + 5) continue;
            if (f.y1 > edge + 1) continue;
            if (f.y1 >= top - 0.3 * f.size and bottom - @min(top, f.y0) <= 3.5 * f.size) {
                in_band[k] = true;
                top = @min(top, f.y0);
                grew = true;
            }
        }
    }
    for (in_band, 0..) |v, k| if (v) try out.append(a, @intCast(k));
    return out.items;
}

// A table grows by its header row (free fragments right above it, one per column) and by its totals rows (right
// below it, the amount in the last column; the label fills the cells it spans, as a merged cell does).
fn growTables(a: Allocator, frags: []Frag, tables: *std.ArrayList(TableOut)) !void {
    for (tables.items, 0..) |*t, ti| {
        const n = t.cols.len;
        if (n < 2 or t.rows.len == 0) continue;
        // header rows above, possibly several (a two-level header), possibly past one section row; a header cell
        // may wrap onto two or three lines, so the header is gathered as a BAND of lines, joined per column
        var hguard: usize = 0;
        var edge: f32 = t.y0;
        var pending_section: ?u32 = null;
        var headers: usize = 0;
        var header_bold = false;
        while (hguard < 6) : (hguard += 1) {
            var band = try bandAbove(a, frags, t.*, edge);
            if (band.len == 0) break;
            const b0 = frags[band[0]];
            var bottom: f32 = -1e9;
            for (band) |k| bottom = @max(bottom, frags[k].y1);
            if (edge - bottom > 1.8 * t.size) break;
            var same_size = true;
            for (band) |k| if (frags[k].size > 1.05 * t.size) {
                same_size = false;
            };
            if (!same_size) break;
            // header cells are short: no sentence, nothing wider than most of the table
            var short_cells = true;
            for (band) |k| if (wordCount(frags[k].text) > 6 or frags[k].x1 - frags[k].x0 > 0.6 * (t.x1 - t.x0)) {
                short_cells = false;
            };
            if (!short_cells) break;
            if (headers > 0 and edge - bottom > 1.5 * t.size) break; // a further header row sits close above the first
            if (band.len == 1) {
                // one cell starting at the first column: a section row, kept only if a header sits above it
                if (pending_section != null or @abs(b0.x0 - t.cols[0][0]) > 1.5 * t.size) break;
                pending_section = band[0];
                edge = b0.y0;
                continue;
            }
            // a band whose every line holds several cells is a header of several ROWS (a two-level header):
            // only its lowest line is taken now, the loop takes the others; a band with one-cell lines is a
            // single row whose cells wrap, joined below
            {
                var lines_n: usize = 0;
                var multi = true;
                var low_base: f32 = -1e9;
                var seen = try a.alloc(bool, band.len);
                @memset(seen, false);
                for (band, 0..) |k, q| {
                    if (seen[q]) continue;
                    var cnt: usize = 0;
                    for (band, 0..) |k2, q2| {
                        if (@abs(frags[k2].base - frags[k].base) < 0.3 * frags[k].size) {
                            seen[q2] = true;
                            cnt += 1;
                        }
                    }
                    lines_n += 1;
                    if (cnt < 2) multi = false;
                    low_base = @max(low_base, frags[k].base);
                }
                if (lines_n > 1 and multi) {
                    var low: std.ArrayList(u32) = .empty;
                    for (band) |k| if (@abs(frags[k].base - low_base) < 0.3 * frags[k].size) try low.append(a, k);
                    band = low.items;
                }
            }
            var cells = try a.alloc(std.ArrayList(u8), n);
            for (cells) |*c| c.* = .empty;
            var col_x0 = try a.alloc(f32, n);
            for (col_x0) |*x| x.* = 1e9;
            var conflict = false;
            // top to bottom, so a wrapped cell reads in order
            const ByY = struct {
                f: []Frag,
                fn lt(ctx: @This(), l: u32, r: u32) bool {
                    if (@abs(ctx.f[l].base - ctx.f[r].base) > 0.5) return ctx.f[l].base < ctx.f[r].base;
                    return ctx.f[l].x0 < ctx.f[r].x0;
                }
            };
            const sorted = try a.dupe(u32, band);
            std.mem.sort(u32, sorted, ByY{ .f = frags }, ByY.lt);
            for (sorted) |k| {
                var placed = false;
                for (t.cols, 0..) |c, jj| {
                    const m = (c[0] + c[1]) / 2;
                    if (m >= frags[k].x0 - 2 and m <= frags[k].x1 + 2) {
                        if (cells[jj].items.len > 0) {
                            // a second line in the same column must start where the first did (a wrapped cell)
                            if (@abs(frags[k].x0 - col_x0[jj]) > 1.5 * t.size and @abs(frags[k].x1 - (col_x0[jj])) > 1e8) conflict = true;
                            try cells[jj].append(a, ' ');
                        }
                        try cells[jj].appendSlice(a, frags[k].text);
                        col_x0[jj] = @min(col_x0[jj], frags[k].x0);
                        placed = true;
                    }
                }
                if (!placed) {
                    const jj = colOf(t.cols, (frags[k].x0 + frags[k].x1) / 2);
                    if (cells[jj].items.len > 0) try cells[jj].append(a, ' ');
                    try cells[jj].appendSlice(a, frags[k].text);
                }
            }
            var used: usize = 0;
            for (cells) |c| {
                if (c.items.len > 0) used += 1;
            }
            if (conflict or used < 2) break;
            const extra: usize = if (pending_section != null) 2 else 1;
            var rows = try a.alloc([][]const u8, t.rows.len + extra);
            var hrow = try a.alloc([]const u8, n);
            for (0..n) |jj| hrow[jj] = cells[jj].items;
            rows[0] = hrow;
            if (pending_section) |sk| {
                const sc = try a.alloc([]const u8, n);
                for (sc) |*c| c.* = frags[sk].text;
                rows[1] = sc;
                frags[sk].table = @intCast(ti);
            }
            @memcpy(rows[extra..], t.rows);
            t.rows = rows;
            for (band) |k| {
                frags[k].table = @intCast(ti);
                t.y0 = @min(t.y0, frags[k].y0);
            }
            pending_section = null;
            edge = t.y0;
            if (headers == 0) {
                var nbold: usize = 0;
                for (band) |k| {
                    if (frags[k].bold) nbold += 1;
                }
                header_bold = nbold * 2 >= band.len;
            }
            headers += 1;
        }
        // totals rows below
        var guard: usize = 0;
        while (guard < 40) : (guard += 1) {
            const row = try rowNear(a, frags, t.*, 1);
            if (row.len < 2 or frags[row[0]].y0 - t.y1 > 1.8 * frags[row[0]].size) break;
            const last = frags[row[row.len - 1]];
            if (colOf(t.cols, (last.x0 + last.x1) / 2) != n - 1) break;
            var cells = try a.alloc([]const u8, n);
            for (cells) |*c| c.* = "";
            if (row.len == 2) {
                for (0..n - 1) |j| cells[j] = frags[row[0]].text;
                cells[n - 1] = last.text;
            } else {
                var distinct = true;
                for (row) |k| {
                    const j = colOf(t.cols, (frags[k].x0 + frags[k].x1) / 2);
                    if (cells[j].len > 0) distinct = false;
                    cells[j] = frags[k].text;
                }
                if (!distinct) break;
            }
            var rows = try a.alloc([][]const u8, t.rows.len + 1);
            @memcpy(rows[0..t.rows.len], t.rows);
            rows[t.rows.len] = cells;
            t.rows = rows;
            for (row) |k| {
                frags[k].table = @intCast(ti);
                t.y1 = @max(t.y1, frags[k].y1);
                t.x0 = @min(t.x0, frags[k].x0);
            }
        }
    }
}

// Two tables one right above the other, sharing their x range, are one table: a section row between them (one
// cell across the table) becomes a row of its own, its text in every cell; the lower table's cells go to the
// upper table's columns; a repeated header row is dropped. A merged-away table keeps no rows.
fn stackTables(a: Allocator, frags: []Frag, tables: *std.ArrayList(TableOut)) !void {
    var changed = true;
    var rounds: usize = 0;
    while (changed and rounds < 20) : (rounds += 1) {
        changed = false;
        for (tables.items, 0..) |*t1, i| {
            if (t1.rows.len == 0 or t1.cols.len < 2) continue;
            for (tables.items, 0..) |*t2, j| {
                if (i == j or t2.rows.len == 0) continue;
                if (t2.y0 < t1.y1 - 1) continue;
                const ov = @min(t1.x1, t2.x1) - @max(t1.x0, t2.x0);
                if (ov < 0.6 * @min(t1.x1 - t1.x0, t2.x1 - t2.x0)) continue;
                // the section rows between them, and nothing else
                var between: std.ArrayList(u32) = .empty;
                var foreign = false;
                for (frags, 0..) |f, k| {
                    if (f.text.len == 0 or f.table >= 0) continue;
                    if (f.y0 >= t1.y1 - 1 and f.y1 <= t2.y0 + 1 and (f.x0 + f.x1) / 2 > t1.x0 - 5 and (f.x0 + f.x1) / 2 < t1.x1 + 5) {
                        if (wordCount(f.text) > 8) foreign = true;
                        try between.append(a, @intCast(k));
                    }
                }
                const gap = t2.y0 - t1.y1;
                if (foreign or gap > 3.5 * t1.size + @as(f32, @floatFromInt(between.items.len)) * 2.0 * t1.size) continue;
                // the lower table's columns must fall on the upper table's: as many and in place, or a totals
                // block (two columns, its amounts in the upper table's last column)
                if (t2.cols.len > t1.cols.len or t2.cols.len == 0) continue;
                var totals = false;
                if (t2.cols.len == t1.cols.len) {
                    var used = try a.alloc(bool, t1.cols.len);
                    @memset(used, false);
                    var inj = true;
                    for (t2.cols) |c2| {
                        const jj = colOf(t1.cols, (c2[0] + c2[1]) / 2);
                        if (used[jj]) inj = false;
                        used[jj] = true;
                    }
                    if (!inj) continue;
                } else if (t2.cols.len == 2 and colOf(t1.cols, (t2.cols[1][0] + t2.cols[1][1]) / 2) == t1.cols.len - 1) {
                    totals = true;
                } else continue;
                // no other table sits between them
                var other = false;
                for (tables.items, 0..) |t3, q| {
                    if (q == i or q == j or t3.rows.len == 0) continue;
                    if (t3.y0 >= t1.y1 - 1 and t3.y1 <= t2.y0 + 1) other = true;
                }
                if (other) continue;
                const n = t1.cols.len;
                var rows: std.ArrayList([][]const u8) = .empty;
                try rows.appendSlice(a, t1.rows);
                for (between.items) |k| {
                    const cells = try a.alloc([]const u8, n);
                    for (cells) |*c| c.* = frags[k].text;
                    try rows.append(a, cells);
                    frags[k].table = @intCast(i);
                }
                for (t2.rows, 0..) |r2, ri| {
                    var cells = try a.alloc([]const u8, n);
                    for (cells) |*c| c.* = "";
                    if (t2.cols.len == n) {
                        for (r2, 0..) |c, ci| cells[ci] = c;
                    } else if (totals and r2.len == 2) {
                        for (0..n - 1) |q| cells[q] = r2[0];
                        cells[n - 1] = r2[1];
                    } else if (t2.cols.len > 0) {
                        for (r2, 0..) |c, ci| {
                            if (ci >= t2.cols.len) break;
                            const jj = colOf(t1.cols, (t2.cols[ci][0] + t2.cols[ci][1]) / 2);
                            if (cells[jj].len == 0) cells[jj] = c;
                        }
                    }
                    // the upper table's header repeated at the top of the lower one is dropped
                    if (ri == 0 and t1.rows.len > 0) {
                        var same = true;
                        for (cells, t1.rows[0]) |c1, c2| if (!eq(c1, c2)) {
                            same = false;
                        };
                        if (same) continue;
                    }
                    try rows.append(a, cells);
                }
                t1.rows = rows.items;
                t1.y1 = t2.y1;
                t1.x0 = @min(t1.x0, t2.x0);
                t1.x1 = @max(t1.x1, t2.x1);
                for (frags) |*f| if (f.table == @as(i32, @intCast(j))) {
                    f.table = @intCast(i);
                };
                t2.rows = &.{};
                changed = true;
                break;
            }
            if (changed) break;
        }
    }
}

// Reading order: a recursive XY cut. A vertical gutter splits columns (left first); without one, units wider
// than most of the region (a title over two columns) become their own strips so they do not interleave the
// columns; otherwise the region is read strip by strip from the top.
fn xycut(a: Allocator, units: []Frag, ids: []u32, out: *std.ArrayList(u32), aside: *std.ArrayList(u32), depth: u32) anyerror!void {
    if (ids.len <= 1 or depth > 60) {
        try out.appendSlice(a, ids);
        return;
    }
    var rx0: f32 = 1e9;
    var rx1: f32 = -1e9;
    var med: f32 = 0;
    for (ids) |k| {
        rx0 = @min(rx0, units[k].x0);
        rx1 = @max(rx1, units[k].x1);
        med += units[k].size;
    }
    med /= @as(f32, @floatFromInt(ids.len));
    // vertical gutter
    if (try gutterSplit(a, units, ids, med, out, aside, depth)) return;
    // spanning units
    const rw = rx1 - rx0;
    var wide: usize = 0;
    for (ids) |k| {
        if (units[k].x1 - units[k].x0 > 0.6 * rw) wide += 1;
    }
    if (wide > 0 and wide < ids.len) {
        var narrow: std.ArrayList(u32) = .empty;
        for (ids) |k| if (units[k].x1 - units[k].x0 <= 0.6 * rw) try narrow.append(a, k);
        if (try gutterAt(a, units, narrow.items, med)) |ng| {
            const sorted = try a.dupe(u32, ids);
            const ByTop = struct {
                u: []Frag,
                fn lt(ctx: @This(), l: u32, r: u32) bool {
                    return ctx.u[l].y0 < ctx.u[r].y0;
                }
            };
            std.mem.sort(u32, sorted, ByTop{ .u = units }, ByTop.lt);
            var seg: std.ArrayList(u32) = .empty;
            for (sorted) |k| {
                // (a wide unit spans only when it crosses the narrow units' gutter: a wide line of the right-hand
                //  box beside a narrow one is part of that box)
                if (units[k].x1 - units[k].x0 > 0.6 * rw and units[k].x0 < ng and units[k].x1 > ng) {
                    try xycut(a, units, seg.items, out, aside, depth + 1);
                    seg = .empty;
                    try out.append(a, k);
                } else try seg.append(a, k);
            }
            try xycut(a, units, seg.items, out, aside, depth + 1);
            return;
        }
    }
    // a gutter that a few lines cross (a title, a date line, a heading, a footer): the stretches between those
    // lines are read on their own, each with its own gutter, and each bridging line where it falls
    if (try bridgeSplit(a, units, ids, med, rx0, rx1, out, aside, depth)) return;
    // strips from the top
    const sorted = try a.dupe(u32, ids);
    const ByTop = struct {
        u: []Frag,
        fn lt(ctx: @This(), l: u32, r: u32) bool {
            if (@abs(ctx.u[l].y0 - ctx.u[r].y0) > 0.5) return ctx.u[l].y0 < ctx.u[r].y0;
            return ctx.u[l].x0 < ctx.u[r].x0;
        }
    };
    std.mem.sort(u32, sorted, ByTop{ .u = units }, ByTop.lt);
    // the widest horizontal gap between strips cuts first: a band of boxes side by side between two full-width
    // tables then becomes a region of its own and finds its gutter (peeling one strip from the top read such
    // boxes line by line across both)
    {
        var bot: f32 = units[sorted[0]].y1;
        var best_gap: f32 = 0;
        var best_at: usize = 0;
        var nstrips: usize = 1;
        var q: usize = 1;
        while (q < sorted.len) : (q += 1) {
            const u = units[sorted[q]];
            if (u.y0 > bot + 0.05 * med) {
                nstrips += 1;
                const gap = u.y0 - bot;
                if (gap > best_gap) {
                    best_gap = gap;
                    best_at = q;
                }
            }
            bot = @max(bot, u.y1);
        }
        if (nstrips >= 3 and best_at > 0 and best_gap >= 0.8 * med) {
            try xycut(a, units, sorted[0..best_at], out, aside, depth + 1);
            try xycut(a, units, sorted[best_at..], out, aside, depth + 1);
            return;
        }
    }
    var bottom: f32 = units[sorted[0]].y1;
    var k: usize = 1;
    while (k < sorted.len) : (k += 1) {
        if (units[sorted[k]].y0 > bottom + 0.05 * med) break;
        bottom = @max(bottom, units[sorted[k]].y1);
    }
    if (k == sorted.len) {
        // one strip: left to right
        const ByX = struct {
            u: []Frag,
            fn lt(ctx: @This(), l: u32, r: u32) bool {
                return ctx.u[l].x0 < ctx.u[r].x0;
            }
        };
        std.mem.sort(u32, sorted, ByX{ .u = units }, ByX.lt);
        try out.appendSlice(a, sorted);
        return;
    }
    try xycut(a, units, sorted[0..k], out, aside, depth + 1);
    try xycut(a, units, sorted[k..], out, aside, depth + 1);
}

// Two boxes side by side with lines crossing between them: the x where the ink crossing is lowest, over a run at
// least 1.2 sizes wide, carrying at most a fifth of the region's ink height. Both sides must hold lines of a third
// of the region's width or more -- a column of labels beside its values is a table, not two boxes.
fn bridgeSplit(a: Allocator, units: []Frag, ids: []u32, med: f32, rx0: f32, rx1: f32, out: *std.ArrayList(u32), aside: *std.ArrayList(u32), depth: u32) anyerror!bool {
    if (ids.len < 6) return false;
    const rw = rx1 - rx0;
    if (rw < 10 * med) return false;
    var ink: f32 = 0;
    for (ids) |k| ink += units[k].y1 - units[k].y0;
    if (ink <= 0) return false;
    const n: usize = @intFromFloat(@ceil(rw));
    const cov = try a.alloc(f32, n + 1);
    @memset(cov, 0);
    for (ids) |k| {
        const u = units[k];
        const h = u.y1 - u.y0;
        var i: usize = @intFromFloat(@max(0, @floor(u.x0 - rx0)));
        const j: usize = @min(n, @as(usize, @intFromFloat(@max(0, @ceil(u.x1 - rx0)))));
        while (i < j) : (i += 1) cov[i] += h;
    }
    // the widest run of low crossing ink, away from both edges
    const limit = 0.2 * ink;
    var best_lo: usize = 0;
    var best_hi: usize = 0;
    var i: usize = 0;
    while (i <= n) {
        if (cov[i] > limit) {
            i += 1;
            continue;
        }
        const lo = i;
        while (i <= n and cov[i] <= limit) i += 1;
        if (lo == 0 or i > n) continue; // a margin, not a gutter
        if (i - lo > best_hi - best_lo) {
            best_lo = lo;
            best_hi = i;
        }
    }
    if (@as(f32, @floatFromInt(best_hi - best_lo)) < 1.2 * med) return false;
    // the gutter: the lowest point of the run
    var g = best_lo;
    for (best_lo..best_hi) |x| {
        if (cov[x] < cov[g]) g = x;
    }
    const gx = rx0 + @as(f32, @floatFromInt(g)) + 0.5;
    var nb: usize = 0;
    var lw: f32 = 0;
    var rwid: f32 = 0;
    var ly = [2]f32{ 1e9, -1e9 };
    var ry = [2]f32{ 1e9, -1e9 };
    for (ids) |k| {
        const u = units[k];
        if (u.x0 < gx and u.x1 > gx) {
            nb += 1;
        } else if (u.x1 <= gx) {
            lw = @max(lw, u.x1 - u.x0);
            ly = .{ @min(ly[0], u.y0), @max(ly[1], u.y1) };
        } else {
            rwid = @max(rwid, u.x1 - u.x0);
            ry = .{ @min(ry[0], u.y0), @max(ry[1], u.y1) };
        }
    }
    // nothing crosses the gutter, though a few lines run into the gap so the plain gutter test missed it: the
    // left side, then the right
    if (nb == 0) {
        if (lw < rw / 3 or rwid < rw / 3) return false;
        if (@min(ly[1], ry[1]) - @max(ly[0], ry[0]) <= 0) return false;
        var ls: std.ArrayList(u32) = .empty;
        var rs: std.ArrayList(u32) = .empty;
        for (ids) |k| {
            if (units[k].x1 <= gx) try ls.append(a, k) else try rs.append(a, k);
        }
        if (ls.items.len == 0 or rs.items.len == 0) return false;
        try xycut(a, units, ls.items, out, aside, depth + 1);
        try xycut(a, units, rs.items, out, aside, depth + 1);
        return true;
    }
    // a narrow side is a box only when it holds a gutter of its own (a small key/value box); a single column of
    // labels beside its values is a table, not two boxes
    if (lw < rw / 3 or rwid < rw / 3) {
        var ls: std.ArrayList(u32) = .empty;
        var rs: std.ArrayList(u32) = .empty;
        for (ids) |k| {
            const u = units[k];
            if (u.x1 <= gx) try ls.append(a, k) else if (u.x0 >= gx) try rs.append(a, k);
        }
        if (lw < rw / 3 and !(try hasGutter(a, units, ls.items, med))) return false;
        if (rwid < rw / 3 and !(try hasGutter(a, units, rs.items, med))) return false;
    }
    if (@min(ly[1], ry[1]) - @max(ly[0], ry[0]) <= 0) return false;
    const sorted = try a.dupe(u32, ids);
    const ByTop = struct {
        u: []Frag,
        fn lt(ctx: @This(), l: u32, r: u32) bool {
            return ctx.u[l].y0 < ctx.u[r].y0;
        }
    };
    std.mem.sort(u32, sorted, ByTop{ .u = units }, ByTop.lt);
    var seg: std.ArrayList(u32) = .empty;
    for (sorted) |k| {
        const u = units[k];
        if (u.x0 < gx and u.x1 > gx) {
            try xycut(a, units, seg.items, out, aside, depth + 1);
            seg = .empty;
            try out.append(a, k);
        } else try seg.append(a, k);
    }
    try xycut(a, units, seg.items, out, aside, depth + 1);
    return true;
}

fn gutterAt(a: Allocator, units: []Frag, ids: []u32, med: f32) !?f32 {
    if (ids.len < 2) return null;
    const sorted = try a.dupe(u32, ids);
    const ByX = struct {
        u: []Frag,
        fn lt(ctx: @This(), l: u32, r: u32) bool {
            return ctx.u[l].x0 < ctx.u[r].x0;
        }
    };
    std.mem.sort(u32, sorted, ByX{ .u = units }, ByX.lt);
    var right: f32 = units[sorted[0]].x1;
    var best: f32 = 0;
    var at: ?f32 = null;
    for (sorted[1..]) |k| {
        const gap = units[k].x0 - right;
        if (gap > best) {
            best = gap;
            at = (units[k].x0 + right) / 2;
        }
        right = @max(right, units[k].x1);
    }
    if (best >= 1.2 * med) return at;
    return null;
}

fn hasGutter(a: Allocator, units: []Frag, ids: []u32, med: f32) !bool {
    return (try gutterAt(a, units, ids, med)) != null;
}

fn spanY(units: []Frag, ids: []u32) [2]f32 {
    var y0: f32 = 1e9;
    var y1: f32 = -1e9;
    for (ids) |k| {
        y0 = @min(y0, units[k].y0);
        y1 = @max(y1, units[k].y1);
    }
    return .{ y0, y1 };
}

fn medSize(units: []Frag, ids: []u32) f32 {
    if (ids.len == 0) return 0;
    var buf: [512]f32 = undefined;
    const n = @min(ids.len, buf.len);
    for (ids[0..n], 0..) |k, j| buf[j] = units[k].size;
    std.mem.sort(f32, buf[0..n], {}, std.sort.asc(f32));
    return buf[n / 2];
}

fn gutterSplit(a: Allocator, units: []Frag, ids: []u32, med: f32, out: *std.ArrayList(u32), aside: *std.ArrayList(u32), depth: u32) anyerror!bool {
    const at = (try gutterAt(a, units, ids, med)) orelse return false;
    var l: std.ArrayList(u32) = .empty;
    var r: std.ArrayList(u32) = .empty;
    for (ids) |k| if (units[k].x1 <= at) try l.append(a, k) else try r.append(a, k);
    if (l.items.len == 0 or r.items.len == 0) return false;
    const ly = spanY(units, l.items);
    const ry = spanY(units, r.items);
    // two columns stand SIDE BY SIDE: units on different rows (a centred byline above a heading) are not columns
    if (@min(ly[1], ry[1]) - @max(ly[0], ry[0]) <= 0) return false;
    // the left column runs on below everything on the right and, somewhere below the right column's end, a gap
    // sets the rest apart: the columns end at that gap, and what follows (a heading, a caption, a table's title)
    // is read after BOTH columns
    {
        var below: std.ArrayList(u32) = .empty;
        for (l.items) |k| try below.append(a, k);
        const ByTop = struct {
            u: []Frag,
            fn lt(ctx: @This(), x: u32, y: u32) bool {
                return ctx.u[x].y0 < ctx.u[y].y0;
            }
        };
        std.mem.sort(u32, below.items, ByTop{ .u = units }, ByTop.lt);
        var right_beyond = false;
        for (r.items) |k| if (units[k].x1 > at) {
            right_beyond = true;
        };
        var cut_y: ?f32 = null;
        var prev_y1: f32 = -1e9;
        for (below.items) |k| {
            const u = units[k];
            if (u.y0 > ry[1] + 0.2 * med and prev_y1 > -1e8 and u.y0 - prev_y1 >= 1.0 * med) {
                cut_y = u.y0 - 0.1;
                break;
            }
            prev_y1 = @max(prev_y1, u.y1);
        }
        if (right_beyond) {
            if (cut_y) |cy| {
                var top: std.ArrayList(u32) = .empty;
                var tail: std.ArrayList(u32) = .empty;
                for (ids) |k| if (units[k].y0 >= cy) try tail.append(a, k) else try top.append(a, k);
                var tail_left = true;
                for (tail.items) |k| if (units[k].x1 > at) {
                    tail_left = false;
                };
                if (tail_left and top.items.len > 0 and tail.items.len > 0) {
                    try xycut(a, units, top.items, out, aside, depth + 1);
                    try xycut(a, units, tail.items, out, aside, depth + 1);
                    return true;
                }
            }
        }
    }
    // a narrower right column in smaller type, shorter than the left one, is an aside: it is read after the flow
    const lm = medSize(units, l.items);
    const rm = medSize(units, r.items);
    if (rm < 0.95 * lm and ry[1] - ry[0] < ly[1] - ly[0] and r.items.len < l.items.len) {
        try xycut(a, units, l.items, out, aside, depth + 1);
        try aside.appendSlice(a, r.items);
        return true;
    }
    try xycut(a, units, l.items, out, aside, depth + 1);
    try xycut(a, units, r.items, out, aside, depth + 1);
    return true;
}

// The bytes to drop when a text ends with a word broken by a hyphen ("versorgungs-" or "versorgungs -"): 0 when
// it does not. Only a letter before the hyphen counts, so a dash after a number or a space-separated dash stays.
fn dehyphen(t: []const u8) usize {
    if (t.len < 3) return 0;
    var n: usize = 0;
    var e = t.len;
    if (t[e - 1] == '-') {
        n = 1;
        e -= 1;
    } else if (e >= 3 and t[e - 2] == 0xC2 and t[e - 1] == 0xAD) {
        n = 2;
        e -= 2;
    } else if (e >= 4 and t[e - 3] == 0xE2 and t[e - 2] == 0x80 and t[e - 1] == 0x90) {
        // (U+2010, the hyphen an ActualText gives for a hyphen drawn at a line end)
        n = 3;
        e -= 3;
    } else return 0;
    if (e > 0 and t[e - 1] == ' ') {
        n += 1;
        e -= 1;
    }
    if (e == 0) return 0;
    const c = t[e - 1];
    if (!(std.ascii.isAlphabetic(c) or c >= 0x80)) return 0;
    if (e >= 2 and t[e - 2] == ' ') return 0; // a one-letter word before a dash is not a broken word
    if (compoundBreak(t)) return 0;
    return n;
}

// TRUE when a text ends with a compound broken after one of its own hyphens ("two-hundred-"): the hyphen is
// part of the word and stays when the line is joined.
fn compoundBreak(t: []const u8) bool {
    var e = t.len;
    while (e > 0 and t[e - 1] == ' ') e -= 1;
    if (e < 3 or t[e - 1] != '-') return false;
    var k = e - 1;
    while (k > 0 and t[k - 1] != ' ' and t[k - 1] != '\n') k -= 1;
    const word = t[k .. e - 1];
    return word.len > 0 and std.ascii.isAlphabetic(word[word.len - 1]) and std.mem.indexOfScalar(u8, word, '-') != null;
}

fn hasLower(t: []const u8) bool {
    var view = std.unicode.Utf8View.init(t) catch return true;
    var it = view.iterator();
    while (it.nextCodepoint()) |cp| {
        if (cp < 128 and std.ascii.isLower(@intCast(cp))) return true;
        if (cp >= 0xDF and cp <= 0xFF and cp != 0xF7) return true;
    }
    return false;
}

fn startsQuote(t: []const u8) bool {
    const qs = [_][]const u8{ "\"", "'", "\u{201C}", "\u{2018}", "\u{00AB}", "\u{201E}" };
    for (qs) |q| if (std.mem.startsWith(u8, t, q)) return true;
    return false;
}

// Line numbers in a gutter: a column of monospaced integers counting up, each beside a monospaced line of code.
fn dropLineNumbers(frags: []Frag) void {
    var n: usize = 0;
    var beside: usize = 0;
    for (frags) |f| {
        if (!f.mono or !isInt(f.text) or f.text.len > 5) continue;
        n += 1;
        for (frags) |o| {
            if (o.mono and !isInt(o.text) and @abs(o.base - f.base) < 0.3 * f.size and o.x0 > f.x1 and o.x0 - f.x1 < 12 * f.size) {
                beside += 1;
                break;
            }
        }
    }
    if (n < 3 or beside * 2 < n) return;
    // the numbers, top to bottom, count up by one (a column of figures in code does not)
    var vals: [4096][2]f32 = undefined;
    var m: usize = 0;
    for (frags) |f| {
        if (!f.mono or !isInt(f.text) or f.text.len > 5 or m >= vals.len) continue;
        vals[m] = .{ f.base, @floatFromInt(std.fmt.parseInt(u32, f.text, 10) catch 0) };
        m += 1;
    }
    const ByB = struct {
        fn lt(_: void, l: [2]f32, r: [2]f32) bool {
            return l[0] < r[0];
        }
    };
    std.mem.sort([2]f32, vals[0..m], {}, ByB.lt);
    var steps: usize = 0;
    for (1..m) |q| {
        if (vals[q][1] - vals[q - 1][1] == 1) steps += 1;
    }
    if (steps * 10 < (m - 1) * 8) return;
    for (frags) |*f| {
        if (f.mono and isInt(f.text) and f.text.len <= 5) f.text = "";
    }
}

// A block in a monospaced font that reads as prose: at least two sentence ends, and code punctuation in under
// one character in a hundred.
fn isMonoProse(t: []const u8) bool {
    var ends: usize = 0;
    var punct: usize = 0;
    for (t, 0..) |c, i| {
        if ((c == '.' or c == '?' or c == '!') and (i + 1 == t.len or t[i + 1] == ' ' or t[i + 1] == '\n')) ends += 1;
        switch (c) {
            '{', '}', '[', ']', '(', ')', ';', '=', '<', '>', '#', '$', '_', '"', '*', '/', '\\' => punct += 1,
            else => {},
        }
    }
    return ends >= 2 and punct * 100 < t.len;
}

fn startsListMarker(t: []const u8) usize {
    // returns the byte length of the marker (with its trailing space), 0 when the text does not start a list item
    const bullets = [_][]const u8{ "\u{2022}", "\u{25E6}", "\u{25AA}", "\u{25CF}", "\u{25CB}", "\u{25A0}", "\u{2023}", "\u{2043}", "\u{2013}", "\u{2192}", "\u{2713}", "\u{2714}", "-", "*", "\u{00B7}" };
    for (bullets) |b| {
        if (std.mem.startsWith(u8, t, b)) {
            var e = b.len;
            if (e < t.len and t[e] == ' ') e += 1 else if (b.len == 1) return 0;
            return e;
        }
    }
    // a bracketed marker: (a) (iv) (12) or [3], then a space
    if (t.len >= 4 and (t[0] == '(' or t[0] == '[')) {
        const close: u8 = if (t[0] == '(') ')' else ']';
        var j: usize = 1;
        var digits = true;
        var letters = true;
        while (j < t.len and j <= 4 and t[j] != close) : (j += 1) {
            if (!(t[j] >= '0' and t[j] <= '9')) digits = false;
            if (!std.ascii.isLower(t[j])) letters = false;
        }
        const n = j - 1;
        const ok_inner = n >= 1 and (digits or (letters and (n == 1 or std.mem.indexOfNone(u8, t[1..j], "ivxlc") == null)));
        // (a square bracket holds a number only: [a] is an editor's note, not a list)
        if (ok_inner and !(close == ']' and !digits) and j + 1 < t.len and t[j] == close and t[j + 1] == ' ') return j + 2;
    }
    // Arabic-Indic or Persian digits, then a full stop, a bracket, a dash or the Urdu full stop, then a space
    {
        var j: usize = 0;
        var nd: usize = 0;
        while (j + 1 < t.len and nd < 3) {
            const sl = std.unicode.utf8ByteSequenceLength(t[j]) catch break;
            if (sl != 2) break;
            const cp = std.unicode.utf8Decode(t[j .. j + 2]) catch break;
            if (!((cp >= 0x0660 and cp <= 0x0669) or (cp >= 0x06F0 and cp <= 0x06F9))) break;
            j += 2;
            nd += 1;
        }
        if (nd > 0 and j < t.len) {
            var m: usize = 0;
            if (t[j] == '.' or t[j] == ')' or t[j] == '-') m = 1 else if (std.mem.startsWith(u8, t[j..], "\u{06D4}")) m = 2;
            if (m > 0 and j + m < t.len and t[j + m] == ' ') return j + m + 1;
        }
    }
    var i: usize = 0;
    while (i < t.len and i < 3 and t[i] >= '0' and t[i] <= '9') i += 1;
    if (i == 0) {
        // a roman numeral, all lower or all upper case: i. ii. iv) ... XII.
        var r: usize = 0;
        const lower = t.len > 0 and std.ascii.isLower(t[0]);
        while (r < t.len and r < 5 and std.mem.indexOfScalar(u8, if (lower) "ivxlc" else "IVXLC", t[r]) != null) r += 1;
        if (r >= 1 and r + 1 < t.len and (t[r] == '.' or t[r] == ')') and t[r + 1] == ' ' and !(r == 1 and !lower and t[r] == '.')) return r + 2;
    }
    if (i == 0 and t.len >= 2 and std.ascii.isLower(t[0])) i = 1;
    if (i > 0 and i + 1 < t.len and (t[i] == '.' or t[i] == ')') and t[i + 1] == ' ') return i + 2;
    return 0;
}

fn normFurniture(a: Allocator, t: []const u8) ![]const u8 {
    const out = try a.dupe(u8, t);
    for (out) |*c| {
        if (c.* >= '0' and c.* <= '9') c.* = '#';
    }
    return out;
}

fn isPageNumber(t: []const u8) bool {
    if (pageNumberAnyLanguage(t)) return true;
    var lower_buf: [64]u8 = undefined;
    if (t.len > 40) return false;
    const l = std.ascii.lowerString(lower_buf[0..t.len], t);
    var s = l;
    if (std.mem.startsWith(u8, s, "page ")) s = s[5..];
    var i: usize = 0;
    while (i < s.len and s[i] >= '0' and s[i] <= '9') i += 1;
    if (i == 0) return false;
    if (i == s.len) return true;
    const rest = std.mem.trim(u8, s[i..], " ");
    if (std.mem.startsWith(u8, rest, "of ") or std.mem.startsWith(u8, rest, "/")) {
        const tail = std.mem.trim(u8, rest[if (rest[0] == '/') 1 else 3..], " ");
        if (tail.len == 0) return false;
        for (tail) |c| if (c < '0' or c > '9') return false;
        return true;
    }
    return false;
}

// A page number in any language: a short line holding one or two small numbers (the second, a page count, not
// below the first), at most three words and the usual separators -- "Seite 1 von 2", "1/1. oldal", "Strona 2 z 3",
// "- 3 -", and the same with Arabic-script digits. No word list: the words are whatever the language uses.
fn pageNumberAnyLanguage(t: []const u8) bool {
    var view = std.unicode.Utf8View.init(t) catch return false;
    var it = view.iterator();
    var nums: [3]u32 = undefined;
    var nn: usize = 0;
    var words: usize = 0;
    var cps: usize = 0;
    var cur: u32 = 0;
    var digits: usize = 0;
    var in_word = false;
    var word_len: usize = 0;
    var words_after_last_num: usize = 0;
    var between_ok = false; // a word or a slash stands between the two numbers ("1 von 2", "1/2"), not a full stop ("1.2")
    while (true) {
        const cpo = it.nextCodepoint();
        cps += 1;
        if (cps > 32) return false;
        const cp: u21 = cpo orelse ' ';
        var dv: ?u32 = null;
        if (cp >= '0' and cp <= '9') dv = cp - '0' else if (cp >= 0x0660 and cp <= 0x0669) dv = cp - 0x0660 else if (cp >= 0x06F0 and cp <= 0x06F9) dv = cp - 0x06F0;
        if (dv) |d| {
            if (in_word) return false; // a digit inside a word: a code, not a page number
            cur = cur * 10 + d;
            digits += 1;
            if (digits > 3) return false;
            if (cpo == null) break;
            continue;
        }
        if (digits > 0) {
            if (nn >= 2) return false;
            nums[nn] = cur;
            nn += 1;
            cur = 0;
            digits = 0;
            words_after_last_num = 0;
        }
        const letter = isLtrCp(cp) or isRtlCp(cp) or (cp >= 0x0400 and cp <= 0x04FF) or (cp >= 0x1200 and cp <= 0x137F) or (cp >= 0x0900 and cp <= 0x0E7F);
        if (letter) {
            if (!in_word) {
                words += 1;
                word_len = 0;
                if (words > 3) return false;
                if (nn > 0) {
                    words_after_last_num += 1;
                    if (nn == 1) between_ok = true;
                }
            }
            in_word = true;
            word_len += 1;
            if (word_len > 12) return false;
        } else {
            in_word = false;
            // separators a page number uses; anything else (a colon, a comma, an at sign) is a sentence or a contact line
            const sep = cp == ' ' or cp == '/' or cp == '.' or cp == '-' or cp == 0x2013 or cp == 0x2014 or cp == '|' or cp == 0x00B7 or cp == '(' or cp == ')' or cp == 0x00A0 or cp == 0x0640;
            if (!sep) return false;
            if (nn == 1 and cp == '/') between_ok = true;
        }
        if (cpo == null) break;
    }
    if (nn == 0) return false;
    if (nums[0] == 0) return false;
    // one number comes LAST (or alone): "Seite 3", "- 3 -"; a number first and words after is a numbered heading
    if (nn == 1) return words_after_last_num == 0;
    // two numbers: a page and a count, apart by a word or a slash; "1.2 Background" is a numbered heading
    if (!between_ok or nums[1] < nums[0]) return false;
    return words_after_last_num <= 1;
}

pub const Result = struct {
    arena: std.heap.ArenaAllocator,
    pages: u32 = 0,
    glyphs: usize = 0,
    version: []const u8 = "",
    encrypted: bool = false,
    tagged: bool = false,
    page_heights: []f32 = &.{}, // each page's height in points, from its crop box (or media box)
    blocks: []Block = &.{},
    text: []const u8 = "",

    pub fn deinit(r: *Result) void {
        r.arena.deinit();
    }
};

pub const ReadError = error{ NotPdf, Encrypted, NoPages, OutOfMemory };

/// Reads a PDF held in `bytes`. The result owns its memory (one arena): call deinit.
pub fn read(gpa: Allocator, bytes: []const u8) !Result {
    var res = Result{ .arena = std.heap.ArenaAllocator.init(gpa) };
    errdefer res.arena.deinit();
    const a = res.arena.allocator();
    if (bytes.len < 8 or std.mem.indexOf(u8, bytes[0..@min(bytes.len, 1024)], "%PDF") == null) return error.NotPdf;
    var d = try Doc.init(a, bytes);
    res.version = try a.dupe(u8, d.version); // the file's bytes are freed when read returns: nothing may point into them
    if (d.encrypted) {
        res.encrypted = true;
        return error.Encrypted;
    }

    // the pages, in page-tree order
    var pages: std.ArrayList(struct { dict: *Dict, res: ?*Dict, box: [4]f64 }) = .empty;
    const Walk = struct {
        fn go(dd: *Doc, al: Allocator, node: *Dict, res_in: ?*Dict, box_in: [4]f64, list: anytype, depth: u32) !void {
            if (depth > 64 or list.items.len > 100000) return;
            var resd = res_in;
            if (dd.dictOf(node.get("Resources") orelse .nul)) |r| resd = r;
            var box = box_in;
            const mb = dd.get(node, "CropBox");
            const mb2 = if (mb == .arr) mb else dd.get(node, "MediaBox");
            if (mb2 == .arr and mb2.arr.len >= 4) box = .{ nv(dd.resolve(mb2.arr[0])), nv(dd.resolve(mb2.arr[1])), nv(dd.resolve(mb2.arr[2])), nv(dd.resolve(mb2.arr[3])) };
            const kids = dd.get(node, "Kids");
            if (kids == .arr) {
                for (kids.arr) |kd| if (dd.dictOf(kd)) |kdd| try go(dd, al, kdd, resd, box, list, depth + 1);
                return;
            }
            try list.append(al, .{ .dict = node, .res = resd, .box = box });
        }
    };
    if (d.catalog()) |cat| {
        if (d.dictOf(cat.get("Pages") orelse .nul)) |root| try Walk.go(&d, a, root, null, .{ 0, 0, 612, 792 }, &pages, 0);
        if (cat.get("StructTreeRoot") != null) d.tagged = true;
    }
    res.tagged = d.tagged;
    if (pages.items.len == 0) return error.NoPages;
    res.pages = @intCast(pages.items.len);

    var text_bytes: std.ArrayList(u8) = .empty;
    var fonts: std.AutoHashMapUnmanaged(usize, *Font) = .empty;
    var page_list: std.ArrayList(Page) = .empty;
    for (pages.items) |pg| {
        var glyphs: std.ArrayList(Glyph) = .empty;
        var rules: std.ArrayList(Rule) = .empty;
        var dots: std.ArrayList(Rule) = .empty;
        var it = Interp{ .d = &d, .a = a, .glyphs = &glyphs, .rules = &rules, .dots = &dots, .text = &text_bytes, .fonts = &fonts, .page_top = pg.box[3], .page_left = pg.box[0] };
        const contents = d.resolve(pg.dict.get("Contents") orelse .nul);
        var data: std.ArrayList(u8) = .empty;
        switch (contents) {
            .stream => |st| if (d.decode(st)) |x| try data.appendSlice(a, x) else |_| {},
            .arr => |arr| for (arr) |c| {
                const cr = d.resolve(c);
                if (cr == .stream) {
                    if (d.decode(cr.stream)) |x| {
                        try data.appendSlice(a, x);
                        try data.append(a, '\n');
                    } else |_| {}
                }
            },
            else => {},
        }
        it.run(data.items, pg.res) catch {};
        res.glyphs += glyphs.items.len;
        try page_list.append(a, .{ .glyphs = glyphs.items, .rules = rules.items, .dots = dots.items, .width = @floatCast(pg.box[2] - pg.box[0]), .height = @floatCast(pg.box[3] - pg.box[1]) });
    }
    const tb = text_bytes.items;
    {
        var hs = try a.alloc(f32, page_list.items.len);
        for (page_list.items, 0..) |pg, k| hs[k] = pg.height;
        res.page_heights = hs;
    }

    // fragments, tables and reading order, page by page
    var blocks: std.ArrayList(Block) = .empty;
    var all_frags: std.ArrayList(Frag) = .empty;
    var frag_page_start: std.ArrayList(usize) = .empty;
    for (page_list.items, 0..) |pg, pi| {
        try frag_page_start.append(a, all_frags.items.len);
        var frags: std.ArrayList(Frag) = .empty;
        try fragments(a, pg, @intCast(pi + 1), tb, &frags);
        for (frags.items) |*f| {
            const rtl = isRtlCp(firstCp(f.text));
            for (pg.dots) |dt| {
                const cy = (dt.y0 + dt.y1) / 2;
                if (cy < f.y0 - 0.1 * f.size or cy > f.y1 + 0.1 * f.size) continue;
                const left = dt.x1 <= f.x0 + 1 and f.x0 - dt.x1 < 2.5 * f.size;
                const right = dt.x0 >= f.x1 - 1 and dt.x0 - f.x1 < 2.5 * f.size;
                if ((!rtl and left) or (rtl and right)) {
                    f.bullet = true;
                    break;
                }
            }
        }
        dropLineNumbers(frags.items);
        for (frags.items) |*mk| {
            if (mk.text.len == 0 or mk.text.len > 6) continue;
            const t2 = try std.mem.concat(a, u8, &.{ mk.text, " x" });
            if (startsListMarker(t2) != mk.text.len + 1) continue;
            for (frags.items) |*it| {
                if (it == mk or it.text.len == 0) continue;
                const after_ltr = it.x0 > mk.x1 and it.x0 - mk.x1 < 3 * mk.size and !isRtlCp(firstCp(it.text));
                const after_rtl = it.x1 < mk.x0 and mk.x0 - it.x1 < 3 * mk.size and isRtlCp(firstCp(it.text));
                if (@abs(it.base - mk.base) < 0.3 * mk.size and (after_ltr or after_rtl)) {
                    it.bullet = true;
                    // a marker set apart by a hanging indent is TEXT the producer wrote, so it stays at the head of its
                    // item (Chrome draws CSS bullets as shapes, and over golden_v1..v14 a CSS-numbered list never left
                    // its number standing apart: keeping numbers moved no earlier set and raised v14 .50 -> .73)
                    it.text = try std.mem.concat(a, u8, &.{ mk.text, " ", it.text });
                    if (after_ltr) it.x0 = mk.x0 else it.x1 = mk.x1;
                    mk.text = "";
                    break;
                }
            }
        }
        var tables: std.ArrayList(TableOut) = .empty;
        try findTables(a, frags.items, pg.rules, &tables);
        try growTables(a, frags.items, &tables);
        try findAlignedTables(a, frags.items, &tables);
        try growTables(a, frags.items, &tables);
        try stackTables(a, frags.items, &tables);
        // units: the fragments outside tables, plus one unit per table
        var units: std.ArrayList(Frag) = .empty;
        for (frags.items) |f| if (f.table < 0 and f.text.len > 0) try units.append(a, f);
        for (tables.items, 0..) |t, ti| {
            if (t.rows.len == 0) continue; // merged into another table
            try units.append(a, .{ .page = @intCast(pi + 1), .x0 = t.x0, .x1 = t.x1, .base = t.y1, .y0 = t.y0, .y1 = t.y1, .size = t.size, .bold = false, .mono = false, .text = "", .table = @intCast(ti) });
        }
        const ids = try a.alloc(u32, units.items.len);
        for (ids, 0..) |*v, k| v.* = @intCast(k);
        var order: std.ArrayList(u32) = .empty;
        var aside: std.ArrayList(u32) = .empty;
        try xycut(a, units.items, ids, &order, &aside, 0);
        // an aside (a sidebar in smaller type beside the main text) is read after the page's main flow
        try order.appendSlice(a, aside.items);
        for (order.items) |k| {
            const u = units.items[k];
            if (u.table >= 0) {
                const t = tables.items[@intCast(u.table)];
                var flat: std.ArrayList(u8) = .empty;
                for (t.rows) |row| {
                    for (row, 0..) |c, ci| {
                        if (ci > 0) try flat.append(a, ' ');
                        try flat.appendSlice(a, c);
                    }
                    try flat.append(a, ' ');
                }
                try blocks.append(a, .{ .page = u.page, .kind = .table, .x0 = t.x0, .y0 = t.y0, .x1 = t.x1, .y1 = t.y1, .size = t.size, .bold = false, .mono = false, .text = std.mem.trim(u8, flat.items, " "), .rows = t.rows });
                continue;
            }
            try all_frags.append(a, u);
        }
        // paragraphs: merge the ordered fragments of this page
        _ = &blocks;
    }

    // merge consecutive fragments into blocks (per page, already in reading order)
    var merged: std.ArrayList(Block) = .empty;
    {
        var cur: ?Block = null;
        var cur_text: std.ArrayList(u8) = .empty;
        var last: Frag = undefined;
        var list_x: f32 = 0;
        var list_rtl = false;
        const flush = struct {
            fn f(al: Allocator, m: *std.ArrayList(Block), c: *?Block, t: *std.ArrayList(u8)) !void {
                if (c.*) |*b| {
                    b.text = try al.dupe(u8, t.items);
                    try m.append(al, b.*);
                }
                c.* = null;
                t.* = .empty;
            }
        }.f;
        for (all_frags.items) |f| {
            const mk = startsListMarker(f.text);
            const item = mk > 0 or f.bullet;
            var join = false;
            if (cur) |b| {
                const same_style = @abs(f.size - b.size) <= 0.15 * b.size and f.bold == b.bold and f.mono == b.mono and f.italic == b.italic;
                const maxgap: f32 = if (b.mono and f.mono) 3.5 * f.size else 0.9 * f.size;
                const below = f.page == b.page and f.y0 >= last.y0 + 0.3 * f.size and f.y0 - last.y1 <= maxgap;
                // (an indented line of code under a short one -- "{" -- does not overlap it and still continues it)
                const overlap = (f.x0 < b.x1 + 1 and f.x1 > b.x0 - 1) or (b.mono and f.mono and f.x0 >= b.x0 - 0.5 * f.size);
                if (same_style and below and overlap and !item) {
                    if (b.kind == .list_item) {
                        join = if (list_rtl) f.x1 <= list_x + 0.5 * f.size else f.x0 >= list_x - 0.5 * f.size;
                    } else join = true;
                }
            }
            if (join) {
                var b = &cur.?;
                if (b.mono) {
                    try cur_text.append(a, '\n');
                    // a blank line of code leaves a gap of whole lines
                    const blank: usize = @intFromFloat(@max(0, @round((f.y0 - last.y1) / (1.15 * f.size))));
                    try cur_text.appendNTimes(a, '\n', @min(blank, 4));
                    const indent: usize = @intFromFloat(@max(0, @round((f.x0 - b.x0) / (0.6 * f.size))));
                    try cur_text.appendNTimes(a, ' ', @min(indent, 40));
                } else if (compoundBreak(cur_text.items) and f.text.len > 0 and std.ascii.isLower(f.text[0])) {
                    while (cur_text.items.len > 0 and cur_text.items[cur_text.items.len - 1] == ' ') cur_text.shrinkRetainingCapacity(cur_text.items.len - 1);
                } else if (dehyphen(cur_text.items) > 0 and f.text.len > 0 and std.ascii.isLower(f.text[0])) {
                    cur_text.shrinkRetainingCapacity(cur_text.items.len - dehyphen(cur_text.items));
                } else try cur_text.append(a, ' ');
                try cur_text.appendSlice(a, f.text);
                b.lines += 1;
                b.x0 = @min(b.x0, f.x0);
                b.x1 = @max(b.x1, f.x1);
                b.y1 = @max(b.y1, f.y1);
            } else {
                try flush(a, &merged, &cur, &cur_text);
                var kind: Kind = .paragraph;
                if (item) {
                    kind = .list_item;
                    // a typed marker: the next line of the item is indented past it; a drawn bullet: the item's text
                    // starts where its next line does
                    list_rtl = isRtlCp(firstCp(f.text[mk..]));
                    list_x = if (list_rtl)
                        (if (mk > 0) f.x1 - 1.0 * f.size else f.x1 - 0.4 * f.size)
                    else if (mk > 0) f.x0 + 1.0 * f.size else f.x0 + 0.4 * f.size; // (0.4: a line starting exactly where the item does)
                } else if (f.mono) kind = .code;
                cur = .{ .page = f.page, .kind = kind, .x0 = f.x0, .y0 = f.y0, .x1 = f.x1, .y1 = f.y1, .size = f.size, .bold = f.bold, .mono = f.mono, .italic = f.italic, .text = "" };
                const lb = f.lead_bold;
                const lead = if (lb > 0 and lb < f.text.len) trimSpace(f.text[0..lb]) else "";
                if (kind == .paragraph and lead.len > 0 and lead.len <= 60 and wordCount(lead) <= 8) {
                    // the bold lead-in is a heading block of its own; the rest of the line opens the paragraph
                    try merged.append(a, .{ .page = f.page, .kind = .paragraph, .x0 = f.x0, .y0 = f.y0, .x1 = f.x1, .y1 = f.y1, .size = f.size, .bold = true, .mono = false, .text = try a.dupe(u8, lead), .runin = true });
                    try cur_text.appendSlice(a, trimSpace(f.text[lb..]));
                } else try cur_text.appendSlice(a, f.text);
            }
            last = f;
        }
        try flush(a, &merged, &cur, &cur_text);
    }

    // classify: headings by size (and bold short lines), furniture by repetition in the page margins
    var body: f32 = 0;
    {
        var hist: std.AutoHashMapUnmanaged(u32, usize) = .empty;
        var best: usize = 0;
        for (merged.items) |b| {
            const key: u32 = @intFromFloat(@round(b.size * 2));
            const e = try hist.getOrPut(a, key);
            if (!e.found_existing) e.value_ptr.* = 0;
            e.value_ptr.* += b.text.len;
            if (e.value_ptr.* > best) {
                best = e.value_ptr.*;
                body = @as(f32, @floatFromInt(key)) / 2;
            }
        }
    }
    var marg: std.StringHashMapUnmanaged(std.AutoHashMapUnmanaged(u32, void)) = .empty;
    for (merged.items) |b| {
        const h = page_list.items[b.page - 1].height;
        if (!(b.y1 < 0.12 * h or b.y0 > 0.88 * h)) continue;
        const key = try normFurniture(a, b.text);
        const e = try marg.getOrPut(a, key);
        if (!e.found_existing) e.value_ptr.* = .empty;
        try e.value_ptr.put(a, b.page, {});
    }
    var hsizes: std.ArrayList(f32) = .empty;
    for (merged.items) |*b| {
        const h = page_list.items[b.page - 1].height;
        const top = b.y1 < 0.12 * h;
        const bottom = b.y0 > 0.88 * h;
        if (top or bottom) {
            const key = try normFurniture(a, b.text);
            const pagesn = if (marg.get(key)) |m| m.count() else 0;
            // (a page number is never set larger than the body: "AquaSense 300" at the top of a page is a title)
            if (pagesn >= 2 or (isPageNumber(b.text) and (body <= 0 or b.size <= 1.05 * body))) {
                b.kind = if (top) .page_header else .page_footer;
                continue;
            }
            if (b.kind == .paragraph and body > 0 and ((b.lines == 1 and b.size <= 0.92 * body and wordCount(b.text) <= 12) or (b.lines <= 3 and b.size <= 0.85 * body) or (b.lines <= 3 and b.size <= 0.92 * body and wordCount(b.text) <= 6 * b.lines))) {
                b.kind = if (top) .page_header else .page_footer;
                continue;
            }
        }
        if (b.kind == .list_item and startsListMarker(b.text) > 0 and body > 0 and b.lines == 1 and b.text.len <= 120 and
            (b.size >= 1.08 * body or (b.bold and b.text[b.text.len - 1] != '.')))
        {
            b.kind = .heading;
            try hsizes.append(a, b.size);
            continue;
        }
        if (b.kind == .code and isMonoProse(b.text)) b.kind = .paragraph;
        // one line of monospaced type, larger than the body or bold, is a heading set in a typewriter face
        if (b.kind == .code and b.lines == 1 and body > 0 and b.text.len <= 80 and (b.size >= 1.15 * body or b.bold)) {
            b.kind = .heading;
            try hsizes.append(a, b.size);
            continue;
        }
        if (b.kind == .paragraph and b.runin) {
            b.kind = .heading;
            try hsizes.append(a, b.size);
            continue;
        }
        if (b.kind != .paragraph) continue;
        const short = b.text.len <= 160;
        const ends = b.text.len > 0 and (b.text[b.text.len - 1] == '.' or b.text[b.text.len - 1] == ':' or b.text[b.text.len - 1] == ',');
        if (body > 0 and b.size >= 1.15 * body and short) {
            b.kind = .heading;
            try hsizes.append(a, b.size);
        } else if (b.bold and short and !ends and b.size >= 0.95 * body and b.lines == 1) {
            b.kind = .heading;
            try hsizes.append(a, b.size);
        } else if (b.italic and short and !ends and b.size >= 0.95 * body and b.lines == 1 and b.text.len <= 80 and !startsQuote(b.text)) {
            b.kind = .heading;
            try hsizes.append(a, b.size);
        }
    }
    // a heading is never a label ending in a colon or a full stop ("Note:", "Decision:"), nor a figure with no
    // letter (a price, a total): measured over golden_v1..v11, 78 such headings were false and one true. A run-in
    // lead so refused goes back into the paragraph it opens.
    {
        var k: usize = 0;
        while (k < merged.items.len) {
            const b = merged.items[k];
            if (b.kind != .heading or b.text.len == 0) {
                k += 1;
                continue;
            }
            const last = b.text[b.text.len - 1];
            const label = last == ':' or last == '.' or std.mem.endsWith(u8, b.text, "\u{FF1A}");
            // a heading that shares its baseline with two or more other short blocks is a cell of a row
            var mates: usize = 0;
            if (b.lines == 1) for (merged.items, 0..) |o, q| {
                if (q == k or o.page != b.page or o.lines != 1 or wordCount(o.text) > 4) continue;
                if (@abs(o.y1 - b.y1) <= 0.3 * b.size and (o.x1 <= b.x0 or o.x0 >= b.x1)) mates += 1;
            };
            // (column headings of a poster share a baseline too, but prose follows each of them)
            const prose_next = k + 1 < merged.items.len and merged.items[k + 1].kind == .paragraph and merged.items[k + 1].lines >= 2;
            if (!label and hasLetter(b.text) and (mates < 2 or prose_next)) {
                k += 1;
                continue;
            }
            merged.items[k].kind = .paragraph;
            merged.items[k].level = 0;
            if (b.runin and k + 1 < merged.items.len and merged.items[k + 1].kind == .paragraph and merged.items[k + 1].page == b.page) {
                const nx = &merged.items[k + 1];
                nx.text = try std.mem.concat(a, u8, &.{ b.text, " ", nx.text });
                nx.x0 = @min(nx.x0, b.x0);
                nx.y0 = @min(nx.y0, b.y0);
                _ = merged.orderedRemove(k);
                continue;
            }
            k += 1;
        }
    }
    // the lowest line of a page, when one of its blocks is a page number, is the page's footer wherever it sits
    // (a footer set inside the page box, above the bottom band: "Σελίδα 1 από 1" beside a legal line)
    {
        var pgi: u32 = 1;
        while (pgi <= page_list.items.len) : (pgi += 1) {
            var low: f32 = -1e9;
            for (merged.items) |b| {
                if (b.page == pgi and b.y1 > low) low = b.y1;
            }
            if (low < -1e8) continue;
            var has_num = false;
            for (merged.items) |b| {
                if (b.page == pgi and b.lines == 1 and @abs(b.y1 - low) <= 0.3 * b.size and isPageNumber(b.text)) has_num = true;
            }
            if (!has_num) continue;
            for (merged.items) |*b| {
                if (b.page == pgi and b.lines <= 2 and @abs(b.y1 - low) <= 0.3 * b.size and b.kind == .paragraph) b.kind = .page_footer;
            }
        }
    }
    // a letterhead: on the first page, the blocks of the top band that end above the title (the largest heading
    // near the top) are furniture, not the document's own text
    {
        var title: ?usize = null;
        for (merged.items, 0..) |b, k| {
            if (b.page != 1 or b.kind != .heading) continue;
            const h = page_list.items[0].height;
            if (b.y0 > 0.3 * h) continue;
            if (title == null or b.size > merged.items[title.?].size) title = k;
        }
        if (title) |ti| {
            const tblk = merged.items[ti];
            const h = page_list.items[0].height;
            for (merged.items, 0..) |*b, k| {
                if (k == ti or b.page != 1) continue;
                if (!(b.y1 < tblk.y0 and b.y1 < 0.18 * h and b.size <= tblk.size)) continue;
                // a letterhead holds a logo name (in capitals) and short lines (an address), never a sentence
                const logo = b.kind == .heading and !hasLower(b.text);
                // (address lines read together as one block: up to eight words a line, and no sentence's full stop)
                const ends_stop = b.text.len > 0 and b.text[b.text.len - 1] == '.';
                const short_line = b.kind == .paragraph and ((b.lines <= 3 and wordCount(b.text) <= 12) or (b.lines <= 4 and wordCount(b.text) <= 8 * b.lines and !ends_stop));
                if (logo or short_line) b.kind = .page_header;
            }
        }
    }
    // heading levels: distinct sizes, largest first
    std.mem.sort(f32, hsizes.items, {}, std.sort.desc(f32));
    var levels: std.ArrayList(f32) = .empty;
    for (hsizes.items) |s| {
        if (levels.items.len == 0 or levels.items[levels.items.len - 1] - s > 0.06 * s) try levels.append(a, s);
    }
    for (merged.items) |*b| {
        if (b.kind != .heading) continue;
        var lv: u32 = 1;
        for (levels.items, 0..) |s, k| {
            if (@abs(s - b.size) <= 0.06 * s) {
                lv = @intCast(k + 1);
                break;
            }
        }
        b.level = lv;
    }
    // an italic heading that shares its size with a bold one sits one level below it
    for (merged.items) |*b| {
        if (b.kind != .heading or !b.italic or b.bold) continue;
        for (merged.items) |o| {
            if (o.kind == .heading and o.bold and @abs(o.size - b.size) <= 0.06 * b.size) {
                b.level = o.level + 1;
                break;
            }
        }
    }
    // list levels: indentation within a run of list items
    {
        var k: usize = 0;
        while (k < merged.items.len) {
            if (merged.items[k].kind != .list_item) {
                k += 1;
                continue;
            }
            var e = k;
            var minx: f32 = 1e9;
            while (e < merged.items.len and merged.items[e].kind == .list_item and merged.items[e].page == merged.items[k].page) : (e += 1) minx = @min(minx, merged.items[e].x0);
            // a right-to-left list is indented from the right: its edge is the right one
            var nrtl: usize = 0;
            for (merged.items[k..e]) |b| {
                if (isRtlCp(firstCp(b.text[startsListMarker(b.text)..]))) nrtl += 1;
            }
            const rtl = 2 * nrtl > e - k;
            var xs: std.ArrayList(f32) = .empty;
            for (merged.items[k..e]) |b| try xs.append(a, if (rtl) -b.x1 else b.x0);
            const steps = try clusterVals(a, xs.items, 4);
            for (merged.items[k..e]) |*b| {
                var lv: u32 = 0;
                const edge = if (rtl) -b.x1 else b.x0;
                for (steps, 0..) |sx, si| {
                    if (@abs(sx - edge) <= 4) lv = @intCast(si);
                }
                b.level = lv;
            }
            k = @max(e, k + 1);
        }
    }

    // tables and text blocks share one order: by page, then by the merged position
    var final: std.ArrayList(Block) = .empty;
    for (0..page_list.items.len) |pi| {
        // place the page's tables among its blocks by vertical position
        var page_blocks: std.ArrayList(Block) = .empty;
        for (merged.items) |b| if (b.page == pi + 1) try page_blocks.append(a, b);
        for (blocks.items) |t| {
            if (t.page != pi + 1) continue;
            var at: usize = page_blocks.items.len;
            for (page_blocks.items, 0..) |b, k| {
                if (b.y0 > t.y0 and b.x1 > t.x0 and b.x0 < t.x1) {
                    at = k;
                    break;
                }
            }
            try page_blocks.insert(a, at, t);
        }
        try final.appendSlice(a, page_blocks.items);
    }
    // a paragraph that ends with a broken word continues in the next paragraph (the next column or page)
    {
        var k: usize = 0;
        while (k + 1 < final.items.len) {
            const b1 = final.items[k];
            const b2 = final.items[k + 1];
            const cut = dehyphen(b1.text);
            const new_column = b2.page == b1.page + 1 or (b2.page == b1.page and b2.y0 < b1.y0);
            const runs_on = b1.text.len > 0 and std.mem.indexOfScalar(u8, ".!?:;", b1.text[b1.text.len - 1]) == null and cut == 0 and !compoundBreak(b1.text);
            if (b1.kind == .paragraph and b2.kind == .paragraph and runs_on and new_column and b2.text.len > 0 and std.ascii.isLower(b2.text[0])) {
                final.items[k].text = try std.mem.concat(a, u8, &.{ b1.text, " ", b2.text });
                final.items[k].lines += b2.lines;
                _ = final.orderedRemove(k + 1);
                continue;
            }
            if (b1.kind == .paragraph and b2.kind == .paragraph and compoundBreak(b1.text) and b2.text.len > 0 and std.ascii.isLower(b2.text[0]) and b2.page <= b1.page + 1) {
                final.items[k].text = try std.mem.concat(a, u8, &.{ std.mem.trimRight(u8, b1.text, " "), b2.text });
                final.items[k].lines += b2.lines;
                _ = final.orderedRemove(k + 1);
                continue;
            }
            if (b1.kind == .paragraph and b2.kind == .paragraph and cut > 0 and b2.text.len > 0 and std.ascii.isLower(b2.text[0]) and b2.page <= b1.page + 1) {
                final.items[k].text = try std.mem.concat(a, u8, &.{ b1.text[0 .. b1.text.len - cut], b2.text });
                final.items[k].lines += b2.lines;
                _ = final.orderedRemove(k + 1);
                continue;
            }
            k += 1;
        }
    }
    // a table that ends a page and one that starts the next, with as many columns, are one table
    {
        var k: usize = 0;
        // the page a table joined so far ENDS on (a table over three pages joins its third part to its second)
        var tail_k: usize = std.math.maxInt(usize);
        var tail_page: u32 = 0;
        while (k + 1 < final.items.len) {
            const t1 = final.items[k];
            if (tail_k != k) {
                tail_k = k;
                tail_page = t1.page;
            }
            var j2 = k + 1;
            while (j2 < final.items.len and (final.items[j2].kind == .page_header or final.items[j2].kind == .page_footer)) j2 += 1;
            if (j2 >= final.items.len) break;
            const t2 = final.items[j2];
            if (t1.kind == .table and t2.kind == .table and t2.page == tail_page + 1 and t1.rows.len > 0 and t2.rows.len > 0 and t1.rows[0].len == t2.rows[0].len) {
                var same_head = true;
                for (t1.rows[0], t2.rows[0]) |c1, c2| if (!eq(c1, c2)) {
                    same_head = false;
                };
                const from: usize = if (same_head) 1 else 0;
                var rows = try a.alloc([][]const u8, t1.rows.len + t2.rows.len - from);
                @memcpy(rows[0..t1.rows.len], t1.rows);
                @memcpy(rows[t1.rows.len..], t2.rows[from..]);
                final.items[k].rows = rows;
                final.items[k].text = try std.mem.concat(a, u8, &.{ t1.text, " ", t2.text });
                tail_page = t2.page;
                _ = final.orderedRemove(j2);
                continue;
            }
            k += 1;
        }
    }
    // a caption: a short block right above a table, or one right below it that names itself
    for (final.items, 0..) |t, k| {
        if (t.kind != .table) continue;
        if (k > 0) {
            const c = &final.items[k - 1];
            if (c.page == t.page and (c.kind == .paragraph or (c.kind == .heading and c.size <= 1.05 * t.size)) and c.lines <= 2 and t.y0 - c.y1 <= 2.0 * c.size and c.x1 > t.x0 and c.x0 < t.x1) {
                // (a heading in larger type than the table is a section heading, not the table's caption)
                c.kind = .caption;
                c.level = 0;
            }
        }
        if (k + 1 < final.items.len) {
            const c = &final.items[k + 1];
            const names = std.mem.startsWith(u8, c.text, "Table") or std.mem.startsWith(u8, c.text, "Figure") or std.mem.startsWith(u8, c.text, "Source");
            if (c.page == t.page and c.kind == .paragraph and names and c.lines <= 2 and c.y0 - t.y1 <= 2.0 * c.size) c.kind = .caption;
        }
    }
    for (final.items) |*b| {
        if (b.kind != .table) continue;
        // blank rows ABOVE the first row with text are a band (a double border, a header's background), not rows;
        // a blank row further down is kept: a form's empty row is part of the table
        var first: usize = 0;
        while (first < b.rows.len) : (first += 1) {
            var any = false;
            for (b.rows[first]) |c| {
                if (c.len > 0) any = true;
            }
            if (any) break;
        }
        if (first < b.rows.len) b.rows = b.rows[first..];
    }
    for (final.items) |*b| {
        if (b.kind != .table) continue;
        for (b.rows) |row| {
            const n = row.len;
            if (n < 3 or row[n - 1].len == 0) continue;
            var lab: ?usize = null;
            var others: usize = 0;
            for (row[0 .. n - 1], 0..) |c, j| {
                if (c.len > 0) {
                    others += 1;
                    if (lab == null) lab = j;
                }
            }
            if (others != 1) continue;
            const l = lab.?;
            if (l == 0) continue;
            for (0..n - 1) |j| row[j] = row[l];
        }
    }
    // boxes side by side, each a small table under its own title, read as ONE table whose first row holds only
    // the titles ([title] [] [title] []): one table per box, its title a heading above it, box by box
    {
        var k: usize = 0;
        while (k < final.items.len) : (k += 1) {
            const t = final.items[k];
            if (t.kind != .table or t.rows.len < 3) continue;
            const n = t.rows[0].len;
            if (n < 4) continue;
            var starts: std.ArrayList(usize) = .empty;
            for (t.rows[0], 0..) |c, j| {
                if (c.len > 0) try starts.append(a, j);
            }
            if (starts.items.len < 2 or starts.items[0] != 0) continue;
            var groups_ok = true;
            for (starts.items, 0..) |st, gi| {
                const en = if (gi + 1 < starts.items.len) starts.items[gi + 1] else n;
                if (en - st < 2) groups_ok = false;
            }
            if (!groups_ok) continue;
            // the title row is not data: the next row has text in more cells than the titles
            var filled: usize = 0;
            for (t.rows[1]) |c| {
                if (c.len > 0) filled += 1;
            }
            if (filled <= starts.items.len) continue;
            var rtl_n: usize = 0;
            var ltr_n: usize = 0;
            for (t.rows) |row| for (row) |c| {
                const cp = firstCp(c);
                if (isRtlCp(cp)) rtl_n += 1;
                if (isLtrCp(cp)) ltr_n += 1;
            };
            var level: u32 = 2;
            {
                var q = k;
                while (q > 0) {
                    q -= 1;
                    if (final.items[q].kind == .heading) {
                        level = final.items[q].level + 1;
                        break;
                    }
                }
            }
            var parts: std.ArrayList(Block) = .empty;
            const ng = starts.items.len;
            for (0..ng) |gq| {
                const gi = if (rtl_n > ltr_n) ng - 1 - gq else gq;
                const st = starts.items[gi];
                const en = if (gi + 1 < ng) starts.items[gi + 1] else n;
                const w = (t.x1 - t.x0) / @as(f32, @floatFromInt(n));
                const gx0 = t.x0 + w * @as(f32, @floatFromInt(st));
                const gx1 = t.x0 + w * @as(f32, @floatFromInt(en));
                var rows: std.ArrayList([][]const u8) = .empty;
                var flat: std.ArrayList(u8) = .empty;
                for (t.rows[1..]) |row| {
                    try rows.append(a, row[st..en]);
                    for (row[st..en]) |c| {
                        if (c.len == 0) continue;
                        if (flat.items.len > 0) try flat.append(a, ' ');
                        try flat.appendSlice(a, c);
                    }
                }
                var hb = t;
                hb.kind = .heading;
                hb.level = level;
                hb.bold = true;
                hb.rows = &.{};
                hb.text = t.rows[0][st];
                hb.x0 = gx0;
                hb.x1 = gx1;
                try parts.append(a, hb);
                var tb2 = t;
                tb2.rows = rows.items;
                tb2.text = flat.items;
                tb2.x0 = gx0;
                tb2.x1 = gx1;
                try parts.append(a, tb2);
            }
            try final.replaceRange(a, k, 1, parts.items);
            k += parts.items.len - 1;
        }
    }
    for (final.items) |*b| {
        if (b.kind != .table) continue;
        var nr: usize = 0;
        var nl: usize = 0;
        for (b.rows) |row| for (row) |c| {
            var view = std.unicode.Utf8View.init(c) catch continue;
            var it = view.iterator();
            while (it.nextCodepoint()) |cp| {
                if (isRtlCp(cp)) {
                    nr += 1;
                    break;
                }
                if (isLtrCp(cp)) {
                    nl += 1;
                    break;
                }
            }
        };
        if (nr <= nl) continue;
        for (b.rows) |row| std.mem.reverse([]const u8, row);
    }
    try arabicDocFix(a, final.items);
    // a font draws Greek mu and the micro sign with one glyph and its ToUnicode says micro: beside a Greek letter
    // it is mu (Programma read with U+00B5)
    for (final.items) |*b| {
        b.text = try greekMu(a, b.text);
        for (b.rows) |row| for (row) |*c| {
            c.* = try greekMu(a, c.*);
        };
    }
    res.blocks = final.items;

    var all: std.ArrayList(u8) = .empty;
    for (final.items) |b| {
        if (b.kind == .page_header or b.kind == .page_footer) continue;
        if (all.items.len > 0) try all.appendSlice(a, "\n\n");
        try all.appendSlice(a, b.text);
    }
    res.text = all.items;
    return res;
}

pub fn readFile(gpa: Allocator, path: []const u8) !Result {
    const bytes = try std.fs.cwd().readFileAlloc(gpa, path, 1 << 30);
    defer gpa.free(bytes);
    // every slice a Result holds lives in its arena, never in `bytes`
    return read(gpa, bytes);
}

pub fn kindName(k: Kind) []const u8 {
    return switch (k) {
        .paragraph => "paragraph",
        .heading => "heading",
        .list_item => "list_item",
        .code => "code",
        .table => "table",
        .caption => "caption",
        .page_header => "page_header",
        .page_footer => "page_footer",
    };
}

test "numbers and refs" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    var p = Parser{ .s = "[1 0 R -.5 3. /A#20B (a\\(b\\)) <48 69>]", .i = 0, .a = arena.allocator(), .doc = null };
    const o = try p.parse();
    try std.testing.expect(o == .arr);
    try std.testing.expectEqual(@as(usize, 6), o.arr.len);
    try std.testing.expect(o.arr[0] == .ref);
    try std.testing.expectEqual(@as(f64, -0.5), o.arr[1].num);
    try std.testing.expectEqualStrings("A B", o.arr[3].name);
    try std.testing.expectEqualStrings("a(b)", o.arr[4].str);
    try std.testing.expectEqualStrings("Hi", o.arr[5].str);
}

test "page numbers" {
    try std.testing.expect(isPageNumber("Page 2 of 3"));
    try std.testing.expect(isPageNumber("7"));
    try std.testing.expect(!isPageNumber("Page two"));
}
