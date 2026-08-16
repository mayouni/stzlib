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

7. **`len()` vs `ring_len()` vs `StzLen()`** — pick by intent, never alias:
   - **Lists:** use `len(aList)` directly. Never `ring_len(aList)`.
     Never define a `len()` method on a class — it shadows Ring's
     builtin and breaks every caller that expects the builtin.
   - **Strings:**
     - `StzLen(cStr)` — engine-backed, Unicode codepoint count.
       Use whenever multibyte correctness matters.
     - `len(cStr)` — raw byte count. Use when you genuinely want
       bytes (e.g. checking against a byte-buffer size).
     - `ring_len(cStr)` — alias for `len()`, byte count. Avoid;
       prefer `len()` for clarity.

8. **Don't wrap to find/contain. AND don't use Ring's `substr()`.**
   Use the engine-backed globals instead:
   - **`StzFind(needle, haystack)`** — position of first occurrence
     of `needle` in `haystack` (returns 0 if not found). Polymorphic:
     also works as `StzFind(item, list)` and `StzFind(item, [:in, list])`.
   - **`StzFindCS(needle, haystack, bCaseSensitive)`** — returns the
     list of all positions; check `len(_) > 0` for "contains".
   - **`StzReplace(host, old, new)`** — engine-backed,
     codepoint-safe replace. Use this instead of Ring's 3-arg
     `substr(s, old, new)` which is byte-oriented.
   - **`StzReplaceCS(host, old, new, bCaseSensitive)`** for the
     case-sensitivity dial.
   - **`StzSplit(host, sep)` / `StzSplitCS(host, sep, bCase)`** —
     codepoint-aware split.

   BAD: `new stzString(host).Contains(sub)` — wrapping to call
        a contains.
   BAD: `substr(host, sub) > 0` — Ring's byte-oriented find.
   BAD: `substr(host, old, new)` — Ring's byte-oriented replace.
   GOOD: `StzFind(sub, host) > 0`.
   GOOD: `host = StzReplace(host, old, new)`.

   Ring's `substr()`, `len()` (for strings), `upper()`, `lower()`
   are byte-oriented and break on UTF-8 (Hebrew, Arabic, CJK,
   emoji). The Stz* engine helpers are the canonical path.

9. **Prefer the engine over Ring loops for find/replace/case/scan.**
   The Zig engine is Unicode-correct AND faster than the
   equivalent Ring loop in almost every case. Reach for the
   engine when:
   - finding any occurrence: `StzEngineStringFindFirstFromCS(...)`
     beats walking chars
   - replacing: `StzEngineStringReplaceCS(...)` is faster AND
     codepoint-correct. `ReplaceCS` now delegates to it (the old
     @memcpy-alias panic is gone — the engine builds a fresh result
     buffer; verified across ASCII / case-insensitive / multibyte /
     60 length-combos with no panic). The previous byte-oriented
     Ring `substr` workaround was removed (it corrupted UTF-8).
   - codepoint count / case detection / script detection
   Use Ring loops only when the engine helper doesn't exist or
   it's a one-shot prototype path.

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

## Background tasks: prefer direct grep over `run_in_background`

For ring-test sweeps that take >5 minutes, **don't** use
`run_in_background: true` -- it leaves zombie shells in the
harness UI that look like work-in-progress but produce nothing
once their state-of-the-world is stale. Use synchronous Bash with
a short timeout, or just `grep -l "^#ERR" tests/<topic>/*.ring`
to read the live state directly.

Background tasks are useful for genuine async work (an annotate
that returns a summary, a long-running compile). They're harmful
for "sweep all tests and print a status table" loops -- by the
time the table arrives I've already moved on, and the state has
changed under it. One session leaked 6 such shells running for
15+ hours each.

## Push protocol

Two remotes, always:
```bash
git push origin main; git push codeberg main
```

**While parallel sessions work this repo: `git add <explicit paths>`,
never `-A`/`-am`.** One session's `git add -A` swept another session's
in-flight files into an unrelated commit (wrong message, wrong
attribution, already pushed). Expect foreign commits to appear between
your edit and your commit, and expect transient engine-build failures
from the other session's mid-save -- rebuild before diagnosing.
Codeberg auth expires periodically; if it fails, push GitHub and
flag the codeberg push as pending. Don't block on it.

**Verify, don't trust the push output.** `git push codeberg main` can
report `Everything up-to-date` while codeberg is still several commits
behind -- the local remote-tracking ref goes stale after a failed
fetch, and git answers from it without contacting the server. Confirm
with the server itself:
```bash
git ls-remote codeberg main   # must equal `git rev-parse main`
```
If it lags, push an explicit refspec, which forces the negotiation:
```bash
git push codeberg HEAD:refs/heads/main
```

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

