const std = @import("std");
const builtin = @import("builtin");
const c = @cImport({
    @cInclude("sqlite3.h");
});

// Per-class SQLite databases, lazily opened on first query.
// Each DB is in the data/ directory alongside the DLL.
//   chardata.db  — scripts, directions, categories, diacritics, numbers, ...
//   regex.db     — named regex patterns
//   words.db     — trilingual words
//   boxdraw.db   — box-drawing Unicode characters
//   syscmd.db    — platform system commands

// ── Path discovery (shared with unicode_data.zig) ───────────────

const win = struct {
    extern "kernel32" fn GetModuleHandleA(lpModuleName: ?[*:0]const u8) callconv(.winapi) ?*anyopaque;
    extern "kernel32" fn GetModuleFileNameA(hModule: ?*anyopaque, lpFilename: [*]u8, nSize: u32) callconv(.winapi) u32;
};

fn findDataDir(out: *[1024]u8) ?[]u8 {
    if (comptime builtin.os.tag == .windows) {
        const hMod = win.GetModuleHandleA("stz_unidata");
        var dll_path: [1024]u8 = undefined;
        const len = win.GetModuleFileNameA(hMod, &dll_path, dll_path.len);
        if (len == 0 or len >= dll_path.len) return null;
        var last_sep: usize = 0;
        for (dll_path[0..len], 0..) |ch, i| {
            if (ch == '\\' or ch == '/') last_sep = i;
        }
        if (last_sep == 0) return null;
        var ups: u8 = 0;
        var pos = last_sep;
        while (pos > 0 and ups < 2) {
            pos -= 1;
            if (dll_path[pos] == '\\' or dll_path[pos] == '/') ups += 1;
        }
        if (ups < 2) return null;
        const base = dll_path[0 .. pos + 1];
        const suffix = "data/";
        if (base.len + suffix.len >= out.len) return null;
        @memcpy(out[0..base.len], base);
        @memcpy(out[base.len .. base.len + suffix.len], suffix);
        return out[0 .. base.len + suffix.len];
    } else {
        const fallback = "data/";
        @memcpy(out[0..fallback.len], fallback);
        return out[0..fallback.len];
    }
}

fn openDbByName(name: []const u8) ?*c.sqlite3 {
    var dir_buf: [1024]u8 = undefined;
    const dir = findDataDir(&dir_buf) orelse return null;
    if (dir.len + name.len >= dir_buf.len) return null;
    @memcpy(dir_buf[dir.len .. dir.len + name.len], name);
    dir_buf[dir.len + name.len] = 0;
    var db: ?*c.sqlite3 = null;
    const rc = c.sqlite3_open_v2(
        @ptrCast(dir_buf[0 .. dir.len + name.len :0]),
        &db,
        c.SQLITE_OPEN_READONLY,
        null,
    );
    if (rc != c.SQLITE_OK or db == null) return null;
    return db.?;
}

// ── Per-domain singletons ───────────────────────────────────────

var g_chardata: ?*c.sqlite3 = null;
var g_regex: ?*c.sqlite3 = null;
var g_words: ?*c.sqlite3 = null;
var g_boxdraw: ?*c.sqlite3 = null;
var g_syscmd: ?*c.sqlite3 = null;
var g_i18n: ?*c.sqlite3 = null;

fn getChardata() ?*c.sqlite3 {
    if (g_chardata == null) g_chardata = openDbByName("chardata.db");
    return g_chardata;
}
fn getRegex() ?*c.sqlite3 {
    if (g_regex == null) g_regex = openDbByName("regex.db");
    return g_regex;
}
fn getWords() ?*c.sqlite3 {
    if (g_words == null) g_words = openDbByName("words.db");
    return g_words;
}
fn getBoxdraw() ?*c.sqlite3 {
    if (g_boxdraw == null) g_boxdraw = openDbByName("boxdraw.db");
    return g_boxdraw;
}
fn getSyscmd() ?*c.sqlite3 {
    if (g_syscmd == null) g_syscmd = openDbByName("syscmd.db");
    return g_syscmd;
}
fn getI18n() ?*c.sqlite3 {
    if (g_i18n == null) g_i18n = openDbByName("i18n.db");
    return g_i18n;
}

