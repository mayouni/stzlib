# Testoor -- the testing framework that fits the tests Softanza already has

*Plane `stzlib-testoor`, launched 2026-10-05 from `memos/2026-10-05-testoor-launch.md`
(COMPASS-TESTOOR-01, ratified). The name is the author's: Testour, the Andalusian
village in Béja whose Great Mosque clock runs counter-clockwise and tells the right
time. A tour that can be re-walked is a defect that can be caught twice.*

## 1. What it is

Softanza had, at `origin/main` 044b9dcd2 on 2026-10-05, 5,267 test files in 153
topic folders, 517 narrated guards in three Ring dialects, 2,874 files carrying
`#-->` promises, five runners of which none emitted JSON and one set an exit code,
and no coverage instrument of any kind. Testoor is the framework that reads every
one of those files as a **tour**, runs them from **one runner** a shell and an agent
can both believe, says which **routes** no tour walked, and turns the clock back so
a failing tour walks again identically.

**It rewrites no existing test file.** The framework fits the files. A file the
reader cannot read is reported by name, never edited.

## 2. The ten words (ruling 1 -- a rename needs a local fact, never a preference)

| word | what a tester does with it | where |
|---|---|---|
| Tour | the test, as data: `Tour(path)`, chained by `TourQ(path)` | `stzTour.ring` (TR0) |
| Stop | where the traveller stops and looks: `Stop()`, `Sees()`, `SeesNot()` | TR0 reads them, TR1 judges them |
| Traveller | who walks: `By("the author")`, `By(:Takamba)`, `By(:excursion)` | TR1 |
| Route | the meaningful path declared before it is walked | TR3 |
| Map | the code graph | TR3 |
| Clock | `Clock(:frozen, ...)`, `Clock(:stepped)`, `Seed(n)` | TR4 |
| Weather | a declared fault | TR4 |
| Logbook | one read or one run: JSON on a pipe, prose on a terminal | `stzTour.ring` (TR0) |
| Souvenir | what a person perceived: `Perceived(:by, :said)` | TR6 |
| Court | the unified rule shape, `stzRuleReport` | TR3 on |

**A stop has five states and no sixth** (ruling 2): kept, diverged, unreached,
unjudged, unperceived. Neither of the last two is a pass or a failure, and a runner
that folds either into pass or fail is wrong.

**`pf()` is a state the runner understands** (ruling 7): "finished, timed", never a
failure. `pf()` itself is not changed.

## 3. The ladder

Every rung is a guard that fails before and passes after, a commit pushed to both
remotes, and one CONCLUSIONS line. Probes first; the corpus read is a gate run once
per task.

### TR0 -- The reader -- DONE 2026-10-05

`base/testoor/stzTour.ring`: `Tour(path)` reads one file as a record -- dialect,
helpers, stops, the claims at each stop, promises, routes, how it ends, whether it
asserts anything at all. Dialects read: the Given/When/Then helper of
`base/test/_narrated.ring`; the self-contained helper under any name (chk, Chk,
Assert ...), recognised by what its body does; the gate's `sec`/`chk`/`chkeq` with
`discharges("GG6")` as routes; bare promises; hand-printed markers; Zin's `.zst`
declarations. `stzLogbook` reads a tree and answers JSON and prose from one read,
naming what it skipped. Guard: `base/test/testoor/testoor_reader_narrated.ring`.

Measured at TR0: a planted lower-case `[ok]` counts as asserting (the sweep's grep
was case-sensitive and did not count it); a planted file with no claim reports
"runs, asserts nothing"; an unknown dialect is named, and the file is byte-identical
after the read.

### TR1 -- The runner -- DONE 2026-10-05

`base/testoor/stzTraveller.ring` and the entry `base/testoor/testoor.ring` (run from
its folder: `rnxc testoor.ring --topic uuid [--json] [--file F] [--all] [--root D]
[--timeout MS] [--by WHO]`). One runner process per batch; one child Ring per tour,
started BY ARGV in the tour's own folder (Ring resolves `load` against the working
directory), read as it prints, held to a deadline, then judged by pairing the
printed verdicts with the reader's claims by text. Exit 0 when every stop is kept
or unperceived; 1 when a stop diverged or a tour did not start -- and when a tour
broke or hung, a decision recorded in CONCLUSIONS; 2 when the runner refused. JSON
on a pipe, prose on a terminal, from one run. Wall time per stop from the arrival
of its opening line. Owned and run as two figures. Skipped by name, and under
`--topic` the other topics named. `pf()` is the state finished-timed, never a
failure. Guard: `base/test/testoor/testoor_runner_narrated.ring`, 80 assertions,
exit 0/1/2 read in-process and again through the OS from a child `ring
testoor.ring`.

