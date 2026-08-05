// Softanza Engine -- String Core (Phase D)
//
// Shared types, helpers, lifecycle, and error reporting.
// All other string submodules import from this file.

const std = @import("std");
pub const mem = std.mem;

pub const gpa = std.heap.c_allocator;
pub const unicode = @import("../unicode.zig");

// ─── Error Reporting ───

pub const StrError = enum(c_int) {
    none = 0,
    out_of_memory = 1,
    invalid_utf8 = 2,
    index_out_of_bounds = 3,
    null_handle = 4,
    invalid_argument = 5,
};

var last_error: StrError = .none;

pub fn setError(err: StrError) void {
    last_error = err;
}

pub fn str_last_error() callconv(.c) c_int {
    return @intFromEnum(last_error);
}

pub fn str_clear_error() callconv(.c) void {
    last_error = .none;
}

// ─── Indexing Configuration ───
//
// The engine is 0-based internally. INDEX_BASE adapts the FFI
// boundary for the host language (Ring is 1-based, so INDEX_BASE=1).
// Exported functions accept INDEX_BASE-based indices from the host,
// convert to 0-based with toInternal() or `- INDEX_BASE`, do all
// internal work 0-based, and convert results back with toExternal()
// when returning positions to the host.

pub const INDEX_BASE: c_int = 1;

/// Convert external (host-language) position to internal 0-based index.
pub fn toInternal(pos: i64) usize {
    const adjusted = pos - INDEX_BASE;
    return if (adjusted < 0) 0 else @intCast(adjusted);
}

/// Convert internal 0-based index to external (host-language) position.
pub fn toExternal(pos: usize) i64 {
    return @as(i64, @intCast(pos)) + INDEX_BASE;
}

// ─── Core Types ───

pub const StzStringHandle = ?*StzString;

pub const StzString = struct {
    data: std.ArrayList(u8),
    cached_cp_count: ?usize = null,
    cached_is_ascii: ?bool = null,
    // Codepoint-to-byte offset cache for sequential access optimization.
    // Stores the last resolved (codepoint_index, byte_offset) pair so
    // consecutive char_at(5), char_at(6) calls walk forward from the
    // cache instead of rescanning from the start each time.
    cached_cp_pos: usize = 0,
    cached_byte_pos: usize = 0,

    pub fn init() StzString {
        return .{ .data = .{}, .cached_cp_count = null, .cached_is_ascii = null, .cached_cp_pos = 0, .cached_byte_pos = 0 };
    }

    pub fn deinit(self: *StzString) void {
        self.data.deinit(gpa);
    }

    pub fn slice(self: *const StzString) []const u8 {
        return self.data.items;
    }

    pub fn invalidateCache(self: *StzString) void {
        self.cached_cp_count = null;
        self.cached_is_ascii = null;
        self.cached_cp_pos = 0;
        self.cached_byte_pos = 0;
    }

    /// Convert a 0-based codepoint index to a byte offset, using the
    /// internal cache to avoid rescanning from byte 0 every time.
    /// Returns null if the index is out of range.
    pub fn cpToByteCached(self: *StzString, cp_index: usize) ?usize {
        const src = self.data.items;
        if (src.len == 0) return if (cp_index == 0) @as(?usize, 0) else null;

        // If target is at or ahead of the cache, walk forward
        if (cp_index >= self.cached_cp_pos) {
            var pos: usize = self.cached_byte_pos;
            var cp: usize = self.cached_cp_pos;
            while (pos < src.len and cp < cp_index) {
                const seq_len = std.unicode.utf8ByteSequenceLength(src[pos]) catch 1;
                pos += seq_len;
                cp += 1;
            }
            if (cp == cp_index) {
                self.cached_cp_pos = cp;
                self.cached_byte_pos = pos;
                return pos;
            }
            return null;
        }

        // Target is before the cache -- walk from the beginning
        var pos: usize = 0;
        var cp: usize = 0;
        while (pos < src.len and cp < cp_index) {
            const seq_len = std.unicode.utf8ByteSequenceLength(src[pos]) catch 1;
            pos += seq_len;
            cp += 1;
        }
        if (cp == cp_index) {
            self.cached_cp_pos = cp;
            self.cached_byte_pos = pos;
            return pos;
        }
        return null;
    }

    pub fn isAscii(self: *StzString) bool {
        if (self.cached_is_ascii) |v| return v;
        const items = self.data.items;
        var ascii = true;
        for (items) |b| {
            if (b >= 128) {
                ascii = false;
                break;
            }
        }
        self.cached_is_ascii = ascii;
        return ascii;
    }

    pub fn cpCount(self: *StzString) usize {
        if (self.cached_cp_count) |c| return c;
        const count = utf8CodepointCount(self.data.items);
        self.cached_cp_count = count;
        return count;
    }
};

