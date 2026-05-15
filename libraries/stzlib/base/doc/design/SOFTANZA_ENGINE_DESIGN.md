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

### Function Registry & Execution Model [PLANNED]

Softanza's 6000+ methods are not hand-coded -- they follow a
systematic grammar of **23 function forms**, each representing a
distinct computational semantic. The Engine codifies these forms
as execution model primitives so ANY language surface reproduces
the full Softanza experience from a compact base of operations.

**The 23 Function Forms (each is an execution mode, not a name):**

| # | Form           | Semantic                  | Engine Primitive         |
|---|----------------|---------------------------|--------------------------|
| 1 | Active         | `Remove("x")` mutates     | In-place mutation        |
| 2 | Passive        | `Removed("x")` copies     | Copy-on-write return     |
| 3 | Fluent         | `Q().A().B().C()`         | Pipeline with COW chain  |
| 4 | Immutable      | `RemoveQC("x")` safe chain| Clone-then-chain         |
| 5 | Partial        | `@("x").@Removed()`      | Context stack (focus)    |
| 6 | Plural         | `RemoveMany(["x","y"])`   | Array-arg dispatch       |
| 7 | Exceptional    | `...Except("_")`          | Predicate + exclusions   |
| 8 | Negative       | `IsNotLetter()`           | Auto-negation            |
| 9 | Alternative    | `Swap` = `SwapItems`      | Semantic alias table     |
|10 | Named Params   | `:At = 1, :And = 3`       | Named param binding      |
|11 | Conditional    | `RemoveW('expr')`         | Expr evaluator as filter |
|12 | Suffixes       | `CS()`, `XT()`, `Q()`     | Behavior modifiers       |
|13 | Future         | `UppercasingFQ()`         | Deferred action queue    |
|14 | Random         | `rndItems()`              | RNG-integrated ops       |
|15 | Deep           | `DeepFind()` -> paths     | Recursive w/ path tracking|
|16 | Multilingual   | `DernierCaractère()`      | Language-mapped dispatch |
|17 | Free Form (FF) | `SectionFF([:To=11])`     | Named params, any order  |
|18 | Default (dft)  | `dftRange()`              | Execute with all defaults|
|19 | Info (inf)     | `infRange()` -> metadata  | Function introspection   |
|20 | Free Order     | `FindNth(2,"r")=FindNth("r",2)` | Type-based param reorder|
|21 | Misspelled     | `WithoutSapces()`         | Fuzzy name matching      |
|22 | Statement (X)  | `AllInQX([]).AreNegativeX()` | Quantified assertions |
|23 | Visual (viz)   | `vizFindAll("I")`         | Display Engine dispatch  |

Planned future forms:
- **Timed**: Functions with lifecycle (birth, TTL, expiry)
- **Cached**: Per-function result memoization (@CacheStore)
- **Versioned**: Multiple implementations selectable by version

These are execution model primitives, not naming conventions. The
Engine implements each as a C ABI facility that any language can
compose.

```c
// --- Execution Model Primitives ---

// Active: mutate target in-place
void stz_op_active(StzValue* target, int operation,
                    const StzValue* args, size_t num_args);

// Passive: copy-on-write, return new value, original untouched
StzValue stz_op_passive(StzValue source, int operation,
                         const StzValue* args, size_t num_args);

// Fluent chain: pipeline of operations with COW semantics
// Each step produces a new value fed to the next step
StzChainHandle stz_chain_new(StzValue initial);
void           stz_chain_free(StzChainHandle h);
StzChainHandle stz_chain_step(StzChainHandle h, int operation,
                               const StzValue* args, size_t num_args);
StzValue       stz_chain_result(StzChainHandle h);
// History: get intermediate values for QH() debugging
size_t         stz_chain_history(StzChainHandle h,
                                  StzValue* out_steps, size_t max);

// Partial form: focus on a sub-part of the target
// Push a context (the part), operate on it, pop back to parent
StzPartialHandle stz_partial_focus(StzValue parent,
                                    StzValue selector);
StzValue  stz_partial_apply(StzPartialHandle h, int operation,
                             const StzValue* args, size_t num_args);
StzValue  stz_partial_restore(StzPartialHandle h);
void      stz_partial_free(StzPartialHandle h);

// Plural: dispatch operation to array of arguments
size_t stz_op_plural(StzValue* target, int operation,
                      const StzValue* items, size_t num_items);

// Exceptional: apply operation with exclusion list
void stz_op_except(StzValue* target, int operation,
                    const StzValue* exceptions, size_t num_exceptions);

// Conditional (W form): filter by expression, then apply
void stz_op_conditional(StzValue* target, int operation,
                         const char* condition_expr, size_t len);

// Future/Deferred: queue operations for later execution
StzFutureHandle stz_future_new(StzValue initial);
void            stz_future_free(StzFutureHandle h);
void  stz_future_queue(StzFutureHandle h, int operation,
                        const StzValue* args, size_t num_args);
StzValue stz_future_execute(StzFutureHandle h); // runs all queued

// Random form: randomized variant of any operation
StzValue stz_op_random(StzValue source, int operation,
                        size_t count); // 0 = random count too

// --- Forms 14-23: Additional Execution Primitives ---

// Immutable chain (QC): clone source THEN chain (original safe)
StzChainHandle stz_chain_new_immutable(StzValue source);
// Identical to stz_chain_new but clones source at creation.
// All chain operations modify the clone, never the original.

// Deep form: recursive operation on nested structures
// Returns paths as list of position-lists: [[1], [3,2], [3,3,1]]
StzValue stz_deep_find(StzValue nested, StzValue needle);
void     stz_deep_replace(StzValue* nested, StzValue old_val,
                           StzValue new_val);
void     stz_deep_remove(StzValue* nested, StzValue target);
StzValue stz_deep_apply(StzValue nested, int operation,
                         StzValue target,
                         const StzValue* args, size_t num_args);
// Deep works on any nested StzValue (lists of lists, trees, etc.)
// It descends into every STZ_LIST child recursively.

// Free Form (FF): named params in any order, defaults for missing
StzValue stz_op_freeform(StzValue* target, int operation,
                          const char** param_names,
                          const StzValue* param_values,
                          size_t num_params);
// Engine resolves param order from names, fills defaults for
// any missing params. Empty param list = all defaults.

// Default form (dft): execute operation with all default values
StzValue stz_op_default(StzValue* target, int operation);

// Info form (inf): return function metadata as structured data
// Returns: list of [name, type, default_value] per parameter
StzValue stz_op_info(int operation);

// Free Order: resolve params by type when order is ambiguous
// e.g. FindNth(2, "ring") = FindNth("ring", 2)
// Engine inspects param types and reorders to match signature.
StzValue stz_op_free_order(StzValue* target, int operation,
                            const StzValue* args, size_t num_args);

// Misspelled form: fuzzy function name resolution
// Uses Levenshtein distance against registry to find closest match
void* stz_registry_resolve_fuzzy(const char* misspelled_name,
                                  size_t len,
                                  char* out_corrected_name,
                                  size_t out_len);

// Statement form (X): quantified logical assertions
// "All items in collection satisfy predicate" -> TRUE/FALSE
int stz_assert_all(StzValue collection,
                    int (*predicate)(StzValue item, void* ctx),
                    void* ctx);
int stz_assert_none(StzValue collection,
                     int (*predicate)(StzValue item, void* ctx),
                     void* ctx);
int stz_assert_some(StzValue collection,
                     int (*predicate)(StzValue item, void* ctx),
                     void* ctx);
// Expression-based variants:
int stz_assert_all_expr(StzValue collection,
                         const char* expr, size_t len);
int stz_assert_none_expr(StzValue collection,
                          const char* expr, size_t len);

// Visual form (viz): dispatch operation result to Display Engine
// viz prefix = run operation + render result visually
size_t stz_op_visual(StzValue source, int operation,
                      const StzValue* args, size_t num_args,
                      char* buf, size_t buf_len);
// e.g. vizFindAll("I") -> "RINGORIALAND\n-^----^-----"
```

```c
// --- Function Registry ---

// Register a base function with its forms and metadata
void stz_registry_add(const char* domain,       // "string"
                       const char* base_name,    // "Remove"
                       uint32_t supported_forms, // bitmask of 23 forms
                       void* active_fn,          // mutating version
                       void* passive_fn,         // copy-on-write version
                       const char* params_json,  // param metadata for
                       size_t params_len);       // FF/dft/inf forms

// Expand one base name into all valid form names
// Remove -> Remove, Removed, RemoveQ, RemoveMany,
//           RemoveManyCS, RemoveW, RemoveWXT, RemoveExcept,
//           rndRemove, rndRemoveN, RemoveFQ, ...
size_t stz_registry_expand(const char* base_name,
                            char** out_names, size_t max);

// Register semantic alternatives for a base function
void stz_registry_alias(const char* base_name,
                         const char** aliases, size_t num_aliases);
// e.g. "Remove" -> ["RemoveItem", "RemoveChar", "Delete"]

// Register multilingual name mapping
void stz_registry_translate(const char* base_name,
                             const char* language,
                             const char* translated_name);
// e.g. "Remove", "french", "Supprimer"
// e.g. "Find", "arabic", "ابحث"

// Lookup function by any form/alias/translation
void* stz_registry_resolve(const char* name, size_t len,
                            int* out_form); // which form was used

// Generate bridge code for a target language
size_t stz_registry_generate_bridge(const char* language,
                                     char* buf, size_t buf_len);

// List all registered functions for a domain
size_t stz_registry_list(const char* domain,
                          char** out_names, size_t max);
```

**Naming grammar rules (Engine-enforced):**

Prefixes:
- Positional: `FindFirst`, `FindLast`, `FindNth`, `FindAll`
- Random: `rndFind`, `rndFindN`, `rndRemove`, `rndRemoveN`
- Visual: `vizFind`, `vizFindAll`, `vizFindBoxed`
- Default: `dftRange`, `dftSection`, `dftFind`
- Info: `infRange`, `infSection` (returns param metadata)
- Deep: `DeepFind`, `DeepReplace`, `DeepRemove`

Suffixes:
- `CS` (case-sensitive), `XT` (extended params), `Q` (fluent)
- `QC` (fluent + immutable copy), `QH` (fluent + history trace)
- `W` (conditional/where), `WXT` (conditional extended)
- `FQ` (future/deferred + fluent), `FF` (future double-fire)
- `FF` also = Free Form (context-dependent: on function names
  not in a chain, FF means free-form params)
