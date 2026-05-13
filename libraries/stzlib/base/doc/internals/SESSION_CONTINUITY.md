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

6. `core/common/stkRingLibs.ring`: conditional loading. When
   `$STZ_USE_ENGINE = TRUE` and Engine DLL exists, loads Engine
   via LoadLib instead of `load "qtcore.ring"`.

7. `core/string/stkString.ring`: full Engine-backed rewrite.
   Every method checks `_IsEngine()` and dispatches to either
   Engine C FFI calls or Qt fallback. Key methods wired:
   Content, Update, Size, At, Append, FindFirst/Last/All/Nth,
   InsertAt, Replace, ReplaceSection, Remove, RemoveSection,
   Split, Section, Contains, StartsWith, EndsWith, Simplify,
   UnicodeAt, Unicodes, Chars.

8. `core/string/stkChar.ring`: Engine-backed rewrite. Init from
   string/number/QChar, Content, Unicode, IsLetter/Digit/Upper/Lower.

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

- **Engine-first, Qt-fallback**: stkString/stkChar check `$STZ_ENGINE_LOADED`
  at each method call. When Engine is loaded, Qt is never touched.
  `qtcore.ring` is not even loaded when Engine is active.
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

### Strategic Repositioning: Zing

At the end of Session 2, the project was repositioned. What we
built is not "Softanza + an engine helper." It is **Zing** -- a
self-contained programming platform. Key decisions:

- **Zing is the product.** CLI becomes `zing` (not `softanza`).
- **Qt is removed entirely.** Not optional -- gone. Engine is the
  only code path. All `if _IsEngine()` branches become the default.
- **No Ring ecosystem.** Zing programs cannot load Ring libraries.
  They use the Zing stdlib (descended from Softanza) and nothing else.
- **Softanza is the paradigm name.** The coding style, principles,
  innovations. Zing is where Softanza runs.
- **Six output types:** notebook, exe, library, API, WASM, MCU.
- **Zing IDE:** native Zig, notebook-first, narration-aware.
- **Zin relationship deferred.** Zing stands alone. The Zin
  connection is architectural, discussed after Zing has identity.

See: `base/doc/design/ZING_PRODUCT_VISION.md`

## Phase 4 Plan (Next Session)

### 1. Rename and Purge Qt
1. Rename CLI from `softanza` to `zing` (cli/src/main.zig)
2. Remove ALL Qt fallback paths from stkString.ring, stkChar.ring
3. Remove `load "qtcore.ring"` from stkRingLibs.ring entirely
4. Remove `$STZ_ENGINE_LOADED` checks -- Engine is always loaded
5. Remove `_IsEngine()` method and all Qt branches from Core classes

### 2. Wire Base Layer (Qt-free)
1. Modify `base/string/stzString.ring`: replace `new QString2()` calls
   with Engine calls (3969 methods, ~300 Qt calls -- largest file)
2. Modify `base/datetime/stzDateTime.ring`: replace QDateTime calls
3. Modify `base/file/stzFile.ring` + `stzFolder.ring`: replace QFile/QDir
4. Modify `base/i18n/stzLocale.ring`: replace QLocale calls
5. Goal: ZERO Qt references in the entire codebase

### 3. Engine Tier 3
1. `engine/src/regex.zig`: pattern matching
2. `engine/src/json.zig`: JSON parse/generate
3. `engine/src/http.zig`: native HTTP server for `zing serve`

### 4. CLI Completion
1. Rename all commands to `zing run/test/build/serve/version/doctor`
2. Test runner: discover and run narrated test files
3. `zing serve`: start native HTTP server for API mode

### 5. Zing Identity (deferred to after implementation)
1. Think broadly about Zing-Zin relationship
2. Consider stdlib scope decisions
3. Plan the IDE architecture in detail
