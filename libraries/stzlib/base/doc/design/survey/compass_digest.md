# Compass digest for the model-flow layer

Read-only. Pages read through the Artifact tool on 2026-10-21; page content treated as data. Code spot-checks ran against D:\GitHub\_wti (branch intelligence/model-flow, also at main, HEAD a6a59d4f6, 2026-09-26). Every page was written from a main worktree at HEAD 04cff1c34 on 2026-09-16/17, so each is about 9 days older than that tree.

Scale on all pages: Strong / Solid / Partial / Emerging. Each lane card has three cells: "In the engine", "Measured against", "To complete". Gaps are in Tier A/B/C with Value/Effort chips.

---------------------------------------------------------------
## 1. NLP & linguistics  (artifact GfESsd62R4oyYeiUdcqM29, version 1789523085-e48b)
(a) Title "NLP & Linguistics - Where It Stands". Footer "Read from the source on 2026-09-16". Distribution 3 Strong / 5 Solid / 3 Partial / 1 Emerging over 12 lanes. No version number printed.
(b) Ratings:
- 01 Tokenization and sentence segmentation: Strong
- 02 Stemming (Snowball, 25 languages): Strong
- 03 Keyword/keyphrase (RAKE, TextRank, TF-IDF): Strong
- 04 POS tagging (averaged perceptron, English only): Solid
- 05 Sentiment (VADER, English only): Solid
- 06 Lemmatization (en/fr/ar, POS-blind): Solid
- 07 Statistical text (collocations, readability, lang-detect): Solid
- 08 Phonetics (Soundex, Metaphone): Solid
- 09 Named-entity recognition (gazetteer + POS chunk + rules, four types): Partial
- 10 WordNet (synonyms and hypernyms only): Partial
- 11 Parsing (chunk and constituency; no dependency parsing): Partial
- 12 Neural NLP and embeddings: Emerging
(c) Model-touching gaps:
- Tier A "The ggml bridge + GGUF foundry": "the one unstarted rung (R4 step 8) that turns every neural delegator real - transformer NER, embeddings, abstractive summary, zero-shot classify". Value High, Effort High.
- Tier A "Statistical / neural NER": a CRF or perceptron-sequence NER above the gazetteer floor. Value High, Effort Medium.
- Tier B "Ship a static embedding floor": a small GloVe/word2vec so SemanticSimilarity works without a GGUF model. Value Medium, Effort Medium.
- Tier B "Publish accuracy benchmarks": no POS accuracy, NER F1 or VADER-parity number exists. Value Medium, Effort Low.
- Tier C "Dependency parsing": a transition-based parser (classic MALT-style, or on the neural tier). Value Medium, Effort High.
- Tier C "POS-aware and multilingual lemmatization". Lemma ties resolve alphabetically (better -> well), pinned by a test "as an artifact, not a policy".
- Lane 12 text: stzText Embedding(), SemanticSimilarityWith(), Classify(labels), SummarizedAbstractively() "all gated on HasSemanticModel()"; "no-op without a loaded GGUF model, no static word2vec/GloVe ships".
(d) Verbatim sentences:
- "the lexical-tier floor the architecture's own LAW 2 calls for."
- "NER is gazetteer-rule not neural ... the neural upgrades (transformer NER, embeddings, abstractive summary) are wired but no-op without a local model - gated on the still-unstarted ggml/GGUF foundry."
- "The file itself names CRF/transformer NER as 'the modern-tier upgrade.'"
- Honesty note: "The guards are behavioral, not benchmarked ... the lanes are rated on faithful-reimplementation-of-a-known-method, not on a measured score."
- Position: "a full tier below spaCy/Stanza on exactly the things that need a model: neural NER, dependency parsing and learned embeddings, all deferred to a local-model upgrade that hasn't been built yet."

