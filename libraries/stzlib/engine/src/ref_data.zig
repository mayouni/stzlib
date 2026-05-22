const std = @import("std");
const builtin = @import("builtin");
const c = @cImport({
    @cInclude("sqlite3.h");
});
const unicode_data = @import("unicode_data.zig");

// Reference data queries — reuses the same unicode.db opened by unicode_data module.
// Tables: scripts, script_ranges, script_languages, directions, categories,
//         regex_patterns, words, box_draw_chars, invertible_chars, diacritics_latin,
//         diacritics_arabic, roman_numbers, mandarin_numbers, fraction_numbers,
//         arabic_special_chars, invisible_chars, word_separators, sentence_separators,
//         locale_abbreviations, system_commands

fn getDb() ?*c.sqlite3 {
    const wrapper = unicode_data.getGlobalDb() orelse return null;
    return @ptrCast(wrapper.db);
}

// ── Scripts ──────────────────────────────────────────────────────────

pub fn scriptCount() i32 {
    const db = getDb() orelse return 0;
    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(db, "SELECT COUNT(*) FROM scripts", -1, &stmt, null) != c.SQLITE_OK) return 0;
    defer _ = c.sqlite3_finalize(stmt);
    if (c.sqlite3_step(stmt) == c.SQLITE_ROW) return c.sqlite3_column_int(stmt, 0);
    return 0;
}

pub fn scriptName(code: i32, out: [*]u8, max: i32) i32 {
    const db = getDb() orelse return 0;
    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(db, "SELECT name FROM scripts WHERE code=?1", -1, &stmt, null) != c.SQLITE_OK) return 0;
    defer _ = c.sqlite3_finalize(stmt);
    _ = c.sqlite3_bind_int(stmt, 1, code);
    if (c.sqlite3_step(stmt) == c.SQLITE_ROW) {
        const txt = c.sqlite3_column_text(stmt, 0);
        const len: usize = @intCast(c.sqlite3_column_bytes(stmt, 0));
        if (txt) |t| {
            const n = @min(len, @as(usize, @intCast(max)) -| 1);
            @memcpy(out[0..n], t[0..n]);
            out[n] = 0;
            return @intCast(n);
        }
    }
    return 0;
}

// ── Directions ───────────────────────────────────────────────────────

pub fn directionCount() i32 {
    const db = getDb() orelse return 0;
    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(db, "SELECT COUNT(*) FROM directions", -1, &stmt, null) != c.SQLITE_OK) return 0;
    defer _ = c.sqlite3_finalize(stmt);
    if (c.sqlite3_step(stmt) == c.SQLITE_ROW) return c.sqlite3_column_int(stmt, 0);
    return 0;
}

pub fn directionName(nbr: i32, out: [*]u8, max: i32) i32 {
    const db = getDb() orelse return 0;
    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(db, "SELECT stz_name FROM directions WHERE nbr=?1", -1, &stmt, null) != c.SQLITE_OK) return 0;
    defer _ = c.sqlite3_finalize(stmt);
    _ = c.sqlite3_bind_int(stmt, 1, nbr);
    if (c.sqlite3_step(stmt) == c.SQLITE_ROW) {
        const txt = c.sqlite3_column_text(stmt, 0);
        const len: usize = @intCast(c.sqlite3_column_bytes(stmt, 0));
        if (txt) |t| {
            const n = @min(len, @as(usize, @intCast(max)) -| 1);
            @memcpy(out[0..n], t[0..n]);
            out[n] = 0;
            return @intCast(n);
        }
    }
    return 0;
}

// ── Categories ───────────────────────────────────────────────────────

pub fn categoryCount() i32 {
    const db = getDb() orelse return 0;
    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(db, "SELECT COUNT(*) FROM categories", -1, &stmt, null) != c.SQLITE_OK) return 0;
    defer _ = c.sqlite3_finalize(stmt);
    if (c.sqlite3_step(stmt) == c.SQLITE_ROW) return c.sqlite3_column_int(stmt, 0);
    return 0;
}

