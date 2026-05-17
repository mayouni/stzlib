# String Engine v2 -- Design Document & Implementation Plan

> **Status:** Design approved, implementation pending.
> **Date:** 2026-05-17
> **Scope:** Engine-level string module (`engine/src/string.zig`)
> **Integrates with:** SOFTANZA_ENGINE_MACROPLAN.md (inserts
> between Phase 5 and M-E1)

---

## 1. Value Proposition

The Softanza Engine string module is the lowest layer where text
meets computation. It must be:

1. **Unicode-correct by default.** Every operation works on
   codepoints, not bytes. Case folding uses utf8proc, not ASCII
   tricks. Grapheme awareness where it matters.

2. **Softanza-native in naming and semantics.** The Engine
   adopts Softanza's mental model: 1-based indexing, CS pattern
   for case sensitivity, verb/noun naming discipline, and the
   suffix DSL where it earns its weight at the C ABI level.

3. **Zig-idiomatic in implementation.** Comptime lookup tables,
   error unions instead of silent catch, SIMD where measurable,
   allocator-parameterized internals.

4. **Industrial-strength for modern domains.** Not just CRUD
   string ops -- regex, locale-aware collation, NLP tokenization,
   cryptographic hashing, ML-ready embeddings.

---

## 2. Naming Convention

### 2.1 Prefix: `str_` (not `stz_string_`)

Current: `stz_string_word_count(handle)`
New:     `str_word_count(handle)`

The `stz_` prefix was useful when the engine had multiple modules
sharing a namespace. At the C ABI boundary, `str_` is shorter,
unambiguous, and directly maps to the domain.

No migration aliases needed -- there is no external user base yet.

### 2.2 Verb/Noun Discipline

| Pattern | When | Examples |
|---------|------|----------|
| `str_<noun>` | Returns a value, no mutation | `str_word_count`, `str_size`, `str_hash` |
| `str_<verb>` | Mutates the handle in place | `str_append`, `str_insert`, `str_replace` |
| `str_to_<target>` | Returns a transformed copy | `str_to_upper`, `str_to_snake_case`, `str_to_hex` |
| `str_from_<source>` | Creates a handle from external format | `str_from_hex`, `str_from_codepoints`, `str_from_utf16` |
| `str_is_<property>` | Boolean predicate | `str_is_empty`, `str_is_numeric`, `str_is_palindrome` |
| `str_has_<thing>` | Boolean containment | `str_has_prefix`, `str_has_suffix`, `str_has_char` |

### 2.3 Case Sensitivity: CS Pattern

Current (two separate functions):
```zig
pub fn stz_string_find_all(handle, needle, len) ...
pub fn stz_string_find_all_ci(handle, needle, len) ...
```

New (single function, case parameter):
```zig
pub fn str_find_all(handle, needle, len, case: c_int) ...
// case = 1: case-sensitive (default)
// case = 0: case-insensitive (Unicode case fold)
```

A convenience wrapper with no `case` parameter defaults to
case-sensitive:
```zig
// In the bridge layer, str_find_all() calls str_find_all_cs(h, n, l, 1)
```

This halves the exported function count for all operations that
have CS/CI variants: find, replace, contains, starts_with,
ends_with, split, count_of, equals.

**Implementation:** The `case = 0` path uses
`stz_unicode_casefold` (utf8proc, already linked) instead of
the broken `toLowerAscii` helper.

### 2.4 DSL Suffix Applicability at Engine Level

The Softanza suffix DSL (Z/ZZ/CS/XT/Q/IB/W) is a Ring-side
concern -- it generates 15,000+ method variants through
composition. At the Engine level, the C ABI must stay flat.
However, three suffixes map naturally:

| Suffix | Engine mapping | Rationale |
|--------|---------------|-----------|
| CS | `_cs` parameter (see 2.3) | Halves function count |
| XT | Additional parameters on the base function | Already done: `str_find_all` vs `str_find_nth` |
| Z/ZZ | Return format variants via output parameter | `str_find_all` returns positions; a `str_find_all_with_sections` variant returns [start, end] pairs |

