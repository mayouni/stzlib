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
    b1 = oG.UploadQ(aBig)
    b2 = b1.ApplyQ(k1).ApplyQ(k2).ApplyQ(k3)       # no readback between
    # (corrected 2026-10-28: this sketch predates G4 and named an Apply that
    # never shipped; the chain lives on the buffer and takes the Q, and
    # ApplyOnQ on stzGpu serves a kernel of several inputs. Run under rnxc:
    # [ 1, 2, 3, 4 ] through x*2, x+1, x*x gives [ 9, 25, 49, 81 ])
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
tuning has headroom, the decision doesn't depend on it. *(GK3,
2026-10-24: the peak was then a guess. Measured, the card's burst peak
is 7.45 TFLOP/s and 294 GFLOP/s is 3.9% of it; the plan's fractions
read against the measured number from GK3 on.)*

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
calibration (control: cpu ×1.59, gpu ×0.97 — not confounded)** -- the two
right-hand columns are GK3's, 2026-10-24: the seam's time is a whole
seam (upload of the query, the distance kernel, the top-k, the
readback), so against the 7.45 TFLOP/s and 77 GB/s this card measures
it reaches a tenth of a percent of the ALU and 5-13% of the bandwidth;
a single-query pairwise distance is a bandwidth-and-submit kernel and
the plan should never have let a "2x the CPU" stand for it alone:

| corpus | n·d | CPU top-k | GPU seam | cpu/gpu | GPU seam, of peak | GPU seam, of bandwidth |
|---|---|---|---|---|---|---|
| 1,000 | 384k | 0.124 ms | 0.331 ms | 0.37x  3.5 GFLOP/s, 0.05% | 4.6 GB/s, 6% |
| 4,000 | 1.5M | 0.643 ms | 0.634 ms | 1.01x  7.3 GFLOP/s, 0.10% | 9.7 GB/s, 13% |
| **16,000** | **6.1M** | **5.325 ms** | **2.573 ms** | **2.07x**  7.2 GFLOP/s, 0.10% | 9.6 GB/s, 12% |
| 32,000 | 12.3M | 6.523 ms | 6.347 ms | 1.03x  5.8 GFLOP/s, 0.08% | 7.7 GB/s, 10% |

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

---

## GS6e STATUS — shipped 2026-09-10: the UMAP k-NN kernel through the foundry, under the checker

Guard: `base/test/gpu/gpu_umap_knn_foundry_narrated.ring` — **21 asserts
green**. Gates: `numeric_umap_gpu_narrated` 23, `numeric_umap_resident`
18, `numeric_embedding` 240, `gpu_foundry_narrated` 27; Zig
`umap_gpu.zig` 8.

**Why this kernel.** cuML's paper puts the k-NN at 98% of a 3M-point
UMAP run: it is the ceiling at scale, and ours was the naive scan. So
it went through GK2's foundry exactly as pairdist did — a for-loop
proposes, GK0's checker decides — but on the stats DLL's own device,
where the kernel lives.

**What shipped.** Four kernels answer one contract (one thread per
row, the k nearest by squared distance, ties to the lower index, ONE
f32 output buffer `[d2 | index as f32]`): **generic** (every thread
walks every row from global memory, its own point in registers),
**tile** (a workgroup stages candidate rows in workgroup memory with
coalesced loads), **tile4** (tile with four candidates in flight),
**chunk** (32 candidates × 64 dimensions per tile, distances
accumulated across dimension chunks — any d ≤ 1024, the only variant
that can stage a wide row). The insertion is one shared function so
the tie rule cannot drift. A **broken** sibling (tile with one index
off) exists for the checker to refuse and the table to reject. The
single output buffer is what lets the checker judge a whole answer in
one band: an index that differs by one differs by 1.0.

`stz_umap_knn_foundry(n, d, k, reps, mask)` runs the enumeration:
each variant against the generic on the same buffers at the asked
shape and at a hidden one (a different, odd n; different data), both
on the GPU clock, the device awake; the winner — if it clears 1.3x —
lands in the stats DLL's variant table (n-class, d-class, k-class) and
is persisted under the op name `umap_knn` beside pairdist's rows. The
stats DLL, having its own device and table, reads the persisted rows
back once at its first fit (`StzUmapKnnVariantsSync`). Face:
`stzGpu.FoundryUmapKnn(n, d, k)`. Counter: `umap.knn.variant`
dispatches (slot 4).

**The kill line, measured on the RTX 3050, k = 15, ratios on the GPU
clock against the generic — every cell VERIFIED at its visible and
hidden shape** (the two right-hand columns are GK3's, 2026-10-24, for
the kernel the verdict kept, FLOPs as 3 · n² · d for every pair's
squared distance, against the 7.45 TFLOP/s and 77 GB/s this card
measures: the k-NN kernel reaches 0.7-2% of the ALU, so its cost is
the selection and the strided reads, not the arithmetic):

| shape | generic | tile | tile4 | chunk | verdict | kept kernel, of peak | kept kernel, of bandwidth |
|---|---|---|---|---|---|---|---|
| 4,096 × 8 | 3.6 ms | 0.59x | 0.82x | 0.65x | generic stays  112 GFLOP/s, 1.5% | 0.17 GB/s, 0.2% |
| 16,384 × 8 | 29.7 ms | 0.82x | 1.22x | 0.37x | generic stays  217 GFLOP/s, 2.9% | 0.08 GB/s, 0.1% |
| 8,192 × 32 | 30.5 ms | 0.53x | 1.23x | 0.55x | generic stays  211 GFLOP/s, 2.8% | 0.07 GB/s, 0.1% |
| 8,192 × 64 | 85.3 ms | 0.52x | **1.52x** | 0.83x | **tile4**  230 GFLOP/s, 3.1% | 0.05 GB/s, 0.1% |
| 4,096 × 256 | 234 ms | — | — | **2.26x** | **chunk**  124 GFLOP/s, 1.7% | 0.05 GB/s, 0.1% |
| 4,096 × 128 | — | — | — | **1.61x** | **chunk** | — (no generic time recorded) | — |

The line is the row's WIDTH, not the count: below 64 features the
generic's warp-broadcast reads out of L1 already beat a staged tile
and its barriers, and the foundry says so; from 64 up a variant earns
its place, and past the register-staging limit only chunk can answer
at all, at 2.3x by 256 features. That is the paper's regime ("a few
hundred features") and the one the seams that feed UMAP produce
(embeddings, PCA scores).

**Held by the guard:** every eligible variant verified in every grid
cell; the broken sibling refused through the mask and rejected by the
table; a set variant dispatches (counter) and answers the generic's
rows exactly for all three; cleared, the counter stays still; a
persisted `umap_knn` row reaches the stats DLL through the sync, for
its class only; the calibration files restored byte for byte.

**Paid for:** the table refusing a row a variant cannot honour (a tile
row at d = 128 degrades to the generic, never dispatches an ineligible
kernel); and the checker's band is a distance band, so the index half
of the answer is what makes a wrong neighbour visible.

Next on this plane from the paper: trustworthiness as the guard's
witness, computed with this kernel. Named, not built: GK2b (matmul
tiles), GK3.

---

## GK2b STATUS — matmul leg shipped 2026-09-10: the backbone's spine at 3x, by a variant the checker chose

Guard: `base/test/gpu/gpu_foundry_matmul_narrated.ring` — **21 asserts
green**. Gates: `gpu_ops_narrated` 37, `gpu_foundry_narrated` 27,
`neural_backbone_narrated` 14, `neural_gpu_routing_narrated` 17,
`numeric_umap_resident` 18, `numeric_umap_gpu` 23; Zig `gpu_ops.zig` 6.

**Why now, and only this half.** GK2b named two legs: matmul tiles and
the elementwise workgroup widths. The elementwise half has no caller
that dispatches from a face, so a winner there would sit unused; it
stays named. The matmul half has one: the neural backbone's 6-layer
spine runs the op library's 16×16 tile kernel resident at a measured
1.5x over the CPU, and the semantic tier's per-layer route dispatches
the same op. That is a workload asking.

**What shipped.** Four kernels on one contract in `gpu_ops.zig` —
C(m×n) = A(m×k)·B(k×n), every one on a LINEAR workgroup grid so GK0's
checker, which dispatches (wx, 1), can judge them all at any shape:
**tile16** (the G0 spike kernel, the generic), **tile8**, **reg2**
(16×16 threads each computing a 2×2 block: a 32×32 tile), **reg4**
(4×4 per thread: a 64×64 tile, sixteen accumulators). A **broken**
sibling (reg2 with one element wrong) exists for the checker to refuse.
`mmSource(v, bias)` generates each kernel's text with or without a
fused bias, so the backbone compiles the SAME winner the table names
for its shape in its own (bias) form. `stz_gpu_foundry_matmul(m, k, n,
reps, mask)` runs the enumeration; the winner per (m, n, k) class lands
in the variant table under `matmul`, is persisted beside pairdist's
rows, and reaches the neural DLL's own table (its own device, its own
gpu_ops copy) through `StzNeuralVariantsSync()` before the first
embedding. Face: `stzGpu.FoundryMatmul(m, k, n)`.

**The kill line, measured on the RTX 3050 on the backbone's shapes,
GPU clock, every cell VERIFIED at its visible and hidden shape:**

| m × k × n | generic | tile8 | reg2 | reg4 | verdict | winner, of peak | winner, of bandwidth |
|---|---|---|---|---|---|---|---|
| 64 × 384 × 384 | 0.11 ms | 0.82x | **1.47x** | 1.21x | reg2  0.25 TFLOP/s, **3.4%** | 10.5 GB/s, 14% |
| 256 × 384 × 384 | 0.39 ms | 0.87x | 2.28x | **2.59x** | reg4  0.50 TFLOP/s, **6.7%** | 9.1 GB/s, 12% |
| 256 × 384 × 1536 | 1.53 ms | 0.79x | 2.37x | **4.28x** | reg4  0.84 TFLOP/s, **11.3%** | 12.1 GB/s, 16% |
| 256 × 1536 × 384 | 1.60 ms | 0.86x | 2.43x | **2.52x** | reg4  0.48 TFLOP/s, **6.4%** | 6.8 GB/s, 9% |
| 512 × 384 × 1536 | 1.89 ms | 0.82x | 2.25x | **4.35x** | reg4  1.39 TFLOP/s, **18.7%** | 14.5 GB/s, 19% |

**The time column is the GENERIC tile's time on the GPU clock** (the
checker's `refgpums`, warm-min of 7); a variant's time is that divided
by its ratio, so at 512 × 384 × 1536 reg4 ran in 1.89 / 4.35 = 0.43 ms
-- 2 · 512 · 384 · 1536 = 604 MFLOP in 0.43 ms = **1.39 TFLOP/s, 18.7%
of the 7.45 TFLOP/s burst peak GK3 measured on this card on
2026-10-24** (and 24% of its 77 GB/s copy bandwidth). The two
right-hand columns were added by GK3 with that reading, against that
peak; the times are the 2026-09-10 ones. Re-measured 2026-10-24 in the
guard: generic 1.85 ms, reg4 4.18x, 0.443 ms, 1.36 TFLOP/s, 18.3%. The
compass read "about a quarter of the 3050's peak" from this row against
a guessed 5.9 TFLOP/s; measured, the fraction is smaller.

Smaller tiles never pay; register blocking pays everywhere, more the
wider the output. **And through the real backbone** (MiniLM, 130
tokens, the winners synced, bias fused): the forward went **23.9 ms →
8.0 ms, 3.0x** in the measuring probe and 14.3 → 7.5 ms (1.9x) in the
guard's own run — the "before" moves with the device's power state,
the "after" sits at 7.5–8 ms either way — the embedding unchanged
within f32. Against a CPU full forward of 36.6 ms, the spine that was
1.5x is now 4.6x.

**The finding that cost an hour.** The first register-blocked kernels
measured 0.18x and 0.04x — slower than the generic by 5x and 25x — and
were VERIFIED correct. The cause was not the arithmetic: their
accumulators were private arrays indexed by loop variables, which the
compiler places in local memory, not registers. Fully unrolled at
comptime (every accumulator, staged value and store a named scalar) the
same kernels measure 2.3x and 4.3x. The checker is what made this
visible as a number rather than a hunch; without it the first draft
would have read as "register blocking does not pay on this GPU".

**Also paid for:** a Zig `@max` of two comptime constants narrows to a
three-bit type and overflows when multiplied; kernel-text generators
that concatenate must be called under `comptime`; and a Zig multiline
literal written through a shell heredoc loses one backslash of every
`\\` — write kernel edits through a file, never a heredoc.

GK2b's elementwise half and GK3 stay named, not built.

---

## GS6f STATUS — shipped 2026-09-10: trustworthiness, the field's witness, exact on the CPU and the same number on the device

Guard: `base/test/number/numeric_trustworthiness_narrated.ring` —
**18 asserts green**. The two device guards now carry it beside purity:
`numeric_umap_gpu` 26, `numeric_tsne_gpu` 24. Gates: `numeric_embedding`
240, `numeric_umap_resident` 18; Zig `trustworthiness.zig` 3.

**What it is.** Venna & Kaski's trustworthiness, as scikit-learn computes
it and as cuML's paper reports it beside every timing:

    T(k) = 1 − 2 / (n k (2n − 3k − 1)) · Σ_i Σ_{j ∈ U_i^k} (r(i, j) − k)

U_i^k is the set of points among i's k nearest in the EMBEDDING that are
not among its k nearest in the INPUT; r(i, j) is j's rank in i's input
ordering. A neighbour the layout invented is charged by how far down the
input ordering it really sat; 1.0 means nothing was invented. It needs
only the data the fit saw and the embedding — no labels, no blob
generator — and it is the number the field compares on, so this
library's tables can sit beside the paper's.

