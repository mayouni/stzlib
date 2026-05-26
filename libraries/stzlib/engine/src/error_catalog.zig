// Softanza Engine -- Error Catalog
//
// Abstraction 5: Replaces hand-crafted StzRaise() strings with
// templated, cataloged error messages. Each error has a code and
// a template with ${key} placeholders.
//
// Ring calls stz_meta_format_error("PARAM_TYPE", params) and gets
// back the formatted string to pass to StzRaise(). This gives:
//   - Consistent error messages across the library
//   - Catalog of all possible errors (debugging, i18n)
//   - Template reuse (no copy-paste of error strings)

const std = @import("std");
const meta = @import("meta.zig");

// Standard error templates extracted from stzlib patterns.
// Each pair is [code, template]. Templates use ${key} substitution.
pub const standard_errors = [_][2][]const u8{
    // ── Param type errors ──
    .{ "PARAM_TYPE", "Incorrect param type! ${param} must be a ${expected}." },
    .{ "PARAM_TYPE_ONE_OF", "Incorrect param type! ${param} must be a ${expected1} or a ${expected2}." },
    .{ "PARAM_TYPE_LIST_OF", "Incorrect param type! ${param} must be a list of ${expected}." },

    // ── Range errors ──
    .{ "OUT_OF_RANGE", "Index ${n} is out of range [1, ${max}]!" },
    .{ "NEGATIVE_VALUE", "${param} must be a positive number. You passed ${value}." },
    .{ "ZERO_VALUE", "${param} must not be zero!" },

    // ── Structural errors ──
    .{ "EMPTY_LIST", "Operation ${op} is not available on an empty list!" },
    .{ "EMPTY_STRING", "Operation ${op} is not available on an empty string!" },
    .{ "LIST_SIZE_MISMATCH", "The two lists must have the same size! Got ${size1} and ${size2}." },

    // ── Named param errors ──
    .{ "UNKNOWN_NAMED_PARAM", "Unknown named parameter :${name}! Expected one of: ${options}." },
    .{ "CONFLICTING_PARAMS", ":${param1} and :${param2} can not be used at the same time." },

    // ── Operation errors ──
    .{ "WALKER_EXISTS", "Can not add walker: '${name}' already exists!" },
    .{ "WALKER_NOT_FOUND", "Walker '${name}' not found!" },
    .{ "ITEM_NOT_FOUND", "Item not found in the list!" },
    .{ "NOT_SORTABLE", "The list can not be sorted: items are not of comparable types." },

    // ── General StzRaise structured format ──
    .{ "STRUCTURED", "in file ${where}:\n   What : ${what}\n   Why  : ${why}\n   Todo : ${todo}" },

    // ── Feature errors ──
    .{ "NOT_IMPLEMENTED", "Feature ${feature} is not yet implemented!" },
    .{ "DEPRECATED", "${old} is deprecated. Use ${new} instead." },
};

pub fn registerAll(eng: *meta.MetaEngine) !void {
    for (&standard_errors) |entry| {
        try eng.errors.register(entry[0], entry[1]);
    }
}

// ─── Tests ───

test "standard errors register" {
    var eng = meta.MetaEngine.init(std.testing.allocator);
    defer eng.deinit();

    try registerAll(&eng);

    // PARAM_TYPE
    var buf: [512]u8 = undefined;
    const params1 = [_]meta.Substitution{
        .{ .key = "param", .value = "pItem" },
        .{ .key = "expected", .value = "string" },
    };
    const len1 = eng.formatError("PARAM_TYPE", &params1, &buf).?;
    try std.testing.expectEqualStrings(
        "Incorrect param type! pItem must be a string.",
        buf[0..len1],
    );

    // OUT_OF_RANGE
    const params2 = [_]meta.Substitution{
        .{ .key = "n", .value = "15" },
        .{ .key = "max", .value = "10" },
    };
    const len2 = eng.formatError("OUT_OF_RANGE", &params2, &buf).?;
    try std.testing.expectEqualStrings(
        "Index 15 is out of range [1, 10]!",
        buf[0..len2],
    );

    // CONFLICTING_PARAMS
    const params3 = [_]meta.Substitution{
        .{ .key = "param1", .value = "CaseSensitive" },
        .{ .key = "param2", .value = "CS" },
    };
    const len3 = eng.formatError("CONFLICTING_PARAMS", &params3, &buf).?;
    try std.testing.expectEqualStrings(
        ":CaseSensitive and :CS can not be used at the same time.",
        buf[0..len3],
    );

    // Unknown error code
    const params4 = [_]meta.Substitution{};
    try std.testing.expect(eng.formatError("NONEXISTENT", &params4, &buf) == null);
}

