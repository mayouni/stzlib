// Softanza Engine -- String Regex Integration (Phase E)
//
// Convenience functions that apply regex operations directly to
// string handles. Internally creates temporary regex handles,
// runs the match, and returns results using standard string types.

const std = @import("std");
const core = @import("core.zig");
const rx = @import("../regex.zig");

const gpa = core.gpa;
const StzString = core.StzString;
const StzStringHandle = core.StzStringHandle;
const StzFindResult = core.StzFindResult;
const StzFindResultHandle = core.StzFindResultHandle;
const toExternal = core.toExternal;
const unicode = core.unicode;
const setError = core.setError;
const str_from = core.str_from;
const byteOffsetToCodepointIndex = core.byteOffsetToCodepointIndex;
const StzStrListResult = core.StzStrListResult;
const StzStrListResultHandle = core.StzStrListResultHandle;

// ─── str_regex_is_match ───
//
// Returns 1 if the string matches the pattern, 0 otherwise.

pub fn str_regex_is_match(handle: StzStringHandle, pat: [*c]const u8, pat_len: usize, flags: u32) callconv(.c) c_int {
    const s = handle orelse return 0;
    const h = rx.stz_regex_new(pat, pat_len, flags) orelse return 0;
    defer rx.stz_regex_free(h);
    const text = s.slice();
    return rx.stz_regex_match(h, text.ptr, text.len, 0);
}

// ─── str_regex_count ───
//
// Returns the number of non-overlapping matches.

pub fn str_regex_count(handle: StzStringHandle, pat: [*c]const u8, pat_len: usize, flags: u32) callconv(.c) c_int {
    const s = handle orelse return 0;
    const h = rx.stz_regex_new(pat, pat_len, flags) orelse return 0;
    defer rx.stz_regex_free(h);
    const text = s.slice();
    return rx.stz_regex_match_all(h, text.ptr, text.len);
}

// ─── str_regex_find_first ───
//
// Returns 1-based codepoint position of first match, 0 if no match.

pub fn str_regex_find_first(handle: StzStringHandle, pat: [*c]const u8, pat_len: usize, flags: u32) callconv(.c) i64 {
    const s = handle orelse return 0;
    const h = rx.stz_regex_new(pat, pat_len, flags) orelse return 0;
    defer rx.stz_regex_free(h);
    const text = s.slice();
    if (rx.stz_regex_match(h, text.ptr, text.len, 0) == 0) return 0;
    const byte_start = rx.stz_regex_capture_start(h, 1);
    if (byte_start < 1) return 0;
    const byte_off: usize = @intCast(byte_start - 1);
    const cp_idx = byteOffsetToCodepointIndex(text, byte_off);
    return toExternal(cp_idx);
}

// ─── str_regex_find_all ───
//
// Returns a StzFindResultHandle with 1-based codepoint positions
// of all non-overlapping match starts.

pub fn str_regex_find_all(handle: StzStringHandle, pat: [*c]const u8, pat_len: usize, flags: u32) callconv(.c) StzFindResultHandle {
    const r = gpa.create(StzFindResult) catch return null;
    r.* = StzFindResult.init();
    const s = handle orelse return r;
    const h = rx.stz_regex_new(pat, pat_len, flags) orelse return r;
    defer rx.stz_regex_free(h);
    const text = s.slice();
    const n = rx.stz_regex_match_all(h, text.ptr, text.len);
    if (n <= 0) return r;
    const cap_count = rx.stz_regex_capture_count(h);
    const groups_per_match = if (n > 0 and cap_count > 0) @divTrunc(@as(usize, @intCast(cap_count)), @as(usize, @intCast(n))) else 1;
    var i: usize = 0;
    while (i < @as(usize, @intCast(n))) : (i += 1) {
        const cap_idx: c_int = @intCast(i * groups_per_match + 1);
        const byte_start = rx.stz_regex_capture_start(h, cap_idx);
        if (byte_start >= 1) {
            const byte_off: usize = @intCast(byte_start - 1);
            const cp_idx = byteOffsetToCodepointIndex(text, byte_off);
            r.positions.append(gpa, toExternal(cp_idx)) catch {};
        }
    }
    return r;
}

