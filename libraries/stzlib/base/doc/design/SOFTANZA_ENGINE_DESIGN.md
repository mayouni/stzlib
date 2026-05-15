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
  +------------+------------+------------+------------+
  | LAYER 0    | LAYER 1    | LAYER 2    | LAYER 4    |
  | Value      | Collections| Algorithms | Signature  |
  | String     | List       | Search     | PatternEx  |
  | Number     | HashMap    | Sort       | NatLang    |
  | Char       | Set        | Graph      | Display    |
  | Bytes      | Table      | Stats      | UnivOps    |
  |            | Graph      | Text       | Reactive   |
  |            | Matrix     | Regex      | Constraint |
  |            | Tree       | I/O        | KnowGraph  |
  +------------+------------+------------+------------+
  |            LAYER 3: Infrastructure               |
  | Crypto, Codec, Compress, Stream, Watch, Process  |
  | Async, UUID, URL, HTML, RNG, Solver, Geo, Bits   |
  +--------------------------------------------------+
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

### Checker [PLANNED]

The Checker metaphor: test a condition across every item in a
collection and return the boolean result. The Engine implements
the iteration and predicate dispatch natively -- no Ring loop.

```c
// Check if ALL items satisfy a condition
int stz_check_all(StzValue collection,
                   int (*predicate)(StzValue item, void* ctx),
                   void* ctx);

// Check if ANY item satisfies a condition
int stz_check_any(StzValue collection,
                   int (*predicate)(StzValue item, void* ctx),
                   void* ctx);

// Check if NO item satisfies a condition
int stz_check_none(StzValue collection,
                    int (*predicate)(StzValue item, void* ctx),
                    void* ctx);

// Check with named condition string (uses expression evaluator)
int stz_check_all_expr(StzValue collection,
                        const char* condition, size_t len);
int stz_check_any_expr(StzValue collection,
                        const char* condition, size_t len);

// Count how many items satisfy the condition
size_t stz_check_count(StzValue collection,
                        int (*predicate)(StzValue item, void* ctx),
                        void* ctx);

// Return positions of items that satisfy the condition
size_t stz_check_where(StzValue collection,
                        int (*predicate)(StzValue item, void* ctx),
                        void* ctx,
                        size_t* out_positions, size_t max);
```

### Yielder [PLANNED]

The Yielder metaphor: apply a transformation to each item and
yield the results into a new collection. This is map/filter/reduce
but with Softanza's semantic richness -- it works on ANY structure,
not just lists.

```c
// Yield: apply transform to each item, return new collection
StzValue stz_yield(StzValue collection,
                    StzValue (*transform)(StzValue item, void* ctx),
                    void* ctx);

// Yield with expression string (uses expression evaluator)
StzValue stz_yield_expr(StzValue collection,
                         const char* expression, size_t len);

// YieldW: yield only items satisfying a condition
StzValue stz_yield_where(StzValue collection,
                          int (*predicate)(StzValue item, void* ctx),
                          StzValue (*transform)(StzValue item, void* ctx),
                          void* ctx);

// YieldXT: yield with access to index, previous, next
StzValue stz_yield_xt(StzValue collection,
                       StzValue (*transform)(StzValue item,
                                             size_t index,
                                             StzValue prev,
                                             StzValue next,
                                             void* ctx),
                       void* ctx);

// Accumulate: fold/reduce with initial value
StzValue stz_yield_accumulate(StzValue collection,
                               StzValue initial,
                               StzValue (*combine)(StzValue acc,
                                                    StzValue item,
                                                    void* ctx),
                               void* ctx);
```

### Performer [PLANNED]

The Performer metaphor: execute an action on each item in-place,
modifying the collection. Unlike Yielder (which produces a new
collection), Performer mutates.

```c
// Perform: execute action on each item (mutating)
void stz_perform(StzValue collection,
                  void (*action)(StzValue* item, void* ctx),
                  void* ctx);

// Perform with expression string
void stz_perform_expr(StzValue collection,
                       const char* expression, size_t len);

// PerformW: perform only on items satisfying condition
void stz_perform_where(StzValue collection,
                        int (*predicate)(StzValue item, void* ctx),
                        void (*action)(StzValue* item, void* ctx),
                        void* ctx);

// PerformXT: perform with access to index, neighbors
void stz_perform_xt(StzValue collection,
                     void (*action)(StzValue* item,
                                    size_t index,
                                    StzValue prev,
                                    StzValue next,
                                    void* ctx),
                     void* ctx);
```

**The four metaphors form a complete interaction vocabulary:**
- **Walker** -- traverse (navigate positions)
- **Checker** -- test (ask yes/no questions)
- **Yielder** -- transform (produce new data)
- **Performer** -- act (modify in place)

Every metaphor works on ANY StzValue collection via type dispatch.

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

## Layer 3: Infrastructure Services

These modules provide system-level capabilities that multiple
Softanza classes need. Without them in the Engine, Ring falls
back to slow external process calls or incomplete stdlib wrappers.

### Cryptography & Hashing [PLANNED]

Replaces stzCrypto's external library calls. Constant-time
implementations for security.

```c
// Hashing
size_t    stz_hash_md5(const char* data, size_t len, char* out, size_t out_len);
size_t    stz_hash_sha1(const char* data, size_t len, char* out, size_t out_len);
size_t    stz_hash_sha256(const char* data, size_t len, char* out, size_t out_len);
size_t    stz_hash_sha512(const char* data, size_t len, char* out, size_t out_len);

// Incremental hashing
StzHashHandle stz_hash_init(int algorithm);
void      stz_hash_update(StzHashHandle h, const char* data, size_t len);
size_t    stz_hash_final(StzHashHandle h, char* out, size_t out_len);

// Symmetric encryption
size_t    stz_cipher_encrypt(int algorithm, const char* key, size_t key_len,
                              const char* plaintext, size_t pt_len,
                              char* ciphertext, size_t ct_len);
size_t    stz_cipher_decrypt(int algorithm, const char* key, size_t key_len,
                              const char* ciphertext, size_t ct_len,
                              char* plaintext, size_t pt_len);

// Algorithms: STZ_AES_128, STZ_AES_256, STZ_BLOWFISH, STZ_DES3
```

### Text Encoding / Codecs [PLANNED]

Replaces stzTextEncoding's 38+ codec support. Streaming codec
conversion for I/O pipelines.

