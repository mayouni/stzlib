// R7 -- THE SQLITE BRIDGE: the MBaaS/IoT data floor
// (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md 5.10: sqlite is vendored but
//  wired to nothing -- the quiet blocker for CRUD + telemetry.) This
//  wires it: open/exec/query over a small handle table.
//
// HAROBASE RUNG 0 (stzlib-security, 2026-09-29): the STATEMENT VERBS
// below -- prepare, bind, step, column, finalize, and the transaction
// trio. They exist because every statement used to be one string built
// by concatenation, with values escaped by hand; a value is now BOUND,
// never spliced, so no value can change what a statement says. The
// design follows RingServ's src/db.zig (loud errors, typed cells, BEGIN
// IMMEDIATE), and the verbs are the ones HaroBase adopts. The Ring
// bridge composes them into one crossing per statement.

const std = @import("std");

const c = @cImport({
    @cInclude("sqlite3.h");
});

const MAX_DB = 64;
var g_db: [MAX_DB]?*c.sqlite3 = [_]?*c.sqlite3{null} ** MAX_DB;
var g_err: [256]u8 = undefined;

fn setErr(msg: [*c]const u8) void {
    if (msg == null) {
        g_err[0] = 0;
        return;
    }
    const s: [*:0]const u8 = @ptrCast(msg);
    const len = @min(std.mem.len(s), g_err.len - 1);
    @memcpy(g_err[0..len], s[0..len]);
    g_err[len] = 0;
}

/// open a database (":memory:" or a file path). Returns a 1-based
/// handle, or 0 on failure.
pub fn stz_db_open(path: [*c]const u8) callconv(.c) i32 {
    var slot: i32 = -1;
    for (0..MAX_DB) |i| {
        if (g_db[i] == null) {
            slot = @intCast(i);
            break;
        }
    }
    if (slot < 0) return 0;
    var pdb: ?*c.sqlite3 = null;
    const rc = c.sqlite3_open(path, &pdb);
    if (rc != c.SQLITE_OK) {
        if (pdb) |d| _ = c.sqlite3_close(d);
        return 0;
    }
    g_db[@intCast(slot)] = pdb;
    return slot + 1;
}

fn dbOf(handle: i32) ?*c.sqlite3 {
    if (handle < 1 or handle > MAX_DB) return null;
    return g_db[@intCast(handle - 1)];
}

/// run a statement (DDL/DML). Returns rows-changed (>=0), or -1 on
/// error (message available via stz_db_error).
pub fn stz_db_exec(handle: i32, sql: [*c]const u8) callconv(.c) i32 {
    const db = dbOf(handle) orelse return -1;
    var errmsg: [*c]u8 = null;
    const rc = c.sqlite3_exec(db, sql, null, null, &errmsg);
    if (rc != c.SQLITE_OK) {
        setErr(errmsg);
        if (errmsg != null) c.sqlite3_free(errmsg);
        return -1;
    }
    return c.sqlite3_changes(db);
}

var g_out: std.ArrayListUnmanaged(u8) = .{};

/// run a SELECT; the result is a TAB-between-columns, NEWLINE-between-
/// rows string, available via stz_db_result. Returns the row count, or
/// -1 on error. Cells are text-coerced (NULL -> empty).
pub fn stz_db_query(handle: i32, sql: [*c]const u8) callconv(.c) i32 {
    const db = dbOf(handle) orelse return -1;
    var stmt: ?*c.sqlite3_stmt = null;
    const rc = c.sqlite3_prepare_v2(db, sql, -1, &stmt, null);
    if (rc != c.SQLITE_OK) {
        setErr(c.sqlite3_errmsg(db));
        return -1;
    }
    defer _ = c.sqlite3_finalize(stmt);
    const gpa = std.heap.c_allocator;
    g_out.clearRetainingCapacity();
    const ncol = c.sqlite3_column_count(stmt);
    var nrow: i32 = 0;
    while (true) {
        const src = c.sqlite3_step(stmt);
        if (src == c.SQLITE_DONE) break;
        if (src != c.SQLITE_ROW) {
            // A step that FAILS is an error, not the end of the rows: the
            // loop used to stop here and report the rows read so far as
            // the whole answer.
            setErr(c.sqlite3_errmsg(db));
            g_out.clearRetainingCapacity();
            return -1;
        }
        if (nrow > 0) g_out.append(gpa, '\n') catch return -1;
        var col: c_int = 0;
        while (col < ncol) : (col += 1) {
            if (col > 0) g_out.append(gpa, '\t') catch return -1;
            const txt = c.sqlite3_column_text(stmt, col);
            if (txt != null) {
                const s: [*:0]const u8 = @ptrCast(txt);
                g_out.appendSlice(gpa, s[0..std.mem.len(s)]) catch return -1;
            }
        }
        nrow += 1;
    }
    g_out.append(gpa, 0) catch return -1;
    return nrow;
}

