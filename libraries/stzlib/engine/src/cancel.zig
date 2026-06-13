// Context-style cancellation tokens.
//
// Gap-analysis Tier 1 item 4. A CancelToken is a shared flag a caller
// can flip to ask a long-running operation to stop. Pool jobs (pool.zig)
// can carry an optional token; the worker checks it before running a job
// and surfaces a cancellation status instead of executing.
//
// The flag is a single atomic bool -- create / signal / poll / destroy.
// A token is a plain heap pointer so it crosses the C ABI as an opaque
// handle; the struct layout is identical wherever cancel.zig is compiled,
// so a token created in one engine DLL is readable in another (e.g.
// created via stz_pool and passed back into a pool submission there).

const std = @import("std");

const gpa = std.heap.c_allocator;

pub const CancelToken = struct {
    flag: std.atomic.Value(bool),
};

pub fn cancel_create() callconv(.c) ?*CancelToken {
    const t = gpa.create(CancelToken) catch return null;
    t.* = .{ .flag = std.atomic.Value(bool).init(false) };
    return t;
}

pub fn cancel_signal(tok: ?*CancelToken) callconv(.c) void {
    const t = tok orelse return;
    t.flag.store(true, .release);
}

pub fn cancel_is_cancelled(tok: ?*CancelToken) callconv(.c) i32 {
    const t = tok orelse return 0;
    return if (t.flag.load(.acquire)) 1 else 0;
}

pub fn cancel_destroy(tok: ?*CancelToken) callconv(.c) void {
    const t = tok orelse return;
    gpa.destroy(t);
}

// ── tests ────────────────────────────────────────────────────

test "cancel: lifecycle" {
    const t = cancel_create().?;
    defer cancel_destroy(t);
    try std.testing.expectEqual(@as(i32, 0), cancel_is_cancelled(t));
    cancel_signal(t);
    try std.testing.expectEqual(@as(i32, 1), cancel_is_cancelled(t));
}

test "cancel: null handle is safe" {
    try std.testing.expectEqual(@as(i32, 0), cancel_is_cancelled(null));
    cancel_signal(null); // no-op
    cancel_destroy(null); // no-op
}
