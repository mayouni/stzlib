# Softanza Model Flow — faculties, flows, and a registry that picks the model

### Programming with models as data flow: the requirement chooses the model, the model can be swapped, and the floor is always there

**Status**: DESIGN, v0.1 · **Date**: 2026-10-21 · **Plane**: stzlib-intelligence · **Nothing in §14 is built until the author has read this.**
**Extends, does not fork**: `SOFTANZA_INTELLIGENCE_ARCHITECTURE.md` (the Six Laws §1, the Uter ladder §5.6, the Model Foundry §5.9), `base/neural/SOFTANZA_STRUCTURED_OUTPUT.md` (contract **C9 v1.0.0**, unchanged by this file).
**Read from**: `intelligence/model-flow` @ `main` a6a59d4f6 plus three engine commits (2f5dd6c33, 9c7514fc4, 13ea45735). Not `origin/main`, which has diverged from local `main` (ahead 5751 / behind 6081 at the time of reading).

---

## 0. What this is, in four sentences

A **faculty** is a typed function — a payload type in, a payload type out, both judged by a court — that always has a deterministic **floor** and may have any number of model-backed **implementations**. A **flow** is faculties wired as a data flow: what passes between stages is an immutable, replayable **parcel** that carries its value, its provenance, its evidence and its cost. A **registry** resolves a **requirement** (task, types, quality, latency, memory, locality, languages) to implementations, says why (`Why()`), and can always be overruled by pinning a model, a set, or the floor. Because the flow names faculties and never models, a model can be swapped, upgraded, or replaced by a plain algorithm without touching the solution, and the user may never know a model was involved — except that the trace says so.

```ring
oF = StzFlowQ("ticket-triage")
oF.AddStageQ("lang",  :detect-language).
   AddStageQ("kind",  :classify,  [ :labels = [ "bug", "billing", "other" ] ]).
   AddStageQ("facts", :extract,   [ :schema = oTicketSchema ]).
   AddStageQ("brief", :summarise, [ :max-words = 40 ])

? oF.ResolvePlan()                # data: which implementation each stage WOULD use, and why — runs nothing
oP = oF.RunQ(cTicketText)         # a parcel object: the value, plus how it came to be
? oP.Value()                      # data: the typed record
? oP.Why()                        # data: "lang: floor; kind: qwen2.5-1.5b (measured 0.85 vs floor 0.62); facts: ..."

oF.PinStage("kind", :floor)             # same flow, that stage now a plain algorithm
oF.PinStage("kind", "granite-4.0-1b")   # same flow, that stage now this model
oF.UseFloorEverywhere()                 # every stage on its floor — for a machine with no model, or a test
```

*Naming follows Softanza's own forms: an **active** verb (`AddStage`) mutates and returns nothing; its **`Q` twin** (`AddStageQ`) mutates and returns the object so calls chain; a plain noun-like name (`Value`, `Why`, `Stages`) returns **data**; `Run` returns the value (data), `RunQ` the parcel object. See §4.3.*

---

## 1. The ten requirements and where each is met

| # | The author's requirement (2026-10-21) | Met in | By |
|---|---|---|---|
| 1 | Execute the engine patches and enhancements | **Part A, done and committed** | pool from the graph (2f5dd6c33), prompt window (9c7514fc4), termination aids (13ea45735); §12 lists what is still owed (A4, A5) |
| 2 | Generalise the selection of useful small models by field | §13, the survey tables | a faculty catalogue per Softanza domain with floor, candidate models, licence filter, and the engine work each costs |
| 3 | Softanza as rich in small models as in algorithms | §13, §3 | every domain gets a faculty with a floor; a model earns a place only by beating the floor on that faculty's golden set |
| 4 | One design, consistent with the Six Laws, C9, the Uter ladder | §2, §10, §14 | LAW 1 (domain = folder = entry object = format), LAW 2 (floor, then local model, never remote), LAW 3 (`Why()`, overridable), LAW 5 (a flow IS a graph), LAW 6 (self-describing, checkable, guardrailed); C9 is the court for records |
| 5 | Implicit **and** explicit use | §8 | implicit routing at five named hooks, always traced, always switch-off-able; explicit: `Using`, `Pin`, `Policy` |
| 6 | Requirements choose the model; the inverse stays possible | §5 | `StzRequirementQ(...)` resolves; `Pin` per call, per stage, per flow, per process |
| 7 | The flow between models is a data flow between functions | §3, §6 | the parcel; typed edges; a flow is a `stzGraph` |
| 8 | A model changes without changing the solution; or downgrades to an algorithm | §4, §9 | implementations are interchangeable by contract; the golden set every implementation — the floor included — runs; `UseFloorEverywhere()` |
| 9 | Analyse through what Softanza has and lacks, and through modern small open models | §13, §16 | the survey, the Compass update list, the engine gaps by cost |
| 10 | In document intelligence in particular, Docling, on an RTX machine | §15 and the separate Part D decision memo | `document` as a parcel type; stages as faculties; floor first |

---

## 2. Where this sits in the doctrine (no fork)

**Faculty is already a word in the doctrine.** §5.6: a Regexuter is *"a FACULTY, not a mind"* — a reflex arc over one medium; §5.6 again: *"an LLM is a pluggable faculty — one generative Xuter among the faculties — never the definition of the mind"*; the Compass and the Jev concordance call the same thing a *LAW-2 faculty*. This design keeps the word and makes it exact: **a faculty is a named, typed capability with a floor.** A Xuter is a faculty whose implementation is a pattern; an `stzLLMFunction` is a faculty whose implementation is a model; they differ in implementation, not in kind. Nothing here renames the Uter ladder; the ladder is *how a mind uses faculties*, this file is *how a faculty finds its implementation*.

| Doctrine | What this design does with it |
|---|---|
| **LAW 1** — a domain is a folder, an entry object, a persistable format | proposed domain folder `base/faculty/` (§14), entry objects `stzFaculty`, `stzFlow`, `stzModelRegistry`, formats `.zfac` (faculty/flow declarations) and `.zmdl` (what is installed and what was measured). Names proposed to Central, not created. |
| **LAW 2** — floor, then local model, never anything paid or remote | every faculty has a floor, enforced at declaration. A model is selected only if it **beats the floor on the faculty's golden set**. A remote service is never selected implicitly. |
| **LAW 3** — maximum control, every verdict explains itself | `Why()` on registry, plan, parcel and flow; every automatic choice overridable; ambiguity refuses. |
| **LAW 4** — consume today, create tomorrow | the registry consumes GGUF; the Model Foundry's DLM (§5.9) is just another implementation kind, `:dlm`, with rung-1 as its floor. |
| **LAW 5** — composition is the payoff | a flow is a `stzGraph`; `CheckRules()` runs on it; no new machinery for typing, cycles, reachability. |
| **LAW 6** — the machine programmer is a first-class audience | a flow answers `Ask()`/`WhatIs()`, is **checked before it runs** (`ResolvePlan()`, `CheckRules()`), and refuses doctrine-breaking use (§10). |
| **C9** — structure kills malformedness, not falsehood | C9 is the court for the `:record` parcel type. **C9 is not changed.** Media types get their own small courts (§3.3); a future `C10 Model Flow` is proposed in the mailbox, not drafted here. |
| **Model Foundry (§5.9)** | a DLM is an implementation: its rung-1 deterministic model is a floor candidate, its rung-2 GGUF a model implementation. The registry is where the Foundry's products get consumed (LAW 4's "consume today"). |
| **`stzLLMFunction`** | becomes the `:model` implementation wrapper for text→record faculties. Its budget, retries, goldens, memoisation, `UseResponder`/`SeedAnswer` survive unchanged. It is not replaced. |
| **Jev concordance** (COMPASS-JEV-DECISIONPORT-01, -CALIBRATION-01, -GATEJUDGE-01) | §7, §9, §10 — each of the three moves has its place; they are not a separate subsystem. |

