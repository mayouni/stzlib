const R = @import("ring_api.zig");
const numtheory = @import("numtheory.zig");

const gn = R.ring_vm_api_getnumber;
const rn = R.ring_vm_api_retnumber;

fn ring_gcd(p: *anyopaque) callconv(.c) void {
    const a: i64 = @intFromFloat(gn(p, 1));
    const b: i64 = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(numtheory.gcd(a, b)));
}

fn ring_lcm(p: *anyopaque) callconv(.c) void {
    const a: i64 = @intFromFloat(gn(p, 1));
    const b: i64 = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(numtheory.lcm(a, b)));
}

fn ring_is_prime(p: *anyopaque) callconv(.c) void {
    const n: i64 = @intFromFloat(gn(p, 1));
    rn(p, @floatFromInt(numtheory.is_prime(n)));
}

fn ring_next_prime(p: *anyopaque) callconv(.c) void {
    const n: i64 = @intFromFloat(gn(p, 1));
    rn(p, @floatFromInt(numtheory.next_prime(n)));
}

fn ring_prev_prime(p: *anyopaque) callconv(.c) void {
    const n: i64 = @intFromFloat(gn(p, 1));
    rn(p, @floatFromInt(numtheory.prev_prime(n)));
}

fn ring_nth_prime(p: *anyopaque) callconv(.c) void {
    const n: i32 = @intFromFloat(gn(p, 1));
    rn(p, @floatFromInt(numtheory.nth_prime(n)));
}

fn ring_factorize(p: *anyopaque) callconv(.c) void {
    const n: i64 = @intFromFloat(gn(p, 1));
    rn(p, @floatFromInt(numtheory.factorize(n)));
}

fn ring_factor_at(p: *anyopaque) callconv(.c) void {
    const i: i32 = @intFromFloat(gn(p, 1));
    rn(p, @floatFromInt(numtheory.factor_at(i)));
}

fn ring_fibonacci(p: *anyopaque) callconv(.c) void {
    const n: i32 = @intFromFloat(gn(p, 1));
    rn(p, @floatFromInt(numtheory.fibonacci(n)));
}

fn ring_is_fibonacci(p: *anyopaque) callconv(.c) void {
    const n: i64 = @intFromFloat(gn(p, 1));
    rn(p, @floatFromInt(numtheory.is_fibonacci(n)));
}

fn ring_mod_pow(p: *anyopaque) callconv(.c) void {
    const b: i64 = @intFromFloat(gn(p, 1));
    const e: i64 = @intFromFloat(gn(p, 2));
    const m: i64 = @intFromFloat(gn(p, 3));
    rn(p, @floatFromInt(numtheory.mod_pow(b, e, m)));
}

fn ring_mod_inv(p: *anyopaque) callconv(.c) void {
    const a: i64 = @intFromFloat(gn(p, 1));
    const m: i64 = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(numtheory.mod_inv(a, m)));
}

fn ring_divisor_count(p: *anyopaque) callconv(.c) void {
    const n: i64 = @intFromFloat(gn(p, 1));
    rn(p, @floatFromInt(numtheory.divisor_count(n)));
}

fn ring_divisor_sum(p: *anyopaque) callconv(.c) void {
    const n: i64 = @intFromFloat(gn(p, 1));
    rn(p, @floatFromInt(numtheory.divisor_sum(n)));
}

fn ring_is_perfect(p: *anyopaque) callconv(.c) void {
    const n: i64 = @intFromFloat(gn(p, 1));
    rn(p, @floatFromInt(numtheory.is_perfect(n)));
}

fn ring_euler_totient(p: *anyopaque) callconv(.c) void {
    const n: i64 = @intFromFloat(gn(p, 1));
    rn(p, @floatFromInt(numtheory.euler_totient(n)));
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = "stzengine_numtheory_gcd", .func = ring_gcd },
    .{ .name = "stzengine_numtheory_lcm", .func = ring_lcm },
    .{ .name = "stzengine_numtheory_is_prime", .func = ring_is_prime },
    .{ .name = "stzengine_numtheory_next_prime", .func = ring_next_prime },
    .{ .name = "stzengine_numtheory_prev_prime", .func = ring_prev_prime },
    .{ .name = "stzengine_numtheory_nth_prime", .func = ring_nth_prime },
    .{ .name = "stzengine_numtheory_factorize", .func = ring_factorize },
    .{ .name = "stzengine_numtheory_factor_at", .func = ring_factor_at },
    .{ .name = "stzengine_numtheory_fibonacci", .func = ring_fibonacci },
    .{ .name = "stzengine_numtheory_is_fibonacci", .func = ring_is_fibonacci },
    .{ .name = "stzengine_numtheory_mod_pow", .func = ring_mod_pow },
    .{ .name = "stzengine_numtheory_mod_inv", .func = ring_mod_inv },
    .{ .name = "stzengine_numtheory_divisor_count", .func = ring_divisor_count },
    .{ .name = "stzengine_numtheory_divisor_sum", .func = ring_divisor_sum },
    .{ .name = "stzengine_numtheory_is_perfect", .func = ring_is_perfect },
    .{ .name = "stzengine_numtheory_euler_totient", .func = ring_euler_totient },
};
