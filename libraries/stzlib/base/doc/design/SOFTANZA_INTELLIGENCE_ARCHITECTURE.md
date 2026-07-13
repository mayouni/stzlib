# Softanza Intelligence Architecture
### The module map, the doctrine, and THE ONE ROADMAP for refactoring and enhancing the library
*(captured 2026-07-13 from the author's directive; unified 2026-07-13 -- this is the single source of truth that governs all module work)*

---

## 0. The Author's Intent, Distilled

Softanza should become **a reference for building intelligent applications with
ease**: advanced features at **no cost in time or money**, with the programmer in
**maximum control**. The current `/natural` + `/neural` split grew along the
milestones, not along the domains. This document fixes the architecture and
carries ONE unified roadmap (section 5) -- refactoring and enhancement are the
same movement, not two plans.

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

## 5. THE ONE ROADMAP (refactor + enhance in the same movement)

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

**R2 -- meta/.**
Promote stzSelfDoc/stzLibDoc/harvest/recipes/test-sample records to meta/;
reflect/ keeps parsing primitives; load order + suite paths updated;
ask-probe and semantic-retrieval suites stay the regression guard.

**R3 -- linguistic/ (the NLTK offensive).**
One step = the refactor AND the gap-closing together:
- stzText moves in as the ENTRY OBJECT; stzPlural/stzSingular/stzOrdinal/
  stzAdverb join it; natural/ keeps language-as-code only;
- NEW: the POS-PATTERN CHUNKER -- patterns over tags (the graphex idea):
  Chunks("DT? JJ* NN+") -> noun phrases; covers NLTK's RegexpParser with a
  cleaner grammar (the out-design move, not just parity);
- NEW: corpora/ shelf + stzCorpus entry object (small corpora embedded,
  large fetched-on-demand, gitignored -- exactly like models/);
- NEW: n-gram LM utilities (probabilities/perplexity over the existing
  counts, engine-side);
- the 4.2 table re-audited; every green row gets its Ask-able intent.

**R4 -- learning/ (creation).**
stzDataset (tables/lists/labeled text) + a minimal trainable
stzNeuralNetwork (XOR/iris class) with the sentence-like API + stzTrainer/
stzModelEvaluation; FIRST APPLIED TARGET: the trainable TEXT CLASSIFIER
(closes the last big 4.2 row); grow toward ggml-backed training; export
into the artifact world neural/ consumes.

**R5 -- agentic/ (composition).**
stzAgent + stzAgentSkill/Memory/Tool interfaces; stzPIAgent FIRST
(deterministic, zero-cost, the differentiator), stzLLMAgent second (same
interfaces over neural/); memory = stzKnowledgeGraph (R1), tools = meta/
(R2), language = linguistic+natural (R3), brains = neural/learning (R4).
Parse trees and *.zagn agent files considered here, on demand.

Each R-step is independently shippable; R1 is ready to start.
