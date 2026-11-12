// The credential broker (RADAR-OPENSHELL-CREDBROKER-01): the runtime half of
// PRINCIPAL-SECRETNAME-01.
//
// An agent's outbound call NAMES a credential; the engine attaches its value. The
// value is read by the engine from where it is held -- an environment variable or a
// file -- into a secret cell (locked pages, wiped on release, secret_cell.zig), and
// it never crosses into Ring or Haro: there is no function that answers it. A grant
// binds one credential to one host and one header; the engine attaches it only to a
// request bound for that host, and masks it out of the answer before the answer goes
// back, so an endpoint that echoes its headers cannot hand it to the agent either.
//
// The governance grants at start, then SEALS: after the seal no grant can be added
// for the life of the process, so code that runs later (an agent's tool, a model's
// suggestion) cannot bind a credential to a host of its choosing. Revoke stays open
// after the seal, because revoking only narrows.
//
// A request is refused, before anything is sent, when:
//   - the grant is unknown or revoked
//   - the URL does not parse, carries user:pass@, or its host is not the grant's
//   - the scheme is not https (plain http is allowed only to 127.0.0.1 and [::1])
//   - the caller's own headers already name the grant's header (an injection)
// The request itself never follows a redirect, and never relaxes TLS checks.
//
// This file is the table and the checks; the request is made by http.zig, and the
// bridge (ring_bridge_http.zig) wires them together.

const std = @import("std");
const cell = @import("secret_cell.zig");

pub const max_grants = 64;
const name_cap = 64;
const host_cap = 255;
const header_cap = 64;
const prefix_cap = 32;
const value_cap = 8192;

const Grant = struct {
    used: bool = false,
    name: [name_cap]u8 = undefined,
    name_len: usize = 0,
    host: [host_cap]u8 = undefined,
    host_len: usize = 0,
    header: [header_cap]u8 = undefined,
    header_len: usize = 0,
    prefix: [prefix_cap]u8 = undefined,
    prefix_len: usize = 0,
    secret: ?*cell.Cell = null,
    attached: u64 = 0,
    refused: u64 = 0,

    fn nameS(g: *const Grant) []const u8 {
        return g.name[0..g.name_len];
    }
    fn hostS(g: *const Grant) []const u8 {
        return g.host[0..g.host_len];
    }
    fn headerS(g: *const Grant) []const u8 {
        return g.header[0..g.header_len];
    }
    fn prefixS(g: *const Grant) []const u8 {
        return g.prefix[0..g.prefix_len];
    }
};

var grants: [max_grants]Grant = [_]Grant{.{}} ** max_grants;
var sealed: bool = false;
var lock: std.Thread.Mutex = .{};

pub const GrantError = enum(i32) {
    ok = 1,
    sealed = -1,
    bad_field = -2,
    no_source = -3,
    bad_value = -4,
    full = -5,
    exists = -6,
    no_cell = -7,
};

pub fn grantErrorText(e: GrantError) []const u8 {
    return switch (e) {
        .ok => "granted",
        .sealed => "the broker is sealed: no grant can be added in this process",
        .bad_field => "a field is empty, too long, or holds a character a header cannot carry",
        .no_source => "the source names nothing that could be read (env:NAME or file:PATH)",
        .bad_value => "the value read is empty, too long, or holds a line break",
        .full => "the grant table is full",
        .exists => "a grant of that name exists; revoke it first",
        .no_cell => "the engine could not hold the value in a secret cell",
    };
}

fn validToken(s: []const u8, cap: usize) bool {
    if (s.len == 0 or s.len > cap) return false;
    for (s) |c| {
        if (c <= 32 or c >= 127 or c == ':') return false;
    }
    return true;
}

fn validPrefix(s: []const u8) bool {
    if (s.len > prefix_cap) return false;
    for (s) |c| {
        if (c < 32 or c >= 127) return false;
    }
    return true;
}

fn find(name: []const u8) ?*Grant {
    for (&grants) |*g| {
        if (g.used and std.ascii.eqlIgnoreCase(g.nameS(), name)) return g;
    }
    return null;
}

/// Reads a value from its source into a fresh buffer the caller wipes and frees.
/// "env:NAME" or "file:PATH"; a file's trailing line break is not part of it.
fn readSource(a: std.mem.Allocator, source: []const u8) ?[]u8 {
    if (std.mem.startsWith(u8, source, "env:")) {
        const n = source[4..];
        if (n.len == 0) return null;
        return std.process.getEnvVarOwned(a, n) catch null;
    }
    if (std.mem.startsWith(u8, source, "file:")) {
        const p = source[5..];
        if (p.len == 0) return null;
        const buf = std.fs.cwd().readFileAlloc(a, p, value_cap + 2) catch return null;
        var n = buf.len;
        while (n > 0 and (buf[n - 1] == '\n' or buf[n - 1] == '\r')) n -= 1;
        if (n == buf.len) return buf;
        const out = a.dupe(u8, buf[0..n]) catch {
            std.crypto.secureZero(u8, buf);
            a.free(buf);
            return null;
        };
        std.crypto.secureZero(u8, buf);
        a.free(buf);
        return out;
    }
    return null;
}

