# Testoor, the Zig core -- design note

*Draft d1, 2026-11-04. Phase P2d of `SOFTANZA_TESTOOR_ROADMAP.md`; ruling 15 (the core is written in Zig,
not Ring). Written before any Zig, to be read and accepted by the author. It says where the line falls,
what crosses it, which bytes must agree, how the work is ordered and what it can get wrong. The
contracts are `TESTOOR_PROTOCOL.md` (1.1) and `TESTOOR_PROTOCOL_2.md` (draft); the acceptance test is
`golden/`.*

## 1. What moves, and what does not

| moves to Zig (the engine) | stays with the face (Ring today, Haro next) |
|---|---|
| the judge: promises, markers, the five states, the six endings | reading a source file into a tour record |
| the protocol reader: the `[testoor ...]` lines | launching a tour, killing it at the deadline, stamping each line's arrival |
| the logbook writer: JSON, prose, exit code | the face profile as data (`TestoorRegisterFace`) |
| seeds, the stepped clock, weather, the scheduler hook | the code-graph readers (`stzCodeGraph`, the parsed program) |
| the route join, the graph store (protocol 2), node counters | the court, refinement, diagrams, the intelligence layer |

**The walk loop stays in the face's language until step P3.5.** It spawns, reads lines with their
arrival times, enforces the deadline and calls the judge. The process seam already exists in the engine
(`system.zig`, spawn by argv, non-blocking read, timed wait). Moving the loop is only wanted when the stz
desk must call the runner without a Ring VM (`stz guard`), and not before.

## 2. One domain, in the engine's own pattern

A new domain `stz_testoor`, built the way the engine's other domains are (`perf`, `watch`, `histogram`):

