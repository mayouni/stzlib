// Softanza Engine -- String Find/Search/Match (Phase D)
//
// Index-of, find-all, contains, starts/ends-with, equals,
// count-of operations extracted from string.zig.
// All functions use C calling convention.

const std = @import("std");
const core = @import("core.zig");
const mem = core.mem;
const gpa = core.gpa;
const unicode = core.unicode;
const StzString = core.StzString;
const StzStringHandle = core.StzStringHandle;
const StzFindResult = core.StzFindResult;
const StzFindResultHandle = core.StzFindResultHandle;
const INDEX_BASE = core.INDEX_BASE;
const toInternal = core.toInternal;
const toExternal = core.toExternal;
const casefoldAlloc = core.casefoldAlloc;
const ciEqlUnicode = core.ciEqlUnicode;
const ciMatch = core.ciMatch;
const bmhSearch = core.bmhSearch;
const decodeCodepoint = core.decodeCodepoint;
const byteOffsetToCodepointIndex = core.byteOffsetToCodepointIndex;
const str_new = core.str_new;
const str_from = core.str_from;

// ─── FindFirst (Softanza convention: base verb = ALL, first/last/nth for specific) ───

pub fn str_find_first_cs(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize, case: c_int) callconv(.c) i64 {
    if (case == 0) return str_find_first_from_cs(handle, needle, needle_len, @intCast(INDEX_BASE), 0);
    if (handle) |s| {
        if (needle == null or needle_len == 0) return -1;
        const hay = s.slice();
        const n = needle[0..needle_len];

        // ASCII + BMH fast-path: byte pos == cp pos
        if (s.isAscii() and n.len > 4) {
            if (bmhSearch(hay, n, 0)) |byte_pos| {
                return toExternal(byte_pos);
            }
            return -1;
        }

        var byte_pos: usize = 0;
        var cp_pos: usize = 0;
        while (byte_pos + n.len <= hay.len) {
            if (mem.eql(u8, hay[byte_pos..][0..n.len], n)) {
                return toExternal(cp_pos);
            }
            const cp_len = std.unicode.utf8ByteSequenceLength(hay[byte_pos]) catch 1;
            byte_pos += cp_len;
            cp_pos += 1;
        }
    }
    return -1;
}

pub fn str_find_first(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize) callconv(.c) i64 {
    return str_find_first_cs(handle, needle, needle_len, 1);
}

/// FindFirst from a starting position, with case sensitivity parameter.
pub fn str_find_first_from_cs(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize, start_cp: usize, case: c_int) callconv(.c) i64 {
    if (handle) |s| {
        if (needle == null or needle_len == 0) return -1;
        const hay = s.slice();
        const n = needle[0..needle_len];
        const internal_start = toInternal(@intCast(start_cp));

        if (case == 0) {
            // Case-insensitive
            const hay_folded = casefoldAlloc(hay) orelse return -1;
            defer gpa.free(hay_folded);
            const n_folded = casefoldAlloc(n) orelse return -1;
            defer gpa.free(n_folded);
            var byte_pos: usize = 0;
            var cp_pos: usize = 0;
            while (cp_pos < internal_start and byte_pos < hay_folded.len) {
                const cp_len = std.unicode.utf8ByteSequenceLength(hay_folded[byte_pos]) catch 1;
                byte_pos += cp_len;
                cp_pos += 1;
            }
            if (mem.indexOfPos(u8, hay_folded, byte_pos, n_folded)) |pos| {
                return toExternal(byteOffsetToCodepointIndex(hay_folded, pos));
            }
        } else {
            // Case-sensitive
            var byte_pos: usize = 0;
            var cp_pos: usize = 0;
            while (cp_pos < internal_start and byte_pos < hay.len) {
                const cp_len = std.unicode.utf8ByteSequenceLength(hay[byte_pos]) catch 1;
                byte_pos += cp_len;
                cp_pos += 1;
            }
            while (byte_pos + n.len <= hay.len) {
                if (mem.eql(u8, hay[byte_pos..][0..n.len], n)) {
                    return toExternal(cp_pos);
                }
                const cp_len = std.unicode.utf8ByteSequenceLength(hay[byte_pos]) catch 1;
                byte_pos += cp_len;
                cp_pos += 1;
            }
        }
    }
    return -1;
}

pub fn str_find_first_from(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize, start_cp: usize) callconv(.c) i64 {
    return str_find_first_from_cs(handle, needle, needle_len, start_cp, 1);
}

// ─── Byte to Codepoint position ───

pub fn str_byte_to_cp(handle: StzStringHandle, byte_pos: usize) callconv(.c) i64 {
    if (handle) |s| {
        const result = unicode.stz_unicode_byte_to_cp(s.data.items.ptr, s.data.items.len, @intCast(byte_pos));
        return result;
    }
    return -1;
}

