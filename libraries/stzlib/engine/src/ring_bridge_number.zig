const number = @import("number.zig");
const R = @import("ring_api.zig");

const g = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring;
const rs2 = R.ring_vm_api_retstring2;

// Shadow the real cpointer functions: store/resolve via handle table.
fn rcp(p: *anyopaque, ptr: ?*anyopaque, _: [*:0]const u8) void {
    R.retHandle(p, ptr);
}

fn gcp(p: *anyopaque, n: c_int, _: [*:0]const u8) ?*anyopaque {
    return R.getHandle(p, n);
}

const H: [*:0]const u8 = "StzBigIntHandle";

fn getH(p: *anyopaque, n: c_int) ?*const number.StzBigInt {
    const ptr = gcp(p, n, H);
    if (ptr) |raw| return @ptrCast(@alignCast(raw));
    return null;
}

// Lifecycle
fn ring_New(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(number.stz_bigint_new()), H);
}
fn ring_FromInt(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(number.stz_bigint_from_int(@intFromFloat(g(p, 1)))), H);
}
fn ring_FromString(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(number.stz_bigint_from_string(gs(p, 1), @intCast(gss(p, 1)))), H);
}
fn ring_Free(p: *anyopaque) callconv(.c) void {
    const raw = R.releaseHandle(p, 1);
    if (raw) |ptr| {
        const bi: ?*number.StzBigInt = @ptrCast(@alignCast(ptr));
        number.stz_bigint_free(bi);
    }
}

// Arithmetic
fn ring_Add(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(number.stz_bigint_add(getH(p, 1), getH(p, 2))), H);
}
fn ring_Sub(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(number.stz_bigint_sub(getH(p, 1), getH(p, 2))), H);
}
fn ring_Mul(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(number.stz_bigint_mul(getH(p, 1), getH(p, 2))), H);
}
fn ring_Div(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(number.stz_bigint_div(getH(p, 1), getH(p, 2))), H);
}
fn ring_Mod(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(number.stz_bigint_mod(getH(p, 1), getH(p, 2))), H);
}
fn ring_Negate(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(number.stz_bigint_negate(getH(p, 1))), H);
}
fn ring_Abs(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(number.stz_bigint_abs(getH(p, 1))), H);
}
fn ring_Pow(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(number.stz_bigint_pow(getH(p, 1), @intFromFloat(g(p, 2)))), H);
}

// Comparison
fn ring_Compare(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(number.stz_bigint_compare(getH(p, 1), getH(p, 2))));
}
fn ring_Equals(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(number.stz_bigint_equals(getH(p, 1), getH(p, 2))));
}
fn ring_IsZero(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(number.stz_bigint_is_zero(getH(p, 1))));
}
fn ring_IsNegative(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(number.stz_bigint_is_negative(getH(p, 1))));
}

// Conversion
fn ring_ToInt(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(number.stz_bigint_to_int(getH(p, 1))));
}
fn ring_ToString(p: *anyopaque) callconv(.c) void {
    var buf: [4096]u8 = undefined;
    const len = number.stz_bigint_to_string(getH(p, 1), &buf, 4096);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs(p, "0");
}
fn ring_ToStringBase(p: *anyopaque) callconv(.c) void {
    var buf: [4096]u8 = undefined;
    const len = number.stz_bigint_to_string_base(getH(p, 1), @intFromFloat(g(p, 2)), &buf, 4096);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs(p, "0");
}
fn ring_Clone(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(number.stz_bigint_clone(getH(p, 1))), H);
}
fn ring_BitCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(number.stz_bigint_bit_count(getH(p, 1))));
}

