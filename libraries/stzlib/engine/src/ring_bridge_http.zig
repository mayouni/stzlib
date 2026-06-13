const http = @import("http.zig");
const dns = @import("dns.zig");
const std = @import("std");
const R = @import("ring_api.zig");

const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rs2 = R.ring_vm_api_retstring2;
const rs = R.ring_vm_api_retstring;
const rn = R.ring_vm_api_retnumber;

// Default body buffer for blocking GET/POST. Generous for the
// scrape-data-from-HTML use case. Larger payloads should grow this
// or move to a streaming API in a later slice.
const BODY_CAP: usize = 4 * 1024 * 1024; // 4 MiB

var body_buf: [BODY_CAP]u8 = undefined;

fn ring_HttpGet(p: *anyopaque) callconv(.c) void {
    const url_ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const url_len: usize = @intCast(gss(p, 1));
    const status = http.http_get(url_ptr, url_len, &body_buf, BODY_CAP);
    if (status > 0) {
        const n = http.http_last_body_len();
        rs2(p, &body_buf, @intCast(n));
    } else {
        rs(p, @constCast(""));
    }
}

fn ring_HttpGetStatus(p: *anyopaque) callconv(.c) void {
    const url_ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const url_len: usize = @intCast(gss(p, 1));
    const status = http.http_get(url_ptr, url_len, &body_buf, BODY_CAP);
    rn(p, @floatFromInt(status));
}

fn ring_HttpPost(p: *anyopaque) callconv(.c) void {
    const url_ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const url_len: usize = @intCast(gss(p, 1));
    const ct_ptr: [*]const u8 = @ptrCast(gs(p, 2));
    const ct_len: usize = @intCast(gss(p, 2));
    const body_ptr: [*]const u8 = @ptrCast(gs(p, 3));
    const body_len: usize = @intCast(gss(p, 3));
    const status = http.http_post(url_ptr, url_len, ct_ptr, ct_len, body_ptr, body_len, &body_buf, BODY_CAP);
    if (status > 0) {
        const n = http.http_last_body_len();
        rs2(p, &body_buf, @intCast(n));
    } else {
        rs(p, @constCast(""));
    }
}

fn ring_HttpLastError(p: *anyopaque) callconv(.c) void {
    var buf: [512]u8 = undefined;
    const n = http.http_last_error(&buf, 512);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, @constCast(""));
}

const gn = R.ring_vm_api_getnumber;

/// StzEngineHttpRequest(method_code, cUrl, cHeaders, cContentType, cBody) -> body
fn ring_HttpRequest(p: *anyopaque) callconv(.c) void {
    const method_code: i32 = @intFromFloat(gn(p, 1));
    const url_ptr: [*]const u8 = @ptrCast(gs(p, 2));
    const url_len: usize = @intCast(gss(p, 2));
    const hdr_ptr: [*]const u8 = @ptrCast(gs(p, 3));
    const hdr_len: usize = @intCast(gss(p, 3));
    const ct_ptr: [*]const u8 = @ptrCast(gs(p, 4));
    const ct_len: usize = @intCast(gss(p, 4));
    const body_ptr: [*]const u8 = @ptrCast(gs(p, 5));
    const body_len: usize = @intCast(gss(p, 5));
    const status = http.http_request(
        method_code,
        url_ptr,
        url_len,
        hdr_ptr,
        hdr_len,
        ct_ptr,
        ct_len,
        body_ptr,
        body_len,
        &body_buf,
        BODY_CAP,
    );
    last_request_status = status;
    if (status > 0) {
        rs2(p, &body_buf, @intCast(http.http_last_body_len()));
    } else {
        rs(p, @constCast(""));
    }
}

/// StzEngineHttpLastStatus() -> last status code from the last
/// StzEngineHttpRequest call (-1 on transport error).
fn ring_HttpLastStatus(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(last_request_status));
}

var last_request_status: i32 = 0;

/// StzEngineHttpParallelGet(cUrlsBlob) -> joined "<status>:<body>\x1E..."
/// Ring side splits on \x1E and parses the prefix.
fn ring_HttpParallelGet(p: *anyopaque) callconv(.c) void {
    const urls_ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const urls_len: usize = @intCast(gss(p, 1));
    const n = http.http_parallel_get(urls_ptr, urls_len, &body_buf, BODY_CAP);
    if (n > 0) {
        rs2(p, &body_buf, @intCast(n));
    } else {
        rs(p, @constCast(""));
    }
}

/// StzEngineHttpSetDefaultTimeouts(nConnectMs, nRequestMs, nIdleMs)
/// Each 0 leaves that default unchanged.
fn ring_HttpSetDefaultTimeouts(p: *anyopaque) callconv(.c) void {
    const connect_ms: u32 = @intFromFloat(gn(p, 1));
    const request_ms: u32 = @intFromFloat(gn(p, 2));
    const idle_ms: u32 = @intFromFloat(gn(p, 3));
    http.http_set_default_timeouts(connect_ms, request_ms, idle_ms);
    rn(p, 0);
}

