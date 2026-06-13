// HTTP client backed by std.http.Client.
//
// M-DEP3 slice 1: minimal GET / POST surface so stzNetwork can stop
// loading libcurl.ring. std.crypto.tls handles HTTPS out of the box
// for Zig 0.15, so we get http + https without a separate TLS lib.
//
// Surface:
//   http_get(url, body_out, body_max) -> status (>=0) or -1 on error
//   http_post(url, content_type, body, body_len, out, max) -> status
//   http_last_error_len() / http_last_error(buf, max)
//
// All operations are blocking. Async streaming + cookies + redirects
// past the std default + per-request headers are deferred to slice 2.

const std = @import("std");

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

/// GET `url`, write response body into `body_out[..body_max]`.
/// Returns HTTP status on success, -1 on transport error,
/// -2 on body-overflow (the response did not fit in body_max).
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
    return doRequest(.GET, url_ptr[0..url_len], null, null, &.{}, body_out, body_max) catch |err| {
        var fbuf: [200]u8 = undefined;
        const msg = std.fmt.bufPrint(&fbuf, "GET failed: {s}", .{@errorName(err)}) catch "GET failed";
        setError(msg);
        return -1;
    };
}

/// POST `url` with `body[..body_len]` payload. `content_type` may be
/// empty (defaults to application/octet-stream).
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
    return doRequest(.POST, url_ptr[0..url_len], ct, payload, &.{}, out, out_max) catch |err| {
        var fbuf: [200]u8 = undefined;
        const msg = std.fmt.bufPrint(&fbuf, "POST failed: {s}", .{@errorName(err)}) catch "POST failed";
        setError(msg);
        return -1;
    };
}

/// Generic request entry. `method_code` is one of:
/// 0=GET 1=POST 2=PUT 3=DELETE 4=HEAD 5=OPTIONS 6=PATCH
/// `headers_blob` is a newline-separated `Name: Value` block (may be empty).
/// `body` may be empty for verbs that don't carry one.
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
    clearError();
    if (url_len == 0) {
        setError("empty URL");
        return -1;
    }
    const method = methodFromCode(method_code) orelse {
        setError("unsupported HTTP method code");
        return -1;
    };
    var hdrs_buf: [32]std.http.Header = undefined;
    const headers = parseHeaderBlob(headers_ptr[0..headers_len], &hdrs_buf) catch {
        setError("too many headers (max 32)");
        return -1;
    };
    const ct_slice: ?[]const u8 = if (ct_len > 0) ct_ptr[0..ct_len] else null;
    const payload: ?[]const u8 = if (body_len > 0) body_ptr[0..body_len] else null;
    return doRequest(method, url_ptr[0..url_len], ct_slice, payload, headers, out, out_max) catch |err| {
        var fbuf: [200]u8 = undefined;
        const msg = std.fmt.bufPrint(&fbuf, "{s} failed: {s}", .{ @tagName(method), @errorName(err) }) catch "request failed";
        setError(msg);
        return -1;
    };
}

fn methodFromCode(code: i32) ?std.http.Method {
    return switch (code) {
        0 => .GET,
        1 => .POST,
        2 => .PUT,
        3 => .DELETE,
        4 => .HEAD,
        5 => .OPTIONS,
        6 => .PATCH,
        else => null,
    };
}

// ── Parallel GET ─────────────────────────────────────────────
// std.Thread per URL; each worker runs a blocking client.fetch.
// All results are concatenated into `out` separated by RECORD_SEP
// (ASCII 0x1E). Each record is "<status>:<body>". Ring side splits
// on RECORD_SEP and parses the prefix.

const RECORD_SEP: u8 = 0x1E;
const MAX_PARALLEL: usize = 32;

const ParallelJob = struct {
    url: []const u8,
    status: i32,
    body: std.ArrayList(u8),
    err: ?[]u8,
    done: bool,
};

fn parallelWorker(job: *ParallelJob) void {
    var client = std.http.Client{ .allocator = gpa };
    defer client.deinit();
    var allocating = std.io.Writer.Allocating.init(gpa);
    defer allocating.deinit();

    const res = client.fetch(.{
        .method = .GET,
        .location = .{ .url = job.url },
        .response_writer = &allocating.writer,
    }) catch |err| {
        job.status = -1;
        const fbuf = std.fmt.allocPrint(gpa, "{s}", .{@errorName(err)}) catch null;
        job.err = fbuf;
        job.done = true;
        return;
    };
    job.status = @intCast(@intFromEnum(res.status));
    const buffered = allocating.writer.buffered();
    job.body.appendSlice(gpa, buffered) catch {
        job.status = -1;
        job.err = gpa.dupe(u8, "oom") catch null;
    };
    job.done = true;
}

