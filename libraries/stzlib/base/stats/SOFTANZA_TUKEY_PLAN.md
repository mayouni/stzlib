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

---

## TK0 RESULTS -- convention and spike, 2026-09-26 (plane stzlib-math, M4)

Ownership first: the math plane's charter (decision 7, ruled 2026-09-26) has
this plane own the Tukey tier end to end -- `eda.zig` as a math-plane engine
file inside the `stz_stats` DLL domain, its pictures as figures of the math
plane -- so the RESULTS of TK0-TK6 are written here by stzlib-math and the
analysis faces live in `base/math/`.

**The spike is `engine/src/eda.zig` with its tests** (`zig test -j2
-OReleaseFast src/eda.zig`, 8 tests): fourths, letter values, fences under
a named convention, MAD, biweight midvariance, trimean, the two-way median
polish, the resistant line, quickselect medians. It is product code kept,
not thrown away, because every line of it is pinned below.

**Kill criterion 1 (R's medpolish to 1e-9): MET.** R's own documented
example (`deaths`, `?medpolish`) is reproduced to 1e-9: overall 8, rows
6 -1 0 2 -8, columns 0 -1 0, the residual table, and Data = Fit + Residual
cell by cell. R is not installed on this machine; the transcription of R's
output was reproduced by an INDEPENDENT NumPy implementation of the same
algorithm (`scratchpad/tk0/medpolish_np.py`, 2 sweeps, converged), and
the two agree -- two routes to the oracle rather than one memory of it.
The stopping rule is R's (sum of |residuals| changing by less than eps
times itself, eps 0.01, at most 10 sweeps) and the even-count median is R's.

**Kill criterion 2 (conventions within 0.1 fourth-spread): NOT MET, so
both paths ship.** On a seeded sweep of sizes 4..200 the fourths and the
percentile quartiles differ by up to 0.2087 fourth-spreads (at n = 4), and
on the library's own box-plot sample `[2,4,4,5,7,9,12,25]` by 0.1154
(fourths 4 and 10.5, percentile 4 and 9.75). Both conventions are defined
once in `eda.zig`'s header in the `stats.zig:204` idiom; every Tukey display
prints which it used; `stzDataSet` keeps percentile quartiles unchanged.

**Kill criterion 3 (1000x1000 polish under 5 ms): NOT MET, and the
prediction was wrong.** Single-threaded, release build, 3 sweeps to
convergence on an additive table with noise:

| size | with sorted medians | with quickselect medians |
|---|---|---|
| 10x10 | 0.01 ms | 0.02 ms |
| 100x100 | 1.12 ms | 0.98 ms |
| 1000x1000 | 171.65 ms | 46.13 ms |
| 4000x4000 | 4069 ms | 1199 ms |

The plan predicted "it will close" at under 5 ms; it stands at 46 ms after
the linear-time selection the estimate assumed, nine times over the bar.
The bar was set from the multicore tier's `compensatedSum` gate, a kernel
that touches each element once; a polish touches each element twice per
sweep and selects a median per line, and the estimate never priced that.
**Ruling: the acceleration question is CLOSED anyway, by judgement rather
than by the bar** -- 46 ms for a million cells and 1.2 s for sixteen
million is exploration speed, the multicore tier admits kernels only on a
measured 1.5x, and nothing in TK1-TK6 needs a table that large in a frame.
The number is recorded so the ruling can be argued with.

**Also fixed in passing, as the plan foresaw for TK1**: nothing yet --
`stz_stats_moving_average`'s uncompensated sum (`stats.zig:602`) is noted
and left for TK1's smoother work, which waits for an R oracle (below).

**What TK1 will not ship without an oracle**: the smoother family (3, 3R,
SS, H, 4253H, twicing). R's `smooth()` is the plan's oracle and R is not on
this machine; NumPy has no smoothers. Under TK1's own kill criterion they
wait; a request for R outputs on a fixed input goes to the author with the
TK1 memo. The resistant line's published example (Tukey's three-group line)
is not at hand either: it is pinned by construction (an exact line
recovered to 1e-9, one point dragged to 1e6 leaving the slope at 3) and by
the NumPy route, and that is said here rather than dressed as the book.

