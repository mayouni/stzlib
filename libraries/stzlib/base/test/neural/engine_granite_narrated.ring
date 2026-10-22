# Narrative
# ---------
# GRANITE (engine/src/neural_gen.zig). IBM's Granite 4.x dense models (Apache-2.0, official GGUF, 12 languages
# including French and Arabic) are the llama graph with FOUR SCALARS the GGUF states:
#   embedding_scale   the token embeddings are multiplied by it
#   attention.scale   the attention logits use it instead of 1/sqrt(head_dim)
#   residual_scale    each branch (attention, FFN) is scaled by it before it is added to the residual
#   logit_scale       the logits are DIVIDED by it
# Until this guard the engine did not recognise the architecture string `granite` at all.
#
# BEHAVIOURAL, not numeric: no independent reference (llama.cpp / numpy) was available; four correct, different
# answers from a 350M model with the scalars applied is evidence, not a parity proof. A numpy reference is owed.
# Skips, saying so, without the GGUF. Run from this directory.

load "../../stzBase.ring"
load "../_narrated.ring"
load "_modelpick.ring"

if _mpFind("granite-4.0-350m-q8") = ""
	Scenario("Granite -- SKIPPED (no granite-4.0-350m-Q8_0 GGUF in libraries/stzlib/models/)")
		Given("drop the file in to run the real path; see models/MODELS.md")
	EndScenario()
	Summary()
	bye
ok

Scenario("Granite-4.0-350m is recognised as a generator and answers")
	Then("it loads as a generator", _mpLoad("granite-4.0-350m-q8"), TRUE)
	Then("its architecture is granite", StzEngineNeuralModelArch(), "granite")
	cParis = lower(_mpGraniteAsk("What is the capital of France? Answer with one word.", 24))
	Then("the capital of France is Paris", StzFindFirst("paris", cParis) > 0, TRUE)
	cTokyo = lower(_mpGraniteAsk("What is the capital of Japan? Answer with one word.", 24))
	Then("the capital of Japan is Tokyo", StzFindFirst("tokyo", cTokyo) > 0, TRUE)
	cFive = _mpGraniteAsk("What is 2 + 3? Answer with the number only.", 24)
	Then("2 + 3 is 5", StzFindFirst("5", cFive) > 0, TRUE)
	cFr = lower(_mpGraniteAsk("Translate to French: good morning", 24))
	Then("good morning is bonjour", StzFindFirst("bonjour", cFr) > 0, TRUE)
EndScenario()

Scenario("It is deterministic, keeps the head of a long prompt")
	cA = _mpGraniteAsk("What is the capital of France? Answer with one word.", 24)
	Then("the same prompt gives the same answer", _mpGraniteAsk("What is the capital of France? Answer with one word.", 24), cA)
	cSecret = "<|start_of_role|>system<|end_of_role|>The secret word is PINEAPPLE. When asked for the secret word, answer with exactly that word and nothing else.<|end_of_text|>" + char(10) + "<|start_of_role|>user<|end_of_role|>" + _mpFiller(30) + "What is the secret word?<|end_of_text|>" + char(10) + "<|start_of_role|>assistant<|end_of_role|>"
	Then("the prompt is a few hundred tokens", StzTokenCount(cSecret) > 300, TRUE)
	Then("the secret word survives", StzFindFirst("pineapple", lower(StzGenerate(cSecret, 10))) > 0, TRUE)
EndScenario()

Scenario("The chat template follows the model's VOCABULARY, not the architecture name")
	Given("Granite 4.0 has its role markers as tokens; Granite 4.2 shares the architecture and speaks ChatML")
	Then("Granite 4.0: <|start_of_role|> is one token", StzChatHasToken("<|start_of_role|>"), 1)
	Then("Granite 4.0: <|im_start|> is not", StzChatHasToken("<|im_start|>"), 0)
	Then("Granite 4.0: the prompt uses its role markers", StzFindFirst("<|start_of_role|>", StzChatPrompt("", "hi")) > 0, TRUE)
	Then("Granite 4.0: through the template, France's capital is Paris",
		StzFindFirst("paris", lower(StzGenerate(StzChatPrompt("Answer with one word.", "What is the capital of France?"), 16))) > 0, TRUE)
EndScenario()

if _mpFind("granite-4.2-3b") = ""
	Scenario("Granite 4.2 -- SKIPPED (no granite-4.2-3b GGUF in libraries/stzlib/models/)")
	EndScenario()
else
	Scenario("Granite 4.2 gets ChatML and an empty thinking block, as its own template does with thinking off")
		Then("it loads as a granite generator", _mpLoad("granite-4.2-3b") and StzEngineNeuralModelArch() = "granite", TRUE)
		Then("<|start_of_role|> is NOT one of its tokens", StzChatHasToken("<|start_of_role|>"), 0)
		Then("<|im_start|> is", StzChatHasToken("<|im_start|>"), 1)
		cP = StzChatPrompt("", "hi")
		Then("the prompt is ChatML", StzFindFirst("<|im_start|>assistant", cP) > 0, TRUE)
		Then("and carries no Granite 4.0 marker", StzFindFirst("<|start_of_role|>", cP), 0)
		Then("it ends with the thinking-off block", right(cP, 15), "<think></think>")
		cAns = StzGenerate(StzChatPrompt("Answer with one word.", "What is the capital of France?"), 16)
		Then("France's capital is Paris", StzFindFirst("paris", lower(cAns)) > 0, TRUE)
		Then("and no marker leaks into the answer", StzFindFirst("<|", cAns), 0)
	EndScenario()
ok

Summary()
