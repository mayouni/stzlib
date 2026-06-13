// Resilience primitives for web-scale + agentic workloads.
//
// Three patterns this module ships:
// * retry_delay_ms()       -- exponential backoff with full jitter
// * RateLimiter            -- token bucket with monotonic refill
// * CircuitBreaker         -- 3-state (closed / open / half_open)
//
// All state-bearing structures are thread-safe via internal mutex.
// Designed so the same handle is shared across thread-pool workers
// without a Ring-side critical section.

const std = @import("std");

const gpa = std.heap.c_allocator;

// ── Retry delay (pure) ──────────────────────────────────────
// Full-jitter exponential backoff per https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/
//
// delay = uniform(0, min(max_ms, base_ms * 2^attempt))
//
// `seed` is a caller-provided RNG seed (so the result is deterministic
// per (attempt, seed) pair -- useful for testing); when seed == 0 we
// fall back to the OS RNG.

pub fn retry_delay_ms(
    attempt: u32,
    base_ms: u64,
    max_ms: u64,
    seed: u64,
) callconv(.c) u64 {
    if (base_ms == 0) return 0;
    const cap = std.math.maxInt(u32);
    var window: u64 = base_ms;
    var a = attempt;
    while (a > 0) : (a -= 1) {
        if (window > max_ms / 2) {
            window = max_ms;
            break;
        }
        window *= 2;
    }
    if (window > max_ms) window = max_ms;
    if (window == 0) return 0;

    var prng = std.Random.DefaultPrng.init(if (seed == 0) blk: {
        var b: u64 = undefined;
        std.crypto.random.bytes(std.mem.asBytes(&b));
        break :blk b;
    } else seed);
    const r = prng.random();
    const result = r.intRangeAtMost(u64, 0, window);
    _ = cap;
    return result;
}

// ── Token bucket rate limiter ───────────────────────────────

pub const RateLimiter = struct {
    capacity: f64,
    refill_per_sec: f64,
    tokens: f64,
    last_refill_ns: i128,
    mutex: std.Thread.Mutex,
};

pub fn rate_create(
    capacity: u32,
    refill_per_sec: u32,
) callconv(.c) ?*RateLimiter {
    const r = gpa.create(RateLimiter) catch return null;
    r.* = .{
        .capacity = @floatFromInt(capacity),
        .refill_per_sec = @floatFromInt(refill_per_sec),
        .tokens = @floatFromInt(capacity),
        .last_refill_ns = std.time.nanoTimestamp(),
        .mutex = .{},
    };
    return r;
}

pub fn rate_destroy(r_opt: ?*RateLimiter) callconv(.c) void {
    const r = r_opt orelse return;
    gpa.destroy(r);
}

fn refillLocked(r: *RateLimiter) void {
    const now = std.time.nanoTimestamp();
    const elapsed_ns = now - r.last_refill_ns;
    if (elapsed_ns <= 0) return;
    const elapsed_s = @as(f64, @floatFromInt(@as(i64, @intCast(elapsed_ns)))) / 1_000_000_000.0;
    r.tokens += elapsed_s * r.refill_per_sec;
    if (r.tokens > r.capacity) r.tokens = r.capacity;
    r.last_refill_ns = now;
}

/// Non-blocking take. Returns 1 on success, 0 on denial.
pub fn rate_try_take(r_opt: ?*RateLimiter, n: u32) callconv(.c) i32 {
    const r = r_opt orelse return 0;
    r.mutex.lock();
    defer r.mutex.unlock();
    refillLocked(r);
    const want: f64 = @floatFromInt(n);
    if (r.tokens >= want) {
        r.tokens -= want;
        return 1;
    }
    return 0;
}

/// Block until `n` tokens are available. Returns ms waited.
pub fn rate_wait_for(r_opt: ?*RateLimiter, n: u32) callconv(.c) u64 {
    const r = r_opt orelse return 0;
    var total_wait_ms: u64 = 0;
    while (true) {
        r.mutex.lock();
        refillLocked(r);
        const want: f64 = @floatFromInt(n);
        if (r.tokens >= want) {
            r.tokens -= want;
            r.mutex.unlock();
            return total_wait_ms;
        }
        const deficit = want - r.tokens;
        const seconds_needed = deficit / r.refill_per_sec;
        const ms_needed: u64 = @intFromFloat(@ceil(seconds_needed * 1000.0));
        r.mutex.unlock();
        const sleep_ms = if (ms_needed == 0) 1 else ms_needed;
        std.Thread.sleep(sleep_ms * std.time.ns_per_ms);
        total_wait_ms += sleep_ms;
    }
}

