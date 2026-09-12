# SOFTANZA GRAPH-ORIENTED GRAPHICS — plan of record (GG0–GG5)

Status: PLAN OF RECORD, written 2026-08-09, after the graph-on-GPU spike
returned GO (`SOFTANZA_GRAPHICS_PLAN.md`, "GRAPH-ON-GPU SPIKE"). The
sibling documents are that plan (GR0–GR6, all shipped but GR5) and
`base/gpu/SOFTANZA_GPU_PLAN.md`, whose lifecycle and laws both inherit.

## 0. The thesis, in one sentence

**In every other engine the graph is SYNTAX; here it is SEMANTICS.**
ShaderGraph's graph is an authoring UI consumed at compile time — your
program can never ask it a question. `stzGraph` is a computational object
with algorithms and rule engines over it, so a graph can be the SUBJECT
of a picture, the STRUCTURE of a scene, the SCHEDULE of a frame, and the
AUTHORING form of a shader — and be the SAME object in all four roles,
with no export step between them.

And the spike found the unifying mechanism: **propagation over a resident
DAG to a fixed point is ONE primitive**, and all four roles are its
applications. Reachability (proven: 133x, exact, zero bus traffic),
hierarchical transforms, pass ordering and shader evaluation are the same
computational shape. That is what makes this a plane and not four
features.

## 1. What already exists (surveyed, not assumed)

- `stzGraph` — nodes/edges/properties, `PathExists`, `Paths`, path
  queries. **Engine-backed** (`_EnsureEngine`), so the data can already
  live outside Ring.
- `stzGraphQuery`, `stzGraphRule`, `stzKnowledgeGraph`, `stzGraphGoal`,
  `stzGridNav`, `stzOrgChart`, `stzDiagram` — a real graph domain.
- `stzGraphView` is a FILTERED VIEW with commit/rollback — **the name is
  taken and means something else.** The visual face must not reuse it;
  this plan names it `stzGraphCanvas`, consistent with `stzTreeCanvas`
  and `stzPlotCanvas` already shipped.
- `stzGraphPlanner` is a goal/plan system (profiles, named plans), **not**
  a pass scheduler. The frame-graph role cannot borrow it; it needs its
  own topological ordering over `stzGraph`.
- Shipped graphics: display list + SVG/PNG twins, 3D instancing with
  GPU-writable transforms, materials, tree layout, `dot.exe` retained for
  true graph layout only.

## STATUS OF EVERY ITEM, GENERATED FROM THE SUITE

**Do not hand-edit the table below.** It is produced by
`StzWritePlanCoverage()` from two things: the item definitions in this
file, and the `discharges("...")` declarations inside the guard sections
of `gg_adversarial.ring`. Section 75 fails if what is written here has
drifted from what those two sources say, so the table cannot go stale --
drifting is precisely what it is checked for.

A dash in the last column means no guard section declares that it proves
the item. That is a real gap and it is shown rather than hidden.

**AND A DASH MEANT THREE DIFFERENT THINGS, which is a worse report than
a number (2026-09-11).** Fifteen items carried one, and reading them one
by one rather than counting them found three separate situations wearing
one mark:

- **Four were declarations the gate had EARNED AND NEVER WRITTEN.** §57
  holds DN2c (this file says so in DN2c's own words), §66 is DN4a's class
  diagram down to its compartment criterion, §72 is DN5a's guard by this
  file's own sentence, and **§73 is titled `DN5b — A CIRCUIT IS READ AS A
  LOOP` and did not declare DN5b.** A section named for an item and
  silent about it is the sharpest form of the gap. All four declare now.
- **Six are UMBRELLAS whose every child is declared** — GG7 over
  GG7a–GG7e, DN3 over DN3a and DN3b, DN4 over DN4a and DN4b, DN7 over
  DN7a–DN7j, DN8 over DN8a–DN8h, DN9 over DN9a–DN9g. Nothing is unproven
  there and no single section proves the whole, so writing one in would
  be a false precision. They keep their dash and this paragraph is what
  the dash means.
- **Five are proven in a suite the convention cannot read** — GG0, GG1,
  GG2, GG4 and GG5 live in `graph_plane_narrated.ring`,
  `gg2_graphcanvas.ring`, `gg4_framegraph.ring` and
  `gg5_materialgraph.ring`. The generator takes a LIST of suites and has
  only ever been given one, and it cannot yet be given more honestly:
  `StzSuiteDischargesOf` returns `[ item, section ]` with no record of
  WHICH FILE a declaration came from, so a table built from five suites
  could not tell one §36 from another. That is `base/meta`, which belongs
  to another session, so it is **routed and not done here**.

So the honest count is not fifteen. It is **five items whose proof this
table cannot see**, six whose proof it can see through their children,
and four that were simply never written down. **No count
is written here on purpose**: the first draft of this paragraph said "10 of
31 items are undeclared", the true figure was 14, and it was wrong before
the table below it had been generated once. A hand-counted number standing
over a generated table is the whole defect this section exists to close,
reproduced in the sentence introducing the cure. Count the dashes.

The honest reading is that this table reports what the suite CLAIMS, which
is a smaller number than what the suite covers: most sections declare
nothing, and prove something anyway.

*Three hand-counted figures stood in this sentence until 2026-09-11 --
assertions, sections, declarations -- and all three were stale, because
the suite grows every week and a sentence does not. They were the defect
the paragraph above warns about, four lines below the warning, and they
survived because section 75 checks the TABLE for drift and not the prose
introducing it. The numbers are gone rather than refreshed: refreshing
them buys one correct reading and leaves the trap armed. Whoever wants
them back should have `StzWritePlanCoverage` emit them, which is the
general-tasks session's file and is routed to them, not fix them here.*

<!-- COVERAGE:BEGIN generated -- do not edit by hand -->
| item | status | discharged by |
| ---- | ------ | ------------- |
| DN9g | closed | 103 |
| GG0 | closed | - |
| GG1 | closed | - |
| GG2 | closed | - |
| GG3 | closed | 119 |
| GG4 | closed | - |
| GG5 | closed | - |
| GG6 | closed | 6, 7, 8, 9 |
| GG7 | closed | - |
| GG7a | closed | 40 |
| GG7b | closed | 41 |
| GG7c | closed | 42 |
| GG7d | closed | 43 |
| GG7e | closed | 44 |
| GG8 | closed | 39 |
| DN0 | closed | 51 |
| DN1 | closed | 52 |
| DN2 | closed | 53 |
| DN3 | closed | - |
| DN3a | closed | 65 |
| DN3b | closed | 76, 77 |
| DN4 | closed | - |
| DN4a | closed | 66 |
| DN4b | closed | 67 |
| DN5 | closed | 72 |
| DN5a | closed | 72 |
| DN5b | closed | 73 |
| DN6 | closed | 73k |
| DN6b | closed | 73m, 73z |
| DN7 | closed | - |
| DN7a | closed | 79 |
| DN7b | closed | 80 |
| DN7c | closed | 81 |
| DN7d | closed | 82 |
| DN7e | closed | 83 |
| DN7f | closed | 84 |
| DN7g | closed | 85 |
| DN7h | closed | 86 |
| DN7i | closed | 87 |
| DN7j | closed | 88 |
| DN8 | closed | - |
| DN8a | closed | 89 |
| DN8b | closed | 90 |
| DN8c | closed | 91 |
| DN8d | closed | 92 |
| DN8e | closed | 93 |
| DN8f | closed | 94 |
| DN8g | closed | 95 |
| DN8h | closed | 96 |
| DN10 | closed | 104 |
| DN11 | closed | 105 |
| DN12 | closed | 106 |
| DN13 | closed | 107 |
| DN14 | closed | 108 |
| DN15 | closed | 109 |
| DN16 | closed | 110 |
| DN17 | closed | 111 |
| DN18 | closed | 112 |
| DN19 | closed | 113 |
| DN20 | closed | 114 |
| DN21 | closed | 115 |
| DN22 | closed | 116 |
| DN23 | closed | 117 |
| DN24 | closed | 118 |
| DN24b | closed | 120 |
| DN9 | closed | - |
| DN9a | closed | 97 |
| DN9b | closed | 98 |
| DN9c | closed | 99 |
| DN9d | closed | 100 |
| DN9e | closed | 101 |
| DN9f | closed | 102 |
| DN2b | closed | 56 |
| DN2c | closed | 57 |
| DN2d | closed | 57 |
<!-- COVERAGE:END -->

## 2. Phases

*A heading or bullet that OPENS with an item id defines that item, and its status is read from its own words: shipped, delivered, done, closed; next, planned, not started; or undecided. That is a convention a check depends on, so a heading naming several items must not open with one of their ids -- the section above this list used to read "GG7 / GG8 REFLECTED" and was read as defining GG7, three screens before GG7 was actually defined.*

*An item may be defined in SEVERAL places, and every one of them counts. That sentence used to be false: the checker kept the first definition and dropped the rest silently, which meant the roadmap bullet naming an item -- stating no status, hundreds of lines above the section that defines it -- WON. Measured 2026-09-08 across the 26 plans in this library: **15 items of 125 reported a status their plan does not hold**, 14 of them shipped work reading "unstated", including GR0, GR1, GR3 and GR5 in the graphics plan next door. The rule it broke is the one written to catch a plan understating proven work, so a shadowed item made the checker accuse the plan of exactly the staleness it did not have. Statuses are folded across every definition now, and two things the fold can see are reported: definitions that state DIFFERENT statuses, and a definition repeated word for word. Guard: §75.*

## The plan that contradicted itself, and the checker that could not say so (2026-09-08)

**This file carried 342 duplicated lines from 2026-09-07 to 2026-09-08,
committed and pushed, and nothing reported it.** The DN9g commit
(`4065f1788`) inserted where it meant to replace, leaving a stale copy of the
whole DN9 section standing behind the new one — seven items defined twice, and
**DN9g defined as SHIPPED at one line and "Not started" at another**.

**A duplicate was invisible by construction.** `StzPlanItemsOf` skipped an id
it had already seen, so the second DN9g never existed as far as any rule was
concerned; the table read "closed" and was right by luck, because the surviving
copy happened to be the newer one. A checker that settles a disagreement by
ignoring one side is not reading the document, it is voting on it.

**The larger defect was underneath, and it was costing something every day.**
The same first-wins rule is what let a silent roadmap bullet outrank an item's
own section — 15 items of 125, measured above. Removing the duplicate was a
minute's work; the fold is the repair.

**What is now reported, and how narrow it is on purpose.** An id defined more
than once is ORDINARY here — 29 of 125 items are, by the roadmap convention —
so a rule firing on every repeat would file 29 findings about something the
plans do deliberately, and would be switched off within a week. Two cases
cannot be anything but an error, and across all 26 plans they fire **zero times
today** and both fire on the state this file was in yesterday:

| rule | fires when | today | on yesterday's file |
|---|---|---:|---:|
| `plan_item_status_contradicts` | two definitions state different statuses | 0 | 1 (DN9g) |
| `plan_item_defined_verbatim_twice` | one definition repeats another word for word | 0 | 7 |

**And the fold immediately found the next one, which is the same disease one
level up.** With statuses read from every definition, three items in this plan
and two next door were **parents reading "planned", or saying nothing, over
children that had all shipped** — DN8 over eight closed sub-items, DN9 over
seven, GR6 over three, GR2 and GR4 over two each. Five of the 32 not-closed
items in the whole library. Work here lands AS its parts, and when the last
part closes nobody goes back to the whole; `plan_item_open_but_discharged`
cannot see it, because a parent has no guard section of its own to discharge
it — its children have them. `plan_parent_understates_its_children` reports it,
all five are corrected, and the count is now **zero of 27**.

**One of those five corrections took a status away, and that is the finding
inside the finding.** The graphics plan carried a heading reading
`### GR0–GR6 are complete` — a RANGE, opening with an item id, so the checker
read it as a definition of GR0 and of nothing else. Six items were covered by a
sentence only a human could parse, and GR0 had been reading "closed" for a month
on the strength of a heading that was not about GR0 in particular. Renaming it
under the convention above **took GR0's status with it**, because GR0's own
words said only *"VERDICT: GO"* — and a verdict is a finding, not a status.
Nothing about GR0 changed and it stopped being closed, which is exactly how a
borrowed status shows itself. It says `DELIVERED` now, in its own section.

*The transferable part is not the rule.* The instrument that found this was
written to answer a different question, and the first version of it used a
looser id grammar than the checker it was about to inform — it reported 24
duplicates across 7 plans, of which the checker could see 9, because the real
grammar needs two capitals and a digit and mine admitted `G4`. **A measurement
about a checker has to use the checker's own definitions**, or it is a
measurement of something else. The corrected instrument is what produced every
number above, and it also found that `SOFTANZA_GUI_PLAN.md` defines **no items
at all** under that grammar — its ids are `G0` to `G5`, one capital — so that
plane's plan is unchecked and does not know it. Routed to the GUI desk rather
than fixed here.

### GG0 — the spike. DONE, GO (2026-08-09, 8ec3937d8)

Exact transitive reachability on device: 133x over the Ring path at
n=10,000, **zero mismatches**, and a whole frame costing 1,800,112 bus
bytes of which 1,800,000 is the image. Caveats stand as recorded: the
CPU baseline is the interpreter not native Zig; the iteration count is
fixed to a known depth; bitsets are O(n²/8) and stop near 30k nodes.

### GG1 — layout as a computation, not a lookup

Graph LAYOUT engine-side: hierarchical (layer assignment + crossing
reduction) and force-directed (Fruchterman-Reingold), both on the GPU
using GG0's propagation primitive, both DETERMINISTIC (a seeded layout
must reproduce byte-identically, or no guard can ever assert a picture).

KILL CRITERIA, written now: if a 10,000-node force-directed layout does
not converge to a stable configuration in under 2 s on this card, the
GPU layout tier is abandoned and `dot.exe` remains the only layout
route for anything non-tree. If a seeded layout is not reproducible
run-to-run, STOP — a non-deterministic layout cannot be guarded, and an
unguardable renderer is not shippable here.

### GG2 — `stzGraphCanvas`: the declarative face. SHIPPED

`oG.ToCanvasQ([ :Layout = :Hierarchical, :SizeBy = :Impact, :ColorBy =
:Depth ])` → an `stzCanvas`, so it inherits BOTH tiers free (SVG with no
device, PNG through one) exactly as plots and org charts did in GR6.
Node size/colour/label bind to COMPUTED graph properties, not to
hand-set attributes — that binding is the whole point.

KILL CRITERION: if the face cannot express the supply-chain risk picture
already produced by hand in the spike, the abstraction is wrong and gets
redesigned before anything is built on it.

### GG3 — the scene graph: hierarchy as the same primitive. SHIPPED

*This item went unadjudicated from the day the table was first generated
until 2026-09-11, and the paragraph that stood here said why: `SetParent`
existed on both sides, no guard section was named for the tier, and
whether that met the kill criterion was "a judgement for whoever owns
it". It is settled below. That it waited is kept in writing, because an
item which quietly turns green teaches nothing about how long it sat.*

*And the word it sat under cannot appear in this section any more, which
is worth one line for whoever closes the next one: the status is read
from the item's own words, the parser checks the waiting word BEFORE the
finished ones (on purpose — an item explaining why it waited usually
mentions work that shipped around it), so writing the history of a status
with the status word in it flips the item straight back. The first draft
of this section did exactly that and regenerated the table to no effect.*

**The criterion asked about a ROUND TRIP, and there is none.** Its words
were: *if hierarchical propagation cannot stay on-device — if any frame
needs a CPU round trip to resolve parents — it falls back to CPU-side
composition and the claim shrinks.* The failure it feared is a frame
that has to read the device back to find out where a child ended up. So
the question is not answered by reading the resolver and forming an
opinion about it; it is answered by **counting device traffic**, which
the scene already publishes.

