# Testoor roadmap -- graph-first, refinement-aware, Zig at the core

*Written 2026-11-03 after the first charge (TR0 to TR4) and the protocol were done, and after
the author's rulings and three questions: the core is written in Zig; what if the program under
test hands Testoor its own code graph; how does refinement-oriented programming gain from
Testoor; how does the intelligence layer help agents and people. Phase P1 was run the same day
and its numbers are in section 7. The earlier ladder is in `SOFTANZA_TESTOOR_PLAN.md`; its TR5 to
TR8 are re-based here as phase P5. The contracts are in `TESTOOR_PROTOCOL.md`.*

## 1. The rulings, old and new

The fourteen rulings of the launch prompt stand. Five are added.

| # | ruling | source |
|---|---|---|
| 15 | **The core is written in Zig, not Ring.** Ring is the first face and Haro the next. The Ring files are the reference implementation, and the Ring guards become the conformance suite the Zig core must pass unchanged. | the author, 2026-11-03 |
| 16 | **The graph is the denominator and the runs are the numerator.** A selection is only as small as the graph is complete: a program the graph cannot read in full selects every tour. The graph raises or widens, it never guesses. | measured in P1a |
| 17 | **Intelligence proposes and a run decides.** A binding, a drafted tour or an explanation is data with provenance. A verdict comes only from a run, and a person or a committing actor commits. | the doctrine: structure kills malformedness, never falsehood |
| 18 | **Spend evidence where it is cheapest to be right.** Cheaper stages come first (a bound is checked before any tour is walked), and the impact set chooses which tours to walk at all. | measured in P1b |
| 19 | **A tour takes its subject from the runner.** The file under test is an argument, so one tour can be walked against the program, a refined copy, or a mutant. | protocol 1.1 |

## 2. The picture

Four contracts cross the boundary between a language and the core, and none of them names a language:
the **tour record** (what a face reads), the **child's output** (plain lines a tour prints), the
**logbook** (JSON and prose from one run) and, from protocol 2, the **graph record** (nodes, edges, which
plan item a node implements, which tours walked it).

| owned by | what |
|---|---|
| the **Zig core** (engine) | the judge and the five states, the logbook writer, exit codes, seeds, the stepped clock and the scheduler hook, the route join, the graph store, node counters |
| a **face** (per language) | reading source into a tour record, launching a tour, what its errors look like |
| the **library** (Ring today, Haro later) | the code graph readers, the court, refinement, diagrams, the intelligence layer |

## 2b. Consumers outside Testoor

**The Atelier (commit 74757d462, plane A1)** already runs whole test files as tours on a resident Ring++
host and judges them with Testoor's own judge: it calls `Tour(path)` for the record and
`_TravJudge(record, lines, ending, exit, wall)` for the verdict, the same five arguments the runner uses, and
reports 15,186 of 20,278 `Then` lines judged. Two consequences for this roadmap.

- **The judge's interface is now a public contract**, not an internal detail. Phase P3 replaces its body with Zig
  but keeps `Tour()` and the five-argument judge call answering what they answer today, so the Atelier needs no change.
  The earlier signature change of `_TravEndingOf` (a fifth argument, protocol commit) is safe because nothing
  outside Testoor calls it; that is why the judge is the part to freeze.
- **A resident host is the fastest runner we have.** It removes the 4 to 5 s child start without a new engine
  build. Phase P2a (the Ring++ engine copy) therefore matters for running Testoor's *own* guards under `rnxc`, and
  matters less for speed; the runner should learn to use a resident host as one more way to walk a tour.

## 3. The phases

Each rung is a guard that fails before and passes after, a commit pushed to both remotes, and one
CONCLUSIONS line. A rung does not open until the one it depends on has recorded its exit.

### P1 -- Prove the two premises. DONE 2026-11-03.
- **P1a, impact recall.** `stzImpact.ring`; guard `testoor_impact_narrated.ring`. Graph-first selection
  is safe on a planted subject, and its one blind spot is detected and handled.
- **P1b, refinement verified.** `stzSubject.ring`, `Subject()` on the traveller, protocol 1.1; guard
  `testoor_refine_narrated.ring`. The tours plug into the refinement gate's existing derivation seam.

