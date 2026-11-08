//! Testoor core -- DOMAINS, step V2 of the evidence ladder (TESTOOR_PROTOCOL_3.md section 4).
//!
//! A domain is the set of inputs a property is checked over, written as a text: dimensions separated by `;`, each
//! `NAME KIND ...` -- `n int 0..100`, `rate dec 0..0.25 step 0.01`, `algo one quick|merge|heap`, `s text 0..12 of mixed`,
//! and `xs list 0..10 of int -5..5`: a list of any of these kinds, a list of lists included.
//! The core answers three questions about it, the same in every language:
//!
//!   inputs   every value in order when there are no more than the tries, else the origin and seeded draws
//!   shrink   the candidates simpler than a failing input, simplest first
//!   size     the number of values, or none when it passes 2^53
//!
//! A `dec` is held as an integer count of its step's smallest unit, so 0.07 is 7 hundredths and never a float.

const std = @import("std");
const T = @import("testoor_text.zig");
const J = @import("testoor_json.zig");

const Allocator = std.mem.Allocator;
const Buf = T.Buf;

pub const Error = error{ BadDomain, OutOfMemory };

pub const Kind = enum { int, dec, one, text, list };

pub const Dim = struct {
    name: []const u8,
    kind: Kind,
    /// int: the bounds; dec: the bounds in the step's smallest unit; text: the lengths
    lo: i64 = 0,
    hi: i64 = 0,
    /// dec: the step in that unit, and the decimals a value is written with
    step: i64 = 1,
    scale: u8 = 0,
    options: []const []const u8 = &.{},
    alphabet: []const u21 = &.{},
    /// list: the kind of its elements; lo and hi are then the lengths
    elem: ?*const Dim = null,
};

pub const Domain = struct { dims: []const Dim };

/// one value of one dimension: a number for int, a position for dec and one, letters for text
pub const Val = union(enum) {
    int: i64,
    pos: i64,
    text: []const u21,
    list: []const Val,
};

pub const Input = []const Val;

pub const max_exact: u64 = 1 << 53;

// ── alphabets ────────────────────────────────────────────────

fn range(list: *std.ArrayList(u21), a: Allocator, from: u21, to: u21, skip: ?u21) !void {
    var c = from;
    while (c <= to) : (c += 1) {
        if (skip) |s| if (c == s) continue;
        try list.append(a, c);
    }
}

