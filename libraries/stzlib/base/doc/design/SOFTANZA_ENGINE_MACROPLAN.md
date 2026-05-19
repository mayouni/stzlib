# Softanza Engine -- Macro Plan

> **Living document.** Updated at every progress milestone.
> Cross-reference: `base/doc/internals/SESSION_CONTINUITY.md`
> for per-session details.

---

## Status Summary

| Metric            | Value                    |
|-------------------|--------------------------|
| Modules designed  | 88                       |
| Modules built     | 11                       |
| Design principles | 19                       |
| Engine tests      | 622 passing              |
| DLLs shipping     | 8 (4 Core + 4 Base)      |
| Qt dependencies   | 0 (fully purged)         |
| Ring bridge regs  | 398 DLL functions        |
| Ring Unicode hard | Complete (all domains)   |
| Last updated      | 2026-05-19 (Session 18)  |

---

## ACHIEVED

### Phase 1 -- Layer Audit & Architecture (Session 1)

- Three-layer audit (Core/Base/Max/Future) completed
- Fixed Max loader (10 duplicate loads removed)
- Layer architecture contract established
- Engine design doc created

### Phase 2 -- Engine Bootstrap: 11 modules DONE (Sessions 1-2)

| Module       | Functions | Replaces              |
|--------------|----------:|-----------------------|
| stz_string   |        20 | QString2              |
| stz_char     |         6 | QChar                 |
| stz_bytes    |         — | Binary data           |
| stz_datetime |        50 | QDate/QTime/QDateTime |
| stz_file     |        17 | QFile/QDir/QFileInfo  |
| stz_locale   |        10 | QLocale               |
| stz_regex    |         — | QRegularExpression    |
| stz_json     |         — | QJsonDocument         |
| stz_url      |         — | URL parsing           |
| stz_system   |         — | System info           |

8 DLLs built (Core + Base tiers). 40 tests passing.

### Phase 3 -- Qt Purge (Session 2)

- ALL Qt code paths removed from Core and Base
- Engine-only: no fallback, no feature flags, no Qt dependency
- Ring FFI bridges wired per domain

### Phase 4 -- Modular DLLs + CLI (Session 3)

- Split monolithic Engine into per-domain DLLs
- Layered DLLs: stk_* (Core) / stz_* (Base) / stx_* (Max, future)
- Softanza CLI: `version`, `doctor`, `help`, `run`, `test`, `build`

### Phase 5 -- Deep Design: 86 -> 88 modules (Sessions 4, 4b)

- Full audit of 60+ paradigm documents + 10 source implementations
- Layer 5: 12 Paradigm Engines designed with full C ABI
- Layer 6: 14 Universal Computation modules designed with full C ABI
- 3 Value Propositions codified: Testability, Usability, Learnability
- 2 VP modules added: stz_interact, stz_skill
- 19 design principles in Architecture doc

### Phase 6 -- String Engine v2 Design (Session 6)

- Critical audit: ASCII-only CI ops, memory leak, 206 catch {},
  no UTF-8 validation, O(n^2) iteration identified
- Deep research: Softanza DSL suffix system (Z/ZZ/CS/XT/Q/IB/W),
  stzRegex/stzListex/stzGraphex, i18n subsystem
- Design document: `STRING_ENGINE_DESIGN_v2.md` created
- 8-phase implementation plan (Naming, Safety, Performance,
  Modules, Regex, Locale, NLP, Crypto)
- 14 stzString methods already Engine-backed, 630 Ring tests pass
- Naming convention: `str_` prefix, verb/noun discipline, CS pattern
- 1-based indexing by default with compile-time config flag

### Phase 6+ -- String Engine v2 Phase A Implementation (Session 7)

- **1-based indexing**: INDEX_BASE=1, toInternal/toExternal helpers,
  ~30 functions converted (all codepoint position I/O)
- **Unicode CI**: 9 toLowerAscii call sites -> casefold, equals_ci
  leak fixed, foldcase + trim_left/right Unicode-aware
- **NLP primitives**: Jaro-Winkler, Metaphone, char/word n-grams
- **CS merge**: 13 unified _cs functions (case parameter), old
  CS/CI names become thin wrappers
- 411 Zig tests, 652 Ring bridge tests, 339 registered functions
- **str_ prefix rename** (Session 8): all `stz_string_*` -> `str_*`
  across string.zig, ring_bridge_string.zig, engine.zig, entry files.
  No migration aliases (no user base). Phase A complete.
