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

## Implementation log + the no-destructor leak finding (slices 1-2)

- **Slice 1** (commit `f8148927`): infra only -- `@pEngine`/`@bRingDirty`
  fields + `_Content()` / `_SetContent()` / `_SetEngine()` / `_Engine()` /
  `_InvalidateEngine()` / `_AdoptEngine()` / `_RefreshFromEngine()`. Behavior
  byte-identical.
- **Slice 2a** (commit `43e0a7f8`): routed ALL 82 method-body `@aContent = X`
  reassignments through `This._SetContent(X)` and guarded the 9 in-place
  writes (`@aContent + x`, `@aContent[i]=`, `ring_remove/insert`) with
  `_InvalidateEngine()`. Behavior-identical (cache never populated yet).
- **Model chosen = "Model A":** `@aContent` stays the always-materialized
  source of truth; `@pEngine` is a pure cache. This keeps the hundreds of
  direct `@aContent` *reads* correct with zero edits (they're never stale) --
  only the ~93 *writes* invalidate. Simpler/safer than the engine-truth
  model, and it targets the plan's primary bottleneck (marshal-IN).
- **Slice 2b** (this commit): migrated ~30 hot ops to the cached handle.

  THE KEY FINDING -- **Ring has no object destructors**, so a cached
  `@pEngine` handle is never freed when an stzList object dies. A naive
  "cache on every read" made 03 regress **33s -> 50s**: 03 builds many large
  ONE-SHOT objects (oBig=1M, oNum=200k, ...), and each leaked its engine
  list -> allocator pressure. (Measured by stashing to 2a: 2a=32s, naive
  2b=50s.)

  THE FIX -- **mutators keep the cache warm; value-returning reads free it
  after use** (terminal cleanup via `_InvalidateEngine()`). Big one-shot
  reads no longer leak (-> 03 back to 33s, no regression), while a fluent
  *mutator chain* still marshals once. A/B on a 5-mutator chain over 1M:
  **2a=3.84s -> 2b=3.04s (~21% faster)**. Residual leaks are only
  mutator-chains that end in a pure-Ring op (NumberOfItems/Content) and are
  usually tiny (the adopted result, e.g. a 2-item deduped handle).

  IMPLICATION for slice 4 (engine-truth, lazy `@aContent`): it faces the
  SAME no-destructor leak and the win is bigger ONLY if the intermediate
  unmarshals are also removed -- but then `@aContent` can be stale and EVERY
  direct read must funnel through `_Content()`. Before doing slice 4, decide
  a deterministic free strategy: (a) explicit `.Release()`/`.Free()` the
  fluent forms call at chain end, or (b) an engine-side arena/generation
  that bulk-frees.

  NOTE -- "bulk marshal-IN" is NOT an easy alternative. `marshalRingList`
  (ring_bridge_list.zig:862) is ALREADY a single FFI call
  (ring_MarshalFromRingList:959) that loops engine-side. The ~1s/op cost is
  the per-item Ring C-API reads (ring_list_gettype_gc / ring_list_getitem_gc
  / ring_item_getnumber -- ~3 C calls/item), which are irreducible without
  replicating Ring's internal `List`/`Item` struct layout in Zig (fragile
  across Ring versions). So caching the handle (residency) genuinely IS the
  right lever to avoid repeating those reads across a chain; the leak is the
  real cost. This corrects an earlier "just bulk the marshal" idea.

  Migrated in 2b (cache-aware): SortCS/SortBy/SortByDescending/
  SortInDescendingCS/Reverse (mutators, warm via `_RefreshFromEngine`);
  RemoveDuplicatesCS/Merge/Flatten (mutators, warm via `_AdoptEngine`);
  _FindFirstEngine/Contains, FindAllOccurrencesCS (string+list paths),
  FindAllItemsW/FindW, WithoutDuplicationCS, FindDuplicates, IsEqualToCS,
  IsStrictlyEqualToCS, StartsWith/EndsWith, Map/Filter, ReduceXT/
  ReduceNoInit/CountW, Sum/Product/Mean/Variance/Stddev/Median (reads, free
  after use). Copy-ops Sorted/Reversed/SortedInDescending keep a FRESH
  throwaway handle (they sort/reverse in place but must NOT touch This).
  Set-ops (UnionWith/IntersectionWith) and Classify delegate to submodules
  -> slice 5. ~32 `_EngineListFromContent` call sites remain (submodule-
  bound, throwaway-other-handle, or colder core ops).

## The keystone -- bounded residency cache (removes the leak)

The no-destructor leak is solved by an engine-side **bounded, generation-keyed
residency cache** (ring_bridge_list.zig). It OWNS the marshalled handles:

- `StzEngineListCacheRegister(id) -> gen` : registers a handle id, returns a
  monotonic generation. Adds its item-count to a running total; **evicts FIFO**
  when over `CACHE_MAX_ITEMS` (8M) or `CACHE_MAX_ENTRIES` (1024) -- eviction
  frees the StzList AND `releaseSlot`s its handle-table id (so the 8192-slot
  table never overflows).
