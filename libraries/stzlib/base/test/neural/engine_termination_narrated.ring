# Narrative
# ---------
# TERMINATION AIDS (engine/src/neural_gen.zig, StzGenerateXT).
#
# The constrained decoder guarantees a valid SHAPE, not an END: a grammar that may
# always take one more statement is satisfied by one more statement, so a small
# model with nothing left to say loops inside it until the token cap. Measured by
# the Ring++ session's local K4 (ENGINE_NOTES.md, 2026-10-20): Qwen2.5-Coder-1.5B
# left 8 of its 20 Ring++ programs without their end marker, repeating one line up
# to 48 times; the sampler had no repetition penalty.
#
# Three options, each OFF by default and deterministic (no random draw is added):
#     :RepeatPenalty n   a token this answer already wrote has its logit divided by n
#     :StopOnRepeat n    end the answer once the same line has been written n times running
#     :EndBias x         while a grammar is satisfied, raise the end-of-text logits by x
#
# This guard states what each one DOES, and that none of them changes anything
# unless asked. What each one HURTS is measured in _measure_termination.ring (K4).
# Uses SmolLM2-135M, which loops on a repeated line; SKIPS saying so without it.
# Run from this directory.

load "../../stzBase.ring"
load "../_narrated.ring"
load "_modelpick.ring"

if _mpFind("smollm2-135m") = ""
	Scenario("Termination aids -- SKIPPED (no SmolLM2-135M GGUF in libraries/stzlib/models/)")
		Given("drop the file in to run the real path; see models/MODELS.md")
	EndScenario()
	Summary()
	bye
ok

cLoop = "step one done" + char(10) + "step one done" + char(10) + "step one done" + char(10) + "step one done" + char(10)

Scenario("Nothing changes unless asked")
	Given("SmolLM2-135M resident and a prompt it loops on")
	Then("it loads as a generator", _mpLoad("smollm2-135m"), TRUE)
	cBase = StzGenerateXT(cLoop, [ [ :MaxTokens, 60 ] ])
	cBase2 = StzGenerateXT(cLoop, [ [ :MaxTokens, 60 ] ])
	Then("a plain run loops (the line repeats many times)", _mpMostRepeated(cBase) >= 10, TRUE)
	Then("a plain run is reproducible", cBase2, cBase)
	cDefaults = StzGenerateXT(cLoop, [ [ :MaxTokens, 60 ], [ :RepeatPenalty, 1 ], [ :StopOnRepeat, 0 ], [ :EndBias, 0 ] ])
	Then("the options at their off values change nothing", cDefaults, cBase)
	Then("StopOnRepeat did not fire", StzLastGenerationStoppedOnRepeat(), 0)
EndScenario()

Scenario(":StopOnRepeat ends a loop after n identical lines")
	cStop = StzGenerateXT(cLoop, [ [ :MaxTokens, 60 ], [ :StopOnRepeat, 4 ] ])
	Then("it fired", StzLastGenerationStoppedOnRepeat(), 1)
	Then("the answer is exactly four lines", len(_mpLines(cStop)), 4)
	Then("...each the looped line", _mpMostRepeated(cStop), 4)
	Then("...and shorter than the plain run", len(cStop) < len(cBase), TRUE)
	Then("the options are uninstalled after the call: the next plain run loops again",
		StzGenerateXT(cLoop, [ [ :MaxTokens, 60 ] ]), cBase)
	Then("...and the flag is cleared by the next generation", StzLastGenerationStoppedOnRepeat(), 0)
	cStop2 = StzGenerateXT(cLoop, [ [ :MaxTokens, 60 ], [ :StopOnRepeat, 4 ] ])
	Then("it is deterministic", cStop2, cStop)
EndScenario()

Scenario(":RepeatPenalty breaks the loop")
	cPen = StzGenerateXT(cLoop, [ [ :MaxTokens, 60 ], [ :RepeatPenalty, 1.6 ] ])
	cPen2 = StzGenerateXT(cLoop, [ [ :MaxTokens, 60 ], [ :RepeatPenalty, 1.6 ] ])
	Then("the answer differs from the plain run", cPen != cBase, TRUE)
	Then("the most repeated line repeats fewer times", _mpMostRepeated(cPen) < _mpMostRepeated(cBase), TRUE)
	Then("it is deterministic", cPen2, cPen)
	Then("a penalty of 1 is the plain run",
		StzGenerateXT(cLoop, [ [ :MaxTokens, 60 ], [ :RepeatPenalty, 1 ] ]), cBase)
EndScenario()

Scenario(":EndBias lets a model finish once the grammar is satisfied")
	cGram = 'root ::= "step one done" ("\n" "step one done")*'
	cG0 = StzGenerateXT(cLoop, [ [ :MaxTokens, 60 ], [ :Grammar, cGram ] ])
	Then("under the grammar alone the answer keeps going (more than 5 lines)", len(_mpLines(cG0)) > 5, TRUE)
	cG1 = StzGenerateXT(cLoop, [ [ :MaxTokens, 60 ], [ :Grammar, cGram ], [ :EndBias, 50 ] ])
	Then("with a strong end bias it stops as soon as the grammar is satisfied", len(_mpLines(cG1)), 1)
	Then("...the grammar is satisfied where it stopped", StzLastGrammarRun()[:complete], 1)
	Then("a bias of 0 is the grammar alone",
		StzGenerateXT(cLoop, [ [ :MaxTokens, 60 ], [ :Grammar, cGram ], [ :EndBias, 0 ] ]), cG0)
EndScenario()

Summary()
