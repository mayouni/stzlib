const std = @import("std");
const seclog = @import("seclog.zig");
const shutlist = @import("door_shut.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const rn = R.ring_vm_api_retnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rs = R.ring_vm_api_retstring;
const rs2 = R.ring_vm_api_retstring2;

const LOG_HANDLE: [*:0]const u8 = "StzSecLog";

var str_buf: [512]u8 = undefined;

fn getLog(p: *anyopaque, n: c_int) ?*seclog.SecLog {
    // ids from the generation-checked table: a destroyed ledger's copy raises (R16)
    const raw = R.getHandleOrRaise(p, n, "security ledger") orelse return null;
    return @ptrFromInt(@intFromPtr(raw));
}

fn ring_SecLogCreate(p: *anyopaque) callconv(.c) void {
    const handle = seclog.seclog_create(gn(p, 1));
    if (handle) |sl| {
        sl.ring_id = R.storeHandle(@ptrCast(sl));
        rn(p, sl.ring_id);
    } else rn(p, 0);
}

fn ring_SecLogAppend(p: *anyopaque) callconv(.c) void {
    const c: [*]const u8 = @ptrCast(gs(p, 2));
    const cl: usize = @intCast(gss(p, 2));
    seclog.seclog_append(getLog(p, 1), c, cl, gn(p, 3), gn(p, 4));
    rn(p, 0);
}

// StzEngineSecLogAttach(h, cPath) -> entries verified (>= 0) or negative
fn ring_SecLogAttach(p: *anyopaque) callconv(.c) void {
    var buf: [1024]u8 = undefined;
    const path = std.fmt.bufPrintZ(&buf, "{s}", .{gs(p, 2)[0..@intCast(gss(p, 2))]}) catch {
        rn(p, -1_000_000_001);
        return;
    };
    rn(p, seclog.seclog_attach(getLog(p, 1), path.ptr));
}

fn ring_SecLogVerifyDurable(p: *anyopaque) callconv(.c) void {
    rn(p, seclog.seclog_verify_durable(getLog(p, 1)));
}

fn ring_SecLogIsDurable(p: *anyopaque) callconv(.c) void {
    rn(p, seclog.seclog_is_durable(getLog(p, 1)));
}

fn ring_SecLogDurableErrors(p: *anyopaque) callconv(.c) void {
    rn(p, seclog.seclog_durable_errors(getLog(p, 1)));
}

fn ring_SecLogCount(p: *anyopaque) callconv(.c) void {
    rn(p, seclog.seclog_count(getLog(p, 1)));
}

fn ring_SecLogCapacity(p: *anyopaque) callconv(.c) void {
    rn(p, seclog.seclog_capacity(getLog(p, 1)));
}

fn ring_SecLogSize(p: *anyopaque) callconv(.c) void {
    rn(p, seclog.seclog_size(getLog(p, 1)));
}

fn ring_SecLogCanonicalAt(p: *anyopaque) callconv(.c) void {
    const n = seclog.seclog_canonical_at(getLog(p, 1), gn(p, 2), &str_buf, str_buf.len);
    if (n > 0) rs2(p, &str_buf, @intCast(n)) else rs(p, @constCast(""));
}

fn ring_SecLogDigestAt(p: *anyopaque) callconv(.c) void {
    const n = seclog.seclog_digest_at(getLog(p, 1), gn(p, 2), &str_buf, str_buf.len);
    if (n > 0) rs2(p, &str_buf, @intCast(n)) else rs(p, @constCast(""));
}

fn ring_SecLogHeadDigest(p: *anyopaque) callconv(.c) void {
    const n = seclog.seclog_head_digest(getLog(p, 1), &str_buf, str_buf.len);
    if (n > 0) rs2(p, &str_buf, @intCast(n)) else rs(p, @constCast(""));
}

fn ring_SecLogWallAt(p: *anyopaque) callconv(.c) void {
    rn(p, seclog.seclog_wall_at(getLog(p, 1), gn(p, 2)));
}

fn ring_SecLogSeverityAt(p: *anyopaque) callconv(.c) void {
    rn(p, seclog.seclog_severity_at(getLog(p, 1), gn(p, 2)));
}

// StzEngineSecLogSetRefusalBudget(h, nMax, nWindowMs) -- nMax 0 = off
fn ring_SecLogSetRefusalBudget(p: *anyopaque) callconv(.c) void {
    seclog.seclog_set_refusal_budget(getLog(p, 1), gn(p, 2), gn(p, 3));
    rn(p, 0);
}

fn ring_SecLogBudgetMax(p: *anyopaque) callconv(.c) void {
    rn(p, seclog.seclog_budget_max(getLog(p, 1)));
}

fn ring_SecLogBudgetWindow(p: *anyopaque) callconv(.c) void {
    rn(p, seclog.seclog_budget_window(getLog(p, 1)));
}

fn ring_SecLogSuppressed(p: *anyopaque) callconv(.c) void {
    rn(p, seclog.seclog_suppressed(getLog(p, 1)));
}

// StzEngineSecLogFlushBudget(h, nWallMs)
fn ring_SecLogFlushBudget(p: *anyopaque) callconv(.c) void {
    seclog.seclog_flush_budget(getLog(p, 1), gn(p, 2));
    rn(p, 0);
}

// StzEngineSecLogVerifyAnchor(h, nSeq, cDigestHex) -> 0 holds, -1 not durable,
// -2 unreadable, -3 truncated, -4 diverged, >0 the chain breaks at that entry
fn ring_SecLogVerifyAnchor(p: *anyopaque) callconv(.c) void {
    const d: [*]const u8 = @ptrCast(gs(p, 3));
    const dl: usize = @intCast(gss(p, 3));
    rn(p, seclog.seclog_verify_anchor(getLog(p, 1), gn(p, 2), d, dl));
}

fn ring_SecLogVerify(p: *anyopaque) callconv(.c) void {
    rn(p, seclog.seclog_verify(getLog(p, 1)));
}

fn ring_SecLogReset(p: *anyopaque) callconv(.c) void {
    seclog.seclog_reset(getLog(p, 1));
    rn(p, 0);
}

fn ring_SecLogDestroy(p: *anyopaque) callconv(.c) void {
    // release FIRST: every copy of this id goes stale before the memory is freed
    const raw = R.releaseHandle(p, 1);
    if (raw) |ptr| seclog.seclog_destroy(@ptrFromInt(@intFromPtr(ptr)));
    rn(p, 0);
}

fn ring_SecLogSetCurrent(p: *anyopaque) callconv(.c) void {
    seclog.seclog_set_current(getLog(p, 1));
    rn(p, 0);
}

fn ring_SecLogClearCurrent(p: *anyopaque) callconv(.c) void {
    seclog.seclog_clear_current();
    rn(p, 0);
}

fn ring_SecLogHasCurrent(p: *anyopaque) callconv(.c) void {
    rn(p, seclog.seclog_has_current());
}

fn ring_SecLogCurrent(p: *anyopaque) callconv(.c) void {
    const cur = seclog.seclog_current();
    if (cur) |sp| {
        if (sp.ring_id == 0) sp.ring_id = R.storeHandle(@ptrCast(sp)); // opened by the engine door
        rn(p, sp.ring_id);
    } else rn(p, 0);
}

fn ring_SecLogCurrentAppend(p: *anyopaque) callconv(.c) void {
    const c: [*]const u8 = @ptrCast(gs(p, 1));
    const cl: usize = @intCast(gss(p, 1));
    seclog.seclog_current_append(c, cl, gn(p, 2), gn(p, 3));
    rn(p, 0);
}

// -- THE ENGINE DOOR (SECURITY-R18b) ------------------------------------------
//
// The model doors were Ring functions, so a direct StzEngineNeural* call passed
// none of them. This is the half that lets another engine DLL write the record
// itself, before it returns to Ring: stz_seclog exports one C entry point, and
// seclog_door.zig (imported by the consumer) finds it by name. Each DLL has its
// own handle table and its own copy of every Zig global, so the ledger can only
// be reached through THIS DLL's export, never by importing seclog.zig twice.
//
// Like the Ring doors, it opens the process ledger when none is open, so no face
// can switch the record off; the ledger it opens gets a Ring id when Ring
// first asks for it, so StzSecurityLedgerQ() reads it like any other. The line is the one
// stzSecurityEvent.CanonicalString writes for an observed fact.

var door_records: f64 = 0;

fn noPipe(out: *std.ArrayList(u8), a: std.mem.Allocator, field: []const u8) !void {
    for (field) |ch| try out.append(a, if (ch == '|') '/' else ch);
}

fn doorFact(kind: []const u8, actor: []const u8, subject: []const u8, origin: []const u8, what: []const u8) !void {
    if (seclog.seclog_current() == null) {
        // no Ring id here: under Ring++ a DLL the door loaded itself has no host
        // table until rnxc initialises it, and asking for one crashed (0x50).
        // ring_SecLogCurrent mints the id the first time Ring asks.
        const sl = seclog.seclog_create(4096) orelse return error.OutOfMemory;
        seclog.seclog_set_current(sl);
    }
    const a = std.heap.c_allocator;
    var line: std.ArrayList(u8) = .empty;
    defer line.deinit(a);
    const wall = std.time.milliTimestamp();
    // kind|severity|actor|posture|action|risk|subject|origin|outcome|reason|atWall|traceId
    try noPipe(&line, a, kind);
    try line.appendSlice(a, "|info|");
    try noPipe(&line, a, actor);
    try line.appendSlice(a, "|||0|");
    try noPipe(&line, a, subject);
    try line.append(a, '|');
    try noPipe(&line, a, origin);
    try line.appendSlice(a, "|observed|");
    try noPipe(&line, a, what);
    try line.writer(a).print("|{d}|", .{wall});
    seclog.seclog_current_append(line.items.ptr, line.items.len, @floatFromInt(wall), 0);
    door_records += 1;
}

/// The exported door: 1 when the record was written, 0 when it could not be.
fn stz_seclog_door_fact(
    kind: [*]const u8, kind_len: usize,
    actor: [*]const u8, actor_len: usize,
    subject: [*]const u8, subject_len: usize,
    origin: [*]const u8, origin_len: usize,
    what: [*]const u8, what_len: usize,
) callconv(.c) i32 {
    doorFact(kind[0..kind_len], actor[0..actor_len], subject[0..subject_len], origin[0..origin_len], what[0..what_len]) catch return 0;
    return 1;
}

/// The exported shut-list query (SECURITY-R18c): the advisory that shut the door
/// of this kind to this name, copied into out; its length, or -1 when the door
/// is open. An engine domain asks this before it acts (seclog_door.isShut).
fn stz_seclog_door_shut_query(
    kind: [*]const u8, kind_len: usize,
    name: [*]const u8, name_len: usize,
    out: [*]u8, out_cap: usize,
) callconv(.c) i32 {
    const got = shutlist.query(kind[0..kind_len], name[0..name_len], out[0..out_cap]) orelse return -1;
    return @intCast(got.len);
}

comptime {
    @export(&stz_seclog_door_fact, .{ .name = "stz_seclog_door_fact" });
    @export(&stz_seclog_door_shut_query, .{ .name = "stz_seclog_door_shut_query" });
}

// StzEngineSecLogDoorShut(cKind, cName, cAdvisoryId) -> 1 when the door is in the
// engine's shut list, 0 when refused (an empty or oversized field, a full table)
fn ring_SecLogDoorShut(p: *anyopaque) callconv(.c) void {
    const k = gs(p, 1)[0..@intCast(gss(p, 1))];
    const n = gs(p, 2)[0..@intCast(gss(p, 2))];
    const a = gs(p, 3)[0..@intCast(gss(p, 3))];
    rn(p, if (shutlist.shut(k, n, a)) 1 else 0);
}

// StzEngineSecLogDoorReopen(cAdvisoryId) -> how many doors that advisory had shut
fn ring_SecLogDoorReopen(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(shutlist.reopen(gs(p, 1)[0..@intCast(gss(p, 1))])));
}

