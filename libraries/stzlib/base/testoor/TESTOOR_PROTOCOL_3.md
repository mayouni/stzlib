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
| `list` | `xs list 0..10 of int -5..5`, `ls list 0..4 of list 0..3 of int 0..9` | lists of A to B elements of any kind above, a list included, by length then element by element, the last fastest | A copies of the element's origin |

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
- An input is a JSON object, one key per dimension: an `int` is a number, a `list` an array of its elements, every other kind
  is text. A Ring check receives a list as a Ring list.

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
- **`list`**: as a text -- the first A elements, the first A + (n-A)/2, then the list without each element in turn -- and then
  each element, in place, by its own kind's candidates, nested lists included.

**What a shrink cannot do.** Each dimension is shrunk with the others held, so a failure that needs two dimensions to change
TOGETHER stops at a local minimum: no single simpler input still fails, though a simpler pair would. Measured on stzList's
`IsEqualTo` (TESTOOR_ZIG_CORE.md, list domains): the shrink stopped at `[2,2,0,3]` against `[2,0,3,0]`, where `[1,1,2]` against `[1,2,2]` is
smaller, because removing an element from one list alone makes their lengths differ. The counterexample is still a true one.

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

## 6. The Haro face: `.haro` tours read and walked by the core (P3.6)

Since 2026-11-09 no new code is written in the retired language (PRINCIPAL-NORING-01), and the estate's new tests are
`.haro` files. Reading a tour's source was the Ring face's work, in Ring; the face for `.haro` tours is in the core
(`engine/src/testoor_reader.zig`), so the native runner walks them with no other language involved.

### 6.1 `testoor walk`

    testoor walk FOLDER [--suffix S] [--haro PATH] [--json | --prose] [--seed N] [--repeat N] [--timeout MS] [--start MS] [--ladder] [--graph GRAPH.json]

- **The tours** are the files under FOLDER, in any folder below it, whose name ends with `_narrated.haro` (or `--suffix`),
  sorted by path. A file or a folder whose name begins with `_` or `.` is never walked: measurement scripts, planted
  fixtures and data live there.
- **Each tour** is read by the Haro face (6.2) and launched as `<haro> <file>` from its own folder, where a guard's
  `load "../../stzBase.ring"` resolves. `<haro>` is `--haro`, else the `HARO_EXE` variable, else `haro` on the path. Nothing
  is added to the tour's arguments: a guard that reads `SysArgv` reads only what it would read run by hand.
- **The logbook** is the one `testoor run` writes; the run's `root` is FOLDER.

### 6.2 What the Haro face reads

A `.haro` guard is narrated: `Scenario("...")` opens a stop, `Then("...", got, wanted)` is a claim of the stop in progress,
and it prints `SCENARIO: <title>`, `  THEN  <claim>  [PASS]` or `[FAIL]` and a closing `TOTAL:` line.

- **A stop** is a line beginning with `Scenario(` whose first argument is ONE text literal (`"..."` or `'...'`, then `,`
  or `)`); **a claim**, a line beginning with `Then(` likewise, of kind `sees`. A claim before any stop opens `(the tour)`.
- **A claim whose text is built at run time** (`Then("a" + tX, ...)`) is counted in `asserts` and not recorded: the judge
  adds it when its verdict line is printed. The text is never guessed from the line.
- **Read at the top level and inside the file's own functions; never inside a HELPER's body** -- a function named Then,
  Scenario, Summary, Chk, ChkEq or Sec, or one whose body prints `[PASS]`, `[FAIL]` or `[OK]`. A class body is not read. A
  line beginning with `#` is a comment.
- **The dialect** is `narrated` when the file calls `Scenario(` or `Then(`, else `unknown`; a self-describing tour (one
  that prints `[testoor ...]` lines) is judged from what it prints, as in protocol 1.1.
- **A verdict, in a narrated tour, is only a line that begins (spaces aside) with `THEN `.** A program under test prints
  reports of its own (`  FAIL     :triage_extract=... -- ...`), and a report that says FAIL is output, not a failed claim.
  The face carries the rule as data (`verdicts` beside `ignore` and `endings`); a face that leaves it empty reads a verdict
  from any line of a verdict's shape, as in protocol 2. **The same holds for a picture:** a face that names its verdicts has no
  picture claims, and a line saying a picture `DOES NOT MATCH` is output (2026-11-14, golden H4; found when `testoor walk`
  judged `testoor_promises_narrated.haro`, whose GIVEN line names the phrase).