/// StzEngineHttpRequestWithTimeouts(method_code, cUrl, cHeaders,
/// cContentType, cBody, nConnectMs, nRequestMs) -> body
fn ring_HttpRequestWithTimeouts(p: *anyopaque) callconv(.c) void {
    const method_code: i32 = @intFromFloat(gn(p, 1));
    const url_ptr: [*]const u8 = @ptrCast(gs(p, 2));
    const url_len: usize = @intCast(gss(p, 2));
    const hdr_ptr: [*]const u8 = @ptrCast(gs(p, 3));
    const hdr_len: usize = @intCast(gss(p, 3));
    const ct_ptr: [*]const u8 = @ptrCast(gs(p, 4));
    const ct_len: usize = @intCast(gss(p, 4));
    const body_ptr: [*]const u8 = @ptrCast(gs(p, 5));
    const body_len: usize = @intCast(gss(p, 5));
    const connect_ms: u32 = @intFromFloat(gn(p, 6));
    const request_ms: u32 = @intFromFloat(gn(p, 7));
    const status = http.http_request_with_timeouts(
        method_code,
        url_ptr,
        url_len,
        hdr_ptr,
        hdr_len,
        ct_ptr,
        ct_len,
        body_ptr,
        body_len,
        connect_ms,
        request_ms,
        &body_buf,
        BODY_CAP,
    );
    last_request_status = status;
    if (status > 0) {
        rs2(p, &body_buf, @intCast(http.http_last_body_len()));
    } else {
        rs(p, @constCast(""));
    }
}

/// StzEngineHttpPoolStats() -> "opens=N\treuses=N\tidle=N\tactive=N"
fn ring_HttpPoolStats(p: *anyopaque) callconv(.c) void {
    var buf: [256]u8 = undefined;
    const n = http.http_pool_stats(&buf, buf.len);
    if (n > 0) rs2(p, &buf, @intCast(n)) else rs(p, @constCast(""));
}

// ── DNS cache diagnostics (item 3) ───────────────────────────

/// StzEngineDnsResolve(cHost, nPort) -> "ip:port" string (cached), or ""
/// on failure. Primes / exercises the cache; mainly for diagnostics.
fn ring_DnsResolve(p: *anyopaque) callconv(.c) void {
    const host_ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const host_len: usize = @intCast(gss(p, 1));
    const port: u16 = @intFromFloat(gn(p, 2));
    const addr = dns.lookup(host_ptr[0..host_len], port) catch {
        rs(p, @constCast(""));
        return;
    };
    var buf: [64]u8 = undefined;
    const text = std.fmt.bufPrint(&buf, "{f}", .{addr}) catch {
        rs(p, @constCast(""));
        return;
    };
    rs2(p, &buf, @intCast(text.len));
}

/// StzEngineDnsStats() -> "resolves=N\thits=N"
fn ring_DnsStats(p: *anyopaque) callconv(.c) void {
    var buf: [64]u8 = undefined;
    const text = std.fmt.bufPrint(&buf, "resolves={d}\thits={d}", .{
        dns.resolve_count.load(.monotonic),
        dns.hit_count.load(.monotonic),
    }) catch {
        rs(p, @constCast(""));
        return;
    };
    rs2(p, &buf, @intCast(text.len));
}

/// StzEngineDnsCacheClear() -> drops every cached entry.
fn ring_DnsCacheClear(p: *anyopaque) callconv(.c) void {
    dns.clear();
    rn(p, 0);
}

// ── HTTP request-latency histogram (item 6 wire-up) ──────────

/// StzEngineHttpLatencyPercentile(nP) -> ms upper bound for percentile.
fn ring_HttpLatencyPercentile(p: *anyopaque) callconv(.c) void {
    rn(p, http.http_latency_percentile(gn(p, 1)));
}

/// StzEngineHttpLatencyCount() -> number of requests recorded.
fn ring_HttpLatencyCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(http.http_latency_count()));
}

/// StzEngineHttpLatencyReset() -> clear the request-latency histogram.
fn ring_HttpLatencyReset(p: *anyopaque) callconv(.c) void {
    http.http_latency_reset();
    rn(p, 0);
}

const regs = [_]R.Reg{
    .{ .name = "stzenginehttpget", .func = ring_HttpGet },
    .{ .name = "stzenginehttpgetstatus", .func = ring_HttpGetStatus },
    .{ .name = "stzenginehttppost", .func = ring_HttpPost },
    .{ .name = "stzenginehttplasterror", .func = ring_HttpLastError },
    // slice 2 -- generic request + last-status accessor
    .{ .name = "stzenginehttprequest", .func = ring_HttpRequest },
    .{ .name = "stzenginehttplaststatus", .func = ring_HttpLastStatus },
    // slice 3 -- parallel GET (threaded)
    .{ .name = "stzenginehttpparallelget", .func = ring_HttpParallelGet },
    // Tier 1 items 1+2 -- timeouts + connection pool
    .{ .name = "stzenginehttpsetdefaulttimeouts", .func = ring_HttpSetDefaultTimeouts },
    .{ .name = "stzenginehttprequestwithtimeouts", .func = ring_HttpRequestWithTimeouts },
    .{ .name = "stzenginehttppoolstats", .func = ring_HttpPoolStats },
    // Tier 1 item 3 -- DNS cache diagnostics
    .{ .name = "stzenginednsresolve", .func = ring_DnsResolve },
    .{ .name = "stzenginednsstats", .func = ring_DnsStats },
    .{ .name = "stzenginednscacheclear", .func = ring_DnsCacheClear },
    // Tier 1 item 6 -- request-latency histogram
    .{ .name = "stzenginehttplatencypercentile", .func = ring_HttpLatencyPercentile },
    .{ .name = "stzenginehttplatencycount", .func = ring_HttpLatencyCount },
    .{ .name = "stzenginehttplatencyreset", .func = ring_HttpLatencyReset },
};

pub fn registerAll(state: *anyopaque) void {
    R.registerAll(state, &regs);
}