fn ascii(list: *std.ArrayList(u21), a: Allocator) !void {
    try range(list, a, 'a', 'z', null);
    try range(list, a, 'A', 'Z', null);
    try range(list, a, '0', '9', null);
    try list.append(a, ' ');
    var c: u21 = 33;
    while (c <= 126) : (c += 1) {
        const alnum = (c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z') or (c >= '0' and c <= '9');
        if (!alnum) try list.append(a, c);
    }
}

/// the named alphabets, each an ordered list: the first letter is the simplest
pub fn alphabet(a: Allocator, name: []const u8) Error![]const u21 {
    var l: std.ArrayList(u21) = .empty;
    const eq = std.mem.eql;
    const all = eq(u8, name, "mixed");
    var known = all;
    if (all or eq(u8, name, "ascii")) {
        try ascii(&l, a);
        known = true;
    }
    if (all or eq(u8, name, "latin")) {
        try range(&l, a, 0xE0, 0xFF, 0xF7);
        known = true;
    }
    if (all or eq(u8, name, "greek")) {
        try range(&l, a, 0x3B1, 0x3C9, null);
        known = true;
    }
    if (all or eq(u8, name, "hebrew")) {
        try range(&l, a, 0x5D0, 0x5EA, null);
        known = true;
    }
    if (all or eq(u8, name, "arabic")) {
        try range(&l, a, 0x621, 0x64A, null);
        known = true;
    }
    if (all or eq(u8, name, "cjk")) {
        try range(&l, a, 0x4E00, 0x4E9F, null);
        known = true;
    }
    if (all or eq(u8, name, "emoji")) {
        try range(&l, a, 0x1F600, 0x1F64F, null);
        known = true;
    }
    if (!known) return Error.BadDomain;
    return l.items;
}

// ── reading a domain ─────────────────────────────────────────

fn isName(s: []const u8) bool {
    if (s.len == 0) return false;
    if (s[0] >= '0' and s[0] <= '9') return false;
    for (s) |ch| {
        const ok = (ch >= 'a' and ch <= 'z') or (ch >= 'A' and ch <= 'Z') or (ch >= '0' and ch <= '9') or ch == '_';
        if (!ok) return false;
    }
    return true;
}

fn parseInt(s: []const u8) Error!i64 {
    return std.fmt.parseInt(i64, s, 10) catch Error.BadDomain;
}

const Dec = struct { units: i64, decimals: u8 };

fn parseDec(s: []const u8) Error!Dec {
    if (s.len == 0) return Error.BadDomain;
    var neg = false;
    var i: usize = 0;
    if (s[0] == '-') {
        neg = true;
        i = 1;
    }
    var units: i64 = 0;
    var decimals: u8 = 0;
    var seen_point = false;
    var digits: usize = 0;
    while (i < s.len) : (i += 1) {
        const ch = s[i];
        if (ch == '.') {
            if (seen_point) return Error.BadDomain;
            seen_point = true;
            continue;
        }
        if (ch < '0' or ch > '9') return Error.BadDomain;
        units = std.math.mul(i64, units, 10) catch return Error.BadDomain;
        units += ch - '0';
        digits += 1;
        if (seen_point) {
            decimals += 1;
            if (decimals > 9) return Error.BadDomain;
        }
    }
    if (digits == 0) return Error.BadDomain;
    return .{ .units = if (neg) -units else units, .decimals = decimals };
}

fn pow10(n: u8) i64 {
    var x: i64 = 1;
    var k: u8 = 0;
    while (k < n) : (k += 1) x *= 10;
    return x;
}

fn rescale(d: Dec, scale: u8) Error!i64 {
    return std.math.mul(i64, d.units, pow10(scale - d.decimals)) catch Error.BadDomain;
}

/// "A..B" into its two ends
fn bounds(s: []const u8) Error!struct { []const u8, []const u8 } {
    const at = std.mem.indexOf(u8, s, "..") orelse return Error.BadDomain;
    return .{ T.trimSp(s[0..at]), T.trimSp(s[at + 2 ..]) };
}

fn decodeUtf8(a: Allocator, s: []const u8) Error![]u21 {
    var out: std.ArrayList(u21) = .empty;
    const view = std.unicode.Utf8View.init(s) catch return Error.BadDomain;
    var it = view.iterator();
    while (it.nextCodepoint()) |cp| try out.append(a, cp);
    return out.items;
}

fn parseDim(a: Allocator, seg: []const u8) Error!Dim {
    var it = std.mem.tokenizeScalar(u8, seg, ' ');
    const name = it.next() orelse return Error.BadDomain;
    if (!isName(name)) return Error.BadDomain;
    const kind_s = it.next() orelse return Error.BadDomain;
    return parseKind(a, name, kind_s, T.trimSp(it.rest()));
}

/// a kind and what follows it: `int 0..9`, `text 0..4 of ascii`, `list 0..3 of int 0..9` (the element read the same way)
fn parseKind(a: Allocator, name: []const u8, kind_s: []const u8, rest: []const u8) Error!Dim {
    const eq = std.mem.eql;
    if (eq(u8, kind_s, "list")) {
        const at = std.mem.indexOf(u8, rest, " of ") orelse return Error.BadDomain;
        const ab = try bounds(rest[0..at]);
        const lo = try parseInt(ab[0]);
        const hi = try parseInt(ab[1]);
        if (lo < 0 or lo > hi or hi > 10000) return Error.BadDomain;
        const spec = T.trimSp(rest[at + 4 ..]);
        var it = std.mem.tokenizeScalar(u8, spec, ' ');
        const ek = it.next() orelse return Error.BadDomain;
        const e = try a.create(Dim);
        e.* = try parseKind(a, "", ek, T.trimSp(it.rest()));
        return .{ .name = name, .kind = .list, .lo = lo, .hi = hi, .elem = e };
    }
    if (eq(u8, kind_s, "int")) {
        const ab = try bounds(rest);
        const lo = try parseInt(ab[0]);
        const hi = try parseInt(ab[1]);
        if (lo > hi) return Error.BadDomain;
        return .{ .name = name, .kind = .int, .lo = lo, .hi = hi };
    }
    if (eq(u8, kind_s, "dec")) {
        const at = std.mem.indexOf(u8, rest, " step ") orelse return Error.BadDomain;
        const ab = try bounds(rest[0..at]);
        const da = try parseDec(ab[0]);
        const db = try parseDec(ab[1]);
        const ds = try parseDec(T.trimSp(rest[at + 6 ..]));
        const scale = @max(da.decimals, @max(db.decimals, ds.decimals));
        const lo = try rescale(da, scale);
        const hi = try rescale(db, scale);
        const step = try rescale(ds, scale);
        if (lo > hi or step <= 0) return Error.BadDomain;
        // the grid stops at the last value not above B
        const last = lo + @divFloor(hi - lo, step) * step;
        return .{ .name = name, .kind = .dec, .lo = lo, .hi = last, .step = step, .scale = scale };
    }
    if (eq(u8, kind_s, "one")) {
        var opts: std.ArrayList([]const u8) = .empty;
        var os = std.mem.splitScalar(u8, rest, '|');
        while (os.next()) |o| {
            const t = T.trimSp(o);
            if (t.len == 0) return Error.BadDomain;
            for (opts.items) |seen| if (eq(u8, seen, t)) return Error.BadDomain;
            try opts.append(a, t);
        }
        if (opts.items.len == 0) return Error.BadDomain;
        return .{ .name = name, .kind = .one, .lo = 0, .hi = @intCast(opts.items.len - 1), .options = opts.items };
    }
    if (eq(u8, kind_s, "text")) {
        const at = std.mem.indexOf(u8, rest, " of ") orelse return Error.BadDomain;
        const ab = try bounds(rest[0..at]);
        const lo = try parseInt(ab[0]);
        const hi = try parseInt(ab[1]);
        if (lo < 0 or lo > hi or hi > 10000) return Error.BadDomain;
        const al_s = T.trimSp(rest[at + 4 ..]);
        var al: []const u21 = undefined;
        if (al_s.len >= 2 and al_s[0] == '"' and al_s[al_s.len - 1] == '"') {
            al = try decodeUtf8(a, al_s[1 .. al_s.len - 1]);
            if (al.len == 0) return Error.BadDomain;
            for (al, 0..) |x, i| for (al[0..i]) |y| if (x == y) return Error.BadDomain;
        } else {
            al = try alphabet(a, al_s);
        }
        return .{ .name = name, .kind = .text, .lo = lo, .hi = hi, .alphabet = al };
    }
    return Error.BadDomain;
}

pub fn parse(a: Allocator, text: []const u8) Error!Domain {
    var dims: std.ArrayList(Dim) = .empty;
    var segs = std.mem.splitScalar(u8, text, ';');
    while (segs.next()) |s| {
        const seg = T.trimSp(s);
        if (seg.len == 0) continue;
        const d = try parseDim(a, seg);
        for (dims.items) |e| if (std.ascii.eqlIgnoreCase(e.name, d.name)) return Error.BadDomain;
        try dims.append(a, d);
    }
    if (dims.items.len == 0) return Error.BadDomain;
    return .{ .dims = dims.items };
}

// ── sizes ────────────────────────────────────────────────────

fn satMul(x: u64, y: u64) u64 {
    const r = std.math.mul(u64, x, y) catch return max_exact + 1;
    return if (r > max_exact) max_exact + 1 else r;
}

/// the number of values of one dimension, above 2^53 meaning unbounded
pub fn dimSize(d: Dim) u64 {
    return switch (d.kind) {
        .int => @as(u64, @intCast(@as(i128, d.hi) - @as(i128, d.lo))) +| 1,
        .dec => @as(u64, @intCast(@divExact(d.hi - d.lo, d.step))) + 1,
        .one => d.options.len,
        .text, .list => blk: {
            const k: u64 = if (d.kind == .text) d.alphabet.len else dimSize(d.elem.?.*);
            var total: u64 = 0;
            var pw: u64 = 1;
            var len: i64 = 0;
            while (len <= d.hi) : (len += 1) {
                if (len >= d.lo) total +|= pw;
                if (total > max_exact) break :blk max_exact + 1;
                pw = satMul(pw, k);
            }
            break :blk total;
        },
    };
}

/// the domain's size, or null when it passes 2^53
pub fn size(d: Domain) ?u64 {
    var s: u64 = 1;
    for (d.dims) |dim| {
        s = satMul(s, dimSize(dim));
        if (s > max_exact) return null;
    }
    return s;
}

// ── origins ──────────────────────────────────────────────────

fn nearZero(lo: i64, hi: i64) i64 {
    if (lo >= 0) return lo;
    if (hi <= 0) return hi;
    return 0;
}

/// the simplest value of a dimension
pub fn origin(a: Allocator, d: Dim) Error!Val {
    return switch (d.kind) {
        .int => .{ .int = nearZero(d.lo, d.hi) },
        .dec => blk: {
            // the grid position nearest 0; a tie goes to the lower
            if (d.lo >= 0) break :blk .{ .pos = 0 };
            const n = @divExact(d.hi - d.lo, d.step);
            if (d.hi <= 0) break :blk .{ .pos = n };
            const k0 = @divFloor(-d.lo, d.step);
            const v0 = d.lo + k0 * d.step;
            const v1 = v0 + d.step;
            break :blk .{ .pos = if (k0 + 1 <= n and v1 < -v0) k0 + 1 else k0 };
        },
        .one => .{ .pos = 0 },
        .text => blk: {
            const l = try a.alloc(u21, @intCast(d.lo));
            @memset(l, d.alphabet[0]);
            break :blk .{ .text = l };
        },
        .list => blk: {
            const l = try a.alloc(Val, @intCast(d.lo));
            for (l) |*x| x.* = try origin(a, d.elem.?.*);
            break :blk .{ .list = l };
        },
    };
}

// ── every value, in order ────────────────────────────────────

/// the i-th value of a dimension in its order (i below dimSize)
fn nth(a: Allocator, d: Dim, idx: u64) Error!Val {
    switch (d.kind) {
        .list => {
            const e = d.elem.?.*;
            const k = dimSize(e);
            var rest = idx;
            var len: i64 = d.lo;
            while (true) : (len += 1) {
                var count: u64 = 1;
                var j: i64 = 0;
                while (j < len) : (j += 1) count = satMul(count, k);
                if (rest < count) break;
                rest -= count;
            }
            const l = try a.alloc(Val, @intCast(len));
            var p: usize = l.len;
            while (p > 0) {
                p -= 1;
                l[p] = try nth(a, e, rest % k);
                rest /= k;
            }
            return .{ .list = l };
        },
        .int => return .{ .int = d.lo + @as(i64, @intCast(idx)) },
        .dec, .one => return .{ .pos = @intCast(idx) },
        .text => {
            const k: u64 = d.alphabet.len;
            var rest = idx;
            var len: i64 = d.lo;
            while (true) : (len += 1) {
                var count: u64 = 1;
                var j: i64 = 0;
                while (j < len) : (j += 1) count = satMul(count, k);
                if (rest < count) break;
                rest -= count;
            }
            const l = try a.alloc(u21, @intCast(len));
            var p: usize = l.len;
            while (p > 0) {
                p -= 1;
                l[p] = d.alphabet[@intCast(rest % k)];
                rest /= k;
            }
            return .{ .text = l };
        },
    }
}

/// every input of a domain whose size is at most `cap`, the last dimension changing fastest
pub fn enumerate(a: Allocator, d: Domain, cap: u64) Error![]Input {
    const total = size(d) orelse return Error.BadDomain;
    if (total > cap) return Error.BadDomain;
    var out = try a.alloc(Input, @intCast(total));
    var i: u64 = 0;
    while (i < total) : (i += 1) {
        const in = try a.alloc(Val, d.dims.len);
        var rest = i;
        var k: usize = d.dims.len;
        while (k > 0) {
            k -= 1;
            const s = dimSize(d.dims[k]);
            in[k] = try nth(a, d.dims[k], rest % s);
            rest /= s;
        }
        out[@intCast(i)] = in;
    }
    return out;
}

// ── draws ────────────────────────────────────────────────────

/// splitmix64 over the seed's bits and a stream number, then stepped: a draw is a function of the seed, the draw's
/// number and the dimension's, and of nothing else, on any machine
const Rng = struct {
    x: u64,
    fn init(seed: f64, stream: u64) Rng {
        var x: u64 = @bitCast(seed);
        x +%= (stream +% 1) *% 0x9E3779B97F4A7C15;
        return .{ .x = x };
    }
    fn next(self: *Rng) u64 {
        self.x +%= 0x9E3779B97F4A7C15;
        var z = self.x;
        z = (z ^ (z >> 30)) *% 0xBF58476D1CE4E5B9;
        z = (z ^ (z >> 27)) *% 0x94D049BB133111EB;
        return z ^ (z >> 31);
    }
    fn below(self: *Rng, n: u64) u64 {
        return if (n == 0) 0 else self.next() % n;
    }
};

fn draw(a: Allocator, d: Dim, rng: *Rng) Error!Val {
    switch (d.kind) {
        .int => {
            const span: u64 = @intCast(@as(i128, d.hi) - @as(i128, d.lo));
            const off = if (span == std.math.maxInt(u64)) rng.next() else rng.below(span + 1);
            return .{ .int = @intCast(@as(i128, d.lo) + off) };
        },
        .dec, .one => return .{ .pos = @intCast(rng.below(dimSize(d))) },
        .text => {
            const len: usize = @intCast(@as(u64, @intCast(d.lo)) + rng.below(@as(u64, @intCast(d.hi - d.lo)) + 1));
            const l = try a.alloc(u21, len);
            for (l) |*c| c.* = d.alphabet[@intCast(rng.below(d.alphabet.len))];
            return .{ .text = l };
        },
        .list => {
            const len: usize = @intCast(@as(u64, @intCast(d.lo)) + rng.below(@as(u64, @intCast(d.hi - d.lo)) + 1));
            const l = try a.alloc(Val, len);
            for (l) |*x| x.* = try draw(a, d.elem.?.*, rng);
            return .{ .list = l };
        },
    }
}

pub const Inputs = struct { inputs: []Input, exhaustive: bool, of: ?u64 };

/// what a property is checked on: every value when there are no more than `tries`, else the origin and `tries - 1` draws
pub fn inputs(a: Allocator, d: Domain, seed: f64, tries: u64) Error!Inputs {
    if (tries == 0) return Error.BadDomain;
    const total = size(d);
    if (total) |t| if (t <= tries) return .{ .inputs = try enumerate(a, d, t), .exhaustive = true, .of = t };
    var out = try a.alloc(Input, @intCast(tries));
    const first = try a.alloc(Val, d.dims.len);
    for (d.dims, 0..) |dim, k| first[k] = try origin(a, dim);
    out[0] = first;
    var j: u64 = 1;
    while (j < tries) : (j += 1) {
        const in = try a.alloc(Val, d.dims.len);
        for (d.dims, 0..) |dim, k| {
            var rng = Rng.init(seed, j * 1024 + k);
            in[k] = try draw(a, dim, &rng);
        }
        out[@intCast(j)] = in;
    }
    return .{ .inputs = out, .exhaustive = false, .of = total };
}

// ── shrinking ────────────────────────────────────────────────

/// toward `o` from `v`, halving the distance: v - d, v - d/2, v - d/4 ... v - 1 (each once, never v)
fn halving(a: Allocator, v: i64, o: i64) Error![]i64 {
    var out: std.ArrayList(i64) = .empty;
    var i: i64 = v - o;
    while (i != 0) : (i = @divTrunc(i, 2)) {
        const c = v - i;
        var dup = false;
        for (out.items) |x| if (x == c) {
            dup = true;
        };
        if (!dup) try out.append(a, c);
    }
    return out.items;
}

fn indexIn(al: []const u21, c: u21) ?usize {
    for (al, 0..) |x, i| if (x == c) return i;
    return null;
}

fn sameText(x: []const u21, y: []const u21) bool {
    return std.mem.eql(u21, x, y);
}

fn textCandidates(a: Allocator, d: Dim, cur: []const u21) Error![]const []const u21 {
    var out: std.ArrayList([]const u21) = .empty;
    const n: i64 = @intCast(cur.len);
    const add = struct {
        fn f(al: Allocator, list: *std.ArrayList([]const u21), c: []const u21, input: []const u21) Error!void {
            if (sameText(c, input)) return;
            for (list.items) |x| if (sameText(x, c)) return;
            try list.append(al, c);
        }
    }.f;
    if (d.lo < n) try add(a, &out, cur[0..@intCast(d.lo)], cur);
    const mid = d.lo + @divTrunc(n - d.lo, 2);
    if (mid > d.lo and mid < n) try add(a, &out, cur[0..@intCast(mid)], cur);
    if (n - 1 >= d.lo) {
        var i: usize = 0;
        while (i < cur.len) : (i += 1) {
            const c = try a.alloc(u21, cur.len - 1);
            @memcpy(c[0..i], cur[0..i]);
            @memcpy(c[i..], cur[i + 1 ..]);
            try add(a, &out, c, cur);
        }
    }
    for (cur, 0..) |ch, i| {
        const idx = indexIn(d.alphabet, ch) orelse continue;
        for (try halving(a, @intCast(idx), 0)) |ni| {
            const c = try a.dupe(u21, cur);
            c[i] = d.alphabet[@intCast(ni)];
            try add(a, &out, c, cur);
        }
    }
    return out.items;
}

fn valEq(x: Val, y: Val) bool {
    return switch (x) {
        .int => |i| y == .int and y.int == i,
        .pos => |p| y == .pos and y.pos == p,
        .text => |t| y == .text and sameText(t, y.text),
        .list => |l| blk: {
            if (y != .list or y.list.len != l.len) break :blk false;
            for (l, 0..) |v, i| if (!valEq(v, y.list[i])) break :blk false;
            break :blk true;
        },
    };
}

/// a list shrinks as a text does: shorter first (its first `lo` elements, its first half, each element left out), then
/// each element, in place, by its own kind's candidates
fn listCandidates(a: Allocator, d: Dim, cur: []const Val) Error![]const []const Val {
    var out: std.ArrayList([]const Val) = .empty;
    const add = struct {
        fn f(al: Allocator, list: *std.ArrayList([]const Val), c: []const Val, input: []const Val) Error!void {
            if (valEq(.{ .list = c }, .{ .list = input })) return;
            for (list.items) |x| if (valEq(.{ .list = x }, .{ .list = c })) return;
            try list.append(al, c);
        }
    }.f;
    const n: i64 = @intCast(cur.len);
    if (d.lo < n) try add(a, &out, cur[0..@intCast(d.lo)], cur);
    const mid = d.lo + @divTrunc(n - d.lo, 2);
    if (mid > d.lo and mid < n) try add(a, &out, cur[0..@intCast(mid)], cur);
    if (n - 1 >= d.lo) {
        var i: usize = 0;
        while (i < cur.len) : (i += 1) {
            const c = try a.alloc(Val, cur.len - 1);
            @memcpy(c[0..i], cur[0..i]);
            @memcpy(c[i..], cur[i + 1 ..]);
            try add(a, &out, c, cur);
        }
    }
    for (cur, 0..) |v, i| {
        for (try valCandidates(a, d.elem.?.*, v)) |nv| {
            const c = try a.dupe(Val, cur);
            c[i] = nv;
            try add(a, &out, c, cur);
        }
    }
    return out.items;
}

/// the values simpler than `v` in one dimension, simplest first
pub fn valCandidates(a: Allocator, dim: Dim, v: Val) Error![]Val {
    var vals: std.ArrayList(Val) = .empty;
    switch (dim.kind) {
        .int => for (try halving(a, v.int, (try origin(a, dim)).int)) |x| try vals.append(a, .{ .int = x }),
        .dec => for (try halving(a, v.pos, (try origin(a, dim)).pos)) |p| try vals.append(a, .{ .pos = p }),
        .one => {
            var p: i64 = 0;
            while (p < v.pos) : (p += 1) try vals.append(a, .{ .pos = p });
        },
        .text => for (try textCandidates(a, dim, v.text)) |t| try vals.append(a, .{ .text = t }),
        .list => for (try listCandidates(a, dim, v.list)) |l| try vals.append(a, .{ .list = l }),
    }
    return vals.items;
}

/// the candidates simpler than a failing input, simplest first: each dimension in the order written, the others held
pub fn shrink(a: Allocator, d: Domain, in: Input) Error![]Input {
    var out: std.ArrayList(Input) = .empty;
    for (d.dims, 0..) |dim, k| {
        const vals = try valCandidates(a, dim, in[k]);
        for (vals) |v| {
            const c = try a.dupe(Val, in);
            c[k] = v;
            try out.append(a, c);
        }
    }
    return out.items;
}

// ── inputs as JSON, both ways ────────────────────────────────

fn writeDec(b: *Buf, d: Dim, pos: i64) !void {
    const units = d.lo + pos * d.step;
    if (d.scale == 0) return b.int(units);
    const p: u64 = @intCast(pow10(d.scale));
    const mag: u64 = @abs(units);
    if (units < 0) try b.c('-');
    try b.int(@intCast(mag / p));
    try b.c('.');
    // the decimals, zeros on the left included: 7 hundredths is ".07"
    var digits: [9]u8 = undefined;
    var frac = mag % p;
    var k: usize = d.scale;
    while (k > 0) {
        k -= 1;
        digits[k] = '0' + @as(u8, @intCast(frac % 10));
        frac /= 10;
    }
    try b.s(digits[0..d.scale]);
}

fn writeText(b: *Buf, l: []const u21) !void {
    var bytes: std.ArrayList(u8) = .empty;
    for (l) |cp| {
        var tmp: [4]u8 = undefined;
        const n = std.unicode.utf8Encode(cp, &tmp) catch continue;
        try bytes.appendSlice(b.a, tmp[0..n]);
    }
    try b.js(bytes.items);
}

fn writeVal(b: *Buf, dim: Dim, v: Val) error{OutOfMemory}!void {
    switch (dim.kind) {
        .int => try b.int(v.int),
        .dec => {
            try b.c('"');
            try writeDec(b, dim, v.pos);
            try b.c('"');
        },
        .one => try b.js(dim.options[@intCast(v.pos)]),
        .text => try writeText(b, v.text),
        .list => {
            try b.c('[');
            for (v.list, 0..) |x, i| {
                if (i > 0) try b.c(',');
                try writeVal(b, dim.elem.?.*, x);
            }
            try b.c(']');
        },
    }
}

/// an input as the JSON object a tour receives: one key per dimension, an int a number, a list an array, every other
/// value text
pub fn writeInput(b: *Buf, d: Domain, in: Input) !void {
    try b.c('{');
    for (d.dims, 0..) |dim, k| {
        if (k > 0) try b.c(',');
        try b.js(dim.name);
        try b.c(':');
        try writeVal(b, dim, in[k]);
    }
    try b.c('}');
}

fn field(v: J.Value, name: []const u8) ?J.Value {
    switch (v) {
        .obj => |pairs| {
            for (pairs) |p| if (std.ascii.eqlIgnoreCase(p.key, name)) return p.val;
            return null;
        },
        else => return null,
    }
}

/// an input a tour sends back, read against its domain; keys are compared without ASCII case (Ring's hash lists fold it)
pub fn readInput(a: Allocator, d: Domain, v: J.Value) Error!Input {
    const in = try a.alloc(Val, d.dims.len);
    for (d.dims, 0..) |dim, k| {
        const x = field(v, dim.name) orelse return Error.BadDomain;
        in[k] = try readVal(a, dim, x);
    }
    return in;
}

/// one value of one dimension, read from the JSON a tour sent back; anything outside the dimension is refused
fn readVal(a: Allocator, dim: Dim, x: J.Value) Error!Val {
    switch (dim.kind) {
        .list => {
            const items = switch (x) {
                .arr => |xs| xs,
                else => return Error.BadDomain,
            };
            if (items.len < dim.lo or items.len > dim.hi) return Error.BadDomain;
            const l = try a.alloc(Val, items.len);
            for (items, 0..) |it, i| l[i] = try readVal(a, dim.elem.?.*, it);
            return .{ .list = l };
        },
        .int => {
            const n: f64 = switch (x) {
                .num => |f| f,
                .str => |s| T.parseNumber(s) orelse return Error.BadDomain,
                else => return Error.BadDomain,
            };
            if (n != @floor(n) or @abs(n) > 9.0e18) return Error.BadDomain;
            const i: i64 = @intFromFloat(n);
            if (i < dim.lo or i > dim.hi) return Error.BadDomain;
            return .{ .int = i };
        },
        .dec => {
            var tmp: [64]u8 = undefined;
            const s = switch (x) {
                .str => |s| s,
                .num => |f| std.fmt.bufPrint(&tmp, "{d}", .{f}) catch return Error.BadDomain,
                else => return Error.BadDomain,
            };
            const dv = try parseDec(s);
            if (dv.decimals > dim.scale) return Error.BadDomain;
            const units = try rescale(dv, dim.scale);
            if (units < dim.lo or units > dim.hi or @mod(units - dim.lo, dim.step) != 0) return Error.BadDomain;
            return .{ .pos = @divExact(units - dim.lo, dim.step) };
        },
        .one => {
            const s = x.str_();
            for (dim.options, 0..) |o, i| if (std.mem.eql(u8, o, s)) return .{ .pos = @intCast(i) };
            return Error.BadDomain;
        },
        .text => {
            const l = try decodeUtf8(a, x.str_());
            if (l.len < dim.lo or l.len > dim.hi) return Error.BadDomain;
            return .{ .text = l };
        },
    }
}

// ── tests ────────────────────────────────────────────────────

const testing = std.testing;

fn inputText(a: Allocator, d: Domain, in: Input) ![]const u8 {
    var b = Buf.init(a);
    try writeInput(&b, d, in);
    return b.done();
}

test "a dec domain is exact, and every value is tried when there are few enough" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const d = try parse(a, "rate dec 0..0.25 step 0.01");
    try testing.expectEqual(@as(?u64, 26), size(d));
    const r = try inputs(a, d, 42, 100);
    try testing.expect(r.exhaustive);
    try testing.expectEqual(@as(usize, 26), r.inputs.len);
    try testing.expectEqualStrings("{\"rate\":\"0.00\"}", try inputText(a, d, r.inputs[0]));
    try testing.expectEqualStrings("{\"rate\":\"0.07\"}", try inputText(a, d, r.inputs[7]));
    try testing.expectEqualStrings("{\"rate\":\"0.25\"}", try inputText(a, d, r.inputs[25]));
    // a value off the grid, or past the end, is not an input of this domain
    try testing.expectError(Error.BadDomain, readInput(a, d, try J.parse(a, "{\"rate\":\"0.005\"}")));
    try testing.expectError(Error.BadDomain, readInput(a, d, try J.parse(a, "{\"rate\":\"0.26\"}")));
}

