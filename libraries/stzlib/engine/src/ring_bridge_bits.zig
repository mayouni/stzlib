const bits = @import("bits.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs2 = R.ring_vm_api_retstring2;
const rs = R.ring_vm_api_retstring;

fn ring_BitsPopcount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(bits.bits_popcount(@intFromFloat(gn(p, 1)))));
}

fn ring_BitsLeadingZeros(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(bits.bits_leading_zeros(@intFromFloat(gn(p, 1)))));
}

fn ring_BitsTrailingZeros(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(bits.bits_trailing_zeros(@intFromFloat(gn(p, 1)))));
}

fn ring_BitsParity(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(bits.bits_parity(@intFromFloat(gn(p, 1)))));
}

fn ring_BitsTest(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(bits.bits_test(@intFromFloat(gn(p, 1)), @intFromFloat(gn(p, 2)))));
}

fn ring_BitsHighestSet(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(bits.bits_highest_set(@intFromFloat(gn(p, 1)))));
}

fn ring_BitsLowestSet(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(bits.bits_lowest_set(@intFromFloat(gn(p, 1)))));
}

fn ring_BitsSet(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(bits.bits_set(@intFromFloat(gn(p, 1)), @intFromFloat(gn(p, 2)))));
}

fn ring_BitsClear(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(bits.bits_clear(@intFromFloat(gn(p, 1)), @intFromFloat(gn(p, 2)))));
}

fn ring_BitsToggle(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(bits.bits_toggle(@intFromFloat(gn(p, 1)), @intFromFloat(gn(p, 2)))));
}

fn ring_BitsRotateLeft(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(bits.bits_rotate_left(@intFromFloat(gn(p, 1)), @intFromFloat(gn(p, 2)))));
}

fn ring_BitsRotateRight(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(bits.bits_rotate_right(@intFromFloat(gn(p, 1)), @intFromFloat(gn(p, 2)))));
}

fn ring_BitsReverse(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(bits.bits_reverse(@intFromFloat(gn(p, 1)))));
}

fn ring_BitsByteSwap(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(bits.bits_byte_swap(@intFromFloat(gn(p, 1)))));
}

fn ring_BitsExtract(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(bits.bits_extract(@intFromFloat(gn(p, 1)), @intFromFloat(gn(p, 2)), @intFromFloat(gn(p, 3)))));
}

fn ring_BitsDeposit(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(bits.bits_deposit(@intFromFloat(gn(p, 1)), @intFromFloat(gn(p, 2)), @intFromFloat(gn(p, 3)), @intFromFloat(gn(p, 4)))));
}

fn ring_BitsPopcountBytes(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(bits.bits_count_ones_in_bytes(ptr, len)));
}

fn ring_BitsHammingDistance(p: *anyopaque) callconv(.c) void {
    const a_ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const a_len: usize = @intCast(gss(p, 1));
    const b_ptr: [*]const u8 = @ptrCast(gs(p, 2));
    const b_len: usize = @intCast(gss(p, 2));
    rn(p, @floatFromInt(bits.bits_hamming_distance(a_ptr, a_len, b_ptr, b_len)));
}

fn ring_BitsToBinaryString(p: *anyopaque) callconv(.c) void {
    var buf: [64]u8 = undefined;
    const len = bits.bits_to_binary_string(@intFromFloat(gn(p, 1)), &buf, 64);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs(p, @constCast(""));
}

fn ring_BitsFromBinaryString(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(bits.bits_from_binary_string(ptr, len)));
}

const regs = [_]R.Reg{
    .{ .name = "stzenginebitspopccount", .func = ring_BitsPopcount },
    .{ .name = "stzenginebitsleadingzeros", .func = ring_BitsLeadingZeros },
    .{ .name = "stzenginebitstrailingzeros", .func = ring_BitsTrailingZeros },
    .{ .name = "stzenginebitsparity", .func = ring_BitsParity },
    .{ .name = "stzenginebitstest", .func = ring_BitsTest },
    .{ .name = "stzenginebitshighestset", .func = ring_BitsHighestSet },
    .{ .name = "stzenginebitslowestset", .func = ring_BitsLowestSet },
    .{ .name = "stzenginebitsset", .func = ring_BitsSet },
    .{ .name = "stzenginebitssclear", .func = ring_BitsClear },
    .{ .name = "stzenginebitstoggle", .func = ring_BitsToggle },
    .{ .name = "stzenginebitsrotateleft", .func = ring_BitsRotateLeft },
    .{ .name = "stzenginebitsrotateright", .func = ring_BitsRotateRight },
    .{ .name = "stzenginebitsreverse", .func = ring_BitsReverse },
    .{ .name = "stzenginebitsbyteswap", .func = ring_BitsByteSwap },
    .{ .name = "stzenginebitsextract", .func = ring_BitsExtract },
    .{ .name = "stzenginebitsdeposit", .func = ring_BitsDeposit },
    .{ .name = "stzenginebitspopcountbytes", .func = ring_BitsPopcountBytes },
    .{ .name = "stzenginebitshammingdistance", .func = ring_BitsHammingDistance },
    .{ .name = "stzenginebitstobinarystring", .func = ring_BitsToBinaryString },
    .{ .name = "stzenginebitsfrombinarystring", .func = ring_BitsFromBinaryString },
};

pub fn registerAll(state: *anyopaque) void {
    R.registerAll(state, &regs);
}
