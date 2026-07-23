# Softanza Numbers, Engine-Side
### A plan to make exact, arbitrary-precision arithmetic first-class — and to build the number types the browser cannot

> Status: **plan only — nothing here is built yet.** This document is the design
> the user asked for before the appserver work. It is grounded in a survey of the
> live tree (2026-07-23): the engine, the Ring `stzNumber`, and the delivery
> catalog were all read, and every "today" claim below was verified by running code.

---

## Why this document exists (and one correction it makes)

The bignumber differential re-check concluded that `BigNumber` should deploy
**native** (defer to JS `BigInt`), not to the wasm edge. That verdict is correct.
But the reason recorded next to it — *"Softanza has no arbitrary-precision engine
to ship"* — is **factually wrong**, and this plan corrects it.

The truth, verified end-to-end:

```ring
a = StzEngineBigIntFromString("99999999999999999999999999999999")
? StzEngineBigIntToString( StzEngineBigIntAdd(a, StzEngineBigIntFromString("1")) )
#--> 100000000000000000000000000000000      (exact -- no float rounding)
? StzEngineBigIntToString( StzEngineBigIntMul(a, a) )
#--> 9999999999999999999999999999999800000000000000000000000000000001
```

The engine **already has** a complete arbitrary-precision integer type. The right
justification for deferring `BigNumber` to native is therefore sharper: the engine's
`StzBigInt` is **integer-only, which exactly matches JS `BigInt`** — so shipping it
to the browser would be *redundant*, not *additive*. It is not differential, so it
defers. The number types that *are* differential — big-**decimal** and **rational**,
which JS has no native equivalent for — do not exist yet. **Building those is the
real prize**, and the second half of this plan is about them.

---

## Part 1 — Ground truth (what exists today)

### 1a. The engine already has `StzBigInt` — complete and working

`engine/src/number.zig` implements arbitrary-precision integers on top of Zig's
`std.math.big.int.Managed`. It is a real domain module (`stz_number` in `build.zig`
`base_domains`), compiled to `stz_number.dll`, exported through
`stz_number_entry.zig`, and bridged (`StzEngineBigInt*`, ~45 references in
`ring_bridge_number.zig`). The full surface (22 exported C-ABI functions):

| Group | Functions |
|---|---|
| Lifecycle | `new`, `from_int`, `from_string`, `from_string_base`, `clone`, `free` |
| Arithmetic | `add`, `sub`, `mul`, `div`, `mod`, `negate`, `abs`, `pow` |
| Comparison | `compare`, `equals`, `is_zero`, `is_negative` |
| Conversion | `to_int`, `to_string`, `to_string_base`, `bit_count` |

It is **used in production paths already**: `StzFactorial(n)` and `StzFibonacci(n)`
compute the exact big result in the engine, then `StzEngineBigIntToString` renders it
and `StzEngineBigIntFree` releases the handle. So `StzFactorial(50)` is already exact
— but the big value lives for exactly two statements and then dies as a string.

### 1b. The Ring `stzNumber` is native doubles — lossy past 2^53

`base/number/stzNumber.ring` is 7106 lines, ~720 public methods, and its underlying
value is a **Ring native number (IEEE-754 double)**. Beyond 2^53 it silently loses
precision:

```ring
? 9007199254740992 + 1        #--> 9007199254740992   (WRONG -- the +1 vanished)
```

`IsBigNumber()` (~line 2423) is only a **predicate** — `NumberOfDigits() >
MaxNumberOfDigits()` — it detects the danger but does nothing to avoid it. General
arithmetic (`+`, `*`, the arithmetic methods) never routes through `StzBigInt`.

### 1c. There is no first-class big-number *class*, and no decimal / rational / complex

`base/number/` has `stzBinaryNumber`, `stzHexNumber`, `stzOctalNumber`,
`stzSciNumber`, `stzMatrix`, `stzListOfNumbers`, `stzPairOfNumbers`, `stzSequence`,
`stzRandom`, `stzSimilarity` — but **no `stzBigNumber`**, no `stzBigDecimal`, no
`stzRational`, no `stzComplexNumber`. The engine's exact-integer power is reachable
only through a handful of global functions that immediately stringify-and-free it.