- `X` (statement/assertion form)
- `ST` (starting-at position param)

Structural:
- Active/Passive pairs: `Remove` / `Removed`
- Partial prefix: `@Remove` operates on focused sub-part
- Plural: `RemoveMany`, `FindMany`, `ReplaceMany`
- Exceptional: `RemoveExcept`, `RemoveNonLettersExcept`
- Negative: `IsNot*`, `DoesNotContain`, `IsNotIn*`
- Deep: `DeepFind`, `DeepRemove`, `DeepReplace`

Semantic alternatives:
- `Swap(1,3)` = `SwapItems(1,3)` = `SwapChars(1,3)`
- `Size()` = `NumberOfChars()` = `NumberOfItems()`

Named parameters:
- `:AtPosition`, `:And`, `:With`, `:In`, `:From`, `:To`
- `:CaseSensitive = TRUE/FALSE`, `:StartingAt`
- `:Of`, `:By`, `:Except`

Parameter metadata (per function, for FF/dft/inf):
```json
{
  "params": [
    { "name": "pnStart", "label": "from", "type": "NUMBER", "default": 1 },
    { "name": "pnEnd",   "label": "to",   "type": "NUMBER", "default": -1 }
  ]
}
```

Multilingual aliases:
- `Find` = `Chercher` (French) = `ابحث` (Arabic) = `查找` (Chinese)
- Loaded from JSON language definition files

Misspelled tolerance:
- `WithoutSapces()` resolves to `WithoutSpaces()`
- Engine uses Levenshtein distance <= 2 against registry

The registry generates ~60-120 valid names per base function.
With ~150 base functions across all domains, this produces the
full 6000+ method vocabulary automatically.

**Engine design consequence:** Every base Engine operation (Find,
Replace, Remove, Insert, Sort, etc.) is implemented ONCE in Zig.
The 23 forms are compositional wrappers that the registry applies
mechanically. A Python client calling `stz_op_passive(s, REMOVE,
args)` gets the same copy-on-write behavior as Ring's `Removed()`.
A Rust client calling `stz_deep_find(nested, needle)` gets the
same recursive path-tracking as Ring's `DeepFind()`. The forms
are the Engine's gift to every language surface.

### Small Functions Engine [PLANNED]

Softanza's small functions (`Q()`, `@@()`, `@()`, `QH()`, etc.)
are not syntactic sugar -- they are the ergonomic connective tissue
that makes fluent coding possible. The Engine must provide them
natively.

```c
// Q(): elevate any raw value to a managed StzValue
// Q(5) -> StzNumber, Q("Hi") -> StzString, Q([1,2]) -> StzList
StzValue stz_q(StzValue raw);

// @@(): readable string representation of any value
// Especially for deep nested lists: @@([1,[2,3],4]) -> "[ 1, [ 2, 3 ], 4 ]"
size_t stz_show_readable(StzValue v, char* buf, size_t buf_len);

// QH(): chain with history -- returns all intermediate steps
// QH(12500).Add(500).RetrieveQ(1500).DivideByQ(500).MultiplyByQ(2).History()
// -> [ 13000, 11500, 23, 46 ]
size_t stz_chain_history(StzChainHandle h,
                          StzValue* out_steps, size_t max);

// L(), S(), N(): quick creators
StzValue stz_quick_list(const char* spec, size_t len);
// L('"v1":"v3"') -> ["v1", "v2", "v3"]
StzValue stz_quick_string(const char* spec, size_t len);
// S() -> ""
StzValue stz_quick_number(int64_t n);
// N() -> 0

// V(), Vr(), Vl(): value inspection utilities
size_t stz_inspect(StzValue v, char* buf, size_t buf_len);
```

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

---

## Layer 5: Paradigm Engines

Softanza rethinks every programming concept from first principles.
These are not wrappers around existing paradigms -- they are NEW
computational models that the Engine must make available natively.

### Reaxis Engine (Container -> Stream -> Rfunction) [PLANNED]

Softanza's Reaxis model replaces the Observable/Subscriber/
Backpressure triad with three simpler abstractions: Container
(data source), Stream (flow channel), and Rfunction (declarative
function waiting for data). "Reactive programming" becomes
"programming with functions that react."

**Terminology decisions (Engine-enforced):**
- Container (not Observable) -- any data source
- Stream (not Channel/Pipe) -- flow of StzValues
- Rfunction (not Subscriber/Observer) -- function in waiting state
- Overflow (not Backpressure) -- when data arrives too fast
- Feed/FeedMany (not emit/push) -- explicit data routing

```c
// --- Container: any data source wrapped for reactivity ---

StzContainerHandle stz_container_new(StzValue initial_data);
void               stz_container_free(StzContainerHandle h);
void  stz_container_update(StzContainerHandle h, StzValue new_data);
StzValue stz_container_value(StzContainerHandle h);

// --- Stream: flow channel connecting containers to rfunctions ---

StzStreamHandle stz_stream_new(StzContainerHandle source);
void            stz_stream_free(StzStreamHandle h);

// Stream optimization hints (Engine tunes buffer/batch behavior)
void stz_stream_set_hint(StzStreamHandle h, int hint);
// STZ_STREAM_HINT_NETWORK     -- larger buffers, batch arrival
// STZ_STREAM_HINT_FILE        -- sequential read, predictable size
// STZ_STREAM_HINT_SENSOR      -- high frequency, small payloads
// STZ_STREAM_HINT_USER_INPUT  -- low frequency, immediate dispatch
// STZ_STREAM_HINT_DATABASE    -- query result sets, typed rows
// STZ_STREAM_HINT_MEMORY      -- in-process, zero-copy possible

// Overflow strategies (when rfunctions can't keep up)
void stz_stream_set_overflow(StzStreamHandle h, int strategy);
// STZ_OVERFLOW_DROP_NEWEST    -- discard incoming when full
// STZ_OVERFLOW_DROP_OLDEST    -- discard buffered when full
// STZ_OVERFLOW_BLOCK          -- block producer until consumed
// STZ_OVERFLOW_BUFFER_ALL     -- unbounded buffer (use with care)
// STZ_OVERFLOW_SAMPLE         -- keep every Nth item

// Cross-stream data routing
void stz_stream_feed(StzStreamHandle target, StzValue item);
void stz_stream_feed_many(StzStreamHandle target,
                           const StzValue* items, size_t count);

// Stream lifecycle
void stz_stream_start(StzStreamHandle h);
void stz_stream_stop(StzStreamHandle h);
void stz_stream_pause(StzStreamHandle h);
void stz_stream_resume(StzStreamHandle h);

// --- Rfunction: function in declarative waiting state ---

StzRfunctionHandle stz_rfunction_new(
    void (*handler)(StzValue item, void* ctx),
    void* ctx);
void stz_rfunction_free(StzRfunctionHandle h);

// Attach rfunction to a stream
void stz_stream_attach(StzStreamHandle stream,
                        StzRfunctionHandle rfunc);
void stz_stream_detach(StzStreamHandle stream,
                        StzRfunctionHandle rfunc);

// Per-rfunction error handling (localized, not global)
void stz_rfunction_on_error(StzRfunctionHandle h,
    void (*handler)(StzValue item, const char* error,
                    size_t len, void* ctx),
    void* ctx);
void stz_rfunction_on_success(StzRfunctionHandle h,
    void (*handler)(StzValue result, void* ctx),
    void* ctx);

// --- Natural Timing (replaces SetInterval/SetTimeout/debounce) ---

StzTimerHandle stz_run_every(StzStreamHandle stream,
                              uint64_t interval_ms,
                              void (*callback)(void* ctx),
                              void* ctx);
StzTimerHandle stz_run_after(StzStreamHandle stream,
                              uint64_t delay_ms,
                              void (*callback)(void* ctx),
                              void* ctx);
void stz_stop_timer(StzTimerHandle h);

// WaitForAttributeToSettle: debounce with semantic name
StzTimerHandle stz_wait_for_settle(StzStreamHandle stream,
                                    uint64_t quiet_period_ms,
                                    void (*callback)(StzValue settled,
                                                     void* ctx),
                                    void* ctx);
```

### Softanzuter (Universal Reactive Computation Medium) [PLANNED]

The stzRegexuter showed that regex can be MORE than pattern
matching -- it can be a reactive computation medium with triggers,
computations, state tracking, and dependency chains. The
Softanzuter generalizes this: ANY pattern language (regex, listex,
numbrex, graphex, timex, or custom) becomes a computation medium
where data flows through pattern triggers, each triggering
computations that update shared state.

This is the foundation for building intelligent agents and
reactive systems declaratively.

```c
// --- Softanzuter: universal reactive computation engine ---

StzSoftanzuterHandle stz_softanzuter_new(void);
void                 stz_softanzuter_free(StzSoftanzuterHandle h);

// Register a trigger (pattern that activates computation)
void stz_softanzuter_add_trigger(StzSoftanzuterHandle h,
    const char* name, size_t name_len,
    int pattern_domain,           // STZ_DOMAIN_REGEX, _LIST, _NUMBER...
    const char* pattern, size_t pattern_len);

// Register computation code for a trigger
void stz_softanzuter_add_computation(StzSoftanzuterHandle h,
    const char* trigger_name, size_t name_len,
    void (*compute)(StzValue match, StzSoftanzuterHandle ctx,
                    void* userdata),
    void* userdata);

// Process input through all triggers
size_t stz_softanzuter_process(StzSoftanzuterHandle h,
                                StzValue input);
// Returns number of triggers that fired

// State management (shared across computations)
void     stz_softanzuter_set_state(StzSoftanzuterHandle h,
                                    const char* key, size_t key_len,
                                    StzValue value);
StzValue stz_softanzuter_get_state(StzSoftanzuterHandle h,
                                    const char* key, size_t key_len);

// Dependency tracking (which triggers affect which)
size_t stz_softanzuter_dependencies(StzSoftanzuterHandle h,
    const char* trigger_name, size_t name_len,
    char** out_dependents, size_t max);

// Computation results and match history
StzValue stz_softanzuter_last_matches(StzSoftanzuterHandle h,
    const char* trigger_name, size_t name_len);
StzValue stz_softanzuter_last_result(StzSoftanzuterHandle h,
    const char* trigger_name, size_t name_len);

// --- Specialized Softanzuter variants ---

// Genetic: evolve trigger patterns toward fitness criteria
void stz_softanzuter_evolve(StzSoftanzuterHandle h,
    double (*fitness)(StzSoftanzuterHandle h, void* ctx),
    void* ctx,
    size_t generations, size_t population);

// Linguistic: triggers are grammar rules, input is tokenized text
void stz_softanzuter_set_grammar(StzSoftanzuterHandle h,
    const char* grammar_json, size_t len);

// Quantic: triggers have probability weights, fire probabilistically
void stz_softanzuter_set_probability(StzSoftanzuterHandle h,
    const char* trigger_name, size_t name_len,
    double probability);
```

