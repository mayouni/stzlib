# Softanza Engine Design

## Purpose

The Softanza Engine is a standalone Zig binary that replaces all Qt
dependencies in Softanza. Ring calls the Engine via C FFI. The result:
**Softanza depends only on Ring + the Engine binary** -- no Qt, no
external libraries.

## Former Qt Dependencies (now fully replaced by Engine)

| Qt Class         | Calls | Replaced By                    |
|------------------|------:|--------------------------------|
| QString2         |  ~300 | stz_string_* functions         |
| QChar            |   42  | stz_char_* functions           |
| QByteArray       |   47  | stz_bytes_* functions          |
| QStringList      |   28  | stz_strlist_* functions        |
| QDate/QTime      |   62  | stz_date_*, stz_time_*         |
| QDateTime        |    7  | stz_datetime_*                 |
| QFile/QFileInfo  |   31  | stz_file_* functions           |
| QDir             |   11  | stz_dir_* functions            |
| QLocale          |   27  | stz_locale_* functions         |
| QRegExp          |    1  | stz_regex_* functions          |
| QVariant         |   42  | stz_variant_* functions        |
| QUrl             |    3  | stz_url_* functions            |
| QProcess         |    2  | stz_process_* functions        |
| QJson*           |   ~5  | stz_json_* functions           |

## Engine Architecture

```
  Ring Application
       |
  load "stzlib.ring"
       |
  stzString / stzDate / stzFile ...
       |
  stzengine.ring  (Ring FFI bridge)
       |
  softanza_engine.dll / .so / .dylib  (Zig binary)
       |
  +-----------+-----------+----------+
  | strings   | datetime  | filesystem|
  | regex     | locale    | json     |
  | unicode   | bytes     | process  |
  +-----------+-----------+----------+
```

## C ABI Surface (exported from Zig)

### Tier 1: String Operations (replaces QString2)

```c
// Lifecycle
StzStringHandle stz_string_new(void);
StzStringHandle stz_string_from(const char* utf8, size_t len);
void            stz_string_free(StzStringHandle h);

// Content
const char*     stz_string_data(StzStringHandle h);
size_t          stz_string_size(StzStringHandle h);
size_t          stz_string_count(StzStringHandle h); // unicode codepoints

// Mutation
void   stz_string_append(StzStringHandle h, const char* utf8, size_t len);
void   stz_string_insert(StzStringHandle h, size_t pos, const char* utf8, size_t len);

// Extraction
StzStringHandle stz_string_mid(StzStringHandle h, size_t start, size_t length);
StzStringHandle stz_string_left(StzStringHandle h, size_t length);
StzStringHandle stz_string_right(StzStringHandle h, size_t length);
StzStringHandle stz_string_trimmed(StzStringHandle h);

// Search
int64_t  stz_string_index_of(StzStringHandle h, const char* needle, size_t len);
int64_t  stz_string_last_index_of(StzStringHandle h, const char* needle, size_t len);
int      stz_string_contains(StzStringHandle h, const char* needle, size_t len);
int      stz_string_starts_with(StzStringHandle h, const char* prefix, size_t len);
int      stz_string_ends_with(StzStringHandle h, const char* suffix, size_t len);

// Transform
void   stz_string_replace(StzStringHandle h, const char* old, size_t old_len,
                           const char* new, size_t new_len);
StzStringHandle* stz_string_split(StzStringHandle h, const char* sep, size_t sep_len,
                                   size_t* out_count);

// Case
StzStringHandle stz_string_to_upper(StzStringHandle h);
StzStringHandle stz_string_to_lower(StzStringHandle h);
int             stz_string_is_rtl(StzStringHandle h);
```

### Tier 1: Unicode Character (replaces QChar)

```c
uint32_t  stz_char_unicode(const char* utf8_char);
size_t    stz_char_to_utf8(uint32_t codepoint, char* buf, size_t buf_len);
int       stz_char_is_letter(uint32_t codepoint);
int       stz_char_is_digit(uint32_t codepoint);
int       stz_char_is_upper(uint32_t codepoint);
int       stz_char_is_lower(uint32_t codepoint);
uint32_t  stz_char_mirrored(uint32_t codepoint);
```