test "two dimensions are tried with the last one changing fastest" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const d = try parse(a, "a int 0..2; b one x|y");
    const r = try inputs(a, d, 1, 6);
    try testing.expect(r.exhaustive);
    try testing.expectEqualStrings("{\"a\":0,\"b\":\"x\"}", try inputText(a, d, r.inputs[0]));
    try testing.expectEqualStrings("{\"a\":0,\"b\":\"y\"}", try inputText(a, d, r.inputs[1]));
    try testing.expectEqualStrings("{\"a\":2,\"b\":\"y\"}", try inputText(a, d, r.inputs[5]));
}

test "draws start at the origin, stay in the domain and replay from the seed" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const d = try parse(a, "n int -50..1000; s text 0..12 of mixed");
    try testing.expectEqual(@as(?u64, null), size(d)); // unbounded
    const r1 = try inputs(a, d, 42, 200);
    const r2 = try inputs(a, d, 42, 200);
    const r3 = try inputs(a, d, 43, 200);
    try testing.expect(!r1.exhaustive);
    try testing.expectEqual(@as(?u64, null), r1.of);
    try testing.expectEqualStrings("{\"n\":0,\"s\":\"\"}", try inputText(a, d, r1.inputs[0]));
    var differ = false;
    for (r1.inputs, 0..) |in, i| {
        try testing.expect(in[0].int >= -50 and in[0].int <= 1000);
        try testing.expect(in[1].text.len <= 12);
        try testing.expectEqualStrings(try inputText(a, d, in), try inputText(a, d, r2.inputs[i]));
        if (!std.mem.eql(u8, try inputText(a, d, in), try inputText(a, d, r3.inputs[i]))) differ = true;
    }
    try testing.expect(differ);
}

