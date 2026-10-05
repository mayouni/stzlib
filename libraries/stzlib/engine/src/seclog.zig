// The security event ledger -- incident analysis I1.
//
// Evidence, not logging. A bounded ring of canonical event lines, each
// carrying a digest that includes THE PREVIOUS DIGEST:
//
//     digest[i] = sha256( digest[i-1] || "|" || canonical[i] )
//
// so a retroactive edit to any entry invalidates every digest after it
// and `seclog_verify` names the first broken link. The chain is
// computed HERE, never handed in from the host: a caller that could
// supply its own digest could forge history. (An in-process attacker
// can still append or wipe the whole ring -- see the honest limits in
// SOFTANZA_INCIDENT_ANALYSIS.md; that is what the keyed export seal is
// for.)
//
// Storage is fixed slabs, oldest overwritten past capacity -- the house
// bounded-store law. One canonical string per entry (pipe-separated
// fields, escaped host-side) plus its digest; the host reconstructs the
// record by splitting, so the engine stays free of field semantics.
//
// Handle-backed for the copy law: the seam face appends, the analyst
// face reads, one truth.

const std = @import("std");
const crypto = @import("crypto.zig");
const durable = @import("seclog_durable.zig");

const gpa = std.heap.c_allocator;

const CANON_MAX = 512;
const DIGEST_LEN = 64; // sha256 hex

// -- The refusal budget (SECURITY-LEDGERFLOOD-01) --------------------------
//
// A refusal is written by whoever is REFUSED, and some of them are
// strangers: anyone who can reach a webhook callback can make the signer
// refuse, and each refusal is a line. Measured 2026-10-05: 1,100 forged
// webhooks took 1.7 s and pushed every earlier event out of a 1,024-entry
// window. So a refused or failed outcome spends a budget PER KIND: at most
// `budget_max` lines of one kind per `budget_window` ms. Past it, one
// marker line says the budget was reached, further refusals of that kind
// are COUNTED, not written, and when the window rolls one summary line
// carries the count. A flood of one kind can no longer evict other kinds'
// evidence, and nothing is lost silently: the count is in the chain.
// Grants and observations are never budgeted. Replay from the durable file
// bypasses it: history is restored as it was written.
const BUDGET_SLOTS = 64;
const KIND_MAX = 64;

const BudgetSlot = struct {
    kind: [KIND_MAX]u8 = undefined,
    kind_len: usize = 0,
    start: f64 = 0,
    recorded: u32 = 0,
    suppressed: u32 = 0,
    used: bool = false,
};

pub const SecLog = struct {
    canon: []u8, // cap * CANON_MAX
    canon_lens: []u16,
    digests: []u8, // cap * DIGEST_LEN
    wall: []f64,
    sev: []u8, // 0 info, 1 warning, 2 error
    cap: usize,
    count: u64, // ever appended
    head: usize, // next write slot
    head_digest: [DIGEST_LEN]u8, // chain head (survives eviction)
    mutex: std.Thread.Mutex,
    store: ?durable.Store = null, // the durable log, when attached (rung 2)
    durable_errors: u64 = 0, // writes the durable log refused
    budget_max: u32 = 64, // refusal lines of one kind per window; 0 = no budget
    budget_window: f64 = 60000, // ms
    slots: [BUDGET_SLOTS]BudgetSlot = [_]BudgetSlot{.{}} ** BUDGET_SLOTS,
    suppressed_total: u64 = 0, // refusals counted rather than written, ever

    fn size(self: *const SecLog) usize {
        if (self.count < self.cap) return @intCast(self.count);
        return self.cap;
    }

    fn phys(self: *const SecLog, i: usize) usize {
        if (self.count < self.cap) return i;
        return (self.head + i) % self.cap;
    }
};

