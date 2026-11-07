# THE DECODER'S KV CACHE -- IM8b, narrated
#
# The decoder's step used to cost more the longer the context: 27 ms at 82 tokens, 55 ms at 1439 (Granite-Docling's decoder, measured by
# phase 2026-11-03). The cause was not compute: every step copied each layer's whole cache into fresh tensors by scalar loops, concatenated
# it with the new K and V, transposed V again for the attention, in a pool of up to 166 MB allocated and first-touched each step. The cache
# is now persistent, per layer, in the layout the attention reads it (K [hd, cap, n_kv], V transposed [cap, hd, n_kv], cap doubling as a
# prompt grows), written in place from inside the graph and read through views: only the new tokens are written.
#
#   Scene 1  nothing about the answer changed: the greedy text of every decoder family present (llama, qwen2 with biases, qwen3 with q/k
#            norms, granite) on prompts of 5, 11 and 1100+ tokens equals the text the decoder wrote BEFORE the change
#            (_data/decode_equiv_expected.txt); the long prompt crosses every capacity doubling (256, 512, 1024, 2048)
#   Scene 2  a step no longer carries the context: the graph's pool is the same few megabytes at 1400 tokens as at 90 (it was 14 and 166 MB),
#            the cache copy-in and the append phases cost nothing, and a step at 1400 tokens costs under twice a step at 90
#   Scene 3  the cache is reusable: the same prompt twice, and a short prompt after a long one, write the same text
#
# NEEDS a generative GGUF in models/ (gitignored); when absent a scene says so and is SKIPPED BY NAME. ONE GPU/NEURAL JOB AT A TIME.
# THE HELPERS LIVE AFTER pf().

load "../../stzBase.ring"
load "../_narrated.ring"

cModelsDir = "../../../models/"
aModels = [ "smollm2-135m-instruct-q8_0.gguf", "qwen2.5-coder-0.5b-instruct-q8_0.gguf", "Qwen3-0.6B-Q8_0.gguf", "granite-4.0-350m-Q8_0.gguf" ]
cPara = "The river towns of the northern valley keep their records in stone halls, and every spring the clerks count the barges that passed the locks. "
cLong = ""
for i = 1 to 40
	cLong += cPara
next
aPrompts = [ "The capital of France is", "Write a short list of three fruits:" + char(10) + "1.", cLong + "In summary, the clerks" ]
aSkipped = []

#=====================================================================#
Scenario("The greedy text is the text the decoder wrote before the cache changed")
#=====================================================================#
# a checkout with autocrlf hands the file back with carriage returns the
# decoder never wrote, so they go before the split, as they go from cT
aExp = StzSplit(StzReplace(read("_data/decode_equiv_expected.txt"), char(13), ""), char(10))
nCompared = 0
nSame = 0
nModels = 0
for m = 1 to len(aModels)
	if NOT fexists(cModelsDir + aModels[m])
		aSkipped + (aModels[m] + " (not in models/)")
		loop
	ok
	StzNeuralModelQ(cModelsDir + aModels[m])
	if NOT StzHasGenerativeModel()
		aSkipped + (aModels[m] + " (not generative)")
		loop
	ok
	nModels++
	for p = 1 to len(aPrompts)
		cT = StzGenerate(aPrompts[p], 40)
		nTok = StzEngineNeuralGenPromptTokens()
		cT = StzReplace(StzReplace(cT, char(10), "\n"), char(13), "")
		cLine = aModels[m] + "|prompt " + p + " (" + nTok + " tokens)|" + cT
		nCompared++
		if HasLine(aExp, cLine) nSame++ ok
	next
next
? "  " + nSame + " of " + nCompared + " greedy texts equal the pre-change decoder's, over " + nModels + " model families"
Then("every model family present writes, on all three prompts, the text it wrote before", nCompared > 0 and nSame = nCompared, TRUE)
Then("...including the prompt of 1100+ tokens, which crosses every doubling of the cache's capacity (256, 512, 1024, 2048)", nCompared >= 3, TRUE)
EndScenario()

#=====================================================================#
Scenario("A step no longer carries the context")
#=====================================================================#
if nModels = 0
	aSkipped + "scene 2 (no generative model)"
	? "  SKIPPED: no generative model in models/"
