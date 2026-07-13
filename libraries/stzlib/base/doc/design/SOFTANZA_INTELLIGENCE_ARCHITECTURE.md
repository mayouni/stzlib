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
  knowledge/    KNOWLEDGE PROGRAMMING -- entities, relations, graphs
                  stzKnowledgeGraph   the entry object: entities + typed edges
                                      + graph laws (:Unique/:Symmetric/
                                      :Transitive) + suppositions overlay +
                                      kind constraints. New/Load/Save .zknw
                  stzEntity           (moves from natural/)
                  stzKnowledgeBase?   later: multiple graphs, federation
                  FORMAT: *.zknw      (readable Ring-literal serialization)
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

  linguistic/   CLASSICAL LANGUAGE ALGORITHMS (Tier-1, deterministic):
                  lemmatizer, VADER, POS, rule-NER, RAKE/TextRank, WordNet,
                  plural/singular/ordinal/adverb, UAX#29 seam. Today these
                  live inside string/text engine files -- give them their
                  domain identity. (Engine .zig files stay where they are;
                  this is the RING-side home.)

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

## 3. Current-State Audit (2026-07-13)

| Concern | Verdict |
|---|---|
| /natural holds entities+relations+suppositions as $-globals | WRONG HOME + WRONG SHAPE -- move to knowledge/, wrap in stzKnowledgeGraph, keep globals as default-instance sugar |
| /neural consumes GGUFs only | Right for its scope; the CREATION ambition gets its own learning/ |
| /reflect hosts self-doc | The mechanics are fine; the DOMAIN identity is meta-programming -- promote to meta/ |
| Tier-1 linguistics scattered in string/text | Works, but deserves the linguistic/ identity |
| Evidential + constraint registers as globals in natural/ | Acceptable: they are DISCOURSE state (per-conversation), not domain data; revisit if they ever need persistence |
| stzNeuralChat in neural/ | Right home (a session over a model) |

---

## 4. The stzKnowledgeGraph Contract (phase 1 target)

```ring
# create, fill, persist
oKg = StzKnowledgeGraphQ("world")
oKg.Know("paris", "city")
oKg.KnowRelation("paris", "capital-of", "france")
oKg.ConstrainRelation("capital-of", :Unique)
oKg.Save("world.zknw")

# load and query
oKg = StzLoadKnowledgeGraph("world.zknw")
? oKg.WhatIs("paris")             #--> [ "city", "capital-of france" ]
? oKg.AreRelated("piston", "car") # transitive walk + Why()

# the default graph keeps today's sugar working UNCHANGED:
StzKnow("x", "thing")   # == DefaultKnowledgeGraph().Know(...)
```

.zknw v1 = a readable Ring literal (entities, relations, rules, metadata)
-- diffable, hand-editable, loadable with eval-free parsing.

---

## 5. Migration Phases (each compat-green before the next)

1. **knowledge/**: stzKnowledgeGraph class wrapping TODAY's logic; move
   stzEntity + stzListOfEntities machinery; .zknw Save/Load; globals become
   default-instance sugar; all suites stay green untouched.
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