// Utility functions (non-bigint)
fn ring_GCD(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(number.stz_number_gcd(@intFromFloat(g(p, 1)), @intFromFloat(g(p, 2)))));
}
fn ring_LCM(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(number.stz_number_lcm(@intFromFloat(g(p, 1)), @intFromFloat(g(p, 2)))));
}
fn ring_IsPrime(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(number.stz_number_is_prime(@intFromFloat(g(p, 1)))));
}
fn ring_Factorial(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(number.stz_number_factorial(@intFromFloat(g(p, 1)))), H);
}
fn ring_Fibonacci(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(number.stz_number_fibonacci(@intFromFloat(g(p, 1)))), H);
}
fn ring_IsPerfect(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(number.stz_number_is_perfect(@intFromFloat(g(p, 1)))));
}
fn ring_DigitCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(number.stz_number_digit_count(@intFromFloat(g(p, 1)))));
}
fn ring_DigitSum(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(number.stz_number_digit_sum(@intFromFloat(g(p, 1)))));
}
fn ring_ReverseDigits(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(number.stz_number_reverse_digits(@intFromFloat(g(p, 1)))));
}
fn ring_IsPalindrome(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(number.stz_number_is_palindrome(@intFromFloat(g(p, 1)))));
}

// BigInt from string with base
fn ring_FromStringBase(p: *anyopaque) callconv(.c) void {
    rcp(p, @ptrCast(number.stz_bigint_from_string_base(gs(p, 1), @intCast(gss(p, 1)), @intFromFloat(g(p, 2)))), H);
}

// Integer base conversion
fn ring_ToBase(p: *anyopaque) callconv(.c) void {
    var buf: [4096]u8 = undefined;
    const len = number.stz_number_to_base(@intFromFloat(g(p, 1)), @intFromFloat(g(p, 2)), &buf, 4096);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs(p, "0");
}
fn ring_FromBase(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(number.stz_number_from_base(gs(p, 1), @intCast(gss(p, 1)), @intFromFloat(g(p, 2)))));
}

// Bitwise
fn ring_BitwiseAnd(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(number.stz_number_bitwise_and(@intFromFloat(g(p, 1)), @intFromFloat(g(p, 2)))));
}
fn ring_BitwiseOr(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(number.stz_number_bitwise_or(@intFromFloat(g(p, 1)), @intFromFloat(g(p, 2)))));
}
fn ring_BitwiseXor(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(number.stz_number_bitwise_xor(@intFromFloat(g(p, 1)), @intFromFloat(g(p, 2)))));
}
fn ring_BitwiseNot(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(number.stz_number_bitwise_not(@intFromFloat(g(p, 1)))));
}
fn ring_BitwiseLShift(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(number.stz_number_bitwise_lshift(@intFromFloat(g(p, 1)), @intFromFloat(g(p, 2)))));
}
fn ring_BitwiseRShift(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(number.stz_number_bitwise_rshift(@intFromFloat(g(p, 1)), @intFromFloat(g(p, 2)))));
}

// Scientific notation
fn ring_ToScientific(p: *anyopaque) callconv(.c) void {
    var buf: [128]u8 = undefined;
    const len = number.stz_number_to_scientific(g(p, 1), &buf, 128);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs(p, "0e+00");
}
fn ring_FromScientific(p: *anyopaque) callconv(.c) void {
    rn(p, number.stz_number_from_scientific(gs(p, 1), @intCast(gss(p, 1))));
}

// Predicates
fn ring_IsEven(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(number.stz_number_is_even(@intFromFloat(g(p, 1)))));
}
fn ring_IsOdd(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(number.stz_number_is_odd(@intFromFloat(g(p, 1)))));
}
fn ring_IsArmstrong(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(number.stz_number_is_armstrong(@intFromFloat(g(p, 1)))));
}
fn ring_IsAbundant(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(number.stz_number_is_abundant(@intFromFloat(g(p, 1)))));
}
fn ring_IsDeficient(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(number.stz_number_is_deficient(@intFromFloat(g(p, 1)))));
}

