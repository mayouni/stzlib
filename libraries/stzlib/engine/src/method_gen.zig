// Softanza Engine -- Method Generation Rules
//
// Abstractions 3 & 4: CS-suffix auto-dispatch and Q-suffix fluent
// auto-generation. Instead of writing 1,700 CS wrappers and 1,600
// Q wrappers in Ring, the engine stores generation rules and Ring
// queries them at class-load time to auto-register the methods.
//
// The engine does NOT generate Ring code at runtime. Instead, Ring
// calls stz_meta_gen_rules(class) and gets back a list of rules.
// Ring then uses addmethod() once per rule. This moves the DECISION
// of what to generate into native code while keeping Ring's method
// dispatch intact.

const std = @import("std");
const meta = @import("meta.zig");

// A generation rule says: "for class X, method Y can be auto-derived
// from canonical method Z using strategy K."
pub const Rule = struct {
    class: []const u8,
    generated: []const u8,
    canonical: []const u8,
    kind: meta.GenKind,
};

pub const RuleSet = struct {
    rules: std.ArrayListUnmanaged(Rule),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) RuleSet {
        return .{ .rules = .empty, .allocator = allocator };
    }

    pub fn addCS(self: *RuleSet, class: []const u8, non_cs: []const u8, cs_canonical: []const u8) !void {
        try self.rules.append(self.allocator, .{
            .class = class,
            .generated = non_cs,
            .canonical = cs_canonical,
            .kind = .cs,
        });
    }

    pub fn addFluent(self: *RuleSet, class: []const u8, q_name: []const u8, mutating: []const u8) !void {
        try self.rules.append(self.allocator, .{
            .class = class,
            .generated = q_name,
            .canonical = mutating,
            .kind = .fluent_q,
        });
    }

    pub fn addPassive(self: *RuleSet, class: []const u8, passive: []const u8, mutating: []const u8) !void {
        try self.rules.append(self.allocator, .{
            .class = class,
            .generated = passive,
            .canonical = mutating,
            .kind = .passive,
        });
    }

    pub fn rulesForClass(self: *const RuleSet, class: []const u8) []const Rule {
        var start: usize = 0;
        var end: usize = 0;
        var found_start = false;

        for (self.rules.items, 0..) |rule, i| {
            if (std.mem.eql(u8, rule.class, class)) {
                if (!found_start) {
                    start = i;
                    found_start = true;
                }
                end = i + 1;
            }
        }
        if (!found_start) return &.{};
        return self.rules.items[start..end];
    }

    pub fn count(self: *const RuleSet) usize {
        return self.rules.items.len;
    }

    pub fn deinit(self: *RuleSet) void {
        self.rules.deinit(self.allocator);
    }
};

