# Testoor golden logbooks

*Phase P2b of `SOFTANZA_TESTOOR_ROADMAP.md`. The files in this folder are what the Zig core is built against: the same inputs must give the same bytes, in any language.*

## What is here

| folder | one case is | inputs | expected |
|---|---|---|---|
| `judge/<case>/` | **one tour**, judged | `record.json`, `output.txt`, `meta.json` | `expected.json`, `expected.txt` |
| `logbook/<case>/` | **one run**, built from judge cases | `run.json` | `expected.json`, `expected.txt`, `expected.exit` |

`record.json` is what a **face** read (`TESTOOR_PROTOCOL.md` section 1): the tour's stops, the claims at each, its routes. `output.txt` is what the child printed, one line per row, each row `<arrival in milliseconds><TAB><text>`. `meta.json` carries the child's exit code, whether it was killed, its error stream, the wall time, the seed it was handed, and **the face's ending rules as data**, so the core needs to know no language. `expected.json` is the tour exactly as the logbook writes it (`TestoorLogbookKeys()` lists the keys); `expected.txt` is the line a terminal shows.

The function under test is `TestoorVerdict(record, lines, stderr, exit, hung, face, wall_ms, seed)` in `stzTraveller.ring`. It is the first thing the Zig core implements (roadmap P3, step 1).

## The fourteen judge cases

| case | what it pins down |
|---|---|
| `01_kept_timed` | a narrated tour, kept, ended the way `pf()` ends |
| `02_diverged` | one diverged claim; non-ASCII text in a claim |
| `03_unjudged_branch` | a claim in a branch not taken is **unjudged** and is not a failure |
| `04_not_started` | nothing ran: a compile error read from the error stream |
| `05_broke_midway` | a runtime error with claims still owed: **unreached** |
| `06_hung` | killed at the deadline |
| `07_promise_spellings` | `TRUE` as `1`, a note in parentheses, quotes, `:Symbol`, `@@()` spacing, a bare list item by item, an empty line, a second `#` |
| `08_promise_lie_and_prose` | a lie, a short lie that must not hide in a later line, a prose promise, a kept list |
| `09_error_promise` | `#--> ERROR:` kept, and the raise it promised is not a break |
| `10_multiline_block` | a block as lines, wrapped but printed on one line, wrapped and wrong |
| `11_picture` | `PICTURE DOES NOT MATCH` is one diverged claim naming its row |
| `12_protocol_python` | a self-describing tour: seed, weather, stops, ok, fail, plan, routes, end |
| `13_unreadable` | a file the reader could not read |
| `14_exact_case` | a verdict marker is read in **any case** (`[pass]`, `[Ok]`); a promised value must match **exactly** (`Hello` is not `HELLO`) |

The five logbook cases cover an all-kept run (exit 0), a mixed run with skipped files and topics (exit 1), a run of tours that did not start, broke, hung or could not be read (exit 1), a kept tour found flaky (exit 1), and a run refused because its root is not there (exit 2).

## Conventions a port must know, because they are where two languages part

- **Arrival times** in `output.txt` are multiples of 250 ms, so a stop's time is exact in binary floating point. A port computes in integer milliseconds and takes the floor of the exact difference.
- **Wall times** in `meta.json` are whole hundredths of a second, so no printed time is a rounding tie (Ring prints `0.125` as `0.13`; other platforms print `0.12`).
- **Numbers in the prose:** an integer prints without decimals (`5`), any other number with exactly two (`1.50`, `0.88`). This is Ring's own rule and the goldens follow it.
- **Line endings:** every file is compared with carriage returns removed, and `.gitattributes` here marks the files `-text` so a checkout cannot change a byte.
- **Text is UTF-8.** `02_diverged` carries non-ASCII text on purpose.
- **Case.** String equality is exact, byte for byte (measured on Ring 1.27 and Ring++: `"Hello" = "HELLO"` is false). `lower()` folds ASCII letters only (`lower("ÀB")` equals `"Àb"`), so a port lowercases A to Z and nothing else. Verdict markers are the one place case does not matter.

## How it is used

- `base/test/testoor/testoor_golden_narrated.ring` regenerates every expected file from the inputs and compares byte for byte, then checks the verdicts against an **intent table written separately from the oracle's answers**. A golden that was only ever produced by the code it tests proves nothing, so the table says what each case is *supposed* to show.
- `base/testoor/golden_update.ring` rewrites the expected files. A human reads the diff in git before it is committed.
- A port passes when it reproduces every `expected.*` from the inputs.

## Protocol 2 (`protocol2/`, P3.3)

Cases version 2 added, which **only the Zig core can judge**: the Ring reference knows no node lines, no graph and no
`protocol` key. So these expected files were **written by hand from `TESTOOR_PROTOCOL_2.md` before the code that
satisfies them**, and `golden_update.ring` does not regenerate them. The Ring golden guard does not read this folder; the
Zig harness (`testoor_golden_test.zig`) does.

| folder | one case is | inputs | expected |
|---|---|---|---|
| `protocol2/judge/<case>/` | one tour, judged | the three of `judge/`, and optionally `graph.json` (the graph record) and `names.txt` (the names its source mentions, one a line) | `expected.json`, `expected.txt` |
| `protocol2/logbook/<case>/` | one run, built from `protocol2/judge/` cases | `run.json`, which may carry a `graph` object (`complete`, `why`, `owned`) | `expected.json`, `expected.txt`, `expected.exit` |
| `protocol2/impact/<case>/` | one change | `request.json`: the graph record, the changed ids, the tours with their names | `expected.json`, the impact record |