---

## TK1 RESULTS -- the resistant core, 2026-09-26 (plane stzlib-math, M4)

**Shipped in the engine** (`engine/src/eda.zig`, in the `stz_stats` DLL
beside `stats.zig`): `hingeDepth`, `fourths`, `fourthSpread`,
`percentileQuartiles`, `fences(mult, convention)`, `letterValues`,
`trimean`, `mad`, `biweightMidvariance(c)`, `medianPolish2D` (R's
`medpolish` exactly, quickselect medians), `resistantLine` (Tukey's
three-group line with residual passes), `selectKth` / `medianSelect`.
Nine bridge calls in `ring_bridge_stats.zig` (`stzenginetukey*`), each
building a fresh Ring list of whole items -- no fixed buffer, so nothing
truncates (the graph plane's list-return lesson).

**Shipped as faces** (`base/math/stzTukey.ring`, loaded by `stzBase`):
`stzTukeySummary` (fourths, percentile quartiles, hinges under the
convention in force, fourth-spread, fences at any multiplier, `Outside()`
and `FarOut()`, the letter-value ladder with its letters, trimean, MAD,
biweight; `Why()` names the convention), `stzTukeyFit` (two-way: `Polish`,
`Common`, `Effects(:Row|:Col)`, `Residuals`, `Fitted`, `Check` = the
largest |data - (fit + residual)|, `ResidualScale`, `Sweeps`,
`IsConverged`; R's eps and cap as defaults, settable), `stzTukeyOneWay`
(group medians, the common as their median, effects and residuals, the
same `Check`), `stzTukeyLine` (`Fit(passes)`, `Slope`, `Intercept`,
`Residuals`). 1-based and named at the face, 0-based and numeric at the
seam, said in the file.

**The gate** `base/test/math/tukey_narrated.ring`, 52 of 52, in eight
sections: fourths against quartiles at every n mod 4 by hand and the
convention printed; the ladder on nine values; the fences under both
conventions with stzDataSet agreeing on its own; R's `medpolish` example
to 1e-9 with Data = Fit + Residual over every cell, one cell dragged to
1e9 moving the resistant effects by 2 (within the data's fourth-spread of
9) while the mean-based effects move by 266,666,666; the one-way fit; the
resistant line recovering an exact line and holding its slope at 3 when
the last point goes to 1e6 while least squares answers 66,668; MAD staying
at 2 and the biweight within a factor of two under a value at 1e9 while
the standard deviation answers 333,333,332; and the cost printed (a
100 x 100 polish through the seam in about 8 ms against 1 ms in the
engine alone -- the list crossing is the tax).

**Two claims the gate corrected in this author, both worth the plan's
own words**: the resistance bar is one fourth-spread OF THE DATA, not of
the residuals (a residual scale of 1 would have failed a fit that moved
by exactly the wild row's median shift); and a negative sibling that drags
the point at the centre of x cannot fail, because that point has no
leverage on any slope -- the wild point must sit at an end.

**Waiting for an oracle (TK1's own kill criterion)**: the smoother family
(3, 3R, SS, H, 4253H, twicing) and the N-way polish. R is not on this
machine; the request for R's `smooth()` outputs on a fixed input is routed
to the author as `MATH-R-ORACLE-01`, and the gate prints the family as
skipped by name on every run. The uncompensated sum in
`stz_stats_moving_average` (`stats.zig:602`) waits with them, since the
smoother work is what touches that neighbourhood.

**Build note for a fresh worktree**: `stz_http` and `stz_reactor` do not
build without `vendor/nghttp2/lib/includes/nghttp2/nghttp2ver.h`, a
generated file git ignores; copied from `_wtv`. `stz_stats` built without
it, which is why TK1 could land.

---

## TK1 RESULTS, second half -- the smoothers against R 4.5.1, 2026-09-26 (plane stzlib-math; MATH-R-ORACLE-01 closed)

**The oracle arrived.** R was at `D:\R\R-4.5.1` all along; the author said
so when asked why the block was still open. `base/test/math/oracle/r_smooth.R`
runs `stats::smooth` on R's own `?smooth` example, a ramp with a wild 100, the
`presidents` series (NAs as 0, n = 120) and forty seeded integer series of 7
to 30 values with ties and plateaus -- six kinds, both end rules, twicing --
and its transcript `r_smooth.txt` (651 lines, R's version string on the first)
is the gate's oracle. Nothing in it was computed by this library.

**Shipped**: the 3-family in `eda.zig` -- `3`, `3R`, `S`, `3RSS`, `3RS3R`,
`3RSR`, the end rules copy and Tukey, R's `do.ends`, twicing as R's
`twiceit` -- transcribed from `src/library/stats/src/smooth.c` line for
line, R's quirks included (`sm_split3` ASSIGNS its change flag; `3RSR`
subtracts the smooth from the input between rounds); four bridge calls;
`stzTukeySmoother` in `base/math/stzTukey.ring` (`Smooth(kind)`, the six
named forms, `Twice`, `Rough`, `SetEndRule`, `SetSplitEnds`, `Hanning`,
`Smooth4253H`, `Smooth4253HTwice`, `WindowMedians`, `Why`).

**Against R, exactly**: 72 of 72 on the three fixed series and 520 of 520
on the sweep (`tukey_narrated.ring` section 10, 115 of 115 in all). The
first run gave 60 of 72 and 491 of 520, every miss a 3RS kind under the copy
end rule, and the cause was in R's own R code, not its C: `smooth.R` says
`if (startsWith(kind, "3RS") && !do.ends) iend <- -iend` and `Rsm` reads
the ends-splitting switch as `iend < 0` -- so for the 3RS kinds R splits the
ends when `do.ends` is FALSE and leaves them when it is TRUE, while `S`
takes `do.ends` as written. Reproduced, and named in `eda.zig`, because the
oracle is what R does, not what its argument is called. Under the Tukey
end rule the inversion never showed on 296 cases; the copy rule exposed it
on 41. A transcription checked against one end rule would have shipped it.

**What R does not verify, said by name**: R's `smooth` covers only the
3-family. Hanning and 4253H are this plane's, with the ends COPIED at every
stage; their windows are checked against R per window (`median()` on every
window of 4 and 2, `runmed` interiors of 3 and 5, `filter(c(.25,.5,.25))`
interior), and their end treatment is this plane's, not Velleman and
Hoaglin's, whose worked series is not at hand. Two mechanism checks stand
in: 4253H keeps a straight line exactly, and a spike of 100 on a line of
slope 2 leaks through the even-span medians by 1.38 (an even median
averages its two middle values; the plan's "removes the spike" was a
guess and the measurement replaced it), where 3RS3R answers with the
neighbour, 25 for 23, and Hanning alone leaves 50. Below four values R
reads memory it never set (the Tukey end rule at n = 3 uses y[2] before it
exists), so the face refuses n < 4 rather than imitate it.

**Not built**: the N-way polish (no oracle in R -- `medpolish` is 2-D -- and
no published table at hand); change-point detection over the rough (the
plan demotes it to a verdict with a stated threshold, and no threshold has
been measured). `tukey_narrated.ring` prints "skipped: none" now: every
gate it owns runs.

## TK2 RESULTS -- re-expression, measured, 2026-09-26 (plane stzlib-math, M4)

**Shipped in the engine** (`eda.zig`): `leastSquares`, `spreadLevel`
(log fourth-spread on log median through the resistant line, the two-point
slope for two groups, least squares when the outer groups share an x;
never a guess on a non-positive value), `comparisonValues` (c_ij = row_i
col_j / common), `nonAdditivitySlope` (residuals on comparison values,
least squares, power = 1 - slope), `evaluateLadder` (every rung -1, -0.5,
0, 0.5, 1, 2 applied, polished with R's rule, scored by the slope and the
residuals' fourth-spread, all in one call; a rung a value cannot take is
returned as not ok rather than skipped silently), `recommend` and the
constant `RECOMMEND_THRESHOLD = 0.5`. Four bridge calls
(`stzenginetukeyspreadlevel`, `stzenginetukeyladder`,
`stzenginetukeynonadditivity`, `stzenginetukeythreshold`).

**Shipped as faces**: `stzTukeyReexpression` (`Ladder()` in one crossing,
`Rung(power)`, `NonAdditivity()`, `Recommend()` as a verdict carrying its
slope and the threshold it was judged by, `Diagnostics(subject)` in the
house rule shape for `stzRuleReport`, `Why()`), `StzTukeySpreadLevel(groups)`.

**The threshold, measured before it was used (the kill criterion)**: over
twenty additive 6 x 5 tables with seeded noise the |slope| at power 1
never exceeded 0.1944; over twenty multiplicative ones (the exponential of
an additive table) it never fell below 0.8781. The constant sits at 0.5,
between them with margin on both sides, and the recommender fired on 0 of
the 20 additive tables. So it ships as a recommendation, not as a slope
only. Both distributions are printed by `zig test` on every run.

**The gate** (`tukey_narrated.ring`, section 6b, 63 of 63 in all): the
multiplicative table's slope at power 1 near 1 and the log recommended
with its evidence; the additive table given NO recommendation and no
finding -- the negative that matters more; spread versus level built from
a known power (spread doubling with the level: slope 1, power 0; constant
spread: slope 0, power 1; a zero spread: not ok).

**Not shipped**: nothing of TK2's list. The spread-versus-level slope
runs the resistant line over as few as three groups, which is thin; the
plan's own words are "measured, never eyeballed" and the number is
reported with its evidence either way.

---

## TK3 RESULTS, first half -- the box plot's convention, the stem-and-leaf, two tables, 2026-09-26 (plane stzlib-math, M4)

Every Tukey picture is a figure of M1 (the math plane's charter, decision
7), so TK3's displays are figure KINDS of `StzMathFigureQ`, judged by their
own rules, with a text rendition where the display is text by nature.

**The box plot names its hinge convention.** `:BoxPlot` gained
`:convention = :Percentile | :Fourths`. The default stays percentile
quartiles -- what the figure shipped with in M1 and what `stzDataSet`
uses, so the M1 gate and the data set keep agreeing -- and `:Fourths`
takes the hinges, the fourth-spread, the fences and the outliers from
`eda.zig`. `Why()` says "under Tukey's fourths" or "under percentile
quartiles"; `Text()` ends with the hinges' convention and the fence rule.
On the library's eight values the upper hinge reads 10.5 against 9.75 and
the upper fence 20.25 against 18.375, while the median, the whisker at 12
and the one outlier are the same under both. `stzDataSet.BoxPlotStats()`
is NOT delegated to the engine here: that file is the stats plane's, so
the delegation is routed as `MATH-BOXPLOT-DELEGATE-01` rather than made.

**The stem-and-leaf** (`base/math/stzStemPlotFigure.ring`, kind
`:StemPlot`, keys `:of`, `:unit`, `:lines`, `:label`): stems as rows,
leaves sorted on each row, the leaf unit chosen from the range as the
power of ten giving 5 to 20 stems or given as a power of ten, one or two
rows a stem (Tukey's * and .), empty stems shown, a legend saying what a
row means in the data's own units. Nothing is solved. Three rules judge
the picture -- `leaves_count_the_values`, `leaves_are_sorted`,
`stems_are_consecutive` -- and the gate's witness, a row whose count is
tampered, is convicted by two of them by name. Negative values are
refused by name (Tukey's -0 stem is not printed in this slice) and so is a
unit that is not a power of ten or a display of more than forty rows.
`Text()` prints the rows and the legend.

**Two tables**: `stzTukeySummary.LetterValueTable(levels)` (letter, depth,
lower, mid, upper, spread, with Tukey's depth rule under it) and
`stzTukeyReexpression.LadderTable()` (power, its name, slope, residual
scale, the recommended rung starred, the evidence under it).

**Looked at**: catalogue scenes 30-32 (`fig_30..32.png`, light and dark)
were opened and read before this section was written -- the fourths box
plot with its numbers, the seventeen-value stem-and-leaf, the two-rows-a-
stem display with its empty rows.

**Gate**: `math_narrated.ring` sections 16 and 17, 240 of 240 in all.

**Still to come in TK3**: residual-versus-fit and the coded two-way table
with its legend (the second half).

## TK3 RESULTS, second half -- residual versus fit, the coded table, and a defect the checksum found, 2026-09-26 (plane stzlib-math, M4)

**Residual versus fit** (`base/math/stzResidualPlotFigure.ring`, kind
`:ResidualPlot`, keys `:of`, `:names`, `:label`): one polish through
`eda.zig`, then every cell as a point whose x is its FITTED value (common
+ row effect + column effect) and whose y is its residual; the zero line;
bands at plus and minus one and two residual fourth-spreads; a cell two
or more spreads out is coloured, three or more is coloured and NAMED on
the picture ("75-199, 1974"). Nothing is solved -- every point sits where
its two numbers put it. Two rules judge it. `point_is_its_cell` recomputes
each point's fit from the effects the picture carries, recomputes its
pixel place from the frame's scale, and checks the ring index (below).
`bands_are_the_scale` recomputes the fourth-spread FROM THE POINTS and
checks each band's multiple against it. The gate's witnesses: a tampered
fit, a ring drawn as a dot, a tampered scale, a band moved off its
multiple -- each convicted by name, and each message says the number it
should have been.

**Coincident cells are rings, never a dot over a dot.** R's deaths table
has column effects 0, -1, 0, so a row whose 1973 and 1975 residuals agree
puts two cells on ONE spot -- three times in fifteen cells. The generic
`dot_above_figure` rule of M1 convicted the first draft for exactly that:
the later dot hid the earlier one. The k-th cell on a spot is now an
UNFILLED ring of radius 6.5 + 4k around the first, so every cell stays
visible at its own numbers, and a shape without a fill is not a region
for the dot rule. Integer tables coincide often; this is the case, not an
edge.

**The coded table** (`base/math/stzCodedTableFigure.ring`, kind
`:CodedTable`, keys `:of`, `:names`, `:glyphs`, `:label`): the plan's 2.5
bands, fixed -- |r| / scale below 0.5 at the fit, below 1 mild, below 2
notable, below 3 outside, 3 and above far out -- with the ASCII glyphs
`.`, `-`/`+`, `<`/`>`, `v`/`^`, `*` by default and the plan's dot,
circles, triangles and diamond under `:Symbols`. Glyph SETS swap; the
meaning of a band never does, and the gate pins that the far-out cell
keeps band 4 under either set. The legend is printed on the picture and in
`Text()` with the scale, the common value and the hinge convention, or
the table is a lie -- `legend_is_printed` says so when it is cut short.
`glyph_is_its_band` recomputes every cell's band and sign; `cells_tile_the_
table` counts. On the deaths table: 9 at the fit, 3 outside, 3 far out.
On a multiplicative 6 x 5 table fitted additively (scene 35) the bow shows
as a band pattern with the two far-out cells in the last row's corner --
the picture that says "re-express" before the ladder is run.

**A defect the checksum found, not the eye.** The catalogue rendered every
scene twice, "light and dark", since M1 -- and every `dark_NN.png` was
byte-identical to its `fig_NN.png`, all 32 of them, because
`stzMathFigure.Diagram()` hands back a COPY (Ring copies an object a method
returns) and the catalogue set the theme on the copy. The first-half
results above say the dark pictures "were opened and read"; they were,
and they were light, and the reader did not notice because nothing was
compared. Fixed by `stzMathFigure.SetTheme(theme)` on the figure's own
picture, pinned in the gate both ways (through `SetTheme` the SVG changes;
through `Diagram()` it does not), the catalogue re-rendered: 35 dark
pictures now differ from their light twins and the 32 light ones are
byte-unchanged.

**Looked at**: `fig_33..35.png` and `dark_33..35.png`, this time with the
checksums beside the eye.

**Gate**: `math_narrated.ring` sections 18 and 19, 280 of 280 in all; the
probe that grew them is `base/test/math/probe_tk3.ring`.

**TK3 is complete**: box plot (two conventions), stem-and-leaf, residual
versus fit, coded table, two printed tables. Not built: the spread-versus-
level and comparison-value diagnostic PICTURES (their numbers are in
`stzTukeyReexpression` and print as `LadderTable`); back-to-back stems; the
notched box. Each is a kind or a key away and none is owed by the plan's
done-when.

## TK4 RESULTS -- the verdicts, with their thresholds measured first, 2026-09-26 (plane stzlib-math, M4d)

**One meaning of "far out".** Before the verdicts, the residual plot of
TK3 coloured a cell by |residual| / scale (2 and 3), while the summary used
Tukey's fences (hinge -+ 1.5 and 3 fourth-spreads). Two instruments, two
counts: the deaths table had three "far out" cells under one and two under
the other (residual 3 lies inside the upper far-out fence 1 + 3 = 4). The
tier now has ONE rule, Tukey's fences on the batch in hand -- the summary,
the box plot, the residual plot (which draws the four fences) and the
fit's verdict all use it -- and the coded table keeps the plan's fixed
bands of 2.5 as a DISPLAY, named as such in its legend. The gates were
recounted: four cells outside, two far out, two named on the picture.

**The verdicts**, every one in the house shape and every message naming
the measurement and the threshold it crossed:

| face | rule | severity | fires when |
|---|---|---|---|
| `stzTukeySummary` | `far_out` | error | a value lies beyond hinge -+ 3 fourth-spreads; the message says how many spreads past the hinge |
| `stzTukeySummary` | `skewed` | warning | the mean drift of the F, E and D mid-summaries from the median, over the fourth-spread, exceeds 0.25 in magnitude |
| `stzTukeySummary` | `heavy_tailed` | warning | the sixteenth-spread over the fourth-spread, against the Gaussian's 2.2745, exceeds 1.2 |
| `stzTukeyFit` | `far_out` | error | a cell's residual lies beyond the residual batch's far-out fences; on a batch whose fourth-spread is 0, any residual at all |
| `stzTukeyFit` | `not_converged` | warning | the polish stopped at its cap |
| `stzTukeyOneWay` | `spread_tracks_level` | warning | the slope of log spread on log level exceeds 0.5 in magnitude; the message names the power to try |
| `stzTukeyReexpression` | `non_additive` | warning | TK2's recommendation fires |

`StzTukeyReportQ(subject, [ faces ])` builds the one `stzRuleReport` over
any faces answering `Diagnostics(subject)`; `IsSound()` is false on an
error and true on warnings alone. A shape verdict is not made under 100
values: it was not measured there, and `Shape()` says "unjudged" by name.

**The thresholds were measured before any face used them**
(`base/test/math/probe_tk4.ring`, seeded Park-Miller batches, 20 per class
and size, the numbers also in `stzTukey.ring` above the thresholds):

| statistic | null classes, max over 60 or 40 batches | positive classes, min | threshold | fires |
|---|---|---|---|---|
| skew, single F-level mid-summary (Tukey's first idea) | symmetric up to 0.2562 at n = 50 | skewed down to -0.0855 | none possible | the classes OVERLAP at n = 50 and 200 |
| skew, mean drift of F, E, D mids | 0.2313 / 0.2058 / 0.1408 at n = 100 / 200 / 400 (normal, uniform, t2) | exponential 0.2366 / 0.2439 / 0.2510; lognormal 0.2894 / 0.3863 / 0.4245 | 0.25 | 0 of 180 symmetric; 40 of 40 lognormal; 40 of 40 exponential at n >= 200, fewer at 100 |
| tail, E-spread over F-spread | normal up to 1.1127 at n = 200 | t2 down to 0.9977 | none clean | overlaps |
| tail, D-spread over F-spread | 1.1595 / 1.1871 / 1.1290 (normal, uniform) | Cauchy 1.1690 / 1.4613 / 1.6215; t2 1.0992 / 1.1057 / 1.1796 | 1.2 | 0 of 120 light-tailed; 40 of 40 Cauchy at n >= 200; t2 only partly (17, 18, 20 of 20 clear the null maximum) |
| spread versus level, five groups of 30 | constant spread: |slope| up to 0.3397 | proportional spread: 0.6689 and up | 0.5 | 0 of 20 constant, 20 of 20 proportional |

The evidence of skew is the DRIFT across letters, as Tukey read the
ladder; the single mid-summary he started from does not separate an
exponential from a normal batch at these sizes. Both facts are in the
table so the thresholds can be argued rather than believed.

**Both directions, in the gate** (`tukey_narrated.ring` section 8): an
exactly additive table is sound with no finding; the same table with one
cell at +1000 is unsound with one error at that cell -- and because every
other residual is exactly 0, the fences collapse onto the hinge and the
message says so; repaired, it is sound again. The additive table with
seeded noise of section 6b carries ONE far-out error (cell (6, 3), residual
-0.0871, 3.92 spreads past a hinge on a spread of 0.02): the rule reads
the batch it is given, and the plan's example was less clean than the plan
assumed. A multiplicative table fitted additively is unsound twice over --
one corner past the far-out fence and the re-expression's warning. Eight
marks with a 40 give one error at value #8, 4.54 spreads past the hinge;
with 25 in its place, no finding. Lognormal leans right, normal leans
neither and is not heavy, Cauchy is heavy, fifty values are unjudged.

### TK4 addendum -- the change point, a verdict with a measured threshold, 2026-09-26

Row 9 of the disposition demoted change-point detection to "a verdict with
a stated threshold, not a claim". The threshold was measured before the
verdict existed (`base/test/math/probe_changepoint.ring`, seeded series of
40 and 100 values, 20 per class). The statistic that separates the classes:
the largest contrast between the medians of the ten values before a cut and
the ten after it, over the fourth-spread of the consecutive differences --
a scale blind to a level and to a trend, and resistant to the one large
difference a step makes. The first statistic tried, the largest step of the
3RS3R smooth over the rough's fourth-spread, did NOT separate anything (a
level with noise up to 4.3, a five-sigma step down to 1.97): a median smooth
of noise is a staircase, and its steps are as large as a real one.

| class, n = 40 / 100 | contrast, min .. max | fires at 1.8 | located within two of the cut |
|---|---|---|---|
| a level with noise | 0.16 .. 1.13 / 0.43 .. 0.90 | 0 / 0 of 20 | -- |
| a trend of 0.1 sigma per point | 0.63 .. 1.50 / 0.96 .. 1.61 | 0 / 0 of 20 | -- |
| a step of 2 sigma | 0.64 .. 2.26 / 0.78 .. 1.93 | 1 / 1 of 20 | 13 / 16 of 20 |
| a step of 3 sigma | 1.20 .. 3.70 / 1.13 .. 2.49 | 5 / 7 of 20 | 17 / 17 of 20 |
| a step of 5 sigma | 1.62 .. 4.86 / 2.16 .. 3.38 | 19 / 20 of 20 | 15 / 19 of 20 |

`stzTukeySmoother.ChangePoint()` answers the contrast, its index, the scale,
the threshold and whether it fires; `Diagnostics(subject)` turns a firing
into a `level_shift` warning at that index, naming the contrast and the
threshold; under 40 values the verdict is not made, by name, and a flat
series with one jump says its differences have no spread to scale by. The
gate (`tukey_narrated.ring` section 11, 124 of 124 in all) fires on 20 of 20
five-sigma steps at n = 100 with its own seeds, locates 17 within two, and
fires on 0 of 40 null series. A three-sigma step is found only sometimes,
and the table says so; a trend steeper than 0.1 sigma per point was not
measured and the verdict does not claim it.

## TK6 RESULTS, the memory half -- the kill criterion fired; the memory does not ship, 2026-09-26

The clause: `stzAgentMemory` recording which re-expressions worked on which
data shapes ships only if, on held-out tables, its suggestion beats the
fixed policy "evaluate the whole ladder and take the best slope". Run as an
experiment before any product code (`base/test/math/probe_tk6_memory.ring`):
forty training tables and twenty held-out, each a 6 x 5 additive table with
seeded noise undone by a known power of the ladder; the memory keyed on the
one-number shape the fixed policy reads first (the non-additivity slope at
power 1) and suggested the power of the nearest remembered shape.

| measure | memory | fixed ladder |
|---|---|---|
| suggests the ladder's own best power | 19 of 20 | -- (it is the ladder) |
| recovers the generating power | 17 of 20 | 17 of 20 |
| regret in |slope| against the ladder's best | mean 0.026, worst 0.52 | 0 |
| cost on 6 x 5 | one polish through the face, 2.33 ms | the whole ladder, one engine crossing, 0.15 ms |
| cost on 60 x 50 | 2.34 ms | 2.08 ms |
| cost on 200 x 100 | 16.5 ms | 12.1 ms |

**Why it does not ship.** On quality the memory can only tie the ladder,
because the ladder evaluates every rung on the table in hand and the memory
guesses one from tables it saw before; it tied on 19 of 20 and lost 0.52 of
slope on the twentieth. On cost it saves nothing: the ladder runs its six
rungs in one engine crossing and costs LESS than the single polish the
memory would replace, at every size tried -- the face's single polish pays
the seam once, and the ladder pays it once too. The plan wrote "it may well
[lose], because the ladder is cheap"; measured, the ladder is cheaper than
the memory's one step. TK6's memory half is closed with this table; its
panel half stays gated on GUI G5.

## TK5 RESULTS -- the story, under the honesty law, 2026-09-26 (plane stzlib-math, M4d)

`stzTukeyStory` (`base/math/stzTukeyStory.ring`) tells a fit and its
report in four paragraphs -- the fit, the extreme effects, the findings
retold verbatim, the verdict -- and PERFORMS NO ARITHMETIC: every number
in the prose is read from the fit's accessors or from a finding's message.
The honesty law of 2.6 is checked on the story itself: `Numerals()` are the
numeral tokens of `Text()`, `SourceNumerals()` the tokens the fit and the
findings carry (formatted the one way the prose formats them), and
`Unsourced()` is the difference -- empty, or the story's `Why()` says
which numeral no source carries. On the deaths table: 4 paragraphs, 37
numerals, every one sourced. The story is told on `stzTranscript` (the
class `stzNarration` became at DN9a, so the plan's "on stzNarration"
resolves there): the paragraphs as system lines, the verdict as a verdict
line at certainty 1, because nothing was guessed.

**The LLM face does not ship.** The plan's kill criterion says the LLM
path does not ship if templated prose reads well enough in the author's
judgement; this plane's judgement is that it does, and the honesty guard
the plan wrote for the LLM face (identical numerals with the face on and
off) is met trivially by a deterministic story that is the same text told
twice, which the gate asserts. If the author rules otherwise, the seam is
one method: a phrasing pass over `Paragraphs()` whose output must pass
`Unsourced()` empty.

**Found on the way, paid for once**: `_ac_` and `_aC_` are ONE variable
in Ring (case-insensitive), so a loop bounded by the column effects and
appending to an accumulator of the other spelling appended to its own
bound -- a hang inside a method call that took six probes to bisect. The
trap is in the repository's memory; two locals are never told apart by
case alone.

**Gate**: `tukey_narrated.ring` sections 8 and 9, 95 of 95 in all.
