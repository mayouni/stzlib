// Softanza Engine -- Meta Layer
//
// Data structures for the seven cross-cutting abstractions that
// eliminate ~25,000 lines of boilerplate from Ring-side code:
//
//   1. Param validation    -- type checks + named-param unwrapping
//   2. Named param registry -- replaces 1,566 IsXxxNamedParam() methods
//   3. CS suffix dispatch   -- auto-generates non-CS wrappers
//   4. Q suffix dispatch    -- auto-generates fluent-return wrappers
//   5. Error catalog        -- templated, cataloged error messages
//   6. Alias engine         -- replaces addmethod() init loops
//   7. History tracking     -- automatic state snapshots on mutation
//
// Ring calls these through FFI after ringlib_init registers them.
// The engine stores registration data in comptime-sized arenas
// and serves lookups in O(1) via hash maps.

const std = @import("std");

// ─── Abstraction 1: Param Validation ───

pub const ParamType = enum(u8) {
    any,
    string,
    number,
    list,
    object,
    number_or_string,
    string_or_list,
    list_or_object,
};

pub const ParamSpec = struct {
    name: [*:0]const u8,
    expected_type: ParamType,
    named_aliases: [*]const [*:0]const u8,
    named_count: u16,
    has_default: bool,
    default_number: f64,

    pub fn matchesAlias(self: *const ParamSpec, candidate: [*:0]const u8) bool {
        const cand = std.mem.span(candidate);
        for (0..self.named_count) |i| {
            if (std.ascii.eqlIgnoreCase(cand, std.mem.span(self.named_aliases[i]))) {
                return true;
            }
        }
        return false;
    }
};

pub const MethodParamSpec = struct {
    method_name: [*:0]const u8,
    params: [*]const ParamSpec,
    param_count: u16,
};

// ─── Abstraction 2: Named Param Registry ───

pub const NamedParamEntry = struct {
    keyword: [*:0]const u8,
};

pub const NamedParamRegistry = struct {
    entries: std.StringHashMapUnmanaged(void),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) NamedParamRegistry {
        return .{
            .entries = .empty,
            .allocator = allocator,
        };
    }

    pub fn register(self: *NamedParamRegistry, keyword: []const u8) !void {
        const owned = try self.allocator.dupe(u8, keyword);
        try self.entries.put(self.allocator, owned, {});
    }

    pub fn isRegistered(self: *const NamedParamRegistry, keyword: []const u8) bool {
        return self.entries.contains(keyword);
    }

    pub fn deinit(self: *NamedParamRegistry) void {
        var it = self.entries.keyIterator();
        while (it.next()) |key| {
            self.allocator.free(key.*);
        }
        self.entries.deinit(self.allocator);
    }
};

// ─── Abstraction 3 & 4: Method Generation (CS + Q + Passive) ───

pub const GenKind = enum(u8) {
    cs,
    fluent_q,
    passive,
};

pub const MethodGenRule = struct {
    generated_name: [*:0]const u8,
    canonical_name: [*:0]const u8,
    kind: GenKind,
};

// ─── Abstraction 5: Error Catalog ───

pub const ErrorTemplate = struct {
    code: [*:0]const u8,
    template: [*:0]const u8,
};

pub const ErrorCatalog = struct {
    templates: std.StringHashMapUnmanaged([]const u8),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) ErrorCatalog {
        return .{
            .templates = .empty,
            .allocator = allocator,
        };
    }

    pub fn register(self: *ErrorCatalog, code: []const u8, template: []const u8) !void {
        const owned_code = try self.allocator.dupe(u8, code);
        const owned_tmpl = try self.allocator.dupe(u8, template);
        try self.templates.put(self.allocator, owned_code, owned_tmpl);
    }

    pub fn format(self: *const ErrorCatalog, code: []const u8, params: []const Substitution, out: []u8) ?usize {
        const tmpl = self.templates.get(code) orelse return null;
        return applyTemplate(tmpl, params, out);
    }

    pub fn deinit(self: *ErrorCatalog) void {
        var it = self.templates.iterator();
        while (it.next()) |entry| {
            self.allocator.free(entry.key_ptr.*);
            self.allocator.free(entry.value_ptr.*);
        }
        self.templates.deinit(self.allocator);
    }
};

