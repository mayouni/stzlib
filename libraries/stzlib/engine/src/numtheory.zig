const std = @import("std");

// ── Number Theory ───────────────────────────────────────────
// GCD, LCM, primality, factorization, Fibonacci, modular arithmetic.

pub fn gcd(a_raw: i64, b_raw: i64) callconv(.c) i64 {
    var a = if (a_raw < 0) -a_raw else a_raw;
    var b = if (b_raw < 0) -b_raw else b_raw;
    if (a == 0) return b;
    if (b == 0) return a;
    while (b != 0) {
        const t = @mod(a, b);
        a = b;
        b = t;
    }
    return a;
}

pub fn lcm(a: i64, b: i64) callconv(.c) i64 {
    if (a == 0 or b == 0) return 0;
    const g = gcd(a, b);
    const abs_a = if (a < 0) -a else a;
    const abs_b = if (b < 0) -b else b;
    return @divExact(abs_a, g) * abs_b;
}

pub fn is_prime(n: i64) callconv(.c) i32 {
    if (n < 2) return 0;
    if (n < 4) return 1;
    if (@mod(n, 2) == 0 or @mod(n, 3) == 0) return 0;
    var i: i64 = 5;
    while (i * i <= n) : (i += 6) {
        if (@mod(n, i) == 0 or @mod(n, i + 2) == 0) return 0;
    }
    return 1;
}

pub fn next_prime(n: i64) callconv(.c) i64 {
    if (n < 2) return 2;
    var candidate = if (@mod(n, 2) == 0) n + 1 else n + 2;
    while (is_prime(candidate) == 0) : (candidate += 2) {}
    return candidate;
}

pub fn prev_prime(n: i64) callconv(.c) i64 {
    if (n <= 2) return -1;
    if (n == 3) return 2;
    var candidate = if (@mod(n, 2) == 0) n - 1 else n - 2;
    while (candidate >= 2) : (candidate -= 2) {
        if (is_prime(candidate) != 0) return candidate;
    }
    return 2;
}

pub fn nth_prime(n: i32) callconv(.c) i64 {
    if (n <= 0) return -1;
    if (n == 1) return 2;
    var count: i32 = 1;
    var candidate: i64 = 3;
    while (count < n) : (candidate += 2) {
        if (is_prime(candidate) != 0) {
            count += 1;
            if (count == n) return candidate;
        }
    }
    return candidate - 2;
}

const MAX_FACTORS = 64;
var factor_buf: [MAX_FACTORS]i64 = undefined;
var factor_count: usize = 0;

pub fn factorize(n_raw: i64) callconv(.c) i32 {
    factor_count = 0;
    var n = if (n_raw < 0) -n_raw else n_raw;
    if (n < 2) return 0;
    while (@mod(n, 2) == 0) {
        if (factor_count < MAX_FACTORS) {
            factor_buf[factor_count] = 2;
            factor_count += 1;
        }
        n = @divExact(n, 2);
    }
    var i: i64 = 3;
    while (i * i <= n) : (i += 2) {
        while (@mod(n, i) == 0) {
            if (factor_count < MAX_FACTORS) {
                factor_buf[factor_count] = i;
                factor_count += 1;
            }
            n = @divExact(n, i);
        }
    }
    if (n > 1) {
        if (factor_count < MAX_FACTORS) {
            factor_buf[factor_count] = n;
            factor_count += 1;
        }
    }
    return @intCast(factor_count);
}

pub fn factor_at(idx: i32) callconv(.c) i64 {
    const i: usize = @intCast(idx);
    if (i >= factor_count) return -1;
    return factor_buf[i];
}

pub fn fibonacci(n: i32) callconv(.c) i64 {
    if (n <= 0) return 0;
    if (n == 1) return 1;
    var a: i64 = 0;
    var b: i64 = 1;
    for (2..@as(usize, @intCast(n)) + 1) |_| {
        const c = a + b;
        a = b;
        b = c;
    }
    return b;
}

pub fn is_fibonacci(n: i64) callconv(.c) i32 {
    if (n < 0) return 0;
    if (n <= 1) return 1;
    var a: i64 = 0;
    var b: i64 = 1;
    while (b < n) {
        const c = a + b;
        a = b;
        b = c;
    }
    return if (b == n) 1 else 0;
}