- **Don't let library code READ a global constant a caller can overwrite.**
  Ring is case-insensitive, so a caller's `nL = len(cPixels)` silently
  replaces the `NL` newline constant with a NUMBER. Library code that
  then builds a string with `NL` raises deep inside the string layer,
  with nothing pointing back at the caller's variable. `TAB` and `CR`
  are equally exposed -- a caller writing `tab = 42` or `cr = 7` breaks
  them the same way. Short, uppercase, two-or-three-letter names are
  trivially collidable.
  Use the literal instead: `char(10)`, `char(9)`, `char(13)`. They are
  byte-identical (`NL = char(10)` is TRUE) and cannot be reassigned.
  Swept library-wide in 2026-08: 2,898 reads across 75 files.
  Two cautions, both paid for:
  - `char()` is a BUILTIN, so it is shadowed inside a class that
    defines its own `Char()` method (`stzStringChar`, `stkChar`,
    `stzStringBounder`, and anything inheriting them). None of those
    read NL, so the sweep was safe -- but check before assuming.
    `ring_char()` in `core/common/stkRingFuncs.ring` is the escape,
    the same way `ring_len` / `ring_trim` are.
  - A blind token replace also hits DEFINITION names. The sweep turned
    `func NL()` into `func char(10)()` and `func NL@@NL(p)` into
    `func char(10)@@NL(p)`, breaking the whole library's load. Keep the
    NAME and change only the BODY: `func NL()` now returns `char(10)`,
    so even that public accessor survives a clobbered global.

- **TRUE / FALSE / NULL are the same hazard, and WORSE.** They are
  globals too -- `TRUE` is `1`, `FALSE` is `0`, `NULL` is `""` -- so a
  caller writing `true = 0` replaces them for the whole process. NL at
  least RAISES somewhere; these do not. With TRUE clobbered,
  `(1=1) = TRUE` answers `0`: the logic runs backwards and nothing
  errors at all. Prefer the literals `1`, `0` and `""` in library code.
  4,460 reads remain, being retired module by module rather than in one
  sweep -- a 278-file diff is exactly where a `func char(10)()` hides.
  Note `func TRUE()`, `func FALSE()` and `func Null()` all exist (they
  return the stzTrue/False/NullObject wrappers), so the
  definition-name trap above is live for these too.

- **A library must not CLOBBER these either, and it did.** The
  `writes-a-mutable-constant` code rule found four in the library on its
  first run: `nL = len(_aRes_)` in stzWordStream.MostFrequentWords --
  the reported bug's exact shape -- and three `cR = ...` locals, since
  `cR` IS `CR`. Calling MostFrequentWords() left NL a NUMBER for the
  rest of the process. Short Hungarian-ish locals are the danger:
  `nL`, `cR`, `nT`. Run `StzCheckProjectKnobs()` -- the rule is there
  now and reports zero.

- Don't name a method or variable after (or containing) a Ring
  KEYWORD: `def Load()` is a C6 error (`load`), a variable `cAll` is
  a C13 error (contains `call`). Cost two renames in the perf grind
  (`LoadRatio()`, `cNarr`).
- Don't use `for X in list ... next` -- iterator form re-evaluates
  the source per step. Use `nLen = ring_len(aList); for i = 1 to nLen`.
- Don't call `len()` or `trim()` bare inside class scope -- use
  `ring_len()` / `ring_trim()`. The bare form triggers R20.
- Don't use Ring's `substr(s, needle, n)` 3-arg form expecting
  find-from-position; it is REPLACE in Ring. Use `_FindFrom` instead.
- Don't use non-ASCII chars in console output (Windows renders as
  garbled text). French markdown docs are the exception.

## Perf-system laws (the P0-P7 grind, 2026-07-29)

The perf module (`base/perf/`, design doc `SOFTANZA_PERF_SYSTEM.md`,
8 narrated guards / 283 assertions under `base/test/perf/`) minted
rules that apply well beyond it. Run the perf guards before touching
`base/perf/`, the appserver request bracket, the cluster supervisor,
the reactor, or the engine perf/histogram/watch modules.

1. **Engine-wrapper copy law.** A class whose state must survive
   Ring's copy-on-assign keeps ALL mutable state in ENGINE handles,
   and materializes those handles EAGERLY at birth. A lazily-created
   handle is created per-copy and forks silently (found live: the
   recording face counted 120, the registry face read 0). Paren-less
   `new` skips `init()`, so force materialization (`.Handle()`) when
   composing wrappers.

2. **Per-face Ring state: one face drives.** Anything Ring-side in a
   copied object (cadence bookkeeping, CPU baselines, self-cost,
   sentinel transitions) forks per copy. `Observe()`/`Supervise()`
   store COPIES -- the stored copy is the driver; every face reads
   the shared engine data. Configure (e.g. `EnableTracing`) BEFORE
   the copy is taken.

3. **Clocks are scopes.** Monotonic = `StzEngineWatchTimestamp*` /
   `StzEngineProcessUptime*` (Instant-baseline; NTP-immune) -- the
   only clocks fit for durations. `StzEngineTimeNow*` and Zig's
   `nanoTimestamp()` are EPOCH WALL time; consumers (stzLog,
   telemetry) treat them as absolute -- do not flip time.zig's
   semantics casually.

