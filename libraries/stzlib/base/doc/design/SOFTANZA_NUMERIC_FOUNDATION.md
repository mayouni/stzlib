# Numbers in Softanza — a global rethink
### Where the numeric layer actually stands, what a modern one owes its users, and the plan to close the distance

> Status: **ALL PHASES 0-7 COMPLETE** (P3 residency in four slices: 13266934d, ba4c54ec9, cc8fb24d8, 0ddf438fc. P4 kernels, NINE slices: 1fdc2eda5, 7621cc5e1, a0fdc7689, e549ec945, d5b84416d, f0b3e7890, 07d3b443e, 504c1df36, 40fd49580). **Phases 5-7 are design.** Written 2026-07-25 at the user's
> direction, *before* starting the number-engine work, to rethink number
> programming across the whole library rather than bolt a `BigNumber` class onto
> the side. **It supersedes `SOFTANZA_NUMBER_ENGINE_PLAN.md`**, whose six phases
> survive as a strict subset (they become Pillar 1 and part of Pillar 4).
> Every "today" claim below was produced by reading the live tree and **running
> code against it** — the measurements are in §2 and the three defects in §2.6
> were found by that probing, not by inspection.

---

## 1. What this document is for

Softanza has a lot of numeric surface: `stzNumber` (7106 lines), `stzListOfNumbers`
(8849), `stzMatrix` (2627), `stzRandom` (4723), `stzDataSet` (3917), a stats module,
three solvers, nine machine-learning classes, a vendored ggml with a real matmul
bridge, and arbitrary-precision integers in the engine.

It also has this:

```ring
? (9007199254740992 + 1) = 9007199254740992      # --> 1     (TRUE)
```

Both facts are true at once, and that is the problem worth solving. The pieces are
individually decent and collectively incoherent: there is no single definition of
what a number *is* in this library, no single authority for what `Variance()`
*means*, and — measured, not guessed — no performance benefit from the engine on
the path most numeric code actually takes.

So this is not a feature list. It is an attempt to answer four questions:

1. What does the library have today, precisely?
2. What does a modern numeric layer owe its users?
3. What do *our own* number-intensive modules need in order to stop being toys?
4. What does Zig give us that Ring cannot, and where should we vendor instead?

---

## 2. The measured baseline

### 2.1 What a Ring number is

One type, and it is a C double. There is no integer type at all.

```ring
? type(1)         # --> NUMBER
? type(1.5)       # --> NUMBER
? 1/2             # --> 0.50        (always float division)
```

Ten measured consequences:

| # | Fact | Measured |
|---|---|---|
| 1 | Integer exactness ends at 2⁵³ | `(2^53 + 1) = 2^53` → **TRUE** |
| 2 | Large integers are silently wrong | `9223372036854775807` prints `9223372036854775808.00` |
| 3 | **No scientific-notation literal** | `x = 1e5` → `R24 Using uninitialized variable: 1e5` |
| 4 | Small values print as zero | `number("1e-20")` displays `0.00` while being `> 0` |
| 5 | Float→string is not shortest-round-trip | `number("1e308")` prints ~90 digits of binary expansion |
| 6 | Display precision is a **global mode** | `decimals(20)` reveals `0.1` as `0.10000000000000000555` |
| 7 | Money is broken by default | `0.1 + 0.2 = 0.3` → FALSE; `0.1` added ten times ≠ 1 |
| 8 | NaN/Inf are reachable and silent | `number("1e308")*10` → `inf`, and `isNumber(inf)` → **TRUE**, `inf > 0` → TRUE |
| 9 | `inf - inf` → `-nan(ind)`, which also passes `isNumber` | no NaN discipline anywhere |
| 10 | Bit operations run on doubles | `1 << 62` → `4611686018427387904.00` |

Fact 3 deserves a second look: **you cannot write a scientific-notation number in
Ring source.** Every such constant in the library must be spelled
`number("1e-9")`. Fact 6 is the one with the widest blast radius — precision is a
process-global display setting, which is the least composable design available for
it, and it is exactly the "invisible frame" that Pillar 2 exists to kill.

### 2.2 What the engine already does well

| Module | Lines | What it gives |
|---|---|---|
| `number.zig` | 1081 | **Arbitrary-precision integers** via Zig's `std.math.big.int.Managed` — add/sub/mul/div/mod/pow/compare, base conversion. Correct, and already exposed |
| `stats.zig` | 663 | 36 functions: moments, quartiles, correlation, regression, z-scores, outliers, moving average |
| `matrix.zig` | 472 | 22 functions: element access, scalar/matrix add, multiply, transpose, determinant, inverse, power |
| `numtheory.zig` | 317 | gcd/lcm, primality, factorial, Fibonacci, divisors, digit predicates |
| `random.zig` | 209 | RNG surface |
| `similarity.zig` | 141 | cosine, euclidean, manhattan, jaccard, dot product, normalize |
| `neural*.zig` + ggml | — | a real `stz_neural_matmul_into` bridge, honestly documented as f32-in/f64-out |
| `bits.zig`, `intseq.zig`, `histogram.zig`, `pivot.zig` | 1271 | bit ops, integer sequences, bucketed histograms, pivot aggregation |

The bignum foundation being *already present and correct* is the single most useful
fact in this document. `SOFTANZA_NUMBER_ENGINE_PLAN.md` was written partly to
correct a recorded claim that we had no arbitrary-precision engine; we do.

### 2.3 What the engine does not have

- **No SIMD. At all.** Zero `@Vector` or `std.simd` across ~200 engine modules — in
  a language whose headline numeric feature is portable explicit vectorisation.
  **First uses landed in phase 4 slices 2-3:** the compensated sum and the centered
  sum of squares in `stats.zig`. And the engine was not even being COMPILED with
  optimisation until slice 1 -- see the phase-4 notes.
- **No parallel numeric kernels.** `std.Thread` appears in `curlcore`, `dns`,
  `fswatch`, `http`, `pool`, `reactor`, `resilience` — all I/O — plus one
  `Thread.Mutex` in `histogram.zig`. Nothing in `stats`, `matrix` or `solver` uses
  more than one core. **MEASURED AND DELIBERATELY LEFT THAT WAY in slice 9**: at this
  library's data sizes threading a reduction is up to **25× SLOWER** (128 µs spawn
  against a 4 µs kernel), and even at 16M elements 12 cores buy only 2.7× because the
  kernel is bandwidth-bound. See the phase-4 notes for the full table.
- **No wide floats.** `f80` and `f128` are unused, though Zig has them natively.
- **No decimal, rational, complex, or fixed-width integer types.**
- **Linear algebra stops at `inverse`.** No LU, QR, Cholesky, SVD, or eigenvalues —
  so no least squares, no PCA, no conditioning diagnostics, no rank. **LU DONE in
  slice 4 (e549ec945)** with a determinant and a linear solve; **QR (Householder) +
  CHOLESKY + LEAST SQUARES in slice 7 (07d3b443e)**, so multiple regression is
  expressible; **SYMMETRIC EIGEN + CONDITION NUMBER + RANK in slice 8 (504c1df36)**,
  which also gives the eigenvectors PCA needs; **SVD + RECTANGULAR RANK/CONDITIONING
  in slice 9 (40fd49580)**; **PSEUDO-INVERSE + MINIMUM-NORM SOLUTIONS (f17404c55)**.
  **This line is now CLOSED.**
- **`solver.zig` is not an optimiser.** 199 lines of scalar root-finding
  (bisection, Newton), Simpson integration and polynomial evaluation over
  coefficient arrays. There is no LP, QP, MIP or general nonlinear solver in the
  engine.
- **No automatic differentiation** — the primitive that everything in modern
  optimisation and ML is built on.
- **No FFT.**
- ~~**No special functions.**~~ **DONE in phase 4 slice 5 (d5b84416d):**
  `engine/src/special.zig` -- incomplete gamma and incomplete beta as the two
  workhorses, with erf/erfc/normal/t/chi-square/F derived from them, plus quantiles
  by bisection on those CDFs. This was why §2.6's confidence-interval defect
  existed: **without those functions the library could not compute a p-value, a t
  critical value, or any distribution CDF**, so inferential statistics was not
  merely missing but unreachable. It is now reachable, and the interval is t-based.
- **No numerically stable accumulation.** No Kahan/Neumaier compensation, no
  Welford streaming moments, no quantile sketch for data that does not fit in RAM.

### 2.4 Where the algorithms actually live

This is the finding that reframes the whole exercise.

| Module | Lines | Engine calls |
|---|---|---|
| `base/learning/` — KMeans, KNN, DecisionTree, LogisticRegression, NaiveBayes, Trainer, Apriori, ModelEval, TrainingSet | ~1250 | **6 in total** (all in `stzNeuralNetwork`) |
| `stzLinearSolver` | 1170 | **0** |
| `stzMultiObjectiveSolver` | 867 | **0** |
| `stzStochasticSolver` | 853 | **0** |
| `stzHistogram` | 1015 | **0** — while `histogram.zig` exists in the engine |
| `stzDataWrangler` | 1424 | **0** |
| `stzListOfNumbers` | 8849 | 10 |
| `stzNumber` | 7106 | 48 |
| `stzMatrix` | 2627 | 34 |
| `stzRandom` | 4723 | 8 |

Read that column again. **Every numeric *algorithm* in Softanza executes in the Ring
interpreter.** The engine holds scalar helpers and a small dense matrix; the
simplex method, k-means, logistic regression and decision-tree induction are
Ring loops over boxed lists. The engine-first doctrine that governs strings, regex,
XML and files was never applied to numbers.

### 2.5 The performance truth, and it is not what you would guess

Measured on this machine, 200 000 numbers:

```
build the list in Ring                    0.02s
Ring loop: mean + variance                0.04s
engine: StatsCreate + Mean + Variance     0.04s     <-- no faster
  of which StatsCreate alone              0.04s     <-- the whole cost
20 x Mean on a WARM handle                0.01s     (~0.0005s each)
```

**The crossing dominates completely.** A one-shot engine call on Ring-side data
buys nothing, because marshalling the list costs as much as the pure-Ring
computation. The engine only pays once the data *stays there* and many operations
run against it — which is precisely the lesson already recorded for lists,
positions and hash sets elsewhere in this library, arrived at independently each
time.

The design consequence is blunt: **residency is not an optimisation, it is the
precondition.** Adding SIMD kernels behind a per-call marshalling boundary would
produce almost no speedup. Get the data engine-side and keep it there, and only
then does kernel quality matter.

A second measurement worth keeping: a plain Ring `for` loop summing 1 000 000
integers takes 0.04s. Ring is not catastrophically slow at trivial arithmetic. The
gap opens on *algorithms* — nested loops, per-element object access, repeated
list indexing — not on single passes.

### 2.6 Three defects found while probing

**(a) Two classes, same data, different variance.**

```ring
an = [2, 4, 4, 4, 5, 5, 7, 9]
? (new stzDataSet(an)).Variance()          # --> 4.57   (sample, N-1, via engine)
? (new stzListOfNumbers(an)).Variance()    # --> 4      (population, N, pure Ring)
```

Neither declares its convention. Median and percentile agree between the paths
(R type-7), so this is specifically an authority problem, not general chaos: there
is no one place where "variance" is defined.

**(b) `ConfidenceInterval` is wrong for exactly the cases it is for.** It is
labelled "t-distribution approximation" and uses hardcoded **z** values:

```ring
an = [12, 15, 11, 14, 13]                  # n = 5
? (new stzDataSet(an)).ConfidenceInterval(95)   # --> [11.61, 14.39]
```

The margin used is `1.96·s/√n` = 1.39. The correct t-based margin for n=5 is
`2.776·s/√n` = 1.96 — the interval is **41% too narrow**, and the error grows as
the sample gets smaller, i.e. exactly when you reach for a confidence interval.
Worse, any level other than 90/95/99 silently falls back to 95:

```ring
? (new stzDataSet(an)).ConfidenceInterval(80)   # --> [11.61, 14.39]  (identical to 95)
```

This is not carelessness. It is the *inevitable* consequence of §2.3: with no
incomplete beta function there is no way to compute a t quantile, so a table of
three constants was the only option available.

**(c) A dead alias.** `ConfInt()` calls `This.ConfidentialInterval()` — a method
that does not exist:

```ring
? (new stzDataSet(an)).ConfInt()
# --> R14 : Calling Method without definition: confidentialinterval
```

### 2.7 One structural wart

`stzMatrix` holds **both** `@aContent` (a Ring nested list) and `@pEngineMatrix`
(an engine handle). Two representations of one matrix means two truths to keep in
step, and no stated answer to "which one is authoritative?". The same question is
already open for `stzList` residency. Pillar 3 has to answer it once, for
everything.

---

## 3. What a modern numeric layer owes its users

Measured against what NumPy/Julia/R/Python-decimal users now take for granted,
here is the gap, sorted by how much it hurts:

| Owed | Today | Cost of absence |
|---|---|---|
| An exact integer that does not lie | 2⁵³ ceiling in Ring; correct bignum in the engine but unwired | silent wrong answers in counting, IDs, combinatorics, money-in-cents |
| Decimal arithmetic for money | none | `0.1+0.2≠0.3`; every financial computation is approximate |
| Dense typed arrays | boxed Ring lists | the residency problem of §2.5; memory blowup |
| Vectorised kernels | none | 4–8× left on the table per core, free from Zig |
| Multicore for big reductions | none | 8–16× left on the table |
| Decompositions (LU/QR/Cholesky/SVD/eigen) | none | no least squares, no PCA, no rank, no conditioning |
| Real optimisation (LP/QP/MIP/NLP) | Ring simplex | toy problem sizes only |
| Automatic differentiation | none | no gradient-based ML or optimisation worth the name |
| Special functions (erf, lgamma, gammainc, betainc) | none | **no p-values, no CDFs, no hypothesis tests** |
| Stable accumulation + streaming moments | naive sums | precision loss on long/ill-conditioned data |
| Shortest-round-trip float printing | ~90-digit dumps, `0.00` for small values | you cannot trust what you read, or round-trip it |
| Reproducible seeded RNG with named streams | partial | experiments are not reproducible |
| FFT | none | no spectral/signal work |

Two of these are *correctness* debts rather than capability gaps — exact integers
and special functions — and they should be paid first for that reason alone.

---

## 4. What Zig gives us that Ring cannot

The engine is written in Zig 0.15.2, and this is the argument for doing the work
there rather than in Ring:

- **`@Vector(N, T)`** — portable explicit SIMD that compiles to AVX2/AVX-512/NEON
  as available, with no intrinsics and no per-platform code. Currently unused.
- **Arbitrary-width integers** — `u256`, `i512`, and `std.math.big.int` for
  unbounded. The latter is *already wired*.
- **Every float width** — `f16` (ML), `f32`, `f64`, `f80`, `f128` (extended
  precision without a library).
- **Explicit overflow semantics** — `+%` wrapping, `+|` saturating,
  `@addWithOverflow` returning a flag. Ring has none of this; the *policy* becomes
  expressible.
- **`@setFloatMode(.optimized)`** — opt-in fast-math, scoped to a function rather
  than a compiler flag.
