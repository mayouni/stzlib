# Testoor protocol, version 3 -- DRAFT

*Draft d1, 2026-11-08. Phase P9 of `SOFTANZA_TESTOOR_ROADMAP.md`, on the author's ruling TESTOOR-LADDER-01 (the evidence
ladder is the direction of protocol 3; the six grade names stand; Testoor records certificates and never checks proofs). The
reasons and the grades are in `TESTOOR_EVIDENCE_LADDER.md`; this file holds only the records, as they are built. It adds to
`TESTOOR_PROTOCOL_2.md` and replaces nothing in it.*

## 0. Rule 0 still holds

**A version 3 key appears only when it was asked for.** A run that does not ask writes the bytes protocol 2 wrote (or protocol
1, when it carries no version 2 key either), so every golden under `golden/judge`, `golden/logbook` and `golden/protocol2`
stays the acceptance test, unchanged.

The logbook's `"protocol"` is the highest version of any key the run carries: `3` when it carries a version 3 key, else `2`
when it carries a version 2 key, else absent.

## 1. What version 3 adds

| addition | grade | step | state |
|---|---|---|---|
| the **ladder record**: each node's highest grade and the tours that gave it | 0, 1, 2 | V1 | **built 2026-11-08** (section 2) |
| the **property record**: a property held over generated inputs from a declared domain, shrunk on failure | 3 | V2 | **built 2026-11-08** (section 4) |
| the same record when every input of a finite domain was tried | 4 | V2 | **built 2026-11-08** (section 4.2): it falls out of the generator |
| every SCHEDULE of the declared weather up to a depth | 4 | V3 | sketched, 6(b) |
| `min_grade` and `over` in the evidence floor, and the impact record's widened `reach` and `capped` | -- | V4 | **built 2026-11-08** (section 5) |
| a node's checker `facts`, and the **certificate record** | 5 | V5, V6 | sketched, 6(a) and 6(c); waits on HARO-PROOF-01 |

## 2. The ladder record (V1)

**How it is asked for**: `"ladder": true` in the run of a request to the Ring seam (`StzEngineTestoorRunJson`, `...RunProse`,
`...RunExit`), `:ladder = TRUE` in `TestoorManifestJson` for the native runner, or `--ladder` on its command line
(`testoor run MANIFEST --ladder`).

```json
"ladder":{"owned":6,"named":1,"observed":3,"exemplified":2,
          "nodes":[{"id":"stzTax.Total","grade":"exemplified","tours":["fixtures/taxtour.py"]},
                   {"id":"stzTax.Round","grade":"observed","tours":["fixtures/counts.py"]}]}
```

| field | rule |
|---|---|
| `owned` | the size of the graph the run was given; **absent when the run has no graph** |
| `named` | grade 0: owned nodes no tour reached, counted as `owned` minus the listed rows and never below zero; absent with no graph |
| `observed`, `exemplified` | how many listed rows stand on grade 1 and on grade 2 |
| `nodes` | one row per node a tour REACHED, never one per owned node: grade 0 is a count, not a list |
| `grade` | `observed` or `exemplified`; the highest any tour gave the node |
| `tours` | the files of the tours that gave the node **that** grade, in run order, each once |

**The rules, each pinned by a golden (section 4):**

- **A node is observed** by a tour that printed `[testoor node ID]` for it with hits above zero (protocol 2 section 3).
- **A tour exemplifies** when it kept at least one claim and did not fail: no claim diverged or was unreached, it is not
  flaky, and it finished (`finished` or `finished-timed`). This is the same failure the tour line prints a seed for. Unjudged
  claims neither raise a tour nor stop it.
- **A node is exemplified** when a tour that exemplifies observed it. A node reached by a kept tour AND by a failing one is
  exemplified, and its `tours` names only the kept one: a failing tour's reach is not listed beside an exemplifying tour.
- **A tour's mention raises no grade.** A mention (the tour's source names the node; `mentioned` in this logbook, section 3) is
  a proxy: it stays in the tour's `nodes` record and counts for nothing here.
- **Rows** follow the order in which the run first OBSERVED each node: tours in run order, each tour's nodes in its own order,
  which is the graph's when it had one.
- **Ids** are compared exactly. With a graph they are already the graph's spelling (protocol 2 folds them when it reads the
  node lines); with no graph there is no fold to apply.
- **Place**: in the run, after `graph` and before `evidence`.
- **Prose**: one line after the graph lines, `ladder: 2 exemplified, 3 observed, 1 named, of 6 owned`, or with no graph
  `ladder: 3 exemplified, 0 observed; no graph, so named nodes are not counted`. A node list is the JSON's, never the prose's: a
  real library has thousands.
