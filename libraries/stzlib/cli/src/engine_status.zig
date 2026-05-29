// Softanza Engine Status -- Source of Truth
//
// Embedded compile-time tables that record where each domain stands in the
// three-layer journey: Zig engine module -> C ABI exports -> Ring bridge ->
// Ring class (thin core + domain submodules) -> XT aliases.
//
// Each session that lands engine work updates THIS FILE so the CLI commands
// (status, coverage, roadmap, next) become a deterministic, no-context-cost
// answer to "where are we?".
//
// Update rules:
//   - Append, don't rewrite. Stable order beats alphabetical.
//   - Counts approximate. Use `git grep` / `zig build test` for exact.
//   - If a Submodule is scoping_clean=true, all method-local vars use the
//     _prefixed_ convention. Otherwise it carries Ring class-attribute risk.
//   - last_touched_commit is the short SHA where the field last changed.

const std = @import("std");

pub const Status = enum {
    planned,
    in_progress,
    done,

    pub fn tag(self: Status) []const u8 {
        return switch (self) {
            .planned => "PLAN",
            .in_progress => "WIP ",
            .done => "DONE",
        };
    }
};

pub const Domain = struct {
    name: []const u8,
    engine_module: []const u8,
    ring_class: []const u8,
    bridge: []const u8,
    engine_fns: u32,
    ring_methods_bridged: u32,
    status: Status,
    notes: []const u8,
};

pub const Submodule = struct {
    parent: []const u8,
    name: []const u8,
    methods: u32,
    engine_backed: u32,
    scoping_clean: bool,
    notes: []const u8,
};

pub const Milestone = struct {
    id: []const u8,
    title: []const u8,
    status: Status,
    summary: []const u8,
};

// ============================================================
// DOMAINS -- one row per Zig engine module
// ============================================================