// ─── Count Of ───

pub fn str_count_of(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize) callconv(.c) c_int {
    if (handle) |s| {
        if (needle == null or needle_len == 0) return 0;
        const hay = s.slice();
        const n = needle[0..needle_len];
        var count: c_int = 0;
        var pos: usize = 0;
        while (pos + n.len <= hay.len) {
            if (mem.eql(u8, hay[pos..][0..n.len], n)) {
                count += 1;
                pos += n.len;
            } else {
                pos += 1;
            }
        }
        return count;
    }
    return 0;
}

/// Unified count_of with case sensitivity parameter.
pub fn str_count_of_cs(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize, case: c_int) callconv(.c) c_int {
    if (handle) |s| {
        if (needle == null or needle_len == 0) return 0;
        const hay = s.slice();
        const n = needle[0..needle_len];
        if (case == 0) {
            const hay_folded = casefoldAlloc(hay) orelse return 0;
            defer gpa.free(hay_folded);
            const n_folded = casefoldAlloc(n) orelse return 0;
            defer gpa.free(n_folded);
            var count: c_int = 0;
            var pos: usize = 0;
            while (pos + n_folded.len <= hay_folded.len) {
                if (mem.eql(u8, hay_folded[pos..][0..n_folded.len], n_folded)) {
                    count += 1;
                    pos += n_folded.len;
                } else {
                    pos += 1;
                }
            }
            return count;
        } else {
            return str_count_of(handle, needle, needle_len);
        }
    }
    return 0;
}

// ─── Find (base verb = ALL per Softanza convention) ───

/// Find all occurrences with case sensitivity parameter.
/// case=1: case-sensitive, case=0: case-insensitive (Unicode casefold).
pub fn str_find_cs(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize, case: c_int) callconv(.c) StzFindResultHandle {
    const r = gpa.create(StzFindResult) catch return null;
    r.* = StzFindResult.init();
    if (handle) |s| {
        if (needle == null or needle_len == 0) return r;
        const hay = s.slice();
        const n = needle[0..needle_len];

        if (case == 0) {
            // Case-insensitive: casefold both
            const hay_folded = casefoldAlloc(hay) orelse return r;
            defer gpa.free(hay_folded);
            const n_folded = casefoldAlloc(n) orelse return r;
            defer gpa.free(n_folded);
            var byte_pos: usize = 0;
            var cp_pos: usize = 0;
            while (byte_pos + n_folded.len <= hay_folded.len) {
                if (mem.eql(u8, hay_folded[byte_pos..][0..n_folded.len], n_folded)) {
                    r.positions.append(gpa, toExternal(cp_pos)) catch break;
                }
                const cp_len = std.unicode.utf8ByteSequenceLength(hay_folded[byte_pos]) catch 1;
                byte_pos += cp_len;
                cp_pos += 1;
            }
        } else {
            // Case-sensitive: direct comparison
            var byte_pos: usize = 0;
            var cp_pos: usize = 0;
            while (byte_pos + n.len <= hay.len) {
                if (mem.eql(u8, hay[byte_pos..][0..n.len], n)) {
                    r.positions.append(gpa, toExternal(cp_pos)) catch break;
                }
                const cp_len = std.unicode.utf8ByteSequenceLength(hay[byte_pos]) catch 1;
                byte_pos += cp_len;
                cp_pos += 1;
            }
        }
    }
    return r;
}

pub fn str_find(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize) callconv(.c) StzFindResultHandle {
    return str_find_cs(handle, needle, needle_len, 1);
}

// Codepoint equality with optional case-fold. cs==0 folds each codepoint
// individually (handles multi-cp folds like ß->ss), matching the monolith's
// CharsCSQ(cs) comparison.
fn cpEql(a: []const u8, b: []const u8, cs: c_int) bool {
    if (cs != 0) return mem.eql(u8, a, b);
    const fa = casefoldAlloc(a) orelse return mem.eql(u8, a, b);
    defer gpa.free(fa);
    const fb = casefoldAlloc(b) orelse return mem.eql(u8, a, b);
    defer gpa.free(fb);
    return mem.eql(u8, fa, fb);
}

// 1-based positions of each char equal to the char immediately before it
// (consecutive-duplicate chars). cs==0 compares case-insensitively.
// Ring FindDupSecutiveChars (cs=1) / FindDupSecutiveCharsCS(cs). One pass.
pub fn str_find_dupsecutive_chars(handle: StzStringHandle, cs: c_int) callconv(.c) StzFindResultHandle {
    const r = gpa.create(StzFindResult) catch return null;
    r.* = StzFindResult.init();
    if (handle) |s| {
        const hay = s.slice();
        var byte_pos: usize = 0;
        var cp_idx: usize = 0;
        var prev: []const u8 = &[_]u8{};
        while (byte_pos < hay.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(hay[byte_pos]) catch 1;
            const cur = hay[byte_pos..][0..cp_len];
            if (cp_idx >= 1 and cpEql(cur, prev, cs)) {
                r.positions.append(gpa, toExternal(cp_idx)) catch break;
            }
            prev = cur;
            byte_pos += cp_len;
            cp_idx += 1;
        }
    }
    return r;
}