- **The ladder changes no exit code.** It is a report until a floor reads it (V4).
- **An incomplete graph lowers no grade of V1.** An `open` node caps only the grades above 2, from V4 on, where proof and
  exhaustion are claimed.

## 3. One word, one meaning: a mention is `mentioned`

Protocol 2 uses `named` for a **tour's** evidence: the tour's source mentions the node. The ladder, as ruled, uses `named` for
**grade 0**: the graph holds the node. **Ruled by the author, 2026-11-08 (TESTOOR-NAMED-01, option b): in a protocol 3 logbook
a mention is written `mentioned`.** So a run that asks for the ladder writes:

- a tour's node row `{"id":..,"evidence":"mentioned","hits":0}` where protocol 2 writes `"evidence":"named"`;
- the run's graph figures `"graph":{..,"mentioned":0,"observed":5}` where protocol 2 writes `"named"`;
- the prose `graph: 6 owned, 0 mentioned, 5 observed (three figures, never summed)`.

`named` then means one thing in that logbook: the ladder's grade 0. **A run that does not ask for the ladder, and the
single-tour verdict of the Ring seam (`StzEngineTestoorVerdict`), keep `named` byte for byte**, so nothing that reads protocol 2
changes. The core holds one evidence and writes its word by the logbook's version.

## 4. The property record (V2)

A **property** is one claim checked over many inputs drawn from a declared **domain**. It is walked in ONE child: the core
generates the inputs and shrinks a failure, the tour evaluates the claim on each input and prints one line. On Haro a walk pays
the library's compile, 15 to 25 s, so a property that started a child per input would cost minutes; one that loops costs one
walk.

### 4.1 The domain

A domain is a text: dimensions separated by `;`, each `NAME KIND ...`, a name of letters, digits and `_` that does not start
with a digit, each name once.

| kind | written | its values, in order | its origin (where a shrink goes) |
|---|---|---|---|
| `int` | `n int 0..100` | the integers from A to B, ascending | the value nearest 0 |
| `dec` | `rate dec 0..0.25 step 0.01` | A, A+S, A+2S ... up to B, exact, written with the step's decimals as text (`"0.07"`) | the value nearest 0 |
| `one` | `algo one quick\|merge\|heap` | the options, in the order written | the first option |
| `text` | `s text 0..12 of mixed` | texts of A to B letters (code points) over an alphabet, by length then letter by letter | A copies of the alphabet's first letter |

**Alphabets** are ordered lists of code points, so "simpler" means "earlier": `ascii` (a to z, A to Z, 0 to 9, the space, then
the other printable ASCII signs in code order), `latin` (U+00E0 to U+00FF without U+00F7), `greek` (U+03B1 to U+03C9), `hebrew`
(U+05D0 to U+05EA), `arabic` (U+0621 to U+064A), `cjk` (U+4E00 to U+4E9F), `emoji` (U+1F600 to U+1F64F), and `mixed`, which is
all of them in that order. `of "..."` gives the letters themselves, in order, with no `"` and no `;` among them.

A domain's **size** is the product of its dimensions' sizes; a text dimension of B letters over k letters has k^A + ... + k^B
values. A size above 2^53 is **unbounded**.

### 4.2 The inputs

Asked of the core with the domain, a seed and a number of tries (the Ring face: `StzEngineTestoorProperty`, op `inputs`).

- **When the size is at most the tries, every value is tried**, in order, the last dimension changing fastest. The answer says
  `"exhaustive":true` and `"of"` is the size.
- **Otherwise the first input is the origin** (every dimension at its origin) **and the rest are draws**: splitmix64 over the
  seed, the draw's number and the dimension's number; a text draws its length, then each letter. `"exhaustive":false`; `"of"`
  is the size, absent when unbounded. Draws may repeat; `tried` counts evaluations, never distinct values.
- An input is a JSON object, one key per dimension: an `int` is a number, every other kind is text.

### 4.3 The shrink

Asked with the domain and a failing input (op `shrink`): **candidates, simplest first**, each inside the domain and none equal to
the input. Dimensions are shrunk in the order written, the others held.

- **`int`, `dec`** (on the value's position counted from A for `dec`): with d the distance to the origin, the candidates are
  `v - d`, `v - d/2`, `v - d/4` ... `v - 1` toward the origin, halving toward zero, each once. From 100 toward 0:
  0, 50, 75, 88, 94, 97, 99.
- **`one`**: the options written before the current one, first option first.
- **`text`**: shorter first -- the first A letters, the first A + (n-A)/2 letters, then the text without its letter at each
  position in turn (none shorter than A); then simpler letters -- each position's letter shrunk like an `int` over its place in
  the alphabet, toward the first letter. A letter outside the alphabet has no candidates.

**The tour's loop**: try the candidates in order; the first that still fails becomes the input, and the candidates are asked
again; stop when none fails. `shrinks` counts the inputs taken. The loop is the face's (the Ring face: `TestoorProperty`, 1,000
evaluations at most); the order is the core's, so every language shrinks a failure to the same answer.

