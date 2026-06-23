# stzList engine-residency — foundational refactor plan

> Dedicated-session handoff. Goal: make `stzList` **engine-resident** so list
> operations stop re-marshalling the whole list between Ring and the Zig engine
> on every call. This is the last "industry-ready heavy performance" item after
> the scale fixes already landed (see commits `79c43ef4` and `4c395603`, and
> the memory note `reference_engine_scale_perf`).

## The problem (measured)

`stzList` keeps its data in a **Ring list** at `@aContent`. Every engine-backed
op does:

```
pList = This._EngineListFromContent()      # marshal Ring -> engine (per-item read)
... engine op on pList -> result handle ...
@aContent = This._ContentFromEngineList(r) # unmarshal engine -> Ring
StzEngineListFree(pList)
```

`_EngineListFromContent` → `StzEngineMarshalList(@aContent)` →
`ring_MarshalFromRingList`/`marshalRingList` (engine-side, but reads the Ring
list **item by item** via the Ring API). At 1,000,000 items that's ~1s **per
op**. So a fluent chain `Q(big).Op1().Op2().Op3()` pays the O(n) marshal floor
on each step. (The *build* and *unmarshal* sides are already optimal: bulk
`ring_ContentToRingList`, and engine-side builders via `.Repeated()` / ranges.)

## Why a cheap cache is NOT safe (don't try it)

`@aContent` is mutated in **~85 direct `@aContent = ...` reassignments** PLUS
scattered **in-place** mutations (`@aContent + x`, `add(@aContent, ...)`,
`@aContent[i] = ...`) across the ~10,000-line stzList class (and submodules).
A cached engine handle cannot be reliably invalidated against all of those —
a single missed site → **silent data corruption**. The fix must make residency
structural, not a bolt-on cache.

## Target architecture

Make an **engine `StzList` handle the source of truth**, and make `@aContent`
lazy / derived:

- New state on the class: `@pEngine` (engine list handle, or NULL) and a small
  `@bRingDirty` / `@bEngineDirty` discipline — OR (cleaner) drop `@aContent`
  as canonical and treat it as a lazily-rebuilt cache of `@pEngine`.
- One **getter** `_Content()` → returns the Ring list, rebuilding it from
  `@pEngine` via the bulk `StzEngineListContentToRingList` only when needed
  (and caching until the next mutation).
- One **setter** `_SetEngine(pHandle)` / `_SetContent(aRing)` → the single
  chokepoint that updates the source of truth and invalidates the other side.
- Hot ops call engine fns **handle→handle** on `@pEngine` directly (no marshal
  in, no unmarshal out) and store the resulting handle back via `_SetEngine`.

The engine already exposes handle-based ops for the hot paths (find, count,
contains, sort, dedup, reverse, slice, set-ops, classify, map/filter/reduce
expr, …) — see `engine/src/ring_bridge_list.zig` `regs` table. They take/return
list handles, so chaining on `@pEngine` is natural.

## Migration plan (incremental, test-guarded)

Do it in slices; after EACH slice, run the guards (below) and commit+push.

1. **Infra (no behavior change).** Add `@pEngine` + `_Content()` getter +
   `_SetEngine()` / `_SetContent()` setters. Route `init()` and the canonical
   mutator (`UpdateWith`/`Update`) through them. Keep `@aContent` working as
   today; `_Content()` just returns it. Prove green.
2. **Hot read ops → handle-direct.** Migrate FindAll/Find, Count/CountW,
   Contains, Sum, NumberOfOccurrences, Sort/Sorted, Reverse/Reversed,
   RemoveDuplicates, UnionWith/IntersectionWith/Difference, Classify to read
   from `@pEngine` (marshal once on first access, then reuse). Each migrated
   op: build/keep `@pEngine`, call the engine fn, return without unmarshalling
   the whole list.
3. **Mutators → handle-direct.** Migrate Add/Insert/Remove/Replace/Extend/etc.
   to mutate `@pEngine` (or rebuild it) via `_SetEngine`, instead of
   round-tripping `@aContent`. Find ALL `@aContent =` / `@aContent +` /
   `add(@aContent` / `@aContent[i]=` sites and route them through the setter.
4. **Make `@aContent` fully derived** and delete the per-op marshal-in. At this
   point `Content()` lazily materializes from `@pEngine`; ops never re-marshal.
5. **Submodules.** Apply the same to the list submodules that hold their own
   `@oList` (Finder/Counter/Replacer/Splits/…) so chains stay engine-resident.

## Guards (run after every slice — MUST stay green)

From `libraries/stzlib/base/test/list/` (cd into it; tests load `../../stzBase.ring`):

- `00_list_narrated.ring` (79/79), `01_deeplist_narrated.ring`,
  `02_engine_largedata_narrated.ring`, `03_engine_millions_narrated.ring` (23/23).
- The 30 `test_*.ring` engine/delegation harnesses (PASS/FAIL self-checkers).
- A broad sweep of the numbered tests for `Error (R` / `panic`.
- Re-time `03` — the WIN target: a fluent chain over 1M should drop from
  ~1s/op toward marshal-once. Add a timing assertion or a perf note.

## Build / test / push

```
# rebuild engine after any .zig change (DLLs are NOT git-tracked; build locally)
cd libraries/stzlib/engine && zig build      # zig 0.15.2; compile-checks the Zig

# run a test
cd libraries/stzlib/base/test/list && ring 03_engine_millions_narrated.ring

# load-check after editing stzString/stzList:
printf 'load "libraries/stzlib/base/stzBase.ring"\n' > _lc.ring && ring _lc.ring   # expect no C22/errors
```

Push BOTH remotes each commit: `git push origin main; git push codeberg main`
(codeberg auth expires — retry once; verify with `git ls-remote codeberg main`).
Commit trailer: `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`.

## Gotchas (hard-won)

- **Don't run heavy `ring` suites concurrently** — they contend for CPU and the
  DLL (one session leaked many, 17+ min). Kill stragglers:
  `powershell -c "Stop-Process -Name ring -Force"`.
- Ring is **case-insensitive** for identifiers: inside a class method a bare
  `type(item)` / `copy(...)` binds to a same-named METHOD on the receiver (R20)
  — run such evals in a global func, or avoid the name.
- **Per-module handle tables**: a value handle minted by the value bridge does
  NOT resolve in the list bridge. Pass needles as item[0] of a list-handle
  holder (see `ring_FindAllHeldCS`).
- Ring has **no `\"` escapes** in `"..."` strings; no method-arity overloading;
  `for X in list` re-evaluates the source per step (use indexed `for i=1 to n`).
- Never define `Len()`/`len()` on a class. Use `_FindFrom`/engine helpers, not
  byte-oriented `substr`/`len`/`upper`.
- Build large lists ENGINE-side (`.Repeated(n)`, ranges) — never the Ring-loop
  `*` operator.

## Key files

- `libraries/stzlib/base/list/stzList.ring` — the class (~10k lines).
- `libraries/stzlib/base/list/stzListFunc.ring` — `StzEngineMarshalList`,
  `StzEngineContentFromList` (now bulk via `StzEngineListContentToRingList`).
- `libraries/stzlib/engine/src/list.zig` — engine list ops + `StzList` struct
  (`items: ArrayList(*StzValue)`).
- `libraries/stzlib/engine/src/ring_bridge_list.zig` — the `regs` table mapping
  `stzenginelist*` names to bridge fns; `marshalRingList` / `appendValueToRing`.
- `libraries/stzlib/base/list/_ENGINE_RESIDENCY_PLAN.md` — this file.
