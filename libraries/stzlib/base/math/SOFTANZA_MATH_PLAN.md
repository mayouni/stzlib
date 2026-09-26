# SOFTANZA MATH PLAN -- the map, the contracts, the phases

Plane `stzlib-math`, folder `libraries/stzlib/base/math/`, task
`COMPASS-MATH-PLANE-01`. Companion to `CHARTER.md`, which carries the vision,
the vocabulary, the laws and the decisions asked of the author.

**Status: DRAFT, M0.** Read against `origin/main` a94ba2920 on 2026-09-25.
Every `path:line` below was read on that commit; where a fact was inferred
rather than read, the sentence says so. Paths are relative to
`libraries/stzlib/` unless they start with a drive letter.

---

## 1. The map of what exists

The compass rated twenty lanes from `main` at 04cff1c34
(https://claude.ai/artifact/M5Chh8QA65Q8b8e1hQZ8uq). This section is the
plane's own reading, thirty-one commits later, of the entry objects it will
consume. It is longer than the compass because a consumer needs the method
names and the caps, not the ratings.

### 1.1 Numbers

| what | where | facts a consumer relies on |
|---|---|---|
| big integers | `engine/src/number.zig:17, 36-293` | `big.int.Managed`; `stz_bigint_*`; factorial at `:331` |
| scaled decimals | `base/number/stzNumber.ring` | strings, arithmetic on scaled integers through the engine (foundation `:895-902`) |
| rationals | `stzNumber.ring:2127, 2192` | `"p/q"` strings, reduced by `stz_bigint_gcd`; `Same()` cross-multiplies big integers (`:4755`) |
| complex | `engine/src/complex.zig`, `base/number/stzComplex.ring:26` | f64 `re`/`im`; `RealPart, ImaginaryPart, Modulus, Argument, Conjugate, Plus, Minus, Times, DividedBy, Equals`; **the Ring face has no `Sqrt` or `Exp`, though `complex.zig:99, 108` have them**; log and inverse trig deliberately absent pending a branch-cut policy (`stzComplex.ring:21-24`, foundation `:1581-1583`) |
| regimes | `stzNumber.ring:173, 182, 191` | `StzMoneyQ` (money, 2 places), `StzExactQ` (raises rather than rounds, `:4631-4636`), `StzMeasuredQ(v, places)`; plain numbers are `:machine`; money and measured round half-even always (`:4618-4627`); the receiver's regime governs the result (`:169`) |
| exactness | `:4734, 4743, 4746, 4701` | `IsExact`, `WhyNotExact` ("" when exact; the reason strings at `:8421-8434`), `Why`, `Representation` -> `:rational`, `:decimal`, `:bigInteger`, `:integer` |
| observation | `:4712` | `:bigInteger` means more than 15 digits, so a 16-digit value below 2^53 is reported `:bigInteger`; the lesson "a number that explains itself" must show the ladder as it is |

### 1.2 Dense algebra (f64 only, checked)

`base/number/stzMatrix.ring:186` (4,659 lines) over `engine/src/linalg.zig`
(59 tests) and `eigen_general.zig` (77 tests). `SolveFor :980`,
`Determinant :2327`, `LeastSquaresFor :2412`, `CholeskyFactor :3822`,
`PseudoInverse :3729`, `EigenValues :3864`, `ComplexEigenValues :3924`,
`EigenVectors :4023`, `SVD :4158`, `Rank :4254`, `ConditionNumber :4120`,
`SchurQ/SchurT :3331/3337`, `LUInverse :3424`, `QRInverse :3473`,
`CholeskyInverse :3524`, `Inverse :4294`, `MatrixExp :3291`,
`MatrixLog :3227`, `MatrixSquareRoot :3625`, `MatrixPower :3596`, and the
trig, hyperbolic and inverse families `:2548-3185`.

Two facts that shape M1 and M5:

- **No rational or big-integer path exists** in `stzMatrix.ring`,
  `linalg.zig`, `eigen_general.zig`, `matrix.zig` or `sparse.zig` (grep for
  `rational`, `BigInt`: the one hit is a Pade "rational approximation",
  `eigen_general.zig:2374`). The Julia question is real.
- **There is no public LU-factor or QR-factor accessor**, only `LUInverse`
  and `QRInverse`. A lesson that shows `A = LU` as two pictures needs the
  factors. Routed as `MATH-FACTORS-01`.

### 1.3 Calculus and optimisation

| what | where | facts |
|---|---|---|
| autodiff | `engine/src/autodiff.zig:38-59`, `base/number/stzMathFunction.ring:34, 85` | reverse-mode tape; 16 ops (add sub mul div neg pow exp log sqrt sin cos tan tanh abs min max); **`MAX_VARS = 256`**; `ValueAt, GradientAt, ValueAndGradientAt, DerivativeAt` |
| L-BFGS | `base/number/stzObjective.ring:33`, `engine/src/lbfgs.zig` | `MinimizeFrom, MaximizeFrom, SetMaxIterations, SetGradientTolerance` |
| polynomials | `base/number/stzPolynomial.ring:59, 215` | roots by companion-matrix eigenvalues (2.0e-15 against `numpy.roots`); **the header at `:49` promises `RootMultiplicity()`, which is not defined** |
| LP / MIP | `base/optim/stzOptimModel.ring:60`, `engine/src/optim.zig` | `Vars, Maximize, Minimize, SubjectTo, SolveWith, Solution, Why, AST`; `:highs` refused (`:30-35`); `.zopt` through `stzOptimFile.ring:55` (no sample `.zopt` file exists in the tree); `stzOptimSentence.ring:48`; NSGA-II in `stzMultiObjectiveSolver.ring:9, 139` |
| the stats-side solver | `base/stats/stzLinearSolver.ring:475-478, 813` | **still raises "Branch-and-bound needs the simplex relaxation, which is not implemented yet" and keeps a placeholder tableau**, while the engine's `optim.zig` has both; routed |
| quadrature, RK4 | `engine/src/geo_furniture.zig:341-414`, `base/geo/stzGeoMap.ring:2785` | RK4 exists for streamlines only; Gauss-Legendre for geodesy only; no general ODE solver, no interpolation family |

### 1.4 Statistics

`base/stats/stzHypothesis.ring:116-226`: eight tests, **global functions,
not a class** (`StzTTestOneSample`, two-sample Welch and pooled, paired,
chi-square goodness of fit and independence, one-way ANOVA, correlation).
Every one returns an effect size -- Cohen's d, Cohen's w, Cramer's V, eta
squared or r (`engine/src/hypothesis.zig:45-327`); a test that did not run
reports `p = 1` (`:71`). Special functions from incomplete gamma and beta
(`special.zig`). `stzDataSet.BoxPlotStats` (`base/stats/stzDataSet.ring:2423`)
computes the five numbers and the 1.5x fences (`stats.zig:498-523`); **its
comment names an `stzBoxPlot` class that does not exist**. No bootstrap, no
Bayesian inference beyond the naive Bayes classifier, no non-parametric
tests. The Tukey tier: `base/stats/SOFTANZA_TUKEY_PLAN.md` (807 lines,
2026-08-16), TK0-TK6, no code, no `eda.zig`, no `base/test/tukey/`.

`base/number/stzRandom.ring` is **not a class**: uniform, weighted, shuffle,
Gaussian (`:4776`), exponential (`:1100`), `SeedRandom :1183`; **no Poisson
or binomial draw** outside the geo point processes
(`engine/src/geo_process.zig:138-197`).

### 1.5 Discrete mathematics

`engine/src/numtheory.zig:6-237`, **i64 only**: gcd, lcm, is_prime,
next_prime, prev_prime, nth_prime, factorize, factor_at, fibonacci,
is_fibonacci, mod_pow, mod_inv, divisor_count, divisor_sum, is_perfect,
euler_totient. `base/graph/stzGraph.ring:68` over `graph.zig`: BFS, DFS,
Dijkstra, A*, diameter, radius, topological sort, components, SCC,
bipartite, Kruskal MST, articulation points, bridges, core numbers,
betweenness, closeness, PageRank, clustering, Louvain (`graph.zig:1637`),
max flow, min cut, min-cost flow. Not found: Bellman-Ford, Floyd-Warshall,
isomorphism, colouring, cliques, Euler and Hamilton paths, a permutations
generator (`Combinations` exists, `stzListFunc.ring:7637`), truth tables,
SAT.

### 1.6 Signals

`base/number/stzFourier.ring:41` over `engine/src/fft.zig`: radix-2 and
Bluestein, `Transform, InverseTransform, Magnitudes, Phases, PowerSpectrum,
DominantFrequency, ConvolvedWith`. The GPU FFT is **convolution only**,
`stzGpu.ConvolveReal` (`base/gpu/stzGpu.ring:628`, `gpu_fft.zig`, f32). The
brief's "an FFT on the CPU and the GPU" is true of convolution and not of the
transform face.

### 1.7 Geometry made visible (the shape to reuse)

`base/geo/stzGeoProjection.ring`: `DistortionAt :290` returns
`[:h,:k,:a,:b,:areal,:angular,:crossing]`; `HoldsItsClaim :329` is measured,
never declared; `IndicatrixAt :351`; `DrawTissotOn(oCanvas, ...) :736` over
`geo_distortion.zig`. `base/geo/stzGeoMap.ring:387`:
`DrawStreamlinesOn :2792`, `DrawStreamDensityOnXT :3070`, RK4 in
`geo_furniture.zig:353, 414`. **The shape**: a numeric object answers facts,
and a `Draw...On(poCanvas, ...)` method paints into a canvas the caller owns;
a field crosses as a grid because the engine takes no callback. The figures
of M1 keep that shape and add the declaration in front of it.

### 1.8 Seen: the diagram system, the canvas, the window, the storyboard

**`base/graph/stzMathDiagram.ring`** (9,165 lines): `stzMathDomain :2888`,
`stzMathSubstance :3099`, `stzMathStyle :3591`, `stzMathDiagram :3819`, the
constructor `init(domain, substance, style) :3896`. Eleven domains in the
file (settheory `:152`, linearalgebra `:213`, geometry `:299` with Euclidean,
spherical, hyperbolic, Thales and Byrne styles, conic `:716`, table `:1937`
with icon-label, quaternion and **heat-map** styles, dots `:2020`, path
`:2048`, graph `:2116`, words `:2371`, order `:2466`, category `:2530`) and
seven in sibling files loaded after it (`stzBase.ring:362-379`: chemistry,
gantt, timeline, fishbone, floorplan, seating, choropleth) -- eighteen
math-plane domains. **The domain list is not closed**: no sentence in
`SOFTANZA_GRAPH_PLANE_PLAN.md` closes it; "closed" in its status table
(`:43-194`) means *has a guard section*, and DN24 is "the last domain of the
list" (`:4027`) as a matter of chronology. What binds a new domain: "a
domain is a NOTATION PROFILE over the single foundation. It is never a second
renderer" (`:1203-1204`); per-domain layout engines refused (`:1272`);
"3D stays outside" (`:2908-2909`); DN9 refuses "animation or timeline"
(`:4667`).

The solver (`:26-32`, `_Solve :7748`, `_SolveStage :8866-8957`): objective
plus `lambda * sum max(0, g)^2`, L-BFGS through `StzEngineGradCompile` and
`StzEngineMinimize(p, x, 400, 1e-6)`, lambda raised tenfold up to seven
rounds, feasible at 0.01 px. Layout functions (`:2866-2869`): contains,
disjoint, notCrossing, overlapping, touching, lessThan, greaterThan, equal,
inRange, sameCenter, near, minimal, maximal, notTooClose, above, below,
leftwards, rightwards. Shape kinds (`:3675-3679`): circle, rect, text, line,
curve, poly, mark, spline, ellipse. Row verbs: shape, delete, unknown,
field, override, ensure, encourage, layer. "Solve it before you copy it"
(`SOFTANZA_GRAPH_PLANE_PLAN.md:4207`; enforced at `:1705-1711`).

Notation (DN10): `StzNotationSymbol :1263-1289`, **72 names**, closed by
name; `_NtMath :1347` handles `^` and `_` to three levels; `_NtFontHas :1446`
refuses a glyph the font lacks (Segoe UI lacks seven, `PLAN:2867-2869`);
a `frac` command is refused by name. A symbol is a Unicode character drawn
as a text run (`:5505-5514`).

Live figure (DN8g): `DragTo :3967`, `Pin/Unpin :3990/4015`, `Relayout :3949`
(warm path, one start, lambda 1e5), `SetSubstanceData :4786` (cold
recompile), gesture verbs `:4102-4132`. Measured: Byrne dragged 60 px
re-solves in **27 ms** warm, **296 ms** on the first warm solve, 382 ms cold
(`PLAN:2741-2772`).

Rendering: `ToCanvas :4412` into a `stzCanvas`, `ToSVG :4427` (no GPU
needed), `ToPNG :4505` (needs a device), `Rendition() :4441` -> `:vector`,
`RenditionKinds :4445` = vector, image, graph, **text**.

**`base/graphics/stzCanvas.ring`** (778 lines): rect, gradient rect, circle,
round rect, ellipse, line, polyline, polygon, image, mesh, text
(`AddText :279`, vertical `:294`, justified with kashida `:315`), fill,
stroke, pick tags, `SetSvgIdent :419`. **No arc, bezier or dash primitive**
(bridge list `ring_bridge_gpu.zig:1951-2102`); curves are sampled to
polylines as `_CatmullRom` does (`stzMathDiagram.ring:4344`). Display list,
tessellation and SVG emission are Zig (`gpu_scene.zig`); PNG is a wgpu
render and readback; **no CPU rasterizer exists** (`SOFTANZA_GRAPHICS_PLAN.md:2522`,
"the vector tier is the floor" `:2537`); without a device `ToPNG` answers
`""` and counts the refusal (`:480-483`). Text is shaped by SheenBidi then
HarfBuzz then stb_truetype on the CPU (`gpu_text.zig:1-20`), so Arabic shapes
without a GPU; in SVG, text is outlines (`PLAN:2904`). Colour is a meaning,
never RGB (`SOFTANZA_COLOR_SYSTEM.md:178-182`), through one choke point
`StzColorToNumber` (`:22-24`).

**`base/graphics/stzPlotCanvas.ring`** (509 lines): seven pixel kinds (VBar,
HBar, Histogram, MultiBar, Line, Scatter, Treemap; dispatcher `:54`, switch
`:151-173`), **raw hex colours** (`:64-73, 258`), header stale at `:28`.
`engine/src/plot.zig`: six **text** renderers (bar `:198`, hbar `:493`,
histogram `:830`, mbar `:1082`, scatter `:1333`, surface `:1839`), byte-parity
between the Zig text renderer and the Ring text renderer it was ported from
(`base/test/stats/plot_engine_parity_narrated.ring`; expected strings
"GENERATED FROM THOSE BYTES, NOT TYPED", `plot.zig:1586`). **`renderSurface`
is a treemap** (`plot.zig:1825-1826`; `stzSurfacePlot.ring:85-88`). There is
no `y = f(x)` plotter, no parametric or polar plot, no number line, no
fraction picture, no complex-plane plot, no drawn box plot, no slider and no
animation of a diagram anywhere in the tree (grep, 2026-09-25).

**`base/graphics/stzWindow.ring`**: the loop `IsOpen :173 / Poll :236 /
DeltaTime :253 / Draw :332 / EachFrame :505`; Ring owns the loop and the
engine never calls into Ring (`PLAN:1338`; `stzPanel.ring:289-293`, events
drained never dispatched). Windows shipped, Linux and macOS unproven
(`PLAN:3595-3600`). **No screenshot API on the window**; a frame is captured
by rendering the same display list offscreen -- `stzCanvas.ToPixels :541`,
`stzScene.ToPixels :372` -- "the same renderer pointed at different targets"
(`PLAN:3533`; witness `showcase_window.ring:170-173`). `stzScene` (3-D):
camera, light, meshes (cube, sphere, torus, plane, obj, custom), instancing,
`Project :282`; **no vector tier**, `Show()` raises without a GPU (`:382-383`).

**`base/graph/stzStoryboard.ring`** (489 lines): `Frame`, `FrameOf`, `Bind`,
`BindFact`, `Act(verb, args) :171` with verbs `DragTo`, `SetData`,
`SetTheme`, `_CloseOpen :204` writes `<name>_NN.png` and judges the frame
with `StzCheckPictures`, `ToNarration :403` emits the `.narration` v0 grammar
(sample `base/test/graphics/folio/one-wedge.narration`). **Two facts M2
must not inherit**: `_CloseOpen` ignores `ToPNG`'s return, so on a machine
without a GPU no file is written and the name is still recorded; and
`_SbFilesDiffer` (`gg_adversarial.ring:22677-22683`) compares file names, not
bytes. No GIF, APNG or video export exists (GIF decode only,
`ring_bridge_gpu.zig:830`).

### 1.9 Learned: the education program

`base/education/` (E0-E8 shipped on `main`; `CHARTER.md`, nine laws at
`:39-47`; eleven gates under `base/test/education/`). A program is a folder
with `program.zknw`; a course is `program/courses/<slug>/course.zknw`, found
**by folder** (`stzProgram.ring:440-447`); three courses exist
(`elementary-introduction` with 15 chapters x 4 languages,
`zindara-missions`, `governed-agents`). Chapters are
`chapters/NN-<id>.<lang>.md` (`:592-594`), a missing language raises
(`:598-603`); a chapter is `# Title`, a byline, fenced `ring` cells with
`#-->` promises (`stzEducation.ring:154-166`), `{{exercise:<id>}}` lines,
`## Recap`; a stored output fence is refused (`stzChapter.ring:71-73`). An
exercise is `exercises/<id>/` with `exercise.zknw`, `promise.ring`,
`wrong/`, `right/`, `task.<lang>.md`; `ProveItself` runs every wrong answer
(each must fail) and every right one (`stzExercise.ring:188-226`); the
matcher rules are at `stzEducation.ring:22-28`; four editions must make the
same promises cell for cell (`course_narrated.ring:67-81`). The tutor
(`stzTutor.ring:15-18`): rule 1 blanks the right answers' method names and
promised values (`:439-466`), rule 2 is position (`ChapterOn`,
`stzLearner.ring:118-130`), the gap question is `StzGoalQ().RequireOne` over
`needs-step` facts then `AskInXT("tutor")` (`:390-413`); **no LLM hook
exists** (`:42`), and an exercise without `needs-step` facts gets only the
"look-output" reply. Overlays (`stzOverlay.ring`): an overlay adds to a
course and never creates one (`overlay-course :236-239`); `overlay-no-fork
:249, 280`; a bank overlay attaches `bank-01` to chapter 7; **there is no
school overlay** -- school is a core world (`program/worlds/school.zknw`).
The reader (`stzEduReader.ring:110-169`) renders headings, paragraphs,
lists, quotes and code; **it has no image support**; RTL is `dir="rtl"` on
the article with `<pre dir="ltr">` and `<bdi>` around non-ASCII literals
(`:39-69, 145, 311-316`). The demo (`demo/demo.ring:78`) copies `program/`
and **refuses any file that is not `.md .zknw .ring .pia .txt .csv .zgov`**,
so no picture file may live under `program/`. Exercise ids are global
(`stzLearner.ring:48-49`); `spine_narrated.ring:31` asserts exactly 25
skills and `worlds_narrated.ring:28` exactly three worlds. The Hausa natural
pack speaks about strings only (`stzEducation.ring:357`) and has no number
vocabulary (inferred from the pack).

### 1.10 Proofs: the guards and the oracle

46 guards `base/test/number/numeric_*_narrated.ring` (autodiff, backprop,
calculable, complex, counting_idiom, decomposition, definitions,
eigenvectors, eigen, embedding, exactness, fft, handle_table, hypothesis,
knn_selection, least_squares, logistic, matrix_truth, no_loss, one_distance,
optimizer, pca, polynomial, pseudoinverse, rationals, reference_oracle,
regime, residency, robustness, rounding, similarity, simplex, sparse,
special_functions, summation, svd_general, svd, text_mining, tier_door,
tie_rule, trustworthiness, tsne_gpu, umap_gpu, umap_resident,
variance_authority, vector_index). The oracle discipline lives in
`base/test/number/`, not in the foundation document (0 hits for "oracle"
there): `numeric_reference_oracle_narrated.ring` (corpus hilbert4/5/6,
vander4, nearsing2, tridiag5, spd3, rot3 at `:17-22`; "TOLERANCES ARE
DERIVED, NOT INVENTED" `:27-36`), `_gen_numpy_reference.py` (`EPS`
`:21`, `cond` `:128`, exact solve with `Fraction` `:24-46`, least-squares
bound `100 * kappa * eps` `:246-251`), `_numpy_reference.ring`,
`_numpy_fft_reference.ring`. Engine tests: 2,045 stated
(`SOFTANZA_COMPUTE_MODEL.md:153`); 2,425 static `test` blocks under
`engine/src` (a count, not a run).

The math-diagram gate: `gg_adversarial.ring` sections 79-104 (`:12657-14490`),
`sec()` prints the previous section's wall time (`:17303-17311`); the one
render gate is section 91, `StzCheckPictures` over 88 pictures asserting
exactly 37 planted findings under 80 s (`:13524-13654`). **No byte-parity
guard exists for math diagrams**; the 52 `math_NN.png` and 52 `dark_NN.png`
in `base/test/graphics/` are committed pictures a person looks at.

### 1.11 Absent, verified by grep on 2026-09-25

ODE solver (RK4 in geo only), bootstrap, Bayesian inference, convex hull,
Delaunay, Voronoi, truth tables, SAT, a permutations generator, complex log
(deliberately), non-parametric tests, Poisson and binomial draws, a
`y = f(x)` figure, parametric and polar figures, a number line, a fraction
picture, a complex-plane figure, a `z = f(x, y)` surface, a drawn box plot,
a slider, an animation of a diagram, a frame-sequence export, a mathematics
course, a mathematics vision document, `base/math/`.

## 2. Repairs routed (findings, never fixes)

Each row: what was observed, what was checked against what was inferred, and
the owner Central routes it to. Filed in `mailbox/stzlib-math.md` as
`MATH-FINDING-NN` with this table as the reference.

| id | where | observed | checked / inferred | owner |
|---|---|---|---|---|
| F01 | `base/doc/design/SOFTANZA_INTELLIGENCE_ARCHITECTURE.md:925, 933-935, 939-943` | section 5.3 still says stzMatrix is 2.4k lines, simplex is a stub, "no Ax=b solve, no LU/QR/Cholesky/SVD/eigen", "no random DISTRIBUTIONS"; also `:1027-1031, 1043-1044`; its own re-audit marks the stub row closed at `:478` | checked by reading | the document's owner, via Central |
| F02 | `base/number/stzNumber.ring:4696-4698` | the comment says `:rational` and `:complex` are not built; `:4701-4705` returns `:rational`, pinned by `numeric_rationals_narrated.ring:34` | checked | number |
| F03 | `base/doc/design/stzextertool-design-article.md:165` | roots of `3x^2 + 2x - 8` given as 1 and -8/3; the roots are 4/3 and -2 (3*(16/9) + 8/3 - 8 = 0; 12 - 4 - 8 = 0) | checked by arithmetic | the document's owner |
| F04 | `SOFTANZA_NUMERIC_FOUNDATION.md:4, 83, 939, 1118 vs 1396, 1566, 3152` | the foundation contradicts itself: "ALL PHASES 0-7 COMPLETE" beside "Phases 5-7 are design"; P4 "STARTED" beside "PHASE 4 IS COMPLETE"; `:rational` "not built"; FFT "not built" while `fft.zig` and `stzFourier` exist; "No GPU" while GPU guards exist; `numtheory.zig` credited with factorial and digit predicates it lacks | checked | number |
| F05 | `base/number/stzPolynomial.ring:49` | the header promises `RootMultiplicity()`; no such method is defined | checked | number |
| F06 | `base/number/stzComplex.ring` | no `Sqrt` or `Exp` on the face while `complex.zig:99, 108` implement them | checked | number |
| F07 | `base/stats/stzHypothesis.ring:116-226`, `base/number/stzRandom.ring` | the eight tests and the random module are naked globals; LAW 1 asks for an instantiable entry object with a global form as sugar | checked; whether this is a defect or a ruled exception is for the owner | stats, number |
| F08 | `base/stats/stzLinearSolver.ring:475-478, 813` | raises "Branch-and-bound needs the simplex relaxation, which is not implemented yet"; `BuildSimplexTableau` is a placeholder; the engine's `optim.zig` has both | checked | stats |
| F09 | `base/stats/stzDataSet.ring:2423` | the comment names `stzBoxPlot`, which does not exist | checked | stats |
| F10 | `base/graphics/stzPlotCanvas.ring:28, 64-73, 258` | header lists four of seven kinds; colours are raw hex against the colour system's rule that colour is a meaning | checked | graphics |
| F11 | `base/graph/stzMathDiagram.ring:93-98` | header says "Three domains ship"; eighteen do | checked | graphics |
| F12 | `base/graph/stzStoryboard.ring:204-243` | `_CloseOpen` ignores `ToPNG`'s return: on a machine with no GPU the frame name is recorded and no file exists; `_SbFilesDiffer` compares names only | checked by reading, not run | graphics |
| F13 | `base/education/stzEduReader.ring:110-169` | the reader has no image or SVG support; a picture-first course cannot show a figure in the page | checked | education (request `MATH-READER-FIGURE-01`) |
| F14 | `base/education/stzTutor.ring:390-413` | the gap question knows string verbs (contains, find, remove); a mathematics exercise without `needs-step` facts gets "look-output"; this plane will declare `needs-step` on every exercise and asks for a number vocabulary in `GapIn` | checked | education |
| F15 | `base/test/education/spine_narrated.ring:31`, `worlds_narrated.ring:28` | exact counts of skills and worlds; a mathematics course that trains its own skills turns the spine red unless the program grows | checked | education (request `MATH-SKILLS-01`) |
| F16 | `base/education/demo/demo.ring:78` | the demo's extension whitelist refuses `.zfig`; a figure declaration file inside `program/` would print NOT PROVED | checked | education (request `MATH-ZFIG-DEMO-01`, or figures stay inline in cells) |
| F17 | `base/natural/stzNatural.ring:84-110`, `stzEducation.ring:357` | the Hausa pack has no number or mathematics vocabulary | pack read; absence inferred | natural (`MATH-HAUSA-NUMBER-01`) |
| F18 | `base/graphics/stzCanvas.ring`, bridge `:1951-2102` | no arc or bezier primitive; every curve is a sampled polyline; acceptable for M1, named so a later request for an arc has its precedent | checked | graphics, information only |
| F19 | `engine/SOFTANZA_COMPUTE_MODEL.md:153` | "2045 engine tests" against 2,425 static `test` blocks; a stated count that is neither a run nor the static count | counted, not run | engine, information only |

## 3. Contracts consumed

What this plane relies on, where it is written, and what would break this
plane if it moved. Every row is a request Central can route when it changes.

| contract | where | this plane relies on |
|---|---|---|
| domain extension protocol | `stzMathDiagram.ring:123, 2903-3071, 3126-3567`; `stzBase.ring:362-379` | a new figure kind = domain + style + builder + rule set in its own file, loaded after the core; no new shape kind or layout function without a routed request |
| solver caps and budgets | `autodiff.zig:38` (256 vars); `_SolveStage` 7 rounds, 400 L-BFGS steps; warm 27 ms / first warm 296 ms; drag budget 100 ms (`GRAPH_PLANE_PLAN:2755`) | the computed/solved split of law 4 |
| solve before copy | `GRAPH_PLANE_PLAN:4207`; `stzMathDiagram.ring:1705-1711` | a motion stores solved states, never unsolved pictures |
| canvas | `stzCanvas.ring:131-419, 476-548` | SVG without a device; PNG and pixels with one; curves sampled; text shaped on the CPU |
| colour | `SOFTANZA_COLOR_SYSTEM.md:22-24, 178-182` | every colour is a role name through `StzColorToNumber` |
| window loop | `stzWindow.ring:173-515`; `PLAN:1338` | Ring owns the loop; state changes are made by Ring inside the loop body; no callback from the engine |
| capture | `stzCanvas.ToPixels :541`, `stzScene.ToPixels :372`, `PLAN:3533` | a frame is the same display list rendered offscreen |
| storyboard and narration | `stzStoryboard.ring:171, 204, 403`; `.narration` v0 | a motion exports through `Act` and `ToNarration`; the frame-reality guard is this plane's |
| number tower | `stzNumber.ring:173-191, 4595-4755` | regimes, `IsExact`, `WhyNotExact`, `Representation`, `Same` |
| oracle | `base/test/number/_gen_numpy_reference.py`, `_numpy_reference.ring`, `numeric_reference_oracle_narrated.ring` | a claim at L2 is judged the way these judge: derived tolerance, exact rationals for the truth |
| course loader and formats | `stzProgram.ring:440-447, 564-603, 678-683`; `stzExercise.ring:188-226`; `stzEducation.ring:22-28, 154-166` | course by folder; chapter and exercise shapes; matcher rules; same promises cell for cell |
| overlay court | `stzOverlay.ring:108-302` | an overlay adds to `courses/math/` and never creates it; every world in an overlay needs an `is-a` and two `requested` facts |
| demo whitelist | `demo.ring:78` | nothing but `.md .zknw .ring .pia .txt .csv .zgov` under `program/` |
| tutor | `stzTutor.ring:15-18, 390-413` | `needs-step` facts on every exercise |
| memo, cost, PX | `D:\GitHub\softanza\protocol\STYLE.md`, `COST.md`, `PX.md` | stamps read from the clock; one cost line; probe first, gate once |

## 4. The phases

Each phase names its deliverable, its done-when, the guards that prove it,
what is routed and what is not claimed. Nothing in M1 or later starts before
the author ratifies M0.

### M0 -- Charter

**Deliverable**: `CHARTER.md`, this plan, the registration in
`mailbox/stzlib-math.md`, the findings of section 2 filed, the memo to the
author with the eight decisions. **Done when** the author ratifies the
charter. Nothing else is claimed.

### M1 -- The visual doors

**Deliverable**: seven figure kinds, each a domain in its own file under
`base/math/`, each with a catalogue scene under `base/test/math/`, a guard
section, a negative sibling, and a picture looked at:

| kind | computed half | solved half | rendition |
|---|---|---|---|
| `:Function` (explicit, `:Parametric`, `:Polar`) | samples of `f` from `stzMathFunction`, zeros and extrema from its derivative | axis labels, marks, the tangent, the label placed off the curve | vector and image |
| `:Surface` `z = f(x, y)` | a mesh grid | -- | vector as a projected wireframe through `stzScene.Project` on the canvas; image as a real `stzScene` mesh on a GPU |
| `:ComplexPlane` | points, the unit circle, a root set (`stzPolynomial.ComplexRoots`) | labels, the argument arc's label | vector and image |
| `:BoxPlot` | `BoxPlotStats` from `stzDataSet` | group labels, outlier labels | vector, image and **text** (the Tukey plan's TK3 asks for a text reading) |
| `:NumberLine` | ticks from a step ladder (the timeline domain's `_TlStepFor` is the precedent, `stzTimelineDiagram.ring:363`) | point labels, the arrow of an addition | vector and image |
| `:Fraction` | the parts | the parts tile the whole, the shaded ones contiguous | vector and image |
| `:Matrix` | cells (the heat-map style, `stzMathDiagram.ring:1995`, and the grid of scene 30 are the precedent) | dimension heads, the `x` and `=` glyphs, factor panels once `MATH-FACTORS-01` lands | vector and image |

**Notation**: a specification for fractions, roots, sums and matrices in
`$...$` -- runs with stacked boxes, not TeX -- sent to graphics or built
here per decision 6.

**Done when**: each kind has a catalogue scene, its guard asserts the solved
geometry by arithmetic re-derived from `ShapeOf` (the way `gg_adversarial
:12699` does), its SVG is compared byte for byte against an expectation
**generated from the bytes** (the `plot.zig:1586` discipline; the PNG path
is looked at on the author's machine and never asserted, because `ToPNG`
needs a device), and a wrong declaration is refused by name. **Not claimed**:
a CPU rasterizer; PNG parity; anything on Linux or macOS.

#### M1a RESULTS -- the `:Function` figure, 2026-09-26

**Shipped**: `base/math/stzFunctionFigure.ring` (the domain, the builder,
the style, three rules registered into the one gate), `base/math/stzMathFigure.ring`
(the entry object, `StzMathFigureQ(kind, spec)`), the load block in
`stzBase.ring`, and `base/test/math/` (scenes, catalogue, gate, two probes,
the byte expectation, fourteen pictures light and dark). `:Function` takes
the explicit, parametric and polar forms; zeros, extrema and given points
are found on the tape and refined by bisection; a pole breaks the curve
and a window bounds it; nine notes are solved as offsets from their marks.
Gate `math_narrated.ring`: 73 assertions in 7 sections, about 22 s on a
quiet machine (2.4 / 1.7 / 2.9 / 0.1 / 9.1 / 6.5 / 0.1 s per section; 94 s
under load the same hour, which is why the per-section times are the
measurement and the wall time is not). Catalogue: 7 scenes, looked at.

**Found while building, and what each changed:**

- A spline shape holds at most 64 controls (`stzMathDiagram._MintShape`),
  so a 400-sample piece is seven runs sharing endpoints. Routed
  `MATH-POLYLINE-01` to graphics: a data-only polyline kind.
- From a random start the solver ran 35 penalty rounds and stuck on
  twelve notes with sixteen chords each. A note declared as an OFFSET from
  its own mark, started on the mark's free side (below a minimum, above
  anything else), solves in two rounds. Where a label starts is where its
  placement is decided; the rules were never the problem.
- A note's centre derived from offsets is not a "free centre", so
  `DragTo` and `Pin` refuse it; the figure moves a note through its
  offsets (`MoveNoteTo`), writing the diagram's own slots. Routed
  `MATH-DRAGFIELD-01` to graphics: a drag by unknown path.
- Ring hands back a COPY when a method returns an object: a witness that
  tampered `oF.Substance()` found nothing. Every mutation goes through the
  figure's own methods, and the plan says so where it matters.
- `StzFind(needle, list)` answers a list of positions, not a number,
  against the sentence in stzlib's `CLAUDE.md`. Routed as a documentation
  finding; the figure uses a plain loop.
- The sign change across tan's pole is not a zero: a root is accepted only
  where the value is small relative to its bracket; the same law on the
  slope for an extremum.
- The generic `name_off_ink` rule (0.5 px) placed the tick numbers: at the
  frame edges, where the curve never goes, with the axes starting at the
  frame edges too.

**Not claimed**: notation growth (M1's last step); the render on Linux or
macOS; PNG parity (the SVG is the byte expectation, a PNG needs a device);
a solve under 100 ms (the cold solve of nine notes is 2.4 s, M2's concern).

### M2 -- Motion

**Deliverable**: `stzMathMotion`: `Param(name, from, to)` re-solves a figure
on change through `SetSubstanceData` (cold) or `Relayout` (warm) as the
change requires; `State(caption, changes)` declares a sequence; `Play(oW)`
runs in the window loop the way `stzDiagram.RunIn` does
(`stzDiagram.ring:10732`), rebuilding only when the model changed;
`ExportTo` writes a storyboard through `Act` and a `.narration` through
`ToNarration`. **Done when**: Pythagoras as declared states (Byrne's I.47
squares moving into place) and `y = a * sin(b x)` under two parameters run
in the window, the computed half at frame rate and the solved half within
100 ms, both numbers printed by the guard; and `motion_narrated.ring` proves
the exported frames equal the live ones by comparing `ToPixels` of the live
state against the exported state re-rendered, refusing by name when the
machine has no device. **Routed**: F12. **Not claimed**: 60 fps for the
solved half (decision 8); GIF or video.

### M3 -- The mathematics course

**Deliverable**: `program/courses/math/` -- `course.zknw`, fifteen chapters
in en/fr/ar/ha, every numeric claim a `#-->` promise, every figure a
declaration in a cell (no picture file under `program/`), one exercise per
chapter proved by wrong and right answers, `needs-step` facts on every
exercise, ids prefixed `math-`; the bank overlay attaches money exercises
(`overlays/bank/courses/math/course.zknw`); the school world is used through
`uses-world`. Chapter spine, by level:

| level | chapters |
|---|---|
| L0 | the number line; the fraction; the chaos game |
| L1 | a function is a picture; a family under a parameter; geometry declared and solved (Thales, Byrne) |
| L2 | a number that says why it is not exact; matrices as pictures; statistics as a language of thought; probability by the quantifier continuum |
| L3 | money that must not lose a centime; an optimisation model (`.zopt`); Tukey's first look (after M4) |
| L2-L3 | the derivative that checks the formula; an identity is not a self-check |

**Done when**: `course_math_narrated.ring` is green in all four languages
with the same promises cell for cell, `tutor_math_narrated.ring` asks the gap
question on every chapter and refuses the answer, and a decision maker's
15-minute demo runs offline from a clean folder (the education demo's
mechanism, `DemoProved`, counting "N proved, 0 not proved"). **Routed**:
F13, F14, F15, F16, F17. **Not claimed**: native review of fr/ar/ha; a cell
in the browser (ringscript); a figure shown in the reader before F13 lands
(until then the page shows the figure's `Why()` and the guard shows the
picture).

After M3, Central is asked to rate `base/math/` as a card on the Atlas by
what its guards prove.

### M4 -- Tukey, built

**Deliverable**: TK0-TK6 as `SOFTANZA_TUKEY_PLAN.md` wrote them, with every
picture a figure of M1 (box plot from M1; stem-and-leaf as a text-rendition
figure; letter values; residual-versus-fit; the coded two-way table; the
re-expression ladder as a table, per the plan `:407`). **Done when**:
`Data = Fit + Residual` holds on the plan's own examples -- R's `medpolish`
example to 1e-9 (`:622-647`), Tukey's three-group line published example,
a synthetic multiplicative table whose ladder power is near 0 with slope
near 1 (`:663-676`); no p-value, interval or forecast anywhere in the tier
(`:313-314`); the pictures are looked at. **Routed or ruled**: decision 7
(who owns `eda.zig`). **Not claimed**: TK6's panel before the GUI's G5.

### M5 -- Deepen the core (routed)

Requests, each with the oracle and the picture that would prove it, to the
owning plane through Central:

| request | oracle | picture |
|---|---|---|
| RK45 with error control | the harmonic oscillator's energy, and a stiff test problem against a published table | the phase portrait, a `:Function` figure |
| forward-mode AD | agreement with the reverse tape to 8 decimals on the existing 16 ops | the tangent under a slider |
| bootstrap | a normal sample whose bootstrap interval covers at the nominal rate over 1,000 draws | the resampling histogram |
| a first Bayesian door (conjugate beta-binomial) | the closed-form posterior | the prior-to-posterior motion |
| convex hull and Delaunay | Euler's formula and the empty-circle property on random points | the triangulation, a `:Points` figure |
| permutations, truth tables, a small SAT | counts against the closed forms; the pigeonhole instance unsatisfiable | the truth table as a `:Matrix` figure |
| Poisson and binomial in `stzRandom` | mean and variance over 1e6 draws within derived bands; the chi-square test already in the tree | the histogram against the mass function |
| the branch-cut policy for complex log and inverse trig | `exp(log z) = z` on both sides of the cut with the negative sibling that crosses it | the complex plane with the cut drawn |
| `MATH-FACTORS-01`: LU and QR factor accessors | `A = LU`, `A = QR`, residual against `kappa * eps` | the factor panels of a `:Matrix` figure |
| the Julia question: LU and Cholesky over the exact tower | `Fraction` solve already in `_gen_numpy_reference.py:24-46`; a 4x4 rational system solved with zero residual | every pivot shown as a fraction |

**Done when**: every request is filed with its two columns and the owning
plane has accepted or declined through Central. Nothing here is built by
this plane.

### M6 -- A bridge to formal proof

**Deliverable**: `stzMathClaim.ToLean()` emits a Lean 4 statement against
Mathlib for the identities a lesson states (an algebraic identity, an
inequality, a divisibility fact); a checker runs Lean when it is installed
and carries the verdict back as a guard; the zero-setup floor is the
numeric guard, per law 9. **Done when**: one chapter's identities are
machine-checked, the guard fails when a statement is made false, and a
machine without Lean reports the door closed by name and stays green on the
floor. **Ruled**: decision 5.

## 5. The demo bar, mapped

| the 15-minute demo shows | what proves it | lands in |
|---|---|---|
| a number that explains itself: `(9007199254740992 + 1)` in f64 and in the tower, and `WhyNotExact()` | `stzMathClaim.In(:f64)` and `.In(:exact)` with `Why()` | M1 (claim) and M3 (chapter) |
| declare a figure, watch it solve; edit a sentence, drag a point in Byrne's Euclid | a `:Function` figure re-solved on an edited declaration; `DragTo` on scene 37 | M1, M2 |
| move a slider, see a family: `y = a * sin(b x)`, offline | `stzMathMotion.Param` in the window; two numbers printed | M2 |
| a proof that plays: Pythagoras as declared states, exported, frames real | `State` sequence; `motion_narrated.ring` pixel comparison | M2 |
| nothing is faked: a wrong answer fails by running, a right one passes | `ProveItself` on every exercise; a planted wrong claim in the demo | M3 |
| in their language: the same lesson in French, Arabic right-to-left, Hausa | the course gate over four editions; the reader's RTL | M3 |
| on their world: the bank's money; the school's own problems | the bank overlay's money exercises; the school world | M3 |
| proven at the frontier: one identity checked in Lean, its verdict a green guard | `ToLean` and the verdict guard | M6 |

## 6. What not to do

- No CAS, no equation solver over symbols, no TeX engine.
- No GMP, MPFR, FFTW or BLAS; the decisions are written and measured.
- No symbol-first course; the visual-first law is the point.
- No pre-baked frame, plot or answer; no picture file under `program/`.
- No model answering a mathematical exercise for the learner.
- No fix in a consumed module; every one is a routed finding.
- No claim called proven without a guard; no gate counted as run that was
  not; no wall time quoted without the section it came from.

## 7. The numbers this plan rests on

| number | what | where |
|---|---|---|
| 256 | tape variables the solver can hold | `autodiff.zig:38` |
| 27 ms / 296 ms / 382 ms | warm re-solve / first warm / cold, Byrne dragged 60 px | `SOFTANZA_GRAPH_PLANE_PLAN.md:2741-2772` |
| 100 ms | the drag budget the graph plane set | `:2755` |
| 16.7 ms | one frame at 60 fps | arithmetic |
| 0.08-0.6 ms | the window tier's frame cost | `SOFTANZA_GRAPHICS_PLAN.md:2618` |
| 29.1 ms | a 1080p still, 95% zlib | `:2606-2618` |
| 72 | notation names | `stzMathDiagram.ring:1263-1289` |
| 18 | math-plane domains | `stzMathDiagram.ring`, `stzBase.ring:362-379` |
| 52 + 52 | catalogue pictures, light and dark | `base/test/graphics/` |
| 88 / 37 / 80 s | pictures, planted findings and bound of the one render gate | `gg_adversarial.ring:13524-13654` |
| 46 / ~1,805 | numeric guards and their assertions | `base/test/number/`; the assertion count is the compass's, not re-counted |
| 2,045 / 2,425 | engine tests stated / static blocks | `SOFTANZA_COMPUTE_MODEL.md:153`; grep |
| 15 x 4 | chapters and languages of the first course | `program/courses/elementary-introduction/chapters/` |
| 30 s, missed by 1-9 s | the education gate budget and the cold-start tax | CONCLUSIONS 2026-09-23 |
| 31 | commits the stzlib tree's local `main` is behind `origin/main` | `git rev-list 04cff1c34..a94ba2920` |