// ─── Find Result Type ───

pub const StzFindResult = struct {
    positions: std.ArrayList(i64),

    pub fn init() StzFindResult {
        return .{ .positions = .{} };
    }

    pub fn deinit(self: *StzFindResult) void {
        self.positions.deinit(gpa);
    }
};

pub const StzFindResultHandle = ?*StzFindResult;

// A compute-once, query-by-index list of STRINGS (the string analog of
// StzFindResult). Owns copies of each item's bytes. Used by the
// substring-enumeration family so O(n^2) work is done once engine-side
// and Ring pulls items by index (never re-enumerating).
pub const StzStrListResult = struct {
    items: std.ArrayList([]u8),

    pub fn init() StzStrListResult {
        return .{ .items = .{} };
    }

    pub fn push(self: *StzStrListResult, bytes: []const u8) void {
        const copy = gpa.alloc(u8, bytes.len) catch return;
        @memcpy(copy, bytes);
        self.items.append(gpa, copy) catch {
            gpa.free(copy);
        };
    }

    pub fn deinit(self: *StzStrListResult) void {
        for (self.items.items) |it| gpa.free(it);
        self.items.deinit(gpa);
    }
};

pub const StzStrListResultHandle = ?*StzStrListResult;

pub fn stz_strlist_count(result: StzStrListResultHandle) callconv(.c) c_int {
    if (result) |r| return @intCast(r.items.items.len);
    return 0;
}

// 1-based index; returns a FRESH string handle (caller frees it).
pub fn stz_strlist_get(result: StzStrListResultHandle, index: c_int) callconv(.c) StzStringHandle {
    if (result) |r| {
        if (index >= 1 and @as(usize, @intCast(index)) <= r.items.items.len) {
            const it = r.items.items[@as(usize, @intCast(index)) - 1];
            return str_from(it.ptr, it.len);
        }
    }
    return str_new();
}

pub fn stz_strlist_free(result: StzStrListResultHandle) callconv(.c) void {
    if (result) |r| {
        r.deinit();
        gpa.destroy(r);
    }
}

// ─── Lifecycle ───

pub fn str_new() callconv(.c) StzStringHandle {
    const s = gpa.create(StzString) catch return null;
    s.* = StzString.init();
    return s;
}

pub fn str_from(utf8: [*c]const u8, len: usize) callconv(.c) StzStringHandle {
    setError(.none);
    if (utf8 == null and len > 0) {
        setError(.invalid_argument);
        return null;
    }
    if (utf8 != null and len > 0) {
        const src: []const u8 = utf8[0..len];
        if (!std.unicode.utf8ValidateSlice(src)) {
            setError(.invalid_utf8);
            return null;
        }
    }
    const s = gpa.create(StzString) catch {
        setError(.out_of_memory);
        return null;
    };
    s.* = StzString.init();
    if (utf8 != null and len > 0) {
        const src: []const u8 = utf8[0..len];
        s.data.appendSlice(gpa, src) catch {
            setError(.out_of_memory);
            s.deinit();
            gpa.destroy(s);
            return null;
        };
    }
    return s;
}

