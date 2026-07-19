# `_diagnostics/` -- ad-hoc engine probes

These are **not** part of the topic-test grid. They bootstrap the engine
themselves so a single module can be loaded and poked in isolation, which is
what you want when the question is "does stzString load and reach the DLL at
all" rather than "does this feature behave".

## Run them from THIS directory

```bash
cd libraries/stzlib/base/test/string/_diagnostics
/d/ring127/bin/ring.exe test_core.ring
```

Ring 1.27, not the 1.25 on PATH -- the engine is ABI-coupled.

## Two bootstraps, never mixed

| bootstrap | files | what it gives you |
|---|---|---|
| `load "test_stubs.ring"` + individual `../../../string/stzXxx.ring` | 21 | genuine isolation: one module, hand-written globals, nothing else |
| `load "../../../stzBase.ring"` | 8 | the whole library, like the normal suites |

**Never both in one file.** `test_stubs.ring` is a hand-written mirror of the
string domain's globals (`Q`, `StzRaise`, `CheckParams`, `IsListOfStrings`,
`StzStringQ`, ...). Loading a real library file that defines those same names
produces a wall of C22/C26 redefinitions. When a probe grows to need
something the stub does not carry -- `stzObject` for the inherited `Update()`
guard, `stzStringFunc` for the condition normalisers -- it has outgrown the
stub and should move to `stzBase.ring`. Eight of them already have.

## `test_stubs.ring`: the DLL block must stay at the top

Only the code **before the first `func`** is a Ring file's main section.
Everything after it compiles but never runs. The DLL-loading block sat below
`func len(p)` for months, so it silently did nothing and every probe using
the stub died on `Calling Function without definition: stzenginestring`.

Function definitions *are* hoisted, which is why the block can call
`_stzFindDll()` from above its definition. That part of the old comment was
right; the placement was not.

There is deliberately no `func len(p)` here. The one that used to exist had
the body `return len(p)` -- a call to itself -- and defining `len` at all
shadows Ring's builtin for every file loaded afterwards, so ordinary library
code reached the recursion and blew the stack at depth 997.

## Expectations older than the rulings they test

Six files still report internal `FAIL` lines. They were unrunnable from
2026-06-09 (a directory move that did not update relative load paths) until
2026-07-19, so their expectations were frozen before several deliberate
behaviour rulings landed. A `FAIL` here means "this file disagrees with the
library", and the library may well be the correct one -- check the ruling
before believing the test.

Known example: `test_string_between.ring` expects `Between("[", "]")` to
return a LIST of every bracketed run. Commit `2887cbd39` (2026-06-30)
deliberately made `Between` **greedy** -- first opener to last closer, one
string -- to match the monolithic archive, with 6 tests pinning it. The
diagnostic is the stale side.
