// Softanza Engine -- the ONE case fold every case-insensitive comparison reads
//
// "Case ignored" means Unicode FULL case folding (CaseFolding.txt, statuses C
// and F, through utf8proc), one codepoint at a time, with no allocation. List
// equality, list sort order, list hashing (list.zig), hash-map key lookup
// (hashmap.zig), table column names (table.zig) and value equality (value.zig)
// all read this file, so they cannot disagree about which texts are equal.
//
// Until 2026-11-09 each folded ASCII only, so "α" and "Α" differed with case
// ignored while stzString called them equal (STZLIB-LISTCI-UNICODE-01). The
// fold lived first in list.zig and moved here when hashmap.zig, table.zig and
// value.zig took it too.
//
// Anything that orders or hashes folded text must use THIS fold, because a
// hash set and a sort-then-compare test are correct only while
//     eql(a,b)  <=>  compare(a,b) == 0      and      eql(a,b) => hash(a) == hash(b).
//
// Folding is not normalisation: "é" (U+00E9) and "e" + U+0301 stay two
// different texts, as they are when case counts. Full folding can change the
// length -- "ß" folds to "ss", the Kelvin sign K to "k" -- so a caller may
// never compare byte lengths before folding.
//
// A DLL that reaches this file links utf8proc (build.zig: needs_utf8proc).

const std = @import("std");
const ascii = @import("ascii.zig");
const allocator = std.heap.c_allocator;

extern fn utf8proc_iterate(str: [*]const u8, strlen: isize, dst: *i32) callconv(.c) isize;
extern fn utf8proc_decompose_char(cp: i32, dst: [*]i32, bufsize: isize, options: c_int, last_boundclass: ?*c_int) callconv(.c) isize;
extern fn utf8proc_encode_char(cp: i32, dst: [*]u8) callconv(.c) isize;
const UTF8PROC_CASEFOLD: c_int = 1 << 10; // utf8proc.h; CHARBOUND unset, so last_boundclass may be null

/// A byte that does not start valid UTF-8 folds to BAD_BYTE + the byte:
/// above every codepoint, so it never equals one, and it still orders.
pub const BAD_BYTE: i32 = 0x110000;

/// The folded codepoints of a text, one at a time.
pub const FoldIter = struct {
    s: []const u8,
    pos: usize = 0,
    buf: [4]i32 = undefined, // a full fold is at most 3 codepoints
    n: usize = 0,
    k: usize = 0,

    pub fn init(s: []const u8) FoldIter {
        return .{ .s = s };
    }

    pub fn next(self: *FoldIter) ?i32 {
        if (self.k < self.n) {
            const cp = self.buf[self.k];
            self.k += 1;
            return cp;
        }
        if (self.pos >= self.s.len) return null;
        const b = self.s[self.pos];
        if (b < 0x80) {
            self.pos += 1;
            return ascii.lower(b);
        }
        var cp: i32 = 0;
        const used = utf8proc_iterate(self.s.ptr + self.pos, @intCast(self.s.len - self.pos), &cp);
        if (used < 1) {
            self.pos += 1;
            return BAD_BYTE + @as(i32, b);
        }
        self.pos += @intCast(used);
        const m = utf8proc_decompose_char(cp, &self.buf, self.buf.len, UTF8PROC_CASEFOLD, null);
        if (m < 1 or m > self.buf.len) return cp;
        self.n = @intCast(m);
        self.k = 1;
        return self.buf[0];
    }
};