4. **Windows quantizes both time axes.** CPU accounting
   (`GetProcessTimes`) ticks in 15.625 ms quanta: a short-interval
   CPU reading of "15.63 ms" is ONE TICK, not a measurement --
   average across many quanta. Sleeps round UP to ~15.6 ms at the
   default timer resolution: the reactor requests 1 ms
   (`timeBeginPeriod(1)` at `reactor_create`) -- that fix took the
   in-process round trip from 22 ms to 5 ms; any new sleep-polling
   code outside a reactor process re-inherits the coarse default.

5. **An identity is not a self-check.** A formula computed from one
   set of anchors (U = X*D/cores) can never fail and proves nothing.
   A real self-check compares two INDEPENDENT measurements of the
   same truth (anchor-computed U vs the sampled utilization gauge;
   Little's implied N vs a counted in-flight).

6. **Leave-one-out z for outliers.** A z-score computed over a window
   that INCLUDES the newest sample is bounded -- at n=10 the maximum
   is exactly 3.0, so a |z|>3 test can never fire. Judge the newest
   sample against the PRIOR window; a jump off a flat baseline is
   infinitely surprising.

7. **Guard honesty for live values.** Never assert equality between
   two reads of a live ratio -- it drifts BOTH ways (the interval
   grows so X decays; the guard's own prints burn CPU so D grows).
   Assert ranges for live reads; prove exact-transfer with a frozen
   stub. And wait-bound scenes must NOT use in-process HTTP -- the
   harness's own CPU masks the wait; feed the standard instruments
   directly.

8. **f64 serialization boundary.** Epoch NANOS overflow 2^53: cross
   into JSON as ms-exact strings plus `"000000"`; exact ns is safe
   only for monotonic spans (~104 days).

9. **Reuse the house contracts, don't invent parallel ones.**
   Check-like verdicts go in the unified rule shape
   `[ :rule, :subject, :where, :severity, :message ]` ->
   `stzRuleReport.Ingest()` (one CI gate). Anything periodic exposes
   `Name_()` + `Cycle()` and becomes hostable on any `stzAgentHost`
   (servers tick their agents' loop). The request instruments'
   names -- `http.request.ms`, `http.requests`, `http.errors` -- are
   the SLA's well-known subjects; keep them stable.

---

## Coordination — read before starting work

This repository is one of several worked on in parallel. The coordinating session is
**Central**, in `D:\GitHub\softanza`. It holds the cross-cutting design, the plan, and the
order of work across every repository. It has no authority here and never edits this repo.

**You have a mailbox, and it is how Central talks to you.** There is no message bus here,
but a file change reaches any session holding that file -- so D:\GitHub\softanza\mailbox\<you>.md
is a real channel the moment you open it. Open it first, keep it open, and Central's
appends arrive as messages rather than as something you must remember to check.

**Before starting anything — including when the author says "what is next", and including
when you were about to choose for yourself:**

1. **Open your mailbox** at `D:\GitHub\softanza\mailbox\` -- your repository's name, plus
   your plane if the repository is shared. Read any unanswered block and leave the file
   open for the rest of the session. Format and the reply kinds are in `mailbox/README.md`.
2. Read `D:\GitHub\softanza\protocol\README.md` — scope, how to report, how to disagree.
   It is short.
3. Read `D:\GitHub\softanza\prompts\QUEUE.md` for what is next *for this repository*.
   Regenerate it first if it looks old:
   `powershell -ExecutionPolicy Bypass -File D:\GitHub\softanza\dashboard\central.ps1`
4. Read the last few entries of `D:\GitHub\softanza\dashboard\SESSION-LOG.md` -- what the
   other sessions concluded, which their commits do not say. Opening it also means later
   entries may surface to you as the file changes, which is the closest thing to a message
   from another session that exists here.
5. Pin against the **live versions** the queue prints, never a version number written
   inside a prompt. Where a prompt and this repository disagree, **this repository is
   right** — report the divergence rather than forcing the prompt.

**The queue is a proposal, not an order.** You see local context Central cannot. To
disagree, append a `DISAGREE` block to **your mailbox** with the
**local fact Central could not have known** — a preference is not a DISAGREE. Central
answers there: accept, or insist with a global reason. You then comply or hand it to the
author. Three messages, never a fourth, and you never DISAGREE twice. **If Central does not
answer, proceed and record what you did** — silence is never a veto.

**Report conclusions, not activity.** Central can read what happened here from git; it
cannot read what you *decided*. Append one line to that same log when you commit a plane,
close a phase, decide something another session would otherwise re-decide, or find
something that changes another repository's plan.

**Never edit a sibling repository** — not even a one-line fix. Write it in the log and its
own session makes it.

*This repository: `stzlib`.*

## Talk in the block style

Substantive messages are a closed block, not prose. Six keys, fixed order, clauses not
sentences:

```
why    <goal, one clause>
did    <fact> · <fact>
state  <thing>=<value>
open   <what waits> -> <who decides>
next   <the single move>
note   <one judgement clause, only if needed>
```

` · ` joins facts, `->` assigns ownership, `=` binds state. Detail beyond a line goes in
one grid (thing | state | action). Popups: outcome plus what gets written. Commits: plain
title, then why/what/proof. Full law: `D:\GitHub\softanza\protocol\STYLE.md`