| file | holds |
|---|---|
| `src/testoor.zig` | re-exports the modules below; the Zig tests live in the modules |
| `src/testoor_text.zig` | line splitting, trimming, ASCII-only lowering, the JSON string escape, number formatting |
| `src/testoor_promises.zig` | `#-->` promises: variants, canonical form, normalisation, multi-line matching |
| `src/testoor_protocol.zig` | the `[testoor ...]` lines and their adoption into a record |
| `src/testoor_verdict.zig` | `verdict(record, output, meta)`: stops, claims, endings, states |
| `src/testoor_logbook.zig` | the run object, its JSON, its prose, its exit code |
| `src/testoor_clock.zig` | the world of a tour: seed, stepped clock, weather and the tick each falls due at (P3.2; the seed is 40 lines that share the weather's pick count, so one file and not `testoor_seed.zig`) |
| `src/testoor_graph.zig` | the graph store: the graph record, id comparison under a fold, the reach (closure of callers), impact selection, the nodes record (P3.3) |
| `src/testoor_routes.zig` | the route join: owned, walked, unwalked, unknown walks, the findings the join raises, the report as prose and JSON (P3.3) |
| `src/testoor_counters.zig` | node counters: a node registered once answers a slot, a hit by slot is an array increment, the report is the `[testoor node ID N]` lines (P3.4) |
| `src/ring_bridge_testoor.zig` | the `regs` table and the `R.ring_vm_api_*` glue |
| `src/stz_testoor_entry.zig` | exports `ringlib_init` |

and one line in `build.zig`: `.{ .name = "stz_testoor", .entry = "src/stz_testoor_entry.zig", .needs_ring = true }`.

**The modules above `ring_bridge_testoor.zig` import nothing from Ring.** `zig test` runs them with no
virtual machine, and the later `stz guard` child links them as they are. One domain, not several: the
modules share the text rules, and splitting them would put the same escape function in two libraries.

## 3. What crosses the bridge: JSON in, JSON out

The goldens already say what the data is, in formats any language reads. The bridge takes those formats and
adds nothing.

| call (Ring name) | in | out |
|---|---|---|
| `StzEngineTestoorVerdict(cRequest)` | `{"record":<record.json>,"output":"<output.txt>" or [[text, ms]...],"meta":<meta.json>}`; `"detail":1` adds each stop's opening and closing millisecond | the tour as the logbook writes it |
| `StzEngineTestoorRunJson(cRequest)` | `{"run":<settings>,"tours":[<tour>...]}` | the logbook JSON |
| `StzEngineTestoorRunProse(cRequest)` | the same request | the summary a terminal shows |
| `StzEngineTestoorRunExit(cRequest)` | the same request | 0, 1 or 2 |
| `StzEngineTestoorTourProse(cTourJson)` | one tour as the logbook writes it | the line a terminal shows for it |
| `StzEngineTestoorNodeSlot(cId)`, `...NodeHit(nSlot [, nHits])`, `...NodeHitId(cId [, nHits])` (P3.4) | an id, or a slot | a number: the slot (0 for an id a node line could not carry), or the count after. These are the HOT calls: numbers in, a number out, nothing allocated |
| `StzEngineTestoorNodes(cOp, cText)` (P3.4) | `report`, `registered`, `get` (cText is the id) or `reset` | a string: the node lines, a count, or `1` |
| `StzEngineTestoorImpact(cRequest)` (P3.3) | `{"graph":<graph record>,"changed":[ids],"tours":[{"file","names":[..]}]}` | the impact record of protocol 2 |
| `StzEngineTestoorRoutes(cRequest)` and `...RoutesProse(cRequest)` (P3.3) | `{"items":[..],"walks":[..],"untouched":[..],"court":[..]}`: what the face read and what its court said | the routes report as JSON, or as prose |
| `StzEngineTestoorWorld(cOp, cText, nA, nB)` (P3.2) | an operation, a text and two numbers | a string; the operations and their answers are listed above `call` in `testoor_clock.zig` |

Prose and exit are **functions of the run and its tours**, so the three run calls take one request. (Confirmed at
P3.1: `_TravRunProse` reads nothing the tour JSON does not carry.)

A stateless call takes one string and returns one string. It allocates from a per-thread arena that every
call reuses and empties (a fresh arena over the page allocator cost 10.8 us a call, found by the P3.4 measurement); the result is copied out through `rs2` (length-aware, so a NUL byte in a tour's output cannot
cut it). A boundary crossing costs microseconds against a child process that costs 70 ms or more, so the
JSON round trip is not where the time is.

**The stateful parts (clock, counters, graph) keep their state in the engine**, under the engine-wrapper copy law of
`CLAUDE.md`: Ring copies an object it stores, so nothing mutable is left in a Ring object. The world of a tour (P3.2)
is the simplest case of it: ONE per thread, as Ring keeps one global per virtual machine, so Ring holds no handle and
nothing can fork. Counters and the graph are many, and will be handles materialised at birth.

## 4. The bytes that must agree

These are where two languages part. The goldens pin each; this table is the list a port is built from.

| rule | the fact, measured on Ring 1.27 and Ring++ |
|---|---|
| time | arrival times are integer milliseconds; a stop's time is the floor of the exact difference |
| numbers in prose | an integer prints without decimals (`5`); any other number with exactly two (`0.88`) |
| seconds from milliseconds | `ms / 1000` as an f64, printed with two decimals rounded on the EXACT binary value, ties to even: `0.125` is `0.12`, as on Ring++ (Ring 1.27 prints `0.13`; the goldens have no ties). Stop times are `floor((closed - opened) * 1000)` in f64, as the reference computes them |
| string equality | exact, byte for byte: `"Hello" = "HELLO"` is false, `"é" = "É"` is false |
| lowering | A to Z only. `lower("ÀB")` is `"Àb"` |
| verdict markers | `[pass]`, `[Ok]`, `[FAIL]`: read in any case (golden 14) |
| JSON strings | **five escapes only**: backslash, quote, TAB, LF, CR. Any other control byte and all non-ASCII are written raw. `std.json` escapes more, so the writer is the core's own |
| JSON key order | the order `TestoorLogbookKeys()` returns |
| lines | split at LF, CR removed; a line that is not valid UTF-8 passes through byte for byte |
| files | compared with CR removed; the directory is `-text` |

## 5. The public contract the Ring side keeps

After the port, the Ring files become **thin wrappers** that turn their arguments into a request, call the
engine and read the answer back. Their signatures do not change, because others hold them:

- `Tour(path)` and `TourQ`, the reader, which the Atelier (plane A1) consumes;
- `_TravJudge(record, lines, ending, exit, wall)`, five arguments, which the Atelier also consumes;
- `TestoorVerdict(...)`, `stzTraveller` and its methods, `TestoorLogbookKeys()`.

The old Ring bodies are not deleted. They are kept as **the reference**, marked, and a switch
(`TESTOOR_CORE=ring` in the environment) makes the wrappers call them instead of the engine. That gives
the difference test of section 8 two implementations in one process.

## 6. Build and test discipline

- **One heavy job at a time, `-j2`.** The engine build is the kind of job this machine stops dead on.
- A step `test-testoor` in `build.zig`, the way `test-x509` and `test-xml` are, so the inner loop runs this
  domain's tests only and not the engine's whole suite. The full `zig build test` is a pre-commit gate.
- Each module carries its own Zig tests. The first test written is **the golden harness**: a Zig test that
  reads `golden/`, judges every case and compares every `expected.*` byte for byte. It is red before any
  module exists, and it is the whole of the acceptance test for step P3.1.
- For `rnxc` the engine copy must be rebuilt with the new domain (`bench/engine_copy.py` of the Ring++
  checkout; how it takes a domain list is checked when the first domain is added).

## 7. Order of work, with what each step must satisfy

| step | what | acceptance |
|---|---|---|
| P3.0 | the Zig golden harness | compiles and is red |
| P3.1 | text, promises, protocol, verdict, logbook | the harness is green; the Ring guards run **through the wrappers** unchanged on Ring 1.27 and on Ring++ (reader 74, runner 80, promises 52, protocol 55, golden 75) |
| P3.2 | seeds, clock, weather, scheduler hook | `testoor_clock_narrated.ring` unchanged (66 on Ring, 56 on Ring++) |
| P3.3 | route join, graph store, the graph record of protocol 2 | the routes and impact guards unchanged; new goldens `15`, `16`, `L6` of protocol 2 section 10 |
| P3.4 | node counters | a measurement first: 11.5 us an event is what the Ring trace hook costs, and a VM that calls the counter directly must beat it |
| P3.5 | the `stz guard` child | the stz desk's guard run through the Zig runner gives the same exit code and logbook |

Every step ends with a Zig test per module and with the guards of the steps before it still green.

## 8. What can go wrong

1. **Hidden Ring semantics.** Ring compares a number with a numeric string as equal and treats `0 = ""`
   as true. The reference may lean on this where nobody wrote it down. *Mitigation:* do not trust a reading
   of the Ring; run the **difference test** below.
2. **The promise matcher is the intricate part.** Variants, canonical form, normalisation and multi-line
   joined-first matching are about 270 lines (`_TravNorm` to `_TravPromiseAt`) whose edge cases the goldens (cases 07 to 11) and 52 promise
   assertions cover well but cannot cover entirely. *Mitigation:* a **difference corpus**: record the
   output of every tour in the library once (a heavy job, run alone), keep it outside git, and have both
   implementations judge it; any disagreement is a bug in one of them, or a missing golden.
3. **Number formatting.** Two platforms print `0.125` differently. The goldens avoid ties on purpose; the
   rule in section 4 says what the core does when one occurs, and a case must pin it.
4. **The engine copy goes stale** whenever the engine's Zig changes: a worktree that built its own engine
   hands `rnxc` the wrong DLLs. The rebuild recipe is in the repository notes.
5. **Haro's own module system** may change how a face loads the wrappers. The bridge is by name and by
   string, which survives that; a handle API would not.
6. **Scope drift.** The graph store and the counters are protocol 2 and are not wanted before P3.3; the
   risk is building them to feel finished.

## 9. Status, 2026-11-05 (P3.0 and P3.1 done)

The four recommended decisions of section 10 were taken on the author's word. Built and measured:

- **`zig build test-testoor -j2`**: 26 tests, 30 s cold, 30 ms to run, no Ring. It reads `golden/` and compares 43
  expected files byte for byte (the harness is shown to fail on a tampered file), and re-runs the same cases through
  the text surface the Ring bridge calls.
- **Modules**: `testoor_text`, `testoor_json` (a reader that accepts the raw bytes Ring writes), `testoor_promises`,
  `testoor_verdict`, `testoor_logbook`, `testoor_api` (text in, text out), `ring_bridge_testoor`, `stz_testoor_entry`.
- **Ring side**: `base/testoor/stzCore.ring`. `TestoorVerdict` asks the core when the `stz_testoor` library is loaded
  and the Ring reference otherwise (`TestoorCore("ring")` or `TESTOOR_CORE=ring` force it). A verdict the core cannot
  give, or an answer the library's JSON reader refuses (a raw control byte), falls back to the reference for that tour.
- **On rnxc, with the core judging, all ten Testoor guards pass**: core 17, golden 75, reader 74, promises 52, routes 44,
  protocol 55, impact 51, refine 34, clock 56, runner 80. The guard `testoor_core_narrated.ring` holds the two
  implementations side by side in one process.
- **Ring 1.27** runs nothing on this main: `base/faculty/stzModelRegistry.ring` line 246 is a syntax Ring 1.27
  refuses, so no guard loads there. The rnxc runs are the evidence.

Four findings the port made, each now pinned:

1. **A judged claim's `want` is not in the logbook**, and the promises guard reads it. The Ring glue restores it from the
   input record; the engine's answer stays the golden bytes.
2. **`:opened` and `:closed` are not in the logbook either**, and the runner guard reads them. `"detail":1` adds them in
   milliseconds, to the Ring glue's request only.
3. **A request missing a field panicked** (an unchecked `.?`), and a panic in a ReleaseSafe library ends the whole VM.
   Every field read is an error now, a number too large for an integer reads as 0, and a test cuts a request at every
   third byte to show none panics.
4. **The one deviation from the reference**: a `[testoor seed X]` or `[testoor plan X]` that is not a number makes the
   reference raise R41 (Ring and Ring++ alike) and the core ignore the line.

Not done, and named: the Traveller's own `Json()`, `Prose()` and `ExitCode()` still run in Ring (the engine versions are
tested against the goldens and from Ring, but not yet called by the runner); the **difference corpus** over recorded
real tour output (section 8, item 2); the engine copy for rnxc must name `stz_testoor` explicitly when it is made,
because `bench/engine_copy.py` of the Ring++ checkout does not list a domain it was never told about.