pub fn str_free(handle: StzStringHandle) callconv(.c) void {
    if (handle) |s| {
        s.deinit();
        gpa.destroy(s);
    }
}

pub fn str_data(handle: StzStringHandle) callconv(.c) [*c]const u8 {
    if (handle) |s| {
        if (s.data.items.len == 0) return "";
        const items = s.data.items;
        if (s.data.capacity > items.len) {
            items.ptr[items.len] = 0;
        } else {
            s.data.ensureTotalCapacity(gpa, items.len + 1) catch {
                setError(.out_of_memory);
                return "";
            };
            s.data.items.ptr[s.data.items.len] = 0;
        }
        return s.data.items.ptr;
    }
    return "";
}

pub fn str_size(handle: StzStringHandle) callconv(.c) usize {
    if (handle) |s| return s.data.items.len;
    return 0;
}

pub fn str_count(handle: StzStringHandle) callconv(.c) usize {
    if (handle) |s| {
        return s.cpCount();
    }
    return 0;
}

// ─── Mutation ───

pub fn str_append(handle: StzStringHandle, utf8: [*c]const u8, len: usize) callconv(.c) void {
    setError(.none);
    if (handle) |s| {
        if (utf8 != null and len > 0) {
            s.data.appendSlice(gpa, utf8[0..len]) catch {
                setError(.out_of_memory);
            };
            s.invalidateCache();
        }
    } else {
        setError(.null_handle);
    }
}

pub fn str_insert(handle: StzStringHandle, byte_pos: usize, utf8: [*c]const u8, len: usize) callconv(.c) void {
    setError(.none);
    if (handle) |s| {
        if (utf8 == null or len == 0) return;
        const pos = @min(byte_pos, s.data.items.len);
        s.data.insertSlice(gpa, pos, utf8[0..len]) catch {
            setError(.out_of_memory);
        };
        s.invalidateCache();
    } else {
        setError(.null_handle);
    }
}

// ─── Shared Helpers ───

// Split a NUL-packed buffer into slices (views into `buf`), including a final
// possibly-empty segment. Shared by the corpus/list FFI paths (edit clustering,
// TF-IDF) that pass a Ring string-list as one NUL-delimited engine string.
pub fn splitNul(buf: []const u8, out: *std.ArrayList([]const u8)) void {
    var start: usize = 0;
    var i: usize = 0;
    while (i < buf.len) : (i += 1) {
        if (buf[i] == 0) {
            out.append(gpa, buf[start..i]) catch {};
            start = i + 1;
        }
    }
    out.append(gpa, buf[start..]) catch {};
}

pub fn casefoldAlloc(input: []const u8) ?[]u8 {
    if (input.len == 0) return null;
    var out_len: usize = 0;
    const ptr = unicode.stz_unicode_casefold(input.ptr, input.len, &out_len);
    if (ptr == null or out_len == 0) return null;
    return @as([*]u8, @ptrCast(ptr))[0..out_len];
}

pub fn ciEqlUnicode(a: []const u8, b: []const u8) bool {
    const fa = casefoldAlloc(a) orelse return mem.eql(u8, a, b);
    defer gpa.free(fa);
    const fb = casefoldAlloc(b) orelse return mem.eql(u8, a, b);
    defer gpa.free(fb);
    return mem.eql(u8, fa, fb);
}

pub fn ciMatch(a: []const u8, b: []const u8) bool {
    return ciEqlUnicode(a, b);
}