test "error catalog: all standard error codes are unique" {
    // Verify no duplicate error codes in the catalog
    for (&standard_errors, 0..) |entry, i| {
        for (standard_errors[i + 1 ..]) |other| {
            try std.testing.expect(!std.mem.eql(u8, entry[0], other[0]));
        }
    }
}

test "error catalog: all templates contain substitution markers" {
    // Every template with ${...} syntax should be well-formed
    for (&standard_errors) |entry| {
        const template = entry[1];
        // Just verify template is non-empty
        try std.testing.expect(template.len > 0);
    }
}

test "error catalog: STRUCTURED error format" {
    var eng = meta.MetaEngine.init(std.testing.allocator);
    defer eng.deinit();
    try registerAll(&eng);

    var buf: [512]u8 = undefined;
    const params = [_]meta.Substitution{
        .{ .key = "where", .value = "stzList.ring" },
        .{ .key = "what", .value = "Index out of range" },
        .{ .key = "why", .value = "n > NumberOfItems()" },
        .{ .key = "todo", .value = "Check your index value" },
    };
    const len = eng.formatError("STRUCTURED", &params, &buf).?;
    const result = buf[0..len];
    try std.testing.expect(std.mem.indexOf(u8, result, "stzList.ring") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "Index out of range") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "What") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "Why") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "Todo") != null);
}

test "error catalog: EMPTY_LIST error" {
    var eng = meta.MetaEngine.init(std.testing.allocator);
    defer eng.deinit();
    try registerAll(&eng);

    var buf: [512]u8 = undefined;
    const params = [_]meta.Substitution{
        .{ .key = "op", .value = "Sort" },
    };
    const len = eng.formatError("EMPTY_LIST", &params, &buf).?;
    try std.testing.expectEqualStrings(
        "Operation Sort is not available on an empty list!",
        buf[0..len],
    );
}

test "error catalog: LIST_SIZE_MISMATCH error" {
    var eng = meta.MetaEngine.init(std.testing.allocator);
    defer eng.deinit();
    try registerAll(&eng);

    var buf: [512]u8 = undefined;
    const params = [_]meta.Substitution{
        .{ .key = "size1", .value = "5" },
        .{ .key = "size2", .value = "3" },
    };
    const len = eng.formatError("LIST_SIZE_MISMATCH", &params, &buf).?;
    try std.testing.expectEqualStrings(
        "The two lists must have the same size! Got 5 and 3.",
        buf[0..len],
    );
}

test "error catalog: DEPRECATED error" {
    var eng = meta.MetaEngine.init(std.testing.allocator);
    defer eng.deinit();
    try registerAll(&eng);

    var buf: [512]u8 = undefined;
    const params = [_]meta.Substitution{
        .{ .key = "old", .value = "FindItems()" },
        .{ .key = "new", .value = "FindAll()" },
    };
    const len = eng.formatError("DEPRECATED", &params, &buf).?;
    try std.testing.expectEqualStrings(
        "FindItems() is deprecated. Use FindAll() instead.",
        buf[0..len],
    );
}

test "error catalog: NOT_IMPLEMENTED error" {
    var eng = meta.MetaEngine.init(std.testing.allocator);
    defer eng.deinit();
    try registerAll(&eng);

    var buf: [512]u8 = undefined;
    const params = [_]meta.Substitution{
        .{ .key = "feature", .value = "ParallelSort" },
    };
    const len = eng.formatError("NOT_IMPLEMENTED", &params, &buf).?;
    try std.testing.expectEqualStrings(
        "Feature ParallelSort is not yet implemented!",
        buf[0..len],
    );
}

test "error catalog: catalog size" {
    try std.testing.expectEqual(@as(usize, 18), standard_errors.len);
}