| case | what it pins down |
|---|---|
| `15_nodes_named_observed` | a node reached three times (one line spelled in another case, under the `ascii` fold), one named and never reached, one reached with a count; a node neither is not listed; rows in the graph's order |
| `16_node_line_count` | counts add; a count that is `x`, `-1`, `1 2` or `1.5`, a bare `[testoor node]` and a zero are ignored |
| `L6_graph_incomplete` | a run whose graph is not complete: `protocol` 2, the three figures, the incomplete line in the prose, and the run still exits 0 |
| `17_routes_and_claims` | four kept claims in two stops and two routes walked: what the evidence floor counts |
| `L7_floor_met` | a gate's floor (`min_kept` 3, unjudged refused, `min_routes` 1) that the walk meets: the evidence record, `met` true, exit 0 |
| `L8_floor_refused` | a floor (`min_kept` 5) the walk falls short of though the tour is kept: `met` false with the first reason, exit 1 |
| `18_nodes_on_a_diverged_tour` | a tour that reached two nodes and diverged: both observed in its own record (V1) |
| `19_nodes_on_an_unjudged_tour` | a tour that reached a node and printed no verdict: observed, its planned claim unjudged (V1) |
 | `impact/01_complete` | a change reaches its callers, found in order, and the tours that name them are selected |
| `impact/02_open_graph` | an open node: the reason is written, every tour is selected and none is skipped |
| `impact/03_two_changed` | two changed nodes: the union of their reaches |

## Protocol 3 (`protocol3/`, V1)

The evidence ladder (`TESTOOR_PROTOCOL_3.md` section 2). Written by hand before the code, like `protocol2/`, and read by the Zig
harness only. A run here is built from `protocol2/judge/` cases.

| folder | one case is | inputs | expected |
|---|---|---|---|
| `protocol3/judge/<case>/` | one tour that printed property lines (V2) | the inputs of `protocol2/judge/` | `expected.json`, `expected.txt` |
| `protocol3/logbook/<case>/` | one run, built from `protocol3/judge/` cases when its first case is there, else from `protocol2/judge/` | `run.json`, with `"ladder": true` or not, and a `graph` object or none | `expected.json`, `expected.txt`, `expected.exit` |

| case | what it pins down |
|---|---|
| `L9_ladder_graph` | cases 15, 16 (flaky), 18 and 19 against a complete graph of six: only the kept, finished, steady tour exemplifies; a node a mention reached takes its grade from the tour that observed it; one owned node stays named; `protocol` 3; exit 1 as without the ladder |
| `L10_ladder_no_graph` | cases 15 and 16 with no graph: no `owned` and no `named`; a node two tours exemplified lists both; exit 0 |
| `20_property_exhausted` | a property held over every value of a `dec` domain: a kept claim of kind `property` and its record |
| `21_property_failed` | a property that failed: a diverged claim, the shrunk counterexample, the counterexample line |
| `22_property_text_generalised` | a property held over unbounded texts; two malformed property lines ignored; a named node never reached |
| `L11_ladder_properties` | grades 4, 3 and 1 beside a named node, the counts of grades 3 and 4, `mentioned` in the graph figures; exit 1 |
| `L12_properties_no_ladder` | properties without the ladder: protocol 3 by the tours' records alone; exit 0 |
| `impact/04_reach_widened_capped` (under `protocol3/`) | the impact record in protocol 3: the reach as ids, widened by an open node, and the nodes it caps |
| `23`, `24`, `25` (judge) | three tours over the ladder page's graph: two exhaust their nodes, one generalises one and exemplifies two |
| `L13_floor_grade_refused` | a floor of `exhausted` over the impact set: 3 of 6 below, the first named in the reach's order; exit 1 |
| `L14_floor_grade_met` | a floor of `exemplified` over the same walk, the ladder not asked: met, a cap does not bite at grade 2; exit 0 |

## The Haro face (`haro/`, P3.6)

The face for `.haro` tours is in the core (`TESTOOR_PROTOCOL_3.md` section 6). These cases are written by hand and read by the
Zig harness only: there is no generator for them, so a case's `expected.*` is the author's reading of section 6.

| folder | one case is | inputs | expected |
|---|---|---|---|
| `haro/reader/<case>/` | one `.haro` source read by the face | `tour.haro` | `expected.json`: the record, on one line |
| `haro/judge/<case>/` | one narrated Haro tour judged with the face's `verdicts` rule | the inputs of `protocol2/judge/`, `meta.json` carrying the face | `expected.json`, `expected.txt` |

| case | what it pins down |
|---|---|
| `R1_narrated` | claims at the top level, inside the file's own function and inside an `if`; a claim before any scenario opens `(the tour)`; a commented claim, a built claim (counted, not recorded) and the helpers' bodies left out; a single-quoted literal |
| `R2_self_describing` | no `Scenario(` and no `Then(`: dialect `unknown`, no stop |
| `H1_a_report_line_is_not_a_verdict` | a program's `  FAIL     :...` report before two `THEN` lines: 2 kept, finished |

## Adding a case

Write the three input files (or `run.json`), run `golden_update.ring`, **read** the expected prose and JSON against what you meant the case to show, add the case to the intent table in the guard, and commit them together. Never edit an `expected.*` by hand.
