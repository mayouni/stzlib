// HTTP connection pool keyed by (scheme, host, port).
//
// Gap-analysis Tier 1 item 2. Keeps httpcore.Connection structs alive
// between requests so the TCP + TLS handshake (the expensive part of an
// HTTPS request) is paid once per host, not once per request.
//
//   acquire(host, port, is_tls) -> reuse a warm idle connection for the
//     same key, or open a fresh one (subject to per-host + global caps).
//   release(conn, reusable)     -> return a still-good connection to the
//     idle list with a refreshed idle clock; close it if not reusable.
//   evict                       -> close connections idle longer than
//     idle_timeout_ms (run on every acquire, and on demand).
//
// Stats: total_opens, total_reuses, current_idle, current_active.
//
// Scale note: the idle list is a flat ArrayList scanned linearly. Pools
// here are bounded (max_total default 256) so linear scan is cheap; the
// 10k-connection reactor is a separate Tier 2 arc.

const std = @import("std");
const httpcore = @import("httpcore.zig");

const gpa = std.heap.c_allocator;

var last_error_buf: [512]u8 = undefined;
var last_error_len: usize = 0;

fn setError(msg: []const u8) void {
    const n = @min(msg.len, last_error_buf.len);
    @memcpy(last_error_buf[0..n], msg[0..n]);
    last_error_len = n;
}

fn clearError() void {
    last_error_len = 0;
}

pub fn pool_last_error_len() usize {
    return last_error_len;
}

pub fn pool_last_error(out: [*]u8, max: usize) i32 {
    const n = @min(last_error_len, max);
    if (n == 0) return 0;
    @memcpy(out[0..n], last_error_buf[0..n]);
    return @intCast(n);
}

pub const Pool = struct {
    mutex: std.Thread.Mutex,
    idle: std.ArrayList(*httpcore.Connection),
    // per-key count of connections currently checked out (active).
    active_by_key: std.StringHashMap(usize),
    active_total: usize,

    idle_timeout_ms: u64,
    max_per_host: usize,
    max_total: usize,

    total_opens: u64,
    total_reuses: u64,
};

fn keyMatch(c: *httpcore.Connection, host: []const u8, port: u16, is_tls: bool) bool {
    return c.is_tls == is_tls and c.port == port and std.mem.eql(u8, c.host, host);
}

/// "scheme|host|port" -- the per-host accounting key.
fn makeKey(buf: []u8, host: []const u8, port: u16, is_tls: bool) []const u8 {
    return std.fmt.bufPrint(buf, "{s}|{s}|{d}", .{
        if (is_tls) "https" else "http",
        host,
        port,
    }) catch host;
}

pub fn create(idle_timeout_ms: u64, max_per_host: usize, max_total: usize) ?*Pool {
    clearError();
    const p = gpa.create(Pool) catch {
        setError("oom (pool)");
        return null;
    };
    p.* = .{
        .mutex = .{},
        .idle = .{},
        .active_by_key = std.StringHashMap(usize).init(gpa),
        .active_total = 0,
        .idle_timeout_ms = if (idle_timeout_ms == 0) 60_000 else idle_timeout_ms,
        .max_per_host = if (max_per_host == 0) 16 else max_per_host,
        .max_total = if (max_total == 0) 256 else max_total,
        .total_opens = 0,
        .total_reuses = 0,
    };
    return p;
}

fn keyCount(p: *Pool, host: []const u8, port: u16, is_tls: bool) usize {
    var key_buf: [320]u8 = undefined;
    const key = makeKey(&key_buf, host, port, is_tls);
    var n: usize = p.active_by_key.get(key) orelse 0;
    for (p.idle.items) |c| {
        if (keyMatch(c, host, port, is_tls)) n += 1;
    }
    return n;
}

fn bumpActive(p: *Pool, host: []const u8, port: u16, is_tls: bool, delta: i64) void {
    var key_buf: [320]u8 = undefined;
    const key = makeKey(&key_buf, host, port, is_tls);
    if (delta > 0) {
        const gop = p.active_by_key.getOrPut(key) catch return;
        if (!gop.found_existing) {
            // Own the key string.
            const owned = gpa.dupe(u8, key) catch {
                _ = p.active_by_key.remove(key);
                return;
            };
            gop.key_ptr.* = owned;
            gop.value_ptr.* = 0;
        }
        gop.value_ptr.* += @intCast(delta);
        p.active_total += @intCast(delta);
    } else {
        if (p.active_by_key.getEntry(key)) |e| {
            const dec: usize = @intCast(-delta);
            if (e.value_ptr.* <= dec) {
                const owned_key = e.key_ptr.*;
                _ = p.active_by_key.remove(key);
                gpa.free(owned_key);
            } else {
                e.value_ptr.* -= dec;
            }
            if (p.active_total >= dec) p.active_total -= dec;
        }
    }
}

