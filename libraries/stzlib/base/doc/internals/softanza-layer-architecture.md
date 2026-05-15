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
| Core  | stk*   | stkString        | Lean, fast, Qt-direct         |
| Base  | stz*   | stzString        | Rich, semantic, human-centric |
| Max   | stx*   | stxMultiString   | Advanced, specialized, wings  |

Each layer replicates the same domain structure (string/, list/,
number/, object/, system/, error/, common/).

## Layer Rules

### Core Layer (stk*)
- Wraps Qt/Ring primitives directly
- No business logic, no semantic sugar
- Every method does exactly one thing
- Dependencies: Ring stdlib + Qt only
- Target: fast operations, embedded, constrained platforms

### Base Layer (stz*)
- Builds on Core via inheritance or delegation
- Adds: function alternatives, named parameters, Q() chaining
- Adds: natural coding keywords, conditional code, constraints
- All 20 functional domains live here
- Dependencies: Core layer only

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

## Engine Architecture (Qt fully replaced)

All layers now use the Zig-based Softanza Engine via C FFI.
No Qt dependency remains.

### Core Layer (stk_* DLLs)
- stkString -> StkEngine* FFI (string operations)
- stkChar -> StkEngine* FFI (unicode operations)

### Base Layer (stz_* DLLs)
- stzString -> StzEngine* FFI (string operations)
- stzChar -> StzEngineUnicode* FFI (unicode)
- stzFile -> StzEngineFile* FFI (filesystem)
- stzFolder -> Ring file ops
- stzDate -> StzEngineDateTime* FFI
- stzTime -> Pure Ring implementation
- stzDateTime -> StzEngineDateTime* FFI
- stzRegex -> StzEngineRegex* FFI
- stzLocale -> StzEngineLocale* FFI

### Engine-Free Domains
These domains use pure Ring (no engine DLLs):
- number, list, object, graph, stats, natural
- network, reactive, appserver, cluster

Softanza is dependency-free: Ring + Engine DLLs only.
