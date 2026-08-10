# The World Contract

**Normative. Family-wide.** This is **C1** of the Softanza reference design: the
declared world every closed language references, as one language-neutral
artifact.

**Version**: **v1.0** · 2026-08-10
**Owner**: stzlib (stzGraph)
**Machine-readable shape**: [`world.schema.json`](world.schema.json) — that file
is what an emitter validates against; this one governs it.
**Read side**: [`read-side.md`](read-side.md).
**Pins**: the Diagnostic Contract (**C2**, StzZui) at **v1.0** — every refusal
below is one C2 envelope, and C1 borrows C2's `span` shape rather than
inventing a second one (§3.3).

---

## 1. Why one artifact

Every closed language in the family declares symbols and references them:
`app.zql` declares an entity, a `.zui` screen shows it, a `.face` binds a field
of it, a `.wflow` step passes it, a `.game` entity *is* it. Today each language
resolves references privately, and a reference that crosses a language is
unspecified — so nothing can check it, and every tool that wants the whole
picture reimplements half of it.

`world.json` is **one derived, language-neutral symbol artifact per project**.
Each court emits its own symbols; the union is the world. stzGraph loads it as a
knowledge graph, which is what makes the read side (§5 of the reference design,
and [`read-side.md`](read-side.md)) the same engine as the symbol table.

**Derived, never authored.** No human writes `world.json`. It is a build output
of the courts, regenerated from the declarations, and a stale one is a build
error rather than a source of truth.

## 2. The shape — two flat tables

```json
{
  "world":    "tontine",
  "contract": "1.0",
  "symbols": [
    { "kind": "entity", "name": "deposit",
      "span": { "file": "app.zql", "line": 6 },
      "rationale": "One member's contribution to one round of the circle" },

    { "kind": "field", "name": "deposit.amount", "type": "currency",
      "span": { "file": "app.zql", "line": 9 } }
  ],
  "refs": [
    { "from": "entity:deposit", "to": "field:deposit.amount",
      "kind": "declares", "span": { "file": "app.zql", "line": 9 } },

    { "from": "field:deposit.amount", "to": "type:currency",
      "kind": "has_type", "span": { "file": "app.zql", "line": 9 } }
  ]
}
```

**Two tables, both flat**, and the reason is not aesthetic:

- The reference design's sketch says *rows* — symbol kind, name, type, declaring
  artifact + span, references out. Rows is what this is.
- A nodes table plus an edges table is exactly the shape a graph loads.
- Multiplicity has somewhere to live. Two flow steps enforcing the same norm are
  **two rows** in `refs`, with different spans — which matters, because
  stzGraph collapses them to one edge (§4.1) and the rows are where the detail
  survives.
- Flatness is a hedge on the reader. The engine's JSON bridge today reads scalar
  keys off a root object and cannot descend (§6.3); an array of flat objects is
  one engine function away from being engine-readable, where a deeply nested
  document would be a redesign.

## 3. The fields

### 3.1 `symbols[]`

| Field | Required | Meaning |
|---|---|---|
| `kind` | yes | one of the closed set in §3.4 |
| `name` | yes | the symbol's name in its declaring language |
| `type` | no | the declared type, where the kind has one (a `field`'s type; a `flow`'s return). `null` otherwise |
| `span` | yes | where it is declared — C2's span (§3.3) |
| `rationale` | no | the declaration's own `RATIONALE`, carried verbatim |

**The id is `kind:name`** — derived, never stored. `entity:deposit`,
`field:deposit.amount`, `norm:positive_deposit`.

That form is **not invented here**. C2 already ships it, in force and
schema-validated: a cite is `kind:value` with a stable identifier
(`rule:79`, `article:reversibility`). The family had the shape; C1 reuses it, so
a programmer who has read one refusal can read a symbol reference.

**Names are matched case-insensitively.** Two symbols of the same kind whose
names differ only by case are a **collision and a refusal**, not a merge. This
is not a preference: stzGraph normalises node ids to lower case (§4.2), so
without the rule the second symbol would silently overwrite the first. A
diagnosed refusal beats a corrupted graph.

