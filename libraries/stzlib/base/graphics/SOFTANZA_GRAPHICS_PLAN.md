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

**Level-1 surface (sketch, Softanza-style — the declarative promise):**

    # 2D: a canvas is described, then rendered to any tier
    oC = new stzCanvas(800, 600)
    oC.Background("#101418")
    oC.Circle(400, 300, 120).Fill("#e0a030").Stroke("#ffffff", 2)
    oC.Text("Softanza", 330, 310).Font("Inter", 24).Color("#ffffff")
    oC.ToSVG()                      # tier 1 — always works
    oC.ToPNG("out.png")             # tier 2 — GPU offscreen (or CPU)
    oC.Show()                       # tier 3/4 — window or browser

    # 3D: a scene graph, declaratively
    oS = new stzScene()
    oS.Camera().At(0, 2, 5).LookAt(0, 0, 0)
    oS.Light(:Directional).From(1, 1, 0)
    oS.Add(StzMeshQ(:Cube)).At(0, 0, 0).Material(oM)
    oS.RenderTo("frame.png")

    # materials: the W-string → WGSL story, extended from G4
    oM = new stzMaterialMaker()
    oM.TakesColor(:base) ; oM.TakesScalar(:glow)
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
into vendor/wgpu under the same VERSION/checksum discipline. Runtime
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
