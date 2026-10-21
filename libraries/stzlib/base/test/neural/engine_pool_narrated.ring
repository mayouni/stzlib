# Narrative
# ---------
# THE DECODER'S MEMORY POOL (engine/src/neural_gen.zig, forwardDecode).
#
# The forward pass builds its whole graph inside ONE ggml context, and the
# context's size used to be a formula in the model's width:
#     128 MB + kv_len*n_new*n_head*n_layer*24 + n_new*n_embd*n_layer*64
# It was a few hundred KB short for Qwen2.5-Coder-1.5B, so that model could
# not answer even a 40-token prompt ("not enough space in the context's
# memory pool (needed 264244144, available 264048128)"), and at 512 tokens
# the process ended in a GGML_ASSERT. The 0.5B and SmolLM2 fit by luck of
# their shape. Found by the Ring++ session's local K4 (ringpp
# haro/spike/v22/k4/ENGINE_NOTES.md, 2026-10-20), measured there.
#
# This guard states the contract the formula could only hope for: a model the
# engine can load ANSWERS, at a short prompt and at a prompt near the old
# window's edge, without a pool that is too small.
#
# It runs only when the GGUFs are on disk (they are git-ignored) and SKIPS,
# saying which, otherwise. Run it from this directory.

load "../../stzBase.ring"
load "../_narrated.ring"
load "_modelpick.ring"

aModels = [ [ "smollm2-135m", "SmolLM2-135M" ],
            [ "qwen2.5-coder-0.5b", "Qwen2.5-Coder-0.5B" ],
            [ "qwen2.5-coder-1.5b", "Qwen2.5-Coder-1.5B" ] ]

nM = len(aModels)
for iM = 1 to nM
	cNeedle = aModels[iM][1]
	cLabel  = aModels[iM][2]

	if _mpFind(cNeedle) = ""
		Scenario(cLabel + " -- SKIPPED (no such GGUF in libraries/stzlib/models/)")
			Given("drop the file in to run its real path; see models/MODELS.md")
		EndScenario()
		loop
	ok

	Scenario(cLabel + " loads and answers at a SHORT prompt and near the old window")
		Given(cLabel + " resident in the single model slot")
		Then("it loads as a generator", _mpLoad(cNeedle), TRUE)

		When("the secret-word probe is asked with no filler (a short prompt)")
		aS = _mpAsk(0, 6)
		Then("the prompt is short (under 80 tokens)", aS[1] < 80, TRUE)
		Then("it answers (the pool was big enough)", len(aS[2]) > 0, TRUE)

		When("the probe is asked with filler that brings it near the old 512 edge")
		# 14-token sentences: 32 of them land the prompt in the 470s, inside
		# the old window, so this is the pool alone being measured.
		aL = _mpAsk(32, 6)
		Then("the prompt is between 440 and 512 tokens",
			aL[1] >= 440 and aL[1] <= 512, TRUE)
		Then("it answers", len(aL[2]) > 0, TRUE)
		if cNeedle != "smollm2-135m"
			Then("...and it still knows the word from the head of the prompt",
				StzFindFirst("pineapple", lower(aL[2])) > 0, TRUE)
		ok
	EndScenario()
next

Summary()
