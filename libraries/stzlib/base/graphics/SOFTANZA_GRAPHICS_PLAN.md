# SOFTANZA GRAPHICS PLAN — analysis and phased plan (GR0–GR6)

Status: PLAN OF RECORD, written 2026-08-08, before any code. The sibling
document is `base/gpu/SOFTANZA_GPU_PLAN.md` (G0–G6, complete): this plan
inherits its laws, its lifecycle layer, and — decisively — its vendor.

The product vision (the author's words, four requirements — the last
two added 2026-08-08, and they CHANGED two decisions below, marked):

1. **Softanzified programmability** — a DECLARATIVE experience for
   designing graphics in Ring, the way stzRegexMaker made regex
   declarative and stzKernelMaker made GPU compute declarative.
2. **A highly efficient backend** — GPU-based, riding the numerical and
   lower-level assets already in the house (the wgpu plane, the SIMD
   engine loops, the multicore tier, the batched-pass machinery).
3. **Unicode text is a REQUIREMENT, not a refinement** — Arabic named
   explicitly: bidirectional layout, contextual joining, mandatory
   ligatures. A graphics plane that renders "Softanza" but garbles
   "سوفتانزا" fails the library's own multilingual identity (the
   stress-test method has demanded "large + multilingual" all along).
4. **All OSs** — Windows, Linux, macOS as peers. Windows-first was a
   sequencing convenience elsewhere; here portability is a contract.

And one procurement rule, unchanged: vendor wisely — smart, useful,
easy, LIGHTWEIGHT, like every tool this repo has selected.

---

## 0. The facts that shape everything (surveyed, not assumed)

**FACT 1 — the GPU rasterizer is ALREADY VENDORED.** wgpu-native
v29.0.1.1 is not a compute-only API: the vendored `webgpu.h` carries the
full render surface — render pipelines, vertex/fragment WGSL stages,
textures, samplers, surfaces, swapchains (79 render-API declarations).
The G-plane only ever exercised compute. The single most important fact
of this analysis: **the heavy vendor decision for graphics was already
made, paid for, guarded (162+ asserts), and proven in-browser.**

**FACT 2 — the house already draws, in three unconnected ways:**
- `engine/src/plot.zig` (2,436 lines): six TERMINAL renderers on a
  codepoint canvas — finished pictures, no raster, no vector.
- The diagram family (stzDiagram/stzOrgChart/stzDotCode): generates DOT
  text and shells out to an EXTERNAL `dot.exe` for layout + SVG — the
  only external-binary runtime dependency in the library.
- stzStringArt / display: glyph art, terminal-bound.
None of the three can produce a PNG, shade a triangle, or share a
scene model. Graphics exists as three islands; this plan is the bridge.

**FACT 3 — the supporting assets are unusually complete:**
- zlib is vendored (PNG encoding = chunks + CRC over vendored zlib:
  pure Zig, ~200 lines, NO new image-writing vendor needed).
- The WGSL transpiler (gpu_wgsl.zig) is engine substance, zero-alloc,
  compiled into stz.wasm — the declarative-shader mechanism EXISTS.
- Batched passes, gen-keyed handles, counted fallback, calibration,
  TDR tiling: the entire render lifecycle discipline is built.
- The edge plane renders: G5 proved byte-identical WGSL executing in
  the browser. For graphics this is not a demo — the BROWSER IS A
  PRESENTATION TARGET (a canvas + the same kernels), via the delivery
  plane's existing HTML bundles.
- linalg/matrix are f64 (the solver tier); graphics wants f32 4×4
  transforms — small, pure Zig, deliberately SEPARATE from the oracle
  tier (its bit-stability contract must not be touched).

**FACT 4 — what is genuinely missing:** a 2D vector rasterizer (paths,
fills, strokes, gradients), the TEXT PIPELINE (see fact 5), image
DECODE (PNG/JPG textures), a scene/mesh model, and windowing.
Everything else is assembly of things that exist.

**FACT 5 — the Unicode ledger, honestly (surveyed 2026-08-08).** The
house owns real Unicode machinery: utf8proc vendored, the unidata
module with its database, the UAX#29 segmentation engine (word_break =
THE tokenization seam), codepoint-correct string ops everywhere. What
it does NOT own is anything text-RENDERING needs beyond that:
- **Bidi (UAX#9)** — reordering mixed RTL/LTR runs: absent.
- **Shaping** — Arabic contextual joining, mandatory ligatures
  (lam-alef), OpenType GSUB/GPOS: absent, and NOT implementable by
  stb_truetype, which rasterizes glyphs but processes no OpenType
  layout tables. A naive per-codepoint Arabic rendering is not
  "degraded" — it is WRONG (disconnected letterforms are misspellings
  to a reader).
- **Font raster** — TTF outlines → bitmaps: absent (stb_truetype's
  actual job, and it does it fine — by GLYPH ID, which is exactly what
  a shaper outputs).
So correct Arabic = a three-stage pipeline (bidi → shape → raster),
and only the last stage was in the original plan.

**FACT 6 — the cross-platform ledger.** wgpu-native publishes official
prebuilts for Windows/Linux/macOS on x64 and arm64 — the same
pinned-binary-with-checksum pattern extends per-OS. The engine already
builds per-OS (libuv's three-platform source lists in build.zig; the
Ring loaders already carry .dll/.so/.dylib paths). Zig cross-compiles
all three targets from one machine. The honest limit: the dev machine
is Windows — Linux/macOS get CROSS-COMPILE + CI verification from day
one, and RUNTIME guard runs as hardware becomes available; the plan
says so rather than implying tested-everywhere.

---

## 1. The vendor decision

Candidates evaluated against the house constraints (zig build, no
cmake, no SDK, flat C-ABI per-domain DLLs, Windows-first, WASM edge,
one-GPU-discipline):

| | wgpu render (in-house) | stb_truetype + stb_image | PlutoVG | NanoVG | raylib | SDL2/3 | Skia / Cairo | bgfx | sokol_gfx |
|---|---|---|---|---|---|---|---|---|---|
| Weight | **zero new** | 2 single-header C files | small C lib | small C | mid C | heavy | HUGE | mid C++ | single headers |
| Builds under zig, no cmake | ✓ (done) | ✓ trivially | ✓ | ✓ | mostly | painful | no | **NO — offline shaderc** | ✓ |
| GPU API | WebGPU (ours) | n/a (CPU) | n/a (CPU) | OpenGL | OpenGL | its own | its own | its own | wraps several |
| Edge/browser story | **proven (G5)** | n/a | n/a | none | none | none | none | none | partial |
| Fits one-GPU-discipline | **IS the discipline** | ✓ | ✓ | ✗ second GPU surface | ✗ | ✗ | ✗ | ✗ | ✗ duplicates wgpu |
| Declarative fit | WGSL from text (transpiler exists) | n/a | n/a | — | — | — | — | — | — |

**DECISION: no new graphics ENGINE is vendored.** The backend is the
wgpu plane we already own, extended from compute to render. The 2D
vector rasterizer is written IN ZIG (scanline path filling — the SIMD
loops and multicore tier apply to exactly this shape of work), with
the honest fallback that early phases can ship on the GPU raster + SVG
before the CPU rasterizer is complete.

**The vendored additions, revised for requirement 3 (this is where the
Unicode requirement changed the plan — the original said "stb only,
Latin first, shaping when a workload asks"; Arabic-as-requirement IS
the workload asking, on day one):**

- **stb_truetype.h + stb_image.h** — glyph rasterization (by glyph id)
  and texture decode. Single-header, public-domain C. Unchanged.
- **HarfBuzz, as its amalgamation** (`harfbuzz.cc` — ONE C++ file, no
  dependencies, its own OT shaper built in, C ABI out). THE text
  shaper: Arabic joining, lam-alef and every other mandatory ligature,
  GSUB/GPOS, all scripts. The vendor-table test it passes: compiles
  from source under zig c++ with no cmake and no SDK — the ggml
  precedent (a large C++ library built by Zig) already proved this
  road. Writing a shaper instead was REJECTED: presentation-forms
  tricks produce wrong Arabic on modern fonts, and OpenType shaping
  is a decade-deep specialty — exactly what wise vendoring is FOR.
- **SheenBidi** — UAX#9 bidirectional algorithm, small pure C, MIT,
  amalgamated build, zero deps. Vendored rather than written because
  bidi is edge-case-dense; the runner-up (recorded): a pure-Zig UAX#9
  verified against Unicode's own BidiTest.txt conformance file, if
  vendoring ever disappoints.
- **GLFW** — windowing + input on Windows/Linux/macOS (this is where
  requirement 4 changed the plan — the original said "raw Win32, zero
  vendor, other OSs deferred"; with all-OS a contract, hand-writing
  three windowing backends is exactly the wheel wise vendoring
  refuses to rebuild). Small C, per-platform source lists + defines,
  no cmake needed — the libuv vendoring in build.zig is the exact
  pattern, already executed. GLFW draws nothing; it yields the native
  handle wgpu makes a surface from. The zero-vendor Win32 route
  survives only as a fallback note.
- **wgpu-native prebuilts, per OS**: the pinned-binary-plus-checksum
  pattern extends to the Linux/macOS (x64+arm64) official releases in
  vendor/wgpu, same VERSION file discipline.

The full text pipeline is therefore: **SheenBidi (reorder) → HarfBuzz
(shape: codepoints → positioned glyph ids) → stb_truetype (raster
glyph ids → atlas)** — three vendors, each the smallest serious tool
for its stage, all Zig-compiled from source, none needing cmake.

Killed on principle, unchanged: **bgfx** (offline shader compilation =
the same SDK invariant that killed ggml-Vulkan), **NanoVG/raylib**
(OpenGL = a second GPU surface outside the counted-fallback
discipline), **Skia/Cairo** (weight; and note Skia would ALSO have
answered text — rejected because it answers everything else too),
**sokol_gfx** (a second abstraction over the API we already bind
directly), **ICU for bidi** (weight; SheenBidi is the scoped tool).
**PlutoVG** stays the named 2D-rasterizer runner-up (GR2 line).

**The dot.exe question, faced honestly:** graph LAYOUT (what dot does)
is a deep specialty; replacing it is out of scope. The diagram family
keeps shelling out to dot for layout. What changes: its SVG output
gains siblings (PNG via this plane), and simple non-graph diagrams stop
needing dot at all. Revisit trigger: a pure-layout library that passes
the vendor table above.

---

## 2. Architecture — the house laws, applied to pixels

- **The render engine grows INSIDE stz_gpu.dll.** Render pipelines,
  vertex/index/texture/target handles join the same gen-keyed table,
  the same VRAM budget, the same counted fallback, the same batched
  passes. Handles never cross DLLs; rendering and compute share ONE
  device — a compute pass (the numeric tier) can feed a render pass
  (this plane) without leaving VRAM. That composition — simulate on
  the compute plane, draw on the render plane, zero copies — is the
  differentiating capability, and no vendored engine would give it.
- **Output is a TIER LADDER, not a window assumption:**
  1. **SVG text** — vector output, no GPU, no window; the diagram
     family's precedent generalized. Every 2D drawing can always
     become SVG (CI-safe floor).
  2. **PNG bytes** — GPU offscreen render + readback, encoded pure-Zig
     over vendored zlib; CPU rasterizer as the counted fallback.
  3. **A native window** — GLFW on Windows/Linux/macOS as peers; wgpu
     makes its surface from the native handle GLFW exposes. (RingQt
     interop = hand it PNG frames; noted, not depended on.)
  4. **The browser** — the same scene, the same WGSL, through the
     delivery plane's bundles onto a WebGPU canvas (the G5 mechanism,
     now drawing instead of computing).
