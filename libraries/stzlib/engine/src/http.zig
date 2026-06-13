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
    return doRequest(.GET, url_ptr[0..url_len], null, null, body_out, body_max) catch |err| {
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
    return doRequest(.POST, url_ptr[0..url_len], ct, payload, out, out_max) catch |err| {
        var fbuf: [200]u8 = undefined;
        const msg = std.fmt.bufPrint(&fbuf, "POST failed: {s}", .{@errorName(err)}) catch "POST failed";
        setError(msg);
        return -1;
    };
}

// ── internal ─────────────────────────────────────────────────

fn doRequest(
    method: std.http.Method,
    url: []const u8,
    content_type: ?[]const u8,
    payload: ?[]const u8,
    out: [*]u8,
    max: usize,
) !i32 {
    var client = std.http.Client{ .allocator = gpa };
    defer client.deinit();

    var allocating = std.io.Writer.Allocating.init(gpa);
    defer allocating.deinit();

    const ct = std.http.Header{
        .name = "Content-Type",
        .value = content_type orelse "application/octet-stream",
    };
    const extra_with_ct = [_]std.http.Header{ct};
    const extra: []const std.http.Header = if (content_type != null) extra_with_ct[0..] else &[_]std.http.Header{};

    const res = try client.fetch(.{
        .method = method,
        .location = .{ .url = url },
        .response_writer = &allocating.writer,
        .extra_headers = extra,
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
