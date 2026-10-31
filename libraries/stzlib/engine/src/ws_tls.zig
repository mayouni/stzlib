// TLS for the WebSocket client and its test server -- mbedTLS over a blocking
// socket, the engine's own TLS socket path (reactor.zig has the same policy).
//
// CLIENT POLICY, fail-closed: the peer certificate is verified against the
// operating system's trust store (Windows ROOT store through CryptoAPI, the
// usual bundle files elsewhere) or a CA file the caller names, and the host
// name is checked (SNI set, iPAddress and dNSName SANs). `insecure` turns
// verification off and is the explicit opt-out a caller must ask for by name.
//
// Every session owns its own entropy, DRBG, config and context, so a session
// per thread needs no shared state.

const std = @import("std");
const builtin = @import("builtin");
const posix = std.posix;
const c = @cImport({
    @cInclude("mbedtls/ssl.h");
    @cInclude("mbedtls/entropy.h");
    @cInclude("mbedtls/ctr_drbg.h");
    @cInclude("mbedtls/x509_crt.h");
    @cInclude("mbedtls/pk.h");
    @cInclude("mbedtls/error.h");
    @cInclude("mbedtls/net_sockets.h"); // the MBEDTLS_ERR_NET_* codes the BIO returns
});

const gpa = std.heap.c_allocator;

pub const Session = struct {
    sock: posix.socket_t,
    ssl: c.mbedtls_ssl_context,
    conf: c.mbedtls_ssl_config,
    entropy: c.mbedtls_entropy_context,
    drbg: c.mbedtls_ctr_drbg_context,
    chain: c.mbedtls_x509_crt,
    own: c.mbedtls_x509_crt,
    pk: c.mbedtls_pk_context,
};

pub const TlsError = error{
    OutOfMemory,
    Setup,
    CaFile,
    NoAnchor,
    Hostname,
    Handshake,
    VerifyFailed,
    Timeout,
    Closed,
    CertFile,
    KeyFile,
};

pub fn describe(e: TlsError) []const u8 {
    return switch (e) {
        error.OutOfMemory => "out of memory",
        error.Setup => "setup failed",
        error.CaFile => "CA file unreadable",
        error.NoAnchor => "no trust anchor on this system",
        error.Hostname => "host name cannot be set",
        error.Handshake => "handshake failed",
        error.VerifyFailed => "certificate verification failed",
        error.Timeout => "handshake timed out",
        error.Closed => "the peer closed during the handshake",
        error.CertFile => "certificate file unreadable",
        error.KeyFile => "key file unreadable",
    };
}

// ── BIO over the socket ──

fn bioSend(ctx: ?*anyopaque, buf: [*c]const u8, len: usize) callconv(.c) c_int {
    const s: *Session = @ptrCast(@alignCast(ctx));
    const n = posix.send(s.sock, buf[0..len], 0) catch return c.MBEDTLS_ERR_NET_SEND_FAILED;
    return @intCast(n);
}

/// mbedTLS hands the config's read timeout here (0 = block).
fn bioRecvTimeout(ctx: ?*anyopaque, buf: [*c]u8, len: usize, timeout: u32) callconv(.c) c_int {
    const s: *Session = @ptrCast(@alignCast(ctx));
    var pfd = [_]posix.pollfd{.{ .fd = s.sock, .events = posix.POLL.IN, .revents = 0 }};
    const t: i32 = if (timeout == 0) -1 else @intCast(@min(timeout, std.math.maxInt(i32)));
    const ready = posix.poll(&pfd, t) catch return c.MBEDTLS_ERR_NET_RECV_FAILED;
    if (ready == 0) return c.MBEDTLS_ERR_SSL_TIMEOUT;
    const n = posix.recv(s.sock, buf[0..len], 0) catch return c.MBEDTLS_ERR_NET_RECV_FAILED;
    return @intCast(n); // 0 = EOF, which mbedTLS reports as MBEDTLS_ERR_SSL_CONN_EOF
}

// ── trust ──

const CERT_CONTEXT = extern struct {
    dwCertEncodingType: u32,
    pbCertEncoded: [*]const u8,
    cbCertEncoded: u32,
    pCertInfo: ?*anyopaque,
    hCertStore: ?*anyopaque,
};
extern "crypt32" fn CertOpenSystemStoreW(hProv: usize, szSubsystemProtocol: [*:0]const u16) callconv(.winapi) ?*anyopaque;
extern "crypt32" fn CertEnumCertificatesInStore(hCertStore: ?*anyopaque, pPrevCertContext: ?*const CERT_CONTEXT) callconv(.winapi) ?*const CERT_CONTEXT;
extern "crypt32" fn CertCloseStore(hCertStore: ?*anyopaque, dwFlags: u32) callconv(.winapi) i32;

