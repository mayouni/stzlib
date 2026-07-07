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
	# NOTE: real loading is verified manually with a BERT GGUF (all-MiniLM-L6-v2):
	#   m = StzNeuralModelQ(cPath) ; ? @@(m.Info())
	#   -> arch=bert dim=384 layers=6 heads=12 ctx=512 vocab=30522 tensors=101.
	# Models are LARGE + user-provided at runtime, so not committed to the suite.
EndScenario()

Summary()
