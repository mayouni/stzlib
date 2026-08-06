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
    ///
    /// The cache only helps SEQUENTIAL access. Ring rebuilds the handle per
    /// call (`StzEngineString(...)` then free), so for the slicing family it
    /// starts cold every time and every call walked the whole prefix:
    /// StzMid at codepoint 150,000 of a 180 KB ASCII string cost 0.134 ms,
    /// essentially all of it in this loop.
    ///
    /// Two paths now short-circuit that.
    pub fn cpToByteCached(self: *StzString, cp_index: usize) ?usize {
        const src = self.data.items;
        if (src.len == 0) return if (cp_index == 0) @as(?usize, 0) else null;

        // ASCII: one byte per codepoint, so the answer IS the index -- O(1)
        // instead of O(position), and no walk at all. isAscii() is cached on
        // the handle, so this costs one scan of the buffer per handle rather
        // than one per lookup. The free function beside this one
        // (codepointIndexToByteOffset) has always had this check; the cached
        // METHOD did not, which is the whole bug: two spellings, one gate.
        if (self.isAscii()) {
            return if (cp_index <= src.len) cp_index else null;
        }

        var pos: usize = 0;
        var cp: usize = 0;
        if (cp_index >= self.cached_cp_pos) {
            pos = self.cached_byte_pos;
            cp = self.cached_cp_pos;
        }

        // Multibyte: skip whole vector blocks. The walk's stride is
        // data-dependent, but the COUNT is not -- a codepoint is exactly one
        // non-continuation byte, so a block of W bytes advances cp by the
        // number of lead bytes in it, which every lane can judge at once. We
        // only descend into the block that actually contains the target.
        const W = std.simd.suggestVectorLength(u8) orelse 1;
        if (W > 1) {
            const Vec = @Vector(W, u8);
            const top2: Vec = @splat(0xC0);
            const cont: Vec = @splat(0x80);
            const one: Vec = @splat(1);
            const zero: Vec = @splat(0);
            while (pos + W <= src.len) {
                const v: Vec = src[pos..][0..W].*;
                const leads = @reduce(.Add, @select(u8, (v & top2) != cont, one, zero));
                // The block holds codepoints cp .. cp+leads-1, so the target
                // is inside it exactly when cp_index < cp + leads.
                if (cp + leads > cp_index) break;
                cp += leads;
                pos += W;
            }
            // A block boundary can fall INSIDE a codepoint. Its lead byte was
            // already counted, so step over the remaining continuation bytes
            // WITHOUT counting again -- otherwise the scalar walk below would
            // read a continuation byte as a fresh codepoint.
            while (pos < src.len and (src[pos] & 0xC0) == 0x80) pos += 1;
        }

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
        // Was a second, byte-at-a-time copy of isAllAscii. Two spellings
        // of one predicate meant vectorising the free function left this
        // one scalar -- so it delegates now rather than agreeing by
        // convention.
        const ascii = isAllAscii(self.data.items);
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

/// Byte-wise ASCII case transform of `src` into `dst` (same length).
///
/// The callers' hand-rolled `for (src, 0..) |b, i|` loops carried a
/// comment saying they "auto-vectorize". MEASURED, that is true at size
/// and false where it matters:
///
///     64 B      auto  8.67 ms   explicit  0.55 ms   15.8x
///      4 KB     auto  0.51 ms   explicit  0.52 ms   0.99x
///      1 MB     auto  0.63 ms   explicit  0.64 ms   0.98x
///
/// LLVM's vectorised loop carries a runtime trip-count guard, so short
/// buffers fall through to the scalar path -- and short strings are this
/// library's common case. Explicit is 15x there and a wash at size, so
/// it wins on the distribution rather than on the benchmark's tail.
/// Recorded because "the compiler will vectorise it" is a claim, and
/// this one was only half right.
pub fn asciiCaseInto(src: []const u8, dst: []u8, comptime to_upper: bool) void {
    const lo: u8 = if (to_upper) 'a' else 'A';
    const hi: u8 = if (to_upper) 'z' else 'Z';

    const W = std.simd.suggestVectorLength(u8) orelse {
        for (src, 0..) |b, i| {
            dst[i] = if (b >= lo and b <= hi) (if (to_upper) b - 32 else b + 32) else b;
        }
        return;
    };
    const Vec = @Vector(W, u8);
    const vlo: Vec = @splat(lo);
    const vhi: Vec = @splat(hi);
    const delta: Vec = @splat(32);
    const zero: Vec = @splat(0);

    var i: usize = 0;
    while (i + W <= src.len) : (i += W) {
        const v: Vec = src[i..][0..W].*;
        const in_range = (v >= vlo) & (v <= vhi);
        const adj = @select(u8, in_range, delta, zero);
        dst[i..][0..W].* = if (to_upper) v - adj else v + adj;
    }
    while (i < src.len) : (i += 1) {
        const b = src[i];
        dst[i] = if (b >= lo and b <= hi) (if (to_upper) b - 32 else b + 32) else b;
    }
}

/// First occurrence of `needle` in `haystack` at or after `start`.
///
/// THE NAME IS HISTORICAL -- this is no longer Boyer-Moore-Horspool. It
/// is kept because twelve call sites across core.zig and find.zig reach
/// it, and they all wanted "find the needle", not "find it by BMH".
///
/// BMH's bad-character table costs 256 stores PER CALL, before a single
/// byte of haystack is examined. For a 1-byte needle the table is built
/// and then never consulted, which is why that case measured worst:
///
///     haystack 1 MB, needle absent (worst case, full scan)
///        ","                    64.14 ms  ->   0.33 ms   194x
///        "fox"                  27.58 ms  ->   0.92 ms    30x
///        "quick brown"           7.54 ms  ->   1.40 ms   5.4x
///        34-byte needle          3.33 ms  ->   0.74 ms   4.5x
///
/// The replacement compares the needle's FIRST and LAST byte against a
/// whole vector of candidate offsets at once. An offset survives only if
/// both match, which for real text rejects almost everything without
/// touching the middle bytes; survivors are confirmed with a memcmp.
/// Order is preserved because within a block the survivor bitmask is
/// consumed lowest-bit-first, so the FIRST match still wins.
///
/// Zig's std.mem.indexOfPos was measured too: it wins the 1-byte case
/// (it is memchr) but LOSES to plain BMH on "fox" (35.96 ms vs 26.69).
/// Delegating wholesale would have made a common case slower -- which is
/// why all three were measured rather than two.
pub fn bmhSearch(haystack: []const u8, needle: []const u8, start: usize) ?usize {
    const n = needle.len;
    const h = haystack.len;
    if (n == 0 or n > h or start + n > h) return null;

    // One byte: this IS memchr, and nothing beats it.
    if (n == 1) return mem.indexOfScalarPos(u8, haystack, start, needle[0]);

    const W = std.simd.suggestVectorLength(u8) orelse return bmhSearchScalar(haystack, needle, start);
    const Vec = @Vector(W, u8);
    const first: Vec = @splat(needle[0]);
    const last: Vec = @splat(needle[n - 1]);

    var pos: usize = start;
    const limit = h - n; // last offset a match could start at
    // `pos + W <= limit + 1` keeps the LAST-byte load in bounds too:
    // it expands to pos + n - 1 + W <= h, which is exactly the end of
    // the second vector read below.
    while (pos + W <= limit + 1) {
        const blk_first: Vec = haystack[pos..][0..W].*;
        const blk_last: Vec = haystack[pos + n - 1 ..][0..W].*;
        const eq = (blk_first == first) & (blk_last == last);
        var bits: std.meta.Int(.unsigned, W) = @bitCast(eq);
        while (bits != 0) {
            const at = pos + @ctz(bits);
            if (mem.eql(u8, haystack[at..][0..n], needle)) return at;
            bits &= bits - 1; // clear lowest set bit, take the next candidate
        }
        pos += W;
    }
    while (pos <= limit) : (pos += 1) {
        if (mem.eql(u8, haystack[pos..][0..n], needle)) return pos;
    }
    return null;
}

pub fn asciiLower(b: u8) u8 {
    return if (b >= 'A' and b <= 'Z') b | 0x20 else b;
}

/// `a` equals `b_lower` ignoring ASCII case. `b_lower` must ALREADY be lower.
pub fn ciEqlAscii(a: []const u8, b_lower: []const u8) bool {
    if (a.len != b_lower.len) return false;
    for (a, b_lower) |x, y| {
        if (asciiLower(x) != y) return false;
    }
    return true;
}

/// Case-insensitive search over ASCII text, WITHOUT materialising a folded
/// copy of the haystack. `needle_lower` must already be lowercased.
///
/// The case-insensitive find paths all began by casefolding the whole
/// haystack through utf8proc -- an allocation and a full transform on EVERY
/// call, because Ring rebuilds the handle each time so nothing can be cached
/// across calls. Measured at 180 KB: casefold 4.76 ms of a 6.04 ms
/// case-insensitive find, i.e. 79% of the work was preparing to search
/// rather than searching.
///
/// For ASCII, that preparation is pure waste: casefolding ASCII is exactly
/// lowercasing, so the folded text is the same LENGTH and every position maps
/// 1:1 -- the fold could only ever have changed which bytes were compared,
/// which is something a comparison can do by itself. So this lowercases each
/// candidate block IN REGISTERS as it scans, and never writes a second
/// haystack anywhere.
///
/// Same first/last-byte candidate filter as bmhSearch, with both the loaded
/// blocks lowered before comparing. Non-ASCII input still goes the utf8proc
/// route -- there, folding genuinely can change length (SS -> ss) and the
/// position mapping with it.
pub fn bmhSearchCiAscii(haystack: []const u8, needle_lower: []const u8, start: usize) ?usize {
    const n = needle_lower.len;
    const h = haystack.len;
    if (n == 0 or n > h or start + n > h) return null;

    const W = std.simd.suggestVectorLength(u8) orelse {
        var p = start;
        while (p + n <= h) : (p += 1) {
            if (ciEqlAscii(haystack[p..][0..n], needle_lower)) return p;
        }
        return null;
    };
    const Vec = @Vector(W, u8);
    const first: Vec = @splat(needle_lower[0]);
    const last: Vec = @splat(needle_lower[n - 1]);
    const up_a: Vec = @splat('A');
    const up_z: Vec = @splat('Z');
    const case_bit: Vec = @splat(0x20);
    const zero: Vec = @splat(0);

    var pos: usize = start;
    const limit = h - n;
    while (pos + W <= limit + 1) {
        const bf: Vec = haystack[pos..][0..W].*;
        const bl: Vec = haystack[pos + n - 1 ..][0..W].*;
        // Set bit 5 only on A-Z. Doing it unconditionally would also alter
        // '@' -> '`' and the other punctuation adjacent to the letter range.
        const lf = bf | @select(u8, (bf >= up_a) & (bf <= up_z), case_bit, zero);
        const ll = bl | @select(u8, (bl >= up_a) & (bl <= up_z), case_bit, zero);
        const eq = (lf == first) & (ll == last);
        var bits: std.meta.Int(.unsigned, W) = @bitCast(eq);
        while (bits != 0) {
            const at = pos + @ctz(bits);
            if (ciEqlAscii(haystack[at..][0..n], needle_lower)) return at;
            bits &= bits - 1;
        }
        pos += W;
    }
    while (pos <= limit) : (pos += 1) {
        if (ciEqlAscii(haystack[pos..][0..n], needle_lower)) return pos;
    }
    return null;
}

/// The Boyer-Moore-Horspool implementation this replaced. Kept as the
/// reference the vector form is differential-tested against, and as the
/// fallback on targets without vectors.
pub fn bmhSearchScalar(haystack: []const u8, needle: []const u8, start: usize) ?usize {
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

// The reference cpToByteCached replaced: a plain sequential walk from byte 0,
// no cache, no lane skipping. Kept in the test only -- the point is to have
// something OBVIOUSLY right to compare against.
fn cpToByteReference(src: []const u8, cp_index: usize) ?usize {
    if (src.len == 0) return if (cp_index == 0) @as(?usize, 0) else null;
    var pos: usize = 0;
    var cp: usize = 0;
    while (pos < src.len and cp < cp_index) {
        pos += std.unicode.utf8ByteSequenceLength(src[pos]) catch 1;
        cp += 1;
    }
    return if (cp == cp_index) pos else null;
}

// The block skip can land a boundary INSIDE a codepoint, and the cache means
// the answer depends on the ORDER of previous calls. Both are invisible to a
// test that asks for one index of one string, so this asks for every index of
// several strings, in several orders.
test "cpToByteCached agrees with a plain walk, at every index and in any order" {
    const samples = [_][]const u8{
        "",
        "a",
        "hello world, a plain ascii string long enough to span vectors ok",
        "caf\u{00e9} na\u{00ef}ve r\u{00e9}sum\u{00e9} caf\u{00e9} na\u{00ef}ve r\u{00e9}sum\u{00e9}",
        "\u{4f60}\u{597d}\u{4e16}\u{754c}\u{ff01}\u{4f60}\u{597d}\u{4e16}\u{754c}\u{ff01}\u{4f60}\u{597d}",
        "\u{1f600}\u{1f601}\u{1f602}\u{1f603}\u{1f604}\u{1f605}\u{1f606}\u{1f607}\u{1f608}\u{1f609}",
        // Leading ASCII then multibyte, so a 32-byte boundary lands mid
        // sequence -- the case the continuation-skip exists for.
        "a\u{00e9}\u{00e9}\u{00e9}\u{00e9}\u{00e9}\u{00e9}\u{00e9}\u{00e9}\u{00e9}\u{00e9}\u{00e9}\u{00e9}\u{00e9}\u{00e9}\u{00e9}\u{00e9}\u{00e9}\u{00e9}\u{00e9}",
        "abc\u{4e16}def\u{1f600}ghi\u{00e9}jkl\u{4e16}mno\u{1f600}pqr\u{00e9}stu\u{4e16}vwx\u{1f600}yz",
    };

    for (samples) |sample| {
        const n_cp = utf8CodepointCountScalar(sample);

        // ASCENDING -- the sequential pattern the cache was built for.
        {
            const h = str_from(sample.ptr, sample.len) orelse return error.Unexpected;
            defer str_free(h);
            var i: usize = 0;
            while (i <= n_cp + 2) : (i += 1) {
                try std.testing.expectEqual(cpToByteReference(sample, i), h.cpToByteCached(i));
            }
        }

        // DESCENDING -- forces the "target is before the cache" path on every
        // call, which the ascending order never touches.
        {
            const h = str_from(sample.ptr, sample.len) orelse return error.Unexpected;
            defer str_free(h);
            var i: usize = n_cp + 2;
            while (true) : (i -= 1) {
                try std.testing.expectEqual(cpToByteReference(sample, i), h.cpToByteCached(i));
                if (i == 0) break;
            }
        }

        // JUMPING -- alternating far/near, so the cache is neither reliably
        // ahead nor behind. A cache bug that survives both orders above will
        // not survive this.
        {
            const h = str_from(sample.ptr, sample.len) orelse return error.Unexpected;
            defer str_free(h);
            var k: usize = 0;
            while (k <= n_cp) : (k += 1) {
                const lo = k;
                const hi = n_cp - k;
                try std.testing.expectEqual(cpToByteReference(sample, hi), h.cpToByteCached(hi));
                try std.testing.expectEqual(cpToByteReference(sample, lo), h.cpToByteCached(lo));
                if (hi <= lo) break;
            }
        }
    }
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

// Pinned against the exact byte loop this replaced. The interesting bytes
// are the ones just OUTSIDE the a-z / A-Z ranges -- '@' '[' '`' '{' sit
// adjacent to them, and an inclusive/exclusive slip in the lane compare
// would corrupt them while leaving letters correct.
test "asciiCaseInto matches the byte loop it replaced" {
    var src: [300]u8 = undefined;
    var got: [300]u8 = undefined;
    var want: [300]u8 = undefined;

    for (0..src.len) |n| {
        // Every byte value cycles through, so the range edges are hit at
        // many different lane positions as n grows past the vector width.
        for (0..n) |i| src[i] = @intCast((i * 7 + n) % 256);

        asciiCaseInto(src[0..n], got[0..n], true);
        for (src[0..n], 0..) |b, i| want[i] = if (b >= 'a' and b <= 'z') b - 32 else b;
        try std.testing.expectEqualSlices(u8, want[0..n], got[0..n]);

        asciiCaseInto(src[0..n], got[0..n], false);
        for (src[0..n], 0..) |b, i| want[i] = if (b >= 'A' and b <= 'Z') b + 32 else b;
        try std.testing.expectEqualSlices(u8, want[0..n], got[0..n]);
    }

    // Explicit boundary bytes, so a failure names the culprit directly.
    const edges = "@AZ[`az{09 ~\x7f";
    var e_got: [16]u8 = undefined;
    asciiCaseInto(edges, e_got[0..edges.len], true);
    try std.testing.expectEqualSlices(u8, "@AZ[`AZ{09 ~\x7f", e_got[0..edges.len]);
    asciiCaseInto(edges, e_got[0..edges.len], false);
    try std.testing.expectEqualSlices(u8, "@az[`az{09 ~\x7f", e_got[0..edges.len]);
}

// The vector search must return the SAME offset as the BMH it replaced --
// not merely "an offset where the needle occurs". First-match semantics
// are what twelve call sites depend on, and a block-at-a-time scanner can
// break them by reporting a later candidate from the same block, so the
// survivor mask is consumed lowest-bit-first. This pins that.
test "vector search agrees with BMH at every offset" {
    var buf: [512]u8 = undefined;
    const needles = [_][]const u8{
        ",", // 1 byte -> the memchr path
        "ab", // 2 bytes: first and last byte are the whole needle
        "aa", // repeated bytes
        "fox",
        "quick brown",
        "aaaaaaaa", // pathological: every offset is a candidate
        "not present anywhere at all",
    };
    const bodies = [_][]const u8{
        "the quick brown fox, and the quick brown fox again",
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaab",
        "ab ab ab ab ab ab ab ab ab ab ab ab ab ab ab ab ab",
        ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,",
    };

    for (bodies) |body| {
        var at: usize = 0;
        // Slide the body through a filler buffer so matches land before,
        // inside, and after the first vector block, and across its seam.
        while (at + body.len <= buf.len) : (at += 3) {
            @memset(&buf, 'z');
            @memcpy(buf[at..][0..body.len], body);
            const hay = buf[0 .. at + body.len];
            for (needles) |ndl| {
                // and from several start offsets, since find-from is a
                // first-class operation here
                for ([_]usize{ 0, 1, 7, 31, 32, 33 }) |st| {
                    if (st > hay.len) continue;
                    try std.testing.expectEqual(
                        bmhSearchScalar(hay, ndl, st),
                        bmhSearch(hay, ndl, st),
                    );
                }
            }
        }
    }

    // Degenerate shapes both forms must agree on.
    try std.testing.expectEqual(bmhSearchScalar("", "a", 0), bmhSearch("", "a", 0));
    try std.testing.expectEqual(bmhSearchScalar("abc", "", 0), bmhSearch("abc", "", 0));
    try std.testing.expectEqual(bmhSearchScalar("abc", "abcd", 0), bmhSearch("abc", "abcd", 0));
    try std.testing.expectEqual(bmhSearchScalar("abc", "abc", 0), bmhSearch("abc", "abc", 0));
    try std.testing.expectEqual(bmhSearchScalar("abc", "c", 2), bmhSearch("abc", "c", 2));
    try std.testing.expectEqual(bmhSearchScalar("abc", "a", 3), bmhSearch("abc", "a", 3));
}

// The ASCII case-insensitive path skips utf8proc entirely, so it has to be
// pinned against the thing it replaced: lowercase BOTH sides, then do an
// ordinary search. If the two ever disagree, the fast path is not a fast
// path, it is a different function.
//
// The bytes that matter are the ones ADJACENT to the letter ranges: '@' is
// 'A'-1, '[' is 'Z'+1, '`' is 'a'-1, '{' is 'z'+1. Setting bit 5
// unconditionally -- the obvious way to lowercase -- corrupts exactly those,
// and leaves every letter correct, so a test using only words would pass.
test "ASCII case-insensitive search agrees with fold-then-search" {
    const bodies = [_][]const u8{
        "Fox in a BOX, fOx on a RoCk, FOX by the dock",
        "@AZ[`az{ @az[`AZ{ @AZ[`az{ @az[`AZ{ @AZ[`az{ @az[`AZ{",
        "aAaAaAaAaAaAaAaAaAaAaAaAaAaAaAaAaAaAaAaAaAaAaAaAaA",
        "0123456789 ~!#$%^&*()_+-= 0123456789 ~!#$%^&*()_+-=",
        "The Quick Brown Fox Jumps Over The Lazy Dog Repeatedly And Often",
        "",
        "A",
    };
    const needles = [_][]const u8{
        "fox", "FOX", "FoX", "a", "A", "aa", "AA", "@az[", "[`AZ{",
        "the quick", "THE QUICK", "zzz", "0123", "~!#",
    };

    var lower_hay: [128]u8 = undefined;
    var lower_ndl: [128]u8 = undefined;

    for (bodies) |body| {
        if (body.len > lower_hay.len) continue;
        for (body, 0..) |b, i| lower_hay[i] = asciiLower(b);

        for (needles) |ndl| {
            if (ndl.len > lower_ndl.len) continue;
            for (ndl, 0..) |b, i| lower_ndl[i] = asciiLower(b);

            // Every start offset, since the vector loop and its scalar tail
            // split differently depending on where the search begins.
            var start: usize = 0;
            while (start <= body.len) : (start += 1) {
                const expected = bmhSearch(lower_hay[0..body.len], lower_ndl[0..ndl.len], start);
                const got = bmhSearchCiAscii(body, lower_ndl[0..ndl.len], start);
                try std.testing.expectEqual(expected, got);
            }
        }
    }
}

test "ciEqlAscii is case-blind for letters and exact for everything else" {
    try std.testing.expect(ciEqlAscii("FoX", "fox"));
    try std.testing.expect(ciEqlAscii("fox", "fox"));
    try std.testing.expect(!ciEqlAscii("fo", "fox"));
    // The adjacent-byte cases again, this time on the verifier rather than
    // the scanner: '@' and '`' differ ONLY in bit 5, so a naive `| 0x20`
    // comparison would call them equal.
    try std.testing.expect(!ciEqlAscii("@", "`"));
    try std.testing.expect(!ciEqlAscii("[", "{"));
    try std.testing.expect(ciEqlAscii("A", "a"));
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
