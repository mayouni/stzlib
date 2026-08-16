# SOFTANZA TUKEY PLAN — the exploration tier (TK0–TK6)

Status: **PLAN OF RECORD**, written 2026-08-16, before any code.
Supersedes the three legacy notes in `libraries/stzlib/future/todo/`:

- `softanza-tukey-mind-enhancement-framework.md`
- `softanza-tukey-discovering-hidden-stories-in-your-data.md`
- `Tukey-Softanza-Framework-Programmer-Tutorial.md`

Those documents are **claims, not code**. Every output block in them was
written by hand, none of it was ever run, and several of the numbers are
arithmetically impossible (§0.5 names them). They are kept as the source
of intent; §0.5 dispositions every claim they make as ADOPT / RESHAPE /
REFUSE. Nothing from them enters the library except through that table.

Siblings, whose laws this plan inherits: `base/gpu/SOFTANZA_GPU_PLAN.md`
(G0–G6, complete), `base/graphics/SOFTANZA_GRAPHICS_PLAN.md` (GR0–GR6,
complete), `base/sound/SOFTANZA_SOUND_PLAN.md` (SN0 pending),
`base/gui/SOFTANZA_GUI_PLAN.md` (G0–G4b shipped),
`engine/SOFTANZA_COMPUTE_MODEL.md` (the compute doctrine).

---

## HOW TO USE THIS DOCUMENT (session bootstrap — read this first)

This file is **sufficient on its own** for a dedicated session that has
never seen the analytics work. It carries the survey, the settled
decisions, the phases with their kill criteria, and the orientation
below. There is deliberately **no companion design document**: this repo
has already been bitten by duplicated rule lists that DRIFT (the
knob-gate audit found two entry points whose copies of the same rules had
diverged). One document. The "strategic proposal", the "design" and the
"implementation plan" are §1, §2–§4 and §5–§6 of this file.

### The mission, in one paragraph

Softanza can ingest data (table/CSV/DB), describe it (stats), model it
(learning/neural/gpu) and present it (graphics/GUI). It cannot **explore**
it — nothing in the library decides which model is even appropriate
before one is fitted, and nothing tells an analyst where to look. Tukey's
Exploratory Data Analysis is exactly that missing tier, and its core is
not a chart pack: it is a **decomposition contract** — `Data = Fit +
Residual`, computed *resistantly* (medians, not means) — plus a
**measured re-expression rule** that says which scale the data wants to be
read on. Build the contract in the engine and every face gets it: ASCII,
SVG/PNG, GUI, the rule report, the narration layer, the LLM agent.

### Orientation — where everything is

| what | where |
|---|---|
| this plan | `libraries/stzlib/base/stats/SOFTANZA_TUKEY_PLAN.md` |
| legacy claims (read once, then only via §0.5) | `libraries/stzlib/future/todo/*tukey*.md` |
| the stats engine you will extend | `libraries/stzlib/engine/src/stats.zig` (1101 lines) |
| the ASCII plot renderer you will extend | `libraries/stzlib/engine/src/plot.zig` (2436 lines) |
| the DLL domain both already live in | `stz_stats` — `src/stz_stats_entry.zig`, `src/ring_bridge_stats.zig`, `build.zig:63` |
| existing Ring plot faces (the shape to copy) | `base/stats/stzScatterPlot.ring`, `stzHistogram.ring` |
| the dataset face | `base/stats/stzDataSet.ring` (4106 lines) |
| two-way data sources | `base/table/stzPivotTable.ring`, `base/table/stzTable.ring` |
| the verdict contract | `base/graph/stzRuleReport.ring` (`Ingest`, `IsSound`, `Explain`) |
| the narration face | `base/conversation/stzNarration.ring` |
| agentic memory (TK6 only) | `base/agentic/stzAgentMemory.ring` |
| guards (create) | `libraries/stzlib/base/test/tukey/` |
| project rules | `CLAUDE.md` at the repo root — READ IT |

### Commands

```bash
cd libraries/stzlib/engine && zig build
```

```bash
cd libraries/stzlib/base/test/tukey && ring tukey_fit_narrated.ring
```

### The working discipline (non-negotiable)

1. **Measure before believing anything, including this plan.** Every
   phase gate is a measurement, and the sibling plans named the wrong
   line repeatedly (G0's crossover seed was 62x too cautious; GR0's kill
   criterion aimed at a tier that cost 3% of the budget). §5 predicts
   its own outcomes so they can be scored.
2. **Write kill criteria BEFORE looking at numbers.** Half this work's
   value is saying where Tukey does NOT need an accelerator and where a
   proposed feature does NOT ship.
3. **Guards are narrated and assert the MECHANISM.** Every positive
   needs a negative sibling — the thing that proves the guard would
   notice a failure. For this plane the negative sibling is usually
   *contamination*: an assertion that a resistant estimate does NOT move
   when one point is dragged to infinity, next to one that shows the
   mean-based estimate DOES.
4. **Expectations come from outside this library** (§6). A guard that
   compares our median polish to our median polish proves nothing.
5. **Engine-first**: substance in Zig so every binding gets it; Ring is
   ONE face. Ring-side arithmetic here is capability other bindings will
   not have — and `stzDataSet.BoxPlotStats()` (line 2423) is already an
   instance of that mistake, computing fences in Ring.
