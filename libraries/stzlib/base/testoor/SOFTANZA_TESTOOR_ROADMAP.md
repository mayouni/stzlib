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
- **P2a, the Ring++ engine copy.** Build it once (`bench/engine_copy.py`, `-j2`, one heavy job) so all
  guards run under `rnxc`, the required VM, and a tour starts in 0.15 to 0.6 s instead of 4 to 5 s.
  *Needs the author's word: a heavy build that writes outside this repository.*
- **P2b, golden logbooks.** Run the Ring reference over a fixed fixture set and commit the JSON logbooks
  as goldens. The Zig core must reproduce them.
- **P2c, protocol 2.** Add the graph record, the `[testoor node ID]` line, and the evidence-floor
  fields. Language-neutral, written before any Zig.
- **P2d, the Zig core design note.** Module boundaries, the bridge to Ring in the pattern of the other
  `ring_bridge_*.zig` files, memory model, and the `-j2` build discipline.
- *Exit:* all guards green under rnxc; goldens committed; protocol 2 and the design note read and
  accepted by the author.

### P3 -- The Zig core, in this order.
1. **Logbook writer, judge, five states, exit codes**, passing the goldens.
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

## 8. Decisions the author owes

1. **P2a**, the Ring++ engine copy: a heavy build that writes outside this repository. Do it once, or not yet; with the Atelier as a fast path (section 2b) it is no longer the only way to a cheap tour.
2. **P3**, the Zig core: approve the order in section 3 and the goldens as the acceptance test.
3. **P6**, the first two items can start now. Say whether they come before P2.
4. **P7**, which intelligence feature to build first. The recommendation is *explain a red stop*, because it only
   reads and can never change a verdict.
