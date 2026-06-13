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
