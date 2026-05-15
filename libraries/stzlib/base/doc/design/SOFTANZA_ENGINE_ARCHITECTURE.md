# Softanza Engine -- Architectural Design

## 1. Identity: The Engine is the Product

The Softanza Engine is not a helper library for Ring. It is an
independent computation substrate that happens to have Ring as
its first client. The Engine will live in its own repository
(`softanza-engine`) and ship as:

- A **C ABI shared library** (`.dll` / `.so` / `.dylib`) usable
  from any language with C FFI
- A **static library** (`.a`) for embedding in compiled binaries
- A **CLI tool** (`stzengine`) for development, building, and
  direct interaction
- A **Ring integration layer** (`stzlib`) that adds scripting
  syntax and OOP paradigms on top

```
  softanza-engine (standalone repo)
       |
       +-- C ABI shared library
       |     |
       |     +-- Ring client (stzlib.ring)
       |     +-- Python client (import softanza)
       |     +-- Rust client (softanza-rs crate)
       |     +-- Go client (softanza-go module)
       |     +-- Any C-FFI language
       |
       +-- Static library
       |     |
       |     +-- Zin compiler (direct Zig import)
       |     +-- Embedded systems (bare metal)
       |
       +-- stzengine CLI
             |
             +-- Build, test, REPL, serve, deploy
```

**Design rule:** Every feature is implemented once, in the
Engine. Language clients are thin FFI bridges that add syntax
and paradigms -- never computation.

---

## 2. Dual Access Model

The Engine serves two fundamentally different consumer patterns:

### 2a. Pure C FFI (DLL mode)

Any language loads the Engine DLL and calls C functions directly.
The consumer provides its own scripting syntax, OOP, and paradigms.

```python
# Python example -- pure DLL, no Ring involved
import ctypes
engine = ctypes.CDLL("softanza_engine.dll")

s = engine.stz_string_from(b"Hello", 5)
engine.stz_string_to_upper(s)
print(engine.stz_string_data(s))  # HELLO
engine.stz_string_free(s)
```

```rust
// Rust example
extern "C" {
    fn stz_string_from(data: *const u8, len: usize) -> *mut c_void;
    fn stz_string_to_upper(h: *mut c_void) -> *mut c_void;
}
```

### 2b. Ring + Engine (scripting mode)

Ring loads the Engine DLLs via its FFI bridge files, then wraps
them in Softanza classes that add:

- Function alternatives (`Contains()` / `IsContaining()` / ...)
- Named parameters (`FindXT(:CaseSensitive = TRUE)`)
- Q() chaining (`o1.UppercaseQ().ReplaceQ("A","X").Content()`)
- Natural coding keywords
- Conditional code, constraints
- Reactive programming

**This is what makes Softanza special.** The Engine provides brute
force; Ring provides human-centric expressiveness. A foreign
language can either:

1. Use the DLL directly and build its own expressiveness, or
2. Embed Ring as a scripting layer and get the full Softanza
   experience with zero effort

### 2c. Ring as Embeddable Scripting Layer

For languages that want the FULL Softanza experience (not just
the Engine), they can embed Ring's interpreter as a DLL alongside
the Engine. This gives them:

- Ring's dynamic typing and OOP
- All 6000+ Softanza methods with semantic naming
- Natural coding, Q() chaining, conditional code
- Zero reimplementation cost

```c
// C application embedding Ring + Softanza
#include "ring.h"
RingState *vm = ring_state_new();
ring_state_runcode(vm, "load 'stzlib.ring'");
ring_state_runcode(vm, "? Q('hello').Uppercased()");
ring_state_delete(vm);
```

This is the "Ring as a scripting paradigm layer" pattern.

---

## 3. Modular Build: Horizontal and Vertical Slicing

### 3a. Horizontal Slicing (Core / Base / Max)

The Engine mirrors Softanza's three-layer architecture:

| Layer | DLL prefix | Content               | When to use          |
|-------|------------|----------------------|----------------------|
| Core  | `stk_*`    | Lean, minimal wrap    | Embedded, constrained|
| Base  | `stz_*`    | Full domain coverage  | General use          |
| Max   | `stx_*`    | Advanced, specialized | Full power           |

