// Softanza Engine -- StzNumber: extended numeric operations
//
// Provides: big integer arithmetic (arbitrary precision via Zig's std.math.big),
// decimal formatting, base conversion, numeric predicates.
// Ring's native numbers are f64; this module adds precision beyond 15 digits
// and integer-exact arithmetic for financial/scientific use.
//
// C ABI: stz_number_* prefix. Handles are opaque pointers.

const std = @import("std");
const allocator = std.heap.c_allocator;
const big = std.math.big;

// ─── BigInt Handle ───

pub const StzBigInt = struct {
    value: big.int.Managed,

    pub fn init() !*StzBigInt {
        const self = try allocator.create(StzBigInt);
        self.value = big.int.Managed.init(allocator) catch {
            allocator.destroy(self);
            return error.OutOfMemory;
        };
        return self;
    }

    pub fn deinit(self: *StzBigInt) void {
        self.value.deinit();
        allocator.destroy(self);
    }
};

// ─── C ABI: BigInt Lifecycle ───

pub fn stz_bigint_new() callconv(.c) ?*StzBigInt {
    return StzBigInt.init() catch null;
}

pub fn stz_bigint_from_int(n: i64) callconv(.c) ?*StzBigInt {
    const bi = StzBigInt.init() catch return null;
    bi.value.set(n) catch {
        bi.deinit();
        return null;
    };
    return bi;
}

pub fn stz_bigint_from_string(ptr: [*]const u8, len: usize) callconv(.c) ?*StzBigInt {
    if (len == 0) return null;
    const bi = StzBigInt.init() catch return null;
    const str = ptr[0..len];

    bi.value.setString(10, str) catch {
        bi.deinit();
        return null;
    };
    return bi;
}

pub fn stz_bigint_free(bi: ?*StzBigInt) callconv(.c) void {
    const b = bi orelse return;
    b.deinit();
}

// ─── C ABI: BigInt Arithmetic ───

pub fn stz_bigint_add(a: ?*const StzBigInt, b: ?*const StzBigInt) callconv(.c) ?*StzBigInt {
    const va = a orelse return null;
    const vb = b orelse return null;
    const result = StzBigInt.init() catch return null;
    result.value.add(&va.value, &vb.value) catch {
        result.deinit();
        return null;
    };
    return result;
}

pub fn stz_bigint_sub(a: ?*const StzBigInt, b: ?*const StzBigInt) callconv(.c) ?*StzBigInt {
    const va = a orelse return null;
    const vb = b orelse return null;
    const result = StzBigInt.init() catch return null;
    result.value.sub(&va.value, &vb.value) catch {
        result.deinit();
        return null;
    };
    return result;
}

pub fn stz_bigint_mul(a: ?*const StzBigInt, b: ?*const StzBigInt) callconv(.c) ?*StzBigInt {
    const va = a orelse return null;
    const vb = b orelse return null;
    const result = StzBigInt.init() catch return null;
    result.value.mul(&va.value, &vb.value) catch {
        result.deinit();
        return null;
    };
    return result;
}

pub fn stz_bigint_div(a: ?*const StzBigInt, b: ?*const StzBigInt) callconv(.c) ?*StzBigInt {
    const va = a orelse return null;
    const vb = b orelse return null;
    const result = StzBigInt.init() catch return null;
    var remainder = big.int.Managed.init(allocator) catch {
        result.deinit();
        return null;
    };
    defer remainder.deinit();
    result.value.divTrunc(&remainder, &va.value, &vb.value) catch {
        result.deinit();
        return null;
    };
    return result;
}

pub fn stz_bigint_mod(a: ?*const StzBigInt, b: ?*const StzBigInt) callconv(.c) ?*StzBigInt {
    const va = a orelse return null;
    const vb = b orelse return null;
    const result = StzBigInt.init() catch return null;
    var quotient = big.int.Managed.init(allocator) catch {
        result.deinit();
        return null;
    };
    defer quotient.deinit();
    quotient.divTrunc(&result.value, &va.value, &vb.value) catch {
        result.deinit();
        return null;
    };
    return result;
}

