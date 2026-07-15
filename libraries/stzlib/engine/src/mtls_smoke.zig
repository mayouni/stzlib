// mTLS slice 1 -- standalone mbedTLS handshake smoke (NO reactor).
//
// Proves the vendored mbedTLS builds, links, and completes a real TLS
// handshake in THIS toolchain, using the SAME buffer-BIO model the reactor
// server loop will use in slice 2: a server ssl_context and a client
// ssl_context handshake through two in-memory pipes (c2s / s2c). After the
// handshake it exchanges one ENCRYPTED application record each way to prove
// the secure channel actually carries data. Exit 0 = pass, 1 = fail.

const std = @import("std");
const c = @cImport({
    @cInclude("mbedtls/ssl.h");
    @cInclude("mbedtls/entropy.h");
    @cInclude("mbedtls/ctr_drbg.h");
    @cInclude("mbedtls/x509_crt.h");
    @cInclude("mbedtls/pk.h");
    @cInclude("mbedtls/error.h");
});

const srv_crt_pem = @embedFile("mtls_certs/server.crt.pem");
const srv_key_pem = @embedFile("mtls_certs/server.key.pem");

// A one-directional in-memory byte pipe (a stand-in for a TCP direction).
const Pipe = struct {
    buf: [16384]u8 = undefined,
    len: usize = 0, // bytes written
    rpos: usize = 0, // bytes consumed
};

// One endpoint's view: it reads from `in`, writes to `out`.
const Endpoint = struct {
    in: *Pipe,
    out: *Pipe,
};

fn bioSend(ctx: ?*anyopaque, buf: [*c]const u8, len: usize) callconv(.c) c_int {
    const ep: *Endpoint = @ptrCast(@alignCast(ctx));
    const space = ep.out.buf.len - ep.out.len;
    if (space == 0) return c.MBEDTLS_ERR_SSL_WANT_WRITE;
    const n = @min(len, space);
    @memcpy(ep.out.buf[ep.out.len .. ep.out.len + n], buf[0..n]);
    ep.out.len += n;
    return @intCast(n);
}

fn bioRecv(ctx: ?*anyopaque, buf: [*c]u8, len: usize) callconv(.c) c_int {
    const ep: *Endpoint = @ptrCast(@alignCast(ctx));
    const avail = ep.in.len - ep.in.rpos;
    if (avail == 0) return c.MBEDTLS_ERR_SSL_WANT_READ;
    const n = @min(len, avail);
    @memcpy(buf[0..n], ep.in.buf[ep.in.rpos .. ep.in.rpos + n]);
    ep.in.rpos += n;
    return @intCast(n);
}

fn die(comptime what: []const u8, rc: c_int) noreturn {
    var errbuf: [256]u8 = undefined;
    c.mbedtls_strerror(rc, &errbuf, errbuf.len);
    std.debug.print("FAIL: {s} -> -0x{X} ({s})\n", .{ what, @as(u32, @bitCast(-rc)), std.mem.sliceTo(&errbuf, 0) });
    std.process.exit(1);
}

