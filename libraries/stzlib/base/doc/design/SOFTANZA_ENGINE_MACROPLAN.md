# Softanza Engine -- Macro Plan

> **Living document.** Updated at every progress milestone.
> Cross-reference: `base/doc/internals/SESSION_CONTINUITY.md`
> for per-session details.

---

## Status Summary

| Metric            | Value                    |
|-------------------|--------------------------|
| Modules designed  | 88                       |
| Modules built     | 49                       |
| Design principles | 19                       |
| Engine tests      | 1313 passing             |
| DLLs shipping     | 53 (4 Core + 49 Base)    |
| Qt dependencies   | 0 (fully purged)         |
| Ring bridge regs  | 1029 DLL functions       |
| Ring classes bridged | 107 files, 3482 calls |
| Ring Unicode hard | Complete (all domains)   |
| PCRE2 backend     | 10.47 (industrial regex) |
| Last updated      | 2026-05-24 (Session 26)  |

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

### M-E4: Algorithms [PARTIAL]

- **stz_stats** [DONE]: Completed as part of M-E3 work (Sessions 23-24).
- **stz_text** [DONE]: Paragraph/sentence segmentation, word/char/line/syllable
  counting, Flesch Reading Ease, Flesch-Kincaid Grade Level, text truncation.
  11 C ABI functions, 11 Ring bridge functions, 15 Zig tests. DLL #27.
- **Walker/Checker/Performer**: Ring-side submodules exist (stzStringWalker,
  stzListWalker, stzStringChecker, stzListChecker, stzStringPerformer,
  stzListPerformer) and already delegate to engine via StzEngine* calls where
  applicable. No standalone engine modules needed -- the operations are backed
  by existing string/list engine functions.
- **Yielder**: Not yet implemented in either layer.

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

### M-E4: Algorithms [PARTIAL]

> `stz_stats`, `stz_text`, `stz_walker`, `stz_checker`,
> `stz_yielder`, `stz_performer`.

**stz_stats** [DONE]. Walker/Checker/Performer Ring-side modules
already delegate to engine string/list functions. Remaining:
stz_text (paragraph/sentence ops), Yielder (not started).

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

### M-E6: Signature Features [5/11 DONE]

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