/// Available tokens (read-only).
pub fn rate_available(r_opt: ?*RateLimiter) callconv(.c) f64 {
    const r = r_opt orelse return 0.0;
    r.mutex.lock();
    defer r.mutex.unlock();
    refillLocked(r);
    return r.tokens;
}

// ── Circuit breaker ─────────────────────────────────────────

pub const CircuitState = enum(u8) { closed = 0, open = 1, half_open = 2 };

pub const CircuitBreaker = struct {
    failure_threshold: u32,
    reset_after_ms: u64,
    state: CircuitState,
    failure_count: u32,
    last_change_ns: i128,
    mutex: std.Thread.Mutex,
};

pub fn circuit_create(
    failure_threshold: u32,
    reset_after_ms: u64,
) callconv(.c) ?*CircuitBreaker {
    const c = gpa.create(CircuitBreaker) catch return null;
    c.* = .{
        .failure_threshold = if (failure_threshold == 0) 5 else failure_threshold,
        .reset_after_ms = if (reset_after_ms == 0) 5000 else reset_after_ms,
        .state = .closed,
        .failure_count = 0,
        .last_change_ns = std.time.nanoTimestamp(),
        .mutex = .{},
    };
    return c;
}

pub fn circuit_destroy(c_opt: ?*CircuitBreaker) callconv(.c) void {
    const c = c_opt orelse return;
    gpa.destroy(c);
}

/// Returns 1 if the caller may proceed, 0 if blocked.
/// Transitions OPEN -> HALF_OPEN once `reset_after_ms` has elapsed.
pub fn circuit_can_pass(c_opt: ?*CircuitBreaker) callconv(.c) i32 {
    const c = c_opt orelse return 0;
    c.mutex.lock();
    defer c.mutex.unlock();
    switch (c.state) {
        .closed => return 1,
        .half_open => return 1,
        .open => {
            const now = std.time.nanoTimestamp();
            const elapsed_ms: u64 = @intCast(@divFloor(now - c.last_change_ns, 1_000_000));
            if (elapsed_ms >= c.reset_after_ms) {
                c.state = .half_open;
                c.last_change_ns = now;
                return 1;
            }
            return 0;
        },
    }
}

/// Caller must report the outcome of a passed-through call.
pub fn circuit_record_success(c_opt: ?*CircuitBreaker) callconv(.c) void {
    const c = c_opt orelse return;
    c.mutex.lock();
    defer c.mutex.unlock();
    c.failure_count = 0;
    if (c.state != .closed) {
        c.state = .closed;
        c.last_change_ns = std.time.nanoTimestamp();
    }
}

pub fn circuit_record_failure(c_opt: ?*CircuitBreaker) callconv(.c) void {
    const c = c_opt orelse return;
    c.mutex.lock();
    defer c.mutex.unlock();
    switch (c.state) {
        .closed => {
            c.failure_count += 1;
            if (c.failure_count >= c.failure_threshold) {
                c.state = .open;
                c.last_change_ns = std.time.nanoTimestamp();
            }
        },
        .half_open => {
            c.state = .open;
            c.failure_count = c.failure_threshold;
            c.last_change_ns = std.time.nanoTimestamp();
        },
        .open => {},
    }
}

pub fn circuit_state(c_opt: ?*CircuitBreaker) callconv(.c) i32 {
    const c = c_opt orelse return -1;
    c.mutex.lock();
    defer c.mutex.unlock();
    return @intFromEnum(c.state);
}

/// Manual reset -- useful for tests + ops dashboards.
pub fn circuit_reset(c_opt: ?*CircuitBreaker) callconv(.c) void {
    const c = c_opt orelse return;
    c.mutex.lock();
    defer c.mutex.unlock();
    c.state = .closed;
    c.failure_count = 0;
    c.last_change_ns = std.time.nanoTimestamp();
}