pub fn stz_db_result() callconv(.c) [*c]const u8 {
    if (g_out.items.len == 0) return "";
    return @ptrCast(g_out.items.ptr);
}

pub fn stz_db_error() callconv(.c) [*c]const u8 {
    return @ptrCast(&g_err);
}

// ─── Statement verbs (HaroBase rung 0) ───

const MAX_STMT = 256;
var g_stmt: [MAX_STMT]?*c.sqlite3_stmt = [_]?*c.sqlite3_stmt{null} ** MAX_STMT;
var g_stmt_db: [MAX_STMT]i32 = [_]i32{0} ** MAX_STMT;

fn stmtOf(st: i32) ?*c.sqlite3_stmt {
    if (st < 1 or st > MAX_STMT) return null;
    return g_stmt[@intCast(st - 1)];
}

/// Prepare ONE statement. Returns a 1-based statement handle, or 0 (the
/// message via stz_db_error). Trailing text after the first statement is
/// refused: a bound statement is one statement.
pub fn stz_db_prepare(handle: i32, sql: [*c]const u8, sql_len: usize) callconv(.c) i32 {
    const db = dbOf(handle) orelse {
        setErr("no such database handle");
        return 0;
    };
    var slot: usize = MAX_STMT;
    for (0..MAX_STMT) |i| {
        if (g_stmt[i] == null) {
            slot = i;
            break;
        }
    }
    if (slot == MAX_STMT) {
        setErr("too many open statements");
        return 0;
    }
    var stmt: ?*c.sqlite3_stmt = null;
    var tail: [*c]const u8 = null;
    if (c.sqlite3_prepare_v2(db, sql, @intCast(sql_len), &stmt, &tail) != c.SQLITE_OK) {
        setErr(c.sqlite3_errmsg(db));
        return 0;
    }
    if (stmt == null) {
        setErr("empty statement");
        return 0;
    }
    if (tail != null) {
        const used: usize = @intFromPtr(tail) - @intFromPtr(sql);
        for (sql[used..sql_len]) |ch| {
            if (ch != ' ' and ch != '\t' and ch != '\n' and ch != '\r' and ch != ';') {
                _ = c.sqlite3_finalize(stmt);
                setErr("more than one statement: bind each one separately");
                return 0;
            }
        }
    }
    g_stmt[slot] = stmt;
    g_stmt_db[slot] = handle;
    return @intCast(slot + 1);
}

fn bindRc(st: i32, rc: c_int) i32 {
    if (rc == c.SQLITE_OK) return 1;
    const db = dbOf(g_stmt_db[@intCast(st - 1)]);
    if (db) |d| setErr(c.sqlite3_errmsg(d)) else setErr("bind failed");
    return 0;
}

/// Bind TEXT at 1-based index `idx`, copied (SQLITE_TRANSIENT) with its
/// exact length -- a NUL, a tab, a newline or a quote is data. 1 ok, 0 fail.
pub fn stz_db_bind_text(st: i32, idx: i32, ptr: [*c]const u8, len: usize) callconv(.c) i32 {
    const stmt = stmtOf(st) orelse return 0;
    const p: [*c]const u8 = if (ptr == null) "" else ptr;
    return bindRc(st, c.sqlite3_bind_text(stmt, idx, p, @intCast(len), c.SQLITE_TRANSIENT));
}

pub fn stz_db_bind_int(st: i32, idx: i32, v: i64) callconv(.c) i32 {
    const stmt = stmtOf(st) orelse return 0;
    return bindRc(st, c.sqlite3_bind_int64(stmt, idx, v));
}

pub fn stz_db_bind_double(st: i32, idx: i32, v: f64) callconv(.c) i32 {
    const stmt = stmtOf(st) orelse return 0;
    return bindRc(st, c.sqlite3_bind_double(stmt, idx, v));
}

pub fn stz_db_bind_null(st: i32, idx: i32) callconv(.c) i32 {
    const stmt = stmtOf(st) orelse return 0;
    return bindRc(st, c.sqlite3_bind_null(stmt, idx));
}

