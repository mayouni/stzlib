# SOFTANZA GPU PLAN — analysis and phased plan (G0–G6)

Status: PLAN OF RECORD, written 2026-08-07, before any code. To be executed
in a dedicated session. This document is the analysis the user asked for:
which engine to vendor, why, what the two product levels look like, and the
phase gates — with kill criteria, because half of this plan's job is to say
where GPU does NOT pay.

The product vision (user's words, two levels):

1. **A declarative programming API** — GPU compute made approachable the way
   stzRegexMaker made regex approachable: the user describes the computation,
   Softanza generates and runs the kernel.
2. **A backend acceleration service** — demanding operations inside the
   library silently dispatch to the GPU when it wins, without the user
   noticing anything but speed.

And one procurement rule: a wise choice of ONE lightweight,
industrial-strength library to vendor, used everywhere GPU is needed.

---

## 0. The two facts that shape everything

**FACT 1 — the dev machine (measured, not assumed):**

    NVIDIA GeForce RTX 3050 6GB Laptop   driver 32.0.15.6100
    Intel(R) Graphics (iGPU)             driver 32.0.101.7076

Real hardware for G0's measurements, covering both the discrete-NVIDIA and
integrated-Intel cases — the two populations end users actually have.

**FACT 2 — the engine's numeric tier is f64, and consumer GPUs are not.**

WGSL (WebGPU's kernel language) has NO f64 type in core. Consumer NVIDIA
silicon runs f64 at 1/32–1/64 of f32 rate (the 3050 is 1/64). Meanwhile our
CPU matmul already does 15.6 GFLOP/s f64 after the i-k-j + slice work, and
the whole linalg oracle tier (determinant/solve/inverse/QR/Cholesky, with
κ(A)·eps tolerance arguments) is built on f64 bit-stability — we refused to
re-associate additions in cholesky() for exactly this reason.

**Consequence, stated up front so nobody relearns it later: the GPU scope is
the f32-TOLERANT domains — embeddings, similarity/knn/ann distances, neural
(ggml is f32/f16 anyway), FFT-at-scale, raster/image, tolerance-banded
stats — and NOT the f64 solver tier.** The solver tier stays on CPU SIMD,
where it is already fast and bit-stable. A GPU f64 path on consumer silicon
would be transfer-bound, 1/64-rate, and would re-open every oracle tolerance
for a marginal win. This is a scoping decision, not a limitation to fix.

---

## 1. The vendor decision

Candidates actually evaluated against this codebase's constraints (Zig build,
no cmake, vendored deps compiled by Zig where possible, flat C ABI per-domain
DLLs, Windows-first, WASM edge plane in the delivery story):

| | wgpu-native (WebGPU) | OpenCL (ICD loader) | Vulkan direct | ggml-Vulkan | CUDA |
|---|---|---|---|---|---|
| Industrial strength | Firefox's WebGPU core; Chrome's sibling (Dawn) | 15-year workhorse | maximal | llama.cpp lineage | maximal |
| Vendor weight | prebuilt C-ABI binary (~20 MB, official releases) | ICD loader, tiny pure C, **Zig-compilable** | headers + loader, but... | backend sources + SPIR-V toolchain — heavy | SDK — out |
| Kernel language | **WGSL, compiled at RUNTIME from strings** | OpenCL C, runtime from strings | SPIR-V — needs offline shader toolchain | fixed tensor ops, no custom kernels | CUDA C |
| f64 | **NO** (core WGSL) | yes (cl_khr_fp64, 1/64 rate here) | yes (shaderFloat64) | no (f32/f16) | yes |
| Portability | DX12 + Vulkan + Metal + **browser WASM** | Windows/Linux fine; macOS deprecated (stuck 1.2) | all native, no browser | wherever ggml builds it | NVIDIA only |
| Fit for declarative DSL | perfect — generate WGSL text | perfect — generate CL text | poor — SPIR-V is not writable text | none | n/a |
| Fit for WASM edge plane | **1:1 — same WGSL runs in-browser** | none | none | none | none |

**DECISION: vendor `wgpu-native`.** Three reasons, in order:

1. **Runtime kernel compilation from text** is what makes level-1 (the
   declarative API) cheap and natural: stzKernelMaker generates WGSL strings
   the same way stzRegexMaker generates patterns and the W paradigm generates
   conditional code. Vulkan's SPIR-V requirement kills this; only WebGPU and
   OpenCL have it, and of those two:
2. **WebGPU is the only candidate that reaches the WASM edge plane.** The
   delivery plane already ships WASM; WebGPU is the browser's compute API,
   and the SAME WGSL kernels run there. No other option converges the native
   and edge stories.
3. **One API over DX12/Vulkan/Metal** covers the census machine's NVIDIA and
   Intel adapters today and macOS later, with the maintenance weight of one
   binding, not three.

The cost accepted: wgpu-native is Rust, so it is vendored as an official
prebuilt binary (pinned version + checksum) rather than Zig-compiled source —
a first for this repo, and acknowledged as such. The C header (webgpu.h) is
the ABI; Zig binds it like any C library.

**Runner-up, documented for the day the trade changes:** the OpenCL ICD
loader — the genuinely lightest vendoring (small pure C, Zig-compiled, zero
binaries; the runtime comes from GPU drivers, and both adapters here ship
it) and the only lightweight route to f64-on-GPU. Switch criteria: if
prebuilt-binary vendoring is rejected on principle, or a real f64 GPU
requirement emerges. **ggml-Vulkan** is NOT a competitor to this decision —
it is a possible later flag strictly for the neural tier (its Vulkan backend
sources are currently NOT vendored; only the header is), and gets its own
go/no-go in G6.

---

## 2. Architecture — the house laws, applied to a GPU

- **One new DLL: `stz_gpu.dll`.** Devices, queues, buffers, compiled
  pipelines are HANDLES in this DLL's table. Handle tables are per-DLL (the
  ggml-bridge lesson): no other DLL ever receives a GPU handle. Code may be
  shared via @import; handle IDs may not cross.
- **Residency is the entire game.** The string-drain work measured 92% of a
  find's cost in marshalling OUT at FFI speed; over PCIe it is worse. Every
  op takes and returns DEVICE-BUFFER handles so chains run without readback:
  upload once → N kernels → read back once. The Ring face mirrors
  stzNumBuffer: `new stzGpuBuffer(aData)` holds a device handle the way
  stzString holds @pEngine — and the finder-copy lesson applies: no per-call
  wrapper objects around it.
- **Ring has no destructors** (the stzList leak lesson, 33s→50s). Buffer
  lifetime = explicit Free() PLUS a bounded, generation-keyed device-memory
  cache with FIFO eviction, exactly like the list residency keystone. VRAM
  is 4–6 GB here; the bound is not optional.
- **Dispatch is threshold-gated, and the threshold is MEASURED.** First use
  calibrates crossover N per op on the actual machine and caches it. Below
  N: CPU path, always. The perf plans named the wrong line 4/6 times —
  nobody guesses where the GPU starts winning.
- **Failure is fallback, and fallback is COUNTED.** No adapter, driver
  reset, TDR, out-of-VRAM → the CPU path answers correctly and
  `gpu.fallback.count` increments (a bounded record must COUNT what it
  drops). Instruments use house names: `gpu.dispatch.ms`,
  `gpu.transfer.bytes`, `gpu.fallback.count`; a device watcher exposes
  `Name_()` + `Cycle()` so any stzAgentHost can tick it.
- **Windows TDR:** the default 2-second watchdog kills long kernels. Kernels
  are tiled/split by design; this goes in G1's lifecycle layer, not
  discovered in production.

**Level-1 surface (sketch, Softanza-style):**

    oG = new stzGpu()
    ? oG.IsAvailable() + " on " + oG.DeviceName()

    k = new stzKernelMaker()
    k.TakesVector(:A) ; k.TakesVector(:B) ; k.ReturnsVector(:C)
    k.ForEachElement('{ @C = 2.0 * @A + @B }')     # W-string → WGSL
    aC = oG.Run(k, [ :A = a1, :B = a2 ])

    # chained, resident:
    b1 = oG.Upload(aBig)
    b2 = oG.Apply(k1, b1).Apply(k2).Apply(k3)      # no readback between
    aOut = b2.Download()

**Level-2 seams (silent):** embedding/knn/ann distance scans at corpus
scale, umap/tsne neighbour phases, batched f32 matmul for the ML floor,
FFT-at-scale — each admitted ONLY after G0's decomposition table shows
compute dominating transfer for that op. The f64 oracle tier is explicitly
out.

---

## 3. Phases

**G0 — Crossover spike (the go/no-go).** Vendor the pinned wgpu-native
binary, minimal Zig binding, TWO kernels only (saxpy, f32 matmul). Produce
the decomposition table {upload, dispatch, readback} × {sizes} × {3050,
iGPU} against the existing CPU SIMD paths. Deliverable: measured crossover
points and a kept/killed list of candidate ops. KILL CRITERIA, written
before measuring: any op whose transfer share exceeds compute at realistic
sizes is out; if even resident-chain matmul cannot beat CPU under ~1024²,
the silent-service scope shrinks to batch workloads and the plan says so.

**G1 — `stz_gpu.dll` lifecycle.** Device/queue/buffer/pipeline handles,
WGSL compile-cache (pipelines are expensive; compile once per kernel text),
bounded VRAM cache, calibration store, TDR-safe tiling, instruments,
fallback discipline. Guard: create/free churn, eviction under pressure,
fallback counters — the negative siblings included.

**G2 — Op library.** matmulF32, elementwise family, reductions (sum/dot),
pairwise-distance (the embedding kernel), softmax. Each op ships with a
parity guard against the CPU reference within a per-op tolerance band SET
FROM MEASUREMENT, and exact witnesses captured before any later change.

**G3 — Silent seams.** Wire the G0-approved ops behind existing faces
(knn/ann/embeddings first). Threshold dispatch + residency chains. The user
notices nothing but speed; the guards assert BOTH sides of the threshold
(GPU wins above N, CPU keeps below N — assert the mechanism, not the vibe).

**G4 — Declarative surface.** stzGpu / stzGpuBuffer / stzKernelMaker; the
W-string → WGSL transpiler (the WXT/W lessons apply: LITERAL predicates,
document the transpile); narrated suites that run for real on this machine.

**G5 — Edge convergence.** The same WGSL kernels through the WASM/WebGPU
delivery plane; capability probing joins the deployment gates (a deployment
declares gpu-required / gpu-optional; Deploy() refuses or degrades
accordingly — the service-virtualization precedent).

**G6 — Neural tier option (separate decision).** Evaluate vendoring ggml's
Vulkan backend for the existing ggml path specifically. Own measurement, own
kill criteria; not part of the wgpu commitment.

---

## 4. Risks, named now

- **Prebuilt-binary vendoring** is new here. Mitigation: pinned release,
  recorded checksum, the OpenCL fallback documented above.
- **Laptop thermals** make sustained-throughput numbers lie. G0 measures
  warm AND sustained, and calibration stores the conservative number.
- **f32 parity vs f64 CPU references**: tolerance bands per op, from
  measurement — never "close enough" by eyeball, and never a band copied
  from a comment.
- **Two adapters** (NVIDIA + Intel): adapter selection is explicit,
  calibration is per-adapter, and the iGPU is a legitimate target (shared
  memory = cheaper transfer), not a nuisance.
- **CI has no GPU**: every guard must pass on the fallback path too; GPU
  assertions gate on IsAvailable() and the fallback guard asserts
  correctness-without-device explicitly.

---

## G0 RESULTS — measured 2026-08-07. VERDICT: GO, with the scope the numbers dictate

Environment: wgpu-native v29.0.1.1 (pinned prebuilt, SHA-256 recorded in
`engine/vendor/wgpu/VERSION`), Zig 0.15.2, ReleaseSafe (the shipped mode).
Spike: `engine/tools/gpu_spike.zig` (build line in its header). Both adapters
ran on the SAME backend (Vulkan) to remove the backend confound. Machine was
shared with other sessions — recorded as-is, variance noted where it moved.

Methodology: monotonic clock; per op 3 warmups + 5 timed reps (min AND
median), then 3 s continuous with the first 1 s discarded ("sustained");
CPU samples inner-loop scaled to ≥1 ms; every GPU op timed as
submit+wait-idle (the price a real call pays, submission overhead included);
chain10 = 10 dispatches in ONE compute pass, amortized /10 = the
resident-chain number. Every GPU result verified against the CPU f32
reference: max rel err 6.9e-8 (saxpy), 3.3e-7 (matmul 2048²) — f32
accumulation-order noise, nothing else.

### CPU baselines (this machine, this session — remeasured, not quoted)

| op | n | f32 | f64 (the shipped tier) |
|---|---|---|---|
| saxpy | 4096 | 0.0003 ms | 0.0006 ms |
| saxpy | 4.2M | 1.25 ms (40 GB/s) | 2.65 ms (38 GB/s) |
| matmul | 128 | 0.145 ms (28.9 GF/s) | 0.269 ms (15.6 GF/s) |
| matmul | 512 | 13.9 ms (19.3 GF/s) | 22.8 ms (11.8 GF/s) |
| matmul | 1024 | 101.5 ms (21.2 GF/s) | 329 ms (6.5 GF/s) |
| matmul | 2048 | 1742 ms (9.9 GF/s) | 3563 ms (4.8 GF/s) |

The engine's recorded 15.6 GFLOP/s f64 reproduces at n=128; at 512 today it
read 11.8 (shared machine). Above 1024 the i-k-j loop falls off the cache
cliff — the CPU number the GPU must beat at scale is 5–7 GF/s f64, ~10-21 f32.

### Decomposition — RTX 3050 Laptop (Vulkan), warm-min / sustained, ms

| matmul n | upload | dispatch | chain10/op | readback | GPU GF/s (chain) |
|---|---|---|---|---|---|
| 64 | 0.056 | 0.059 / 0.070 | 0.012 | 0.049 | 41 |
| 128 | 0.073 | 0.095 / 0.083 | 0.025 | 0.056 | 155 |
| 256 | 0.14 | 0.25 / 0.18 | 0.12 | 0.087 | 250 |
| 512 | 0.32 | 1.82 / 1.11 | 0.96 | 0.22 | 280 |
| 1024 | 1.11 | 18.9 / 8.4 | 7.3 | 0.85 | 294 |
| 2048 | 5.0 (5→19 across runs) | 64.6 / 62.1 | 58.5 | 3.06 | 293 |

| saxpy n | upload (2 bufs) | dispatch | chain10/op | readback |
|---|---|---|---|---|
| 4096 | 0.061 | 0.060 | 0.009 | 0.051 |
| 262144 | 0.33 | 0.082 | 0.026 | 0.19 |
| 1.05M | 1.10 | 0.174 | 0.111 | 0.67 |
| 4.2M | 4.35 | 0.53 | 0.43 | 2.79 |

