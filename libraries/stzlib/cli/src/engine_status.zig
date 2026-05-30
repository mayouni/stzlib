// Softanza Engine Status -- Source of Truth
//
// Embedded compile-time tables that mirror the canonical roadmap in
// base/doc/design/SOFTANZA_ENGINE_MACROPLAN.md.
//
// The roadmap has two parallel tracks:
//   - Engine (M-E1..M-E11): Zig modules + C ABI + Ring bridges
//   - stzlib  (M-S1..M-S3): Ring-side modularization, tests, docs
//
// And three orthogonal status surfaces:
//   - macro_stats        headline numbers (modules, DLLs, tests, bridges)
//   - domains            per-engine-module bridge status
//   - submodules         list-domain Ring submodules (scoping debt)
//   - milestones         M-E1..M-E11 + M-S1..M-S3 (matches macroplan)
//
// Update rules:
//   - Bump macro_stats whenever a Zig test or DLL count changes.
//   - Append/update domain rows when a bridge gains/loses methods.
//   - Append/update submodule rows when scoping_clean flips.
//   - Append/update milestone rows when a phase advances.
//   - DO NOT renumber milestones -- M-E1..M-E11 are canonical.

const std = @import("std");

pub const Status = enum {
    planned,
    in_progress,
    done,
    partial,

    pub fn tag(self: Status) []const u8 {
        return switch (self) {
            .planned => "PLAN",
            .in_progress => "WIP ",
            .done => "DONE",
            .partial => "PART",
        };
    }
};

pub const MacroStats = struct {
    modules_designed: u32,
    modules_built: u32,
    design_principles: u32,
    engine_tests: u32,
    dlls_shipping: u32,
    qt_dependencies: u32,
    ring_bridge_regs: u32,
    ring_classes_bridged: u32,
    ring_engine_calls: u32,
    last_session: u32,
    last_updated: []const u8,
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
    track: []const u8, // "engine" or "stzlib"
    title: []const u8,
    status: Status,
    summary: []const u8,
};

// ============================================================
// MACRO STATS -- the headline numbers from the macroplan
// ============================================================

pub const macro = MacroStats{
    .modules_designed = 88,
    .modules_built = 85,
    .design_principles = 19,
    .engine_tests = 1593,
    .dlls_shipping = 87,
    .qt_dependencies = 0,
    .ring_bridge_regs = 1034,
    .ring_classes_bridged = 125,
    .ring_engine_calls = 3482,
    .last_session = 30,
    .last_updated = "2026-05-28",
};

// ============================================================
// DOMAINS -- per Zig engine module / Ring class pair
// ============================================================
// Not exhaustive (87 DLLs total). Lists the active-development
// domains plus headline ones. See `softanza coverage` for all.