The remaining suffixes (Q, IB, W) are Ring-side composition
only -- they depend on Ring object semantics (fluent chaining,
bound inclusion, conditional predicates) that have no meaning
at the C ABI level.

---

## 3. Indexing: 1-Based by Default

### 3.1 Design

All Engine functions that accept or return codepoint positions
use **1-based indexing** by default.

```zig
// Position 1 = first codepoint
str_char_at(handle, 1)     // returns first codepoint
str_find(handle, "x", 1, 1) // find "x" starting at position 1
```

A compile-time config flag controls this:
```zig
pub const INDEX_BASE: c_int = 1; // default: 1-based
// Set to 0 for 0-based indexing (C/Python convention)
```

The flag affects:
- All `cp_index` parameters
- All returned position values (find results, char positions)
- Slice/substring boundaries
- Line numbers, word positions

### 3.2 Internal Invariant

Internally, arrays remain 0-based (Zig's natural model). The
conversion happens at the public API boundary only:
```zig
fn toInternal(pos: c_int) usize {
    return @intCast(pos - INDEX_BASE);
}
fn toExternal(pos: usize) c_int {
    return @intCast(@as(i64, @intCast(pos)) + INDEX_BASE);
}
```

### 3.3 Bridge Alignment

Ring is 1-based natively. With `INDEX_BASE = 1`, the Ring bridge
passes positions directly -- no `n - 1` / `n + 1` conversions.
This eliminates an entire class of off-by-one bugs.

---

## 4. Critical Fixes (Tier 1 -- Correctness)

These are bugs that produce wrong results or leak memory. They
block any further feature work.

### 4.1 Unicode-Correct Case Insensitivity

**Bug:** 9 call sites use `toLowerAscii()` (line 407) for CI
operations. This breaks for any non-ASCII text.

**Fix:** Replace all CI paths with `stz_unicode_casefold`:
```zig
fn casefold(input: []const u8, alloc: Allocator) ?[]u8 {
    var out_len: usize = 0;
    const ptr = unicode.stz_unicode_casefold(
        input.ptr, input.len, &out_len
    );
    if (ptr == null) return null;
    defer alloc.free(ptr[0..out_len]);
    const result = alloc.alloc(u8, out_len) catch return null;
    @memcpy(result, ptr[0..out_len]);
    return result;
}
```

**Affected functions:** `index_of_ci`, `find_all_ci`,
`last_index_of_ci`, `count_of_ci`, `starts_with_ci`,
`ends_with_ci`, `contains_ci`, `split_count_ci`, `split_get_ci`,
`replace_ci`, `equals_ci`, `find_nth_ci`, `remove_all_ci`.

### 4.2 Memory Leak in equals_ci

**Bug:** Line 1078 uses `gpa.resize` which does not free the
original allocation on failure. The function creates temporary
lowered copies but never frees them on the success path.

**Fix:** Use explicit alloc/free with defer:
```zig
const a_fold = casefold(a_slice, gpa) orelse return 0;
defer gpa.free(a_fold);
const b_fold = casefold(b_slice, gpa) orelse return 0;
defer gpa.free(b_fold);
return if (mem.eql(u8, a_fold, b_fold)) 1 else 0;
```

### 4.3 Fix stz_string_foldcase

**Bug:** `stz_string_foldcase` (line 796) just calls
`stz_string_to_lower`. Real case folding is different:
German sharp-s (ess-zett) folds to "ss", Turkish dotted-I has
locale-dependent folding.

**Fix:** Use `stz_unicode_casefold` directly.

### 4.4 Unicode-Aware Trim

**Bug:** `stz_string_trim` / `trim_left` / `trim_right` only
strip ASCII whitespace (space, tab, newline). Unicode has 25+
whitespace characters (U+00A0 no-break space, U+2003 em space,
U+3000 ideographic space, etc.).

**Fix:** Use `stz_unicode_is_space` (already in unicode.zig,
line 120) for whitespace detection:
```zig
fn isUnicodeWhitespace(cp: u21) bool {
    return unicode.stz_unicode_is_space(cp) != 0;
}
```

---

## 5. Structural Fixes (Tier 2 -- Safety)

### 5.1 Replace All `catch {}` with Error Unions

**Current:** ~206 occurrences of `catch {}` silently swallow
allocation failures. An OOM condition produces wrong results
with no diagnostic.

**Fix:** Propagate errors through return values.
For C ABI functions (which cannot use Zig error unions), return
null on allocation failure consistently:
```zig
// Before:
r.data.appendSlice(gpa, src) catch {};

// After:
r.data.appendSlice(gpa, src) catch {
    r.deinit();
    gpa.destroy(r);
    return null;
};
```

For internal helpers, use `!void` or `!StzStringHandle`.

**Scope:** This is a systematic pass through all 234 exported
functions. Estimated: 206 catch sites to audit, ~150 need
conversion.

### 5.2 UTF-8 Validation

**Current:** `stz_string_from` accepts any byte sequence without
validation. Malformed UTF-8 causes undefined behavior in
codepoint iteration.

**Fix:** Add validation on input:
```zig
pub fn str_from(utf8: [*c]const u8, len: usize) callconv(.c) StzStringHandle {
    if (utf8 == null or len == 0) return str_new();
    const src = utf8[0..len];
    if (!std.unicode.utf8ValidateSlice(src)) return null;
    // ... proceed with valid UTF-8
}
```

Provide a separate `str_from_bytes` for raw byte sequences
that need explicit encoding handling.

### 5.3 Null Termination Safety

**Current:** `stz_string_data` returns a pointer into the
ArrayList buffer, which is NOT null-terminated. C callers that
treat this as a C string will read past the buffer.

**Fix:** Ensure null termination:
```zig
pub fn str_data(handle: StzStringHandle) callconv(.c) [*c]const u8 {
    if (handle) |s| {
        if (s.data.items.len == 0) return "";
        // Ensure null terminator exists
        s.data.ensureUnusedCapacity(gpa, 1) catch return "";
        s.data.items.ptr[s.data.items.len] = 0;
        return s.data.items.ptr;
    }
    return "";
}
```

---

## 6. Performance Architecture (Tier 3)

### 6.1 Codepoint Offset Cache

**Problem:** Every codepoint-indexed operation calls
`stz_unicode_cp_to_byte` which is O(n) -- walking from the
start of the string each time. Two successive `char_at(5)` and
`char_at(6)` calls scan the string twice.

**Solution:** Cache the last (codepoint, byte_offset) pair in
the StzString struct:
```zig
const StzString = struct {
    data: std.ArrayList(u8),
    // Codepoint offset cache
    cached_cp: usize = 0,
    cached_byte: usize = 0,

    fn cpToByte(self: *StzString, cp_index: usize) ?usize {
        if (cp_index == self.cached_cp) return self.cached_byte;
        // Walk forward from cache if target is ahead
        if (cp_index > self.cached_cp) {
            // Walk from cached position
        }
        // Otherwise walk from start
        // Update cache on success
    }
};
```

This turns sequential codepoint access from O(n^2) to O(n).

### 6.2 SIMD Where Measurable

Ye-specific SIMD opportunities in string processing:

1. **ASCII fast path for find:** When both haystack and needle
   are pure ASCII, use `@Vector(16, u8)` for 16-byte-at-a-time
   comparison. Fall back to scalar for non-ASCII.

2. **Whitespace detection:** Load 16 bytes, compare against
   space/tab/newline/CR simultaneously.

3. **Character classification:** Is-alpha, is-digit, is-upper
   on ASCII ranges can process 16 bytes per cycle.

**Discipline:** SIMD only where benchmarks show measurable
improvement on strings > 1KB. No premature vectorization.

### 6.3 Boyer-Moore for Large-String Search

**Current:** `index_of` uses `std.mem.indexOf` which is a naive
O(n*m) scan.

**Future:** Implement Boyer-Moore-Horspool for needles > 4
bytes. The bad-character table fits in a comptime-generated
256-byte array for ASCII, with a hash-based fallback for
Unicode.

### 6.4 Rope Data Structure (Future)

For strings > 1MB (log files, document processing), the
ArrayList-based representation degrades on insert/delete
operations. A rope (balanced binary tree of string chunks)
gives O(log n) insert/delete.

**Deferred** until M-E6 or a concrete use case demands it.

---

## 7. Module Separation

The current `string.zig` is 11,800+ lines in a single file.
Split into focused submodules:

```
engine/src/
  string.zig            # Public API (re-exports all submodules)
  string/
    core.zig            # StzString struct, lifecycle, data access
    find.zig            # All find/search operations
    replace.zig         # All replace/remove operations
    transform.zig       # Case, encoding, format conversions
    split.zig           # Split, partition, join operations
    inspect.zig         # Is_*, has_*, count_*, compare
    format.zig          # Pad, trim, align, indent, case conversion
    extract.zig         # Between, substring, slice, chars
    encode.zig          # Hex, URL, base64, hash
    text.zig            # Word operations, line operations, NLP
    regex.zig           # Pattern matching (see section 9)
```

Each submodule imports `core.zig` for the StzString type.
The top-level `string.zig` re-exports everything, so external
callers see a flat namespace.

---

## 8. Locale and Multilingual Support

### 8.1 Architecture

The Engine provides locale-aware operations through a
locale context:

```zig
pub const StzLocale = struct {
    language: [3]u8,     // ISO 639-1/2 (e.g., "fr", "ha")
    country: [3]u8,      // ISO 3166-1 (e.g., "NE", "FR")
    script: [5]u8,       // ISO 15924 (e.g., "Latn", "Arab")
    collation_tailoring: ?*const CollationTable,
};

pub fn str_set_locale(locale: *const StzLocale) callconv(.c) void;
pub fn str_compare_locale(h1, h2, locale) callconv(.c) c_int;
pub fn str_sort_locale(handle, locale) callconv(.c) StzStringHandle;
pub fn str_to_lower_locale(handle, locale) callconv(.c) StzStringHandle;
pub fn str_to_upper_locale(handle, locale) callconv(.c) StzStringHandle;
```

### 8.2 Multilingual Priorities

Given the project's multilingual context (French, Hausa,
Arabic, English), these are first-class concerns:

