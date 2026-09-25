# stzlib-math -- the charter (M0)

Plane `stzlib-math`. Folder `libraries/stzlib/base/math/`. Task `COMPASS-MATH-PLANE-01`.

**Status: DRAFT for the author's ratification.** Written 2026-09-25 against
`origin/main` a94ba2920, in the worktree `D:\GitHub\_wtm` on branch `math/m0`.
No code is written before the author ratifies this file. The companion,
`SOFTANZA_MATH_PLAN.md`, carries the map of what exists (with line numbers),
the contracts this plane consumes, the phases with their done-whens, and the
demo bar. This file carries what is decided and what is asked.

Naming ruling, author, 2026-09-25: every identifier and path says `math`
(`stzlib-math`, `base/math/`, `base/test/math/`, `courses/math/`,
`mailbox/stzlib-math.md`); the full word `mathematics` is for prose only.

---

## 0. The sentence

Mathematics in Softanza is **seen first, proven always, and learned in the
learner's own language** -- by a child, a student, a professional and a
researcher, and by every institution -- on one engine, with no dependency but
Softanza itself.

## 1. What Softanza owns, and what it concedes

**Softanza owns constructive, exact, visual and verified mathematics**: the
mathematics a learner does with numbers, pictures and checks, and the
mathematics a business does with money that must not lose a centime.

Four things already in the tree are the proof that this is the right ground,
and none of them has a peer that does the same:

- **a number that says why it is not exact** -- `IsExact`, `WhyNotExact`,
  `Representation` and the three regimes (`stzNumber.ring:173-191, 4701-4746`);
- **a decomposition judged by an oracle with a derived tolerance** -- NumPy and
  exact rationals, `kappa(A) * eps`, never a literal
  (`base/test/number/numeric_reference_oracle_narrated.ring:27-36`);
- **a picture that is declared and solved, not drawn** -- `stzMathDiagram`,
  a domain, a substance and a style, solved by the engine's own autodiff tape
  and L-BFGS (`base/graph/stzMathDiagram.ring:26-32`);
- **a rigour written as law** -- "an identity cannot be mistyped into
  agreement" (`SOFTANZA_NUMERIC_FOUNDATION.md:1275-1277`), "an identity is not
  a self-check" (`base/culture/SOFTANZA_CULTURE_PLAN.md:186-188`), "the
  Jacobian adjudicates them, and the round trip does not"
  (`SOFTANZA_GRAPHICS_PLAN.md:1207-1217`).

**Softanza concedes symbolic mathematics**, in writing, to Wolfram
(`D:\GitHub\stznarrations\POSITIONING.md:21`), and the concession is right.
This plane builds no computer algebra system, no solver over symbols, and no
TeX engine. Julia shows that symbolic and numeric can share one type system;
that is a fact about Julia's ambition, not a reason to reopen a written
concession.

**Refused on licence, already decided**: GMP and MPFR
(`SOFTANZA_NUMERIC_FOUNDATION.md:802`), FFTW (`:813`); BLAS is not vendored by
default because the engine's kernels are measured (`SOFTANZA_COMPUTE_MODEL.md`).
The exact tower was rebuilt in Zig instead. This plane inherits those
refusals and does not re-argue them.

## 2. What this plane adds

The compass measured twenty lanes: the compute core is profound and the
adjectives the author asked for are the ones missing. This plane supplies
them, in this order:

| owed | what it is | phase |
|---|---|---|
| **visual-first** | a `y = f(x)` figure with parametric and polar forms, a true surface, the complex plane, a box plot, a number line, a fraction picture, a matrix picture; notation grown toward fractions, roots, sums and matrices | M1 |
| **motion** | a declared parameter that re-solves a figure; a declared sequence of states the window loop plays; export as a narration whose frames are real | M2 |
| **educational** | the mathematics course of the education program, picture-first, en/fr/ar/ha, every exercise a promise, the tutor exercised on every chapter, a bank overlay and a school world | M3 |
| **exploratory** | the Tukey tier, TK0-TK6 as the plan of record wrote them, every picture a figure of M1 | M4 |
| **profound, further** | requests to the owning planes, each with its oracle and its picture: RK45, forward-mode AD, bootstrap, a Bayesian door, hull and Delaunay, permutations and truth tables, Poisson and binomial, the branch-cut policy, and the Julia question -- decompositions generic over the exact tower | M5 |
| **frontier** | a door to formal proof: a lesson's identities exported as Lean 4 statements, checked there, the verdict carried back as a guard | M6 |

## 3. The vocabulary

