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

### Key Findings from Audit

**Layer Status:**
- Core: 7 complete classes (stkNumber 53 methods, stkString 51, stkChar 7, stkList 28, stkBuffer 65, stkPointer 66, stkMemory 24)
- Base: 20 domains, major classes: stzString ~3969 methods, stzList ~3026, stzTable ~2472
- Max: Fixed. True Max-only classes: Walker, Parser, BigNumber, MultiString, TextEncoding, BinaryFile, Testoor
- Future: 11 candidates assessed; only stzFunction.ring ready to promote; rest experimental

**Qt Dependencies (337+ instances, 380+ calls):**
- Tier 1 (DONE in Engine): QString2 (~300 calls), QChar (42 calls)
- Tier 2 (TODO): QDate/QTime (62), QFile/QDir (42), QLocale (27)
- Tier 3 (TODO): QRegExp (1), QJson* (~5), QVariant (42), QProcess (2)

**Test Coverage:**
- 181 test files across Core/Base/Max
- 49% class coverage, 18% narration coverage
- Strong: datetime (100%), regex (91%), number (83%)
- Weak: cluster (0%), error (0%), appserver (17%)

### Zig API Notes (v0.15.2)
- Use `.c` not `.C` for calling convention
- ArrayList is unmanaged: init with `.{}`, pass `gpa` to every method
- Tests need `link_libc = true` in module
- Libraries use `b.addLibrary(.{ .linkage = .dynamic })` not `addSharedLibrary`
- Tests use `.root_module = b.createModule(.{...})` not `.root_source_file`

## Phase 3 Plan (Next Session)

### WS-4b: Extend Engine Tier 2
1. Add `engine/src/datetime.zig`: date/time operations (replaces QDate/QTime/QDateTime)
2. Add `engine/src/file.zig`: file system operations (replaces QFile/QDir/QFileInfo)
3. Add `engine/src/locale.zig`: locale formatting (replaces QLocale)
4. Update `engine/src/engine.zig` to export new symbols
5. Update `engine/stzengine.ring` with new Ring wrappers
6. Build and test

### WS-4c: Wire Core to Engine
1. Modify `core/common/stkRingLibs.ring`: add conditional Engine loading
2. Modify `core/string/stkString.ring`: replace `new QString2()` with Engine calls
3. Modify `core/string/stkChar.ring`: replace `new QChar()` with Engine calls
4. Test that Core layer works with Engine instead of Qt
5. Goal: `load "qtcore.ring"` becomes optional

### WS-6: Softanza CLI
1. Create `softanza` CLI tool (Zig executable)
2. Commands: `softanza run`, `softanza test`, `softanza build`, `softanza notebook`
3. Bundles Ring + Engine for single-binary distribution

### WS-7: Interactive Notebook
1. `.stzn` format: JSON cells with Ring code + markdown + output
2. Terminal-based renderer (no Qt/browser dependency)
3. Backed by Engine for text rendering

### WS-8: Zin Bridge ("Zing")
1. Map Engine modules to Zin pillars
2. Softanza Engine becomes part of Zin stdlib
3. Document the "Zing" architecture

## Repository State

- Repo: `D:\GitHub\stzlib` (Codeberg remote)
- Branch: `main`
- Commits ahead of origin: 2
- Pending unstaged changes: stzlib.zip, 2 test files (pre-existing)
- Engine built: `engine/zig-out/bin/softanza_engine.dll` (952KB)
