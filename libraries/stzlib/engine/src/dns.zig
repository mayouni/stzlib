// DNS cache with TTL.
//
// Gap-analysis Tier 1 item 3. Every connection open in httpcore.connect
// (and tcp.tcp_connect) resolves the host first. A small cache keyed by
// "host|port" saves the resolver round-trip (typically 1-10ms, more on a
// cold cache or slow resolver) on the hot path of repeated requests to
// the same host.
//
//   lookup(host, port) -> std.net.Address
//     * cache hit (fresh)  -> return the stored address, no resolve
//     * cache miss/expired -> std.net.getAddressList, store first result
//     * negative caching    -> a failed resolve is cached briefly so a
//        broken resolver is not hammered on every retry
//
// Positive entries live `positive_ttl_ms` (default 60s); negative
// entries live `negative_ttl_ms` (default 5s). The cache is mutex-
// guarded; the actual resolve happens OUTSIDE the lock so a slow lookup
// for one host does not block lookups for others (two threads racing the
// same cold host simply both resolve and store -- harmless).
//
// Each DLL that imports this module gets its own cache instance; that is
// intentional -- the http path (stz_http) and the tcp path (stz_tcp)
// each cache their own lookups.

const std = @import("std");

const gpa = std.heap.c_allocator;

pub const LookupError = error{DnsFailed};

const Entry = struct {
    addr: std.net.Address,
    expiry_ns: i128,
    ok: bool, // false = negative (failed-lookup) entry
};

var cache: std.StringHashMap(Entry) = undefined;
var initialized: bool = false;
var mutex: std.Thread.Mutex = .{};

pub var positive_ttl_ms: u64 = 60_000;
pub var negative_ttl_ms: u64 = 5_000;

// Diagnostics -- atomic so the counters are race-free even though the
// hot path touches them outside the cache mutex.
pub var resolve_count = std.atomic.Value(u64).init(0); // real getAddressList calls
pub var hit_count = std.atomic.Value(u64).init(0); // cache short-circuits

const ZERO_ADDR = std.net.Address.initIp4(.{ 0, 0, 0, 0 }, 0);

fn ensureInit() void {
    if (!initialized) {
        cache = std.StringHashMap(Entry).init(gpa);
        initialized = true;
    }
}

fn makeKey(buf: []u8, host: []const u8, port: u16) []const u8 {
    return std.fmt.bufPrint(buf, "{s}|{d}", .{ host, port }) catch host;
}

pub fn lookup(host: []const u8, port: u16) LookupError!std.net.Address {
    var key_buf: [320]u8 = undefined;
    const key = makeKey(&key_buf, host, port);
    const now = std.time.nanoTimestamp();

    mutex.lock();
    ensureInit();
    if (cache.get(key)) |e| {
        if (now < e.expiry_ns) {
            const ok = e.ok;
            const addr = e.addr;
            mutex.unlock();
            _ = hit_count.fetchAdd(1, .monotonic);
            if (ok) return addr;
            return error.DnsFailed; // fresh negative entry
        }
    }
    mutex.unlock();

    // Resolve outside the lock.
    _ = resolve_count.fetchAdd(1, .monotonic);
    if (std.net.getAddressList(gpa, host, port)) |list| {
        defer list.deinit();
        if (list.addrs.len == 0) {
            store(key, ZERO_ADDR, false);
            return error.DnsFailed;
        }
        const addr = list.addrs[0];
        store(key, addr, true);
        return addr;
    } else |_| {
        store(key, ZERO_ADDR, false);
        return error.DnsFailed;
    }
}

fn store(key: []const u8, addr: std.net.Address, ok: bool) void {
    mutex.lock();
    defer mutex.unlock();
    ensureInit();
    const ttl_ms = if (ok) positive_ttl_ms else negative_ttl_ms;
    const expiry = std.time.nanoTimestamp() + @as(i128, @intCast(ttl_ms)) * 1_000_000;
    const gop = cache.getOrPut(key) catch return;
    if (!gop.found_existing) {
        const owned = gpa.dupe(u8, key) catch {
            _ = cache.remove(key);
            return;
        };
        gop.key_ptr.* = owned;
    }
    gop.value_ptr.* = .{ .addr = addr, .expiry_ns = expiry, .ok = ok };
}

/// Drop every cached entry (positive and negative).
pub fn clear() void {
    mutex.lock();
    defer mutex.unlock();
    if (!initialized) return;
    var it = cache.keyIterator();
    while (it.next()) |k| gpa.free(k.*);
    cache.clearRetainingCapacity();
}

// ── tests ────────────────────────────────────────────────────
// These use 127.0.0.1 (an IP literal -- resolved without a network
// query) so they are deterministic and network-free. Not part of the
// default `zig build test` sweep (dns is not imported by engine.zig);
// run via `zig test src/dns.zig`.

test "dns: cache hit does not re-resolve" {
    clear();
    resolve_count.store(0, .monotonic);
    hit_count.store(0, .monotonic);

    _ = try lookup("127.0.0.1", 80);
    try std.testing.expectEqual(@as(u64, 1), resolve_count.load(.monotonic));

    _ = try lookup("127.0.0.1", 80);
    // Second call is a cache hit -- resolve count must not move.
    try std.testing.expectEqual(@as(u64, 1), resolve_count.load(.monotonic));
    try std.testing.expectEqual(@as(u64, 1), hit_count.load(.monotonic));
}

test "dns: expiry forces a re-resolve" {
    clear();
    resolve_count.store(0, .monotonic);
    const saved = positive_ttl_ms;
    defer positive_ttl_ms = saved;

    positive_ttl_ms = 0; // entries are born already expired
    _ = try lookup("127.0.0.1", 80);
    _ = try lookup("127.0.0.1", 80);
    try std.testing.expectEqual(@as(u64, 2), resolve_count.load(.monotonic));
}

test "dns: negative cache short-circuits a failed lookup" {
    clear();
    resolve_count.store(0, .monotonic);

    const bad = "no.such.host.invalid";
    try std.testing.expectError(error.DnsFailed, lookup(bad, 80));
    const after_first = resolve_count.load(.monotonic);
    try std.testing.expectEqual(@as(u64, 1), after_first);

    // Second failed lookup within negative_ttl_ms must be a cache hit.
    try std.testing.expectError(error.DnsFailed, lookup(bad, 80));
    try std.testing.expectEqual(after_first, resolve_count.load(.monotonic));
}
