// R7 -- THE SQLITE BRIDGE: the MBaaS/IoT data floor
// (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md 5.10: sqlite is vendored but
//  wired to nothing -- the quiet blocker for CRUD + telemetry.) This
//  wires it: open/exec/query over a small handle table. Query results
//  return as a TAB/NEWLINE-delimited string (Ring splits it) -- robust
//  and panic-free at the floor; a typed row API is the next rung.

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
    while (c.sqlite3_step(stmt) == c.SQLITE_ROW) {
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

pub fn stz_db_close(handle: i32) callconv(.c) i32 {
    if (handle < 1 or handle > MAX_DB) return 0;
    const idx: usize = @intCast(handle - 1);
    if (g_db[idx]) |d| {
        _ = c.sqlite3_close(d);
        g_db[idx] = null;
        return 1;
    }
    return 0;
}