test "an int shrinks toward the value nearest zero by halving the distance" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const want = [_]i64{ 0, 50, 75, 88, 94, 97, 99 };
    const d = try parse(a, "n int 0..100");
    const c = try shrink(a, d, try readInput(a, d, try J.parse(a, "{\"n\":100}")));
    try testing.expectEqual(want.len, c.len);
    for (want, 0..) |w, i| try testing.expectEqual(w, c[i][0].int);
    const neg = try parse(a, "n int -5..5");
    const cn = try shrink(a, neg, try readInput(a, neg, try J.parse(a, "{\"n\":-4}")));
    try testing.expectEqual(@as(usize, 3), cn.len);
    try testing.expectEqual(@as(i64, 0), cn[0][0].int);
    try testing.expectEqual(@as(i64, -2), cn[1][0].int);
    try testing.expectEqual(@as(i64, -3), cn[2][0].int);
    const off = try parse(a, "n int 3..9");
    const co = try shrink(a, off, try readInput(a, off, try J.parse(a, "{\"n\":9}")));
    try testing.expectEqual(@as(usize, 3), co.len);
    try testing.expectEqual(@as(i64, 3), co[0][0].int);
    try testing.expectEqual(@as(i64, 6), co[1][0].int);
    try testing.expectEqual(@as(i64, 8), co[2][0].int);
}

