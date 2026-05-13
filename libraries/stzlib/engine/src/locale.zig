// Softanza Engine -- Locale Operations (Tier 2)
//
// Replaces QLocale with pure Zig implementations.
// Provides AM/PM text, case conversion, number formatting,
// and locale-aware month/day names.
// All functions use C ABI for Ring FFI compatibility.

const std = @import("std");
const mem = std.mem;

const gpa = std.heap.c_allocator;

// ─── AM/PM Text ───

pub fn stz_locale_am_text(buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    const text = "AM";
    if (buf_len < text.len) return 0;
    @memcpy(buf[0..text.len], text);
    return text.len;
}

pub fn stz_locale_pm_text(buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    const text = "PM";
    if (buf_len < text.len) return 0;
    @memcpy(buf[0..text.len], text);
    return text.len;
}

// ─── Case Conversion ───

pub fn stz_locale_to_upper(src: [*c]const u8, src_len: usize, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    if (src == null or src_len == 0) return 0;
    if (buf_len < src_len) return 0;
    const input = src[0..src_len];
    for (input, 0..) |byte, i| {
        buf[i] = std.ascii.toUpper(byte);
    }
    return src_len;
}

pub fn stz_locale_to_lower(src: [*c]const u8, src_len: usize, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    if (src == null or src_len == 0) return 0;
    if (buf_len < src_len) return 0;
    const input = src[0..src_len];
    for (input, 0..) |byte, i| {
        buf[i] = std.ascii.toLower(byte);
    }
    return src_len;
}

pub fn stz_locale_to_titlecase(src: [*c]const u8, src_len: usize, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    if (src == null or src_len == 0) return 0;
    if (buf_len < src_len) return 0;
    const input = src[0..src_len];
    var after_space = true;
    for (input, 0..) |byte, i| {
        if (after_space and std.ascii.isAlphabetic(byte)) {
            buf[i] = std.ascii.toUpper(byte);
            after_space = false;
        } else {
            buf[i] = std.ascii.toLower(byte);
            after_space = (byte == ' ' or byte == '\t' or byte == '\n' or byte == '-');
        }
    }
    return src_len;
}

// ─── Number Formatting ───

pub fn stz_locale_format_number(value: f64, decimals: u8, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    if (buf == null or buf_len == 0) return 0;

    // Format the number with std.fmt first, then insert thousand separators
    var raw: [64]u8 = undefined;
    const raw_str = switch (decimals) {
        0 => std.fmt.bufPrint(&raw, "{d:.0}", .{value}) catch return 0,
        1 => std.fmt.bufPrint(&raw, "{d:.1}", .{value}) catch return 0,
        2 => std.fmt.bufPrint(&raw, "{d:.2}", .{value}) catch return 0,
        3 => std.fmt.bufPrint(&raw, "{d:.3}", .{value}) catch return 0,
        4 => std.fmt.bufPrint(&raw, "{d:.4}", .{value}) catch return 0,
        else => std.fmt.bufPrint(&raw, "{d:.2}", .{value}) catch return 0,
    };

    // Split on decimal point
    const dot_pos = mem.indexOf(u8, raw_str, ".") orelse raw_str.len;
    const int_part = raw_str[0..dot_pos];
    const frac_part = if (dot_pos < raw_str.len) raw_str[dot_pos..] else "";

    // Find start of digits (skip '-')
    const digit_start: usize = if (int_part.len > 0 and int_part[0] == '-') 1 else 0;
    const digits = int_part[digit_start..];

    var tmp: [64]u8 = undefined;
    var pos: usize = 0;

    // Copy sign
    if (digit_start > 0) {
        tmp[pos] = '-';
        pos += 1;
    }

    // Insert thousand separators into digit portion
    var first_group = digits.len % 3;
    if (first_group == 0) first_group = 3;

    for (digits, 0..) |digit, i| {
        if (i > 0 and i == first_group) {
            tmp[pos] = ',';
            pos += 1;
            first_group += 3;
        }
        tmp[pos] = digit;
        pos += 1;
    }

    // Append fractional part
    for (frac_part) |c| {
        tmp[pos] = c;
        pos += 1;
    }

    if (pos > buf_len) return 0;
    @memcpy(buf[0..pos], tmp[0..pos]);
    return pos;
}

