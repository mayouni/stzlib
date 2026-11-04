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
| later: `testoor_seed.zig`, `testoor_clock.zig`, `testoor_routes.zig`, `testoor_graph.zig`, `testoor_counters.zig` | steps P3.2 to P3.4 |
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
| `StzEngineTestoorVerdict(cRequest)` | `{"record":<record.json>,"output":"<output.txt>","meta":<meta.json>}` | the tour as the logbook writes it |
| `StzEngineTestoorLogbook(cRequest)` | `{"run":<run settings>,"tours":[<tour>...],"skipped":[...],"topics_skipped":[...]}` | the logbook JSON |
| `StzEngineTestoorProse(cLogbook)` | the logbook JSON | the summary a terminal shows |
| `StzEngineTestoorExit(cLogbook)` | the logbook JSON | 0, 1 or 2 |

Prose and exit are **functions of the logbook**, not of its inputs, so there is one source of truth. This
is the shape to confirm at the first step (the Ring `_TravRunProse` may read a field the JSON does not
carry; if so, the field joins the JSON and the golden says why).

A stateless call takes one string and returns one string. It allocates from an arena that dies at the end
of the call; the result is copied out through `rs2` (length-aware, so a NUL byte in a tour's output cannot
cut it). A boundary crossing costs microseconds against a child process that costs 70 ms or more, so the
JSON round trip is not where the time is.

**The stateful parts (clock, counters, graph) are handles**, under the engine-wrapper copy law of
`CLAUDE.md`: all mutable state lives in an engine handle, materialised at birth, because Ring copies an
object it stores and a lazily created handle forks silently.

## 4. The bytes that must agree

These are where two languages part. The goldens pin each; this table is the list a port is built from.

| rule | the fact, measured on Ring 1.27 and Ring++ |
|---|---|
| time | arrival times are integer milliseconds; a stop's time is the floor of the exact difference |
| numbers in prose | an integer prints without decimals (`5`); any other number with exactly two (`0.88`) |
| seconds from milliseconds | by integer arithmetic, rounding half up on the thousandth; the goldens have no ties, so this rule is chosen and written here, then pinned by a case |
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

## 9. Decisions owed

1. **One domain `stz_testoor`** (recommended) or one per module.
2. **JSON in, JSON out** for the stateless calls (recommended) or structured arguments.
3. **Keep the Ring reference behind `TESTOOR_CORE=ring`** (recommended) or delete it once the goldens pass.
4. **Accept the difference corpus** as part of the exit of P3.1, a heavy job to run alone.

Draft d1, 2026-11-04.