Transfers: upload ≈7.6 GB/s, readback ≈5–6 GB/s. Submission floor ≈55–70 µs
per submit+wait; INSIDE one pass a dispatch costs ~9 µs — pass-batching
amortizes ~7x of the submission overhead (G1 design input).

### Decomposition — Intel iGPU (Vulkan), warm-min / sustained, ms

| matmul n | upload | dispatch | chain10/op | readback | GPU GF/s (chain) |
|---|---|---|---|---|---|
| 64 | 0.34 | 0.24 / 0.33 | 0.089 | 0.26 | 4.8 |
| 128 | 0.20 | 0.62 / 0.78 | 0.11–0.26 | 0.13 | 37 |
| 256 | 0.23 | 2.83 / 0.85 | 0.57 | 0.16 | 57 |
| 512 | 0.45 | 4.4 / 4.4 (first-ever run 19.4: cold clocks) | 4.2 | 0.23 | 64 |
| 1024 | 1.33 | 32.9 / 33.8 | 33.6 | 0.53 | 64 |
| 2048 | 5.0 | 272.7 / 274.6 | 274 | 2.10 | 62 |

saxpy 4.2M: upload 5–7, dispatch 1.6–1.8, chain10/op 0.79–0.87, readback
2.0–3.4. Submission floor ≈220–420 µs. Note: the iGPU's shared memory did
NOT make transfer cheap through wgpu — staging copies still happen (upload
~5 GB/s). The "iGPU = free transfer" hope is dead until/unless G1 measures
mapped-at-creation buffers.

### Kill criteria, applied

**KILLED — standalone elementwise (saxpy and its whole family).** Transfer
share is 92% of one-shot cost at 4M elements on the 3050 (7.2 of 7.7 ms) —
the same 92% the string-drain measured at FFI speed, now over PCIe. One-shot
GPU saxpy LOSES to CPU f32 at every size tested (6.2x worse at 4M, 570x at
4K). Even fully resident, the chain win peaks at 2.9x (4M) and only crosses
CPU at ~256K elements. Elementwise ops are admitted ONLY as links inside
resident chains between compute-dense ops, never as a dispatch of their own.

**KILLED — anything below the dispatch floor.** One submit+wait costs
~60 µs (3050) / ~250 µs (iGPU) before any math. matmul n=64 and n=128
one-shot stay CPU on both adapters. The calibrated threshold gate is not
optional politeness; it is where most of the op catalog actually lives.

**KEPT — f32 matmul and the compute-dense family** (ops doing O(n) work per
element moved: matmul, pairwise-distance, attention-shaped blocks).
Resident-chain matmul at 1024² runs 294 GFLOP/s on the 3050 — 45x the CPU
f64 tier, 14x CPU f32 — and 64 GF/s on the bare iGPU (9x / 2.9x). The kill
criterion ("resident chain must beat CPU under ~1024²") passes on BOTH
adapters with room: the chain crosses CPU at n≈128 (3050) / n≈256 (iGPU).
And this is the FLOOR — a plain 16×16 tile, ~5% of the 3050's peak; G2
tuning has headroom, the decision doesn't depend on it.

**CONDITIONAL — FFT-at-scale, reductions, softmax.** Between the two poles
measured here (O(1) and O(n) work per element); each gets this same
decomposition in G2 before admission. No op enters the silent tier on vibes.

### Calibrated crossover points (this machine; G3 recalibrates per install)

| | RTX 3050 | Intel iGPU |
|---|---|---|
| matmul one-shot (upload+dispatch+readback) | n ≈ 192–256 | n ≈ 384–512 |
| matmul resident-chain | n ≈ 128 | n ≈ 256 |
| elementwise one-shot | NEVER | NEVER |
| elementwise inside resident chain | ~256K elems | ~1M elems |

### Findings G1 must inherit

1. **Pipeline compile is 5–34 ms cold, 0.4 ms warm** (driver shader cache).
   The WGSL compile-cache is justified by measurement, not principle.
2. **The clock inversion.** On this laptop the GPU idles at low clocks:
   warm-min dispatch at 1024² is 2.3x SLOWER than sustained (18.9 vs
   8.4 ms). A sporadic one-shot call pays the slow number — calibration must
   store the WARM-MIN (conservative), and "sustained" flatters any op that
   ships as occasional calls. (Opposite direction from CPU thermal lying.)
3. **Pass-batching is the cheap residency win**: 10 dispatches in one pass
   amortize submission ~7x (3050). Chains should coalesce into one pass
   whenever dependencies allow.
4. **Transfer variance is real**: the 2048² upload moved 5→19 ms across
   otherwise-identical runs. Calibration should treat transfer cost as a
   band, not a point.
5. f32 GPU vs f64 CPU parity: rel err ≤3.3e-7 vs the f32 reference; vs the
   f64 tier the difference is f32 representation itself — the tolerance-band
   work in G2 starts from these measured figures.

Scope confirmed as planned: f32-tolerant domains only; the f64 solver tier
stays CPU. The silent-service scope does NOT shrink to batch-only — the
resident-chain criterion passed on both adapters.

---

## G1 STATUS — shipped 2026-08-07: stz_gpu.dll, the lifecycle layer

Delivered (guard: `base/test/gpu/gpu_lifecycle_narrated.ring`, 62 asserts
green on this machine + a 9-assert no-GPU probe of the same surface):

- **`stz_gpu.dll`** (engine domain `stz_gpu`; `src/gpu.zig` +
  `ring_bridge_gpu.zig`, loader `engine/stz_gpu.ring`, registered in
  stzRingLibs). wgpu_native.dll is loaded at **Init() time via LoadLibrary,
  never linked** — the DLL loads everywhere, and a machine without the
  runtime or an adapter degrades to counted fallback. CI-safe by
  construction; the guard is deliberately STANDALONE (loads only the engine
  bridge) so an unrelated face breakage cannot mask a GPU regression.
- **Generation-keyed handles**: buffer ids are (gen<<32)|slot; free AND
  evict bump the generation, so stale ids answer STALE — never a silently
  reused pointer (the handle-cliff lesson applied to VRAM). 200-cycle
  churn guard: live-count and byte accounting return exactly to baseline,
  200/200 freed ids detected stale.
- **Bounded VRAM cache, FIFO eviction**, budget settable; eviction is
  COUNTED and the guard names the victim (oldest live) and its negative
  sibling (big budget ⇒ zero evictions).
- **WGSL compile-cache** keyed by kernel text hash: 1 compile + N hits,
  counted separately; malformed WGSL refuses AND counts a device error.
- **TDR-safe tiling**: every kernel binds a layer-owned tile uniform at
  @binding(0) (xoff in workgroups; user buffers start at @binding(1));
  dispatches over the tile limit split along x — one shared uniform serves
  all tiles because writeBuffer/submit are queue-ordered. Guard: wx=16 at
  limit 4 ⇒ EXACTLY 4 submits and a bit-exact result.
- **Calibration store** (op name → crossover threshold): ShouldDispatch
  answers CPU when the device is absent, the op is uncalibrated, or n is
  below the line; GPU only above a measured line. Warm-min basis per G0's
  clock inversion.
- **Instruments** (house names): gpu.dispatch.count/ms, gpu.transfer.bytes,
  gpu.fallback.count, compiles/hits, submits, evictions, live buffers,
  device errors. Counter reset preserves structural gauges (live count).
- **Dispatch is asynchronous** (returns after submit; Sync() or a read
  completes) — residency chains run upload-once → N dispatches → read-once,
  which is the entire G0 case for the GPU paying at all.

Next: **G2** — the op library (matmulF32, pairwise-distance, reductions,
softmax) with per-op parity bands from measurement, on this layer.

---

## G2 STATUS — shipped 2026-08-07: the op library

Seven ops in `engine/src/gpu_ops.zig`, all operating on G1 buffer ids
(upload once → chain → read back once; every op is submit-only except the
reductions, whose scalar answer lives on the CPU by definition):
**matmulF32** (16×16 tiled), **pairdist** (squared L2 rows×rows — the
embedding kernel; no sqrt, knn ranks on squared distance), **axpby / mul /
scale-inplace** (the chain links G0 admitted only inside resident chains),
**softmax** (max-shifted, 3 dispatches: max-reduce, fused exp+partials,
scale), **sum / dot** (per-workgroup shared-mem partials, f64 fold on CPU
in fixed ascending order — deterministic, and EXACT for integer data).

Mechanics worth recording:
- WGSL lives as comptime constants compiled through the G1 compile-cache
  per call — a text-hash lookup against a 60 µs dispatch floor. Ops are
  self-healing across device re-init (Shutdown/SelectAdapter clears
  pipelines; the next call recompiles). No epoch bookkeeping.
- Ops bind params at @binding(1) via `stz_gpu_dispatch_params` (a second
  shared uniform, same queue-ordering argument as the tile uniform);
  data buffers at @binding(2..). Tile uniform stays at @binding(0), so
  every op inherits G1's TDR tiling unchanged.
- Availability gates FIRST, then buffer checks: a dead device answers
  FALLBACK (counted at the refusing layer), not STALE-because-ids-died.
- OUT must be distinct from inputs (WebGPU usage-scope validation).

Parity guard (`base/test/gpu/gpu_ops_narrated.ring`, 37 asserts green):
- **Exact witnesses per op**: integer / dyadic data where every f32
  intermediate is exactly representable ⇒ bit-equality against Ring
  references, including RAGGED shapes (20×48×36 matmul, d=10 pairdist)
  that exercise the tile tails. A later change that breaks one changed
  the math, full stop.
- **Tolerance bands SET FROM MEASUREMENT** on non-dyadic (/251) data:
  matmul k=64 measured 4.05e-7 → band 1e-5 (25x); sum 100k measured
  1.28e-8 → band 5e-7 (39x); softmax measured 8.06e-7 → band 2e-5 (25x).
  The first draft used /256 dyadics and measured a literal ZERO — the
  "tolerance" scene was testing nothing; the measurement pass caught the
  scene design, which is what measurement passes are for.
- **Cross-adapter check**: the iGPU (Vulkan) produced BIT-IDENTICAL
  errors to the 3050 (4.04718e-7 / 8.05825e-7) — the kernels fix the
  accumulation order, so parity is driver-stable, not driver-lucky.
- Negatives: too-small buffers → BAD_ARG, freed → STALE, shut-down
  device → [FALLBACK, 0], zero fallbacks across the whole happy path.
- Chain scene: axpby → mul → scale → sum with no syncs between links,
  exact final scalar — queue ordering carries resident chains through
  the ops layer.

Next: **G3** — silent seams: wire these ops behind knn/ann/embeddings
faces with threshold dispatch (calibration store) + residency chains;
guards assert BOTH sides of the threshold.

---

## G3 STATUS — shipped 2026-08-07: the first silent seam

**`stzVectorIndex.SearchExact()` now runs its full scan on the GPU when
the corpus earns residency.** Measured on this machine: 2.2 ms/query
GPU-routed vs 39.4 ms CPU on a 50k×128 corpus — **17.9x**, same method,
same contract, nothing visible but speed.

Why THIS seam and not the obvious ones — the shape argument from G0,
applied honestly:
- A single-query scan over host data is O(1) flop per byte moved — the
  KILLED shape. What changes the class is **residency**: the corpus
  uploads ONCE at build; each query then moves d floats in and k pairs
  out while doing n·d flops — d flops per byte, compute-dense at real
  embedding widths. Residency is not an optimization of the seam, it IS
  the seam.
- The missing piece was **top-k engine-side** (`stz_gpu_op_topk`,
  read-back + bounded insertion, ties to the LOWER index like the CPU
  scan): a Ring-side pass over 100k distances would have eaten the win.
- stzKnn.Classify stays CPU for now: no batch surface exists, and f32
  distance ties could flip a CLASSIFICATION — a visible behavior change,
  which "silent" forbids. Noted for the calibration era.

