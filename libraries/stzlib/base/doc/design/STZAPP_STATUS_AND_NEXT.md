# stzApp - Status & Next Steps (handoff)

> Read this first when resuming work on `base/app/stzApp.ring`. It records where the
> construct stands, the hard-won Ring/stzGraph lessons, the pattern that works, and the
> concrete remaining work. Companion to STZAPP_DESIGN.md (the concept) and the
> STZAPP_PURPOSE_DESIGN.md / STZAPP_BODY_DESIGN.md deepenings.

---

## 1. Where we are

The construct `stzApp` -- "an application is a living world of meaning" -- is sketched
end to end and its foundation is **validated running under Ring**.

- **Concept (locked):** 3 CONSTITUTIVE aspects -- **Domain** (being: things, truths,
  relations), **Life** (becoming: behavior = flows+reactions, purpose = goals+plans),
  **Body** (embodiment: where it endures) -- and 4 RELATIONAL emergents -- **Presence**
  (seen), **Intent** (engaged), **Refinement** (tuned), **Reach** (appears). See STZAPP_DESIGN.md.
- **Code:** `base/app/stzApp.ring` -- classes `stzApp` + `stzAppFlow/Reaction/Goal/Body/
  Screen/Refinement` (classes last; no embedded examples).
- **Examples:** `base/test/app/` -- `00_stzapp_narrated.ring` (**VALIDATED GREEN**, Being),
  `01_..purpose`, `02_..body`, `03_..full` (design illustrations, not yet green -- see S4).

### Slice A (Being / Domain) = GREEN under Ring
`Thing(:X){ Has(...) IsTrue(...) Owns(:Y) }` + `Knows(...)` fully works: fields, truths,
and all relations persist and print; `Explain()` and `Live()` run. Run it:
```
cd libraries/stzlib/base/test/app
ring 00_stzapp_narrated.ring
```

---

## 2. The pattern that works (apply this to B..E)

Ring's value semantics defeat the "sub-builder object that the app reads back" approach
(see S3). The pattern that keeps the near-natural nested-brace idiom AND works:

**Make the entry method return `This` (the app); its brace calls the app's OWN methods on a
cursor over plain app-held lists.**

Domain does this (the template to copy):
```ring
def Thing(pcName)          # returns This, so { Has(..) Owns(..) } braces the APP
    ... register, set nCur = index ...
    return This
def Has(paFields)          # app method, operates on the current cursor
    if nCur > 0  aThings[nCur][2] = paFields  ok
    return This
```
No sub-builder -> no object copy, no R31, no graph-property bug. Data lives in plain
app lists (lists of lists persist fine; only *objects* copy).

---

## 3. Ring / stzGraph gotchas learned (operational knowledge -- keep!)

These cost real debugging; do not rediscover them:

1. **Reserved method/var names.** `Load`, `Import`, `Put`, `Set`, `Get` are reserved ->
   pick other names (we used `Restore`, `Ingest`). Ring is **case-insensitive**, so a var
   `oR` == the `or` keyword (broke Whenever/Refine); avoid 2-3char names colliding with
   `or/and/not/to/in/on/of/if/ok`... (we renamed `oR`->`oRe`).
2. **File order.** Top-level executable code must come BEFORE class definitions; classes
   go last. Class files contain no examples (examples -> `base/test/<topic>/`).
