load "../../stzBase.ring"
load "../_narrated.ring"

# NEURAL DOMAIN (stzNeural, base/neural/). The modern tier: a facade over the
# vendored ggml (CPU-only) inference runtime (engine stz_neural.dll), auto-loaded
# with stzBase. Foundation for embeddings / semantic search / zero-shot / NER.

Scenario("The ggml runtime is vendored, built, and live from Ring")
	o = new stzNeural()
	Then("the runtime reports a ggml build version",
		o.GgmlVersion(), "0.0.0-stz")
	Then("the runtime is ready (context -> tensor -> compute round-trips)",
		o.IsReady(), TRUE)
	Then("IsAvailable is an alias of IsReady",
		o.IsAvailable(), TRUE)
EndScenario()

Scenario("Runtime snapshot + global shortcuts")
	o = new stzNeural()
	Then("RuntimeInfo backend is ggml (CPU)",
		o.RuntimeInfo()[1][2], "ggml (CPU)")
	Then("StzGgmlVersion() global returns the version data",
		StzGgmlVersion(), "0.0.0-stz")
	Then("StzNeuralReady() global returns readiness data",
		StzNeuralReady(), TRUE)
	Then("StzNeuralQ() returns the neural-domain object",
		isObject(StzNeuralQ()), TRUE)
EndScenario()

Scenario("Model API (GGUF loads at RUNTIME -- no real model needed here)")
	o = new stzNeural()
	Then("no model is loaded initially",
		o.ModelLoaded(), FALSE)
	Then("loading a missing file fails cleanly (no crash)",
		o.LoadModel("does_not_exist.gguf"), FALSE)
	Then("a non-string path is rejected",
		o.LoadModel(123), FALSE)
	# NOTE: real loading is verified manually with a BERT GGUF, e.g. all-MiniLM-
	# L6-v2 -- o.LoadModel(cPath) -> o.ModelInfo() reads arch/dim/layers/vocab.
	# Models are LARGE + user-provided at runtime, so not committed to the suite.
EndScenario()

Summary()