**Why this matters:** A Python developer creates a Softanzuter
with regex triggers for log analysis. A Zin developer creates one
with listex triggers for data validation pipelines. A Ring
developer creates one with graphex triggers for network
monitoring. Same Engine, same C ABI, different pattern domains.
The Softanzuter IS the Softanza way of building agents -- declare
triggers, declare computations, feed data, let the engine react.

### Truth Engine (Configurable Semantic Truth) [PLANNED]

Standard truth (empty = false, zero = false) is too blunt.
Softanza's IsTrueXT lets programs define what truth means in
their domain. A medical system might treat "N/A" as false. A
survey tool might treat ["X"] as false in a checklist.

```c
StzTruthHandle stz_truth_new(void);
void           stz_truth_free(StzTruthHandle h);

// Configure what makes a string false
void stz_truth_add_false_substrings(StzTruthHandle h,
    const char** substrings, const size_t* lengths, size_t count);
// e.g. "false", "wrong", "no", "N/A", "null"

// Configure what makes a list item false
void stz_truth_add_false_items(StzTruthHandle h,
    const StzValue* items, size_t count);
// e.g. "X", 0, NULL

// Configure deep falsification (items in nested lists)
void stz_truth_add_false_inner_items(StzTruthHandle h,
    const StzValue* items, size_t count);

// Evaluate truth with configuration
int stz_truth_eval(StzTruthHandle h, StzValue v);

// Standard truth (Ring semantics, no config)
int stz_truth_standard(StzValue v);
```

### Quantifier Engine (Probabilistic Natural Proportions) [PLANNED]

Softanza maps natural-language quantifiers to proportional
operations. "Give me a Few items" means ~10%. "Are Most of
these numbers positive?" means >90%. The thresholds are
configurable per application domain.

```c
StzQuantifierHandle stz_quantifier_new(void);
void                stz_quantifier_free(StzQuantifierHandle h);

// Configure thresholds (defaults shown)
void stz_quantifier_set(StzQuantifierHandle h,
                         int quantifier, double threshold);
// STZ_QUANT_NONE = 0.0,   STZ_QUANT_FEW  = 0.10,
// STZ_QUANT_SOME = 0.30,  STZ_QUANT_HALF = 0.50,
// STZ_QUANT_MOST = 0.90,  STZ_QUANT_ALL  = 1.00

// Sample N% of items from a collection
StzValue stz_quantifier_sample(StzQuantifierHandle h,
                                int quantifier,
                                StzValue collection);
// Few([1,2,...,100]) -> ~10 random items

// Check if quantifier proportion satisfies predicate
int stz_quantifier_check(StzQuantifierHandle h,
                          int quantifier,
                          StzValue collection,
                          int (*predicate)(StzValue item, void* ctx),
                          void* ctx);
// Most(numbers).ArePositive() -> true if >90% positive
```

### Polyglot Bridge (EXCIS Multi-Runtime) [PLANNED]

Softanza orchestrates code across language runtimes -- R for
statistics, Python for ML, Julia for numerics, COBOL for legacy,
AI models for inference. The Engine handles type marshaling,
process management, and result conversion.

```c
StzPolyglotHandle stz_polyglot_new(void);
void              stz_polyglot_free(StzPolyglotHandle h);

// Register a language runtime
void stz_polyglot_register(StzPolyglotHandle h,
    int language,              // STZ_LANG_PYTHON, _R, _JULIA, _COBOL, _AI
    const char* runtime_path,  // path to interpreter/binary
    size_t path_len);

// Execute code in a language, marshal result to StzValue
StzValue stz_polyglot_execute(StzPolyglotHandle h,
    int language,
    const char* code, size_t code_len,
    const StzValue* args, size_t num_args);

// Type marshaling: StzValue <-> language-native format
size_t stz_polyglot_marshal(int language, StzValue v,
                             char* buf, size_t buf_len);
StzValue stz_polyglot_unmarshal(int language,
                                 const char* data, size_t len);

// AI model integration (LLM prompting)
StzValue stz_polyglot_ai_prompt(StzPolyglotHandle h,
    const char* prompt, size_t len,
    const char* model_config_json, size_t config_len);
```

### Refinement Engine (PolyCode) [PLANNED]

Code is not written once -- it is refined. Softanza's PolyCode
marks refinement points in code: parameters, blocks, algorithms,
and functions that can be swapped without rewriting the whole
program. The Engine parses and applies refinements.

```c
StzPolyCodeHandle stz_polycode_new(const char* code, size_t len);
void              stz_polycode_free(StzPolyCodeHandle h);

// Find refinement points in code
size_t stz_polycode_points(StzPolyCodeHandle h,
    StzRefinementPoint* out_points, size_t max);

typedef struct {
    int kind;           // STZ_REFINE_PARAM, _BLOCK, _ALGO, _FUNC
    char name[256];     // refinement point name
    size_t offset;      // position in source
    size_t length;      // extent of refinable region
} StzRefinementPoint;

// Apply a refinement
void stz_polycode_refine(StzPolyCodeHandle h,
    const char* point_name, size_t name_len,
    const char* replacement, size_t repl_len);

// Generate refined output
size_t stz_polycode_render(StzPolyCodeHandle h,
    char* buf, size_t buf_len);
```

### Timeline Engine (Temporal Workspace) [PLANNED]

Time is not a scalar -- it is a structured domain with events,
periods, gaps, overlaps, constraints, and visualization. The
Timeline Engine treats time as a workspace where temporal
entities interact.

```c
StzTimelineHandle stz_timeline_new(const char* start, size_t s_len,
                                    const char* end, size_t e_len);
void              stz_timeline_free(StzTimelineHandle h);

// Add temporal entities
void stz_timeline_add_point(StzTimelineHandle h,
    const char* name, size_t name_len,
    const char* datetime, size_t dt_len);

void stz_timeline_add_span(StzTimelineHandle h,
    const char* name, size_t name_len,
    const char* start, size_t s_len,
    const char* end, size_t e_len);

// Block regions (prevent overlap)
void stz_timeline_block_span(StzTimelineHandle h,
    const char* start, size_t s_len,
    const char* end, size_t e_len);

// Query operations
size_t stz_timeline_overlaps(StzTimelineHandle h,
    StzValue* out_pairs, size_t max);
size_t stz_timeline_gaps(StzTimelineHandle h,
    StzValue* out_gaps, size_t max);
double stz_timeline_coverage(StzTimelineHandle h); // 0.0-1.0

// Render to ASCII (uses Display Engine)
size_t stz_timeline_render(StzTimelineHandle h,
    size_t width, char* buf, size_t buf_len);
```

### Section Merger (Interval Arithmetic) [PLANNED]

Softanza's section operations use three merging strategies that
apply to ANY structure with start/end pairs -- string sections,
list ranges, time spans, table row groups, graph edge sets.

```c
// Three merging strategies for interval pairs [start, end]

// Inclusive: merge only contained intervals (A inside B -> B)
size_t stz_sections_merge_inclusive(
    const size_t* sections, size_t num_pairs,
    size_t* out_sections, size_t max);

// Overlapping: merge intervals that share any point
size_t stz_sections_merge_overlapping(
    const size_t* sections, size_t num_pairs,
    size_t* out_sections, size_t max);

// Comprehensive: merge everything into minimal cover
size_t stz_sections_merge_comprehensive(
    const size_t* sections, size_t num_pairs,
    size_t* out_sections, size_t max);

// Interval queries
int stz_sections_overlap(size_t a_start, size_t a_end,
                          size_t b_start, size_t b_end);
int stz_sections_contains(size_t outer_start, size_t outer_end,
                            size_t inner_start, size_t inner_end);
size_t stz_sections_gap(size_t a_start, size_t a_end,
                          size_t b_start, size_t b_end);
```

### Grid Navigator (2D Cursor Intelligence) [PLANNED]

The Grid Navigator moves through 2D structures with direction
awareness, boundary intelligence, and surrounding context
queries. It works on matrices, tables, game boards, pixel maps,
and any 2D structure.

```c
StzGridNavHandle stz_gridnav_new(size_t rows, size_t cols);
void             stz_gridnav_free(StzGridNavHandle h);

// Position management
void stz_gridnav_move_to(StzGridNavHandle h, size_t row, size_t col);
void stz_gridnav_move(StzGridNavHandle h, int direction);
// STZ_DIR_UP, STZ_DIR_DOWN, STZ_DIR_LEFT, STZ_DIR_RIGHT
// STZ_DIR_UP_LEFT, STZ_DIR_UP_RIGHT, STZ_DIR_DOWN_LEFT, STZ_DIR_DOWN_RIGHT

size_t stz_gridnav_row(StzGridNavHandle h);
size_t stz_gridnav_col(StzGridNavHandle h);

// Boundary intelligence
int stz_gridnav_can_move(StzGridNavHandle h, int direction);
int stz_gridnav_is_edge(StzGridNavHandle h);    // any edge
int stz_gridnav_is_corner(StzGridNavHandle h);

// Context queries
size_t stz_gridnav_neighbors(StzGridNavHandle h,
    size_t* out_positions, size_t max); // row,col pairs
size_t stz_gridnav_path_to(StzGridNavHandle h,
    size_t target_row, size_t target_col,
    size_t* out_path, size_t max);
```

---

---

## Layer 6: Universal Computation Concerns

Every programmer, in every domain, in every language, eventually
hits the same walls. Standard libraries give you data structures
and I/O. They don't give you provenance, explanation, confidence,
similarity, context propagation, or resource awareness. These are
not "nice to have" -- they are the concerns that consume 40-60%
of real application code because no engine provides them.

