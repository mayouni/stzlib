# Softanza Strategic Work -- Session Continuity

## Session 1 (2026-05-13): Phase 1 + Phase 2

### What Was Done

**Phase 1 -- Layer Audit & Architecture:**
- Archive backup: `D:\GitHub\stzlib-archive-ad4b3b17-2026-05-13.zip` (81MB)
- Three-layer audit completed (Core/Base/Max/Future)
- Fixed Max loader: removed 10 duplicate file loads from `max/stzmax.ring`
- Created layer architecture contract: `base/doc/internals/softanza-layer-architecture.md`
- Created Engine design doc: `base/doc/design/SOFTANZA_ENGINE_DESIGN.md`
- Updated `readme.txt` with full 7-principle architecture overview
- Created test runner: `tools/test-runner.ring`
- Commit: `d0bec5a1`

**Phase 2 -- Softanza Engine + Core Stubs:**
- Built working Softanza Engine in Zig (`engine/`)
- `engine/src/string.zig`: 20 C ABI functions replacing QString2
- `engine/src/char.zig`: 6 C ABI functions replacing QChar
- `engine/src/engine.zig`: main entry, exports all symbols
- `engine/build.zig`: builds DLL (952KB) + static lib
- `engine/stzengine.ring`: Ring FFI bridge
- **15 tests all passing** (`zig build test --summary all`)
- Filled 4 empty Core stubs: stkGlobals, stkStringCommons, stkListCommons, stkObjectCommons
- Updated `stzlib.ring`: supports `$STZ_LAYER = :core | :base | :max`
- Commit: `e18cbcb2`

## Session 2 (2026-05-13): Phase 3

### What Was Done

**WS-4b: Engine Tier 2 (3 new modules, 62 C ABI functions)**

1. `engine/src/datetime.zig` -- 35 functions replacing QDate/QTime/QDateTime:
   - Date: new, today, free, year, month, day, dayOfWeek, dayOfYear,
     daysInMonth, daysInYear, isLeapYear, addDays, diffDays, toString,
     toISO, format, compare, dayName, monthName
   - Time: new, newMs, now, free, hour, minute, second, millisecond,
     hour12, isPM, addSeconds, addMs, toString, toString12h, compare
   - DateTime: new, now, fromUnix, free, year, month, day, hour, minute,
     second, addDays, addSeconds, toUnix, toISO, compare, isBetween

2. `engine/src/file.zig` -- 17 functions replacing QFile/QDir/QFileInfo:
   - File: exists, size, read, readFree, write, append, delete, copy
   - Dir: exists, create, createPath, delete, countFiles, countDirs
   - Path: extension, basename, dirname (cross-platform / and \)

3. `engine/src/locale.zig` -- 10 functions replacing QLocale:
   - amText, pmText, toUpper, toLower, toTitlecase, formatNumber,
     monthName, monthAbbr, dayName, dayAbbr

4. `engine/src/engine.zig` updated: imports + exports all 88 symbols
   (26 Tier 1 + 62 Tier 2). Version bumped to 0.2.0.

5. **40/40 tests passing**. DLL size: 1118KB (was 952KB).

**WS-4c: Core Wired to Engine**

6. `core/common/stkRingLibs.ring`: loads Engine via LoadLib
   (Qt loading fully removed).

7. `core/string/stkString.ring`: full Engine-backed rewrite.
   All methods dispatch to Engine C FFI calls. Key methods wired:
   Content, Update, Size, At, Append, FindFirst/Last/All/Nth,
   InsertAt, Replace, ReplaceSection, Remove, RemoveSection,
   Split, Section, Contains, StartsWith, EndsWith, Simplify,
   UnicodeAt, Unicodes, Chars.

8. `core/string/stkChar.ring`: Engine-backed rewrite. Init from
   string/number/codepoint, Content, Unicode, IsLetter/Digit/Upper/Lower.

