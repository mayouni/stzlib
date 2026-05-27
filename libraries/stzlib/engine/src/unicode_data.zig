const std = @import("std");
const builtin = @import("builtin");
const c = @cImport({
    @cInclude("sqlite3.h");
});

pub const StzUnicodeDb = struct {
    db: *c.sqlite3,

    stmt_by_cp: ?*c.sqlite3_stmt = null,
    stmt_name_search: ?*c.sqlite3_stmt = null,
    stmt_block_range: ?*c.sqlite3_stmt = null,
    stmt_by_category: ?*c.sqlite3_stmt = null,
    stmt_count: ?*c.sqlite3_stmt = null,
};

// Module-global singleton — opened once, used by all Ring bridge calls
var g_db: ?*StzUnicodeDb = null;

pub fn getGlobalDb() ?*StzUnicodeDb {
    return g_db;
}

// ── Auto-init: find unicode.db relative to DLL ─────────────────────

const win = struct {
    extern "kernel32" fn GetModuleHandleA(lpModuleName: ?[*:0]const u8) callconv(.winapi) ?*anyopaque;
    extern "kernel32" fn GetModuleFileNameA(hModule: ?*anyopaque, lpFilename: [*]u8, nSize: u32) callconv(.winapi) u32;
};

fn findDbPath(out: *[1024]u8) ?[]u8 {
    if (comptime builtin.os.tag == .windows) {
        const hMod = win.GetModuleHandleA("stz_unidata");
        var dll_path: [1024]u8 = undefined;
        const len = win.GetModuleFileNameA(hMod, &dll_path, dll_path.len);
        if (len == 0 or len >= dll_path.len) return null;

        // Walk back to find the DLL directory
        var last_sep: usize = 0;
        for (dll_path[0..len], 0..) |ch, i| {
            if (ch == '\\' or ch == '/') last_sep = i;
        }
        if (last_sep == 0) return null;

        // DLL is in .../engine/zig-out/bin/ — DB is in .../engine/data/
        // Walk up two levels from the DLL dir to get engine/
        var ups: u8 = 0;
        var pos = last_sep;
        while (pos > 0 and ups < 2) {
            pos -= 1;
            if (dll_path[pos] == '\\' or dll_path[pos] == '/') ups += 1;
        }
        if (ups < 2) return null;

        const base = dll_path[0 .. pos + 1];
        const suffix = "data/unicode.db";
        if (base.len + suffix.len >= out.len) return null;
        @memcpy(out[0..base.len], base);
        @memcpy(out[base.len .. base.len + suffix.len], suffix);
        out[base.len + suffix.len] = 0;
        return out[0 .. base.len + suffix.len];
    } else {
        // Linux/macOS: try relative to CWD as fallback
        const fallback = "data/unicode.db";
        @memcpy(out[0..fallback.len], fallback);
        out[fallback.len] = 0;
        return out[0..fallback.len];
    }
}

pub fn initGlobal() void {
    if (g_db != null) return;
    var path_buf: [1024]u8 = undefined;
    const path = findDbPath(&path_buf) orelse return;
    g_db = openDb(path.ptr, path.len);
}

pub fn shutdownGlobal() void {
    if (g_db) |db| {
        closeDb(db);
        g_db = null;
    }
}

pub fn setGlobalDbForTest(db: ?*StzUnicodeDb) void {
    g_db = db;
}

// ── Open / Close ──────────────────────────────────────────────────

pub fn openDb(path_ptr: [*]const u8, path_len: usize) ?*StzUnicodeDb {
    const alloc = std.heap.c_allocator;

    const buf = alloc.alloc(u8, path_len + 1) catch return null;
    defer alloc.free(buf);
    @memcpy(buf[0..path_len], path_ptr[0..path_len]);
    buf[path_len] = 0;

    var db: ?*c.sqlite3 = null;
    const flags = c.SQLITE_OPEN_READONLY;
    const rc = c.sqlite3_open_v2(buf.ptr, &db, flags, null);

    if (rc != c.SQLITE_OK or db == null) {
        if (db) |d| _ = c.sqlite3_close(d);
        return null;
    }

    const udb = alloc.create(StzUnicodeDb) catch {
        _ = c.sqlite3_close(db.?);
        return null;
    };
    udb.* = .{
        .db = db.?,
    };

    return udb;
}