### 6.3 How a Haro tour ends

Tried in order over the tour's output, a verdict line (`THEN  ...`) never read for it, since a claim's text may hold any
of these:

| the output holds | the tour |
|---|---|
| `Haro refused this statement` | **broke**: Haro runs a file up to a statement it refused and stops there |
| `Error (R` | **broke**: a runtime error |
| `TOTAL: ` | **finished**, whatever the exit code: a guard exits with its failure count, and those failures are diverged claims, not a break |

Otherwise a non-zero exit is `broke`, a zero exit `finished`, and a tour past its deadline `hung`, as for every face.

### 6.4 A claim is judged once (every face)

A verdict line lands on the first claim of its text that is **not judged yet**. When every claim of that text is already
judged, the line is a **second check** and joins the stop in progress as its own claim, as a verdict the reader had no
claim for always did. Until 2026-11-14 it landed on the first claim again and replaced its state, so a tour printing
`FAIL  x` and then `ok  x` read as kept: a failure the logbook did not show. Found on the Foundry's `af2_rehearse.haro`,
which checks "it signs and installs" twice; the walk counted 19 claims where the guard counted 20. No golden of protocols
1 to 3 changed. The Ring reference (`TESTOOR_CORE=ring`) keeps the old landing: it is the retired language's, and the
core is the judge.

### 6.5 Two deadlines (every tour the core walks)

A tour walked by the core (`testoor run`, `testoor walk`) is held to **two deadlines**:

- **the start deadline**, from the child's start to its first output (the first bytes on its standard output) --
  `--start MS`, the manifest's `run.start_ms`; 0 is the tour's deadline;
- **the tour's deadline**, from that first output to the child's exit -- `--timeout MS`, `run.timeout_ms`.