---

## 3. The parcel — what passes between stages

The flow is a data flow, so the value passing is the design. A **parcel** (`stzParcel`) is the only thing a stage receives and the only thing it returns.

```
parcel
  type        the payload type, from the closed vocabulary in §3.2
  value       the payload, OR a handle to engine-resident data (never a copy of a big buffer)
  evidence    certainty:   :certain | :probable | :apparent | :unknown      (the evidential register, LAW 3)
              p:           0..1, only when the implementation can state one
  provenance  [ { faculty, implementation, version, kind (:floor|:model|:service|:dlm),
                  model-sha256, grammar-used, seed, constrained, court-verdict } ... ]   — the whole chain
  cost        { ms, tokens-in, tokens-out, bytes-peak, device (:cpu|:gpu) }
  trace       the run id and stage names
  key         sha256 of (faculty, implementation, implementation-version, canonical input, options)
```

### 3.1 Properties

- **Immutable.** There is no `Set`. A stage returns a new parcel whose provenance extends the old one.
- **Replayable.** Provenance + `key` is enough to say *exactly* what ran. A parcel recorded with `seed` and `constrained` replays byte-identically on the same model file (the engine is reproducible under a seed — measured: `engine_termination_narrated`, the plain runs).
- **Memoisable.** `key` is a content hash, as `stzLLMFunction` already memoises (C9 §9). The registry's cache is keyed on it; a hit is free and deterministic.
- **Validated or refused.** A stage yields a parcel that its **court** accepted, or a **refusal** — itself a parcel of type `:refusal` carrying the finding in the house shape `[ :rule, :subject, :where, :severity, :message ]`. No partial credit (C9 R1) is extended to every type.
- **Big data is a handle.** Text and records travel as values. Embeddings, images, audio, tables and documents travel as **engine-resident handles** with their metadata beside them (perf law 1: mutable state in engine handles, materialised eagerly). A flow over a 2,000-page document copies no pages.

### 3.2 The type vocabulary (closed, like C9's)

| type | value | court (what "valid" means) |
|---|---|---|
| `:text` | UTF-8 string | valid UTF-8; length within the stage's declared bound |
| `:tokens` | list of ids + the tokenizer id | ids in range for that tokenizer |
| `:vector` | engine handle, `dim`, `model-id` | finite floats; `dim` matches the declared one; **vectors from different models never compare** — the court refuses `dim` or `model-id` mismatch |
| `:record` | a structure | **C9, verbatim** (`stzOutputSchema`): R1–R5, closed types, closed keys, the finding shape |
| `:label` / `:labels` | `oneof` members | **C9 `oneof`**, exact match after trim + case fold |
| `:score` | number in a declared band | **C9 `number`** with `:must` |
| `:table` | `stzTable` handle | declared columns present and typed |
| `:image` | engine buffer + `width`, `height`, `format`, `colour-space` | dimensions > 0; buffer length = w·h·channels |
| `:audio` | engine buffer + **`sample-rate`**, `channels` | **the rate travels with the samples.** (Sound plane, 2026: speech played at double speed because the ring carried no rate. A parcel without a rate is a refusal.) |
| `:document` | an `stzDocument` handle (§15): pages → regions | every region has a kind, a box inside its page, an order |
| `:geo` | feature(s) in a declared CRS | CRS declared; coordinates in range for it |
| `:refusal` | the finding list | always valid; it is what a failed court returns |

A flow edge is legal only when the producer's output type equals the consumer's input type, or a declared **adapter** (a faculty of type `a → b` with a floor, e.g. `:text → :tokens`) sits between them. The check happens in `ResolvePlan()`, before anything runs.

### 3.3 Where falsehood is caught (C9 does not catch it)

C9 says it plainly: *a schema-valid lie validates.* A parcel inherits that limit; this design adds **four** places where a lie can be caught, none of which is a court:

1. **The quality golden set** (§9.2): an implementation's measured score on a deterministic checker. A model that does not beat the floor is never auto-selected.
2. **The calibration ledger** (§9.3): confidence versus outcome over time. A higher band must be right more often than a lower one, or the guard fails.
3. **The witness** (`VerifyStageAgainstFloor("kind")`, off by default): runs the **floor** alongside the chosen model on the same input and records disagreement as a finding. This is Klaiber's dual-path witness (Compass WITNESS-04) applied to a stage.
4. **Admission** (§10): a model's parcel is a *proposal*. Anything that becomes knowledge or an effect goes through a gate or a knowledge-graph rule. *The model proposes, the validator decides* (§5.9).

---

## 4. The faculty

```ring
oFac = StzFacultyQ(:classify)
oFac.SetInputType(:text)
oFac.SetOutputType(:label)
oFac.SetParams([ :labels = [] ])
oFac.SetFloor("naive-bayes+keywords", fFloor)      # REQUIRED at declaration; a faculty without a floor is refused
oFac.AddGolden(oGoldenSet)                         # REQUIRED before any model may be auto-selected
oFac.AddImplementation(oModelImpl)                 # zero or more
# or chained:  StzFacultyQ(:classify).SetInputTypeQ(:text).SetOutputTypeQ(:label).SetFloorQ(...).AddGoldenQ(...)
```

A faculty is **declared once and judged at declaration** (the C9 §3.4 discipline): a missing floor, an unknown type, or an implementation whose declared `In`/`Out` disagree with the faculty's **raises before anything runs.**

### 4.1 Implementation kinds