```c
// Codec conversion
size_t    stz_codec_convert(const char* from_encoding,
                             const char* to_encoding,
                             const char* input, size_t input_len,
                             char* output, size_t output_len);

// Encoding detection
const char* stz_codec_detect(const char* data, size_t len);

// BOM handling
size_t    stz_codec_bom_size(const char* encoding);
int       stz_codec_has_bom(const char* data, size_t len);

// Supported: utf-8, utf-16le, utf-16be, utf-32le, utf-32be,
// iso-8859-1..16, windows-1250..1258, shift-jis, euc-jp,
// euc-kr, gb18030, big5, koi8-r, koi8-u, iscii-*
```

### Compression [PLANNED]

Replaces stzZipFile's external zip library dependency.

```c
// Deflate/Inflate (raw)
size_t    stz_compress(const char* input, size_t input_len,
                        char* output, size_t output_len, int level);
size_t    stz_decompress(const char* input, size_t input_len,
                          char* output, size_t output_len);

// ZIP archive
StzZipHandle stz_zip_open(const char* path, int mode); // READ or WRITE
void      stz_zip_close(StzZipHandle h);
int       stz_zip_add_file(StzZipHandle h, const char* name,
                            const char* data, size_t len);
size_t    stz_zip_entry_count(StzZipHandle h);
size_t    stz_zip_read_entry(StzZipHandle h, size_t index,
                              char* out, size_t out_len);
```

### Streaming I/O [PLANNED]

Replaces stzTextStream. Buffered streams with codec chains for
efficient file/network I/O.

```c
StzStreamHandle stz_stream_open_file(const char* path, const char* mode,
                                      const char* encoding);
StzStreamHandle stz_stream_from_buffer(const char* data, size_t len);
void            stz_stream_close(StzStreamHandle h);

size_t    stz_stream_read(StzStreamHandle h, char* buf, size_t buf_len);
size_t    stz_stream_read_line(StzStreamHandle h, char* buf, size_t buf_len);
int       stz_stream_write(StzStreamHandle h, const char* data, size_t len);
int       stz_stream_eof(StzStreamHandle h);
void      stz_stream_flush(StzStreamHandle h);
```

### File System Events [PLANNED]

Replaces stzFolderWatcher's libuv dependency. Native OS-level
file watching (inotify / FSEvents / ReadDirectoryChangesW).

```c
StzWatchHandle stz_watch_dir(const char* path, int recursive);
void           stz_watch_stop(StzWatchHandle h);
int            stz_watch_poll(StzWatchHandle h, StzWatchEvent* out_event);

typedef struct {
    int kind;          // CREATED, MODIFIED, DELETED, RENAMED
    char path[1024];
} StzWatchEvent;
```

### Process Management [PLANNED]

Replaces stzExterCode's manual process spawning. Needed for
multi-language integration (Python, R, Julia, COBOL).

```c
StzProcessHandle stz_process_start(const char* command,
                                    const char** args, size_t num_args);
int       stz_process_wait(StzProcessHandle h);
int       stz_process_exit_code(StzProcessHandle h);
size_t    stz_process_read_stdout(StzProcessHandle h, char* buf, size_t len);
size_t    stz_process_read_stderr(StzProcessHandle h, char* buf, size_t len);
int       stz_process_write_stdin(StzProcessHandle h,
                                   const char* data, size_t len);
void      stz_process_kill(StzProcessHandle h);
```

### Async / Event Loop [PLANNED]

Replaces stzReactive's libuv dependency. Provides timers, task
scheduling, and I/O multiplexing for reactive programming.

```c
StzLoopHandle stz_loop_new(void);
void          stz_loop_free(StzLoopHandle h);
int           stz_loop_run(StzLoopHandle h);  // blocks until empty
void          stz_loop_stop(StzLoopHandle h);

// Timers
StzTimerHandle stz_timer_start(StzLoopHandle loop, uint64_t ms,
                                int repeat, void (*callback)(void*),
                                void* userdata);
void           stz_timer_stop(StzTimerHandle h);

// Task queue
void      stz_loop_queue_task(StzLoopHandle loop,
                               void (*task)(void*), void* userdata);
```

### UUID [PLANNED]

```c
size_t    stz_uuid_v4(char* buf, size_t buf_len);  // random
size_t    stz_uuid_v5(const char* namespace_uuid, const char* name,
                       size_t name_len, char* buf, size_t buf_len);
int       stz_uuid_is_valid(const char* uuid, size_t len);
```

### URL Parsing [PLANNED]

```c
typedef struct {
    char scheme[16];
    char host[256];
    uint16_t port;
    char path[1024];
    char query[1024];
    char fragment[256];
} StzUrl;

int       stz_url_parse(const char* url, size_t len, StzUrl* out);
size_t    stz_url_encode(const char* input, size_t len,
                          char* output, size_t out_len);
size_t    stz_url_decode(const char* input, size_t len,
                          char* output, size_t out_len);
```

### HTML/XML Parsing [PLANNED]

Replaces stzHtml's manual string parsing with a proper DOM.

```c
StzDomHandle stz_html_parse(const char* html, size_t len);
void         stz_html_free(StzDomHandle h);

size_t    stz_html_query(StzDomHandle h, const char* selector,
                          size_t* out_node_ids, size_t max);
size_t    stz_html_text(StzDomHandle h, size_t node_id,
                         char* buf, size_t buf_len);
size_t    stz_html_attr(StzDomHandle h, size_t node_id,
                         const char* attr_name,
                         char* buf, size_t buf_len);
size_t    stz_html_children(StzDomHandle h, size_t node_id,
                             size_t* out_children, size_t max);
```

### Random Number Generation [PLANNED]

Needed by solvers, crypto, Monte Carlo simulations.

```c
void      stz_rng_seed(uint64_t seed);
uint64_t  stz_rng_next(void);
double    stz_rng_float(void);                // [0, 1)
int64_t   stz_rng_range(int64_t min, int64_t max);
void      stz_rng_shuffle(StzListHandle h);   // Fisher-Yates
```

### Optimization Solvers [PLANNED]

Replaces stzMultiObjectiveSolver (NSGA-II), stzStochasticSolver
(Monte Carlo), stzLinearSolver (Gaussian elimination).

```c
// Linear system solver (Ax = b)
int       stz_solve_linear(StzMatrixHandle A, const double* b,
                            double* x, size_t n);

// Multi-objective optimizer (NSGA-II)
StzSolverHandle stz_solver_nsga2(size_t num_objectives,
                                  size_t population_size,
                                  size_t generations);
void      stz_solver_set_bounds(StzSolverHandle h,
                                 const double* lower, const double* upper,
                                 size_t dimensions);
size_t    stz_solver_pareto_front(StzSolverHandle h,
                                   double* out_solutions,
                                   size_t max_solutions,
                                   size_t dimensions);
void      stz_solver_free(StzSolverHandle h);
```

