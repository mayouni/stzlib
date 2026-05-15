# Softanza Engine Design

## Purpose

The Softanza Engine is the universal computation substrate that
powers Softanza. It is a standalone Zig shared library exposing a
C ABI. Any language with C FFI can bind to it and reproduce the
full Softanza experience: Ring, Zig (Zin), Python, Rust, Go, etc.

**Design principle:** Ring provides the scripting surface -- syntax,
OOP, dynamic typing, REPL. The Engine provides ALL computation:
data structures, algorithms, text processing, I/O. Ring's stdlib
is never used for data operations (its `len()` counts bytes, its
`find()` only works on primitives, its `sort()` fails on mixed
types, its numbers cap at 15-digit precision).

**Architecture:**

```
  Any Language (Ring, Python, Rust, Go, Zin...)
       |
  Language-specific FFI bridge
       |
  softanza_engine.dll / .so / .dylib  (Zig binary, C ABI)
       |
  +------------+------------+------------+
  | LAYER 0    | LAYER 1    | LAYER 2    |
  | Value      | Collections| Algorithms |
  | String     | List       | Search     |
  | Number     | HashMap    | Sort       |
  | Char       | Set        | Graph      |
  | Bytes      | Table      | Stats      |
  |            | Graph      | Text       |
  |            | Matrix     | Regex      |
  |            | Tree       | I/O        |
  +------------+------------+------------+
```

---

## Layer 0: Foundational Types

Every value in Softanza flows through the Engine's type system.
The tagged union `StzValue` is the universal currency.

### StzValue (Tagged Union)

```c
typedef enum {
    STZ_NULL = 0,
    STZ_BOOL,
    STZ_INT,       // 64-bit signed
    STZ_FLOAT,     // 64-bit IEEE 754
    STZ_BIGINT,    // arbitrary precision
    STZ_DECIMAL,   // arbitrary-precision decimal
    STZ_STRING,    // UTF-8, codepoint-indexed
    STZ_LIST,      // heterogeneous dynamic array
    STZ_HASHMAP,   // key-value store
    STZ_SET,       // unique elements
    STZ_DATE,
    STZ_TIME,
    STZ_PAIR,      // two StzValues
} StzValueType;

typedef struct {
    StzValueType type;
    // ... union payload
} StzValue;

StzValue    stz_value_null(void);
StzValue    stz_value_bool(int b);
StzValue    stz_value_int(int64_t n);
StzValue    stz_value_float(double f);
StzValue    stz_value_string(const char* utf8, size_t len);
StzValueType stz_value_type(StzValue v);
int         stz_value_equals(StzValue a, StzValue b); // deep equality
int         stz_value_compare(StzValue a, StzValue b); // ordering
size_t      stz_value_stringify(StzValue v, char* buf, size_t buf_len);
void        stz_value_free(StzValue v);
```

**Why this matters:** Ring's `find()` only works on numbers and
strings. With `StzValue`, the Engine can find, sort, compare, and
hash ANY type -- lists inside lists, pairs, nested structures.
The Stringify trick disappears entirely.

### String (UTF-8, codepoint-indexed) [DONE]

```c
StzStringHandle stz_string_new(void);
StzStringHandle stz_string_from(const char* utf8, size_t len);
void            stz_string_free(StzStringHandle h);

const char*     stz_string_data(StzStringHandle h);
size_t          stz_string_size(StzStringHandle h);    // bytes
size_t          stz_string_count(StzStringHandle h);   // codepoints

void   stz_string_append(StzStringHandle h, const char* utf8, size_t len);
void   stz_string_insert(StzStringHandle h, size_t pos, const char* utf8, size_t len);

StzStringHandle stz_string_mid(StzStringHandle h, size_t start, size_t length);
StzStringHandle stz_string_left(StzStringHandle h, size_t length);
StzStringHandle stz_string_right(StzStringHandle h, size_t length);
StzStringHandle stz_string_trimmed(StzStringHandle h);

int64_t  stz_string_index_of(StzStringHandle h, const char* needle, size_t len);
int64_t  stz_string_last_index_of(StzStringHandle h, const char* needle, size_t len);
int      stz_string_contains(StzStringHandle h, const char* needle, size_t len);
int      stz_string_starts_with(StzStringHandle h, const char* prefix, size_t len);
int      stz_string_ends_with(StzStringHandle h, const char* suffix, size_t len);

void   stz_string_replace(StzStringHandle h, const char* old, size_t old_len,
                           const char* new_str, size_t new_len);
StzStringHandle* stz_string_split(StzStringHandle h, const char* sep, size_t sep_len,
                                   size_t* out_count);

StzStringHandle stz_string_to_upper(StzStringHandle h);
StzStringHandle stz_string_to_lower(StzStringHandle h);
int             stz_string_is_rtl(StzStringHandle h);
```

