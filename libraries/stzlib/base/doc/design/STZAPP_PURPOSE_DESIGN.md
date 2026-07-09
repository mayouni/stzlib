# stzApp — Deepening: Purpose (Goals & Plans)

> Companion to [STZAPP_DESIGN.md](STZAPP_DESIGN.md). Deepens **Life's second arm — Purpose**:
> what a world *wants*, and how it *finds its way there*. Grounded in the real graph organs
> `stzGraphPlanner`, `stzGraphQuery`, and the solver family — Purpose is composition, not new
> machinery.

---

## 1. Why Purpose, precisely

Behavior answers *how the world moves when something happens* (the push — a reaction fires).
Purpose answers *what state the world is trying to bring about* (the pull — a wanted end). A
world with behavior but no purpose is a mechanism; adding purpose is what makes it a world **of
meaning**. Two constructs express it, and both already have a home in Softanza:

- **A Goal — a declared *wanted state of the graph*** → `stzGraphGoal`.
- **A Plan — the way from the current state to that wanted one** → `stzGraphPlan` (a thin skin
  over `stzGraphPlanner`).

The key discipline, as everywhere in Softanza: **declare the goal; let the engine find the plan.**

---

## 2. A Goal is a wanted state, not a script  (`stzGraphGoal`)

A goal does not say *what to do*; it says *what should become true*. It is a **predicate over
the graph** — a condition that is either satisfied by the world's current state or not yet.

That predicate is expressed with `stzGraphQuery` (the graph's own condition language):

```ring
Want(:EveryClientSeenThisQuarter) {
    Means = 'every :Client Has(:visit) Since(:quarterStart)'    # a stzGraphQuery condition
}
```

`Means` compiles to a `stzGraphQuery` — `Match(:Client)` … `Where([ :visit, :since, quarterStart ])`
— and the goal is **satisfied** exactly when that query holds over the whole graph. `stzGraphGoal`
is the thin construct that carries:

| Field | Meaning | Backed by |
|---|---|---|
| `Means` | the wanted-state predicate | `stzGraphQuery` (`Where`/`Match`/`WhereF`) |
| `Satisfied()` | is the goal true of the graph *now*? | the query executed on the live graph |
| `Gap()` | *what is missing* to satisfy it | the query's unmet matches (the clients not yet visited) |
| `Bounds` (optional) | truths the goal must respect | `IsTrue` + `stzGraphRule` |

`Gap()` matters: a goal that can report *what is missing* turns "we want every client seen" into
"these 14 clients are the gap" — the raw material a plan acts on.

---

## 3. A Plan is a search toward the goal  (`stzGraphPlan` over `stzGraphPlanner`)

`stzGraphPlanner` **already performs goal-directed search.** Its `UntilYouReachF(goalFunc)` /
`ToReachF` walk the graph until a wanted-state predicate holds, and its `Profile` / `Using`
select *how* the search is done. `stzGraphPlan` is the small skin that binds a `stzGraphGoal` to
a planner run:

```ring
# what the world does under the hood for  Want(...) { ReachedBy = :planning }
oPlan = new stzGraphPlanner( oApp.Graph() )
oPlan.Using(:planning)
      .UntilYouReachF( func oGraph { return oGoal.Satisfied() } )   # goal as reach-predicate
```

The plan's output is not a mutation — it is a **proposed sequence of actions** (which visits, in
which order) that would move the graph from its current state into the goal state. Those proposals
re-enter **Behavior** as `Propose(:Visit)` events, which the world's flows then enact. So Purpose
and Behavior close a loop: *goal → plan → proposed actions → behavior → new state → goal
re-checked.* The world strives, settles, and re-strives.

---

## 4. `ReachedBy` — the PI ladder as planner profiles

`ReachedBy` chooses the plan's **profile** — and this is exactly the **PI ladder: programmatic
first, intelligence only when needed.** The goal never changes; only *how it is reached* escalates.

| `ReachedBy` | What it does | Softanza organ |
|---|---|---|
| `:planning` *(default)* | deterministic graph search (walk / BFS / DFS / A*) | `stzGraphPlanner` profiles |
| `:optimization` | best assignment under objectives & limits (route, workload) | `stzMultiObjectiveSolver`, `stzConstraint`, `stzListOfConstraints` |
| `:learning` | decisions under uncertainty; predict-then-plan | `stzStochasticSolver` + ML via `stzExterCode(:Python)` |
| `:llm` *(last resort)* | a language model proposes, bounded and reviewed | `stzExterCode` |

**PI-first is the default posture:** a plan starts at `:planning`; it escalates a rung only when
the space is intractable or the deterministic search cannot reach the goal. Every rung returns the
*same shape* — proposed actions — so a goal is indifferent to how it was reached. And every rung
is **bounded by the world's truths**: the planner's candidate states are filtered by `IsTrue` and
`stzGraphRule` (via the query's `EnforceRule` / `ValidateWith`), so a plan can never propose a
state the domain forbids. Intelligence enters *only through plans, in service of declared goals,
inside declared truths.*

---

## 5. Many goals, and when they conflict

A world may want several things at once. Goals compose:

```ring
Want(:EveryClientSeenThisQuarter) { Means = '…' }
Want(:AgentTravelMinimized)       { Means = '…'  Prefer = :minimize(:distance) }
Balance([ :EveryClientSeenThisQuarter, :AgentTravelMinimized ])   # trade-off, not tie-break
```

When goals pull in different directions (see everyone **and** minimize travel), the plan becomes a
**multi-objective** problem — `Balance(...)` routes it to `stzMultiObjectiveSolver`, which finds a
Pareto-sensible plan rather than forcing one goal to win outright. Priorities and weights are
declared on the goals; the solver honors them.

---

## 6. The idiom, complete

```ring
oApp {
    # a goal — a wanted state of the world
    Want(:EveryClientSeenThisQuarter) {
        Means     = 'every :Client Has(:visit) Since(:quarterStart)'
        Within    = :thisQuarter                       # a time bound (Timex)
        ReachedBy = :planning                          # PI-first; escalates only if needed
        Respecting = [ :AccountsAreViewOnly ]          # truths the plan must not break
    }
}

oApp.Goal(:EveryClientSeenThisQuarter).Satisfied()   #--> FALSE
oApp.Goal(:EveryClientSeenThisQuarter).Gap()         #--> [ 14 clients not yet visited ]
oApp.Pursue(:EveryClientSeenThisQuarter)             # run the plan → proposes visits
oApp.Explain(:EveryClientSeenThisQuarter)            # narrate goal, gap, chosen profile, plan
```

`Explain()` on a goal is Purpose meeting Presence: the world shows *what it wants, how far it is,
how it plans to get there, and why* — never a black box.

---

## 7. What this buys the construct

- **The agentic dimension, natively and safely.** An agent is just a world with a declared goal
  whose plan may reason — PI-first, truth-bounded, its reasoning always visible via `Explain`.
- **Games & simulations for free.** A win-condition is a goal; a plan is the AI opponent or the
  optimizer driving the simulation toward a target state.
- **No new engine.** Goals are `stzGraphQuery` predicates; plans are `stzGraphPlanner` runs with a
  profile; escalation reuses the solver family and `extercode`. `stzGraphGoal`/`stzGraphPlan` are
  thin, humane skins that make purpose *declared and visible*.

---

*Purpose is the pull that makes a world mean something: declare what should become true; the
engine finds the way — programmatic first, intelligent only when it must, always within the
world's own truths.*
