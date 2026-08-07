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
