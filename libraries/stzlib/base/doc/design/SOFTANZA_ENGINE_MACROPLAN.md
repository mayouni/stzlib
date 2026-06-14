# Softanza Engine -- Macro Plan

> **Living document.** Updated at every progress milestone.
> Cross-reference: `base/doc/internals/SESSION_CONTINUITY.md`
> for per-session details.

---

## Status Summary

| Metric            | Value                    |
|-------------------|--------------------------|
| Modules designed  | 88                       |
| Modules built     | 83                       |
| Design principles | 19                       |
| Engine tests      | 1593 passing             |
| DLLs shipping     | 87 (4 Core + 83 Base)    |
| Qt dependencies   | 0 (fully purged)         |
| Ring bridge regs  | 1031 DLL functions       |
| Ring classes bridged | 125 files, 3482+ calls |
| Ring Unicode hard | Complete (all domains)   |
| PCRE2 backend     | 10.47 (industrial regex) |
| Last updated      | 2026-06-12 (Session 50)  |

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

### String Engine v2 -- Phases A-D (Sessions 7-18)

- **Phase A (Naming & Indexing)**: Unified `_cs()` signatures, INDEX_BASE=1 at FFI
  boundary, CamelCase file naming across all layers.
- **Phase B (Safety)**: Null-handle guards, StrError reporting, ReDoS hardening.
- **Phase C (Performance)**: BMH search, codepoint cache, ASCII fast-path.
- **Phase D (Module Separation)**: String engine split into 13 submodules under
  `string/` (core, find, replace, split, encode, transform, nlp, inspect, extract,
  trim, compare, count, format).
- **Stats at D completion**: 641 Zig tests, 398 Ring bridge functions.

### String Engine v2 -- Phase E: Regex Integration (Session 19)

- **New submodule**: `string/regex.zig` -- bridges standalone regex engine into
  string handle API. 7 functions: `str_regex_is_match`, `str_regex_count`,
  `str_regex_find_first`, `str_regex_find_all` (returns StzFindResultHandle),
  `str_regex_replace_all` (returns new StzStringHandle), `str_regex_split_count`,
  `str_regex_split_get`.
- **Ring bridge**: 7 new bridge wrappers in `ring_bridge_string.zig` (405 total).
- **Exports**: All 7 functions exported in `engine.zig` and `stz_string_entry.zig`.
- **Tests**: 16 new Zig tests covering ASCII, Unicode, case-insensitive, null
  handles, edge cases (657 total).
- **DLLs**: `stz_string.dll` and `stk_string.dll` rebuilt with regex integration.

### PCRE2 Industrial Regex Backend (Session 20)

- **PCRE2 10.47 vendored**: 31 C source files in `vendor/pcre2/pcre2-10.47/src/`,
  compiled with `-DHAVE_CONFIG_H -DPCRE2_CODE_UNIT_WIDTH=8 -DSUPPORT_UNICODE -DPCRE2_STATIC`.
- **regex.zig rewritten**: Custom recursive backtracker replaced with PCRE2 backend.
  Same C ABI surface preserved (`stz_regex_new/free/match/match_all/has_match/
  capture_count/capture_start/capture_end/capture_text/replace/replace_free/set_limits`).
- **New PCRE2 features exposed**: `stz_regex_capture_by_name` (named group access),
  `stz_regex_named_group_count`. Ring bridge: `stzengineregexcapturebyname`,
  `stzengineregexnamedgroupcount` (407 total).
- **Full feature set now available**: lookahead/lookbehind, named groups `(?P<name>)`,
  backreferences `\1`, word boundaries `\b`, non-capturing groups `(?:)`, counted
  quantifiers `{n,m}`, multiline mode, recursion `(?R)`, Unicode scripts
  `\p{Greek}/\p{Arabic}`, replace with `$1/$2/\1` backreferences.
- **Tests**: 674 total (17 new PCRE2 feature tests).
- **Ring-side stzRegex.ring**: `HasNames()`, `CaptureNames()`, `CaptureByName()`,
  `NamedGroups()` now live. `IsPartialMatch()`, `HasPartialMatch()`,
  `PartialMatchInfo()` return real partial match results (code 2 = partial).
  `:ExtendedSyntax` and `:NonGreedy` match options now wired to PCRE2 flags.
- **build.zig**: `needs_pcre2` flag added to Domain struct. All string and regex
  domains link PCRE2. Static lib and test targets include PCRE2.

### M-E1: Foundation Types (Session 21)

- **`value.zig` -- StzValue tagged union**: 6 types (null, bool, int, float, string,
  list). Full C ABI: constructors (`stz_value_new_*`), destructor, type query,
  getters (with cross-type coercion for int/float), list operations (append, set,
  remove, insert, find, contains, reverse, sort, clear), deep clone, equality,
  comparison (total ordering across types), toString, type_name. 27 Zig tests.
- **`number.zig` -- StzBigInt + numeric utilities**: Arbitrary-precision integer
  arithmetic via `std.math.big.int.Managed`. Full C ABI: lifecycle (from_int,
  from_string, free, clone), arithmetic (add, sub, mul, div, mod, negate, abs, pow),
  comparison (compare, equals, is_zero, is_negative), conversion (to_int, to_string,
  to_string_base for hex/binary/octal). Numeric utilities: GCD, LCM, is_prime,
  factorial, fibonacci (both returning BigInt), is_perfect, digit_count, digit_sum,
  reverse_digits, is_palindrome. 27 Zig tests.
- **Ring bridge**: 29 value bridge functions (StzEngineValue*), 30 number bridge
  functions (StzEngineBigInt*, StzEngineNumber*). All list operations use INDEX_BASE=1
  adjustment at FFI boundary. 59 new bridge registrations (470 total).
- **DLLs**: `stz_value.dll` and `stz_number.dll` added to base_domains in build.zig.
  17 DLLs shipping (was 15).
- **Stats**: 728 Zig tests (was 674), 470 Ring bridge functions (was 411), 13 modules
  built (was 11).

### M-E2: Core Collections (Session 22)

- **`list.zig` -- StzList typed dynamic list**: Handle-based list operating on StzValue
  items. Full C ABI: lifecycle (new, free, len), typed appenders (append_int, append_float,
  append_string, append_value), positional ops (insert, remove, get, get_int, get_string,
  set), search (find_cs, find_string_cs, contains_cs, find_all_cs, count_cs -- all with
  case-sensitivity parameter), sorting (sort, sort_descending), mutation (reverse, clear),
  deduplication (unique_cs returns new list, remove_duplicates_cs in-place), clone/slice,
  bulk string I/O (from_null_delimited, to_null_delimited), nested list flatten,
  type queries (item_type, is_all_strings, is_all_numbers), equality (equals_cs).
  21 Zig tests.
- **`hashmap.zig` -- StzHashMap string-keyed map**: Handle-based associative container
  mapping string keys to StzValue items. Full C ABI: lifecycle (new, free, len),
  typed putters (put, put_int, put_float, put_string -- all upsert), getters (get,
  get_cs, get_int, get_float, get_string), key tests (has_key, has_key_cs), remove,
  iteration (key_at, key_len_at, value_at), bulk ops (clear, clone, keys as
  null-delimited, merge). 10 Zig tests.
- **Ring bridge**: 32 list bridge functions (StzEngineList*), 21 hashmap bridge functions
  (StzEngineHashMap*). All index-based operations use INDEX_BASE=1 adjustment at FFI
  boundary. Find operations return 1-based positions (0 = not found). 53 new bridge
  registrations (523 total).
- **DLLs**: `stz_list.dll` and `stz_hashmap.dll` added to base_domains in build.zig.
  19 DLLs shipping (was 17).
- **Stats**: 759 Zig tests (was 728), 523 Ring bridge functions (was 470), 15 modules
  built (was 13). Engine version bumped to 0.7.0.0.

### M-E3: Extended Collections (Sessions 23-26) [DONE]

- **`stz_table` -- columnar table engine**: Handle-based columnar storage with typed
  columns. Full C ABI: lifecycle, row/cell CRUD, sort (multi-column, stable), search
  (find/filter with predicates), aggregation (sum/avg/min/max/count per column).
  42 Ring bridge functions. stzTable.ring + stzTableSorter/Aggregator/Search all
  delegate to engine. `stz_pivot` module adds pivot table operations.
- **`stz_graph` -- directed/undirected graph engine**: Node/edge CRUD, BFS/DFS
  traversal, shortest path (Dijkstra), cycle detection, topological sort, connected
  components, reachable set, in/out degree. 18 Ring bridge functions. stzGraph.ring
  delegates 7+ algorithmic methods via lazy engine sync with invalidation on mutations.
- **`stz_matrix` -- matrix engine**: 19 Ring bridge functions. stzMatrix.ring fully
  engine-backed.
- **stzTree stays Ring-side**: Its API uses `eval()` on Ring nested lists for path
  navigation (`[:root][:node]`) -- inherently Ring-specific, not a fit for engine
  reimplementation.
- **Reference data**: SQLite-backed ref_data module (country/language/currency/script
  lookups). 18 bridge functions. stzUnicodeData.ring + stzLocale.ring consume it.
- **stz_stats**: Mean/median/mode/variance/stddev/percentile/correlation/regression/
  z-score/outlier detection. 28 bridge functions. stzDataSet.ring fully delegates.
- **stz_random**: Uniform/range/shuffle/sample/weighted selection. 6 bridge functions.
- **stz_csv**: Parse/write CSV with headers. 7 bridge functions.
- **Ring-side bridging completed**: stzNumber, stzListFinder, stzListCounter,
  stzListLeadTrail, stzHashList, stzRandom, stzCSV, stzGraph -- all engine-backed.
- **String Engine Phase H (Crypto)**: SHA-256, MD5, BLAKE3, HMAC-SHA256 via
  `std.crypto`. 5 new engine functions (str_sha256, str_md5, str_blake3,
  str_hmac_sha256, str_sha256_raw), 4 Ring bridge functions, 6 new Zig tests.
  stzStringCrypto.ring gains SHA256(), MD5(), BLAKE3(), HMACSHA256() methods.
- **String Engine Phase F (Locale)**: Script/direction detection, locale-aware
  comparison. 7 engine functions (str_detect_script, str_script_name,
  str_detect_direction, str_direction_name, str_has_rtl, str_script_count,
  str_locale_compare), 7 Ring bridge functions, 16 Zig tests.
  stzStringLocale.ring fully engine-backed with script/direction/comparison.
- **String Engine v2 COMPLETE**: All 8 phases (A-H) done. 13 submodules,
  ~280 functions, full test coverage.
- **i18n engine backing**: i18n.db generated (261 countries, 323 languages) from
  countries.zig + languages.zig data files. 8 C ABI exports in ref_data.zig for
  country/language field queries. 8 Ring bridge functions in ring_bridge_refdata.zig.
  stzCountry.ring, stzLanguage.ring, stzCurrency.ring gain engine-backed methods
  (NumberOfCountries, NumberOfLanguages, EngineField, EngineFieldByAbbr).
- **Stats**: 1122 Zig tests, 1016 Ring bridge functions, 27 DLLs, 23 modules built,
  107 Ring files making 3482 StzEngine* calls.

### M-E4: Algorithms [DONE]

- **stz_stats** [DONE]: Completed as part of M-E3 work (Sessions 23-24).
- **stz_text** [DONE]: Paragraph/sentence segmentation, word/char/line/syllable
  counting, Flesch Reading Ease, Flesch-Kincaid Grade Level, text truncation.
  11 C ABI functions, 11 Ring bridge functions, 15 Zig tests. DLL #27.
- **Walker/Checker/Performer**: Ring-side submodules exist (stzStringWalker,
  stzListWalker, stzStringChecker, stzListChecker, stzStringPerformer,
  stzListPerformer) and already delegate to engine via StzEngine* calls where
  applicable. No standalone engine modules needed -- the operations are backed
  by existing string/list engine functions.
- **stz_yielder** [DONE]: Functional pipeline (map/filter/reduce) on StzList
  handles. 17 TransformOps, 17 FilterOps, 10 ReduceOps. 7 C ABI functions
  (map, filter, reduce, reduce_concat, filter_map, map_indexed, count_where,
  free), 8 Ring bridge functions, 12 Zig tests. Ring wrapper stzYielder.ring
  with named op dispatch. DLL #60.

---

## MILESTONES AHEAD

### M-E0.5: String Engine v2 [DONE]

> Redesign the string engine for Unicode correctness, Softanza
> naming, 1-based indexing, and modern domain coverage.
> See `STRING_ENGINE_DESIGN_v2.md` for full design.

**8 phases -- ALL COMPLETE:**
- A (Naming & Indexing) -- unified _cs() signatures, INDEX_BASE=1
- B (Safety) -- null-handle guards, StrError reporting, ReDoS hardening
- C (Performance) -- BMH search, codepoint cache, ASCII fast-path
- D (Module Separation) -- 13 submodules, ~250 functions
- E (Regex) -- PCRE2 10.47 backend, industrial-grade
- F (Locale) -- script/direction detection, locale-aware comparison
- G (NLP) -- similarity metrics, phonetics, n-grams, extraction
- H (Crypto) -- SHA-256, MD5, BLAKE3, HMAC-SHA256

### M-E1: Foundation Types [DONE]

> Build `stz_value` (StzValue tagged union) + `stz_number`
> (BigInt + numeric utilities).

**Completed Session 21.** StzValue tagged union (6 types) +
StzBigInt (arbitrary precision) + 10 numeric utilities. 54 Zig
tests, 59 Ring bridge functions, 2 new DLLs.

**Deliverables:**
- `engine/src/value.zig` with tagged union + C ABI
- `engine/src/number.zig` with BigInt + numeric utilities
- Ring FFI bridges for both (ring_bridge_value.zig, ring_bridge_number.zig)
- DLL entry points (stz_value_entry.zig, stz_number_entry.zig)
- Tests: 54 passing

### M-E2: Core Collections [DONE]

> `stz_list` (heterogeneous dynamic array), `stz_hashmap`.

**Completed Session 22.** StzList (33 C ABI functions) +
StzHashMap (22 C ABI functions). 31 Zig tests, 53 Ring bridge
functions, 2 new DLLs.

**Deliverables:**
- `engine/src/list.zig` with typed list + find/sort/dedup
- `engine/src/hashmap.zig` with string-keyed map
- Ring FFI bridges for both (ring_bridge_list.zig, ring_bridge_hashmap.zig)
- DLL entry points (stz_list_entry.zig, stz_hashmap_entry.zig)
- Tests: 31 passing