- **`comptime`** — generate a kernel per element type and per unroll factor with
  no macro tricks and no code duplication.
- **`std.Thread` + `std.Thread.Pool`** — and the library already runs a thread
  pool (`pool.zig`) for I/O, so the pattern is in-house.
- **Shortest round-trip float formatting in `std.fmt`** — Ryu-class output for free,
  which fixes §2.1 facts 4–6 without vendoring anything.
- **C interop with no glue layer** — `@cImport` and `build.zig` already compile
  eleven vendored C libraries. Vendoring more C is a solved problem here.

Zig's weakness for our purposes: **C++ and Fortran are both awkward.** All eleven
current dependencies are C. That single fact drives most of §6.

---

## 5. The design — five pillars

### Pillar 1 — One number, many representations, and exactness is visible

The tempting design is six classes: `stzInt`, `stzBigInt`, `stzRational`,
`stzDecimal`, `stzFloat`, `stzComplex`. It is also wrong for this library, because
it makes the *user* carry a type decision that the *system* can make, and Softanza's
heritage is the opposite of type ceremony.

**One front door: `stzNumber` keeps its name and grows a representation.** Inside,
a number is exactly one of: machine integer, big integer, rational, decimal,
binary float, complex. Promotion is automatic and follows one published ladder;
demotion never happens silently.

What makes this Softanza rather than generic: **a number knows whether it is exact,
and can say why it is not.** This mirrors the evidential register the NNL layer
already has, where every verdict carries its confidence.

```ring
StzNum("0.1").Plus("0.2").IsExact()        # TRUE  -- decimal path
StzNum(0.1).Plus(0.2).IsExact()            # FALSE -- binary float path
StzNum(0.1).Plus(0.2).Why()
# "approximate: 0.1 and 0.2 are not representable in binary floating point"
```

And the distinction Ring cannot currently express at all:

```ring
StzNum("1/3").Plus("2/3").Same( StzNum(1) )   # TRUE  -- mathematical equality
```

`Same()` means "equal as numbers"; Ring's `=` keeps meaning what it means. Naming
follows the house rules: plain method returns data, `...Q()` returns the chainable
object, no `As`/`With`/`To`/`For`.

Sub-parts, in dependency order: **big integers** (already in the engine — wire them
up), **rationals** (a pair of big integers; trivial once big integers are wired),
**decimals** (§6 decides build-vs-vendor), **complex** (last, and only because
FFT and eigenvalues need it).

### Pillar 2 — Numeric scope: name the frame at the call site

This is the pillar that is *specific to this library*, and it is
[Scope-Oriented Programming](SCOPE_ORIENTED_PROGRAMMING.md) instance #3 after
regex and system.

The SOP diagnosis is: a field gets hard when **one act's behaviour is bent by an
invisible frame**. Numerics is the textbook case. `2/3` depends on a division
convention. `0.5 → 0` or `1` depends on a rounding mode. `x + y` overflowing
depends on a policy. `?` printing `0.00` for a positive number depends on
`decimals(2)`, **a process-global mode set by whoever ran last**.

The cure is the same as for regex and system calls: **name the scope at the call
site.**

```ring
StzWithPrecision(50, func {
    return StzNum("2").Sqrt()          # 50 significant digits, here and nowhere else
})

StzWithRounding(:HalfEven, func {
    return oInvoice.Total()             # banker's rounding, the accounting default
})

StzWithOverflow(:Raise, func {
    return oCounter.Add(nHuge)          # refuse rather than saturate or wrap
})
```

Three consequences worth stating:

1. **Display precision stops being global.** How many digits you *show* becomes a
   property of the rendering call, not of the process. `decimals(2)` remains for
   Ring compatibility; nothing in Softanza depends on it.
2. **The scopes are auditable.** They compose with the governance vocabulary the
   library already has, so "this financial routine ran under half-even rounding at
   34 digits" is a recordable fact.
3. **The default is stated, not implied.** IEEE-754 binary64, round-half-even,
   NaN/Inf *raising* rather than propagating silently. Fact 8 in §2.1 — that
   `isNumber(inf)` is TRUE — is a trap we should close by default and open only
   inside `StzWithOverflow(:Propagate, ...)`.

### Pillar 3 — Engine-resident numeric arrays (the keystone)

§2.5 makes this non-negotiable and also tells us what it must look like.

A **`stzNumBuffer`**: a contiguous typed buffer (f64/f32/i64) owned by the engine,
with Ring holding a handle. One crossing to fill it, then any number of engine
operations at engine speed, and one crossing to read results back.

`stzListOfNumbers` stays the friendly door — 8849 lines of surface that people use
— and gains residency *behind* it rather than being replaced by a competing class.

And Pillar 3 must settle the question §2.7 leaves open, once, for matrices, lists
and buffers alike:

> **The engine copy is the truth. The Ring copy is a materialised view, produced on
> demand and invalidated on mutation.**