- `StzEngineListCacheGet(gen) -> id` : live handle id, or 0 = miss (evicted).
- `StzEngineListCacheInvalidate(gen)` : free + release that entry.

stzList now stores `@pEngineGen` (not a raw handle). `_Engine()` returns the
warm handle if its gen is still resident, else **re-marshals from @aContent**
(always truth in Model A) and re-registers. Generations avoid the ABA problem
of reused handle ids. Because eviction bounds memory, READS can now stay warm
safely (the 2b "free after each read" rule was removed).

Results (A/B by git-stash, 1M items):
- **Read-reuse (8 reads on one object): 3.34s -> 1.29s (~2.6x).**
- 03_engine_millions (one-shot heavy): **33s, no regression** -- the cache
  evicts the big one-shot handles instead of leaking them (naive always-warm
  caching had regressed this to 50s).
- Mutator chain: still warm (the ~21% from 2b), now also leak-free.

This makes residency production-safe and **unblocks slice 4**: with handles
bounded, the engine-truth model can keep dirty handles within the same cap
(force-materialize the LRU dirty handle under pressure -- still needs the
owner to do it, so slice 4 remains the harder step, but the leak is no longer
the blocker). Guard: `test_residency_cache.ring` (15 checks).

## Unmarshal copy elimination (measurement-driven, biggest broad win)

Profiling at 1M (not assumptions) found the real hot spots were NOT marshal-IN
(only ~0.1s) but the heavy *result-returning* ops: UnionWith 5.4s, Classify
4.8s, IntersectionWith 2.9s. Two causes, both Ring value-semantics overhead:

1. **Classify repackaged in Ring** -- the engine returned a FLAT
   `[key, posList, key, posList, ...]` and Ring rebuilt it into `[[key,posList],
   ...]`, COPYING every position sublist (O(n) in interpreted Ring). Fix:
   `stz_list_classify_cs` now emits the FINAL nested `[[key,[pos...]],...]`
   shape, so Ring unmarshals once and returns it -- no repackage.

2. **The unmarshal wrapper added a full list copy.** `StzEngineContentFromList`
   (a Ring func) calls the C bridge `StzEngineListContentToRingList` (builds the
   Ring list engine-side, cheap) but then `return`s it -- and **Ring copies a
   list on every function-return boundary** (~1.3s for 3M items). Measured:
   bridge-direct 0.80s vs wrapper 2.11s for the same 3M result. Fix: route all
   77 internal unmarshal sites across the 15 list-module files straight to the
   bridge `StzEngineListContentToRingList` (handles NULL -> []; the wrapper's
   per-item fallback was dead). The wrapper stays defined for any external use.

Results (1M, vs the original baseline): **Classify 4.82s -> 2.35s (-51%),
UnionWith 5.38s -> 3.53s (-34%), IntersectionWith 2.89s -> 1.80s (-38%),
5-mutator chain 3.54s -> 2.26s (-36%)**. The remaining cost is the unavoidable
1 copy per Ring method-return boundary + the engine op itself.

KEY LESSON: in Ring, a function/method returning a large list COPIES it. Deep
delegation chains (op -> submodule -> wrapper) stack O(n) copies. Prefer the C
bridge return (no copy) and minimize Ring-return boundaries the big list
crosses. marshal-IN is cheap (~0.1s); the copies were the real tax.

## Scalar hash fast-path (set-ops / classify / dedup on numbers)

The value hash-set (ValueSetCtx) backing union/intersection/difference/
classify/dedup spun up a fresh Wyhash (init + byte-update + final) per item.
For SCALAR values (int/float/bool/null) that per-item overhead dominated at
scale. Added a splitmix64 (`mix64`) direct hash for scalars, folding the tag in
as salt (eql requires equal tags, so types never need to collide). Strings/
lists keep the structural, case-fold-aware Wyhash. Hashes only need internal
consistency (eql resolves collisions), so this is safe.

Result: looped UnionWith over 1M ints ~5.1s -> ~2.9s (~43%). Classify over
STRING keys is unchanged (~2.3s -- strings keep Wyhash), confirming the win is
the int path. Correct across set-ops/dups/classify tests.

Remaining frontier for native-speed set-ops (Python does 1M int-union in
~0.1s; we're ~2-3s): the list stores boxed `*StzValue` items, so hashing/
comparing chase pointers and switch on tags. True native speed needs UNBOXED
typed storage (e.g. a dense i64 array for all-int lists) -- a larger engine
rearchitecture, deliberately out of scope here.

## Key files

- `libraries/stzlib/base/list/stzList.ring` — the class (~10k lines).
- `libraries/stzlib/base/list/stzListFunc.ring` — `StzEngineMarshalList`,
  `StzEngineContentFromList` (now bulk via `StzEngineListContentToRingList`).
- `libraries/stzlib/engine/src/list.zig` — engine list ops + `StzList` struct
  (`items: ArrayList(*StzValue)`).
- `libraries/stzlib/engine/src/ring_bridge_list.zig` — the `regs` table mapping
  `stzenginelist*` names to bridge fns; `marshalRingList` / `appendValueToRing`.
- `libraries/stzlib/base/list/_ENGINE_RESIDENCY_PLAN.md` — this file.