Each layer is a separate set of DLLs. A client loads only the
layer it needs.

### 3b. Vertical Slicing (Per-Domain DLLs)

Within each layer, each domain is its own DLL:

```
stk_string.dll    -- just strings + chars
stk_datetime.dll  -- just date/time
stk_file.dll      -- just filesystem
stk_locale.dll    -- just locale
```

A client that only needs string operations loads only
`stk_string.dll` (or `stz_string.dll` for the richer API).
No wasted memory, no unnecessary initialization.

### 3c. Build Configuration

The `stzengine` CLI controls what gets built:

```bash
# Build everything (all layers, all domains)
stzengine build

# Build only Core layer
stzengine build --layer core

# Build only string domain (Core + Base)
stzengine build --domain string

# Build a custom subset
stzengine build --domains string,datetime,regex

# Build for a specific target
stzengine build --target aarch64-linux

# Build static library (for embedding)
stzengine build --static

# Build with release optimizations
stzengine build --release
```

### 3d. Dependency Graph

Domains declare their dependencies. The build system resolves
them automatically:

```
stz_regex   -> stz_string (regex operates on strings)
stz_json    -> stz_string (JSON is text)
stz_locale  -> stz_string (formatted output is text)
stz_html    -> stz_string (HTML is text)
stz_crypto  -> stz_bytes  (crypto operates on bytes)
stz_table   -> stz_list   (tables contain lists)
stz_graph   -> stz_list, stz_hashmap (adjacency + properties)
stz_stats   -> stz_list, stz_number  (data + precision)
stz_solver  -> stz_matrix, stz_number (linear algebra)
```

Building `--domain regex` automatically includes `stz_string`.

---

## 4. stzengine CLI

The CLI is the developer's primary interface to the Engine.
It makes working with the Engine precise and enjoyable.

### 4a. Commands

```
stzengine build [options]     Build Engine DLLs
stzengine test  [filter]      Run Engine test suite
stzengine bench [filter]      Run benchmarks
stzengine repl                Interactive Engine REPL
stzengine serve [port]        HTTP API exposing Engine functions
stzengine doctor              Diagnose installation
stzengine info                Show modules, versions, sizes
stzengine init <lang>         Generate FFI bridge for a language
stzengine pack                Package Engine for distribution
stzengine deploy <target>     Cross-compile for target platform
```

### 4b. REPL

Direct interaction with the Engine, no language client needed:

```
$ stzengine repl
stz> s = string.from("Hello, Softanza!")
stz> string.count(s)
16
stz> string.to_upper(s)
"HELLO, SOFTANZA!"
stz> list.from([1, "two", [3, 4]])
[1, "two", [3, 4]]
stz> list.find(_, "two")
2
stz> hash.sha256("secret")
"2bb80d537b1da3e38bd30361aa855686bde0eac..."
stz> quit
```

### 4c. Bridge Generator

Auto-generate FFI bindings for any language:

```bash
stzengine init python    # generates softanza.py (ctypes)
stzengine init rust      # generates softanza-rs/src/lib.rs
stzengine init go        # generates softanza.go (cgo)
stzengine init csharp    # generates Softanza.cs (P/Invoke)
stzengine init ring      # generates stz_*.ring bridges
```

### 4d. HTTP API Server

Expose Engine functions as a REST API for microservice
architectures or browser-based applications:

```bash
stzengine serve --port 8080 --modules string,crypto,json
```

```
POST /string/to_upper  {"input": "hello"}  -> {"result": "HELLO"}
POST /crypto/sha256    {"input": "data"}   -> {"result": "3a6eb..."}
POST /json/parse       {"input": "{...}"}  -> {"result": {...}}
```

---

## 5. Enterprise-Grade Performance

### 5a. Memory Management

The Engine uses Zig's allocator model. Clients choose their
strategy:

| Allocator        | Use case                           |
|------------------|------------------------------------|
| GeneralPurpose   | Default, balanced (dev/prod)       |
| ArenaAllocator   | Batch operations, request scoping  |
| FixedBuffer      | Embedded, no-heap environments     |
| PageAllocator    | Large allocations, SIMD-aligned    |