pub fn seclog_create(cap_f: f64) callconv(.c) ?*SecLog {
    if (cap_f < 1) return null;
    const cap: usize = @intFromFloat(cap_f);
    const s = gpa.create(SecLog) catch return null;
    const canon = gpa.alloc(u8, cap * CANON_MAX) catch {
        gpa.destroy(s);
        return null;
    };
    const canon_lens = gpa.alloc(u16, cap) catch {
        gpa.free(canon);
        gpa.destroy(s);
        return null;
    };
    const digests = gpa.alloc(u8, cap * DIGEST_LEN) catch {
        gpa.free(canon_lens);
        gpa.free(canon);
        gpa.destroy(s);
        return null;
    };
    const wall = gpa.alloc(f64, cap) catch {
        gpa.free(digests);
        gpa.free(canon_lens);
        gpa.free(canon);
        gpa.destroy(s);
        return null;
    };
    const sev = gpa.alloc(u8, cap) catch {
        gpa.free(wall);
        gpa.free(digests);
        gpa.free(canon_lens);
        gpa.free(canon);
        gpa.destroy(s);
        return null;
    };
    s.* = .{
        .canon = canon,
        .canon_lens = canon_lens,
        .digests = digests,
        .wall = wall,
        .sev = sev,
        .cap = cap,
        .count = 0,
        .head = 0,
        .head_digest = [_]u8{'0'} ** DIGEST_LEN, // genesis
        .mutex = .{},
    };
    return s;
}

// digest = sha256(prev_hex || "|" || canonical)
fn chainDigest(prev: []const u8, canonical: []const u8, out: *[DIGEST_LEN]u8) void {
    var buf: [DIGEST_LEN + 1 + CANON_MAX]u8 = undefined;
    var n: usize = 0;
    @memcpy(buf[0..prev.len], prev);
    n += prev.len;
    buf[n] = '|';
    n += 1;
    var cl = canonical.len;
    if (cl > CANON_MAX) cl = CANON_MAX;
    @memcpy(buf[n..][0..cl], canonical[0..cl]);
    n += cl;
    _ = crypto.crypto_sha256(&buf, n, out);
}

// The ring half of an append: chain the entry onto the head and store it
// in the window. The CALLER HOLDS the mutex. Returns the new digest.
fn appendMem(s: *SecLog, canonical: []const u8, wall_ms: f64, sev: u8) [DIGEST_LEN]u8 {
    var cl = canonical.len;
    if (cl > CANON_MAX) cl = CANON_MAX;
    const h = s.head;
    @memcpy(s.canon[h * CANON_MAX ..][0..cl], canonical[0..cl]);
    s.canon_lens[h] = @intCast(cl);
    var d: [DIGEST_LEN]u8 = undefined;
    chainDigest(&s.head_digest, canonical[0..cl], &d);
    @memcpy(s.digests[h * DIGEST_LEN ..][0..DIGEST_LEN], &d);
    s.head_digest = d;
    s.wall[h] = wall_ms;
    s.sev[h] = sev;
    s.head = (s.head + 1) % s.cap;
    s.count += 1;
    return d;
}

// One entry into the ring and, when attached, the durable log. The CALLER
// HOLDS the mutex.
fn writeEntry(s: *SecLog, canonical: []const u8, wall_ms: f64, sev: u8) void {
    const d = appendMem(s, canonical, wall_ms, sev);
    // write-through, in the same lock, so disk order IS chain order
    if (s.store) |st| {
        if (!durable.insert(st, s.count, wall_ms, sev, canonical, &d)) s.durable_errors += 1;
    }
}

// Field i (0-based) of a pipe-separated canonical line.
fn field(canonical: []const u8, i: usize) []const u8 {
    var it = std.mem.splitScalar(u8, canonical, '|');
    var k: usize = 0;
    while (it.next()) |f| : (k += 1) {
        if (k == i) return f;
    }
    return "";
}

// The kind, when this entry spends the refusal budget; null otherwise.
fn budgetedKind(canonical: []const u8) ?[]const u8 {
    const outcome = field(canonical, 8);
    if (!std.mem.eql(u8, outcome, "refused") and !std.mem.eql(u8, outcome, "failed")) return null;
    const k = field(canonical, 0);
    if (k.len == 0) return null;
    if (k.len > KIND_MAX) return k[0..KIND_MAX];
    return k;
}

