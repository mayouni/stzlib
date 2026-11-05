//! Testoor core -- the text rules the judge shares. Pure Zig, no Ring.
//!
//! Every function here is a port of a Ring behaviour that was MEASURED on Ring 1.27 and on
//! Ring++ (2026-11-05), because the judge's bytes depend on it and a port that "does the
//! obvious thing" is wrong in each of these places:
//!   - `trim` strips the byte 32 and nothing else (not TAB, not LF, not CR)
//!   - `substr(s, start, count)` answers "" for start < 1, count <= 0 or start past the end
//!   - `lower` / `upper` fold A to Z only; every other byte is left alone
//!   - `str2list` splits at LF, removes a CR at the end of a line, and a final LF adds nothing
//!   - strings compare byte for byte, and `find` of an empty needle answers 1
//!   - a number prints as an integer when it is whole and with two decimals otherwise, the
//!     decimals rounded on the EXACT binary value (ties to even, as Ring++ and Zig do;
//!     Ring 1.27 rounds an exact tie up, which the goldens avoid on purpose)
//! TESTOOR_ZIG_CORE.md section 4 is the list; the guards of golden/ pin each one.

const std = @import("std");
const Allocator = std.mem.Allocator;

/// Ring's `trim`: the byte 32 at both ends, nothing else.
pub fn trimSp(s: []const u8) []const u8 {
    var a: usize = 0;
    var b: usize = s.len;
    while (a < b and s[a] == ' ') a += 1;
    while (b > a and s[b - 1] == ' ') b -= 1;
    return s[a..b];
}

/// Ring's `substr(s, needle)`: the 1-based position of the first occurrence, 0 when none.
/// An empty needle is found at 1, as Ring answers.
pub fn find(hay: []const u8, needle: []const u8) usize {
    if (needle.len == 0) return 1;
    if (std.mem.indexOf(u8, hay, needle)) |i| return i + 1;
    return 0;
}

/// `substr(s, needle) = 1`: the needle is where the string begins.
pub fn startsWith(hay: []const u8, needle: []const u8) bool {
    return find(hay, needle) == 1;
}

/// Ring's `substr(s, start, count)`, start 1-based. Out of range answers "".
pub fn sub(s: []const u8, start: i64, count: i64) []const u8 {
    if (start < 1 or count <= 0) return "";
    const n: i64 = @intCast(s.len);
    if (start > n) return "";
    const from: usize = @intCast(start - 1);
    var c: i64 = count;
    if (c > n - start + 1) c = n - start + 1;
    return s[from .. from + @as(usize, @intCast(c))];
}

/// Ring's `right(s, n)`: the last n bytes, all of them when n is larger, "" for n <= 0.
pub fn right(s: []const u8, n: usize) []const u8 {
    if (n == 0) return "";
    if (n >= s.len) return s;
    return s[s.len - n ..];
}

pub fn lowerAscii(a: Allocator, s: []const u8) ![]u8 {
    const out = try a.alloc(u8, s.len);
    for (s, 0..) |c, i| out[i] = if (c >= 'A' and c <= 'Z') c + 32 else c;
    return out;
}

pub fn upperAscii(a: Allocator, s: []const u8) ![]u8 {
    const out = try a.alloc(u8, s.len);
    for (s, 0..) |c, i| out[i] = if (c >= 'a' and c <= 'z') c - 32 else c;
    return out;
}

/// Ring's three-argument `substr(s, old, new)`: every occurrence, left to right, not
/// overlapping. An empty `old` changes nothing.
pub fn replaceAll(a: Allocator, s: []const u8, old: []const u8, new: []const u8) ![]u8 {
    if (old.len == 0) return a.dupe(u8, s);
    var out: std.ArrayList(u8) = .empty;
    var i: usize = 0;
    while (i < s.len) {
        if (i + old.len <= s.len and std.mem.eql(u8, s[i .. i + old.len], old)) {
            try out.appendSlice(a, new);
            i += old.len;
        } else {
            try out.append(a, s[i]);
            i += 1;
        }
    }
    return out.toOwnedSlice(a);
}

/// Ring's `str2list`: lines split at LF, one CR at the end of a line removed, and the
/// text after the last LF counted only when it is not empty.
pub fn splitLines(a: Allocator, s: []const u8) ![][]const u8 {
    var out: std.ArrayList([]const u8) = .empty;
    var start: usize = 0;
    var i: usize = 0;
    while (i < s.len) : (i += 1) {
        if (s[i] == '\n') {
            try out.append(a, stripCr(s[start..i]));
            start = i + 1;
        }
    }
    if (start < s.len) try out.append(a, stripCr(s[start..]));
    return out.toOwnedSlice(a);
}