pub fn mod_pow(base_raw: i64, exp_raw: i64, modulus: i64) callconv(.c) i64 {
    if (modulus <= 0) return -1;
    if (modulus == 1) return 0;
    var result: i64 = 1;
    var b = @mod(base_raw, modulus);
    var e = exp_raw;
    while (e > 0) : (e = @divFloor(e, 2)) {
        if (@mod(e, 2) == 1) {
            result = @mod(result * b, modulus);
        }
        b = @mod(b * b, modulus);
    }
    return result;
}

pub fn mod_inv(a_raw: i64, m: i64) callconv(.c) i64 {
    if (m <= 0) return -1;
    var old_r = a_raw;
    var r = m;
    var old_s: i64 = 1;
    var s: i64 = 0;
    while (r != 0) {
        const q = @divFloor(old_r, r);
        const tmp_r = r;
        r = old_r - q * r;
        old_r = tmp_r;
        const tmp_s = s;
        s = old_s - q * s;
        old_s = tmp_s;
    }
    if (old_r != 1) return -1;
    return @mod(old_s, m);
}

pub fn divisor_count(n_raw: i64) callconv(.c) i32 {
    var n = if (n_raw < 0) -n_raw else n_raw;
    if (n == 0) return 0;
    if (n == 1) return 1;
    var count: i32 = 0;
    var i: i64 = 1;
    while (i * i <= n) : (i += 1) {
        if (@mod(n, i) == 0) {
            count += 1;
            if (i != @divExact(n, i)) count += 1;
        }
    }
    _ = &n;
    return count;
}

pub fn divisor_sum(n_raw: i64) callconv(.c) i64 {
    const n = if (n_raw < 0) -n_raw else n_raw;
    if (n == 0) return 0;
    var sum: i64 = 0;
    var i: i64 = 1;
    while (i * i <= n) : (i += 1) {
        if (@mod(n, i) == 0) {
            sum += i;
            const other = @divExact(n, i);
            if (other != i) sum += other;
        }
    }
    return sum;
}

pub fn is_perfect(n: i64) callconv(.c) i32 {
    if (n < 2) return 0;
    return if (divisor_sum(n) - n == n) 1 else 0;
}

pub fn euler_totient(n_raw: i64) callconv(.c) i64 {
    var n = if (n_raw < 0) -n_raw else n_raw;
    if (n <= 1) return n;
    var result = n;
    var p: i64 = 2;
    while (p * p <= n) : (p += 1) {
        if (@mod(n, p) == 0) {
            while (@mod(n, p) == 0) n = @divExact(n, p);
            result -= @divExact(result, p);
        }
    }
    if (n > 1) result -= @divExact(result, n);
    return result;
}

// ── C ABI exports ────────────────────────────────────────────

pub export fn stz_numtheory_gcd(a: i64, b: i64) callconv(.c) i64 { return gcd(a, b); }
pub export fn stz_numtheory_lcm(a: i64, b: i64) callconv(.c) i64 { return lcm(a, b); }
pub export fn stz_numtheory_is_prime(n: i64) callconv(.c) i32 { return is_prime(n); }
pub export fn stz_numtheory_next_prime(n: i64) callconv(.c) i64 { return next_prime(n); }
pub export fn stz_numtheory_prev_prime(n: i64) callconv(.c) i64 { return prev_prime(n); }
pub export fn stz_numtheory_nth_prime(n: i32) callconv(.c) i64 { return nth_prime(n); }
pub export fn stz_numtheory_factorize(n: i64) callconv(.c) i32 { return factorize(n); }
pub export fn stz_numtheory_factor_at(i: i32) callconv(.c) i64 { return factor_at(i); }
pub export fn stz_numtheory_fibonacci(n: i32) callconv(.c) i64 { return fibonacci(n); }
pub export fn stz_numtheory_is_fibonacci(n: i64) callconv(.c) i32 { return is_fibonacci(n); }
pub export fn stz_numtheory_mod_pow(b: i64, e: i64, m: i64) callconv(.c) i64 { return mod_pow(b, e, m); }
pub export fn stz_numtheory_mod_inv(a: i64, m: i64) callconv(.c) i64 { return mod_inv(a, m); }
pub export fn stz_numtheory_divisor_count(n: i64) callconv(.c) i32 { return divisor_count(n); }
pub export fn stz_numtheory_divisor_sum(n: i64) callconv(.c) i64 { return divisor_sum(n); }
pub export fn stz_numtheory_is_perfect(n: i64) callconv(.c) i32 { return is_perfect(n); }
pub export fn stz_numtheory_euler_totient(n: i64) callconv(.c) i64 { return euler_totient(n); }