pub fn categoryName(nbr: i32, out: [*]u8, max: i32) i32 {
    const db = getDb() orelse return 0;
    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(db, "SELECT name FROM categories WHERE nbr=?1", -1, &stmt, null) != c.SQLITE_OK) return 0;
    defer _ = c.sqlite3_finalize(stmt);
    _ = c.sqlite3_bind_int(stmt, 1, nbr);
    if (c.sqlite3_step(stmt) == c.SQLITE_ROW) {
        const txt = c.sqlite3_column_text(stmt, 0);
        const len: usize = @intCast(c.sqlite3_column_bytes(stmt, 0));
        if (txt) |t| {
            const n = @min(len, @as(usize, @intCast(max)) -| 1);
            @memcpy(out[0..n], t[0..n]);
            out[n] = 0;
            return @intCast(n);
        }
    }
    return 0;
}

// ── Regex Patterns ───────────────────────────────────────────────────

pub fn regexPatternCount() i32 {
    const db = getDb() orelse return 0;
    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(db, "SELECT COUNT(*) FROM regex_patterns", -1, &stmt, null) != c.SQLITE_OK) return 0;
    defer _ = c.sqlite3_finalize(stmt);
    if (c.sqlite3_step(stmt) == c.SQLITE_ROW) return c.sqlite3_column_int(stmt, 0);
    return 0;
}

pub fn regexPattern(name_ptr: [*]const u8, name_len: i32, out: [*]u8, max: i32) i32 {
    const db = getDb() orelse return 0;
    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(db, "SELECT pattern FROM regex_patterns WHERE name=?1", -1, &stmt, null) != c.SQLITE_OK) return 0;
    defer _ = c.sqlite3_finalize(stmt);
    _ = c.sqlite3_bind_text(stmt, 1, name_ptr, name_len, c.SQLITE_TRANSIENT);
    if (c.sqlite3_step(stmt) == c.SQLITE_ROW) {
        const txt = c.sqlite3_column_text(stmt, 0);
        const len: usize = @intCast(c.sqlite3_column_bytes(stmt, 0));
        if (txt) |t| {
            const n = @min(len, @as(usize, @intCast(max)) -| 1);
            @memcpy(out[0..n], t[0..n]);
            out[n] = 0;
            return @intCast(n);
        }
    }
    return 0;
}

// ── Words (trilingual) ───────────────────────────────────────────────

pub fn wordCount() i32 {
    const db = getDb() orelse return 0;
    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(db, "SELECT COUNT(*) FROM words", -1, &stmt, null) != c.SQLITE_OK) return 0;
    defer _ = c.sqlite3_finalize(stmt);
    if (c.sqlite3_step(stmt) == c.SQLITE_ROW) return c.sqlite3_column_int(stmt, 0);
    return 0;
}

pub fn wordAt(idx: i32, lang: i32, out: [*]u8, max: i32) i32 {
    const db = getDb() orelse return 0;
    const col_name: [*:0]const u8 = switch (lang) {
        0 => "english",
        1 => "french",
        2 => "arabic",
        else => return 0,
    };
    var sql_buf: [128]u8 = undefined;
    const sql = std.fmt.bufPrint(&sql_buf, "SELECT {s} FROM words WHERE rowid=?1", .{col_name}) catch return 0;
    sql_buf[sql.len] = 0;
    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(db, @ptrCast(sql_buf[0..sql.len :0]), -1, &stmt, null) != c.SQLITE_OK) return 0;
    defer _ = c.sqlite3_finalize(stmt);
    _ = c.sqlite3_bind_int(stmt, 1, idx);
    if (c.sqlite3_step(stmt) == c.SQLITE_ROW) {
        const txt = c.sqlite3_column_text(stmt, 0);
        const len: usize = @intCast(c.sqlite3_column_bytes(stmt, 0));
        if (txt) |t| {
            const n = @min(len, @as(usize, @intCast(max)) -| 1);
            @memcpy(out[0..n], t[0..n]);
            out[n] = 0;
            return @intCast(n);
        }
    }
    return 0;
}