6. **Cross once per ALGORITHM**, not per rung. The re-expression ladder
   evaluates every power engine-side and returns one table.
7. **Parallel sessions work this repo**: `git add <explicit paths>`,
   never `-A`.
8. **Push protocol**: `git push origin main` then
   `git push codeberg HEAD:refs/heads/main`; verify both with
   `git ls-remote <remote> main` against `git rev-parse main`. If
   codeberg fails, say PENDING and move on.
9. **Record the outcome** in this file (a `## TK<n> RESULTS` section) and
   in memory (`project_tukey_plane.md`) when a phase ends.

### The first action

**TK0**, exactly as specified in §5: the convention decision plus the
median-polish spike. Measurement only, no product code, kill criteria
applied before the numbers are interpreted.

---

## 0. THE SURVEY (taken 2026-08-16)

### 0.1 What the library gained since the legacy notes were written

The notes assumed Softanza was an ASCII visualization library. It is not,
and has not been for some time. The delta that makes this plane worth
reopening:

| asset | where | what it changes for Tukey |
|---|---|---|
| Compensated statistics in Zig, with the **variance divisor and the summation named once and only once** | `stats.zig:31-232` | there is an established doctrine for "the ambiguous choice is documented, not silent" — the hinge decision (§2.2) follows it exactly |
| ASCII plots rendered **in the engine**, on a codepoint canvas, returning the finished picture | `plot.zig:1-21` | stem-and-leaf, box and residual displays are new renderers on an existing asset, not a new subsystem |
| Every plot face answers `ToCanvasQ` / `ToSVG` / `ToPNG` | `stzScatterPlot.ring:130-143` | a Tukey display gets vector and raster output for free |
| A graphics plane (wgpu, text shaping, charts, org charts) | `base/graphics/`, GR0–GR6 complete | the "ASCII is our unique advantage" premise of the legacy notes is dead; ASCII is now **one** target |
| A GUI plane with a real window, a panel, and a screen-reader-visible tree | `base/gui/`, G0–G4b shipped | "click to explore" belongs there, not in a parallel interactive class |
| ML tier: kmeans, knn, decision tree, logistic, naive bayes, apriori, model eval | `base/learning/` | EDA now has a downstream consumer that *needs* to be told which scale to model on |
| Neural tier + embeddings + LLM agent faces | `base/neural/`, `base/agentic/` | the narrative layer can be language-model-driven — and therefore needs the honesty law of §2.6 |
| PCA / t-SNE / UMAP, autodiff + L-BFGS, multicore reductions, GPU tier | `engine/src/{pca,tsne,umap,autodiff,lbfgs}.zig`, `base/gpu/` | acceleration is available *and* the doctrine for refusing it is established |
| A unified verdict shape + one CI gate | `stzRuleReport.ring` | EDA findings become assertable facts, not prose |
| A narration face | `stzNarration.ring` | the "StoryTeller" has a home; it does not need inventing |

### 0.2 What already exists that Tukey needs

`stats.zig` C ABI (via `stz_stats`): count, mean, sum, min, max, range,
median, variance (sample/population, divisor named), std dev, coefficient
of variation, percentile, q1/q2/q3, IQR, skewness, kurtosis, geometric
and harmonic mean, z-scores, outliers, mode, **trimmed mean**, weighted
mean, normalize, standardize, moving average, correlation, covariance,
**regression**, rank correlation, deciles, frequency.

`plot.zig`: `renderBar`, `renderHBar`, `renderHistogram`, `renderMBar`,
`renderScatter`, `renderSurface`, plus the bin-choice and label
machinery. `pivot.zig`: `stz_pivot_cross_tab`, `stz_pivot_multi_group_by`
— the two-way table already exists as data.

### 0.3 What is missing (this is the work)

Verified absent from the repository on 2026-08-16:

- **Hinges (fourths)** and the letter-value ladder (M F E D C B A …).
  `stats.zig` has percentile quartiles only.
- **Median polish** — the resistant two-way fit. Nothing, anywhere.
- **Resistant line** (three-group line). Nothing; `stz_stats_regression`
  is least-squares.
- **Tukey smoothers** — 3R, 3RSS, 3RSSH, Hanning, 4253H, twicing.
  `stz_stats_moving_average` is a mean filter and is not resistant.
- **Robust scale**: no MAD, no biweight midvariance (`grep -i mad
  stats.zig` → nothing). The order statistics (median, quartiles) are
  resistant, but `trimmed_mean` is the only resistant estimator beyond
  them — there is no resistant measure of *spread* at all.
- **A live instance of the drift disease next door**:
  `stz_stats_moving_average` (`stats.zig:602`) accumulates a **naive
  uncompensated running sum** — in the very file whose header sermon is
  that the summation lives in one compensated place
  (`stats.zig:31-51`). TK1 fixes it in passing, since the smoother work
  touches that neighbourhood anyway.
- **The outer fence.** `stz_stats_outliers` (line 498) applies
  `1.5 * IQR` from percentile quartiles and stops there — no `3 x`
  far-out band, and it does not say which quartile convention it means.
- **Box plot.** `stzDataSet.BoxPlotStats()` (line 2423) computes the
  five numbers *in Ring* and its own comment promises a `stzBoxPlot`
  that does not exist. The library has had a dangling box-plot promise
  in its source for as long as it has had the comment.
