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

fn ring_StringFindCharsOfType(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const char_type: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const result = string.stz_string_find_chars_of_type(h, char_type);
    ring_vm_api_retcpointer(p, @ptrCast(result), "StzFindResultHandle");
}

fn ring_StringExtractCharsOfType(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const char_type: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const result = string.stz_string_extract_chars_of_type(h, char_type);
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

fn ring_StringIsUppercase(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_is_uppercase(h)));
}

fn ring_StringIsLowercase(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_is_lowercase(h)));
}

fn ring_StringIsWhitespace(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_is_whitespace(h)));
}

fn ring_StringWordCount(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_word_count(h)));
}

fn ring_StringIsOnlyType(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const char_type: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_is_only_type(h, char_type)));
}

fn ring_StringRemoveCharsOfType(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const char_type: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const result = string.stz_string_remove_chars_of_type(h, char_type);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringTrim(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const result = string.stz_string_trim(h);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringSwapCase(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const result = string.stz_string_swap_case(h);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringUniqueChars(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const result = string.stz_string_unique_chars(h);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringUniqueCharCount(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_unique_char_count(h)));
}

fn ring_StringRemoveAllCI(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const needle = ring_vm_api_getstring(p, 2);
    const needle_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const result = string.stz_string_remove_all_ci(h, needle, needle_len);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringIsAlphaOnly(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_is_alpha_only(h)));
}

fn ring_StringIsAlnum(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_is_alnum(h)));
}

fn ring_StringContainsChar(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const cp: i32 = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_contains_char(h, cp)));
}

fn ring_StringBetweenNth(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const open = ring_vm_api_getstring(p, 2);
    const open_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const close = ring_vm_api_getstring(p, 3);
    const close_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    const nth: c_int = @intFromFloat(ring_vm_api_getnumber(p, 4));
    const result = string.stz_string_between_nth(h, open, open_len, close, close_len, nth);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringCountBetween(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const open = ring_vm_api_getstring(p, 2);
    const open_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const close = ring_vm_api_getstring(p, 3);
    const close_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_count_between(h, open, open_len, close, close_len)));
}

fn ring_StringSimplify(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const result = string.stz_string_simplify(h);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringStartsWithDigit(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_starts_with_digit(h)));
}

fn ring_StringStartsWithLetter(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_starts_with_letter(h)));
}

fn ring_StringEndsWithDigit(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_ends_with_digit(h)));
}

fn ring_StringEndsWithLetter(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_ends_with_letter(h)));
}

fn ring_StringReplaceCharAt(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const cp_index: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const replacement = ring_vm_api_getstring(p, 3);
    const rep_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    const result = string.stz_string_replace_char_at(h, cp_index, replacement, rep_len);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringLevenshtein(p: *anyopaque) callconv(.c) void {
    const h1 = getHandle(p, 1);
    const h2 = getHandle(p, 2);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_levenshtein(h1, h2)));
}

fn ring_StringIsTitleCase(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_is_title_case(h)));
}

fn ring_StringLinesSplitCount(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_lines_split_count(h)));
}

fn ring_StringLineAt(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const idx: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const result = string.stz_string_line_at(h, idx);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

// ─── IsWord ───

fn ring_StringIsWord(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_is_word(h)));
}

// ─── CountLeadingChar / CountTrailingChar ───

fn ring_StringCountLeadingChar(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const cp: u32 = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_count_leading_char(h, cp)));
}

fn ring_StringCountTrailingChar(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const cp: u32 = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_count_trailing_char(h, cp)));
}

// ─── IsNumericString ───

fn ring_StringIsNumericString(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_is_numeric_string(h)));
}

// ─── URLEncode / URLDecode ───

fn ring_StringURLEncode(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const result = string.stz_string_url_encode(h);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringURLDecode(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const result = string.stz_string_url_decode(h);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

// ─── CharAtToString ───

fn ring_StringCharAtToString(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const idx: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const result = string.stz_string_char_at_to_string(h, idx);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

// ─── Spacify ───

fn ring_StringSpacify(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const result = string.stz_string_spacify(h);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

// ─── BytesPerChar ───

fn ring_StringBytesPerChar(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const result = string.stz_string_bytes_per_char(h);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

// ─── IsHexString / IsBinaryString / IsOctalString ───

fn ring_StringIsHexString(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_is_hex_string(h)));
}

fn ring_StringIsBinaryString(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_is_binary_string(h)));
}

fn ring_StringIsOctalString(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_is_octal_string(h)));
}

// ─── WordAt ───