// ─── Month / Day Names ───

const month_names = [_][]const u8{
    "January", "February", "March",     "April",   "May",      "June",
    "July",    "August",   "September", "October", "November", "December",
};

const month_abbr = [_][]const u8{
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
};

const day_names = [_][]const u8{
    "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday",
};

const day_abbr = [_][]const u8{
    "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun",
};

pub fn stz_locale_month_name(month: u8, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    if (month < 1 or month > 12) return 0;
    const name = month_names[month - 1];
    if (name.len > buf_len) return 0;
    @memcpy(buf[0..name.len], name);
    return name.len;
}

pub fn stz_locale_month_abbr(month: u8, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    if (month < 1 or month > 12) return 0;
    const name = month_abbr[month - 1];
    if (name.len > buf_len) return 0;
    @memcpy(buf[0..name.len], name);
    return name.len;
}

pub fn stz_locale_day_name(dow: u8, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    if (dow < 1 or dow > 7) return 0;
    const name = day_names[dow - 1];
    if (name.len > buf_len) return 0;
    @memcpy(buf[0..name.len], name);
    return name.len;
}

pub fn stz_locale_day_abbr(dow: u8, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    if (dow < 1 or dow > 7) return 0;
    const name = day_abbr[dow - 1];
    if (name.len > buf_len) return 0;
    @memcpy(buf[0..name.len], name);
    return name.len;
}

// ─── Tests ───

test "am pm text" {
    var buf: [4]u8 = undefined;
    const am_len = stz_locale_am_text(&buf, 4);
    try std.testing.expect(mem.eql(u8, buf[0..am_len], "AM"));
    const pm_len = stz_locale_pm_text(&buf, 4);
    try std.testing.expect(mem.eql(u8, buf[0..pm_len], "PM"));
}

test "case conversion" {
    var buf: [32]u8 = undefined;
    const upper_len = stz_locale_to_upper("hello world", 11, &buf, 32);
    try std.testing.expect(mem.eql(u8, buf[0..upper_len], "HELLO WORLD"));

    const lower_len = stz_locale_to_lower("HELLO WORLD", 11, &buf, 32);
    try std.testing.expect(mem.eql(u8, buf[0..lower_len], "hello world"));

    const title_len = stz_locale_to_titlecase("hello world", 11, &buf, 32);
    try std.testing.expect(mem.eql(u8, buf[0..title_len], "Hello World"));
}

test "titlecase with hyphens" {
    var buf: [32]u8 = undefined;
    const len = stz_locale_to_titlecase("jean-pierre dupont", 18, &buf, 32);
    try std.testing.expect(mem.eql(u8, buf[0..len], "Jean-Pierre Dupont"));
}

test "number formatting" {
    var buf: [32]u8 = undefined;

    const len1 = stz_locale_format_number(1234567.89, 2, &buf, 32);
    try std.testing.expect(mem.eql(u8, buf[0..len1], "1,234,567.89"));

    const len2 = stz_locale_format_number(42.0, 0, &buf, 32);
    try std.testing.expect(mem.eql(u8, buf[0..len2], "42"));

    const len3 = stz_locale_format_number(-500.5, 1, &buf, 32);
    try std.testing.expect(mem.eql(u8, buf[0..len3], "-500.5"));
}

test "month names" {
    var buf: [16]u8 = undefined;
    const len = stz_locale_month_name(1, &buf, 16);
    try std.testing.expect(mem.eql(u8, buf[0..len], "January"));

    const len2 = stz_locale_month_abbr(12, &buf, 16);
    try std.testing.expect(mem.eql(u8, buf[0..len2], "Dec"));
}

test "day names" {
    var buf: [16]u8 = undefined;
    const len = stz_locale_day_name(1, &buf, 16);
    try std.testing.expect(mem.eql(u8, buf[0..len], "Monday"));

    const len2 = stz_locale_day_abbr(7, &buf, 16);
    try std.testing.expect(mem.eql(u8, buf[0..len2], "Sun"));
}
