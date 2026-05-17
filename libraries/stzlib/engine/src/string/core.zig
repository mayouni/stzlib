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

pub const INDEX_BASE: c_int = 1;

pub fn toInternal(pos: i64) usize {
    const adjusted = pos - INDEX_BASE;
    return if (adjusted < 0) 0 else @intCast(adjusted);
}

pub fn toExternal(pos: usize) i64 {
    return @as(i64, @intCast(pos)) + INDEX_BASE;
}

// ─── Core Types ───

pub const StzStringHandle = ?*StzString;

pub const StzString = struct {
    data: std.ArrayList(u8),
    cached_cp_count: ?usize = null,
    cached_is_ascii: ?bool = null,

    pub fn init() StzString {
        return .{ .data = .{}, .cached_cp_count = null, .cached_is_ascii = null };
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

pub fn toLowerAscii(c: u8) u8 {
    return if (c >= 'A' and c <= 'Z') c + 32 else c;
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

pub fn utf8CodepointCount(bytes: []const u8) usize {
    if (isAllAscii(bytes)) return bytes.len;
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

pub fn isAllAscii(bytes: []const u8) bool {
    for (bytes) |b| {
        if (b >= 128) return false;
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