pub const domains = [_]Domain{
    .{
        .name = "list",
        .engine_module = "engine/src/list.zig",
        .ring_class = "base/list/stzList.ring",
        .bridge = "engine/src/ring_bridge_list.zig",
        .engine_fns = 133,
        .ring_methods_bridged = 230,
        .status = .in_progress,
        .notes = "thin core + 25 submodules; engine covers find/sort/dedup/slide/anti-sections/starts-with-list",
    },
    .{
        .name = "string",
        .engine_module = "engine/src/string.zig",
        .ring_class = "base/string/stzString.ring",
        .bridge = "engine/src/ring_bridge_string.zig",
        .engine_fns = 280,
        .ring_methods_bridged = 200,
        .status = .done,
        .notes = "13 submodules under string/ (Phase D); PCRE2 regex; SHA/MD5/BLAKE3 crypto; locale",
    },
    .{
        .name = "table",
        .engine_module = "engine/src/table.zig",
        .ring_class = "base/table/stzTable.ring",
        .bridge = "engine/src/ring_bridge_table.zig",
        .engine_fns = 55,
        .ring_methods_bridged = 80,
        .status = .done,
        .notes = "columnar core + pivot + sort + aggregate + search/filter (M-E3)",
    },
    .{
        .name = "hashmap",
        .engine_module = "engine/src/hashmap.zig",
        .ring_class = "base/list/stzHashList.ring",
        .bridge = "engine/src/ring_bridge_hashmap.zig",
        .engine_fns = 23,
        .ring_methods_bridged = 6,
        .status = .in_progress,
        .notes = "M-E18 started: cached @pEngineMap with lazy build + invalidate on mutation; HasKey/FindKey/NumberOfPairs/ValueInt/Float/StringByKey engine-backed",
    },
    .{
        .name = "value",
        .engine_module = "engine/src/value.zig",
        .ring_class = "(internal)",
        .bridge = "engine/src/ring_bridge_value.zig",
        .engine_fns = 29,
        .ring_methods_bridged = 0,
        .status = .done,
        .notes = "StzValue tagged union (M-E1); powers list/hashmap heterogeneity",
    },
    .{
        .name = "number",
        .engine_module = "engine/src/number.zig",
        .ring_class = "base/number/stzNumber.ring",
        .bridge = "engine/src/ring_bridge_number.zig",
        .engine_fns = 40,
        .ring_methods_bridged = 35,
        .status = .done,
        .notes = "StzBigInt + GCD/LCM/prime/factorial/fibonacci (M-E1)",
    },
    .{
        .name = "stats",
        .engine_module = "engine/src/stats.zig",
        .ring_class = "base/data/stzDataSet.ring",
        .bridge = "engine/src/ring_bridge_stats.zig",
        .engine_fns = 28,
        .ring_methods_bridged = 30,
        .status = .done,
        .notes = "mean/median/mode/variance/stddev/percentile/correlation/regression (M-E4)",
    },
    .{
        .name = "graph",
        .engine_module = "engine/src/graph.zig",
        .ring_class = "base/list/stzGraph.ring",
        .bridge = "engine/src/ring_bridge_stats.zig",
        .engine_fns = 18,
        .ring_methods_bridged = 22,
        .status = .done,
        .notes = "BFS/DFS/Dijkstra/topo-sort/components; lazy engine sync (M-E3)",
    },
    .{
        .name = "matrix",
        .engine_module = "engine/src/matrix.zig",
        .ring_class = "base/list/stzMatrix.ring",
        .bridge = "engine/src/ring_bridge_matrix.zig",
        .engine_fns = 19,
        .ring_methods_bridged = 19,
        .status = .done,
        .notes = "fully engine-backed (M-E3)",
    },
    .{
        .name = "regex",
        .engine_module = "engine/src/regex.zig (PCRE2)",
        .ring_class = "base/string/stzRegex.ring",
        .bridge = "engine/src/ring_bridge_string.zig",
        .engine_fns = 18,
        .ring_methods_bridged = 18,
        .status = .done,
        .notes = "PCRE2 10.47 backend; named groups; lookaround; Unicode scripts (Phase E)",
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
        .engine_fns = 7,
        .ring_methods_bridged = 15,
        .status = .done,
        .notes = "RFC-4180; round-trip tested (M-E3)",
    },
    .{
        .name = "json",
        .engine_module = "engine/src/json.zig",
        .ring_class = "base/file/stzJson.ring",
        .bridge = "engine/src/ring_bridge_json.zig",
        .engine_fns = 12,
        .ring_methods_bridged = 10,
        .status = .in_progress,
        .notes = "stzJsonFuncs.ring deliberately untouched per user directive",
    },
    .{
        .name = "random",
        .engine_module = "engine/src/random.zig",
        .ring_class = "base/common/stzRandom.ring",
        .bridge = "engine/src/ring_bridge_random.zig",
        .engine_fns = 6,
        .ring_methods_bridged = 15,
        .status = .done,
        .notes = "uniform/range/shuffle/sample/weighted (M-E5)",
    },
    .{
        .name = "unicode",
        .engine_module = "engine/src/unicode.zig",
        .ring_class = "(internal -- invisible to Ring)",
        .bridge = "engine/src/ring_bridge_unicode.zig",
        .engine_fns = 25,
        .ring_methods_bridged = 0,
        .status = .done,
        .notes = "utf8proc-backed; per-class sqlite refdata; engine impl detail",
    },
    .{
        .name = "text",
        .engine_module = "engine/src/text.zig",
        .ring_class = "base/string/stzStringText.ring",
        .bridge = "engine/src/ring_bridge_text.zig",
        .engine_fns = 11,
        .ring_methods_bridged = 11,
        .status = .done,
        .notes = "Flesch readability, segmentation, truncation (M-E4)",
    },
    .{
        .name = "yielder",
        .engine_module = "engine/src/yielder.zig",
        .ring_class = "base/list/stzYielder.ring",
        .bridge = "engine/src/ring_bridge_yielder.zig",
        .engine_fns = 8,
        .ring_methods_bridged = 8,
        .status = .done,
        .notes = "map/filter/reduce pipeline on StzList handles; 17/17/10 ops (M-E4)",
    },
    .{
        .name = "refdata",
        .engine_module = "engine/src/ref_data.zig",
        .ring_class = "base/i18n/stzCountry.ring + Language + Currency",
        .bridge = "engine/src/ring_bridge_refdata.zig",
        .engine_fns = 26,
        .ring_methods_bridged = 20,
        .status = .done,
        .notes = "i18n.db (261 countries, 323 languages); SQLite-backed (M-E3)",
    },
};