fn stripCr(s: []const u8) []const u8 {
    if (s.len > 0 and s[s.len - 1] == '\r') return s[0 .. s.len - 1];
    return s;
}

pub fn removeCr(a: Allocator, s: []const u8) ![]u8 {
    var out: std.ArrayList(u8) = .empty;
    for (s) |c| if (c != '\r') try out.append(a, c);
    return out.toOwnedSlice(a);
}

/// The number a Ring numeric string means, or null where Ring raises R41. Ring takes
/// leading spaces, a sign, decimals, an exponent and 0x hex; an empty string is 0.
pub fn parseNumber(s: []const u8) ?f64 {
    const t = trimSp(s);
    if (t.len == 0) return 0;
    var body = t;
    var neg = false;
    if (body[0] == '-' or body[0] == '+') {
        neg = body[0] == '-';
        body = body[1..];
    }
    if (body.len == 0) return null;
    var v: f64 = 0;
    if (body.len > 2 and body[0] == '0' and (body[1] == 'x' or body[1] == 'X')) {
        const n = std.fmt.parseInt(u64, body[2..], 16) catch return null;
        v = @floatFromInt(n);
    } else {
        for (body) |c| {
            const ok = (c >= '0' and c <= '9') or c == '.' or c == 'e' or c == 'E' or c == '+' or c == '-';
            if (!ok) return null;
        }
        v = std.fmt.parseFloat(f64, body) catch return null;
    }
    return if (neg) -v else v;
}

/// How Ring prints a number: whole values without decimals, every other value with two,
/// rounded on the exact binary value, ties to even.
pub fn fmtNum(a: Allocator, v: f64) ![]u8 {
    if (std.math.isNan(v)) return a.dupe(u8, "nan");
    if (std.math.isInf(v)) return a.dupe(u8, if (v < 0) "-inf" else "inf");
    if (v == @floor(v) and @abs(v) < 9.0e18) {
        return std.fmt.allocPrint(a, "{d}", .{@as(i64, @intFromFloat(v))});
    }
    const neg = v < 0;
    const x = @abs(v);
    const bits: u64 = @bitCast(x);
    const e_raw: i32 = @intCast((bits >> 52) & 0x7ff);
    const mant: u64 = bits & ((@as(u64, 1) << 52) - 1);
    var m: u128 = undefined;
    var e: i32 = undefined;
    if (e_raw == 0) {
        m = mant;
        e = -1074;
    } else {
        m = mant | (@as(u64, 1) << 52);
        e = e_raw - 1075;
    }
    var q: u128 = 0;
    if (e >= 0) {
        // not reachable for a non-whole value below 2^53, kept for completeness
        q = (m << @intCast(@min(e, 60))) * 100;
    } else if (-e < 120) {
        const sh: u7 = @intCast(-e);
        const num: u128 = m * 100;
        q = num >> sh;
        const rem: u128 = num & ((@as(u128, 1) << sh) - 1);
        const half: u128 = @as(u128, 1) << (sh - 1);
        if (rem > half or (rem == half and (q & 1) == 1)) q += 1;
    }
    const ip: u128 = q / 100;
    const fp: u128 = q % 100;
    return std.fmt.allocPrint(a, "{s}{d}.{d:0>2}", .{ if (neg) "-" else "", ip, fp });
}

/// An output buffer that knows the escape Ring's `_TourJsonStr` writes: FIVE escapes
/// only (backslash, quote, TAB, LF, CR). Every other byte, control bytes and non-ASCII
/// alike, goes through raw -- std.json would escape more, so the core owns this writer.
pub const Buf = struct {
    a: Allocator,
    list: std.ArrayList(u8) = .empty,

    pub fn init(a: Allocator) Buf {
        return .{ .a = a };
    }
    pub fn s(self: *Buf, str: []const u8) !void {
        try self.list.appendSlice(self.a, str);
    }
    pub fn c(self: *Buf, ch: u8) !void {
        try self.list.append(self.a, ch);
    }
    pub fn int(self: *Buf, n: i64) !void {
        const t = try std.fmt.allocPrint(self.a, "{d}", .{n});
        try self.s(t);
    }
    pub fn num(self: *Buf, v: f64) !void {
        try self.s(try fmtNum(self.a, v));
    }
    /// a JSON string: quotes and the five escapes
    pub fn js(self: *Buf, str: []const u8) !void {
        try self.c('"');
        for (str) |ch| switch (ch) {
            '\\' => try self.s("\\\\"),
            '"' => try self.s("\\\""),
            '\t' => try self.s("\\t"),
            '\n' => try self.s("\\n"),
            '\r' => try self.s("\\r"),
            else => try self.c(ch),
        };
        try self.c('"');
    }
    pub fn done(self: *Buf) ![]u8 {
        return self.list.toOwnedSlice(self.a);
    }
};

