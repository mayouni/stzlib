const std = @import("std");
const db = @import("db.zig");
const R = @import("ring_api.zig");

const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const gn = R.ring_vm_api_getnumber;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring;

const ITEMTYPE_STRING: c_uint = 1;
const ITEMTYPE_NUMBER: c_uint = 2;

fn ring_Open(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(db.stz_db_open(@ptrCast(gs(p, 1)))));
}
fn ring_Exec(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(db.stz_db_exec(@intFromFloat(gn(p, 1)), @ptrCast(gs(p, 2)))));
}
fn ring_Query(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(db.stz_db_query(@intFromFloat(gn(p, 1)), @ptrCast(gs(p, 2)))));
}
fn ring_Result(p: *anyopaque) callconv(.c) void {
    rs(p, @ptrCast(db.stz_db_result()));
}
fn ring_Error(p: *anyopaque) callconv(.c) void {
    rs(p, @ptrCast(db.stz_db_error()));
}
fn ring_Close(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(db.stz_db_close(@intFromFloat(gn(p, 1)))));
}

// ─── Bound statements: one crossing per statement ───
//
// StzEngineDbExecP(nDb, cSql, aParams)          -> rows changed
// StzEngineDbQueryP(nDb, cSql, aParams, nTyped) -> [ [cell, ...], ... ]
//
// Every value in aParams is BOUND to a `?` in cSql, never spliced into
// it: a string binds as TEXT with its exact length, an integral number as
// INTEGER, any other number as REAL. With nTyped = 0 every cell comes back
// as text (NULL as ""), the contract stzDatabase.Rows() always had; with
// nTyped = 1 INTEGER and REAL come back as numbers. ANY failure -- prepare,
// bind, or a step midway through the rows -- raises a trappable Ring error
// carrying SQLite's message. A failure never returns the rows read so far.

fn raise(p: *anyopaque, what: []const u8) void {
    var buf: [600]u8 = undefined;
    const detail: [*:0]const u8 = @ptrCast(db.stz_db_error());
    const msg = std.fmt.bufPrintZ(&buf, "{s}: {s}", .{ what, std.mem.span(detail) }) catch "database error";
    R.ring_vm_error(p, msg);
}

/// Prepare arg 2 against the handle in arg 1 and bind the list in arg 3.
/// Returns the statement handle, or 0 after raising.
fn prepareBound(p: *anyopaque) i32 {
    const h: i32 = @intFromFloat(gn(p, 1));
    const st = db.stz_db_prepare(h, gs(p, 2), @intCast(gss(p, 2)));
    if (st == 0) {
        raise(p, "sql error");
        return 0;
    }
    if (R.ring_vm_api_paracount(p) < 3 or R.il(p, 3) == 0) {
        db.stz_db_finalize(st);
        R.ring_vm_error(p, "sql error: the parameters must be a list ([] for none)");
        return 0;
    }
    const list = R.gl(p, 3) orelse {
        db.stz_db_finalize(st);
        R.ring_vm_error(p, "sql error: the parameters must be a list ([] for none)");
        return 0;
    };
    const n = R.ringListSize(list);
    if (@as(i32, @intCast(n)) != db.stz_db_param_count(st)) {
        db.stz_db_finalize(st);
        var buf: [160]u8 = undefined;
        const msg = std.fmt.bufPrintZ(&buf, "sql error: {d} parameter(s) given, the statement has {d}", .{ n, db.stz_db_param_count(st) }) catch "sql error: parameter count";
        R.ring_vm_error(p, msg);
        return 0;
    }
    var i: c_uint = 1;
    while (i <= n) : (i += 1) {
        const idx: i32 = @intCast(i);
        const t = R.ring_list_gettype_gc(null, list, i);
        const item = R.ring_list_getitem_gc(null, list, i);
        var ok: i32 = 0;
        if (t == ITEMTYPE_STRING and item != null) {
            const ptr = R.ringItemStringPtr(item.?) orelse "";
            ok = db.stz_db_bind_text(st, idx, ptr, R.ringItemStringSize(item.?));
        } else if (t == ITEMTYPE_NUMBER and item != null) {
            const v = R.ring_item_getnumber(item.?);
            const integral = @floor(v) == v and v >= -9.007199254740992e15 and v <= 9.007199254740992e15;
            ok = if (integral) db.stz_db_bind_int(st, idx, @intFromFloat(v)) else db.stz_db_bind_double(st, idx, v);
        } else {
            db.stz_db_finalize(st);
            var buf: [120]u8 = undefined;
            const msg = std.fmt.bufPrintZ(&buf, "sql error: parameter {d} must be a string or a number", .{i}) catch "sql error: bad parameter";
            R.ring_vm_error(p, msg);
            return 0;
        }
        if (ok == 0) {
            db.stz_db_finalize(st);
            raise(p, "sql bind error");
            return 0;
        }
    }
    return st;
}