### 4.4 The line a tour prints

```
[testoor property {"id":"TAX-RATE-01","nodes":["stzTax.Total"],"domain":"rate dec 0..0.25 step 0.01","seed":42,"tried":26,"of":26,"exhaustive":true,"held":true}]
```

| field | rule |
|---|---|
| `id` | the property's name, no whitespace; required |
| `nodes` | optional: the graph nodes the property is about |
| `domain`, `seed` | what replays it |
| `tried`, `of`, `exhaustive` | the generated inputs checked (a failure stops them; the shrink's checks are not counted); the domain's size, absent when unbounded; true only when every value was tried and the property held |
| `held` | required |
| `counterexample`, `shrinks` | only when `held` is false: the input after shrinking, and how many shrinks it took |

A line that is not a JSON object, or lacks `id`, `held` or `tried`, is ignored and stays ordinary output, as a malformed node
line is. The face writes the line through the core (op `line`), so key order and spelling are the core's.

### 4.5 What the judge does with it

- **Every tour** keeps its property lines, in the order printed, as its `properties` record: in the tour's JSON after `nodes`,
  written in the table's order with the counterexample as the tour gave it. It is a version 3 key: a run that carries one writes
  `"protocol":3` (and, by section 3, `mentioned`).
- **In a self-describing tour** each property line is also a CLAIM in the stop it appears in: kind `property`, text
  `property ID`, kept when it held and diverged when it did not. A tour with no static claims that prints a property line is
  self-describing. **In a tour judged from its record** the line is recorded and is not a claim: wrap it in one
  (`Then("...", TestoorProperty(...)[:held], TRUE)`).
- **The prose** adds, under a tour, one line per property that did not hold:
  `    counterexample  ID  {"n":8}  (seed 42, 5 shrinks)`.
- **Exit codes do not change**: a failed property in a self-describing tour is a diverged claim, which already exits 1.

### 4.6 The ladder's grades 3 and 4

- A property that HELD, in a tour that did not fail (no claim diverged or unreached, not flaky, finished), raises its nodes to
  **`exhausted`** when it was exhaustive and to **`generalised`** otherwise.
- Its nodes are the line's `nodes`, each only if the same tour observed it; with no `nodes`, every node the tour observed. A
  property cannot raise a node no tour reached.
- A row of grade 3 or 4 adds `"properties"`: the ids that gave it, in run order, each once. The ladder's counts gain
  `"generalised"` and `"exhausted"`, after `"exemplified"`, when any tour of the run carries a property; so does the prose,
  highest grade first: `ladder: 1 exhausted, 1 generalised, 0 exemplified, 1 observed, 1 named, of 4 owned`.

## 5. The floor asks for a grade (V4)

A gate can now ask for more than kept claims: that every node a change reaches stand on a grade of the ladder. This is the
point of the ladder -- an `:llm` change to a critical point is refused unless what it touches was exhausted, or proved.

### 5.1 The set: the impact record in protocol 3

The impact record (protocol 2 section 5) answers a request that says `"protocol":3` with three more keys, after `skipped`:

| key | rule |
|---|---|
| `reach` | the changed nodes and their callers' closure, as **ids** in the graph's spelling, in the order protocol 2's reach finds them; then every **open** node not yet in it, in the graph's order, each followed by its own callers' closure |
| `widened` | the open nodes that joined the reach that way |
| `capped` | `{"id","by"}` for every node of the reach whose callees, followed breadth first in the edges' order, include an open node -- `by` is the first one found, and an open node caps itself |

**Why the reach is widened.** An open node dispatches by a name built at run time, so it may call the changed node through an
edge no reader saw. Its callers would then be missing from the reach, and a floor judged over a reach with a hole could be met
by never looking. So every open node joins the reach with its callers: the graph widens, it never guesses (ruling 16). The
record's `complete` and `selected` keep protocol 2's meaning: a selection from an incomplete graph still takes every tour.

A request without `"protocol":3` writes protocol 2's record, byte for byte.

### 5.2 The floor

```json
"floor":{"min_kept":3,"min_grade":"exhausted","over":"impact"}
```

- **`min_grade`**: `named`, `observed`, `exemplified`, `generalised`, `exhausted` or `proved`. **`over`**: the set it is judged over;
  `impact` is the only one, and the default. A floor that asks for a grade makes the logbook protocol 3.
- **The run carries the set** as `impact`: the protocol 3 impact record, as the core gave it (the Ring seam: `run.impact`; the
  native runner: `:impact_json` in `TestoorManifestJson`). Only `reach` and `capped` are read.
- **Each node of the reach** stands on its ladder grade (sections 2 and 4.6, computed whether or not the ladder is asked for);
  a node no tour reached is `named`. **A capped node can stand on no grade above `exemplified`**: under a floor above it, it fails
  whatever its tours did, because no proof and no exhaustion can be claimed through a name built at run time.
- **The checks run in this order**, and the reason is the first that fails: the five counts' checks of protocol 2 section 6, then
  the grade -- the first node of the reach, in its order, that falls short:
  `stzReport.Monthly is generalised, below the floor's min_grade exhausted`;
  `stzInvoice.Render can reach no grade above exemplified: it calls stzTemplate.Fill, which is open`;
  `stzTemplate.Fill dispatches by a name built at run time: it can reach no grade above exemplified`.
- **Refused, never guessed**: a floor that asks for a grade and a run that carries no impact record is not met ("the floor asks
  for a grade over the impact set, and the run carries no impact record"); nor is a `min_grade` that is not a grade.
- **The record** echoes `min_grade` and `over` after `min_routes`, and gains `"reach"` (the set's size) and `"below"` (how many fall
  short) after `routes_walked`. **The prose** adds `, 3 of 6 nodes in the impact set below exhausted` before the posture.
- **An empty reach meets any grade**, `proved` included: nothing the change touches is called by anything.

## 6. Conformance

Written by hand from section 2 before the code, and reproduced by the core on its first run (`zig build test-testoor`).

| case | what it pins down |
|---|---|
| `protocol2/judge/18_nodes_on_a_diverged_tour` | a tour that reached two nodes and diverged: both observed in its own record |
| `protocol2/judge/19_nodes_on_an_unjudged_tour` | a tour that reached a node and printed no verdict: the node observed, the planned claim unjudged |
| `protocol3/logbook/L9_ladder_graph` | cases 15, 16 (flaky), 18 and 19 against a complete graph of six: only the kept, finished, steady tour exemplifies; a node it shares with a flaky and a diverged tour lists it alone; a node only a mention reached (Rate, named by 15) takes its grade from the tour that observed it; one owned node stays named; `protocol` 3; exit 1 for the flaky and diverged tours, as without the ladder |
| `protocol3/logbook/L10_ladder_no_graph` | cases 15 and 16 with no graph: no `owned`, no `named`; a node two tours exemplified lists both, in run order; exit 0 |

| `protocol3/judge/20_property_exhausted` | a property held over all 26 values of a `dec` domain: a kept claim of kind `property`, the record with `"exhaustive":true` |
| `protocol3/judge/21_property_failed` | a property that failed: a diverged claim, the counterexample and the shrinks in the record, the counterexample line in the prose |
| `protocol3/judge/22_property_text_generalised` | a property held over an unbounded text domain (no `of`); a line that is not JSON and one with no `held` are ignored; the line names a node the tour never reached |
| `protocol3/logbook/L11_ladder_properties` | 20, 21 and 22 against a graph of four: one node exhausted, one generalised by the property that held, one observed where the property failed, one named; the counts of grades 3 and 4 written; exit 1 |
| `protocol3/logbook/L12_properties_no_ladder` | 20 and 22 with no ladder asked: the tours' `properties` alone make the log protocol 3; no `ladder` key; exit 0 |
| `protocol3/impact/04_reach_widened_capped` | the ladder page's graph: the reach as ids, the open template filler widened in, the renderer and the filler capped |
| `protocol3/judge/23`, `24`, `25` | three tours over that graph: two exhaust their nodes, one generalises one node and exemplifies two |
| `protocol3/logbook/L13_floor_grade_refused` | an `:llm` floor of `exhausted` over the impact set: 3 of 6 below, the first named in order; exit 1 though every tour is kept |
| `protocol3/logbook/L14_floor_grade_met` | the same walk under `exemplified`, the ladder not asked: met, because a cap does not bite at grade 2; exit 0 |

The same requests with the ladder NOT asked for write protocol 2 and no `ladder` key: the core guard and the native guard each
assert it. `testoor_property_narrated.ring` holds the Ring face to section 4: the domains through the seam, `TestoorProperty`
in-process (a failure shrunk to the same smallest input from two seeds), and two property tours walked as children.
