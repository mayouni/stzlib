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
    .dlls_shipping = 91,
    .qt_dependencies = 0,
    .ring_bridge_regs = 1500,
    .ring_classes_bridged = 131,
    .ring_engine_calls = 3482,
    .last_session = 105,
    .last_updated = "2026-06-15",
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
        .bridge = "engine/src/ring_bridge_graph.zig",
        .engine_fns = 38,
        .ring_methods_bridged = 44,
        .status = .done,
        .notes = "engine ACTIVE; BFS/DFS, SCC (Kosaraju), MST weight+edges (Kruskal), articulation points + bridges (Tarjan), weighted Dijkstra, is_bipartite, closeness + betweenness centrality (Brandes), k-core (Batagelj-Zaversnik), PageRank, A* (coordinate heuristic) + astar_full (path+explored) for the engine-backed stzGraphPlanner, set_edge_weight, shortest-path/reachable/components/topo-sort/cycle/degrees. All list-returning bridges build Ring lists Zig-side (sessions 100-104)",
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
        .status = .done,
        .summary = "Closed 2026-06-13 (session 54). softanza status/coverage/roadmap/next CLI DONE; 125/125 Ring classes bridged; narrated GIVEN/WHEN/THEN runner shipped session 53 (5 suites, 73 assertions); reactive harness shipped session 54 (5 scenarios, 20 assertions, sync-only data-layer); skills-assessment item moot (skill module removed in b70f3ad9 as AI-invented).",
    },
    .{
        .id = "M-E11",
        .track = "engine",
        .title = "Repository Split",
        .status = .planned,
        .summary = "Extract softanza-engine as standalone repo; ship C headers + CLI + language-neutral docs. Deferred until API stable",
    },

    // ---- external-dependency track (M-DEP*) ----
    .{
        .id = "M-DEP1",
        .track = "depcleanup",
        .title = "Drop FastPro Extension",
        .status = .done,
        .summary = "Closed 2026-06-13 (session 55). stzFastPro.ring wrapped the RingFastPro C++ extension's updateList() for fast batch list/matrix mutations. Only consumer was its own test suite; no production code in base/ called it. Engine stzMatrix covers the hot paths. stzFastPro.ring moved to base/archive/number/; test/fastpro/ moved to base/archive/test/fastpro/; `load \"number/stzFastPro.ring\"` removed from stzBase.ring.",
    },
    .{
        .id = "M-DEP-UUID",
        .track = "depcleanup",
        .title = "Drop uuid.ring Extension",
        .status = .done,
        .summary = "Closed 2026-06-13 (session 55). stzUUID.ring previously loaded the C++ uuid.ring extension. Engine module libraries/stzlib/engine/src/uuid.zig already provided V4/V4Compact/IsValid/Version/Nil/Compare via StzEngineUUID* bridge. Rewrote stzUUID.ring to use engine; uncommented `load \"system/stzUUID.ring\"` in stzBase.ring; ToBytes() hex-decodes pure-Ring. Test 52_uuid_engine_narrated.ring: 14 assertions green. Commit 9f9bed5f.",
    },
    .{
        .id = "M-DEP2",
        .track = "depcleanup",
        .title = "Replace html.ring (lexbor) with Zig HTML5 Parser",
        .status = .done,
        .summary = "CLOSED 2026-06-13 (sessions 56-57). Slice 1: html_dom.zig (~450 LOC) ships tokenizer + flat element index with 14 Zig unit tests. Bridge exposes 14 functions (Parse/Free/Count/CountByTag/TextOfTag/AttrOfTag/AllText/TagOf + FindById/CountByClass/FindByClass/ChildrenCount/ChildAt/ParentOf). Slice 2: stzHtml.ring rewritten to use engine -- `load \"html.ring\"` REMOVED. Supports tag/#id/.class selectors via Find(), Node API with Tag/Text/Attr/Id/Klass/HasKlass. Tests 52+53 narrated_html: 36 assertions, all green. NOT YET (slice 3, only if needed): CSS combinator selectors, DOM mutation, stzHtmlBuilder. Current surface covers typical scrape-data-from-HTML use case.",
    },
    .{
        .id = "M-DEP3",
        .track = "depcleanup",
        .title = "Replace libcurl.ring with Zig HTTP Client",
        .status = .done,
        .summary = "CLOSED 2026-06-13 (sessions 58-59). Engine module stz_http ships GET/POST + generic StzEngineHttpRequest (method codes 0..6 for GET/POST/PUT/DELETE/HEAD/OPTIONS/PATCH) with caller-supplied headers blob. std.http.Client + std.crypto.tls handle HTTP+HTTPS without an external TLS library. stzNetwork.ring + stzHttpClient.ring fully rewritten -- `load \"libcurl.ring\"` + `load \"libuv.ring\"` REMOVED from network/. Verbs, form helpers (PostForm/PostJson), header list, cookie list, user-agent setter all route through the engine. libuv-backed parallel GetMany() dropped; sequential GetManySequential() supported. Tests 52+53 narrated: 24 assertions, all green. Slice 3 deferred (response headers extraction, Basic/Bearer auth, proxy, streaming download, per-request timing) -- not driven by current callers.",
    },
    .{
        .id = "M-DEP4",
        .track = "depcleanup",
        .title = "Replace libuv.ring with engine TCP + polling timer",
        .status = .done,
        .summary = "FULLY CLOSED 2026-06-13 (sessions 60-62). Slice 1: libuv removed from reactive runtime + stzReactiveTimer rewritten to clock()-based polling. Slice 2: new engine domain stz_tcp (std.net-backed sync TCP) -- stzTcp{Client,Server} fully rewired. Slice 3 (session 62): REAL ASYNC SHIPPED -- parallel HTTP fetch via std.Thread per URL (StzEngineHttpParallelGet, GetMany restored on stzHttpClient) + engine fswatch module via background polling worker thread (StzEngineFsWatch* + new stzFolderWatcher class). Real ADD event detected from a live FS test. Five test suites cover the arc: 52_reactive_polling 8/8, 54_stztcp_engine 15/15, 55_http_parallel 7/7, 54_fswatch_engine 10/10, cross-checks 51_reactive (20/20), 53_stzhttpclient (17/17), 53_stzhtml (21/21). 98 assertions across the reactive engine work, all green. The libuv era's three documented use cases (timers, parallel HTTP, FS watch) are all engine-backed now -- no IOCP/epoll/kqueue wrapper needed for these.",
    },

    // ---- reactive-engine hardening track (gap analysis Tier 1) ----
    .{
        .id = "M-RX1",
        .track = "engine",
        .title = "Reactive Engine Hardening -- Tier 1 (web/cloud/agentic)",
        .status = .done,
        .summary = "Closing the Tier 1 gaps from REACTIVE_ENGINE_GAP_ANALYSIS.md (vs libuv/libcurl/nginx/Go/Tokio/Envoy). Item 1 caller-side deadline shipped session 64 (StzEnginePoolPollWithDeadline). Session 65 landed items 1+2 fused: a custom HTTP/1.1 client on raw std.net.Stream (engine/src/httpcore.zig) with TLS via std.crypto.tls.Client for https, replacing the std.http.Client path inside http.zig; plus a connection pool keyed by (scheme,host,port) (engine/src/http_pool.zig) with idle eviction + per-host/global caps + opens/reuses/idle/active stats. Per-layer timeouts: connect via non-blocking connect + poll(POLLOUT) deadline (fails fast on unreachable hosts -- ~ms not ~21s); request via SO_RCVTIMEO/SO_SNDTIMEO (honoured on POSIX, best-effort on Windows where std uses overlapped WSARecv -- the caller-side deadline remains the cross-platform guarantee). New bridge fns StzEngineHttpSetDefaultTimeouts/RequestWithTimeouts/PoolStats; stzHttpClient gains SetTimeout/SetConnectTimeout/SetRequestTimeout/SetDefaultTimeouts/PoolStats. Live-verified: connection REUSE (reuses increments, opens flat), HTTPS round-trip, fast connect-timeout. Tests 63_http_pool (6/6) + 64_http_timeouts_engine (7/7). **Session 66 added items 3+4:** (3) DNS cache `engine/src/dns.zig` -- lookup keyed by host|port, positive TTL 60s + negative TTL 5s, atomic resolve/hit counters, wired into httpcore.connect + tcp.tcp_connect; diagnostics StzEngineDnsResolve/Stats/CacheClear. (4) Cancellation tokens `engine/src/cancel.zig` -- atomic-flag CancelToken create/signal/is_cancelled/destroy; pool Job carries an optional token; new StzEnginePoolSubmitWithCancel + worker checkpoint returns -5 (JOB_CANCELLED) when signalled before run; Ring class stzCancelToken (lazy-init guard since paren-less `new` skips init). Tests: dns.zig 3/3 Zig + 65_dns_cache 4/4 Ring; cancel.zig 2/2 Zig + 54_cancel 5/5 Ring. **Session 67 added items 5+6:** (5) retry budget -- Ring class `base/common/stzRetryBudget.ring` over the existing token-bucket rate limiter (no engine change); budget=N retries / window=W sec, refill floor(N/W) tokens/sec min 1; Allow()/Spend()/AllowN()/Available() (named Allow not Try -- `try` is a Ring keyword). (6) latency histograms -- new DLL `engine/src/histogram.zig` (log-scale ms buckets 0.1..10000, create/record/percentile/reset/count/destroy) + `StzEngineHistogram*` bridge + Ring class `stzLatencyHistogram` (P50/P95/P99); HTTP path now records every request's latency, queryable via StzEngineHttpLatencyPercentile/Count/Reset. Tests: histogram.zig 4/4 Zig + 66_retry_budget 10/10 + 67_histogram 10/10 Ring. DLLs 87->88, regs 1045->1054, classes 126->128. **Session 68 CLOSED Tier 1 with items 7+8:** (7) outlier ejection per host -- resilience.zig OutlierDetector (consecutive-failure threshold + cooldown readmit + reset-on-success); http_pool.acquire refuses ejected hosts, http.zig records each outcome; StzEngineOutlierConfig/Record/ShouldEject/Reset registered in stz_http (same instance as the pool). (8) graceful pool drain -- pool.zig gains an `accepting` flag + `pool_drain(timeout_ms)` returning the residual (queued+running) count; submit returns -4 'pool draining' once draining; StzEnginePoolDrain bridge; stzHttpClient.Shutdown() releases idle pooled sockets via StzEngineHttpPoolShutdown. Tests: resilience.zig 8/8 (incl. 2 outlier) + pool.zig drain Zig; new 68_outlier 5/5 + 69_pool_drain 6/6 Ring. regs 1054->1060. **M-RX1 DONE -- all 8 Tier 1 gaps closed (sessions 64-68).** Full network(52..69)+reactive(51..54) green; zig build + test clean. Tier 2 (IOCP/epoll/kqueue cooperative scheduler, HTTP/2, TraceContext propagation, work-stealing) remains the deferred 3-5 session arc, gated on Zig 0.16 std.Io.",
    },

    .{
        .id = "M-RX2",
        .track = "engine",
        .title = "Reactive Engine -- Tier 2 (libuv reactor backbone)",
        .status = .done,
        .summary = "Industry-strength cross-platform async I/O, built on vendored libuv instead of hand-rolling per-OS reactors (user directive: build with libuv, avoid reinventing wheels). Vendoring C is the utf8proc/pcre2/sqlite pattern -- it does NOT reintroduce the M-DEP Ring-extension dependency (that rule is about Ring-side `load`, not C compiled into the engine). FOUNDATION LANDED (session 69): engine/vendor/libuv (v1.52.1, include+src, ~2MB) compiles from source via addLibuv in build.zig (per-OS file lists/defines/syslibs mirror libuv CMakeLists; Windows IOCP path); new stz_reactor DLL with reactor.zig (@cImport uv.h) exposing StzEngineReactorVersion/SelfTest; loader + stzRingLibs wired. Verified end-to-end on Windows: zig build clean (libuv compiled first try), Ring smoke reports libuv 1.52.1 and self-test=1 (real loop ran, one-shot timer fired). DLLs 88->89, regs 1060->1062. Design + plan in base/doc/design/TIER2_REACTOR_DIRECTION.md. SLICE 1 LANDED (session 70): reactor core -- a uv_loop running on a dedicated worker thread, cross-thread submission via uv_async_send + a mutex-guarded job table, and the standard libuv two-phase handle-lifetime handshake (free a job only once its handle's uv_close callback fired AND the caller polled). First async op = timer; Ring stays synchronous via the submit/poll idiom (StzEngineReactorCreate/SubmitTimer/Poll/Await/Pending/Destroy). Verified: reactor.zig Zig tests 5/5 (incl. 32 concurrent timers + clean destroy with in-flight/undrained jobs) and narrated reactive/56_reactor_core 6/6. regs 1062->1068. SLICE 2 LANDED (session 71): async TCP request on the reactor (uv_getaddrinfo->uv_tcp_connect->uv_write->uv_read_start-to-EOF state machine per job; worked around Zig translate-c's libuv uv_stream_t<->uv_read_cb dependency loop via opaque handle/req buffers + hand-written externs with data at offset 0); Ring classes stzReactor + stzReactorPool (N libuv loops, round-robin parallel fetch); StzEngineReactorSubmitTcp/TcpAwait/TcpPoll/TcpLastStatus. TraceContext landed too (tracectx.zig in the default sweep + stz_tracectx DLL + stzTraceContext + stzHttpClient.StartTrace) for W3C traceparent propagation. Tests: reactor.zig 7/7 Zig incl. LIVE async TCP round-trip; tracectx.zig 4/4; narrated reactive/56 6/6, 57 6/6, 58 4/4 (pool), network/70 10/10 (trace). DLLs 89->90, regs 1068->1078, classes 128->131. Deliberate non-goal: NOT refactoring the working blocking tcp.zig / polling timer onto the reactor (regression risk > upside; reactor is the forward path for new async). The libuv reactor feature is COMPLETE. **HTTP-STACK DECISION RESOLVED (sessions 72): adopted vendored libcurl.** engine/vendor/curl (8.20.0, CMake-free via config-win32.h, native Schannel TLS) + engine/vendor/nghttp2 (1.69.0) give HTTP/1.1 + HTTP/2 + TLS + connection pooling + DNS cache + redirects in one battle-tested stack; httpcore.zig/http_pool.zig RETIRED. http.zig now drives curl_easy over a thread-safe CURLSH share (connection/DNS/TLS-session reuse); same C-ABI so the Ring API + full network suite (52-71) stay green. HTTP/2 negotiates over ALPN (verified live vs nghttp2.org + cloudflare); StzEngineHttpLastVersion reports it. Required a one-line vendored-curl patch (lib/easy.c: run Curl_win32_init before Curl_ssl_init so Schannel's ALPN OS-version gate uses accurate RtlVerifyVersionInfo, not the manifest-lying VerifyVersionInfoW that silently disabled h2 for an unmanifested host). HTTP/3 deferred (needs ngtcp2/quiche QUIC stack). Engine version string: libcurl/8.20.0 Schannel nghttp2/1.69.0. **TIER 2 COMPLETE for the shipped scope** (libuv reactor + async timer/TCP + multi-loop pool + TraceContext + libcurl HTTP through HTTP/2). **HTTP/3 DEFERRED (decision s72):** Schannel can't serve curl's QUIC, so every h3 path is a bad trade -- wolfSSL+ngtcp2+nghttp3 would rip out the working Schannel h1/h2 stack + ship a CA bundle, and msh3+msquic needs a curl bump + a prebuilt binary (breaks from-source rule); h3 degrades to h2 with zero functional loss. Revisit when curl restores msh3 (reuse Schannel) or OpenSSL 3.5 QUIC matures. True work-stealing scheduler also deferred (multi-loop pool covers scale). **HTTP FEATURE-COMPLETION (session 74):** capitalized on libcurl to expose its full surface through stzHttpClient -- real Basic/Digest/NTLM/Bearer auth (CURLOPT_USERPWD/HTTPAUTH/XOAUTH2_BEARER), proxy + proxy auth, mTLS client certs (SSLCERT/SSLKEY), persistent cookie file/jar, response-header capture (HEADERFUNCTION -> ResponseHeaders()), SSL-verify + follow-redirect toggles now actually drive the engine, and gzip/deflate auto-decompression via vendored zlib 1.3.1. Implemented as a per-request 'options blob' (key=value lines parsed by curlcore.applyOpts -> CURLOPTs) carried by new StzEngineHttpRequestEx; StzEngineHttpLastHeaders added; stub/warning setters (the old SetAuth that only warned) retired. Engine: libcurl/8.20.0 Schannel zlib/1.3.1 nghttp2/1.69.0. Tests: 72_http_features 13/13 (deterministic opts-blob + live auth/headers/gzip); full network suite (52-72) green. regs 1080->1082. **HTTP TEST-HARDENING (session 75):** new stz_testsrv DLL -- a std.net loopback HTTP server (engine/src/testserver.zig, 127.0.0.1, detached thread-per-conn, raw posix recv/send) serving canned responses by path (/status /headers /echo /big /slow /redirect /auth /setcookie /checkcookie). New 73_http_loopback 15/15 exercises the integration seam DETERMINISTICALLY + OFFLINE (CI-runnable, no public internet): exact non-2xx codes, response-header capture, POST echo, large body, the overflow (-2) path, redirect on/off, request-timeout firing, auth 401/200, cookie round-trip via a jar file. Converts the manual internet-dependent smoke into an automated regression net. DLLs 91, regs ->1084. See base/doc/design/TIER2_REACTOR_DIRECTION.md.",
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
        .summary = "Sessions 38-54: 48 regression suites, ~1593 assertions, 95 cumulative latent bugs. Sessions 52-54 (2026-06-13) closed the external-domain coverage gap + the previously-pending narrated runner + reactive harness items. Bug-pattern catalogue: 17 families. **Classic->narrated conversion resumed (session 76)** -- each new suite RUN for real + fixed, randomness scenarios run 6-8x to confirm no flakiness: listofnumbers/00_listofnumbers_narrated (28/28; surfaced + fixed a latent bug -- NSmallestNumbers/NLargestNumbers chained .SortUpQ()/.FirstNItems() which don't exist on stzList -> R14; now .SortInAscendingQ()/.Section(1,n)/.LastNItems()), uuid/00_uuid_narrated (17/17; format+version+variant+validity + 500-generation uniqueness invariant). Pattern for random ops: assert length/range/uniqueness invariants, NOT the stale one-off #--> sample values. **Session 77 added 6 more domain suites** (each run for real): counter/00 9/9, random/00 7/7 (run 5x; ARandomNumberBetween/random01 bounds, Some() subset, Randomize permutation+actually-shuffles), ordinal/00 12/12 (en+fr), octalnumber/00 7/7 (fixed stale formats: ctor needs 0o, FromHex/FromBinary need 0x/0b), decimaltobinary/00 4/4, binarynumber/00 5/5. Skipped plural/singular -- their morphological rule pipeline is incomplete (function defect, not test work; won't lock in broken behavior). 8 domains converted total this arc + 1 latent bug fixed. **Session 78 added 3 more** (each run for real): duration/00 28/28 (seconds + natural-language ctor, components, arithmetic +/-/*//, comparisons, ToString/ToHuman/ToCompact, in-place mutators), hashlist/00 18/18 (HasKey/HasKeys/HasKeysXT/HasPath safe-access + stzHashList keys/values/lookups + named hashlist), listofstrings/00 10/10 (concat/count/find/case/reverse/sort/dedup). Flagged 2 real latent defects rather than locking them in: stzListOfBytes NumberOfBytes/Bytecodes use codepoint-length where byte-length is needed (wrong on multibyte), and stzListOfStrings.SortBy prepends a spurious empty element. 11 domains converted total this arc + 1 fixed + 2 flagged. **Session 79 added 2 more + fixed a 2nd latent bug**: list2d/00 6/6 (Content verbatim, Transposed non-mutating + source-intact, TransposeQ in-place, involution invariant transpose-twice==original, global Transpose parity), listofchars/00 7/7 (codepoint + range construction, NumberOfChars, Unicodes round-trip, NumberOfUniqueChars; asserts on codepoints not glyphs to keep console ASCII-clean). Fixed: stzStringCharList.Concatenated() looped 'for i = 1 to nLen' on an uninitialized var (len is _nLen_) -> R24 crash that broke NumberOfUniqueChars; one-char fix nLen->_nLen_. 13 domains converted total this arc + 2 latent bugs fixed + 2 defects flagged. **Session 80 landed the 2 flagged defects + 3 more domains**: the stzListOfBytes byte/codepoint fix (Bytecodes/NumberOfBytes StzLen->len) and the stzStringList.SortBy spurious-empty fix (explicit shallow-copy loop) were verified end-to-end and committed; listofbytes/00 11/11 (byte counts ASCII vs multibyte, Bytecodes, NumberOfBytesPerChar, ToHex 0x-prefix, byte-accurate slicing -- asserts byte codes/counts not glyphs), listofstrings/00 grew to 12/12 (+2 SortBy assertions now the bug is fixed), listoflists/00 11/11 (jagged Sizes/MinSize/MaxSize/HowManyMissing/FindMissing/NthList/NthCol/@IsListOfLists; classic Sizes [4,2,2] was stale -> [4,3,2]), listoftimelines/00 9/9 (stzTimeLines GlobalStart/End/Duration/DurationQ.ToHuman/NumberOfLanes/Lanes uppercased + date-only From auto-time). 16 domains converted total this arc + 2 latent bugs fixed (both flagged defects now resolved). **Session 81 added 2 more + fixed 2 more latent bugs**: hexnumbert/00_hexnumber 12/12 (HexPrefixes/RepresentsNumberInHexForm/HexToDecimal; Content/WithPrefix/ToDecimal/ToBinary/ToOctal; FromDecimal round-trip -- ctor now needs 0x like octal) with fix stzHexNumber.From*Form stored the PREFIXED ToHexForm() into @cHexNumber so Content()='0x167A'/WithPrefix()='0x0x167A' doubled -> added _StripHexPrefix() helper; char/00_char 18/18 (name<->codepoint via Unicode names, case mapping, IsLetter/IsDigit/IsSpace/IsPunctuation/IsUppercase/IsLowercase, IsVowel) with fix stzStringChar.IsVowel called the inherited stzString.Vowels() (vowels-in-content, []) instead of the alphabet so it ALWAYS returned FALSE -> rewrote to test the codepoint against the ASCII vowel set. 18 domains converted total this arc + 4 latent bugs fixed. **Session 82 added 3 more + fixed a 5th latent bug**: grid/00_grid 13/13 (stzGrid dimensions, relative MoveUp/Down/Left/Right, edge clamping, absolute MoveToCell/First/Last; CurrentPosition is [col,row]) with fix stzGrid.MoveToCell alias had an EMPTY body (no-op) -> added the missing This.MoveToNode call; json/00_json 10/10 (IsJsonList/IsJsonString predicates, ListToJson compact + nested, JsonToList pairs/nested/arrays, round-trip identity); csv/00_csv 7/7 (CSVSeparator default ';' + SetCSVSeparator round-trip, IsCSV, CSVToList column-major, ListToCSV). 21 domains converted total this arc + 5 latent bugs fixed. **Session 83 added 3 more**: namedvars/00 6/6 (dynamic Vr/Vl/v/vxt/VrVl named variables), dataset/00 12/12 (stzDataSet descriptive stats -- Mean/Median/Range/Sum/Min/Max/Count exact + StdDev/Variance/CoVar/Geometric/HarmonicMean rounded via Rnd2 to dodge float-eq flakiness), func/00 24/24 (IsNull/IsEmpty sentinel-aware + IsTrue/IsFalse primitive truthiness; classic IsTrue([])=TRUE was stale, empty is falsy). Flagged 1 defect: IsTrueXT/IsFalseXT crash (R19) on objects -- the isObject branch calls IsTrueObject()/IsFalseObject()/IsNullObject() without passing the object. 24 domains converted total this arc + 5 latent bugs fixed + 1 flagged. **Session 84 added 3 more**: listofhashlists/00 12/12 (stzListOfHashLists construct/NumberOfItems/IsEmpty/Content + ToListOfStzHashLists -> stzhashlist objects + empty edge), orgchart/00 10/10 (stzOrgChart hierarchy AddExecutive/Manager/StaffXT+ReportsTo, NodeCount/EdgeCount, DirectReports(N), vacancy VacantPositions/VacancyRate, Assign+PersonData), entity/00 9/9 (stzEntity Name/Type/Property get+set+add/HasName; avoids volatile Created timestamp). 27 domains converted total this arc + 5 latent bugs fixed + 1 flagged. **Session 85 added 2 more + fixed a 6th latent bug**: locale/00 9/9 (stzLocale C-locale case mapping + en_US/fr_FR identity Abbreviation/CountryName/LanguageName/CountryNumber from stzlib data tables), knowledgegraph/00 11/11 (stzKnowledgeGraph triples AddFact/RemoveFact/Facts lowercased-predicates, NodeExists, pattern Query with ?vars + existence check, Predicates/Relations). Fix: stzGraph.RemoveThisEdge matched edge from/to RAW while ids are StzLower-normalised (every other method lowercases its lookup args) -> RemoveFact was a silent no-op; added StzLower (idempotent). Skipped linearsolver -- greedy solver returns clearly suboptimal results (deterministic but not worth locking; LP verification out of scope). 29 domains converted total this arc + 6 latent bugs fixed + 1 flagged. **Session 86 added 2 more**: datawrangler/00 6/6 (stzDataWrangler list cleaning: TrimWhitespace/RemoveDuplicates/NormalizeCase(lower/upper)/HandleMissingValues + full pipeline via GetData), date/00 15/15 (stzDate fixed-date components Day/DayNumber/Month/MonthNumber/Year/DayOfYear/IsLeapYear + arithmetic AddDays/AddMonths/AddYears + DaysTo/IsBefore/IsAfter; no clock-dependent Today/Tomorrow). Flagged 1 defect: stzPivotTable intermittent R31 (StzUpper GC self-ref in SetAggregateFunction) on COUNT for certain grouping shapes; skipped pivottable (would flake CI). Skipped chainofvalue (DSL with print side-effects + randomness). 31 domains converted total this arc + 6 latent bugs fixed + 2 flagged. **Session 87 added datetime + a 7th fix**: datetime/00 13/13 (stzDateTime fixed-timestamp Content/ToEuropean(12h)/ToEuropeanWithoutAmPm(24h), components Year/Month/Day/Hours/Minutes/Seconds, AddHours/AddDays, IsBefore/IsAfter; no clock-dependent Now). Fix: added missing @StzMid alias in stzPrimitives (stzMatrex called @StzMid ~30x but only bare StzMid existed -> R3 at construction). Flagged stzMatrex.Match as broadly broken (size/shape always FALSE; Rows/Cols don't validate) -> no matrex suite shipped. 32 domains converted total this arc + 7 latent bugs fixed + 3 flagged. **Session 88 added 2 more**: html/00 10/10 (stzHtml parse + query: CountByTag, Find/FindFirst + element Text, Klass/HasClass; classic IsValid/HasBody/TagsUsed are gone), listparser/00 10/10 (stzListParser List/Start/End/NumberOfSteps/CurrentPosition + Parse(From/To/Step) -> ParsedPositions/ParsedItems + NextItem cursor). Flagged stzNumbrex.Match (always TRUE -- same broken-Match family as matrex). Skipped dotcode (View()/render side-effects, not assertable). 34 domains converted total this arc + 7 latent bugs fixed + 4 flagged. **Session 89 added 2 more**: cluster/00 14/14 (stzLoadBalancer routing stats/RegisterCluster/FindCluster/replace-semantics + stzClusterNode UpdateMetrics/IsOverloaded/GetHealthStatus), graphquery/00 6/6 (stzGraphQuery fluent MATCH/Select: match-all, by-label, by-property :where). 36 domains converted total this arc + 7 latent bugs fixed + 4 flagged. **Session 90 added 2 more**: graphplanner/00 4/4 (stzGraphPlanner A* WalkFrom/Minimizing/Execute -> Cost/Route; linear path + branching where A* picks the cheaper route), i18n/00 7/7 (stzLanguage code->name/country + stzCountry by name/abbreviation, lowercased data tables). Flagged stzMatrix mutators (Add/Multiply call RingFastPro updateList which stzBase doesn't load -> R3; read-only Determinant/Size/Diagonal work). Skipped object (truthiness overlaps func; IsAString/IsEitherA quirky), naturalmarkup (fragile NLP DSL), dotcode (render side-effects). 38 domains converted total this arc + 7 latent bugs fixed + 5 flagged. **Session 91 added 2 more**: calendar/00 9/9 (stzCalendar fixed [year,month]: Year/MonthName/TotalDays, SetWorkingDays + IsWorkingDay + WorkingDays count, AddHoliday/IsHoliday/HolidayName), misc/00 12/12 (stzlen/stzleft/stzright primitives, ring_del returns-the-list, @substr replace/find/slice, @Min/@Max). Flagged: English morphology pipeline (Adverb/Plural/Singular -- happy->happyily, basic->asian), stzCurrency (Name/Currency return single char, Russia->RON not RUB). 40 domains converted total this arc + 7 latent bugs fixed + 7 flagged. **Session 92 REPAIRED the Match-family defects** (2 previously-flagged): found the shared root cause -- stzNumbrex AND stzMatrex parsers used @StzMid with end-based (start,end) args while the global @StzMid is COUNT-based (start,count), so patterns never tokenised (numbrex Match -> always TRUE on empty token loop; matrex Match -> always FALSE). Fixed both by routing all 40 @StzMid calls each through an end-based _Mid(s,n1,n2)=@StzMid(s,n1,n2-n1+1) helper. numbrex/00 15/15 (Prime/Perfect/Fibonacci/Even/Odd/Square/Composite/Positive, match + non-match each), matrex/00 8/8 (Size exact, mxn any, shape(square)). 42 domains converted total this arc + 9 latent bugs fixed + 5 flagged remaining. **Session 93 REPAIRED IsTrueXT/IsFalseXT** (flagged): 3 bugs in StzIsTrueXT's isObject branch -- (1) R19 crash, sentinel predicates called without the object arg -> pass p; (2) IsStzTrueObject checked classname='stzfalseobject' (copy-paste) so it was inverted -> 'stztrueobject'; (3) NullObject branch returned 1 when null configured FALSE -> flipped. Now IsTrueXT(TrueObject)=TRUE/FalseObject=FALSE/NullObject=FALSE, IsFalseXT(FalseObject)=TRUE; primitives + existing object/func tests stay green. func/00 grew to 32/32. 42 domains converted + 12 latent bugs fixed + 4 flagged remaining. **Session 94 REPAIRED matrix engine-first** (flagged): stzMatrix Add*/Multiply* mutators crashed R3 calling the removed RingFastPro updateList(). Per the engine-first direction (all non-engine deps dropped -- engine is the sole backend), added a NEW engine fn stz_matrix_update_region(m,op,r1,r2,c1,c2,val) to matrix.zig + bridge StzEngineMatrixUpdateRegion, and routed all 11 call sites through a Ring _UpdateRegion() that ensures the engine matrix, applies the op in-engine, syncs @aMatrix back. matrix/00 13/13 (Size, scalar Add/MultiplyBy, AddInCol/Row, MultiplyCol/Row/Rows, Determinant). matrix was the last RingFastPro user -> dependency fully gone. Engine zig build + zig build test clean. 43 domains converted + 13 latent bugs fixed + 3 flagged remaining. **Session 95 added 2 more**: time/00 12/12 (stzTime fixed-string ctor, Hours/Minutes/Seconds, HH:mm normalisation, AddHours/AddMinutes rollover, IsBefore/IsAfter/IsAfternoon/Hours12), tree/00 6/6 (stzTree Nodes/Items/Node/Branches + counts). (datetime/00 13/13 already existed.) currency fix is mid-flight in its own worktree (Russia/US now correct -> RUB/USD; France Abbreviation still R2) -- left to that session, not double-edited here. 45 domains converted + 13 latent bugs fixed + 3 flagged remaining. **Session 96 began the core-domain suites**: regex/00 8/8 (PCRE2 stzRegex: Match presence/absence, AllMatches+NumberOfMatches, char classes, anchors+exact quantifiers, capture-group extraction; partial-match MatchAsYouType/MatchInProgress left out -- they return FALSE where classic expects TRUE, i.e. partial matching unwired), number/00 15/15 (engine stzNumber: Factorial/GCD/LCM/Fibonacci, IsPrime/IsEven/IsOdd/IsMultipleOf, Power/Abs/IsNegative/IsPositive/Digits). 47 domains converted + 13 latent bugs fixed + 3 flagged remaining. **Session 97 added the 3 core giants** (representative suites): string/00 14/14 (case, codepoint-correct length incl multibyte, reverse/contains/find, replace/split, trim/equality/slicing), list/00 16/16 (count/membership/find-positions/occurrences, reverse/sort/dedup, add/first/last/section, sum/isempty), table/00 12/12 (shape, Col/Cell/Row, HasCol presence, Copy independence). Fixed a 14th latent bug: stzTable.HasColumName lowercased the query then did a case-SENSITIVE Contains against as-stored upper names -> always FALSE; fixed to ContainsCS(name,FALSE). 50 domains converted + 14 latent bugs fixed + 3 flagged remaining. **Session 98 added graph/00 9/9** (stzGraph: NumberOfNodes/Edges/NodesIds; Neighbors incl sink; ShortestPath; IsConnected; ConnectedComponents) + fixed a 15th latent bug: stzGraph.Neighbors pure-Ring fallback compared the RAW arg against StzLower-normalised edge endpoints -> Neighbors('A') empty while ('a') worked; lowercased the query (same family as the earlier RemoveThisEdge case fix). 51 domains converted + 15 latent bugs fixed + 3 flagged remaining. **Session 99 -- STRATEGIC: activated the Zig graph engine backend for stzGraph** (it powers knowledgegraph/graphquery/graphplanner/orgchart). stzGraph already had full engine wiring but _EngineAvailable() probed isFunction('stzenginegraphcreate'), and isFunction() can't see NATIVELY-registered bridge functions -> always FALSE -> EVERY graph op silently ran the slow pure-Ring fallbacks. Fixed detection to isPointer($pStzGraphHandle); activation exposed a separator mismatch (engine neighbors/shortest_path/reachable emitted comma vs the newline _SplitNewline/toposort use) -> standardized those engine funcs to '\\n'. Now Neighbors/ShortestPath/PathExists/HasCycle/Reachable/TopologicalSort/In+OutDegree/components run in-engine. Verified graph/00 10/10 (asserts engine active) + knowledgegraph/graphquery/graphplanner + graph classics green. Repo scan: no other isFunction(stzengine) dead-path anti-patterns. 16 latent bugs fixed total. Remaining flagged: pivottable R31, morphology, currency.",
    },
    .{
        .id = "M-S3",
        .track = "stzlib",
        .title = "Documentation Reimagining",
        .status = .planned,
        .summary = "6 doc types (API reference / how-to / tutorials / paradigm narrations / architecture / quick-ref cards); 60+ existing narrations to curate; top-10 class API references to generate",
    },
    .{
        .id = "M-S4",
        .track = "stzlib",
        .title = "Engine-First String Refactor",
        .status = .done,
        .summary = "Sessions 50+: Ring substr/loop -> Zig engine rewrite. Phase A done 2026-06-12: 354 string ERR -> 0; 320 substr->Stz + StzMid defensive + StzMidToEnd / StzCodepoint primitives added. Phase B done 2026-06-13: 87 of 117 Chars()-walk sites refactored to engine primitives (count-walks, predicate-walks, find-walks, transform-walks, sort-via-stzList, edge-guard, leading/trailing-run family). Engine fns used: StzEngineStringCountLeading/TrailingChar, StzEngineStringCharAt, StzEngineStringIsAlpha/IsDigit, StzEngineStringContainsLatin/Arabic, StzEngineStringSwapCase, StzEngineStringUniqueChars, StzEngineStringTrimLeft/Right, StzEngineStringSpacify. 30 sites kept as Chars() walks -- predicate-eval loops with @char binding (Check/WalkForwardW/CharsWXT etc), byte-walk inspectors (BytesPerChar/Bytecodes family), complex multi-position mutations (ReplaceCharsAtPositions, SimplifyExcept, ReplaceAllExcept, Bounds, Combinations), or per-codepoint isAlpha checks (LeadingSubString/TrailingSubString). All deliberate. Side effect: 5477 ring_len() calls swept to len() across 252 files (8b15e3b3). M-S4 closed.",
    },
};