// A line the LEDGER writes about itself: same kind, outcome "observed",
// actor "ledger", so a reader filtering by kind still finds it.
fn writeNote(s: *SecLog, kind: []const u8, wall_ms: f64, comptime fmt: []const u8, args: anytype) void {
    var reason: [256]u8 = undefined;
    const r = std.fmt.bufPrint(&reason, fmt, args) catch return;
    var buf: [CANON_MAX]u8 = undefined;
    const wall_i: i64 = @intFromFloat(wall_ms);
    const c = std.fmt.bufPrint(&buf, "{s}|warning|ledger|engine|record|0|budget:{s}|engine|observed|{s}|{d}|", .{ kind, kind, r, wall_i }) catch return;
    writeEntry(s, c, wall_ms, 1);
}

fn writeSummary(s: *SecLog, slot: *BudgetSlot, wall_ms: f64) void {
    if (slot.suppressed == 0) return;
    writeNote(s, slot.kind[0..slot.kind_len], wall_ms,
        "{d} further refusal(s) of this kind were counted, not recorded one by one (budget {d} per {d} ms)",
        .{ slot.suppressed, s.budget_max, @as(i64, @intFromFloat(s.budget_window)) });
}

fn slotFor(s: *SecLog, kind: []const u8, wall_ms: f64) *BudgetSlot {
    var free: ?*BudgetSlot = null;
    var oldest: *BudgetSlot = &s.slots[0];
    for (&s.slots) |*sl| {
        if (sl.used and std.mem.eql(u8, sl.kind[0..sl.kind_len], kind)) return sl;
        if (!sl.used and free == null) free = sl;
        if (sl.used and sl.start < oldest.start) oldest = sl;
    }
    const sl = free orelse blk: {
        // every slot is taken: the oldest window closes now, with its count
        writeSummary(s, oldest, wall_ms);
        break :blk oldest;
    };
    @memcpy(sl.kind[0..kind.len], kind);
    sl.kind_len = kind.len;
    sl.start = wall_ms;
    sl.recorded = 0;
    sl.suppressed = 0;
    sl.used = true;
    return sl;
}

pub fn seclog_append(s_opt: ?*SecLog, canonical: [*]const u8, canonical_len: usize, wall_ms: f64, severity: f64) callconv(.c) void {
    const s = s_opt orelse return;
    s.mutex.lock();
    defer s.mutex.unlock();
    var cl = canonical_len;
    if (cl > CANON_MAX) cl = CANON_MAX;
    const sev: u8 = @intFromFloat(severity);
    const line = canonical[0..cl];
    if (s.budget_max > 0) {
        if (budgetedKind(line)) |kind| {
            const sl = slotFor(s, kind, wall_ms);
            if (wall_ms - sl.start >= s.budget_window) {
                writeSummary(s, sl, wall_ms);
                sl.start = wall_ms;
                sl.recorded = 0;
                sl.suppressed = 0;
            }
            if (sl.recorded >= s.budget_max) {
                if (sl.suppressed == 0) {
                    writeNote(s, kind, wall_ms,
                        "budget reached: further refusals of this kind are counted, not recorded, until the window ends ({d} per {d} ms)",
                        .{ s.budget_max, @as(i64, @intFromFloat(s.budget_window)) });
                }
                sl.suppressed += 1;
                s.suppressed_total += 1;
                return;
            }
            sl.recorded += 1;
        }
    }
    writeEntry(s, line, wall_ms, sev);
}

// Set the refusal budget: at most max lines of one refused kind per
// window_ms. max = 0 turns it off (every refusal is written).
pub fn seclog_set_refusal_budget(s_opt: ?*SecLog, max_f: f64, window_f: f64) callconv(.c) void {
    const s = s_opt orelse return;
    s.mutex.lock();
    defer s.mutex.unlock();
    s.budget_max = if (max_f < 1) 0 else @intFromFloat(max_f);
    s.budget_window = if (window_f < 1) 1 else window_f;
}

