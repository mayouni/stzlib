// Ring Extension Bridge for str_ (string engine)
//
// Wraps Softanza Engine string+char functions as Ring extension
// functions. Ring calls these by name after ringlib_init registers them.
//
// HANDLE TABLE: Instead of passing raw C pointers across the Ring-Zig
// FFI boundary (which causes sporadic alignment panics), all engine
// handles are stored in a Zig-side table. Ring receives/passes integer
// IDs (via retnumber/getnumber). This eliminates all pointer alignment
// issues because Ring never touches the actual pointers.

const std = @import("std");
const string = @import("string.zig");
const char_mod = @import("char.zig");
const R = @import("ring_api.zig");

const ring_vm_api_getstring = R.ring_vm_api_getstring;
const ring_vm_api_getstringsize = R.ring_vm_api_getstringsize;
const ring_vm_api_getnumber = R.ring_vm_api_getnumber;
const ring_vm_api_retnumber = R.ring_vm_api_retnumber;
const ring_vm_api_retstring = R.ring_vm_api_retstring;
const ring_vm_api_retstring2 = R.ring_vm_api_retstring2;

// Shadow the real cpointer functions: store/resolve via handle table.
// All 267+ call sites automatically use the table -- no per-site changes.
fn ring_vm_api_retcpointer(p: *anyopaque, ptr: ?*anyopaque, _: [*:0]const u8) void {
    R.retHandle(p, ptr);
}

fn ring_vm_api_getcpointer(p: *anyopaque, n: c_int, _: [*:0]const u8) ?*anyopaque {
    return R.getHandle(p, n);
}

const STZ_HANDLE: [*:0]const u8 = "StzStringHandle";

fn getHandle(p: *anyopaque, n: c_int) string.StzStringHandle {
    const ptr = ring_vm_api_getcpointer(p, n, STZ_HANDLE);
    if (ptr) |raw| {
        // Use @intFromPtr + @ptrFromInt to bypass alignment check.
        // Ring's C pointer storage may return pointers that trigger
        // Zig's @alignCast safety panic under high allocation churn.
        const addr = @intFromPtr(raw);
        if (addr == 0) return null;
        return @ptrFromInt(addr);
    }
    return null;
}

// ─── Error Reporting ───

fn ring_StringLastError(p: *anyopaque) callconv(.c) void {
    ring_vm_api_retnumber(p, @floatFromInt(string.str_last_error()));
}

fn ring_StringClearError(_: *anyopaque) callconv(.c) void {
    string.str_clear_error();
}

// ─── String Lifecycle ───

fn ring_StringNew(p: *anyopaque) callconv(.c) void {
    ring_vm_api_retcpointer(p, @ptrCast(string.str_new()), STZ_HANDLE);
}

fn ring_StringFrom(p: *anyopaque) callconv(.c) void {
    const s = ring_vm_api_getstring(p, 1);
    const len: usize = @intCast(ring_vm_api_getstringsize(p, 1));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_from(s, len)), STZ_HANDLE);
}

fn ring_StringFree(p: *anyopaque) callconv(.c) void {
    const raw = R.releaseHandle(p, 1);
    if (raw) |ptr| {
        const h: string.StzStringHandle = @ptrFromInt(@intFromPtr(ptr));
        string.str_free(h);
    }
}

fn ring_StringData(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const data = string.str_data(h);
    const size = string.str_size(h);
    if (data != null and size > 0) {
        ring_vm_api_retstring2(p, data, @intCast(size));
    } else {
        ring_vm_api_retstring(p, "");
    }
}

fn ring_StringSize(p: *anyopaque) callconv(.c) void {
    ring_vm_api_retnumber(p, @floatFromInt(string.str_size(getHandle(p, 1))));
}

fn ring_StringCount(p: *anyopaque) callconv(.c) void {
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count(getHandle(p, 1))));
}

fn ring_StringAppend(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    string.str_append(h, s, @intCast(ring_vm_api_getstringsize(p, 2)));
}

fn ring_StringInsert(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const pos: usize = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const s = ring_vm_api_getstring(p, 3);
    string.str_insert(h, pos, s, @intCast(ring_vm_api_getstringsize(p, 3)));
}

fn ring_StringMid(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const start: usize = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const length: usize = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_mid(h, start, length)), STZ_HANDLE);
}

fn ring_StringTrimmed(p: *anyopaque) callconv(.c) void {
    ring_vm_api_retcpointer(p, @ptrCast(string.str_trimmed(getHandle(p, 1))), STZ_HANDLE);
}

fn ring_StringFindFirst(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_find_first(h, s, @intCast(ring_vm_api_getstringsize(p, 2)))));
}

fn ring_StringFindFirstFrom(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const start: usize = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_find_first_from(h, s, len, start)));
}

fn ring_StringByteToCp(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const pos: usize = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_byte_to_cp(h, pos)));
}

fn ring_StringCountOf(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_of(h, s, @intCast(ring_vm_api_getstringsize(p, 2)))));
}

fn ring_StringFindLast(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_find_last(h, s, @intCast(ring_vm_api_getstringsize(p, 2)))));
}

fn ring_StringContains(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_contains(h, s, @intCast(ring_vm_api_getstringsize(p, 2)))));
}

fn ring_StringStartsWith(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_starts_with(h, s, @intCast(ring_vm_api_getstringsize(p, 2)))));
}

fn ring_StringEndsWith(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_ends_with(h, s, @intCast(ring_vm_api_getstringsize(p, 2)))));
}

// ─── Find Result ───

const FIND_HANDLE: [*:0]const u8 = "StzFindResultHandle";

fn getFindHandle(p: *anyopaque, n: c_int) string.StzFindResultHandle {
    const ptr = ring_vm_api_getcpointer(p, n, FIND_HANDLE);
    if (ptr) |raw| {
        const addr = @intFromPtr(raw);
        if (addr == 0) return null;
        return @ptrFromInt(addr);
    }
    return null;
}

fn ring_StringFind(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_find(h, s, len)), FIND_HANDLE);
}

fn ring_FindResultCount(p: *anyopaque) callconv(.c) void {
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_find_result_count(getFindHandle(p, 1))));
}

fn ring_FindResultGet(p: *anyopaque) callconv(.c) void {
    const h = getFindHandle(p, 1);
    const idx: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_find_result_get(h, idx)));
}

fn ring_FindResultFree(p: *anyopaque) callconv(.c) void {
    const raw = R.releaseHandle(p, 1);
    if (raw) |ptr| {
        const fh: string.StzFindResultHandle = @ptrFromInt(@intFromPtr(ptr));
        string.stz_find_result_free(fh);
    }
}

// ─── String-list Result (substring enumeration) ───

fn getStrListHandle(p: *anyopaque, n: c_int) string.StzStrListResultHandle {
    const ptr = R.getHandle(p, n);
    if (ptr) |raw| {
        const addr = @intFromPtr(raw);
        if (addr == 0) return null;
        return @ptrFromInt(addr);
    }
    return null;
}

fn ring_StringSubStrings(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    R.retHandle(p, @ptrCast(string.str_substrings(h)));
}

fn ring_StringSubStringsUnique(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const cs: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    R.retHandle(p, @ptrCast(string.str_substrings_unique_cs(h, cs)));
}

fn ring_StringSubStringsByCount(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const nWant: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const exact: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    const cs: c_int = @intFromFloat(ring_vm_api_getnumber(p, 4));
    R.retHandle(p, @ptrCast(string.str_substrings_by_count_cs(h, nWant, exact, cs)));
}

fn ring_StringFindDupSecutiveChars(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const cs: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_find_dupsecutive_chars_cs(h, cs)), FIND_HANDLE);
}

fn ring_StringFindDupSecutiveSubString(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const cs: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_find_dupsecutive_substring_cs(h, s, len, cs)), FIND_HANDLE);
}

fn ring_StringConsecutiveSubStringsOfN(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const nWant: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    R.retHandle(p, @ptrCast(string.str_consecutive_substrings_of_n(h, nWant)));
}

fn ring_StringConsecutiveSubStrings(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    R.retHandle(p, @ptrCast(string.str_consecutive_substrings(h)));
}

fn ring_StringWindowsUptoHalf(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    R.retHandle(p, @ptrCast(string.str_windows_upto_half(h)));
}

fn ring_StrListCount(p: *anyopaque) callconv(.c) void {
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_strlist_count(getStrListHandle(p, 1))));
}

fn ring_StrListGet(p: *anyopaque) callconv(.c) void {
    const h = getStrListHandle(p, 1);
    const idx: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    // Returns a FRESH string handle Ring can query via StzEngineStringData.
    R.retHandle(p, @ptrCast(string.stz_strlist_get(h, idx)));
}

fn ring_StrListFree(p: *anyopaque) callconv(.c) void {
    const raw = R.releaseHandle(p, 1);
    if (raw) |ptr| {
        const lh: string.StzStrListResultHandle = @ptrFromInt(@intFromPtr(ptr));
        string.stz_strlist_free(lh);
    }
}

fn ring_StringReplace(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const old_s = ring_vm_api_getstring(p, 2);
    const old_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const new_s = ring_vm_api_getstring(p, 3);
    const new_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    string.str_replace(h, old_s, old_len, new_s, new_len);
}

fn ring_StringReplaceRange(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const start: usize = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const range: usize = @intFromFloat(ring_vm_api_getnumber(p, 3));
    const s = ring_vm_api_getstring(p, 4);
    const len: usize = @intCast(ring_vm_api_getstringsize(p, 4));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_replace_range(h, start, range, s, len)), STZ_HANDLE);
}

fn ring_StringSplitCount(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_split_count(h, s, @intCast(ring_vm_api_getstringsize(p, 2)))));
}

fn ring_StringSplitGet(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const idx: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_split_get(h, s, len, idx)), STZ_HANDLE);
}

fn ring_StringToUpper(p: *anyopaque) callconv(.c) void {
    ring_vm_api_retcpointer(p, @ptrCast(string.str_to_upper(getHandle(p, 1))), STZ_HANDLE);
}

fn ring_StringToLower(p: *anyopaque) callconv(.c) void {
    ring_vm_api_retcpointer(p, @ptrCast(string.str_to_lower(getHandle(p, 1))), STZ_HANDLE);
}

fn ring_StringDotless(p: *anyopaque) callconv(.c) void {
    ring_vm_api_retcpointer(p, @ptrCast(string.str_dotless(getHandle(p, 1))), STZ_HANDLE);
}

fn ring_StringGroupInsert(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const sep = ring_vm_api_getstring(p, 2);
    const sep_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const step: usize = @intFromFloat(ring_vm_api_getnumber(p, 3));
    const backward: c_int = @intFromFloat(ring_vm_api_getnumber(p, 4));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_group_insert(h, sep, sep_len, step, backward)), STZ_HANDLE);
}

fn ring_StringToTitle(p: *anyopaque) callconv(.c) void {
    ring_vm_api_retcpointer(p, @ptrCast(string.str_to_title(getHandle(p, 1))), STZ_HANDLE);
}

fn ring_StringCharAt(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const idx: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_char_at(h, idx)));
}

fn ring_StringMidCp(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const start: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const count: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_mid_cp(h, start, count)), STZ_HANDLE);
}

fn ring_StringGraphemeCount(p: *anyopaque) callconv(.c) void {
    ring_vm_api_retnumber(p, @floatFromInt(string.str_grapheme_count(getHandle(p, 1))));
}

fn ring_StringNormalize(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const form: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_normalize(h, form)), STZ_HANDLE);
}

fn ring_StringStripMarks(p: *anyopaque) callconv(.c) void {
    ring_vm_api_retcpointer(p, @ptrCast(string.str_strip_marks(getHandle(p, 1))), STZ_HANDLE);
}

fn ring_CharUnicode(p: *anyopaque) callconv(.c) void {
    ring_vm_api_retnumber(p, @floatFromInt(char_mod.stz_char_unicode(ring_vm_api_getstring(p, 1))));
}

fn ring_CharToUtf8(p: *anyopaque) callconv(.c) void {
    const cp: u32 = @intFromFloat(ring_vm_api_getnumber(p, 1));
    var buf: [4]u8 = undefined;
    const n = char_mod.stz_char_to_utf8(cp, &buf, 4);
    if (n > 0) {
        ring_vm_api_retstring2(p, &buf, @intCast(n));
    } else {
        ring_vm_api_retstring2(p, @constCast(""), 0);
    }
}

fn ring_CharIsLetter(p: *anyopaque) callconv(.c) void {
    const cp: u32 = @intFromFloat(ring_vm_api_getnumber(p, 1));
    ring_vm_api_retnumber(p, @floatFromInt(char_mod.stz_char_is_letter(cp)));
}

fn ring_CharIsDigit(p: *anyopaque) callconv(.c) void {
    const cp: u32 = @intFromFloat(ring_vm_api_getnumber(p, 1));
    ring_vm_api_retnumber(p, @floatFromInt(char_mod.stz_char_is_digit(cp)));
}

fn ring_CharIsUpper(p: *anyopaque) callconv(.c) void {
    const cp: u32 = @intFromFloat(ring_vm_api_getnumber(p, 1));
    ring_vm_api_retnumber(p, @floatFromInt(char_mod.stz_char_is_upper(cp)));
}

fn ring_CharIsLower(p: *anyopaque) callconv(.c) void {
    const cp: u32 = @intFromFloat(ring_vm_api_getnumber(p, 1));
    ring_vm_api_retnumber(p, @floatFromInt(char_mod.stz_char_is_lower(cp)));
}

// ─── Codepoint-aware Extraction ───

fn ring_StringNthChar(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const cp_idx: usize = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const result = string.str_nth_char(h, cp_idx);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringSlice(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const start_cp: usize = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const cp_count: usize = @intFromFloat(ring_vm_api_getnumber(p, 3));
    const result = string.str_slice(h, start_cp, cp_count);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringReverse(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const result = string.str_reverse(h);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringFoldcase(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const result = string.str_foldcase(h);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringRepeat(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const count: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const result = string.str_repeat(h, count);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringPadLeft(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const target: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const pad_s = ring_vm_api_getstring(p, 3);
    const pad_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    const result = string.str_pad_left(h, target, pad_s, pad_len);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringPadRight(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const target: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const pad_s = ring_vm_api_getstring(p, 3);
    const pad_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    const result = string.str_pad_right(h, target, pad_s, pad_len);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringRemoveRange(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const start_cp: usize = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const cp_count: usize = @intFromFloat(ring_vm_api_getnumber(p, 3));
    const result = string.str_remove_range(h, start_cp, cp_count);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringTrimLeft(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_trim_left(h)), STZ_HANDLE);
}

fn ring_StringTrimRight(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_trim_right(h)), STZ_HANDLE);
}

fn ring_StringEquals(p: *anyopaque) callconv(.c) void {
    const h1 = getHandle(p, 1);
    const h2 = getHandle(p, 2);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_equals(h1, h2)));
}

fn ring_StringRemove(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const result = string.str_remove(h, s, len);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringLinesCount(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_lines_count(h)));
}

fn ring_StringIsPalindrome(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_palindrome(h)));
}

