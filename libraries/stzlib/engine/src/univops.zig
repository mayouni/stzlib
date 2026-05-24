const std = @import("std");

// ── Universal Operations ────────────────────────────────────
// Type-agnostic operations: deepequal, deepcopy, typeof, sizeof,
// swap, compare, hash, stringify.

const TypeTag = enum(i32) {
    null_type = 0,
    bool_type = 1,
    int_type = 2,
    float_type = 3,
    string_type = 4,
    list_type = 5,
    object_type = 6,
    unknown_type = -1,
};

pub fn type_from_tag(tag: i32) callconv(.c) i32 { return tag; }

pub fn type_name(tag: i32, out: [*]u8) callconv(.c) i32 {
    const name = switch (@as(TypeTag, @enumFromInt(tag))) {
        .null_type => "null",
        .bool_type => "bool",
        .int_type => "int",
        .float_type => "float",
        .string_type => "string",
        .list_type => "list",
        .object_type => "object",
        .unknown_type => "unknown",
    };
    @memcpy(out[0..name.len], name);
    return @intCast(name.len);
}

pub fn type_is_numeric(tag: i32) callconv(.c) i32 {
    return if (tag == 2 or tag == 3) 1 else 0;
}

pub fn type_is_collection(tag: i32) callconv(.c) i32 {
    return if (tag == 5 or tag == 6) 1 else 0;
}

pub fn type_is_scalar(tag: i32) callconv(.c) i32 {
    return if (tag >= 0 and tag <= 4) 1 else 0;
}

pub fn bytes_equal(a_ptr: [*]const u8, b_ptr: [*]const u8, len: usize) callconv(.c) i32 {
    if (len == 0) return 1;
    return if (std.mem.eql(u8, a_ptr[0..len], b_ptr[0..len])) 1 else 0;
}

pub fn bytes_compare(a_ptr: [*]const u8, a_len: usize, b_ptr: [*]const u8, b_len: usize) callconv(.c) i32 {
    const min_len = @min(a_len, b_len);
    const a = a_ptr[0..min_len];
    const b = b_ptr[0..min_len];
    for (0..min_len) |i| {
        if (a[i] < b[i]) return -1;
        if (a[i] > b[i]) return 1;
    }
    if (a_len < b_len) return -1;
    if (a_len > b_len) return 1;
    return 0;
}

pub fn bytes_swap(a_ptr: [*]u8, b_ptr: [*]u8, len: usize) callconv(.c) void {
    for (0..len) |i| {
        const tmp = a_ptr[i];
        a_ptr[i] = b_ptr[i];
        b_ptr[i] = tmp;
    }
}

pub fn bytes_fill(ptr: [*]u8, len: usize, val: u8) callconv(.c) void {
    @memset(ptr[0..len], val);
}

pub fn bytes_hash_fnv(ptr: [*]const u8, len: usize) callconv(.c) u64 {
    if (len == 0) return 0xcbf29ce484222325;
    return std.hash.Fnv1a_64.hash(ptr[0..len]);
}

pub fn int_min(a: i64, b: i64) callconv(.c) i64 { return @min(a, b); }
pub fn int_max(a: i64, b: i64) callconv(.c) i64 { return @max(a, b); }
pub fn int_clamp(val: i64, lo: i64, hi: i64) callconv(.c) i64 { return @min(@max(val, lo), hi); }
pub fn int_abs(n: i64) callconv(.c) i64 { return if (n < 0) -n else n; }
pub fn int_sign(n: i64) callconv(.c) i32 {
    if (n < 0) return -1;
    if (n > 0) return 1;
    return 0;
}
pub fn int_in_range(n: i64, lo: i64, hi: i64) callconv(.c) i32 {
    return if (n >= lo and n <= hi) 1 else 0;
}

// ── C ABI exports ────────────────────────────────────────────

