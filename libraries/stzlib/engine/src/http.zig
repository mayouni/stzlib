// HTTP client -- custom HTTP/1.1 on raw std.net.Stream, pooled.
//
// Gap-analysis Tier 1 items 1+2. Previously this wrapped
// std.http.Client; that gave no per-socket timeouts and limited pool
// control. It now drives a small in-tree HTTP/1.1 client (httpcore.zig)
// over a connection pool (http_pool.zig):
//
//   * Connections are reused per (scheme, host, port) -- the TCP+TLS
//     handshake is paid once per host, not once per request.
//   * connect_timeout_ms makes an unreachable host fail fast.
//   * request_timeout_ms drives SO_RCVTIMEO / SO_SNDTIMEO (honoured on
//     POSIX; best-effort on Windows -- see httpcore.zig).
//
// Surface (unchanged for existing callers):
//   http_get / http_post / http_request / http_parallel_get
//   http_last_error_len / http_last_error / http_last_body_len
// New:
//   http_set_default_timeouts(connect_ms, request_ms, idle_ms)
//   http_request_with_timeouts(...)  -- per-request timeout override
//   http_pool_stats(out, max)        -- "opens=N\treuses=N\tidle=N\tactive=N"

const std = @import("std");
const httpcore = @import("httpcore.zig");
const http_pool = @import("http_pool.zig");
const histogram = @import("histogram.zig");
const resilience = @import("resilience.zig");

const gpa = std.heap.c_allocator;

var last_error_buf: [512]u8 = undefined;
var last_error_len: usize = 0;
var last_body_len: usize = 0;

pub fn http_last_body_len() callconv(.c) usize {
    return last_body_len;
}

fn setError(msg: []const u8) void {
    const n = @min(msg.len, last_error_buf.len);
    @memcpy(last_error_buf[0..n], msg[0..n]);
    last_error_len = n;
}

fn clearError() void {
    last_error_len = 0;
}

pub fn http_last_error_len() callconv(.c) usize {
    return last_error_len;
}

pub fn http_last_error(out: [*]u8, max: usize) callconv(.c) i32 {
    const n = @min(last_error_len, max);
    if (n == 0) return 0;
    @memcpy(out[0..n], last_error_buf[0..n]);
    return @intCast(n);
}

// ── pool + default timeouts (all milliseconds) ───────────────

var default_pool: ?*http_pool.Pool = null;
var pool_mutex: std.Thread.Mutex = .{};

var def_connect_ms: u32 = 5_000;
var def_request_ms: u32 = 30_000;
var def_idle_ms: u32 = 60_000;

fn getPool() ?*http_pool.Pool {
    pool_mutex.lock();
    defer pool_mutex.unlock();
    if (default_pool) |p| return p;
    default_pool = http_pool.create(def_idle_ms, 16, 256);
    return default_pool;
}

/// http_set_default_timeouts -- set process-wide default connect /
/// request / idle timeouts in milliseconds. 0 leaves a field unchanged.
pub fn http_set_default_timeouts(connect_ms: u32, request_ms: u32, idle_ms: u32) callconv(.c) void {
    if (connect_ms != 0) def_connect_ms = connect_ms;
    if (request_ms != 0) def_request_ms = request_ms;
    if (idle_ms != 0) {
        def_idle_ms = idle_ms;
        pool_mutex.lock();
        if (default_pool) |p| p.idle_timeout_ms = idle_ms;
        pool_mutex.unlock();
    }
}

// ── request-latency histogram (item 6 wire-up) ───────────────
// Every completed round-trip records its wall-clock latency here, so
// p50/p95/p99 of real HTTP traffic are queryable without the caller
// instrumenting each call.

var latency_hist: ?*histogram.Histogram = null;
var latency_mutex: std.Thread.Mutex = .{};

fn latencyHist() ?*histogram.Histogram {
    latency_mutex.lock();
    defer latency_mutex.unlock();
    if (latency_hist) |h| return h;
    latency_hist = histogram.histogram_create();
    return latency_hist;
}

/// http_latency_percentile -- ms upper bound for percentile p (0..100)
/// of recorded request latencies.
pub fn http_latency_percentile(p: f64) callconv(.c) f64 {
    return histogram.histogram_percentile(latencyHist(), p);
}

/// http_latency_count -- number of requests recorded.
pub fn http_latency_count() callconv(.c) u64 {
    return histogram.histogram_count(latencyHist());
}

/// http_latency_reset -- clear the request-latency histogram.
pub fn http_latency_reset() callconv(.c) void {
    histogram.histogram_reset(latencyHist());
}