pub const Substitution = struct {
    key: []const u8,
    value: []const u8,
};

pub fn applyTemplate(tmpl: []const u8, params: []const Substitution, out: []u8) ?usize {
    var pos: usize = 0;
    var i: usize = 0;

    while (i < tmpl.len) {
        if (i + 1 < tmpl.len and tmpl[i] == '$' and tmpl[i + 1] == '{') {
            const start = i + 2;
            const end = std.mem.indexOfScalarPos(u8, tmpl, start, '}') orelse return null;
            const key = tmpl[start..end];

            var found = false;
            for (params) |sub| {
                if (std.mem.eql(u8, sub.key, key)) {
                    if (pos + sub.value.len > out.len) return null;
                    @memcpy(out[pos..][0..sub.value.len], sub.value);
                    pos += sub.value.len;
                    found = true;
                    break;
                }
            }
            if (!found) {
                if (pos + (end - i + 1) > out.len) return null;
                @memcpy(out[pos..][0..(end - i + 1)], tmpl[i .. end + 1]);
                pos += end - i + 1;
            }
            i = end + 1;
        } else {
            if (pos >= out.len) return null;
            out[pos] = tmpl[i];
            pos += 1;
            i += 1;
        }
    }
    return pos;
}

// ─── Abstraction 6: Alias Engine ───

pub const AliasEntry = struct {
    alias_name: [*:0]const u8,
    canonical_name: [*:0]const u8,
};

pub const AliasTable = struct {
    map: std.StringHashMapUnmanaged([]const u8),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) AliasTable {
        return .{
            .map = .empty,
            .allocator = allocator,
        };
    }

    pub fn register(self: *AliasTable, alias: []const u8, canonical: []const u8) !void {
        const owned_alias = try self.allocator.dupe(u8, alias);
        const owned_canon = try self.allocator.dupe(u8, canonical);
        try self.map.put(self.allocator, owned_alias, owned_canon);
    }

    pub fn resolve(self: *const AliasTable, name: []const u8) ?[]const u8 {
        return self.map.get(name);
    }

    pub fn count(self: *const AliasTable) u32 {
        return self.map.count();
    }

    pub fn deinit(self: *AliasTable) void {
        var it = self.map.iterator();
        while (it.next()) |entry| {
            self.allocator.free(entry.key_ptr.*);
            self.allocator.free(entry.value_ptr.*);
        }
        self.map.deinit(self.allocator);
    }
};

// ─── Abstraction 7: History Tracking ───

pub const HistoryConfig = struct {
    class_name: [*:0]const u8,
    tracked_methods: [*]const [*:0]const u8,
    tracked_count: u16,
    snapshot_method: [*:0]const u8,
};

// ─── Global Meta-Engine State ───

pub const MetaEngine = struct {
    named_params: NamedParamRegistry,
    errors: ErrorCatalog,
    aliases: std.StringHashMapUnmanaged(AliasTable),
    param_check_enabled: bool,
    history_enabled: bool,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) MetaEngine {
        return .{
            .named_params = NamedParamRegistry.init(allocator),
            .errors = ErrorCatalog.init(allocator),
            .aliases = .empty,
            .param_check_enabled = true,
            .history_enabled = false,
            .allocator = allocator,
        };
    }

    pub fn getOrCreateAliasTable(self: *MetaEngine, class_name: []const u8) !*AliasTable {
        const result = try self.aliases.getOrPut(self.allocator, class_name);
        if (!result.found_existing) {
            const owned = try self.allocator.dupe(u8, class_name);
            result.key_ptr.* = owned;
            result.value_ptr.* = AliasTable.init(self.allocator);
        }
        return result.value_ptr;
    }

    pub fn resolveAlias(self: *const MetaEngine, class_name: []const u8, method_name: []const u8) ?[]const u8 {
        const table = self.aliases.get(class_name) orelse return null;
        return table.resolve(method_name);
    }

    pub fn isNamedParam(self: *const MetaEngine, keyword: []const u8) bool {
        return self.named_params.isRegistered(keyword);
    }

    pub fn formatError(self: *const MetaEngine, code: []const u8, params: []const Substitution, out: []u8) ?usize {
        return self.errors.format(code, params, out);
    }

    pub fn deinit(self: *MetaEngine) void {
        self.named_params.deinit();
        self.errors.deinit();
        var it = self.aliases.iterator();
        while (it.next()) |entry| {
            self.allocator.free(entry.key_ptr.*);
            entry.value_ptr.deinit();
        }
        self.aliases.deinit(self.allocator);
    }
};