/// Grants a credential: read from source, attached as "header: prefix value" to
/// requests bound for host. Refused once the broker is sealed.
pub fn grant(name: []const u8, source: []const u8, host: []const u8, header: []const u8, prefix: []const u8) GrantError {
    if (!validToken(name, name_cap) or !validToken(header, header_cap) or !validPrefix(prefix)) return .bad_field;
    if (host.len == 0 or host.len > host_cap) return .bad_field;
    for (host) |c| {
        if (c <= 32 or c >= 127 or c == '/' or c == '@') return .bad_field;
    }
    {
        lock.lock();
        defer lock.unlock();
        if (sealed) return .sealed;
        if (find(name) != null) return .exists;
    }
    const a = std.heap.page_allocator;
    const v = readSource(a, source) orelse return .no_source;
    defer {
        std.crypto.secureZero(u8, v);
        a.free(v);
    }
    if (v.len == 0 or v.len > value_cap) return .bad_value;
    for (v) |c| {
        if (c == '\n' or c == '\r' or c == 0) return .bad_value;
    }
    const c = cell.hold(v) orelse return .no_cell;

    lock.lock();
    defer lock.unlock();
    if (sealed) {
        _ = cell.release(c);
        return .sealed;
    }
    if (find(name) != null) {
        _ = cell.release(c);
        return .exists;
    }
    for (&grants) |*g| {
        if (g.used) continue;
        g.* = .{};
        @memcpy(g.name[0..name.len], name);
        g.name_len = name.len;
        for (host, 0..) |ch, i| g.host[i] = std.ascii.toLower(ch);
        g.host_len = host.len;
        @memcpy(g.header[0..header.len], header);
        g.header_len = header.len;
        @memcpy(g.prefix[0..prefix.len], prefix);
        g.prefix_len = prefix.len;
        g.secret = c;
        g.used = true;
        return .ok;
    }
    _ = cell.release(c);
    return .full;
}

/// After this no grant can be added in this process. Answers true; a second seal
/// changes nothing.
pub fn seal() bool {
    lock.lock();
    defer lock.unlock();
    sealed = true;
    return true;
}

pub fn isSealed() bool {
    lock.lock();
    defer lock.unlock();
    return sealed;
}

/// Revokes a grant and wipes its value. Allowed after the seal. True when a grant
/// of that name existed.
pub fn revoke(name: []const u8) bool {
    lock.lock();
    defer lock.unlock();
    const g = find(name) orelse return false;
    if (g.secret) |c| _ = cell.release(c);
    g.* = .{};
    return true;
}

pub fn count() usize {
    lock.lock();
    defer lock.unlock();
    var n: usize = 0;
    for (grants) |g| {
        if (g.used) n += 1;
    }
    return n;
}

/// "name<TAB>host<TAB>header<TAB>attached<TAB>refused" lines, never a value.
pub fn describe(out: []u8) usize {
    lock.lock();
    defer lock.unlock();
    var w = std.io.fixedBufferStream(out);
    for (&grants) |*g| {
        if (!g.used) continue;
        w.writer().print("{s}\t{s}\t{s}\t{d}\t{d}\n", .{ g.nameS(), g.hostS(), g.headerS(), g.attached, g.refused }) catch break;
    }
    return w.pos;
}

// ── the request check ───────────────────────────────────────

pub const Refusal = enum {
    none,
    unknown_grant,
    bad_url,
    userinfo,
    not_https,
    wrong_host,
    header_injection,
};

pub fn refusalText(r: Refusal) []const u8 {
    return switch (r) {
        .none => "",
        .unknown_grant => "no grant of that name (unknown or revoked)",
        .bad_url => "the URL does not parse",
        .userinfo => "the URL carries credentials of its own (user@host)",
        .not_https => "the URL is not https (plain http only to 127.0.0.1 or [::1])",
        .wrong_host => "the URL's host is not the host the credential is granted for",
        .header_injection => "the request's own headers already name the granted header",
    };
}

pub const UrlParts = struct {
    scheme: []const u8,
    host: []const u8,
    has_user: bool,
};

pub fn parseUrl(url: []const u8) ?UrlParts {
    const uri = std.Uri.parse(url) catch return null;
    const hc = uri.host orelse return null;
    const host = switch (hc) {
        .raw => |s| s,
        .percent_encoded => |s| s,
    };
    if (host.len == 0) return null;
    return .{ .scheme = uri.scheme, .host = host, .has_user = uri.user != null or uri.password != null };
}

