const std = @import("std");

// ── Call Stack Tracker (manual push/pop for tracing) ────────
// Ring code pushes function names; on error, the stack shows
// the call chain. Not an automatic stack trace -- explicit.

const MAX_DEPTH = 128;
const MAX_FRAME_NAME = 128;

const Frame = struct {
    name: [MAX_FRAME_NAME]u8 = [_]u8{0} ** MAX_FRAME_NAME,
    name_len: usize = 0,
};

var stack: [MAX_DEPTH]Frame = [_]Frame{.{}} ** MAX_DEPTH;
var depth: u32 = 0;

pub fn callstack_push(name_ptr: [*]const u8, name_len: usize) callconv(.c) i32 {
    if (name_len > MAX_FRAME_NAME) return -1;
    if (depth >= MAX_DEPTH) return -2;
    @memcpy(stack[depth].name[0..name_len], name_ptr[0..name_len]);
    stack[depth].name_len = name_len;
    depth += 1;
    return 0;
}

pub fn callstack_pop() callconv(.c) i32 {
    if (depth == 0) return -1;
    depth -= 1;
    return 0;
}

pub fn callstack_depth() callconv(.c) u32 {
    return depth;
}

pub fn callstack_frame(index: u32, out: [*]u8, max: usize) callconv(.c) i32 {
    if (index >= depth) return -1;
    const nlen = stack[index].name_len;
    if (nlen > max) return -2;
    @memcpy(out[0..nlen], stack[index].name[0..nlen]);
    return @intCast(nlen);
}

pub fn callstack_top(out: [*]u8, max: usize) callconv(.c) i32 {
    if (depth == 0) return -1;
    return callstack_frame(depth - 1, out, max);
}

pub fn callstack_clear() callconv(.c) void {
    depth = 0;
}

pub fn callstack_to_string(out: [*]u8, max: usize) callconv(.c) i32 {
    var pos: usize = 0;
    var i: u32 = 0;
    while (i < depth) : (i += 1) {
        if (i > 0) {
            if (pos + 4 > max) return -1;
            @memcpy(out[pos .. pos + 4], " -> ");
            pos += 4;
        }
        const nlen = stack[i].name_len;
        if (pos + nlen > max) return -1;
        @memcpy(out[pos .. pos + nlen], stack[i].name[0..nlen]);
        pos += nlen;
    }
    return @intCast(pos);
}

// ── C ABI exports ────────────────────────────────────────────

pub export fn stz_callstack_push(p: [*]const u8, l: usize) callconv(.c) i32 { return callstack_push(p, l); }
pub export fn stz_callstack_pop() callconv(.c) i32 { return callstack_pop(); }
pub export fn stz_callstack_depth() callconv(.c) u32 { return callstack_depth(); }
pub export fn stz_callstack_frame(i: u32, o: [*]u8, m: usize) callconv(.c) i32 { return callstack_frame(i, o, m); }
pub export fn stz_callstack_top(o: [*]u8, m: usize) callconv(.c) i32 { return callstack_top(o, m); }
pub export fn stz_callstack_clear() callconv(.c) void { callstack_clear(); }
pub export fn stz_callstack_to_string(o: [*]u8, m: usize) callconv(.c) i32 { return callstack_to_string(o, m); }

// ── Tests ────────────────────────────────────────────────────

test "callstack: push/pop/depth" {
    callstack_clear();
    try std.testing.expectEqual(@as(u32, 0), callstack_depth());
    _ = callstack_push("main".ptr, 4);
    try std.testing.expectEqual(@as(u32, 1), callstack_depth());
    _ = callstack_push("helper".ptr, 6);
    try std.testing.expectEqual(@as(u32, 2), callstack_depth());
    _ = callstack_pop();
    try std.testing.expectEqual(@as(u32, 1), callstack_depth());
    callstack_clear();
}

test "callstack: frame" {
    callstack_clear();
    _ = callstack_push("alpha".ptr, 5);
    _ = callstack_push("beta".ptr, 4);
    var buf: [64]u8 = undefined;
    const len = callstack_frame(0, &buf, 64);
    try std.testing.expectEqualStrings("alpha", buf[0..@intCast(len)]);
    callstack_clear();
}

test "callstack: top" {
    callstack_clear();
    _ = callstack_push("first".ptr, 5);
    _ = callstack_push("second".ptr, 6);
    var buf: [64]u8 = undefined;
    const len = callstack_top(&buf, 64);
    try std.testing.expectEqualStrings("second", buf[0..@intCast(len)]);
    callstack_clear();
}

test "callstack: to_string" {
    callstack_clear();
    _ = callstack_push("a".ptr, 1);
    _ = callstack_push("b".ptr, 1);
    _ = callstack_push("c".ptr, 1);
    var buf: [256]u8 = undefined;
    const len = callstack_to_string(&buf, 256);
    try std.testing.expectEqualStrings("a -> b -> c", buf[0..@intCast(len)]);
    callstack_clear();
}

test "callstack: empty pop" {
    callstack_clear();
    try std.testing.expectEqual(@as(i32, -1), callstack_pop());
}

test "callstack: clear" {
    callstack_clear();
    _ = callstack_push("x".ptr, 1);
    callstack_clear();
    try std.testing.expectEqual(@as(u32, 0), callstack_depth());
}