### P3.2, 2026-11-05 -- DONE

The world of a tour moved to the core: `testoor_clock.zig` (seed, stepped clock, weather, the tick each falls due at;
12 Zig tests), the bridge call `StzEngineTestoorWorld`, and `stzClock.ring` rewritten so every public function asks the
core when it is there and runs the unchanged reference (`...Ring`) when it is not. What the core keeps is TIMING and
STATE; a weather's payload (the spec the tour wrote) stays in Ring by ordinal, so no JSON round trip stands between a
tick and the supervisor it kills a child of. The runner's own seed draw now calls `TestoorDrawSeed()`, one formula
where there were two. Choosing who runs the world (`TestoorCore(...)`) forgets what was declared, so the state is never
left behind in the other place. `base/testoor/stzClock.ring` explains who owns what.

**Three differences from the reference, deliberate, each pinned in `testoor_core_narrated.ring`:**

1. A weather declared without a tick gets one from the SEED (splitmix64 over the seed and the picks since it was set),
   not from Ring's `random(5)`. Ring's is the C runtime's `rand()`, so the same seed picked another tick on each OS and
   VM, and a tick that moved with every other draw the tour took. The first four picks of seeds 42, 43 and 7 are pinned
   from a second implementation of the formula, because a change to it changes every replay anyone recorded.
