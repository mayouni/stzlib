const u = @import("unicode.zig");
const R = @import("ring_api.zig");

const g = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs2 = R.ring_vm_api_retstring2;
const rs = R.ring_vm_api_retstring;

fn ring_Category(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(u.stz_unicode_category(@intFromFloat(g(p, 1)))));
}
fn ring_CategoryString(p: *anyopaque) callconv(.c) void {
    var buf: [8]u8 = undefined;
    const n = u.stz_unicode_category_string(@intFromFloat(g(p, 1)), &buf, 8);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_IsLetter(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(u.stz_unicode_is_letter(@intFromFloat(g(p, 1)))));
}
fn ring_IsDigit(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(u.stz_unicode_is_digit(@intFromFloat(g(p, 1)))));
}
fn ring_IsNumber(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(u.stz_unicode_is_number(@intFromFloat(g(p, 1)))));
}
fn ring_IsUpper(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(u.stz_unicode_is_upper(@intFromFloat(g(p, 1)))));
}
fn ring_IsLower(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(u.stz_unicode_is_lower(@intFromFloat(g(p, 1)))));
}
fn ring_IsSpace(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(u.stz_unicode_is_space(@intFromFloat(g(p, 1)))));
}
fn ring_IsPunctuation(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(u.stz_unicode_is_punctuation(@intFromFloat(g(p, 1)))));
}
fn ring_IsSymbol(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(u.stz_unicode_is_symbol(@intFromFloat(g(p, 1)))));
}
fn ring_IsMark(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(u.stz_unicode_is_mark(@intFromFloat(g(p, 1)))));
}
fn ring_IsControl(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(u.stz_unicode_is_control(@intFromFloat(g(p, 1)))));
}
fn ring_IsValid(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(u.stz_unicode_is_valid(@intFromFloat(g(p, 1)))));
}
fn ring_BidiClass(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(u.stz_unicode_bidi_class(@intFromFloat(g(p, 1)))));
}
fn ring_Charwidth(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(u.stz_unicode_charwidth(@intFromFloat(g(p, 1)))));
}
fn ring_ToLower(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(u.stz_unicode_to_lower(@intFromFloat(g(p, 1)))));
}
fn ring_ToUpper(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(u.stz_unicode_to_upper(@intFromFloat(g(p, 1)))));
}
fn ring_ToTitle(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(u.stz_unicode_to_title(@intFromFloat(g(p, 1)))));
}
fn ring_ToLowerStr(p: *anyopaque) callconv(.c) void {
    var buf: [4096]u8 = undefined;
    const n = u.stz_unicode_to_lower_str(gs(p, 1), @intCast(gss(p, 1)), &buf, 4096);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_ToUpperStr(p: *anyopaque) callconv(.c) void {
    var buf: [4096]u8 = undefined;
    const n = u.stz_unicode_to_upper_str(gs(p, 1), @intCast(gss(p, 1)), &buf, 4096);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_ToTitleStr(p: *anyopaque) callconv(.c) void {
    var buf: [4096]u8 = undefined;
    const n = u.stz_unicode_to_title_str(gs(p, 1), @intCast(gss(p, 1)), &buf, 4096);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_Normalize(p: *anyopaque) callconv(.c) void {
    var out_len: usize = 0;
    const ptr = u.stz_unicode_normalize(gs(p, 1), @intCast(gss(p, 1)), @intFromFloat(g(p, 2)), &out_len);
    if (ptr != null and out_len > 0) {
        rs2(p, ptr, @intCast(out_len));
        u.stz_unicode_normalize_free(ptr, out_len);
    } else rs(p, "");
}
fn ring_Casefold(p: *anyopaque) callconv(.c) void {
    var out_len: usize = 0;
    const ptr = u.stz_unicode_casefold(gs(p, 1), @intCast(gss(p, 1)), &out_len);
    if (ptr != null and out_len > 0) {
        rs2(p, ptr, @intCast(out_len));
        u.stz_unicode_casefold_free(ptr, out_len);
    } else rs(p, "");
}
fn ring_StripMarks(p: *anyopaque) callconv(.c) void {
    var out_len: usize = 0;
    const ptr = u.stz_unicode_strip_marks(gs(p, 1), @intCast(gss(p, 1)), &out_len);
    if (ptr != null and out_len > 0) {
        rs2(p, ptr, @intCast(out_len));
        u.stz_unicode_strip_marks_free(ptr, out_len);
    } else rs(p, "");
}
fn ring_GraphemeCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(u.stz_unicode_grapheme_count(gs(p, 1), @intCast(gss(p, 1)))));
}
fn ring_GraphemeBreak(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(u.stz_unicode_grapheme_break(@intFromFloat(g(p, 1)), @intFromFloat(g(p, 2)))));
}
fn ring_Iterate(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(u.stz_unicode_iterate(gs(p, 1), @intCast(gss(p, 1)), @intFromFloat(g(p, 2)))));
}
fn ring_CpByteLen(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(u.stz_unicode_cp_byte_len(gs(p, 1), @intCast(gss(p, 1)), @intFromFloat(g(p, 2)))));
}
fn ring_Encode(p: *anyopaque) callconv(.c) void {
    var buf: [4]u8 = undefined;
    const n = u.stz_unicode_encode(@intFromFloat(g(p, 1)), &buf, 4);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, "");
}
fn ring_CpToByte(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(u.stz_unicode_cp_to_byte(gs(p, 1), @intCast(gss(p, 1)), @intFromFloat(g(p, 2)))));
}
fn ring_ByteToCp(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(u.stz_unicode_byte_to_cp(gs(p, 1), @intCast(gss(p, 1)), @intFromFloat(g(p, 2)))));
}