**What shipped.** `engine/src/trustworthiness.zig`: the exact CPU form
(O(n²(d + dims)), the k-NN kernel's tie rule — equal distance, the lower
index is nearer — on both sides, so the two routes
differ only where f32 makes a tie that f64 does not), with a hand-computed case pinned by a test: five points
on a line, the last folded back beside the first, T(1) = 0.4 exactly.
`umap_gpu.trustworthiness`: the device route — two passes of the k-NN
kernel (the input, the embedding) and one RANK pass, one thread per
(point, embedding-neighbour slot), the n·k penalties summed in f64 —
from a gate of 1,024 points, where the CPU and the device cost the
same. `StzEngineEmbeddingTrustworthiness(x, n, d, y, dims, k, mode)`
is the door (rows or flat lists; mode 0 the engine decides, 1 the CPU,
2 the device); `stzUMAP.Trustworthiness()` and
`stzTSNE.Trustworthiness()` (k = 5; `TrustworthinessAt(k)`) answer it
on the data the fit saw.

**Measured, four blobs in 8 dims, T(5):**

| fit | CPU route | device route |
|---|---|---|
| UMAP 1,000 | 0.9951 | 0.9982 |
| UMAP 4,000 | 0.9926 | 0.9891 |
| t-SNE 1,000 | 0.9952 | 0.9959 |

The device witness agrees with the CPU's within ONE RANK UNIT —
2/(n·k·(2n−3k−1)), 5e-8 at 2,000 points — on every fit measured (gaps
of 0 to 5e-8): where f64 separates two input distances that f32
cannot, the tie rule decides them differently, and that is the whole
of the gap. The guard bounds it at four units. At 4,000 points the
device witness is 5–8x faster (22–26 ms against 122–224). The device
UMAP route's 0.004 gap at 4k is the same synchronous-update cost GS6c
measured by purity, now in the field's units.

**Held by the guard:** the hand case exactly 0.4 on both routes; an
embedding that keeps every neighbour exactly 1; shapes outside the
definition answer 0; both routes within four rank units at k = 5 and
k = 15 on 2,000 real points, and the witness moves with k; the gate on both sides with the
counter; the faces on a fitted UMAP and t-SNE; the device faster at 4k.

The paper's list for this plane is now complete on this desk: the data
resident, the graph resident, the k-NN through the foundry, the matmul
through the foundry, the witness. Named, not built: GK2b's elementwise
half, GK3.

---

## THE FLATTENING TAX, THE REMAINDER — shipped 2026-09-10: every matrix face sends rows

Gates, all green: `numeric_pca` 69, `numeric_vector_index` 28,
`numeric_logistic` 38, `numeric_hypothesis` 69, `numeric_knn_selection`
24, `numeric_embedding` 240, `numeric_backprop` 30, `numeric_autodiff` 48,
`knn_approximate` 27, `mlfloor` 36, `learning_multilingual_stress` 37,
`semantic_search` 14, `neural_semantic_gpu_seam` 33, `gpu_ops` 37.

**What shipped.** The class the first tax pass named is closed. Two
more doorways walk rows engine-side — the GPU bridge's buffer upload
(`StzEngineGpuBufferUploadList`) and the neural bridge's GGUF tensor
export — beside the stats bridge that already did; a flat list behaves
exactly as before and a ragged row is refused. Then every face that
appended a matrix one number at a time sends its rows as they are:
stzPCA (fit, transform, inverse — the loadings too, cut to width only
when the caller supplied fewer components), stzKnn (the resident model,
the agreement queries), stzVectorIndex (the index build, the device
upload, the recall queries), stzSemanticIndex (the resident dataset
and the device upload), stzLogisticRegression (train, predict),
stzTrainer (inputs and targets), stzNeuralNetwork (the weight tensors
on export), the chi-square table, and the four sites left in
stzEmbedding (both `LocalRadiiOf` paths, both inverse decoders). ANOVA's
groups are ragged by nature and stay flat; the bar plot pads its series
and stays flat.

**Measured, the face timed at its doorway, old face against new face
on the same new bridges:**

| face | before | after |
|---|---|---|
| stzVectorIndex build, 20,000 × 128 | 1,644 ms | **260 ms** (6.3x) |
| stzSemanticIndex first search, 5,000 × 384 | 967 ms | **38 ms** (26x) |
| chi-square, 300 × 300 | 23 ms | 3 ms |
| stzLogisticRegression train, 20,000 × 64 | 887 ms | 738 ms |
| stzKnn resident + agreement, 20,000 × 64 | 1,210 ms | 1,149 ms |
| stzPCA fit, 5,000 × 64 | 1,797 ms | 1,668 ms |

Where the engine's own work is small the doorway was most of the call
and the win is an order of magnitude; where the engine works (a
logistic epoch, an exact agreement, a PCA fit) the doorway was a tenth
and the win is a tenth.

**A finding for the numeric desk, not fixed here:** `stzPCA.Fit()`
took 1.7 s at 5,000 × 64 and 268–435 s at 20,000 × 256 in two runs.
That is the engine's decomposition, not the face, and it is far off the
cost of the arithmetic (a 256 × 256 covariance and its eigenvectors
are milliseconds). Routed in CONCLUSIONS; `base/number/` is not touched
unnotified.

**Paid for, again:** a `func` placed at the TOP of a probe swallows the
whole probe — the first two measurements printed nothing; put helper
functions at the end of a script.

---

## GK2c STATUS — shipped 2026-09-10: the backbone's attention through the foundry; the kernel 1.5x, the forward 7%

Guard: `base/test/gpu/gpu_foundry_attention_narrated.ring` — **12 asserts
green**. Gates: `neural_backbone` 14, `neural_gpu_routing` 17,
`neural_semantic_gpu_seam` 33, `semantic_search` 14,
`gpu_foundry_matmul` 21.

**Why this kernel.** After GK2b the forward was 7.5 ms and the fused
attention was the largest kernel left in it that had never been
measured against an alternative. The generic — one workgroup of 64 per
(head, query row) — had EVERY thread scan max and sum over the tokens
serially (64 threads doing the same n_tok exponentials) and used
head_dim threads of the 64 for the context.

**What shipped.** In `neural_backbone.zig`: the attention family on a
LINEAR grid (head = id mod n_head, row = id div n_head) so the checker
judges every kernel at every shape — **scan64** (the generic),
**red64 / red128 / red256** (max and sum reduced through workgroup
memory; the context's token range split W / head_dim ways across the
threads a head does not need) and a **broken** sibling (one output
nudged) for the checker to refuse. `neural_attention_foundry(n_tok,
n_embd, n_head, reps, mask)` runs the enumeration on the neural DLL's
device at the asked token count and a hidden odd one; the winner past
1.3x lands in the neural DLL's variant table under `attention`
(tokens, width, head_dim), is persisted beside the matmul rows through
the face `stzGpu.FoundryAttention`, and reaches the DLL through the
same sync before the first embedding. The forward dispatches the
table's variant and **reports which** (`StzEngineNeuralAttentionVariantUsed`),
which is the guard's witness.

**Measured, RTX 3050, 384 wide, 12 heads, every cell VERIFIED** (the
two right-hand columns are GK3's, 2026-10-24, against the 7.45 TFLOP/s
and 77 GB/s this card measures; FLOPs counted as 4 · n² · 384 for the
two products, bytes as Q, K, V in and the context out; what they say is
that attention at these token counts is **neither compute- nor
bandwidth-bound -- it is submit-bound**, 0.19-1.39 ms against a 0.13 ms
smallest dispatch, which is why a 1.5x tile wins and no tile wins 10x):

| tokens | generic | red64 | red128 | red256 | verdict | winner, of peak | winner, of bandwidth |
|---|---|---|---|---|---|---|---|
| 64 | 0.19 ms | 1.35x | **1.37x** | 1.27x | red128  45 GFLOP/s, 0.6% | 2.8 GB/s, 3.7% |
| 130 | 0.73 ms | 1.49x | **1.51x** | 1.47x | red64 / red128 (a coin toss between runs)  54 GFLOP/s, 0.7% | 1.7 GB/s, 2.1% |
| 256 | 1.39 ms | 1.29x | 1.25x | 1.24x | generic stays (under the margin)  72 GFLOP/s, 1.0% | 1.1 GB/s, 1.5% |

**And through the real forward** (MiniLM, 130 tokens, warm-min of 7):
all generic **14.43 ms**; the matmul winners **7.46 ms**; the matmul
and attention winners **6.94 ms** — the attention's own 1.5x is worth
7% of the forward, because after GK2b the attention is a smaller share
than the spike's per-head decomposition had suggested. The embedding
is unchanged within f32. The whole foundry series on the backbone:
14.4 → 6.9 ms, **2.08x**, against a CPU full forward of 36.6 ms —
**5.3x**.

**The honest reading.** The kill line held on one cell (256 tokens),
and the win at the forward is modest: the reductions were the right
fix for the generic's redundant scan, and there is no larger one in
this kernel's shape — the remaining time is the matmuls at their
register-blocked speed, the layer norms and the GELU, each a fraction.
The backbone is at the point where the next factor is not a kernel.

GK2b's elementwise half and GK3 stay named, not built.

---

## GX — MORE THAN ONE ADAPTER (named 2026-09-11, on the author's question)

The author asked whether the parallel programming system covers more
than one GPU. It does not, by design, and this section records what
the plane has, what it lacks, and the one item that would close the
gap, with its kill line written before any code.

### GX.1 — what the plane does with several adapters today

- **Enumeration and a name for each** (`gpu.zig` at init, first
  discrete by default, adapter 0 otherwise; `stzGpu.AdapterCount()`,
  `DeviceName()`).
- **Explicit selection of ONE** (`StzEngineGpuSelectAdapter`): the
  current device is closed first and every buffer and kernel handle
  goes stale on purpose. One device per DLL at any time. The GK1 and
  GS1 guards measure the RTX 3050 and the Intel iGPU one after the
  other, never together.
- **Calibration per adapter**: thresholds, shaped classes and foundry
  variant tables persist under the adapter's name, so a machine that
  switches adapters gets the right verdicts.

That is selection, not parallelism.

### GX.2 — what it lacks

- **Two devices at once.** The device, queue, buffer table, kernel
  table, batch state and counters are module globals; every op, seam
  and foundry keys off them. Two devices in one DLL means that state
  becomes a context instance — a refactor of the plane, not a feature
  on it.
- **A partition and a merge.** Nothing splits rows across devices or
  gathers results; wgpu has no device-to-device transfer, so a split
  always round-trips through the host.
- **A substrate.** The concurrent plan settles on three substrates —
  engine threads, reactor processes, cluster workers — "one router, no
  fourth", and names the GPU once, as a witness of the boundary law.
  The per-DLL device law means the neural, stats and gpu DLLs could
  land on different adapters by accident, never by a face's choice.

### GX.3 — the physics on this machine