pub fn stz_db_param_count(st: i32) callconv(.c) i32 {
    const stmt = stmtOf(st) orelse return -1;
    return c.sqlite3_bind_parameter_count(stmt);
}

/// 1 = a row is ready, 0 = done, -1 = error (the message via stz_db_error).
pub fn stz_db_step(st: i32) callconv(.c) i32 {
    const stmt = stmtOf(st) orelse return -1;
    const rc = c.sqlite3_step(stmt);
    if (rc == c.SQLITE_ROW) return 1;
    if (rc == c.SQLITE_DONE) return 0;
    const db = dbOf(g_stmt_db[@intCast(st - 1)]);
    if (db) |d| setErr(c.sqlite3_errmsg(d)) else setErr("step failed");
    return -1;
}

pub fn stz_db_column_count(st: i32) callconv(.c) i32 {
    const stmt = stmtOf(st) orelse return 0;
    return c.sqlite3_column_count(stmt);
}

/// 1 INTEGER, 2 FLOAT, 3 TEXT, 4 BLOB, 5 NULL (SQLite's own codes).
pub fn stz_db_column_type(st: i32, col: i32) callconv(.c) i32 {
    const stmt = stmtOf(st) orelse return 5;
    return c.sqlite3_column_type(stmt, col);
}

pub fn stz_db_column_int(st: i32, col: i32) callconv(.c) i64 {
    const stmt = stmtOf(st) orelse return 0;
    return c.sqlite3_column_int64(stmt, col);
}

pub fn stz_db_column_double(st: i32, col: i32) callconv(.c) f64 {
    const stmt = stmtOf(st) orelse return 0;
    return c.sqlite3_column_double(stmt, col);
}

/// The cell as text (any type), with its exact byte length in `out_len`.
/// Valid until the next step or finalize on this statement.
pub fn stz_db_column_text(st: i32, col: i32, out_len: *usize) callconv(.c) [*c]const u8 {
    out_len.* = 0;
    const stmt = stmtOf(st) orelse return "";
    const t = c.sqlite3_column_text(stmt, col);
    if (t == null) return "";
    out_len.* = @intCast(c.sqlite3_column_bytes(stmt, col));
    return t;
}

pub fn stz_db_finalize(st: i32) callconv(.c) void {
    if (st < 1 or st > MAX_STMT) return;
    const i: usize = @intCast(st - 1);
    if (g_stmt[i]) |stmt| _ = c.sqlite3_finalize(stmt);
    g_stmt[i] = null;
    g_stmt_db[i] = 0;
}

pub fn stz_db_changes(handle: i32) callconv(.c) i32 {
    const db = dbOf(handle) orelse return -1;
    return c.sqlite3_changes(db);
}

pub fn stz_db_last_insert_id(handle: i32) callconv(.c) i64 {
    const db = dbOf(handle) orelse return 0;
    return c.sqlite3_last_insert_rowid(db);
}

fn runPlain(handle: i32, sql: [*c]const u8) i32 {
    const db = dbOf(handle) orelse {
        setErr("no such database handle");
        return 0;
    };
    var errmsg: [*c]u8 = null;
    if (c.sqlite3_exec(db, sql, null, null, &errmsg) != c.SQLITE_OK) {
        setErr(errmsg);
        if (errmsg != null) c.sqlite3_free(errmsg);
        return 0;
    }
    return 1;
}

/// BEGIN IMMEDIATE, not the deferred default: the write lock is taken now,
/// so a busy database fails here -- where the whole unit can be retried --
/// and not halfway through it (RingServ's reasoning, kept). 1 ok, 0 fail.
pub fn stz_db_begin(handle: i32) callconv(.c) i32 {
    return runPlain(handle, "BEGIN IMMEDIATE");
}

pub fn stz_db_commit(handle: i32) callconv(.c) i32 {
    return runPlain(handle, "COMMIT");
}

pub fn stz_db_rollback(handle: i32) callconv(.c) i32 {
    return runPlain(handle, "ROLLBACK");
}

pub fn stz_db_close(handle: i32) callconv(.c) i32 {
    if (handle < 1 or handle > MAX_DB) return 0;
    const idx: usize = @intCast(handle - 1);
    if (g_db[idx]) |d| {
        // statements left open on this database would keep it from closing
        for (0..MAX_STMT) |i| {
            if (g_stmt_db[i] == handle) stz_db_finalize(@intCast(i + 1));
        }
        _ = c.sqlite3_close(d);
        g_db[idx] = null;
        return 1;
    }
    return 0;
}
