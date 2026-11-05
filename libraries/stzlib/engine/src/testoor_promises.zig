//! Testoor core -- `#-->` promises. A port of the Ring reference (stzTraveller.ring, from
//! `_TravNorm` to `_TravPromiseAt`), which was itself a port of base/meta/promises.py. Every
//! rule below was learned by watching a harness accuse the library of things it had not done:
//!   - a SHORT promise must equal the whole line ("#--> 6" against a real 3 once passed
//!     because "6" sat inside a later "[ 6, 28 ]"); a promise of five bytes or more may be
//!     contained, since a `?` often prints a label with the value
//!   - whitespace is removed around [ ] and , and ONLY there (`@@()` prints "[ 6, 28 ]")
//!   - TRUE and FALSE print as 1 and 0; `:Symbol` prints bare; a note in parentheses or after
//!     a second # is not part of the value
//!   - "#--> ERROR: ..." means the line RAISES, and what is searched for is the message
//!   - a list printed without `@@()` arrives one bare item per line
//! Indices are 1-based as the reference's are; 0 means "not found".

const std = @import("std");
const Allocator = std.mem.Allocator;
const T = @import("testoor_text.zig");

/// whitespace runs collapsed to one space, the ends trimmed (tabs and CRs count as space)
pub fn norm(a: Allocator, s: []const u8) ![]const u8 {
    var c: []const u8 = try T.replaceAll(a, s, "\t", " ");
    c = try T.replaceAll(a, c, "\r", " ");
    while (T.find(c, "  ") > 0) c = try T.replaceAll(a, c, "  ", " ");
    return T.trimSp(c);
}

/// whitespace around [ ] , removed, and only there
pub fn canon(a: Allocator, s: []const u8) ![]const u8 {
    var c: []const u8 = try a.dupe(u8, s);
    const ps = [_][]const u8{ "[", "]", "," };
    for (ps) |p| {
        const before = try std.mem.concat(a, u8, &.{ " ", p });
        const after = try std.mem.concat(a, u8, &.{ p, " " });
        while (T.find(c, before) > 0) c = try T.replaceAll(a, c, before, p);
        while (T.find(c, after) > 0) c = try T.replaceAll(a, c, after, p);
    }
    return c;
}

pub fn stripQuotes(s: []const u8) []const u8 {
    const n = s.len;
    if (n >= 2) {
        if ((s[0] == '"' and s[n - 1] == '"') or (s[0] == '\'' and s[n - 1] == '\'')) {
            return T.sub(s, 2, @as(i64, @intCast(n)) - 2);
        }
    }
    return s;
}

fn isAlpha(ch: u8) bool {
    return (ch >= 65 and ch <= 90) or (ch >= 97 and ch <= 122);
}

fn isWordChar(ch: u8) bool {
    return isAlpha(ch) or (ch >= 48 and ch <= 57) or ch == '_';
}

/// "#--> ERROR: message", "ERRORS!" or "ERR:" -- THIS LINE RAISES
pub fn isErrorPromise(a: Allocator, raw: []const u8) !bool {
    const lt = try T.lowerAscii(a, T.trimSp(raw));
    var c: []const u8 = undefined;
    const n: i64 = @intCast(lt.len);
    if (T.startsWith(lt, "error")) {
        c = T.sub(lt, 6, n - 5);
    } else if (T.startsWith(lt, "err")) {
        c = T.sub(lt, 4, n - 3);
    } else return false;
    if (T.startsWith(c, "s")) c = T.sub(c, 2, @as(i64, @intCast(c.len)) - 1);
    c = T.trimSp(c);
    return T.startsWith(c, ":") or T.startsWith(c, "!");
}

/// the message after the first : or !, quotes off
pub fn errorMessage(a: Allocator, raw: []const u8) ![]const u8 {
    const c = T.trimSp(raw);
    var n = T.find(c, ":");
    const m = T.find(c, "!");
    if (n == 0 or (m > 0 and m < n)) n = m;
    if (n == 0) return "";
    const cl: i64 = @intCast(c.len);
    return stripQuotes(try norm(a, T.sub(c, @as(i64, @intCast(n)) + 1, cl - @as(i64, @intCast(n)))));
}

fn lastIndexOf(s: []const u8, needle: []const u8) usize {
    if (std.mem.lastIndexOf(u8, s, needle)) |i| return i + 1;
    return 0;
}

fn isSymbol(s: []const u8) bool {
    if (s.len < 2 or !T.startsWith(s, ":")) return false;
    if (!isAlpha(s[1])) return false;
    for (s[2..]) |ch| if (!isWordChar(ch)) return false;
    return true;
}