pub fn stz_bigint_negate(a: ?*const StzBigInt) callconv(.c) ?*StzBigInt {
    const va = a orelse return null;
    const result = StzBigInt.init() catch return null;
    result.value.copy(va.value.toConst()) catch {
        result.deinit();
        return null;
    };
    result.value.negate();
    return result;
}

pub fn stz_bigint_abs(a: ?*const StzBigInt) callconv(.c) ?*StzBigInt {
    const va = a orelse return null;
    const result = StzBigInt.init() catch return null;
    result.value.copy(va.value.toConst()) catch {
        result.deinit();
        return null;
    };
    result.value.setSign(true);
    return result;
}

// ─── C ABI: BigInt Comparison ───

pub fn stz_bigint_compare(a: ?*const StzBigInt, b: ?*const StzBigInt) callconv(.c) i32 {
    const va = a orelse return 0;
    const vb = b orelse return 0;
    const ord = va.value.order(vb.value);
    return switch (ord) {
        .lt => -1,
        .eq => 0,
        .gt => 1,
    };
}

pub fn stz_bigint_equals(a: ?*const StzBigInt, b: ?*const StzBigInt) callconv(.c) i32 {
    return if (stz_bigint_compare(a, b) == 0) 1 else 0;
}

pub fn stz_bigint_is_zero(a: ?*const StzBigInt) callconv(.c) i32 {
    const va = a orelse return 1;
    return if (va.value.eqlZero()) 1 else 0;
}

pub fn stz_bigint_is_negative(a: ?*const StzBigInt) callconv(.c) i32 {
    const va = a orelse return 0;
    return if (va.value.isPositive()) 0 else if (va.value.eqlZero()) 0 else 1;
}

// ─── C ABI: BigInt Conversion ───

pub fn stz_bigint_to_int(a: ?*const StzBigInt) callconv(.c) i64 {
    const va = a orelse return 0;
    return va.value.toInt(i64) catch 0;
}

pub fn stz_bigint_to_string(a: ?*const StzBigInt, buf: [*]u8, buf_len: usize) callconv(.c) usize {
    const va = a orelse return 0;
    if (buf_len == 0) return 0;
    const str = va.value.toString(allocator, 10, .lower) catch return 0;
    defer allocator.free(str);
    const copy_len = @min(str.len, buf_len);
    @memcpy(buf[0..copy_len], str[0..copy_len]);
    return copy_len;
}

pub fn stz_bigint_to_string_base(a: ?*const StzBigInt, base: u8, buf: [*]u8, buf_len: usize) callconv(.c) usize {
    const va = a orelse return 0;
    if (buf_len == 0) return 0;
    if (base < 2 or base > 36) return 0;
    const str = va.value.toString(allocator, base, .lower) catch return 0;
    defer allocator.free(str);
    const copy_len = @min(str.len, buf_len);
    @memcpy(buf[0..copy_len], str[0..copy_len]);
    return copy_len;
}

pub fn stz_bigint_clone(a: ?*const StzBigInt) callconv(.c) ?*StzBigInt {
    const va = a orelse return null;
    const result = StzBigInt.init() catch return null;
    result.value.copy(va.value.toConst()) catch {
        result.deinit();
        return null;
    };
    return result;
}

// ─── C ABI: BigInt Power ───

pub fn stz_bigint_pow(base_val: ?*const StzBigInt, exp: u32) callconv(.c) ?*StzBigInt {
    const vb = base_val orelse return null;
    const result = StzBigInt.init() catch return null;
    result.value.pow(&vb.value, exp) catch {
        result.deinit();
        return null;
    };
    return result;
}

// ─── C ABI: BigInt Bit Count ───

pub fn stz_bigint_bit_count(a: ?*const StzBigInt) callconv(.c) usize {
    const va = a orelse return 0;
    return va.value.bitCountAbs();
}

// ─── C ABI: Numeric Utilities (non-bigint) ───