test "a choice shrinks to the options before it; a text to shorter texts, then earlier letters" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const d = try parse(a, "algo one quick|merge|heap");
    const c = try shrink(a, d, try readInput(a, d, try J.parse(a, "{\"ALGO\":\"heap\"}")));
    try testing.expectEqual(@as(usize, 2), c.len);
    try testing.expectEqualStrings("{\"algo\":\"quick\"}", try inputText(a, d, c[0]));
    try testing.expectEqualStrings("{\"algo\":\"merge\"}", try inputText(a, d, c[1]));
    const t = try parse(a, "s text 0..5 of ascii");
    const ct = try shrink(a, t, try readInput(a, t, try J.parse(a, "{\"s\":\"ab\"}")));
    const want = [_][]const u8{ "{\"s\":\"\"}", "{\"s\":\"a\"}", "{\"s\":\"b\"}", "{\"s\":\"aa\"}" };
    try testing.expectEqual(want.len, ct.len);
    for (want, 0..) |w, i| try testing.expectEqualStrings(w, try inputText(a, t, ct[i]));
}

test "a list is tried by length, then element by element, the last fastest" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const d = try parse(a, "xs list 0..2 of int 0..1");
    try testing.expectEqual(@as(?u64, 7), size(d));
    const r = try inputs(a, d, 1, 10);
    try testing.expect(r.exhaustive);
    const want = [_][]const u8{ "{\"xs\":[]}", "{\"xs\":[0]}", "{\"xs\":[1]}", "{\"xs\":[0,0]}", "{\"xs\":[0,1]}", "{\"xs\":[1,0]}", "{\"xs\":[1,1]}" };
    try testing.expectEqual(want.len, r.inputs.len);
    for (want, 0..) |w, i| try testing.expectEqualStrings(w, try inputText(a, d, r.inputs[i]));
    // a list of lists: 1 + 3 + 9 values; a list of unbounded texts is unbounded
    try testing.expectEqual(@as(?u64, 13), size(try parse(a, "ls list 0..2 of list 0..1 of int 0..1")));
    try testing.expectEqual(@as(?u64, null), size(try parse(a, "ws list 0..3 of text 0..9 of mixed")));
    // a list's origin is its shortest length of its element's origin
    const o = try inputs(a, try parse(a, "ws list 1..3 of text 0..9 of mixed"), 5, 3);
    try testing.expectEqualStrings("{\"ws\":[\"\"]}", try inputText(a, try parse(a, "ws list 1..3 of text 0..9 of mixed"), o.inputs[0]));
}