/// Close every idle connection older than idle_timeout_ms. Caller holds
/// the mutex. Returns the number evicted.
fn evictLocked(p: *Pool) usize {
    const now = std.time.nanoTimestamp();
    const ttl_ns: i128 = @as(i128, @intCast(p.idle_timeout_ms)) * 1_000_000;
    var evicted: usize = 0;
    var i: usize = 0;
    while (i < p.idle.items.len) {
        const c = p.idle.items[i];
        if (now - c.last_used_ns >= ttl_ns) {
            _ = p.idle.swapRemove(i);
            httpcore.close(c);
            evicted += 1;
        } else {
            i += 1;
        }
    }
    return evicted;
}

/// Acquire a connection for (host, port, is_tls): reuse a warm idle one
/// or open a fresh one. Returns null on cap-exceeded or connect failure
/// (reason in last_error).
pub fn acquire(
    p: *Pool,
    host: []const u8,
    port: u16,
    is_tls: bool,
    connect_timeout_ms: u32,
) ?*httpcore.Connection {
    clearError();

    p.mutex.lock();
    _ = evictLocked(p);

    // Reuse newest matching idle connection (LIFO keeps the warmest hot).
    var i: usize = p.idle.items.len;
    while (i > 0) {
        i -= 1;
        const c = p.idle.items[i];
        if (keyMatch(c, host, port, is_tls)) {
            _ = p.idle.swapRemove(i);
            bumpActive(p, host, port, is_tls, 1);
            p.total_reuses += 1;
            p.mutex.unlock();
            return c;
        }
    }

    // Capacity check before opening a new connection.
    if (p.active_total + p.idle.items.len >= p.max_total) {
        p.mutex.unlock();
        setError("pool at global max connections");
        return null;
    }
    if (keyCount(p, host, port, is_tls) >= p.max_per_host) {
        p.mutex.unlock();
        setError("pool at per-host max connections");
        return null;
    }

    // Reserve the slot as active while we connect (outside the lock so a
    // slow handshake does not block other hosts).
    bumpActive(p, host, port, is_tls, 1);
    p.mutex.unlock();

    const c = httpcore.connect(host, port, is_tls, connect_timeout_ms) catch |err| {
        p.mutex.lock();
        bumpActive(p, host, port, is_tls, -1);
        p.mutex.unlock();
        var fbuf: [200]u8 = undefined;
        const msg = std.fmt.bufPrint(&fbuf, "connect failed: {s}", .{@errorName(err)}) catch "connect failed";
        setError(msg);
        return null;
    };

    p.mutex.lock();
    p.total_opens += 1;
    p.mutex.unlock();
    return c;
}

/// Return a connection. If `reusable`, it goes back to the idle list with
/// a refreshed clock; otherwise it is closed.
pub fn release(p: *Pool, c: *httpcore.Connection, reusable: bool) void {
    p.mutex.lock();
    bumpActive(p, c.host, c.port, c.is_tls, -1);
    if (reusable and !c.closing) {
        c.last_used_ns = std.time.nanoTimestamp();
        p.idle.append(gpa, c) catch {
            p.mutex.unlock();
            httpcore.close(c);
            return;
        };
        p.mutex.unlock();
    } else {
        p.mutex.unlock();
        httpcore.close(c);
    }
}

pub const Stats = struct {
    opens: u64,
    reuses: u64,
    idle: usize,
    active: usize,
};

pub fn stats(p: *Pool) Stats {
    p.mutex.lock();
    defer p.mutex.unlock();
    return .{
        .opens = p.total_opens,
        .reuses = p.total_reuses,
        .idle = p.idle.items.len,
        .active = p.active_total,
    };
}

/// Force-evict all idle connections older than the TTL. Returns count.
pub fn evict(p: *Pool) usize {
    p.mutex.lock();
    defer p.mutex.unlock();
    return evictLocked(p);
}

pub fn destroy(p: *Pool) void {
    p.mutex.lock();
    for (p.idle.items) |c| httpcore.close(c);
    p.idle.deinit(gpa);
    var it = p.active_by_key.iterator();
    while (it.next()) |e| gpa.free(e.key_ptr.*);
    p.active_by_key.deinit();
    p.mutex.unlock();
    gpa.destroy(p);
}

// ── tests ────────────────────────────────────────────────────

test "http_pool: create + destroy + empty stats" {
    const p = create(60_000, 16, 256).?;
    defer destroy(p);
    const s = stats(p);
    try std.testing.expectEqual(@as(u64, 0), s.opens);
    try std.testing.expectEqual(@as(u64, 0), s.reuses);
    try std.testing.expectEqual(@as(usize, 0), s.idle);
    try std.testing.expectEqual(@as(usize, 0), s.active);
}

test "http_pool: defaults applied on zero" {
    const p = create(0, 0, 0).?;
    defer destroy(p);
    try std.testing.expectEqual(@as(u64, 60_000), p.idle_timeout_ms);
    try std.testing.expectEqual(@as(usize, 16), p.max_per_host);
    try std.testing.expectEqual(@as(usize, 256), p.max_total);
}
