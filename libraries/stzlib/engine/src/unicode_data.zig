const std = @import("std");
const c = @cImport({
    @cInclude("sqlite3.h");
});

pub const StzUnicodeDb = struct {
    db: *c.sqlite3,

    // Prepared statements (cached for performance)
    stmt_by_cp: ?*c.sqlite3_stmt = null,
    stmt_name_search: ?*c.sqlite3_stmt = null,
    stmt_block_range: ?*c.sqlite3_stmt = null,
    stmt_by_category: ?*c.sqlite3_stmt = null,
    stmt_count: ?*c.sqlite3_stmt = null,
};

// ── Schema ──────────────────────────────────────────────────────────
const schema_sql =
    \\CREATE TABLE IF NOT EXISTS chars (
    \\  codepoint  INTEGER PRIMARY KEY,
    \\  name       TEXT NOT NULL,
    \\  category   TEXT NOT NULL,
    \\  combining  INTEGER NOT NULL DEFAULT 0,
    \\  bidi       TEXT NOT NULL DEFAULT '',
    \\  decomposition TEXT NOT NULL DEFAULT '',
    \\  decimal_val TEXT NOT NULL DEFAULT '',
    \\  digit_val   TEXT NOT NULL DEFAULT '',
    \\  numeric_val TEXT NOT NULL DEFAULT '',
    \\  mirrored   INTEGER NOT NULL DEFAULT 0,
    \\  old_name   TEXT NOT NULL DEFAULT '',
    \\  uppercase  INTEGER NOT NULL DEFAULT 0,
    \\  lowercase  INTEGER NOT NULL DEFAULT 0,
    \\  titlecase  INTEGER NOT NULL DEFAULT 0
    \\);
    \\CREATE INDEX IF NOT EXISTS idx_name ON chars(name);
    \\CREATE INDEX IF NOT EXISTS idx_category ON chars(category);
;

// ── Open / Close ────────────────────────────────────────────────────

pub fn stz_unidata_open(path_ptr: ?[*]const u8, path_len: usize) callconv(.c) ?*StzUnicodeDb {
    const alloc = std.heap.c_allocator;

    var db_path: [*c]const u8 = ":memory:";
    var path_buf: ?[]u8 = null;

    if (path_ptr != null and path_len > 0) {
        const buf = alloc.alloc(u8, path_len + 1) catch return null;
        @memcpy(buf[0..path_len], path_ptr.?[0..path_len]);
        buf[path_len] = 0;
        db_path = buf.ptr;
        path_buf = buf;
    }

    var db: ?*c.sqlite3 = null;
    const rc = c.sqlite3_open(db_path, &db);

    if (path_buf) |buf| alloc.free(buf);

    if (rc != c.SQLITE_OK or db == null) {
        if (db) |d| _ = c.sqlite3_close(d);
        return null;
    }

    // WAL mode for on-disk, ignored for in-memory
    _ = c.sqlite3_exec(db, "PRAGMA journal_mode=WAL;", null, null, null);
    _ = c.sqlite3_exec(db, "PRAGMA synchronous=NORMAL;", null, null, null);

    // Create schema
    var err_msg: [*c]u8 = null;
    const sr = c.sqlite3_exec(db, schema_sql, null, null, &err_msg);
    if (sr != c.SQLITE_OK) {
        if (err_msg) |e| c.sqlite3_free(e);
        _ = c.sqlite3_close(db.?);
        return null;
    }

    const udb = alloc.create(StzUnicodeDb) catch {
        _ = c.sqlite3_close(db.?);
        return null;
    };
    udb.* = .{
        .db = db.?,
        .stmt_by_cp = null,
        .stmt_name_search = null,
        .stmt_block_range = null,
        .stmt_by_category = null,
        .stmt_count = null,
    };

    return udb;
}

pub fn stz_unidata_close(udb: ?*StzUnicodeDb) callconv(.c) void {
    const db = udb orelse return;
    if (db.stmt_by_cp) |s| _ = c.sqlite3_finalize(s);
    if (db.stmt_name_search) |s| _ = c.sqlite3_finalize(s);
    if (db.stmt_block_range) |s| _ = c.sqlite3_finalize(s);
    if (db.stmt_by_category) |s| _ = c.sqlite3_finalize(s);
    if (db.stmt_count) |s| _ = c.sqlite3_finalize(s);
    _ = c.sqlite3_close(db.db);
    std.heap.c_allocator.destroy(db);
}

// ── Import from UnicodeData.txt ─────────────────────────────────────

fn parseHex(slice: []const u8) u32 {
    var val: u32 = 0;
    for (slice) |ch| {
        val <<= 4;
        if (ch >= '0' and ch <= '9') {
            val |= ch - '0';
        } else if (ch >= 'A' and ch <= 'F') {
            val |= ch - 'A' + 10;
        } else if (ch >= 'a' and ch <= 'f') {
            val |= ch - 'a' + 10;
        }
    }
    return val;
}