pub fn seclog_budget_max(s_opt: ?*SecLog) callconv(.c) f64 {
    const s = s_opt orelse return 0;
    return @floatFromInt(s.budget_max);
}

pub fn seclog_budget_window(s_opt: ?*SecLog) callconv(.c) f64 {
    const s = s_opt orelse return 0;
    return s.budget_window;
}

pub fn seclog_suppressed(s_opt: ?*SecLog) callconv(.c) f64 {
    const s = s_opt orelse return 0;
    s.mutex.lock();
    defer s.mutex.unlock();
    return @floatFromInt(s.suppressed_total);
}

// Close every open window now: each kind with counted refusals gets its
// summary line. For a sentinel's tick, or before an export.
pub fn seclog_flush_budget(s_opt: ?*SecLog, wall_ms: f64) callconv(.c) void {
    const s = s_opt orelse return;
    s.mutex.lock();
    defer s.mutex.unlock();
    for (&s.slots) |*sl| {
        if (!sl.used) continue;
        writeSummary(s, sl, wall_ms);
        sl.used = false;
    }
}

// ── The durable log (HaroBase rung 2) ────────────────────────
//
// Attach BEFORE recording: the stored chain is replayed from genesis into
// this ledger and verified entry by entry; the ring then holds the most
// recent window and the chain resumes from the stored head. Returns the
// number of stored entries verified (>= 0), or:
//   -seq  the first stored entry that breaks the chain (edited, or a gap);
//         nothing is attached and the ledger is left empty
//   -1 000 000 001 / -002  the file could not be opened / read
//   -1 000 000 003  already attached    -1 000 000 004  not empty
const ReplayCtx = struct { s: *SecLog };
fn replayRow(ctx: ReplayCtx, row: durable.Row) bool {
    const d = appendMem(ctx.s, row.canonical, row.wall_ms, row.severity);
    return std.mem.eql(u8, &d, row.digest);
}

fn clearMem(s: *SecLog) void {
    s.count = 0;
    s.head = 0;
    s.head_digest = [_]u8{'0'} ** DIGEST_LEN;
}

pub fn seclog_attach(s_opt: ?*SecLog, path: [*:0]const u8) callconv(.c) f64 {
    const s = s_opt orelse return -1;
    s.mutex.lock();
    defer s.mutex.unlock();
    if (s.store != null) return -1_000_000_003;
    if (s.count != 0) return -1_000_000_004;
    const db = durable.open(path) orelse return @floatFromInt(durable.ERR_OPEN);
    const n = durable.walk(db, ReplayCtx{ .s = s }, replayRow);
    if (n < 0) {
        clearMem(s);
        _ = durable.c.sqlite3_close(db);
        return @floatFromInt(n);
    }
    const ins = durable.prepareInsert(db) orelse {
        clearMem(s);
        _ = durable.c.sqlite3_close(db);
        return @floatFromInt(durable.ERR_SCHEMA);
    };
    s.store = .{ .db = db, .ins = ins };
    return @floatFromInt(n);
}

// Re-verify the WHOLE stored history from genesis -- not the window.
// 0 intact, the 1-based seq of the first broken entry, or -1 (no durable
// log attached) / -2 (unreadable).
const VerifyCtx = struct { prev: *[DIGEST_LEN]u8 };
fn verifyRow(ctx: VerifyCtx, row: durable.Row) bool {
    var cl = row.canonical.len;
    if (cl > CANON_MAX) cl = CANON_MAX;
    var d: [DIGEST_LEN]u8 = undefined;
    chainDigest(ctx.prev, row.canonical[0..cl], &d);
    if (!std.mem.eql(u8, &d, row.digest)) return false;
    ctx.prev.* = d;
    return true;
}