pub fn decodeCodepoint(bytes: []const u8, pos: usize, cp_len: usize) i32 {
    if (cp_len == 1) return @intCast(bytes[pos]);
    if (cp_len == 2 and pos + 1 < bytes.len)
        return @intCast((@as(u21, bytes[pos] & 0x1F) << 6) | (bytes[pos + 1] & 0x3F));
    if (cp_len == 3 and pos + 2 < bytes.len)
        return @intCast((@as(u21, bytes[pos] & 0x0F) << 12) | (@as(u21, bytes[pos + 1] & 0x3F) << 6) | (bytes[pos + 2] & 0x3F));
    if (cp_len == 4 and pos + 3 < bytes.len)
        return @intCast((@as(u21, bytes[pos] & 0x07) << 18) | (@as(u21, bytes[pos + 1] & 0x3F) << 12) | (@as(u21, bytes[pos + 2] & 0x3F) << 6) | (bytes[pos + 3] & 0x3F));
    return 0;
}

/// Number of codepoints in a UTF-8 buffer.
///
/// Vectorising isAllAscii above made the ASCII path ~1.9x faster at the
/// Ring surface and thereby EXPOSED this loop: with a real multibyte
/// prefix, StzLen on the same 180 KB went 7.9 ms -> 34.9 ms, because the
/// ASCII gate now bails instantly and everything is spent walking here.
/// Speeding one path up is what made the other one's cost legible.
/// Restating it as the lane-wise count below took that 34.9 ms to
/// 15.3 ms (2.3x), measured the same way.
///
/// The scalar walk is sequential BY CONSTRUCTION -- each step's stride
/// comes from the byte it just read -- so it cannot be vectorised as
/// written. It has to be restated as something order-free, and UTF-8
/// affords exactly that: every codepoint is one lead byte followed by
/// continuation bytes, and a continuation byte is precisely one matching
/// `0b10xxxxxx`. So the count of codepoints IS the count of NON
/// continuation bytes, which each lane can judge independently.
///
///     count = popcount over lanes of ((b & 0xC0) != 0x80)
///
/// EQUIVALENT ON VALID UTF-8, and handles are validated at construction
/// (`str_from` runs utf8ValidateSlice and refuses bad input). The two
/// forms can disagree on invalid bytes -- the old walk trusts a bad lead
/// byte's implied length via `catch 1`, this one classifies each byte on
/// its own -- so the differential test below pins them together over the
/// valid corpus this function is actually reachable with.
pub fn utf8CodepointCount(bytes: []const u8) usize {
    if (isAllAscii(bytes)) return bytes.len;

    const W = std.simd.suggestVectorLength(u8) orelse return utf8CodepointCountScalar(bytes);
    const Vec = @Vector(W, u8);
    const top2: Vec = @splat(0xC0);
    const cont_bits: Vec = @splat(0x80);
    const one: Vec = @splat(1);
    const zero: Vec = @splat(0);

    var count: usize = 0;
    var i: usize = 0;
    while (i + W <= bytes.len) : (i += W) {
        const v: Vec = bytes[i..][0..W].*;
        const is_lead = (v & top2) != cont_bits;
        // Sum of 0/1 over W lanes maxes out at W (32 here), so a u8
        // accumulator cannot overflow. Widen the lane type before
        // raising W past 255.
        count += @reduce(.Add, @select(u8, is_lead, one, zero));
    }
    while (i < bytes.len) : (i += 1) {
        if ((bytes[i] & 0xC0) != 0x80) count += 1;
    }
    return count;
}

/// The original sequential walk. Kept as the reference the vector form is
/// tested against, and as the fallback on targets with no vector support.
pub fn utf8CodepointCountScalar(bytes: []const u8) usize {
    var count: usize = 0;
    var i: usize = 0;
    while (i < bytes.len) {
        const byte = bytes[i];
        const cp_len = std.unicode.utf8ByteSequenceLength(byte) catch 1;
        count += 1;
        i += cp_len;
    }
    return count;
}

