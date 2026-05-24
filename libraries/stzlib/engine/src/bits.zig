const std = @import("std");

// ── Bit Queries ──────────────────────────────────────────────

pub fn bits_popcount(val: u64) callconv(.c) u32 {
    return @popCount(val);
}

pub fn bits_leading_zeros(val: u64) callconv(.c) u32 {
    return @clz(val);
}

pub fn bits_trailing_zeros(val: u64) callconv(.c) u32 {
    return @ctz(val);
}

pub fn bits_parity(val: u64) callconv(.c) u32 {
    return @popCount(val) % 2;
}

pub fn bits_test(val: u64, bit: u32) callconv(.c) i32 {
    if (bit >= 64) return -1;
    const mask = @as(u64, 1) << @intCast(bit);
    return if (val & mask != 0) 1 else 0;
}

pub fn bits_highest_set(val: u64) callconv(.c) i32 {
    if (val == 0) return -1;
    return @intCast(63 - @as(u32, @clz(val)));
}

pub fn bits_lowest_set(val: u64) callconv(.c) i32 {
    if (val == 0) return -1;
    return @intCast(@as(u32, @ctz(val)));
}

// ── Bit Manipulation ─────────────────────────────────────────

pub fn bits_set(val: u64, bit: u32) callconv(.c) u64 {
    if (bit >= 64) return val;
    return val | (@as(u64, 1) << @intCast(bit));
}

pub fn bits_clear(val: u64, bit: u32) callconv(.c) u64 {
    if (bit >= 64) return val;
    return val & ~(@as(u64, 1) << @intCast(bit));
}

pub fn bits_toggle(val: u64, bit: u32) callconv(.c) u64 {
    if (bit >= 64) return val;
    return val ^ (@as(u64, 1) << @intCast(bit));
}

pub fn bits_rotate_left(val: u64, amount: u32) callconv(.c) u64 {
    const a: u6 = @intCast(amount % 64);
    return std.math.rotl(u64, val, a);
}

pub fn bits_rotate_right(val: u64, amount: u32) callconv(.c) u64 {
    const a: u6 = @intCast(amount % 64);
    return std.math.rotr(u64, val, a);
}

pub fn bits_reverse(val: u64) callconv(.c) u64 {
    return @bitReverse(val);
}

pub fn bits_byte_swap(val: u64) callconv(.c) u64 {
    return @byteSwap(val);
}

// ── Bit Extract/Deposit ──────────────────────────────────────

pub fn bits_extract(val: u64, start: u32, count: u32) callconv(.c) u64 {
    if (start >= 64 or count == 0) return 0;
    const actual_count = @min(count, 64 - start);
    const mask = if (actual_count >= 64) ~@as(u64, 0) else (@as(u64, 1) << @intCast(actual_count)) - 1;
    return (val >> @intCast(start)) & mask;
}

pub fn bits_deposit(val: u64, bits_val: u64, start: u32, count: u32) callconv(.c) u64 {
    if (start >= 64 or count == 0) return val;
    const actual_count = @min(count, 64 - start);
    const mask = if (actual_count >= 64) ~@as(u64, 0) else (@as(u64, 1) << @intCast(actual_count)) - 1;
    const cleared = val & ~(mask << @intCast(start));
    return cleared | ((bits_val & mask) << @intCast(start));
}

// ── Byte-Level Ops ───────────────────────────────────────────

pub fn bits_count_ones_in_bytes(ptr: [*]const u8, len: usize) callconv(.c) u32 {
    if (len == 0) return 0;
    var count: u32 = 0;
    for (ptr[0..len]) |b| {
        count += @popCount(b);
    }
    return count;
}

pub fn bits_hamming_distance(a_ptr: [*]const u8, a_len: usize, b_ptr: [*]const u8, b_len: usize) callconv(.c) i32 {
    if (a_len != b_len) return -1;
    if (a_len == 0) return 0;
    var dist: u32 = 0;
    for (0..a_len) |i| {
        dist += @popCount(a_ptr[i] ^ b_ptr[i]);
    }
    return @intCast(dist);
}