1. **Bidirectional text:** RTL detection, logical vs visual
   ordering. Hausa in Ajami (Arabic script) and Latin script.
2. **Collation:** French accent ordering (e < e-acute < f),
   locale-specific sort.
3. **Normalization:** NFC/NFD/NFKC/NFKD (already partially
   implemented via utf8proc).
4. **Script detection:** Per-codepoint script identification
   for mixed-script text (Latin + Arabic in same string).
5. **Number formatting:** Locale-aware decimal/thousands
   separators.

### 8.3 Mapping to Softanza i18n Classes

| Engine function | Ring class | Purpose |
|----------------|-----------|---------|
| `str_compare_locale` | stzLocale.Compare() | Locale-aware comparison |
| `str_script_of` | stzScript.ScriptOf() | Unicode script per codepoint |
| `str_is_rtl` | stzString.IsRightToLeft() | Bidirectional detection |
| `str_transliterate` | stzTransliterator | Script-to-script conversion |

---

## 9. Regex as Strategic Capability

### 9.1 Current State

stzRegex (Ring-side) has 216 methods backed by a Zig engine.
The Engine must provide the regex substrate that stzRegex,
stzListex, and stzGraphex all consume.

### 9.2 Engine Regex API

```zig
pub fn str_regex_match(handle, pattern, pat_len, flags) StzMatchHandle;
pub fn str_regex_find_all(handle, pattern, pat_len, flags) StzMatchListHandle;
pub fn str_regex_replace(handle, pattern, pat_len, replacement, rep_len, flags) StzStringHandle;
pub fn str_regex_split(handle, pattern, pat_len, flags) StzStringArrayHandle;
pub fn str_regex_is_match(handle, pattern, pat_len, flags) c_int;

// Match result accessors
pub fn str_match_group(match_handle, group_index) StzStringHandle;
pub fn str_match_start(match_handle) c_int;  // 1-based position
pub fn str_match_end(match_handle) c_int;    // 1-based position
```

