// Ring Extension Bridge for stz_string
//
// Wraps Softanza Engine string+char functions as Ring extension
// functions. Ring calls these by name after ringlib_init registers them.

const string = @import("string.zig");
const char_mod = @import("char.zig");
const R = @import("ring_api.zig");

const ring_vm_api_getstring = R.ring_vm_api_getstring;
const ring_vm_api_getstringsize = R.ring_vm_api_getstringsize;
const ring_vm_api_getnumber = R.ring_vm_api_getnumber;
const ring_vm_api_getcpointer = R.ring_vm_api_getcpointer;
const ring_vm_api_retnumber = R.ring_vm_api_retnumber;
const ring_vm_api_retstring = R.ring_vm_api_retstring;
const ring_vm_api_retstring2 = R.ring_vm_api_retstring2;
const ring_vm_api_retcpointer = R.ring_vm_api_retcpointer;

const STZ_HANDLE: [*:0]const u8 = "StzStringHandle";

fn getHandle(p: *anyopaque, n: c_int) string.StzStringHandle {
    const ptr = ring_vm_api_getcpointer(p, n, STZ_HANDLE);
    if (ptr) |raw| return @ptrCast(@alignCast(raw));
    return null;
}

// ─── String Lifecycle ───

fn ring_StringNew(p: *anyopaque) callconv(.c) void {
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_new()), STZ_HANDLE);
}

fn ring_StringFrom(p: *anyopaque) callconv(.c) void {
    const s = ring_vm_api_getstring(p, 1);
    const len: usize = @intCast(ring_vm_api_getstringsize(p, 1));
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_from(s, len)), STZ_HANDLE);
}

fn ring_StringFree(p: *anyopaque) callconv(.c) void {
    string.stz_string_free(getHandle(p, 1));
}

fn ring_StringData(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const data = string.stz_string_data(h);
    const size = string.stz_string_size(h);
    if (data != null and size > 0) {
        ring_vm_api_retstring2(p, data, @intCast(size));
    } else {
        ring_vm_api_retstring(p, "");
    }
}

fn ring_StringSize(p: *anyopaque) callconv(.c) void {
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_size(getHandle(p, 1))));
}

fn ring_StringCount(p: *anyopaque) callconv(.c) void {
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_count(getHandle(p, 1))));
}

fn ring_StringAppend(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    string.stz_string_append(h, s, @intCast(ring_vm_api_getstringsize(p, 2)));
}

fn ring_StringInsert(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const pos: usize = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const s = ring_vm_api_getstring(p, 3);
    string.stz_string_insert(h, pos, s, @intCast(ring_vm_api_getstringsize(p, 3)));
}

fn ring_StringMid(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const start: usize = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const length: usize = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_mid(h, start, length)), STZ_HANDLE);
}

fn ring_StringTrimmed(p: *anyopaque) callconv(.c) void {
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_trimmed(getHandle(p, 1))), STZ_HANDLE);
}

fn ring_StringIndexOf(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_index_of(h, s, @intCast(ring_vm_api_getstringsize(p, 2)))));
}

fn ring_StringIndexOfFrom(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const start: usize = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_index_of_from(h, s, len, start)));
}

fn ring_StringIndexOfCI(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const start: usize = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_index_of_ci(h, s, len, start)));
}

fn ring_StringByteToCp(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const pos: usize = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_byte_to_cp(h, pos)));
}

fn ring_StringCountOf(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_count_of(h, s, @intCast(ring_vm_api_getstringsize(p, 2)))));
}

fn ring_StringLastIndexOf(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_last_index_of(h, s, @intCast(ring_vm_api_getstringsize(p, 2)))));
}

fn ring_StringContains(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_contains(h, s, @intCast(ring_vm_api_getstringsize(p, 2)))));
}

fn ring_StringStartsWith(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_starts_with(h, s, @intCast(ring_vm_api_getstringsize(p, 2)))));
}

