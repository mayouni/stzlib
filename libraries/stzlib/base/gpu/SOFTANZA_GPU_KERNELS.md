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

A description is a set of lines. A value is a 32-bit float, a 32-bit
int (GL0), a vector of two to four floats (GL0) or, in a condition, a truth
value. Names fold to lower case, as
Ring does.

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
- **a choice** (GL0): `when(condition, a, b)` is `a` where the condition
  holds and `b` where it does not, anywhere a value may stand, nested if
  need be: `@c = when(@a > 0, @a, 0)`;
- **in a condition only** (the guard line, and a `when`'s first
  argument): `< <= > >= == !=`, `and`, `or`, and parentheses around a
  condition. `and` beside `or` needs parentheses, as WGSL requires:
  `(A and B) or C`.

**A condition's shape.** A condition is comparisons between values,
joined by `and` and `or` and grouped by parentheses. A comparison is not
a number and a number is not a condition: `(@a > 0) * 2`, `max(@a < 0,
1)` and `guard { @a }` are refused. WGSL types a comparison as a truth
value, and until GL0 those three reached the device and failed there in
the compiler's words. Both readers now read the shape from the source
with one routine, before either compiles it, so they cannot disagree on
it.

### 3.1b Whole numbers (GL0)

```
in a int
out c int
body { @c = (@a * 1664525 + 1013904223) % 1000 }
```

A declaration ends with its type: `in a int`, `scalar k int`, `out c int`;
nothing, or `float`, is a float. Every operation on ints is an int's: `/`
drops the remainder, `%` keeps the dividend's sign, and a product past
2,147,483,647 wraps around, as on every CPU. Divided by zero, an int gives
the dividend and its remainder 0, as WGSL says.

**A number without a decimal point takes the type of the value it meets**,
and so do the counting names `@i`, `n`, `@l`, `@g`, `@lx`, `@ly`, `@row`,
`@col`, a sum's variable and the tiles variable. In `@k + 1`, the `1` is an
int; in `@a + 1` it is a float. Meeting nothing, it is a float, which is
what every description before GL0 meant: `3 / 4` is still 0.75. A number
with a decimal point is a float.

**An int and a float never meet without saying so**: `@k + 0.5` is
refused; write `float(@k) + 0.5` or `@k + int(0.5)`. `int(x)` goes toward
zero and saturates at 2,147,483,520 (the largest float below 2^31) and at
-2,147,483,648; a NaN gives -2,147,483,648, as the device does. `abs min
max clamp sign` and `when` take either type; every other function takes
floats. A shared array and `@acc` hold floats.

**The buffers stay floats.** An int input is read through `i32(...)` and an
int output written through `f32(...)`, so a value crosses exactly up to
16,777,216. An int's arithmetic inside the kernel is exact over its whole
range.

### 3.1c Vectors (GL0)

```
in nx
in ny
in nz
scalar sx
scalar sy
scalar sz
out c
body { @c = max(dot(normalize(vec3(@nx, @ny, @nz)), normalize(vec3(sx, sy, sz))), 0) }
```

`vec2`, `vec3` and `vec4` hold two to four floats, as **values inside a
kernel**: an input and an output are still numbers, so a vector is built
and reduced within one expression.

| written | means |
|---|---|
| `vec3(@x, @y, @z)` | a vector from numbers; `vec4(v2, 1, 0)` from a vector and numbers; `vec3(1)` one number spread |
| `v.x`, `v.zyx` | one component, or several in any order (`x y z w`) |
| `v + w`, `v * 2` | component by component; a number meeting a vector is spread across it |
| `sin(v)`, `max(v, w)`, `mix(v, w, 0.5)` | every float function, component by component; its arguments have one type, except mix's weight |
| `dot(v, w)`, `length(v)`, `distance(v, w)` | a number |
| `normalize(v)`, `cross(v, w)`, `reflect(v, n)` | a vector (cross: two vec3s) |
| `when(c, v, w)` | one vector or the other |

