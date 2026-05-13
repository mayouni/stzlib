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
    │       CORE  (stk*)          │  Lean: Qt-direct, minimal wrap
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

## Qt Dependency Map

### Core Layer Qt Usage
- stkString -> QString2 (append, split, replace, trimmed, etc.)
- stkChar -> QChar, QString2 (unicode operations)
- stkRingLibs -> loads qtcore.ring

### Base Layer Qt Usage (via Core + direct)
- stzString -> QStringObject() (5000+ references)
- stzChar -> QChar operations
- stzFile -> QFile, QFileInfo, QDir
- stzFolder -> QDir
- stzDate -> QDate
- stzTime -> QTime
- stzDateTime -> QDateTime
- stzRegex -> QRegex, QMatch
- stzLocale -> QLocale

### Max Layer Qt Usage
- None direct (inherits via Base)

### Qt-Free Domains
These domains use NO Qt and are portable as-is:
- number (pure arithmetic)
- list (pure Ring lists)
- object (pure Ring objects)
- graph (pure algorithms)
- stats (pure computation)
- natural (pure parsing)
- network (Ring networking)
- reactive (Ring + libuv)
- appserver, cluster, extincode, extercode

## Softanza Engine Strategy

To eliminate Qt dependency, a Softanza Engine (Zig binary)
will replace Qt operations through C FFI:

| Qt Class     | Engine Replacement          |
|--------------|-----------------------------|
| QString2     | UTF-8/UTF-16 string ops     |
| QChar        | Unicode codepoint ops       |
| QRegExp      | Regex engine (PCRE2 or Zig) |
| QDate/QTime  | Date/time arithmetic        |
| QFile/QDir   | File system operations      |
| QLocale      | Locale data + formatting    |

This makes Softanza dependency-free: Ring + Engine binary only.
