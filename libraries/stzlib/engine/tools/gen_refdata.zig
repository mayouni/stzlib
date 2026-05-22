const std = @import("std");
const c = @cImport({
    @cInclude("sqlite3.h");
});

const ref_schema =
    \\CREATE TABLE IF NOT EXISTS scripts (
    \\  code INTEGER PRIMARY KEY,
    \\  name TEXT NOT NULL
    \\);
    \\CREATE TABLE IF NOT EXISTS script_ranges (
    \\  script_code INTEGER NOT NULL,
    \\  range_start INTEGER NOT NULL,
    \\  range_end   INTEGER NOT NULL,
    \\  FOREIGN KEY (script_code) REFERENCES scripts(code)
    \\);
    \\CREATE TABLE IF NOT EXISTS script_languages (
    \\  script_code INTEGER NOT NULL,
    \\  language    TEXT NOT NULL,
    \\  FOREIGN KEY (script_code) REFERENCES scripts(code)
    \\);
    \\CREATE INDEX IF NOT EXISTS idx_script_lang ON script_languages(script_code);
    \\CREATE TABLE IF NOT EXISTS directions (
    \\  nbr        INTEGER PRIMARY KEY,
    \\  short_name TEXT NOT NULL,
    \\  stz_name   TEXT NOT NULL,
    \\  description TEXT NOT NULL
    \\);
    \\CREATE TABLE IF NOT EXISTS categories (
    \\  nbr  INTEGER PRIMARY KEY,
    \\  name TEXT NOT NULL
    \\);
    \\CREATE TABLE IF NOT EXISTS regex_patterns (
    \\  name    TEXT PRIMARY KEY,
    \\  pattern TEXT NOT NULL
    \\);
    \\CREATE TABLE IF NOT EXISTS words (
    \\  english TEXT NOT NULL,
    \\  french  TEXT NOT NULL,
    \\  arabic  TEXT NOT NULL
    \\);
    \\CREATE TABLE IF NOT EXISTS box_draw_chars (
    \\  name       TEXT PRIMARY KEY,
    \\  char_value TEXT NOT NULL
    \\);
    \\CREATE TABLE IF NOT EXISTS invertible_chars (
    \\  original TEXT NOT NULL,
    \\  inverted TEXT NOT NULL
    \\);
    \\CREATE INDEX IF NOT EXISTS idx_invert_orig ON invertible_chars(original);
    \\CREATE TABLE IF NOT EXISTS diacritics_latin (
    \\  diacritized TEXT NOT NULL,
    \\  base_char   TEXT NOT NULL,
    \\  description TEXT NOT NULL DEFAULT ''
    \\);
    \\CREATE INDEX IF NOT EXISTS idx_diac_lat ON diacritics_latin(diacritized);
    \\CREATE TABLE IF NOT EXISTS diacritics_arabic (
    \\  unicode     INTEGER NOT NULL,
    \\  without     INTEGER NOT NULL DEFAULT 0,
    \\  description TEXT NOT NULL DEFAULT ''
    \\);
    \\CREATE TABLE IF NOT EXISTS roman_numbers (
    \\  symbol TEXT NOT NULL,
    \\  value  INTEGER NOT NULL
    \\);
    \\CREATE TABLE IF NOT EXISTS mandarin_numbers (
    \\  symbol TEXT NOT NULL,
    \\  value  INTEGER NOT NULL
    \\);
    \\CREATE TABLE IF NOT EXISTS fraction_numbers (
    \\  fraction TEXT NOT NULL,
    \\  unicode  INTEGER NOT NULL
    \\);
    \\CREATE TABLE IF NOT EXISTS invisible_chars (
    \\  unicode INTEGER PRIMARY KEY
    \\);
    \\CREATE TABLE IF NOT EXISTS word_separators (
    \\  char_value TEXT NOT NULL
    \\);
    \\CREATE TABLE IF NOT EXISTS sentence_separators (
    \\  char_value TEXT NOT NULL
    \\);
    \\CREATE TABLE IF NOT EXISTS system_commands (
    \\  name         TEXT PRIMARY KEY,
    \\  windows_cmd  TEXT NOT NULL DEFAULT '',
    \\  unix_cmd     TEXT NOT NULL DEFAULT '',
    \\  description  TEXT NOT NULL DEFAULT '',
    \\  return_type  TEXT NOT NULL DEFAULT 'string'
    \\);
;

fn execSql(db: *c.sqlite3, sql: [*:0]const u8) void {
    _ = c.sqlite3_exec(db, sql, null, null, null);
}