2. `ClockTo(:stepped, [ s, d ])`, `Weather(:child_killed, [ c, t ])` and `Weather(:skew, [ ms ])` want numbers; the
   reference took a numeric string and stored it unconverted.
3. A runner seed that is not a number is no seed (a draw, reported); the reference raised R41.

**Run, 2026-11-05, on rnxc against `engine-stzlib2`:** `zig build test-testoor -j2` 38 of 38 (the 26 of P3.1 and 12 new, 105 ms);
the core guard 39 (17 + 22); `testoor_clock_narrated.ring` **56 with the core owning the world and 56 with
`TESTOOR_CORE=ring`**, so the step's exit holds on both paths; and the other eight guards as before: golden 75,
reader 74, promises 52, routes 44, protocol 55, impact 51, refine 34, runner 80. The first run of the clock guard
FAILED 12 assertions and took 494 s, and it was not the world: the rnxc prefix (`rnxc prefix stzBase.ring`, run from
`base/`) was stale after the library edit, so every planted tour compiled the whole library as its own child (230 s
for one tour on a loaded machine, against a 60 s walk timeout) and four tours read as `unreached`. After the prefix
(30 MB, 271 s once, under load) the same guard is 7.7 s and a tour starts in 0.7 s. **Build the prefix before any
guard that walks children.**

### P3.3, 2026-11-06 -- DONE

The route join and the graph store moved to the core, and the version 2 additions of the verdict came with them.

- **Written first:** the goldens `15`, `16`, `L6` and `impact/01..03` under `golden/protocol2/`, by hand from the protocol
  document, because the Ring reference cannot judge version 2 and no oracle exists. The Zig harness reproduced all of them
  on its first run.
- **`testoor_graph.zig`** reads a graph record tolerantly, compares ids under the declared fold and never parses one,
  closes a change over its callers in the order found, selects tours (an incomplete graph selects every tour), and joins what
  a tour reported (`[testoor node ID [N]]`) and named with what the graph owns into the tour's `nodes`.
- **`testoor_routes.zig`** is a port of the counting and both faces of `stzRouteMap`. The Ring face still reads the plans, the
  walks and runs the court (`StzCheckPlanCoverage`); the court's findings cross as data and come first, as before.
