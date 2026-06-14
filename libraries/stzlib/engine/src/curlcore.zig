// HTTP transport on vendored libcurl (Tier 2 -- adopt libcurl).
//
// libcurl is the industry-standard HTTP stack: HTTP/1.1 + HTTP/2, TLS
// (native Schannel on Windows -- no extra dependency), connection
// pooling, DNS cache, redirects, proxy. We vendor it as C source (see
// build.zig addLibcurl) and replace the custom httpcore/http_pool path.
//
// This slice is the binding + a smoke proof (curl_version + a real
// HTTPS GET through Schannel). The full request surface that http.zig
// drives lands in the next slice.

const std = @import("std");
const c = @cImport({
    @cInclude("curl/curl.h");
});

var global_inited: bool = false;
var global_mutex: std.Thread.Mutex = .{};

/// curl_global_init is not thread-safe; do it once under a lock before
/// the first easy handle is created.
pub fn ensureGlobalInit() void {
    global_mutex.lock();
    defer global_mutex.unlock();
    if (global_inited) return;
    _ = c.curl_global_init(c.CURL_GLOBAL_DEFAULT);
    global_inited = true;
}

/// libcurl version string, e.g. "libcurl/8.20.0 Schannel ...".
pub fn version() callconv(.c) [*c]const u8 {
    return c.curl_version();
}

const SmokeBuf = struct {
    data: [*]u8,
    cap: usize,
    len: usize,
};

fn writeCb(ptr: [*c]u8, size: usize, nmemb: usize, userdata: ?*anyopaque) callconv(.c) usize {
    const total = size * nmemb;
    const b: *SmokeBuf = @ptrCast(@alignCast(userdata.?));
    const room = b.cap - b.len;
    const n = @min(total, room);
    if (n > 0) {
        @memcpy(b.data[b.len .. b.len + n], ptr[0..n]);
        b.len += n;
    }
    return total; // report full consumption so curl doesn't abort on overflow
}

var smoke_len: usize = 0;

pub fn smoke_last_len() callconv(.c) usize {
    return smoke_len;
}

/// Smoke: GET an https URL through Schannel, write the body into
/// out[0..max], return the HTTP status (or -1 on transport error).
/// Proves the vendored libcurl compiles, links, and does real TLS.
pub fn smoke_get(url_ptr: [*:0]const u8, out: [*]u8, max: usize) callconv(.c) i64 {
    ensureGlobalInit();
    smoke_len = 0;
    const h = c.curl_easy_init() orelse return -1;
    defer c.curl_easy_cleanup(h);
    var buf = SmokeBuf{ .data = out, .cap = max, .len = 0 };
    _ = c.curl_easy_setopt(h, c.CURLOPT_URL, url_ptr);
    _ = c.curl_easy_setopt(h, c.CURLOPT_WRITEFUNCTION, &writeCb);
    _ = c.curl_easy_setopt(h, c.CURLOPT_WRITEDATA, &buf);
    _ = c.curl_easy_setopt(h, c.CURLOPT_FOLLOWLOCATION, @as(c_long, 1));
    _ = c.curl_easy_setopt(h, c.CURLOPT_TIMEOUT, @as(c_long, 20));
    _ = c.curl_easy_setopt(h, c.CURLOPT_USERAGENT, "Softanza-HTTP/2.0");
    const rc = c.curl_easy_perform(h);
    if (rc != c.CURLE_OK) return -1;
    var code: c_long = 0;
    _ = c.curl_easy_getinfo(h, c.CURLINFO_RESPONSE_CODE, &code);
    smoke_len = buf.len;
    return @intCast(code);
}