pub export fn stz_univops_type_name(t: i32, o: [*]u8) callconv(.c) i32 { return type_name(t, o); }
pub export fn stz_univops_type_is_numeric(t: i32) callconv(.c) i32 { return type_is_numeric(t); }
pub export fn stz_univops_type_is_collection(t: i32) callconv(.c) i32 { return type_is_collection(t); }
pub export fn stz_univops_type_is_scalar(t: i32) callconv(.c) i32 { return type_is_scalar(t); }
pub export fn stz_univops_bytes_equal(a: [*]const u8, b: [*]const u8, l: usize) callconv(.c) i32 { return bytes_equal(a, b, l); }
pub export fn stz_univops_bytes_compare(a: [*]const u8, al: usize, b: [*]const u8, bl: usize) callconv(.c) i32 { return bytes_compare(a, al, b, bl); }
pub export fn stz_univops_bytes_swap(a: [*]u8, b: [*]u8, l: usize) callconv(.c) void { bytes_swap(a, b, l); }
pub export fn stz_univops_bytes_fill(p: [*]u8, l: usize, v: u8) callconv(.c) void { bytes_fill(p, l, v); }
pub export fn stz_univops_bytes_hash(p: [*]const u8, l: usize) callconv(.c) u64 { return bytes_hash_fnv(p, l); }
pub export fn stz_univops_int_min(a: i64, b: i64) callconv(.c) i64 { return int_min(a, b); }
pub export fn stz_univops_int_max(a: i64, b: i64) callconv(.c) i64 { return int_max(a, b); }
pub export fn stz_univops_int_clamp(v: i64, lo: i64, hi: i64) callconv(.c) i64 { return int_clamp(v, lo, hi); }
pub export fn stz_univops_int_abs(n: i64) callconv(.c) i64 { return int_abs(n); }
pub export fn stz_univops_int_sign(n: i64) callconv(.c) i32 { return int_sign(n); }
pub export fn stz_univops_int_in_range(n: i64, lo: i64, hi: i64) callconv(.c) i32 { return int_in_range(n, lo, hi); }

// ── Tests ────────────────────────────────────────────────────

test "univops: type_name" {
    var buf: [16]u8 = undefined;
    const len = type_name(2, &buf);
    try std.testing.expectEqualStrings("int", buf[0..@intCast(len)]);
    const len2 = type_name(4, &buf);
    try std.testing.expectEqualStrings("string", buf[0..@intCast(len2)]);
}

test "univops: type predicates" {
    try std.testing.expectEqual(@as(i32, 1), type_is_numeric(2));
    try std.testing.expectEqual(@as(i32, 1), type_is_numeric(3));
    try std.testing.expectEqual(@as(i32, 0), type_is_numeric(4));
    try std.testing.expectEqual(@as(i32, 1), type_is_collection(5));
    try std.testing.expectEqual(@as(i32, 0), type_is_collection(2));
    try std.testing.expectEqual(@as(i32, 1), type_is_scalar(0));
    try std.testing.expectEqual(@as(i32, 0), type_is_scalar(5));
}

test "univops: bytes_equal" {
    try std.testing.expectEqual(@as(i32, 1), bytes_equal("abc".ptr, "abc".ptr, 3));
    try std.testing.expectEqual(@as(i32, 0), bytes_equal("abc".ptr, "abd".ptr, 3));
    try std.testing.expectEqual(@as(i32, 1), bytes_equal("".ptr, "".ptr, 0));
}

test "univops: bytes_compare" {
    try std.testing.expectEqual(@as(i32, -1), bytes_compare("abc".ptr, 3, "abd".ptr, 3));
    try std.testing.expectEqual(@as(i32, 1), bytes_compare("abd".ptr, 3, "abc".ptr, 3));
    try std.testing.expectEqual(@as(i32, 0), bytes_compare("abc".ptr, 3, "abc".ptr, 3));
    try std.testing.expectEqual(@as(i32, -1), bytes_compare("ab".ptr, 2, "abc".ptr, 3));
}

test "univops: bytes_swap" {
    var a = [_]u8{ 1, 2, 3 };
    var b = [_]u8{ 4, 5, 6 };
    bytes_swap(&a, &b, 3);
    try std.testing.expectEqual([_]u8{ 4, 5, 6 }, a);
    try std.testing.expectEqual([_]u8{ 1, 2, 3 }, b);
}

test "univops: bytes_fill" {
    var buf = [_]u8{ 0, 0, 0, 0 };
    bytes_fill(&buf, 4, 0xAA);
    try std.testing.expectEqual([_]u8{ 0xAA, 0xAA, 0xAA, 0xAA }, buf);
}

test "univops: int operations" {
    try std.testing.expectEqual(@as(i64, 3), int_min(3, 7));
    try std.testing.expectEqual(@as(i64, 7), int_max(3, 7));
    try std.testing.expectEqual(@as(i64, 5), int_clamp(3, 5, 10));
    try std.testing.expectEqual(@as(i64, 5), int_clamp(15, 0, 5));
    try std.testing.expectEqual(@as(i64, 7), int_abs(-7));
    try std.testing.expectEqual(@as(i32, -1), int_sign(-5));
    try std.testing.expectEqual(@as(i32, 1), int_sign(5));
    try std.testing.expectEqual(@as(i32, 0), int_sign(0));
    try std.testing.expectEqual(@as(i32, 1), int_in_range(5, 1, 10));
    try std.testing.expectEqual(@as(i32, 0), int_in_range(15, 1, 10));
}