// Extract the TEXT of every regex match (not just positions) in ONE call --
// emails, URLs, dates, IDs, etc. Was a Ring while-loop (MatchAt + CaptureText
// per match). Returns a StzStrListResult of the whole-match substrings.
pub fn str_regex_extract_all(handle: StzStringHandle, pat: [*c]const u8, pat_len: usize, flags: u32) callconv(.c) StzStrListResultHandle {
    const r = gpa.create(StzStrListResult) catch return null;
    r.* = StzStrListResult.init();
    const s = (handle orelse return r);
    const h = rx.stz_regex_new(pat, pat_len, flags) orelse return r;
    defer rx.stz_regex_free(h);
    const text = s.slice();
    const n = rx.stz_regex_match_all(h, text.ptr, text.len);
    if (n <= 0) return r;
    const cap_count = rx.stz_regex_capture_count(h);
    const groups_per_match = if (n > 0 and cap_count > 0) @divTrunc(@as(usize, @intCast(cap_count)), @as(usize, @intCast(n))) else 1;
    var i: usize = 0;
    while (i < @as(usize, @intCast(n))) : (i += 1) {
        const cap_idx: c_int = @intCast(i * groups_per_match + 1);
        const bstart = rx.stz_regex_capture_start(h, cap_idx); // 1-based byte
        const bend = rx.stz_regex_capture_end(h, cap_idx); // 1-based byte, one-PAST the last
        if (bstart >= 1 and bend > bstart) {
            const a: usize = @intCast(bstart - 1);
            const b: usize = @min(@as(usize, @intCast(bend - 1)), text.len);
            if (b > a) r.push(text[a..b]);
        }
    }
    return r;
}

// ─── str_regex_replace_all ───
//
// Returns a new string handle with all matches replaced.
// The caller owns the returned handle.

pub fn str_regex_replace_all(handle: StzStringHandle, pat: [*c]const u8, pat_len: usize, repl: [*c]const u8, repl_len: usize, flags: u32) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const h = rx.stz_regex_new(pat, pat_len, flags) orelse return null;
    defer rx.stz_regex_free(h);
    const text = s.slice();
    var out_len: usize = 0;
    const ptr = rx.stz_regex_replace(h, text.ptr, text.len, repl, repl_len, &out_len);
    if (ptr == null or out_len == 0) {
        if (ptr != null) rx.stz_regex_replace_free(ptr, out_len);
        return str_from(text.ptr, text.len);
    }
    defer rx.stz_regex_replace_free(ptr, out_len);
    return str_from(ptr, out_len);
}

// ─── str_regex_split_count ───
//
// Returns the number of parts when splitting by regex.

pub fn str_regex_split_count(handle: StzStringHandle, pat: [*c]const u8, pat_len: usize, flags: u32) callconv(.c) c_int {
    const s = handle orelse return 0;
    const h = rx.stz_regex_new(pat, pat_len, flags) orelse return 1;
    defer rx.stz_regex_free(h);
    const text = s.slice();
    if (text.len == 0) return 1;
    const n = rx.stz_regex_match_all(h, text.ptr, text.len);
    return n + 1;
}

// ─── str_regex_split_get ───
//
// Returns the Nth part (1-based) when splitting by regex.
// Caller must free the returned string handle.