- **The Ring face split:** `stzImpact.ring` now has `_ImpactFace` (the subject's source, its code graph, the seed of a change,
  the line that dispatches by a built name), `_ImpactCore` (a graph record of NAMES as ids, one edge per raw call entry and a
  second from the class when the caller is a constructor, so the closure comes out in the reference's order) and the
  unchanged loop as `_ImpactClosureRing`. `stzRouteMap` asks the core for `Json()` and `Prose()` and keeps `_JsonRing()` and
  `_ProseRing()`; both fall back to the reference when the library is absent or does not know the call.
- **Decisions taken where the protocol draft was silent** are listed in `TESTOOR_PROTOCOL_2.md` section 4 and pinned by the goldens.
- **Run, on rnxc against `engine-stzlib2`:** `zig build test-testoor -j2` 53 of 53 (48 plus 5 route-join tests, 63 ms); the core
  guard 56 (39 plus 17: the route report and impact side by side, and protocol 2 through the Ring seam); routes 44 and impact
  51 **unchanged** through the core and with `TESTOOR_CORE=ring`; golden 75, reader 74, promises 52, protocol 55, refine 34,
  clock 56, runner 80. Ten guards, 577 assertions.
- **Not built:** the evidence floor (`L7`, `L8`), node counters (P3.4), and the Ring face handing a graph and names to the
  verdict from the runner (it belongs to P4, node-level route coverage; the core takes both today and the guard sends them).

### P3.4, 2026-11-06 -- DONE

Node counters, the numerator of graph coverage, and the measurement that had to come first.

- **Measured first, on rnxc (Ring++):** an empty Ring function call 0.05 us; an engine call that takes and returns numbers
  0.15 us; an engine call that RETURNS A STRING **10.81 us**. The Ring trace hook the first design considered costs 11.5 us an
  event on Ring 1.27 and **does not exist on Ring++** (`ringvm_settrace` is R3 on rnxc), so a counter called directly is the
  only route there and the only one that can be cheap.
- **A defect of my own was found by it.** Every bridge call built a fresh arena over the page allocator, so each call that
  returned text paid a system allocation: 10.81 us, as slow as the hook, on `ClockTick` and every world call since P3.2.
  The bridge now reuses one arena per thread (up to 1 MB kept): the same call costs 0.23 us.
- **`testoor_counters.zig`:** a node is registered ONCE and answers a slot; a hit by slot is an array increment, a hit by id one
  hash lookup more. An id with a space or a control byte (32 and below) is refused with slot 0, because a node line could not
  carry it; a count saturates at fifteen nines, the longest a node line carries; `reset` zeroes the counts and keeps the slots.
  Raw in Zig a hit by slot is under a nanosecond (the optimiser may fuse the loop) and a hit by id 19 ns.
- **The Ring face, `stzNodes.ring`:** `TestoorNodeSlot`, `TestoorNodeHit`, `TestoorNodeHitN`, `TestoorNode`, `TestoorNodeN`,
  `TestoorNodeCount`, `TestoorNodesLines`, `TestoorNodesReport` (prints the lines), `TestoorNodesReset`. The counts live in the
  engine, never in a Ring object. With no core, two parallel Ring lists do the same thing, slower and in the same answers.
  `TestoorReset()` and `TestoorCore()` zero them with the rest of the tour's world.
- **Through Ring, per event (100,000 events each):** `TestoorNodeHit(slot)` **0.19 us**, `TestoorNode(id)` 0.26 us, an empty
  Ring function 0.08 us. The trace hook is 11.5 us: sixty times more. `testoor_counters_narrated.ring` asserts the bounds
  (under the hook's 11.5 us for both hits, under 5 us for an engine call that returns text) and says by name that the hook
  itself is not re-measured on this VM.
- **Run, on rnxc against `engine-stzlib2`:** `zig build test-testoor` 60 of 60 (53 plus 7 counter tests); eleven guards, 606
  assertions (the new `counters` 29, and the other ten unchanged); counters, routes, impact and clock also with `TESTOOR_CORE=ring`.
- **Not built:** the Ring face handing a graph and the tour's names to the verdict from the runner (P4), an automatic flush of the
  report at the end of a tour (a tour calls `TestoorNodesReport()` itself), the evidence floor (`L7`, `L8`).

## 10. Decisions owed (taken 2026-11-05, the recommended answers)

1. **One domain `stz_testoor`** (recommended) or one per module.
2. **JSON in, JSON out** for the stateless calls (recommended) or structured arguments.
3. **Keep the Ring reference behind `TESTOOR_CORE=ring`** (recommended) or delete it once the goldens pass.
4. **Accept the difference corpus** as part of the exit of P3.1, a heavy job to run alone.

Draft d1, 2026-11-04.
