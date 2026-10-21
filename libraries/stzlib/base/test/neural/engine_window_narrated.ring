# Narrative
# ---------
# THE PROMPT WINDOW (engine/src/neural_gen.zig, neural_gen_start_x).
#
# A fresh prompt used to be cut to its LAST 512 tokens, silently. A system
# message at the head survived at 506 tokens and was gone at 514; the answer
# was merely wrong, and nothing said why (found by the Ring++ session's local
# K4, 2026-10-20: a few-shot prompt of ~1,400 tokens reached the model as the
# tail of its last example). Anything built on StzGenerateXT with a long
# system prompt, a few-shot prompt or a retrieved context failed soft.
#
# The contract this guard states:
#   1. THE SECRET-WORD PROBE: a system message "the secret word is PINEAPPLE",
#      then filler, then the question -- the model still answers it when the
#      prompt is 1,200+ tokens (it failed at 514 before).
#   2. NEVER SILENT: a prompt that does not fit the window is REFUSED with a
#      sentence naming both numbers, never trimmed.
#   3. A generation that runs into the end of the window stops and says so
#      (StzLastGenerationTruncated).
#   4. The token count is readable (StzTokenCount).
#
# Runs only with the GGUFs on disk and SKIPS saying so otherwise. The probe is
# asked of Qwen2.5-Coder-0.5B, which reads a long prompt and keeps its head;
# SmolLM2-135M is used for the window bounds, where the answer is not the point.
# Run from this directory.

load "../../stzBase.ring"
load "../_narrated.ring"
load "_modelpick.ring"

if _mpFind("qwen2.5-coder-0.5b") = ""
	Scenario("Prompt window -- SKIPPED (no Qwen2.5-Coder-0.5B GGUF in libraries/stzlib/models/)")
		Given("drop the file in to run the real path; see models/MODELS.md")
	EndScenario()
	Summary()
	bye
ok

Scenario("The secret word survives a prompt far past the old 512-token cap")
	Given("Qwen2.5-Coder-0.5B resident")
	Then("it loads as a generator", _mpLoad("qwen2.5-coder-0.5b"), TRUE)

	When("the probe is asked at about 1,200 tokens (85 filler sentences)")
	aA = _mpAsk(85, 6)
	Then("the prompt is past 1,200 tokens", aA[1] >= 1200, TRUE)
	Then("the engine reports the same count as the tokenizer", StzLastPromptTokens(), aA[1])
	Then("the model still knows the word from the HEAD of the prompt",
		StzFindFirst("pineapple", lower(aA[2])) > 0, TRUE)
	Then("nothing was cut: the window did not fill", StzLastGenerationTruncated(), 0)

	When("the same probe is asked at about 2,000 tokens (140 filler sentences)")
	aB = _mpAsk(140, 6)
	Then("the prompt is past 1,900 tokens", aB[1] >= 1900, TRUE)
	Then("the model still knows the word", StzFindFirst("pineapple", lower(aB[2])) > 0, TRUE)
EndScenario()

Scenario("A prompt that does not fit the window is refused, never trimmed")
	Given("the window lowered to 600 tokens for the test")
	Then("the window in force is 600", StzSetContextLimit(600), 600)
	Then("the model reports a window of 600", StzModelContextWindow(), 600)

	When("a prompt of about 900 tokens is asked")
	cMsg = ""
	try
		StzGenerate(_mpSecretPrompt(60), 4)
	catch
		cMsg = cCatchError
	done
	Then("it is REFUSED, not answered", len(cMsg) > 0, TRUE)
	Then("...and the sentence names the window", StzFindFirst("context window (600 tokens)", cMsg) > 0, TRUE)
	Then("...and says it was refused rather than trimmed", StzFindFirst("refused, not trimmed", cMsg) > 0, TRUE)
	Then("the error code is 2 (prompt does not fit)", StzLastGenerationError(), 2)

	When("a prompt of about 400 tokens is asked in the same window")
	aC = _mpAsk(25, 4)
	Then("it fits and is answered", len(aC[2]) > 0, TRUE)
	Then("the error is cleared", StzLastGenerationError(), 0)

	When("a generation that never ends on its own is asked to run past a 150-token window")
	StzSetContextLimit(150)
	cCount = StzChatPrompt("", "Count from 1 to 400, separated by commas, with nothing else.")
	nCountTokens = StzTokenCount(cCount)
	cCounted = StzGenerate(cCount, 400)
	Then("the prompt itself fit (well under 150)", nCountTokens < 100, TRUE)
	Then("it wrote something", len(cCounted) > 0, TRUE)
	Then("the generation stopped at the window and SAYS SO", StzLastGenerationTruncated(), 1)
	Then("...and the answer is not the whole count to 400", StzFindFirst("400", cCounted) = 0, TRUE)
	StzSetContextLimit(600)
	When("a short answer that ends on its own is asked")
	StzGenerate(StzChatPrompt("", "Say the single word yes."), 40)
	Then("the flag is cleared: ending by itself is not truncation", StzLastGenerationTruncated(), 0)

	Given("the window restored to the model's trained context")
	Then("the trained context is bigger than 600", StzSetContextLimit(0) > 600, TRUE)
EndScenario()

Scenario("The token count is readable before anything is generated")
	Then("a short text has a small count", StzTokenCount("one two three") > 0 and StzTokenCount("one two three") < 8, TRUE)
	Then("the count grows with the text", StzTokenCount(_mpFiller(10)) > StzTokenCount(_mpFiller(2)), TRUE)
EndScenario()

Summary()