pub fn codepointIndexToByteOffset(bytes: []const u8, cp_index: usize) usize {
    if (isAllAscii(bytes)) {
        return @min(cp_index, bytes.len);
    }
    var cp_count: usize = 0;
    var i: usize = 0;
    while (i < bytes.len and cp_count < cp_index) {
        const byte = bytes[i];
        const cp_len = std.unicode.utf8ByteSequenceLength(byte) catch 1;
        cp_count += 1;
        i += cp_len;
    }
    return i;
}

pub fn byteOffsetToCodepointIndex(bytes: []const u8, byte_offset: usize) usize {
    if (isAllAscii(bytes)) return @min(byte_offset, bytes.len);
    var cp_count: usize = 0;
    var i: usize = 0;
    while (i < bytes.len and i < byte_offset) {
        const byte = bytes[i];
        const cp_len = std.unicode.utf8ByteSequenceLength(byte) catch 1;
        cp_count += 1;
        i += cp_len;
    }
    return cp_count;
}

/// True when no byte has the high bit set.
///
/// This is the ASCII fast-path gate for the three codepoint<->byte
/// primitives above, so every Unicode-aware operation in the library
/// pays for it. Note the shape of that "fast path": it scans the WHOLE
/// buffer in order to earn the right to return `bytes.len`. The scan is
/// the cost, which is exactly why its width matters.
///
/// A high-bit test over contiguous bytes is the canonical vector loop:
/// splat the mask, stride by the target's lane count, reduce, then a
/// scalar tail. Measured here (ReleaseSafe, 32-byte lanes), all-ASCII
/// input so the full buffer is walked:
///
///        16 B    1.00x   (below one vector -- tail only, no change)
///        64 B   15.21x
///       256 B   16.82x
///      4096 B   13.97x
///      64 KB    13.71x
///       1 MB    13.87x
///
/// The 16-byte row is the point worth keeping: short strings, which are
/// this library's common case, neither gain nor LOSE. The vector loop is
/// skipped entirely and the tail is the old loop. So this is a win on
/// document-scale text bought without a regression on `StzLen("hello")`.
pub fn isAllAscii(bytes: []const u8) bool {
    const W = std.simd.suggestVectorLength(u8) orelse {
        for (bytes) |b| {
            if (b >= 128) return false;
        }
        return true;
    };
    const Vec = @Vector(W, u8);
    const zero: Vec = @splat(0);
    const hi: Vec = @splat(0x80);
    var i: usize = 0;
    while (i + W <= bytes.len) : (i += W) {
        const v: Vec = bytes[i..][0..W].*;
        // `& 0x80 != 0` rather than `>= 128`: u8 comparison against a
        // splat works too, but the mask form is the one that stays
        // correct if the lane type is ever widened.
        if (@reduce(.Or, (v & hi) != zero)) return false;
    }
    while (i < bytes.len) : (i += 1) {
        if (bytes[i] >= 128) return false;
    }
    return true;
}

pub fn bmhSearch(haystack: []const u8, needle: []const u8, start: usize) ?usize {
    const n = needle.len;
    const h = haystack.len;
    if (n == 0 or n > h or start + n > h) return null;
    var shift: [256]usize = undefined;
    for (&shift) |*s| s.* = n;
    for (needle[0 .. n - 1], 0..) |byte, i| {
        shift[byte] = n - 1 - i;
    }
    var pos: usize = start;
    while (pos + n <= h) {
        if (mem.eql(u8, haystack[pos..][0..n], needle)) {
            return pos;
        }
        pos += shift[haystack[pos + n - 1]];
    }
    return null;
}

pub fn formatUsize(val: usize, buf: *[12]u8) usize {
    if (val == 0) {
        buf[0] = '0';
        return 1;
    }
    var v = val;
    var len: usize = 0;
    while (v > 0) : (len += 1) {
        buf[len] = @intCast('0' + @as(u8, @intCast(v % 10)));
        v /= 10;
    }
    var lo: usize = 0;
    var hi: usize = len - 1;
    while (lo < hi) {
        const tmp = buf[lo];
        buf[lo] = buf[hi];
        buf[hi] = tmp;
        lo += 1;
        hi -= 1;
    }
    return len;
}