/// http_pool_shutdown -- close all idle pooled connections (item 8).
/// Returns the number closed. Active in-flight requests are unaffected.
pub fn http_pool_shutdown() callconv(.c) i32 {
    pool_mutex.lock();
    const p = default_pool;
    pool_mutex.unlock();
    if (p) |pp| return @intCast(http_pool.shutdown(pp));
    return 0;
}

/// http_pool_stats -- write "opens=N\treuses=N\tidle=N\tactive=N" into
/// out[0..max]. Returns bytes written (or 0 if no pool yet).
pub fn http_pool_stats(out: [*]u8, max: usize) callconv(.c) i32 {
    pool_mutex.lock();
    const p = default_pool;
    pool_mutex.unlock();
    const s: http_pool.Stats = if (p) |pp| http_pool.stats(pp) else .{
        .opens = 0,
        .reuses = 0,
        .idle = 0,
        .active = 0,
    };
    const text = std.fmt.bufPrint(out[0..max], "opens={d}\treuses={d}\tidle={d}\tactive={d}", .{
        s.opens, s.reuses, s.idle, s.active,
    }) catch {
        setError("pool stats buffer too small");
        return 0;
    };
    return @intCast(text.len);
}

// ── public verbs ─────────────────────────────────────────────

pub fn http_get(
    url_ptr: [*]const u8,
    url_len: usize,
    body_out: [*]u8,
    body_max: usize,
) callconv(.c) i32 {
    clearError();
    if (url_len == 0) {
        setError("empty URL");
        return -1;
    }
    return doRequest("GET", url_ptr[0..url_len], null, null, &.{}, body_out, body_max, def_connect_ms, def_request_ms);
}

pub fn http_post(
    url_ptr: [*]const u8,
    url_len: usize,
    ct_ptr: [*]const u8,
    ct_len: usize,
    body_ptr: [*]const u8,
    body_len: usize,
    out: [*]u8,
    out_max: usize,
) callconv(.c) i32 {
    clearError();
    if (url_len == 0) {
        setError("empty URL");
        return -1;
    }
    const ct = if (ct_len == 0) "application/octet-stream" else ct_ptr[0..ct_len];
    const payload = body_ptr[0..body_len];
    return doRequest("POST", url_ptr[0..url_len], ct, payload, &.{}, out, out_max, def_connect_ms, def_request_ms);
}

/// Generic request. `method_code`:
/// 0=GET 1=POST 2=PUT 3=DELETE 4=HEAD 5=OPTIONS 6=PATCH
/// `headers_blob` is a newline-separated "Name: Value" block.
pub fn http_request(
    method_code: i32,
    url_ptr: [*]const u8,
    url_len: usize,
    headers_ptr: [*]const u8,
    headers_len: usize,
    ct_ptr: [*]const u8,
    ct_len: usize,
    body_ptr: [*]const u8,
    body_len: usize,
    out: [*]u8,
    out_max: usize,
) callconv(.c) i32 {
    return requestImpl(
        method_code,
        url_ptr,
        url_len,
        headers_ptr,
        headers_len,
        ct_ptr,
        ct_len,
        body_ptr,
        body_len,
        out,
        out_max,
        def_connect_ms,
        def_request_ms,
    );
}

/// Per-request timeout override. Same as http_request but takes explicit
/// connect / request millisecond deadlines (0 = use the default).
pub fn http_request_with_timeouts(
    method_code: i32,
    url_ptr: [*]const u8,
    url_len: usize,
    headers_ptr: [*]const u8,
    headers_len: usize,
    ct_ptr: [*]const u8,
    ct_len: usize,
    body_ptr: [*]const u8,
    body_len: usize,
    connect_ms: u32,
    request_ms: u32,
    out: [*]u8,
    out_max: usize,
) callconv(.c) i32 {
    const cms = if (connect_ms == 0) def_connect_ms else connect_ms;
    const rms = if (request_ms == 0) def_request_ms else request_ms;
    return requestImpl(
        method_code,
        url_ptr,
        url_len,
        headers_ptr,
        headers_len,
        ct_ptr,
        ct_len,
        body_ptr,
        body_len,
        out,
        out_max,
        cms,
        rms,
    );
}

fn requestImpl(
    method_code: i32,
    url_ptr: [*]const u8,
    url_len: usize,
    headers_ptr: [*]const u8,
    headers_len: usize,
    ct_ptr: [*]const u8,
    ct_len: usize,
    body_ptr: [*]const u8,
    body_len: usize,
    out: [*]u8,
    out_max: usize,
    connect_ms: u32,
    request_ms: u32,
) i32 {
    clearError();
    if (url_len == 0) {
        setError("empty URL");
        return -1;
    }
    const method = methodStr(method_code) orelse {
        setError("unsupported HTTP method code");
        return -1;
    };
    const headers_blob = headers_ptr[0..headers_len];
    const ct_slice: ?[]const u8 = if (ct_len > 0) ct_ptr[0..ct_len] else null;
    const payload: ?[]const u8 = if (body_len > 0) body_ptr[0..body_len] else null;
    return doRequest(method, url_ptr[0..url_len], ct_slice, payload, headers_blob, out, out_max, connect_ms, request_ms);
}

