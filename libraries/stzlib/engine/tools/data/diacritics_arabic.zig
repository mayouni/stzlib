pub const ArabicDiacritic = struct { unicode: i32, without: i32, description: []const u8 };

pub const diacritics_arabic = [_]ArabicDiacritic{
    .{ .unicode = 1571, .without = 1569, .description = "Arabic Hamza Kat3ia ontop of Aleef" },
    .{ .unicode = 1572, .without = 1569, .description = "Arabic Hamza Kat3ia ontop of Waw" },
    .{ .unicode = 1573, .without = 1569, .description = "Arabic Hamza Kat3ia under Aleef" },
    .{ .unicode = 1574, .without = 1569, .description = "Arabic Hamza Kat3ia ontop of Waw" },
    .{ .unicode = 1611, .without = 0, .description = "Arabic Tinween of Fat7ah" },
    .{ .unicode = 1612, .without = 0, .description = "Arabic Tinween of Dhammah" },
    .{ .unicode = 1613, .without = 0, .description = "Arabic Tinween of Kasrah" },
    .{ .unicode = 1614, .without = 0, .description = "Arabic Fat7ah" },
    .{ .unicode = 1615, .without = 0, .description = "Arabic Dhammah" },
    .{ .unicode = 1616, .without = 0, .description = "Arabic Kasrah" },
    .{ .unicode = 1618, .without = 0, .description = "Arabic Sukoon" },
    .{ .unicode = 1617, .without = 0, .description = "Arabic Shaddah" },
    .{ .unicode = 1648, .without = 0, .description = "Arabic small Alif Mamdoodah" },
    .{ .unicode = 1649, .without = 1575, .description = "Arabic Hamzah Wasliah Madhmoomah" },
    .{ .unicode = 1570, .without = 1575, .description = "Arabic Alif Mamdoodah" },
};
