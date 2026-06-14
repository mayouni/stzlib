// HTTP transport on vendored libcurl (Tier 2 -- adopt libcurl).
//
// libcurl is the industry-standard HTTP stack: HTTP/1.1 + HTTP/2, TLS
// (native Schannel on Windows -- no extra dependency), connection
// pooling, DNS cache, redirects, proxy. We vendor it as C source (see
// build.zig addLibcurl) and it replaces the custom httpcore/http_pool.
//
// Pooling + DNS cache + TLS-session reuse come from a process-wide
// CURLSH "share" handle that all easy handles attach to; the share is
// made thread-safe with per-data-type lock callbacks so the threaded
// parallel-GET path is safe. Each request is a curl_easy_perform on a
// short-lived easy handle that draws warm connections from the share.

const std = @import("std");
const c = @cImport({
    @cInclude("curl/curl.h");
});

// ── global init + shared connection/DNS/TLS cache ────────────

var global_inited: bool = false;
var init_mutex: std.Thread.Mutex = .{};
var share: ?*c.CURLSH = null;

// One mutex per curl_lock_data value (SHARE..HSTS are <= 7). curl may
// hold locks for different data types simultaneously, so a single mutex
// would deadlock -- index by data type. `data`/`access` are taken as
// c_uint to stay agnostic of translate-c's enum representation (ABI is
// identical through the variadic setopt).
var share_locks: [16]std.Thread.Mutex = [_]std.Thread.Mutex{.{}} ** 16;

fn lockCb(handle: ?*anyopaque, data: c_uint, access: c_uint, user: ?*anyopaque) callconv(.c) void {
    _ = handle;
    _ = access;
    _ = user;
    const i: usize = @min(@as(usize, @intCast(data)), share_locks.len - 1);
    share_locks[i].lock();
}

fn unlockCb(handle: ?*anyopaque, data: c_uint, user: ?*anyopaque) callconv(.c) void {
    _ = handle;
    _ = user;
    const i: usize = @min(@as(usize, @intCast(data)), share_locks.len - 1);
    share_locks[i].unlock();
}

fn ensureInit() void {
    init_mutex.lock();
    defer init_mutex.unlock();
    if (global_inited) return;
    _ = c.curl_global_init(c.CURL_GLOBAL_DEFAULT);
    share = c.curl_share_init();
    if (share) |sh| {
        _ = c.curl_share_setopt(sh, c.CURLSHOPT_LOCKFUNC, &lockCb);
        _ = c.curl_share_setopt(sh, c.CURLSHOPT_UNLOCKFUNC, &unlockCb);
        _ = c.curl_share_setopt(sh, c.CURLSHOPT_SHARE, @as(c_long, c.CURL_LOCK_DATA_DNS));
        _ = c.curl_share_setopt(sh, c.CURLSHOPT_SHARE, @as(c_long, c.CURL_LOCK_DATA_CONNECT));
        _ = c.curl_share_setopt(sh, c.CURLSHOPT_SHARE, @as(c_long, c.CURL_LOCK_DATA_SSL_SESSION));
    }
    global_inited = true;
}

// ── stats + last error / body ────────────────────────────────

var total_opens = std.atomic.Value(u64).init(0);
var total_reuses = std.atomic.Value(u64).init(0);
var last_body_len: usize = 0;
var last_error_buf: [512]u8 = undefined;
var last_error_len: usize = 0;

fn setError(msg: []const u8) void {
    const n = @min(msg.len, last_error_buf.len);
    @memcpy(last_error_buf[0..n], msg[0..n]);
    last_error_len = n;
}

pub fn curl_last_body_len() callconv(.c) usize {
    return last_body_len;
}

pub fn curl_last_error_len() callconv(.c) usize {
    return last_error_len;
}

pub fn curl_last_error(out: [*]u8, max: usize) callconv(.c) i32 {
    const n = @min(last_error_len, max);
    if (n == 0) return 0;
    @memcpy(out[0..n], last_error_buf[0..n]);
    return @intCast(n);
}

pub fn curl_total_opens() callconv(.c) u64 {
    return total_opens.load(.monotonic);
}
pub fn curl_total_reuses() callconv(.c) u64 {
    return total_reuses.load(.monotonic);
}