| kind | what it is | capability (the lattice of the Governance page) | selected implicitly? |
|---|---|---|---|
| `:floor` | deterministic Ring/Zig code; no model | `compute` | yes — it is the fallback of last resort and the baseline |
| `:model` | a local GGUF run by the engine (`neural_gen`, `neural_embed`) | `inference` | yes, **if** measured and it beats the floor |
| `:dlm` | a Foundry domain model (`.zdlm`); rung-1 is a floor, rung-2 a model | `inference` / `compute` | yes, same rule |
| `:service` | an external process or endpoint (e.g. `docling-serve`, a Jev-class API) | `sensing`, posture `:local` or `:live` | **never.** Only when pinned by name. LAW 2: nothing remote is ever required or implicit. |

An implementation declares: `id`, `version`, `kind`, `In`/`Out`, `Languages`, `Memory` (MB), `Latency` class, `Licence`, `Deterministic` (1 if a fixed seed reproduces), and — when it is a model — `file`, `sha256`, `arch`. Everything in that list is **data**, readable by `Ask()`.

### 4.2 The floor is not a stub

Each floor in §13 is an algorithm Softanza already ships, or a short one the survey names. Where a domain has **no floor** today (PDF text, mel features, time-series forecasting, content classification below), the faculty is declared with `Floor` = *"refuses, naming what is missing"* — a floor that says *"I cannot"* is honest, is a valid floor, and is the first thing a model must beat. It is not a hole in the design; it is a hole in the library, and the catalogue (§13) is where it is counted.

### 4.3 Naming: a method that acts must read as an action

The rule (the author, 2026-10-21, correcting an earlier draft that wrote `oF.Stage(...)` — which could mean *set*, *get* or *declare*): **a method that changes the object is named with an active verb**, and Softanza's three forms apply as everywhere else.

| form | name | does |
|---|---|---|
| active | `AddStage("kind", :classify)` | mutates; returns nothing |
| fluent | `AddStageQ("kind", :classify)` | mutates; returns the object, so calls chain |
| data | `Stages()`, `StageNamed("kind")` | returns data; never an object |
| passive | `WithStageAdded(...)` / `PinnedStage(...)` | returns a modified **copy**; the original is unchanged |

| earlier draft | now |
|---|---|
| `Stage(...)` | `AddStage` / `AddStageQ` |
| `Connect(a, b)` | `ConnectStages` / `ConnectStagesQ` |
| `Pin(...)`, `PinSet(...)` | `PinStage`, `PinStageToSet` (+ `Q`) |
| `Policy(...)` | `SetStagePolicy` |
| `Deterministic()` | `UseFloorEverywhere()` (the question is `IsDeterministic()`) |
| `Plan()` / `Check()` | `ResolvePlan()` (data) / `CheckRules()` (data: findings, as `stzGraph` already names it) |
| `Run(x)` | `Run(x)` returns the **value** (data), `RunQ(x)` the **parcel** object |
| `In(...)`, `Out(...)`, `Params(...)`, `Floor(...)`, `Golden(...)`, `Implementation(...)` | `SetInputType`, `SetOutputType`, `SetParams`, `SetFloor`, `AddGolden`, `AddImplementation` (+ `Q`) |
| `Quality(...)`, `Latency(...)`, `Memory(...)`, `Languages(...)`, `Locality(...)`, `Licence(...)` on a requirement | `RequireQuality`, `RequireLatency`, `RequireMemory`, `RequireLanguages`, `RequireLocality`, `RequireLicence` (+ `Q`) |
| `Using("x")` | `UseImplementation("x")` (+ `Q`) |
| `Verify()` on a stage | `VerifyStageAgainstFloor` |
| `Resolve(req)` | `Resolve(req)` returns the plan as data; `ResolveQ(req)` the `stzModelPlan` object |

The names in the later sections are this table's right-hand column. A name that cannot be read as a verb, or that a reader could take for an accessor, is a defect to report.

---

## 5. Requirements choose the model — and the inverse

```ring
oReq = StzRequirementQ(:classify).
          SetInputTypeQ(:text).SetOutputTypeQ(:label).
          RequireQualityQ(:good).        # :any | :good | :best — or a number: at least 0.80 on the golden set
          RequireLatencyQ(:interactive). # :batch | :interactive | :realtime — mapped to ms budgets in the registry
          RequireMemoryQ(2048).          # MB the implementation may hold resident
          RequireLanguagesQ([ "fr", "ar" ]).
          RequireLocalityQ(:local).      # :local (default) | :allow-service
          RequireLicenceQ(:permissive)

oPlan = StzModelRegistryQ().ResolveQ(oReq)
? oPlan.Chosen()      # data: the implementation, or :floor
? oPlan.Why()         # data
```

### 5.1 How `Resolve` decides — a deterministic procedure, printed in full by `Why()`

1. **Candidates**: implementations of the faculty whose types match.
2. **Hard filters**, each one recorded when it removes a candidate: not installed (file absent); locality; licence policy; language not covered; memory budget; capability not permitted in this context (§10); `Deterministic(1)` and the implementation is not.
3. **Quality gate**: an implementation is eligible only if the registry holds a **measurement** for it on this faculty's golden set (§9.2) and it is **≥ the requested quality and ≥ the floor's own measured score.** An implementation with no measurement is *unknown*, not *good*: it is never auto-selected. (This is the rule *a model that does not beat its floor earns no place*, enforced by the registry rather than by taste.)
4. **Rank** the survivors: higher measured quality; then lower resident memory; then lower latency; then name (a stable tie-break — LAW 3: a tie is reported, not hidden).
5. **Fall back** to `:floor` if nothing survives, **and say so**, unless the requirement says `RefuseBelow(:good)`, in which case the plan is a **refusal** naming the filter that emptied the list.

```
Why():
  classify  → qwen2.5-coder-1.5b (kind :model)
    rejected: smollm2-135m        measured 0.31 < floor 0.62
    rejected: granite-4.0-1b      not installed
    rejected: glotlid-v3          wrong faculty (:detect-language)
    chosen:   qwen2.5-coder-1.5b  measured 0.85 on golden v3 (n=40) ≥ floor 0.62 and ≥ requested 0.80;
                                  1.9 GB ≤ 2.0 GB budget; fr ar covered; Apache-2.0
    floor kept: naive-bayes+keywords (0.62) — used if the model is unavailable
```

### 5.2 The inverse is first-class

| Scope | Pin | Effect |
|---|---|---|
| one call | `oFac.UseImplementationQ("granite-4.0-1b").Run(x)` | that implementation or a refusal; **never** a silent substitute |
| one stage | `oF.PinStage("kind", "granite-4.0-1b")` | the flow's stage |
| a set | `oF.PinStageToSet("kind", [ "a", "b" ])` | the registry picks within the set by §5.1 steps 3–5 |
| a policy | `oF.SetStagePolicy("kind", :cheapest)` / `:best` / `:floor` | re-ranks, does not bypass the quality gate unless `AllowUnmeasured()` is also said |
| a flow | `oF.UseFloorEverywhere()` | every stage on its floor |
| the process | `StzModelPolicy(:deterministic)` or `STZ_MODELS=off` | no model is loaded by anything, including the implicit hooks of §8 |