fn insertText2(db: *c.sqlite3, sql: [*:0]const u8, v1: []const u8, v2: []const u8) void {
    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(db, sql, -1, &stmt, null) != c.SQLITE_OK) return;
    defer _ = c.sqlite3_finalize(stmt);
    _ = c.sqlite3_bind_text(stmt, 1, v1.ptr, @intCast(v1.len), c.SQLITE_TRANSIENT);
    _ = c.sqlite3_bind_text(stmt, 2, v2.ptr, @intCast(v2.len), c.SQLITE_TRANSIENT);
    _ = c.sqlite3_step(stmt);
}

fn insertText3(db: *c.sqlite3, sql: [*:0]const u8, v1: []const u8, v2: []const u8, v3: []const u8) void {
    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(db, sql, -1, &stmt, null) != c.SQLITE_OK) return;
    defer _ = c.sqlite3_finalize(stmt);
    _ = c.sqlite3_bind_text(stmt, 1, v1.ptr, @intCast(v1.len), c.SQLITE_TRANSIENT);
    _ = c.sqlite3_bind_text(stmt, 2, v2.ptr, @intCast(v2.len), c.SQLITE_TRANSIENT);
    _ = c.sqlite3_bind_text(stmt, 3, v3.ptr, @intCast(v3.len), c.SQLITE_TRANSIENT);
    _ = c.sqlite3_step(stmt);
}

fn insertInt1Text1(db: *c.sqlite3, sql: [*:0]const u8, int1: i32, t1: []const u8) void {
    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(db, sql, -1, &stmt, null) != c.SQLITE_OK) return;
    defer _ = c.sqlite3_finalize(stmt);
    _ = c.sqlite3_bind_int(stmt, 1, int1);
    _ = c.sqlite3_bind_text(stmt, 2, t1.ptr, @intCast(t1.len), c.SQLITE_TRANSIENT);
    _ = c.sqlite3_step(stmt);
}

fn insertInt1Text3(db: *c.sqlite3, sql: [*:0]const u8, int1: i32, t1: []const u8, t2: []const u8, t3: []const u8) void {
    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(db, sql, -1, &stmt, null) != c.SQLITE_OK) return;
    defer _ = c.sqlite3_finalize(stmt);
    _ = c.sqlite3_bind_int(stmt, 1, int1);
    _ = c.sqlite3_bind_text(stmt, 2, t1.ptr, @intCast(t1.len), c.SQLITE_TRANSIENT);
    _ = c.sqlite3_bind_text(stmt, 3, t2.ptr, @intCast(t2.len), c.SQLITE_TRANSIENT);
    _ = c.sqlite3_bind_text(stmt, 4, t3.ptr, @intCast(t3.len), c.SQLITE_TRANSIENT);
    _ = c.sqlite3_step(stmt);
}

fn insertText1Int1(db: *c.sqlite3, sql: [*:0]const u8, t1: []const u8, int1: i32) void {
    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(db, sql, -1, &stmt, null) != c.SQLITE_OK) return;
    defer _ = c.sqlite3_finalize(stmt);
    _ = c.sqlite3_bind_text(stmt, 1, t1.ptr, @intCast(t1.len), c.SQLITE_TRANSIENT);
    _ = c.sqlite3_bind_int(stmt, 2, int1);
    _ = c.sqlite3_step(stmt);
}

fn insertInt1(db: *c.sqlite3, sql: [*:0]const u8, int1: i32) void {
    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(db, sql, -1, &stmt, null) != c.SQLITE_OK) return;
    defer _ = c.sqlite3_finalize(stmt);
    _ = c.sqlite3_bind_int(stmt, 1, int1);
    _ = c.sqlite3_step(stmt);
}

fn insertText1(db: *c.sqlite3, sql: [*:0]const u8, t1: []const u8) void {
    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(db, sql, -1, &stmt, null) != c.SQLITE_OK) return;
    defer _ = c.sqlite3_finalize(stmt);
    _ = c.sqlite3_bind_text(stmt, 1, t1.ptr, @intCast(t1.len), c.SQLITE_TRANSIENT);
    _ = c.sqlite3_step(stmt);
}