- **Phase B safety audit** (Session 8): str_last_error/str_clear_error
  with StrError enum (5 codes), UTF-8 validation in str_from, null-
  termination in str_data, all 128 catch {} sites set error state.
  423 Zig tests, 658 Ring bridge tests, 341 registered functions.
- **Phase C performance** (Session 8): StzString gains cached_cp_count
  and cached_is_ascii with lazy computation + mutation invalidation.
  ASCII fast-paths for codepointIndexToByteOffset, utf8CodepointCount.
  Boyer-Moore-Horspool search for needles > 4 bytes on ASCII strings.
  434 Zig tests, 658 Ring bridge tests, 341 registered functions.
- **Phase D module separation** (Sessions 8-11): Eight submodules extracted:
  `string/core.zig` (StzString, lifecycle, error, indexing, helpers),
  `string/encode.zig` (25 fns: URL/hex/base64/binary/HTML/morse/CSV/
  quote/ciphers/hash/entropy), `string/nlp.zig` (18 fns: Levenshtein/
  Hamming/Jaro/JW/Jaccard/Soundex/Metaphone/n-grams/extraction/
  pluralize/pig-latin/NATO/mask-email), `string/split.zig` (26 fns:
  split/word/line/partition/chunk/sentence/chars-split),
  `string/find.zig` (37 fns: index_of/find_all/last_index_of/
  count_of/contains/starts_with/ends_with/equals/find_nth/
  find_all_char, all with CS/CI variants),
  `string/replace.zig` (39 fns: replace/remove/insert/strip/keep),
  `string/transform.zig` (19 fns: case transforms -- upper/lower/
  title/camel/snake/kebab/pascal/dot/path/constant/spongebob/
  alternating/sentence/capitalize/decapitalize/swap/foldcase),
  `string/inspect.zig` (38 fns: is_*/predicate checks -- empty/
  numeric/alpha/palindrome/ascii/case/type/sorted/anagram/pangram/
  balanced/email/url/float/identifier/isogram).
  `string/extract.zig` (23 fns: mid/left/right/nth_char/slice/chars/
  char_at/mid_cp/left_cp/right_cp/grapheme_count/normalize/strip_marks/
  between/between_nth/count_between/substring/chars_between/cp_count),
  `string/trim.zig` (22 fns: trim/trim_left/trim_right/simplify/
  trim_chars/pad_left/pad_right/center/center_pad/zfill/ljust/rjust/
  left_pad/right_pad/indent/dedent/tab_expand/expand_tabs/
  collapse_spaces/normalize_spaces/squeeze/squeeze_char),
  `string/count.zig` (25 fns: count_chars_of_type/find_chars_of_type/
  extract_chars_of_type/char_type_at/unique_chars/unique_char_count/
  count_char/count_leading/trailing_char/count_overlapping/
  count_any_char/count_runs/count_vowels/consonants/longest_run/
  count_sentences/digit_sum/count_upper/lower/count_unique_chars/
  count_paragraphs/count_substring/count_words_matching/count_digits/
  count_spaces),
  `string/compare.zig` (11 fns: compare/common_prefix/common_suffix/
  prefix_count/suffix_count/common_chars/longest_common_prefix/suffix/
  hamming_weight/commonality/diff_chars),
  `string/format.zig` (47 fns: reverse/repeat/concat/copy/sort_chars/
  repeat_char/rotate/repeat_to_length/swap_chars/mirror/
  repeat_each_char/spacify/bytes_per_char/char_frequency/truncate/
  wrap_at/ensure_prefix/suffix/only_letters/digits/vowels/interleave/
  surround/mask/slug/camel_to_words/initials/title_smart/
  reverse_words/sort_words/unique_words/run_length_encode/decode/
  and more formatting/word-level ops).
  `string.zig` is now a pure re-export hub + tests (zero function bodies).
  584 Zig tests, 658 Ring bridge tests, 341 registered functions.
  Phase D COMPLETE -- 13 submodules, ~250 functions extracted.

### Phase 7 -- Ring-Side Unicode Hardening (Sessions 15-16)

- **Comprehensive audit**: ~180 byte-level usages across 18+ files scanned.
  Classified as "needs fix" vs "safe (ASCII-only intent)".
