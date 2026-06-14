// HTTP client -- vendored libcurl (Tier 2: adopt libcurl).
//
// Replaces the custom HTTP/1.1 client (httpcore.zig) + connection pool
// (http_pool.zig). libcurl gives HTTP/1.1 (+ HTTP/2 when nghttp2 is
// linked), TLS via native Schannel, connection pooling + DNS cache +
// TLS-session reuse (via a process-wide CURLSH share in curlcore), and
// redirect/proxy handling -- battle-tested instead of hand-rolled.
//
// The C-ABI surface is unchanged (http_get/post/request/parallel_get,
// timeouts, pool stats, latency, outlier) so the Ring bridge + Ring API
// + the whole network test suite keep working.

const std = @import("std");
const curlcore = @import("curlcore.zig");
const histogram = @import("histogram.zig");
const resilience = @import("resilience.zig");

var last_error_buf: [512]u8 = undefined;
var last_error_len: usize = 0;
var last_body_len_v: usize = 0;

pub fn http_last_body_len() callconv(.c) usize {
    return last_body_len_v;
}

fn setError(msg: []const u8) void {
    const n = @min(msg.len, last_error_buf.len);
    @memcpy(last_error_buf[0..n], msg[0..n]);
    last_error_len = n;
}

fn importCurlError() void {
    last_error_len = @intCast(curlcore.curl_last_error(&last_error_buf, last_error_buf.len));
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

// ── default timeouts (ms) ────────────────────────────────────

var def_connect_ms: u32 = 5_000;
var def_request_ms: u32 = 30_000;
var def_idle_ms: u32 = 60_000;

pub fn http_set_default_timeouts(connect_ms: u32, request_ms: u32, idle_ms: u32) callconv(.c) void {
    if (connect_ms != 0) def_connect_ms = connect_ms;
    if (request_ms != 0) def_request_ms = request_ms;
    if (idle_ms != 0) def_idle_ms = idle_ms;
}

// ── request-latency histogram (item 6 wire-up) ───────────────

var latency_hist: ?*histogram.Histogram = null;
var latency_mutex: std.Thread.Mutex = .{};

fn latencyHist() ?*histogram.Histogram {
    latency_mutex.lock();
    defer latency_mutex.unlock();
    if (latency_hist) |h| return h;
    latency_hist = histogram.histogram_create();
    return latency_hist;
}

pub fn http_latency_percentile(p: f64) callconv(.c) f64 {
    return histogram.histogram_percentile(latencyHist(), p);
}
pub fn http_latency_count() callconv(.c) u64 {
    return histogram.histogram_count(latencyHist());
}
pub fn http_latency_reset() callconv(.c) void {
    histogram.histogram_reset(latencyHist());
}

// ── pool stats / shutdown (now backed by libcurl's share) ────
// libcurl manages the connection cache internally; we report open vs
// reuse counts derived from CURLINFO_NUM_CONNECTS. idle/active are not
// individually exposed by libcurl's cache, so they read 0.

pub fn http_pool_stats(out: [*]u8, max: usize) callconv(.c) i32 {
    const text = std.fmt.bufPrint(out[0..max], "opens={d}\treuses={d}\tidle=0\tactive=0", .{
        curlcore.curl_total_opens(), curlcore.curl_total_reuses(),
    }) catch {
        setError("pool stats buffer too small");
        return 0;
    };
    return @intCast(text.len);
}

/// Graceful client shutdown: drop libcurl's shared connection cache.
pub fn http_pool_shutdown() callconv(.c) i32 {
    curlcore.curl_reset_pool();
    return 0;
}

// ── host extraction (for outlier ejection + recording) ───────

fn hostOf(url: []const u8) ?[]const u8 {
    const uri = std.Uri.parse(url) catch return null;
    const hc = uri.host orelse return null;
    return switch (hc) {
        .raw => |s| s,
        .percent_encoded => |s| s,
    };
}

// ── public verbs ─────────────────────────────────────────────

pub fn http_get(url_ptr: [*]const u8, url_len: usize, out: [*]u8, max: usize) callconv(.c) i32 {
    return doRequest(0, url_ptr[0..url_len], "", "", "", out, max, def_connect_ms, def_request_ms, "");
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
    const ct = if (ct_len == 0) "application/octet-stream" else ct_ptr[0..ct_len];
    return doRequest(1, url_ptr[0..url_len], ct, body_ptr[0..body_len], "", out, out_max, def_connect_ms, def_request_ms, "");
}

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
    return doRequest(method_code, url_ptr[0..url_len], ct_ptr[0..ct_len], body_ptr[0..body_len], headers_ptr[0..headers_len], out, out_max, def_connect_ms, def_request_ms, "");
}

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
    return doRequest(method_code, url_ptr[0..url_len], ct_ptr[0..ct_len], body_ptr[0..body_len], headers_ptr[0..headers_len], out, out_max, cms, rms, "");
}

