// Softanza Engine -- Byte Array Operations (Tier 3)
//
// Replaces QByteArray with Zig-native byte manipulation.
// Provides base64, hex, percent-encoding, and raw byte ops.
// All functions use C ABI for Ring FFI compatibility.

const std = @import("std");
const mem = std.mem;
const base64 = std.base64;
const gpa = std.heap.c_allocator;

// ─── Byte Array Handle ───

const Bytes = struct {
    data: std.ArrayList(u8),
};

pub const StzBytesHandle = ?*Bytes;

pub fn stz_bytes_new() callconv(.c) ?*Bytes {
    const b = gpa.create(Bytes) catch return null;
    b.* = .{ .data = .{} };
    return b;
}

pub fn stz_bytes_from(data: [*c]const u8, len: usize) callconv(.c) ?*Bytes {
    const b = gpa.create(Bytes) catch return null;
    b.* = .{ .data = .{} };
    if (data != null and len > 0) {
        b.data.appendSlice(gpa, data[0..len]) catch { gpa.destroy(b); return null; };
    }
    return b;
}

pub fn stz_bytes_free(h: ?*Bytes) callconv(.c) void {
    if (h) |b| { b.data.deinit(gpa); gpa.destroy(b); }
}

pub fn stz_bytes_data(h: ?*Bytes) callconv(.c) [*c]const u8 {
    const b = h orelse return null;
    if (b.data.items.len == 0) return null;
    return b.data.items.ptr;
}

pub fn stz_bytes_size(h: ?*Bytes) callconv(.c) c_int {
    const b = h orelse return 0;
    return @intCast(b.data.items.len);
}

pub fn stz_bytes_is_empty(h: ?*Bytes) callconv(.c) c_int {
    const b = h orelse return 1;
    return if (b.data.items.len == 0) 1 else 0;
}

pub fn stz_bytes_clear(h: ?*Bytes) callconv(.c) void {
    if (h) |b| b.data.clearRetainingCapacity();
}

pub fn stz_bytes_append(h: ?*Bytes, data: [*c]const u8, len: usize) callconv(.c) void {
    const b = h orelse return;
    if (data != null and len > 0) b.data.appendSlice(gpa, data[0..len]) catch {};
}

pub fn stz_bytes_at(h: ?*Bytes, idx: c_int) callconv(.c) c_int {
    const b = h orelse return -1;
    if (idx < 1) return -1;
    const i: usize = @intCast(idx - 1);
    if (i >= b.data.items.len) return -1;
    return @intCast(b.data.items[i]);
}

pub fn stz_bytes_insert(h: ?*Bytes, pos: c_int, data: [*c]const u8, len: usize) callconv(.c) void {
    const b = h orelse return;
    if (data == null or len == 0) return;
    if (pos < 1) return;
    const p: usize = @intCast(pos - 1);
    if (p > b.data.items.len) return;
    b.data.insertSlice(gpa, p, data[0..len]) catch {};
}

pub fn stz_bytes_remove(h: ?*Bytes, pos: c_int, count: c_int) callconv(.c) void {
    const b = h orelse return;
    if (pos < 1) return;
    const p: usize = @intCast(pos - 1);
    const c: usize = @intCast(count);
    if (p >= b.data.items.len) return;
    const end = @min(p + c, b.data.items.len);
    const to_remove = end - p;
    var i: usize = 0;
    while (i < to_remove) : (i += 1) {
        _ = b.data.orderedRemove(p);
    }
}

pub fn stz_bytes_left(h: ?*Bytes, n: c_int, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    const b = h orelse return 0;
    const count = @min(@as(usize, @intCast(n)), b.data.items.len);
    if (count > buf_len) return 0;
    @memcpy(buf[0..count], b.data.items[0..count]);
    return count;
}

pub fn stz_bytes_right(h: ?*Bytes, n: c_int, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    const b = h orelse return 0;
    const count = @min(@as(usize, @intCast(n)), b.data.items.len);
    if (count > buf_len) return 0;
    const start = b.data.items.len - count;
    @memcpy(buf[0..count], b.data.items[start..]);
    return count;
}