- **Stem-and-leaf.** Nothing.
- **Re-expression search.** Nothing — no ladder, no spread-versus-level,
  no diagnostic slope.
- **Non-additivity diagnosis.** Nothing.

### 0.4 The cost this implies

Everything above lands in **one existing DLL domain** (`stz_stats`,
`build.zig:63`), alongside `stats.zig` and `plot.zig` which are already
imported by `ring_bridge_stats.zig`. No new DLL, no vendored dependency,
no cross-compile surface, no per-OS build. This plane is the cheapest
major capability left on the roadmap.

### 0.5 DISPOSITION OF THE LEGACY CLAIMS

Read this table instead of the three notes.

| # | Legacy claim | Disposition | Reason |
|---|---|---|---|
| 1 | `stzTukeyExplorer` / `QuickLook()` — one-batch first look | **ADOPT** as `stzTukeySummary` | this is the real Tukey "rough and ready", and it is genuinely missing |
| 2 | Dual naming: `DataDetective` = `stzTukeyExplorer`, `PatternHunter`, `ResidualInvestigator`, `StoryTeller`… | **REFUSE** | two names for one class is exactly what the semantic-unification project exists to kill; and `Hunter`/`Detective`/`Investigator` are the aggressive-noun naming the house style forbids. Friendliness belongs in the narration and the docs, not in duplicated class names |
| 3 | Symbol coding system (● ○ ◐ ◆ ▲ ▼ ■ ★ ✱) | **RESHAPE** | keep it, but a glyph must be **derived** from `residual / fourth-spread` bands, never assigned by hand to a meaning. And the legend prints with the table, always (§2.5) |
| 4 | `DefineSymbols(["🚀" = "outstanding_growth", …])` | **REFUSE** | user-assigned symbol→meaning maps make the display unfalsifiable. A swappable *glyph set* (with fixed band semantics) is the reshaped version |
| 5 | Three-line separator hierarchy (`═══` / `───` / `···`) | **ADOPT** | cheap, genuinely Tukey, and it is real visual structure |
| 6 | Two-way effect decomposition | **ADOPT — but by median polish** | the legacy examples compute "Row Effect" from **averages** (tutorial §2.1: `Row Avg` → `Row Effect`). That is ANOVA wearing Tukey's clothes and it is not resistant; a single wild cell moves every effect. Median polish is the method |
| 7 | Additivity test + transformation suggestion | **ADOPT, and make it measured** | the legacy version tries transformations and eyeballs the result. The real rule is a **slope**: regress residual on the comparison value `row·col/grand`, or log-spread on log-level; suggested power = `1 − slope` (§2.4) |
| 8 | Stem-and-leaf, letter values, box plot with notches and mild/extreme outliers | **ADOPT** | all three missing, all three cheap, all three ride `plot.zig` |
| 9 | Smoothers: 4253H, reroughing/twicing, change points | **ADOPT** (engine) | change-point *detection* is demoted to a verdict with a stated threshold, not a claim |
| 10 | Residual plot, spread-location plot | **ADOPT** | |
| 11 | Conditioned / panel ("trellis") plots | **ADOPT, late** | a layout over existing plots (TK3), not a class |
| 12 | Multiple-Y comparison plot | **RESHAPE** | an overlay option on the existing scatter/line faces |
| 13 | `stzTukeyGrid` "adaptive graph paper" | **SPLIT** | ADOPT **banking to 45°** as an axis policy (a real, measurable result). REFUSE grid density that varies with data density — decoration, and it makes two regions of one picture non-comparable |
| 14 | `stzTukeyScale` — round numbers, minimise white space | **ADOPT** as tick policy in the plot layer | partly present already; finish it rather than fork it |
| 15 | `stzTukeyInteractive`, click-to-explore, hover explanations | **DEFER to the GUI plane** | G5's reactive half owns this. A parallel interactive system is the fork we spent GR5 avoiding |
| 16 | `CreateTukeyDashboard()` deploying to `localhost:8080` | **REFUSE as specified** | the appserver plane serves pages; a class that "deploys a dashboard" as a side effect of an analysis call is not a Softanza shape |
| 17 | `stzTukeyMemory` — remembers which transformations worked | **DEFER to agentic, with a kill criterion** | `stzAgentMemory` exists. It ships only if it beats the fixed policy "always evaluate the ladder" (§5, TK6) |
| 18 | "Users with similar data patterns found success with… (73%)" | **REFUSE** | there is no corpus. This is fabricated social proof |
| 19 | `stzTukeyMasterOrchestrator.ExecuteFullWorkflow()` emitting F-statistics, p-values, R², forecasts and confidence intervals | **REFUSE as specified** | it smuggles confirmatory inference into an exploratory frame and reports it as discovery. Inference stays in `stzHypothesis`, invoked deliberately. The reshaped version is a *pipeline* of the four analysis faces, and it forecasts nothing |
| 20 | "Automated insight generation" with dollar impacts and confidence scores (94%, 87%, 83%…) | **REFUSE** | those percentages are attached to no computation. This is the single most dangerous idea in the legacy notes: it is a hallucination engine with a statistics costume. The reshaped version is §2.6 — verdicts that must name the measurement that produced them |
| 21 | `stzTukeyFingerFrames`, attention sequencing, sliding windows | **RESHAPE** | a "focus region" is a subset plus a local fit, which the fit contract already expresses; the guided sequence is narration. No new class |
| 22 | `λ(x) → log(x)` transformation syntax | **REFUSE (not Ring)** | transforms are named symbols (`:Log`, `:Sqrt`, `:Power`) resolved engine-side, which is also what lets the ladder cross once |
| 23 | "ASCII's unique advantage" as the framing | **OBSOLETE** | ASCII is now one render target of several (§2.7) |