- **Critical path fixes**: stzStringLeadTrail, stzStringWords, stzStringLocale,
  stzStringText, stzStringVisualizer, stzStringDuplicates, stzStringFinder,
  stzStringChar, stzStringLines, stzStringExtractor, stzStringInserter,
  stzStringComparator, stzStringRemover, stzStringReplacer, stzStringSplitter.
- **Patterns fixed**: `len(pcSubStr)` -> `StzLen()` for codepoint position
  arithmetic. `substr(str, i, 1)` byte-level char access -> `@oString.NthChar(i)`
  or `Chars()` iteration. `Content()[i]` byte indexing -> `Chars()[i]`.
  `char(n)` for non-ASCII -> `StzChar(n)`.
- **Confirmed safe**: stzStringEncoder (hex/base64), stzStringCrypto (ASCII
  ciphers), stzStringIO (file paths), stzStringNumbers (ASCII digits 0x30-0x39),
  stzStringChecker (format checks), stzStringCode (syntax parsing).
- **Engine additions**: str_duplicated_chars (O(n) hashmap), cpToByteCached
  (O(n) sequential access cache in StzString struct).
- **Stats**: 604 Zig tests, 389 Ring bridge functions, all 9 Ring test suites pass.
  Unicode hardening COMPLETE across all active domain classes.

### Phase 8 -- Code Deduplication & Bulk Engine Ops (Session 17)

- **`_SplitNullDelimited()` centralization**: Created global helper in stzStringFunc.ring
  to eliminate repeated null-byte delimiter parsing boilerplate (~60 lines removed).
  Used by: DuplicatedChars, UniqueChars, SubStringsCS, Chars(), stzStringCharList.
- **`Chars()` bulk optimization**: Replaced N individual `NthChar(i)` FFI calls with
  single `StzEngineStringCharsSplit()` call + `_SplitNullDelimited()`.
- **`Words()` engine migration**: Replaced Ring-side char-by-char word parsing with
  engine `str_words_split()` + `_SplitNullDelimited()`.
- **Engine additions**: `str_words_split` (null-delimited word list, Unicode-aware
  whitespace splitting).
- **stzStringCharList cleanup**: Removed private `_SplitNullDelimited` method (uses
  global), replaced inline null-split in init() with helper call.
- **Engine additions**: `str_sort_null_items` (O(n log n) sort on null-delimited items),
  `str_unique_null_items` (O(n) hashmap dedup on null-delimited items).
- **stzStringList Sort/Unique migration**: O(n^2) insertion sort with per-comparison
  handle create/free replaced with engine O(n log n) sort. O(n^2) nested-loop dedup
  with per-pair handle create/free replaced with engine O(n) hashmap dedup.
- **Standalone Chars() optimization**: stzStringFunc `Chars()` migrated from N
  individual NthChar FFI calls to single `StzEngineStringCharsSplit` call.
- **stzStringList FFI handle elimination**: Eliminated per-iteration engine handle
  creation/destruction in 8 methods: ContainsCS, FindCS, ContainsSubStringCS,
  FilterCS, FilterByStartsWithCS, FilterByEndsWithCS (replaced with Ring string
  comparison + StzCaseFold for CI), ToUpper/ToLower (replaced with StzUpper/StzLower
  wrappers). JaroWinkler methods (MostSimilarTo, SimilarToCS) kept engine handles
  as computation requires the engine.
- **stzStringList test suite**: Added test_stringlist.ring covering ContainsCS,
  FindCS, ContainsSubStringCS, FilterCS, FilterByStartsWithCS, FilterByEndsWithCS,
  ToUpper/ToLower, SortInAscending, UniqueItems (17 assertions).

### Phase 9 -- Engine Migration: Inserter, Finder, Lines (Session 18)

- **Engine additions**: `str_insert_before_each_cs`, `str_insert_after_each_cs`
  (Unicode casefold matching for CI insert), `str_unique_lines_ci` (O(n) casefold
  hashmap dedup preserving first occurrence case), `str_reverse_lines`.
  8 new Zig tests (622 total). 4 new bridge functions (398 total).
- **stzStringInserter migration**: `InsertBeforeSubStringCS` and
  `InsertAfterSubStringCS` migrated from O(n) find-then-shift Ring loop
  to single engine `InsertBeforeEachCS`/`InsertAfterEachCS` call.