// ── String Representation ────────────────────────────────────

pub fn bits_to_binary_string(val: u64, out: [*]u8, max: usize) callconv(.c) i32 {
    if (max < 64) return -1;
    for (0..64) |i| {
        const bit_pos: u6 = @intCast(63 - i);
        out[i] = if (val & (@as(u64, 1) << bit_pos) != 0) '1' else '0';
    }
    return 64;
}

pub fn bits_from_binary_string(ptr: [*]const u8, len: usize) callconv(.c) u64 {
    if (len == 0) return 0;
    var result: u64 = 0;
    const actual = @min(len, 64);
    for (0..actual) |i| {
        if (ptr[i] == '1') {
            const shift: u6 = @intCast(actual - 1 - i);
            result |= @as(u64, 1) << shift;
        }
    }
    return result;
}

// ── C ABI exports ────────────────────────────────────────────

pub export fn stz_bits_popcount(v: u64) callconv(.c) u32 { return bits_popcount(v); }
pub export fn stz_bits_leading_zeros(v: u64) callconv(.c) u32 { return bits_leading_zeros(v); }
pub export fn stz_bits_trailing_zeros(v: u64) callconv(.c) u32 { return bits_trailing_zeros(v); }
pub export fn stz_bits_parity(v: u64) callconv(.c) u32 { return bits_parity(v); }
pub export fn stz_bits_test(v: u64, b: u32) callconv(.c) i32 { return bits_test(v, b); }
pub export fn stz_bits_highest_set(v: u64) callconv(.c) i32 { return bits_highest_set(v); }
pub export fn stz_bits_lowest_set(v: u64) callconv(.c) i32 { return bits_lowest_set(v); }
pub export fn stz_bits_set(v: u64, b: u32) callconv(.c) u64 { return bits_set(v, b); }
pub export fn stz_bits_clear(v: u64, b: u32) callconv(.c) u64 { return bits_clear(v, b); }
pub export fn stz_bits_toggle(v: u64, b: u32) callconv(.c) u64 { return bits_toggle(v, b); }
pub export fn stz_bits_rotate_left(v: u64, a: u32) callconv(.c) u64 { return bits_rotate_left(v, a); }
pub export fn stz_bits_rotate_right(v: u64, a: u32) callconv(.c) u64 { return bits_rotate_right(v, a); }
pub export fn stz_bits_reverse(v: u64) callconv(.c) u64 { return bits_reverse(v); }
pub export fn stz_bits_byte_swap(v: u64) callconv(.c) u64 { return bits_byte_swap(v); }
pub export fn stz_bits_extract(v: u64, s: u32, c: u32) callconv(.c) u64 { return bits_extract(v, s, c); }
pub export fn stz_bits_deposit(v: u64, bv: u64, s: u32, c: u32) callconv(.c) u64 { return bits_deposit(v, bv, s, c); }
pub export fn stz_bits_count_ones_in_bytes(p: [*]const u8, l: usize) callconv(.c) u32 { return bits_count_ones_in_bytes(p, l); }
pub export fn stz_bits_hamming_distance(a: [*]const u8, al: usize, b: [*]const u8, bl: usize) callconv(.c) i32 { return bits_hamming_distance(a, al, b, bl); }
pub export fn stz_bits_to_binary_string(v: u64, o: [*]u8, m: usize) callconv(.c) i32 { return bits_to_binary_string(v, o, m); }
pub export fn stz_bits_from_binary_string(p: [*]const u8, l: usize) callconv(.c) u64 { return bits_from_binary_string(p, l); }

// ── Tests ────────────────────────────────────────────────────

test "bits: popcount" {
    try std.testing.expectEqual(@as(u32, 0), bits_popcount(0));
    try std.testing.expectEqual(@as(u32, 1), bits_popcount(1));
    try std.testing.expectEqual(@as(u32, 64), bits_popcount(~@as(u64, 0)));
    try std.testing.expectEqual(@as(u32, 3), bits_popcount(0b1011));
}