fn ring_StringConcat(p: *anyopaque) callconv(.c) void {
    const h1 = getHandle(p, 1);
    const h2 = getHandle(p, 2);
    const result = string.str_concat(h1, h2);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringFindCharsOfType(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const char_type: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const result = string.str_find_chars_of_type(h, char_type);
    ring_vm_api_retcpointer(p, @ptrCast(result), "StzFindResultHandle");
}

fn ring_StringExtractCharsOfType(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const char_type: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const result = string.str_extract_chars_of_type(h, char_type);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringIsAscii(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_ascii(h)));
}

fn ring_StringRemoveCharAt(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const cp_index: usize = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const result = string.str_remove_char_at(h, cp_index);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringCharTypeAt(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const cp_index: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_char_type_at(h, cp_index)));
}

fn ring_StringReplaceFirst(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const old = ring_vm_api_getstring(p, 2);
    const old_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const new_str = ring_vm_api_getstring(p, 3);
    const new_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    const result = string.str_replace_first(h, old, old_len, new_str, new_len);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringReplaceLast(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const old = ring_vm_api_getstring(p, 2);
    const old_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const new_str = ring_vm_api_getstring(p, 3);
    const new_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    const result = string.str_replace_last(h, old, old_len, new_str, new_len);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringReplaceNth(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const old = ring_vm_api_getstring(p, 2);
    const old_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const new_str = ring_vm_api_getstring(p, 3);
    const new_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    const n: c_int = @intFromFloat(ring_vm_api_getnumber(p, 4));
    const result = string.str_replace_nth(h, old, old_len, new_str, new_len, n);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringIsEmpty(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_empty(h)));
}

fn ring_StringBetween(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const open = ring_vm_api_getstring(p, 2);
    const open_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const close = ring_vm_api_getstring(p, 3);
    const close_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    const result = string.str_between(h, open, open_len, close, close_len);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringBetweenAll(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const open = ring_vm_api_getstring(p, 2);
    const open_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const close = ring_vm_api_getstring(p, 3);
    const close_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    const result = string.str_between_all(h, open, open_len, close, close_len);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringBetweenAllCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const open = ring_vm_api_getstring(p, 2);
    const open_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const close = ring_vm_api_getstring(p, 3);
    const close_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    const cs: c_int = @intFromFloat(ring_vm_api_getnumber(p, 4));
    const result = string.str_between_all_cs(h, open, open_len, close, close_len, cs);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringCountCharsOfType(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const char_type: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_chars_of_type(h, char_type)));
}

fn ring_StringIsNumeric(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_numeric(h)));
}

fn ring_StringIsAlpha(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_alpha(h)));
}

fn ring_StringFindNth(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const n: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_find_nth(h, s, len, n)));
}



fn ring_StringInsertCp(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const cp_pos: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const s = ring_vm_api_getstring(p, 3);
    const len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    string.str_insert_cp(h, cp_pos, s, len);
}

fn ring_StringLeftCp(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const cp_count: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const result = string.str_left_cp(h, cp_count);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringRightCp(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const cp_count: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const result = string.str_right_cp(h, cp_count);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringIsUppercase(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_uppercase(h)));
}

fn ring_StringIsLowercase(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_lowercase(h)));
}

fn ring_StringIsWhitespace(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_whitespace(h)));
}

fn ring_StringWordCount(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_word_count(h)));
}

fn ring_StringIsOnlyType(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const char_type: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_only_type(h, char_type)));
}

fn ring_StringRemoveCharsOfType(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const char_type: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const result = string.str_remove_chars_of_type(h, char_type);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringTrim(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const result = string.str_trim(h);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringSwapCase(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const result = string.str_swap_case(h);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringUniqueChars(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const result = string.str_unique_chars(h);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringUniqueCharCount(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_unique_char_count(h)));
}

fn ring_StringIsAlphaOnly(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_alpha_only(h)));
}

fn ring_StringIsAlnum(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_alnum(h)));
}

fn ring_StringContainsChar(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const cp: i32 = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_contains_char(h, cp)));
}

fn ring_StringBetweenNth(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const open = ring_vm_api_getstring(p, 2);
    const open_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const close = ring_vm_api_getstring(p, 3);
    const close_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    const nth: c_int = @intFromFloat(ring_vm_api_getnumber(p, 4));
    const result = string.str_between_nth(h, open, open_len, close, close_len, nth);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringCountBetween(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const open = ring_vm_api_getstring(p, 2);
    const open_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const close = ring_vm_api_getstring(p, 3);
    const close_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_between(h, open, open_len, close, close_len)));
}

fn ring_StringSimplify(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const result = string.str_simplify(h);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringStartsWithDigit(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_starts_with_digit(h)));
}

fn ring_StringStartsWithLetter(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_starts_with_letter(h)));
}

fn ring_StringEndsWithDigit(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_ends_with_digit(h)));
}

fn ring_StringEndsWithLetter(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_ends_with_letter(h)));
}

fn ring_StringReplaceCharAt(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const cp_index: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const replacement = ring_vm_api_getstring(p, 3);
    const rep_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    const result = string.str_replace_char_at(h, cp_index, replacement, rep_len);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringLevenshtein(p: *anyopaque) callconv(.c) void {
    const h1 = getHandle(p, 1);
    const h2 = getHandle(p, 2);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_levenshtein(h1, h2)));
}

fn ring_StringIsTitleCase(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_title_case(h)));
}

fn ring_StringLinesSplitCount(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_lines_split_count(h)));
}

fn ring_StringLineAt(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const idx: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const result = string.str_line_at(h, idx);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

// ─── IsWord ───

fn ring_StringIsWord(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_word(h)));
}

// ─── CountLeadingChar / CountTrailingChar ───

fn ring_StringCountLeadingChar(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const cp: u32 = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_leading_char(h, cp)));
}

fn ring_StringCountTrailingChar(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const cp: u32 = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_trailing_char(h, cp)));
}

// ─── IsNumericString ───

fn ring_StringIsNumericString(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_numeric_string(h)));
}

// ─── URLEncode / URLDecode ───

fn ring_StringURLEncode(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const result = string.str_url_encode(h);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringURLDecode(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const result = string.str_url_decode(h);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

// ─── CharAtToString ───

fn ring_StringCharAtToString(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const idx: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const result = string.str_char_at_to_string(h, idx);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

// ─── Spacify ───

fn ring_StringSpacify(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const result = string.str_spacify(h);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

// ─── BytesPerChar ───

fn ring_StringBytesPerChar(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const result = string.str_bytes_per_char(h);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

// ─── IsHexString / IsBinaryString / IsOctalString ───

fn ring_StringIsHexString(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_hex_string(h)));
}

fn ring_StringIsBinaryString(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_binary_string(h)));
}

fn ring_StringIsOctalString(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_octal_string(h)));
}

// ─── WordAt ───

fn ring_StringWordAt(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const idx: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const result = string.str_word_at(h, idx);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

// ─── Center ───

fn ring_StringCenter(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const width: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const pad_char: u32 = @intFromFloat(ring_vm_api_getnumber(p, 3));
    const result = string.str_center(h, width, pad_char);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

// ─── RemoveConsecutiveDuplicates ───

fn ring_StringRemoveConsecutiveDuplicates(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const result = string.str_remove_consecutive_duplicates(h);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

// ─── Substring ───

fn ring_StringSubstring(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const from: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const to: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    const result = string.str_substring(h, from, to);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

// ─── ReplaceSubstring ───

fn ring_StringReplaceSubstring(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const from: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const to: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    const rep_ptr = ring_vm_api_getstring(p, 4);
    const rep_len: usize = @intCast(ring_vm_api_getstringsize(p, 4));
    const result = string.str_replace_substring(h, from, to, rep_ptr, rep_len);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

// ─── PrefixCount / SuffixCount ───

fn ring_StringPrefixCount(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const pref_ptr = ring_vm_api_getstring(p, 2);
    const pref_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_prefix_count(h, pref_ptr, pref_len)));
}

fn ring_StringSuffixCount(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const suf_ptr = ring_vm_api_getstring(p, 2);
    const suf_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_suffix_count(h, suf_ptr, suf_len)));
}

// ─── CommonPrefix / CommonSuffix ───

fn ring_StringCommonPrefix(p: *anyopaque) callconv(.c) void {
    const h1 = getHandle(p, 1);
    const h2 = getHandle(p, 2);
    const result = string.str_common_prefix(h1, h2);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringCommonSuffix(p: *anyopaque) callconv(.c) void {
    const h1 = getHandle(p, 1);
    const h2 = getHandle(p, 2);
    const result = string.str_common_suffix(h1, h2);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

// ─── SortChars ───

fn ring_StringSortCharsAsc(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const result = string.str_sort_chars_asc(h);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringSortCharsDesc(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const result = string.str_sort_chars_desc(h);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

// ─── FindChar ───

fn ring_StringFindChar(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const cp: u32 = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_find_char(h, cp)), FIND_HANDLE);
}

// ─── DuplicateSubstringsCS ───

fn ring_StringDuplicateSubstringsCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_duplicate_substrings_cs(h, case)), STZ_HANDLE);
}

// ─── Hash ───

fn ring_StringHash(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_hash(h)));
}

// ─── Cryptographic Hashes ───

fn ring_StringSha256(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_sha256(h)), STZ_HANDLE);
}

fn ring_StringMd5(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_md5(h)), STZ_HANDLE);
}

fn ring_StringBlake3(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_blake3(h)), STZ_HANDLE);
}

fn ring_StringHmacSha256(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const key = ring_vm_api_getstring(p, 2);
    const key_len: c_int = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_hmac_sha256(h, key, key_len)), STZ_HANDLE);
}

// ─── Locale: Script & Direction Detection ───

fn ring_StringDetectScript(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_detect_script(h)));
}

fn ring_StringScriptName(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_script_name(h)), STZ_HANDLE);
}

fn ring_StringDetectDirection(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_detect_direction(h)));
}

fn ring_StringDirectionName(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_direction_name(h)), STZ_HANDLE);
}

fn ring_StringHasRTL(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_has_rtl(h)));
}

fn ring_StringScriptCount(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_script_count(h)));
}

fn ring_StringLocaleCompare(p: *anyopaque) callconv(.c) void {
    const h1 = getHandle(p, 1);
    const h2 = getHandle(p, 2);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_locale_compare(h1, h2)));
}

// ─── CountChar ───

fn ring_StringCountChar(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const cp: u32 = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_char(h, cp)));
}

// ─── ReplaceChar ───

fn ring_StringReplaceChar(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const old_cp: u32 = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const new_cp: u32 = @intFromFloat(ring_vm_api_getnumber(p, 3));
    const result = string.str_replace_char(h, old_cp, new_cp);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

// ─── CountOverlapping ───

fn ring_StringCountOverlapping(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const needle = ring_vm_api_getstring(p, 2);
    const needle_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_overlapping(h, needle, needle_len)));
}

// ─── ReplaceAt ───

fn ring_StringReplaceAt(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const cp_pos: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const cp_count: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    const rep = ring_vm_api_getstring(p, 4);
    const rep_len: usize = @intCast(ring_vm_api_getstringsize(p, 4));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_replace_at(h, cp_pos, cp_count, rep, rep_len)), STZ_HANDLE);
}

// ─── CharFrequency ───

fn ring_StringCharFrequency(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_char_frequency(h)), STZ_HANDLE);
}

// ─── ContainsAnyOf ───

fn ring_StringContainsAnyOf(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const chars = ring_vm_api_getstring(p, 2);
    const chars_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_contains_any_of(h, chars, chars_len)));
}

// ─── ContainsAllOf ───

fn ring_StringContainsAllOf(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const chars = ring_vm_api_getstring(p, 2);
    const chars_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_contains_all_of(h, chars, chars_len)));
}

// ─── CenterPad ───

fn ring_StringCenterPad(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const width: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const pad = ring_vm_api_getstring(p, 3);
    const pad_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_center_pad(h, width, pad, pad_len)), STZ_HANDLE);
}

// ─── OnlyLetters ───

fn ring_StringOnlyLetters(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_only_letters(h)), STZ_HANDLE);
}

// ─── OnlyDigits ───

fn ring_StringOnlyDigits(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_only_digits(h)), STZ_HANDLE);
}

// ─── OnlyPunctuation ───

fn ring_StringOnlyPunctuation(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_only_punctuation(h)), STZ_HANDLE);
}

// ─── OnlySymbols ───

fn ring_StringOnlySymbols(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_only_symbols(h)), STZ_HANDLE);
}

// ─── OnlySpaces ───

fn ring_StringOnlySpaces(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_only_spaces(h)), STZ_HANDLE);
}

// ─── OnlyMarks ───

fn ring_StringOnlyMarks(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_only_marks(h)), STZ_HANDLE);
}

// ─── OnlyControls ───

fn ring_StringOnlyControls(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_only_controls(h)), STZ_HANDLE);
}

// ─── IsPunctuation ───

fn ring_StringIsPunctuation2(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_punctuation(h)));
}

// ─── IsSymbol ───

fn ring_StringIsSymbol(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_symbol(h)));
}

// ─── IsMark ───

fn ring_StringIsMark(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_mark(h)));
}

// ─── IsControl ───

fn ring_StringIsControl(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_control(h)));
}

// ─── HasPunctuation ───

fn ring_StringHasPunctuation(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_has_punctuation(h)));
}

// ─── HasSymbol ───

fn ring_StringHasSymbol(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_has_symbol(h)));
}

// ─── HasMark ───

fn ring_StringHasMark(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_has_mark(h)));
}

// ─── CharUnicodeAt ───

fn ring_StringCharUnicodeAt(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const idx: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_char_unicode_at(h, idx)));
}

// ─── CharCategoryAt ───

fn ring_StringCharCategoryAt(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const idx: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_char_category_at(h, idx)));
}

// ─── CharCategoryStringAt ───

fn ring_StringCharCategoryStringAt(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const idx: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    var buf: [8]u8 = undefined;
    const n = string.str_char_category_string_at(h, idx, &buf, 8);
    if (n > 0) ring_vm_api_retstring2(p, &buf, @intCast(n)) else ring_vm_api_retstring(p, "");
}

// ─── CharIsPunctuationAt ───

fn ring_StringCharIsPunctuationAt(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const idx: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_char_is_punctuation_at(h, idx)));
}

// ─── CharIsSymbolAt ───

fn ring_StringCharIsSymbolAt(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const idx: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_char_is_symbol_at(h, idx)));
}

// ─── CharIsMarkAt ───

fn ring_StringCharIsMarkAt(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const idx: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_char_is_mark_at(h, idx)));
}

// ─── CharIsControlAt ───

fn ring_StringCharIsControlAt(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const idx: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_char_is_control_at(h, idx)));
}

// ─── CharIsSpaceAt ───

fn ring_StringCharIsSpaceAt(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const idx: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_char_is_space_at(h, idx)));
}

// ─── RemoveWhitespace ───

fn ring_StringRemoveWhitespace(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_remove_whitespace(h)), STZ_HANDLE);
}

// (ring_StringIsPalindrome already defined above)

// ─── CountWords ───

fn ring_StringCountWords(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_words(h)));
}

// ─── NthWord ───

