# AGENTS.md -- the door for an AI agent arriving in stzlib

*About 150 lines that point. The law is `CLAUDE.md` and is not repeated here; a
procedure lives in a skill under `.claude/skills/`. Every path below exists and every
command runs in a fresh checkout: `libraries/stzlib/base/test/render/agents_door_narrated.ring`
checks that, and it is run from a fresh checkout before this file is pushed.*

## What this repository is

Softanza (`stzlib`) is a computational platform around one engine written in Zig, with Ring
as its face: text, numbers, tables, graphs, maps, images, sound, neural networks and governed
AI agents. **The engine is the product**; Ring is one face over it, never a fallback for what
the engine owns. Start with `README.md`, then `CLAUDE.md` whole: its first half is how this
repository is coordinated with its siblings, its second half is the rules paid for in the
field. `ALIGNMENT.md` says where this repository stands against the reference design.

## Where to read first, by task

| you are here to | read first | then the fixture to copy |
|---|---|---|
| fix a method | `CLAUDE.md` "Editing discipline" and "What NOT to do" | `libraries/stzlib/base/test/render/escape_sinks_narrated.ring` (a narrated guard that fails before and passes after) |
| add a method or a class | `libraries/stzlib/base/doc/design/SCOPE_ORIENTED_PROGRAMMING.md`, then the class's own header comment | the doc brief above every public method; the doc gate below refuses one without it |
| move substance into the engine | `libraries/stzlib/base/doc/design/SOFTANZA_ENGINE_ARCHITECTURE.md` | `libraries/stzlib/engine/src/json.zig` (one function) and `libraries/stzlib/engine/src/ring_bridge_json.zig` (its bridge and the registration table) |
| write a guard | `libraries/stzlib/base/test/README.md` and `libraries/stzlib/base/test/_narrated.ring` | `libraries/stzlib/base/test/render/twin_coverage_narrated.ring` (positives and their negative siblings) |
| add a code rule the court runs | `libraries/stzlib/base/meta/stzCodeRules.ring` (the rule list is the single source) | `libraries/stzlib/base/test/meta/coderule_narrated.ring` |
| write text into HTML or JSON | `libraries/stzlib/base/file/SOFTANZA_RENDER_PLAN.md` | `libraries/stzlib/base/file/stzHtml.ring`: `StzHtmlEscaped`, `StzHtmlAttrEscaped`, `SetMarkup` the one raw door |
| reduce the `#ERR` count of a test topic | `.claude/skills/grind-err/SKILL.md` | the loop in that skill |
| run or write a tour | `libraries/stzlib/base/testoor/SOFTANZA_TESTOOR_PLAN.md` | `libraries/stzlib/base/testoor/testoor.ring` |
| understand a world an application declares | `contracts/world-contract.md` and `contracts/world.schema.json` | `contracts/read-side.md` |
| report a security concern | `SECURITY.md` | -- |

## The decision tree

1. **Is the substance Ring or Zig?** A find, a replace, a case fold, a parse, a serializer,
   a numeric kernel: the engine owns it. Call the engine helper if it exists
   (`StzFind`, `StzReplace`, `StzLower`, `StzHtmlEscaped`, `StzJsonString`); add one in
   `libraries/stzlib/engine/src/` if it does not, with a bridge function and a registration
   line, and rebuild. Never `substr`, `len` on a string, `upper` or `lower` on text: they are
   bytes, not characters.
2. **Does a guard fail before the change?** If not, write the guard first, standalone, as a
   probe; fold it into a suite only when green. A guard that agrees with the writer by
   coincidence is not a guard: assert on the mechanism, with a negative sibling.
3. **Does the method carry a doc brief?** A public method without one is refused by the doc
   gate. Write it before the code, in the third person, ending with a period.
4. **Does the change reach a person through a sense?** A page, a colour, a sound, a rendered
   glyph: ship something they can perceive, beside the guard, and record who perceived it.
   *Unperceived* is a state, never a failure.
5. **Is a sibling repository involved?** Never edit one. Write the finding in the
   coordination log named in `CLAUDE.md` and its own session makes it.

## When stuck

- **A Ring error you do not understand**: `.claude/skills/ring-traps/SKILL.md` lists the
  traps a method hits, each with the error it shows. Three to check first: a name that is a
  keyword (`oR`, `cAll`, `Load`), a duplicate definition anywhere in the file (one C22
  turns every test red), and a statement after a `func` (it belongs to that function).
- **A guard fails only in a suite**: run it standalone from its own folder; `load` resolves
  against the current directory, not the file.
- **The engine says a function is not found**: the DLLs in the engine's `zig-out` output
  folder are not tracked; build them (below) or copy a build made at the same commit.
- **A push to codeberg fails with "credentials incorrect"**: it is a spent single-use token,
  not an expiry; `CLAUDE.md` "Push protocol" has the two commands.
- **The machine is loaded**: one heavy job at a time. Never two builds, never a corpus sweep
  beside a build. The hook refuses a backgrounded `zig build` for this reason.

## Verification commands

Each is a pre-commit gate for what it names, run once per task, never after every edit.

The render plane's fast path, 95 assertions in two processes:

