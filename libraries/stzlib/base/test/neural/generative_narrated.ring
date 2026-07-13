# Narrative
# --------
# GENERATIVE GGUF -- the decoder milestone: a llama-family causal decoder
# (RMSNorm + RoPE + GQA + SwiGLU + KV cache + GPT-2 byte-level BPE) running
# on the same ctor-independent ggml foundation as the encoder tier. Greedy
# sampling = deterministic. Runs the REAL path only when a generative GGUF
# is present (scratchpad/models are gitignored); the model-free contract
# (graceful "" answers) is asserted always.

load "../../stzBase.ring"
load "../_narrated.ring"

# single-slot engine: the auto-loader takes the first *.gguf alphabetically
# (usually the embedding model) -- seek a GENERATIVE one for the real path
if NOT StzHasGenerativeModel()
	_aGg_ = []
	try _aGg_ = dir("../../../models/") catch done
	nGg = len(_aGg_)
	for iGg = 1 to nGg
		if _aGg_[iGg][2] = 0 and StzFindFirst(lower(_aGg_[iGg][1]), ".gguf") > 0
			StzUseNeuralModel("../../../models/" + _aGg_[iGg][1])
			if StzHasGenerativeModel() exit ok
		ok
	next
ok

Scenario("Model-free contract: generation degrades gracefully")
	if NOT StzHasGenerativeModel()
		Then("no generative model -> not generative", StzHasGenerativeModel(), FALSE)
		Then("...and StzGenerate answers the empty string",
			StzGenerate("hello", 8), "")
	else
		Then("a generative model is loaded", StzHasGenerativeModel(), TRUE)
	ok
EndScenario()

if StzHasGenerativeModel()

	Scenario("Greedy generation answers factual questions")
		Then("capital of France",
			StzAskModel("What is the capital of France?", 24),
			"The capital of France is Paris.")
		Then("largest planet",
			StzAskModel("Name the largest planet of our solar system.", 24),
			"The largest planet of our solar system is Jupiter.")
	EndScenario()

	Scenario("Sampling knobs: variety with reproducibility")
		c1 = StzAskModel("What is the capital of France?", 24)
		c2 = StzAskModelXT("What is the capital of France?",
			[ :MaxTokens = 24, :Temperature = 0 ])
		Then("temperature 0 IS the greedy path", c1 = c2, TRUE)
		c3 = StzAskModelXT("Say something nice about libraries.",
			[ :MaxTokens = 20, :Temperature = 0.8, :Seed = 7 ])
		c4 = StzAskModelXT("Say something nice about libraries.",
			[ :MaxTokens = 20, :Temperature = 0.8, :Seed = 7 ])
		Then("the same seed reproduces the same text", c3 = c4, TRUE)
		Then("...and it is not empty", len(c3) > 0, TRUE)
	EndScenario()

	Scenario("Streaming: token-by-token equals the blocking answer")
		StzStartGeneration(StzChatPrompt("", "What is the capital of France?"),
			[ :MaxTokens = 24, :Temperature = 0 ])
		cAcc = ""
		cTok = StzNextToken()
		while cTok != ""
			cAcc += cTok
			cTok = StzNextToken()
		end
		Then("the accumulated chunks ARE the blocking answer", cAcc = c1, TRUE)
	EndScenario()

	Scenario("The model object speaks too")
		oM = new stzNeuralEngine()
		Then("the engine is ready", oM.IsReady(), TRUE)
		Given("stzNeuralModel.AnswerTo(question) wraps the ChatML template around the question and generates greedily -- deterministic across runs")
	EndScenario()
else
	Scenario("Generative path SKIPPED (no decoder GGUF on disk)")
		Given("drop a llama-family instruct GGUF (SmolLM2/Qwen2.5) into libraries/stzlib/models/ to run the real path")
		Then("the suite stays green without it", TRUE, TRUE)
	EndScenario()
ok

Summary()