- **f32 graphics math is its own small module** (vec2/3/4, mat4,
  quaternion, camera) — pure Zig, SIMD where it pays, DELIBERATELY
  apart from the f64 solver tier whose bit-stability is contractual.
- **Text is a PIPELINE, and Arabic is its acceptance test**: SheenBidi
  reorders (UAX#9), HarfBuzz shapes (joining, mandatory ligatures,
  GSUB/GPOS), stb_truetype rasterizes the resulting glyph ids into the
  atlas. One engine-side entry (`text_layout(text, font, size)` →
  positioned glyph runs) serves BOTH renderers, so the GPU path and
  the SVG path cannot disagree about where letters sit. Two honest
  notes: (a) on the SVG and browser tiers the CONSUMING renderer
  (browser, Inkscape) shapes text natively — Arabic is correct there
  even before our pipeline lands, and the guard exploits that as an
  independent reference; (b) the pipeline is script-general by
  construction (HarfBuzz), so Arabic-as-requirement buys Hebrew,
  Devanagari, Thai and CJK vertical opportunities without new vendors
  — but only Arabic + Latin + mixed-bidi are GUARDED initially, and
  the guard corpus says which scripts are claimed. Guard fixture: a
  small OFL-licensed Arabic font SUBSET, committed, generated
  deterministically by a fixture tool (the tiny_bert.gguf pattern
  applied to fonts) — so CI shapes real Arabic with no download.
- **Every phase gates on measurement** with kill criteria written
  before the numbers, and every claim lands in a narrated guard with
  its negative sibling. CI has no GPU: the SVG tier and the refusal
  paths are the CI coverage, exactly as the G-plane guards do it.

**Level-1 surface (corrected 2026-08-09 to the house naming law — the
sketch that shipped in this plan violated it, and GR4 builds from the
corrected form, not from the old one):**

The three rules, stated so GR4 cannot drift from them:
1. **A method is an explicit VERB acting on the object** — `AddCircle()`,
   `AddFont()`, `SetBackground()`. Not a noun (`Circle()`), which says
   what a thing IS rather than what the call DOES.