// ── Tests ────────────────────────────────────────────────────

test "numtheory: gcd" {
    try std.testing.expectEqual(@as(i64, 6), gcd(12, 18));
    try std.testing.expectEqual(@as(i64, 1), gcd(7, 13));
    try std.testing.expectEqual(@as(i64, 5), gcd(0, 5));
    try std.testing.expectEqual(@as(i64, 4), gcd(-12, 8));
}

test "numtheory: lcm" {
    try std.testing.expectEqual(@as(i64, 36), lcm(12, 18));
    try std.testing.expectEqual(@as(i64, 91), lcm(7, 13));
    try std.testing.expectEqual(@as(i64, 0), lcm(0, 5));
}

test "numtheory: is_prime" {
    try std.testing.expectEqual(@as(i32, 0), is_prime(0));
    try std.testing.expectEqual(@as(i32, 0), is_prime(1));
    try std.testing.expectEqual(@as(i32, 1), is_prime(2));
    try std.testing.expectEqual(@as(i32, 1), is_prime(17));
    try std.testing.expectEqual(@as(i32, 0), is_prime(15));
    try std.testing.expectEqual(@as(i32, 1), is_prime(97));
}

test "numtheory: next/prev prime" {
    try std.testing.expectEqual(@as(i64, 11), next_prime(7));
    try std.testing.expectEqual(@as(i64, 5), prev_prime(7));
    try std.testing.expectEqual(@as(i64, 2), next_prime(1));
}

test "numtheory: nth prime" {
    try std.testing.expectEqual(@as(i64, 2), nth_prime(1));
    try std.testing.expectEqual(@as(i64, 3), nth_prime(2));
    try std.testing.expectEqual(@as(i64, 29), nth_prime(10));
}

test "numtheory: factorize" {
    const count = factorize(60);
    try std.testing.expectEqual(@as(i32, 4), count);
    try std.testing.expectEqual(@as(i64, 2), factor_at(0));
    try std.testing.expectEqual(@as(i64, 2), factor_at(1));
    try std.testing.expectEqual(@as(i64, 3), factor_at(2));
    try std.testing.expectEqual(@as(i64, 5), factor_at(3));
}

test "numtheory: fibonacci" {
    try std.testing.expectEqual(@as(i64, 0), fibonacci(0));
    try std.testing.expectEqual(@as(i64, 1), fibonacci(1));
    try std.testing.expectEqual(@as(i64, 55), fibonacci(10));
    try std.testing.expectEqual(@as(i32, 1), is_fibonacci(55));
    try std.testing.expectEqual(@as(i32, 0), is_fibonacci(4));
}

test "numtheory: mod_pow" {
    try std.testing.expectEqual(@as(i64, 1), mod_pow(2, 10, 1023));
    try std.testing.expectEqual(@as(i64, 4), mod_pow(2, 10, 1020));
}

test "numtheory: mod_inv" {
    try std.testing.expectEqual(@as(i64, 4), mod_inv(3, 11));
    try std.testing.expectEqual(@as(i64, -1), mod_inv(2, 4));
}

test "numtheory: divisors" {
    try std.testing.expectEqual(@as(i32, 6), divisor_count(12));
    try std.testing.expectEqual(@as(i64, 28), divisor_sum(12));
}

test "numtheory: perfect numbers" {
    try std.testing.expectEqual(@as(i32, 1), is_perfect(6));
    try std.testing.expectEqual(@as(i32, 1), is_perfect(28));
    try std.testing.expectEqual(@as(i32, 0), is_perfect(10));
}

test "numtheory: euler totient" {
    try std.testing.expectEqual(@as(i64, 4), euler_totient(10));
    try std.testing.expectEqual(@as(i64, 6), euler_totient(7));
    try std.testing.expectEqual(@as(i64, 1), euler_totient(1));
}