pub fn closeDb(udb: *StzUnicodeDb) void {
    if (udb.stmt_by_cp) |s| _ = c.sqlite3_finalize(s);
    if (udb.stmt_name_search) |s| _ = c.sqlite3_finalize(s);
    if (udb.stmt_block_range) |s| _ = c.sqlite3_finalize(s);
    if (udb.stmt_by_category) |s| _ = c.sqlite3_finalize(s);
    if (udb.stmt_count) |s| _ = c.sqlite3_finalize(s);
    _ = c.sqlite3_close(udb.db);
    std.heap.c_allocator.destroy(udb);
}

// ── Public C ABI kept for static lib / direct Zig linking ──────────

pub fn stz_unidata_open(path_ptr: ?[*]const u8, path_len: usize) callconv(.c) ?*StzUnicodeDb {
    if (path_ptr == null or path_len == 0) return null;
    return openDb(path_ptr.?, path_len);
}

pub fn stz_unidata_close(udb: ?*StzUnicodeDb) callconv(.c) void {
    if (udb) |db| closeDb(db);
}

// ── Query: char name by codepoint ──────────────────────────────────

pub fn stz_unidata_char_name(udb: ?*StzUnicodeDb, codepoint: i32, buf: [*]u8, buf_len: usize) callconv(.c) usize {
    const db = udb orelse return 0;

    if (db.stmt_by_cp == null) {
        _ = c.sqlite3_prepare_v2(db.db, "SELECT name FROM chars WHERE codepoint=?1;", -1, &db.stmt_by_cp, null);
    }
    const stmt = db.stmt_by_cp orelse return 0;
    _ = c.sqlite3_reset(stmt);
    _ = c.sqlite3_bind_int(stmt, 1, codepoint);

    if (c.sqlite3_step(stmt) == c.SQLITE_ROW) {
        const txt = c.sqlite3_column_text(stmt, 0);
        const len: usize = @intCast(c.sqlite3_column_bytes(stmt, 0));
        const out_len = @min(len, buf_len);
        if (txt) |t| {
            @memcpy(buf[0..out_len], t[0..out_len]);
        }
        return out_len;
    }
    return 0;
}

// ── Query: char category by codepoint ──────────────────────────────

pub fn stz_unidata_char_category(udb: ?*StzUnicodeDb, codepoint: i32, buf: [*]u8, buf_len: usize) callconv(.c) usize {
    const db = udb orelse return 0;

    if (db.stmt_by_category == null) {
        _ = c.sqlite3_prepare_v2(db.db, "SELECT category FROM chars WHERE codepoint=?1;", -1, &db.stmt_by_category, null);
    }
    const stmt = db.stmt_by_category orelse return 0;
    _ = c.sqlite3_reset(stmt);
    _ = c.sqlite3_bind_int(stmt, 1, codepoint);

    if (c.sqlite3_step(stmt) == c.SQLITE_ROW) {
        const txt = c.sqlite3_column_text(stmt, 0);
        const len: usize = @intCast(c.sqlite3_column_bytes(stmt, 0));
        const out_len = @min(len, buf_len);
        if (txt) |t| @memcpy(buf[0..out_len], t[0..out_len]);
        return out_len;
    }
    return 0;
}

// ── Query: search chars by name (LIKE %pattern%) ───────────────────

pub fn stz_unidata_find_by_name(udb: ?*StzUnicodeDb, pattern_ptr: [*]const u8, pattern_len: usize, result_buf: [*]u8, result_buf_len: usize) callconv(.c) usize {
    const db = udb orelse return 0;
    const pattern = pattern_ptr[0..pattern_len];

    var like_buf: [512]u8 = undefined;
    if (pattern_len + 2 > like_buf.len) return 0;
    like_buf[0] = '%';
    @memcpy(like_buf[1 .. 1 + pattern_len], pattern);
    like_buf[1 + pattern_len] = '%';
    const like_str = like_buf[0 .. pattern_len + 2];

    var stmt: ?*c.sqlite3_stmt = null;
    _ = c.sqlite3_prepare_v2(db.db, "SELECT codepoint,name FROM chars WHERE name LIKE ?1 ORDER BY codepoint LIMIT 1000;", -1, &stmt, null);
    defer {
        if (stmt) |s| _ = c.sqlite3_finalize(s);
    }

    const s = stmt orelse return 0;
    _ = c.sqlite3_bind_text(s, 1, like_str.ptr, @intCast(like_str.len), c.SQLITE_TRANSIENT);

    var pos: usize = 0;
    while (c.sqlite3_step(s) == c.SQLITE_ROW) {
        const cp = c.sqlite3_column_int(s, 0);
        const name_txt = c.sqlite3_column_text(s, 1);
        const name_len: usize = @intCast(c.sqlite3_column_bytes(s, 1));

        var hex_buf: [8]u8 = undefined;
        const hex_len = formatHex(@intCast(cp), &hex_buf);

        const line_len = hex_len + 1 + name_len + 1;
        if (pos + line_len > result_buf_len) break;

        @memcpy(result_buf[pos .. pos + hex_len], hex_buf[0..hex_len]);
        pos += hex_len;
        result_buf[pos] = ';';
        pos += 1;
        if (name_txt) |t| {
            @memcpy(result_buf[pos .. pos + name_len], t[0..name_len]);
        }
        pos += name_len;
        result_buf[pos] = '\n';
        pos += 1;
    }
    return pos;
}