fn ring_StringNthWord(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const n: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_nth_word(h, n)), STZ_HANDLE);
}

// ─── CharsBetween ───

fn ring_StringCharsBetween(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const from: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const to: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_chars_between(h, from, to)), STZ_HANDLE);
}

// ─── IsAlphanumeric ───

fn ring_StringIsAlphanumeric(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_alphanumeric(h)));
}

// ─── Ljust / Rjust ───

fn ring_StringLjust(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const width: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const pad = ring_vm_api_getstring(p, 3);
    const pad_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_ljust(h, width, pad, pad_len)), STZ_HANDLE);
}

fn ring_StringRjust(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const width: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const pad = ring_vm_api_getstring(p, 3);
    const pad_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_rjust(h, width, pad, pad_len)), STZ_HANDLE);
}

// (ring_StringCommonPrefix already defined above)

// ─── Indent / Dedent ───

fn ring_StringIndent(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const spaces: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_indent(h, spaces)), STZ_HANDLE);
}

fn ring_StringDedent(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_dedent(h)), STZ_HANDLE);
}

// ─── CamelCase / SnakeCase / KebabCase ───

fn ring_StringToCamelCase(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_to_camel_case(h)), STZ_HANDLE);
}

fn ring_StringToSnakeCase(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_to_snake_case(h)), STZ_HANDLE);
}

fn ring_StringToKebabCase(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_to_kebab_case(h)), STZ_HANDLE);
}

// ─── RemovePrefix ───

fn ring_StringRemovePrefix(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const pfx = ring_vm_api_getstring(p, 2);
    const pfx_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_remove_prefix(h, pfx, pfx_len)), STZ_HANDLE);
}

// ─── RemoveSuffix ───

fn ring_StringRemoveSuffix(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const sfx = ring_vm_api_getstring(p, 2);
    const sfx_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_remove_suffix(h, sfx, sfx_len)), STZ_HANDLE);
}

// ─── EnsurePrefix ───

fn ring_StringEnsurePrefix(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const pfx = ring_vm_api_getstring(p, 2);
    const pfx_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_ensure_prefix(h, pfx, pfx_len)), STZ_HANDLE);
}

// ─── EnsureSuffix ───

fn ring_StringEnsureSuffix(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const sfx = ring_vm_api_getstring(p, 2);
    const sfx_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_ensure_suffix(h, sfx, sfx_len)), STZ_HANDLE);
}

// ─── SqueezeChar ───

fn ring_StringSqueezeChar(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const cp: u32 = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_squeeze_char(h, cp)), STZ_HANDLE);
}

// ─── CapitalizeFirst ───

fn ring_StringCapitalizeFirst(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_capitalize_first(h)), STZ_HANDLE);
}

// ─── DecapitalizeFirst ───

fn ring_StringDecapitalizeFirst(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_decapitalize_first(h)), STZ_HANDLE);
}

// ─── ZFill ───

fn ring_StringZFill(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const width: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_zfill(h, width)), STZ_HANDLE);
}

// ─── TabExpand ───

fn ring_StringTabExpand(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const tw: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_tab_expand(h, tw)), STZ_HANDLE);
}

// ─── RepeatChar ───

fn ring_StringRepeatChar(p: *anyopaque) callconv(.c) void {
    const cp: u32 = @intFromFloat(ring_vm_api_getnumber(p, 1));
    const count: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_repeat_char(cp, count)), STZ_HANDLE);
}

// ─── InsertBeforeEach ───

fn ring_StringInsertBeforeEach(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const needle = ring_vm_api_getstring(p, 2);
    const needle_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const ins = ring_vm_api_getstring(p, 3);
    const ins_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_insert_before_each(h, needle, needle_len, ins, ins_len)), STZ_HANDLE);
}

// ─── InsertAfterEach ───

fn ring_StringInsertAfterEach(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const needle = ring_vm_api_getstring(p, 2);
    const needle_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const ins = ring_vm_api_getstring(p, 3);
    const ins_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_insert_after_each(h, needle, needle_len, ins, ins_len)), STZ_HANDLE);
}

// ─── InsertBeforeEachCS ───

fn ring_StringInsertBeforeEachCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const needle = ring_vm_api_getstring(p, 2);
    const needle_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const ins = ring_vm_api_getstring(p, 3);
    const ins_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 4));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_insert_before_each_cs(h, needle, needle_len, ins, ins_len, case)), STZ_HANDLE);
}

// ─── InsertAfterEachCS ───

fn ring_StringInsertAfterEachCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const needle = ring_vm_api_getstring(p, 2);
    const needle_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const ins = ring_vm_api_getstring(p, 3);
    const ins_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 4));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_insert_after_each_cs(h, needle, needle_len, ins, ins_len, case)), STZ_HANDLE);
}

// ─── Truncate ───

fn ring_StringTruncate(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const max_cp: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const ell = ring_vm_api_getstring(p, 3);
    const ell_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_truncate(h, max_cp, ell, ell_len)), STZ_HANDLE);
}

// ─── WrapAt ───

fn ring_StringWrapAt(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const width: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_wrap_at(h, width)), STZ_HANDLE);
}

// ─── Copy ───

fn ring_StringCopy(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_copy(h)), STZ_HANDLE);
}

// ─── Compare ───

fn ring_StringCompare(p: *anyopaque) callconv(.c) void {
    const h1 = getHandle(p, 1);
    const ptr2 = ring_vm_api_getcpointer(p, 2, STZ_HANDLE);
    const h2: string.StzStringHandle = if (ptr2) |raw| blk: {
        const addr2 = @intFromPtr(raw);
        break :blk if (addr2 == 0) null else @ptrFromInt(addr2);
    } else null;
    ring_vm_api_retnumber(p, @floatFromInt(string.str_compare(h1, h2)));
}

// ─── RemoveFirst ───

fn ring_StringRemoveFirst(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const needle = ring_vm_api_getstring(p, 2);
    const needle_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_remove_first(h, needle, needle_len)), STZ_HANDLE);
}

// ─── RemoveLast ───

fn ring_StringRemoveLast(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const needle = ring_vm_api_getstring(p, 2);
    const needle_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_remove_last(h, needle, needle_len)), STZ_HANDLE);
}

// ─── RemoveNth ───

fn ring_StringRemoveNth(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const needle = ring_vm_api_getstring(p, 2);
    const needle_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const n: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_remove_nth(h, needle, needle_len, n)), STZ_HANDLE);
}

// ─── IsCharsSortedAsc ───

fn ring_StringIsCharsSortedAsc(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_chars_sorted_asc(h)));
}

// ─── IsCharsSortedDesc ───

fn ring_StringIsCharsSortedDesc(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_chars_sorted_desc(h)));
}

// ─── Partition ───

fn ring_StringPartition(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const sep = ring_vm_api_getstring(p, 2);
    const sep_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_partition(h, sep, sep_len)), STZ_HANDLE);
}

fn ring_StringPartitionAfter(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const sep = ring_vm_api_getstring(p, 2);
    const sep_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_partition_after(h, sep, sep_len)), STZ_HANDLE);
}

fn ring_StringRpartition(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const sep = ring_vm_api_getstring(p, 2);
    const sep_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_rpartition(h, sep, sep_len)), STZ_HANDLE);
}

fn ring_StringRpartitionAfter(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const sep = ring_vm_api_getstring(p, 2);
    const sep_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_rpartition_after(h, sep, sep_len)), STZ_HANDLE);
}

// ─── Squeeze ───

fn ring_StringSqueeze(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_squeeze(h)), STZ_HANDLE);
}

// ─── IsDigit ───

fn ring_StringIsDigit(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_digit(h)));
}

// ─── Interleave ───

fn ring_StringInterleave(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const sep = ring_vm_api_getstring(p, 2);
    const sep_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_interleave(h, sep, sep_len)), STZ_HANDLE);
}

// ─── StripChars ───

fn ring_StringStripChars(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const chars = ring_vm_api_getstring(p, 2);
    const chars_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_strip_chars(h, chars, chars_len)), STZ_HANDLE);
}

// ─── KeepChars ───

fn ring_StringKeepChars(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const chars = ring_vm_api_getstring(p, 2);
    const chars_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_keep_chars(h, chars, chars_len)), STZ_HANDLE);
}

// ─── Replace2 ───

fn ring_StringReplace2(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const old1 = ring_vm_api_getstring(p, 2);
    const old1_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const new1 = ring_vm_api_getstring(p, 3);
    const new1_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    const old2 = ring_vm_api_getstring(p, 4);
    const old2_len: usize = @intCast(ring_vm_api_getstringsize(p, 4));
    const new2 = ring_vm_api_getstring(p, 5);
    const new2_len: usize = @intCast(ring_vm_api_getstringsize(p, 5));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_replace2(h, old1, old1_len, new1, new1_len, old2, old2_len, new2, new2_len)), STZ_HANDLE);
}

// ─── Surround ───

fn ring_StringSurround(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const prefix = ring_vm_api_getstring(p, 2);
    const prefix_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const suffix = ring_vm_api_getstring(p, 3);
    const suffix_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_surround(h, prefix, prefix_len, suffix, suffix_len)), STZ_HANDLE);
}

// ─── ReplaceAnyChar ───

fn ring_StringReplaceAnyChar(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const chars = ring_vm_api_getstring(p, 2);
    const chars_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const repl = ring_vm_api_getstring(p, 3);
    const repl_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_replace_any_char(h, chars, chars_len, repl, repl_len)), STZ_HANDLE);
}

// ─── CountAnyChar ───

fn ring_StringCountAnyChar(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const chars = ring_vm_api_getstring(p, 2);
    const chars_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_any_char(h, chars, chars_len)));
}

fn ring_StringRotate(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const n: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_rotate(h, n)), STZ_HANDLE);
}

fn ring_StringRepeatToLength(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const target: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_repeat_to_length(h, target)), STZ_HANDLE);
}

fn ring_StringRemoveBetween(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const open = ring_vm_api_getstring(p, 2);
    const open_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const close = ring_vm_api_getstring(p, 3);
    const close_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_remove_between(h, open, open_len, close, close_len)), STZ_HANDLE);
}

fn ring_StringRemoveBetweenAll(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const open = ring_vm_api_getstring(p, 2);
    const open_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const close = ring_vm_api_getstring(p, 3);
    const close_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_remove_between(h, open, open_len, close, close_len)), STZ_HANDLE);
}

fn ring_StringRemoveFirstBetween(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const open = ring_vm_api_getstring(p, 2);
    const open_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const close = ring_vm_api_getstring(p, 3);
    const close_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_remove_first_between(h, open, open_len, close, close_len)), STZ_HANDLE);
}

fn ring_StringIsBlank(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_blank(h)));
}

fn ring_StringToPascalCase(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_to_pascal_case(h)), STZ_HANDLE);
}

fn ring_StringIsIdentifier(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_identifier(h)));
}

fn ring_StringReplaceBetween(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const open = ring_vm_api_getstring(p, 2);
    const open_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const close = ring_vm_api_getstring(p, 3);
    const close_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    const rep = ring_vm_api_getstring(p, 4);
    const rep_len: usize = @intCast(ring_vm_api_getstringsize(p, 4));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_replace_between(h, open, open_len, close, close_len, rep, rep_len)), STZ_HANDLE);
}

fn ring_StringReplaceBetweenAll(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const open = ring_vm_api_getstring(p, 2);
    const open_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const close = ring_vm_api_getstring(p, 3);
    const close_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    const rep = ring_vm_api_getstring(p, 4);
    const rep_len: usize = @intCast(ring_vm_api_getstringsize(p, 4));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_replace_between(h, open, open_len, close, close_len, rep, rep_len)), STZ_HANDLE);
}

fn ring_StringReplaceFirstBetween(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const open = ring_vm_api_getstring(p, 2);
    const open_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const close = ring_vm_api_getstring(p, 3);
    const close_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    const rep = ring_vm_api_getstring(p, 4);
    const rep_len: usize = @intCast(ring_vm_api_getstringsize(p, 4));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_replace_first_between(h, open, open_len, close, close_len, rep, rep_len)), STZ_HANDLE);
}

fn ring_StringContainsOnly(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const chars = ring_vm_api_getstring(p, 2);
    const chars_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_contains_only(h, chars, chars_len)));
}

fn ring_StringCapitalizeWords(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_capitalize_words(h)), STZ_HANDLE);
}

fn ring_StringSwapChars(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const pos1: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const pos2: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_swap_chars(h, pos1, pos2)), STZ_HANDLE);
}

fn ring_StringEncodeHex(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_encode_hex(h)), STZ_HANDLE);
}

fn ring_StringDecodeHex(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_decode_hex(h)), STZ_HANDLE);
}

fn ring_StringReverseWords(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_reverse_words(h)), STZ_HANDLE);
}

fn ring_StringCollapseSpaces(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_collapse_spaces(h)), STZ_HANDLE);
}

fn ring_StringIsAnagram(p: *anyopaque) callconv(.c) void {
    const h1 = getHandle(p, 1);
    const h2 = getHandle(p, 2);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_anagram(h1, h2)));
}

fn ring_StringMask(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const mask = ring_vm_api_getstring(p, 2);
    const mask_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const keep: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_mask(h, mask, mask_len, keep)), STZ_HANDLE);
}

fn ring_StringCountRuns(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_runs(h)));
}

fn ring_StringHammingDistance(p: *anyopaque) callconv(.c) void {
    const h1 = getHandle(p, 1);
    const h2 = getHandle(p, 2);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_hamming_distance(h1, h2)));
}

fn ring_StringRemoveVowels(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_remove_vowels(h)), STZ_HANDLE);
}

fn ring_StringOnlyVowels(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_only_vowels(h)), STZ_HANDLE);
}

fn ring_StringIsPangram(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_pangram(h)));
}

fn ring_StringNgram(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const size: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const n: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_ngram(h, size, n)), STZ_HANDLE);
}

fn ring_StringNgramCount(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const size: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_ngram_count(h, size)));
}

fn ring_StringCountConsonants(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_consonants(h)));
}

fn ring_StringToSentenceCase(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_to_sentence_case(h)), STZ_HANDLE);
}

fn ring_StringIsBalanced(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_balanced(h)));
}

fn ring_StringSlug(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_slug(h)), STZ_HANDLE);
}

fn ring_StringChunk(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const size: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const n: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_chunk(h, size, n)), STZ_HANDLE);
}

fn ring_StringCountVowels(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_vowels(h)));
}

fn ring_StringLongestRun(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_longest_run(h)));
}

fn ring_StringTrimChars(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const chars: [*c]const u8 = ring_vm_api_getstring(p, 2);
    const chars_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_trim_chars(h, chars, chars_len)), STZ_HANDLE);
}

fn ring_StringIsEmailLike(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_email_like(h)));
}

fn ring_StringCamelToWords(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_camel_to_words(h)), STZ_HANDLE);
}

fn ring_StringInitials(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_initials(h)), STZ_HANDLE);
}

fn ring_StringRemoveDuplicateWords(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_remove_duplicate_words(h)), STZ_HANDLE);
}

fn ring_StringIsUrlLike(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_url_like(h)));
}

fn ring_StringEscapeHtml(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_escape_html(h)), STZ_HANDLE);
}