The second adapter here is the iGPU: 3–4x slower per kernel than the
3050 (GS6's spike: 71x against 19.7x on the same chain) and sharing
system memory. A workload split across both gains at most about a
quarter while doubling the doorway crossings, and every seam this
plane shipped in September turned out to be doorway-bound (the
flattening tax, twice). Multi-GPU pays only with two or more DISCRETE
adapters and a row-partitionable, resident workload.

### GX.4 — the item

- **GX0** — the adapter pool: the device state as a context instance
  in `gpu.zig`; a pool that opens one context per adapter; row
  partition on the host with each shard routed by its adapter's own
  calibration; a host merge; the counters per context. Workloads that
  partition by rows and stay resident per shard: batch embeddings
  (the backbone per shard), k-NN over a large corpus (GS6e's kernel
  per shard, the merge a k-way top-k), an epoch chain per shard where
  the objective allows it (k-means yes, t-SNE and UMAP no — their
  epochs read every row). Not started.

**Gate to build, written now:** a machine with at least two discrete
adapters AND one of those workloads asking. Neither exists on this
desk; the item waits for both.

**Kill line, written now:** on the first such machine, a two-adapter
pool must beat the faster single adapter by ≥1.5x on the workload's
own guard at its real size, both adapters awake, the doorway included
in both timings. Below that, the pool is refused and the plan records
that partition cost ate the second adapter — the boundary law's fifth
witness — and the plane stays one device per DLL.

---

## GRAPHICS ON THE GPU — audited 2026-09-11: it draws where the plan said; two defects and one drift found and fixed

The author asked whether the graphics engine uses the GPU as it should.
Audited from the code and then at run time with the engine's own
counters (draws, submits, fallbacks, pipeline compiles, live textures,
transfer bytes), on the RTX 3050.

**What the plan says and the code does.** Every 2D `ToPNG` in the
library — the plot family, `stzDiagram`, `stzMathDiagram`,
`stzOrgChart`, `stzGraphCanvas`, `stzPanel`, `stzSoundGrid` — funnels
into `stzCanvas.ToPNG`, which asks for the device once per process and
renders through `gpu_scene.zig`: tessellate, one render pass into an
offscreen target, one readback, pure-Zig PNG. Measured: one draw and
two submits per picture, zero fallbacks, 1.8 ms for an 800×600 render
and readback, 7–8 ms with the encode, 15 ms for a chart, 43–53 ms for
a 1080p canvas of 5,000 circles. The render pipelines compile once
(three) and are cached. SVG never touches the device. That is the tier
ladder as written.

**Defect 1 — a texture per picture, never freed.** Every face's
`ToPNG`/`ToSVG` built a transient canvas (`ToCanvasQ(...).ToPNG(path)`)
and dropped it; Ring has no destructor, so the engine scene — its
offscreen target on the device, its vertex buffers, its command list —
stayed live. The live-texture counter climbed by one per picture
(0 → 1 → 2 → 3); twenty charts, twenty targets; a 1080p target is 8 MB
of VRAM. Fixed at every site (24 across ten faces): the canvas is
kept, the answer taken, `Free()` called, the answer returned. Twenty
chart PNGs now leave the counter where it was. A canvas the caller
made explicitly is the caller's to free, as before.

**Defect 2 — the first picture paid 0.65–2.5 s for a device init the
plan quoted at ~300 ms.** Instrumented step by step: the instance over
ALL backends enumerated D3D12 and GL as well as Vulkan, and that
enumeration cost 450 ms warm and 2.3 s cold — while every adapter the
engine ever picked came from Vulkan (both the 3050 and the iGPU). The
instance now asks Vulkan first (3 ms to enumerate) and falls back to
all backends only when Vulkan lists nothing, so a machine without a
Vulkan driver keeps exactly the old behaviour. Init: **224–299 ms** in
three fresh processes; the first picture in a cold process (init, the
three pipeline compiles, the font, the draw, the encode): **814 ms**
where it was 2,200. Every DLL with a device (gpu, stats, neural) gets this, since
they share `gpu.zig`.

**Drift — two guards red for a month, same class.** `gpu_scene_narrated`
asserted six scene-stats slots; DN3b had widened the contract to ten
(text dropped, glyphs dropped, shape and text draws refused — what a
build could NOT draw, as numbers). `gpu_text_narrated` asserted seven
layout slots; DN12 had appended two (ink top, ink bottom — the cap
height a label centres on). Both contracts were APPENDED, never
reordered, so every face kept working while the guards stayed red. The
scene guard now asserts ten and that a healthy scene's four refusal
slots are zero (**70 green**); the text guard asserts nine and that the
ink band lies inside the em box (**42 green**). The lesson is the
knob-gate's: a doorway that grows its answer owes its guard a line in
the same commit.

**A fixture that is an output, recorded not fixed.** Running
`gg3_hierarchy` rewrites `gg3_system.png` and git shows it modified.
Two reruns give the SAME bytes — the render is deterministic — but the
committed file (2026-08-09) is RGBA, 41 KB, and today's encoder writes
an opaque canvas as RGB, 30 KB, with 727 of 620,000 pixels moved
(0.12%, at glyph edges: DN12 recentred labels). The gate reads the
fresh render, never the committed bytes, so the file is a by-product
checked in as if it were an expectation. Left as committed; a PNG
regenerated by a gate must not ride along in an unrelated commit
(the A/B sweep's rule), and whether the graph desk wants the fixture
refreshed or dropped is that desk's call.

**One plan-versus-code divergence, recorded not fixed.** The tier
ladder names "a CPU rasterizer as the counted fallback" for PNG. There
is none: without a device `ToPNG` answers an empty string, counted,
and the face's SVG tier is the floor — which is what GR2b shipped and
what CI relies on. The sentence in §2 overstates the code; the PlutoVG
line it points at was never built. Left as written here so the next
reader knows which of the two documents to trust: the code.

Gates, all green: `gpu_lifecycle` 62, `gpu_ops` 37, `gpu_verify` 26,
`gpu_scene` 70, `gpu_text` 42, `gpu_errors` 14, `gpu_render_lifecycle`
74, `gpu_convolve` 19, `gpu_calibration_shaped` 40, `numeric_tsne_gpu`
24, `neural_backbone` 14, `plot_backends` 29, `gg2_graphcanvas` and
`gg3_hierarchy` pass. Owned and not run: none on this desk's list.

---

## GK3 STATUS — shipped 2026-10-24: the peak in the roofline, measured, and what measuring it found

Guard: `base/test/gpu/gpu_verify_narrated.ring` — **36 asserts green**
(26 before), run on Ring 1.27, interim. Zig: `gpu_verify.zig` 4 tests
(2 new: the pure compute judge; the peak kernel's text and FLOP count).
Gates run on the device the same afternoon, every one green:
`gpu_foundry_matmul` 18 (fraction rows printed per cell), `gpu_foundry`
27 (pairdist, fraction row), `gpu_calibration` 10,
`gpu_calibration_shaped` 40 (its Wake scene failed once on the way and
is the reason for the second half of finding 3), `gpu_lifecycle` 62,
`gpu_ops` 37, `gpu_declarative` 20, `gpu_batch` 13, `gpu_seams` 17,
`gpu_deploy_gate` 16. Not run:
the backbone scene of the matmul guard (no MiniLM in this worktree; it
says so and skips) and the neural and stats guards (their DLLs carry
their own copy of `gpu_verify.zig`; both DLLs were rebuilt and compile).

**Why.** Every kernel this plane had timed was recorded as "Nx the CPU"
or "Nx the generic tile", never as a fraction of what the hardware can
do, and GK0's roofline refused a time that beat the BUS and had no
ceiling for ARITHMETIC: a candidate claiming more FLOP/s than the device
owns was not refused. The Modular reading (compass, 2026-10-24) named
both; this rung measures the peak and makes the ceiling.

**What shipped.** In `gpu_verify.zig`: a register-only fused-multiply-add
kernel built at comptime (`fmaSource(chains, unroll)`; 16 chains, body
unrolled ×16, 256 fma per loop round, m and b from the params uniform
so nothing folds), measured once per device inside `ensureFloors`
beside the copy floor and the submit floor, warm-min of 5 on the GPU
clock after a compute warm-up; `minPossibleMs` and `judgeWith` take the
candidate's FLOPs and refuse a time implying more than the peak ×
`PEAK_ALLOW` (1.15); `stz_gpu_verify_judge_flops(bytes, flops, ms)`,
`stz_gpu_verify_declare_flops(visible, hidden)` for the next verify,
`stz_gpu_verify_peak_gflops`, `_peak_measured_gflops`, `_peak_set` (a
pin); result slots 17-20 (peak, declared FLOPs, compute floor, warm
dispatches). The foundry declares its ops' FLOPs (2mkn; 3mnd) and
records FLOPs, bytes and the peak in slots 7-9 (F_BASE moved 8 → 10;
the face's two gpu readers moved with it, the neural and stats readers
keep 8). Face: `VerifyJudgeFlops`, `PeakGFlops`, `PinPeakGFlops`,
`RecordFloors`, `VerifyFloors()[:peakgflops]`, and every foundry report
carries `:fractions` — for the generic and each verified variant, the
fraction of the measured peak and of the measured copy bandwidth; the
two foundry guards print them per cell. The record: `VerifyFloors`
writes `peak_gflops` and `copy_gbs` into the adapter's calibration file
(`engine/data/gpu_calib_<adapter>.txt`) beside the ops' thresholds.
The standalone instrument: `engine/src/gpu_peak_probe.zig` (not built by
the default build), every adapter, six body densities, three work sizes,
A B A B against the copy kernel, both clocks, the spread of 7 beside
every number, and `--ramp` for the clock's behaviour under sustained
work. And `zig build -Ddomains=stz_gpu -j2` builds one DLL instead of
92 (4 minutes cold, 20 seconds warm): a desk changing one domain owes a
rebuild of that one.

**Measured, 2026-10-24, wgpu-native as vendored, Vulkan, GPU timestamps
inside the pass, warm-min; the record is the adapter file, the spread is
the probe's:**

| adapter | burst peak | sustained | copy, 16 MB in + out | smallest dispatch | warm-up to the peak |
|---|---|---|---|---|---|
| RTX 3050 6GB Laptop GPU (2048 lanes, max SM clock 2100 MHz, 65 W) | **7.45 TFLOP/s** in the Ring process (7.38-7.85 across six guard runs; the probe 7.5-8.4 at 4 ms, spread 0.5-1.9 ms) | 7.1-7.25 TFLOP/s at 75-150 ms per dispatch, spread 0.6-1.7 ms | 77 GB/s (54-79 across runs) | 0.13 ms | 50-60 dispatches, ~300 ms |
| Intel(R) Graphics (Core 5 210H iGPU) | **955 GFLOP/s** cool (957-972 across runs; **331-617 after eleven seconds of its own full load**) | 955 (no burst/sustained step) | 22 GB/s alone, 35-53 right after compute | 0.21 ms | 20 dispatches, ~700 ms |

The 3050's burst is 97% of 2048 × 2 × 2.1 GHz at its best (8.36, run 3
of the probe) and 1.73-1.82 GHz-equivalent in the Ring process; the
published 7.1 TFLOP/s is its SUSTAINED figure, not its ceiling. The
discrete card is 7.8x the integrated one in arithmetic and 1.5x (3.5x
alone) in bandwidth.

**Found, and each one changed the design above:**

1. **The loop was the first measurement.** 8 fma per loop round read
   2.70 TFLOP/s on the 3050 and 0.43 on the iGPU; 256 per round read
   8.36 and 0.97 from the same hardware. The counter, compare and branch
   share issue slots with the fma. A peak kernel is a DENSE one or it
   measures its own bookkeeping — GK2b's lesson (accumulators in a
   private array, 0.04x) met one level up. A ceiling set by the loop
   kernel would have refused every kernel above a third of the ALU.
2. **The clock is a governor, and it was sampled.** `nvidia-smi` at
   250 ms while the guard ran: the 3050 sits at **990 MHz (P3, throttle
   reasons 0x24: software power cap and thermal slowdown)** and rises to
   1477-1740 only after about a quarter second of SUSTAINED arithmetic;
   copies do not raise it. The engine's first peak, read right after the
   copy floors, was 4.78 TFLOP/s in every run, in the probe's process as
   in Ring's — not a process effect, an ORDER effect. The peak is now
   measured after at least 300 ms of its own dispatches and windows of
   five until three in a row stop improving by 3%; it reads 7.4-7.8.
3. **Wake(400)'s awake test was a 3050 constant, and the first repair
   regressed it.** One 32 MB copy under 2 ms is the 3050 ASLEEP and the
   iGPU awake at once (its copies take 1.5 ms whatever one does), so the
   iGPU's floors were measured at 19-23 GB/s. The first replacement —
   settle when the copy stops improving by 10% — settled on the asleep
   3050 (its 9 ms copies are a plateau too) and read a **5.9 GB/s**
   floor. Wake now runs at least 300 ms of sustained copies before
   looking for a plateau the FIRST time it meets a device, remembers the
   best copy it saw, and from then on a copy within 3x of that best
   says awake (21 copies, ~10 ms; an asleep card is 20x slower, so 3x
   cannot confuse the two) — the shaped-calibration guard's "second
   burst stops at the settle count" failed two versions on the way: one
   that knew awake only once the floors existed, and one with a 1.3x
   bound that the best copy's own jitter (0.39 against 0.43-0.48 ms)
   put most normal copies outside of.
   The `--ramp` run that found the iGPU flat at 22 GB/s for 400 copies
   and 955 GFLOP/s for 300 dispatches also says: the iGPU does not ramp,
   it THROTTLES — see 5.
4. **A process-wide store keyed by name mis-scopes across adapters.**
   The first design filled `peak_gflops` and `copy_gbs` into the flat
   calibration store and read them back as the authority (explicit >
   persisted > measured, the order the thresholds keep). The probe,
   which switches adapters in one process, then read the iGPU's 957
   GFLOP/s and 20 GB/s as the 3050's and would have refused everything
   above 1.1 TFLOP/s. The authority is now **a pin set in this process,
   else this device's own measurement**; the file is a RECORD the engine
   never reads back. Reported because the order "explicit > persisted >
   seed" is right for a threshold a tuner sets and wrong for a hardware
   fact a device measures.
5. **The iGPU's peak halves when the package is hot** (955 → 470 →
   331 across an afternoon of runs; the CPU shares its power budget), so
   a ceiling measured hot would refuse a kernel timed cool for running
   as fast as the device can. A refusal BY COMPUTE is therefore
   confirmed: the peak is re-measured in the same second (it can only
   rise), and the time is judged again; a pinned peak is not re-measured.
   `R_PEAK_WARM` says how many dispatches the warm-up took.
6. **The second clock agrees with the wall by the submit** (0.3-0.5 ms)
   on both adapters, and both have timestamp queries. One latent defect
   fixed on the way: the checker's query set was released on device
   close only if the floors had been measured first (only `ensureFloors`
   registered the close hook); `ensureTs` registers it itself now, found
   when the probe asked for timestamps before any floor and wgpu refused
   a query set of the old device on the new one.
7. **The compute ceiling rarely speaks on the 3050 for the backbone's
   kernels** — reg4's 604 MFLOP at the peak is 0.08 ms, under the 0.13
   ms submit floor, so the bus refuses first; the guard's fixture claims
   a hundred such dispatches (60 GFLOP, 8 ms at the peak) so the ceiling
   alone decides. The ceiling matters for the kernels GK6 and the
   puzzles will bring: a user kernel declared with its FLOPs, judged
   without a Zig twin.

**The 1.89 ms question** (GPU_PLAN.md GK2b table): the time column is
the generic's GPU-clock time and the variant's time is that divided by
its ratio, so reg4 at 512 × 384 × 1536 is 0.43 ms, 1.39 TFLOP/s, **18.7%
of the measured burst peak** — written into the table above, with the
same two columns on the attention, k-NN and semantic-seam tables. What
those columns say, read together: the matmul variants reach 3-19% of
the ALU and 14-35% of the bandwidth; attention and the single-query
seam reach under 1% of the ALU — they are submit-bound; the k-NN kernel
reaches 0.7-2% — it is a selection, not an arithmetic kernel. The plan
had one kind of number for all of them.

**Decided:** `PEAK_ALLOW` 1.15 (the burst moved 8% between runs and sits
15% over sustained; a low ceiling refuses legitimate kernels, the worse
failure). The ceiling is the BURST peak, because a foundry candidate
runs for milliseconds and sees the burst. Pin > measured, record not
authority (4). Refusal by compute confirmed against a fresh peak (5).

Next: **GK6**, the user kernel's own reference — the KernelMaker spec
interpreted on the CPU as the checker's reference, NaN guard margins, a
shape assert — which is where a declared-FLOPs candidate without a Zig
twin first meets this ceiling.

**Addendum, the same evening, under Ring++ and on battery.** The counts
above were taken on Ring 1.27 (interim). Told to work against Ring++, the
desk ran the same guards under `rnxc` from a verification vehicle — the
migrated lineage `ringpp/migrate-rule-a` plus this plane's files plus
engine DLLs built for `rpp_init` from this tree by ringpp's
`engine_copy.py` — and ten of the eleven GPU gates answered the SAME
counts (verify 36, foundry 27, matmul 18, calibration 10, lifecycle 62,
ops 37, declarative 20, batch 13, seams 17, deploy 16); the shaped guard
answers 38 of 40 there because its Scene 3 drives `stzVectorIndex`'s
seam, which learned to consult the shape with GK1 (September) and the
lineage split in August. Two Ring++ facts for every GPU guard: counters a
function touches are `$nPass` / `$nFail` at every site, and an
engine-only guard loads `stdlibcore.ring`, not `stdlib.ring`. Three
findings came with the second runtime, none of them about Ring++:

- **The floors are the MINIMUM over three rounds separated by compute.**
  From a cold card (two minutes idle) copies ran at 6 GB/s for 250 ms and
  then 49-67; once, after a full second of dense compute, the smallest
  dispatch read 0.82 ms and the copy 16 GB/s where the awake device does
  0.13 and 77 — and GK0's own CONTROL then read *impossible*: a floor
  measured in a slow state refuses awake work. A floor is the fastest the
  device does; the minimum across states, with 100 ms of dense dispatches
  between rounds to move the governor, is that.
- **The peak's warm-up is a full second.** Three hundred milliseconds
  plateaued at 990 MHz on a cold card (4.8 TFLOP/s), and the confirmation
  re-measurement read 8.4; the governor's jump is discrete and late. The
  guard's fixture claims a QUARTER of the peak's time, beyond the 1.76x
  the clock can swing (990 to 1740 MHz) between two readings.
- **The machine was on battery** (72%, `sw_power_cap` active, 58-60 °C)
  for the evening's runs, and that is the local fact behind the swing in
  every number after the GK3 record: Wake's awake copy itself moved
  between 16 and 77 GB/s across an hour, so a later Wake now measures
  itself against the PREVIOUS Wake's best copy, not an all-time best. The
  GK3 record's power source was not recorded; **a measurement in this
  plane names its power source from now on**, and the record is to be
  re-taken on mains.

---

## GK6 STATUS — shipped 2026-10-24: the user kernel's own reference

Guard: `base/test/gpu/gpu_spec_reference_narrated.ring` — **34 asserts
green under Ring++ (`rnxc`)**, from the verification vehicle described in
GK3's addendum; Scene 0 and the refusal need no device. Zig:
`gpu_wgsl.zig` 4 of 5 (the three GK6 tests pass; the fragment-stage test
fails on the committed file too — a drift of GR4b's, recorded for the
graphics desk, not touched here), `gpu_verify.zig` 4. Gates re-run under
`rnxc` after the change: `gpu_verify` 36, `gpu_declarative` 20,
`gpu_foundry` 27, `gpu_foundry_matmul` 18, `gpu_calibration_shaped` 40.

**Why.** GK0 compares a candidate with a REFERENCE KERNEL on the device.
A kernel a user writes through `stzKernelMaker` had no reference of its
own, so the checker could not check it without a Zig twin — and the
puzzles (KP1) need exactly that: a learner's kernel graded against what
the description says, with the learner's mistakes named.