/// http_parallel_get -- fire N GETs in parallel, write
/// "<status>:<body><RS>"... into `out`. `urls_blob` is a `\n`-
/// separated list of URLs. Returns total bytes written, or -2 on
/// overflow, -1 on argument error.
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

    // Split.
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
        for (jobs) |*j| {
            j.body.deinit(gpa);
            if (j.err) |e| gpa.free(e);
        }
        gpa.free(jobs);
    }

    const threads = gpa.alloc(std.Thread, n) catch {
        setError("oom (threads)");
        return -1;
    };
    defer gpa.free(threads);

    for (jobs, 0..) |*j, i| {
        j.* = .{
            .url = url_buf[i],
            .status = 0,
            .body = .{},
            .err = null,
            .done = false,
        };
        threads[i] = std.Thread.spawn(.{}, parallelWorker, .{j}) catch {
            j.status = -1;
            j.err = gpa.dupe(u8, "spawn failed") catch null;
            j.done = true;
            // Leave the thread slot uninitialised; we'll detect via
            // the done flag and skip the join below.
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

fn parseHeaderBlob(blob: []const u8, out: []std.http.Header) error{TooMany}![]const std.http.Header {
    if (blob.len == 0) return out[0..0];
    var n: usize = 0;
    var it = std.mem.splitScalar(u8, blob, '\n');
    while (it.next()) |raw_line| {
        var line = raw_line;
        if (line.len > 0 and line[line.len - 1] == '\r') line = line[0 .. line.len - 1];
        if (line.len == 0) continue;
        const colon = std.mem.indexOfScalar(u8, line, ':') orelse continue;
        if (n >= out.len) return error.TooMany;
        var value = line[colon + 1 ..];
        while (value.len > 0 and (value[0] == ' ' or value[0] == '\t')) value = value[1..];
        out[n] = .{ .name = line[0..colon], .value = value };
        n += 1;
    }
    return out[0..n];
}

// ── internal ─────────────────────────────────────────────────

fn doRequest(
    method: std.http.Method,
    url: []const u8,
    content_type: ?[]const u8,
    payload: ?[]const u8,
    user_headers: []const std.http.Header,
    out: [*]u8,
    max: usize,
) !i32 {
    var client = std.http.Client{ .allocator = gpa };
    defer client.deinit();

    var allocating = std.io.Writer.Allocating.init(gpa);
    defer allocating.deinit();

    // Build the extra-headers slice: user headers + (optional Content-Type
    // if not already supplied by the caller).
    var merged: [40]std.http.Header = undefined;
    var n: usize = 0;
    var ct_already = false;
    for (user_headers) |h| {
        if (std.ascii.eqlIgnoreCase(h.name, "content-type")) ct_already = true;
        if (n >= merged.len) break;
        merged[n] = h;
        n += 1;
    }
    if (content_type) |ct| if (!ct_already and n < merged.len) {
        merged[n] = .{ .name = "Content-Type", .value = ct };
        n += 1;
    };

    const res = try client.fetch(.{
        .method = method,
        .location = .{ .url = url },
        .response_writer = &allocating.writer,
        .extra_headers = merged[0..n],
        .payload = payload,
    });

    const status: i32 = @intCast(@intFromEnum(res.status));

    const written = allocating.writer.buffered();
    if (written.len > max) {
        setError("response body exceeds output buffer");
        last_body_len = 0;
        return -2;
    }
    @memcpy(out[0..written.len], written);
    last_body_len = written.len;

    return status;
}

// ── tests ────────────────────────────────────────────────────

// Network tests require a live server and are excluded from the
// default Windows test loop (per the L99 guardrail). They run only
// when `STZ_NET_TESTS=1` is set at build/test time.

test "http: URL parse rejection surface" {
    var body_buf: [256]u8 = undefined;
    const rc = http_get("not a url", 9, &body_buf, 256);
    try std.testing.expect(rc < 0);
    try std.testing.expect(http_last_error_len() > 0);
}