pub fn stz_number_gcd(a: i64, b: i64) callconv(.c) i64 {
    var x = if (a < 0) -a else a;
    var y = if (b < 0) -b else b;
    while (y != 0) {
        const t = @mod(x, y);
        x = y;
        y = t;
    }
    return x;
}

pub fn stz_number_lcm(a: i64, b: i64) callconv(.c) i64 {
    if (a == 0 or b == 0) return 0;
    const g = stz_number_gcd(a, b);
    const abs_a = if (a < 0) -a else a;
    const abs_b = if (b < 0) -b else b;
    return @divExact(abs_a, g) * abs_b;
}

pub fn stz_number_is_prime(n: i64) callconv(.c) i32 {
    if (n < 2) return 0;
    if (n < 4) return 1;
    if (@mod(n, 2) == 0 or @mod(n, 3) == 0) return 0;
    var i: i64 = 5;
    while (i * i <= n) {
        if (@mod(n, i) == 0 or @mod(n, i + 2) == 0) return 0;
        i += 6;
    }
    return 1;
}

pub fn stz_number_factorial(n: u32) callconv(.c) ?*StzBigInt {
    const result = StzBigInt.init() catch return null;
    result.value.set(@as(i64, 1)) catch {
        result.deinit();
        return null;
    };
    if (n <= 1) return result;

    var temp = StzBigInt.init() catch {
        result.deinit();
        return null;
    };
    defer temp.deinit();

    var i: u32 = 2;
    while (i <= n) : (i += 1) {
        temp.value.set(@as(i64, @intCast(i))) catch {
            result.deinit();
            return null;
        };
        result.value.mul(&result.value, &temp.value) catch {
            result.deinit();
            return null;
        };
    }
    return result;
}

pub fn stz_number_fibonacci(n: u32) callconv(.c) ?*StzBigInt {
    const result = StzBigInt.init() catch return null;
    if (n == 0) {
        result.value.set(@as(i64, 0)) catch {
            result.deinit();
            return null;
        };
        return result;
    }
    if (n <= 2) {
        result.value.set(@as(i64, 1)) catch {
            result.deinit();
            return null;
        };
        return result;
    }

    var a = big.int.Managed.init(allocator) catch {
        result.deinit();
        return null;
    };
    defer a.deinit();
    var b = big.int.Managed.init(allocator) catch {
        result.deinit();
        return null;
    };
    defer b.deinit();

    a.set(@as(i64, 0)) catch {
        result.deinit();
        return null;
    };
    b.set(@as(i64, 1)) catch {
        result.deinit();
        return null;
    };

    var i: u32 = 2;
    while (i <= n) : (i += 1) {
        result.value.add(&a, &b) catch {
            result.deinit();
            return null;
        };
        a.copy(b.toConst()) catch {
            result.deinit();
            return null;
        };
        b.copy(result.value.toConst()) catch {
            result.deinit();
            return null;
        };
    }
    return result;
}

pub fn stz_number_is_perfect(n: i64) callconv(.c) i32 {
    if (n <= 1) return 0;
    var sum: i64 = 1;
    var i: i64 = 2;
    while (i * i <= n) {
        if (@mod(n, i) == 0) {
            sum += i;
            if (i != @divExact(n, i)) {
                sum += @divExact(n, i);
            }
        }
        i += 1;
    }
    return if (sum == n) 1 else 0;
}

pub fn stz_number_digit_count(n: i64) callconv(.c) i32 {
    var x = if (n < 0) -n else n;
    if (x == 0) return 1;
    var count: i32 = 0;
    while (x > 0) {
        x = @divTrunc(x, 10);
        count += 1;
    }
    return count;
}

pub fn stz_number_digit_sum(n: i64) callconv(.c) i64 {
    var x = if (n < 0) -n else n;
    if (x == 0) return 0;
    var sum: i64 = 0;
    while (x > 0) {
        sum += @mod(x, 10);
        x = @divTrunc(x, 10);
    }
    return sum;
}

