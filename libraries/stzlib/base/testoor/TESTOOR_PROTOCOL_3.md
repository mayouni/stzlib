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
| the **property record**: a property held over generated inputs from a declared domain, shrunk on failure | 3 | V2 | sketched, `TESTOOR_EVIDENCE_LADDER.md` 6(b) |
| the same record when every input or schedule inside a bound was tried | 4 | V3 | sketched, 6(b) |
| `min_grade` and `over` in the evidence floor | -- | V4 | sketched, 6(d) |
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

## 4. Conformance

Written by hand from section 2 before the code, and reproduced by the core on its first run (`zig build test-testoor`).

| case | what it pins down |
|---|---|
| `protocol2/judge/18_nodes_on_a_diverged_tour` | a tour that reached two nodes and diverged: both observed in its own record |
| `protocol2/judge/19_nodes_on_an_unjudged_tour` | a tour that reached a node and printed no verdict: the node observed, the planned claim unjudged |
| `protocol3/logbook/L9_ladder_graph` | cases 15, 16 (flaky), 18 and 19 against a complete graph of six: only the kept, finished, steady tour exemplifies; a node it shares with a flaky and a diverged tour lists it alone; a node only a mention reached (Rate, named by 15) takes its grade from the tour that observed it; one owned node stays named; `protocol` 3; exit 1 for the flaky and diverged tours, as without the ladder |
| `protocol3/logbook/L10_ladder_no_graph` | cases 15 and 16 with no graph: no `owned`, no `named`; a node two tours exemplified lists both, in run order; exit 0 |

The same requests with the ladder NOT asked for write protocol 2 and no `ladder` key: the core guard and the native guard each
assert it.