Layer 6 modules are domain-agnostic. They serve a Rust systems
programmer, a Python data scientist, an AI agent builder, and
any future technology equally. They emerged from studying 60+
Softanza paradigm narrations and asking: "What do programmers
universally struggle with that no standard library solves?"

### Provenance Engine (Data Lineage) [PLANNED]

Every value in a running program came from somewhere. A column
was loaded from a CSV. A number was computed from two other
numbers. A decision was made because three conditions were true.
Standard libraries lose this history the moment the value exists.

The Provenance Engine attaches origin metadata to any StzValue
without changing its behavior. Any language surface can ask
"where did this come from?" at any point.

```c
StzProvenanceHandle stz_provenance_new(void);
void                stz_provenance_free(StzProvenanceHandle h);

// Tag a value with its origin
StzValue stz_provenance_tag(StzProvenanceHandle h,
    StzValue v,
    int origin_kind,           // STZ_ORIGIN_LITERAL, _FILE,
                               // _COMPUTATION, _USER_INPUT,
                               // _NETWORK, _EXTERNAL_TOOL
    const char* source, size_t source_len);

// Record a derivation (this value was computed from these inputs)
void stz_provenance_derive(StzProvenanceHandle h,
    StzValue result,
    const StzValue* inputs, size_t num_inputs,
    const char* operation, size_t op_len);

// Query lineage
size_t stz_provenance_trace(StzProvenanceHandle h,
    StzValue v,
    StzProvenanceEntry* out_chain, size_t max);

typedef struct {
    int origin_kind;
    char source[512];
    char operation[256];
    uint64_t timestamp;
} StzProvenanceEntry;

// "Where did the value in cell [3,5] come from?"
// -> loaded from sales.csv, row 3, column "revenue"
//    -> multiplied by exchange_rate (from api.forex.com)
//    -> rounded to 2 decimals
```

**Why this matters universally:** Regulatory compliance (GDPR,
financial auditing), debugging ("why is this NaN?"), AI
explainability ("what data influenced this prediction"),
reproducibility ("can I regenerate this result?").

### Confidence Engine (Values with Uncertainty) [PLANNED]

Real-world data is never perfectly certain. A sensor reading
has a margin of error. An AI prediction has a confidence score.
A user input might be approximate. A merged record from two
sources might conflict. Yet every programming language treats
values as absolute.

The Confidence Engine wraps StzValue with a confidence level
(0.0 to 1.0) and propagation rules. When you multiply two
uncertain values, the result's confidence is derived
automatically.

```c
// Create a confident value (value + confidence level)
StzValue stz_confidence_wrap(StzValue v, double confidence);
// confidence: 0.0 (unknown) to 1.0 (certain)

// Query confidence
double stz_confidence_level(StzValue v);
int    stz_confidence_is_certain(StzValue v);  // >= threshold

// Propagation: when computing with uncertain values
void stz_confidence_set_rule(int rule);
// STZ_CONF_PROPAGATE_MIN     -- result = min(input confidences)
// STZ_CONF_PROPAGATE_PRODUCT -- result = product (independence)
// STZ_CONF_PROPAGATE_AVG     -- result = average
// STZ_CONF_PROPAGATE_CUSTOM  -- user function

// Conflict resolution: when two sources disagree
StzValue stz_confidence_merge(StzValue a, StzValue b, int strategy);
// STZ_MERGE_HIGHER_CONFIDENCE  -- keep the more confident value
// STZ_MERGE_AVERAGE            -- average the values
// STZ_MERGE_FLAG_CONFLICT      -- tag as conflicting

// Threshold-based filtering
StzValue stz_confidence_filter(StzValue collection,
                                double min_confidence);
```

**Why this matters universally:** Sensor fusion (IoT), AI/ML
probability outputs, data quality management, scientific
computing with error bars, any system where "how sure are we?"
is as important as "what is the value?"

### Explanation Engine (Auditable Computation) [PLANNED]

"Why did the program produce this result?" is the most common
question in debugging, compliance, and AI. Yet no engine
provides explanation as a first-class concern. The Explanation
Engine records the reasoning chain behind any computation and
can render it in human-readable form.

```c
StzExplainHandle stz_explain_new(void);
void             stz_explain_free(StzExplainHandle h);

// Start recording explanations for a computation
void stz_explain_begin(StzExplainHandle h,
    const char* goal, size_t goal_len);

// Record a reasoning step
void stz_explain_step(StzExplainHandle h,
    const char* action, size_t action_len,
    const char* reason, size_t reason_len,
    StzValue evidence);

// Record a decision point (branch taken)
void stz_explain_decision(StzExplainHandle h,
    const char* question, size_t q_len,
    const char* answer, size_t a_len,
    StzValue condition_value);

// End recording
void stz_explain_end(StzExplainHandle h, StzValue final_result);

// Render explanation as human-readable text
size_t stz_explain_render(StzExplainHandle h,
    int format,             // STZ_EXPLAIN_PROSE,
                            // STZ_EXPLAIN_TREE,
                            // STZ_EXPLAIN_CHAIN
    char* buf, size_t buf_len);

// Query: "Why was this decision made?"
size_t stz_explain_why(StzExplainHandle h,
    const char* decision, size_t len,
    char* buf, size_t buf_len);
```

**Why this matters universally:** AI explainability (XAI),
regulatory auditing, debugging complex logic, teaching/learning
("show your work"), any system where humans need to trust or
verify automated decisions.

### Similarity Engine (Beyond Equality) [PLANNED]

Equality is the wrong question for most real-world comparisons.
"Are these the same?" matters less than "How similar are these?"
and "What are the differences?" Standard libraries give you
`==` and nothing else. The Similarity Engine provides graduated
comparison across all data types.

```c
// Scalar similarity (0.0 = completely different, 1.0 = identical)
double stz_similarity(StzValue a, StzValue b);

// Type-specific similarity with configurable weights
double stz_similarity_xt(StzValue a, StzValue b,
    const char* options_json, size_t len);

// String similarity (multiple algorithms)
double stz_similarity_string(const char* a, size_t a_len,
    const char* b, size_t b_len, int algorithm);
// STZ_SIM_LEVENSHTEIN, STZ_SIM_JARO_WINKLER,
// STZ_SIM_COSINE, STZ_SIM_JACCARD, STZ_SIM_NGRAM,
// STZ_SIM_SOUNDEX, STZ_SIM_METAPHONE

// Structural similarity (lists, trees, graphs)
double stz_similarity_structural(StzValue a, StzValue b);
// Compares shape and content; tolerates reordering

// Semantic similarity (via embeddings -- Engine provides
// the vector math, caller provides the embeddings)
double stz_similarity_vector(const double* a, const double* b,
    size_t dimensions, int metric);
// STZ_METRIC_COSINE, STZ_METRIC_EUCLIDEAN,
// STZ_METRIC_MANHATTAN, STZ_METRIC_DOT_PRODUCT

// Find N most similar items in a collection
size_t stz_similarity_nearest(StzValue collection, StzValue query,
    size_t n, StzValue* out_items, double* out_scores,
    size_t max);

// Diff: structured difference report between two values
StzValue stz_diff(StzValue a, StzValue b);
// Returns structured diff: additions, removals, changes
// Works on strings, lists, tables, trees, graphs
```

**Why this matters universally:** Search and retrieval (fuzzy
matching), deduplication, recommendation systems, AI embedding
operations (RAG, semantic search), data reconciliation, any
system where "close enough" is more useful than "exactly equal."

### Context Engine (Propagating State Through Chains) [PLANNED]

Every non-trivial program has implicit context: the current user,
the active locale, the transaction ID, the request trace, the
security principal. This context must flow through every function
call without being passed as an explicit parameter everywhere.
Most languages solve this with globals (unsafe), thread-locals
(fragile), or explicit parameters (verbose).

The Context Engine provides structured, scoped, inheritable
context that any computation can read without coupling to it.

```c
StzContextHandle stz_context_new(void);
void             stz_context_free(StzContextHandle h);

// Set context values (key-value, scoped)
void stz_context_set(StzContextHandle h,
    const char* key, size_t key_len, StzValue value);
StzValue stz_context_get(StzContextHandle h,
    const char* key, size_t key_len);
int stz_context_has(StzContextHandle h,
    const char* key, size_t key_len);

// Scoped context: push/pop layers (inner scope inherits outer)
void stz_context_push(StzContextHandle h);
void stz_context_pop(StzContextHandle h);
// Values set in inner scope don't leak to outer scope
// Values from outer scope are visible in inner scope

// Fork: create a child context that inherits but doesn't
// pollute the parent (for parallel/concurrent work)
StzContextHandle stz_context_fork(StzContextHandle parent);

// Merge: combine two contexts with conflict resolution
void stz_context_merge(StzContextHandle target,
    StzContextHandle source, int strategy);
// STZ_CONTEXT_PREFER_TARGET, STZ_CONTEXT_PREFER_SOURCE,
// STZ_CONTEXT_FAIL_ON_CONFLICT

// Snapshot: serialize context for transmission/storage
size_t stz_context_serialize(StzContextHandle h,
    char* buf, size_t buf_len);
StzContextHandle stz_context_deserialize(
    const char* data, size_t len);
```

**Why this matters universally:** Web request context (user,
locale, permissions), distributed tracing (span IDs), AI agent
memory (conversation state), transaction management, any system
where "ambient state" must flow through computation without
explicit threading.

### Resource Awareness Engine (Cost-Conscious Computation) [PLANNED]

Every operation has a cost: time, memory, network calls, API
tokens, money. Yet no engine lets programmers reason about cost
before committing to an operation. You call a function, it runs,
and you find out afterward that it was expensive.

The Resource Awareness Engine lets any operation declare its
cost profile and lets callers make informed decisions.

```c
StzResourceHandle stz_resource_new(void);
void              stz_resource_free(StzResourceHandle h);

// Estimate cost before execution
StzCostEstimate stz_resource_estimate(StzResourceHandle h,
    int operation,
    const StzValue* args, size_t num_args);

typedef struct {
    uint64_t time_us;          // estimated microseconds
    size_t   memory_bytes;     // estimated memory
    size_t   io_operations;    // estimated I/O calls
    double   monetary_cost;    // estimated money (API calls)
    int      confidence;       // how reliable this estimate is
} StzCostEstimate;

// Budget: set limits on resource consumption
void stz_resource_set_budget(StzResourceHandle h,
    int resource_kind, double limit);
// STZ_BUDGET_TIME_MS, STZ_BUDGET_MEMORY_MB,
// STZ_BUDGET_IO_COUNT, STZ_BUDGET_MONEY

// Check if operation fits within budget
int stz_resource_can_afford(StzResourceHandle h,
    StzCostEstimate estimate);

// Track actual consumption
void stz_resource_record(StzResourceHandle h,
    int operation,
    uint64_t actual_time_us,
    size_t actual_memory);

// Query consumption history
StzCostEstimate stz_resource_total(StzResourceHandle h);
StzCostEstimate stz_resource_per_operation(StzResourceHandle h,
    int operation);
```