Three engine seams, all in `engine/src/system.zig`: `stz_process_spawn_argv` (no
shell between: a quote in an argument no longer kills the command silently, and
kill() reaches the program -- through cmd.exe it reached only cmd.exe and the hung
tour kept beating), `stz_process_read_stdout_available` (non-blocking) and
`stz_process_wait_for` (timed; the pipes stay open so a child that exits between
two polls is drained to its last line). Ring faces: `stzProcess.SpawnIn()`,
`ReadAvailable()`, `StdoutEnded()`, `WaitFor()`, `IsRunning()`.

Measured: the uuid topic, 9 tours, owned 9 run 9, 20 kept 9 diverged (the one-off
UUID values recorded as promises), 8 finished-timed, exit 1, 43 s of which every
second is a child loading the library (each tour's own stops take under a
millisecond once loaded). The guard: 69 s, 41 of them the uuid children. A
per-line trace hook was probed and refused as the default instrument: 11.5
microseconds per event, and the library load does not finish under it in three
minutes. Central was asked about COMPASS-AGENTTOOLS-01 before TR1 and had not
answered; the runner was written here, as the ASK allows, and the stz desk's verb
calls it as a child.

### TR2 -- Promises as stops -- DONE 2026-10-05

The rules of `base/meta/promises.py` live in the traveller (`_TravPromise*`,
`_TravVariants`, `_TravCanon` in `stzTraveller.ring`) and judge a promise as a
claim of a stop. Kept with their reasons: a promise is walked as an ordered
subsequence of the output; a short promise must equal its line (a `6` once hid
inside a later `[ 6, 28 ]`); a divergence consumes one line so it cannot hand its
line to the next promise; `TRUE`/`FALSE` print as `1`/`0`; a note in parentheses
and a second `#` are dropped; quotes are dropped; `:Symbol` prints bare and
lowercased; `@@()` list spacing is canonical; a bare list arrives one item per
line and is compared item by item; `''` is an empty line; `#--> ERROR: msg` means
the line raises, and a tour whose last kept promise is one of those FINISHED as it
said it would; a trailing `#-->` followed by a standalone one is a label; a promise
that argues with itself (`but should`, `see why`, `TODO` ...) is PROSE -- kind
prose, state unjudged, never diverged; a file that did not compile (C, S, E9) or
raised part-way has not broken the promises below: they are unreached. `_expect.
ring`'s `Shows()`/`Same()` are picture claims: silent is kept; `PICTURE DOES NOT
MATCH` is one diverged claim naming its row (which picture it was is in the rows,
not in the numbering, so the file's picture claims are unjudged), and the raise
that follows it is the assertion's ending, not a break. Guard:
`base/test/testoor/testoor_promises_narrated.ring`, 46 assertions, every rule
planted both ways (the lie it must catch and the truth it must not accuse), plus
one real plot example. The Python harness and the Ring port were run on numbrex,
char, locale and file; the comparison is in the TR2 memo.

### TR2 closing figures -- 2026-11-03

`promises.py` against `testoor.ring --topic X --json`, one topic at a time (outputs and
`cmp_promises.py` kept under `.central/testoor-cmp-2026-10-05/`, not in git). Ring agrees
with Python on every promise Python reads, which is the same-line form only.

| topic | Python read / kept / diverged | Ring read / kept / diverged | reading |
|---|---|---|---|
| file | 2 / 8 / 1 | 2 / 8 / 1 | exact |
| numbrex | 40 / 113 / 0 | 42 / 118 / 0 | exact; Ring reads 5 next-line promises more |
| locale | 56 / 186 / 27 | 79 / 212 / 36 | 8 files differ, all next-line promises Python never reads, 1 of them prose-like and now unjudged |
| char | 65 / 245 / 0 | 114 / 322 / 30 before the last fix | file 15 moves from 3 to 2 after it (checked on the file); the topic was not re-run in full |

Three fixes came out of the comparison: a multi-line promise block is gathered (933 in 641
files), matched line by line and, when the value is wrapped over comment lines but printed
on one, as one joined line; `#--> ERR:` reads like `ERROR:`; the `?` line's own trailing
note makes a next-line promise prose. Genuine library findings Ring surfaces that Python
cannot: `UnicodeChar(1114113)` prints 1114112 instead of raising; `LatinDotlessLetters()`
returns six letters where the promise lists two (char/18, four promises); locale/87
promises deliberately misspelt day names. Files whose promise bytes are double-encoded
(char 01, 06, 09, 115, 118) and 28 char files that break on methods without a definition
are findings for their owners, not rules. The gate ran on Ring 1.27 with children on Ring,
interim: the promises guard 52 assertions, 3 of which are the Ring++ expectations the
Atelier session moved, so they fail on Ring by design; it has not been re-run on rnxc, whose
engine copy this worktree does not have.