// StzEngineSecLogDoorIsShut(cKind, cName) -> the advisory that shut it, or ""
fn ring_SecLogDoorIsShut(p: *anyopaque) callconv(.c) void {
    var buf: [64]u8 = undefined;
    const got = shutlist.query(gs(p, 1)[0..@intCast(gss(p, 1))], gs(p, 2)[0..@intCast(gss(p, 2))], &buf) orelse {
        rs(p, "");
        return;
    };
    rs2(p, got.ptr, @intCast(got.len));
}

// StzEngineSecLogDoorShutCount() -> rows in the engine's shut list
fn ring_SecLogDoorShutCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(shutlist.count()));
}

// StzEngineSecLogDoorRecords() -> records written through the engine door in this process
fn ring_SecLogDoorRecords(p: *anyopaque) callconv(.c) void {
    rn(p, door_records);
}

pub const regs = [_]R.Reg{
    .{ .name = "stzengineseclogdoorrecords", .func = &ring_SecLogDoorRecords },
    .{ .name = "stzengineseclogdoorshut", .func = &ring_SecLogDoorShut },
    .{ .name = "stzengineseclogdoorreopen", .func = &ring_SecLogDoorReopen },
    .{ .name = "stzengineseclogdoorisshut", .func = &ring_SecLogDoorIsShut },
    .{ .name = "stzengineseclogdoorshutcount", .func = &ring_SecLogDoorShutCount },
    .{ .name = "stzengineseclogsetcurrent", .func = &ring_SecLogSetCurrent },
    .{ .name = "stzengineseclogclearcurrent", .func = &ring_SecLogClearCurrent },
    .{ .name = "stzenginesecloghascurrent", .func = &ring_SecLogHasCurrent },
    .{ .name = "stzengineseclogcurrent", .func = &ring_SecLogCurrent },
    .{ .name = "stzengineseclogcurrentappend", .func = &ring_SecLogCurrentAppend },
    .{ .name = "stzengineseclogcreate", .func = &ring_SecLogCreate },
    .{ .name = "stzengineseclogattach", .func = &ring_SecLogAttach },
    .{ .name = "stzengineseclogverifydurable", .func = &ring_SecLogVerifyDurable },
    .{ .name = "stzengineseclogisdurable", .func = &ring_SecLogIsDurable },
    .{ .name = "stzengineseclogdurableerrors", .func = &ring_SecLogDurableErrors },
    .{ .name = "stzengineseclogappend", .func = &ring_SecLogAppend },
    .{ .name = "stzengineseclogcount", .func = &ring_SecLogCount },
    .{ .name = "stzengineseclogsize", .func = &ring_SecLogSize },
    .{ .name = "stzengineseclogcapacity", .func = &ring_SecLogCapacity },
    .{ .name = "stzengineseclogcanonicalat", .func = &ring_SecLogCanonicalAt },
    .{ .name = "stzengineseclogdigestat", .func = &ring_SecLogDigestAt },
    .{ .name = "stzengineseclogheaddigest", .func = &ring_SecLogHeadDigest },
    .{ .name = "stzengineseclogwallat", .func = &ring_SecLogWallAt },
    .{ .name = "stzengineseclogseverityat", .func = &ring_SecLogSeverityAt },
    .{ .name = "stzengineseclogverify", .func = &ring_SecLogVerify },
    .{ .name = "stzengineseclogverifyanchor", .func = &ring_SecLogVerifyAnchor },
    .{ .name = "stzengineseclogsetrefusalbudget", .func = &ring_SecLogSetRefusalBudget },
    .{ .name = "stzengineseclogbudgetmax", .func = &ring_SecLogBudgetMax },
    .{ .name = "stzengineseclogbudgetwindow", .func = &ring_SecLogBudgetWindow },
    .{ .name = "stzengineseclogsuppressed", .func = &ring_SecLogSuppressed },
    .{ .name = "stzengineseclogflushbudget", .func = &ring_SecLogFlushBudget },
    .{ .name = "stzengineseclogreset", .func = &ring_SecLogReset },
    .{ .name = "stzengineseclogdestroy", .func = &ring_SecLogDestroy },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