**WS-6: Softanza CLI**

9. `cli/build.zig` + `cli/src/main.zig`: working Zig executable.
   Commands: run, test, build, version, doctor, help.
   Built and tested: `softanza version` shows 0.2.0.

10. `base/doc/design/SOFTANZA_CLI_DESIGN.md`: design document.

**WS-8: Zing Bridge Architecture**

11. `base/doc/design/ZING_BRIDGE_DESIGN.md`: architecture document.
    Maps Engine modules to Zin pillars, defines 4 integration phases
    (static linking, pillar delegation, unified tests, pack integration).

### Key Decisions

- **Engine-only**: stkString/stkChar use Engine FFI exclusively.
  All Qt code paths have been removed. No Qt dependency remains.
- **Cross-platform paths**: file.zig path utilities handle both `/` and `\`
  with custom logic (not std.fs.path which is OS-specific).
- **Zig 0.15.2 API**: used `deprecatedWriter()` for console output,
  `.{}` init for ArrayList, `.c` for callconv, `b.addLibrary` with
  `.linkage` for shared/static libs.

### Zig API Notes (v0.15.2)
- `std.fs.File.stdout()` replaces `std.io.getStdOut()`
- `.deprecatedWriter()` on File gives the old-style Writer
- ArrayList: unmanaged `.{}` init, pass allocator to every method
- Tests need `link_libc = true` in module
- Libraries use `b.addLibrary(.{ .linkage = .dynamic })` not `addSharedLibrary`
- Tests use `.root_module = b.createModule(.{...})` not `.root_source_file`

### Repository State

- Repo: `D:\GitHub\stzlib` (Codeberg remote)
- Engine built: `engine/zig-out/bin/softanza_engine.dll` (1118KB)
- CLI built: `cli/zig-out/bin/softanza.exe`
- 40 Engine tests passing
- 1 CLI test passing

### Design Decision: Engine-Only, No Qt

Softanza is a Ring library -- but a self-sufficient one.
The only dependencies are Ring itself and the Softanza Engine
(a Zig shared library). No Qt, no Ring extensions, no external
C/C++ libraries. A Ring programmer does `load "stzlib.ring"`
and everything works with just Ring + Engine installed.

This means (all completed):
- **All Qt code paths removed.** Not optional -- gone.
- **All `_IsEngine()` checks removed.** Engine is always loaded.
- **`load "qtcore.ring"` removed.** No Ring extensions at all.
- **Engine replaced Qt completely** for strings, dates, files,
  locale, regex, JSON, and everything else Qt provided.
- **Still a Ring library.** Programs are Ring code. They use
  Ring syntax, Ring's interpreter, and Softanza's classes.
  But the backend is 100% Zig Engine.

### Design Decision: Modular Engine

The Engine mirrors the library's granularity. A Ring programmer
who loads only `stkString.ring` should not pull in a monolithic
DLL with datetime and locale code. The Engine builds as separate
per-domain shared libraries:

```
engine/zig-out/bin/
  stz_string.dll      # string.zig + char.zig (Core+Base string ops)
  stz_datetime.dll    # datetime.zig (date, time, datetime)
  stz_file.dll        # file.zig (file, dir, path)
  stz_locale.dll      # locale.zig (formatting, names, case)
  stz_regex.dll       # regex.zig (pattern matching)
  stz_json.dll        # json.zig (parse/generate)
