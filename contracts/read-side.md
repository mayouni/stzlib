# The Read Side — ledger → graph → questions

**Companion to** [`world-contract.md`](world-contract.md) (C1, v1.0).
**Status**: doctrine, owned by stzlib. One page, on purpose.
**Source**: §5 of the Softanza reference design, adopted here as this
repository's own so that the read side is not reinvented in four places.

---

## The two sides

```
WRITE     closed grammar  →  court  →  ledger
READ      ledger  →  graph  →  questions
```

The write side is settled family-wide: a closed language, a court that judges
it, fixtures that gate it, consumers that pin it. It is the family's signature
move and it is not what this page is about.

**The read side is the other half, and it has one shape.** Committed records
feed a graph; questions are semantic queries over that graph; the human face is
a domain expert conversing with the declared world in their own vocabulary.

## Why the symbol table and the read side are one engine

C1's world artifact *is* a graph of the declared world: symbols are nodes,
references are edges. The read side's questions — *what does this flow touch,
who can see this field, what breaks if this entity changes* — are reachability
questions over that same graph.

So stzGraph carries two duties with one engine, and that is a saving rather
than a coincidence: a symbol table that could not be queried would need a query
layer built beside it, and a query layer that did not know the symbols would
need its own copy of them.

- **The symbol side**: [`stzWorldGraph`](../libraries/stzlib/base/graph/stzWorldGraph.ring)
  loads `world.json` and hands back an ordinary `stzGraph`.
- **The query side**: `stzGraphQuery` already exists — `Match` · `Where` ·
  `Select` · `OrderBy` · `Limit` · `Execute`. Nothing new is needed and nothing
  new should be built.
- **The knowledge side**: `stzKnowledgeGraph` adds facts, laws (`:Unique`,
  `:Symmetric`, `:Transitive`) and `Prove()`, which returns a *structured,
  replayable derivation* rather than a yes. When the read side has to explain
  itself, that is the surface.

## One door, three consumers

The reference design names them and this repository builds no fourth:

1. **A human REPL or notebook** — the domain expert asking the declared world
   questions.
2. **The agent surface** — the same queries, reached over MCP, read-only.
3. **Page dashboards** — the same queries, rendered.

They differ in presentation, never in engine. A consumer that needs a query the
graph cannot answer is evidence for growing the graph, and never a licence to
grow a second one.

## What growing the read side means

**Growing the read side means growing the graph** — more symbols, more
reference kinds, richer laws — and never growing a query language toward SQL.

This is the same restraint the reference design places on ZQL's `SELECT`, which
is a deliberate seed and does not grow. It is worth stating twice because the
pressure arrives from the opposite direction each time: on the write side
someone wants to compute in a declaration; on the read side someone wants a
`JOIN`. The answer is the same in both directions — the expressive thing already
exists one layer down, and reaching for it is not the same as reimplementing it
in the declaration.

## What the read side must never become

- **Not a mutable runtime store.** The world artifact is *derived* — regenerated
  from declarations by the courts. A read side that accepts writes has quietly
  become a second source of truth, and the first thing it will do is disagree
  with the first one. (Ringuist's mission states the same rule for its knowledge
  tier: the graph ships versioned with the language, full stop.)
- **Not a court.** The graph answers questions; it does not judge. A verdict
  comes from a court reading a pinned instrument and speaking C2. The read side
  can *feed* a court — that is exactly what C1 does for StzZui's Level-3 checks —
  but a query result is not a finding.
- **Not a second symbol table.** If a tool needs symbols, it reads `world.json`.
  A tool that computes its own has forked the world, and the fork will be found
  when the two disagree in production.

## Honest boundaries

- **No court emits `world.json` yet**, so the read side currently has nothing
  real to read. The loader and this doctrine exist so that when the first
  emitter lands, the read side is not designed in a hurry beside it.
- **`stzGraphQuery` has not been exercised over a world graph.** It is the named
  query surface because it is the one that exists, not because it has been
  proven against this workload.
- **The conversational face is a separate question**, sketched in the reference
  design's §5 and owned there. This page names it as the third consumer and
  stops.