// Test support
pub fn setTestDbs(chardata: ?*c.sqlite3, regex: ?*c.sqlite3, words_db: ?*c.sqlite3, boxdraw: ?*c.sqlite3, syscmd: ?*c.sqlite3) void {
    g_chardata = chardata;
    g_regex = regex;
    g_words = words_db;
    g_boxdraw = boxdraw;
    g_syscmd = syscmd;
}
pub fn setTestI18n(i18n: ?*c.sqlite3) void {
    g_i18n = i18n;
}

// ── Generic helpers ─────────────────────────────────────────────

fn queryCount(db: ?*c.sqlite3, sql: [*:0]const u8) i32 {
    const d = db orelse return 0;
    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(d, sql, -1, &stmt, null) != c.SQLITE_OK) return 0;
    defer _ = c.sqlite3_finalize(stmt);
    if (c.sqlite3_step(stmt) == c.SQLITE_ROW) return c.sqlite3_column_int(stmt, 0);
    return 0;
}

fn queryTextByInt(db: ?*c.sqlite3, sql: [*:0]const u8, key: i32, out: [*]u8, max: i32) i32 {
    const d = db orelse return 0;
    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(d, sql, -1, &stmt, null) != c.SQLITE_OK) return 0;
    defer _ = c.sqlite3_finalize(stmt);
    _ = c.sqlite3_bind_int(stmt, 1, key);
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

fn queryTextByText(db: ?*c.sqlite3, sql: [*:0]const u8, key_ptr: [*]const u8, key_len: i32, out: [*]u8, max: i32) i32 {
    const d = db orelse return 0;
    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(d, sql, -1, &stmt, null) != c.SQLITE_OK) return 0;
    defer _ = c.sqlite3_finalize(stmt);
    _ = c.sqlite3_bind_text(stmt, 1, key_ptr, key_len, c.SQLITE_TRANSIENT);
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

// ── chardata.db queries ─────────────────────────────────────────

pub fn scriptCount() i32 { return queryCount(getChardata(), "SELECT COUNT(*) FROM scripts"); }
pub fn scriptName(code: i32, out: [*]u8, max: i32) i32 { return queryTextByInt(getChardata(), "SELECT name FROM scripts WHERE code=?1", code, out, max); }
pub fn directionCount() i32 { return queryCount(getChardata(), "SELECT COUNT(*) FROM directions"); }
pub fn directionName(nbr: i32, out: [*]u8, max: i32) i32 { return queryTextByInt(getChardata(), "SELECT stz_name FROM directions WHERE nbr=?1", nbr, out, max); }
pub fn categoryCount() i32 { return queryCount(getChardata(), "SELECT COUNT(*) FROM categories"); }
pub fn categoryName(nbr: i32, out: [*]u8, max: i32) i32 { return queryTextByInt(getChardata(), "SELECT name FROM categories WHERE nbr=?1", nbr, out, max); }
pub fn invertibleCharCount() i32 { return queryCount(getChardata(), "SELECT COUNT(*) FROM invertible_chars"); }
pub fn invertedOf(char_ptr: [*]const u8, char_len: i32, out: [*]u8, max: i32) i32 { return queryTextByText(getChardata(), "SELECT inverted FROM invertible_chars WHERE original=?1", char_ptr, char_len, out, max); }
pub fn latinDiacriticCount() i32 { return queryCount(getChardata(), "SELECT COUNT(*) FROM diacritics_latin"); }
pub fn latinDiacriticBase(diac_ptr: [*]const u8, diac_len: i32, out: [*]u8, max: i32) i32 { return queryTextByText(getChardata(), "SELECT base_char FROM diacritics_latin WHERE diacritized=?1", diac_ptr, diac_len, out, max); }

// ── regex.db queries ────────────────────────────────────────────

pub fn regexPatternCount() i32 { return queryCount(getRegex(), "SELECT COUNT(*) FROM regex_patterns"); }
pub fn regexPattern(name_ptr: [*]const u8, name_len: i32, out: [*]u8, max: i32) i32 { return queryTextByText(getRegex(), "SELECT pattern FROM regex_patterns WHERE name=?1", name_ptr, name_len, out, max); }

