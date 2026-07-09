# stzApp — Deepening: Body (Embodiment)

> Companion to [STZAPP_DESIGN.md](STZAPP_DESIGN.md). Deepens the third constitutive aspect —
> **Body**: the matter in which a world's being and becoming are inscribed and **endure**.
> Grounded in `stzGraph`'s real persistence (`.stzgraf` / `.stzrulz`, JSON/YAML/GraphML) and
> `stzGraphView` — Body is composition, not a new datastore.

---

## 1. Why a world needs a body

Domain + Life are the world's **form** — its meaning. But form alone is ephemeral: it exists only
while a program runs, then vanishes. The **Body is the world's matter** — where its form is
written down so it can *persist across time*, be *queried*, and *travel*. Softanza's method says
this must be **declared, not hidden**: a world names its own body (*make the invisible visible*),
rather than inheriting an opaque storage backend.

```ring
oApp { LivesIn(:GraphDB) }              # or :Files · or [ :GraphDB, :Files ] · default :Memory
```

Body answers *where the world resides* — which is **not** where it *appears* (that is Reach). One
Body; possibly many surfaces read from it.

---

## 2. The world's substance is its graph — and the graph already persists

A world *is* a graph (`stzGraph`); so the world's substance persists exactly as a graph does — and
`stzGraph` ships this already, in **native Softanza formats** plus interchange:

| Body concern | `stzGraph` method | Form on disk |
|---|---|---|
| the world's structure (being + becoming) | `SaveToStzGraf` / `LoadFromStzGraf` | **`.stzgraf`** — native node/edge substance |
| the world's truths & rules | `SaveToStzRulz` / `LoadFromStzRulz` | **`.stzrulz`** — native rules |
| portable interchange | `ExportToJSON` / `ExportToYAML` / `ExportToGraphML` / `ExportToDOT` | `.json` · `.yaml` · `.graphml` · `.dot` |
| whole-world round-trip | `SaveTo(path)` / `LoadFrom(path)` | a world folder |

So `LivesIn(:GraphDB)` is not a promise to bolt on a database — it is the world persisted as its
own graph substance (`.stzgraf` + `.stzrulz`), **queryable** (via `stzGraphQuery`) and **stable**
(node ids survive). The "graph database" is the world remembering itself in its native form.

---

## 3. Two faces of one body (graph substance ⟷ readable files)

A `LivesIn([ :GraphDB, :Files ])` **dual body** keeps two coordinated faces:

- **The graph face** — the living substance: the whole world as nodes/edges (`.stzgraf`),
  queryable and complete. This is the *system of record* — where the world's state truly lives.
- **The file face** — a human-readable projection so building the world feels usual:

```
myapp/
  world.stz                      # the world (being · becoming · body)
  things/   clients.stz  accounts.stz  visits.stz     # Domain, projected
  life/     flows.stz  reactions.stz  goals.stz       # Life, projected
  assets/   …                    # your own files, untouched
  .stzapp/  world.stzgraf  truths.stzrulz             # the graph face (system of record)
```

The projection is not a copy job — it is a **view with transactional consistency**, which
`stzGraphView` already provides: `stzGraphView from stzGraph` *is* a graph, with `Commit()`,
`Rollback()`, and `Changes()`. So:

- **edit a file → import → the graph updates** (a change staged, then `Commit`);
- **the world moves → export → the files reproject** (the graph is the source; files follow);
- a failed or half-applied change **`Rollback`s** — the two faces never drift out of sync.

*(The general graph⟷source projection is the planned `stzGraphCode`; today `stzGraphView` +
the export/import methods already carry the mechanism.)*

---

## 4. What `LivesIn` guarantees

Declaring a Body is a contract:

- **Endurance** — the world survives beyond a run; `Live()` on next launch resumes the same world
  (`LoadFromStzGraf`).
- **Identity** — nodes keep stable ids across saves/loads, so annotations, goals, and history stay
  attached to the right things.
- **Consistency** — dual-body reprojection is atomic (`Commit`/`Rollback`); the file face and the
  graph face are always the same world.
- **Queryability** — the body is not dead storage; the resident graph answers `stzGraphQuery`
  (this is also what makes goal `Satisfied()`/`Gap()` checks cheap — they query the body directly).
- **Portability** — the body travels with the app: *`.stzgraf` + `.stzrulz` + the Ring runtime +
  the stz engine* is the whole, self-contained, movable world. No external database required.

Default `:Memory` keeps the contract's *shape* minus endurance: the world lives fully, but forgets
at exit — right for a scratch world, a test, or an embedded one-shot.

---

## 5. Body is not Reach (resides vs appears)

| | **Body** | **Reach** |
|---|---|---|
| question | where does the world *reside*? | where does the world *appear*? |
| cardinality | one substance (possibly dual-faced) | many surfaces |
| realized by | `.stzgraf`/`.stzrulz` + `stzGraphView` (Commit/Rollback) | per-surface `stzGraphView` **projections** rendered as intent |
| moves with the app? | yes — it *is* the app's state | no — it's a manifestation |

A surface (mobile, web) is a **projection of the Body** for a participant — a `stzGraphView` of the
resident graph, rendered through Intent. That is why one Body can feed many surfaces without
duplication: each surface is a *view*, the Body is the *world*.

---

## 6. The idiom, complete

```ring
oApp {
    # … domain, life …
    LivesIn([ :GraphDB, :Files ]) {
        Graph = ".stzapp/world.stzgraf"      # the substance (system of record)
        Files = "./"                          # the readable face (things/, life/, …)
        Keep  = :everything                   # or :state-only — what endures vs. what's derived
    }
}

oApp.Body().Save()            # SaveToStzGraf + SaveToStzRulz, files reprojected
oApp.Body().Reproject()       # rebuild the file face from the graph
oApp.Body().Import(:files)    # fold edited files back into the graph (staged → Commit)
oApp.Explain(:body)           # show where the world lives and what endures
```

---

## 7. What this buys the construct

- **A world that remembers itself** — persistence is native (`.stzgraf`/`.stzrulz`), not a bolted-on
  ORM; the body *is* the graph.
- **Friendly on the outside, powerful within** — programmers edit ordinary files; the world keeps a
  queryable, transactional graph underneath, always in sync (`stzGraphView`).
- **Self-contained portability** — the app moves as *state + runtime + engine*, honoring the
  dependency-free promise.
- **A clean seam to Reach** — surfaces are views of the Body, so appearance never forks the truth.

---

*The Body is where a living world endures: its own graph, written in its own format, queryable and
portable — with a readable file-face kept faithfully in step. Declare where the world lives; it
remembers itself.*
