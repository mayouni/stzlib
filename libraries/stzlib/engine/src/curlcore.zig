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
var last_http_version: i32 = 0; // 1 = HTTP/1.x, 2 = HTTP/2, 3 = HTTP/3
// THREADLOCAL: parallel GET runs one of these per thread, and each worker reads
// its own result immediately after its own request. A shared global here means the
// last thread to finish decides how many bytes every other worker copies out.
threadlocal var last_body_len: usize = 0;

// Response headers captured per request (raw "Name: Value\r\n" lines).
const HDR_CAP: usize = 64 * 1024;
var hdr_buf: [HDR_CAP]u8 = undefined;
var hdr_len: usize = 0;

pub fn curl_last_headers_len() callconv(.c) usize {
    return hdr_len;
}

pub fn curl_last_headers(out: [*]u8, max: usize) callconv(.c) i32 {
    const n = @min(hdr_len, max);
    if (n == 0) return 0;
    @memcpy(out[0..n], hdr_buf[0..n]);
    return @intCast(n);
}

fn headerCb(ptr: [*c]u8, size: usize, nitems: usize, userdata: ?*anyopaque) callconv(.c) usize {
    _ = userdata;
    const total = size * nitems;
    const room = HDR_CAP - hdr_len;
    const n = @min(total, room);
    if (n > 0) {
        @memcpy(hdr_buf[hdr_len .. hdr_len + n], ptr[0..n]);
        hdr_len += n;
    }
    return total;
}
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