A pinned implementation that is unmeasured **runs** (the programmer asked) and the parcel's evidence says `:unknown`. The registry never overrides a pin; it only says what it cost.

---

## 6. The flow

A flow is a **`stzGraph`** whose nodes are faculty applications and whose edges are parcels. That is not a metaphor: `stzFlow` composes `stzGraph`, so cycle detection, reachability, and the rule gate (`stzRuleReport`, one gate over six domains) apply without new machinery (LAW 5).

```ring
oF = StzFlowQ("read-and-brief")
oF.AddStageQ("pages",  :document-pages).                  # bytes → document
   AddStageQ("kind",   :classify, [ :labels = ... ]).
   AddStageQ("facts",  :extract,  [ :schema = oS ]).
   AddStageQ("brief",  :summarise).
   ConnectStagesQ("pages", "kind").ConnectStagesQ("pages", "facts").   # fan-out
   ConnectStagesQ("facts", "brief")                                    # fan-in is explicit
```

- **`ResolvePlan()`** resolves every stage and returns the plan **without running anything**: types checked on each edge, implementations chosen, memory summed (a flow whose stages cannot all be resident says so and proposes an eviction order, §11), budgets aggregated.
- **`CheckRules()`** is `ResolvePlan()` plus the rule gate (§10) — the name `stzGraph` already uses; it is what an agent runs before committing.
- **`Run(x)`** (value) / **`RunQ(x)`** (parcel) executes in topological order; a stage that **refuses** stops its branch and the flow returns the refusal parcel with the partial provenance — never a half-built value.
- **Substitution test (the contract of requirement 8)**: `oF.ResolvePlan()` and `oF.Run(x)` are valid for any pinning, including all-floor. The `Run` result's **type** is identical in every pinning; only provenance, evidence, cost, and (measurably) quality differ.
- **Fan-out is parallel questions.** Several stages reading one input share the prompt prefix through the engine's append path (a KV prefix reused, not recomputed) — the Jev-class "many typed questions, one pass" shape, built on what `neural_gen_start_x(reset=0)` already does.
- A flow persists to `.zfac` (LAW 1) — declarative, diffable, judged on load like `.pia`.

---

## 7. The decision port (COMPASS-JEV-DECISIONPORT-01) and calibrated decisions

Choice, Score and Noul are not a new subsystem; they are **three faculty shapes** whose output types already exist in §3.2.