fn ring_StringEndsWith(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_ends_with(h, s, @intCast(ring_vm_api_getstringsize(p, 2)))));
}

// ─── Find Result ───

const FIND_HANDLE: [*:0]const u8 = "StzFindResultHandle";

fn getFindHandle(p: *anyopaque, n: c_int) string.StzFindResultHandle {
    const ptr = ring_vm_api_getcpointer(p, n, FIND_HANDLE);
    if (ptr) |raw| return @ptrCast(@alignCast(raw));
    return null;
}

fn ring_StringFindAll(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_find_all(h, s, len)), FIND_HANDLE);
}

fn ring_StringFindAllCI(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_find_all_ci(h, s, len)), FIND_HANDLE);
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
    string.stz_find_result_free(getFindHandle(p, 1));
}

fn ring_StringCountOfCI(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_count_of_ci(h, s, @intCast(ring_vm_api_getstringsize(p, 2)))));
}

fn ring_StringLastIndexOfCI(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_last_index_of_ci(h, s, @intCast(ring_vm_api_getstringsize(p, 2)))));
}

fn ring_StringContainsCI(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_contains_ci(h, s, @intCast(ring_vm_api_getstringsize(p, 2)))));
}

fn ring_StringStartsWithCI(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_starts_with_ci(h, s, @intCast(ring_vm_api_getstringsize(p, 2)))));
}

fn ring_StringEndsWithCI(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_ends_with_ci(h, s, @intCast(ring_vm_api_getstringsize(p, 2)))));
}

fn ring_StringSplitCountCI(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_split_count_ci(h, s, @intCast(ring_vm_api_getstringsize(p, 2)))));
}

fn ring_StringSplitGetCI(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const idx: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_split_get_ci(h, s, len, idx)), STZ_HANDLE);
}

fn ring_StringReplaceCI(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const old_s = ring_vm_api_getstring(p, 2);
    const old_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const new_s = ring_vm_api_getstring(p, 3);
    const new_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    string.stz_string_replace_ci(h, old_s, old_len, new_s, new_len);
}

fn ring_StringReplace(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const old_s = ring_vm_api_getstring(p, 2);
    const old_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const new_s = ring_vm_api_getstring(p, 3);
    const new_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    string.stz_string_replace(h, old_s, old_len, new_s, new_len);
}

fn ring_StringReplaceRange(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const start: usize = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const range: usize = @intFromFloat(ring_vm_api_getnumber(p, 3));
    const s = ring_vm_api_getstring(p, 4);
    const len: usize = @intCast(ring_vm_api_getstringsize(p, 4));
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_replace_range(h, start, range, s, len)), STZ_HANDLE);
}

fn ring_StringSplitCount(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_split_count(h, s, @intCast(ring_vm_api_getstringsize(p, 2)))));
}

fn ring_StringSplitGet(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const idx: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_split_get(h, s, len, idx)), STZ_HANDLE);
}

fn ring_StringToUpper(p: *anyopaque) callconv(.c) void {
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_to_upper(getHandle(p, 1))), STZ_HANDLE);
}

fn ring_StringToLower(p: *anyopaque) callconv(.c) void {
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_to_lower(getHandle(p, 1))), STZ_HANDLE);
}

fn ring_StringToTitle(p: *anyopaque) callconv(.c) void {
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_to_title(getHandle(p, 1))), STZ_HANDLE);
}

fn ring_StringCharAt(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const idx: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_char_at(h, idx)));
}

fn ring_StringMidCp(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const start: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const count: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_mid_cp(h, start, count)), STZ_HANDLE);
}

fn ring_StringGraphemeCount(p: *anyopaque) callconv(.c) void {
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_grapheme_count(getHandle(p, 1))));
}

fn ring_StringNormalize(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const form: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_normalize(h, form)), STZ_HANDLE);
}

fn ring_StringStripMarks(p: *anyopaque) callconv(.c) void {
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_strip_marks(getHandle(p, 1))), STZ_HANDLE);
}