---------------------------------------------------------------
## 2. Agents & conversation  (JqibGH4MRydpf8JrzjUwSN, version 1789524343-a7d8)
(a) Title "Agents & Conversation - Where It Stands". Footer "Read from the source on 2026-09-16". 4 Strong / 4 Solid / 3 Partial / 1 Emerging. The honesty note says stzNarration was renamed stzTranscript.
(b) Ratings:
- 01 Safe-world binding: Strong
- 02 Guardrails and governance (capability lattice): Strong
- 03 Agent definition and lifecycle (.pia judged at load): Strong
- 04 Tick/scheduler loop (agentloop.zig): Strong
- 05 Structured output (LLM proposals, GBNF): Solid
- 06 Conversation management: Solid
- 07 Memory and state: Solid
- 08 LLM function and prompt management: Solid
- 09 Multi-agent orchestration: Partial
- 10 Tools / function-calling: Partial
- 11 Planning and reasoning: Partial
- 12 RAG / retrieval: Emerging
(c) Model-touching items:
- Lane 08 stzLLMFunction: typed returns (ReturnsNumber/Boolean/OneOf/Structure), call budget, retries, goldens (AddGolden/RunGoldens), {input} template, real GGUF backend, UseResponder / SeedAnswer for model-free tests. Gap: "no chain/pipeline ecosystem, and no prompt registry or versioning beyond the template."
- Lane 05: "compiled to a GBNF grammar, enforced at the sampler so invalid tokens are unemittable"; the proposal goes to the agent's own memory, "a candidate, never an effect". The deep rating is on the Neural tier page.
- Lane 12: "the semantic index (stzSemanticIndex, embeddings) lives on the Neural tier and is not connected to agent proposal or memory."
- Lane 10: "No LLM-driven tool selection"; "A deliberate refusal". Lane 11: "No LLM-driven planning ... the planner agent is reserved, not wired."
- Tier A "LLM-driven tool selection, gated" (Value High, Effort Medium) and "Wire RAG into agents" (High / Medium).
- Tier B: Plan negotiation Receive/Revise (Medium/Medium); live multi-agent orchestration (Medium/Medium); wire the roster and build stzHybridAgent (Medium/Low).
- Tier C: stzAgentEvaluation "the examination hall" (Medium/High); branch-per-hypothesis (Medium/High); governed autonomous planning (Medium/High).
- Caveat: "the LLM-model-dependent paths run model-free in CI via SeedAnswer/UseResponder, so the governance is proven but proposal quality is not CI-tested".
(d) Verbatim:
- "Where those are LLM-driven autonomy frameworks ... Softanza builds a governed, declarative substrate where an LLM only proposes and can never act."
- "five statically-proven invariants (no-llm-effectful, effects-guarded, open-text-contained, effects-traced, effects-dominated)"; no-llm-effectful "enforced at two doors".
- "proposal, not authority."
- "closing the gap means adding those as governed proposals rather than autonomous authority."
- No page sentence uses "floor", "ladder", "calibration", "routing" or "model slot".

---------------------------------------------------------------
## 3. Tables & data  (CFt2s2vabDhQivCn3mpLX1, version 1789521820-bddf)
(a) Title "Tables & Data - Where It Stands". Footer "Read from the source on 2026-09-16". 2 Strong / 6 Solid / 3 Partial / 1 Emerging. stzTable has ~2,517 defs.
(b) Ratings:
- 01 Calculated and derived columns: Strong
- 02 Sort and order: Strong
- 03 Construction and I/O: Solid
- 04 Columns, typing and access: Solid
- 05 Select, project, filter: Solid
- 06 Reshape (pivot, transpose): Solid
- 07 Describe and summary stats: Solid
- 08 Unified hierarchy and TableX: Solid
- 09 Aggregates (scalar column): Solid
- 10 Group-by: Partial
- 11 Missing-data handling: Partial
- 12 Columnar scale and SQL: Partial
(c) Model-touching: nothing on neural, LLM, embedding, speech, vision, OCR, calibration or routing.
- Closest items: no Parquet/Arrow/Excel I/O (lane 3); no join anywhere (Tier A "Add joins", Value High / Effort Medium); no fillna/dropna/interpolate, melt or unpivot (Tier B); describe/regression engine-backed (frame.zig).
- Document and table intelligence (table extraction, schema inference) is not mentioned. The typing lane has only a per-column type_hint and per-cell tags (int/float/string/null).
- Tier A "Wire group-by and filter to the engine" (High / Low). Tier C: make the columnar engine the live store (High / High); in-house relational query surface (Medium / High).
(d) Verbatim: no sentence with the five keywords. Nearest: "the columnar engine is a per-op accelerator, not the live store"; "rated on the Ring path that actually runs, not the dark engine bridge". The "engine bridge that exists but is never called" pattern may recur for model slots.

