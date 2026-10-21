# Narrative
# ---------
# THE DECISION PRIMITIVE (engine/src/neural_gen.zig: neural_gen_prefill_logits / logit_at / logit_lse;
# stzNeuralModel.ring: StzOptionProbabilities). A classifier does not need to GENERATE: after the prompt the model
# holds a distribution over its next token, and the FIRST tokens of the candidate answers are enough to tell them apart.
# Reading that distribution once gives true probabilities (a softmax over the whole vocabulary) with no sampling,
# no parsing and no grammar -- Choice and Noul in the Jev concordance's vocabulary, and the evidence a parcel carries.
#
# Skips, saying so, without Qwen3-0.6B. Run from this directory.

load "../../stzBase.ring"
load "../_narrated.ring"
load "_modelpick.ring"

if _mpFind("qwen3-0.6b-q8") = ""
	Scenario("Option probabilities -- SKIPPED (no Qwen3-0.6B-Q8_0 GGUF in libraries/stzlib/models/)")
		Given("drop the file in to run the real path; see models/MODELS.md")
	EndScenario()
	Summary()
	bye
ok

Scenario("The model's own probabilities for chosen answers")
	Then("Qwen3-0.6B is resident", _mpLoad("qwen3-0.6b-q8"), TRUE)
	cP = StzChatPrompt("", "What is the capital of France? Answer with one word.")
	aR = StzOptionProbabilities(cP, [ "Paris", "London", "Berlin" ])
	Then("the answer carries probabilities, a mass and a best", len(aR[:probabilities]), 3)
	Then("the best option is Paris", aR[:best], "Paris")
	Then("every probability is a true probability (between 0 and 1)", aR[:probabilities][1][2] > 0 and aR[:probabilities][1][2] <= 1, TRUE)
	Then("the candidates hold most of the model's belief here (mass above 0.5)", aR[:mass] > 0.5, TRUE)
	Then("the mass can never exceed 1 (it is a share of a softmax)", aR[:mass] <= 1.0001, TRUE)
	nSum = 0
	for i = 1 to 3 nSum += aR[:normalised][i][2] next
	Then("the normalised choice among the candidates sums to 1", fabs(nSum - 1) < 0.0001, TRUE)
	Then("Paris is far likelier than London", aR[:probabilities][1][2] > 10 * aR[:probabilities][2][2], TRUE)
	aR2 = StzOptionProbabilities(cP, [ "Paris", "London", "Berlin" ])
	Then("a read is deterministic", aR2[:probabilities][1][2], aR[:probabilities][1][2])
EndScenario()

Scenario("A yes/no question (Noul) and agreement with generation")
	cY = StzChatPrompt("", "Is the Earth round? Answer yes or no.")
	aY = StzOptionProbabilities(cY, [ "Yes", "No" ])
	Then("the Earth is round: yes", aY[:best], "Yes")
	cN = StzChatPrompt("", "Is the Moon made of cheese? Answer yes or no.")
	aN = StzOptionProbabilities(cN, [ "Yes", "No" ])
	Then("the Moon is not cheese: no", aN[:best], "No")
	Then("the model is more sure of the first than of the second claim",
		aY[:normalised][1][2] != aN[:normalised][1][2], TRUE)
	cG = lower(StzGenerate(cY, 3))
	Then("the read agrees with what greedy generation starts with", StzFindFirst("yes", cG) > 0, TRUE)
EndScenario()

Scenario("Options that cannot be told apart are refused, not merged")
	bRaised = 0
	try
		StzOptionProbabilities(StzChatPrompt("", "Name a fruit."), [ "apple", "apple pie" ])
	catch
		bRaised = 1
	done
	Then("two options beginning with the same token are REFUSED", bRaised, 1)
	Then("with no model loaded the read answers an empty list", len(StzOptionProbabilities("x", [ "a" ])) >= 0, TRUE)
EndScenario()

Summary()