Arena allocators enable request-scoped memory: allocate freely
during a request, free everything at once when done. Zero
fragmentation, zero leaks.

```c
StzArenaHandle arena = stz_arena_new(64 * 1024); // 64KB
// ... all operations use this arena ...
stz_arena_free(arena); // instant cleanup
```

### 5b. Thread Safety

Three concurrency modes:

| Mode         | API                          | Use case              |
|-------------|------------------------------|-----------------------|
| Single      | Default, no locking          | CLI, scripts          |
| Thread-safe | `stz_config_thread_safe(1)`  | Multi-threaded apps   |
| Lock-free   | Atomic data structures       | High-throughput       |

Thread-safe mode uses per-handle mutexes (no global lock).
Lock-free structures (concurrent hash map, lock-free queue) are
available for high-throughput scenarios.

### 5c. SIMD Acceleration

Zig's `@Vector` types enable SIMD for hot paths:

- String searching (16-byte parallel comparison)
- List operations (bulk comparison, filtering)
- Statistical computation (vectorized mean/variance)
- Byte operations (bulk XOR for crypto, popcount)
- Matrix multiplication (4x4 tile operations)

SIMD is transparent -- the same API works on all platforms, with
Zig emitting optimal instructions for each target.

### 5d. Zero-Copy Where Possible

- String slicing returns views, not copies
- List sections reference parent storage
- File reads use memory-mapped I/O for large files
- JSON parsing returns references into the source buffer

### 5e. Compile-Time Configuration

Build-time feature flags eliminate dead code:

```bash
stzengine build --features "no-crypto,no-regex,no-network"
```

Unused modules are not compiled, not linked, not shipped.
The resulting binary contains exactly what the client needs.

---

## 6. Security Architecture

### 6a. Memory Safety

Zig provides memory safety without garbage collection:

- Bounds checking on all array/slice access
- No null pointer dereferences (optional types)
- No use-after-free (ownership model)
- No buffer overflows (slice-based APIs)
- Stack canaries in release builds

### 6b. Cryptographic Safety

- Constant-time comparison for secrets (no timing attacks)
- Secure memory wiping (`stz_secure_zero`) after key use
- No secret material in error messages or logs
- CSPRNG for key generation (OS entropy source)

### 6c. Input Validation

Every C ABI function validates inputs before processing:

- NULL handle checks
- Buffer length validation
- UTF-8 validity verification
- Integer overflow detection

Invalid inputs return error codes, never crash.

### 6d. Sandboxing Support

The Engine can run in restricted mode:

```c
stz_config_sandbox(STZ_NO_FILESYSTEM | STZ_NO_NETWORK | STZ_NO_PROCESS);
```

This disables file, network, and process operations at the Engine
level -- useful for untrusted code execution environments.

---

## 7. Deployment Realities

### 7a. Target Matrix

Zig cross-compiles from any host to any target:

| Target              | Format    | Use case                    |
|---------------------|-----------|-----------------------------|
| x86_64-windows      | .dll      | Desktop, server             |
| x86_64-linux-gnu    | .so       | Server, cloud               |
| x86_64-linux-musl   | .so       | Alpine containers, static   |
| aarch64-linux-gnu   | .so       | ARM servers (AWS Graviton)  |
| aarch64-linux-musl  | .so       | ARM containers              |
| x86_64-macos        | .dylib    | macOS Intel                 |
| aarch64-macos       | .dylib    | macOS Apple Silicon         |
| wasm32-freestanding | .wasm     | Browser, edge               |
| arm-freestanding    | .a        | Embedded (bare metal)       |
| riscv64-freestanding| .a        | RISC-V embedded             |

### 7b. Deployment Modes

