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

// ─── C ABI: BigInt Parse from Base ───

pub fn stz_bigint_from_string_base(ptr: [*]const u8, len: usize, base: u8) callconv(.c) ?*StzBigInt {
    if (len == 0 or base < 2 or base > 36) return null;
    const bi = StzBigInt.init() catch return null;
    const str = ptr[0..len];
    bi.value.setString(base, str) catch {
        bi.deinit();
        return null;
    };
    return bi;
}

// ─── C ABI: Integer Base Conversion (i64 convenience) ───

pub fn stz_number_to_base(n: i64, base: u8, buf: [*]u8, buf_len: usize) callconv(.c) usize {
    if (buf_len == 0 or base < 2 or base > 36) return 0;
    const bi = stz_bigint_from_int(n) orelse return 0;
    defer stz_bigint_free(bi);
    return stz_bigint_to_string_base(bi, base, buf, buf_len);
}

pub fn stz_number_from_base(ptr: [*]const u8, len: usize, base: u8) callconv(.c) i64 {
    if (len == 0 or base < 2 or base > 36) return 0;
    const bi = stz_bigint_from_string_base(ptr, len, base) orelse return 0;
    defer stz_bigint_free(bi);
    return stz_bigint_to_int(bi);
}

// ─── C ABI: Bitwise Operations (i64) ───

pub fn stz_number_bitwise_and(a: i64, b: i64) callconv(.c) i64 {
    return a & b;
}

pub fn stz_number_bitwise_or(a: i64, b: i64) callconv(.c) i64 {
    return a | b;
}

pub fn stz_number_bitwise_xor(a: i64, b: i64) callconv(.c) i64 {
    return a ^ b;
}

pub fn stz_number_bitwise_not(a: i64) callconv(.c) i64 {
    return ~a;
}

pub fn stz_number_bitwise_lshift(a: i64, n: u8) callconv(.c) i64 {
    if (n >= 64) return 0;
    const shift: u6 = @intCast(n);
    return a << shift;
}

pub fn stz_number_bitwise_rshift(a: i64, n: u8) callconv(.c) i64 {
    if (n >= 64) return 0;
    const shift: u6 = @intCast(n);
    const ua: u64 = @bitCast(a);
    return @bitCast(ua >> shift);
}

// ─── C ABI: Scientific Notation ───

pub fn stz_number_to_scientific(n: f64, buf: [*]u8, buf_len: usize) callconv(.c) usize {
    if (buf_len == 0) return 0;
    if (n == 0.0) {
        if (buf_len >= 5) {
            const s = "0e+00";
            @memcpy(buf[0..5], s);
            return 5;
        }
        return 0;
    }
    const abs_n = @abs(n);
    const log10_val = @log10(abs_n);
    const exp_f: f64 = @floor(log10_val);
    const exp_i: i32 = @intFromFloat(exp_f);
    const mantissa = n / std.math.pow(f64, 10.0, exp_f);

    var tmp: [64]u8 = undefined;
    var pos: usize = 0;

    if (mantissa < 0) {
        tmp[pos] = '-';
        pos += 1;
    }
    const abs_m = @abs(mantissa);
    const int_part: u64 = @intFromFloat(abs_m);
    const frac_part: f64 = abs_m - @as(f64, @floatFromInt(int_part));

    if (int_part < 10) {
        tmp[pos] = @intCast(int_part + '0');
        pos += 1;
    } else {
        tmp[pos] = '1';
        pos += 1;
    }

    if (frac_part > 1e-10) {
        tmp[pos] = '.';
        pos += 1;
        var frac = frac_part;
        var digits: u32 = 0;
        while (digits < 15 and frac > 1e-15) : (digits += 1) {
            frac *= 10.0;
            const d: u64 = @intFromFloat(frac);
            tmp[pos] = @intCast(d + '0');
            pos += 1;
            frac -= @as(f64, @floatFromInt(d));
        }
        while (pos > 0 and tmp[pos - 1] == '0') pos -= 1;
        if (pos > 0 and tmp[pos - 1] == '.') pos -= 1;
    }

    tmp[pos] = 'e';
    pos += 1;
    if (exp_i >= 0) {
        tmp[pos] = '+';
        pos += 1;
    } else {
        tmp[pos] = '-';
        pos += 1;
    }
    const abs_exp: u32 = @intCast(if (exp_i < 0) -exp_i else exp_i);
    if (abs_exp >= 100) {
        tmp[pos] = @intCast(abs_exp / 100 + '0');
        pos += 1;
        tmp[pos] = @intCast((abs_exp / 10) % 10 + '0');
        pos += 1;
        tmp[pos] = @intCast(abs_exp % 10 + '0');
        pos += 1;
    } else {
        tmp[pos] = @intCast(abs_exp / 10 + '0');
        pos += 1;
        tmp[pos] = @intCast(abs_exp % 10 + '0');
        pos += 1;
    }

    const copy_len = @min(pos, buf_len);
    @memcpy(buf[0..copy_len], tmp[0..copy_len]);
    return copy_len;
}