// 1-based start positions of the SECOND copy in each back-to-back
// identical-substring pair. cs==0 compares case-insensitively. Ring
// FindDupSecutiveSubString (cs=1) / FindDupSecutiveSubStringCS(sub, cs).
// Greedy: on a hit, advance by one substring length; else by one codepoint.
pub fn str_find_dupsecutive_substring(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize, cs: c_int) callconv(.c) StzFindResultHandle {
    const r = gpa.create(StzFindResult) catch return null;
    r.* = StzFindResult.init();
    const s = (handle orelse return r);
    if (needle == null or needle_len == 0) return r;
    const src = s.slice();
    const need = needle[0..needle_len];
    const sublen = utf8CodepointCount(need);
    if (sublen == 0) return r;
    const total = utf8CodepointCount(src);
    if (2 * sublen > total) return r;
    // Optional casefolded needle for cs==0 comparison.
    const need_fold: ?[]u8 = if (cs == 0) casefoldAlloc(need) else null;
    defer if (need_fold) |nf| gpa.free(nf);
    // Codepoint -> byte offset table (offs[total] = src.len).
    const offs = gpa.alloc(usize, total + 1) catch return r;
    defer gpa.free(offs);
    {
        var pos: usize = 0;
        var k: usize = 0;
        while (pos < src.len and k < total) {
            offs[k] = pos;
            const cl = std.unicode.utf8ByteSequenceLength(src[pos]) catch 1;
            pos += cl;
            k += 1;
        }
        offs[total] = src.len;
    }
    var i: usize = 0;
    while (i + 2 * sublen <= total) {
        const first = src[offs[i]..offs[i + sublen]];
        const second = src[offs[i + sublen]..offs[i + 2 * sublen]];
        const hit = if (cs != 0)
            (mem.eql(u8, first, need) and mem.eql(u8, second, need))
        else
            eqlFold(first, need_fold) and eqlFold(second, need_fold);
        if (hit) {
            r.positions.append(gpa, toExternal(i + sublen)) catch break;
            i += sublen;
        } else {
            i += 1;
        }
    }
    return r;
}

// window casefold == precomputed needle fold (null-safe).
fn eqlFold(window: []const u8, need_fold: ?[]u8) bool {
    const nf = need_fold orelse return false;
    const wf = casefoldAlloc(window) orelse return false;
    defer gpa.free(wf);
    return mem.eql(u8, wf, nf);
}

// ─── Find Result Accessors ───

pub fn stz_find_result_count(result: StzFindResultHandle) callconv(.c) c_int {
    if (result) |r| return @intCast(r.positions.items.len);
    return 0;
}

pub fn stz_find_result_get(result: StzFindResultHandle, index: c_int) callconv(.c) i64 {
    if (result) |r| {
        if (index < 1) return -1;
        const i: usize = @intCast(index - 1);
        if (i < r.positions.items.len) return r.positions.items[i];
    }
    return -1;
}

pub fn stz_find_result_free(result: StzFindResultHandle) callconv(.c) void {
    if (result) |r| {
        r.deinit();
        gpa.destroy(r);
    }
}

// ─── FindLast ───

/// Find last occurrence with case sensitivity parameter.
pub fn str_find_last_cs(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize, case: c_int) callconv(.c) i64 {
    if (handle) |s| {
        if (needle == null or needle_len == 0) return -1;
        const hay = s.slice();
        const n = needle[0..needle_len];
        if (case == 0) {
            const hay_folded = casefoldAlloc(hay) orelse return -1;
            defer gpa.free(hay_folded);
            const n_folded = casefoldAlloc(n) orelse return -1;
            defer gpa.free(n_folded);
            if (n_folded.len > hay_folded.len) return -1;
            if (mem.lastIndexOf(u8, hay_folded, n_folded)) |pos| {
                return toExternal(byteOffsetToCodepointIndex(hay_folded, pos));
            }
        } else {
            if (mem.lastIndexOf(u8, hay, n)) |byte_pos| {
                return toExternal(byteOffsetToCodepointIndex(hay, byte_pos));
            }
        }
    }
    return -1;
}

pub fn str_find_last(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize) callconv(.c) i64 {
    return str_find_last_cs(handle, needle, needle_len, 1);
}

// ─── Contains ───

/// Unified contains with case sensitivity parameter.
pub fn str_contains_cs(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize, case: c_int) callconv(.c) c_int {
    return if (str_find_first_cs(handle, needle, needle_len, case) >= 0) 1 else 0;
}

