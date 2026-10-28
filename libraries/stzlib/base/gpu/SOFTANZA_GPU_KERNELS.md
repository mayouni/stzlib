# Softanza GPU kernels: the design

*Written 2026-10-28 by the GPU desk, after the charge GK3 to KP3. This is
the reader's document. The dated record of how each piece was built, and
what measuring it found, stays in `SOFTANZA_GPU_PLAN.md`. Where the two
disagree, the code is right and this file owes a correction.*

## 1. What this is for

Softanza lets a person **describe** a GPU kernel in a few lines and have
the engine do everything else: write the shader, check it against a
reference it did not write, refuse it by name when it is wrong, and say
how close it runs to what the machine allows.

The same description serves three readers:

| reader | what it does with the description |
|---|---|
| the transpiler | writes a WebGPU (WGSL) compute kernel from it |
| the interpreter | runs it on the CPU, a workgroup at a time, as the reference |
| the learner | works it as a puzzle in a browser, graded by the same checker |

The goal is not to be a second CUDA. It is to make a GPU kernel something
a person can **read, trust and measure**, on any GPU WebGPU reaches,
including the one in a browser.

## 2. The pieces, and where they live

```
  a description (text, or a stzKernelMaker)
      |
      +-- gpu_wgsl.zig: one parser
      |       +-- the transpiler: WGSL, run by stz_gpu (wgpu-native) or the browser's WebGPU
      |       +-- the interpreter: the CPU reference, and the path when no GPU exists
      |
      +-- gpu_verify.zig: the checker (visible shape, hidden shape, NaN margin, floors, roofs)
      |
      +-- stzKernelPuzzle.ring and courses/kernel-puzzles: twelve puzzles, two runners
```

| file | holds |
|---|---|
| `engine/src/gpu_wgsl.zig` | the grammar's one parser, the transpiler, the interpreter, the roof kernels |
| `engine/src/gpu_verify.zig` | the checker and its result slots |
| `engine/src/gpu.zig` | the device, its features, calibration, GPU-or-CPU routing |
| `engine/src/gpu_ops.zig`, `gpu_foundry.zig` | the op library, the matmul variants, the foundry that times them |
| `engine/src/neural_backbone.zig` | the resident MiniLM forward on the GPU, with f32 or f16 weights |
| `engine/src/stz_wasm_entry.zig` | the same grammar compiled for the browser |
| `base/gpu/stzKernelMaker.ring` | the Ring face over the grammar |
| `base/gpu/stzKernelPuzzle.ring` | a puzzle: its facts, its data, its grading |
| `base/gpu/stzGpu.ring` | the device face, with `VerifySpec` and `VerifySpecWith` |
| `base/education/program/courses/kernel-puzzles/` | the course, twelve exercises, the browser runner |
| `base/test/gpu/` | the guards |

The grammar lives in the engine and is written without an allocator, so
the browser build gets **the same code**, not a port of it.

## 3. The kernel language

A description is a set of lines. Every value is a 32-bit float on the
device. Names fold to lower case, as Ring does.

### 3.1 The elementwise kernel

```
in a
in b
scalar alpha
out c
body { @c = alpha * @a + @b }
```

| line | meaning | limit |
|---|---|---|
| `in NAME` | an input vector, read as `@NAME` | 5 inputs |
| `scalar NAME` | a parameter, read by its bare name | 14 scalars |
| `out NAME` | the one output vector | exactly 1 |
| `body { @out = expression }` | what each thread computes | one assignment |
| `guard { condition }` | when a thread may write; `guard none` removes the default | 1 guard |

One thread runs per output element. Without a guard line, the engine's
default guard keeps every thread inside the output.

**Inside an expression** a description may use:

- **declared names**: `@a` for the input at this element, `alpha` for a scalar;
- **the position**: `@i` is the element index, `n` the element count;
- **a neighbour**: `@a[expression]` reads another element, and reads 0
  outside the vector;
- **a bounded sum**: `sum(k, from, to, expression)` adds the expression
  for `k` from `from` up to, but not including, `to`; a sum cannot sit
  inside another sum;
- **arithmetic**: `+ - * / %`, parentheses, numbers; every number is an
  f32 in the kernel (`3 / 4` is 0.75, written `3f / 4f`);