| what was measured | reading |
| --- | --- |
| uploads while resolving a three-link chain | **0 geometry, 0 transform** |
| transform uploads per frame, 60 instances flat | 1 |
| transform uploads per frame, 60 instances chained 59 deep | **1** |
| draw calls, flat against chained | 1 against 1 |
| resolve of a 1,000-link chain, parents added first | under the clock |
| the same, parents added LAST (the resolver's worst order) | 0.05 ms at 200 |

**So the claim that survives is not the one the criterion was drafted
against, and it is not smaller in the way it expected.** Propagation is
composed **host-side**, in the library, so the literal phrase *stays
on-device* does not hold. But the property the phrase was protecting
does: **hierarchy costs the device nothing.** It adds no upload, no draw
call, and no readback — the composition is folded into the one instance
upload every frame performs anyway, and a chain fifty-nine deep is
indistinguishable from a flat list in device traffic. A GPU propagation
pass would have bought exactly nothing measurable here, which is why the
one that was allowed for was never written.

**One place the two sides can disagree, now asserted rather than
discovered.** A GPU-driven scene's instance buffer belongs to a compute
kernel after the first frame, so a parent moved afterwards changes what
`WorldPosition()` answers on the host and not what is drawn. That is the
mode's own contract — a kernel that owns the buffer owns it — and it is
the only case where the host's answer and the picture can differ. The
guard pins it with its control: the same scene *not* gpu-driven uploads
on every frame.

*Guard:* §119, 11 assertions, declaring `discharges("GG3")` — the
composed chain, the zero-upload resolve, the following and the
detaching, one upload and one draw flat or deep, the published depth,
the refused cycle counted rather than hung on, the self-parent refused,
and the gpu-driven divergence with its control. `gg3_hierarchy.ring`
keeps the longer demonstration it always had; what it lacked was
assertions and a declaration, which is why the item could not close on
it.

Parent/child transforms for `stzScene` (today's instance list is flat, so
articulated models — a robot arm, a solar system — are impossible).
Propagate world transforms down the hierarchy with GG0's mechanism: a
DAG, iterated to depth, on device, no readback. The graphics plan's
`SOFTANZA_GRAPHICS_PLAN.md` section 3b, door 4, already keeps transform
state separate from render state, so this is an addition, not surgery.

KILL CRITERION: if hierarchical propagation cannot stay on-device — if
any frame needs a CPU round trip to resolve parents — it falls back to
CPU-side composition and the claim shrinks to "scene graphs work",
without the zero-copy property.

### GG4 — the frame graph: passes and resources as a DAG. SHIPPED

Declare render passes and their resource reads/writes as an `stzGraph`;
derive execution order topologically, resource lifetimes by liveness,
and let `stzRuleReport` PROVE the properties as a CI gate: acyclic, no
read-before-write, no resource outliving its budget. This is the role
modern engines actually use graphs for (Frostbite's FrameGraph, Unreal's
RDG) and is a different tool from ShaderGraph entirely.

**Depends on challenge gaps 2 and 3** — sampled render targets and
compute+render sharing one submit. Both are named in the GR-plan's
challenge pass and both are cheapest to close during GR5.

KILL CRITERION: if the scheduler cannot beat the hand-ordered passes we
already write, it is ceremony; keep the manual order and ship only the
RULE checks, which are valuable on their own.

### GG5 — the material node graph (LAST, deliberately)

**DELIVERED as `base/graphics/stzMaterialGraph.ring`** — nodes and their
inputs compiled into the MATERIAL LANGUAGE (not into WGSL: the language
already refuses what it should, and a second transpiler would be a second
rule set to keep in agreement). Order, reuse and proofs derived;
`Affects(:node)` answers what a node changes, by reachability, while the
material is drawing. Guard `gg5_materialgraph.ring` (36).


A node DAG topologically emitted into the material language. This is the
role that merely reaches ShaderGraph's *shape*, and it is sequenced last
on purpose: the graph front-end is the easy half, and it is worthless
until the material LANGUAGE is deepened — multiple statements and
intermediate lets, texture sampling, control flow. Language first, graph
second.

KILL CRITERION: if the material language has not gained multi-statement
bodies and texture sampling, do not start GG5 — a node editor over a
one-assignment language is a toy with a GUI.

## 3. What is refused, and why

- **A visual node EDITOR.** Rendering a graph is in scope; building an
  interactive editing UI is a different product and belongs after GR5's
  window and input loop exist, if ever.
- **Replacing `dot.exe` for general graph layout** until GG1's kill
  criterion is actually met. Tree layout already left dot behind (GR6b);
  general layout has not.
- **Graph algorithms as a general GPU library.** Only the algorithms a
  PICTURE needs get GPU paths — reachability, layering, force layout.
  Betting on a general graph-compute library is the "build for a workload
  that does not exist" error G6 already taught.

## 4. Risks, named now

- **Scale wall.** Bitset reachability is O(n²/8) — fine at 10k, dead at
  100k. Any claim past ~30k nodes needs a different algorithm (sampled
  reachability, or per-query BFS instead of all-pairs), and the plan says
  so rather than implying the 133x scales forever.
- **Convergence needs a readback.** GG0 fixed the iteration count to a
  known depth. A general graph needs either a proven bound or a
  per-iteration readback — and that readback costs exactly the property
  the spike proved. This is the sharpest open design question in the
  plane.
- **Determinism.** Force-directed layout is iterative and float-ordered;
  without a fixed seed and fixed reduction order it will not reproduce,
  and every guard here asserts a picture.
- **The CPU baseline is the interpreter.** Every speedup in this plane
  must state that, or the numbers become folklore.

---

## GG1 SLICE 0 — DETERMINISM AND CONVERGENCE, MEASURED FIRST. VERDICT: GO

`base/test/graphics/graph_layout_determinism.ring`. Run before any layout
engine exists, because GG1's kill criteria decide whether one gets built.

### Both kill lines pass

| kill criterion | line | measured |
|---|---|---|
| seeded layout reproduces byte-identically | required, else STOP | **bit-identical**, 2000 of 2000 values in-process; same SHA-256 across 4 fresh processes |
| 10,000 nodes converge | < 2 s | **121–155 ms** for 60 iterations — 13× headroom |

### The design that makes it deterministic

**One thread per node, accumulating in INDEX ORDER, with no atomics and no
cross-thread reduction.** GG0's reachability used integer OR — associative,
commutative, exact, reproducible whatever order the hardware picks. A force
layout sums FLOATS, and float addition is not associative, so the summation
order must be fixed by the SOURCE rather than left to the scheduler. It is,
and it reproduces — including across process boundaries, where the shader
is recompiled and the device rebuilt.

Not tested and not claimed: reproducibility across DIFFERENT GPUs. A guard
runs on one machine, so same-machine reproducibility is what it needs.

### The plan's "convergence needs a readback" fear does NOT apply here

Recorded in this plan's own section 4, "Risks, named now", as the sharpest
open design question. It belongs to
PROPAGATION (reachability, layer assignment — where the iteration count
depends on the graph's depth), **not** to force layout. A force layout with
a cooling schedule has an iteration count fixed by the schedule, so nothing
has to be read back to know when to stop.

But only with an **ABSOLUTE** schedule — `temp = T0 * 0.94^i`, a function of
the iteration NUMBER. The first version normalised by the TOTAL
(`1 - i/nIters`), which makes run(30) a *different schedule* from run(20)
rather than run(20) plus ten steps. Residual measured that way was noise
(531 → 642 → 522 → 282 → 168 → 215 px). With the absolute schedule it
decays monotonically:

```
iteration  20   30   40   50   60   80  110
residual  414  223  120   65   35   29   10  px
```

### Quality is measured, not eyeballed

A layout can reproduce perfectly and still be worthless. The first picture
drawn was an even disc — and that was the CORRECT drawing of the graph it
was given, a pseudo-random expander with no communities. Proving nothing.

Re-run on a graph that HAS structure (6 clusters of 120, dense inside,
sparse bridges): mean radius within a cluster **131.6**, mean distance
between centroids **581.7**, **separation ratio 4.42**. The communities
come apart, and the number says so without anyone squinting at the picture.
`graph_layout_clusters.png` is the visual confirmation, not the evidence.

### Two measurement bugs caught inside the probe, both worth the entry

1. **`BufferDownloadList(id)` silently answered 16 values of 2000** — it
   takes `(id, count)` and the missing argument read garbage. The first
   determinism verdict rested on 0.8% of the data and said PASS. A
   comparison that reports success on a truncated read is exactly the
   coincidence-pass this house keeps meeting.
2. **The normalised cooling schedule above.** Both were found by asking
   whether the numbers could be right, not by anything failing.

### What GG1 still owes

Hierarchical layout (layer assignment + crossing reduction) is untouched —
and layer assignment IS a propagation to a fixed point, so the convergence
question lands there rather than here. Force-directed is proven; the other
half of GG1 is not.

---

## SECTION 4's RISKS, MEASURED (2026-08-12)

Section 4 named four risks as predictions. Three are now measured. Two of
the three predictions were WRONG, and each wrong one was hiding a defect.

### "Scale wall" — WRONG MECHANISM, and five times lower

Predicted: bitset reachability dies past ~30,000 nodes.

Measured: the bitset is fine. A 3,000-node chain answers impact for EVERY
node in ~90 ms, and it REFUSES above `MAX_REACH_NODES` (20,000) rather
than eating the machine. The wall was somewhere else entirely: every
list-returning call wrote node names into a FIXED buffer and, when full,
silently kept looping. A 5,000-spoke hub answered **2,916** nodes — and
the name at the boundary was cut wherever the buffer ended, returning the
id `node` for a node called `node1234`. Three hand-written copies of that
loop existed. Fixed with snprintf's contract (measure, then whole items or
none, return the size needed) and grow-and-retry in the bridge.
Guard: `test/graphics/gg_scalewall.ring` (11).

### "Convergence needs a readback" — RIGHT QUESTION, three defects under it

GG1 slice 0 answered half (force layout's absolute cooling schedule needs
no readback) and correctly pointed at layer assignment for the rest.
Going there found:

1. Layering on a cycle returned its PASS COUNTER as layers — a 6-node
   cycle answered `[42, 37, 38, 39, 40, 41]`. The cap is now a refusal.
2. `retCentralityAll` DISCARDED the engine's return value, so every
   whole-graph metric turned a refusal into n entries of uninitialised
   heap.
3. Which made `stzGraphCanvas`'s ":Impact refused above 20,000 nodes"
   message — written back in GG2 — permanently dead code.

**A refusal is not a refusal until something proves it reaches the
caller.** Guard: `test/graphics/gg_convergence.ring` (15).

### "Determinism" — the prediction held, and the layer under it holds too

`graph_layout_determinism.ring` already proved bit-identity within and
across processes. The question it never asked: a layout can reproduce
perfectly and still hang every coordinate on the WRONG node — a failure
that is stable, looks like a picture, and passes a determinism guard.

Measured clean. Two cliques joined by one bridge separate at **7.8x**, no
edge is dropped by the name lookup despite `MixedCase` ids folding to
lowercase, and every position names a real node. The negative control
(names decoupled from positions) collapses to **0.97x**, so the 7.8x is
about WHICH node rather than about spread.
Guard: `test/graphics/gg_layout_binding.ring` (7).

Note on that control, since the mistake is instructive: the first version
rotated positions by one index. The nodes alternate `L1,R1,L2,R2...`, so a
rotation hands every L the position of an R — a clean SWAP OF THE GROUPS,
which preserves separation exactly. It reported 7.74x and looked like a
library failure. No index arithmetic can scramble an alternating pairing;
the control had to decouple by VALUE (sort on x, deal in id order).

### "The CPU baseline is the interpreter" — TRUE, and bigger than assumed

The risk said to STATE it. Stating it never told anyone what the number
would be against a compiled baseline, and a "6,950x" that is 6,950x seam
and 1.0x algorithm would mean the bitset was never worth writing.

Measured by adding `stz_graph_impact_all_naive` — the same question, one
BFS per node, no bitset — purely as an instrument, so the multiplier
splits:

| | share | behaviour in n |
|---|---|---|
| Ring per-pair → same algorithm in Zig | **~7,000x** | flat |
| naive Zig → the bitset | **1.5x** at n=240, **3x** at n=2,400 | grows |

**Every "Nx faster" figure in this plane is a statement about crossing the
seam ONCE instead of n² times, and only secondarily about the algorithm
behind it.** That is not an argument against the bitset — 3x and rising is
why it exists, and it refuses past 20,000 where the naive walk would
simply get slow. It is an argument against reading 6,950x as an
algorithmic claim.

Two measurement traps inside the guard, both recorded in it:

- The first version averaged 20 engine calls on a millisecond clock — five
  ticks. It reported the bitset at 0.83x, which reads as a verdict and is
  a tick count. 2,000 reps fixed it.
- The file then CONTRADICTED ITSELF: 1.01x in one scene, 1.60x in another,
  at the same size. Both were right about what they measured. A fixed
  marshalling cost sits in both arms and drags any ratio toward 1.
  Subtracting a measured floor (`:Degree`, same bridge, no propagation)
  did NOT rescue it — differencing two noisy tenths-of-a-millisecond
  amplifies noise. The honest resolution was to stop claiming an
  algorithm share at a size that cannot resolve one, and let the sweep
  answer it where the signal clears the floor.

Guard: `test/graphics/gg_baseline.ring` (7).

### Still unmeasured

Nothing from section 4. The remaining risks are the ones the plane
declared out of scope in section 3.

## GG6 — DIAGRAMMING AS A STRENGTH: the design decision (2026-08-14)

The 40-node tree looked wrong after GG5 and the reason was not a bug. It
was a **missing model**. Four defects were found by drawing it and
looking; each is a named stage of the classic Sugiyama pipeline that this
plane had either skipped or inverted.

### The decision: spacing is the contract, the size is derived

dot's model, and this tier had it **backwards**. The caller fixed a
canvas and the layout was STRETCHED to fill it, so the minimum gap
between two nodes was whatever the stretch left over — 2px in a crowded
rank and 20px in a loose one, *in the same picture*. No amount of layout
quality survives that, because the last step overwrites it.

`SetNodeSeparation` / `SetRankSeparation` already existed, in dot's own
units, and **only the dot writer read them** — the port-knob trap again:
the knob the caller sends and the knob the face reads have to be the same
knob. A render naming no `:Width`/`:Height` now derives its size from its
content. Naming a size keeps fill-the-canvas, with `:FitBoxes` as the net.

### The pipeline, stage by stage — what was there, what was not

| Stage | Before | Now |
|---|---|---|
| 1. Layer assignment | longest-path, engine | unchanged |
| 2. **Dummy nodes for long edges** | **absent** | one per intervening rank |
| 3. Crossing reduction | barycentre sweep, engine | now also orders dummies |
| 4. **Coordinate assignment** | `position / (width + 1)` | isotonic/PAVA, engine |
| 5. **Edge routing** | centre-to-centre straight | ports, lanes, routed curves |

Stages 2, 4 and 5 were the gap. Note that 1 and 3 were the *good* ones —
which is exactly why this survived: **the crossing count was optimal the
whole time, and the drawing was still wrong.** An optimal answer to one
question is very effective at hiding that another was never asked.

### Why isotonic regression for stage 4 (and why it beats the textbook)

Place each layer to minimise squared distance from every node to the mean
of its neighbours, subject to keeping the sweep's order with a minimum
separation. Substituting `u[k] = t[k] - k*sep` turns the constraint into
"u non-decreasing" — so it is isotonic regression, and
pool-adjacent-violators solves it **exactly** in one pass. dot uses a
priority/median heuristic here; this is the optimum for the layer, and it
is deterministic (no sort, fixed arithmetic order).

### The two routing disciplines

- **Ports.** A node's edges fan from distinct border points, ORDERED BY
  DESTINATION. Ordered by rank index instead, two edges swap inside the
  box's own width and cross a pixel after leaving it.
- **Lanes.** Each parent's orthogonal trunk crosses the rank gap at its
  own height, cycled among four. One shared midpoint made neighbouring
  families read as crossings.

### Refused, and why

**Network simplex for layering.** dot uses it to pull nodes toward their
neighbours' ranks. Longest-path is already exact for trees and DAGs of
the shapes measured here, and the visible defects were all downstream of
layering. Revisit only with a picture that longest-path demonstrably
spoils — not on the authority of dot doing it.

### Clusters, closed (2026-08-14)

A cluster constrained nothing, so its box bounded its members *exactly*
and its members were scattered — a "Data" box with the logger inside it.
Nothing was fixable in the renderer. Three stages, each placed at the
layer where the property actually lives:

| Property | Layer | Why there |
|---|---|---|
| Contiguity | between sweep and placement | it is an ORDERING property |
| Cohesion | after placement, inward only | span can only shrink, so no neighbour loses room |
| Room for chrome | derived-size pass | a cluster is bigger than its members |

Contiguity orders groups by their **mean position in the sweep's order**
and leaves the order *within* a group untouched, so crossing work is kept
wherever the constraint does not contradict it. An unclustered node is
its own group — merging them would be a constraint nobody asked for.

Dummies are never clustered: a long edge crossing a cluster's ranks must
stay free to route around it.

**Not dot's model, deliberately.** dot lays each cluster out as its own
subgraph, collapses it to a node, lays out the parent, then expands.
That is the more general answer and it costs a recursive pipeline. The
constraint form gets the property that matters — a box holds its own and
only its own — at three local passes. Revisit if nested clusters are
ever needed, which the constraint form does not express.

### Self-loops, closed — and a plan item that was WRONG (2026-08-14)

This list said "self-loops and parallel edges are drawn as degenerate
segments". Checking it found both halves wrong, in opposite directions.

**A self-loop was not degenerate, it was FATAL.** Longest-path layering
propagates `lay[u]+1 > lay[v]`, true forever when `v == u`, so one
self-edge stopped the propagation settling and the engine refused the
whole graph as cyclic. A state machine with a single "stay in this state"
arrow could not be drawn at all, and the message blamed a cycle its
author would never recognise as one. Layering now skips self-edges; the
refusal for a real cycle is untouched. Underneath that the loop *did*
draw as a zero-length segment — the second defect the first was hiding.

**Parallel edges cannot be created at all.** `stzGraph` is a SIMPLE graph
by decision, documented at `ConnectIfAbsent`: a silently doubled edge
corrupts every count, path and metric that walks the adjacency. So there
was never a rendering gap here. The work became making the refusal worth
reading — it now names the model and points at `ConnectIfAbsent`, at edge
labels/properties, or at modelling the second relation as its own node.

**The lesson for this document.** Both items were written from a
reasonable assumption about code that was never run. One understated a
fatal defect, the other invented a defect that did not exist. An "open
items" list is a set of claims like any other, and claims decay — check
before scheduling, and expect the check itself to be the finding.

### Edge labels, closed (2026-08-14) — and the plan understated this one too

"Edge labels have no reserved space" implied they were drawn and merely
crowded. **They were never drawn at all.** The labels were in the model
and reached the dot writer, so every test that cared asked the model or
the dot and both were right — while the rendered picture showed anonymous
arrows. Third plan entry in a row whose claim was softer than the truth.

Drawn on a plate of the background colour (a label sits ON its edge; dark
text crossed by a grey line at x-height is unreadable — dot fills a box
for the same reason), with three placements because there are three kinds
of edge: rank-adjacent at the clipped midpoint, **routed where the edge
actually runs** rather than on the straight line it never takes, and
self-loops beside the loop. Overlapping labels nudge into the next band.
The rank gap grows only when it must — the default 76px already exceeds
the ~62px a line of text needs.

### `SetLayout` honoured nothing it did not recognise (2026-08-14)

Found while testing the above, and worse than it. `SetLayout` took any
string and stored it; an unrecognised name fell through `_NativeRankDir`'s
default and became **top-down in silence**. The vocabulary gave the
vertical directions seven spellings each and the horizontal ones exactly
one (`lr`, `rl`), so `SetLayout(:LeftToRight)` drew a top-down picture.
Every horizontal caller in this library was affected — `:LeftRight`,
`:LeftToRight`, `:RightLeft`, `"leftright"` all appear in the tree and
none worked.

Vocabulary now symmetric; an unknown layout is **refused**. A setter that
accepts a value it will not honour leaves the caller with evidence of
neither. Graphviz engine names are a different axis through the same
setter and are named explicitly so they cannot be mistaken for typos.

### Ortho self-loops, closed (2026-08-14) — and geometry that hid a bug

Under `splines=ortho` a loop is now three axis-aligned segments out of the
same side the curve leaves from. Asserted as the real property: **zero
segments in the whole picture are neither horizontal nor vertical**,
against 36 with curves.

**The fix exposed a second defect that was already there.** A self-loop's
label is anchored at its centre and sat a few pixels past the loop's outer
edge, so half the label plate lay ON the loop — and the plate is
background-coloured, so it *erased* what it covered. With a curve that
removed an arc nobody looked at twice; with a rectangle it removed the
entire right-hand side and the loop read as two stray horizontal lines.
Worth remembering: **making one thing sharper can be what finally shows
the other.**

### Nested clusters, closed (2026-08-14) — the constraint form CAN express them

This document twice recorded nesting as the thing the constraint form
could not do, and gave that as the reason to revisit dot's collapse model.
**It was wrong.** The cost of nesting was one idea: apply the constraints
*per depth* rather than once.

**Inferred, not declared.** A cluster whose node set is a subset of
another's IS inside it. Asking the author to also declare a parent would
be a second statement of one fact, free to disagree with the first — and
inference costs no API change, so existing callers gain nesting the
moment their sets nest. Partial overlap is refused: there is no
arrangement of two rectangles where each holds all its own members and
neither holds a stranger.

**Innermost first**, twice. Compacting by an outer key preserves each
group's internal order, so an inner block made contiguous first survives
the outer pass; the other direction undoes itself. Cohesion runs the same
way. The boundary gap needed no new rule — one helping of air per level
crossed, so outer boxes separate more than inner ones as a consequence of
counting rather than a second policy.

Two bugs that can only exist once boxes contain boxes: padding was a fixed
16 (an outer box must clear the inner *label*, drawn 24px above the inner
box), and boxes were painted in declaration order while each is *filled*,
so an outer cluster declared second erased the inner one — correct
geometry, invisible result.

**The refusal fired on the case it exists to permit.** Written as "is i
inside j, else do they overlap", it never asked whether j was inside i, so
declaring a nesting raised the error meant to forbid a non-nesting. The
negative sibling that catches this — *a genuine nesting is NOT refused* —
is now in the guard.

### Still open
- ~~Edge labels do not steer the layout.~~ **Closed 2026-08-14.** The
  engine's coordinate pass took one separation for every pair, so nothing
  wider than a node could ask for space. It now takes a per-node
  half-width demand — `sep + extra[a] + extra[b]` — and the isotonic
  substitution generalises exactly (`u[k] = t[k] - c[k]` with `c` the
  cumulative offset), so PAVA still solves each layer optimally in one
  pass. dot buys this with a virtual label node in its own rank; a
  per-node demand buys the same room without doubling the rank count.

  Charged to the **target**: a fan-out's labels spread the way its
  children do, so widening the children is what stops the labels meeting.

  **The first attempt widened the picture and the labels still collided.**
  They were drawn at edge MIDPOINTS, and the midpoints of a fan stay
  bunched near the parent however far apart the children get — the room
  was bought in the one place the labels were not standing. They now sit
  at a fraction of the way to the target and the demand DIVIDES by that
  same fraction; `_EdgeLabelBias` owns it and both read it. Out of step,
  the layout buys space the label is not in.
- **`polyline` and `line` splines are aliases of each other**, and neither
  changes a self-loop. Only `ortho` and the curved default are distinct
  routes today, so `$acSplineTypes` advertises six names for three
  behaviours.

### Every item on this list has now been checked, and every claim was wrong

Six for six. Each entry was written from a reasonable assumption about
code that was never run, and not one survived contact:

| Plan said | Truth |
|---|---|
| clusters "do not constrain layout" | correct, but the box was faithful — the members were scattered |
| self-loops "drawn as degenerate segments" | **fatal** — refused the whole graph as cyclic |
| parallel edges "drawn as degenerate segments" | **cannot be created** — simple graph by decision |
| edge labels "have no reserved space" | **never drawn at all** |
| nested clusters "the constraint form cannot express them" | it can, per depth — the plan asserted an impossibility about its own design |
| labels "do not steer the layout" | true, and the enabler was a missing engine capability, not a diagram concern |

The pattern is not carelessness in any single entry — each was plausible
when written. It is that **an open-items list is a set of claims, and
claims decay silently** because nothing runs them. The same reason a
`#-->` block goes stale. Check before scheduling, and expect the check
itself to be the finding.

### The pattern across all four (worth reading before scheduling any of them)

Every closed item was **understated by its own plan entry**, and each
entry was written from a reasonable assumption about code never run:

| Plan said | Truth |
|---|---|
| clusters "do not constrain layout" | correct, but the box was faithful — the members were scattered |
| self-loops "drawn as degenerate segments" | **fatal** — refused the whole graph as cyclic |
| parallel edges "drawn as degenerate segments" | **cannot be created** — simple graph by decision |
| edge labels "have no reserved space" | **never drawn at all** |

An open-items list is a set of claims like any other, and claims decay.
Check before scheduling, and expect the check itself to be the finding.

Guards: `gg_adversarial.ring` §6 (a parent sits over its children: 0.66%
vs 10.39% respaced the old way), §7 (the tightest gap IS the contract:
59px measured, 57px declared), §8 (zero edge ink inside any box, against
60 for a line drawn across one deliberately).

**Every one of those three instruments was WRONG on its first writing**,
and every one was caught by its negative sibling rather than by the
assertion it served — §6 read an `<ellipse>` tag this renderer never
emits, §7 measured runs of background that a shallow-angle edge chops
into fragments, §8 scanned by row and called a deliberately dirty picture
clean. A check that measures the wrong thing agrees with every input.

## REFLECTION ON GG7 AND GG8 — the live diagram, and the diagram larger than its medium
*(2026-08-19, reflection before any code; the Principal named both features)*

The two features look unrelated and are the same architectural statement:
**the retained engine scene is the single source, and every face — editor,
pager, screen viewer — is a viewport over it with different input.** That
extends this plane's thesis one step: the picture has been *a question
answered about the graph*; now the question can also be *"which cell is at
this point"* and *"which part of you fits this page"*.

### GG7 — stzLiveDiagram: the layout becomes a suggestion, the picture becomes an input device. SHIPPED as GG7a-GG7e

**THREE OF FIVE DELIVERED 2026-08-21.** The model half is done and
guarded; the window half is not started.

- **GG7a, picking. SHIPPED** (72308ddc7). `sceneSetPickTag`/`scenePick` in the
  engine, `SetPickTag`/`Pick` on stzCanvas, `PickAt` on stzDiagram
  answering `[ :node, id ]` / `[ :edge, from, to ]` / `[]`. Kill
  criterion MET and measured: **0.28 ms a pick on a 500-node diagram**,
  300 of 300 hits, against a 1 ms budget. Section 40.
- **GG7b, pins. SHIPPED** (3cfcf714b). `coordsPinned` in the engine, pins through
  stzGraphCanvas, `Pin`/`Unpin`/`IsPinned` on stzDiagram. A pin decides
  ORDER as well as position — without that it decided nothing visible,
  because rank order is settled before coordinates and `_Normalise`
  refits the box afterwards. Section 41.
- **GG7c, the command log. SHIPPED** (edbe91454). `Edit(kind, args)` with
  inverses, `Undo`/`Redo`, over the model's existing mutation API and
  its existing refusals. Section 42, nineteen assertions.

- **GG7d, the interaction. SHIPPED** (6de2d40a7). Four states — idle, dragging,
  linking, labelling — fed explicit events, so the machine is a function
  of (state, event) and is tested headless. Section 43.
- **GG7e, the session. SHIPPED** (this commit). `Step(window, options)` is one
  frame; `RunIn(window)` is the loop. Section 44, against a stub window.

**The second kill criterion, measured and ANSWERED rather than met as
written.** Re-rendering a 500-node diagram per pointer-move costs
**11,675 ms a frame** against the 16 ms budget — 730× over — and no
faster scene upload rescues it, because the cost is the layout and the
edge work, not the drawing. The plan invited exactly this measurement
("only if full-scene rebuild misses that does an incremental path earn
existence"); the answer it gives is not an incremental upload but that
**the model must not move while a gesture is in flight**. A drag records
the pointer, the window paints the cell over the picture it already has
(`DragPreview`), and the layout runs once at release. A drag frame then
costs **0.12 ms on 500 nodes** including a pick. GG7 is COMPLETE.

**Reading the picture backwards** made dragging possible at all:
stzGraphCanvas keeps the layout's own coordinate before `_Normalise`
rewrites it to pixels, and stzDiagram publishes the exact linear map
(`SlotAtPixel`/`PixelAtSlot`) — fitted in the coordinates actually
drawn, since fitting against the provisional measuring canvas gives a
map that is self-consistent and wrong.

**One measurement worth keeping**, found while chasing the pick budget:
`ToCanvasXT` was superlinear because a per-edge loop scanned
`Positions()` in the ITERATOR form over a method call, rebuilding the
list per step with four StzLower crossings a row. A 100-node picture
went 4.5s → 0.6s when hoisted. Only pictures that size themselves
entered that branch, so a fixed-size render of the same graph was
already fast and nothing looked wrong from outside.



The batch pipeline is `model → layout → paint`, and every stage OWNS its
successor. A live editor inverts the ownership: the user owns positions,
the layout only advises, and the picture must answer questions.

**What already exists to build on — measured, not hoped:**
- `stzWindow` (GR5): input events, and a swapchain still-frame at ~6.7KB
  of bus traffic — redraw is already cheap enough for dragging.
- The engine scene is RETAINED: every command lives engine-side. Picking
  is therefore a *read over data the engine already holds*.
- The layout is DETERMINISTIC (bit-identical), so a "re-layout" button is
  safe: same graph, same picture, no surprise shuffle.
- Every mutation the editor needs already exists with its refusals
  (`AddNodeXTT`, `AddEdge` refusing parallels, cluster overlap refusal…).

**Design decisions:**
1. **The model stays stzDiagram.** No parallel "editable graph" class.
   `stzLiveDiagram` = the same model + a *session* (window, pins, undo
   log, interaction state). Editing writes through the EXISTING mutation
   API, so every guard in this plane governs the editor for free, and
   model refusals surface as editor feedback rather than a second rulebook.
2. **Pins over positions.** A user-moved cell is *pinned*; layout and
   snapAlign never override a pin (react-flow's controlled/uncontrolled
   distinction; yFiles' "layout from sketch"). Unpinned cells keep
   flowing around pinned ones — the relaxation already accepts fixed
   points naturally.
3. **Hit-testing is ENGINE work** — `scene_pick(x, y)` over the retained
   command list in Zig (point in rounded-rect, point within tolerance of
   a polyline). One crossing per click. This is the one new engine
   capability GG7 needs.
4. **Undo is a command log** with inverses (`MoveCell`, `AddCell`,
   `RemoveCell`, `Link`, `SetLabel` — each Do/Undo), mxGraph's model:
   the editor never mutates directly, it *executes commands*.
5. **Interaction is a state machine** (idle → dragging → linking →
   editing-label), not event soup.

**Refused for v1:** freeform edge-path hand-editing; rubber-band
multi-select; a Ring-side scene graph (the engine already retains — a
copy would fork, which is the engine-wrapper copy law).

**Kill criterion:** on a 500-node diagram, pick < 1ms and drag-redraw
< 16ms. Only if full-scene rebuild misses that does a
`scene_update_cmd` incremental path earn existence — measure first; this
plan has named the wrong bottleneck before.

### GG8 — ToPages: rendered per tile, never rendered whole and cut

**DELIVERED 2026-08-20 (9b9d0facc).** `ToPages`/`ToPagesXT` on
stzDiagram, `SetRegion`/`ClearRegion` on stzCanvas, and one engine
addition — `sceneSetView` moves the projection and sizes the target, so
a tile is the same retained scene through a different window. Guard
section 39 (10 assertions).

Two amendments the work forced, both recorded because they change what
the plan said:

- **The seam is asserted as NOTHING MOVES, not as pixel-identity.** A
  tile and the whole render divide the same coordinate by different
  widths, so the rasteriser lands some antialiased edges one
  quantisation level apart — 79 pixels of 100,000, each off by one in
  one channel, unchanged when the projection is computed in f64. The
  kill criterion's spirit (a tile IS the picture there) holds; its
  letter (bit-identity) is not something the hardware offers, and
  claiming it would have been claiming something untrue.
- **The 8192 refusal had to stand aside for its own cure.** ToPages must
  ask for a canvas of the full size, so the check raised before any tile
  existed. It now recognises a tiling caller and names ToPages as the
  way out.



A picture larger than its medium must be **rendered per tile**, because
"whole" already fails: a GPU texture caps at 8192px and we ship that as a
refusal today. Print never had a whole in the first place. dot's
precedent is literal — `page="8.27,11.69"` has tiled PostScript across
A4 sheets for thirty years.

**Design:**
- `ToPages(:A4)` / `ToPagesXT([ :PageW, :PageH, :DPI, :Overlap, :Marks,
  :Path ])` — grid computed from the natural size, each tile drawn from
  the SAME retained scene with a translated viewport into a page-sized
  target.
- The one engine addition is **render-region**: offset the scene's
  orthographic projection by the tile origin. A few lines — and it is
  the same capability a *screen viewer panning a huge diagram* needs, so
  tiling and panning are ONE engine feature (viewport), not two.
- Overlap (default ~12mm) so sheets join with a glue margin; crop marks
  and a "page r,c of R×C" caption in the margin, dot-style.
- `ToPagesSVG` is nearly free — the SVG tier has no size limit — and
  covers vector printing without PDF work.
- **This retires the 8192 dead end**: the oversize refusal can now name
  `:Tiled` alongside ToSVG as the way out, and ToPNG on an oversize
  diagram gains an honest path.

**Refused for v1:** PDF assembly; "never cut through a node"
repagination (overlap covers it; dot does not do it either).

**Kill criterion:** the SEAM is the property. Adjacent tiles, overlap
stripped, must reassemble pixel-identical to a reference render of a
region small enough to render whole — and a 12,000px diagram (refused
outright today) must come out as a printable A4 grid.

### Order

GG8 before GG7: it is smaller, it retires a shipped refusal, and its
render-region is a prerequisite piece of the live viewer anyway. GG7's
hit-testing is the only other engine work; everything else is face
composition over what this plane already proved.

## THE VISUAL CONTRACT (2026-08-20, from the Principal's session of marks)

Every correction the Principal made this session — territories, corridors,
foreign surfaces, clearances, middles, merges — is one law seen from a
different side. Stated once:

> **A diagram is a visual language, not a painting. Every geometric
> coincidence a reader can perceive is a semantic claim, so the picture
> may contain no geometric relation that the graph does not contain.**

Three invariants operationalise it. Every future edge/layout decision is
judged against these, not against taste:

**I1 — INCIDENCE IS MEANING.** Ink touches a node or cluster surface iff
the graph relates them, and the touch is the attachment. This owns: the
territory rule (no node inside a foreign subtree's span), the corridor
veto (no run along a row), the foreign-surface rule (no crossing a
cluster you don't belong to), square arrivals.

**I2 — SHARED INK IS SHARED MEANING.** Two edges may run collinear only
where they share the endpoint on that side of the shared ink — a trunk
out of one source, a funnel into one target. Edges that merely both go
somewhere NEVER merge: a reader who sees Web A's line join API B's line
concludes Web A and API B share something, and the graph says they do
not. Distinct channels, one lane each, spaced a clearance apart.

**I3 — PROXIMITY IS LEGIBILITY.** Non-incident ink keeps _LineClearance()
from all other ink; where a band cannot give it, the middle is the
fairest position that exists. Gaps must be sized so a traversing line
leaves visible space both sides — including the space clusters' chrome
eats. Every such quantity scales with the render; a literal distance is
a bug by construction.

**I4 — A BEND IS A CONSTRAINT.** Every change of direction testifies to
something: an obstacle avoided, or the perpendicular grammar at a
border. A bend with no cause behind it claims a constraint the picture
does not contain — the reader looks for the thing the line swerved
around and finds nothing. So any leg that can run straight to its
ported end must: the router's reserved lane is a fallback for blocked
corridors, never the default. Crossings that a straight leg creates are
I1's problem and the wire hop answers it; they never justify a detour.

**I5 — SAMENESS IS A CLAIM.** Two things drawn alike are asserted alike,
and two spaced alike are asserted equally related. So siblings in one
relation render identically (a lone member drawn differently states a
distinction the graph does not contain), and a rank's spacing must show
where one family ends: equal gaps everywhere state one family. Where the
graph DOES declare a difference — different cluster membership, a
different kind of target — the picture may and should state it. The
converse is the whole rule: nothing may look different for a reason the
graph cannot supply, and nothing may look alike that the graph
distinguishes.

**I6 — THE PICTURE FOLLOWS THE GRAPH'S OWN EMPHASIS.** Where the graph
distinguishes a way onward — one child carrying a longer continuation
than its siblings — the drawing says so: the line runs straight and the
branches hang aside. Where the graph does not distinguish, the drawing
must not either: equal branches tie and the parent centres. A tie is not
indecision, it is the graph reporting that the line has split, and a
picture that picks a side there invents emphasis.

**I7 — SIBLINGS STAND ON EITHER SIDE OF THEIR PARENT.** Peers are shown
to be peers by their POSITIONS, before any line is drawn: a parent's
column must lie strictly inside the span of its children, so a reader
sees a pair about a middle rather than a queue down one flank. And the
vertical column is the strongest statement the grammar has, so it is
spent only where I6 licenses it — on the child carrying the graph
onward. A LEAF may never hold its parent's column while its siblings do
not: the straight line reads as continuation and the siblings read as
afterthoughts, a difference in kind that exists in the picture and
nowhere in the graph. The corollary is the edge half of the same claim:
children of one parent on one rank are reached by ONE grammar — one
stem, one channel, legs fanning to either side — because I5 makes any
difference in drawing a difference in meaning.

The enforcement points are structural, not per-picture: the layout owns
I1's territories and gap floors; the channel allocator owns I2's lanes
and I3's bands; attachment owns I1's borders; the routed staircase owns
I4's collapse; `centerParents` owns I6's emphasis and `siblingStraddle`
owns I7's positions, both in `graph_layout.zig` and both running after
every pass that can move a node. A new feature is done when it names
which invariant it serves.

## THE PLASTIC LAYOUT (2026-08-22, named by the Principal on first contact with the live editor)

His words, on the day every link he drew came out right: *"I think it is a
good thing that moving cells does not produce any change, since we are not
making the system for the sake of beauty, or arbitrary positioning like in
all the diagramming software. What the user needs to change is the links …
and let the diagram plastic position algorithm"* — and the name is his:
**the plastic layout**.

The doctrine it names, which every editor feature is now judged against:

**The author edits MEANING; the layout owns GEOMETRY — all of it.** A
diagram here is not a drawing that happens to contain a graph; it is a
graph that the plastic layout re-forms around, the way a plastic material
takes the shape of what it holds. Every spatial law in the visual contract
(I1–I7) is a consequence: geometry states facts, so only the algorithm —
which knows the facts — may write it. An author placing a cell by eye
would be asserting spatial claims the graph cannot back.

What follows for the editor's verb set, in the order the Principal ranked
them:

- **Managing links is the main action.** Draw one (L+drag between cells,
  GG7), **remove one** (`RemoveLinkAt` — a verb, not a gesture, because
  removal is instantaneous), and **re-aim one by its knobs** — an edge is
  grabbed near either END, carried, and dropped on another cell as ONE
  `Rewire` command with one inverse. The MIDDLE of an edge grabs nothing:
  its geometry belongs to the plastic layout, so there is nothing there
  for a gesture to say.
- **Cells and labels are the second rank**: add/remove a cell and edit a
  label already exist as commands; their gestures come when asked for.
- **Dragging a cell is advice about ORDER, never geometry** — the pin
  ruling of GG7b, which this doctrine retroactively explains: a pin
  reorders the rank and the plastic layout replaces every coordinate.

The refusals carry the doctrine as much as the verbs: a knob dropped on
paper abandons the gesture with the model untouched; a rewire onto a pair
the graph already holds is refused BEFORE the old link is removed, so a
refused gesture changes nothing at all. Section 49 of the guard holds all
of it headless.

## DN — DIAGRAMMING AS DOMAINS: a notation is DATA, the contract is LAW (2026-08-23, design ruled before code)

The Principal's ask: BPMN workflows, state machines, org charts,
electric/electronic, building plans, UML — all of it, model-driven, in a
visual-DSL style, without dirtying the foundation.

### The one decision everything else follows from

**A domain is a NOTATION PROFILE — a declaration — over the single
foundation. It is never a second renderer.** The estate already owns the
proof of both halves of this rule. The affirmative proof: one `_ElbowArc`
serves the staircase and the self-loop; one `stzRuleReport` gates six
rule domains; one plastic layout serves every picture drawn so far. The
negative proof: `stzBpmnDiagram` was built as its own renderer with its
own layout and its own SVG writer, and it arrived broken in exactly the
way duplicated machinery breaks — its emitter reset a shared accumulator
the main renderer had already learned not to, and nobody's guard saw it
because it lived beside the guarded path, not on it.

A notation profile declares FOUR things, each landing on machinery that
already exists:

1. **A VOCABULARY** — node kinds and edge kinds, typed. `:Task`,
   `:Gateway`, `:State`, `:Resistor`, `:Class`, `:Room`; `:Transition`,
   `:Wire`, `:Inheritance`, `:ReportsTo`. A kind carries its glyph, its
   ports, its compartments. Lands on: node properties and
   `_NativeShapeOf`, which already dispatch per node.

2. **WELL-FORMEDNESS RULES, in the house rule shape** —
   `[ :rule, :subject, :where, :severity, :message ]` through
   `stzRuleReport`, the one CI gate. A BPMN end event with an outgoing
   flow, a wire joining two outputs, a class inheriting from itself: all
   REFUSALS THAT TEACH, like the parallel-edge refusal that names the
   model and points at the way forward. The editor inherits them free:
   `Edit()` already refuses commands whose apply returns empty, so an
   illegal link in a domain is refused at the gesture, with the domain's
   own sentence.

3. **A GRAMMAR AMENDMENT** — what geometry MEANS in this domain, as
   deltas to the visual contract, never as a new contract. BPMN: the
   happy path is a straight spine, exceptions hang off it (the law
   `stzBpmnDiagram` already states; it becomes a named layout pass like
   `tidyTerritories`, gated by profile, instead of a fork). State
   machines: cycles are first-class and the self-loop is prominent (the
   loop grammar exists). Electric: junction dots assert connection,
   hops deny it (the hop exists — it was BORN from electric diagrams),
   wires are orthogonal always, components have FIXED ports. Org: strict
   tree, rank IS hierarchy. UML: edge-END adornments carry the meaning
   (diamond, triangle, multiplicity labels).

4. **A GLYPH SET** — per-kind drawing into the same canvas, same theme
   roles (the eight semantic roles, `:Muted` included), same pick tags.
   A glyph may declare PORTS (an electric component's pins, a UML class's
   compartment anchors); the knob machinery generalises — `PickAt`
   answers `[ :node, id ]` today and grows `[ :port, id, n ]`, and a
   rewire gesture lands on a port the way it lands on a cell.

### The model stays the model — this is the model-driven half

A diagram is a VIEW of a live domain object, never a parallel document.
`stzWorkflow`, `stzOrgChart`, a state machine, a circuit: each projects
into `stzGraph` + typed properties, and every edit command mutates the
MODEL through the existing undoable command set. The domain classes
already exist as models — what they gain is a projection, not a
rewrite: `oWorkflow.ToDiagramQ([ :Notation = :BPMN ])`.

The notation declaration itself follows the `.pia` precedent (an agent
is a FILE judged at load): a profile is a Ring declaration first, a
`.stznotation` file when one earns it — judged at load by the same rule
gate it declares.

### What is refused, and why

- **A meta-meta-framework** (MOF/EMF's tower). Profiles are small
  declarations over one strong foundation, each earning its place with
  a guard and a real picture. The tower is the enterprise trap: it
  makes every diagram equally easy to half-support and none fully.
- **Per-domain layout engines.** One plastic layout, parameterised.
  Where a domain truly needs a pass (BPMN's spine), the pass is named,
  guarded, and profile-gated — `tidyTerritories` is the shape: forest
  only, one property, refuses elsewhere.
- **Freeform geometry as domain surface.** Building plans tempt with
  "the author places the walls" — that is a floor-plan CAD, a different
  product. What this plane offers building diagrams is the same offer
  it makes everyone: topology in, lawful geometry out.

### Sequence, each phase with a kill criterion

- **DN0 — the profile shape, proven on the default. SHIPPED 2026-08-23.**
  `stzNotation` (vocabulary / rules / grammar / glyphs), the registry,
  and the seam: `_NativeShapeOf` answers through the profile, `Edit`'s
  Link and Rewire consult `MayLink`, `NotationFindings()` answers
  house-shape rows (`Validate()` was already the org chart's governance
  name -- DN1 found the collision). The kill criterion was MET: four scenes (service ortho in a
  window, the full type table, LR with self-loops, the rectangular
  style) rendered byte-identical PNGs before and after the refactor.
  §51 holds the rest live: a declared kind outranks the shared table, a
  closed vocabulary reports strangers with a teaching message, a
  forbidden link is refused at the gesture, a grammar amendment rides
  `SetNotation`.
- **DN1 — org charts. SHIPPED 2026-08-23.** `stzOrgChart` is born under
  its own registered notation, built beside the model it speaks for. The
  tree grammar became three rule primitives (`:SelfLink`,
  `:SecondParent`, `:Cycle` — the latter two graph-aware, which is why
  `MayLink` gained the diagram), and reaches the editor as refusals with
  no editor code knowing what an org is. Governance rule bases are
  untouched: they judge content and keep `Validate()`; the notation
  sweep is `NotationFindings()` because DN1 found the name collision.
  One subtlety paid for: a from-end REWIRE under a one-parent rule must
  be judged on the graph WITHOUT the edge being re-aimed, or every
  target looks already-parented. §52 holds it all, including I6 proven
  on a real domain's model.
- **DN2 — state machines. SHIPPED 2026-08-23.** `SetWorkflowType(
  "statemachine")` puts the workflow under its own law: states are
  rounded boxes (the declaration outranking the table), initial keeps
  the small circle and final the double one, and the rules are
  KIND-SCOPED — `ForbidFor(kind, :Inbound/:Outbound, msg)` — nothing
  transitions into the initial, nothing leaves a final, while cycles
  and self-loops are first-class. The real cost was the layout: the
  hierarchical tier refused any cyclic graph, because `:Depth` has no
  answer on a cycle. It now ranks against an acyclic ORIENTATION (DFS
  back edges dropped from ranking only) and draws the original arrows —
  a back edge points up, which is how return reads. The orientation is
  layout-private: `:Depth` the metric still refuses, because the fact
  still does not exist. §53 holds it, including the org/state contrast
  in one breath: the same Edit gate refuses a cycle in one domain and
  welcomes it in the other.
- **DN3 — BPMN. SHIPPED as DN3a; the KILL criterion FIRED, and here is
  the measurement it asked for.**

  BPMN arrived unlike the two domains before it. The org chart and the
  state machine had no notation before their profile — the profile is
  where their law was first written down. BPMN already had one: a
  written, versioned specification (`ringflex/docs/bpmn-layout-law.md`
  v1.0.0), a second conforming implementation in that repository, and a
  **layout digest** the two are held to.

  **THE SPINE LAW EXPRESSES.** L3–L11 assign a column, a row and an
  arrow class; §8's digest fixes exactly those decisions and §9
  explicitly frees geometry ("two conforming implementations can still
  draw differently"); and this library already has the hook that carries
  a decided position into the plastic layout — pins. So the pass is
  buildable and conformance survives it.

  **TWO OTHER THINGS DO NOT EXPRESS, and neither is the layout:**

  1. **L15's glyphs are not in the shared vocabulary.** A gateway
     bearing an X; a task bearing a gear, a person, an envelope, a clock
     or BPMN's own compensation marker; a thick ring; a DASHED double
     circle. DN0 defines a glyph as "the shape name the renderer already
     draws", and the renderer draws none of these six.
  2. **L18/L19 is a consumer contract.** Every drawn element carries a
     stable identifier and a set of classes, and a consumer binds to
     them and may say nothing else. `stzGraphCanvas.ToSVG()` emits
     neither ids nor classes, so deleting the private writer today would
     delete the contract.

  **SO DN3 SPLITS, and the split is measured rather than assumed:**

  - **DN3a — SHIPPED.** `StzBpmnNotation()`: the vocabulary (L15), the
    colour law declared (L16 — every kind white, no role named, because
    the only thing that colours a node is a verdict), the rules (a start
    event admits nothing, an end event releases nothing, a suspension
    resumes by declaration), the grammar (left-to-right, ortho), and a
    CLOSED vocabulary because BPMN is a standard. `stzBpmnDiagram` asks
    the profile which glyph a kind takes, so the two faces cannot come
    to disagree. `SetWorkflowType("bpmn")` draws a process through the
    one renderer under the visual contract. Guard §65.
  - **DN3b — SHIPPED 2026-09-04.** Three commits: 9022946a6 the
    channel, 2bb38c0db the renderer speaking it, 8e8689519 the
    conformance, and the private writer's 312 lines of SVG emission gone.
    Guards §76 and §77, 47 assertions between them. The markers and the
    dash discipline are DN4's business (compartments and adornments),
    which is where they were always going.

    **THE ITEM'S SECOND STEP WAS WRONGLY SPECIFIED, AND MEASURING IT IS
    THE FINDING.** It read "the law's col/row handed to the plastic layout
    as pins". Compared cell by cell against `LayoutDigest()` — the oracle
    this library and ringflex's implementation are both held to — the
    plastic layout ALREADY places every node where the law says. Three of
    five process shapes agreed on every cell with no pins at all, and no
    pin was ever added.

    The two that diverged did so for one reason each, always the same one:
    **L7/L8, an ending duplicated per arrival.** An ending reached twice is
    one node in the shared model and two markers in the law, and merging
    them moves the survivor. So the missing piece was never a layout pass;
    it was a MODEL transform, and `ExpandEndingsPerArrival()` is it. With
    it, all five shapes agree on every cell.

    **The written law settled a question this desk had got backwards.** I
    had been treating "one marker per arrival" as a drawing habit the
    shared model could decline, since real BPMN tools draw one end event
    with several incoming flows. `bpmn-layout-law.md` says otherwise: L7
    requires the duplication, L8 fixes the identities (canonical first,
    then `__2`, `__3` in arrival order), the digest checks them by id, row
    and column, and **L19 addresses endings BY CLASS and nodes by
    identifier** — every duplicate carrying `wf-target-<name>`. That is
    the same scheme the channel had arrived at independently for a node's
    box and its label: separate ids, shared class, because a multi-part
    element has no single identifier to offer. The law had already named
    the idiom.

    **AND THE REASON THE TWO FACES COULD NEVER MEET, which cost the most
    to find.** `stzWorkflow` carries TWO collections: `@aSteps` for the
    process vocabulary and `@aStates` for the state-machine one.
    `stzBpmnDiagram` reads `Steps()`; the BPMN guard builds with
    `AddStateXTT`. So the law's face was reading a collection the shared
    path never filled, `EntryStep()` answered empty, and the digest came
    back with a header and no records. That is why the private writer
    looked like it had no callers: not that nobody wanted it, but that
    nothing fed it.

    **What was deleted, and what deliberately was not.** The SVG emission
    went — `Svg`, `WriteSvg`, `Palette`, the node/arrow/stub writers, the
    theme and the verdict colouring, 312 lines with no caller outside the
    class. The LAW stayed, because §77 compares the shared renderer
    against its digest: deleting the file outright would have deleted the
    only thing that can say whether a BPMN picture is lawful. The class is
    the oracle now, not a rival renderer.

    **The plan-of-record check caught this item itself.** Declaring §76 and
    §77 against DN3b while the prose still read NEXT made
    `plan_item_open_but_discharged` fire, naming both sections, and
    `plan_coverage_table_is_stale` with it. The machinery built the same
    afternoon caught the defect it was built for, on live work rather than
    on a fixture.

- **DN4 — UML class diagrams. SHIPPED as DN4a and DN4b.** Compartments and edge-end adornments —
  the notation half the industry reads daily.

  **DN4a scoped to the CLASS diagram. SHIPPED** (`stzUmlNotation.ring`) — classes, interfaces, the five
  relationship kinds. The rest of UML follows as DN4b, and the reason
  that first scoping was wrong is worth keeping: *"sequence and activity
  are separate notations that happen to share a name"* was a JUDGEMENT
  written as if it were a fact. They share a metamodel, a stereotype
  mechanism and a reader; what differs between them is the LAYOUT, which
  is exactly what a profile is for. The Principal overruled it and was
  right.

  **DN4b — THE REST OF UML, measured before ordering.** Fourteen diagram
  types, and they do not cost the same:

  - **already shipped** — state machine (DN2, the modes model)
  - **profile only** — object · package · component · deployment ·
    communication
  - **one new glyph each** — use case (an ACTOR) · activity (a fork/join
    BAR)
  - **a new layout mode** — sequence (time is an AXIS)
  - **out of scope** — timing (a chart, not a graph; see the KILL)

  Those middle rows are the whole of what has to be built, because the
  shape table already carries Folder (a package), Component, Ellipse (a
  use case), Note and Cylinder, and clusters already draw a system
  boundary.

  **KILL, and it was aimed at two of them — one measured and cleared,
  one standing:**

  - **SEQUENCE.** Its y-axis is TIME and its x-axis is participants.
    That is not a graph layout, it is a schedule. If it cannot express
    as a layout MODE over the one renderer — the way :Modes and :Ring
    do — it is a second renderer wearing a profile's clothes, and the
    plan says so. Measured when built, never before.

    **MEASURED 2026-08-28, AND IT DOES NOT FIRE — DN4c SHIPPED.** The
    criterion was answerable because the two axes are NOT symmetrical,
    which the question above assumes they are. Only ONE axis belongs to
    the nodes: participants stand side by side, a single row, and
    `_LayoutSequence()` is four lines of `stzGraphCanvas`. The other
    axis belongs to the MESSAGES, and a message is an EDGE — its place
    comes from its ordinal in the model, the same way a lane's depth or
    a summit's side does. The time axis was never a layout question.

    What it added, each entering the way DN1–DN4b did: a LIFELINE is a
    node property drawn by the node pass (as a class's compartments
    are); a MESSAGE is one more branch in the edge loop that already
    had four — self-loop, routed, twin, generic; a REPLY is DN4a's
    dashed stroke unchanged. **No second draw loop, which is the
    criterion this paragraph actually named.**

    **AND ONE THING THE MODEL OWED, found by the ordinary case.** A
    checkout calls Inventory twice — reserve, then commit — and
    `stzGraph` refused the second: it is a SIMPLE graph so that counts,
    paths and metrics stay true. That refusal is CORRECT and was not
    weakened for a picture. Who-talks-to-whom is a RELATION and does not
    repeat; what-was-said-and-when is a SEQUENCE over it and repeats
    freely. Modelling the second as the first would have produced a
    graph in which Inventory has degree 4, which is false about the
    system described. So messages became their own ordered list —
    `AddMessage` / `AddMessageXT`, which also ensures the relation
    exists via `ConnectIfAbsent`. The graph stays true and the picture
    became possible, with neither giving ground. A sequence written with
    plain `AddEdge` still draws, so an author whose pairs never repeat
    never meets the difference.

    Guards: `gg_adversarial.ring` §67, 13 assertions, each positive with
    the negative sibling that proves it could have failed. Gallery:
    `gg_uml_sequence.ring`.
  - **TIMING.** A timing diagram is a chart with a time axis and value
    bands. This library has a plot pipeline and that is the right home;
    drawing it here would be the graph plane pretending. Named as OUT
    rather than left unmentioned, because a domain nobody lists is a
    domain nobody notices is missing.

  **KILL: if compartments cannot express as a node PROPERTY over the
  existing glyph machinery, say so and keep them out — measured, not
  assumed.** Measured before building, and it passes on three counts:

  1. **Per-node size already exists.** `@aBoxOf` / `_BoxOf` give every
     node its own drawn size, and this week established that every
     consumer reads it — the edge clip, the paper's extent, the row
     placement, the arrival attach. A class taller than a cell needs no
     new mechanism; it needs a size derived from its content.
  2. **A compartmented class is drawable with the primitives in hand.**
     A rectangle, two horizontal rules, three text blocks. `AddRect`,
     `AddLine`, `AddText` — nothing new, and `_WrapLabel` /
     `_LabelBlock` already measure text the way the drawing draws it.
  3. **It is NOT a glyph, and saying so is the answer.** DN0 defines a
     glyph as the shape name the renderer already draws, and a
     compartmented class is not a shape — it is a BOX plus content. So
     it enters as a node property whose size derives from what it holds,
     which is exactly the form the criterion asked about.

  The edge-end adornments pass the same way: a hollow triangle, a filled
  or hollow diamond and an open arrow are `AddPolygon`, and a DASHED
  line — the channel DN3a recorded as missing for BPMN's suspension —
  is the existing polyline emitted as alternating segments. No new
  canvas capability, which also makes DN3b cheaper rather than dearer.
- **DN5 — electric/electronic.** The stress test, LAST on purpose: a
  net is a HYPEREDGE (one wire, three pins), which the pair-edge model
  must earn honestly — junction nodes drawn as dots, or the domain is
  faked. KILL: if nets cannot be modelled without lying about the
  graph, the domain waits for the model to grow, and the plan says so.

  **MEASURED 2026-08-30, AND IT DOES NOT FIRE — DN5 SHIPPED.** The
  criterion's premise is a statement about a DRAWING. A net looks like a
  line, so "edge" is the natural reach, and then edges turn out to have
  two ends. Ask the domain's own formats what a net IS and none of them
  answers "a connection between two things":

  ```
  SPICE     R1 n1 n2 1k                    components NAME nets
  KiCad     (net (code 1) (name "GND")     a net is an OBJECT with a
              (node (ref R1) (pin 2))      name, a code and a LIST of
              (node (ref C1) (pin 1)))     nodes -- of any length
  Verilog   wire [7:0] databus;            declared, typed, sized
  ```

  A net is a first-class named object that pins attach to, carrying
  properties no edge can hold — a name, a width, a class — and existing
  whether or not anything is attached. **Net-as-node is the domain's own
  model; net-as-edge is what would have been the lie.**

  **ONE THING IS GENUINELY OWED, and it is a drawing rule.** A schematic
  draws a junction dot only where THREE OR MORE wires meet; two pins on
  one net are a plain wire, and a dot there states a branch that does not
  exist. So the net stays in the graph at every degree — named,
  queryable, carrying its properties — and the PICTURE elides the dot at
  degree two, collapsing the node's extent so its two edges meet at a
  point and read as one line. The model does not bend; the picture tells
  the truth about a junction.

  **WHAT IT COST:** five glyphs — resistor, capacitor, ground, source,
  junction — and they are the first in the table read as VALUES rather
  than as containers. A box with "R1" in it is a thing called R1; a
  resistor symbol IS a resistance, and an engineer reads the component
  from the outline before reading any label. That is why this domain
  could not borrow from the other nine, and why every electric glyph
  writes its name OUTSIDE itself.

  **ONE GRAMMAR AMENDMENT, and it is not electric-only:**
  `SetEdgesDirected(0)`. A wire carries no direction — current flows
  both ways depending on the moment — so it carries no arrowhead. A UML
  association and a communication link are undirected for the same
  reason.

  Guards: `gg_adversarial.ring` §72, each positive with its negative
  sibling. Galleries: `gg_electric.ring`, `gg_electric_compare.ring`.

  **DN5a IS NOT THE WHOLE DOMAIN, AND THE PRINCIPAL SAID SO.** Measured
  against the circuits every textbook and EDA tool uses as its worked
  example, the pictures are right in their parts and wrong in their
  whole:

  | what | verdict |
  |---|---|
  | symbols | IEC forms, readable, labels outside the outline |
  | terminals | a component lies ALONG its wire, so the wire meets a lead |
  | junctions | a dot at 3+ wires, a plain wire at 2 |
  | wires | undirected, no arrowheads |
  | left-to-right circuits | genuinely schematic-like |
  | **a closed loop** | **drawn as a straight line with two dangling ends** |
  | **proportions** | **a voltage divider comes out 124 x 1141** |

  **THE MISSING PIECE IS A LAYOUT, NOT MORE GLYPHS**, and it is DN2b's
  lesson arriving a second time. A layered layout answers "what flows
  into what" and orients cycles away. **A circuit is nothing but
  cycles** — current leaves a source and must return to it or nothing
  flows — so the smallest closed loop in existence comes out as a line.
  And because every element takes a rank of its own, a divider that a
  book draws roughly square is drawn nine times taller than it is wide.

  Real tools place parts on a GRID at a fixed pitch and route wires
  orthogonally between them. That is neither `dot` nor `circo`: it is a
  third mode, and the plane already has the seam for it —
  `SetLayoutMode(:Mesh)` would be one line in the profile, exactly as
  `:Ring` was for DN2b.

  **DN5b SHIPPED 2026-08-30, and the word is the domain's own.** Measured
  before building: a closed RC filter is 6 nodes and 6 edges, so
  E − V + 1 = 1 — exactly one independent loop. In circuit theory that
  quantity is the **mesh count**, and mesh analysis (Kirchhoff's voltage
  law taken once around each mesh) is the method built on it. The domain
  already reasons in the units the layout needs, so `:Mesh` is not a
  metaphor.

  `_LayoutMesh()` finds the fundamental cycle by spanning tree and walks
  it around a rectangle's perimeter as one parameter, so members spread
  evenly however many there are; anything hanging off the loop — a ground
  symbol — stands beside the node it attaches to. It fills `@aX`/`@aY`
  like every other mode, so it is a placement and not a second renderer.

  | measured | before | after |
  |---|---|---|
  | the smallest closed loop | a straight line, two dangling ends | a closed rectangle |
  | the RC filter | 124 × 1141 | 1000 × 700 |
  | component orientation | one global rank direction | read from the placement |

  **AND AN OPEN CIRCUIT IS NOT DRAWN AS A LOOP.** It carries no current,
  so it is laid in a line and left for the rules to report — drawing a
  rectangle would invent a return path the model does not have. Building
  this found that the first DN5 galleries were themselves open: a source
  whose other terminal reaches nothing, which is part of why they drew as
  chains.

  **BOTH OF THE REMAINDERS THIS SECTION NAMED ARE NOW CLOSED
  (2026-08-31/09-01), and what closed them is worth more than the fact.**

  *Interlocking meshes*, 841e853da. Contract every degree-2 node and a
  circuit states its own structure as JUNCTIONS joined by BRANCHES; two
  junctions carrying several branches ARE a ladder, which is how
  schematics have drawn parallel branches for a century. The same move
  as taking the mesh count from circuit theory rather than inventing a
  cycle metric: ask the domain for the structure, never the picture for
  a fit. What it removed was not cosmetic — the load's two wires left
  the same side, and a two-terminal part with both wires on one lead is
  drawn as a SHORT.

  *Corner orientation*, 574f10dbd. A corner is where the run changes
  axis, so whatever sits there has one neighbour beside it and one
  below — and a part has two terminals on ONE axis and cannot face
  both. The answer was not a better orientation rule but to stop
  SEATING a part there: the perimeter walk is phased off the corners,
  and the offset is scored rather than assumed, because a fixed
  half-step lands a member exactly on a corner at six members.

  **WHAT REMAINS, named rather than left to be discovered.** A ladder
  with MORE THAN TWO junctions — a three-section RC ladder has one per
  section — needs rails carrying several rungs each, and falls through
  to the single rectangle. No shipped fixture needs it, and the source
  says so at the decision.

  **AND THE PRINCIPAL'S MARKS ON THIS DOMAIN MINTED FOUR RULES THAT ARE
  NOT ABOUT CIRCUITS.** A wire meets a TERMINAL, never a body. A name is
  never laid ON a wire — the plate is opaque, so it does not overlap a
  line, it erases it. A curve is RESERVED here (a hop says "these cross
  and do not touch"), so a wire turns square and only the loop's own
  corners keep a radius. And every distance to a name is measured from
  the INK a glyph paints, not from the box it was allotted — a resistor
  asked for 68x110 paints a body 30x62 and spends the rest on leads.

The doctrine that makes all of it Softanza-ish is already written: the
plastic layout. In every domain the author edits domain MEANING — a
transition, a wire, a reporting line — and geometry belongs to the
algorithm, which is what makes one editor, one layout and one contract
able to serve them all.


## DN6 — DRAKON: the skewer, and a law this plane had already half-found (2026-09-01)

The Principal named DRAKON as the next deep task in this plane — the
visual language built for the Buran programme, "the best visual language
for designing any diagram", to be embraced as a first-class citizen. Its
three governing ideas are laws about READING, not about drawing:

| | |
|---|---|
| the skewer | one vertical line carries the main path |
| no crossings | by construction, not by a router |
| the happy path is leftmost | horizontal distance measures how unusual a branch is |

**The third is one this library had already arrived at from the other
end**, by the Principal marking pictures where the refusal ran down the
main line. DN6 is where it stops being a rule the plane patched in and
becomes a law a notation declares: `SetBranchSide(:Right)`.

### The kill, measured before a line of code

DRAKON's no-crossing guarantee is not free — it comes from the source
being a STRUCTURED algorithm, so that every path lies on vertical
skewers with only downward flow. An IRREDUCIBLE flow graph cannot: it
needs a crossing or a duplicated node. **KILL: if the models this plane
holds are irreducible, a DRAKON profile would either draw crossings in
the one notation that forbids them, or refuse most real models.**

Measured over every model in the plane's own fixtures, by extracting the
edge lists and running the standard T1/T2 collapse:

| | |
|---|---|
| models (weakly connected, 3+ nodes) | 139 |
| containing a cycle | 52 |
| with exactly one entry | 110 |
| reducible once given a single entry | **117** |
| genuinely irreducible | **0** |

**The kill does not fire.** The other 22 have no entry at all — circuits
and ring lifecycles, outside DRAKON's scope by construction rather than
by failure.

**THE INSTRUMENT TOOK THREE PASSES AND THE FIRST TWO WERE WRONG**, which
is the part worth keeping. Pass one read one variable name per file, so
scenes reusing `_o_` merged into a single graph and a FOREST failed the
collapse. Pass two split by component and reported 7 irreducible — all
ACYCLIC, which is impossible, and that impossibility is what exposed the
cause: those 7 have several roots, and T2 needs a unique predecessor. A
DRAKON diagram BEGINS somewhere, so pass three gives each root a virtual
entry — which is what a Title icon is — and asks the question the
criterion actually meant.

### What shipped

`StzDrakonNotation()`: the icon vocabulary mapped onto glyphs the
renderer already draws (DN0's rule for what a glyph is), and the skewer
declared rather than coded — `SetSpine(:HappyPath)` plus
`SetBranchSide(:Right)`.

**ONE COLUMN PER OVERLAPPING SPAN, which is the no-crossing law itself.**
A branch occupies the vertical stretch from where it leaves the skewer
to where it rejoins; two branches whose stretches overlap cannot share a
column without one running through the other. Counting them per RANK —
what the two-sided allocation does — cannot see that: the first DRAKON
picture put two refusals at different depths in one column, and the
router escaped the collision by taking a lane **194px beyond the paper**.

**And the OUTER branch stands further out.** The first allocation was a
downward sweep, first-come-first-served, so the branch leaving earliest
took the nearest column and the later one drew its wire straight through
the earlier one's box. Nesting is the answer and it is DRAKON's own: a
branch still out when a second one leaves CONTAINS it, and the contained
branch is nearer the normal case.

Measured, on the nested scene: without the profile both refusals occupy
**one** column; with it they take **two**, outer at 549 and inner at 320
against a skewer at 91. §73k holds it, with the negative asking about the
COLUMN rather than the side — two earlier drafts asked about the side and
both proved nothing, because the plain layout already sends a lone
refusal right.

### What was open on 2026-09-01, and is now closed

All three are done; they are kept in the record because the third one
was closed twice and the first was closed for the wrong reason first.

- **A question writes its text BELOW the rhombus.** ~~Open.~~ Closed —
  and the rhombus went with it. DRAKON's If **is a hexagon**, which the
  language's book states in one sentence and its teaching picture
  captions: diamonds under "an old messy flowchart", hexagons under "a
  modern DRAKON flowchart". Every diagram this plane had published was
  drawn in the glyph DRAKON exists to replace.
- **Two branches returning to the same terminal cross once.** ~~Open.~~
  Closed. `RenderCrossings()` on the hardest scene in the catalogue is
  **0**. The note above was right that a router bias is not the fix and
  wrong about what is: it needed the branch ordering to be decided by
  **enclosure**, and enclosure to be asked only between branches on ONE
  skewer, which reachability answers.
- **The SILHOUETTE.** ~~Open.~~ Shipped, then shipped again. The first
  version drew branches as separate columns and nothing else, under a
  heading reading "a transfer is written, not drawn" — half right, and
  the wrong half left three columns sharing a sheet with nothing saying
  they were one algorithm. DRAKON draws the runner's route: a rail above
  the branch entries, a rail below the addresses, the climb up the left
  edge, and the one arrowhead a silhouette is allowed.

### DN6b–DN6f — what the LANGUAGE'S OWN SOURCES added (2026-09-02/03)

The Principal judged the profile short of the language and supplied its
book, its icon table and eight real diagrams. Every item below is a
sentence in those sources that could be quoted against a picture this
plane had already published — which is the finding: **correcting an
artefact against a reviewer's eye converges on what the reviewer can
see, and a specification says things no instance shows.**

- **Exits are DECLARED, not read from labels.** The reference engine
  gives every icon exactly two exits and fixes what each means — `one`
  is the item below, `two` the item to the right. This library read the
  words: affirmative, then neutral, then anything. That works on yes/no
  and is a guess everywhere else. §73m proves it on a scene whose
  wording misleads.
- **An arrow means a LOOP and nothing else means it.** "All arrows
  inside a branch represent loops. All other lines do not have arrow
  heads." This plane drew one on every edge, spending the one mark the
  language reserves for its rarest event on its most ordinary one.
- **A FOR loop is TWO icons**, Begin For and End For, with the body
  between them. One icon with a right exit is an If wearing a loop's
  name: read literally, the fixture said the loop ends on its first
  pass. The gap had been NAMED in the profile under a heading reading
  "NAMED AND NOT DONE" and the picture went out claiming otherwise.
- **Select and Case are a construct, not two glyphs.** Three cases came
  out at two coordinates — one icon drawn over another — because a
  branch's column was "one plus the number of branches nested inside
  it", which orders things that CONTAIN one another and says nothing
  about peers. A branch is also a CHAIN, not a node.
- **`branchId` orders the silhouette's branches**, so the entry branch
  is declared rather than implied by the order somebody typed.
- **The Shelf needed no glyph**; it is a two-compartment node, which
  this plane already draws for a UML class. What it needed was the right
  to NAME its second compartment.

### The law this phase minted, three times over

**A rule whose membership is ENUMERATED stops being applied the moment
something new arrives.** Three instances in one week, each hand-extended
at least once before it failed:

| the rule | its list | what it missed |
|---|---|---|
| the paper is the content measured | four layout modes | DRAKON is none of them |
| this kind holds its own name | the shape `diamond` | every other sized glyph |
| a node's compartments | `attributes`, `operations` | the Shelf's second text |

The first had narrated its own three previous extensions in the comment
directly above the list. The repair each time is the same: ask a
PROPERTY, keep the old list as the default, and **assert that default**,
because a silent redefinition for every other domain is the expensive
way to find out.

### The last two open items, both closed 2026-09-03

*This heading said "Still open" until 2026-09-04, over two items that had
both been closed the day before. It is the third staleness in this file in
two days, and the first one found by a CHECK rather than by a reader —
`plan_calls_closed_work_open` in `stzCodeRules.ring`, which reads a heading
that claims openness against the items under it.*

~~The icon table's remaining real-time set~~ — **CLOSED 2026-09-03,
781b496f2.** The law was in the macroicon table all along: thirteen rows
of "X by timer", every one drawing the timer ATTACHED to the left of the
icon it governs. A timer is a property of a step, not a step. §73z.

~~The visual logic formulas as a checked law~~ — **CLOSED 2026-09-03,
78f28ab24.** Both are plastic rules now, `and_chain_on_one_line` and
`or_chain_steps_aside`, each proved to discriminate by perturbing a
correct picture into the other pattern. Adding their pictures to the
governor's corpus then showed three of this plane's general rules
contradicting DRAKON laws, each of which now states its boundary.

### Nothing in DN6 is open, and that has been said twice

**This list was corrected on 2026-09-03 for saying three closed things
were open, and it was stale again within a day** — because both items
above were closed that same afternoon and the plan was not touched. The
first correction called a stale record "a false statement in the one
file another session reads to learn where this plane stands", which was
right and did not stop it happening again.

The lesson is structural rather than moral: **a plan that must be
hand-updated after every close will lag, and the lag is invisible from
inside the session that caused it.** Where an item names its guard
section and its commit — as the two above now do — a reader can check
the claim in one grep instead of trusting the prose. That is the cheap
half of the fix. The expensive half, not done, is having the guard
sections themselves declare what plan item they discharge, so the plan
can be generated rather than remembered.

**Half of that expensive half was built on 2026-09-04, after the file went
stale a THIRD time in two days.** Two rules in `stzCodeRules.ring`, guarded
by §74, in the unified finding shape so they join the one gate rather than
starting a second:

- `plan_cites_a_missing_guard` — the plan names a guard section no suite
  defines. Fires on a renumbering, and on a plan claiming a proof it never
  had.
- `plan_calls_closed_work_open` — a heading says work is still open and
  every item beneath it is struck through and marked closed. **This is the
  direction the defect actually ran in.** The citation direction was never
  the problem: a session adding a guard cites it correctly in the same
  breath. It is the paragraph three screens up, still calling the work
  pending, that nobody walks back to.

It found one on its first run — the heading at what is now line 1502 — and
two more repairs came out of building it. **What it does NOT reach is
written down beside it**, because a check's reach being mistaken for its
coverage is the next version of this same defect: the DRAKON paragraph in
DN2a was stale in prose under an honest heading, and no rule that does not
know what DN6 means can see that.

Two lessons worth more than the rules, both paid for:

1. **The guard's positives must be BUILT, never borrowed from the artefact
   it guards.** The first version perturbed the live plan — strike an item,
   rename a heading — and the first repair the rules provoked rewrote those
   exact sentences. Every positive would have quietly become a negative and
   the guard would have gone green by testing nothing.
2. **Silence has to be earned.** Two headings passed the first version
   because their items were INVISIBLE to it, not because they were open —
   it counted only bullets and struck-through lines, so a live item written
   as plain prose was skipped. The negative sibling caught it; the positive
   never would have.


## DN7 — MATHEMATICAL DIAGRAMS: a picture is SOLVED, not placed (2026-09-04). SHIPPED as DN7a; DN7b named

The Principal named the next domain — mathematical diagrams, taking
Penrose (Ye, Ni, Krieger, Ma'ayan, Wise, Aldrich, Sunshine, Crane; SIGGRAPH
2020) as the inspiration. Read from its own sources before a line was
written: the paper, the language reference, the constraint and objective
library source, the optimizer source, the staged-layout post, the 2024
retrospective, and the set-theory, geometry and linear-algebra examples.

**What Penrose is, in the paper's own two principles**: *"(i) to specify
diagrams via a mapping from mathematical objects to visual icons, and (ii)
to synthesize diagrams by solving an associated constrained optimization
problem."* Three languages carry it — a DOMAIN declares a field's
types, predicates and functions; a SUBSTANCE states one diagram's content
in that domain, with graphical data *excluded* so the same content can
wear many representations; a STYLE maps patterns over the domain to
shapes, with `ensure` for a constraint and `encourage` for a preference.
The picture is then found by an exterior-point method: minimise objective
+ λ·Σ max(0, g)² with L-BFGS, raise λ tenfold until nothing is violated.

### The kill, measured before a line of code

**KILL: if this library's own autodiff tape and L-BFGS cannot reach
feasibility on Penrose's seven-set example from random starts, the domain
needs a solver of its own, and that is a different plane.** Measured by
hand-composing the penalty energy for `tree.substance` — 21 unknowns,
44 constraint terms — and handing it to `StzEngineMinimize` as it
stands:

| | |
|---|---|
| random starts | 3 |
| penalty rounds to feasibility | 1, 1, 1 |
| evaluations | 1213, 1346, 1236 |
| maximum violation | 0, 0, 0 |

The kill does not fire. The one engine change was a constant: the tape's
variable cap, 64 to 256, because a labelled set costs five unknowns and 64
was a cliff at twelve sets.

- **DN7a — the set-theory domain, end to end. SHIPPED 2026-09-04.**
  `stzMathDomain`, `stzMathSubstance`, `stzMathStyle`, `stzMathDiagram` in
  `base/graph/stzMathDiagram.ring`; `StzSetTheoryDomain()` and
  `StzEulerStyle()` — Penrose's own `setTheory.domain` and `euler.style`,
  as data. Guard §79; scenes in `gg_math_scenes.ring`, every one of them
  Penrose's own: `twosets-simple`, `tree` (the README's example),
  `nested` (the case the paper says "disks must shrink exponentially"
  for), a three-way Venn, and the contradiction of the paper's Fig. 2.

  | scene | unknowns | constraints | rounds | evaluations | ms |
  |---|---|---|---|---|---|
  | two sets | 10 | 22 | 1 | 47 | 10 |
  | seven-set tree | 35 | 85 | 1 | 238 | 70 |
  | nested seven deep | 35 | 82 | 3 | 938 | 72 |
  | three-way Venn | 15 | 39 | 1 | 97 | 19 |
  | contradiction | 10 | 23 | 14 | 801 | 262, unlawful by 14px, reported |

  **What is Softanza's own.** The solver is the engine this library
  already had — the energy is ONE expression string over the
  unknowns, compiled once to a tape; no new Zig. The renderer is the one
  canvas, so a mathematical diagram gets both tiers and the DN3b id/class
  channel free: a Set's circle is `<g id="A" class="circle set el_A">`.
  Rules are DATA, as the plane ruled for notation profiles. A
  contradiction is a FINDING in the house rule shape, never a crash —
  the picture of Fig. 2, a dot on the boundary, drawn and explained.

  **The staging pitfall, paid for.** The first solver laid shapes out with
  labels excluded, then placed labels against frozen shapes — exactly
  the staging the Penrose blog demonstrates failing. On the seven-deep
  chain the innermost circles were sized with no room for their text and
  no label round could mend a radius it was not allowed to move: 4.4px
  short, unlawful. Stage 0 is a JOINT solve now and stage 1 only polishes
  labels. Every scene became lawful in one or three rounds.

  **And the plane's oldest defect, again.** The seven-set tree took
  1,348 ms, and most of it was 85 violation tapes recompiled every round,
  when they never change between rounds. Compiled once per solve: 70 ms,
  nineteen times cheaper, the same answer.

  **Five Ring traps in one afternoon, all silent**: every `func` after
  the first `class` becomes a method; `decimals()` sets and returns
  nothing; `list + [ :key = v ]` appends a nested hash so the property
  vanishes (every label drew as nothing); `1e-6` reads as a variable
  named `1e`; and **`(3-5)^2` is −4** — Ring applies the sign after the
  power — so a sum of squared differences went negative and `sqrt()`
  raised. `pow(x, 2)` answers 4. The library is untouched by the last,
  because its `^` lives inside expression strings the Zig tape
  evaluates; the guard's own re-verification was not.

- **DN7b — one substance, two representations; vectors; Euclid. SHIPPED
  2026-09-04.** Guard §80. What a second and third domain needed, added to
  the Style language: expressions over paths with a few computations over
  shapes (`dist`, `len`, `dot`, `cross`, `midx`/`midy`, `ux`/`uy`,
  `nx`/`ny`); constant and DERIVED properties; `[:field]`; `[:override]`;
  function applications in where-clauses (`u := addV(v, w)`); literal
  selectors (Set `A`); arrowheads; hidden shapes; `disjoint(text, line)`
  as a point-to-segment distance the tape expresses with min and max.

  **The kill, and it is Penrose's central claim.** One `stzMathSubstance`
  INSTANCE — the seven-set tree — handed to two diagrams: `StzEulerStyle()`
  draws nested disks, `StzTreeStyle()` (Penrose's own tree.style, as
  data) draws a name per set and an arrow from each subset to its
  superset. Both lawful, the substance untouched by construction of the
  test, every superset drawn above its subset. That is representation
  swapped without a word of content changing, which is the whole reason
  for the split.

  | scene | unknowns | constraints | rounds | evaluations | ms |
  |---|---|---|---|---|---|
  | the tree, as a tree | 14 | 158 | 2 | 626 | 105 |
  | unit + orthogonal (twoVectorsPerp) | 4 | 87 | 1 | 59 | 41 |
  | u := addV(v, w) | 6 | 85 | 1 | **1** | 37 |
  | a general triangle | 12 | 67 | 2 | 224 | 35 |
  | right isosceles, marked | 12 | 113 | 2 | 266 | 67 |

  **The one evaluation is the point of `override`.** u's arrow ends at
  v.end + w.end — origin by construction; the solver never owned that
  end, so with v and w placed there was nothing left to move, and the
  guard asserts the equality to a millionth of a pixel.

  **Two defects, both scale.** Penrose's `notTooClose` is weight x 10^7
  over the squared distance and mine used the bare weight, so the tree
  style's "align with your parent" won outright and every set collapsed
  onto one vertical line — a picture that was lawful and wrong, which is
  the kind the governor exists for. And names folded to lower case, so
  `Vector u` and `VectorSpace U` were one object; Penrose's names are
  case-sensitive and so is Ring's `=`, and every lookup now is.

- **DN7c — one triangle, three geometries: Penrose's Fig. 1. SHIPPED
  2026-09-05.** Guard §81. `StzSphericalStyle()` and
  `StzHyperbolicStyle()` over the geometry domain, and ONE
  `stzMathSubstance` instance — the right isosceles triangle — handed to
  three diagrams: the plane, the sphere, the Poincaré disk. All three
  lawful, the substance untouched by construction of the test, the
  right angle and the equal sides re-read from the solved coordinates in
  each geometry's own terms.

  | scene | unknowns | constraints | rounds | evaluations | ms |
  |---|---|---|---|---|---|
  | on a sphere | 15 | 45 | 2 | 904 | 48 |
  | in the Poincaré disk | 12 | 42 | 2 | 646 | 50 |

  **THE PLAN WAS WRONG ABOUT WHAT THIS COST, in the cheap direction.** It
  said the styles needed `asin`, `acos` and `atan2` on the tape — an
  engine addition of three opcodes and their adjoints. They did not. A
  point on the sphere is a unit vector held there by one constraint; a
  point in the disk is a pair held inside by one; and every claim the
  domain makes is a POLYNOMIAL in those coordinates once it is phrased on
  dot products: equal length is equal cosine on the sphere and equal
  `delta = |p—q|² / ((1—|p|²)(1—|q|²))` in the disk, both monotone in
  the true distance; a right angle is a zero dot product between the
  geodesics' tangents at the vertex. In the disk the tangent at q is
  perpendicular to q — c for the arc's centre c = N/D, and clearing the
  denominators makes the test `(D₁q — N₁)·(D₂q — N₂) = 0` — which stays
  correct when an arc is a diameter and D is zero. The arcs themselves
  are DRAWN, sampled in Ring at the solved values, because no constraint
  ever needs an arc's interior. No engine change, no rebuild.

  Added to the language for it: `[ :unknown, path, lo, hi ]`, a variable
  the solver owns that is not a shape's property; global paths (`_.sphere`,
  minted once however many points sit on it); and the `:curve` shape,
  `greatarc` or `poincare`, derived entirely from its endpoints.

- **DN7d — Byrne's Euclid I.47, and marks bent to the geometry. SHIPPED
  2026-09-05.** Guard §82. All four pieces the plan named: polygons as
  shapes, Penrose's `delete`, Minkowski separation, and the marks the
  sphere and the disk did not draw.

  | scene | unknowns | constraints | rounds | evaluations | ms |
  |---|---|---|---|---|---|
  | Byrne's Euclid I.47 | 12 | 149 | 1 | 658 | 243 |

  **THE KILL IS A THEOREM THE STYLE NEVER STATES.** Byrne (1847) colours
  each rectangle of the hypotenuse square like the leg square it equals.
  Here the whole figure — three squares, the foot of the altitude, the two
  rectangles — is DERIVED from the three points, so the solver owns six
  numbers and nothing anywhere asserts Euclid's equality. The guard reads
  it back off the drawn polygons: each rectangle equals its leg square, and
  the hypotenuse square is their sum, **to one part in a million**, with
  the two legs deliberately unequal so the identity cannot hold by
  symmetry.

  **The outward normal is written as a direction, not a sign.** A square
  stands on the far side of its edge, which normally needs a sign test the
  tape cannot express well. It is not needed: the outward normal of the
  hypotenuse is the direction from the right-angle vertex to the foot of
  its OWN altitude, and each leg's square stands along the other leg
  reversed, because the angle between them is right. Three sign tests
  dissolved into three directions the figure already contains — the same
  move as DN7c's dot products.

  **A mark is bent by walking the arc, not by drawing on the chord.** Each
  foot of a right-angle mark is rotated about its geodesic's own centre —
  the great circle's pole, or the orthogonal circle's centre — so it lands
  ON the drawn curve. Measured: the feet sit within **0.01px** of the arc,
  where a foot walked along the chord lands **2.1 to 2.25px** off it, which
  is wider than the stroke. Ticks sit at the middle of the arc, across it.

  **Minkowski replaced a bounding circle that was worst where it mattered
  most.** A label used to be kept off a shape by the circle drawn around
  its box, whose radius is the box's half-diagonal — so a WIDE name was
  pushed away by nearly its own half-width in every direction, including
  the vertical, where it is only as tall as a letter. `disjoint` now
  measures the exact signed distance to the box, `|max(q,0)| + min(0,
  max(qx,qy))` for `q = |offset| - halfExtents`; the second term keeps a
  live gradient where the two overlap, which is what lets the solver push
  them apart at all. Measured on a name eight letters wide: its box sits
  exactly against a disk it may not enter, while its bounding circle
  overlaps that disk by **75px** — a lawful picture the old rule refused.

  **THE AUTHOR MARKED THE FIRST PICTURE TWICE, and both marks were about
  precision the eye can see before any measurement does.**

  *The names were an equal radius from their points, which is an unequal
  gap from the ink.* The notch a name sits in is bounded by the two
  squares meeting at that vertex: a quarter turn at the right angle, and
  half a turn less the angle at the other two — so one radius buys a third
  less room at A than at B or C, and A is where the picture is busiest.
  The fix is closed-form. Write the name's centre as `V + a·e1 + b·e2`
  over the two wall directions; its distance to each wall is the other
  coefficient times `sqrt(1-c²)` for `c = e1·e2`; ask each to be the
  clearance plus the box's reach in THAT wall's normal — the support
  function `|nx|·w/2 + |ny|·h/2`, exact for an axis-aligned box — and `a`
  and `b` fall out with no iteration. Measured: the three gaps are
  **10.10, 9.54, 9.54 px**, equal to within half a pixel, against a spread
  of two and a half before. A bisector with a single correction cannot do
  it: the bite differs per WALL, not per notch.

  *The right-angle mark's corner missed the altitude drawn through it.*
  A mark with two EQUAL arms has its corner on the angle's BISECTOR, and
  the altitude from a right angle is not its bisector unless the legs are
  equal — 2.27px out here, wider than the stroke. The corner is now put on
  the altitude at `A + 21·w`, and the arms are what that costs: the legs
  are perpendicular, so `(ub, uc)` is orthonormal and `w` decomposes
  exactly as `(w·ub)ub + (w·uc)uc`. The arms come out 16.4 and 13.2 — equal
  only when the triangle is isosceles, which is the same fact from the
  other side.

  **AND THE FIRST ATTEMPT AT THE FIRST OF THOSE COST 202 SECONDS, which is
  the finding.** Putting the names under `disjoint` constraints against
  the figure's edges collapsed the triangle: twelve label penalties
  outweighed the right angle, and the solver found a collinear basin.
  Writing them as derived positions instead was correct — but the
  placement divided by a root of a dot product of `w`, and `w` was
  defined through the altitude's foot, so every expression built on it
  inherited a division, two subtractions and a square root. Once that
  expression also became the argument of the `disjoint` and `near` the
  Point rule adds, the tape grew past what the solver could work with:
  **243ms to 202 SECONDS**, and it stopped converging. Two changes fixed
  it, both worth keeping: `w` is now the signed area over `lab·lac·lbc`
  (the magnitude of `(B-A)×(C-B)` IS `lab·lac` when the angle at A is
  right, so the quotient is the sign, with no branch), and a name that is
  PLACED carries no constraint of its own into the energy. **Expression
  DEPTH is a cost like any other, and it compounds where a derived value
  becomes an argument.**

  **And one trap, which is the transferable half.** The first version of
  that measurement pulled the name to the disk's CENTRE and pinned its
  height. It deadlocked: at dead centre `abs(dx)` has no gradient, so no
  push could move the name sideways, and the only escape had been pinned
  shut. The picture was reported unlawful by 43px and the constraint was
  correct all along. **An objective whose minimum sits exactly on a
  non-differentiable point of a constraint is a trap, not a preference** —
  give the pull a ring to settle on rather than a point.

- **DN7e — the engine's range: three more domains. SHIPPED 2026-09-05.**
  Guard §83. The author asked for more visual examples, and the useful
  answer was not more set-theory scenes but three domains that stress
  DIFFERENT halves of the engine. Catalogue now 18 pictures.

  | scene | unknowns | constraints | rounds | evaluations | ms |
  |---|---|---|---|---|---|
  | the divisors of 12 (Hasse) | 24 | 156 | 2 | 525 | 98 |
  | the divisors of 36 (Hasse) | 36 | 277 | 2 | 936 | 259 |
  | a commuting square | 16 | 122 | 1 | 43 | 97 |
  | a commuting triangle | 12 | 91 | 1 | 84 | 66 |
  | Thales | 15 | 115 | 2 | 911 | 59 |

  **ORDER THEORY is the opposite end of the engine from Byrne.** A partial
  order has no coordinates to be faithful to, so a Hasse diagram is pure
  LAYOUT — the only forced fact is that x sits above y when x covers y, and
  every other rule exists to make the picture readable. Where Byrne's
  figure had six free numbers and everything else derived, this has two per
  node and nothing derived at all. `StzOrderDomain` makes a covering an
  OBJECT rather than a predicate, for the reason a Segment is one: a rule
  mints one shape per match, and an element covers several others, so the
  edge needs a name to be minted under.

  **CATEGORY THEORY is the case where the layout IS the content.** A
  commuting square is not an illustration of an equation, it is how the
  equation is written, so `StzCommutativeStyle` states the grid as
  constraints (`a` and `b` share a row, `a` and `c` share a column) and
  lets the solver place it. Arrows stop clear of both names by deriving
  their ends from the direction, and an arrow's own name is PLACED off the
  midpoint along the normal — costing the solver nothing, which is the
  lesson DN7d paid for.

  **THALES IS BYRNE'S KILL AGAIN, in one line of substance.** The content
  says B and C are on the circle, BC runs through its centre, and A is on
  the circle. It never says the angle at A is right. Every position the
  solver may choose for A gives a right angle, so the mark the style draws
  is a claim about the picture the picture was never asked to satisfy —
  measured back at **cos = −0.00**, and the guard also asserts the
  substance contains no `Right` at all, so the reading cannot be a
  tautology.

  **AND A LAWFUL PICTURE IS NOT A READABLE ONE.** Nothing in the engine
  forbids two edges from crossing, and it shows: **7 of 10 seeds** draw the
  divisors of 12 without a crossing, but only **1 of 12** draws the
  divisors of 36 clean. Choosing the seed is what Penrose's variations are
  for and it is honest, but the odds fall as the lattice grows — which is
  an argument for a crossing term, recorded here rather than built now.
  The guard pins the chosen variation at zero crossings AND asserts that
  another seed does cross, so the check cannot pass by being vacuous.

- **DN7f — the Penrose gallery as the yardstick. SHIPPED 2026-09-05.**
  Guard §84. The author pointed at Penrose's own example gallery — some
  sixty diagrams — and asked that they be tried, so that the
  implementation is measured against the thing it was modelled on rather
  than against its own catalogue. Triage first, then the largest family
  built, then a limit found and measured.

  **THE TRIAGE, so the next session does not redo it.** Read from the
  gallery's titles and thumbnails; "runs" means the machinery exists, not
  that a scene has been written, except where marked rendered.

  | class | examples | what it needs |
  |---|---|---|
  | **runs on the engine as it stands** (~27) | Sets as Euler *(rendered)*, SIGGRAPH Euclidean teaser *(rendered)*, Circle example *(rendered, as Thales)*, Box-arrow architecture *(rendered)*, Word cloud *(rendered)*, Network with one-way links *(rendered)*, Hypercube *(rendered, Q3)*, Hamiltonian cycle *(rendered)*, Dodecahedral graph *(rendered — see the limit)*, Continuous map, Hypergraph, Cayley graph, Caffeine / methane molecules, Hexagonal lattice, Lagrange bases, Random sampling, Linear regression, Planets, Persistent homology, Half adder, Cotan formula, Concyclic edge flip, Wedge product, Matrix-matrix multiplication, Sets in 2.5D (flat), Quaternion table (uncoloured) | a substance and a style each; nothing new in the engine |
  | **one feature away** (~6) | Catmull-Rom interpolation, Blobs, Curved graph with dots, Nephroid envelope → *spline paths*; Ellipse rays → *ellipses*; Fancy text + equations → *TeX*; Quaternion table coloured → *a colour channel from substance data* | one shape or one channel each |
  | **outside a constraint solver** (~24) | Two 3D triangles, 3D reflections, Walk on spheres, Möbius strip, Viewport, Impossible polygons → *a 3D camera*; Chaos game, Iterated function system, Lyapunov, Brownian motion ×2 → *iteration, not optimisation*; Ray casting, Next-event estimation, Walk on stars ×2, Geometric / closest-point queries → *computed rays and loops in Style*; Insertion sort → *a trace, not a layout* | Penrose does these with loops and a projection in Style; this engine has neither, by design |

  **What was built: the graph family**, the gallery's largest.
  `StzGraphDomain` (Vertex, Edge, Arc, Highlighted), `StzGraphStyle`
  (node-link, hard rules), `StzSpringGraphStyle` (the same rules soft),
  `StzBoxArrowStyle` (the same domain as boxes and arrows), and
  `StzWordDomain` + `StzWordCloudStyle`. Two engine changes came out of it,
  both general:

  **THE MATCHER WAS THE COST, NOT THE SOLVER.** On the dodecahedron the
  first compile was **18.0 seconds against a 0.65-second solve.** A clause
  `e := Edge(a, b)` was a FILTER over every binding of e, a and b — and
  with one more variable in the selector, 240,000 candidates each tested
  against the substance. It is a GENERATOR: the substance holds thirty
  definitions of Edge, and each binds three variables in one step. The same
  graph enumerates 600 candidates now; compile **1.8 s**, a tenth.

  **AND THE CROSSING TERM DN7e OWED — built, and found mostly inert.**
  `notCrossing(a, b, pad, weight)` over two segments: signed distances of
  each segment's ends from the other's line, crossing exactly when both
  products are negative, the violation the smaller magnitude plus a
  margin, zero everywhere the segments are clear. The selector that
  applies it, `Edge e; Edge f; Vertex a; Vertex b; Vertex c; Vertex d
  where e := Edge(a, b); f := Edge(c, d)`, reaches exactly the pairs
  sharing no vertex, because the matcher binds distinct objects to
  distinct variables — adjacent edges meet at their vertex by right and
  are never asked. Two measurements, both the kind that change what the
  next session does:

  *Its first form did not terminate.* Rooting the product back to pixels
  gave `sqrt(x + ε)`, whose slope at the instant a crossing begins is
  1/(2√ε) = 500 — a cliff the line search fell off on every round while
  the penalty weight multiplied it. A seven-vertex network that solved in
  2 s did not finish in ten minutes. A ramp with a bounded slope solves it
  in 3.6 s and the picture cannot tell the difference. **A term's shape at
  its own boundary is part of its cost.**

  *And as a hard rule it is not solvable; as a preference it barely
  steers.* Ensured, it leaves 25 constraints open on the cube from a
  random start and 2 on the network. Encouraged, the picture's crossing
  count is **identical seed by seed at weight 1 and at weight 25**, and at
  the solution the 84 crossing terms of the cube still hold 10,138 energy
  units that the solver cannot spend: from a random start every way out of
  a crossing passes through the separation penalties, so **the seed
  decides the basin and the weight only its depth.** The network reaches
  1 crossing on its best seed of six; the cube, which is planar, 7.

  **THE LIMIT, measured and kept.** The dodecahedral graph — twenty
  vertices, thirty edges, planar — from a random start: the hard style
  leaves 79 constraints open, worst 32.7 px; the soft style is lawful by
  construction and settles at **17 crossings on its best seed of eight**
  (range 17–55). Neither is a picture of a dodecahedron, and the cube
  above says the same thing at eight vertices. A local optimiser does not
  find a planar embedding it was not started near, and no term changes
  the class of that problem — the fix, if one is wanted, is a planar
  *initialisation* (Tutte's embedding from a face, or a layered start from
  a spanning tree), not more energy. Scenes 19 and 23 stay in the
  catalogue as this finding, labelled as such.

  Two small things the yardstick also caught: an object named `000` broke
  three layers down because the expression rewriter reads a leading digit
  as a number — `Declare` refuses such a name now, with the rule stated;
  and `_Initialise` indexed the name map by tape slot, which diverge after
  a `delete` — found the first time a word cloud re-minted a text larger.

- **DN7g — the planar start: Tutte from a face found by its shape. SHIPPED
  2026-09-06.** Guard §85. DN7f measured that the basin is chosen before
  the first gradient step; so the start is chosen. A style declares
  `StartPlanar("Vertex", "icon", ["Edge", "Arc"])` — which objects are
  vertices, which shape's centre carries them, which constructors are
  edges — and the diagram seeds those centres by Tutte's embedding: one
  face on a convex polygon, every other vertex at the barycentre of its
  neighbours (four hundred Gauss–Seidel sweeps; no linear algebra). The
  face needs no planarity test: in a 3-connected planar graph a face
  boundary is exactly a cycle that is **chordless and non-separating**,
  and the shortest such cycle through any edge is taken. A drawing that
  collapses — two vertices within four pixels: a tree, a cut vertex — is
  refused and the random start stands; `StartedPlanar()` and `OuterFace()`
  say which happened.

  | scene | start | crossings before | crossings after | ms |
  |---|---|---|---|---|
  | the cube Q3 | face of 4 | 7 (best of 6 seeds) | **0** | 611 |
  | the dodecahedron | face of 5 | 17 (best of 8) | **0** | 4,687 |
  | the network (not 3-connected) | fell back | 1 | 1 | — |

  **The start alone was not enough, and what it took to keep it is the
  finding.** Three things threw a planar start away before the picture was
  drawn, each measured, each repaired:

  *At the usual opening weight the objectives outrank the rules.* Round
  one at λ = 10³ let the repulsion between Tutte's cramped inner vertices
  push them through edges while the vertex-off-edge rule was still weak;
  later rounds enforced every rule inside the crossed basin they inherited
  — nine crossings on a cube that began with none. A planar start now opens
  at λ = 10⁵. **A good start deserves a strict solver from round one.**

  *A name held off an edge pulls on the edge's ends.* `disjoint(text,
  edge)` has a gradient on the edge's endpoints, and at a strict weight
  eight names threw the cube away to make room for themselves — 22 label
  violations at the start, every shape violation under half a pixel. The
  node-link style now declares `SolveLabelsAfter()`: the first stage sees
  no label term and no label variable, and the names find their room
  against frozen shapes. The Euler style must NOT declare it — a set has
  to be large enough for its name — and the guard asserts both.

  *And freezing the shapes for that label stage was quadratic.* `_Frozen`
  rewrote the whole energy text once per frozen variable, building each
  rewrite a character at a time, and Ring reallocates on every append: a
  half-megabyte energy with sixteen frozen variables took **706 seconds**.
  One tokenising pass with chunked output does it in under a second.

  **And the crossing term changed class.** DN7f found it inert from a
  random start — a barrier is useless to a solver outside it. From a planar
  start it is exactly a barrier: never violated at the start, forbidding
  every move that would cross. So `notCrossing` is a *rule* again in the
  graph styles, and the diagram folds it into the objectives as advice when
  the start was not planar — a rule you cannot begin inside is not a rule.
  With soft separation and this one hard barrier, the spring style holds
  twenty vertices planar; the hard node-link style, whose separation rules
  shove a cramped interior at 10⁵, does not (10 crossings, 37 s) and keeps
  the small labelled graphs.

  Two smaller repairs the pictures forced: a name that finds no room by
  its own dot must be a **violation, never a relocation** — the cube's
  inner names had been placed beside the *outer* dots, lawfully, and read
  as the wrong labels; a leash of `22 + w/2` from the dot now refuses that.
  And the paper gained a **margin** (`SetMargin`): a style whose vertices
  repel pushed the dodecahedron's outer face onto all four edges of the
  canvas, since the on-canvas rule sat at zero.

- **DN7h — splines: blobs, a curved graph, Catmull-Rom. SHIPPED
  2026-09-06.** Guard §86. The largest of the gallery's one-feature gaps,
  closed with one shape: `:spline`, n control points open or closed,
  drawn by **centripetal Catmull-Rom** sampling at the solved values —
  the parametrisation that interpolates every control point and never
  cusps between two of them however they are spaced. The same law as
  `curve` and `poly`: a constraint speaks to the points, never to the
  drawn curve. Catalogue 26.

  | scene | unknowns | constraints | rounds | ms |
  |---|---|---|---|---|
  | the seven-set tree as blobs | 91 | 365 | 2 | 206 |
  | the cube, edges curved | 32 | 956 | 8 | 7,033 |
  | Catmull-Rom through six points | 24 | 254 | 3 | 245 |

  **Blobs are the third reading of one substance.** Scenes 02, 06 and 24
  are the same seven sets: disks, a tree, and now wobbly closed splines.
  Each blob is eight control points at its own radius, the eight wobbles
  being UNKNOWNS in a narrow range that the solver leaves where the seed
  put them — so every seed is a different blob. Containment and
  separation are solved on a hidden circle padded by the wobble it must
  cover, and the guard checks them on what is **drawn**: every sample of a
  child's curve inside its parent's polygon, no sample of a disjoint pair
  inside the other, no two curves crossing.

  **A range on an unknown is where it STARTS, not where it may go.** The
  first blobs grew tendrils twice the canvas. The wobbles had `[-0.12,
  0.12]` at initialisation only; the spline's points are derived from
  them, the on-canvas rule reaches those points, and so the solver moved
  the wobbles with nothing in the energy holding them. `[:unknown, path,
  lo, hi]` says where a variable begins; a bound is a constraint, and is
  written as one.

  **A name avoids what is DRAWN.** In the curved graph the straight chord
  stays, hidden, as the segment the rules speak to; the arc through its
  ends and a point bulged off its middle is what is drawn. A rule cannot
  see a spline, but it can see the polygon the spline was drawn through —
  the arc's two half-chords, hidden — and a name held off both halves is
  held off the arc. Holding it off the *invisible* chord as well was what
  left two names 3.8 px short: three forbidden lines per edge at a
  degree-three vertex leaves no wedge.

  **And the freeze had a second quadratic.** DN7g made `_Frozen` one pass;
  it still read each symbol's digits with a slice of the whole energy
  text, and a slice is O(position) — the engine's own trap, on record
  since the graph plane. Thousands of slices across a megabyte is minutes:
  the curved cube did not finish in ten. The digits are gathered as the
  walk passes them now. The network's smaller energy had hidden it.

- **DN7i — ellipses: sets in 2.5D, and the rays of an ellipse. SHIPPED
  2026-09-06.** Guard §87. The `:ellipse` shape — a centre and two radii,
  axis-aligned. **To a constraint it is its bounding box**: exact for a
  label inside it, conservative for everything else, and the two styles
  that use it never put an ellipse in a constraint at all. Catalogue 28.

  | scene | unknowns | constraints | rounds | ms |
  |---|---|---|---|---|
  | the seven-set tree in 2.5D | 35 | 169 | 1 | 96 |
  | an ellipse and six rays | 6 | 138 | 2 | 113 |

  **2.5D is the tree's FOURTH reading, and it costs no ellipse
  reasoning.** Disks, a tree, blobs, and now flattened disks with a shadow
  under each: the diagram is solved as disks exactly as the Euler style
  solves it, and drawn as their image under one affine map — y flattened
  to 0.55 about a horizontal axis. An affine map preserves containment
  and disjointness, so every relation the disks satisfied the ellipses
  satisfy too; the guard checks it on the drawn rims and asserts the one
  fact that makes the argument valid, that every ellipse is flattened by
  the same factor. The one thing the map does not flatten is the NAME, so
  the disk is held large enough that the name still fits the short axis,
  and other disks are held off a box the name would need in disk space.

  **The rays are Byrne's kill for a conic.** An ellipse, its two foci at
  ±√(rx²−ry²), and six rays that leave one focus, meet the curve at a
  parameter the solver owns, and go on to the other focus. The substance
  states none of the optics and the guard asserts that no rule names a
  focus. Read back from the solved picture: **|F1P| + |PF2| = 2a to
  0.00 px on every hit, and the ray in and the ray out make the same
  angle with the tangent to 0.00** — the string property and the
  reflection law, neither asserted, both true because the point is on
  the curve and the foci are where the foci are. And each ray's parameter
  is bounded in the energy, not only at its start — DN7h's lesson, applied
  the same day.

- **DN7j — a colour channel from substance data. SHIPPED 2026-09-06.**
  Guard §88. The last of the gallery's one-feature gaps. Two additions,
  both small: a substance may put a NUMBER on an object —
  `SetData(object, key, value)` — and any Style expression reads it as
  `x.key`; and a fill or stroke may be a RULE over such an expression,
  `[:ramp, expr, lo, hi, colourA, colourB]` or `[:palette, expr,
  [colours]]`, resolved at draw time through the same tape a position is.
  `FillOf(path)` reads the resolved colour back. Catalogue 30.

  | scene | shapes | unknowns | evaluations | ms |
  |---|---|---|---|---|
  | the quaternion table, 8×8 | 144 | 160, none referenced | **1** | 512 |
  | A·B = C as a heat map | 71 | 76, none referenced | **1** | 186 |

  **A table is a diagram with nothing to solve, and the engine says so.**
  A cell IS its row, its column and its value; those are data, the cell's
  position is an expression over them, and its colour is a rule over
  them. Both scenes are lawful in a single evaluation. Penrose's
  Substance carries no numbers, and for a set or a point that is right —
  the content is the relation, not the coordinate. A table is the case
  where the number *is* the content.

  **The quaternion table is read back as mathematics, not as pixels.**
  The guard checks every row is a permutation of the eight elements — a
  Latin square, the group's cancellation law — and recomputes all 64
  products by an independent method (quaternions as 4-vectors) against
  the cell data; i·j = k and j·i = −k wear different colours because they
  are different elements. The heat map's C is recomputed from A's and
  B's cell data; its hottest cell wears the ramp's hot end, found from
  the data rather than named by hand — the first guess at which cell
  that was, was wrong, which is the argument for computing it.

## DN8 — ONE CONTENT, ONE READING, ONE GATE: unify the two planes by making each strengthen the other (planned 2026-09-06, SHIPPED 2026-09-07 as DN8a through DN8h, all eight closed)

The Principal asked, after DN7j was met, whether the foundational
mathematical-diagram models were covered and what the library's own
design adds. The assessment (memo of 2026-09-06) found the Penrose model
whole, the construction model whole under the name DERIVED, graph layout
in part, and four algorithmic gaps: polygon distances, planarity beyond
Tutte, a local optimiser only, and no iteration in a Style. And it found
the added value largest where it is not yet built: **the library holds two
content-to-reading systems side by side** — `stzGraph` + notation profile
+ five layouts + governor + rule gate on one side, Substance + Style +
solver on the other — and a colour doctrine with the right three laws
that no math style yet speaks.

**The thesis of this plane: every unifying step must also be a
strengthening step, or it is not taken.** The graph plane's layouts are
what the solver lacks — a good basin chosen by structure, not by seed. The
solver's constraints are what the graph plane lacks — exact clearances,
names off ink, marks bent to geometry. The colour system is what both
lack. So the join is not a refactor; it is the shortest path to closing
the four gaps.

**Refused, before the first item:** no rewrite of either system; no DSL;
no 3D; no loops in a Style — iteration is CONTENT, and a substance may
carry five thousand objects already (the quaternion table proved the
path); no "framework" layer above both. Adapters and starts, measured.

### The items, in the order of leverage

- **DN8a — A substance is a graph, and a graph is a substance. SHIPPED
  2026-09-06.** Guard §89, 17 assertions. `ToGraph()` and
  `ToGraphXT([:projectConstructors = ...])` on the substance;
  `StzSubstanceFromGraph(graph, domain, opts)` the other way. **Where an
  edge will not do, a node**: stzGraph is a SIMPLE graph and its own
  refusal names the remedy, so a second relation on one pair and any
  relation of three or more arguments are reified as a relation node with
  one positioned edge per argument — the contradiction of scene 5 is
  three nodes and three edges and holds both ways back. **Projection** is
  what the layouts will want: a graph-domain substance's Edge objects
  become plain edges (the cube: 8 nodes, 12 edges, and the same 12
  definitions with all 8 Highlighted marks on the way back), where without
  it the cube is twenty nodes. **A foreign graph** says what its nodes and
  edges are through the caller — `[:nodeType, :edgeConstructor |
  :edgePredicate]` — and the graph plane's own org chart, never a
  substance, is scene 31: six Vertex objects, five Arc objects, the titles
  as labels, drawn by the box-and-arrow style. Two things the join taught:
  stzGraph folds node ids to lower case where a substance's names are
  case-sensitive (DN7b), so the true name rides as a property and two
  names differing only by case are refused with the reason; and a foreign
  node's own `:type` — an org chart's "box" — is the drawing's word, not a
  domain's, and yields to the caller's when the domain does not know it.
  The original text of the item follows.

  *It said:* A substance is a graph, and a graph is a substance.
  `stzMathSubstance.ToGraph()`: objects become nodes carrying their type
  and data, predicates become typed edges (a hyperedge for arity above
  two), definitions become edges from result to argument, labels ride as
  attributes. `StzSubstanceFromGraph(oGraph, oDomain)` the other way, with
  the domain doing the typechecking a substance always did. **Kill:** the
  seven-set tree round-trips with nothing missing — counts, relations, data —
  and the graph plane's own org-chart fixture, turned into a substance,
  draws under a Style. Cheap, and everything below stands on it.

- **DN8b — Layouts as starts, and the end of seed-picking. SHIPPED
  2026-09-06.** Guard §90, 13 assertions. `StartLayout(mode, type, shape,
  ctors)` and `StartTrying([modes...], ...)` on a Style; the modes are the
  graph plane's own — hierarchical, ring, force, mesh, sequence — plus
  planar and random. The solver compiles its tapes once and takes the
  starts in order; the first that ends lawful is the picture; a start the
  graph cannot give (planar on a tree) is skipped, not replaced; random is
  the last resort whether named or not. `StartsTried()` and `StartUsed()`
  report the figures. **The kill, against the numbers on record:** the
  divisors of 12 and of 36 from a hierarchical start — first try, lawful,
  zero crossings, on any seed (four tried for the 36-lattice, where one of
  twelve managed it before), and the same style with its starts cleared
  still crosses on the seed that crossed. The org chart, DN8a's witness, is
  fixed the same way: hierarchical, one try, no crossing, every report
  below its superior. **What measured false:** the plan expected the
  dodecahedron lawful under the HARD style from the planar start now that
  the label stage is separate. It is not: Tutte's inner faces are too tight
  for 26 px separations and 90 px edges, and after 16 rounds 31 separations
  and 4 lengths stay open while planarity is lost. The soft style keeps it —
  planar start, lawful, zero crossings — and the hard-style result is
  recorded, not kept. **And one honesty the multi-start forced:** when a
  random start wins, the crossing rule was advice (DN7g's decision), so a
  picture reported lawful now also reports how many crossing rules it left
  unmet, in `Why()` and in `AdvisoryUnmet()`. The layout graph is built
  from the substance directly and not through ToGraph, because a reified
  relation — a SameRank — would become a node and a rank the layout would
  honour. The original text of the item follows.

  *It said:* Layouts as starts, and the end of seed-picking. The planar
  start generalised: `StartLayout(:Hierarchical | :Ring | :Force |
  :Mesh)` on a Style, computed by the graph plane's own engines on the
  substance's graph and overlaid as the solver's start. Multi-start
  becomes the SET of layouts plus random, first lawful wins, and the
  number of starts tried is a reported figure. **Kill, against the numbers
  on record:** the divisors of 12 and of 36 lawful with zero crossings from
  a hierarchical start with no seed chosen — against 7 of 10 and 1 of 12
  by seed — and the dodecahedron from the planar start under the HARD
  style, which the label stage now permits. This is the "local optimiser
  only" gap met by structure rather than by annealing. **Risk, named:**
  a start can fight the constraints it is handed to, as the labels fought
  the cube; the answer is per-style measurement and the labels-after
  knob, not a weight.

- **DN8c — One gate. SHIPPED 2026-09-06.** Guard §91. `StzCheckPictures(pictures)`
  takes every picture of both catalogues, sends each to the governance its
  class is drawn by — a notation picture to the plastic rules, a
  mathematical one to `StzMathRuleSet()` — ingests every math diagram's
  own `Violations()` beside, and returns one `stzRuleReport`, printing
  how many pictures it judged, because zero findings over zero pictures
  is the condition a silent gate hides in. **The math rules are the
  visual contract for a picture the solver made**, as scoped rules with
  subjects and counter-subjects: `name_off_ink`, `name_off_name`,
  `dot_above_figure`, `on_paper`. **The first run found 27 things**, and
  22 were real: fifteen Hasse names sat on edges run centre-to-centre and
  hidden only by painting order; two vector names sat on the space's
  axes because they were placed at 1.16 of the arrow; a name touched a
  right-angle mark; three names touched a spline whose chords alone were
  fenced; an arrow tip stood 0.15 px from a letter. Each was a style row
  and each is fixed; the five that remain are the contradiction's, kept —
  the gate is not sound *because* scene 5 is a finding. **The pair rule's
  boundary was unwitnessed** — no picture held an empty name beside a
  real one — and the corpus now carries a witness rather than the rule a
  weaker counter. **And the gate cost 101 seconds on the first run**
  because every read of a shape's value compiled a tape and the ink rule
  read every shape per name — 46,000 compiles on the quaternion table
  alone; values and ink are remembered per solve now, `Touch()` forgets
  them for a guard that moves a value by hand. The plan-of-record check
  already covered the graph plane's items, since the plan is one file. The
  original text of the item follows.

  *It said:* One gate. `Violations()` already speaks the rule shape;
  route it into `stzRuleReport` beside the graph plane's three engines,
  and run the governor's visual contract — names off ink, clearances,
  dots above the figure, nothing off the paper — over the math catalogue
  as it runs over the notation catalogue. **Kill:** one `StzCheckPictures()`
  over both catalogues, printing pictures judged and findings found, and
  the plan-of-record check extended to the graph plane's own items.

- **DN8d — Colour as meaning. SHIPPED 2026-09-06.** Guard §92. A style
  names a theme (`SetTheme`) and writes ROLES — `:primary` for the one
  accent, `:neutral` for ink, `:muted` for secondary ink, `:background`
  for the paper — and the theme decides what each is; two new colour
  rules carry the rest: `[:alpha, colour, a]` for a surface (the accent at
  a fifth over whatever the paper is, which is what keeps a fill right
  under dark), and `[:on, path | "paper"]` for a name's colour — the best
  of black and white on what it sits in, MEASURED, never a literal. A
  name given no colour takes the best on the paper. **The ramp is
  perceptual now**: the engine exports `stz_color_mix_oklab`, a straight
  line in Oklab clamped to gamut, and the DN7j ramp interpolates through
  it — the sRGB midpoint it used to pin is the negative sibling. **Nineteen
  structural styles carry no hex literal**; the two content styles carry
  exactly Byrne's plate and the quaternion table's eight, fourteen, kept
  as the content they are — a theme governs surface, ink and accent, not
  what a picture is about. **Every picture under both themes, every name
  measured**: under light and dark alike, no name falls under 3:1 against
  the fill that holds it, composited over the paper — 31 pictures, some
  hundreds of names, no second solve since a theme changes no geometry.
  The catalogue renders a dark twin of every picture. One library bug the
  roles exposed: a region test string-added a fill *prop*, and a fill that
  is a rule is a list. The original text of the item follows.

  *It said:* Colour as meaning. Every math style speaks roles —
  `:fill = :Accent`, `:stroke = :Line` — and never a hex; labels take
  `StzContrastingText` so the picture decides what can be read; the ramp
  and palette rules route through the colour system's PERCEPTUAL ramp,
  which retires the sRGB interpolation DN7j introduced — the very defect
  the colour plan measured (a ramp that zigzags in luminance). **Kill:** all
  30 pictures rendered under two themes with every label's contrast
  passing the governor, and the count of raw hex literals in the math
  styles at zero. Waits on the colour plan's own perceptual ramp landing;
  costs one afternoon after it.

- **DN8e — Polygon distances. SHIPPED 2026-09-06.** Guard §93. A convex
  polygon is its vertices to a constraint now. `contains(poly, text |
  circle)` is the largest signed distance from the four corners — or the
  centre plus r — to the edges' lines, turned by the polygon's own winding
  read off its area, which is exact for a convex outline; `disjoint(text |
  circle, poly)` is the smallest gap to any edge as a segment, with the
  centre held outside so a name that fell in cannot read as clear of every
  edge. Two polygons against each other, and `contains(thing, poly)`, are
  refused with the reason. **The picture the bounding box could not
  draw**: Byrne's plate with a², b², c² solved inside its three rotated
  squares, twelve corners inside by an independent test, and a corner of
  the square's bounding box lying on the paper where the square is not.
  **And the join the item was named for**: the graph plane's simplest
  DRAKON scene rendered, its icons read back as rectangles and carried as
  data, and a formula the substance says is `Inside` the action icon
  solved there by the polygon's edges, off the icon's own name — scene 32.
  **Two costs, one paid and one measured.** The labels dragged the
  triangle collinear at first, DN7d's failure again — `contains` has a
  gradient on the square's vertices, which are the triangle's points — and
  Byrne now solves its labels after its shapes, against frozen squares.
  And the formula stopped straddling the icon's top edge, a stalemate
  between "inside" and "off the name" with the room below reachable only
  through the name's penalty hill: **a contained name now starts at its
  container's centre** — DN8b's principle, for a label. **Measured and not
  cured**: one `contains(poly, text)` term over derived vertices is
  **41,509 characters**, because a derived vertex re-expands at every
  mention and the winding sign at every edge. The cure is a tape that can
  bind a subexpression once, and it is the engine item DN8 owes next —
  the same cause as DN7d's 202 seconds, and every energy string this
  plane compiles. Original text follows.

  *It said:* Polygon distances. The signed distance from a point to a
  convex polygon on the tape — the max over edges of the signed edge
  distance — and, for a spline or a non-convex outline, the distance to
  its convex hull or a convex decomposition. Then `contains(text, poly)`
  and `disjoint(poly, poly)` exist, Byrne's names are held off the SQUARES
  and not off hidden walls, and — the unifying half — a notation's icon
  (a DRAKON shape, an org box) becomes something a math rule can hold a
  label off. **Kill:** the Byrne figure with its walls deleted and the
  same clearances; a DRAKON icon holding a formula's label. **Risk:** tape
  size — DN7d's 202 seconds are the standing warning; the expression per
  polygon edge is measured before the second polygon is added.

- **DN8f — Content generators, and the scale they expose.** **SHIPPED**
  2026-09-06. `DeclareMany(type, prefix, n)` and `SetDataFrom(prefix, key,
  list)` on the substance; a dot domain (Dot, Ring, Step := Step(Dot,
  Dot)) and its style; three gallery pictures that were "outside the
  engine" and are content: the chaos game's Sierpinski triangle (5,000
  dots), the nephroid as an envelope (180 circles tangent to a diameter),
  three Brownian walks (3,000 steps, each a definition). Nothing is solved
  in any of them, and the picture is the substance drawn.

  *What the scale exposed, measured before and after on the 5,000 dots:*

  | stage | before | after |
  |---|---|---|
  | substance build | 22.4 s | 0.65 s |
  | compile (5,000 shapes) | 237.7 s, 20,000 constraints | 2.3 s, 0 constraints |
  | solve | 0.15 s | 0 |
  | draw | not finished at 10 min | 9.2 s, of which 2.5 s is the PNG raster |

  Every table keyed by a name — objects, data, definitions, shapes,
  constants, derived names, unknowns, text sizes, the value cache, the
  matcher's candidate lists — was a linear scan, squared at five thousand.
  Each has a Ring hash list beside it now (measured: 30,000 keys, 12 ms for
  30,000 lookups; case-marked keys, since Ring's hash list folds case), a
  plain member that copies with its object. The 20,000 constraints were
  `onCanvas` on shapes whose every coordinate is a constant: a tape that
  evaluates to a number, kept only when a term mentions an unknown now.
  A shape that keeps none is checked in Ring at compile, once, and a datum
  that puts it off the paper is reported as a violation like any other,
  because the content can be wrong where the solver cannot help; the
  guard puts a dot 300 px past the edge and reads the report. The draw's whole cost was an
  engine tape compile per derived coordinate to read a number back; a
  coordinate that is a datum is read as the datum. Roles resolve once per
  theme per draw, not once per shape. **Kill met:** 5,000 points drawn and
  timed; matcher and minter at that count. *Not cured, named:* the minter
  is 0.36 ms a shape — property scans and head rewriting — and the PNG
  raster is the canvas's.

  *Guard:* §94, DN8f.

- **DN8g — The live figure.** **SHIPPED** 2026-09-06. `DragTo(path, x, y)`
  puts a shape's free centre where the author released it, holds it there
  while the figure re-solves around it, and lets it go; `Pin` / `Unpin` /
  `UnpinAll` / `IsPinned` / `Pins` hold any free property through any
  solve; `Relayout()` re-solves warm from the current values with no
  start drawn; `PickAt`, `Draggable`, and the plastic editor's three verbs
  `OnPress` / `OnMove` / `OnRelease` with `DragPreview()` — a move previews
  and re-solves nothing, the release is the one drag. `SolveProfile()`
  says where a solve's time went. `StartUsed()` answers "warm".

  *The kill, measured:* Byrne's figure with A dragged sixty pixels
  re-solves in 27 ms (296 ms on the first warm solve), two rounds, the
  angle at A reading cos 0.00 and every area name back inside its square.

  *What the 100 ms budget exposed, none of it a new algorithm:*

  | cost | before | after |
  |---|---|---|
  | label-stage energy text | 586,494 chars, values substituted by a walk (~1.3 s) | 42,784 chars: a frozen unknown is its value and a settled derived name its NUMBER at generation (`_Sym` under the fold) |
  | text per round | regenerated every round | built once per frozen set; only λ, a prefix, moves |
  | on-canvas rows under the fold | each row rebuilt its shape's whole list | one list per shape per set |
  | shape stage under labels-after | judged by every violation, climbed all 7 rungs, cold and warm | judged by its own terms: 2 rounds |
  | a pin in the shape stage | regenerated the stage, materialising every derived vertex (47 ms) | substituted into the stored text by eight exact engine replaces, one per byte that can follow a symbol (under 1 ms) |
  | warm opening weight | λ = 1,000 | λ = 100,000, the planar start's rule: a good start deserves a strict solver |
  | a derived expression | walked character by character at every expansion, two method calls a character | tokenised once per compile, assembled from tokens |
  | the case-marked key | a character walk on every name lookup, 7 of its 8 µs | memoised by the name, exact spelling checked on the hit |

  The cold Byrne solve went 1,536 ms → 382 ms from the same changes. The
  fold is the engine item DN8e owed, paid on the Ring side: a subexpression
  is bound once because it is evaluated once.

  *Guard:* §95, DN8g.

- **DN8h — The tape binds a subexpression once.** **SHIPPED** 2026-09-06.
  The engine item DN8e named and DN8g paid only half of, on the Ring side.
  `autodiff.zig` hash-conses at emit: a node is looked up by its identity —
  opcode, constant bits, operand indices — and an identical one already on
  the tape is returned instead of a second copy. Zero caller change, and
  every consumer of the tape gets it: the math plane, `stzMathFunction`,
  `stzObjective`, `stzOptimExpr`. `StzEngineGradNodes(handle)` reports how
  big a tape is, because a generator cannot see that from the text it
  wrote.

  | | before | after |
  |---|---|---|
  | Byrne's longest term, 90,397 chars | 28,945 nodes | **208 nodes**, 139x |
  | Byrne's whole energy, 273,710 chars | 87,345 nodes | **1,320 nodes**, 66x |
  | one evaluation of the longest term | 0.060 ms | **0.0014 ms** |
  | dodecahedron, minimise | 784 ms | **130 ms** |
  | cube graph, minimise | 195 ms | **58 ms** |
  | word cloud, minimise | 76 ms | **48 ms** |
  | Byrne, minimise | 17 ms | **1 ms** |

  *The measurement that redirected the item.* The plan had assumed the cure
  was a `let` binding in the grammar, so the generated TEXT would shrink.
  Measured first: the engine parses those 90,397 characters in 0.66 ms and
  all 174 of Byrne's violation tapes in 2.5 ms. Text size was never the
  engine's cost. What cost was that every evaluation walked a tape carrying
  hundreds of copies of one subtree — twenty-nine thousand nodes where two
  hundred say the same thing — so the fix belonged at emit, not in the
  grammar, and needed no caller to change a line.

  *What sharing does change, stated rather than hidden.* The value is
  bit-exact: a shared node performs the same operation on the same
  operands. **The gradient is not, and cannot be.** Where a subexpression
  is used n times, sharing sums its n adjoint contributions first and
  pushes the total through the subtree once; separate copies push each
  through and sum at the variable. Same arithmetic, different order,
  measured at one to two ULP. Fewer roundings is if anything the more
  accurate, but it is not identical, and the tape's own test says so with
  a switch that compiles both ways. Identity is exact and structural:
  `a+b` and `b+a` stay two nodes, because normalising them would move
  which argument `min` and `max` hand the gradient to at a tie, and this
  file promises that tie goes to the argument written first.

  *And what that ULP exposed, which is the real finding.* One ULP flipped
  the curved cube from lawful to unlawful. It was not a regression in the
  tape: the picture was lawful by one name's random start wedge. Measured
  across six seeds on the OLD engine: four lawful, and only two keeping
  the planar start. A name cannot cross an edge once the label stage runs,
  so its wedge decides — and the three initial draws choose between whole
  starts by INITIAL energy, which barely moves when a name rotates about
  its own vertex. The wedge was, in effect, unchosen. So when the shapes
  are lawful and only the names are not, the shapes are now KEPT and the
  names redrawn into fresh wedges, and the cheap label stage runs again
  before the whole start is abandoned. The same six seeds: **six lawful,
  five keeping the planar start.** A start is no longer thrown away over
  one name's bad draw.

  *Guard:* §96, DN8h.

## DN10 — NOTATION IN A LABEL: the last cell of the gallery triage (2026-09-08)

**SHIPPED** 2026-09-08.

DN7f's triage left one thing in the "one feature away" column after
splines, ellipses and the colour channel had landed: *fancy text and
equations*. DN9 predicted this would arrive as "one more thing a callout
can carry", and it did.

**A label may carry mathematical notation, written between dollar signs**
as TeX has written it for forty years: `"the area is $a^2$"`,
`"$\alpha \le \beta$"`. Text outside the dollars is prose and is left
exactly alone, so nothing that exists changes.

**What this is not.** It is not TeX, and calling it TeX would be the kind
of overclaim this project refuses. TeX is a typesetting system; this is a
reader for the notation the pictures in this library actually need —
superscripts, subscripts, Greek letters and the common operators — laid
out with the font that is already measuring every other label. Everything
outside that is **refused by name**: an author who writes `\frac` is told
it is not here, rather than shown a label with a stray word in it.

**Why it needed nothing from the solver.** A label reaches the solver as a
box, and always has. Notation changes what is inside the box and how tall
it is — a superscript raises the ascent, a subscript lowers the descent —
and the constraint machinery goes on holding a rectangle off the ink
exactly as before. A label becomes RUNS, `[ text, dx, dy, size ]`, and the
renderer draws each while the measurer takes their union: one list, two
consumers, no second description of the same thing.

**A glyph the font cannot draw is refused too.** The table maps a name to
a character and is the same everywhere; whether that character can be
drawn belongs to the font. A shaper answers glyph id 0 for a character it
has no glyph for, and drawing that puts a hollow box in the picture —
which is worse than a refusal, because it looks like a decision. Measured:
Segoe UI carries the Greek and the common relations, and lacks **seven**
of the table's symbols, `\angle` and `\perp` among them. All seven are
refused by name against that font.

### The hazard this met, and a claim retracted the same day

**The canvas styles the text that is PENDING, not the next one.** `SetFont`
with a text pending retro-styles *that* text; `AddText` captures the canvas
default. So in a run of `SetFont`, `AddText`, `SetFont`, `AddText` the sizes
land one item late.

**I first read this as a four-week-old defect in the picture renderer, and
said so in a commit, a memo and a conclusions line. It was wrong.**
`SetSvgIdent` calls `_Flush()`, and the renderer calls `SetSvgIdent` at the
top of every shape, so nothing is ever pending when `SetFont` runs there:
`SetFont` sets the canvas default and `AddText` captures it. Both orders are
correct in that path, and **the word cloud was never drawn wrong** — the
committed `math_22.png` is byte-identical to a correct re-render. The
"before" picture I produced to demonstrate the bug had omitted the
`SetSvgIdent` call, so it reproduced a bug that never existed.

**What is true** is narrower and still worth the guard: the hazard bites the
moment **one shape emits several texts with no flush between them**, which
is exactly what a notation label does. The first notation render came out
with each base and its superscript exchanged, which is how the whole
question arose. The order used now is correct in both cases, and the guard
holds all three facts: the pending-style rule, the inversion without a
flush, and the correctness either way with one.

*The lesson is the retraction, not the rule.* A canvas experiment showed a
real API hazard; I generalised it to a caller I had not read, and the
generalisation was plausible, dramatic and false. The check that settled it
took one grep for `_Flush` and one hash comparison against a committed
picture.

*Guard:* §104, DN10.

### What this leaves

Planarity testing proper (Boyer–Myrvold) and annealing stay refused until
DN8b's numbers say the layouts-as-starts are not enough — the expectation
is that they are, for every planar graph the gallery draws. Rotated
shapes and text along a path stay unplanned. 3D stays outside.

## DN11 — A MOLECULE IS A CONSTRAINT PROBLEM OVER ATOMS: the solver's second caller (2026-09-08, SHIPPED)

The Principal asked for new domains and offered molecular visualisation
among them; this plane chose it first, and for one reason: DN8's solver had
laid out sets, triangles, lattices and graphs and had never been handed a
**ring**. A molecule is rings and chains, and it arrives with no
coordinates — so the picture is *solved*, as the seven-set tree is. What it
would find in DN8, a fourth math scene never would. It found three things.

**What a molecule is here**, in the plane's three programs.
`StzChemistryDomain()`: `Atom` with the elements as subtypes — and
`HeavyAtom` as a subtype between, so that *the skeleton is a type*;
`Bond(Atom, Atom)` with `Double` and `Triple` as predicates, the
specialisation idiom the graph domain's `Highlighted` edge uses; and
`BondAngle(p, q, r)` with its ideal as a predicate, `Ideal120`, `Ideal90`,
`Ideal180` — hybridisation said in the plane's words. `StzMoleculeFromBonds`
builds the substance from a list of elements and a list of bonds and derives
every angle and its ideal from degree and bond order; `StzMoleculeFromMol`
reads a V2000 MOL block. `StzBallAndStickStyle()` is a disc per atom
coloured by the CPK convention *through the theme's roles* (carbon neutral,
oxygen danger, nitrogen info, hydrogen the paper with a muted rim), a bond
as a hidden centre-to-centre segment the rules speak to and a drawn stick
that stops at each rim, a double bond as two lines off the normal, a triple
as three.

**Every angle is a distance.** The tape has no `acos` and does not need
one: two bonds of length L at 120° put their far atoms √3·L apart, at 90°
√2·L, at 180° 2L. An ideal is a hard band around that distance and an
encouraged centre inside it — polynomial throughout, the trick the spherical
style used for a right angle. A six-ring under equal bonds and 120° ideals
**is a regular hexagon, and nothing says "hexagon"**: benzene solves to six
angles within 1.3° of 120 and six bonds within 4% of one another, from the
planar start, first try, one round.

**The MOL block is the independent expectation, not the input.** Its
coordinates are never used to draw. A hand-written benzene block holds a
hexagon of 1.40 Å; the molecule read from it solves to the angle the block's
own coordinates hold, read back by a different function than the one that
solved. That is the stress-test doctrine — an expectation the system did not
produce — and it is the kill this item was aimed at.

**What the second caller found in the solver, in the order it found them.**

1. **A pendant vertex breaks the planar start.** Tutte relaxes every free
   vertex to the barycentre of its neighbours, so a vertex with one
   neighbour relaxes *onto* it, and the collapse check then refused the
   whole embedding — for a graph that was planar and easy. Measured: the
   bare six-ring is lawful from the planar start in one round at 120° each;
   the same ring with six hydrogens fell to a random start and folded, its
   angles 72°, 156°, 97°. Two repairs, both general. The start is asked
   over the skeleton, and *an object of another type joined to the started
   graph by a constructor begins a step from its anchor* — in `_Initialise`,
   beside the rule that starts a contained name at its container's centre,
   and for the same reason: choose the basin by structure. And the planar
   start itself now embeds the **2-core** and hangs the stripped leaves off
   it afterwards, each a step out from its anchor away from the anchor's
   other neighbours, which is the direction a substituent points. A tree
   still strips to nothing and is refused, as before. **And a picture that
   was never a molecule improved by it**: the network of scene 20 is a ring
   with a leaf hanging off it, not 3-connected, and DN7g recorded it as "no
   planar start, one crossing on the chosen seed". It starts planar now and
   the crossing is gone. Two pins in the gate said it could not, and were
   asserting the limitation rather than the promise — they are rewritten,
   and a real tree stands as the fallback's witness in their place.

2. **The shortest chordless cycle is the wrong outer face for fused rings.**
   Caffeine is a six-ring and a five-ring on a shared edge. The planar start
   took the five-ring as the outer face and relaxed the six-ring's four free
   atoms into an arc squashed against the shared edge — a planar drawing,
   and a start no local method opens without crossing; the solve ended 26px
   unlawful from the only start that could have been right. What a chemist
   draws is the **perimeter**, with the shared edge a straight chord across
   it. So when the core has a cycle through every vertex whose chords do not
   cross in cyclic order — the core is outerplanar — that cycle is the outer
   boundary and every vertex is fixed on it. Caffeine: lawful from the
   planar start, first try, two rounds, outer face of nine. **And the
   pictures DN8b pinned did not move**: the cube is not outerplanar and keeps
   its four-face, the dodecahedron its five, the network its six; all nine
   pinned scenes keep their start, their tries and their lawfulness.

3. **`paPath + v` as a call argument appends in place.** The perimeter
   search is a depth-first walk, and its first version passed the extended
   path as `paPath + _v_`; Ring appends to the caller's list and hands the
   same list down, so after a failed branch the path had grown by one and
   the next branch extended the wrong path. Every graph needing a single
   backtrack was refused — and the six-ring and the five-ring passed, because
   neither needs one. A bug on the fused rings hid behind a green hexagon.
   Sibling of the option-list trap and the nested-append trap, same family,
   and the third time this item paid for Ring's `+` on a list.

**What the domain owes the gate: valence.** A carbon with five bonds is not a
drawing defect. `valence_respected` and `atom_bonded` read the substance and
*recount* the bonds — a rule that read a valence the builder stored would be
checking the builder against itself — and register themselves into the math
governance from the file that owns them, through `StzRegisterMathRuleSet`.
The corpus carries an oxygen with three bonds, geometrically perfect and
chemically wrong, so the only thing the gate finds in it is the valence; and
water with a stray hydrogen. Every lattice in the corpus is the boundary the
rules must not cross, so the five questions pass with the rules judged
rather than dead: sixty pictures, eight planted findings.

**Phenol in water, seven components in one substance**, every hydrogen drawn
as the Principal's picture had them: 174 unknowns, 2,958 constraints, lawful
from the planar start in two rounds. The solver had never been handed a
disconnected substance.

**The Principal's correction, same day: the letters were not centred in the
discs.** Measured before believing it. The solver had placed a carbon's `C`
0.86 px left and 1.92 px below its disc: the symbol was a free text held by
`contains` — satisfied anywhere inside the disc — and an *encouraged*
`sameCenter`, which anything hard outvotes. A symbol has nothing to dodge
inside its own disc, so it is not solved at all now: its centre is an
expression of the disc's, as a bond's end is an atom's centre, exact by
construction, and the unknowns halve (benzene 60 → 36, phenol in water
174 → 112). The set style still solves its name, because a set's name does
have things to dodge.

*What the pixels showed besides, and is not this item's:* the renderer
centres a text on its **em box** — baseline at `cy + (ascent − descent)/2`
from the font's metrics — so a capital letter, which has no descender, sits
low by half the empty descender space: measured **+0.6 px at 11 px and
+1.6 px at 28 px** on scene 1's `B`, proportional to size, in every math
picture. Sub-pixel at label sizes, visible on a large centred name. Fixing it
moves every label in 82 pictures and the box the gate's clearance rules read,
so it is recorded here as a number and left for its own item — **DN12, the
same day.** And one instrument lesson from getting there: my first ink-centroid measurement said
the `C` was 3.2 px right and 4.6 px low, which contradicted both the solver
and the primitive — the disc's antialiased rim had been counted as ink. The
primitive measurement (one glyph on a blank canvas against a known anchor)
was the one to trust, and a weighted centroid inside a radius the rim cannot
reach agreed with it.

**Said plainly, and left out.** A 2D depiction draws every sp² and chain
angle at 120° and water's oxygen among them; the real angle is 104.5°, and
this is how it is drawn on paper. A five-ring cannot have its 120° and
settles near 108°, the compromise a chemist draws too; a fused system's
shared atoms compromise further, and caffeine's six-ring reads 102° at the
fusion and 129° elsewhere. A *cycle-size-aware ideal* — a ring's own angle
rather than the atom's — would fix that, and is the next step, not this
item. Three- and four-rings are outside the band and say so as a violation.
Stereo wedges, charges, aromatic circles and implicit hydrogens are not
here; a hydrogen is drawn when it is declared.

*Guard:* §105, 33 assertions; §91 grew by five pictures. Catalogue: scenes
38–41.

## DN12 — A LABEL IS CENTRED ON ITS CAP HEIGHT, NOT ITS EM BOX (2026-09-08, SHIPPED)

**The finding inside DN11's correction, taken as its own item.** The renderer
centred every text on its em box — baseline at `cy + (ascender − descender)/2`
from the font's metrics — and a capital letter has no descender, so it sat
low by half the descender space it never used. Measured on the pixels:
**+0.7 px at 11 px, +1.8 px at 28 px**, proportional to size, in every math
picture since the plane was written. Invisible on an atom symbol, visible on
a set name.

**The metric came from the engine first.** The text layout carries two more
numbers now, appended after the seven it had: the **ink extents** of the
shaped string — how far the glyphs reach above and below the baseline, from
HarfBuzz's glyph extents on the same scaled font the positions came from.
`stzFont.InkOf(text, size)` answers them and `CapHeightOf(size)` is the ink
top of an `H`: read from the font, not guessed at 0.7 em. An `H` has ink
above and none below; a `g` hangs 6.6 px below at 28 px; the em box is the
same for both and the ink is not, which is the whole point.

**The drawing moved by one term.** The baseline sits `cap/2` below `cy`, so
a capital's ink is centred on `cy`. Scene 1's `B` is 0.01 px off its centre
where it was 1.6 px low; benzene's `C` is 0.02 px off.

**The box moved with the ink, and stayed one number.** The em box around the
new baseline is off-centre — `asc − cap/2` above `cy`, `cap/2 + desc` below.
Rather than teach every box consumer an asymmetric rectangle, the modelled
height is the smallest *symmetric* box about `cy` that holds that em box:
`2·max(asc − cap/2, cap/2 + desc)`. Every rule, the tape, the on-paper check
and the marks read `w` and `h` as before; the box is a tenth taller than the
em box at 11 px, and no clearance is closer to the ink than the em-box
clearance was. DN10's box-matches-runs check computes the same number from
the runs' union and still holds.

**What it costs and what it changes.** Every label in every math picture
moves up by the bias and its box grows a little, so all 82 catalogue pictures
change. The gate holds — clearances were held against a box that contains the
old one — but a tenth of a box moved two things worth naming. **The one-wedge
story lost its failure**: on the catalogue's seed, `v111`'s name given a
single wedge now finds room first time (23 px inside a 44 px leash), so the
storyboard, the fact captions and the window pair had nothing to narrate.
Measured over twelve seeds, the story holds on five; the fixture tells it on
`one-wedge` — stranded at 47 px, retried inside, planar start kept, and the
retried picture clean under the one gate in the frame and at 3× — while the
catalogue picture stays on `curved`; the seed is the fixture's, not the
plane's. *Two story-holding seeds were refused for a reason worth writing
down:* their retried pictures were lawful and still carried a `name_off_ink`
finding, a name lawfully clear of a curved edge's two hidden half-chords and
sitting on the spline that bulges 8% off them. The curved style guards names
against the chords, not the curve; the gate reads the curve. That gap is the
style's, predates this item, and is left recorded here rather than widened
into it. **And one seed lost its planar start**: `bulge2`, which DN8h had
pinned as keeping it, now ends its planar solve with that name past its leash
and the next start wins, lawfully. The pin is a count now — four of six seeds
keep the planar start, against one of six before the second wedge — and every
seed ends lawful whatever start it took. A pin on one seed's outcome was the
"answer of the day" shape this session met twice already; the count is the
promise.

*Guard:* §106, 10 assertions, with the ink centre measured on the rendered
pixels inside a circle the disc's rim cannot reach — the first measurement
of this defect counted a rim as ink and was three times too large in the
wrong direction, which is why the instrument's shape is written down here.

## DN13 — THE CHORDS ARE NOT THE CURVE, AND THE CLEARANCE SAYS BY HOW MUCH (2026-09-08, SHIPPED)

**The gap DN12's seed sweep exposed, taken as its own item.** The curved
graph style (DN7h) draws an edge as a centripetal Catmull-Rom through its two
ends and a middle bulged 8% of the length off the chord, and — because a rule
cannot see a spline — holds every name off the two hidden half-chords the
curve was drawn through, at 4 px. The gate reads what is drawn: the spline's
sampled polyline. Between the chords and the curve there is room, and on two
of twelve seeds a name stood in it lawfully with the curve's ink inside its
box — a **lawful picture carrying a finding**, the same disagreement between
model and drawing that DN12 closed for text.

**The gap is one constant.** Every edge in this style bulges by the same
fraction of its length, so the curve has the same shape at every size and
leaves its chords by the same fraction: measured on the cube's twelve edges,
**0.0117 of the edge length on every one** — 4.35 px on a 371 px edge, 2.05 px
on a 175 px one, 14.6% of the bulge — with the twelve ratios agreeing to the
fourth decimal. Past 342 px the gap alone exceeds the 4 px the names were
held at.

**The fix is the clearance carrying that constant.** Names are held off each
half-chord by `4 + 0.012·len(edge)` — the tape already takes an expression
where a number stood — so what the rules hold a name off is where the ink
actually is, on every edge, at every length. The two seeds that carried the
finding are clean; the catalogue's curved cube is lawful, planar-started and
clean; and a name set by hand on a hidden chord's midpoint *is* caught against
the curve it cannot see, which is the instrument discriminating.

**What the fix cost, and the knob that paid it.** Held three pixels farther
off its long edges, the catalogue's curved cube lost its planar start at the
style's 140 px edge target: the force start won, lawfully, with **two crossed
edges** — a picture the plane had stopped drawing at DN8b. The knob is the one
DN8b turned for the same reason, when a 108 px inner square had no room for
four names with their clearances:

| curved style's edge target | seeds keeping the planar start (of 6) | catalogue seed |
|---|---:|---|
| 140 px (as it was) | 4 | force, 2 crossings |
| 150 px | 4 | planar |
| **160 px** | **5** | **planar, no crossing** |

The curved style takes 160; the straight style keeps 140, because its names
sit on ink-exact chords and need no more room. Five of six is better than the
four of six this item inherited. *And two pins in the gate retyped the constant
`4` the clearance used to be* — a fact test asserting the rule's argument "is
read from the rule in force, not retyped from the Style" was itself comparing
against a retyped 4, and a region mark's width was asserted at 8. Both read the
rule's own value now, which is what they always claimed to do.

**And the one-wedge story moved a second time, for the second time by
measurement.** With the corrected clearance and the 160 px target, the seed
DN12 had chosen lets `v111`'s single wedge succeed first time, as `curved` had
under DN12. Sixteen seeds swept at the corrected style: six strand the name on
one wedge (50 px against a 44 px leash) and land it inside on the retry, all
six from a planar start — and **all sixteen are clean under the one gate**, on
the full solve and at 3×, where before this item two of twelve lawful pictures
carried a name on the curve. That last count is the evidence the fix was for.
The fixture tells the story on `second-wedge`.

**What was refused.** Guarding off the curve itself — more hidden chords
through points of the spline — needs the spline's points as tape
expressions, and a centripetal Catmull-Rom parametrises by square roots of
chord lengths through a Barry–Goldman pyramid: expressible, and forty terms
per point. The constant does the same work in one term, exactly, *because* the
bulge is a fixed fraction; a style that varied the bulge would owe the
expression instead. That condition is written in the style beside the number.

*Guard:* §107, 7 assertions.

## DN14 — A GANTT CHART: every position a datum, every rule about time (2026-09-09, SHIPPED)

**The cheapest domain the plane can take, chosen after the dearest.** A
molecule's positions are solved; a Gantt's are computed. A task is three
numbers — a start day, a finish day, a lane — and every pixel follows by
arithmetic, so the builder puts the days on each object for the rules and the
facts and the pixels for the style, and the solver reports **"nothing to lay
out — no rule minted an unknown"**: 52 shapes, 0 unknowns, 80 ms. It is still a
mathematical diagram, and that is the reason to build it here: it answers
`Fact()` in days (`t5.finish − t2.start is 26 days`), carries marks, sits in a
storyboard, is judged by the one gate and renders through `Rendition()` like
everything else. The dot domain — Sierpinski, the Brownian walks — is the
precedent.

**What it is.** `StzGanttDomain()`: `Task` with `Milestone` as a subtype (no
duration, drawn as a diamond), `Dependency(Task, Task)`, `Tick`, and the
predicate `OverBar` for a task that is not the first on its lane.
`StzGanttFromTasks(tasks, deps)` takes `[name, start, finish]` or
`[name, start, finish, lane]` and dependencies by name, assigns lanes, maps
days to pixels, and chooses the axis step from the usual ladder so the axis
has ten ticks or fewer. `StzGanttStyle(lanes)`: a bar in the primary colour,
the name in the left column right-aligned by its own measured width, a diamond
per milestone, an elbow arrow per dependency out of the predecessor's end and
into the successor's start, a faint vertical per tick with its day above.
`StzGanttDiagram(font, tasks, deps)` is the whole picture in one call.

**What the domain owes the gate is the reason to draw a Gantt at all.** The
mistakes people make in a schedule are about time, and none of them is visible
in a drawing that draws what it is given — a backwards dependency is an arrow
pointing left, which looks like an arrow. Three rules read the substance and
recount, each naming the tasks by the author's names and saying by how many
days: `dependency_forward_in_time`, `task_ends_after_it_starts`,
`lane_not_double_booked`. They register into the math governance from the
file that owns them, as the chemistry rules do; the corpus carries a project
and a witness with one of each mistake — the double booking reported on *both*
its tasks, because each of them is double-booked — and every lattice and
molecule is the boundary they must not cross.

**The rule caught its author on its first run.** The project list typed for
the catalogue scene, as "nothing wrong with it", had Prototype starting four
days before Design ended and Test four days before Build ended, both under a
dependency. Fixed, and the mistake is kept as the witness's first rows: a
schedule a person types is a schedule nobody checks, which is what the rule is
for. And the first shared-lane picture had two names in one column cell,
found by `name_off_name` — so a task that is not the first on its lane carries
its name over its own bar.

**And the plane's first all-expression static picture found a defect that lived
in the gate and in no probe.** In the gate's process, and there only, every
Gantt shape whose position is an *expression* read as off the paper by exactly
the margin — 43 of 52 shapes, 10 px each — while every shape positioned by a
bare datum was fine; standalone, the same picture was clean. Bisected along
the gate, the poison was already present before section 91, so it was not
late state. The mechanism: `_StaticOnCanvas` collects a shape's extents in a
list, and each `_V` it calls to fill that list may reach `_EvalExpr`, which
evaluated its tape at a point held in a list of the *same name*; in every
probe those were two method locals, in the gate they were one variable, and
the inner call handed the outer an accumulator of `[0]`. Renaming the inner
method's locals ended it, and a report added to `_EvalExpr` for the run showed
the engine never once answered a non-number — which is how the mechanism was
confirmed. **What was not pinned:** the rule of Ring's scoping that made one
variable of two. A probe that called a top-level helper assigning the same
name, as the gate's helpers do, stayed clean. So the fix does not depend on
the rule: a re-entrant chain of methods gives each method its own local names,
and both methods carry theirs now. Nothing before this item could have hit it
— the dot domain's positions are bare data, which take the fast path, and
every other picture has unknowns, which take the tape.

**The Principal's corrections, same morning, three of them, and the third
decided where the routing lives.** The first elbow turned into the
successor's lane at once and ran to its start; for a task starting the day
its predecessor ends — four of six dependencies here — that run went *left*,
so the head pointed backwards and lay on the bar. The corners were square.
And the link into Launch ran straight down through the Docs bar. **A link
must never cross a bar, and only the builder can promise that**, because only
the builder sees every bar: so the builder is the router. For each dependency
it chooses the vertical column — out of the predecessor's end by eight, then
pushed right of every bar on a lane between the two tasks and on the
successor's lane that would stand in its way — and one of three routes: a
single segment along a shared lane; *Roomy*, out, down the column and in, when
the successor starts at least twenty pixels past the column; *Tight*
otherwise — touching, overlapping, backwards, or into a milestone — out, down
the column to the gap between lanes on the successor's side, along the gap to
twenty short of the successor, down into its lane, and in from the left. Every
route ends rightwards into the successor with its head pointing right; a
milestone is entered and left at its diamond's tips; a backwards dependency
takes the tight route and its run along the gap goes left, visibly. The route
is stored as data — each segment shortened to its arc's tangents, each corner
as the two tangents and the arc's midpoint, radius five or half the shorter
segment — and the style draws a fixed set of shapes per route kind, the corner
a three-point spline. The shared-lane name moved from above its bar to inside
it, since the gap above a bar is where a tight route's run goes.

**A fault is drawn, not hidden.** The Principal asked what a white seam on the
Build bar and a blank lane were. They were the witness's planted faults drawn
badly: the double booking's only trace was the later bar's background-coloured
edge crossing the earlier, and a task finishing before it starts had a bar of
negative width and drew nothing. A picture used to explain a fault should show
it: the builder marks a reversed task and every task that overlaps another on
its lane, and the style draws the first as a bar between its two days in the
colour of a fault and gives the second a red edge, so the overlap is a red
seam. The rules still judge from the days, and the gate holds the drawing's
marks to the rules' verdicts — the marked tasks are exactly the ones the lane
rule names, and nothing in the lawful project is marked.

**A gridline is a guide, not ink.** A task that is not the first on its lane
carries its name over its own bar, and a name over a bar must cross a
gridline — there is no place in the chart free of them. The gate's name rules
read every drawn stroke as ink regardless of paint order, which DN8c chose on
purpose for strokes that mean something; a gridline means nothing a name could
hide. So a shape may declare itself furniture, `:guide = 1`, and `_MrInk`
reads past it. The claim is the author's and is judged like any other: the
corpus holds the touching-tasks chart with its gridlines as guides, clean, and
the same chart with its gridlines as ink, which has a name on one and says so.
The graph plane's edges are not guides and are still ink.

**Said plainly and left out.** Days are numbers, not dates; day 0 is whatever
the author says. Percent complete, the critical path, resources beyond a lane,
and dependency kinds other than finish-to-start are not here. Muted measures
2.85:1 against light paper — below the 3:1 the gate holds every name to — so the
axis labels are neutral at a smaller size; that number is filed for the colour
desk, whose own guard reported every theme/role pair above 4.5:1.

*Guard:* §108, 17 assertions; §91 grew by two pictures. Catalogue: scene 42.

## DN15 — AN ENTITY-RELATIONSHIP DIAGRAM: a schema with a picture, and rules about keys (2026-09-09, SHIPPED)

**The first domain since the org chart to live on the graph plane rather than
the mathematical one, and the reason is what its rules read.** A schema is
nodes and edges — entities and relations — with nothing to solve: rank
layout and ortho routing are its right shape, as they are for every diagram
drawn by `stzDiagram`. What makes it a domain and not a style is the same
thing that made the org chart one: the mistakes people make in it are about
the *substance* — a table nobody can refer to, a reference to a table nobody
drew, a relation the keys do not back — and none of them is visible in a
drawing that draws what it is given.

**What it is.** `stzErDiagram from stzDiagram`, under `StzErNotation()`:
left-to-right, ortho, and **undirected** — a relation carries its meaning at
its ends, and an arrowhead would claim a direction a schema does not have.
`AddEntity`, `AddJunction`, `AddNote`; `AddKey`, `AddAttribute`,
`AddForeignKey(entity, column, target)`, and `AddKeyReferencing` for the
junction's columns, which are keys *and* references and read as `PK FK
product_id -> product`. An entity's compartment reads as a schema does: PK
first, then the columns, a foreign key naming its target. `Relate(a, b,
kind)` with the four cardinalities, drawn as crow's-foot ends at **both** ends
of the line — a bar for *one*, a fan for *many* — through the same
`_DrawRelationEnd` dispatch the org chart's ends use, every end published in
`RenderAdornments()` with which end it is, so the gate reads the cardinality
from the drawing and not from the builder.

**Three rules about keys, a rule set like the org chart's.** `entity_has_key`
(error): a table without a primary key cannot be referred to, and a diagram
is a set of references. `foreign_key_resolves` (error): every foreign key
names an entity of this diagram, by the author's names — *'Order.customer_id'
refers to 'custmer', which is not an entity of this diagram*.
`relation_backed_by_key` (warning): a one-to-many's many side holds a foreign
key to its one side; a many-to-many has some entity holding keys to both
sides, *a junction is owed* otherwise. Each declares its boundary: a note is
a node and not an entity, owes no key and joins no relation, and every rule
excludes it by name rather than merely passing it; an entity with no foreign
key is *outside* the resolving rule, not passing it. The corpus holds the
shop — five entities and a junction, sound under all three — and the same
shop with one of each mistake, which the rules name.

**The plastic rule the shop stood on, and what it taught the rule.** Judged
by the plastic rules like every notation picture, the shop failed one:
`a_fan_leaves_on_one_stem`, because Product's two relations reach different
ranks and turn 253 px apart. They are right to. An ER relation carries its
cardinality where it meets the entity, so two relations out of one entity are
two things, each owed its own mark there — a shared stem would stack two
*one* bars on one point and hide which relation each belongs to. This is the
branch-cell reasoning again, read from the drawing instead of the shape: **a
line adorned at its source is its own thing.** The rule now skips a cell
whose lines are marked where they leave it and lists such a cell with two or
more lines as a counter-subject, so the boundary is witnessed by the corpus.
It does *not* key on the notation being undirected: an electric wire is
undirected, unmarked, and still shares its stem at a junction, as a wire
should. Under the amended rule both schemas are clean.

**Two traps, both paid for in this file.** `@aNotes + "" + pcId` is two
appends, the first of an empty string — a phantom note with an empty id in
the rule graph, found because the note's exclusion counted two where one was
drawn. And `StzFind(item, list) = 0` never held, so `Relate` accepted any word
as a cardinality; the refusal is a loop now, and the gate holds it to refusing
*Sometimes* by name.

**Participation, same day, and it turned out to be a rule and not only a
mark.** `RelateXT(from, to, kind, [ :from = :Mandatory, :to = :Optional ])`
says, per end, whether the entity at that end must take part — read at the
end it names, whatever the kind: *an order always has a customer* is a bar
at the customer end, *a customer may have no order* a ring at the order end.
Drawn inside the cardinality as the crow's foot does, a second bar for
at-least-one and a hollow ring for possibly-none, each published beside the
cardinality with its end; an end that declares nothing draws nothing more,
so every earlier picture is unchanged. The substance under the mark is a
column: `AddForeignKeyXT(entity, column, target, [ :Nullable = 1 ])`, and the
compartment says `(nullable)`. **"An order always has a customer" is a mark
on a line and a NOT NULL on a column — one claim made twice**, so the fourth
rule, `participation_matches_nullability`, holds the declaration at a foreign
key's *target* end to that key's column: optional wants nullable, mandatory
wants not, and the finding names both — *the 'User' end is declared optional
and the key behind it, 'Ticket.assignee_id', is not nullable*. Its boundary
is stated in three parts: a relation declaring nothing at that end makes no
claim, a relation no key backs belongs to the third rule, and a mark at the
*many* end says nothing a column can contradict and is drawn only. The
catalogue's third schema carries two right and two wrong, and the shop's own
marks agree with its columns.

**Two marks from the Principal on the shop, and both were the renderer's,
not the schema's.** A blank between a crow's foot and OrderLine: the routed
form of an ortho edge cut its last 13 px for an arrowhead, and an undirected
notation never draws one — `_DrawArrowHead` returned at once and the trim
stayed behind, exactly the DRAKON defect of an earlier item under another
notation. A line is shortened only for a head that will be drawn, now under
every notation, and the gate holds every relation to touching both its
entities. And the junction's two crow's feet met at their tips: arrivals were
spread over a third of the *picture's cell*, 12 px on a node twice as tall,
which is one foot's width. The share is of the node's own border now, with a
floor of a mark's width and a gap — and the floor stops at the rounded
corners, because a port pushed into a corner is pulled diagonally toward the
centre and the pair's midpoint left the centre by 0.8 px in the old service
picture, which section 29 caught.

**Said plainly and left out.** Attribute types, unique constraints, composite
keys beyond the junction's pair, weak entities and Chen's diamond notation
are not here; the crow's foot is the one notation drawn.

**At the house type size (2026-09-10).** The catalogue and the gate's
options moved from 150×52 at 13 pt to 150×56 at 20 pt, the size every
catalogue draws at. It found one inconsistency general to the plane: the
layout's demand was measured against the caller's cell and divided by the
caller's slot, while the engine's unit was then multiplied by the tallest
drawn box plus a separation — so under a left-to-right schema an entity of
two rows gave nothing back against a 56px cell and was stacked at a
144px pitch. The slot base is measured once now, and the demand and the
scale read the same number. What remains between stacked components is
the engine's family air, 0.4 of a slot, which is the grouping rule and
stands.

*Guard:* §109, 33 assertions; §91 grew by three pictures. Catalogue:
`gg_er_catalogue.ring`, er_01 to er_03.

## DN16 — A PETRI NET: the picture carries its state (2026-09-09, SHIPPED)

**The first domain on this plane whose drawing is not fixed by its author.**
A place holds tokens, a transition moves them, and the same net read a
moment apart shows two different facts. Nothing before it had that: an org
chart, a schema, a circuit are what they are until edited. It lives on the
graph plane — places and transitions are typed nodes, arcs are directed
edges, the net is bipartite by definition — in
`base/graph/stzPetriNet.ring`, under `StzPetriNotation()`: places as circles
at seven tenths of the cell with their name outside, transitions as bars
across the flow, arcs left to right with heads.

**What it is.** `AddPlace` / `AddPlaceXT(id, name, tokens)`, `AddTransition`,
`AddNote`, `Arc` / `ArcXT(from, to, weight)` — a weight above one is written
on the line. The token game: `Tokens`, `SetTokens`, `Marking`, `InputsOf`,
`OutputsOf`, `IsEnabled`, `Enabled`, `WhyNotEnabled` and `Fire`, which takes
each input arc's weight from its place and gives each output arc's weight to
its place, and refuses otherwise by name and by number — *transition 'Enter
B' is not enabled: place 'Key' holds 0 and the arc wants 1*. The mutex in the
catalogue shows the exclusion: Enter A fires, and Enter B is not enabled
until Leave A fires. **The tokens are drawn by the diagram itself**, after
the glyph and before any name, through a hook every cell now offers,
`_DrawNodeMark`: one to four as dots, more as the number, and each published
in `RenderTokens()` as place, count and position, so the gate reads what was
drawn and not what was meant. The picture rendered after a firing carries
the new marking.

**Five rules, and the fifth is liveness in its structural case.**
`arc_joins_place_and_transition` (error): an arc from a place to a place has
nothing to move its tokens. `transition_has_input` and
`transition_has_output` (warnings): a source fires forever, a sink consumes
into nothing. `place_can_be_marked` (warning): no token now and no
transition feeding it is empty forever. `transition_can_fire` (error): fed by
such a place, a transition is dead at birth. Reachability, boundedness and
liveness in the full sense are not computed, and the file says so. Each rule
declares its boundary — the note by every rule, a place by every rule about
transitions, a transition with no input by the firing rule, since it is the
input rule's — and the witness carries one of each mistake.

**Three things the first cyclic domain found in the plane, each general.**
*A backward edge ran through cells.* The mutex's every cycle lands on one
row, and Leave A → Waiting A was drawn straight back along it, under
Critical A and Enter A, a false link with each. The return ladder existed
and was gated on the notation declaring a spine, because ungated it had
disturbed seven assertions in domains whose backward edges had clear runs.
The gate is right and was too wide: with no spine the ladder is now used for
exactly the backward edges with a cell standing on their straight run, read
from the drawn positions (`_CellOnTheRun`), and a clear run still keeps the
row. *The name was written over the tokens.* A glyph big enough to hold its
name holds it, which is right until the glyph holds something else — "Key"
over one dot read as "K.y". A notation now declares, per kind, that a
glyph's inside is spoken for (`SetNameOutside`), and the renderer writes the
name outside without asking whether it fits. *Two plastic rules learned from
the returns.* A return that steps off the row because a cell stands on its
straight run is a detour by law in every notation, not only DRAKON's — the
aligned-edge rule now asks the drawing (`_PlCellOnRun`) before convicting a
bend; and a return dropping out of the bottom of a cell and a flow leaving
its right side are two departures, not one fan drawn twice — the fan rule
now reads the face each line leaves by and holds only the lines of one face
to one stem, which is what DRAKON's If had said of its two exits.

**Five marks from the Principal on the mutex, and every one was a general
fault of the renderer.** *A lone return arrived a quarter-cell off the
centre of its circle, and two stubs under Key sat at centre and
centre-plus-seven, and a lone return left a bar off its centre.* One
allocator: the stub planner bucketed a return with the forward departures,
though a return leaves and arrives through the far *stacking* border while a
forward edge uses the *rank-facing* one — under a left-to-right reading, the
bottom against the right — and it measured the return's offset along the
wrong axis. A return now has its own border and its offset runs along the
rank axis, so a lone return takes the centre and a pair straddles it. *An
arrow stopped short of the bar.* The bar glyph inset its ink to 28% of a box
that was itself a third of the cell, so an arc attached to the box ended 9 px
from any ink. A box already as thin as a bar is now filled, and the Petri
transition declares a tenth of the cell — its box is its ink. *The wire
between a place and its name was five pixels long.* A beside-name's plate
began 5 px past the border and covered the wire leaving through it; where a
wire leaves or arrives through the side a name sits on, the name now stands a
line's clearance off the border — the stub the name-below branch already
left — and keeps close where nothing does. *And the name hung under the wire.*
A beside-name sat 0.35 of the type below the centre, its letters 4 px under
the line they stand beside; its capitals now straddle the wire's centre, the
same centring DN12 gave a name inside a cell.

**Said plainly and left out.** Inhibitor arcs, coloured tokens, timed
transitions, priorities, and any analysis beyond the structural — the
reachability graph, boundedness, full liveness — are not here.

**At the house type size (2026-09-10).** The catalogue and the gate's
options moved from 64×64 at 13 pt to 150×56 at 20 pt. The transition came
out a 20px block: a bar took its thickness as a scale of the cell's extent
along the flow, which under a left-to-right net is the cell's width — set
by the widest name in the picture, and a note had widened every cell to
198px. A bar's thickness is a mark's now, the scale of the smaller cell
dimension, whichever way the picture runs; the gate's "a bar's box is its
ink" assertion is what caught it.

*Guard:* §110, 45 assertions; §91 grew by three pictures. Catalogue:
`gg_petri_catalogue.ring`, petri_01 to petri_03 and petri_01b, the mutex
after Enter A fired.

## DN17 — A FAULT TREE: a picture that computes (2026-09-09, SHIPPED)

**The first domain on the graph plane whose picture answers a number.** A
fault tree says how an undesired event, the top, comes about: through AND
and OR gates down to basic events whose probabilities are known. Read up it
is a picture of causes; computed up it is the probability of the top and
the minimal cut sets, which is what an analyst draws the tree to learn. It
lives in `base/graph/stzFaultTree.ring` under `StzFaultNotation()`: top and
intermediate events as boxes, basic events as circles with the number
inside and the name beneath, undeveloped events as diamonds, the two gates
as the shapes every standard draws — the round-topped AND and the shield OR,
two new glyphs in `stzNodeShape` — read top-down with no heads.

**What it is.** `AddTop`, `AddEvent`, `AddBasicXT(id, name, p)`, `AddBasic`
for a leaf whose number is not yet known, `AddUndeveloped`, `AddNote`;
`AddGate(id, :And | :Or)`, `Under(event, gate)`, `Feed(gate, input)`, and
`Develop(event, kind, [ inputs ])`, the three in one line. `ProbabilityOf`
computes up from the leaves — AND multiplies, OR takes one minus the product
of the complements — and refuses by name at a leaf with no number, an
undeveloped event, or a cause among its own effects. `MinimalCutSets` expands
the tree, an OR unioning and an AND crossing, and minimises; and
`CutSetProbability` sums them by inclusion and exclusion, which is the exact
number the gate arithmetic cannot give when a basic event is repeated: the
catalogue's second tree has one sensor under both branches, and the gates say
0.0494 where the cut sets say 0.044. The probability is drawn inside the leaf
through the cell hook DN16 opened, a question mark where none was declared,
and published as `RenderProbabilities()`.

**Five rules.** `one_top_event`, `gate_has_two_inputs` (one input is a
wire), `basic_event_has_probability`, `event_is_developed` (one gate beneath,
or declared undeveloped — which is the rule's own boundary), and
`no_event_causes_itself`. The witness carries one of each, and an undeveloped
event and a note that every rule must leave alone.

**Four things the first tree with unequal branches found, each in the
engine or the renderer, none in the domain.** *The gate leaned.* The
engine's coordinate pass gives a parent's column to the child carrying the
longest continuation — right for a flow, where the graph says "this way
onward" — and the plane's own plastic rule I7 convicted the top gate the
moment one input had a subtree and the other was a leaf. A fault tree's gate
has inputs, not a continuation, so a notation may now declare its children
*peers* (`SetPeerChildren`, carried to `graph_layout.zig` as one flag) and the
parent stands at the middle of all it owns. A plain diagram keeps the flow
rule, and the gate holds both. *The fan split by five pixels.* Same-source
channels were joined by the claim and then clamped, each against its own
target's border, by every hand after it; the dry pass now records where each
member came to rest and the drawing pass gives the fan its tightest channel.
*The published path was the rehearsal.* Ortho edges published on the dry
pass only, so an instrument read where the rehearsal had put a line and not
where it was drawn; the drawing pass has the last word now. *A gate was
entered from its side.* The lone-edge L, one bend into the target's side,
and the side landing for a shallow aim both read as a line arriving from a
sibling in a tree; a peers notation keeps every edge rank-facing at both
ends. And two readings of the fan rule were sharpened on the way: a straight
member has no corner to read, and a stem that continues a clearance past
the branch before turning is one stem with a second branch, not two.

**Then the Principal marked the alignment of every subtree, and two more
were the engine's.** *A chain did not follow its child.* The centring pass
skipped every node with one edge out, so an event stood where the snap had
left it while the gate beneath it was centred over the grandchildren in the
same pass — "No power" half a slot off its own gate. One child is the
strongest case there is, as the pass's own comment already said three lines
below the skip; the skip is gone. *A shared leaf was nobody's.* The centring
counted owned children only, so a gate over a repeated leaf centred over the
other input alone. Under a peers notation every input counts, which is what
puts the shared sensor between the two branches and each gate at the middle
of both its inputs. And a tree's one backward edge, a cause among its own
effects, takes the return ladder beside the picture rather than climbing
its own column into the top event's floor. *And a second arrival entered a
leaf from its side.* A mark takes no ports, so its second arrival always
found the column taken and took the side approach; two descents into a
mark are one line by the mark's own law, and under a peers notation no line
enters a cell's side — the repeated sensor is now entered from above by
both gates, on one drop.

**A third round, three more.** *Two fans read as one rule.* Their channels
met end to end at the shared leaf, and the claim registry let two foreign
spans share a row when they only touched; spans closer than a clearance now
contend like overlapping ones, and the second fan takes the next row. *A
gate stood off its middle input.* The span's middle is the middle child only
when the children are evenly spaced; among peers an odd count now stands
over the median child, a column the reader already sees. *A second tree
stood a cell and a half from the first.* The layout spaces every node as a
full cell, so two marks a third of the cell wide were a cell and a half
apart. Two engine remedies were tried and reverted the same night — a
negative demand shrank the cells and truncated the names, and pulling a
subtree left in the territory pass landed it inside another family's band,
which section 6 caught — and the answer is a Ring-side pass on the drawn
boxes, for peers notations only: each tree of the forest is shifted as a
rigid block until it stands one separation from the trees before it on some
rank, names beneath marks counting as the mark's width, and the engine's
reserved routes follow their nodes. And a length guard in the layout canvas
threw away the whole label-demand list whenever a long edge added a dummy;
the real nodes keep what they asked and the dummies demand nothing.

**A fourth round, two small ones.** The cycle's ladder stood at the
picture's far edge, beyond a leaf two ranks below anything it passed; the
ladder now clears only the ranks between the return's two ends, so it stands
beside Jam and the paper gives the column back. And the OR gate's concave
bottom rose 0.40 of the box above the line leaving it; the input stem now
reaches up into the shield, as the standard draws it. And a fifth: the gate
whose third line cycles back to the top stood over the "middle" of two
leaves and the top event, which is the right leaf — the engine's centring
took a back edge's target for a child. The rank each node was laid on says
which way an edge goes, and a target on the parent's rank or above is not
something to centre over; the gate stands at the middle of its two leaves,
which is the rule the Principal asked for. And the catalogue is set in the
house type, 150×56 cells at 20 pt as the DRAKON catalogue is, so its names
read at the size the plane's other pictures are read at.

**Said plainly and left out.** NOT, voting and inhibit gates, transfer
symbols, common-cause groups, importance measures, and the exact sum above
twelve cut sets. The gates draw for a top-down tree only.

**Round 6 (2026-09-10), five marks on the catalogue.** On the repeated
tree: the two lines into the shared leaf merged above it into one stem
(*"why not separating the two lines completely like in other diagrams?"*),
and the alarm gate's fork was rounded on one arm and square on the other.
On the witness: a very large distance between Jam and the cell beside it;
the return's ladder a few pixels off the leaf column below; and the text
unreadable. Five causes, four of them laws general to the plane:

- **A mark gives room back** (engine, `demand()` signed). Every node held a
  whole slot whatever it drew; a 40px circle with a name beneath, in a
  150px cell, spread two leaves a cell apart. The face now sends a negative
  half-width for a node narrower than its slot, bounded at −0.45 of it;
  `_DrawnExtentOf` is the one answer to "how wide is this node" for the
  demand, the peers packing and the rank fitter.
- **A return's target is not a child** — in `tidyTerritories` too. The
  centring learned it in round 5; the territory pass had not, so the gate's
  territory ran up its own return to the top event and the next cell stood
  a slot from Jam over nothing.
- **The rank fitter measures what is drawn.** It judged every pair against
  the caller's box, read two rightly packed marks as a collision and scaled
  the whole witness — cells, marks, words — by a fifth. That was the small
  text. It reads each pair's drawn extents now.
- **A mark that holds two ports keeps them**, under a peers notation: a
  quarter of the mark to each side, and a drop into a circle lands on its
  arc, the landing only — the channel arithmetic keeps the flat border, or
  a member whose border moved a pixel refuses the row its sibling stepped
  to. The 17px end event's rule (every arrival at the centre) stands for
  any mark smaller than two ports' floors.
- **The stem's corner is a fork whenever the source fans**, read off the
  model, not off the rehearsal: the dry pass's paths no longer decide which
  arm is squared. And a ladder within a pitch of a column outside its span
  stands on that column, outward only (`_PlanRowLanes`) — moot on the
  witness once the leaves packed, kept as the law the Principal drew.

**Round 7 (2026-09-10), two marks.** *"Let the two horizontal lines be at
the same level, because they represent logically the same level"*: two
fans that part on the shared leaf's own ports end at two different places
and are two lines by construction, so they share the row — the channel
claim records each run's target and lets runs into one target stand a
port's floor apart on one row; where a smaller mark makes the arrivals
coincide, the third round's two-row rule stands, and a negative holds it.
*"The left side must be aligned (principle of spatial equilibrium)"*: the
leaves beside a ladder stand on its column — the outer leaf on the
ladder's side takes the ladder's column, the outer leaf on the other side
stands as far from the gate the other way, the rest spread evenly between
(`_SpreadLeavesToLadder`, peers only, outward only, and only where the
mirrored leaf meets no foreign cell on its rank). The ladder continues
down onto Dust; the gate keeps its middle.

*Guard:* §111, 56 assertions; §91 grew by three pictures. Catalogue:
`gg_fault_catalogue.ring`, fault_01 to fault_03.

## DN18 — A FAMILY TREE: a tree with two parents (2026-09-10, SHIPPED)

**The cheapest domain after the fault tree, and the one that reads the tree
the other way.** A person is a box with the name and, in a second band, the
years; a *union* is a dot between two partners; every child hangs from a
union. Two parents per child is what makes it a family tree and not an org
chart, and the union is what makes two parents drawable — the child has one
line up, to the dot, and the dot one line to each partner. It lives in
`base/graph/stzFamilyTree.ring` under `StzFamilyNotation()`: top-down, no
heads (kinship has no arrow), every parent's children peers, the years as a
compartment the way DRAKON's shelf is.

**What it is.** `AddPerson`, `AddPersonXT(id, name, born, died)` with 0 for
unknown, `AddNote`; `Marry(a, b)` answering the union's id and answering the
same union asked again either way round; `AddUnion(id, [ partners ])` for a
single parent or whatever the author insists on; `Child(union, person)` and
`ChildOf(a, b, child)`, which marries them if they are not yet. Kinship read
off the tree: `PartnersOf`, `ChildrenOf`, `ParentsOf`, `SiblingsOf`,
`AncestorsOf`, `DescendantsOf`, `GenerationOf`.

**Five rules.** `no_one_is_own_ancestor`, `union_has_two_partners` (one is a
single parent and the rule says so as a warning; three is not a union),
`child_of_one_union`, `parents_are_older` where the years are given — its
boundary is every person without a year or without a dated parent, stated —
and `partners_are_not_kin`. The witness carries the union of three, the
child of two unions and the child older than both parents; the cycle and the
father joined to his daughter each have a scene of their own, because a
cycle makes everyone everyone's ancestor and every rule then speaks at once.

**One layout law the domain needed, and it is general to peers.** A spouse
who married in has no parents drawn, so the longest-path ranking lifted her
to the top rank, three generations above the partner she stands beside.
Among peers a source now settles onto the rank just above the earliest thing
it feeds (`_SettleSources` in the layout canvas), which is where its partner
already stands; a flow notation keeps its starts on the first rank, and the
gate holds both. And a lesson for every witness: a wide note widens every
cell of the picture — the widest-name law counts it — and at 20 pt that
overflowed the paper the fit had measured before the widening; the note is
short now, and the widening after the fit is noted here as a limit.

**And a second, general to every long edge.** The layout places a long
edge's waypoints as cells of their own, and the peers packing moved the
cells and not the waypoints: the witness's line from a union to a grandchild
bent at x=919 and x=1167 on a sheet whose last cell ends at 787, and the
paper — measured from the cells — cut it 116px short. The return ladder's
law already answered this (*a ladder clears what it passes, not the whole
picture*), so a bend beyond every cell it passes now stands one line
clearance past the far border of the ranks between its ends, and the fit
reads the bends as ink beside the cells and the returns. The witness
draws its long line beside Fay with the same 16px margin on both sides;
the plastic governor reads 0 on the four family pictures.

**Said plainly and left out.** Adoption, step-relations, the ordering of
siblings by birth, and dates finer than a year.

*Guard:* §112, 27 assertions; §91 grew by four pictures. Catalogue:
`gg_family_catalogue.ring`, family_01 to family_04.

## DN19 — A TIMELINE: the axis as a scale, every mark on it a datum (2026-09-10, SHIPPED)

**The rank axis as time.** The Gantt drew time as bars on lanes and the
family tree drew generations as ranks; a timeline is the axis itself — one
ruled line where *distance means duration*, events as dots on it named
above, eras as bands beneath it. It is the Gantt's kind of picture: every
position computed from a number the author gave, nothing minted as an
unknown, the solver reporting *nothing to lay out*, and still a
mathematical diagram — it answers `Fact()` in the author's unit
(`e9.t − e1.t is 71 years`), sits in a storyboard, is judged by the one
gate and renders through `Rendition()`. It lives in
`base/graph/stzTimelineDiagram.ring`.

**What it is.** `StzTimelineDomain()`: `Event`, `Era`, `Tick`, `Axis`, and
`Belonging(Event, Era)` — an event the author places in an era, the one
claim a timeline makes that its own drawing cannot show to be false.
`StzTimelineFromEvents(events, eras)` takes `[name, t]` or `[name, t, era]`
and `[name, from, to]` or `[name, from, to, band]`; it maps time to pixels,
chooses the axis step from the usual ladder so the axis has ten ticks or
fewer, assigns each era the first band it does not overlap on, and lays the
names. `StzTimelineStyle(levels, bands)`: the axis as one line, a tick as a
cross-mark with its time beneath, an event as a dot with a stem up to its
name, an era as a band in the primary colour with its name inside — or
beside the band when the band is too short for it. `StzTimelineDiagram(font,
events, eras)` is the whole picture in one call.

**The law it mints is the laying of the names, and it is the builder's.** A
name over another event's column would put that event's stem through it,
and two names on one level would run together; so the builder lays each
name, in the order the events happen, at the lowest level where it covers
no other event's column and touches no name on that level — centred on
its stem when it can be, hung to the right of it when it cannot, to the
left when it still cannot, and a level up otherwise. The axis stands below
the levels the names took. And the margins hold the first and the last
name: the earliest event's name, centred on its dot, ran seven pixels off
the paper's left edge, and hanging it inward would have covered the next
column; a margin is at least half the name that stands over it.

**Three rules, every one about time.** `era_ends_after_it_starts`,
`band_not_double_booked` (reported on both eras, since each is booked;
touching ends are not an overlap), `event_within_its_era` (inclusive at
both ends, saying by how many years and which way). A fault is drawn: a
reversed era as a band between its two times in the colour of a fault, a
double-booked era with a red edge, an event outside its era with a red
dot — and the gate holds the marks to the rules' verdicts. The corpus
carries the history of computing, lawful, and a witness with one of each
mistake.

**Said plainly and left out.** Time is a number in the author's unit and
the axis writes the number; a calendar is a labelling this item does not
do. Names are laid above the axis only — a timeline dense enough to need
both sides is a timeline that wants two pictures. Durations of events,
uncertainty, and links between events are not here.

*Guard:* §113, 28 assertions; §91 grew by two pictures. Catalogue:
`gg_math_catalogue.ring`, scenes 43 and 44.

## DN20 — A FISHBONE: an effect, its categories of cause, the causes on them (2026-09-10, SHIPPED)

**Ishikawa's diagram, and nothing in it is solved.** One effect at the
head, a spine running into it, a bone for each category of cause leaning
toward the head from above and below by turns, and on each bone a rib for
every cause with its name at the rib's free end. A bone's length follows
from how many causes it carries, its place on the spine from how wide its
neighbours are, and every pixel from those numbers by arithmetic — so it is
the Gantt's and the timeline's kind of picture, on the math plane, with the
solver reporting *nothing to lay out*. It lives in
`base/graph/stzFishboneDiagram.ring`.

**What it is.** `StzFishboneDomain()`: `Effect`, `Spine`, `Category`,
`Cause`, and `Up(Category)` for the side a bone leans from.
`StzFishboneFromCauses(effect, categories)` takes the effect's name and
`[name, [cause, …]]` per category in spine order; it gives every bone a
length that seats its ribs a name's height apart (a floor of 96 px), leans
it at sixty degrees toward the head, places the ribs evenly along it with
the first cause outermost, and puts the head where the last bone ends.
`StzFishboneStyle(w, h)` draws the spine with a head into the effect's box,
each bone with a head at the spine, each rib as a level line toward the
tail with its name at the free end, each category's name past its bone's
end. `StzFishboneDiagram(font, effect, categories)` is the whole picture.

**The law it mints is the spacing of the bones.** Bones alternate sides, so
a bone's neighbour on its own side is two places along; every bone is
measured first — its reach along the spine, a rib, and the widest name at a
rib's end, or half its category's name past its end — and the pitch
between consecutive bones is half the widest carry and some air, so two
bones on one side never meet in what they carry. Long names widen the
carry and the pitch follows; the gate stands on it with a picture of long
names that stays clean under the name rules.

**Three rules, every one about the analysis.** `every_bone_carries_a_cause`
(a category with nothing under it is where the analysis stopped),
`a_cause_is_named_once` (one cause under two categories, reported on both
listings; the same name twice under one bone is a repeat, not this),
`the_effect_is_not_its_own_cause` (the effect among the causes, matched
whatever its case, explains nothing). A fault is drawn — the empty bone in
the colour of a fault, the offending names in it — and the gate holds the
marks to the verdicts. The corpus carries the bitter coffee, lawful, and a
witness with one of each mistake.

**Said plainly and left out.** A rib carries a name and nothing hangs off a
rib — no sub-causes. The six Ms are the author's convention, not the
domain's. Weights, votes and the five whys are not here.

*Guard:* §114, 27 assertions; §91 grew by two pictures. Catalogue:
`gg_math_catalogue.ring`, scenes 45 and 46.

## DN21 — A NETWORK TOPOLOGY: devices, links, subnets, addresses (2026-09-11, SHIPPED)

**The sixth domain on the graph plane, and the first whose frames are
subnets.** A topology says what is wired to what: the internet beyond the
picture, a firewall guarding the way in, routers between subnets, switches
fanning out to servers, hosts and access points. The devices are typed
nodes drawn as the trade draws them — seven glyphs added to the shape
sheet: a cloud, a puck with four arrows for a router, a flat box with
arrows across it for a switch, a brick wall, a tall box with slots, a
screen on a foot, a small box under two waves — the links are undirected
edges, a subnet is a cluster with an address range, and the picture reads
top-down from the cloud, which the notation makes a source. It lives in
`base/graph/stzNetworkDiagram.ring`.

**What it is.** `AddDevice(id, name, kind)`, `AddDeviceXT(id, name, kind,
address)`, `AddNote`; `AddSubnet(id, name, cidr, [members])`; `Link(a, b)`,
`LinkXT(a, b, label)`. Read back: `NeighboursOf`, `HopsBetween`,
`IsReachable`, `AddressOf`, `SubnetOf`, `CidrOf`, `DevicesIn`, `KindOf`.
Addresses are IPv4 read as numbers and a subnet is a CIDR read as a range
(`StzIpToNumber`, `StzCidrRange`, `StzIpInCidr`); the address is checked
and not drawn, since a mark's name is one line.

**Five rules.** `every_device_is_linked`, `addresses_are_unique` (reported
on both devices; a device with no address is outside the rule),
`address_in_its_subnet` (a device in no subnet is outside it),
`switches_form_no_loop` (a ring of switches alone, on every switch of the
ring; a loop through a router is a route and stays outside — the floors
stand on that), `the_edge_is_guarded` (the cloud links only into a
firewall). The corpus carries the office and the floors, lawful, and a
witness with one of each mistake.

**Three things the domain found in the plane, none of them about
networks.** The cluster cohesion pass stood a cluster's members exactly
one slot apart whatever they had asked for, so two marks that had given
room back were spread to a cell's width and the last member of one subnet
was carried onto the first of the next: two names 61px apart under two
frames that overlapped. Cohesion now spaces members at their own pitch —
one slot plus the two signed demands, the engine's own law — and a sweep
along each level after the boundary air pushes any node out to its pitch
from the one before it. Second, a name plate inside a frame was painted in
the cluster's declared hue while the frame itself is painted at that hue's
surface step, so every name under a mark in a subnet sat on a dark slate
card — the very card the Principal once marked; the surface helper answers
the surface step now, one quantity from one source. Third, a name written
beneath a glyph the plane had never heard of was drawn beneath and reserved
nowhere — the witness's last rank had "Alice" cut by the paper's edge; a
kind the profile writes outside writes below whatever its glyph, and the
reservation stays out of the left-to-right pictures, whose names go beside.

**Said plainly and left out.** VLANs, routes, link speeds beyond a label,
redundancy protocols and wireless reach are not here; addresses are IPv4.

*Guard:* §115, 30 assertions; §91 grew by three pictures. Catalogue:
`gg_network_catalogue.ring`, network_01 to network_03.

**The shape sheet, regenerated (2026-09-11).** `gg_nodeshapes.ring` still
said twenty-four shapes while the vocabulary had grown to forty-six; it
reads the count from the library now. Two things the old sheet hid: it
named no glyph, so a reader could not pick one from it, and it drew the
stroke in the ground's own colour, so the two stroke-only electric
symbols were invisible there and read as blank to the pixel-tier check,
whose sample strode past their few hundred pixels. The sheet names every
glyph beneath it, strokes in a light ink, and the check counts every
pixel. Found while looking: a fill set while a canvas shape is pending
colours THAT shape — the first regeneration came out one colour with
rainbow names — so each name is posted before the next cell's fill.

## DN22 — A FLOOR PLAN: rooms to scale, the rules of a building (2026-09-11, SHIPPED)

**Distance means length.** The timeline's law turned into two dimensions: a
room is four numbers in metres, a door and a window are a place on a wall
and a width, and every pixel follows from those by one scale, the plan
filling the paper's width and a bar of one metre saying so. Nothing is
solved; it is the Gantt's kind of picture on the math plane, answering
`Fact()` in square metres. It lives in `base/graph/stzFloorPlanDiagram.ring`.

**What it is.** `StzFloorPlanDomain()`: `Room`, `Door`, `Window`, `Area`
(a text shape draws its owner's label, so a room's area is an object of
its own), `Scale`; the facing predicates `Exterior` and `Outward`.
`StzFloorPlanFromRooms(rooms, doors, windows)` takes `[name, x, y, w, h]`
and `[room, side, offset, width]` with side n, e, s or w; it reads which
rooms abut which along which wall and says for every opening what it
faces — another room or the outside — and a door counts for both rooms
it stands between. A door is drawn as a gap in the wall with its leaf on
one jamb and its swing a quarter circle into the room; a window as a light
band across the wall; a room as its walls with its name and area inside.
`StzFloorPlanDiagram(font, rooms, doors, windows)` is the whole picture.

**Four rules, every one about the building.** `rooms_do_not_overlap`
(reported on both, with the floor they share; rooms that touch along a
wall do not overlap), `every_room_has_a_door`, `every_room_is_reachable`
(from outside, through doors — a bedroom and a study whose only door is
between them are both caught; a room with no door is the second rule's
and outside this one), `windows_face_outside` (naming the wall and both
rooms). A fault is drawn in the colour of a fault and the marks are held to
the verdicts. The corpus carries the flat, lawful, and a witness with one
of each mistake.

**Said plainly and left out.** Rooms are rectangles and walls are
straight; wall thickness is drawn, not measured; stairs, furniture,
fixtures, levels and the north arrow are not here. A door on a wall that
abuts no room is an exterior door, which is how the plan is entered.

*Guard:* §116, 26 assertions; §91 grew by two pictures. Catalogue:
`gg_math_catalogue.ring`, scenes 47 and 48.

## DN23 — A SEATING PLAN: tables where they stand, seats around them, guests in them (2026-09-11, SHIPPED)

**The floor plan's kind of picture with people in it.** A table is a name,
a kind, a number of seats and a place in the hall in metres; its seats are
computed around it — evenly on a ring for a round table, the first at the
top, along both long sides for a long one — and a round table's disc grows
with its seats. The guests take the seats in the order they are given, and
each name is written beyond its seat, anchored by where the seat stands on
the ring so that it reads outward: hung to the right on the east, to the
left on the west, centred above and below. Nothing is solved; it is on the
math plane and lives in `base/graph/stzSeatingDiagram.ring`.

**What it is.** `StzSeatingDomain()`: `Table` (`Round` or `Long`), `Seat`
(`Taken`), `Guest`, `Apart(Guest, Guest)` — two people the host keeps
apart, the one claim a plan makes that the drawing cannot show to be
broken — and `Unseated`, the one line naming everyone who found no seat.
`StzSeatingFromTables(tables, guests, apart)` takes `[name, kind, seats, x,
y]`, `[name, table]` in seating order and `[name, name]`;
`StzSeatingDiagram(font, …)` is the whole picture, the font measuring the
names so the anchoring is exact.

**Four rules, every one about the plan.** `table_not_overbooked` (naming
who found no seat), `a_guest_sits_once` (on both listings),
`kept_apart_are_apart` (naming the table), `tables_stand_clear` (seat
reach against seat reach, on both tables, with the distance and the
distance needed; names are the plane's own name rules' business, and the
lawful wedding stands clean under them). Faults are drawn — a rimmed
table, a name on a plate, the seatless named beneath the hall — and the
marks are held to the verdicts.

**The tables are spread so that every name clears every other table on
all sides** — the Principal's words on the first picture: *tables should
be spaced so that chairs and labels are clearly separated from all sides*.
The host writes where a table stands; the layout owns the geometry, and a
name is geometry the host never typed. Each table's extent — disc, seats
and the names hung beyond them, measured in the font — is taken, and two
extents that meet are pushed apart along the axis of least overlap, half
each, until none meet with a clearance between; twice, since the scale
follows the spread and the names are measured in pixels. What stood left
stays left, what stood above stays above, and tables that already clear
each other keep the distance the host gave them. Two laws came with it: a
long table's seats stand a name apart, its pitch growing past six tenths
of a metre where the widest name at the scale drawn asks for more; and two
tables meet when they are closer than their seats' reaches on *both* axes
— a long table's slab was being measured radially against a table below
it, and read as a collision at 3.6 m.

**Said plainly and left out.** Seats are taken in order, not chosen; the
hall is the paper and has no walls; couples, dietary marks and who faces
the stage are not here.

*Guard:* §117, 31 assertions; §91 grew by two pictures. Catalogue:
`gg_math_catalogue.ring`, scenes 49 and 50.

## DN24 — A CHOROPLETH MAP: regions coloured by a value, a legend beside (2026-09-11, SHIPPED)

**The last domain of the list, and the first whose colour is the datum.**
A choropleth paints each region by where its value falls among a few
classes, darker meaning more, and a legend beside the map says what each
shade stands for. The regions are polygons the author gives in map units,
the classes are the edges the author gives, and every pixel and every fill
follows by arithmetic. Nothing is solved; it is on the math plane and
lives in `base/graph/stzChoroplethDiagram.ring`.

**What it is.** `Region`, `Swatch`, `Legend`, `Value`; a class predicate
per class on regions and on swatches, and a vertex-count predicate per
region — a polygon's count is a literal of the style, so the style paints
each class and each count present by its own rule.
`StzChoroplethFromRegions(quantity, regions, edges)` takes
`[name, value, [x1, y1, …]]` with `""` for no value and the class edges
ascending, `n + 1` for `n` classes; a palette of `n` colours may be given,
or the primary hue is stepped from a pale tint to a deep shade on the
colour ramp's own lightness scale. The lower edge belongs to a class and
the upper does not, the last closed at its top; a region's name stands at
its shoelace centroid with the value beneath; the map fits beside a legend
column.

**Four rules, every one about the map.** `every_region_has_a_value` (a
hole, drawn as no data with a swatch saying so),
`values_fall_in_the_classes` (saying by which edge; a region with no value
is outside it), `darker_means_more` (class by class, the first having
nothing to be darker than), `every_class_has_a_region` (a colour the
legend promises for nothing; the no-data swatch is no class). Faults are
drawn — the region beyond the classes in the colour of a fault, the
offending swatches rimmed — and the marks are held to the verdicts.

**The legend says why (2026-09-11, the Principal's reading).** Shown the
witness cold, the Principal read what a reader would: *the centre is 450
and it is not represented in the legend; and some entries of the legend
do not exist as values on the map.* Both were the planted faults, and the
rules reported both — but the picture rimmed two swatches in the fault's
colour and said nothing more, and a rim says something is wrong without
saying what. So the legend explains itself now: a class that colours
nothing says *(no region)* after its range, a shade out of order says
*(out of order)*, and a value beyond the classes gets an entry of its own
in the fault's colour — *above 400 (no class)* — so that every region on
the map is in the legend. The rules' messages read the range, never the
label, so the reason written in the legend does not leak into a finding.

**Said plainly and left out.** Regions are simple polygons the author
gives, not fetched from an atlas; a projection is the author's business;
classes are the author's edges, not computed quantiles; no north arrow,
no scale bar, no coastline beyond the regions.

*Guard:* §118, 30 assertions; §91 grew by two pictures. Catalogue:
`gg_math_catalogue.ring`, scenes 51 and 52.

## DN24b — REAL BOUNDARIES, WITHOUT AN ATLAS (2026-09-12, SHIPPED)

**The Principal asked whether the choropleth needs a vendored boundary
asset of a few hundred kilobytes.** The geometry is indeed cheap — a
shoelace centroid, a class lookup, one scale factor — and the answer to
the asset is **no, and the refusal stands**. What was true underneath the
question is that the library had pushed the whole cost of getting real
boundaries onto its caller, and that is what this closes.

**What shipped.** `stzGeoRegions.ring`: a GeoJSON FeatureCollection
becomes the `[ name, value, [x1, y1, …] ]` regions the builder already
takes, with the name and value read from each feature's own properties by
keys the caller names, because no two datasets agree on what to call
either. It vendors no boundary, names no country, and carries no opinion
about where a border lies.

**A projection lives here after all, and the reason is not convenience.**
A choropleth encodes a quantity as the colour of an AREA, so a projection
that distorts area makes the picture argue against its own legend — on
Mercator, Greenland reads as large as Africa while carrying a fourteenth
of its people. The default is therefore **Lambert cylindrical equal-area**,
and the guard asserts the property that matters: two regions of equal true
area at latitudes twenty degrees apart draw the **same size**, while the
plain projection draws them at sizes differing by more than half. The
standard parallel is taken from the data's own middle latitude, since a
map left at the equator is area-true and three times too wide at fifty
north.

**Two defects a PICTURE found, and no test of numbers would have.** The
first projection wrote x in degrees and y as a sine — two axes in
different units — so a country twelve degrees wide and six tall drew 184
times wider than it was tall: every polygon a two-pixel hairline, every
name colliding, six rule findings and nothing recognisable. The second was
subtler: the standard parallel was averaged over EVERY feature in the
file, so one nameless feature near the equator, which the reader skips and
draws nothing for, pulled a country at fifty north down to a parallel of
twenty-six. The guard now holds both.

**AND NORTH IS UP, which the Principal's own review caught.** Asked for
maps to assess, the first render of a six-province country put Nord along
the bottom edge and Sud across the top: every area right, every border
meeting its neighbour, the legend in order, and the map upside down.
Latitude grows north and a screen's y grows DOWN, so a projection handing
back a rising y inverts every map made from it. The guard had asserted the
areas and the aspect ratio, and both passed — **nothing had asked which way
was up**, which is precisely what a picture is looked at for. §120 asks it
now, in both projections.

**A quantity name longer than the legend column runs off the paper**, and
this is a DN24 defect the geo work only exposed. The column leaves 160 px
and the title is written at 13 px with no fitting: *"People per square
kilometre"* measures 161 px and clips, which makes it a routine case and
not an edge one. Named here, unfixed, because the repair belongs in the
choropleth's own layout — wrapping needs a second text object, the DN22
lesson — and is the Principal's to call rather than mine to slip in.

**Said plainly and left out.** A Polygon contributes its outer ring and a
MultiPolygon the outer ring of its largest part: holes are dropped, and so
are the smaller islands, because the domain draws one simple polygon per
region and a reader is better served by a mainland than by a shape that
closes through its own holes. Skipped features are counted and the count
is readable, so a short map is known before it is looked at.

### The vendoring question, answered rather than deferred

**No asset is vendored, and the weight is the least of the reasons.** A
world outline at the coarsest usable scale is a few hundred kilobytes, as
the Principal said, and that alone would be arguable either way. The costs
that decide it are the ones a file's size does not show:

- **A boundary dataset carries a position.** Ship one and the library has
  an opinion on every disputed border in it, restated in every picture
  drawn from it, in a plane whose whole doctrine is that a picture must
  not assert what it cannot check.
- **It carries a vintage.** Borders and names change; a vendored file is
  right on the day it lands and silently wrong afterwards, with nothing in
  the plane able to say which.
- **It carries a licence and an attribution duty** that the consumer, not
  this library, would have to honour in whatever they publish.

None of those apply to a font subset, which is why one is committed and
this is not. **The kill line, written now rather than after the argument:
this plane vendors boundary data only if a caller demonstrates a workload
that cannot supply its own** — and the reader shipped here is what makes
that demonstration unlikely, because supplying your own is now three lines.

*Guard:* §120, 13 assertions, declaring `discharges("DN24b")` — the FeatureCollection read, the skipped
feature counted, the MultiPolygon's largest part, equal area proved equal
with the plain projection as its negative sibling, the two axes sharing a
unit, the standard parallel from the data and from the caller, the refusal
by name, and a map built from GeoJSON passing every rule the domain has.
Gate 1658 ok, 0 failed.

## PX — THE GATE'S DIET: the same 1,628 assertions in two thirds of the time (2026-09-11, SHIPPED)

**The one gate had grown to ten minutes** — 388 s of sections for 1,628
assertions after DN24 — and CENTRAL-PXLATENCY-01 says a section over
budget owes a diet or a split. The section clocks put half of it in two
sections, §91 (the governor over both catalogues, 115 s) and §92 (colour
as meaning, 84 s), and the probes found three costs, none of them an
algorithm:

- **The governance asked every scope for every PAIR of rules.** The
  contested-subject question called each rule's scope over each picture
  once per pair — 39,000 scope calls over 88 pictures where 2,900 answer
  the same thing. `CheckRules` tabulates every scope and counter once
  (`@aScopeTable`, `@aCounterTable`) and every question reads the table;
  `_SubjectsOverlap` reads it by rule index when it exists. Same answers.
- **A picture was solved three times.** Ring copies an object it stores in
  a list, and a copy of an *unsolved* picture solves itself again the
  first time a scope asks it anything: the corpus copy paid one layout,
  the gate's local copy another, and the gate's own governance a third —
  26 s of §91's governor was 52 layouts of pictures already solved
  elsewhere. `StzCheckPictures` now solves the picture in the CALLER's
  list before any copy, and `AddPicture` solves what it is given (a
  parameter is a reference), so every copy carries the solution.
- **The colour section resolved every shape once per name.** Its
  readability instrument resolved every filled region of a picture again
  for every name it measured — five thousand resolutions per name on the
  five-thousand-dot picture. The filled regions are read once per picture;
  every name is tested against the list. And a math diagram now lists its
  drawn names once per solve (`Texts()`, under the ink cache's law), which
  every name rule's scope reads.

**Measured on the section clocks, same run for both arms:** §91 115 s →
37 s, §92 84 s → 9 s, sections total 388 s → 267 s; assertions 1,628 →
1,628, findings unchanged. What remains is coverage bought on purpose —
§96 (the tape, 36 s), §94 (the content generators at scale, 25 s), §90
(layouts as starts, 19 s) — and the one law this minted for any code
that hands a picture to a list: **solve it before you copy it.** A copy
that solves itself is the plane's own copy-to-read defect wearing a
different name, and it hides because nothing in the source looks slow.

## THE NARRATED GUIDES: eleven domains, each walked through by a file that runs (2026-09-11, SHIPPED)

**A guide is a guard that reads as prose.** Eleven files in
`base/test/graphics`, one per domain from DN14 to DN24 — `gantt_`,
`er_`, `petri_`, `faulttree_`, `familytree_`, `timeline_`, `fishbone_`,
`network_`, `floorplan_`, `seating_`, `choropleth_narrated.ring` — each
in the house's narrated form: a scene that builds the domain's catalogue
picture from the same data the catalogue uses, prints what the picture
says about itself and asserts it; a scene that asks the domain's rules
of a sound picture; a scene that asks them of the witness and prints
every finding by rule and message; and a scene that writes the two
pictures as `guide_<domain>.png` and `guide_<domain>_witness.png`. A
math-plane guide reads its numbers back through `Substance()` (a task's
days, a year's width in pixels, a room's area, a region's class) and
asks the rules through `StzCheckPictures`; a graph-plane guide asks the
domain's own verbs (a net fired, a top's probability from its gates and
from its cut sets, a family walked for ancestors, a network walked for
hops) and its own `GovernanceFindings()`. 115 assertions, all green;
the pictures need a device, the numbers do not.

**What writing them found.** The family tree's `GovernanceIsSound()`
answers *no findings at all*, where the house report's `IsSound()`
answers *no errors*: a single parent draws a WARNING that says "if that
is meant", and by the tree's own word that makes the three generations
unsound. The guide narrates the warning as what it is; the two verbs
disagreeing is recorded here and not repaired unasked, since five domain
classes and their gates share the shape. Three Ring traps paid again:
`1e-9` is not a number literal Ring reads (spell the decimal); a render
puts the global `decimals()` back to two, so set it after the picture
and not before; and `oR` is `or`.

## A VERB THAT WRITES A FILE OWES THE CALLER A SAY IN WHERE (2026-09-11, SHIPPED)

**`RenditionAs(:image)` wrote a PNG to a name the caller could not
choose.** The display contract divides a rendition into two:
one that is **carried** (an SVG, a dot file, a line of text — its bytes
come back in the value) and one that is **located** (a raster, because it
cannot travel in a value, so a path comes back instead). A located kind
therefore *writes a file* — and both classes that answer one, the
mathematical picture and the notation picture, chose the name themselves:
`rendition_<domain>.png` and `rendition_notation.png`, in whatever
directory the caller happened to be standing in.

Three things a caller could not do. **Put it anywhere** — a consumer
writing into its own output folder could not. **Ask twice** — two
pictures of one domain, and the second landed on the first. **Keep a
tree clean** — which is how this was found: one of those files turned up
in this repository's own residue count on 2026-09-11, left by a guard
that had no way to ask for it anywhere else.

`RenditionAsXT(pcKind, pcPath)` on both classes, with `RenditionAtQ` as
its chainable spelling. **An empty path means the name the class would
have chosen**, so every caller written before today means what it meant.
**A path handed to a carried kind is refused by name**, not ignored: a
caller asking for an SVG at a path holds a wrong belief about the
contract, and being told costs less than being humoured.
`StzRenditionIsLocated(pcKind)` sits beside `StzRenditionExtension` and
answers which kinds write a file at all, from the kind alone — the one
place the two planes agree about it.

**And the guard that found it now cleans up after itself.** Proving the
default still works means letting it write, so the assertion writes,
checks, and removes — because a guard that proves a file was written and
then leaves it behind is the exact defect this section is about. It left
one on its own first run, which is how the clean-up got written.

*Guard:* §103 grew by five — which kinds are located, a caller naming two
places for one picture, the refusal on a carried kind with nothing
written, the default still standing, and the notation plane answering the
same verb the same way. The gate now leaves only `_`-prefixed scratch,
which the folder's ignore rule already covers, and the orphaned
`rendition_geometry.png` is removed from the repository. Gate 1636 ok, 0
failed.

## SOUND IS NO ERROR, NOT NO FINDING — one answer where there were ten (2026-09-11, SHIPPED)

**A severity is a dial every rule sets deliberately, and six places were
throwing it away.** Of the twenty-three rules the five picture domains
declare, **nine are warnings** — `union_has_two_partners` says *a single
parent, if that is meant*; `switches_form_no_loop` and `the_edge_is_guarded`
advise about a network's shape; `gate_has_two_inputs` says a gate with one
input is a wire. A warning means the picture may stand.

Ten places in this library answered *is it sound*. **Four read the severity**
— `stzRuleReport.IsSound`, `stzGraphRuleSet.IsSound`,
`stzPlasticGovernance.IsSound`, and `stzOrgChart.GovernanceIsSound`, which
asks its rule set rather than counting. **Six counted findings** —
`stzGraph.RulesAreSound` and the `GovernanceIsSound` of all five picture
domains. So one family tree, asked twice about one findings list, answered
**NOT SOUND from itself and SOUND from its own rule set**, and a report over
the same list agreed with the rule set.

`StzFindingsAreSound(paFindings)` in `stzGraphRule.ring` — where the unified
finding shape already lives — is the one answer now, and all ten call it or
delegate to something that does. This is the library's own law read back at
it: *reuse the house contracts, don't invent parallel ones*. The parallel one
was not written once and copied; it was written six times, each time by
someone who knew what sound meant and never asked what the house already
said.

**Found by writing a narrated guide, which is the transferable part.** The
guide prints what a picture says about itself before asserting it, so the
three generations printing `sound 0` beside one warning was visible in a way
it had not been in any gate — and the gate's own prose had said *"the three
generations pass"* since the day that section was written, four lines above
the verb that denied it. **A file that narrates what it checks catches a
disagreement between a sentence and a verb; a file that only checks cannot.**

*Guard:* §112 grew by three — the positive (tree, rule set, report and house
answering SOUND together), its negative sibling (an error, and not one of the
four calls it sound), and a check that the dial is real on both sides, so
neither can pass on a list whose severities are all the same. The narrated
family guide carries the pair too, where it was found. Gate 1631 ok, 0
failed; the four suites that assert these verbs — `graphruleset_narrated`,
`graphrule_object_narrated`, `orgrule_narrated`, `coderule_narrated` — all
green, 158 assertions between them. **No section time is claimed:** §91 read
15 s slower than its last run while the three control sections moved 1–4%,
and rather than wear that number either way, the section was checked for
calls — it makes **none** to any of the six changed verbs, and the one
`IsSound` it calls is the report's, untouched. A call count settles what a
clock on this machine cannot.

## DN9 — THE TOLD PICTURE: a narration is facts made visible, in an order (planned 2026-09-06, SHIPPED 2026-09-07 as DN9a through DN9g, all seven closed)

The Principal, after DN8h was explained to him with three diagrams drawn
by hand from the engine's own numbers, asked whether the library was now
"a mathematical computational visual thinking engine" for explaining and
teaching. The honest answer given was *half*: every mark in those diagrams
was a function of a fact the engine already held — a distance, a verdict,
a count, a position — and nothing in them was invented; but the engine had
no way to be *asked* to draw what it knew. So the gap is a vocabulary, not
mathematics, and this plane is that vocabulary. It is written at one level
above mathematics on purpose: a fact is anything a picture can answer,
including a notation's governance finding, so an org chart with a person
reporting to two heads is narrated with exactly the same five marks as
Byrne's plate.

**Three facts from outside this plane that shape it, read before the first
item, none of them this plane's to reopen:**

1. **The document is the sibling's.** `stznarrations` (design only, no
   code) owns the `.narration` format: a header, `PROSE` and `CELL`, three
   kinds with "a fourth a substance change to the grammar", and one law —
   *the document is plain text and outputs are never stored in it.* So a
   frame is not a document kind. A frame is **what a cell yields**, and a
   caption's numbers are **computed by a cell at run time**, never typed
   into prose. This plane emits that format; it does not extend it.
2. **The name `stzNarration` is spoken for.** The reference design v1.2
   ruled (obligation O1 in the sibling's ALIGNMENT.md, author-decided) that
   the existing `base/conversation/stzNarration.ring` — a speaker-tagged
   transcript — is renamed `stzTranscript`, freeing the name for the
   document class. This repository has not paid that obligation. The
   sequence object here is therefore **`stzStoryboard`**, the professional
   word for ordered frames with captions, and paying O1 is item DN9a, so
   that this plane is not the second thing to squat on the name.
3. **C7, the Display Contract, is stzlib's and unwritten.** Its first
   consumer's ask is on record: a *returning* display method — `Show()`
   prints at 196 sites and no notebook can capture a print — whose value
   declares its own kind (text, table, graph, vector, image, markup...).
   This plane makes the two picture classes answer in that shape and
   routes the result to Central as **evidence toward C7, not as C7.**

### The abstraction, in five words

**fact · mark · frame · storyboard · judged**

- A **fact** is anything a picture can answer, in one shape across both
  planes: `[ :kind, :subject, :value, :unit, :where, :message ]`. A
  measurement (`:distance` between two things), a verdict (a rule
  satisfied or violated, by how much — which is the rule report DN8c
  already produces, in the house shape `[ :rule, :subject, :where,
  :severity, :message ]`), a count (nodes, crossings, starts), a datum a
  substance carries, a position. **Facts are queried, never typed.**
- A **mark** makes a fact visible. Five kinds, and no sixth without a
  substance change to this plane, the way the grammar guards its three:
  | mark | shows | how it is drawn |
  |---|---|---|
  | `show` | a rule's boundary as a shape — the leash as a dashed circle, a clearance as a ribbon, a container as itself | derived geometry from the constraint's own arguments, in the picture's renderer |
  | `measure` | a dimension between two things, with its number | a line with ticks and a solved label |
  | `callout` | a sentence attached to a thing by a leader | a label whose owner is any shape — **solved exactly as a name is**, off ink and off other names |
  | `emphasis` | focus, dim, or ring | colour roles the theme already has (danger, success, muted), a ring at a point |
  | `region` | an area — the lawful set, a forbidden ribbon | a tinted or hatched shape derived from a rule |
- A **frame** is a picture, its marks, a **window** (the whole paper, or a
  zoom onto a region, marks following), and a **caption**: a sentence with
  holes, each hole bound to a fact, filled at render time.
- A **storyboard** is ordered frames. One content may appear under several
  readings (the catalogue's dark twins already do this), or changed by an
  action between frames — a drag (DN8g), a datum set (DN7j), a step of a
  generator (DN8f). It renders to a folio of PNGs, to one HTML page, and it
  **emits a `.narration`**: the captions as `PROSE`, the pictures and the
  filled holes as `CELL`s that recompute on arrival, so the sibling's law
  holds by construction.
- **Judged**: every frame passes the one gate (`StzCheckPictures`), and
  every number in every caption is asserted equal to the fact it was
  filled from. That is the claim no textbook can make: a lesson whose every
  picture is lawful and every number true, checked.

**What stays with the author, and should**: which fact to show first, what
to leave out, when to zoom. That is the teaching. The engine guarantees the
pictures and the numbers; it does not know what a learner needs to see.

**Refused, before the first item**: no animation or timeline (a frame is a
still; the live figure is the interaction, not the narration); no document
format of this plane's own (the sibling owns it); no slide framework; no
natural-language generation beyond sentences with holes; no pedagogy in
the engine; no sixth mark; no writing of C7 here. And **no hand-drawn
SVG**: the whole plane's kill is that the three diagrams drawn by hand on
2026-09-06 are regenerated by the engine with no picture code written by a
person.

### The items, in the order of leverage

- **DN9a — O1 paid: `stzNarration` becomes `stzTranscript`.** **SHIPPED**
  2026-09-06. The sibling's nine sites of 2026-08-11, verified today
  before touching any: the same nine, two of them thirty lines further
  down the loader than listed, and none in a test. Renamed the file, the
  class, the loader line and its comment, the conversation's member at
  its sixteen uses and its constructor, and the delivery comment whose
  reasoning the rename changed; the one design document that lists the
  construct by name updated at its four mentions. The judgement call the
  sibling left to this repository: `TranscriptQ()` is the accessor, and
  `NarrationQ()` stays one version as an alias that returns it. The
  transcript's header records where the name went and why. **Kill met:**
  no code names the old class; `classes()` holds the new name and not the
  old; the two conversation suites that exercise the class are 13 of 13
  and 52 of 52, identical before and after; a line added through the alias
  is seen through the name. *Guard:* §97, DN9a. One line to Central: the
  name is free, and the sibling may stop designing against a held one.

- **DN9b — Facts, one surface on both planes.** **SHIPPED** 2026-09-06.
  `Fact(kind, args)` on `stzMathDiagram` and on `stzDiagram`, both
  answering the one shape `[ :kind, :subject, :value, :unit, :where,
  :message ]` built by `StzFact()`. A unit rides along because 46.9 is not
  a fact and 46.9 px is; a sentence rides along because the sentence that
  describes a fact belongs to the fact, not to whoever quotes it.

  | plane | kinds |
  |---|---|
  | math | `expr` (the general one, asked in the picture's own rule language and answered off the same tape the solver used), `value`, `distance`, `angle`, `datum`, `position`, `count`, `term`, `tapenodes`, `arg`, `verdict` |
  | notation | `count`, `position`, `distance`, `verdict` |

  Two kinds are worth their own line. **`arg` reads a rule's own
  argument** — the clearance a name must keep, the bound a leash allows —
  from the term actually in force, addressed by words from its own line;
  those numbers were previously retyped into prose from the Style.
  **`tapenodes` compiles an expression and counts its nodes**, in the
  picture's variables or in its own, and with sharing off on request,
  which is how a narration *shows* what DN8h saved instead of asserting
  it; the engine's compiler gained `StzEngineGradCompileXT(expr, names,
  share)` for that, an instrument's door and nothing else's.

  **Verdicts are read, never recomputed.** The math plane answers from
  `Violations()`, the notation plane from its plastic governance's
  `Findings()`. A fact that recomputed a rule could disagree with the one
  gate, and a narration that disagrees with the gate is worse than no
  narration.

  **Kill met, and it convicted its own author.** Every number in the three
  diagrams hand-drawn on 2026-09-06 now comes from a `Fact` call — and two
  of them were wrong:

  | caption said | the fact says | why |
  |---|---|---|
  | the leash allows **44** | **43.73** px | I rounded a bound I had retyped |
  | **9** steps, then **5** | **11**, then **6** | I forgot that the exponent in `x^2` is itself a node |
  | 47 px from its dot | 46.89 px | — |
  | 22 px after the retry | 21.53 px | — |
  | 28,945 nodes, then 208 | exact | — |

  That is the plane's whole argument, arriving early and at my expense: a
  number a person types into a caption is a number nobody checks. The
  NEGATIVE is met too — a fact asked of a shape the picture never minted,
  a count it does not keep, or a kind neither plane answers is refused by
  name with the reason.

  *Guard:* §98, DN9b.

- **DN9c — The five marks.** **SHIPPED** 2026-09-07. `Show`, `Measure`,
  `Callout`, `Emphasis` and `Region` on `stzMathDiagram`, as methods a
  frame calls after the solve. No sixth without a substance change to this
  plane, argued here, the way the narration grammar guards its three kinds.

  | mark | what it makes visible | where its geometry comes from |
  |---|---|---|
  | `Show(rule)` | a rule's own boundary | the term in force: `lessThan(dist(a,b), r)` becomes a circle at `b` of radius `r`, read as a fact |
  | `Region(rule)` | the area a rule forbids | a `disjoint` against a line becomes the strip two pads wide, its corners derived from the segment's own direction |
  | `Measure(a, b)` | a distance, with its number | the line runs centre to centre and the number IS the distance fact |
  | `Callout(target, text)` | a sentence, tied by a leader | the sentence may carry `{value}`, filled from a fact; the leader is derived from the label's solved centre |
  | `Emphasis(target, mode)` | focus, dim or ring | the shape's own stroke, or a circle at its measured extent |

  **A mark cannot move the figure it describes.** Every existing unknown is
  pinned while a mark places itself, using DN8g's own pinning, so frame
  two's figure is frame one's figure to the last pixel — the guard asserts
  all eight vertices unmoved. And **a mark's sentence is solved, not
  placed**: it is a label, held off every name already in the picture, off
  the thing it is about, and off every drawn line, by the same `disjoint`
  terms a Style writes for a vertex's name. That is why a callout needed no
  new solver.

  Three things the first draft got wrong, each fixed by a law already on
  the books. The sentence landed on top of the vertex's own name, because
  I had described it as held off other names without adding those terms.
  It then got one random start direction and no second chance, which is
  exactly DN8h's defect, so `_RetryLabels` now serves marks too — and
  `_RedrawLabels` learned to skip a **pinned** label, since it writes
  values directly and would otherwise walk straight past a pin the
  optimiser respects. Last, a hard leash round its subject left a
  two-hundred-pixel sentence nowhere to stand and reported a violation the
  author could not act on: nearness is an **encouragement toward a ring**
  now, DN7d's law about objectives that minimise onto a non-differentiable
  point, and the leader carries the association instead.

  **Kill met.** The "what a name must satisfy" diagram of 2026-09-06,
  drawn by hand, is regenerated by the engine with no picture code written
  by a person: the leash is a `Show` of the `lessThan(dist)` rule at its
  own bound of 43.73 px, the forbidden strip is a `Region` of the
  `disjoint` rule at its own pad, the vertex is ringed, and two sentences
  carry numbers filled from facts. The one gate judges it and returns zero
  findings.

  *Guard:* §99, DN9c.

- **DN9d — The window.** **SHIPPED** 2026-09-07. `SetWindow(cx, cy, w, h)`
  and `WindowOn(path, reach)`, with `ClearWindow`, `Window`, `HasWindow`,
  `WindowScale`, `IsInWindow` and `VisibleShapes`. The drawing maps the
  window onto the paper at a uniform scale, so a frame may show a part.

  **The window is a property of the view, not of the figure.** Nothing the
  solver owns moves, and every reader keeps answering in the picture's own
  coordinates: the guard asserts a distance read at 3.05x equals the same
  distance read unzoomed, bit for bit. That is the only way a narration can
  say "the same figure, closer" and be believed. **What does not scale is
  the type** — a name keeps the size it was measured at and only travels,
  because a close frame is for reading rather than for enlargement; stroke
  widths do scale, since a hairline blown up three times and still one
  pixel wide reads as a different picture.

  **The gate judges what is visible**, as a fifth math rule:
  `mark_inside_the_window` reports a mark left outside the part being
  shown, which is the one defect a zoom introduces that a full view never
  had. With no window every mark is out of scope, counted and reported as
  such rather than passed over.

  One thing measured and fixed: `IsInWindow` first read every shape as a
  centre and a reach, which is right for a dot and wrong for an arc, and
  it hid **60 of 65** shapes on the first ask. A shape's box is now built
  from what it actually covers — a curve's sampled points, a polygon's
  vertices, a mark's strokes — and the same view reports 7 of 65, which is
  what the picture shows.

  **Kill met:** the v111 pair of 2026-09-06, both solves, one zoomed window
  each, rendered by the engine. In the first the name sits past the leash
  circle's edge; in the second it sits well inside it. Same content, same
  marks, two frames.

  *Guard:* §100, DN9d.

- **DN9e — The engine draws its own thinking.** **SHIPPED** 2026-09-07.
  `StzEngineGradDump(handle)` gives the tape itself as text — a root line
  then one line per step, `op|k|a|b` — and `StzTapeGraph(handle)` turns
  that into an `stzGraph`, one node per step labelled with its own sign,
  an edge from each step to what it consumes. `StzTapePicture(expr, names,
  shared)` compiles both ways and hands back a substance, so the arithmetic
  is drawn by the same two planes that draw everything else, with no
  picture code of its own.

  **Why this is worth a function rather than a diagram somebody draws.** A
  tape's shape cannot be read from the text that made it: the same
  subexpression written a hundred times is one node, and the count alone
  does not say which one. A drawing made by hand from the text shows the
  text's shape, not the tape's — which is exactly the error that put nine
  and five in a caption where the truth was eleven and six.

  **Kill met**, on the DN8h expression `(x-y)^2 + (x-y)^2`:

  | | engine says | the graph holds | edges |
  |---|---|---|---|
  | shared | 6 nodes | 6 nodes | 5 |
  | written out | 11 nodes | 11 nodes | 10 |

  **A step consumed twice is recorded, not dropped.** `stzGraph` is simple
  and holds one edge per pair, and a shared root reads its operand twice —
  which is not a degenerate case here but what sharing looks like from
  above. The multiplicity goes on the consuming step, so the drawn root
  reads `+ (x2)` and a reader is told rather than shown one arrow and
  misled.

  **Refused above two hundred steps**, deliberately: a drawing of Byrne's
  twenty-nine thousand is a measurement and not a picture, and the refusal
  names `Fact(:tapenodes)` as the thing actually being asked for.

  *Named and not done:* the pictures come out through the graph plane's
  own box-and-arrow style, which is a data-flow layout rather than a tree
  layout, so the drawn tape sprawls where a hand-drawn tree would nest. The
  structure is exact and the reading is worse; a tree style for expression
  DAGs is a separate item nobody has asked for yet.

  *Guard:* §101, DN9e.

- **DN9f — The storyboard.** **SHIPPED** 2026-09-07.
  `stzStoryboard(name, picture, folio)` in `base/graph/stzStoryboard.ring`:
  frames in order, each adding marks, moving the view or changing the
  content, and each carrying one sentence. `Frame`, `FrameOf` (a second
  picture), `Bind` (a hole to a fact of this picture), `BindFact` (a fact
  from any plane), `ExpectFindings`, the five marks and the window
  forwarded, `Act` for a drag or a datum, then `Render` for the page and
  `ToNarration` for the document.

  **A caption carries holes, never numbers**, and a hole is filled when
  its frame closes, from the picture as it stands in that frame. **Every
  frame is judged as it closes** — through the one gate, and every filled
  hole against the fact it came from.

  Two things the building taught, both now law here:

  - **A frame may be ABOUT a picture the gate faults, and that is not a
    defect in the telling.** "Here is what goes wrong" is the commonest
    didactic frame there is. So a frame declares `ExpectFindings()`, its
    findings become its subject, and — the negative that keeps the flag
    honest — a frame that expects a finding and gets none is itself
    reported.
  - **A hole is held to the form the caption asked for.** A caption may
    show a fact's number, its sentence or its unit; holding it to the
    number when it quotes the sentence is the check misreading the
    caption rather than the caption misreading the fact. A fact bound and
    never quoted is reported too.

  **The plane's kill, met twice.**

  | | frames | numbers, none typed | judged |
  |---|---|---|---|
  | the explanation of 2026-09-06 | 4, over two solves of one content | 3 | clean |
  | an org chart with a governance finding | 3 | 2 | clean |

  The second has **no mathematics anywhere**: five positions, the org
  plane's own `no-orphan-position` finding quoted in a caption about a
  drawing that never reached it, the orphan ringed and called out, and
  the repaired chart as the last frame. The same five marks, the same
  holes, the same judge. *One correction to this item's own kill text:*
  it promised "the person with two managers", and the library has no
  dual-reporting rule — it has orphan, cycle, span-of-control and
  separation-of-duties. The story uses a finding the library really
  produces rather than a rule invented to match the prose.

  **The emitter, written and marked provisional.** `ToNarration()` writes
  the sibling's `.narration` v0 grammar — NARRATION, PROSE and CELL, three
  kinds and no fourth — and pins that version in the file. Its one law is
  honoured by construction: **a caption goes out with its holes still
  open, and every number is a CELL that recomputes on arrival**, so
  nothing is stored that could go stale. DN9-EMITTER-01 was routed to
  `stznarrations` through Central on 2026-09-06 and is unanswered; the
  harness rule is that silence is never a veto, so this is written against
  the published sketch, pinned, and a correction costs one function.

  *Guard:* §102, DN9f.

- **DN9g — C7 evidence.** **SHIPPED** 2026-09-07, and it closes the plane.
  Four classes — `stzMathDiagram`, `stzDiagram`, `stzGraph`,
  `stzStoryboard` — answer `Rendition()`, a value that says what it is
  before it says what it contains: `[ :kind, :mime, :content, :locator,
  :title ]`. `RenditionAs(kind)` and `RenditionKinds()` beside it, and
  `StzRenditionOf(object)` is the one door a consumer knowing no class
  uses.

  **Kill met:** a script holding four objects of four classes renders each
  one, choosing its surface and its file type from `:kind` alone and never
  asking what any of them is — a solved picture and a notation picture as
  `vector`, a tape as `graph`, a storyboard as `markup`. A class the
  contract has not reached is refused by name rather than answered with
  nothing.

  **The evidence this repository owes C7's first consumer**, measured here
  on 2026-09-07 and recounted by the guard so it cannot go stale:

  | | |
  |---|---|
  | `Show()` defined | 113 times, and it prints |
  | `Display()` defined | **6 times**, meaning two incompatible things |
  | `Rendition()` defined | 4 times, all new |

  **And the correction that matters more than the counts.** The consumer's
  ask reads *"`Display()` exists at 13 sites and is, in every one read, an
  alias of `Show()`"*. In this repository today there are **six**, and
  they already mean **two incompatible things**:

  | what `Display()` does | where |
  |---|---|
  | prints, as an alias of `Show()` | `stzString`, `stzOperatingSystem`, `stzGraph`'s table face |
  | launches an external program | `stzGraph` via `RunAndView()`, `stzDiagram` via `ExecuteAndView()`, `stzDotCode` via `View()` |

  **`stzGraph` carries one of each**, which is the sharpest form of it. And
  the decisive test needs no list of verbs at all: **not one of the six
  contains a `return` in its body.** Three different launcher verbs appear
  among them — `View()`, `RunAndView()`, `ExecuteAndView()` — which is why
  the guard tests for the return rather than for the launcher. So C7 cannot take this name
  without first deciding which of its two existing meanings to break. The
  name used here is `Rendition()`, and the contract may still choose
  otherwise as long as it chooses knowing that. *My own first count of
  this was two, and the guard's recount said six — which is the reason the
  guard recounts.*

  **A raster is located, not carried.** SVG, Graphviz source and HTML
  travel inside the value; a PNG cannot, so `:image` fills `:locator`
  instead of `:content`, and the consumer is told which of the two it got
  rather than having to guess from an empty field.

  *This is evidence, not the contract.* C7 is stzlib's to write, across
  the whole library, and four classes are four classes. What they
  demonstrate is that the shape works and that the recommended name does
  not.

  *Guard:* §103, DN9g.

## DN2b — THE RING: a state machine is not a tree (2026-08-23)

The Principal's deepest correction of the plane, and it invalidates an
assumption every picture before it carried: *"you still consider a state
machine diagram as a tree diagram, it isn't. Take the spatial metaphor of
a space with states as cells sitting around its border, and for some of
them when it is required, in the middle."*

**Layered layout answers "what flows into what".** It is built for a DAG,
and it treats a cycle as a defect to be oriented away. A statechart has
no flow direction: its states are PEERS and its edges are EVENTS. Every
mark on the layered state machines — the knot of channels, the
scrambling, the arbitrary up-and-down of states that have no up or down
— traces to that single mistake. **Graphviz says the same thing by
shipping two programs**: `dot` for hierarchies, `circo`/`neato` for
everything cyclic. We had been drawing a `circo` problem with `dot`'s
model.

### What shipped

**A notation may declare THE LAYOUT IT IS READ IN** — the strongest
grammar amendment in DN, and one line in the profile:
`SetLayoutMode(:Ring)`. The state machine declares it; everything else
stays layered, so the ring is a declaration and not a new default.

`_LayoutRing()` in `stzGraphCanvas`, built to the metaphor:

- **the border** — peers on a circle, no state above another because none
  is
- **the middle** — a HUB (degree ≥ 4 and talking to half the machine)
  moves inside, where its edges become short radials instead of chords
  sawing the space in half
- **the order** — a traversal, so states that talk are neighbours and an
  event is a short chord, then adjacent swaps kept only when a COUNTED
  crossing number falls. Two chords cross iff exactly one endpoint of one
  lies strictly between the other's: that is the whole geometry of a
  circular layout, and it makes the improvement an honest hill-climb
- **the entry** — the initial pseudostate opens the ring at the top

### What the ring made visible elsewhere

- **A ring needs a SQUARE inner box.** The inset is half a cell plus air,
  and a cell is wider than it is tall, so a square canvas still handed
  the layout a 768×832 box and the circle arrived as an ellipse — border
  radii 32px apart. Ring renders inset equally on both axes.
- **A chord must hold its event.** The shortest chord is the radius, and
  BOTH members of an opposite pair write on it. A circumference-sized
  radius left 50px for two labels. The radius now also clears both cells
  plus two stacked labels — the "the line must be longer than what is
  written on it" rule, in the ring's own geometry.
- **A pair separates on a chord too**, and the perpendicular must come
  from a CANONICAL direction: computed per edge it flips with the edge,
  so both members stepped the same way and overlapped instead of
  separating.
- **A straight edge now PUBLISHES its drawn path.** Ortho edges have done
  so since the label placer needed one; chords and curves never did, so
  under a non-ortho spline every instrument — and the placer itself —
  fell back to guessing.
- **A self-loop radiates outward** on a ring: the two rank-derived sides
  (top, right) cover a top or right cell, and the other two were added
  for cells at the bottom and on the left, whose loops were otherwise
  drawn INTO the space, across the chords they sit among.

§56 holds it: one circle for the peers and the hub off it, a square
space, the entry at the top, a counted crossing number of zero, chords of
a pair on opposite sides — and the negative sibling, that a diagram
declaring no layout mode is still layered.


## DN2c — THE LIFECYCLE TEMPLATE, and what outranks what (2026-08-23)

The Principal's second correction on state machines, on top of "a state
machine is not a tree":

> *"Positioning logic in state machines does not depend only from the
> concentration of links. The real-world semantics and reader mental
> model as well as UX habits and best practices all enter in play:
> reading happens from top to down and from left to right, the very last
> things to happen on the machine must be at the bottom right, and start
> at the top; other events take each a spatial column from left to right
> to understand visually the organic steps, even if events happen in an
> uncontrollable manner."*

And, in the same breath, that the ring had **thrown away the elegance**:
the colours, the visual semantics, the space optimisation and the edge
fluidity the layered grammar had spent weeks earning.

**Both critiques have one answer: the domain's template is a LIFECYCLE,
drawn in the layered grammar.** Not a third dialect — the same ortho
staircase, twin rails, rounded elbows, per-gap pricing, label laws and
space contract, pointed left-to-right so that stages become columns.

### The ordering law this mints

**READING ORDER OUTRANKS LINK CONCENTRATION.** The ring placed `Closed`
at the centre because four transitions met there; a reader does not
care. What a reader needs is where the life of the thing begins and
where it ends. So:

- **a SOURCE leads its column** — the first thing sits where reading
  starts
- **a SINK sinks** — last column, bottom of it: the very last thing to
  happen sits at the very end of the reading direction
- and these are **derived from the rules the notation already
  declares** — a kind that forbids `:Inbound` IS a source, a kind that
  forbids `:Outbound` IS a sink. One declaration, two consumers, no way
  for the placement to disagree with the refusals.
- the sweep still minimises crossings **within** those constraints:
  reading order is applied after it, because a crossing or two costs
  less than a lifecycle read backwards.

### What the template made visible

- **A self-loop had a side per rank direction, and that was wrong.** LR
  put loops on TOP — exactly where the lifecycle's return channels run,
  so `Locked`'s loop was drawn across the `close` and `unlock` rails.
  One side for every direction now (the right border), which is also
  one size reservation instead of two.
- **A self-loop's label followed an assumption, not the ink.** With the
  loop's side no longer a function of the rank direction, the label
  reads the DRAWN path and stands off its outer extreme — so the loop
  publishes its path like any other edge.
- **A label could only stand at a segment's MIDDLE.** In a lawful funnel
  — two returns sharing their arrival lane, a drop crossing the run at
  its centre — every midpoint touched foreign ink, and the least-bad
  rule put `unlock` on a line it does not name. A label SLIDES along its
  own segment now; the middle is the first seat it tries, not the only
  one.

§57 holds the template: first thing at the start of the reading, last
thing at the bottom-right, stages as columns, the picture space-
optimised, the pair on twin rails, the loop publishing its path.

### What this section left for later, and what answered it

The **ring survives as a declared layout** for graphs of genuine peers
(§56) — it is right for a network, wrong for a lifecycle.

~~And the Principal has named the next inspiration: **DRAKON**~~ —
**CLOSED as DN6, 2026-09-03.** The Russian visual programming language
whose editor he calls the best visual language for designing any diagram,
embraced as a first-class citizen. Its governing ideas — a single vertical
"skewer" for the main path, no crossing lines by construction, the happy
path always leftmost — were a much stronger version of the lifecycle rule
this section mints, and they became DN6: the notation profile, the
twenty-scene catalogue, and §73k through §73z.

*This paragraph said DRAKON was "the next deep task in this plane" until
2026-09-04, the day after DN6 shipped it. THE CHECK CANNOT SEE THIS ONE.
`plan_calls_closed_work_open` reads a heading against the items under it,
and this heading never claimed openness — the staleness was inside the
prose, where a rule that does not know what DN6 means cannot go. It is
recorded here so the check's REACH is written down next to the check, and
not mistaken for its coverage.*


## DN2d — MODES: the state machine's own model (2026-08-23)

Three templates were wrong before this one, and all three in the same
way. The Principal, refusing the third:

> *"A state machine is not a life cycle! You should understand its use
> case in the real world, where it fits dynamic flows that are NOT
> deterministic, since events and change of state are what determine
> their flow. Maybe you should build its own model."*

He is right, and the sources say so plainly. **Lucid's UML tutorial:** a
state diagram is *"not necessarily the best tool for capturing an overall
progression of events"* — it shows *"how an object gets to each state"*.
**The practitioners' thread:** statecharts tame complexity by letting a
group of states *share their event handling*, i.e. by GROUPING, not by
placing more cleverly. **Mermaid's syntax** confirms the structural
vocabulary a real notation needs: `[*]` entry/exit, composite states,
`<<choice>>`, `<<fork>>`/`<<join>>`, concurrent regions with `--`.

A tree drew a progression. A ring drew a space with a centre. A lifecycle
drew a progression again, sideways. **Every one of them answered "what
happens NEXT", and a state machine has no next**: it sits somewhere and
waits, and what happens is whatever event arrives.

### The model

What may a picture honestly order? Exactly one thing, and it is a fact
about the graph rather than a taste:

- **INSIDE a set of mutually reachable states there is NO order.** Closed
  → Open → Closed, all day; which one you are in is decided at runtime by
  events. Drawing those as a sequence is a lie — the lie all three
  templates told.
- **BETWEEN such sets the order is REAL and IRREVERSIBLE.** A demolished
  door is never closed again.

So: **a MODE is a strongly connected component** — a region the machine
lives in, whose states are peers. The picture **ranks the modes**, whose
condensation is a DAG by construction, and leaves the states inside each
mode unordered, side by side, inside a drawn **region**.

This is Harel's answer arriving from the other direction: a mode is
exactly the group of states that share their event handling, **discovered
from the graph rather than declared by the author**. And it makes the
picture's structure a consequence of the model — change the graph so a
broken door can be repaired, and `Broken` JOINS the mode, with no layout
knob touched anywhere. §57 asserts precisely that, which is what makes it
a test of the MODEL and not of a picture.

### What it reuses

A mode is drawn with the **cluster machinery** — boundaries, chrome, air,
the containment guard — because a region IS a cluster and inventing a
second kind of box would be the `stzBpmnDiagram` mistake again. **An
author's own clusters always win**: discovery fills a vacuum, it never
overrules a declaration.

Sizing follows the house contract: the widest rank in states across, the
mode depth down, region chrome paid once per region rather than per rank.
And a mode gap carries ONE transition — a one-way door out of a region —
rather than a fan riding a shared channel, so it is priced for one label
and the picture is a quarter shorter for saying so.

### What is refused, and what is next

- **Single states are not regions.** A box inside a box says nothing.
- **Regions are unlabelled.** The graph knows those states belong
  together; it does not know what to CALL the grouping, and a
  manufactured name is noise a reader must ignore. An author who wants
  one declares the cluster.
- **Still to build, from the sources:** the transition grammar
  `trigger [guard] / effect`; explicit composite states (author-declared
  nesting, the other half of Harel); `<<choice>>`, `<<fork>>`/`<<join>>`
  pseudostates; concurrent regions; history. Each is a vocabulary and
  glyph addition on this model, not a new layout.
- **And DRAKON**, which the Principal has named as the next inspiration
  and wants embraced as a first-class citizen.

### The lesson, which cost three templates

A layout is a **claim about what kind of thing is being drawn**. Choosing
the wrong one is not a cosmetic error, and no amount of edge polish
repairs it: three rounds went into channels, labels and rails inside
templates that could not be right. The question to ask first is not "how
shall I place these" but **"what does this domain's reader actually want
to know, and what may I honestly order?"**