### Geospatial [PLANNED]

Replaces stzGeoMap's coordinate calculations.

```c
double    stz_geo_haversine(double lat1, double lon1,
                             double lat2, double lon2);
void      stz_geo_destination(double lat, double lon,
                               double bearing, double distance,
                               double* out_lat, double* out_lon);
int       stz_geo_point_in_polygon(double lat, double lon,
                                    const double* polygon_lats,
                                    const double* polygon_lons,
                                    size_t num_points);
```

### Bit & Byte Operations [PLANNED]

Replaces stzBit/stzByte/stzListOfBits manual operations.

```c
StzBytesHandle stz_bytes_new(size_t capacity);
void           stz_bytes_free(StzBytesHandle h);

void      stz_bytes_append(StzBytesHandle h, uint8_t byte);
uint8_t   stz_bytes_get(StzBytesHandle h, size_t index);
size_t    stz_bytes_count(StzBytesHandle h);

// Bitwise
int       stz_bytes_bit_get(StzBytesHandle h, size_t bit_index);
void      stz_bytes_bit_set(StzBytesHandle h, size_t bit_index, int value);
size_t    stz_bytes_popcount(StzBytesHandle h);

// Encoding
size_t    stz_bytes_to_hex(StzBytesHandle h, char* buf, size_t buf_len);
size_t    stz_bytes_to_base64(StzBytesHandle h, char* buf, size_t buf_len);
StzBytesHandle stz_bytes_from_hex(const char* hex, size_t len);
StzBytesHandle stz_bytes_from_base64(const char* b64, size_t len);
```

### Expression Evaluator [PLANNED]

Replaces Ring's slow `eval()` for stzConstraint, stzQEngine,
and conditional code (W()/WXT() transpilation).

```c
StzExprHandle stz_expr_compile(const char* expression, size_t len);
void          stz_expr_free(StzExprHandle h);
StzValue      stz_expr_eval(StzExprHandle h, const StzValue* vars,
                             const char** var_names, size_t num_vars);
int           stz_expr_is_valid(const char* expression, size_t len);
```

### Function Registry & Alternatives Engine [PLANNED]

Softanza's 6000+ methods are not hand-coded -- they follow a
systematic naming grammar (prefixes, suffixes, free-form,
alternatives). The Engine codifies this grammar so ANY language
surface can auto-generate the full method vocabulary from a
compact base.

```c
// Register a base function
void stz_registry_add(const char* domain,       // "string"
                       const char* base_name,    // "Find"
                       const char* signature,    // "StzValue,StzValue->int64_t"
                       void* func_ptr);

// Generate all alternatives for a base function
// Applies: prefixes (FindFirst, FindLast, FindNth, FindAll)
//          suffixes (FindCS, FindCSXT, FindXT)
//          named params (FindW, FindWXT)
//          semantic alternatives (FindOccurrence, FindPosition)
size_t stz_registry_expand(const char* base_name,
                            char** out_names, size_t max);

// Lookup function by any alternative name
void* stz_registry_resolve(const char* name, size_t len);

// Generate bridge code for a target language
// Languages: "ring", "python", "rust", "go", "csharp"
size_t stz_registry_generate_bridge(const char* language,
                                     char* buf, size_t buf_len);

// List all registered functions for a domain
size_t stz_registry_list(const char* domain,
                          char** out_names, size_t max);
```

**Naming grammar rules (Engine-enforced):**
- Prefixes: `FindFirst`, `FindLast`, `FindNth`, `FindAll`
- Suffixes: `CS` (case-sensitive), `XT` (extended), `Q` (chained)
- Conditionals: `W` (where/when), `WXT` (where extended)
- Semantic: `NumberOfChars` = `Size` for strings
- Multilingual: `Chercher` = `Find` (via language mapping JSON)

### Cache Engine [PLANNED]

Function-level caching with pluggable stores. Enables the
`@ActivateCache` decorator pattern at Engine speed.

```c
StzCacheHandle stz_cache_new(int store_type);
// STZ_CACHE_MEMORY, STZ_CACHE_FILE, STZ_CACHE_MMAP
void           stz_cache_free(StzCacheHandle h);

// Cache a function result keyed by arguments hash
void stz_cache_put(StzCacheHandle h,
                    const char* func_name, size_t name_len,
                    const StzValue* args, size_t num_args,
                    StzValue result);

// Lookup cached result (returns 1 if hit, 0 if miss)
int  stz_cache_get(StzCacheHandle h,
                    const char* func_name, size_t name_len,
                    const StzValue* args, size_t num_args,
                    StzValue* out_result);

// Invalidate entries for a function or all
void stz_cache_invalidate(StzCacheHandle h,
                           const char* func_name, size_t name_len);
void stz_cache_clear(StzCacheHandle h);

// Stats
size_t stz_cache_hits(StzCacheHandle h);
size_t stz_cache_misses(StzCacheHandle h);
size_t stz_cache_size_bytes(StzCacheHandle h);
```

### Log Engine [PLANNED]

Function-level tracing with structured context. Enables the
`@ActivateLog` decorator pattern.

```c
StzLogHandle stz_log_new(int store_type, const char* config_json,
                          size_t len);
// STZ_LOG_FILE, STZ_LOG_MEMORY, STZ_LOG_CALLBACK
void         stz_log_free(StzLogHandle h);

// Log a function call with context
void stz_log_call(StzLogHandle h,
                   const char* func_name, size_t name_len,
                   const char* caller_name, size_t caller_len,
                   const StzValue* args, size_t num_args,
                   StzValue result,
                   uint64_t duration_ns);

// Query logs
size_t stz_log_query(StzLogHandle h,
                      const char* func_name,  // NULL for all
                      uint64_t from_timestamp, // 0 for start
                      uint64_t to_timestamp,   // 0 for now
                      StzLogEntry* out_entries, size_t max);

typedef struct {
    char func_name[256];
    char caller_name[256];
    uint64_t timestamp;
    uint64_t duration_ns;
} StzLogEntry;

// Log level control
void stz_log_set_level(StzLogHandle h, int level);
// STZ_LOG_TRACE, STZ_LOG_DEBUG, STZ_LOG_INFO,
// STZ_LOG_WARN, STZ_LOG_ERROR
```

### Profiler Engine [PLANNED]

Measurable performance at function granularity. Enables the
`@MeasurePerformance` decorator pattern.

