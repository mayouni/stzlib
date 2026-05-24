const std = @import("std");
const c = @cImport({
    @cInclude("sqlite3.h");
});

// Each Ring class gets its own .db file so programs carry only what they need.
//   chardata.db  → stzCharData   (scripts, directions, categories, diacritics, numbers, separators, ...)
//   regex.db     → stzRegexData  (named regex patterns)
//   words.db     → stzRandomData (trilingual words)
//   boxdraw.db   → stzBoxDrawCharsData (box-drawing Unicode chars)
//   syscmd.db    → stzSystemCallData   (platform system commands)

const chardata_schema =
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
;

const regex_schema =
    \\CREATE TABLE IF NOT EXISTS regex_patterns (
    \\  name    TEXT PRIMARY KEY,
    \\  pattern TEXT NOT NULL
    \\);
;

const words_schema =
    \\CREATE TABLE IF NOT EXISTS words (
    \\  english TEXT NOT NULL,
    \\  french  TEXT NOT NULL,
    \\  arabic  TEXT NOT NULL
    \\);
;

const boxdraw_schema =
    \\CREATE TABLE IF NOT EXISTS box_draw_chars (
    \\  name       TEXT PRIMARY KEY,
    \\  char_value TEXT NOT NULL
    \\);
;

const syscmd_schema =
    \\CREATE TABLE IF NOT EXISTS system_commands (
    \\  name         TEXT PRIMARY KEY,
    \\  windows_cmd  TEXT NOT NULL DEFAULT '',
    \\  unix_cmd     TEXT NOT NULL DEFAULT '',
    \\  description  TEXT NOT NULL DEFAULT '',
    \\  return_type  TEXT NOT NULL DEFAULT 'string'
    \\);
;

const i18n_schema =
    \\CREATE TABLE IF NOT EXISTS countries (
    \\  id               INTEGER PRIMARY KEY,
    \\  name             TEXT NOT NULL,
    \\  alpha2           TEXT NOT NULL,
    \\  alpha3           TEXT NOT NULL,
    \\  phone_code       TEXT NOT NULL,
    \\  default_language TEXT NOT NULL,
    \\  currency         TEXT NOT NULL,
    \\  fractional_unit  TEXT NOT NULL,
    \\  currency_base    INTEGER NOT NULL DEFAULT 100
    \\);
    \\CREATE INDEX IF NOT EXISTS idx_country_name ON countries(name);
    \\CREATE INDEX IF NOT EXISTS idx_country_alpha2 ON countries(alpha2);
    \\CREATE INDEX IF NOT EXISTS idx_country_alpha3 ON countries(alpha3);
    \\CREATE TABLE IF NOT EXISTS languages (
    \\  id               INTEGER PRIMARY KEY,
    \\  name             TEXT NOT NULL,
    \\  short_abbr       TEXT NOT NULL,
    \\  long_abbr        TEXT NOT NULL,
    \\  default_country  TEXT NOT NULL DEFAULT '',
    \\  native_name      TEXT NOT NULL DEFAULT ''
    \\);
    \\CREATE INDEX IF NOT EXISTS idx_lang_name ON languages(name);
    \\CREATE INDEX IF NOT EXISTS idx_lang_short ON languages(short_abbr);
    \\CREATE INDEX IF NOT EXISTS idx_lang_long ON languages(long_abbr);
;

fn execSql(db: *c.sqlite3, sql: [*:0]const u8) void {
    _ = c.sqlite3_exec(db, sql, null, null, null);
}

fn openOrCreate(path: [*:0]const u8) !*c.sqlite3 {
    var db: ?*c.sqlite3 = null;
    const rc = c.sqlite3_open(path, &db);
    if (rc != c.SQLITE_OK or db == null) return error.DbOpen;
    const d = db.?;
    execSql(d, "PRAGMA journal_mode=WAL;");
    execSql(d, "PRAGMA synchronous=NORMAL;");
    return d;
}