/// Negotiated HTTP version of the last request: 1 (HTTP/1.x), 2 (HTTP/2),
/// 3 (HTTP/3), or 0 if none yet.
pub fn curl_last_http_version() callconv(.c) i32 {
    return last_http_version;
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

// ── download to a file, checked against a recorded digest ────
// A model is up to gigabytes: it never passes through memory. The body streams into <path>.part while its SHA-256 and length are
// computed, and the file takes its name only when both are the recorded ones -- so a partial, a substituted or an oversized body never
// sits at the path a program loads from. No recorded digest is a refusal (the shape of model_digest.zig), never a download "to check".

pub const DL_OK: i64 = 1;
pub const DL_TRANSPORT: i64 = -1;
pub const DL_STATUS: i64 = -2;
pub const DL_MISMATCH: i64 = -3;
pub const DL_SIZE: i64 = -4;
pub const DL_FILE: i64 = -5;
pub const DL_NODIGEST: i64 = -6;

const Sink = struct {
    file: std.fs.File,
    hash: std.crypto.hash.sha2.Sha256,
    n: u64,
    limit: u64,
    write_failed: bool,
    too_big: bool,
};

fn sinkCb(ptr: [*c]u8, size: usize, nmemb: usize, userdata: ?*anyopaque) callconv(.c) usize {
    const total = size * nmemb;
    const s: *Sink = @ptrCast(@alignCast(userdata.?));
    if (s.limit > 0 and s.n + total > s.limit) {
        s.too_big = true;
        return 0; // a short count aborts the transfer (CURLE_WRITE_ERROR)
    }
    s.file.writeAll(ptr[0..total]) catch {
        s.write_failed = true;
        return 0;
    };
    s.hash.update(ptr[0..total]);
    s.n += total;
    return total;
}

var dl_bytes: u64 = 0;
var dl_hex: [65]u8 = [_]u8{0} ** 65;

/// Bytes received by the last download (kept or not).
pub fn curl_download_last_bytes() callconv(.c) u64 {
    return dl_bytes;
}

/// The SHA-256 of the last download's body, 64 hex characters ("" before any).
pub fn curl_download_last_sha256() callconv(.c) [*:0]const u8 {
    return @ptrCast(&dl_hex);
}

fn dlError(comptime fmt: []const u8, args: anytype) void {
    var b: [512]u8 = undefined;
    const s = std.fmt.bufPrint(&b, fmt, args) catch "download failed";
    setError(s);
}

/// GET url into path, kept only when the body's sha256 is want_hex (and its length want_bytes, when not 0).
/// DL_OK, or DL_TRANSPORT / DL_STATUS / DL_MISMATCH / DL_SIZE / DL_FILE / DL_NODIGEST with the reason in the last error.
pub fn curl_download(
    url_ptr: [*]const u8,
    url_len: usize,
    path_ptr: [*]const u8,
    path_len: usize,
    hex_ptr: [*]const u8,
    hex_len: usize,
    want_bytes: u64,
    opts_ptr: [*]const u8,
    opts_len: usize,
    connect_ms: u32,
) callconv(.c) i64 {
    last_error_len = 0;
    dl_bytes = 0;
    dl_hex[0] = 0;
    ensureInit();
    const path = path_ptr[0..path_len];
    var want: [64]u8 = undefined;
    if (hex_len != 64) {
        dlError("no recorded sha256 for {s}: a model is fetched only against the digest it must have", .{path});
        return DL_NODIGEST;
    }
    for (hex_ptr[0..64], 0..) |ch, i| {
        if (!std.ascii.isHex(ch)) {
            dlError("the recorded sha256 for {s} is not 64 hex characters", .{path});
            return DL_NODIGEST;
        }
        want[i] = std.ascii.toLower(ch);
    }
    var url_buf: [8192]u8 = undefined;
    if (url_len >= url_buf.len or path_len + 6 >= 4096) {
        setError("URL or path too long");
        return DL_TRANSPORT;
    }
    @memcpy(url_buf[0..url_len], url_ptr[0..url_len]);
    url_buf[url_len] = 0;

    var part_buf: [4096]u8 = undefined;
    const part = std.fmt.bufPrint(&part_buf, "{s}.part", .{path}) catch return DL_FILE;
    if (std.fs.path.dirname(path)) |d| std.fs.cwd().makePath(d) catch {};
    const file = std.fs.cwd().createFile(part, .{ .truncate = true }) catch {
        dlError("cannot write {s}", .{part});
        return DL_FILE;
    };
    var sink = Sink{ .file = file, .hash = std.crypto.hash.sha2.Sha256.init(.{}), .n = 0, .limit = want_bytes, .write_failed = false, .too_big = false };
    var kept = false;
    var closed = false;
    defer {
        if (!closed) sink.file.close();
        if (!kept) std.fs.cwd().deleteFile(part) catch {};
    }

    const h = c.curl_easy_init() orelse {
        setError("curl_easy_init failed");
        return DL_TRANSPORT;
    };
    defer c.curl_easy_cleanup(h);
    _ = c.curl_easy_setopt(h, c.CURLOPT_URL, @as([*:0]const u8, @ptrCast(&url_buf)));
    if (share) |sh| _ = c.curl_easy_setopt(h, c.CURLOPT_SHARE, sh);
    _ = c.curl_easy_setopt(h, c.CURLOPT_WRITEFUNCTION, &sinkCb);
    _ = c.curl_easy_setopt(h, c.CURLOPT_WRITEDATA, &sink);
    _ = c.curl_easy_setopt(h, c.CURLOPT_FOLLOWLOCATION, @as(c_long, 1)); // a hub answers with a redirect to its CDN
    _ = c.curl_easy_setopt(h, c.CURLOPT_MAXREDIRS, @as(c_long, 10));
    _ = c.curl_easy_setopt(h, c.CURLOPT_NOSIGNAL, @as(c_long, 1));
    _ = c.curl_easy_setopt(h, c.CURLOPT_USERAGENT, "Softanza-HTTP/2.0");
    _ = c.curl_easy_setopt(h, c.CURLOPT_HTTPGET, @as(c_long, 1));
    _ = c.curl_easy_setopt(h, c.CURLOPT_FAILONERROR, @as(c_long, 0));
    if (connect_ms > 0) _ = c.curl_easy_setopt(h, c.CURLOPT_CONNECTTIMEOUT_MS, @as(c_long, @intCast(connect_ms)));
    // no total timeout (a gigabyte takes what it takes); a transfer slower than 1 KB/s for a minute is given up
    _ = c.curl_easy_setopt(h, c.CURLOPT_LOW_SPEED_LIMIT, @as(c_long, 1024));
    _ = c.curl_easy_setopt(h, c.CURLOPT_LOW_SPEED_TIME, @as(c_long, 60));
    applyOpts(h, opts_ptr[0..opts_len]);

    const rc = c.curl_easy_perform(h);
    dl_bytes = sink.n;
    if (sink.too_big) {
        dlError("{s}: the body passed the recorded {d} bytes; nothing was kept", .{ path, want_bytes });
        return DL_SIZE;
    }
    if (sink.write_failed) {
        dlError("{s}: writing {s} failed (disk full?); nothing was kept", .{ path, part });
        return DL_FILE;
    }
    if (rc != c.CURLE_OK) {
        const es = c.curl_easy_strerror(rc);
        dlError("GET {s} failed: {s}", .{ url_ptr[0..url_len], if (es != null) std.mem.span(es) else "transport error" });
        return DL_TRANSPORT;
    }
    var code: c_long = 0;
    _ = c.curl_easy_getinfo(h, c.CURLINFO_RESPONSE_CODE, &code);
    if (code < 200 or code > 299) {
        dlError("GET {s} answered HTTP {d}; nothing was kept", .{ url_ptr[0..url_len], code });
        return DL_STATUS;
    }
    var raw: [32]u8 = undefined;
    sink.hash.final(&raw);
    const got = std.fmt.bytesToHex(raw, .lower);
    @memcpy(dl_hex[0..64], &got);
    dl_hex[64] = 0;
    if (want_bytes > 0 and sink.n != want_bytes) {
        dlError("{s}: {d} bytes arrived, not the recorded {d}; nothing was kept", .{ path, sink.n, want_bytes });
        return DL_SIZE;
    }
    if (!std.mem.eql(u8, &got, &want)) {
        dlError("{s}: the body's sha256 is {s}, not the recorded {s}; nothing was kept", .{ path, got[0..], want[0..] });
        return DL_MISMATCH;
    }
    sink.file.close(); // Windows renames no open file
    closed = true;
    std.fs.cwd().rename(part, path) catch {
        dlError("{s} was fetched and verified but could not be renamed to {s}", .{ part, path });
        return DL_FILE;
    };
    kept = true;
    return DL_OK;
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

fn eqk(key: []const u8, name: []const u8) bool {
    return std.mem.eql(u8, key, name);
}

// CURLAUTH_* are unsigned bitmasks (CURLAUTH_ANY ~= 0xFFFFFFEF) that
// don't fit c_long directly; bitcast through c_ulong (same width as
// c_long on every platform) to pass them to CURLOPT_HTTPAUTH.
fn am(v: c_ulong) c_long {
    return @bitCast(v);
}
fn authMask(val: []const u8) c_long {
    if (eqk(val, "basic")) return am(c.CURLAUTH_BASIC);
    if (eqk(val, "digest")) return am(c.CURLAUTH_DIGEST);
    if (eqk(val, "bearer")) return am(c.CURLAUTH_BEARER);
    if (eqk(val, "ntlm")) return am(c.CURLAUTH_NTLM);
    if (eqk(val, "negotiate")) return am(c.CURLAUTH_NEGOTIATE);
    return am(c.CURLAUTH_ANY);
}

// Apply an extra-options blob: newline-separated "key=value" lines that
// map to libcurl easy options. Lets stzHttpClient expose proxy / auth /
// mTLS / cookies / verify / redirect without exploding the C-ABI arity.
fn applyOpts(h: ?*c.CURL, opts: []const u8) void {
    if (opts.len == 0) return;
    var scratch: [4096]u8 = undefined;
    var it = std.mem.splitScalar(u8, opts, '\n');
    while (it.next()) |raw| {
        var line = raw;
        if (line.len > 0 and line[line.len - 1] == '\r') line = line[0 .. line.len - 1];
        if (line.len == 0) continue;
        const eq = std.mem.indexOfScalar(u8, line, '=') orelse continue;
        const key = line[0..eq];
        const val = line[eq + 1 ..];
        if (val.len + 1 > scratch.len) continue;
        @memcpy(scratch[0..val.len], val);
        scratch[val.len] = 0;
        const vz: [*:0]const u8 = @ptrCast(&scratch);
        if (eqk(key, "proxy")) {
            _ = c.curl_easy_setopt(h, c.CURLOPT_PROXY, vz);
        } else if (eqk(key, "proxyuserpwd")) {
            _ = c.curl_easy_setopt(h, c.CURLOPT_PROXYUSERPWD, vz);
        } else if (eqk(key, "userpwd")) {
            _ = c.curl_easy_setopt(h, c.CURLOPT_USERPWD, vz);
            _ = c.curl_easy_setopt(h, c.CURLOPT_HTTPAUTH, @as(c_long, c.CURLAUTH_BASIC));
        } else if (eqk(key, "bearer")) {
            _ = c.curl_easy_setopt(h, c.CURLOPT_XOAUTH2_BEARER, vz);
            _ = c.curl_easy_setopt(h, c.CURLOPT_HTTPAUTH, @as(c_long, c.CURLAUTH_BEARER));
        } else if (eqk(key, "authtype")) {
            _ = c.curl_easy_setopt(h, c.CURLOPT_HTTPAUTH, authMask(val));
        } else if (eqk(key, "sslcert")) {
            _ = c.curl_easy_setopt(h, c.CURLOPT_SSLCERT, vz);
        } else if (eqk(key, "sslkey")) {
            _ = c.curl_easy_setopt(h, c.CURLOPT_SSLKEY, vz);
        } else if (eqk(key, "cookiefile")) {
            _ = c.curl_easy_setopt(h, c.CURLOPT_COOKIEFILE, vz);
        } else if (eqk(key, "cookiejar")) {
            _ = c.curl_easy_setopt(h, c.CURLOPT_COOKIEJAR, vz);
        } else if (eqk(key, "acceptencoding")) {
            _ = c.curl_easy_setopt(h, c.CURLOPT_ACCEPT_ENCODING, vz);
        } else if (eqk(key, "verifyssl")) {
            if (eqk(val, "0")) {
                _ = c.curl_easy_setopt(h, c.CURLOPT_SSL_VERIFYPEER, @as(c_long, 0));
                _ = c.curl_easy_setopt(h, c.CURLOPT_SSL_VERIFYHOST, @as(c_long, 0));
            }
        } else if (eqk(key, "followredirects")) {
            if (eqk(val, "0")) _ = c.curl_easy_setopt(h, c.CURLOPT_FOLLOWLOCATION, @as(c_long, 0));
        }
    }
}

/// Perform an HTTP request. Returns HTTP status (>0), -1 on transport
/// error (message in curl_last_error), or -2 on response overflow.
/// `headers_blob` is a newline-separated "Name: Value" block; `opts_blob`
/// is a newline-separated "key=value" block of extra request options.
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
    opts_ptr: [*]const u8,
    opts_len: usize,
) callconv(.c) i64 {
    last_error_len = 0;
    last_body_len = 0;
    hdr_len = 0;
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
    // Prefer HTTP/2 over TLS (ALPN); falls back to 1.1 automatically.
    _ = c.curl_easy_setopt(h, c.CURLOPT_HTTP_VERSION, @as(c_long, c.CURL_HTTP_VERSION_2TLS));
    // Capture response headers.
    _ = c.curl_easy_setopt(h, c.CURLOPT_HEADERFUNCTION, &headerCb);
    _ = c.curl_easy_setopt(h, c.CURLOPT_HEADERDATA, @as(?*anyopaque, null));
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

    // Extra options (proxy/auth/mTLS/cookies/verify/redirect) -- applied
    // last so they can override the defaults set above.
    applyOpts(h, opts_ptr[0..opts_len]);

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
    var http_ver: c_long = 0;
    _ = c.curl_easy_getinfo(h, c.CURLINFO_HTTP_VERSION, &http_ver);
    last_http_version = switch (http_ver) {
        c.CURL_HTTP_VERSION_2_0 => 2,
        c.CURL_HTTP_VERSION_3 => 3,
        else => 1,
    };
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