fn parseDec(slice: []const u8) u32 {
    if (slice.len == 0) return 0;
    var val: u32 = 0;
    for (slice) |ch| {
        if (ch >= '0' and ch <= '9') {
            val = val * 10 + (ch - '0');
        }
    }
    return val;
}

pub fn stz_unidata_import(udb: ?*StzUnicodeDb, txt_ptr: [*]const u8, txt_len: usize) callconv(.c) i32 {
    const db = udb orelse return -1;
    const data = txt_ptr[0..txt_len];

    _ = c.sqlite3_exec(db.db, "BEGIN TRANSACTION;", null, null, null);

    const insert_sql = "INSERT OR REPLACE INTO chars (codepoint,name,category,combining,bidi,decomposition,decimal_val,digit_val,numeric_val,mirrored,old_name,uppercase,lowercase,titlecase) VALUES (?1,?2,?3,?4,?5,?6,?7,?8,?9,?10,?11,?12,?13,?14);";

    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(db.db, insert_sql, -1, &stmt, null) != c.SQLITE_OK) {
        _ = c.sqlite3_exec(db.db, "ROLLBACK;", null, null, null);
        return -2;
    }

    var count: i32 = 0;
    var line_start: usize = 0;

    while (line_start < data.len) {
        var line_end = line_start;
        while (line_end < data.len and data[line_end] != '\n') : (line_end += 1) {}

        var line = data[line_start..line_end];
        if (line.len > 0 and line[line.len - 1] == '\r') line = line[0 .. line.len - 1];

        if (line.len > 0) {
            // Parse 15 semicolon-separated fields
            var fields: [15][]const u8 = undefined;
            var fi: usize = 0;
            var fstart: usize = 0;
            for (line, 0..) |ch, idx| {
                if (ch == ';') {
                    if (fi < 15) {
                        fields[fi] = line[fstart..idx];
                        fi += 1;
                    }
                    fstart = idx + 1;
                }
            }
            if (fi < 15) {
                fields[fi] = line[fstart..];
                fi += 1;
            }

            if (fi >= 14) {
                const cp = parseHex(fields[0]);
                const mirror_val: i32 = if (fields[9].len > 0 and fields[9][0] == 'Y') 1 else 0;
                const upper_cp: i32 = if (fields[12].len > 0) @intCast(parseHex(fields[12])) else 0;
                const lower_cp: i32 = if (fields[13].len > 0) @intCast(parseHex(fields[13])) else 0;
                const title_cp: i32 = if (fi > 14 and fields[14].len > 0) @intCast(parseHex(fields[14])) else 0;

                _ = c.sqlite3_reset(stmt);
                _ = c.sqlite3_bind_int(stmt, 1, @intCast(cp));
                _ = c.sqlite3_bind_text(stmt, 2, fields[1].ptr, @intCast(fields[1].len), c.SQLITE_TRANSIENT);
                _ = c.sqlite3_bind_text(stmt, 3, fields[2].ptr, @intCast(fields[2].len), c.SQLITE_TRANSIENT);
                _ = c.sqlite3_bind_int(stmt, 4, @intCast(parseDec(fields[3])));
                _ = c.sqlite3_bind_text(stmt, 5, fields[4].ptr, @intCast(fields[4].len), c.SQLITE_TRANSIENT);
                _ = c.sqlite3_bind_text(stmt, 6, fields[5].ptr, @intCast(fields[5].len), c.SQLITE_TRANSIENT);
                _ = c.sqlite3_bind_text(stmt, 7, fields[6].ptr, @intCast(fields[6].len), c.SQLITE_TRANSIENT);
                _ = c.sqlite3_bind_text(stmt, 8, fields[7].ptr, @intCast(fields[7].len), c.SQLITE_TRANSIENT);
                _ = c.sqlite3_bind_text(stmt, 9, fields[8].ptr, @intCast(fields[8].len), c.SQLITE_TRANSIENT);
                _ = c.sqlite3_bind_int(stmt, 10, mirror_val);
                _ = c.sqlite3_bind_text(stmt, 11, fields[10].ptr, @intCast(fields[10].len), c.SQLITE_TRANSIENT);
                _ = c.sqlite3_bind_int(stmt, 12, upper_cp);
                _ = c.sqlite3_bind_int(stmt, 13, lower_cp);
                _ = c.sqlite3_bind_int(stmt, 14, title_cp);

                if (c.sqlite3_step(stmt) == c.SQLITE_DONE) {
                    count += 1;
                }
            }
        }

        line_start = line_end + 1;
    }

    _ = c.sqlite3_finalize(stmt);
    _ = c.sqlite3_exec(db.db, "COMMIT;", null, null, null);

    return count;
}