### Unicode Character [DONE]

```c
uint32_t  stz_char_unicode(const char* utf8_char);
size_t    stz_char_to_utf8(uint32_t codepoint, char* buf, size_t buf_len);
int       stz_char_is_letter(uint32_t codepoint);
int       stz_char_is_digit(uint32_t codepoint);
int       stz_char_is_upper(uint32_t codepoint);
int       stz_char_is_lower(uint32_t codepoint);
uint32_t  stz_char_mirrored(uint32_t codepoint);
const char* stz_char_name(uint32_t codepoint);
int       stz_char_script(uint32_t codepoint);
int       stz_char_category(uint32_t codepoint);
```

### Number (Arbitrary Precision) [PLANNED]

Replaces stzNumber's string-storage hack (Ring's IEEE 754 doubles
cap at 15-digit precision).

```c
StzNumberHandle stz_number_from_string(const char* s, size_t len);
StzNumberHandle stz_number_from_int(int64_t n);
StzNumberHandle stz_number_from_float(double f);
void            stz_number_free(StzNumberHandle h);

// Arithmetic (returns new handle, arbitrary precision)
StzNumberHandle stz_number_add(StzNumberHandle a, StzNumberHandle b);
StzNumberHandle stz_number_sub(StzNumberHandle a, StzNumberHandle b);
StzNumberHandle stz_number_mul(StzNumberHandle a, StzNumberHandle b);
StzNumberHandle stz_number_div(StzNumberHandle a, StzNumberHandle b, int scale);
StzNumberHandle stz_number_mod(StzNumberHandle a, StzNumberHandle b);
StzNumberHandle stz_number_pow(StzNumberHandle base, int32_t exp);

// Comparison
int  stz_number_compare(StzNumberHandle a, StzNumberHandle b);
int  stz_number_is_zero(StzNumberHandle h);
int  stz_number_is_negative(StzNumberHandle h);
int  stz_number_is_integer(StzNumberHandle h);

// Formatting
size_t stz_number_to_string(StzNumberHandle h, char* buf, size_t buf_len);
StzNumberHandle stz_number_round(StzNumberHandle h, int decimals, int mode);
size_t stz_number_format_locale(StzNumberHandle h, const char* locale,
                                 char* buf, size_t buf_len);

// Conversion
int     stz_number_integer_part(StzNumberHandle h);
int     stz_number_fractional_digits(StzNumberHandle h);
size_t  stz_number_to_binary(StzNumberHandle h, char* buf, size_t buf_len);
size_t  stz_number_to_hex(StzNumberHandle h, char* buf, size_t buf_len);
size_t  stz_number_to_octal(StzNumberHandle h, char* buf, size_t buf_len);
```

---

## Layer 1: Collection Data Structures

These are the foundational containers. Every Softanza collection
class (stzList, stzHashList, stzSet, stzTable, stzGraph, stzMatrix)
delegates storage and manipulation to these Engine structures.

### List (Heterogeneous Dynamic Array) [PLANNED]

Replaces Ring's list (which can't find complex items, can't sort
mixed types, and is too slow beyond 1K items).