pub fn stz_number_reverse_digits(n: i64) callconv(.c) i64 {
    const negative = n < 0;
    var x = if (negative) -n else n;
    var result: i64 = 0;
    while (x > 0) {
        result = result * 10 + @mod(x, 10);
        x = @divTrunc(x, 10);
    }
    return if (negative) -result else result;
}

pub fn stz_number_is_palindrome(n: i64) callconv(.c) i32 {
    if (n < 0) return 0;
    return if (n == stz_number_reverse_digits(n)) 1 else 0;
}

// ─── Tests ───

test "bigint from int" {
    const bi = stz_bigint_from_int(12345) orelse return error.AllocFailed;
    defer stz_bigint_free(bi);
    try std.testing.expectEqual(@as(i64, 12345), stz_bigint_to_int(bi));
}

test "bigint from string" {
    const s = "99999999999999999999";
    const bi = stz_bigint_from_string(s.ptr, s.len) orelse return error.AllocFailed;
    defer stz_bigint_free(bi);
    var buf: [64]u8 = undefined;
    const len = stz_bigint_to_string(bi, &buf, 64);
    try std.testing.expect(std.mem.eql(u8, buf[0..len], "99999999999999999999"));
}

test "bigint add" {
    const a = stz_bigint_from_int(100) orelse return error.AllocFailed;
    defer stz_bigint_free(a);
    const b = stz_bigint_from_int(200) orelse return error.AllocFailed;
    defer stz_bigint_free(b);
    const c = stz_bigint_add(a, b) orelse return error.AllocFailed;
    defer stz_bigint_free(c);
    try std.testing.expectEqual(@as(i64, 300), stz_bigint_to_int(c));
}

test "bigint sub" {
    const a = stz_bigint_from_int(500) orelse return error.AllocFailed;
    defer stz_bigint_free(a);
    const b = stz_bigint_from_int(200) orelse return error.AllocFailed;
    defer stz_bigint_free(b);
    const c = stz_bigint_sub(a, b) orelse return error.AllocFailed;
    defer stz_bigint_free(c);
    try std.testing.expectEqual(@as(i64, 300), stz_bigint_to_int(c));
}

test "bigint mul" {
    const a = stz_bigint_from_int(123) orelse return error.AllocFailed;
    defer stz_bigint_free(a);
    const b = stz_bigint_from_int(456) orelse return error.AllocFailed;
    defer stz_bigint_free(b);
    const c = stz_bigint_mul(a, b) orelse return error.AllocFailed;
    defer stz_bigint_free(c);
    try std.testing.expectEqual(@as(i64, 56088), stz_bigint_to_int(c));
}

test "bigint div" {
    const a = stz_bigint_from_int(100) orelse return error.AllocFailed;
    defer stz_bigint_free(a);
    const b = stz_bigint_from_int(7) orelse return error.AllocFailed;
    defer stz_bigint_free(b);
    const c = stz_bigint_div(a, b) orelse return error.AllocFailed;
    defer stz_bigint_free(c);
    try std.testing.expectEqual(@as(i64, 14), stz_bigint_to_int(c));
}

test "bigint mod" {
    const a = stz_bigint_from_int(100) orelse return error.AllocFailed;
    defer stz_bigint_free(a);
    const b = stz_bigint_from_int(7) orelse return error.AllocFailed;
    defer stz_bigint_free(b);
    const c = stz_bigint_mod(a, b) orelse return error.AllocFailed;
    defer stz_bigint_free(c);
    try std.testing.expectEqual(@as(i64, 2), stz_bigint_to_int(c));
}

test "bigint negate" {
    const a = stz_bigint_from_int(42) orelse return error.AllocFailed;
    defer stz_bigint_free(a);
    const b = stz_bigint_negate(a) orelse return error.AllocFailed;
    defer stz_bigint_free(b);
    try std.testing.expectEqual(@as(i64, -42), stz_bigint_to_int(b));
}

test "bigint abs" {
    const a = stz_bigint_from_int(-99) orelse return error.AllocFailed;
    defer stz_bigint_free(a);
    const b = stz_bigint_abs(a) orelse return error.AllocFailed;
    defer stz_bigint_free(b);
    try std.testing.expectEqual(@as(i64, 99), stz_bigint_to_int(b));
}