// ── words.db queries ────────────────────────────────────────────

pub fn wordCount() i32 { return queryCount(getWords(), "SELECT COUNT(*) FROM words"); }

pub fn wordAt(idx: i32, lang: i32, out: [*]u8, max: i32) i32 {
    const db = getWords() orelse return 0;
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

// ── boxdraw.db queries ──────────────────────────────────────────

pub fn boxDrawCharCount() i32 { return queryCount(getBoxdraw(), "SELECT COUNT(*) FROM box_draw_chars"); }
pub fn boxDrawChar(name_ptr: [*]const u8, name_len: i32, out: [*]u8, max: i32) i32 { return queryTextByText(getBoxdraw(), "SELECT char_value FROM box_draw_chars WHERE name=?1", name_ptr, name_len, out, max); }

// ── syscmd.db queries ───────────────────────────────────────────

pub fn systemCommandCount() i32 { return queryCount(getSyscmd(), "SELECT COUNT(*) FROM system_commands"); }

pub fn systemCommand(name_ptr: [*]const u8, name_len: i32, platform: i32, out: [*]u8, max: i32) i32 {
    const db = getSyscmd() orelse return 0;
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

// ── i18n.db queries ────────────────────────────────────────

pub fn countryCount() i32 { return queryCount(getI18n(), "SELECT COUNT(*) FROM countries"); }
pub fn languageCount() i32 { return queryCount(getI18n(), "SELECT COUNT(*) FROM languages"); }

pub fn countryNameById(id: i32, out: [*]u8, max: i32) i32 {
    return queryTextByInt(getI18n(), "SELECT name FROM countries WHERE id=?1", id, out, max);
}

pub fn countryByName(name_ptr: [*]const u8, name_len: i32, col: [*:0]const u8, out: [*]u8, max: i32) i32 {
    const db = getI18n() orelse return 0;
    var sql_buf: [128]u8 = undefined;
    const sql = std.fmt.bufPrint(&sql_buf, "SELECT {s} FROM countries WHERE name=?1 COLLATE NOCASE", .{col}) catch return 0;
    sql_buf[sql.len] = 0;
    return queryTextByTextCustom(db, @ptrCast(sql_buf[0..sql.len :0]), name_ptr, name_len, out, max);
}

pub fn countryByAlpha2(code_ptr: [*]const u8, code_len: i32, col: [*:0]const u8, out: [*]u8, max: i32) i32 {
    const db = getI18n() orelse return 0;
    var sql_buf: [128]u8 = undefined;
    const sql = std.fmt.bufPrint(&sql_buf, "SELECT {s} FROM countries WHERE alpha2=?1 COLLATE NOCASE", .{col}) catch return 0;
    sql_buf[sql.len] = 0;
    return queryTextByTextCustom(db, @ptrCast(sql_buf[0..sql.len :0]), code_ptr, code_len, out, max);
}

pub fn languageByName(name_ptr: [*]const u8, name_len: i32, col: [*:0]const u8, out: [*]u8, max: i32) i32 {
    const db = getI18n() orelse return 0;
    var sql_buf: [128]u8 = undefined;
    const sql = std.fmt.bufPrint(&sql_buf, "SELECT {s} FROM languages WHERE name=?1 COLLATE NOCASE", .{col}) catch return 0;
    sql_buf[sql.len] = 0;
    return queryTextByTextCustom(db, @ptrCast(sql_buf[0..sql.len :0]), name_ptr, name_len, out, max);
}

pub fn languageByShortAbbr(abbr_ptr: [*]const u8, abbr_len: i32, col: [*:0]const u8, out: [*]u8, max: i32) i32 {
    const db = getI18n() orelse return 0;
    var sql_buf: [128]u8 = undefined;
    const sql = std.fmt.bufPrint(&sql_buf, "SELECT {s} FROM languages WHERE short_abbr=?1 COLLATE NOCASE", .{col}) catch return 0;
    sql_buf[sql.len] = 0;
    return queryTextByTextCustom(db, @ptrCast(sql_buf[0..sql.len :0]), abbr_ptr, abbr_len, out, max);
}

fn queryTextByTextCustom(db: *c.sqlite3, sql: [*:0]const u8, key_ptr: [*]const u8, key_len: i32, out: [*]u8, max: i32) i32 {
    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(db, sql, -1, &stmt, null) != c.SQLITE_OK) return 0;
    defer _ = c.sqlite3_finalize(stmt);
    _ = c.sqlite3_bind_text(stmt, 1, key_ptr, key_len, c.SQLITE_TRANSIENT);
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

pub fn countryIntByName(name_ptr: [*]const u8, name_len: i32, col: [*:0]const u8) i32 {
    const db = getI18n() orelse return 0;
    var sql_buf: [128]u8 = undefined;
    const sql = std.fmt.bufPrint(&sql_buf, "SELECT {s} FROM countries WHERE name=?1 COLLATE NOCASE", .{col}) catch return 0;
    sql_buf[sql.len] = 0;
    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(db, @ptrCast(sql_buf[0..sql.len :0]), -1, &stmt, null) != c.SQLITE_OK) return 0;
    defer _ = c.sqlite3_finalize(stmt);
    _ = c.sqlite3_bind_text(stmt, 1, name_ptr, name_len, c.SQLITE_TRANSIENT);
    if (c.sqlite3_step(stmt) == c.SQLITE_ROW) return c.sqlite3_column_int(stmt, 0);
    return 0;
}

// ── C ABI exports ───────────────────────────────────────────────

pub export fn stz_refdata_script_count() callconv(.c) i32 { return scriptCount(); }
pub export fn stz_refdata_script_name(code: i32, out: [*]u8, max: i32) callconv(.c) i32 { return scriptName(code, out, max); }
pub export fn stz_refdata_direction_count() callconv(.c) i32 { return directionCount(); }
pub export fn stz_refdata_direction_name(nbr: i32, out: [*]u8, max: i32) callconv(.c) i32 { return directionName(nbr, out, max); }
pub export fn stz_refdata_category_count() callconv(.c) i32 { return categoryCount(); }
pub export fn stz_refdata_category_name(nbr: i32, out: [*]u8, max: i32) callconv(.c) i32 { return categoryName(nbr, out, max); }
pub export fn stz_refdata_regex_count() callconv(.c) i32 { return regexPatternCount(); }
pub export fn stz_refdata_regex_pattern(name_ptr: [*]const u8, name_len: i32, out: [*]u8, max: i32) callconv(.c) i32 { return regexPattern(name_ptr, name_len, out, max); }
pub export fn stz_refdata_word_count() callconv(.c) i32 { return wordCount(); }
pub export fn stz_refdata_word_at(idx: i32, lang: i32, out: [*]u8, max: i32) callconv(.c) i32 { return wordAt(idx, lang, out, max); }
pub export fn stz_refdata_box_draw_count() callconv(.c) i32 { return boxDrawCharCount(); }
pub export fn stz_refdata_box_draw_char(name_ptr: [*]const u8, name_len: i32, out: [*]u8, max: i32) callconv(.c) i32 { return boxDrawChar(name_ptr, name_len, out, max); }
pub export fn stz_refdata_invertible_count() callconv(.c) i32 { return invertibleCharCount(); }
pub export fn stz_refdata_inverted_of(char_ptr: [*]const u8, char_len: i32, out: [*]u8, max: i32) callconv(.c) i32 { return invertedOf(char_ptr, char_len, out, max); }
pub export fn stz_refdata_latin_diacritic_count() callconv(.c) i32 { return latinDiacriticCount(); }
pub export fn stz_refdata_latin_diacritic_base(diac_ptr: [*]const u8, diac_len: i32, out: [*]u8, max: i32) callconv(.c) i32 { return latinDiacriticBase(diac_ptr, diac_len, out, max); }
pub export fn stz_refdata_syscmd_count() callconv(.c) i32 { return systemCommandCount(); }
pub export fn stz_refdata_syscmd(name_ptr: [*]const u8, name_len: i32, platform: i32, out: [*]u8, max: i32) callconv(.c) i32 { return systemCommand(name_ptr, name_len, platform, out, max); }

pub export fn stz_refdata_country_count() callconv(.c) i32 { return countryCount(); }
pub export fn stz_refdata_language_count() callconv(.c) i32 { return languageCount(); }
pub export fn stz_refdata_country_name(id: i32, out: [*]u8, max: i32) callconv(.c) i32 { return countryNameById(id, out, max); }
pub export fn stz_refdata_country_field(name_ptr: [*]const u8, name_len: i32, col: [*:0]const u8, out: [*]u8, max: i32) callconv(.c) i32 { return countryByName(name_ptr, name_len, col, out, max); }
pub export fn stz_refdata_country_field_by_alpha2(code_ptr: [*]const u8, code_len: i32, col: [*:0]const u8, out: [*]u8, max: i32) callconv(.c) i32 { return countryByAlpha2(code_ptr, code_len, col, out, max); }
pub export fn stz_refdata_country_int_field(name_ptr: [*]const u8, name_len: i32, col: [*:0]const u8) callconv(.c) i32 { return countryIntByName(name_ptr, name_len, col); }
pub export fn stz_refdata_language_field(name_ptr: [*]const u8, name_len: i32, col: [*:0]const u8, out: [*]u8, max: i32) callconv(.c) i32 { return languageByName(name_ptr, name_len, col, out, max); }
pub export fn stz_refdata_language_field_by_abbr(abbr_ptr: [*]const u8, abbr_len: i32, col: [*:0]const u8, out: [*]u8, max: i32) callconv(.c) i32 { return languageByShortAbbr(abbr_ptr, abbr_len, col, out, max); }

// ── Tests ───────────────────────────────────────────────────────

fn openTestDbFile(name: [*:0]const u8) ?*c.sqlite3 {
    var db: ?*c.sqlite3 = null;
    if (c.sqlite3_open_v2(name, &db, c.SQLITE_OPEN_READONLY, null) != c.SQLITE_OK) return null;
    return db.?;
}

fn setupTestDbs() struct { cd: ?*c.sqlite3, rx: ?*c.sqlite3, wd: ?*c.sqlite3, bd: ?*c.sqlite3, sc: ?*c.sqlite3 } {
    return .{
        .cd = openTestDbFile("data/chardata.db"),
        .rx = openTestDbFile("data/regex.db"),
        .wd = openTestDbFile("data/words.db"),
        .bd = openTestDbFile("data/boxdraw.db"),
        .sc = openTestDbFile("data/syscmd.db"),
    };
}

fn teardownTestDbs(dbs: anytype, saved: [5]?*c.sqlite3) void {
    if (dbs.cd) |d| _ = c.sqlite3_close(d);
    if (dbs.rx) |d| _ = c.sqlite3_close(d);
    if (dbs.wd) |d| _ = c.sqlite3_close(d);
    if (dbs.bd) |d| _ = c.sqlite3_close(d);
    if (dbs.sc) |d| _ = c.sqlite3_close(d);
    g_chardata = saved[0];
    g_regex = saved[1];
    g_words = saved[2];
    g_boxdraw = saved[3];
    g_syscmd = saved[4];
}

test "ref_data: script count > 0" {
    const saved = [5]?*c.sqlite3{ g_chardata, g_regex, g_words, g_boxdraw, g_syscmd };
    const dbs = setupTestDbs();
    if (dbs.cd == null) return;
    setTestDbs(dbs.cd, dbs.rx, dbs.wd, dbs.bd, dbs.sc);
    defer teardownTestDbs(dbs, saved);
    try std.testing.expect(scriptCount() >= 156);
}

test "ref_data: direction count = 19" {
    const saved = [5]?*c.sqlite3{ g_chardata, g_regex, g_words, g_boxdraw, g_syscmd };
    const dbs = setupTestDbs();
    if (dbs.cd == null) return;
    setTestDbs(dbs.cd, dbs.rx, dbs.wd, dbs.bd, dbs.sc);
    defer teardownTestDbs(dbs, saved);
    try std.testing.expect(directionCount() == 19);
}

test "ref_data: category count = 30" {
    const saved = [5]?*c.sqlite3{ g_chardata, g_regex, g_words, g_boxdraw, g_syscmd };
    const dbs = setupTestDbs();
    if (dbs.cd == null) return;
    setTestDbs(dbs.cd, dbs.rx, dbs.wd, dbs.bd, dbs.sc);
    defer teardownTestDbs(dbs, saved);
    try std.testing.expect(categoryCount() == 30);
}

test "ref_data: regex pattern count > 300" {
    const saved = [5]?*c.sqlite3{ g_chardata, g_regex, g_words, g_boxdraw, g_syscmd };
    const dbs = setupTestDbs();
    if (dbs.rx == null) return;
    setTestDbs(dbs.cd, dbs.rx, dbs.wd, dbs.bd, dbs.sc);
    defer teardownTestDbs(dbs, saved);
    try std.testing.expect(regexPatternCount() >= 300);
}

test "ref_data: word count >= 100" {
    const saved = [5]?*c.sqlite3{ g_chardata, g_regex, g_words, g_boxdraw, g_syscmd };
    const dbs = setupTestDbs();
    if (dbs.wd == null) return;
    setTestDbs(dbs.cd, dbs.rx, dbs.wd, dbs.bd, dbs.sc);
    defer teardownTestDbs(dbs, saved);
    try std.testing.expect(wordCount() >= 100);
}

test "ref_data: box draw char count > 80" {
    const saved = [5]?*c.sqlite3{ g_chardata, g_regex, g_words, g_boxdraw, g_syscmd };
    const dbs = setupTestDbs();
    if (dbs.bd == null) return;
    setTestDbs(dbs.cd, dbs.rx, dbs.wd, dbs.bd, dbs.sc);
    defer teardownTestDbs(dbs, saved);
    try std.testing.expect(boxDrawCharCount() >= 80);
}

test "ref_data: invertible char count > 50" {
    const saved = [5]?*c.sqlite3{ g_chardata, g_regex, g_words, g_boxdraw, g_syscmd };
    const dbs = setupTestDbs();
    if (dbs.cd == null) return;
    setTestDbs(dbs.cd, dbs.rx, dbs.wd, dbs.bd, dbs.sc);
    defer teardownTestDbs(dbs, saved);
    try std.testing.expect(invertibleCharCount() >= 50);
}

test "ref_data: latin diacritic count > 190" {
    const saved = [5]?*c.sqlite3{ g_chardata, g_regex, g_words, g_boxdraw, g_syscmd };
    const dbs = setupTestDbs();
    if (dbs.cd == null) return;
    setTestDbs(dbs.cd, dbs.rx, dbs.wd, dbs.bd, dbs.sc);
    defer teardownTestDbs(dbs, saved);
    try std.testing.expect(latinDiacriticCount() >= 190);
}

test "ref_data: system command count > 10" {
    const saved = [5]?*c.sqlite3{ g_chardata, g_regex, g_words, g_boxdraw, g_syscmd };
    const dbs = setupTestDbs();
    if (dbs.sc == null) return;
    setTestDbs(dbs.cd, dbs.rx, dbs.wd, dbs.bd, dbs.sc);
    defer teardownTestDbs(dbs, saved);
    try std.testing.expect(systemCommandCount() >= 10);
}

test "ref_data: lookup script name for Latin (code=3)" {
    const saved = [5]?*c.sqlite3{ g_chardata, g_regex, g_words, g_boxdraw, g_syscmd };
    const dbs = setupTestDbs();
    if (dbs.cd == null) return;
    setTestDbs(dbs.cd, dbs.rx, dbs.wd, dbs.bd, dbs.sc);
    defer teardownTestDbs(dbs, saved);
    var buf: [256]u8 = undefined;
    const len = scriptName(3, &buf, 256);
    try std.testing.expect(len > 0);
    try std.testing.expectEqualStrings("Latin", buf[0..@intCast(len)]);
}

test "ref_data: lookup regex pattern 'email'" {
    const saved = [5]?*c.sqlite3{ g_chardata, g_regex, g_words, g_boxdraw, g_syscmd };
    const dbs = setupTestDbs();
    if (dbs.rx == null) return;
    setTestDbs(dbs.cd, dbs.rx, dbs.wd, dbs.bd, dbs.sc);
    defer teardownTestDbs(dbs, saved);
    var buf: [1024]u8 = undefined;
    const name = "email";
    const len = regexPattern(name.ptr, @intCast(name.len), &buf, 1024);
    try std.testing.expect(len > 0);
}

test "ref_data: lookup word at index 1 (english=apple)" {
    const saved = [5]?*c.sqlite3{ g_chardata, g_regex, g_words, g_boxdraw, g_syscmd };
    const dbs = setupTestDbs();
    if (dbs.wd == null) return;
    setTestDbs(dbs.cd, dbs.rx, dbs.wd, dbs.bd, dbs.sc);
    defer teardownTestDbs(dbs, saved);
    var buf: [256]u8 = undefined;
    const len = wordAt(1, 0, &buf, 256);
    try std.testing.expect(len > 0);
    try std.testing.expectEqualStrings("apple", buf[0..@intCast(len)]);
}

test "ref_data: lookup box draw char LightH" {
    const saved = [5]?*c.sqlite3{ g_chardata, g_regex, g_words, g_boxdraw, g_syscmd };
    const dbs = setupTestDbs();
    if (dbs.bd == null) return;
    setTestDbs(dbs.cd, dbs.rx, dbs.wd, dbs.bd, dbs.sc);
    defer teardownTestDbs(dbs, saved);
    var buf: [64]u8 = undefined;
    const name = "LightH";
    const len = boxDrawChar(name.ptr, @intCast(name.len), &buf, 64);
    try std.testing.expect(len > 0);
}

test "ref_data: country count >= 250" {
    const saved_i18n = g_i18n;
    const db = openTestDbFile("data/i18n.db");
    if (db == null) return;
    g_i18n = db;
    defer {
        if (db) |d| _ = c.sqlite3_close(d);
        g_i18n = saved_i18n;
    }
    try std.testing.expect(countryCount() >= 250);
}

test "ref_data: language count >= 200" {
    const saved_i18n = g_i18n;
    const db = openTestDbFile("data/i18n.db");
    if (db == null) return;
    g_i18n = db;
    defer {
        if (db) |d| _ = c.sqlite3_close(d);
        g_i18n = saved_i18n;
    }
    try std.testing.expect(languageCount() >= 200);
}

test "ref_data: lookup country France by name" {
    const saved_i18n = g_i18n;
    const db = openTestDbFile("data/i18n.db");
    if (db == null) return;
    g_i18n = db;
    defer {
        if (db) |d| _ = c.sqlite3_close(d);
        g_i18n = saved_i18n;
    }
    var buf: [64]u8 = undefined;
    const name = "France";
    const len = countryByName(name.ptr, @intCast(name.len), "alpha2", &buf, 64);
    try std.testing.expect(len == 2);
    try std.testing.expect(std.mem.eql(u8, buf[0..2], "FR"));
}

test "ref_data: lookup language english by name" {
    const saved_i18n = g_i18n;
    const db = openTestDbFile("data/i18n.db");
    if (db == null) return;
    g_i18n = db;
    defer {
        if (db) |d| _ = c.sqlite3_close(d);
        g_i18n = saved_i18n;
    }
    var buf: [64]u8 = undefined;
    const name = "english";
    const len = languageByName(name.ptr, @intCast(name.len), "short_abbr", &buf, 64);
    try std.testing.expect(len == 2);
    try std.testing.expect(std.mem.eql(u8, buf[0..2], "en"));
}

test "ref_data: country currency by alpha2 US" {
    const saved_i18n = g_i18n;
    const db = openTestDbFile("data/i18n.db");
    if (db == null) return;
    g_i18n = db;
    defer {
        if (db) |d| _ = c.sqlite3_close(d);
        g_i18n = saved_i18n;
    }
    var buf: [64]u8 = undefined;
    const code = "US";
    const len = countryByAlpha2(code.ptr, @intCast(code.len), "currency", &buf, 64);
    try std.testing.expect(len > 0);
    try std.testing.expect(std.mem.eql(u8, buf[0..@intCast(len)], "United_States_dollar"));
}
