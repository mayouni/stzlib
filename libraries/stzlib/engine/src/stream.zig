const std = @import("std");

// ── Byte Stream (fixed buffer, read/write cursor) ──────────

const MAX_STREAMS = 32;
const STREAM_BUF_SIZE = 65536;

const Stream = struct {
    buf: [STREAM_BUF_SIZE]u8 = [_]u8{0} ** STREAM_BUF_SIZE,
    write_pos: usize = 0,
    read_pos: usize = 0,
    active: bool = false,
};

var streams: [MAX_STREAMS]Stream = [_]Stream{.{}} ** MAX_STREAMS;

pub fn stream_open(id: u32) callconv(.c) i32 {
    if (id >= MAX_STREAMS) return -1;
    streams[id] = .{};
    streams[id].active = true;
    return 0;
}

pub fn stream_close(id: u32) callconv(.c) i32 {
    if (id >= MAX_STREAMS) return -1;
    streams[id].active = false;
    return 0;
}

pub fn stream_write(id: u32, data_ptr: [*]const u8, data_len: usize) callconv(.c) i32 {
    if (id >= MAX_STREAMS or !streams[id].active) return -1;
    const avail = STREAM_BUF_SIZE - streams[id].write_pos;
    if (data_len > avail) return -2;
    @memcpy(streams[id].buf[streams[id].write_pos .. streams[id].write_pos + data_len], data_ptr[0..data_len]);
    streams[id].write_pos += data_len;
    return @intCast(data_len);
}

pub fn stream_read(id: u32, out: [*]u8, max: usize) callconv(.c) i32 {
    if (id >= MAX_STREAMS or !streams[id].active) return -1;
    const available = streams[id].write_pos - streams[id].read_pos;
    const n = @min(available, max);
    if (n == 0) return 0;
    @memcpy(out[0..n], streams[id].buf[streams[id].read_pos .. streams[id].read_pos + n]);
    streams[id].read_pos += n;
    return @intCast(n);
}

pub fn stream_available(id: u32) callconv(.c) i32 {
    if (id >= MAX_STREAMS or !streams[id].active) return -1;
    return @intCast(streams[id].write_pos - streams[id].read_pos);
}

pub fn stream_reset(id: u32) callconv(.c) i32 {
    if (id >= MAX_STREAMS or !streams[id].active) return -1;
    streams[id].write_pos = 0;
    streams[id].read_pos = 0;
    return 0;
}

pub fn stream_seek(id: u32, pos: u32) callconv(.c) i32 {
    if (id >= MAX_STREAMS or !streams[id].active) return -1;
    if (pos > streams[id].write_pos) return -2;
    streams[id].read_pos = pos;
    return 0;
}

pub fn stream_size(id: u32) callconv(.c) i32 {
    if (id >= MAX_STREAMS or !streams[id].active) return -1;
    return @intCast(streams[id].write_pos);
}

pub fn stream_is_open(id: u32) callconv(.c) i32 {
    if (id >= MAX_STREAMS) return 0;
    return if (streams[id].active) 1 else 0;
}

pub fn stream_peek(id: u32, out: [*]u8, max: usize) callconv(.c) i32 {
    if (id >= MAX_STREAMS or !streams[id].active) return -1;
    const available = streams[id].write_pos - streams[id].read_pos;
    const n = @min(available, max);
    if (n == 0) return 0;
    @memcpy(out[0..n], streams[id].buf[streams[id].read_pos .. streams[id].read_pos + n]);
    return @intCast(n);
}

// ── C ABI exports ────────────────────────────────────────────

pub export fn stz_stream_open(id: u32) callconv(.c) i32 { return stream_open(id); }
pub export fn stz_stream_close(id: u32) callconv(.c) i32 { return stream_close(id); }
pub export fn stz_stream_write(id: u32, p: [*]const u8, l: usize) callconv(.c) i32 { return stream_write(id, p, l); }
pub export fn stz_stream_read(id: u32, o: [*]u8, m: usize) callconv(.c) i32 { return stream_read(id, o, m); }
pub export fn stz_stream_available(id: u32) callconv(.c) i32 { return stream_available(id); }
pub export fn stz_stream_reset(id: u32) callconv(.c) i32 { return stream_reset(id); }
pub export fn stz_stream_seek(id: u32, pos: u32) callconv(.c) i32 { return stream_seek(id, pos); }
pub export fn stz_stream_size(id: u32) callconv(.c) i32 { return stream_size(id); }
pub export fn stz_stream_is_open(id: u32) callconv(.c) i32 { return stream_is_open(id); }
pub export fn stz_stream_peek(id: u32, o: [*]u8, m: usize) callconv(.c) i32 { return stream_peek(id, o, m); }

// ── Tests ────────────────────────────────────────────────────

test "stream: open/close" {
    try std.testing.expectEqual(@as(i32, 0), stream_open(0));
    try std.testing.expectEqual(@as(i32, 1), stream_is_open(0));
    try std.testing.expectEqual(@as(i32, 0), stream_close(0));
    try std.testing.expectEqual(@as(i32, 0), stream_is_open(0));
}

test "stream: write/read" {
    _ = stream_open(1);
    const data = "hello stream";
    try std.testing.expectEqual(@as(i32, 12), stream_write(1, data.ptr, data.len));
    try std.testing.expectEqual(@as(i32, 12), stream_size(1));
    var buf: [64]u8 = undefined;
    const n = stream_read(1, &buf, 64);
    try std.testing.expectEqual(@as(i32, 12), n);
    try std.testing.expectEqualStrings("hello stream", buf[0..@intCast(n)]);
    _ = stream_close(1);
}

test "stream: peek does not advance" {
    _ = stream_open(2);
    _ = stream_write(2, "abc".ptr, 3);
    var buf: [64]u8 = undefined;
    _ = stream_peek(2, &buf, 64);
    try std.testing.expectEqual(@as(i32, 3), stream_available(2));
    _ = stream_close(2);
}

test "stream: seek" {
    _ = stream_open(3);
    _ = stream_write(3, "abcdef".ptr, 6);
    var discard: [8]u8 = undefined;
    _ = stream_read(3, &discard, 3);
    try std.testing.expectEqual(@as(i32, 0), stream_seek(3, 0));
    try std.testing.expectEqual(@as(i32, 6), stream_available(3));
    _ = stream_close(3);
}

test "stream: reset" {
    _ = stream_open(4);
    _ = stream_write(4, "data".ptr, 4);
    _ = stream_reset(4);
    try std.testing.expectEqual(@as(i32, 0), stream_size(4));
    _ = stream_close(4);
}

test "stream: bounds check" {
    try std.testing.expectEqual(@as(i32, -1), stream_open(32));
    try std.testing.expectEqual(@as(i32, 0), stream_is_open(32));
}