pub const regs = [_]R.Reg{
    .{ .name = "stzenginebigintfromint", .func = &ring_FromInt },
    .{ .name = "stzenginebigintfromstring", .func = &ring_FromString },
    .{ .name = "stzenginebigintfree", .func = &ring_Free },
    .{ .name = "stzenginebigintadd", .func = &ring_Add },
    .{ .name = "stzenginebigintsub", .func = &ring_Sub },
    .{ .name = "stzenginebigintmul", .func = &ring_Mul },
    .{ .name = "stzenginebigintdiv", .func = &ring_Div },
    .{ .name = "stzenginebigintmod", .func = &ring_Mod },
    .{ .name = "stzenginebigintnegate", .func = &ring_Negate },
    .{ .name = "stzenginebigintabs", .func = &ring_Abs },
    .{ .name = "stzenginebigintpow", .func = &ring_Pow },
    .{ .name = "stzenginebigintcompare", .func = &ring_Compare },
    .{ .name = "stzenginebigintequals", .func = &ring_Equals },
    .{ .name = "stzenginebigintiszero", .func = &ring_IsZero },
    .{ .name = "stzenginebigintis" ++ "negative", .func = &ring_IsNegative },
    .{ .name = "stzenginebigintoint", .func = &ring_ToInt },
    .{ .name = "stzenginebiginttostring", .func = &ring_ToString },
    .{ .name = "stzenginebigintostringbase", .func = &ring_ToStringBase },
    .{ .name = "stzenginebigintclone", .func = &ring_Clone },
    .{ .name = "stzenginebigintbitcount", .func = &ring_BitCount },
    .{ .name = "stzenginenumbergcd", .func = &ring_GCD },
    .{ .name = "stzenginenumberlcm", .func = &ring_LCM },
    .{ .name = "stzenginenumberisprime", .func = &ring_IsPrime },
    .{ .name = "stzenginenumberfactorial", .func = &ring_Factorial },
    .{ .name = "stzenginenumberfibonacci", .func = &ring_Fibonacci },
    .{ .name = "stzenginenumberisperfect", .func = &ring_IsPerfect },
    .{ .name = "stzenginenumberdigitcount", .func = &ring_DigitCount },
    .{ .name = "stzenginenumberdigitsum", .func = &ring_DigitSum },
    .{ .name = "stzenginenumberreversedigits", .func = &ring_ReverseDigits },
    .{ .name = "stzenginenumberispalindrome", .func = &ring_IsPalindrome },
    .{ .name = "stzenginebigintfromstringbase", .func = &ring_FromStringBase },
    .{ .name = "stzenginenumbertobase", .func = &ring_ToBase },
    .{ .name = "stzenginenumberfrombase", .func = &ring_FromBase },
    .{ .name = "stzenginenumberbitwiseand", .func = &ring_BitwiseAnd },
    .{ .name = "stzenginenumberbitwiseor", .func = &ring_BitwiseOr },
    .{ .name = "stzenginenumberbitwisexor", .func = &ring_BitwiseXor },
    .{ .name = "stzenginenumberbitwisenot", .func = &ring_BitwiseNot },
    .{ .name = "stzenginenumberbitwiselshift", .func = &ring_BitwiseLShift },
    .{ .name = "stzenginenumberbitwisershift", .func = &ring_BitwiseRShift },
    .{ .name = "stzenginenumbertoscientific", .func = &ring_ToScientific },
    .{ .name = "stzenginenumberfromscientific", .func = &ring_FromScientific },
    .{ .name = "stzenginenumberiseven", .func = &ring_IsEven },
    .{ .name = "stzenginenumberisodd", .func = &ring_IsOdd },
    .{ .name = "stzenginenumberisarmstrong", .func = &ring_IsArmstrong },
    .{ .name = "stzenginenumberisabundant", .func = &ring_IsAbundant },
    .{ .name = "stzenginenumberisdeficient", .func = &ring_IsDeficient },
};

pub fn ringlib_init(pRingState: ?*anyopaque) callconv(.c) void {
    if (pRingState) |state| R.registerAll(state, &regs);
}