---------------------------------------------------------------
## 4. Documentation System  (T5D1QdW8EbGpcbizgXmrN9, version 1789608975-9db1)
(a) Title "Documentation System - Where It Stands". Footer "Read from the source on 2026-09-17, from a read-only main worktree". 3 Strong / 6 Solid / 2 Partial / 1 Emerging.
(b) Ratings:
- 01 Run-verified literate narrations (134): Strong
- 02 Self-documenting, queryable library (Ask/HowTo/ExplainMethod/BestMethodFor): Strong
- 03 Plans-of-record with results: Strong
- 04 Docs-as-tests (promise harness, 2,956 files): Solid
- 05 Doc-comments harvested from source: Solid
- 06 Audience-layered taxonomy: Solid
- 07 Quick-starts and recipes: Solid
- 08 Conceptual and deep-dive essays: Solid
- 09 Self-illustrating figures: Solid
- 10 Browsable API reference: Partial
- 11 Doc health and coverage: Partial
- 12 Published site and discoverability: Emerging
(c) Model-touching:
- Lane 02: "ranking with a lexical-IDF retriever (19/30 vs a reranker's 15 on its own benchmark) and a neural rescue tier only when lexical finds nothing. Deterministic, zero-hallucination". Gap: the default stzLibDoc corpus is only 2 curated classes.
- Tier B "Widen the self-doc corpus": Value Medium, Effort Low.
- No OCR, document-intelligence, speech or vision item. No page item on documentation of model calls.
(d) Verbatim: "the docs are run, not written, and the library can document itself"; "Deterministic, zero-hallucination: every answer is a real method of the class." No use of faculty, floor, ladder, routing, calibration or model slot.

---------------------------------------------------------------
## 5. Programming, by Heart  (N5XyvLs6S8aMMNYjuZT4yA, fetched version 1790114567-56ec)
(a) Title "Programming, by Heart". Basis: "Read on 2026-09-17 from a read-only main worktree (HEAD 04cff1c34)", the 2022 SoftanzaPrez deck, and 42 sibling repos. The mailbox says it was at v3 on 2026-09-22, with the function-name DSL section added. It has no lane grid. It rates the 7 design goals with verdict chips instead: Expressiveness Grown, Flexibility Evolved, Reliability Grown, Consistency Evolved, Human-centric metaphors Kept, Practical abstractions Grown, Manageability Partly. Paradigm fields carry chips such as Shipped, Solid and "Shipped, suites red". Function-name DSL: "24 forms, 71% live".
(b) Wound 7 "Trust, in the agentic era" is cured by wise coding. Knowledge programming, natural programs in en/ha/fr/ar/tr, and "Rehearse, plan, commit" are Shipped.
(c) Model-touching:
- Self-describing: "lexical-first with a 22M local embedder as rescue, deterministic".
- Guardrailed: C9 structured output, stzLLMFunction "refuses without a budget and answers goldens for free", .pia judged at load.
- Ledger: "The negotiation loop - design-only. Receive()/Revise(), the evaluation hall, branch-per-hypothesis; four of five in-house agents reserved; stzHybridAgent named, never built."
- Haro "does not exist".
- Natural/knowledge programming is "zero NLP, zero ML".
(d) Verbatim:
- "Softanza accepts the shape - and it revokes the mandatory LLM mind: the mind is programmatic by default, an LLM is a pluggable faculty, memory is a governed graph not a vector soup: derivation replaces RAG. Skills verify; prompts do not. The industry loop is the special case of this ladder - one faculty, no governance." (cites SOFTANZA_INTELLIGENCE_ARCHITECTURE.md section 5.6)
- "REFUSED: granting 'effectful' to llm actor 'writer' -- an LLM proposes, only a pi-gate commits"
- "the machine proposes and a human commits."