### TR3 -- Routes and the map -- DONE 2026-11-03

`base/testoor/stzRoute.ring`. A ROUTE is a plan item; a TOUR walks it by saying so, with
`discharges("GG6")` (the gate's old form) or the new `Route("GG6")` (a harmless no-op
function, read from the source by the tour reader in every dialect). `stzRouteMap` joins
the plan's items (the court's own `StzPlanItemsOf`) with the tours' declarations and
answers two counts, OWNED and WALKED, never summed and never a percentage (ruling 8).
The court's plan rules run over the same two lists (`StzCheckPlanCoverage`), and one rule
is new: `route_without_tour`, a WARNING when the plan reads the item closed (something is
claimed done that nothing walks) and INFO when it reads open. A tour naming a route no plan
defines is the court's own `guard_discharges_unknown_item`, not a second rule. The MAP: `StzUntouchedMethods(classFile, tourFiles)` names, from the code
graph, the public methods of a class that no tour NAMES -- a static name join, a proxy for
a route and not execution coverage, said in every report that uses it; a definition is not
a touch, `init` and `_private` methods are not listed. At the shell:
`ring testoor.ring --routes PLAN.md --topic T [--class FILE] [--json]`, exit 0, 1 when a
closed route has no tour or a tour names an unknown one, 2 when refused. All findings are in
the court's shape and `stzRuleReport.Ingest()` takes them.

Guard `base/test/testoor/testoor_routes_narrated.ring`, 44 assertions: one plan item with no
tour is ONE route unwalked and adding the tour clears it; closed is a warning and open is
information; an unknown route is a finding and a known one is not; and on the real gate the
tour reader and the court's own `StzSuiteDischargesOf`, written apart, find the same 81
routes in the same order. Measured on the real graphics plan: 36 routes owned, 9 walked,
27 unwalked, 26 of them read closed (so 26 warnings: closed and nothing walks it) and 1
unstated. The library's tours almost never declare a route, only the gate does, so route
coverage starts low and the number is the finding. Joined with that one plan alone, the gate's
72 discharges of other plans' items are reported as unknown by the court, as they should be.

**Not done:** the comparison with `zin test coverage` on a shared fixture. The two count
different things (declarations a Zin test mentions, plan items a tour declares) and no
fixture both can read exists; see the TR3 memo.

### TR4 -- The clock and the weather -- DONE 2026-11-03

`base/testoor/stzClock.ring` (the tour's words) and the traveller (the runner's side).
A failing tour PRINTS ITS SEED and the same seed walks the same path.

- **Seed.** The runner chooses a seed once per run, passes it to every child as
  `--testoor-seed N`, and reports it in the logbook (`"seed"` per tour and per stop, `seed N`
  in the prose of anything that failed). `testoor.ring --seed 42` walks with 42. A tour says
  `Seed(:run)` to adopt the runner's seed or `Seed(7)` to name its own, which then wins; either
  way it seeds the engine's and Ring's generators together (`SeedRandom`) and prints
  `[testoor seed N]`, the line the traveller reads back. Run by hand with no runner, `Seed(:run)`
  draws one from the clock and reports it.
