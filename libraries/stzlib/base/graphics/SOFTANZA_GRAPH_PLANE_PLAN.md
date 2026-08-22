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

## 2. Phases

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

### GG2 — `stzGraphCanvas`: the declarative face

`oG.ToCanvasQ([ :Layout = :Hierarchical, :SizeBy = :Impact, :ColorBy =
:Depth ])` → an `stzCanvas`, so it inherits BOTH tiers free (SVG with no
device, PNG through one) exactly as plots and org charts did in GR6.
Node size/colour/label bind to COMPUTED graph properties, not to
hand-set attributes — that binding is the whole point.

KILL CRITERION: if the face cannot express the supply-chain risk picture
already produced by hand in the spike, the abstraction is wrong and gets
redesigned before anything is built on it.

### GG3 — the scene graph: hierarchy as the same primitive

Parent/child transforms for `stzScene` (today's instance list is flat, so
articulated models — a robot arm, a solar system — are impossible).
Propagate world transforms down the hierarchy with GG0's mechanism: a
DAG, iterated to depth, on device, no readback. §3b door 4 already keeps
transform state separate from render state, so this is an addition, not
surgery.

KILL CRITERION: if hierarchical propagation cannot stay on-device — if
any frame needs a CPU round trip to resolve parents — it falls back to
CPU-side composition and the claim shrinks to "scene graphs work",
without the zero-copy property.

### GG4 — the frame graph: passes and resources as a DAG

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

Recorded in §4 as the sharpest open design question. It belongs to
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

## GG7 / GG8 REFLECTED — the live diagram, and the diagram larger than its medium
*(2026-08-19, reflection before any code; the Principal named both features)*

The two features look unrelated and are the same architectural statement:
**the retained engine scene is the single source, and every face — editor,
pager, screen viewer — is a viewport over it with different input.** That
extends this plane's thesis one step: the picture has been *a question
answered about the graph*; now the question can also be *"which cell is at
this point"* and *"which part of you fits this page"*.

### GG7 — stzLiveDiagram: the layout becomes a suggestion, the picture becomes an input device

**THREE OF FIVE DELIVERED 2026-08-21.** The model half is done and
guarded; the window half is not started.

- **GG7a, picking** (72308ddc7). `sceneSetPickTag`/`scenePick` in the
  engine, `SetPickTag`/`Pick` on stzCanvas, `PickAt` on stzDiagram
  answering `[ :node, id ]` / `[ :edge, from, to ]` / `[]`. Kill
  criterion MET and measured: **0.28 ms a pick on a 500-node diagram**,
  300 of 300 hits, against a 1 ms budget. Section 40.
- **GG7b, pins** (3cfcf714b). `coordsPinned` in the engine, pins through
  stzGraphCanvas, `Pin`/`Unpin`/`IsPinned` on stzDiagram. A pin decides
  ORDER as well as position — without that it decided nothing visible,
  because rank order is settled before coordinates and `_Normalise`
  refits the box afterwards. Section 41.
- **GG7c, the command log** (edbe91454). `Edit(kind, args)` with
  inverses, `Undo`/`Redo`, over the model's existing mutation API and
  its existing refusals. Section 42, nineteen assertions.

- **GG7d, the interaction** (6de2d40a7). Four states — idle, dragging,
  linking, labelling — fed explicit events, so the machine is a function
  of (state, event) and is tested headless. Section 43.
- **GG7e, the session** (this commit). `Step(window, options)` is one
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