// Pre-built rule sets for stzList methods.
// These capture the patterns that repeat thousands of times in the monolith.
pub fn registerStzListRules(rs: *RuleSet) !void {
    const c = "stzList";

    // ── CS wrappers: Find family ──
    try rs.addCS(c, "FindAllOccurrences", "FindAllOccurrencesCS");
    try rs.addCS(c, "FindAll", "FindAllCS");
    try rs.addCS(c, "Find", "FindCS");
    try rs.addCS(c, "AntiFind", "AntiFindCS");
    try rs.addCS(c, "FindFirst", "FindFirstCS");
    try rs.addCS(c, "FindLast", "FindLastCS");
    try rs.addCS(c, "FindNth", "FindNthCS");
    try rs.addCS(c, "FindNOccurrences", "FindNOccurrencesCS");
    try rs.addCS(c, "FindGivenOccurrences", "FindGivenOccurrencesCS");
    try rs.addCS(c, "FindMany", "FindManyCS");
    try rs.addCS(c, "FindAllExceptFirst", "FindAllExceptFirstCS");
    try rs.addCS(c, "FindAllExceptLast", "FindAllExceptLastCS");
    try rs.addCS(c, "NumberOfOccurrence", "NumberOfOccurrenceCS");
    try rs.addCS(c, "FindNextNthOccurrence", "FindNextNthOccurrenceCS");
    try rs.addCS(c, "FindNextOccurrence", "FindNextOccurrenceCS");
    try rs.addCS(c, "FindPreviousNthOccurrence", "FindPreviousNthOccurrenceCS");
    try rs.addCS(c, "FindPreviousOccurrence", "FindPreviousOccurrenceCS");
    try rs.addCS(c, "Contains", "ContainsCS");
    try rs.addCS(c, "ContainsMany", "ContainsManyCS");

    // ── CS wrappers: Replace family ──
    try rs.addCS(c, "ReplaceAllOccurrences", "ReplaceAllOccurrencesCS");
    try rs.addCS(c, "ReplaceAll", "ReplaceAllCS");
    try rs.addCS(c, "Replace", "ReplaceCS");
    try rs.addCS(c, "ReplaceNthOccurrence", "ReplaceNthOccurrenceCS");
    try rs.addCS(c, "ReplaceFirstOccurrence", "ReplaceFirstOccurrenceCS");
    try rs.addCS(c, "ReplaceLastOccurrence", "ReplaceLastOccurrenceCS");
    try rs.addCS(c, "ReplaceMany", "ReplaceManyCS");
    try rs.addCS(c, "ReplaceSection", "ReplaceSectionCS");

    // ── CS wrappers: Remove family ──
    try rs.addCS(c, "RemoveAll", "RemoveAllCS");
    try rs.addCS(c, "Remove", "RemoveCS");
    try rs.addCS(c, "RemoveMany", "RemoveManyCS");
    try rs.addCS(c, "RemoveNthOccurrence", "RemoveNthOccurrenceCS");
    try rs.addCS(c, "RemoveFirstOccurrence", "RemoveFirstOccurrenceCS");
    try rs.addCS(c, "RemoveLastOccurrence", "RemoveLastOccurrenceCS");

    // ── CS wrappers: Duplicate family ──
    try rs.addCS(c, "FindDuplicates", "FindDuplicatesCS");
    try rs.addCS(c, "DuplicatedItems", "DuplicatedItemsCS");
    try rs.addCS(c, "RemoveDuplicates", "RemoveDuplicatesCS");
    try rs.addCS(c, "WithoutDuplication", "WithoutDuplicationCS");
    try rs.addCS(c, "HasDuplicates", "HasDuplicatesCS");
    try rs.addCS(c, "NumberOfDuplicates", "NumberOfDuplicatesCS");
    try rs.addCS(c, "FindDuplicatesOf", "FindDuplicatesOfCS");
    try rs.addCS(c, "UniqueItems", "UniqueItemsCS");
    try rs.addCS(c, "FindNonDuplicatedItems", "FindNonDuplicatedItemsCS");

    // ── CS wrappers: Equality/Bounds ──
    try rs.addCS(c, "IsEqualTo", "IsEqualToCS");
    try rs.addCS(c, "Section", "SectionCS");
    try rs.addCS(c, "AreBoundsOf", "AreBoundsOfCS");
    try rs.addCS(c, "IsBoundedBy", "IsBoundedByCS");
    try rs.addCS(c, "RemoveBounds", "RemoveBoundsCS");
    try rs.addCS(c, "HasRepeatedLeadingItems", "HasRepeatedLeadingItemsCS");

    // ── CS wrappers: Content ──
    try rs.addCS(c, "Content", "ContentCS");

    // ── Q (fluent) wrappers ──
    try rs.addFluent(c, "FlattenQ", "Flatten");
    try rs.addFluent(c, "SortQ", "Sort");
    try rs.addFluent(c, "SortInAscendingQ", "SortInAscending");
    try rs.addFluent(c, "SortInDescendingQ", "SortInDescending");
    try rs.addFluent(c, "SortByQ", "SortBy");
    try rs.addFluent(c, "ReverseQ", "Reverse");
    try rs.addFluent(c, "UpdateQ", "Update");
    try rs.addFluent(c, "AddItemQ", "AddItem");
    try rs.addFluent(c, "InsertQ", "Insert");
    try rs.addFluent(c, "RemoveAllCSQ", "RemoveAllCS");
    try rs.addFluent(c, "RemoveCSQ", "RemoveCS");
    try rs.addFluent(c, "ReplaceAllCSQ", "ReplaceAllCS");
    try rs.addFluent(c, "ReplaceCSQ", "ReplaceCS");
    try rs.addFluent(c, "RemoveDuplicatesCSQ", "RemoveDuplicatesCS");
    try rs.addFluent(c, "RemoveDuplicatesQ", "RemoveDuplicates");
    try rs.addFluent(c, "RemoveAtQ", "RemoveAt");
    try rs.addFluent(c, "RemoveFirstItemQ", "RemoveFirstItem");
    try rs.addFluent(c, "RemoveLastItemQ", "RemoveLastItem");
    try rs.addFluent(c, "RemoveSectionQ", "RemoveSection");
    try rs.addFluent(c, "RemoveWQ", "RemoveW");
    try rs.addFluent(c, "AssociateWithQ", "AssociateWith");

    // ── Passive (ed-suffix) wrappers ──
    try rs.addPassive(c, "Flattened", "Flatten");
    try rs.addPassive(c, "Sorted", "Sort");
    try rs.addPassive(c, "SortedInAscending", "SortInAscending");
    try rs.addPassive(c, "SortedInDescending", "SortInDescending");
    try rs.addPassive(c, "Reversed", "Reverse");
    try rs.addPassive(c, "Updated", "Update");
    try rs.addPassive(c, "ItemAdded", "AddItem");
    try rs.addPassive(c, "BoundsRemoved", "RemoveBounds");
    try rs.addPassive(c, "AssociatedWith", "AssociateWith");
}

// ─── Tests ───