```c
StzProfilerHandle stz_profiler_new(void);
void              stz_profiler_free(StzProfilerHandle h);

// Start/stop timing a function
void stz_profiler_enter(StzProfilerHandle h,
                         const char* func_name, size_t len);
void stz_profiler_exit(StzProfilerHandle h,
                        const char* func_name, size_t len);

// Get timing stats for a function
uint64_t stz_profiler_total_ns(StzProfilerHandle h,
                                const char* func_name, size_t len);
uint64_t stz_profiler_avg_ns(StzProfilerHandle h,
                              const char* func_name, size_t len);
size_t   stz_profiler_call_count(StzProfilerHandle h,
                                  const char* func_name, size_t len);

// Get call graph (who called whom)
size_t stz_profiler_callgraph(StzProfilerHandle h,
                               StzProfilerEdge* out_edges,
                               size_t max);

typedef struct {
    char caller[256];
    char callee[256];
    size_t call_count;
    uint64_t total_ns;
} StzProfilerEdge;

// Render profile as visual callstack (uses Display Engine)
size_t stz_profiler_show(StzProfilerHandle h,
                          char* buf, size_t buf_len);
```

### Callstack Visualizer [PLANNED]

Visual error reporting with execution path rendering. Powers
Softanza's informative error messages.

```c
// Capture current callstack
StzCallstackHandle stz_callstack_capture(void);
void               stz_callstack_free(StzCallstackHandle h);

// Push/pop frames manually (for interpreted languages)
void stz_callstack_push(StzCallstackHandle h,
                         const char* func_name, size_t len,
                         const char* file_name, size_t file_len,
                         size_t line_number);
void stz_callstack_pop(StzCallstackHandle h);

// Render callstack as ASCII tree (uses Display Engine)
size_t stz_callstack_show(StzCallstackHandle h,
                           char* buf, size_t buf_len);

// Render with error context
size_t stz_callstack_show_error(StzCallstackHandle h,
                                 const char* error_msg, size_t len,
                                 char* buf, size_t buf_len);
```

---

## Design Principle: Seven Design Goals

The Engine must enable ALL seven of Softanza's design goals.
Each goal maps to Engine capabilities:

| Goal                   | Engine Capabilities                      |
|------------------------|------------------------------------------|
| **Expressiveness**     | Fluent chaining (StzValue returns),      |
|                        | semantic precision (type-specific ops),  |
|                        | multilingual function names (registry)   |
| **Flexibility**        | Function registry (prefix/suffix/alt),   |
|                        | free-form params, default values         |
| **Reliability**        | Unicode-correct ops, arbitrary precision,|
|                        | type-safe collections, 20+ domains       |
| **Consistency**        | Universal ops (Find/Replace/Show on ALL  |
|                        | types), consistent naming grammar        |
| **Human-Centric**      | 4 metaphors (Walker/Checker/Yielder/     |
|                        | Performer) as native Engine modules      |
| **Practical Abstractions** | Constraint engine, natural language,  |
|                        | knowledge programming, conditional code, |
|                        | visual orientation (display engine)      |
| **Manageability**      | Cache, log, profiler, callstack viz,     |
|                        | error context -- all Engine-native       |

---

## Design Principle: Feature Generalization

Softanza's identity is that operations generalize across data
structures. A feature does not exist for "strings" or "lists" --
it exists for ALL structures that admit it. The Engine enforces
this by routing every generalizable operation through StzValue and
a domain tag, so the same C ABI serves strings, lists, tables,
trees, graphs, matrices, and any future structure.

**The rule:** If an operation makes sense on more than one data
structure, it MUST be implemented as a single Engine function
family that dispatches on the domain tag. Language surfaces
(Ring, Python, Rust) call the same function -- the Engine decides
how to execute it based on the target's type.

### Universal Operation Families

These operations generalize across ALL or MOST data structures:

| Operation   | String | List | Table | Matrix | Tree | Graph | Grid |
|-------------|:------:|:----:|:-----:|:------:|:----:|:-----:|:----:|
| Find        |   Y    |  Y   |   Y   |   Y    |  Y   |   Y   |  Y   |
| FindAll     |   Y    |  Y   |   Y   |   Y    |  Y   |   Y   |  Y   |
| Replace     |   Y    |  Y   |   Y   |   Y    |  Y   |   Y   |  Y   |
| ReplaceAll  |   Y    |  Y   |   Y   |   Y    |  Y   |   Y   |  Y   |
| Contains    |   Y    |  Y   |   Y   |   Y    |  Y   |   Y   |  Y   |
| Count       |   Y    |  Y   |   Y   |   Y    |  Y   |   Y   |  Y   |
| Sort        |   Y    |  Y   |   Y   |   -    |  -   |   -   |  -   |
| Reverse     |   Y    |  Y   |   Y   |   Y    |  -   |   -   |  Y   |
| Section     |   Y    |  Y   |   Y   |   Y    |  Y   |   Y   |  Y   |
| Split       |   Y    |  Y   |   Y   |   Y    |  Y   |   Y   |  Y   |
| Merge       |   Y    |  Y   |   Y   |   Y    |  Y   |   Y   |  Y   |
| Walk        |   Y    |  Y   |   Y   |   Y    |  Y   |   Y   |  Y   |
| Show        |   Y    |  Y   |   Y   |   Y    |  Y   |   Y   |  Y   |
| Boxed       |   Y    |  Y   |   Y   |   Y    |  Y   |   Y   |  Y   |
| VizFind     |   Y    |  Y   |   Y   |   Y    |  Y   |   Y   |  Y   |
| ToCode      |   Y    |  Y   |   Y   |   Y    |  Y   |   Y   |  Y   |

### Universal C ABI

```c
// Generic operations dispatched on StzValue type
int64_t   stz_find(StzValue haystack, StzValue needle);
size_t    stz_find_all(StzValue haystack, StzValue needle,
                        int64_t* out_positions, size_t max);
size_t    stz_replace(StzValue target, StzValue old_val,
                       StzValue new_val);
int       stz_contains(StzValue container, StzValue item);
size_t    stz_count(StzValue container, StzValue item);
StzValue  stz_section(StzValue source, size_t from, size_t to);
StzValue  stz_reverse(StzValue source);
StzValue  stz_merge(StzValue a, StzValue b);
```

Each function inspects `stz_value_type()` and dispatches to the
type-specific implementation. If a structure does not support the
operation, the function returns an error code -- never silent
wrong behavior.

### Walker Generalization

The Walker (Layer 2) does not walk "lists" -- it walks ANY
indexed structure. The same Walker instance works on strings
(character positions), lists (item positions), table rows/cols,
matrix cells, tree levels, and graph traversal orders.