fn ring_StringUnescapeHtml(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_unescape_html(h)), STZ_HANDLE);
}

fn ring_StringCountSentences(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_sentences(h)));
}

fn ring_StringTitleSmart(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_title_smart(h)), STZ_HANDLE);
}

fn ring_StringRemovePunctuation(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_remove_punctuation(h)), STZ_HANDLE);
}

fn ring_StringIsFloat(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_float(h)));
}

fn ring_StringDigitSum(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_digit_sum(h)));
}

fn ring_StringToAlternatingCase(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_to_alternating_case(h)), STZ_HANDLE);
}

fn ring_StringCountUpper(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_upper(h)));
}

fn ring_StringCountLower(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_lower(h)));
}

fn ring_StringIsCamelCase(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_camel_case(h)));
}

fn ring_StringCommonChars(p: *anyopaque) callconv(.c) void {
    const h1 = getHandle(p, 1);
    const h2 = getHandle(p, 2);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_common_chars(h1, h2)), STZ_HANDLE);
}

fn ring_StringCountLines(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_lines(h)));
}

fn ring_StringSortLines(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_sort_lines(h)), STZ_HANDLE);
}

fn ring_StringUniqueLines(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_unique_lines(h)), STZ_HANDLE);
}

fn ring_StringUniqueLinesCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_unique_lines_cs(h, case)), STZ_HANDLE);
}

fn ring_StringReverseLines(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_reverse_lines(h)), STZ_HANDLE);
}

fn ring_StringIsSnakeCase(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_snake_case(h)));
}

fn ring_StringIsKebabCase(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_kebab_case(h)));
}

fn ring_StringCountUniqueChars(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_unique_chars(h)));
}

fn ring_StringCaesar(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const shift: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_caesar(h, shift)), STZ_HANDLE);
}

fn ring_StringMirror(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_mirror(h)), STZ_HANDLE);
}

fn ring_StringRepeatEachChar(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const n: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_repeat_each_char(h, n)), STZ_HANDLE);
}

fn ring_StringStartsWithAny(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const prefixes: [*c]const u8 = ring_vm_api_getstring(p, 2);
    const plen: c_int = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_starts_with_any(h, prefixes, plen)));
}

fn ring_StringEndsWithAny(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const suffixes: [*c]const u8 = ring_vm_api_getstring(p, 2);
    const slen: c_int = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_ends_with_any(h, suffixes, slen)));
}

fn ring_StringToBinary(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_to_binary(h)), STZ_HANDLE);
}

fn ring_StringSortWords(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_sort_words(h)), STZ_HANDLE);
}

fn ring_StringUniqueWords(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_unique_words(h)), STZ_HANDLE);
}

fn ring_StringFromBinary(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_from_binary(h)), STZ_HANDLE);
}

fn ring_StringSwapWords(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const idx1: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const idx2: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_swap_words(h, idx1, idx2)), STZ_HANDLE);
}

fn ring_StringToPigLatin(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_to_pig_latin(h)), STZ_HANDLE);
}

fn ring_StringRunLengthEncode(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_run_length_encode(h)), STZ_HANDLE);
}

fn ring_StringRunLengthDecode(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_run_length_decode(h)), STZ_HANDLE);
}

fn ring_StringCountParagraphs(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_paragraphs(h)));
}

fn ring_StringZigzag(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const rails: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_zigzag(h, rails)), STZ_HANDLE);
}

fn ring_StringToMorse(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_to_morse(h)), STZ_HANDLE);
}

fn ring_StringToBase64(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_to_base64(h)), STZ_HANDLE);
}

fn ring_StringFromBase64(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_from_base64(h)), STZ_HANDLE);
}

fn ring_StringXorCipher(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const key: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_xor_cipher(h, key)), STZ_HANDLE);
}

fn ring_StringEntropy(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_entropy(h)));
}

fn ring_StringCharFrequencyTop(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_char_frequency_top(h)), STZ_HANDLE);
}

fn ring_StringJaccardSimilarity(p: *anyopaque) callconv(.c) void {
    const h1 = getHandle(p, 1);
    const h2 = getHandle(p, 2);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_jaccard_similarity(h1, h2)));
}

fn ring_StringLongestCommonPrefix(p: *anyopaque) callconv(.c) void {
    const h1 = getHandle(p, 1);
    const h2 = getHandle(p, 2);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_longest_common_prefix(h1, h2)), STZ_HANDLE);
}

fn ring_StringLongestCommonSuffix(p: *anyopaque) callconv(.c) void {
    const h1 = getHandle(p, 1);
    const h2 = getHandle(p, 2);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_longest_common_suffix(h1, h2)), STZ_HANDLE);
}

fn ring_StringWrapWith(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const prefix: [*c]const u8 = ring_vm_api_getstring(p, 2);
    const prefix_len: c_int = @intCast(ring_vm_api_getstringsize(p, 2));
    const suffix: [*c]const u8 = ring_vm_api_getstring(p, 3);
    const suffix_len: c_int = @intCast(ring_vm_api_getstringsize(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_wrap_with(h, prefix, prefix_len, suffix, suffix_len)), STZ_HANDLE);
}

fn ring_StringToTitleCaseStrict(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_to_title_case_strict(h)), STZ_HANDLE);
}

fn ring_StringHammingWeight(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_hamming_weight(h)));
}

fn ring_StringIsPalindromeWords(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_palindrome_words(h)));
}

fn ring_StringRemoveNthWord(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const n: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_remove_nth_word(h, n)), STZ_HANDLE);
}

fn ring_StringInsertWordAt(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const n: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const word: [*c]const u8 = ring_vm_api_getstring(p, 3);
    const wlen: c_int = @intCast(ring_vm_api_getstringsize(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_insert_word_at(h, n, word, wlen)), STZ_HANDLE);
}

fn ring_StringToSpongebobCase(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_to_spongebob_case(h)), STZ_HANDLE);
}

fn ring_StringBetweenFirst(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const open: [*c]const u8 = ring_vm_api_getstring(p, 2);
    const open_len: c_int = @intCast(ring_vm_api_getstringsize(p, 2));
    const close: [*c]const u8 = ring_vm_api_getstring(p, 3);
    const close_len: c_int = @intCast(ring_vm_api_getstringsize(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_between_first(h, open, open_len, close, close_len)), STZ_HANDLE);
}

fn ring_StringBetweenFirstCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const open: [*c]const u8 = ring_vm_api_getstring(p, 2);
    const open_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const close: [*c]const u8 = ring_vm_api_getstring(p, 3);
    const close_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    const cs: c_int = @intFromFloat(ring_vm_api_getnumber(p, 4));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_between_first_cs(h, open, open_len, close, close_len, cs)), STZ_HANDLE);
}

fn ring_StringBetweenLast(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const open: [*c]const u8 = ring_vm_api_getstring(p, 2);
    const open_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const close: [*c]const u8 = ring_vm_api_getstring(p, 3);
    const close_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_between_last(h, open, open_len, close, close_len)), STZ_HANDLE);
}

fn ring_StringReplaceNthBetween(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const open = ring_vm_api_getstring(p, 2);
    const open_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const close = ring_vm_api_getstring(p, 3);
    const close_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    const rep = ring_vm_api_getstring(p, 4);
    const rep_len: usize = @intCast(ring_vm_api_getstringsize(p, 4));
    const nth: c_int = @intFromFloat(ring_vm_api_getnumber(p, 5));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_replace_nth_between(h, open, open_len, close, close_len, rep, rep_len, nth)), STZ_HANDLE);
}

fn ring_StringReplaceLastBetween(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const open = ring_vm_api_getstring(p, 2);
    const open_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const close = ring_vm_api_getstring(p, 3);
    const close_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    const rep = ring_vm_api_getstring(p, 4);
    const rep_len: usize = @intCast(ring_vm_api_getstringsize(p, 4));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_replace_last_between(h, open, open_len, close, close_len, rep, rep_len)), STZ_HANDLE);
}

fn ring_StringRemoveNthBetween(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const open = ring_vm_api_getstring(p, 2);
    const open_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const close = ring_vm_api_getstring(p, 3);
    const close_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    const nth: c_int = @intFromFloat(ring_vm_api_getnumber(p, 4));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_remove_nth_between(h, open, open_len, close, close_len, nth)), STZ_HANDLE);
}

fn ring_StringRemoveLastBetween(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const open = ring_vm_api_getstring(p, 2);
    const open_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const close = ring_vm_api_getstring(p, 3);
    const close_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_remove_last_between(h, open, open_len, close, close_len)), STZ_HANDLE);
}

fn ring_StringToDotCase(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_to_dot_case(h)), STZ_HANDLE);
}

fn ring_StringAbbreviate(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const max_len: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_abbreviate(h, max_len)), STZ_HANDLE);
}

fn ring_StringCountSubstring(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const needle: [*c]const u8 = ring_vm_api_getstring(p, 2);
    const nlen: c_int = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_substring(h, needle, nlen)));
}

fn ring_StringToPathCase(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_to_path_case(h)), STZ_HANDLE);
}

fn ring_StringLeftPad(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const width: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const ch_str: [*c]const u8 = ring_vm_api_getstring(p, 3);
    const pad_char: u8 = if (ch_str != null) ch_str[0] else ' ';
    ring_vm_api_retcpointer(p, @ptrCast(string.str_left_pad(h, width, pad_char)), STZ_HANDLE);
}

fn ring_StringRightPad(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const width: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const ch_str: [*c]const u8 = ring_vm_api_getstring(p, 3);
    const pad_char: u8 = if (ch_str != null) ch_str[0] else ' ';
    ring_vm_api_retcpointer(p, @ptrCast(string.str_right_pad(h, width, pad_char)), STZ_HANDLE);
}

fn ring_StringToHex(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_to_hex(h)), STZ_HANDLE);
}

fn ring_StringFromHex(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_from_hex(h)), STZ_HANDLE);
}

fn ring_StringSoundex(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_soundex(h)), STZ_HANDLE);
}

fn ring_StringVigenereEncrypt(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const key: [*c]const u8 = ring_vm_api_getstring(p, 2);
    const key_len: c_int = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_vigenere_encrypt(h, key, key_len)), STZ_HANDLE);
}

fn ring_StringAtbash(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_atbash(h)), STZ_HANDLE);
}

fn ring_StringCountWordsMatching(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const pat: [*c]const u8 = ring_vm_api_getstring(p, 2);
    const pat_len: c_int = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_words_matching(h, pat, pat_len)));
}

fn ring_StringTruncateWords(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const n: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_truncate_words(h, n)), STZ_HANDLE);
}

fn ring_StringToConstantCase(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_to_constant_case(h)), STZ_HANDLE);
}

fn ring_StringFirstWord(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_first_word(h)), STZ_HANDLE);
}

fn ring_StringLastWord(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_last_word(h)), STZ_HANDLE);
}

fn ring_StringWordsSplit(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_words_split(h)), STZ_HANDLE);
}

fn ring_StringSortNullItems(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_sort_null_items(h)), STZ_HANDLE);
}

fn ring_StringUniqueNullItems(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_unique_null_items(h)), STZ_HANDLE);
}

fn ring_StringToNato(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_to_nato(h)), STZ_HANDLE);
}

fn ring_StringCommonality(p: *anyopaque) callconv(.c) void {
    const h1 = getHandle(p, 1);
    const h2 = getHandle(p, 2);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_commonality(h1, h2)));
}

fn ring_StringDiffChars(p: *anyopaque) callconv(.c) void {
    const h1 = getHandle(p, 1);
    const h2 = getHandle(p, 2);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_diff_chars(h1, h2)), STZ_HANDLE);
}

fn ring_StringRot47(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_rot47(h)), STZ_HANDLE);
}

fn ring_StringIsIsogram(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_isogram(h)));
}

fn ring_StringReverseEachWord(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_reverse_each_word(h)), STZ_HANDLE);
}

fn ring_StringCountDigits(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_digits(h)));
}

fn ring_StringStripTags(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_strip_tags(h)), STZ_HANDLE);
}

fn ring_StringToSlug(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_to_slug(h)), STZ_HANDLE);
}

fn ring_StringCountSpaces(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_spaces(h)));
}

fn ring_StringCountLetters(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_letters(h)));
}

fn ring_StringCountPunctuation(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_punctuation(h)));
}

fn ring_StringCountSymbols(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_symbols(h)));
}

fn ring_StringCountMarks(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_marks(h)));
}

fn ring_StringCountControls(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_controls(h)));
}

// ─── Script-level bulk functions ───

fn ring_StringCountArabic(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_arabic(h)));
}
fn ring_StringCountLatin(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_latin(h)));
}
fn ring_StringCountGreek(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_greek(h)));
}
fn ring_StringCountCyrillic(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_cyrillic(h)));
}
fn ring_StringCountHebrew(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_hebrew(h)));
}
fn ring_StringCountArabicLetters(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_arabic_letters(h)));
}
fn ring_StringCountLatinLetters(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_latin_letters(h)));
}
fn ring_StringIsArabic(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_arabic(h)));
}
fn ring_StringIsLatin(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_latin(h)));
}
fn ring_StringIsArabicLetters(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_arabic_letters(h)));
}
fn ring_StringIsLatinLetters(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_latin_letters(h)));
}
fn ring_StringIsGreek(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_greek(h)));
}
fn ring_StringIsCyrillic(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_cyrillic(h)));
}
fn ring_StringIsHebrew(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_hebrew(h)));
}
fn ring_StringHasArabic(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_has_arabic(h)));
}
fn ring_StringHasLatin(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_has_latin(h)));
}
fn ring_StringHasGreek(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_has_greek(h)));
}
fn ring_StringHasCyrillic(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_has_cyrillic(h)));
}
fn ring_StringHasHebrew(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_has_hebrew(h)));
}
fn ring_StringCountCjk(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_cjk(h)));
}
fn ring_StringCountDevanagari(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_devanagari(h)));
}
fn ring_StringCountThai(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_thai(h)));
}
fn ring_StringOnlyArabic(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_only_arabic(h)), STZ_HANDLE);
}
fn ring_StringOnlyLatin(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_only_latin(h)), STZ_HANDLE);
}
fn ring_StringOnlyArabicLetters(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_only_arabic_letters(h)), STZ_HANDLE);
}
fn ring_StringOnlyLatinLetters(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_only_latin_letters(h)), STZ_HANDLE);
}

fn ring_StringNormalizeSpaces(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_normalize_spaces(h)), STZ_HANDLE);
}

fn ring_StringMaskEmail(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_mask_email(h)), STZ_HANDLE);
}

fn ring_StringPluralize(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_pluralize(h)), STZ_HANDLE);
}

fn ring_StringDeduplicateLines(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_deduplicate_lines(h)), STZ_HANDLE);
}

fn ring_StringRemoveBlankLines(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_remove_blank_lines(h)), STZ_HANDLE);
}

fn ring_StringExtractNumbers(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_extract_numbers(h)), STZ_HANDLE);
}

fn ring_StringExtractEmails(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_extract_emails(h)), STZ_HANDLE);
}