pub fn seclog_verify_durable(s_opt: ?*SecLog) callconv(.c) f64 {
    const s = s_opt orelse return -1;
    s.mutex.lock();
    defer s.mutex.unlock();
    const st = s.store orelse return -1;
    var prev: [DIGEST_LEN]u8 = [_]u8{'0'} ** DIGEST_LEN;
    const n = durable.walk(st.db, VerifyCtx{ .prev = &prev }, verifyRow);
    if (n >= 0) return 0;
    if (n <= durable.ERR_OPEN) return -2;
    return @floatFromInt(-n);
}

// ── The anchor (threat-model R5) ─────────────────────────────
//
// A hash chain shows an EDIT, never a CUT: delete the last rows of the file
// and what remains is still a perfect chain from genesis, and someone with
// the file can even rebuild a whole new chain, since the chain has no key.
// An anchor is (count, head digest) taken at some moment and kept where the
// file's attacker cannot reach -- off the machine. This checks the stored
// chain against it: every link from genesis, AND entry `seq` still exists
// with the anchored digest. Returns
//    0  the anchor holds (the chain may have grown since: that is normal)
//   -1  this ledger is not durable          -2  the store cannot be read
//   -3  TRUNCATED: fewer stored entries than the anchor counted
//   -4  DIVERGED: entry `seq` exists with another digest -- history rewritten
//   >0  the chain itself breaks at that entry
const AnchorCtx = struct { prev: *[DIGEST_LEN]u8, seq: i64, want: []const u8, matched: *i8 };
fn anchorRow(ctx: AnchorCtx, row: durable.Row) bool {
    var cl = row.canonical.len;
    if (cl > CANON_MAX) cl = CANON_MAX;
    var d: [DIGEST_LEN]u8 = undefined;
    chainDigest(ctx.prev, row.canonical[0..cl], &d);
    if (!std.mem.eql(u8, &d, row.digest)) return false;
    ctx.prev.* = d;
    if (row.seq == ctx.seq) ctx.matched.* = if (std.mem.eql(u8, row.digest, ctx.want)) 1 else -1;
    return true;
}

pub fn seclog_verify_anchor(s_opt: ?*SecLog, seq_f: f64, digest: [*]const u8, digest_len: usize) callconv(.c) f64 {
    const s = s_opt orelse return -1;
    s.mutex.lock();
    defer s.mutex.unlock();
    const st = s.store orelse return -1;
    if (seq_f < 1) return -3;
    var prev: [DIGEST_LEN]u8 = [_]u8{'0'} ** DIGEST_LEN;
    var matched: i8 = 0;
    const ctx = AnchorCtx{ .prev = &prev, .seq = @intFromFloat(seq_f), .want = digest[0..digest_len], .matched = &matched };
    const n = durable.walk(st.db, ctx, anchorRow);
    if (n <= durable.ERR_OPEN) return -2;
    if (n < 0) return @floatFromInt(-n);
    if (matched == 0) return -3;
    if (matched < 0) return -4;
    return 0;
}

pub fn seclog_is_durable(s_opt: ?*SecLog) callconv(.c) f64 {
    const s = s_opt orelse return 0;
    return if (s.store != null) 1 else 0;
}

pub fn seclog_durable_errors(s_opt: ?*SecLog) callconv(.c) f64 {
    const s = s_opt orelse return 0;
    return @floatFromInt(s.durable_errors);
}

pub fn seclog_count(s_opt: ?*SecLog) callconv(.c) f64 {
    const s = s_opt orelse return 0;
    s.mutex.lock();
    defer s.mutex.unlock();
    return @floatFromInt(s.count);
}

pub fn seclog_capacity(s_opt: ?*SecLog) callconv(.c) f64 {
    const s = s_opt orelse return 0;
    return @floatFromInt(s.cap);
}

pub fn seclog_size(s_opt: ?*SecLog) callconv(.c) f64 {
    const s = s_opt orelse return 0;
    s.mutex.lock();
    defer s.mutex.unlock();
    return @floatFromInt(s.size());
}