### Tier 2: Date/Time (replaces QDate, QTime, QDateTime)

```c
typedef struct { int32_t year; uint8_t month; uint8_t day; } StzDate;
typedef struct { uint8_t hour; uint8_t minute; uint8_t second; uint32_t ms; } StzTime;

StzDate   stz_date_today(void);
int       stz_date_is_valid(StzDate d);
int32_t   stz_date_days_between(StzDate a, StzDate b);
StzDate   stz_date_add_days(StzDate d, int32_t n);
size_t    stz_date_format(StzDate d, const char* fmt, char* buf, size_t buf_len);
int       stz_date_day_of_week(StzDate d);

StzTime   stz_time_now(void);
size_t    stz_time_format(StzTime t, const char* fmt, char* buf, size_t buf_len);
```

### Tier 2: File System (replaces QFile, QDir, QFileInfo)

```c
int       stz_file_exists(const char* path);
int64_t   stz_file_size(const char* path);
char*     stz_file_read_all(const char* path, size_t* out_len);
int       stz_file_write_all(const char* path, const char* data, size_t len);
int       stz_file_delete(const char* path);
int       stz_file_copy(const char* src, const char* dst);

int       stz_dir_exists(const char* path);
int       stz_dir_create(const char* path);
char**    stz_dir_list(const char* path, size_t* out_count);

char*     stz_file_extension(const char* path);
char*     stz_file_basename(const char* path);
char*     stz_file_dirname(const char* path);
```

### Tier 2: Locale (replaces QLocale)

```c
size_t    stz_locale_format_number(double n, const char* locale_id,
                                    char* buf, size_t buf_len);
size_t    stz_locale_format_currency(double n, const char* locale_id,
                                      const char* currency_code,
                                      char* buf, size_t buf_len);
const char* stz_locale_language_name(const char* locale_id);
const char* stz_locale_country_name(const char* locale_id);
```

### Tier 3: Regex (replaces QRegExp)

```c
StzRegexHandle stz_regex_compile(const char* pattern, size_t len);
void           stz_regex_free(StzRegexHandle h);
int            stz_regex_match(StzRegexHandle h, const char* input, size_t len);
StzStringHandle* stz_regex_captures(StzRegexHandle h, const char* input,
                                     size_t len, size_t* out_count);
```

### Tier 3: JSON (replaces QJson*)

```c
StzJsonHandle stz_json_parse(const char* json, size_t len);
void          stz_json_free(StzJsonHandle h);
const char*   stz_json_get_string(StzJsonHandle h, const char* key);
double        stz_json_get_number(StzJsonHandle h, const char* key);
size_t        stz_json_stringify(StzJsonHandle h, char* buf, size_t buf_len);
```

## Ring FFI Bridge (stzengine.ring)

The bridge file translates Ring calls to Engine C functions:

```ring
# stzengine.ring -- Ring FFI bridge to Softanza Engine

LoadLib("softanza_engine.dll")  # or .so / .dylib

# String functions
stz_string_new      = GetCFunc("stz_string_new", "p", "")
stz_string_from     = GetCFunc("stz_string_from", "p", "pi")
stz_string_free     = GetCFunc("stz_string_free", "v", "p")
stz_string_data     = GetCFunc("stz_string_data", "p", "p")
stz_string_size     = GetCFunc("stz_string_size", "i", "p")
stz_string_append   = GetCFunc("stz_string_append", "v", "ppi")
stz_string_mid      = GetCFunc("stz_string_mid", "p", "pii")
stz_string_index_of = GetCFunc("stz_string_index_of", "i", "ppi")
# ... and so on for all functions
```

## Implementation Plan

### Phase A: Build Infrastructure
- Set up Zig project with `build.zig`
- Define C ABI exports
- Build Ring FFI bridge template
- Produce DLL/SO for Windows/Linux/macOS

### Phase B: Tier 1 -- Strings + Unicode [DONE]
- stz_string_* replaces 300+ QString2 calls
- stz_char_* replaces 42 QChar calls
- stz_bytes_* replaces QByteArray
- stkString.ring and stzString.ring use Engine

