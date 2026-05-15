# Softanza Layer Architecture Contract

## Three-Layer Pyramid

Softanza is structured as a three-layer pyramid where each layer
builds on the one beneath it:

```
    ┌─────────────────────────────┐
    │        MAX  (stx*)          │  Advanced: walkers, parsers,
    │   Wings plugin system       │  big numbers, testing, wings
    ├─────────────────────────────┤
    │       BASE  (stz*)          │  Rich: 20 domains, 6000+ methods
    │  Full Softanza experience   │  semantic API, natural coding
    ├─────────────────────────────┤
    │       CORE  (stk*)          │  Lean: Engine-direct, minimal wrap
    │  Performance substrate      │  7 classes, ~300 methods
    └─────────────────────────────┘
```

## Naming Convention

| Layer | Prefix | Example          | Purpose                       |
|-------|--------|------------------|-------------------------------|
| Core  | stk*   | stkString        | Lean, fast, Engine-direct     |
| Base  | stz*   | stzString        | Rich, semantic, human-centric |
| Max   | stx*   | stxMultiString   | Advanced, specialized, wings  |

Each layer replicates the same domain structure (string/, list/,
number/, object/, system/, error/, common/).

## Layer Rules

### Core Layer (stk*)
- Delegates all heavy work to the Softanza Engine (Zig)
- No business logic, no semantic sugar
- Every method does exactly one thing
- Dependencies: Ring language + Engine DLLs only
- Target: fast operations, embedded, constrained platforms

### Base Layer (stz*)
- Builds on Core via inheritance or delegation
- Adds: function alternatives, named parameters, Q() chaining
- Adds: natural coding keywords, conditional code, constraints
- All 20 functional domains live here
- Dependencies: Core layer + Engine DLLs

### Max Layer (stx*)
- Builds on Base
- Adds: walkers, parsers, big numbers, text encoding
- Adds: wings plugin system (data, security, intelligence, etc.)
- Adds: testing framework (stzTestoor)
- Dependencies: Base layer only
- MUST NOT re-load files already loaded by Base

## Domain Inventory

| Domain     | Core (stk*) | Base (stz*) | Max (stx*) |
|------------|:-----------:|:-----------:|:----------:|
| string     | Y           | Y           | Y          |
| number     | Y           | Y           | Y          |
| list       | Y           | Y           | -          |
| object     | Y           | Y           | -          |
| system     | Y           | Y           | Y          |
| error      | Y           | Y           | Y          |
| common     | Y           | Y           | Y          |
| file       | -           | Y           | -          |
| datetime   | -           | Y           | -          |
| regex      | -           | Y           | -          |
| graph      | -           | Y           | -          |
| stats      | -           | Y           | -          |
| i18n       | -           | Y           | -          |
| natural    | -           | Y           | -          |
| reactive   | -           | Y           | -          |
| network    | -           | Y           | -          |
| appserver  | -           | Y           | -          |
| cluster    | -           | Y           | -          |
| extincode  | -           | Y           | -          |
| extercode  | -           | Y           | -          |
| data       | -           | Y           | Y          |
| wings      | -           | -           | Y          |
| test       | -           | -           | Y          |

## Future Layer

The `future/` directory holds experimental features not yet
promoted. Promotion path: future/ -> max/ or base/ after
stabilization and testing.

Ready-to-promote: stzQEngine, stzMultiObjectiveSolver,
stzStochasticSolver, stzCobol, stzCache, stzTurboList,
stzTextStream, stzConstraint, stzFolderWatcher, stzProfiler,
stzFunction.

## Engine Architecture

All heavy computation is delegated to the Zig-based Softanza
Engine via C FFI. Ring provides only the language runtime
(syntax, OOP, scripting) -- never the algorithms.

**Design principle:** Ring stdlib functions are unreliable for
Softanza's needs (e.g. `len()` counts bytes not Unicode
codepoints, list operations are slow, no proper string search).
Every operation that touches data -- strings, numbers, lists,
dates, files -- must go through the Engine.

### Core Layer (stk_* DLLs)
- stkString -> StkEngine* FFI (string operations)
- stkChar -> StkEngine* FFI (unicode operations)

### Base Layer (stz_* DLLs)
- stzString -> StzEngine* FFI (string operations)
- stzChar -> StzEngineUnicode* FFI (unicode)
- stzFile -> StzEngineFile* FFI (filesystem)
- stzFolder -> StzEngineFile* FFI (directory operations)
- stzDate -> StzEngineDateTime* FFI
- stzTime -> StzEngineDateTime* FFI
- stzDateTime -> StzEngineDateTime* FFI
- stzRegex -> StzEngineRegex* FFI
- stzLocale -> StzEngineLocale* FFI

### Domains Pending Engine Migration
These domains currently use Ring but are planned for Engine:
- number (Engine: arbitrary precision, fast arithmetic)
- list (Engine: search, sort, replace, stringify)
- object (Engine: reflection, serialization)
- graph, stats (Engine: algorithms, computation)
- natural (Engine: NLP tokenization, parsing)
- network, reactive, appserver, cluster (Engine: I/O, async)

Softanza is dependency-free: Ring language + Engine DLLs only.