```c
// Walker targets any indexed structure
StzWalkerHandle stz_walker_on(StzValue target, int64_t step);
// Walks characters in a string, items in a list, rows in a
// table, cells in a matrix, nodes in a tree (level-order),
// nodes in a graph (BFS/DFS order)
```

### Splitter Generalization

The Splitter does not split "strings" -- it partitions ANY
structure into sections. A string splits into substrings, a list
into sublists, a table into sub-tables (row groups), a matrix
into sub-matrices (blocks), a tree into subtrees, a graph into
subgraphs (connected components or cuts).

### Conditional Code Generalization

The @CurrentItem/@NextItem mechanism works on ANY walkable
structure, not just lists. It adapts to the structure's topology:
- String: @CurrentChar, @NextChar, @PreviousChar
- List: @CurrentItem, @NextItem, @PreviousItem
- Table: @CurrentRow, @NextRow, @CurrentCol
- Tree: @CurrentNode, @Parent, @FirstChild, @NextSibling
- Graph: @CurrentNode, @Neighbor(n)

---

## Layer 4: Softanza Signature Features

These are the features that define Softanza's identity. Without
them in the Engine, a Python or Rust client gets data structures
but NOT the Softanza experience. These must be Engine-native so
every language surface inherits them automatically.

### Domain-Specific Pattern Matching (the *-ex family) [PLANNED]

Softanza invented regex-like pattern matching for non-string
domains: lists, matrices, numbers, tables, graphs, and time.
The backtracking engine, constraint solver, and pattern compiler
are the same across all domains -- only the token vocabulary
changes.

```c
// Universal pattern matching engine
StzPatternHandle stz_pattern_compile(int domain, const char* pattern,
                                      size_t len);
void             stz_pattern_free(StzPatternHandle h);

// Domain constants
// STZ_DOMAIN_LIST, STZ_DOMAIN_MATRIX, STZ_DOMAIN_NUMBER,
// STZ_DOMAIN_TABLE, STZ_DOMAIN_GRAPH, STZ_DOMAIN_TIME

// Match against domain-specific data
int       stz_pattern_match(StzPatternHandle h, StzValue target);
size_t    stz_pattern_find_all(StzPatternHandle h, StzValue target,
                                StzValue* out_matches, size_t max);
double    stz_pattern_similarity(StzPatternHandle h, StzValue target);
```

**Listex tokens:** `@N` (number), `@S` (string), `@L` (list),
`@$` (any), quantifiers `+*?{n}{n-m}`, uniqueness `{...}U`,
negation `@!`, alternation `|`.

**Numbrex tokens:** `@digit`, `@factor`, `@property(prime|even|
fibonacci|palindrome|perfect|square|triangular|abundant)`,
`@part(integer|fractional)`, `@relation(mod:N=R)`, `@approx`.

**Matrex tokens:** `@size(RxC)`, `@shape(square|wide|tall)`,
`@element(range)`, `@property(symmetric|diagonal|identity|
upper|lower)`, `@determinant`, `@row`, `@col`, `@diagonal`.

**Tablex tokens:** `@rows`, `@cols`, `@coltype`, `@sorted`,
`@unique`, `@duplicates`, `@completeness`, `@sumcol`, `@avgcol`.

**Graphex tokens:** `@Node(label)`, `@Edge(label)`, `@Cycle`,
`@Path`, with quantifiers and alternation.

**Timex tokens:** `@Instant`, `@Duration(1h30min)`, `@Event`,
`@Sequence`, `@Frame`, cyclic `~` suffix.

**Engine internals needed:**
- Backtracking engine with constraint propagation
- Number theory: primality, factorization, Fibonacci check
- Matrix property detection (symmetry, triangularity)
- Graph substructure matching
- Duration arithmetic and temporal reasoning

```c
// Number theory (used by Numbrex, stzNumber)
int       stz_math_is_prime(int64_t n);
int64_t*  stz_math_factorize(int64_t n, size_t* out_count);
int       stz_math_is_fibonacci(int64_t n);
int       stz_math_is_perfect(int64_t n);
int       stz_math_is_palindrome(int64_t n);
int64_t   stz_math_gcd(int64_t a, int64_t b);
int64_t   stz_math_lcm(int64_t a, int64_t b);
```

### Natural Language Programming [PLANNED]

Softanza lets users write code in human language. The Engine
provides the parsing, tokenization, and semantic mapping so ANY
language surface can offer natural coding -- not just Ring.

```c
// Language definition loading
StzNatLangHandle stz_natlang_new(void);
void             stz_natlang_free(StzNatLangHandle h);
int  stz_natlang_load_language(StzNatLangHandle h,
                                const char* lang_id,
                                const char* definitions_json,
                                size_t len);

// Parsing natural code to structured operations
size_t stz_natlang_parse(StzNatLangHandle h,
                          const char* natural_code, size_t len,
                          StzNatOp* out_operations, size_t max);

typedef struct {
    int kind;             // CREATE, CALL, OUTPUT, ASSIGN, ...
    char target[256];     // object or variable name
    char method[256];     // method to call
    char args[1024];      // serialized arguments
} StzNatOp;

// Context interpolation
size_t stz_natlang_interpolate(const char* template_str, size_t len,
                                const char** keys,
                                const StzValue* values,
                                size_t num_vars,
                                char* output, size_t out_len);

// Smart tokenization (protects strings and lists)
size_t stz_natlang_tokenize(const char* input, size_t len,
                             StzStringHandle* out_tokens,
                             size_t max);
```

**Language definition format (JSON):**
```json
{
  "lang": "english",
  "ignored_words": ["the", "a", "an", "to", "of"],
  "mappings": {
    "create": "CREATE_OBJECT",
    "uppercase": "METHOD_UPPERCASE",
    "show": "OUTPUT_DISPLAY",
    "reverse": "METHOD_REVERSE"
  }
}
```

Any language can load definitions for English, French, Hausa,
Arabic, or any other human language and get natural coding.

### Conditional Code Transpiler [PLANNED]

The W()/WXT() mechanism transpiles rich keywords like
`@CurrentItem`, `@NextItem`, `@PreviousItem` into executable
indexing operations. The transpiler handles boundary detection
(no @NextItem at list end) and performance optimization.

