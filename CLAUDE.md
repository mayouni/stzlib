# stzlib -- Claude operating notes

Short, project-specific rules. The session-wide Zin standards live
in the parent project's CLAUDE.md; this file only carries what is
local to the stzlib grind.

## Editing discipline (lessons from the field)

After touching `stzString.ring`, `stzList.ring`, or any other file
that defines methods/aliases/primitives:

1. **Syntax-check before testing.** Ring fails fast: a single C22
   "Function redefinition" anywhere in the file makes EVERY method
   call fail with R14 across all tests that load the file. The
   error count can balloon from ~200 to ~770 from one stray dup.
   Quick check:
   ```bash
   ring /tmp/loadcheck.ring 2>&1 | grep -i "stzString\|error " | head -3
   ```
   where loadcheck.ring is just `load "libraries/stzlib/base/string/stzString.ring"`.

2. **Scan for case-insensitive duplicate defs before assuming a
   regression.** Ring is case-insensitive; `NthStz` and `NthSTZ`
   collide. The fastest check:
   ```bash
   grep -niE "^\s*def\s+<methodname>\s*\(" libraries/stzlib/base/string/stzString.ring
   ```

3. **Prefer whole-block edits over piecemeal line-by-line.** Leaving
   a file in a broken intermediate state during a multi-step edit
   triggers cascading test failures that look like real regressions.

4. **Engine helpers first.** Use `_FindFrom`, `_EngineSlice`,
   `_EngineSliceFrom`, `_EngineCount` for codepoint-aware ops. Ring's
   `substr` is byte-based and corrupts UTF-8 (Hebrew, Greek, emoji, ♥).

5. **Operator-precedence trap.** `_aRes_ + _x_ + _y_ - 1` is
   parsed as three list-appends, not arithmetic. Always
   parenthesise: `_aRes_ + (_x_ + _y_ - 1)`.

6. **Single-clause `if` inside method bodies can no-op.** In Ring 1.25,
   a method-body `if isString(p); p = [p]; ok` (the type-widening
   pattern) sometimes does not fire — the wrap is unreached, and the
   downstream validation rejects the original type. Force the branch
   with `if .. but .. else .. ok` and build the result in a fresh
   variable instead of reassigning the param:
   ```ring
   def Foo(acArg)
       _arg_ = []
       if isString(acArg)
           _arg_ + acArg
       but isList(acArg)
           # copy
       else
           return FALSE
       ok
       ...
   ```
   See the `IsMadeOfCS` change for the canonical fix shape.

## Test-error grind workflow

When systematically reducing `#ERR` count under
`libraries/stzlib/base/test/<topic>/`:

1. **Baseline** with the live count: `grep -l '^#ERR' tests/<topic>/*.ring | wc -l`
2. **Categorise** by error type: `grep -h '^#ERR' tests/<topic>/*.ring | sort | uniq -c | sort -rn`
3. **Pick the highest-leverage cluster** -- one root cause unlocking many tests beats N one-off aliases.
4. **Fix + spot-verify** a sample of tests in the cluster before committing.
5. **Commit + push** to BOTH origin (GitHub) and codeberg.
6. **Re-annotate** (background, ~25 min): `python _annotate_test_errors.py <topic>`
7. **Confirm** the count strictly decreased; if not, look for new
   duplicate defs or arity collisions you introduced.

The `/grind-err` skill in `.claude/skills/grind-err/` packages this
loop.

## Push protocol

Two remotes, always:
```bash
git push origin main; git push codeberg main
```
Codeberg auth expires periodically; if it fails, push GitHub and
flag the codeberg push as pending. Don't block on it.

## Sensitive test patterns

- Tests that load `../../stzBase.ring` must be run from inside
  their topic directory (`cd libraries/stzlib/base/test/<topic>`).
  Running them from the stzlib root produces a misleading
  "Can't open file" error.
- Tests ending with `pf()` print "STOPPED!" on a successful pass --
  that banner is the success marker, not a failure.
- `#ERR exit 3221225794` is Windows 0xC0000142 (DLL init / access
  violation) and can be a stale header. Always re-run a sample
  before assuming the tests still crash.

## What NOT to do (collected the hard way)

- Don't use `for X in list ... next` -- iterator form re-evaluates
  the source per step. Use `nLen = ring_len(aList); for i = 1 to nLen`.
- Don't call `len()` or `trim()` bare inside class scope -- use
  `ring_len()` / `ring_trim()`. The bare form triggers R20.
- Don't use Ring's `substr(s, needle, n)` 3-arg form expecting
  find-from-position; it is REPLACE in Ring. Use `_FindFrom` instead.
- Don't use non-ASCII chars in console output (Windows renders as
  garbled text). French markdown docs are the exception.