pub fn str_regex_split_get(handle: StzStringHandle, pat: [*c]const u8, pat_len: usize, flags: u32, index: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    if (index < 1) { setError(.index_out_of_bounds); return null; }
    const idx: usize = @intCast(index - 1);
    const h = rx.stz_regex_new(pat, pat_len, flags) orelse {
        if (idx == 0) return str_from(s.slice().ptr, s.slice().len);
        return null;
    };
    defer rx.stz_regex_free(h);
    const text = s.slice();
    if (text.len == 0) {
        if (idx == 0) return str_from("", 0);
        return null;
    }
    const n: usize = @intCast(@max(rx.stz_regex_match_all(h, text.ptr, text.len), 0));
    if (idx > n) { setError(.index_out_of_bounds); return null; }

    const cap_count = rx.stz_regex_capture_count(h);
    const groups_per_match = if (n > 0 and cap_count > 0) @divTrunc(@as(usize, @intCast(cap_count)), n) else 1;

    var starts: [512]usize = undefined;
    var ends: [512]usize = undefined;
    var mi: usize = 0;
    while (mi < n and mi < 512) : (mi += 1) {
        const cap_idx: c_int = @intCast(mi * groups_per_match + 1);
        const ms = rx.stz_regex_capture_start(h, cap_idx);
        const me = rx.stz_regex_capture_end(h, cap_idx);
        starts[mi] = if (ms >= 1) @intCast(ms - 1) else 0;
        ends[mi] = if (me >= 1) @intCast(me - 1) else 0;
    }

    const part_start = if (idx == 0) 0 else ends[idx - 1];
    const part_end = if (idx < n) starts[idx] else text.len;
    if (part_start > text.len) return str_from("", 0);
    const actual_end = @min(part_end, text.len);
    if (part_start > actual_end) return str_from("", 0);
    return str_from(text.ptr + part_start, actual_end - part_start);
}

// ─── Tests ───

test "str_regex_is_match basic" {
    const h = core.str_from("hello world", 11) orelse unreachable;
    defer core.str_free(h);
    try std.testing.expectEqual(@as(c_int, 1), str_regex_is_match(h, "\\w+", 3, 0));
    try std.testing.expectEqual(@as(c_int, 0), str_regex_is_match(h, "^xyz$", 5, 0));
}

test "str_regex_is_match case insensitive" {
    const h = core.str_from("Hello World", 11) orelse unreachable;
    defer core.str_free(h);
    try std.testing.expectEqual(@as(c_int, 0), str_regex_is_match(h, "^hello", 6, 0));
    try std.testing.expectEqual(@as(c_int, 1), str_regex_is_match(h, "^hello", 6, 1)); // flag 1 = case insensitive
}

test "str_regex_count" {
    const h = core.str_from("abc123def456", 12) orelse unreachable;
    defer core.str_free(h);
    try std.testing.expectEqual(@as(c_int, 2), str_regex_count(h, "\\d+", 3, 0));
    try std.testing.expectEqual(@as(c_int, 0), str_regex_count(h, "xyz", 3, 0));
}

test "str_regex_find_first ascii" {
    const h = core.str_from("hello 123 world", 15) orelse unreachable;
    defer core.str_free(h);
    const pos = str_regex_find_first(h, "\\d+", 3, 0);
    try std.testing.expectEqual(@as(i64, 7), pos);
}

test "str_regex_find_first no match" {
    const h = core.str_from("hello world", 11) orelse unreachable;
    defer core.str_free(h);
    try std.testing.expectEqual(@as(i64, 0), str_regex_find_first(h, "\\d+", 3, 0));
}

test "str_regex_find_all" {
    const h = core.str_from("a1b2c3", 6) orelse unreachable;
    defer core.str_free(h);
    const r = str_regex_find_all(h, "\\d", 2, 0);
    defer if (r) |fr| { fr.deinit(); gpa.destroy(fr); };
    try std.testing.expect(r != null);
    try std.testing.expectEqual(@as(usize, 3), r.?.positions.items.len);
    try std.testing.expectEqual(@as(i64, 2), r.?.positions.items[0]);
    try std.testing.expectEqual(@as(i64, 4), r.?.positions.items[1]);
    try std.testing.expectEqual(@as(i64, 6), r.?.positions.items[2]);
}