/// ":Name" inside a list, where the colon follows no word character, prints as "name"
fn lowerSymbols(a: Allocator, s: []const u8) ![]const u8 {
    var out: std.ArrayList(u8) = .empty;
    const n = s.len;
    var k: usize = 0;
    while (k < n) {
        const ch = s[k];
        if (ch == ':' and k + 1 < n and isAlpha(s[k + 1]) and (k == 0 or !isWordChar(s[k - 1]))) {
            var j = k + 1;
            while (j < n and isWordChar(s[j])) j += 1;
            const word = try T.lowerAscii(a, s[k + 1 .. j]);
            try out.appendSlice(a, word);
            k = j;
        } else {
            try out.append(a, ch);
            k += 1;
        }
    }
    return out.toOwnedSlice(a);
}

fn addVariant(a: Allocator, seen: *std.ArrayList([]const u8), v: []const u8) !void {
    const c = try norm(a, v);
    if (c.len == 0) return;
    for (seen.items) |x| if (std.mem.eql(u8, x, c)) return;
    try seen.append(a, c);
}

/// every spelling the promised value could legitimately print as
pub fn variants(a: Allocator, raw: []const u8) ![][]const u8 {
    var seen: std.ArrayList([]const u8) = .empty;
    try addVariant(a, &seen, raw);
    const c = try norm(a, raw);
    if (T.right(c, 1).len == 1 and T.right(c, 1)[0] == ')') {
        const open = lastIndexOf(c, " (");
        if (open > 0) try addVariant(a, &seen, T.sub(c, 1, @as(i64, @intCast(open)) - 1));
    }
    const h = T.find(c, " #");
    if (h > 0) try addVariant(a, &seen, T.sub(c, 1, @as(i64, @intCast(h)) - 1));
    const nb = seen.items.len;
    var k: usize = 0;
    while (k < nb) : (k += 1) {
        const cb = seen.items[k];
        const cq = stripQuotes(cb);
        if (!std.mem.eql(u8, cq, cb)) try addVariant(a, &seen, cq);
        const cu = try T.upperAscii(a, cb);
        if (std.mem.eql(u8, cu, "TRUE")) try addVariant(a, &seen, "1");
        if (std.mem.eql(u8, cu, "FALSE")) try addVariant(a, &seen, "0");
        if (isSymbol(cb)) {
            const rest = T.sub(cb, 2, @as(i64, @intCast(cb.len)) - 1);
            try addVariant(a, &seen, rest);
            try addVariant(a, &seen, try T.lowerAscii(a, rest));
        }
        if (T.startsWith(cb, "[") and T.find(cb, ":") > 0) {
            try addVariant(a, &seen, try lowerSymbols(a, cb));
        }
    }
    return seen.items;
}

/// the items of "[a, b, c]", quotes off; empty when it is not a list text
fn listItems(a: Allocator, inner: []const u8) ![][]const u8 {
    var out: std.ArrayList([]const u8) = .empty;
    if (!T.startsWith(inner, "[") or inner.len == 0 or inner[inner.len - 1] != ']') return out.items;
    const c = T.sub(inner, 2, @as(i64, @intCast(inner.len)) - 2);
    var cur: std.ArrayList(u8) = .empty;
    for (c) |ch| {
        if (ch == ',') {
            if (T.trimSp(cur.items).len != 0) try out.append(a, stripQuotes(T.trimSp(try a.dupe(u8, cur.items))));
            cur.clearRetainingCapacity();
        } else {
            try cur.append(a, ch);
        }
    }
    if (T.trimSp(cur.items).len != 0) try out.append(a, stripQuotes(T.trimSp(try a.dupe(u8, cur.items))));
    return out.items;
}

/// the output line (normalised, 1-based, from `from` on) where the promise is met, or 0
pub fn promiseAt(a: Allocator, raw: []const u8, norm_lines: []const []const u8, from: usize) Allocator.Error!usize {
    const nl = norm_lines.len;
    if (T.find(raw, "\n") > 0) return multiline(a, raw, norm_lines, from);
    if (try isErrorPromise(a, raw)) {
        const msg = try errorMessage(a, raw);
        if (msg.len == 0) return 0;
        var k = from;
        while (k >= 1 and k <= nl) : (k += 1) {
            if (T.find(norm_lines[k - 1], msg) > 0) return k;
        }
        return 0;
    }
    const cn = try norm(a, raw);
    if (std.mem.eql(u8, cn, "''") or std.mem.eql(u8, cn, "\"\"")) {
        var k = from;
        while (k >= 1 and k <= nl) : (k += 1) {
            if (norm_lines[k - 1].len == 0) return k;
        }
        return 0;
    }
    const acv = try variants(a, raw);
    for (acv) |cand| {
        const cc = try canon(a, cand);
        const loose = cc.len >= 5;
        var k = from;
        while (k >= 1 and k <= nl) : (k += 1) {
            const line = norm_lines[k - 1];
            const cl = try canon(a, line);
            if (std.mem.eql(u8, cc, cl) or std.mem.eql(u8, cand, line)) return k;
            if (loose and (T.find(line, cand) > 0 or T.find(cl, cc) > 0)) return k;
        }
    }
    // a list printed without @@() arrives one bare item per line
    if (T.startsWith(T.trimSp(raw), "[") and acv.len > 0) {
        const items = try listItems(a, try canon(a, acv[0]));
        const ni = items.len;
        if (ni > 0) {
            var k = from;
            while (k >= 1 and k <= nl) : (k += 1) {
                var seg: std.ArrayList([]const u8) = .empty;
                var j = k;
                while (j <= nl and seg.items.len < ni) {
                    if (norm_lines[j - 1].len != 0) try seg.append(a, stripQuotes(norm_lines[j - 1]));
                    j += 1;
                }
                if (seg.items.len < ni) break;
                var same = true;
                for (items, 0..) |it, m| {
                    if (!std.mem.eql(u8, seg.items[m], it)) {
                        same = false;
                        break;
                    }
                }
                if (same) return j - 1;
            }
        }
    }
    return 0;
}