/// libcurl version string (incl. TLS backend).
pub fn version() callconv(.c) [*c]const u8 {
    return c.curl_version();
}

/// Drop the shared connection cache (graceful client shutdown): tear the
/// share down and rebuild it so subsequent requests open fresh.
pub fn curl_reset_pool() callconv(.c) void {
    init_mutex.lock();
    defer init_mutex.unlock();
    if (share) |sh| {
        _ = c.curl_share_cleanup(sh);
        share = null;
    }
    share = c.curl_share_init();
    if (share) |sh| {
        _ = c.curl_share_setopt(sh, c.CURLSHOPT_LOCKFUNC, &lockCb);
        _ = c.curl_share_setopt(sh, c.CURLSHOPT_UNLOCKFUNC, &unlockCb);
        _ = c.curl_share_setopt(sh, c.CURLSHOPT_SHARE, @as(c_long, c.CURL_LOCK_DATA_DNS));
        _ = c.curl_share_setopt(sh, c.CURLSHOPT_SHARE, @as(c_long, c.CURL_LOCK_DATA_CONNECT));
        _ = c.curl_share_setopt(sh, c.CURLSHOPT_SHARE, @as(c_long, c.CURL_LOCK_DATA_SSL_SESSION));
    }
}

// ── request ──────────────────────────────────────────────────

const Buf = struct {
    data: [*]u8,
    cap: usize,
    len: usize,
    overflow: bool,
};

fn writeCb(ptr: [*c]u8, size: usize, nmemb: usize, userdata: ?*anyopaque) callconv(.c) usize {
    const total = size * nmemb;
    const b: *Buf = @ptrCast(@alignCast(userdata.?));
    const room = b.cap - b.len;
    const n = @min(total, room);
    if (n > 0) {
        @memcpy(b.data[b.len .. b.len + n], ptr[0..n]);
        b.len += n;
    }
    if (n < total) b.overflow = true;
    return total; // always "consume" so curl completes; overflow flagged
}

