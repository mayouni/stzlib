load "../../stzBase.ring"
load "../_narrated.ring"

# NEURAL DOMAIN (base/neural/). The modern tier over the vendored ggml (CPU-only)
# inference runtime (engine stz_neural.dll), auto-loaded with stzBase. Naming:
# stzNeural is the shared BASE; stzNeuralEngine wraps the inference RUNTIME;
# stzNeuralModel is an instantiable MODEL loaded at runtime from a GGUF.

Scenario("stzNeuralEngine: the ggml runtime is vendored, built, and live")
	e = new stzNeuralEngine()
	Then("the engine reports a ggml build version",
		e.GgmlVersion(), "0.0.0-stz")
	Then("the engine is ready (context -> tensor -> compute round-trips)",
		e.IsReady(), TRUE)
	Then("backend is ggml (CPU)",
		e.Backend(), "ggml (CPU)")
	Then("Content carries the snapshot",
		e.Content()[1][2], "ggml (CPU)")
EndScenario()

Scenario("The ggml compute graph runs (graph_plan + graph_compute live)")
	# Proves the full compute path -- not just tensor write/read, but building a
	# graph and running ggml_graph_compute. This exercises the ctor-independent
	# patches (atomic_flag critical section, traits short-circuits) that make the
	# BERT embedding forward pass possible on this Zig-built DLL.
	Then("a trivial add graph computes to the right result",
		StzEngineNeuralComputeSmoke(), 1)
EndScenario()

Scenario("Shared base + global shortcuts")
	e = new stzNeuralEngine()
	Then("engine inherits GgmlReady from the stzNeural base",
		e.GgmlReady(), TRUE)
	Then("StzGgmlVersion() global returns the version data",
		StzGgmlVersion(), "0.0.0-stz")
	Then("StzGgmlReady() global returns readiness data",
		StzGgmlReady(), TRUE)
	Then("StzNeuralEngineQ() returns the engine object",
		isObject(StzNeuralEngineQ()), TRUE)
EndScenario()

Scenario("stzNeuralModel: GGUF loads at RUNTIME (no real model needed here)")
	m = new stzNeuralModel("")
	Then("a fresh model is not loaded",
		m.IsLoaded(), FALSE)
	Then("loading a missing file fails cleanly (no crash)",
		m.LoadFrom("does_not_exist.gguf"), FALSE)
	Then("a non-string path is rejected",
		m.LoadFrom(123), FALSE)
	Then("the model shares the ggml runtime via the base",
		m.GgmlReady(), TRUE)
	# NOTE: real loading + the BERT forward pass are verified manually with a
	# BERT GGUF (all-MiniLM-L6-v2), which is large and NOT committed:
	#   m = StzNeuralModelQ(cPath) ; ? @@(m.Info())
	#   -> arch=bert dim=384 layers=6 heads=12 ctx=512 vocab=30522 tensors=101.
	#   m.EmbeddingOf("the cat sat")            -> 384-float L2-normalized vector
	#   m.SemanticSimilarityBetween(a, b)       -> cosine; related ~0.65, unrelated ~0.05
	# Once StzNeuralModelQ(cPath) is called, the stzText layer upgrades to
	# embeddings automatically:
	#   Q(str).TextQ().SemanticSimilarityWith(other) / MostSimilarSentenceTo(q)
	#   stzText.SummarySentences(n) -> embedding-TextRank (cosine graph + PageRank)
	#     instead of the engine's word-overlap TextRank; falls back w/o a model.
	#   stzText.ClassifiedAs(labels)     -> zero-shot classification by meaning
	#   stzText.EntitiesTypedAs(types)   -> entities re-typed by meaning
	# With a NER-HEAD GGUF (cstr/bert-base-NER-GGUF) instead, NamedEntities()
	# upgrades to TRANSFORMER NER (token classification + BIO decode):
	#   StzEngineNeuralModelHasNer() -> 1; StzHasNeuralNerModel() -> TRUE
	#   new stzText("Barack Obama visited Paris").NamedEntities()
	#     -> [[Barack Obama,PERSON],[Paris,LOCATION]] (multi-word entities merged)
	# With a CROSS-ENCODER reranker GGUF (jina-reranker-v1-turbo-en):
	#   StzEngineNeuralModelHasReranker() -> 1; StzHasRerankerModel() -> TRUE
	#   new stzListOfTexts(docs).RankedForQuery(q) / .MostRelevantTo(q) -- joint
	#   [CLS] query [SEP] doc scoring (jina-bert-v2 ALiBi + GEGLU via buildBackbone).
	# Token-level substrate for NER/token-classification (raw per-token hidden
	# states): StzEngineNeuralEmbedTokens(text) -> n_tok; StzEngineNeuralTokenDim();
	# StzEngineNeuralTokenValue(tok, dim). A real token-classification NER head
	# plugs onto this.
	# Models are LARGE + user-provided at runtime, so not committed to the suite.
EndScenario()

Summary()
