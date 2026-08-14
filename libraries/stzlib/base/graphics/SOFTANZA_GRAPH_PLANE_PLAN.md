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

### Still open

- **Clusters do not constrain layout.** `_ClusterBox` draws a box around
  whatever the layout produced; it does not keep a cluster's nodes
  together. A cluster whose members scatter gets a box containing
  strangers.
- **Self-loops and parallel edges** are drawn as degenerate segments.
- **Edge labels** have no reserved space.

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