```c
// Transpile conditional code keywords
size_t stz_ccode_transpile(const char* expression, size_t len,
                            size_t collection_size,
                            size_t current_index,
                            char* output, size_t out_len);

// Keyword table:
// @CurrentItem    -> collection[current_index]
// @NextItem       -> collection[current_index + 1]
// @PreviousItem   -> collection[current_index - 1]
// @i              -> current_index
// @NumberOfItems  -> collection_size
// @FirstItem      -> collection[1]
// @LastItem       -> collection[collection_size]

// Boundary-safe evaluation
int stz_ccode_has_next(size_t current_index, size_t collection_size);
int stz_ccode_has_previous(size_t current_index);

// Compiled conditional for repeated evaluation (avoids re-parsing)
StzCCodeHandle stz_ccode_compile(const char* expression, size_t len);
void           stz_ccode_free(StzCCodeHandle h);
StzValue       stz_ccode_eval(StzCCodeHandle h,
                               StzListHandle collection,
                               size_t current_index);
```

### Constraint Engine [PLANNED]

Declarative constraints on any StzValue. The Engine validates
constraints so every language surface gets the same guarantees.

```c
StzConstraintHandle stz_constraint_new(void);
void                stz_constraint_free(StzConstraintHandle h);

// Add rules
void stz_constraint_add_rule(StzConstraintHandle h,
                              const char* expression, size_t len);
// e.g. "@.IsLowercase", "@.NumberOfChars > 3", "@.IsNotEmpty"

// Validate a value against all rules
int  stz_constraint_check(StzConstraintHandle h, StzValue v);

// Get violation details
size_t stz_constraint_violations(StzConstraintHandle h, StzValue v,
                                  char* out_messages, size_t out_len);
```

### Reactive Attribute System [PLANNED]

Engine-level attribute change detection and callback dispatch.
Any language surface can build reactive objects on top.

```c
StzReactiveHandle stz_reactive_new(void);
void              stz_reactive_free(StzReactiveHandle h);

// Define watched attributes
void stz_reactive_watch(StzReactiveHandle h,
                         const char* attr_name,
                         void (*callback)(const char* attr,
                                          StzValue old_val,
                                          StzValue new_val,
                                          void* userdata),
                         void* userdata);

// Set attribute (triggers watchers)
void stz_reactive_set(StzReactiveHandle h,
                       const char* attr_name, StzValue value);

// Get attribute
StzValue stz_reactive_get(StzReactiveHandle h,
                           const char* attr_name);

// Computed attributes (auto-recalculate on dependency change)
void stz_reactive_computed(StzReactiveHandle h,
                            const char* attr_name,
                            const char** dependencies,
                            size_t num_deps,
                            StzValue (*compute)(StzReactiveHandle h,
                                                void* userdata),
                            void* userdata);

// Batch mode (accumulate changes, fire callbacks once)
void stz_reactive_batch_start(StzReactiveHandle h);
void stz_reactive_batch_end(StzReactiveHandle h);

// Two-way binding between reactive objects
void stz_reactive_bind(StzReactiveHandle source,
                        const char* source_attr,
                        StzReactiveHandle target,
                        const char* target_attr);
```

### Knowledge Graph Engine [PLANNED]

RDF-style semantic graph with inference and SPARQL-like queries.
Distinct from the structural graph (Layer 1) because it adds
semantic reasoning, ontology, and inference rules.

```c
StzKGHandle stz_kg_new(void);
void        stz_kg_free(StzKGHandle h);

// Facts (triples)
void stz_kg_add_fact(StzKGHandle h,
                      const char* subject, size_t s_len,
                      const char* predicate, size_t p_len,
                      const char* object, size_t o_len);
size_t stz_kg_fact_count(StzKGHandle h);

// Query with variable binding (?x, ?y)
size_t stz_kg_query(StzKGHandle h,
                     const char* subject,   // or "?x"
                     const char* predicate,  // or "?p"
                     const char* object,     // or "?o"
                     StzKGResult* out_results, size_t max);

typedef struct {
    char subject[256];
    char predicate[256];
    char object[256];
} StzKGResult;

// Multi-hop query (reasoning chain)
size_t stz_kg_query_path(StzKGHandle h,
                          const StzKGResult* patterns,
                          size_t num_patterns,
                          StzKGResult* out_results, size_t max);

// Inference rules
void stz_kg_add_rule(StzKGHandle h,
                      const char* rule_json, size_t len);
size_t stz_kg_infer(StzKGHandle h); // returns new facts derived

// Ontology
void stz_kg_define_class(StzKGHandle h,
                          const char* class_name, size_t len,
                          const char* parent_class, size_t p_len);
void stz_kg_define_property(StzKGHandle h,
                             const char* prop_name, size_t len,
                             const char* domain, size_t d_len,
                             const char* range, size_t r_len);

// Analysis
size_t stz_kg_similar_to(StzKGHandle h,
                          const char* entity, size_t len,
                          StzKGResult* out_similar, size_t max);
```

### Universal Splitter & Counter [PLANNED]

The Splitter operates on ANY data structure, not just strings.
It partitions the structure into sections based on position
arithmetic, delimiter matching, or predicate functions.

```c
// --- Position-arithmetic splitting (works on any indexed structure) ---

// Split a structure of total_size at given positions
size_t stz_split_at(size_t total_size,
                     const size_t* split_points, size_t num_points,
                     size_t* out_sections, size_t max);
                     // out_sections: pairs [start, end, start, end, ...]

// Split into N equal parts
size_t stz_split_into(size_t total_size, size_t num_parts,
                       size_t* out_sections, size_t max);

// --- Structure-aware splitting (adapts to topology) ---

// Split any StzValue by a delimiter value
// String: split by substring -> list of substrings
// List: split by item -> list of sublists
// Table: split by column value -> list of sub-tables
StzValue stz_split_by(StzValue source, StzValue delimiter);

// Split by predicate (items where predicate returns true become boundaries)
StzValue stz_split_where(StzValue source,
                          int (*predicate)(StzValue item, void* ctx),
                          void* ctx);

// --- Deep structure splitting ---

// Tree: split at node -> forest of subtrees
StzValue stz_tree_split_at_node(StzTreeHandle h, size_t node_id);

// Graph: split into connected components
StzValue stz_graph_split_components(StzGraphHandle h);

// Graph: split by edge removal (min-cut)
StzValue stz_graph_split_mincut(StzGraphHandle h,
                                 size_t source, size_t sink);

// Matrix: split into blocks
StzValue stz_matrix_split_blocks(StzMatrixHandle h,
                                  size_t block_rows, size_t block_cols);

// Grid: split into regions (flood-fill based)
StzValue stz_grid_split_regions(StzValue grid);

// --- Counter: generate count sequences with rules ---

size_t stz_counter(size_t start, size_t step,
                    size_t restart_at, size_t restart_to,
                    size_t skip_every, size_t total,
                    size_t* out_counts, size_t max);
```

