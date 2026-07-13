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
same movement, not two plans, running over FIVE SUBSTRATES (section 5).

### 0.1 The North Star: the knowledgebase-driven system

The author's definition, which everything below serves:

> INTELLIGENCE is the computational ability to DERIVE NEW KNOWLEDGE from
> EXISTING KNOWLEDGE. And KNOWLEDGE is the modeling of information in
> GRAPH-BASED form, obeying DOMAIN-SPECIFIC SEMANTICS.

So the full equation is bracketed by knowledge on BOTH ends:

    KNOWLEDGE  ->  search + optimization + learning + rules  ->  NEW KNOWLEDGE

The middle is machinery; the ends are the point. This is why knowledge/ is
R1 and why the graph is the first substrate: the knowledge graph is not one
pillar among six -- it is the INPUT and the OUTPUT of intelligence, and the
other pillars are the derivation engine between them.

THE GOAL, STATED AS AN EXPERIENCE: a programmer -- or the business itself --
supplies a KNOWLEDGEBASE. A restaurant describes its business in a
*.stzknow file: entities, relations, an ontology (domain-specific
semantics), rules. Feeding that ONE FILE to Softanza yields an
industrial-grade intelligent system: any app or solution for that
restaurant is then developed easily on top of a strong, dynamic,
WELL-GOVERNED BRAIN -- the knowledgebase. And the decisive property:
adding one fact or one rule -- by the user, the programmer, or an
intelligent agent -- AUGMENTS THE SYSTEM'S INTELLIGENCE AUTOMATICALLY.
No code change. No training. No RAG machinery. Derivation rules fire
(stzGraphRule), derived facts appear, plans recompute (the reactive
substrate), agents act on the new state.

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

