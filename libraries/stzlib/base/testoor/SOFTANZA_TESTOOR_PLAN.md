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
its folder: `ring testoor.ring --topic uuid [--json] [--file F] [--all] [--root D]
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

### TR3 -- Routes and the map -- PLANNED

`Route()` on tours; route coverage from the plan rules (`StzCheckPlanCoverage`,
`StzSuiteDischargesOf`); untouched methods named from the code graph. A line or
branch percentage is refused until route coverage exists, then printed beside it.
Probed 2026-10-05: Ring's trace hook (`ringvm_settrace`) reports a NEWLINE event
with file, line and function for every executed line, so a line map is possible
from inside one process -- after routes, never instead of them.

### TR4 -- The clock and the weather -- PLANNED

In the engine: seed, frozen and stepped clocks, the tick loop driven by a tour. In
Ring: `Clock()`, `Seed()`, `Weather()`. A tour seeded to fail at 42 fails
identically twice and passes at 43; undeclared weather is reported flaky. Zin's
SIMULATION_TEST is the shared grammar: adopt, do not fork.

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