That is the rule the `stzList` residency work reached and left half-applied ("slice
4: engine-truth, dirty-handle write-back" is still pending), and the rule
`stzMatrix`'s dual `@aContent`/`@pEngineMatrix` currently lacks.

The columnar payoff is worth naming: once numeric columns are resident buffers,
`stzTable`, `stzDataSet` and `pivot.zig` aggregate over typed memory instead of
boxed lists, and the neural tier's tensors and our matrices become the same bytes
— which is what makes the ggml bridge cheap rather than a copy.

### Pillar 4 — Kernels: SIMD and threads in Zig, vendored C only where it pays

With residency in place, kernel quality finally matters. In priority order:

1. **SIMD the hot reductions** — sum, dot, min/max, mean/variance (Welford,
   vectorised), cosine similarity, elementwise ops, saxpy. `@Vector` makes each of
   these a few lines and portable. ~~`similarity.zig`'s six functions are scalar
   loops today and are on the hot path for every embedding comparison in the NLP
   and neural tiers.~~ **CORRECTED by slice 6: they were scalar, but NOT on that hot
   path — the bridge exposed only fixed 3-dimension variants, so Ring could not
   reach them with an embedding at all. And a `dim > 1024 -> return 0.0` guard meant
   a 1536-dimension comparison would have silently scored zero. Both fixed
   (f0b3e7890).**
2. **Numerically stable by default** — Neumaier compensation in accumulation,
   Welford for moments, log-sum-exp where it belongs. This is a correctness upgrade
   disguised as a performance one.
3. **Thread the big ones** — reductions, matmul, distance matrices, k-means
   assignment. `pool.zig` already exists.
4. **Decompositions in Zig** — LU with partial pivoting, QR (Householder),
   Cholesky, symmetric eigen (Jacobi), SVD (Golub–Kahan or one-sided Jacobi). This
   is the set that unlocks least squares, PCA, rank and conditioning. §6 explains
   why these are *written* rather than vendored.
5. **Special functions in Zig** — `erf`, `erfc`, `lgamma`, `tgamma`, incomplete
   gamma, incomplete beta, and the inverse CDFs built on them. Small, well-published
   mathematics, and the thing standing between us and real statistics.
6. **Reverse-mode autodiff** — a tape over a scalar/tensor expression graph. This
   is the multiplier: with gradients, L-BFGS becomes ~300 lines, logistic
   regression becomes a two-line objective, and the neural trainer stops being
   hand-derived.

### Pillar 5 — Move the algorithms, and give every definition one authority

The algorithms in §2.4 come down from Ring, in value order:

- **Simplex → engine. DONE (9a5c356ff)**, guard `numeric_simplex_narrated` (27) —
  **and the simplex was never the problem.** I did exactly what this line says first:
  moved the pivot loop into `engine/src/simplex.zig`. A 40-variable model went from
  **2.620s to 2.603s**. Then I profiled:

  ```
  extractCoefficient x 1200 calls : 2.474s
  the whole Solve("simplex")      : 2.592s
  ```

  **95% of the time was re-parsing strings.** `extractCoefficient` is called once per
  (constraint, variable) pair and each call re-parsed the *entire* expression from
  scratch to pull out one coefficient — so the cost grew as constraints × variables ×
  terms, **cubic in the model, for a parse that is linear**. Parsing once into
  `[ [name, coeff], … ]` and caching by expression text:

  | vars × cons | before | after |
  |---|---|---|
  | 10 × 8 | 0.051s | 0.009s |
  | 20 × 15 | 0.353s | 0.024s |
  | 40 × 30 | 2.620s | **0.091s** (29×) |

  On the whole `Solve()` call, 2.592s → 0.063s — **41×**. A 100×80 model, previously
  out of reach, now solves in 0.71s. All seven call sites keep their signatures, so
  `stzMultiObjectiveSolver` (which delegates to the same parser) got it for free.

  **Third time this shape has appeared** — after the CSV module's per-cell regex
  recompile and the graph module's O(E²) rebuild. **Profile before optimising: the
  expensive line is rarely the one the plan names.**

  The engine pivot loop is *kept*, on the merits rather than the plan's say-so: A/B'd
  on the same tableau it gives **bit-identical** solutions (largest disagreement
  exactly 0) while running below clock resolution where Ring takes 13ms, and it
  removes ~50 lines of hand-rolled pivoting. It mirrors the Ring pivot rule exactly,
  because a different but equally valid rule lands on a different vertex of the same
  optimal face when the problem is degenerate — silently changing every answer.

  *Verification:* all 14 linearsolver tests **byte-identical** before and after.
- **Clustering / KNN / logistic / trees → engine**, over resident buffers. These
  are the classic distance-and-reduce kernels that SIMD and threads were made for.
  **DISTANCE DONE (3e70a67c7)**, guard `numeric_one_distance_narrated` (16):
  `stzKMeans` and `stzKnn` each carried a hand-rolled Euclidean distance — *byte-for-byte
  identical Ring loops* — alongside `similarity.zig`'s vectorised one. **Three
  definitions of one quantity**, the same shape as the variance divisor, the summation,
  the centered sum of squares and the negligible threshold. Measured first: 8× at
  20000×32, free below a few thousand points, so the authority argument carried it.
  **The care was in the RAGGED case** — both loops truncated to the shorter vector and
  nothing validates lengths on input, while the engine bridge *refuses* a mismatch and
  answers 0, which for a distance reads as "identical" and would collapse a k-means
  cluster. Routing to a shared authority is only safe if its REFUSALS are handled.

  **LOGISTIC DONE (a212ff7cc)**, guard `numeric_logistic_narrated` (38). The plan's
  claim was checked before any Zig was written, because last time it named the wrong
  line: the old Ring loop was hoisted **by hand** first — the label comparison done
  once instead of once per epoch, the feature row read in place instead of passed as
  an argument (Ring copies a list into a parameter). On 5000 × 16 × 100 epochs that
  gave **10.0s → 5.0s with bit-identical weights**. Half interpreter overhead, half
  arithmetic no Ring-side care removes — *that* is what justified the move.

  | scale | before | after |
  |---|---|---|
  | 200 × 4 × 50 | 0.057s | 0.002s |
  | 5000 × 16 × 100 | 10.0s | **0.062s** (161×) |
  | 20000 × 32 × 100 | out of reach | 0.706s |

  **The arithmetic is unchanged, not merely equivalent, and that is the design.**
  Gradient descent is a feedback loop, so a last-bit difference compounds. Updates
  stay sequential per example (SGD — the weights move before the next example is
  scored), the dot product accumulates in index order though a lane-parallel
  reduction would be faster, and the saturation cutoff stays at |z| > 35. **Only the
  weight update vectorises, and only because it can:** `w[f] += c * x[f]` is
  elementwise, so no accumulation crosses lanes and no reassociation is possible.
  Half the inner work vectorises free and half must not — knowing which is which is
  the engineering.

  **One thing could not be held fixed, and was measured rather than assumed.** Ring's
  `exp` is the C library's and the engine's is Zig's: drift is **1e-16 after one
  epoch, 1e-15 at ten, 1e-14 at a hundred and five hundred** — never zero, growing
  about a decade per five hundred epochs, and both loops classify identically.
  **The first reading of this was wrong:** under `decimals(14)` it printed as
  `0.00000000000000`, "identical to the last bit" was asserted, and it failed. The
  display had truncated it. *Measure by order of magnitude when a quantity may be
  smaller than the display mode.*

  **Two silent failures became diagnoses.** `NumberOfFeatures()` is the width of the
  FIRST example and the old loop indexed every other row to it, so a 3-feature row
  among 2-feature rows trained as though its third feature did not exist. And
  `Classify()` with the wrong arity escaped as a bare Ring "Array Access (Index out
  of range)" from inside the dot product. **`_Score()` and `_Sigmoid()` were deleted
  rather than kept** — two definitions of one quantity is this phase's recurring
  shape, and here it would have surfaced as a model whose predictions disagreed with
  its own training.

  **IDENTIFIED AND DELIBERATELY NOT FIXED:** the class diverges on unscaled features
  (weights of 4100, accuracy 0.5 on data already seen, against 8.48 and 1.0 for the
  same data scaled) and is pinned as it behaves. Needing standardised features is
  SGD's normal requirement, not a defect; `TrainingAccuracy()` is what makes a
  silent, confident failure visible. Standardisation belongs with the trainer
  rewiring in phase 6, where the transform can be held with the model.

  **TREES: THE PLAN NAMED THE WRONG LINE AGAIN (381d94b06)**, guard
  `numeric_counting_idiom_narrated` (33). The tree did **not** go to the engine,
  because profiling it found something with nothing to do with trees — a Ring idiom
  that appears all over this library:

  ```ring
  if HasKey(aCounts, key) : aCounts[key] = aCounts[key] + 1
  else                    : aCounts[key] = 1
  ```

  Counting into a Ring hash-list. It reads like a hash map and is not one:

  | 4000 items, 20 passes | 2 distinct keys | 50 distinct keys |
  |---|---|---|
  | HasKey idiom | 1.515s | 12.858s |
  | parallel lists + `ring_find` | 0.054s | 0.068s |
  | | **28×** | **189×** |

  **Read the second column.** 2 keys → 50 makes the scan 26% slower and the HasKey
  form **8.5× slower** — writing through the key appears to invalidate the index so
  the next HasKey rebuilds it. *The idiom is worst exactly where a map is most
  wanted.*

  | | before | after | |
  |---|---|---|---|
  | `stzApriori` 200 transactions | 16.124s | 0.041s | **393×** |
  | `stzApriori` 600 transactions | 47.589s | 0.099s | **481×** |
  | `stzNaiveBayes` 100 documents | 12.497s | 0.088s | **142×** |
  | `stzNaiveBayes` 600 documents | 82.251s | 0.466s | **176×** |
  | `stzDecisionTree` 4000 × 8 | 1.434s | 0.308s | 4.7× |
  | `stzDecisionTree` 10000 × 8 | 3.580s | 1.349s | 2.7× |

  Association rules on two hundred baskets took sixteen seconds. **No suite said so
  because they all use tiny fixtures.**

  Two more tree findings, each measured before acting. The **case fold** lived inside
  `_ValuesOf`/`_Subset`, re-folding every row once per (node, feature) though the
  value never changes — `StzLower` builds and frees two engine string objects, five
  crossings per character, and was **13× the loop containing it**. And `_Subset`
  returned **copied rows**, so the set was copied once per level and again on every
  method return; the recursion now carries **row numbers** (22× cheaper to append,
  14% dearer to read). `_Majority` and `_Entropy` also had byte-identical counting
  loops — one `_Counts()` now.

  **The arithmetic is untouched in all three**, verified by before/after output diffs:
  trees across five datasets + a mixed-case one + every training verdict + `Why()`;
  naive Bayes labels, classifications and log-scores to ten decimals; apriori
  itemsets, counts, rules, confidences **and their order**. All three diffs empty.

  **Deliberately left:** `StzConfusionMatrix` (callers index it BY KEY — `aCM["b->a"]`
  is its tested contract — and it holds at most labels² entries, the flat end of the
  curve) and `stzKnn`'s vote tally (bounded by k). Neither is the severe form.

  *Ring trap:* `(new stzDecisionTree(...)).Train()` as ONE expression does not raise —
  it **runs**, and a 0.35s build did not finish in four minutes. A nastier face of the
  construct-and-call trap than the R13 the same shape gives on `stzMatrix`, because
  nothing announces itself.

  **KNN: THE DISTANCES WERE 0.3% OF IT (2a9c7c3b8)**, guard
  `numeric_knn_selection_narrated` (23). Measured expecting the distance kernel to be
  worth moving. Classifying **one** point against ten thousand took **17.9 seconds**;
  twenty queries took 357. At 10000 × 16:

  | | |
  |---|---|
  | the distances themselves | 0.032s |
  | **the full insertion sort** | **11.769s** |
  | a bounded K=5 selection | 0.003s |

  `Classify()` computed every distance — which is what KNN *is* — and then **insertion
  sorted all ten thousand to read the first five off the front**. O(N²) for an O(N·K)
  question; the ordering of the other 9995 was computed and discarded, at **3900×**
  what finding the five costs. 2000 × 8 dim, 20 queries: 15.018s → 0.187s (**80×**).
  10000 × 16: 357.753s → 1.173s (**305×**). **Nothing moved to the engine** — the
  distance has lived there since slice 3.

  **The tie rule was the delicate part.** The old code was a *stable* insertion sort
  (shifting only while strictly greater), so equidistant examples kept training-set
  order and that order decided the vote at the K/K+1 boundary. The bounded selection
  walks left under the same strict comparison and rejects a candidate that merely
  *equals* the current worst — the same decision without ordering anything else.
  Verified by diffing every verdict, neighbour list, index and distance for k = 1..8
  on a set built entirely of ties, plus k > N, plus 120 classifications. Empty.

  **No suite caught it because every KNN fixture has about six rows**, where N² and
  N·K are the same number. So the guard asserts **growth** as well as time: halving N
  must roughly halve the work. **k-means was profiled in the same pass and left alone**
  — its inner loop is a distance and a mean, no ordering anywhere.

  ---

  **PILLAR 5's ALGORITHM LIST IS NOW COMPLETE**, and the pattern across it is worth
  stating once. Six things were examined; **two moved to the engine** (the simplex
  pivot loop, on the merits rather than the plan's say-so, and logistic training,
  161×). **Four did not, and were faster for it:** the simplex's real cost was a cubic
  re-parse (41×), the tree's was a hash-list counting idiom (393× in apriori), KNN's
  was a quadratic sort (305×), and `stzHistogram` was never duplication at all. *The
  plan named the wrong line four times out of six.* Profiling before moving is not a
  refinement of this phase's method — it is the method.

  ---

  ### Second pass: the heavy loops actually go to the engine

  The account above stops at "profile before moving", and that was **the wrong place
  to stop**. Diagnosing correctly and then leaving an O(N·K) algorithm running in an
  interpreter is not the same as finishing: correct complexity in an interpreter is
  still an interpreter. Three of the four Ring-side fixes were followed through.

  | | original | after Ring fix | **in the engine** |
  |---|---|---|---|
  | KNN 10000 × 16, 20 queries | 357.753s | 1.173s | **0.085s** (4200×) |
  | KNN 2000 × 8, 20 queries | 15.018s | 0.187s | **0.012s** (1250×) |
  | ID3 4000 × 8 | 1.434s | 0.308s | **0.059s** (24×) |
  | ID3 40000 × 10 | — | 3.965s | **0.727s** |
  | k-means 10000 × 16, k=5 | — | 0.985s | **0.076s** (13×) |

  **The KNN sequence is the lesson, and three of its four steps were wrong guesses:**

  | | |
  |---|---|
  | one distance per crossing, sorting all N | 357.753s |
  | one distance per crossing, bounded selection | 1.173s |
  | whole matrix marshalled inside every query | **2.254s — worse** |
  | matrix flattened once, re-sent per query | 0.679s |
  | matrix **resident**, query crosses alone | 0.630s |
  | ...and `Examples()` off the hot path | **0.085s** |

  Sending the whole matrix per query is the right *shape* and made it worse — 160 000
  list appends now happened per query for data that never changes. Making the dataset
  resident (phase 3's keystone, the step I was most confident about) barely moved it.
  **The cost was `@oDs.Examples()`: Ring copies a list when a method returns it**, so
  asking the dataset for its examples handed back all ten thousand rows on every
  query — 0.581s of a 0.598s run, 97% of what remained, in a line that reads like a
  plain accessor.

  ID3 repeated the shape one level up: the first engine version gained only 1.5×
  because the cost had moved into the **interning loop** — `StzLower` per (row,
  feature) is 400 000 calls at 40000 × 10, each building and freeing two engine string
  objects. Folding each *distinct* raw string once instead of each occurrence took it
  from 2.690s to 0.727s.

  **What made the categorical move clean: codes, not strings.** A categorical value's
  identity is all ID3 needs, so Ring interns once — work it already did — and nothing
  in `tree.zig` compares a string.

  **In every case the decision rules are Ring's, to the comparison**, because these
  algorithms choose among equals constantly and those choices are answers a user
  reads: KNN's tie order, ID3's first-max feature and first-seen majority and branch
  order, k-means's distinct-point seeding and lower-index-wins assignment. All three
  were verified byte-identical against the **original** implementations — not the
  intermediate ones — across ties, refusals, truncated runs and full output dumps.
  Both dead Ring implementations (`_Score`/`_Sigmoid`, and 172 lines of ID3) were
  **deleted rather than kept**, for the reason this phase keeps rediscovering.

  **`stzNaiveBayes` and `stzApriori` followed** (`2bd2fc50e`), guard
  `numeric_text_mining_narrated` (31). What replaced HasKey in the first pass was a
  `ring_find` scan over a key list that grows with the data — right in Ring, wrong
  anywhere with a hash table.

  | | original | after pass 1 | **in the engine** |
  |---|---|---|---|
  | Bayes 100 docs | 12.497s | 0.088s | **0.003s** (4166×) |
  | Bayes 600 docs | 82.251s | 0.466s | **0.015s** (5483×) |
  | Bayes 3000 docs | — | 3.647s | **0.095s** |
  | Apriori 200 tx | 16.124s | 0.041s | **0.017s** (948×) |
  | Apriori 5000 tx | — | 0.941s | **0.157s** |

  **Naive Bayes needed tokenization to move too** — only ~⅔ of its cost was counting;
  the rest was `_TokensOf` building a whole `stzText` per document to reach the word
  iterator, a floor near 1.4s however fast the hash was. **Which made the tokenizer the
  risk:** `bayes.zig` uses the same UAX#29 `WordIter` that `str_extract_words` walks and
  the same case fold `StzLower` applies (so `stz_stats` now links utf8proc). A
  whitespace split would have agreed on "the cat sat" and quietly built a different
  model on `don't`, `3.14`, `word2vec` and every CJK document. An empty diff **at ten
  decimals** is itself the proof the tokenizer matches — one differing token moves every
  score.

  **Apriori needed its ordering to survive twice:** items intern in `strcmp` order so
  integer order reproduces `_Sorted`, and itemsets keep **first-counted** order because
  `FrequentItemsets()` publishes it and the suite asserts "bread" comes first.

  ---

  **ALL SIX ALGORITHMS THE PLAN NAMED ARE NOW IN THE ENGINE.** The honest summary of
  this phase is two-part and neither part is optional: *profile before moving* — the
  plan named the wrong line four times out of six — **and then actually move it**.
  Diagnosing correctly and stopping at a Ring-side fix leaves a working algorithm in an
  interpreter, which is what the first pass did. Every move was verified byte-identical
  against the **original** implementation, and in every case the tie and ordering rules
  were the specification, not the arithmetic.
- ~~**`stzHistogram` → the existing `histogram.zig`.** 1015 Ring lines duplicating an
  engine module is pure waste.~~ **WRONG, and checked in phase 5 slice 1: they share a
  NAME and nothing else.** `histogram.zig` is a **latency** histogram with fixed
  log-scale *millisecond* buckets (0.1 ms … 10 s) for observability percentiles — a
  Tier 1 item. `stzHistogram` computes **data-driven** bins by Sturges' rule, with a
  configurable count, range, aggregation and labels, for analysis and rendering.
  Migrating one onto the other would replace user-defined statistical bins with
  hardcoded millisecond latency buckets. **Not done, and it should not be** — the claim
  was made from the module names.
- **Inferential statistics → new. DONE (be744b5c0)**, guard
  `numeric_hypothesis_narrated` (69). The library could not perform a **single**
  hypothesis test — everything `stzDataSet` had was descriptive. Eight now:
  one-sample / Welch / Student / paired t, chi-square goodness-of-fit and
  independence, one-way ANOVA, correlation. Each is two steps — a statistic from
  `stats.zig`, a tail probability from `special.zig` — and `hypothesis.zig` owns
  nothing else.

  **Every test returns a RECORD, never a bare p-value**, and one measurement makes the
  case. The same difference at four sample sizes:

  | n | p | Cohen's d |
  |---|---|---|
  | 10 | 8.37e-1 | 0.067 |
  | 100 | 4.83e-1 | 0.070 |
  | 1000 | 2.56e-2 | 0.071 |
  | 10000 | **1.64e-12** | **0.071** |

  Eleven orders of magnitude in p while the effect size does not move — and d = 0.07 is
  *negligible* (0.2 is the threshold for "small"). So a result carries the statistic,
  df, p, n, **effect size**, the test's name, and a conclusion that overclaims in
  neither direction. **Welch is the default** two-sample test (Student's equal-variance
  assumption is usually untestable, usually wrong, and anti-conservative when it
  fails). An un-runnable test reports `:ran = FALSE` with **p = 1, never 0** — a zero
  from a test that never ran reads as overwhelming significance.

  **I repeated slice 5's mistake, at scale.** The first draft's reference values were
  written from memory of R; **six of nine failed and all six were mine** — hand-computing
  the one-sample case gave 1.7218921, exactly what the code produced, against the
  1.6903 I had invented. Every constant is now verified against an independent hand
  implementation before being pinned, and the file says so.

And the authority rule, which costs nothing and prevents the §2.6(a) class of bug
permanently:

> **Every statistical definition lives in exactly one place — `stats.zig` — and the
> convention is in the name or in a scope, never in a comment.**

So `VariancePopulation()` and `VarianceSample()` both exist and neither is
ambiguous; `Variance()` remains as the documented default (sample, matching the
engine and `stzDataSet` today) rather than being quietly one or the other depending
on which class you happened to hold. `stzListOfNumbers` delegates instead of
re-deriving.

---

## 6. Vendor or build

The precedent: eleven vendored dependencies — curl, ggml, libuv, mbedtls, nghttp2,
pcre2, snowball, sqlite, tree-sitter, utf8proc, zlib — **all C**, all built by
`build.zig`. Two constraints follow, and they decide most rows below:

- **C++ is friction** (buildable, but a new kind of problem here).
- **Fortran is a wall**, which rules out reference LAPACK and the LAPACK half of
  OpenBLAS.

A third constraint is licensing: Softanza should not take an LGPL/GPL dependency
into its engine, which removes the two most famous numeric libraries from
consideration.

| Need | Candidate | License | Lang | Decision |
|---|---|---|---|---|
| Arbitrary-precision integers | Zig `std.math.big` | — | Zig | **Build (already present)** — wire it up |
| Rationals | on top of the above | — | Zig | **Build** — a pair of big ints |
| Arbitrary-precision **decimal** | **mpdecimal** (CPython's `decimal` backend) | BSD-2 | C | **Vendor, phase 2** — correct IEEE-754-2008 decimal is a lot to get right, and this is the reference implementation. Start with a big-int-backed decimal to unblock money, swap in mpdecimal if we need the full spec and its speed |
| — | GMP / MPFR | LGPL-3 | C | **Reject** — licence |
| Vectorised kernels | `@Vector` | — | Zig | **Build** — free, portable, currently 0% used |
| — | SLEEF / Google Highway | Boost / Apache-2 | C/C++ | **Not needed** — `@Vector` covers our kernels; revisit only for transcendental vector math |
| BLAS (dense L1/L2/L3) | BLIS, OpenBLAS | BSD-3 | C (+asm) | **Defer.** Our matrices are table- and ML-sized, ggml already owns heavy f32 matmul, and a vendored BLAS is a large surface for a modest win. Revisit if large dense f64 becomes real |
| LU/QR/Cholesky/SVD/eigen | reference LAPACK | BSD-3 | **Fortran** | **Build in Zig** — Fortran breaks the build model, and we need perhaps six decompositions, not 1700 routines |
| LP / MIP | **HiGHS** | MIT | C++ | **Phase 2 evaluation.** Excellent (it is SciPy's LP backend now) but C++. **Build a Zig revised simplex first** — it retires 1170 Ring lines with no new dependency, and tells us whether we need MIP at all |
| QP | **OSQP** | Apache-2.0 | C | **Vendor when QP is real** — pure C, small, ADMM-based, fits the build model exactly |
| Nonlinear / unconstrained | — | — | Zig | **Build** — L-BFGS and Nelder–Mead are small; L-BFGS becomes trivial once autodiff exists |
| — | NLopt | LGPL (mixed) | C | **Reject for now** — licence friction for the parts that matter |
| Special functions | — | — | Zig | **Build** — erf/lgamma/gammainc/betainc from published mathematics. Cephes is the classic source but its licence status is genuinely murky; the algorithms are not encumbered |
| FFT | **KISS FFT** | BSD-3 | C | **Vendor when spectral work is real** — tiny and permissive. Low priority |
| — | FFTW | GPL-2+ | C | **Reject** — licence |
| Autodiff | — | — | Zig | **Build** — a tape is small, and nothing off-the-shelf fits a Ring-facing engine |
| Quantile sketch | t-digest / KLL | Apache-2 (Java orig.) | — | **Build** — ~400 lines, and the C ports vary in quality |
| RNG | Zig `std.Random` (Xoshiro, PCG, ChaCha) | — | Zig | **Build** — named reproducible streams on top |
| Float↔string | Zig `std.fmt` | — | Zig | **Build** — already shortest-round-trip; fixes §2.1 facts 4–6 for free |
| Heavy f32 tensor math | **ggml** | MIT | C | **Already vendored** — keep for ML, keep the f32/f64 boundary documented |

*Licences above should be re-verified at the moment of vendoring; they are stated
from knowledge, and a licence can change between releases.*

The shape of the answer: **build far more than we vendor**, which is unusual for
this library and is justified by two things — Zig genuinely covers the substrate
(SIMD, wide ints, big integers, threads, float formatting), and the C ecosystem's
best numeric offerings are either Fortran-dependent, C++, or copyleft.

---

## 7. Heritage: naming, style, information design

The rules this plan is bound by, and how they apply:

- **One front door.** `stzNumber` stays the number; `stzListOfNumbers` stays the
  numeric list. Representations and residency are internal. A user should never
  choose between `stzFloat64` and `stzDecimal128` to add two prices.
- **Plain + `Q` twins.** `Plus()` returns data, `PlusQ()` chains. Every mutator gets
  both.
- **Form carries meaning.** `Round()` mutates, `Rounded()` returns a copy,
  `RoundQ()` chains — the existing library-wide convention, unchanged.
- **No `As`/`With`/`To`/`For` in names.** `StzWithPrecision` is a *scope opener*,
  not a method, which is why it may keep `With` — the same shape as the existing
  scope openers. Scope names read as English at the call site or they are wrong.
- **Never define `Len()`.** Counts are `NumberOf...()`/`Count()`.
- **Engine-first for new code**, `Stz*` helpers over Ring builtins.
- **Information design: a number explains itself.** `IsExact()`, `Why()`,
  `Explain()` on a solver result ("optimal in 14 iterations; 3 constraints
  binding"). This is the library's distinguishing habit and it applies especially
  well here, because numeric surprise is almost always about a frame the user could
  not see.
- **No non-ASCII in console output** — relevant to any table/report rendering added
  here.

---

## 8. Phases

Ordered by *correctness debt first, then leverage*. Each ships runnable and leaves
the suites green.

**Phase 0 — pay the three defects. DONE (77a902cd4), guard
`numeric_definitions_narrated` (39).** The variance root cause was in the ENGINE,
not Ring: `list.zig` divided by N while `stats.zig` divided by N-1. The divisor --
the only genuinely ambiguous part -- now lives once in
`stats.varianceDivisor(count, kind)` and `list.zig` asks for it;
`VarianceSample`/`VariancePopulation` + Stddev twins exist on both `stzList` and
`stzDataSet`. **Behaviour change: `stzList.Variance()` now returns the sample
statistic** (nothing in the suite or the narrations asserted the old value --
checked first). `ConfidenceInterval` keeps z but stops misrepresenting itself: the
supported levels are a published 8-entry table at full precision, an untabulated
level RAISES naming what is missing, and `ConfidenceIntervalXT()` reports
`:method`/`:critical`/`:n` plus a note that warns *in words* when a small n makes
the approximation understate the interval. Both dead aliases fixed -- and auditing
every `This.X()` call in `stzDataSet` against its inheritance chain found a **second
one nobody knew about** (`BoxPlotData()` → `BoxPlot()`, real name `BoxPlotStats()`).
That audit is cheap and worth repeating on any class with a long alias tail.

**Phase 1 — the numeric tower, exactness visible.** Wire the existing engine big
integers into `stzNumber`; add rationals; add a big-int-backed decimal sufficient
for money; publish the promotion ladder; add `IsExact()`/`Why()`/`Same()`. Fix float
display through Zig's shortest-round-trip formatter. *(This is the old
`SOFTANZA_NUMBER_ENGINE_PLAN` phases 1–2 and 4, absorbed.)*

> **SLICE 1 DONE (dbcd48a06), guard `numeric_exactness_narrated` (39).** And it was
> far less invasive than this plan assumed, because of one discovery: **`stzNumber`
> stores its value as a STRING, not a Ring number.** A 32-digit integer was already
> held faithfully; the digits were never the problem. Every operation funnels
> through ONE chokepoint (`pvtCalculate`) whose first act was
> `This.NumericValue()` — an f64. So the fix is a routing change at one place.
>
> Two defects were there, both silent and both worse than phase 0's. First, the
> result's **decimal places came from the receiver alone** for every operation, so
> `0.1 * 0.1` was `0.0`, `19.99 * 0.15` was `3.00`, `1 + 0.001` was `1.00` and
> `1 / 8` was `0.13` — *every decimal multiplication in the library lost
> precision*. Second, integers past 2^53 were flattened. Now `+ - * % ^ /` on
> decimal operands are computed on the **scaled integers** through the engine, exact
> by construction: `19.99 * 0.15` becomes `1999 * 15 = 29985` with the point four
> from the right. Places are per-operation (max for `+ - %`, the **sum** for `*`),
> and division asks the engine whether scaling by a power of ten divides evenly —
> the smallest that does gives the shortest exact form, so `1/8` is `0.125` not
> `0.125000`, while `1/3` reports itself approximate. Small integer arithmetic keeps
> the f64 fast path, where it is exact anyway.
>
> The **exactness register** landed with it: `IsExact()`/`IsApproximate()`/`Why()`/
> `Exactness()`, plus `Same()` for equality as numbers rather than as rendered text
> (`"1.50".Same("1.5")` is TRUE; Ring's `=` says FALSE).
>
> **The blast radius was measured, not hoped.** `pvtCalculate` serves ~30 operations
> and 70 of the 88 number tests use comment-based `#-->` expectations that nothing
> checks, so a silent output change would have gone unseen. Capturing all 88 outputs
> before and diffing after: 60 identical, and once timing lines are filtered only 4
> differ — 2 random-number tests and 2 whose only change is a line number inside a
> *pre-existing* R14 trace. **Zero behavioural change outside the intended fixes.**
> That diff also caught a regression I had introduced: the first version applied the
> new place rule to `sin`/`cos`/`log`/`sqrt` too, coarsening trigonometry from five
> places to two. Those were never the defect, and the fix is now confined to
> arithmetic.
>
> **SLICE 2 DONE (6b67b814c), guard `numeric_no_loss_narrated` (31).** Slice 1 fixed
> the arithmetic; this closes the hole one step earlier, at CONSTRUCTION. `"" + n`
> renders through Ring's process-global `decimals()`, so `new stzNumber(number("1e-20"))`
> stored the string `"0.00"` — and since the string *is* the value here, the number
> was **destroyed, not mis-shown**: `NumericValue() > 0` answered FALSE.
>
> New engine function `stz_number_plain_shortest` raises precision until the text
> parses back as the same f64, so the first form that works is the shortest that
> loses nothing — **plain and never scientific**, because `"1e-20"` would defeat
> `IntegerPart`, `NumberOfDigits` and slice 1's scaled-integer arithmetic, all of
> which expect digits and at most one dot.
>
> **The fix is deliberately narrow: the ordinary rendering is replaced only when it
> fails to round-trip.** `0.10` has lost nothing and is left alone. Measured: zero
> of the 88 number test outputs changed. A pleasing consequence is that `1e-20 * 2`
> is now exactly `0.00000000000000000002`, because a plain decimal string is
> something slice 1's exact path can use.
>
> **The ladder is published too:** `Representation()` reports `:integer` /
> `:bigInteger` / `:decimal`, with `IsBigInteger()`/`IsDecimalNumber()`. `:rational`
> and `:complex` are named here and not built, so they are never reported — a ladder
> that claims rungs it does not have is worse than a short one.
>
> Also repaired while verifying: the engine's `process: uptime` test asserted
> `uptime_ns() > 0` on the FIRST call, but `uptimeNanos()` creates its baseline
> lazily *on* that call, so the answer is ~0 by construction. It passed or failed
> according to how much unrelated code ran first — which is why adding code to
> `number.zig` turned it red. It now asserts what is true and worth knowing:
> non-negative, non-decreasing across a measurable gap, and an *uptime* rather than a
> wall clock (`< 3600s`, the epoch bug it exists to catch).
>
> **SLICE 3 DONE (6b18cefb6), guard `numeric_rationals_narrated` (42) — PHASE 1 IS
> COMPLETE.** Rationals: the representation decimals cannot supply. Slice 1 was
> honest that `1/3` has no finite decimal form and reported it approximate; as a
> fraction it is exact, and `"1/3" + "2/3"` is exactly `1`.
>
> New engine function **`stz_bigint_gcd`** — every rational operation ends in a
> reduction, or denominators grow without bound and equal numbers stop comparing
> equal, so it belongs in the engine rather than as a Euclid loop in Ring paying two
> crossings per iteration (this plane's own measurement). It also handles
> `gcd(n, 0)`, which Zig's gcd rejects. Results are always in lowest terms, sign on
> the numerator, and **collapse to a plain integer when the denominator reduces to
> 1** — so `"4/2"` is `"2"` and `Representation()` then honestly says `:integer`.
>
> Mixing works because **a decimal IS a fraction with a power-of-ten denominator**:
> `0.25` becomes `25/100`, so `1/2 + 0.25` is `3/4` and `1/3 * 3` is exactly `1`
> (as a decimal that last one is `0.999999`). `Same()` compares across
> representations by cross-multiplying on big integers, never touching a float.
>
> **Honest limit:** `NumericValue()` still returns an f64, because everything
> numeric eventually must. Stay in `Content()`/`Same()`/the arithmetic and the value
> is exact.
>
> Also repaired: `new stzNumber("123.")` left its content EMPTY (that constructor
> branch appended to a local and never assigned). **Two existing tests documented
> the correct answer and were failing silently against it** — `55_content` records
> `#--> 123.0` and printed nothing. The test was right and the implementation was
> broken, which is the strongest evidence a fix is correct rather than merely
> different.
>
> **A method note worth keeping:** the first blast-radius diff of this slice was
> worthless — two snapshots captured from different working directories, only 21 of
> 89 basenames matching. Redone with `git stash`: rebuild at the committed state,
> capture, restore, rebuild, capture, diff with timing lines filtered. Four files
> differ: two random-number tests, and the two above, both moving from wrong to
> right.

**Phase 2 — numeric scope. DONE, in three slices, and the shape CHANGED from the
sketch below.**

> This section originally proposed `StzWithPrecision(50, func{...})` — an ambient
> block. Building it, [SCOPE_ORIENTED_PROGRAMMING.md](SCOPE_ORIENTED_PROGRAMMING.md)'s
> move **M3 says the frame belongs *in the verb at the call site***, and both shipped
> instances obey it: regex says `MatchLine()` rather than `Match()` with a flag set
> three lines up; system says `App(:x).System()` rather than a floating
> `CurrentSystem()`. **An ambient block is closer to the disease the paradigm exists
> to cure**, so the implementation follows the paradigm and not this sketch.
>
> **Slice 1 (fd84e53f2)** — repair rounding before naming its mode. `RoundedTo(0)`
> of `100.4` returned **`1`**: the trailing-zero tidy ran over the whole string, so
> once rounding removed the decimal point it ate the integer's zeros. **No test
> caught it because none ever rounded a value whose result ends in a zero** — the
> tests covered the method, not the shape of value that breaks it.
>
> **Slice 2 (27bdf53d6)** — the tie rule, in the verb: `RoundedToHalfEven(2)` /
> `RoundedToHalfUp(2)`. Half-up is **biased** (every tie moves the same way, so a
> long ledger drifts upward); half-even splits them and the bias cancels. It rounds
> the **digits, not a double** — through an f64 the nearest double to `1.005` is
> `1.00499…`, so it is not a tie at all and both modes answer `1.00`; on the digits
> half-up gives `1.01`, which is the decimal truth a price wants.
>
> **Slice 3 (c26e30f67, guard 7263f2ce3)** — the regime carried by the value, since
> unlike a regex scope (per match) or a system scope (per object), a number's regime
> is a property of the **quantity** and travels through a whole calculation:
> `StzMoneyQ` / `StzExactQ` / `StzMeasuredQ` / plain. Applied in `Update()`, the one
> point a value changes, so it survives arithmetic and rounding alike. `:exact`
> **raises** rather than approximating. And **infinities and NaN are now refused** —
> Ring answers `isNumber(inf)` with TRUE, and stzNumber used to store the text
> `"inf"` and then call it a `:decimal`.
>
> Guards: `numeric_rounding_narrated` (19), `numeric_tie_rule_narrated` (34),
> `numeric_regime_narrated` (27). Blast radius measured at every slice: nothing in
> the 89-file suite moved.

**Phase 3 — residency. DONE.** `stzNumBuffer`, engine-is-truth with materialised
views; `stzMatrix`'s dual representation resolved; one summation authority; and an
explicit door between the list tier and the resident tier. **This is the phase that
makes every later phase worth doing** — §2.5.

> **SLICE 1 DONE (13266934d), guard `numeric_residency_narrated` (26): THE BUFFER.**
> New engine module `numbuf.zig` — a contiguous, mutable f64 buffer the engine owns,
> with 1-based access, fill/range written straight into resident memory, elementwise
> ops **in place**, and the reductions. Every operation either mutates in place or
> returns a scalar; **none marshals**. Hosted in the stats DLL because it asks
> `stats.zig` for the variance convention and because a handle table is per-DLL.
>
> **§2.5's claim, re-measured on the same 200 000 numbers:** five reductions
> marshalling each time = **0.19s**; one crossing to become resident plus the same
> five reductions = **0.01s**, a **19×** difference. Twenty full elementwise passes
> over the resident data cost essentially nothing.
>
> **The polarity rule, stated once:** the **engine copy is the truth** here.
> `stzList` does the opposite — Ring owns the content and the engine handle is a
> cache invalidated on write — which is right for a general list. `ToList()`
> materialises a view when you want to look.
>
> Two decisions worth naming. The sum is **Neumaier-compensated**: add 1e16 then a
> thousand 1.0s and a naive total answers exactly 1e16, because each 1.0 falls off
> the mantissa. It costs one extra add per element and removes an error class that is
> invisible until the data is big — precisely when a buffer is used. And variance
> asks `stats.varianceDivisor` rather than choosing a divisor, since phase 0 exists
> because two modules once chose their own.
>
> One burden named rather than hidden: **Ring has no destructors**, so a buffer holds
> engine memory until `Free()`.
>
> *Build note:* `engine.zig`'s `test { _ = X; }` block is what COLLECTS a module's
> tests — importing it is not enough. The count sat at 1637 until `numbuf` was added
> there; it is now 1642.
>
> **SLICE 2 DONE (ba4c54ec9), guard `numeric_matrix_truth_narrated` (12): THE DUAL
> REPRESENTATION.** `stzMatrix` held its values twice and kept them in step by asking
> every writer to remember to invalidate. **Seventeen of the twenty-three writers did
> not** — the whole `Replace*` family among them — so `Determinant()` after
> `ReplaceRow(1,[99,2])` still answered `-2` where the content plainly said `390`.
>
> Adding the seventeen missing calls would have fixed today and left the eighteenth
> method to reopen it, so the **discipline is removed rather than relied upon**: the
> engine matrix is now a **transient**, rebuilt from the Ring content when needed.
> Nothing was gaining from the cache — every call site is a one-shot engine
> operation. Cost of always rebuilding, measured: fifty transposes of a 50×50, i.e.
> fifty rebuilds of 2500 cells, **0.05s total**, about a millisecond each.
>
> *Found while measuring, not fixed here:* the engine's determinant is **naive
> cofactor expansion, O(n!)** — fine at 2×2, hard work at 8×8, impossible past about
> ten. **FIXED in phase 4 slice 4 (e549ec945): LU decomposition, O(n³)** -- and n<=3 keeps
> exact direct formulae. What follows describes the state before that. `Determinant()`
> is for small matrices.
>
> **SLICE 3 DONE (cc8fb24d8), guard `numeric_summation_narrated` (16): ONE
> SUMMATION.** Slice 1 gave the buffer a compensated sum while `stats.zig` and
> `list.zig` kept naive ones, so the **same 1001 numbers gave two different answers**
> depending on the door: `stzListOfNumbers.Sum()` and `stzDataSet.Sum()` both lost a
> thousand ones that `stzNumBuffer.Sum()` kept. **The phase-0 disease recreated in a
> new place by the very phase that added the correct version.**
>
> Summation moved next to the variance divisor in `stats.zig`: `compensatedSum` for a
> slice, a `Compensated` accumulator for callers that filter or convert as they walk.
> `list.zig` had **three** naive loops in `sum` and three in `mean`, one per
> representation; all six now feed the accumulator.
>
> Blast radius measured, not assumed: the 74 tests across number / listofnumbers /
> stats / dataset / matrix that touch a sum or a mean, captured against both engines.
> Six files differ and **every difference is a timing line** — when addends are of
> similar magnitude the compensation term stays zero and the two algorithms are
> bit-identical.
>
> **SLICE 4 DONE (0ddf438fc), guard `numeric_tier_door_narrated` (13): THE DOOR —
> and a departure from this plan.** The plan said "move `stzListOfNumbers` onto the
> buffer". Reading the class decided otherwise: of its **eleven hundred methods**,
> nearly all are list work that genuinely wants a Ring list. Moving its truth into the
> engine would make a thousand methods worse to make ten better.
>
> What it owed the numeric plane was an explicit, cheap way **out** —
> `ToStzNumBuffer()` / `ToStzListOfNumbers()`, one crossing each, **named at the call
> site** so the tier you are in is visible rather than guessed at. Over a million
> numbers, eight reductions: **0.31s the ordinary way, 0.03s across the door.**
>
> **The copy that nearly hid it.** Written first as `new stzNumBuffer(This.Content())`
> the door measured **slower** than the ordinary path — 0.34s against 0.31s.
> `Content()` was assigning the field to a local before returning it, so asking for
> the numbers cost **two full copies of a million-element list** before the buffer had
> marshalled anything, and those copies cost **more than the entire crossing they sat
> in front of**. Reading `@aContent` directly took the door to 0.03s; removing the
> pointless local from `Content()` took that method from **0.32s to 0.12s** per call,
> provably safe because a probe confirms Ring copies a list on return either way.
>
> **PHASE 3 COMPLETE.** 14 number guards, 392 assertions, engine 1643/1643.

**Phase 4 — kernels. STARTED.** SIMD reductions and similarity; Neumaier/Welford
stability; threaded reductions and matmul; then LU/QR/Cholesky/eigen/SVD; then
special functions.

> **SLICE 1 DONE (1fdc2eda5), guard `engine_is_optimised_narrated` (6): THE ENGINE
> WAS NOT BEING COMPILED.** Before writing a kernel, a measurement: `build.zig`
> asked for `standardOptimizeOption(.{})`, which defaults to **Debug**, and every
> documented build command in this repo is a bare `zig build`. The DLLs are not
> tracked in git, so **every developer and every deploy has been running an
> unoptimised engine.** On 2M engine-resident f64s, twenty passes each:
>
> | | Debug | ReleaseSafe | |
> |---|---|---|---|
> | Sum | 0.14s | 0.04s | 3.5× |
> | Mean | 0.14s | 0.04s | 3.5× |
> | Variance | 0.22s | 0.07s | 3.1× |
> | Dot | 0.08s | 0.03s | 2.7× |
> | Scale | 0.05s | 0.01s | 5× |
>
> On string / list / matrix work the same change buys ~15%, because there the
> marshalling dominates. **That contrast is the point: phase 3 moved computation
> into the engine, so from here on the engine loop IS the cost.** Doing this before
> the first SIMD kernel is the difference between optimising code and optimising
> code that was never being compiled.
>
> **ReleaseSafe, not ReleaseFast** — it measured the same on every kernel while
> keeping bounds/overflow/alignment checks, and since Debug had those too this
> changes **no runtime semantics, only the optimiser**.
>
> *Two traps.* `standardOptimizeOption(.{ .preferred_optimize_mode = ... })` does
> NOT change the default — it swaps `-Doptimize` for a `-Drelease` boolean and
> leaves Debug in force; declare the option with `b.option` instead. And turning
> optimisation on turns Zig's **implicit C sanitiser** on with it: tree-sitter began
> trapping on *any* parse with SIGILL and no message (a bare `ud2`, where a Zig
> safety panic would print). UBSan is now off for that one vendored library, whose
> `parser.c` is machine-generated and does deliberate unaligned access; pcre2,
> utf8proc and sqlite still opt *in* to trap mode.
>
> **SLICE 2 DONE (7621cc5e1): THE SUMMATION AUTHORITY IS VECTORISED, and the shape
> is the opposite of the obvious one.** Measured over 4M f64s, thirty passes:
>
> | | scalar | `@Vector(8)` | |
> |---|---|---|---|
> | sum naive | 67.6ms | 35.8ms | 1.9× |
> | **sum compensated** | **145.1ms** | **58.5ms** | **2.5×** |
> | dot | 77.5ms | 62.9ms | 1.2× |
>
> The naive sum is the textbook SIMD candidate and gains *least* of the two, because
> LLVM already unrolls it. The **compensated** sum gains most — its loop-carried
> dependence is exactly what stopped the compiler, so **being numerically careful is
> what blocked the optimiser**, and lane-splitting gives the parallelism back. Dot
> gains least of all: two streams, bandwidth-bound not compute-bound.
>
> Only `compensatedSum` changed, and because phase 3 slice 3 made summation ONE
> authority, every door got it at once — through Ring, `Sum` and `Mean` 0.13s →
> 0.06s (2.2×). Variance moves only to 0.15s because **its own sum-of-squares loop
> is still scalar, and is now the dominant term there — the next target.**
>
> Accuracy is not traded for speed: each lane compensates its own subtotal and the
> lanes combine through the scalar accumulator. Pinned by a test covering the
> pathological case with the big value in a lane *and* in the ragged tail, every
> length 0–40 against the scalar form, the empty slice, and mixed signs.
>
> **SLICE 3 DONE (a0fdc7689), guard `numeric_variance_authority_narrated` (14): ONE
> CENTERED SUM OF SQUARES — and the THIRD time this shape has appeared.** Variance
> was the laggard after slice 2 (0.20s → 0.15s only), because its second pass was
> still scalar. Looking for that one loop found **five** of it: `stats.zig`,
> `numbuf.zig`, `list.zig`, and twice in `pivot.zig`. Each round of duplication had
> a different reasonable defence:
>
> | phase | what was duplicated | consequence |
> |---|---|---|
> | 0 | the variance **divisor** | stzList said 4, stzDataSet said 4.57 |
> | 3 | the **summation** | 1e16 + 1000 ones gave two different totals |
> | 4 | the **sum of squares** | pivot.zig also hardcoded its divisor |
>
> **Phase 0 deliberately left the ss loop with its data, reasoning that only the
> divisor was ever ambiguous. That was wrong in an instructive way:** nobody
> disagreed about the arithmetic and it still drifted — the fifth copy hardcoded
> `values.len - 1` *and* used a naive mean, agreeing with the library only by the
> accident that N-1 is the documented default. **Duplication invites divergence even
> where there is no ambiguity to diverge about.**
>
> `centeredSumOfSquaresOf` is generic over the element type so list.zig's dense i64
> and dense f64 share one implementation — needing a loop per type is how five
> copies started. **A useful negative result: the Chan–Golub–LeVeque correction was
> implemented, measured, and REJECTED** — 11% cost, no digit changed, because the
> mean it corrects for is already compensated. Fixing the authority upstream removed
> the need for the patch downstream.
>
> Second finding: the six variance/stddev bridges used `getLC`, which calls
> `ensureBoxed()` — **one heap allocation per element**, so a million integers were
> boxed to compute a mean plus one pass. Sum/Mean/Min/Max were already dense-aware.
> Measured: ss loop 66.2→36.0ms (1.8×), numbuf variance 0.12→0.09s, **stzList
> variance over 1M ints 0.13→0.04s (3.2×)**.
>
> **SLICE 4 DONE (e549ec945), guard `numeric_decomposition_narrated` (24): LU, and
> the determinant stops being O(n!).** New engine module `linalg.zig`. LU with
> partial pivoting first, because a determinant, a linear solve, an inverse and
> later least squares are one factorisation read differently.
>
> The determinant was naive cofactor expansion — O(n!) time **and O(n!)
> allocations**, since it allocated a submatrix per recursion level. 10×10 was 3.6M
> calls; 20×20 unfinishable. **`inverse`, a few lines below it, had always done
> Gauss-Jordan with partial pivoting in O(n³)** — the machinery was next to it the
> whole time. A wrong asymptotic complexity does not announce itself: every existing
> test used 2×2 or 3×3, where cofactor expansion is *optimal*. 40×40 now answers
> 2⁴⁰ instantly.
>
> `SolveFor` is new capability wired the right way. It **already existed** as a
> Ring-side Gauss-Jordan, and the instinct was to add an engine solve beside it —
> exactly how LCM/GCD became divergent twins answering 0 instead of 24. The engine
> path went *inside* the existing method, preserving its documented refusal
> contract. 60×60, ten solves: **0.21s → 0.01s**.
>
> **The blast-radius diff earned its keep again:** `test_matrix_regression` asserted
> `Determinant() = 1` exactly for `[[1,2,3],[0,1,4],[5,6,0]]`, and LU gives
> 0.9999999999999964 — the same value NumPy gives, so normal rather than a defect.
> The fix was *not* to relax the assertion: `linalg` already special-cased n≤2 with
> exact direct formulae, and a 3×3 is six products of the input values with **no
> division**, hence exact for integer entries. Adding the rule of Sarrus restored
> byte-identical output across all 56 matrix tests. The cut is at 3 because a 4×4
> closed form needs 24 products.
>
> **SLICE 5 DONE (d5b84416d), guards `numeric_special_functions_narrated` (40) +
> `numeric_definitions_narrated` rewritten (42): SPECIAL FUNCTIONS, and §2.6's
> confidence-interval defect is finally CLOSED rather than merely honest.**
>
> New engine module `special.zig`, and **two core functions with everything derived
> from them** — because a dozen independent rational approximations is exactly how a
> library acquires two answers for one quantity:
>
> | workhorse | derives |
> |---|---|
> | regularised incomplete **gamma** `P(a,x)`, `Q(a,x)` | erf, erfc, normal CDF, chi-square CDF |
> | regularised incomplete **beta** `I_x(a,b)` | Student t CDF, F CDF |
>
> So `erf` is not an approximation *of* erf; it **is** `P(1/2, x²)`, sharing every
> digit with the chi-square CDF. Zig's std supplies `lgamma`/`gamma` — nothing was
> vendored. `erfc` comes from `Q` rather than `1 - erf`, which is not tidiness:
> erfc(6) ≈ 2.15e-17, so `1 - erf(6)` is **exactly 0** in a double, and a p-value
> lives in that tail.
>
> **Quantiles are the CDF bisected**, not a separate approximation of each inverse.
> ~60 CDF evaluations instead of ~20 flops — irrelevant for something computed once
> — and in exchange **an inverse cannot disagree with the function it inverts**.
>
> `ConfidenceInterval` is now genuinely t-based (df = n−1), reports `:method = :t`
> and `:df`, and accepts **any** level. At n = 5 the margin goes 1.96·s/√n →
> 2.776·s/√n: **41.7% wider, exactly as phase 0's warning predicted.** The eight-row
> z table is *gone*, not kept alongside — it held 1.959964 where the true value is
> 1.959963984540054. The small-sample warning is gone too, since t is correct at
> every n and converges on z by itself.
>
> **Two testing lessons, both learned by being wrong first.** (i) The F constant was
> transcribed wrong at the 9th digit and the test failed against *correct* code —
> which is the argument for **identity checks** (`F(0.95;1,v) = t(0.975;v)²`,
> `χ²(x,1) = 2Φ(√x) − 1`, `P+Q=1`, beta symmetry): a mistyped reference constant
> looks exactly like a broken implementation, and an identity cannot be mistyped into
> agreement. (ii) "t equals z to six decimals at df=100000" failed *correctly* — t is
> still 2.37e-5 wider. Measuring the gap over four decades showed it falls by 10× per
> 10× of df, so the guard now asserts the **O(1/df) rate** instead of a tolerance. A
> rate is a mathematical property no approximation error can fake.
>
> **SLICE 6 DONE (f0b3e7890), guard `numeric_similarity_narrated` (29): SIMILARITY —
> and THIS SECTION'S OWN CLAIM ABOUT IT WAS WRONG.** Pillar 4 item 1 says
> `similarity.zig`'s functions "are on the hot path for every embedding comparison in
> the NLP and neural tiers." They were not reachable from it at all:
> `ring_bridge_similarity.zig` exposed only fixed **three-dimension** variants, and
> even `CosineFromLists` insisted on exactly three elements.
>
> **Underneath that, a silent zero.** Every function began `if (dim <= 0 or dim >
> 1024) return 0.0` — not an error, not a clamp. Two *identical* 1536-dimension
> vectors scored **0 cosine similarity**, which reads as "completely unrelated". And
> 1024 is exactly where real sentence embeddings live: 384, 768, 1024, 1536.
>
> **The two defects were each other's cover.** The cap never fired because the bridge
> was too narrow; the bridge was never widened because nothing needed it. Widening
> alone would have turned a latent trap into a live one, so both went in one slice.
> There was nothing to cap: every function is handed its length.
>
> All five vector loops vectorised; general-dimension bridges added (3-arg forms
> kept, they are published); `stzSimilarity`'s four `*FromLists` widened plus
> `Cosine`/`Euclidean`/`Manhattan`/`Dot` aliases, `MagnitudeOf`, `NormalizedList`;
> and `StzSemanticSimilarity`'s Ring dot-product loop over 384–1536 elements replaced
> by one engine call.
>
> | 200k cosines | scalar | `@Vector(8)` | |
> |---|---|---|---|
> | dim 384 | 33.4 ms | 9.7 ms | 3.44× |
> | dim 768 | 66.9 ms | 18.3 ms | 3.66× |
> | dim 1536 | 135.2 ms | 40.1 ms | 3.37× |
>
> **The best ratio of the phase, and the reason generalises: cosine accumulates THREE
> quantities per element loaded** (the dot product and both squared magnitudes), so it
> is compute-bound. A plain dot product reads two arrays to do one multiply-add and is
> bandwidth-bound — which is why it gained only 1.2× in slice 2. **Arithmetic per byte
> loaded is what decides whether SIMD pays.** Jaccard is deliberately left scalar:
> merging two sorted runs is inherently sequential.
>
> **Left undone, deliberately:** `_StzEmbedInto` copies an embedding out of the engine
> **one element at a time** (`StzEngineNeuralEmbedAt(i)`) — 384–1536 bridge crossings
> per embed. There is no bulk accessor on `g_emb`, and no GGUF model is present here,
> so a new neural bridge could not be exercised end to end. Adding untested code on an
> unrunnable path is worse than documenting the cost.
>
> **SLICE 7 DONE (07d3b443e), guard `numeric_least_squares_narrated` (31): QR,
> CHOLESKY, LEAST SQUARES — and the gap closed is a CAPABILITY, not a speed one.**
> An **overdetermined** system — more equations than unknowns, which is what fitting
> a model to data always is — had no answer anywhere in the library. `SolveFor` needs
> a square matrix; `stats.zig`'s regression is *simple* regression, two series in,
> one slope and one intercept out. There was no route to a fit with two predictors.
>
> **Householder QR, NOT the normal equations**, and the shortcut was tempting: least
> squares is often taught as "solve `A'A x = A'b`", one line on top of the LU solve
> already in hand. But forming `A'A` **squares the condition number** — a problem
> that loses 8 significant digits loses 16, and a double has 16. Householder costs
> about twice as much and is unconditionally stable. Q is never formed, only applied.
>
> **Cholesky** is the cheap case: half the work of LU (n³/3 vs 2n³/3) and **no
> pivoting**, because a positive-definite matrix cannot produce a zero pivot — a
> theorem, not an optimisation. It also gives the cheapest positive-definiteness
> *test* there is, since the factorisation exists iff the property holds.
>
> Ring surface: `LeastSquaresFor` (+ `LeastSquares`/`BestFitFor`), `CholeskyFactor`,
> `IsPositiveDefinite`.
>
> **What it refuses is part of the design.** Rank deficiency → `[]`: dependent
> columns mean infinitely many vectors share the minimum residual, and silently
> picking one is the worst option. Underdetermined → raises: infinitely many *exact*
> solutions, and least squares has no opinion between them (that is minimum-norm, a
> different problem needing a different decomposition).
>
> **Tested by identity and by definition**, per slice 5's lesson. Cholesky's `L·Lᵀ`
> is multiplied back out; its solve is compared against **LU's**, and QR's against
> LU's too — factorisations sharing no code and no algorithm. The inexact fit is
> checked against what least squares *means*: the residual orthogonal to every column
> of A, and perturbing either coefficient in either direction increasing the squared
> residual. A minimum is a minimum.
>
> **SLICE 8 DONE (504c1df36), guard `numeric_eigen_narrated` (26): SYMMETRIC
> EIGENVALUES, CONDITION NUMBER, RANK — the decomposition that EXPLAINS the others.**
> Slice 7's `IsPositiveDefinite` answers by whether a Cholesky factorisation exists;
> a symmetric matrix is positive definite exactly when all its eigenvalues are
> positive. **Two algorithms sharing no code, no loop and no idea, answering one
> question** — so agreement is independent evidence, and it checks slice 7 from
> outside. The guard runs that over six cases including the semi-definite boundary.
>
> **Cyclic Jacobi, not the QR iteration LAPACK uses**, and the trade is deliberate:
> Jacobi is slower on large matrices (O(n³) per sweep, several sweeps) but is ~80
> lines with no tridiagonal reduction, no shift strategy and no deflation — and it
> resolves the **small** eigenvalues to high relative accuracy, which is exactly what
> a condition number and a rank test depend on, since both are decided by the
> smallest one. Our matrices are table- and covariance-sized. If large dense
> symmetric problems become real, the answer is tridiagonal QR, not a faster Jacobi.
>
> **Symmetric only, and that is a refusal rather than a limitation.** A general matrix
> has *complex* eigenvalues, needing a different algorithm and a complex type we do
> not have. Handed one, this **raises** — rather than returning the spectrum of
> `(A + A')/2` and letting the caller believe it belongs to A, which is the failure
> shape this phase has now found four times. Symmetry is judged with a *relative*
> tolerance, since data out of a real computation is rarely symmetric to the last bit.
>
> Ring surface: `EigenValues`, `EigenVectors`, `IsSymmetric`, `ConditionNumber`,
> `Rank`, `IsSingular`. Two choices worth stating: a singular matrix's condition
> number is **infinite**, not a large finite number; and rank counts eigenvalues
> non-negligible **relative** to the largest, because an absolute cutoff would call a
> matrix of uniformly tiny entries rank zero when scaling cannot change a rank.
>
> **Tested by definition and invariant, not by transcribed constants:** `A·v = λ·v`
> componentwise for every eigenpair; orthonormal eigenvectors; the **trace** equal to
> the sum of the eigenvalues and the **LU determinant from slice 4** equal to their
> product, tying the two slices together through unrelated code; a diagonal matrix
> whose spectrum is known by inspection; and a **repeated** eigenvalue (2·I), where a
> naive rotation formula divides by zero.
>
> **SLICE 9 DONE (40fd49580), guard `numeric_svd_narrated` (32): SVD + RECTANGULAR
> RANK — and it exposed a silent wrong answer in slice 7 and an inconsistency in
> slice 8. PHASE 4 IS COMPLETE.**
>
> **THREADING: MEASURED, THEN DECLINED.** Pillar 4 item 3 says "thread the big ones".
> Slice 6 had already shown the dot product is bandwidth-bound, and threads share one
> memory bus, so this was measured before writing anything. 12 logical CPUs:
>
> | kernel | 1t | 2t | 4t | 8t | 12t |
> |---|---|---|---|---|---|
> | sum N=100k | 1.00× | 0.16× | 0.11× | 0.06× | **0.04×** |
> | sum N=1M | 1.00× | 0.82× | 0.88× | 0.55× | 0.41× |
> | sum N=16M | 1.00× | 1.48× | 2.18× | 2.53× | 2.72× |
> | matmul 64² | 1.00× | 0.14× | 0.11× | 0.06× | **0.04×** |
> | matmul 256² | 1.00× | 1.48× | 2.43× | 2.38× | 2.22× |
> | matmul 512² | 1.00× | 2.06× | 3.06× | 4.09× | 4.46× |
>
> Spawn+join is **128 µs per thread**. Below ~16M elements threading is **25× slower**
> — 128 µs of overhead against a 4 µs kernel — and even at the best sizes 12 cores buy
> 2.7–4.5×, not 12×: the sum is bandwidth-bound and matmul at 256² *peaks at 4 threads
> then declines*. §2.5 established that this library's numeric data is table-sized,
> which is exactly where threading is catastrophic rather than merely unhelpful.
> **Declined, with the numbers recorded so nobody has to rediscover them.** A
> persistent pool would remove the spawn cost but not the bandwidth ceiling.
>
> **SVD**: one-sided Jacobi, not Golub–Kahan — the same rotation idea as slice 8
> (orthogonalise pairs of *columns* until the column norms **are** the singular
> values), ~100 lines instead of several hundred, and high relative accuracy on the
> small values, which is what rank and conditioning are decided by. `Rank` and
> `ConditionNumber` now accept rectangular matrices; square symmetric still routes
> through eigen. Plus `SingularValues`, `IsFullRank`, `IsRankDeficient`.
>
> **DEFECT 1 (slice 8).** A rank test and a condition number ask the same question —
> "is the smallest value negligible?" — and used *separate rules*. One-sided Jacobi
> leaves a dependent column at rounding level, not zero, so a rank-2 5×3 reported rank
> 2 alongside a condition number of **8.97e16** — finite, for a singular matrix. Slice
> 8 had it too (rank 2, 1.22e16); its test passed only because `[[1,1],[1,1]]` happens
> to give an **exact** zero eigenvalue. `negligibleThreshold` is now the one definition
> of numerically-zero, asked by all four functions, with a test pinning that they can
> never disagree.
>
> **DEFECT 2 (slice 7), and far worse — a silent wrong answer.** `QR.isFullRank` tested
> `d == 0` *exactly*. On a 3×2 with a duplicated column `rdiag` comes out exact, which
> is why slice 7's test passed. On a **200×4 design matrix with a redundant predictor
> it does not**: `isFullRank` answered TRUE for a rank-deficient system, `qrSolve`
> back-substituted through a near-zero pivot, and `LeastSquaresFor` returned
> **coefficients around −9.7e12 as though they were a fit**. Found because the SVD rank
> said 3 of 4 while the fit cheerfully succeeded.
>
> **Both defects are the same mistake made twice: testing a floating-point quantity
> against exact zero, and choosing a test case small enough that it really was zero.**
> The lesson generalises past linear algebra — if a test of "is this zero?" passes,
> check whether it passes at *scale*.
>
> **PSEUDO-INVERSE DONE (f17404c55), guard `numeric_pseudoinverse_narrated` (26) —
> added between phases 4 and 5, and it CLOSES A DOOR SLICE 7 DELIBERATELY LEFT OPEN.**
> `LeastSquaresFor` refuses a rank-deficient system, and its comment says why:
> infinitely many coefficient vectors share the minimum residual, "and least squares
> does not choose between them — that is minimum-norm, a different problem needing a
> different decomposition." **This is that decomposition.** `A⁺b` both minimises
> ‖Ax − b‖ *and* is the shortest vector that does — principled rather than arbitrary,
> which is exactly why it can be offered where least squares declines.
>
> | A is | A⁺ gives |
> |---|---|
> | square, invertible | exactly the inverse |
> | tall, full rank | exactly the least-squares solution |
> | rank deficient | the **minimum-norm** least-squares solution |
> | wide | the minimum-norm **exact** solution |
>
> `A⁺ = V S⁺ U'`, two lines on the SVD. One subtlety: "negligible" must be the *same*
> judgement rank and conditioning use, so it asks `negligibleThreshold` — the authority
> that exists because slice 9 caught those two disagreeing. The wide case transposes
> internally (`pinv(A) = pinv(A')'`), since a pseudo-inverse refusing half of all shapes
> would be a poor generalisation of an inverse.
>
> **Tested by the four Penrose conditions**, which *define* A⁺ uniquely — `A A⁺ A = A`,
> `A⁺ A A⁺ = A⁺`, and both `A A⁺` and `A⁺ A` symmetric — across eight shapes including
> singular, wide and the zero matrix. Cross-checked against the LU inverse and slice 7's
> QR solution, neither of which shares code with the SVD. Where it goes *beyond* them,
> the minimum-norm property is **demonstrated**: shifting along the null space preserves
> the residual exactly while lengthening the vector.
>
> Ring: `PseudoInverse`, `MinimumNormSolutionFor`. **`LeastSquaresFor` remains the right
> call for a full-rank design** — a refusal there is *information* (the predictors are
> collinear), and defaulting to minimum-norm would hide it.
>
> *Trap recorded in the guard:* `stzMatrix.Inverse()` **mutates in place** and returns
> nothing, so calling it then `PseudoInverse()` on the same object returns the ORIGINAL
> — correctly, since A⁺ of an inverse is what you started with. It reads exactly like a
> bug in the new code.

**Phase 5 — algorithms come down from Ring. COMPLETE.** Simplex first (biggest
single win), then k-means/KNN/logistic/trees, then `stzHistogram` onto
`histogram.zig`, then real inferential statistics on the special functions from
phase 4. *Every item was addressed; the per-item records are under pillar 5 above.
Two moved to the engine, four turned out to have a different and larger cost in
Ring, and `stzHistogram` should never have been on the list.*

**Phase 6 — autodiff, and what it unlocks. COMPLETE.** The tape, then L-BFGS, then
the trainer — *but not by the route this line proposed, and the difference is the
finding.*

> **SLICE 1 (123864ae3), guard `numeric_autodiff_narrated` (48): THE TAPE.**
> `autodiff.zig` compiles an expression to a tape, evaluates forwards, walks the node
> list backwards carrying adjoints. **One backward pass gives every partial
> derivative**; finite differences need n+1 evaluations and are approximate either way
> (too large a step shows truncation error, too small and rounding eats the
> difference). Ring surface `stzMathFunction`.
>
> **`expr.zig` was checked first** — two definitions of one thing is this project's
> most repeated defect — and it is the *wrong tool*, not an awkward one: a predicate
> DSL for filtering lists whose variable is "the current item" and whose vocabulary is
> `IsVowel`/`StartsWith`/`Replace`. No `exp`, no `log`, no `pow`, no named variables.
> The infix syntax is deliberately shared; the domain is not.
>
> **The validation was the cross-check against `stzTrainer`'s hand-derived backprop** —
> written independently, years apart — agreeing to eight decimals on all four weights
> of a 1-tanh-1-sigmoid net. Two implementations of one derivative is a far stronger
> statement than either agreeing with a step size. **And it settled a question first:**
> the backprop looked ~2× WRONG under finite differences. It is not — it differentiates
> *binary cross-entropy* while *reporting* squared error, as its own comment says.
> Against cross-entropy the disagreement is 0.0000000000.
>
> **SLICE 2 (c69b8935f), guard `numeric_optimizer_narrated` (37): L-BFGS.** Rosenbrock
> from (−1.2, 1) in 34 iterations; a 10⁶ condition number in under 50. Ring surface
> `stzObjective` = a `stzMathFunction` plus a direction, answering with a **record**
> (status / iterations / evaluations / why) because a bare point cannot say it did not
> converge. **It takes a function pointer, not a tape** — an optimiser that could only
> minimise parsed expressions could never minimise a logistic loss over a resident
> dataset. **The line search is the full bracket-and-zoom for strong Wolfe**, not
> backtracking Armijo: the curvature condition is what guarantees sᵀy > 0, and without
> it the method degrades toward gradient descent *without saying so*.
>
> **AND THE ENGINE TEST STEP WAS NOT RUNNING THESE TESTS.** `zig build test` compiles
> `src/engine.zig`, not the per-DLL entry files, so `logistic`, `cluster`, `tree`,
> `apriori`, `bayes` and `autodiff` had been silently skipped since phase 5. **The
> count sitting at exactly 1698 across six modules landing is what gave it away.**
> Fixed; two assertions failed immediately, both mine (an `UnexpectedEnd` I had called
> `UnexpectedCharacter`, and a claim that the |z|>35 sigmoid clamp "costs no accuracy"
> when sigmoid(35) is three ulps short of 1.0 — *negligible and free are different
> claims*).
>
> **SLICE 3 (3eb513a86), guard `numeric_backprop_narrated` (30): THE TRAINER — AND NOT
> ONTO THE TAPE.** XOR 0.407s → 0.002s (203×); 400 × 10 through 16-8-1 over 100 epochs
> 11.140s → 0.028s (398×). The plan's "use gradients rather than hand-derived updates"
> was declined on three measured grounds: the hand-derived gradients were **already
> exact** (slice 1 proved it), a tape is **slower than closed-form code** for a fixed
> architecture, and rebuilding around the *reported* loss would **reintroduce the XOR
> saddle** the Ring comment records.
>
> **Bit-equality holds where it can and not where it cannot**, measured both ways:
> exact for XOR/ReLU/softmax, and exact to **twelve decimals** for a three-layer net
> after one sample and one epoch — the check that proves the multi-layer backward pass,
> which XOR never exercises. But a 3-layer net over 40 samples first differs at **epoch
> 48** in the tenth decimal, because Ring's `tanh` and Zig's differ by **6e-17** on some
> inputs and backprop feeds each step into the next. On the 400 × 10 benchmark the final
> loss differs by ~4% — **and the accuracy is identical, 0.93 either way.** The runs
> settle on different points of a nearly flat basin. Reproducibility *within a build* is
> preserved and pinned; bit-equality with the old interpreter could not be, and nothing
> could preserve it while calling a different libm.

**Phase 7 — the optional edges. COMPLETE (`e148fb60f`)**, guard
`numeric_complex_narrated` (35). *The gate did most of the work.*

**FOUR OF FIVE FAILED THE CONSUMER TEST, and not building them is the result:**

| | verdict |
|---|---|
| **mpdecimal** | the condition was "if the big-int decimal proves insufficient". **Measured**: `0.1+0.2` is exactly `0.3`, a 29-place product is exact, a 30-digit integer plus 1e-9 is exact, and a non-terminating division reports itself approximate *and says why*. **Sufficient. Not built.** |
| **OSQP** | nothing in the library poses a quadratic program. **Not built.** |
| **HiGHS** | nothing poses a mixed-integer program. **Not built.** |
| **KISS FFT** | there is no spectral or signal code to serve. **Not built.** |

Building any of them would have been *completeness*, which is what the gate exists to
refuse. **A library is not improved by an FFT nothing calls.**

**COMPLEX NUMBERS PASSED, on one consumer that phase 4 slice 8 had already written
down as a refusal:** *"EigenValues: this matrix is not symmetric, and a general matrix
has complex eigenvalues. Only the symmetric case is implemented."* That refusal was
right — the alternative was returning the eigenvalues of (A + A′)/2 and letting a
caller believe they belonged to A — and the honest way to remove it is to implement
what it refused.

- `complex.zig` — arithmetic, modulus, argument, conjugate, principal sqrt, exp.
  Division uses **Smith's formula** and modulus uses **hypot**, for the same reason:
  the textbook `(ac+bd)/(c²+d²)` overflows above ~1e154 on inputs whose quotient is
  ordinary. **Deliberately absent:** log, inverse trig, general powers — each needs a
  branch-cut policy, nothing asks, and a guessed branch cut is a wrong answer a
  library cannot take back.
- `eigen_general.zig` — balance (Parlett–Reinsch, powers of the radix so the
  similarity is *exact* in binary), Householder reduction to Hessenberg (which makes
  each QR sweep O(n²) rather than O(n³)), then **Francis double-shift QR**. The double
  shift is what lets real arithmetic find complex pairs at all: shifting by a complex
  number needs complex arithmetic throughout; shifting by a conjugate *pair* does not.
- Ring: `stzComplex`, `stzMatrix.ComplexEigenValues()`. **`EigenValues()` now answers
  any matrix with a real spectrum** and raises only when the eigenvalues are genuinely
  complex — naming one, and pointing at the complex form. Dropping an imaginary part
  silently is precisely the plausible wrong answer the original refusal prevented.
- **A capability the library did not have: polynomial roots.** The eigenvalues of a
  companion matrix *are* the roots; `x³−6x²+11x−6` gives 1, 2, 3.
- **EIGENVECTORS FOLLOWED (`19f980aa6`)**, guard `numeric_eigenvectors_narrated` (37).
  Deferred in the first pass, then asked for. Harder than the values for a structural
  reason: **eigenvalues can be read off a matrix you have destroyed; eigenvectors
  cannot.** Balancing, Hessenberg reduction and QR are all similarities, so the
  spectrum survives being thrown away — but an eigenvector of the final triangular
  form belongs to *that* matrix, and getting back needs every transformation the
  eigenvalue routine discarded (`v_A = D·Q·Z·v_T`). The pipeline accumulates now, with
  the standard EISPACK `hqr2` back-substitution tail.

  **The QR iteration is still ONE implementation** — a second accumulating copy would
  have been this project's most-punished defect — so `eigenvalues()` is a thin call
  into the same routine with accumulation off.

  **Two bugs surfaced, and neither would show in the eigenvalues:** the restructuring
  dropped the balance-and-reduce calls from the eigenvalue path (QR on a *full* matrix
  is a different computation, not a slower one); and a conjugate pair was stored
  `(-im, +im)` where the back-substitution detects a pair by a **negative imaginary
  part at the second index** — *the eigenvalue set was identical either way*, and the
  vector pass silently skipped every complex block.

  **Verified against the defining property**, not tabulated vectors: `max ‖Av − λv‖ /
  ‖A‖` over every eigenpair, in complex arithmetic, through the public surface, on
  eight matrices including a rotation, a companion matrix, a defective one, and one
  scaled across twelve orders of magnitude.

  **Defective matrices are reported, not papered over.** `[[1,1],[0,1]]` has eigenvalue
  1 twice and *one* eigenvector; no algorithm can supply a second, and back-substitution
  returns a near-duplicate. `NumberOfIndependentEigenVectors()` / `IsDefective()` /
  `IsDiagonalizable()` say so, and `EigenVectors()` refuses rather than returning a
  copy. *A repeated eigenvalue alone does not imply defective* — the identity is pinned
  as the counter-example.

  *Ring trap worth carrying: `^` is **bitwise XOR** in Ring, not exponentiation —
  `3^2` is 1. Two assertions here silently XOR-ed vector components and reported a
  magnitude of 0.*

- **THE SVD OF A GENERAL MATRIX FOLLOWED (`094c55d70`)**, guard
  `numeric_svd_general_narrated` (30). Slice 9's SVD was doing real work — rank,
  conditioning, least squares, the pseudo-inverse — with **two things missing**.

  **Only the singular values reached Ring.** U and V were computed and discarded at
  the boundary. Enough for everything phase 4 wanted, because rank and conditioning
  are questions about *magnitudes*; not enough for anything needing *directions* — PCA,
  low-rank approximation, an orthonormal basis for the range or null space. **The
  values say how much; the vectors say where.**

  **A wide matrix was refused** by `SingularValues()`, `Rank()` and
  `ConditionNumber()`, advising *"transpose it — the singular values are the same"*.
  True, and the refusal was never defensible: `rank(A) = rank(A')` and
  `cond(A) = cond(A')`, so orientation is a fact about your data layout, not the matrix.

  **And the advice hid a trap that only appears once the factors are exposed:** the
  singular values of A and A′ agree, but **U and V swap**. A caller who followed
  "transpose it" to obtain a *decomposition* got one that multiplies back to A′. So the
  transpose moved **inside** the engine (`svdAnyShape`), once, with the swap done
  right — one implementation either way, calling the same one-sided Jacobi.

  Ring: `SVD()` → `[:u, :singularValues, :v]`, `LeftSingularVectors()`,
  `RightSingularVectors()`; all three shape guards lifted.

  **Verified against `A = U Σ Vᵀ`** through the public surface on eight shapes (tall,
  wide, symmetric, non-symmetric, rank-deficient, single row, single column, and one
  scaled over twelve orders of magnitude), plus `UᵀU = I` and `VᵀV = I` — factors that
  merely reconstruct are useless for projection, which is most of what an SVD is for.
  **Tabulated reference factors would not have caught the U/V swap at all**, since both
  orderings give the same singular values.

  *Two phase-4 guards **updated, not weakened**: `linalg`'s "bad shapes are refused"
  now asserts a wide matrix and its transpose give the same rank and condition number
  (an empty dimension is still refused), and `numeric_svd_narrated`'s "a wide matrix is
  refused" now asserts it is answered and agrees with its transpose.*

- **PCA FOLLOWED (`fae73e757`)**, guard `numeric_pca_narrated` (47) — *the consumer
  the factors were exposed for.* PCA is the SVD of the **centered** data matrix, so
  almost no new arithmetic; what there is, is three decisions that each change the
  answer.

  | | |
  |---|---|
  | **Centering** | not optional, and done rather than documented as a duty. Uncentered PCA finds the direction of greatest *second moment* — roughly the direction of the mean — so the first component points at the centroid, appears to explain nearly everything, and explains nothing. |
  | **Standardising** | a genuine choice with **no safe default**, so `Fit()` *refuses* until the caller makes it. Covariance PCA lets each feature contribute in its own units — height in metres against mass in grams makes the first component "mass", a fact about the unit. |
  | **The variance divisor** | *not PCA's to invent.* Phase 0 made `stats.varianceDivisor` the one authority; `pca.zig` asks it rather than writing `n−1`, so these variances and `stzDataSet`'s cannot drift apart. Sample/population differ by exactly n/(n−1) and the **proportions are identical** — pinned. |

  **Verified two ways.** Against a standard reference *once* (Lindsay Smith's tutorial
  data: mean 1.81/1.91, first component 0.6779/0.7352, variances 1.2840/0.0491), and
  then against **identities**, which need no reference and cover what a tabulated case
  cannot: the explained variances **sum** to the total; the variance of score column j
  **equals** explained variance j; every score column **averages zero** (the direct
  evidence centering happened); and `Transform()` on the training data reproduces the
  training scores exactly — the check that it centers by the *fit's* mean rather than
  the new data's own.

  Two details that would otherwise bite: a **constant column** has zero standard
  deviation, so standardising it would divide by zero and NaN the whole decomposition —
  it is left alone. And a component is a **direction**, which has no preferred sign, so
  the largest loading is made positive and its score column negated with it; without a
  convention two runs look like they disagree.

- **NONLINEAR EMBEDDING ON TOP OF PCA (`39ff9341a`, `e1ef15fb6`, `97aedc125`)**,
  guard `numeric_embedding_narrated` (108) — t-SNE and UMAP, both taking PCA as an
  optional pre-step, in `tsne.zig` / `umap.zig` / `ptsne.zig` with `stzTSNE` and
  `stzUMAP` in `stzEmbedding.ring`.

  PCA answers *"what are the dominant directions"*; these answer *"what sits near
  what"*, which is a different question and needs a different guarantee. **Neither
  preserves distance, and the guards say so** — what they preserve is neighbourhood,
  so a cluster's *size* and the *gaps between* clusters carry no meaning and must not
  be read as if they did.

  | | |
  |---|---|
  | **PCA as a pre-step** | not a shortcut — the neighbour graph both algorithms build is what high dimensions ruin. Reducing to ~30 components first makes the neighbours mean something, and it is the same `stzPCA`, so centering, standardising and the variance divisor keep their one authority. |
  | **The transform seam** | `StzEmbeddingPrepare` and `Transform()` must be **one** computation. They were two — `Scores()` and `Transform()` — agreeing to eight decimals and differing in the last bits. Unified. |
  | **Iterations are not comparable** | t-SNE needs ~800 where UMAP needs ~300. Same-epochs benchmarks between them compare nothing. |

  **Two things measured that contradict the obvious reading.** UMAP's `a`/`b` are
  fitted by L-BFGS against the target curve rather than tabulated, and independently
  came out at **1.577 / 0.895** — the published values, which is a real check on the
  optimiser from phase 6. And the a/b fit is the only place phase 6's L-BFGS is used
  by something that is not a test.

- **TRANSFORM FOR NEW POINTS (`e1ef15fb6`), then PARAMETRIC t-SNE** — the two
  algorithms answer *"where does an unseen point go"* in genuinely different ways, and
  the difference is the honest part.

  UMAP **re-optimises** the new point against a frozen map, so it is *anchored, not
  exact*: putting the training rows back through `Transform()` moves them about **0.2
  of the typical inter-point distance**, and only 25% land nearest their own fitted
  position — the same 25% unsupervised, so this is the method's nature, not a defect.
  Parametric t-SNE instead **trains a network** (van der Maaten 2009) whose forward
  pass *is* the embedding, so its transform is exact by construction. Buying an exact
  transform means accepting a model between you and the map.

- **SUPERVISED UMAP (`97aedc125`)** — labels reweight the neighbour graph rather than
  training anything: cross-class edges are crushed, edges touching an **unknown (−1)**
  label merely damped, and each point's edges renormalised so its strongest is 1 again.
  That renormalisation is load-bearing — without it the crushed edges take the local
  connectivity with them. Semi-supervision falls out of the −1 marker rather than
  needing its own path: damping instead of crushing is exactly the difference between
  *"no information here"* and *"drop this row"*.

  **The dial is not the shape anyone assumes.** Separation against `target_weight` on
  random-labelled data: `0.00→0.98`, `0.05→1.71`, **`0.20→2.62` (the peak)**,
  `0.50→1.46`, `0.90→1.43`, `0.99→1.43`. It **saturates** — `far_dist` is `2.5/(1−w)`,
  so 0.9 gives `exp(−25)` and 0.99 `exp(−250)`, both zero to an f64, and the two runs
  come out byte-identical. And **more supervision is not more separation**: crushing
  every cross-class edge fragments the graph, points lose their neighbours, and each
  class comes apart into pieces instead of holding as one group. *A monotone assertion
  was written first and failed; measuring rather than loosening it produced both facts.*

  **The guard tests supervision on data with no class structure** — random points,
  alternating labels — because testing it on separable data would prove nothing: the
  unsupervised run would separate that too, and both would pass. Which is also the
  warning the surface carries. **A supervised embedding will separate your classes
  because you asked it to, so it is never evidence that they are separable.** What it
  is genuinely for: seeing structure *within* groups you already trust.

- **DENSITY PRESERVATION / densMAP (`f0fc8e5a9`)**, `density.zig` — *the entry that
  retires a caveat the rest of this section had to keep printing.*

  Everything above tells you not to read cluster size, because UMAP and t-SNE preserve
  **neighbourhoods** and not **density**. Measured rather than left as a warning: two
  clusters whose spreads differ **twentyfold** are drawn **1.17** apart. A 20× fact,
  rendered as 17%.

  Narayan, Berger and Cho (*Nature Biotechnology* 2021) add one term. Give each point a
  local radius — the membership-weighted mean squared distance to the neighbours it is
  actually joined to — and require the original and embedded radii to stay **correlated**.

  | λ | correlation | drawn ratio | cluster separation |
  |---|---|---|---|
  | 0 | 0.226 | 1.17 | 7.36 |
  | 2 *(paper default)* | 0.436 | 1.31 | 6.28 |
  | 30 | 0.871 | 1.81 | 5.85 |
  | 300 | 0.993 | 23.83 | **1.44** |

  **Three things the table says, none of them assumable.** It is a **correlation**, so
  what returns is the **ordering** of densities and not their magnitude — at the paper
  default a twentyfold difference still draws at 1.31. **It is a trade**, which the
  small default hides: getting density nearly exact collapses the gap between clusters
  from 7.36 to 1.44, because the term buys its room by spending what was holding the
  groups apart. No setting is simply better — a high λ answers *"how dense is each
  region"* at the cost of *"how many groups are there"*, and the second is usually why
  the plot was opened. And **this dial is monotone**, where `target_weight` peaks at 0.2
  and saturates past 0.9 — two dials on the same object behaving nothing alike.

  **`LocalRadii()` is the other half, and arguably the better one:** a per-point density
  estimate that ranks rows by isolation **with no reference to the embedding at all**.
  Tight rows come out near 0.006 and diffuse ones near 1.80 — a 300-fold separation,
  usable for outlier detection or for weighting a downstream model, and **free**,
  because the density term computes it anyway.

  `density.zig` is shared deliberately: the same term defines **den-SNE** in the same
  paper, so radius, correlation and gradient keep **one definition** rather than drifting
  into a second notion of what local density means.

  **The one structural cost.** UMAP's optimiser is *embarrassingly local* — sample an
  edge, pull, push a few negatives, repeat; nothing global anywhere. A Pearson
  correlation is a statistic over **every** point, so this term inserts the optimiser's
  **only synchronisation point**: a per-epoch reduction. It is also why it switches on
  for the **final 30%** of epochs only — on a random start the embedded radii are noise,
  their correlation is noise, and its gradient is noise with a lever arm.

  *One of my expectations was wrong and measuring fixed it: a density-**reversed**
  embedding scores **−0.600**, not −1. Reversing the order of a vector is not negating
  it — −1 requires an affine decreasing relationship. Kept, because it means a reported
  correlation is **not a percentage**: an embedding that gets every density rank
  backwards can still score well above −1.*

- **den-SNE (`126300625`)** — the same term in the other algorithm, and *the finding is
  worse than densMAP's.*

  Plain t-SNE returns a density correlation of **−0.186, +0.099, +0.125, −0.048, +0.168**
  across five seeds on twentyfold-different data. Scattered around **zero**, negative as
  often as not. So t-SNE cluster sizes are not merely unreliable — **they are noise**,
  and anything read from them is read from the initialisation. Plain UMAP at least
  scored a consistent +0.226: weak, but pointing the right way. The Student-t kernel is
  why — its heavy tail solves the crowding problem precisely *by* letting every cluster
  settle at whatever size the repulsion allows.

  **What "shared" had to mean.** UMAP holds `p_ij` as a sparse edge list; t-SNE holds a
  dense n×n joint distribution. Forcing t-SNE to materialise n(n−1)/2 edges to reuse one
  loop would double its memory for nothing. So the **math** is shared —
  `pointCoefficients` and everything it calls — and only the **traversal** differs. A
  test builds one graph in both representations and requires identical answers, so *one
  definition* is checked rather than claimed.

  They also differ in **where the answer goes**, and the sign follows. UMAP has no
  gradient buffer and writes each edge straight into the layout, so that path *ascends*
  `y`. t-SNE accumulates a gradient and then applies momentum and Jacobs gains, so this
  path accumulates into `dy` and **negates** — t-SNE descends its buffer. Backwards
  would not crash; it would quietly *anti*-preserve density, so a test pins it.

  | λ | seed 42 | seed 7 | seed 1234 | *second dataset* |
  |---|---|---|---|---|
  | 0.5 | 0.902 | 0.896 | 0.827 | 0.936 |
  | 1.0 | 0.957 | 0.965 | 0.900 | 0.899 |
  | 2.0 | **−0.646** | 0.480 | 0.910 | 0.929 |
  | 4.0 | 0.938 | 0.936 | 0.933 | 0.953 *(at 5)* |

  On the first dataset λ=2 lands anywhere from −0.65 to +0.91 **decided only by the
  seed** — a density term of middling strength drives an oscillation the adaptive gains
  then amplify. On the second, nothing is unstable anywhere. **The bad band is not at a
  fixed place**, so λ cannot be set once and trusted.

  **Which is why `DensityCorrelation()` is on the surface rather than internal.** It is
  not a diagnostic for the curious — it is the only way to know the term did what was
  asked, and a low value means the picture is not density-preserving however it was
  configured. The default of 1.0 is a *starting point measured to behave on both
  datasets*, not a guarantee. (stzUMAP's dial was cleanly monotone and defaults to 2.0 —
  **same term, different optimiser: the shape belongs to the optimiser.**)

  Here the cost arrives **itemised**. UMAP could only show it indirectly as lost cluster
  separation; t-SNE reports its own objective, so KL rises from **0.291 to 0.443** at the
  default — neighbourhood fidelity spent on density fidelity, in the units of the thing
  given up.

  **Parametric + density is refused, not ignored** — the parametric fit produces
  coordinates through a network, so a term that moves coordinates directly has nothing to
  act on, and silently dropping the request would return a picture the caller believes is
  density-preserving and is not.

  A cross-check worth having: stzUMAP weights the radius by its fuzzy graph, stzTSNE by
  the joint distribution, and they rank rows by density with **over 90% pairwise
  agreement** — the radius is a fact about the data, not an artefact of the graph used to
  weigh it.

  *One trap found the hard way: an earlier guard helper drew its data from the **low bits
  of an LCG**, which have short periods and lay points on a lattice. On that data the
  sweep read −0.86 at λ=0.2 and 0.97 at 5 — the opposite ranking. Taking the high bits
  gave the clean picture above. **The measurement was wrong before the algorithm was.***

- **DENSITY-AWARE TRANSFORM (`826883f77`)** — *the object was keeping two contracts at
  once.* The fitted map said a point's distance from its neighbours means density
  (correlation 0.81), and then `Transform()` placed new points by a rule that knew
  nothing about density.

  | new row | original radius | ordinary | density-aware |
  |---|---|---|---|
  | tight cluster | 0.002 | 2.135 | 0.789 |
  | diffuse cloud | 0.727 | 1.115 | 1.300 |
  | **far outlier** | **126510** | **1.375** | **5.990** |

  The ordinary transform draws the **outlier closer in than the familiar row** — ratio
  0.64, *inverted*, not merely uninformative. It places a new point at the centre of
  mass of its neighbours and lets the layout nudge it, and nothing there distinguishes
  *"near its neighbours"* from *"nowhere near anything"*.

  **The mechanism cannot be the fit's**, which is the interesting part. The fit
  maximises a **correlation over every point**; one new point has nothing to correlate
  against, so the objective does not even type-check for it. What carries over is the
  **line** the fit leaves behind — least squares of log R\_embedded on log R\_original
  over the training rows — which says what embedded radius *this* map gives any original
  density, and which **extrapolates**.

  **And the correction is closed form.** With `c` the membership-weighted centroid of a
  new point's neighbours and `S` their own spread about it, `R_embedded = ||y − c||² + S`
  — an identity. So the neighbourhood optimisation decides the **direction** from `c`,
  and the density contract decides only the **distance**. No second gradient loop, and
  nothing for the two terms to fight over; a test pins that the ray is unchanged
  (cosine > 0.99) and only its length differs.

  **Not further than 5.99, which is right rather than weak.** This map's line has slope
  0.194 — it compresses eight and a half natural logs of original density into about 1.7
  of embedded radius, and the transform inherits **exactly that compression**, because
  its job is to place new points under *the same contract the training rows obey*.
  Flinging the outlier further would draw something the picture does not mean. More
  separation is bought at **fit** time, where it applies to everything at once.

  `NewLocalRadii()` is the other half and may be the more useful one: the new rows'
  radii in the **original** space — 0.002 against 126510, a 63-million-fold range that
  answers *"is this row anything like the training data"* with no reference to the
  embedding. Reported for ordinary fits too, since it is a property of the data rather
  than of the placement, and free.

  *One bug worth recording: the new density arguments were given bridge slots 11–13,
  which `epochs` and `seed` already occupied — so the slope read 30 and the intercept 42,
  giving `exp(42 + 30·log r)` and an embedded reach of 4.5e85. **The engine tests passed
  throughout**, because they call the Zig function directly and never cross the bridge.
  Count the existing arguments.*

- **den-SNE TRANSFORM (`8751c8643`)** — *through the network, and what it cannot see.*

  Classic t-SNE has **no transform**: it optimises the points it was given and a new
  point has no position, so the density contract had nowhere to go. The only door is the
  parametric variant — which two commits earlier had been made to **refuse** density.

  **The refusal is gone, and deservedly.** It was sound for the code as it stood: the
  density term moves coordinates, and the parametric fit produces coordinates through a
  network. What it missed is that the term need not act on the coordinates at all — its
  gradient is taken on the network's **outputs**, and `nn.backwardFromDelta` chains an
  output delta back through the weights. It exists precisely so a caller can supply a
  delta the network could not derive from targets of its own. So the term *teaches the
  network to produce different coordinates* rather than moving the ones it produced. Six
  lines, into the same `dy` the KL term already fills.

  **Which makes the transform density-preserving by construction, and exact** — a
  training row returns its fitted position to the last bit, because the forward pass *is*
  the embedding. (UMAP's re-optimises and lands ~0.2 of the typical spacing away.)

  **But the network saturates, and that is the price of the exactness.** A legitimate row
  at (20,20,20,20) transforms to (−2.1100, −9.7090); one at (200,200,200,200) — ten times
  further out in every coordinate than anything the fit saw — to (−2.1118, −9.7117).
  **Three thousandths apart.** Bounded activations send everything past a certain
  magnitude to the same place, so the transform is not merely inaccurate on unfamiliar
  input, it is **structurally blind** to it, and it fails **silently**.

  That is the exact inverse of the UMAP transform's profile: approximate on training rows
  but able to place an outlier *outside* the map (5.99 against 0.79). **Neither is
  better** — they fail in opposite directions, and a caller should know which one they
  hold. So `LocalRadiiOf()` answers from the **data**, never the model: 4.41 for the
  legitimate row against a training maximum of 5.50, and **126688** for the outlier. The
  radius computation moved into one shared function both transforms call.

  | λ | correlation | drawn ratio |
  |---|---|---|
  | ~0 | **−0.422** | 0.66 — *plain parametric, inverted here* |
  | 0.01 | 0.983 | 8.15 |
  | **0.10** | **0.985** | 8.76 — *the new parametric default* |
  | 0.30 | 0.988 | 9.34 |
  | 1.00 | **−0.913** | 0.07 — *the classic default, catastrophic* |

  **The weight had to become mode-dependent.** A network has a few hundred weights
  *shared* by every point, so an over-strong term does not distort one region — it
  deforms the whole function. `PreserveDensity()` resolves to 0.1 on the parametric path
  and records what it used; an explicit `SetDensityWeight()` is obeyed exactly, including
  into the range that inverts.

  ***And a claim I nearly shipped was too strong.*** On the engine's dataset plain
  parametric t-SNE scores **0.975** with no density term — a network cannot tear space,
  so tight stays tight — and I wrote that up as *density preservation for free*. On a
  second dataset the same configuration scores **−0.42**. Smoothness makes it **likely,
  not certain**, and which way a fit went is not deducible from the algorithm.

  **Every strand of this work has now reached the same place from a different direction:
  density preservation is a property of a particular fit on particular data, never of the
  algorithm or the settings, and the only way to know is to read the correlation.**

- **CLASSIC den-SNE TRANSFORM (`76f909aac`)** — *built, since the paper declines to.*

  The entry above says classic t-SNE has no transform. That is true of the **published**
  algorithm — it optimises the positions of the points it was given, and a new point has
  no position — and it is why the refusal stood. But *"the algorithm does not provide
  one"* is not *"one cannot be built"*. Everything needed was already defined: freeze the
  training map, give the new row the same kind of neighbour distribution the fit gave
  every training row, and minimise the same KL over that one position. Only the paper
  declined to combine them.

  | transform | displacement | self-match |
  |---|---|---|
  | UMAP *(published)* | 0.20 | 25% |
  | **classic** *(constructed)* | **0.23** | **50%** |
  | parametric | 0.00 | 100% — *the forward pass **is** the embedding* |

  So it is **approximate and must not be sold as exact**. The fit optimised each row
  against every other row moving at the same time; this optimises one row against a
  frozen map. Different problems, different answers, and the 0.23 measures the gap.

  `Q` is normalised over the new point's **own row** rather than the whole joint —
  recomputing the full normaliser would make placing one point cost as much as a fit, and
  would let a new arrival perturb the very distribution the frozen map was optimised
  against. The density contract then carries across by the **same closed form** the UMAP
  transform uses.

  **And a third way to fail on an outlier.** At 200 units out every training point is
  very nearly equidistant — the spread *within* the training set is negligible beside the
  distance *to* it — so the neighbour distribution goes **uniform**, its weighted centroid
  is the centroid of the whole map, and t-SNE recenters. Measured: **(0.307, −1.976)**.
  The origin. That is the most dangerous of the three, because the middle of a scatter
  plot is where the interesting points are supposed to be: an unrecognised row does not
  land somewhere odd-looking, it lands in the most meaningful-looking place there is.
  (With a density line it may instead be pushed far out — but only if the predicted
  radius exceeds the whole map's spread, which is what a uniform distribution makes the
  neighbours' spread. On one dataset it went out; on another it pinned to the centre.)

  | transform | what it does with a far outlier |
  |---|---|
  | UMAP | places it **outside** the map (5.99 vs 0.79) |
  | parametric den-SNE | **saturates** onto a legitimate point (0.003 apart) |
  | classic den-SNE | **origin, or far out** — it depends on the calibration |

  **Only the first is dependable, and none of the three is detectable from the
  coordinates.** Which is the whole case for `NewLocalRadii()`: 143711 against a training
  maximum near 5, measured against the data, where 356 units from anything is 356 units
  from anything whatever a map believes.

  *Four guard assertions pinning the two refusals are retired — with the reasoning kept
  in place rather than deleted — and one rewritten, because "only one of them has a map"
  was really pointing at **exactness**, which is still true and is now asserted directly.*

---

*Phase 4's `numeric_eigen_narrated` was **updated, not weakened**: it pinned the old
blanket refusal. It now asserts what that scenario was always about — `[[1,2],[3,4]]`
is answered from **its own** spectrum (trace 5, determinant −2), not the symmetrised
matrix's (determinant −2.25) — plus that a rotation still raises.*

---

## 9. Non-goals, and honest limits

- **Not a NumPy.** No broadcasting semantics, no fancy indexing, no dtype algebra.
  Softanza's numeric layer serves *this library's* modules — tables, datasets,
  stats, solvers, ML, NLP — not general array programming.
- **No GPU.** ggml could open that door later; nothing here assumes it.
- **f32/f64 stays a visible boundary.** The ggml bridge narrows f64→f32 and says so.
  Pretending otherwise would be the one dishonest move available in a numeric layer.
- **Decimal is not a universal fix.** It fixes money. It does not make transcendental
  functions exact, and `StzNum("1/3")` as a decimal is still a rounding decision —
  which is what the rational representation is for.
- **Arbitrary precision is not free.** Big integers allocate; a 50-digit scope is
  orders of magnitude slower than f64. The scope makes the cost *chosen* rather than
  hidden, which is the most any library can offer.
- **Ring's own limits remain.** Ring will still lack an integer literal type, still
  lack scientific notation in source, and still print through `decimals()` unless
  Softanza's own rendering path is used. We can give correct numbers a good home; we
  cannot change the host language.
- **Phase ordering is a claim, not a certainty.** The §2.5 measurement says
  residency precedes kernels. If a later measurement contradicts that on real
  workloads, the order should change and this document should be corrected.