/// a promise of several lines: its first line is found as any promise is, then each
/// following line must be the next non-blank output line (canonical-equal, or contained
/// when long enough). A value WRAPPED over several comment lines but PRINTED on one is
/// found first, by joining the block with spaces.
fn multiline(a: Allocator, raw: []const u8, norm_lines: []const []const u8, from: usize) Allocator.Error!usize {
    const nl = norm_lines.len;
    const all = try T.splitLines(a, raw);
    var want: std.ArrayList([]const u8) = .empty;
    for (all) |l| if (T.trimSp(l).len != 0) try want.append(a, l);
    const nw = want.items.len;
    if (nw == 0) return 0;
    var joined: std.ArrayList(u8) = .empty;
    try joined.appendSlice(a, want.items[0]);
    for (want.items[1..]) |l| {
        try joined.append(a, ' ');
        try joined.appendSlice(a, l);
    }
    const one = try promiseAt(a, joined.items, norm_lines, from);
    if (one > 0) return one;
    const first = try promiseAt(a, want.items[0], norm_lines, from);
    if (first == 0 or nw == 1) return first;
    var at = first;
    var k: usize = 1;
    while (k < nw) : (k += 1) {
        at += 1;
        while (at <= nl and norm_lines[at - 1].len == 0) at += 1;
        if (at > nl) return 0;
        const cand = try norm(a, want.items[k]);
        const cc = try canon(a, cand);
        const cl = try canon(a, norm_lines[at - 1]);
        if (std.mem.eql(u8, cc, cl)) continue;
        if (cc.len >= 5 and T.find(cl, cc) > 0) continue;
        return 0;
    }
    return at;
}

// ── tests ────────────────────────────────────────────────────

const testing = std.testing;

fn lines(a: Allocator, raws: []const []const u8) ![][]const u8 {
    const out = try a.alloc([]const u8, raws.len);
    for (raws, 0..) |r, i| out[i] = try norm(a, r);
    return out;
}

test "a short promise must equal the line; a long one may be contained" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const out = try lines(a, &.{ "3", "[ 6, 28 ]" });
    try testing.expectEqual(@as(usize, 0), try promiseAt(a, "6", out, 1));
    try testing.expectEqual(@as(usize, 1), try promiseAt(a, "3", out, 1));
    const out2 = try lines(a, &.{"the total is 12 dollars"});
    try testing.expectEqual(@as(usize, 1), try promiseAt(a, "total is 12", out2, 1));
}

test "TRUE prints as 1, a note in parentheses is dropped, quotes come off" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const out = try lines(a, &.{ "1", "hello" });
    try testing.expectEqual(@as(usize, 1), try promiseAt(a, "TRUE", out, 1));
    try testing.expectEqual(@as(usize, 2), try promiseAt(a, "\"hello\" (a greeting)", out, 1));
}

test "an error promise looks for the message" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    try testing.expect(try isErrorPromise(a, "ERROR: bad input"));
    try testing.expect(try isErrorPromise(a, "ERRORS! no"));
    try testing.expect(!try isErrorPromise(a, "ERROR bad"));
    const out = try lines(a, &.{ "ok", "Line 12 bad input" });
    try testing.expectEqual(@as(usize, 2), try promiseAt(a, "ERROR: \"bad input\"", out, 1));
}

test "a list printed bare, one item per line, is compared item by item" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const out = try lines(a, &.{ "x", "a", "b", "c" });
    try testing.expectEqual(@as(usize, 4), try promiseAt(a, "[a, b, c]", out, 1));
}

test "a block wrapped over comment lines is found printed on one line" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const out = try lines(a, &.{"[ 1609, 1575 ]"});
    try testing.expectEqual(@as(usize, 1), try promiseAt(a, "[\n1609, 1575\n]", out, 1));
}

test "symbols print bare and lowercased" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const out = try lines(a, &.{"name"});
    try testing.expectEqual(@as(usize, 1), try promiseAt(a, ":Name", out, 1));
}