### 9.3 Regex Engine Choice

Options evaluated:
1. **PCRE2** -- Gold standard, but large C dependency (~300KB)
2. **RE2** -- Linear-time guarantee, C++ (unwanted dependency)
3. **Custom NFA/DFA** -- Full control, comptime optimization,
   but significant implementation effort
4. **utf8proc + custom** -- Minimal: use utf8proc for character
   classes, build NFA on top

**Recommendation:** Start with PCRE2 as the regex backend
(proven, Unicode-aware, widely understood syntax). Wrap it
behind the `str_regex_*` C ABI. If binary size becomes a
concern, evaluate a custom NFA engine in M-E6.

---

## 10. AI, NLP, and Cryptographic Support

### 10.1 NLP Primitives (Engine Level)

These belong in the Engine because they are performance-critical
and language-agnostic:

```zig
// Tokenization
pub fn str_tokenize(handle, mode: TokenMode) StzTokenListHandle;
// mode: WHITESPACE, WORD, SENTENCE, BPE, WORDPIECE

// N-grams
pub fn str_ngrams(handle, n: c_int) StzStringArrayHandle;
pub fn str_char_ngrams(handle, n: c_int) StzStringArrayHandle;

// Similarity
pub fn str_levenshtein(h1, h2) c_int;       // already exists
pub fn str_jaro_winkler(h1, h2) f64;
pub fn str_cosine_similarity(h1, h2) f64;   // character-level
pub fn str_soundex(handle) StzStringHandle;
pub fn str_metaphone(handle) StzStringHandle;

// Text statistics
pub fn str_entropy(handle) f64;
pub fn str_readability_score(handle) f64;    // Flesch-Kincaid
```