LAW 1 of the intelligence architecture applies
(`SOFTANZA_INTELLIGENCE_ARCHITECTURE.md:180-184`): a domain is a folder, an
entry object and a data format. The folder is `base/math/`. The proposal:

| term | what it is | entry object | lives in |
|---|---|---|---|
| **Figure** | a declared mathematical picture: a kind, its data, its annotations; solved by the diagram engine, drawn by `stzCanvas` | `stzMathFigure` | `base/math/stzMathFigure.ring`, one file per kind beside it |
| **Motion** | a figure with declared parameters (sliders) or a declared sequence of states (a proof, a construction); played by the window loop, exported as a storyboard and a `.narration` | `stzMathMotion` | `base/math/stzMathMotion.ring` |
| **Claim** | a mathematical statement with its check: an identity, an inequality, a numeric equality with a derived tolerance, an exactness assertion; every claim answers `Holds()` and `Why()` and is refused when it has no check | `stzMathClaim` | `base/math/stzMathClaim.ring` |
| **Lesson** | a chapter of the mathematics course; not a new class -- it is the education plane's `stzChapter`, and every numeric claim in it is a `#-->` promise the checker runs | consumed | `base/education/program/courses/math/` |
| **Notation** | the `$...$` label language of DN10, today 72 names (`stzMathDiagram.ring:1263-1289`), grown toward fractions, roots, sums and matrices without becoming TeX | consumed today; see decision 6 | `base/graph/stzMathDiagram.ring` |

**The format is `.zfig`**: one figure, its data, its parameters and its
states, as plain text, loadable and diffable, four letters under the family
rule (`SOFTANZA_INTELLIGENCE_ARCHITECTURE.md:65-68`). The name is free on
`main` (checked 2026-09-25). A motion is a `.zfig` with a `params` or a
`states` section, so there is one format, not two.

**A figure is declared, computed, then solved.** The diagram engine solves
at most 256 tape variables (`engine/src/autodiff.zig:38`), and a curve of
four hundred samples is not four hundred unknowns. So a figure has two halves:
the **computed** half -- the samples of `f`, the cells of a matrix, the
fourths of a box plot -- comes from the engine as data, the way the dots,
timeline and choropleth domains mint no unknowns
(`stzMathDiagram.ring:7759`); the **solved** half -- labels, callouts, the
tangent that must not cross the curve, the fraction's parts that must tile the
whole -- is what the solver places. A learner edits the declaration, never a
pixel; and the split is what lets a slider move the computed half at frame
rate while the solved half re-solves within the budget the graph plane
already set (100 ms, `SOFTANZA_GRAPH_PLANE_PLAN.md:2755`).

**How a figure kind enters the tree**: exactly as the last seven domains did
(`stzBase.ring:362-379`) -- its own file, a domain built with
`AddType`/`AddPredicate`, a style built with `ForAll` rows, a builder that
turns data into a substance, a rule set registered with
`StzRegisterMathRuleSet` (`stzMathDiagram.ring:123`), a guard section and
catalogue scenes. A new shape kind, layout function or computed function means
editing the core file, which the graphics plane owns, and is therefore a
routed request, never a local edit.

A declaration, as this plane intends it to read:

```ring
oF = StzMathFigureQ(:Function, [
	:f     = "sin(x) / x",
	:on    = [ -12, 12 ],
	:mark  = [ :zeros, :extrema ],
	:label = "$f(x) = sin(x) / x$"
])
oF.Show()                # solved, then drawn; ToSVG() needs no GPU
oF.Why()                 # "computed 400 samples; solved 9 labels in 2 rounds"

oM = StzMathMotionQ(oF).Param("a", 0.5, 3, :step = 0.1)   # y = sin(a x) / x
oM.Play(oWindow)          # the curve at frame rate, labels within 100 ms
oM.ExportTo("sinc/")      # a storyboard whose frames are the live ones

oC = StzMathClaimQ("(9007199254740992 + 1) = 9007199254740992")
oC.In(:f64).Holds()       #--> TRUE   and Why() says the digit that was lost
oC.In(:exact).Holds()     #--> FALSE  the tower keeps the 1
```

## 4. The laws

Non-negotiable, and each one names the fact in the tree that makes it real.

1. **Visual-first, by law.** The picture comes before the symbol. Every
   object this plane adds can draw itself; every lesson opens with a figure.
   The render is the instrument: three geodesic defects were found by
   looking and none by numbers (`SOFTANZA_GRAPHICS_PLAN.md:1361-1363, 2319`).
   A figure that has not been looked at is not done.
