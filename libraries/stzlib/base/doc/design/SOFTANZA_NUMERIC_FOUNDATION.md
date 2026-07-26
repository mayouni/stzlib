# Numbers in Softanza — a global rethink
### Where the numeric layer actually stands, what a modern one owes its users, and the plan to close the distance

> Status: **PHASES 0-4 COMPLETE** (P3 residency in four slices: 13266934d, ba4c54ec9, cc8fb24d8, 0ddf438fc. P4 kernels, NINE slices: 1fdc2eda5, 7621cc5e1, a0fdc7689, e549ec945, d5b84416d, f0b3e7890, 07d3b443e, 504c1df36, 40fd49580). **Phases 5-7 are design.** Written 2026-07-25 at the user's
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
  in slice 9 (40fd49580)**. **This line is now closed** -- only a pseudo-inverse
  remains unbuilt, and it is three lines on top of the SVD when a consumer appears.
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

- **Simplex → engine.** `stzLinearSolver`'s 1170 Ring lines become a revised
  dual simplex over resident buffers. Same public surface; the narration and tests
  stay valid.
- **Clustering / KNN / logistic / trees → engine**, over resident buffers. These
  are the classic distance-and-reduce kernels that SIMD and threads were made for.
- **`stzHistogram` → the existing `histogram.zig`.** 1015 Ring lines duplicating an
  engine module is pure waste.
- **Inferential statistics → new.** Once special functions land: t/z/χ²/F
  distributions, correct confidence intervals, and the hypothesis tests that
  `stzDataSet` cannot currently express. This retires §2.6(b) properly instead of
  patching the constant table.

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

**Phase 5 — algorithms come down from Ring.** Simplex first (biggest single win),
then k-means/KNN/logistic/trees, then `stzHistogram` onto `histogram.zig`, then real
inferential statistics on the special functions from phase 4.

**Phase 6 — autodiff, and what it unlocks.** The tape, then L-BFGS, then rewiring
the trainer and logistic regression to use gradients rather than hand-derived
updates.

**Phase 7 — the optional edges.** Complex numbers; decimal via mpdecimal if the
big-int-backed one proves insufficient; OSQP if QP becomes real; HiGHS if MIP
becomes real; KISS FFT if spectral work becomes real. Each gated on a genuine
consumer, not on completeness.

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