### String Art Renderer [PLANNED]

Multi-layer ASCII art generation at native speed.

```c
// Render text to ASCII art
size_t stz_stringart_render(const char* text, size_t len,
                             const char* style,
                             char* output, size_t out_len);

// Get available styles
size_t stz_stringart_styles(const char** out_names, size_t max);

// Load custom style (JSON character map)
int stz_stringart_load_style(const char* name,
                              const char* style_json, size_t len);
```

### Unified Display Engine [PLANNED]

Every Softanza class has a `Show()` method producing ASCII visual
output. Currently each class implements its own rendering -- 30+
independent implementations with duplicated box-drawing, alignment,
padding, and formatting logic. The Engine unifies ALL visual
rendering into a single canvas-based display system.

**What it replaces:** stzBoxedString (boxing), stzTable (bordered
tables), stzGrid/stzTile (2D grids with obstacles), stzTree
(hierarchical indented trees), stzGraphAsciiVisualizer (graph
drawings), stzTimeLine (multi-canvas timelines), stzCalendar
(month grids), stzFolder (directory trees), stzMatrix (bracket
notation), stzHistogram/stzBarPlot/stzScatterPlot/stzSurfacePlot
(charts), stzPivotTable (multi-dimensional tables), stzStringArt
(ASCII art), VizFind (highlight-with-carets).

**Design:** One canvas, one renderer, one box-drawing engine.
Every data structure serializes its visual intent into a display
tree, and the display engine renders it to ASCII text.

```c
// --- Canvas: the universal rendering surface ---

StzCanvasHandle stz_canvas_new(size_t width, size_t height);
void            stz_canvas_free(StzCanvasHandle h);
void            stz_canvas_resize(StzCanvasHandle h,
                                   size_t width, size_t height);

// Place text at position
void stz_canvas_text(StzCanvasHandle h, size_t x, size_t y,
                      const char* text, size_t len);

// Draw primitives
void stz_canvas_hline(StzCanvasHandle h, size_t x, size_t y,
                       size_t length, char ch);
void stz_canvas_vline(StzCanvasHandle h, size_t x, size_t y,
                       size_t length, char ch);
void stz_canvas_fill(StzCanvasHandle h, size_t x, size_t y,
                      size_t w, size_t h_size, char ch);

// Render canvas to string
size_t stz_canvas_render(StzCanvasHandle h, char* buf, size_t buf_len);

// --- Box Drawing Engine ---

// Box styles
// STZ_BOX_ASCII:   +--+    STZ_BOX_ROUNDED: ╭──╮
//                  |  |                      │  │
//                  +--+                      ╰──╯
// STZ_BOX_HEAVY:   ┏━━┓   STZ_BOX_DOUBLE:  ╔══╗
//                  ┃  ┃                      ║  ║
//                  ┗━━┛                      ╚══╝

void stz_canvas_box(StzCanvasHandle h, size_t x, size_t y,
                     size_t w, size_t h_size, int style);

// Box with title
void stz_canvas_titled_box(StzCanvasHandle h, size_t x, size_t y,
                            size_t w, size_t h_size, int style,
                            const char* title, size_t title_len);

// --- Universal Show(): render any StzValue to ASCII ---

// The single function that replaces 30+ class-specific Show()
size_t stz_show(StzValue v, int format, char* buf, size_t buf_len);

// Format constants:
// STZ_SHOW_COMPACT     -> "[ 1, 2, 3 ]"
// STZ_SHOW_EXPANDED    -> multi-line indented
// STZ_SHOW_BOXED       -> with box-drawing border
// STZ_SHOW_TABLE       -> tabular format (for lists of lists, tables)
// STZ_SHOW_TREE        -> hierarchical indent (for trees, nested lists)
// STZ_SHOW_GRAPH       -> node-edge ASCII diagram
// STZ_SHOW_MATRIX      -> bracket notation with alignment
// STZ_SHOW_CALENDAR    -> month grid (for date ranges)
// STZ_SHOW_TIMELINE    -> horizontal timeline (for event sequences)
// STZ_SHOW_CHART       -> histogram/bar/scatter (for numeric data)

// Extended show with options
size_t stz_show_xt(StzValue v, int format,
                    const char* options_json, size_t opts_len,
                    char* buf, size_t buf_len);

// --- VizFind: visual search highlighting ---

// Highlight occurrences of needle in haystack's visual representation
// Works on ANY data structure: strings (caret under chars),
// lists (bracket items), tables (highlight cells), trees (mark nodes),
// graphs (mark nodes/edges), matrices (mark elements)
size_t stz_vizfind(StzValue haystack, StzValue needle,
                    char* buf, size_t buf_len);

// --- Table Rendering ---

// Render a table with headers, borders, and alignment
size_t stz_render_table(const char** headers, size_t num_cols,
                         const StzValue* data, size_t num_rows,
                         int style, char* buf, size_t buf_len);

// --- Tree Rendering ---

// Render a tree with configurable connectors
// Connector styles: "├── └──" (default), "|-- `--", "+-- +--"
size_t stz_render_tree(StzTreeHandle h, int style,
                        char* buf, size_t buf_len);

// --- Graph Rendering ---

// Render graph as ASCII diagram
// Layout algorithms: STZ_LAYOUT_FORCE, STZ_LAYOUT_HIERARCHICAL,
//                    STZ_LAYOUT_CIRCULAR, STZ_LAYOUT_GRID
size_t stz_render_graph(StzGraphHandle h, int layout, int style,
                         char* buf, size_t buf_len);

// --- Chart Rendering ---

// Histogram from numeric data
size_t stz_render_histogram(const double* data, size_t count,
                             size_t width, size_t height,
                             char* buf, size_t buf_len);

// Bar plot (horizontal or vertical)
size_t stz_render_barplot(const char** labels, const double* values,
                           size_t count, int horizontal,
                           size_t width, size_t height,
                           char* buf, size_t buf_len);

// Scatter plot (2D points)
size_t stz_render_scatter(const double* x, const double* y,
                           size_t count,
                           size_t width, size_t height,
                           char* buf, size_t buf_len);

// --- Composite Layouts ---

// Stack multiple rendered outputs vertically or horizontally
size_t stz_layout_stack(const char** panels, const size_t* widths,
                         size_t count, int direction,
                         char* buf, size_t buf_len);
