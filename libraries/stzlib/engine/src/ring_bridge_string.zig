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
};

pub fn ringlib_init(pRingState: ?*anyopaque) callconv(.c) void {
    if (pRingState) |state| R.registerAll(state, &regs);
}