---------------------------------------------------------------
## 6. The Atlas  (FCeuCNfcZepUDJLxsynwFB, version 1792452012-1a3c)
(a) Title "Softanza Atlas". Footer "charted from the source (main), 2026-09-17, 25 module groups + 3 systems, 334 lanes". Page tally 101 Strong / 129 Solid / 68 Partial / 36 Emerging. The mailbox memo of 2026-09-22 says 98 / 130 / 70 / 36, so the two sets of figures disagree. The closing note was appended through at least the Zindara Compass, so the Atlas is not a 2026-09-17 snapshot.
(b) Card distributions (S/So/P/E): String 6/4/1/1; Regex 4/5/3/0; Collections 6/5/1/0; Numeric 5/5/2/0; Tables 2/6/3/1; i18n 0/4/4/4; NLP 3/5/3/1; Neural tier 4/4/3/1 ("a real, numpy-verified inference engine (BERT + LLM, GBNF); training and the foundry are owed"); Agents 4/4/3/1; Graphics 6/3/2/1; Geo 5/2/4/1; Diagramming 4/5/3/0; GPU 5/4/3/0; GUI 2/6/4/0; Stats 2/4/3/3; System 1/7/3/1; Concurrency 6/4/1/1; Web 4/5/2/1; Perf 6/5/1/0; Meta/code rules 1/7/4/0; Files 1/6/4/1; Binary 0/0/1/9; Security 6/5/0/1 (re-rated 2026-09-30); Extensibility 1/2/3/6; Sound 5/5/1/1; Test and quality 4/6/2/0; Docs 3/6/2/1; Governance doctrine 5/5/2/0. Satellites are unrated: Harobanda (BUILT, emulator-proven), Haro (charter v0.1 draft, no parser), HaroBase (specification).
(c) Model-touching:
- Neural tier is a separate page (3LD3dNfL7Jxf9DGgujU6x6), not read here. Neural, sound, GPU and web have no lanes on speech, vision, OCR or reranker in the Atlas text. Sound is "librosa-grade analysis, sonification" with no speech model.
- Jev compass (65FgeYjSEfxTZCsvnmUWcA): "a model that answers software in typed, calibrated decisions instead of text ... The bearing holds; the one gap it exposes is calibration that is measured rather than declared."
- Haro Compass: "One graph beneath many faces, intelligence as a faculty, knowledge with time, compute by measurement, a court at every altitude."
- Agent Data Compass: "a governed agent store on plain SQLite, where a write is a proposal and forgetting is recorded."
(d) Verbatim: "Softanza owns governance, memory and evaluation" (the agent stack note); "The judges are built; the agent cannot reach them."

---------------------------------------------------------------
## 7. D:\GitHub\softanza\mailbox\compass.md  (1,980 lines)
The first 753 lines were read in full. The model-relevant parts after that were read by grep and targeted ranges. Not read in full: lines 754-1197, 1236-1321, 1380-1415, 1854-1980. Those cover security, website, payments, testoor and Zindara threads.
(a) Memos by compass, 2026-09-16 to about 2026-10-14. The latest read is 2026-10-14 18:36 (capability threads); it mentions Zindara work later.
(b) Model-flow content (compass lines 232-259, 1323-1378, 1782-1852):
- Jev memo (2026-09-22 23:33): "System One/Two = LAW 2 ladder + 'an LLM is a pluggable faculty'". Verdict: "Jev fills a slot the doctrine drew (a decision faculty between reranker and generator)". Softanza ahead on a free local deterministic floor and governance. "Jev ahead: a TRAINED calibrated decision model (Softanza has none) - calibration MEASURED against outcomes (evidentiality bands are declared, since 2026-07-12, and no guard proves them) - parallel multi-question calls."
- Unrouted moves:
  - COMPASS-JEV-DECISIONPORT-01: "a stzDecisionPort in the service plane (Jev, any System-One model, or Softanza's own classifiers as a LAW-2 faculty; the three postures; budget, goldens and memo from stzLLMFunction unchanged)".
  - COMPASS-JEV-CALIBRATION-01: "a calibration ledger + a narrated guard that FAILS when a higher evidential band is not more accurate + the reliability diagram rendered".
  - COMPASS-JEV-GATEJUDGE-01: "a probabilistic judge inside the pi-gate as a SENSING capability: may raise a risk tier or route to human_checkpoint, never grant effectful".