```
Cloud / Server:
  Docker image with Engine DLLs + language runtime
  OR stzengine serve (HTTP API mode)

Desktop:
  Ship Engine DLLs alongside application
  OR static-link into a single binary

Mobile (via Zin):
  Static library linked into the Zin runtime

Edge / IoT:
  Static library, no-std, FixedBuffer allocator
  ARM/RISC-V cross-compiled from dev machine

Browser:
  WASM build, no filesystem/network modules
  Engine functions callable from JavaScript

Embedded:
  Bare-metal static library
  Core layer only (minimal footprint)
  FixedBuffer allocator (no heap)
```

### 7c. Packaging

```bash
# Create a distribution package
stzengine pack --target x86_64-linux --layer base --format tar

# Output: softanza-engine-0.3.0-x86_64-linux.tar.gz
# Contains:
#   lib/libstz_string.so
#   lib/libstz_datetime.so
#   lib/...
#   include/softanza_engine.h
#   bin/stzengine
#   README.md
#   LICENSE
```

The `include/softanza_engine.h` file is auto-generated from the
Zig source -- a single header with all C ABI declarations.

---

## 8. Foreign Language Embedding (DLL-to-DLL)

### The Problem with stzExterCode

Currently, calling Python from Softanza means:
1. Write a temporary .py file
2. Spawn `python.exe` as a child process
3. Capture stdout
4. Parse the output back into Ring

This requires Python installed on the target, is slow (process
spawn per call), and fragile (text-based IPC).

### The Engine Solution: Direct DLL Linking

The Engine links against language runtimes as shared libraries:

```
softanza_engine.dll
    |
    +-- links libpython3.12.dll   (Python C API)
    +-- links libR.dll            (R C API)
    +-- links libjulia.dll        (Julia C API)
    +-- links libprolog.dll       (SWI-Prolog C API)
```

Engine functions call language interpreters directly in-process:

```c
// Execute Python code in-process (no python.exe needed)
StzPyHandle stz_python_init(void);
StzValue    stz_python_eval(StzPyHandle h, const char* code, size_t len);
StzValue    stz_python_call(StzPyHandle h, const char* module,
                             const char* function,
                             const StzValue* args, size_t num_args);
void        stz_python_free(StzPyHandle h);

// Same pattern for R, Julia, Prolog
StzRHandle  stz_r_init(void);
StzValue    stz_r_eval(StzRHandle h, const char* code, size_t len);
```

**Benefits:**
- No external runtime installation required on target
- In-process calls (microseconds, not milliseconds)
- Type-safe data exchange through StzValue (no text parsing)
- The Engine ships language DLLs as optional modules

**Build control:**

```bash
# Build with Python embedding
stzengine build --embed python

# Build with R + Julia
stzengine build --embed r,julia

# Build without any language embedding (default)
stzengine build
```

Language DLLs are optional -- they add capability without
affecting the core Engine footprint.

---

## 9. Configuration System

### 9a. Configuration File

`stzengine.toml` in the project root:

```toml
[engine]
version = "0.3.0"
layer = "base"            # core | base | max
allocator = "general"     # general | arena | fixed

[build]
target = "native"         # or "x86_64-linux-musl"
release = false
features = ["crypto", "regex", "json"]
domains = "all"           # or ["string", "datetime"]

[embed]
python = false
r = false
julia = false

[security]
sandbox = false
flags = []                # ["no-filesystem", "no-network"]

[serve]
port = 8080
modules = "all"

[paths]
ring = "D:/Ring126"       # auto-detected if not set
output = "./zig-out"
```

### 9b. Environment Variables

```
STZ_ENGINE_DIR     Path to Engine installation
STZ_ENGINE_LAYER   Override layer (core/base/max)
STZ_ENGINE_LOG     Log level (off/error/warn/info/debug)
STZ_RING_PATH      Path to Ring installation (for Ring clients)
```

### 9c. Discovery

The Engine auto-discovers its environment:

1. Check `stzengine.toml` in current directory
2. Check `STZ_ENGINE_DIR` environment variable
3. Check relative to the executable (`../lib/`, `../engine/`)
4. Check platform-standard paths (`/usr/lib/softanza/`, etc.)

---

## 10. Additional Design Concerns

### 10a. Versioning and ABI Stability

The Engine uses semantic versioning with ABI guarantees:

- **Patch** (0.3.x): Bug fixes, no ABI changes
- **Minor** (0.x.0): New functions added, existing unchanged
- **Major** (x.0.0): Breaking ABI changes (rare)

Every DLL exports a version function:

```c
uint32_t stz_engine_version(void);  // 0x000300 = 0.3.0
```

### 10b. Error Handling

Every fallible function returns an error code:

```c
typedef enum {
    STZ_OK = 0,
    STZ_ERR_NULL_HANDLE,
    STZ_ERR_OUT_OF_BOUNDS,
    STZ_ERR_INVALID_UTF8,
    STZ_ERR_OUT_OF_MEMORY,
    STZ_ERR_IO,
    STZ_ERR_PARSE,
    STZ_ERR_NOT_FOUND,
    STZ_ERR_PERMISSION,
    STZ_ERR_TIMEOUT,
} StzError;

const char* stz_error_message(StzError err);
StzError    stz_last_error(void);  // thread-local
```

### 10c. Logging and Observability

The Engine has a built-in structured logger:

```c
stz_log_set_level(STZ_LOG_INFO);
stz_log_set_callback(my_log_handler); // custom handler
```

Log output follows structured format for integration with
observability stacks (ELK, Grafana, etc.):

```
{"level":"info","module":"string","op":"replace","duration_us":42}
```

### 10d. Benchmarking Framework

Every module includes benchmarks:

```bash
stzengine bench string    # benchmark string operations
stzengine bench list      # benchmark list operations
stzengine bench --all     # benchmark everything
```

Output includes operations/second, memory usage, and comparison
against Ring-native equivalents (to validate Engine superiority).

### 10e. Documentation Generation

The CLI auto-generates documentation from Zig source:

```bash
stzengine docs            # generate HTML docs
stzengine docs --format md # generate Markdown
stzengine docs --c-header # generate softanza_engine.h
```

### 10f. Plugin Architecture

Third-party modules can extend the Engine:

```
stzengine plugin install softanza-ml    # ML operations
stzengine plugin install softanza-geo   # advanced GIS
stzengine plugin list                   # installed plugins
```

Plugins are Zig shared libraries that register functions through
the Engine's module system. They get the same C ABI, same CLI
integration, same bridge generation.

### 10g. Telemetry and Profiling

Built-in profiling for performance-sensitive deployments:

```c
stz_profile_start("my_operation");
// ... operations ...
stz_profile_end("my_operation");
stz_profile_report(buf, buf_len); // JSON report
```

### 10h. Migration Path from stzlib

The Engine will be extracted from stzlib in phases:

1. **Current**: Engine lives in `stzlib/engine/`, builds with
   stzlib's build system
2. **Next**: Engine gets its own `build.zig` with no stzlib
   dependencies. stzlib references Engine as a git submodule
   or system-installed library
3. **Final**: Engine is its own repository (`softanza-engine`).
   stzlib is one client among many. Ring bridge files ship with
   stzlib, not with the Engine. The Engine ships language-neutral
   C headers and the `stzengine` CLI.

---

## 11. Module Inventory (Complete)

### Layer 0: Foundational Types (5 modules)

| Module   | DLL              | Status  |
|----------|------------------|---------|
| value    | stz_value        | PLANNED |
| string   | stz_string       | DONE    |
| char     | stz_char         | DONE    |
| number   | stz_number       | PLANNED |
| bytes    | stz_bytes        | DONE    |

### Layer 1: Collection Data Structures (7 modules)

| Module   | DLL              | Status  |
|----------|------------------|---------|
| list     | stz_list         | PLANNED |
| hashmap  | stz_hashmap      | PLANNED |
| set      | stz_set          | PLANNED |
| table    | stz_table        | PLANNED |
| graph    | stz_graph        | PLANNED |
| matrix   | stz_matrix       | PLANNED |
| tree     | stz_tree         | PLANNED |

### Layer 2: Algorithms (10 modules)