- **functions**: `abs min max sqrt exp log sin cos tan tanh floor ceil
  pow clamp sign fract round mix smoothstep step atan2 asin acos
  inversesqrt length distance`;
- **in the guard only**: `< <= > >= == !=`, `and`, `or`, and parentheses
  around a condition. `and` beside `or` needs parentheses, as WGSL
  requires: `(A and B) or C`.

### 3.2 The group's own memory

A GPU runs threads in **groups** of 256 that share a small fast memory.
These lines describe it. They are what a tiled matrix product needs.

| line | meaning |
|---|---|
| `shared NAME SIZE` | an array of SIZE floats the whole group shares: at most 4 arrays, 1,024 floats each, 16 KB in all |
| `stage { @t[index] = value }` | every thread writes one slot, then the group waits for all of them |
| `reduce NAME sum` (or `max`, `min`) | folds the array into its first slot; the size must be a power of two up to 256 |
| `tiles VAR { count }` | the group lines after it repeat `count` times, with `VAR` counting from 0 |
| `accumulate { @acc = expression }` | a running value per thread, carried across the tiles |
| `width w` | the output is a 2-D grid `w` wide, and each group is a 16 x 16 tile of it |

At most 12 group lines in one description. The names they add:

| name | is |
|---|---|
| `@l` | the thread's place in its group, 0 to 255 |
| `@g` | the group's number |
| `@lx`, `@ly` | `@l` as a column and a row inside a 16 x 16 tile |
| `@row`, `@col` | the output element's row and column; needs a `width` line |
| `@acc` | the accumulator; readable once an accumulate line exists |
| `@t[index]` | one slot of a shared array |

The tiled matrix product of puzzle 10, whole:

```
in a
in b
scalar k
scalar w
out c
width w
shared ta 256
shared tb 256
tiles t { k / 16 }
stage { @ta[@ly * 16 + @lx] = @a[@row * k + t * 16 + @lx] }
stage { @tb[@ly * 16 + @lx] = @b[(t * 16 + @ly) * w + @col] }
accumulate { @acc = @acc + sum(j, 0, 16, @ta[@ly * 16 + j] * @tb[j * 16 + @lx]) }
body { @c = @acc }
```

### 3.3 What the language refuses, and why

A refusal names its cause in words a learner can act on. The transpiler
and the interpreter refuse the same descriptions with the same words,
because they share one parser.

| refused | why |
|---|---|
| an unknown name or function | the whitelist is the grammar |
| a stage that reads the array it writes | the threads would race; stage into a second array |
| a tiles count that could differ between threads | every thread must reach every barrier: scalars, `n` and numbers only |
| `@row` or `@col` without a `width` line | they have no meaning in a 1-D kernel |
| a shared array read without an index | a slot is the unit, as in `@t[@l]` |
| a reserved name used as a user name | `i n l g lx ly row col acc` belong to the language |
| `and` beside `or` without parentheses | WGSL refuses it in a browser; write `(A and B) or C` |
| too many lines, arrays or floats | the limits above |

The emitted kernel **zeroes its own shared arrays** before the first
stage. wgpu-native did not do it, and a kernel that relies on it reads
garbage on one adapter and zeros on another.

### 3.4 The Ring face

```ring
k = new stzKernelMaker
k.TakesVector(:a)
k.TakesVector(:b)
k.TakesScalar(:alpha)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = alpha * @a + @b }')
? k.ToWGSL()                                  # the generated kernel, verbatim
? k.EvaluateOn([ :a = aA, :b = aB, :alpha = 2.5 ])   # the CPU interpreter
```

`Shared`, `Stage`, `Reduce`, `Tiles`, `Accumulate`, `Width` and `Guard`
add the lines above. `Spec()` returns the description as text, and
`StzKernelMakerFromSpec(text)` builds a maker from one. `ToWGSL()` needs
no GPU, so a kernel can be written and read on a machine without one.

## 4. The two readers, and why there are two

The transpiler turns a description into WGSL. The interpreter runs the
same description on the CPU. It simulates one group at a time, every
thread through each item of the schedule before the next item starts, so
a barrier means what it means on the device. Its arithmetic is f32 with
WGSL's meanings: `%` truncates and `round` goes to even.