// ── Box Drawing Characters ───────────────────────────────────────────

pub fn boxDrawCharCount() i32 {
    const db = getDb() orelse return 0;
    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(db, "SELECT COUNT(*) FROM box_draw_chars", -1, &stmt, null) != c.SQLITE_OK) return 0;
    defer _ = c.sqlite3_finalize(stmt);
    if (c.sqlite3_step(stmt) == c.SQLITE_ROW) return c.sqlite3_column_int(stmt, 0);
    return 0;
}

pub fn boxDrawChar(name_ptr: [*]const u8, name_len: i32, out: [*]u8, max: i32) i32 {
    const db = getDb() orelse return 0;
    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(db, "SELECT char_value FROM box_draw_chars WHERE name=?1", -1, &stmt, null) != c.SQLITE_OK) return 0;
    defer _ = c.sqlite3_finalize(stmt);
    _ = c.sqlite3_bind_text(stmt, 1, name_ptr, name_len, c.SQLITE_TRANSIENT);
    if (c.sqlite3_step(stmt) == c.SQLITE_ROW) {
        const txt = c.sqlite3_column_text(stmt, 0);
        const len: usize = @intCast(c.sqlite3_column_bytes(stmt, 0));
        if (txt) |t| {
            const n = @min(len, @as(usize, @intCast(max)) -| 1);
            @memcpy(out[0..n], t[0..n]);
            out[n] = 0;
            return @intCast(n);
        }
    }
    return 0;
}

// ── Invertible Characters ────────────────────────────────────────────

pub fn invertibleCharCount() i32 {
    const db = getDb() orelse return 0;
    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(db, "SELECT COUNT(*) FROM invertible_chars", -1, &stmt, null) != c.SQLITE_OK) return 0;
    defer _ = c.sqlite3_finalize(stmt);
    if (c.sqlite3_step(stmt) == c.SQLITE_ROW) return c.sqlite3_column_int(stmt, 0);
    return 0;
}

pub fn invertedOf(char_ptr: [*]const u8, char_len: i32, out: [*]u8, max: i32) i32 {
    const db = getDb() orelse return 0;
    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(db, "SELECT inverted FROM invertible_chars WHERE original=?1", -1, &stmt, null) != c.SQLITE_OK) return 0;
    defer _ = c.sqlite3_finalize(stmt);
    _ = c.sqlite3_bind_text(stmt, 1, char_ptr, char_len, c.SQLITE_TRANSIENT);
    if (c.sqlite3_step(stmt) == c.SQLITE_ROW) {
        const txt = c.sqlite3_column_text(stmt, 0);
        const len: usize = @intCast(c.sqlite3_column_bytes(stmt, 0));
        if (txt) |t| {
            const n = @min(len, @as(usize, @intCast(max)) -| 1);
            @memcpy(out[0..n], t[0..n]);
            out[n] = 0;
            return @intCast(n);
        }
    }
    return 0;
}

// ── Latin Diacritics ─────────────────────────────────────────────────

pub fn latinDiacriticCount() i32 {
    const db = getDb() orelse return 0;
    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(db, "SELECT COUNT(*) FROM diacritics_latin", -1, &stmt, null) != c.SQLITE_OK) return 0;
    defer _ = c.sqlite3_finalize(stmt);
    if (c.sqlite3_step(stmt) == c.SQLITE_ROW) return c.sqlite3_column_int(stmt, 0);
    return 0;
}