```c
StzListHandle stz_list_new(void);
StzListHandle stz_list_from_values(const StzValue* items, size_t count);
void          stz_list_free(StzListHandle h);

size_t    stz_list_count(StzListHandle h);
StzValue  stz_list_at(StzListHandle h, size_t index);  // 1-based
void      stz_list_set(StzListHandle h, size_t index, StzValue v);
void      stz_list_append(StzListHandle h, StzValue v);
void      stz_list_insert(StzListHandle h, size_t index, StzValue v);
void      stz_list_remove_at(StzListHandle h, size_t index);

// Find -- works on ANY type (kills the Stringify trick)
int64_t   stz_list_find(StzListHandle h, StzValue item);
int64_t   stz_list_find_from(StzListHandle h, StzValue item, size_t start);
size_t    stz_list_find_all(StzListHandle h, StzValue item,
                             int64_t* out_positions, size_t max_positions);
int       stz_list_contains(StzListHandle h, StzValue item);

// Replace
size_t    stz_list_replace(StzListHandle h, StzValue old_item, StzValue new_item);
void      stz_list_replace_at(StzListHandle h, size_t index, StzValue v);

// Sort -- handles heterogeneous types
void      stz_list_sort(StzListHandle h, int ascending);
void      stz_list_sort_on(StzListHandle h, size_t col_index, int ascending);
void      stz_list_reverse(StzListHandle h);

// Set-like operations
StzListHandle stz_list_unique(StzListHandle h);
StzListHandle stz_list_intersection(StzListHandle a, StzListHandle b);
StzListHandle stz_list_union(StzListHandle a, StzListHandle b);
StzListHandle stz_list_difference(StzListHandle a, StzListHandle b);

// Deep operations (nested lists)
size_t    stz_list_depth(StzListHandle h);
StzListHandle stz_list_flatten(StzListHandle h);
StzListHandle stz_list_flatten_to(StzListHandle h, size_t max_depth);

// Stringify (for display, not as workaround)
size_t    stz_list_stringify(StzListHandle h, char* buf, size_t buf_len);

// Sections/Slicing
StzListHandle stz_list_section(StzListHandle h, size_t from, size_t to);

// Bulk operations
void      stz_list_swap(StzListHandle h, size_t i, size_t j);
void      stz_list_move(StzListHandle h, size_t from, size_t to);
```

### HashMap (O(1) Key-Value Store) [PLANNED]

Replaces stzHashList's O(n) linear-search-through-pairs.

```c
StzHashMapHandle stz_hashmap_new(void);
void             stz_hashmap_free(StzHashMapHandle h);

void      stz_hashmap_set(StzHashMapHandle h, const char* key, size_t key_len,
                           StzValue value);
StzValue  stz_hashmap_get(StzHashMapHandle h, const char* key, size_t key_len);
int       stz_hashmap_has(StzHashMapHandle h, const char* key, size_t key_len);
void      stz_hashmap_remove(StzHashMapHandle h, const char* key, size_t key_len);
size_t    stz_hashmap_count(StzHashMapHandle h);

// Iteration
size_t    stz_hashmap_keys(StzHashMapHandle h, const char** out_keys, size_t max);
size_t    stz_hashmap_values(StzHashMapHandle h, StzValue* out_values, size_t max);

// Merge
void      stz_hashmap_merge(StzHashMapHandle target, StzHashMapHandle source);
```

### Set (Unique Elements, O(1) Lookup) [PLANNED]

Replaces stzSet's O(n) uniqueness checking.

```c
StzSetHandle stz_set_new(void);
void         stz_set_free(StzSetHandle h);

int       stz_set_add(StzSetHandle h, StzValue v);     // returns 0 if duplicate
int       stz_set_contains(StzSetHandle h, StzValue v);
void      stz_set_remove(StzSetHandle h, StzValue v);
size_t    stz_set_count(StzSetHandle h);

StzSetHandle stz_set_union(StzSetHandle a, StzSetHandle b);
StzSetHandle stz_set_intersection(StzSetHandle a, StzSetHandle b);
StzSetHandle stz_set_difference(StzSetHandle a, StzSetHandle b);
int          stz_set_is_subset(StzSetHandle a, StzSetHandle b);

StzListHandle stz_set_to_list(StzSetHandle h);
```

### Table (Column-Oriented Dataframe) [PLANNED]

Replaces stzTable's Ring list-of-lists storage.

```c
StzTableHandle stz_table_new(const char** col_names, size_t num_cols);
void           stz_table_free(StzTableHandle h);

size_t    stz_table_num_rows(StzTableHandle h);
size_t    stz_table_num_cols(StzTableHandle h);

void      stz_table_add_row(StzTableHandle h, const StzValue* values, size_t count);
StzValue  stz_table_get(StzTableHandle h, size_t row, size_t col);
void      stz_table_set(StzTableHandle h, size_t row, size_t col, StzValue v);

StzListHandle  stz_table_col(StzTableHandle h, size_t col_index);
StzListHandle  stz_table_row(StzTableHandle h, size_t row_index);

void      stz_table_sort_by(StzTableHandle h, size_t col_index, int ascending);
StzTableHandle stz_table_filter(StzTableHandle h, size_t col_index,
                                 int (*predicate)(StzValue));
void      stz_table_transpose(StzTableHandle h);
```