// ── Outlier ejection per (host, port) ───────────────────────
// Gap-analysis Tier 1 item 7. A process-wide registry keyed by host
// tracks consecutive failures; once a host crosses the failure
// threshold it is ejected for a cooldown window, then auto-readmitted
// (half-open: it gets a fresh chance). A success resets the failure
// count. The HTTP pool consults outlier_should_eject before handing out
// a connection, so a flapping downstream stops receiving traffic.
//
// This slice ejects on consecutive failures (error-based). The
// latency_ms argument is recorded for a future latency-p99-based
// ejection refinement; it does not affect ejection today.

const Outlier = struct {
    consecutive_failures: u32,
    ejected_until_ns: i128, // 0 = not ejected
};

var outlier_map: std.StringHashMap(Outlier) = undefined;
var outlier_init: bool = false;
var outlier_mutex: std.Thread.Mutex = .{};
var outlier_threshold: u32 = 10;
var outlier_cooldown_ms: u64 = 30_000;

fn outlierEnsure() void {
    if (!outlier_init) {
        outlier_map = std.StringHashMap(Outlier).init(gpa);
        outlier_init = true;
    }
}

/// Set the ejection threshold (consecutive failures) and cooldown (ms).
/// A 0 leaves that field unchanged.
pub fn outlier_config(threshold: u32, cooldown_ms: u64) callconv(.c) void {
    outlier_mutex.lock();
    defer outlier_mutex.unlock();
    if (threshold != 0) outlier_threshold = threshold;
    if (cooldown_ms != 0) outlier_cooldown_ms = cooldown_ms;
}

/// Record the outcome of a call to `host`. ok != 0 resets the failure
/// run (and clears any ejection); ok == 0 increments it and ejects once
/// the threshold is crossed.
pub fn outlier_record(
    host_ptr: [*]const u8,
    host_len: usize,
    ok: i32,
    latency_ms: f64,
) callconv(.c) void {
    _ = latency_ms; // reserved for latency-based ejection
    const host = host_ptr[0..host_len];
    outlier_mutex.lock();
    defer outlier_mutex.unlock();
    outlierEnsure();
    const gop = outlier_map.getOrPut(host) catch return;
    if (!gop.found_existing) {
        const owned = gpa.dupe(u8, host) catch {
            _ = outlier_map.remove(host);
            return;
        };
        gop.key_ptr.* = owned;
        gop.value_ptr.* = .{ .consecutive_failures = 0, .ejected_until_ns = 0 };
    }
    if (ok != 0) {
        gop.value_ptr.*.consecutive_failures = 0;
        gop.value_ptr.*.ejected_until_ns = 0;
    } else {
        gop.value_ptr.*.consecutive_failures += 1;
        if (gop.value_ptr.*.consecutive_failures >= outlier_threshold) {
            const now = std.time.nanoTimestamp();
            gop.value_ptr.*.ejected_until_ns = now + @as(i128, @intCast(outlier_cooldown_ms)) * 1_000_000;
        }
    }
}

/// 1 if `host` is currently ejected, else 0. Once the cooldown elapses
/// the host is readmitted (half-open) and this returns 0.
pub fn outlier_should_eject(host_ptr: [*]const u8, host_len: usize) callconv(.c) i32 {
    const host = host_ptr[0..host_len];
    outlier_mutex.lock();
    defer outlier_mutex.unlock();
    outlierEnsure();
    const e = outlier_map.getPtr(host) orelse return 0;
    if (e.ejected_until_ns == 0) return 0;
    const now = std.time.nanoTimestamp();
    if (now >= e.ejected_until_ns) {
        // Cooldown elapsed -- give the host a fresh chance.
        e.ejected_until_ns = 0;
        e.consecutive_failures = 0;
        return 0;
    }
    return 1;
}

/// Clear all state for `host`.
pub fn outlier_reset(host_ptr: [*]const u8, host_len: usize) callconv(.c) void {
    const host = host_ptr[0..host_len];
    outlier_mutex.lock();
    defer outlier_mutex.unlock();
    outlierEnsure();
    if (outlier_map.getPtr(host)) |e| {
        e.* = .{ .consecutive_failures = 0, .ejected_until_ns = 0 };
    }
}