fn ring_StringQuote(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const ch_str: [*c]const u8 = ring_vm_api_getstring(p, 2);
    const qchar: u8 = if (ch_str != null) ch_str[0] else '"';
    ring_vm_api_retcpointer(p, @ptrCast(string.str_quote(h, qchar)), STZ_HANDLE);
}

fn ring_StringUnquote(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_unquote(h)), STZ_HANDLE);
}

fn ring_StringToCsvField(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_to_csv_field(h)), STZ_HANDLE);
}

fn ring_StringNumberLines(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_number_lines(h)), STZ_HANDLE);
}

fn ring_StringHide(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const ch_str: [*c]const u8 = ring_vm_api_getstring(p, 2);
    const mask: u8 = if (ch_str != null) ch_str[0] else '*';
    const kf: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    const kl: c_int = @intFromFloat(ring_vm_api_getnumber(p, 4));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_hide(h, mask, kf, kl)), STZ_HANDLE);
}

fn ring_StringExtractWords(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_extract_words(h)), STZ_HANDLE);
}

fn ring_StringExpandTabs(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const ts: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_expand_tabs(h, ts)), STZ_HANDLE);
}

fn ring_StringSentenceCount(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_sentence_count(h)));
}

fn ring_StringChop(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_chop(h)), STZ_HANDLE);
}

fn ring_StringScanInt(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_scan_int(h)));
}

fn ring_StringToOrdinal(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_to_ordinal(h)), STZ_HANDLE);
}

fn ring_StringCpCount(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_cp_count(h)));
}

fn ring_StringCharsSplit(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_chars_split(h)), STZ_HANDLE);
}

// Return the string's characters as a ready Ring list of 1-codepoint strings,
// built entirely Zig-side. This replaces the fragile NUL-delimited-buffer +
// Ring _SplitNullDelimited round-trip (which dropped trailing multibyte chars
// and intermittently corrupted/crashed on a leading multibyte char).
fn ring_StringCharsList(p: *anyopaque) callconv(.c) void {
    const out = R.ring_vm_api_newlist(p) orelse return;
    const h = getHandle(p, 1);
    if (h) |s| {
        const data = string.str_data(s);
        const size = string.str_size(s);
        if (data != null and size > 0) {
            const buf = data[0..size];
            var off: usize = 0;
            while (off < buf.len) {
                const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch 1;
                const end = @min(off + cp_len, buf.len);
                R.ring_list_addstring2(out, buf.ptr + off, @intCast(end - off));
                off = end;
            }
        }
    }
    R.ring_vm_api_retlist(p, out);
}

// ─── Substrings and unique chars ───

fn ring_StringAllSubstringsCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_all_substrings_cs(h, case)), STZ_HANDLE);
}

fn ring_StringDuplicatedChars(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const result = string.str_duplicated_chars(h);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringUniqueCharsCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_unique_chars_cs(h, case)), STZ_HANDLE);
}

fn ring_StringSubstringsCount(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_substrings_count(h)));
}

fn ring_StringSubstringsOfNChars(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const n: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_substrings_of_n_chars(h, n)), STZ_HANDLE);
}

// ─── Character classification (contains_latin, contains_arabic, has_mixed_case) ───

fn ring_StringContainsLatin(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_contains_latin(h)));
}

fn ring_StringContainsArabic(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_contains_arabic(h)));
}

fn ring_StringHasMixedCase(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_has_mixed_case(h)));
}

// ─── Byte-level extraction (str_left, str_right) ───

fn ring_StringLeft(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const length: usize = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_left(h, length)), STZ_HANDLE);
}

fn ring_StringRight(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const length: usize = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_right(h, length)), STZ_HANDLE);
}

// ─── NLP: Jaro-Winkler, Metaphone, N-grams ───

fn ring_StringJaro(p: *anyopaque) callconv(.c) void {
    const h1 = getHandle(p, 1);
    const h2 = getHandle(p, 2);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_jaro(h1, h2)));
}

fn ring_StringJaroWinkler(p: *anyopaque) callconv(.c) void {
    const h1 = getHandle(p, 1);
    const h2 = getHandle(p, 2);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_jaro_winkler(h1, h2)));
}

fn ring_StringMetaphone(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.str_metaphone(h)), STZ_HANDLE);
}

fn ring_StringCharNgrams(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const n: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_char_ngrams(h, n)), STZ_HANDLE);
}

fn ring_StringWordNgrams(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const n: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_word_ngrams(h, n)), STZ_HANDLE);
}

// ─── CS Unified Functions ───

fn ring_StringFindFirstCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const l = ring_vm_api_getstringsize(p, 2);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_find_first_cs(h, s, l, case)));
}

fn ring_StringFindFirstFromCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const l = ring_vm_api_getstringsize(p, 2);
    const start: usize = @intFromFloat(ring_vm_api_getnumber(p, 3));
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 4));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_find_first_from_cs(h, s, l, start, case)));
}

fn ring_StringFindCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const l = ring_vm_api_getstringsize(p, 2);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_find_cs(h, s, l, case)), FIND_HANDLE);
}

fn ring_StringFindLastCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const l = ring_vm_api_getstringsize(p, 2);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_find_last_cs(h, s, l, case)));
}

fn ring_StringCountOfCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const l = ring_vm_api_getstringsize(p, 2);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_count_of_cs(h, s, l, case)));
}

fn ring_StringContainsCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const l = ring_vm_api_getstringsize(p, 2);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_contains_cs(h, s, l, case)));
}

fn ring_StringStartsWithCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const l = ring_vm_api_getstringsize(p, 2);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_starts_with_cs(h, s, l, case)));
}

fn ring_StringEndsWithCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const l = ring_vm_api_getstringsize(p, 2);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_ends_with_cs(h, s, l, case)));
}

fn ring_StringEqualsCS(p: *anyopaque) callconv(.c) void {
    const h1 = getHandle(p, 1);
    const h2 = getHandle(p, 2);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_equals_cs(h1, h2, case)));
}

fn ring_StringFindNthCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const l = ring_vm_api_getstringsize(p, 2);
    const n: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 4));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_find_nth_cs(h, s, l, n, case)));
}

fn ring_StringReplaceCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const old = ring_vm_api_getstring(p, 2);
    const ol = ring_vm_api_getstringsize(p, 2);
    const new = ring_vm_api_getstring(p, 3);
    const nl = ring_vm_api_getstringsize(p, 3);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 4));
    string.str_replace_cs(h, old, ol, new, nl, case);
}

fn ring_StringRemoveCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const l = ring_vm_api_getstringsize(p, 2);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_remove_cs(h, s, l, case)), STZ_HANDLE);
}

fn ring_StringSplitCountCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const l = ring_vm_api_getstringsize(p, 2);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_split_count_cs(h, s, l, case)));
}

fn ring_StringSplitGetCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const l = ring_vm_api_getstringsize(p, 2);
    const idx: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 4));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_split_get_cs(h, s, l, idx, case)), STZ_HANDLE);
}

// ─── CS batch 2: split, format, compare, replace, inspect ───

fn ring_StringSortLinesCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_sort_lines_cs(h, case)), STZ_HANDLE);
}

fn ring_StringPartitionCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const l = ring_vm_api_getstringsize(p, 2);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_partition_cs(h, s, l, case)), STZ_HANDLE);
}

fn ring_StringPartitionAfterCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const l = ring_vm_api_getstringsize(p, 2);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_partition_after_cs(h, s, l, case)), STZ_HANDLE);
}

fn ring_StringRpartitionCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const l = ring_vm_api_getstringsize(p, 2);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_rpartition_cs(h, s, l, case)), STZ_HANDLE);
}

fn ring_StringRpartitionAfterCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const l = ring_vm_api_getstringsize(p, 2);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_rpartition_after_cs(h, s, l, case)), STZ_HANDLE);
}

fn ring_StringSortNullItemsCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_sort_null_items_cs(h, case)), STZ_HANDLE);
}

fn ring_StringUniqueNullItemsCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_unique_null_items_cs(h, case)), STZ_HANDLE);
}

fn ring_StringEnsurePrefixCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const l = ring_vm_api_getstringsize(p, 2);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_ensure_prefix_cs(h, s, l, case)), STZ_HANDLE);
}

fn ring_StringEnsureSuffixCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const l = ring_vm_api_getstringsize(p, 2);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_ensure_suffix_cs(h, s, l, case)), STZ_HANDLE);
}

fn ring_StringDeduplicateLinesCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_deduplicate_lines_cs(h, case)), STZ_HANDLE);
}

fn ring_StringSortWordsCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_sort_words_cs(h, case)), STZ_HANDLE);
}

fn ring_StringUniqueWordsCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_unique_words_cs(h, case)), STZ_HANDLE);
}

fn ring_StringCompareCS(p: *anyopaque) callconv(.c) void {
    const h1 = getHandle(p, 1);
    const h2 = getHandle(p, 2);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_compare_cs(h1, h2, case)));
}

fn ring_StringPrefixCountCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const l = ring_vm_api_getstringsize(p, 2);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_prefix_count_cs(h, s, l, case)));
}

fn ring_StringSuffixCountCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const l = ring_vm_api_getstringsize(p, 2);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_suffix_count_cs(h, s, l, case)));
}

fn ring_StringCommonPrefixCS(p: *anyopaque) callconv(.c) void {
    const h1 = getHandle(p, 1);
    const h2 = getHandle(p, 2);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_common_prefix_cs(h1, h2, case)), STZ_HANDLE);
}

fn ring_StringCommonSuffixCS(p: *anyopaque) callconv(.c) void {
    const h1 = getHandle(p, 1);
    const h2 = getHandle(p, 2);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_common_suffix_cs(h1, h2, case)), STZ_HANDLE);
}

fn ring_StringCommonCharsCS(p: *anyopaque) callconv(.c) void {
    const h1 = getHandle(p, 1);
    const h2 = getHandle(p, 2);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_common_chars_cs(h1, h2, case)), STZ_HANDLE);
}

fn ring_StringLongestCommonPrefixCS(p: *anyopaque) callconv(.c) void {
    const h1 = getHandle(p, 1);
    const h2 = getHandle(p, 2);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_longest_common_prefix_cs(h1, h2, case)), STZ_HANDLE);
}

fn ring_StringLongestCommonSuffixCS(p: *anyopaque) callconv(.c) void {
    const h1 = getHandle(p, 1);
    const h2 = getHandle(p, 2);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_longest_common_suffix_cs(h1, h2, case)), STZ_HANDLE);
}

fn ring_StringCommonalityCS(p: *anyopaque) callconv(.c) void {
    const h1 = getHandle(p, 1);
    const h2 = getHandle(p, 2);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_commonality_cs(h1, h2, case)));
}

fn ring_StringDiffCharsCS(p: *anyopaque) callconv(.c) void {
    const h1 = getHandle(p, 1);
    const h2 = getHandle(p, 2);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_diff_chars_cs(h1, h2, case)), STZ_HANDLE);
}

fn ring_StringReplaceFirstCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const old = ring_vm_api_getstring(p, 2);
    const ol = ring_vm_api_getstringsize(p, 2);
    const new = ring_vm_api_getstring(p, 3);
    const nl = ring_vm_api_getstringsize(p, 3);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 4));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_replace_first_cs(h, old, ol, new, nl, case)), STZ_HANDLE);
}

fn ring_StringReplaceLastCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const old = ring_vm_api_getstring(p, 2);
    const ol = ring_vm_api_getstringsize(p, 2);
    const new = ring_vm_api_getstring(p, 3);
    const nl = ring_vm_api_getstringsize(p, 3);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 4));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_replace_last_cs(h, old, ol, new, nl, case)), STZ_HANDLE);
}

fn ring_StringReplaceNthCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const old = ring_vm_api_getstring(p, 2);
    const ol = ring_vm_api_getstringsize(p, 2);
    const new = ring_vm_api_getstring(p, 3);
    const nl = ring_vm_api_getstringsize(p, 3);
    const n: c_int = @intFromFloat(ring_vm_api_getnumber(p, 4));
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 5));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_replace_nth_cs(h, old, ol, new, nl, n, case)), STZ_HANDLE);
}

fn ring_StringContainsAnyOfCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const l = ring_vm_api_getstringsize(p, 2);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_contains_any_of_cs(h, s, l, case)));
}

fn ring_StringContainsAllOfCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const l = ring_vm_api_getstringsize(p, 2);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_contains_all_of_cs(h, s, l, case)));
}

fn ring_StringContainsOnlyCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const l = ring_vm_api_getstringsize(p, 2);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_contains_only_cs(h, s, l, case)));
}

fn ring_StringIsAnagramCS(p: *anyopaque) callconv(.c) void {
    const h1 = getHandle(p, 1);
    const h2 = getHandle(p, 2);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_is_anagram_cs(h1, h2, case)));
}

fn ring_StringStartsWithAnyCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const l: c_int = @intCast(ring_vm_api_getstringsize(p, 2));
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_starts_with_any_cs(h, s, l, case)));
}

fn ring_StringEndsWithAnyCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const l: c_int = @intCast(ring_vm_api_getstringsize(p, 2));
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_ends_with_any_cs(h, s, l, case)));
}

// ─── Regex Integration (Phase E) ───

fn ring_StringRegexIsMatch(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const pat = ring_vm_api_getstring(p, 2);
    const pat_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const flags: u32 = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_regex_is_match(h, pat, pat_len, flags)));
}

fn ring_StringRegexCount(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const pat = ring_vm_api_getstring(p, 2);
    const pat_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const flags: u32 = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_regex_count(h, pat, pat_len, flags)));
}

fn ring_StringRegexFindFirst(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const pat = ring_vm_api_getstring(p, 2);
    const pat_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const flags: u32 = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_regex_find_first(h, pat, pat_len, flags)));
}

fn ring_StringRegexFindAll(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const pat = ring_vm_api_getstring(p, 2);
    const pat_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const flags: u32 = @intFromFloat(ring_vm_api_getnumber(p, 3));
    const FR_HANDLE: [*:0]const u8 = "StzFindResultHandle";
    ring_vm_api_retcpointer(p, @ptrCast(string.str_regex_find_all(h, pat, pat_len, flags)), FR_HANDLE);
}

fn ring_StringRegexReplaceAll(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const pat = ring_vm_api_getstring(p, 2);
    const pat_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const repl = ring_vm_api_getstring(p, 3);
    const repl_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    const flags: u32 = @intFromFloat(ring_vm_api_getnumber(p, 4));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_regex_replace_all(h, pat, pat_len, repl, repl_len, flags)), STZ_HANDLE);
}

fn ring_StringRegexSplitCount(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const pat = ring_vm_api_getstring(p, 2);
    const pat_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const flags: u32 = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_regex_split_count(h, pat, pat_len, flags)));
}

fn ring_StringRegexSplitGet(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const pat = ring_vm_api_getstring(p, 2);
    const pat_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const flags: u32 = @intFromFloat(ring_vm_api_getnumber(p, 3));
    const idx: c_int = @intFromFloat(ring_vm_api_getnumber(p, 4));
    const result = string.str_regex_split_get(h, pat, pat_len, flags, idx);
    if (result) |rs_h| {
        const data = string.str_data(rs_h);
        const size = string.str_size(rs_h);
        if (data != null and size > 0) {
            ring_vm_api_retstring2(p, data, @intCast(size));
        } else {
            ring_vm_api_retstring(p, "");
        }
        string.str_free(rs_h);
    } else {
        ring_vm_api_retstring(p, "");
    }
}

