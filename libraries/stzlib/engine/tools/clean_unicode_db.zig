const c = @cImport({ @cInclude("sqlite3.h"); });
const std = @import("std");

pub fn main() !void {
    var db: ?*c.sqlite3 = null;
    if (c.sqlite3_open("data/unicode.db", &db) != c.SQLITE_OK or db == null) return error.DbOpen;
    defer _ = c.sqlite3_close(db.?);
    const d = db.?;
    const drops =
        \\DROP TABLE IF EXISTS scripts;
        \\DROP TABLE IF EXISTS script_ranges;
        \\DROP TABLE IF EXISTS script_languages;
        \\DROP TABLE IF EXISTS directions;
        \\DROP TABLE IF EXISTS categories;
        \\DROP TABLE IF EXISTS regex_patterns;
        \\DROP TABLE IF EXISTS words;
        \\DROP TABLE IF EXISTS box_draw_chars;
        \\DROP TABLE IF EXISTS invertible_chars;
        \\DROP TABLE IF EXISTS diacritics_latin;
        \\DROP TABLE IF EXISTS diacritics_arabic;
        \\DROP TABLE IF EXISTS roman_numbers;
        \\DROP TABLE IF EXISTS mandarin_numbers;
        \\DROP TABLE IF EXISTS fraction_numbers;
        \\DROP TABLE IF EXISTS invisible_chars;
        \\DROP TABLE IF EXISTS word_separators;
        \\DROP TABLE IF EXISTS sentence_separators;
        \\DROP TABLE IF EXISTS system_commands;
        \\DROP INDEX IF EXISTS idx_script_lang;
        \\DROP INDEX IF EXISTS idx_invert_orig;
        \\DROP INDEX IF EXISTS idx_diac_lat;
    ;
    _ = c.sqlite3_exec(d, drops, null, null, null);
    _ = c.sqlite3_exec(d, "VACUUM;", null, null, null);
    std.debug.print("Cleaned reference tables from unicode.db\n", .{});
}