### P2 -- Make the gates honest and the core specifiable.
- **P2a, the Ring++ engine copy. DONE 2026-11-04** (section 7b): all eight guards run under `rnxc`, and a
  tour that loads the library costs 0.07 s warm instead of 4 to 5 s.
- **P2b, golden logbooks. DONE 2026-11-04** (`golden/`, 14 judge cases and 5 logbooks, 43 expected files; guard
  `testoor_golden_narrated.ring`, 75 assertions on Ring 1.27 and on Ring++). The Zig core must reproduce them.
- **P2c, protocol 2. DRAFTED 2026-11-04** (`TESTOOR_PROTOCOL_2.md`, draft d1, four questions for the author). Adds the
  graph record, the `[testoor node ID]` line, the nodes record, the evidence floor and `refinements`; a version 2 key
  appears only when it has content, so the goldens stay the acceptance test.
- **P2d, the Zig core design note. DRAFTED 2026-11-04** (`TESTOOR_ZIG_CORE.md`, draft d1, four decisions for the author).
  One domain `stz_testoor`; JSON in, JSON out; the bytes that must agree; the Ring files kept as the reference behind a switch.
- *Exit:* all guards green under rnxc; goldens committed; protocol 2 and the design note read and
  accepted by the author.

### P3 -- The Zig core, in this order.
*Opened 2026-11-05 on the author's word, with the recommended answers to protocol 2 section 11 and the Zig note section 10.*
1. **Logbook writer, judge, five states, exit codes**, passing the goldens. **DONE 2026-11-05** (`TESTOOR_ZIG_CORE.md` section 9;
   `zig build test-testoor`, 26 tests; all ten guards on rnxc through the core). Still open inside this step: the runner's own
   logbook calls, and the difference corpus.
2. **Seeds, stepped clock, weather, the scheduler hook** (the clock moves out of Ring).
3. **Route join and graph store.**
4. **Node counters**, the numerator of graph coverage, cheap where the Ring trace hook costs 11.5 us an event.
5. **The `stz guard` child**, so the stz desk calls the Zig runner.
- *Exit:* the Ring guards pass against the Zig core unchanged; a Zig test per module.

### P4 -- Graph-first coverage on the real library.
- **Impact recall on real classes**, with real mutants and the tree-sitter call graph, because P1a measured a
  planted subject and not the library with its dynamic dispatch, inheritance and Q-chains.
- **Selection from a change**: `--impacted-by` fed from `git diff`, method by method, so an agent asks
  "what did my patch reach".
- **Node-level route coverage**, reported as two counts, with the unwalked closed routes owed by their owners.
- *Exit:* recall stays 100 percent on the real library or the graph is declared incomplete for the cases
  where it is not.

### P5 -- Excursions, mutation, perception, inherited tours (the old TR5 to TR8, on the graph).
- **TR5 excursions.** The graph finds the `Verb`/`Verbed`/`VerbQ` triples; each gives a metamorphic relation.
  The options of an `<R:ALGO>` knob are alternative implementations of one specification, so a differential
  tour across them is a ready-made excursion.
- **TR6 perception.** Generalise `StzSoundSingingVerdict()` into a registry with `Perceived(:by, :said)`;
  the court raises a finding for a verdict still unperceived past a date.
- **TR7 mutation.** Targets come from the graph (weakly walked nodes with many callers); a surviving mutant
  is a court finding.
- **TR8 inherited tours.** `stz guard --inherited` walks the library's conformance tours against a
  platform's own bindings.

### P6 -- Refinement embraced.
- **Package the verification** as `StzRefineVerified(refinable, tour, subjectPath)`, the P1b predicate made a
  reusable factory.
- **Evidence floor by trust posture and risk tier**: an `:llm` edit to a critical knob needs kept tours; a
  trusted human may pass with unjudged ones. The policy knobs are themselves refinement points.
- **Knob-space excursions**: the bounds give boundary and beyond-bound cases, and the gate must refuse the latter.
- **The timeline carries the evidence**: each step of the refinement timeline holds a logbook id and seed.
- **Cascade-selected tours**: the cascade chooses what the gate walks (needs P4).