A name may not contain a space or a newline (stzGraph's `_IsWellFormedId`).
Dots are allowed and are how a field is qualified — `deposit.amount` — which is
also the path form `.face` files already write (`cout.variation_sens`).

### 3.2 `refs[]`

| Field | Required | Meaning |
|---|---|---|
| `from` | yes | a symbol id — the referring symbol |
| `to` | yes | a symbol id — the referenced symbol |
| `kind` | yes | one of the closed set in §3.5 |
| `span` | yes | where **the reference** appears, not where either symbol is declared |

`span` on a ref is the reference *site*. That is the whole reason refs is a
table: the same pair referenced from three places is three rows, and a
diagnostic about the third one can point at it.

**Every `from` and `to` must resolve to a row in `symbols[]`.** A dangling
reference is a refusal (§6.1) — the gap Ringuist's exemplar study names **G6**,
where a flow enforcing a non-existent norm raises in one runtime and is silently
skipped in another because no fixture ever covered it. C1 closes it at birth.

### 3.3 `span` — C2's, not a second one

```json
{ "file": "app.zql", "line": 9, "col": 3 }
```

`file` required; `line` locates when ≥ 1 and **`line: 0` means file-wide**;
`col` optional and ≥ 1 when known. This is C2's span verbatim, including the
`line: 0` convention.

**This merges two of the reference design's sketch rows.** The sketch lists
"declaring artifact **+** span" as separate columns; C2 had already fused them —
its `span.file` *is* the declaring artifact. Carrying both would give the family
two spellings of one fact and let them disagree. Recorded as a divergence in
§7.

### 3.4 `kind` — the symbol kinds, closed

`entity` · `field` · `type` · `actor` · `norm` · `flow` · `screen` ·
`process` · `element` · `state`

The first eight are the reference design's. **`element` and `state` are added**,
and not speculatively: StzZui's `zui` verifier ships today with
`--symbols FILE`, and its Level-3 checks read exactly four arrays —
`entities`, `actors`, `state`, `elements`. A world artifact that cannot feed the
one shipped consumer of a symbol table would be a contract about nothing.
Recorded as a divergence in §7.

### 3.5 `kind` — the reference kinds, closed

| Kind | Means | Attested in |
|---|---|---|
| `declares` | A introduces B as part of itself | `DEFINE ENTITY deposit ( amount: currency )` |
| `has_type` | A's declared type is B | the same line, field → type |
| `enforces` | A is judged against the rule B | ZQL `ENFORCING` |
| `routes_to` | A hands control to B | ZQL `LANDING_ZONE ... INTO` |
| `performed_by` | A is carried out by the actor B | ZQL `ACTOR` |
| `calls` | A invokes B | `.face` `ACTION go ... CALLS suggestion.flow` |
| `shows` | A surfaces B to a person | `.zui` `VISIBLE_ENTITIES`, `VISIBLE_STATE` |
| `binds` | A **is** B — the same thing in two languages | `.game` `BINDS entity:member` |
| `references` | A's declaration depends on B, relation unstated | the honest floor |

`references` is the weakest **true** statement, not an escape hatch: it makes no
claim it cannot support. A court must emit the most specific kind it can prove,
and `references` only when it genuinely cannot name the relation. A court that
emits nothing but `references` has not been written yet.

`binds` is the one worth pausing on. It asserts **identity across languages** —
a game entity that *is* a declared business entity, a screen element that *is*
the field. It is what makes a world one world rather than several that resemble
each other.

## 4. Loading it — what stzGraph can and cannot carry

The loader is [`libraries/stzlib/base/graph/stzWorldGraph.ring`](../libraries/stzlib/base/graph/stzWorldGraph.ring).
A symbol becomes a node, a reference becomes an edge. Two properties of
stzGraph shape that mapping and both are recorded rather than worked around
silently.

### 4.1 stzGraph is a SIMPLE graph — one edge per node pair

`AddEdge` raises on a second arrow between the same pair, and `stzGraph.ring`
states this is deliberate: *"a workflow or a knowledge graph that wants two
distinct relations between the same two nodes needs a different model, not a
silently doubled edge."*

A world hits this immediately and unavoidably, and the guard exercises the exact
case: `flow:accept_deposit` enforces `norm:positive_deposit` at **step 2 and
again at step 4** — two `enforces` rows between the same pair, on lines 31 and
35. Nothing about that is contrived; a flow that checks a rule twice is
ordinary.

**The resolution: `refs` rows are grouped by (from, to) and become ONE edge**
whose label is the first row's kind and whose `:refs` property carries every
row, kind and span intact.

Nothing is lost, because the two artifacts have different jobs: **`world.json`
is the truth and the graph is an index over it.** The graph answers reachability
— what does this reach, who reaches this, is there a cycle — and reachability is
a property of the pair, not of the multiplicity. Detail is read from the rows.

No change to stzGraph is proposed. Multi-edge support would be a substantial
change to a class 7,100 lines long with many consumers, to buy something the
index does not need.

### 4.2 stzGraph normalises node ids to lower case

`AddEdgeXTT` lower-cases both endpoints and `Node()` looks up lower-cased. Two
symbols differing only by case would therefore collide silently. §3.1 turns that
into a refusal at load, which is the only place it can be seen.

### 4.3 What the loader is not

A loader, not a framework. It reads, refuses, and hands back an `stzGraph`.
It does not emit `world.json` — emitting is each court's job, in each court's
repository — it does not cache, it does not watch files, and it does not query:
querying is `stzGraphQuery`'s, which already exists.

## 5. The one shipped consumer, satisfied

StzZui's verifier takes `--symbols FILE` shaped
`{"entities": […], "actors": […], "state": […], "elements": […]}` — four flat
arrays of names — and **skips its Level-3 checks without it**, because
*"undecidable is silence, never a pass."*

The projection is a filter and a map, and the loader exposes it directly:

```ring
oW = StzWorldGraphQ("build/world.json")
? oW.NamesOfKind(:entity)        # deposit, member, player
? oW.ZuiSymbolTable()            # [ :entities = [...], :actors = [...],
                                 #   :state = [...], :elements = [...] ]
```

The projection carries **names, not ids** — the verifier compares against
`VISIBLE_ENTITIES` items, so an id would never match. The guard asserts both
halves of that: `deposit` is present and `entity:deposit` is not.

Two other consumers were read while designing this and are satisfied by the
same two tables — Zing's `app.zql` (entity/field/type/norm/flow/actor, with
`ENFORCING` and `INTO` as refs) and RingFace's `.face` (`ZUI` naming
declarations, `CALLS` naming a flow, dotted field paths, which is why a `field`
name is qualified).

