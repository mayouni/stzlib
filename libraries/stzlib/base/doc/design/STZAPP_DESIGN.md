# stzApp — an application is a living world of meaning

> **Status:** forward design — the *construct*, from first principles, in the Softanza
> spirit. `base/app/stzApp.ring` is a stub; this is what it should become. Present tense
> on purpose.

---

## 0. The construct

Softanza models a thing by asking what it *essentially is*, then rebuilding it around human
meaning. So we refuse the conventional application — files + database + UI + logic +
deployment, glued by a framework. That is an application's *plumbing*, not its *being*.
Stripped to its essence:

> **An application is a living world of meaning.**
>
> A world **made of** a domain (things and their truths), a life (behaviors it enacts and
> goals it pursues), and a body (where it endures) — and **met from without** by being seen,
> engaged, tuned, and reached.

Not a container of layers — a *world that lives, and lives for something*. That reframing is
what lets one construct be a business tool, an agent, a game, or a simulation.

`stzApp` is a **Base-layer** Softanza construct (`stz*`, human-centric, engine-backed), mostly
**composition**: it animates `stzGraph`, `stzWorkflow`, the Reaxis reactive engine, the
Softanzuter, `stzGraphGoal`/`stzGraphPlan`(`stzGraphPlanner`), `stzData`, `stzAppServer` — the
world's organs already exist.

---

## 1. First principles: what the world is *made of*, and how it is *met*

```
CONSTITUTIVE — what the world is made of
   ┌───────────────┐   ┌────────────────────────────┐   ┌───────────────┐
   │   DOMAIN      │   │            LIFE            │   │     BODY      │
   │  being        │──▶│  becoming                  │◀──│  embodiment   │
   │  things ·     │   │   behavior — it reacts     │   │  graph / files│
   │  truths ·     │   │   purpose  — it strives    │   │  / memory —   │
   │  relations    │   │              (goals+plans) │   │  where it     │
   └───────────────┘   └────────────────────────────┘   │  endures      │
                          the LIVING WORLD              └───────────────┘
                                  │  met from without:
       ┌──────────────┬──────────┴──────┬────────────────┐
    PRESENCE        INTENT          REFINEMENT           REACH
   (world seen)  (world engaged)   (world tuned)   (world appears)
```

Three aspects **constitute** the world (strip any and there is no world); four **relate** it to
the outside (strip them and a world still lives, headless).

### 1.1 DOMAIN — the world's *being*  *(constitutive)*

What the world *is*: its **things**, what is **true** of them, and how they **relate**.

- Things are nodes, relations are edges — the domain is a **graph** (`stzGraph`).
- **Truth is a conscience, not a syntax** (`IsTrueXT`): each thing declares what *should* hold
  — `IsTrue(:balance) = '@ >= 0'`. Validity is part of the world's being.
- **Meaning is first-class** (knowledge programming): `Knows(:Account, :belongsTo, :Client)`.

*Classic:* entity-relationship, set theory, ontology. *Modern:* the knowledge graph; truth as policy.

### 1.2 LIFE — the world's *becoming*  *(constitutive)*

How, and **toward what**, the world moves. A world that only reacts is a mechanism; a world
that also *wants* is alive **with meaning**. So Life has two arms:

**Behavior — the world reacts.** *(the push — efficient cause)*
Its heart is the **Softanzuter**: life flows through the world, patterns fire, computations
run, state updates, consequences cascade. Declared, never wired:
- **Flows** — an act moves the world through steps (`stzWorkflow`). `When(:agent, :records, :Visit) { Require(:subject) Then( Keep(:Visit) ) }`
- **Reactions** — the world stirs on its own as conditions settle (Reaxis). `Whenever(:Client).Unseen(90, :Days) { Propose(:Visit) }`
- **Future actions** — the world plans a sequence before it acts (`FQ`/`FF`).

**Purpose — the world strives.** *(the pull — final cause; this is what confers meaning)*
- A **Goal** is a *declared wanted state of the graph* (`stzGraphGoal`) — not steps, but the
  condition the world means to bring about: `Want(:EveryClientSeen) { Means = 'every :Client Has(:recentVisit)' }`.
- A **Plan** finds the way from the current state to the wanted one (`stzGraphPlan` /
  `stzGraphPlanner`), along the **PI ladder — programmatic first, intelligence when needed**:
  `ReachedBy(:planning)` → deterministic search · `:optimization` → solver · `:learning` → ML ·
  `:llm` → a language model as a *last resort*. Intelligence enters the world **only through
  plans, in service of declared goals, bounded by the domain's truths** — PI-first, governed by
  the world's own being.

