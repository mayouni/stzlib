# The Softanza Compute Model

Status: doctrine, written 2026-08-07, after the fact. Everything below
shipped and is guarded; every number was measured on the dev machine
(Core 5 210H, 8 cores / 12 threads, RTX 3050 + Intel iGPU) in ReleaseSafe,
the mode we ship. Nothing here is a plan.

## The model in one paragraph

Softanza's engine runs the same computation at three widths — SIMD lanes
inside one core, threads across the machine's cores, and GPU kernels beside
the CPU — under ONE dispatch discipline: every path is admitted only where a
measurement says it wins, the admission thresholds live in one calibration
store, and correctness is split into exactly two classes: results that are
bit-identical by construction, and results whose last-bit movement is
justified in writing, per site, before it ships. The user calls the same
function either way and sees nothing but the speed.

## The three layers

**Lanes** (`@Vector`, one core). The scan and kernel loops — matmul rows,
UTF-8 counting, search candidate filters, compensated summation — run 4 f64
or 32 u8 lanes wide. The layer's two lessons are recorded where they were
learned: sometimes the winning move is to DELETE the hand-written vector
and hand LLVM slices it can prove independent (the LU kernel: index-form
3.9 s, hand-vectorised 1.0 s, plain slices 0.7 s at n=400); and a
sequential-looking loop can often be restated order-free (a codepoint is
exactly one non-continuation byte — 15x on the scan).

**Cores** (threads, M1–M5). Row-banded matmul (2.7–4.5x end-to-end),
gated-parallel LU (2.9x at n=1024), compensated reductions with per-thread
compensated partials (up to 3.9x, the 1e16-plus-ones pathological case
exact through threads), and distance scans (up to 6.7x, tie semantics
reproduced exactly and proven on fixtures built to collide). Workers spawn
per call above the gates — measured at ~0.4 ms for eight, under 10% of any
admitted workload — and a failed spawn computes its share inline: the
answer never depends on thread availability.

**GPU** (wgpu/WebGPU, the parallel track). Scoped by decision, not
accident, to f32-tolerant domains — embeddings, neighbours, neural, raster
— because WGSL has no f64, consumer silicon runs f64 at 1/64 rate, and the
f64 solver tier's bit-stability arguments are worth more than a marginal
transfer-bound win. Resident-chain matmul measured 294 GFLOP/s on the dev
GPU; the same WGSL reaches the browser through the WASM edge.

## The finding that unifies them

Standalone elementwise work — saxpy and friends — was measured and KILLED
on both accelerators independently: PCIe transfer ate it on the GPU (92% of
one-shot cost), and the memory wall ate it on CPU threads (one core already
pulls ~39 GB/s of a ~58 GB/s machine). **The two accelerators return the
same verdict because it is the same verdict: acceleration pays on
compute-dense work and on resident chains, and streaming a big buffer
through one cheap operation pays nowhere.** Any future backend should be
interrogated against this symmetry first.

## One dispatch discipline

- **Gates come from measurement, never argument.** Each spike wrote its
  kill criteria before its first number, and several things famous for
  being parallelisable failed honestly: threads LOSE 4–7x on small
  reductions, 12 threads run an n=128 matmul at 0.63x, CSV field scanning
  gained nothing from memchr. Recorded kills count as results.
- **One calibration store** (`src/calib.zig`). Resolution order OVERRIDE >
  FILE > DEFAULT: tests override (a test must never depend on its machine),
  `stz_calibration.txt` in the application's working directory is the
  cross-DLL truth (statics are per-DLL, so a file, not shared memory), and
  the compiled defaults are the spike numbers — no file means exactly the
  behavior that was measured and shipped. `src/calibrate_tool.zig` probes
  the real production functions on the user's machine and writes the file;
  run it on a quiet machine, delete the file to return to defaults. The
  `gpu.*` namespace is reserved so the GPU store converges on the same file.
- **Thresholds are honest in both directions.** The calibrator's first live
  run LOWERED two gates (parallel already pays at n=203 matmul and n=812
  LU — sizes the spikes never probed) and its conservative rule can only
  fail safe under machine contention: gates rise, speedups are lost,
  correctness is never at risk.

## The correctness doctrine

Two classes, no third:

1. **Partition the output and bit-identity is free.** A row of the result
   belongs to one lane-order, one thread, computed in the same sequence as
   serial. Matmul, LU (pivots included), the distance scans — all assert
   EXACT equality against the serial path, singular cases and ties
   included. This is what let the whole tier ship under the numeric
   oracle's κ(A)·eps tolerance arguments without reopening a single one.
2. **Reduce across lanes or threads and a justification is owed, in
   writing, at the site.** Compensated partials per group, combined
   compensated, are if anything better conditioned — and the pathological
   case is pinned exact. The ann/density dot products documented their
   bounded-magnitude arguments. Cholesky, QR and back-substitution remain
   serial reductions BY REFUSAL: their tolerance regime is not worth
   re-arguing for the gain measured.

Ties deserve their own sentence: parallel top-k reproduces the serial
stability exactly — smaller distance, then smaller index — and the fixture
that proves it uses quantized coordinates so equal distances actually
occur. A tie path tested only with continuous random data is not tested.

## Without ceremony

The user-visible API of all of the above is: nothing. No flags, no session
objects, no backend enums, no initialization order. `o1 * o2` is the same
multiplication it was in June; a variance is a variance; a shuffle is a
shuffle (now governed, with everything else, by one `SeedRandom`). The only
optional artifact is one text file a user MAY generate to tune gates to
their machine, and deleting it restores the measured defaults. Tests
override gates explicitly and never inherit the machine.

That modesty is load-bearing. Because no path changes any promised answer,
every layer could ship behind existing faces, guarded by existing suites —
2045 engine tests and the narrated guards ran unchanged across all of it,
and the handful that DID move (a sparse guard's timing-honesty floor, a
find guard's linearity band) moved because the code got faster than the
fixture, which is the only acceptable direction.

## What is deliberately absent

- GPU f64 (1/64-rate silicon under a bit-stability contract — refused).
- Parallel Cholesky/QR/back-substitution (reductions under oracle
  tolerances — refused until a measurement makes the case).
- Any parallelism below a measured gate (small work stays serial,
  unconditionally).
- A second spelling of anything. One dot product, one summation authority,
  one ASCII case table, one calibration store. The recurring engine defect
  was never slow code; it was the same operation written twice with only
  one copy maintained. The model exists to have one copy of everything.