Two readers of one parsed description give a reference that **was not
produced by the thing being tested**. If the transpiler emits a wrong
kernel, the device and the interpreter disagree. A checker that compared
the device against itself could not see that.

The interpreter is also the **no-GPU path**: a puzzle is graded on a
machine with no device, in the same verdict words.

## 5. The checker

`stzGpu.VerifySpec(reference, candidate, bindings)` and its options form
`VerifySpecWith(..., [ :reps, :band, :n, :hidden ])` judge a candidate
kernel against a reference on the same device, with the same inputs.

| step | what it catches |
|---|---|
| a **visible** shape, the one the learner sees | a wrong kernel |
| a **hidden** shape, with a different size and different data | a kernel that hardcodes the size or a value |
| a **NaN margin** after the output region | a kernel that writes past its output |
| both kernels timed **the same way**: warm, alternated A B A B, on two clocks where the adapter has timestamps | a candidate that wins because it was timed differently |
| **floors measured on this device**: the smallest dispatch, the copy bandwidth, the compute peak | a time that could not have happened |

The verdicts:

| verdict | means |
|---|---|
| verified | right at both shapes, in a possible time |
| mismatch at element K | wrong where it was shown |
| mismatch-hidden at element K | right where it was shown, wrong where it was not |
| write-outside at element K | stored past the output region |
| impossible | faster than this device can move or compute the data: a measurement defect, not a win |
| refused: why | the description does not parse |

Before it calls a time impossible, the checker **measures the bus floors
again** and judges against the fresh ones. Under four parallel processes
a stale floor read "impossible" in 2 of 8 runs of the checker's own
self-proof; with the fresh round, in 0 of 8.

## 6. The speed verdict: where a kernel stands under the roofs

A correct kernel is the first question. The second is how fast it runs
**compared with what the machine allows**. The engine measures two roofs
on the device in use:

- **the copy roof**: how many bytes per second a plain copy kernel moves;
- **the compute roof**: how many floating-point operations per second a
  dense multiply-add kernel reaches. On the development machine's RTX
  3050 laptop part that is about 8.4 TFLOP/s in a short burst. A loop of
  only 8 multiply-adds per round measured 2.7, because it timed the loop
  and not the arithmetic.

`stzKernelPuzzle.Roofline(kernel)` runs a kernel over a large vector and
reports its bandwidth and its operations as fractions of those roofs, and
whether it is bound by memory or by compute. Bytes and operations are the
**essential** ones: each input read once, the output written once, the
reference's operations per element. A kernel that does more than it must
shows a smaller fraction.

The browser page times batches of ten dispatches. One dispatch at a time
reported 174% of the copy roof, which is a clock artefact, not speed.

## 7. The puzzles

Twelve puzzles in six chapters teach the GPU from the map to the tiled
product:

| chapter | puzzles |
|---|---|
| the elementwise kernel | 1 double it · 2 two vectors, one sum · 3 one number for everyone · 4 where am I |
| the bounds guard | 5 the threads that have no element |
| the stencil | 6 look at your neighbours |
| the reduction | 7 many hands, first pass · 8 many hands, the fold |
| the group's memory | 9 the group's own memory · 10 a matrix product in tiles · 11 softmax, one row per group |
| the roofline | 12 how fast can it be |

An exercise is a folder in the Learning System's shape: `exercise.zknw`,
`task.<lang>.md` in English, French and Arabic, `promise.ring`, a
`reference.txt` the learner's kernel must match and a `starter.txt` that
fails with "waiting for your implementation". Facts in `exercise.zknw`
build the data, so the Ring runner and the browser runner grade one spec
to one verdict:

| fact | gives |
|---|---|
| `elements` | the output count |
| `input-NAME`, `scalar-NAME` | an input's recipe, a scalar's value |
| `input-length-NAME` | an input longer than the output, for a stencil or a sum |
| `hidden-elements`, `hidden-scalar-NAME`, `hidden-input-length-NAME` | the hidden shape |
| `band` | the allowed difference, where a puzzle needs more than the default |
| `roofline-elements` | the size the speed verdict runs at |
| `has-mistake` | a wrong kernel the page offers as a button, so a learner sees each verdict happen |