// ─── Singleton ───

var _engine: ?MetaEngine = null;
var _gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;

pub fn engine() *MetaEngine {
    if (_engine == null) {
        _engine = MetaEngine.init(_gpa.allocator());
    }
    return &_engine.?;
}

pub fn shutdown() void {
    if (_engine) |*e| {
        e.deinit();
        _engine = null;
    }
    _ = _gpa.deinit();
    _gpa = .init;
}

// ─── Tests ───

test "named param registry" {
    var reg = NamedParamRegistry.init(std.testing.allocator);
    defer reg.deinit();

    try reg.register("Of");
    try reg.register("At");
    try reg.register("CaseSensitive");

    try std.testing.expect(reg.isRegistered("Of"));
    try std.testing.expect(reg.isRegistered("At"));
    try std.testing.expect(reg.isRegistered("CaseSensitive"));
    try std.testing.expect(!reg.isRegistered("NotRegistered"));
}

test "error catalog template substitution" {
    var cat = ErrorCatalog.init(std.testing.allocator);
    defer cat.deinit();

    try cat.register("PARAM_TYPE", "Incorrect param type! ${param} must be a ${expected}.");

    var buf: [256]u8 = undefined;
    const params = [_]Substitution{
        .{ .key = "param", .value = "pItem" },
        .{ .key = "expected", .value = "string" },
    };
    const len = cat.format("PARAM_TYPE", &params, &buf).?;
    const result = buf[0..len];
    try std.testing.expectEqualStrings("Incorrect param type! pItem must be a string.", result);
}

test "alias table" {
    var table = AliasTable.init(std.testing.allocator);
    defer table.deinit();

    try table.register("Value", "Content");
    try table.register("Size", "NumberOfItems");
    try table.register("Length", "NumberOfItems");

    try std.testing.expectEqualStrings("Content", table.resolve("Value").?);
    try std.testing.expectEqualStrings("NumberOfItems", table.resolve("Size").?);
    try std.testing.expectEqualStrings("NumberOfItems", table.resolve("Length").?);
    try std.testing.expect(table.resolve("Unknown") == null);
    try std.testing.expectEqual(@as(u32, 3), table.count());
}

test "meta engine alias per class" {
    var eng = MetaEngine.init(std.testing.allocator);
    defer eng.deinit();

    const list_table = try eng.getOrCreateAliasTable("stzList");
    try list_table.register("Value", "Content");
    try list_table.register("Size", "NumberOfItems");

    const str_table = try eng.getOrCreateAliasTable("stzString");
    try str_table.register("Text", "Content");

    try std.testing.expectEqualStrings("Content", eng.resolveAlias("stzList", "Value").?);
    try std.testing.expectEqualStrings("NumberOfItems", eng.resolveAlias("stzList", "Size").?);
    try std.testing.expectEqualStrings("Content", eng.resolveAlias("stzString", "Text").?);
    try std.testing.expect(eng.resolveAlias("stzList", "Text") == null);
    try std.testing.expect(eng.resolveAlias("stzNumber", "Value") == null);
}

test "template with missing key preserves placeholder" {
    var buf: [256]u8 = undefined;
    const params = [_]Substitution{
        .{ .key = "param", .value = "x" },
    };
    const len = applyTemplate("${param} is ${unknown}", &params, &buf).?;
    try std.testing.expectEqualStrings("x is ${unknown}", buf[0..len]);
}
