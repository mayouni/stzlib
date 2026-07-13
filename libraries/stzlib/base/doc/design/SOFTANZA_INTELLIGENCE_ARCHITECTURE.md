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
same movement, not two plans, running over THREE SUBSTRATES (section 5).

---

## 1. The Five Laws (the pattern of thinking, made explicit)

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

## 5. The Three Substrates (studied 2026-07-13; they run UNDER all pillars)

The author's directive: graphs, the pattern-matching family, and the
numerical layer are not modules beside the pillars -- they are SUBSTRATES the
whole intelligence system runs on. Three deep code studies confirmed it.

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
- folder naming (graph/ -> knowledge/?) decided by the author here.

**R2 -- meta/ (+ THE CODE GRAPH).**
Promote stzSelfDoc/stzLibDoc/harvest/recipes/test-sample records to meta/;
reflect/ keeps parsing primitives; ask-probe and semantic-retrieval suites
stay the regression guard. SUBSTRATE MOVE: build **stzCodeGraph** (the
design doc's stzCode spec) -- the harvested corpus becomes NODES (classes,
methods, helpers) and EDGES (defines/delegates-to/forwards-to/inherits,
already detected by the harvest levers!) instead of flat records: DeadCode()
via ReachableFrom, ImpactOf(method), CyclicCalls(), refactor planning via
the planner; Ask/WhatIs answer over STRUCTURE, not just text.

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

**R4 -- learning/ (creation) -- RIDES THE NUMERIC SUBSTRATE.**
Step order matters:
1. MATRIX HYGIENE: expose Transpose (engine has it); add elementwise
   subtract/multiply/divide, dot/norm/trace; add Solve(Ax=b) via
   Gauss-Jordan first, LU next; wire stzRandom distributions
   (normal/uniform) -- the training prerequisites.
2. THE GGML BRIDGE: stzMatrix <-> ggml tensor (both contiguous float
   arrays) -- BLAS-grade matmul + the vendored backward pass become
   available to ALL numerics, not just neural/.
3. stzDataset (tables/lists/labeled text) + stzNeuralNetwork with the
   sentence-like API + stzTrainer/stzModelEvaluation (metrics ride the
   already-engine-backed stzDataSet statistics).
4. FIRST APPLIED TARGET: the trainable TEXT CLASSIFIER (closes the last
   big 4.2 row). Also: make stzLinearSolver's simplex REAL (today a
   hardcoded-tableau stub) -- the optimization module PI-agents will use.

**R5 -- agentic/ (composition) -- THE SUBSTRATES CONVERGE.**
stzAgent + stzAgentSkill/Memory/Tool interfaces; stzPIAgent FIRST
(deterministic, zero-cost, the differentiator), stzLLMAgent second (same
interfaces over neural/). The PI-agent is ASSEMBLED, not invented:
- PLANNING = stzGraphPlanner (goal-predicate search, profiles, Actions()
  sequences, history learning -- ALREADY BUILT) + the missing
  **stzGraphGoal** goal-modeling layer (Gap()/Profile(), stubbed in stzApp);
- REACTION = the Softanzuter upgraded to fixpoint cascading (dependent
  triggers re-fire) = production-rule skills;
- OPTIMIZATION = the real LP solver (R4) for resource-allocation skills;
- memory = stzKnowledgeGraph (R1), tools = meta/stzCodeGraph (R2),
  language = linguistic+natural (R3), brains = neural/learning (R4);
- stzApp is the studied precedent (Being/Behavior/Purpose mapping).
Parse trees and *.zagn agent files considered here, on demand.

**S0 -- SUBSTRATE HYGIENE (small, do alongside R1):**
fix stzRegexUter.Compute typo; implement StateByPosition/ByComputationOrder;
delete stznumbrex-copy.ring; implement or honestly-raise stzGraph.Paths()
(PathsWhereF depends on it); expose stzMatrix.Transpose; note the planner
constant-heuristic TODO.

Each R-step is independently shippable; R1 (with S0) is ready to start.