test "str_regex_replace_all basic" {
    const h = core.str_from("hello world", 11) orelse unreachable;
    defer core.str_free(h);
    const result = str_regex_replace_all(h, "\\w+", 3, "X", 1, 0);
    defer core.str_free(result);
    try std.testing.expect(result != null);
    const data = core.str_data(result);
    const size = core.str_size(result);
    const slice = data[0..@intCast(size)];
    try std.testing.expectEqualStrings("X X", slice);
}

test "str_regex_replace_all no match" {
    const h = core.str_from("hello", 5) orelse unreachable;
    defer core.str_free(h);
    const result = str_regex_replace_all(h, "\\d+", 3, "X", 1, 0);
    defer core.str_free(result);
    try std.testing.expect(result != null);
    const data = core.str_data(result);
    const size = core.str_size(result);
    try std.testing.expectEqualStrings("hello", data[0..@intCast(size)]);
}

test "str_regex_split_count" {
    const h = core.str_from("one::two::three", 15) orelse unreachable;
    defer core.str_free(h);
    try std.testing.expectEqual(@as(c_int, 3), str_regex_split_count(h, ":+", 2, 0));
}

test "str_regex_split_get parts" {
    const h = core.str_from("one::two::three", 15) orelse unreachable;
    defer core.str_free(h);
    const p1 = str_regex_split_get(h, ":+", 2, 0, 1);
    defer core.str_free(p1);
    try std.testing.expect(p1 != null);
    try std.testing.expectEqualStrings("one", core.str_data(p1)[0..@intCast(core.str_size(p1))]);

    const p2 = str_regex_split_get(h, ":+", 2, 0, 2);
    defer core.str_free(p2);
    try std.testing.expect(p2 != null);
    try std.testing.expectEqualStrings("two", core.str_data(p2)[0..@intCast(core.str_size(p2))]);

    const p3 = str_regex_split_get(h, ":+", 2, 0, 3);
    defer core.str_free(p3);
    try std.testing.expect(p3 != null);
    try std.testing.expectEqualStrings("three", core.str_data(p3)[0..@intCast(core.str_size(p3))]);
}

test "str_regex_split_get out of bounds" {
    const h = core.str_from("a-b", 3) orelse unreachable;
    defer core.str_free(h);
    const p = str_regex_split_get(h, "-", 1, 0, 5);
    try std.testing.expect(p == null);
}

test "str_regex_find_first unicode" {
    const input = "caf\xC3\xA9 123";
    const h = core.str_from(input, input.len) orelse unreachable;
    defer core.str_free(h);
    const pos = str_regex_find_first(h, "\\d+", 3, 0);
    try std.testing.expectEqual(@as(i64, 6), pos);
}

test "str_regex_count unicode" {
    const input = "\xCE\xB1\xCE\xB2 \xCE\xB3\xCE\xB4";
    const h = core.str_from(input, input.len) orelse unreachable;
    defer core.str_free(h);
    try std.testing.expectEqual(@as(c_int, 2), str_regex_count(h, "\\p{L}+", 6, 0));
}

test "str_regex_replace_all unicode" {
    const input = "abc\xC3\xA9def";
    const h = core.str_from(input, input.len) orelse unreachable;
    defer core.str_free(h);
    const result = str_regex_replace_all(h, "\\p{L}+", 6, "X", 1, 0);
    defer core.str_free(result);
    try std.testing.expect(result != null);
    const data = core.str_data(result);
    const size = core.str_size(result);
    try std.testing.expectEqualStrings("X", data[0..@intCast(size)]);
}

test "str_regex_null handle" {
    try std.testing.expectEqual(@as(c_int, 0), str_regex_is_match(null, "a", 1, 0));
    try std.testing.expectEqual(@as(c_int, 0), str_regex_count(null, "a", 1, 0));
    try std.testing.expectEqual(@as(i64, 0), str_regex_find_first(null, "a", 1, 0));
    try std.testing.expect(str_regex_replace_all(null, "a", 1, "b", 1, 0) == null);
}