pub fn str_contains(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize) callconv(.c) c_int {
    return str_contains_cs(handle, needle, needle_len, 1);
}

// ─── Starts With ───

/// Unified starts_with with case sensitivity parameter.
pub fn str_starts_with_cs(handle: StzStringHandle, prefix: [*c]const u8, prefix_len: usize, case: c_int) callconv(.c) c_int {
    if (handle) |s| {
        if (prefix == null or prefix_len == 0) return 1;
        const sl = s.slice();
        if (prefix_len > sl.len) return 0;
        if (case == 0) {
            const hay_prefix = casefoldAlloc(sl[0..prefix_len]) orelse return 0;
            defer gpa.free(hay_prefix);
            const pfx_folded = casefoldAlloc(prefix[0..prefix_len]) orelse return 0;
            defer gpa.free(pfx_folded);
            return if (mem.eql(u8, hay_prefix, pfx_folded)) 1 else 0;
        } else {
            return if (mem.eql(u8, sl[0..prefix_len], prefix[0..prefix_len])) 1 else 0;
        }
    }
    return 0;
}

pub fn str_starts_with(handle: StzStringHandle, prefix: [*c]const u8, prefix_len: usize) callconv(.c) c_int {
    return str_starts_with_cs(handle, prefix, prefix_len, 1);
}

// ─── Ends With ───

/// Unified ends_with with case sensitivity parameter.
pub fn str_ends_with_cs(handle: StzStringHandle, suffix: [*c]const u8, suffix_len: usize, case: c_int) callconv(.c) c_int {
    if (handle) |s| {
        if (suffix == null or suffix_len == 0) return 1;
        const sl = s.slice();
        if (suffix_len > sl.len) return 0;
        const start = sl.len - suffix_len;
        if (case == 0) {
            const hay_suffix = casefoldAlloc(sl[start..]) orelse return 0;
            defer gpa.free(hay_suffix);
            const sfx_folded = casefoldAlloc(suffix[0..suffix_len]) orelse return 0;
            defer gpa.free(sfx_folded);
            return if (mem.eql(u8, hay_suffix, sfx_folded)) 1 else 0;
        } else {
            return if (mem.eql(u8, sl[start..], suffix[0..suffix_len])) 1 else 0;
        }
    }
    return 0;
}

pub fn str_ends_with(handle: StzStringHandle, suffix: [*c]const u8, suffix_len: usize) callconv(.c) c_int {
    return str_ends_with_cs(handle, suffix, suffix_len, 1);
}

// ─── Equals ───

pub fn str_equals_cs(h1: StzStringHandle, h2: StzStringHandle, case: c_int) callconv(.c) c_int {
    if (h1) |s1| {
        if (h2) |s2| {
            if (case == 0) return if (ciEqlUnicode(s1.slice(), s2.slice())) 1 else 0;
            return if (mem.eql(u8, s1.slice(), s2.slice())) 1 else 0;
        }
    }
    return 0;
}

pub fn str_equals(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) c_int {
    return str_equals_cs(h1, h2, 1);
}

// ─── Find Nth ───

/// Unified find_nth with case sensitivity parameter.
pub fn str_find_nth_cs(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize, n: c_int, case: c_int) callconv(.c) i64 {
    if (handle) |s| {
        if (n < 1) return -1;
        const hay = s.slice();
        const ndl = needle[0..needle_len];
        if (case == 0) {
            const hay_folded = casefoldAlloc(hay) orelse return -1;
            defer gpa.free(hay_folded);
            const ndl_folded = casefoldAlloc(ndl) orelse return -1;
            defer gpa.free(ndl_folded);
            var occurrence: c_int = 0;
            var byte_pos: usize = 0;
            while (mem.indexOfPos(u8, hay_folded, byte_pos, ndl_folded)) |pos| {
                occurrence += 1;
                if (occurrence == n) {
                    return toExternal(byteOffsetToCodepointIndex(hay_folded, pos));
                }
                byte_pos = pos + 1;
            }
        } else {
            var occurrence: c_int = 0;
            var byte_pos: usize = 0;
            while (mem.indexOfPos(u8, hay, byte_pos, ndl)) |pos| {
                occurrence += 1;
                if (occurrence == n) {
                    return toExternal(byteOffsetToCodepointIndex(hay, pos));
                }
                byte_pos = pos + 1;
            }
        }
    }
    return -1;
}

pub fn str_find_nth(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize, n: c_int) callconv(.c) i64 {
    return str_find_nth_cs(handle, needle, needle_len, n, 1);
}

// ─── Character-level find ───