pub fn main() void {
    // shared RNG (entropy + CTR-DRBG)
    var entropy: c.mbedtls_entropy_context = undefined;
    var drbg: c.mbedtls_ctr_drbg_context = undefined;
    c.mbedtls_entropy_init(&entropy);
    c.mbedtls_ctr_drbg_init(&drbg);
    {
        const pers = "softanza-mtls-smoke";
        const rc = c.mbedtls_ctr_drbg_seed(&drbg, c.mbedtls_entropy_func, &entropy, pers, pers.len);
        if (rc != 0) die("ctr_drbg_seed", rc);
    }

    // server certificate + private key (PEM parse needs a NUL-terminated buf
    // whose length INCLUDES the terminator)
    var srvcert: c.mbedtls_x509_crt = undefined;
    var pkey: c.mbedtls_pk_context = undefined;
    c.mbedtls_x509_crt_init(&srvcert);
    c.mbedtls_pk_init(&pkey);
    {
        var cbuf: [4096]u8 = undefined;
        @memcpy(cbuf[0..srv_crt_pem.len], srv_crt_pem);
        cbuf[srv_crt_pem.len] = 0;
        const rc = c.mbedtls_x509_crt_parse(&srvcert, &cbuf, srv_crt_pem.len + 1);
        if (rc != 0) die("x509_crt_parse", rc);
    }
    {
        var kbuf: [4096]u8 = undefined;
        @memcpy(kbuf[0..srv_key_pem.len], srv_key_pem);
        kbuf[srv_key_pem.len] = 0;
        const rc = c.mbedtls_pk_parse_key(&pkey, &kbuf, srv_key_pem.len + 1, null, 0, c.mbedtls_ctr_drbg_random, &drbg);
        if (rc != 0) die("pk_parse_key", rc);
    }

    // server config
    var srv_conf: c.mbedtls_ssl_config = undefined;
    c.mbedtls_ssl_config_init(&srv_conf);
    if (c.mbedtls_ssl_config_defaults(&srv_conf, c.MBEDTLS_SSL_IS_SERVER, c.MBEDTLS_SSL_TRANSPORT_STREAM, c.MBEDTLS_SSL_PRESET_DEFAULT) != 0)
        die("srv config_defaults", -1);
    c.mbedtls_ssl_conf_rng(&srv_conf, c.mbedtls_ctr_drbg_random, &drbg);
    if (c.mbedtls_ssl_conf_own_cert(&srv_conf, &srvcert, &pkey) != 0) die("conf_own_cert", -1);

    // client config (smoke: don't verify the self-signed server cert)
    var cli_conf: c.mbedtls_ssl_config = undefined;
    c.mbedtls_ssl_config_init(&cli_conf);
    if (c.mbedtls_ssl_config_defaults(&cli_conf, c.MBEDTLS_SSL_IS_CLIENT, c.MBEDTLS_SSL_TRANSPORT_STREAM, c.MBEDTLS_SSL_PRESET_DEFAULT) != 0)
        die("cli config_defaults", -1);
    c.mbedtls_ssl_conf_rng(&cli_conf, c.mbedtls_ctr_drbg_random, &drbg);
    c.mbedtls_ssl_conf_authmode(&cli_conf, c.MBEDTLS_SSL_VERIFY_NONE);

    // ssl contexts
    var srv_ssl: c.mbedtls_ssl_context = undefined;
    var cli_ssl: c.mbedtls_ssl_context = undefined;
    c.mbedtls_ssl_init(&srv_ssl);
    c.mbedtls_ssl_init(&cli_ssl);
    if (c.mbedtls_ssl_setup(&srv_ssl, &srv_conf) != 0) die("srv ssl_setup", -1);
    if (c.mbedtls_ssl_setup(&cli_ssl, &cli_conf) != 0) die("cli ssl_setup", -1);

    // wire the two directions
    var c2s = Pipe{};
    var s2c = Pipe{};
    var srv_ep = Endpoint{ .in = &c2s, .out = &s2c };
    var cli_ep = Endpoint{ .in = &s2c, .out = &c2s };
    c.mbedtls_ssl_set_bio(&srv_ssl, &srv_ep, bioSend, bioRecv, null);
    c.mbedtls_ssl_set_bio(&cli_ssl, &cli_ep, bioSend, bioRecv, null);

    // drive the handshake: pump both sides until both report done
    var srv_done = false;
    var cli_done = false;
    var iter: usize = 0;
    while ((!srv_done or !cli_done) and iter < 200) : (iter += 1) {
        if (!cli_done) {
            const r = c.mbedtls_ssl_handshake(&cli_ssl);
            if (r == 0) cli_done = true else if (r != c.MBEDTLS_ERR_SSL_WANT_READ and r != c.MBEDTLS_ERR_SSL_WANT_WRITE) die("client handshake", r);
        }
        if (!srv_done) {
            const r = c.mbedtls_ssl_handshake(&srv_ssl);
            if (r == 0) srv_done = true else if (r != c.MBEDTLS_ERR_SSL_WANT_READ and r != c.MBEDTLS_ERR_SSL_WANT_WRITE) die("server handshake", r);
        }
    }
    if (!srv_done or !cli_done) die("handshake did not converge", -1);

    const ver = c.mbedtls_ssl_get_version(&cli_ssl);
    const suite = c.mbedtls_ssl_get_ciphersuite(&cli_ssl);
    std.debug.print("handshake OK: version={s} ciphersuite={s}\n", .{ ver, suite });

    // prove the channel carries ENCRYPTED application data (client -> server)
    const msg = "softanza-mtls-ping";
    {
        var off: usize = 0;
        while (off < msg.len) {
            const r = c.mbedtls_ssl_write(&cli_ssl, msg.ptr + off, msg.len - off);
            if (r <= 0) {
                if (r == c.MBEDTLS_ERR_SSL_WANT_READ or r == c.MBEDTLS_ERR_SSL_WANT_WRITE) continue;
                die("ssl_write", r);
            }
            off += @intCast(r);
        }
    }
    var rbuf: [64]u8 = undefined;
    var got: usize = 0;
    var rtries: usize = 0;
    while (got < msg.len and rtries < 50) : (rtries += 1) {
        const r = c.mbedtls_ssl_read(&srv_ssl, rbuf[got..].ptr, rbuf.len - got);
        if (r == c.MBEDTLS_ERR_SSL_WANT_READ or r == c.MBEDTLS_ERR_SSL_WANT_WRITE) continue;
        if (r <= 0) die("ssl_read", r);
        got += @intCast(r);
    }
    if (!std.mem.eql(u8, rbuf[0..got], msg)) {
        std.debug.print("FAIL: decrypted payload mismatch: '{s}'\n", .{rbuf[0..got]});
        std.process.exit(1);
    }
    std.debug.print("app-data OK: server decrypted '{s}' over the TLS channel\n", .{rbuf[0..got]});

    // that the bytes on the wire were NOT plaintext (encryption really ran):
    // the c2s pipe holds TLS records, so it must not contain the cleartext.
    if (std.mem.indexOf(u8, c2s.buf[0..c2s.len], msg) != null) {
        std.debug.print("FAIL: cleartext found on the wire -- not encrypted!\n", .{});
        std.process.exit(1);
    }
    std.debug.print("wire OK: cleartext '{s}' is NOT present in the transported bytes (encrypted)\n", .{msg});

    std.debug.print("PASS: mbedTLS vendored, built, handshaked + encrypted round-trip.\n", .{});
    std.process.exit(0);
}
