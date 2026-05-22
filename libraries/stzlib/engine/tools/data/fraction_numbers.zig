pub const FractionNumber = struct { fraction: []const u8, unicode: i32 };

pub const fraction_numbers = [_]FractionNumber{
    .{ .fraction = "1/4", .unicode = 188 },
    .{ .fraction = "1/2", .unicode = 189 },
    .{ .fraction = "3/4", .unicode = 190 },
    .{ .fraction = "1/7", .unicode = 8528 },
    .{ .fraction = "1/9", .unicode = 8529 },
    .{ .fraction = "1/10", .unicode = 8530 },
    .{ .fraction = "1/3", .unicode = 8531 },
    .{ .fraction = "2/3", .unicode = 8532 },
    .{ .fraction = "1/5", .unicode = 8533 },
    .{ .fraction = "2/5", .unicode = 8534 },
    .{ .fraction = "3/5", .unicode = 8535 },
    .{ .fraction = "4/5", .unicode = 8536 },
    .{ .fraction = "1/6", .unicode = 8537 },
    .{ .fraction = "5/6", .unicode = 8538 },
    .{ .fraction = "1/8", .unicode = 8539 },
    .{ .fraction = "3/8", .unicode = 8540 },
    .{ .fraction = "5/8", .unicode = 8541 },
    .{ .fraction = "7/8", .unicode = 8542 },
    .{ .fraction = "1/", .unicode = 8543 },
    .{ .fraction = "0/3", .unicode = 8585 },
};