### Phase C: Tier 2 -- Date/Time + Files + Locale [DONE]
- stz_date_*, stz_time_*, stz_datetime_* implemented
- stz_file_*, stz_dir_* implemented
- stz_locale_* implemented

### Phase D: Tier 3 -- Regex + JSON + Process [DONE]
- stz_regex_* implemented (Zig regex)
- stz_json_* implemented
- stz_process_* implemented

### Phase E: Qt Fully Removed [DONE]
- All Qt classes purged from base layer
- All bridge files rewritten as LoadLib-only
- Full e2e verification of 10 base classes passed
- Ship: Ring + softanza_engine binary = complete Softanza

### Phase F: Ring Workaround Elimination [PLANNED]

Ring stdlib workarounds that must migrate to Engine:

1. **List operations** (stzList Stringify trick):
   - `Stringify()` converts lists to strings for search/replace
     because Ring `find()` only works on numbers/strings
   - Engine: native list search, replace, deduplicate in Zig
   - Functions: `stz_list_find`, `stz_list_replace`,
     `stz_list_sort`, `stz_list_unique`, `stz_list_stringify`

2. **Number precision** (stzNumber string storage):
   - Numbers stored as strings to preserve decimal precision
     because Ring uses IEEE 754 doubles (15-digit limit)
   - Engine: arbitrary-precision arithmetic via Zig
   - Functions: `stz_number_add`, `stz_number_mul`,
     `stz_number_format`, `stz_number_round`

3. **Sort operations** (stzList mixed-type sort):
   - Ring `sort()` fails on non-homogeneous lists
   - Workaround: stringify column, sort, then map back
   - Engine: heterogeneous sort with type-aware comparison

4. **Time operations** (stzTime pure Ring):
   - Currently implemented in pure Ring
   - Engine: `stz_time_*` functions for consistency

5. **String utilities** (stzLen, @substr):
   - `StzLen()` reimplements UTF-8 codepoint counting in Ring
     because `len()` counts bytes
   - `@substr()` adds positional extraction Ring lacks
   - Engine: already covered by `stz_string_count`,
     `stz_string_mid` -- wire remaining Ring callers

6. **Folder operations** (stzFolder):
   - Currently uses Ring file ops
   - Engine: `stz_dir_*` functions already exist, wire them

## Why the Engine Does Everything

Ring provides a scripting runtime -- syntax, OOP, dynamic typing,
and an interactive REPL. But Ring's stdlib is not reliable for
production data operations:

| Ring Limitation              | Engine Solution                    |
|------------------------------|------------------------------------|
| `len()` counts bytes, not    | `stz_string_count()` counts        |
| Unicode codepoints           | codepoints correctly               |
| `find()` only finds numbers  | Engine find handles any type,      |
| and strings in lists         | with O(n log n) sorted paths       |
| `sort()` fails on mixed-type | Engine sort handles heterogeneous  |
| or nested lists              | lists natively                     |
| `substr()` lacks positional  | Engine slice/section operations    |
| extraction form              | with Unicode-aware indexing        |
| Number precision limited to  | Engine arbitrary-precision         |
| IEEE 754 doubles (15 digits) | arithmetic via Zig big integers    |
| List operations too slow for | Engine list ops in Zig (search,    |
| >1K items (Stringify trick)  | sort, replace, deduplicate)        |
| No built-in sleep, no async  | Engine async I/O, timers           |

**Design rule:** Ring is the scripting surface. The Engine is the
computation substrate. Every data operation goes through the Engine.

## Zig Advantages for the Engine

- Compiles to a single static binary (no runtime dependencies)
- Cross-compiles to Windows/Linux/macOS/ARM from any host
- C ABI compatibility built in (no wrapper generators needed)
- Unicode support via std.unicode
- Excellent string handling (slices, UTF-8 native)
- Memory safety without garbage collection
- The same Engine can serve both Softanza (Ring) and Zin

## Zin Connection

The Softanza Engine IS the runtime substrate that powers both:
- **Softanza** (Ring surface): `stzString -> stzengine.ring -> Engine`
- **Zin** (Zig surface): `Zin pillars -> Engine directly`

This is the "Zing" bridge -- the power of Zig, the beauty of Ring.