/// The operating system's trusted roots into `chain`; how many were added.
fn loadSystemTrust(chain: *c.mbedtls_x509_crt) usize {
    var n: usize = 0;
    if (builtin.os.tag == .windows) {
        const store = CertOpenSystemStoreW(0, std.unicode.utf8ToUtf16LeStringLiteral("ROOT")) orelse return 0;
        defer _ = CertCloseStore(store, 0);
        var prev: ?*const CERT_CONTEXT = null;
        while (CertEnumCertificatesInStore(store, prev)) |ctx| {
            if ((ctx.dwCertEncodingType & 1) != 0 and
                c.mbedtls_x509_crt_parse_der(chain, ctx.pbCertEncoded, ctx.cbCertEncoded) == 0) n += 1;
            prev = ctx;
        }
        return n;
    }
    const bundles = [_][*:0]const u8{
        "/etc/ssl/certs/ca-certificates.crt",
        "/etc/pki/tls/certs/ca-bundle.crt",
        "/etc/ssl/ca-bundle.pem",
        "/etc/ssl/cert.pem",
    };
    for (bundles) |path| {
        if (c.mbedtls_x509_crt_parse_file(chain, path) >= 0) break;
    }
    var p: ?*c.mbedtls_x509_crt = chain;
    while (p) |crt| : (p = crt.next) {
        if (crt.raw.len > 0) n += 1;
    }
    return n;
}

fn newSession(sock: posix.socket_t) TlsError!*Session {
    const s = gpa.create(Session) catch return error.OutOfMemory;
    s.sock = sock;
    c.mbedtls_ssl_init(&s.ssl);
    c.mbedtls_ssl_config_init(&s.conf);
    c.mbedtls_entropy_init(&s.entropy);
    c.mbedtls_ctr_drbg_init(&s.drbg);
    c.mbedtls_x509_crt_init(&s.chain);
    c.mbedtls_x509_crt_init(&s.own);
    c.mbedtls_pk_init(&s.pk);
    const pers = "softanza-ws";
    if (c.mbedtls_ctr_drbg_seed(&s.drbg, c.mbedtls_entropy_func, &s.entropy, pers, pers.len) != 0) {
        deinit(s);
        return error.Setup;
    }
    return s;
}

fn handshake(s: *Session, timeout_ms: u32) TlsError!void {
    c.mbedtls_ssl_conf_read_timeout(&s.conf, if (timeout_ms == 0) 1 else timeout_ms);
    const deadline = std.time.milliTimestamp() + @as(i64, if (timeout_ms == 0) 1 else timeout_ms);
    while (true) {
        const rc = c.mbedtls_ssl_handshake(&s.ssl);
        if (rc == 0) return;
        if (rc == c.MBEDTLS_ERR_SSL_WANT_READ or rc == c.MBEDTLS_ERR_SSL_WANT_WRITE) {
            if (std.time.milliTimestamp() >= deadline) return error.Timeout;
            continue;
        }
        if (rc == c.MBEDTLS_ERR_SSL_TIMEOUT) return error.Timeout;
        if (rc == c.MBEDTLS_ERR_SSL_CONN_EOF or rc == c.MBEDTLS_ERR_NET_CONN_RESET) return error.Closed;
        if (rc == c.MBEDTLS_ERR_X509_CERT_VERIFY_FAILED) return error.VerifyFailed;
        return error.Handshake;
    }
}

/// Client side: a verified TLS session on an already connected socket.
pub fn connect(sock: posix.socket_t, host: []const u8, ca_file: []const u8, insecure: bool, timeout_ms: u32) TlsError!*Session {
    const s = try newSession(sock);
    errdefer deinit(s);
    if (c.mbedtls_ssl_config_defaults(&s.conf, c.MBEDTLS_SSL_IS_CLIENT, c.MBEDTLS_SSL_TRANSPORT_STREAM, c.MBEDTLS_SSL_PRESET_DEFAULT) != 0) return error.Setup;
    c.mbedtls_ssl_conf_rng(&s.conf, c.mbedtls_ctr_drbg_random, &s.drbg);
    if (insecure) {
        c.mbedtls_ssl_conf_authmode(&s.conf, c.MBEDTLS_SSL_VERIFY_NONE);
    } else {
        if (ca_file.len > 0) {
            var abuf: [1024]u8 = undefined;
            const ca_z = std.fmt.bufPrintZ(&abuf, "{s}", .{ca_file}) catch return error.CaFile;
            if (c.mbedtls_x509_crt_parse_file(&s.chain, ca_z.ptr) != 0) return error.CaFile;
        } else if (loadSystemTrust(&s.chain) == 0) {
            return error.NoAnchor;
        }
        c.mbedtls_ssl_conf_ca_chain(&s.conf, &s.chain, null);
        c.mbedtls_ssl_conf_authmode(&s.conf, c.MBEDTLS_SSL_VERIFY_REQUIRED);
    }
    if (c.mbedtls_ssl_setup(&s.ssl, &s.conf) != 0) return error.Setup;
    var hbuf: [256]u8 = undefined;
    const host_z = std.fmt.bufPrintZ(&hbuf, "{s}", .{host}) catch return error.Hostname;
    if (c.mbedtls_ssl_set_hostname(&s.ssl, host_z.ptr) != 0) return error.Hostname;
    c.mbedtls_ssl_set_bio(&s.ssl, s, bioSend, null, bioRecvTimeout);
    try handshake(s, timeout_ms);
    if (!insecure and c.mbedtls_ssl_get_verify_result(&s.ssl) != 0) return error.VerifyFailed;
    return s;
}