fn ring_StringWordAt(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const idx: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const result = string.stz_string_word_at(h, idx);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

// ─── Center ───

fn ring_StringCenter(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const width: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const pad_char: u32 = @intFromFloat(ring_vm_api_getnumber(p, 3));
    const result = string.stz_string_center(h, width, pad_char);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

// ─── RemoveConsecutiveDuplicates ───

fn ring_StringRemoveConsecutiveDuplicates(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const result = string.stz_string_remove_consecutive_duplicates(h);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

// ─── Substring ───

fn ring_StringSubstring(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const from: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const to: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    const result = string.stz_string_substring(h, from, to);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

// ─── ReplaceSubstring ───

fn ring_StringReplaceSubstring(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const from: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const to: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    const rep_ptr = ring_vm_api_getstring(p, 4);
    const rep_len: usize = @intCast(ring_vm_api_getstringsize(p, 4));
    const result = string.stz_string_replace_substring(h, from, to, rep_ptr, rep_len);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

// ─── PrefixCount / SuffixCount ───

fn ring_StringPrefixCount(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const pref_ptr = ring_vm_api_getstring(p, 2);
    const pref_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_prefix_count(h, pref_ptr, pref_len)));
}

fn ring_StringSuffixCount(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const suf_ptr = ring_vm_api_getstring(p, 2);
    const suf_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_suffix_count(h, suf_ptr, suf_len)));
}

// ─── CommonPrefix / CommonSuffix ───

fn ring_StringCommonPrefix(p: *anyopaque) callconv(.c) void {
    const h1 = getHandle(p, 1);
    const h2 = getHandle(p, 2);
    const result = string.stz_string_common_prefix(h1, h2);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringCommonSuffix(p: *anyopaque) callconv(.c) void {
    const h1 = getHandle(p, 1);
    const h2 = getHandle(p, 2);
    const result = string.stz_string_common_suffix(h1, h2);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

// ─── SortChars ───

fn ring_StringSortCharsAsc(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const result = string.stz_string_sort_chars_asc(h);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

fn ring_StringSortCharsDesc(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const result = string.stz_string_sort_chars_desc(h);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

// ─── FindAllChar ───

fn ring_StringFindAllChar(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const cp: u32 = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_find_all_char(h, cp)), FIND_HANDLE);
}

// ─── Hash ───

fn ring_StringHash(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_hash(h)));
}

// ─── CountChar ───

fn ring_StringCountChar(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const cp: u32 = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_count_char(h, cp)));
}

// ─── ReplaceChar ───

fn ring_StringReplaceChar(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const old_cp: u32 = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const new_cp: u32 = @intFromFloat(ring_vm_api_getnumber(p, 3));
    const result = string.stz_string_replace_char(h, old_cp, new_cp);
    ring_vm_api_retcpointer(p, @ptrCast(result), STZ_HANDLE);
}

// ─── CountOverlapping ───

fn ring_StringCountOverlapping(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const needle = ring_vm_api_getstring(p, 2);
    const needle_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_count_overlapping(h, needle, needle_len)));
}

// ─── ReplaceAt ───

fn ring_StringReplaceAt(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const cp_pos: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const cp_count: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    const rep = ring_vm_api_getstring(p, 4);
    const rep_len: usize = @intCast(ring_vm_api_getstringsize(p, 4));
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_replace_at(h, cp_pos, cp_count, rep, rep_len)), STZ_HANDLE);
}

// ─── CharFrequency ───

fn ring_StringCharFrequency(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_char_frequency(h)), STZ_HANDLE);
}

// ─── ContainsAnyOf ───

fn ring_StringContainsAnyOf(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const chars = ring_vm_api_getstring(p, 2);
    const chars_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_contains_any_of(h, chars, chars_len)));
}

// ─── ContainsAllOf ───

fn ring_StringContainsAllOf(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const chars = ring_vm_api_getstring(p, 2);
    const chars_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_contains_all_of(h, chars, chars_len)));
}

// ─── RemovePrefix ───

fn ring_StringRemovePrefix(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const pfx = ring_vm_api_getstring(p, 2);
    const pfx_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_remove_prefix(h, pfx, pfx_len)), STZ_HANDLE);
}

// ─── RemoveSuffix ───

fn ring_StringRemoveSuffix(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const sfx = ring_vm_api_getstring(p, 2);
    const sfx_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_remove_suffix(h, sfx, sfx_len)), STZ_HANDLE);
}

// ─── EnsurePrefix ───

fn ring_StringEnsurePrefix(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const pfx = ring_vm_api_getstring(p, 2);
    const pfx_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_ensure_prefix(h, pfx, pfx_len)), STZ_HANDLE);
}

// ─── EnsureSuffix ───

fn ring_StringEnsureSuffix(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const sfx = ring_vm_api_getstring(p, 2);
    const sfx_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_ensure_suffix(h, sfx, sfx_len)), STZ_HANDLE);
}

// ─── SqueezeChar ───

fn ring_StringSqueezeChar(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const cp: u32 = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_squeeze_char(h, cp)), STZ_HANDLE);
}

// ─── CapitalizeFirst ───

fn ring_StringCapitalizeFirst(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_capitalize_first(h)), STZ_HANDLE);
}

// ─── DecapitalizeFirst ───

fn ring_StringDecapitalizeFirst(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_decapitalize_first(h)), STZ_HANDLE);
}

// ─── ZFill ───

fn ring_StringZFill(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const width: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_zfill(h, width)), STZ_HANDLE);
}