```

Three levels of granularity on both Ring side and Engine side:

**Level 1 -- Full library:**
```ring
load "stzlib.ring"             # all modules, all engine DLLs
```

**Level 2 -- One layer:**
```ring
$STZ_LAYER = :core
load "stzlib.ring"             # core modules + stz_string.dll
```

**Level 3 -- One module:**
```ring
load "base/string/stzString.ring"  # stz_string.dll only
load "base/datetime/stzDate.ring"  # stz_datetime.dll only
```

Each Ring module file loads only the Engine DLL it needs via
`LoadLib()`. The build system (`build.zig`) produces all DLLs
independently. The `softanza build` CLI command can build
individual modules or everything.

This matters for:
- **Small apps** that use one Softanza domain: tiny footprint
- **Embedded/MCU targets**: load only what fits in memory
- **Distribution**: ship only the DLLs your app actually uses
- **Build time**: rebuild only the module you changed

## Session 3 (2026-05-14): Phase 4

### What Was Done

**Phase 4 Task 1: Split Engine into Modular DLLs (DONE)**

1. Created per-domain entry point files in `engine/src/`:
   - `stz_string_entry.zig`: exports 26 symbols (string + char)
   - `stz_datetime_entry.zig`: exports 50 symbols (date + time + datetime)
   - `stz_file_entry.zig`: exports 17 symbols (file + dir + path)
   - `stz_locale_entry.zig`: exports 10 symbols (locale)

2. Refactored `engine/build.zig`: data-driven domain table produces
   4 shared libraries + 1 static lib + tests. No monolithic DLL.

3. Created per-domain Ring FFI bridges:
   - `engine/stz_string.ring`: loads stz_string.dll, 25 wrapper functions
   - `engine/stz_datetime.ring`: loads stz_datetime.dll, 33 wrapper functions
   - `engine/stz_file.ring`: loads stz_file.dll, 16 wrapper functions
   - `engine/stz_locale.ring`: loads stz_locale.dll, 10 wrapper functions

4. `engine/stzengine.ring` becomes convenience "load all" (4 lines).

5. CLI updated: version shows 0.3.0 + module breakdown, doctor
   checks each DLL individually.

6. Build output after clean build:
   - stz_string.dll (930 KB)
   - stz_datetime.dll (932 KB)
   - stz_file.dll (996 KB)
   - stz_locale.dll (959 KB)
   - softanza_engine_static.lib (2440 KB)

7. **40/40 Engine tests passing, 1/1 CLI test passing.**

**Phase 4 Task 1b: Layered Engine -- Core/Base DLL Tiers (DONE)**

8. Three-layer architecture applied to Engine DLLs:
   - **Core (stk_*):** minimal subset for speed and constrained envs
   - **Base (stz_*):** full features, strict superset of Core
   - Each Base DLL exports ALL Core functions plus additions
   - A Ring program loads ONE DLL per domain per layer

9. Created Core entry point files in `engine/src/`:
   - `stk_string_entry.zig`: 12 funcs (lifecycle + data + search + char basics)
   - `stk_datetime_entry.zig`: 24 funcs (lifecycle + components + compare)
   - `stk_file_entry.zig`: 6 funcs (exists + read/write/delete + dir_exists)
   - `stk_locale_entry.zig`: 2 funcs (to_upper + to_lower)

10. Created Core Ring FFI bridges:
    - `engine/stk_string.ring`, `stk_datetime.ring`, `stk_file.ring`, `stk_locale.ring`
    - `engine/stkengine.ring`: convenience "load all Core" (4 lines)

11. Build output -- 8 DLLs total:
    - stk_string.dll (912 KB), stk_datetime.dll (912 KB)
    - stk_file.dll (920 KB), stk_locale.dll (898 KB)
    - stz_string.dll (930 KB), stz_datetime.dll (932 KB)
    - stz_file.dll (996 KB), stz_locale.dll (959 KB)

12. CLI updated: version shows layered architecture, doctor checks
    all 8 DLLs. **40/40 Engine tests, 1/1 CLI test passing.**

### Design Decision: Layered DLLs

Each class exists in three layers with incremental features:

- **Core (stk_*):** Minimalistic, made for speed, no syntax sugar,
  works on constrained environments. DLL naming: `stk_<domain>.dll`.
- **Base (stz_*):** All features. The full Softanza API with ergonomics,
  rich methods, formatting, arithmetic. DLL: `stz_<domain>.dll`.
- **Max (stx_*):** Everything in Base plus engine-level advanced
  facilities (large data optimizations, parallel processing, streaming).
  DLL: `stx_<domain>.dll`. Future -- no Max DLLs yet.

Each higher-tier DLL is a strict superset: Base exports all Core
symbols plus its own. Handles created in one tier work seamlessly
because the same Zig code backs both DLLs.

Loading rules:
- Core layer loads `stk_*.dll` only
- Base layer loads `stz_*.dll` (which includes Core functions)
- Base module automatically gets its Core dependency

## Phase 4 Remaining Plan

### ~~1. Split Engine into Modular DLLs~~ (DONE)
### ~~1b. Layered Engine -- Core/Base DLL Tiers~~ (DONE)

### ~~2. Purge Qt from Core Layer~~ (DONE)
1. ~~Remove `load "qtcore.ring"` from stkRingLibs.ring~~
2. ~~stkRingLibs.ring loads stz_string.dll directly~~
3. ~~Remove `_IsEngine()` method and ALL Qt branches from stkString.ring~~
4. ~~Remove ALL Qt branches from stkChar.ring~~
5. ~~Engine is the only code path -- no fallback~~

### ~~3. Purge Qt from Base Layer~~ (DONE)
1. ~~Each Base module loads its own Engine DLL~~
2. ~~Replace every `new QString2()` with Engine calls~~
3. ~~Replace every QDateTime/QFile/QDir/QLocale call~~
4. ~~Grep entire codebase for remaining Qt references~~
5. ~~Goal: ZERO Qt references in Softanza code~~ (achieved)

### ~~4. Engine Tier 3~~ (DONE)
1. ~~`engine/src/regex.zig` -> stz_regex.dll~~
2. ~~`engine/src/json.zig` -> stz_json.dll~~
3. ~~All Qt calls replaced by Engine~~

### 5. CLI Polish
1. `softanza build` builds individual or all Engine DLLs
2. `softanza test` discovers and runs narrated test files
3. `softanza doctor` verifies Ring + per-module Engine DLLs

### ~~6. Validation~~ (DONE)
1. ~~Run existing test suite (Engine-only, no Qt)~~
2. ~~Fix any failures from the Qt removal~~
3. Confirm all narrated tests produce expected output
4. Verify module-level loading works (load one module only)

## Session 4 (2026-05-15): Phase 5 -- Deep Design from Paradigm Audit

### What Was Done

**Phase 5: Complete Paradigm Audit + Engine Design Deepening**

1. Scanned entire Softanza documentation tree. Found **60+
   paradigm-rethinking documents** across narrations/, deepdives/,
   design/, and internals/ directories.

2. Read and analyzed **10 source code implementations**:
   stzWalker, stzReactive, stzReactiveObject, stzReactiveTask,
   stzRegexuter, stzListex, stzGraphex, stzTimeLine, stzNatural,
   stzConstraint.

3. **Layer 5: Paradigm Engines (12 modules)** added to Engine
   design. Reaxis (Container->Stream->Rfunction), Softanzuter
   (universal reactive computation medium for agents), Truth
   Engine, Quantifier Engine, Polyglot Bridge, Refinement Engine,
   Adverb Engine, Timeline Engine, Grid Navigator, Section
   Merger, Deep Operations, Named Variables.

4. **Layer 6: Universal Computation Concerns (14 modules)** added.
   Provenance (data lineage), Confidence (values with uncertainty),
   Explanation (auditable reasoning), Similarity (beyond equality),
   Context (scoped state propagation), Resource Awareness (cost
   before execution), Validation Pipeline (multi-stage checking),
   Schema Evolution (structural change over time), Intent
   Resolution (what-not-how dispatch), Embedding/Vector (geometric
   computation), Sequence/Windowing (sliding/tumbling/session),
   Computation Topology (local/remote fission), Relationships
   (entity connections), State Machine (declared transitions).

5. **Enhancement notes** added to existing modules from deep doc
   audit: regex (scope context, hierarchical captures), pattern
   matching (table metadata, temporal intervals), walker (N-D
   extension), reaxis (change batching), serialization (structural
   encoding).

6. **"Softanza Through Claude's Eyes"** document written --
   reflection on how understanding evolved from "a rich Ring
   library" to "a programming philosophy that has been implemented."

7. **16 design principles** now in Architecture doc (was 10).

### Key Decisions

- **Intelligence is not a special domain.** AI needs vectors
  (similarity), provenance (where data came from), confidence
  (how sure), explanation (why this result), and context (what
  carries forward). These are general-purpose modules that happen
  to make AI natural. No AI-specific modules needed.
- **Softanzuter is the agent substrate.** The trigger-compute-
  state model from stzRegexuter, generalized across any pattern
  domain, is the canonical way to build intelligent agents.
- **Every agent is a state machine.** Declared transitions with
  guards, history, and validation replace ad-hoc switch-case
  state trackers everywhere.
- **Computation has topology.** Where code runs is an Engine
  decision based on operation signatures, not a deployment
  detail baked into application code.

### Repository State

- Repo: `D:\GitHub\stzlib` (GitHub + Codeberg remotes)
- Engine design: 86 modules (11 done, 75 planned) across 7 layers
- Architecture: 16 design principles
- All 60+ paradigm documents, 8 deepdives, 5 internals, 7 design
  docs fully audited. No unread documents remain.
- Commits: 41f8443d, d99fd2c5, 4c36c4be, 626aae22

### Next Steps

- **Phase F (code):** Build StzValue tagged union + List in Zig.
  These two modules unlock heterogeneous operations and kill the
  Stringify trick. The design is now complete enough to code
  confidently.
- **CLI Polish:** `softanza build`, `softanza test`, `softanza
  doctor` (Phase 4, task 5 -- still pending).

## Session 4b (2026-05-15): Three Value Propositions

### What Was Done

**Three cross-cutting value propositions added to Engine design:**

1. **VP-1 Testability:** 4-layer testing discipline (inline unit,
   simulation harness, CLI integration, narrated GIVEN/WHEN/THEN).
   L99 mechanical guardrail (no real I/O in tests). Test density
   tracking via CLI. C ABI for external test harnesses.

2. **VP-2 Usability -- Interaction Engine:** Intent-based
   interaction layer with 24 cognitive verbs in 6 categories
   (Orienting/Attention/Information/Selection/Action/Continuity).
   Constitutional laws enforced at Engine level (no SELECT-to-ACT
   collapse, UNDO covenant, DISCOVER-before-ACT, accessibility
   invariant). Medium-agnostic rendering projections (web, TUI,
   voice, API, accessibility, print). Full C ABI. New module:
   `stz_interact`.

3. **VP-3 Learnability -- Skill Engine:** Skill metadata per
   module (prerequisites, skills taught, graded examples, skill
   checks). CLI skill commands (list, prereqs, check, path,
   assess). Code-aware skill assessment. JSON export for training
   platforms. New module: `stz_skill`.

**Updated files:**
- `base/doc/design/SOFTANZA_ENGINE_DESIGN.md` -- added VP-1,
  VP-2, VP-3 sections with full C ABI specs (~400 lines)
- `base/doc/design/SOFTANZA_ENGINE_ARCHITECTURE.md` -- added
  2 VP modules, 3 new design principles (17-19), total 88 modules

### Next Steps

- **Phase F (code):** Build StzValue tagged union + List in Zig
- **CLI Polish:** `softanza build`, `softanza test`, `softanza
  doctor`
- **Interaction Engine prototype:** Implement `stz_interact` with
  at least the flow declaration and validation APIs
- **Skill metadata format:** Define the `.skill.zig` companion
  file format for module skill declarations