// ============================================================
// SUBMODULES -- list-domain Ring submodules tracked for scoping debt
// ============================================================

pub const submodules = [_]Submodule{
    .{ .parent = "list", .name = "stzList (core)",        .methods = 65, .engine_backed = 40, .scoping_clean = true,  .notes = "thin core + delegation router" },
    .{ .parent = "list", .name = "stzListFinder",         .methods = 28, .engine_backed = 12, .scoping_clean = true,  .notes = "find/findAll/findFirst/findLast/findNth engine-fast for strings" },
    .{ .parent = "list", .name = "stzListCounter",        .methods = 12, .engine_backed = 8,  .scoping_clean = true,  .notes = "engine CountCS / NumberOfOccurrence" },
    .{ .parent = "list", .name = "stzListLeadTrail",      .methods = 14, .engine_backed = 8,  .scoping_clean = true,  .notes = "engine StartsWith/EndsWith (single value)" },
    .{ .parent = "list", .name = "stzListChecker",        .methods = 22, .engine_backed = 6,  .scoping_clean = true,  .notes = "ContainsItemCS/IsEqualToCS engine-backed" },
    .{ .parent = "list", .name = "stzListComparator",     .methods = 18, .engine_backed = 8,  .scoping_clean = true,  .notes = "StartsWithList/EndsWithList engine-backed" },
    .{ .parent = "list", .name = "stzListClassifier",     .methods = 26, .engine_backed = 8,  .scoping_clean = true,  .notes = "Classify/Frequencies/FrequencyOf/Chunks engine" },
    .{ .parent = "list", .name = "stzListExtractor",      .methods = 16, .engine_backed = 4,  .scoping_clean = true,  .notes = "ExtractDuplicates engine; type extractors loop in Ring" },
    .{ .parent = "list", .name = "stzListMerger",         .methods = 18, .engine_backed = 6,  .scoping_clean = true,  .notes = "Interleave/Zip/Diff/Intersect/Union/Partition engine" },
    .{ .parent = "list", .name = "stzListDuplicates",     .methods = 18, .engine_backed = 10, .scoping_clean = true,  .notes = "FindDuplicates/RemoveDuplicates/MostDuplicated engine" },
    .{ .parent = "list", .name = "stzListSplits",         .methods = 14, .engine_backed = 10, .scoping_clean = true,  .notes = "SplitAt/Before/After/ToPartsOfN engine" },
    .{ .parent = "list", .name = "stzListSorter",         .methods = 14, .engine_backed = 12, .scoping_clean = true,  .notes = "Sort/Reverse/Min/Max/Median/Ranked/SortBy engine" },
    .{ .parent = "list", .name = "stzListGetter",         .methods = 35, .engine_backed = 10, .scoping_clean = true,  .notes = "Section/UniqueItems/NRandomItems/SlidingWindow engine" },
    .{ .parent = "list", .name = "stzListBounder",        .methods = 22, .engine_backed = 2,  .scoping_clean = true,  .notes = "Section engine; Middle/Range/Clamp Ring-side" },
    .{ .parent = "list", .name = "stzListSections",       .methods = 12, .engine_backed = 6,  .scoping_clean = true,  .notes = "SectionCS engine; Ranges/AntiRanges Ring-side; scoping clean" },
    .{ .parent = "list", .name = "stzListWalker",         .methods = 18, .engine_backed = 4,  .scoping_clean = true,  .notes = "WalkUntil/WalkWhile use engine FindW; rest scoping clean" },
    .{ .parent = "list", .name = "stzListFlattener",      .methods = 12, .engine_backed = 6,  .scoping_clean = true,  .notes = "Flatten/DeepFlatten/FlattenToDepth/Paired/Chunked engine; scoping clean" },
    .{ .parent = "list", .name = "stzListTrimmer",        .methods = 18, .engine_backed = 5,  .scoping_clean = true,  .notes = "TrimLeading/Trailing engine; Compact/Squeeze/StripNulls/TrimToSize scoping clean" },
    .{ .parent = "list", .name = "stzListReplacer",       .methods = 14, .engine_backed = 6,  .scoping_clean = true,  .notes = "ReplaceAllCS/ReplaceAt engine (ListSet); ReplaceMany/Nth/Last clean" },
    .{ .parent = "list", .name = "stzListRemover",        .methods = 14, .engine_backed = 5,  .scoping_clean = true,  .notes = "RemoveAllCS/RemoveAt engine (ListRemove); RemoveMany/Nth/Last/Section clean" },
    .{ .parent = "list", .name = "stzListInserter",       .methods = 8,  .engine_backed = 3,  .scoping_clean = true,  .notes = "InsertAt via ring_insert; SwapItems engine; MoveItem clean" },
    .{ .parent = "list", .name = "stzListMover",          .methods = 14, .engine_backed = 6,  .scoping_clean = true,  .notes = "Swap/RotateLeft/Right/Reverse/Shuffle engine; MoveMany scoping clean" },
    .{ .parent = "list", .name = "stzListRandom",         .methods = 35, .engine_backed = 4,  .scoping_clean = true,  .notes = "Shuffle/NRandomItems/Randomize engine; RandomizeSection/Numbers/Strings/Lists/Objects clean" },
    .{ .parent = "list", .name = "stzListPerformer",      .methods = 8,  .engine_backed = 4,  .scoping_clean = true,  .notes = "Perform/Yield via StzEngineListMapExpr; PerformOn/PerformW/YieldOn/YieldW clean" },
    .{ .parent = "list", .name = "stzListStringify",      .methods = 14, .engine_backed = 1,  .scoping_clean = true,  .notes = "Join via StzEngineListJoin; Stringify/Singlify/Lowercased/Uppercased/Numbers<->Strings clean" },
    .{ .parent = "list", .name = "stzListShow",           .methods = 18, .engine_backed = 0,  .scoping_clean = true,  .notes = "global recursive funcs (FormatList/FormatValue/etc) made recursion-safe; Ring-side viz with box-drawing" },
    .{ .parent = "list", .name = "stzHashList",           .methods = 63, .engine_backed = 6,  .scoping_clean = true,  .notes = "Engine: HasKey/FindKey/NumberOfPairs/Value(Int/Float/String)ByKey via cached @pEngineMap with auto-invalidate. ~80 methods scoping cleaned (full Klass-family Top/Bottom/Strongest/Weakest, ClassesSizes/Frequencies, NumberOfValuesInClass, NumberOfKeysByItemInList, ClassesInList, ClassifyInList, KlassInList, FindKeysByItemInList family, ToCode, ToStzTable, Show). 8 latent bugs fixed total (ValuesAndKeys typo, ReverseKeysAndValues missing _, UpdateAllPairsWith no-persist, FindNthKeyByValue undefined n, FindNthItem.FindItel typo, NumberOfKeysByItemInList missing param, FindLastKeyByItemInList undefined n, KeysByItemInList missing arg)" },
    .{ .parent = "list", .name = "stzListOfLists",        .methods = 55, .engine_backed = 1,  .scoping_clean = true,  .notes = "Engine: CommonItemsCS via StzEngineListIntersectionCS. Full scoping cleanup complete (~120 methods, 33 latent bugs fixed across 4 batches: SizeOfEach@Is always returned 1, AddMany loop no-op, NthList :Last fallthrough, Pairify->Parify typo, ShrinkTp typo, SwapCols n1=n2[2] overwrite, DuplicatesInListsRemoved missing .Copy(), entry-family used undefined o1, etc)" },
};