// 1-based, oldest retained first.
pub fn seclog_canonical_at(s_opt: ?*SecLog, i_f: f64, out: [*]u8, max: usize) callconv(.c) i32 {
    const s = s_opt orelse return 0;
    s.mutex.lock();
    defer s.mutex.unlock();
    if (i_f < 1 or i_f > @as(f64, @floatFromInt(s.size()))) return 0;
    const p = s.phys(@as(usize, @intFromFloat(i_f)) - 1);
    var l: usize = s.canon_lens[p];
    if (l > max) l = max;
    @memcpy(out[0..l], s.canon[p * CANON_MAX ..][0..l]);
    return @intCast(l);
}

pub fn seclog_digest_at(s_opt: ?*SecLog, i_f: f64, out: [*]u8, max: usize) callconv(.c) i32 {
    const s = s_opt orelse return 0;
    s.mutex.lock();
    defer s.mutex.unlock();
    if (i_f < 1 or i_f > @as(f64, @floatFromInt(s.size()))) return 0;
    const p = s.phys(@as(usize, @intFromFloat(i_f)) - 1);
    var l: usize = DIGEST_LEN;
    if (l > max) l = max;
    @memcpy(out[0..l], s.digests[p * DIGEST_LEN ..][0..l]);
    return @intCast(l);
}

pub fn seclog_head_digest(s_opt: ?*SecLog, out: [*]u8, max: usize) callconv(.c) i32 {
    const s = s_opt orelse return 0;
    s.mutex.lock();
    defer s.mutex.unlock();
    var l: usize = DIGEST_LEN;
    if (l > max) l = max;
    @memcpy(out[0..l], s.head_digest[0..l]);
    return @intCast(l);
}

pub fn seclog_wall_at(s_opt: ?*SecLog, i_f: f64) callconv(.c) f64 {
    const s = s_opt orelse return -1;
    s.mutex.lock();
    defer s.mutex.unlock();
    if (i_f < 1 or i_f > @as(f64, @floatFromInt(s.size()))) return -1;
    return s.wall[s.phys(@as(usize, @intFromFloat(i_f)) - 1)];
}

pub fn seclog_severity_at(s_opt: ?*SecLog, i_f: f64) callconv(.c) f64 {
    const s = s_opt orelse return -1;
    s.mutex.lock();
    defer s.mutex.unlock();
    if (i_f < 1 or i_f > @as(f64, @floatFromInt(s.size()))) return -1;
    return @floatFromInt(s.sev[s.phys(@as(usize, @intFromFloat(i_f)) - 1)]);
}

// Recompute the chain over the RETAINED window and return the 1-based
// index of the first entry whose stored digest disagrees, or 0 when the
// window is internally consistent. NOTE: after eviction the first
// retained entry's predecessor is gone, so verification starts from
// that entry's stored digest and checks the rest -- an honest window
// property, stated in the Ring wrapper's docs.
pub fn seclog_verify(s_opt: ?*SecLog) callconv(.c) f64 {
    const s = s_opt orelse return -1;
    s.mutex.lock();
    defer s.mutex.unlock();
    const n = s.size();
    if (n < 2) return 0;
    var i: usize = 1;
    while (i < n) : (i += 1) {
        const prev_p = s.phys(i - 1);
        const p = s.phys(i);
        var d: [DIGEST_LEN]u8 = undefined;
        chainDigest(s.digests[prev_p * DIGEST_LEN ..][0..DIGEST_LEN], s.canon[p * CANON_MAX ..][0..s.canon_lens[p]], &d);
        if (!std.mem.eql(u8, &d, s.digests[p * DIGEST_LEN ..][0..DIGEST_LEN])) {
            return @floatFromInt(i + 1); // 1-based index of the broken entry
        }
    }
    return 0;
}

pub fn seclog_reset(s_opt: ?*SecLog) callconv(.c) void {
    const s = s_opt orelse return;
    s.mutex.lock();
    defer s.mutex.unlock();
    // a durable ledger cannot restart its chain: the disk would continue
    // from the old head while the ring began again at genesis
    if (s.store != null) return;
    s.count = 0;
    s.head = 0;
    s.head_digest = [_]u8{'0'} ** DIGEST_LEN;
}