/// Check if string starts with a digit. Returns 1 or 0.
pub fn str_starts_with_digit(handle: StzStringHandle) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const bytes = s.slice();
    if (bytes.len == 0) return 0;
    const cp_len = std.unicode.utf8ByteSequenceLength(bytes[0]) catch 1;
    const cp_val: i32 = decodeCodepoint(bytes, 0, cp_len);
    return if (unicode.stz_unicode_is_digit(cp_val) != 0) @as(c_int, 1) else @as(c_int, 0);
}

/// Check if string starts with a letter. Returns 1 or 0.
pub fn str_starts_with_letter(handle: StzStringHandle) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const bytes = s.slice();
    if (bytes.len == 0) return 0;
    const cp_len = std.unicode.utf8ByteSequenceLength(bytes[0]) catch 1;
    const cp_val: i32 = decodeCodepoint(bytes, 0, cp_len);
    return if (unicode.stz_unicode_is_letter(cp_val) != 0) @as(c_int, 1) else @as(c_int, 0);
}

/// Check if string ends with a digit. Returns 1 or 0.
pub fn str_ends_with_digit(handle: StzStringHandle) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const bytes = s.slice();
    if (bytes.len == 0) return 0;
    // Walk to last codepoint
    var i: usize = 0;
    var last_cp: i32 = 0;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        last_cp = decodeCodepoint(bytes, i, cp_len);
        i += cp_len;
    }
    return if (unicode.stz_unicode_is_digit(last_cp) != 0) @as(c_int, 1) else @as(c_int, 0);
}

/// Check if string ends with a letter. Returns 1 or 0.
pub fn str_ends_with_letter(handle: StzStringHandle) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const bytes = s.slice();
    if (bytes.len == 0) return 0;
    var i: usize = 0;
    var last_cp: i32 = 0;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        last_cp = decodeCodepoint(bytes, i, cp_len);
        i += cp_len;
    }
    return if (unicode.stz_unicode_is_letter(last_cp) != 0) @as(c_int, 1) else @as(c_int, 0);
}

/// Find all positions of a codepoint (base verb = ALL).
pub fn str_find_char(handle: StzStringHandle, codepoint: u32) callconv(.c) StzFindResultHandle {
    const s = handle orelse return null;
    const buf = s.slice();

    var positions: std.ArrayList(i64) = .{};
    var off: usize = 0;
    var cp_i: i64 = 0;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch break;
        if (cp_val == codepoint) {
            positions.append(gpa, toExternal(@intCast(cp_i))) catch return null;
        }
        off += cp_len;
        cp_i += 1;
    }

    const fr = gpa.create(StzFindResult) catch return null;
    fr.* = .{ .positions = positions };
    return fr;
}

// ─── Starts/Ends With Any ───

/// Check if string starts with any of given prefixes (pipe-separated).
pub export fn str_starts_with_any_cs(handle: ?*StzString, prefixes: [*c]const u8, prefixes_len: c_int, case: c_int) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    const plen: usize = if (prefixes_len >= 0) @intCast(prefixes_len) else return 0;
    const pstr = prefixes[0..plen];

    // Split by pipe and check each
    var start: usize = 0;
    var i: usize = 0;
    while (i <= pstr.len) : (i += 1) {
        if (i == pstr.len or pstr[i] == '|') {
            const prefix = pstr[start..i];
            if (prefix.len > 0 and prefix.len <= src.len) {
                if (case != 0) {
                    if (mem.eql(u8, src[0..prefix.len], prefix)) return 1;
                } else {
                    if (ciMatch(src[0..prefix.len], prefix)) return 1;
                }
            }
            start = i + 1;
        }
    }
    return 0;
}

pub export fn str_starts_with_any(handle: ?*StzString, prefixes: [*c]const u8, prefixes_len: c_int) callconv(.c) c_int {
    return str_starts_with_any_cs(handle, prefixes, prefixes_len, 1);
}

/// Check if string ends with any of given suffixes (pipe-separated).
pub export fn str_ends_with_any_cs(handle: ?*StzString, suffixes: [*c]const u8, suffixes_len: c_int, case: c_int) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    const slen: usize = if (suffixes_len >= 0) @intCast(suffixes_len) else return 0;
    const sstr = suffixes[0..slen];

    var start: usize = 0;
    var i: usize = 0;
    while (i <= sstr.len) : (i += 1) {
        if (i == sstr.len or sstr[i] == '|') {
            const suffix = sstr[start..i];
            if (suffix.len > 0 and suffix.len <= src.len) {
                if (case != 0) {
                    if (mem.eql(u8, src[src.len - suffix.len ..], suffix)) return 1;
                } else {
                    if (ciMatch(src[src.len - suffix.len ..], suffix)) return 1;
                }
            }
            start = i + 1;
        }
    }
    return 0;
}

pub export fn str_ends_with_any(handle: ?*StzString, suffixes: [*c]const u8, suffixes_len: c_int) callconv(.c) c_int {
    return str_ends_with_any_cs(handle, suffixes, suffixes_len, 1);
}