pub const domains = [_]Domain{
    .{
        .name = "list",
        .engine_module = "engine/src/list.zig",
        .ring_class = "base/list/stzList.ring",
        .bridge = "engine/src/ring_bridge_list.zig",
        .engine_fns = 130,
        .ring_methods_bridged = 230,
        .status = .in_progress,
        .notes = "thin core + 25 submodules; engine covers find/sort/dedup/slide/anti-sections/starts-with-list",
    },
    .{
        .name = "string",
        .engine_module = "engine/src/string.zig",
        .ring_class = "base/string/stzString.ring",
        .bridge = "engine/src/ring_bridge_string.zig",
        .engine_fns = 120,
        .ring_methods_bridged = 200,
        .status = .in_progress,
        .notes = "PCRE2 regex live; Unicode case folding; thin-core orchestrator at 355 lines",
    },
    .{
        .name = "table",
        .engine_module = "engine/src/table.zig",
        .ring_class = "base/table/stzTable.ring",
        .bridge = "engine/src/ring_bridge_table.zig",
        .engine_fns = 55,
        .ring_methods_bridged = 80,
        .status = .done,
        .notes = "columnar core + pivot + sort + aggregate + search/filter",
    },
    .{
        .name = "hashmap",
        .engine_module = "engine/src/hashmap.zig",
        .ring_class = "base/list/stzHashList.ring",
        .bridge = "engine/src/ring_bridge_hashmap.zig",
        .engine_fns = 20,
        .ring_methods_bridged = 0,
        .status = .planned,
        .notes = "engine module live; Ring class not yet bridged",
    },
    .{
        .name = "value",
        .engine_module = "engine/src/value.zig",
        .ring_class = "(internal)",
        .bridge = "engine/src/ring_bridge_value.zig",
        .engine_fns = 18,
        .ring_methods_bridged = 0,
        .status = .done,
        .notes = "tagged union; powers list/hashmap heterogeneity",
    },
    .{
        .name = "number",
        .engine_module = "engine/src/number.zig",
        .ring_class = "base/number/stzNumber.ring",
        .bridge = "engine/src/ring_bridge_number.zig",
        .engine_fns = 40,
        .ring_methods_bridged = 35,
        .status = .done,
        .notes = "arbitrary precision; full bridge done",
    },
    .{
        .name = "stats",
        .engine_module = "engine/src/stats.zig",
        .ring_class = "base/data/stzDataSet.ring",
        .bridge = "engine/src/ring_bridge_stats.zig",
        .engine_fns = 35,
        .ring_methods_bridged = 30,
        .status = .done,
        .notes = "stzDataSet fully delegated",
    },
    .{
        .name = "graph",
        .engine_module = "engine/src/graph.zig",
        .ring_class = "base/list/stzGraph.ring",
        .bridge = "engine/src/ring_bridge_stats.zig",
        .engine_fns = 25,
        .ring_methods_bridged = 22,
        .status = .done,
        .notes = "algorithmic methods delegated; _SyncEngine on mutations",
    },
    .{
        .name = "regex",
        .engine_module = "engine/src/regex.zig (PCRE2)",
        .ring_class = "base/string/stzRegex.ring",
        .bridge = "engine/src/ring_bridge_string.zig",
        .engine_fns = 18,
        .ring_methods_bridged = 18,
        .status = .done,
        .notes = "PCRE2 backend; named groups; INDEX_BASE adjusted",
    },
    .{
        .name = "datetime",
        .engine_module = "engine/src/datetime.zig",
        .ring_class = "base/datetime/stzDate.ring",
        .bridge = "engine/src/ring_bridge_datetime.zig",
        .engine_fns = 50,
        .ring_methods_bridged = 40,
        .status = .in_progress,
        .notes = "core stk_datetime + base stz_datetime; calendar variants pending",
    },
    .{
        .name = "csv",
        .engine_module = "engine/src/csv.zig",
        .ring_class = "base/file/stzCSV.ring",
        .bridge = "engine/src/ring_bridge_csv.zig",
        .engine_fns = 15,
        .ring_methods_bridged = 15,
        .status = .done,
        .notes = "RFC-4180 compliant; round-trip tested",
    },
    .{
        .name = "json",
        .engine_module = "engine/src/json.zig",
        .ring_class = "base/file/stzJson.ring",
        .bridge = "engine/src/ring_bridge_json.zig",
        .engine_fns = 12,
        .ring_methods_bridged = 10,
        .status = .in_progress,
        .notes = "parser solid; stzJsonFuncs.ring deliberately untouched per user directive",
    },
    .{
        .name = "random",
        .engine_module = "engine/src/random.zig",
        .ring_class = "base/common/stzRandom.ring",
        .bridge = "engine/src/ring_bridge_random.zig",
        .engine_fns = 15,
        .ring_methods_bridged = 15,
        .status = .done,
        .notes = "deterministic seed support; cryptographic and PRNG modes",
    },
    .{
        .name = "unicode",
        .engine_module = "engine/src/unicode.zig",
        .ring_class = "(internal -- invisible to Ring)",
        .bridge = "engine/src/ring_bridge_unicode.zig",
        .engine_fns = 25,
        .ring_methods_bridged = 0,
        .status = .done,
        .notes = "utf8proc-backed; per-class sqlite reference DBs; engine implementation detail",
    },
};

// ============================================================
// SUBMODULES -- one row per stzList* / stzString* domain class
// ============================================================
// Only list-domain submodules tracked here for now; expand as we
// refactor others. scoping_clean=true means all method-local
// variables use the _prefixed_ convention.