test "a list shrinks shorter first, then each element by its own kind, nested lists included" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const d = try parse(a, "xs list 0..5 of int 0..9");
    const c = try shrink(a, d, try readInput(a, d, try J.parse(a, "{\"xs\":[3,1]}")));
    const want = [_][]const u8{ "{\"xs\":[]}", "{\"xs\":[3]}", "{\"xs\":[1]}", "{\"xs\":[0,1]}", "{\"xs\":[2,1]}", "{\"xs\":[3,0]}" };
    try testing.expectEqual(want.len, c.len);
    for (want, 0..) |w, i| try testing.expectEqualStrings(w, try inputText(a, d, c[i]));
    const n = try parse(a, "ls list 0..2 of list 0..1 of int 0..1");
    const cn = try shrink(a, n, try readInput(a, n, try J.parse(a, "{\"ls\":[[1]]}")));
    const wn = [_][]const u8{ "{\"ls\":[]}", "{\"ls\":[[]]}", "{\"ls\":[[0]]}" };
    try testing.expectEqual(wn.len, cn.len);
    for (wn, 0..) |w, i| try testing.expectEqualStrings(w, try inputText(a, n, cn[i]));
    // an element outside its kind, or a list of the wrong length, is not an input of the domain
    try testing.expectError(Error.BadDomain, readInput(a, d, try J.parse(a, "{\"xs\":[3,10]}")));
    try testing.expectError(Error.BadDomain, readInput(a, d, try J.parse(a, "{\"xs\":[1,1,1,1,1,1]}")));
    try testing.expectError(Error.BadDomain, readInput(a, d, try J.parse(a, "{\"xs\":3}")));
    try testing.expectError(Error.BadDomain, parse(a, "xs list 0..3 of"));
}

test "the mixed alphabet puts every ASCII letter before the first accented one" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const m = try alphabet(a, "mixed");
    try testing.expectEqual(@as(usize, 460), m.len);
    try testing.expectEqual(@as(u21, 'a'), m[0]);
    try testing.expectEqual(@as(u21, 0xE0), m[95]);
    try testing.expectError(Error.BadDomain, parse(a, "s text 0..3 of klingon"));
    try testing.expectError(Error.BadDomain, parse(a, "n int 5..1"));
    try testing.expectError(Error.BadDomain, parse(a, "n int 0..1; N one a|b"));
    try testing.expectError(Error.BadDomain, parse(a, "9n int 0..1"));
}