A vector is not compared whole (compare `v.x`, or a `dot`), does not stand
where a number is needed (an output, an index, a sum's body), and holds
floats (`vec2(@k, 1)` with an int `k` is refused).

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
| an int and a float meeting, `@k + 0.5` | WGSL has no silent conversion; write `float(@k)` or `int(0.5)` |
| a float function on an int, `sqrt(@k)` | write `sqrt(float(@k))` |
| a float into an int output, or an int into a float one | write `int(...)` or `float(...)` |
| a whole number past 2,147,483,647 meeting an int | it is not an int |
| a type word other than `int` or `float` | a declaration ends with its type, or with its name |
| a vector where a number is needed, `@c = vec3(...)` | reduce it: `.x`, `dot(...)`, `length(...)` |
| a vector compared whole, `v > 0` | compare a component or a dot |
| two widths meeting, `vec2(...) + vec3(...)` | a vector meets one of its own width, or a number |
| a number given to a function beside a vector, `min(v, 0)` | WGSL has one type per call: `min(v, vec2(0))` |
| a component past the width, `vec2(...).z` | a vec2's letters are `x y` |
| a comparison used as a number, `(@a > 0) * 2` | on the device a comparison is a truth value; write `when(@a > 0, 2, 0)` |
| a number used as a condition, `when(@a, 1, 0)` or `guard { @a }` | a condition compares: `@a != 0` |
| a chain, `0 < @a < 2` | write `0 < @a and @a < 2` |
| a `when` without exactly three arguments | the condition, the value if true, the value if false |
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
A `when` is WGSL's `select`, which computes both values and keeps one; the
interpreter jumps over the value it does not keep. Neither value can have
a side effect, so the answer is the same, and the sanitizer watches only
the reads the answer depends on.

Since GL0 both readers are typed recursive descents, one construct for
each of the other's, so they refuse in the same order with the same words.
The transpiler keeps the source's own spacing and parentheses, so WGSL
reads the precedence a second time by itself. When it was rebuilt, it wrote
the same WGSL, byte for byte, for 18,000 generated kernels, and did again
when vectors were added. What a call means once its arguments' types are
known is decided once, for both (`planCall`); each still parses, writes and
computes it its own way. The interpreter keeps a vector in consecutive stack
slots and computes each component through the one function that computes a
number (`applyF`), so the two meanings cannot drift apart.

Two readers of one parsed description give a reference that **was not
produced by the thing being tested**. If the transpiler emits a wrong
kernel, the device and the interpreter disagree. A checker that compared
the device against itself could not see that.

The interpreter is also the **no-GPU path**: a puzzle is graded on a
machine with no device, in the same verdict words.

And it is a **sanitizer**. Run with it watching (`SanitizeOn`), it names
four defects the device runs without a word, each with the line, the
threads and the slot: two threads of one stage writing one slot (a race),
a stage writing past its array, a read past a shared array, and a read of a
slot no stage wrote. Comparing values cannot stand in for it: of 900 races
the fuzz injected, values showed 383; the sanitizer named all 900.

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
| race at line L | two threads of one stage write one slot; named before anything runs |
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

Fifteen puzzles in nine chapters teach the GPU from the map to the tiled
product, then the branch, the whole number and the vector:

| chapter | puzzles |
|---|---|
| the elementwise kernel | 1 double it · 2 two vectors, one sum · 3 one number for everyone · 4 where am I |
| the bounds guard | 5 the threads that have no element |
| the stencil | 6 look at your neighbours |
| the reduction | 7 many hands, first pass · 8 many hands, the fold |
| the group's memory | 9 the group's own memory · 10 a matrix product in tiles · 11 softmax, one row per group |
| the roofline | 12 how fast can it be |
| the branch | 13 two prices (GL0: `when`, and the same answer without it) |
| whole numbers | 14 roll the dice (GL0: an int keeps the digits a float loses) |
| the vector | 15 light on a surface (GL0: `vec3`, `dot`, `normalize`) |

An exercise is a folder in the Learning System's shape: `exercise.zknw`,
`task.<lang>.md` in English, French, Arabic and Hausa, `promise.ring`, a
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
them what to do. Puzzles 9 to 15 are built and checked by instruments;
**no person has worked one yet**.

## 8. Choices measured into the library

| question | answer | why |
|---|---|---|
| store the neural model's weights at half precision | kept, **off by default** | it halves the weight memory on the device and moves the forward by about 2%; the embedding stays as close to the CPU as f32 does |
| merge GELU into the matrix product's store | **removed** | 62 to 56 dispatches per forward, and the clock moved within its own noise |
| route a shape nobody measured | **interpolate** between measured shapes, log-log, never beyond them | a flat line sent a search the GPU runs 1.7 to 1.9 times faster to the CPU |
| double precision on the GPU | **refused** at the start | WebGPU has no f64 |
| WGSL's `%` on an int | **never written**: the transpiler writes `stz_rem(a, b)`, `a - (a / b) * b` | on the RTX 3050 (wgpu-native 29) the compiler took an i32 `%` as unsigned: `-7 % 4` was 1, where WGSL says -3; its `/`, its wrapping and its comparisons were WGSL's |
| `int()` past the range, and of NaN | **the device's answer**: 2,147,483,520 at the top, -2,147,483,648 for NaN | measured on the RTX 3050; WGSL leaves NaN to the device, so another one may differ |

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
  adapter offers subgroups. Measured against cuBLAS on the same laptop
  (2026-10-28, after GK2d's variants): our best f32 product is 1.04x to
  1.84x cuBLAS's f32 time on square shapes, 1.04x to 3.0x on MiniLM's
  narrow ones. The tensor cores add a further 1.3x to 3.4x that only a
  second backend could reach. The plan's GC0 and GK2d STATUS sections
  hold the tables.
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
| `gpu_sanitizer_narrated.ring` | the four defects named, the unwritable ones refused, races as puzzle verdicts, 300 injected races all named |
| `gpu_fuzz_narrated.ring` | generated kernels of six kinds through both readers and the device; the control that each wrong operator is caught |
| `gpu_when_narrated.ring` | GL0's `when`: both readers, the condition's shape and its refusals, the device, the fuzz's SWAP control, puzzle 13 |
| `gpu_int_narrated.ring` | GL0's ints: declarations, typing, refusals in both readers' words, the device at every edge, the fuzz's int kind, puzzle 14 |
| `gpu_vec_narrated.ring` | GL0's vectors: construction, swizzles, spreading, the vector functions, refusals, the device, the fuzz's vector kind, puzzle 15 |
| `edge_proof/edge_proof.html` | the browser and the desktop agree, case by case |