1. THE DSL DOOR (declarative, data-oriented): *.stzknow itself IS the
   program -- readable, diffable, hand-editable, validated on load.
   The format family doctrine (LAW 1): .stzknow / .flow / .stzopt /
   .stzconv -- every stateful domain earns its format.
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
  artifacts: the .stzknow knowledgebase WRITTEN, data in place, an
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
                  Planner/Workflow -- and the *.stzknow FORMAT with a real
                  parser (ImportKnow/ExportToKnow/WriteToKnowFile).
                  THE WORK IS INTEGRATION, NOT CREATION (roadmap R1):
                  natural/'s world becomes SUGAR over a DEFAULT
                  stzKnowledgeGraph; the ad-hoc relation-law globals retire
                  into stzGraphRule; stzEntity moves in beside the graph.
                  FOLDER: whether graph/ is renamed knowledge/ (with
                  diagram/orgchart as visual citizens inside or moved) is
                  the author's naming call; the DOMAIN unification is the
                  substance.
                  ENTRY: stzKnowledgeGraph      FORMAT: *.stzknow
                  SUGAR: StzKnow()/StzKnowRelation()/WhatIs()/AreRelated()

  meta/         META-PROGRAMMING -- the library's knowledge of ITSELF:
                  stzSelfDoc, stzLibDoc (move from reflect/), the harvest,
                  recipes, test-sample records, emb caches (.stzcache).
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
                  ENTRY: stzConversation        FORMAT: *.stzconv

  reactive/     THE TIME SUBSTRATE (exists -- round-2 study, section 5.4):
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

  optim/        DECISION PROGRAMMING (round-2 elevation, section 5.5 --
                  the PI doctrine's engine room; lands in R4):
                  stzOptimModel     the ZIMPL-class modeling object: declare
                                    sets/params/vars/constraints/objective
                                    (hash literals or *.stzopt), then
                                    SolveWith(:auto); Why() names the engine
                                    and narrates the solution (LAW 3)
                  execution tiers   own Zig simplex+B&B floor -> vendored
                                    HiGHS upgrade (LAW 2; the ggml no-CMake
                                    build precedent makes vendoring routine)
                  stzMultiObjectiveSolver (NSGA-II, already REAL) joins it;
                  the classic-ML roster (kNN/NaiveBayes/TF-IDF/ID3/apriori,
                  then k-means/logistic) rides stzDataSet + stzSimilarity.
                  ENTRY: stzOptimModel          FORMAT: *.stzopt

  agentic/      AGENTS (the composition point -- R5):
                  stzAgent          base: goal, skills, memory, tools, Why
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
```

What does NOT change: string/ list/ number/ table/ etc. (the data domains),
engine/ (Zig), the Q-convention, the narrated-test culture.

---

## 3. Current-State Audit (2026-07-13)

| Concern | Verdict |
|---|---|
| /natural holds entities+relations+suppositions as $-globals | WRONG HOME + WRONG SHAPE -- and a PARALLEL WORLD: graph/stzKnowledgeGraph already offers the power (triples/query/ontology/.stzknow). R1 unifies onto a default instance, globals as sugar |
| The 2026-07-13 relation laws ($aStzRelationRules) | DUPLICATE a lesser stzGraphRule (Constraint/Derivation/Validation) -- retire into it in R1 |
| stzText lives in natural/ | Move to linguistic/ as its ENTRY OBJECT (R3) -- natural/ keeps language-as-code only |
| /neural consumes GGUFs only | Right for its scope; CREATION gets learning/ (R4) |
| /reflect hosts self-doc | Mechanics fine; the DOMAIN identity is meta-programming -- promote to meta/ (R2) |
| Evidential + constraint registers as globals in natural/ | Acceptable: DISCOURSE state (per-conversation), not domain data; revisit only if persistence is ever needed |
| stzNeuralChat in neural/ | Right home (a session over a model) |
| stzLinearSolver's simplex | DISHONEST STUB -- returns all-zeros silently (hardcoded tableau, pivot loop never iterates); the one comparing test was retired, which is why it survives. Violates LAW 3; R4 makes it real |
| reactive/ vs intelligence modules | DISJOINT ISLANDS -- zero cross-references today; the derived-state engine (Watch/Computed/BindTo) is blocked by the R54 stzReactiveObject init bug (8 of 9 tests retired); the engine event bus (reactive.zig) is built+loaded but ORPHANED (no Ring callers) |
| Reaxis narration claims "built on libuv" | STALE -- libuv was removed from Reaxis 2026-06-13 (cooperative polling now); real libuv lives in stzReactor. Reconcile in S0 |
| Conversation constructs scattered: stzNeuralChat (neural/), stzQuestion (natural/), narration = culture-only, goals unbuilt | Conversational programming deserves a DOMAIN -- conversation/ reunites them (R3b) |
| The house rules (Q-convention, forms, engine-first) live in docs + folklore | LAW 6: agents can't RUN folklore -- meta/ exposes them as checkable validators (R2) |

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
| Classification | trainable (setup-heavy) | zero-shot TODAY; trainable -> R4 |
| Chunking / parsing | RegexpParser, CFG trees | GAP -> R3 (POS-pattern chunker) |
| Corpora shelf | nltk.download zoo | GAP -> R3 (corpora/ + stzCorpus) |
| Language modeling utils | nltk.lm | PARTIAL -> R3 (LM utils over n-gram counts) |

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

## 5. The Five Substrates (rounds 1+2, 2026-07-13; they run UNDER all pillars)

The author's directive: graphs, the pattern-matching family, the numerical
layer -- and, from the second analysis round, REACTIVITY and the
DECISION machinery (optimization + modeling DSLs + classic ML) -- are not
modules beside the pillars. They are SUBSTRATES the whole intelligence
system runs on. Five deep code studies confirmed it: STRUCTURE (graphs),
RECOGNITION->ACTION (patterns), COMPUTATION (numerics), TIME/CHANGE
(reactive), and DECISION (optimization+ML).

### 5.1 GRAPHS -- the STRUCTURE substrate  (graph/, ~19k lines, 108+ tests)

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

### 5.2 PATTERNS -- the RECOGNITION->ACTION substrate  (regex/, 12 modules)

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
PI-agent's reactive skill substrate (R5).

LATENT: the doc-only executor family (stzRegexAnalyser, stzGeneticRegexuter,
stzLinguisticRegexuter, stzQuanticRegexuter -- vision, no code); pattern-
driven data GENERATION and code translation (stzRegex's own TODO roadmap).
PATTERN INDUCTION -- inferring a Regex/Listex/Graphex FROM user-supplied
EXAMPLES -- is now DEMANDED by the 0.3 answer protocol (answer-by-example):
the doc-only genetic/inference executors finally have their purpose.
HYGIENE found: Compute() typo (cTex) = dead alias; StateByPosition/
StateByComputationOrder TODO stubs in both Uters; stznumbrex-copy.ring
stale duplicate; listexuter tree test retired pending a hash-literal DSL.

DESTINY BY PILLAR: R3's POS chunker = stzListex over tag streams (compose,
do NOT build a new engine -- Graphex proves the layering); R1's graph laws
feed stzGraphRule; R5's PI skills = Softanzuter triggers + planner actions.

### 5.3 NUMERICS -- the COMPUTATION substrate  (number/ + stats/ + engine)

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

DESTINY BY PILLAR: R4 rides this substrate (matrix hygiene -> ggml bridge ->
stzNeuralNetwork); stzDataSet is the evaluation layer (metrics/correlation);
the LP solver becomes the OPTIMIZATION module (real simplex) feeding
PI-agents with resource-allocation skills (R5).

### 5.4 REACTIVITY -- the TIME/CHANGE substrate  (reactive/ + common/ + engine)

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

### 5.5 DECISION -- the OPTIMIZATION+ML substrate  (stats/ + engine)

THE PI DOCTRINE, stated once and plainly: Softanza REVOKES the full-LLM
thesis. Intelligence is not defined as "call a giant model" -- it is
KNOWLEDGE + search + optimization + learning + rules + NEW KNOWLEDGE
(the bracketed equation of 0.1: the computational ability to derive new
knowledge from existing knowledge), running locally, explaining itself,
costing nothing (LAWS 2+3). LLMs are ONE TIER of the ladder, never its
definition. A doctrine like that needs an engine room; this substrate is
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
3. THE FORMAT -- *.stzopt (LAW 1; precedent = .stzknow/.flow): sets,
   params, indexed variable/constraint FAMILIES ("for all p in Products")
   -- THE capability today's longhand solver lacks. Expressions compile
   through expr.zig's bytecode (the W-DSL engine), retiring
   stzCoeffExtractor's eval-based parsing.

EXECUTION -- two tiers per LAW 2 (graceful degradation): own Zig
simplex+B&B floor (engine/src/optim.zig -- honest, zero-dependency, small
models and teaching) -> vendored HiGHS (MIT, modern LP/MIP) as the
transparent large-model upgrade. SolveWith(:auto) picks; Why() reports
which tier ran -- identical in shape to lexical->embeddings and
linguistic->neural.

THE CLASSIC-ML ROSTER (ranked by intelligence-per-line; the rollout order
writes itself):
- FLOOR, no numeric blockers, rides stzDataSet + stzSimilarity AS THEY
  EXIST TODAY: kNN (zero training, "the nearest examples were..." = pure
  LAW 3) -> naive Bayes (text, ties into linguistic/) -> TF-IDF (the
  missing vectorizer feeding everything) -> decision tree (ID3/CART; the
  MOST explainable model, and its output IS a stzGraph -- substrates
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
oKg.WriteToKnowFile("world")     # -> world.stzknow (the format EXISTS)
```

- retire $aStzRelations/$aStzRelationRules into AddFact + stzGraphRule
  (:Unique -> Constraint rule, :Symmetric -> Derivation rule,
  :Transitive -> query-time closure over stzGraph reachability);
- suppositions overlay + evidential certainty carry over unchanged;
- stzEntity/stzListOfEntities move in beside the graph;
- folder naming (graph/ -> knowledge/?) decided by the author here;
- ACCEPTANCE (the north star, 0.1): a small DOMAIN knowledgebase
  (.stzknow with ontology + rules) loads, answers WhatIs/AreRelated,
  and a newly added fact FIRES derivation rules -- intelligence visibly
  augmented with zero code change.

**R2 -- meta/ (+ THE CODE GRAPH).**
Promote stzSelfDoc/stzLibDoc/harvest/recipes/test-sample records to meta/;
reflect/ keeps parsing primitives; ask-probe and semantic-retrieval suites
stay the regression guard. SUBSTRATE MOVE: build **stzCodeGraph** (the
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
  history), persisted as *.stzconv;
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
  by WRITING the .stzknow and standing the system up;
- THE ANSWER PROTOCOL (0.3): replies accepted in five registers --
  proposed option / data structure / formula-script / natural-NNL /
  EXAMPLES (pattern INDUCTION over the ...ex family builds the
  computable candidate); every candidate is validated against the graph
  + its rules before admission: unique -> accept + narrate, several ->
  enumerate and let the user choose, none -> refuse with reasons and
  nearest alternatives;
- LAW 2 ladder: deterministic floor (lexicon + frames + templates) works
  with NO model; stzNeuralChat upgrades fluency when a GGUF is present.

**R4 -- learning/ + optim/ (creation + decision) -- RIDES THE NUMERIC
SUBSTRATE.** Step order matters:
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
5. optim/ -- THE MODELING DSL (section 5.5): stzOptimModel entry object +
   *.stzopt format (sets/params/indexed families); expressions compiled by
   expr.zig (retire stzCoeffExtractor); REAL simplex + B&B in
   engine/src/optim.zig as the floor, vendored HiGHS as the upgrade tier
   (SolveWith(:auto), Why() names the engine); UN-RETIRE the
   solver-comparison test as the honesty guard; stzMultiObjectiveSolver
   (NSGA-II) moves in beside it.

**R5 -- agentic/ (composition) -- THE SUBSTRATES CONVERGE.**
stzAgent + stzAgentSkill/Memory/Tool interfaces; stzPIAgent FIRST
(deterministic, zero-cost, the differentiator), stzLLMAgent second (same
interfaces over neural/). The PI-agent is ASSEMBLED, not invented:
- PLANNING = stzGraphPlanner (goal-predicate search, profiles, Actions()
  sequences, history learning -- ALREADY BUILT) + the missing
  **stzGraphGoal** goal-modeling layer (Gap()/Profile(), stubbed in stzApp);
- REACTION = the Softanzuter upgraded to fixpoint cascading (dependent
  triggers re-fire) = production-rule skills;
- OPTIMIZATION = stzOptimModel (R4 step 5) called by the planner as a
  sub-solver for resource-allocation skills;
- RUNTIME = the reactive substrate: the perceive-decide-act loop runs on
  stzReactor (REAL libuv async, cancellation tokens, pool retry) -- NOT
  the cooperative poller; perception = async reactor fetches; neural token
  streaming = one new reactor job type;
- CURRENCY = replanning: stzKnowledgeGraph gains change-emission hooks
  (AddFact publishes) and plans become Computed values over the facts they
  depend on (requires the R54 stzReactiveObject fix -- see S0);
- memory = stzKnowledgeGraph (R1), tools = meta/stzCodeGraph (R2),
  language = linguistic+natural (R3), brains = neural/learning/optim (R4);
- stzApp is the studied precedent (Being/Behavior/Purpose mapping).
Parse trees and *.zagn agent files considered here, on demand.

**S0 -- SUBSTRATE HYGIENE (do alongside R1):**
- patterns: fix stzRegexUter.Compute typo; implement StateByPosition/
  ByComputationOrder; delete stznumbrex-copy.ring;
- graphs: implement or honestly-raise stzGraph.Paths() (PathsWhereF
  depends on it); note the planner constant-heuristic TODO;
- numerics: expose stzMatrix.Transpose;
- optimization honesty: fix the createRelaxedProblem bug (4-arg call to a
  3-arg addConstraint + undefined [:value]); make the simplex stub RAISE
  or refuse instead of returning zeros, until R4 step 5 replaces it;
- reactive (the R54 fix is MEDIUM -- a class restructure, but it gates
  derived facts + replanning): fix the stzReactiveObject init bug;
  fix WaitForAttributetoSettle's (callback, delay) arg order; make
  stzHttpTask store its status; reconcile the stale "built on libuv"
  narration across Reaxis tests/docs; decide wire-or-retire for the
  orphaned engine event bus (reactive.zig).

**THE CAPSTONE TEST (the definition of done for the WHOLE roadmap):**
the restaurant scenario of 0.1. DAY ZERO is wise coding (0.3): the owner
starts with NOTHING -- Softanza interviews them, gap by gap, and writes
restaurant.stzknow ITSELF (entities, relations, ontology, rules). Then,
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
- R5 proves it ACTS: an agent takes a goal ("prepare Saturday's
  service"), plans over the graph, allocates via the optimizer, reacts
  to changes as they stream in.
Adding ONE rule to the .stzknow file visibly upgrades every layer above
-- no code change, no training, no retrieval pipeline. That demo IS the
proof of the revoked-LLM thesis. Finally, run the SAME capstone with an
AGENT as the programmer, through the machine door (LAW 6): same doors,
same rules, nothing breaks.

Each R-step is independently shippable; R1 (with S0) is ready to start.