Two arithmetic errors in the legacy notes, recorded so they are not
copied forward as expectations: the discovering-hidden-stories note
prints a `North Q4` cell of 105 with a row effect of +12 and a column
effect of +18 on a grand of 86.5 (fit = 116.5, residual −11.5) while its
own interactive panel claims "Peak Performance ★" for the same cell — a
star awarded to the *largest value* on a page whose entire thesis is that
you must read the *residual*. (The stated grand of 86.5 is itself wrong —
the matrix's grand mean is 87.5 — so the note is broken even on its own
numbers.) And the tutorial's two-way table (§2.1)
states a grand mean of 57.5 for a matrix whose grand mean is 57.125,
which is why neither its row effects (+1.3 / −6.7 / +7.8 / −3.7, sum
−1.3) nor its column effects (−13.5 / −7.5 / +7.8 / +11.8, sum −1.4)
come to zero — and an effect decomposition whose effects do not sum to
zero is not a decomposition. Neither document was ever run.

---

## 1. STRATEGIC PROPOSAL

### 1.1 The thesis

**Tukey is not a chart pack. It is a contract.**

    Data = Fit + Residual         computed resistantly
    Scale is a choice             and the data says which one

Every symbol table, every box, every narrative in the legacy notes is a
*rendering* of those two lines. Build the renderings first and the
library gets a decorative chart pack that does not compose. Build the
contract in the engine and every existing plane inherits it.

### 1.2 Where it sits in the stack

```
  ingest        stzTable  stzPivotTable  CSV  DB  stzDataWrangler
     |
  describe      stzDataSet  stats.zig                     <- present
     |
  EXPLORE       stzTukeySummary  stzTukeyFit                 MISSING
                stzTukeySmoother stzTukeyReexpression      <- this plan
     |
  model         stzKMeans stzDecisionTree stzNeural gpu   <- present
     |
  present       plot.zig  graphics  gui  stzNarration     <- present
```

The exploration tier answers the question no other tier answers: *is the
model you are about to fit even the right shape, and on what scale?* A
library that can fit a logistic regression but cannot tell you the
response is multiplicative is a library that will confidently fit the
wrong thing.

### 1.3 Why now, and why it is different from two years ago

Three things changed.

**The output problem dissolved.** In 2024 the plane's justification was
"ASCII is immediate". Today `plot.zig` renders finished pictures in the
engine, the graphics plane emits SVG and PNG, and the GUI plane puts a
panel in a real window. A Tukey display is now a *model* with four
render targets, and the model is the valuable half.

**The consumers arrived.** There was no ML tier to inform, no agentic
layer to keep honest, no rule report to feed. All three now exist, and
all three want exactly what EDA produces.