pub fn isVowelAscii(c: u8) bool {
    return switch (c) {
        'a', 'e', 'i', 'o', 'u', 'A', 'E', 'I', 'O', 'U' => true,
        else => false,
    };
}

// ─── Core Tests ───

test "string lifecycle" {
    const s = str_new();
    try std.testing.expect(s != null);
    str_free(s);
}

test "string from and data" {
    const s = str_from("Hello", 5);
    try std.testing.expect(s != null);
    const data = str_data(s);
    try std.testing.expect(data != null);
    try std.testing.expectEqualStrings("Hello", data[0..5]);
    str_free(s);
}

test "string size" {
    const s = str_from("Hello", 5);
    try std.testing.expectEqual(@as(usize, 5), str_size(s));
    str_free(s);
}

test "string count" {
    const s = str_from("Hello", 5);
    try std.testing.expectEqual(@as(usize, 5), str_count(s));
    str_free(s);
}

test "string count multibyte" {
    const s = str_from("\xc3\xa9\xc3\xa8", 4);
    try std.testing.expectEqual(@as(usize, 2), str_count(s));
    try std.testing.expectEqual(@as(usize, 4), str_size(s));
    str_free(s);
}

test "string append" {
    const s = str_new();
    str_append(s, "Hello", 5);
    str_append(s, " World", 6);
    try std.testing.expectEqualStrings("Hello World", s.?.slice());
    str_free(s);
}

test "string insert" {
    const s = str_from("Helo", 4);
    str_insert(s, 2, "l", 1);
    try std.testing.expectEqualStrings("Hello", s.?.slice());
    str_free(s);
}

test "str_last_error initial state" {
    try std.testing.expectEqual(@as(c_int, 0), str_last_error());
}

test "str_clear_error" {
    _ = str_from("\xff\xfe", 2);
    try std.testing.expect(str_last_error() != 0);
    str_clear_error();
    try std.testing.expectEqual(@as(c_int, 0), str_last_error());
}

test "str_from rejects invalid UTF-8" {
    const bad1 = str_from("\xff\xfe", 2);
    try std.testing.expect(bad1 == null);
    try std.testing.expectEqual(@as(c_int, 2), str_last_error());
    const bad2 = str_from("\xc0\x80", 2);
    try std.testing.expect(bad2 == null);
    try std.testing.expectEqual(@as(c_int, 2), str_last_error());
    const bad3 = str_from("\xe2\x82", 2);
    try std.testing.expect(bad3 == null);
    try std.testing.expectEqual(@as(c_int, 2), str_last_error());
    const good = str_from("Hello", 5);
    try std.testing.expect(good != null);
    try std.testing.expectEqual(@as(c_int, 0), str_last_error());
    str_free(good);
}

test "str_from accepts valid multi-byte UTF-8" {
    const s2 = str_from("\xc3\xa9", 2);
    try std.testing.expect(s2 != null);
    try std.testing.expectEqual(@as(c_int, 0), str_last_error());
    str_free(s2);
    const s3 = str_from("\xe2\x82\xac", 3);
    try std.testing.expect(s3 != null);
    str_free(s3);
    const s4 = str_from("\xf0\x9f\x98\x80", 4);
    try std.testing.expect(s4 != null);
    str_free(s4);
}

test "str_from null pointer with len 0 succeeds" {
    const s = str_from(null, 0);
    try std.testing.expect(s != null);
    try std.testing.expectEqual(@as(c_int, 0), str_last_error());
    try std.testing.expectEqual(@as(usize, 0), str_size(s));
    str_free(s);
}

test "str_from null pointer with len > 0 fails" {
    const s = str_from(null, 5);
    try std.testing.expect(s == null);
    try std.testing.expectEqual(@as(c_int, 5), str_last_error());
}