test "bits: leading/trailing zeros" {
    try std.testing.expectEqual(@as(u32, 64), bits_leading_zeros(0));
    try std.testing.expectEqual(@as(u32, 63), bits_leading_zeros(1));
    try std.testing.expectEqual(@as(u32, 0), bits_trailing_zeros(1));
    try std.testing.expectEqual(@as(u32, 3), bits_trailing_zeros(8));
}

test "bits: parity" {
    try std.testing.expectEqual(@as(u32, 0), bits_parity(0));
    try std.testing.expectEqual(@as(u32, 1), bits_parity(1));
    try std.testing.expectEqual(@as(u32, 0), bits_parity(3));
    try std.testing.expectEqual(@as(u32, 1), bits_parity(7));
}

test "bits: test/highest/lowest" {
    try std.testing.expectEqual(@as(i32, 1), bits_test(0b1010, 1));
    try std.testing.expectEqual(@as(i32, 0), bits_test(0b1010, 0));
    try std.testing.expectEqual(@as(i32, -1), bits_test(0, 64));
    try std.testing.expectEqual(@as(i32, 3), bits_highest_set(0b1010));
    try std.testing.expectEqual(@as(i32, 1), bits_lowest_set(0b1010));
    try std.testing.expectEqual(@as(i32, -1), bits_highest_set(0));
}

test "bits: set/clear/toggle" {
    try std.testing.expectEqual(@as(u64, 0b1011), bits_set(0b1001, 1));
    try std.testing.expectEqual(@as(u64, 0b1000), bits_clear(0b1010, 1));
    try std.testing.expectEqual(@as(u64, 0b1000), bits_toggle(0b1010, 1));
    try std.testing.expectEqual(@as(u64, 0b1011), bits_toggle(0b1001, 1));
}

test "bits: rotate" {
    const v: u64 = 1;
    try std.testing.expectEqual(@as(u64, 4), bits_rotate_left(v, 2));
    const v2: u64 = 4;
    try std.testing.expectEqual(@as(u64, 1), bits_rotate_right(v2, 2));
}

test "bits: reverse and byte_swap" {
    const v: u64 = 1;
    const rev = bits_reverse(v);
    try std.testing.expectEqual(@as(u64, 1) << 63, rev);

    const v2: u64 = 0x0102030405060708;
    const swapped = bits_byte_swap(v2);
    try std.testing.expectEqual(@as(u64, 0x0807060504030201), swapped);
}

test "bits: extract/deposit" {
    try std.testing.expectEqual(@as(u64, 0b101), bits_extract(0b10100, 2, 3));
    try std.testing.expectEqual(@as(u64, 0b11100), bits_deposit(0, 0b111, 2, 3));
    try std.testing.expectEqual(@as(u64, 0), bits_extract(0xFF, 64, 1));
}

test "bits: count_ones_in_bytes" {
    const data = [_]u8{ 0xFF, 0x00, 0x0F };
    try std.testing.expectEqual(@as(u32, 12), bits_count_ones_in_bytes(&data, 3));
}

test "bits: hamming_distance" {
    const a = [_]u8{ 0xFF, 0x00 };
    const b = [_]u8{ 0x00, 0xFF };
    try std.testing.expectEqual(@as(i32, 16), bits_hamming_distance(&a, 2, &b, 2));

    const c = [_]u8{0xFF};
    try std.testing.expectEqual(@as(i32, -1), bits_hamming_distance(&a, 2, &c, 1));
}

test "bits: binary string roundtrip" {
    var buf: [64]u8 = undefined;
    const val: u64 = 42;
    const len = bits_to_binary_string(val, &buf, 64);
    try std.testing.expectEqual(@as(i32, 64), len);
    const back = bits_from_binary_string(&buf, @intCast(len));
    try std.testing.expectEqual(val, back);
}