### 1d. The delivery catalog treats numbers as one coarse capability

`base/system/stzDelivery.ring` carries one catalog row for numbers
(`[ key, display, unique, nature, weight, js, native, embedded, kb ]`):

```
[ "bignumber", "BigNumber", FALSE, "compute", "light", "strong", "strong", "weak", 3 ]
```

`js = "strong"` + `unique = FALSE` → `VectorFor` places it **native** (defers to JS
`BigInt`). Correct for integers. But there is no `:BigDecimal` or `:Rational` row,
so the catalog cannot yet express that *those* are Softanza-unique and belong on the
edge.

### Summary of the gap

| # | Gap | Consequence |
|---|---|---|
| **G1** | No first-class `stzBigNumber` class over the existing engine `StzBigInt` | The exact-integer engine is unreachable ergonomically — no `new stzBigNumber(...).Add(...).Times(...)`, no chaining, no operator use |
| **G2** | `stzNumber` never auto-promotes on overflow | `2^53 + 1` is silently wrong — exactness is opt-in via obscure globals, not the default |
| **G3** | No big-**decimal**, no **rational**, no **complex** in the engine | The genuinely differential number types (JS has none of them) don't exist |
| **G4** | Engine handles are freed immediately; nothing owns one across its lifetime | A first-class class must own an engine handle, and Ring has no destructors |

---

## Part 2 — The differential-value argument (why this is worth engine work)

The delivery plane's doctrine: the on-device engine ships only what is **critical AND
(Softanza-unique OR platform-weak)**. Measured against the browser:

| Number type | JS native? | Differential? | Delivery vector |
|---|---|---|---|
| Arbitrary-precision **integer** | ✅ `BigInt` | ❌ engine matches, doesn't exceed | **native** (defer to `BigInt`) |
| Arbitrary-precision **decimal** | ❌ (float only; `Intl`/libs are userland) | ✅ **Softanza-unique** | **engine / wasm edge** |
| Exact **rational** (p/q) | ❌ none | ✅ **Softanza-unique** | **engine / wasm edge** |
| **Complex** | ❌ none | ✅ Softanza-unique | engine (lower priority) |

So the payoff is concrete: **big-decimal and rational are exactly the kind of
capability the wasm edge exists to carry** — critical for money, science, and exact
math; absent from the platform; unique to Softanza. Building them engine-side doesn't
just fix Ring-side correctness — it *earns those types a seat on the edge*, which
plain `BigNumber` (redundant with `BigInt`) never gets.

---

## Part 3 — The plan

Six phases, ordered so that each ships value on its own and the early phases unblock
the later ones. Phases 1–2 are **Ring-class + wiring over an engine that already
exists**. Phases 3–5 are **new engine types**. Phase 6 closes the loop with the
delivery plane.

### Phase 1 — `stzBigNumber`: a first-class class over the existing `StzBigInt`

The engine work is *done* (Part 1a). This phase is a Ring class that **owns an engine
handle** for its lifetime and exposes the full surface with Softanza naming and the
Q-convention.

- **Value & lifecycle.** `new stzBigNumber("123...")` calls `StzEngineBigIntFromString`
  and stores the returned pointer in `@pHandle`. A `Free()` method releases it. Because
  Ring has no destructors (see [engine residency](../../../..) discipline — the same
  problem the resident-list cache solved), the class follows the established pattern:
  an explicit `Free()`, plus a **bounded, generation-keyed handle policy** so a forgotten
  handle is reclaimed rather than leaked. A conservative first cut can also round-trip
  through the decimal string on every op (allocate → op → stringify → free) — correct
  and leak-free, optimized later once the residency policy is wired.
- **Arithmetic.** `Add/Sub/Times/DividedBy/Modulo/Power/Negated/Abs`, each mapping to
  the matching `stz_bigint_*`. Active vs passive per the function-form convention
  (`Add()` mutates the receiver's handle; `Plus()`/`Added()` return a new
  `stzBigNumber`).
- **Comparison.** `IsEqualTo/IsLessThan/IsGreaterThan/IsZero/IsNegative`, via
  `stz_bigint_compare/equals/is_zero/is_negative`.