// ─── TabExpand ───

fn ring_StringTabExpand(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const tw: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_tab_expand(h, tw)), STZ_HANDLE);
}

// ─── RepeatChar ───

fn ring_StringRepeatChar(p: *anyopaque) callconv(.c) void {
    const cp: u32 = @intFromFloat(ring_vm_api_getnumber(p, 1));
    const count: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_repeat_char(cp, count)), STZ_HANDLE);
}

// ─── InsertBeforeEach ───

fn ring_StringInsertBeforeEach(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const needle = ring_vm_api_getstring(p, 2);
    const needle_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const ins = ring_vm_api_getstring(p, 3);
    const ins_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_insert_before_each(h, needle, needle_len, ins, ins_len)), STZ_HANDLE);
}

// ─── InsertAfterEach ───

fn ring_StringInsertAfterEach(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const needle = ring_vm_api_getstring(p, 2);
    const needle_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const ins = ring_vm_api_getstring(p, 3);
    const ins_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_insert_after_each(h, needle, needle_len, ins, ins_len)), STZ_HANDLE);
}

// ─── Truncate ───

fn ring_StringTruncate(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const max_cp: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    const ell = ring_vm_api_getstring(p, 3);
    const ell_len: usize = @intCast(ring_vm_api_getstringsize(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_truncate(h, max_cp, ell, ell_len)), STZ_HANDLE);
}

// ─── WrapAt ───

fn ring_StringWrapAt(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const width: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_wrap_at(h, width)), STZ_HANDLE);
}

// ─── Copy ───

fn ring_StringCopy(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_copy(h)), STZ_HANDLE);
}

// ─── Compare ───

fn ring_StringCompare(p: *anyopaque) callconv(.c) void {
    const h1 = getHandle(p, 1);
    const ptr2 = ring_vm_api_getcpointer(p, 2, STZ_HANDLE);
    const h2: string.StzStringHandle = if (ptr2) |raw| @ptrCast(@alignCast(raw)) else null;
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_compare(h1, h2)));
}

// ─── RemoveFirstOccurrence ───

fn ring_StringRemoveFirstOccurrence(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const needle = ring_vm_api_getstring(p, 2);
    const needle_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_remove_first_occurrence(h, needle, needle_len)), STZ_HANDLE);
}

// ─── RemoveLastOccurrence ───

fn ring_StringRemoveLastOccurrence(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const needle = ring_vm_api_getstring(p, 2);
    const needle_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_remove_last_occurrence(h, needle, needle_len)), STZ_HANDLE);
}

// ─── RemoveNthOccurrence ───

fn ring_StringRemoveNthOccurrence(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const needle = ring_vm_api_getstring(p, 2);
    const needle_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const n: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.stz_string_remove_nth_occurrence(h, needle, needle_len, n)), STZ_HANDLE);
}

// ─── IsCharsSortedAsc ───

fn ring_StringIsCharsSortedAsc(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_is_chars_sorted_asc(h)));
}

// ─── IsCharsSortedDesc ───

fn ring_StringIsCharsSortedDesc(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.stz_string_is_chars_sorted_desc(h)));
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
    .{ .name = "stzenginestringleftcp", .func = &ring_StringLeftCp },
    .{ .name = "stzenginestringrightcp", .func = &ring_StringRightCp },
    .{ .name = "stzenginestringremoveall", .func = &ring_StringRemoveAll },
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
    .{ .name = "stzenginestringremoveallci", .func = &ring_StringRemoveAllCI },
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
    .{ .name = "stzenginestringfindallchar", .func = &ring_StringFindAllChar },
    .{ .name = "stzenginestringhash", .func = &ring_StringHash },
    .{ .name = "stzenginestringcountchar", .func = &ring_StringCountChar },
    .{ .name = "stzenginestringreplacechar", .func = &ring_StringReplaceChar },
    .{ .name = "stzenginestringcopy", .func = &ring_StringCopy },
    .{ .name = "stzenginestringcompare", .func = &ring_StringCompare },
    .{ .name = "stzenginestringremovefirstoccurrence", .func = &ring_StringRemoveFirstOccurrence },
    .{ .name = "stzenginestringremovelastoccurrence", .func = &ring_StringRemoveLastOccurrence },
    .{ .name = "stzenginestringremoventhoccurrence", .func = &ring_StringRemoveNthOccurrence },
    .{ .name = "stzenginestringischarssortedasc", .func = &ring_StringIsCharsSortedAsc },
    .{ .name = "stzenginestringischarssorteddesc", .func = &ring_StringIsCharsSortedDesc },
    .{ .name = "stzenginestringrepeatchar", .func = &ring_StringRepeatChar },
    .{ .name = "stzenginestringinsertbeforeeach", .func = &ring_StringInsertBeforeEach },
    .{ .name = "stzenginestringinsertaftereach", .func = &ring_StringInsertAfterEach },
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
};

pub fn ringlib_init(pRingState: ?*anyopaque) callconv(.c) void {
    if (pRingState) |state| R.registerAll(state, &regs);
}
