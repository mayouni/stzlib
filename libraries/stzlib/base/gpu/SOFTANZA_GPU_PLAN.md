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