The time before a tour prints anything is its runtime's, not the tour's. haro.exe compiles a program's image of the
library before the program prints its first line: 20 s to 182 s on 2026-11-13, 5 to 11 minutes on 2026-11-12. One
deadline counted from the start killed that compile, the image was never written, and the same tour read `hung` on every
later run. `testoor walk` gives a tour 20 minutes to start and 10 to run; `testoor run` keeps 0 (the tour's deadline) unless
its manifest names one.

A child past either deadline is `hung`, killed with everything it started. The logbook writes, beside `timeout_ms`, the
`start_ms` the run applied when it applied one, and in each tour **`first_output_ms`**, when the first output arrived,
whenever the walk measured one; the tour's line names it when it is 10 s or more (`(121.73 s, first output at 121.39 s)`),
so a slow start reads as slow. Both are absent from a logbook that applied or measured neither, whose bytes are those of
protocol 2. The Ring runner (`stzTraveller`, retired) keeps one deadline from the start.

### 6.6 A Haro unit's graph: `testoor graph`

    testoor graph FILE.haro [--haro PATH] [--out FILE.json]
    testoor graph --lines LINES.txt [--root DIR] [--out FILE.json]

writes the graph record (protocol 2 section 2) of the unit `FILE.haro` loads, from what `haro graph FILE.haro` prints
(`engine/src/testoor_harograph.zig`): the compiler's resolution of the unit, not a text scan of it. The record's `subject` is
the unit's first file, its `language` is `haro`, and its `fold` is `ascii`, since a unit's `.ring` files fold case.

| haro graph prints | the record holds |
|---|---|
| `FUNC|name|line` | a node `name`, kind `function` |
| `METHOD|class|name|line` | a node `class.name`, kind `method`, named `name` |
| `CALL|from|to|static` | an edge, kind `call`, each end written in its node's spelling |
| `CALL|from|name|dynamic|n` | an edge, kind `dispatch`, to **every** method of the unit named `name`: the set of possible callees, exact, so the graph stays complete. A name no method carries leaves the caller **open** |
| `UNFINISHED|function` | the node is **open**: its calls are missing |
| `CALL|caller|*|late|n` | haro v0.77 on (HARO-GRAPH-LATECALL-01): the caller holds n calls by a name built at run time -- the node is **open**, and no edge is drawn |
| a file's own statements (`<top>`) | a node `<top>:FILE`, kind `top`, made when it first calls something |

**A call by a name built at run time** (`call tName()`, `eval(...)`) leaves no line in `haro graph`, so the face reads each file
of the unit, from the folder haro graph ran in, and the function holding one is **open** ("dispatches by a name built at run
time"). A string, a comment and a method named `call` are not one. A file it cannot read, or lines given without `--root`,
leave the record **not complete**, `why` saying so: the record never certifies what was not read.

Measured on a Foundry guard's unit (`af1_pack.haro`, 2026-11-15): `testoor graph` writes it in 50 s, 25.6 MB -- 48,939 nodes
(11,103 functions, 37,828 methods, 8 files' own statements) and 196,894 edges (66,951 `call`; 8,769 calls dispatched by name over
2,342 names, which make 129,943 `dispatch`). 358 nodes are open: 12 functions the compiler could not finish, 185 calling a
method by a name no method of the unit carries, and 161 calling by a name built at run time (`call f()` in
`StzCallMethodOrFunction`, `call _fWork_()` in `stzWorkerPool.Drain`). So the record is not complete, and says why.

### 6.7 The impact of a change over a Haro unit: `testoor impact`

    testoor impact GRAPH.json --changed ID [--changed ID ...] [--tours FOLDER [--suffix S]] [--protocol 2]

writes the impact record (section 5.1) of a change to the nodes named, over a graph record `testoor graph` wrote. A tour
under FOLDER is selected when its source CALLS a name of the reach: the Haro face reads each tour's names
(`testoor_reader.zig`, `namesOf`) -- every identifier followed by `(` in code, a function or a method after a dot, never in a
string or a comment. A graph that is not complete still selects every tour (protocol 2's rule). One line of figures goes to the
standard error, and it keeps two figures apart: **the reach the compiler bound**, and the reach once the open nodes and their
callers widen it.

**Measured on a Foundry guard's unit** (2026-11-15, `af1_pack.haro`'s graph): a change to `FoundryField` reaches 22 nodes by
calls the compiler bound -- `FoundryPackBuild`, `FoundryPackInstall`, ... `<top>:af1_pack.haro` -- and 23,244 of 48,939 once
222 open nodes of the library and their callers widen it; all 23,244 are capped; the graph is not complete, so the 9 guards are
selected. About 30 s a change, most of it reading the 25.6 MB record. The open nodes are the library's: the reach a codebase's
own change has by its own calls is the first figure, and fewer calls by a name built at run time in stzlib is what narrows the
second.

**The core's walks are indexed** (`testoor_graph.zig`, `Index`, 2026-11-15): each id's edges in and out, in the edges' order, so
a reach follows the same edges in the same order as the scan it replaces, and every golden of protocols 2 and 3 is unchanged.
Before it, a reach over that unit was a scan of every edge per reached node, billions of comparisons.

### 6.8 Which functions a tour reached: `testoor probe`, and the side file

    testoor probe FOLDER [--haro PATH] [--out FILE.json]
    testoor walk FOLDER ... --graph FILE.json --ladder

The ladder's grade 1, **observed**, needs to know which functions a tour ran (section 2), and haro.exe counts no calls
(HARO-CALLCOUNT-01). `testoor probe` gives a COPY of a codebase that says so itself (`engine/src/testoor_probe.zig`):

- **A call before the first statement of each body**, on that statement's line: `\tTestoorProbeHit(4) nSec = Floor(nMs / 1000)`,
  each function and method numbered. haro graph names the definitions and their lines; the probe finds where each signature
  closes and the first line after it that is not blank or a comment. No line moves, so a claim, an error and a graph name the
  lines they named. The file gains one last line, `load "<path>/_testoor_probe.haro"`.
- **`_testoor_probe.haro`**, at the folder's root, holds `TestoorProbeHit`: on the first call of each function in a process, one
  line `[testoor node ID]` appended to the file the variable `TESTOOR_NODES` names; with no such variable, nothing. It sets
  itself up on its first call, so a file's own statements may run a function before the load at its end is reached.
- **Not probed, and named**: a function whose body begins on the line of its signature, one whose signature does not close,
  one whose body begins where another definition does. On haro.exe of 2026-11-14 a statement after a signature, on its line,
  made some functions a function of one line and their bodies the file's own statements; so the call never goes there.
- **The check**: haro graph is run again on each probed file; it must name the same definitions on the same lines, finish
  what it finished, and read a call to `TestoorProbeHit` in each probed definition. Else probe exits 2 and names the file.
- **A copy, never a repository**: a folder in a git work tree is refused, and so is one probed already.
- **The record** (`--out`): the graph record of what was probed, subject the folder, for `--graph`. Its nodes are the files'
  functions and methods, each with the file and line its own file gave; a file's own statements are no node of it, since
  the probe does not observe them. Its EDGES come from one reading of a unit that loads every file of the folder, made before
  any file changes: haro graph on one file alone prints no line for a call into another file (`FoundryField(...)` in
  `project.haro`, measured 2026-11-15), so a record of files read one by one missed every call between them, and read 19
  Foundry functions as open. An edge is kept when both its ends are the codebase's; `complete` and `why` are the unit's.

**The side file.** Every walk the core makes names a file of its own to the tour, by `TESTOOR_NODES`, and a child the tour
starts inherits it. A `[testoor node ID]` line written there is the tour's, as if printed (protocol 2 section 3); nothing else
in it is read, so no claim reaches the judge that way, and nothing of a probed codebase passes through the output a tour is
judged by. A walk that writes nothing leaves no file.

**`--graph FILE.json`** on `run` and `walk`: the run is judged against that graph record -- a node line names one of its nodes,
a node a tour calls by name (the Haro face's names) and never reached is `mentioned`, and the ladder's `owned` is the graph's
node count, `named` the nodes no tour reached.

**The probe's names are its own.** Its first name was `TestoorNodeHit`, which stzlib defines (its node counter,
`base/testoor/stzNodes.ring`): a guard loads the library first, haro.exe keeps a name's first definition, and the probed calls
went to the library's counter -- the Foundry's guards observed nothing in their own process. `TestoorProbeHit` and its
globals are named nowhere in stzlib; a codebase that defined one would shadow the probe the same way.

**Measured on the Foundry** (2026-11-15, a copy of stzfoundry 2917ebe; haro.exe of 2026-11-14):

- **the probe**: 8 files, 117 functions, every one probed and the check passed, in 57 s (81 s with other desks' builds
  running): haro graph reads `node.haro`, which loads the library, in 21.6 s and each other module in under 0.3 s, and the
  check reads them again.
- **the claims do not move**: the 9 guards walked on the probed copy and on the plain one give the same verdict on every
  claim, 243 kept and 1 diverged (`af6_page` runs a tool, `.zayn`, these copies lack: the same in both). 433 s probed and
  445 s plain, every image cold.
- **the ladder**, `--graph` the probe's record: 117 owned -- **114 exemplified, 2 observed, 1 named**. Each guard reached
  51 to 103 of them, its child programs included. `PageShort` and `PageBodyList` stand on grade 1, reached only by
  `af6_page`, which diverged. `FoundryHex2` (`project.haro` line 385) stands on grade 0: it is called only to write a
  control character other than a tab, a line feed or a carriage return into a JSON text, and no guard writes one.

### 6.9 The evidence report: `testoor report`

    testoor report LOGBOOK.json --graph GRAPH.json [--impact IMPACT.json ...] [--title T] [--stamp LINE ...] [--out FILE.md]

writes the evidence report (`engine/src/testoor_report.zig`) as one Markdown page a person reads, from a logbook that
`walk --ladder --graph` wrote, the graph it was judged against, and the impact records of the changes named. Its sections
are the parts of business lead offer 1 that are data (stz-business, `board/offers/testoor-evidence-report.md` section 5):

| section | what it holds |
|---|---|
| the stamp | the `--stamp` lines: the commit, the runtime, the judge -- the caller states them, the report holds for them |
| 1. the ladder | every function's grade, counted in all and file by file; a grade the ladder does not carry is not shown, `named` always |
| 2. what no tour ran | the functions at grade 0, each with the functions that call it |
| 3. run only by a tour that did not keep its claims | the functions at grade 1, each with the tours that ran it and their state |
| 4. the tours | each tour's state, its claims by state, and how many functions it ran |
| 5. what a change reaches | each impact record: the reach the compiler bound, the reach the open functions widen, the tours to walk again, and why every tour is walked again when the graph is not complete |
| 6. where the evidence is thinnest | the functions below exemplified, the most called first, five of them: where a check buys most |
| 7. what the report does not claim | seven lines, the same in every report |

The report adds no figure the logbook, the graph and the impact records do not hold, except counts of what they list.
Callers are DIRECT callers: a count of every function that depends on one at any depth is a walk of the graph per function,
and on a library-sized graph (48,939 nodes) that is not a report's cost. The reading for a person -- one page on what is
proven and what is not -- is the business desk's to shape (offer section 8); section 6 is the list it is read from.

**Measured on the Foundry** (2026-11-15, the same copy and runtime as 6.8): probe 101 s, the walk 351 s, two impact
records, and the report in 62 to 71 ms -- 79 lines. Its figures: 117 functions, 114 exemplified, 2 observed, 1
named; `FoundryHex2` the one no tour ran, called by `FoundryJson`; a change to `FoundryField` reaches 39 functions by calls
the compiler bound, and every guard is walked again because the unit's graph is not complete, which the report says with
its reason (the library's: 12 functions haro.exe could not finish, 185 functions calling a method by a name no method carries, 160
dispatching by a name built at run time). The same change read from one guard's unit reached 22, and from the files read one by one, 4:
the record's edges come from the whole folder's unit for that reason (6.8).

## 7. Conformance

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

| `haro/reader/R1_narrated` | the Haro face's reader (6.2): a claim before any scenario opens `(the tour)`; a claim in a comment, a claim built at run time and the bodies of the helpers `Scenario` and `Then` are not recorded, the built claim counted in `asserts`; claims inside the file's own function and inside an `if` are; a single-quoted claim is a literal |
| `haro/reader/R2_self_describing` | a `.haro` file with no `Scenario(` and no `Then(`: dialect `unknown`, no stop, judged from what it prints |
| `haro/judge/H3_a_slow_start_is_named` | 6.5: a tour whose first output arrived at 121.39 s: `first_output_ms` written after `wall_ms`, and its line naming the start -- written by hand; the core printed `121.30` where the hand wrote `121.3`, and both now print it as the wall time is printed, `121.39` |
| `haro/graph/G1_functions_methods_dispatch` | 6.6: functions, methods, a static call written in its node's spelling, two calls dispatched by name each to both methods named `Run`, an unfinished function open, a file's statements as a `top` node, a path's `.` and `..` resolved; read from lines alone, so not complete for that reason too |
| `haro/graph/G3_a_late_line_opens_its_caller` | 6.6: haro v0.77's `CALL|Go|*|late|2` opens `Go`, counted once, with no edge to `*`; its bound call to `Gross` stays an edge -- written by hand from the format in haro's spike/v77/GRAMMAR.md, before haro.exe prints it here |
| `haro/graph/G2_a_call_by_a_built_name_opens_its_function` | 6.6: the unit's file read: `call tName(nX)` opens `Dispatch`; the word in a string and a comment does not |
| `haro/impact/I1_names_select_a_tour` | 6.7: a complete graph, a change to `Vat`: the tour calling `Gross` is selected and the one calling `Label` skipped |
| `haro/impact/I2_an_open_node_selects_every_tour` | 6.7: the same change over G2's graph, `Dispatch` open: the reach widened by it, it caps itself, every tour selected |
| `haro/report/E1_a_small_codebase` | 6.9: five functions in two files, two tours, one change: every section of the report, the three functions below exemplified ranked by their callers -- written by hand before the module, and the module matched it on its first build |
| `haro/probe/P1_a_call_before_each_body` | 6.8: eight functions and methods each given a call before the first statement of its body, with no line moved, the probe file, nothing left unprobed, and the record of what was probed, which holds no node for the file's own statements -- written by hand; the module runs on haro.exe with the same output plain, probed, and probed with a side file, which then holds the eight |
| `haro/judge/H4_a_picture_report_is_not_a_verdict` | 6.2: a narrated Haro tour whose GIVEN line says a picture DOES NOT MATCH, its two THEN lines PASS: kept -- the picture rule had read the GIVEN line as a diverged claim |
| `haro/judge/H2_a_repeated_claim_is_a_second_check` | 6.4: an unknown-dialect tour printing `FAIL  x`, then `ok  x`, then another claim: three claims, the tour diverged -- protocol 2's landing read it as kept |
| `haro/judge/H1_a_report_line_is_not_a_verdict` | a narrated Haro tour whose program prints `  FAIL     :...` before its two `THEN` lines: 2 kept, finished, exit 0 -- under protocol 2's rule the report line was a diverged claim |

The same requests with the ladder NOT asked for write protocol 2 and no `ladder` key: the core guard and the native guard each
assert it. `testoor_property_narrated.haro` holds the Ring face to section 4: the domains through the seam, `TestoorProperty`
in-process (a failure shrunk to the same smallest input from two seeds), and two property tours walked as children.
`testoor_walk_narrated.haro` holds `testoor walk` to section 6 on haro.exe: five planted tours (kept, diverged, refused,
a runtime error, self-describing) judged from their folder, a `_` file and a non-matching name never walked.