**Why this matters universally:** AI/LLM token budgets (critical
for cost control), cloud computing (pay-per-use), embedded
systems (memory/CPU constraints), mobile apps (battery/network),
any system where resources are finite and decisions should be
cost-aware.

### Validation Pipeline Engine (Multi-Stage Checking) [PLANNED]

Real validation is never a single check. An email address must
be syntactically valid, then DNS-resolvable, then not blacklisted.
A financial transaction must pass format checks, then business
rules, then compliance rules, then fraud detection. Each stage
can fail with a different explanation.

The Validation Pipeline Engine chains validation stages with
explanatory failure reports, short-circuit evaluation, and
configurable severity.

```c
StzValidatorHandle stz_validator_new(void);
void               stz_validator_free(StzValidatorHandle h);

// Add validation stages (executed in order)
void stz_validator_add_stage(StzValidatorHandle h,
    const char* name, size_t name_len,
    int severity,              // STZ_SEVERITY_ERROR,
                               // STZ_SEVERITY_WARNING,
                               // STZ_SEVERITY_INFO
    int (*check)(StzValue v, char* msg, size_t msg_len,
                 void* ctx),
    void* ctx);

// Validate a value through all stages
StzValidationResult stz_validator_run(StzValidatorHandle h,
    StzValue v);

typedef struct {
    int passed;                // overall pass/fail
    size_t num_failures;
    size_t num_warnings;
    StzValidationEntry entries[64];
} StzValidationResult;

typedef struct {
    char stage_name[128];
    int severity;
    int passed;
    char message[512];
} StzValidationEntry;

// Short-circuit: stop at first error, or run all stages
void stz_validator_set_mode(StzValidatorHandle h, int mode);
// STZ_VALIDATE_FAIL_FAST, STZ_VALIDATE_COLLECT_ALL

// Render validation report (uses Display Engine)
size_t stz_validator_report(StzValidationResult* result,
    char* buf, size_t buf_len);
```

**Why this matters universally:** Form validation (web/mobile),
data pipeline quality gates, API request validation, CI/CD
checks, compliance verification, AI input sanitization, any
system where "is this valid?" has multiple dimensions.

### Schema Evolution Engine (Structural Change Over Time) [PLANNED]

Data structures change. A table gains a column. A message format
adds a field. An API response changes shape. Most systems handle
this with ad-hoc migration scripts or version-specific code
paths. The Schema Evolution Engine treats structural change as
a first-class concern.

```c
StzSchemaHandle stz_schema_new(const char* name, size_t len,
    int version);
void            stz_schema_free(StzSchemaHandle h);

// Define structure (fields with types and constraints)
void stz_schema_add_field(StzSchemaHandle h,
    const char* field, size_t field_len,
    int field_type,            // STZ_FIELD_STRING, _NUMBER,
                               // _BOOL, _LIST, _OBJECT
    int required,
    const char* default_json, size_t default_len);

// Register a migration from version N to N+1
void stz_schema_add_migration(StzSchemaHandle h,
    int from_version, int to_version,
    StzValue (*migrate)(StzValue old_data, void* ctx),
    void* ctx);

// Validate data against schema
int stz_schema_validate(StzSchemaHandle h, StzValue data);

// Migrate data from old version to current
StzValue stz_schema_migrate(StzSchemaHandle h,
    StzValue data, int from_version);

// Diff two schema versions
size_t stz_schema_diff(StzSchemaHandle old_schema,
    StzSchemaHandle new_schema,
    StzSchemaDiff* out_diffs, size_t max);

typedef struct {
    int kind;              // FIELD_ADDED, FIELD_REMOVED,
                           // FIELD_TYPE_CHANGED, FIELD_RENAMED
    char field[256];
    char detail[512];
} StzSchemaDiff;
```

**Why this matters universally:** Database migrations, API
versioning, configuration file evolution, serialization format
changes, AI model input/output schema changes, any system where
data outlives the code that created it.

### Intent Resolution Engine (What, Not How) [PLANNED]

The deepest lesson from Softanza's paradigm narrations is that
programmers think in INTENT ("remove duplicates", "find similar
items", "validate this data") but code in MECHANISM (loops,
conditionals, index arithmetic). The gap between intent and
mechanism is where bugs, verbosity, and cognitive load live.

The Intent Resolution Engine maps high-level intent descriptions
to concrete Engine operations, choosing the best implementation
based on context (data type, data size, available resources).

```c
StzIntentHandle stz_intent_new(void);
void            stz_intent_free(StzIntentHandle h);

// Register an intent with multiple implementations
void stz_intent_register(StzIntentHandle h,
    const char* intent, size_t intent_len,
    int (*can_handle)(StzValue target, void* ctx),
    StzValue (*execute)(StzValue target,
                        const StzValue* args, size_t num_args,
                        void* ctx),
    void* ctx,
    StzCostEstimate estimated_cost);

// Resolve and execute an intent
StzValue stz_intent_resolve(StzIntentHandle h,
    const char* intent, size_t intent_len,
    StzValue target,
    const StzValue* args, size_t num_args);
// Engine picks the best implementation based on:
// 1. Can this implementation handle this data type?
// 2. Which implementation has the lowest estimated cost?
// 3. Does the implementation fit within the resource budget?

// List available intents for a data type
size_t stz_intent_list(StzIntentHandle h, StzValue target,
    char** out_intents, size_t max);

// Explain resolution: "Why was this implementation chosen?"
size_t stz_intent_explain(StzIntentHandle h,
    const char* intent, size_t intent_len,
    StzValue target,
    char* buf, size_t buf_len);
```

**Why this matters universally:** AI agent tool selection ("I
need to analyze this data" -> choose pandas/SQL/custom based on
data shape), plugin architectures, self-optimizing systems, any
system where the best approach depends on runtime context.

### Embedding & Vector Engine (Geometric Computation) [PLANNED]

Intelligence -- whether human or artificial -- reasons about
similarity, proximity, and relationships in high-dimensional
space. The Embedding Engine provides the mathematical substrate
for any system that works with vectors: AI embeddings, sensor
fusion, recommendation, dimensionality reduction, clustering.

This is NOT an AI module. It is a geometric computation engine
that happens to be essential for AI but equally serves signal
processing, physics simulation, and statistical analysis.

```c
// --- Dense vector operations ---

StzVectorHandle stz_vector_new(size_t dimensions);
StzVectorHandle stz_vector_from(const double* data,
                                 size_t dimensions);
void            stz_vector_free(StzVectorHandle h);

double stz_vector_dot(StzVectorHandle a, StzVectorHandle b);
double stz_vector_cosine(StzVectorHandle a, StzVectorHandle b);
double stz_vector_euclidean(StzVectorHandle a, StzVectorHandle b);
double stz_vector_magnitude(StzVectorHandle h);
StzVectorHandle stz_vector_normalize(StzVectorHandle h);

StzVectorHandle stz_vector_add(StzVectorHandle a,
                                StzVectorHandle b);
StzVectorHandle stz_vector_scale(StzVectorHandle h, double s);
StzVectorHandle stz_vector_lerp(StzVectorHandle a,
                                 StzVectorHandle b, double t);

// --- Vector store (nearest-neighbor search) ---

StzVectorStoreHandle stz_vecstore_new(size_t dimensions);
void                 stz_vecstore_free(StzVectorStoreHandle h);

void stz_vecstore_add(StzVectorStoreHandle h,
    const char* id, size_t id_len,
    StzVectorHandle vector);

// Find K nearest neighbors
size_t stz_vecstore_nearest(StzVectorStoreHandle h,
    StzVectorHandle query, size_t k,
    char** out_ids, double* out_distances, size_t max);

// Find all within radius
size_t stz_vecstore_within_radius(StzVectorStoreHandle h,
    StzVectorHandle center, double radius,
    char** out_ids, double* out_distances, size_t max);

size_t stz_vecstore_count(StzVectorStoreHandle h);

// --- Clustering ---

size_t stz_cluster_kmeans(const StzVectorHandle* vectors,
    size_t count, size_t k,
    size_t* out_labels, size_t max);

// --- Dimensionality reduction ---

void stz_reduce_pca(const StzVectorHandle* vectors,
    size_t count, size_t target_dims,
    StzVectorHandle* out_reduced, size_t max);
```

**Why this matters universally:** AI/RAG systems need embedding
similarity. Recommendation engines need nearest neighbors.
Signal processing needs vector operations. Physics simulations
need geometric math. Clustering and dimensionality reduction
are domain-agnostic tools. The Engine provides the math -- the
caller decides what the vectors represent.

### Sequence Engine (Windowing, Chunking, Overlap) [PLANNED]

Any ordered data -- text, time series, audio samples, event
logs, token streams -- needs to be sliced into overlapping or
non-overlapping windows for processing. This is the fundamental
operation behind AI tokenization, signal processing, streaming
analytics, and batch processing. Yet every programmer
reimplements windowing from scratch.

```c
// Sliding window over any sequence (string or list)
size_t stz_window_sliding(StzValue sequence,
    size_t window_size, size_t stride,
    StzValue* out_windows, size_t max);

// Tumbling window (non-overlapping)
size_t stz_window_tumbling(StzValue sequence,
    size_t window_size,
    StzValue* out_windows, size_t max);

// Session window (gap-based: new window when gap > threshold)
size_t stz_window_session(StzValue sequence,
    size_t max_gap,
    StzValue* out_windows, size_t max);

// Chunk by predicate (start new chunk when condition changes)
size_t stz_chunk_by(StzValue sequence,
    int (*boundary)(StzValue prev, StzValue curr, void* ctx),
    void* ctx,
    StzValue* out_chunks, size_t max);

// Overlap management: merge overlapping chunks
StzValue stz_chunks_merge_overlap(const StzValue* chunks,
    size_t count, size_t overlap_size);

// Token-aware chunking (for text: respect word/sentence bounds)
size_t stz_chunk_text(const char* text, size_t len,
    size_t max_chunk_size,
    int boundary_mode,         // STZ_BOUNDARY_CHAR,
                               // STZ_BOUNDARY_WORD,
                               // STZ_BOUNDARY_SENTENCE,
                               // STZ_BOUNDARY_PARAGRAPH
    StzStringHandle* out_chunks, size_t max);
```