| shape | in → out | the engine-side implementation |
|---|---|---|
| `:decide-choice` | `:text` (+ options) → `:label` + per-option `p` | **read the next-token distribution over the option strings** (restricted to the options' first tokens) — one forward pass, no sampling, no parsing |
| `:decide-score` | `:text` → `:score` in an ordered band | same, over the band's labels |
| `:decide-noul` | `:text` + statement → `:score` in [0,1] | the probability mass of "yes" vs "no" at the answer position |

Their floors are the lexical/ML classifiers Softanza already has (kNN, naive Bayes, logistic regression, rules). Their model implementations need one engine addition that is not built yet — **E3 in the survey: read the logits of chosen tokens after a prompt** (also what Qwen3-Reranker needs). `stzDecisionPort` is the *faculty family* of these three, with the three service postures the service plane already has (`:sandbox` refuses production). A Jev-class endpoint is a `:service` implementation of the same family — allowed only when pinned, posture `:live`, never implicit. Budget, goldens, and memoisation come from `stzLLMFunction` unchanged.

---

## 8. Implicit and explicit use

**Explicit** is §5.2. **Implicit** is the case the author named: *the user does not know a model is used; Softanza analyses the context and decides.* Five places in the library already analyse context and already choose between a floor and a model by hand:

| hook | today | what routing replaces |
|---|---|---|
| `stzText` quickers — `Classify`, `Embedding`, `SemanticSimilarityWith`, `SummarizedAbstractively` | each tests `StzHasGenerativeModel()` / `HasSemanticModel()` and falls back to a lexical result (verified in `base/linguistic/stzText.ring`) | one resolution through the registry, same fallback, now explained and traced |
| `Ask` / `HowTo` / `ExplainMethod` (`stzLibDoc`) | lexical IDF first, a neural rescue only when lexical finds nothing | the rescue tier becomes `:retrieve` with its floor |
| `stzNatural` / `Naturally(...)` / NNL chains | resolves language-as-code through the ONE lexicon, no model | optional `:interpret` faculty; lexicon stays the floor and the arbiter |
| `stzSemanticIndex.Search` | embeds with whichever model is resident | `:embed` + `:rerank` faculties |
| `stzNeuralChat`, abstractive text ops | assumes one generative model | `:chat` / `:summarise` |

**Rules for every implicit use — these are the "never a surprise" guarantees:**

1. **The requirement is derived from context, visibly.** Input language (a `:detect-language` faculty, floor = the engine's detector), input length (→ a latency/memory class), whether a model is already resident (preferred: no cold load for a one-line call), the caller's declared strictness. The derived requirement is part of the trace.
2. **Every implicit resolution is recorded** in the model trace (`StzModelTrace()`, ring buffer + the calibration ledger when outcomes are known) with `implicit = 1`, the requirement, the chosen implementation, and `Why()`. No stdout noise; readable on demand.
3. **A model is loaded implicitly only if it is already installed, measured, within the memory budget, and `STZ_MODELS` is not `off`.** There is no implicit download, ever.
4. **No remote call, ever, implicitly** (LAW 2). `:service` implementations are invisible to implicit routing.
5. **One switch turns it all off**: `StzModelPolicy(:deterministic)` — every hook then resolves to its floor, which is exactly today's no-model behaviour. This is also the infrastructure downgrade: a CI machine, a locked-down server, a unit test.

---

## 9. Substitution, downgrade, and the contract that makes them safe

### 9.1 Why "swap without changing the solution" is true

Because the flow names a **faculty** and a faculty fixes the in/out types and the court. Any implementation — floor, 135M model, 3B model, a Foundry DLM — returns a parcel the same court accepts or a refusal. What a swap changes is **provenance, evidence, cost and measured quality** — all in the parcel — never the shape the next stage consumes.

### 9.2 The golden set every implementation runs, the floor included

A faculty owns a **golden set**, in two parts, run by `RunGoldens()` (the existing `stzLLMFunction` mechanism, generalised):

- **Conformance goldens** (must pass 100%, for *every* implementation including the floor): output type valid; refuses rather than guesses on out-of-domain input; reproducible under a fixed seed when it claims `Deterministic`; respects `Languages`.
- **Quality goldens** (scored): 10–40 items with a **deterministic checker** — an exact match, a regex, a numeric tolerance, a program run on hidden data (the K4 shape: `printed the shown answer` fails). **No LLM judge.** The floor is scored first; its score is the bar.

The registry **stores the score per implementation per golden-set version**, with the date, the model file's sha256, the hardware throttle state, and the sample size. A changed golden set or a changed model file **invalidates the measurement** (a different `key`); the implementation is *unknown* again until re-measured.

**Measured per language (ruled by the author 2026-10-30, OCR-PERLANG-01).** A faculty may name the input field that holds a golden's language (`SetGoldenLanguageKey(:lang)`). `RunGoldens()` then files, beside the whole-set row, one row per language under the golden version `"<version>/<lang>"` (two-letter code: `v2/ru`), and a call that names exactly one language -- in its requirement, or else in its parameters or input under that key -- is resolved on **that language's rows alone**: the floor's bar and every model's score come from the same items, and a model may answer one language while the floor keeps another. A call with no language, or in a language the golden set has no items for, is judged on the whole set, and the plan says which it did. The cause was `:ocr` (`SOFTANZA_OCR_MEMO.md`, O3c): the platform engine wins Arabic, PP-OCR wins Russian (the platform has no pack), French is a tie -- and a single mixed set could only ever pick one of them. Guard without any model: `base/test/faculty/faculty_perlang_narrated.ring`.

### 9.3 The calibration ledger (COMPASS-JEV-CALIBRATION-01)

Evidence in a parcel is `certainty` (certain/probable/apparent) and optionally `p`. The ledger records, per implementation: `(band, p, outcome)` whenever an outcome becomes known (a golden item, a human correction, a downstream court). It is **append-only and hash-chained** like `stzSecurityLedger` (`Verify()` names the first broken link). A narrated guard **fails** when *a higher band is not more accurate than a lower one* for any implementation with enough samples, and the **reliability diagram is rendered** by the plot plane — the render is the instrument (the project's own rule: numbers pass while pictures are wrong). Every faculty on the ladder — deterministic or learned — writes to it, so "certainly / probably / apparently" stops being vocabulary and becomes a measured property.

**Built (stzCalibration.ring, `calibration_narrated.ring` 14/14)**: the ledger is filled by `RunGoldens` whenever an answer carries a probability (the choice-by-probability implementations do); `StzCalibrationFindings` fails with `calibration-inverted` when a higher band is right less often than a lower one, and only *warns* (`calibration-thin`) on a band with too few answers to judge; `StzReliabilityText` prints the table. **Not yet built**: the hash chain, and the plot-plane render of the reliability diagram (the design's own rule — the render is the instrument — still owes it).

**A first real reading** (Qwen2.5-Coder-0.5B reading the ticket kind by probability, 36 held-out tickets): the answers given with p ≥ 0.75 (n = 7, mean p 0.83) were right 86 % of the time; the rest (n = 29, mean p 0.57) 59 %. Its confidence is, on this small sample, **well calibrated** — which suggests a *cascade* implementation (answer with the model when its probability clears a threshold, else the floor). A quick offline probe gave 0.75 against the floor's 0.69 at a threshold of 0.75, i.e. two items of 36, with the threshold chosen on the same set: **a hypothesis, not a result.** A cascade would need its threshold fixed on a separate dev split and measured on the golden set; it is the next experiment, not a built feature.

### 9.4 Downgrade

`PinStage(name, :floor)` on a stage, `UseFloorEverywhere()` on a flow, `StzModelPolicy(:deterministic)` for the process. The floor of each faculty is the thing that runs. Because floors are part of the contract (§4), downgrade never fails for want of an implementation — it can only *refuse by naming a missing capability*, honestly (§4.2).

---

## 10. Governance and agents

- **A model is a non-effectful faculty.** Its capability is `inference` (the lattice of the Governance page: `effectful / sensing / compute / inference`). Granting `effectful` to a model implementation **raises at construction**, the same refusal `Grant` gives an LLM actor today. A flow's *effect position* (the node that causes an effect) may only be reached through a gate; a model-kind implementation in that position is a rule violation.
- **The new rule family** goes into the existing gate in the unified finding shape, subject `"model-flow"`: `model-in-effect-position`, `service-not-pinned`, `unmeasured-auto-selected`, `floor-missing`, `type-mismatch-on-edge`, `golden-set-missing`. `CheckRules()` returns them; `stzRuleReport.Ingest()` takes them — **one gate, seven domains**.
- **The gate judge (COMPASS-JEV-GATEJUDGE-01)**: a decision faculty used inside a pi-gate has capability **`sensing`**; its output type is a `:risk-tier` parcel whose only legal transitions are **upward** (`raise`) or `route-human-checkpoint`. The gate exposes `AcceptJudgement(parcel)`, which accepts nothing that lowers a tier or grants a capability — **there is no API by which a model can make the gate more permissive.** Governance by construction gains a calibrated sense without surrendering what made it governance.
- **The responder restriction** (Compass THREAD-06: *"the LLM function's responder [be] restricted to an LLM actor so 'zero capabilities' is enforced; today any-responder"*): a faculty's `:model` implementation is constructed with a capability set; a responder not holding `inference` is refused.
- **Agents (LAW 6).** `oF.Ask("what does stage kind do?")`, `oF.WhatIs(...)`, `oF.ExplainQ()` answer from the declaration (the harvested-prose mechanism of `meta/`). `CheckRules()` is the machine-checkable gate an agent runs before it commits a flow. A flow file (`.zfac`) is **judged at load**, with the refusal sentences quoted from the code, like `.pia`.

---

## 11. Resources — residency, memory, CPU/GPU

**Today**: the engine holds **one** model. `neural_model_load()` frees the previous (`neural_embed.zig`), and the tokenizer, KV cache, grammar and sampler state are process globals (about 40 across `neural_embed.zig` and `neural_gen.zig` — enumerated in Part A's A5 note). Part C needs embed → rerank → generate in one flow.

**The design (A5)**: a **residency manager** with named slots, a memory budget and an eviction policy.

- A **slot** holds one loaded model with its own tokenizer state and KV cache. Roles: `:embed :rerank :generate :ner :asr :vision`. Slots are cheap to describe, expensive to hold.
- **Budget**: `StzResidencyBudget(MB)`, default = a fraction of free RAM; **never** above physical headroom (this machine freezes under memory pressure; the CLAUDE.md caps bind). The budget counts weights **plus the measured peak of the largest forward** (the pool is now measurable: `StzLastGenerationPoolBytes()`; peak working set of the Qwen 1.5B was 4.0 GB at a 505-token prompt with chunked prefill).
- **Eviction**: least-recently-used among unpinned slots; a slot used by a flow in progress is pinned for that run. `ResolvePlan()` reports the eviction order before `Run`.
- **Implementation path (smallest that is safe)**: the engine's per-model state is a bounded set of globals. A slot swap that saves and restores that set as one struct gives multi-model residency **without touching the forward-pass code.** The risk is a global that is missed (cross-model leakage of a tokenizer or cache), so it ships with a guard that loads A then B then A and checks A's answers are byte-identical. **Not implemented in this pass** — it touches the shared engine in a way the author should see designed first (§17, question 4).
- **Load cost is part of the plan**: loading the 1.9 GB 1.5B is seconds-to-minutes on this machine; a flow that alternates two big models pays it each time. `ResolvePlan()` prints the cost; the planner prefers a resident model for a one-line call (§8, rule 1).

**GPU** (A4, recommendation only): this machine has an **NVIDIA GeForce RTX 3050 6GB Laptop GPU (driver 561.00)**. The vendored ggml is **CPU-only** by construction (`build.zig`: "vendored ggml (CPU-only)"; GPU backends pruned). Softanza already has its own GPU path — the **wgpu** plane (`stz_gpu`, WGSL kernels, a measured calibration foundry) — and a seam in the patched `traits.cpp` that forwards large `MUL_MAT` nodes to it. A ggml **CUDA** backend would need the CUDA toolkit to build and ship NVIDIA runtime DLLs: against sovereignty. A ggml **Vulkan** backend needs a SPIR-V shader generator and `vulkan-1.dll` at runtime (present with a driver) and does not run where there is no Vulkan. **The CPU baseline, measured (A4, 2026-10-21 evening, `_probe_speed.ring`):** Qwen2.5-Coder-1.5B Q8_0, grammar off, minimum of three repetitions, CPU at **156 % of nominal before and 142 % after** (so *unthrottled*; `bench/heartbeat.py` exit 0): **prefill 38.5 tokens/s** (505 tokens in 13.1 s) and **decode 17.6 tokens/s**. For comparison the same prefill took ~127 s while the firmware held the CPU at 42–57 % and other jobs ran — about **ten times slower**: on this machine the throttle state moves every timing by an order of magnitude, which is why every earlier wall time in this work is labelled throttled and not quoted. With the constrained decoder on, a decode step costs about 0.7 s more on a 150 k-token vocabulary (≈ 76 k candidates judged per step, measured throttled).

**What a GPU could buy, as bounds not measurements** (RTX 3050 6GB Laptop: ~170 GB/s memory bandwidth, ~5–9 TFLOPS fp32; a 1.5B Q8 model is 1.9 GB): decode is bandwidth-bound, so at best ≈ 170 / 1.9 ≈ **90 tokens/s, about 5× the CPU's 17.6**; prefill is compute-bound at ≈ 3 GFLOP per token, so at best **hundreds to ~1,500 tokens/s, 10–40× the CPU's 38.5**. These are ceilings, not predictions: real kernels reach a fraction. The numbers say where the GPU would pay: **prefill (long prompts, documents, few-shot) first, decode second.**

**Recommendation, pending the author's yes (the delegation covers it in principle; nothing is built)**: extend the existing wgpu plane with resident quantised weights and a Q8_0 matvec/matmul kernel, because it (a) adds no vendored runtime, (b) already degrades to CPU when no adapter exists — LAW 2's floor, (c) is where the calibration foundry already routes by *measurement*. Prefill (compute-bound) benefits most; decode (bandwidth-bound) a 1.5B Q8 fits comfortably in 6 GB.

---

## 12. What Part A changed, because this design stands on it

| Change | Evidence | Why this design needs it |
|---|---|---|
| The pool is sized from the graph (`2f5dd6c33`) | the 1.5B could not answer a 40-token prompt; now loads and answers at 505 tokens | a registry that selects the 1.5B must be able to run it |
| The prompt is prefilled whole, bounded by the context, refused when too long, never trimmed (`9c7514fc4`) | PINEAPPLE probe passes at 1,233 and ~2,000 tokens; failed at 1,163 before | a flow that passes a long parcel (a document, a retrieved context) must not lose its head silently |
| Termination aids (`13ea45735`) | `engine_termination_narrated`, 20/20 | a faculty over a grammar must be able to end |
| `StzLastGenerationPoolBytes`, `StzLastPromptTokens`, `StzLastGenerationTruncated`, `StzTokenCount`, `StzModelContextWindow` | exported to Ring | the `cost` field of a parcel and the memory term of `Plan()` |

Owed from Part A: **A3's measurement** (what each option buys and hurts on the K4 twenty tasks — running), **A4's CPU baseline timing** (to be taken unthrottled), **A5's implementation** (§11, awaiting the author).

---

## 13. The faculty catalogue — domain by domain, floor beside model

*Verified on live model cards 2026-10-21 by the survey agents; sizes are the cards' file sizes; "engine" says whether the engine runs it today. **No model below has yet been measured against its floor** — the golden sets are specified, not built, and downloads need the author's yes. A model earns its row in the registry only by that measurement.*

Legend — **E1 — DONE (98d5eb732)**: Qwen3 now runs. It needed two things, not one: the per-head Q/K RMSNorm *and* a head width that is not hidden/heads (Qwen3-0.6B: hidden 1024, 16 heads, head_dim 128 — the engine derived 64 and aborted). Qwen3-0.6B-Q8_0 answers correctly (13/13 narrated, behavioural; a numeric reference is still owed). **E2 — DONE (703cfc051)**: `granite` runs (llama graph + four scalars); Granite-4.0-350m-Q8_0 9/9. It also taught the decoder to read a per-layer array of one repeated value and to **refuse**, rather than crash on, a mixture-of-experts, hybrid or irregular stack — the granite family shares the arch string across all of these. **E3** read chosen-token logits + last-token/CLS pooling. **E4** SentencePiece-unigram tokenizer (Viterbi). **E5** N-class sequence-classification head. **E6** per-arch ports (phi3, mistral3, smollm3, …). **E7 — NOT NEEDED**: k-quants run (see §17).

| Faculty (in → out) | Floor today (file) | Candidate models (licence, size, arch) | Engine today / work |
|---|---|---|---|
| `:chat` / `:summarise` / `:classify` / `:extract` (text → text/label/record) | `stzText` extractive summary, lexical classifier, regex/rule extraction; `stzLLMFunction` for typed output | **runs today**: SmolLM2-1.7B (Apache, 1.70 GiB Q8), Qwen2.5-1.5B (Apache); **runs now (E2 done)**: Granite-4.0-350m (verified); 1b, 4.2-3B (Apache, same arch — the 3B-class files may be hybrid and would be *refused*; check `granite.expert_count` / `ssm.*` first) (Apache, official GGUF 0.22–2.1 GiB Q4_K_M, 12 languages incl. fr, ar); **runs now (E1 done)**: Qwen3-0.6B (verified), 1.7B/4B-2507 (Apache; same arch, not yet loaded) | measured: 135M and 0.5B ≈ 0 on code tasks; **1.5B first model that computes (5–6/20)** — size decides, not the decoder |
| `:embed` (text → vector) | lexical TF-IDF / hash similarity | all-MiniLM-L6-v2 (in use); **E1 done, E3 owed**: Qwen3-Embedding-0.6B (Apache, multilingual); **after E4**: multilingual-e5-small (MIT, tags Hausa), bge-m3 (MIT); LaBSE (Apache, WordPiece, **tags Hausa/Yoruba/Arabic/French**, needs CLS+Dense) | BERT-family: yes. Multilingual: E3/E4 |
| `:rerank` | lexical IDF (beat the English reranker 19/30 vs 15 on its own benchmark, per the Docs page) | jina-reranker-v1-turbo-en (in use); **after E4**: bge-reranker-v2-m3 (Apache); **E1 done, E3 owed**: Qwen3-Reranker-0.6B (Apache) | as above |
| `:detect-language` | the engine's detector: 6 languages + Arabic script | **GlotLID v3** (Apache + notices, 1.6 GB fastText; Zarma `dje_Latn` F1 0.994, Hausa 0.989); CommonLingua (Apache, 2.35M params) | fastText inference is a bounded pure-Zig reader (no ggml); not built |
| `:translate` | **none** | NLLB / Jina v3 / fastText-langid are **CC-BY-NC — excluded**; Opus-MT/Marian licence not verified | no floor; no permissive candidate verified — an honest gap |
| `:ner` | gazetteer + POS-chunk + rules, four types, English | bert-base-NER (in use, MIT); Masakhane NER (Hausa F1 88.7 — **no licence declared; not adoptable**); GLiNER (Apache but DeBERTa) | BERT-family: yes; DeBERTa: no |
| `:sentiment` | VADER, English | lxyuan multilingual distilbert (Apache; fr, ar); nlptown (MIT; no Arabic) | after E5 |
| `:code` (text → program) | the engine computes; the K4 test is the oracle | Qwen2.5-Coder-1.5B (Apache, runs); Qwen3-4B-2507 (Apache, runs now); Granite-4.2-3B (Apache, runs now if dense); **Qwen2.5-Coder-3B is `qwen-research`, not Apache** | see chat row |
| `:maths` | exact arithmetic tower, autodiff, simplex — **the oracle, not a competitor** | DeepSeek-R1-Distill-Qwen-1.5B (MIT, qwen2, runs; emits long `<think>`) | runs |
| `:forecast` (series → series) | **no forecasting**: moving average, OLS, FFT, z-score only | TTM r3 (Apache, 1.4M params, MLP-mixer), Toto-2.0-22m (Apache, decoder-only, quantile head); **TimesFM 3.0, TabPFN ≥ 2.5 are non-commercial** | TTM: new graph; Toto: closest to the decoder |
| `:tabular-predict` | kNN, logistic, ID3, k-means, naive Bayes (text only) | TabICL (licence unverified) | none; the floor is weak, so "beats the floor" is an easy bar — compare to a real GBM offline |
| `:text-to-record` / `:text-to-sql` | `stzOutputSchema` + `stzLLMFunction`; **no deterministic NL→SQL** | NuExtract-2.0-2B (MIT, needs `qwen2vl` string accepted for text-only) | small |
| `:guard` (content security) | structural rules only; **no content classifier** | Qwen3Guard-Gen-0.6B (Apache, qwen3 — runs now); Llama Prompt Guard/ProtectAI: DeBERTa, or Llama licence — blocked | E1 |
| `:geocode` | country-name resolution; fuzzy parts exist unassembled | **no model earns a place** | assemble the floor first |
| `:transcribe` (audio → text) | SAPI closed-grammar commands (100%); dictation 66.7% — **fails its own gate** | **whisper.cpp** (MIT, ~520 KB source, also runs Parakeet); **Qwen3-ASR-0.6B** (Apache, fr + ar, Qwen3 decoder) | vendor (C++ static-init trap, 3 file-scope maps); Qwen3-ASR needs an audio encoder, embedding injection and a 2nd slot |
| `:speak` (text → audio) | SAPI voices (Zira en, Hortense fr); no Arabic measured | **none permissive**: Piper successor GPL-3, kokoro.cpp links espeak-ng (GPL), Supertonic OpenRAIL-M | no neural TTS now |
| `:ocr` (image → text) | none in-engine; `Windows.Media.Ocr` measured: fr exact, Arabic splits words | Tesseract (Apache, fra/ara ~1.1/1.4 MB), PP-OCRv6 (Apache, ONNX); **Indra / Surya / Chandra: weights licence is a revenue-capped OpenRAIL-M ($20M / $5M / $2M) — not permissive, off the default path** | Tesseract vendorable (C++); others need new graphs |
| `:describe-image` / `:doc-vlm` | none | **Granite-Docling-258M, SmolVLM-256M (Apache)**: decoder = exactly the SmolLM2-135M shape; only the SigLIP tower + connector missing | vision tower + embedding-injection entry |
| `:document` stages | **no PDF reader, no OOXML parser**; zip and XML exist | Docling stack (MIT code; layout-heron Apache; Granite-Docling Apache) | see §15 |

**The first fact the table gives**: of ~20 faculties, the engine runs models for **four today** (chat family, embed, rerank, NER-English) — and, since E1 and E2, the **Qwen3 and Granite chat lines too**. E3+E4 are the remaining small engine changes that unlock multilingual retrieval; vision, audio and documents need new graph code (§15).

---

## 14. Proposed shape, and the first vertical slice

### 14.1 The domain (a proposal to Central, not yet created)

`base/faculty/` — entry objects `stzFaculty`, `stzFlow`, `stzParcel`, `stzRequirement`, `stzModelRegistry`; formats `.zfac` (faculties + flows), `.zmdl` (installed models + measurements). Plane owner: stzlib-intelligence. **Creating a top-level folder under `base/` needs the author's yes (the prompt says to ask).** Alternatives I considered and rejected: `base/model/` (reads as the models themselves, not the routing), `base/flow/` (collides with the existing `.flow` workflow format).

### 14.2 The slice (built only after the author has read this)

Three flows, each green with the floor alone and with a model, narrated, skipping without the model:

1. **Retrieval**: `:embed → :rerank` — today's chain, now two faculties. Floor = lexical IDF.
2. **Text → record**: `:extract` with `stzLLMFunction` (Qwen2.5-Coder-1.5B) against a regex/rule floor, C9 as the court.
3. **Three stages**: `:classify → :extract → :summarise`, one stage pinned to its floor, the result still validates (substitution, requirement 8).

For each: report the quality score floor vs model on a golden set with a deterministic checker, the cost, and **what the choice hurts**. The slice needs, from the engine: A5 (or load-swap, measured), and nothing else.

---

## 15. Document intelligence in the flow (the Part D hook; the decision memo is separate)

A `:document` parcel is an `stzDocument`: **pages → regions**, each region with `kind` (`text title list table figure formula header footer`), a `box`, a reading `order`, and per-kind content (`text`; a table `grid` of cells with spans; a figure `caption`). The Docling pipeline decomposes into faculties with this exact shape: `bytes → pages → regions → { table grid | reading-order text | figure caption } → stzDocument → C9 extraction and summaries downstream`.

| stage | floor | model implementation |
|---|---|---|
| `:document-pages` (bytes → pages + text layer) | **a native Zig PDF content-stream reader** (text + positions) — *does not exist today* | — |
| `:document-layout` (page → regions) | heuristics over text positions (line grouping, columns, headings by size) | RT-DETR layout detector (Apache, 42.9M) — conv/transformer detector: missing graph code |
| `:document-table` (region → grid) | ruling-line / alignment heuristics | TableFormer (licence tag ambiguous on the card) |
| `:ocr` (image region → text) | `Windows.Media.Ocr` (platform), Tesseract later | Granite-Docling-258M as an all-in-one VLM (Apache) |

The recommended minimal slice, and the baselines, are in the **Part D decision memo**; the headline is the same as the table's: **the floor is the first thing to build**, and it is a PDF text-layer reader, not a model.

---

## 16. What this design hurts, stated now

- **An indirection.** A call that was `StzGenerate(...)` becomes a resolution. Mitigation: memoised plans; the registry's decision for an unchanged requirement is a hash lookup.
- **A measurement burden.** Every faculty needs a golden set and every model a score before it is selected. This is the point (a model that does not beat its floor earns no place) and it is also real work: ~20 faculties × 10–40 items.
- **Floors are uneven.** Several are *"refuses"* (translation, PDF, mel features, content classification). The design makes the holes visible; it does not fill them.
- **Memory.** Multi-residency raises the footprint on a machine that freezes under pressure. The budget and the eviction plan exist for that, and the A5 swap ships only with the A-B-A leakage guard.
- **A new vocabulary** (parcel, faculty, flow, requirement) on top of an already large one. Mitigation: *faculty* and *LAW-2 faculty* are already the doctrine's words; *flow* extends `stzGraph`; *parcel* is the only new noun.
- **Implicit routing is the riskiest part.** Five hooks change from hand-written fallbacks to a registry call. They ship **last**, behind the trace and the switch (§8), and only after the slice proves the registry on explicit use.

---

## 17. The seven questions — DECIDED 2026-10-21, on the author's delegation

The author asked to *decide on my behalf for the best of Softanza robustness and usability.* Each answer below says which of the two it serves and what it costs. Any can be reversed by the author by saying so.

| # | Question | Decision | Serves | Costs |
|---|---|---|---|---|
| 1 | Folder and names | **Yes**: `base/faculty/`; `stzFaculty / stzFlow / stzParcel / stzRequirement / stzModelRegistry / stzModelPlan`; formats `.zfac` / `.zmdl`. The folder is created **with the first slice, not before**, and the proposal is in the mailbox for Central. Method names follow §4.3. | usability (one place to look; verbs that read as verbs) | one more top-level domain |
| 2 | A contract | **C10 Model Flow, extracted from the running slice** — not drafted ahead of it. C9 stays untouched. | robustness (C9 was extracted from code that runs; so is this) | the contract arrives after the code, not before |
| 3 | E1 and E2 before the slice | **Yes, in this order: E1 (Qwen3 q/k-norm) → probe the k-quant question → E2 (`granite`) → the slice.** E1 is a *correctness* question about code already shipped, so it comes first regardless. | robustness first (E1), then catalogue breadth | the slice starts a little later |
| 4 | A5 residency | **Staged.** Slice 1 uses **load-swap** (zero engine risk) and *measures* the swap cost; the slot-swap with the A-B-A leakage guard is built **only if** the measured cost justifies it. | robustness (the shared engine's ~40 globals are not touched on a hunch) | slice 1 pays swap time |
| 5 | Downloads | **Approved, small and vendor-sourced, in a directory outside the repository with the SHA-256 checked before use**: `Qwen3-0.6B-Q8_0.gguf` (Qwen/Qwen3-0.6B-GGUF, 639,446,688 B, Apache-2.0, sha256 verified) and `Qwen3-0.6B-Q4_K_M.gguf` (unsloth/Qwen3-0.6B-GGUF, 396,705,472 B). Further models are approved **one at a time, when a golden set exists for their faculty**, each stated with filename/source/size before it is fetched. **No Python or Docling install now**: the floor comes first (the memo's slice D1) and the disk has 11 GB free. | robustness (no blind multi-GB downloads) | measurement of the survey's candidates is staged |
| 6 | GPU | **The wgpu Q8 route** in principle; **not** a ggml CUDA or Vulkan backend. Built **after** the slice and after an unthrottled CPU baseline (A4), because without the baseline there is nothing to beat. | robustness (no vendored vendor runtime; falls back to CPU) | GPU waits |
| 7 | Datalab / Indra | **Agreed**: restricted-weights models stay off the default path, offered at most as an on-demand adapter that shows its licence. | robustness (no licence obligation ships by default) | none now |

**The k-quant assumption is settled**: Qwen3-0.6B-**Q4_K_M** loads and answers correctly (`engine_qwen3_narrated`, 13/13). The engine never de-quantises on load — ggml's own `mul_mat` reads the weights — so the survey's Q4_K_M sizes for 3–4B models stand and **no E7 is needed**. (The Neural-tier Compass page says quantisation is "consume-only F16/Q8_0"; that is out of date and belongs on the re-survey list.)

---

## 18. Compass updates this changes (to be requested of the Compass session, not edited here)

- **NLP & linguistics** page: lane 12 says the neural methods are *"no-ops without a loaded GGUF model"* and the ggml bridge is *"the one unstarted rung"*. The code shows a deterministic fallback in each (`HasSemanticModel()`; extractive `Summary()`; lexical `SemanticSimilarityWith`) and the engine's `neural*.zig` files exist. Re-rate lane 12 and drop the "unstarted" sentence.
- **Neural tier** page: lane 05 *decoder inference* — add that a prompt is no longer cut to 512 tokens, the 1.5B loads, and termination aids exist; add the open `qwen3` QK-norm question.
- **Jev** page: moves A, B and C now have a design home (§7, §9.3, §10); none is built.
- **Neural tier**, lane 10 (quantisation): consume-only F16/Q8_0 is out of date — Q4_K_M runs. Lane 05: Qwen3 and Granite now run; the engine refuses hybrid/MoE stacks.
- **Docs** page: the `Ask/HowTo` rescue tier is a faculty (`:retrieve`) in this design.

---

## 19. Versioning

| Version | Date | Change |
|---|---|---|
| `0.1` | 2026-10-21 | First design. No code. Read-only claims verified against the tree at the ref above; model facts from live cards read 2026-10-21; **no model measured against a floor yet.** |