// ── Import from file path ──────────────────────────────────────────

pub fn stz_unidata_import_file(udb: ?*StzUnicodeDb, path_ptr: [*]const u8, path_len: usize) callconv(.c) i32 {
    const alloc = std.heap.c_allocator;
    const path = path_ptr[0..path_len];

    const file = std.fs.cwd().openFile(path, .{}) catch return -1;
    defer file.close();

    const stat = file.stat() catch return -1;
    const data = alloc.alloc(u8, stat.size) catch return -1;
    defer alloc.free(data);

    const bytes_read = file.readAll(data) catch return -1;

    return stz_unidata_import(udb, data.ptr, bytes_read);
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

    // Build LIKE pattern: %PATTERN%
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

    // Format: "CP;NAME\n" lines packed into result_buf
    var pos: usize = 0;
    while (c.sqlite3_step(s) == c.SQLITE_ROW) {
        const cp = c.sqlite3_column_int(s, 0);
        const name_txt = c.sqlite3_column_text(s, 1);
        const name_len: usize = @intCast(c.sqlite3_column_bytes(s, 1));

        // Format codepoint as hex
        var hex_buf: [8]u8 = undefined;
        const hex_len = formatHex(@intCast(cp), &hex_buf);

        const line_len = hex_len + 1 + name_len + 1; // "HEX;NAME\n"
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
        // Pack all columns as "col;col;col;..." into buf
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

test "open in-memory db" {
    const db = stz_unidata_open(null, 0);
    try std.testing.expect(db != null);
    stz_unidata_close(db);
}

test "import and query" {
    const db = stz_unidata_open(null, 0) orelse return error.SkipZigTest;

    const sample =
        "0041;LATIN CAPITAL LETTER A;Lu;0;L;;;;;N;;;;0061;\n" ++
        "0042;LATIN CAPITAL LETTER B;Lu;0;L;;;;;N;;;;0062;\n" ++
        "0061;LATIN SMALL LETTER A;Ll;0;L;;;;;N;;;0041;;0041\n" ++
        "0062;LATIN SMALL LETTER B;Ll;0;L;;;;;N;;;0042;;0042\n";

    const count = stz_unidata_import(db, sample.ptr, sample.len);
    try std.testing.expectEqual(@as(i32, 4), count);

    // Query count
    try std.testing.expectEqual(@as(i32, 4), stz_unidata_count(db));

    // Query char name
    var name_buf: [64]u8 = undefined;
    const name_len = stz_unidata_char_name(db, 0x41, &name_buf, name_buf.len);
    try std.testing.expectEqualStrings("LATIN CAPITAL LETTER A", name_buf[0..name_len]);

    // Search by name
    var search_buf: [1024]u8 = undefined;
    const search_len = stz_unidata_find_by_name(db, "SMALL", 5, &search_buf, search_buf.len);
    try std.testing.expect(search_len > 0);
    const search_result = search_buf[0..search_len];
    try std.testing.expect(std.mem.indexOf(u8, search_result, "LATIN SMALL LETTER A") != null);

    stz_unidata_close(db);
}

test "char info full record" {
    const db = stz_unidata_open(null, 0) orelse return error.SkipZigTest;

    const sample = "0041;LATIN CAPITAL LETTER A;Lu;0;L;;;;;N;;;;0061;\n";
    _ = stz_unidata_import(db, sample.ptr, sample.len);

    var buf: [256]u8 = undefined;
    const len = stz_unidata_char_info(db, 0x41, &buf, buf.len);
    try std.testing.expect(len > 0);
    const info = buf[0..len];
    try std.testing.expect(std.mem.indexOf(u8, info, "LATIN CAPITAL LETTER A") != null);

    stz_unidata_close(db);
}

test "chars in range" {
    const db = stz_unidata_open(null, 0) orelse return error.SkipZigTest;

    const sample =
        "0041;LATIN CAPITAL LETTER A;Lu;0;L;;;;;N;;;;0061;\n" ++
        "0042;LATIN CAPITAL LETTER B;Lu;0;L;;;;;N;;;;0062;\n" ++
        "0043;LATIN CAPITAL LETTER C;Lu;0;L;;;;;N;;;;0063;\n";
    _ = stz_unidata_import(db, sample.ptr, sample.len);

    var buf: [1024]u8 = undefined;
    const len = stz_unidata_chars_in_range(db, 0x41, 0x42, &buf, buf.len);
    const result = buf[0..len];
    try std.testing.expect(std.mem.indexOf(u8, result, "LETTER A") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "LETTER B") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "LETTER C") == null);

    stz_unidata_close(db);
}
