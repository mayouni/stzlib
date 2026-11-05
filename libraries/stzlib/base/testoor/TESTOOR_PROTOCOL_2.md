# Testoor protocol, version 2 -- DRAFT

*Draft d1, 2026-11-04. Phase P2c of `SOFTANZA_TESTOOR_ROADMAP.md`. Not accepted: the author reads it
before any Zig is written (the P2 exit). It adds to `TESTOOR_PROTOCOL.md` (version 1.1) and replaces
nothing in it. No sentence depends on the language a tour is written in.*

## 0. The one rule that keeps version 1 alive

**A version 2 key or line appears only when it has something to say.** A run with no graph, no
evidence floor and no refinement writes the same bytes version 1 wrote, so the fourteen golden
judge cases and five golden logbooks (`golden/`) stay the acceptance test of the core, unchanged,
through the whole of version 2.

- A tour written for version 1 is a version 2 tour. Nothing it prints changes meaning.
- A reader ignores a line or a key it does not know. That is how a version 1 reader survives a
  version 2 tour, and how a version 2 reader survives one that is newer still.
- The logbook carries `"protocol":2` **only when it carries a version 2 key**, and nothing else
  marks the difference. No `"protocol":1` is ever written; its absence is version 1.

## 1. What version 2 adds, in one table

| addition | where | why it exists |
|---|---|---|
| the **graph record** | a fourth contract, a JSON document | the program hands Testoor its own code graph, so Testoor stops guessing the program from its tests (ruling 16) |
| `[testoor node ID]` | a child's output line | a tour (or a trace hook) reports a graph node it reached |
| the **nodes record** | the logbook, per tour and per run | graph coverage as counts, never a percentage |
| the **impact record** | its own JSON document, now formal | which tours a change obliges you to walk again |
| the **evidence record** | the logbook, per gate | how much walking a change needed before it was accepted (the evidence floor) |
| `refinements` | the logbook, per run | which refinement points the walked subject was built from |

## 2. The graph record

The graph record is what a **program** (or its face) says about itself. It is a JSON document, read
from a file or a pipe, and it names no language.

```json
{"testoor":"graph","protocol":2,"subject":"tax/stzTax.ring","language":"ring","fold":"ascii",
 "complete":true,"why":"",
 "nodes":[{"id":"stzTax.Total","kind":"method","file":"tax/stzTax.ring","line":12,
           "implements":["TAX-01"],"open":false}],
 "edges":[{"from":"stzTax.Total","to":"stzMoney.Add","kind":"call","line":15}]}
```

| field | rule |
|---|---|
| `id` | a string with **no whitespace**, stable between runs of the same source; the unit every join uses |
| `name` | optional (P3.3): the identifier a tour mentions the node by, which is what the tour's *names* are compared with. The id when absent |
| `kind` | `class`, `method`, `function`, `point` (a refinement point), `file`. A reader ignores a kind it does not know |
| `fold` | how two ids are compared: `"none"` (exact bytes) or `"ascii"` (A to Z folded to a to z, **nothing else**). Ring is case-insensitive and says `ascii`; a case-sensitive language says `none` |
| `implements` | plan-item ids (routes) this node carries out; the join that turns a route into a node |
| `open` | true on a node that dispatches by a name built at run time (`eval`, `call`, reflection). Its outgoing edges are **not all known** |
| `complete` | false when any node is `open` or the reader gave up. `why` then names the first cause and its line |
| edge `kind` | `call`, `new`, `inherits`. A reader ignores a kind it does not know |

**Completeness is the load-bearing field.** A graph that is not complete may never be used to leave
a tour out: selection then walks **every** tour and says so (ruling 16, measured in P1a: a selection
is only as small as the graph is complete). Over-approximation is allowed and costs time only; an
edge the graph cannot see would cost a verdict, and `open` is how it admits that.

**Id spelling.** `Class.Method` for a method, the bare name for a function, `Class` for a class,
`Class#knob` for a refinement point. A language that cannot follow this declares its own and joins
by `fold`; the core never parses an id, it only compares two.

## 3. The child's line: `[testoor node ID]`

| line | meaning |
|---|---|
| `[testoor node ID]` | the tour (or a trace hook acting for it) reached node `ID` at least once |
| `[testoor node ID N]` | the same, with a hit count `N` (a non-negative integer, the last token); the counts of a repeated line add |