- **stzStringFinder migration**: `FindNthCS` migrated from iterated
  find-next Ring loop to direct `StzEngineStringFindNthCS` engine call.
- **stzStringLines migration**: `UniqueLinesCS` CI path migrated from
  O(n^2) Ring nested loop with per-pair StzCaseFold to single engine
  `UniqueLinesCI` call. `ReverseLinesOrder` migrated from Ring string
  rebuild loop to engine `ReverseLines` call.
- **Test suites**: Added test_inserter.ring (7 assertions).
- **Stats**: 622 Zig tests, 398 Ring bridge functions, all Ring test suites pass.

---

## MILESTONES AHEAD

### M-E0.5: String Engine v2 [ ]

> Redesign the string engine for Unicode correctness, Softanza
> naming, 1-based indexing, and modern domain coverage.
> See `STRING_ENGINE_DESIGN_v2.md` for full design.

**8 phases:** A (Naming & Indexing) -> B (Safety) ->
C (Performance) -> D (Module Separation) -> E (Regex) ->
F (Locale) -> G (NLP/AI) -> H (Crypto)

**Why before M-E1:** The string module is the most-used Engine
component. Fixing its naming, safety, and Unicode correctness
now prevents all downstream modules from inheriting the same
patterns. The CS merge and 1-based indexing set conventions
that StzValue and StzList will follow.

### M-E1: Foundation Types [ ]

> Build `stz_value` (StzValue tagged union) + `stz_number`
> (BigInt, Decimal, 64-bit).

**Why first:** Every module above Layer 0 depends on StzValue.
This kills the Stringify trick and unlocks heterogeneous
collections.

**Deliverables:**
- `engine/src/value.zig` with tagged union + C ABI
- `engine/src/number.zig` with BigInt + Decimal
- Ring FFI bridges for both
- Tests at all 4 layers

### M-E2: Core Collections [ ]

> `stz_list` (heterogeneous dynamic array), `stz_hashmap`,
> `stz_set`.

**Why:** Lists are Softanza's most-used structure. HashMap
enables named-parameter dispatch. Set enables unique-element
operations.

**Depends on:** M-E1 (StzValue)

### M-E3: Extended Collections [ ]

> `stz_table`, `stz_graph`, `stz_matrix`, `stz_tree`.

**Why:** Targets for the universal operations paradigm
(Find/Replace/Contains work on ALL structures).

**Depends on:** M-E2 (List, HashMap)

### M-E4: Algorithms [ ]

> `stz_stats`, `stz_text`, `stz_walker`, `stz_checker`,
> `stz_yielder`, `stz_performer`.

**Why:** Walker replaces all index-based loops. Text and stats
are high-frequency. Checker/Yielder/Performer complete Ring
workaround elimination.

**Depends on:** M-E2 (collections)

### M-E5: Infrastructure Services [ ]

> 25 modules: crypto, codec, compress, stream, watch, process,
> async, uuid, html, rng, solver, geo, bits, expr, embed,
> registry, smallfn, execmodel, cache, log, profiler, callstack.

**Why:** Plumbing that signature features and paradigm engines
build on. Stream and async are prerequisites for Reaxis.

**Depends on:** M-E1 (StzValue), partially M-E2

### M-E6: Signature Features [ ]

> 11 modules: pattern, numtheory, natlang, ccode, constraint,
> reactive, knowgraph, splitter, stringart, display, univops.

**Why:** What makes Softanza unique at the feature level --
PatternEx family, natural language bridge, universal operations,
display engine.

**Depends on:** M-E4 (algorithms), M-E5 (infrastructure)

### M-E7: Paradigm Engines [ ]

> 12 modules: reaxis, softanzuter, truth, quantifier, polyglot,
> polycode, adverb, timeline, gridnav, sectmerge, deepops,
> namedvars.

**Why:** The innovations. Reaxis replaces reactive programming.
Softanzuter is the agent substrate. Truth is domain-configurable.
Each one is a concept rethought from first principles.

**Depends on:** M-E6 (signature features)

### M-E8: Universal Computation [ ]

> 14 modules: provenance, confidence, explain, similarity,
> context, resource, validator, schema, intent, embedding,
> sequence, topology, relations, statemachine.

**Why:** General-purpose concerns every programmer needs. These
make AI natural without AI-specific modules.

