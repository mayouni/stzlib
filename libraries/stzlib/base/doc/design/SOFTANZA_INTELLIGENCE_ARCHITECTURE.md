# Softanza Intelligence Architecture
### The module map, the doctrine, and THE ONE ROADMAP for refactoring and enhancing the library
*(captured 2026-07-13 from the author's directive; unified 2026-07-13 -- this is the single source of truth that governs all module work)*

---

## 0. The Author's Intent, Distilled

Softanza should become **a reference for building intelligent applications with
ease**: advanced features at **no cost in time or money**, with the programmer in
**maximum control**. The current `/natural` + `/neural` split grew along the
milestones, not along the domains. This document fixes the architecture and
carries ONE unified roadmap (section 6) -- refactoring and enhancement are the
same movement, not two plans, running over FIVE FOUNDATIONS (section 5).

### 0.1 The North Star: the knowledgebase-driven system

The author's definition, which everything below serves:

> INTELLIGENCE is the computational ability to DERIVE NEW KNOWLEDGE from
> EXISTING KNOWLEDGE. And KNOWLEDGE is the modeling of information in
> GRAPH-BASED form, obeying DOMAIN-SPECIFIC SEMANTICS.

So the full equation is bracketed by knowledge on BOTH ends:

    KNOWLEDGE  ->  search + optimization + learning + rules  ->  NEW KNOWLEDGE

The middle is machinery; the ends are the point. This is why knowledge/ is
R1 and why the graph is the first foundation: the knowledge graph is not one
pillar among six -- it is the INPUT and the OUTPUT of intelligence, and the
other pillars are the derivation engine between them.

THE GOAL, STATED AS AN EXPERIENCE: a programmer -- or the business itself --
supplies a KNOWLEDGEBASE. A restaurant describes its business in a
*.zknw file: entities, relations, an ontology (domain-specific
semantics), rules. Feeding that ONE FILE to Softanza yields an
industrial-grade intelligent system: any app or solution for that
restaurant is then developed easily on top of a strong, dynamic,
WELL-GOVERNED BRAIN -- the knowledgebase. And the decisive property:
adding one fact or one rule -- by the user, the programmer, or an
intelligent agent -- AUGMENTS THE SYSTEM'S INTELLIGENCE AUTOMATICALLY.
No code change. No training. No RAG machinery. Derivation rules fire
(stzGraphRule), derived facts appear, plans recompute (the reactive
foundation), agents act on the new state.

Every needed mechanism already has verified machinery: ontology =
stzKnowledgeGraph.DefineClass/Property/Validate; governance = stzGraphRule
(Constraint/Derivation/Validation); currency = Computed/Watch (5.4);
decision = planner + optimizer (5.5); and stzApp already PROTOTYPED the
shape ("an application as a living world of meaning"). The roadmap turns
that prototype into the doctrine -- and section 6 ends with this scenario
as THE CAPSTONE TEST of the whole plan.

### 0.2 Programming the knowledgebase: every door Softanza owns

The knowledgebase is only as strong as the experience of AUTHORING it --
and that experience must serve programmers AND business owners alike.
Softanza does not need to invent it; it needs to point its existing
instruments (declarative programming, data orientation, the *.z-format
family, natural programming, conversational programming) at it. FOUR
DOORS, one governed brain:

1. THE DSL DOOR (declarative, data-oriented): *.zknw itself IS the
   program -- readable, diffable, hand-editable, validated on load.
   The format family doctrine (LAW 1): every stateful domain earns
   its format, and every Softanza extension is EXACTLY FOUR LETTERS:
   z (the Softanza mark) + a three-letter abbreviation (author ruling
   2026-07-14): .zknw / .zopt / .zcnv / .zdlm / .zrlz / .zrfn
   (legacy spellings still READ).
2. THE API DOOR (the programmer): stzKnowledgeGraph + Q chains --
   AddFact/Query/ontology, chainable, Why-accountable.
3. THE NATURAL DOOR: Naturally(...) / NNL chains / stzQuestion frames --
   knowledge spoken as language-as-code, resolved through the ONE lexicon.
4. THE CONVERSATIONAL DOOR (the organic rethink -> conversation/, R3b):
   a business owner TALKS the knowledge in; the system asks back
   (stzQuestion frames), validates against the ontology and rules
   (governance), and only then writes facts. Today's pieces grew apart --
   stzNeuralChat (neural/, a session over a model), stzQuestion
   (natural/, built), narration (a culture, not yet a class), goals
   (stzGraphGoal, referenced not built) -- the rethink reunites them
   as a domain of their own.

Whichever door is used, the SAME rules govern the same graph: four
surfaces, one brain. Adding through any door augments the intelligence
of every other door's view.

### 0.3 Wise Coding (the deliberate inversion of vibe coding)

The conversational door is what lets ANYONE -- not only programmers --
build intelligent systems in Softanza. And it works by INVERTING what
vibe coding does:

- In VIBE CODING, the human prompts and the machine guesses. Structure
  is whatever survives the guessing; the knowledge lives nowhere; the
  result is code you must trust without a brain behind it.
- In WISE CODING, it is SOFTANZA THAT ASKS THE USER. The system knows
  what a complete domain model requires -- the ontology and rules define
  the target shape -- so it measures the GAP between that shape and what
  it has heard so far, and turns each gap into the next well-structured
  question (stzGoal drives the elicitation, stzQuestion asks,
  stzNarration explains why it is asking). The conversation ASSISTS THE
  DESIGN of the solution, step by governed step -- and it ends with real
  artifacts: the .zknw knowledgebase WRITTEN, data in place, an
  OPERATIONAL intelligent system standing (the 0.1 north star).

The same fluency vibe coding is loved for -- but carried by the
structure and governed knowledge Softanza holds of ITSELF (meta/, LAW 6)
and of the DOMAIN (the knowledgebase). Guessing is replaced by asking;
vibes are replaced by governance. WISE CODING, not vibe coding.

THE ANSWER PROTOCOL (how a reply becomes knowledge). To any question
Softanza asks, the programmer or the owner may answer in FIVE registers:

1. one of the OPTIONS Softanza proposed;
2. a well-defined DATA STRUCTURE (hash literals, lists, tables);
3. a FORMULA or SCRIPT (the W-DSL expression, Ring code);
4. NATURAL or NEAR-NATURAL language (Naturally / NNL chains, resolved
   through the ONE lexicon);
5. EXAMPLES -- from which Softanza INFERS the pattern (induction over
   the ...ex family: Regex/Listex/Numbrex/Graphex) and builds a
   COMPUTABLE answer candidate.

Whatever the register, the candidate answer is EVALUATED against the
world graph and its rules (ontology + stzGraphRule) BEFORE it becomes
knowledge:

- UNIQUE acceptable answer -> accepted, written, narrated (Why);
- SEVERAL acceptable -> Softanza ENUMERATES them and the user chooses
  (informed choice, never a silent guess);
- NONE acceptable -> refusal with the reason and the nearest acceptable
  alternatives (LAW 3 applied to dialogue).

Every register lands in the same funnel: EXPRESSION IS FREE, ADMISSION
IS GOVERNED.

THE SOLUTION SPACE (how Softanza works out an answer). Analyzing a reply
or searching for a solution is itself intelligent work, and Softanza
brings its own machinery to it:

- SUPERPOSITION of candidates -- the stzQuanticRegexuter idea (documented
  vision: evaluate MULTIPLE interpretations SIMULTANEOUSLY, each carrying
  a contextual-probability weight): candidate answers are held in
  parallel, weighted, and COLLAPSED by the rules, the context, or the
  user's choice. The weights speak the evidential register's language
  (certainly / probably / apparently) -- ranked interpretations, never a
  silent guess.
- THE NATIVE AGENT STACK -- Softanza runs an agentic infrastructure OF
  ITS OWN: a well-designed, CURATED set of agents native to the library,
  working individually or collaboratively to bring a plausible solution
  (analyze the reply in every register, induce the pattern, validate
  against the graph, rank the survivors, plan the follow-up question).
  Programmers can add agents too -- but generally in the APPLICATION
  space; the native roster is a Softanza-designer decision (R5). The
  library is thus the FIRST CONSUMER of its own agentic/ module (LAW 5
  eating its own cooking).

### 0.4 The Engine and the Library (what Softanza IS)

Softanza is an ENGINE plus a LIBRARY. The engine (Zig) is PROGRAMMING-
LANGUAGE-AGNOSTIC: the library happens to be written in Ring -- the
REFERENCE implementation -- but nothing prevents rewriting the library
layer in Python or any other language over the same engine. The engine
is the invariant; libraries are projections. (This is also why the
products build on "the Softanza engine": they bind the engine, not the
Ring surface.)

And even within the Ring distribution, Softanza is POLYGLOT by design:
the extercode/ system (stzExterCode + stzPythonCode/stzRCode/
stzJuliaCode/stzPrologCode/...) runs a well-defined set of external
languages, EACH FOR ITS COMPETENT DOMAIN (Python for data/ML, R for
statistics, Julia for numerics, Prolog for logic, ...), marshalling
results back into Ring. Today this requires the external runtimes to be
installed; section 5.8 (polyglot refinement) upgrades it to a tiered,
engine-backed system with an embedded floor.

---

## 1. The Six Laws (the pattern of thinking, made explicit)

**LAW 1 -- A domain = a folder = an entry object = a data format.**
What belongs to a domain is entered through an INSTANTIABLE class -- you create
or load it, then work within it. Naked domain globals are forbidden; a global
form may exist only as thin sugar over one DEFAULT instance (the way `Q()`
sugars object construction). Every stateful domain earns a persistable format.

**LAW 2 -- Layered intelligence, graceful degradation.**
Every capability has a zero-setup deterministic/lexical floor, sharpens with a
local model when one is present, and NEVER requires anything paid or remote.
(lexical -> embeddings -> reranker -> generator is the proven ladder.)

**LAW 3 -- Maximum control.**
Deterministic core. Every verdict explains itself (Why, evidentiality), every
ambiguity refuses rather than guesses, every automatic choice is inspectable
and overridable.

**LAW 4 -- Consume today, create tomorrow.**
Consuming artifacts (GGUF models, datasets, corpora) is the floor; DESIGNING
them (networks, training, export) is the ambition. The design experience must
read like Softanza: easy, chainable, self-explaining (OpenNN's lesson: a
network you declare like a sentence, not a config file).

**LAW 5 -- Composition is the payoff.**
Higher modules are composition points, not new machinery. The agent composes
knowledge (memory) + meta (tools) + linguistic/natural (language) +
neural/learning (brains). If a higher module needs machinery the lower ones
lack, the lower ones were wrong.

**LAW 6 -- The machine programmer is a first-class audience.**
Most programming today is done by agents and LLMs, not humans. Softanza
must present ITSELF to them -- their own perspective, without letting them
break its rules: SELF-DESCRIBING (meta/'s Ask/WhatIs, the harvested
verified prose, info-tags, the semantic lexicon -- the library teaches
itself), MACHINE-CHECKABLE (the house rules -- Q-convention, active/
passive/fluent forms, engine-first -- exposed as validators an agent can
RUN before committing code, not folklore it must infer), and GUARDRAILED
(constraints, evidentiality, narrated tests as executable examples; the
library REFUSES doctrine-breaking use the same way it refuses ambiguity,
LAW 3). An agent should be able to learn Softanza FROM Softanza and be
corrected BY Softanza.

---

## 2. The Target Module Map

```
base/
  knowledge/    KNOWLEDGE PROGRAMMING -- entities, relations, graphs.
                  THE POWER ALREADY EXISTS in graph/: stzGraph (6.3k lines:
                  nodes, edges, paths, reachability, neighbors, views),
                  stzKnowledgeGraph from stzGraph (triples via AddFact,
                  pattern Query/QueryPath, ontology DefineClass/Property/
                  Validate, Explain), stzGraphRule (three-phase rules:
                  Constraint / Derivation / Validation), stzGraphQuery/
                  Planner/Workflow -- and the *.zknw FORMAT with a real
                  parser (ImportKnow/ExportToKnow/WriteToKnowFile).
                  THE WORK IS INTEGRATION, NOT CREATION (roadmap R1):
                  natural/'s world becomes SUGAR over a DEFAULT
                  stzKnowledgeGraph; the ad-hoc relation-law globals retire
                  into stzGraphRule; stzEntity moves in beside the graph.
                  FOLDER: whether graph/ is renamed knowledge/ (with
                  diagram/orgchart as visual citizens inside or moved) is
                  the author's naming call; the DOMAIN unification is the
                  substance.
                  ENTRY: stzKnowledgeGraph      FORMAT: *.zknw
                  SUGAR: StzKnow()/StzKnowRelation()/WhatIs()/AreRelated()

  meta/         META-PROGRAMMING -- the library's knowledge of ITSELF:
                  stzSelfDoc, stzLibDoc (move from reflect/), the harvest,
                  recipes, test-sample records, emb caches (.zcch).
                  reflect/ keeps only the raw mechanics (source resolution,
                  parsing primitives) that meta/ builds on.
                  ENTRY: stzLibDoc (already right)

  linguistic/   TEXT PROCESSING / NLP -- the domain that competes with NLTK
                  head to head (section 4). ENTRY OBJECT: stzText (moves
                  here from natural/ as the domain's face -- LAW 1).
                  The algorithms (engine, Zig, @embedFile'd data): UAX#29
                  word/sentence seam, lemmatizer, SNOWBALL STEMMING (25
                  languages), VADER sentiment, POS (perceptron), rule-NER,
                  RAKE/TextRank, WordNet, phonetics (Soundex/Metaphone),
                  fuzzy matching, n-grams + collocations, concordance/KWIC,
                  textstats/readability, plural/singular/ordinal/adverb.
                  neural/ upgrades the same calls transparently.
                  ENTRY: stzText                ARTIFACTS: corpora/ (R3)

  natural/      LANGUAGE SURFACES -- NNL devices, Naturally, questions,
                  evidentiality, truth chains, templates. SHEDS knowledge
                  state (-> knowledge/) and stzText (-> linguistic/);
                  keeps only language-as-code. Queries the other domains
                  through their entry objects.

  conversation/ CONVERSATIONAL PROGRAMMING (the organic rethink -- R3b):
                  the pieces exist but grew apart; the module REUNITES:
                  stzConversation   ENTRY: a governed multi-turn exchange
                                    with STATE (topic, goals, grounding,
                                    history)
                  stzQuestion       (EXISTS, natural/) the interrogative
                                    frames -- shared with natural/
                  stzGoal           what the conversation is FOR (ties to
                                    stzGraphGoal + the planner, R5)
                  stzNarration      the system's side of the dialogue:
                                    Why-chains, evidentiality, prose
                                    explanations (the narration culture,
                                    promoted to a construct)
                  GROUNDING: the knowledge graph (R1) -- a conversation
                  READS and WRITES the knowledgebase under its rules
                  (the 0.2 conversational door). LAW 2 ladder applies:
                  deterministic floor (lexicon + frames + templates) ->
                  neural upgrade (stzNeuralChat stays in neural/ as the
                  model-backed ENGINE this module can ride).
                  ENTRY: stzConversation        FORMAT: *.zcnv

  reactive/     THE TIME FOUNDATION (exists -- round-2 study, section 5.4):
                  Reaxis declarative streams = the change-propagation
                  surface; stzReactor/stzReactorPool (libuv worker thread,
                  base/common/) = the REAL async runtime agents run on.
                  Not a new folder -- a ROLE: knowledge/planner/neural gain
                  change hooks so intelligence stays CURRENT instead of
                  being recomputed on demand.

  neural/       MODEL CONSUMPTION (runtime inference over artifacts):
                  stzNeuralEngine, stzNeuralModel (GGUF load, embeddings,
                  NER, rerank, generate/sample/stream), stzNeuralChat.
                  models/ (*.gguf, gitignored) stays its artifact shelf.

  learning/     MODEL CREATION (the elevation -- R4):
                  stzDataset      load/split/normalize, from tables/lists/
                                  labeled text (serves the NLP classifier
                                  need too)
                  stzNeuralNetwork  declare layers like a sentence:
                      StzNeuralNetworkQ([ :Inputs = 4 ])
                        .AddDenseLayer(8, :ReLU)
                        .AddDenseLayer(3, :Softmax)
                  stzLayer / stzTrainer (loss, epochs, early stop) /
                  stzModelEvaluation; ggml backward pass or pure-Zig SGD
                  for small nets; EXPORT to the same artifact world neural/
                  consumes. OpenNN as the design lesson, not a dependency.
                  THE MODEL FOUNDRY (5.9): knowledgebase -> the DLM
                  (DOMAIN LANGUAGE MODEL, *.zdlm -- ENTRY stzDLM),
                  two rungs -- deterministic (graph -> grammar
                  synthesis -> constrained decoding; zero training;
                  every DLM's floor) and neural SLM (teacher-free
                  corpus synthesis via the natural layer -> tokenizer
                  -> small training -> GGUF export; optional fluency).
                  Any project ships its DLM FREE to its domain users.

  optim/        DECISION PROGRAMMING (round-2 elevation, section 5.5 --
                  the PI doctrine's engine room; lands in R4):
                  stzOptimModel     the ZIMPL-class modeling object: declare
                                    sets/params/vars/constraints/objective
                                    (hash literals or *.zopt), then
                                    SolveWith(:auto); Why() names the engine
                                    and narrates the solution (LAW 3)
                  execution tiers   own Zig simplex+B&B floor -> vendored
                                    HiGHS upgrade (LAW 2; the ggml no-CMake
                                    build precedent makes vendoring routine)
                  stzMultiObjectiveSolver (NSGA-II, already REAL) joins it;
                  the classic-ML roster (kNN/NaiveBayes/TF-IDF/ID3/apriori,
                  then k-means/logistic) rides stzDataSet + stzSimilarity.
                  ENTRY: stzOptimModel          FORMAT: *.zopt

  governance/   PROGRAMMATIC GOVERNANCE (the Zin-concordance layer,
                  section 5.7 -- R4b): the five declarable primitives
                  (ActionRiskTier / AuthorityType / CommitmentState /
                  DecommissionContract / DecisionLineage) + the
                  PERMISSION-vs-AUTHORITY split, all riding stzGraphRule;
                  the capability lattice + taint colours consumed by
                  agentic/'s stzAgentGraph; validators delivered through
                  meta/ (LAW 6). Mechanism, never a fixed constitution.

  refine/       REFINEMENT PROGRAMMING (the Refine concordance, 5.8 --
                  stzPolyCode's first-stimulus idea comes home; R6):
                  stzRefinementPoint  typed graph annotations, 8 kinds
                                    (Param/Block/Algo/Func/Pipeline/
                                    VarType/Lib/Custom) -- named
                                    adjustment knobs at any level
                  stzRefinement     a typed graph TRANSFORMATION carrying
                                    cascade + author + verification +
                                    history; IDENTICAL SHAPE whatever the
                                    author (human/template/solver/LLM)
                  THE GATE          4-stage pipeline (structural ->
                                    constraint -> derivation ->
                                    governance) composed from stzGraphRule
                  CASCADE           the pre-commit impact query -- the
                                    review artifact (ImpactOf packaged)
                  REVERSIBILITY     a full undo/redo TIMELINE (RevertTo/
                                    Checkpoint/Redo), atomic + typed
                                    [DEEPENED 2026-07-16]
                  TRUST POSTURES    every refinement carries an origin
                                    posture (trusted/external/sandboxed/llm)
                                    into the audit; per-point TrustFloor
                                    refuses lower-trust edits [DEEPENED 2026-07-16]
                  SEEDS: stzAppRefinement's knob model, the narration's
                  R-tag grammar, stzCCode's working transpiler.
                  ENTRY: stzRefinableCode       FORMAT: *.zrfn

  agentic/      AGENTS (the composition point -- R5):
                  stzAgent          base: goal, skills, memory, tools, Why
                                    -- its MIND is a Softanzuter (the
                                    Uter ladder, 5.6)
                  stzPIAgent        PROGRAMMATIC INTELLIGENCE: deterministic
                                    planners over the semantic lexicon +
                                    library methods (the Softanzuter
                                    lineage) -- auditable, zero-cost,
                                    offline. Softanza's differentiator.
                  stzLLMAgent       model-backed (local GGUF via neural/);
                                    same skill/tool/memory interfaces
                  stzAgentSkill     a capability: precondition + plan +
                                    verification (PI skills = algorithmic;
                                    LLM skills = prompted; SAME interface)
                  stzAgentMemory    BACKED BY stzKnowledgeGraph (LAW 5)
                  stzAgentTool      BACKED BY meta/ (the self-describing
                                    library: every documented method is a
                                    callable tool with its intent text)
                  TWO SPACES: the NATIVE STACK -- a curated set of
                  library-internal agents (the roster is a Softanza-
                  designer decision, R5) that the library's OWN features
                  consume first: wise-coding answer analysis, solution
                  search, knowledgebase gap-filling -- individually or
                  collaboratively. Versus the APPLICATION SPACE, where
                  programmers add their own agents over the SAME
                  interfaces, without touching the native stack.

  app/          THE WORLD (exists -- 5.10): stzApp (Being/Becoming/
                  Body + Presence/Intent/Refinement/Reach; Slice A
                  green, B-E to finish in R7) and stzSuperApp (the
                  constellation -- design-only, code in R7).
                  ENTRY: stzApp / stzSuperApp   FORMAT: *.zgrf+rulz

  platform/     THE OPERATIONAL ENVELOPE (NEW -- 5.10, R7): stzPlatform
                  = Generation (Reach -> shells), the capability seam
                  (governance-gated device/native capabilities), the
                  Commons runtime (identity/messaging/stores), the
                  networked body, registry + norm enforcement.
                  ENTRY: stzPlatform

  appserver/    THE COMPUTATIONAL SERVER (exists as pre-engine
                  skeleton -- 5.10, re-based in R7): ONE reactor-driven
                  service host (async accept/read/lifecycle on
                  stzReactor + sqlite bridge) specializing into web /
                  MBaaS / IoT / AGENT hosting; the persistent
                  computational brain IS the resident Zig engine.
                  ENTRY: stzAppServer
```

What does NOT change: string/ list/ number/ table/ etc. (the data domains),
engine/ (Zig), the Q-convention, the narrated-test culture.

---

## 3. Current-State Audit (2026-07-13)

> **AMENDED 2026-08-22.** The table below is the audit as taken on 2026-07-13 and is
> preserved unedited. **[3.1](#31-re-audit-2026-08-22----every-rung-marked-with-the-file-or-commit-that-proves-it)
> is the live one** -- every 2026-07-13 row dispositioned, then every roadmap rung R1-R8
> marked delivered / partial / not started with its proof. **3.2 is the agent-doctrine
> ruling** (`CENTRAL-AGENTDOCTRINE-01`).

| Concern | Verdict |
|---|---|
| /natural holds entities+relations+suppositions as $-globals | WRONG HOME + WRONG SHAPE -- and a PARALLEL WORLD: graph/stzKnowledgeGraph already offers the power (triples/query/ontology/.zknw). R1 unifies onto a default instance, globals as sugar |
| The 2026-07-13 relation laws ($aStzRelationRules) | DUPLICATE a lesser stzGraphRule (Constraint/Derivation/Validation) -- retire into it in R1 |
| stzText lives in natural/ | Move to linguistic/ as its ENTRY OBJECT (R3) -- natural/ keeps language-as-code only |
| /neural consumes GGUFs only | Right for its scope; CREATION gets learning/ (R4) |
| /reflect hosts self-doc | Mechanics fine; the DOMAIN identity is meta-programming -- promote to meta/ (R2) |
| Evidential + constraint registers as globals in natural/ | Acceptable: DISCOURSE state (per-conversation), not domain data; revisit only if persistence is ever needed |
| stzNeuralChat in neural/ | Right home (a session over a model) |
| stzLinearSolver's simplex | DISHONEST STUB -- returns all-zeros silently (hardcoded tableau, pivot loop never iterates); the one comparing test was retired, which is why it survives. Violates LAW 3; R4 makes it real |
| reactive/ vs intelligence modules | LINKED (R5 reactor-runtime, 2026-07-16): the engine event bus (reactive.zig) is UN-ORPHANED -- `stzEventBus` (Ring wrapper) + `stzAgentHost.SuperviseOnEvent(agent, channel)` make agents EVENT-DRIVEN (one perceive-act cycle per emitted event -- "the loop IS an event loop"). Still open: the derived-state engine (Watch/Computed/BindTo) blocked by the R54 stzReactiveObject init bug (8 of 9 tests retired) |
| Reaxis narration claims "built on libuv" | STALE -- libuv was removed from Reaxis 2026-06-13 (cooperative polling now); real libuv lives in stzReactor. Reconcile in S0 |
| Conversation constructs scattered: stzNeuralChat (neural/), stzQuestion (natural/), narration = culture-only, goals unbuilt | Conversational programming deserves a DOMAIN -- conversation/ reunites them (R3b) |
| The house rules (Q-convention, forms, engine-first) live in docs + folklore | LAW 6: agents can't RUN folklore -- meta/ exposes them as checkable validators (R2) |

---

### 3.1 RE-AUDIT 2026-08-22 -- every rung marked, with the file or commit that proves it

*(by the stzlib-intelligence plane, on Central's prompt 47. **The 2026-07-13 table above is
kept exactly as written and is NOT corrected in place** -- this estate amends by adding, so
that what was believed on the day remains readable beside what was measured six weeks
later. Every row above is dispositioned in 3.1.1; the roadmap is marked in 3.1.2.)*

**A source of truth that cannot say where the work stands is not one.** That sentence is
why this subsection exists. Everything in it was measured against the tree on 2026-08-22,
and every green verdict names a guard that was RUN, not a file that was seen.

#### 3.1.1 Disposition of the 2026-07-13 audit rows

| 2026-07-13 concern | 2026-08-22 disposition |
|---|---|
| /natural holds entities+relations+suppositions as $-globals | **CLOSED.** The globals are sugar over ONE default graph: `natural/stzKnowledgeWorld.ring` delegates `StzKnow` / `StzKnowRelation` / `WhatIs` / `AreRelated` to `DefaultKnowledgeGraph()`. Proven end to end by `test/natural/knowledge_integration_narrated.ring` (19/19) |
| The 2026-07-13 relation laws ($aStzRelationRules) | **CLOSED.** `:Transitive` / `:Symmetric` / `:Unique` are declared with `StzConstrainRelation` and enforced by the graph's own ontology -- `RelationHasLaw()` reads them back, and they TRAVEL INSIDE THE .zknw FILE (same guard, Scene 3) |
| stzText lives in natural/ | **CLOSED.** `base/linguistic/` holds stzText, stzPlural, stzSingular, stzOrdinal, stzAdverb, stzParseTree, stzListOfTexts and stzCorpus |
| /neural consumes GGUFs only | **CLOSED, both ways.** Consumption plus creation: `learning/` holds the ML floor and `stzDLM`; `neural/` now also CONSTRAINS generation (see the C9 row below) |
| /reflect hosts self-doc | **CLOSED.** `base/meta/` holds stzSelfDoc, stzLibDoc, stzCodeGraph, stzCodeRule(s), stzPredicateSet, stzGovernanceChecks, and the Py / JS / Ring code graphs |
| Evidential + constraint registers as globals in natural/ | **UNCHANGED, and still acceptable** -- discourse state, not domain data. No persistence need has appeared |
| stzNeuralChat in neural/ | **UNCHANGED, still the right home** |
| stzLinearSolver's simplex -- DISHONEST STUB | **CLOSED at the floor, OPEN at the DSL.** A real simplex lives in `engine/src/simplex.zig`, guarded by `test/number/numeric_simplex_narrated.ring`, and the comparison test is un-retired (`test/linearsolver/13_same_problem_different_solvers.ring`). What did NOT arrive is R4 step 5's modelling DSL -- see the R4 row in 3.1.2 |
| reactive/ vs intelligence modules | **CLOSED.** The event bus is wired (`stzEventBus` + `stzAgentHost.SuperviseOnEvent`), and since 2026-08-20 the SCHEDULING itself can be handed to Zig (`agentloop.zig`, `UseEngineLoop()`), guarded by `test/agentic/agentloop_engine_narrated.ring` (54/54) |
| Reaxis narration claims "built on libuv" | **CLOSED in S0** |
| Conversation constructs scattered | **CLOSED.** `base/conversation/` holds stzConversation, stzGoal, stzNarration; wise coding runs (`test/conversation/wisecoding_narrated.ring` 13/13, `wisecoding_rich_narrated.ring` 52/52) |
| The house rules live in docs + folklore | **CLOSED.** They are runnable: `meta/stzCodeRule(s)` + `graph/stzRuleReport` -- ONE CI gate over six rule domains, and since 2026-08-22 the structured-output verdict enters that same gate |

#### 3.1.2 THE ONE ROADMAP, rung by rung (measured 2026-08-22)

Verdicts are **DELIVERED** / **PARTIAL** (with what is missing named) / **NOT STARTED**.
A rung is marked DELIVERED only where a guard proving it was RUN on this date.

| Rung | Verdict | The proof | What is still missing |
|---|---|---|---|
| **S0** foundation hygiene | **DELIVERED** | `stzGraph.Paths()` implemented (stzGraph.ring:2019); `stzMatrix.Transpose` exposed (stzMatrix.ring:4433); `stzRegexUter.Compute` present; `stznumbrex-copy.ring` deleted; the Reaxis / libuv narration reconciled | -- |
| **R1** knowledge | **DELIVERED** | `test/natural/knowledge_integration_narrated.ring` -- **19/19 green, 2.5 s**. Authoring, the ontology laws, `StzProve()` with a structured three-step trace, the .zknw round trip, derivation fired by an agent-door write, and strict mode (G8: provenance required, a contradiction RECORDED rather than resolved). `graph/stzKnowledgeGraph.ring` 977 lines, born 590daccd5 | **One author ruling is still open.** §6 R1 said "folder naming (graph/ -> knowledge/?) decided by the author here". The folder is still `graph/` and every consumer imports it as such. **Recommendation: keep `graph/` and retire the question** -- graph/ now holds 27k lines across sixteen files, of which the knowledge graph is one, and renaming a container after its most famous tenant is wrong by LAW 1 |
| **R2** meta + the code graph | **DELIVERED** | `test/meta/` -- codegraph 28/28, coderule, coderule_project, jscodegraph, pycodegraph, all green. `stzPredicateSet` (G10, the signable constitution) exists; `stzGovernanceChecks` holds the G2 validators; `stzRuleReport` is the ONE gate. Call-edges, deferred at R7, are now read (`stzRingCodeGraph.ring:239`) | -- |
| **R3** linguistic | **DELIVERED** | `base/linguistic/`, 8 files. The POS-pattern chunker (`test/linguistic/chunker_narrated.ring`) and the n-gram LM tier (`ngram_lm_tier_narrated.ring`) both exist; `stzCorpus` is the corpora entry object | The corpora SHELF is a class, not a folder. That is adequate, but §2's map still draws a `corpora/` directory that does not exist -- **the map is what is wrong here, not the code** |
| **R3b** conversation | **DELIVERED** | `test/conversation/wisecoding_narrated.ring` **13/13** and `wisecoding_rich_narrated.ring` **52/52**, both green. `ConcludeIn()` WRITES the .zknw at the end of an elicitation -- wise coding ends in an artifact, exactly as 0.3 demanded | The five answer registers are not equally strong: option, data-structure and natural are wired; EXAMPLES-with-induction rides `StzOwnAgent("induction")`, which is declared RESERVED (see the R5 row) |
| **R4** learning + optim | **PARTIAL** | Steps 0-4, 6 and 7 DELIVERED: `test/learning/` mlfloor 36/36, dlm 16/16, multilingual stress 37/37, knn-approximate green; `stzDLM` + .zdlm is foundry rung 1; `stzLLMFunction` + `stzOutputSchema` are step 6, and are now specified as **C9 v1.0.0** in `base/neural/SOFTANZA_STRUCTURED_OUTPUT.md` (written 2026-08-22) | **STEP 5 IS NOT STARTED. There is no `base/optim/`, no `stzOptimModel`, no `.zopt` format, no `SolveWith(:auto)` and no HiGHS tier.** The solver FLOOR exists (`engine/src/simplex.zig`, `stats/stzLinearSolver`, `stzMultiObjectiveSolver`, `stzStochasticSolver`); what is missing is the MODELLING DSL over it. This is load-bearing rather than cosmetic: R5's OPTIMIZATION leg names `stzOptimModel` as the planner's sub-solver, and the capstone's "optimize a menu straight from the knowledgebase" runs through it. ***[SUPERSEDED 2026-08-22: STEP 5 IS DELIVERED — `base/optim/` with three surfaces onto one AST, `engine/src/optim.zig` as the floor, `SolveWith(:auto)`/`Why()`, and `optim_modelling_narrated.ring` 59/59. The HiGHS tier is deliberately still absent and is REFUSED rather than downgraded. Details and the corrected expression mechanism are in the §6 R4 step 5 and §5.5 amendments. R5's OPTIMIZATION leg is now unblocked.]*** **Step 8** (the neural foundry rung -- corpus synthesis, tokenizer training, GGUF export) is also not started, and was always the ambition tier |
| **R4b** governance | **DELIVERED -- all five contracts, not one** | `base/governance/stzGovernance.ring`, 744 lines, born 7dd4b7275. ActionRiskTier = `DeclareRisk` / `RiskOf`; AuthorityType = `SetAuthority` / `AuthorityOf`; CommitmentState = `OpenCommitment` / `AdvanceCommitment`; DecommissionContract = `DeclareDecommission` / `FulfillObligation` / `MayRetire`; DecisionLineage = `RecordDecision` / `LineageOf` / `DecisionsSince`. Plus the 5.8 execution trust postures (`DeclarePosture` / `MayExecute`) and the .zgov format. `test/governance/` -- narrated 19/19, lineage 37/37 | **Reversibility is not among them.** See 3.2 -- it is now owed as a sixth contract *[2026-08-22 second session: PAID -- contract 6 + MayRegister delivered, safeworld_narrated 76/76]* |
| **R5** agentic | **PARTIAL -- and the partition is not where 2026-07-13 expected it** | Green: `test/agentic/`, eight suites, **261 assertions, 0 fail** (agentfile 88, agentloop_engine 54, agenthost 32, roster 31, agentrule 21, piagent 14, agentgraph 11, ownagentstack 10). PLANNING = `stzGraphPlanner` + `stzGraphGoal`, both built; REACTION, MEMORY, SKILLS and the governance gate all run; the capability lattice and taint colours are real (`stzAgentGraph`); ACCOUNTABILITY is the per-cycle trace | Named with reasons in **3.2**. In one line: OPTIMIZATION has no sub-solver (R4 step 5), the NATIVE ROSTER is one wired of five, `stzHybridAgent` was never built as a class, and **the safe world and the agents have never been introduced to each other** *[2026-08-22 second session: INTRODUCED -- stzAgentWorkbench + pia:2 postures + roster as first consumer; OPTIM, the four native agents and stzHybridAgent remain]* |
| **R6** refine | **DELIVERED** | `test/refine/` -- refinablecode 17/17, refine_deepening 24/24, gate_deepening green. `stzRefinableCode` over .zrfn; the four-stage gate; `stzPyCodeGraph` and `stzJsCodeGraph` are the polyglot contracts | The optional research tier (patch-commutation predicates, the ROM-style stable surface) was never started, and was marked optional on the day |
| **R7** delivery plane | **DELIVERED** (unchanged; marked on the day) | `test/capstone/restaurant_capstone_narrated.ring` green. All four topologies; `HostAgents()` interleaves the serve loop | INBOUND server-side TLS, as already recorded |
| **R8** scale | **DELIVERED** (unchanged; marked 2026-07-15) | §7 and its six rungs | -- |

**THE CAPSTONE** -- the definition of done for the whole roadmap -- runs and is green, but
it threads R1->R7 through CODE, not through the DAY-ZERO experience §6 describes: nothing
in the tree yet starts an owner with NOTHING and interviews them into a `restaurant.zknw`.
Wise coding proves the mechanism (`wisecoding_rich_narrated`, 52/52); the capstone does
not yet BEGIN with it. That is the honest gap between "the roadmap is nearly done" and
"the capstone is passed".

#### 3.1.3 Three measurements Central published, corrected at their source

Central's prompt 47 stated three facts and asked to be falsified rather than trusted. Two
stand as stated. All three carried an inference that does not.

1. **"`base/agentic/` is 3,808 lines, of which 2,946 arrived in the last four days and 744
   are R5's own."** The total is right; **the split is wrong in both directions.** The loop
   program added **2,578** lines (`git log --numstat`, 2026-08-20: stzAgentDeclaration
   1,207 + stzAgentFolder 505 + stzAgentRoster 470 + 396 into stzAgentHost). R5's own core
   is **1,230** lines, not 744: the count omitted `stzOwnAgentStack.ring` (118, 2026-07-16)
   entirely, and attributed ALL of stzAgentHost to the loop program when 368 of its 764
   lines predate it by five weeks (born f4d1f2edf, 2026-07-14). The true ratio is
   **68 / 32**, not 77 / 20. It does not overturn Central's worry -- the loop program is
   still the majority -- but a doctrine question decided on a ratio deserves the right one.
2. **"No `.zknw` file exists anywhere in the tree."** TRUE, and it is **hygiene, not a
   gap**. The acceptance guard WRITES one, reloads the brain from it, and `remove()`s it at
   line 137. The attached inference -- *"the north star's acceptance test has therefore
   never been run end to end"* -- is **false**: it was run on 2026-08-22 and is **19/19
   green in 2.5 s**. A test that cleans up after itself leaves exactly the evidence Central
   went looking for and did not find.
3. **"C9's normative text does not exist."** TRUE as measured. **Closed 2026-08-22**:
   `base/neural/SOFTANZA_STRUCTURED_OUTPUT.md`, C9 **v1.0.0**, extracted from
   `stzOutputSchema.ring`, `stzLLMFunction.ring`, `schema_gbnf.zig` and `gbnf_machine.zig`,
   and cross-checked by RUNNING the code -- the GBNF printed in its §6.1 is `ToGBNF()`'s
   real output, not a sketch of it. Central's pointer needs no path change.

Also corrected: `intelligence-wings/zai/` lives at
`libraries/stzlib/max/wings/intelligence-wings/zai`, not `max/wings/...`, and it is an
**empty directory that was never filled** -- created 2026-08-16 with the wings tree, and no
commit has ever added a file to it.

#### 3.1.4 What this re-audit cost, and the one PX finding

Twenty-eight guards run across agentic, governance, conversation, neural, learning, meta,
refine, knowledgegraph, natural and capstone. **Every one green: 0 failures.** Process cold
start is about 2.5 s and dominates almost every suite in this territory.

**The one section over budget: `test/meta/codegraph_narrated.ring` at 93 seconds** -- 37x
the next slowest guard here, for 28 assertions, because it walks the whole library to build
the graph. It owes a diet or a split (a fixture corpus for the assertions, the
full-library walk kept as a separate pre-commit gate). Until then it does not belong in
anyone's inner loop.

**Gates owned but NOT run, named with the reason** (`CENTRAL-PXDENOMINATOR-01`): the
`test/graph/` numbered suites (about 100 files) and `test/graphplanner/` -- both in this
territory, both not run because nothing this session changed can reach them.
`test/reactiveobject/` carries an `_ERR_RUN.txt` from an earlier session and belongs to the
reactive plane, not this one.

### 3.2 THE AGENT-DOCTRINE RULING (`CENTRAL-AGENTDOCTRINE-01`, settled 2026-08-22)

*(routed by Central to the stzlib-intelligence plane. R5's own DOCTRINE GUARD -- "the
doctrine must not fork" -- is what this ruling was asked to apply. The question: is the
`.pia` declaration and the roster shape THE LIBRARY'S AGENT DOCTRINE, which R5 should now
be rewritten around, or a PRODUCT REALIZATION over interfaces R5 still owes?)*

#### THE RULING, in one sentence

**`.pia` is a product realization -- a DOOR, not the doctrine -- and the doctrine did not
fork.** But the harness proved two things in practice that R5's 2026-07-13 design does not
carry, and **both are promoted to doctrine here**: the **registration gate** and the
**reversibility class**.

#### Why it is a door and not a fork -- the evidence, not the preference

The declaration says so in its own opening, and the code keeps the promise:

> *"NO NEW AGENT RUNTIME LIVES HERE -- this is a front-end onto classes that already
> work."* -- `stzAgentDeclaration.ring`, line 9

> *"THIS FILE EXTENDS stzAgentGraph's VOCABULARY RATHER THAN INVENTING A SECOND ONE.
> `kind` is the graph's actor kind, `effect` names a governed action exactly as
> `AddGovernedSkill` does, and the refusal for an llm actor holding an effect is
> `stzAgentGraph.Grant`'s OWN SENTENCE, quoted rather than paraphrased -- one rule, two
> doors, same words."* -- ibid., line 78

That is the test a fork fails and this passes. A `.pia` file compiles to `stzPIAgent` +
`stzAgentSkill` + `stzAgentMemory` + `stzGovernance`, hosted on `stzAgentHost` -- the
2026-07-14 classes, unedited. It is exactly §0.2's **DSL DOOR** applied to agentic/, the
same move `.zknw` is for knowledge and `.zgov` for governance, and LAW 1 predicted it:
*every stateful domain earns its format*. **agentic/ earning `.pia` is the doctrine
working, not the doctrine bending.**

The corrected line count says the same thing from the other side (3.1.3): the loop program
is 2,578 lines of FRONT END over 1,230 lines of runtime that it did not touch. Four fifths
of a folder being new is alarming only if the new part reimplements the old one. It does
not.

**So R5 is not rewritten around `.pia`. `.pia` is adopted as R5's declarative door, and
promoted from "considered here, on demand" (the `*.zagn` line at the end of §6 R5) to
DELIVERED, under its real name.**

#### What the harness proved that R5's design got wrong -- and is now owed back

*Both directions were real answers, and this is the direction that carries weight.*

**(a) THE REGISTRATION GATE. An actor with no coverage statement and no reversibility class
is REFUSED.** This was measured in the loop program, not theorised. R5's 2026-07-13 design
has nothing like it: it gated ACTS (`MayProceed` before a skill fires) and never gated
REGISTRATION. Those are different failures. A governance gate answers *may this actor do
this thing*; a registration gate answers *may this actor exist in the loop at all*, and it
answers before any tick, which is the only moment at which the answer is free.

It is enforced today in `agentloop.zig` and reachable from Ring as
`oHost.Declare(name, coverage, :compensable)`, with the agent asked for its own
`CoverageStatement()` / `ReversibilityClass()` first. **It is OPT-IN** (`UseEngineLoop()`),
and the code is honest about why: switching it on for everybody would break every host that
has not declared yet.

> **RULING: the gate is DOCTRINE, and opt-in is a MIGRATION STATE, not the design.** It
> belongs beside `MayProceed` in R4b, not inside one scheduler. A host that does not use
> the engine loop should reach the same refusal. **The default flips when the last
> in-tree host declares** -- and the roster's own agents already do, so the distance is
> short.

**(b) REVERSIBILITY IS A SIXTH GOVERNANCE CONTRACT, and it is missing from R4b.** `.pia`
declares one of `reversible` / `compensable` / `irreversible`; `stzAgentHost` maps the
words to engine codes; `agentloop.zig` refuses a registration without one. And
`stzGovernance` -- the file that holds the five R4b contracts -- **has never heard of it.**
A grep for `Reversib` across `base/` returns agentic/, `data/stzCharData.ring`, and nothing
else. The concept is real, enforced, and homeless.

That is a genuine 2026-07-13 design miss, and it is the more interesting of the two,
because reversibility is precisely the axis `Agents That Cannot Hurt You` turns on. R4b
declared *how risky* an action is (ActionRiskTier) and never *how undoable* it is -- and
those are orthogonal. A tier-1 action that cannot be undone deserves more ceremony than a
tier-3 action that can.

> **RULING: `ReversibilityClass` joins ActionRiskTier, AuthorityType, CommitmentState,
> DecommissionContract and DecisionLineage as R4b's SIXTH declarable contract.** `.pia`
> keeps its three words unchanged -- they become the contract's vocabulary rather than one
> format's private enum. §6 R4b is amended by reference to this paragraph.

#### Where `Agents That Cannot Hurt You` binds today: NOWHERE. That is the finding.

The constitution's whole thesis is *the workbench holds no reference to reality*. Measured
2026-08-22:

- **The safe world EXISTS and is complete for the file domain.** `stzVirtualOperation`
  carries `@cActor` and `@cIntent`; `stzCommitScope` has `AllowUnder` / `AllowType` /
  `SetMaxOperations`; `stzUpdatePlan` has `Validate()`, `Risks()`, `Narration()`,
  `RejectOperation(n, :Because)`, `MayCommit()`, `Execute()`, `ExecuteStepByStep()` and an
  `AuditTrail()`; it even takes `SetGovernance(oGov)`, so the crossing is R4b-gated and
  `test/system/governance_crossing_narrated.ring` proves it.
- **`base/agentic/` does not mention any of it.** A grep for `VirtualSystem`,
  `VirtualFileSystem`, `CommitScope` or `UpdatePlan` across `base/agentic/` and
  `base/governance/` returns **zero lines**.
- **And an agent in this library reaches reality directly, today.**
  `stzAgentRoster.RollRelocateMonths` -- a `ring:` function in a live `.pia` agent's `does:`
  slot -- calls `StzFileRead`, `StzFileWrite`, `StzFileDelete` and `StzDirCreatePath` on the
  estate's real journal and on `dashboard/SESSION-LOG.md`, on a tick, with no plan, no
  scope, and no committing actor.

To its credit, that function hand-rolls its own safety: it writes the archive copy, re-reads
it, compares it to what it wrote, and only then deletes the source -- leaving the ledger
completely untouched if the verify fails. **That is the right instinct and the wrong place
for it.** Write-then-verify-then-commit is precisely what `stzUpdatePlan` exists to provide
ONCE, for every agent, auditable. Every agent that reimplements it will reimplement it
slightly differently, and the differences will be found in production.

> **ANSWERING CENTRAL'S THIRD SUB-QUESTION DIRECTLY.** *Does an `stzPIAgent` today hold any
> reference to reality?* **Yes -- through the `ring:` escape, and it is exercised in
> shipped code.** *Is plan-as-negotiation-medium a thing R5 must build, or a thing
> `stzAgentHost` already half-is?* **Neither. It is a thing `stzVirtualSystem` already
> fully is, on the human side, and that no agent has ever been handed.** The missing piece
> is not the plan -- the plan is built. It is the **binding**: an agent whose memory-write
> and file-write go to a vfs instead of to reality, and whose only export is
> `GenerateUpdatePlan()`.
>
> What genuinely does NOT exist, from the constitution's own Layer-4 list:
> `oAgent.Receive(aIssues)` / `oAgent.Revise()` (the agent's side of the negotiation),
> `stzAgentEvaluation` (the examination hall), and branch-per-hypothesis
> (`BranchFrom` / `CompareBranches`). `stzHybridAgent` was named in §6 R5 and never built
> as a class -- `stzAgentGraph.AddHybridActor` is a graph NODE, which proves a composition
> sound but instantiates nothing.

#### The `ring:` escape, judged

`ring:<FunctionName>` is refused at LOAD if no such function exists -- good, and that is
what the doc means by *"what 'Ring for the rest' costs and all it costs"*. But that is a
check on the NAME. **Nothing checks what the function DOES**, and the roster demonstrates
that a `ring:` function may do anything Ring can do.

This is not a defect to be closed by removing the escape -- the escape is the reason `.pia`
is usable at all. It is a defect closed by **the trust posture R4b already ships**:
`DeclarePosture` / `MayExecute` exist and govern exactly this question for polyglot and
LLM-composed code, and a `ring:` function is the same category of thing. Today a `.pia`
file cannot declare a posture and the loader never asks for one.

> **RULING: a `ring:` clause must carry an execution posture, and a `does:` slot's posture
> must be at least as strict as the agent's reversibility class allows.** This is the one
> place where `.pia` v1's vocabulary is genuinely incomplete rather than merely small, and
> closing it is a version bump (`pia: 2`), which is what the version header is for.

*[DELIVERED 2026-08-22, second session: `pia: 2` is the current format --
`posture: trusted | external | sandboxed` required beside any `ring:` clause,
composed against the agent's reversibility class for `does:` slots via
`StzPostureReversibilityRefusal` (trusted covers all three classes, external
covers reversible+compensable, sandboxed covers reversible only -- the
`no-llm-effectful` rule seen from the other side). v1 stays READ as a stated
migration state: the estate's live roster declarations are v1 and belong to
softanza, so their bump is Central's; the debt is recorded in
stzAgentDeclaration's header. Guard: test/agentic/safeworld_narrated.ring
scene 4.]*

#### The native roster: honest, and one-fifth wired

`stzOwnAgentStack` declares five library-internal agents and wires one (`wise-coder`);
asking for a reserved one RAISES rather than returning a stub. **That is LAW 3 working and
should not be read as a defect** -- but it does mean §0.3's "solution space" (analyze in
every register, induce, validate, rank, plan) is one-fifth real, and R3b's EXAMPLES
register depends on `induction`, which is reserved. The roster is the honest measure of how
far "the library is the first consumer of its own agents" has actually got.

#### What R5 still owes, after this ruling

1. `stzOptimModel` as the planner's sub-solver -- **blocked on R4 step 5**, which is not
   started (3.1.2).
2. The four reserved native agents.
3. `stzHybridAgent` as a class, not only as a graph colour.
4. **The binding of the safe world** -- the largest of the four, and the one that makes the
   constitution true instead of aspirational.
   *[DELIVERED 2026-08-22, second session: stzAgentWorkbench +
   stzPIAgent.GiveWorkbench()/GenerateUpdatePlan(), the ambient bench bracketed
   per Cycle(), stzAgentRoster as first consumer. The constitution's remaining
   Layer-4 gap is the negotiation verbs (Receive/Revise, stzAgentEvaluation,
   branch-per-hypothesis) -- the plan now reaches the agent; the conversation
   about the plan does not yet.]*

And R4b owes the two contracts this ruling promotes: the **registration gate** and
**ReversibilityClass**.
*[DELIVERED 2026-08-22, second session: contract 6
(`DeclareReversibility`/`ReversibilityOf`, .zgov-persisted) and
`MayRegister` refusing in AGENTLOOP-R4/R5's own sentences -- both in
stzGovernance.ring. The gate's default flip on the Ring pump stays a migration
step by the ruling's own condition: appserver/, cluster/ and perf/ hosts
supervise without declaring, and those planes are not this one's to edit.]*


---

## 4. The Text-Processing Battlefield: Softanza vs NLTK

**The author's target: compete with NLTK head to head and beat it on
simplicity, innovation, and multi-dimensional paradigms, covering all the
classic needs of NLP and more.**

### 4.1 Where text processing LIVES (the layered answer)

Text processing is not one module -- it is a LAYERED STACK, and the layering
IS the advantage:

```
  string/      the MECHANICS  -- find/replace/split/sections, codepoint-true
  linguistic/  the ALGORITHMS -- classic NLP, deterministic, zero-setup
               (entry object: stzText -- the face of the domain)
  neural/      the UPGRADE    -- the SAME calls sharpen when a model is
               present (NamedEntities -> transformer NER, Summary ->
               embedding TextRank, Classify -> zero-shot ...)
  natural/     the SURFACES   -- the same needs speakable as language
               (Naturally, NNL chains, questions, evidentiality)
```

### 4.2 Head-to-head coverage (audited 2026-07-13)

| Classic NLP need | NLTK | Softanza today |
|---|---|---|
| Tokenization (word/sentence) | punkt (download) | UAX#29 engine seam -- Unicode-true, zero setup |
| Stemming | Porter/Snowball (~15 langs) | Snowball, 25 LANGUAGES, embedded |
| Lemmatization | WordNet lemmatizer | dictionary lemmatizer (42k), embedded |
| POS tagging | perceptron (download) | perceptron, embedded |
| NER | ne_chunk (weak) | rule-NER + TRANSFORMER NER (GGUF upgrade) |
| Sentiment | VADER (download) | VADER, embedded + tone evidentiality |
| WordNet | corpus download | embedded |
| Key phrases / summary | (third-party) | RAKE + TextRank + embedding + ABSTRACTIVE |
| n-grams / collocations | FreqDist/BigramCollocation | NGramsAndTheirCounts / Collocations |
| Concordance (KWIC) | Text.concordance | Concordance / InContextWithWindow |
| Phonetics | -- ABSENT -- | Soundex + Metaphone |
| Edit distance / fuzzy | edit_distance | Levenshtein + fuzzy module |
| Readability/textstats | (third-party) | textstats engine module |
| Classification | trainable (setup-heavy) | DONE 2026-07-14: zero-shot (neural) + TRAINABLE floor (stzNaiveBayes text learner + kNN/tree/logistic, learning/); embedding-upgraded tier later |
| Chunking / parsing | RegexpParser, CFG trees | DONE 2026-07-14: Chunks('DT? JJ* NN+') -- patterns over tags, zero setup; parse trees stay deferred |
| Corpora shelf | nltk.download zoo | DONE 2026-07-14: stzCorpus -- your texts ARE the corpus; big-shelf artifacts later |
| Language modeling utils | nltk.lm | DONE 2026-07-14: BigramProbability/LogProbability/Perplexity (Laplace floor; engine-side counting = next rung) |

### 4.3 The three beat-axes

**SIMPLICITY.** NLTK's first contact is ceremony: pip install, then
nltk.download('punkt'), download('averaged_perceptron_tagger'), ... per
feature. Softanza's first contact is ONE LINE, everything embedded:

    Q("The cats were running fast").TextQ().Lemmatized()
    # no install, no download, no internet -- ever (LAW 2)

**INNOVATION.** What NLTK cannot say: verdicts that carry confidence
(evidentiality), operations that explain themselves (Why()), the SAME call
that upgrades itself when a local model appears, a library you can ASK in
plain words (meta/), 25-language stemming, phonetics, and a Zig engine
(compiled speed, not interpreter loops).

**MULTI-DIMENSIONAL PARADIGMS.** The same need, five ways -- NLTK has one
(Python calls). Softanza:
1. method chains         Q(t).TextQ().Sentiment()
2. natural language      Naturally("get the sentiment of ...")
3. NNL narratives        TruthOf(t).IsA(:PositiveText)...
4. declarative W         conditions/filters over words and sentences
5. knowledge + agents    text -> entities -> the knowledge graph -> agents

Definition of victory: every row of 4.2 green, each with (a) a one-line
zero-setup call, (b) a narrated suite, (c) an Ask-able intent, and (d) a
neural upgrade path where meaningful.

---

## 5. The Five Foundations (rounds 1+2, 2026-07-13; they run UNDER all pillars)

The author's directive: graphs, the pattern-matching family, the numerical
layer -- and, from the second analysis round, REACTIVITY and the
DECISION machinery (optimization + modeling DSLs + classic ML) -- are not
modules beside the pillars. They are FOUNDATIONS the whole intelligence
system runs on. Five deep code studies confirmed it: STRUCTURE (graphs),
RECOGNITION->ACTION (patterns), COMPUTATION (numerics), TIME/CHANGE
(reactive), and DECISION (optimization+ML).
(Vocabulary ruling, 2026-07-13: the word "substrate" is RETIRED across
the Softanza corpus; FOUNDATION is the canonical term.)

### 5.1 GRAPHS -- the STRUCTURE foundation  (graph/, ~19k lines, 108+ tests)

WHAT EXISTS (verified in code):
- stzGraph core: the full classical suite -- Dijkstra/A*/BFS paths, longest
  path, reachability, connected + strongly-connected components, cycles,
  topological sort, BETWEENNESS/CLOSENESS/PAGERANK centrality, clustering,
  MAX-FLOW/MIN-CUT/min-cost-flow, bottleneck + ImpactOf analysis, density/
  diameter/MST, live filtered VIEWS (Commit/Rollback), diff/compare,
  DOT/JSON/YAML/GraphML export.
- stzGraphPlanner: a REAL PLANNER, not just pathfinding -- A* + GOAL-PREDICATE
  search (UntilYouReachF(func) = preconditions as closures), weighted cost
  PROFILES (:fastest/:safest/:cheapest/...), Explain()/Why()/Alternatives()/
  CostBreakdown(), plan COMPARISON (Tradeoffs/WhichIsCheaper/RankPlansBy),
  HISTORY + LEARNING (BestHistoricalPlan), and Actions() returning a literal
  step-by-step ACTION SEQUENCE. This is the PI-agent's planning brain,
  already built and 40-tests strong.
- stzGraphQuery: Cypher-like declarative matching (variable binding,
  multi-hop, Where/WhereF, Select/OrderBy/Limit, mutation, rule hooks) +
  ToOpenCypher() export.
- stzGraphRule: the three-phase rule registry (Constraint guards BEFORE,
  Derivation auto-derives AFTER -- incl. built-in Transitivity/Symmetry --
  Validation checks the final state), rules = plain closures.
- stzWorkflow (+ stzOrgChart, .flow parser): processes/state machines with
  actors, SLAs, critical path, bottlenecks, what-if simulation.
- stzApp: THE precedent -- "an application as a living world of meaning":
  Being -> stzGraph, Life-behavior -> stzWorkflow, Life-purpose ->
  stzGraphPlanner.Pursue(goal). Partially validated; study it for R5.

LATENT (spec'd or stubbed, NOT built -- the expansion frontier):
- **stzCodeGraph** (the design doc's "stzCode: Programs as Call Graphs" --
  fully worked-out spec): nodes = functions/classes/modules, edges = calls/
  imports/inheritance/delegation; DeadCode() via ReachableFrom, CyclicCalls(),
  CriticalPath(), ParallelizableBranches(). Every primitive exists; only the
  semantic wrapper is missing. DESTINY: meta/ replaces its FLAT harvest
  records with a code graph (R2) -- impact analysis, dead-code detection,
  Ask over structure, refactor planning.
- **stzGraphGoal**: referenced by stzApp (Gap()/Profile()) but nonexistent --
  the goal-modeling layer the planner needs to become an agent brain (R5).
- stzGraphSimulator extraction (TODO'd in core), stzDecisionTree,
  stzSemanticModel, stzDomainLanguage (design-doc Parts 5-6).
- HYGIENE found: stzGraph.Paths() raises Not-yet-implemented (PathsWhereF
  partially dead); planner heuristic falls back to constant-1 without
  coordinates (TODO'd).
- TODAY graphs are barely used OUTSIDE graph/ (only stzApp + stzGraphex):
  natural/ and meta/ do not ride them yet -- exactly what R1/R2 fix.

### 5.2 PATTERNS -- the RECOGNITION->ACTION foundation  (regex/, 12 modules)

WHAT EXISTS (verified): ONE grammar DNA across every data shape --
`{...}` patterns, `@Token(constraints)`, `& | @!` quantifiers/sets/:unique,
uniform .Match/.MatchedParts/.Explain/.Tokens surface, match caches:
  stzRegex (PCRE2 + match-type policies + named patterns via pat()),
  stzRegexMaker (fluent English-like builder), stzListex (typed tokens over
  lists), stzNumbrex (math properties: prime/perfect/palindrome/mod...),
  stzMatrex (matrices), stzTablex (tables: cols/rows/sorted/aggregates),
  stzTimex (timelines: events/durations/sequences), stzGraphex (graph paths
  with property constraints -- LAYERED ON stzListex: the family composes).

THE SOFTANZUTER PARADIGM (the author's flagged innovation): stzRegexUter +
stzListexUter are WORKING pattern->computation engines: triggers (patterns)
carry code; Process(data) fires every matching trigger, transforms the value,
and records a DEPENDENCY-TRACKED state history (dependsOn/affects/
GetDependencyChain). This is a nascent FORWARD-CHAINING RULE ENGINE -- the
scaffolding anticipates cascading but does not yet RE-FIRE dependent
triggers to fixpoint. That upgrade turns it into production rules = the
PI-agent's reactive skill foundation (R5).

LATENT: the doc-only executor family (stzRegexAnalyser, stzGeneticRegexuter,
stzLinguisticRegexuter, stzQuanticRegexuter -- vision, no code); pattern-
driven data GENERATION and code translation (stzRegex's own TODO roadmap).
PATTERN INDUCTION -- inferring a Regex/Listex/Graphex FROM user-supplied
EXAMPLES -- is now DEMANDED by the 0.3 answer protocol (answer-by-example):
the doc-only genetic/inference executors finally have their purpose.
So does stzQuanticRegexuter (documented: evaluate multiple interpretations
SIMULTANEOUSLY, each weighted by contextual probability): it is the
SOLUTION-SPACE engine of the same protocol -- superposed weighted
candidates feeding the several-acceptable branch, collapsed by rules or
user choice, its weights mapping onto the evidential certainty bands.
HYGIENE found: Compute() typo (cTex) = dead alias; StateByPosition/
StateByComputationOrder TODO stubs in both Uters; stznumbrex-copy.ring
stale duplicate; listexuter tree test retired pending a hash-literal DSL.

DESTINY BY PILLAR: R3's POS chunker = stzListex over tag streams (compose,
do NOT build a new engine -- Graphex proves the layering); R1's graph laws
feed stzGraphRule; R5's PI skills = Softanzuter triggers + planner actions.

### 5.3 NUMERICS -- the COMPUTATION foundation  (number/ + stats/ + engine)

WHAT EXISTS (verified):
- stzMatrix (2.4k lines, from stzListOfLists) over a Zig engine
  (stz_matrix.dll, flat f64): region add/multiply (the FastPro replacement),
  matmul, determinant, inverse, sum/min/max/power -- plus a large
  spreadsheet-style find/replace/section-editing surface.
- stzDataSet: THE HIDDEN GEM -- fully engine-backed statistics: variance/
  stddev, percentiles/quartiles/IQR, skewness/kurtosis, z-scores, moving
  averages, outliers, CORRELATION/COVARIANCE/LINEAR REGRESSION, Spearman.
- solver.zig: scalar numerics (quadratic roots, bisection/Newton, Simpson).
- stzLinearSolver: an LP/MILP SURFACE (variables/constraints/objective,
  greedy/simplex/branch-bound/genetic backends) -- but simplex is a STUB
  (hardcoded tableau) and only greedy works; the module is unexercised.

GAPS (the honest ledger for R4):
- Transpose exists in the ENGINE but is NOT exposed in Ring (trivial wire).
- No Ax=b solve (only full inverse), no LU/QR/Cholesky/SVD/eigen, no
  elementwise subtract/multiply/divide, no dot/norm/trace/rank, no
  broadcasting; matmul is naive O(n^3), determinant O(n!) Laplace; every op
  pays a Ring<->engine copy (no resident pipelines).
- No random DISTRIBUTIONS (normal/uniform/poisson) anywhere.
- NO ggml BRIDGE: stzMatrix (flat f64) and ggml tensors are unrelated today
  -- but both are contiguous float arrays, so a bridge is FEASIBLE and is
  the strategic move: BLAS-grade matmul + the backward pass from the ggml
  we already vendor = the floor learning/ stands on.

DESTINY BY PILLAR: R4 rides this foundation (matrix hygiene -> ggml bridge ->
stzNeuralNetwork); stzDataSet is the evaluation layer (metrics/correlation);
the LP solver becomes the OPTIMIZATION module (real simplex) feeding
PI-agents with resource-allocation skills (R5).

### 5.4 REACTIVITY -- the TIME/CHANGE foundation  (reactive/ + common/ + engine)

Intelligence that only computes on demand is a SNAPSHOT; reactivity is what
makes it CURRENT -- facts change and knowledge, plans, and behavior follow
without being asked. The study found THREE distinct layers at different
maturities (conflating them is the main confusion to avoid):

WHAT EXISTS (verified in code):
- REAXIS (base/reactive/, 8 files ~2.5k lines): the author's DECLARATIVE
  REDESIGN of reactive programming -- semantics renamed from first
  principles (callbacks -> Rfunctions, "functions that wait"; observable/
  subscribe -> stream + OnPassed; backpressure -> overflow strategies;
  SetTimeout/SetInterval -> RunAfter/RunEvery), a three-tier model
  (Container stzReactiveSystem -> Stream -> Rfunction), and DECLARE-THEN-
  EXECUTE: the pipeline is a pure description until RunLoop() activates it.
  Stream pipelines (Map/Filter/Reduce/OnPassed/OnError/OnNoMore) are GREEN
  (9/9 core suite). NOTE: libuv was REMOVED from Reaxis (2026-06-13) -- it
  runs on cooperative polling now; the test narration still claiming
  "libuv thread pool" is stale.
- stzReactiveObject: Watch / Computed(attr, fn, deps) / BindTo / Batch /
  StreamAttribute / debounce -- a Vue/MobX-grade reactive-ATTRIBUTE surface,
  and the single most intelligence-relevant piece... currently BROKEN:
  the R54 attribute-redefinition init bug retired 8 of its 9 tests.
- stzReactor + stzReactorPool (base/common/) over VENDORED libuv 1.52.1 on
  a worker thread: REAL async -- Ring submits work, gets a job id, then
  poll/await (Ring never receives a callback; the blocking-looking model is
  preserved by design). Concurrent TCP/fetch, cancellation tokens
  (stzCancelToken, green), pool retry/latency machinery. THE strategic
  runtime for agents.
- engine reactive.zig: a native observable-channel bus (create/subscribe/
  emit; built expressly as "the Reaxis engine foundation") -- ORPHANED:
  compiled and loaded, ZERO Ring callers. Wire-or-retire decision needed.

WHY IT EMPOWERS INTELLIGENCE (today: ZERO cross-references between the
reactive layers and any intelligence module -- all of this is the wiring
the roadmap adds, none of it new machinery):
- knowledge: Computed(attr, fn, deps) IS a derived-fact engine -- a fact
  changes, dependent knowledge recomputes. Needs (i) the R54 fix and
  (ii) change-emission hooks on stzKnowledgeGraph (AddFact publishes).
- patterns: Filter -> OnPassed is structurally a production rule; piping
  Softanzuter matches into streams = reactive rules over flowing data.
- planner: a plan as a Computed value over the facts it depends on =
  REPLANNING when the world changes (needs a planner invalidation hook).
- neural: StzNextToken() pull-streaming is a natural stream producer;
  off-thread generation = one new reactor job type (like the TCP op).
- agents: the perceive-decide-act loop IS an event loop -- build it on
  stzReactor (real async + cancellation + pool), NOT the cooperative
  poller. The reactor's submit/await idiom fits a synchronous decide step.

HYGIENE found: the R54 init bug (SetAttributeValue does addattribute +
eval per set); WaitForAttributetoSettle passes (callback, delay) to
RunAfter(delay, callback); overflow :BUFFER/:BLOCK are print-only
simulations; stzHttpTask never stores its status; libuv-era corpses
(LibuvLoop NULL stub, identity buffer converters) + the stale narration;
duplicate constant families (OPTIMISED_/OPTIMIzED_, BINDING_/BIND_);
three names for one class (stzReactiveSystem/stzReactive/stzReactiveEngine).

### 5.5 DECISION -- the OPTIMIZATION+ML foundation  (stats/ + engine)

THE PI DOCTRINE, stated once and plainly: Softanza REVOKES the full-LLM
thesis. Intelligence is not defined as "call a giant model" -- it is
KNOWLEDGE + search + optimization + learning + rules + NEW KNOWLEDGE
(the bracketed equation of 0.1: the computational ability to derive new
knowledge from existing knowledge), running locally, explaining itself,
costing nothing (LAWS 2+3). LLMs are ONE TIER of the ladder, never its
definition. A doctrine like that needs an engine room; this foundation is
the middle of the bracket -- the derivation machinery between knowledge
in and knowledge out.

WHAT EXISTS (verified -- the honest ledger):
- stzLinearSolver: already ~70% of a modeling object -- variables with
  bounds/integrality, constraints, maximize/minimize, backend dispatch,
  reporting. Backends: greedy REAL (efficiency-ratio allocation), genetic
  REAL (population/tournament/crossover/mutation); simplex = a
  ZEROS-RETURNING STUB (hardcoded tableau, the pivot loop never iterates);
  branch&bound BROKEN (fed by the dead simplex + a live bug in
  createRelaxedProblem). The one test comparing solvers was retired --
  exactly why the stub survives CI.
- stzMultiObjectiveSolver: NSGA-II GENUINELY IMPLEMENTED (non-dominated
  sorting, crowding distance, Pareto front, best-compromise) -- the most
  complete real optimizer in the Ring layer today.
- stzStochasticSolver: scenarios + chance constraints; four modes real but
  all reduce to greedy under scenario weighting.
- stzCoeffExtractor: the shared expression parser -- fragile substring
  parsing + a numerical-differentiation fallback over eval(); its own
  header warns about it; flagged #TODO for replacement.
- Classic ML present: OLS regression/correlation/covariance/Spearman
  (engine stats.zig), vector-similarity kernels (cosine/Euclidean/
  Manhattan/dot -- similarity.zig), TextRank, the perceptron POS tagger.
  ABSENT: kNN, k-means, naive Bayes, decision-tree learner, logistic
  regression, TF-IDF, apriori, PCA -- the PI-ML gap.
- engine constraint.zig is value VALIDATION (not CSP); solver.zig is
  scalar root-finding only; NO vendored LP solver -- but addGgml (a large
  C++ library compiled from source under Zig, no CMake) is the executed
  precedent that makes vendoring one routine.

THE MODELING DSL (ZIMPL-class, Softanza-style) -- three coexisting
surfaces, per LAW 1 + the 4.3 multi-paradigm doctrine:
1. THE ENTRY OBJECT -- stzOptimModel:
       oM = new stzOptimModel()
       oM.Vars([ :x = [0, 40], :y = [0, :integer] ])
       oM.Maximize("3*x + 2*y")
       oM.SubjectTo([ "x + y <= 50", "2*x + y <= 80" ])
       oM.SolveWith(:auto)
       ? oM.Solution()  ? oM.Why()      # LAW 3: names the engine, narrates
2. THE SENTENCE SURFACE -- Naturally("maximize ... where ... stays under
   ..."), parsed by the stzListex grammar family into the same model AST.
3. THE FORMAT -- *.zopt (LAW 1; precedent = .zknw/.flow): sets,
   params, indexed variable/constraint FAMILIES ("for all p in Products")
   -- THE capability today's longhand solver lacks. Expressions compile
   through expr.zig's bytecode (the W-DSL engine), retiring
   stzCoeffExtractor's eval-based parsing.

   [AMENDED 2026-08-22, on building it: **THE ENGINE NAMED HERE CANNOT DO
   THIS, AND A BETTER ONE CAN.** Measured from Ring, both directions:
   `expr.zig` has `<=` but **no named variables** -- its whole variable
   vocabulary is `@item`, `@i`, `@accumulator`, `@char`,
   `@numberofitems` and `This[k]`, so `3*x + 2*y` is refused
   (`StzEngineListEvalColumnsDense` returns an EMPTY list; the same call
   with `3*This[1] + 2*This[2]` returns 5 at x=y=1). And `autodiff.zig`
   has named variables but **no comparison operators**
   (`StzEngineGradCompile("x + y <= 50", "x,y")` is refused with *"there
   is a character the expression cannot use"*). Neither engine alone
   spans one constraint string.
   **What ships instead, and it is strictly better than what was
   designed:** a linear form's GRADIENT *is* its coefficient vector, so
   ONE autodiff tape pass returns the constant term and every
   coefficient exactly -- `4*x - 2*y + 7` answers `[7, 4, -2]`, with no
   step size to choose and no eval() anywhere. The relation is split
   Ring-side on `<=` / `>=` / `=` (four string positions, not
   arithmetic) and each side compiled separately, so `2*x + 3 <= y + 10`
   is read as `2x - y <= 7` with no term-shuffling. The design's INTENT
   -- compile expressions in the engine, retire the eval-based parsing --
   is met; the MECHANISM is `autodiff.zig`, not `expr.zig`.
   **Scope of the retirement, stated honestly:** the new modelling layer
   never touches `stzCoeffExtractor`. It still backs `stzStochasticSolver`
   and `stzMultiObjectiveSolver`, and rewiring those is a separate
   migration against working code with passing guards -- named here so it
   is not read as done. See `base/optim/stzOptimExpr.ring`.]

EXECUTION -- two tiers per LAW 2 (graceful degradation): own Zig
simplex+B&B floor (engine/src/optim.zig -- honest, zero-dependency, small
models and teaching) -> vendored HiGHS (MIT, modern LP/MIP) as the
transparent large-model upgrade. SolveWith(:auto) picks; Why() reports
which tier ran -- identical in shape to lexical->embeddings and
linguistic->neural.

[AMENDED 2026-08-22: **the floor is BUILT and the upgrade tier is
deliberately absent.** `engine/src/optim.zig` takes a clean MODEL
(objective, matrix, senses, right-hand sides, bounds, integrality) and
owns the tableau layout, because branch-and-bound solves a TREE of LPs
and rebuilding that tableau Ring-side would pay the build cost once per
node -- which is the same measured logic that kept the layout in Ring
for `simplex.zig`, reaching the opposite answer because the node count
is what grows. It reuses `simplex.zig`'s pivot loop unchanged.
`SolveWith(:highs)` is **REFUSED** rather than silently downgraded: a
quiet fallback is how a two-tier claim stops being true. `Why()` names
the tier that ran and says the upgrade tier is not vendored. Reported
statuses are optimal / unbounded / infeasible / iteration-limit /
node-limit / no-lower-bound -- and node-limit is distinct on purpose,
because a feasible incumbent nobody proved optimal is a different claim
from an optimum.]

THE CLASSIC-ML ROSTER (ranked by intelligence-per-line; the rollout order
writes itself):
- FLOOR, no numeric blockers, rides stzDataSet + stzSimilarity AS THEY
  EXIST TODAY: kNN (zero training, "the nearest examples were..." = pure
  LAW 3) -> naive Bayes (text, ties into linguistic/) -> TF-IDF (the
  missing vectorizer feeding everything) -> decision tree (ID3/CART; the
  MOST explainable model, and its output IS a stzGraph -- foundations
  compose) -> apriori association rules (explainable if-then itemsets).
- POST matrix-hygiene (R4 steps 1-2): k-means, logistic regression.

DESTINY -- the PI DECISION STACK (LAW 5 made concrete, one cycle):
  1. PERCEIVE/MODEL   classic ML (kNN/Bayes/tree over stzDataSet +
                      stzSimilarity) classifies the world state; facts land
                      in the agent's stzKnowledgeGraph memory (R1).
  2. DECIDE           stzGraphPlanner runs goal-predicate search and
                      returns Actions(); where a step allocates scarce
                      resources it calls stzOptimModel as a SUB-SOLVER --
                      optimization becomes a planner skill.
  3. REACT            the Softanzuter (fixpoint-upgraded) fires production
                      rules; stzGraphRule holds the invariants.
  4. LEARN/SCORE      stzDataSet + the stats engine score executed plans;
                      BestHistoricalPlan() closes the loop -- the agent
                      improves WITHOUT any LLM.
Every box in that stack except stzOptimModel and the ML roster is ALREADY
BUILT AND TESTED. Programmatic Intelligence does not need inventing; it
needs an honest optimizer, five-to-seven classic algorithms, and the
declarative model surface. That is what makes the revoked-LLM thesis
DEFENSIBLE rather than rhetorical.

### 5.6 The Uter Ladder -- Regexuter, Softanzuter, Agent (the definitions)

The author's definition, adopted verbatim and made mechanical: **a
SOFTANZUTER is a computational representation of a THINKING MACHINE,
based on one or many Regexuters, enabling it to identify and react to
PATTERNS OF THOUGHT.** The ladder, rung by rung -- each rung adds
exactly one thing:

RUNG 0 -- THE PATTERN (the ...ex family): pure RECOGNITION. A pattern
knows a shape in a medium (string, list, number, matrix, table, time,
graph) and can say "this matches, and here is how" (Explain). It does
nothing.

RUNG 1 -- THE REGEXUTER (generically: an XUTER -- stzRegexUter,
stzListexUter, ...; one per medium): a REFLEX ARC. Patterns over ONE
medium, each bound to code; Process(data) fires what matches and records
a dependency-tracked state (dependsOn / affects / GetDependencyChain).
It recognizes and REACTS -- stimulus to response, with provenance -- but
holds no goals and does not deliberate. A FACULTY, not a mind.

RUNG 2 -- THE SOFTANZUTER: the thinking machine. One or MANY Xuters
(faculties over different media) sharing a dependency-tracked state and
CASCADING TO FIXPOINT (the R5 upgrade): the state one faculty writes is
a medium other faculties match over. "Patterns of THOUGHT" is thereby
mechanical, not metaphorical: a THOUGHT = a state entry (value +
provenance); the thought HISTORY is a list -- stzListex matches over it;
the dependency chain is a graph -- stzGraphex matches over it. So
META-COGNITION rides the SAME pattern family, no new machinery (LAW 5).
THINKING = the cascade of pattern-firings over the machine's own states;
a SETTLED THOUGHT = the fixpoint. Deterministic, auditable (every
thought carries its Why), interruptible.

RUNG 3 -- THE AGENT (stzAgent): a Softanzuter EMBODIED IN A WORLD. The
Softanzuter is the agent's MIND; the agent adds the body and the stakes:
a GOAL (stzGoal + the planner -- the deliberation the reflex rungs
lack), MEMORY (the knowledge graph), TOOLS (meta/), PERCEPTION-ACTION
(the reactive foundation's event loop), ACCOUNTABILITY (Why on every
act). The containment question answered precisely: AGENTS CONTAIN
SOFTANZUTERS (at least one, the cognitive core); SOFTANZUTERS CONTAIN
XUTERS (their faculties); no rung contains the rung above it.
Collaboration happens ABOVE the ladder: agents compose into the native
stack (0.3) and application colonies; stzApp is the world they live in.

THE INDUSTRY NOTION, THE SOFTANZA WAY. Today's industry "agent" = an
LLM in a loop with tools, memory, and a goal. Softanza ACCEPTS THE
SHAPE: that loop IS rung 3, and the skill/tool/memory vocabulary maps
one-to-one -- programmers and machine programmers (LAW 6) feel at home.
And it REVOKES THE MANDATORY LLM MIND:
- the mind is PROGRAMMATIC BY DEFAULT (Softanzuter + planner + optimizer
  + the ML floor) -- stzPIAgent;
- an LLM is a PLUGGABLE FACULTY -- one generative Xuter among the
  faculties -- never the definition of the mind: stzLLMAgent = the SAME
  embodiment, interfaces, and governance with neural faculties swapped
  in (LAW 2's ladder applied to cognition itself);
- memory is a GOVERNED GRAPH, not a vector soup: derivation replaces
  RAG (0.1), and admission stays governed (0.3) even when the suggester
  is a model;
- skills VERIFY (precondition + plan + verification); prompts do not.
The industry loop is the SPECIAL CASE of this ladder -- one faculty, no
governance. Softanza offers the general case, locally, for free.

### 5.7 GOVERNANCE -- the layer over all foundations (the Zin concordance)

Modern AI lacks PROGRAMMATIC GOVERNANCE; Softanza thrives at it. The
2026-07-13 study of the Zin corpus (D:/GitHub/zin/doc -- the product the
author builds ON TOP of Softanza; Zin depends on Softanza, never the
inverse; Softanza stays free and open source) returned two findings:

FINDING 1 -- CONCORDANCE, point for point. Zin's governed-AI doctrine is
the same intelligence philosophy this document articulates -- and the
lineage is EXPLICIT: Zin's planner profiles are documented as
"stzGraphPlanner heritage"; its knowledge design cites stzGraphRule/
stzGraph/stzGraphQuery by name; its reading guide has a "Softanza
distillations" tier. Revoked-LLM thesis, knowledge-bracketed
intelligence, derivation-replaces-RAG, pi/llm agents over the same
interfaces, governed admission, wise-coding-vs-vibe-coding -- all
mirrored. The Softanza design is VALIDATED by its first product.

FINDING 2 -- THE GAP Zin most needs filled: governance as a CHECKABLE
PROPERTY, not a value statement. Zin's own move is "agents are
subgraphs; governance is a set of graph predicates" proved before the
program runs. The PLATFORM fundamentals (general-purpose, product-
stripped) Softanza adopts as foundational work:

- G1 THE AGENTIC GOVERNANCE GRAPH (stzAgentGraph over stzGraph): typed
  node kinds (pi/llm/hybrid actor, function, tool, guardian, effect,
  human checkpoint, trace sink), edge kinds (feeds/proposes/guards/
  commits/escalates/traces), a CAPABILITY LATTICE (effectful/sensing/
  compute/inference) and TAINT COLOURS (trusted/open-llm-text/
  external-data/validated). The rule that matters: an LLM actor's
  capability set is EMPTY; a hybrid (LLM creativity -> effects) is
  legal ONLY under a declared pi-guardian.
- G2 GOVERNANCE PREDICATES AS RUNNABLE VALIDATORS (LAW 6 made real):
  "no llm node holds effectful", "every effect is dominated by a
  guardian", "no open-text edge reaches an effect", "every effect
  reaches a trace sink", "every rejection reaches a human checkpoint"
  -- all are graph algorithms Softanza ALREADY OWNS (reachability,
  dominance, colouring). Softanza's honest claim: GOVERNED ADMISSION
  WITH INSPECTABLE VALIDATORS (checked before commit), not
  compile-time proof -- that stricter form is the product's job.
- G3 stzLLMFunction (neural/): the LLM call as a PURE TYPED FUNCTION --
  typed I/O, grammar-constrained decoding COMPILED FROM THE TYPE
  (GBNF/JSON-schema: the sampler cannot emit a violating token),
  golden-set tested, memoised by content hash (determinism-by-cache:
  the second run is free), mandatory BUDGET, zero capabilities.
  Distinct from stzNeuralChat (a session) and stzLLMAgent (an actor).
- G4 THE GROUNDING CONTRACT (knowledge/): Prove(goal) returns a proof
  + derivation trace; a declared, TYPED context package (facts with
  provenance and authority, never text chunks) feeds any model as
  GROUND TRUTH -- the mechanism behind "derivation replaces RAG".
- G5 THE TRACE FOUNDATION (stzTrace): every run leaves a timestamped
  SUBGRAPH of the declaration graph (nodes fired, value hashes,
  taints, cost, rejected paths, escalations) -- so diff, replay,
  blame, and cost attribution are ordinary graph operations. Extends
  Why() from per-verdict to PER-RUN.
- G6 THE GOVERNANCE PRIMITIVES (governance/, R4b): ActionRiskTier,
  AuthorityType (advisory/delegated/autonomous/emergency-override),
  CommitmentState (exploratory->provisional->committed),
  DecommissionContract, DecisionLineage -- plus the structural split
  of PERMISSION (can) from AUTHORITY (should). All ride stzGraphRule.
- G7 human_checkpoint: a first-class human-in-the-loop node on every
  rejection path (TTL auto-refuse, context preserved).
- G8 KNOWLEDGE HYGIENE, strict mode (knowledge/): mandatory
  provenance+confidence per fact, bounded queries, EXPLICIT
  contradiction (named, never silently resolved), scope isolation,
  revision with rollback. OPT-IN, to not break existing AddFact use.
- G9 BUDGET as a declared, governed concern (per call/session, cost in
  the trace, escalation to a budget guardian) -- LAW 2's complement
  for when a remote tier IS chosen.
- G10 SIGNABLE PREDICATE SETS (meta/): the CONSTITUTION MECHANISM --
  a declared, diffable, signable set of governance predicates the
  validators enforce. Softanza ships the mechanism; any specific
  constitution (articles, jurisdictions, regimes) is product space.

THE BOUNDARY PRINCIPLE (what stays out): wherever the source idea is "a
graph algorithm / a type rule / a capability label / a declared
contract", it is PLATFORM (here). Wherever it is "a pillar name / a
pack / a CLI / a tier / a jurisdiction profile / a market", it is
PRODUCT and must NOT leak into Softanza. Named tensions resolved:
Softanza claims validator-checked admission (not compile-time proof);
ships no fixed constitution (only the mechanism); keeps ITS meaning of
Wise Coding (elicitation, 0.3); makes provenance strictness opt-in; and
aligns superposition collapse (0.3) with the taint rule -- an
ungoverned model suggestion NEVER becomes an effect.

### 5.8 REFINEMENT -- the Refine concordance (stzPolyCode comes home)

The 2026-07-13 study of the SECOND Softanza-based product: Refine
(D:/GitHub/refine -- an IDE + change-governance layer founded on a book
and the Refinement-Oriented/Centered Programming paradigm, RCP), paired
with a code study of stzPolyCode inside stzlib (the author's FIRST
STIMULUS for it, years ago).

TRIPLE COHERENCE (Softanza / Zin / Refine) -- VERIFIED. All three run
the same doctrine: graph-primary, LLM demoted to ONE AUTHORITY among
many, governed admission (not proof), lineage-as-query, human
checkpoints, permission-vs-authority split. And Refine's lineage is
explicit and one-to-one: RCP is documented as implemented ON Softanza's
graph machinery -- stzGraph = the system graph, stzGraphRule = the
rules, stzGraphex = the pattern authority, stzGraphPlanner = the planner
authority, stzGraphView = scoped perspectives, stzGraphQuery = the
discovery surface, stzKnowledgeGraph = decision lineage. Refine's own
words: "This is not coincidence... system transformation is structurally
a special case of business decision modeling." The two products confirm
the platform from two directions: Zin governs AGENTS ACTING; Refine
governs CHANGE ITSELF -- complementary frames, one doctrine. (Semantics
kept distinct: Refine's graph is the CODE-SYSTEM graph; Softanza's
knowledge graph is the DOMAIN brain. Related, never conflated.)

WHAT REFINE ADDS that neither round captured (platform-worthy):
- THE REFINEMENT AS THE UNIT OF WORK: the atomic unit of programming is
  no longer the line/diff/PR but a TYPED TRANSFORMATION of a subset of
  the graph, carrying its cascade, author, verification, and history --
  and every author (human, template, solver, LLM) produces
  transformations of IDENTICAL SHAPE.
- THE CASCADE AS THE REVIEW SURFACE: the computed, cross-boundary blast
  radius, presented BEFORE commit -- "what you read instead of the
  diff". Softanza owns ImpactOf/reachability; the packaging is new.
- REVERSIBILITY AS A DATA-MODEL PRIMITIVE: every committed
  transformation captures prior state and exposes a typed inverse with
  atomic revert -- built into the graph, not layered on as UX.
- EXECUTION TRUST POSTURES: trusted in-process / external / sandboxed
  LLM-composed -- every execution carries a posture and lands in the
  audit chain.
- (Research-grade, optional) PATCH-THEORY commutation for sound
  multi-authority merge/cherry-pick/revert; ROM-style stable object
  model for governed third-party scripting.

stzPolyCode, THE GROUND TRUTH (code-verified): ~95% vision, ~5% code.
No stzPolyCode class exists; the canonical narration (refinement-centered
programming: code carrying <R:PARAM|BLOCK|ALGO|FUNC|PIPELINE|VARTYPE|
LIB> refinement points -- named adjustment knobs -- through an
Exploration -> Refinement -> Production workflow) is fully designed; the
only executable trace is stzAppRefinement (~21 lines:
Refine(:balance).Bounds(0, 1000000)) plus stzCCode's REAL, tested
transpiler as seed machinery. One ambiguity RESOLVED here: the engine
plan's "multi-representation code store" reading is set aside; the
narration's REFINEMENT-POINTS reading is the original intent and the
one with machinery. One inconsistency for S0: the engine MACROPLAN
marks stz_polycode/stz_polyglot [DONE] with no source in the tree.

THE DECISION -- refine/ AS A DOMAIN (LAW 1): stzPolyCode is redefined
as the refine/ module (map entry; roadmap R6). Its EXECUTION sense
(trusted polyglot running) is a different concern and lands as the
trust-posture wrapper in governance/ (R4b). Boundary holds as before:
the paradigm mechanics (typed refinement points, the 4-stage gate, the
cascade, reversibility) are PLATFORM; the book, the brand, the IDE/PX,
live-refinement UX, the three-domain (code/UI/data) product framing,
jurisdiction packs, and business model are PRODUCT and never leak.
Note: nothing in Softanza may assume Refine's licensing (undecided);
Softanza stays FOSS regardless. One doctrine note for R5: stzPIAgent
(Ring, the Softanzuter mind) is THE platform PI-agent; engine-bodied
product agents are REALIZATIONS of the same interface -- the doctrine
must not fork.

THE EXPERIENCE (how refinement happens in Softanza, for programmers
AND agents):

    o = StzRefinableCodeQ(ReadFile("pricing.ring"))
    ? o.RefinementPoints()        # the R-tags: the code's DECLARED,
                                  # typed change surface
    ? o.Explain(:vat_rate)        # kind, bounds, current value, lineage
    o.Refine(:vat_rate).To(0.20)  # a TYPED PROPOSAL -- not a diff
    ? o.Cascade()                 # the blast radius, BEFORE applying
    o.Apply()                     # the gate: structural -> constraint
                                  # -> derivation -> governance; Why()
    o.Revert()                    # the typed inverse

And through the OTHER doors unchanged: natural ("raise the VAT rate to
20 percent"), conversational (wise coding ASKS: "vat_rate is bounded
0..0.25 -- which value?"), by EXAMPLE (desired outputs in, knob values
INDUCED). REFINEMENT IS THE ANSWER PROTOCOL APPLIED TO ARTIFACTS: a
proposal is a candidate answer, the gate is the same admission funnel,
the cascade is the enumerate-before-choose branch, Why() narrates, and
evidentiality stamps the verdict. For AGENTS (LAW 6) this is the
SAFEST WRITE SURFACE they can be given: typed proposals against
declared knobs -- discoverable (the points are the agent's affordance
map, as the harvest is for Ask), bounded, gate-validated, reversible;
the gate does not care who authored the proposal. The reviewer-
attention crisis, answered at the library level.

GRAPHS CARRY THE WHOLE STORY: points = typed nodes anchored in the code
graph (R2); a refinement = a typed transformation; CASCADE =
reachability/ImpactOf; the GATE = stzGraphRule phases; lineage = the
trace subgraph; reversibility = inverse transformations as graph
events; discovery = stzGraphQuery; multi-point coordination = the
planner ordering refinements by dependency; Graphex MATCHES refinement
patterns. Without the graph, refinement is find-and-replace with
ceremony; on the graph, it is a governed transformation calculus.

WHAT THE FOUNDATION SAYS THAT THE PRODUCT WON'T:
1. REFINEMENT IS UNIVERSAL, not code-bound: anything living in a graph
   is refinable through the SAME gate -- the knowledgebase's facts and
   rules, an optimization model's Vars bounds (.zopt knobs ARE
   refinement points), a plan's profile, a conversation policy. The
   product must focus (code/UI/data); the foundation must generalize
   (LAW 1 makes every domain graph-backed, hence refinable).
2. REFINEMENT COMPOSES with the whole intelligence stack, for free:
   evidential verdicts, wise-coding elicitation, answer-by-example
   induction of knob values, Softanzuter reactions to refinement
   state, agents refining as ONE SKILL among skills. The product ships
   an IDE; the foundation ships refinement as a LIBRARY VERB available
   to every program.
3. THE ZERO-CEREMONY FLOOR (LAW 2): one line, no IDE, no server, no
   product -- Q(code).RefineQ(:knob).To(v).Applied() -- and it still
   passes the same gate. Graceful degradation applies to refinement
   itself.
4. REFINEMENT IS KNOWLEDGE DERIVATION (the 0.1 bracket): existing
   graph + rules + a proposal -> a new admitted state + lineage = new
   knowledge derived from existing knowledge. The product speaks
   version-control's language (change governance); the foundation
   names the deeper fact: refinement is the knowledgebase's WRITE
   OPERATION generalized to artifacts.
5. PERMANENCE: the mechanics (points, gate, cascade, reversibility)
   are FOSS in Softanza forever, whatever any product decides.

POLYGLOT REFINEMENT (the author's extension, 2026-07-13): Softanza
refines ANY language it supports, not only Ring. Three design rulings:

1. EXECUTION TIERS, not a swap (LAW 2 + the R4b trust postures, twice
   confirmed): (a) the EMBEDDED FLOOR -- a small embeddable Python
   implementation VENDORED INTO THE ENGINE (the ggml no-CMake build
   precedent; PocketPy-class: C11, MIT, tiny) -- zero external install,
   scripting-grade, sandboxable; (b) the FFI TIER -- dynamically load
   the SYSTEM CPython shared library (python3x.dll) through the C API:
   the full ecosystem (numpy/pandas) when Python is present, in-process,
   microseconds not process spawns; (c) the EXTERNAL TIER -- today's
   extercode subprocess, maximal isolation. Why() names the tier that
   ran. HONESTY: the embedded floor is NOT CPython (no C extensions) --
   the capability difference is declared, never blurred.

2. THE LANGUAGE IS THE AUTHORITY IN ITS OWN GATE (the keystone).
   Softanza never writes a Python parser: the LIFT runs Python's own
   ast module (on the embedded/FFI tier) to produce stzPyCodeGraph --
   a language-tagged sibling of stzCodeGraph (R2). The gate's
   STRUCTURAL stage is delegated to the language itself (ast.parse /
   compile IS the check); the CONSTRAINT / DERIVATION / GOVERNANCE
   stages stay Softanza's -- language-agnostic, graph-side. After
   Apply, the language re-validates the result. This generalizes for
   free: Prolog validates Prolog, Julia validates Julia. The R-tag
   grammar is language-agnostic because it lives in COMMENTS
   (# <R:PARAM ...> in Python).

3. SPAN SURGERY over full regeneration (the fidelity floor). Full
   regenerate-from-graph loses comments and formatting (the classic
   unparse problem) -- that "text is one rendering of the graph"
   ambition is product-grade. The platform floor stores CODEPOINT-EXACT
   SPANS per refinement point (the engine's string machinery is
   purpose-built for this) and Apply() rewrites ONLY those spans; the
   whole file then goes back to the language for structural
   re-validation. Fidelity preserved, honesty preserved.

The loop, end to end: import Python -> its own ast lifts it ->
stzPyCodeGraph (+ R-tag points) -> typed refinement proposed through
any door -> gate (structural BY PYTHON, the rest by Softanza) ->
cascade previewed -> span-anchored Apply -> Python re-validates ->
lineage recorded, revert available. One gate, many languages.

### 5.9 THE MODEL FOUNDRY -- knowledgebase -> language model (the ZLM
concordance)

The 2026-07-13 study of ZLM in the Zin corpus, and the author's raised
ambition: Softanza as a powerful, VERY ACCESSIBLE environment for
MAKING MODELS -- especially SMALL language models, the strategic tier
per Softanza's pragmatism (complex challenges, simple cheap tools):
supply a domain knowledgebase, compose primitives from the
intelligence arsenal, and the domain's language model is ready.

DISAMBIGUATION FIRST: in Zin, ZLM = the model; Zml/.zml = the
constitutional grammar it emits. And the decisive finding: the
CANONICAL ZLM IS NOT NEURAL. Zin designed a 1-3B transformer (v1),
then its own critical review ARCHIVED it in favor of rule-based
Constructive Semantic Prediction: typed chunks, each validated by the
compiler BEFORE acceptance -- "hallucination is impossible because the
model cannot generate almost-valid text." ZLM is Zin's institutional
expression of the REVOKED-LLM THESIS -- the doctrine independently
re-derived by the product's own design process. Shared principle,
canonized: THE MODEL PROPOSES, THE VALIDATOR DECIDES.

FOUNDATION FIT (verified): Softanza already owns the entire
inference/validation half ZLM needs -- local GGUF inference with
generate/sample/stream, G3 type->grammar constrained decoding, golden
sets + memoization, the knowledge graph + Prove(), NL generation, and
REAL embeddings (Zin ships hash embeddings today; Softanza exceeds
it). The gap is the model-CREATION half: corpus synthesis from a
knowledgebase, tokenizer training, small-LM training/fine-tuning, and
GGUF EXPORT -- Softanza reads GGUF but cannot yet WRITE one.

THE MODEL LADDER (LAW 2 applied to model-making itself):

RUNG 1 -- THE DETERMINISTIC DOMAIN MODEL (no neurons; Zin's SHIPPED
path; the strategic floor). Walk the knowledgebase graph -> extract
vocabulary (entity names), schema (fields+types), valid tokens
(enums), role scoping (actor permissions), process verbs (flows),
constraints (rules) -> SYNTHESIZE A CONSTRAINED GRAMMAR from them (G3
machinery pointed at a domain) -> decode under it, gate with golden
sets, validate every construct against the graph. A usable,
governed domain language model with ZERO training, ZERO cost --
compose-and-go. Nearly every primitive already exists.

RUNG 2 -- THE NEURAL DOMAIN SLM (when fluency earns its cost). The
missing platform pieces, in build order:
1. CORPUS SYNTHESIS FROM THE KNOWLEDGEBASE -- facts + rules rendered
   as text by the NATURAL LAYER (derivation pointed at text; graph
   walks + templates + NNL renderings), every example VALIDATED by
   the rung-1 grammar before admission ("training data correct by
   construction"). LAW-2 GUARD: NO REMOTE TEACHER -- Zin's archived
   pipeline used Claude/GPT-4 as corpus teacher; Softanza's version
   is teacher-free by design.
2. dedup (MinHash) + stzDataset containers (R4).
3. TOKENIZER TRAINING on the domain corpus.
4. small-LM training/fine-tuning on the ggml backward pass (the R4
   bridge), sentence-like declaration per LAW 4.
5. QUANTIZE + GGUF EXPORT -- Softanza learns to WRITE the format it
   reads; neural/ consumes the foundry's own products. (Preference
   alignment/DPO deferred; constrained decoding at inference already
   covers most of its value.)

Both rungs end at the same gate: generations are proposals, the graph
and its rules decide admission. The 0.1 north star extends one step:
feed ONE .zknw file -> an operational intelligent system -> AND,
when wanted, the domain's own language model.

THE DLM RULING (author, 2026-07-13): the ZLM CONCEPT is donated from
the Zin product arena to the open-source foundation as the **DLM --
DOMAIN LANGUAGE MODEL**: the generic, named artifact the Model Foundry
produces. Any Softanza project that supplies a knowledgebase can ship
its DLM FREE to the users of its knowledge-based domain -- the domain
gains its own governed voice at zero cost. Under LAW 1:
  ENTRY: stzDLM (stzDomainLanguageModel)   FORMAT: *.zdlm
  -- a bundle of the synthesized domain grammar + lexicon + templates
  + golden sets (+ optionally the rung-2 GGUF when a neural tier was
  forged). Rung 1 is EVERY DLM's floor; rung 2 is optional fluency.
  neural/ runs it, conversation/ speaks through it, the gate governs
  its every generation.
The boundary, redrawn cleanly: the DLM concept and machinery =
PLATFORM (free, forever); ZLM = Zin's PRODUCT INSTANTIATION of the
platform DLM (DLM + the Zml grammar + the constitution + Zin corpora
+ hosted tiers). Refine may likewise instantiate a DLM over the
refinement domain. The concept flows DOWN to the foundation; only the
worlds stay product.

### 5.10 DELIVERY -- App, SuperApp, Platform, and the computational
server (studied 2026-07-14)

The last plane of the design: how a Softanza solution IS MODELED, RUNS,
and SHIPS. Two code studies (the app corpus; the app-server corpus incl.
the unfinalized future/doc articles) ground it.

WHAT EXISTS (verified):
- stzApp -- "an application is a LIVING WORLD OF MEANING": DOMAIN/Being
  (things+truths+relations on stzGraph), LIFE/Becoming (Behavior flows
  + PURPOSE: goals as wanted graph states, plans on the PI ladder,
  "an agent is simply a world whose purpose is declared and whose plans
  may reason"), BODY/Embodiment (declared residence, .zgrf/.zrul)
  -- plus four emergents: Presence (seen), Intent (engaged), Refinement
  (tuned, the 5.8 knobs), REACH (appears; explicitly NOT Body).
  Code truth: one 403-line file; Slice A/Being GREEN; B-E are
  narrating stubs (the sub-builder brace-copy trap); Pursue() returns
  a hardcoded empty Gap; Generate(:all) is CALLED in the narration
  and DOES NOT EXIST in code.
- stzSuperApp -- "a living constellation of worlds": a governed graph
  whose nodes are stzApps (graph-of-graphs, recursively), sharing a
  COMMONS ("world zero": identity/data/services), bound by norm-gated
  BONDS, under an ambient GOVERNANCE; hot-swappable worlds via a
  registry graph. DESIGN-ONLY (no code).
- stzAppServer -- THE COMPUTATIONAL SERVER PARADIGM (future/doc
  articles + base/appserver skeleton): "treating Softanza as a
  PERSISTENT COMPUTATIONAL ENGINE rather than a per-request library" --
  invert the 80/20 load/compute cost; Express-like surface; context
  pool; polyglot EXCIS fleet; domain-specialized computational
  clustering; a Supabase-class MBaaS vision. Code truth: a PRE-ENGINE
  skeleton, never re-checked after the Zig engine (confirmed): the
  response Send is commented out, it calls stzTcpServer methods that
  no longer exist, no read loop, the compute-engine preloads are
  no-ops, the cluster "proxies" in-process and its monitor busy-loops
  on random() metrics, and the whole pipeline rides Reaxis -- the
  cooperative poller the runtime doctrine (5.4) already disqualified
  for servers.

THE PARADIGM'S FATE: VALIDATED AND SURPASSED. The "persistent
computational brain" the 2024 articles wished for IS the Zig engine --
always resident, Unicode/NLP/graph/neural warm by construction. Nothing
in the paradigm is invalidated; almost everything must be RE-WIRED to
the engine built after the docs were frozen.

THE CONVERGENCE (the study's strongest finding): all four target
topologies -- classic WEB, MBaaS, IoT, AGENTIC -- reduce to ONE missing
spine plus one missing bridge:
- a REACTOR-DRIVEN SERVICE HOST: async accept + per-connection read
  streams + connection registry + lifecycle/supervision on stzReactor
  (real libuv), NOT Reaxis; and
- the SQLITE BRIDGE: vendored in the engine, wired to nothing --
  the quiet blocker for MBaaS CRUD and IoT telemetry.
Engine gaps, honestly: an HTTP/1.1 SERVER (only a test fixture exists;
it is the seed), server-side reactor job kinds (today: timers +
outbound TCP only), inbound TLS, async spawn for the polyglot fleet.
And the AGENT HOST IS THE SAME HOST: R5's perceive-decide-act loop
wants exactly this reactor spine -- an agent is a supervised,
cancellable, traced, DECOMMISSIONABLE (R4b) long-running service.
[LANDED 2026-07-23: `oSrv.HostAgents()` makes the sentence literal --
the agent host shares the server's reactor, and the serve loop ticks
the agents between bounded socket slices. See topology 4 below.]

R7 SERVICE-HOST STATUS (2026-07-16): every gap above is now closed. The
reactor-driven service host (stzAppServer on stzReactor) serves WEB routes,
the SQLITE BRIDGE (stz_db.dll / stzDatabase) is wired, and the MBaaS floor is
now the FULL CRUD surface -- `Expose(db, table)` (or `ExposeWithKey` for a
custom key) gives GET list / GET :id / POST / PUT :id / DELETE :id, all
injection-safe, with honest 404s; IoT telemetry rides the raw-listener floor
into the same db; inbound TLS (server termination) + async spawn landed with
R8. reactor-narrated 26/26.

stzPlatform -- THE MISSING BACKEND, now defined. stzApp models the
WORLD and entirely lacks the OPERATIONAL ENVELOPE; the gap is
DOC-SHAPED (the design names the API without building it). stzPlatform
is that envelope, one construct with five duties:
1. GENERATION: Generate(:all) made real -- declared Reach becomes
   per-platform shells (web/desktop/mobile) embedding the one engine;
2. THE CAPABILITY SEAM (the design's "stz.platform"): device/native
   capabilities (camera, offline, storage, notifications, payments)
   granted by Admits(...) With([...]) and GATED BY GOVERNANCE (the
   capability lattice of 5.7 -- same vocabulary, no new machinery);
3. THE COMMONS RUNTIME: identity/auth sessions, messaging, stores --
   the operational counterpart of SuperApp's declared Provides/Shares;
4. THE NETWORKED BODY: the single-file .zgrf body exposed
   multi-user over the wire (through the service host + sqlite);
5. REGISTRY + ENFORCEMENT: the discovery graph as a runtime (push/
   update/retire worlds) and governance norms actually INTERCEPTING
   cross-world calls.

THE DELIVERY PLANE, stated once:
  stzApp        the WORLD          (what the solution IS)
  stzSuperApp   the CONSTELLATION  (worlds composed, commons, norms)
  stzPlatform   the ENVELOPE       (build, deploy, capabilities,
                                    services, registry, enforcement)
  stzAppServer  the HOST           (one reactor spine; specializes to
                                    web / MBaaS / IoT / agent hosting)
Declare the world; declare its envelope; the host runs both --
whatever the topology, with NO dependency beyond engine + stzlib.
COLLAPSE RULINGS: stzContextPool folds into stzReactorPool (real
threads; the "context" abstraction predates the resident engine);
cluster/ folds into the host's worker model (domain-specialized
workers, not a parallel class tree); the server re-bases from Reaxis
onto stzReactor.

---

## 6. THE ONE ROADMAP (refactor + enhance in the same movement)

Rules for EVERY step: entry objects first; existing sugar preserved
byte-for-byte; all suites green before the step closes; narrated tests for
each new surface; docs + memory updated; both remotes pushed.

**R1 -- knowledge/ (INTEGRATION).**
Marry natural/'s world onto the EXISTING graph/stzKnowledgeGraph:

```ring
# ONE default knowledge graph behind the natural sugar:
StzKnow("paris", "city")                          # == oDKG.AddFact("paris", "is-a", "city")
StzKnowRelation("paris", "capital-of", "france")  # == oDKG.AddFact(...)
? WhatIs("paris")              # reads the DEFAULT graph (types + edges)
? AreRelated("piston", "car")  # rides stzGraph paths/reachability

# and the graph object is directly usable, persistable:
oKg = DefaultKnowledgeGraph()
oKg.WriteToKnowFile("world")     # -> world.zknw (the format EXISTS)
```

- retire $aStzRelations/$aStzRelationRules into AddFact + stzGraphRule
  (:Unique -> Constraint rule, :Symmetric -> Derivation rule,
  :Transitive -> query-time closure over stzGraph reachability);
- suppositions overlay + evidential certainty carry over unchanged;
- stzEntity/stzListOfEntities move in beside the graph;
- folder naming (graph/ -> knowledge/?) decided by the author here;
- GOVERNANCE SEEDS (5.7): Prove(goal) returning a STRUCTURED proof +
  derivation trace (G4 -- stzGraphRule/Explain is 80% there); the
  knowledge-hygiene STRICT MODE, opt-in (G8: mandatory provenance +
  confidence, bounded queries, explicit contradiction, scoped graphs,
  revision with rollback); the stzAgentGraph node/edge/taint VOCABULARY
  declared (G1 seed); the GRAPH REVERSIBILITY contract seeded (5.8:
  mutating graph ops capture prior state and expose a typed inverse
  with atomic revert -- Refine's data-model primitive, and G8's
  rollback made real);
- ACCEPTANCE (the north star, 0.1): a small DOMAIN knowledgebase
  (.zknw with ontology + rules) loads, answers WhatIs/AreRelated,
  and a newly added fact FIRES derivation rules -- intelligence visibly
  augmented with zero code change.

**R2 -- meta/ (+ THE CODE GRAPH).**
Promote stzSelfDoc/stzLibDoc/harvest/recipes/test-sample records to meta/;
reflect/ keeps parsing primitives; ask-probe and semantic-retrieval suites
stay the regression guard. FOUNDATION MOVE: build **stzCodeGraph** (the
design doc's stzCode spec) -- the harvested corpus becomes NODES (classes,
methods, helpers) and EDGES (defines/delegates-to/forwards-to/inherits,
already detected by the harvest levers!) instead of flat records: DeadCode()
via ReachableFrom, ImpactOf(method), CyclicCalls(), refactor planning via
the planner; Ask/WhatIs answer over STRUCTURE, not just text.
PLUS THE MACHINE DOOR (LAW 6): the same meta/ machinery serves the agent
programmer -- Ask answers in STRUCTURED form (not only prose), the house
rules become RUNNABLE validators (check a diff for Q-convention, form
semantics, engine-first violations before it lands), and narrated tests
are surfaced as the executable examples an agent learns from.
GOVERNANCE VALIDATORS join them (5.7 G2): the graph-predicate invariants
("no llm node holds effectful", "every effect dominated by a guardian",
"no open-text reaches an effect", ...) exposed as checks any agent runs
before committing -- plus the SIGNABLE PREDICATE-SET format (G10, the
constitution mechanism: declared, diffable, signable, enforced by these
validators).
CASCADE AS REVIEW (5.8): ImpactOf packaged as a pre-commit
Cascade(change) query over the code graph -- the affected-node set with
typed edges, computed BEFORE mutation, presented as the review artifact.

**R3 -- linguistic/ (the NLTK offensive).**
One step = the refactor AND the gap-closing together:
- stzText moves in as the ENTRY OBJECT; stzPlural/stzSingular/stzOrdinal/
  stzAdverb join it; natural/ keeps language-as-code only;
- NEW: the POS-PATTERN CHUNKER -- built ON stzListex over tag streams
  (the composition Graphex already proves; do NOT build a new engine):
  Chunks("DT? JJ* NN+") -> noun phrases; covers NLTK's RegexpParser with a
  cleaner grammar (the out-design move, not just parity);
- NEW: corpora/ shelf + stzCorpus entry object (small corpora embedded,
  large fetched-on-demand, gitignored -- exactly like models/);
- NEW: n-gram LM utilities (probabilities/perplexity over the existing
  counts, engine-side);
- the 4.2 table re-audited; every green row gets its Ask-able intent.

**R3b -- conversation/ (conversational programming, organically rebuilt).**
stzNeuralChat stays in neural/ as the model-backed ENGINE; conversation/
becomes the DOMAIN (map entry above):
- stzConversation ENTRY OBJECT: multi-turn state (topic, goals, grounding,
  history), persisted as *.zcnv;
- stzQuestion supplies the interrogative frames (exists); stzGoal gives
  the conversation its purpose (ties to stzGraphGoal, R5); stzNarration
  promotes the narration culture (Why-chains, evidentiality, prose) into
  the system's side of the dialogue;
- GROUNDED in the knowledge graph (R1): the conversation reads AND writes
  the knowledgebase under its rules -- the 0.2 conversational door; the
  ontology drives the clarifying questions;
- WISE CODING (0.3): the conversation is SYSTEM-LED -- the ontology
  defines what a complete domain model needs; the gap between that and
  the current knowledgebase GENERATES the next questions (goal-driven
  slot filling: stzGoal + stzQuestion over the graph); the session ends
  by WRITING the .zknw and standing the system up;
- THE ANSWER PROTOCOL (0.3): replies accepted in five registers --
  proposed option / data structure / formula-script / natural-NNL /
  EXAMPLES (pattern INDUCTION over the ...ex family builds the
  computable candidate); every candidate is validated against the graph
  + its rules before admission: unique -> accept + narrate, several ->
  enumerate and let the user choose, none -> refuse with reasons and
  nearest alternatives;
- LAW 2 ladder: deterministic floor (lexicon + frames + templates) works
  with NO model; stzNeuralChat upgrades fluency when a GGUF is present;
- human_checkpoint (5.7 G7): the escalation node -- rejections and
  low-certainty admissions route to a human with context preserved and
  TTL auto-refuse; the conversation stays a PROJECTION of the governed
  graph, never a parallel stack.

**R4 -- learning/ + optim/ (creation + decision) -- RIDES THE NUMERIC
FOUNDATION.** Step order matters:
0. THE CLASSIC-ML FLOOR (no numeric blockers -- can start anytime): kNN,
   naive Bayes, TF-IDF, decision tree (ID3 -> emits a stzGraph), apriori --
   riding stzDataSet + stzSimilarity exactly as they exist today.
1. MATRIX HYGIENE: expose Transpose (engine has it); add elementwise
   subtract/multiply/divide, dot/norm/trace; add Solve(Ax=b) via
   Gauss-Jordan first, LU next; wire stzRandom distributions
   (normal/uniform) -- the training prerequisites.
2. THE GGML BRIDGE: stzMatrix <-> ggml tensor (both contiguous float
   arrays) -- BLAS-grade matmul + the vendored backward pass become
   available to ALL numerics, not just neural/.
3. stzDataset (tables/lists/labeled text) + stzNeuralNetwork with the
   sentence-like API + stzTrainer/stzModelEvaluation (metrics ride the
   already-engine-backed stzDataSet statistics); k-means + logistic
   regression join the ML roster here (post steps 1-2).
4. FIRST APPLIED TARGET: the trainable TEXT CLASSIFIER (closes the last
   big 4.2 row).
5. optim/ -- THE MODELING DSL (section 5.5) [NOT STARTED as of 2026-08-22:
   no base/optim/, no stzOptimModel, no .zopt -- the SOLVER FLOOR exists
   (engine/src/simplex.zig + stats/stzLinearSolver + stzMultiObjectiveSolver),
   the MODELLING DSL over it does not. See 3.1.2 -- it blocks R5's
   OPTIMIZATION leg and the capstone's menu-optimization scene]:
   stzOptimModel entry object +
   *.zopt format (sets/params/indexed families); expressions compiled by
   expr.zig (retire stzCoeffExtractor); REAL simplex + B&B in
   engine/src/optim.zig as the floor, vendored HiGHS as the upgrade tier
   (SolveWith(:auto), Why() names the engine); UN-RETIRE the
   solver-comparison test as the honesty guard; stzMultiObjectiveSolver
   (NSGA-II) moves in beside it.
   [AMENDED 2026-08-22 -- **DELIVERED**, with one mechanism corrected and
   one item found already done. `base/optim/` now holds all three
   surfaces onto ONE AST: `stzOptimModel` (the entry object),
   `stzOptimFile` (*.zopt with sets, params and indexed variable and
   constraint families -- `sum ... for p in Products` and
   `forall p in Products` expand to longhand BEFORE the model sees them,
   so the format is a front end and not a second engine), and
   `stzOptimSentence` (`StzOptimNaturally`). The two surfaces are proven
   to agree by comparing `ASTSignature()`, never answers -- two wrong
   models can share a number. `engine/src/optim.zig` is the floor
   (simplex + branch-and-bound over `simplex.zig`'s pivot loop, 12
   standalone Zig tests); HiGHS is NOT vendored and `SolveWith(:highs)`
   is refused rather than downgraded, per the "do not vendor on day one"
   instruction. **Expressions compile through `autodiff.zig`, not
   `expr.zig`** -- see the amendment in 5.5; the intent is met and the
   named mechanism was wrong. **stzCoeffExtractor is retired for the new
   path only** and still backs stzStochasticSolver and
   stzMultiObjectiveSolver. `stzMultiObjectiveSolver` HAS moved to
   `base/optim/`, and the stale second copy under `future/` (841 lines,
   older, referenced by nothing) was removed rather than left to be
   found again. **The solver-comparison test was already un-retired** by
   an earlier session (`test/linearsolver/13_same_problem_different_solvers.ring`,
   green); the new guard extends it to compare the modelling object with
   both older backends on one model and print all three. Guard:
   `base/test/optim/optim_modelling_narrated.ring`, 59 assertions, 0.06s.]
6. stzLLMFunction (5.7 G3): the pure typed LLM primitive -- type->
   grammar compilation (GBNF for local GGUF, JSON-schema for remote),
   content-hash memoization, golden-set tests woven into the narrated
   culture, mandatory BUDGET (G9) with cost recorded in the trace.
7. THE MODEL FOUNDRY, RUNG 1 (5.9 -- compose-and-go, no training):
   knowledgebase graph -> vocabulary/schema/rules extraction ->
   DOMAIN GRAMMAR SYNTHESIS (the G3 machinery pointed at a domain) ->
   constrained decoding + golden sets + graph validation = the DLM
   (stzDLM, *.zdlm bundle): a usable, governed DOMAIN LANGUAGE MODEL
   from ONE .zknw file, shippable FREE to the domain's users.
8. THE MODEL FOUNDRY, RUNG 2 (neural, when fluency earns its cost):
   teacher-free CORPUS SYNTHESIS from the knowledgebase (the natural
   layer renders facts+rules as text; every example validated by the
   rung-1 grammar -- correct by construction; NO remote teacher, LAW
   2) -> MinHash dedup -> TOKENIZER TRAINING -> small-LM training/
   fine-tuning on the ggml backward pass -> QUANTIZE + GGUF EXPORT
   (Softanza learns to WRITE the format it reads). The model proposes,
   the validator decides -- generations pass the same gate as any
   proposal.

**R4b -- governance/ (the primitives -- independently shippable).**
The five declarable contracts + the permission/authority split (5.7 G6),
all riding stzGraphRule: ActionRiskTier gates actions by risk level;
AuthorityType distinguishes advisory/delegated/autonomous/emergency;
CommitmentState makes exploration/commitment explicit and forward-only;
DecommissionContract makes agent retirement a declared obligation
(credential revocation, data removal, audit preservation);
DecisionLineage weaves rationale + authority + production traces.
PLUS the EXECUTION TRUST POSTURES (5.8 -- the redefinition of
stzPolyCode's EXECUTION sense): every polyglot / external / LLM-composed
code execution carries a declared posture (trusted / external /
sandboxed), resource limits, and lands its trace in the audit chain.
Mechanism only -- no fixed constitution ships with Softanza.
[AMENDED 2026-08-22, ruling 3.2: DELIVERED -- all five contracts plus the trust
postures ship in governance/stzGovernance.ring. TWO ARE NOW OWED ON TOP, promoted
from what the Bangalo loop program proved in practice: a SIXTH contract
**ReversibilityClass** (reversible / compensable / irreversible -- .pia declares it,
the engine loop enforces it, and stzGovernance has never heard of it), and the
**REGISTRATION GATE** -- an actor with no coverage statement and no reversibility
class is refused before it can be scheduled at all, which is a different question
from MayProceed and is answered at a different moment.]
[AMENDED 2026-08-22, second session -- BOTH OWED CONTRACTS DELIVERED.
**ReversibilityClass** is contract 6 in stzGovernance
(`DeclareReversibility`/`ReversibilityOf`, the three .pia words as the whole
vocabulary, persisted in a `.zgov` `reversibility` section beside the postures it
composes with). The **registration gate** is `MayRegister(actor, coverage, class)`
in the same file, refusing in agentloop.zig's own AGENTLOOP-R4/R5 sentences --
one rule, two doors, same words. The gate's DEFAULT FLIP (Supervise refusing
undeclared agents on the Ring pump) remains a migration step per the ruling's own
condition "the default flips when the last in-tree host declares": hosts in
appserver/, cluster/ and perf/ supervise without declaring and belong to other
planes. The composition of contract 6 with the 5.8 postures is one sentence,
`StzPostureReversibilityRefusal` (trusted covers all three classes; external
covers reversible+compensable; sandboxed covers reversible only), quoted by both
stzGovernance.MayExecuteFor and the .pia v2 court. Guard:
test/agentic/safeworld_narrated.ring.]

**R5 -- agentic/ (composition) -- THE FOUNDATIONS CONVERGE.**
[AMENDED 2026-08-22: PARTIAL. **Read ruling 3.2 before this section** -- it settles
`CENTRAL-AGENTDOCTRINE-01`. In short: the .pia declaration is R5's DECLARATIVE DOOR,
not a fork of its doctrine, and is promoted from the "*.zagn considered on demand"
line at the foot of this section to DELIVERED under its real name. What R5 still owes:
stzOptimModel (blocked on R4 step 5), four of five native agents, stzHybridAgent as a
class, and -- the largest -- BINDING THE SAFE WORLD: base/agentic/ contains zero
references to stzVirtualSystem / stzUpdatePlan / stzCommitScope, while a shipped .pia
agent writes to the real filesystem through the `ring:` escape.]
[AMENDED 2026-08-22, second session -- THE SAFE WORLD IS BOUND, and the `ring:`
escape is closed by version rather than by removal. Delivered:
**stzAgentWorkbench** (agentic/stzAgentWorkbench.ring) -- an stzVirtualFileSystem
held in a process-global table, reached through id-carrying faces (the
engine-wrapper copy law in pure Ring); `stzPIAgent.GiveWorkbench()` opens one,
`Cycle()` brackets it as the AMBIENT bench so a ring: function reaches it as
`StzActiveWorkbenchQ()` with no signature change, and the tick's ONLY export
toward reality is `GenerateUpdatePlan()`, committed by a committing actor under
stzUpdatePlan's three gates. **pia: 2** requires `posture: trusted | external |
sandboxed` on any skill (or proposes input) with a ring: clause, composes a
does:-slot's posture against the agent's reversibility class in
StzPostureReversibilityRefusal's own sentence, and lands what the file declares in
the agent's OWN governance (contract 6 + DeclarePosture per ring function). v1
remains READ -- the stated migration state, recorded in stzAgentDeclaration's
header: the live estate's declarations are v1 and not this repository's to edit;
the admission ends when they bump. **stzAgentRoster is the first consumer**: its
write paths go through the safe-world door (_StzRosterFile* helpers) -- inside a
workbench-holding agent's tick the relocation rehearses and the ledger moves only
on plan commit; outside one it is the direct write the live estate still runs.
Proof: test/agentic/safeworld_narrated.ring, 76 assertions -- including the twin
producing the IDENTICAL ledger the direct path produces. Still owed by R5 after
this: stzOptimModel (R4 step 5, prompt 48), four native agents, stzHybridAgent,
and the constitution's Layer-4 negotiation verbs (Receive/Revise,
stzAgentEvaluation, branch-per-hypothesis).]
stzAgent + stzAgentSkill/Memory/Tool interfaces; stzPIAgent FIRST
(deterministic, zero-cost, the differentiator), stzLLMAgent second (same
interfaces over neural/). The PI-agent is ASSEMBLED, not invented (the 5.6 ladder: Xuter
faculties -> Softanzuter mind -> embodied agent):
- PLANNING = stzGraphPlanner (goal-predicate search, profiles, Actions()
  sequences, history learning -- ALREADY BUILT) + the missing
  **stzGraphGoal** goal-modeling layer (Gap()/Profile(), stubbed in stzApp);
- REACTION = the Softanzuter upgraded to fixpoint cascading (dependent
  triggers re-fire) = production-rule skills;
- OPTIMIZATION = stzOptimModel (R4 step 5) called by the planner as a
  sub-solver for resource-allocation skills;
- RUNTIME = the reactive foundation: the perceive-decide-act loop runs on
  stzReactor (REAL libuv async, cancellation tokens, pool retry) -- NOT
  the cooperative poller; perception = async reactor fetches; neural token
  streaming = one new reactor job type;
- CURRENCY = replanning: stzKnowledgeGraph gains change-emission hooks
  (AddFact publishes) and plans become Computed values over the facts they
  depend on (requires the R54 stzReactiveObject fix -- see S0);
- GOVERNANCE = the full stzAgentGraph (5.7 G1: capability lattice, taint
  colours, guardians) + the THREE INJECTION GATES (typed prompt-in,
  grammar-bounded output-out, guarded tool-call-back) + the G2 validators
  run at composition time + stzHybridAgent (LLM creativity -> effects
  ONLY under a declared pi-guardian);
- ACCOUNTABILITY = the trace foundation (5.7 G5): every run leaves a
  timestamped subgraph -- diff, replay, blame, cost attribution as
  ordinary graph operations;
- memory = stzKnowledgeGraph (R1), tools = meta/stzCodeGraph (R2),
  language = linguistic+natural (R3), brains = neural/learning/optim (R4);
- stzApp is the studied precedent (Being/Behavior/Purpose mapping);
- DOCTRINE GUARD (5.8): stzPIAgent (Ring, the Softanzuter mind) is THE
  platform PI-agent; engine-bodied product agents (Zig) are product
  REALIZATIONS of the same interface -- the doctrine must not fork;
- THE NATIVE STACK: the curated library-internal agents Softanza's own
  features consume FIRST (the 0.3 solution space: analyze the reply in
  every register, induce, validate, rank, plan the next question) --
  the roster is a designer decision taken here (candidate natives:
  elicitation / induction / validation / ranking / planning agents);
  programmers extend in the APPLICATION space over the same interfaces.
Parse trees and *.zagn agent files considered here, on demand.

**R6 -- refine/ (refinement programming -- needs R1 + R2 + the
reversibility contract).**
stzPolyCode's first-stimulus idea, rebuilt as a domain (5.8):
- stzRefinableCode ENTRY OBJECT over *.zrfn: source carrying the
  R-tag refinement points (the narration's grammar, finally parsed);
- stzRefinement = the typed graph transformation (uniform shape for
  every author -- human, template, solver, LLM); the GATE = the 4-stage
  pipeline composed from stzGraphRule; the CASCADE presented before
  commit; REVERSIBILITY riding the R1 contract;
- the render/Apply step seeds from stzCCode's working transpiler;
- the AI-guidance layer (Explore/Ask/TestRefinement) rides
  conversation/ (R3b) + neural/ -- no private machinery;
- OPTIONAL (research-grade): patch-commutation predicates for sound
  multi-authority merge; ROM-style stable object surface for governed
  third-party Ring scripts (with meta/, LAW 6);
- POLYGLOT REFINEMENT (5.8, Python first):
  1. stz_python engine module -- the EMBEDDED interpreter floor
     (vendored, ggml-style) + the FFI tier (dynamic load of system
     CPython) + today's extercode subprocess as the external tier;
     tier selection :auto, Why() names it, postures per R4b;
  2. stzPyCodeGraph -- the LIFT via Python's OWN ast (the language is
     the authority in its own gate); R-tag points in comments;
  3. span-anchored Apply (codepoint-exact, formatting preserved) +
     re-validation BY the language + the same cascade/lineage/revert;
  4. then one contract per supported language (stzXXCodeGraph) --
     R for statistics, Julia for numerics, Prolog for logic -- each
     validating its own structural stage.

**R7 -- the DELIVERY PLANE (app/ + platform/ + appserver/, 5.10).**
[COMPLETE 2026-07-14 except the deferrals noted inline; commits
981364d86 (sqlite) + 7f5762eab..0388d987d. F5 (Reaxis re-based onto
the reactor; poller = documented no-DLL fallback) landed in the same
movement.] Step order matters:
1. THE ENGINE TRIO [DONE]: the HTTP/1.1 server grew INSIDE reactor.zig
   (engine-side framing: Content-Length, keep-alive, pipelining;
   testserver.zig stays the offline client-hardening fixture);
   server-side reactor job kinds (listen/accept + per-connection read
   streams + accept/data/closed events, write/close control ops);
   the SQLITE BRIDGE wired (stz_db.dll + data/stzDatabase).
2. REBUILD THE SERVER SPINE on stzReactor [DONE]: real listener ->
   parse -> route -> dispatch -> WRITE (exact-match routes; params/
   wildcards deferred); stzContextPool + compute-engine preloads
   retired as collapse-ruling tombstones; cluster/ folding deferred
   with the R5 worker model.
3. ONE HOST, FOUR TOPOLOGIES [4 of 4 DONE]: web (routes over the
   engine-framed listener); MBaaS (CRUD floor over sqlite; auth/
   sessions live in stzPlatform's Commons -- KDF = engine gap);
   IoT (raw per-connection streams on the same loop); AGENTS
   [DONE 2026-07-23, 2e266a0a5] -- `HostAgents()` attaches an
   stzAgentHost that SHARES the server's reactor, and the serve
   loop INTERLEAVES: a bounded slice on the socket, then tick
   whatever is due. Without that bound, `ServeOne` parks for the
   whole remaining time on an idle socket and the agents starve;
   with it, 300ms of `RunFor` and zero traffic still ticks the
   agents, and an ordinary route still answers mid-flight. Timer-
   AND event-driven supervision both ride the serve loop. The HTTP
   surface (`/agents`, `/agents/<name>`, `/agents/trace`) is
   READ-ONLY by doctrine -- pausing and retiring are effects, and a
   socket carries no actor, so control stays in-process where R4b's
   decommission contract gates it. Guard
   `64_appserver_agents_narrated` (35).
4. stzPlatform [DONE, new platform/ domain]: Generate(:all) real
   (Reach -> web/desktop/mobile shells); the capability seam gated
   by the 5.7 lattice via R4b governance; the Commons runtime; the
   networked body (GET /world, /thing over the host); the registry
   + norm-enforced CallAcross.
5. FINISH THE WORLD [DONE]: slices B-E converted to the proven
   cursor/return-This pattern (brace-copy trap sealed); Pursue()
   wired to the REAL gap via stzGraphGoal (GapOn(liveGraph);
   instances via Is_/Relate isa-edges); Live() MADE REAL -- reactions
   fire into proposals (Pulse/React), composes with stzAgentHost;
   stzSuperApp is CODE now -- a governed graph-of-graphs (real world
   objects, shared Commons, norm-gated CallAcross, hot-swap,
   recursion).

POST-R7 SWEEP [DONE 2026-07-14, "do them all"]: the deferrals above
are cleared except inbound TLS. (a) R5 REACTOR RUNTIME -- stzAgentHost
runs PI-agents as supervised/cancellable/traced/decommissionable
reactor jobs (R4b MayRetire gate). (b) ROUTER params/wildcards. (c) R6
GATE-DEEPENING -- refine stages 3 (cross-point derivation, rollback) +
4 (stzGovernance) wired. (d) stzPyCodeGraph -- polyglot code-graph over
Python. (e) COMMONS KDF -- engine PBKDF2/CSPRNG, no plaintext secrets.
(f) ASYNC SPAWN -- uv_spawn polyglot fleet floor. (g) OUTBOUND TLS --
async https on the reactor (uv_queue_work + curl/Schannel), reactive
HTTP rewired. (h) CAPSTONE -- test/capstone/restaurant threads R1->R7,
28/28. STILL DEFERRED: INBOUND server-side TLS (needs a vendored
accept-side TLS lib + handshake-over-libuv); R2 call-edges (body
parsing); a true-ast stzPyCodeGraph backend (now unblocked by spawn).

**S0 -- FOUNDATION HYGIENE (do alongside R1):**
- patterns: fix stzRegexUter.Compute typo; implement StateByPosition/
  ByComputationOrder; delete stznumbrex-copy.ring;
- graphs: implement or honestly-raise stzGraph.Paths() (PathsWhereF
  depends on it); note the planner constant-heuristic TODO; the
  stzGraph SetNodeProperty/NodeProperty "round-trip bug" was VERIFIED
  NOT BROKEN on Ring 1.27 (S0 2026-07-14: four probe shapes green; the
  old repro hit the bare-new-without-parens trap) -- stzApp's side
  lists retire at R7;
- numerics: expose stzMatrix.Transpose;
- optimization honesty: fix the createRelaxedProblem bug (4-arg call to a
  3-arg addConstraint + undefined [:value]); make the simplex stub RAISE
  or refuse instead of returning zeros, until R4 step 5 replaces it;
- reactive (the R54 fix is MEDIUM -- a class restructure, but it gates
  derived facts + replanning): fix the stzReactiveObject init bug;
  fix WaitForAttributetoSettle's (callback, delay) arg order; make
  stzHttpTask store its status; reconcile the stale "built on libuv"
  narration across Reaxis tests/docs; decide wire-or-retire for the
  orphaned engine event bus (reactive.zig);
- governance seed (5.7, PRIORITIZED -- both products' audit chains
  depend on it): make stzGraphRule/Explain derivations return a
  STRUCTURED, replayable trace (the stzTrace + Prove() seed);
- plan honesty (5.8): the engine MACROPLAN marks stz_polycode and
  stz_polyglot [DONE] with no source in the tree -- correct the plan
  docs to [PLANNED];
- delivery honesty (5.10): mark the appserver skeleton's broken seams
  until R7 rebuilds them (Send commented out, stzTcpServer methods
  that no longer exist, "/*" routes the exact-match router can never
  hit, monitor busy-loop fabricating random() metrics, no-op
  preloads) -- honest raises or removal, no silent pretending.

**THE CAPSTONE TEST (the definition of done for the WHOLE roadmap):**
the restaurant scenario of 0.1. DAY ZERO is wise coding (0.3): the owner
starts with NOTHING -- Softanza interviews them, gap by gap, and writes
restaurant.zknw ITSELF (entities, relations, ontology, rules). Then,
with ZERO app-specific code:
- R1 proves LOAD + GOVERN: facts queried (WhatIs/AreRelated), laws
  enforced, a new fact triggers derivations;
- R2 proves it EXPLAINS ITSELF: Ask over the library AND over the
  knowledgebase's structure;
- R3 proves you can TALK to it: natural surfaces over the domain's own
  vocabulary;
- R3b proves you can BUILD it by talking: the owner adds a dish and a
  house rule in conversation -- the system asks back, validates against
  the ontology, then writes; the knowledgebase grows under governance;
- R4 proves it DECIDES and LEARNS: optimize a menu/roster straight from
  the knowledgebase (stzOptimModel); classify/score with the ML floor;
  and the foundry ships the RESTAURANT'S OWN DLM -- its users get the
  domain's language model for free;
- R5 proves it ACTS: an agent takes a goal ("prepare Saturday's
  service"), plans over the graph, allocates via the optimizer, reacts
  to changes as they stream in;
- R6 proves CHANGE ITSELF IS GOVERNED: the agent refines the menu
  logic through a typed refinement -- the cascade is previewed, the
  gate validates, the audit chain records, and one call reverts;
- R7 proves IT SHIPS, WHATEVER THE TOPOLOGY: the same knowledgebase
  serves the restaurant's WEB portal, its mobile-backend (MBaaS), a
  kitchen-sensor TELEMETRY feed (IoT), and the resident AGENT -- one
  world, one envelope, one host, one engine, zero dependencies.
Adding ONE rule to the .zknw file visibly upgrades every layer above
-- no code change, no training, no retrieval pipeline. That demo IS the
proof of the revoked-LLM thesis. Finally, run the SAME capstone with an
AGENT as the programmer, through the machine door (LAW 6): same doors,
same rules, nothing breaks.

Each R-step is independently shippable; R1 (with S0) is ready to start.

---

## 7. R8 -- the SCALE plane (clustering, re-based on the resident engine)

[COMPLETE 2026-07-15. All six stages shipped, both remotes, 141
narrated assertions. R8.1 stzWorkerProfile/stzWorkerPool (worker model
+ retired class tree); R8.2 stzRequestClassifier (rules + capability-
lexical + model seam); R8.3 stzAppCluster (real worker-process fleet
via reactor spawn + curl proxy + load-balance); R8.4 stzFacetCatalog
(the full ~18-facet breadth, INSTANCE-scoped per the naming law) +
stzClusterSupervisor (health/restart/real-metric autoscale/drain,
running as a supervised job on stzAgentHost); R8.5 stzComputePipeline
(chained facet stages, per-stage budget admission); R8.6
stzComputeFederation (governed multi-host constellation -- discovery +
bond + governance capability lattice + real curl transport, proven with
a live cross-host call). The pre-engine stzCluster* tree is retired to
loadable tombstones.]

Studied 2026-07-14 from the 2024 future/doc corpus (stzappserver_
clustering.md + stz_cluster_core.txt + cluster_usage_example.txt) and
the existing base/cluster/ prototype. R1-R7 built the intelligence
stack and made ONE host serve one world; R8 makes MANY hosts serve at
SCALE. It is the delivery plane's horizontal axis.

THE CORE INVERSION (the study's decisive finding). The 2024 clustering
vision sells ONE value: "specialized hot servers beat cold starts" --
every node PRELOADS NLP/Math/Vision libraries so a request skips a
2-4s load penalty. That premise is OBSOLETE for Softanza. Those
`oComputeEngine.Preload*()` calls are the pre-engine skeleton -- all
NO-OPS (stzComputeEngine is a tombstone). The Zig engine is resident
and warm BY CONSTRUCTION: the full linguistic tier, the neural tier
(ggml/BERT/DLM), numerics (matrix/ggml matmul, real simplex), graph,
and sqlite are hot the instant the process starts. There are NO cold
starts and NO per-domain library loading in one Softanza process. So
"14x faster because already loaded" is trivially true for a SINGLE
process -- the resident engine IS the always-hot farm the doc wished
for. What SURVIVES once specialization-for-warmth is moot:
  1. CONCURRENCY / horizontal scale -- one Ring VM is single-threaded;
     1000+ concurrent requests need many workers across cores/machines.
  2. LOAD ISOLATION -- a heavy neural/vision request must not
     head-of-line-block light NLP requests; domains get RESOURCE
     BUDGETS, not separate libraries.
  3. DISTRIBUTION + FEDERATION -- spanning machines, with SLAs and
     capability gating.
This executes the 5.10 ruling verbatim: cluster/ folds into the host's
WORKER MODEL -- domain-specialized WORKERS, not a parallel class tree.

DOMAIN HONESTY (what each "cluster" really maps to):
  - NLP cluster    -> engine-native (linguistic + neural tier). Real.
  - Math cluster   -> engine-native (matrix/ggml, stats, simplex). Real.
  - Search cluster -> engine-native (BERT embeddings + graph + sqlite
                      = semantic search). Real.
  - Vision/OCR     -> NOT in the engine (no image/OCR). Honest answer:
                      a POLYGLOT-SPAWN worker -- the reactor's async
                      spawn (uv_spawn, R7) runs python/tesseract/opencv
                      off-process and drains the result. Specialization
                      becomes a WORKER PROFILE (capability tag + budget
                      + optional external tool), never a subclass.

THE FACET ONTOLOGY -- the SCALE plane's NAMING LAW (semantic precision,
formalized 2026-07-15). WithFacet() specializes along a FACET, NOT a
MODULE, and the distinction is load-bearing, not cosmetic. Because the
engine is RESIDENT and MONOLITHIC, every worker carries the whole
engine -- there is nothing to "select" or "deploy" per node, so the
specialization axis CANNOT be a physical module (no boundary to
specialize along); it can only be a LOGICAL COMPETENCE used for routing
and budgeting. Calling it "module" would silently re-import the
cold-start/preloading model R8 revoked. Four levels, never collapsed:
  - CAPABILITY (finest): an atomic engine operation (:paths, :embed,
    :sentiment). WHAT THE ENGINE CAN DO.
  - FACET (grouping): a named, coherent set of capabilities (:graph,
    :knowledge). WHAT THE SYSTEM IS COMPETENT AT. Logical; forward-
    declarable; maps to modules 1:1 / 1:n / n:m / 1:0.
  - MODULE (physical): base/graph/ -- WHERE THE CODE LIVES. An
    authoring/maintenance concern, NEVER the specialization unit.
    (~140 modules exist; ~18 facets -- the asymmetry proves they are
    different structures.)
  - PROFILE (configured): stzWorkerProfile = a facet + budget +
    optional external tool, instantiated in a pool/cluster. A DEPLOYED
    specialization.
The facet catalog is an OBJECT (stzFacetCatalog), OWNED by the
pool/cluster INSTANCE -- NOT a global. Two clusters deployed in one
process are INDEPENDENT, each with its own catalog (custom facets,
subsets, per-site competences); global functions are reserved for
constructors + true stateless utilities, never per-deployment config.
The facet<->module relation is EXPLICIT, OPTIONAL, and MANY-TO-MANY --
recorded (stzFacetCatalog.ModulesOf / stzWorkerProfile.RealizedBy) but
never forced to identity:
  :data->[data] (grounded 1:1); :math->[matrix,stats,number] and
  :knowledge->[natural,graph] (composed 1:n); :search->[neural,graph,
  data] (composed, NO search/ module); :nlp->[natural,neural] (logical
  -- the library DELETED the nlp/ folder by ruling, yet the competence
  is real); :vision->[] (external/polyglot, no module at all, 1:0).
MappingKind() reads the relation: :grounded (1 module) / :composed (2+)
/ :external (polyglot, 0) / :logical (0, not polyglot). This is also
the bridge to stzCodeGraph: "which FACETS does touching base/graph/
affect?" is a real cross-structure impact query -- a recorded relation
between two graphs, not a collapse of one into the other. LAW: carve
facets at COMPETENCE joints, even when that cuts across folders; never
drift facet names toward module names for false tidiness.

WHAT R8 REUSES (clustering composes almost entirely from R5+R7):
  node = stzAppServer; intra-process pool = stzReactorPool; launch a
  fleet = reactor async SPAWN (worker PROCESSES, each its own VM +
  resident engine); route/proxy = reactor async CURL/TCP (native TLS);
  supervise/health/restart/drain = stzAgentHost (R4b decommission);
  the cluster-as-a-whole governed = stzSuperApp (norm-gated CallAcross,
  the doc's "SLA/quality guarantees" = the 5.7 capability lattice).
The only genuinely NEW layer is worker-pool + routing + fleet
orchestration.

THE RE-BASED ARCHITECTURE:
  stzAppCluster (front host = stzAppServer)
    -> request classifier (engine-NLP backed: rules + zero-shot)
    -> worker PROFILES (nlp / math / search / vision), each backed by
       in-proc reactor-pool slots OR spawned worker processes
    -> reactor curl/TCP proxy to the fleet
    -> stzAgentHost supervises (health / real-metric autoscale / drain)
    -> bound as a governed stzSuperApp constellation (across machines)
One resident engine per process; specialization is a routing + budget
concept; TRUE multi-core parallelism comes from the PROCESS FLEET
(Ring's VM is single-threaded, so CPU-bound parallelism must cross
processes -- exactly what reactor spawn + curl enable).

THE STAGES (each: engine reuse first, narrated suite, both remotes):
- R8.1 WORKER MODEL + RETIRE THE CLASS TREE: stzWorkerProfile
  ({tag, capabilities, resource budget}) + stzWorkerPool over
  stzReactorPool; a host dispatches domain-tagged work to profile
  slots with load isolation (a heavy job never starves a light one).
  Tombstone stzClusterNode / the stzNLPServer-style tree and the no-op
  oComputeEngine preloads (as stzContextPool/stzComputeEngine were).
- R8.2 THE SMART ROUTER (real, engine-backed): stzRequestClassifier --
  tier-1 deterministic rules (path/method/content-type), tier-2 ENGINE
  zero-shot/embedding classification of request content -> domain
  (dogfoods the neural tier; replaces the doc's hand-wavy balancer).
- R8.3 THE FLEET (true horizontal scale): stzAppCluster = front host +
  a supervised fleet of stzAppServer worker PROCESSES via reactor
  spawn, proxied via reactor curl/TCP. WithNLP(3).WithMath(2) = spawn
  N workers of that profile. Delivers the "1000+ concurrent" scale.
- R8.4 SUPERVISION + REAL METRICS + AUTOSCALE: stzAgentHost supervises
  the fleet; a scaling AGENT reads REAL queue/latency/in-flight counts
  (from the reactor, not random()) and spawns/retires workers; health
  heartbeats; failed node restarts; graceful drain via R4b. The
  random()-metrics monitor is retired.
- R8.5 COMPUTATIONAL PIPELINES: stzComputePipeline chains domain stages
  (Vision->NLP->Compliance->Search) on the reactor's async job
  pipeline; each stage runs on the right worker/profile.
- R8.6 THE GOVERNED CONSTELLATION (distribution/federation): a cluster
  spanning machines IS an stzSuperApp constellation -- cross-node calls
  norm-gated, capabilities gated by governance (the "federated compute
  marketplace" = a governed multi-host SuperApp; reactor curl as
  transport). Closes the doc's federation vision on real primitives.

REVOKED BY R8 (kept as tombstones like stzComputeEngine):
  the stzNLPServer/stzMathServer/... PARALLEL CLASS TREE and all
  oComputeEngine.Preload*() (obsolete -- engine resident); the framing
  that clustering exists to AVOID COLD STARTS (revoked -- it exists for
  concurrency, isolation, and governed distribution); the busy-loop
  random() metrics monitor (replaced with real reactor metrics).

Start at R8.1 + R8.3 (worker model + spawn/curl fleet) -- the
load-bearing core; routing/scaling/pipelines/federation layer on top.

### 7.1 R8 RESILIENCE -- the fleet under fault (industry-grade #1)

Scale is only credible if a broken worker never breaks the request. Three
standard fault-tolerance patterns are wired into the fleet, all tested in
`base/test/cluster/resilience_narrated.ring` (25 assertions, green):

- BACKPRESSURE (bounded queue / load shedding). A worker profile's queue
  can be bounded (`SetMaxQueue(n)`); once full, further dispatch SHEDS
  (a counted rejection) instead of growing unbounded to OOM. `ShedCount()`
  records it. The default (0) is unbounded -- operators SHOULD set a bound
  in production. This is the honest backstop under the R8.1 load-isolation
  budgets: isolation caps CONCURRENCY, backpressure caps the BACKLOG.

- CIRCUIT BREAKER (per-worker isolation). `SetCircuitBreaker(threshold,
  cooldownMs)`: a worker that fails `threshold` consecutive times has its
  circuit OPENED -- it is skipped by routing for `cooldownMs`, then goes
  HALF-OPEN (eligible for one probe; a success re-closes it, a failure
  re-opens it). A success anywhere resets the worker's failure count. This
  stops the cluster from hammering a dead/black-holed node. `RestartDead`
  clears a respawned worker's circuit (self-healing). `CircuitOpenCount()`
  is the observable.

- RETRY-WITH-FAILOVER. `Route` no longer targets a single round-robin
  worker: it tries up to `SetMaxTries(n)` HEALTHY (ready, non-draining,
  circuit-closed) workers of the facet, in RR-rotated order, and returns
  the first 2xx. A transport error or non-2xx FAILS OVER to the next. So a
  live worker beside a broken sibling keeps success at 100% while the
  breaker quietly isolates the bad one (the LIVE end-to-end scenario:
  8/8 requests served, the dead sibling's circuit opens and it drops out).

Two engine-truth robustness fixes fell out of building this and matter to
every reactor caller, not just the cluster:

- COMPLETION, NOT STALE STATUS. `HttpLastStatus()` is a GLOBAL refreshed
  only when a curl job DRAINS; on an await TIMEOUT it keeps a prior call's
  status. Reading it blindly makes a healthy 200 bleed onto a hung worker.
  A drained job is reaped, so `JobState(id) = -2` proves THIS attempt
  actually completed -- `Route`/`_HealthOk` trust the status only then.
- OWNED vs EXTERNAL workers. `Start()` spawns a process only for fleet
  rows it OWNS (port still 0); `RegisterExternalWorker(facet, host, port)`
  rows carry a real endpoint and are left intact (a remote/static host we
  route to and health-check but do NOT spawn).

### 7.2 R8 OBSERVABILITY -- the fleet made diagnosable (rung #2)

Once workers can fail and fail over, you must be able to SEE it. Wired into
`stzClusterTelemetry` (cluster-owned), fed from `Route`, tested in
`base/test/cluster/observability_narrated.ring` (32 assertions, green):

- LATENCY PERCENTILES, per facet. Each served request's end-to-end latency
  is recorded into that facet's OWN engine histogram (`stzLatencyHistogram`
  / `stz_histogram.dll`, log-scale buckets, O(1) memory + record). `p50 /
  p90 / p95 / p99` per facet, so the TAIL -- where circuit-breaker trips and
  failovers hide, invisible to an average -- is visible, and a heavy vision
  facet's tail never smears a light nlp one. An instant "no routable worker"
  reject is recorded as a trace but NOT as a latency sample (0ms with no
  round-trip would deflate the tail).

- TRACE IDS. Every routed request gets a unique, URL-safe, monotonic id
  (`t-<clock>-<seq>`), recorded with its facet, the endpoint that served it,
  final status, total latency, and the attempt count (>1 = a failover
  happened -- `FailoverTraces()` is the breaker/retry footprint). The id is
  also put ON THE WIRE as a `_trace` query param, so a worker sees the SAME
  id the front host recorded -- genuine request correlation across the fleet
  (proven end to end: the worker echoes the id back). `LastTraceId()`,
  `RecentTraces(n)`, `TraceById(id)` are the read surface; a bounded ring
  keeps memory flat.

### 7.3 R8 RATE LIMITING -- admission control at the front door (rung #3)

The first rungs protect the fleet from ITS OWN workers failing (failover /
breaker) and make it observable. Rate limiting protects it from EXCESSIVE
INBOUND demand -- a flooding client or a runaway loop. Three caps now
compose: load-isolation caps a facet's CONCURRENCY, backpressure caps the
QUEUE behind a busy worker, and rate limiting caps the request RATE over
TIME. New `stzRateLimiter` (common/, reusable), owned by the cluster, tested
in `base/test/cluster/rate_limiting_narrated.ring` (30 assertions, green):

- TOKEN BUCKET, per key. Reuses the engine limiter (resilience.zig /
  stz_resilience.dll): a bucket of `burst` tokens refilling at `rate`/sec,
  so short bursts are absorbed up to the bucket size while the sustained
  rate is capped. Multi-key: a facet, and (for reuse) a caller or client ip
  each get an independent bucket -- a flooded key never starves another.
- FRONT DOOR. `SetRateLimit(facet, ratePerSec, burst)`; `Route` checks the
  bucket BEFORE touching a worker, so an over-limit request is shed with a
  distinct `-429` (callers branch on it vs `-1` no-worker) and never reaches
  or exhausts the fleet. A facet with no limit is UNLIMITED. Every shed is
  TRACED (0 attempts -> not a latency sample), so `RateLimitedCount(facet)`
  and the trace ring show exactly what was turned away.

### 7.4 R8 REQUEST SIGNING -- authenticity + integrity between nodes (rung #4)

Governance decides whether a caller MAY proceed; it TRUSTS the asserted
caller identity. Signing closes that gap: it proves the request IS from that
caller and was not tampered in transit. New `stzRequestSigner` (common/,
reusable), owned by the federation, tested in
`base/test/cluster/request_signing_narrated.ring` (29 assertions, green):

- HMAC-SHA256 over a canonical (method, path, body, timestamp, nonce) with a
  per-caller shared SECRET (engine crypto.zig -- the same primitive as the
  Commons KDF). The canonical form is length-prefixed (injective: no two
  distinct requests collide). Sign() returns an envelope
  [ kid, ts, nonce, sig ]; the receiver, sharing the key, recomputes it.
- FOUR guarantees, each tested against its threat: INTEGRITY (a tampered
  path / body / method fails the MAC), AUTHENTICITY (a wrong or unknown key
  cannot forge), FRESHNESS (a stale or future-dated timestamp fails the skew
  window), REPLAY (a verified (kid, nonce) is accepted once; a second use is
  rejected). Signature comparison is constant-time via DOUBLE-HMAC (re-key
  both sides with a fresh random secret, then compare) -- no byte-by-byte
  loop, so no timing leak AND no Ring in-class char-index VM trap.
- Federation wiring: `RegisterKey(caller, secret)` opts a caller into
  signing; `FederatedCall` signs the request and carries the envelope on the
  wire (`_caller/_ts/_nonce/_sig`). The receiver calls `VerifyInbound` /
  `VerifyInboundEnvelope`. Signing is a SEPARATE gate from governance
  (defense in depth: a signable caller is still refused by an insufficient
  authority) -- and opt-in, so an unkeyed caller transports unsigned.

GOTCHA sealed: the low-level `StzEngineStringNew` handle reads back EMPTY, so
HMAC over it silently ignored the message (every request signed identically).
The engine-backed path is `new stzStringCrypto(msg).HmacSha256(key)` (via a
real stzString handle) -- the canonical way to MAC a string from Ring.

### 7.5 R8 FORCED KILL + ORPHAN CLEANUP -- the fleet-lifecycle closer (rung #5)

`ScaleDown` DRAINS a worker gracefully (routing stops, it finishes in-flight,
self-exits on TTL). But a WEDGED worker -- alive yet answering neither
/health nor its TTL -- needs an OS-level kill. New engine primitive
`reactor_spawn_kill(job_id, signum)` -> `uv_process_kill` (SIGKILL/SIGTERM;
Windows -> TerminateProcess), MUTEX-GUARDED so it can never race the loop
thread reaping the process on its own exit. Tested in
`base/test/cluster/forced_kill_narrated.ring` (19 assertions, green):

- `ForceKill(facet)` SIGKILLs every spawned worker of a facet (the forceful
  sibling of drain); returns the count actually killed, marks them not ready.
  `KilledCount()` is the observable. Idempotent: re-killing an already-dead
  worker returns -3 and is not counted.
- NO ORPHAN ON RESTART: `RestartDead` now force-kills the OLD process before
  respawning -- a worker that reads "dead" (no /health) may be HUNG, not
  gone; respawning without killing it would leak the hung process.
- ORPHAN CLEANUP ON STOP: `Stop()` force-kills every worker PROCESS the
  cluster spawned, so NONE outlive it (the guarantee; TTL self-exit is the
  graceful path). External workers (RegisterExternalWorker, jobId 0) are not
  ours and are always skipped.

Engine note: `reactor_spawn_kill` + its `ring_ReactorSpawnKill` bridge were
added to reactor.zig / ring_bridge_reactor.zig; the reactor DLL was rebuilt
against Ring 1.27. Ring wrapper: `stzReactor.KillSpawn(id, signum)` /
`KillSpawnHard(id)`.

### 7.6 R8 WIRE mTLS between nodes -- IN PROGRESS (rung #6)

The last rung: true mutual-TLS -- both ends terminate TLS and validate X.509
certs, adding what signing does NOT (wire CONFIDENTIALITY + cert-bound
identity). The reactor's SERVER side speaks plain HTTP today (no TLS
termination), so this is a multi-slice engine project. Plan +slice breakdown:
`doc/design/MTLS_PLAN.md`.

- BACKEND: vendored mbedTLS 3.6.2 LTS (not Schannel). Self-contained C,
  vendors + builds with zig like sqlite/pcre2; its buffer-BIO model
  (feed received bytes, get bytes to send) maps cleanly onto libuv.
- SLICE 1 (DONE 2026-07-15): vendored under `engine/vendor/mbedtls/`,
  `addMbedtls()` in build.zig, and `zig build mtls-smoke` runs an in-memory
  server<->client handshake through paired byte pipes (the exact BIO model
  slice 2 feeds from libuv). VERIFIED: TLS 1.3 handshake, encrypted app-data
  round-trip, cleartext confirmed absent from the wire. No reactor changes.
- SLICE 2 (DONE 2026-07-15): the reactor server now TERMINATES TLS.
  `reactor_listen_tls` + a per-conn mbedTLS context with byte BIOs over the
  libuv buffers: `onSrvRead` decrypts to the existing HTTP framing,
  `startWrite` encrypts the response -- transparent, so the Ring
  router/handlers are unchanged. `stzAppServer.StartTls`/`StartHttps`.
  VERIFIED: a real external curl GETs `https://.../health` and validates the
  cert; without the CA it is rejected; the plain-HTTP path is unregressed. A
  non-empty CA + `require_client` demands + validates a CLIENT cert (the
  mutual half) -- exercised fully once slice 3 gives curl a client cert.
- SLICE 3 (DONE 2026-07-15): a dedicated mbedTLS CLIENT (not curl -- Schannel
  can't present a PEM client cert). `reactor_tls_request` over `mbedtls_net`
  presents this node's client cert, validates the peer against a CA (hostname
  via SNI), and reads the framed response. `stzReactor.TlsRequest`/`TlsGet`.
  VERIFIED end-to-end vs a MUTUAL slice-2 server (CA + CA-signed leaf):
  genuine -> served; missing client cert -> server refuses (empty body,
  server-enforced; under TLS 1.3 the body, not the status, is the "let in?"
  signal); wrong CA -> client aborts the handshake. Mutual auth both ways.
- SLICE 4 (DONE 2026-07-15): the FEDERATION transport runs over mTLS.
  `stzComputeFederation.SetMutualTls(cert, key, ca)` -> `FederatedCall` goes
  over the mutual mbedTLS channel (`TlsGet`) instead of curl. So a federated
  call is now ENCRYPTED + MUTUALLY CERT-AUTHENTICATED + SIGNED (7.4) +
  GOVERNED (R4b) -- the full node-to-node security stack. Narrated suite
  `mtls_narrated.ring` (15 assertions): a real mutual-TLS worker driven as a
  client (genuine / missing-cert / wrong-CA) and over a governed federation
  (served over mTLS + signed; governance still gates). RESIDUAL (skipped,
  low value): using the peer-cert CN AS the governed caller identity --
  request signing already cryptographically binds the caller, so this is
  redundant; `oReq.PeerCommonName()` is a small future add if needed.

mTLS COMPLETE (slices 1-4). The resilience/security ladder (rungs 1-6) is
now fully closed: failover/breaker/backpressure, observability, rate
limiting, request signing, forced kill/orphan cleanup, and wire mTLS.

### 7.7 MEMORY-SAFETY FUZZING (quality track #2)

After the resilience ladder (#1), the second industry-grade track hardens the
NATIVE engine's untrusted-input paths -- the surfaces a hostile peer can
reach. Fuzz harnesses live in `engine/src/`, built with safety checks ON
(ReleaseSafe) so any out-of-bounds read, integer overflow, or bad slice
PANICS and fails the step. Run `zig build fuzz` (or `fuzz-http` / `fuzz-tls`).

- HTTP FRAMING (`fuzz_http.zig` -> `http_framing.zig`): the request parser
  that runs on EVERY server connection's raw bytes -- the most-exposed
  untrusted surface. Extracted into its own module so the fuzzer hammers the
  exact code the reactor runs. A regression corpus of nasty edge cases + 1M
  PRNG-mutated, HTTP-biased inputs; every call must never read OOB nor claim
  a frame longer than the buffer. FINDING (fixed): the original
  `header_end + Content-Length` OVERFLOWED usize on a hostile `Content-Length`
  -- a safety build PANICS, i.e. a one-line malformed request could DoS the
  server thread. Fixed with `@addWithOverflow` (an unsatisfiable length now
  reads as "incomplete"). 3M inputs clean after the fix.
- TLS INPUT (`fuzz_tls.zig`), with mbedTLS compiled under UBSan-TRAP
  (`-fsanitize=undefined -fsanitize-trap=undefined`), so any undefined
  behavior in the C TLS parser (signed overflow, misaligned access, bad
  shift, null deref) becomes an illegal-instruction trap that fails the step.
  Two phases: (1) malformed CERT + KEY parsing (raw + PEM-header + base64
  garbage) to `mbedtls_x509_crt_parse` / `mbedtls_pk_parse_key` -- the peer-
  cert surface + our PEM NUL-terminator contract, 150k inputs; (2) RECORD-
  LAYER handshake fuzz -- garbage "ClientHello" bytes fed to a real server
  `mbedtls_ssl` context via the BIO (the reactor's actual TLS read path),
  60k inputs. Both clean: no crash, no UB.

- OTHER VENDORED PARSERS, each under UBSan-trap via its own harness (same
  sources as production, +UBSan): PCRE2 (`fuzz_pcre2.zig`) -- the regex
  compiler + matcher, a classic UB target, fed random patterns + subjects
  (300k); UTF8PROC (`fuzz_utf8.zig`) -- Unicode normalization + the codepoint
  iterator run on every user string, fed mostly-invalid UTF-8 (500k); SQLITE
  (`fuzz_sqlite.zig`) -- `prepare_v2` + step on random SQL-fragment text
  (100k). All clean: no crash, no UB.

UBSan note: trap mode needs no ubsan runtime, so it works in a plain
executable (the fuzz harness) -- side-stepping the ubsan-runtime-in-a-DLL
problem. The DLLs stay uninstrumented; the C is validated through the
harnesses that link the same sources. The vendored file lists are shared
(e.g. `pcre2_files`) so the fuzzed sources never drift from production.

STATUS: every network- or user-reachable native parser is now fuzzed +
UBSan-checked -- HTTP framing (Zig, safety-checked), mbedTLS (cert + record),
PCRE2, utf8proc, SQLite. One real bug found + fixed (the Content-Length DoS).

### 7.8 PROPERTY + MUTATION TESTING (quality track #3)

Where fuzzing asserts "never crashes", property testing asserts CORRECTNESS
via invariants over generated (not example) inputs, and mutation testing
checks those invariants actually catch bugs. `zig build prop`.

- `prop_http.zig` -- the HTTP framing under three invariants over 300k
  generated well-formed requests: (A) SELF-CONSISTENCY (a complete request
  frames to exactly its length); (B) PREFIX STABILITY (trailing/pipelined
  bytes never change the first frame's length -- the guarantee the server
  relies on); (C) INCREMENTAL (every proper prefix is "incomplete", never
  mistaken for complete). The real framer holds all three.
- MUTATION TESTING in the same harness: the properties are re-run against
  three deliberately buggy framers (Content-Length ignored, header-end
  off-by-one, `>` instead of `>=`). Each mutant is KILLED (fails a property),
  proving the invariants have teeth -- they don't pass vacuously. A surviving
  mutant would fail the step as a test-quality gap.

- `prop_ratebucket.zig` -- the token-bucket rate limiter under four
  invariants over random capacities: BURST BOUND (exactly C immediate takes
  from a full bucket, then denials -- the "never admit more than the burst"
  guarantee), CAP (available never exceeds capacity), NON-NEGATIVE, DRAINED
  (a take after draining is denied). Mutants killed: always-take, off-by-one
  burst, lying-available.
- `prop_crypto.zig` -- the crypto primitives underpinning signing + the
  Commons KDF. SHA-256 over 300k inputs (DETERMINISM, SENSITIVITY -- any
  changed byte flips the digest, the basis of tamper detection -- FIXED
  LENGTH); mutants killed: constant-hash, first-byte-only-hash. PBKDF2 over
  20k inputs (DETERMINISM, SALT-SENSITIVITY, PASSWORD-SENSITIVITY -- the
  Commons password-verify invariants).

HONEST SCOPE: line-coverage + a full mutation FRAMEWORK are not available for
Ring on this toolchain (no kcov on Windows, no Ring coverage tool). So track
#3 is realized as (a) engine-side property + mutation harnesses where the code
is callable and invariants are crisp -- HTTP framing, the token bucket, and
the signing/KDF crypto -- and (b) the input-space coverage the fuzz + property
harnesses give the parsers, atop the ~thousands of narrated behavioral
assertions in base/test/. `zig build prop` runs all three.