pub fn stz_number_from_scientific(ptr: [*]const u8, len: usize) callconv(.c) f64 {
    if (len == 0) return 0.0;
    const str = ptr[0..len];
    var e_pos: ?usize = null;
    for (str, 0..) |c, i| {
        if (c == 'e' or c == 'E') {
            e_pos = i;
            break;
        }
    }
    const ep = e_pos orelse return 0.0;
    const mantissa = parseFloat(str[0..ep]);
    const exp_str = str[ep + 1 ..];
    const exp_val = parseInt(exp_str);
    return mantissa * std.math.pow(f64, 10.0, @as(f64, @floatFromInt(exp_val)));
}

fn parseFloat(str: []const u8) f64 {
    if (str.len == 0) return 0.0;
    var neg = false;
    var start: usize = 0;
    if (str[0] == '-') {
        neg = true;
        start = 1;
    } else if (str[0] == '+') {
        start = 1;
    }
    var int_part: f64 = 0;
    var i = start;
    while (i < str.len and str[i] != '.') : (i += 1) {
        if (str[i] >= '0' and str[i] <= '9') {
            int_part = int_part * 10.0 + @as(f64, @floatFromInt(str[i] - '0'));
        }
    }
    var frac_part: f64 = 0;
    if (i < str.len and str[i] == '.') {
        i += 1;
        var divisor: f64 = 10.0;
        while (i < str.len) : (i += 1) {
            if (str[i] >= '0' and str[i] <= '9') {
                frac_part += @as(f64, @floatFromInt(str[i] - '0')) / divisor;
                divisor *= 10.0;
            }
        }
    }
    const result = int_part + frac_part;
    return if (neg) -result else result;
}

fn parseInt(str: []const u8) i32 {
    if (str.len == 0) return 0;
    var neg = false;
    var start: usize = 0;
    if (str[0] == '-') {
        neg = true;
        start = 1;
    } else if (str[0] == '+') {
        start = 1;
    }
    var val: i32 = 0;
    for (str[start..]) |c| {
        if (c >= '0' and c <= '9') {
            val = val * 10 + @as(i32, @intCast(c - '0'));
        }
    }
    return if (neg) -val else val;
}

// ─── C ABI: Number Predicates ───

pub fn stz_number_is_even(n: i64) callconv(.c) i32 {
    return if (@mod(n, 2) == 0) 1 else 0;
}

pub fn stz_number_is_odd(n: i64) callconv(.c) i32 {
    return if (@mod(n, 2) != 0) 1 else 0;
}

pub fn stz_number_is_armstrong(n: i64) callconv(.c) i32 {
    if (n < 0) return 0;
    const digits = stz_number_digit_count(n);
    var x = n;
    var sum: i64 = 0;
    while (x > 0) {
        const d = @mod(x, 10);
        var power: i64 = 1;
        var j: i32 = 0;
        while (j < digits) : (j += 1) power *= d;
        sum += power;
        x = @divTrunc(x, 10);
    }
    return if (sum == n) 1 else 0;
}

pub fn stz_number_divisors(n: i64, buf: [*]i64, buf_len: usize) callconv(.c) usize {
    if (n <= 0 or buf_len == 0) return 0;
    var count: usize = 0;
    var i: i64 = 1;
    while (i * i <= n) : (i += 1) {
        if (@mod(n, i) == 0) {
            if (count < buf_len) {
                buf[count] = i;
                count += 1;
            }
            const other = @divExact(n, i);
            if (other != i and count < buf_len) {
                buf[count] = other;
                count += 1;
            }
        }
    }
    var j: usize = 0;
    while (j < count) : (j += 1) {
        var k = j + 1;
        while (k < count) : (k += 1) {
            if (buf[k] < buf[j]) {
                const tmp = buf[j];
                buf[j] = buf[k];
                buf[k] = tmp;
            }
        }
    }
    return count;
}

pub fn stz_number_is_abundant(n: i64) callconv(.c) i32 {
    if (n <= 1) return 0;
    var sum: i64 = 1;
    var i: i64 = 2;
    while (i * i <= n) : (i += 1) {
        if (@mod(n, i) == 0) {
            sum += i;
            const other = @divExact(n, i);
            if (other != i) sum += other;
        }
    }
    return if (sum > n) 1 else 0;
}