**Depends on:** M-E5 (infrastructure), M-E7 (paradigm engines)

### M-E9: Value Proposition Modules [ ]

> `stz_interact` (Interaction Engine), `stz_skill` (Skill Engine).

**Why:** Testability is enforced by the build system from M-E1
onward. Interaction and Skill modules complete the Engine's
three promises.

**Depends on:** M-E8 (universal computation)

### M-E10: CLI Polish + Ring Bridge Completion [ ]

> `softanza build` (per-module), `softanza test` (narrated test
> runner), `softanza doctor` (full diagnostic), `softanza skills`
> (assessment). Ring FFI bridges for all 88 modules.

**Depends on:** M-E9

### M-E11: Repository Split [ ]

> Extract `softanza-engine` as standalone repo. stzlib becomes
> one client. Ship C headers, CLI, and language-neutral docs.

**Deferred** until API surface is stable and battle-tested.

---

## STZLIB REDESIGN TRACKS

Three parallel tracks that harden the Ring-side library while
Engine milestones progress. These can start immediately -- they
do not depend on Engine completion.

### M-S1: Class Modularization [ ]

> Break monolithic classes into granular, purpose-focused
> subclasses. Each subclass handles one concern and can be
> loaded independently.

**Why:** stzString is 100K+ LOC in a single file. A programmer
who needs string splitting loads the entire finder, replacer,
bounder, formatter, and visual engine. Modularization gives
smaller files, faster loading, and clearer API boundaries.
It also makes designing solutions more agile -- a programmer
picks exactly the subclass that fits the need, without overcode.

**Target classes and proposed decomposition:**

```
stzString (100K+ LOC) -->
  stzString           # core: creation, content, size, comparison
  stzStringFinder     # FindFirst, FindLast, FindAll, FindNth, ...
  stzStringSplitter   # Split, SplitAt, SplitBefore, SplitAfter, ...
  stzStringReplacer   # Replace, ReplaceAll, ReplaceSection, ...
  stzStringBounder    # Section, Range, Between, BoundedBy, ...
  stzStringFormatter  # Align, Pad, Trim, Simplify, Case, ...
  stzStringVisualizer     # Show, Boxed, VizFind, Highlight, ...
  stzStringWalker     # Walk, WalkW, Each, EachW, ...
  stzStringChecker    # Contains, StartsWith, EndsWith, IsXxx, ...

stzList (large) -->
  stzList             # core: creation, content, size, access
  stzListFinder       # Find, FindAll, FindW, ...
  stzListSorter       # Sort, SortBy, SortXT, Reverse, ...
  stzListSplitter     # Split, Partition, Classify, ...
  stzListReplacer     # Replace, ReplaceAll, ReplaceAt, ...
  stzListWalker       # Walk, WalkW, Each, ...
  stzListChecker      # Contains, AllAre, AnyIs, ...
  stzListMath         # Sum, Mean, Min, Max, Stats, ...

(Other classes audited case-by-case: stzNumber, stzTable,
stzGrid, stzGraph -- split only when the file exceeds
manageable size or mixes unrelated concerns.)
```

**Design rules:**
- The root class (stzString) loads all subclasses by default
  for backward compatibility -- existing code keeps working.
- Each subclass can be loaded independently for minimal footprint.
- Subclasses share state through the root object -- no data
  duplication, no cross-subclass dependencies.
- Engine C ABI stays flat (str_find_*, str_split_*).
  The modularization is a Ring-side concern only.
- The 23 function forms (Active/Passive/Fluent/etc.) apply
  uniformly across all subclasses.

**Deliverables:**
- Audit all classes for size and concern mixing
- Decomposition map (which methods go to which subclass)
- Migrated code with backward-compatible root loaders
- Updated Ring FFI bridges per subclass

### M-S2: Ring-Side Test Hardening [ ]

> Audit all existing stzlib tests, fix broken ones, and write
> new tests to cover all aspects and scenarios of the library.

**Why:** Engine-side testing is designed with 4-layer strength.
But the Ring surface -- where programmers actually work -- needs
its own comprehensive test coverage. Ring tests verify that FFI
bridges work, that function forms behave correctly, that the
23 execution modes compose, and that edge cases (empty strings,
mixed-type lists, Unicode boundaries) are handled.

**Scope:**