test "str_data null-terminated" {
    const s = str_from("Hello", 5);
    const data = str_data(s);
    try std.testing.expectEqual(@as(u8, 0), data[5]);
    str_free(s);
}

test "str_data empty string returns empty" {
    const s = str_new();
    const data = str_data(s);
    try std.testing.expectEqual(@as(u8, 0), data[0]);
    str_free(s);
}

test "str_data null handle returns empty" {
    const data = str_data(null);
    try std.testing.expectEqual(@as(u8, 0), data[0]);
}

test "str_append sets error on null handle" {
    str_append(null, "test", 4);
    try std.testing.expectEqual(@as(c_int, 4), str_last_error());
}

test "str_insert sets error on null handle" {
    str_insert(null, 0, "test", 4);
    try std.testing.expectEqual(@as(c_int, 4), str_last_error());
}

test "error enum values" {
    try std.testing.expectEqual(@as(c_int, 0), @intFromEnum(StrError.none));
    try std.testing.expectEqual(@as(c_int, 1), @intFromEnum(StrError.out_of_memory));
    try std.testing.expectEqual(@as(c_int, 2), @intFromEnum(StrError.invalid_utf8));
    try std.testing.expectEqual(@as(c_int, 3), @intFromEnum(StrError.index_out_of_bounds));
    try std.testing.expectEqual(@as(c_int, 4), @intFromEnum(StrError.null_handle));
    try std.testing.expectEqual(@as(c_int, 5), @intFromEnum(StrError.invalid_argument));
}

test "cpCount cache works" {
    const s = str_from("Hello", 5);
    try std.testing.expectEqual(@as(usize, 5), str_count(s));
    try std.testing.expectEqual(@as(usize, 5), str_count(s));
    str_free(s);
}

test "cpCount cache invalidated on append" {
    const s = str_from("Hi", 2);
    try std.testing.expectEqual(@as(usize, 2), str_count(s));
    str_append(s, " there", 6);
    try std.testing.expectEqual(@as(usize, 8), str_count(s));
    str_free(s);
}

test "isAllAscii helper" {
    try std.testing.expect(isAllAscii("Hello World"));
    try std.testing.expect(!isAllAscii("\xc3\xa9"));
    try std.testing.expect(isAllAscii(""));
    try std.testing.expect(!isAllAscii("Hi\xf0\x9f\x98\x80"));
}

// The four cases above are all shorter than one vector, so they exercise
// ONLY the scalar tail -- they would pass against a completely broken
// vector loop. These cover the loop itself, and the seam between the two.
test "isAllAscii crosses the vector boundary" {
    const W = std.simd.suggestVectorLength(u8) orelse 1;
    var buf: [512]u8 = undefined;

    // Every length from empty to well past several vectors, all-ASCII.
    for (0..buf.len) |n| {
        @memset(buf[0..n], 'a');
        try std.testing.expect(isAllAscii(buf[0..n]));
    }

    // One non-ASCII byte, walked through EVERY position of a buffer that
    // spans multiple full vectors plus a partial tail. This is the test
    // that fails if a lane is dropped, a bound is off by one, or the tail
    // is skipped -- a single missed position is a silently wrong answer.
    const n = W * 3 + 5;
    for (0..n) |bad| {
        @memset(buf[0..n], 'a');
        buf[bad] = 0x80; // lowest byte that must be rejected
        try std.testing.expect(!isAllAscii(buf[0..n]));
        buf[bad] = 0xFF; // highest
        try std.testing.expect(!isAllAscii(buf[0..n]));
        buf[bad] = 0x7F; // highest byte that must still be ACCEPTED
        try std.testing.expect(isAllAscii(buf[0..n]));
    }

    // Exact multiples: no tail at all, so the loop must decide alone.
    for ([_]usize{ W, W * 2, W * 4 }) |exact| {
        @memset(buf[0..exact], 'a');
        try std.testing.expect(isAllAscii(buf[0..exact]));
        buf[exact - 1] = 0x80; // last lane of the last vector
        try std.testing.expect(!isAllAscii(buf[0..exact]));
    }
}