// ─── Duplicate Substrings ───

const codepointIndexToByteOffset = core.codepointIndexToByteOffset;
const utf8CodepointCount = core.utf8CodepointCount;

/// Find all substrings (of any length) that appear more than once.
/// Returns null-delimited list of unique duplicate substrings.
/// case = 1: case-sensitive, case = 0: case-insensitive.
pub fn str_duplicate_substrings_cs(handle: StzStringHandle, case: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return str_new();
    const buf = s.slice();
    if (buf.len == 0) return str_new();

    const n = utf8CodepointCount(buf);
    if (n < 2) return str_new();

    // Build codepoint offset table for O(1) codepoint-to-byte lookups
    var cp_offsets = std.ArrayListUnmanaged(usize){};
    defer cp_offsets.deinit(gpa);
    {
        var off: usize = 0;
        while (off < buf.len) {
            cp_offsets.append(gpa, off) catch return null;
            const seq = std.unicode.utf8ByteSequenceLength(buf[off]) catch 1;
            off += seq;
        }
        cp_offsets.append(gpa, buf.len) catch return null; // sentinel
    }

    // Track seen substrings: key = substring bytes (or casefolded), value = count
    // Also track which originals we've already emitted
    var seen = std.StringHashMap(u8).init(gpa); // 0 = seen once, 1 = emitted
    defer {
        var it = seen.keyIterator();
        while (it.next()) |key| gpa.free(key.*);
        seen.deinit();
    }

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();
    var first = true;

    // Iterate all substrings by codepoint indices
    var i: usize = 0;
    while (i < n) : (i += 1) {
        var j: usize = i + 1;
        while (j <= n) : (j += 1) {
            const byte_start = cp_offsets.items[i];
            const byte_end = cp_offsets.items[j];
            const substr = buf[byte_start..byte_end];

            // Get the comparison key
            const key_slice = if (case == 0) (casefoldAlloc(substr) orelse continue) else (gpa.dupe(u8, substr) catch continue);

            const entry = seen.getOrPut(key_slice) catch {
                gpa.free(key_slice);
                continue;
            };
            if (entry.found_existing) {
                // Already seen — free the duplicate key
                gpa.free(key_slice);
                if (entry.value_ptr.* == 0) {
                    // First duplicate — emit it
                    entry.value_ptr.* = 1;
                    if (!first) {
                        result.data.append(gpa, 0) catch break; // null separator
                    }
                    result.data.appendSlice(gpa, substr) catch break;
                    first = false;
                }
                // Already emitted — skip
            } else {
                // First occurrence
                entry.value_ptr.* = 0;
            }
        }
    }

    return result;
}

// ─── Between ───

/// Extract FIRST substring between open/close delimiters with case sensitivity.
/// For first-only semantics (base verb str_between_cs = ALL per Softanza convention).
pub fn str_between_first_cs(handle: StzStringHandle, start_ptr: [*c]const u8, start_len: usize, end_ptr: [*c]const u8, end_len: usize, case: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (buf.len == 0 or start_len == 0 or end_len == 0) return str_new();

    const start_needle = start_ptr[0..start_len];
    const end_needle = end_ptr[0..end_len];
    const cs = case != 0;

    const start_pos = if (cs)
        (bmhSearch(buf, start_needle, 0) orelse return str_new())
    else blk: {
        const folded_buf = casefoldAlloc(buf) orelse return null;
        defer gpa.free(folded_buf);
        const folded_needle = casefoldAlloc(start_needle) orelse return null;
        defer gpa.free(folded_needle);
        break :blk bmhSearch(folded_buf, folded_needle, 0) orelse return str_new();
    };

    const after_start = start_pos + start_needle.len;
    if (after_start >= buf.len) return str_new();

    const remaining = buf[after_start..];
    const end_pos = if (cs)
        (bmhSearch(remaining, end_needle, 0) orelse return str_new())
    else blk: {
        const folded_rem = casefoldAlloc(remaining) orelse return null;
        defer gpa.free(folded_rem);
        const folded_end = casefoldAlloc(end_needle) orelse return null;
        defer gpa.free(folded_end);
        break :blk bmhSearch(folded_rem, folded_end, 0) orelse return str_new();
    };

    const between = remaining[0..end_pos];
    return str_from(between.ptr, between.len);
}

pub fn str_section_cp(handle: StzStringHandle, start_cp: i64, end_cp: i64) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (buf.len == 0) return str_new();

    const n = utf8CodepointCount(buf);
    const s0 = toInternal(start_cp);
    const e0 = toInternal(end_cp);
    if (s0 >= n or e0 >= n or s0 > e0) return str_new();

    const byte_start = codepointIndexToByteOffset(buf, s0);
    const byte_end_cp = if (e0 + 1 >= n) buf.len else codepointIndexToByteOffset(buf, e0 + 1);

    return str_from(buf[byte_start..byte_end_cp].ptr, byte_end_cp - byte_start);
}