fn isLoopback(host: []const u8) bool {
    return std.mem.eql(u8, host, "127.0.0.1") or std.mem.eql(u8, host, "[::1]") or std.mem.eql(u8, host, "::1");
}

fn headersName(headers: []const u8, header: []const u8) bool {
    var it = std.mem.splitScalar(u8, headers, '\n');
    while (it.next()) |line0| {
        const line = std.mem.trim(u8, line0, " \t\r");
        const colon = std.mem.indexOfScalar(u8, line, ':') orelse continue;
        if (std.ascii.eqlIgnoreCase(std.mem.trim(u8, line[0..colon], " \t"), header)) return true;
    }
    return false;
}

/// Checks a request against a grant. On .none, writes the header block to send
/// (the caller's headers plus the granted line) into out and answers its length in
/// out_len. The value is written only into out, which the caller wipes.
pub fn prepare(name: []const u8, url: []const u8, headers: []const u8, out: []u8, out_len: *usize, host_out: []u8, host_len: *usize) Refusal {
    lock.lock();
    defer lock.unlock();
    host_len.* = 0;
    const g = find(name) orelse return .unknown_grant;
    const r = check(g, url, headers, host_out, host_len);
    if (r != .none) {
        g.refused += 1;
        return r;
    }
    const v = cell.value(g.secret.?);
    var w = std.io.fixedBufferStream(out);
    const wr = w.writer();
    const ok = blk: {
        if (headers.len > 0) {
            wr.writeAll(headers) catch break :blk false;
            if (headers[headers.len - 1] != '\n') wr.writeAll("\n") catch break :blk false;
        }
        wr.print("{s}: {s}", .{ g.headerS(), g.prefixS() }) catch break :blk false;
        wr.writeAll(v) catch break :blk false;
        break :blk true;
    };
    if (!ok) {
        std.crypto.secureZero(u8, out);
        g.refused += 1;
        return .bad_url;
    }
    out_len.* = w.pos;
    g.attached += 1;
    return .none;
}

fn check(g: *const Grant, url: []const u8, headers: []const u8, host_out: []u8, host_len: *usize) Refusal {
    const u = parseUrl(url) orelse return .bad_url;
    const n = @min(u.host.len, host_out.len);
    @memcpy(host_out[0..n], u.host[0..n]);
    host_len.* = n;
    if (u.has_user) return .userinfo;
    if (!std.ascii.eqlIgnoreCase(u.scheme, "https")) {
        if (!(std.ascii.eqlIgnoreCase(u.scheme, "http") and isLoopback(u.host))) return .not_https;
    }
    if (!std.ascii.eqlIgnoreCase(u.host, g.hostS())) return .wrong_host;
    if (headersName(headers, g.headerS())) return .header_injection;
    return .none;
}

/// Overwrites every occurrence of the grant's value in buf with '*', in place.
/// Answers how many it masked. Called on the body and the response headers.
pub fn mask(name: []const u8, buf: []u8) usize {
    lock.lock();
    defer lock.unlock();
    const g = find(name) orelse return 0;
    return maskValue(cell.value(g.secret.?), buf);
}

fn maskValue(v: []const u8, buf: []u8) usize {
    if (v.len == 0 or buf.len < v.len) return 0;
    var n: usize = 0;
    var i: usize = 0;
    while (std.mem.indexOfPos(u8, buf, i, v)) |at| {
        @memset(buf[at .. at + v.len], '*');
        n += 1;
        i = at + v.len;
    }
    return n;
}

/// Empties the table and unseals. For a test's setup only.
pub fn clearForTest() void {
    lock.lock();
    defer lock.unlock();
    for (&grants) |*g| {
        if (g.used) {
            if (g.secret) |c| _ = cell.release(c);
        }
        g.* = .{};
    }
    sealed = false;
}

// ── tests ──────────────────────────────────────────────────

const t = std.testing;

fn tmpSource(dir: std.testing.TmpDir, value: []const u8, buf: []u8) ![]const u8 {
    try dir.dir.writeFile(.{ .sub_path = "cred.txt", .data = value });
    const p = try dir.dir.realpath("cred.txt", buf[5..]);
    @memcpy(buf[0..5], "file:");
    return buf[0 .. 5 + p.len];
}

test "a granted request carries the value; the header block is the caller's plus one line" {
    clearForTest();
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    var sb: [512]u8 = undefined;
    const src = try tmpSource(tmp, "tok-123456\n", &sb);
    try t.expectEqual(GrantError.ok, grant("gh", src, "api.github.com", "Authorization", "Bearer "));
    var out: [512]u8 = undefined;
    var n: usize = 0;
    var h: [256]u8 = undefined;
    var hn: usize = 0;
    try t.expectEqual(Refusal.none, prepare("gh", "https://API.github.com/user", "Accept: x", &out, &n, &h, &hn));
    try t.expectEqualStrings("Accept: x\nAuthorization: Bearer tok-123456", out[0..n]);
}