The seam's discipline (in `stzVectorIndex._EnsureGpu/_QueryGpu`):
- **The threshold is consulted BEFORE the device**: CalibGet works
  without a device, so a small corpus never pays the ~300 ms Init. The
  gate is build-time (residency is a build-time investment); seed
  threshold n·d = 4M (conservative, ~8x above G0's computed crossover)
  until a calibration pass refines it.
- **:Cosine keeps the CPU** — the CPU index normalizes rows internally;
  raw rows on the GPU would compute WRONG distances. Guarded as a
  negative sibling, not just documented.
- **Any refusal falls through to the CPU path** (eviction → STALE, lost
  device, failed upload): same answer, later. After a runtime refusal
  the index stays CPU (no thrash); a config change re-opens the question.
- f32 distances vs the CPU's f64: same squared-Euclidean contract;
  indices agree exactly on separated data (both sides tie-break on the
  lower index), distance band measured at 1.47e-7 → asserted < 1e-5.

Guard: `base/test/gpu/gpu_seams_narrated.ring` (17 asserts, green; loads
the FULL stzBase because the seam lives in a library face). Both sides
of the threshold asserted by MECHANISM: below the line zero dispatches
and zero residency; above it 3 live buffers, the dispatch counter moves
1:1 with queries, and the answers match the forced-CPU twin. Plus: the
approximate path never touches the GPU, and a mid-life Shutdown()
answers identically through the CPU. The existing
`numeric_vector_index_narrated.ring` suite stays 28/28 green.

Next: **G4** — the declarative surface (stzGpu / stzGpuBuffer /
stzKernelMaker, W-string → WGSL); further seams (batch knn surfaces,
umap/tsne neighbour phases) ride on calibration work in G5.

---

## G4 STATUS — shipped 2026-08-07: the declarative surface

The level-1 vision from §0, working as sketched (suite:
`base/test/gpu/gpu_declarative_narrated.ring`, 20 asserts green; all four
GPU guards green together — 136 asserts):

    k = StzKernelMakerQ()
    k.TakesVector(:A)  k.TakesVector(:B)  k.TakesScalar(:alpha)
    k.ReturnsVector(:C)
    k.ForEachElement('{ @C = alpha * @A + @B }')
    aC = oG.Run(k, [ :A = a1, :B = a2, :alpha = 2.5 ])

    b2 = oG.UploadQ(aBig).ApplyQ(kDouble).ApplyWithQ(kShift, [:d = 100])
    aOut = b2.Download()

- **The transpiler is ENGINE substance** (`gpu_wgsl.zig`): a line-based
  spec (what the maker's declarations collapse into) → validated WGSL on
  the house binding contract (tile@0, params@1 with n + scalars packed in
  declaration order, inputs read at @2.., output read_write last). Any
  binding gets the declarative surface; Ring's stzKernelMaker is one face.
- **The W lessons enforced**: the body is LITERAL — one assignment, the
  declared names, arithmetic, and a 16-function whitelist. Refusals name
  the offender (undeclared vector, unknown identifier, reading the output,
  uncalled function, foreign character, wrong LHS — each guarded). The
  transpile is documented BY ITS OUTPUT: ToWGSL() returns the kernel
  verbatim.
- **Authoring needs no device**: transpile is pure text, so kernels can be
  written and inspected on GPU-less machines (CI included); only the data
  paths require a device, and they raise a clear message without one.
- **Residency proven by the transfer counter, not claimed**: the suite's
  3-op chain (upload → x2 → +100 → download) moves EXACTLY up + down
  bytes across the bus — zero transfer between links.
- **The faces keep the house laws**: stzGpuBuffer's state is two numbers
  (gen-keyed engine id + count), so copy-on-assign is harmless and stale
  ids answer by name; a missing scalar binding RAISES (a missing Ring
  hashlist key silently reads 0 — scanned explicitly); one-shot Run() is
  documented as the doorway, not the fast path (G0's 92% transfer share,
  stated in the class header).
- Ring lesson collected: a `func` after a `class` in the same file becomes
  a METHOD of that class — shared helpers must precede the class.

Remaining phases: **G5** (WASM/WebGPU edge convergence + deployment
gates + real calibration passes) and **G6** (the separate ggml-Vulkan
decision for the neural tier).

---

## G5 STATUS — shipped 2026-08-07: the edge converges, the thresholds are measured

**Edge convergence, PROVEN in a browser, not asserted.** The transpiler
went zero-allocation (fixed stack cursors, no libc) and now compiles into
stz.wasm as the `gpu` group (31.5 KB total; capability key `GpuKernels`
in the builder's map; exports `stz_gpu_wgsl_elementwise` / `_error`).
The proof harness (`base/test/gpu/edge_proof/`, run 2026-08-07, 5/5):

1. stz.wasm transpiled the same spec to **byte-identical WGSL** to the
   native engine's;
2. the browser's WebGPU ran that kernel text and its results were
   **exactly equal** to the native wgpu-native run's (256 f32-exact
   values).

Same spec → same kernel → same numbers, native and edge. The plan's
"the SAME WGSL runs in-browser" claim is now a measured fact.

**Calibration is measured, persisted, and consumed.**
`stzGpu.Calibrate()` walks a corpus-size ladder through the REAL G3
seam, both routes, warm-min per rung (the G0 clock inversion), stores
the first rung the GPU wins by ≥30%, and persists it under
`engine/data/` — `gpu_calib_default.txt` (loadable BEFORE any device;
the seam's cheap precheck reads it) + `gpu_calib_<adapter>.txt`
(per-adapter truth, loaded after Init). Measured here: the GPU wins
from n·d = 64k — the conservative 4M seed was **62x too cautious**;
the calibration pass genuinely changes routing. Authority order in the
faces: explicit CalibSet > persisted file > seed — the loaders are
FILL-ONLY, because a persisted value overriding an in-process explicit
one broke the seam guard the moment both existed (caught by the guard
sweep; the fix is semantic, not a patch).

**The deployment gate is an ADMISSION check.** stzResourceSpec carries
GPU on both roles (a requirement's SetGpuRequired/SetGpuOptional, a
capacity's SetGpuPresent; Meets/Plus/IsEmpty/Text extended). The gate
fires in Run() before a part's FIRST step — NOT inside the provision
op, which only exists for scriptable sites; the first draft put it
there and the gate never ran, while the refuse-scene passed by
COINCIDENCE on an unrelated store failure. The log-by-name assertion
is what caught it, and the guard now asserts "the gpu admission gate
refused" verbatim. Semantics: required + gpu-less site → the step
FAILS and the deploy refuses; optional + gpu-less → proceeds with the
degrade LOGGED (runtime falls back and counts, G1's law); a LOCAL site
answers by probing the real device; a remote site's GPU is its declared
capacity, absent otherwise.

Guards: `gpu_calibration_narrated.ring` (10) +
`gpu_deploy_gate_narrated.ring` (16); the six GPU guards together =
**162 asserts green**; the pre-existing deployment suite stays green.

Remaining: **G6** — the separate ggml-Vulkan go/no-go for the neural
tier, with its own measurement and kill criteria.

---

## G6 — the ggml-Vulkan decision

### Kill criteria, written 2026-08-07 BEFORE the measurement

The question: vendor ggml's Vulkan backend so the neural tier (BERT-family
embeddings, the generative decoder) runs its ggml graphs on the GPU.

- **K1 — workload eligibility by proxy.** The tier's compute is matmul at
  BERT-class shapes (hidden 384–1536, seq ≤ 512) plus token-by-token
  matvec for decoding. The already-shipped wgpu path is a fair PROXY
  CEILING for ggml-Vulkan on this silicon (same GPU, same f32). If the
  proxy cannot beat the tier's ACTUAL ggml CPU route by ≥2x on the
  forward-pass census, a second GPU stack cannot pay: NO-GO.
- **K2 — the vendoring invariant.** This repo builds with `zig build`,
  no cmake, no external SDK. ggml-Vulkan requires its GLSL shader set
  compiled to SPIR-V at build time (Vulkan SDK's glslc + ggml's
  vulkan-shaders-gen tool). Unless pinned pre-generated artifacts make
  the SDK unnecessary for BUILDING and for UPDATING the vendored ggml:
  NO-GO on principle, whatever the speed.
- **K3 — decisive margin for a second stack.** ggml-Vulkan would be a
  SECOND GPU surface — its own device/VRAM/TDR story OUTSIDE
  stz_gpu.dll's counted-fallback discipline. That duplication must buy
  ≥2x END-TO-END on the tier's real jobs (bulk embedding), not merely
  per-op wins: below that, NO-GO.
- **K4 — CI.** CPU must remain the load-time default with the backend
  behind runtime opt-in; a backend that cannot be isolated: NO-GO.

### The measurement (2026-08-07, `base/test/gpu/g6_census_bench.ring`)

The tier's shipped ggml route (`StzEngineMatrixMulGgml`, bridge overhead
included — that IS today's per-call price) against the shipped wgpu op on
resident buffers, warm-min of 5, RTX 3050:

| shape m×k×n | census role | ggml-cpu ms | wgpu ms | ratio |
|---|---|---|---|---|
| 128×384×384 | attn qkv/proj, seq 128 | 1.81 | 0.40 | 4.6x |
| 128×384×1536 | ffn up, seq 128 | 5.20 | 1.07 | 4.8x |
| 128×1536×384 | ffn down, seq 128 | 5.19 | 1.10 | 4.7x |
| 512×384×1536 | ffn up, seq 512 | 8.80 | 3.23 | 2.7x |
| 4096×384×1536 | batch embed | 45.9 | 24.2 | 1.9x |
| 1×384×1536 | decode matvec | 2.85 | 0.28 | (10.3x)* |
| 1×1536×384 | decode matvec down | 2.87 | 0.37 | (7.8x)* |

\* the matvec rows measure the BRIDGE, not ggml: MulGgml re-converts and
re-transposes B on every call (~0.02 ms of actual compute inside 2.85 ms).
Honest read of decode: a matvec is 1 flop per weight byte — G0's killed
shape — and at MiniLM scale (590 KB of weights per matmul) the CPU serves
it from cache faster than any dispatch floor. Decode stays CPU at small-
model scale, full stop. (The bridge-overhead finding is real and now has
its own task: resident tensor handles for MulGgml.)

Forward-pass and batch shapes: 1.9–4.8x for the GPU as shipped, and the
2.7–4.8x band survives even granting the CPU implausibly generous pure-
compute numbers — K1 PASSES for the embedding workload.

### DECISION: NO-GO on vendoring ggml-Vulkan — the wgpu plane is the route

Killed by **K2** and **K3**, despite K1 passing:

- **K2 kills it on the invariant.** ggml-Vulkan's build compiles a GLSL
  shader set to SPIR-V via the Vulkan SDK's glslc plus ggml's own
  generator tool (our vendored ggml has the backend pruned entirely).
  Pinning pre-generated SPIR-V would vendor a build product this repo
  cannot regenerate without installing the SDK — every ggml update would
  re-require it. That is cmake-by-another-name; the invariant holds.
- **K3 cannot even be measured yet** — and that is itself the decision:
  the BERT forward pass ggml-Vulkan would accelerate is NOT IMPLEMENTED
  (neural_embed.zig is at the model-loading milestone; the forward pass
  is its next). Vendoring a second GPU stack for a workload that does
  not exist is premature by definition.

  **CORRECTION (2026-08-07, same day, next session): the K3 premise was
  WRONG.** The forward pass HAS been implemented for some time — full
  BERT-family encoder, NER head, reranker, and a generative decoder —
  and this record repeated neural_embed.zig's STALE HEADER ("the forward
  pass is the next milestone") without reading the file's 900 lines.
  The derive-from-the-label lesson, again. What survives unchanged: the
  NO-GO stands on **K2 alone** (the SDK invariant is independent and
  sufficient), and K1's measured 1.9–4.8x makes the constructive route
  (matmul share through the shipped stz_gpu plane) MORE actionable, not
  less — the workload it would serve exists and now has numeric parity
  coverage (`base/test/neural/bert_parity_narrated.ring`: a committed
  83 KB synthetic BERT + an independent numpy forward; tokenizer ids
  exact, embeddings within a measured 1.6e-7).
- **The constructive route the numbers DO support:** when the forward
  pass lands, its matmul-shaped ~85% can run through the ALREADY-SHIPPED
  stz_gpu plane (the lawful @import pattern gives stz_neural.dll its own
  device context; one GPU discipline, counted fallback, no second
  stack) — the measured 2.7–4.8x is exactly the win ggml-Vulkan was
  supposed to buy, without the SDK, without the second surface.

**Revisit triggers**, recorded so nobody relearns this: (a) a real
large-model generative workload arrives (weights ≫ CPU cache; decode
becomes bandwidth-bound at GB scale, where the 3050's 168 GB/s vs
~40 GB/s CPU is a genuine 4x ceiling), or (b) upstream ggml ships
prebuilt SPIR-V artifacts that make the SDK unnecessary for building
AND updating.

---

## POST-G6: THE CONSTRUCTIVE ROUTE, BUILT — AND MEASURED HONEST (2026-08-07)

The G6 correction said the forward pass exists and its matmul share could
route through the shipped plane. Built: `engine/src/neural_gpu.zig` in
stz_neural.dll (own device — the per-DLL law), fed by ggml's OWN
extra-compute hook (vendored traits.cpp patch, NOTICE'd; stz_matrix links
a return-0 stub). Weights dequantize (F32/F16/Q8_0) + transpose ONCE and
stay resident keyed by (data ptr, model generation); activations stream
through two reused buffers; the verdict is shape-deterministic so ggml's
worker threads agree (thread 0 computes, the per-node barrier holds the
rest); a mid-node device death is kept-promise'd by a scalar fallback and
latches the state to CPU-forever. Guard:
`base/test/neural/neural_gpu_routing_narrated.ring` (17 asserts): the
tiny parity fixture never even WAKES the device; on a real MiniLM the
hook claims 36 nodes above an explicit line and zero below it; the two
routes agree at cos 0.99992 (NOT bit-parity — Q8_0 CPU kernels quantize
activations, the GPU computes full f32, different rounding by design);
the routed path is deterministic.

**And the end-to-end verdict is a LOSS at MiniLM scale: 0.45–0.67x.**
The census's 2.7–4.8x was measured on RESIDENT chains; per-NODE
interception pays an activation upload, a staged readback and a sync on
every matmul while ggml's CPU ops interleave — a graph that hops
CPU↔GPU per node is not a resident chain. G0's transfer law, resurfacing
at graph level, caught by the guard's own timing. So the SHIPPED default
threshold is set where a node can actually pay (~1.5 GFLOP of work —
bert-large at long sequences), MiniLM-class forwards stay entirely on
CPU BY MEASUREMENT, and the guard asserts exactly that as the shipped
behavior. The real small-model win is the RESIDENT BACKBONE — every op
on-device, one upload, one readback — recorded here as the follow-up
that earns the 2.7–4.8x, when a workload justifies building LN/GELU/
attention kernels on the plane.

## THE RESIDENT BACKBONE — criteria written 2026-08-07, BEFORE measuring

The per-node route's follow-up: run the WHOLE encoder on-device (embeddings
gathered, every LN / matmul / softmax / GELU / residual a dispatch, mean-pool
on-device) so a forward pays ONE upload and ONE readback — the shape the
census's 2.7–4.8x was actually measured on.

Cost is real: LayerNorm, row-softmax attention, GELU, bias-add and pooling
kernels, plus a chain executor. So the gate is decided first, by spike:

- **R1 — the floor must clear a REAL bar.** The matmul spine alone (6
  layers of MiniLM's matmuls, resident, ONE sync) must beat the CPU's FULL
  forward (36.6 ms measured) by **≥2x**. The backbone can only be SLOWER
  than its own spine — the other kernels add dispatches. Below 2x there is
  no headroom for them, and the answer is NO-GO.
- **R2 — the plane's contract holds.** New kernels must fit the shipped
  binding contract (tile@0, params@1, ≤8 buffers, 64-byte params). Needing
  lifecycle surgery makes this a different phase, not this one.
- **R3 — parity ≥ 0.999 cosine** vs the CPU forward, the same standard the
  per-node route met.
- **R4 — counted degradation** to the per-node route / CPU on any refusal.

### R1 SPIKE RESULT (2026-08-07) — FAILED, then PASSED once the real
### prerequisite was built. GREEN LIGHT, with the design settled.

`base/test/gpu/backbone_spine_spike.ring` times MiniLM's 6-layer matmul
spine resident, one sync — the backbone's FLOOR (its other kernels can
only add).

| | spine, warm-min | vs CPU full forward (36.6 ms) |
|---|---|---|
| one submit per op (as shipped) | 23.7 ms | 1.55x — **R1 FAILS** |
| batched into one pass | **17.2 ms** | **2.12x — R1 PASSES** |

The diagnostic that turned it: the spine's 180 dispatches split 36 big
projection/FFN matmuls (12.3 ms — real compute) against 144 tiny per-head
attention matmuls (**11.3 ms unbatched for a sliver of the FLOPs**). That
is submission cost, not work — G0's own 60 µs-per-submit vs 9 µs-in-pass
number, at graph scale. Judging the backbone by that would have repeated
the census-vs-bridge error: an implementation artifact mistaken for a
design verdict. So the prerequisite got built (below), and the same spine
re-measured at 17.2 ms — attention's share collapsing 11.3 → 4.7 ms.
Ceiling if attention were free: 2.9x.

**BUILT NOW — batched passes in the lifecycle layer** (`stz_gpu_batch_begin`
/ `_end` / `_active`; guard `gpu_batch_narrated.ring`, 13 asserts). One
pass, one submit, bind groups held until it lands. The correctness catch
that shaped it: tile/params uniforms are written with queue.writeBuffer,
which orders against SUBMITS, not against dispatches inside a pass — a
batch sharing one params buffer would hand EVERY dispatch the last value
written, silently. Each batched dispatch therefore takes its own uniform
slot from a pool, and the guard proves it by running 8 ops with 8
DIFFERENT alphas and asserting element-by-element equality with the
unbatched run (plus the collapse-onto-the-last-alpha failure named as its
negative sibling). A multi-tile dispatch can't share one slot, so it
falls through to the immediate path — correct, just not amortized.
This is independently valuable: every G4 `ApplyQ` chain gets it (60 small
matmuls measured 2.35x faster batched).

**Remaining backbone design, settled by the spike** (the build, next
increment): keep Q/K/V whole and write ONE FUSED multi-head attention
kernel — a workgroup per (head, query row) doing scores → softmax →
context — which removes the per-head slicing that would otherwise have
demanded buffer offsets in the op API (R2's "different phase" trap).
Plus LayerNorm, bias-add, GELU, and a fused mean-pool + L2 kernel; the
embedding gather stays a CPU-side gather + one upload. R3 (≥0.999
cosine) and R4 (counted degradation) then guard it exactly as the
per-node route was guarded.

### BUILT AND SHIPPED (2026-08-07): the backbone runs, at 1.5x

`engine/src/neural_backbone.zig` — the five kernels above and an
executor; guard `base/test/neural/neural_backbone_narrated.ring`
(14 asserts). The design held: keeping Q/K/V whole meant no buffer
offsets were ever needed.

**Correctness judged against GROUND TRUTH, not the sibling path.** The
tiny synthetic BERT's numpy reference is the judge, so a bug shared by
both engine paths would still fail here: **cosine 0.999999986**, worst
element 8.3e-5. On MiniLM, cosine 0.99992 vs the CPU forward (R3 met).
Out-of-scope architectures are REFUSED, not mishandled — jina-bert-v2
(ALiBi + GEGLU) is detected and declined, and the caller keeps its CPU
path (R4, asserted both ways).

**It IS a resident chain, and the counter proves it**: a 9-token
forward moves 1152 bytes up + 128 bytes down, with ONE batched submit
for the whole encoder. No per-layer round trips — the thing the
per-node router could never be.

**Speed: 1.50–1.58x** on MiniLM (24.1–24.8 ms vs 36–39 ms CPU) over
three runs. The spine spike predicted 2.12x; the delivered number is
lower because that spike measured MATMULS ONLY, while the real encoder
adds LayerNorms, GELU, attention and pooling — dispatches the floor
never counted. R1 was a floor on cost, not a promise of speed, and
saying so is the difference between a measurement and a sales figure.
Its purpose still held: it said there was headroom, and there was.

**The bug worth remembering** (it cost this phase's debugging):
`layout: "auto"` builds a bind-group layout ONLY from bindings the
shader statically READS. The pool kernel DECLARED the tile uniform at
@binding(0) and never referenced it, so its layout had no binding 0 —
every bind group built for it was invalid, and the failure surfaced far
away as `wgpuQueueSubmit: BindGroup is invalid`, naming no kernel. **A
kernel must READ the tile uniform, not merely declare it.** Found by
binary-searching the dispatch chain (the five kernels all COMPILED
fine, which is what made it confusing); fixed with a real reference
plus the rule written into that kernel's own comment.

### WIRED IN (2026-08-07): the seam is silent, and the gate is measured

`neural_embed_routed` is now THE embedding entry point — every call in
the library (EmbeddingOf, the semantic index, stzText) comes through it,
and the ENGINE picks the route. Guard:
`base/test/neural/neural_embed_seam_narrated.ring` (16 asserts).

**The gate is a measured crossover in TOKENS**, not a flag — because at
this scale the GPU genuinely loses on short input:

| tokens | 11 | 20 | 29 | 47 | 74 | 119 | 182 | 254 |
|---|---|---|---|---|---|---|---|---|
| routed vs CPU | 0.76x | 1.02x | 1.34x | 1.59x | 1.67x | 1.57x | **1.94x** |

Break-even sits near 20 tokens; the shipped default is **32** — past it
with a real margin, never at it. Below the line the CPU keeps the work,
and the guard asserts that side by the route counters, not by vibe.

Measured at the face: 98 tokens, 24.3 ms CPU → 16.8 ms routed (1.45x),
with cosine 0.99990 between the two routes — callers cannot tell which
one served them, which is the definition of a silent seam.

**One correctness obligation the wiring created and pays**: the backbone
produces ONLY the pooled vector, so the routed path INVALIDATES the
per-token hidden states (`neural_token_dim()` reads 0 afterwards).
Leaving them populated would let a later token-level read return the
PREVIOUS text's states — a silent wrong answer no caller could see
coming. Zero is the honest answer, and the guard asserts it.

**And a guard had to learn to isolate its subject**: with two GPU paths
now live, `neural_gpu_routing_narrated` (the per-node router) saw ZERO
claimed nodes, because the backbone took the work before ggml ever built
a graph. It now pushes the backbone's gate out of reach for its own
scenes — a guard must exercise the path it is about.

Remaining, unforced: batch the embedding gather, and widen scope to
GEGLU/ALiBi if a workload asks for it.

One day, one plan of record, every phase gated by measurement: the
go/no-go spike (GO, with elementwise killed honestly), the lifecycle
DLL, the op library with exact witnesses, the 17.9x silent seam, the
declarative surface with the engine-resident transpiler, the browser-
proven edge convergence with measured calibration and the deployment
admission gate, and a NO-GO where the numbers and the invariants said
no. 162 guard asserts stand behind it. The f64 solver tier never moved
off the CPU — by decision, start to finish.

---

## GK — THE KERNEL FOUNDRY. What Proteus teaches this plane, and what it does not (2026-09-09)

Source studied: Databricks, *Achieving Extreme Efficiency through
Specialized GPU Kernel Generation* (Li, Khudia, Jin, 2026-09-04) — the
Proteus harness: agents propose kernels, a controlled checker verifies
them against a reference, only verified candidates are timed, winners
seed the next round; kernels specialized per runtime SHAPE reached
1.8–5.2x over vLLM's best on Qwen 3.5 122B / B200.

Read against what this plane already is (G0–G6 + the resident backbone,
~460 guard asserts), the paper's four findings sort into three bins:
**things this plane already does and the paper independently confirms**,
**one thing the paper shows this plane has NOT done**, and **one thing the
paper does that this plane should refuse.** The ids below use two
capitals (GK) so the plan checker can see them — it cannot see G0–G6,
whose one-capital ids fall outside the item grammar (`CONCLUSIONS.md`
2026-09-08 03:05, found on the GUI plan; TRUE OF THIS PLAN TOO, and left
for its own item).

### GK.1 — the four findings, mapped

**Finding 1 — "the checker, not the prompt, is where the design time
goes."** Proteus's list of measurement bugs is this plane's own paid
history under other names:

| Proteus found | this plane's name for it | where it was paid |
|---|---|---|
| a candidate reused compiled code left from an earlier attempt and looked cheaper | the WARM/COLD split — the compile cache is a feature (7–13 ms/pipeline) and a confound | G0's "clock inversion": warm-min AND sustained, never mixed |
| the two sides were not doing the same work (graph replay vs per-launch) | "a control that moves means confounded" | the house rule since G0; the backbone R1 spike |
| strong on the visible sizes, weak on the unseen | a pin on an OUTCOME, not a promise | the stale gg_image_primitive pin; the dyadic /256 fixture that measured ZERO error |
| impossible speedups (>100x) flagged against physical limits | — **ABSENT** — | nothing here refuses a number that beats the bus |
| time the winners AGAIN before seeding the next round | "5 runs minimum; a re-run is the most expensive wait" | PX law |

So the culture is confirmed rather than imported. What is NOT here is
the fourth row, and it is cheap: G0 measured this machine's ceilings
(matmul ≈293 GFLOP/s on the 3050, readback 5–6 GB/s, upload ≈7.6 GB/s,
submit floor 55–70 µs). A candidate whose measured time implies MORE
than that is a measurement defect by construction, and the checker
should say so by name instead of recording it as a win.

**Finding 2 — "the agent must not time its own work."** Proteus keeps
timing and correctness in the loop, outside the proposer, because a
proposer that measures itself optimizes the measurement. This plane's
current arrangement: the seam's calibration ladder times in RING
(`stzGpu.CalibrateWith`, wall clock via `StzEngineWatchTimestampNs`),
and the store it writes is consumed by the engine's `should_dispatch`.
That is the proposer's side of the line holding the stopwatch. The
engine-is-the-product law says the same thing Proteus does from the
other direction: **verification and timing belong in `stz_gpu.dll` as
one primitive, and the Ring face only READS its verdict.** One timer is
also one fewer than the paper uses to cross-check; wgpu exposes
timestamp query sets where the adapter supports them, which gives a
second, GPU-side clock for the same dispatch — two clocks that disagree
are the tell that the wall clock caught something other than the kernel.

**Finding 3 — "specialize to the shape; a generic kernel for every
shape is suboptimal."** Here the paper reaches something this plane has
NOT done, and the code says so plainly:

- every op in `gpu_ops.zig` is ONE kernel: matmul is a fixed 16x16 tile
  (`TILE = 16`), every elementwise kernel is `@workgroup_size(256)`, the
  transpiler hard-codes 256; no variant exists for any op;
- the calibration store is `op name → one threshold` (a wyhash of the
  name → `f64`), so `should_dispatch("pairdist", n)` knows the problem's
  SIZE and nothing about its SHAPE — `n·d` = 64k routes the same whether
  it is 64k×1 or 256×256;
- the backbone's gate is one dimension (32 tokens) over a shape that is
  really (n_tok dynamic × n_embd static × n_head static) — the paper's
  exact "static model parameter × dynamic request factor" case.

The paper's Batch-1 vs Batch-4 result is the argument: the same
operation wanted DIFFERENT kernels at two shapes, and the win at one
shape was "not a universal replacement." This plane's law is already
"gated by MEASURED thresholds"; the paper says the threshold has one
dimension too few. The honest caveat is scale: Proteus searched
thousands of Triton/CUDA variants per shape on a B200 fleet where 1.6x
on one kernel is paid for by the fleet's power bill. Here the op set is
nine kernels and the knob set is tile edge, workgroup width and
vectorized loads. Whether specialization PAYS at this scale is exactly
the kind of claim this plane does not believe until measured, and GK2
below is that measurement with its kill line written first.

**Finding 4 — "the knowledge layer must be tiny, situation → action,
and scoped; anything else becomes the cost."** Proteus's Figure 2/3 —
most tokens spent fetching and routing memory, none of it making the
next kernel better — is the strongest external confirmation this plane
has received for a decision it made without knowing it: **the
calibration file IS a knowledge layer, and it stores exactly one
sentence per situation** ("on adapter X, op Y, from n=64k, dispatch").
No prose, no lesson, no advice. The paper's rule — *"if a takeaway
cannot name the situation and the action, it is not worth putting in
the prompt"* — is the store's format already. Two refinements follow:
the situation key gains the shape (finding 3), and the store keeps the
LADDER that produced the threshold, not just the threshold. A stored
number with no trace is a pin on an outcome; the paper's Figure 4 says
the trace — rejected, correct-but-slower, winner-attached-to-shape — is
the artefact, and this house learned the same thing from a green guard
that was pinning an encoder's old answer.

### GK.2 — what this plane REFUSES from the paper, and why

**No LLM kernel proposer is built.** Proteus's own conclusion is that
"generation is the cheap step." The search space here is small enough
to ENUMERATE — nine ops × a handful of knobs × a shape-class ladder —
so the proposer is a for-loop in Zig, which is Rung 1 of the Model
Foundry (no neurons) applied to kernels. That is not a lesser version of
Proteus; it is the same architecture with the proposer replaced by the
cheapest thing that fills the role. An agent proposer becomes worth
building only when a workload asks for a kernel the enumeration cannot
reach (a fused kernel, a new op) — G6's law, applied to our own
ambition. When that day comes, the checker built in GK0 is UNCHANGED:
the proposer's side of the line is the only side that changes, which is
the paper's closing argument ("give the agent autonomy over how a
kernel is written; keep the loop as the channel for memory and
evaluation").

And when it comes, the governance already exists: a proposed kernel is
work REHEARSED in a workbench, the checker is the COMMITTING ACTOR (the
safe-world binding, unchanged), a store entry is COMPENSABLE (revert to
the previous variant — the reversibility contract), and a proposer that
scores its own candidates is refused at REGISTRATION, not caught at
commit (the registration gate). None of that is designed here; it is
simply not designed against.

**No CUDA/Triton.** WGSL through wgpu is the single GPU surface (the
counted-fallback discipline, G0's decision); the paper's Triton backend
is not a vendor question this plane reopens.

### GK.3 — the phases, kill criteria written before code

**GK0 — the checker as an engine primitive.** `stz_gpu_verify(ref,
cand, shape, band)` in `stz_gpu.dll`: runs reference and candidate
kernels on the SAME device buffers with the SAME inputs, equalizes cache
state (both warm, or both cold — never one each), compares within a
band, times both with the wall clock AND the wgpu timestamp query set
where the adapter has it, warm-min over N reps, and REFUSES by name any
result faster than the measured roofline (G0's numbers, per adapter,
re-measured at Init rather than quoted). GUARDS, the negative siblings
first: a candidate that skips the rows the visible fixture does not read
is CAUGHT by the hidden-shape check; a candidate that writes the right
answer but reports an impossible time is REFUSED by the roofline; two
identical kernels verify equal and time within the measured jitter band
(the control that must not move). Ring's Calibrate() becomes a READER
of this primitive. KILL: if the timestamp-query feature is absent on
both adapters here, the checker ships with ONE clock and says so — not a
kill, a recorded limit.

**GK1 — the shape-keyed store.** Calibration key becomes
`(adapter, op, shape-class)` where a shape class is the bucketed
(rows, cols, inner) — powers-of-two buckets, so the class count stays
small and the store stays a table, not a database. The LADDER persists
beside the threshold. `should_dispatch` takes the shape. The seam
(stzVectorIndex) and the backbone gate (`g_min_tokens`) consult the
shaped key. Verification at OFF-LADDER shapes is the hidden set — a
threshold is trusted only if a shape it was not calibrated on agrees
with it. KILL: if shaped thresholds differ from the flat one by <20% on
every class measured on both adapters, the shape dimension is NOT
worth its complexity here, and the store stays flat — recorded.

**GK2 — op variants, by enumeration.** Not started. For matmul and pairdist (the
two tiled ops): tile edge {8, 16, 32} × workgroup width {64, 128, 256}
× vectorized loads {off, vec4}. For the elementwise family: workgroup
{64, 128, 256}. A Zig for-loop proposes, GK0 verifies and times, GK1
records the winner per shape class. KILL, written now: **if no variant
beats the generic kernel the op library carries by ≥1.3x on ANY shape
class on BOTH adapters, the variant table is refused**, the paper's specialization
thesis is recorded as "does not pay at this op count on this hardware,"
and the generic kernels stay — with GK0 and GK1 kept, because a checker
and a shaped store are worth having even when they only ever confirm
the default.

**GK3 — the proposer seam (a DOOR, not built).** Not started. stzKernelMaker is
already the proposer's write surface — it refuses malformed kernels by
name before any device sees them (Proteus's "static checks" stage). GK3
is the CONTRACT that lets anything else stand on the proposer's side of
the line: a candidate is a spec + a shape class; the checker's verdict is
the only score; the store is the only memory. Built when a workload
asks for a kernel enumeration cannot reach. Not before.

### GK.4 — the sentence to carry

*Generation is the cheap step. The checker and the memory are the
product — and this plane had already built them, one dimension short.*

---

## GK0 STATUS — shipped 2026-09-09: the checker as an engine primitive

Guard: `base/test/gpu/gpu_verify_narrated.ring` — **26 asserts green,
2.6 s**, first run. Gate on the guards the change reaches (device
creation and the immediate dispatch path): lifecycle 62, ops 37,
declarative 20, batch 13, calibration 10, seams 17, render lifecycle
74, deploy gate 16, neural backbone 10 — **259 green**. Two Zig unit
tests on the pure judge and the comparator.

**What shipped.** `engine/src/gpu_verify.zig`, one primitive:
`stz_gpu_verify(ref, cand, shape A, shape B, reps, band)` runs both
kernels on the SAME device buffers at a visible shape and a HIDDEN one,
compares every output element, times both the same way (warm on both
sides — the correctness pass is the warm-up, alternating A B A B,
warm-min), on TWO clocks where the adapter has them (wall around
dispatch+sync; wgpu timestamp queries inside the pass, requested at
device creation and re-requested without if refused), and refuses by
name any time under floors it MEASURED on this device. The verdict and
every measurement are result slots; `stzGpu.Verify()` only reads them.
The Ring face owns the hidden set — an odd, tile-uneven size over the
reversed tail of each input (a permutation, so every value stays in the
kernel's domain) — and accepts a maker or raw WGSL as the candidate,
which is how a hand-written variant, or a cheat, gets checked.

**The negative siblings, all caught:** a candidate that answers the
visible fixture without reading its input (`out[i] = 2i` when
`a[i] = i`) is EXACT at the visible shape and wrong by 8190 at the
hidden one — `mismatch-hidden`, first element named. A constant offset
is `mismatch` by exactly 0.5 from element 1, and a mismatch is never
timed. The judge refuses 1 GB in 0.01 ms and any time under half the
smallest dispatch, and accepts the reference's own time. The control —
a kernel against itself — sits at speedup 1.01 inside a 0.23 ms jitter.

**Measured on the 3050, this run:**

| floor | value |
|---|---|
| copy bandwidth (16 MB, warm-min) | 89.0 GB/s |
| smallest dispatch + sync | 0.087 ms |
| 4096-element kernel, wall clock | 0.088 ms |
| the same kernel, GPU timestamps | **0.0057 ms** |

**THE FINDING, and it changes GK1/GK2:** below roughly 100 µs of
work, the wall clock measures the SUBMIT, not the kernel — the
4096-element dispatch reads as 88 µs on the wall and 5.7 µs on the
device, a 15x gap that is pure submission floor. Every speedup this
plane has ever reported for a small kernel was a ratio of two submit
floors. So: **GK2's variant comparisons must use the GPU clock** (the
kernel's own cost is what a tile size changes), while **GK1's routing
decision keeps the wall clock** (a caller pays the submit whether or
not the kernel is fast). Two clocks were not a refinement; at this
plane's sizes they measure different things. One clock stays a
recorded limit for adapters without timestamp queries.

**Paid for on the way:** the roofline needs an allowance — a working
set that fits in cache legitimately beats DRAM bandwidth, so the bus
floor carries 8x headroom and the submit floor a 0.5x one, both
written beside the numbers; a floor that refuses a legitimate result
is worse than one that lets a marginal one through. And `zig test` on a
single engine file needs only the wgpu include path — the DLL's
functions are resolved at runtime, so nothing links.

**Not this plane's, found by building in a fresh worktree:** `stz_http`
does not build from a clean checkout — `nghttp2ver.h` is gitignored
(generated from its `.in`) and nothing in `build.zig` generates it.
Recorded for the HTTP desk.

Next: **GK1**, the shape-keyed store — with the clock split above as
its first design input.

---

## GK1 STATUS — shipped 2026-09-09: the shape-keyed store, and what measuring it found

Guard: `base/test/gpu/gpu_calibration_shaped_narrated.ring` — **39
asserts green**. Gate on the guards the change reaches: calibration 10,
seams 17, verify 26, lifecycle 62, ops 37, declarative 20, batch 13,
deploy gate 16, render lifecycle 74, neural backbone 10 — **285 green**.
Zig unit tests on the class function and the route's precedence.

**What shipped.** The engine store gains a shape: `(op, n-class,
d-class) → measured cpu/gpu ratio`, classes being powers-of-two
ceilings, ratio 0 = unmeasured. One margin (1.3x) lives in the gate.
The route: a measured class decides by its ratio; an unmeasured class
falls back to the flat line on n·d; and G5's authority order — explicit
> persisted > seed — is carried to shapes with an `explicit` flag, so a
guard forcing a route through the flat knob keeps working after a file
has filled the classes. The seam (stzVectorIndex) consults the shaped
decision device-free before Init and again after. Persistence carries
three kinds of line — the flat crossover, `shape` rows per class, and
`ladder` rows with the cpu/gpu milliseconds that produced them (the
trace, finding 4). `stzGpu.CalibrateShaped()` walks a dimension ×
corpus grid through the real seam, sets the flat line to the most
conservative crossover (or "beyond the ladder"), **re-measures its
first cell at the end as a control and refuses to persist a grid whose
control moved**, and checks itself at two shapes the grid never held —
one inside a measured class, one outside — reporting each as decisive
or marginal.

**THE KILL LINE, applied honestly: the shape dimension does NOT pay for
pairdist on this hardware.** The grid, both adapters, device awake:

| n·d | ratio at d=64 | d=256 | d=1024 | adapter |
|---|---|---|---|---|
| 256k | 0.28 | 0.29 | — | iGPU |
| 1M | 0.72 | 0.60 | 0.88 | iGPU |
| 4M | — | 1.94 | 2.16 | iGPU |
| 256k | 2.08 | 2.29 | — | 3050 |
| 1M | 0.84 (outlier; 3.05 in a second run) | 4.27 | 4.86 | 3050 |
| 4M | — | 2.50 | 2.29 | 3050 |

At equal n·d the ratios agree across dimensions within the run-to-run
noise; the crossover is ~256k on the 3050 and ~4M on the iGPU for every
dimension the ladder reached. The 4x "spread" the first probe reported
on the iGPU was a slow-state artefact (below). **So the shaped classes
reproduce the flat line's decisions and add no routing information for
this op.** The store stays — built, guarded, and the place GK2's
per-class variants will live — but the plan records that its first
tenant did not need it. The flat number on disk was RIGHT for the 3050
awake (256k) and wrong for the iGPU (which wants 4M); per-adapter files
carry that.

**THE FINDING THAT COST THE DAY, and it applies to every GPU number
this plane has ever recorded on this machine: the RTX 3050 (laptop,
power-gated) enters a slow state after ~10 s idle, in which EVERY
submit pays a fixed ~2 ms and a 32 MB copy takes 9 ms instead of 0.4
(13 GB/s instead of 85).** Hundreds of tiny queries do not lift it;
~250 ms of sustained heavy work does. Ring building a large corpus
between cells is exactly a 10 s idle, so a calibration grid measured
half its cells in each state and the "flat rule wrong on 6 of 11"
verdict was a verdict on the state. Found by a control that moved (the
same cell at 0.55 and 3.97 ms in one process), isolated by elimination
— not VRAM (0 evictions), not harness memory (24M live Ring numbers
changed nothing), not an adapter switch (opened right after the iGPU,
0.68 ms), not 3 s of idle — and confirmed by 10 and 20 s of idle and by
the two clocks: in the slow state the GPU clock grew 2.5x and the wall
4x for the same kernel. **`stz_gpu_wake(cap_ms)` is the answer**:
adaptive copies until one runs at full speed, then settle, then stop —
an asleep 3050 costs ~250 ms, an awake one ~10 ms. Every rung wakes
before its GPU timing; GK0's floors wake before measuring (a floor
measured asleep reads 6.5x low, which would make the roofline refuse
honest results). The idle penalty itself is real for sporadic callers
and is NOT modelled by the routing margin: recorded as **GK1b — idle-
aware routing** (the engine knows the time since its last submit),
not built.

**Two more things paid for.** The rung forced the flat line and never
restored it, so the second hidden check read a line of 1 — and AGREED
BY COINCIDENCE in the first run (measured 1.63x) before disagreeing in
the second (1.09x). A hidden check near the line is marginal, and now
says so. And the rung leaked three device buffers per cell; it frees
them.

Next: **GK2**, op variants by enumeration — on the GPU clock, with the
device awake, per shape class; the kill line (no variant ≥1.3x over the
generic anywhere on both adapters) stands.

---

## GS — THE SILENT SEAMS SURVEY: where the GPU should work under the scene (2026-09-09)

The author's question: across the whole library, where should the GPU
mechanism run beneath an operation so that the caller notices nothing
but the speed? This section is the answer, library-wide, with every
candidate scored against laws this plane MEASURED rather than assumed,
and every refusal named so it is not re-proposed.

### GS.1 — the scoring laws (all measured, all already in this file)

A silent seam pays only when ALL of these hold:

1. **Residency exists or is cheap to build.** G0: a one-shot transfer is
   92% of the cost; G3: "residency is not an optimization of the seam,
   it IS the seam." A candidate that takes a bare slice per call must
   first hold its data in an engine handle across calls.
2. **f32 is tolerable, with the band written per site** (FACT 2, the
   compute model's class-2 rule). The f64 solver tier is out by
   decision, and stays out.
3. **Compute-dense, not streaming.** The memory wall killed standalone
   elementwise on BOTH accelerators (G0 and the multicore spike agree).
   Only chains and O(n²)-class work qualify.
4. **Work per call clears the awake floors** — 0.087 ms per submit, a
   seam query ~0.15–0.6 ms with its readback — and the caller's usage
   pattern is known: a sporadic caller on this laptop also pays the
   ~2 ms idle penalty GK1 measured (GK1b). Batch and offline work is
   the natural home; interactive per-call work must clear the floor by
   the margin every time.
5. **Correctness is stated:** bit-identical by construction (class 1),
   or a written band and a tie rule (class 2). "Deterministic by law"
   is a class-2 obligation the GPU must meet in writing.

And two GK laws for whoever builds one: **wake the device before any
timing** (GK1), and **compare kernels on the GPU clock, route on the
wall clock** (GK0).

### GS.2 — the seams worth building, in order

| id | where | what | residency | f32 | mode | evidence | owner |
|---|---|---|---|---|---|---|---|
| **GS1** | `sound.zig`/`fft.zig` offline render, `convolveReal` | FFT convolution of a sound with an impulse response | sound `Buf` handles exist | 1.75e-6 measured, inside audio's noise floor | batch | **SN0 kill criterion #3 PASSED and was SIGNED: 19.0–22.7x on the 3050, 12.9x iGPU, 60 s render 62 ms vs 1,400 ms. No GPU code exists in the sound engine.** Approved and unwired. Prerequisite recorded there: twiddles from an uploaded table on the iGPU (per-butterfly `cos/sin` reads −91 dB). | sound desk (the GPU plane provides `stz_gpu` FFT ops) |
| **GS2** | `soundanalysis.zig` `spectrogram` (feeds `onsets`, `tempo`) | thousands of independent Hann-windowed FFT rows | resident `buffer_id` | class 2: the guard pins 1-thread = 4-thread bit-identical; a GPU path needs a written band (the same 1e-6 class as GS1) | batch | already threaded ad hoc (`threads=4`, ungated); rows are embarrassingly parallel — one batched pass, one readback | sound desk |
| **GS3** | `graph_layout.zig` `force` ← `stzGraphCanvas._LayoutForce()` | Fruchterman-Reingold: O(n²) repulsion × 160 iterations | slice per call; positions are `f32` ALREADY | native f32 | interactive per picture | **the WGSL kernel exists and is guarded** (`graph_layout_determinism.ring`: index-order repulsion, no atomics, 10k nodes in 121–155 ms for 60 iterations, bit-identical across 4 processes); the shipped face runs the CPU loop. GG1's own kill line (10k nodes < 2 s) is met by the guard's kernel. | graph desk (GG's item) |
| **GS4** | `cluster.zig` `topKResident` on `cluster.Dataset` (stats bridge) | k-nearest scan on a RESIDENT n×d matrix — the same pairdist+top-k the stzVectorIndex seam already runs on the GPU | **handle exists** (the bridge says marshalling was 34 of 34.3 ms) | f64 in; the seam's measured 1e-7 band applies | interactive per query | the ideal shape (upload once, query many) with the kernel already shipped (G2 pairdist + G3 top-k); the only new work is the route inside the resident face, gated by the SAME calibration store as the index seam. Tie rule "smaller distance, then smaller index" must be reproduced on the GPU path — the index seam's guard proves the pattern. | GPU plane |
| **GS5** | `base/stats/stzDataSet.ring` `CorrelationWith`/`CovarianceWith` | a p-column correlation MATRIX computed as p² Ring-level crossings into `stats.zig` | none (per-column `StzStats` handles) | class 2 (tolerance-banded stats) | batch | **first a crossing defect, then a GPU shape**: the matrix form does not exist engine-side; once it does (one crossing), it is `XᵀX` on centered columns — a resident matmul at f32 for large n·p. The engine step pays on its own; the GPU step is gated by measurement. | numeric desk |
| **GS6** | `tsne.zig` (`conditionalP`, `klGradient`), `umap.zig` (`buildGraph`, `knnExact`), `density.zig` (dense targets and gradients) | O(n²) kernels per epoch, dozens to hundreds of epochs | bare slices per call; `ptsne`/`pumap` hold a net + P matrix across epochs = the ML tier's clearest resident chain | tolerance-based objectives (KL, correlation) | batch | the same shape as the resident BERT backbone: build residency once, run the epoch chain on-device, read positions back once. Needs a GK0-checked spike per kernel BEFORE any seam; memory wall bites first on the n×n allocations. | GPU plane, after GS4 |
| **GS7** | `cluster.zig` `kmeansRun` | assignment n·k·d + centroid update × iterations | points per run | "deterministic by law" ties (first-k-distinct start, comparison-order ties) ⇒ class 2 with a written index-order tie rule | batch | assignment is the pairdist kernel again; centroid update is a segmented reduction — the same batched-pass shape as the backbone's pool. | GPU plane, after GS6's spike |
| **GS8** | `sound.zig` `resampleSinc` | windowed-sinc polyphase, out_frames × channels × taps | resident `Buf` | f32 samples | batch (never the callback — FACT 5) | SN0 finding 4 named it the first thing worth a resident buffer; 1.17 ms per second of audio is ~20x the mix cost. Multicore first (the sound plan's own order), GPU only if the batch tier still asks. | sound desk |

**What "silent" requires of every one of them, from the seams that
already work:** the threshold consulted BEFORE the device (a small input
never pays Init's ~300 ms); a counted refusal and a CPU path that stays
the truth; the dispatch and transfer counters as the guard's witness
(the mechanism, not the vibe); per-adapter calibration through
`CalibrateShaped`'s control; and the GPU path's answer compared against
the CPU path on a fixture built to expose the tie rule.

### GS.3 — refused, with the law that refuses each

- **The f64 solver tier** — `matrix.zig` f64 paths, `linalg.zig` (LU,
  QR, Cholesky, SVD), `eigen_general.zig`, `poly.zig`, `optim.zig`:
  out by FACT 2 and by the compute model. Their speed path is the
  multicore tier, already shipped and gated.
- **`matFn` and the ~40 elementwise transcendental wrappers**: f64 AND
  standalone elementwise — fails two laws at once. Listed so it is not
  re-proposed; the resident-chain form is GS-numbuf below.
- **`stzNumBuffer` chains**: the residency keystone and exactly the
  ApplyQ chain shape G4 proved — but the buffer is the f64 numeric
  tier, its `sum` routes to the compensated-summation authority, and
  the tier's promises are bit-exactness. A GPU f32 shadow would break a
  promise the tier makes in writing. **Door, not seam**: an explicit
  `stzNumBuffer32` (an f32 buffer that declares its band) could own
  GPU chains without touching the f64 tier. Not built until asked.
- **`stats.zig` reductions** (compensated sum, centered SS, variance):
  the 1e16+1000×1.0 pathological case must come out EXACT; a GPU
  reduction cannot promise that. Multicore already gives 2–4x under a
  written justification.
- **PageRank / betweenness / closeness** (`graph.zig`): refused by the
  graph plane's own rule — only what a PICTURE needs gets a GPU path;
  a general graph-compute library is G6's error. Revisit only if a
  picture asks for a metric above the 20k-node ceiling.
- **`autodiff.zig` tape**: sequential by data dependence; a scalar tape
  has no width. Only a BATCHED evaluation over many inputs would — and
  nothing asks for one.
- **`apriori.zig`**: hash-map insertion order is part of the asserted
  answer — hostile to any parallel path.
- **`crypto_pbkdf2_sha256`**: serial by DESIGN; parallelising a key
  derivation function defeats it.
- **Plot renderers** (`plot.zig`): the cost is string emission, not
  arithmetic. **PNG encode**: deflate is a serial dependency; GR0
  already took the honest fix (level 1). Only per-row filter choice and
  CRC are parallel — not worth a kernel.
- **`list.zig` map/filter/reduce over boxed values**: heterogeneous
  `StzValue`s are not GPU data.
- **Hypothesis tests**: inputs too small to clear the submit floor.
- **`str_edit_cluster`** (all-pairs edit distance): a real O(m²·L²)
  shape, but an integer DP with data-dependent branching — a poor
  kernel. Named as a later possibility, not a candidate.

### GS.4 — the picture in one paragraph

Three seams are already paid for and idle: the sound plane's offline
convolution (measured 19–23x, signed, unwired), the graph plane's force
layout (kernel written and guarded, face on the CPU), and the resident
k-NN dataset (handle built, kernel shipped, route missing). They cost a
route each, not a plane. Behind them the ML tier's per-epoch O(n²)
kernels are the one genuinely new chain, and they earn a GK0-checked
spike before anything else. Everything numeric that promises exactness
stays on the CPU by the doctrine that made it trustworthy, and its speed
path remains the multicore tier. The silent seam's discipline does not
change with the op: threshold before device, counted refusal, CPU truth,
counters as witness, calibration with a control, and the device woken
before anyone believes a number.

### GS.5 — the items, as the plan tooling reads them

Each seam above is an item with an owner and a status. A table row is
not a definition to the plan checker; these lines are.

- **GS1** — offline FFT convolution in the sound engine over the signed SN0 verdict; twiddles from a table on the iGPU. Sound desk; the GPU plane provides the FFT op. Not started.
- **GS2** — spectrogram rows as one batched FFT pass with a written band. Sound desk. Not started.
- **GS3** — the force-layout face routed to the guarded WGSL kernel above a measured node count. Graph desk. Not started.
- **GS4** — the resident k-NN dataset routed through pairdist and top-k, gated by the shared calibration store, tie rule reproduced. GPU plane. Not started.
- **GS5** — correlation and covariance matrices engine-side in one crossing, then f32 transposed-product above a measured size. Numeric desk. Not started.
- **GS6** — the ML tier's per-epoch quadratic kernels as a resident chain, each kernel checked by GK0 before any seam. GPU plane. Not started.
- **GS7** — k-means assignment on the pairdist kernel with an index-order tie rule and a segmented centroid reduction. GPU plane. Not started.
- **GS8** — sinc resampling in batch mode, multicore first, GPU only if the batch tier still asks. Sound desk. Not started.

---

## GS4 STATUS — shipped 2026-09-09: the semantic index routes to the GPU under its own line

Guard: `base/test/neural/neural_semantic_gpu_seam_narrated.ring` — **33
asserts green**, its mechanism scenes running WITHOUT a model. Gate on
the eight guards the change reaches (semantic search 14, semantic
pipeline 9, embed seam 16, calibration shaped 40, calibration 10, seams
17, declarative 20, verify 26): **152 green**. Owned and NOT run: the
d6 cluster guard over the same face, because `stz_reactor.dll` does not
build from a clean checkout (the nghttp2 defect already filed).

**What shipped.** `stzSemanticIndex` routes its resident corpus through
the GPU pairdist + top-k kernels the vector index seam already runs: the
threshold consulted before any device exists (shaped class, then flat
line), per-adapter truth after Init, the canonical gate, the upload; a
refusal anywhere means the CPU resident dataset answers, and it stays
built as the truth. Two doors the face lacked and real callers need:
`AddEmbedded` (index a precomputed embedding) and `SearchByVectorXT`
(search with one); `SearchXT` embeds and delegates, so ONE path decides
the route. `stzGpu.CalibrateKnnResident()` measures the seam's line the
house way: both routes through the real face on synthetic unit vectors,
the query embedding excluded, warm-min, the device woken before every
GPU timing, the first rung re-measured last as the control, shaped
classes and the flat line persisted unless the control moved.

**THE FINDING: "already paid for" was true of the kernels and false of
the line.** The survey scored this seam on the vector index's measured
crossover (~256k on the 3050). Built, it lost at 800 × 384 by 3.4x. The
CPU alternative here is not the vector index's scan but the multicore
tier's SIMD top-k (`cluster.topK`, M4), several times faster — and a
threshold is a COMPARISON against a specific CPU path, so the key must
name the seam, not the GPU op. The seam's key is `knn_resident`, with no
seed: an uncalibrated key routes CPU by the engine's own rule.

**Measured on the RTX 3050 at 384 dims, device awake, through the
calibration (control: cpu ×1.59, gpu ×0.97 — not confounded):**

| corpus | n·d | CPU top-k | GPU seam | cpu/gpu |
|---|---|---|---|---|
| 1,000 | 384k | 0.124 ms | 0.331 ms | 0.37x |
| 4,000 | 1.5M | 0.643 ms | 0.634 ms | 1.01x |
| **16,000** | **6.1M** | **5.325 ms** | **2.573 ms** | **2.07x** |
| 32,000 | 12.3M | 6.523 ms | 6.347 ms | 1.03x |

One class wins. The store is shaped for exactly this: class (16k, 384)
carries its 2x, the flat line sits beyond the ladder, and a corpus of
any other measured size stays on the CPU. The window is narrow for a
measured reason: the pairdist kernel is a 16×16 tile written for m × n,
and a single query (m = 1) drives one of its sixteen rows — at 16,000 ×
384 the kernel reads 24 MB in ~2.5 ms where the bus allows ~0.3. **A
single-query pairdist variant is GK2's first target**, and it would
widen this seam's window and the vector index's alike.

**Paid for on the way.** `StzNeuralEmbeddingOf` stood after the class,
so Ring made it a METHOD, reachable only from inside the index though
its comment called it a free function — the guard found it; it stands
above the class now. The synthetic tiny BERT maps every text to one
vector, so a scene on it proves the tie rule and not the seam — hence
the bring-your-own-embedding doors carry the mechanism scenes. And the
score is now pinned as a cosine on BOTH routes against an independent
dot product, which no earlier guard did.

Next: **GK2**, beginning with the m = 1 pairdist variant.

---

## GK2 STATUS — shipped 2026-09-09: op variants by enumeration, and the kill line did not fire

Guard: `base/test/gpu/gpu_foundry_narrated.ring` — **27 asserts green**.
Gate on the eleven guards the change reaches (every pairdist dispatcher
and the calibration/verify family): **286 green**. Zig unit tests on the
variant table's classing and degradation, and on the foundry's margin.

**What shipped.** The op library carries three VARIANTS of pairdist
beside its generic 16×16 tile — `row` (one thread per corpus row, a
straight loop over d), `row4` (the same over vec4), `row4s` (row4 with
the query rows staged in workgroup memory) — and a test-only `broken`
one that only the foundry's mask can reach. A variant TABLE keyed by
`(op, m-class, n-class, d-class)` is consulted at dispatch, degrading
to the nearest eligible variant when the actual shape does not fit the
class's pick (d % 4, the shared-memory bound), and never holding the
test variant. `stz_gpu_foundry_pairdist` is Proteus's loop with a
for-loop as the proposer: each variant verified by GK0's checker
against the generic on the same device buffers at the visible shape
AND a hidden one (different size, different data), timed on the GPU
clock with the device woken, the winner recorded for the class only
if it clears 1.3x. The table persists as `variant` rows beside the
calibration. `stzGpu.FoundryPairdist(m, n, d)` and
`FoundryPairdistGrid` are the faces; `gpu.variant.count` is the
counter a guard watches. Scope: m ≤ 16, the single-query family the
seams dispatch — matmul and the elementwise workgroup widths are
**GK2b**, named and not built.

**The negative sibling that makes the table trustworthy:** the broken
variant, right in shape and wrong in answer, is REFUSED by the checker
and cannot win, whatever it timed. And the dispatch witness: with a
class pointing at a variant the counter moves and the distances equal
the generic's exactly on quarter-grid data; cleared, the counter stays
still.

**THE KILL LINE, applied on both adapters — it did not fire.** Single
query, GPU clock, ratio generic/winner:

| shape | RTX 3050 | Intel iGPU |
|---|---|---|
| 1 × 1024 × 128 | 2.67x row4s | 4.42x row4s |
| 1 × 1024 × 384 | 2.68x row4 | 4.93x row4s |
| 1 × 4096 × 128 | 5.54x row4 | 7.99x row4 |
| 1 × 4096 × 384 | 3.36x row4s | 7.70x row4 |
| 1 × 16000 × 384 | 1.88x row4 | 7.17x row4 |
| 1 × 32000 × 384 | 1.14x — generic kept | (not measured) |

**The payoff, where GS4 pointed.** With the table populated at 384
dims, the semantic index's own ladder (its CPU alternative unchanged):

| corpus | before GK2 | after GK2 |
|---|---|---|
| 1,000 | 0.37x | 0.65x |
| 4,000 | 1.01x | **1.90x** |
| 16,000 | 2.07x | **2.46x** |
| 32,000 | 1.03x | 0.94x (generic) |

The seam's window went from one class to two, and every number above
came from the same checker, the same clocks, and the same woken device
as GK0 and GK1.

**Two things the enumeration taught.** The winner is not one variant:
`row4s` takes small corpora where the staged query pays, `row4` takes
the large ones where the workgroup load is overhead — which is exactly
why the table is per class and not per op. And at 32,000 rows the
generic tile draws level again on the 3050, so the variant's advantage
is a property of the shape, not of the kernel — the reason the table
falls back to the generic rather than assuming the variant.

Next: **GK2b** (matmul tiles, elementwise workgroup widths) when a
workload asks; **GK3** stays a door.

---

## GS1 STATUS — engine half shipped 2026-09-09: FFT convolution is an op of the GPU plane; the sound desk owes one route

Guard: `base/test/gpu/gpu_convolve_narrated.ring` — **19 asserts green**,
on BOTH adapters. Gate on the guards that share the dispatch path
(batch, lifecycle, ops, verify, foundry, seams): **182 green**. Zig unit
test on the transform sizes.

**What shipped.** `engine/src/gpu_fft.zig`: `stz_gpu_op_convolve_real
(a, na, b, nb, out)` over G1 buffer ids — the linear convolution of two
real f32 signals as ONE batched pass: pack both operands to complex,
Stockham radix-2 forward chains (no bit-reversal traffic, ping-pong
buffers, one dispatch per stage), a pointwise product, the inverse
chain phase-shifted so the result lands in the same buffer for either
stage parity (the spike's lesson, kept), the scaled real part. Exactly
4 + 3·log2(N) dispatches and one submit; the caller's readback or Sync
establishes completion. Twiddles come from an UPLOADED TABLE computed
in f64 and cached per transform size (replaced on a size change, never
accumulated, forgotten with the device) — not from `cos`/`sin` per
butterfly. `stzGpu.ConvolveReal(aA, aB)` is the one-shot doorway;
`StzEngineGpuConvolveSize` tells a caller the transform size; a
test-facing `BufferFillLcg` stages millions of samples without a Ring
list.

**Measured, this run (SN0's numbers beside):**

| | this op | SN0's spike |
|---|---|---|
| max rel. error vs fft.zig f64, RTX 3050 | **2.2e-6** | 1.47e-6 (cos/sin per butterfly) |
| max rel. error vs fft.zig f64, Intel iGPU | **2.2e-6** | 2.75e-5 (cos/sin per butterfly) |
| 1 s vs 1 s IR, N = 131072, resident chain + sync | **1.6 ms** | 1.74 ms with transfer |
| 60 s vs 1 s IR, N = 4,194,304, chain + sync | **54 ms** | 62 ms with transfer; fft.zig 1,390–1,464 ms |

**The iGPU prerequisite SN0 named is discharged by construction**: with
the table, the iGPU's error equals the 3050's, 12x under its own
per-butterfly reading and inside a 16-bit noise floor by a wide margin.

**The honest number about the doorway.** Through Ring lists on both
sides, the GPU beats fft.zig by 1.1x at 1 s — because list marshalling
dominates BOTH routes (37 ms and 33 ms around a 1.6 ms chain). The
seam's value exists only for signals that are ALREADY on the device,
which is precisely the sound desk's situation: its buffers live in
`stz_sound.dll`, and the route it owes is a transfer from its resident
sample buffer to a G1 buffer WITHOUT a Ring list in between — an
engine-to-engine pointer transfer (`stz_gpu_buffer_write` already
takes a pointer; a bridge that accepts a Ring C-pointer + length from
the sound DLL's buffer is the one piece missing, and it is not built
here because nothing yet hands one over to test it against).
Recorded as **GS1b — the pointer transfer and the sound face's route**,
the sound desk's.

**Paid for on the way:** a guard that measures "one buffer more" after
an earlier scene had already built the thing it measures is asserting
a coincidence; the cache's law is "never grows", and that is what the
guard says now.

Next for this plane: nothing owed on GS1. GS3 is the graph desk's;
GS5–GS8 wait for their workloads.

---

## GS6 SPIKE RESULTS — measured 2026-09-10. VERDICT: GO, on both adapters, by a wide margin

Spike: `engine/src/gs6_spike.zig` (in `src/` because it drives the REAL
`gpu.zig` and `tsne.zig`, and Zig refuses `../` imports from `tools/`;
build line in its header). Measurement only; no product code.

**Kill criteria, written before the numbers:** GO only if at n = 4000
the GPU epoch beats `tsne.zig`'s f64 `klGradient` by ≥ 3x AND the
gradient agrees within 1e-4 of the f64 one relative to its peak.

**The chain measured** — the resident shape the survey asked for: P
uploaded ONCE as f32, y uploaded per epoch (n × 2 floats), three
dispatches in one batched pass (a per-row q-sum with a shared-memory
reduction, a one-workgroup total, a per-row gradient pass that reads
each P entry once and recomputes q from y), dy and the KL partials read
back per epoch. Device woken first. Clustered data (8 blobs in 16
dims), perplexity 30, exaggeration 12.

| n | CPU epoch (f64) | GPU epoch, RTX 3050 | ratio | GPU epoch, Intel iGPU | ratio | gradient err / peak | KL rel. |
|---|---|---|---|---|---|---|---|
| 1,000 | 5.15 ms | 0.415 ms | **12.4x** | — | — | 1.2e-7 | 2.4e-8 |
| 2,000 | 18.0 ms | 0.480 ms | **37.6x** | 2.76 ms | **6.6x** | 8.6e-8 | 3.8e-8 |
| 4,000 | 82.2 ms | 1.15 ms | **71.4x** | 4.29 ms | **19.7x** | 1.1e-7 | 2.7e-8 |

A 1,000-epoch fit at 4,000 points: **82 s on the CPU, 1.15 s on the
3050, 4.3 s on the iGPU.** The gradient agrees with f64 to 1e-7 of its
peak — three orders inside the criterion — because the f32 work is a
per-row sum of n terms of similar magnitude, not a long accumulation.

**Why the ratio GROWS with n**: the CPU pass is memory-bound over two
n × n f64 matrices (P and the q numerators, 256 MB at n = 4000); the
GPU chain never materialises q — it recomputes 1/(1+|yᵢ−yⱼ|²) from the
n × 2 positions in both passes, so its only n² traffic is one read of P
as f32. The memory wall that limits the CPU is the thing the chain
removes.

**The memory wall, measured beside:** P as f32 on the device is 4n²
bytes — 61 MB at n = 4000, 244 MB at 8,000, ~1 GB at 16,000, which is
the VRAM budget. The seam's honest range on this machine is n ≤ ~12,000
dense; beyond it the sparse-P path (UMAP's k-NN graph, GS6's other
half) is the shape, not a bigger buffer.

**What the seam will then be limited by:** the P build itself
(`jointP`, a per-row perplexity search of up to 50 entropy evaluations
over n) — 1.4 s at n = 4000 on the CPU, larger than the whole
1,000-epoch GPU fit. It is the same n² shape with a per-row binary
search and belongs in the same chain; the seam must move it too or the
fit stays CPU-bound at the start.

**So GS6 is a seam to build**, not a survey row: `stz_gpu_op_tsne_epoch`
over resident buffers (P once, y per epoch), the CPU `run` loop keeping
momentum, gains and the exaggeration schedule, `stzTSNE.Fit()` routing
silently by a calibrated n with the CPU path as the truth — and the P
build as its second kernel. Correctness class 2, with the band written
from this measurement (1e-6 on the gradient's peak, a hundred times the
observed error).

Next: **GS6a** — the epoch op and the seam; **GS6b** — the P build on
the device; then UMAP's sparse form.

---

## GS6a STATUS — shipped 2026-09-10: the t-SNE epoch on the GPU, a silent seam inside `tsne.run`

Guard: `base/test/number/numeric_tsne_gpu_narrated.ring` — **16 asserts
green**. Gate: `numeric_embedding_narrated` (the face's own guard, t-SNE
and UMAP) **240 green** and `numeric_summation` 16 — the stats DLL
loads and answers as before. Zig unit test on the gate's refusals.

**What shipped.** `engine/src/tsne_gpu.zig`, compiled into
`stz_stats.dll`, which now owns its own wgpu device (the per-DLL handle
law; the neural tier's precedent; `build.zig` gives it `needs_wgpu`
and the Ring loader hands over the runtime's path, as `stz_neural.ring`
does). `tsne.run` asks it once per fit (`prepare`: eligibility, the
device, P resident as f32, the buffers, one wake) and once per epoch
(`epoch`: the positions up, three dispatches in one batched pass, the
gradient and KL back); the optimiser — momentum, adaptive gains, the
exaggeration schedule, recentering, the density term — is untouched
and runs on the gradient the device returns. Any refusal at any epoch
drops to the CPU block for the rest of the fit and is COUNTED. The
gate is `n ≥ 500` (measured GO at 1,000; set by
`StzEngineTsneGpuSetMinN`); `dims ≠ 2` stays CPU without a refusal
(the kernels cover the picture, not the general case). `stzTSNE.Fit()`
did not change by a character.

**Measured, this run, 1,000 points × 150 epochs, four blobs in 8 dims:**

| | CPU fit | GPU fit |
|---|---|---|
| epochs served by the device | 0 | **150 of 150** |
| first-epoch KL (same P, same y₀) | 71.878826 | 71.878824 |
| final KL | 50.012 | 50.058 |
| 5-NN blob purity of the embedding | 1.00 | 1.00 |
| wall, P build included | 1,339 ms | **257 ms (5.2x)** |

The first epoch's KL agrees to 3e-8 relative — the same P, the same
initial positions, before f32 and f64 trajectories diverge — and after
150 epochs the two embeddings keep every blob together; a stochastic
method is compared on what it promises, not on bits.

**Where the fit's time now sits.** At 1,000 points the P build
(`jointP`, 100 ms) is ~40% of the GPU fit; at 4,000 it is 1.4 s
against a 1.15 s thousand-epoch chain. **GS6b — the P build on the
device** — is the next kernel, and it is the same shape (a per-row
perplexity search over n distances). The spike's chain is the epoch;
the fit will be bound by its start until GS6b lands.

**Paid for on the way:** an epoch counter that equals the iteration
count is the only witness that the seam served the WHOLE fit — a guard
on "it was faster" would have passed a route that served the first ten
epochs and fell back. And a `defer` on an optional session that the
loop may set to null releases exactly what is still held.

Next: **GS6b**, the P build on the device; then UMAP's sparse form.

---

## GS6b STATUS — shipped 2026-09-10: the P build on the device; the fit is now GPU from its first byte to its last epoch

Guard: `base/test/number/numeric_tsne_gpu_narrated.ring` — **22 asserts
green** (was 16). Gate: `numeric_embedding_narrated` **240 green**.

**What shipped.** Two kernels in `engine/src/tsne_gpu.zig` and one
function, `buildP`. The first kernel is one workgroup per row: the
row's squared distances (the point staged in workgroup memory, `d ≤
1024`), then the CPU's bandwidth search reproduced exactly — up to 50
tries, lo/hi bisection with doubling while unbounded, the same 1e-5
tolerance on the entropy, the row written at the LAST evaluated beta,
an underflowed row made uniform — with the search's control flow made
workgroup-uniform through `workgroupUniformLoad` so every lane takes
the same branch. The second symmetrises: each unordered pair belongs
to the row with the smaller index, so no element is written twice.
The matrix is left RESIDENT and `prepare()` adopts it instead of
re-uploading; it is also downloaded once as f64 because the CPU parts
of the fit and the fallback read it. `tsne.run` asks `buildP` first
and falls to `conditionalP` + symmetrisation exactly as before when
it refuses (counted). Eligibility is the epoch seam's: `n ≥ 500`,
`dims = 2`. `stzTSNE.Fit()` unchanged.

**Measured, this run, 1,000 points × 150 epochs, four blobs in 8 dims:**

| | GS6a (epochs only) | GS6b (P build too) |
|---|---|---|
| P built on the device | no | **yes, counted once** |
| epochs served | 150 of 150 | 150 of 150 |
| first-epoch KL vs CPU | 3e-8 | 1e-8 |
| 5-NN blob purity | 1.00 | 1.00 |
| whole fit vs CPU | 5.2x | **7.9x** (1,519 → 193 ms) |

The device's P against the CPU's, entry by entry at 300 points:
max |Δ| below 1e-6 on entries up to 2.1e-4, both sum to 1, zero
diagonal, symmetric. The build alone through Ring lists both ways at
1,000 points is 2.1x — the lists carry a million doubles each way; the
in-engine seam pays none of that, which is where the fit's 5.2x → 7.9x
comes from.

**Paid for on the way.** `target` is a reserved word in WGSL. The
driver reports it only through the uncaptured-error callback, whose
message the pipeline's own "shader module is invalid" then
overwrites — the stored last error names the symptom and never the
cause. The engine keeps the last error only; a probe that prints every
uncaptured error as it arrives is the way to read a shader's
rejection, and it took three rebuilds to learn that. Worth a
`stz_gpu_first_error` slot on a later pass.

Next, on the author's word: **UMAP's sparse form** (GS6's dense range
ends near 12k points); GK2b/GK3 remain named, not built.

---

## GS6c STATUS — shipped 2026-09-10: UMAP's sparse form, on the CPU and on the device

Guard: `base/test/number/numeric_umap_gpu_narrated.ring` — **23 asserts
green**. Gates: `numeric_embedding_narrated` **240 green**,
`numeric_tsne_gpu_narrated` 22, `numeric_summation` 16. Zig: `umap.zig`
78 tests (one new: the sparse union against the dense one, bit for bit),
`umap_gpu.zig` 7.

**Where a UMAP fit's time sat, and why "sparse form" was two things.**
Measured on the CPU before this work (d = 8, 200 epochs):

| n | graph build | 200 epochs |
|---|---|---|
| 4,000 | 175 ms | 837 ms |
| 8,192 | 1,642 ms | 400 ms* |
| 16,384 | 5,278 ms | 790 ms* |

*50 epochs, scaled. Above 8,192 the build WAS the fit, and half of it was
a **dense n×n f64 matrix the fuzzy union walked** — 2 GB at 16k points,
almost all of it zero — the memory wall GS6 named for t-SNE, standing in
UMAP too. So three things shipped:

1. **The fuzzy union is sparse** (`umap.zig`, `fuzzyUnionSparse`): the
   n×k table merged with its transpose as an in-edge list, every pair
   once, **bit-identical edges in the identical order** — the dense form
   is kept as `fuzzyUnionDense` for the test that holds them equal, and
   the whole CPU fit is unchanged to the bit. Build at 16k: 5.3 s → 2.1 s.
2. **The exact k-NN on the device** (`umap_gpu.knn`): one thread per row,
   the point staged in registers, a sorted k-array in registers with the
   CPU's tie rule. No n×n matrix is materialised, ever. Above the
   forest's 8,192 threshold this replaces an APPROXIMATE answer with an
   exact one, faster. At 1,000 points every one of 1,000 rows is
   identical to the CPU's exact scan, order included.
3. **The epoch chain on the device** (`umap_gpu.prepare/epochs`), in
   gather form: one thread per point sums its sampled edges' attraction
   and its negative samples' repulsion; the sampling schedule is
   stateless (edge e is sampled at epoch t when ⌊(t+1)/ε⌋ > ⌊t/ε⌋, which
   is what the CPU's running counter computes), the negatives come from a
   hash of (seed, epoch, edge, sample), so an epoch is one dispatch and a
   fit's 200 epochs are a few submits. **Deterministic under its seed**,
   like the CPU. The density term stays on the CPU and interleaves: on
   the epochs it is on, the positions come down, it applies, they go up.
   Any refusal restarts the fit on the CPU from its seed and is counted.
   Gates: epochs from 1,000 points, k-NN from 1,024; `dims ≤ 4`.

**Measured, this run, four blobs in 8 dims, 200 epochs:**

| n | CPU fit | device fit | | 5-NN purity CPU / device |
|---|---|---|---|---|
| 1,000 | 223 ms | 80 ms | 2.8x | 0.992 / 0.998 |
| 4,000 | 897 ms | 91 ms | **9.8x** | 0.993 / 0.985 |
| 8,192 | 2,465 ms | 172 ms | **14.3x** | |
| 16,384 | 5,320 ms | 323 ms | **16.5x** | |

At 16k the device fit is a third of a second where the CPU took ten
before the union went sparse — and its neighbour table is exact.

**The finding that cost an hour, and the experiment that settled it.**
The first device route scored 0.944 purity at 4k against the CPU's
0.993. Not f32, not the sampler: **a synchronous update**. On the CPU
each sampled edge moves its endpoints and the next edge sees the move;
in gather form every pull a point receives is computed from positions
that have not moved yet, so a well-connected point overshoots its
cluster and the layout rings. `src/gs6c_probe.zig` runs the CPU's own
loop three ways on the same graph and seed:

| n | sequential (shipped CPU) | synchronous | synchronous, attraction halved |
|---|---|---|---|
| 1,000 | 0.997 | 0.979 | 1.000 |
| 4,000 | 0.982 | 0.951 | 0.972 |

The synchronous column reproduces the device's gap exactly, which is
what names the cause. The kernel ships the third column: the attraction
halved per endpoint, so a pair closes by the transform path's one-sided
step. Device purity went 0.944 → 0.985 at 4k. The tool stays in `src/`
as the evidence (the GS6 spike's precedent).

**Also paid for.** A `func` placed mid-file in a Ring guard swallows
every line after it into its body, silently: the guard printed nothing
at all. And a centroid-separation ratio was the wrong witness for
blobs that are curves — UMAP unrolls them, so the centroids sit inside
each other's spread while every point's neighbours are still its own;
5-NN purity is the witness, as the t-SNE guard already knew.

**GS6 is closed**: t-SNE dense (epochs, P build) and UMAP sparse
(graph, k-NN, epochs), each a silent seam behind a measured gate, each
counted, each with the CPU as truth. Named, not built: a first-error
slot in gpu.zig; GK2b/GK3; GS7 (k-means on pairdist) is the GPU
plane's next item on the author's word.

---

## GS7 STATUS — shipped 2026-09-10: k-means assignment on the device, the CPU's bits kept

Guard: `base/test/learning/learning_kmeans_gpu_narrated.ring` — **21
asserts green**. Gates: `mlfloor_narrated` (the face's own) **36 green**;
Zig `cluster.zig` 27 tests, `kmeans_gpu.zig` 7.

**What the plan line asked, and what was found on the way.** "k-means
assignment on the pairdist kernel with an index-order tie rule and a
segmented centroid reduction." The first cut did exactly that — a fused
argmin per point, one workgroup per cluster for the means, eight
iterations per submit — and it was fast and **wrong on the law**: at
100k × 64 into 16 with the deterministic seed (the first 16 distinct
points, all in one blob) it sent whole blobs to a different seed than
the CPU did. Measured, the runner-up seed sat **1e-6 to 1e-4 relative**
from the winner — inside f32's rounding over 64 accumulated terms — and
the CPU itself did not move under a 1e-9 perturbation of the data. Not
a bug: a near-tie f64 resolves and f32 cannot. And k-means here is
**deterministic by law**: two runs on the same data agree. A device
that answered differently the moment a corpus crossed the gate, or a
machine had a GPU, would break that law on the answer itself.

**What shipped** (`engine/src/kmeans_gpu.zig`, on the stats DLL's
device):

- **The device assigns and certifies.** One thread per point, the
  points transposed on upload so a warp reads consecutive words, four
  centroids per pass through the row, the argmin fused (no n×k matrix
  is written). The kernel keeps the runner-up and **flags** every
  point whose two best centroids are within f32's error bound
  (`d · 2.4e-7 · (best + second)`), an exact tie included, into a
  compact list by an atomic counter.
- **The CPU decides and updates in f64.** Every flagged point is
  re-decided by `cluster.nearestCentroid` — the CPU's own strict `<`
  in index order — and the update runs through
  `cluster.updateCentroids`, the CPU loop's own code, refactored out so
  there is ONE definition. The device only ever sees f32 copies of f64
  centroids. Labels, iteration count and centroids are therefore the
  CPU's **bits**, which the guard asserts (max |Δ| = 0 on the
  centroids).
- The iteration is one submit and one readback; the CPU is in the
  loop, so iterations cannot batch, and the gate is on the WORK of one
  iteration: `n·k·d ≥ 64 M` (`StzEngineKMeansGpuSetMinWork`). Counters:
  iterations, fallbacks, runs, and **points resolved by the CPU** — a
  guard can read how much f32 could not certify. `stzKMeans.Run()`
  unchanged.

**Measured, this run, blobs in contiguous blocks (every seed in blob 0,
near-ties everywhere in the first iteration), per iteration by the
difference of a one-iteration call and the full call:**

| n × d into k | terms/iter | CPU ms/it | device ms/it | per iteration | whole call |
|---|---|---|---|---|---|
| 50,000 × 16 into 8 | 6.4 M | 2.5 | 1.3 | 2.0x | 1.1x |
| 200,000 × 16 into 8 | 25.6 M | 9.3 | 5.0 | 1.9x | 1.3x |
| 100,000 × 32 into 32 | 102 M | 18.5 | 4.5 | 4.1x | 1.8x |
| 50,000 × 128 into 32 | 205 M | 24.6 | 5.8 | 4.3x | 1.7x |
| 20,000 × 256 into 64 | 328 M | 48.9 | 8.0 | **6.1x** | **3.1x** |

Labels differed from the CPU's in **0** cases at every size. The whole
call carries a fixed cost the CPU does not — the transposed f32 upload,
and on this seed the first iteration's f64 resolution of most points
(20,550 of 20,000 × 14 iterations were resolved, nearly all in the
first) — which is why the gate sits at 64 M terms and the seam pays
from ~100 M: large k·d, the codebook shape. Through `stzKMeans.Run()`
the 5-million-append Ring flattening dilutes it to 1.3x; that
flattening is the face's tax, the GS survey's "batch" class, not this
seam's.

**Where the win is bounded.** The device removes the assignment, k·d
per point; the CPU keeps the update, d per point, in f64 for the bits.
So the per-iteration ceiling is about k, and small k stays near the
CPU whatever the device does. A route that moved the update too would
be faster and would not be this library's k-means.

**Paid for.** The first kernel's row reads were strided by d across
neighbouring threads (uncoalesced): at d = 128 the device was slower
than the CPU. Transposing on upload fixed it. And a Ring guard that
prints nothing at all has a `func` above its main code — the third
time this session; it is in the memory now.

GS7 closes the GPU plane's GS list that belongs to this desk (GS1 engine
half, GS4, GS6a/b/c, GS7); GS1b, GS2, GS3, GS5, GS8 belong to the sound,
graph and numeric desks. Named, not built: a first-error slot in
gpu.zig; GK2b; GK3.

---

## THE FLATTENING TAX — shipped 2026-09-10: the seams had become faster than their doorways

Gates: `numeric_embedding_narrated` **240 green**, `mlfloor_narrated` 36,
`numeric_knn_selection_narrated` 24, `learning_multilingual_stress` 37,
`learning_kmeans_gpu_narrated` 22, `numeric_umap_gpu_narrated` 23,
`numeric_tsne_gpu_narrated` 22; Zig `cluster.zig` 27.

**What was found.** After GS7 the k-means engine call at 20,000 × 256
into 64 took 195 ms and `stzKMeans.Run()` took 1,535 ms. The face spent
the difference appending 5,120,000 numbers one at a time into a flat
Ring list before the engine saw them, then crossing the bridge 20,000
more times to compute the inertia, one `StzEngineSimEuclidean` per
point. The GS survey had named this class ("batch": marshalling is the
cost) and GS7's own comment named it again; the fit had simply moved
enough that the doorway was now the fit.

**What shipped.**

- **The bridge walks rows.** `listToF64` in `ring_bridge_stats.zig`
  accepts a list of equal-length rows and flattens it engine-side, one
  pointer per row, a ragged row refused; flat lists behave exactly as
  before. Every stats entry that takes a matrix gets this for free.
- **The faces stop flattening.** `stzKMeans.Run()` passes its vectors
  as they are; `StzEmbeddingPrepare` (t-SNE and UMAP) returns the rows,
  and the two inverse-decoder paths pass the prepared rows instead of
  re-flattening them.
- **The copies go too.** Ring copies a list on every assignment —
  measured: one copy of 16,384 × 8 rows is 20–200 ms, of 20,000 × 256
  rows 700 ms — and there were three between `Fit()` and the engine
  call (the wrap, the unwrap, the member). `ref()` makes each free; a
  reference made inside a function survives its return, its wrap, and
  a member, verified before use.
- **The inertia comes back with the run** (`cluster.kmeansInertia`,
  the same distance squared and summed; slot 3 of the engine's answer),
  and `Clusters()` is one pass over the assignments instead of one per
  cluster (k scans of n were 1.28 M steps, 256 ms, at 20,000 into 64).

**Measured, the face against its own engine call:**

| | before | after | engine call |
|---|---|---|---|
| `stzKMeans.Run()` 20,000 × 256 into 64 | 1,535 ms | **339 ms** (4.5x) | 245 ms |
| `stzUMAP.Fit()` 16,384 × 8 | 363 ms | 319–363 ms | 229 ms |
| `stzTSNE.Fit()` 4,000 × 8 | 323 ms | 302–311 ms | 284 ms |

The UMAP and t-SNE faces were never far from their engine calls at
these shapes; their remaining gap is Ring's copy of the answer into
`Embedding()` and moves run to run. The k-means face's remaining
94 ms is the bridge's own row walk (69 ms for 5 M numbers) and the
answer's unpacking.

**What is left of the class, for whoever owns those faces.** The same
`_aFlat_ +` loop stands in `stzPCA` (3), `stzKnn` (2),
`stzVectorIndex` (2), `stzSemanticIndex` (1), `stzNeuralNetwork` (1),
and the stats plots; the bridge reader that cures it is the stats
DLL's, and each of those needs the same one-line change at its call
plus a look at what reads the flat copy afterwards.

---

## THE FIRST-ERROR SLOT — shipped 2026-09-10: a refused kernel names its cause, not its symptom

Guard: `base/test/gpu/gpu_errors_narrated.ring` — **14 asserts green**.
Gates: `gpu_verify_narrated` 26, `gpu_lifecycle_narrated` 62,
`learning_kmeans_gpu_narrated` 22, `mlfloor_narrated` 36; Zig `gpu.zig` 3.

**What was wrong.** A shader that fails validation raises two errors
in a row: the parser's — "name `target` is a reserved keyword",
with the line — and then the pipeline's — "ShaderModule with
'stz_kernel' label is invalid". `gpu.zig` kept one slot, so the second
overwrote the first: every refusal read as "invalid" and the cause was
gone. GS6b paid three rebuilds and a patched error callback to see one
parser line.

**What shipped.** Two slots in `gpu.zig`, sized for a naga message
(2 KB): `setLastError` fills the last as before and the FIRST only
while it is empty; `clearErrors()` empties both, and a kernel compile
clears both before it starts, so after a refusal the first slot is the
parser's line and after a good compile both are empty — a stale cause
never survives. Readers: `StzEngineGpuFirstError()` /
`StzEngineGpuErrorClear()` beside the existing `LastError`, and
`stzGpu.FirstError() / LastError() / ClearErrors()` on the face,
whose compile refusals now quote the first slot. The stats DLL has its
own device and therefore its own slots (its own `gpu.zig`):
`StzEngineStatsGpuFirstError()` / `LastError()` read those, which the
t-SNE, UMAP and k-means kernels write — `StzEngineGpuFirstError`
reads `stz_gpu.dll`'s and would say nothing about a stats kernel. The
guard holds the two devices apart.

**Paid for on the way, in the guard itself:** `oK` is Ring's `ok`
(case folded) — a syntax error on the line that declared it; and
`StzFind(needle, hay) > 0` raised on type in this guard, so it
searches the driver's ASCII with a byte search.

Named, not built, on the GPU plane: GK2b, GK3.

---

## GS6d STATUS — shipped 2026-09-10: the UMAP graph outlives the fit

Guard: `base/test/number/numeric_umap_resident_narrated.ring` — **18
asserts green**. Gates: `numeric_embedding_narrated` **240 green**,
`numeric_umap_gpu_narrated` 23, `learning_multilingual_stress` 37; Zig
`umap.zig` 78.

**The lesson taken from cuML** (Nolet et al., *Bringing UMAP Closer to
the Speed of Light with GPU Acceleration*, 2021): of 9.5 minutes at 3M
points, everything that was not the k-NN graph took 9.3 seconds, so
they let a caller keep the graph and tune the layout in seconds. Their
kernels were modest; their speed came from refusing to move or rebuild
what they already had. The flattening tax was the first half of that
sentence on this plane; this is the second.

**What shipped.**
- `umap.zig`: `runSupervised` is now `buildGraph` + `runOnGraph`, and
  `runOnGraph` takes ANY graph — the one a plain fit builds and throws
  away, or one a `ResidentGraph` keeps (the data copied in, the graph
  built once, `residentCreate / runResident / residentFree`). The
  curve (a, b) is fitted from THIS run's min_dist and spread, never
  read from the graph, so one graph serves every setting of them; the
  plain path computes the same values it always did, unchanged to the
  bit (the fresh-object scene holds a plain fit against a resident one
  bit for bit). `g_graph_builds` counts every build, the witness that a
  refit built none.
- The bridge: `StzEngineUmapGraphBuild(rows, n, d, k, labels, w)` → a
  handle; `StzEngineUmapRunOnGraph(h, dims, minDist, spread, epochs,
  seed, λ, frac)` → the same answer as `StzEngineUmap`;
  `GraphFree / GraphInfo / GraphBuilds`.
- The face: `stzUMAP` keeps the handle from its first `Fit()`; every
  later `Fit()` is the layout. The six setters that reshape the graph
  — neighbours, PCA width (both forms), labels (learn and ignore), the
  target weight — drop it; `ReleaseGraph()` drops it by hand;
  `HasGraph()` and `GraphInfo()` say what is held. The device seams
  (GS6c) ride unchanged inside `runOnGraph`.

**Measured, four blobs in 8 dims, 200 epochs, device route on:**

| 16,384 points | first `Fit()` (graph + layout) | refit with a new min_dist | |
|---|---|---|---|
| wall | 412 ms | **112 ms** | 3.7x |

The refit is the epoch chain plus the answer's crossing. And a refit
with the first settings answers the first embedding bit for bit; the
density term composes (its target is built from the resident graph, no
rebuild); the seed alone never rebuilds.

**Not taken from the paper, and why:** per-edge atomics for the
layout (WGSL has no f32 atomicAdd, and their reproducible mode is our
gather form already); spectral initialisation (a quality item the CPU
lacks too); a fit straight from another DLL's resident dataset (the
per-DLL device law forbids the pointer; the doorway would be GS1b's
pointer transfer, the sound desk's route). Next on the paper's list
for this plane: the k-NN kernel through GK2's foundry under GK0's
checker (it is the ceiling at scale — 98% of their 3M-point run), and
trustworthiness as the guard's witness, computed with that kernel.