2. **Exact where it can be, honest where it cannot.** Use the tower. A result
   that became approximate says why (`WhyNotExact`, `stzNumber.ring:4743`).
   Money keeps two places with banker's rounding, always
   (`_pvtApplyRegime`, `:4618-4627`). Nothing downgrades exactness silently.
3. **Every claim carries its check.** A lesson's numeric claim is a `#-->`
   promise checked by running. An identity is asserted the way the numeric
   guards assert it: against an oracle, with a derived tolerance, and with
   the counter-law in mind -- *an identity is not a self-check*. Every
   positive has a negative sibling. Nothing is called proven without a guard.
4. **Declared, computed, then solved.** A figure is a declaration, never a
   drawing command; its data is computed by the engine; its annotations are
   solved. Section 3 says why the middle word is there.
5. **Motion is real.** A motion is a sequence of solved states the window
   loop plays; an export is a storyboard whose frames are the live ones, and
   a guard proves it (`ToPixels` of the live frame against the exported
   state, same renderer, two targets, `SOFTANZA_GRAPHICS_PLAN.md:3533`). No
   pre-baked frame, ever; and a frame the machine could not render is refused
   by name, never recorded as if it existed.
6. **The tutor asks.** The gap question, never the answer
   (`stzTutor.ring:15-18`). A language model may join only as an optional
   LAW-2 faculty; nothing requires one; and no model answers a mathematical
   exercise for the learner.
7. **Four languages from the first page**: English, French, Arabic
   (right-to-left, code kept left-to-right, numerals guarded with `<bdi>`,
   `stzEduReader.ring:39-69, 311-316`) and Hausa. A missing edition is a red
   guard, never English.
8. **Symbolic algebra is conceded.** No CAS, no solver over symbols, no TeX.
9. **Softanza is the only dependency.** No Python, no TeX, no plotting
   library, no external kernel. Lean, in M6, is a door with a zero-setup
   floor (the numeric guard) that sharpens when Lean is present and is never
   required -- the LAW-2 shape, applied to proof.
10. **Honest.** Never claim a picture is solved, a cell ran, a frame is real
    or a claim is proven unless a guard proves it; never count a gate as run
    that was not; name what was skipped.

## 5. Audiences, levels, and what "proven" means at each

The education program earns a level by one rule: every exercise of the
level's chapters passed and its project passed, each with evidence
(`stzLearner.HasEarned`). Chapter order encodes level, because
`ChaptersForLevel` takes the first N chapters of the course it is given
(`stzProgram.ring:404-415`). The mathematics course orders its chapters by
audience, and "proven" climbs a ladder with the audience:

| level | audience | what a claim must show to be proven |
|---|---|---|
| L0 | a child | the picture agrees with a count: three of four cells shaded, five ticks to the right of zero; the check counts |
| L1 | secondary | a `#-->` promise the checker runs, with a wrong answer that fails by running |
| L2 | university | a claim against an oracle with a derived tolerance, and its negative sibling; a decomposition judged by its residual, never by its own identity |
| L3 | professional | a regime that refuses: money never loses a centime, an exact number raises rather than rounds; the overlay court passes |
| L4 | researcher | the same statement exported to Lean 4, checked against Mathlib, its verdict a green guard that fails when the statement is false |

The first course covers L0 through L3 in fifteen chapters -- the child's
trio first (the number line, the fraction, the chaos game), because a picture
a child can read is the strongest test of visual-first -- and L4 is the door
M6 opens. See decision 3 for what the author must choose here.

## 6. Boundaries

**This plane owns** `base/math/`, `base/test/math/`, the mathematics course at
`base/education/program/courses/math/` (by agreement with `stzlib-education`,
asked through Central as `MATH-COURSEFOLDER-01`), the bank overlay's
attachment of mathematics exercises under `overlays/bank/courses/math/`
(same agreement), and the mathematics narrations and documents it writes.
It stages only those paths, by name.

**This plane consumes and does not own**: `number/`, `stats/`, `optim/`,
`graph/`, `geo/` and their engine files; `stzMathDiagram`, `stzPlotCanvas`,
`stzCanvas`, `stzScene`, `stzWindow`, `stzStoryboard` and `plot.zig`
(graphics); the education reader, checker, tutor, overlay court and demo
(education); `.narration` (stznarrations); the browser VM (ringscript).
A defect found in a consumed module is a finding, routed through
`mailbox/stzlib-math.md`, never a fix made here. The plan lists nineteen
such findings at the time of writing, three of them the ones the brief
named and sixteen found while reading.

**This plane never edits a sibling repository.**

## 7. The decisions only the author can make

Each row states what this plane will do if the author says nothing, so that
silence never stops work; a later ruling amends.