| Module   | DLL              | Status  |
|----------|------------------|---------|
| stats    | stz_stats        | PLANNED |
| text     | stz_text         | PLANNED |
| walker   | stz_walker       | PLANNED |
| checker  | stz_checker      | PLANNED |
| yielder  | stz_yielder      | PLANNED |
| performer| stz_performer    | PLANNED |
| datetime | stz_datetime     | DONE    |
| file     | stz_file         | DONE    |
| regex    | stz_regex        | DONE    |
| json     | stz_json         | DONE    |

### Layer 3: Infrastructure Services (25 modules)

| Module   | DLL              | Status  |
|----------|------------------|---------|
| crypto   | stz_crypto       | PLANNED |
| codec    | stz_codec        | PLANNED |
| compress | stz_compress     | PLANNED |
| stream   | stz_stream       | PLANNED |
| watch    | stz_watch        | PLANNED |
| process  | stz_process      | PLANNED |
| async    | stz_async        | PLANNED |
| uuid     | stz_uuid         | PLANNED |
| url      | stz_url          | DONE    |
| html     | stz_html         | PLANNED |
| rng      | stz_rng          | PLANNED |
| solver   | stz_solver       | PLANNED |
| geo      | stz_geo          | PLANNED |
| bits     | stz_bits         | PLANNED |
| expr     | stz_expr         | PLANNED |
| locale   | stz_locale       | DONE    |
| system   | stz_system       | DONE    |
| embed    | stz_embed_*      | PLANNED |
| registry | stz_registry     | PLANNED |
| smallfn  | stz_smallfn      | PLANNED |
| execmodel| stz_exec         | PLANNED |
| cache    | stz_cache        | PLANNED |
| log      | stz_log          | PLANNED |
| profiler | stz_profiler     | PLANNED |
| callstack| stz_callstack    | PLANNED |

### Layer 4: Signature Features (11 modules)

| Module   | DLL              | Status  |
|----------|------------------|---------|
| pattern  | stz_pattern      | PLANNED |
| numtheory| stz_numtheory    | PLANNED |
| natlang  | stz_natlang      | PLANNED |
| ccode    | stz_ccode        | PLANNED |
| constr   | stz_constraint   | PLANNED |
| reactive | stz_reactive     | PLANNED |
| knowgraph| stz_knowgraph    | PLANNED |
| splitter | stz_splitter     | PLANNED |
| stringart| stz_stringart    | PLANNED |
| display  | stz_display      | PLANNED |
| univops  | stz_univops      | PLANNED |

### Layer 5: Paradigm Engines (12 modules)

Softanza's paradigm innovations codified as Engine-native modules.
Each represents a programming concept rethought from first
principles -- not a wrapper, but a new computational model.

| Module      | DLL                | Status  |
|-------------|------------------  |---------|
| reaxis      | stz_reaxis         | PLANNED |
| softanzuter | stz_softanzuter    | PLANNED |
| truth       | stz_truth          | PLANNED |
| quantifier  | stz_quantifier     | PLANNED |
| polyglot    | stz_polyglot       | PLANNED |
| polycode    | stz_polycode       | PLANNED |
| adverb      | stz_adverb         | PLANNED |
| timeline    | stz_timeline       | PLANNED |
| gridnav     | stz_gridnav        | PLANNED |
| sectmerge   | stz_sectmerge      | PLANNED |
| deepops     | stz_deepops        | PLANNED |
| namedvars   | stz_namedvars      | PLANNED |

### Layer 6: Universal Computation Concerns (11 modules)

General-purpose concerns every programmer needs, regardless of
language, domain, or technology. These serve Zin, Python, Rust,
AI agents, and any future technology equally.

| Module      | DLL                | Status  |
|-------------|------------------  |---------|
| provenance  | stz_provenance     | PLANNED |
| confidence  | stz_confidence     | PLANNED |
| explain     | stz_explain        | PLANNED |
| similarity  | stz_similarity     | PLANNED |
| context     | stz_context        | PLANNED |
| resource    | stz_resource       | PLANNED |
| validator   | stz_validator      | PLANNED |
| schema      | stz_schema         | PLANNED |
| intent      | stz_intent         | PLANNED |
| embedding   | stz_embedding      | PLANNED |
| sequence    | stz_sequence       | PLANNED |