**Why this matters universally:** AI tokenization and context
windows, time-series analysis (financial, IoT), log processing,
audio/video frame extraction, streaming data analytics, any
system that processes ordered data in pieces.

### Computation Topology Engine (Local/Remote Fission) [PLANNED]

As computation scales beyond a single machine, every program
faces the same question: what runs here, what runs there? Cloud
offloading, edge computing, distributed pipelines, and GPU
dispatch all need the same primitive -- the ability to describe
WHERE computation should happen based on operation characteristics,
not hardcoded deployment topology.

The Computation Topology Engine lets any operation declare its
resource signature. The runtime then decides placement.

```c
StzTopoHandle stz_topo_new(void);
void          stz_topo_free(StzTopoHandle h);

// Register a computation target (local, cloud, GPU, edge...)
void stz_topo_register_target(StzTopoHandle h,
    const char* name, size_t name_len,
    int capabilities,          // STZ_CAP_HIGH_MEMORY,
                               // STZ_CAP_HIGH_CPU,
                               // STZ_CAP_GPU,
                               // STZ_CAP_LOW_LATENCY,
                               // STZ_CAP_PERSISTENT_STORAGE
    StzCostEstimate base_cost);

// Tag an operation with its resource signature
void stz_topo_tag_operation(StzTopoHandle h,
    int operation,
    int requirements,          // bitmask of STZ_CAP_*
    size_t estimated_data_bytes);

// Ask: where should this operation run?
const char* stz_topo_resolve(StzTopoHandle h,
    int operation,
    StzValue input);
// Returns target name based on requirements vs capabilities

// Serialize a computation stage for remote execution
size_t stz_topo_serialize_stage(StzTopoHandle h,
    int operation,
    const StzValue* args, size_t num_args,
    char* buf, size_t buf_len);

// Deserialize and execute a received stage
StzValue stz_topo_execute_stage(StzTopoHandle h,
    const char* serialized, size_t len);
```

**Why this matters universally:** Cloud functions (AWS Lambda,
Cloudflare Workers), edge AI (run inference locally, train
remotely), distributed data pipelines, GPU offloading, any
system where computation placement is a decision, not a given.

### Relationship Engine (Structural Connections) [PLANNED]

Data never exists in isolation. Tables have foreign keys. Objects
have owners. Events have causes. Files have dependencies. Yet
standard libraries treat each data structure as standalone.

The Relationship Engine makes connections between entities
first-class, enabling referential integrity, join optimization,
and impact analysis across any data domain.

```c
StzRelHandle stz_rel_new(void);
void         stz_rel_free(StzRelHandle h);

// Define entity types
void stz_rel_define_entity(StzRelHandle h,
    const char* entity_type, size_t len,
    const char* fields_json, size_t fields_len);

// Define relationships between entity types
void stz_rel_define_relationship(StzRelHandle h,
    const char* from_type, size_t from_len,
    const char* to_type, size_t to_len,
    const char* rel_name, size_t name_len,
    int cardinality);          // STZ_REL_ONE_TO_ONE,
                               // STZ_REL_ONE_TO_MANY,
                               // STZ_REL_MANY_TO_MANY

// Check referential integrity
int stz_rel_validate(StzRelHandle h,
    const char* entity_type, size_t len,
    StzValue data);

// Query related entities
size_t stz_rel_related(StzRelHandle h,
    const char* entity_type, size_t type_len,
    StzValue entity_id,
    const char* relationship, size_t rel_len,
    StzValue* out_related, size_t max);

// Impact analysis: what would be affected if this entity changes?
size_t stz_rel_impact(StzRelHandle h,
    const char* entity_type, size_t type_len,
    StzValue entity_id,
    StzValue* out_affected, size_t max);
```

**Why this matters universally:** Database design, dependency
management (packages, modules, builds), organizational modeling,
workflow dependency tracking, AI knowledge bases, any system
where entities are connected and changes cascade.

### State Machine Engine (Declared Transitions) [PLANNED]

Every agent, every protocol, every workflow, every UI, every
game is a state machine. Yet programmers implement them ad-hoc
every time -- switch statements, flag variables, nested
conditionals. The State Machine Engine makes transitions
declarative and the current state queryable.

```c
StzStateMachineHandle stz_fsm_new(
    const char* initial_state, size_t len);
void stz_fsm_free(StzStateMachineHandle h);

// Declare states
void stz_fsm_add_state(StzStateMachineHandle h,
    const char* state, size_t len,
    int kind);                 // STZ_STATE_NORMAL,
                               // STZ_STATE_INITIAL,
                               // STZ_STATE_FINAL,
                               // STZ_STATE_ERROR

// Declare transitions
void stz_fsm_add_transition(StzStateMachineHandle h,
    const char* from_state, size_t from_len,
    const char* event, size_t event_len,
    const char* to_state, size_t to_len,
    int (*guard)(StzValue context, void* userdata),
    void* userdata);

// Fire an event (attempt transition)
int stz_fsm_fire(StzStateMachineHandle h,
    const char* event, size_t event_len,
    StzValue context);
// Returns 1 if transition occurred, 0 if no valid transition

// Query current state
size_t stz_fsm_current_state(StzStateMachineHandle h,
    char* buf, size_t buf_len);
int stz_fsm_is_final(StzStateMachineHandle h);

// Query available transitions from current state
size_t stz_fsm_available_events(StzStateMachineHandle h,
    char** out_events, size_t max);

// Transition history
size_t stz_fsm_history(StzStateMachineHandle h,
    StzFsmEntry* out_entries, size_t max);

typedef struct {
    char from_state[128];
    char event[128];
    char to_state[128];
    uint64_t timestamp;
} StzFsmEntry;

// Render state machine as graph (uses Display Engine)
size_t stz_fsm_render(StzStateMachineHandle h,
    char* buf, size_t buf_len);

// Validate: check for unreachable states, dead ends, etc.
size_t stz_fsm_validate(StzStateMachineHandle h,
    char* out_warnings, size_t buf_len);
```

**Why this matters universally:** Protocol implementations
(HTTP, WebSocket, MQTT), UI navigation flows, game logic,
agent behavior (idle/planning/acting/waiting), workflow engines,
approval chains, any system with discrete states and events.

---

### Enhancement Notes (Deepened from Full Document Audit)

The following existing modules gain depth from the remaining
35 documents studied:

**Regex module (done):** Add scope-based metacharacter behavior
(`STZ_MATCH_SCOPE_LINE`, `_WORD`, `_SEGMENT`), deferred pattern
compilation (lazy builder accumulator), and hierarchical capture
groups (recursive match tree returning depth + group names +
positions, not just flat strings).

**Pattern matching (H.1):** Add table metadata inspection
primitives for Tablex patterns -- lazy evaluation of column
types, cardinality, uniqueness, and aggregate ranges without
full data scans. Add temporal interval algebra for Timex
patterns -- point matching, duration range validation, event
ordering assertions, and gap constraints.

**Walker (F.12):** Extend to N-dimensional position state.
The 2D Walker (stzWalker2D) shows that walkers naturally
generalize beyond 1D. Engine should support `stz_walker_nd_new(
dimensions, bounds, steps)` with direction detection, rollback
history, and boundary awareness in any number of dimensions.

**Reaxis (J.1):** Add change batching/coalescing. When multiple
reactive data sources change rapidly, the Engine should defer
dependent recomputation until all sources settle, then flush
once. This prevents cascading recomputation storms.

**Serialization (across modules):** Add structural encoding/
decoding primitives -- converting nested structures to bracket-
comma strings and back in O(n) single-pass processing, as shown
by the path generation deepdive.

---

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
| G.16     | Func Registry   | 13-form execution model, naming grammar|
|          |                 | alternatives, multilingual, bridge gen  |
| G.17     | Small Functions | Q(), @@(), @(), QH(), L(), S(), N()    |
| G.18     | Exec Primitives | Chain, Partial, Future, Conditional,   |
|          |                 | Plural, Exceptional, Random dispatch   |
| G.19     | Cache Engine    | Function-level caching (mem/file/mmap) |
| G.20     | Log Engine      | Function-level tracing with context    |
| G.21     | Profiler Engine | Timing, call counts, call graph        |
| G.22     | Callstack Viz   | Visual error reporting, execution path |

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

### Phase J: Paradigm Engines

Softanza does not merely use programming concepts -- it rethinks
them from first principles and redesigns them. The Engine must
codify these paradigm innovations as native modules so every
language surface inherits them. These were extracted from 60+
paradigm narration documents and their Ring implementations.

| Priority | Module             | What It Brings                          |
|----------|--------------------|-----------------------------------------|
| J.1      | Reaxis Engine      | Container->Stream->Rfunction reactive   |
|          |                    | model with overflow, Feed/FeedMany,     |
|          |                    | natural timing, stream optimization     |
| J.2      | Softanzuter        | Universal reactive computation medium   |
|          |                    | (triggers, computations, state, deps)   |
| J.3      | Truth Engine       | Configurable truth (IsTrueXT), semantic |
|          |                    | falsification by substring/item/deep    |
| J.4      | Quantifier Engine  | Probabilistic quantifiers (Few/Some/    |
|          |                    | Most/Half) with configurable thresholds |
| J.5      | Polyglot Bridge    | EXCIS multi-language runtime (R, Python,|
|          |                    | Julia, COBOL, AI) with type marshaling  |
| J.6      | Refinement Engine  | PolyCode refinement points (<R:PARAM>,  |
|          |                    | <R:BLOCK>, <R:ALGO>, <R:FUNC>)          |
| J.7      | Adverb Engine      | Morphological rule engine with 5-level  |
|          |                    | priority (irregular->domain->fallback)  |
| J.8      | Timeline Engine    | Temporal workspace (points, spans,      |
|          |                    | blocked regions, constraint reasoning)  |
| J.9      | Grid Navigator     | 2D cursor with direction intelligence,  |
|          |                    | boundary awareness, context queries     |
| J.10     | Section Merger     | Interval arithmetic (inclusive/overlap/ |
|          |                    | comprehensive merging strategies)       |
| J.11     | Deep Operations    | Path-based recursive traversal with     |
|          |                    | endpoint/in-path disambiguation         |
| J.12     | Named Variables    | Dynamic variable construction and       |
|          |                    | reference resolution                    |