Recipes: `ramp`, `half`, `mod13`, `mod7`, `ones`, `tenths`.

**The browser runner** (`runner/puzzle.html`) loads the engine compiled to
WebAssembly, transpiles in the page, runs on the browser's WebGPU, and
falls back to the interpreter when WebGPU is missing. A separate edge
proof page, `base/test/gpu/edge_proof/`, shows the browser and the
desktop produce identical results on every case it holds.

The author worked puzzles 1 to 8. After the page gained a "Your move"
block and buttons that load a known mistake, the author said those told
them what to do. Puzzles 9 to 12 are built and checked by instruments;
**no person has worked one yet**.

## 8. Choices measured into the library

| question | answer | why |
|---|---|---|
| store the neural model's weights at half precision | kept, **off by default** | it halves the weight memory on the device and moves the forward by about 2%; the embedding stays as close to the CPU as f32 does |
| merge GELU into the matrix product's store | **removed** | 62 to 56 dispatches per forward, and the clock moved within its own noise |
| route a shape nobody measured | **interpolate** between measured shapes, log-log, never beyond them | a flat line sent a search the GPU runs 1.7 to 1.9 times faster to the CPU |
| double precision on the GPU | **refused** at the start | WebGPU has no f64 |

Half precision is requested whenever the adapter offers it; both adapters
on the development machine grant it. Subgroups are noted, never
requested; neither adapter offers them.

## 9. How this differs from the usual GPU stack

| | the usual way | here |
|---|---|---|
| hardware | one vendor, mostly NVIDIA through CUDA | any GPU WebGPU reaches, and the browser's |
| the reference | a NumPy or Python answer beside the kernel | an independent interpreter of the same description |
| a wrong kernel | an output that differs | a verdict that names the element, and whether it was the hidden shape |
| speed | a time in milliseconds | a fraction of the roofs measured on this device; "impossible" refused by name |
| teaching and production | separate code | the puzzle's tiled product is the template the neural forward uses |
| negative results | rarely published | kept, with the number, in the plan |

## 10. What it does not do

*Since 2026-10-28 the grammar is also checked by kernels nobody wrote: the
random-kernel fuzz (`gpu_fuzz.zig`, section GT0 STATUS of the plan). Its
first run found four defects every hand-written guard had passed, among
them a silent wrong answer: an untyped `3 / 4` was integer division on the
device.*

- **Reach CUDA's peak.** WebGPU cannot reach tensor cores, asynchronous
  copies or more than one GPU, and warp-level operations only where an
  adapter offers subgroups. The tuned product is good for this engine
  and has not been compared with cuBLAS.
- **Integer types, atomics, 3-D grids, general loops and branches.** The
  bounded sum and the tiles loop are the only loops. Every value is f32.
- **Run beyond one machine.** Everything was measured on one Windows
  laptop with an NVIDIA RTX 3050 and an Intel integrated GPU, partly on
  battery. Nothing ran on AMD, Apple, Linux or a phone.

The order in which these are closed is in `SOFTANZA_GPU_PLAN.md`, the
section headed NEXT.

## 11. The gates

Run with Ring++ from `base/test/gpu/`: `rnxc <guard>.ring`.

| guard | covers |
|---|---|
| `gpu_grammar_narrated.ring` | the elementwise grammar, its refusals, transpiler and interpreter agreeing |
| `gpu_shared_narrated.ring` | the group lines: shared, stage, reduce, tiles, accumulate, width |
| `gpu_spec_reference_narrated.ring` | the interpreter as the reference |
| `gpu_verify_narrated.ring` | the checker, its verdicts and its floors |
| `gpu_puzzle_narrated.ring` | the twelve puzzles, both runners, the chapters |
| `gpu_f16_narrated.ring` | half-precision weights and the forward's dispatch count |
| `gpu_calibration_shaped_narrated.ring` | routing by shape, interpolation between measured classes |
| `gpu_fuzz_narrated.ring` | generated kernels of six kinds through both readers and the device; the control that each wrong operator is caught |
| `edge_proof/edge_proof.html` | the browser and the desktop agree, case by case |