1. **Audit existing tests.**
   - Inventory all test files across Core/Base/Max layers
   - Run each one, classify: PASS / FAIL / STALE / INCOMPLETE
   - Fix all FAIL and STALE tests
   - Remove tests that test removed Qt code paths

2. **Coverage analysis per class.**
   - For each class, list public methods
   - Map which methods have tests and which do not
   - Priority: high-frequency methods first (Find, Replace,
     Contains, Split, Sort, Walk, Show)

3. **New test categories.**
   - **Function form tests:** For each of the 23 forms, verify
     that the form works on at least string and list (Active vs
     Passive, Q() chaining, QC() clone, QH() history, etc.)
   - **Edge case tests:** Empty input, single element, Unicode
     boundaries, very large inputs, mixed types in lists
   - **Cross-class tests:** Operations that span multiple classes
     (e.g., Split a string then Sort the resulting list)
   - **Narrated tests:** GIVEN/WHEN/THEN scenarios for the most
     important workflows, serving as executable documentation

4. **Test runner integration.**
   - `softanza test` discovers and runs all Ring tests
   - Reports per-class coverage summary
   - Fails on regression (any previously-passing test that breaks)

**Deliverables:**
- Test inventory with PASS/FAIL/STALE classification
- Coverage map (class x method x tested?)
- New tests for uncovered methods and all 23 function forms
- Narrated test suite for top 20 programmer workflows

### M-S3: Documentation Reimagining [ ]

> Redesign documentation for both stzlib and the Engine with
> clear organization, realistic document types, and complete
> reference material.

**Why:** The current 60+ paradigm narrations are brilliant as
design exploration but do not serve as reference material. A
programmer looking for "how do I split a string?" should not
read a 20-page philosophical narration. Documentation needs
distinct types serving distinct audiences.

**Document types (both stzlib and Engine):**

1. **API Reference** (per class / per module)
   - Every public method with signature, parameters, return type
   - One-line description + one minimal example
   - Grouped by concern (finding, replacing, splitting, etc.)
   - Generated from code where possible, hand-written where needed

2. **How-To Guides** (task-oriented)
   - "How to find and replace in strings"
   - "How to walk a list with variable steps"
   - "How to build a reactive pipeline"
   - Short, goal-focused, copy-paste-ready code
   - 20-30 guides covering the most common tasks

3. **Tutorials** (learning-oriented)
   - Progressive, building on prior knowledge
   - "Your first Softanza program"
   - "From loops to walkers"
   - "Building a data pipeline with Reaxis"
   - 5-10 tutorials for the beginner-to-intermediate path

4. **Paradigm Narrations** (understanding-oriented)
   - The existing 60+ documents, curated and organized
   - These explain WHY, not HOW -- the philosophy behind each
     innovation
   - Indexed by concept, cross-referenced to API Reference

5. **Architecture Documents** (contributor-oriented)
   - Engine Architecture, Engine Design, Zing Bridge Design
   - Layer contracts, module inventories, C ABI specs
   - For contributors and language-bridge authors

6. **Quick Reference Cards** (cheat sheets)
   - One-page per class: most-used methods with signatures
   - 23 function forms quick reference
   - Walker patterns, PatternEx syntax, Reaxis flow

**Organization:**

```
doc/
  reference/          # API Reference (per class)
    stzString.md
    stzList.md
    stzWalker.md
    ...
  howto/              # How-To Guides (task-oriented)
    find-and-replace.md
    walk-with-steps.md
    reactive-pipeline.md
    ...
  tutorials/          # Tutorials (progressive learning)
    01-first-program.md
    02-strings-and-lists.md
    03-loops-to-walkers.md
    ...
  narrations/         # Paradigm Narrations (philosophy)
    truth-rethought.md
    regex-beyond-strings.md
    reactive-reaxis.md
    ...
  architecture/       # Architecture (contributors)
    ENGINE_DESIGN.md
    ENGINE_ARCHITECTURE.md
    ZING_BRIDGE.md
    ...
  quickref/           # Quick Reference Cards
    stzString-card.md
    function-forms.md
    walker-patterns.md
    ...
```

**Deliverables:**
- Documentation type taxonomy (the 6 types above)
- Directory restructure
- API Reference for the top 10 classes (generated + hand-edited)
- 10 How-To Guides for the most common tasks
- 3 Tutorials for the beginner path
- Curated index of existing paradigm narrations
- Quick reference cards for String, List, Walker, function forms