fn formatHex(val: u32, buf: *[8]u8) usize {
    const hex_chars = "0123456789ABCDEF";
    var v = val;
    var i: usize = 0;
    var tmp: [8]u8 = undefined;
    if (v == 0) {
        buf[0] = '0';
        return 1;
    }
    while (v > 0) : (i += 1) {
        tmp[i] = hex_chars[@intCast(v & 0xF)];
        v >>= 4;
    }
    for (0..i) |j| {
        buf[j] = tmp[i - 1 - j];
    }
    return i;
}

// ── Query: chars in codepoint range ────────────────────────────────

pub fn stz_unidata_chars_in_range(udb: ?*StzUnicodeDb, cp_from: i32, cp_to: i32, result_buf: [*]u8, result_buf_len: usize) callconv(.c) usize {
    const db = udb orelse return 0;

    var stmt: ?*c.sqlite3_stmt = null;
    _ = c.sqlite3_prepare_v2(db.db, "SELECT codepoint,name FROM chars WHERE codepoint BETWEEN ?1 AND ?2 ORDER BY codepoint;", -1, &stmt, null);
    defer {
        if (stmt) |s| _ = c.sqlite3_finalize(s);
    }

    const s = stmt orelse return 0;
    _ = c.sqlite3_bind_int(s, 1, cp_from);
    _ = c.sqlite3_bind_int(s, 2, cp_to);

    var pos: usize = 0;
    while (c.sqlite3_step(s) == c.SQLITE_ROW) {
        const cp = c.sqlite3_column_int(s, 0);
        const name_txt = c.sqlite3_column_text(s, 1);
        const name_len: usize = @intCast(c.sqlite3_column_bytes(s, 1));

        var hex_buf: [8]u8 = undefined;
        const hex_len = formatHex(@intCast(cp), &hex_buf);

        const line_len = hex_len + 1 + name_len + 1;
        if (pos + line_len > result_buf_len) break;

        @memcpy(result_buf[pos .. pos + hex_len], hex_buf[0..hex_len]);
        pos += hex_len;
        result_buf[pos] = ';';
        pos += 1;
        if (name_txt) |t| @memcpy(result_buf[pos .. pos + name_len], t[0..name_len]);
        pos += name_len;
        result_buf[pos] = '\n';
        pos += 1;
    }
    return pos;
}

// ── Query: total char count ────────────────────────────────────────

pub fn stz_unidata_count(udb: ?*StzUnicodeDb) callconv(.c) i32 {
    const db = udb orelse return 0;

    if (db.stmt_count == null) {
        _ = c.sqlite3_prepare_v2(db.db, "SELECT COUNT(*) FROM chars;", -1, &db.stmt_count, null);
    }
    const stmt = db.stmt_count orelse return 0;
    _ = c.sqlite3_reset(stmt);

    if (c.sqlite3_step(stmt) == c.SQLITE_ROW) {
        return c.sqlite3_column_int(stmt, 0);
    }
    return 0;
}

// ── Query: codepoint by exact name (case-insensitive) ─────────────

pub fn stz_unidata_codepoint_by_name(udb: ?*StzUnicodeDb, name_ptr: [*]const u8, name_len: usize) callconv(.c) i32 {
    const db = udb orelse return -1;
    const name = name_ptr[0..name_len];

    var stmt: ?*c.sqlite3_stmt = null;
    _ = c.sqlite3_prepare_v2(db.db, "SELECT codepoint FROM chars WHERE name=?1 COLLATE NOCASE LIMIT 1;", -1, &stmt, null);
    defer {
        if (stmt) |s| _ = c.sqlite3_finalize(s);
    }

    const s = stmt orelse return -1;
    _ = c.sqlite3_bind_text(s, 1, name.ptr, @intCast(name.len), c.SQLITE_TRANSIENT);

    if (c.sqlite3_step(s) == c.SQLITE_ROW) {
        return c.sqlite3_column_int(s, 0);
    }
    return -1;
}

