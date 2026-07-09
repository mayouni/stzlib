# Your First App with stzApp: A World That Lives, and Wants

> A narration. It builds a real application with `stzApp` — the Softanza construct that holds
> that *an application is a living world of meaning*. A world is **made of** a domain (things
> and their truths), a life (what it does *and* what it wants), and a body (where it endures);
> and it is **met** by being seen, engaged, tuned, and reached. Written as if `stzApp` already
> ships. Watch a world come into being, begin to move — and begin to strive.

## The setting

Aïcha builds a tool for a bank in Niamey. Field agents visit clients. She doesn't think
"database, screens, deployment." In Softanza she thinks about a small **world** — what lives in
it, what's true of it, how it moves, what it's *for*, and where it endures.

## Being — the world's things and their truths

```ring
load "stzlib.ring"
oApp = new stzApp("SonibankVisits")

oApp {
    Thing(:Account) { Has([ :number, :chapter, :balance ])  IsTrue(:balance) = '@ >= 0' }
    Thing(:Client)  { Has([ :code, :name, :city ])  Owns(:Account) }
    Thing(:Visit)   { Of(:Client)  Has([ :agent, :date, :subject ]) }
    Knows(:Account, :belongsTo, :Client)
}
```

A **domain** — a graph of things — declared without ever saying "graph," and told what *should*
hold: a balance below zero is simply not true in this world.

## Becoming, part one — how the world reacts

```ring
oApp {
    When(:agent, :records, :Visit) { Require(:subject)  Then( Keep(:Visit) ) }
    Whenever(:Client).Unseen(90, :Days) { Propose(:Visit) }
}
```

A *flow*: an agent records a visit, the world requires a subject, then keeps it. A *reaction*:
whenever a client goes unseen for ninety days, the world stirs and proposes a visit — nobody
scheduled it. This is the push of life: events flow, patterns fire, consequences follow.

## Becoming, part two — what the world wants

Here Aïcha adds the part that gives the world its *meaning*. A world that only reacts is a
mechanism. She tells it what it is *for*:

```ring
oApp {
    Want(:EveryClientSeenThisQuarter) {
        Means     = 'every :Client Has(:visit) Since(:quarterStart)'   # the wanted state
        ReachedBy = :planning                                          # how to get there
    }
}
```

`Want` declares a **goal** — not a list of steps, but a *wanted state of the world*: every
client visited this quarter (`stzGraphGoal`). `ReachedBy` names how the world should **find** its
way there (`stzGraphPlan`): `:planning` searches the graph programmatically; had the problem been
harder she'd have climbed the ladder — `:optimization` (order visits by route and workload),
`:learning` (predict who's most at risk), or `:llm` as a last resort. **Programmatic first,
intelligence only when needed — and always in service of a declared goal, bounded by the world's
truths.** The pull of life: the world now *strives*, not just twitches.

## Body — where the world endures

```ring
oApp { LivesIn([ :GraphDB, :Files ]) }
```

She gives the world a **body**. The graph database is its living substance — queryable, the
structure of its being and becoming. The files are its familiar, editable face. Edit a file →
the world updates; the world moves → the files reproject. (With no body declared, the world still
lives — in memory — it just wouldn't endure past a run.)

## The world lives — and pursues

```ring
oApp.Explain()
```
```
WORLD SonibankVisits   lives in: GraphDB + Files
  BEING     Account (…) true when balance>=0 · Client owns Account · Visit of Client
  BECOMING  · when agent records Visit → require subject → keep
            · whenever Client unseen 90 days → propose Visit
            · WANTS every Client seen this quarter  → reached by planning
```
```ring
oApp.Live()
```

`Explain()` makes the whole world visible — being, behavior, **and purpose**. `Live()` animates
it: stale clients surface on their own (reaction), and the plan quietly reorders the world toward
its goal, proposing the visits that would make "every client seen this quarter" become true. With
no UI at all, the world already **lives and wants**.

## Seen · Engaged · Tuned · Reached (the emergents)

```ring
oApp.Screen(:ClientFile) { ToUnderstand(:Client)  Shows([ :identity, :accounts, :visits ]) }
oApp.Refine(:balance).Bounds(0, 1_000_000)
oApp.Reaches([ :mobile, :desktop, :web ])
oApp.Generate(:all)
```

The **screen** is an intent (an agent wants to *understand* a client), rendered per surface.
**Refinement** turns a knob without touching being, life, or body. **Reach** projects the one
world onto phone, desktop, web — where it *appears* (distinct from its body, where it *resides*).
Each artifact is just *the world + the Ring runtime + the stz engine*, portable anywhere.

## What just happened

Aïcha declared a world's **being** (things, truths, relations), its **life** (a flow, a reaction,
and a *goal* with a plan), and its **body** (graph + files). Softanza gave her a *living,
striving application*, composed from `stzGraph`, Reaxis, `stzWorkflow`, `stzGraphGoal`/
`stzGraphPlan`, `stzAppServer`. Because it is a living world that wants, everything else — how it
is seen, engaged, tuned, reached — emerged. And because it is *just* a world, the same construct
could be an agent, a game, or a simulation. Softanza gave the world; what it lives for is hers.

> A living world of meaning. Being · life (behavior and purpose) · body.
> Seen, engaged, tuned, reached. One dependency. Any language. Everywhere.

---

*See also: [stzApp — Design](../design/STZAPP_DESIGN.md) — the three constitutive aspects
(domain, life, body), life's two arms (behavior, purpose), and the four emergents.*