pub fn latinDiacriticBase(diac_ptr: [*]const u8, diac_len: i32, out: [*]u8, max: i32) i32 {
    const db = getDb() orelse return 0;
    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(db, "SELECT base_char FROM diacritics_latin WHERE diacritized=?1", -1, &stmt, null) != c.SQLITE_OK) return 0;
    defer _ = c.sqlite3_finalize(stmt);
    _ = c.sqlite3_bind_text(stmt, 1, diac_ptr, diac_len, c.SQLITE_TRANSIENT);
    if (c.sqlite3_step(stmt) == c.SQLITE_ROW) {
        const txt = c.sqlite3_column_text(stmt, 0);
        const len: usize = @intCast(c.sqlite3_column_bytes(stmt, 0));
        if (txt) |t| {
            const n = @min(len, @as(usize, @intCast(max)) -| 1);
            @memcpy(out[0..n], t[0..n]);
            out[n] = 0;
            return @intCast(n);
        }
    }
    return 0;
}

// ── System Commands ──────────────────────────────────────────────────

pub fn systemCommandCount() i32 {
    const db = getDb() orelse return 0;
    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(db, "SELECT COUNT(*) FROM system_commands", -1, &stmt, null) != c.SQLITE_OK) return 0;
    defer _ = c.sqlite3_finalize(stmt);
    if (c.sqlite3_step(stmt) == c.SQLITE_ROW) return c.sqlite3_column_int(stmt, 0);
    return 0;
}

pub fn systemCommand(name_ptr: [*]const u8, name_len: i32, platform: i32, out: [*]u8, max: i32) i32 {
    const db = getDb() orelse return 0;
    const col: [*:0]const u8 = if (platform == 0) "windows_cmd" else "unix_cmd";
    var sql_buf: [128]u8 = undefined;
    const sql = std.fmt.bufPrint(&sql_buf, "SELECT {s} FROM system_commands WHERE name=?1", .{col}) catch return 0;
    sql_buf[sql.len] = 0;
    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(db, @ptrCast(sql_buf[0..sql.len :0]), -1, &stmt, null) != c.SQLITE_OK) return 0;
    defer _ = c.sqlite3_finalize(stmt);
    _ = c.sqlite3_bind_text(stmt, 1, name_ptr, name_len, c.SQLITE_TRANSIENT);
    if (c.sqlite3_step(stmt) == c.SQLITE_ROW) {
        const txt = c.sqlite3_column_text(stmt, 0);
        const len: usize = @intCast(c.sqlite3_column_bytes(stmt, 0));
        if (txt) |t| {
            const n = @min(len, @as(usize, @intCast(max)) -| 1);
            @memcpy(out[0..n], t[0..n]);
            out[n] = 0;
            return @intCast(n);
        }
    }
    return 0;
}

// ── C ABI exports ────────────────────────────────────────────────────

pub export fn stz_refdata_script_count() callconv(.c) i32 {
    return scriptCount();
}

pub export fn stz_refdata_script_name(code: i32, out: [*]u8, max: i32) callconv(.c) i32 {
    return scriptName(code, out, max);
}

pub export fn stz_refdata_direction_count() callconv(.c) i32 {
    return directionCount();
}

pub export fn stz_refdata_direction_name(nbr: i32, out: [*]u8, max: i32) callconv(.c) i32 {
    return directionName(nbr, out, max);
}

pub export fn stz_refdata_category_count() callconv(.c) i32 {
    return categoryCount();
}

pub export fn stz_refdata_category_name(nbr: i32, out: [*]u8, max: i32) callconv(.c) i32 {
    return categoryName(nbr, out, max);
}

pub export fn stz_refdata_regex_count() callconv(.c) i32 {
    return regexPatternCount();
}

pub export fn stz_refdata_regex_pattern(name_ptr: [*]const u8, name_len: i32, out: [*]u8, max: i32) callconv(.c) i32 {
    return regexPattern(name_ptr, name_len, out, max);
}

pub export fn stz_refdata_word_count() callconv(.c) i32 {
    return wordCount();
}

pub export fn stz_refdata_word_at(idx: i32, lang: i32, out: [*]u8, max: i32) callconv(.c) i32 {
    return wordAt(idx, lang, out, max);
}

