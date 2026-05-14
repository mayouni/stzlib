// Softanza Engine -- URL Operations (Tier 3)
//
// Replaces QUrl with Zig std.Uri for parsing,
// plus custom reconstruction. All C ABI for Ring FFI.

const std = @import("std");
const mem = std.mem;
const gpa = std.heap.c_allocator;

const Url = struct {
    raw: []const u8,
    scheme: []const u8,
    user: []const u8,
    password: []const u8,
    host: []const u8,
    port: i32,
    path: []const u8,
    query: []const u8,
    fragment: []const u8,
};

pub fn stz_url_parse(raw: [*c]const u8, raw_len: usize) callconv(.c) ?*Url {
    if (raw == null or raw_len == 0) return null;
    const src = gpa.dupe(u8, raw[0..raw_len]) catch return null;
    const u = gpa.create(Url) catch { gpa.free(src); return null; };
    u.* = .{ .raw = src, .scheme = "", .user = "", .password = "", .host = "", .port = -1, .path = "", .query = "", .fragment = "" };
    parseInto(u, src);
    return u;
}

pub fn stz_url_free(h: ?*Url) callconv(.c) void {
    if (h) |u| { gpa.free(u.raw); gpa.destroy(u); }
}

pub fn stz_url_is_valid(h: ?*Url) callconv(.c) c_int {
    const u = h orelse return 0;
    return if (u.scheme.len > 0 and u.host.len > 0) 1 else 0;
}

pub fn stz_url_scheme(h: ?*Url, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    return copyField(h, "scheme", buf, buf_len);
}

pub fn stz_url_host(h: ?*Url, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    return copyField(h, "host", buf, buf_len);
}

pub fn stz_url_port(h: ?*Url) callconv(.c) c_int {
    const u = h orelse return -1;
    return u.port;
}

pub fn stz_url_path(h: ?*Url, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    return copyField(h, "path", buf, buf_len);
}

pub fn stz_url_query(h: ?*Url, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    return copyField(h, "query", buf, buf_len);
}

pub fn stz_url_fragment(h: ?*Url, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    return copyField(h, "fragment", buf, buf_len);
}

pub fn stz_url_user(h: ?*Url, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    return copyField(h, "user", buf, buf_len);
}

pub fn stz_url_password(h: ?*Url, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    return copyField(h, "password", buf, buf_len);
}

pub fn stz_url_reconstruct(h: ?*Url, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    const u = h orelse return 0;
    var out: usize = 0;

    if (u.scheme.len > 0) {
        if (!appendBuf(buf, buf_len, &out, u.scheme)) return 0;
        if (!appendBuf(buf, buf_len, &out, "://")) return 0;
    }
    if (u.user.len > 0) {
        if (!appendBuf(buf, buf_len, &out, u.user)) return 0;
        if (u.password.len > 0) {
            if (!appendBuf(buf, buf_len, &out, ":")) return 0;
            if (!appendBuf(buf, buf_len, &out, u.password)) return 0;
        }
        if (!appendBuf(buf, buf_len, &out, "@")) return 0;
    }
    if (u.host.len > 0) {
        if (!appendBuf(buf, buf_len, &out, u.host)) return 0;
    }
    if (u.port > 0 and u.port != 80 and u.port != 443) {
        var num_buf: [16]u8 = undefined;
        const num_slice = std.fmt.bufPrint(&num_buf, "{d}", .{u.port}) catch return 0;
        if (!appendBuf(buf, buf_len, &out, ":")) return 0;
        if (!appendBuf(buf, buf_len, &out, num_slice)) return 0;
    }
    if (u.path.len > 0) {
        if (u.path[0] != '/' and u.host.len > 0) {
            if (!appendBuf(buf, buf_len, &out, "/")) return 0;
        }
        if (!appendBuf(buf, buf_len, &out, u.path)) return 0;
    }
    if (u.query.len > 0) {
        if (!appendBuf(buf, buf_len, &out, "?")) return 0;
        if (!appendBuf(buf, buf_len, &out, u.query)) return 0;
    }
    if (u.fragment.len > 0) {
        if (!appendBuf(buf, buf_len, &out, "#")) return 0;
        if (!appendBuf(buf, buf_len, &out, u.fragment)) return 0;
    }
    return out;
}

// ─── Internal parser ───

fn parseInto(u: *Url, src: []const u8) void {
    var rest = src;

    // Fragment
    if (mem.indexOfScalar(u8, rest, '#')) |i| {
        u.fragment = rest[i + 1 ..];
        rest = rest[0..i];
    }
    // Query
    if (mem.indexOfScalar(u8, rest, '?')) |i| {
        u.query = rest[i + 1 ..];
        rest = rest[0..i];
    }
    // Scheme
    if (mem.indexOf(u8, rest, "://")) |i| {
        u.scheme = rest[0..i];
        rest = rest[i + 3 ..];
    }
    // Userinfo
    if (mem.indexOfScalar(u8, rest, '@')) |i| {
        const ui = rest[0..i];
        rest = rest[i + 1 ..];
        if (mem.indexOfScalar(u8, ui, ':')) |ci| {
            u.user = ui[0..ci];
            u.password = ui[ci + 1 ..];
        } else {
            u.user = ui;
        }
    }
    // Host:port vs path
    if (mem.indexOfScalar(u8, rest, '/')) |i| {
        parseHostPort(u, rest[0..i]);
        u.path = rest[i..];
    } else {
        parseHostPort(u, rest);
    }
}

fn parseHostPort(u: *Url, hp: []const u8) void {
    if (mem.lastIndexOfScalar(u8, hp, ':')) |i| {
        u.host = hp[0..i];
        u.port = std.fmt.parseInt(i32, hp[i + 1 ..], 10) catch -1;
    } else {
        u.host = hp;
    }
}

fn copyField(h: ?*Url, comptime field: []const u8, buf: [*c]u8, buf_len: usize) usize {
    const u = h orelse return 0;
    const val = @field(u, field);
    if (val.len == 0 or val.len > buf_len) return 0;
    @memcpy(buf[0..val.len], val);
    return val.len;
}

fn appendBuf(buf: [*c]u8, buf_len: usize, out: *usize, data: []const u8) bool {
    if (out.* + data.len > buf_len) return false;
    @memcpy(buf[out.*..][0..data.len], data);
    out.* += data.len;
    return true;
}

// ─── Tests ───

test "parse full url" {
    const u = stz_url_parse("https://user:pass@example.com:8080/path?q=1#frag", 48) orelse return error.NullUrl;
    defer stz_url_free(u);
    try std.testing.expectEqual(@as(c_int, 1), stz_url_is_valid(u));
    try std.testing.expectEqual(@as(c_int, 8080), stz_url_port(u));

    var buf: [256]u8 = undefined;
    var len = stz_url_scheme(u, &buf, 256);
    try std.testing.expect(mem.eql(u8, buf[0..len], "https"));
    len = stz_url_host(u, &buf, 256);
    try std.testing.expect(mem.eql(u8, buf[0..len], "example.com"));
    len = stz_url_user(u, &buf, 256);
    try std.testing.expect(mem.eql(u8, buf[0..len], "user"));
    len = stz_url_query(u, &buf, 256);
    try std.testing.expect(mem.eql(u8, buf[0..len], "q=1"));
}

test "simple url" {
    const u = stz_url_parse("http://example.com/page", 23) orelse return error.NullUrl;
    defer stz_url_free(u);
    var buf: [256]u8 = undefined;
    const len = stz_url_path(u, &buf, 256);
    try std.testing.expect(mem.eql(u8, buf[0..len], "/page"));
}