test "rule set basics" {
    var rs = RuleSet.init(std.testing.allocator);
    defer rs.deinit();

    try rs.addCS("stzList", "Find", "FindCS");
    try rs.addFluent("stzList", "SortQ", "Sort");
    try rs.addPassive("stzList", "Sorted", "Sort");
    try rs.addCS("stzString", "Contains", "ContainsCS");

    try std.testing.expectEqual(@as(usize, 4), rs.count());

    const list_rules = rs.rulesForClass("stzList");
    try std.testing.expectEqual(@as(usize, 3), list_rules.len);
    try std.testing.expectEqual(meta.GenKind.cs, list_rules[0].kind);
    try std.testing.expectEqual(meta.GenKind.fluent_q, list_rules[1].kind);
    try std.testing.expectEqual(meta.GenKind.passive, list_rules[2].kind);

    const str_rules = rs.rulesForClass("stzString");
    try std.testing.expectEqual(@as(usize, 1), str_rules.len);

    const no_rules = rs.rulesForClass("stzNumber");
    try std.testing.expectEqual(@as(usize, 0), no_rules.len);
}

test "stzList rules register" {
    var rs = RuleSet.init(std.testing.allocator);
    defer rs.deinit();

    try registerStzListRules(&rs);

    const rules = rs.rulesForClass("stzList");
    try std.testing.expect(rules.len > 50);
}

test "rule set: empty class returns empty slice" {
    var rs = RuleSet.init(std.testing.allocator);
    defer rs.deinit();

    const rules = rs.rulesForClass("stzAnything");
    try std.testing.expectEqual(@as(usize, 0), rules.len);
}

test "rule set: count starts at zero" {
    var rs = RuleSet.init(std.testing.allocator);
    defer rs.deinit();
    try std.testing.expectEqual(@as(usize, 0), rs.count());
}

test "rule set: CS rule has correct kind" {
    var rs = RuleSet.init(std.testing.allocator);
    defer rs.deinit();

    try rs.addCS("stzString", "Find", "FindCS");
    const rules = rs.rulesForClass("stzString");
    try std.testing.expectEqual(@as(usize, 1), rules.len);
    try std.testing.expectEqual(meta.GenKind.cs, rules[0].kind);
    try std.testing.expectEqualStrings("Find", rules[0].generated);
    try std.testing.expectEqualStrings("FindCS", rules[0].canonical);
}

test "rule set: fluent rule has correct kind" {
    var rs = RuleSet.init(std.testing.allocator);
    defer rs.deinit();

    try rs.addFluent("stzList", "SortQ", "Sort");
    const rules = rs.rulesForClass("stzList");
    try std.testing.expectEqual(meta.GenKind.fluent_q, rules[0].kind);
    try std.testing.expectEqualStrings("SortQ", rules[0].generated);
    try std.testing.expectEqualStrings("Sort", rules[0].canonical);
}

test "rule set: passive rule has correct kind" {
    var rs = RuleSet.init(std.testing.allocator);
    defer rs.deinit();

    try rs.addPassive("stzList", "Sorted", "Sort");
    const rules = rs.rulesForClass("stzList");
    try std.testing.expectEqual(meta.GenKind.passive, rules[0].kind);
}

test "rule set: multiple classes are isolated" {
    var rs = RuleSet.init(std.testing.allocator);
    defer rs.deinit();

    try rs.addCS("stzList", "Find", "FindCS");
    try rs.addCS("stzList", "Contains", "ContainsCS");
    try rs.addCS("stzString", "Replace", "ReplaceCS");
    try rs.addFluent("stzTable", "SortQ", "Sort");

    try std.testing.expectEqual(@as(usize, 4), rs.count());
    try std.testing.expectEqual(@as(usize, 2), rs.rulesForClass("stzList").len);
    try std.testing.expectEqual(@as(usize, 1), rs.rulesForClass("stzString").len);
    try std.testing.expectEqual(@as(usize, 1), rs.rulesForClass("stzTable").len);
    try std.testing.expectEqual(@as(usize, 0), rs.rulesForClass("stzNumber").len);
}

test "stzList rules: CS rules have correct canonical suffix" {
    var rs = RuleSet.init(std.testing.allocator);
    defer rs.deinit();

    try registerStzListRules(&rs);

    const rules = rs.rulesForClass("stzList");
    for (rules) |rule| {
        if (rule.kind == .cs) {
            // Canonical for CS rules should end with "CS"
            try std.testing.expect(std.mem.endsWith(u8, rule.canonical, "CS"));
            // Generated should NOT end with "CS"
            try std.testing.expect(!std.mem.endsWith(u8, rule.generated, "CS"));
        }
    }
}

test "stzList rules: Q rules have correct naming" {
    var rs = RuleSet.init(std.testing.allocator);
    defer rs.deinit();

    try registerStzListRules(&rs);

    const rules = rs.rulesForClass("stzList");
    for (rules) |rule| {
        if (rule.kind == .fluent_q) {
            // Generated Q method should end with "Q"
            try std.testing.expect(std.mem.endsWith(u8, rule.generated, "Q"));
        }
    }
}
