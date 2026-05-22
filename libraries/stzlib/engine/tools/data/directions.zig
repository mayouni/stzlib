pub const Direction = struct { nbr: i32, short_name: []const u8, stz_name: []const u8, description: []const u8 };

pub const directions = [_]Direction{
    .{ .nbr = 0, .short_name = "DirL", .stz_name = "LeftToRight", .description = "Left-to-right" },
    .{ .nbr = 1, .short_name = "DirR", .stz_name = "RightToLeft", .description = "Right-to-left" },
    .{ .nbr = 2, .short_name = "DirEN", .stz_name = "EuropeanNumber", .description = "European Number" },
    .{ .nbr = 3, .short_name = "DirES", .stz_name = "EuropeanNumberSeparator", .description = "European Number Separator" },
    .{ .nbr = 4, .short_name = "DirET", .stz_name = "EuropeanNumberTerminator", .description = "European Number Terminator" },
    .{ .nbr = 5, .short_name = "DirAN", .stz_name = "ArabicNumber", .description = "Arabic Number" },
    .{ .nbr = 6, .short_name = "DirCS", .stz_name = "CommonNumberSeparator", .description = "Common Number Separator" },
    .{ .nbr = 7, .short_name = "DirB", .stz_name = "ParagraphSeparator", .description = "Paragraph Separator" },
    .{ .nbr = 8, .short_name = "DirS", .stz_name = "SectionSeparator", .description = "Section Separator" },
    .{ .nbr = 9, .short_name = "DirWS", .stz_name = "Whitespace", .description = "Whitespace" },
    .{ .nbr = 10, .short_name = "DirON", .stz_name = "OtherNeutrals", .description = "Other Neutrals" },
    .{ .nbr = 11, .short_name = "DirLRE", .stz_name = "LeftToRightEmbedding", .description = "Left-to-right Embedding" },
    .{ .nbr = 12, .short_name = "DirLRO", .stz_name = "LeftToRightOverride", .description = "Left-to-right Override" },
    .{ .nbr = 13, .short_name = "DirAL", .stz_name = "RightToLeftArabic", .description = "Right-to-left Arabic" },
    .{ .nbr = 14, .short_name = "DirRLE", .stz_name = "RightToLeftEmbedding", .description = "Right-to-left Embedding" },
    .{ .nbr = 15, .short_name = "DirRLO", .stz_name = "RightToLeftOverride", .description = "Right-to-left Override" },
    .{ .nbr = 16, .short_name = "DirPDF", .stz_name = "PopDirectionalFormat", .description = "Pop Directional Format" },
    .{ .nbr = 17, .short_name = "DirNSM", .stz_name = "NonSpacingMark", .description = "Non-Spacing Mark" },
    .{ .nbr = 18, .short_name = "DirBN", .stz_name = "BoundaryNeutral", .description = "Boundary Neutral" },
};