**The doctrine arrived.** The engine has learned to name its ambiguous
conventions once (`stats.zig`'s variance divisor), to refuse acceleration
that measurement does not justify (the multicore tier killed elementwise
on both accelerators), and to route verdicts through one shape. Tukey's
methods are full of ambiguous conventions — hinges versus quartiles is
the textbook example — and this repo now has the discipline to settle
them out loud.

### 1.4 What it unlocks

- **Honest AI analytics.** An LLM asked to "analyse this data" invents
  structure. An LLM handed a median-polish decomposition, a fourth-spread
  scale and a list of measured verdicts can only *phrase* what was
  measured. §2.6 makes that a testable law, not an aspiration.
- **Assertable data shape.** `oReport.IsSound()` over EDA verdicts means
  a pipeline can fail CI when its input distribution changes shape —
  data drift detection with no new machinery.
- **The box plot the library has been promising itself.**
- **A reason for the rest of the stack to be resistant.** Once MAD and
  biweight exist in the engine, `stzDataSet`, the perf histograms and
  the anomaly paths can all stop being fooled by outliers.

### 1.5 What this plane is not

It is not inference. It produces no p-values, no confidence intervals, no
forecasts. When a question needs those, `stzHypothesis` is one call away
and the analyst chose it deliberately. An exploration tier that quietly
emits significance is worse than no exploration tier, because it launders
a hypothesis found in the data as if it had been posed beforehand.

---

## 2. DESIGN — the settled decisions

### 2.1 D1: one contract object, four producers

`stzTukeyFit` is the single shape every analysis produces and every
display consumes:

| part | one-way | two-way | n-way | line |
|---|---|---|---|---|
| `Common()` | overall median | grand effect | grand effect | intercept |
| `Effects(:Row)` | group effects | row effects | per-dimension effects | — |
| `Effects(:Col)` | — | column effects | per-dimension effects | slope |
| `Residuals()` | vector | matrix | array | vector |
| `Diagnostics()` | verdicts | verdicts | verdicts | verdicts |

One shape means one renderer family, one narrative generator, one verdict
emitter. The legacy notes had `stzTukeyTwoWay`, `stzTukeyMultiWay`,
`stzTukeyRowAnalysis`, `stzTukeyResidual` and `stzTukeyResistant` all
carrying overlapping state; that is five places for the same idea to
diverge in cost and convention, which this repo has already paid for
twice.

### 2.2 D2: the hinge convention is NAMED, once

Tukey's **fourths** (hinges) are not quartiles. Their depth is
`d(F) = (floor(d(M)) + 1) / 2` where `d(M) = (n+1)/2`; the fourth-spread
is `F_upper − F_lower`; the fences are `F ± 1.5·Fspread` (outside) and
`F ± 3·Fspread` (far out). The library today has percentile quartiles
and a bare 1.5 fence that does not say which convention it used
(`stats.zig:498`).

Both conventions are correct. Picking silently is not — this is
letter-for-letter the disease `stats.zig:204-230` already diagnosed for
the variance divisor. So:

- `eda.zig` defines `hingeDepth`, `fourths`, `fourthSpread` and the
  fence pair **once**, with a header comment in the same idiom as the
  variance-divisor block, stating that Tukey's fourths are the default
  *for Tukey displays* and that percentile quartiles remain the default
  for `stzDataSet` and everything already shipped.
- `stz_stats_outliers` gains a sibling that takes the convention and the
  fence multiplier as arguments; the existing function keeps its
  behaviour and gains a doc line saying which convention it means.
- Every box plot and every letter-value display **prints which
  convention it used**.

TK0 measures how far apart the two conventions actually fall on real
data, so the decision is documented with a number beside it.

### 2.3 D3: resistance is a policy, not a class hierarchy

`stzTukeyFit` carries two knobs rather than spawning a parallel resistant
class:

```ring
oFit = new stzTukeyFit(oPivotTable)
oFit {
    SetCenter(:Median)        # :Median (default) | :Mean | :Biweight
    SetScale(:FourthSpread)   # :FourthSpread (default) | :MAD | :StdDev
    Polish()
}
```

Setting `:Mean` + `:StdDev` reproduces the classical additive
decomposition, which is what makes the resistance *demonstrable*: the
guard drags one cell to 10^9 and asserts the median-polish effects move
by less than one fourth-spread while the mean-based effects move by
orders of magnitude. That is the negative sibling the house rules
require, and it falls out of the design rather than being bolted on.

### 2.4 D4: re-expression is measured, never eyeballed

Two slopes, both computed engine-side, both reported with their evidence:

- **Spread-versus-level** — for grouped data, fit a line through
  `(log median_g, log fourthSpread_g)`. Slope `b` ⇒ suggested power
  `p = 1 − b`. `b ≈ 1` ⇒ log; `b ≈ 0.5` ⇒ square root; `b ≈ 0` ⇒ leave
  it alone.
- **Comparison values** — for a two-way fit, regress the residual
  `r_ij` on `c_ij = (rowEffect_i · colEffect_j) / common`. Slope `b` ⇒
  suggested power `p = 1 − b`. This is Tukey's diagnosis of
  non-additivity and it is the honest version of legacy claim #7.

The ladder (`-1, -0.5, 0, 0.5, 1, 2`) is then evaluated for real: each
rung is applied, refitted, and scored on residual size and on how flat
the diagnostic slope became. **All rungs are evaluated in one engine
crossing** and returned as one table — cross once per algorithm.

The recommendation is a verdict carrying its slope, not an opinion.

### 2.5 D5: a coded display prints its legend, or it is a lie

The symbol in a cell is a rendering of `residual / scale`, banded:

| band | meaning | default glyph |
|---|---|---|
| `\|r\|/s < 0.5` | at the fit | `·` |
| `0.5 ≤ \|r\|/s < 1` | mild, signed | `○` / `●` |
| `1 ≤ \|r\|/s < 2` | notable, signed | `◔` / `◕` |
| `2 ≤ \|r\|/s < 3` | outside, signed | `▽` / `▲` |
| `\|r\|/s ≥ 3` | far out | `◆` |

The whole table is in **one currency** — residual over scale. An earlier
draft stated the last band as "beyond the outer fence", a data-value
criterion, which would have let a cell satisfy two bands at once; the
fences classify *data values* in `stzTukeySummary`, the bands classify
*residuals* here, and the two are not mixed on one display.

Bands are the display's parameters and may be set; the **mapping from
band to meaning is fixed**, and the legend — bands, glyphs, scale value,
and the hinge convention — is emitted with every coded table. Glyph
*sets* are swappable (ASCII-only, box-drawing, theme-driven) because
terminals differ; meanings are not, because a reader must be able to
trust one page against another.

### 2.6 D6: verdicts use the house shape, and the narrative computes nothing

Every diagnostic is a finding in the unified rule shape
`[:rule, :subject, :where, :severity, :message]`, ingested by
`stzRuleReport` — the same gate the graph, org-chart and knob rules
already feed. Examples:

```
[ :non_additive, :sales, "region x quarter", :warning,
  "residuals track row*col/grand with slope 0.94; try log" ]

[ :far_out, :sales, "South,Q2", :error,
  "residual -3.8 fourth-spreads, beyond the outer fence" ]

[ :spread_tracks_level, :sales, "by region", :warning,
  "log-spread on log-level slope 0.51; try square root" ]
```

Consequences: EDA becomes CI-gatable, the narrative layer becomes a
*renderer of findings*, and the LLM face becomes safe by construction.

**The honesty law**: `stzTukeyStory` performs no arithmetic. Every number
that appears in generated prose is read from the fit or from a finding.
The guard for TK5 runs the same story twice — once with the LLM face
disabled and once enabled — and asserts every numeral in the output is
identical. Phrasing may differ; numbers may not.

### 2.7 D7: one model, four render targets

The engine computes the display model once. The targets:

| target | how | when |
|---|---|---|
| ASCII / terminal | `plot_eda.zig`, sharing `plot.zig`'s codepoint canvas | TK3 |
| SVG | the `ToSVG` path every plot face already has | TK3 |
| PNG | the `ToPNG` path | TK3 |
| GUI panel | `stzPanel`, bound reactively | TK6, gated on GUI G5 |

`plot_eda.zig` is a **sibling file in the same domain**, not a new
module: `plot.zig` is 2436 lines and its canvas, tick and label helpers
are the asset being reused. Both are already imported by
`ring_bridge_stats.zig`.

### 2.8 D8: the class list, and what it replaces

Nine faces. The legacy notes named twenty-five.

**Analysis** (`base/stats/`)

| class | responsibility |
|---|---|
| `stzTukeySummary` | letter values, hinges, fences, five-number, shape verdicts |
| `stzTukeyFit` | one/two/n-way median polish, resistant line; the contract of §2.1 |
| `stzTukeySmoother` | 3R, 3RSS, 3RSSH, Hanning, 4253H, twicing; smooth/rough split |
| `stzTukeyReexpression` | spread-vs-level, comparison values, the ladder, the recommendation |

**Display** (`base/stats/`, beside `stzHistogram` and `stzScatterPlot`,
answering `ToCanvasQ` / `ToSVG` / `ToPNG` like every other plot)

| class | responsibility |
|---|---|
| `stzBoxPlot` | notched box, mild and far-out points, group comparison — *the promise at `stzDataSet.ring:2423`* |
| `stzStemPlot` | stem-and-leaf, back-to-back, adaptive stem width |
| `stzResidualPlot` | residual-versus-fit, spread-location, comparison-value diagnostic |
| `stzCodedTable` | the two-way symbol table of §2.5, with its legend |

**Narrative** (`base/stats/`)

| class | responsibility |
|---|---|
| `stzTukeyStory` | findings and fit → prose, via `stzNarration`; computes nothing |

Naming follows the house conventions: verb methods, `Q()` for chainable
objects and plain for data, no dual "friendly" names, and no nouns like
Hunter or Detective. Displays are named for what they are, not for the
framework they belong to, because that is where a user will look for
them.

---

## 3. ENGINE DESIGN

### 3.1 `eda.zig` — new, in the `stz_stats` domain

Built on `stats.zig`'s compensated primitives; it does not re-implement
summation, variance or percentile.

```
  Order statistics and resistance
    hingeDepth(n)                       fourths(sorted)
    fourthSpread(sorted)                letterValues(sorted, levels) -> [level]{lo,hi,mid,spread}
    fences(sorted, mult, convention)    mad(data)
    biweightMidvariance(data, c)        trimean(sorted)

  Fits
    medianPolish1D(values, groups)      medianPolish2D(matrix, rows, cols, iters, eps)
    medianPolishND(array, dims, ...)    resistantLine(x, y, iters)   // three-group

  Smoothers
    smooth3(x)   smooth3R(x)   smoothSS(x)   smoothH(x)   smooth4253H(x)
    twice(x, kernel)                    roughOf(x, smooth)

  Re-expression
    spreadLevelSlope(medians, spreads)  comparisonValues(fit)
    nonAdditivitySlope(fit)             evaluateLadder(fit, powers) -> [power]{slope, residualScale, ok}

  Verdicts
    diagnose(fit, opts) -> [finding]    // the rule shape, emitted as data
```

Conventions in a header block in the `stats.zig:204` idiom: the hinge
definition, the fence multipliers, the polish convergence rule
(`max|Δresidual| < eps · fourthSpread`, iteration cap stated), and the
tie-breaking rule for even-length medians.

### 3.2 `plot_eda.zig` — new, same domain

```
    renderStem(values, opts)        renderBox(groups, opts)
    renderResidual(fit, opts)       renderSpreadLocation(fit, opts)
    renderCodedTable(fit, opts)     renderLetterValues(lv, opts)
```

Same contract as `plot.zig`: return the finished text on a codepoint
canvas, take a glyph-override options struct, allocate the result once.

### 3.3 Bridge and faces

Exports added to `stz_stats_entry.zig`; list-returning calls follow the
engine list-return contract (measure, then whole items or none — the
fixed-buffer truncation lesson). Ring faces in `base/stats/`, loaded from
`base/stzBase.ring`. Engine bridges are 0-based, Ring faces 1-based,
translated at the face and said so in the face.

---

## 4. THE RING SURFACE (illustrative — not yet run)

Every code block below is a **design sketch**. Nothing in this document
is presented as executed output; the legacy notes' habit of printing
invented results is the thing this plan exists to correct. Real narrated
outputs land in `base/test/tukey/` as the phases complete, and the
tutorial is regenerated from them.

```ring
# The first look
oSum = new stzTukeySummary(aSales)
oSum {
    LetterValues()          # M F E D C B A with mid and spread
    Fences()                # inside and outside, hinge convention stated
    Shape()                 # verdicts: skew, tail weight, modality
    ShowQ().Stem()          # stem-and-leaf
    ShowQ().Box()           # notched box
}

# The two-way fit
oFit = new stzTukeyFit(oPivotTable)
oFit {
    Polish()                             # median polish to convergence
    Common()  Effects(:Row)  Residuals() # the contract of §2.1
    ShowQ().CodedTable()                 # symbols + legend
    ShowQ().Residuals()                  # residual vs fit
}

# Is it on the right scale?
oRe = new stzTukeyReexpression(oFit)
oRe {
    Ladder()                # every power, one crossing
    Recommend()             # a power, with its slope as evidence
}

# What did it find?
oReport = new stzRuleReport("sales-eda")
oReport.Ingest(oFit.Diagnostics() + oRe.Diagnostics())
? oReport.IsSound()
? new stzTukeyStory(oFit, oReport).Text()
```

---

## 5. IMPLEMENTATION PLAN — phases and kill criteria

Each phase ends with a `## TK<n> RESULTS` section appended to this file
and a memory update. Kill criteria are written **now**, before any
number is seen.

### TK0 — Convention and spike (measurement only, no product code)

1. Implement hinges and letter values as a throwaway spike; measure how
   far Tukey fourths and percentile quartiles diverge across the
   library's existing test datasets, and record the distribution of the
   gap. **Write the convention decision into this file with that number
   beside it.**
2. Implement `medianPolish2D` as a spike; verify against R's
   `stats::medpolish` on its own documented example and on one published
   Tukey table (§6).
3. Time median polish at 10×10, 100×100, 1000×1000 and 4000×4000.

**Kill criteria, stated in advance.**
- If 1000×1000 median polish converges in **< 5 ms** single-threaded,
  the acceleration question is **CLOSED**: no multicore, no GPU, and
  this file records the refusal with its number. *Prediction: it will
  close.* Median polish is O(sweeps · n·m) with linear-time selection;
  the multicore tier's own gates admit `compensatedSum` only at 4M
  elements, and a 1000×1000 table is 1M.
- If the two quartile conventions differ by **< 0.1 fourth-spread** on
  every dataset tested, the plan simplifies: one convention, documented,
  no dual path. If they differ more, both paths ship and every display
  states which it used.
- If R's `medpolish` cannot be reproduced to within `1e-9` on its own
  example, the phase does not proceed — the convergence rule or the
  tie-break is wrong, and everything downstream would inherit it.

### TK1 — The resistant core (`eda.zig`)

Hinges, letter values, MAD, biweight midvariance, trimean, both fences,
median polish (1D/2D/ND), resistant line, and the smoother family (3, 3R,
SS, H, 4253H, twicing). C ABI, bridge, and Ring-visible primitives.

**Guards**: values pinned against R and published constants (§6);
contamination guards proving each resistant estimate holds while its
classical sibling moves; a convergence guard proving the polish stops and
a capped guard proving it terminates on a pathological input.

**Kill criterion**: any estimator that cannot be pinned against an
external oracle does not ship in TK1. It waits for one.

### TK2 — Re-expression, measured

Spread-versus-level slope, comparison values, non-additivity slope, the
ladder evaluated in one crossing, the recommendation as a verdict with
its evidence.

**Guard**: a synthetic multiplicative table must yield a recommended
power near 0 (log) with a slope near 1; a genuinely additive table must
yield power near 1 and **must not** recommend a transform. The second
half is the negative sibling and matters more than the first.

**Kill criterion**: if the recommender fires on additive data more than
once in the synthetic suite, it ships as a *diagnostic slope only*, with
no recommendation, until the threshold is measured properly.

### TK3 — Displays (`plot_eda.zig` + four Ring faces)

`stzBoxPlot`, `stzStemPlot`, `stzResidualPlot`, `stzCodedTable`, each
with `ToCanvasQ` / `ToSVG` / `ToPNG`, each printing the conventions it
used. `stzDataSet.BoxPlotStats()` is **delegated to the engine** in this
phase — the Ring-side fence arithmetic at line 2423 goes away rather than
acquiring a second implementation beside it.

**Guard**: the picture is verified by *reading it back* — column
positions of the median and the hinges are asserted against the computed
values, not eyeballed. The GUI plane's measured lesson applies here
(seven defects found by looking at pictures, zero by assertions written
first), so every display guard also writes a PNG a human can open, and
the phase is not closed until they have been looked at.

### TK4 — Faces and the verdict contract

`stzTukeySummary`, `stzTukeyFit`, `stzTukeySmoother`,
`stzTukeyReexpression`; all diagnostics in the house rule shape flowing
into `stzRuleReport`.

**Guard**: a dataset whose shape is deliberately broken must make
`IsSound()` answer false, and the same dataset repaired must make it
answer true. One CI gate, both directions.

### TK5 — The story

`stzTukeyStory` on `stzNarration`. Optional LLM phrasing through
`stzLLMAgent`.

**Guard (the honesty law of §2.6)**: the story generated with the LLM
face disabled and enabled must contain **identical numerals**. If it
cannot be made to, the LLM path does not ship.

**Kill criterion**: if templated prose reads as well as generated prose
in the author's judgement, the LLM path does not ship at all. This is a
capability the plane does not need to have.

### TK6 — Interaction and memory (both gated, both refusable)

- **Panel**: `stzPanel` bound to a fit, drilling from cell to residual
  to source rows. **Gated on GUI G5** (the reactive half). Not started
  before G5 lands.
- **Memory**: `stzAgentMemory` recording which re-expressions worked on
  which data shapes. **Kill criterion**: it ships only if, on a held-out
  set of datasets, its suggestion beats the fixed policy "evaluate the
  whole ladder and take the best slope". If the fixed policy wins — and
  it may well, because the ladder is cheap — the memory does not ship
  and this file records why.

### Sequencing

TK0 → TK1 → TK2 are strictly ordered. TK3 is gated per display:
`stzStemPlot`, `stzBoxPlot` and `stzCodedTable` need only TK1, but
`stzResidualPlot`'s comparison-value and spread-location panels render
TK2 machinery and wait for it — residual-versus-fit alone may ship on
TK1. TK4 requires TK2. TK5 requires TK4. TK6 requires TK4 and, for its first half,
GUI G5. Nothing here blocks the sound plane, the graph plane or the GUI
plane; the only shared file is `stz_stats_entry.zig`.

---

## 6. VERIFICATION METHOD — where the expectations come from

The promises-harness lesson applies at full force: this repo has 7,635
hand-written expected outputs that were never compared, and the pilot
found real divergence in every module it checked. So:

**No expectation in this plane is written by hand.**

| subject | oracle |
|---|---|
| median polish | R `stats::medpolish` — its documented example, plus two published tables |
| smoothers, 3-family | R `stats::smooth(kind = "3RS3R" / "3RSS", twiceit = TRUE)` |
| 4253H and Hanning | **not in base R** — `stats::smooth` covers only the 3-family. Oracle is the published worked series in Velleman & Hoaglin, *ABC of EDA* (where 4253H comes from), transcribed with page numbers |
| letter values | the published ladders in Tukey's *EDA* and in Hoaglin/Mosteller/Tukey |
| hinges and fences | worked examples with known integer answers at every `n mod 4` |
| resistant line | Tukey's three-group line on its published example |
| box plot geometry | asserted by reading the rendered canvas back, not by eye |
| re-expression | synthetic data built *from* a known power, so the right answer is known by construction |

Oracle values are transcribed into the guard with the command that
produced them in a comment, so any future disagreement is adjudicable
without re-deriving anything.

The library's own outputs are never the expectation for its own guards.

---

## 7. RISKS AND STANDING REFUSALS

| risk | response |
|---|---|
| **The plane becomes a chart pack.** Displays are fun; contracts are not | TK1 and TK2 land *before* TK3. No display is written before the fit it renders exists |
| **Symbol soup.** A coded table nobody can read | legend mandatory, meanings fixed, bands in fourth-spread units (§2.5) |
| **Laundered inference.** Exploration output read as confirmation | no p-values, no intervals, no forecasts (§1.5). Severity, not significance |
| **LLM invention.** Generated prose asserting numbers nobody computed | the honesty law and its guard (§2.6, TK5) |
| **Class explosion.** Twenty-five classes with overlapping state | nine faces, one contract (§2.8) |
| **Convention drift.** Two quartile definitions in one library, silently | named once, printed on every display (§2.2) |
| **Duplicated arithmetic.** Ring-side fences beside engine-side fences | `stzDataSet.BoxPlotStats()` is delegated in TK3, not shadowed |
| **Premature acceleration.** Multicore or GPU because it is available | the TK0 gate, written before the measurement, with its prediction recorded |
| **Scope creep into the GUI plane** | interaction is TK6 and gated on G5 |

---

## 8. INTERFACES WITH THE OTHER PLANES

| plane | interface | direction |
|---|---|---|
| **table** | `stzPivotTable.CrossTab()` is the two-way input | consumes |
| **stats** | `stats.zig` primitives; `stzDataSet` gains resistant summaries and delegates its fences | both |
| **graphics** | `ToSVG` / `ToPNG` on every display; theme and colour system for glyph sets | consumes |
| **gui** | `stzPanel` in TK6, gated on G5 | consumes |
| **graph** | `stzRuleReport` ingests every diagnostic — one CI gate | produces |
| **conversation** | `stzNarration` renders the story | consumes |
| **agentic** | `stzAgentMemory` in TK6, with a kill criterion; `stzLLMAgent` may phrase, never compute | consumes |
| **learning / neural** | the recommended re-expression is what a model should be fitted on | produces |
| **perf** | MAD and biweight give the perf histograms a resistant scale for anomaly bands | produces |

---

## 9. LEGACY DOCUMENT DISPOSITION

The three notes stay where they are, under `future/todo/`, as the record
of intent. Each gains a header line pointing here and stating that its
outputs are illustrative and were never executed. When TK3 and TK5 land,
the tutorial is **regenerated from run guards**, and the regenerated file
replaces the tutorial in the documentation set.

Nothing in those files is a specification. This document is.