fn insertSysCmd(db: *c.sqlite3, name: []const u8, win: []const u8, unix: []const u8, desc: []const u8, ret: []const u8) void {
    var stmt: ?*c.sqlite3_stmt = null;
    const sql = "INSERT INTO system_commands (name,windows_cmd,unix_cmd,description,return_type) VALUES (?1,?2,?3,?4,?5);";
    if (c.sqlite3_prepare_v2(db, sql, -1, &stmt, null) != c.SQLITE_OK) return;
    defer _ = c.sqlite3_finalize(stmt);
    _ = c.sqlite3_bind_text(stmt, 1, name.ptr, @intCast(name.len), c.SQLITE_TRANSIENT);
    _ = c.sqlite3_bind_text(stmt, 2, win.ptr, @intCast(win.len), c.SQLITE_TRANSIENT);
    _ = c.sqlite3_bind_text(stmt, 3, unix.ptr, @intCast(unix.len), c.SQLITE_TRANSIENT);
    _ = c.sqlite3_bind_text(stmt, 4, desc.ptr, @intCast(desc.len), c.SQLITE_TRANSIENT);
    _ = c.sqlite3_bind_text(stmt, 5, ret.ptr, @intCast(ret.len), c.SQLITE_TRANSIENT);
    _ = c.sqlite3_step(stmt);
}