pub fn stz_bytes_mid(h: ?*Bytes, pos: c_int, count: c_int, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    const b = h orelse return 0;
    if (pos < 1) return 0;
    const p: usize = @intCast(pos - 1);
    const c: usize = @intCast(count);
    if (p >= b.data.items.len) return 0;
    const end = @min(p + c, b.data.items.len);
    const len = end - p;
    if (len > buf_len) return 0;
    @memcpy(buf[0..len], b.data.items[p..end]);
    return len;
}

pub fn stz_bytes_fill(h: ?*Bytes, val: u8, count: c_int) callconv(.c) void {
    const b = h orelse return;
    b.data.clearRetainingCapacity();
    const n: usize = @intCast(count);
    b.data.appendNTimes(gpa, val, n) catch {};
}

pub fn stz_bytes_replace(h: ?*Bytes, pos: c_int, count: c_int, data: [*c]const u8, data_len: usize) callconv(.c) void {
    const b = h orelse return;
    if (pos < 1) return;
    const p: usize = @intCast(pos - 1);
    const c: usize = @intCast(count);
    if (p >= b.data.items.len) return;
    const end = @min(p + c, b.data.items.len);
    var i: usize = 0;
    while (i < end - p) : (i += 1) {
        _ = b.data.orderedRemove(p);
    }
    if (data != null and data_len > 0) {
        b.data.insertSlice(gpa, p, data[0..data_len]) catch {};
    }
}

pub fn stz_bytes_resize(h: ?*Bytes, n: c_int) callconv(.c) void {
    const b = h orelse return;
    const new_len: usize = @intCast(n);
    if (new_len > b.data.items.len) {
        b.data.appendNTimes(gpa, 0, new_len - b.data.items.len) catch {};
    } else {
        b.data.shrinkRetainingCapacity(new_len);
    }
}

pub fn stz_bytes_to_lower(h: ?*Bytes, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    const b = h orelse return 0;
    if (b.data.items.len > buf_len) return 0;
    for (b.data.items, 0..) |c, i| {
        buf[i] = if (c >= 'A' and c <= 'Z') c + 32 else c;
    }
    return b.data.items.len;
}

pub fn stz_bytes_to_upper(h: ?*Bytes, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    const b = h orelse return 0;
    if (b.data.items.len > buf_len) return 0;
    for (b.data.items, 0..) |c, i| {
        buf[i] = if (c >= 'a' and c <= 'z') c - 32 else c;
    }
    return b.data.items.len;
}

// ─── Base64 ───

pub fn stz_bytes_to_base64(h: ?*Bytes, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    const b = h orelse return 0;
    const encoder = base64.standard.Encoder;
    const needed = encoder.calcSize(b.data.items.len);
    if (needed > buf_len) return 0;
    const result = encoder.encode(buf[0..needed], b.data.items);
    _ = result;
    return needed;
}

pub fn stz_bytes_from_base64(h: ?*Bytes, encoded: [*c]const u8, encoded_len: usize) callconv(.c) c_int {
    const b = h orelse return 0;
    if (encoded == null or encoded_len == 0) return 0;
    const decoder = base64.standard.Decoder;
    const src = encoded[0..encoded_len];
    const exact_len = decoder.calcSizeForSlice(src) catch return 0;
    const tmp = gpa.alloc(u8, exact_len) catch return 0;
    defer gpa.free(tmp);
    decoder.decode(tmp, src) catch return 0;
    b.data.clearRetainingCapacity();
    b.data.appendSlice(gpa, tmp) catch return 0;
    return 1;
}

// ─── Hex ───

pub fn stz_bytes_to_hex(h: ?*Bytes, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    const b = h orelse return 0;
    const needed = b.data.items.len * 2;
    if (needed > buf_len) return 0;
    const hex_chars = "0123456789abcdef";
    for (b.data.items, 0..) |byte, i| {
        buf[i * 2] = hex_chars[byte >> 4];
        buf[i * 2 + 1] = hex_chars[byte & 0x0f];
    }
    return needed;
}

pub fn stz_bytes_from_hex(h: ?*Bytes, hex: [*c]const u8, hex_len: usize) callconv(.c) c_int {
    const b = h orelse return 0;
    if (hex == null or hex_len == 0 or hex_len % 2 != 0) return 0;
    b.data.clearRetainingCapacity();
    var i: usize = 0;
    while (i < hex_len) : (i += 2) {
        const hi = hexVal(hex[i]) orelse return 0;
        const lo = hexVal(hex[i + 1]) orelse return 0;
        b.data.append(gpa, (@as(u8, hi) << 4) | @as(u8, lo)) catch return 0;
    }
    return 1;
}

