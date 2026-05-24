const std = @import("std");

// ── Async Task Queue (cooperative, single-threaded) ────────
// Fixed-slot task queue for deferred work. Tasks have a name,
// status, and result buffer. No real threading -- this is a
// cooperative scheduling primitive for Ring code.

const MAX_TASKS = 64;
const MAX_NAME = 64;
const MAX_RESULT = 1024;

const TaskStatus = enum(u8) {
    empty = 0,
    pending = 1,
    running = 2,
    done = 3,
    failed = 4,
};

const Task = struct {
    name: [MAX_NAME]u8 = [_]u8{0} ** MAX_NAME,
    name_len: usize = 0,
    status: TaskStatus = .empty,
    result: [MAX_RESULT]u8 = [_]u8{0} ** MAX_RESULT,
    result_len: usize = 0,
    priority: u8 = 0,
};

var tasks: [MAX_TASKS]Task = [_]Task{.{}} ** MAX_TASKS;

pub fn async_create(name_ptr: [*]const u8, name_len: usize, priority: u8) callconv(.c) i32 {
    if (name_len > MAX_NAME) return -1;
    for (0..MAX_TASKS) |i| {
        if (tasks[i].status == .empty) {
            @memcpy(tasks[i].name[0..name_len], name_ptr[0..name_len]);
            tasks[i].name_len = name_len;
            tasks[i].status = .pending;
            tasks[i].result_len = 0;
            tasks[i].priority = priority;
            return @intCast(i);
        }
    }
    return -2;
}

pub fn async_status(id: u32) callconv(.c) u8 {
    if (id >= MAX_TASKS) return 0;
    return @intFromEnum(tasks[id].status);
}

pub fn async_start(id: u32) callconv(.c) i32 {
    if (id >= MAX_TASKS) return -1;
    if (tasks[id].status != .pending) return -2;
    tasks[id].status = .running;
    return 0;
}

pub fn async_complete(id: u32, result_ptr: [*]const u8, result_len: usize) callconv(.c) i32 {
    if (id >= MAX_TASKS) return -1;
    if (tasks[id].status != .running) return -2;
    if (result_len > MAX_RESULT) return -3;
    @memcpy(tasks[id].result[0..result_len], result_ptr[0..result_len]);
    tasks[id].result_len = result_len;
    tasks[id].status = .done;
    return 0;
}

pub fn async_fail(id: u32, msg_ptr: [*]const u8, msg_len: usize) callconv(.c) i32 {
    if (id >= MAX_TASKS) return -1;
    if (tasks[id].status != .running) return -2;
    const n = @min(msg_len, MAX_RESULT);
    @memcpy(tasks[id].result[0..n], msg_ptr[0..n]);
    tasks[id].result_len = n;
    tasks[id].status = .failed;
    return 0;
}

pub fn async_result(id: u32, out: [*]u8, max: usize) callconv(.c) i32 {
    if (id >= MAX_TASKS) return -1;
    if (tasks[id].status != .done and tasks[id].status != .failed) return -2;
    const n = @min(tasks[id].result_len, max);
    @memcpy(out[0..n], tasks[id].result[0..n]);
    return @intCast(n);
}

pub fn async_cancel(id: u32) callconv(.c) i32 {
    if (id >= MAX_TASKS) return -1;
    tasks[id].status = .empty;
    return 0;
}

pub fn async_pending_count() callconv(.c) u32 {
    var count: u32 = 0;
    for (0..MAX_TASKS) |i| {
        if (tasks[i].status == .pending) count += 1;
    }
    return count;
}

pub fn async_next_pending() callconv(.c) i32 {
    var best: i32 = -1;
    var best_pri: u8 = 0;
    for (0..MAX_TASKS) |i| {
        if (tasks[i].status == .pending) {
            if (best == -1 or tasks[i].priority > best_pri) {
                best = @intCast(i);
                best_pri = tasks[i].priority;
            }
        }
    }
    return best;
}

pub fn async_clear() callconv(.c) void {
    for (0..MAX_TASKS) |i| tasks[i].status = .empty;
}

// ── C ABI exports ────────────────────────────────────────────

pub export fn stz_async_create(p: [*]const u8, l: usize, pri: u8) callconv(.c) i32 { return async_create(p, l, pri); }
pub export fn stz_async_status(id: u32) callconv(.c) u8 { return async_status(id); }
pub export fn stz_async_start(id: u32) callconv(.c) i32 { return async_start(id); }
pub export fn stz_async_complete(id: u32, p: [*]const u8, l: usize) callconv(.c) i32 { return async_complete(id, p, l); }
pub export fn stz_async_fail(id: u32, p: [*]const u8, l: usize) callconv(.c) i32 { return async_fail(id, p, l); }
pub export fn stz_async_result(id: u32, o: [*]u8, m: usize) callconv(.c) i32 { return async_result(id, o, m); }
pub export fn stz_async_cancel(id: u32) callconv(.c) i32 { return async_cancel(id); }
pub export fn stz_async_pending_count() callconv(.c) u32 { return async_pending_count(); }
pub export fn stz_async_next_pending() callconv(.c) i32 { return async_next_pending(); }
pub export fn stz_async_clear() callconv(.c) void { async_clear(); }

// ── Tests ────────────────────────────────────────────────────

test "async: create/status" {
    async_clear();
    const id = async_create("task1".ptr, 5, 1);
    try std.testing.expect(id >= 0);
    try std.testing.expectEqual(@as(u8, 1), async_status(@intCast(id)));
}

test "async: lifecycle" {
    async_clear();
    const id: u32 = @intCast(async_create("job".ptr, 3, 0));
    try std.testing.expectEqual(@as(i32, 0), async_start(id));
    try std.testing.expectEqual(@as(u8, 2), async_status(id));
    try std.testing.expectEqual(@as(i32, 0), async_complete(id, "ok".ptr, 2));
    try std.testing.expectEqual(@as(u8, 3), async_status(id));
    var buf: [64]u8 = undefined;
    const len = async_result(id, &buf, 64);
    try std.testing.expectEqualStrings("ok", buf[0..@intCast(len)]);
}

test "async: fail" {
    async_clear();
    const id: u32 = @intCast(async_create("bad".ptr, 3, 0));
    _ = async_start(id);
    _ = async_fail(id, "error".ptr, 5);
    try std.testing.expectEqual(@as(u8, 4), async_status(id));
}

test "async: pending count" {
    async_clear();
    _ = async_create("a".ptr, 1, 0);
    _ = async_create("b".ptr, 1, 0);
    try std.testing.expectEqual(@as(u32, 2), async_pending_count());
}

test "async: next pending by priority" {
    async_clear();
    _ = async_create("low".ptr, 3, 1);
    const high = async_create("high".ptr, 4, 5);
    try std.testing.expectEqual(high, async_next_pending());
}

test "async: cancel" {
    async_clear();
    const id: u32 = @intCast(async_create("x".ptr, 1, 0));
    _ = async_cancel(id);
    try std.testing.expectEqual(@as(u8, 0), async_status(id));
}