// The vector count and the sequential walk must agree on every valid
// input. Asserting a hand-counted number would only prove the vector
// form self-consistent; comparing against the implementation it REPLACED
// is what makes this a regression test rather than a restatement.
test "utf8CodepointCount agrees with the scalar walk it replaced" {
    const samples = [_][]const u8{
        "", // empty
        "a", // 1-byte, below a vector
        "hello world", // pure ASCII, below a vector
        "\u{00e9}", // 2-byte alone
        "\u{4e16}\u{754c}", // 3-byte CJK
        "\u{1f600}", // 4-byte emoji
        "caf\u{00e9} na\u{00ef}ve r\u{00e9}sum\u{00e9}", // Latin-1 mix
        "\u{0645}\u{0631}\u{062d}\u{0628}\u{0627} \u{0628}\u{0627}\u{0644}\u{0639}\u{0627}\u{0644}\u{0645}", // Arabic
        "\u{05e9}\u{05dc}\u{05d5}\u{05dd} \u{05e2}\u{05d5}\u{05dc}\u{05dd}", // Hebrew
        "\u{4f60}\u{597d}\u{4e16}\u{754c}\u{ff01}", // CJK + fullwidth
        "\u{1f600}\u{1f601}\u{1f602}\u{1f603}", // all 4-byte
    };
    for (samples) |s| {
        try std.testing.expectEqual(utf8CodepointCountScalar(s), utf8CodepointCount(s));
    }

    // Long inputs: the vector loop only engages past W bytes, and the
    // interesting failures are at the seam, so slide a multibyte
    // sequence across every offset of a buffer spanning several vectors.
    const W = std.simd.suggestVectorLength(u8) orelse 1;
    var buf: [256]u8 = undefined;
    const n = W * 3 + 7;
    const multi = [_][]const u8{ "\u{00e9}", "\u{4e16}", "\u{1f600}" };
    for (multi) |seq| {
        var at: usize = 0;
        while (at + seq.len <= n) : (at += 1) {
            @memset(buf[0..n], 'x');
            @memcpy(buf[at..][0..seq.len], seq);
            const slice = buf[0..n];
            // Only compare where the splice left VALID utf-8 (it can cut
            // a previous sequence); the two forms are only contracted to
            // agree on valid input.
            if (!std.unicode.utf8ValidateSlice(slice)) continue;
            try std.testing.expectEqual(
                utf8CodepointCountScalar(slice),
                utf8CodepointCount(slice),
            );
        }
    }
}

test "BMH search basic" {
    const hay = "The quick brown fox jumps over the lazy dog";
    try std.testing.expectEqual(@as(?usize, 16), bmhSearch(hay, "fox j", 0));
    try std.testing.expectEqual(@as(?usize, 31), bmhSearch(hay, "the lazy", 0));
    try std.testing.expect(bmhSearch(hay, "cat jumps", 0) == null);
}

test "BMH search with start offset" {
    const hay = "abcdef abcdef abcdef";
    try std.testing.expectEqual(@as(?usize, 0), bmhSearch(hay, "abcdef", 0));
    try std.testing.expectEqual(@as(?usize, 7), bmhSearch(hay, "abcdef", 1));
    try std.testing.expectEqual(@as(?usize, 14), bmhSearch(hay, "abcdef", 8));
}

test "cpCount ASCII fast-path" {
    const s = str_from("Hello World!", 12);
    try std.testing.expectEqual(@as(usize, 12), str_count(s));
    str_free(s);
}

test "cpCount multi-byte correct" {
    const s = str_from("caf\xc3\xa9!", 6);
    try std.testing.expectEqual(@as(usize, 5), str_count(s));
    try std.testing.expectEqual(@as(usize, 6), str_size(s));
    str_free(s);
}