### P7 -- The intelligence layer. Proposes only.
- **Explain a red stop**: callers, the recent change, the doc-comment promise and the seed to replay.
- **Incident memory**: logbooks kept as incident records; flaky history; fragile routes; runs ordered by risk.
- **Sentences to nodes**: a designer writes a promise in words, the semantic resolver proposes graph nodes, a
  human confirms, the court records the binding.
- **A tour-drafting agent**: a declared agent drafts a six-line protocol tour for an unwalked route, judged
  at load, rehearsed in the workbench, committed by a person.
- **Constraint-derived claims**: an invariant declared on a kind of node produces claims across all of them.
- **The coverage map**: the graph drawn with routes coloured by the five states.
- *Guard for every item:* nothing in this phase can change a verdict without a run.

### P8 -- Faces.
- **Haro**, when it can be parsed: a helper that prints the protocol lines and a profile, and a reader that takes
  the parsed program (`rnxc dump --json` is the model to try) in place of matching source lines.
- **Zin SIMULATION_TEST** read into the logbook, once the Zin desk confirms what a tick means.
- **Python, JS and others** registered by their owners; the conformance guard is already their test.

## 4. Order, and what runs at the same time

P2 comes before P3, because the goldens and the protocol are what the Zig core is built against. P4 needs the
graph store of P3 for node counters, but its recall measurement can start earlier in Ring. P5 needs P4's graph.
P6 can start with its first two items right now, since they need only P1b. P7 needs P4 and the court. P8 waits on
Haro.

One heavy job at a time: an engine build, a corpus walk and a mutation batch never overlap, and every build
uses `-j2`.

## 5. What we measure

| measure | target | where it is read |
|---|---|---|
| impact recall | 100 percent, always | the impact guard, then the real library in P4 |
| reduction | tours skipped as a fraction of walks | the same |
| route coverage | owned and walked as two counts | `--routes` |
| flaky tours | zero | `--repeat 2` |
| time to a verdict for an agent loop | falling | tour starts per verdict |
| conformance | goldens reproduced byte for byte | P2b onward |

## 6. Risks and unknowns, said plainly

- **A graph is a proxy.** It misses edges under dynamic dispatch. The answer is the completeness flag and the
  fallback to every tour, and the real measurement is P4.
- **The Zig port is a large piece of work.** The goldens exist so that it can be done in steps and checked at each one.
- **Haro is not built and nothing here has been tried on it.** The protocol is the bet that the contracts survive.
- **Intelligence can sound right and be wrong.** Hence ruling 17.
- **This machine freezes under memory pressure.** Builds and corpus walks are capped and run one at a time.
- **Running tours inside a gate is slow** until the engine copy and the impact set make it cheap.

## 7. P1, measured

**P1a, impact recall** (planted subject: three classes, seven public methods, eight tours, so 56 real walks):

| | result |
|---|---|
| walks | 7 mutants times 8 tours = 56 |
| tours the graph selected | 18 |
| tours that failed | 18 |
| failing tours outside the selection | 0 |
| selected without need | 0 |
| walks skipped | 38 of 56 |

The blind spot, measured the same way: a subject whose method reaches another through `eval` has an edge the graph
cannot see. The naive selection missed 1 of the 2 failing tours. The graph reads such a subject as incomplete,
selects every tour, and misses none. This proves the method and not the real library, which is P4.

**P1b, refinement verified** (a pricing program with one knob, bounds 0 to 0.9, three tours):

- **Control:** the bounds alone admit 0.50, and the tours, walked against that very state, diverge on the promise
  that the vat never exceeds a quarter of the net.
- **With the tours as a derivation rule:** 0.22 is admitted with the tours kept and the seed on record; 0.50 is
  refused at the derivation stage and rolled back; 0.95 is refused at the constraint stage and **the tours are not
  walked at all**; `Revert()` restores the old value; the real source file is never rewritten.

Guards at the end of P1: reader 74, runner 80, promises 52 (3 by design), routes 44, clock 66, protocol 55,
impact 51, refine 33.