fn ring_CharUnicode(p: *anyopaque) callconv(.c) void {
    ring_vm_api_retnumber(p, @floatFromInt(char_mod.stz_char_unicode(ring_vm_api_getstring(p, 1))));
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
    const result = string.stz_string_nth_char(h, cp_idx);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringSlice(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const start_cp: usize = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const cp_count: usize = @intFromFloat(ring_vm_api_getnumber(p, 3));
    const result = string.stz_string_slice(h, start_cp, cp_count);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringReverse(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const result = string.stz_string_reverse(h);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringRepeat(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const count: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const result = string.stz_string_repeat(h, count);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringPadLeft(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const target: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const pad_s = ring_vm_api_getstring(p, 3);
    const pad_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    const result = string.stz_string_pad_left(h, target, pad_s, pad_len);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringPadRight(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const target: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const pad_s = ring_vm_api_getstring(p, 3);
    const pad_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    const result = string.stz_string_pad_right(h, target, pad_s, pad_len);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringRemoveRange(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const start_cp: usize = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const cp_count: usize = @intFromFloat(ring_vm_api_getnumber(p, 3));
    const result = string.stz_string_remove_range(h, start_cp, cp_count);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringTrimLeft(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_trim_left(h)), STZ_HANDLE);
}

fn ring_StringTrimRight(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_trim_right(h)), STZ_HANDLE);
}

fn ring_StringEquals(p: *anyopaque) callconv(.c) void {
    const h1 = getHandle(p, 1);
    const h2 = getHandle(p, 2);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_equals(h1, h2)));
}

fn ring_StringEqualsCI(p: *anyopaque) callconv(.c) void {
    const h1 = getHandle(p, 1);
    const h2 = getHandle(p, 2);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_equals_ci(h1, h2)));
}

fn ring_StringRemoveAll(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const result = string.stz_string_remove_all(h, s, len);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringLinesCount(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_lines_count(h)));
}

fn ring_StringIsPalindrome(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_is_palindrome(h)));
}

fn ring_StringConcat(p: *anyopaque) callconv(.c) void {
    const h1 = getHandle(p, 1);
    const h2 = getHandle(p, 2);
    const result = string.stz_string_concat(h1, h2);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringIsAscii(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_is_ascii(h)));
}

fn ring_StringRemoveCharAt(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const cp_index: usize = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const result = string.stz_string_remove_char_at(h, cp_index);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringCharTypeAt(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const cp_index: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_char_type_at(h, cp_index)));
}

fn ring_StringReplaceFirst(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const old = ring_vm_api_getstring(p, 2);
    const old_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const new_str = ring_vm_api_getstring(p, 3);
    const new_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    const result = string.stz_string_replace_first(h, old, old_len, new_str, new_len);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringReplaceLast(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const old = ring_vm_api_getstring(p, 2);
    const old_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const new_str = ring_vm_api_getstring(p, 3);
    const new_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    const result = string.stz_string_replace_last(h, old, old_len, new_str, new_len);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringReplaceNth(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const old = ring_vm_api_getstring(p, 2);
    const old_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const new_str = ring_vm_api_getstring(p, 3);
    const new_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    const n: c_int = @intFromFloat(ring_vm_api_getnumber(p, 4));
    const result = string.stz_string_replace_nth(h, old, old_len, new_str, new_len, n);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringIsEmpty(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_is_empty(h)));
}

fn ring_StringBetween(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const open = ring_vm_api_getstring(p, 2);
    const open_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const close = ring_vm_api_getstring(p, 3);
    const close_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    const result = string.stz_string_between(h, open, open_len, close, close_len);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringCountCharsOfType(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const char_type: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_count_chars_of_type(h, char_type)));
}

fn ring_StringIsNumeric(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_is_numeric(h)));
}

fn ring_StringIsAlpha(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_is_alpha(h)));
}