| topology    | stz_topology       | PLANNED |
| relations   | stz_relations      | PLANNED |
| statemachine| stz_fsm            | PLANNED |

### Value Proposition Modules (2 modules)

Cross-cutting modules that implement the Engine's three value
propositions (Testability is a build-system concern, not a module).

| Module      | DLL                | Status  |
|-------------|------------------  |---------|
| interact    | stz_interact       | PLANNED |
| skill       | stz_skill          | PLANNED |

### Total: 88 modules (11 done, 77 planned)

---

## 12. Design Principles (Summary)

1. **Engine is the product.** Language surfaces are thin skins.
2. **Build only what you need.** Per-domain DLLs, compile-time
   feature flags, no wasted bytes.
3. **Same binary everywhere.** Zig cross-compiles to 10+ targets
   from any host. No platform-specific build chains.
4. **Ring adds beauty, not computation.** 6000+ semantic methods,
   natural coding, Q() chaining -- but zero algorithms.
5. **DLL-to-DLL, not exe-to-exe.** Foreign language integration
   through direct library linking, not process spawning.
6. **Enterprise from day one.** Thread safety, arena allocators,
   SIMD, sandboxing, structured logging, ABI stability.
7. **Developer joy.** The CLI makes building, testing, benchmarking,
   and deploying a single-command experience.
8. **No dependencies.** The Engine depends only on Zig's stdlib
   and vendored sources (utf8proc). No system libraries, no
   package managers, no transitive dependency chains.
9. **Generalize everything.** If an operation works on one data
   structure, it works on ALL structures that admit it. One
   function family, dispatched by type. No per-class silos.
10. **One display engine.** Every Show(), Boxed(), VizFind(),
    chart, table, tree, graph rendering goes through the unified
    canvas-based display engine. No duplicated rendering logic.
11. **Paradigm-native.** Every concept Softanza rethinks (reactive,
    truth, quantifiers, refinement, temporal, grid navigation)
    becomes an Engine module. Language surfaces inherit the
    paradigm -- they don't reinvent it.
12. **Softanzuter as agent substrate.** The trigger-compute-state
    reactive computation model is the canonical way to build
    intelligent agents across any pattern domain.
13. **Universal concerns are Engine concerns.** Provenance,
    confidence, explanation, similarity, context propagation,
    resource awareness, validation, schema evolution, intent
    resolution, vector math, and sequence windowing belong in the
    Engine -- not in application code. Every programmer needs them;
    no standard library provides them.
14. **Intelligence is geometry + provenance + explanation.** AI is
    not a special domain -- it is vectors (similarity), provenance
    (where data came from), confidence (how sure), explanation
    (why this result), and context (what state carries forward).
    The Engine provides these as general-purpose modules that
    happen to make AI natural.
15. **Every agent is a state machine.** Protocols, workflows, UIs,
    games, and AI agents all transition between discrete states on
    events. The Engine provides declared state machines so no
    programmer ever implements a switch-case state tracker again.
16. **Computation has topology.** Where code runs (local, cloud,
    GPU, edge) is a decision the Engine helps make via operation
    signatures and target capabilities -- not a deployment detail
    baked into application code.
17. **Testability is structural, not aspirational.** Four test
    layers (inline unit, simulation harness, CLI integration,
    narrated tests) are mandatory per module. A mechanical
    guardrail (L99) prevents real I/O in tests at compile time.
    No module ships without tests at all four layers.
18. **Interaction is intent, not pixels.** Programmers declare
    cognitive intents (DISCOVER, SELECT, ACT, CONFIRM). The
    Engine validates intent flows against constitutional laws
    (no SELECT-to-ACT collapse, UNDO covenant, DISCOVER-before-ACT)
    and projects them to any medium: web, terminal, voice, API,
    accessibility device, print. Write the logic once, render
    everywhere.
19. **The Engine teaches itself.** Every module declares
    prerequisite skills, skills it teaches, graded coding examples,
    and verifiable skill checks. The CLI can assess code for
    demonstrated skills and recommend learning paths. Training
    platforms built on the Engine inherit structured material --
    they do not author it.