pub const submodules = [_]Submodule{
    .{ .parent = "list", .name = "stzList (core)",        .methods = 65, .engine_backed = 40, .scoping_clean = true,  .notes = "thin core + delegation router" },
    .{ .parent = "list", .name = "stzListFinder",         .methods = 28, .engine_backed = 12, .scoping_clean = true,  .notes = "find/findAll/findFirst/findLast/findNth all engine-fast for strings" },
    .{ .parent = "list", .name = "stzListCounter",        .methods = 12, .engine_backed = 8,  .scoping_clean = true,  .notes = "engine CountCS / NumberOfOccurrence" },
    .{ .parent = "list", .name = "stzListLeadTrail",      .methods = 14, .engine_backed = 8,  .scoping_clean = true,  .notes = "engine StartsWith/EndsWith (single value)" },
    .{ .parent = "list", .name = "stzListChecker",        .methods = 22, .engine_backed = 6,  .scoping_clean = true,  .notes = "ContainsItemCS/IsEqualToCS engine-backed" },
    .{ .parent = "list", .name = "stzListComparator",     .methods = 18, .engine_backed = 8,  .scoping_clean = true,  .notes = "StartsWithList/EndsWithList engine-backed; routes Contains via @oList" },
    .{ .parent = "list", .name = "stzListClassifier",     .methods = 26, .engine_backed = 8,  .scoping_clean = true,  .notes = "Classify/Frequencies/FrequencyOf/Chunks all engine; scoping clean" },
    .{ .parent = "list", .name = "stzListExtractor",      .methods = 16, .engine_backed = 4,  .scoping_clean = true,  .notes = "ExtractDuplicates engine; type extractors loop in Ring" },
    .{ .parent = "list", .name = "stzListMerger",         .methods = 18, .engine_backed = 6,  .scoping_clean = true,  .notes = "Interleave/Zip/Diff/Intersect/Union/Partition engine" },
    .{ .parent = "list", .name = "stzListDuplicates",     .methods = 18, .engine_backed = 10, .scoping_clean = true,  .notes = "FindDuplicates/RemoveDuplicates/MostDuplicated engine" },
    .{ .parent = "list", .name = "stzListSplits",         .methods = 14, .engine_backed = 10, .scoping_clean = true,  .notes = "SplitAt/Before/After/ToPartsOfN engine" },
    .{ .parent = "list", .name = "stzListSections",       .methods = 12, .engine_backed = 6,  .scoping_clean = false, .notes = "AntiSections/SlidingWindow engine; rest of class needs scoping fix" },
    .{ .parent = "list", .name = "stzListSorter",         .methods = 14, .engine_backed = 12, .scoping_clean = true,  .notes = "Sort/Sorted/Reverse/Min/Max/Median/Ranked/NthSmallest engine; SortBy expr engine" },
    .{ .parent = "list", .name = "stzListGetter",         .methods = 35, .engine_backed = 10, .scoping_clean = true,  .notes = "Section/UniqueItems/NRandomItems/SlidingWindow engine; rest scoping-clean" },
    .{ .parent = "list", .name = "stzListWalker",         .methods = 18, .engine_backed = 2,  .scoping_clean = false, .notes = "WalkUntil/WalkBetween Ring-side; engine expr backend possible" },
    .{ .parent = "list", .name = "stzListBounder",        .methods = 22, .engine_backed = 2,  .scoping_clean = true,  .notes = "Section engine fast-path; Middle/Bounds/Range/Clamp Ring-side; scoping clean" },
    .{ .parent = "list", .name = "stzListFlattener",      .methods = 12, .engine_backed = 4,  .scoping_clean = false, .notes = "Flatten/DeepFlatten engine; FlattenToDepth needs scoping" },
    .{ .parent = "list", .name = "stzListTrimmer",        .methods = 18, .engine_backed = 3,  .scoping_clean = false, .notes = "TrimLeading/Trailing/Compact; ~33 bare vars" },
    .{ .parent = "list", .name = "stzListReplacer",       .methods = 14, .engine_backed = 4,  .scoping_clean = false, .notes = "ReplaceCS/ReplaceMany engine; bare vars in walks" },
    .{ .parent = "list", .name = "stzListRemover",        .methods = 14, .engine_backed = 3,  .scoping_clean = false, .notes = "RemoveCS engine; bare vars in batch removes" },
    .{ .parent = "list", .name = "stzListInserter",       .methods = 8,  .engine_backed = 2,  .scoping_clean = false, .notes = "Insert/SortedInsert engine; mostly Ring-side" },
    .{ .parent = "list", .name = "stzListMover",          .methods = 10, .engine_backed = 3,  .scoping_clean = false, .notes = "Swap/RotateLeft/Right engine; bare vars elsewhere" },
    .{ .parent = "list", .name = "stzListRandom",         .methods = 10, .engine_backed = 4,  .scoping_clean = false, .notes = "Shuffle/RandomItem/RandomItems engine; 18 bare vars" },
    .{ .parent = "list", .name = "stzListPerformer",      .methods = 8,  .engine_backed = 2,  .scoping_clean = false, .notes = "Map/Filter/Reduce expr engine; 9 bare vars" },
    .{ .parent = "list", .name = "stzListStringify",      .methods = 14, .engine_backed = 1,  .scoping_clean = false, .notes = "Join engine; rest formatting Ring-side" },
    .{ .parent = "list", .name = "stzListShow",           .methods = 18, .engine_backed = 0,  .scoping_clean = false, .notes = "viz/render Ring-side; 20 bare vars + box-drawing" },
    .{ .parent = "list", .name = "stzHashList",           .methods = 60, .engine_backed = 0,  .scoping_clean = false, .notes = "hashmap engine exists but Ring class still pure; ~190 bare vars" },
    .{ .parent = "list", .name = "stzListOfLists",        .methods = 55, .engine_backed = 0,  .scoping_clean = false, .notes = "specialised container; ~190 bare vars" },
};