fn ring_StringFindNth(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const n: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_find_nth(h, s, len, n)));
}

fn ring_StringFindNthCI(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const n: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_find_nth_ci(h, s, len, n)));
}

fn ring_StringInsertCp(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const cp_pos: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const s = ring_vm_api_getstring(p, 3);
    const len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    string.stz_string_insert_cp(h, cp_pos, s, len);
}

fn ring_StringLeftCp(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const cp_count: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const result = string.stz_string_left_cp(h, cp_count);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringRightCp(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const cp_count: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const result = string.stz_string_right_cp(h, cp_count);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

// ─── Registration ───
// Ring lowercases all function names, so registered names must be lowercase.

const regs = [_]R.Reg{
    .{ .name = "stzenginestringnew", .func = &ring_StringNew },
    .{ .name = "stzenginestringfrom", .func = &ring_StringFrom },
    .{ .name = "stzenginestringfree", .func = &ring_StringFree },
    .{ .name = "stzenginestringdata", .func = &ring_StringData },
    .{ .name = "stzenginestringsize", .func = &ring_StringSize },
    .{ .name = "stzenginestringcount", .func = &ring_StringCount },
    .{ .name = "stzenginestringappend", .func = &ring_StringAppend },
    .{ .name = "stzenginestringinsert", .func = &ring_StringInsert },
    .{ .name = "stzenginestringmid", .func = &ring_StringMid },
    .{ .name = "stzenginestringtrimmed", .func = &ring_StringTrimmed },
    .{ .name = "stzenginestringindexof", .func = &ring_StringIndexOf },
    .{ .name = "stzenginestringindexoffrom", .func = &ring_StringIndexOfFrom },
    .{ .name = "stzenginestringindexofci", .func = &ring_StringIndexOfCI },
    .{ .name = "stzenginestringbytetocp", .func = &ring_StringByteToCp },
    .{ .name = "stzenginestringcountof", .func = &ring_StringCountOf },
    .{ .name = "stzenginestringlastindexof", .func = &ring_StringLastIndexOf },
    .{ .name = "stzenginestringcontains", .func = &ring_StringContains },
    .{ .name = "stzenginestringstartswith", .func = &ring_StringStartsWith },
    .{ .name = "stzenginestringendswith", .func = &ring_StringEndsWith },
    .{ .name = "stzenginestringfindall", .func = &ring_StringFindAll },
    .{ .name = "stzenginestringfindallci", .func = &ring_StringFindAllCI },
    .{ .name = "stzenginefindresultcount", .func = &ring_FindResultCount },
    .{ .name = "stzenginefindresultget", .func = &ring_FindResultGet },
    .{ .name = "stzenginefindresultfree", .func = &ring_FindResultFree },
    .{ .name = "stzenginestringcountofci", .func = &ring_StringCountOfCI },
    .{ .name = "stzenginestringlastindexofci", .func = &ring_StringLastIndexOfCI },
    .{ .name = "stzenginestringcontainsci", .func = &ring_StringContainsCI },
    .{ .name = "stzenginestringstartswithci", .func = &ring_StringStartsWithCI },
    .{ .name = "stzenginestringendswithci", .func = &ring_StringEndsWithCI },
    .{ .name = "stzenginestringsplitcountci", .func = &ring_StringSplitCountCI },
    .{ .name = "stzenginestringsplitgetci", .func = &ring_StringSplitGetCI },
    .{ .name = "stzenginestringreplaceci", .func = &ring_StringReplaceCI },
    .{ .name = "stzenginestringreplace", .func = &ring_StringReplace },
    .{ .name = "stzenginestringreplacerange", .func = &ring_StringReplaceRange },
    .{ .name = "stzenginestringsplitcount", .func = &ring_StringSplitCount },
    .{ .name = "stzenginestringsplitget", .func = &ring_StringSplitGet },
    .{ .name = "stzenginestringtoupper", .func = &ring_StringToUpper },
    .{ .name = "stzenginestringtolower", .func = &ring_StringToLower },
    .{ .name = "stzenginestringtotitle", .func = &ring_StringToTitle },
    .{ .name = "stzenginestringcharat", .func = &ring_StringCharAt },
    .{ .name = "stzenginestringmidcp", .func = &ring_StringMidCp },
    .{ .name = "stzenginestringgraphemecount", .func = &ring_StringGraphemeCount },
    .{ .name = "stzenginestringnormalize", .func = &ring_StringNormalize },
    .{ .name = "stzenginestringstripmarks", .func = &ring_StringStripMarks },
    .{ .name = "stzenginecharunicode", .func = &ring_CharUnicode },
    .{ .name = "stzenginecharisletter", .func = &ring_CharIsLetter },
    .{ .name = "stzenginecharisdigit", .func = &ring_CharIsDigit },
    .{ .name = "stzenginecharisupper", .func = &ring_CharIsUpper },
    .{ .name = "stzenginecharislower", .func = &ring_CharIsLower },
    .{ .name = "stzenginestringnthchar", .func = &ring_StringNthChar },
    .{ .name = "stzenginestringslice", .func = &ring_StringSlice },
    .{ .name = "stzenginestringreverse", .func = &ring_StringReverse },
    .{ .name = "stzenginestringrepeat", .func = &ring_StringRepeat },
    .{ .name = "stzenginestringpadleft", .func = &ring_StringPadLeft },
    .{ .name = "stzenginestringpadright", .func = &ring_StringPadRight },
    .{ .name = "stzenginestringremoverange", .func = &ring_StringRemoveRange },
    .{ .name = "stzenginestringtrimleft", .func = &ring_StringTrimLeft },
    .{ .name = "stzenginestringtrimright", .func = &ring_StringTrimRight },
    .{ .name = "stzenginestringequals", .func = &ring_StringEquals },
    .{ .name = "stzenginestringequalsci", .func = &ring_StringEqualsCI },
    .{ .name = "stzenginestringreplacefirst", .func = &ring_StringReplaceFirst },
    .{ .name = "stzenginestringreplacelast", .func = &ring_StringReplaceLast },
    .{ .name = "stzenginestringreplacenth", .func = &ring_StringReplaceNth },
    .{ .name = "stzenginestringisempty", .func = &ring_StringIsEmpty },
    .{ .name = "stzenginestringbetween", .func = &ring_StringBetween },
    .{ .name = "stzenginestringcountcharsoftype", .func = &ring_StringCountCharsOfType },
    .{ .name = "stzenginestringisnumeric", .func = &ring_StringIsNumeric },
    .{ .name = "stzenginestringisalpha", .func = &ring_StringIsAlpha },
    .{ .name = "stzenginestringfindnth", .func = &ring_StringFindNth },
    .{ .name = "stzenginestringfindnthci", .func = &ring_StringFindNthCI },
    .{ .name = "stzenginestringinsertcp", .func = &ring_StringInsertCp },
    .{ .name = "stzenginestingleftcp", .func = &ring_StringLeftCp },
    .{ .name = "stzenginestringrightcp", .func = &ring_StringRightCp },
    .{ .name = "stzenginestringremoveall", .func = &ring_StringRemoveAll },
    .{ .name = "stzenginestringlinescount", .func = &ring_StringLinesCount },
    .{ .name = "stzenginestringispalindrome", .func = &ring_StringIsPalindrome },
    .{ .name = "stzenginestringconcat", .func = &ring_StringConcat },
    .{ .name = "stzenginestringisascii", .func = &ring_StringIsAscii },
    .{ .name = "stzenginestringremovecharat", .func = &ring_StringRemoveCharAt },
    .{ .name = "stzenginestringchartypeat", .func = &ring_StringCharTypeAt },
};

pub fn ringlib_init(pRingState: ?*anyopaque) callconv(.c) void {
    if (pRingState) |state| R.registerAll(state, &regs);
}