---

## Dependency Graph

Two parallel tracks: Engine (M-E) and stzlib Redesign (M-S).
The S-track can start immediately and feeds into the E-track
as modularized classes map cleanly to Engine submodules.

```
ENGINE TRACK (Zig)              STZLIB TRACK (Ring)
================                ==================

M-E1 (StzValue + Number)       M-S1 (Class Modularization)
  |                               |
  v                               v
M-E2 (List + HashMap + Set)     M-S2 (Ring-Side Test Hardening)
  |                               |
  v                               v
M-E3 (Table + Graph + Matrix)   M-S3 (Documentation Reimagining)
  |          \
  v           v
M-E4         M-E5                 M-S1 informs M-E* decomposition
(Algorithms) (Infrastructure)     M-S2 validates Engine bridges
  |           |                   M-S3 documents both sides
  +-----+-----+
        |
        v
M-E6 (Signature Features)
        |
        v
M-E7 (Paradigm Engines)
        |
        v
M-E8 (Universal Computation)
        |
        v
M-E9 (VP Modules)
        |
        v
M-E10 (CLI + Bridges)
        |
        v
M-E11 (Repo Split)
```

---

## Progress Log

| Date       | Session | Milestone | What changed                     |
|------------|---------|-----------|----------------------------------|
| 2026-05-13 | 1       | Phase 1-2 | Audit + bootstrap 11 modules     |
| 2026-05-13 | 2       | Phase 3   | Qt purge + Tier 2-3 modules      |
| 2026-05-14 | 3       | Phase 4   | Modular DLLs + layered tiers + CLI|
| 2026-05-15 | 4       | Phase 5   | 86 modules designed, 16 principles|
| 2026-05-15 | 4b      | Phase 5+  | 88 modules, 19 principles, 3 VPs |
| 2026-05-16 | 5       | Phase 5++ | 14 stzString methods Engine-backed, 630 Ring tests |
| 2026-05-17 | 6       | Phase 6   | String Engine v2 design doc + 8-phase plan |
| 2026-05-17 | 7       | Phase A   | 1-based indexing + CS merge (Phase A complete) |
| 2026-05-17 | 8       | Phase A-D | str_ rename, safety audit, perf, core.zig extraction |
| 2026-05-17 | 9       | Phase D+  | encode.zig (25 fns) + nlp.zig (18 fns) extraction |
| 2026-05-17 | 10      | Phase D++ | split.zig (26 fns) + find.zig (37 fns), 535 Zig tests |
| 2026-05-17 | 11      | Phase D+++| replace.zig (39) + transform.zig (19) + inspect.zig (38), 566 tests |
| 2026-05-17 | 12      | Phase D****| extract(23)+trim(22)+count(25)+compare(11)+format(47), Phase D DONE |
| 2026-05-18 | 12+     | Bridging   | +3 engine fns (contains_latin/arabic, has_mixed_case), 587 tests, 341 DLL fns |
| 2026-05-18 | 13      | Bridging++ | +6 engine fns (all_substrings, unique_substrings, unique_chars_ci, substrings_count, substrings_of_n_chars, is_word enhanced). 8 Ring methods bridged: SubStringsCS, UniqueCharsCS, CharsCS CI, UniqueSubStringsCS, SubStringsOfNCharsCS, IsWord, NumberOfSubStringsCS. 592 tests, 352 DLL fns |
| 2026-05-18 | 14      | M-S1       | Modularised stzString: 32 domain classes converted to composition pattern, stzString.ring minimal core, monolith archived. Fixed Ring object-copy use-after-free. Added core primitives (NLeftChars, NRightChars, RemoveSection/s, ReplaceSections, Trim). 14/22 TODOs resolved |
| 2026-05-18 | 15      | M-S1+      | Fixed INDEX_BASE=1 off-by-one in Ring wrappers (FindCS, FindLastCS, _FindSubStr all had double +1). Added 6 Finder methods (FindAsSectionsCS, FindBetweenAsSectionCS, FindBoundedByAsSectionsCS, SubStringsCS, FindCharsWCS/FindW, FindDuplicatesAsSectionsCS). All 8 remaining TODOs in domain files resolved (0 remaining). 5 test suites pass |