pub fn main() !void {
    const db_path = "data/unicode.db";

    var db: ?*c.sqlite3 = null;
    var rc = c.sqlite3_open(db_path, &db);
    if (rc != c.SQLITE_OK or db == null) {
        std.debug.print("ERROR: cannot open database {s}\n", .{db_path});
        return error.DbOpen;
    }
    defer _ = c.sqlite3_close(db.?);

    const d = db.?;
    execSql(d, "PRAGMA journal_mode=WAL;");
    execSql(d, "PRAGMA synchronous=NORMAL;");

    var err_msg: [*c]u8 = null;
    rc = c.sqlite3_exec(d, ref_schema, null, null, &err_msg);
    if (rc != c.SQLITE_OK) {
        std.debug.print("ERROR: schema creation failed\n", .{});
        if (err_msg) |e| c.sqlite3_free(e);
        return error.Schema;
    }

    execSql(d, "BEGIN TRANSACTION;");

    // ── Scripts (156 entries) ────────────────────────────────────
    const scripts = @import("data/scripts.zig").scripts;
    for (scripts) |s| {
        insertInt1Text1(d, "INSERT OR REPLACE INTO scripts (code,name) VALUES (?1,?2);", s.code, s.name);
    }
    std.debug.print("  Scripts: {d} rows\n", .{scripts.len});

    // ── Directions (19 entries) ──────────────────────────────────
    const directions = @import("data/directions.zig").directions;
    for (directions) |dir| {
        insertInt1Text3(d, "INSERT OR REPLACE INTO directions (nbr,short_name,stz_name,description) VALUES (?1,?2,?3,?4);", dir.nbr, dir.short_name, dir.stz_name, dir.description);
    }
    std.debug.print("  Directions: {d} rows\n", .{directions.len});

    // ── Categories (30 entries) ──────────────────────────────────
    const categories = @import("data/categories.zig").categories;
    for (categories) |cat| {
        insertInt1Text1(d, "INSERT OR REPLACE INTO categories (nbr,name) VALUES (?1,?2);", cat.nbr, cat.name);
    }
    std.debug.print("  Categories: {d} rows\n", .{categories.len});

    // ── Regex patterns (731+ entries) ────────────────────────────
    const patterns = @import("data/regex_patterns.zig").patterns;
    for (patterns) |p| {
        insertText2(d, "INSERT OR REPLACE INTO regex_patterns (name,pattern) VALUES (?1,?2);", p.name, p.pattern);
    }
    std.debug.print("  Regex patterns: {d} rows\n", .{patterns.len});

    // ── Words (100 trilingual entries) ───────────────────────────
    const words = @import("data/words.zig").words;
    for (words) |w| {
        insertText3(d, "INSERT INTO words (english,french,arabic) VALUES (?1,?2,?3);", w.english, w.french, w.arabic);
    }
    std.debug.print("  Words: {d} rows\n", .{words.len});

    // ── Box drawing chars (80+ entries) ──────────────────────────
    const box_chars = @import("data/box_draw_chars.zig").box_draw_chars;
    for (box_chars) |bc| {
        insertText2(d, "INSERT OR REPLACE INTO box_draw_chars (name,char_value) VALUES (?1,?2);", bc.name, bc.char_value);
    }
    std.debug.print("  Box draw chars: {d} rows\n", .{box_chars.len});

    // ── Invertible chars ─────────────────────────────────────────
    const inv_chars = @import("data/invertible_chars.zig").invertible_chars;
    for (inv_chars) |ic| {
        insertText2(d, "INSERT INTO invertible_chars (original,inverted) VALUES (?1,?2);", ic.original, ic.inverted);
    }
    std.debug.print("  Invertible chars: {d} rows\n", .{inv_chars.len});

    // ── Latin diacritics ─────────────────────────────────────────
    const lat_diacs = @import("data/diacritics_latin.zig").diacritics_latin;
    for (lat_diacs) |ld| {
        insertText3(d, "INSERT INTO diacritics_latin (diacritized,base_char,description) VALUES (?1,?2,?3);", ld.diacritized, ld.base_char, ld.description);
    }
    std.debug.print("  Latin diacritics: {d} rows\n", .{lat_diacs.len});

    // ── Arabic diacritics ────────────────────────────────────────
    const ar_diacs = @import("data/diacritics_arabic.zig").diacritics_arabic;
    for (ar_diacs) |ad| {
        var stmt: ?*c.sqlite3_stmt = null;
        if (c.sqlite3_prepare_v2(d, "INSERT INTO diacritics_arabic (unicode,without,description) VALUES (?1,?2,?3);", -1, &stmt, null) == c.SQLITE_OK) {
            _ = c.sqlite3_bind_int(stmt, 1, ad.unicode);
            _ = c.sqlite3_bind_int(stmt, 2, ad.without);
            _ = c.sqlite3_bind_text(stmt, 3, ad.description.ptr, @intCast(ad.description.len), c.SQLITE_TRANSIENT);
            _ = c.sqlite3_step(stmt);
            _ = c.sqlite3_finalize(stmt);
        }
    }
    std.debug.print("  Arabic diacritics: {d} rows\n", .{ar_diacs.len});

    // ── Roman numbers ────────────────────────────────────────────
    const romans = @import("data/roman_numbers.zig").roman_numbers;
    for (romans) |r| {
        insertText1Int1(d, "INSERT INTO roman_numbers (symbol,value) VALUES (?1,?2);", r.symbol, r.value);
    }
    std.debug.print("  Roman numbers: {d} rows\n", .{romans.len});

    // ── Mandarin numbers ─────────────────────────────────────────
    const mandarins = @import("data/mandarin_numbers.zig").mandarin_numbers;
    for (mandarins) |m| {
        insertText1Int1(d, "INSERT INTO mandarin_numbers (symbol,value) VALUES (?1,?2);", m.symbol, m.value);
    }
    std.debug.print("  Mandarin numbers: {d} rows\n", .{mandarins.len});

    // ── Fraction numbers ─────────────────────────────────────────
    const fractions = @import("data/fraction_numbers.zig").fraction_numbers;
    for (fractions) |f| {
        insertText1Int1(d, "INSERT INTO fraction_numbers (fraction,unicode) VALUES (?1,?2);", f.fraction, f.unicode);
    }
    std.debug.print("  Fraction numbers: {d} rows\n", .{fractions.len});

    // ── Invisible chars ──────────────────────────────────────────
    const invisibles = @import("data/invisible_chars.zig").invisible_chars;
    for (invisibles) |iv| {
        insertInt1(d, "INSERT OR REPLACE INTO invisible_chars (unicode) VALUES (?1);", iv);
    }
    std.debug.print("  Invisible chars: {d} rows\n", .{invisibles.len});

    // ── Word separators ──────────────────────────────────────────
    const word_seps = @import("data/separators.zig").word_separators;
    for (word_seps) |ws| {
        insertText1(d, "INSERT INTO word_separators (char_value) VALUES (?1);", ws);
    }
    std.debug.print("  Word separators: {d} rows\n", .{word_seps.len});

    // ── Sentence separators ──────────────────────────────────────
    const sent_seps = @import("data/separators.zig").sentence_separators;
    for (sent_seps) |ss| {
        insertText1(d, "INSERT INTO sentence_separators (char_value) VALUES (?1);", ss);
    }
    std.debug.print("  Sentence separators: {d} rows\n", .{sent_seps.len});

    // ── System commands ──────────────────────────────────────────
    const sys_cmds = @import("data/system_commands.zig").system_commands;
    for (sys_cmds) |sc| {
        insertSysCmd(d, sc.name, sc.windows_cmd, sc.unix_cmd, sc.description, sc.return_type);
    }
    std.debug.print("  System commands: {d} rows\n", .{sys_cmds.len});

    execSql(d, "COMMIT;");
    execSql(d, "PRAGMA wal_checkpoint(TRUNCATE);");
    execSql(d, "PRAGMA journal_mode=DELETE;");

    std.debug.print("Reference data populated into {s}\n", .{db_path});
}