Version 1 had `[testoor route ID]` for a **plan item**. A route is a promise; a node is a place in
the program. The two never share a spelling and are never summed.

**How a node line is counted (P3.3, pinned by golden `16`).** `[testoor node ID]` is one hit and `[testoor node ID N]` is
N. A line whose count is not a non-negative integer (`x`, `-1`, `1.5`, more than fifteen digits), or that has more than an
id and a count, or no id, is **ignored** and stays ordinary output. A line that reports zero hits proves nothing: a node
is *observed* only when its hits are above zero. With a graph, ids are compared under the graph's `fold`, the node is
listed under the graph's own spelling, and an id the graph does not own is dropped; with no graph the ids are listed as
the tour spelled them, first seen first.

**Who writes the lines (P3.4).** A tour may print them itself, or count with the engine's node counters
(`TestoorNodeSlot` once, `TestoorNodeHit` per event, 0.19 us through Ring++) and print them with `TestoorNodesReport()` at its
end. A counter writes `[testoor node ID N]` with the count always present, an id only if a node line could carry it (no space,
no control byte) and a count saturated at fifteen digits, so every line it writes reads back.

## 4. The nodes record in the logbook

Per tour, when the tour reported or was found to name any node:

```json
"nodes":[{"id":"stzTax.Total","evidence":"observed","hits":3},
         {"id":"stzTax.Rate","evidence":"named","hits":0}]
```

Per run, beside `claims`:

```json
"graph":{"complete":true,"owned":14,"named":9,"observed":6}
```

Two kinds of evidence, and the difference is the point:

- **named**: the tour's source mentions the node's name. Read before the tour runs, it costs nothing,
  and it is a proxy. A tour can name a function it never calls.
- **observed**: the node was reached while the tour ran (a `[testoor node ID]` line). It is the only
  evidence that the node did anything.

**`owned`, `named` and `observed` are three figures, never summed and never turned into a percentage.**
A node observed is not a route walked: route coverage (section 8 of version 1) stays its own pair of
counts. Where a graph is not `complete`, the run says so beside the figures (`"complete":false`), and
the figures are lower bounds on what is reached.

**Decisions P3.3 took where this draft was silent** (each pinned by a golden under `golden/protocol2/`):

- a node is listed under the **stronger** of its two evidences, `observed` before `named`, and a node with neither is not
  listed; rows follow the **graph's order**, so a log reads the same whatever order a tour reached its nodes in
- the run's `named` counts nodes that were named and **never observed**, and `observed` counts nodes observed by any
  tour; a node is in at most one of them, because the per-tour record keeps one evidence per node
- the run's `graph` object is `{"complete",["why",]"owned","named","observed"}`: `why` appears only when the graph is
  not complete, and `owned` is the size of the graph the runner was given
- `"protocol":2` is written right after `"kind":"run"` **only when the run holds a version 2 key**: a `graph` object or
  a tour with `nodes`. The tour's `nodes` key comes last, after `routes`, and only when the tour has any
- the terminal summary gains `graph: N owned, M named, K observed (three figures, never summed)` after the claims line,
  and `graph incomplete: <why>; a selection from it takes every tour` when the graph is not complete. A tour's own line
  is unchanged
- a graph record whose `complete` is false, or that holds an `open` node, is not complete; with no `why` given the first
  open node names the cause: `node ID dispatches by a name built at run time (line N)`
- `names` of the impact record are the reached nodes' `name`s (their ids when they have none), lower-cased under an
  `ascii` fold, each once, in the order the reach found them

## 5. The impact record

The impact record was a Ring convenience in version 1.1; it is now a contract, because an agent in
a loop reads it. One JSON document, produced by `--impacted-by` and returned before anything runs:

```json
{"testoor":"logbook","kind":"impact","protocol":2,"subject":"tax/stzTax.ring",
 "changed":["stzTax.Total"],"method":"stzTax.Total",
 "complete":true,"why":"","names":["total","net","invoice"],
 "selected":["tax/tax_totals.ring"],"skipped":["tax/tax_rates.ring"]}
```

- `changed` is the list of node ids a change touched (from a diff, method by method). `method` is
  kept for version 1 readers and holds the first of them.
- `names` is the closure of callers of `changed` over the graph's edges, the **reach**.
- `selected` and `skipped` partition the tours. When `complete` is false, `skipped` is empty and `why`
  says so.