fn methodStr(code: i32) ?[]const u8 {
    return switch (code) {
        0 => "GET",
        1 => "POST",
        2 => "PUT",
        3 => "DELETE",
        4 => "HEAD",
        5 => "OPTIONS",
        6 => "PATCH",
        else => null,
    };
}

// ── URL parsing ──────────────────────────────────────────────

const ParsedUrl = struct {
    is_tls: bool,
    host: []const u8,
    port: u16,
    target: []const u8, // points into target_buf
};

fn compStr(c: std.Uri.Component) []const u8 {
    return switch (c) {
        .raw => |s| s,
        .percent_encoded => |s| s,
    };
}

fn parseUrl(url: []const u8, target_buf: []u8) ?ParsedUrl {
    const uri = std.Uri.parse(url) catch return null;
    const is_tls = std.ascii.eqlIgnoreCase(uri.scheme, "https");
    const host_comp = uri.host orelse return null;
    const host = compStr(host_comp);
    if (host.len == 0) return null;
    const port: u16 = uri.port orelse (if (is_tls) @as(u16, 443) else @as(u16, 80));

    // Build the request-target: path + "?" + query.
    const path = compStr(uri.path);
    const p = if (path.len == 0) "/" else path;
    var n: usize = 0;
    if (p.len > target_buf.len) return null;
    @memcpy(target_buf[0..p.len], p);
    n = p.len;
    if (uri.query) |q| {
        const qs = compStr(q);
        if (n + 1 + qs.len > target_buf.len) return null;
        target_buf[n] = '?';
        n += 1;
        @memcpy(target_buf[n .. n + qs.len], qs);
        n += qs.len;
    }
    return .{ .is_tls = is_tls, .host = host, .port = port, .target = target_buf[0..n] };
}

// ── core round-trip ──────────────────────────────────────────

fn doRequest(
    method: []const u8,
    url: []const u8,
    content_type: ?[]const u8,
    payload: ?[]const u8,
    headers_blob: []const u8,
    out: [*]u8,
    max: usize,
    connect_ms: u32,
    request_ms: u32,
) i32 {
    var target_buf: [8192]u8 = undefined;
    const parsed = parseUrl(url, &target_buf) orelse {
        var fbuf: [200]u8 = undefined;
        const msg = std.fmt.bufPrint(&fbuf, "{s} failed: invalid URL", .{method}) catch "request failed: invalid URL";
        setError(msg);
        return -1;
    };

    const pool = getPool() orelse {
        setError("pool unavailable");
        return -1;
    };

    const t0_ms = std.time.milliTimestamp();
    const conn = http_pool.acquire(pool, parsed.host, parsed.port, parsed.is_tls, connect_ms) orelse {
        var ebuf: [256]u8 = undefined;
        const n = http_pool.pool_last_error(&ebuf, ebuf.len);
        if (n > 0) setError(ebuf[0..@intCast(n)]) else setError("acquire failed");
        // A genuine connect failure counts toward outlier ejection; an
        // already-ejected host does not (it is reported, not re-counted).
        if (resilience.outlier_should_eject(parsed.host.ptr, parsed.host.len) == 0) {
            resilience.outlier_record(parsed.host.ptr, parsed.host.len, 0, 0);
        }
        last_body_len = 0;
        return -1;
    };

    httpcore.setIoTimeout(conn, request_ms);

    const resp = httpcore.request(
        conn,
        method,
        parsed.target,
        parsed.host,
        headers_blob,
        content_type,
        payload,
        out,
        max,
    ) catch |err| {
        // A failed request leaves the connection in an unknown state --
        // do not return it to the idle list.
        http_pool.release(pool, conn, false);
        resilience.outlier_record(parsed.host.ptr, parsed.host.len, 0, 0);
        last_body_len = 0;
        if (err == error.BodyOverflow) {
            setError("response body exceeds output buffer");
            return -2;
        }
        var fbuf: [200]u8 = undefined;
        const msg = std.fmt.bufPrint(&fbuf, "{s} failed: {s}", .{ method, @errorName(err) }) catch "request failed";
        setError(msg);
        return -1;
    };

    http_pool.release(pool, conn, resp.keep_alive);
    last_body_len = resp.body_len;
    const dt_ms = std.time.milliTimestamp() - t0_ms;
    histogram.histogram_record(latencyHist(), @floatFromInt(dt_ms));
    // A completed response (any HTTP status) is a healthy host: reset its
    // outlier failure run.
    resilience.outlier_record(parsed.host.ptr, parsed.host.len, 1, @floatFromInt(dt_ms));
    return resp.status;
}