// ── The process ledger (I2) ──────────────────────────────────
//
// The seams live inside classes an application never constructs, so
// they need one ledger they can find. It lives HERE for the same
// reason the trace scope does (perf P9): a Ring-side "current
// ledger" is per-scope state that a function cannot reliably write,
// and a Ring copy of it would fork. Closed is the default, and closed
// costs one pointer test.

var g_current: ?*SecLog = null;

pub fn seclog_set_current(s_opt: ?*SecLog) callconv(.c) void {
    g_current = s_opt;
}

pub fn seclog_clear_current() callconv(.c) void {
    g_current = null;
}

pub fn seclog_has_current() callconv(.c) f64 {
    if (g_current == null) return 0;
    return 1;
}

pub fn seclog_current() callconv(.c) ?*SecLog {
    return g_current;
}

// Append to whichever ledger is current; a no-op when none is.
pub fn seclog_current_append(canonical: [*]const u8, canonical_len: usize, wall_ms: f64, severity: f64) callconv(.c) void {
    const s = g_current orelse return;
    seclog_append(s, canonical, canonical_len, wall_ms, severity);
}

pub fn seclog_destroy(s_opt: ?*SecLog) callconv(.c) void {
    if (g_current) |c| {
        if (c == s_opt) g_current = null; // never leave a dangling current
    }
    const s = s_opt orelse return;
    if (s.store) |st| durable.close(st);
    gpa.free(s.canon);
    gpa.free(s.canon_lens);
    gpa.free(s.digests);
    gpa.free(s.wall);
    gpa.free(s.sev);
    gpa.destroy(s);
}

// ── tests ────────────────────────────────────────────────────

test "seclog: append, read back, chain advances" {
    const s = seclog_create(8).?;
    defer seclog_destroy(s);
    seclog_append(s, "a|one", 5, 1000, 2);
    seclog_append(s, "b|two", 5, 1001, 1);
    try std.testing.expectEqual(@as(f64, 2), seclog_count(s));
    var buf: [512]u8 = undefined;
    const n = seclog_canonical_at(s, 1, &buf, buf.len);
    try std.testing.expectEqualStrings("a|one", buf[0..@intCast(n)]);
    var d1: [64]u8 = undefined;
    var d2: [64]u8 = undefined;
    _ = seclog_digest_at(s, 1, &d1, 64);
    _ = seclog_digest_at(s, 2, &d2, 64);
    try std.testing.expect(!std.mem.eql(u8, &d1, &d2));
    var head: [64]u8 = undefined;
    _ = seclog_head_digest(s, &head, 64);
    try std.testing.expectEqualStrings(&d2, &head);
    try std.testing.expectEqual(@as(f64, 0), seclog_verify(s));
    try std.testing.expectEqual(@as(f64, 2), seclog_severity_at(s, 1));
}

test "seclog: the chain depends on history" {
    const a = seclog_create(8).?;
    defer seclog_destroy(a);
    const b = seclog_create(8).?;
    defer seclog_destroy(b);
    seclog_append(a, "one", 3, 1, 0);
    seclog_append(a, "two", 3, 2, 0);
    seclog_append(b, "one-EDITED", 10, 1, 0);
    seclog_append(b, "two", 3, 2, 0);
    var da: [64]u8 = undefined;
    var db: [64]u8 = undefined;
    _ = seclog_head_digest(a, &da, 64);
    _ = seclog_head_digest(b, &db, 64);
    // same last entry, different history -> different head digest
    try std.testing.expect(!std.mem.eql(u8, &da, &db));
}

test "seclog: tampering with a stored entry is detected" {
    const s = seclog_create(8).?;
    defer seclog_destroy(s);
    seclog_append(s, "one", 3, 1, 0);
    seclog_append(s, "two", 3, 2, 0);
    seclog_append(s, "three", 5, 3, 0);
    try std.testing.expectEqual(@as(f64, 0), seclog_verify(s));
    // rewrite entry 2's canonical in place (what an editor would do)
    const forged = "two-EDITED";
    @memcpy(s.canon[1 * CANON_MAX ..][0..forged.len], forged);
    s.canon_lens[1] = forged.len;
    try std.testing.expectEqual(@as(f64, 2), seclog_verify(s));
}

