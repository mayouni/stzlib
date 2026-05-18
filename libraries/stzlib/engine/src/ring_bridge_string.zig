// Ring Extension Bridge for str_ (string engine)
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
    string.str_free(getHandle(p, 1));
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

fn ring_StringIndexOf(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_index_of(h, s, @intCast(ring_vm_api_getstringsize(p, 2)))));
}

fn ring_StringIndexOfFrom(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const start: usize = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_index_of_from(h, s, len, start)));
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

fn ring_StringLastIndexOf(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_last_index_of(h, s, @intCast(ring_vm_api_getstringsize(p, 2)))));
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
    if (ptr) |raw| return @ptrCast(@alignCast(raw));
    return null;
}

fn ring_StringFindAll(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_find_all(h, s, len)), FIND_HANDLE);
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

fn ring_StringRemoveAll(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const result = string.str_remove_all(h, s, len);
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

// ─── FindAllChar ───

fn ring_StringFindAllChar(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const cp: u32 = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_find_all_char(h, cp)), FIND_HANDLE);
}

// ─── Hash ───

fn ring_StringHash(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    ring_vm_api_retnumber(p, @floatFromInt(string.str_hash(h)));
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
    const h2: string.StzStringHandle = if (ptr2) |raw| @ptrCast(@alignCast(raw)) else null;
    ring_vm_api_retnumber(p, @floatFromInt(string.str_compare(h1, h2)));
}

// ─── RemoveFirstOccurrence ───

fn ring_StringRemoveFirstOccurrence(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const needle = ring_vm_api_getstring(p, 2);
    const needle_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_remove_first_occurrence(h, needle, needle_len)), STZ_HANDLE);
}

// ─── RemoveLastOccurrence ───

fn ring_StringRemoveLastOccurrence(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const needle = ring_vm_api_getstring(p, 2);
    const needle_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_remove_last_occurrence(h, needle, needle_len)), STZ_HANDLE);
}

// ─── RemoveNthOccurrence ───

fn ring_StringRemoveNthOccurrence(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const needle = ring_vm_api_getstring(p, 2);
    const needle_len: usize = @intCast(ring_vm_api_getstringsize(p, 2));
    const n: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_remove_nth_occurrence(h, needle, needle_len, n)), STZ_HANDLE);
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

// ─── Substrings and unique chars ───

fn ring_StringAllSubstringsCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 2));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_all_substrings_cs(h, case)), STZ_HANDLE);
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

fn ring_StringIndexOfCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const l = ring_vm_api_getstringsize(p, 2);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_index_of_cs(h, s, l, case)));
}

fn ring_StringIndexOfFromCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const l = ring_vm_api_getstringsize(p, 2);
    const start: usize = @intFromFloat(ring_vm_api_getnumber(p, 3));
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 4));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_index_of_from_cs(h, s, l, start, case)));
}

fn ring_StringFindAllCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const l = ring_vm_api_getstringsize(p, 2);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_find_all_cs(h, s, l, case)), FIND_HANDLE);
}

fn ring_StringLastIndexOfCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const l = ring_vm_api_getstringsize(p, 2);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retnumber(p, @floatFromInt(string.str_last_index_of_cs(h, s, l, case)));
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

