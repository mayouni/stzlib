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
