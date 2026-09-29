// MODEL DIGESTS -- a GGUF file is parsed only once its SHA-256 is KNOWN.
//
// Every model file used to go straight to ggml's GGUF parser: a swapped,
// truncated or hostile file was read as if it were the model the program
// was written for. A model is now opened only when its digest matches one
// that was RECORDED for it, and the check runs BEFORE the parser sees a
// byte (the parser is the attack surface; a digest checked after parsing
// protects nothing).
//
// Where an expected digest comes from, in order:
//   1. this process: a digest registered with stz_model_expect (the caller
//      pins one it got from the publisher), or by stz_gguf_export_write for
//      a file this process just wrote itself;
//   2. a SHA256SUMS file in the model's own directory, in the standard
//      `sha256sum` format:  <64 hex>  <filename>
//
// No recorded digest is a refusal, not a pass -- the same fail-closed
// shape as the TLS client. Trusting a new model is an explicit act
// (StzTrustModel in Ring), never a default.
//
// Hashing a 135 MB model costs a fraction of a second, so a digest is
// cached per process against the file's path, size and modification time.

const std = @import("std");
const builtin = @import("builtin");

pub const OK: i32 = 0;
pub const ERR_UNREADABLE: i32 = -1;
pub const ERR_MISMATCH: i32 = -2;
pub const ERR_UNKNOWN: i32 = -3;

const gpa = std.heap.c_allocator;
const HEX = 64;

const Entry = struct { path: []u8, hex: [HEX]u8 };
const Cached = struct { path: []u8, size: u64, mtime: i128, hex: [HEX]u8 };

var g_expected: std.ArrayListUnmanaged(Entry) = .{};
var g_cache: std.ArrayListUnmanaged(Cached) = .{};
var g_mutex: std.Thread.Mutex = .{};
var g_last_hex: [HEX + 1]u8 = [_]u8{0} ** (HEX + 1);

fn pathEql(a: []const u8, b: []const u8) bool {
    if (builtin.os.tag == .windows) return std.ascii.eqlIgnoreCase(a, b);
    return std.mem.eql(u8, a, b);
}

fn normHex(src: []const u8, out: *[HEX]u8) bool {
    if (src.len != HEX) return false;
    for (src, 0..) |ch, i| {
        if (!std.ascii.isHex(ch)) return false;
        out[i] = std.ascii.toLower(ch);
    }
    return true;
}

/// SHA-256 of the file, as 64 lowercase hex characters (cached).
fn digestOf(path: []const u8, out: *[HEX]u8) bool {
    const file = std.fs.cwd().openFile(path, .{}) catch return false;
    defer file.close();
    const st = file.stat() catch return false;
    for (g_cache.items) |e| {
        if (pathEql(e.path, path) and e.size == st.size and e.mtime == st.mtime) {
            out.* = e.hex;
            return true;
        }
    }
    var h = std.crypto.hash.sha2.Sha256.init(.{});
    const buf = gpa.alloc(u8, 1 << 20) catch return false;
    defer gpa.free(buf);
    while (true) {
        const n = file.read(buf) catch return false;
        if (n == 0) break;
        h.update(buf[0..n]);
    }
    var raw: [32]u8 = undefined;
    h.final(&raw);
    const hexed = std.fmt.bytesToHex(raw, .lower);
    out.* = hexed;
    const p = gpa.dupe(u8, path) catch return true;
    g_cache.append(gpa, .{ .path = p, .size = st.size, .mtime = st.mtime, .hex = hexed }) catch gpa.free(p);
    return true;
}

/// The recorded digest for `path`, from this process or from SHA256SUMS.
fn expectedOf(path: []const u8, out: *[HEX]u8) bool {
    for (g_expected.items) |e| {
        if (pathEql(e.path, path)) {
            out.* = e.hex;
            return true;
        }
    }
    const dir = std.fs.path.dirname(path) orelse ".";
    const base = std.fs.path.basename(path);
    var d = std.fs.cwd().openDir(dir, .{}) catch return false;
    defer d.close();
    const text = d.readFileAlloc(gpa, "SHA256SUMS", 1 << 20) catch return false;
    defer gpa.free(text);
    var lines = std.mem.splitScalar(u8, text, '\n');
    while (lines.next()) |raw_line| {
        const line = std.mem.trim(u8, raw_line, " \t\r");
        if (line.len < HEX + 2 or line[0] == '#') continue;
        var name = std.mem.trimLeft(u8, line[HEX..], " \t");
        if (name.len > 0 and name[0] == '*') name = name[1..]; // binary-mode marker
        if (!pathEql(name, base)) continue;
        if (normHex(line[0..HEX], out)) return true;
    }
    return false;
}