test "seclog: the process ledger is opt-in and self-clearing" {
    try std.testing.expectEqual(@as(f64, 0), seclog_has_current());
    seclog_current_append("ignored", 7, 1, 0); // no ledger: a no-op
    const s = seclog_create(4).?;
    seclog_set_current(s);
    try std.testing.expectEqual(@as(f64, 1), seclog_has_current());
    seclog_current_append("noted", 5, 1, 0);
    try std.testing.expectEqual(@as(f64, 1), seclog_count(s));
    seclog_destroy(s); // destroying the current one clears it
    try std.testing.expectEqual(@as(f64, 0), seclog_has_current());
}

test "seclog: a flood of one refused kind cannot evict another kind's evidence" {
    const s = seclog_create(64).?;
    defer seclog_destroy(s);
    seclog_set_refusal_budget(s, 8, 60000);
    const real = "secret.reveal.refused|error|intruder||||secret:db||refused|real|1000|";
    seclog_append(s, real, real.len, 1000, 2);
    var i: usize = 0;
    while (i < 1000) : (i += 1) {
        const f = "webhook.signature.forged|error|hub||||body||refused|forged|1001|";
        seclog_append(s, f, f.len, 1001, 2);
    }
    // 1 real + 8 forged + 1 marker; 992 counted
    try std.testing.expectEqual(@as(f64, 10), seclog_count(s));
    try std.testing.expectEqual(@as(f64, 992), seclog_suppressed(s));
    var buf: [512]u8 = undefined;
    const n = seclog_canonical_at(s, 1, &buf, buf.len);
    try std.testing.expectEqualStrings(real, buf[0..@intCast(n)]);
    // the window rolls: one summary line carries the count, and recording resumes
    const g = "webhook.signature.forged|error|hub||||body||refused|forged|70000|";
    seclog_append(s, g, g.len, 70000, 2);
    try std.testing.expectEqual(@as(f64, 12), seclog_count(s));
    const m = seclog_canonical_at(s, 11, &buf, buf.len);
    try std.testing.expect(std.mem.indexOf(u8, buf[0..@intCast(m)], "992 further") != null);
    try std.testing.expectEqual(@as(f64, 0), seclog_verify(s));
}

test "seclog: grants are never budgeted, and a zero budget writes everything" {
    const s = seclog_create(64).?;
    defer seclog_destroy(s);
    seclog_set_refusal_budget(s, 2, 60000);
    var i: usize = 0;
    while (i < 5) : (i += 1) {
        const g = "secret.reveal.granted|info|ops||||secret:db||granted||1|";
        seclog_append(s, g, g.len, 1, 0);
    }
    try std.testing.expectEqual(@as(f64, 5), seclog_count(s));
    seclog_set_refusal_budget(s, 0, 60000);
    i = 0;
    while (i < 5) : (i += 1) {
        const f = "sig.signature.forged|error|x||||y||refused||2|";
        seclog_append(s, f, f.len, 2, 2);
    }
    try std.testing.expectEqual(@as(f64, 10), seclog_count(s));
    try std.testing.expectEqual(@as(f64, 0), seclog_suppressed(s));
}

test "seclog: ring evicts oldest, count keeps counting" {
    const s = seclog_create(2).?;
    defer seclog_destroy(s);
    seclog_append(s, "one", 3, 1, 0);
    seclog_append(s, "two", 3, 2, 0);
    seclog_append(s, "three", 5, 3, 0);
    try std.testing.expectEqual(@as(f64, 3), seclog_count(s));
    try std.testing.expectEqual(@as(f64, 2), seclog_size(s));
    var buf: [512]u8 = undefined;
    const n = seclog_canonical_at(s, 1, &buf, buf.len);
    try std.testing.expectEqualStrings("two", buf[0..@intCast(n)]);
}
