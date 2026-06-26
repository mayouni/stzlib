# stzlib HANDOFF -- next phase: the STRING module grind

Self-contained handoff for a fresh session. You should not need any other
document to start. Two contexts are merged below:

- **Part A** -- the engine-residency work just completed on `stzList` (status,
  architecture, results, commits, what is still pending).
- **Part B** -- the roadmap for what is next: bring the STRING foundation
  module to the same gold standard the list module just reached.

Read the linked memory notes for depth, but everything load-bearing is restated
here.

---

## ⏯ RESUME HERE — the STRING NARRATION AUDIT is IN PROGRESS

The WXT/eval disqualification (Part B step 2) is **DONE** (10 commits
f679a425..69556872; see memory `project_wxt_disqualification`). The active task
is **step 1 = narrate the suite, which IS the correctness audit** (not a
formatting pass): for each test, *understand* impl + original, *run* it, and
commit a *verified asserted* value. Status: 999 tests, blocks 01-105 narrated so
far (01,02,03,05,09-105); deferred-defect / pending (print-form) blocks: 04, 08,
42-45, 48, 54 (interactive), 56, 58, 59, 60_isrealinstring, 67, 68, 71, 74,
77, 78, 79, 80, 82, 83, 84 (W/WXT step 2), 98, 99, 100, 101 (box cluster), 103,
104; partials w/ NOTEs: 70_section_out_of_range_raises, 91, 92, 97, 102.
Resume ~106.

**Per-test workflow (the important part):**
1. Recover the original archive ONCE (the pre-split monolith, 19,572 lines):
   `git show f6bdfbcc^:libraries/stzlib/base/test/legacy/stzStringTest.ring > /tmp/orig.ring`
   Each modular test header says `Extracted from stzStringTest.ring, block #N`;
   find its block in /tmp/orig.ring (blocks are delimited by `/*===== ... */`,
   each a `pr()...pf()` section). Triangulate **archive original ↔ Softanza
   implementation (string/stzString.ring) ↔ the modular test as it runs**.
2. Run the modular test (`D:/ring127/bin/ring.exe <f>.ring`); compare actual to
   the archive `#-->`.
3. If they agree and the value is right → **narrate** it (concise comment + a few
   asserted `Then(...)`; full `Scenario` narration only when illustrative —
   "narrate only what deserves it"). Concept-rename `NN_content`/`NN_pr` files.