### Phase K: Universal Computation Concerns

These modules address the concerns EVERY programmer hits
regardless of language, domain, or era. They emerged from
asking: "What do programmers universally struggle with that
no standard library solves?" They serve Zin, Python, Rust,
AI agents, and any future technology equally.

| Priority | Module             | What It Brings                          |
|----------|--------------------|-----------------------------------------|
| K.1      | Provenance         | Data lineage: where did this value come |
|          |                    | from? How was it derived? Full trace.   |
| K.2      | Confidence         | Values with uncertainty (0.0-1.0),      |
|          |                    | automatic propagation, conflict merge   |
| K.3      | Explanation        | Auditable computation: record reasoning |
|          |                    | chains, render as prose/tree/chain      |
| K.4      | Similarity         | Beyond equality: graduated comparison,  |
|          |                    | structural diff, nearest neighbors      |
| K.5      | Context            | Scoped state propagation: push/pop/fork |
|          |                    | /merge without globals or explicit args |
| K.6      | Resource Awareness | Cost estimation before execution, budget|
|          |                    | limits, consumption tracking            |
| K.7      | Validation Pipeline| Multi-stage checking with severity,     |
|          |                    | explanatory failures, short-circuit     |
| K.8      | Schema Evolution   | Structural change over time: migrations,|
|          |                    | version diffs, forward compatibility    |
| K.9      | Intent Resolution  | Map "what" to "how": pick best impl    |
|          |                    | based on data type, size, resources     |
| K.10     | Embedding/Vector   | Geometric computation: dot/cosine/      |
|          |                    | nearest-neighbor, clustering, PCA       |
| K.11     | Sequence/Windowing | Sliding/tumbling/session windows,       |
|          |                    | text chunking, overlap management       |
| K.12     | Comp. Topology     | Local/remote/GPU fission: operation     |
|          |                    | signatures, placement, serialization    |
| K.13     | Relationships      | Entity connections, referential integrity|
|          |                    | impact analysis, join optimization      |
| K.14     | State Machine      | Declared states/transitions/guards,     |
|          |                    | history, validation, graph rendering    |

### Module Count Summary

| Phase | Modules | Status    | What                      |
|-------|---------|-----------|---------------------------|
| A-E   | 11      | DONE      | Qt replacement            |
| F     | 13      | PLANNED   | Ring workaround elimination|
| F+    | 3       | PLANNED   | Checker/Yielder/Performer |
| G     | 22      | PLANNED   | Infrastructure + manageability |
| H     | 11      | PLANNED   | Signature features        |
| J     | 12      | PLANNED   | Paradigm engines          |
| K     | 14      | PLANNED   | Universal computation     |
| VP    | 2       | PLANNED   | Interaction + Skill engines|
| **Total** | **88** | **11 done, 77 planned** |

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

---

## Three Value Propositions

The Engine provides computational force. But computational force
alone is not enough. Three cross-cutting concerns make the Engine
trustworthy, accessible, and teachable:

1. **Testability** -- the Engine hardens itself
2. **Usability** -- the Engine exposes interaction as a first-class
   concern, so programmers declare intent and the Engine renders it
   on any medium
3. **Learnability** -- the Engine knows what skills it demands and
   provides material to teach them

These are not optional add-ons. They are value propositions that
every module participates in.

---

### VP-1: Testability

The Engine applies the same 4-layer testing discipline that hardens
the Zin compiler. Every module ships with tests at all four layers.
No module is considered complete without them.

#### The Four Layers

**Layer 1 -- Inline unit tests.**
Every `.zig` source file contains `test` blocks next to the code
they verify. These run with `zig build test` and use Zig's
`std.testing` allocator for leak detection. Target density:
40+ tests per 1000 lines of code.

```zig
// Inside stz_string.zig
test "codepoint_count handles combining marks" {
    const s = stz_string_from("e\xCC\x81", 3); // é as e + combining acute
    defer stz_string_free(s);
    try std.testing.expectEqual(@as(usize, 1), stz_string_codepoint_count(s));
}
```

**Layer 2 -- Simulation harness.**
Multi-module integration tests that exercise cross-module contracts
without real I/O. These verify that the Walker correctly drives
List iteration, that the Splitter and Regex cooperate, that the
Reaxis container-stream-rfunction pipeline works end-to-end.

```zig
// Inside tests/sim/test_walker_list.zig
test "walker drives list forward and backward" {
    const list = stz_list_create(allocator);
    defer stz_list_free(list);
    // ... populate list ...
    const w = stz_walker_create(1, stz_list_len(list), 1);
    defer stz_walker_free(w);
    // Walk forward, collect values, walk backward, compare
}
```

**Layer 3 -- CLI integration tests.**
The `stzengine` CLI commands are tested as complete invocations.
Each test launches the CLI binary with arguments and verifies
stdout, stderr, and exit code. These use pre-built binaries --
no child process spawning inside `zig build test`.

```zig
// Build-time test that checks CLI output was pre-recorded
test "stzengine info --module string produces valid JSON" {
    const expected = @embedFile("fixtures/info_string.json");
    // Compare pre-recorded output against expected schema
}
```

**Layer 4 -- Narrated tests.**
Structured test scenarios with GIVEN/WHEN/THEN blocks and
EXPLANATION fields that serve as both verification and
documentation. These are the Engine's equivalent of executable
specifications.

```zig
// Inside tests/narrated/test_truth_domain.zig
test "GIVEN a medical domain truth config WHEN evaluating 'N/A' THEN it is falsy" {
    // EXPLANATION: Medical systems treat "N/A" as absence of data,
    // which is semantically false in diagnostic contexts.
    const cfg = stz_truth_config_create(allocator);
    defer stz_truth_config_free(cfg);
    stz_truth_add_falsy_string(cfg, "N/A", 3);
    const v = stz_value_string("N/A", 3);
    try std.testing.expect(!stz_truth_is_true(cfg, v));
}
```

#### Mechanical Guardrail: L99 -- No Real I/O in Tests

The Engine enforces at build time that no test body reaches
`std.fs.File` stdout/stdin/stderr or `std.io.getStd*()`. This
prevents hangs on Windows (where child-process stdio in tests
deadlocks `zig build test`) and ensures all tests are hermetic.

The guardrail is a compile-time check in the build system:

```zig
// build.zig -- L99 enforcement
// If any test file imports std.io.getStdOut, the build fails
// with: "L99: real stdio is banned in test bodies"
```

#### Test Discovery and Density Tracking

The build system auto-discovers test files by convention:
- `src/**/*.zig` -- inline unit tests (Layer 1)
- `tests/sim/*.zig` -- simulation harness (Layer 2)
- `tests/cli/*.zig` -- CLI integration (Layer 3)
- `tests/narrated/*.zig` -- narrated tests (Layer 4)

The CLI reports test density per module:

```
$ stzengine test --summary
Module      | L1   | L2  | L3  | L4  | Total | Lines | Density
------------|------|-----|-----|-----|-------|-------|--------
stz_string  |  312 |  24 |   8 |  12 |   356 |  8200 |  43.4
stz_list    |  287 |  31 |   6 |   9 |   333 |  7100 |  46.9
stz_walker  |  148 |  18 |   4 |   6 |   176 |  3400 |  51.8
...
TOTAL       | 3200 | 420 |  90 |  80 |  3790 | 86000 |  44.1
```

#### C ABI for External Test Harnesses

Language clients can query the Engine's test infrastructure:

```c
// Test metadata for external harnesses
size_t    stz_test_module_count(void);
const char* stz_test_module_name(size_t idx);
size_t    stz_test_count(const char* module, size_t mod_len);
size_t    stz_test_layer_count(const char* module, size_t mod_len,
                               int layer); // 1-4
int       stz_test_run_module(const char* module, size_t mod_len,
                              char* report_buf, size_t buf_len);
```

---

### VP-2: Usability -- The Interaction Engine

The Engine does not just compute -- it exposes a declarative
interaction layer where programmers define user-facing logic in
terms of **cognitive intents**, and the Engine projects those
intents onto any physical medium (web UI, terminal UI, voice
interface, API endpoint, accessibility device).

This is not a UI framework. It is an **intent grammar** that
separates WHAT the user wants to do from HOW it appears on screen.

#### Design Source

This design is informed by Zin's Zui pillar, which defines 24
cognitive verbs across 6 categories. The Engine generalizes this
into a medium-agnostic interaction substrate.

#### The Six Intent Categories

| Category    | Verbs                              | Semantics                |
|-------------|-------------------------------------|--------------------------|
| Orienting   | DISCOVER, ORIENT, OVERVIEW          | User builds mental model |
| Attention   | FOCUS, ZOOM, FILTER, GROUP          | User narrows scope       |
| Information | READ, INSPECT, COMPARE, TRACE       | User acquires knowledge  |
| Selection   | SELECT, MARK, COLLECT, RANK         | User makes choices       |
| Action      | ACT, CONFIRM, UNDO, RETRY, DELEGATE| User triggers change     |
| Continuity  | SAVE, RESUME, SHARE, EXPORT         | User preserves state     |

#### Constitutional Laws (Engine-enforced)

The interaction layer enforces safety invariants at the Engine
level, not at the UI level. These are not guidelines -- they are
compile-time or runtime checks that reject invalid intent flows:

1. **No SELECT-to-ACT collapse.** Every destructive action MUST
   pass through CONFIRM. A UI cannot wire a select event directly
   to a delete operation.

2. **UNDO covenant.** Every ACT that mutates state MUST register
   an undo operation. If no undo is possible (irreversible action),
   the Engine forces a CONFIRM with explicit "no undo" disclosure.

3. **DISCOVER before ACT.** A session cannot begin with ACT. The
   user must have encountered DISCOVER or ORIENT first. This
   prevents "deep link to delete" attacks.

4. **Accessibility invariant.** Every intent MUST have a text
   representation. If a rendering projection cannot produce text
   (e.g., a purely visual control), the Engine rejects the flow
   at declaration time.