// ── tests ────────────────────────────────────────────────────

const testing = std.testing;

test "trim strips the byte 32 only" {
    try testing.expectEqualStrings("a b", trimSp("  a b  "));
    try testing.expectEqualStrings("\ta\n", trimSp(" \ta\n "));
    try testing.expectEqualStrings("", trimSp("   "));
}

test "substr edge cases answer empty, as Ring does" {
    try testing.expectEqualStrings("", sub("abc", 2, 0));
    try testing.expectEqualStrings("", sub("abc", 2, -1));
    try testing.expectEqualStrings("", sub("abc", 5, 1));
    try testing.expectEqualStrings("", sub("abc", 0, 2));
    try testing.expectEqualStrings("", sub("abc", 4, 1));
    try testing.expectEqualStrings("abc", sub("abc", 1, 10));
    try testing.expectEqualStrings("c", sub("abc", 3, 2));
}

test "find is 1-based, case sensitive, and an empty needle is at 1" {
    try testing.expectEqual(@as(usize, 3), find("Hello", "llo"));
    try testing.expectEqual(@as(usize, 0), find("Hello", "hello"));
    try testing.expectEqual(@as(usize, 1), find("abc", ""));
}

test "lower and upper fold A to Z only" {
    const a = testing.allocator;
    const l = try lowerAscii(a, "ABC\xc3\x80");
    defer a.free(l);
    try testing.expectEqualStrings("abc\xc3\x80", l);
    const u = try upperAscii(a, "abc\xc3\xa9");
    defer a.free(u);
    try testing.expectEqualStrings("ABC\xc3\xa9", u);
}

test "replaceAll is left to right and not overlapping" {
    const a = testing.allocator;
    const r1 = try replaceAll(a, "aaaa", "aa", "b");
    defer a.free(r1);
    try testing.expectEqualStrings("bb", r1);
    const r2 = try replaceAll(a, "a   b", "  ", " ");
    defer a.free(r2);
    try testing.expectEqualStrings("a  b", r2);
}

test "splitLines follows str2list" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    try testing.expectEqual(@as(usize, 3), (try splitLines(a, "a\n\nb\n")).len);
    try testing.expectEqual(@as(usize, 0), (try splitLines(a, "")).len);
    try testing.expectEqual(@as(usize, 1), (try splitLines(a, "\n")).len);
    const crlf = try splitLines(a, "a\r\nb");
    try testing.expectEqual(@as(usize, 2), crlf.len);
    try testing.expectEqualStrings("a", crlf[0]);
}

test "numbers print as Ring++ prints them" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const a = arena.allocator();
    try testing.expectEqualStrings("1.23", try fmtNum(a, 1234.0 / 1000.0));
    try testing.expectEqualStrings("1.24", try fmtNum(a, 1235.0 / 1000.0));
    try testing.expectEqualStrings("1.25", try fmtNum(a, 1255.0 / 1000.0));
    try testing.expectEqualStrings("0.12", try fmtNum(a, 0.125));
    try testing.expectEqualStrings("0.88", try fmtNum(a, 880.0 / 1000.0));
    try testing.expectEqualStrings("5", try fmtNum(a, 5000.0 / 1000.0));
    try testing.expectEqualStrings("1.50", try fmtNum(a, 1.5));
    try testing.expectEqualStrings("-1", try fmtNum(a, -1));
    try testing.expectEqualStrings("0", try fmtNum(a, 0));
    try testing.expectEqualStrings("1700000000", try fmtNum(a, 1700000000));
}

test "a numeric string is read as Ring reads it, or refused" {
    try testing.expectEqual(@as(f64, 7), parseNumber(" 7").?);
    try testing.expectEqual(@as(f64, -3), parseNumber("-3").?);
    try testing.expectEqual(@as(f64, 1.5), parseNumber("1.5").?);
    try testing.expectEqual(@as(f64, 0), parseNumber("").?);
    try testing.expectEqual(@as(f64, 1000), parseNumber("1e3").?);
    try testing.expectEqual(@as(f64, 16), parseNumber("0x10").?);
    try testing.expect(parseNumber("abc") == null);
    try testing.expect(parseNumber("12abc") == null);
}

test "the JSON string writer escapes five bytes and no others" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    var b = Buf.init(arena.allocator());
    try b.js("a\"b\\c\td\ne\rf\x01\xc3\xa9");
    try testing.expectEqualStrings("\"a\\\"b\\\\c\\td\\ne\\rf\x01\xc3\xa9\"", try b.done());
}