2. **`...Q()` performs the same action and returns the MAIN object**, so
   chains never leave the canvas — there are no intermediate shape
   objects to hold or lose. The plain twin ACTS and returns NOTHING
   (the core's `AddItem` / `AddItemQ` law, applied to pixels).
3. **`To...()` names stay** — `ToSVG()`, `ToPNG()`, `ToWGSL()` — because
   they are already unambiguous about what they do, and they return
   DATA, which is what a plain form must do.

<!-- -->

    # 2D -- the plain form acts; nothing comes back
    oC = new stzCanvas(800, 600)
    oC.SetBackground("#101418")
    oC.AddCircle(400, 300, 120)
    oC.Fill("#e0a030")                 # applies to the last shape added

    # the same, fluent -- every Q returns the CANVAS itself
    oC.AddCircleQ(400, 300, 120).FillQ("#e0a030").StrokeQ("#ffffff", 2)
    oC.AddTextQ("Softanza", 330, 310).SetFontQ(oFont, 24).ColorQ("#ffffff")

    oC.ToSVG()                      # tier 1 — always works
    oC.ToPNG("out.png")             # tier 2 — GPU offscreen (or CPU)
    oC.Show()                       # tier 3/4 — window or browser

    # 3D: the same law, one object deep
    oS = new stzScene(800, 600)
    oS.SetCamera(0, 2, 5, 0, 0, 0)
    oS.SetLight(:Directional, 1, 1, 0)
    oS.AddMesh(oCube, 0, 0, 0)
    oS.SetMaterial(1, oM)
    # fluent twin
    oS.SetCameraQ(0, 2, 5, 0, 0, 0).AddMeshQ(oCube, 0, 0, 0).ToPNG("frame.png")

    # materials: the W-string → WGSL story, extended from G4
    oM = new stzMaterialMaker()
    oM.TakesColor(:base)  oM.TakesScalar(:glow)
    oM.ForEachFragment('{ @out = base * (1.0 + glow * @normal.y) }')

The maker pattern, the Q convention, Show() = visualize Content(), and
the transpile documented by its output (ToWGSL) — all inherited.

---

## 3. Phases

**GR0 — the render spike (go/no-go, measurement only).** Extend the
G0 spike style to render: offscreen target + one triangle + one
textured quad through the VENDORED wgpu, readback, pure-Zig PNG over
zlib. Measure: offscreen render+readback ms at 800×600/1920×1080; PNG
encode ms; a 10k-primitive 2D batch vs a naive CPU fill of the same
pixels. KILL CRITERIA, written now: if offscreen render+readback+encode
of a simple frame exceeds ~50 ms at 1080p (i.e. not even 20 fps for
STILLS), the GPU raster tier is demoted to "3D only" and 2D ships
SVG+CPU; if the render API surface demands lifecycle surgery that
compute didn't (new binding model, incompatible with batched passes),
STOP and re-plan before building on it.

**GR1 — render lifecycle in stz_gpu.dll.** Render-pipeline cache (WGSL
text-keyed, like compute), vertex/index/uniform/texture/target handles
in the SAME gen-keyed table, offscreen targets, readback, PNG encoder,
stb_truetype + stb_image vendored and compiled. From day one the
builds CROSS-COMPILE to linux-x64 and macos (x64+arm64) in CI —
catching a portability break at the phase it enters, not at GR5.
Guards: create/free churn, eviction under pressure, fallback counting
— the G1 suite's shape, for render objects.

**GR2 — the 2D layer, WITH the text pipeline.** Shape batching (rect/
circle/line/polyline/path) into vertex buffers; ONE 2D pipeline with
per-vertex color + texture; gradients. TEXT: vendor HarfBuzz
(amalgamation) + SheenBidi here; engine `text_layout` (bidi → shape →
glyph runs); glyph atlas on the GPU path, positioned <text>/<path> on
the SVG path. The SVG emitter is the sister backend of the SAME
display list — one canvas model, two renderers. GUARD CORPUS, named
now: Latin, Arabic (joining + lam-alef ligature witness — assert the
GLYPH IDS differ from the isolated forms, the mechanism not the
pixels), mixed-direction lines (UAX#9 witnesses from BidiTest-derived
cases), and the committed subset-font fixture. KILL CRITERIA: if
harfbuzz.cc does not compile under zig c++ within a session's effort,
STOP and re-evaluate (the ggml precedent says it will); if the
pure-Zig rasterizer costs more than ~2 focused weeks to fill+stroke+
clip parity on the guard corpus, vendor PlutoVG (the runner-up exists
for this exact line).

**GR3 — the 3D layer.** f32 math module; mesh (positions/normals/uv,
OBJ loader; glTF via the vendored-JSON path later); camera; depth
target; ONE forward-lit pipeline (directional + ambient) with WGSL
materials; instancing (the batched-pass machinery applied to draws).
Scope honesty: NO shadows, NO PBR, NO skeletal animation in this
phase — each is a later, workload-justified increment (G6's lesson).

**GR4 — the declarative faces.** stzCanvas / stzScene / stzMesh /
stzMaterialMaker in base/graphics/, on the conventions ledger (Q
convention, maker pattern, Show/Content, W-string → WGSL fragment via
the EXISTING transpiler, extended with fragment-stage builtins). The
narrated suites run for real; parity between ToSVG and ToPNG on the
guard corpus within a measured band (positions exact, antialiasing
banded).

**GR5 — presentation, all OSs.** GLFW vendored (per-platform source
lists — the libuv pattern in build.zig, already executed); window +
wgpu surface from the native handle; render loop + input events on
Windows/Linux/macOS as peers, with the per-OS wgpu prebuilts pinned
into vendor/wgpu under the same VERSION/checksum discipline.

> **AMENDED 2026-08-09, before any GR5 code was written — a measured
> correction to this plan's own claim.** The plan has said since GR1
> that cross-compilation from this machine verifies the all-OS
> contract. Measured, that is TRUE for the engine and FALSE for
> windowing:
>
> | target | windowing headers | cross-compiles from here? |
> |---|---|---|
> | Windows | Win32, bundled with Zig | **yes** |
> | Linux | `X11/Xlib.h` — NOT FOUND | **no** |
> | macOS | `Cocoa/Cocoa.h` — NOT FOUND | **no** |
>
> Zig bundles libc, not platform GUI SDKs; Apple's frameworks are not
> redistributable at all. This is why every prior module cross-compiled
> cleanly — they need only libc — and why windowing cannot.
>
> **The architectural consequence, and it is the important part: the
> window tier must NOT live in `stz_gpu.dll`.** Putting GLFW there
> would make the whole GPU plane un-cross-compilable and destroy a
> property we already have and guard. GR5 therefore ships a SEPARATE
> `stz_window.dll` (its own domain, `needs_glfw`), loaded the way
> wgpu_native already is — dynamically, at use time, with a counted
> refusal when absent. The engine stays portable; only the window is
> per-OS.
>
> **Honest verification status GR5 will claim:** Windows —
> runtime-verified. Linux/macOS — the source is vendored and the build
> rules are written, buildable ON those platforms with their usual dev
> packages (libx11-dev / wayland, Xcode CLT), and NOT verified from
> here. That is what GLFW's own CI does, and stating it is better than
> a cross-compile that would prove nothing about a window anyway. Runtime
verification runs on the hardware that exists (Windows today) and the
plan SAYS which OSs are cross-compile-verified vs runtime-verified —
never implying tested-everywhere. The BROWSER target through the
delivery plane (scene serialized + same WGSL, canvas presentation —
the G5 edge machinery pointed at pixels) remains the fourth tier and
is OS-independent by nature. Deployment gate: gpu-required/optional
already exists and applies unchanged.

**GR6 — the convergence dividend.** The three islands join the plane:
plots gain :SVG and :PNG backends beside the terminal canvas (same
plot model, new renderers — the "finished picture" doctrine kept);
the diagram family gains PNG output; dataviz charts ride stzCanvas.
Compute↔render composition demo: a simulation stepped by stz_gpu
compute passes rendered by the same device without readback — the
capability no vendored engine could have given.

---

## 3b. Foresight: a game / gamification plane is coming (2026-08-08)

The author has flagged a FUTURE task — a game engine, for videogame
development and for business gamification — and asked whether it should
inform these choices. It does, in a disciplined way, and the discipline
is the point: **take the cheap doors, refuse the expensive speculation.**
G6's law applies to our own future too — building for a workload that
does not exist yet is premature by definition. But a door left shut here
becomes a rewrite there, and THAT is a real cost, not a speculative one.

**What it VALIDATES (no change, now with a second reason):**
- wgpu and GLFW are game-grade choices already — GLFW exists to serve
  exactly this, and wgpu is a modern game-class GPU API. Nothing in the
  vendor table would be picked differently.
- The compute↔render zero-copy composition, named as this plane's
  differentiator, is what GPU particles, culling and physics-on-compute
  need. A game engine makes it MORE valuable, not less.
- The tier ladder holds and splits cleanly: gamification lives on tiers
  1–2 (SVG dashboards, PNG reports, progress visuals riding dataviz);
  videogames live on tiers 3–4 (window, browser).
- Much of a game engine is ASSEMBLY of planes that exist — the reactive
  layer + event bus (base/reactive/), stzStateMachine (game/UI states),
  the distribution plane (multiplayer), the multicore tier and SIMD
  loops (physics/collision), stzKnowledgeGraph + rules (gamification's
  actual substance: points, badges, challenges, progression). Graphics
  turned out to be assembly; games look the same.

**THE CHEAP DOORS — decided now because retrofitting them is expensive:**
1. **The atlas is a TEXTURE atlas, not a font atlas** (GR2). Glyphs are
   its first tenant; sprites and tilesets are the same shape. Naming it
   for fonts would guarantee a rewrite.
2. **Display lists and scenes hold RETAINED, reusable GPU buffers**
   (GR2/GR3/GR4). A still is drawn once; a frame loop redraws 60×/s and
   must not re-upload static geometry each time. The G-plane's residency
   discipline already says this — the canvas API must not quietly
   violate it by rebuilding per call.
3. **The mesh vertex format is EXTENSIBLE** (GR3) — extra attributes
   (skin weights, instance data) must be addable without breaking the
   pipeline contract. Skeletal animation stays OUT; its door stays open.
4. **Transform state is separate from render state** (GR3), so a physics
   step (or any simulation) can write transforms without touching
   material/mesh data.
5. **Presentation is a LOOP WITH INPUT from the start** (GR5), with
   delta time and vsync control — not "render once and show a window."
   This is the one that would hurt most as a retrofit: a frame loop
   bolted onto a render-once API is a rewrite, not an addition.

**WHAT IS REFUSED as speculation** (until the game plane is actually
specified and planned like this one): an ECS or entity model, vendored
physics (Box2D/Jolt class), skeletal animation, sprite-specific APIs,
and AUDIO — which is not a graphics concern at all and would be its own
sibling plane with its own vendor question (miniaudio is the obvious
first candidate; noted, not chosen). None of these are designed for
here; they are simply not designed AGAINST.

## 4. Risks, named now

- **Scope gravity.** Graphics engines die of feature accretion. The
  defense is the phase gates: shadows/PBR/animation/shaping are OUT
  until a workload asks, in writing.
- **The CPU rasterizer** is the one genuinely new engine component;
  its kill-to-PlutoVG line is written into GR2.
- **Windowing on non-Windows** is deferred (Windows-first, like the
  reactor's curl story); the SVG/PNG/browser tiers are cross-platform
  from day one.
- **Text is a bottomless field** — which is exactly why its hard parts
  are VENDORED (HarfBuzz, SheenBidi), not reinvented. The scope line
  moves from "which scripts work" (HarfBuzz makes that general) to
  "which scripts are GUARDED": Arabic + Latin + mixed-bidi initially,
  the corpus growing by demand. Vertical CJK layout, justification
  (kashida), and font FALLBACK CHAINS (one font rarely covers all
  scripts) are named as later increments — fallback chains being the
  one most likely to be asked for next.
- **HarfBuzz is the largest C++ vendored after ggml** — the same
  compile-under-zig road, and the same ctor-caution: the neural
  tier's static-initializer lessons (NOTICE'd patches) are the
  checklist to walk harfbuzz.cc through BEFORE trusting it in a DLL.
- **Cross-platform claims decay silently** — hence cross-compilation
  in CI from GR1, not a GR5 scramble; and the runtime-vs-cross-compile
  verification status stated per OS, kept current in this file.
- **dot.exe remains external** for graph layout; named, scoped,
  revisit trigger recorded.
- **CI has no GPU**: every guard passes through the SVG tier and the
  counted-refusal paths; GPU assertions gate on availability, exactly
  as the 162-assert G-plane suite already demonstrates.

---

## GR0 RESULTS — measured 2026-08-08. VERDICT: GO, and the render surface needs no lifecycle surgery

Environment: the SAME pinned wgpu-native v29.0.1.1, Zig 0.15.2,
ReleaseSafe. Spike: `engine/tools/gr0_render_spike.zig` (build line in
its header; zlib compiled from the vendored C sources into the exe).
Both adapters on Vulkan (the G0 same-backend discipline). Machine
shared with other sessions — recorded as-is.

Methodology: G0's exactly — monotonic clock, 3 warmups + 5 timed reps
(min AND median), 3 s sustained with the first 1 s discarded, GPU ops
timed as submit+wait-idle, CPU samples inner-loop scaled to ≥1 ms.

**Correctness before speed, on BOTH adapters:** offscreen pixel checks
pass (clear color exact, shaded-triangle interpolation present,
checker cells EXACT under nearest sampling); the 10k-rect batch is
**BYTE-IDENTICAL to the naive CPU fill — 0 mismatches of 8,294,400**
(integer-aligned opaque quads, painter order; the strongest possible
seed for GR4's ToSVG/ToPNG parity claim); the PNG encoder's output is
the artifact the pixel checks read back, written and eyeballable.

### Still frame (clear + shaded triangle + textured quad), warm-min / sustained, ms

| | render | readback | PNG z1 | PNG z6 | TOTAL (z1) | TOTAL (z6) |
|---|---|---|---|---|---|---|
| 3050, 800×600 | 0.075 / 0.081 | 0.31 / 0.35 (6.3 GB/s) | 8.2 | 14.2 | **8.6** | 14.6 |
| 3050, 1920×1080 | 0.142 / 0.081 | 1.54 / 1.62 (5.4 GB/s) | 27.5 | 55.2 | **29.1** | 56.9 |
| iGPU, 800×600 | 0.31 / 0.31 | 0.65 / 0.75 | 8.3 | 14.2 | **9.3** | 15.2 |
| iGPU, 1920×1080 | 0.56 / 0.53 | 1.85 / 2.20 | 27.9 | 54.5 | **30.4** | 57.0 |

PNG sizes at 1080p: 516 KB (z1) / 327 KB (z6). Render pipeline compile
(cold): 7–13 ms per pipeline — the G1 text-keyed compile-cache is
justified for RENDER pipelines by the same measurement.

### KILL CRITERION 1 (≤ ~50 ms for a simple 1080p still): **PASSES — 29.1 ms**

The decomposition is the finding: the GPU raster part is **1.7 ms of
the 29** (render 0.14 + readback 1.54); **95% of the cost is CPU zlib
deflate**, resolution-bound and scene-independent. zlib level 6 would
total 56.9 ms — over the line — so the level is a decided knob: **GR1
defaults PNG encode to level 1** (z6 stays an opt-in archival knob).
Demoting the GPU tier would not have moved this number — SVG+CPU 2D
pays the identical encode price for raster output; the criterion's
target (the GPU raster tier) costs 3% of the budget. Named GR1
headroom, not assumed: PNG filter heuristics (Sub/Up) recover most of
the z6 ratio at z1-class speed. And the window tier (GR5) pays no
encode at all — 0.08–0.6 ms/frame leaves hundreds of fps of headroom.

### 10k-primitive 2D batch vs naive CPU fill (1920×1080), ms

| | build verts | upload 1.44 MB | draw (warm/sus) | readback | CPU fill (warm-min/med) |
|---|---|---|---|---|---|
| 3050 | 0.073 | 0.31 | 1.24 / 0.62 | 1.37 | 2.90 / 3.90 |
| iGPU | 0.074 | 0.53 | 6.44 / 1.47 | 0.99 | 2.96 / 3.90 |

Read honestly: the 3050 wins draw-only 2.3x warm (4.6x sustained), but
END-TO-END to a PNG the readback eats the win — 1.0x at 10k rects.
The iGPU warm-min draw LOSES (0.5x) — the G0 clock inversion again
(sustained 1.47 ms says the silicon is fine; a sporadic call pays the
idle-clock price). Consequences, recorded as decisions: (a) the 2D
PNG tier at THIS primitive count is not a GPU story — it becomes one
at higher counts (CPU fill scales linearly with covered pixels; the
draw is far from saturated) and in the window tier where readback
vanishes; (b) GR2's CPU rasterizer is not a fallback afterthought —
at 10k-primitive stills it is co-equal; (c) calibration stores
warm-min, exactly as the G-plane law says.

### KILL CRITERION 2 (render must not demand lifecycle surgery): **PASSES, witnessed**

- Vertex/index/staging buffers are the SAME `wgpuDeviceCreateBuffer`
  the gen-keyed table already wraps — new usage flags, same slots.
  Textures/views/samplers/render pipelines are new SLOT KINDS in the
  same table shape (id = (gen<<32)|slot, VRAM accounting w·h·4), not
  a new model.
- Bind groups reuse the same @group/@binding structure; texture and
  sampler entries are additional FIELDS on the same WGPUBindGroupEntry
  the layer already builds. The compute-side tile@0/params@1 contract
  simply does not govern render pipelines (render passes are not
  TDR-tiled dispatches) — no collision, no surgery.
- **The composition witness ran**: a compute pass wrote the vertex
  buffer (Storage|Vertex usage) a render pass consumed, same encoder,
  **ONE submit**, pixel-verified at two uniform values. The plan's
  differentiator — simulate on compute, draw on render, zero copies —
  is a demonstrated fact, and it is exactly the batched-pass shape G1
  already ships (a render pass is a sibling of a compute pass on the
  same encoder; the uniform-slot-pool lesson carries).
- Honestly named additions (additions, not re-plans): pass-level verbs
  the compute path never needed (SetVertexBuffer/SetPipeline/Draw
  inside a render pass), texture readback's 256-byte row alignment
  (handled + de-padded in the spike), and RenderPassDescriptor
  sentinels (depthSlice, multisample.count/mask, maxAnisotropy) that
  zeroed structs get WRONG — recorded so GR1 doesn't rediscover them.

### Front-loaded risk (a): harfbuzz.cc under zig c++ — **CONFIRMED, stronger than asked**

HarfBuzz 14.3.0 (official release tarball, SHA-256
`16070d77cfc4ba1f1e7327e83bf9b3f55898081cabdb94e56a33e04fc8874eae`):
`zig c++ -c src/harfbuzz.cc -O2 -fno-exceptions -fno-rtti` compiles
with **zero errors** (9 benign warnings), no cmake, no SDK, no config
step: 38.9 s native Windows (13.9 MB .o), and CROSS-COMPILES from this
one machine to linux-x86_64 (31.0 s) and macos-aarch64 (32.5 s) — the
all-OS contract grounded, not assumed. Then the real proof: a C
program linked against the object **shaped real Arabic through the C
ABI** — an 8-codepoint word into 8 positioned glyphs, and the
lam-alef pair (U+0644 U+0627) into **ONE ligature glyph** — GR2's
kill criterion pre-passed with its own witness mechanism (2 cp → 1
glyph id is the GSUB assertion the guard corpus names). Still owed to
GR2: the static-initializer walk (the ggml ctor checklist) before
harfbuzz.cc lives inside a DLL, and the committed OFL subset-font
fixture so CI never touches a system font.

### Front-loaded risk (b): per-OS wgpu-native prebuilts — **CONFIRMED at the pinned tag**

The v29.0.1.1 release (the exact tag in vendor/wgpu/VERSION) ships
official release zips for every target the plan names: linux-x86_64
(16.0 MB), linux-aarch64 (15.8 MB), macos-x86_64 (13.6 MB),
macos-aarch64 (13.7 MB) — plus windows aarch64/i686/gnu variants and
android/ios beyond the contract. No official checksums asset exists
(only a commit-sha file), so pinning = the discipline already in
vendor/wgpu/VERSION: record asset name + SHA-256 computed at
vendoring time, per OS, same file. GR5 extends the VERSION file; no
new mechanism.

### What GR1 inherits (calibrated numbers)

1. Offscreen render at still-frame scale is ~0.1–0.6 ms — negligible;
   **readback (1.5–2.2 ms at 1080p, 4.5–6.3 GB/s) and PNG encode
   (27–55 ms) are the budget**. Optimize the encoder, not the pass.
2. PNG defaults: zlib level 1; z6 = opt-in archival; filter
   heuristics = named headroom.
3. Render-pipeline compile 7–13 ms cold → same compile-cache, keyed
   the same way.
4. Texture readback rows align to 256 bytes (800×600 pads 3200→3328;
   1080p is naturally aligned) — the de-pad belongs engine-side.
5. Retained-buffer discipline held even in the spike (static scene
   geometry uploaded once; the frame loop re-encodes only) — the §3b
   door stays open by construction.
6. iGPU warm-min draw pays the clock inversion (6.4 ms warm vs 1.5
   sustained) — calibration stores warm-min, and sporadic one-shot 2D
   GPU calls on iGPU-class machines are exactly where the CPU
   rasterizer keeps the work.

---

## GR1 STATUS — shipped 2026-08-08: the render lifecycle in stz_gpu.dll

Delivered (guard: `base/test/gpu/gpu_render_lifecycle_narrated.ring`,
**74 asserts green** on this machine, fallback + codec scenes pass with
no device = the CI coverage; the six pre-existing GPU guards and the
neural backbone guard stay green — 175 asserts swept, all suites the
changed files can reach):

- **Textures and offscreen targets join the G1 discipline** — their own
  gen-keyed table (`stz_gpu_texture_*`; a texture id and a buffer id
  are separate namespaces, like kernels), the SAME VRAM budget, and
  FIFO eviction ACROSS kinds: the guard witnesses a texture creation
  evicting the OLDEST resident *buffer*, counted, with its negative
  sibling. Three kinds: render target / sampled-nearest / sampled-
  linear, RGBA8 only (the GR0 contract). Churn returns live-count and
  byte accounting exactly to baseline; stale ids answer by name.
- **Every lifecycle buffer now carries Vertex|Index usage** — any
  buffer can feed a draw, and a compute kernel can write vertices a
  render pass consumes. The GR0 composition witness is now guarded
  THROUGH the product layer (dispatch → draw → exact pixels), not just
  in the spike. (And the layout-auto trap resurfaced on cue: a kernel
  must READ the tile uniform, not merely declare it — the guard's
  generator kernel carries the rule as a comment.)
- **Render-pipeline cache** keyed by (WGSL text, vertex format, blend):
  1 compile + N hits, counted separately (counters 10/11); malformed
  WGSL refuses AND counts a device error (the kernel-compile lesson
  applied to render). Vertex format is declarative text ("2,4" = vec2
  pos + vec4 color); blend 0 = opaque, 1 = standard alpha.
- **The pass machine mirrors the batch machinery**: Begin(target,
  clear) opens ONE encoder, draws (plain + indexed, textured + not)
  encode into it, End() submits ONCE — asserted by the submit counter.
  Asynchronous like Dispatch; readback or Sync completes. Mid-pass
  shutdown aborts cleanly (nothing submitted, nothing owed) via the
  close-device callback; re-Init restores service.
- **Readback de-pads the 256-byte row alignment engine-side** — guarded
  at width 63 (row 252 ≠ 256), where a de-pad bug shears every row
  after the first.
- **The PNG encoder is engine substance** (pure Zig over the vendored
  zlib, z1 the measured default) and **stb_image decode** joins it
  (memory-only, RGBA8 out). The guard round-trips REAL rendered pixels
  through encode→decode byte-identically — two independent codec
  implementations cross-checking each other, working with NO device.
- **The 15-rect batch parity scene** reproduces GR0's byte-identical
  claim through the product layer: 0 mismatching pixels against a
  Ring-computed painter-order reference.
- **stb vendored and pinned** (`vendor/stb/VERSION`: commit 2c980bb,
  SHA-256 per file; stz_stb_impl.c is the one implementation TU;
  STBI_NO_STDIO — decode is from memory only). stb_truetype compiles
  in, unexercised until GR2's text pipeline.
- **Cross-compile verified from this machine**: the render module
  (gpu.zig + gpu_render.zig + wgpu/zlib/stb headers) build-objs clean
  for x86_64-linux-gnu and aarch64-macos. Honest scope: full-DLL
  cross-compilation waits on per-OS Ring libraries (pre-existing
  repo-wide constraint, not a render one), and this repo has no CI
  runner yet — the check is a documented command, not a pipeline:
  `zig build-obj src/gpu_render.zig -OReleaseSafe -I vendor/wgpu/include
  -I vendor/zlib -I vendor/stb -lc -target <triple>`.

Surface documented in `engine/stz_gpu.ring` (counters 10–13, texture
kinds, the vmain/fmain + format contract, u32 index upload, codecs).

Next: **GR2** — the 2D layer WITH the text pipeline (display list →
GPU batch AND SVG emitter; HarfBuzz + SheenBidi vendored — harfbuzz.cc
already compile-proven and shaping in GR0; the lam-alef glyph-id
witness becomes the guard corpus).

---

## GR2a STATUS — shipped 2026-08-09: the text pipeline (bidi → shape → raster)

GR2 split at its natural seam: the TEXT PIPELINE first (the phase's
named acceptance test, its vendors pre-proven in GR0), the display
list + SVG/GPU twin renderers next. Guard:
`base/test/gpu/gpu_text_narrated.ring` — **41 asserts green**, and the
whole suite runs with NO device, no download, no system font: this
suite IS its own CI coverage. DLL-load-sensitive guards re-swept green
(render lifecycle 74, lifecycle 62, ops 37) — the harfbuzz
static-initializer caution produced no load-time incident.

**Vendored, pinned, compiled into stz_gpu.dll:**
- **HarfBuzz 14.3.0** (`vendor/harfbuzz/VERSION.txt`): the SHAPER
  closure only — harfbuzz.cc + its include tree (+ the hb-subset
  HEADERS that hb-open-type.hh demands), NOT the subset .cc machinery,
  repacker, or tools. One C++ TU, `zig c++ -fno-exceptions -fno-rtti`,
  no cmake/SDK/config — the largest C++ vendor in the house, accepted
  in writing by the plan of record. Two Windows lessons collected:
  a vendor-root `VERSION` file on a C include path COLLIDES with C++'s
  `<version>` header on case-insensitive filesystems (renamed
  VERSION.txt for stb + harfbuzz); a bare `text` import shadowed
  bridge locals.
- **SheenBidi 3.0.0** (`vendor/sheenbidi/VERSION`): UAX#9, pure C
  unity build, zero deps.
- stb_truetype (GR1's vendor) now EXERCISED as the raster stage.

**The engine entry** (`src/gpu_text.zig`, CPU-side, device-free):
`textLayout(font, utf8, size_px)` = SheenBidi visual-order runs →
HarfBuzz shaping per run WITH full-paragraph context (item window, so
joining sees across run edges) → positioned GLYPH IDS with byte
clusters; `glyphBitmap(font, gid, size)` rasters BY GLYPH ID (em-mapped
scale shared with layout: hb scale px·64 / stbtt
ScaleForMappingEmToPixels — metrics and bitmaps agree by construction).
Fonts are gen-keyed handles from memory blobs, validated by BOTH
consumers (hb face glyph count AND stbtt init). Single-line contract
(first paragraph) documented; line breaking is a later increment.

**The committed fixture** (`base/test/gpu/fixtures/`): Amiri Regular
1.003 subset (OFL, license committed beside it) — Basic Latin + Arabic
U+060C..066F + bidi controls, GSUB/GPOS retained: 131,820 bytes, 1,449
glyphs, SHA-256 in fixtures/README.md. Generated deterministically by
`engine/tools/font_subset_gen.c` (hb-subset compiled from the SAME
pinned tarball; all inputs SHA-pinned in the tool header). CI never
regenerates.

**The guard corpus, asserted by MECHANISM** (glyph ids and run
structure, never pixels):
- Latin: 8 chars → 8 real glyph ids, x strictly advancing, clusters
  ascending.
- Arabic joining: beh's MEDIAL form id ≠ its isolated form id; the
  joined word is measurably narrower than its letters apart;
  word-initial seen ≠ isolated seen.
- **lam-alef, the finding worth recording**: Tahoma fuses the pair
  into ONE glyph (GR0's smoke); **Amiri substitutes TWO dedicated
  lam-alef pieces** — both are the mandatory ligature working. The
  witness that holds across correct fonts (probed against generic
  contexts before asserting): every output glyph differs from the
  isolated forms AND from the generic joined forms (lam-initial from
  lam+beh, alef-final from beh+alef). A fusion-count assertion would
  have been font-lore, not mechanism.
- Mixed direction "abc سوفتانزا xyz": 3 visual runs; Latin clusters
  ascend, the Arabic segment's clusters DESCEND as x advances (RTL
  made visual, inside LTR). Clusters are BYTE indices — 'z' at 23.
- Raster: the ligature piece inks (coverage above half-ink asserted);
  whitespace answers [0×0] ink-free — a valid answer, not an error.
- Refusals by name (stale font, double free, zero size, empty text,
  garbage font bytes); layout is deterministic (ids AND positions).

Cross-compile: gpu_text.zig build-objs clean for x86_64-linux-gnu and
aarch64-macos.

Remaining in GR2 — **GR2b**: the display list (rect/circle/line/
polyline/path) with its TWO renderers (GPU batch through the GR1
surface, SVG emitter as the sister backend), gradients, the TEXTURE
atlas (glyphs its first tenant — the §3b door), text drawn onto both
backends through THIS pipeline, and the PlutoVG kill line for the CPU
rasterizer.

---

## GR2b STATUS — shipped 2026-08-09: one display list, two renderers

GR2 is complete. Guard: `base/test/gpu/gpu_scene_narrated.ring` —
**69 asserts green**, of which everything up to the GPU scene runs with
NO device (the SVG tier IS the CI coverage, as the plan promised).
Reachable suites re-swept: text 41, render lifecycle 74, lifecycle 62,
ops 37, seams 17, neural backbone 14 — **314 assertions green**.

**The model owns the geometry; the backends only draw it.** A scene
(`engine/src/gpu_scene.zig`) is a painter-ordered list of commands in
PIXEL space (y down). `ToSvg` emits vector text with no device;
`ToPng`/`ToPixels` tessellate and draw through the GR1 surface. Neither
backend computes positions of its own, so they cannot drift apart — and
text goes through the GR2a pipeline on BOTH sides, so Arabic is correct
on both or broken on both. Shapes: rect, rect-gradient, circle, line,
polyline, polygon, text.

**Decisions worth their reasons:**
- **The curve parity band is COMPUTED, not hoped for.** Circle segment
  count = ceil(π / acos(1 − 0.15/r)), so the chord sagitta never
  exceeds 0.15 px at any radius. SVG emits a true `<circle>`, so that
  bound IS the honest geometric difference between the tiers — a
  number, not an adjective. Unit test asserts it across r = 1…2000;
  the guard checks the rendered pixels honour it (filled inside the
  rim, background outside).
- **Polygon fill is ear clipping** (n−2 triangles, verified on a
  concave L), not a triangle fan that would spill outside any reflex
  corner. A self-intersecting outline runs out of ears and stops —
  an honest partial fill rather than garbage, and that case is exactly
  the PlutoVG line, still standing unspent.
- **Alpha arrived without costing exactness.** Both pipelines blend
  src-over, which at a=1 reduces to plain overwrite — so opaque rects
  are still BYTE-IDENTICAL to a Ring-computed painter-order reference
  (0 of 2400 pixels wrong), while a 50 % white over black lands at 128
  as its negative sibling.
- **Strokes agree on cap semantics**: a disc at every vertex on the GPU
  side, `stroke-linejoin/linecap="round"` on the SVG side. Matching
  caps is what keeps the two silhouettes the same shape.
- **SVG text is glyph OUTLINES**, not `<text>` — the SVG carries the
  exact positions this pipeline computed and needs no font installed on
  the viewer's machine. Handing shaping back to the consumer is the one
  thing the text pipeline exists to prevent. (A selectable-`<text>`
  emitter is a later knob.)
- **The atlas is a TEXTURE atlas** (`engine/src/gpu_atlas.zig`), the
  §3b door taken: shelf packing, 1 px padding so linear filtering
  cannot bleed, entries keyed (font, glyph, quantized size). Glyphs are
  its first tenant; sprites are the same shape. The guard proves the
  cache by counting — a repeated word adds zero entries, a new size
  adds some — and proves the upload is not repeated when nothing
  changed.
- **Retained buffers, witnessed not asserted**: `builds` in SceneStats
  increments only when the display list actually changed. Reading an
  unchanged scene twice does not re-tessellate. That is the §3b frame-
  loop door, and the counter is why it will stay open.
- **Painter order survives crossing kinds**: shapes and text live in
  separate vertex buffers (different formats), but an ordered draw-
  segment list interleaves them inside the ONE pass, so text is not
  silently forced above shapes.

**Two things the guard's own asserts caught**, recorded because both
were fixed in the implementation rather than in the assertion:
`sceneToPixels` was encoding a PNG and discarding it, then reading the
target a second time — the submit-count assert (one pass + one
readback) exposed the double work, and the tiers were refactored to
share one render path. And the device-close hook in `gpu.zig` was a
SINGLE slot: the scene layer registering would have silently overwritten
the render layer's, leaking exactly the objects the hook exists to
release. It is a registry now.

Cross-compile: gpu_scene.zig and gpu_atlas.zig build-obj clean for
x86_64-linux-gnu and aarch64-macos.

Visual proof rendered from one scene through both tiers (gradient,
alpha-blended circles, concave arch, round-joined polyline, Latin and
Arabic): 9 commands → 591 shape vertices + 258 text vertices → 2 draw
segments → one pass.

Next: **GR3** — the 3D layer (f32 math module, mesh + OBJ, camera, depth
target, one forward-lit pipeline, instancing), with shadows/PBR/skeletal
animation explicitly OUT until a workload asks. The §3b doors GR3 must
keep open: an EXTENSIBLE vertex format and transform state SEPARATE from
render state.

---

## GR3 STATUS — shipped 2026-08-09: the 3D layer

Guard: `base/test/gpu/gpu_scene3d_narrated.ring` — **46 asserts green**
(mesh building, OBJ parsing and every refusal run with NO device; only
the rendering scenes gate on a GPU). Plus **16 Zig unit tests** where
exactness is available: `gpu_math.zig` (9) and `gpu_mesh.zig` (7). Every
reachable suite re-swept: scene 69, render lifecycle 74, text 41,
lifecycle 62, ops 37, seams 17, neural backbone 14 — **360 assertions
green**.

**The math is asserted analytically, not by eye** (`src/gpu_math.zig`).
f32 vec/mat4/quaternion/transform/camera, column-major to match WGSL so
a matrix is memcpy'd into a buffer and used as-is — and DELIBERATELY
apart from the f64 solver tier, whose bit-stability is contractual. The
identities the tests pin: lookAt sends the eye to the origin and
preserves the eye→target distance; perspective maps −near to 0 and −far
to 1 (WebGPU's depth range, not OpenGL's); quaternion composition equals
matrix composition; a rotation preserves length and orthogonality; a
direction transform ignores translation where a point transform does
not; and **the normal matrix keeps normals perpendicular under
non-uniform scale — with the naive "just use the model matrix" choice
asserted to FAIL as its negative sibling**. A picture can look plausible
with a subtly wrong matrix; these cannot.

**Meshes describe themselves, and the vertex format is DERIVED**
(`src/gpu_mesh.zig`). A mesh carries an attribute descriptor; the
pipeline's format string ("3,3,2") comes FROM it. That is §3b door 3
taken concretely rather than promised: the guard builds a 4-attribute
mesh (position/normal/uv/colour) today, it gets its own pipeline
variant, and **not one line of the render layer knows what the new
attribute means**. Cube (24 vertices, not 8 — a shared corner cannot
carry three normals), UV sphere, plane, and an OBJ loader that dedupes
by the (v, vt, vn) TRIPLE, fans polygon faces, resolves NEGATIVE
indices, and generates normals when a file has none rather than
shipping black geometry. An out-of-range index is a refusal, not a
crash later.

**Depth, instancing, and the transform door** (`src/gpu_scene3d.zig`):
- **Depth decides, not painter order** — the guard renders a near cube
  and a far one, submits the FAR one last, and the near one still owns
  the centre pixel; then reverses the submission order and asserts the
  image is byte-identical. If both orders give the same picture,
  ordering is provably not what decided it.
- **One draw call per MESH, not per object**: 5 instances of a cube =
  1 draw; adding 2 spheres = 2 draws for 7 objects. Instances of a mesh
  are contiguous in the shared buffer and `firstInstance` shifts
  `@builtin(instance_index)` onto each group's slice — without which
  every group after the first would redraw the earlier instances with
  the wrong geometry (found and fixed while writing it, not after).
- **§3b door 4, witnessed by counters**: moving an instance re-uploads
  transforms (`transform_uploads` +1) and does NOT re-upload geometry
  (`geometry_uploads` unchanged), while the picture demonstrably
  changes. A simulation can drive the scene without knowing rendering
  exists.
- **Lighting is shading, and the black light proves it**: with a white
  directional light the cube's faces span 40..255; with the light set to
  BLACK every visible face collapses to exactly the ambient value
  (40..40). Had the faces still differed, the "shading" would have been
  coming from somewhere else.

**Lifecycle additions were strictly ADDITIVE** — the 2D surface that
shipped keeps its exact signatures and all its guards pass unchanged.
New: `TEX_DEPTH` (Depth32Float) as a fourth texture kind in the same
gen-keyed table and VRAM budget; `render_pipeline3d` (depth test + back-
face culling) as a SEPARATE entry point rather than a widened one;
`render_begin3d` attaching a depth buffer that must match the target's
size; and `render_draw_bound`, an instanced indexed draw whose group(0)
bindings are ordinary lifecycle buffers — storage rather than uniform,
so the buffer usage that shipped in G1 already covers them. The sentinel
trap this phase contributed to the ledger: **`WGPUOptionalBool_False ==
0`, so a zeroed depth-stencil state silently disables depth writes** —
the buffer would exist, be cleared, and never be written.
`depthWriteEnabled` is set explicitly for exactly that reason.

Scope kept, per the plan: **NO shadows, NO PBR, NO skeletal animation.**
Each is a later, workload-justified increment — G6's law applied to our
own roadmap. Skeletal animation's door is the extensible vertex format,
and it is open and load-tested.

Cross-compile: gpu_math.zig, gpu_mesh.zig and gpu_scene3d.zig build-obj
clean for x86_64-linux-gnu and aarch64-macos.

Visual proof: 29 instances across 3 meshes (a ground plane, a 5×5 field
of cubes, three spheres) → **3 draw calls, 3 geometry uploads, one
depth-tested pass**.

Next: **GR4** — the declarative faces (stzCanvas / stzScene / stzMesh /
stzMaterialMaker in base/graphics/) on the house conventions: the Q
convention, the maker pattern, Show/Content, and W-string → WGSL
fragments through the EXISTING transpiler, with narrated suites that run
for real and a measured ToSVG/ToPNG parity band.

---

## CHALLENGE PASS — 2026-08-09, before GR4: does the design hold outside its own guards?

Three real graphics were written against the shipped surface, chosen to
attack the three claims that actually distinguish this plane from the
engines the vendor table killed. Guards prove a thing works; these asked
whether the thing is *usable* and whether the differentiators are real.

### 1. Compute → render, zero copies — **the differentiator is real, and large**

A 12,000-particle curl-flow field: a compute kernel steps the simulation
AND writes the vertex buffer the render pass draws. 90 frames, no
readback (a window loop's shape).

| | measured |
|---|---|
| bytes across the bus, per frame | **16** (the params blob) |
| particle state resident in VRAM | 192,000 B |
| vertex data resident in VRAM | 1,728,000 B |
| a CPU-side engine's per-frame vertex upload | 1,728,000 B |

**Five orders of magnitude** less bus traffic than rebuilding vertices
CPU-side, which is what a NanoVG/raylib-class immediate API forces. One
buffer legitimately served as compute STORAGE and render VERTEX in the
same frame — the usage flags GR1 gave every buffer paid off exactly as
intended. This is the capability the plan said no vendored engine would
give, and it is now demonstrated on a real workload rather than a spike.

### 2. A real chart, two tiers — **the SVG twin survives an independent rasterizer**

A 720×420 bar chart: gridlines, gradient bars, a highlighted peak, value
labels centred by MEASURED width, and mixed Latin/Arabic categories —
34 commands, 78 shape vertices, 450 text vertices, 26 draw segments.
Emitted to PNG (our rasterizer) and SVG, then the SVG was rendered by
**Chrome** and compared: same layout, same positions, same picture.

And the sharpest check available, because it uses a genuinely
independent implementation: Chrome's own text stack was asked to shape
and measure the same Arabic string in the same font at the same size.

| | advance width, الإنتاج الشهري @20px |
|---|---|
| Chrome (its HarfBuzz + font stack) | 96.44 px |
| this engine (SheenBidi → HarfBuzz → stb) | 96.45 px |
| **delta** | **0.010 px** |

A hundredth of a pixel against an industrial reference. The text
pipeline is not merely self-consistent; it agrees with the browser.

### 3. Animation through the shipped 3D face — **the §3b transform door holds at scale**

400 cubes in a wave field, every transform rewritten every frame for 60
frames:

| | measured |
|---|---|
| draw calls per frame | **1** (400 instances) |
| geometry uploads across 60 animated frames | **1** |
| transform uploads | 60 |
| wall time | 1.67 ms/frame *including a full 720×405 readback every frame* |

Moving 400 objects 60 times never re-uploaded geometry once. The door
§3b left open for a physics step is load-bearing and it holds.

### FOUR GAPS FOUND — verified by inspection, and GR4/GR5 should close them

These are not bugs; they are places the surface stops short of what the
layers underneath can already do. Recorded now so the faces are designed
around them rather than over them.

1. **Compute cannot drive the 3D scene.** `gpu_scene3d`'s instance
   buffer is internal (zero references from the bridge), so the
   zero-copy trick that worked beautifully in challenge 1 is
   unreachable for 3D instances — GPU physics can move particles but
   not meshes. §3b door 4 is open at the CPU level and **shut at the
   GPU level**. Fix: expose the instance buffer's handle (or accept a
   caller-owned one), which costs one accessor.
2. **A render target cannot be sampled.** `TEX_TARGET` carries
   `RenderAttachment|CopySrc` and not `TextureBinding`, so a 3D render
   cannot be used as a texture by the 2D layer — a HUD over a 3D scene,
   or any post-process, has to round-trip through the CPU today. Fix:
   add a sampled-target kind, or add the usage bit.
3. **Compute and render cannot share a submit through the API.**
   `stz_gpu_dispatch` submits per call, so challenge 1 paid 2 submits
   per frame (180 for 90 frames). GR0's spike proved compute→render in
   ONE submit is possible; the product API cannot express it. At GR0's
   measured ~60 µs submit floor that is ~60 µs/frame of avoidable
   overhead — small now, compounding for a frame loop with many passes.
   Fix: let the batch machinery span a render pass, as GR0 did.
4. **The f32 math is not reachable from Ring.** `gpu_math.zig` is
   engine-internal; a challenge script that wanted its own camera had to
   re-derive lookAt/perspective by hand. GR4's `stzScene` needs it
   anyway — expose vec/mat4/quat/camera as part of the declarative face.

None of these invalidate a shipped phase, and none were visible from
inside the guards — which is the argument for doing a pass like this
before every face-building phase, not only before this one.

---

## GR4a STATUS — shipped 2026-08-09: the declarative faces

`base/graphics/`: **stzColor, stzFont, stzMesh, stzCanvas, stzScene**,
loaded by stzBase. Guard: `base/test/graphics/graphics_faces_narrated.ring`
— **58 asserts green**, everything but the pixel scenes running with no
GPU. Regression sweep: the eight GPU suites and the neural backbone all
green — **438 assertions**.

**The naming law is now GUARDED, not merely documented.** A convention
that lives only in prose drifts, so the guard asserts it by mechanism:
- the plain form is asserted NOT to return an object (`isObject(
  oC.AddCircle(...)) = FALSE`), so a chain cannot accidentally work off
  a form that was never meant to chain;
- the Q twin is asserted to return **the main object by IDENTITY** —
  `oC.AddCircleQ(...).Id_() = oC.Id_()` — which is the real claim: the
  chain never leaves the canvas for a shape object to hold or lose;
- `To...()` names return data.

**Fill colours the last shape added** — and that is asserted with
pixels, both directions: two circles each keep their own fill (the
second does not repaint the first), and a `Fill` issued BEFORE any shape
becomes the canvas default. It works because an `Add*` REMEMBERS the
shape instead of posting it, so `Fill`/`Stroke`/`Color`/`SetFont` can
still reach it; the shape posts when the next `Add*` arrives or when
output is asked for.

**The two gaps GR4 promised to close are closed:**
- **Gap 4 — the f32 math is reachable from Ring**:
  `Mat4LookAt / Mat4Perspective / Mat4Mul / Mat4Project`, and the face
  that needed it, `stzScene.Project(x,y,z)` → `[x, y, depth, visible]`
  in canvas pixels. Guarded: the camera's target lands within 1 px of
  the picture's centre, and a point behind the camera answers **not
  visible** rather than a NaN to trip over.
- **Gap 1 — compute can now drive the 3D scene**: `InstanceBuffer()`
  hands out the transform buffer's handle, `InstanceStride()` the
  shader's stride, and `SetGpuDriven(TRUE)` stops the face from
  overwriting what a kernel wrote. That flag is the part that matters —
  without it the accessor would be a trap, since the next frame would
  rewrite the kernel's work. Guarded both ways: CPU-driven by default,
  and once GPU-driven the transform-upload counter stops moving.

Other decisions worth recording:
- **Colour has exactly one converter** (`stzColor`), because a colour
  meaning two things on two tiers is precisely the bug the twin-renderer
  design exists to prevent. `#rgb`, `#rrggbb`, `#rrggbbaa` and a small
  named set; a malformed colour RAISES by name rather than silently
  becoming black — a wrong-coloured picture teaches nothing.
- **A font is bytes you loaded**, not a name the system might resolve
  differently tomorrow, and `WidthOf()` is a real shaped advance — which
  is what makes centring an Arabic label possible at all.
- **`CanDrawPixels()` and lazy device init**: the faces open a device the
  first time pixels are actually wanted (once per process), so callers
  never manage it, and a GPU-less machine simply keeps answering through
  SVG.
- Two Ring traps re-collected while building: a global assigned AFTER a
  `func` in a file becomes part of that function and never runs at load
  (the graphics globals live at the top of `stzColor.ring`, the
  first-loaded file); and reading `@aCam[7]` inside the list literal
  that replaces `@aCam` is an out-of-range trap — read the parts out
  first.

**Deferred to GR4b, with the reason**: `stzMaterialMaker`. The plan's
sketch (`TakesColor(:base)` … `ForEachFragment('{ … }')`) needs the
EXISTING W-string → WGSL transpiler extended with a **fragment stage**
and its builtins — that is engine substance, not a face, and it deserves
its own increment with its own refusal corpus, exactly as `gpu_wgsl.zig`
got in G4. Shipping the faces without it is honest; pretending a Ring-side
string builder is the transpiler would not be.

Next: **GR5** — presentation on all OSs (GLFW vendored, window + surface,
a loop WITH INPUT from the start per §3b door 5), where challenge gaps 2
and 3 (sampled render targets, compute+render in one submit) pay for
themselves; or **GR6** — the convergence dividend, which needs nothing
new and is where existing plots and diagrams gain real image output.

---

## GR6a STATUS — shipped 2026-08-09: plots gained pixels

The first island joins the plane. `base/graphics/stzPlotCanvas.ring`
renders a plot's model onto an stzCanvas, and the bar family gained
`ToCanvasQ()` / `ToSVG()` / `ToPNG()` — inherited by every subclass, so
`stzVBarChart`, `stzBarChart`, `stzVBarPlot` and `stzHBarPlot` all got
them from one edit. Guard:
`base/test/graphics/plot_backends_narrated.ring` — **29 asserts green,
every one of them deviceless**. The pre-existing plot suites stay green
(chart subclasses 16, engine parity 107), which is the point: a
convergence that changed the old output would be a regression, not a
dividend.

    oPlot = StzPlotQ(:VBar, [ :Jan = 34, :Feb = 58, :Mar = 47 ])
    oPlot.Show()                                   # the terminal picture, as ever
    oPlot.ToPNG("sales.png", [ :Font = oFont, :Title = "Sales" ])
    oPlot.ToSVG([ :Font = oFont ])                 # no GPU needed

**What is shared is the MODEL, not the layout** — and that distinction is
the whole design. A character grid and a pixel canvas have no common
layout to share: tick spacing in rows is not tick spacing in pixels, and
a bar three characters wide is not a bar thirty-four pixels wide. What
must never diverge is the MEANING, so the values, the labels and the
semantic flags are read from the plot object once. The guard asserts
that directly: a plot told `AddAverage()` gets an average line in its
SVG, a plot not told gets none, and an explicit option still overrides
the object — the intent travels without being restated.

`stzHBarPlot` differs from `stzVBarPlot` by **one method**, `PlotKind()`.
That is the test of whether the seam was cut in the right place.

Decisions worth recording:
- **Axis ticks are rounded to nice numbers** (1/2/2.5/5 × a power of ten):
  0/20/40/60/80/100 rather than 0/17.6/35.2/52.8. An axis a reader has to
  decode is an axis that failed. Asserted on the arithmetic, not on
  pixels, so it cannot pass by coincidence.
- **A plot without a font still draws** — bars, axes, gridlines — and
  simply carries no text. A legible chart beats a refusal, and the guard
  pins both halves.
- Two Ring structure traps collected, both of which fail SILENTLY:
  a multi-line function SIGNATURE is not parsed (it made stzBase.ring die
  at load with no message at all), and a class's attributes must ALL
  precede its first method — inserting `PlotKind()` at the top of
  stzHBarPlot turned every declaration below it into dead code, surfacing
  much later as "uninitialized @nBarHeight".

Remaining in GR6: the **diagram family** and **dataviz**. An honest note
on scope, discovered here: the diagram family reaches SVG through an
external `dot.exe`, so giving it PNG would mean RASTERIZING that SVG —
and this plane has no SVG parser. The tractable path is the one the plan
already named: compute simple non-graph layouts (an org chart's tree)
ourselves and draw them with stzCanvas, so they stop needing dot at all,
while true graph layout keeps shelling out. That is GR6b, and it is a
layout problem, not a rendering one.

---

## GR6b STATUS — shipped 2026-08-09: hierarchies lay themselves out

`base/graphics/stzTreeCanvas.ring` lays a hierarchy out and draws it, and
`stzOrgChart` gained `ToTreeNodes()` / `ToCanvasQ()` / `ToSVG()` /
`ToPNG()`. Guard: `base/test/graphics/tree_backends_narrated.ring` —
**29 asserts green, every one deviceless**. Pre-existing suites stay
green (org chart 10, diagram exporters 35, diagram styles 20).

**An org chart needs no external binary now.** `ToDot()` is untouched —
a real graph, with cycles and dotted-line reporting, still belongs to the
tool that does graph layout for a living. But a TREE does not need graph
layout, and saying so is the whole phase: laying a hierarchy out is a
page of arithmetic, and doing it here also buys the PNG tier that
rasterizing dot's SVG could never have given us.

**It is a TREE canvas, not an org-chart canvas** — org charts are its
first tenant, the way glyphs were the texture atlas's. Any parent/child
structure (a file tree, a taxonomy, a decision tree) is the same shape.

The layout is the classic tidy-tree pass — leaves take consecutive slots,
every parent centres over its children — done **iteratively on purpose**:
a recursive version would be shorter and would put a caller's own deep
hierarchy at the mercy of the interpreter's stack.

**The layout is asserted as GEOMETRY, by parsing the emitted SVG** rather
than by eye: a parent's centre equals the mean of its children's centres
(415 vs 415), siblings never overlap, depth grows downward in distinct
rows, and a four-child subtree provably pushes its sibling aside. Reading
the emitted document is the honest check — it is what a consumer sees,
not what the renderer believes it did.

Refusals and edges all answer: an empty hierarchy raises, a **cycle
raises rather than looping forever**, a forest stands side by side, a
node naming an unknown parent becomes a root (with its own child still
beneath it), and a label too long for its box is **truncated with an
ellipsis rather than spilled** — a label that silently overflows is a
chart lying about what it contains.

One guard lesson worth keeping: the background is a `<rect>` too, and
counting it as a node silently added a phantom row to every geometry
assertion — and one assertion was left counting raw `<rect>`s, which made
it pass no matter what. Both fixed; the coincidence-pass is the more
dangerous of the two.

Remaining in GR6: **dataviz on stzCanvas** (the third island), and the
compute↔render composition demo — already demonstrated in the showcase
(676 instances placed by a kernel), so it needs writing up rather than
building.

---

## GR6c STATUS — shipped 2026-08-09: the third island, and GR6 is complete

Every chart type now answers in pixels. `stzPlotCanvas` gained
`:Histogram`, `:MultiBar` and `:Treemap`, and the four remaining faces —
`stzHistogram`, `stzScatterPlot`, `stzMBarPlot`, `stzSurfacePlot` — each
gained `ToCanvasQ()` / `ToSVG()` / `ToPNG()` reading its OWN model: bin
counts and bin labels, point pairs, series values and their names, parts
of a whole. Nothing restates what the object already knows. Guard:
`base/test/graphics/dataviz_backends_narrated.ring` — **19 asserts
green, all deviceless**. The pre-existing stats suites stay green
(chart subclasses 16, engine parity 107, solvers 17).

The assertions go after what would be WRONG rather than merely ugly:

- **A histogram's bars TOUCH, because its bins do.** A gap would draw a
  distribution that is not there. Asserted as the maximum horizontal gap
  across the baseline row (≤ 2 px, the deliberate 1 px separator).
- **A treemap's AREAS are its values** — the entire claim of a
  composition chart, so it is checked as arithmetic on the emitted
  rectangles rather than by eye. Measured: 45/25/15/10/5 against
  45/25/15/10/5. Layout is slice-and-dice with an alternating split
  direction; squarified packing is the upgrade if a caller ever brings
  dozens of slices.
- **A multi-series chart carries a LEGEND**, without which it cannot be
  read, and its series names come from the model so they cannot go
  stale. Asserted as 12 bars + 3 swatches, in ≥ 3 distinct fills.
- A histogram thins its bin labels when they would collide — a row of
  overlapping labels tells a reader less than a sparse one.

**A bug the guard's last assertion caught**, worth recording because the
shape recurs: a multi-series plot whose series carry no values has a
non-empty outer list, so the "is there data?" check passed, and the
scale computation then died on an out-of-range index. A list of empty
lists is still an empty plot, and it now refuses the same way — the
check moved to AFTER flattening, where the question can actually be
answered.

**GR6 is complete.** The three islands the plan named have joined the
plane: plots and dataviz ride stzCanvas, hierarchies lay themselves out
without dot.exe, and the compute↔render composition is demonstrated
(676 instances placed by a kernel in one draw call — showcase.ring).

Remaining phases: **GR4b** (stzMaterialMaker + the fragment-stage
transpiler) and **GR5** (presentation on all OSs), where challenge gaps
2 and 3 — sampled render targets and compute+render in one submit —
finally pay for themselves.

---

## GR4b STATUS — shipped 2026-08-09: materials, and the fragment stage

The W-string → WGSL transpiler gained a **fragment stage**
(`stz_gpu_wgsl_fragment` in `gpu_wgsl.zig`), and `stzMaterialMaker` is
its face. Guard: `base/test/graphics/material_maker_narrated.ring` —
**35 asserts green**, the authoring half needing no device. Reachable
suites re-swept: scene3d 46, declarative 20, scene 69, faces 63.

    oM = new stzMaterialMaker
    oM.TakesColor(:base)
    oM.TakesScalar(:glow)
    oM.ForEachFragment('{ @out = base * (0.25 + 0.75 * @lambert) * (1.0 + glow * @normal.y) }')
    oScene.SetMaterial(oM, [ :base = "#e0a030", :glow = 0.6 ])

**The FRAGMENT BUILTINS are what make it a material language** rather
than string concatenation: `@normal`, `@position`, `@uv`, `@lambert` and
`@color` are what the rasterizer already knows at this pixel, so the
material describes a surface instead of recomputing a renderer. Swizzles
ride along (`@normal.y`, `@color.rgb`) because that is how a surface is
actually described. Declared colours and scalars are bare names; the
same LITERAL-body discipline and 16-function whitelist as the compute
maker apply, and **every refusal names its offender** — nine of them are
guarded, including a bad swizzle and a function named but never called.

**What it emits is a COMPLETE shader on the render layer's existing 3D
contract** (frame at @0, instances at @1, material at @2) — a pipeline
that can be run, not a fragment nobody can bind. That is why a material
is a drop-in: `residencyFor` simply picks it over the built-in shading,
and nothing else in the render path changed.

Scope, stated: a material is **scene-level**. Per-instance materials
would have to split the draw grouping by mesh AND material — a different
phase, not a bigger version of this one.

**The bug worth recording** (it cost this phase's debugging, and the
shape recurs): WGSL rounds a struct's SIZE up to its largest member
alignment, so a material carrying one `vec4` and one `f32` occupies 32
bytes, not 20. Sizing the buffer to the raw float count produced a
binding too small, and the failure surfaced as an unattributed
`wgpuQueueSubmit: Validation Error` — far from the arithmetic that
caused it. The same class as GR1's `layout:"auto"` trap: a binding
mistake reports itself at submit, never at the line responsible.

**Every phase of the plan is now shipped except GR5.** GR0 (go/no-go),
GR1 (render lifecycle), GR2 (2D + text), GR3 (3D), GR4a (faces), GR4b
(materials), GR6 (convergence). Remaining: **GR5** — presentation on all
OSs (GLFW vendored, window + surface, a loop WITH INPUT per §3b door 5),
which is also where challenge gaps 2 and 3 finally pay for themselves.

---

## GRAPH-ON-GPU SPIKE — 2026-08-09. VERDICT: GO. Graphs can compute their own picture.

The question behind it (the author's): the "graph" in graphics engine —
what would inviting `base/graph/` into this plane buy, and could it beat
a shader graph at *computational* thinking rather than at shading?

The distinction that makes it worth answering: **in ShaderGraph the graph
is SYNTAX** — an authoring UI consumed at compile time, which your program
can never interrogate. **In Softanza the graph is a computational object**
with algorithms and rule engines over it. So the graph can be the SUBJECT
of the picture, not merely the way the shader was drawn.

### KILL CRITERIA, written before measuring

A 10,000-node graph must be materially faster on the GPU than the path a
Softanza user has today, the whole frame must stay at one readback, and
the GPU answers must match the CPU answers EXACTLY. Fail any of the
three and the GPU route stays a demo; graphs keep computing CPU-side.

### Measured (`base/test/graphics/graph_gpu_spike.ring`)

Exact transitive reachability by bitset propagation — `reach[u] |=
reach[v]` over every edge, iterated to the DAG's depth, impact =
popcount − 1. The same algorithm both sides.

| n | edges | Ring (today's path) | GPU | speedup | mismatches | bus bytes during compute |
|---|---|---|---|---|---|---|
| 512 | 1,417 | 147 ms | 4 ms | 36.8x | **0** | **0** |
| 1,024 | 2,840 | 556 ms | 1 ms | (timer floor — not claimed) | **0** | **0** |
| 10,000 | 27,753 | **51,803 ms** | **388 ms** | **133x** | **0** | **0** |

### And the picture computes itself (`graph_gpu_picture.ring`)

Adjacency uploaded ONCE; reachability solved on device; a kernel writes
the INSTANCE BUFFER directly from the result (position, scale and colour
from impact — the door GR4a opened); the frame draws. For 10,000 nodes:

    solve + place + draw : 190 ms
    draw calls           : 1
    transformUploads     : 1  (frozen -- the kernel owns them)
    bus bytes, WHOLE FRAME: 1,800,112   (the picture itself is 1,800,000)

**112 bytes** of parameters is all that crossed besides the image. The
graph never came back to the CPU to be drawn.

### Honest caveats, recorded so the number is not repeated as more than it is

1. **The CPU baseline is the Ring interpreter, not optimized native.**
   133x is the PRODUCT-relevant number (what a user gains today), not a
   hardware claim. The fair engine-vs-engine figure needs a Zig CPU
   transitive-closure to compare against, and that does not exist yet.
2. The n=1,024 row is at the clock's resolution floor; only the 512 and
   10,000 rows carry a claim.
3. Iteration count is FIXED to the DAG's known depth. A general graph
   needs either a proven bound or a convergence check — and a
   convergence check is a readback per iteration, which would cost
   exactly the property this spike just proved. That trade is the next
   real design question, not a detail.
4. Memory is O(n²/8): 12.5 MB of bitset at n=10,000, 1.25 GB at
   n=100,000. Bitset reachability does not scale past ~30k nodes on this
   card; beyond that the algorithm must change (sampled reachability,
   or per-query BFS rather than all-pairs).

### What this licenses

Not "prettier shaders" — **graphs that compute their own picture on the
GPU**. A domain graph is the subject, the schedule and the drawing at
once, with no export step between them. That is a capability no shader
graph has, because a shader graph has no domain.

Recorded as the strongest candidate for the next plane after GR5, with
the three roles a graph could play written down: SUBJECT (proven here),
MATERIAL AUTHORING (a node DAG topologically emitted into the material
language — reaches ShaderGraph's shape, and needs the material language
deepened first: multiple statements, texture sampling, control flow),
and RENDER STRUCTURE (a frame graph whose passes and resource lifetimes
`stzGraphPlanner` schedules and `stzGraphRule` proves acyclic).

---

## GR5 STATUS — shipped 2026-08-09: a picture you WATCH

The last phase of GR0–GR6. Everything before it answered `ToSVG()` or
`ToPNG()`: a picture computed once and handed to a file. GR5 is the other
half — a picture recomputed while somebody is looking at it, and a user
who can act on it.

### What shipped

**`stz_window.dll` — its own DLL, as the amendment required.** GLFW 3.4
vendored (1.8 MB, src/ + include/, no cmake) and built from per-platform
source lists by `addGlfw` in `build.zig` — the libuv pattern this repo
already executes. Window creation, the event pump, keyboard, mouse,
framebuffer size, resize detection and delta time, all on the same
gen-keyed handle discipline as every other table in the engine.

**Presentation in `stz_gpu.dll`** (`gpu_surface.zig`). A wgpu surface from
the native handle, capability-driven format choice, configurable present
mode, and resize reconfiguration.

**The design decision that made it small:** a swapchain frame is ADOPTED
into the ordinary texture table as a render target (`gpu.adoptTarget`).
So the pass machine, the 2D scene, the 3D scene and GPU-driven instancing
all draw to a window through code that already existed. There is no second
renderer to keep in sync — `ToPixels` and `Present` are the same renderer
pointed at different targets. The adopted slot costs zero VRAM budget (the
surface allocated it) and is PINNED against eviction, because evicting the
frame you are drawing into would be a memorable way to lose a picture.

**`stzWindow`** — the face, under the naming law: verbs that act
(`Poll`, `Draw`, `Close`, `SetTitle`), `Q` for chaining, plain forms
returning data or nothing. Plus `Show(thing)` for a still picture and
`EachFrame(fn)` for a loop.

**`stzCanvas.Show()` now opens a real window** instead of writing a PNG
and asking the OS to open it — and still falls back to exactly that when
there is no windowing.

### Measured

| | bus bytes |
|---|---|
| 120 window frames, 700×420, still scene | **6,696** (all of it frame 1) |
| the same 120 frames through `ToPng` | 141,120,000 |

After the first frame a still scene moves **zero** bytes. The guard
asserts that number rather than a ratio, because a ratio can be true while
both sides are wrong.

### Three defects the window found that no offscreen test could

1. **Timeout from frame 3, forever.** The window drew exactly 2 frames of
   120 and went quiet. Cause: releasing the frame reference BEFORE
   `wgpuSurfacePresent`, which leaves the swapchain unable to retire the
   image. Present-then-release fixed it. A device poll added at the same
   time was suspected — a control run with the poll removed still rendered
   every frame, so it was **measured innocent** and kept only for the job
   it actually does (running error callbacks in a loop that never reads
   back).

2. **A still scene re-uploaded its whole vertex set every frame** while
   reporting `builds = 1`. The retained-buffer property stopped at the
   tessellator and never reached the upload. Fixed by an upload generation
   (guarded against the buffer having been evicted and silently replaced),
   and `SceneStats` gained a sixth field so the two are countable
   separately. This is invisible to a renderer that only ever draws frame 1.

3. **An animated display list grew without bound** — a frame loop appends
   shapes forever with nothing to empty it. `sceneReset` / `Clear()`, with
   the guard's negative sibling proving the fix is load-bearing.

Also: `classname()` called inside a class body raises R20 (it resolves
against the class's own methods) — the same family as the bare `len()` and
`trim()` traps already in the project notes. Fixed with a file-scope
`StzDrawableKind()`.

### Added along the way

`StzColorFromHSL`, `StzColorWithAlpha`, `StzColorMix` — hex literals are
how a colour is WRITTEN; a frame loop cycling a hue needs a colour
COMPUTED. Verified against the standard HSL definition at the primaries,
greys and the wrap point.

### Verification status, stated rather than implied

| | |
|---|---|
| **Windows** | built and runtime-verified here — 42-assertion guard green, plus an interactive showcase |
| **Linux** | GLFW X11 backend vendored, build rules written, surface path written against the verified header fields. **Not built or run from this machine.** |
| **macOS** | GLFW Cocoa backend vendored (`.m` sources), build rules written; the NSWindow→CAMetalLayer bridge is written through the Objective-C runtime rather than Cocoa headers. **Not built or run from this machine, and not compile-checked** — Zig only analyses the taken branch of a comptime switch. |

The honest summary: **Windows is shipped; Linux and macOS are written and
plausible but unproven.** That is exactly what the amendment predicted
would happen and why the window lives in its own DLL — the other 40+
engine domains still cross-compile to all three.

### Guards

`base/test/graphics/window_narrated.ring` — 42 assertions, headless-safe
(it reports the refusal and stops rather than faking a pass). Regression
sweep of every suite the change can reach: 261 assertions, all green.

`base/test/graphics/showcase_window.ring` — interactive; `ring
showcase_window.ring 180` runs a fixed budget on autopilot and saves the
last frame, because a demo that needs a human to check it is a demo nobody
checks.

### GR0–GR6 are complete

Next: the graph plane, `SOFTANZA_GRAPH_PLANE_PLAN.md` (GG0–GG5). GG0 is
already done (the spike returned GO); GG1 is the next phase. Note that
GG4's dependency — sampled render targets and compute+render sharing one
submit — was NOT closed by GR5; presentation did not need it, and closing
a gap that nothing yet exercises is the error G6 already taught.