// ── Query: check if name exists (case-insensitive) ────────────────

pub fn stz_unidata_contains_name(udb: ?*StzUnicodeDb, name_ptr: [*]const u8, name_len: usize) callconv(.c) i32 {
    return if (stz_unidata_codepoint_by_name(udb, name_ptr, name_len) >= 0) 1 else 0;
}

// ── Query: char full record ────────────────────────────────────────

pub fn stz_unidata_char_info(udb: ?*StzUnicodeDb, codepoint: i32, buf: [*]u8, buf_len: usize) callconv(.c) usize {
    const db = udb orelse return 0;

    var stmt: ?*c.sqlite3_stmt = null;
    _ = c.sqlite3_prepare_v2(db.db, "SELECT * FROM chars WHERE codepoint=?1;", -1, &stmt, null);
    defer {
        if (stmt) |s| _ = c.sqlite3_finalize(s);
    }

    const s = stmt orelse return 0;
    _ = c.sqlite3_bind_int(s, 1, codepoint);

    if (c.sqlite3_step(s) == c.SQLITE_ROW) {
        const ncols = c.sqlite3_column_count(s);
        var pos: usize = 0;
        var col: i32 = 0;
        while (col < ncols) : (col += 1) {
            if (col > 0) {
                if (pos < buf_len) {
                    buf[pos] = ';';
                    pos += 1;
                }
            }
            const txt = c.sqlite3_column_text(s, col);
            const len: usize = @intCast(c.sqlite3_column_bytes(s, col));
            const copy_len = @min(len, buf_len -| pos);
            if (txt) |t| @memcpy(buf[pos .. pos + copy_len], t[0..copy_len]);
            pos += copy_len;
        }
        return pos;
    }
    return 0;
}

// ── Tests ──────────────────────────────────────────────────────────

fn openTestDb() ?*StzUnicodeDb {
    const db_path = "data/unicode.db";
    return openDb(db_path.ptr, db_path.len);
}

test "open pre-built database" {
    const db = openTestDb();
    if (db == null) return;
    defer closeDb(db.?);
    const count = stz_unidata_count(db);
    try std.testing.expect(count > 34000);
}

test "char name and category lookup" {
    const db = openTestDb() orelse return;
    defer closeDb(db);

    var name_buf: [64]u8 = undefined;
    const name_len = stz_unidata_char_name(db, 0x41, &name_buf, name_buf.len);
    try std.testing.expectEqualStrings("LATIN CAPITAL LETTER A", name_buf[0..name_len]);

    var cat_buf: [16]u8 = undefined;
    const cat_len = stz_unidata_char_category(db, 0x41, &cat_buf, cat_buf.len);
    try std.testing.expectEqualStrings("Lu", cat_buf[0..cat_len]);

    const cat_len2 = stz_unidata_char_category(db, 0x30, &cat_buf, cat_buf.len);
    try std.testing.expectEqualStrings("Nd", cat_buf[0..cat_len2]);
}

test "search by name" {
    const db = openTestDb() orelse return;
    defer closeDb(db);

    var search_buf: [4096]u8 = undefined;
    const search_len = stz_unidata_find_by_name(db, "EURO", 4, &search_buf, search_buf.len);
    try std.testing.expect(search_len > 0);
    const result = search_buf[0..search_len];
    try std.testing.expect(std.mem.indexOf(u8, result, "EURO SIGN") != null);
}

test "char info full record" {
    const db = openTestDb() orelse return;
    defer closeDb(db);

    var buf: [256]u8 = undefined;
    const len = stz_unidata_char_info(db, 0x41, &buf, buf.len);
    try std.testing.expect(len > 0);
    const info = buf[0..len];
    try std.testing.expect(std.mem.indexOf(u8, info, "LATIN CAPITAL LETTER A") != null);
}

test "chars in range" {
    const db = openTestDb() orelse return;
    defer closeDb(db);

    var buf: [4096]u8 = undefined;
    const len = stz_unidata_chars_in_range(db, 0x41, 0x43, &buf, buf.len);
    const result = buf[0..len];
    try std.testing.expect(std.mem.indexOf(u8, result, "LETTER A") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "LETTER B") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "LETTER C") != null);
}