4. If they disagree → it's a **defect**. Apply the policy: a narration doc in
   `doc/narrations/` is authority; else the **implementation** is authority
   (most archive `#-->` errors are the original author's). Do NOT assert a wrong
   value. Log every real code bug to `base/test/string/_AUDIT_DEFECTS.md` and
   DEFER the fix to a focused fix-pass (don't rush fixes inline). Commit verified
   tests in batches; push both remotes.

**Open defects already found** (in `_AUDIT_DEFECTS.md`): `ReplaceInSections`
destroys its sections; `StartsWithXTQ().AndQ().EndsWithXT()` returns FALSE when
both true; `SizeInBytes64/32` + `FindAnyBoundedBy` semantics;
`CharRemovedFromLeft/Right(c)` ignore their char arg; `LeadingChars()`/
`TrailingChars()` must return a LIST not a string (author-confirmed); a
**bounds-family cluster** (`BoundsOf` flat-pair / `BoundsOfXT` first-occurrence-
only / `IsBoundedBy` rejects single-string bound / `Bounds()` greedy trailing
run); a **Replace-by-many cluster** (`ReplaceByMany`/`ReplaceByManyXT`/
`Replace(:By=list)` broken, while `ReplaceMany`/`ReplaceManyByMany`/
`ReplaceSubstringAtPositions`/`ReplaceOccurrencesByMany` work); `SectionXT`
missing reversal + `:UpToNChars`; `ToList` no range-string expansion; the
missing `IsRealInString` aliases; a **Replace-by-many cluster** (`ReplaceByMany`/
`ReplaceByManyXT`/`ReplaceWithMany`/`Replace(:By=list)` broken, while
`ReplaceMany`/`ReplaceManyByMany`/`ReplaceManyWithMany`/`ReplaceSubstringAt-
Positions`/`ReplaceOccurrencesByMany` work); broken **position-anchored XT**
forms (`RemoveXT(:AtPosition[s])` byte-based, `ReplaceXT(:AtPosition)` uses
occurrence-index); an **Except-family cluster** (`Except`/`RemoveAllExcept`/
`ReplaceAllExcept`/`FindExceptZZ([list])`); and **W/WXT-conditional** examples
(83/84) pending the string WXT-disqualification step. These await a fix-pass. **Caution:** the engine `isLetter`/`isDigit` are now Unicode-correct
(utf8proc) -- an A/B over the 32 predicate-using tests was clean (only
395_replacew changed, intentionally), so that change is verified safe.

After the audit: stress/perf guard (string has none -- 07_managing_a_big_text is
a 6.6M-char read worth modelling a guard on) + engine-first audit + cleanup.

---

## STANDING RULES (apply to every commit in this project)

1. **Push BOTH remotes after every commit:**
   ```bash
   git push origin main
   git push codeberg main
   ```
   Codeberg auth expires periodically. If it fails, **retry once** -- it
   usually succeeds. Then **verify both** are at your HEAD:
   ```bash
   git rev-parse HEAD
   git ls-remote origin   -h refs/heads/main | cut -c1-12
   git ls-remote codeberg -h refs/heads/main | cut -c1-12
   ```
   If codeberg still fails, push origin and flag codeberg as pending -- do not
   block on it.

2. **Commit trailer** (exact):
   ```
   Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
   ```

3. **Engine rebuild after ANY `.zig` edit:**
   ```bash
   cd libraries/stzlib/engine && zig build
   ```
   The compiled DLLs are **not** git-tracked, so a `.zig` change has no effect
   until you rebuild. Kill any running `ring` first (it holds the DLL):
   `powershell -c "Stop-Process -Name ring -Force"`.

4. **The engine is ABI-coupled to the Ring version** (it reads Ring's internal
   `List` struct directly; `nSize` moved offset 16 -> 60 in Ring 1.27). A given
   DLL matches ONE Ring family. Build picks the newest installed Ring; pin with
   `RING_HOME=D:/ring127 zig build` (or `-Dring=D:/ring127`) and confirm the
   printed `[softanza] building against Ring dir=... minor=...` line. **Run
   tests with the `ring.exe` that matches the built DLL** (e.g.
   `D:/ring127/bin/ring.exe test.ring`). A mismatch shows up as DeepList
   "Invalid path" / corrupt find-dedup-classify / silent perf cliff. See
   `reference_ring_abi_versions`.

5. **Do not run heavy ring suites concurrently** -- no `run_in_background` for
   multi-minute sweeps (leaves zombie shells holding the DLL -> next build hits
   AccessDenied). Use synchronous runs with a per-test timeout.

6. **ASCII-only console output.** Windows renders non-ASCII as garbled text.
   (French markdown docs are the only exception.)

7. **Never open PRs unless explicitly asked.**

8. **Editing discipline** (Ring fails fast): syntax-check after touching a big
   class file (`load`-check script) -- one duplicate `def` (Ring is
   case-insensitive: `NthStz` collides with `NthSTZ`) cascades R14 across every
   test. Use engine-backed `StzFind` / `StzReplace` / `StzSplit` / `StzLen`,
   never Ring's byte-oriented `substr` / `len` / `upper` (they corrupt UTF-8).
   See the root `CLAUDE.md` for the full list.

---

## PART A -- ENGINE-RESIDENCY work on stzList (COMPLETED, with one slice pending)

**Goal:** stop re-marshalling `@aContent` Ring<->engine on every list op so a
chain of operations reuses one engine-side representation.
Plan: `libraries/stzlib/base/list/_ENGINE_RESIDENCY_PLAN.md`.
Depth: memory note `reference_engine_residency`.

### Architecture chosen -- MODEL A (cache, not engine-truth)

`@aContent` (the Ring list) **stays the always-materialized source of truth**.
`@pEngine` / `@pEngineGen` is a **pure cache** of the engine-side `StzList`.

Consequence: the hundreds of direct `@aContent` **reads** stay correct with
zero edits (they can never be stale). Only the ~93 **writes** must invalidate
the cache. This is far simpler and safer than an engine-truth model (where
`@aContent` would go stale and every read would have to funnel through a
materializer).

### THE KEY FINDING -- Ring has NO object destructors

A cached engine handle is never freed when an stzList object dies. So a naive
"cache every read" **regressed** `03_engine_millions` from 33s to 50s: that
test builds many large **one-shot** objects (1M, 200k, ...) and each leaked its
engine list -> allocator pressure. (Confirmed by git-stash A/B.)

### How the leak is SOLVED -- bounded, generation-keyed FIFO cache

The KEYSTONE fix is an **engine-side bounded residency cache** in
`ring_bridge_list.zig`:

- `Register(id) -> gen`: adds the list's item-count to a running total; when the
  total exceeds `CACHE_MAX_ITEMS` (8M) or entries exceed `CACHE_MAX_ENTRIES`
  (1024), it **evicts FIFO** -- freeing the evicted `StzList` AND releasing its
  handle slot. Returns a generation number.
- `Get(gen) -> id` (0 = miss), `Invalidate(gen)`.
- stzList stores `@pEngineGen` (a generation, NOT a raw handle). `_Engine()`
  returns the warm handle if the gen is still resident, else **re-marshals from
  `@aContent`** (Model A truth). Generations defeat the ABA reused-id problem.

Because eviction bounds memory, **reads now stay warm** (no per-read free
needed). One-shot big objects get evicted FIFO instead of leaking. This also
fixes a latent **8192-handle cliff** (handle-table exhaustion).
Caps are tunable consts at the top of `ring_bridge_list.zig`.

### Measured results (A/B, 1M items, Ring 1.27)

- Read-reuse (8 reads on one object): 3.34s -> 1.29s (**~2.6x**).
- `03_engine_millions`: stays **33s (no regression)** -- big one-shots evict.
- 5-mutator chain over 1M: still warm + leak-free.
- 8192-handle cliff: fixed.

(Adjacent perf work shipped alongside, not part of residency proper: unboxed
typed dense storage -- int/float/string modes -- giving e.g. Sum 1.25s->0.04s,
Count/Find 0.27s->0.04s, high-cardinality dedup hang->0.47s; plus
unmarshal-copy elimination and a scalar hash fast-path. All captured in
`reference_engine_residency` and `reference_engine_scale_perf`. A
`test_perf_guard.ring` (11/11) guards against regressions -- run it after any
engine change.)

### Relevant commits (chronological)

| Commit | What |
|---|---|
| `f8148927` | Slice 1: residency infra (handle field + helpers), behavior-identical |
| `43e0a7f8` | Slice 2a: route `@aContent` writes through `_SetContent` + invalidate |
| `ac172afa` | Slice 2b: migrate ~30 hot ops to the cached handle (mutators warm / reads free) |
| `a3b5ecef` | **KEYSTONE**: bounded gen-keyed residency cache -- leak solved, reads stay warm |
| `ee832a7c` | Slice 5: set-ops residency-aware + handle-return (no list copy) |
| `ddfe7668` | unmarshal-copy elimination (Ring value-semantics copy on return) |
| `d6a993be` `e2c70cd2` `10728207` `10c3fc86` `f2892d2e` `23dbd362` `d5f6ab79` `5a1589a2` `1d269688` | unboxed typed storage (int / float / string dense modes) + classify |
| `2e09ee7d` | perf-regression guard |

### What is STILL PENDING -- Slice 4 (engine-truth write-back)

**Slice 4 is the only residency slice not done, and it is the genuinely hard
one -- NOT because of the leak (that is solved), but because of write-back.**

The problem: with the cache, a **dirty** handle (engine holds newer data than
`@aContent`) can only be materialized by *its owner* calling `_Content()` --
the engine cannot write back into a Ring object's field. So dirty handles
cannot be safely engine-evicted. Slice 4 needs the owner to convert
dirty->clean (e.g. force-materialize under a dirty-count cap, or an explicit
`.Release()`), AND `@aContent` would become stale so **every** direct read
would have to funnel through `_Content()` (hundreds of sites, high risk).

Note "bulk marshal-IN" is **not** an easy alternative: marshalling is already a
single FFI call; the ~per-op cost is the irreducible per-item Ring C-API reads
(`gettype`/`getitem`/`getnumber`). Caching the handle (residency) is the right
lever; the write-back-on-eviction limitation is what is left. **Slice 4 is a
carry-over, low priority -- do not start it ahead of the string module unless
asked.**

---

## PART B -- ROADMAP: the STRING module is NEXT

### Where we are

The **list foundation module is fully done**: gold-standard narration, WXT
disqualification, future features, cleanup/rename, engine scale-perf, and
engine-residency slices 1-2 + keystone (slice 4 pending as above). The `/`
operator was also just unified to divide-into-N-parts across list+string (see
"Recently resolved" below).

Per memory `project_module_grind_plan` and task #75, the standing goal is to
bring **every foundation module to the same gold standard, in this order**:

```
file -> list -> string -> char -> hashlist -> table -> listof*
        ^^^^      ^^^^^^
        DONE      NEXT  (the largest module)
```

### The multi-part treatment each module gets (apply to STRING)

1. **Gold-standard narrate** its `base/test/<module>` suite (here:
   `base/test/string/`, currently **999 `.ring` files** -- large).
   **Narration IS the correctness audit, not a formatting pass.** Converting each
   `pr()/pf()` print test into an asserted `Scenario/Given/Then` forces you to
   (a) read and *understand* the implementation + test, (b) *run* it for real,
   and (c) commit a *verified* expected value. A bare `#-->` comment is
   unverified and silently wrong far more often than you'd expect -- error-greps
   and engine A/B diffs never catch a test that runs cleanly but returns the
   wrong value. Only asserting the output does. On any code-vs-test
   disagreement, apply the defect policy (fix the code when a narration doc is
   the authority, else fix the test). This step is the bulk of the work and the
   real point of the whole module pass.

2. **Disqualify its WXT family.** String has a BIG one -- `stzString.ring`
   currently defines **23 `*WXT` methods** (FindWXT, CharsWXT, SplitWXT,
   ReplaceCharsWXT, YieldCharsWXT, SubStringsWXT, ...). Use the **proven
   recipe** from the list pass (memory `project_wxt_disqualification` and
   `reference_wxt_conditional_path`):
   - Classify each `WXT` def as **real-body** vs **thin-delegator**.
   - **Fold the real body into its `W` twin BEFORE deleting** the WXT def
     (otherwise behavior is lost).
   - **Detect self-recursion** (a WXT that calls itself) before folding.
   - Migrate the examples/tests that used WXT to the W form.
   - **Verify with the FULL numbered sweep**, not an error-only grep: WXT
     disqualification changes *output*, and output drift is invisible to
     `grep '^#ERR'`. You must diff actual vs expected across the suite.
   - Rationale: `W` is now the single performant + expressive conditional form
     (engine DSL via `expr.zig`; `WF` = anonymous functions). WXT/WhereXT were
     retired in the list domain; string (and later table) are the remaining
     holdouts.

3. **Engine-first / perf audit.** The scale fixes (unboxed dense storage,
   residency cache) were **list-specific**. Check string's OWN engine paths:
   `stzString` already routes most ops through the engine (`StzEngineString*`),
   but audit for Ring-side loops over chars, byte-oriented `substr`/`len`
   misuse, and find/replace/case/split that should be engine-backed. See
   `feedback_engine_first_fixes`.

4. **Reposition misfiled tests, concept-based naming, remove dead files.**
   Apply Softanza naming (no Qt-lineage names, no aggressive verbs -- see
   `feedback_softanza_naming`).

### Smaller carry-overs (slot in anytime, not blocking)

- **Engine-residency slice 4** (engine-truth write-back) -- Part A above.
- **Thin-stub narration quality pass.** The header-only "# Narrative" count
  over-counts: some test files are still "# pr()" one-liners with no real
  narrative. A cleanup pass should distinguish genuinely-narrated files from
  stubs.

### Recently RESOLVED (do NOT treat these as open)

- **`(/)` operator unified to divide-into-N-parts** (commit `5a92e2cb`,
  2026-06-25). Both stzList and stzString `/ n` now divide into exactly `n`
  parts of as-equal-as-possible size (remainder front-loaded, numpy
  `array_split` convention): `[1..6]/3 -> [[1,2],[3,4],[5,6]]`,
  `"RingRingRing"/3 -> ["Ring","Ring","Ring"]`. Chunk-by-SIZE stays available
  as `SplitToPartsOfNItems`. **`SplitToNParts`/`SplittedToNParts` are now fixed**
  (the old ceil-chunk gave the wrong part count when n was near len) and
  `stzString.SplitToNParts` is now UTF-8-safe (was byte-based). The `(+)`
  operator was confirmed already-correct (appends x as one element; raw->raw,
  Q->elevated). So the previously-flagged "stzList (/) chunk-vs-N-parts +
  SplitToNParts bug" in `reference_operator_q_elevation` is **DONE** -- that
  memory note's "REMAINING OPEN" now only lists `(*)` shape and the
  string-suffix `(*)` stub, neither blocking.

### RECOMMENDED FIRST STEP for the new session

**Baseline `base/test/string/` the same way list was baselined, before
touching anything:**

1. Count the suite: `ls libraries/stzlib/base/test/string/*.ring | wc -l`
   (expect ~999).
2. Run a **failing-test sweep with a per-test timeout** (synchronous, not
   backgrounded) to find current `#ERR` / crashes / drift.
3. **Categorize the errors** by type (`grep -h '^#ERR' ... | sort | uniq -c |
   sort -rn`) and pick the highest-leverage cluster first (one root cause that
   unlocks many tests beats N one-off fixes).
4. Only then plan the narrate / WXT-disqualify / perf / cleanup passes.

Use Ring 1.27 (`D:/ring127/bin/ring.exe`) to match the currently-built engine
DLL, or rebuild for whichever Ring you standardize on.

---

## Memory notes to load (recall by name)

- `reference_engine_residency` -- residency design, leak, cache, perf, slice 4.
- `reference_engine_scale_perf` -- million-item bug fixes and engine scaling.
- `reference_ring_abi_versions` -- engine<->Ring ABI coupling, build pinning.
- `reference_operator_q_elevation` -- Q-elevation rule; `(/)` unification done.
- `project_module_grind_plan` -- the module order and gold-standard definition.
- `project_wxt_disqualification` -- WXT retirement rationale + deletion recipe.
- `reference_wxt_conditional_path` -- W vs WF vs WXT internals.
- `reference_conditional_code_w_wf` -- the W engine DSL / WF anon-functions.
- `feedback_engine_first_fixes` -- fix features in the Zig engine, not pure-Ring.
- `feedback_fast_verification` -- verify via narrated guards + one in-process
  assertion script, NOT a 277-file numbered sweep.
- `feedback_narrated_test_grind` -- how to convert classic tests to narrated.
- `feedback_softanza_naming` -- naming conventions.
- `feedback_ring_vm_traps` / `feedback_no_len_method` / `feedback_source_mojibake`
  -- recurring Ring gotchas.