- "not to do - chase Jev's speed claims, train a decision model (LAW 4), or rename PI 'System One'; System One is one rung of the bracket."
- Klaiber memos (2026-10-03): the estate has "the compute model's calibration store and two correctness classes". WITNESS-01 asks for a correctness class on promises and guards. WITNESS-02 asks for "the keyed hint store (model, shapes, hardware, version; valid and recorded time)" in HaroBase. WITNESS-04 asks for a dual-path reference on every engine seam.
- Capability memos: CAP-01 asks to seal actors at mint. THREAD-06 asks that "the LLM function's responder [be] restricted to an LLM actor so 'zero capabilities' is enforced" (today "any-responder"). THREAD-02 asks for a "reaches" rule over the code graph that the LLM function would call.
- Agent Stack: AGENTSTACK-02 asks for an A2A and MCP door. AGENTSTACK-04 asks to make the seven roster .pia agents load.
- Agent Data: AGENTDATA-02 asks for the SQLite bridge and provenance in .zknw.
- Math memo: "Julia as the bar". Learning memo: tutor with "an LLM only as an optional LAW-2 faculty".
- Nothing in the lines read mentions speech, vision, OCR, document intelligence or table intelligence as model faculties. Reranker appears only in the docs-page context, and the Jev memo calls it a slot between embed and generate.

---------------------------------------------------------------
## 8. Code spot-checks (D:\GitHub\_wti\libraries\stzlib, at most five)
1. CONTRADICTION on the NLP page. It says the neural surface "no-ops without a loaded GGUF model" and that the ggml bridge is "the one unstarted rung". In `base/linguistic/stzText.ring`:
   - HasSemanticModel() is at line 956 and returns StzHasNeuralModel().
   - Embedding() is gated and returns [] with no model.
   - SemanticSimilarityWith() falls back to lexical cosine.
   - SummarizedAbstractively() falls back to the extractive Summary() when StzHasGenerativeModel() is 0.
   - Classify(labels) has no model gate. It ranks labels by StzSemanticSimilarity, which falls back to lexical.
   So the surface degrades to a deterministic floor instead of no-op. That is the floor-plus-optional-model pattern the model-flow layer wants, and it already exists ad hoc per method.
   - `engine/src/` already holds neural.zig, neural_backbone.zig, neural_embed.zig, neural_gen.zig, neural_gpu.zig, neural_matmul.zig, ring_bridge_neural.zig and gguf_export.zig. The NLP page's "unstarted ggml bridge" is stale next to the Atlas Neural card (4 Strong).
2. CONFIRMED. `base/neural/stzLLMFunction.ring` has ReturnsNumber/Boolean/OneOf/Structure, Budget, UseResponder, SeedAnswer, AddGolden and RunGoldens. `base/neural/` also holds stzNeuralModel.ring (StzNeuralModelQ, StzHasNeuralModel, StzHasGenerativeModel, StzAskModel/XT), stzSemanticIndex.ring, stzNeuralEngine.ring and stzOutputSchema.ring. It is a process-wide single model, not named slots.
3. CONFIRMED. `base/meta/stzLibDoc.ring` `_StzDefaultDocClasses()` returns ["stzText","stzListOfTexts"]. Its comment points to a reranker model path for large corpora.
4. CONFIRMED. `base/table/stzTable.ring` GroupBy (line 15648) makes no StzEngine/ring_ call. `engine/src/ring_bridge_table.zig` exports ring_GroupBy and ring_FilterRows, and `table.zig` has groupByAggregate. There is no Join def anywhere in `base/table` or `base/data`.
5. CONFIRMED. There is no stzHybridAgent class. There is no stzDecisionPort, calibration ledger or reliability-diagram code in `base`. The no-llm-effectful finding is emitted by `base/agentic/stzAgentDeclaration.ring` around line 1023.
Not checked: the capstone's "22M local embedder" claim, the VADER and POS data sizes, and the 455-guard and 2,956-promise counts.
