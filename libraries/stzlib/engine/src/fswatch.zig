// Background folder watcher -- polling-based, cross-platform.
//
// A worker thread walks the watched directory at a configurable
// interval, snapshots (mtime, size), and diffs against the previous
// snapshot. Differences become events on a queue the Ring side
// drains. No OS-specific APIs (no IOCP / inotify / FSEvents) --
// portable across Windows / Linux / macOS via std.fs.
//
// API:
//   fswatch_start(path) -> opaque handle (or null)
//   fswatch_poll(handle, out, max) -> bytes written
//     Each event: "<kind>\t<name>\n" where kind in {ADD, MOD, DEL}.
//   fswatch_stop(handle)
//   fswatch_last_error_len() / fswatch_last_error(buf, max)

const std = @import("std");

const gpa = std.heap.c_allocator;

var last_error_buf: [512]u8 = undefined;
var last_error_len: usize = 0;

fn setError(msg: []const u8) void {
    const n = @min(msg.len, last_error_buf.len);
    @memcpy(last_error_buf[0..n], msg[0..n]);
    last_error_len = n;
}

pub fn fswatch_last_error_len() callconv(.c) usize {
    return last_error_len;
}

pub fn fswatch_last_error(out: [*]u8, max: usize) callconv(.c) i32 {
    const n = @min(last_error_len, max);
    if (n == 0) return 0;
    @memcpy(out[0..n], last_error_buf[0..n]);
    return @intCast(n);
}

const Entry = struct {
    mtime: i128,
    size: u64,
};

pub const Watcher = struct {
    path: []u8,
    poll_interval_ms: u64,
    snapshot: std.StringHashMapUnmanaged(Entry),
    events: std.ArrayList(u8),
    mutex: std.Thread.Mutex,
    stop_flag: std.atomic.Value(bool),
    thread: ?std.Thread,
};

pub fn fswatch_start(
    path_ptr: [*]const u8,
    path_len: usize,
) callconv(.c) ?*Watcher {
    last_error_len = 0;
    if (path_len == 0) {
        setError("empty path");
        return null;
    }
    const path_copy = gpa.dupe(u8, path_ptr[0..path_len]) catch {
        setError("oom (path)");
        return null;
    };

    const w = gpa.create(Watcher) catch {
        gpa.free(path_copy);
        setError("oom (watcher)");
        return null;
    };
    w.* = .{
        .path = path_copy,
        .poll_interval_ms = 250,
        .snapshot = .{},
        .events = .{},
        .mutex = .{},
        .stop_flag = std.atomic.Value(bool).init(false),
        .thread = null,
    };

    snapshotInitial(w) catch {};

    if (std.Thread.spawn(.{}, watcherLoop, .{w})) |t| {
        w.thread = t;
    } else |_| {
        setError("thread spawn failed");
    }
    return w;
}

pub fn fswatch_stop(w_opt: ?*Watcher) callconv(.c) void {
    const w = w_opt orelse return;
    w.stop_flag.store(true, .release);
    if (w.thread) |t| t.join();

    var it = w.snapshot.iterator();
    while (it.next()) |e| gpa.free(e.key_ptr.*);
    w.snapshot.deinit(gpa);
    w.events.deinit(gpa);
    gpa.free(w.path);
    gpa.destroy(w);
}

pub fn fswatch_poll(
    w_opt: ?*Watcher,
    out: [*]u8,
    max: usize,
) callconv(.c) i32 {
    const w = w_opt orelse return -1;
    w.mutex.lock();
    defer w.mutex.unlock();
    const buf = w.events.items;
    if (buf.len == 0) return 0;
    const n = @min(buf.len, max);
    @memcpy(out[0..n], buf[0..n]);
    w.events.clearRetainingCapacity();
    return @intCast(n);
}

// ── worker ───────────────────────────────────────────────────

fn watcherLoop(w: *Watcher) void {
    while (!w.stop_flag.load(.acquire)) {
        std.Thread.sleep(w.poll_interval_ms * std.time.ns_per_ms);
        if (w.stop_flag.load(.acquire)) break;
        diffAndEmit(w) catch {};
    }
}

fn snapshotInitial(w: *Watcher) !void {
    var dir = std.fs.cwd().openDir(w.path, .{ .iterate = true }) catch return;
    defer dir.close();

    var it = dir.iterate();
    while (try it.next()) |entry| {
        const stat = dir.statFile(entry.name) catch continue;
        const key = try gpa.dupe(u8, entry.name);
        try w.snapshot.put(gpa, key, .{
            .mtime = stat.mtime,
            .size = stat.size,
        });
    }
}

fn diffAndEmit(w: *Watcher) !void {
    var dir = std.fs.cwd().openDir(w.path, .{ .iterate = true }) catch return;
    defer dir.close();

    var seen = std.StringHashMapUnmanaged(void){};
    defer seen.deinit(gpa);

    var it = dir.iterate();
    while (try it.next()) |entry| {
        const stat = dir.statFile(entry.name) catch continue;
        try seen.put(gpa, entry.name, {});

        if (w.snapshot.get(entry.name)) |e| {
            if (e.mtime != stat.mtime or e.size != stat.size) {
                try emitEvent(w, "MOD", entry.name);
                try w.snapshot.put(gpa, w.snapshot.getKey(entry.name).?, .{
                    .mtime = stat.mtime,
                    .size = stat.size,
                });
            }
        } else {
            try emitEvent(w, "ADD", entry.name);
            const key = try gpa.dupe(u8, entry.name);
            try w.snapshot.put(gpa, key, .{
                .mtime = stat.mtime,
                .size = stat.size,
            });
        }
    }

    var to_delete = std.ArrayList([]const u8){};
    defer to_delete.deinit(gpa);
    var snap_it = w.snapshot.iterator();
    while (snap_it.next()) |e| {
        if (!seen.contains(e.key_ptr.*)) {
            try to_delete.append(gpa, e.key_ptr.*);
        }
    }
    for (to_delete.items) |name| {
        try emitEvent(w, "DEL", name);
        if (w.snapshot.fetchRemove(name)) |kv| {
            gpa.free(kv.key);
        }
    }
}

fn emitEvent(w: *Watcher, kind: []const u8, name: []const u8) !void {
    w.mutex.lock();
    defer w.mutex.unlock();
    try w.events.appendSlice(gpa, kind);
    try w.events.append(gpa, '\t');
    try w.events.appendSlice(gpa, name);
    try w.events.append(gpa, '\n');
}

// ── tests ────────────────────────────────────────────────────

test "fswatch: empty path rejected" {
    try std.testing.expect(fswatch_start("", 0) == null);
}

test "fswatch: nonexistent dir yields no events" {
    const w = fswatch_start("does/not/exist/12345", 21).?;
    defer fswatch_stop(w);
    std.Thread.sleep(400 * std.time.ns_per_ms);
    var buf: [256]u8 = undefined;
    try std.testing.expectEqual(@as(i32, 0), fswatch_poll(w, &buf, 256));
}