test "bigint compare" {
    const a = stz_bigint_from_int(10) orelse return error.AllocFailed;
    defer stz_bigint_free(a);
    const b = stz_bigint_from_int(20) orelse return error.AllocFailed;
    defer stz_bigint_free(b);
    try std.testing.expect(stz_bigint_compare(a, b) < 0);
    try std.testing.expect(stz_bigint_compare(b, a) > 0);
    try std.testing.expectEqual(@as(i32, 1), stz_bigint_equals(a, a));
}

test "bigint is_zero" {
    const a = stz_bigint_from_int(0) orelse return error.AllocFailed;
    defer stz_bigint_free(a);
    try std.testing.expectEqual(@as(i32, 1), stz_bigint_is_zero(a));

    const b = stz_bigint_from_int(5) orelse return error.AllocFailed;
    defer stz_bigint_free(b);
    try std.testing.expectEqual(@as(i32, 0), stz_bigint_is_zero(b));
}

test "bigint is_negative" {
    const pos = stz_bigint_from_int(5) orelse return error.AllocFailed;
    defer stz_bigint_free(pos);
    try std.testing.expectEqual(@as(i32, 0), stz_bigint_is_negative(pos));

    const neg = stz_bigint_from_int(-5) orelse return error.AllocFailed;
    defer stz_bigint_free(neg);
    try std.testing.expectEqual(@as(i32, 1), stz_bigint_is_negative(neg));
}

test "bigint pow" {
    const base_val = stz_bigint_from_int(2) orelse return error.AllocFailed;
    defer stz_bigint_free(base_val);
    const result = stz_bigint_pow(base_val, 10) orelse return error.AllocFailed;
    defer stz_bigint_free(result);
    try std.testing.expectEqual(@as(i64, 1024), stz_bigint_to_int(result));
}

test "bigint large number" {
    const s = "123456789012345678901234567890";
    const a = stz_bigint_from_string(s.ptr, s.len) orelse return error.AllocFailed;
    defer stz_bigint_free(a);
    const b = stz_bigint_from_int(1) orelse return error.AllocFailed;
    defer stz_bigint_free(b);
    const c = stz_bigint_add(a, b) orelse return error.AllocFailed;
    defer stz_bigint_free(c);
    var buf: [64]u8 = undefined;
    const len = stz_bigint_to_string(c, &buf, 64);
    try std.testing.expect(std.mem.eql(u8, buf[0..len], "123456789012345678901234567891"));
}

test "bigint to_string_base hex" {
    const a = stz_bigint_from_int(255) orelse return error.AllocFailed;
    defer stz_bigint_free(a);
    var buf: [16]u8 = undefined;
    const len = stz_bigint_to_string_base(a, 16, &buf, 16);
    try std.testing.expect(std.mem.eql(u8, buf[0..len], "ff"));
}

test "bigint to_string_base binary" {
    const a = stz_bigint_from_int(10) orelse return error.AllocFailed;
    defer stz_bigint_free(a);
    var buf: [16]u8 = undefined;
    const len = stz_bigint_to_string_base(a, 2, &buf, 16);
    try std.testing.expect(std.mem.eql(u8, buf[0..len], "1010"));
}

test "bigint clone" {
    const a = stz_bigint_from_int(777) orelse return error.AllocFailed;
    defer stz_bigint_free(a);
    const b = stz_bigint_clone(a) orelse return error.AllocFailed;
    defer stz_bigint_free(b);
    try std.testing.expectEqual(@as(i32, 1), stz_bigint_equals(a, b));
}

test "bigint bit_count" {
    const a = stz_bigint_from_int(255) orelse return error.AllocFailed;
    defer stz_bigint_free(a);
    try std.testing.expectEqual(@as(usize, 8), stz_bigint_bit_count(a));
}