fn hexVal(c: u8) ?u4 {
    if (c >= '0' and c <= '9') return @intCast(c - '0');
    if (c >= 'a' and c <= 'f') return @intCast(c - 'a' + 10);
    if (c >= 'A' and c <= 'F') return @intCast(c - 'A' + 10);
    return null;
}

// ─── Percent Encoding ───

pub fn stz_bytes_to_percent(h: ?*Bytes, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    const b = h orelse return 0;
    var out: usize = 0;
    const hex_chars = "0123456789ABCDEF";
    for (b.data.items) |c| {
        if (isUnreserved(c)) {
            if (out >= buf_len) return 0;
            buf[out] = c;
            out += 1;
        } else {
            if (out + 3 > buf_len) return 0;
            buf[out] = '%';
            buf[out + 1] = hex_chars[c >> 4];
            buf[out + 2] = hex_chars[c & 0x0f];
            out += 3;
        }
    }
    return out;
}

pub fn stz_bytes_from_percent(h: ?*Bytes, encoded: [*c]const u8, encoded_len: usize) callconv(.c) c_int {
    const b = h orelse return 0;
    if (encoded == null) return 0;
    b.data.clearRetainingCapacity();
    var i: usize = 0;
    while (i < encoded_len) {
        if (encoded[i] == '%' and i + 2 < encoded_len) {
            const hi = hexVal(encoded[i + 1]) orelse { b.data.append(gpa, encoded[i]) catch return 0; i += 1; continue; };
            const lo = hexVal(encoded[i + 2]) orelse { b.data.append(gpa, encoded[i]) catch return 0; i += 1; continue; };
            b.data.append(gpa, (@as(u8, hi) << 4) | @as(u8, lo)) catch return 0;
            i += 3;
        } else {
            b.data.append(gpa, encoded[i]) catch return 0;
            i += 1;
        }
    }
    return 1;
}

fn isUnreserved(c: u8) bool {
    return (c >= 'A' and c <= 'Z') or (c >= 'a' and c <= 'z') or (c >= '0' and c <= '9') or c == '-' or c == '_' or c == '.' or c == '~';
}

// ─── Tests ───

test "bytes lifecycle" {
    const b = stz_bytes_from("hello", 5) orelse return error.NullBytes;
    defer stz_bytes_free(b);
    try std.testing.expectEqual(@as(c_int, 5), stz_bytes_size(b));
    try std.testing.expectEqual(@as(c_int, 'h'), stz_bytes_at(b, 1));
}

test "base64 round-trip" {
    const b = stz_bytes_from("Hello World", 11) orelse return error.NullBytes;
    defer stz_bytes_free(b);
    var buf: [64]u8 = undefined;
    const enc_len = stz_bytes_to_base64(b, &buf, 64);
    try std.testing.expect(enc_len > 0);
    try std.testing.expect(mem.eql(u8, buf[0..enc_len], "SGVsbG8gV29ybGQ="));

    const b2 = stz_bytes_new() orelse return error.NullBytes;
    defer stz_bytes_free(b2);
    try std.testing.expectEqual(@as(c_int, 1), stz_bytes_from_base64(b2, &buf, enc_len));
    try std.testing.expectEqual(@as(c_int, 11), stz_bytes_size(b2));
}

test "hex round-trip" {
    const b = stz_bytes_from("AB", 2) orelse return error.NullBytes;
    defer stz_bytes_free(b);
    var buf: [64]u8 = undefined;
    const hex_len = stz_bytes_to_hex(b, &buf, 64);
    try std.testing.expect(mem.eql(u8, buf[0..hex_len], "4142"));

    const b2 = stz_bytes_new() orelse return error.NullBytes;
    defer stz_bytes_free(b2);
    try std.testing.expectEqual(@as(c_int, 1), stz_bytes_from_hex(b2, &buf, hex_len));
    try std.testing.expectEqual(@as(c_int, 2), stz_bytes_size(b2));
}