fn methodName(code: i32) ?[]const u8 {
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

/// Perform an HTTP request. Returns HTTP status (>0), -1 on transport
/// error (message in curl_last_error), or -2 on response overflow.
/// `headers_blob` is a newline-separated "Name: Value" block.
pub fn curl_request(
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
    max: usize,
    connect_ms: u32,
    request_ms: u32,
) callconv(.c) i64 {
    last_error_len = 0;
    last_body_len = 0;
    ensureInit();

    const method = methodName(method_code) orelse {
        setError("unsupported HTTP method code");
        return -1;
    };

    // Null-terminate the URL for curl.
    var url_buf: [8192]u8 = undefined;
    if (url_len >= url_buf.len) {
        setError("URL too long");
        return -1;
    }
    @memcpy(url_buf[0..url_len], url_ptr[0..url_len]);
    url_buf[url_len] = 0;

    const h = c.curl_easy_init() orelse {
        setError("curl_easy_init failed");
        return -1;
    };
    defer c.curl_easy_cleanup(h);

    var buf = Buf{ .data = out, .cap = max, .len = 0, .overflow = false };
    _ = c.curl_easy_setopt(h, c.CURLOPT_URL, @as([*:0]const u8, @ptrCast(&url_buf)));
    if (share) |sh| _ = c.curl_easy_setopt(h, c.CURLOPT_SHARE, sh);
    _ = c.curl_easy_setopt(h, c.CURLOPT_WRITEFUNCTION, &writeCb);
    _ = c.curl_easy_setopt(h, c.CURLOPT_WRITEDATA, &buf);
    _ = c.curl_easy_setopt(h, c.CURLOPT_FOLLOWLOCATION, @as(c_long, 1));
    _ = c.curl_easy_setopt(h, c.CURLOPT_MAXREDIRS, @as(c_long, 10));
    _ = c.curl_easy_setopt(h, c.CURLOPT_NOSIGNAL, @as(c_long, 1));
    _ = c.curl_easy_setopt(h, c.CURLOPT_USERAGENT, "Softanza-HTTP/2.0");
    if (connect_ms > 0) _ = c.curl_easy_setopt(h, c.CURLOPT_CONNECTTIMEOUT_MS, @as(c_long, @intCast(connect_ms)));
    if (request_ms > 0) _ = c.curl_easy_setopt(h, c.CURLOPT_TIMEOUT_MS, @as(c_long, @intCast(request_ms)));

    // Method.
    switch (method_code) {
        0 => _ = c.curl_easy_setopt(h, c.CURLOPT_HTTPGET, @as(c_long, 1)),
        4 => _ = c.curl_easy_setopt(h, c.CURLOPT_NOBODY, @as(c_long, 1)),
        1 => { // POST
            _ = c.curl_easy_setopt(h, c.CURLOPT_POST, @as(c_long, 1));
            _ = c.curl_easy_setopt(h, c.CURLOPT_POSTFIELDSIZE, @as(c_long, @intCast(body_len)));
            _ = c.curl_easy_setopt(h, c.CURLOPT_COPYPOSTFIELDS, body_ptr);
        },
        else => { // PUT / DELETE / OPTIONS / PATCH
            _ = c.curl_easy_setopt(h, c.CURLOPT_CUSTOMREQUEST, method.ptr);
            if (body_len > 0) {
                _ = c.curl_easy_setopt(h, c.CURLOPT_POSTFIELDSIZE, @as(c_long, @intCast(body_len)));
                _ = c.curl_easy_setopt(h, c.CURLOPT_COPYPOSTFIELDS, body_ptr);
            }
        },
    }

    // Headers (blob lines) + optional Content-Type.
    var slist: ?*c.curl_slist = null;
    defer if (slist != null) c.curl_slist_free_all(slist);
    var line_buf: [8192]u8 = undefined;
    var ct_in_blob = false;
    if (headers_len > 0) {
        var it = std.mem.splitScalar(u8, headers_ptr[0..headers_len], '\n');
        while (it.next()) |raw| {
            var line = raw;
            if (line.len > 0 and line[line.len - 1] == '\r') line = line[0 .. line.len - 1];
            if (line.len == 0 or line.len >= line_buf.len) continue;
            if (std.ascii.startsWithIgnoreCase(line, "content-type")) ct_in_blob = true;
            @memcpy(line_buf[0..line.len], line);
            line_buf[line.len] = 0;
            slist = c.curl_slist_append(slist, @ptrCast(&line_buf));
        }
    }
    if (ct_len > 0 and !ct_in_blob) {
        const prefix = "Content-Type: ";
        if (prefix.len + ct_len < line_buf.len) {
            @memcpy(line_buf[0..prefix.len], prefix);
            @memcpy(line_buf[prefix.len .. prefix.len + ct_len], ct_ptr[0..ct_len]);
            line_buf[prefix.len + ct_len] = 0;
            slist = c.curl_slist_append(slist, @ptrCast(&line_buf));
        }
    }
    if (slist != null) _ = c.curl_easy_setopt(h, c.CURLOPT_HTTPHEADER, slist);

    const rc = c.curl_easy_perform(h);
    if (rc != c.CURLE_OK) {
        var fbuf: [256]u8 = undefined;
        const es = c.curl_easy_strerror(rc);
        const es_slice = if (es != null) std.mem.span(es) else "transport error";
        const msg = std.fmt.bufPrint(&fbuf, "{s} failed: {s}", .{ method, es_slice }) catch "request failed";
        setError(msg);
        return -1;
    }

    if (buf.overflow) {
        setError("response body exceeds output buffer");
        return -2;
    }

    var code: c_long = 0;
    _ = c.curl_easy_getinfo(h, c.CURLINFO_RESPONSE_CODE, &code);
    var num_connects: c_long = 0;
    _ = c.curl_easy_getinfo(h, c.CURLINFO_NUM_CONNECTS, &num_connects);
    if (num_connects > 0) {
        _ = total_opens.fetchAdd(@intCast(num_connects), .monotonic);
    } else {
        _ = total_reuses.fetchAdd(1, .monotonic);
    }

    last_body_len = buf.len;
    return @intCast(code);
}