#### C ABI

```c
// Intent flow declaration
typedef struct StzIntentFlow StzIntentFlow;
typedef struct StzIntentStep StzIntentStep;

StzIntentFlow* stz_interact_flow_create(
    void* allocator, const char* name, size_t name_len);
void stz_interact_flow_free(StzIntentFlow* flow);

// Add steps to a flow
StzIntentStep* stz_interact_step_add(
    StzIntentFlow* flow,
    int verb,           // STZ_VERB_DISCOVER, STZ_VERB_SELECT, etc.
    const char* label, size_t label_len,
    const char* target, size_t target_len);

// Attach data binding to a step
void stz_interact_step_bind(
    StzIntentStep* step,
    const char* source_expr, size_t expr_len);

// Validate the entire flow against constitutional laws
// Returns 0 on success, error code + message on violation
int stz_interact_flow_validate(
    StzIntentFlow* flow,
    char* error_buf, size_t buf_len);

// Rendering projection
typedef enum {
    STZ_MEDIUM_WEB = 0,    // HTML/CSS/JS
    STZ_MEDIUM_TUI,        // Terminal UI (ANSI)
    STZ_MEDIUM_VOICE,      // Voice prompt/response
    STZ_MEDIUM_API,        // REST/GraphQL endpoint
    STZ_MEDIUM_ACCESS,     // Screen reader / braille
    STZ_MEDIUM_PRINT,      // PDF / paper
} StzMedium;

// Project a validated flow to a specific medium
int stz_interact_project(
    StzIntentFlow* flow,
    StzMedium medium,
    char* output_buf, size_t buf_len,
    size_t* written);

// Intent verbs (compile-time constants)
enum {
    STZ_VERB_DISCOVER = 0,
    STZ_VERB_ORIENT,
    STZ_VERB_OVERVIEW,
    STZ_VERB_FOCUS,
    STZ_VERB_ZOOM,
    STZ_VERB_FILTER,
    STZ_VERB_GROUP,
    STZ_VERB_READ,
    STZ_VERB_INSPECT,
    STZ_VERB_COMPARE,
    STZ_VERB_TRACE,
    STZ_VERB_SELECT,
    STZ_VERB_MARK,
    STZ_VERB_COLLECT,
    STZ_VERB_RANK,
    STZ_VERB_ACT,
    STZ_VERB_CONFIRM,
    STZ_VERB_UNDO,
    STZ_VERB_RETRY,
    STZ_VERB_DELEGATE,
    STZ_VERB_SAVE,
    STZ_VERB_RESUME,
    STZ_VERB_SHARE,
    STZ_VERB_EXPORT,
};
```

#### Usage Example (Python via C FFI)

```python
import ctypes
engine = ctypes.CDLL("softanza_engine.dll")

# Declare an intent flow for "browse products and buy"
flow = engine.stz_interact_flow_create(None, b"shop", 4)

engine.stz_interact_step_add(flow, 0, b"Browse catalog", 14,
                             b"products", 8)       # DISCOVER
engine.stz_interact_step_add(flow, 11, b"Pick item", 9,
                             b"product", 7)        # SELECT
engine.stz_interact_step_add(flow, 15, b"Add to cart", 11,
                             b"cart.add", 8)        # ACT
engine.stz_interact_step_add(flow, 16, b"Confirm purchase", 16,
                             b"order.place", 11)    # CONFIRM

# Validate -- Engine checks constitutional laws
err = ctypes.create_string_buffer(256)
if engine.stz_interact_flow_validate(flow, err, 256) != 0:
    print(f"Flow violation: {err.value}")

# Project to web
html = ctypes.create_string_buffer(8192)
written = ctypes.c_size_t()
engine.stz_interact_project(flow, 0, html, 8192,
                            ctypes.byref(written))
# html now contains a self-contained web component

# Project same flow to terminal
tui = ctypes.create_string_buffer(4096)
engine.stz_interact_project(flow, 1, tui, 4096,
                            ctypes.byref(written))
# tui now contains ANSI-formatted interactive prompts

engine.stz_interact_flow_free(flow)
```

The programmer writes the interaction logic ONCE. The Engine
renders it on web, terminal, voice, API, accessibility device,
or paper. The constitutional laws guarantee safety regardless
of rendering medium.

---

### VP-3: Learnability -- The Skill Engine

Every module in the Engine knows what it demands from the
programmer and what it can teach. Learnability is not
documentation -- it is a structured, queryable, machine-readable
skill graph embedded in the Engine itself.

#### Skill Metadata per Module

Each Engine module declares:

1. **Prerequisites** -- skills the programmer must have before
   using this module (other Engine modules, general concepts)
2. **Skills taught** -- what the programmer learns by using this
   module
3. **Coding examples** -- executable Ring snippets (using Zing =
   Ring + Softanza Engine) that demonstrate each skill, graded by
   difficulty (beginner/intermediate/advanced). Ring is the example
   language because the Skill Engine targets high-level programmers,
   not systems programmers. Learners run examples with the Ring
   interpreter + Engine DLLs -- no Zig toolchain required.
4. **Skill checks** -- small coding challenges the programmer can
   attempt, with automated verification

```c
// Skill graph queries
typedef struct StzSkillInfo StzSkillInfo;

// How many skills does this module require?
size_t stz_skill_prereq_count(
    const char* module, size_t mod_len);

// Get prerequisite skill name and description
int stz_skill_prereq_get(
    const char* module, size_t mod_len,
    size_t idx,
    char* name_buf, size_t name_len,
    char* desc_buf, size_t desc_len);

// How many skills does this module teach?
size_t stz_skill_teaches_count(
    const char* module, size_t mod_len);

// Get a coding example for a specific skill
int stz_skill_example_get(
    const char* module, size_t mod_len,
    const char* skill, size_t skill_len,
    int difficulty,  // 0=beginner, 1=intermediate, 2=advanced
    char* code_buf, size_t code_len,
    char* explanation_buf, size_t expl_len);

// Get a skill check challenge
int stz_skill_check_get(
    const char* module, size_t mod_len,
    const char* skill, size_t skill_len,
    char* challenge_buf, size_t chal_len,
    char* signature_buf, size_t sig_len);

// Verify a skill check answer
int stz_skill_check_verify(
    const char* module, size_t mod_len,
    const char* skill, size_t skill_len,
    const char* answer_code, size_t code_len,
    char* feedback_buf, size_t fb_len);
```

#### CLI Skill Commands

```
$ stzengine skills list
Module         | Prerequisites | Skills Taught | Examples | Checks
---------------|---------------|---------------|----------|-------
stz_string     | value         | 12            | 36       | 12
stz_list       | value, string | 15            | 45       | 15
stz_walker     | (none)        |  8            | 24       |  8
stz_reaxis     | stream, truth | 10            | 30       | 10
stz_interact   | intent, state | 14            | 42       | 14
...

$ stzengine skills prereqs walker
Module stz_walker has no prerequisites. You can start here.

$ stzengine skills prereqs reaxis
Module stz_reaxis requires:
  - stz_stream: data flow and buffering (from Layer 3)
  - stz_truth: domain-specific truth evaluation (from Layer 5)

$ stzengine skills check string codepoint_handling
Challenge: Write a Ring function using Softanza that counts the
number of visible characters (grapheme clusters) in a UTF-8
string containing combining marks.

Signature:
  load "stzlib.ring"
  func solve(cStr)
    # your code here -- return the count

Submit your answer:
> _

$ stzengine skills path "build a reactive pipeline"
Recommended learning path:
  1. stz_value    (Layer 0) -- understand the universal value type
  2. stz_stream   (Layer 3) -- data flow and buffering
  3. stz_truth    (Layer 5) -- domain-specific truth
  4. stz_reaxis   (Layer 5) -- reactive container/stream/rfunction
  5. stz_interact (VP-2)    -- declare user-facing intent flows

Estimated effort: 4-6 hours for intermediate programmers.
```

#### Skill Graph as Training Platform Material

The skill metadata is not just for CLI use. It is structured
data that any training platform can consume:

```c
// Export the full skill graph as JSON
int stz_skill_graph_export(
    char* json_buf, size_t buf_len,
    size_t* written);

// Export learning paths as JSON
int stz_skill_paths_export(
    const char* goal, size_t goal_len,
    char* json_buf, size_t buf_len,
    size_t* written);
```

A training platform built on the Engine gets:
- Prerequisite-ordered curriculum generation
- Executable coding examples with expected output
- Automated skill verification with feedback
- Learning path recommendations based on goals
- Progress tracking across the skill graph

The Engine does not BUILD the training platform -- it provides
the structured material that makes building one trivial.

#### Code-Aware Skill Assessment

The Engine can analyze existing code to determine which skills
the programmer already demonstrates:

```c
// Analyze source code for demonstrated skills
int stz_skill_assess(
    const char* source_code, size_t code_len,
    const char* language, size_t lang_len,  // "zig", "ring", "python"
    char* report_buf, size_t report_len);
```

```
$ stzengine skills assess myapp.ring
Skills demonstrated in myapp.ring:
  [x] stzString: basic creation, codepoint indexing, Q() chaining
  [x] stzList: creation, append, iteration
  [x] stzWalker: forward traversal
  [ ] stzWalker: variable step patterns (not used)
  [ ] stzReactive: (not used -- consider for the event handling
      in lines 45-78, which uses manual polling)
  [ ] stzInteract: (not used -- the CLI menu in lines 12-30
      could be declared as an intent flow)

Recommendations:
  - Learn stzReactive to replace the polling loop at line 45
  - Learn stzInteract to make the CLI menu portable
```

---

### Module Count Summary (Updated)

| Phase   | Modules | Status    | What                          |
|---------|---------|-----------|-------------------------------|
| A-E     | 11      | DONE      | Qt replacement                |
| F       | 13      | PLANNED   | Ring workaround elimination   |
| F+      | 3       | PLANNED   | Checker/Yielder/Performer     |
| G       | 22      | PLANNED   | Infrastructure + manageability|
| H       | 11      | PLANNED   | Signature features            |
| J       | 12      | PLANNED   | Paradigm engines              |
| K       | 14      | PLANNED   | Universal computation         |
| VP      | 2       | PLANNED   | Interaction + Skill engines   |
| **Total** | **88** | **11 done, 77 planned** |              |