### 10.2 ML-Ready Operations

```zig
// Embedding preparation
pub fn str_to_codepoint_ids(handle) StzIntArrayHandle;
pub fn str_from_codepoint_ids(ids, count) StzStringHandle;

// BPE tokenization (for LLM token counting)
pub fn str_bpe_encode(handle, vocab: *const BpeVocab) StzIntArrayHandle;
pub fn str_bpe_decode(ids, count, vocab: *const BpeVocab) StzStringHandle;

// Vocabulary
pub fn str_vocabulary(handle) StzStringArrayHandle;  // unique words sorted
pub fn str_word_frequency(handle) StzPairArrayHandle;
```

### 10.3 Cryptographic Operations

```zig
pub fn str_hash_sha256(handle) StzStringHandle;  // hex output
pub fn str_hash_md5(handle) StzStringHandle;
pub fn str_hash_blake3(handle) StzStringHandle;
pub fn str_hmac_sha256(handle, key, key_len) StzStringHandle;

// Base64
pub fn str_to_base64(handle) StzStringHandle;
pub fn str_from_base64(handle) StzStringHandle;

// Hex encoding (already exists as encode_hex/decode_hex)
```

**Implementation:** Use Zig's `std.crypto` for hash functions
(zero external dependencies, hardware-accelerated where
available).

---

## 11. Zig-Specific Strengths to Leverage

### 11.1 Comptime Lookup Tables

Character classification tables generated at compile time:

```zig
const char_class_table = comptime blk: {
    var table: [128]CharClass = .{.other} ** 128;
    for ('A'..'Z'+1) |c| table[c] = .upper;
    for ('a'..'z'+1) |c| table[c] = .lower;
    for ('0'..'9'+1) |c| table[c] = .digit;
    table[' '] = .space;
    table['\t'] = .space;
    // ...
    break :blk table;
};
```

This gives zero-cost character classification for ASCII with
a clean fallback to utf8proc for non-ASCII.

### 11.2 Error Unions for Proper Error Handling

Replace all `catch {}` with proper error propagation:

```zig
const StringError = error{
    OutOfMemory,
    InvalidUtf8,
    IndexOutOfBounds,
    InvalidCodepoint,
};

// Internal functions use error unions
fn findInternal(self: *StzString, needle: []const u8) StringError!?usize {
    // ...
}

// C ABI functions convert errors to null/sentinel returns
pub fn str_find(handle: StzStringHandle, ...) callconv(.c) i64 {
    if (handle) |s| {
        return s.findInternal(needle) catch return -2; // -2 = error, -1 = not found
    }
    return -2;
}
```

### 11.3 Allocator Parameterization

The current global `c_allocator` works for FFI, but internal
operations can benefit from arena allocators for batch
operations:

```zig
fn replaceAllInternal(
    self: *StzString,
    old: []const u8,
    new: []const u8,
    arena: Allocator, // temporary allocations
) !void {
    // Build result in arena, then swap into self.data
}
```

### 11.4 Tagged Unions for Rich Results

Instead of returning opaque handles for everything:

```zig
pub const FindResult = union(enum) {
    found: struct { position: usize, length: usize },
    not_found: void,
    @"error": StringError,
};
```

(Exposed to C via struct with tag field.)

---

## 12. Implementation Plan

### Phase A: Naming & Indexing Foundation (Week 1)
> Milestone: M-STR-A

1. Add `INDEX_BASE` config and `toInternal`/`toExternal`
   conversion helpers.
2. Create `str_` aliases for all 234 exported functions.
3. Merge CS/CI pairs into single `_cs` functions (reduces
   ~30 function pairs to ~30 single functions).
4. Fix all 9 `toLowerAscii` call sites to use `casefold`.
5. Fix `equals_ci` memory leak.
6. Fix `stz_string_foldcase` to use real case folding.
7. Unicode-aware trim (use `stz_unicode_is_space`).
8. All 384+ Zig tests updated and passing.
9. Ring bridge updated, all 630+ Ring tests passing.

### Phase B: Safety & Robustness (Week 2)
> Milestone: M-STR-B

1. Audit and fix all ~206 `catch {}` sites.
2. Add UTF-8 validation to `str_from`.
3. Add null-termination safety to `str_data`.
4. Add bounds checking with proper error returns to all
   index-accepting functions.
5. Add `str_last_error()` for C callers to query what went
   wrong.
6. New tests for error paths (invalid UTF-8, OOM simulation,
   out-of-bounds).

### Phase C: Performance (Week 3)
> Milestone: M-STR-C

1. Implement codepoint offset cache in StzString struct.
2. Comptime character classification tables.
3. ASCII fast-path for find (SIMD on supported targets).
4. Boyer-Moore-Horspool for needles > 4 bytes.
5. Benchmark suite: measure before/after for find, replace,
   split, case conversion on 1KB / 100KB / 1MB strings.

### Phase D: Module Separation (Week 4)
> Milestone: M-STR-D

1. Split `string.zig` into submodules (core, find, replace,
   transform, split, inspect, format, extract, encode, text).
2. Top-level `string.zig` re-exports everything.
3. All tests organized per submodule.
4. Ring bridge unchanged (flat namespace preserved).

### Phase E: Regex Integration (Week 5-6)
> Milestone: M-STR-E

1. Link PCRE2 (or evaluate custom NFA).
2. Implement `str_regex_*` API (match, find_all, replace,
   split, is_match).
3. Match result accessors (group, start, end).
4. Unicode-aware character classes.
5. Ring bridge for regex operations.
6. Tests: basic patterns, Unicode patterns, edge cases.

### Phase F: Locale & Multilingual (Week 6-7)
> Milestone: M-STR-F

1. StzLocale struct and thread-local locale context.
2. Locale-aware comparison and sorting (ICU collation
   algorithm subset or utf8proc-based).
3. Script detection per codepoint.
4. Bidirectional text detection.
5. Ring bridge connecting to stzLocale/stzScript/stzCountry.

### Phase G: NLP & AI Primitives (Week 8-9)
> Milestone: M-STR-G

1. Tokenization engine (whitespace, word, sentence modes).
2. N-gram generation (character and word level).
3. Similarity metrics (Jaro-Winkler, cosine, Soundex,
   Metaphone).
4. Text statistics (entropy, readability).
5. Codepoint ID conversion for ML pipelines.
6. BPE tokenizer (load vocabulary, encode/decode).

### Phase H: Crypto & Encoding (Week 9-10)
> Milestone: M-STR-H

1. SHA-256, MD5, BLAKE3 via `std.crypto`.
2. HMAC-SHA256.
3. Base64 encode/decode.
4. Ring bridge for all crypto operations.

---

## 13. Integration with Macro Plan

This design inserts as **M-E0.5** in the SOFTANZA_ENGINE_MACROPLAN,
between Phase 5 (completed) and M-E1 (Foundation Types).