## 6. Refusals

Every refusal is one **C2 v1.0** envelope with `language: "world"`.

```json
{
  "code": "DANGLING_REFERENCE",
  "severity": "error",
  "message": "flow:accept_deposit enforces norm:postive_deposit, which nothing declares. Did you mean norm:positive_deposit?",
  "span": { "file": "app.zql", "line": 31 },
  "cites": [],
  "language": "world"
}
```

| Code | Severity | When |
|---|---|---|
| `DUPLICATE_SYMBOL` | error | two symbols share a kind and a name (case-insensitively) |
| `DANGLING_REFERENCE` | error | a ref's `from` or `to` names no declared symbol |
| `UNKNOWN_SYMBOL_KIND` | error | a `kind` outside §3.4 |
| `UNKNOWN_REFERENCE_KIND` | error | a ref `kind` outside §3.5 |
| `MALFORMED_NAME` | error | a name carrying a space or a newline |
| `CONTRACT_MISMATCH` | error | the `contract` field names a version this loader does not implement |
| `MISSING_SPAN` | warning | a row without a `span.file`; loadable, but nothing can point at it |

`cites` is `[]` for all of them, which C2 explicitly allows: *"Empty is honest
where no law applies."* These are structural findings, not enforcement of a
pinned instrument.

**A world that refuses still loads what it can.** The loader collects every
diagnostic rather than raising on the first — a build wants the whole list, and
`IsLawful()` is the gate.

## 7. Divergences from the reference design's sketch

Per the reference design's own rule that the owner wins and the reference
follows, two changes, both driven by something readable:

1. **"declaring artifact + span" became one field.** C2's `span` already carries
   `file`, and two spellings of one fact drift. §3.3.
2. **Two symbol kinds added — `element` and `state`.** The only shipped consumer
   of a symbol table in the family reads four arrays and two of them are these.
   §3.4.

Neither changes what the sketch was for. Both should be carried back to
`REFERENCE_DESIGN.md` in its own session.

## 8. Governance

Governed as C2 is, and for the same reason — a contract many repositories pin
must move visibly:

- **A version denotes one pair of files**: this document and
  `world.schema.json`, which move together.
- **`MAJOR.MINOR` moves when substance moves**: a field added to or removed from
  §3.1/§3.2, a kind added to or removed from §3.4/§3.5, the id form changed, the
  case rule relaxed.
- **`MAJOR.MINOR.PATCH` marks a correction that changes no requirement.**
- **The substance test**: *does any `world.json` that validated before stop
  validating — or must any emitting court change what it emits?* If no, it is a
  correction, however much prose moved.
- **Consumers pin**, and move by their own decision.
- **Amendment by evidence.** A court that needs a kind submits the reference it
  cannot express. A kind added because it might be useful is refused.

## 9. Honest boundaries

- **No court emits `world.json` today.** This contract defines the artifact and
  ships a reader; the writers are Zing's, StzZui's, RingFlex's and RingFace's
  work, in their repositories.
- **The loader is registered nowhere.** `stzWorldGraph.ring` is not added to
  `stzBase.ring` — this session created no file it did not own — so it is loaded
  explicitly today. A one-line registration is the author's call.
- **The engine cannot read this yet.** The house rule is engine-first, and the
  JSON bridge is flat: `stz_json_get_string` reads scalar keys off a root object
  and there is no way to descend into an array of objects. The Ring reader
  (`JsonToList`) is used, and §2 kept the artifact flat so that one engine
  function — array-element-as-handle — closes the gap without touching the
  schema. Recorded as a gap against the engine, not designed around.
- **`element` and `state` are underspecified** compared to the other eight. They
  entered from one consumer's needs, and what exactly a `state` symbol *is*
  across languages will sharpen when a second consumer wants one.
- **Proven small, unmeasured large.** The guard
  ([`libraries/stzlib/base/test/world/world_contract_narrated.ring`](../libraries/stzlib/base/test/world/world_contract_narrated.ring))
  loads a 13-symbol, 11-reference world across three artifacts and asserts every
  refusal with a sibling that must not fire. No world of real size has been
  loaded; `_IndexOfSymbol` is a linear scan, so the loader is O(S·R) and will
  need an index long before ten thousand symbols. Named, not designed around —
  the shape to fix is known (`stzKnowledgeGraph` and `stzGraph` both grew engine
  hash indexes for exactly this).
