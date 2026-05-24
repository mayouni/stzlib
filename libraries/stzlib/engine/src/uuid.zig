const std = @import("std");

pub fn uuid_v4(out: [*]u8) callconv(.c) i32 {
    var bytes: [16]u8 = undefined;
    std.crypto.random.bytes(&bytes);
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    const hex = "0123456789abcdef";
    var pos: usize = 0;
    for (0..16) |i| {
        if (i == 4 or i == 6 or i == 8 or i == 10) {
            out[pos] = '-';
            pos += 1;
        }
        out[pos] = hex[bytes[i] >> 4];
        out[pos + 1] = hex[bytes[i] & 0x0f];
        pos += 2;
    }
    return 36;
}

pub fn uuid_v4_compact(out: [*]u8) callconv(.c) i32 {
    var bytes: [16]u8 = undefined;
    std.crypto.random.bytes(&bytes);
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    const hex = "0123456789abcdef";
    for (0..16) |i| {
        out[i * 2] = hex[bytes[i] >> 4];
        out[i * 2 + 1] = hex[bytes[i] & 0x0f];
    }
    return 32;
}

pub fn uuid_is_valid(ptr: [*]const u8, len: usize) callconv(.c) i32 {
    if (len != 36) return 0;
    const data = ptr[0..36];
    const hex_chars = "0123456789abcdefABCDEF";
    for (0..36) |i| {
        if (i == 8 or i == 13 or i == 18 or i == 23) {
            if (data[i] != '-') return 0;
        } else {
            var found = false;
            for (hex_chars) |h| {
                if (data[i] == h) { found = true; break; }
            }
            if (!found) return 0;
        }
    }
    if (data[14] != '4') return 0;
    const variant = data[19];
    if (variant != '8' and variant != '9' and variant != 'a' and variant != 'b' and
        variant != 'A' and variant != 'B') return 0;
    return 1;
}

pub fn uuid_version(ptr: [*]const u8, len: usize) callconv(.c) i32 {
    if (len < 15) return -1;
    const ch = ptr[14];
    if (ch >= '0' and ch <= '9') return ch - '0';
    return -1;
}

pub fn uuid_nil(out: [*]u8) callconv(.c) i32 {
    const nil = "00000000-0000-0000-0000-000000000000";
    @memcpy(out[0..36], nil);
    return 36;
}

pub fn uuid_compare(a_ptr: [*]const u8, a_len: usize, b_ptr: [*]const u8, b_len: usize) callconv(.c) i32 {
    if (a_len != 36 or b_len != 36) return -2;
    const a = a_ptr[0..36];
    const b = b_ptr[0..36];
    for (0..36) |i| {
        const ca = if (a[i] >= 'A' and a[i] <= 'F') a[i] + 32 else a[i];
        const cb = if (b[i] >= 'A' and b[i] <= 'F') b[i] + 32 else b[i];
        if (ca < cb) return -1;
        if (ca > cb) return 1;
    }
    return 0;
}

pub export fn stz_uuid_v4(out: [*]u8) callconv(.c) i32 { return uuid_v4(out); }
pub export fn stz_uuid_v4_compact(out: [*]u8) callconv(.c) i32 { return uuid_v4_compact(out); }
pub export fn stz_uuid_is_valid(p: [*]const u8, l: usize) callconv(.c) i32 { return uuid_is_valid(p, l); }
pub export fn stz_uuid_version(p: [*]const u8, l: usize) callconv(.c) i32 { return uuid_version(p, l); }
pub export fn stz_uuid_nil(out: [*]u8) callconv(.c) i32 { return uuid_nil(out); }
pub export fn stz_uuid_compare(a: [*]const u8, al: usize, b: [*]const u8, bl: usize) callconv(.c) i32 { return uuid_compare(a, al, b, bl); }

// ── Tests ──────────────────────────────────────────────────────

test "uuid: v4 format" {
    var buf: [36]u8 = undefined;
    const len = uuid_v4(&buf);
    try std.testing.expectEqual(@as(i32, 36), len);
    try std.testing.expectEqual(@as(u8, '-'), buf[8]);
    try std.testing.expectEqual(@as(u8, '-'), buf[13]);
    try std.testing.expectEqual(@as(u8, '-'), buf[18]);
    try std.testing.expectEqual(@as(u8, '-'), buf[23]);
    try std.testing.expectEqual(@as(u8, '4'), buf[14]);
}

test "uuid: v4 valid" {
    var buf: [36]u8 = undefined;
    _ = uuid_v4(&buf);
    try std.testing.expectEqual(@as(i32, 1), uuid_is_valid(&buf, 36));
}

test "uuid: v4 compact length" {
    var buf: [32]u8 = undefined;
    const len = uuid_v4_compact(&buf);
    try std.testing.expectEqual(@as(i32, 32), len);
}

test "uuid: nil" {
    var buf: [36]u8 = undefined;
    _ = uuid_nil(&buf);
    try std.testing.expectEqualStrings("00000000-0000-0000-0000-000000000000", buf[0..36]);
}

test "uuid: invalid" {
    const bad = "not-a-uuid-at-all-definitely-not-36";
    try std.testing.expectEqual(@as(i32, 0), uuid_is_valid(bad.ptr, bad.len));
}

test "uuid: version" {
    var buf: [36]u8 = undefined;
    _ = uuid_v4(&buf);
    try std.testing.expectEqual(@as(i32, 4), uuid_version(&buf, 36));
}

test "uuid: compare equal" {
    const a = "550e8400-e29b-41d4-a716-446655440000";
    try std.testing.expectEqual(@as(i32, 0), uuid_compare(a.ptr, 36, a.ptr, 36));
}

test "uuid: compare case insensitive" {
    const a = "550e8400-e29b-41d4-a716-446655440000";
    const b = "550E8400-E29B-41D4-A716-446655440000";
    try std.testing.expectEqual(@as(i32, 0), uuid_compare(a.ptr, 36, b.ptr, 36));
}

test "uuid: uniqueness" {
    var a: [36]u8 = undefined;
    var b: [36]u8 = undefined;
    _ = uuid_v4(&a);
    _ = uuid_v4(&b);
    try std.testing.expect(!std.mem.eql(u8, &a, &b));
}