// ── tests ────────────────────────────────────────────────────

test "outlier: consecutive failures eject; success resets" {
    outlier_reset("h1", 2);
    outlier_config(10, 30_000);
    var i: u32 = 0;
    while (i < 9) : (i += 1) outlier_record("h1", 2, 0, 0);
    try std.testing.expectEqual(@as(i32, 0), outlier_should_eject("h1", 2)); // 9 < 10
    outlier_record("h1", 2, 1, 0); // success resets the run
    i = 0;
    while (i < 9) : (i += 1) outlier_record("h1", 2, 0, 0);
    try std.testing.expectEqual(@as(i32, 0), outlier_should_eject("h1", 2)); // still 9
    outlier_record("h1", 2, 0, 0); // 10th failure
    try std.testing.expectEqual(@as(i32, 1), outlier_should_eject("h1", 2));
}

test "outlier: readmit after cooldown" {
    outlier_reset("h2", 2);
    outlier_config(3, 150); // low threshold + short cooldown for the test
    outlier_record("h2", 2, 0, 0);
    outlier_record("h2", 2, 0, 0);
    outlier_record("h2", 2, 0, 0);
    try std.testing.expectEqual(@as(i32, 1), outlier_should_eject("h2", 2));
    std.Thread.sleep(220 * std.time.ns_per_ms);
    try std.testing.expectEqual(@as(i32, 0), outlier_should_eject("h2", 2)); // readmitted
    outlier_config(10, 30_000); // restore defaults for other tests
}

test "retry: zero base => zero delay" {
    try std.testing.expectEqual(@as(u64, 0), retry_delay_ms(0, 0, 1000, 1));
}

test "retry: delay grows but is capped" {
    const a = retry_delay_ms(0, 100, 5000, 42);
    const b = retry_delay_ms(20, 100, 5000, 42);
    try std.testing.expect(a <= 100);
    try std.testing.expect(b <= 5000);
}

test "rate: try_take respects capacity" {
    const r = rate_create(3, 1).?;
    defer rate_destroy(r);
    try std.testing.expectEqual(@as(i32, 1), rate_try_take(r, 1));
    try std.testing.expectEqual(@as(i32, 1), rate_try_take(r, 1));
    try std.testing.expectEqual(@as(i32, 1), rate_try_take(r, 1));
    try std.testing.expectEqual(@as(i32, 0), rate_try_take(r, 1));
}

test "rate: refill recovers tokens" {
    const r = rate_create(2, 1000).?;
    defer rate_destroy(r);
    _ = rate_try_take(r, 2);
    std.Thread.sleep(50 * std.time.ns_per_ms);
    try std.testing.expect(rate_available(r) > 1.0);
}

test "circuit: opens after threshold failures" {
    const c = circuit_create(3, 1000).?;
    defer circuit_destroy(c);
    try std.testing.expectEqual(@as(i32, 1), circuit_can_pass(c));
    circuit_record_failure(c);
    circuit_record_failure(c);
    try std.testing.expectEqual(@as(i32, 1), circuit_can_pass(c));
    circuit_record_failure(c);
    try std.testing.expectEqual(@as(i32, 0), circuit_can_pass(c));
    try std.testing.expectEqual(@as(i32, @intFromEnum(CircuitState.open)), circuit_state(c));
}

test "circuit: closes on success" {
    const c = circuit_create(2, 100).?;
    defer circuit_destroy(c);
    circuit_record_failure(c);
    circuit_record_failure(c);
    try std.testing.expectEqual(@as(i32, @intFromEnum(CircuitState.open)), circuit_state(c));
    std.Thread.sleep(150 * std.time.ns_per_ms);
    _ = circuit_can_pass(c);
    try std.testing.expectEqual(@as(i32, @intFromEnum(CircuitState.half_open)), circuit_state(c));
    circuit_record_success(c);
    try std.testing.expectEqual(@as(i32, @intFromEnum(CircuitState.closed)), circuit_state(c));
}