// ─── Between CS / Section CP ───

fn ring_StringBetweenCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const open: [*c]const u8 = ring_vm_api_getstring(p, 2);
    const open_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const close: [*c]const u8 = ring_vm_api_getstring(p, 3);
    const close_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    const cs: c_int = @intFromFloat(ring_vm_api_getnumber(p, 4));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_between_cs(h, open, open_len, close, close_len, cs)), STZ_HANDLE);
}

fn ring_StringSectionCP(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const start_cp: i64 = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const end_cp: i64 = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_section_cp(h, start_cp, end_cp)), STZ_HANDLE);
}

// ─── Registration ───
// Ring lowercases all function names, so registered names must be lowercase.

const regs = [_]R.Reg{
    // Error reporting
    .{ .name = "stzenginestringlasterror", .func = &ring_StringLastError },
    .{ .name = "stzenginestringclearerror", .func = &ring_StringClearError },
    // Lifecycle
    .{ .name = "stzenginestringnew", .func = &ring_StringNew },
    .{ .name = "stzenginestring", .func = &ring_StringFrom },
    .{ .name = "stzenginestringfree", .func = &ring_StringFree },
    .{ .name = "stzenginestringdata", .func = &ring_StringData },
    .{ .name = "stzenginestringsize", .func = &ring_StringSize },
    .{ .name = "stzenginestringcount", .func = &ring_StringCount },
    .{ .name = "stzenginestringappend", .func = &ring_StringAppend },
    .{ .name = "stzenginestringinsert", .func = &ring_StringInsert },
    .{ .name = "stzenginestringmid", .func = &ring_StringMid },
    .{ .name = "stzenginestringtrimmed", .func = &ring_StringTrimmed },
    .{ .name = "stzenginestringfindfirst", .func = &ring_StringFindFirst },
    .{ .name = "stzenginestringfindfirstfrom", .func = &ring_StringFindFirstFrom },
    .{ .name = "stzenginestringbytetocp", .func = &ring_StringByteToCp },
    .{ .name = "stzenginestringcountof", .func = &ring_StringCountOf },
    .{ .name = "stzenginestringsubstrings", .func = &ring_StringSubStrings },
    .{ .name = "stzenginestringsubstringsuniquecs", .func = &ring_StringSubStringsUnique },
    .{ .name = "stzenginestringsubstringsbycountcs", .func = &ring_StringSubStringsByCount },
    .{ .name = "stzenginestringconsecutivesubstringsofn", .func = &ring_StringConsecutiveSubStringsOfN },
    .{ .name = "stzenginestringconsecutivesubstrings", .func = &ring_StringConsecutiveSubStrings },
    .{ .name = "stzenginestringwindowsuptohalf", .func = &ring_StringWindowsUptoHalf },
    .{ .name = "stzenginestringfinddupsecutivecharscs", .func = &ring_StringFindDupSecutiveChars },
    .{ .name = "stzenginestringfinddupsecutivesubstringcs", .func = &ring_StringFindDupSecutiveSubString },
    .{ .name = "stzenginestrlistcount", .func = &ring_StrListCount },
    .{ .name = "stzenginestrlistget", .func = &ring_StrListGet },
    .{ .name = "stzenginestrlistfree", .func = &ring_StrListFree },
    .{ .name = "stzenginestringfindlast", .func = &ring_StringFindLast },
    .{ .name = "stzenginestringcontains", .func = &ring_StringContains },
    .{ .name = "stzenginestringstartswith", .func = &ring_StringStartsWith },
    .{ .name = "stzenginestringendswith", .func = &ring_StringEndsWith },
    .{ .name = "stzenginestringfind", .func = &ring_StringFind },
    .{ .name = "stzenginefindresultcount", .func = &ring_FindResultCount },
    .{ .name = "stzenginefindresultget", .func = &ring_FindResultGet },
    .{ .name = "stzenginefindresultfree", .func = &ring_FindResultFree },
    .{ .name = "stzenginestringreplace", .func = &ring_StringReplace },
    .{ .name = "stzenginestringreplacerange", .func = &ring_StringReplaceRange },
    .{ .name = "stzenginestringsplitcount", .func = &ring_StringSplitCount },
    .{ .name = "stzenginestringsplitget", .func = &ring_StringSplitGet },
    .{ .name = "stzenginestringtoupper", .func = &ring_StringToUpper },
    .{ .name = "stzenginestringtolower", .func = &ring_StringToLower },
    .{ .name = "stzenginestringdotless", .func = &ring_StringDotless },
    .{ .name = "stzenginestringgroupinsert", .func = &ring_StringGroupInsert },
    .{ .name = "stzenginestringtotitle", .func = &ring_StringToTitle },
    .{ .name = "stzenginestringcharat", .func = &ring_StringCharAt },
    .{ .name = "stzenginestringmidcp", .func = &ring_StringMidCp },
    .{ .name = "stzenginestringgraphemecount", .func = &ring_StringGraphemeCount },
    .{ .name = "stzenginestringnormalize", .func = &ring_StringNormalize },
    .{ .name = "stzenginestringstripmarks", .func = &ring_StringStripMarks },
    .{ .name = "stzenginecharunicode", .func = &ring_CharUnicode },
    .{ .name = "stzenginechartoutf8", .func = &ring_CharToUtf8 },
    .{ .name = "stzenginecharisletter", .func = &ring_CharIsLetter },
    .{ .name = "stzenginecharisdigit", .func = &ring_CharIsDigit },
    .{ .name = "stzenginecharisupper", .func = &ring_CharIsUpper },
    .{ .name = "stzenginecharislower", .func = &ring_CharIsLower },
    .{ .name = "stzenginestringnthchar", .func = &ring_StringNthChar },
    .{ .name = "stzenginestringslice", .func = &ring_StringSlice },
    .{ .name = "stzenginestringreverse", .func = &ring_StringReverse },
    .{ .name = "stzenginestringfoldcase", .func = &ring_StringFoldcase },
    .{ .name = "stzenginestringrepeat", .func = &ring_StringRepeat },
    .{ .name = "stzenginestringpadleft", .func = &ring_StringPadLeft },
    .{ .name = "stzenginestringpadright", .func = &ring_StringPadRight },
    .{ .name = "stzenginestringremoverange", .func = &ring_StringRemoveRange },
    .{ .name = "stzenginestringtrimleft", .func = &ring_StringTrimLeft },
    .{ .name = "stzenginestringtrimright", .func = &ring_StringTrimRight },
    .{ .name = "stzenginestringequals", .func = &ring_StringEquals },
    .{ .name = "stzenginestringreplacefirst", .func = &ring_StringReplaceFirst },
    .{ .name = "stzenginestringreplacelast", .func = &ring_StringReplaceLast },
    .{ .name = "stzenginestringreplacenth", .func = &ring_StringReplaceNth },
    .{ .name = "stzenginestringisempty", .func = &ring_StringIsEmpty },
    .{ .name = "stzenginestringbetween", .func = &ring_StringBetween },
    .{ .name = "stzenginestringbetweenall", .func = &ring_StringBetweenAll },
    .{ .name = "stzenginestringbetweenallcs", .func = &ring_StringBetweenAllCS },
    .{ .name = "stzenginestringcountcharsoftype", .func = &ring_StringCountCharsOfType },
    .{ .name = "stzenginestringisnumeric", .func = &ring_StringIsNumeric },
    .{ .name = "stzenginestringisalpha", .func = &ring_StringIsAlpha },
    .{ .name = "stzenginestringfindnth", .func = &ring_StringFindNth },
    .{ .name = "stzenginestringinsertcp", .func = &ring_StringInsertCp },
    .{ .name = "stzenginestringleftcp", .func = &ring_StringLeftCp },
    .{ .name = "stzenginestringrightcp", .func = &ring_StringRightCp },
    .{ .name = "stzenginestringremove", .func = &ring_StringRemove },
    .{ .name = "stzenginestringremove", .func = &ring_StringRemove },
    .{ .name = "stzenginestringlinescount", .func = &ring_StringLinesCount },
    .{ .name = "stzenginestringispalindrome", .func = &ring_StringIsPalindrome },
    .{ .name = "stzenginestringconcat", .func = &ring_StringConcat },
    .{ .name = "stzenginestringisascii", .func = &ring_StringIsAscii },
    .{ .name = "stzenginestringremovecharat", .func = &ring_StringRemoveCharAt },
    .{ .name = "stzenginestringchartypeat", .func = &ring_StringCharTypeAt },
    .{ .name = "stzenginestringfindcharsoftype", .func = &ring_StringFindCharsOfType },
    .{ .name = "stzenginestringextractcharsoftype", .func = &ring_StringExtractCharsOfType },
    .{ .name = "stzenginestringisuppercase", .func = &ring_StringIsUppercase },
    .{ .name = "stzenginestringislowercase", .func = &ring_StringIsLowercase },
    .{ .name = "stzenginestringiswhitespace", .func = &ring_StringIsWhitespace },
    .{ .name = "stzenginestringwordcount", .func = &ring_StringWordCount },
    .{ .name = "stzenginestringisonlytype", .func = &ring_StringIsOnlyType },
    .{ .name = "stzenginestringremovecharsoftype", .func = &ring_StringRemoveCharsOfType },
    .{ .name = "stzenginestringtrim", .func = &ring_StringTrim },
    .{ .name = "stzenginestringswapcase", .func = &ring_StringSwapCase },
    .{ .name = "stzenginestringuniquechars", .func = &ring_StringUniqueChars },
    .{ .name = "stzenginestringuniquecharscount", .func = &ring_StringUniqueCharCount },
    .{ .name = "stzenginestringisalphaonly", .func = &ring_StringIsAlphaOnly },
    .{ .name = "stzenginestringisalnum", .func = &ring_StringIsAlnum },
    .{ .name = "stzenginestringcontainschar", .func = &ring_StringContainsChar },
    .{ .name = "stzenginestringbetweennth", .func = &ring_StringBetweenNth },
    .{ .name = "stzenginestringcountbetween", .func = &ring_StringCountBetween },
    .{ .name = "stzenginestringreplacecharat", .func = &ring_StringReplaceCharAt },
    .{ .name = "stzenginestringsimplify", .func = &ring_StringSimplify },
    .{ .name = "stzenginestringstartswithletter", .func = &ring_StringStartsWithLetter },
    .{ .name = "stzenginestringstartswithdigit", .func = &ring_StringStartsWithDigit },
    .{ .name = "stzenginestringendswithletter", .func = &ring_StringEndsWithLetter },
    .{ .name = "stzenginestringendswithdigit", .func = &ring_StringEndsWithDigit },
    .{ .name = "stzenginestringlevenshteindistance", .func = &ring_StringLevenshtein },
    .{ .name = "stzenginestringistitlecase", .func = &ring_StringIsTitleCase },
    .{ .name = "stzenginestringlinessplitcount", .func = &ring_StringLinesSplitCount },
    .{ .name = "stzenginestringlineat", .func = &ring_StringLineAt },
    .{ .name = "stzenginestringisword", .func = &ring_StringIsWord },
    .{ .name = "stzenginestringcountleadingchar", .func = &ring_StringCountLeadingChar },
    .{ .name = "stzenginestringcounttrailingchar", .func = &ring_StringCountTrailingChar },
    .{ .name = "stzenginestringisnumericstring", .func = &ring_StringIsNumericString },
    .{ .name = "stzenginestringurlencode", .func = &ring_StringURLEncode },
    .{ .name = "stzenginestringurldecode", .func = &ring_StringURLDecode },
    .{ .name = "stzenginestringcharattostring", .func = &ring_StringCharAtToString },
    .{ .name = "stzenginestringspacify", .func = &ring_StringSpacify },
    .{ .name = "stzenginestringbytesperchar", .func = &ring_StringBytesPerChar },
    .{ .name = "stzenginestringishexstring", .func = &ring_StringIsHexString },
    .{ .name = "stzenginestringisbinarystring", .func = &ring_StringIsBinaryString },
    .{ .name = "stzenginestringisoctalstring", .func = &ring_StringIsOctalString },
    .{ .name = "stzenginestringwordat", .func = &ring_StringWordAt },
    .{ .name = "stzenginestringcenter", .func = &ring_StringCenter },
    .{ .name = "stzenginestringremoveconsecutiveduplicates", .func = &ring_StringRemoveConsecutiveDuplicates },
    .{ .name = "stzenginestringsubstring", .func = &ring_StringSubstring },
    .{ .name = "stzenginestringreplacesubstring", .func = &ring_StringReplaceSubstring },
    .{ .name = "stzenginestringprefixcount", .func = &ring_StringPrefixCount },
    .{ .name = "stzenginestringsuffixcount", .func = &ring_StringSuffixCount },
    .{ .name = "stzenginestringcommonprefix", .func = &ring_StringCommonPrefix },
    .{ .name = "stzenginestringcommonsuffix", .func = &ring_StringCommonSuffix },
    .{ .name = "stzenginestringsortcharsasc", .func = &ring_StringSortCharsAsc },
    .{ .name = "stzenginestringsortcharsdesc", .func = &ring_StringSortCharsDesc },
    .{ .name = "stzenginestringfindchar", .func = &ring_StringFindChar },
    .{ .name = "stzenginestringduplicatesubstringscs", .func = &ring_StringDuplicateSubstringsCS },
    .{ .name = "stzenginestringhash", .func = &ring_StringHash },
    .{ .name = "stzenginestringsha256", .func = &ring_StringSha256 },
    .{ .name = "stzenginestringmd5", .func = &ring_StringMd5 },
    .{ .name = "stzenginestringblake3", .func = &ring_StringBlake3 },
    .{ .name = "stzenginestringhmacsha256", .func = &ring_StringHmacSha256 },
    .{ .name = "stzenginestringdetectscript", .func = &ring_StringDetectScript },
    .{ .name = "stzenginestringscriptname", .func = &ring_StringScriptName },
    .{ .name = "stzenginestringdetectdirection", .func = &ring_StringDetectDirection },
    .{ .name = "stzenginestringdirectionname", .func = &ring_StringDirectionName },
    .{ .name = "stzenginestringhasrtl", .func = &ring_StringHasRTL },
    .{ .name = "stzenginestringscriptcount", .func = &ring_StringScriptCount },
    .{ .name = "stzenginestringlocalecompare", .func = &ring_StringLocaleCompare },
    .{ .name = "stzenginestringcountchar", .func = &ring_StringCountChar },
    .{ .name = "stzenginestringreplacechar", .func = &ring_StringReplaceChar },
    .{ .name = "stzenginestringcopy", .func = &ring_StringCopy },
    .{ .name = "stzenginestringcompare", .func = &ring_StringCompare },
    .{ .name = "stzenginestringremovefirst", .func = &ring_StringRemoveFirst },
    .{ .name = "stzenginestringremovelast", .func = &ring_StringRemoveLast },
    .{ .name = "stzenginestringremoventh", .func = &ring_StringRemoveNth },
    .{ .name = "stzenginestringischarssortedasc", .func = &ring_StringIsCharsSortedAsc },
    .{ .name = "stzenginestringischarssorteddesc", .func = &ring_StringIsCharsSortedDesc },
    .{ .name = "stzenginestringrepeatchar", .func = &ring_StringRepeatChar },
    .{ .name = "stzenginestringinsertbeforeeach", .func = &ring_StringInsertBeforeEach },
    .{ .name = "stzenginestringinsertaftereach", .func = &ring_StringInsertAfterEach },
    .{ .name = "stzenginestringinsertbeforeeachcs", .func = &ring_StringInsertBeforeEachCS },
    .{ .name = "stzenginestringinsertaftereachcs", .func = &ring_StringInsertAfterEachCS },
    .{ .name = "stzenginestringtruncate", .func = &ring_StringTruncate },
    .{ .name = "stzenginestringwrapat", .func = &ring_StringWrapAt },
    .{ .name = "stzenginestringremoveprefix", .func = &ring_StringRemovePrefix },
    .{ .name = "stzenginestringremovesuffix", .func = &ring_StringRemoveSuffix },
    .{ .name = "stzenginestringensureprefix", .func = &ring_StringEnsurePrefix },
    .{ .name = "stzenginestringensuresuffix", .func = &ring_StringEnsureSuffix },
    .{ .name = "stzenginestringsqueezechar", .func = &ring_StringSqueezeChar },
    .{ .name = "stzenginestringcapitalizefirst", .func = &ring_StringCapitalizeFirst },
    .{ .name = "stzenginestringdecapitalizefirst", .func = &ring_StringDecapitalizeFirst },
    .{ .name = "stzenginestringzfill", .func = &ring_StringZFill },
    .{ .name = "stzenginestringtabexpand", .func = &ring_StringTabExpand },
    .{ .name = "stzenginestringcountoverlapping", .func = &ring_StringCountOverlapping },
    .{ .name = "stzenginestringreplaceat", .func = &ring_StringReplaceAt },
    .{ .name = "stzenginestringcharfrequency", .func = &ring_StringCharFrequency },
    .{ .name = "stzenginestringcontainsanyof", .func = &ring_StringContainsAnyOf },
    .{ .name = "stzenginestringcontainsallof", .func = &ring_StringContainsAllOf },
    .{ .name = "stzenginestringcenterpad", .func = &ring_StringCenterPad },
    .{ .name = "stzenginestringonlyletters", .func = &ring_StringOnlyLetters },
    .{ .name = "stzenginestringonlydigits", .func = &ring_StringOnlyDigits },
    .{ .name = "stzenginestringonlypunctuation", .func = &ring_StringOnlyPunctuation },
    .{ .name = "stzenginestringonlysymbols", .func = &ring_StringOnlySymbols },
    .{ .name = "stzenginestringonlyspaces", .func = &ring_StringOnlySpaces },
    .{ .name = "stzenginestringonlymarks", .func = &ring_StringOnlyMarks },
    .{ .name = "stzenginestringonlycontrols", .func = &ring_StringOnlyControls },
    .{ .name = "stzenginestringispunctuation", .func = &ring_StringIsPunctuation2 },
    .{ .name = "stzenginestringissymbol", .func = &ring_StringIsSymbol },
    .{ .name = "stzenginestringismark", .func = &ring_StringIsMark },
    .{ .name = "stzenginestringiscontrol", .func = &ring_StringIsControl },
    .{ .name = "stzenginestringhaspunctuation", .func = &ring_StringHasPunctuation },
    .{ .name = "stzenginestringhassymbol", .func = &ring_StringHasSymbol },
    .{ .name = "stzenginestringhasmark", .func = &ring_StringHasMark },
    .{ .name = "stzenginestringcharunicodeat", .func = &ring_StringCharUnicodeAt },
    .{ .name = "stzenginestringcharcategoryat", .func = &ring_StringCharCategoryAt },
    .{ .name = "stzenginestringcharcategorystringat", .func = &ring_StringCharCategoryStringAt },
    .{ .name = "stzenginestringcharispunctuationat", .func = &ring_StringCharIsPunctuationAt },
    .{ .name = "stzenginestringcharissymbolat", .func = &ring_StringCharIsSymbolAt },
    .{ .name = "stzenginestringcharismarkat", .func = &ring_StringCharIsMarkAt },
    .{ .name = "stzenginestringchariscontrolat", .func = &ring_StringCharIsControlAt },
    .{ .name = "stzenginestringcharisspaceat", .func = &ring_StringCharIsSpaceAt },
    .{ .name = "stzenginestringremovewhitespace", .func = &ring_StringRemoveWhitespace },
    .{ .name = "stzenginestringcountwords", .func = &ring_StringCountWords },
    .{ .name = "stzenginestringnthword", .func = &ring_StringNthWord },
    .{ .name = "stzenginestringcharsbetween", .func = &ring_StringCharsBetween },
    .{ .name = "stzenginestringisalphanumeric", .func = &ring_StringIsAlphanumeric },
    .{ .name = "stzenginestringljust", .func = &ring_StringLjust },
    .{ .name = "stzenginestringrjust", .func = &ring_StringRjust },
    .{ .name = "stzenginestringindent", .func = &ring_StringIndent },
    .{ .name = "stzenginestringdedent", .func = &ring_StringDedent },
    .{ .name = "stzenginestringtocamelcase", .func = &ring_StringToCamelCase },
    .{ .name = "stzenginestringtosnakecase", .func = &ring_StringToSnakeCase },
    .{ .name = "stzenginestringtokebabcase", .func = &ring_StringToKebabCase },
    .{ .name = "stzenginestringpartition", .func = &ring_StringPartition },
    .{ .name = "stzenginestringpartitionafter", .func = &ring_StringPartitionAfter },
    .{ .name = "stzenginestringrpartition", .func = &ring_StringRpartition },
    .{ .name = "stzenginestringrpartitionafter", .func = &ring_StringRpartitionAfter },
    .{ .name = "stzenginestringsqueeze", .func = &ring_StringSqueeze },
    .{ .name = "stzenginestringisdigit", .func = &ring_StringIsDigit },
    .{ .name = "stzenginestringinterleave", .func = &ring_StringInterleave },
    .{ .name = "stzenginestringstripchars", .func = &ring_StringStripChars },
    .{ .name = "stzenginestringkeepchars", .func = &ring_StringKeepChars },
    .{ .name = "stzenginestringreplace2", .func = &ring_StringReplace2 },
    .{ .name = "stzenginestringsurround", .func = &ring_StringSurround },
    .{ .name = "stzenginestringreplaceanychar", .func = &ring_StringReplaceAnyChar },
    .{ .name = "stzenginestringcountanychar", .func = &ring_StringCountAnyChar },
    .{ .name = "stzenginestringrotate", .func = &ring_StringRotate },
    .{ .name = "stzenginestringrepeattolength", .func = &ring_StringRepeatToLength },
    .{ .name = "stzenginestringremovebetween", .func = &ring_StringRemoveBetween },
    .{ .name = "stzenginestringremovebetweenall", .func = &ring_StringRemoveBetweenAll },
    .{ .name = "stzenginestringisblank", .func = &ring_StringIsBlank },
    .{ .name = "stzenginestringtopascalcase", .func = &ring_StringToPascalCase },
    .{ .name = "stzenginestringisidentifier", .func = &ring_StringIsIdentifier },
    .{ .name = "stzenginestringreplacebetween", .func = &ring_StringReplaceBetween },
    .{ .name = "stzenginestringreplacebetweenall", .func = &ring_StringReplaceBetweenAll },
    .{ .name = "stzenginestringcontainsonly", .func = &ring_StringContainsOnly },
    .{ .name = "stzenginestringcapitalizewords", .func = &ring_StringCapitalizeWords },
    .{ .name = "stzenginestringswapchars", .func = &ring_StringSwapChars },
    .{ .name = "stzenginestringencodehex", .func = &ring_StringEncodeHex },
    .{ .name = "stzenginestringdecodehex", .func = &ring_StringDecodeHex },
    .{ .name = "stzenginestringreversewords", .func = &ring_StringReverseWords },
    .{ .name = "stzenginestringcollapsespaces", .func = &ring_StringCollapseSpaces },
    .{ .name = "stzenginestringisanagram", .func = &ring_StringIsAnagram },
    .{ .name = "stzenginestringmask", .func = &ring_StringMask },
    .{ .name = "stzenginestringcountruns", .func = &ring_StringCountRuns },
    .{ .name = "stzenginestringhammingdistance", .func = &ring_StringHammingDistance },
    .{ .name = "stzenginestringremovevowels", .func = &ring_StringRemoveVowels },
    .{ .name = "stzenginestringonlyvowels", .func = &ring_StringOnlyVowels },
    .{ .name = "stzenginestringispangram", .func = &ring_StringIsPangram },
    .{ .name = "stzenginestringngram", .func = &ring_StringNgram },
    .{ .name = "stzenginestringngramcount", .func = &ring_StringNgramCount },
    .{ .name = "stzenginestringcountconsonants", .func = &ring_StringCountConsonants },
    .{ .name = "stzenginestringtosentencecase", .func = &ring_StringToSentenceCase },
    .{ .name = "stzenginestringisbalanced", .func = &ring_StringIsBalanced },
    .{ .name = "stzenginestringslug", .func = &ring_StringSlug },
    .{ .name = "stzenginestringchunk", .func = &ring_StringChunk },
    .{ .name = "stzenginestringcountvowels", .func = &ring_StringCountVowels },
    .{ .name = "stzenginestringlongestrun", .func = &ring_StringLongestRun },
    .{ .name = "stzenginestringtrimchars", .func = &ring_StringTrimChars },
    .{ .name = "stzenginestringisemaillike", .func = &ring_StringIsEmailLike },
    .{ .name = "stzenginestringcameltowords", .func = &ring_StringCamelToWords },
    .{ .name = "stzenginestringinitials", .func = &ring_StringInitials },
    .{ .name = "stzenginestringremoveduplicatewords", .func = &ring_StringRemoveDuplicateWords },
    .{ .name = "stzenginestringisurllike", .func = &ring_StringIsUrlLike },
    .{ .name = "stzenginestringescapehtml", .func = &ring_StringEscapeHtml },
    .{ .name = "stzenginestringunescapehtml", .func = &ring_StringUnescapeHtml },
    .{ .name = "stzenginestringcountsentences", .func = &ring_StringCountSentences },
    .{ .name = "stzenginestringtitlesmart", .func = &ring_StringTitleSmart },
    .{ .name = "stzenginestringremovepunctuation", .func = &ring_StringRemovePunctuation },
    .{ .name = "stzenginestringisfloat", .func = &ring_StringIsFloat },
    .{ .name = "stzenginestringdigitsum", .func = &ring_StringDigitSum },
    .{ .name = "stzenginestringtoalternatingcase", .func = &ring_StringToAlternatingCase },
    .{ .name = "stzenginestringcountupper", .func = &ring_StringCountUpper },
    .{ .name = "stzenginestringcountlower", .func = &ring_StringCountLower },
    .{ .name = "stzenginestringiscamelcase", .func = &ring_StringIsCamelCase },
    .{ .name = "stzenginestringcommonchars", .func = &ring_StringCommonChars },
    .{ .name = "stzenginestringcountlines", .func = &ring_StringCountLines },
    .{ .name = "stzenginestringsortlines", .func = &ring_StringSortLines },
    .{ .name = "stzenginestringuniquelines", .func = &ring_StringUniqueLines },
    .{ .name = "stzenginestringuniquelinescs", .func = &ring_StringUniqueLinesCS },
    .{ .name = "stzenginestringreverselines", .func = &ring_StringReverseLines },
    .{ .name = "stzenginestringissnakecase", .func = &ring_StringIsSnakeCase },
    .{ .name = "stzenginestringiskebabcase", .func = &ring_StringIsKebabCase },
    .{ .name = "stzenginestringcountuniquechars", .func = &ring_StringCountUniqueChars },
    .{ .name = "stzenginestringcaesar", .func = &ring_StringCaesar },
    .{ .name = "stzenginestringmirror", .func = &ring_StringMirror },
    .{ .name = "stzenginestringrepeateachchar", .func = &ring_StringRepeatEachChar },
    .{ .name = "stzenginestringbeginswithanyx", .func = &ring_StringStartsWithAny },
    .{ .name = "stzenginestringfinisheswithanyx", .func = &ring_StringEndsWithAny },
    .{ .name = "stzenginestringtobinary", .func = &ring_StringToBinary },
    .{ .name = "stzenginestringsortwords", .func = &ring_StringSortWords },
    .{ .name = "stzenginestringuniquewords", .func = &ring_StringUniqueWords },
    .{ .name = "stzenginestringbinary", .func = &ring_StringFromBinary },
    .{ .name = "stzenginestringswapwords", .func = &ring_StringSwapWords },
    .{ .name = "stzenginestringtopiglatin", .func = &ring_StringToPigLatin },
    .{ .name = "stzenginestringrunlengthencode", .func = &ring_StringRunLengthEncode },
    .{ .name = "stzenginestringrunlengthdecode", .func = &ring_StringRunLengthDecode },
    .{ .name = "stzenginestringcountparagraphs", .func = &ring_StringCountParagraphs },
    .{ .name = "stzenginestringzigzag", .func = &ring_StringZigzag },
    .{ .name = "stzenginestringtomorse", .func = &ring_StringToMorse },
    .{ .name = "stzenginestringtobase64", .func = &ring_StringToBase64 },
    .{ .name = "stzenginestringbase64", .func = &ring_StringFromBase64 },
    .{ .name = "stzenginestringxorcipher", .func = &ring_StringXorCipher },
    .{ .name = "stzenginestringentropy", .func = &ring_StringEntropy },
    .{ .name = "stzenginestringcharfrequencytop", .func = &ring_StringCharFrequencyTop },
    .{ .name = "stzenginestringjaccardsimilarity", .func = &ring_StringJaccardSimilarity },
    .{ .name = "stzenginestringlongestcommonprefix", .func = &ring_StringLongestCommonPrefix },
    .{ .name = "stzenginestringlongestcommonsuffix", .func = &ring_StringLongestCommonSuffix },
    .{ .name = "stzenginestringwrapwith", .func = &ring_StringWrapWith },
    .{ .name = "stzenginestringtotitlecasestrict", .func = &ring_StringToTitleCaseStrict },
    .{ .name = "stzenginestringhammingweight", .func = &ring_StringHammingWeight },
    .{ .name = "stzenginestringispalindromewords", .func = &ring_StringIsPalindromeWords },
    .{ .name = "stzenginestringremoventhword", .func = &ring_StringRemoveNthWord },
    .{ .name = "stzenginestringinsertwordat", .func = &ring_StringInsertWordAt },
    .{ .name = "stzenginestringtospongebobcase", .func = &ring_StringToSpongebobCase },
    .{ .name = "stzenginestringbetweenfirst", .func = &ring_StringBetweenFirst },
    .{ .name = "stzenginestringbetweenfirstcs", .func = &ring_StringBetweenFirstCS },
    .{ .name = "stzenginestringbetweenlast", .func = &ring_StringBetweenLast },
    .{ .name = "stzenginestringreplacefirstbetween", .func = &ring_StringReplaceFirstBetween },
    .{ .name = "stzenginestringreplacenthbetween", .func = &ring_StringReplaceNthBetween },
    .{ .name = "stzenginestringreplacelastbetween", .func = &ring_StringReplaceLastBetween },
    .{ .name = "stzenginestringremovefirstbetween", .func = &ring_StringRemoveFirstBetween },
    .{ .name = "stzenginestringremoventhbetween", .func = &ring_StringRemoveNthBetween },
    .{ .name = "stzenginestringremovelastbetween", .func = &ring_StringRemoveLastBetween },
    .{ .name = "stzenginestringtodotcase", .func = &ring_StringToDotCase },
    .{ .name = "stzenginestringabbreviate", .func = &ring_StringAbbreviate },
    .{ .name = "stzenginestringcountsubstring", .func = &ring_StringCountSubstring },
    .{ .name = "stzenginestringtopathcase", .func = &ring_StringToPathCase },
    .{ .name = "stzenginestringleftpad", .func = &ring_StringLeftPad },
    .{ .name = "stzenginestringrightpad", .func = &ring_StringRightPad },
    .{ .name = "stzenginestringtohex", .func = &ring_StringToHex },
    .{ .name = "stzenginestringhex", .func = &ring_StringFromHex },
    .{ .name = "stzenginestringsoundex", .func = &ring_StringSoundex },
    .{ .name = "stzenginestringvigenereencrypt", .func = &ring_StringVigenereEncrypt },
    .{ .name = "stzenginestringatbash", .func = &ring_StringAtbash },
    .{ .name = "stzenginestringcountwordsmatching", .func = &ring_StringCountWordsMatching },
    .{ .name = "stzenginestringtruncatewords", .func = &ring_StringTruncateWords },
    .{ .name = "stzenginestringtoconstantcase", .func = &ring_StringToConstantCase },
    .{ .name = "stzenginestringfirstword", .func = &ring_StringFirstWord },
    .{ .name = "stzenginestringlastword", .func = &ring_StringLastWord },
    .{ .name = "stzenginestringwordssplit", .func = &ring_StringWordsSplit },
    .{ .name = "stzenginestringsortnullitems", .func = &ring_StringSortNullItems },
    .{ .name = "stzenginestringuniquenullitems", .func = &ring_StringUniqueNullItems },
    .{ .name = "stzenginestringtonato", .func = &ring_StringToNato },
    .{ .name = "stzenginestringcommonality", .func = &ring_StringCommonality },
    .{ .name = "stzenginestringdiffchars", .func = &ring_StringDiffChars },
    .{ .name = "stzenginestringrot47", .func = &ring_StringRot47 },
    .{ .name = "stzenginestringisisogram", .func = &ring_StringIsIsogram },
    .{ .name = "stzenginestringreverseeachword", .func = &ring_StringReverseEachWord },
    .{ .name = "stzenginestringcountdigits", .func = &ring_StringCountDigits },
    .{ .name = "stzenginestringstriptags", .func = &ring_StringStripTags },
    .{ .name = "stzenginestringtoslug", .func = &ring_StringToSlug },
    .{ .name = "stzenginestringcountspaces", .func = &ring_StringCountSpaces },
    .{ .name = "stzenginestringcountletters", .func = &ring_StringCountLetters },
    .{ .name = "stzenginestringcountpunctuation", .func = &ring_StringCountPunctuation },
    .{ .name = "stzenginestringcountsymbols", .func = &ring_StringCountSymbols },
    .{ .name = "stzenginestringcountmarks", .func = &ring_StringCountMarks },
    .{ .name = "stzenginestringcountcontrols", .func = &ring_StringCountControls },
    .{ .name = "stzenginestringcountarabic", .func = &ring_StringCountArabic },
    .{ .name = "stzenginestringcountlatin", .func = &ring_StringCountLatin },
    .{ .name = "stzenginestringcountgreek", .func = &ring_StringCountGreek },
    .{ .name = "stzenginestringcountcyrillic", .func = &ring_StringCountCyrillic },
    .{ .name = "stzenginestringcounthebrew", .func = &ring_StringCountHebrew },
    .{ .name = "stzenginestringcountarabicletters", .func = &ring_StringCountArabicLetters },
    .{ .name = "stzenginestringcountlatinletters", .func = &ring_StringCountLatinLetters },
    .{ .name = "stzenginestringisarabic", .func = &ring_StringIsArabic },
    .{ .name = "stzenginestringislatin", .func = &ring_StringIsLatin },
    .{ .name = "stzenginestringisarabicletters", .func = &ring_StringIsArabicLetters },
    .{ .name = "stzenginestringislatinletters", .func = &ring_StringIsLatinLetters },
    .{ .name = "stzenginestringonlyarabic", .func = &ring_StringOnlyArabic },
    .{ .name = "stzenginestringonlylatin", .func = &ring_StringOnlyLatin },
    .{ .name = "stzenginestringonlyarabicletters", .func = &ring_StringOnlyArabicLetters },
    .{ .name = "stzenginestringonlylatinletters", .func = &ring_StringOnlyLatinLetters },
    .{ .name = "stzenginestringisgreek", .func = &ring_StringIsGreek },
    .{ .name = "stzenginestringiscyrillic", .func = &ring_StringIsCyrillic },
    .{ .name = "stzenginestringishebrew", .func = &ring_StringIsHebrew },
    .{ .name = "stzenginestringhasarabic", .func = &ring_StringHasArabic },
    .{ .name = "stzenginestringhaslatin", .func = &ring_StringHasLatin },
    .{ .name = "stzenginestringhasgreek", .func = &ring_StringHasGreek },
    .{ .name = "stzenginestringhascyrillic", .func = &ring_StringHasCyrillic },
    .{ .name = "stzenginestringhashebrew", .func = &ring_StringHasHebrew },
    .{ .name = "stzenginestringcountcjk", .func = &ring_StringCountCjk },
    .{ .name = "stzenginestringcountdevanagari", .func = &ring_StringCountDevanagari },
    .{ .name = "stzenginestringcountthai", .func = &ring_StringCountThai },
    .{ .name = "stzenginestringnormalizespaces", .func = &ring_StringNormalizeSpaces },
    .{ .name = "stzenginestringmaskemail", .func = &ring_StringMaskEmail },
    .{ .name = "stzenginestringpluralize", .func = &ring_StringPluralize },
    .{ .name = "stzenginestringdeduplicatelines", .func = &ring_StringDeduplicateLines },
    .{ .name = "stzenginestringremoveblanklines", .func = &ring_StringRemoveBlankLines },
    .{ .name = "stzenginestringextractnumbers", .func = &ring_StringExtractNumbers },
    .{ .name = "stzenginestringextractemails", .func = &ring_StringExtractEmails },
    .{ .name = "stzenginestringquote", .func = &ring_StringQuote },
    .{ .name = "stzenginestringunquote", .func = &ring_StringUnquote },
    .{ .name = "stzenginestringtocsvfield", .func = &ring_StringToCsvField },
    .{ .name = "stzenginestringnumberlines", .func = &ring_StringNumberLines },
    .{ .name = "stzenginestringhide", .func = &ring_StringHide },
    .{ .name = "stzenginestringextractwords", .func = &ring_StringExtractWords },
    .{ .name = "stzenginestringexpandtabs", .func = &ring_StringExpandTabs },
    .{ .name = "stzenginestringsentencecount", .func = &ring_StringSentenceCount },
    .{ .name = "stzenginestringchop", .func = &ring_StringChop },
    .{ .name = "stzenginestringscanint", .func = &ring_StringScanInt },
    .{ .name = "stzenginestringtoordinal", .func = &ring_StringToOrdinal },
    .{ .name = "stzenginestringcpcount", .func = &ring_StringCpCount },
    .{ .name = "stzenginestringcharssplit", .func = &ring_StringCharsSplit },
    .{ .name = "stzenginestringcharslist", .func = &ring_StringCharsList },
    .{ .name = "stzenginestringleft", .func = &ring_StringLeft },
    .{ .name = "stzenginestringright", .func = &ring_StringRight },
    .{ .name = "stzenginestringcontainslatin", .func = &ring_StringContainsLatin },
    .{ .name = "stzenginestringcontainsarabic", .func = &ring_StringContainsArabic },
    .{ .name = "stzenginestringhasmixedcase", .func = &ring_StringHasMixedCase },
    .{ .name = "stzenginestringjaro", .func = &ring_StringJaro },
    .{ .name = "stzenginestringjarowinkler", .func = &ring_StringJaroWinkler },
    .{ .name = "stzenginestringmetaphone", .func = &ring_StringMetaphone },
    .{ .name = "stzenginestringcharngrams", .func = &ring_StringCharNgrams },
    .{ .name = "stzenginestringwordngrams", .func = &ring_StringWordNgrams },
    // CS unified functions (13)
    .{ .name = "stzenginestringfindfirstcs", .func = &ring_StringFindFirstCS },
    .{ .name = "stzenginestringfindfirstfromcs", .func = &ring_StringFindFirstFromCS },
    .{ .name = "stzenginestringfindcs", .func = &ring_StringFindCS },
    .{ .name = "stzenginestringfindlastcs", .func = &ring_StringFindLastCS },
    .{ .name = "stzenginestringcountofcs", .func = &ring_StringCountOfCS },
    .{ .name = "stzenginestringcontainscs", .func = &ring_StringContainsCS },
    .{ .name = "stzenginestringstartswithcs", .func = &ring_StringStartsWithCS },
    .{ .name = "stzenginestringendswithcs", .func = &ring_StringEndsWithCS },
    .{ .name = "stzenginestringequalscs", .func = &ring_StringEqualsCS },
    .{ .name = "stzenginestringfindnthcs", .func = &ring_StringFindNthCS },
    .{ .name = "stzenginestringreplacecs", .func = &ring_StringReplaceCS },
    .{ .name = "stzenginestringremovecs", .func = &ring_StringRemoveCS },
    .{ .name = "stzenginestringsplitcountcs", .func = &ring_StringSplitCountCS },
    .{ .name = "stzenginestringsplitgetcs", .func = &ring_StringSplitGetCS },
    .{ .name = "stzenginestringallsubstringscs", .func = &ring_StringAllSubstringsCS },
    .{ .name = "stzenginestringuniquecharscs", .func = &ring_StringUniqueCharsCS },
    .{ .name = "stzenginestringduplicatedchars", .func = &ring_StringDuplicatedChars },
    .{ .name = "stzenginestringsubstringscount", .func = &ring_StringSubstringsCount },
    .{ .name = "stzenginestringsubstringsofnchars", .func = &ring_StringSubstringsOfNChars },
    // CS batch 2: split (7)
    .{ .name = "stzenginestringsortlinescs", .func = &ring_StringSortLinesCS },
    .{ .name = "stzenginestringpartitioncs", .func = &ring_StringPartitionCS },
    .{ .name = "stzenginestringpartitionaftercs", .func = &ring_StringPartitionAfterCS },
    .{ .name = "stzenginestringrpartitioncs", .func = &ring_StringRpartitionCS },
    .{ .name = "stzenginestringrpartitionaftercs", .func = &ring_StringRpartitionAfterCS },
    .{ .name = "stzenginestringsortnullitemscs", .func = &ring_StringSortNullItemsCS },
    .{ .name = "stzenginestringuniquenullitemscs", .func = &ring_StringUniqueNullItemsCS },
    // CS batch 2: format (5)
    .{ .name = "stzenginestringensureprefixcs", .func = &ring_StringEnsurePrefixCS },
    .{ .name = "stzenginestringensuresuffixcs", .func = &ring_StringEnsureSuffixCS },
    .{ .name = "stzenginestringdeduplicatelinescs", .func = &ring_StringDeduplicateLinesCS },
    .{ .name = "stzenginestringsortwordscs", .func = &ring_StringSortWordsCS },
    .{ .name = "stzenginestringuniquewordscs", .func = &ring_StringUniqueWordsCS },
    // CS batch 2: compare (10)
    .{ .name = "stzenginestringcomparecs", .func = &ring_StringCompareCS },
    .{ .name = "stzenginestringprefixcountcs", .func = &ring_StringPrefixCountCS },
    .{ .name = "stzenginestringsuffixcountcs", .func = &ring_StringSuffixCountCS },
    .{ .name = "stzenginestringcommonprefixcs", .func = &ring_StringCommonPrefixCS },
    .{ .name = "stzenginestringcommonsuffixcs", .func = &ring_StringCommonSuffixCS },
    .{ .name = "stzenginestringcommoncharscs", .func = &ring_StringCommonCharsCS },
    .{ .name = "stzenginestringlongestcommonprefixcs", .func = &ring_StringLongestCommonPrefixCS },
    .{ .name = "stzenginestringlongestcommonsuffixcs", .func = &ring_StringLongestCommonSuffixCS },
    .{ .name = "stzenginestringcommonalitycs", .func = &ring_StringCommonalityCS },
    .{ .name = "stzenginestringdiffcharscs", .func = &ring_StringDiffCharsCS },
    // CS batch 2: replace (3)
    .{ .name = "stzenginestringreplacefirstcs", .func = &ring_StringReplaceFirstCS },
    .{ .name = "stzenginestringreplacelastcs", .func = &ring_StringReplaceLastCS },
    .{ .name = "stzenginestringreplacenthcs", .func = &ring_StringReplaceNthCS },
    // CS batch 2: inspect (4)
    .{ .name = "stzenginestringcontainsanyofcs", .func = &ring_StringContainsAnyOfCS },
    .{ .name = "stzenginestringcontainsallofcs", .func = &ring_StringContainsAllOfCS },
    .{ .name = "stzenginestringcontainsonlycs", .func = &ring_StringContainsOnlyCS },
    .{ .name = "stzenginestringisanagramcs", .func = &ring_StringIsAnagramCS },
    // CS batch 2: find (2)
    .{ .name = "stzenginestringbeginswithanyxcs", .func = &ring_StringStartsWithAnyCS },
    .{ .name = "stzenginestringfinisheswithanyxcs", .func = &ring_StringEndsWithAnyCS },
    // Regex integration (Phase E) (7)
    .{ .name = "stzenginestringregexismatch", .func = &ring_StringRegexIsMatch },
    .{ .name = "stzenginestringregexcount", .func = &ring_StringRegexCount },
    .{ .name = "stzenginestringregexfindfirst", .func = &ring_StringRegexFindFirst },
    .{ .name = "stzenginestringregexfindall", .func = &ring_StringRegexFindAll },
    .{ .name = "stzenginestringregexreplaceall", .func = &ring_StringRegexReplaceAll },
    .{ .name = "stzenginestringregexsplitcount", .func = &ring_StringRegexSplitCount },
    .{ .name = "stzenginestringregexsplitget", .func = &ring_StringRegexSplitGet },
    // Between CS / Section CP
    .{ .name = "stzenginestringbetweencs", .func = &ring_StringBetweenCS },
    .{ .name = "stzenginestringssectioncp", .func = &ring_StringSectionCP },
};

pub fn ringlib_init(pRingState: ?*anyopaque) callconv(.c) void {
    if (pRingState) |state| R.registerAll(state, &regs);
}
