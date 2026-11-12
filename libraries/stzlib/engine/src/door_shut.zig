// The engine-side shut list (SECURITY-R18c, SOFTANZA_ONE_HOUR.md B5).
//
// stzExposureResponder shuts a door for an advisory: refuse a listener, a fetch,
// a model. Until R18c the list lived in a Ring global, so it bound the Ring doors
// and nothing else -- an engine call made directly (StzEngineNeural* on a shut
// model) ran, recorded but not refused. The list lives here now, in stz_seclog,
// the one DLL every engine domain already reaches (seclog_door.zig), so an engine
// entry point can ask before it acts.
//
// A row is kind + name + the advisory that shut it. Kinds and names compare with
// ASCII case ignored; the name "*" covers every name of its kind. One process,
// one list, a mutex around it. The table is fixed: a shut that does not fit is
// refused (false), never dropped silently.

const std = @import("std");

pub const max_rows = 256;
const kind_cap = 16;
const name_cap = 192;
const adv_cap = 64;

const Row = struct {
    used: bool = false,
    kind: [kind_cap]u8 = undefined,
    kind_len: usize = 0,
    name: [name_cap]u8 = undefined,
    name_len: usize = 0,
    adv: [adv_cap]u8 = undefined,
    adv_len: usize = 0,
};

var rows: [max_rows]Row = [_]Row{.{}} ** max_rows;
var lock: std.Thread.Mutex = .{};

fn put(dst: []u8, src: []const u8) ?usize {
    if (src.len == 0 or src.len > dst.len) return null;
    for (src, 0..) |c, i| dst[i] = std.ascii.toLower(c);
    return src.len;
}

fn same(a: []const u8, b: []const u8) bool {
    return std.ascii.eqlIgnoreCase(a, b);
}

/// Shuts the door of a kind to a name (or "*") for an advisory. True when the
/// row is in the list (a second shut of the same row is a no-op, still true).
pub fn shut(kind: []const u8, name: []const u8, advisory: []const u8) bool {
    if (kind.len == 0 or kind.len > kind_cap or name.len == 0 or name.len > name_cap) return false;
    if (advisory.len == 0 or advisory.len > adv_cap) return false;
    lock.lock();
    defer lock.unlock();
    var free: ?usize = null;
    for (&rows, 0..) |*r, i| {
        if (!r.used) {
            if (free == null) free = i;
            continue;
        }
        if (same(r.kind[0..r.kind_len], kind) and same(r.name[0..r.name_len], name) and
            std.mem.eql(u8, r.adv[0..r.adv_len], advisory)) return true;
    }
    const i = free orelse return false;
    var r = &rows[i];
    r.kind_len = put(&r.kind, kind) orelse return false;
    r.name_len = put(&r.name, name) orelse return false;
    @memcpy(r.adv[0..advisory.len], advisory);
    r.adv_len = advisory.len;
    r.used = true;
    return true;
}

/// Opens every door one advisory shut. Returns how many rows it removed.
pub fn reopen(advisory: []const u8) usize {
    lock.lock();
    defer lock.unlock();
    var n: usize = 0;
    for (&rows) |*r| {
        if (r.used and std.mem.eql(u8, r.adv[0..r.adv_len], advisory)) {
            r.* = .{};
            n += 1;
        }
    }
    return n;
}

/// The advisory that shut the door of this kind to this name, copied into out;
/// null when the door is open. A row named "*" covers every name.
pub fn query(kind: []const u8, name: []const u8, out: []u8) ?[]const u8 {
    lock.lock();
    defer lock.unlock();
    for (&rows) |*r| {
        if (!r.used or !same(r.kind[0..r.kind_len], kind)) continue;
        const rn = r.name[0..r.name_len];
        if (!(rn.len == 1 and rn[0] == '*') and !same(rn, name)) continue;
        const n = @min(r.adv_len, out.len);
        @memcpy(out[0..n], r.adv[0..n]);
        return out[0..n];
    }
    return null;
}

pub fn count() usize {
    lock.lock();
    defer lock.unlock();
    var n: usize = 0;
    for (rows) |r| {
        if (r.used) n += 1;
    }
    return n;
}

/// Empties the list. For a test's setup only; a program reopens by advisory.
pub fn clearForTest() void {
    lock.lock();
    defer lock.unlock();
    rows = [_]Row{.{}} ** max_rows;
}

test "a shut door answers its advisory, an open one answers null" {
    clearForTest();
    var buf: [64]u8 = undefined;
    try std.testing.expect(shut("model", "owlvit-b32.gguf", "ADV-1"));
    try std.testing.expectEqualStrings("ADV-1", query("model", "owlvit-b32.gguf", &buf).?);
    try std.testing.expect(query("model", "mobilesam.gguf", &buf) == null);
    try std.testing.expect(query("fetch", "owlvit-b32.gguf", &buf) == null);
}

test "kind and name ignore case; * covers every name of its kind only" {
    clearForTest();
    var buf: [64]u8 = undefined;
    try std.testing.expect(shut("Model", "OWLVIT-B32.GGUF", "ADV-2"));
    try std.testing.expect(query("model", "owlvit-b32.gguf", &buf) != null);
    try std.testing.expect(shut("fetch", "*", "ADV-3"));
    try std.testing.expectEqualStrings("ADV-3", query("FETCH", "api.osv.dev", &buf).?);
    try std.testing.expect(query("listener", "stztcpserver", &buf) == null);
}

test "reopen removes only its own advisory's rows" {
    clearForTest();
    var buf: [64]u8 = undefined;
    try std.testing.expect(shut("model", "a", "ADV-4"));
    try std.testing.expect(shut("model", "b", "ADV-4"));
    try std.testing.expect(shut("model", "c", "ADV-5"));
    try std.testing.expectEqual(@as(usize, 2), reopen("ADV-4"));
    try std.testing.expect(query("model", "a", &buf) == null);
    try std.testing.expect(query("model", "c", &buf) != null);
    try std.testing.expectEqual(@as(usize, 1), count());
}

test "a second shut of the same row is one row" {
    clearForTest();
    try std.testing.expect(shut("model", "a", "ADV-6"));
    try std.testing.expect(shut("model", "a", "ADV-6"));
    try std.testing.expectEqual(@as(usize, 1), count());
}

test "a full table refuses, it never drops a row" {
    clearForTest();
    var name: [8]u8 = undefined;
    var i: usize = 0;
    while (i < max_rows) : (i += 1) {
        const n = std.fmt.bufPrint(&name, "m{d}", .{i}) catch unreachable;
        try std.testing.expect(shut("model", n, "ADV-7"));
    }
    try std.testing.expect(!shut("model", "one-more", "ADV-7"));
    try std.testing.expectEqual(@as(usize, max_rows), count());
    var buf: [64]u8 = undefined;
    try std.testing.expect(query("model", "m0", &buf) != null);
}

test "empty or oversized fields are refused" {
    clearForTest();
    try std.testing.expect(!shut("", "a", "ADV-8"));
    try std.testing.expect(!shut("model", "", "ADV-8"));
    try std.testing.expect(!shut("model", "a", ""));
    try std.testing.expect(!shut("a-kind-longer-than-sixteen", "a", "ADV-8"));
    try std.testing.expectEqual(@as(usize, 0), count());
}
