pub const MandarinNumber = struct { symbol: []const u8, value: i32 };

pub const mandarin_numbers = [_]MandarinNumber{
    .{ .symbol = "\xe3\x80\x87", .value = 0 },
    .{ .symbol = "\xe4\xb8\x80", .value = 1 },
    .{ .symbol = "\xe4\xba\x8c", .value = 2 },
    .{ .symbol = "\xe4\xb8\x89", .value = 3 },
    .{ .symbol = "\xe5\x9b\x9b", .value = 4 },
    .{ .symbol = "\xe4\xba\x94", .value = 5 },
    .{ .symbol = "\xe5\x85\xad", .value = 6 },
    .{ .symbol = "\xe4\xb8\x83", .value = 7 },
    .{ .symbol = "\xe5\x85\xab", .value = 8 },
    .{ .symbol = "\xe4\xb9\x9d", .value = 9 },
    .{ .symbol = "\xe5\x8d\x81", .value = 10 },
    .{ .symbol = "\xe7\x99\xbe", .value = 100 },
    .{ .symbol = "\xe5\x8d\x83", .value = 1000 },
    .{ .symbol = "\xe4\xb8\x87", .value = 10000 },
};