// ─── Tests ───

const testing = std.testing;
const str_free = core.str_free;
const str_data = core.str_data;
const str_size = core.str_size;

test "find_first" {
    const s = str_from("hello world", 11);
    defer str_free(s);
    try testing.expectEqual(@as(i64, 1), str_find_first(s, "hello", 5));
    try testing.expectEqual(@as(i64, 7), str_find_first(s, "world", 5));
    try testing.expectEqual(@as(i64, -1), str_find_first(s, "xyz", 3));
}

test "find_first_cs" {
    const s = str_from("Hello World", 11);
    defer str_free(s);
    // Case sensitive: "hello" not found
    try testing.expectEqual(@as(i64, -1), str_find_first_cs(s, "hello", 5, 1));
    // Case insensitive: "hello" found at 1
    try testing.expectEqual(@as(i64, 1), str_find_first_cs(s, "hello", 5, 0));
}

test "find_first_from" {
    const s = str_from("abcabc", 6);
    defer str_free(s);
    try testing.expectEqual(@as(i64, 4), str_find_first_from(s, "abc", 3, 4));
}

test "byte_to_cp" {
    const s = str_from("abc", 3);
    defer str_free(s);
    try testing.expectEqual(@as(i64, 1), str_byte_to_cp(s, 1));
}

test "count_of" {
    const s = str_from("abcabcabc", 9);
    defer str_free(s);
    try testing.expectEqual(@as(c_int, 3), str_count_of(s, "abc", 3));
}

test "count_of_cs" {
    const s = str_from("AbcABCabc", 9);
    defer str_free(s);
    try testing.expectEqual(@as(c_int, 1), str_count_of_cs(s, "Abc", 3, 1));
    try testing.expectEqual(@as(c_int, 3), str_count_of_cs(s, "abc", 3, 0));
}

test "find" {
    const s = str_from("abcabc", 6);
    defer str_free(s);
    const fr = str_find(s, "abc", 3);
    defer stz_find_result_free(fr);
    try testing.expect(fr != null);
    try testing.expectEqual(@as(c_int, 2), stz_find_result_count(fr));
    try testing.expectEqual(@as(i64, 1), stz_find_result_get(fr, 1));
    try testing.expectEqual(@as(i64, 4), stz_find_result_get(fr, 2));
}

test "find_last" {
    const s = str_from("abcabc", 6);
    defer str_free(s);
    try testing.expectEqual(@as(i64, 4), str_find_last(s, "abc", 3));
}

test "contains" {
    const s = str_from("hello world", 11);
    defer str_free(s);
    try testing.expectEqual(@as(c_int, 1), str_contains(s, "world", 5));
    try testing.expectEqual(@as(c_int, 0), str_contains(s, "xyz", 3));
}

test "contains_cs" {
    const s = str_from("Hello", 5);
    defer str_free(s);
    try testing.expectEqual(@as(c_int, 0), str_contains_cs(s, "hello", 5, 1));
    try testing.expectEqual(@as(c_int, 1), str_contains_cs(s, "hello", 5, 0));
}

test "starts_with" {
    const s = str_from("hello world", 11);
    defer str_free(s);
    try testing.expectEqual(@as(c_int, 1), str_starts_with(s, "hello", 5));
    try testing.expectEqual(@as(c_int, 0), str_starts_with(s, "world", 5));
}

test "ends_with" {
    const s = str_from("hello world", 11);
    defer str_free(s);
    try testing.expectEqual(@as(c_int, 1), str_ends_with(s, "world", 5));
    try testing.expectEqual(@as(c_int, 0), str_ends_with(s, "hello", 5));
}

test "equals" {
    const s1 = str_from("hello", 5);
    defer str_free(s1);
    const s2 = str_from("hello", 5);
    defer str_free(s2);
    const s3 = str_from("Hello", 5);
    defer str_free(s3);
    try testing.expectEqual(@as(c_int, 1), str_equals(s1, s2));
    try testing.expectEqual(@as(c_int, 0), str_equals(s1, s3));
    try testing.expectEqual(@as(c_int, 1), str_equals_cs(s1, s3, 0));
}

test "find_nth" {
    const s = str_from("abcabcabc", 9);
    defer str_free(s);
    try testing.expectEqual(@as(i64, 1), str_find_nth(s, "abc", 3, 1));
    try testing.expectEqual(@as(i64, 4), str_find_nth(s, "abc", 3, 2));
    try testing.expectEqual(@as(i64, 7), str_find_nth(s, "abc", 3, 3));
    try testing.expectEqual(@as(i64, -1), str_find_nth(s, "abc", 3, 4));
}