// ============================================================
// MILESTONES -- the engine roadmap
// ============================================================

pub const milestones = [_]Milestone{
    .{
        .id = "M-E1",
        .title = "Foundation Types",
        .status = .done,
        .summary = "value (tagged union) + number (arbitrary precision)",
    },
    .{
        .id = "M-E2",
        .title = "Core Collections",
        .status = .done,
        .summary = "list (typed) + hashmap (string-keyed) Zig modules",
    },
    .{
        .id = "M-E3",
        .title = "Unicode Reference Data",
        .status = .done,
        .summary = "per-class sqlite DBs; engine implementation detail; Ring never sees handles",
    },
    .{
        .id = "M-E4",
        .title = "stzNumber Bridge",
        .status = .done,
        .summary = "engine-back arbitrary precision + global number utilities",
    },
    .{
        .id = "M-E5",
        .title = "stzTable + Pivot Engine",
        .status = .done,
        .summary = "columnar table + sort/search/aggregate + pivot; full Ring delegation",
    },
    .{
        .id = "M-E6",
        .title = "stzList Finder/Counter Bridge",
        .status = .done,
        .summary = "engine-back find/count for stzListFinder and stzListCounter",
    },
    .{
        .id = "M-E7",
        .title = "stzList Leading/Trailing Detection",
        .status = .done,
        .summary = "engine starts_with / ends_with (single value); leading/trailing counts",
    },
    .{
        .id = "M-E8",
        .title = "stzList Splits Engine",
        .status = .done,
        .summary = "SplitAt/Before/After/ToPartsOfN engine; recursive unmarshal fix",
    },
    .{
        .id = "M-E9",
        .title = "stz_stats + stz_graph",
        .status = .done,
        .summary = "stats module + graph algorithms; stzDataSet fully delegated",
    },
    .{
        .id = "M-E10",
        .title = "stzRandom + stzCSV Bridge",
        .status = .done,
        .summary = "random number generation + RFC-4180 CSV both engine-backed",
    },
    .{
        .id = "M-E11",
        .title = "PCRE2 Regex Integration",
        .status = .done,
        .summary = "vendored PCRE2; stzRegex engine-backed with named groups",
    },
    .{
        .id = "M-E12",
        .title = "stzList SlidingWindow + AntiSections",
        .status = .done,
        .summary = "engine sliding_window + anti_sections with INDEX_BASE adjustment",
    },
    .{
        .id = "M-E13",
        .title = "stzList Checker/Comparator Bridge",
        .status = .done,
        .summary = "Contains/IsEqualTo/StartsWithList/EndsWithList engine; new list-prefix engine fns",
    },
    .{
        .id = "M-E14",
        .title = "stzList Classifier/Extractor Bridge",
        .status = .done,
        .summary = "FrequencyOf/Chunks engine; scoping fix for both submodules",
    },
    .{
        .id = "M-E15",
        .title = "stzList Scoping Cleanup (Phase 1)",
        .status = .done,
        .summary = "Finder, Merger, Duplicates submodules converted to _prefixed_ vars",
    },
    .{
        .id = "M-E16",
        .title = "Engine Status CLI",
        .status = .done,
        .summary = "softanza status/coverage/roadmap/next; source-of-truth comptime table",
    },
    .{
        .id = "M-E17",
        .title = "stzList Scoping Cleanup (Phase 2)",
        .status = .in_progress,
        .summary = "Getter, Walker, Bounder, Flattener, Trimmer, Show, Random, Mover, Sections, Sorter",
    },
    .{
        .id = "M-E18",
        .title = "stzHashList Engine Bridge",
        .status = .planned,
        .summary = "wire hashmap engine module into stzHashList Ring class (60 methods, ~190 bare vars)",
    },
    .{
        .id = "M-E19",
        .title = "stzListPerformer Engine Expr",
        .status = .planned,
        .summary = "expand engine Map/Filter/Reduce expr coverage; add Yield/Walk-w/Until-w bytecode",
    },
    .{
        .id = "M-E20",
        .title = "Walk/Until/Between Engine Layer",
        .status = .planned,
        .summary = "engine walker bytecode for stzListWalker condition operations",
    },
    .{
        .id = "M-E21",
        .title = "stzString Submodule Bridge",
        .status = .planned,
        .summary = "mirror the list submodule pattern for stzString (Finder/Replacer/...)",
    },
};