/// Server side: a TLS session presenting `cert_pem` / `key_pem` (PEM text).
pub fn accept(sock: posix.socket_t, cert_pem: []const u8, key_pem: []const u8, timeout_ms: u32) TlsError!*Session {
    const s = try newSession(sock);
    errdefer deinit(s);
    // PEM parsing wants a NUL-terminated buffer whose length counts the NUL
    const cb = gpa.alloc(u8, cert_pem.len + 1) catch return error.OutOfMemory;
    defer gpa.free(cb);
    @memcpy(cb[0..cert_pem.len], cert_pem);
    cb[cert_pem.len] = 0;
    if (c.mbedtls_x509_crt_parse(&s.own, cb.ptr, cb.len) != 0) return error.CertFile;
    const kb = gpa.alloc(u8, key_pem.len + 1) catch return error.OutOfMemory;
    defer gpa.free(kb);
    @memcpy(kb[0..key_pem.len], key_pem);
    kb[key_pem.len] = 0;
    if (c.mbedtls_pk_parse_key(&s.pk, kb.ptr, kb.len, null, 0, c.mbedtls_ctr_drbg_random, &s.drbg) != 0) return error.KeyFile;
    if (c.mbedtls_ssl_config_defaults(&s.conf, c.MBEDTLS_SSL_IS_SERVER, c.MBEDTLS_SSL_TRANSPORT_STREAM, c.MBEDTLS_SSL_PRESET_DEFAULT) != 0) return error.Setup;
    c.mbedtls_ssl_conf_rng(&s.conf, c.mbedtls_ctr_drbg_random, &s.drbg);
    if (c.mbedtls_ssl_conf_own_cert(&s.conf, &s.own, &s.pk) != 0) return error.Setup;
    if (c.mbedtls_ssl_setup(&s.ssl, &s.conf) != 0) return error.Setup;
    c.mbedtls_ssl_set_bio(&s.ssl, s, bioSend, null, bioRecvTimeout);
    try handshake(s, timeout_ms);
    return s;
}

/// Read plaintext, waiting at most `timeout_ms` (-1 = forever, 0 = poll once).
pub fn read(s: *Session, buf: []u8, timeout_ms: i32) error{ Timeout, Closed, Failed }!usize {
    const t: u32 = if (timeout_ms < 0) 0 else if (timeout_ms == 0) 1 else @intCast(timeout_ms);
    c.mbedtls_ssl_conf_read_timeout(&s.conf, t);
    const deadline: i64 = if (timeout_ms < 0) std.math.maxInt(i64) else std.time.milliTimestamp() + timeout_ms;
    while (true) {
        const rc = c.mbedtls_ssl_read(&s.ssl, buf.ptr, buf.len);
        if (rc > 0) return @intCast(rc);
        if (rc == 0 or rc == c.MBEDTLS_ERR_SSL_PEER_CLOSE_NOTIFY or rc == c.MBEDTLS_ERR_SSL_CONN_EOF or rc == c.MBEDTLS_ERR_NET_CONN_RESET) return error.Closed;
        if (rc == c.MBEDTLS_ERR_SSL_TIMEOUT) return error.Timeout;
        if (rc == c.MBEDTLS_ERR_SSL_WANT_READ or rc == c.MBEDTLS_ERR_SSL_WANT_WRITE or rc == c.MBEDTLS_ERR_SSL_RECEIVED_NEW_SESSION_TICKET) {
            if (std.time.milliTimestamp() >= deadline) return error.Timeout;
            continue;
        }
        return error.Failed;
    }
}

pub fn writeAll(s: *Session, bytes: []const u8) error{Failed}!void {
    var off: usize = 0;
    while (off < bytes.len) {
        const rc = c.mbedtls_ssl_write(&s.ssl, bytes.ptr + off, bytes.len - off);
        if (rc > 0) {
            off += @intCast(rc);
            continue;
        }
        if (rc == c.MBEDTLS_ERR_SSL_WANT_READ or rc == c.MBEDTLS_ERR_SSL_WANT_WRITE) continue;
        return error.Failed;
    }
}

/// Send close_notify (best effort) and free everything. The socket is the caller's.
pub fn deinit(s: *Session) void {
    _ = c.mbedtls_ssl_close_notify(&s.ssl);
    c.mbedtls_ssl_free(&s.ssl);
    c.mbedtls_ssl_config_free(&s.conf);
    c.mbedtls_x509_crt_free(&s.chain);
    c.mbedtls_x509_crt_free(&s.own);
    c.mbedtls_pk_free(&s.pk);
    c.mbedtls_ctr_drbg_free(&s.drbg);
    c.mbedtls_entropy_free(&s.entropy);
    gpa.destroy(s);
}
