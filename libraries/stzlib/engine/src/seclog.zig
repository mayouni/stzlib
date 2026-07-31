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

const gpa = std.heap.c_allocator;

const CANON_MAX = 512;
const DIGEST_LEN = 64; // sha256 hex

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

pub fn seclog_append(s_opt: ?*SecLog, canonical: [*]const u8, canonical_len: usize, wall_ms: f64, severity: f64) callconv(.c) void {
    const s = s_opt orelse return;
    s.mutex.lock();
    defer s.mutex.unlock();
    var cl = canonical_len;
    if (cl > CANON_MAX) cl = CANON_MAX;
    const h = s.head;
    @memcpy(s.canon[h * CANON_MAX ..][0..cl], canonical[0..cl]);
    s.canon_lens[h] = @intCast(cl);
    var d: [DIGEST_LEN]u8 = undefined;
    chainDigest(&s.head_digest, canonical[0..cl], &d);
    @memcpy(s.digests[h * DIGEST_LEN ..][0..DIGEST_LEN], &d);
    s.head_digest = d;
    s.wall[h] = wall_ms;
    s.sev[h] = @intFromFloat(severity);
    s.head = (s.head + 1) % s.cap;
    s.count += 1;
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
