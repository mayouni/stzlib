const r = @import("resilience.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const rn = R.ring_vm_api_retnumber;

const RATE_HANDLE: [*:0]const u8 = "StzRateLimiter";
const CIRCUIT_HANDLE: [*:0]const u8 = "StzCircuitBreaker";

fn getRate(p: *anyopaque, n: c_int) ?*r.RateLimiter {
    const raw = R.ring_vm_api_getcpointer(p, n, RATE_HANDLE) orelse return null;
    const addr = @intFromPtr(raw);
    if (addr == 0) return null;
    return @ptrFromInt(addr);
}

fn getCircuit(p: *anyopaque, n: c_int) ?*r.CircuitBreaker {
    const raw = R.ring_vm_api_getcpointer(p, n, CIRCUIT_HANDLE) orelse return null;
    const addr = @intFromPtr(raw);
    if (addr == 0) return null;
    return @ptrFromInt(addr);
}

// ── retry ────────────────────────────────────────────────────

fn ring_RetryDelayMs(p: *anyopaque) callconv(.c) void {
    const attempt: u32 = @intFromFloat(gn(p, 1));
    const base_ms: u64 = @intFromFloat(gn(p, 2));
    const max_ms: u64 = @intFromFloat(gn(p, 3));
    const seed: u64 = @intFromFloat(gn(p, 4));
    rn(p, @floatFromInt(r.retry_delay_ms(attempt, base_ms, max_ms, seed)));
}

// ── rate limiter ────────────────────────────────────────────

fn ring_RateCreate(p: *anyopaque) callconv(.c) void {
    const cap: u32 = @intFromFloat(gn(p, 1));
    const refill: u32 = @intFromFloat(gn(p, 2));
    const handle = r.rate_create(cap, refill);
    if (handle) |h| {
        R.ring_vm_api_retcpointer(p, @ptrCast(h), RATE_HANDLE);
    } else {
        R.ring_vm_api_retcpointer(p, @ptrFromInt(0), RATE_HANDLE);
    }
}

fn ring_RateTryTake(p: *anyopaque) callconv(.c) void {
    const rr = getRate(p, 1);
    const n: u32 = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(r.rate_try_take(rr, n)));
}

fn ring_RateWaitFor(p: *anyopaque) callconv(.c) void {
    const rr = getRate(p, 1);
    const n: u32 = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(r.rate_wait_for(rr, n)));
}

fn ring_RateAvailable(p: *anyopaque) callconv(.c) void {
    const rr = getRate(p, 1);
    rn(p, r.rate_available(rr));
}

fn ring_RateDestroy(p: *anyopaque) callconv(.c) void {
    r.rate_destroy(getRate(p, 1));
}

// ── circuit breaker ─────────────────────────────────────────

fn ring_CircuitCreate(p: *anyopaque) callconv(.c) void {
    const threshold: u32 = @intFromFloat(gn(p, 1));
    const reset_ms: u64 = @intFromFloat(gn(p, 2));
    const handle = r.circuit_create(threshold, reset_ms);
    if (handle) |h| {
        R.ring_vm_api_retcpointer(p, @ptrCast(h), CIRCUIT_HANDLE);
    } else {
        R.ring_vm_api_retcpointer(p, @ptrFromInt(0), CIRCUIT_HANDLE);
    }
}

fn ring_CircuitCanPass(p: *anyopaque) callconv(.c) void {
    const cc = getCircuit(p, 1);
    rn(p, @floatFromInt(r.circuit_can_pass(cc)));
}

fn ring_CircuitRecordSuccess(p: *anyopaque) callconv(.c) void {
    r.circuit_record_success(getCircuit(p, 1));
}

fn ring_CircuitRecordFailure(p: *anyopaque) callconv(.c) void {
    r.circuit_record_failure(getCircuit(p, 1));
}

fn ring_CircuitState(p: *anyopaque) callconv(.c) void {
    const cc = getCircuit(p, 1);
    rn(p, @floatFromInt(r.circuit_state(cc)));
}

fn ring_CircuitReset(p: *anyopaque) callconv(.c) void {
    r.circuit_reset(getCircuit(p, 1));
}

fn ring_CircuitDestroy(p: *anyopaque) callconv(.c) void {
    r.circuit_destroy(getCircuit(p, 1));
}

const regs = [_]R.Reg{
    .{ .name = "stzengineretrydelayms", .func = ring_RetryDelayMs },
    .{ .name = "stzengineratecreate", .func = ring_RateCreate },
    .{ .name = "stzengineratetrytake", .func = ring_RateTryTake },
    .{ .name = "stzengineratewaitfor", .func = ring_RateWaitFor },
    .{ .name = "stzenginerateavailable", .func = ring_RateAvailable },
    .{ .name = "stzengineratedestroy", .func = ring_RateDestroy },
    .{ .name = "stzenginecircuitcreate", .func = ring_CircuitCreate },
    .{ .name = "stzenginecircuitcanpass", .func = ring_CircuitCanPass },
    .{ .name = "stzenginecircuitrecordsuccess", .func = ring_CircuitRecordSuccess },
    .{ .name = "stzenginecircuitrecordfailure", .func = ring_CircuitRecordFailure },
    .{ .name = "stzenginecircuitstate", .func = ring_CircuitState },
    .{ .name = "stzenginecircuitreset", .func = ring_CircuitReset },
    .{ .name = "stzenginecircuitdestroy", .func = ring_CircuitDestroy },
};

pub fn registerAll(state: *anyopaque) void {
    R.registerAll(state, &regs);
}
