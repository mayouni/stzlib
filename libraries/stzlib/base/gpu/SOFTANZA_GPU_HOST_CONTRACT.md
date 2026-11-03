# Softanza GPU: the host contract

**Version 1, 2026-11-03.** For the author of a *host*: the program that runs
a kernel written in the spec language (`SOFTANZA_GPU_KERNELS.md`) on a
device and says whether it is right. Hosts today are this engine's checker,
the Ring face, and the browser page. A host in another language (Haro's, now
in its own repository) is the reader this is written for.

## 1. Who owns what

The **engine** (Zig, `engine/src/`) reads the description: it transpiles it
to WGSL, interprets it on the CPU as the reference, and answers every
*number* a host would otherwise work out for itself. The **host** owns what
is the platform's: creating buffers, writing and reading them, dispatching.
A native host and a browser host do those differently, and the contract does
not ask them to do them the same way.

Before this contract the numbers existed four times (the Ring face twice,
the puzzle grader, the browser page), and a copy that drifts is a verdict
that differs between hosts. They are defined once, in `gpu_host.zig`, and a
host that spells one of them itself is wrong by definition. The guard
`base/test/gpu/gpu_host_narrated.ring` scans the host files for them.

## 2. The numbers

| number | value | engine export (wasm / C) | Ring |
|---|---|---|---|
| contract version | 1 | `stz_gpu_host_version()` | `StzEngineGpuHostVersion()` |
| threads in a group | 256 | `stz_gpu_host_group()` | `StzEngineGpuHostGroup()` |
| workgroups for n elements | ceil(n / 256) | `stz_gpu_host_groups(n)` | `StzEngineGpuHostGroups(n)` |
| NaN margin after the output's region | 256 floats | `stz_gpu_host_margin()` | `StzEngineGpuHostMargin()` |
| default band (allowed difference) | 0.000001 | `stz_gpu_host_default_band()` | `StzEngineGpuHostDefaultBand()` |
| default timed repetitions | 7 | `stz_gpu_host_default_reps()` | `StzEngineGpuHostDefaultReps()` |
| hidden shape's element count | see 4 | `stz_gpu_host_hidden_count(n)` | `StzEngineGpuHostHiddenCount(n)` |
| elements of an input the hidden shape keeps | see 4 | `stz_gpu_host_hidden_len(len, n, nb)` | `StzEngineGpuHostHiddenLen(len, n, nb)` |
| the hidden shape's input data | see 4 | `stz_gpu_host_hidden_input(src, floats, w, n, nb, dst)` | `StzEngineGpuHostHiddenInput(list, w, n, nb)` |
| params uniform size for k scalars | min(8 + 4k, 64) | `stz_gpu_host_params_bytes(k)` | `StzEngineGpuHostParamsBytes(k)` |

And, of the description compiled last (`stz_gpu_spec_compile`; the Ring
calls take the spec text and compile it themselves):