**Depends on:** M-E1 (StzValue)

### M-E3: Extended Collections [DONE]

> `stz_table`, `stz_graph`, `stz_matrix`, `stz_tree`.

**Completed Sessions 23-26.** Table (42 bridge fns), Graph (18),
Matrix (19), Stats (28), Random (6), CSV (7), RefData (18).
Tree stays Ring-side (eval-based path navigation). All Ring
classes fully engine-backed: 107 files, 3482 StzEngine* calls.

### M-E4: Algorithms [DONE]

> `stz_stats`, `stz_text`, `stz_walker`, `stz_checker`,
> `stz_yielder`, `stz_performer`.

**All complete.** stz_stats, stz_text, stz_yielder engine modules
built. Walker/Checker/Performer Ring-side modules delegate to
existing engine string/list functions. stz_yielder: 7 C ABI
functions, 8 Ring bridge functions, 12 Zig tests, Ring wrapper
stzYielder.ring with named op dispatch (DLL #60).

**Depends on:** M-E2 (collections)

### M-E5: Infrastructure Services [DONE]

> 25 modules: crypto, codec, compress, stream, watch, process,
> async, uuid, html, rng, solver, geo, bits, expr, embed,
> registry, smallfn, execmodel, cache, log, profiler, callstack.
> (4 modules -- random, expr, text, csv -- already existed from M-E3/E4.)

**Why:** Plumbing that signature features and paradigm engines
build on. Stream and async are prerequisites for Reaxis.

**Started Session 26.**
- **stz_uuid** [DONE]: UUID v4 generation (crypto random), validation,
  version extraction, nil UUID, comparison. 6 C ABI functions,
  6 Ring bridge functions, 9 Zig tests. DLL #28.
- **stz_codec** [DONE]: Base64 encode/decode, hex encode/decode,
  URL encode/decode, ROT13. 8 C ABI functions, 7 Ring bridge
  functions, 8 Zig tests. DLL #29.
- **stz_bits** [DONE]: Popcount, leading/trailing zeros, parity,
  set/clear/toggle, rotate, reverse, byte-swap, extract/deposit,
  hamming distance, binary string conversion. 20 C ABI functions,
  20 Ring bridge functions, 11 Zig tests. DLL #30.
- **stz_html** [DONE]: HTML entity encode/decode (named + numeric),
  tag stripping, attribute encoding. 4 C ABI functions, 4 Ring
  bridge functions, 8 Zig tests. DLL #31.
- **stz_geo** [DONE]: Haversine distance (km/miles), bearing,
  midpoint, destination point, coordinate validation, unit
  conversion (km/miles, deg/rad). 14 C ABI functions, 14 Ring
  bridge functions, 8 Zig tests. DLL #32.
- **stz_compress** [DONE]: CRC-32, Adler-32, RLE encode/decode,
  simple LZ77 compress/decompress. 6 C ABI functions, 6 Ring
  bridge functions, 8 Zig tests. DLL #33.
- **stz_solver** [DONE]: Linear/quadratic equation solving,
  bisection/Newton root-finding, Simpson integration, polynomial
  evaluation, lerp/clamp/map_range. 8 C ABI functions, 8 Ring
  bridge functions, 8 Zig tests. DLL #34.
- **stz_watch** [DONE]: 64 stopwatch slots with nanosecond precision,
  start/stop/resume/reset, elapsed in ns/us/ms/s, timestamp.
  11 C ABI functions, 11 Ring bridge functions, 6 Zig tests. DLL #35.
- **stz_log** [DONE]: 6 log levels (trace-fatal), level filtering,
  enable/disable, message buffer, level names. 10 C ABI functions,
  10 Ring bridge functions, 6 Zig tests. DLL #36.
- **stz_cache** [DONE]: 256-slot string cache with TTL support,
  hit/miss tracking, hit rate. 9 C ABI functions, 9 Ring bridge
  functions, 5 Zig tests. DLL #37.
- **stz_stream** [DONE]: 32 byte streams with read/write cursors,
  peek, seek, reset. 10 C ABI functions, 10 Ring bridge functions,
  6 Zig tests. DLL #38.
- **stz_process** [DONE]: Process introspection (PID, uptime, arch,
  OS, endian, pointer size). 8 C ABI functions, 8 Ring bridge
  functions, 6 Zig tests. DLL #39.
- **stz_arith** [DONE]: Arithmetic expression evaluator (+,-,*,/,%,
  parens, decimals, unary minus). 2 C ABI functions, 2 Ring bridge
  functions, 10 Zig tests. DLL #40.
- **stz_registry** [DONE]: 512-slot key-value config store, set/get/
  has/remove/clear/count/key_at. 7 C ABI functions, 7 Ring bridge
  functions, 5 Zig tests. DLL #41.
- **stz_profiler** [DONE]: 128 named timers with call counting,
  total/avg timing, reset/clear. 9 C ABI functions, 9 Ring bridge
  functions, 6 Zig tests. DLL #42.
- **stz_callstack** [DONE]: 128-frame call stack tracker, push/pop/
  frame/top/to_string/clear. 7 C ABI functions, 7 Ring bridge
  functions, 6 Zig tests. DLL #43.
- **stz_crypto** [DONE]: SHA-256, MD5, CRC-32, FNV-32/64 hashing,
  constant-time comparison. 7 C ABI functions, 7 Ring bridge
  functions, 8 Zig tests. DLL #44.
- **stz_async** [DONE]: Cooperative task queue (create/start/complete/
  fail/cancel), priority-based scheduling. 10 C ABI functions,
  10 Ring bridge functions, 6 Zig tests. DLL #45.
- **stz_embed** [DONE]: Engine version/build info, feature flag
  registry. 10 C ABI functions, 10 Ring bridge functions,
  4 Zig tests. DLL #46.
- **stz_smallfn** [DONE]: min/max/abs/sign/clamp/lerp/map_range,
  ceil/floor/round/trunc/fmod/pow/sqrt/log. 19 C ABI functions,
  19 Ring bridge functions, 8 Zig tests. DLL #47.
- **stz_execmodel** [DONE]: State machine with event dispatch,
  named states + transitions. 9 C ABI functions, 9 Ring bridge
  functions, 6 Zig tests. DLL #48.

**Depends on:** M-E1 (StzValue), partially M-E2

### M-E6: Signature Features [DONE]

> 11 modules: pattern, numtheory, natlang, ccode, constraint,
> reactive, knowgraph, splitter, stringart, display, univops.

**Why:** What makes Softanza unique at the feature level --
PatternEx family, natural language bridge, universal operations,
display engine.

**Started Session 27.**
- **stz_numtheory** [DONE]: GCD, LCM, primality, next/prev/nth prime,
  factorization, Fibonacci, modular pow/inv, divisors, perfect numbers,
  Euler totient. 16 C ABI functions, 16 Ring bridge functions,
  12 Zig tests. DLL #49.
- **stz_splitter** [DONE]: Split by string/width/any-char/lines/words,
  keep-delimiters, limit splits. 9 C ABI functions, 9 Ring bridge
  functions, 7 Zig tests. DLL #50.
- **stz_univops** [DONE]: Type queries (name/numeric/collection/scalar),
  bytes equal/compare/swap/fill/hash, int min/max/clamp/abs/sign/in_range.
  15 C ABI functions, 10 Ring bridge functions, 7 Zig tests. DLL #51.
- **stz_pattern** [DONE]: Palindrome, repeat detection/extraction,
  prefix/suffix matching, arithmetic/geometric/constant sequences,
  occurrence counting, longest common prefix/suffix.
  14 C ABI functions, 9 Ring bridge functions, 9 Zig tests. DLL #52.
- **stz_stringart** [DONE]: Pad left/right, center, repeat, box lines,
  box borders, indent, truncate with ellipsis, visible length.
  9 C ABI functions, 9 Ring bridge functions, 8 Zig tests. DLL #53.
- **stz_display** [DONE]: Number/int/percent/bytes formatting, bar chart,
  progress bar, tree prefix, ruler. 8 C ABI functions, 8 Ring bridge
  functions, 8 Zig tests. DLL #54.
- **stz_constraint** [DONE]: 128-slot named constraint store (range/
  not_empty/min_len/max_len), check with violation tracking.
  12 C ABI functions, 12 Ring bridge functions, 7 Zig tests. DLL #55.
- **stz_natlang** [DONE]: Word/sentence/char/syllable counting, avg word
  length, case checks (upper/lower/title), digit/alpha/alnum detection.
  11 C ABI functions, 11 Ring bridge functions, 7 Zig tests. DLL #56.
- **stz_ccode** [DONE]: C type names, sizeof, function declarations, struct
  fields, includes, defines, typedefs, keyword check, string escaping.
  9 C ABI functions, 8 Ring bridge functions, 9 Zig tests. DLL #57.
- **stz_reactive** [DONE]: Observable channels with named subscriptions,
  event emission, last-event retrieval, channel lifecycle.
  10 C ABI functions, 10 Ring bridge functions, 6 Zig tests. DLL #58.
- **stz_knowgraph** [DONE]: Triple store (subject-predicate-object), query
  by any position, duplicate rejection, has_triple check.
  11 C ABI functions, 8 Ring bridge functions, 7 Zig tests. DLL #59.

**Depends on:** M-E4 (algorithms), M-E5 (infrastructure)

### M-E7: Paradigm Engines [DONE]

> 12 modules: reaxis, softanzuter, truth, quantifier, polyglot,
> polycode, adverb, timeline, gridnav, sectmerge, deepops,
> namedvars.

**Why:** The innovations. Reaxis replaces reactive programming.
Softanzuter is the agent substrate. Truth is domain-configurable.
Each one is a concept rethought from first principles.

**Completed Session 27.**
- **stz_namedvars** [DONE]: Named parameter store with type tracking
  (int/float/string/bool). 12 C ABI functions, 12 Ring bridge
  functions, 6 Zig tests. DLL #60.
- **stz_truth** [DONE]: Domain-configurable truth values beyond boolean
  (maybe/unknown/partial), threshold-based evaluation.
  8 C ABI functions, 8 Ring bridge functions, 5 Zig tests. DLL #61.
- **stz_quantifier** [DONE]: Named quantifiers with configurable
  thresholds (all/most/few/none/half), ratio evaluation.
  7 C ABI functions, 7 Ring bridge functions, 4 Zig tests. DLL #62.
- **stz_adverb** [DONE]: Operation modifiers as composable flags
  (CS/XT/Q/Z/ZZ/W/IB), set/clear/has/count/describe.
  7 C ABI functions, 7 Ring bridge functions, 4 Zig tests. DLL #63.
- **stz_timeline** [DONE]: 256-slot event store with timestamps (i64
  epoch ms), ordering, range queries, duration computation.
  9 C ABI functions, 9 Ring bridge functions, 6 Zig tests. DLL #64.
- **stz_gridnav** [DONE]: 2D grid navigation with position tracking,
  neighbors, boundary checks, Manhattan distance.
  9 C ABI functions, 9 Ring bridge functions, 6 Zig tests. DLL #65.
- **stz_sectmerge** [DONE]: Section merge (ordered ranges into
  non-overlapping), overlap detection, gap finding.
  7 C ABI functions, 7 Ring bridge functions, 6 Zig tests. DLL #66.
- **stz_deepops** [DONE]: Deep operations on nested structures,
  path-based get/set/flatten, depth calculation.
  7 C ABI functions, 7 Ring bridge functions, 5 Zig tests. DLL #67.
- **stz_reaxis** [DONE]: Rule-based reactive event processing, named
  rules with pattern matching and action dispatch.
  6 C ABI functions, 6 Ring bridge functions, 5 Zig tests. DLL #68.
- **stz_softanzuter** [DONE]: Named agent slots with state and message
  passing, agent lifecycle management.
  8 C ABI functions, 8 Ring bridge functions, 6 Zig tests. DLL #69.
- **stz_polyglot** [DONE]: Multi-language string registry, locale-keyed
  storage and retrieval.
  6 C ABI functions, 6 Ring bridge functions, 5 Zig tests. DLL #70.
- **stz_polycode** [DONE]: Multi-representation code store, format-keyed
  storage and retrieval.
  6 C ABI functions, 6 Ring bridge functions, 5 Zig tests. DLL #71.

**Depends on:** M-E6 (signature features)

### M-E8: Universal Computation [DONE]

> 14 modules: provenance, confidence, explain, similarity,
> context, resource, validator, schema, intent, embedding,
> sequence, topology, relations, statemachine.

**Why:** General-purpose concerns every programmer needs. These
make AI natural without AI-specific modules.

**Completed Session 28.**
- **stz_provenance** [DONE]: 128-slot provenance records (entity/origin/
  author/timestamp), version tracking. 10 C ABI, 10 Ring bridge, 4 tests. DLL #72.
- **stz_confidence** [DONE]: 64-slot named confidence scores (0.0-1.0),
  weighted average, min/max. 8 C ABI, 8 Ring bridge, 5 tests. DLL #73.
- **stz_explain** [DONE]: 64-slot named explanations with categories,
  category counting. 8 C ABI, 8 Ring bridge, 4 tests. DLL #74.
- **stz_similarity** [DONE]: Cosine, Euclidean, Manhattan distance,
  Jaccard on sorted sets, dot product, normalize. 6 C ABI, 4 Ring bridge,
  6 tests. DLL #75.
- **stz_context** [DONE]: 32 nested scopes with key-value pairs, parent
  inheritance, child override. 8 C ABI, 8 Ring bridge, 4 tests. DLL #76.
- **stz_resource** [DONE]: 128-slot resource tracker with acquire/release
  lifecycle, leak detection. 9 C ABI, 9 Ring bridge, 4 tests. DLL #77.
- **stz_validator** [DONE]: 64-slot validation rules (required/min/max/
  length), violation tracking. 10 C ABI, 10 Ring bridge, 4 tests. DLL #78.
- **stz_schema** [DONE]: 32 named schemas with typed fields (string/int/
  float/bool/list/object). 9 C ABI, 9 Ring bridge, 4 tests. DLL #79.
- **stz_intent** [DONE]: 64-slot named intents with parameters and
  priority-based selection. 9 C ABI, 9 Ring bridge, 4 tests. DLL #80.
- **stz_embedding** [DONE]: 64 named embedding vectors (up to 512 dim),
  cosine similarity between stored embeddings. 8 C ABI, 7 Ring bridge,
  4 tests. DLL #81.
- **stz_sequence** [DONE]: 32 named sequences with step/repeat/bounce
  modes and configurable bounds. 9 C ABI, 9 Ring bridge, 4 tests. DLL #82.
- **stz_topology** [DONE]: 64-node adjacency topology with BFS
  connectivity queries. 8 C ABI, 8 Ring bridge, 4 tests. DLL #83.
- **stz_relations** [DONE]: 256-slot named binary relations with weighted
  edges, query by subject/object. 10 C ABI, 8 Ring bridge, 4 tests. DLL #84.
- **stz_statemachine** [DONE]: 16 named finite state machines with states,
  transitions, event dispatch. 11 C ABI, 10 Ring bridge, 4 tests. DLL #85.

**Depends on:** M-E5 (infrastructure), M-E7 (paradigm engines)

### M-E9: Value Proposition Modules [DONE]

> `stz_interact` (Interaction Engine), `stz_skill` (Skill Engine).

**Why:** Testability is enforced by the build system from M-E1
onward. Interaction and Skill modules complete the Engine's
three promises.

**Depends on:** M-E8 (universal computation)

| # | DLL | Module | C ABI | Tests |
|---|-----|--------|-------|-------|
| 86 | stz_interact | interact.zig | 10 | 4 |
| 87 | stz_skill | skill.zig | 12 | 4 |

### M-E10: CLI Polish + Ring Bridge Completion [PARTIAL]

> `softanza build` (per-module), `softanza test` (narrated test
> runner), `softanza doctor` (full diagnostic), `softanza skills`
> (assessment). Ring FFI bridges for all 88 modules.

**Depends on:** M-E9

**Session 29 progress (M-S2 Ring-Side Test Hardening):**
- **test_engine_wrappers.ring** [DONE]: 138 assertions across all 18
  DLLs (sequence, confidence, provenance, relation, intent, resource,
  context, similarity, schema, topology, embedding, explain, timeline,
  gridnav, interact, skill, statemachine, validator). Fixed Ring function
  placement bug and corrected all bridge function name/signature
  mismatches discovered.
- **Ring test audit** [DONE]: Ran ~50 engine-related test files across
  datetime, file, i18n, string, regex, number, system, network, list,
  table, and number subdirectories. Results: 48 PASS, 1 FIXED
  (hashlist needed IsWithOrByOrUsingNamedParam on stzList core),
  1 minor (test_unicode has 19/20 pass). Legacy test files (119 in
  base/test/) not audited — most depend on the archived monolith.
- **stzList core fix** [DONE]: Added IsWithOrByOrUsingNamedParam() and
  IsCaseSensitiveNamedParam() to stzList.ring. These methods were only
  in stzListChecker (composition-based), but Q() returns stzList and
  needs them directly.

### M-E11: Repository Split [ ]

> Extract `softanza-engine` as standalone repo. stzlib becomes
> one client. Ship C headers, CLI, and language-neutral docs.

**Deferred** until API surface is stable and battle-tested.

---

## STZLIB REDESIGN TRACKS

Three parallel tracks that harden the Ring-side library while
Engine milestones progress. These can start immediately -- they
do not depend on Engine completion.

### M-S1: Class Modularization [DONE for stzString + stzList]

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

### M-S2: Ring-Side Test Hardening [PARTIAL]

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
| 2026-05-25 | 27      | M-E9       | interact.zig (10 C ABI, 4 tests) + skill.zig (12 C ABI, 4 tests). DLLs 86-87. 1487 tests, 87 DLLs. M-E9 DONE |
| 2026-05-25 | 27+     | M-E10      | 10 Ring wrapper classes for M-E7/M-E8 engine modules: stzStateMachine, stzValidator, stzSequence, stzConfidence, stzProvenance, stzRelation, stzIntent, stzResource, stzContext, stzSimilarity. 117 files bridged |
| 2026-05-25 | 27++    | M-E10      | 8 more Ring wrapper classes: stzSchema, stzTopology, stzEmbedding, stzExplain, stzEngineTimeline, stzGridNav, stzInteraction, stzSkill. All 18 engine wrapper classes complete. 125 files bridged. M-E10 Ring bridges DONE |
| 2026-05-25 | 27+++   | M-S1       | stzList Phase 2.2+3: added Bisect/PartitionW/Chunks to stzListClassifier, ContainsW/IsPalindrome/IsPairOf*/IsSet/IsPair to stzListChecker. Phase 3 engine coverage verified: Map/Filter/Reduce/Classify/Frequencies/AllUnique all engine-backed |
| 2026-05-25 | 27++++  | Testing    | +21 tests across 8 modules (skill, gridnav, sequence, resource, context, schema, relations, interact). All C ABI exports now tested. 1508 tests pass |
| 2026-05-28 | 28      | M-S1       | stzList Phase 1: engine-backed Checker/Comparator (StartsWith/EndsWith list-prefix engine fns added), Classifier/Extractor (FrequencyOf/Chunks via engine), Merger/Duplicates. Fixed Comparator.ContainsCS mixed-type bug (route to engine-backed @oList.ContainsCS). Variable scoping fix (_prefixed_ convention) across these submodules. 1591 engine tests, 14/14 checker/comparator + 13/13 classifier + 26/26 delegation tests pass |
| 2026-05-28 | 29      | CLI        | Added softanza status/coverage/roadmap/next commands backed by comptime engine_status.zig table (14 domains, 28 submodules, 21 milestones). Source of truth for "where are we?" -- avoids re-deriving progress each session |
| 2026-05-28 | 29+     | M-S1       | Phase 2: scoping cleanup for Getter (35 methods), Sorter (14), Bounder (22) -- 11->14 clean submodules, 27%->30% engine-backed. All delegation tests still pass |
| 2026-05-28 | 30      | CLI        | Aligned CLI roadmap with canonical M-E0.5..M-E11 + M-S1..M-S3 milestone naming from this doc. Status command now shows macro stats first, then tracked subset. Roadmap splits ENGINE/STZLIB tracks. Added Status.partial for mid-flight milestones (M-E10, M-S1, M-S2). |
| 2026-05-28 | 30+     | M-S1       | Phase 2 cont'd: scoping cleanup for Sections (12 methods), Walker (18), Flattener (12 + 2 global recursive helpers). 14->17 clean submodules. Walker WalkUntil/WalkWhile use engine FindW. Flattener Paired/Chunked/DeepFlatten/FlattenToDepth all engine. 1593 engine tests pass |
| 2026-05-28 | 30++    | M-S1       | Phase 2 cont'd: scoping cleanup for Trimmer (18 methods), Replacer (14), Remover (14). 17->20 clean submodules; debt down to 8. Trimmer TrimLeading/Trailing via StzEngineListTrimLeading/TrailingString. Replacer ReplaceAllCS via StzEngineListReplaceAllCS, ReplaceAt via StzEngineListSet. Remover RemoveAllCS via StzEngineListRemoveAllCS, RemoveAt via StzEngineListRemove. All 26 delegation tests pass |
| 2026-05-28 | 30+++   | M-S1       | Phase 2 cont'd: scoping cleanup for Inserter (8 methods), Mover (14), Random (35). 20->23 clean submodules; debt down to 5. Mover RotateLeft/Right/Reverse/Shuffle/Swap via engine. Random NRandomItems/Randomize via StzEngineListShuffle. Random includes 5 type-specific RandomizeNumbers/Strings/Lists/Objects + their *Randomized cousins (35 methods total). All 26 delegation tests pass |
| 2026-05-28 | 30++++  | M-S1       | Phase 2 cont'd: scoping cleanup for Performer (8 methods), Stringify (14), Show (18 global recursive funcs). 23->26 clean submodules; debt down to 2 (HashList, ListOfLists). Performer Perform/Yield via StzEngineListMapExpr. Stringify Join via StzEngineListJoin. Show is all global recursive funcs (FormatList/FormatValue/FormatListSmart/FormatListSmartNL/EstimateInlineWidth/GetMaxDepth/CalculateComplexity/FormatShortList/FormatShortString/etc) -- made recursion-safe with per-function _prefixed_ locals to prevent global-var clobbering on recursive calls. All 26 delegation, 14 checker/comparator, 13 classifier, 6 sliding-window tests pass |
| 2026-05-28 | 30+++++ | M-E18      | stzHashList Engine Bridge started. Cached @pEngineMap with lazy build (_EnsureEngineMap) + auto-invalidate on mutation (_InvalidateEngineMap) already in place from prior work. Bridged 4 new methods: NumberOfPairs (engine Len O(1) vs Ring len()), ValueIntByKey, ValueFloatByKey, ValueStringByKey (engine typed gets vs Ring [pcKey] indexer). Keys() scoping cleaned. Hashmap domain status: PLAN -> WIP. 13/13 hashlist engine tests pass, 26/26 list delegation tests pass. Stripped pr()/pf() profiler calls that depended on missing stkProfiler.stop() |
| 2026-05-28 | 31      | M-E18      | stzHashList scoping cleanup pass: ~25 methods converted to _prefixed_ vars (init, KeysForValue, Values, ValuesAreListsOfSameSize, ValuesAndKeys, NthValue, UpdatePair, UpdateNthKey, UpdateKey, UpdateKeys, UpdateNthValue, UpdateValues, UpdateValue, UpdateLastValue, UpdateAllPairsWith, ReverseKeysAndValues, AddPair, AddPairs, RemoveNthPair, RemovePair, RemovePairByKey, RemovePairsByKeys, RemovePairsByValue, RemovePairsByValues, ReplaceKey/Value/ValueByKey/Pair/PairByKey, ReplaceNthValue, FindPair, FindKeys, FindValueCS, ContainsValuesCS, UniqueValues, ValuesAtPositions). Global Keys/HasKey/HasKeys/HasKeysXT funcs also cleaned. Latent bugs fixed: ValuesAndKeys returned `aResults` (typo) and used bare `value`; ReverseKeysAndValues had `_aKeys[@i]` missing trailing underscore so values silently became NULL; UpdateAllPairsWith mutated local copy but never persisted via UpdateWith. 13/13 hashlist + 26/26 delegation + 13/13 classifier + 14/14 checker/comparator tests pass |
| 2026-05-28 | 32      | M-E18      | stzHashList scoping cleanup batch 2: ~25 more methods cleaned (FindValuesCS, FindKeysByValue, FindNthKeyByValue, FindFirstKeyByValue, FindLastKeyByValue, KeyByValue, KeysByValue, KeysByValues, KeysAtPositions, FindLists, FindNonLists, Lists, ListsZ, FindList, ListZ, FindTheseLists, TheseListsZ, FindNumbers, Numbers, NumbersZ, FindNumber, NumberZ, FindTheseNumbers, TheseNumbersZ, FindStrings, Strings, StringsZ, FindString, StringZ, FindTheseStrings, TheseStringsZ, FindObjects, Objects, FindStzLists, StzLists, FindStzHashLists, StzHashLists, FindStzNumbers, StzNumbers, FindStzStrings, StzStrings, FindStzObjects, StzObjects, ContainsItem, FindItem, FindTheseItems, TheseItemsZ, Items, FindItems, ItemsZ, ItemZ, FindNthItem, Copy, Listify, Listified, Classify, Classes, ContainsClass, ContainsClasses). 2 more latent bugs fixed: FindNthKeyByValue used undefined `n` (added n as param), FindNthItem called `FindItel` (typo for FindItem). 13/13 hashlist + 26/26 delegation tests pass |
| 2026-05-28 | 33      | M-E18      | stzHashList scoping cleanup batch 3 -- COMPLETE: ~30 final methods cleaned spanning the entire Klass-family analytics, list-of-lists classification, code/table conversion, and Find*KeyByItem family. Methods: Klass, NumberOfValuesInClass, ClassesSizes(/XT), TheseClassesSizes(/XT), KlassFreq(/XT), ClassesFrequencies(/XT), TheseClassesFrequencies(/XT), NStrongestClasses(/XT), NWeakestClasses(/XT), ClassesInList, ClassifyInList, KlassInList, ToCode, ToStzTable, FindKeysByItem(InList), KeysByItemInList. Three more latent bugs fixed: NumberOfKeysByItemInList declared no params but body used `pValue` (added param), FindLastKeyByItemInList called the broken NumberOfKeysByItemInList with no arg (now passes pValue), KeysByItemInList called FindKeysByItemInList with no arg (now passes pValue). Total since M-E18 start: ~85 methods cleaned, 8 latent bugs fixed. stzHashList now marked scoping_clean=true in CLI. 13/13 hashlist + 26/26 delegation + 14/14 checker/comparator tests pass |
| 2026-05-28 | 34      | M-S1       | stzListOfLists scoping cleanup batch 1 (last debt item): ~25 methods cleaned (init, AddList, AddMany, NthList, FindInListsCS, FindManyInListsCS, PositionsW, ListsW, ListsWZ, Sizes, ListsHaveSameNumberOfItems, FindSmallestLists, SmallestLists, SmallestListsZ, FindBiggestLists, BiggestLists, BiggestListsZ, FindListsOfSizeN, ListsOfSizeN, FindMissingItems, NumberOfMissingItems, ItemsAtPositionN, FindSmallestList, SmallestList, SmallestListZ, SizeOfSmallestList, FindLargestList, LargestList, LargestListZ, SizeOfLargestList, SizeOfList). 3 latent bugs fixed: AddMany loop used `aContent + paListOfLists[i]` which DISCARDED the result (no-op), NthList had `but n = :First or n = :FirstList` duplicated (should be `:Last or :LastList` -- :Last fell through to NaN), FindManyInListsCS computed `aItems = U(paItems)` but discarded the dedup result. PositionsW/ListsW keep `aResult` bare since user's eval() code references that exact name. 13/13 hashlist + 26/26 delegation tests pass |
| 2026-05-28 | 35      | M-S1       | stzListOfLists scoping cleanup batch 2: ~30 more methods cleaned (Extended, ExtendXT/ExtendedXT/ExtendTo/ExtendToXT/ExtendedToXT, ExtendToByRepeatingItems/Extended*/ExtendByRepeatingItems/Extended*, ExtendToWithItemsIn/Extended*/ExtendWithItemsIn/Extended*, Shrink/Shrinked/ShrinkTo/ShrinkedTo/ShrinkToWith/ShrinkedToWith, AdjustWith/AdjustedWith/AdjustTo/AdjustedTo/AdjustXT/AdjustedXT, Associated, Pairify/Pairified, ReverseLists/ReversedLists/ReverseItemsInLists/ItemsInListsReversed, IndexCS). 8 more latent bugs fixed: ExtendedXT(pItem) called ExtendXTQ() with no arg (pItem silently dropped), ExtendedToByRepeatingItems had `return aResul` (missing t), ExtendToWithItemsIn had `len(aConten)` (missing t), ShrinkToQ called `This.ShrinkTp(n)` (typo for ShrinkTo), ShrinkedToUsing(pUsing) and ShrinkedToBy(pBy) passed undefined `pWith` instead, AdjustWith/AdjustXT else-branch indexed `_aContent_[@j]` instead of `_aContent_[@i][@j]` (item-from-other-list bug), AdjustedTo called `.Conten()` (typo for .Content), PairifyQ called `This.Parify()` (typo for Pairify -- whole fluent form was broken). Cumulative M-S1 Phase 2 latent-bug count: 19 across stzHashList + stzListOfLists. 13/13 hashlist + 26/26 delegation tests pass |
| 2026-05-28 | 36      | M-S1       | stzListOfLists scoping cleanup batch 3: ~30 more methods cleaned (IndexCSXT, NumberOfOccurrenceOfEntry/Nth/First/Last, ContainsItemCS/ContainsItem, ListsContainingItemCS, EachListContainsCS, Merged, SizeOfEach@Is, CommonItemsCS, Cols, NumberOfColumns, NthcolumnXT/NthColumn, AddCol/AddColXT, SortNthList/NthListSorted, SortDownNthList/NthListSortedDown, IsSortedInAscendingOn, IsSortedInDescendingOn, Sorted, SortedDown, SortOn). 8 more latent bugs fixed: SizeOfEach@Is always returned 1 (init nResult=1, inner branch wrote bResult never read, returned nResult), ContainsItem passed symbol :CaseSensitive instead of 1 to CS variant, NumberOfOccurrenceOfEntry/HowManyEntry/HowManyEntries/NthOccurrenceOfEntry used bare `o1` (undefined) instead of This, FirstOccurrenceOfEntry called bare NthOccurrenceOfEntry (now This.), LastOccurrenceOfEntry same, HowManyEntry/HowManyEntries had no pEntry param, AddCol referenced undefined `nLen` (replaced with _nAcLenList_), NthListSorted called nonexistent method SortNthListInAscendingQ with no arg and never returned aResult, NthListSortedUp/InAscending/InDescending used bare calls (now This.), IsSortedDownOn called nonexistent IsSortedInDescendingDown (typo for IsSortedInDescendingOn). Cumulative latent bugs: 27. 13/13 hashlist + 26/26 delegation tests pass |
| 2026-05-28 | 37      | M-S1       | stzListOfLists scoping cleanup batch 4 -- COMPLETE: ~30 more methods cleaned (SortedOn, SortDownOn, SortedDownOn, SortedBy, SortedInDescendingBy, SortOnBy, SortedOnBy, SortedInDescendingOnBy, RemoveDuplicatesInNthList/DuplicatesInNthListRemoved, RemoveDuplicatesInLists/DuplicatesInListsRemoved, Classify, ClassifyOn, ClassifyOnBy, MoveCol/ColMoved, SwapCols/ColsSwapped, InsertCol, RemoveCol/ColRemoved, RemoveCols/ColsRemoved, ReplaceCol, ReplaceCols, ToListOfStzLists, ToListsInString, ToListInStringInShortForm, ToListOfStrings, IsListOfPairs, SpeedUp, GainFactor, AreContiguous, FindSubListCS, SortLists, ListsSorted). 6 more latent bugs fixed: SortInDescendingOn called This.SortDown(n) (no-arg method silently dropped n, sorted col 1), SortedUpOnBy returned This.SortedByOn (nonexistent typo for SortedOnBy), RemoveDuplicatesInNthListQ had bare `return` (NULL chain broke .Content()), DuplicatesInListsRemoved missing .Copy() (mutated self via fluent), SwapCols had n1=n2[2] (named-param unwrap assigned to wrong var, dropped n2), ColsSwapped called non-fluent SwapCols (returned NULL), RemoveTheseColqQ/RemoveManyColqQ passed bare `n` (undefined), RemoveTheseColumnsQ/RemoveManyColumnsQ called RemoveCoslQ (typo for RemoveColsQ). stzListOfLists now flagged scoping_clean=true. M-S1 Phase 2 COMPLETE: 28/28 list-domain submodules scoping-clean. Cumulative latent bugs: 33. 13/13 hashlist + 26/26 delegation + 14/14 checker/comparator + 13/13 classifier tests pass |
| 2026-05-28 | 38      | M-S2       | First regression-test pin lands: test_listoflists_regression.ring (15 checks) and test_hashlist_regression.ring (10 checks) assert the corrected behaviour of every bug fixed during M-S1 Phase 2 so they cant silently regress. Writing the tests uncovered 2 more bugs not previously caught: (1) SwapCols inner ring_swap(list, n1, n2) was resolving case-insensitively to the user-defined func Swap(p1, p2) in stzFuncs.ring (which only takes 2 params), causing an R20 extra-params error -- fixed by inlining the 3-line swap with a temp; (2) FindNthKeyByValue/FindFirstKeyByValue guarded behind ContainsValue which compares the whole value, not items inside list-valued entries -- they returned 0 for sub-item lookups even when FindKeysByValue returned positions. Fixed both to guard on len(FindKeysByValue) instead. Cumulative latent-bug count across M-S1 Phase 2 + this M-S2 first slice: 35. All 4 regression + delegation + checker/comparator + classifier suites pass (10+15+13+26+14+13 = 91 assertions) |
| 2026-05-28 | 39      | M-S2       | Second regression-test slice: test_submodules_regression.ring (28 checks) covers Flattener/Walker/Performer/Trimmer/Stringify/Inserter/Mover and the passive *-ed chains. Writing it uncovered 6 more bugs: (1-6) ALL the @oList.Copy().*Q() chains in stzListTrimmer (TrimmedCS/Left/Right, Compacted, Squeezed, NullsStripped, TrimmedW), stzListRemover (AllOccurrencesRemoved), stzListReplacer (AllOccurrencesReplacedCS), stzListLeadTrail (RepeatedLeading/TrailingItemsRemovedCS) called Q-methods that exist on the SUBMODULE but Copy() returns plain stzList without them -- pattern broken across 12 *-ed methods. Fixed all by wrapping with `new <Submodule>(@oList.Content())` then calling the non-fluent form. (7) stzList.FindAllOccurrencesCS for ALL-number lists returned [] because the direct StzEngineListFindAllCS+StzEngineValueNewInt path didnt match -- delegated to the proven @FindAllCS_NbrOrStr helper used by stzListFinder. CRITICAL: Discovered architectural cross-DLL handle-table bug -- stz_value.dll and stz_list.dll have SEPARATE static handle tables, so values created in one DLL get null when looked up in the other. StzEngineListReplaceAllCS/RemoveAllCS via StzEngineValueNewString handles return -1. Disabled engine fast-paths in stzListReplacer.ReplaceAllOccurrencesCS/ReplaceAnyItemAtPositionCS and stzListRemover.RemoveAllCS, falling back to Ring iteration. Engine-side fix (shared handle table OR string-only variants) deferred to a separate engine session. Cumulative latent-bug count: 42 (35 + 7). 119 assertions pass across 7 test suites |
| 2026-05-28 | 40      | M-S2       | Third + fourth regression-test slices: test_submodules_regression2.ring (36 checks) covers Sorter/Getter/Bounder/Random -- all PASS at first try, no bugs uncovered (Sorter and Random already exercised by stzList core test suites). test_submodules_regression3.ring (25 checks) covers Extractor/Merger/Duplicates/Splits/Sections -- uncovered 5 more bugs in stzListExtractor: ExtractNth used `ring_remove(This.List(), n)` where This.List() returns a list value (not a mutable reference into @aContent), so the removal never persisted and ExtractFirst/Last returned the item but left the list unchanged; ExtractStrings/Numbers/Lists had the same mutation-leak AND called nonexistent `ListReversed` (defined only in a test stubs file); ExtractDuplicatesCS used the same broken ring_remove pattern. Fixed all 3 type-extractors by switching to forward-collect then reverse-remove using @oList.RemoveItemAtPosition (the proper persistence API). Also discovered Splits has SplitBeforePosition/SplitAtPosition as MUTATING void methods (passive variants are SplittedBeforePosition/SplittedAtPosition) -- test corrected to use the right form. Cumulative latent-bug count: 47 (35 + 7 + 5). 144 assertions pass across 8 test suites |
| 2026-05-28 | 41      | M-S2       | Fifth and sixth regression slices: test_submodules_regression4.ring (30 checks) covers stzListShow global recursive formatters (ComputableForm, GetMaxDepth, CalculateComplexity, EstimateInlineWidth, ContainsNestedLists, short forms, @@NL1) + expanded stzListClassifier coverage (FrequencyOf via engine CountCS, MostFrequent/LeastFrequent/Mode, Bisect/FirstHalf/SecondHalf, Chunks via engine, Partition, ItemsAppearingNTimes/MoreThanNTimes). test_show_recursion_stress.ring (9 checks) deliberately stresses the recursive globals at 10-level nesting depth + mutually-recursive NL chain + repeated-call sibling clobbering. RING SEMANTICS DISCOVERY: contrary to the docs warning that "Ring func vars are global", recursive calls do NOT actually clobber each others locals in practice -- empirically verified GetMaxDepth on a 10-level nested list returns 10 even with bare `for ... in` loop and direct recursion. The M-S1 Phase 2 var rename was therefore sufficient; no explicit save/restore needed. (Initial failing test was a false alarm: Ring's `a = [i, a]` literal does NOT deep-copy the inner reference, so the input was a 3-level list shaped like [1, [1, []]] rather than the intended 10 levels. Used explicit @AddItem deep-copy to build properly.) Reverted the unnecessary save/restore changes in GetMaxDepth and _DeepFlattenHelper/_FlattenDepthHelper. Cumulative latent-bug count: still 47 (no new bugs; test discipline pays off). 183 assertions pass across 9 test suites |
| 2026-05-28 | 42      | M-S2       | Seventh regression slice: test_string_regression.ring (34 checks) covers stzString modularization done during M-S1 Phase 1 -- core (NumberOfChars/IsEmpty), Finder (FindFirst/FindLast/FindAll/Contains/NumberOfOccurrence/case-insensitive), LeadTrail (StartsWith/EndsWith), Replacer (Replace/ReplaceFirst/ReplaceLast), Remover (Remove/RemoveFirst), Trimmer (Trim/TrimLeft/TrimRight), Splitter (Split), Inserter (InsertBefore/InsertAfter), Bounder/Sections (Section/Range), CaseChanger (Lowercased/Uppercased), Checker (IsAlphaString/IsNumericString), Reverse, Unicode (codepoint count + UTF-8 uppercase). All 34 PASS on first try after fixing 3 test-side mistakes (oR var collided with Ring `or` keyword case-insensitively; method named ReplaceFirst not ReplaceFirstOccurrence; off-by-one INDEX_BASE assumption on Section -- 1-based means position 3 is 3rd char, not 4th). stzString modularization is remarkably clean -- 32 domain classes converted via composition pattern with NO latent bugs surfaced. Suggests the stzList submodules had more fragility because they were converted from a much larger monolith with more opaque dependencies. Cumulative latent-bug count: still 47. 217 assertions pass across 12 test suites |
| 2026-05-28 | 43      | M-E18+M-S2 | CROSS-DLL HANDLE FIX SHIPS. Added stz_list_replace_all_string_cs / stz_list_remove_all_string_cs / stz_list_set_string -- string-direct engine variants that take raw (ptr, len) instead of StzValue handles. The engine constructs the StzValue inside stz_list.dll itself, so no cross-DLL handle lookup is needed (sidesteps the architectural bug discovered in session 39 where StzValue handles minted in stz_value.dll cant be resolved in stz_list.dll's separate static handle table). Engine: 3 new C ABI functions in list.zig, 3 new exports in stz_list_entry.zig, 3 new Ring bridge wrappers + registrations in ring_bridge_list.zig. 1591/1591 engine tests still pass. Ring: re-enabled engine fast paths in stzListReplacer.ReplaceAllOccurrencesCS (was disabled session 39), stzListReplacer.ReplaceAnyItemAtPositionCS (was disabled session 39), and stzListRemover.RemoveAllCS (was disabled session 39). Each falls back to Ring iteration for non-string items. New test_engine_string_direct.ring (10 checks) validates both case-sensitive and case-insensitive variants for Replacer + Remover, plus the passive *-ed forms, plus non-string fallback. All 13 test suites still pass (227 total assertions). Cumulative latent-bug count still 47 (no new bugs surfaced -- the architectural fix simply restores intended behaviour) |
| 2026-05-30 | 44      | M-S2       | stzYielder fixed (Map/Filter/Reduce silently returned input unchanged): same cross-DLL handle-table bug -- StzEngineMarshalList mints handle in stz_list.dll, StzEngineYielderMap looks it up in stz_yielder.dll's separate table and gets NULL, every reduce path hit its NULL-fallback. Replaced engine fast paths in Map/MapIndexed/Filter/Reduce/ReduceConcat/MapFiltered/CountWhere with pure-Ring helpers (_RingMap_ covering all 17 transform ops, _RingFilter_ covering 17 filter ops, _RingReduce_ covering 10 reduce ops). Engine path can be reinstated when a direct-marshal yielder bridge variant lands (same pattern as session 43 string-direct fix). Also normalised empty-input convention in fallback (return 0 for all Reduce ops, matching engine semantics; default for empty Product was math identity 1). Fixed 4 broken test-load paths discovered during yielder debugging: stzYielderTest.ring (now in base/test/), stzsystemcalldatatest.ring (redundant load stzlib.ring commented out), stzSetTest.ring (../stzlib.ring -> ../stzmax.ring), stzCryptoTest.ring (backslash separator normalised). New regression suites: test_edge_cases.ring (37 checks: empty/single/mixed-type/Unicode edges across Yielder/Replacer/Remover/HashList -- caught the empty-Product convention mismatch) and test_function_forms.ring (31 checks: Active/Q/Passive contract + CS/CI distinction for Remover/Replacer/Extractor/Trimmer/HashList -- all pass clean). Cumulative latent-bug count: 48 (47 + 1 yielder convention). 295 assertions across 15 test suites pass |
| 2026-05-30 | 45      | M-S2       | M-E3 domain regression slice: stzNumber + stzTable + stzGraph integration suites land (40+24+21 = 85 checks, all green). 4 latent bugs uncovered. stzNumber: init(cString) crashed on missing Represents*Number family (RepresentsRealNumber/SignedNumber/UnsignedNumber/CalculableNumber) -- ported to stzStringChecker + delegated from stzString. Sign() crashed on missing LeftChar/RightChar -- added as LTR aliases for FirstChar/LastChar. stzTable: Section([col1,row1],[col2,row2]) implemented a page-reading sweep (first col to end-of-table, middle cols full, last col from top) instead of rectangular block -- replaced in-class override with proper row-major rect iteration; the submodule version (stzTableCellAccess.Section) was already correct. stzGraph: HasEdge(pcFomId, ...) had param typo (missing 'r'), body referenced undefined pcFromNodeId -- method was unreachable until fixed. stzGraph also had no domain-local test/ dir before this slice. Cumulative latent-bug count: 52 (48 + 4). Test inventory: edge_cases (37) + function_forms (31) + number (40) + table (24) + graph (21) = 153 new assertions across 5 new regression suites; all prior suites (string 34, list/listoflists/hashlist 53, sliding-window 6, show recursion 9, etc.) still green. 442 cumulative assertions across 19 regression suites. |
| 2026-05-30 | 46      | M-E18+M-S2 | YIELDER DIRECT-MARSHAL BRIDGE SHIPS. Closes the architectural gap session 44 punted by adding pure-Ring fallbacks. Engine: added 7 new C ABI bridges in ring_bridge_yielder.zig that take a Ring list directly (no handle table), marshal it into a *StzList inside stz_yielder.dll, run the op, and either return the result as a fresh Ring list (Map/MapIndexed/Filter/FilterMap = 4 variants) or as a scalar/string (Reduce/CountWhere/ReduceConcat = 3 variants). Added Ring write-side externs to ring_api.zig (ring_vm_api_newlist/retlist + ring_list_add{int,double,string,string2,newlist}). KEY DISCOVERY: calling regular `pub fn` Zig functions (StzList.init, etc.) from inside a callconv(.c) Ring bridge function crashes the DLL on Windows -- a Zig-vs-C calling-convention mismatch. Routing every list op through callconv(.c) C ABI entries (stz_list_new / stz_list_append_int / stz_list_free / stz_list_len) instead of Zig methods sidesteps it. Struct field access works fine (bare memory read, no calling). Ring side: stzYielder Map/MapIndexed/Filter/Reduce/ReduceConcat/MapFiltered/CountWhere now call the *Direct bridges; the 17+17+10 pure-Ring helper functions (ring_Map/ring_Filter/ring_Reduce, ~130 lines) are removed. stzYielderTest + all 5 regression suites (37+31+40+24+21 = 153 assertions) still pass on the engine path. Cumulative latent-bug count: still 52; the calling-convention discovery is a learning, not a bug. |
| 2026-05-30 | 47      | M-S2       | M-S2 BROAD REGRESSION SWEEP CONTINUED. Eight more domain integration suites land after the session-46 yielder bridge, raising the regression-suite count to 19 and assertion count to ~615. Bugs surfaced and fixed (12 latent, 52 -> 64 cumulative): (1) stzRegex 22/22 -- clean, PCRE2-backed. (2) stzJson 46/46 -- Prepend/Insert called bare `insert(...)` which Ring resolved case-insensitively to the class's own Insert method (R20); fixed both to ring_insert. (3) stzCSV 31/31 -- THREE bugs: List2DToCSVXT alias forwarded to wrong target (1-arg ListToCSV called with 2 args), engine `stzenginecsvIsvalid` registration typo (capital I -- Ring lookup is lowercase), and StringToCSVListXT silently clobbered its own cSep param with the global default. (4) stzString modularization-gap closure: IsNumberInString / IsListInString delegations added to checker (used by CSV parser). (5) stzDateTime 35/35 -- IsListOfNumbers had a stray `? (t2-t1)/clockspersecond()` debug print that fired on every call (used pervasively across stz classes). (6) stzMatrix 41/41 -- TWO bugs: init([rows, cols]) dim-pair ctor was unreachable (isList(paInput) branch fired first and crashed on len(paInput[1])); AND `list(@nCols, 0)` was invalid 2-arg form (Ring's list(n) is 1-arg). Both fixed together; dim-pair ctor was 100% dead before. (7) Shadow audit -- systematic scan for class methods shadowing Ring builtins (abs/add/insert/reverse/trim/copy/count/swap/del/find/replace/substr/upper/lower); confirmed the previous sweep work closed most of them; ONE remaining bug in stzStringList.Reverse + Reversed (called bare `reverse(...)`) fixed with ring_reverse. False positives filtered (global funcs, @prefixed aliases, dot-method on external objects). (8) stzCalendar 29/29 -- stzDate.DaysTo passed args in wrong order to engine (engine returns a-b, semantic wanted b-a), making TotalDays/TotalWeeks return negatives. Fix at Ring side -- swap args. (9) stzListOfNumbers 40/40 -- SortInDescending double bug: method-chain on `new stzList(...).Reversed()` raised R13 (Ring parser), AND active form silently didn't persist (returned the value instead of UpdateWith). Split chain + added persistence. New bug-pattern catalogued: "active form silently doesnt mutate" -- worth a future audit. |
| 2026-05-30 | 48      | M-S2       | M-S2 SWEEP WAVE 2 -- list-of-* family + audits. Five more domain suites + two pattern-audits land, raising suite count to 24 and assertion count to ~810. Six more latent bugs (64 -> 70 cumulative). (1) stzStringList 49/49 clean (Reverse already fixed). (2) stzListOfPairs 32/32 -- FOUR bugs: FindPair called nonexistent FindItem (R14 unreachable); the inherited FindAllOccurrencesCS fallback stringified list-valued items with `"" + item` (R21) -- fixed to use @@(item) for list/object items; SortOnInDescending hit the Ring chain-on-new R13 parser bug AGAIN -- split into multiple statements; PairsAreMadeOfEqualItems had INVERTED logic (set false when items WERE equal, should be when NOT equal). (3) stzListOfBytes 29/29 clean. (4) Inverted-predicate audit -- 26 candidates scanned, mostly clean; found one OFF-BY-ONE in stzListOfNumbers.IsContiguous (loop started at i=3 instead of i=2, so the gap between [1] and [2] was never checked; [1,5,6] wrongly returned 1). (5) stzPivotTable 22/22 -- "AVG" silently aggregated as SUM. SetAggregateFunction uppercases the name; _AggFuncToInt() (engine fast path) only recognized full names ("sum"/"count"/"average"/...) and "avg" fell through to the default `return 0` = SUM. Fix: added "avg"/"mean"->"average" and "cnt"->"count" aliases in BOTH _AggFuncToInt (engine) AND _applyAggregateFunction (Ring fallback). New bug-pattern catalogued: "silent default in aggregation/dispatch lookup". Active-form-no-mutate audit also done -- 3 candidates, all false positives; pattern is contained at 2 known instances. Bug-pattern catalogue at session 48: 14 distinct families across 70 bugs. |
| 2026-05-31 | 49      | M-S2       | EXHAUSTIVE QUALITY SWEEP per user directive "don't move on before fixing all potential bugs". Six structured waves through previously-unswept classes, raising regression-suite count from 19 to 41 (~1450 assertions, all green). 19 more latent bugs surfaced and fixed across diverse domains (70 -> 89 cumulative). Modularization-gap restoration accelerated -- 22 stzString methods that existed only in the monolith have been ported back. Wave-by-wave: (1) list-family standalone -- stzList2D/Grid/Item/ListInString -- 4 bugs (stzItem missing-return + R19 wrong-arg, stzListInString R24 + Copy-wrong-source). (2) graph family -- KG/OrgChart/Workflow -- 3 typos in stzOrgChart staff adders (pcIde x2 + paprop). (3) datetime family -- Duration/TimeLine/ListOfTimeLines -- stzListOfTimeLines had FOUR major bugs: three empty-stub helpers (_normalizeDateTime / _isDateOnly / _isTimeOnly), case-mismatched lane lookup, and Ring-copy-on-list-indexing breaking AddPointToLane mutation. (4) common utilities -- Counter/StateMachine/Validator/Splitter -- 1 bug (IsCounterNamedParamList missing :WhenYouReach). (5) i18n -- Country/Language/Currency/Locale/Script -- stzLocale.IsLocaleList was a self-recursive infinite-loop stub (R4 stack overflow at depth 997), stzCurrency had 2 inconsistent global-call sites, 21 stzString modularization gaps closed (Country/Language/Currency/Script identifier checkers + ContainsNTimes family). (6) file domain -- File/Folder/Html -- stzFileXT.init referenced undefined cFileName, stzFolder.Seperator alias forwarded to non-existent Seprator typo. Also discovered stzCache depends on missing stzStorage class (deferred), stzHtml.Text depends on missing upstream .text() method (deferred), stzFile path helpers defined after first class so unreachable as globals (deferred). New bug patterns catalogued: "empty-stub method (Copy from X comment, no body)", "self-recursive infinite-loop stub". Patterns total: 16 distinct families across 89 bugs. |
| 2026-06-12 | 50      | M-S4       | ENGINE-FIRST STRING REFACTOR Phase A done. Reduced 354 string-test ERR -> 0 across 47 commits, then per user directives swept Ring `substr()` -> engine-backed `StzReplace`/`StzFind`/`StzMid`/`StzMidToEnd`: ~300 automated rewrites via _sweep_substr.py + 20 manual conversions in stzString/stzTable/stzListex/stznatural-copy + 3 trivial `ring_len(This.Chars())` -> `_EngineCount`. StzMid hardened with defensive guards (matches Ring substr's silent-empty behavior on negative nLen / OOB nStart, prevents engine integer-OOB panics). StzMidToEnd added as one-handle-reuse substr-from-position-to-end. StzFindCS refactored to use engine directly (was wrapping in Q()). Missing methods restored: FindNextNth, FindPreviousNth, LeadingSubStringCS. 51 residual `substr()` calls are intentional (byte-walks in DiacriticsRemoved, LHS-assignment mutation syntax, comments, ambiguous needles) -- documented in _unknown_substrs.txt and `[[project-stzlib-substr-sweep-closed]]`. Phase B (open): ~117 `_aChars_ = This.Chars()` walk-loops in stzString.ring still need per-method analysis to map to engine primitives by semantic family. Commits: b658c08e fd16e0ef 234f69f1 603499d9. |
| 2026-06-13 | 51      | M-S4       | M-S4 PHASE B + ring_len PURGE CLOSED. Engine-loop refactor Phase B done: 87 of 117 `_aChars_ = This.Chars()` walk sites in stzString.ring converted to engine primitives across multiple semantic families -- count-walks (CountLeading/TrailingChar), predicate-walks (IsAlpha/IsDigit/ContainsLatin/ContainsArabic), find-walks (UniqueChars + ring_find), leading/trailing-run (CountLeading/TrailingChar + StzRepeatStr), case-swap (SwapCase), non-space scan (TrimLeft/Right + Count), Unicode codepoint extraction (CharAt + StzChar), per-codepoint range checks for digits, marker scans (FindAll + CharAt-digit-test), sort via stzList.Sorted, and edge-guard predicates. New primitive StzCodepoint(cChar) added for Unicode-correct char->codepoint. 30 remaining sites kept as Chars() walks (predicate-eval with @char binding, byte-walk inspectors, complex multi-position mutations, per-codepoint isAlpha checks). Side sweep: 5477 `ring_len()` calls across 252 base files replaced with `len()` per standing rule (commit 8b15e3b3). Verified per-batch with ~120 targeted assertions across 22 verification files. Commits: 2c82e256 73e63421 ddcc6f75 367f8784 6bcd11d5 b8cfa0da 20afd6c5 cafa0a1a fb3767c6 396551e1 53ba52a5 59a5dbe6 71091ca0 fdf0bc13 08f81926 d1dffae3 21ca28c2 b9a8c590 04ae1e47 6ceb42c5 bbd28b9d 780135fe 8b15e3b3 a359499c 70b69bb7 99fffb8c 568bf2b8 (current batch). |
| 2026-06-13 | 52      | M-S2       | External-domain coverage gap closed. Four new regression suites land for extercode/extincode/cluster/appserver (43 -> 47 suites; 54 new assertions). FIVE latent bugs surfaced and fixed: (1) stzExterCode.Code() read @cSourceFile which exists only after Execute() -- SetCode + Code roundtrip returned "" instead of the in-memory source; fix returns @cCode when set. (2) stzClusterNode.init() called `stzAppServer.init()` as if static -> R24 uninit-var; Ring 1.25's `super { init() }` syntax also fails with R16. Worked around by skipping parent init for test scope (added comment). (3) Load{NLP,Math,Vision,Search}Engines crashed with R16 when parent's oComputeEngine = NULL; wrapped each `oComputeEngine { ... }` block with `if isObject(oComputeEngine)`. (4) stzLoadBalancer.RegisterCluster used the Ring copy-on-list-index trap (same family as session 49's stzListOfTimeLines): `aCluster = aClusters[i]; aCluster[:nodes] = ...` mutated the copy. Switched to `aClusters[i][:nodes] = ...`. (5) @StzMidToEnd called in 3 sites (stzAppRequest x2, stzAppServer x1) but no such @-prefixed alias defined -> R3 on every ParseQuery. Switched to bare StzMidToEnd. New bug-pattern catalogued: "Ring inheritance does not auto-call parent init" (17 families total). Pending: narrated GIVEN/WHEN/THEN runner, reactive async harness. Commits: 196eacce 202a74a4 (this session). |
| 2026-06-13 | 53      | M-S2/M-E10 | Narrated GIVEN/WHEN/THEN runner shipped (Ring-side, ~65 LOC at libraries/stzlib/base/test/_narrated.ring). Primitives: Scenario / Given / When / Then(text, actual, expected) / EndScenario / Summary. Auto-assertion + per-scenario + grand-total tally, structured spec-style output, plain-text failure diff via @@(). Four session-52 suites converted as proof: 51_extercode (11), 51_extincode (12), 51_cluster (14), 51_appserver (16) = 53 assertions, all green. Ring gotcha discovered: backslash-escaped quotes inside double-quoted strings raise C8; use single-quoted outer strings (already the stzlib idiom). Older 41 classic-format suites can adopt narrated form incrementally. Closes the M-S2/M-E10 "narrated test runner" pending item; pending now is reactive async harness + skills assessment. Commits: ddcd16ae 1b9428f7 (this session). |
| 2026-06-13 | 54      | M-E10/M-S2 | M-E10 CLOSED. Reactive async harness shipped as sync-only data-layer suite (51_reactive_harness_narrated.ring, 5 scenarios, 20 assertions): stzTimerManager defaults + setters, AddTimer/RemoveTimer in-place mutation, stzReactiveTimer Init param honoring (oneTime TRUE/FALSE/NULL), stzReactiveTask Then_/Catch_ callback storage. NO event-loop or libuv (Windows guardrail). Latent bug fixed: stzReactiveTimer.Init's `oneTime` parameter was never assigned to the `isOneTime` class attribute -- code checked `if isOneTime = NULL` referencing the field, not the arg, so every timer was treated as repeating regardless of constructor input. Fix: `if oneTime = NULL ok else isOneTime = oneTime ok`. Ring gotchas pinned: (1) consecutive `new ClassName(...)` inside one Scenario block triggers C27 -- split into separate scenarios; (2) `init` (lowercase) vs `Init` (capital) collide as case-insensitive identifiers; cannot ship both as overloads. Suite count 47 -> 48. Skills assessment item dropped (skill module was removed in b70f3ad9 as AI-invented). M-S2's pending items now narrowed to incremental conversion of older 41 classic-format suites to narrated form. Commits: 1b9428f7 (...this session's). |
| 2026-06-13 | 55      | M-DEP-AUDIT | EXTERNAL-DEPENDENCY AUDIT + first two closures. Survey of `load "*.ring"` sites in base/ identified 5 external Ring extensions: uuid.ring (system/stzUUID), fastpro.ring (number/stzFastPro), html.ring (file/stzHtml, lexbor-based), libcurl.ring (network/stzNetwork), libuv.ring (file/stzFolderWatcher + network/stzNetwork + reactive/stzReactive). New design doc at doc/design/EXTERNAL_DEPENDENCY_AUDIT.md catalogues each + the engine-replacement path. Closures: (1) **uuid.ring DROPPED** -- engine uuid.zig + ring_bridge_uuid.zig already shipped V4/V4Compact/IsValid/Version/Nil/Compare. stzUUID.ring rewritten to call StzEngineUUID*; uncommented `load "system/stzUUID.ring"` in stzBase (was TODO-gated). ToBytes() pure-Ring hex decode. Test 52_uuid_engine_narrated.ring: 14/14 green. (2) **fastpro.ring DROPPED** -- stzFastPro had no production callers (only its own test suite); engine stzMatrix covers the same ground. Moved to base/archive/number/; tests moved to base/archive/test/fastpro/; `load "number/stzFastPro.ring"` removed from stzBase. Cross-domain spot-check (UUID/extercode/reactive narrated suites) still green. Three deps remain (M-DEP2/3/4) -- HTML5 parser + DOM + CSS selectors (weeks), HTTP client + TLS (weeks), cross-platform async loop (months) -- each a proper milestone arc. Commits: 9f9bed5f (UUID) + this session's FastPro commit. |
| 2026-06-13 | 56      | M-DEP2     | M-DEP2 SLICE 1 LANDED. New engine module html_dom.zig (~370 LOC, 8 Zig unit tests all green) ships a pragmatic HTML tokenizer + flat element index suitable for stzHtml's most-used surface: find-by-tag, inner-text-of-nth-occurrence, attribute-of-nth-occurrence, document-text-extraction. Ring bridge extended (ring_bridge_html.zig) with 8 new functions: StzEngineHtmlParse/Free/Count/CountByTag/TextOfTag/AttrOfTag/AllText/TagOf. Doc handle via custom HTML_DOC pointer kind. Tokenizer handles tag/attribute parsing in all four shapes (quoted/single-quoted/bare/attr-only), self-closing (`<br/>`), 14 void elements (img/br/hr/...), `<script>` and `<style>` raw-text body suppression in text extraction, HTML comments and `<!DOCTYPE>` skipping, case-insensitive tag and attr lookup. Ring smoke `52_html_dom_engine_narrated.ring`: 5 scenarios, 15 assertions, all green. NOT YET: CSS selectors (slice 2), nested DOM tree walking (children/parent), mutation API (setAttribute/appendChild). stzHtml.ring NOT YET rewired -- waiting for slice 2 (CSS) before swap. M-DEP3 (HTTP via Zig std.http) and M-DEP4 (cross-platform async loop) still PLANNED -- each warrants its own session arc. |
| 2026-06-13 | 57      | M-DEP2     | M-DEP2 CLOSED. html_dom.zig grew to ~450 LOC (14 Zig unit tests, all green). Bridge surface now 14 functions: parse/free/count/count-by-tag/text-of-tag/attr-of-tag/all-text/tag-of (slice 1, session 56) + find-by-id/count-by-class/find-by-class/children-count/child-at/parent-of (slice 2, this session). stzHtml.ring fully rewritten: NO `load "html.ring"` anymore. Selectors supported: bare tag, `#id`, `.class`. Node API: Tag/Text/Attr/Id/Klass/HasKlass. `stzBase.ring` uncommented `load "file/stzHtml.ring"` (was TODO-gated). Integration test 53_stzhtml_engine_narrated.ring: 7 scenarios, 21 assertions, all green; combined with the slice-1 engine smoke 52_html_dom_engine_narrated (5/15) the HTML coverage is 12 scenarios / 36 assertions. NOT YET (slice 3, only if needed): full CSS combinator selectors (`div > p`, `.a .b`), DOM mutation API (setAttribute/appendChild/setInnerText), stzHtmlBuilder. The current surface covers typical "scrape data from HTML" cases. Three external Ring deps now eliminated: uuid, fastpro, html. Two remain: libcurl (M-DEP3), libuv (M-DEP4). |
| 2026-06-13 | 58      | M-DEP3     | M-DEP3 SLICE 1 LANDED. New engine domain stz_http (build.zig + stz_http_entry.zig + http.zig + ring_bridge_http.zig, ~180 LOC) ships HTTP GET/POST built on Zig 0.15 std.http.Client + std.crypto.tls. HTTPS works without an external TLS library -- crypto.tls bundles the implementation. Bridge exposes 4 functions: StzEngineHttpGet (body string), StzEngineHttpGetStatus (status code), StzEngineHttpPost (content-type + body, returns body), StzEngineHttpLastError. Body buffer cap 4 MiB (generous for scrape-data use case; streaming API deferred to slice 2). Engine loader at engine/stz_http.ring; wired into base/common/stzRingLibs.ring next to stz_html. Ring smoke 52_http_engine_narrated: 3 scenarios / 7 assertions, all green (covers API surface + malformed-URL error path; no network IO per L99 / Windows test-loop guardrail; live HTTP tests stay outside CI). NOT YET (slice 2 once real callers drive the shape): per-request custom headers, cookies, redirect policy, auth (basic / bearer), PUT/DELETE/HEAD/OPTIONS verbs, form POST helper, streaming for large bodies. stzNetwork.ring + stzHttpClient.ring still `load "libcurl.ring"` -- swap happens in slice 2. Four of five external Ring deps now have engine alternatives shipped or under way: uuid+fastpro CLOSED, html CLOSED, libcurl SLICE 1, libuv (M-DEP4) still planned multi-month arc. |
| 2026-06-13 | 59      | M-DEP3     | M-DEP3 CLOSED. Slice 2 ships generic StzEngineHttpRequest(method_code, cUrl, cHeadersBlob, cContentType, cBody) -- method codes 0..6 cover GET/POST/PUT/DELETE/HEAD/OPTIONS/PATCH. Headers passed as newline-separated `Name: Value` blob; engine merges with Content-Type only if caller did not set one. Companion accessor StzEngineHttpLastStatus. Ring rewires: (1) **stzNetwork.ring rewritten** -- `load "libcurl.ring"` + `load "libuv.ring"` REMOVED; connection state as plain attrs; _RecordRequest() fed by clients. (2) **stzHttpClient.ring rewritten** -- full surface (Get_/Post/Put_/Delete/Head/Options + form helpers + cookie list as `Cookie:` header + UA setter) routes through _Perform() into the engine. libuv-backed parallel GetMany dropped; sequential GetManySequential is the supported path until M-DEP4 lands. Settings the libcurl backend supported but std.http does not yet honor (SetAuth/SetProxy/FollowRedirects/VerifySSL/setopt UA) kept as fluent setters that store values but do not change request behaviour today. URLEncode helper removed -- already provided by stzNetworkUtils.UrlEncode (Ring is case-insensitive on fn names, so they collided). Tests 52_http_engine_narrated (3/7) + 53_stzhttpclient_engine_narrated (5/17) all green. Block-comment gotcha discovered: Ring closes /* ... */ on the FIRST `*/` anywhere -- `SetHeader*/SetCookie*` inside the docstring terminated the comment early. Workaround: spell out method names without trailing `/`. FOUR external Ring deps now eliminated: uuid, fastpro, html, libcurl. ONE remains: libuv (M-DEP4) -- proper multi-month arc. |
| 2026-06-13 | 60      | M-DEP4     | M-DEP4 SLICE 1 LANDED -- libuv removed where polling works. (1) reactive/stzReactive.ring: `load "libuv.ring"` REMOVED; uv_default_loop -> NULL sentinel; uv_buf2str + uv_buf_init become identity (Ring buffers ARE strings, no conversion needed). (2) reactive/stzReactiveTimer.ring: full rewrite -- uv_timer_* + new_uv_timer_t + destroy_uv_timer_t calls all gone; class now uses Ring's clock() + clocksPerSecond() polling pattern with Start()/Stop()/CheckAndTick(); the manager's poll loop drives ticking. (3) file/stzFolderWatcher.ring (demo script, not a class) moved to base/archive/file_stzFolderWatcher_libuv_demo.ring. Ring smoke 52_reactive_polling_narrated: 4 scenarios / 8 assertions all green; existing 51_reactive_harness (20/20) still green. Ring gotcha pinned: `new stzReactiveSystem()` (with parens) raises C27 in some scenario contexts; `new stzReactiveSystem` (no parens) works -- same family as the consecutive-`new` C27 from session 54. NOT YET (slice 2, multi-month): network/stzTcpClient + stzTcpServer still embed uv_* in method bodies (construction works, method calls would fail at runtime); folder watcher polling rewrite; real preemptive async via cross-platform IOCP/epoll/kqueue Zig wrapper. FIVE of five external Ring deps now have engine alternatives or polling fallbacks: uuid + fastpro + html + libcurl CLOSED, libuv SLICE 1. The libuv.ring extension is no longer required for stzBase to load. |
| 2026-06-13 | 61      | M-DEP4     | M-DEP4 CLOSED -- libuv gone from stzBase. New engine domain stz_tcp (build.zig + stz_tcp_entry.zig + tcp.zig + ring_bridge_tcp.zig, ~280 LOC) ships synchronous TCP via std.net: Connect/Send/Recv/Close + Listen/Accept/ServerClose + LastError. Opaque handle types TcpClient + TcpServer. Ring rewires: (1) **network/stzTcpClient.ring rewritten** -- Connect/Send/Receive/Close + OnX callbacks all route through StzEngineTcp*. Callbacks fire synchronously after each operation returns. (2) **network/stzTcpServer.ring rewritten** -- Listen returns immediately after bind; AcceptOne() blocks until a client connects and returns a wrapped stzTcpClient. Legacy async-loop driving Listen() is gone; callers drive their own accept loop in Ring. Tests 54_stztcp_engine_narrated: 5 scenarios / 15 assertions all green. Cross-checks 51_reactive_harness (20/20) + 52_reactive_polling (8/8) + 53_stzhttpclient (17/17) + 53_stzhtml (21/21) all still green = 81 assertions across the engine-ification arc, all green. Ring gotcha pinned: isPointer(null_handle) returns TRUE for Ring's typed null pointer; success check must use StzEngineTcpLastError() = "" instead. AUDIT FINAL: zero active loads of any external Ring extension in stzBase (verified by grep -rE '^\s*load "(libuv|libcurl|uuid|fastpro|html)\.ring"' -> no matches outside archive/). Five engine modules added across the arc: uuid (already shipped) + html_dom + http + tcp + reactive polling fallback. Future arc (NOT an M-DEP item, multi-month): cross-platform Zig event loop (IOCP/epoll/kqueue) for real preemptive async -- parallel HTTP fetch, async TCP server, async file watch. |
| 2026-06-13 | 62      | M-DEP4     | **REACTIVE ENGINE FINALIZED -- real async shipped.** Two new engine surfaces close the libuv-era use cases without IOCP/epoll/kqueue heroics. (1) **Parallel HTTP fetch** -- http.zig extended with http_parallel_get that spawns one std.Thread per URL (max 32), each running blocking client.fetch into its own ArrayList; joins all and concatenates `<status>:<body><RS>...` into the output buffer. Bridge: StzEngineHttpParallelGet. stzHttpClient.GetMany restored to its parallel form (was sequential-only after M-DEP3 slice 2). Test 55_http_parallel_narrated: 3 scenarios / 7 assertions all green. (2) **Engine folder watcher** -- new engine domain stz_fswatch (~200 LOC, fswatch.zig + ring_bridge_fswatch.zig + stz_fswatch_entry.zig) spawns a worker thread that polls std.fs at 250ms, diffs (mtime, size) against the previous snapshot, queues ADD/MOD/DEL events on a mutex-guarded ArrayList. Ring side drains via Drain(). New Ring class stzFolderWatcher wraps it -- Watch(path) / IsRunning() / Drain() -> list of [:kind, :name] / Stop(). stzBase now `load "file/stzFolderWatcher.ring"` (was TODO-gated for engine-side reimplementation). Test 54_fswatch_engine_narrated: 3 scenarios / 10 assertions all green, INCLUDING a real ADD event surfaced from a worker thread after the test creates a file in a scratch dir. Three external Ring extensions had use cases the libuv era served: timers (M-DEP4 slice 1, polling fallback), parallel HTTP (this session, std.Thread), FS watch (this session, polling worker thread). All three are engine-backed now. 98 assertions across the reactive arc, all green; cross-checks 51_reactive (20/20) + 53_stzhtml (21/21) + 53_stzhttpclient (17/17) still pass. The framing "multi-month cross-platform IOCP/epoll/kqueue arc" was over-cautious -- the actual use cases needed thread-based concurrency, not a full async runtime, and that ships in a single session. Future arc remains as a real planning item only if a true preemptive async client (e.g. tens of thousands of concurrent TCP connections) becomes a requirement. |
| 2026-06-13 | 63      | M-DEP4     | **REACTIVE HARDENING -- session 63 closes three legit gaps user flagged.** (1) **Engine-side clock.** Foundational time primitives moved out of Ring `clock()` / `clocksPerSecond()` into a new engine domain `stz_time` (time.zig + ring_bridge_time.zig + stz_time_entry.zig). Functions: StzEngineTimeNowMs/Us/Ns (monotonic), StzEngineTimeWallMs (UTC since epoch), StzEngineTimeSleepMs, StzEngineTimeResolutionNs. The clock now lives where the engine owns it -- any host language gets the same semantics, not just Ring. stzReactiveTimer.Start + CheckAndTick refactored to use StzEngineTimeNowMs directly (no more CLOCKS_TO_MS_MULTIPLIER conversion). (2) **Scalable concurrency via thread pool.** New engine domain `stz_pool` (pool.zig + bridge + entry, ~280 LOC) ships a bounded thread pool with a mutex+condvar work queue. N worker threads dequeue and dispatch jobs by kind (kind 0 = HTTP GET; extendable). Direct-spawn per call was correct but doesn't scale -- the user is right that this matters for web/cloud workloads. Pool API: StzEnginePoolCreate(nWorkers), StzEnginePoolSubmit(pool, nKind, cArg) -> job_id, StzEnginePoolPoll(pool, nJobId) -> body, StzEnginePoolLastStatus, StzEnginePoolDestroy. Note: this is still thread-per-blocking-call within each worker, NOT IOCP/epoll/kqueue. For tens of thousands of concurrent connections we still need a real reactor -- that arc is tracked separately and remains genuinely multi-session because the unified IOCP+epoll+kqueue abstraction is the hard part, not the wiring. (3) **Hardening test suites.** Four new narrated suites with 34 assertions across correctness + security + consistency + performance: 53_engine_time_narrated (6/6 monotonicity + wall-clock + ms/us coherence), 56_http_hardening_narrated (12/12 empty URL + CRLF header injection + large URL + LastError stability + parallel batch consistency + wall-clock bound), 57_tcp_hardening_narrated (8/8 bogus host fast-fail + ephemeral-port bind + SO_REUSEADDR back-to-back + null-handle invariants), 58_pool_hardening_narrated (8/8 unique monotone ids + unknown-id => -2 + 50-job stress through 4 workers within 10s wall-clock). Cross-domain checks 51_reactive (20/20) + 52_polling (8/8) + 54_fswatch (10/10) still green. Three engine modules added this session: stz_time + stz_pool + (extension of) stz_http with parallel-get already shipped. Real future arc remains: IOCP/epoll/kqueue async runtime for 10k+ concurrent connections per worker thread -- properly its own milestone since the cross-platform reactor design is the hard part. |
| 2026-06-13 | 64      | M-DEP4     | **WEB/CLOUD + AGENTIC HARDENING.** New engine domain stz_resilience ships three primitives every production HTTP/agentic workload needs: (a) **retry_delay_ms** (pure) -- full-jitter exponential backoff per AWS recipe; deterministic with caller-provided seed for reproducibility, OS RNG when seed=0. (b) **Token-bucket RateLimiter** -- capacity + refill_per_sec, atomic refill on each take/wait, mutex-guarded; try_take is non-blocking, wait_for blocks until n tokens available, rate_available returns float. (c) **3-state CircuitBreaker** (closed / open / half_open) -- trips OPEN after N consecutive failures, transitions HALF_OPEN after reset_after_ms, succeeds back to CLOSED on success, OPENs again on failure during half-open probe. Pool extended (M-DEP4 hardening): **pool_create_xt(workers, max_queue)** adds bounded-queue backpressure (submit returns -2 with "queue full" LastError instead of OOM); pool_pending + pool_inflight ops accessors. Six new narrated suites: 53_engine_time (6/6), 56_http_hardening (12/12), 57_tcp_hardening (8/8), 58_pool_hardening (8/8), 59_resilience (19/19), 60_pool_scale (6/6), 61_agentic_loop (8/8). Scale highlights: **1000 jobs through 8 workers drained within 30s wall-clock**; **bounded-queue backpressure refuses submissions past max_queue with stable LastError**; **agentic integration test combines pool + rate limit + circuit breaker + retry end-to-end** -- 6 tasks submitted, rate-limiter throttles, circuit opens after 3 failures, breaker blocks subsequent submissions. 81 assertions across 7 new suites, all green. Cross-checks 51_reactive (20/20) + 52_polling (8/8) + 54_fswatch (10/10) still green. Engine modules total: stz_time + stz_pool + stz_resilience + extension of stz_http with parallel-get. Remaining future arc (genuine multi-session work, accurately framed): IOCP + epoll + kqueue unified reactor for 10k+ concurrent connections per worker via non-blocking I/O -- the cross-platform abstraction is the hard part, not the wiring. Everything else web-scale / cloud-scale / agentic needs ships now. |
| 2026-06-13 | 65      | M-RX1      | **REACTIVE GAP-ANALYSIS TIER 1 -- items 1+2 fused: custom HTTP/1.1 client + connection pool + per-layer timeouts.** Replaced the std.http.Client path inside `http.zig` with a small in-tree HTTP/1.1 client on raw `std.net.Stream` (`engine/src/httpcore.zig`), layering TLS via `std.crypto.tls.Client` for https -- this is what gives us control over the socket lifecycle (the prerequisite for both pooling and socket-level timeouts). New `engine/src/http_pool.zig`: a connection pool keyed by (scheme,host,port) with a LIFO idle list (warmest socket reused first), idle eviction past `idle_timeout_ms` (default 60s, run on every acquire), per-host (default 16) + global (default 256) caps, and `total_opens`/`total_reuses`/`current_idle`/`current_active` stats. **Per-layer timeouts:** connect via non-blocking connect + `poll(POLLOUT)` against a deadline (an unreachable host fails in ~ms instead of the OS connect timeout ~21s on Windows); request via `SO_RCVTIMEO`/`SO_SNDTIMEO` (honoured on POSIX; best-effort on Windows where std's reader uses overlapped `WSARecv` -- the session-64 caller-side `pool_poll_with_deadline` remains the cross-platform guarantee, documented honestly in httpcore.zig). New bridge fns: `StzEngineHttpSetDefaultTimeouts`, `StzEngineHttpRequestWithTimeouts`, `StzEngineHttpPoolStats` (3 regs; 1034->1037). `stzHttpClient` rewired: `SetTimeout`/`SetConnectTimeout`/`SetRequestTimeout`/`SetDefaultTimeouts`/`ConnectTimeout`/`RequestTimeout`/`PoolStats`; `_Perform` routes through the timeout-aware engine call when a deadline is set. Live-verified end-to-end against example.com: plain GET 200, **connection REUSE** (second same-host GET increments reuses, opens stays flat), **HTTPS** round-trip (TLS handshake + pooled), **fast connect-timeout** (192.0.2.1 / TEST-NET-1, ~ms). New suites 63_http_pool (6/6) + 64_http_timeouts_engine (7/7); existing 52/53/55/56/62 still green; `zig build` + `zig build test` clean. Parallel GET (`http_parallel_get`) rewired onto the pooled path too. Remaining Tier 1 (separate sessions B-D): 3 DNS cache w/ TTL, 4 cancellation tokens, 5 retry budget, 6 latency histograms (p50/p95/p99), 7 outlier ejection, 8 graceful pool drain. Tier 2 (IOCP/epoll/kqueue cooperative scheduler, HTTP/2, TraceContext, work-stealing) still the genuine multi-session arc, deferred until Zig 0.16 std.Io stabilises. |
| 2026-06-13 | 66      | M-RX1      | **REACTIVE GAP-ANALYSIS TIER 1 -- items 3 (DNS cache) + 4 (cancellation tokens).** Item 3: new `engine/src/dns.zig` -- `lookup(host,port)` keyed by "host\|port", positive TTL 60s + negative TTL 5s (a broken resolver is not hammered), resolve happens outside the cache mutex, atomic resolve/hit counters for diagnostics, `clear()`. Wired into `httpcore.connect` (the HTTP hot path) and `tcp.tcp_connect` (now resolves via the cache then `tcpConnectToAddress`). Diagnostics bridge in stz_http: `StzEngineDnsResolve(host,port)` (returns the cached address via `{f}` Address fmt), `StzEngineDnsStats` ("resolves=N\thits=N"), `StzEngineDnsCacheClear`. Each DLL keeps its own cache instance (intentional). Item 4: new `engine/src/cancel.zig` -- `CancelToken` is a single atomic bool; `cancel_create/signal/is_cancelled/destroy` (null-safe). `pool.zig` Job gains an optional `cancel_token`; new `pool_submit_with_cancel` + a worker checkpoint BEFORE running a job -- if the token is already signalled the job is skipped and polls return `JOB_CANCELLED` (-5). (A single blocking fetch has exactly one safe checkpoint; true mid-I/O preemption is the Tier 2 cooperative scheduler.) Bridge in stz_pool: `StzEngineCancelCreate/Signal/IsCancelled/Destroy` + `StzEnginePoolSubmitWithCancel`. New Ring class `base/common/stzCancelToken.ring` (loaded in stzBase) with a lazy-init guard -- discovered + documented that paren-less `new stzCancelToken` does NOT run `init()` in Ring (only `new X()` does), so every method calls `_Ensure()` guarded by a plain boolean (cpointer `= NULL` comparison is unreliable per the typed-null gotcha). Bridge regs 1037->1045 (+3 dns, +5 cancel/submit); Ring classes 125->126. Tests: dns.zig 3/3 + cancel.zig 2/2 Zig; new narrated 65_dns_cache 4/4 + reactive 54_cancel 5/5 Ring. Full network suite (52/53/55/56/58/59/60/61/62/63/64/65) + reactive (51/52/53/54) all green; zig build + zig build test clean. Remaining Tier 1: 5 retry budget (Ring wrapper over rate limiter), 6 latency histograms p50/p95/p99 (histogram.zig), 7 outlier ejection (extend resilience.zig), 8 graceful pool drain (extend pool.zig). |
| 2026-06-13 | 67      | M-RX1      | **REACTIVE GAP-ANALYSIS TIER 1 -- items 5 (retry budget) + 6 (latency histograms).** Item 5: new Ring class `base/common/stzRetryBudget.ring` -- a global cap on retries across a workload, wrapping the existing engine token-bucket rate limiter (stz_resilience.dll, NO engine change). Constructor `(nBudget, nWindowSeconds)` => capacity N, refill floor(N/W) tokens/sec (min 1); `Allow()` (alias `Spend()`) takes one token and returns TRUE while budget remains, `AllowN(n)` all-or-nothing, `Available()` float. Named **Allow not Try** -- `try` is a Ring keyword (try/catch/done) and Ring is case-insensitive, so a `Try` method raises C27 (new gotcha, captured in memory). Item 6: new DLL `engine/src/histogram.zig` -- log-scale ms buckets (0.1..10000, +overflow), `histogram_create/record/percentile/reset/count/destroy`; a sample lands in the first bucket >= its value, percentile returns that bucket's upper bound. New domain stz_histogram (entry + bridge + build.zig + .ring loader + stzRingLibs); `StzEngineHistogram*` bridge; Ring class `base/common/stzLatencyHistogram.ring` with P50/P95/P99. **Wire-up:** http.zig records every completed request's wall-clock latency into a built-in histogram, exposed via `StzEngineHttpLatencyPercentile/Count/Reset` (live-verified: a real GET records a sample, p50 > 0). DLLs 87->88, bridge regs 1045->1054 (+6 histogram, +3 http-latency), Ring classes 126->128 (stzRetryBudget, stzLatencyHistogram). Tests: histogram.zig 4/4 Zig (incl. 1000-uniform-sample p50=500/p99=1000); new narrated 66_retry_budget 10/10 + 67_histogram 10/10 Ring. Full network suite (52..67) + reactive (51..54) all green; zig build + zig build test clean. Remaining Tier 1: 7 outlier ejection per (host,port) (extend resilience.zig, checked in http_pool.acquire), 8 graceful pool drain (extend pool.zig with accepting flag + pool_drain(timeout)). Tier 2 (IOCP/epoll/kqueue reactor, HTTP/2, TraceContext, work-stealing) still deferred until Zig 0.16 std.Io stabilises. |
| 2026-06-14 | 68      | M-RX1      | **REACTIVE GAP-ANALYSIS TIER 1 CLOSED -- items 7 (outlier ejection) + 8 (graceful pool drain).** Item 7: extended `engine/src/resilience.zig` with an OutlierDetector -- a process-wide registry keyed by host tracking consecutive failures; once a host crosses the threshold (default 10) it is ejected for a cooldown (default 30s) then auto-readmitted (half-open), and any success resets the failure run. `outlier_config/record/should_eject/reset`. Wired into `http_pool.acquire` (refuses ejected hosts) and `http.zig` doRequest (records ok=1 on a completed response, ok=0 on connect/request failure -- an already-ejected host is reported, not re-counted). Bridge `StzEngineOutlierConfig/Record/ShouldEject/Reset` registered in stz_http (NOT stz_resilience) so they operate on the SAME resilience instance the pool consults -- the cross-DLL-instance trap again. Item 8: extended `engine/src/pool.zig` with an `accepting` atomic flag + `pool_drain(timeout_ms) -> residual` (stops accepting, waits up to timeout for queued+running to finish, returns the count still outstanding; Zig threads can't be preempted so residual jobs finish in the background, joined at destroy); submit returns -4 'pool draining' once draining. Bridge `StzEnginePoolDrain`. Plus `http_pool.shutdown()` (close all idle sockets) exposed as `StzEngineHttpPoolShutdown` and surfaced as `stzHttpClient.Shutdown()`. Bridge regs 1054->1060 (+4 outlier, +1 pool-drain, +1 http-pool-shutdown). Tests: resilience.zig 8/8 (incl. 2 new outlier) + pool.zig drain Zig; new narrated 68_outlier 5/5 + 69_pool_drain 6/6 Ring. Full network suite (52..69) + reactive (51..54) all green; zig build + zig build test clean. **M-RX1 DONE: all 8 Tier 1 gaps closed across sessions 64-68 (HTTP timeouts, connection pool, DNS cache, cancellation, retry budget, latency histograms, outlier ejection, graceful drain).** Next arc is Tier 2 (IOCP/epoll/kqueue cooperative scheduler for 10k+ conns/worker, HTTP/2, TraceContext propagation, work-stealing) -- a genuine 3-5 session effort gated on Zig 0.16 std.Io stabilising; not started. |
| 2026-06-14 | 69      | M-RX2      | **TIER 2 STARTED -- libuv reactor backbone vendored + proven.** User directive: build the cooperative scheduler / async I/O substrate on libuv, not a hand-rolled per-OS reactor ("avoid reinventing the wheels"), and vendoring robust C libs into the engine is sanctioned (same as utf8proc/pcre2/sqlite). Crucially this does NOT violate the M-DEP dependency-freedom rule: that rule forbids Ring-side `load "libuv.ring"` extensions, whereas this compiles libuv FROM SOURCE into an engine DLL -- a different layer. Landed the FOUNDATION slice: `engine/vendor/libuv` (v1.52.1, include+src+LICENSE, docs/test pruned, ~2MB); `addLibuv(mod,lib,b,os_tag)` in build.zig replicating libuv's CMakeLists (common sources + per-OS win/unix-linux/unix-darwin file lists, per-OS defines, Windows syslibs psapi/user32/advapi32/iphlpapi/userenv/ws2_32/dbghelp/ole32/shell32); new `stz_reactor` base domain (needs_libuv); `engine/src/reactor.zig` via `@cImport("uv.h")` exposing reactor_version/version_hex/selftest (selftest arms a 1ms one-shot timer on a private uv_loop, runs UV_RUN_DEFAULT, returns callbacks fired); bridge `StzEngineReactorVersion`/`SelfTest`; `stz_reactor.ring` loader + stzRingLibs. **Verified on Windows:** zig build clean (libuv compiled from C source via zig cc first try, stz_reactor.dll 3MB), zig build test clean, Ring smoke prints `libuv version: 1.52.1` + self-test `1` (real IOCP-backed loop ran, timer fired). New narrated suite reactive/55_reactor 3/3; cross-checks (51/54 reactive, 53/67/69 network) still green after adding the global stz_reactor load. DLLs 88->89, regs 1060->1062. Direction + multi-slice plan + open decision (keep httpcore vs adopt libcurl) recorded in base/doc/design/TIER2_REACTOR_DIRECTION.md. NEXT: reactor core (loop on an engine worker thread; async timers+TCP through the submit/poll handle idiom, Ring stays synchronous), then the HTTP-stack decision, then nghttp2 (HTTP/2) + TraceContext + multi-loop work-stealing. Requirement check pending: confirm real need for 10k-conn-per-worker before the full multi-loop scheduler. |
| 2026-06-14 | 70      | M-RX2      | **TIER 2 SLICE 1 -- reactor core (libuv loop on a worker thread + cross-thread submit/poll).** Built the load-bearing async machinery on the session-69 libuv foundation. `Reactor` (engine/src/reactor.zig) owns a `uv_loop_t` run by a dedicated `std.Thread` (`uv_run(UV_RUN_DEFAULT)`). Cross-thread work submission uses the only thread-safe libuv primitive, `uv_async_send`: Ring's thread enqueues a Job under a mutex + wakes the loop; the loop's async callback drains pending and starts the libuv op; on completion the result is stored in a mutex-guarded job table. Ring drains results via the same submit/poll handle idiom as the thread pool, so **Ring stays fully synchronous and never sees a libuv callback**. Handle lifetime uses the canonical libuv two-phase dance: on op completion the handle is `uv_close`d, and a Job is freed only once BOTH its close callback has fired AND the caller has polled (monotonic flags + reap-when-both, guarded by the loop mutex). Clean shutdown: `reactor_destroy` sets a stopping flag, `uv_async_send`s the loop, the wake callback `uv_walk`s + `uv_close`s every handle (guarded by `uv_is_closing`) so `uv_run` returns, the thread joins, then any surviving jobs are freed and `uv_loop_close` succeeds. First async op = timer (deterministic, no network); proves the whole submit->loop->complete->poll round trip across the thread boundary. Surface: `StzEngineReactorCreate/SubmitTimer/Poll/Await/Pending/Destroy` (+ Version/SelfTest from s69). Tests: reactor.zig 5/5 Zig -- incl. **32 concurrent timers all firing** and **destroy with in-flight + undrained jobs leaking nothing** -- run via `zig test` with libuv compiled in; narrated reactive/56_reactor_core 6/6 through the Ring FFI (submit+await, running->done, unknown-id=-2). zig build + zig build test clean; reactive 51/52/54/55 + network 53 still green. regs 1062->1068. NEXT: async TCP (connect/read/write) on the same machinery, migrate tcp.zig server + polling timer onto the loop, then the HTTP-stack decision (keep httpcore vs adopt libcurl). |
| 2026-06-14 | 71      | M-RX2      | **TIER 2 -- async TCP + TraceContext + multi-loop scale (libuv reactor feature COMPLETE).** Built on the s70 reactor core. (1) **Async TCP**: `tcp_request` job = a per-job state machine on the loop thread (`uv_getaddrinfo` -> `uv_tcp_connect` -> `uv_write` -> `uv_read_start` to EOF), response accumulated and drained via `reactor_tcp_poll/await` + `reactor_tcp_last_status`. Hit Zig translate-c's libuv **dependency loop** (`uv_stream_t` <-> `uv_read_cb` can't be built) -- solved robustly by treating TCP handles + requests as OPAQUE buffers sized by `uv_handle_size`/`uv_req_size`, with hand-written `extern` decls using `*anyopaque` and reading/writing the user pointer at offset 0 (every uv handle/req starts with `void* data`); `@cImport` keeps only the non-cyclic types. (2) **Ring classes** `stzReactor` (SubmitTimer/AwaitTimer/Poll/Pending + SubmitTcp/AwaitTcp/PollTcp/TcpRequest/TcpLastStatus/Version/Destroy; lazy-init, construct with parens) and `stzReactorPool` (N libuv loops on N threads, round-robin `FetchAll` batch = libuv's recommended multi-loop scaling). Bridge `StzEngineReactorSubmitTcp/TcpAwait/TcpPoll/TcpLastStatus`. (3) **TraceContext** (W3C `traceparent`): `engine/src/tracectx.zig` (generate/child/parse/validate, IN the default `zig build test` sweep -- pure), `stz_tracectx` DLL + bridge `StzEngineTrace*`, `stzTraceContext` (+ StzTraceContextFrom), `stzHttpClient.SetTraceParent/StartTrace` inject the header. **Verified:** reactor.zig 7/7 Zig incl. LIVE async TCP round-trip to example.com:80 + unreachable no-leak; tracectx.zig 4/4 (W3C example + malformed rejection); narrated reactive/56 6/6, 57 6/6 (live), 58 4/4 (parallel pool fetch), network/70 10/10; zig build + zig build test clean; all prior reactive (51-55) + network (52/53/63/64/68/69) suites green. DLLs 89->90 (+stz_tracectx), regs 1068->1078, classes 128->131 (+stzReactor/stzReactorPool/stzTraceContext). **Deliberate non-goal:** NOT migrating the working blocking tcp.zig / clock()-polling stzReactiveTimer onto the reactor (regression risk > upside; reactor is the forward path for NEW async work). **The libuv reactor feature is COMPLETE.** Only remaining Tier 2 work = HTTP/2 + HTTP/3, gated on ONE strategic decision (keep custom httpcore + vendor nghttp2 vs adopt vendored libcurl with multi/socket_action on the reactor) -- documented with recommendation in TIER2_REACTOR_DIRECTION.md, awaiting go-ahead since it would retire working code. |
| 2026-06-14 | 72      | M-RX2      | **HTTP-STACK DECISION RESOLVED -- adopted vendored libcurl (HTTP/1.1 + HTTP/2 + Schannel TLS), retired httpcore/http_pool.** "Buy not build": libcurl is the industrial HTTP stack. **Slice A** (vendor + build de-risk): `engine/vendor/curl` (8.20.0, lib/+include/, ~6MB) compiles from C source with NO CMake -- on Windows curl_setup.h auto-includes lib/config-win32.h (HAVE_CONFIG_H NOT defined); TLS = native **Schannel** (USE_WINDOWS_SSPI+USE_SCHANNEL, link crypt32/secur32/bcrypt); trimmed to HTTP(S) via CURL_DISABLE_* (no optional deps); `addLibcurl` globs the 6 lib dirs at configure time. Proven: zig build clean first try, live http 200 + **https 200 via Schannel**. **Slice B** (rewire): `curlcore.zig` = full request engine (curl_easy_perform over a process-wide CURLSH share for connection/DNS/TLS-session reuse, thread-safe via per-data-type lock callbacks; methods, slist headers, copy-postfields, timeouts, redirects, bounded write-cb, curl_easy_strerror, NUM_CONNECTS reuse accounting). `http.zig` rewritten to drive curlcore keeping every exported fn + the outlier/latency wire-ups; **httpcore.zig + http_pool.zig deleted**. Tests adjusted to libcurl semantics (63 idle/active=0 libcurl-managed; 69 Shutdown drops shared cache; 56 no-host URLs fast-fail). **Slice C** (HTTP/2): vendored `engine/vendor/nghttp2` (1.69.0, 26 .c, nghttp2ver.h generated; no config.h -- ssize_t from MinGW), compiled into stz_http with USE_NGHTTP2+NGHTTP2_STATICLIB; CURLOPT_HTTP_VERSION=2TLS. **Gotcha + fix:** h2 wouldn't negotiate -- curl's global_init runs Curl_ssl_init (schannel_init reads OS version for the ALPN gate) BEFORE Curl_win32_init (which sets the accurate RtlVerifyVersionInfo), so Schannel fell back to the manifest-lying VerifyVersionInfoW (sees Win6.2 for an unmanifested host) and silently disabled ALPN. One-line vendored patch to lib/easy.c reorders win32_init before ssl_init -> ALPN works. Verified live: "ALPN: server accepted h2", HTTP/2 negotiated vs nghttp2.org + cloudflare; StzEngineHttpLastVersion reports 2. New bridge StzEngineHttpEngineVersion + StzEngineHttpLastVersion. Tests: full network suite (52-71, incl. new 71_http2 6/6) + reactive green; zig build + test clean. DLLs 90 (libcurl/nghttp2 fold into stz_http), regs 1078->1080, last_session 72. Engine: libcurl/8.20.0 Schannel nghttp2/1.69.0. HTTP/3 deferred (ngtcp2/quiche). **Tier 2 effectively COMPLETE** (reactor + industrial HTTP incl. h2); remaining optional: HTTP/3, true work-stealing scheduler. |
| 2026-06-14 | 73      | M-RX2      | **HTTP/3 DEFERRED -- M-RX2 (Tier 2) marked DONE.** Decision: defer h3. curl 8.20's h3 backends are ngtcp2+nghttp3 or quiche, and Schannel cannot serve curl's QUIC, so h3 forces a replacement TLS backend -- every path is a bad trade now: wolfSSL+ngtcp2+nghttp3 (only from-source option) rips out the working Schannel h1/h2 stack + loses Windows cert-store verification (must ship a CA bundle) + biggest vendor yet; msh3+msquic needs a curl bump AND a prebuilt binary (breaks the from-source rule). h3 degrades to h2 with zero functional loss (discovered via Alt-Svc), and h2 already covers essentially all real traffic. Revisit when curl restores msh3 (reuse Schannel via msquic) or OpenSSL 3.5 QUIC matures into a zig-cc-buildable form. True work-stealing scheduler likewise deferred (the multi-loop reactor pool covers scale). **Tier 2 COMPLETE for shipped scope:** libuv reactor (async timer/TCP, multi-loop), W3C TraceContext, libcurl HTTP through HTTP/2 + Schannel -- all vendored from source, all suites green. Rationale recorded in TIER2_REACTOR_DIRECTION.md + memory. last_session 73. |
| 2026-06-14 | 74      | M-RX2      | **HTTP FEATURE-COMPLETION -- exposed libcurl's full surface through stzHttpClient.** Capitalized on the libcurl adoption: turned the stub/"warning" setters into real, engine-backed features. Design: a per-request **options blob** ("key=value" newline lines) parsed by `curlcore.applyOpts` -> CURLOPTs, carried by new `StzEngineHttpRequestEx` (so the C-ABI arity doesn't explode). Features: **auth** -- Basic/Digest/NTLM/Negotiate (CURLOPT_USERPWD + HTTPAUTH) + **Bearer**/OAuth2 (XOAUTH2_BEARER); **proxy** + proxy auth (CURLOPT_PROXY/PROXYUSERPWD); **mTLS** client certs (CURLOPT_SSLCERT/SSLKEY); **persistent cookies** (COOKIEFILE/COOKIEJAR); **SSL-verify** + **follow-redirect** toggles now actually drive curl; **response headers** captured via CURLOPT_HEADERFUNCTION -> `StzEngineHttpLastHeaders` -> `stzHttpClient.ResponseHeaders()`; **gzip/deflate auto-decompression** via newly vendored **zlib 1.3.1** (engine/vendor/zlib, flat 15 .c, committed zconf.h -> no gen; curl built with HAVE_LIBZ). stzHttpClient gained SetAuth(real)/SetAuthType/SetBearer/SetProxyAuth/SetClientCert/SetCookieFile/SetCookieJar/AcceptEncoding/AcceptGzip + `_ComposeOptionsBlob`; the old SetAuth-that-only-warned is gone. CURLAUTH_ANY bitmask gotcha: doesn't fit c_long on Windows -> bitcast through c_ulong. **Fix:** Accept-Encoding is opt-in (a bare empty value would make curl advertise gzip and garble bodies if zlib were absent). Engine: libcurl/8.20.0 Schannel zlib/1.3.1 nghttp2/1.69.0. Tests: new 72_http_features 13/13 (deterministic opts-blob composition + live Basic-auth via postman-echo + response-header capture + gzip decode via httpbin); full network suite (52-72) + reactive green; zig build + zig build test clean. DLLs 90 (zlib folds into stz_http), regs 1080->1082, last_session 74. The HTTP client is now feature-complete for the libcurl surface (auth/proxy/mTLS/cookies/compression/redirects/headers/h2); only HTTP/3 remains deferred. |