// direction: STZ_LAYOUT_VERTICAL, STZ_LAYOUT_HORIZONTAL
```

**Engine internals needed:**
- Unicode-aware column width calculation (CJK = 2 columns)
- Box-drawing character intersection resolution (when lines cross)
- Automatic width detection (terminal width query or configurable)
- Alignment engine (left/right/center per column)
- Color-free by default (pure ASCII), optional ANSI escape codes
  via stz_show_xt options

### Generalizable Feature Inventory

Beyond Splitter and Display, these features must generalize:

**Sections/Slicing** -- Extract contiguous sub-structures from
ANY collection. `stz_section(v, from, to)` returns a substring,
sublist, sub-table (row range), sub-matrix (block), subtree
(rooted at node), or subgraph (induced by node set).

**Merge/Concatenate** -- Combine two structures of the same type.
`stz_merge(a, b)` concatenates strings, appends lists, unions
tables (append rows), block-diagonal matrices, graft trees,
union graphs.

**Flatten/Deepen** -- Convert between nested and flat
representations. `stz_flatten(v)` works on nested lists,
trees (to list), graphs (to edge list), hierarchical tables
(to flat rows).

**Sort** -- `stz_sort(v, key, ascending)` sorts strings
(characters), lists (items), tables (by column), matrices
(by row sum/column).

**Filter/Select** -- `stz_filter(v, predicate)` filters items
in lists, rows in tables, nodes in graphs/trees, elements in
matrices.

**Map/Transform** -- `stz_map(v, transform)` applies a function
to every element: characters in strings, items in lists, cells
in tables/matrices, nodes in trees/graphs.

**Reduce/Aggregate** -- `stz_reduce(v, combine, initial)` folds
over any collection: sum characters (codepoints), reduce list,
aggregate table column, sum matrix, accumulate tree values.

**Serialize/Deserialize** -- `stz_to_json(v)` and
`stz_from_json(json)` work on ANY StzValue, preserving type
information. Every data structure round-trips through JSON.

**Compare/Diff** -- `stz_diff(a, b)` produces a structural diff:
string diff (character-level), list diff (item-level), table
diff (row/cell-level), tree diff (node edit distance), graph
diff (edge additions/removals).

**Copy/Clone** -- `stz_clone(v)` deep-copies any StzValue,
including nested structures.

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

### Phase G: Infrastructure Services

| Priority | Module          | Replaces                               |
|----------|-----------------|----------------------------------------|
| G.1      | Crypto/Hash     | stzCrypto external libs (SHA/AES/RSA)  |
| G.2      | Text Encoding   | stzTextEncoding 38+ codecs             |
| G.3      | Compression     | stzZipFile external zip library        |
| G.4      | Streaming I/O   | stzTextStream buffered codec chains    |
| G.5      | File Events     | stzFolderWatcher libuv dependency      |
| G.6      | Process Mgmt    | stzExterCode manual process spawning   |
| G.7      | Async/Event Loop| stzReactive libuv dependency           |
| G.8      | UUID            | stzUUID manual generation              |
| G.9      | URL Parsing     | stzUrl manual string parsing           |
| G.10     | HTML/XML DOM    | stzHtml manual string parsing          |
| G.11     | RNG             | Solvers, crypto, Monte Carlo needs     |
| G.12     | Solvers         | NSGA-II, Monte Carlo, linear systems   |
| G.13     | Geospatial      | stzGeoMap coordinate calculations      |
| G.14     | Bit/Byte Ops    | stzBit/stzByte/stzListOfBits           |
| G.15     | Expression Eval | Ring eval(), stzConstraint, stzQEngine |
| G.16     | Func Registry   | Method naming grammar, alternatives,   |
|          |                 | multilingual names, bridge generation   |
| G.17     | Cache Engine    | Function-level caching (mem/file/mmap) |
| G.18     | Log Engine      | Function-level tracing with context    |
| G.19     | Profiler Engine | Timing, call counts, call graph        |
| G.20     | Callstack Viz   | Visual error reporting, execution path |

### Phase H: Softanza Signature Features

These are what make the Engine more than a utility library.
Without them, foreign languages get data structures; WITH them,
they get the Softanza experience.

| Priority | Module           | What It Brings                          |
|----------|------------------|-----------------------------------------|
| H.1      | Pattern Matching | Universal *-ex engine (list/matrix/     |
|          |                  | number/table/graph/time patterns)       |
| H.2      | Number Theory    | Primality, factorization, Fibonacci,    |
|          |                  | perfect numbers (used by Numbrex)       |
| H.3      | Natural Language | Parse human-language code to operations, |
|          |                  | multi-language definitions, interpolation|
| H.4      | CCode Transpiler | Compile @CurrentItem/@NextItem keywords |
|          |                  | to boundary-safe indexed access         |
| H.5      | Constraint Engine| Declarative rule validation on any value |
| H.6      | Reactive System  | Attribute watching, computed properties, |
|          |                  | two-way binding, batch mode             |
| H.7      | Knowledge Graph  | RDF triples, SPARQL-like queries,       |
|          |                  | inference rules, ontology               |
| H.8      | Splitter/Counter | Universal splitting across all types,   |
|          |                  | conditional counting with restart/skip  |
| H.9      | String Art       | Multi-layer ASCII art rendering         |
| H.10     | Display Engine   | Unified canvas, box-drawing, charts,    |
|          |                  | table/tree/graph rendering, VizFind     |
| H.11     | Universal Ops    | Generic Find/Replace/Sort/Filter/Map/   |
|          |                  | Reduce/Diff/Clone dispatched on StzValue|

### Phase I: Engine as Universal Substrate

Once Phases F+G+H are complete, the Engine becomes
language-agnostic AND experience-complete:

- **Ring** binds via `stzengine.ring` (LoadLib + GetCFunc)
- **Zin** (Zig) calls Engine modules directly (no FFI overhead)
- **Python** binds via `ctypes` or `cffi`
- **Rust** binds via `extern "C"` declarations
- **Go** binds via `cgo`
- **Any C-compatible language** gets the full Softanza experience

The Engine IS the product. The language surfaces are thin skins.

### Module Count Summary

| Phase | Modules | Status    | What                      |
|-------|---------|-----------|---------------------------|
| A-E   | 11      | DONE      | Qt replacement            |
| F     | 13      | PLANNED   | Ring workaround elimination|
| F+    | 3       | PLANNED   | Checker/Yielder/Performer |
| G     | 20      | PLANNED   | Infrastructure + manageability |
| H     | 11      | PLANNED   | Signature features        |
| **Total** | **58** | **11 done, 47 planned** |

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