```
Phase 5 (88 modules designed) -- DONE
  |
  v
M-E0.5: String Engine v2 (this document)
  Phase A: Naming & Indexing     [blocks nothing]
  Phase B: Safety & Robustness   [blocks nothing]
  Phase C: Performance           [blocks nothing]
  Phase D: Module Separation     [blocks nothing]
  Phase E: Regex Integration     [informs M-E6]
  Phase F: Locale & Multilingual [informs M-E5]
  Phase G: NLP & AI Primitives   [informs M-E6]
  Phase H: Crypto & Encoding     [informs M-E5]
  |
  v
M-E1: Foundation Types (StzValue + Number)
```

Phases A-D can proceed immediately and in parallel with ongoing
stzString refactoring (the Ring bridge adapts incrementally).
Phases E-H are additive and can interleave with M-E1/M-E2 work.

---

## 14. Function Count Projection

| Category | Current | After v2 |
|----------|--------:|--------:|
| Core (lifecycle, data) | 8 | 8 |
| Find/Search | 24 | 14 (CS merge) |
| Replace/Remove | 28 | 18 (CS merge) |
| Transform (case, encoding) | 22 | 22 |
| Split/Partition | 12 | 8 (CS merge) |
| Inspect (is_*, has_*) | 32 | 32 |
| Format (pad, trim, align) | 20 | 20 |
| Extract (between, slice) | 16 | 16 |
| Text (word, line) | 14 | 14 |
| Encode (hex, URL, base64) | 8 | 12 |
| **Regex (new)** | 0 | **10** |
| **Locale (new)** | 0 | **8** |
| **NLP (new)** | 0 | **14** |
| **Crypto (new)** | 0 | **8** |
| **Total** | **234** | **~204 + 40 new = ~244** |

The CS merge reduces ~30 pairs to ~30 single functions,
while new domains add ~40 functions. Net: comparable count
but broader coverage and cleaner API.

---

## 15. Ring Bridge Impact

### 15.1 Registration Name Change

DLL registration names follow the `str_` convention:
```
Current: "stzenginestringwordcount"
New:     "stzenginestrwordcount"
```

Backward compatibility: old registration names kept as aliases
during transition.

### 15.2 stzString Method Mapping

The 14 already-refactored methods continue working. New
refactoring targets (post Phase A):

| stzString method | Engine function (new name) |
|-----------------|---------------------------|
| FindCS() | str_find_all(h, n, l, case) |
| ContainsCS() | str_has(h, n, l, case) |
| ReplaceCS() | str_replace(h, old, ol, new, nl, case) |
| SplitCS() | str_split(h, sep, sl, case) |
| UpperCase() | str_to_upper(h) |
| LowerCase() | str_to_lower(h) |
| Reversed() | str_reverse(h) |
| Simplified() | str_simplify(h) |
| TrimmedQ() | str_trim(h) (Ring-side wraps for Q) |

---

## 16. Testing Strategy

Each phase adds tests at all 4 layers:

1. **Zig unit tests** (comptime-bounded, no stdio)
2. **Ring bridge tests** (engine_bridge_test.ring)
3. **stzString integration tests** (refactored methods)
4. **Narrated tests** (GIVEN/WHEN/THEN for key workflows)

Test count projection:
- Current: 384 Zig + 630 Ring = 1,014 total
- After Phase A: +50 Zig, +30 Ring = ~1,094
- After Phase B: +40 Zig, +20 Ring = ~1,154
- After all phases: ~1,500+ total

---

## 17. Non-Goals (Explicit Exclusions)

1. **Rope data structure** -- Deferred to M-E6 or when a
   concrete > 1MB use case appears.
2. **Full ICU integration** -- Too large. Use utf8proc + custom
   collation tables.
3. **Grapheme cluster segmentation** -- Defer to Phase F or
   later. Current grapheme_count uses utf8proc which is
   adequate.
4. **Custom regex engine** -- Start with PCRE2. Evaluate custom
   only if binary size is a blocker.
5. **Ring-side DSL suffix generation** -- Not an Engine concern.
   The Ring layer handles Z/ZZ/Q/IB/W composition.