*Classic:* state machines (behavior), teleology / final causation (purpose).
*Modern:* reactive functions, declarative agents, goal-directed planning with the PI ladder —
an **agent is simply a world whose purpose is declared and whose plans may reason**.

### 1.3 BODY — the world's *embodiment*  *(constitutive)*

Domain + Life are the world's **form** (its meaning); the Body is its **matter** — where that
form is inscribed and **endures**. A world of pure meaning, never embodied, is ephemeral; a body
is what lets it persist across time. The Body is **declared**, not a hidden backend (Softanza:
*make the invisible visible*):

```ring
LivesIn(:GraphDB)                 # node/edge substance
LivesIn(:Files)                   # a folder tree
LivesIn([ :GraphDB, :Files ])     # dual body: graph = living substance, files = readable face
# default: :Memory  (a world still lives with no declared body — it just won't endure)
```

A **dual body** is the old "two faces" made honest: the graph is the world's living substance
(queryable, the structure of being+becoming); the files are its familiar, editable projection.
Edit the files → the world updates; the world moves → the files reproject.

*Classic:* form & matter (hylomorphism). *Modern:* graph databases; structured, owned state.

### 1.4 What is *met from without* — the four emergents

Each is a relation a living world necessarily has; none is a separate system.

- **PRESENCE — the world seen.** `Explain()` narrates the whole world; `Show(:Client)` renders a
  thing; `viz` reveals structure. *Make the invisible visible*, applied to an entire application.
- **INTENT — the world engaged.** Participants reach in by *what they mean to do*, not by widget:
  `Screen(:ClientFile) { ToUnderstand(:Client) Shows([:identity, :accounts, :visits]) }`. (DISCOVER · UNDERSTAND · FOCUS · SELECT · ACT.)
- **REFINEMENT — the world tuned.** Named knobs (PolyCode) adjust without rewriting:
  `Refine(:balance).Bounds(0, 1_000_000)`.
- **REACH — the world appears.** Surfaces are projections of one world: `Reaches([:mobile,
  :desktop, :web])`. (Reach = where it *appears* to users — distinct from Body, where it *resides*.)

---

## 2. The idiom — near-natural, block style

A world declared: being, then becoming (what it does *and* wants), then its body.

```ring
load "stzlib.ring"
oApp = new stzApp("SonibankVisits")

oApp {
    # ─── DOMAIN — being ───
    Thing(:Account) { Has([ :number, :chapter, :balance ])  IsTrue(:balance) = '@ >= 0' }
    Thing(:Client)  { Has([ :code, :name, :city ])  Owns(:Account) }
    Thing(:Visit)   { Of(:Client)  Has([ :agent, :date, :subject ]) }
    Knows(:Account, :belongsTo, :Client)

    # ─── LIFE — becoming: behavior (it reacts) ───
    When(:agent, :records, :Visit) { Require(:subject)  Then( Keep(:Visit) ) }
    Whenever(:Client).Unseen(90, :Days) { Propose(:Visit) }

    # ─── LIFE — becoming: purpose (it strives) ───
    Want(:EveryClientSeenThisQuarter) {
        Means     = 'every :Client Has(:visit) Since(:quarterStart)'   # a wanted state (stzGraphGoal)
        ReachedBy = :planning                                          # how (stzGraphPlan): :planning|:optimization|:learning|:llm
    }

    # ─── BODY — embodiment ───
    LivesIn([ :GraphDB, :Files ])
}
```

The emergents, just as naturally:

```ring
oApp.Screen(:ClientFile) { ToUnderstand(:Client)  Shows([ :identity, :accounts, :visits ]) }
oApp.Refine(:balance).Bounds(0, 1_000_000)
oApp.Reaches([ :mobile, :desktop, :web ])

oApp.Explain()   # make the whole world visible
oApp.Live()      # animate it — it reacts and it pursues its goals
```

Softanza's method also offers other forms (a flat `Define…`, a fluent chained form); the block
above is the **primary** read, because it shows a world as *being · becoming · body*.

---

## 3. The design moves it honors

- **Generalize across structures** — a world is a graph; Show/Explain/Find work over all of it.
- **Declaration over execution** — things, truths, flows, reactions, **goals**, plans, and the
  **body** are all declared; the engine animates and the planner searches.
- **Make intent readable** — near-natural blocks; `IsTrue`, `Owns`, `Whenever`, `Want`,
  `ReachedBy`, `LivesIn`, `ToUnderstand` read as thought.
- **One engine** — all computation is the Softanza engine; the world runs the same in any language.
- **Truth as conscience** — validity lives in the domain; goals and plans are *bounded* by it.
- **PI-first intelligence** — planning climbs programmatic → optimization → learning → LLM only as needed.