- **Clock.** `ClockTo(:frozen, "2025-09-27 14:30:25")` is the existing `StzFreezeClock`;
  `ClockTo(:stepped, [ startMs, stepMs ])` is a logical clock that moves only when the tour
  moves it (`ClockTick()`, `ClockAdvance(ms)`, `ClockNow()`); `ClockTo(:live, "")` undoes both.
  **The function is spelled `ClockTo`, not `Clock`, for a local fact:** Ring is
  case-insensitive and `clock()` is a builtin the library calls hundreds of times, so a global
  `Clock` shadows it and the library stops loading (R19 in `stzProfilingTimer`, measured). Seed
  and Weather collide with nothing and keep their names. `ClockTick()` is the scheduler hook: the
  tour is the loop, and each tick the clock says which declared weather is due.
- **Weather.** `Weather(:child_killed, [ child ])` or `[ child, tick ]` (without a tick the
  seeded generator picks one, so the same seed kills at the same tick) and
  `Weather(:skew, [ ms ])`. Declared, never ambient; each prints `[testoor weather name@tick]`
  and the traveller lists it per tour. **The one weather on the distribution plane is real:**
  `WeatherKill(supervisor, fired)` calls the platform's own `stzNodeSupervisor.KillChild`, and
  the guard watches the supervisor restart the worker and count it. No mock stands in.
- **Flaky.** `testoor.ring --repeat N` walks each tour N times with ONE seed; when the verdicts
  differ the tour is FLAKY: record flag, court rule `tour_is_flaky` (an error) naming whether
  weather was declared, prose `FLAKY`, exit 1. One walk cannot see flakiness; undeclared weather
  is found from outside, which is why the check is a repeat and not a claim.

Guard `base/test/testoor/testoor_clock_narrated.ring`, 66 assertions in 29 s: the stepped clock
replays identically and refuses a tick it was not given; a seed replays its draws and another
seed does not; weather falls due once and an unknown weather is refused; **a tour seeded to fail
at 42 fails identically twice (same signature, same draw) and passes at 43**; a tour naming its
own seed overrides the runner's; a tour that leaves a marker file behind is flaky and a stable
one is not; declared weather is named; and the real supervisor kills and restarts a real worker.
The seed tour is VM-independent on purpose: it fails exactly when its draw equals the draw
seed 42 produces, so it fails at 42 and passes at 43 under any VM's generator.

**Limits, stated.** The stepped clock lives in Ring; the engine owns seeds already and takes the
clock when a second consumer needs it (ruling 12). Zin's SIMULATION_TEST (`SEED 42`, `AT 2s:
FAULT ...`) is the grammar this follows in spirit: a seed, a scenario of timed steps, declared
faults. It is adopted as a vocabulary, not parsed; reading `.zst` SIMULATION_TEST files into the
logbook is the next small step, not done here. The Zin desk's memo is filed in `memos/` and
routed through CONCLUSIONS.

### TR5 to TR8 -- after the compass re-rates the plane on TR4 -- PLANNED

Excursions from the function forms as metamorphic relations; the perception
registry generalised from `StzSoundSingingVerdict()`; mutation through the engine's
byte loops; `stz guard --inherited`.

## 4. What Testoor refuses (ruling 13)

A second assertion library in Ring; any rewrite of the 5,267 files; a coverage
percentage before routes; "verified" on a perceptual claim without a name; a suite
that runs after every edit; a mock for a platform's production.

## 5. The five runners it replaces

| runner | what it does today | its defect |
|---|---|---|
| `softanza test` (`libraries/stzlib/cli/src/main.zig`) | runs top-level files named "test"; PASS when Ring exits 0 | drops its path argument; scans no sub-folder; reads `pf()` as FAIL. Run 2026-10-05 on uuid: 9 core files, 0 passed, exit 1 |
| `_run_test_batch.py` | pairs `? expr` with `#-->`; `# @clock` freezes the clock | no exit code; Ring path hard-coded to `D:\Ring126`, which does not exist on this machine |
| `_annotate_test_errors.py` | writes `#ERR` headers into files | the only runner that edits tests, which Testoor never does |
| `base/test/_sweepall.sh` | ok / RED / ERR / HANG and an `#ASSERTING` count | always exits 0; case-sensitive, so `[ok]` is not counted as asserting |
| `base/meta/promises.py` | kept / diverged / did not compile / raised / prose / timed out | Python; text; no exit code |