test "starts_with_digit_letter" {
    const s1 = str_from("123abc", 6);
    defer str_free(s1);
    try testing.expectEqual(@as(c_int, 1), str_starts_with_digit(s1));
    try testing.expectEqual(@as(c_int, 0), str_starts_with_letter(s1));

    const s2 = str_from("abc123", 6);
    defer str_free(s2);
    try testing.expectEqual(@as(c_int, 0), str_starts_with_digit(s2));
    try testing.expectEqual(@as(c_int, 1), str_starts_with_letter(s2));
}

test "ends_with_digit_letter" {
    const s1 = str_from("abc123", 6);
    defer str_free(s1);
    try testing.expectEqual(@as(c_int, 1), str_ends_with_digit(s1));
    try testing.expectEqual(@as(c_int, 0), str_ends_with_letter(s1));
}

test "find_char" {
    const s = str_from("abcabc", 6);
    defer str_free(s);
    const fr = str_find_char(s, 'a');
    defer stz_find_result_free(fr);
    try testing.expect(fr != null);
    try testing.expectEqual(@as(c_int, 2), stz_find_result_count(fr));
    try testing.expectEqual(@as(i64, 1), stz_find_result_get(fr, 1));
    try testing.expectEqual(@as(i64, 4), stz_find_result_get(fr, 2));
}

test "starts_with_any" {
    const s = str_from("hello.zig", 9);
    defer str_free(s);
    try testing.expectEqual(@as(c_int, 1), str_starts_with_any(s, "hello|world", 11));
    try testing.expectEqual(@as(c_int, 0), str_starts_with_any(s, "foo|bar", 7));
}

test "ends_with_any" {
    const s = str_from("hello.zig", 9);
    defer str_free(s);
    try testing.expectEqual(@as(c_int, 1), str_ends_with_any(s, ".txt|.zig", 9));
    try testing.expectEqual(@as(c_int, 0), str_ends_with_any(s, ".md|.rs", 6));
}

test "starts_with_any_cs CI" {
    const s = str_from("Hello.zig", 9);
    defer str_free(s);
    // CS: "hello" won't match "Hello"
    try testing.expectEqual(@as(c_int, 0), str_starts_with_any_cs(s, "hello|world", 11, 1));
    // CI: "hello" matches "Hello"
    try testing.expectEqual(@as(c_int, 1), str_starts_with_any_cs(s, "hello|world", 11, 0));
}

test "ends_with_any_cs CI" {
    const s = str_from("hello.ZIG", 9);
    defer str_free(s);
    // CS: ".zig" won't match ".ZIG"
    try testing.expectEqual(@as(c_int, 0), str_ends_with_any_cs(s, ".txt|.zig", 9, 1));
    // CI: ".zig" matches ".ZIG"
    try testing.expectEqual(@as(c_int, 1), str_ends_with_any_cs(s, ".txt|.zig", 9, 0));
}

test "between_first_cs basic" {
    const s = str_from("<html>content</html>", 20);
    defer str_free(s);
    const r = str_between_first_cs(s, "<html>", 6, "</html>", 7, 1);
    defer str_free(r);
    try testing.expect(r != null);
    const d: [*]const u8 = @ptrCast(str_data(r));
    try testing.expectEqualStrings("content", d[0..str_size(r)]);
}

test "between_first_cs not found" {
    const s = str_from("hello world", 11);
    defer str_free(s);
    const r = str_between_first_cs(s, "[", 1, "]", 1, 1);
    defer str_free(r);
    try testing.expectEqual(@as(usize, 0), str_size(r));
}

test "between_first_cs case insensitive" {
    const s = str_from("START-middle-END", 16);
    defer str_free(s);
    const r = str_between_first_cs(s, "start-", 6, "-end", 4, 0);
    defer str_free(r);
    try testing.expect(r != null);
    const d: [*]const u8 = @ptrCast(str_data(r));
    try testing.expectEqualStrings("middle", d[0..str_size(r)]);
}

test "section_cp basic" {
    const s = str_from("hello world", 11);
    defer str_free(s);
    const r = str_section_cp(s, 1, 5);
    defer str_free(r);
    try testing.expect(r != null);
    const d: [*]const u8 = @ptrCast(str_data(r));
    try testing.expectEqualStrings("hello", d[0..str_size(r)]);
}

test "section_cp middle" {
    const s = str_from("hello world", 11);
    defer str_free(s);
    const r = str_section_cp(s, 7, 11);
    defer str_free(r);
    try testing.expect(r != null);
    const d: [*]const u8 = @ptrCast(str_data(r));
    try testing.expectEqualStrings("world", d[0..str_size(r)]);
}

test "section_cp unicode" {
    const s = str_from("cafe\xCC\x81", 6);
    defer str_free(s);
    const r = str_section_cp(s, 1, 4);
    defer str_free(r);
    try testing.expect(r != null);
    try testing.expectEqual(@as(usize, 4), str_size(r));
}
