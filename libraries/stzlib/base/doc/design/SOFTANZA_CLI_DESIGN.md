# Softanza CLI Design

## Purpose

A single `softanza` binary (built in Zig) that manages the Softanza
development lifecycle. It bundles the Engine and invokes Ring, so the
developer never touches platform-specific paths.

## Commands

```
softanza run <file.ring>       Run a Ring script with Softanza loaded
softanza test [dir|file]       Run test files, report pass/fail counts
softanza build                 Build the Engine DLL from engine/src/
softanza notebook <file.stzn>  Open an interactive notebook (future)
softanza version               Show Engine + Ring + Zig versions
softanza doctor                Check that Ring, Engine, and paths are correct
```

## Architecture

```
softanza (Zig executable)
    |
    +-- Engine (statically linked)
    |     string.zig, char.zig, datetime.zig, file.zig, locale.zig
    |
    +-- Ring launcher
    |     Finds ring.exe in PATH or $RING_HOME
    |     Prepends stzlib load path
    |     Sets $STZ_USE_ENGINE = TRUE
    |
    +-- Test runner
    |     Discovers *test*.ring in base/test/ and core/test/
    |     Runs each via Ring, captures exit code + output
    |     Reports summary: passed/failed/skipped
    |
    +-- Doctor
          Checks: Ring reachable? Engine DLL exists?
          Reports versions, paths, layer status
```

## Implementation Plan

### Phase 1: CLI skeleton (Zig)
- `cli/main.zig`: arg parser, command dispatch
- `cli/runner.zig`: spawn Ring with correct env
- `cli/tester.zig`: discover + run test files
- `cli/build.zig`: wrapper around `zig build` in engine/
- Statically link the Engine so `softanza run` can preload it

### Phase 2: Test runner
- Glob `base/test/stz*test*.ring` and `core/test/stk*test*.ring`
- For each: spawn `ring <file>`, capture stdout/stderr, measure time
- Print summary table: file, status, duration
- Exit code = number of failures

### Phase 3: Notebook (future, WS-7)
- `.stzn` format: JSON array of cells
- Each cell: `{ "type": "code"|"markdown", "source": "...", "output": "..." }`
- Terminal renderer: syntax-highlighted code, formatted markdown
- Execute cells via Ring subprocess, capture output

## Value Proposition

1. **Single entry point**: `softanza run` replaces `ring -e "load stzlib.ring" ...`
2. **Qt-free path**: Engine is statically linked, no DLL hunting
3. **Test discipline**: `softanza test` gives a proper test runner with counts
4. **Discovery**: `softanza doctor` diagnoses setup issues instantly

## Zin Comparative Advantage

The CLI maps directly to Zin's tool philosophy:
- `softanza run` = `zin run` for Ring programs
- `softanza test` = `zin test` with narrated output
- `softanza build` = `zin build` for the Engine substrate
- When the Zing bridge ships, `softanza` becomes a Zin dialect tool