**What shipped, and where it lives.** In `gpu_wgsl.zig`, beside the
transpiler and sharing its directive parser (`parseDecl`, extracted; a
Zig test holds the emitted WGSL byte-identical to the edge proof's) and
its whitelist: an INTERPRETER. `stz_gpu_spec_compile` turns the same
spec into a postfix program over fixed buffers — zero allocation, Zig
builtins and `std.math` only, so the wasm group carries it and a browser
can grade without a device — and `stz_gpu_spec_eval` runs it element by
element in f32 with WGSL's meanings: `%` is the truncated remainder,
`round` goes to even, and the vector-only names the whitelist carries
for the fragment stage (`dot`, `cross`, `normalize`, `reflect`, `vecN`)
are refused by name as not elementwise, where the transpiler would have
let WGSL fail later. The program counts its operations per element,
which is the FLOP count GK3's compute ceiling reads: **a user kernel
declares its own work by what it says.** Decided here: the interpreter
is Zig native in the same module as the transpiler (one grammar, two
readers held to agree by a test over a refusal corpus), and the wasm
group gets it for free; a JavaScript twin would have been a third reader.

In `gpu_verify.zig`: `stz_gpu_verify_spec` reads the candidate's inputs
back from the device, evaluates the spec on the host (timed; reported as
the reference's time, and `speedup` is cpu over candidate), fills the
candidate's output buffer with NaN **including a margin of 256 floats
after the region**, dispatches, and scans the margin before comparing
the region; a non-NaN there is `write-outside` with the index named.
What the margin catches and what it cannot, stated: a store to index n
or beyond — the missing or wrong bounds guard, the learner's mistake,
up to a whole workgroup past n; NOT a store below 0 (u32 cannot say it,
and WGSL's robust access drops the wrapped index outside the binding),
NOT a store inside the region at the wrong index (a value mismatch, the
compare's). A front margin is unreachable for the same reason — the
binding is the kernel's whole world — so there is one margin, at the
end, inside the binding. A **shape assert** before any dispatch: every
input must hold n floats and the output n plus the margin, or the call
refuses with both numbers (`stz_gpu_verify_error`). Face: `stzGpu.VerifySpec`
/ `VerifySpecWith`, `stzKernelMaker.EvaluateOn` (the CPU reference as a
list, no device) and `OperationsPerElement`.

**The learner's kernel found a crash on the way, and it is a refusal
now.** A kernel that never reads the params uniform — the unguarded
kernel is one — gets an auto layout WITHOUT binding 1; the layer's bind
group then carries an entry the layout lacks, `wgpuDeviceCreateBindGroup`
returns a non-null INVALID object, and the submit **panicked the
process**. `dispatchInternal` now flushes after creating the bind group
and refuses with wgpu's own message ("Number of bindings in bind group
descriptor (4) does not match ... (3)"), status 5; Scene 6b asserts the
process lives. The guard's unguarded fixture keeps `p` alive with a zero
term so it tests the missing guard alone. For KP0: a kernel the grammar
emits must always reference `p`, whatever the learner writes.

**Measured, RTX 3050, Ring++, on battery:** the description `@c = @a * 2`
over 4,096 elements verifies itself in 0.45-1.24 ms on the device against
0.12-0.15 ms of interpreter on the CPU — at this size the GPU is 3-10x
SLOWER than the reference, which is the submit floor speaking and the
first thing a puzzle should teach. The wrong operator is named at
element 2 by 4,095; the cheat is exact at the visible shape and off by
8,190 at the hidden one; `sqrt` of a negative is a mismatch at element 1
on both sides (NaN agrees with nothing); the unguarded kernel at n = 4,000
is `write-outside` at 4,001; the guarded sibling verifies.

Next: **KP0**, the grammar grows one admission at a time (an index in
the body, the learner's own bounds guard, the stencil, the reduction),
each with its probe, its refusal message and its edge-proof case; the
interpreter here is the reference every admission is checked against.

---

## KP0 STATUS — shipped 2026-10-24: the grammar grows, one admission at a time

Guard: `base/test/gpu/gpu_grammar_narrated.ring` — **43 asserts green
under Ring++ (`rnxc`)**; Scene 0 (the four admissions on the CPU and the
seven refusals) needs no device. Zig: `gpu_wgsl.zig` 6 of 7 (two KP0
tests added; the fragment-stage failure is GR4b's, recorded at GK6),
`gpu_verify.zig` 5 (the masked compare added). Gates re-run under `rnxc`
after the change: `gpu_spec_reference` 34, `gpu_declarative` 20,
`gpu_verify` 36. **The edge proof: 17 of 17 in the browser pane**,
five cases where there was one — and the native results came from the
RTX 3050 under `rnxc` while the browser ran the byte-identical WGSL on
the **Intel iGPU** (`intel gen-12lp`): two GPUs, two runtimes, the same
numbers to the bit. That is KP1's premise, shown before KP1.

**Why.** The elementwise grammar covered map, zip and a scalar
(Modular's puzzles 1-3). KP2's eight puzzles need, in order, an element
index the body can read, a bounds guard the learner writes — or omits,
and sees the margin catch — a stencil over neighbours, and a two-pass
reduction. Each is a grammar decision with a kernel-shape consequence,
made here one at a time, each refused or admitted with a probe.

**The four admissions, in both readers from one parser:**

| admission | the spec | the WGSL | the interpreter | what it refuses |
|---|---|---|---|---|
| the index | `@i` in a body | `f32(i)` | the element number | a vector or scalar named `i` ("the element index; it cannot be declared") |
| the guard | `guard { @i < n - 1 }`, or `guard none` | `if (f32(i) < f32(p.n) - 1) {`; or no `if` at all; and in both cases **`_ = p.n;`** so the params uniform stays bound (GK6's crash) | an element the guard refuses is left UNWRITTEN, and the checker's compare wants it untouched in the candidate (the written mask) | `=` alone ("use '==' to compare"), a comparison or `and`/`or` in a body ("belongs to the guard line"), two guard lines |
| the stencil | `@a[@i - 1]` | a reader per input, `rd_a(k : i32)`, **0.0 outside the input's own range** (`arrayLength`), so an unguarded edge is a wrong value the compare names, not undefined behaviour | the same rule, bounded by each input's own length (inputs may be longer than n now, never shorter) | `[` after anything but a vector name; a missing `]` |
| the sum | `sum(k, 0, 16, @a[@i * 16 + k])` | a prelude: `var acc0 : f32 = 0.0; for (var k_k : i32 = ...) { acc0 = acc0 + (...); }` and the body reads `acc0` | a loop frame; the operations EXECUTED are counted, loops included (`stz_gpu_spec_eval_flops`), and that is the FLOP count the compute ceiling reads for a spec | a sum inside a sum ("one level; shared memory is KP3's"), three arguments, a variable that is already a name |

`n` is the element count, a bare name in a body or a guard; `i` and `n`
are reserved. The default form — no guard line — emits the kernel every
spec had before KP0, byte for byte (the GK6 test holds it). A kernel
with a guard line always references `p`, whatever the learner writes;
that is the rule GK6 set and KP0 keeps.

**Face:** `stzKernelMaker.Guard('{ ... }')`, `WithoutGuard()`,
`GuardText()`, `EvaluateOnWith(bindings, [:n = ...])` (ragged inputs,
the output count chosen), `OperationsExecuted()`; `stzGpu.VerifySpecWith(...,
[:n = ...])` (the hidden input is each input's reversed tail scaled by
the hidden shape's ratio), `RunWith` / `RunQWith` with `:n`. An input
shorter than n is refused by name in `Run` and `VerifySpec`; longer is
admitted.

**The two-pass reduction without workgroup memory**, measured on the
device under Ring++: 1,024 partials of 16 over 16,384 inputs verify
themselves at the visible and the hidden shape; a partial one term short
is a mismatch; the fold of the partials into one element agrees with the
CPU's sum within f32 and verifies itself at n = 1. The grammar stops at
the reduction in this charge, as the launch prompt's default said;
workgroup memory and a barrier are KP3's admission, and the sum's
refusal message says so.

**What the admissions taught, for KP2's texts:** a guard too TIGHT is a
mismatch at the first element the task writes and the learner does not;
a guard DROPPED is `write-outside` at n + 1 when n is not a multiple of
256 — the two mistakes are told apart by the checker, and the puzzle
can say which; an unguarded stencil edge is a mismatch at element 1,
the edge the task leaves; and at 4,096 elements the GPU is slower than
the interpreter, which is the first lesson of all.

**Edge proof, run 2026-10-24 in the desktop app's browser pane** on the
Intel iGPU (the native half on the RTX 3050 under `rnxc`): axpby,
index, guard, stencil, partials — each byte-identical WGSL and exactly
equal results (17 checks). `gen_fixture.ring` emits the five cases
(inputs of their own lengths, the ordered scalars, n, the native
results); `edge_proof.html` loops over them; an element both sides leave
unwritten reads 0 on both (WebGPU zero-fills a new buffer). `stz.wasm`
and `fixture.js` are generated and untracked, as before.

Next: **KP1**, the puzzle form and its two runners from one spec — the
desktop runner through the Ring face, the browser runner as a page in
this proof's shape with the interpreter's verdict as the grader.

---

## KP1 STATUS — shipped 2026-10-24: the puzzle form, and two runners from one description

Guard: `base/test/gpu/gpu_puzzle_narrated.ring` — **30 asserts green under
Ring++ (`rnxc`)**, from the vehicle with main's Learning System laid over
the lineage (its eleven files carry no Rule A site of their own). Scenes 0
and 1 need no device. Gates re-run under `rnxc`: `gpu_grammar` 43,
`gpu_spec_reference` 34, `gpu_declarative` 20, `gpu_verify` 36. Zig
`gpu_wgsl.zig` 7 of 8 (one KP1 test added; the eighth is GR4b's fragment
test). **The browser runner, driven in the desktop app's browser pane on
the Intel iGPU:** the starter answers *waiting for your implementation*,
the right answer *verified* (2.9 ms on the device), the wrong operator
*mismatch at element 2*, the unknown function *refused: unknown name
'foo'* — the desktop face's words, letter for letter.

**The form.** A puzzle is an exercise of the Learning System in the
System's own shape — `exercise.zknw`, `task.<lang>.md` in en, fr, ar and
ha (fr, ar and ha marked as provisional translations awaiting a native
reader), `promise.ring`, `right/`, `wrong/` — plus two texts the grammar
reads, `reference.txt` (the description the kernel must match) and
`starter.txt` (where the learner begins; no body, so the puzzle starts
red), and data facts both runners build the same vectors from:
`kp-01 | elements | 4000`, `kp-01 | input-a | ramp`, with the recipes
ramp, half, mod13, ones and tenths, `scalar-<name> | value` and
`input-length-<name> | m` for an input longer than n. **The promise is
one word**, the checker's verdict; the learner's program builds a maker
and prints what `StzKernelPuzzleQ("kp-01").Grade(k)` says of it. The
course `kernel-puzzles` is declared in `program.zknw` and opens through
the program; its first puzzle **proves itself through the System's own
checker**, every wrong answer refused and every right one accepted, by
running them under `rnxc` (the checker spawns the executable it runs in).

**The desktop runner** is `stzKernelPuzzle` in `base/gpu/`, a face over
the checker: `Grade` takes a maker or the description text
(`StzKernelMakerFromSpec` turns a text into a maker, and `Spec()` turns
it back), refuses the starter and an empty body with *waiting for your
implementation*, a description the grammar refuses with *refused: ...*,
inputs or scalars not the task's — or not in the task's order, since one
params block serves the kernel and the interpreter alike — by naming
yours and the task's, and otherwise runs `VerifySpecWith` at n with the
NaN margin: *verified*, *mismatch at element K*, *mismatch-hidden at
element K*, *write-outside at element K*, *impossible*. `GradeOnCpu` is
the interpreter alone at both shapes, in the same words — the browser's
path when WebGPU is missing — and the guard holds the two paths to the
same verdicts; the one thing it cannot see is a store past the region.

**The browser runner** is `courses/kernel-puzzles/runner/puzzle.html`
beside `stz.wasm`, in the edge proof's shape: it fetches the puzzle's
facts, reference, starter and task, builds the data from the same
recipes, transpiles the learner's text with the wasm transpiler, computes
the reference with the wasm INTERPRETER (the native checker's, compiled;
`stz_gpu_spec_compile`, `_eval_masked`, `_eval_flops` joined the gpu
group), runs the kernel on the browser's WebGPU into a NaN-filled buffer
with the 256-float margin, at the visible shape and the hidden one built
by the face's rule (odd, five sevenths, the reversed tail scaled), and
judges with the written mask in the face's words. No server grades
anything, nothing is stored, and the page ran on the laptop's integrated
GPU with no NVIDIA driver in the picture. Open it with `?p=<id>&lang=<l>`.

**Found on the way, and fixed in the grammar:** the cheat kernel
`@c = @i * 2` reads none of its inputs, so wgpu's auto layout dropped the
input binding and the layer's bind group was refused (GK6's finding, on
an INPUT this time; the device path said *refused* where the CPU path
said *mismatch-hidden*). The transpiler now keeps every declared input
bound with a phony `_ = arrayLength(&v_a);` when the body never reads it;
a kernel that reads all its inputs is emitted exactly as before. And the
knowledge graph keeps one edge per node pair, so a course manifest names
an exercise once: `has-exercise`, not also `has-puzzle-N`.

Not done, and said: the puzzle is one (the map); KP2 writes the eight.
The browser runner ran under the desk's hand, not yet a person's — the
named person is KP2's PERCEPTGATE. The System's reader does not embed the
page (cells in the browser are ZD1, another desk's); the page stands alone,
as the launch prompt allowed.

Next: **KP2**, the eight puzzles from the map to the reduction, each with
its text in the course's languages, its right and wrong siblings and the
sentence on what the GPU did differently from a loop; then a named person
works two of them in the browser, one failing first.

---

## KP2 STATUS — DONE 2026-10-27: the eight puzzles, from the map to the reduction; perceived by the author, twice

Guard: `base/test/gpu/gpu_puzzle_narrated.ring` — **95 asserts green under
Ring++ (`rnxc`)**, nine minutes on battery (most of it the checker spawning 35 learner programs): for every puzzle the starter waits, the
reference verifies itself on the CPU, the task reads in four languages and
ends with what the GPU did differently from a loop; every right and wrong
description in the table below gets its words on the device; `GradeOnCpu`
says the same words as `Grade` for all 27 value cases; and every exercise
PROVES ITSELF through the System's own checker, three wrong refused and
two right accepted, by running its programs under `rnxc`.

**The eight**, in the order the launch prompt gave, each a folder in the
exercise shape with its facts, reference, starter, promise (`verified`),
two right and three wrong programs, and a task in en, fr, ar and ha (fr,
ar, ha marked provisional):

| puzzle | the kernel | data | the wrong answers the checker names |
|---|---|---|---|
| kp-01 map | `@c = @a * 2` | ramp, n 4,000 | starter waits; `* 3` mismatch at 2; `@i * 2` (the cheat) mismatch-hidden at 1 |
| kp-02 zip | `@c = @a + @b` | ramp, half | `-` mismatch at 2; `@a + @a` (ignores b) mismatch at 2 |
| kp-03 scalar | `@c = alpha * @a` | ramp, alpha 2.5 | `@a * 2` (hard-coded) mismatch at 2; `alpha + @a` mismatch at 1 |
| kp-04 index | `@c = @a + @i` | half | `+ 1` (off by one) mismatch at 1; `@i` alone mismatch at 2 |
| kp-05 the guard | `guard { @i < n }`, `@c = @a * 2` | ramp, n 4,000 (16 groups, 96 idle threads) | `guard none` **write-outside at 4001**; `guard { @i < n - 1 }` mismatch at 4000; the engine's own guard is a right answer too |
| kp-06 stencil | `guard { @i > 0 and @i < n - 1 }`, `(@a[@i-1] + @a + @a[@i+1]) / 3` | mod13 | no edge guard: mismatch at 1 (the edge the task leaves); forgets itself: mismatch at 2 |
| kp-07 reduction, pass 1 | `sum(k, 0, 16, @a[@i * 16 + k])` | tenths, 16,384 in, 1,024 out | one short: mismatch at 1; windows sliding by 1: mismatch at 2 |
| kp-08 reduction, the fold | `sum(k, 0, m, @c[k])` | tenths, 1,024 in (as long as `m` says), 1 out | `m - 1`: mismatch at 1; `@c` (copies the first): mismatch at 1 |

kp-05 carries `needs | device`: its margin mistake is the one thing the
CPU path cannot see, and a machine without a GPU will not prove that
exercise. The runner lists the eight from the course manifest and links
the four languages.

**Found on the way.** The knowledge graph keeps one edge per node pair,
and a puzzle whose input length and scalar are both 1,024 cannot say so
twice: an `input-length-<name>` fact may now NAME a scalar ("as long as
`m` says"), resolved by both runners. And Ring++ raises on `0 + "m"`
where Ring answered 0, so a numeric test looks at the first character.

**Spot-checked in the desktop app's browser pane on the Intel iGPU** before
the page was handed over: kp-05 answers *write-outside at element 4001*,
*mismatch at element 4000* and *verified* for the three guards; kp-08
answers *verified* for the fold (10.8 ms, 2,048 operations in the
reference) and *mismatch at element 1* for the copy, in French too.

**PERCEPTGATE — met on 2026-10-27, and the verdict was NO.** The author,
Mansour Ayouni, opened the page, pressed *Run the kernel* on the untouched
starter and reported, in their words: *"When i click 'Run the kernel' i get
nothing"*, then, with the run now stamped on the page and the verdict
unchanged: *"i don't understand what happens!"*. The grader was right
both times (the starter has no body line, so the verdict was *waiting for
your implementation* before and after the click) and the page was wrong
both times: nothing on it said what the person's move was. The task
explained the kernel; nothing explained the page. Every counter above was
green while the first reader could not start.

**What the page does now, 2026-10-27.** Every click prints *run N at
HH:MM:SS* before the verdict and the button is disabled while the device
works, so the same verdict twice is still seen to be new. A *Your move*
block sits directly above the box (en, fr, ar; ha falls back to en): the
box holds the description, the lines there name the inputs and output,
add the body line and, where asked, the guard line, press Run, the verdict
names the first element that differs. Under it, one button per named
mistake of the exercise (`has-mistake` facts, added to each
`exercise.zknw`; the page reads the `wrong/` sibling's Ring back into the
description's lines and keeps its head comment as the note) fills the box
and runs at once, so the learner sees a verdict in one click before
writing a line; and *I give up -- show the answer* puts the reference in
the box. The task's small markdown renders instead of showing raw. Found
on the way: a checkout turns the task files into CRLF and a JavaScript
`.` does not match the carriage return, so a line-anchored regex over
fetched text fails silently on Windows; the renderer strips `
` first.

Run end to end on the author's behalf, by real keystrokes and clicks in
the desktop app's browser pane on the Intel iGPU, 2026-10-27 22:11-22:16:
kp-05 *write-outside at element 4001* (guard none), *mismatch at element
4000* (`@i < n - 1`), *verified* (`@i < n`, 3.2 ms); kp-08 *mismatch at
element 1* (the copy), *verified* (the fold, 8.0 ms, 2,048 operations in
the reference); the two mistake buttons of kp-05 give their two verdicts
with their notes; the answer link verifies. The desktop face on rnxc with
the new facts: starter waits, reference verifies on the CPU, a mistake
named, for kp-01/05/08 (12/12). The page is served from the course folder
(`python -m http.server 8780`, from `courses/kernel-puzzles`) at
`runner/puzzle.html?p=kp-05`.

**PERCEPTGATE — met a second time, 2026-10-27 22:25, and the verdict was YES.**
Mansour Ayouni reloaded the repaired page and said, in their words: *"I
reloaded the page, the Your-move block and the mistake buttons told me
what to do."* That sentence closes the rung: the eight puzzles are built,
gated (95/95 on rnxc), and a named person has used the page and said what
it did. Both verdicts stay in this record, the NO and the YES, because the
first is what the counters could not see.

Next: the author's two puzzles and their verdict, written here with their
name; then **KP3** (gated: workgroup memory and a barrier for the tiled
matmul, softmax and the bandwidth puzzle that reads GK3's roofline) or
**GK5** (f16 weights on the device), whichever the author names.

## KP3 STATUS — built 2026-10-27: the group's memory, puzzles 9 to 12, the roofline in the page; the person is owed

**What the grammar admits now.** KP0 stopped at the reduction one thread
can do. KP3 admits what a tiled matrix product needs, each in the
transpiler and the interpreter through one parser, refused in the same
words by both:

| line | what it is | the kernel's side |
|---|---|---|
| `shared t 256` | an array of floats in the group's memory, 1 to 1,024, 16 KB in all | `var<workgroup>`, zeroed by the kernel itself at entry |
| `stage { @t[@l] = @a }` | one write per thread, then a barrier | the write under a bounds test, `workgroupBarrier()` after |
| `reduce t sum` (`max`, `min`) | the halving tree into slot 0, a barrier per step | a uniform loop over `s_ = size / 2 ...` |
| `tiles t { k / 16 }` | the stages and the accumulate after it repeat; the count over scalars, `n` and numbers only, so every thread reaches every barrier | a `for` over `t_t` |
| `accumulate { @acc = ... }` | a thread's running value across turns, read by the body | `var acc`, a barrier after |
| `width w` | the output a matrix in 16 x 16 tiles; `@row`, `@col`, `@lx`, `@ly` | the group's tile from `wid.x`, the cell from `l` |

`@l` and `@g` (the thread's place in its group, the group's number) are
readable anywhere. In a stage or an accumulate, `@a` alone is a bounded
read, because those lines run for every thread of the group, the ones
past the input included. The six refusals: a stage that reads the array
it writes ("the threads would race"); a tiles count that reads anything
per thread; `@row` without a width line; a shared array read without a
slot; a reduce over a size that is not a power of two up to 256; an
accumulate outside a tiles loop. The interpreter runs a **group at a time**:
every item of the schedule over all 256 threads before the next starts,
which is what a barrier promises. A spec with none of these lines emits the
same WGSL as before, byte for byte (the GK6 test holds it).

**Measured, RTX 3050 through wgpu-native under rnxc, 2026-10-27:**

| kernel | verdict | note |
|---|---|---|
| each group of 4,096 reversed through a stage | verified at the visible shape and the derived hidden one (2,925, last group partial) | 0.0041 ms on the GPU clock |
| a kernel reading shared memory no stage wrote | mismatch at element 1 | **passed the visible shape before the kernel zeroed its own memory** |
| a reduce, the sum of each group | verified | |
| softmax of 16 rows of 256 | verified; the device's `exp` within **0.47 billionths** of the CPU's at band 0 | without the max: 0.93 billionths, verified at the default band |
| tiled product, 32 x 64 times 64 x 48, hidden 16 x 80 times 80 x 32 | verified | 0.0110 ms on the GPU clock |
| the plain loop, same product | verified | 0.0174 ms |
| one tile only | mismatch at element 1 | |

**Three defects found on the way, one of them older than this rung.**

- **wgpu-native did not zero workgroup memory.** WGSL promises it. A
  kernel with no stage read the previous kernel's values on the 3050 and
  passed the visible shape; only the hidden shape caught it. The kernel now
  zeroes its shared arrays itself before the schedule, so every runtime means
  what the interpreter means. The guard assertion runs the filling kernel
  first, then the one that reads without a stage.
- **The browser runner wrote at address 0 since KP1.** The wasm's
  marshalling heap was a static 8 KiB buffer that answered 0 when full, and
  the page never checked. A puzzle with more than 8 KiB of data put its
  inputs and its output at address 0, one over the other. One-input puzzles
  passed by luck; puzzle 2, with two inputs, read `b` where `a` was owed and
  would have refused its own reference in a browser. KP2's spot checks
  (puzzles 5 and 8) never touched it.
  The heap is now a 64 KiB arena after the module's image plus pages it grows
  itself (never pages a page claimed: `stz-music.js` grows a region above the
  module and relies on that), and the page refuses a failed allocation. All
  twelve puzzles were then run in the pane: every reference verified, every
  mistake named as on the desktop.
- **"impossible" under contention.** The System's checker runs four learner
  programs side by side, each measuring its floors while the others had the
  device. A floor read in that slow state made puzzle 12's SAXPY "impossible"
  in 2 of 8 self-proofs. GK3 already re-measured the compute peak before a
  refusal by compute; the checker now folds a fresh round of the bus floors
  in (twice at most, the faster reading kept) before any refusal from a real
  dispatch. 0 of 8 after. The judge on fabricated numbers is unchanged.

**The puzzles**, chapter five ("the group's memory") and chapter six ("the
roofline") of the course, each with facts, reference, starter, promise
`verified`, two right and three wrong programs, and tasks in en, fr, ar, ha
(the last three marked provisional) ending with what the GPU did differently
from a loop:

| puzzle | reference | the mistakes, as both runners name them |
|---|---|---|
| kp-09 each group reversed | `stage { @t[@l] = @a }`, `@c = @t[255 - @l]` | no stage: mismatch at 1; the whole vector reversed: mismatch at 1 |
| kp-10 tiled product | two stages per turn, `accumulate`, `@c = @acc` | one tile: mismatch at 1; b's tile along the wrong axis: mismatch at 1; the plain loop is the second right answer |
| kp-11 softmax per row | `reduce m max`, `reduce s sum`, divide | forgets to divide: mismatch at 1; divides by `@s[@l]`: mismatch at 2; without the max is right here |
| kp-12 SAXPY under the roofs | `@c = alpha * @a + @b` | forgets alpha: mismatch at 2; alpha on both: mismatch at 2 |

A puzzle may now declare its hidden shape whole (`hidden-elements`,
`hidden-scalar-NAME`, `hidden-input-length-NAME`; the hidden inputs are the
same recipes at those lengths, reversed): a matrix's hidden shape is another
matrix, not a reversed tail. `VerifySpecWith` takes `:hidden`, and the
bridge a twelfth argument for the hidden shape's own scalars. A `band` fact
sets the compare's allowance, and a `mod7` recipe joins the five.

**The roofline (puzzle 12).** GK3's copy and peak kernels moved to
`gpu_wgsl.zig`, so `stz.wasm` carries them (`stz_gpu_roof_wgsl`,
`stz_gpu_roof_number`) and a browser measures its own adapter's roofs with
the same texts. The desktop face's `Roofline()` times the learner's kernel on
4,194,304 elements filled on the device (no list crosses) with the floor's
own instrument, the best dispatch and sync on the wall clock; the page times
batches of ten dispatches per submission, divided by ten, for the roofs and
the kernel alike. One dispatch timed with its wait read SAXPY at 174% of the
copy roof in the browser; the wait resolves late by a millisecond or more.
Bytes and operations are the essential ones, each input read once and the
output written once, so a kernel that rereads memory shows a smaller share.

| runner, adapter | SAXPY | SAXPY with 64 extra reads | SAXPY again |
|---|---|---|---|
| desktop face, RTX 3050 | 0.53 ms, 1.04 of the copy roof | 0.97 ms, 0.57 | 0.53 ms, 1.05 |
| browser page, Intel iGPU | 0.93 ms, 97% of 55.9 GB/s | 2.75 ms, 28% of 64.5 GB/s | 1.03 ms, 99% of 49.3 GB/s |

Both read "the bandwidth roof is the lower one" (0.17 operations per byte).
SAXPY at or a little over the copy roof is within the floor's own noise:
the copy floor is itself a best-of on the same wall clock.

**Edge proof: 26/26** in the desktop app's browser pane on the Intel iGPU,
eight cases, three new (`shared-reverse`, `reduce`, `tiled-matmul`): the wasm
emits byte-identical WGSL and the browser's results equal the 3050's exactly.

**Guard:** `base/test/gpu/gpu_shared_narrated.ring`, 58 assertions, run
under `rnxc` from the vehicle, two minutes, most of it the System's checker
proving four exercises by running 20 programs. The power source read AC
(Windows battery status 2) at 23:41.

**PERCEPTGATE — delegated, not met.** Asked to work puzzle 10, the author,
Mansour Ayouni, answered *"do it by yourself and continue"* (2026-10-28). So
the agent worked it in the desktop app's browser pane on the Intel iGPU, by
real clicks and keystrokes, as a learner would, at 00:52:

| step | what was typed or pressed | verdict |
|---|---|---|
| 1 | Run, on the untouched starter | waiting for your implementation, with the body-line hint |
| 2 | the "one tile only" mistake button | mismatch at element 1, with its note |
| 3 | a first attempt reading `b`'s tile across, `@tb[@lx * 16 + j]` | mismatch at element 1 (2.0 ms) |
| 4 | the fix, `@tb[j * 16 + @lx]`, the whole description retyped | **verified** (7.8 ms, 878,598 operations in the reference) |

That is an instrument's reading by the author's choice, not a person's
perception, and the perception rule refuses DONE on instrumental evidence
alone. **KP3 is BUILT, worked end to end by the agent, unperceived by a
person.** It becomes DONE when a person works a puzzle of 9 to 12 and says
what the page did.

## GK5 STATUS — shipped 2026-10-28: f16 weights on the device, measured; kept beside f32, off by default

**What the device asks for now.** `gpu.zig` requests `shader-f16` when the
adapter offers it, beside the timestamps; a device that refuses is asked
again without f16, then without the second clock. Subgroups are noted,
never requested. Measured under `rnxc` through wgpu-native 29.0.1.1:

| adapter | shader-f16 | subgroups | timestamps |
|---|---|---|---|
| NVIDIA GeForce RTX 3050 6GB Laptop GPU | offered, granted | not offered | granted |
| Intel(R) Graphics (gen-12lp) | offered, granted | not offered | granted |

Both grant it, so there is no routing fact for the calibration store.

**The template.** `gpu_ops.mmSourceW(v, bias, wf16)`: with `wf16` the
module opens with `enable f16;`, B (the weights) is `array<f16>` and each
read is widened, `f32(b[...])`; the accumulation stays f32. `mmSource` is
`mmSourceW(..., false)` and its text is byte-identical to before (a Zig
test holds every variant to that). The neural DLL builds its own device
from the same `gpu.zig`, so the request reaches the backbone too.

**The kernels, A B A B** (`StzEngineGpuFoundryMatmulF16`: the same A and
the same values of B, f32 and f16 alternated four times, best of 7 per
turn, on both clocks; both results against an f64 product):

| shape (130 tokens) | variant | f32 GPU ms | f16 GPU ms | f32 / f16 | error f32 | error f16 |
|---|---|---|---|---|---|---|
| 130 x 384 x 384 | generic | 0.203 | 0.202 | 1.004 | 1.3e-6 | 3.3e-4 |
| 130 x 384 x 1536 | generic | 0.486 | 0.477 | 1.020 | 1.4e-6 | 3.5e-4 |
| 130 x 1536 x 384 | generic | 0.507 | 0.495 | 1.023 | 5.3e-6 | 6.8e-4 |
| 130 x 384 x 384 | reg4 | 0.0563 | 0.0529 | 1.064 | 1.3e-6 | 3.3e-4 |
| 130 x 384 x 1536 | reg4 | 0.163 | 0.159 | 1.026 | 1.4e-6 | 3.5e-4 |
| 130 x 1536 x 384 | reg4 | 0.213 | 0.208 | 1.025 | 5.3e-6 | 6.8e-4 |

Errors are absolute, against outputs up to 1.8-3.6 in size. On the Intel
iGPU, reg4 at 130 x 384 x 1536: 1.87 ms against 1.84, 1.02 on the GPU
clock and 0.98 on the wall.

**The backbone** (MiniLM, `neural_backbone_set_weights_f16`, residency
keyed by the weight AND its type so both copies live side by side):

- the weight matrices bound per forward: **42,467,328 bytes in f32,
  21,233,664 in f16**, exactly half;
- agreement, against the CPU forward with the backbone's gate pushed out of
  reach: at 158 tokens one minus the cosine is 8.49e-5 (f32) and 8.48e-5
  (f16); at 68 tokens 1.73e-4 and 1.74e-4. f16 is as close to the CPU as f32
  is; the two GPU paths differ by **2.3e-7** and **1.5e-7**, and by at most
  1.1e-4 in any coordinate of the unit vector;
- the forward, reg4 winners, six turns with the order alternated
  (f32 / f16): 1.007, 1.008, 1.077, 1.045, 1.000, 1.030. **About 2% for
  f16, never slower.** The control, the CPU forward timed before and after
  each turn, drifted from 79 to 44 ms over the same minutes, so only the
  paired ratio means anything; on the generic kernels the ratios scatter
  0.90-1.35 with the same drift.

**The reading.** At 130 tokens the weights are reused by every row tile
of A and the matmuls are not waiting on the bytes, so halving them buys
2-6% per kernel and about 2% per forward. What f16 buys is VRAM: half the
resident weights, which is what decides whether a larger encoder fits on a
6 GB card. **f16 accumulation did not earn its question** and is not
built. The f16 path stays beside the f32 one, **off by default**; nothing
that ships changes unless asked.

**Found on the way.** `StzEngineNeuralEmbed` is routed to the resident
backbone above the gate's token count, so a "CPU reference" taken through
it at 130 tokens is the GPU's own output: the first measurement read
`1 - cos(cpu, f32) = 0` and the control "CPU forward" sped up with the reg4
table. The guard and the probe push the gate out of reach for the CPU half.
The vehicle had no model: the MiniLM file was copied in and its digest,
recorded by another desk in `_wti_pub`'s `SHA256SUMS`, was checked against
the copy (`sha256sum -c`: OK) before being written beside it.

**Guard:** `base/test/gpu/gpu_f16_narrated.ring`, **22/22 under `rnxc`**,
1.5 s, bands about ten times the measured differences. **Not run:**
`base/test/neural/neural_backbone_narrated.ring` reads `nPass` bare in its
`chk()`, which Rule A refuses; its migration is the neural desk's. The f16
guard's backbone scene covers the default f32 path's agreement with the CPU.

## GK4 STATUS — closed 2026-10-28: the fusible epilogue, counted, timed, and REMOVED; tanh and the dispatch count stay

**What was built and measured** (commit `92831a80c`, kept in history so the
number can be re-earned): `stz_gpu_wgsl_epilogue` turned a one-value
KernelMaker spec into a matmul store's epilogue, `gpu_ops` applied it after
the bias in every variant's store (f32 or f16 weights), and the resident
backbone could apply GELU in the up-projection's store instead of a GELU
pass. The spec says what the backbone's GELU kernel says, which needed
`tanh` in the grammar:

    in x
    out y
    body { @y = 0.5 * @x * (1 + tanh(0.7978845608 * @x * (1 + 0.044715 * @x * @x))) }

**Measured on MiniLM, RTX 3050, reg4 winners, under `rnxc`, 2026-10-28:**

| measure | GELU as its own pass | GELU in the store |
|---|---|---|
| dispatches per forward (a count) | **62** | **56** |
| embedding, 1 - cos between the two | — | 0 to nine places, at 158 and 68 tokens |
| forward, twelve turns, order alternated | | fused faster in 7 of 12; unfused / fused from 0.969 to 1.079, median about 1.01 |

The control, the CPU forward timed before and after each turn, moved by up
to 60% inside a turn. The count confirms one dispatch fewer per layer; the
clock does not confirm a gain: 7 of 12 is what chance gives, and six GELU
passes over 130 x 1,536 elements are about a hundred microseconds of an
8 ms forward. **By the charge's rule the fused form is removed** and the
number recorded here. It is not kept because it is elegant.

**The other two targets, refused by structure, not by measurement:**

- **add_ln** is LayerNorm over a whole row of 384, while a matmul tile
  holds 16 columns (64 in reg4): no store of one tile sees the row's mean
  and variance. Only its residual add could ride the store, and the add is
  already inside the LayerNorm kernel, so the count would not move.
- **softmax's third dispatch** scales by the reciprocal of a total that
  depends on every workgroup's partial sum; there is no matmul before it
  to carry an epilogue, and it cannot fold into its own exponential pass
  without a second pass over the whole input. It stays three dispatches.

**What stays.** `tanh` in the grammar's functions, in the transpiler and
the interpreter (`std.math.tanh`; a Zig test holds the two to WGSL's
meaning), and `neural_backbone_dispatches()` with its Ring binding
`StzEngineNeuralBackboneDispatches`, a count of the last forward's
dispatches that is immune to ambient load. The f16 guard asserts it: 62.

**The reading, for whoever proposes the next fusion here.** The backbone
is at the point GK2c named: after the register-blocked matmuls, no single
pass is a large share of the forward, so a fusion that removes one pass per
layer moves the forward by about the clock's noise on this machine. A
fusion worth keeping would have to remove a pass that is a large share,
and on MiniLM at 130 tokens none is.

## GK1 FOLLOW-UP — 2026-10-28: an unmeasured class between measured ones is interpolated, not sent to the flat line

**What was wrong.** `gpu_calibration_shaped_narrated` failed under `rnxc` on
every run in KP3's gate: its off-class hidden shape, 64 wide by 2,000 rows,
measured **1.7-1.9x faster on the GPU** and was routed to the CPU. The flat
line is one number on n*d; when the 16-wide column of the grid never
crossed, it went beyond the whole ladder and every unmeasured class went to
the CPU, though the shape sits between a 16-wide column losing at 0.3-0.8
and a 256-wide one winning at 3.4-9.3. GK1 had already measured that the
crossover moves 4x with the width; the fallback was still one-dimensional.

**What the route does now** (`gpu.zig`, `bracketedLog2`): a measured class
decides as before; an UNMEASURED class first looks for a bracket -- its own
width column interpolated to its corpus size, else the nearest measured
widths below and above it, each read at its corpus size -- and decides by
the log-log interpolated ratio against the 1.3 margin. It never
extrapolates: without a bracket the flat line decides, as before. The
authority order holds: with the flat line set explicitly, only explicit
classes take part. For the grid in question the estimate is about 1.6;
measured, 1.7-1.9.

**Measured under `rnxc`, RTX 3050:** `gpu_calibration_shaped_narrated`
**40/40 three runs in a row** (the off-class shape predicted GPU, measured
GPU at 2.40 and 1.94, marginal at 1.15 once, which the guard allows);
`gpu_seams` 17, `gpu_calibration` 10, `gpu_lifecycle` 62, `gpu_ops` 37,
`gpu_f16` 23. A Zig test holds the route to the interpolation, the losing
column, and both sides of the flat line beyond the ladder.

## GT0 STATUS — shipped 2026-10-28: the random-kernel fuzz, and the four defects its first run found

**What it is.** `engine/src/gpu_fuzz.zig` generates descriptions from the
grammar in six kinds (a map; a map under a guard; neighbour reads over
longer inputs; a bounded sum; shared arrays with stages and reductions; the
tiles loop, 2-D and 1-D), runs each through BOTH readers' admission, on the
device, and through the interpreter, and counts. Case `index` of run `seed`
is the same description on every machine (`StzEngineGpuFuzzCase`), so a
defect is reproduced from two numbers. Guard: `gpu_fuzz_narrated.ring`, 23
assertions.

**The exactness discipline**, which is what makes a disagreement mean a
defect: inputs, scalars and literals are eighths of small magnitude, so
`+ - *`, floor, round, fract, sign, step, min, max, clamp, abs, mix with a
dyadic weight and `%` or `/` by a power of two round NOWHERE; a description
built only of those must agree bit for bit. An inexact operation (sin, exp,
log, pow, a general division ...) takes exact arguments and never feeds a
discontinuous function, a guard or an index. Stage indices are permutations
of the thread index, so no two threads write one slot.

**The four defects of the first run** (all in `gpu_wgsl.zig`, every other
guard green before it):

| defect | how it showed | fixed by |
|---|---|---|
| `inverseSqrt` | names are folded to lower case and the whitelist held WGSL's camel case: the transpiler refused every `inversesqrt` the interpreter admitted, and a match would have emitted a name WGSL lacks | the lookup ignores case and emits the whitelist's spelling (the material language shares the fix) |
| a guard's parenthesis | `@i < n and (A or B)` reached WGSL; the interpreter refused it, "missing ')'" | in a guard a parenthesis holds a condition |
| untyped literals | a call made only of literals, `ceil(0.5)`, is abstract outside a constant expression and the device refused the kernel; and `3 / 4` was **integer division on the device, 0 where the grammar means 0.75**: a silent wrong answer, -0.475 where the interpreter said -0.042 | every literal is written `f32`: `0.5f`, `4f` |
| `and` beside `or` | naga accepts `a && b \|\| c`; Chrome 152 refuses it, "mixing '&&' and '\|\|' requires parenthesis": one guard ran on the desktop and failed in a browser | both readers refuse it, naming the parentheses, as WGSL does |

And one stale test found on the way: `fragment transpile` had expected the
sRGB-space form since C4 (`f96f03093`, 2026-08-12) moved shading to linear
light. The code was right; the assertion now reads the linear form.

**Measured on the RTX 3050, mains power, under `rnxc`:**

| measure | value |
|---|---|
| seeds 1 to 7 and 11, 120 + 1,800 + 300 kernels | every one admitted by both readers, compiled, and agreeing after the fixes |
| the guard's seed, 300 kernels | 222 exact (bit for bit), 78 inexact; 281,557 elements compared, 15,357 left unwritten by a guard and checked so |
| the inexact band | 1e-5 of the value; the worst difference 0.10 of it |
| the control: one ' + ' made ' - ' in each kernel's store | seed 11: 144 of 158 caught; the guard's seed: 156 of 171. Each of the 14 escapes on seed 11 was read: a guard that writes nothing, a single element whose flipped term is 0, or a term that is zero everywhere (the fractional part of an integer). None could change an answer |
| time | the guard 3.2 s when the driver has seen its kernels, 57 s the first time on a machine (300 kernels compiled once into the driver's cache) |

**The other gates after the literal change**, under `rnxc`: grammar 43
(one pinned line updated to the typed form), shared 58, spec reference 34,
verify 36, declarative 20, puzzle 95, material maker 35 (the Ring++
worktree's copy); Zig 18 of 18; the edge proof 26 of 26 in Chrome on the
Intel adapter, the fixture regenerated.

**Not run, and why:** `gg5_material_language.ring` and main's copy of
`material_maker_narrated.ring` stop at load under `rnxc` (a top-level name
read bare, Rule A); they are the graphics desk's. The material language's
literals are still copied untyped, so `ceil(0.5)` in a material is the same
abstract expression; the fuzz does not generate materials, so this is
named for the graphics desk, not measured.

**What the fuzz does not cover yet:** the material language; a general
division feeding a discontinuous function (excluded by design); a race (the
generator never writes one; GZ0's sanitizer is the instrument for it).

## GZ0 STATUS — shipped 2026-10-28: the interpreter as a sanitizer; a race is a verdict

**What the grammar already makes unwritable**, so the sanitizer does not
look for it: a barrier some threads skip (every barrier stands outside any
branch, and the tiles count is refused unless it is the same for every
thread), and a stage reading the array it writes (refused, "the threads
would race"). The guard holds both by their refusals and checks that no
barrier of the tiled product's kernel sits inside the guard's branch.

**What remains, and what the sanitizer names** with the description's line,
the threads, the group and the slot (`gpu_wgsl.zig`, `stz_gpu_spec_sanitize`,
the same interpreter, watching):

| defect | the device does | measured on the RTX 3050 under `rnxc` |
|---|---|---|
| race: two threads of one stage write one slot | keeps any one of the writes | 900 races injected by the fuzz: the sanitizer named **900**; comparing values showed **383** -- 517 came back verified |
| dropped: a stage writes past its array | drops the write | the checker says verified; the sanitizer names it |
| past: a read past a shared array | reads 0 | the checker says verified; the sanitizer names it |
| unwritten: a read of a slot no stage wrote | reads the zero the kernel filled | the checker says verified; the sanitizer names it. A `max` or `min` reduce over such a slot counts its zero and is named; a `sum` adds nothing and is not |

And the other way: 900 generated kernels without a race, sanitized as the
fuzz runs them, gave **no false race**; 72 of them carried a quieter defect
that the device ran without a word.

**Where it shows.** `stzKernelMaker.SanitizeOn(bindings)` returns one
sentence per defect kind. A puzzle's `Grade` and `GradeOnCpu` name a race
BEFORE anything runs: `race at line L`, because the device may keep either
write and no comparison of values can stand for it. `Sanitize(kernel)` gives
the sentences, and the browser runner shows them under the verdict, in the
same words, through `stz.wasm`. Puzzle 9 gained two mistakes, a race and an
array too short; its no-stage mistake already showed the unwritten read.

**Gates, under `rnxc`:** sanitizer 25 (new), fuzz 23, grammar 43, spec
reference 34, declarative 20, verify 36, shared 60 (two new cases), puzzle
95; Zig 22. The puzzle page in Chrome: the race mistake reads "race at line
4", the short array and the no-stage mistakes keep their mismatch verdicts
with the sanitizer's sentences under them, and the reference is verified
with nothing said.

## GC0 STATUS — measured 2026-10-28: the distance to cuBLAS is about 2.4x in f32, and the tensor cores are a second, larger distance

**The instrument.** `base/test/gpu/gc0/gc0_cublas.py` times NVIDIA's cuBLAS
through ctypes on CUDA events (the GPU's clock), warm, best of 7, in three
modes: strict f32 on the CUDA cores (`cublasSgemm`, the fair comparison),
TF32 tensor-core math, and f16 inputs with f32 accumulation on the tensor
cores (`cublasGemmEx`, the hardware's ceiling). Sixteen sampled entries of
every product are checked against an f64 sum. It runs from a separate venv
(`D:\GitHub\_bench_cublas`, the author's ruling of 2026-10-28: a benchmark
tool, never a dependency; `nvidia-cublas-cu12` 12.6.4.1 and
`nvidia-cuda-runtime-cu12` 12.6.77, 435 MB). Our side is
`gc0/gc0_ours.ring` under `rnxc`: the foundry runs tile16, tile8, reg2 and
reg4 under the checker, on the GPU clock, best of 7.

**Measured on the RTX 3050 Laptop GPU, driver 561.00, mains power,
alternated cuBLAS, ours, cuBLAS, ours; each cell the better of the two
turns:**

| shape m x k x n | ours (reg4) ms | GFLOP/s | cuBLAS f32 ms | GFLOP/s | ours / f32 | cuBLAS TF32 ms | cuBLAS f16 ms | ours / f16 |
|---|---|---|---|---|---|---|---|---|
| 130 x 384 x 384 | 0.0604 | 635 | 0.0399 | 960 | 1.51 | 0.0399 | 0.0174 | 3.5 |
| 130 x 384 x 1536 | 0.1645 | 932 | 0.0655 | 2340 | 2.51 | 0.0492 | 0.0379 | 4.3 |
| 130 x 1536 x 384 | 0.2138 | 717 | 0.0901 | 1702 | 2.37 | 0.0612 | 0.0266 | 8.0 |
| 256 x 256 x 256 | 0.0402 | 835 | 0.0244 | 1378 | 1.65 | 0.0113 | 0.0092 | 4.4 |
| 512 x 512 x 512 | 0.2115 | 1269 | 0.0840 | 3197 | 2.52 | 0.0737 | 0.0625 | 3.4 |
| 1024 x 1024 x 1024 | 1.4328 | 1499 | 0.5742 | 3740 | 2.50 | 0.3377 | 0.1905 | 7.5 |
| 2048 x 2048 x 2048 | 12.6161 | 1362 | 5.4272 | 3166 | 2.32 | 3.5973 | 1.6394 | 7.7 |
| 4096 x 4096 x 4096 | 95.5687 | 1438 | 32.1055 | 4281 | 2.98 | 16.2714 | 9.4198 | 10.1 |

Our side moved by at most 4% between turns. **cuBLAS moved by up to 45% on
the small shapes** (8% to 45% up to 1024, 0% and 3% at 2048 and 4096), so its small
rows are its better turn and the ratios there are the honest LOWER bound of
the distance. Every cuBLAS product matched the f64 samples (f32 within
7e-7, TF32 and f16 within 6e-5).

**What the table says:**

1. **In f32, on the same CUDA cores, we are 1.5x to 3.0x slower, about
   2.4x in the middle.** That distance is the kernel, not WebGPU: cuBLAS
   reaches 51% of the measured f32 peak at 4096, reg4 reaches 17%. Larger
   register tiles, vectorized loads and double-buffered shared tiles are
   what separate them, and all of them are expressible in WGSL. This is
   the closable part, and it belongs to a foundry rung (GK2d below).
2. **The tensor cores are a second distance**: TF32 is a further 1.0x to
   2.2x over cuBLAS f32, f16 a further 1.3x to 3.4x. WebGPU has no way to
   ask for them. Only GV0 (Vulkan with cooperative matrices) can.
3. **GV0's kill line is not met**: the route is not within 2x of cuBLAS on
   Softanza's shapes (1.5x, 2.5x and 2.4x on MiniLM's three). So GV0 stays
   open, for the Principal to decide, and the order is GK2d first: it
   closes the part of the distance that needs no second backend.

**A measurement defect found on the way, fixed** (`gpu.zig`): a dispatch
over the TDR limit of 32,768 workgroups per submit is split into chunks,
and every chunk wrote its timestamps into the same two slots, so the GPU
clock read the LAST chunk alone. tile8 at 4096^3 (eight chunks) read 75 ms
where the wall clock said 600, and won the foundry's race at that shape.
The first chunk now writes the start and the last the end. Held by a scene
of `gpu_verify_narrated.ring` (39): the 1024^3 tile16 product forced into
eight chunks reads 7.5 ms against 6.4 ms in one submit, where the old
clock would have read about 0.8.

## GK2d STATUS — shipped 2026-10-28: three new matmul variants; at 1024 and above the distance to cuBLAS is less than half what GC0 measured

**What reg4 did that cost it**, read after GC0's table: each thread owned
four ADJACENT columns, so its B loads were strided across the warp and its
shared-memory reads collided in the banks. The new generator
(`mmStridedSourceP` in `gpu_ops.zig`) gives a thread rows `lid.y + 16 i`
and columns `lid.x + 16 j`, stores the A tile transposed with one float of
padding, stages by the linear thread index, and unrolls the K loop with
named scalars. Three variants, each under the foundry's checker:

| variant | per thread | tile | K step | workgroup memory |
|---|---|---|---|---|
| reg4s | 4 x 4, strided | 64 x 64 | 16 | 8.1 KB |
| reg8 | 8 x 8, strided | 128 x 128 | 8 | 8.0 KB |
| reg8p | reg8, the next K tile prefetched into registers while the current one is multiplied | 128 x 128 | 8 | 8.0 KB |

The broken sibling keeps its index 4, because guards select it by its bit.
The new variants sit after it, and `mmIsReal` replaces every "below
MM_REAL" test: the table, the foundry's default mask, its winner, and the
f16 path. `stzGpu.FoundryMatmulWith` now walks the variants by name.

**Measured on the RTX 3050 under `rnxc`, alternated cuBLAS, ours, cuBLAS,
ours; each cell the better turn:**

| shape | reg4 | reg4s | reg8 | reg8p | best | cuBLAS f32 | best / cuBLAS | GC0's reg4 / cuBLAS |
|---|---|---|---|---|---|---|---|---|
| 130 x 384 x 384 | 0.0622 | 0.0477 | 0.1011 | 0.0986 | reg4s | 0.0459 | 1.04 | 1.51 |
| 130 x 384 x 1536 | 0.1640 | 0.1515 | 0.1826 | 0.1749 | reg4s | 0.0686 | 2.21 | 2.51 |
| 130 x 1536 x 384 | 0.2128 | 0.2073 | 0.4212 | 0.4007 | reg4s | 0.0685 | 3.03 | 2.37 |
| 256 x 256 x 256 | 0.0401 | 0.0334 | 0.0701 | 0.0685 | reg4s | 0.0245 | 1.36 | 1.65 |
| 512 x 512 x 512 | 0.2123 | 0.1942 | 0.1556 | 0.1501 | reg8p | 0.0818 | 1.84 | 2.52 |
| 1024 x 1024 x 1024 | 1.3957 | 1.1994 | 1.0046 | 0.9634 | reg8p | 0.5938 | 1.62 | 2.50 |
| 2048 x 2048 x 2048 | 10.2933 | 11.4203 | 7.1495 | 5.6038 | reg8p | 5.3760 | 1.04 | 2.32 |
| 4096 x 4096 x 4096 | 94.0087 | 87.7663 | 55.7064 | 53.7447 | reg8p | 34.5610 | 1.56 | 2.98 |

(milliseconds on the GPU clock.) **The done-when is met**: at 1024, 2048
and 4096 the excess over cuBLAS fell from 1.50, 1.32 and 1.98 to 0.62, 0.04
and 0.56. reg8p beat reg8 in all 16 pairs (eight shapes, two turns), by 2%
to 5% where neither moved and by more at 2048, so it stays. On the third
MiniLM shape our time improved 3% while cuBLAS's best turn ran 24% faster
than in GC0; that ratio is cuBLAS's variance, not a loss. On MiniLM's
130-row shapes reg4s wins by 3% to 23%; reg8's 128-row tiles leave too few
workgroups there (two row tiles for 130 rows). The 130 x 1536 x 384 shape
has only 18 workgroups of 64 x 64 for a k of 1,536: the gap that remains
there is SPLIT-K's to close, which needs a second pass (WGSL has no float
atomics) and is named GK2e.

**The backbone, held by witnesses, not by agreement alone.** Each new
variant forced into the neural DLL's table compiled one kernel and
dispatched 36 matrix products per forward, with the bias fused, in f32 and
with f16 weights. The embeddings were identical to nine digits across
reg4, reg4s, reg8 and reg8p: every variant sums k in the same order, so
each rounds the same. 1 - cos to the CPU forward stayed 1.73e-4 (f32) and
1.74e-4 (f16) at 68 tokens. On this machine the foundry stored reg4s for
130 x 384 x 384 and 130 x 384 x 1536, and reg4 for 130 x 1536 x 384,
where the two are within 3%.

**A dead assertion found and fixed**: `gpu_foundry_matmul_narrated.ring`
read the broken variant's verdict at slot 28 since GK3 moved `F_BASE` to
10. Slot 28 belongs to a masked variant and was always 0, so "the checker
REFUSED it" held whatever the checker said. It reads slot 30 now, which
also reads 0, for the right reason.

**Gates, under `rnxc`:** ops 37, foundry 27, verify 39, f16 23, lifecycle
62, seams 17, calibration shaped 40. The matmul foundry guard passes every
assertion through scene 4, with six variants verified in five cells and
six dispatched through the op, each equal to the generic. Its scene 5
stops at `StzNeuralVariantsSync`, as before: the Ring++ worktree lacks it,
and main's `stzNeuralModel` is not Rule-A clean. Zig: ops 8, foundry 1,
gpu 4, fuzz 22.

## GK2e STATUS — measured 2026-10-28: split-K is right and pays only where k is deep; kept as a capability, NOT wired into the backbone

**What was built.** Split-K's two passes (`gpu_ops.zig`): the first is
reg4s's generator in a split mode (`mmStridedSourceX`): workgroup g takes
tile g % tiles and slice g / tiles of k, and stores its partial product in
a workspace. With the switch off, the text of reg4s, reg8 and reg8p stays
byte for byte the same; their twelve forms were hashed before and after.
The second pass sums the S partials IN SLICE ORDER and adds the bias once,
so the result does not depend on which workgroup finished first. The
checker judges one kernel, so the foundry runs the pair itself
(`stz_gpu_foundry_matmul_splitk`). The generic kernel is the reference at
a visible and a hidden shape, within the foundry's band. The pair and a
single-pass rival are timed alternately on both clocks, the pair as ONE
span (`verify.timedPair`: the first pass writes the start, the second the
end). The checker's judge rules on the pair's time.

**Measured on the RTX 3050 under `rnxc`, S = 4 unless named, against
reg4s (GPU clock):**

| shape | reg4s ms | split-K ms | rival / split |
|---|---|---|---|
| 130 x 1536 x 384 (MiniLM's down-projection) | 0.209 to 0.275 | 0.173 to 0.237 | 1.16 to 1.21 (S = 2: 1.13; S = 6: 1.21; S = 8: 1.19) |
| 256 x 1536 x 384 | 0.320 | 0.215 | 1.48 to 1.49 |
| 130 x 3072 x 768 (a BERT-base-sized down-projection) | 0.63 | 0.59 to 0.65 | 0.97 to 1.07 |
| 130 x 384 x 1536 | 0.151 to 0.152 | 0.177 to 0.214 | 0.70 to 0.86 |
| 130 x 384 x 384 | 0.052 to 0.061 | 0.064 to 0.071 | 0.80 to 0.94 |

Every pair agreed with the generic at both shapes (largest difference
0.0011 against a band of 0.03 at k = 1,536), and the judge accepted every
time.

**Why it is not in the backbone.** At 130 tokens it saves about 0.036 ms
on one of the three products, six times per forward: about 0.2 ms of a
forward near 8 ms, roughly 2.5%. GK4 measured that this machine's forward
clock cannot confirm a change of that size: a control moved 60% inside a
turn. Wiring it in would need a workspace in the residency, a split form
of the f16 weights, and a two-pass dispatch in `mmBias`. That is code the
clock cannot vouch for, so by GK4's rule it is not added. The capability
and its instrument stay, because the table is clear about where split-K
pays: deep k with few output tiles, 1.48x at 256 tokens.

**What would change the decision**: a consumer whose deep products have
few output tiles (long sequences on a narrow model, which 256 x 1536 x 384
stands for), or a forward clock that can see 2%. The latter is the
per-pass GPU timing the backbone does not keep yet.

**Where the remaining distance to cuBLAS is, on MiniLM's shapes**: 130 rows
in 64-row tiles compute 192 rows, 32% of them padding, and reg4s's 64 x 64
tile tops out near 1 TFLOP/s (it does 1.0 at 256^3). cuBLAS's 2.2 TFLOP/s
there needs a tile that wastes fewer rows, and more work per thread. That
is a variant, named here and not opened: 32-row tiles with 8 columns per
thread.

**Gates, under `rnxc`:** the matmul foundry guard's new scene 3b (4)
passes, and all earlier scenes pass. Its scene 5 stops on
`StzNeuralVariantsSync` as before. ops 37, foundry 27, verify 39, f16 23,
lifecycle 62. Zig: ops 8, foundry 1, verify 25, gpu 4, fuzz 22.

## GK2f STATUS — measured and REFUSED 2026-10-28: narrow tiles do not close MiniLM's gap; padding was not the cause

**The hypothesis GK2e named**: 130 rows in 64-row tiles compute 192 rows, a
third of them padding, so narrower tiles would close the gap to cuBLAS on
MiniLM's shapes. Three variants from GK2d's strided generator tested it,
each under the foundry's checker, all three verified at every shape:

| variant | per thread | tile | rows computed for 130 |
|---|---|---|---|
| r2x8 (the one named) | 2 x 8 | 32 x 128 | 160 |
| r2x4 | 2 x 4 | 32 x 64 | 160 |
| r1x8 | 1 x 8 | 16 x 128 | 144 |

**Measured on the RTX 3050 under `rnxc`, GPU clock, ms:**

| shape | reg4s (incumbent) | r2x8 | r2x4 | r1x8 |
|---|---|---|---|---|
| 130 x 384 x 384 | 0.0475 | 0.0558 | 0.0597 | 0.0862 |
| 130 x 384 x 1536 | 0.1515 | 0.1479 | 0.1631 | 0.2403 |
| 130 x 1536 x 384 | 0.2076 | 0.2454 | 0.2349 | 0.3570 |
| 256 x 256 x 256 | 0.0334 | 0.0394 | 0.0416 | 0.0589 |

Alternated duels, four turns each: r2x8 beat reg4s at 130 x 384 x 1536 in
4 of 4, by about 2% (0.148 against 0.151), and lost at 130 x 384 x 384 in
4 of 4, by about 17%. r2x4 and r1x8 won nowhere.

**Verdict**: the foundry crowns a variant at a margin of 1.3, and the
narrow family's best result is 1.02 over the incumbent. **All three are
removed**; the code is the GK2e commit's. Fewer padded rows also mean each
staged column of B serves fewer rows, and on this GPU the lost reuse costs
more than the padding saved. **What remains between reg4s and cuBLAS on
MiniLM's shapes is the kernel's own rate** (reg4s tops out near 1 TFLOP/s;
cuBLAS reaches 2.2 on the down-projection), not its tiling of 130 rows.

**The same duels re-checked GK2d's reg8p** after one run showed plain reg8
ahead at 1024 and 2048: reg8p won 3 of 4 at 1024, and 4 of 4 at 2048 and
4096. The reversal was that run's noise, and reg8p stays.

**Gates after the revert, under `rnxc`:** the matmul foundry guard has no
failure before its scene 5 (six variants); ops 37. Every existing kernel
text was hashed before and after the variants were added: 33 forms,
byte-identical.

## NEXT — after the charge (written 2026-10-28): from a checked teaching tool to a production GPU layer

**Where the plane stands.** The charge GK3 to KP3 is through. A kernel can
be described, transpiled, interpreted, checked at a hidden shape, placed
under measured roofs and taught as a puzzle, in the desktop engine and in
a browser. The reader's account is `SOFTANZA_GPU_KERNELS.md`. What is
missing is documentation outside this folder, testing a production team
could rely on, and the capabilities that separate this layer from CUDA.

**The ceiling, named before the plan.** WebGPU cannot reach tensor cores,
asynchronous copies or several GPUs, and reaches warp-level operations
only where an adapter offers subgroups. Matching CUDA's peak through
WebGPU alone is not a goal this plan can reach. The goal is **portable
kernels that are checked, measured, and within a KNOWN distance of the
vendor libraries on the shapes Softanza uses**. The distance is measured
first (GC0), and the second backend (GV0) is gated on it.

**The rungs, in order.** Each has a kill line written now, before it is
measured. A rung that crosses its kill line is recorded and closed, as
GK4 was.

| rung | what | done when | kill line | owner, and what it waits on |
|---|---|---|---|---|
| **GD0** | documentation: this folder's design document; the site's GPU guide and atlas; a book chapter | the design document exists (done, 2026-10-28); the site and book desks have the request | none | the site and book desks, through Central |
| **GT0** | a random-kernel fuzz: descriptions generated from the grammar, transpiled and interpreted, compared on the device; seeded, counted, a fixed budget per run | a guard runs N generated kernels of every line kind and prints how many agreed, how many were refused, and each disagreement with its seed | none: a disagreement is a bug, not a reason to stop | this desk |
| **GT1** | the guards on main's library under Ring++, not on the vehicle's overlay | every GPU guard runs from a checkout of main under `rnxc` | none | waits on the Principal's ruling on the library's Rule A migration |
| **GT2** | a platform matrix: AMD, Apple, Linux; Chrome, Edge, Firefox, Safari | the guards and the edge proof pass, or each failure is named, on each machine | none | waits on machines only the author can provide |
| **GT3** | a long run: a backbone forward and the checker repeated for an hour | memory and handle counts are flat; a lost device is reported and recovered, not crashed | none | this desk |
| **GZ0** | the interpreter as a sanitizer: a shared-memory race, a read past a shared array and a barrier not every thread reaches are reported with the line that caused them | each defect class has a negative puzzle that the sanitizer names and the device does not | if a race the device shows is missed, the sanitizer is wrong and is fixed before it ships | this desk |
| **GC0** | MEASURED 2026-10-28 (see GC0 STATUS): the distance to cuBLAS: the foundry's matmul against the vendor's, same laptop, same shapes, both clocks | a table of ratios on MiniLM's shapes and on square shapes from 256 to 4,096 | none: the number is the deliverable | needs a benchmark-only tool on the machine (PyTorch or a cuBLAS sample); the no-new-dependency rule makes that the author's call |
| **GL0** | the language grows: integer and vector types, atomics, 2-D and 3-D grids, a general bounded loop, branches | each admission has a puzzle, a refusal list, and agreement between both readers | an admission that the interpreter cannot mirror exactly is refused | this desk; after GT0, so the fuzz covers each admission as it lands |
| **GL1** | subgroup operations where an adapter offers them, with the interpreter's own reading of them | a reduction measured faster with subgroups than with shared memory, on an adapter that offers them | no gain on the clock: recorded and removed, as GK4 | waits on an adapter that offers subgroups; neither on this machine does |
| **GB0** | the library layer: convolution, scan, sort, top-k, segmented reductions, sparse-dense product, each through the foundry and the checker | each op has a CPU reference, a hidden shape, a roof fraction and a route | an op whose GPU route never wins on any measured shape is not routed | this desk; each op is a rung of its own |
| **GQ0** | recorded submission: a forward's dispatches recorded once and replayed, the role CUDA graphs play | the backbone forward's submit cost measured before and after | under 10% of the forward: recorded and closed | this desk |
| **GQ1** | a fusion planner that merges passes only where the dispatch count AND the clock agree | a merged pair kept by measurement, or the planner closed with its numbers | GK4's rule: within the clock's noise, removed | this desk; after GQ0 |
| **GV0** | a second backend for the hardware ceiling: Vulkan with cooperative matrices, reaching tensor cores on NVIDIA, AMD and Intel, under the same description and checker | a matmul measured through it against the WebGPU route and against cuBLAS | GC0 shows the WebGPU route within 2x of cuBLAS on Softanza's shapes; or the build needs an external SDK (G6's K2 invariant: SPIR-V must come from this repository's own code, the way WGSL does) | the Principal decides whether to open it, after GC0 |

**Owed before any of these, and not this desk's alone:**

- **PERCEPTGATE-KP3**: one of puzzles 9 to 12 worked by a person, with a sentence -> the author.
- **DOOR-GUARD-RPP**: the agent door guard is not Rule-A clean and still names `ring` -> the render desk, routed 2026-10-28.
- **NEURAL-GUARD-RPP**: the backbone guard reads `nPass` bare -> the neural desk, routed 2026-10-28.
- **DOC-GATE-RUN**: the documentation gate loads main's library and cannot run under `rnxc`. The KP and GK public methods were read against its rules by hand on 2026-10-28: three briefs over 140 characters, one stray block and one undocumented parameter were fixed. A machine run is owed when GT1 lands.

**GK2d, added by GC0's table**: the foundry gains larger register tiles (8 x 8 per thread), vec4 loads and double-buffered shared tiles, each a variant under the checker; done when reg4's successor halves the f32 distance at 1024 and above; killed if no variant beats reg4 by the foundry's margin.

**GK2e, added by GK2d's table**: split-K for the narrow, deep products (130 x 1536 x 384 has 18 workgroups of 64 x 64), as two passes under the checker; killed if the two passes cost more than they save at MiniLM's shapes.

**This desk's order**: GT0, GZ0, GC0, GK2d and GK2e (done 2026-10-28, see their STATUS sections above; GK2e measured and kept out of the backbone; GK2f's narrow tiles measured and refused), then once the author rules on the
benchmark tool, then GL0. GT0 comes first because every later rung adds
grammar, and a fuzz that already exists covers each addition the day it
lands.