## 7b. P2a, measured (2026-11-04)

**What was built.** A Ring++ copy of the engine from this worktree's sources, with the repository's own rule for
a desk that changed engine Zig: the Ring++ repository's `bench/engine_copy.py` makes the copy and
`ONLY=<domains> zig build -j2` builds it. Two choices were forced by the machine and are stated here so they are
not re-decided. **The cache was not seeded**: the other copies carry caches of 8 to 11 GB and the data drive had 11 GB
free. **Eight giant domains were left out** (neural, gpu, window, gui, accessibility, sound, audio device, voice)
because Testoor never loads them; 81 core domains were built. The cache went to the system drive, and a watchdog
stopped the build if either drive fell below a floor or free memory below 3 GB; it never tripped.

| | |
|---|---|
| build time | about 12 minutes cold, at `-j2` |
| result | 82 libraries, 81 Ring++ builds plus one vendored runtime, 352 MB |
| disk used | about 1 GB of cache on the system drive and 0.7 GB on the data drive |
| the three Testoor process seams | present |

**How the guards find it.** The library discovers its engine by searching upward from the working directory, so a run
uses the libraries of the nearest engine directory above it. `rnxc_tree.ps1` makes a tree whose `base` and `core` are
junctions to the worktree and whose `engine` is the Ring++ copy. It must be run from PowerShell: Git Bash follows a
junction when it changes directory and would find the Ring-built engine again.

**The guards, under `rnxc` and on Ring 1.27:**

| guard | rnxc | Ring 1.27 |
|---|---|---|
| reader | 74 | 74 |
| protocol | 55 | 55 |
| refine | 34 | 34 |
| impact | 51 | 51 |
| routes | 44 | 44 |
| promises | **52 of 52** | 49 of 52 |
| clock | 56, supervisor section skipped by name | 66 |
| runner | 80 | 80 |

The three promises assertions that fail on Ring by design pass on Ring++, which confirms they record Ring++'s real
behaviour. The first reader count under `rnxc` equals the Ring count (74), as the rule asks before trusting a new VM.

**The speed.** The uuid topic, nine tours that each load the library: **43 s on Ring 1.27, 1.2 s on `rnxc` with the image
cache warm** (0.07 s a tour, the slowest 0.12 s). The first walk after a change pays the compile once, 15 s a tour.

**What the second VM taught the code** (all four fixed on this side, and the first two reported to their owners):

1. `rnxc` has no `binarysearch()` (R3). And comparing two strings with `<` raises on Ring 1.27 (R41) while `rnxc`
   accepts it. The join now uses a plain index lookup, the one operation both VMs agree on.
2. `rnxc`'s `eval` refuses to create a new global (E1), and a function defined at run time cannot be called by the
   already-compiled program (R3). A subject can therefore not be loaded from a path a tour was given. The runner now
   *installs* the subject under a fixed name beside the tour (`SubjectAs`), which the tour `load`s statically, and a
   subject keeps its refinement points inside functions. Protocol 1.1 says so.
3. `stzNodeSupervisor` picks its worker's program by looking for `ring.exe` in the arguments and falls back to `ring`,
   so under `rnxc` its worker starts on the wrong VM. That is the cluster plane's file, not Testoor's: the weather
   section of the clock guard is skipped under `rnxc` and says so by name, and the finding is routed.
4. A tour that fails under one VM and passes under the other is the cheapest conformance check there is.

## 8. Decisions the author owes

1. **P2a**, the Ring++ engine copy: done and measured (section 7b); nothing owed.
2. **P2c and P2d**, read the two drafts: `TESTOOR_PROTOCOL_2.md` section 11 (four questions) and
   `TESTOOR_ZIG_CORE.md` section 9 (four decisions). Each carries a recommended answer.
3. **P3**, the Zig core: approve the order in section 3 and the goldens as the acceptance test. The second VM
   is now a free conformance check for it.
4. **P6**, the first two items can start now. Say whether they come before P2.
5. **P7**, which intelligence feature to build first. The recommendation is *explain a red stop*, because it only
   reads and can never change a verdict.