/// Verify `path` against its recorded digest. OK, or ERR_*.
pub fn verify(path_c: [*c]const u8) i32 {
    if (path_c == null) return ERR_UNREADABLE;
    const path = std.mem.span(@as([*:0]const u8, @ptrCast(path_c)));
    g_mutex.lock();
    defer g_mutex.unlock();
    var got: [HEX]u8 = undefined;
    if (!digestOf(path, &got)) return ERR_UNREADABLE;
    @memcpy(g_last_hex[0..HEX], &got);
    var want: [HEX]u8 = undefined;
    if (!expectedOf(path, &want)) return ERR_UNKNOWN;
    return if (std.mem.eql(u8, &got, &want)) OK else ERR_MISMATCH;
}

/// Register the digest `path` must have, for this process. 1 ok, 0 bad hex.
pub fn stz_model_expect(path_c: [*c]const u8, hex_c: [*c]const u8, hex_len: usize) callconv(.c) i32 {
    if (path_c == null or hex_c == null) return 0;
    const path = std.mem.span(@as([*:0]const u8, @ptrCast(path_c)));
    var hex: [HEX]u8 = undefined;
    if (!normHex(hex_c[0..hex_len], &hex)) return 0;
    g_mutex.lock();
    defer g_mutex.unlock();
    for (g_expected.items) |*e| {
        if (pathEql(e.path, path)) {
            e.hex = hex;
            return 1;
        }
    }
    const p = gpa.dupe(u8, path) catch return 0;
    g_expected.append(gpa, .{ .path = p, .hex = hex }) catch {
        gpa.free(p);
        return 0;
    };
    return 1;
}

/// The file's SHA-256 as 64 hex characters, "" when unreadable. The
/// pointer is valid until the next digest call.
pub fn stz_model_digest(path_c: [*c]const u8) callconv(.c) [*:0]const u8 {
    if (path_c == null) return "";
    const path = std.mem.span(@as([*:0]const u8, @ptrCast(path_c)));
    g_mutex.lock();
    defer g_mutex.unlock();
    var got: [HEX]u8 = undefined;
    if (!digestOf(path, &got)) return "";
    @memcpy(g_last_hex[0..HEX], &got);
    g_last_hex[HEX] = 0;
    return @ptrCast(&g_last_hex);
}

/// A file this process has just written itself is trusted in this process.
pub fn trustWritten(path_c: [*c]const u8) void {
    const hex = stz_model_digest(path_c);
    const s = std.mem.span(hex);
    if (s.len == HEX) _ = stz_model_expect(path_c, s.ptr, s.len);
}

test "a digest is refused unless it was recorded, and a mismatch is refused" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    try tmp.dir.writeFile(.{ .sub_path = "m.gguf", .data = "abc" });
    const dir = try tmp.dir.realpathAlloc(std.testing.allocator, ".");
    defer std.testing.allocator.free(dir);
    const path = try std.fs.path.joinZ(std.testing.allocator, &.{ dir, "m.gguf" });
    defer std.testing.allocator.free(path);
    try std.testing.expectEqual(ERR_UNKNOWN, verify(path.ptr));
    // sha256("abc")
    const good = "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad";
    try tmp.dir.writeFile(.{ .sub_path = "SHA256SUMS", .data = good ++ "  m.gguf\n" });
    try std.testing.expectEqual(OK, verify(path.ptr));
    try tmp.dir.writeFile(.{ .sub_path = "SHA256SUMS", .data = ("0" ** 64) ++ "  m.gguf\n" });
    try std.testing.expectEqual(ERR_MISMATCH, verify(path.ptr));
}