fn applySchema(db: *c.sqlite3, schema: [*:0]const u8) !void {
    var err_msg: [*c]u8 = null;
    const rc = c.sqlite3_exec(db, schema, null, null, &err_msg);
    if (rc != c.SQLITE_OK) {
        if (err_msg) |e| c.sqlite3_free(e);
        return error.Schema;
    }
}

fn finalize(db: *c.sqlite3) void {
    execSql(db, "COMMIT;");
    execSql(db, "PRAGMA wal_checkpoint(TRUNCATE);");
    execSql(db, "PRAGMA journal_mode=DELETE;");
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

fn insertSysCmd(db: *c.sqlite3, name: []const u8, win_cmd: []const u8, unix_cmd: []const u8, desc: []const u8, ret: []const u8) void {
    var stmt: ?*c.sqlite3_stmt = null;
    const sql = "INSERT INTO system_commands (name,windows_cmd,unix_cmd,description,return_type) VALUES (?1,?2,?3,?4,?5);";
    if (c.sqlite3_prepare_v2(db, sql, -1, &stmt, null) != c.SQLITE_OK) return;
    defer _ = c.sqlite3_finalize(stmt);
    _ = c.sqlite3_bind_text(stmt, 1, name.ptr, @intCast(name.len), c.SQLITE_TRANSIENT);
    _ = c.sqlite3_bind_text(stmt, 2, win_cmd.ptr, @intCast(win_cmd.len), c.SQLITE_TRANSIENT);
    _ = c.sqlite3_bind_text(stmt, 3, unix_cmd.ptr, @intCast(unix_cmd.len), c.SQLITE_TRANSIENT);
    _ = c.sqlite3_bind_text(stmt, 4, desc.ptr, @intCast(desc.len), c.SQLITE_TRANSIENT);
    _ = c.sqlite3_bind_text(stmt, 5, ret.ptr, @intCast(ret.len), c.SQLITE_TRANSIENT);
    _ = c.sqlite3_step(stmt);
}

pub fn main() !void {
    // ═══════════════════════════════════════════════════════════════
    // 1. chardata.db — scripts, directions, categories, diacritics,
    //    numbers, invisible chars, invertible chars, separators
    // ═══════════════════════════════════════════════════════════════
    {
        const d = try openOrCreate("data/chardata.db");
        defer _ = c.sqlite3_close(d);
        try applySchema(d, chardata_schema);
        execSql(d, "BEGIN TRANSACTION;");

        const scripts = @import("data/scripts.zig").scripts;
        for (scripts) |s| insertInt1Text1(d, "INSERT OR REPLACE INTO scripts (code,name) VALUES (?1,?2);", s.code, s.name);
        std.debug.print("  chardata.db: scripts={d}", .{scripts.len});

        const directions = @import("data/directions.zig").directions;
        for (directions) |dir| insertInt1Text3(d, "INSERT OR REPLACE INTO directions (nbr,short_name,stz_name,description) VALUES (?1,?2,?3,?4);", dir.nbr, dir.short_name, dir.stz_name, dir.description);
        std.debug.print(" directions={d}", .{directions.len});

        const categories = @import("data/categories.zig").categories;
        for (categories) |cat| insertInt1Text1(d, "INSERT OR REPLACE INTO categories (nbr,name) VALUES (?1,?2);", cat.nbr, cat.name);
        std.debug.print(" categories={d}", .{categories.len});

        const inv_chars = @import("data/invertible_chars.zig").invertible_chars;
        for (inv_chars) |ic| insertText2(d, "INSERT INTO invertible_chars (original,inverted) VALUES (?1,?2);", ic.original, ic.inverted);
        std.debug.print(" invertible={d}", .{inv_chars.len});

        const lat_diacs = @import("data/diacritics_latin.zig").diacritics_latin;
        for (lat_diacs) |ld| insertText3(d, "INSERT INTO diacritics_latin (diacritized,base_char,description) VALUES (?1,?2,?3);", ld.diacritized, ld.base_char, ld.description);
        std.debug.print(" latin_diac={d}", .{lat_diacs.len});

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
        std.debug.print(" arabic_diac={d}", .{ar_diacs.len});

        const romans = @import("data/roman_numbers.zig").roman_numbers;
        for (romans) |r| insertText1Int1(d, "INSERT INTO roman_numbers (symbol,value) VALUES (?1,?2);", r.symbol, r.value);

        const mandarins = @import("data/mandarin_numbers.zig").mandarin_numbers;
        for (mandarins) |m| insertText1Int1(d, "INSERT INTO mandarin_numbers (symbol,value) VALUES (?1,?2);", m.symbol, m.value);

        const fractions = @import("data/fraction_numbers.zig").fraction_numbers;
        for (fractions) |f| insertText1Int1(d, "INSERT INTO fraction_numbers (fraction,unicode) VALUES (?1,?2);", f.fraction, f.unicode);

        const invisibles = @import("data/invisible_chars.zig").invisible_chars;
        for (invisibles) |iv| insertInt1(d, "INSERT OR REPLACE INTO invisible_chars (unicode) VALUES (?1);", iv);

        const word_seps = @import("data/separators.zig").word_separators;
        for (word_seps) |ws| insertText1(d, "INSERT INTO word_separators (char_value) VALUES (?1);", ws);

        const sent_seps = @import("data/separators.zig").sentence_separators;
        for (sent_seps) |ss| insertText1(d, "INSERT INTO sentence_separators (char_value) VALUES (?1);", ss);

        finalize(d);
        std.debug.print("\n", .{});
    }

    // ═══════════════════════════════════════════════════════════════
    // 2. regex.db — named regex patterns
    // ═══════════════════════════════════════════════════════════════
    {
        const d = try openOrCreate("data/regex.db");
        defer _ = c.sqlite3_close(d);
        try applySchema(d, regex_schema);
        execSql(d, "BEGIN TRANSACTION;");

        const patterns = @import("data/regex_patterns.zig").patterns;
        for (patterns) |p| insertText2(d, "INSERT OR REPLACE INTO regex_patterns (name,pattern) VALUES (?1,?2);", p.name, p.pattern);
        std.debug.print("  regex.db: patterns={d}\n", .{patterns.len});

        finalize(d);
    }

    // ═══════════════════════════════════════════════════════════════
    // 3. words.db — trilingual words
    // ═══════════════════════════════════════════════════════════════
    {
        const d = try openOrCreate("data/words.db");
        defer _ = c.sqlite3_close(d);
        try applySchema(d, words_schema);
        execSql(d, "BEGIN TRANSACTION;");

        const words = @import("data/words.zig").words;
        for (words) |w| insertText3(d, "INSERT INTO words (english,french,arabic) VALUES (?1,?2,?3);", w.english, w.french, w.arabic);
        std.debug.print("  words.db: words={d}\n", .{words.len});

        finalize(d);
    }

    // ═══════════════════════════════════════════════════════════════
    // 4. boxdraw.db — box-drawing Unicode characters
    // ═══════════════════════════════════════════════════════════════
    {
        const d = try openOrCreate("data/boxdraw.db");
        defer _ = c.sqlite3_close(d);
        try applySchema(d, boxdraw_schema);
        execSql(d, "BEGIN TRANSACTION;");

        const box_chars = @import("data/box_draw_chars.zig").box_draw_chars;
        for (box_chars) |bc| insertText2(d, "INSERT OR REPLACE INTO box_draw_chars (name,char_value) VALUES (?1,?2);", bc.name, bc.char_value);
        std.debug.print("  boxdraw.db: chars={d}\n", .{box_chars.len});

        finalize(d);
    }

    // ═══════════════════════════════════════════════════════════════
    // 5. syscmd.db — platform system commands
    // ═══════════════════════════════════════════════════════════════
    {
        const d = try openOrCreate("data/syscmd.db");
        defer _ = c.sqlite3_close(d);
        try applySchema(d, syscmd_schema);
        execSql(d, "BEGIN TRANSACTION;");

        const sys_cmds = @import("data/system_commands.zig").system_commands;
        for (sys_cmds) |sc| insertSysCmd(d, sc.name, sc.windows_cmd, sc.unix_cmd, sc.description, sc.return_type);
        std.debug.print("  syscmd.db: commands={d}\n", .{sys_cmds.len});

        finalize(d);
    }

    // ═══════════════════════════════════════════════════════════════
    // 6. i18n.db — countries and languages
    // ═══════════════════════════════════════════════════════════════
    {
        const d = try openOrCreate("data/i18n.db");
        defer _ = c.sqlite3_close(d);
        try applySchema(d, i18n_schema);
        execSql(d, "BEGIN TRANSACTION;");

        const country_data = @import("data/countries.zig").countries;
        for (country_data) |co| {
            var stmt: ?*c.sqlite3_stmt = null;
            if (c.sqlite3_prepare_v2(d, "INSERT OR REPLACE INTO countries (id,name,alpha2,alpha3,phone_code,default_language,currency,fractional_unit,currency_base) VALUES (?1,?2,?3,?4,?5,?6,?7,?8,?9);", -1, &stmt, null) == c.SQLITE_OK) {
                _ = c.sqlite3_bind_int(stmt, 1, co.id);
                _ = c.sqlite3_bind_text(stmt, 2, co.name.ptr, @intCast(co.name.len), c.SQLITE_TRANSIENT);
                _ = c.sqlite3_bind_text(stmt, 3, co.alpha2.ptr, @intCast(co.alpha2.len), c.SQLITE_TRANSIENT);
                _ = c.sqlite3_bind_text(stmt, 4, co.alpha3.ptr, @intCast(co.alpha3.len), c.SQLITE_TRANSIENT);
                _ = c.sqlite3_bind_text(stmt, 5, co.phone_code.ptr, @intCast(co.phone_code.len), c.SQLITE_TRANSIENT);
                _ = c.sqlite3_bind_text(stmt, 6, co.default_language.ptr, @intCast(co.default_language.len), c.SQLITE_TRANSIENT);
                _ = c.sqlite3_bind_text(stmt, 7, co.currency.ptr, @intCast(co.currency.len), c.SQLITE_TRANSIENT);
                _ = c.sqlite3_bind_text(stmt, 8, co.fractional_unit.ptr, @intCast(co.fractional_unit.len), c.SQLITE_TRANSIENT);
                _ = c.sqlite3_bind_int(stmt, 9, co.currency_base);
                _ = c.sqlite3_step(stmt);
                _ = c.sqlite3_finalize(stmt);
            }
        }
        std.debug.print("  i18n.db: countries={d}", .{country_data.len});

        const lang_data = @import("data/languages.zig").languages;
        for (lang_data) |la| {
            var stmt: ?*c.sqlite3_stmt = null;
            if (c.sqlite3_prepare_v2(d, "INSERT OR REPLACE INTO languages (id,name,short_abbr,long_abbr,default_country,native_name) VALUES (?1,?2,?3,?4,?5,?6);", -1, &stmt, null) == c.SQLITE_OK) {
                _ = c.sqlite3_bind_int(stmt, 1, la.id);
                _ = c.sqlite3_bind_text(stmt, 2, la.name.ptr, @intCast(la.name.len), c.SQLITE_TRANSIENT);
                _ = c.sqlite3_bind_text(stmt, 3, la.short_abbr.ptr, @intCast(la.short_abbr.len), c.SQLITE_TRANSIENT);
                _ = c.sqlite3_bind_text(stmt, 4, la.long_abbr.ptr, @intCast(la.long_abbr.len), c.SQLITE_TRANSIENT);
                _ = c.sqlite3_bind_text(stmt, 5, la.default_country.ptr, @intCast(la.default_country.len), c.SQLITE_TRANSIENT);
                _ = c.sqlite3_bind_text(stmt, 6, la.native_name.ptr, @intCast(la.native_name.len), c.SQLITE_TRANSIENT);
                _ = c.sqlite3_step(stmt);
                _ = c.sqlite3_finalize(stmt);
            }
        }
        std.debug.print(" languages={d}\n", .{lang_data.len});

        finalize(d);
    }

    std.debug.print("Done: 6 databases generated in data/\n", .{});
}