### Graph (Adjacency List with Properties) [PLANNED]

Replaces stzGraph's Ring list-of-hashlists. Makes DFS, BFS,
shortest path, cycle detection run at native speed.

```c
StzGraphHandle stz_graph_new(int directed);
void           stz_graph_free(StzGraphHandle h);

// Nodes
size_t    stz_graph_add_node(StzGraphHandle h, const char* label, size_t len);
void      stz_graph_remove_node(StzGraphHandle h, size_t node_id);
size_t    stz_graph_node_count(StzGraphHandle h);

// Edges
void      stz_graph_add_edge(StzGraphHandle h, size_t from, size_t to, double weight);
void      stz_graph_remove_edge(StzGraphHandle h, size_t from, size_t to);
size_t    stz_graph_edge_count(StzGraphHandle h);

// Properties (generic key-value on nodes/edges)
void      stz_graph_set_node_prop(StzGraphHandle h, size_t node_id,
                                   const char* key, StzValue val);
StzValue  stz_graph_get_node_prop(StzGraphHandle h, size_t node_id,
                                   const char* key);

// Traversal
size_t    stz_graph_bfs(StzGraphHandle h, size_t start,
                         size_t* out_order, size_t max);
size_t    stz_graph_dfs(StzGraphHandle h, size_t start,
                         size_t* out_order, size_t max);

// Pathfinding
int       stz_graph_path_exists(StzGraphHandle h, size_t from, size_t to);
size_t    stz_graph_shortest_path(StzGraphHandle h, size_t from, size_t to,
                                   size_t* out_path, size_t max);
double    stz_graph_shortest_distance(StzGraphHandle h, size_t from, size_t to);

// Topology
int       stz_graph_has_cycle(StzGraphHandle h);
size_t    stz_graph_topological_sort(StzGraphHandle h,
                                      size_t* out_order, size_t max);
size_t    stz_graph_connected_components(StzGraphHandle h,
                                          size_t* out_labels, size_t max);

// Analysis
size_t    stz_graph_neighbors(StzGraphHandle h, size_t node_id,
                               size_t* out_neighbors, size_t max);
size_t    stz_graph_in_degree(StzGraphHandle h, size_t node_id);
size_t    stz_graph_out_degree(StzGraphHandle h, size_t node_id);
```

### Matrix (Dense 2D Numeric Array) [PLANNED]

Replaces stzMatrix's Ring list-of-lists. Enables BLAS-like
operations at native speed.

```c
StzMatrixHandle stz_matrix_new(size_t rows, size_t cols);
StzMatrixHandle stz_matrix_identity(size_t n);
void            stz_matrix_free(StzMatrixHandle h);

double    stz_matrix_get(StzMatrixHandle h, size_t row, size_t col);
void      stz_matrix_set(StzMatrixHandle h, size_t row, size_t col, double val);
size_t    stz_matrix_rows(StzMatrixHandle h);
size_t    stz_matrix_cols(StzMatrixHandle h);

// Arithmetic
StzMatrixHandle stz_matrix_add(StzMatrixHandle a, StzMatrixHandle b);
StzMatrixHandle stz_matrix_mul(StzMatrixHandle a, StzMatrixHandle b);
StzMatrixHandle stz_matrix_scale(StzMatrixHandle h, double scalar);
StzMatrixHandle stz_matrix_transpose(StzMatrixHandle h);
double          stz_matrix_determinant(StzMatrixHandle h);
StzMatrixHandle stz_matrix_inverse(StzMatrixHandle h);
```

### Tree (Labeled N-ary Tree) [PLANNED]

Replaces stzTree's nested-list representation. Enables native
traversal, path queries, and serialization.