fn ring_ExecP(p: *anyopaque) callconv(.c) void {
    const st = prepareBound(p);
    if (st == 0) return;
    defer db.stz_db_finalize(st);
    while (true) {
        const rc = db.stz_db_step(st);
        if (rc == 0) break;
        if (rc < 0) return raise(p, "sql error");
    }
    rn(p, @floatFromInt(db.stz_db_changes(@intFromFloat(gn(p, 1)))));
}

fn ring_QueryP(p: *anyopaque) callconv(.c) void {
    const st = prepareBound(p);
    if (st == 0) return;
    defer db.stz_db_finalize(st);
    const typed = R.ring_vm_api_paracount(p) >= 4 and gn(p, 4) != 0;
    const out = R.ring_vm_api_newlist(p) orelse return;
    const ncol = db.stz_db_column_count(st);
    while (true) {
        const rc = db.stz_db_step(st);
        if (rc == 0) break;
        if (rc < 0) return raise(p, "sql error");
        const row = R.ring_list_newlist(out) orelse return;
        var col: i32 = 0;
        while (col < ncol) : (col += 1) {
            const ty = db.stz_db_column_type(st, col);
            if (typed and ty == 1) {
                R.ring_list_adddouble(row, @floatFromInt(db.stz_db_column_int(st, col)));
            } else if (typed and ty == 2) {
                R.ring_list_adddouble(row, db.stz_db_column_double(st, col));
            } else {
                var len: usize = 0;
                const t = db.stz_db_column_text(st, col, &len);
                R.ring_list_addstring2(row, t, @intCast(len));
            }
        }
    }
    R.ring_vm_api_retlist(p, out);
}

fn txn(p: *anyopaque, rc: i32, what: []const u8) void {
    if (rc == 0) return raise(p, what);
    rn(p, 1);
}
fn ring_Begin(p: *anyopaque) callconv(.c) void {
    txn(p, db.stz_db_begin(@intFromFloat(gn(p, 1))), "cannot begin transaction");
}
fn ring_Commit(p: *anyopaque) callconv(.c) void {
    txn(p, db.stz_db_commit(@intFromFloat(gn(p, 1))), "cannot commit");
}
fn ring_Rollback(p: *anyopaque) callconv(.c) void {
    txn(p, db.stz_db_rollback(@intFromFloat(gn(p, 1))), "cannot roll back");
}
fn ring_LastInsertId(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(db.stz_db_last_insert_id(@intFromFloat(gn(p, 1)))));
}

const regs = [_]R.Reg{
    .{ .name = "stzenginedbopen", .func = &ring_Open },
    .{ .name = "stzenginedbexec", .func = &ring_Exec },
    .{ .name = "stzenginedbquery", .func = &ring_Query },
    .{ .name = "stzenginedbresult", .func = &ring_Result },
    .{ .name = "stzenginedberror", .func = &ring_Error },
    .{ .name = "stzenginedbclose", .func = &ring_Close },
    .{ .name = "stzenginedbexecp", .func = &ring_ExecP },
    .{ .name = "stzenginedbqueryp", .func = &ring_QueryP },
    .{ .name = "stzenginedbbegin", .func = &ring_Begin },
    .{ .name = "stzenginedbcommit", .func = &ring_Commit },
    .{ .name = "stzenginedbrollback", .func = &ring_Rollback },
    .{ .name = "stzenginedblastinsertid", .func = &ring_LastInsertId },
};

pub fn registerAll(state: *anyopaque) void {
    R.registerAll(state, &regs);
}