// ============================================================
// MILESTONES -- canonical M-E1..M-E11 (engine) + M-S1..M-S3 (stzlib)
// Matches base/doc/design/SOFTANZA_ENGINE_MACROPLAN.md
// ============================================================

pub const milestones = [_]Milestone{
    // ---- Engine track ----
    .{
        .id = "M-E0.5",
        .track = "engine",
        .title = "String Engine v2 (Phases A-H)",
        .status = .done,
        .summary = "Naming, Safety, Performance, Module-split (13 submodules ~280 fns), Regex (PCRE2), Locale, NLP, Crypto",
    },
    .{
        .id = "M-E1",
        .track = "engine",
        .title = "Foundation Types",
        .status = .done,
        .summary = "value.zig (StzValue tagged union, 29 fns) + number.zig (StzBigInt + GCD/LCM/prime/fib, 30 fns)",
    },
    .{
        .id = "M-E2",
        .track = "engine",
        .title = "Core Collections",
        .status = .done,
        .summary = "list.zig (33 fns find/sort/dedup) + hashmap.zig (22 fns string-keyed map)",
    },
    .{
        .id = "M-E3",
        .track = "engine",
        .title = "Extended Collections",
        .status = .done,
        .summary = "table + graph + matrix + stats + random + csv + refdata; stzTree stays Ring-side",
    },
    .{
        .id = "M-E4",
        .track = "engine",
        .title = "Algorithms",
        .status = .done,
        .summary = "stz_stats + stz_text + stz_yielder; Walker/Checker/Performer Ring-side over existing engine fns",
    },
    .{
        .id = "M-E5",
        .track = "engine",
        .title = "Infrastructure Services",
        .status = .done,
        .summary = "25 modules: uuid, codec, bits, html, geo, compress, solver, watch, log, cache, stream, process, arith, registry, profiler, callstack, crypto, async, embed, smallfn, execmodel + (random/expr/text/csv from M-E3/4)",
    },
    .{
        .id = "M-E6",
        .track = "engine",
        .title = "Signature Features",
        .status = .done,
        .summary = "11 modules: numtheory, splitter, univops, pattern, stringart, display, constraint, natlang, ccode, reactive, knowgraph",
    },
    .{
        .id = "M-E7",
        .track = "engine",
        .title = "Paradigm Engines",
        .status = .done,
        .summary = "12 modules: namedvars, truth, quantifier, adverb, timeline, gridnav, sectmerge, deepops, reaxis, softanzuter, polyglot, polycode",
    },
    .{
        .id = "M-E8",
        .track = "engine",
        .title = "Universal Computation",
        .status = .done,
        .summary = "14 modules: provenance, confidence, explain, similarity, context, resource, validator, schema, intent, embedding, sequence, topology, relations, statemachine",
    },
    .{
        .id = "M-E9",
        .track = "engine",
        .title = "Value Proposition Modules",
        .status = .done,
        .summary = "stz_interact (Interaction Engine, 10 fns) + stz_skill (Skill Engine, 12 fns)",
    },
    .{
        .id = "M-E10",
        .track = "engine",
        .title = "CLI Polish + Ring Bridge Completion",
        .status = .partial,
        .summary = "softanza status/coverage/roadmap/next DONE (this CLI); 125/125 Ring classes bridged; narrated test runner + skills assessment pending",
    },
    .{
        .id = "M-E11",
        .track = "engine",
        .title = "Repository Split",
        .status = .planned,
        .summary = "Extract softanza-engine as standalone repo; ship C headers + CLI + language-neutral docs. Deferred until API stable",
    },

    // ---- stzlib redesign track ----
    .{
        .id = "M-S1",
        .track = "stzlib",
        .title = "Class Modularization",
        .status = .done,
        .summary = "stzString DONE (32 domain classes, monolith archived). stzList DONE: Phase 1 bridged Finder/Counter/Splits/Checker/Comparator/Classifier/Extractor/Merger/Duplicates/Sorter/Getter/Bounder; Phase 2 scoping cleanup landed all 28 submodules + stzHashList engine bridge. M-S1 closed at session 37; the Phase 2 sweep flushed 33 latent bugs (later regression sessions added 19 more across stzString modularization gaps and stzTable/stzGraph). 52 cumulative bugs surfaced through this work.",
    },
    .{
        .id = "M-S2",
        .track = "stzlib",
        .title = "Ring-Side Test Hardening",
        .status = .partial,
        .summary = "Sessions 38-48: 24 regression suites pin 70 latent bugs, ~810 cumulative assertions. Sessions 43-44 cross-DLL handle/pure-Ring-yielder. Session 45 M-E3 slice (Number/Table/Graph). Session 46 shipped engine-side direct-marshal yielder bridge (7 C ABI variants, key learning: route everything through callconv(.c) inside bridge fns). Session 47 wave 1 -- 8 domain suites (regex/json/csv/datetime/matrix/calendar/listofnumbers + shadow audit) + 12 bugs. Session 48 wave 2 -- 5 more domains (stringlist/listofpairs/listofbytes/pivot + inverted-predicate audit + active-form audit) + 6 bugs: inverted boolean logic in PairsAreMadeOfEqualItems; FindItem unreachable in stzListOfPairs; FindAllOccurrencesCS string+list R21 fallback; chain-on-new R13 in SortOnInDescending; IsContiguous off-by-one (loop started at i=3, missed [1]->[2] gap); pivot AVG silently aggregated as SUM (no alias in dispatch lookup). 14 bug-pattern families catalogued. Still pending: more domain regression suites, narrated GIVEN/WHEN/THEN runner, reactive async harness",
    },
    .{
        .id = "M-S3",
        .track = "stzlib",
        .title = "Documentation Reimagining",
        .status = .planned,
        .summary = "6 doc types (API reference / how-to / tutorials / paradigm narrations / architecture / quick-ref cards); 60+ existing narrations to curate; top-10 class API references to generate",
    },
};