| number | engine export (wasm / C) | Ring |
|---|---|---|
| floats per element of input k (1, or a vector's 2 to 4) | `stz_gpu_spec_in_width(k)`, k from 0 | `StzEngineGpuSpecInWidth(spec, k)`, k from 1 |
| floats per element of the output | `stz_gpu_spec_out_width()` | `StzEngineGpuSpecOutWidth(spec)` |
| floats an input must hold for n elements | `stz_gpu_spec_in_len(k, n)` | `StzEngineGpuSpecInLen(spec, k, n)` |
| floats the output's region holds | `stz_gpu_spec_out_len(n)` | `StzEngineGpuSpecOutLen(spec, n)` |
| is the output atomic counters? | `stz_gpu_spec_out_atomic()` | `StzEngineGpuSpecOutAtomic(spec)` |
| how many counters; where they start | `stz_gpu_spec_out_size()`, `stz_gpu_spec_out_identity()` | `StzEngineGpuSpecOutSize(spec)`, `StzEngineGpuSpecOutIdentity(spec)` |

The output's region is `n` times its width, except an atomic output, which
is its SIZE counters whatever n is.

## 3. What a host does, in order

1. **Compile the description** (`stz_gpu_spec_compile`). A refusal is the
   verdict `refused: <the engine's words>` (`stz_gpu_wgsl_error`). Compile
   the *reference* and the *learner's* text each.
2. **If the description uses shared memory, sanitize first**
   (`stz_gpu_spec_sanitize`). Two threads of one stage writing one slot is
   the verdict `race at line L` and nothing is run: the device keeps either
   write, so no comparison of values can stand for it.
3. **Transpile** the learner's text (`stz_gpu_wgsl_elementwise`) and compile
   the WGSL on the device.
4. **For the visible shape (n elements), then the hidden shape (nb):**
   1. build the inputs; the hidden shape's are the engine's (section 4)
      unless the task declares its own;
   2. size the buffers: each input at least `in_len(k, n)` floats; the
      output `out_len(n) + margin` floats;
   3. fill the output with NaN (f32 bits `0x7FC00000`) everywhere; if the
      output is atomic, then the first `out_size` words with
      `out_identity` as an **i32**;
   4. write the params uniform: u32 `n`, a u32 pad, then each scalar as an
      f32 in the order the description declares them (`params_bytes`);
      the tile uniform at binding 0 is four u32 zeros;
   5. bind: 0 the tile uniform, 1 the params, 2.. the inputs in declaration
      order, then the output; dispatch `groups(n)` workgroups in x;
   6. read the output back, all `out_len + margin` floats; an atomic
      output's first `out_size` words are **i32 bits**, read as numbers;
   7. interpret the *reference* on the CPU for the same inputs
      (`stz_gpu_spec_eval_masked`), `n` elements, one mask byte each;
   8. judge, as in section 5.
5. A shape that holds gives no verdict; both holding give `verified`.

## 4. The hidden shape

The hidden shape exists so that a kernel which answers the visible fixture
by position (`out[i] = f(i)` instead of `f(a[i])`) fails somewhere it was
not shown. Its count for a visible `n` is **five sevenths, floored, at least
1, and odd when above 1**: a count that is a multiple of no tile. 256 gives
181 (182 is even); 4000 gives 2857.

Its data, when the task declares none, is the **tail of each visible input,
reversed, one element at a time**, keeping `floor(len * nb / n)` elements
(at least 1): a permutation, so every value stays inside the kernel's
domain. An element of a `vec3` input is its three floats, kept in order. A
task may declare its own hidden shape instead (`hidden-elements` and its
siblings), and then the host uses that.

## 5. The verdict words

A mismatch or an escape is named by its **1-based element**, the unit a
learner wrote, never a float's index.

1. **Margin first.** The first float after the region that is not NaN is
   `write-outside at element K`, with `K = region_elements + floor(j / w) + 1`
   for the j-th margin float, `w` the output's width (1 when atomic, whose
   region elements are the counters).
2. **Then the region.** For each element: the reference left it unwritten
   (the guard refused it) and the device wrote it, or the reference wrote it
   and the difference exceeds the band (or either is NaN), is
   `mismatch at element K`; the hidden shape's is `mismatch-hidden at
   element K`. An atomic output compares **every** counter.
3. `refused: ...` for a description the engine refuses, `race at line L`
   before anything runs, `verified` otherwise.

## 6. Data

Every buffer is f32. An `int` input is whole floats (exact to 16,777,216)
read in the kernel through `i32()`; a `vecN` input is N floats per element,
packed; an atomic output is i32 counters. A host in a language with no f32
list passes the bit patterns it must; the NaN margin is the one place a
host writes bits it does not compute.

## 7. Conformance

A host conforms when it reaches the same verdict words as the face. The
guard `base/test/gpu/gpu_host_narrated.ring` holds a *reference host*: about
a hundred and fifty lines of Ring, written from this document and calling only the
engine's entry points (no `stzGpu`, no `stzKernelMaker`, no
`stzKernelPuzzle`), which it compares with the face on 17 cases from puzzles
5, 6, 10, 13, 14, 15, 16 and 17: the margin, a stencil, a declared hidden
shape, ints, vectors, vector buffers and atomic counters. Port that file's
`_MiniVerdict` and run the same cases.

It makes one approximation, named: it reads the interpreter's list where the
checker also keeps a mask, so an element a body computed as NaN is not told
from one a guard left unwritten. No puzzle computes a NaN. It does not run
the sanitizer (step 2) and it does not time the kernel.

## 8. What this contract does not cover

The speed verdict (the roofs, the roofline fraction), the foundry's variant
choice, the calibration routing, and the fuzz are the checker's own and run
in this engine; a host asks for them, it does not reimplement them.

## 9. Decisions taken (2026-11-03, the GPU desk, on the author's word)

- **Numbers in the engine, buffers in the host.** Moving dispatch into the
  engine would make it the platform's: wgpu-native and the browser's WebGPU
  differ, and a host language would lose its own memory model for nothing.
- **The hidden shape's rule is unchanged**, only moved. The guard replays the
  old rule for every n from 1 to 6000 and finds no difference.
- **The Ring face keeps its own reversal loop** (over lists of doubles, one
  helper, `_StzKernelHiddenTail`) and the guard ties it to the engine's.
  A bridge for list transforms would add code to save one loop.
- **A version number** (`stz_gpu_host_version`) so a host can refuse an
  engine that means something else than the document it was written from.
  Anything above that changes a number or a rule bumps it.
- **The reference host lives in a guard**, not in the library: it is a
  proof and a template, and the library's face is the other implementation.
