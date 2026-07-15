// Fuzz harness for SQLite -- the SQL parser + bytecode engine, run on
// untrusted SQL. Compiled under UBSan-trap. Feeds random SQL-ish text to
// sqlite3_prepare_v2 on an in-memory DB and steps any statement that
// compiles; the parser must reject garbage without crashing / UB.

const std = @import("std");
const c = @cImport({
    @cInclude("sqlite3.h");
});

fn fuzzSql(db: ?*c.sqlite3, sql: []const u8) void {
    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(db, sql.ptr, @intCast(sql.len), &stmt, null) == c.SQLITE_OK) {
        var steps: usize = 0;
        while (steps < 200 and c.sqlite3_step(stmt) == c.SQLITE_ROW) : (steps += 1) {}
    }
    _ = c.sqlite3_finalize(stmt);
}

pub fn main() void {
    var db: ?*c.sqlite3 = null;
    if (c.sqlite3_open(":memory:", &db) != c.SQLITE_OK) {
        std.debug.print("FAIL: could not open in-memory db\n", .{});
        std.process.exit(1);
    }
    defer _ = c.sqlite3_close(db);

    // SQL keywords/fragments so random text becomes plausible SQL
    const frags = [_][]const u8{
        "SELECT ",   "FROM ",    "WHERE ",   "CREATE TABLE ",  "INSERT INTO ",
        "VALUES ",   "(",        ")",        ",",              "t",
        "1",         "'x'",      "*",        "JOIN ",          "ON ",
        "GROUP BY ", "ORDER BY ", ";",       "a=b",            "NULL",
        "UNION ",    "SELECT sqlite_version()", "PRAGMA ",     "CASE WHEN ",
    };
    var prng = std.Random.DefaultPrng.init(0x51413A_9999);
    const rand = prng.random();
    var buf: [1024]u8 = undefined;
    var iter: usize = 0;
    const rounds: usize = 100_000;
    while (iter < rounds) : (iter += 1) {
        var len: usize = 0;
        const parts = rand.uintLessThan(usize, 24);
        var p: usize = 0;
        while (p < parts) : (p += 1) {
            if (rand.uintLessThan(u8, 4) == 0) {
                // inject a raw random byte for good measure
                if (len < buf.len) {
                    buf[len] = rand.int(u8);
                    len += 1;
                }
            } else {
                const f = frags[rand.uintLessThan(usize, frags.len)];
                if (len + f.len > buf.len) break;
                @memcpy(buf[len .. len + f.len], f);
                len += f.len;
            }
        }
        fuzzSql(db, buf[0..len]);
    }
    std.debug.print("PASS: {d} sqlite prepare+step inputs, no crash / UB.\n", .{rounds});
    std.process.exit(0);
}