```c
StzTreeHandle stz_tree_new(const char* root_label, size_t len);
void          stz_tree_free(StzTreeHandle h);

size_t    stz_tree_add_child(StzTreeHandle h, size_t parent_id,
                              const char* label, size_t len);
size_t    stz_tree_node_count(StzTreeHandle h);
size_t    stz_tree_depth(StzTreeHandle h);

size_t    stz_tree_children(StzTreeHandle h, size_t node_id,
                             size_t* out_children, size_t max);
size_t    stz_tree_parent(StzTreeHandle h, size_t node_id);

// Path queries
size_t    stz_tree_path_to_root(StzTreeHandle h, size_t node_id,
                                 size_t* out_path, size_t max);
size_t    stz_tree_leaves(StzTreeHandle h, size_t* out_leaves, size_t max);

// Traversal
size_t    stz_tree_preorder(StzTreeHandle h, size_t* out_order, size_t max);
size_t    stz_tree_postorder(StzTreeHandle h, size_t* out_order, size_t max);
size_t    stz_tree_levelorder(StzTreeHandle h, size_t* out_order, size_t max);
```

---

## Layer 2: Algorithms

Algorithms operate on Layer 0 types and Layer 1 collections.

### Statistics [PLANNED]

Replaces stzDataSet's Ring-based calculations.

```c
double    stz_stats_mean(const double* data, size_t count);
double    stz_stats_median(const double* data, size_t count);
double    stz_stats_mode(const double* data, size_t count);
double    stz_stats_stddev(const double* data, size_t count);
double    stz_stats_variance(const double* data, size_t count);
double    stz_stats_percentile(const double* data, size_t count, double p);
double    stz_stats_skewness(const double* data, size_t count);
double    stz_stats_kurtosis(const double* data, size_t count);
double    stz_stats_correlation(const double* x, const double* y, size_t count);
size_t    stz_stats_quartiles(const double* data, size_t count, double* out_q);
size_t    stz_stats_outliers(const double* data, size_t count,
                              size_t* out_indices, size_t max);
```

### Text Analysis [PLANNED]

Advanced text operations beyond basic string manipulation.

```c
// Word/sentence boundaries (UAX #29)
size_t    stz_text_word_count(const char* utf8, size_t len);
size_t    stz_text_words(const char* utf8, size_t len,
                          StzStringHandle* out_words, size_t max);
size_t    stz_text_sentences(const char* utf8, size_t len,
                              StzStringHandle* out_sentences, size_t max);

// String distance
size_t    stz_text_levenshtein(const char* a, size_t a_len,
                                const char* b, size_t b_len);
double    stz_text_jaro_winkler(const char* a, size_t a_len,
                                 const char* b, size_t b_len);
size_t    stz_text_hamming(const char* a, size_t a_len,
                            const char* b, size_t b_len);

// Script and language detection
int       stz_text_detect_script(const char* utf8, size_t len);
int       stz_text_detect_direction(const char* utf8, size_t len); // LTR/RTL

// Unicode normalization
StzStringHandle stz_text_normalize_nfc(const char* utf8, size_t len);
StzStringHandle stz_text_normalize_nfd(const char* utf8, size_t len);

// Transliteration
StzStringHandle stz_text_transliterate(const char* utf8, size_t len,
                                        const char* from_script,
                                        const char* to_script);
```

### Walker [PLANNED]

The walker pattern is a Softanza signature feature -- iterating
with step patterns, conditions, and multi-directional traversal.

```c
StzWalkerHandle stz_walker_new(size_t start, size_t end, int64_t step);
void            stz_walker_free(StzWalkerHandle h);

int       stz_walker_has_next(StzWalkerHandle h);
size_t    stz_walker_next(StzWalkerHandle h);
void      stz_walker_reset(StzWalkerHandle h);

// Multi-step patterns (e.g., step 2 then 3 then 2...)
StzWalkerHandle stz_walker_with_steps(size_t start, size_t end,
                                       const int64_t* steps, size_t num_steps);

// Collect all positions
size_t    stz_walker_positions(StzWalkerHandle h,
                                size_t* out_positions, size_t max);
```

### Date/Time [DONE]

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
int32_t   stz_time_seconds_between(StzTime a, StzTime b);
StzTime   stz_time_add_seconds(StzTime t, int32_t n);
```

### File System [DONE]

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

### Locale [DONE]

```c
size_t    stz_locale_format_number(double n, const char* locale_id,
                                    char* buf, size_t buf_len);