- **Conversion.** `ToString()` (default), `ToStringInBase(n)` (hex/oct/bin via
  `stz_bigint_to_string_base`), `ToNumber()` (guarded — only when it fits a double),
  `NumberOfBits()`.
- **Q-chaining & operators.** `Q()` returns the chainable object; operator elevation
  (`+ - * /`) on a `stzBigNumber` stays exact and returns a `stzBigNumber`, matching
  the operator-elevation rule already used across `stzList`/`stzString`.
- **Guard:** `bignumber_narrated` — exact arithmetic against independently-computed
  expectations (Python `int` or a reference string), including the `2^53+1`,
  factorial(100), and 300-digit multiply cases.

### Phase 2 — auto-promotion: make exactness the default in `stzNumber`

Today `stzNumber` *detects* overflow (`IsBigNumber()`) but proceeds in doubles. This
phase closes the correctness hole:

- On an arithmetic op whose operands or result exceed `MaxNumberOfDigits()` (i.e. leave
  the exact-double range), `stzNumber` **promotes**: it computes in `stzBigNumber` and
  either returns one or carries an internal big-handle, instead of rounding.
- `9007199254740992 + 1` then yields the exact `9007199254740993`.
- The promotion is **one-directional and lazy** — small numbers stay native doubles
  (fast, hot ASCII-math path untouched); only values that would lose precision pay the
  engine-handle cost. This mirrors the "measure the interleaved pattern; don't tax the
  cheap common case" rule already applied to the incremental caches.
- **Guard:** extend the number suite with promotion assertions and a scale guard proving
  the small-number path did not regress.

### Phase 3 — engine `stz_bigdec`: arbitrary-precision **decimal** (the first differential type)

The first type JS genuinely lacks. Two viable engine implementations, to be chosen at
build time:

1. **Scaled big-integer** — `(StzBigInt coefficient, i32 scale)`, i.e. value =
   coefficient × 10^(−scale). Reuses the `StzBigInt` already in `number.zig`; add/sub
   align scales, mul adds scales, div carries a requested precision + rounding mode.
   Simplest, no new dependency, exact for all the money/accounting cases.
2. **Vendored decimal** (e.g. a small C decimal or Zig port) if we later need
   correctly-rounded transcendental decimals.

