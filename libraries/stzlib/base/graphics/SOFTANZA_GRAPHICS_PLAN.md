# SOFTANZA GRAPHICS PLAN — analysis and phased plan (GR0–GR6)

Status: PLAN OF RECORD, written 2026-08-08, before any code. The sibling
document is `base/gpu/SOFTANZA_GPU_PLAN.md` (G0–G6, complete): this plan
inherits its laws, its lifecycle layer, and — decisively — its vendor.

The product vision (the author's words, two requirements):

1. **Softanzified programmability** — a DECLARATIVE experience for
   designing graphics in Ring, the way stzRegexMaker made regex
   declarative and stzKernelMaker made GPU compute declarative.
2. **A highly efficient backend** — GPU-based, riding the numerical and
   lower-level assets already in the house (the wgpu plane, the SIMD
   engine loops, the multicore tier, the batched-pass machinery).

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
fills, strokes, gradients), FONT rasterization (TTF), image DECODE
(PNG/JPG textures), a scene/mesh model, and windowing. Everything else
is assembly of things that exist.

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

**DECISION: no new graphics engine is vendored.** The backend is the
wgpu plane we already own, extended from compute to render. The only
NEW vendoring is the lightest in the repo's history: **stb_truetype.h**
(TTF → glyph bitmaps/metrics) and **stb_image.h** (PNG/JPG decode for
textures) — two single-header, dependency-free, public-domain C files,
compiled by Zig like utf8proc. PNG WRITING is pure Zig over the
already-vendored zlib. The 2D vector rasterizer is written IN ZIG
(scanline path filling — the SIMD loops and multicore tier apply to
exactly this shape of work), with the honest fallback that early
phases can ship on the GPU raster + SVG before the CPU rasterizer is
complete.

Runner-up, documented for the day the trade changes: **PlutoVG** (small
pure-C 2D vector rasterizer, zig-compilable) IF the pure-Zig rasterizer
proves costlier than budgeted — the GR2 kill criterion names the line.
Killed on principle: **bgfx** (offline shader compilation = the same
SDK invariant that killed ggml-Vulkan), **NanoVG/raylib** (OpenGL = a
second GPU surface outside the counted-fallback discipline),
**Skia/Cairo** (weight), **sokol_gfx** (a second abstraction over the
API we already bind directly).

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
  3. **A native window** — Windows-first: raw Win32 window + wgpu
     surface from HWND, ZERO new vendor. (RingQt interop = hand it
     PNG frames; noted, not depended on.)
  4. **The browser** — the same scene, the same WGSL, through the
     delivery plane's bundles onto a WebGPU canvas (the G5 mechanism,
     now drawing instead of computing).
- **f32 graphics math is its own small module** (vec2/3/4, mat4,
  quaternion, camera) — pure Zig, SIMD where it pays, DELIBERATELY
  apart from the f64 solver tier whose bit-stability is contractual.
- **Text**: stb_truetype rasterizes glyphs into a GPU atlas (render
  path) and provides metrics (SVG path). ASCII+Latin first; complex
  shaping (harfbuzz-class) is explicitly OUT until a workload asks —
  the G6 lesson.
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
stb_truetype + stb_image vendored and compiled. Guards: create/free
churn, eviction under pressure, fallback counting — the G1 suite's
shape, for render objects.

**GR2 — the 2D layer.** Shape batching (rect/circle/line/polyline/
path) into vertex buffers; ONE 2D pipeline with per-vertex color +
texture; glyph atlas text; gradients. The SVG emitter as the sister
backend of the SAME display list — one canvas model, two renderers.
The pure-Zig scanline rasterizer starts here as the CPU fallback. KILL
CRITERION: if the Zig rasterizer costs more than ~2 focused weeks of
sessions to reach fill+stroke+clip parity with the SVG output on the
guard corpus, vendor PlutoVG instead (the runner-up exists for this
exact line).

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

**GR5 — presentation.** Native Win32 window + wgpu surface (no new
vendor) with a render loop and basic input events; the BROWSER target
through the delivery plane (scene serialized + same WGSL, canvas
presentation — the G5 edge machinery pointed at pixels). Deployment
gate: gpu-required/optional already exists and applies unchanged.

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
- **Text is a bottomless field**; stb_truetype + Latin-first is the
  floor, and the plan says so where users will read it.
- **dot.exe remains external** for graph layout; named, scoped,
  revisit trigger recorded.
- **CI has no GPU**: every guard passes through the SVG tier and the
  counted-refusal paths; GPU assertions gate on availability, exactly
  as the 162-assert G-plane suite already demonstrates.