fn ring_StringRemoveAllCS(p: *anyopaque) callconv(.c) void {
    const h = getHandle(p, 1);
    const s = ring_vm_api_getstring(p, 2);
    const l = ring_vm_api_getstringsize(p, 2);
    const case: c_int = @intFromFloat(ring_vm_api_getnumber(p, 3));
    ring_vm_api_retcpointer(p, @ptrCast(string.str_remove_all_cs(h, s, l, case)), STZ_HANDLE);
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
    .{ .name = "stzenginestringindexof", .func = &ring_StringIndexOf },
    .{ .name = "stzenginestringindexoffrom", .func = &ring_StringIndexOfFrom },
    .{ .name = "stzenginestringbytetocp", .func = &ring_StringByteToCp },
    .{ .name = "stzenginestringcountof", .func = &ring_StringCountOf },
    .{ .name = "stzenginestringlastindexof", .func = &ring_StringLastIndexOf },
    .{ .name = "stzenginestringcontains", .func = &ring_StringContains },
    .{ .name = "stzenginestringstartswith", .func = &ring_StringStartsWith },
    .{ .name = "stzenginestringendswith", .func = &ring_StringEndsWith },
    .{ .name = "stzenginestringfindall", .func = &ring_StringFindAll },
    .{ .name = "stzenginefindresultcount", .func = &ring_FindResultCount },
    .{ .name = "stzenginefindresultget", .func = &ring_FindResultGet },
    .{ .name = "stzenginefindresultfree", .func = &ring_FindResultFree },
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
    .{ .name = "stzenginestringcountcharsoftype", .func = &ring_StringCountCharsOfType },
    .{ .name = "stzenginestringisnumeric", .func = &ring_StringIsNumeric },
    .{ .name = "stzenginestringisalpha", .func = &ring_StringIsAlpha },
    .{ .name = "stzenginestringfindnth", .func = &ring_StringFindNth },
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
    .{ .name = "stzenginestringisblank", .func = &ring_StringIsBlank },
    .{ .name = "stzenginestringtopascalcase", .func = &ring_StringToPascalCase },
    .{ .name = "stzenginestringisidentifier", .func = &ring_StringIsIdentifier },
    .{ .name = "stzenginestringreplacebetween", .func = &ring_StringReplaceBetween },
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
    .{ .name = "stzenginestringissnakecase", .func = &ring_StringIsSnakeCase },
    .{ .name = "stzenginestringiskebabcase", .func = &ring_StringIsKebabCase },
    .{ .name = "stzenginestringcountuniquechars", .func = &ring_StringCountUniqueChars },
    .{ .name = "stzenginestringcaesar", .func = &ring_StringCaesar },
    .{ .name = "stzenginestringmirror", .func = &ring_StringMirror },
    .{ .name = "stzenginestringrepeateachchar", .func = &ring_StringRepeatEachChar },
    .{ .name = "stzenginestringbeginswithanyx", .func = &ring_StringStartsWithAny },
    .{ .name = "stzenginestringfinisheswithanyx", .func = &ring_StringEndsWithAny },
    .{ .name = "stzenginestringtobinary", .func = &ring_StringToBinary },
    .{ .name = "stzenginestingsortwords", .func = &ring_StringSortWords },
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
    .{ .name = "stzenginestringtodotcase", .func = &ring_StringToDotCase },
    .{ .name = "stzenginestringabbreviate", .func = &ring_StringAbbreviate },
    .{ .name = "stzenginestringcountsubstring", .func = &ring_StringCountSubstring },
    .{ .name = "stzenginestringtopathcase", .func = &ring_StringToPathCase },
    .{ .name = "stzenginestingleftpad", .func = &ring_StringLeftPad },
    .{ .name = "stzenginestringrightpad", .func = &ring_StringRightPad },
    .{ .name = "stzenginestringtohex", .func = &ring_StringToHex },
    .{ .name = "stzenginestringhex", .func = &ring_StringFromHex },
    .{ .name = "stzenginestingsoundex", .func = &ring_StringSoundex },
    .{ .name = "stzenginestringvigenereencrypt", .func = &ring_StringVigenereEncrypt },
    .{ .name = "stzenginestringatbash", .func = &ring_StringAtbash },
    .{ .name = "stzenginestringcountwordsmatching", .func = &ring_StringCountWordsMatching },
    .{ .name = "stzenginestringtruncatewords", .func = &ring_StringTruncateWords },
    .{ .name = "stzenginestringtoconstantcase", .func = &ring_StringToConstantCase },
    .{ .name = "stzenginestringfirstword", .func = &ring_StringFirstWord },
    .{ .name = "stzenginestringlastword", .func = &ring_StringLastWord },
    .{ .name = "stzenginestringtonato", .func = &ring_StringToNato },
    .{ .name = "stzenginestringcommonality", .func = &ring_StringCommonality },
    .{ .name = "stzenginestringdiffchars", .func = &ring_StringDiffChars },
    .{ .name = "stzenginestringrot47", .func = &ring_StringRot47 },
    .{ .name = "stzenginestringisisogram", .func = &ring_StringIsIsogram },
    .{ .name = "stzenginestringreverseeachword", .func = &ring_StringReverseEachWord },
    .{ .name = "stzenginestringcountdigits", .func = &ring_StringCountDigits },
    .{ .name = "stzenginestingstriptags", .func = &ring_StringStripTags },
    .{ .name = "stzenginestringtoslug", .func = &ring_StringToSlug },
    .{ .name = "stzenginestringcountspaces", .func = &ring_StringCountSpaces },
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
    .{ .name = "stzenginestingscanint", .func = &ring_StringScanInt },
    .{ .name = "stzenginestringtoordinal", .func = &ring_StringToOrdinal },
    .{ .name = "stzenginestringcpcount", .func = &ring_StringCpCount },
    .{ .name = "stzenginestringcharssplit", .func = &ring_StringCharsSplit },
    .{ .name = "stzenginestingleft", .func = &ring_StringLeft },
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
    .{ .name = "stzenginestringindexofcs", .func = &ring_StringIndexOfCS },
    .{ .name = "stzenginestringindexoffromcs", .func = &ring_StringIndexOfFromCS },
    .{ .name = "stzenginestringfindallcs", .func = &ring_StringFindAllCS },
    .{ .name = "stzenginestringlastindexofcs", .func = &ring_StringLastIndexOfCS },
    .{ .name = "stzenginestringcountofcs", .func = &ring_StringCountOfCS },
    .{ .name = "stzenginestringcontainscs", .func = &ring_StringContainsCS },
    .{ .name = "stzenginestringstartswithcs", .func = &ring_StringStartsWithCS },
    .{ .name = "stzenginestringendswithcs", .func = &ring_StringEndsWithCS },
    .{ .name = "stzenginestringequalscs", .func = &ring_StringEqualsCS },
    .{ .name = "stzenginestringfindnthcs", .func = &ring_StringFindNthCS },
    .{ .name = "stzenginestringreplacecs", .func = &ring_StringReplaceCS },
    .{ .name = "stzenginestringremoveallcs", .func = &ring_StringRemoveAllCS },
    .{ .name = "stzenginestringsplitcountcs", .func = &ring_StringSplitCountCS },
    .{ .name = "stzenginestringsplitgetcs", .func = &ring_StringSplitGetCS },
    .{ .name = "stzenginestringallsubstringscs", .func = &ring_StringAllSubstringsCS },
    .{ .name = "stzenginestringuniquecharscs", .func = &ring_StringUniqueCharsCS },
    .{ .name = "stzenginestringsubstringscount", .func = &ring_StringSubstringsCount },
    .{ .name = "stzenginestringsubstringsofnchars", .func = &ring_StringSubstringsOfNChars },
};

pub fn ringlib_init(pRingState: ?*anyopaque) callconv(.c) void {
    if (pRingState) |state| R.registerAll(state, &regs);
}