pub fn stz_number_is_deficient(n: i64) callconv(.c) i32 {
    if (n <= 1) return 0;
    var sum: i64 = 1;
    var i: i64 = 2;
    while (i * i <= n) : (i += 1) {
        if (@mod(n, i) == 0) {
            sum += i;
            const other = @divExact(n, i);
            if (other != i) sum += other;
        }
    }
    return if (sum < n) 1 else 0;
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

test "bigint from_string_base binary" {
    const bi = stz_bigint_from_string_base("1010", 4, 2) orelse return error.AllocFailed;
    defer stz_bigint_free(bi);
    try std.testing.expectEqual(@as(i64, 10), stz_bigint_to_int(bi));
}

test "bigint from_string_base hex" {
    const bi = stz_bigint_from_string_base("ff", 2, 16) orelse return error.AllocFailed;
    defer stz_bigint_free(bi);
    try std.testing.expectEqual(@as(i64, 255), stz_bigint_to_int(bi));
}

test "bigint from_string_base octal" {
    const bi = stz_bigint_from_string_base("77", 2, 8) orelse return error.AllocFailed;
    defer stz_bigint_free(bi);
    try std.testing.expectEqual(@as(i64, 63), stz_bigint_to_int(bi));
}

test "number to_base binary" {
    var buf: [64]u8 = undefined;
    const len = stz_number_to_base(255, 2, &buf, 64);
    try std.testing.expect(std.mem.eql(u8, buf[0..len], "11111111"));
}

test "number to_base hex" {
    var buf: [64]u8 = undefined;
    const len = stz_number_to_base(255, 16, &buf, 64);
    try std.testing.expect(std.mem.eql(u8, buf[0..len], "ff"));
}

test "number to_base octal" {
    var buf: [64]u8 = undefined;
    const len = stz_number_to_base(255, 8, &buf, 64);
    try std.testing.expect(std.mem.eql(u8, buf[0..len], "377"));
}

test "number from_base binary" {
    try std.testing.expectEqual(@as(i64, 10), stz_number_from_base("1010", 4, 2));
}

test "number from_base hex" {
    try std.testing.expectEqual(@as(i64, 255), stz_number_from_base("ff", 2, 16));
}

test "number from_base octal" {
    try std.testing.expectEqual(@as(i64, 63), stz_number_from_base("77", 2, 8));
}

test "bitwise and" {
    try std.testing.expectEqual(@as(i64, 0b1000), stz_number_bitwise_and(0b1010, 0b1100));
}

test "bitwise or" {
    try std.testing.expectEqual(@as(i64, 0b1110), stz_number_bitwise_or(0b1010, 0b1100));
}

test "bitwise xor" {
    try std.testing.expectEqual(@as(i64, 0b0110), stz_number_bitwise_xor(0b1010, 0b1100));
}

test "bitwise not" {
    try std.testing.expectEqual(@as(i64, -11), stz_number_bitwise_not(10));
}

test "bitwise lshift" {
    try std.testing.expectEqual(@as(i64, 40), stz_number_bitwise_lshift(10, 2));
}

test "bitwise rshift" {
    try std.testing.expectEqual(@as(i64, 2), stz_number_bitwise_rshift(10, 2));
}

test "scientific notation to" {
    var buf: [64]u8 = undefined;
    const len = stz_number_to_scientific(12345.0, &buf, 64);
    const result = buf[0..len];
    try std.testing.expect(result.len > 0);
    try std.testing.expect(result[0] == '1');
    var has_e = false;
    for (result) |c| {
        if (c == 'e') has_e = true;
    }
    try std.testing.expect(has_e);
}

test "scientific notation from" {
    const val = stz_number_from_scientific("1.5e+03", 7);
    try std.testing.expectEqual(@as(f64, 1500.0), val);
}

test "scientific notation roundtrip" {
    const val = stz_number_from_scientific("2.5e+02", 7);
    try std.testing.expectEqual(@as(f64, 250.0), val);
}

test "number is_even" {
    try std.testing.expectEqual(@as(i32, 1), stz_number_is_even(4));
    try std.testing.expectEqual(@as(i32, 0), stz_number_is_even(3));
    try std.testing.expectEqual(@as(i32, 1), stz_number_is_even(0));
}

test "number is_odd" {
    try std.testing.expectEqual(@as(i32, 1), stz_number_is_odd(3));
    try std.testing.expectEqual(@as(i32, 0), stz_number_is_odd(4));
}

test "number is_armstrong" {
    try std.testing.expectEqual(@as(i32, 1), stz_number_is_armstrong(153));
    try std.testing.expectEqual(@as(i32, 1), stz_number_is_armstrong(370));
    try std.testing.expectEqual(@as(i32, 0), stz_number_is_armstrong(10));
}

test "number divisors" {
    var buf: [32]i64 = undefined;
    const count = stz_number_divisors(12, &buf, 32);
    try std.testing.expectEqual(@as(usize, 6), count);
    try std.testing.expectEqual(@as(i64, 1), buf[0]);
    try std.testing.expectEqual(@as(i64, 2), buf[1]);
    try std.testing.expectEqual(@as(i64, 3), buf[2]);
    try std.testing.expectEqual(@as(i64, 4), buf[3]);
    try std.testing.expectEqual(@as(i64, 6), buf[4]);
    try std.testing.expectEqual(@as(i64, 12), buf[5]);
}

test "number is_abundant" {
    try std.testing.expectEqual(@as(i32, 1), stz_number_is_abundant(12));
    try std.testing.expectEqual(@as(i32, 0), stz_number_is_abundant(6));
}

test "number is_deficient" {
    try std.testing.expectEqual(@as(i32, 1), stz_number_is_deficient(8));
    try std.testing.expectEqual(@as(i32, 0), stz_number_is_deficient(6));
}