pub export fn stz_refdata_box_draw_count() callconv(.c) i32 {
    return boxDrawCharCount();
}

pub export fn stz_refdata_box_draw_char(name_ptr: [*]const u8, name_len: i32, out: [*]u8, max: i32) callconv(.c) i32 {
    return boxDrawChar(name_ptr, name_len, out, max);
}

pub export fn stz_refdata_invertible_count() callconv(.c) i32 {
    return invertibleCharCount();
}

pub export fn stz_refdata_inverted_of(char_ptr: [*]const u8, char_len: i32, out: [*]u8, max: i32) callconv(.c) i32 {
    return invertedOf(char_ptr, char_len, out, max);
}

pub export fn stz_refdata_latin_diacritic_count() callconv(.c) i32 {
    return latinDiacriticCount();
}

pub export fn stz_refdata_latin_diacritic_base(diac_ptr: [*]const u8, diac_len: i32, out: [*]u8, max: i32) callconv(.c) i32 {
    return latinDiacriticBase(diac_ptr, diac_len, out, max);
}

pub export fn stz_refdata_syscmd_count() callconv(.c) i32 {
    return systemCommandCount();
}

pub export fn stz_refdata_syscmd(name_ptr: [*]const u8, name_len: i32, platform: i32, out: [*]u8, max: i32) callconv(.c) i32 {
    return systemCommand(name_ptr, name_len, platform, out, max);
}

// ── Tests ────────────────────────────────────────────────────────────

fn openTestDb() ?*unicode_data.StzUnicodeDb {
    return unicode_data.openDb("data/unicode.db", "data/unicode.db".len);
}

test "ref_data: script count > 0" {
    const saved = unicode_data.getGlobalDb();
    const test_db = openTestDb();
    if (test_db == null) return;
    unicode_data.setGlobalDbForTest(test_db);
    defer {
        if (test_db) |db| unicode_data.closeDb(db);
        unicode_data.setGlobalDbForTest(saved);
    }
    const count = scriptCount();
    try std.testing.expect(count >= 156);
}

test "ref_data: direction count = 19" {
    const saved = unicode_data.getGlobalDb();
    const test_db = openTestDb();
    if (test_db == null) return;
    unicode_data.setGlobalDbForTest(test_db);
    defer {
        if (test_db) |db| unicode_data.closeDb(db);
        unicode_data.setGlobalDbForTest(saved);
    }
    const count = directionCount();
    try std.testing.expect(count == 19);
}

test "ref_data: category count = 30" {
    const saved = unicode_data.getGlobalDb();
    const test_db = openTestDb();
    if (test_db == null) return;
    unicode_data.setGlobalDbForTest(test_db);
    defer {
        if (test_db) |db| unicode_data.closeDb(db);
        unicode_data.setGlobalDbForTest(saved);
    }
    const count = categoryCount();
    try std.testing.expect(count == 30);
}

test "ref_data: regex pattern count > 700" {
    const saved = unicode_data.getGlobalDb();
    const test_db = openTestDb();
    if (test_db == null) return;
    unicode_data.setGlobalDbForTest(test_db);
    defer {
        if (test_db) |db| unicode_data.closeDb(db);
        unicode_data.setGlobalDbForTest(saved);
    }
    const count = regexPatternCount();
    try std.testing.expect(count >= 300);
}

test "ref_data: word count = 100" {
    const saved = unicode_data.getGlobalDb();
    const test_db = openTestDb();
    if (test_db == null) return;
    unicode_data.setGlobalDbForTest(test_db);
    defer {
        if (test_db) |db| unicode_data.closeDb(db);
        unicode_data.setGlobalDbForTest(saved);
    }
    const count = wordCount();
    try std.testing.expect(count >= 100);
}

