// THE DURABLE SECURITY LOG -- HaroBase rung 2.
//
// The ledger (seclog.zig) is a bounded ring: past capacity the oldest
// events give way, and verification can only speak for the window that
// remains. This file gives the ledger a SOURCE OF TRUTH that forgets
// nothing: every append is written through, in the same lock, to an
// SQLite table the engine makes INSERT-ONLY (triggers refuse UPDATE and
// DELETE), carrying the SAME chained digest the ring computes. On attach
// the whole stored chain is re-verified FROM GENESIS before a single new
// event is accepted -- a history with a gap or an edited row is refused,
// never resumed.
//
// Honest limits, stated where the code is: triggers stop a careless or
// scripted edit, not an attacker who owns the file (they can drop the
// trigger); the chain then DETECTS the edit. Truncating the tail is not
// detectable from the file alone -- anchor the head digest elsewhere (the
// keyed seal, an attestation) for that. And this SQLite copy is private
// to stz_seclog.dll: open the log file through no other connection.
//
// WHY synchronous=NORMAL, MEASURED 2026-09-29 on this machine: 500
// events, two rounds each -- FULL 2.83-3.27 ms per event, NORMAL 0.04 ms
// (memory alone 0.02-0.03). The append holds the engine lock, so at FULL
// a flood of refusals (a brute-force attempt) would stall every seam on a
// disk flush: the log would become the denial of service. In WAL mode
// NORMAL is still consistent after an APPLICATION crash; after a power
// loss it may lose the newest entries -- a truncated tail, which is the
// limit already stated above and what an anchored head digest covers.
//
// The event-log format is the canonical chain line HaroBase adopts.

const std = @import("std");
pub const c = @cImport({
    @cInclude("sqlite3.h");
});

pub const Store = struct {
    db: *c.sqlite3,
    ins: *c.sqlite3_stmt,
};

pub const ERR_OPEN: i64 = -1_000_000_001;
pub const ERR_SCHEMA: i64 = -1_000_000_002;

const SCHEMA =
    \\PRAGMA journal_mode=WAL;
    \\PRAGMA synchronous=NORMAL;
    \\CREATE TABLE IF NOT EXISTS seclog (
    \\  seq       INTEGER PRIMARY KEY,
    \\  wall_ms   REAL    NOT NULL,
    \\  severity  INTEGER NOT NULL,
    \\  canonical BLOB    NOT NULL,
    \\  digest    TEXT    NOT NULL
    \\);
    \\CREATE TRIGGER IF NOT EXISTS seclog_no_update BEFORE UPDATE ON seclog
    \\  BEGIN SELECT RAISE(ABORT, 'the security log is insert-only'); END;
    \\CREATE TRIGGER IF NOT EXISTS seclog_no_delete BEFORE DELETE ON seclog
    \\  BEGIN SELECT RAISE(ABORT, 'the security log is insert-only'); END;
;

pub fn open(path: [*:0]const u8) ?*c.sqlite3 {
    var db: ?*c.sqlite3 = null;
    const flags = c.SQLITE_OPEN_READWRITE | c.SQLITE_OPEN_CREATE;
    if (c.sqlite3_open_v2(path, &db, flags, null) != c.SQLITE_OK) {
        if (db) |d| _ = c.sqlite3_close(d);
        return null;
    }
    _ = c.sqlite3_busy_timeout(db, 5000);
    if (c.sqlite3_exec(db, SCHEMA, null, null, null) != c.SQLITE_OK) {
        _ = c.sqlite3_close(db);
        return null;
    }
    return db;
}

pub fn prepareInsert(db: *c.sqlite3) ?*c.sqlite3_stmt {
    var st: ?*c.sqlite3_stmt = null;
    const sql = "INSERT INTO seclog (seq, wall_ms, severity, canonical, digest) VALUES (?, ?, ?, ?, ?)";
    if (c.sqlite3_prepare_v2(db, sql, -1, &st, null) != c.SQLITE_OK) return null;
    return st;
}

/// Write one chained entry. true when the row is on disk.
pub fn insert(s: Store, seq: u64, wall_ms: f64, severity: u8, canonical: []const u8, digest: []const u8) bool {
    _ = c.sqlite3_reset(s.ins);
    _ = c.sqlite3_clear_bindings(s.ins);
    _ = c.sqlite3_bind_int64(s.ins, 1, @intCast(seq));
    _ = c.sqlite3_bind_double(s.ins, 2, wall_ms);
    _ = c.sqlite3_bind_int(s.ins, 3, severity);
    _ = c.sqlite3_bind_blob(s.ins, 4, canonical.ptr, @intCast(canonical.len), c.SQLITE_TRANSIENT);
    _ = c.sqlite3_bind_text(s.ins, 5, digest.ptr, @intCast(digest.len), c.SQLITE_TRANSIENT);
    const rc = c.sqlite3_step(s.ins);
    _ = c.sqlite3_reset(s.ins);
    return rc == c.SQLITE_DONE;
}

pub fn close(s: Store) void {
    _ = c.sqlite3_finalize(s.ins);
    _ = c.sqlite3_close(s.db);
}

/// One stored row, handed to the visitor in seq order. The visitor returns
/// false to stop (the row is broken).
pub const Row = struct { seq: i64, wall_ms: f64, severity: u8, canonical: []const u8, digest: []const u8 };

/// Walk every stored row in order. Returns the number walked, or -seq of
/// the first row the visitor rejected or whose seq is not the next one (a
/// gap is a break), or an ERR_ code.
pub fn walk(db: *c.sqlite3, ctx: anytype, comptime visit: fn (@TypeOf(ctx), Row) bool) i64 {
    var st: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(db, "SELECT seq, wall_ms, severity, canonical, digest FROM seclog ORDER BY seq", -1, &st, null) != c.SQLITE_OK)
        return ERR_SCHEMA;
    defer _ = c.sqlite3_finalize(st);
    var expect: i64 = 1;
    while (true) {
        const rc = c.sqlite3_step(st);
        if (rc == c.SQLITE_DONE) break;
        if (rc != c.SQLITE_ROW) return ERR_SCHEMA;
        const seq = c.sqlite3_column_int64(st, 0);
        if (seq != expect) return -expect;
        const cp: [*]const u8 = if (c.sqlite3_column_blob(st, 3)) |p| @ptrCast(p) else "";
        const cn: usize = @intCast(c.sqlite3_column_bytes(st, 3));
        const dp: [*]const u8 = if (c.sqlite3_column_text(st, 4)) |p| @ptrCast(p) else "";
        const dn: usize = @intCast(c.sqlite3_column_bytes(st, 4));
        const row = Row{
            .seq = seq,
            .wall_ms = c.sqlite3_column_double(st, 1),
            .severity = @intCast(c.sqlite3_column_int(st, 2) & 0xff),
            .canonical = cp[0..cn],
            .digest = dp[0..dn],
        };
        if (!visit(ctx, row)) return -seq;
        expect += 1;
    }
    return expect - 1;
}