```bash
cd libraries/stzlib/base/test/render && ring escape_sinks_narrated.ring && ring twin_coverage_narrated.ring
```

The code rules, 93 assertions:

```bash
cd libraries/stzlib/base/test/meta && ring coderule_narrated.ring
```

The ratchet that catches a NEW writer concatenating markup (about a minute; once before a
commit that touches a writer, never after every edit):

```bash
cd libraries/stzlib/base/test/render && ring markup_concat_gate_narrated.ring
```

The doc gate (prints `OK` or every missing or malformed brief):

```bash
cd libraries/stzlib/base/doc && ring gate.ring
```

Testoor, the runner that reads every test file as a tour. Its exit code is the runner's,
never Ring's: **0** every stop kept or unperceived, **1** a stop diverged or a tour did not
start, **2** the runner refused. `--json` for a pipe, `--all` is a gate and not an iteration:

```bash
cd libraries/stzlib/base/testoor && ring testoor.ring --topic uuid
```

The engine, alone, capped at two jobs (about 25 minutes on this machine); or ONE of its
DLLs by name, which is what a change to one domain owes (about 4 minutes cold, 20 seconds warm):

```bash
cd libraries/stzlib/engine && zig build -j2
```

```bash
cd libraries/stzlib/engine && zig build -Ddomains=stz_gpu -j2
```

The GPU plane, eight guards in one folder, each needing a device: the sanitizer (GZ0, 25), the random-kernel fuzz (GT0, 23;
3 s warm, about a minute the first time a machine compiles its kernels), the checker with its compute
ceiling (GK3, 36), the user kernel's own reference (GK6, 34), f16 weights (GK5, 23), the grammar's admissions (KP0, 43),
the group's memory and puzzles 9-12 (KP3, 58) and the kernel puzzles (KP1-KP2, 95: the course `libraries/stzlib/base/education/program/courses/kernel-puzzles`,
graded by `libraries/stzlib/base/gpu/stzKernelPuzzle.ring` on the desktop and by
`libraries/stzlib/base/education/program/courses/kernel-puzzles/runner/puzzle.html` in a browser
with WebGPU, the course folder served over http). The standalone probe `libraries/stzlib/engine/src/gpu_peak_probe.zig`
prints every adapter's peak with its spread (build it with `zig build-exe`, run it with
`libraries/stzlib/engine/vendor/wgpu/lib/wgpu_native.dll` as its one argument), and the edge proof
`libraries/stzlib/base/test/gpu/edge_proof/edge_proof.html` runs eight kernels in a browser
byte-identical to the native engine (fixture from `libraries/stzlib/base/test/gpu/edge_proof/gen_fixture.ring`).
Run the guards with Ring++'s `rnxc`, not `ring`. The kernel language, the checker and the puzzles are
described for a reader in `libraries/stzlib/base/gpu/SOFTANZA_GPU_KERNELS.md`; the next rungs are the
section NEXT of `libraries/stzlib/base/gpu/SOFTANZA_GPU_PLAN.md`:

```bash
cd libraries/stzlib/base/test/gpu && rnxc gpu_verify_narrated.ring && rnxc gpu_spec_reference_narrated.ring && rnxc gpu_f16_narrated.ring
```

```bash
cd libraries/stzlib/base/test/gpu && rnxc gpu_grammar_narrated.ring && rnxc gpu_shared_narrated.ring && rnxc gpu_puzzle_narrated.ring && rnxc gpu_fuzz_narrated.ring && rnxc gpu_sanitizer_narrated.ring
```

The standalone probe beside it prints every adapter's peak with its spread, A B A B against
the copy kernel, on both clocks; build it with the line below, then run `gpu_peak_probe.exe`
from the engine folder with the vendored runtime,
`libraries/stzlib/engine/vendor/wgpu/lib/wgpu_native.dll`, as its one argument
(`--ramp` shows the clock under sustained work):

```bash
cd libraries/stzlib/engine && zig build-exe -j2 src/gpu_peak_probe.zig -I vendor/wgpu/include -lc -O ReleaseFast
```

This door's own guard, which needs no engine and runs in a fresh checkout:

```bash
cd libraries/stzlib/base/test/render && ring agents_door_narrated.ring
```

`stz check`, a command that would run the code rules and the twin court from the shell, is
**planned** and not built; `StzCheckProjectKnobs()` and `StzCheckCode()` in
`libraries/stzlib/base/meta/stzCodeRules.ring` are what runs today, from Ring.

## What stzlib does not own

The website, the UI law, the learning offering, the game engine, the operating system, the
payments provider and the coordinating session each live in a sibling repository; their
names and the way findings travel to them are in the coordination block at the top of
`CLAUDE.md`. A fix an agent sees in a sibling is written down there, never applied here.

## Skills

- `.claude/skills/narrated-guard/SKILL.md` -- writing a narrated guard that fails before.
- `.claude/skills/ring-traps/SKILL.md` -- the Ring traps a method hits, with their errors.
- `.claude/skills/fast-path/SKILL.md` -- running the fast path, Testoor and the gates.
- `.claude/skills/grind-err/SKILL.md` -- the C22 duplicate-definition and `#ERR` grind.