1. **The figure vocabulary.** `stzMathFigure`, `stzMathMotion`,
   `stzMathClaim`; the format `.zfig`; one file per figure kind under
   `base/math/`, loaded after `stzMathDiagram`. *Default: as written.*
2. **Generic-over-exact algebra** (Julia's idea). Two halves, both in scope:
   a teaching path in `base/math/` -- Gaussian elimination, LU and Cholesky
   written over `stzNumber` so that a 4x4 rational system solves exactly and
   the lesson can show every pivot as a fraction -- and a routed engine
   question to the number plane with the oracle already in the tree
   (`_gen_numpy_reference.py:24-46` solves with `Fraction`). *Default: the
   teaching path is M3's, the engine question is M5's request.*
3. **Audiences and levels.** The first course is L0-L3 in fifteen chapters,
   researcher (L4) through M6; the child's trio opens the course. *Default:
   as written.*
4. **What "proven" means at each level.** The ladder in section 5.
   *Default: as written.*
5. **The Lean bridge in year one.** M6 after M3, as an optional door under
   the LAW-2 shape; Lean is never a dependency of the library or of the
   course. The author decides whether Lean may be installed on the demo
   machine. *Default: M6 is planned for year one and gated on that answer.*
6. **Who owns notation.** The `$...$` table and its parser live in
   `stzMathDiagram.ring:1263-1446`, owned by graphics; growing it toward
   fractions, roots, sums and matrices means editing that file. Either
   graphics grows it on this plane's specification, or the table moves to
   `base/math/stzMathNotation.ring` and this plane owns it while the draw
   path stays in graphics. *Recommended: the move, because notation is
   mathematics and the draw path is not. Default until ruled: a routed
   specification to graphics.*
7. **Who owns the Tukey tier's numerics.** The plan of record puts fourths,
   letter values, median polish and the smoothers in a new `eda.zig` under
   the stats domain, and its pictures in `stats/` with a text renderer
   beside `plot.zig` (`SOFTANZA_TUKEY_PLAN.md:463-477, 495-500`). This charter
   makes every Tukey picture a figure of M1. Either this plane owns the tier
   end to end (`eda.zig` as a math-plane engine file, the pictures as
   figures) or stats builds TK0-TK2 on this plane's requests. *Recommended:
   end to end, because a fit and its residual picture split across two
   owners is the duplication the estate keeps paying for. Default until
   ruled: this plane writes TK0's spike as a probe and routes the split.*
8. **The 60 fps bar for a slider.** The measured warm re-solve of a dragged
   figure is 27 ms, and the first warm solve 296 ms
   (`SOFTANZA_GRAPH_PLANE_PLAN.md:2741-2772`); a 60 fps frame is 16.7 ms. Under
   law 4 the computed half moves at frame rate and the solved labels
   re-solve within the 100 ms drag budget. Either that is the bar, or the
   author wants everything at 60 fps, which is a request to graphics for a
   faster warm path. *Default: the split bar, stated in every M2 guard as
   two numbers.*

## 8. How this plane works

- **Worktree** `D:\GitHub\_wtm`, branch `math/m0` from `origin/main`. The
  stzlib tree is on `ringpp/migrate-rule-a` and is not touched. Note for
  every session: the local `main` ref in the stzlib tree is thirty-one
  commits behind `origin/main`, so `base/education/` is absent from every
  local `main` worktree; branch from `origin/main`.
- **Probe first, gate once.** Every figure is born as a standalone probe
  under `base/test/math/`, seconds per run; the plane's gate
  `math_narrated.ring` runs once per task, in the background, before the
  commit, and prints per-section wall time. A scoped run prints what it
  skipped by name. Owned and run are two figures, never summed.
- **Fast path**: one process, many assertions. Cold start is 2-3 s per
  process on this machine; the course gate's cost is child processes, and
  the mathematics course will name that cost in its own gate rather than
  inherit a budget it cannot meet (education missed 30 s by 1-9 s, all of
  it cold start).
- **One heavy job at a time.** An engine build is `-j2`; a corpus sweep is
  one process; never while another repository builds.
- **Stage by explicit path.** `base/math/`, `base/test/math/`,
  `courses/math/`, the load block in `stzBase.ring`, and nothing else.
- **Push both remotes and verify with `git ls-remote`**; a failed codeberg
  push is a spent single-use token, cleared and retried, never flagged
  pending.
- **Memos stamped from the clock**, filed in `softanza/memos/`; one cost line
  in `.central/cost.jsonl` at close, `closed` read from the clock in UTC
  immediately before the commit that carries it.
