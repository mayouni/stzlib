---
name: fast-path
description: Run stzlib's fast path, the gates and Testoor the right way, with their exit codes and costs. Use when asked to "run the tests", "gate this", "verify before commit" or "is it green".
---

# Fast path and gates

The inner loop, edit to verdict, targets seconds; a monolithic suite is a pre-commit
gate, run once per task, never after every edit (`CLAUDE.md` "Keep the loop short").
Every `ring` below is one process that loads the library: 4 to 5 seconds of cold start
before the first line, more under load.

## Run a guard standalone

From its own folder, always: `load` resolves against the current directory.

```bash
cd libraries/stzlib/base/test/render && ring escape_sinks_narrated.ring
```

Read the last lines: `TOTAL: n assertions, p pass, f fail` and `STATUS: OK`. A guard
ending with `pf()` prints `STOPPED!` on success; that banner is the success marker.

## The gates, once before the commit

| what you touched | gate |
|---|---|
| `base/file/stzHtml.ring`, the JSON faces, the GUI projections | `cd libraries/stzlib/base/test/render && ring escape_sinks_narrated.ring && ring twin_coverage_narrated.ring` |
| `base/meta/stzCodeRules.ring` | `cd libraries/stzlib/base/test/meta && ring coderule_narrated.ring` |
| any public method (a brief above it) | `cd libraries/stzlib/base/doc && ring gate.ring` prints `OK` or the errors |
| the engine (`engine/src/*.zig`) | `cd libraries/stzlib/engine && zig build -j2`, alone, in the foreground, about 25 minutes; never beside another build |
| a test topic | `cd libraries/stzlib/base/testoor && ring testoor.ring --topic <topic>` |

## Testoor's exit codes

The runner's, never Ring's: **0** every stop kept or unperceived; **1** a stop diverged or
a tour did not start; **2** the runner refused. `--json` on a pipe, `--all` for the whole
corpus (a gate, not an iteration: a topic of N tours costs 4N seconds of child start-ups
whatever the tours do).

## Reporting a run

Owned and run are two figures and are never summed. Name every gate you own and did not
run, with the reason (absent runtime, absent hardware, or it executes in another
repository). A scoped run prints what it skipped, by name.

## Cost rules

One heavy job at a time: a build, a corpus sweep, a whole-tree parse. The machine freezes
under memory pressure rather than slowing down. Do not background a build; do not run a
sweep beside one.
