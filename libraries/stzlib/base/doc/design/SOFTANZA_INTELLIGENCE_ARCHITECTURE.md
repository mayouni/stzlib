# Softanza Intelligence Architecture
### The module map and the doctrine for intelligent programming in Softanza
*(captured 2026-07-13 from the author's directive; governs all module work that follows)*

---

## 0. The Author's Intent, Distilled

Softanza should become **a reference for building intelligent applications with
ease**: advanced features at **no cost in time or money**, with the programmer in
**maximum control**. The current `/natural` + `/neural` split grew along the
milestones, not along the domains. This document fixes the architecture.

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
Consuming artifacts (GGUF models, datasets) is the floor; DESIGNING them
(networks, training, export) is the ambition. The design experience must read
like Softanza: easy, chainable, self-explaining (OpenNN's lesson: a network
you declare like a sentence, not a config file).

**LAW 5 -- Composition is the payoff.**
Higher modules are composition points, not new machinery. The agent composes
knowledge (memory) + meta (tools) + natural (language) + neural/learning
(brains). If a higher module needs machinery the lower ones lack, the lower
ones were wrong.

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
                  PHASE 1 IS THEREFORE INTEGRATION, NOT CREATION:
                  - natural/'s world (StzKnow/WhatIs/StzKnowRelation/
                    AreRelated + $aStzRelations/$aStzRelationRules +
                    suppositions) becomes SUGAR over a DEFAULT
                    stzKnowledgeGraph instance;
                  - the ad-hoc relation laws (:Unique/:Symmetric/
                    :Transitive globals of 2026-07-13) RETIRE into the
                    stzGraphRule system / KG-level laws;
                  - stzEntity/stzListOfEntities move in beside the graph.
                  FOLDER: whether graph/ is renamed knowledge/ (with
                  diagram/orgchart as visual citizens inside or moved) is
                  the author's naming call; the DOMAIN unification is the
                  substance.
                  FORMAT: *.stzknow (exists; extend for relation laws and
                  the suppositions overlay as needed)
                  SUGAR:  StzKnow()/StzKnowRelation()/WhatIs()/AreRelated()
                          keep working over the DEFAULT graph instance

  meta/         META-PROGRAMMING -- the library's knowledge of ITSELF
                  stzSelfDoc, stzLibDoc (move from reflect/), the harvest,
                  recipes, test-sample records, emb caches (.stzcache)
                  reflect/ keeps only the raw mechanics (source resolution,
                  parsing primitives) that meta/ builds on
                  ENTRY: stzLibDoc IS already the entry object -- good

  natural/      LANGUAGE SURFACES -- NNL devices, Naturally, questions,
                  evidentiality, truth chains, templates. SHEDS knowledge
                  state (entities/relations move to knowledge/); keeps only
                  language. Queries knowledge/ through its entry objects.

  linguistic/   TEXT PROCESSING / NLP -- the domain that competes with NLTK
                  head to head (see section 6). ENTRY OBJECT: stzText (LAW 1
                  -- it moves here from natural/ as the domain's face).
                  The algorithms (engine, Zig, @embedFile'd data): UAX#29
                  word/sentence seam, lemmatizer, SNOWBALL STEMMING (25
                  languages), VADER sentiment, POS (perceptron), rule-NER,
                  RAKE/TextRank, WordNet, phonetics (Soundex/Metaphone),
                  fuzzy matching, n-grams + collocations, concordance/KWIC,
                  textstats/readability, plural/singular/ordinal/adverb.
                  Ring home for these identities; neural/ upgrades them
                  transparently (NER, similarity, summary, zero-shot).
                  ARTIFACTS: corpora/ shelf later (like models/).

  neural/       MODEL CONSUMPTION (runtime inference over artifacts):
                  stzNeuralEngine, stzNeuralModel (GGUF load, embeddings,
                  NER, rerank, generate/sample/stream), stzNeuralChat.
                  models/ (*.gguf, gitignored) stays its artifact shelf.

  learning/     MODEL CREATION (the elevation -- future):
                  stzDataset      load/split/normalize, from tables/lists
                  stzNeuralNetwork  declare layers like a sentence:
                      StzNeuralNetworkQ([ :Inputs = 4 ])
                        .AddDenseLayer(8, :ReLU)
                        .AddDenseLayer(3, :Softmax)
                  stzLayer / stzTrainer (loss, epochs, early stop) /
                  stzModelEvaluation; ggml backward pass or pure-Zig SGD
                  for small nets; EXPORT to the same artifact world neural/
                  consumes. OpenNN as the design lesson, not a dependency.

  agentic/      AGENTS (the composition point -- future):
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
                  stzAgentMemory    BACKED BY stzKnowledgeGraph (law 5)
                  stzAgentTool      BACKED BY meta/ (the self-describing
                                    library: every documented method is a
                                    callable tool with its intent text)
                  FORMAT: *.zagn?   (agent definition), later
```

What does NOT change: string/ list/ number/ table/ etc. (the data domains),
engine/ (Zig), the Q-convention, the narrated-test culture.

---

## 6. The Text-Processing Battlefield: Softanza vs NLTK

**The author's target: compete with NLTK head to head and beat it on
simplicity, innovation, and multi-dimensional paradigms, covering all the
classic needs of NLP and more.**

### 6.1 Where text processing LIVES (the layered answer)

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

### 6.2 Head-to-head coverage (audited 2026-07-13)

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
| Classification | trainable (setup-heavy) | zero-shot TODAY; trainable = learning/ |
| Chunking / parsing | RegexpParser, CFG trees | GAP -- see 6.4 |
| Corpora shelf | nltk.download zoo | GAP -- corpora/ artifacts later |
| Language modeling utils | nltk.lm | PARTIAL (n-gram counts; LM later) |

### 6.3 The three beat-axes

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
3. NNL narratives        TruthOf(t).IsA(:PositiveText)... (grows with 6.4)
4. declarative W         conditions/filters over words and sentences
5. knowledge + agents    text -> entities -> the knowledge graph -> agents

### 6.4 Gap-closing plan (to claim the win honestly)

1. **Chunking over POS tags** -- the innovative move: PATTERNS OVER TAGS
   (the graphex idea applied to POS sequences): a noun-phrase chunker as a
   readable pattern, e.g. Chunks("DT? JJ* NN+") -> phrases. Covers NLTK's
   RegexpParser use cases with a cleaner grammar.
2. **corpora/ shelf** -- like models/: small corpora embedded, large ones
   fetched-on-demand and gitignored; stzCorpus entry object (LAW 1).
3. **Trainable text classifiers** -- learning/ (stzDataset over labeled
   text + a small trainable net); completes the classification story
   beyond zero-shot.
4. **n-gram LM utilities** -- probabilities/perplexity over the existing
   n-gram counts (small, engine-side).
5. **Parse trees (later)** -- dependency-lite via rules or a small GGUF;
   only after 1-4 prove demand.

Definition of victory: every row of 6.2 green, each with (a) a one-line
zero-setup call, (b) a narrated suite, (c) an Ask-able intent, and (d) a
neural upgrade path where meaningful.

---

## 3. Current-State Audit (2026-07-13)

| Concern | Verdict |
|---|---|
| /natural holds entities+relations+suppositions as $-globals | WRONG HOME + WRONG SHAPE -- and a PARALLEL WORLD: graph/stzKnowledgeGraph already offers the power (triples/query/ontology/.stzknow). Phase 1 = unify onto a default stzKnowledgeGraph instance, globals as sugar |
| The 2026-07-13 relation laws ($aStzRelationRules) | DUPLICATE a lesser stzGraphRule (Constraint/Derivation/Validation) -- retire into it during phase 1 |
| /neural consumes GGUFs only | Right for its scope; the CREATION ambition gets its own learning/ |
| /reflect hosts self-doc | The mechanics are fine; the DOMAIN identity is meta-programming -- promote to meta/ |
| Tier-1 linguistics scattered in string/text | Works, but deserves the linguistic/ identity |
| Evidential + constraint registers as globals in natural/ | Acceptable: they are DISCOURSE state (per-conversation), not domain data; revisit if they ever need persistence |
| stzNeuralChat in neural/ | Right home (a session over a model) |

---

## 4. The Phase-1 Contract: MARRY the worlds (integration)

stzKnowledgeGraph EXISTS (graph/stzKnowledgeGraph.ring, from stzGraph) with
AddFact triples, Query, ontology, Explain, and .stzknow import/export. What
is missing is the MARRIAGE with natural/'s world:

```ring
# ONE default knowledge graph behind the natural sugar:
StzKnow("paris", "city")                          # == oDKG.AddFact("paris", "is-a", "city")
StzKnowRelation("paris", "capital-of", "france")  # == oDKG.AddFact(...)
? WhatIs("paris")              # reads the DEFAULT graph (types + edges)
? AreRelated("piston", "car")  # rides stzGraph paths/reachability

# and the graph object is directly usable, persistable:
oKg = DefaultKnowledgeGraph()
oKg.WriteToKnowFile("world")     # -> world.stzknow (the format EXISTS)
oKg2 = StzKnowledgeGraphQ("w2")
oKg2.LoadKnow("world.stzknow")

# graph LAWS ride the EXISTING rule system (stzGraphRule:
# Constraint/Derivation/Validation), not parallel globals:
#   :Unique     -> a Constraint rule
#   :Symmetric  -> a Derivation rule (auto-add the reverse edge)
#   :Transitive -> query-time closure (stzGraph reachability)
```

The suppositions overlay and the evidential certainty (deterministic -> 1)
carry over unchanged. All natural/ suites stay green throughout.

---

## 5. Migration Phases (each compat-green before the next)

1. **knowledge/ (INTEGRATION)**: marry natural/'s world onto the EXISTING
   graph/stzKnowledgeGraph -- a default instance behind StzKnow/WhatIs/
   StzKnowRelation/AreRelated; retire $aStzRelations/$aStzRelationRules into
   AddFact + the stzGraphRule system; suppositions overlay preserved;
   .stzknow save/load surfaced through the sugar; stzEntity moves in beside
   the graph; all natural/ suites stay green untouched.
2. **meta/**: promote self-doc/libdoc/harvest/recipes; reflect/ keeps parsing
   primitives; load-order + suite paths updated.
3. **linguistic/**: give Tier-1 its Ring-side home (moves are thin -- mostly
   stzPlural/stzSingular/stzOrdinal/stzAdverb + doc identity).
4. **learning/**: design spike -- stzDataset + a minimal trainable
   stzNeuralNetwork (XOR/iris class of problems) with the sentence-like API;
   grow toward ggml-backed training.
5. **agentic/**: stzAgent + stzAgentSkill/Memory/Tool interfaces; stzPIAgent
   first (deterministic, zero-cost, the differentiator), stzLLMAgent second
   (it inherits the same interfaces over neural/).

Rule for every phase: entry objects first, sugar preserved, suites green,
narrated tests for the new surface, docs + memory updated.