- Selection costs a verdict only through an edge the graph cannot see, never through a name it
  over-matches. The recall of `selected` on a planted subject was measured at 100 percent in P1a; on
  the real library it is still to measure (P4), and the record does not claim it.

## 6. The evidence record: the floor

A gate (a refinement step, a commit hook, an agent's patch) can demand a **floor** of evidence
before it accepts a change. The record states what the floor was and whether the walk met it. The
policy that picks a floor is *not* in the protocol (it is data the library holds); only the record is.

```json
"evidence":{"posture":"llm","tier":"critical",
            "floor":{"min_kept":3,"allow_unjudged":false,"min_routes":1},
            "kept":4,"diverged":0,"unjudged":0,"routes_walked":2,
            "met":true,"why":""}
```

| field | rule |
|---|---|
| `posture` | who proposed the change: `human`, `llm`, `trusted` or a name the library defines |
| `tier` | the risk of the thing changed: `low`, `normal`, `critical` or a name the library defines |
| `floor` | the minimum, as numbers and one boolean; a field the floor does not set is omitted |
| the five counts | read from the walk, so the record can be checked against the logbook beside it |
| `met`, `why` | the verdict of the comparison, and the first reason it failed |

`met` is computed by the core from the counts and the floor, nothing else. **Unjudged never raises
`kept`**; a floor that allows it says `allow_unjudged` out loud. A gate that finds `met` false refuses,
and a refused change rolls back. The core holds no opinion on what a floor ought to be.

## 7. `refinements`

When the subject walked is a refined copy, the run says what it was refined from:

```json
"refinements":[{"point":"stzTax#Rate","value":"0.20","by":"llm","bound":"0..0.25"}]
```

A point is named as in section 2. `value` is a string whatever the point's type. `bound` is the point's
declared range, copied so a reader sees that a value admitted by the bound can still be refused by a
tour. Together with `subject` and `seed`, this is enough to **replay** the walk.

## 8. Replay

A logbook is a recipe: its `subject`, `seed`, `weather` and `refinements` are exactly what a run needs
to be repeated. Version 2 states the rule the core relies on: **a run given the same subject bytes,
seed, weather and refinements judges the same way**, and a tour for which it does not is `flaky` by
definition. The logbook holds no wall clock in any field a replay must match except the `wall_ms`
fields, which are measurements and are excluded from a comparison.

## 9. What does not change

Exit codes (0, 1, 2) and their meaning. The five stop states. The six endings. The three version 1
contracts. A graph that is not complete is **reported, not failed**: the run exits 0 if its tours are
kept. Unjudged is still reported and not counted against.

## 10. Conformance, to be written with the Zig core

The golden set grows, each case added before the code that satisfies it, in the way the first
fourteen were:

| case | pins down |
|---|---|
| `15_nodes_named_observed` | a tour that names a node it never reaches, and one it reaches three times |
| `16_node_line_count` | `[testoor node ID N]` adds, and a malformed count is ignored with the line kept as output |
| logbook `L6_graph_incomplete` | an open node: selection takes every tour, the run still exits 0 |
| logbook `L7_floor_met`, `L8_floor_refused` | the evidence record, met and not met, and the exit it gives a gate |
| `impact/01..03` | the impact record for a complete graph, an open graph, and a change touching two nodes |

**Status, 2026-11-06 (P3.3):** `15`, `16`, `L6` and `impact/01..03` are written, under `golden/protocol2/`, and the Zig
core reproduces every one byte for byte. Their expected files were written **by hand from this document, before any
code**, because the Ring reference cannot judge version 2 and there is no oracle to regenerate them from. `L7` and `L8`
(the evidence floor) are not built.

## 11. Questions for the author

Answers are recommended; none is taken for the author.

1. **Who writes the graph record?** *Recommended:* the face, from the program's own graph where there
   is one (`stzCodeGraph` for Ring; the parsed program for Haro), and the core never reads source.
2. **May observed node evidence ever count toward a route?** *Recommended: no.* A route is a promise
   a tour keeps by saying so; a node touched is not a promise kept.
3. **Is `fold:"ascii"` enough for Haro?** *Recommended:* yes until Haro's identifier rules are
   written; the value is data, so a third fold can be added without changing a byte of the core.
4. **Should the floor's policy ship in the library or stay a user's data?** *Recommended:* the library
   ships three defaults (one per posture) as refinement points, so the floor is itself refinable, and
   the core only compares.

Draft d1, 2026-11-04.