test "every refusal is decided before anything is sent" {
    clearForTest();
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    var sb: [512]u8 = undefined;
    const src = try tmpSource(tmp, "tok-abcdef", &sb);
    try t.expectEqual(GrantError.ok, grant("gh", src, "api.github.com", "Authorization", "Bearer "));
    var out: [512]u8 = undefined;
    var n: usize = 0;
    var h: [256]u8 = undefined;
    var hn: usize = 0;
    try t.expectEqual(Refusal.unknown_grant, prepare("other", "https://api.github.com/", "", &out, &n, &h, &hn));
    try t.expectEqual(Refusal.wrong_host, prepare("gh", "https://evil.example/", "", &out, &n, &h, &hn));
    try t.expectEqual(Refusal.wrong_host, prepare("gh", "https://api.github.com.evil.example/", "", &out, &n, &h, &hn));
    try t.expectEqual(Refusal.not_https, prepare("gh", "http://api.github.com/", "", &out, &n, &h, &hn));
    try t.expectEqual(Refusal.userinfo, prepare("gh", "https://u:p@api.github.com/", "", &out, &n, &h, &hn));
    try t.expectEqual(Refusal.header_injection, prepare("gh", "https://api.github.com/", "authorization: Bearer mine", &out, &n, &h, &hn));
    try t.expectEqual(Refusal.bad_url, prepare("gh", "not a url", "", &out, &n, &h, &hn));
}

test "the seal refuses a new grant and keeps revoke open" {
    clearForTest();
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    var sb: [512]u8 = undefined;
    const src = try tmpSource(tmp, "v1", &sb);
    try t.expectEqual(GrantError.ok, grant("a", src, "h.example", "X-Key", ""));
    try t.expect(seal());
    try t.expectEqual(GrantError.sealed, grant("b", src, "h.example", "X-Key", ""));
    try t.expect(revoke("a"));
    try t.expectEqual(@as(usize, 0), count());
    try t.expectEqual(GrantError.sealed, grant("a", src, "h.example", "X-Key", ""));
}

test "a value with a line break, an empty source or a header with a colon is refused" {
    clearForTest();
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    var sb: [512]u8 = undefined;
    const src = try tmpSource(tmp, "line1\nline2", &sb);
    try t.expectEqual(GrantError.bad_value, grant("a", src, "h", "X-Key", ""));
    try t.expectEqual(GrantError.no_source, grant("a", "env:", "h", "X-Key", ""));
    try t.expectEqual(GrantError.no_source, grant("a", "literal:abc", "h", "X-Key", ""));
    try t.expectEqual(GrantError.bad_field, grant("a", "env:X", "h", "X:Key", ""));
    try t.expectEqual(GrantError.bad_field, grant("a", "env:X", "u@h", "X-Key", ""));
    try t.expectEqual(@as(usize, 0), count());
}

test "plain http is allowed to loopback only" {
    clearForTest();
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    var sb: [512]u8 = undefined;
    const src = try tmpSource(tmp, "v1", &sb);
    try t.expectEqual(GrantError.ok, grant("lo", src, "127.0.0.1", "X-Key", ""));
    var out: [512]u8 = undefined;
    var n: usize = 0;
    var h: [256]u8 = undefined;
    var hn: usize = 0;
    try t.expectEqual(Refusal.none, prepare("lo", "http://127.0.0.1:8080/x", "", &out, &n, &h, &hn));
}

test "the value is masked out of an echo, every occurrence" {
    clearForTest();
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    var sb: [512]u8 = undefined;
    const src = try tmpSource(tmp, "s3cr3t-v", &sb);
    try t.expectEqual(GrantError.ok, grant("m", src, "h", "X-Key", ""));
    var body = "a s3cr3t-v b s3cr3t-v c".*;
    try t.expectEqual(@as(usize, 2), mask("m", &body));
    try t.expectEqualStrings("a ******** b ******** c", &body);
}

test "describe names grants and counts, never a value" {
    clearForTest();
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    var sb: [512]u8 = undefined;
    const src = try tmpSource(tmp, "never-printed", &sb);
    try t.expectEqual(GrantError.ok, grant("d", src, "h.example", "X-Key", ""));
    var out: [256]u8 = undefined;
    const n = describe(&out);
    try t.expect(std.mem.indexOf(u8, out[0..n], "never-printed") == null);
    try t.expect(std.mem.indexOf(u8, out[0..n], "d\th.example\tX-Key") != null);
}