// ─── Script detection ───
fn ring_IsArabic(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(u.stz_unicode_is_arabic(@intFromFloat(g(p, 1)))));
}
fn ring_IsLatin(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(u.stz_unicode_is_latin(@intFromFloat(g(p, 1)))));
}
fn ring_IsGreek(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(u.stz_unicode_is_greek(@intFromFloat(g(p, 1)))));
}
fn ring_IsCyrillic(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(u.stz_unicode_is_cyrillic(@intFromFloat(g(p, 1)))));
}
fn ring_IsHebrew(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(u.stz_unicode_is_hebrew(@intFromFloat(g(p, 1)))));
}
fn ring_IsCjk(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(u.stz_unicode_is_cjk(@intFromFloat(g(p, 1)))));
}
fn ring_IsDevanagari(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(u.stz_unicode_is_devanagari(@intFromFloat(g(p, 1)))));
}
fn ring_IsThai(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(u.stz_unicode_is_thai(@intFromFloat(g(p, 1)))));
}

pub const regs = [_]R.Reg{
    .{ .name = "stzengineunicodecategory", .func = &ring_Category },
    .{ .name = "stzengineunicodecategorystring", .func = &ring_CategoryString },
    .{ .name = "stzengineunicodeisletter", .func = &ring_IsLetter },
    .{ .name = "stzengineunicodeisdigit", .func = &ring_IsDigit },
    .{ .name = "stzengineunicodeisnumber", .func = &ring_IsNumber },
    .{ .name = "stzengineunicodeisupper", .func = &ring_IsUpper },
    .{ .name = "stzengineunicodeislower", .func = &ring_IsLower },
    .{ .name = "stzengineunicodeisspace", .func = &ring_IsSpace },
    .{ .name = "stzengineunicodeispunctuation", .func = &ring_IsPunctuation },
    .{ .name = "stzengineunicodeissymbol", .func = &ring_IsSymbol },
    .{ .name = "stzengineunicodeismark", .func = &ring_IsMark },
    .{ .name = "stzengineunicodeiscontrol", .func = &ring_IsControl },
    .{ .name = "stzengineunicodeisvalid", .func = &ring_IsValid },
    .{ .name = "stzengineunicodebidiclass", .func = &ring_BidiClass },
    .{ .name = "stzengineunicodecharwidth", .func = &ring_Charwidth },
    .{ .name = "stzengineunicodetolower", .func = &ring_ToLower },
    .{ .name = "stzengineunicodetoupper", .func = &ring_ToUpper },
    .{ .name = "stzengineunicodetotitle", .func = &ring_ToTitle },
    .{ .name = "stzengineunicodetolowerstr", .func = &ring_ToLowerStr },
    .{ .name = "stzengineunicodetoupperstr", .func = &ring_ToUpperStr },
    .{ .name = "stzengineunicodetotitlestr", .func = &ring_ToTitleStr },
    .{ .name = "stzengineunicodenormalize", .func = &ring_Normalize },
    .{ .name = "stzengineunicodecasefold", .func = &ring_Casefold },
    .{ .name = "stzengineunicodestripmarks", .func = &ring_StripMarks },
    .{ .name = "stzengineunicodegraphemecount", .func = &ring_GraphemeCount },
    .{ .name = "stzengineunicodegraphemebreak", .func = &ring_GraphemeBreak },
    .{ .name = "stzengineunicodeiterate", .func = &ring_Iterate },
    .{ .name = "stzengineunicodecpbytelen", .func = &ring_CpByteLen },
    .{ .name = "stzengineunicodeencode", .func = &ring_Encode },
    .{ .name = "stzengineunicodecptobyte", .func = &ring_CpToByte },
    .{ .name = "stzengineunicodebytetocp", .func = &ring_ByteToCp },
    .{ .name = "stzengineunicodeisarabic", .func = &ring_IsArabic },
    .{ .name = "stzengineunicodeislatin", .func = &ring_IsLatin },
    .{ .name = "stzengineunicodeisgreek", .func = &ring_IsGreek },
    .{ .name = "stzengineunicodeiscyrillic", .func = &ring_IsCyrillic },
    .{ .name = "stzengineunicodeishebrew", .func = &ring_IsHebrew },
    .{ .name = "stzengineunicodeiscjk", .func = &ring_IsCjk },
    .{ .name = "stzengineunicodeisdevanagari", .func = &ring_IsDevanagari },
    .{ .name = "stzengineunicodeisthai", .func = &ring_IsThai },
};

pub fn ringlib_init(pRingState: ?*anyopaque) callconv(.c) void {
    if (pRingState) |state| R.registerAll(state, &regs);
}