test "number gcd" {
    try std.testing.expectEqual(@as(i64, 6), stz_number_gcd(12, 18));
    try std.testing.expectEqual(@as(i64, 1), stz_number_gcd(7, 13));
    try std.testing.expectEqual(@as(i64, 5), stz_number_gcd(0, 5));
}

test "number lcm" {
    try std.testing.expectEqual(@as(i64, 36), stz_number_lcm(12, 18));
    try std.testing.expectEqual(@as(i64, 91), stz_number_lcm(7, 13));
    try std.testing.expectEqual(@as(i64, 0), stz_number_lcm(0, 5));
}

test "number is_prime" {
    try std.testing.expectEqual(@as(i32, 1), stz_number_is_prime(2));
    try std.testing.expectEqual(@as(i32, 1), stz_number_is_prime(17));
    try std.testing.expectEqual(@as(i32, 0), stz_number_is_prime(4));
    try std.testing.expectEqual(@as(i32, 0), stz_number_is_prime(1));
    try std.testing.expectEqual(@as(i32, 1), stz_number_is_prime(97));
}

test "number factorial" {
    const f5 = stz_number_factorial(5) orelse return error.AllocFailed;
    defer stz_bigint_free(f5);
    try std.testing.expectEqual(@as(i64, 120), stz_bigint_to_int(f5));

    const f20 = stz_number_factorial(20) orelse return error.AllocFailed;
    defer stz_bigint_free(f20);
    try std.testing.expectEqual(@as(i64, 2432902008176640000), stz_bigint_to_int(f20));
}

test "number fibonacci" {
    const f0 = stz_number_fibonacci(0) orelse return error.AllocFailed;
    defer stz_bigint_free(f0);
    try std.testing.expectEqual(@as(i64, 0), stz_bigint_to_int(f0));

    const f10 = stz_number_fibonacci(10) orelse return error.AllocFailed;
    defer stz_bigint_free(f10);
    try std.testing.expectEqual(@as(i64, 55), stz_bigint_to_int(f10));

    const f50 = stz_number_fibonacci(50) orelse return error.AllocFailed;
    defer stz_bigint_free(f50);
    try std.testing.expectEqual(@as(i64, 12586269025), stz_bigint_to_int(f50));
}

test "number is_perfect" {
    try std.testing.expectEqual(@as(i32, 1), stz_number_is_perfect(6));
    try std.testing.expectEqual(@as(i32, 1), stz_number_is_perfect(28));
    try std.testing.expectEqual(@as(i32, 0), stz_number_is_perfect(12));
}

test "number digit_count" {
    try std.testing.expectEqual(@as(i32, 1), stz_number_digit_count(0));
    try std.testing.expectEqual(@as(i32, 3), stz_number_digit_count(123));
    try std.testing.expectEqual(@as(i32, 5), stz_number_digit_count(-12345));
}

test "number digit_sum" {
    try std.testing.expectEqual(@as(i64, 6), stz_number_digit_sum(123));
    try std.testing.expectEqual(@as(i64, 15), stz_number_digit_sum(12345));
    try std.testing.expectEqual(@as(i64, 6), stz_number_digit_sum(-123));
}

test "number reverse_digits" {
    try std.testing.expectEqual(@as(i64, 321), stz_number_reverse_digits(123));
    try std.testing.expectEqual(@as(i64, -321), stz_number_reverse_digits(-123));
}

test "number is_palindrome" {
    try std.testing.expectEqual(@as(i32, 1), stz_number_is_palindrome(121));
    try std.testing.expectEqual(@as(i32, 1), stz_number_is_palindrome(12321));
    try std.testing.expectEqual(@as(i32, 0), stz_number_is_palindrome(123));
    try std.testing.expectEqual(@as(i32, 0), stz_number_is_palindrome(-121));
}

test "bigint null handles" {
    stz_bigint_free(null);
    try std.testing.expect(stz_bigint_add(null, null) == null);
    try std.testing.expectEqual(@as(i32, 0), stz_bigint_compare(null, null));
    try std.testing.expectEqual(@as(i64, 0), stz_bigint_to_int(null));
}