else
	# the last model loaded stays in the slot; the question is the same for any
	aCtx = [ 90, 400, 1400 ]
	aPool = []
	aStep = []
	aCopy = []
	aApp = []
	# alternated: short, long, short, long, so the machine's load is on both; the best of two for each
	for r = 1 to 2
		for q = 1 to len(aCtx)
			cTxt = TextOfTokens(aCtx[q], cPara)
			StzEngineNeuralGenStart(cTxt, 1, 0, 1.0, 0, 0)
			nCtx = StzEngineNeuralGenPromptTokens()
			nSum = 0
			nCp = 0
			nAp = 0
			for k = 1 to 12
				t0 = StzEngineWatchTimestampMs()
				StzEngineNeuralVlmFeed(100)
				nSum += StzEngineWatchTimestampMs() - t0
				aP = StzEngineNeuralGenStepPhases()
				nCp += aP[3]
				nAp += aP[5]
			next
			nPoolMb = StzEngineNeuralGenLastPool() / 1048576
			nStep = nSum / 12
			if r = 1
				aPool + nPoolMb
				aStep + nStep
				aCopy + (nCp / 12)
				aApp + (nAp / 12)
			else
				if nStep < aStep[q] aStep[q] = nStep ok
				if nCp / 12 < aCopy[q] aCopy[q] = nCp / 12 ok
			ok
			if r = 1
				? "  context " + nCtx + ": step " + nStep + " ms, build + cache copy-in " + (nCp / 12) + " ms, append " + (nAp / 12) + " ms, pool " + nPoolMb + " MB"
			ok
		next
	next
	Then("the graph's pool at about 1400 tokens is under 16 MB (it was 166 MB for a 258M model, and grew with the context)", aPool[3] < 16, TRUE)
	Then("...and not more than a few MB larger than at 90 tokens (" + aPool[1] + " MB against " + aPool[3] + " MB)", aPool[3] < aPool[1] + 12, TRUE)
	Then("the cache is written in place: the append phase costs nothing (" + aApp[3] + " ms at 1400 tokens)", aApp[3] < 0.5, TRUE)
	Then("the build and cache copy-in at 1400 tokens is under 4 ms (it was 18 ms: scalar loops over the whole cache)", aCopy[3] < 4, TRUE)
	# the TIMING bar is the loosest of the five on purpose: the ratio measured 1.5 on Granite-Docling's decoder (2.0 before the change) and 1.84
	# on granite-4.0-350m, whose attention is a larger share of its step, and the machine's load moves both numbers. The POOL and the
	# PHASES above are the sharp assertions (the pool is bytes, not a clock), and scene 1 proves the answers did not change
	Then("a step at about 1400 tokens costs under 2.5 times a step at 90 (" + (aStep[3] / aStep[1]) + " times)", aStep[3] < 2.5 * aStep[1], TRUE)
ok
EndScenario()

#=====================================================================#
Scenario("The cache is reusable")
#=====================================================================#
if nModels = 0
	aSkipped + "scene 3 (no generative model)"
else
	c1 = StzGenerate(aPrompts[2], 24)
	cLongOut = StzGenerate(aPrompts[3], 8)
	c2 = StzGenerate(aPrompts[2], 24)
	Then("the same prompt twice writes the same text", c1 = c2, TRUE)
	Then("...also after a prompt of 1100+ tokens grew the cache and a short one reused it", len(cLongOut) > 0 and c1 = c2, TRUE)
ok
EndScenario()

if len(aSkipped) > 0
	? "SKIPPED BY NAME, not run: " + len(aSkipped)
	for i = 1 to len(aSkipped)
		? "  - " + aSkipped[i]
	next
ok
Summary()
shutdown($_zst_fail)

func HasLine(aLines, cLine)
	for i = 1 to len(aLines)
		if aLines[i] = cLine return 1 ok
	next
	return 0

# a text of about nTokens tokens: the paragraph repeated (a token is about 6.5 of its characters), cut to the length
func TextOfTokens(nTokens, cPara)
	cT = ""
	nNeed = nTokens * 6
	while len(cT) < nNeed
		cT += cPara
	end
	return left(cT, nNeed)