3. **Braces.** `oObj { ... }` and `method(){ ... }` (brace on a method's return) both work;
   `new X(){ ... }` FAILS (R16). Non-ASCII in source is risky on Windows -- keep it ASCII.
4. **R31 "destroy via self reference":** a sub-builder must not call back into the parent
   object whose brace is currently active. (Root cause of the abandoned sub-builder approach.)
5. **Ring COPIES objects by value** when stored in a list OR an attribute. So you cannot
   hand a shared object (even the graph) to a helper and expect mutations to reflect back.
   Plain data lists are fine; objects are not shared.
6. **stzGraph specifics:** nodes store lowercased ids (`:id = StzLower(id)`); `AddNode(id)`
   works, `AddNodeXTT(id,label,[])` did NOT register usably in our tests. `AddEdgeXT`
   requires both nodes to already exist and is finicky. **`SetNodeProperty`/`NodeProperty`
   round-trip is BROKEN** even directly (setting a hashlist key on a node's empty `[]`
   properties does not persist) -- a real stzlib bug (candidate for `grind-err`). Because of
   this we store Domain data in app lists, not graph node-properties, for now.

---

## 4. What remains (concrete)

### 4a. Convert B..E builders from sub-builder shape to return-This/cursor
The B..E builders (`stzAppFlow/Reaction/Screen/Refinement/Goal/Body`) currently return
sub-builder objects the app stores in lists -> their brace data is LOST to the copy bug
(their `Narrate()` will read empty). Convert each to the Domain pattern:

- **Flows** `When(:actor,:verb,:Thing){ Require(:f) Then(Keep(:Thing)) }` -> `When` returns
  This, sets a flow cursor; `Require/Then/Keep` are app methods writing to `aFlows[cursor]`
  (plain lists). EASY.
- **Reactions** `Whenever(:Thing).Unseen(n,:U){ Propose(:X) }` -> note the CHAINED
  `.Unseen(...)` before the brace: keep `Whenever` returning This, but `.Unseen` must also
  operate on a reaction cursor and return This; `Propose` an app method. EASY-ish.
- **Screens** `Screen(:X){ ToUnderstand(:Y) Shows([...]) Acts(:a,:flow) }` -> same cursor
  pattern. EASY.
- **Refinement** `Refine(:knob).Bounds(lo,hi)` -> chained, no brace; already close, but the
  builder object still copies -> make `Refine` store into `aRefinements` and return This,
  with `Bounds/Options` as app methods on the refinement cursor. EASY.
- **Goals** `Want(:G){ Means = "..."  ReachedBy = :planning }` -- HARD: uses **attribute
  assignment** inside the brace, which REQUIRES a distinct object (you can't `attr = val`
  onto the app via a cursor). Two options: (i) switch to method form
  `Want(:G){ Means("...") ReachedBy(:planning) }` (methods on a goal cursor, app-held plain
  data), or (ii) hashlist form `Want(:G, [ :means = "...", :reachedby = :planning ])`.
  RECOMMEND (i) to keep the block feel. Update STZAPP_PURPOSE_DESIGN.md + example 01 to match.
- **Body** `LivesIn([...]){ Graph = "..." Files = "./" }` -- same attribute-assignment issue
  as Goals; same fix (method form `Graph("...")` or hashlist `LivesIn([...], [:graph=...])`).
  Update STZAPP_BODY_DESIGN.md + example 02.

After converting, make examples `01`, `02`, `03` green and add their `#-->` expected output.

### 4b. Cosmetic / semantics
- stzGraph lowercases node ids, so `:Account` prints `account`. If case must be preserved,
  either use string ids (`"Account"`) or store the display name separately (we already keep
  the original name in `aThings[i][1]`, but Domain nodes are added lowercased). Decide.
- The graph is currently only a node REGISTRY (Domain data lives in app lists). If/when the
  stzGraph SetNodeProperty bug is fixed, revisit whether to move Domain data into real graph
  node-properties + edges (the "app is literally a graph" ideal).

### 4c. Deeper wiring (still stubbed, marked in code with comments)
- Life: `stzAppFlow.Build()` -> full `stzWorkflow` topology; `stzAppReaction.RegisterIn()` ->
  real Reaxis (`stzReactiveObject.Watch`/`WaitForAttributetoSettle`, timers, `RunLoop()`).
- Purpose: `Pursue()` -> real `stzGraphPlanner.UntilYouReachF(goalPredicate)` + `Using(profile)`
  (PI ladder); `Goal.Satisfied()/Gap()` -> real `stzGraphQuery` over live instance data.
- Body: `Save/Restore/Reproject/Ingest` -> real `.stzgraf`/`.stzrulz` + `stzGraphView`
  Commit/Rollback.
- Reach: `Reaches` -> `stzGraphView` projections per surface.

### 4d. Upstream (optional but valuable)
Fix stzGraph `SetNodeProperty`/`NodeProperty` (setting a key on empty `[]` properties). A
`grind-err`-style focused fix in `base/graph/stzGraph.ring` (~line 1331-1409) would unblock
graph-native storage for stzApp and help the graph module generally.

---

## 5. Open concept questions (from the design phase, still pending owner)
Recorded in STZAPP_DESIGN.md; the main ones: node-id case handling; whether Domain data
should ultimately be graph-native (properties/edges) vs app lists; and how far to take the
real Reaxis/planner/persistence wiring vs keep declarative. None block Slice A.

---

## 6. Quick resume checklist
1. `cd libraries/stzlib/base/test/app && ring 00_stzapp_narrated.ring` -> confirm GREEN.
2. Convert flows -> reactions -> screens -> refinement (easy, S4a), validating each with a
   things+that-aspect example.
3. Convert goals + body (method form, S4a).
4. Green examples 01/02/03; add expected output.
5. (Optional) fix stzGraph SetNodeProperty; then reconsider graph-native Domain storage.