/// http_request_ex -- like http_request_with_timeouts but also takes an
/// `opts_blob` (newline "key=value" extra options: proxy/auth/mTLS/
/// cookies/verifyssl/followredirects/acceptencoding).
pub fn http_request_ex(
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
    opts_ptr: [*]const u8,
    opts_len: usize,
    out: [*]u8,
    out_max: usize,
) callconv(.c) i32 {
    const cms = if (connect_ms == 0) def_connect_ms else connect_ms;
    const rms = if (request_ms == 0) def_request_ms else request_ms;
    return doRequest(method_code, url_ptr[0..url_len], ct_ptr[0..ct_len], body_ptr[0..body_len], headers_ptr[0..headers_len], out, out_max, cms, rms, opts_ptr[0..opts_len]);
}

/// Response headers captured from the last request (raw "Name: Value" lines).
pub fn http_last_headers(out: [*]u8, max: usize) callconv(.c) i32 {
    return curlcore.curl_last_headers(out, max);
}
pub fn http_last_headers_len() callconv(.c) usize {
    return curlcore.curl_last_headers_len();
}

// ── core round-trip ──────────────────────────────────────────

fn doRequest(
    method_code: i32,
    url: []const u8,
    ct: []const u8,
    body: []const u8,
    headers: []const u8,
    out: [*]u8,
    max: usize,
    connect_ms: u32,
    request_ms: u32,
    opts: []const u8,
) i32 {
    last_error_len = 0;
    if (url.len == 0) {
        setError("empty URL");
        return -1;
    }
    const host = hostOf(url) orelse "";

    // Outlier ejection (Tier 1 item 7): skip a host that's flapping.
    if (host.len > 0 and resilience.outlier_should_eject(host.ptr, host.len) != 0) {
        setError("host ejected by outlier detector");
        last_body_len_v = 0;
        return -1;
    }

    const t0_ms = std.time.milliTimestamp();
    const status = curlcore.curl_request(
        method_code,
        url.ptr,
        url.len,
        headers.ptr,
        headers.len,
        ct.ptr,
        ct.len,
        body.ptr,
        body.len,
        out,
        max,
        connect_ms,
        request_ms,
        opts.ptr,
        opts.len,
    );
    const dt_ms = std.time.milliTimestamp() - t0_ms;
    histogram.histogram_record(latencyHist(), @floatFromInt(dt_ms));
    last_body_len_v = curlcore.curl_last_body_len();
    importCurlError();

    if (status > 0) {
        if (host.len > 0) resilience.outlier_record(host.ptr, host.len, 1, @floatFromInt(dt_ms));
    } else {
        if (host.len > 0) resilience.outlier_record(host.ptr, host.len, 0, 0);
    }
    return @intCast(status);
}

// ── parallel GET ─────────────────────────────────────────────
// std.Thread per URL; each worker does a pooled libcurl GET (the CURLSH
// share is thread-safe). Results concatenated into `out` separated by
// RECORD_SEP (0x1E); each record is "<status>:<body>".

const RECORD_SEP: u8 = 0x1E;
const MAX_PARALLEL: usize = 32;
const PARALLEL_BODY_CAP: usize = 2 * 1024 * 1024;

const gpa = std.heap.c_allocator;

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
    const status = doRequest(0, job.url, "", "", "", buf.ptr, buf.len, def_connect_ms, def_request_ms, "");
    job.status = status;
    if (status > 0) {
        job.body.appendSlice(gpa, buf[0..last_body_len_v]) catch {
            job.status = -1;
        };
    }
    job.done = true;
}

pub fn http_parallel_get(urls_ptr: [*]const u8, urls_len: usize, out: [*]u8, out_max: usize) callconv(.c) i32 {
    last_error_len = 0;
    if (urls_len == 0) {
        setError("empty URL list");
        return -1;
    }
    var url_buf: [MAX_PARALLEL][]const u8 = undefined;
    var n: usize = 0;
    var it = std.mem.splitScalar(u8, urls_ptr[0..urls_len], '\n');
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
    last_body_len_v = written;
    return @intCast(written);
}

// ── tests ────────────────────────────────────────────────────

test "http: empty URL is rejected" {
    var body_buf: [64]u8 = undefined;
    try std.testing.expect(http_get("", 0, &body_buf, 64) < 0);
    try std.testing.expect(http_last_error_len() > 0);
}

test "http: hostOf parses the host" {
    try std.testing.expectEqualStrings("example.com", hostOf("https://example.com/a?b=1").?);
    try std.testing.expectEqualStrings("localhost", hostOf("http://localhost:8080/").?);
}