size_t    stz_locale_format_currency(double n, const char* locale_id,
                                      const char* currency_code,
                                      char* buf, size_t buf_len);
const char* stz_locale_language_name(const char* locale_id);
const char* stz_locale_country_name(const char* locale_id);
```

### Regex [DONE]

```c
StzRegexHandle stz_regex_compile(const char* pattern, size_t len);
void           stz_regex_free(StzRegexHandle h);
int            stz_regex_match(StzRegexHandle h, const char* input, size_t len);
StzStringHandle* stz_regex_captures(StzRegexHandle h, const char* input,
                                     size_t len, size_t* out_count);
```

### JSON [DONE]

```c
StzJsonHandle stz_json_parse(const char* json, size_t len);
void          stz_json_free(StzJsonHandle h);
const char*   stz_json_get_string(StzJsonHandle h, const char* key);
double        stz_json_get_number(StzJsonHandle h, const char* key);
size_t        stz_json_stringify(StzJsonHandle h, char* buf, size_t buf_len);
```

---

## Ring FFI Bridge (stzengine.ring)

The bridge translates Ring calls to Engine C functions:

```ring
# stzengine.ring -- Ring FFI bridge to Softanza Engine

LoadLib("softanza_engine.dll")  # or .so / .dylib

# String functions
stz_string_new      = GetCFunc("stz_string_new", "p", "")
stz_string_from     = GetCFunc("stz_string_from", "p", "pi")
stz_string_free     = GetCFunc("stz_string_free", "v", "p")
stz_string_data     = GetCFunc("stz_string_data", "p", "p")
stz_string_size     = GetCFunc("stz_string_size", "i", "p")
# ... and so on for all functions
```

---

## Implementation Roadmap

### Phase A-E: Qt Replacement [ALL DONE]
- Infrastructure, strings, unicode, datetime, files, locale,
  regex, json, process -- all implemented and shipping.

### Phase F: Ring Workaround Elimination

Priority order by impact on Softanza experience:

| Priority | Module      | Kills This Ring Workaround              |
|----------|-------------|-----------------------------------------|
| F.1      | StzValue    | Type system for heterogeneous ops       |
| F.2      | List        | Stringify trick, slow find/sort/replace  |
| F.3      | Number      | String-stored precision, 15-digit cap   |
| F.4      | HashMap     | O(n) linear search in stzHashList       |
| F.5      | Set         | O(n) uniqueness checking in stzSet      |
| F.6      | Stats       | All statistical math in Ring             |
| F.7      | Text        | Word boundaries, distance, normalization|
| F.8      | Table       | Column operations, sort, filter         |
| F.9      | Graph       | DFS/BFS/shortest path in Ring           |
| F.10     | Matrix      | Row/column arithmetic in Ring           |
| F.11     | Tree        | Nested list traversal/path generation   |
| F.12     | Walker      | Step-pattern iteration                  |
| F.13     | Time        | Wire to Engine for consistency          |

### Phase G: Engine as Universal Substrate

Once Phase F is complete, the Engine becomes language-agnostic:

- **Ring** binds via `stzengine.ring` (LoadLib + GetCFunc)
- **Zin** (Zig) calls Engine modules directly (no FFI overhead)
- **Python** binds via `ctypes` or `cffi`
- **Rust** binds via `extern "C"` declarations
- **Go** binds via `cgo`
- **Any C-compatible language** gets the full Softanza experience

The Engine IS the product. The language surfaces are thin skins.

---

## Zig Advantages for the Engine

- Compiles to a single static binary (no runtime dependencies)
- Cross-compiles to Windows/Linux/macOS/ARM from any host
- C ABI compatibility built in (no wrapper generators needed)
- Unicode support via std.unicode
- Excellent string handling (slices, UTF-8 native)
- Memory safety without garbage collection
- SIMD-ready for bulk number/list operations
- The same Engine serves Softanza (Ring) AND Zin (Zig)

## Zin Connection

The Softanza Engine IS the runtime substrate that powers both:
- **Softanza** (Ring surface): `stzString -> stzengine.ring -> Engine`
- **Zin** (Zig surface): `Zin pillars -> Engine directly`

This is the "Zing" bridge -- the power of Zig, the beauty of Ring.
