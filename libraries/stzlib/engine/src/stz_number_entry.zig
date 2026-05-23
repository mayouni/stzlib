// Per-domain entry point for stz_number.dll
pub const number = @import("number.zig");
pub const ring_bridge = @import("ring_bridge_number.zig");

comptime {
    @export(&number.stz_bigint_new, .{ .name = "stz_bigint_new" });
    @export(&number.stz_bigint_from_int, .{ .name = "stz_bigint_from_int" });
    @export(&number.stz_bigint_from_string, .{ .name = "stz_bigint_from_string" });
    @export(&number.stz_bigint_free, .{ .name = "stz_bigint_free" });
    @export(&number.stz_bigint_add, .{ .name = "stz_bigint_add" });
    @export(&number.stz_bigint_sub, .{ .name = "stz_bigint_sub" });
    @export(&number.stz_bigint_mul, .{ .name = "stz_bigint_mul" });
    @export(&number.stz_bigint_div, .{ .name = "stz_bigint_div" });
    @export(&number.stz_bigint_mod, .{ .name = "stz_bigint_mod" });
    @export(&number.stz_bigint_negate, .{ .name = "stz_bigint_negate" });
    @export(&number.stz_bigint_abs, .{ .name = "stz_bigint_abs" });
    @export(&number.stz_bigint_compare, .{ .name = "stz_bigint_compare" });
    @export(&number.stz_bigint_equals, .{ .name = "stz_bigint_equals" });
    @export(&number.stz_bigint_is_zero, .{ .name = "stz_bigint_is_zero" });
    @export(&number.stz_bigint_is_negative, .{ .name = "stz_bigint_is_negative" });
    @export(&number.stz_bigint_to_int, .{ .name = "stz_bigint_to_int" });
    @export(&number.stz_bigint_to_string, .{ .name = "stz_bigint_to_string" });
    @export(&number.stz_bigint_to_string_base, .{ .name = "stz_bigint_to_string_base" });
    @export(&number.stz_bigint_clone, .{ .name = "stz_bigint_clone" });
    @export(&number.stz_bigint_pow, .{ .name = "stz_bigint_pow" });
    @export(&number.stz_bigint_bit_count, .{ .name = "stz_bigint_bit_count" });
    @export(&number.stz_number_gcd, .{ .name = "stz_number_gcd" });
    @export(&number.stz_number_lcm, .{ .name = "stz_number_lcm" });
    @export(&number.stz_number_is_prime, .{ .name = "stz_number_is_prime" });
    @export(&number.stz_number_factorial, .{ .name = "stz_number_factorial" });
    @export(&number.stz_number_fibonacci, .{ .name = "stz_number_fibonacci" });
    @export(&number.stz_number_is_perfect, .{ .name = "stz_number_is_perfect" });
    @export(&number.stz_number_digit_count, .{ .name = "stz_number_digit_count" });
    @export(&number.stz_number_digit_sum, .{ .name = "stz_number_digit_sum" });
    @export(&number.stz_number_reverse_digits, .{ .name = "stz_number_reverse_digits" });
    @export(&number.stz_number_is_palindrome, .{ .name = "stz_number_is_palindrome" });
    @export(&number.stz_bigint_from_string_base, .{ .name = "stz_bigint_from_string_base" });
    @export(&number.stz_number_to_base, .{ .name = "stz_number_to_base" });
    @export(&number.stz_number_from_base, .{ .name = "stz_number_from_base" });
    @export(&number.stz_number_bitwise_and, .{ .name = "stz_number_bitwise_and" });
    @export(&number.stz_number_bitwise_or, .{ .name = "stz_number_bitwise_or" });
    @export(&number.stz_number_bitwise_xor, .{ .name = "stz_number_bitwise_xor" });
    @export(&number.stz_number_bitwise_not, .{ .name = "stz_number_bitwise_not" });
    @export(&number.stz_number_bitwise_lshift, .{ .name = "stz_number_bitwise_lshift" });
    @export(&number.stz_number_bitwise_rshift, .{ .name = "stz_number_bitwise_rshift" });
    @export(&number.stz_number_to_scientific, .{ .name = "stz_number_to_scientific" });
    @export(&number.stz_number_from_scientific, .{ .name = "stz_number_from_scientific" });
    @export(&number.stz_number_is_even, .{ .name = "stz_number_is_even" });
    @export(&number.stz_number_is_odd, .{ .name = "stz_number_is_odd" });
    @export(&number.stz_number_is_armstrong, .{ .name = "stz_number_is_armstrong" });
    @export(&number.stz_number_divisors, .{ .name = "stz_number_divisors" });
    @export(&number.stz_number_is_abundant, .{ .name = "stz_number_is_abundant" });
    @export(&number.stz_number_is_deficient, .{ .name = "stz_number_is_deficient" });
}

comptime {
    @export(&ring_bridge.ringlib_init, .{ .name = "ringlib_init" });
}

test { _ = number; }