test "ref_data: box draw char count > 80" {
    const saved = unicode_data.getGlobalDb();
    const test_db = openTestDb();
    if (test_db == null) return;
    unicode_data.setGlobalDbForTest(test_db);
    defer {
        if (test_db) |db| unicode_data.closeDb(db);
        unicode_data.setGlobalDbForTest(saved);
    }
    const count = boxDrawCharCount();
    try std.testing.expect(count >= 80);
}

test "ref_data: invertible char count > 50" {
    const saved = unicode_data.getGlobalDb();
    const test_db = openTestDb();
    if (test_db == null) return;
    unicode_data.setGlobalDbForTest(test_db);
    defer {
        if (test_db) |db| unicode_data.closeDb(db);
        unicode_data.setGlobalDbForTest(saved);
    }
    const count = invertibleCharCount();
    try std.testing.expect(count >= 50);
}

test "ref_data: latin diacritic count > 190" {
    const saved = unicode_data.getGlobalDb();
    const test_db = openTestDb();
    if (test_db == null) return;
    unicode_data.setGlobalDbForTest(test_db);
    defer {
        if (test_db) |db| unicode_data.closeDb(db);
        unicode_data.setGlobalDbForTest(saved);
    }
    const count = latinDiacriticCount();
    try std.testing.expect(count >= 190);
}

test "ref_data: system command count > 10" {
    const saved = unicode_data.getGlobalDb();
    const test_db = openTestDb();
    if (test_db == null) return;
    unicode_data.setGlobalDbForTest(test_db);
    defer {
        if (test_db) |db| unicode_data.closeDb(db);
        unicode_data.setGlobalDbForTest(saved);
    }
    const count = systemCommandCount();
    try std.testing.expect(count >= 10);
}

test "ref_data: lookup script name for Latin (code=3)" {
    const saved = unicode_data.getGlobalDb();
    const test_db = openTestDb();
    if (test_db == null) return;
    unicode_data.setGlobalDbForTest(test_db);
    defer {
        if (test_db) |db| unicode_data.closeDb(db);
        unicode_data.setGlobalDbForTest(saved);
    }
    var buf: [256]u8 = undefined;
    const len = scriptName(3, &buf, 256);
    try std.testing.expect(len > 0);
    try std.testing.expectEqualStrings("Latin", buf[0..@intCast(len)]);
}

test "ref_data: lookup regex pattern 'email'" {
    const saved = unicode_data.getGlobalDb();
    const test_db = openTestDb();
    if (test_db == null) return;
    unicode_data.setGlobalDbForTest(test_db);
    defer {
        if (test_db) |db| unicode_data.closeDb(db);
        unicode_data.setGlobalDbForTest(saved);
    }
    var buf: [1024]u8 = undefined;
    const name = "email";
    const len = regexPattern(name.ptr, @intCast(name.len), &buf, 1024);
    try std.testing.expect(len > 0);
}

test "ref_data: lookup word at index 1 (english=apple)" {
    const saved = unicode_data.getGlobalDb();
    const test_db = openTestDb();
    if (test_db == null) return;
    unicode_data.setGlobalDbForTest(test_db);
    defer {
        if (test_db) |db| unicode_data.closeDb(db);
        unicode_data.setGlobalDbForTest(saved);
    }
    var buf: [256]u8 = undefined;
    const len = wordAt(1, 0, &buf, 256);
    try std.testing.expect(len > 0);
    try std.testing.expectEqualStrings("apple", buf[0..@intCast(len)]);
}

test "ref_data: lookup box draw char LightH" {
    const saved = unicode_data.getGlobalDb();
    const test_db = openTestDb();
    if (test_db == null) return;
    unicode_data.setGlobalDbForTest(test_db);
    defer {
        if (test_db) |db| unicode_data.closeDb(db);
        unicode_data.setGlobalDbForTest(saved);
    }
    var buf: [64]u8 = undefined;
    const name = "LightH";
    const len = boxDrawChar(name.ptr, @intCast(name.len), &buf, 64);
    try std.testing.expect(len > 0);
}