// ── parallel GET ─────────────────────────────────────────────
// std.Thread per URL; each worker does a pooled round-trip. Results are
// concatenated into `out` separated by RECORD_SEP (0x1E); each record is
// "<status>:<body>". Ring splits on RECORD_SEP and parses the prefix.

const RECORD_SEP: u8 = 0x1E;
const MAX_PARALLEL: usize = 32;
const PARALLEL_BODY_CAP: usize = 2 * 1024 * 1024; // 2 MiB per URL

const ParallelJob = struct {
    url: []const u8,
    status: i32,
    body: std.ArrayList(u8),
    done: bool,
};

fn parallelWorker(job: *ParallelJob) void {
    const buf = gpa.alloc(u8, PARALLEL_BODY_CAP) catch {
        job.status = -1;
        job.done = true;
        return;
    };
    defer gpa.free(buf);
    const status = doRequest("GET", job.url, null, null, &.{}, buf.ptr, buf.len, def_connect_ms, def_request_ms);
    job.status = status;
    if (status > 0) {
        const n = last_body_len;
        job.body.appendSlice(gpa, buf[0..n]) catch {
            job.status = -1;
        };
    }
    job.done = true;
}

pub fn http_parallel_get(
    urls_ptr: [*]const u8,
    urls_len: usize,
    out: [*]u8,
    out_max: usize,
) callconv(.c) i32 {
    clearError();
    if (urls_len == 0) {
        setError("empty URL list");
        return -1;
    }
    const urls_slice = urls_ptr[0..urls_len];

    var url_buf: [MAX_PARALLEL][]const u8 = undefined;
    var n: usize = 0;
    var it = std.mem.splitScalar(u8, urls_slice, '\n');
    while (it.next()) |raw| {
        if (raw.len == 0) continue;
        if (n >= MAX_PARALLEL) {
            setError("too many URLs (max 32)");
            return -1;
        }
        url_buf[n] = raw;
        n += 1;
    }
    if (n == 0) {
        setError("empty URL list");
        return -1;
    }

    const jobs = gpa.alloc(ParallelJob, n) catch {
        setError("oom (jobs)");
        return -1;
    };
    defer {
        for (jobs) |*j| j.body.deinit(gpa);
        gpa.free(jobs);
    }

    const threads = gpa.alloc(std.Thread, n) catch {
        setError("oom (threads)");
        return -1;
    };
    defer gpa.free(threads);

    for (jobs, 0..) |*j, i| {
        j.* = .{ .url = url_buf[i], .status = 0, .body = .{}, .done = false };
        threads[i] = std.Thread.spawn(.{}, parallelWorker, .{j}) catch {
            j.status = -1;
            j.done = true;
            continue;
        };
    }

    for (jobs, 0..) |*j, i| {
        if (!j.done) threads[i].join();
    }

    var written: usize = 0;
    for (jobs) |*j| {
        var status_buf: [16]u8 = undefined;
        const status_str = std.fmt.bufPrint(&status_buf, "{d}:", .{j.status}) catch "?:";
        if (written + status_str.len + j.body.items.len + 1 > out_max) {
            setError("parallel response exceeds output buffer");
            return -2;
        }
        @memcpy(out[written .. written + status_str.len], status_str);
        written += status_str.len;
        @memcpy(out[written .. written + j.body.items.len], j.body.items);
        written += j.body.items.len;
        out[written] = RECORD_SEP;
        written += 1;
    }
    last_body_len = written;
    return @intCast(written);
}

// ── tests ────────────────────────────────────────────────────

test "http: URL parse rejection surface" {
    var body_buf: [256]u8 = undefined;
    const rc = http_get("not a url", 9, &body_buf, 256);
    try std.testing.expect(rc < 0);
    try std.testing.expect(http_last_error_len() > 0);
}

test "http: parseUrl splits scheme/host/port/target" {
    var tbuf: [256]u8 = undefined;
    const p = parseUrl("https://example.com/a/b?x=1", &tbuf).?;
    try std.testing.expect(p.is_tls);
    try std.testing.expectEqualStrings("example.com", p.host);
    try std.testing.expectEqual(@as(u16, 443), p.port);
    try std.testing.expectEqualStrings("/a/b?x=1", p.target);
}

test "http: parseUrl default http port + root path" {
    var tbuf: [256]u8 = undefined;
    const p = parseUrl("http://localhost:8080", &tbuf).?;
    try std.testing.expect(!p.is_tls);
    try std.testing.expectEqual(@as(u16, 8080), p.port);
    try std.testing.expectEqualStrings("/", p.target);
}