---

## 4. Open and universal (a living world takes no side)

Because an application is *just a living world that wants*, the same construct carries very
different lives — `stzApp` prescribes none:

- a **business tool** (participants trigger flows; the world is seen through screens),
- an **agent** (its purpose is declared; plans reason toward goals within truths),
- a **game** (the world is a state a Softanzuter advances each tick, toward win-conditions),
- a **simulation / pipeline** (data flows, life fires, the world settles toward a target state).

Softanza gives the world and its organs; *what the world lives for* is yours to declare.

---

## 5. Module shape & build plan

Same three-file Softanza shape; a Base-layer construct over existing organs.

```
base/app/stzApp.ring            Ring API — the world, composed from graph/reactive/flow/goal organs
engine/src/ring_bridge_app.zig  bridge (only where native earns it)
engine/src/app.zig              native world helpers (indexing, projection) if needed
```

### 5.1 Composition grounding (verified against the real organs)

Every aspect — and the idiom itself — maps to methods that already exist (confirmed by reading
`object`/`graph`/`workflow`/`reactive`/`data`):

| Aspect | Real organ & methods it composes |
|---|---|
| **Block idiom** | Ring object-access braces `oApp { … }` (confirmed) + nested `Thing(:X){ … }` — **Softanza's own documented modeling style** (`stzDataModel { customers { … } }`). |
| **Predicates / norms** | hashlist + anonymous function: `[ :type = :Constraint, :function = func(oGraph, params, op){ … } ]` (the real `RegisterRuleInGroup` pattern). |
| **Domain — things & relations** | `stzGraph` (`AddNodeXTT(id,label,props)`, `AddEdgeXT(from,to,label)`, `Node`, `Nodes`) + `stzDataModel` relationship types (relational · hierarchical · network · conceptual) → `Owns` / `Of` / `Knows`. |
| **Life — flows** | `stzWorkflow from stzDiagram` (a flow *is* a graph): `AddStep`, **`Then(from,to)`**, `AddTransition(from,to,event,condition)`, `AddActor(id,name,role)`, `AssignStepTo`, `SetStepSLA`. |
| **Life — reactions** | `stzReactiveSystem` (`MakeReactive`, `ReactivateObject`, streams / timers, `RunLoop()`); attribute-watch via `stzReactiveObject`. |
| **Life — purpose** | `stzGraphGoal` = `stzGraphQuery` predicate (`Where`/`Match`); `stzGraphPlan` = `stzGraphPlanner` (`UntilYouReachF`, `Profile`/`Using` = PI ladder) + solver family. |
| **Body** | `stzGraph` persistence (`SaveToStzGraf` `.stzgraf`, `SaveToStzRulz` `.stzrulz`, JSON/YAML/GraphML) + `stzGraphView` (`Commit`/`Rollback`). |
| **Emergents** | Presence: `Explain`/`Show`/`viz`. Intent: screens + `stzWorkflow` actor-roles. Refinement: PolyCode. Reach: `stzGraphView` projections. |

**One idiom refinement the grounding forced** (real Ring, not the guide's pseudo-code): a truth is
a **two-argument method** — `IsTrue(:balance, '@ >= 0')`, not `IsTrue(:balance) = '…'` (Ring has no
method-call-as-lvalue). Inside a builder's brace, use **attribute assignment** (`Means = '…'`) or
**method calls** (`Has([…])`, `Owns(:Y)`) — both real; never a method on the left of `=`.

| # | Slice | Deliverable |
|---|---|---|
| A | **Being** | `Thing{ Has · IsTrue · Owns · Of }` + `Knows` → the domain graph; `Explain()`, `Show()` |
| B | **Becoming · behavior** | `When{…}` flows, `Whenever{…}` reactions, future actions; `Live()` |
| C | **Becoming · purpose** | `Want{ Means · ReachedBy }` → `stzGraphGoal` + `stzGraphPlan` (PI ladder) |
| D | **Body** | `LivesIn(...)` — graph / files / memory; dual-body projection & persistence |
| E | **Emergents** | `Screen{ ToUnderstand · Shows }`, `Refine()`, `Reaches([…])` |

**Litmus (slice C):** a world with only Domain + Life — no screens, no surfaces — not only
*lives* (a reaction fires on its own) but *strives* (`oApp.Live()` and a declared goal drives a
plan that reorders the world toward the wanted state). Everything else is the world being seen,
engaged, tuned, and made to appear.

---

*An application is a living world of meaning — made of domain (being), life (behavior and
purpose), and body (embodiment); met by being seen, engaged, tuned, and reached. Softanza gives
the world; what it lives for is yours.*
