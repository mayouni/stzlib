const std = @import("std");
const c = @cImport({
    @cInclude("sqlite3.h");
});

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

pub fn main() !void {
    const alloc = std.heap.page_allocator;

    const txt_path = "src/unicodedata.txt";
    const db_path = "data/unicode.db";

    const file = std.fs.cwd().openFile(txt_path, .{}) catch |e| {
        std.debug.print("ERROR: cannot open {s}: {}\n", .{ txt_path, e });
        return error.FileNotFound;
    };
    defer file.close();

    const stat = file.stat() catch return error.StatFailed;
    const data = alloc.alloc(u8, stat.size) catch return error.OutOfMemory;
    defer alloc.free(data);
    const bytes_read = file.readAll(data) catch return error.ReadFailed;
    const txt = data[0..bytes_read];

    std.fs.cwd().makePath("data") catch {};

    std.fs.cwd().deleteFile(db_path) catch {};

    var db: ?*c.sqlite3 = null;
    var rc = c.sqlite3_open(db_path, &db);
    if (rc != c.SQLITE_OK or db == null) {
        std.debug.print("ERROR: cannot create database\n", .{});
        return error.DbOpen;
    }
    defer _ = c.sqlite3_close(db.?);

    _ = c.sqlite3_exec(db, "PRAGMA journal_mode=WAL;", null, null, null);
    _ = c.sqlite3_exec(db, "PRAGMA synchronous=NORMAL;", null, null, null);

    var err_msg: [*c]u8 = null;
    rc = c.sqlite3_exec(db, schema_sql, null, null, &err_msg);
    if (rc != c.SQLITE_OK) {
        std.debug.print("ERROR: schema creation failed\n", .{});
        if (err_msg) |e| c.sqlite3_free(e);
        return error.Schema;
    }

    _ = c.sqlite3_exec(db, "BEGIN TRANSACTION;", null, null, null);

    const insert_sql = "INSERT OR REPLACE INTO chars (codepoint,name,category,combining,bidi,decomposition,decimal_val,digit_val,numeric_val,mirrored,old_name,uppercase,lowercase,titlecase) VALUES (?1,?2,?3,?4,?5,?6,?7,?8,?9,?10,?11,?12,?13,?14);";

    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(db, insert_sql, -1, &stmt, null) != c.SQLITE_OK) {
        std.debug.print("ERROR: prepare failed\n", .{});
        return error.Prepare;
    }
    defer _ = c.sqlite3_finalize(stmt);

    var count: u32 = 0;
    var line_start: usize = 0;

    while (line_start < txt.len) {
        var line_end = line_start;
        while (line_end < txt.len and txt[line_end] != '\n') : (line_end += 1) {}

        var line = txt[line_start..line_end];
        if (line.len > 0 and line[line.len - 1] == '\r') line = line[0 .. line.len - 1];

        if (line.len > 0) {
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

    _ = c.sqlite3_exec(db, "COMMIT;", null, null, null);

    // Checkpoint WAL to merge into main DB file
    _ = c.sqlite3_exec(db, "PRAGMA wal_checkpoint(TRUNCATE);", null, null, null);
    // Switch to DELETE journal so only one file ships
    _ = c.sqlite3_exec(db, "PRAGMA journal_mode=DELETE;", null, null, null);

    std.debug.print("Generated {s}: {d} characters imported\n", .{ db_path, count });
}