/// Folded order of two texts: codepoint by codepoint, then the shorter first.
/// The UTF-8 byte order and the codepoint order agree, so on ASCII this is the
/// order the ASCII-only fold gave.
pub fn compare(a: []const u8, b: []const u8) i32 {
    // ASCII prefix: no utf8proc call. While both bytes are ASCII, each is the
    // next folded codepoint of its side, so a difference here is final.
    var i: usize = 0;
    while (i < a.len and i < b.len and a[i] < 0x80 and b[i] < 0x80) : (i += 1) {
        const la = ascii.lower(a[i]);
        const lb = ascii.lower(b[i]);
        if (la < lb) return -1;
        if (la > lb) return 1;
    }
    // A full fold never yields nothing, so a side with bytes left is longer.
    if (i == a.len) return if (i == b.len) 0 else -1;
    if (i == b.len) return 1;
    var ia = FoldIter.init(a[i..]);
    var ib = FoldIter.init(b[i..]);
    while (true) {
        const ca = ia.next();
        const cb = ib.next();
        if (ca == null) return if (cb == null) 0 else -1;
        if (cb == null) return 1;
        if (ca.? < cb.?) return -1;
        if (ca.? > cb.?) return 1;
    }
}

/// TRUE when the two texts are equal with case ignored.
pub fn eql(a: []const u8, b: []const u8) bool {
    return compare(a, b) == 0;
}

/// Feeds the folded text to a hasher: texts equal under eql hash equal.
pub fn hashInto(h: *std.hash.Wyhash, s: []const u8) void {
    var it = FoldIter.init(s);
    while (it.next()) |cp| {
        if (cp < 0x80) {
            h.update(&[_]u8{@intCast(cp)});
        } else {
            h.update(std.mem.asBytes(&cp));
        }
    }
}

/// The folded text as UTF-8 (a BAD_BYTE goes back as its byte). Caller frees
/// with std.heap.c_allocator.
pub fn alloc(s: []const u8) ?[]u8 {
    var out = std.ArrayList(u8){};
    out.ensureTotalCapacity(allocator, s.len) catch return null;
    var it = FoldIter.init(s);
    while (it.next()) |cp| {
        var enc: [4]u8 = undefined;
        if (cp >= BAD_BYTE) {
            out.append(allocator, @intCast(cp - BAD_BYTE)) catch {
                out.deinit(allocator);
                return null;
            };
            continue;
        }
        const n = utf8proc_encode_char(cp, &enc);
        if (n < 1) continue;
        out.appendSlice(allocator, enc[0..@intCast(n)]) catch {
            out.deinit(allocator);
            return null;
        };
    }
    return out.toOwnedSlice(allocator) catch {
        out.deinit(allocator);
        return null;
    };
}

/// The folded text written into dst, cut at a whole codepoint when dst is full.
pub fn into(s: []const u8, dst: []u8) usize {
    var w: usize = 0;
    var it = FoldIter.init(s);
    while (it.next()) |cp| {
        var enc: [4]u8 = undefined;
        var n: usize = 1;
        if (cp >= BAD_BYTE) {
            enc[0] = @intCast(cp - BAD_BYTE);
        } else {
            const m = utf8proc_encode_char(cp, &enc);
            if (m < 1) continue;
            n = @intCast(m);
        }
        if (w + n > dst.len) break;
        @memcpy(dst[w..][0..n], enc[0..n]);
        w += n;
    }
    return w;
}

// Expectations written by hand from CaseFolding.txt. The wider law (order,
// equality and hash agreeing over a mixed set) is tested in list.zig.
test "casefold: equal across scripts and byte lengths" {
    try std.testing.expect(eql("αβγ", "ΑΒΓ"));
    try std.testing.expect(eql("straße", "STRASSE"));
    try std.testing.expect(eql("\u{212A}", "k"));
    try std.testing.expect(eql("ς", "Σ"));
    try std.testing.expect(!eql("é", "e\u{0301}"));
    try std.testing.expect(!eql("\u{0131}", "i"));
    var buf: [16]u8 = undefined;
    const n = into("STRAßE", &buf);
    try std.testing.expectEqualStrings("strasse", buf[0..n]);
    const a = alloc("ΑΒΓ") orelse return error.AllocFailed;
    defer allocator.free(a);
    try std.testing.expectEqualStrings("αβγ", a);
}