Start with (1). Surface mirrors `StzBigInt`: `from_string/to_string/add/sub/mul/div
(with scale+rounding)/compare/round/rescale`. Bridge as `StzEngineBigDec*`; Ring class
`stzBigDecimal` (Phase 1's lifecycle discipline, reused). **Rounding modes** are
first-class (half-even/half-up/floor/ceil/truncate) — the thing float and even
`BigInt` cannot express.

### Phase 4 — engine `stz_rational`: exact **fractions** p/q (the second differential type)

- Struct `(StzBigInt num, StzBigInt den)`, always normalized (sign on numerator, GCD-
  reduced via the existing `gcd`). Ops: `add/sub/mul/div/compare/reciprocal/simplify`,
  plus `to_bigdecimal(precision)` and `to_double`.
- Ring class `stzRational`. Exact `1/3 + 1/3 + 1/3 == 1` — impossible in float, absent
  from JS.
- Bridge `StzEngineRational*`.

### Phase 5 — engine `stz_complex` (optional, lower priority)

- `(f64 re, f64 im)` first (covers signal/graphics), with a later `(stzBigDecimal,
  stzBigDecimal)` exact variant if a use case demands it. Ring class `stzComplexNumber`;
  `Plus/Times/Conjugate/Modulus/Argument`. Lower priority — no strong pull yet.

### Phase 6 — re-classify the delivery catalog (close the loop)

Once Phases 3–4 land, the catalog can finally tell the truth the coarse `bignumber`
row cannot:

- Add rows: `[ "bigdecimal", "BigDecimal", TRUE, "compute", "light", "weak", "strong",
  "strong", 4 ]` and `[ "rational", "Rational", TRUE, "compute", "light", "weak",
  "strong", "strong", … ]`. `js = "weak"` + `unique = TRUE` → `VectorFor` places them
  **engine** → **they ship to the wasm edge**.
- `bignumber` (integers) **stays native** — unchanged, and now for the *correct*
  reason recorded in code.
- Update `delivery_narrated` to assert the new split: `BigNumber → native`,
  `BigDecimal → engine (on the edge)`, `Rational → engine (on the edge)`. This is the
  concrete, testable payoff of the whole plan.

---

## Part 4 — The engine-extension recipe (how each new type lands)

Every engine phase follows the same five-step path already used for `stz_number` and
the other domains — no new machinery:

1. **Implement** the type + C-ABI functions in `engine/src/number.zig` (or a sibling
   `bigdec.zig`/`rational.zig` imported by it), with Zig `test` blocks alongside.
2. **Export** each function in `engine/src/stz_number_entry.zig`
   (`@export(&number.stz_bigdec_add, .{ .name = "stz_bigdec_add" })`).
3. **Bridge** to Ring in `engine/src/ring_bridge_number.zig`, honoring the
   `INDEX_BASE=1` and utf-8-validation boundary rules (decimal strings are ASCII, so
   the [binary-through-a-text-boundary](../../../..) trap does not bite — values cross
   as plain digit strings).
4. **Build**: the `stz_number` domain is already in `build.zig` `base_domains`; adding
   functions needs only a rebuild (`zig build`), no new Domain struct.
5. **Wrap** in a Ring class under `base/number/` and load it in `stzBase.ring`.

**ABI note:** the engine is ABI-coupled to the Ring version (List-struct layout moved
between 1.25→1.27). These number types cross the boundary as **opaque pointers +
strings**, so they are insulated from the List-struct churn — but the DLL must still be
rebuilt against the active Ring. Keep the `-Dring` override in mind.

---

## Part 5 — Lifecycle discipline (the one hard part)

The single real engineering risk is **handle ownership**, because Ring has no
destructors. Three tiers, cheapest-correct first:

1. **Stateless round-trip (Phase 1 default).** Each op allocates inputs from strings,
   computes, stringifies the result, frees all three handles. Zero long-lived handles,
   zero leaks; the only cost is alloc/free per op. Correct and shippable immediately.
2. **Owned handle + explicit `Free()`.** The class holds `@pHandle` across its life;
   the caller frees. Fast for chains; leaks if the caller forgets.
3. **Bounded, generation-keyed cache (the resident-list solution, reused).** A FIFO-
   evicted engine-side registry so a dropped Ring object's handle is reclaimed on
   pressure rather than leaked — exactly the mechanism that fixed the resident-list
   handle leak. This is the target once big-number chains prove hot.

Phase 1 ships on tier 1; tiers 2–3 are a measured optimization, not a prerequisite.

---

## Part 6 — Verification strategy

- **Zig `test` blocks** in each engine module — the arithmetic laws (associativity,
  identity, round-trip `from_string∘to_string`), boundary cases (zero, negative,
  leading zeros, very long strings).
- **Ring narrated guards** — `bignumber_narrated`, `bigdecimal_narrated`,
  `rational_narrated` — each asserting against **independently-computed** expectations
  (Python `int`/`Fraction`/`Decimal`, or hand-verified reference strings), per the
  stress-test method that has caught defects green suites missed.
- **Scale guards** — factorial(1000), a 10^4-digit multiply, `1/3` summed 1000× — both
  for correctness and to prove the native-double fast path did not regress.
- **The delivery assertion** (Phase 6) — the plane places `BigDecimal`/`Rational` on
  the edge and `BigNumber` native. This single test is the end-to-end proof the
  differential story is real.

---

## What this unlocks

- **Correctness by default** — `stzNumber` stops silently rounding past 2^53.
- **A first-class exact-integer type** — the engine `StzBigInt` becomes reachable as
  `new stzBigNumber(...)`, chainable, operator-enabled.
- **The number types the browser cannot do** — exact decimal (money) and exact
  rational (math) — which, unlike plain `BigNumber`, **earn a place on the wasm edge**
  as genuine differential value.
- **A corrected record** — the delivery reasoning stops claiming Softanza has no
  arbitrary-precision engine, and states the accurate rule: integers match `BigInt`
  (defer), decimals/rationals exceed it (ship).

---

*Nothing above is built. This is the plan the appserver work waits on: implement
`stzBigNumber` over the engine `StzBigInt` that already exists, make `stzNumber`
promote instead of round, then build the decimal and rational types that give the
edge something the platform genuinely lacks.*
