load "../../stzBase.ring"
load "../_narrated.ring"

# stzLlmPort -- phase 5 of the service-virtualization plane, and mostly PROMOTION:
# Softanza already had the pieces, this names the contract and puts them behind it.
#
# An LLM port is "any object with Complete(prompt)" returning [ :ok, :text, :from ].
#
# THE HONEST LIMIT COMES FIRST, because it governs everything else: frontier-model
# QUALITY cannot be virtualized. The other ports in this plane substitute
# faithfully -- a mail sink really is mail-shaped, sqlite really is a database.
# Nothing local is GPT-class. So what a generative sandbox buys is not fidelity but
# three other things, each real:
#
#   DETERMINISM -- replay a recorded answer, so a test that depends on model output
#     stops being flaky and becomes a test.
#   COST -- zero, and MEASURABLE: calls and approximate tokens are counted, so
#     "this feature must not cost more than two calls" becomes an assertion.
#   OFFLINE -- no key, no network, no rate limit in CI.
#
# Use it for the SHAPE of a pipeline: prompts assembled right, answers parsed
# right, cost bounded. Judge model QUALITY against the real thing, deliberately, as
# its own activity.

Scenario("replay: the same prompt always gets the same answer")
	oLlm = new stzLlmSandbox()
	oLlm.SeedAnswerQ("What is 2+2?", "4")

	aR = oLlm.Complete("What is 2+2?")
	Then("it answers", aR[:ok], TRUE)
	Then("...exactly what was seeded", aR[:text], "4")
	Then("...marked as a replay", aR[:from], :replay)
	Then("the answer is findable", oLlm.HasAnswerFor("What is 2+2?"), TRUE)
	Then("...and keyed by a stable hash of the prompt", len(oLlm.PromptKey("What is 2+2?")), 64)
	Then("an unseeded prompt is not claimed", oLlm.HasAnswerFor("What is 3+3?"), FALSE)
	# this is what turns a model-dependent test from flaky into deterministic.
EndScenario()

Scenario("scripted: one rule for a FAMILY of prompts")
	oLlm = new stzLlmSandbox()
	oLlm.WhenPromptContainsQ("summarise", "A short summary.")

	Then("a matching prompt is answered", oLlm.Complete("Please summarise this article")[:text], "A short summary.")
	Then("...marked as scripted", oLlm.Complete("summarise it briefly")[:from], :scripted)
	Then("matching is case-insensitive", oLlm.Complete("SUMMARISE THIS")[:ok], TRUE)

	When("a prompt is BOTH seeded and covered by a rule")
	oLlm.SeedAnswerQ("summarise this exactly", "the seeded one")
	Then("the SEEDED answer wins", oLlm.Complete("summarise this exactly")[:from], :replay)
	Then("...with its text", oLlm.Complete("summarise this exactly")[:text], "the seeded one")
	# a recording is what a model actually said; that beats a rule someone wrote.
EndScenario()

Scenario("strict by default, with a fallback for shape-only tests")
	oLlm = new stzLlmSandbox()
	Then("it is strict out of the box", oLlm.IsStrict(), TRUE)

	bRaised = FALSE
	try
		oLlm.Complete("something nobody prepared")
	catch
		bRaised = TRUE
	done
	Then("an unprepared prompt RAISES", bRaised, TRUE)
	# silently answering "" would let a broken pipeline pass.

	When("a catch-all is set, for pipelines where only the SHAPE matters")
	oLlm.SetFallbackQ("(placeholder)")
	aF = oLlm.Complete("literally anything")
	Then("it answers", aF[:text], "(placeholder)")
	Then("...marked as a fallback, so the test knows it is not real", aF[:from], :fallback)
EndScenario()

Scenario("record once from a real model, replay forever")
	# a stand-in "live" model -- any object with Complete(prompt) -- so the
	# recording path is testable with no key and no network.
	oLive = new stzLlmSandbox()
	oLive.WhenPromptContainsQ("capital", "Tunis")

	oSb = new stzLlmSandbox()
	Then("nothing is seeded yet", oSb.NumberOfSeededAnswers(), 0)

	aRec = oSb.RecordFrom(oLive, "What is the capital of Tunisia?")
	Then("the live answer came back", aRec[:text], "Tunis")
	Then("...and is now held", oSb.NumberOfSeededAnswers(), 1)
	Then("it replays offline, identically", oSb.Complete("What is the capital of Tunisia?")[:text], "Tunis")
	Then("...from the recording", oSb.Complete("What is the capital of Tunisia?")[:from], :replay)
	# the plan's own caveat applies: recorded answers DRIFT, so a replay suite needs
	# re-recording and contract tests. Determinism is not permanence.
EndScenario()

Scenario("COST is the fee-free promise, made measurable")
	oLlm = new stzLlmSandbox()
	oLlm.SetFallbackQ("ok")

	oLlm.Complete("first prompt")
	oLlm.Complete("a considerably longer second prompt, with more words in it")

	Then("calls are counted", oLlm.NumberOfCalls(), 2)
	Then("...and approximate tokens with them", oLlm.ApproximateTokensSent() > 0, TRUE)
	# so "this feature must not cost more than N calls" becomes an assertion
	# instead of a hope. APPROXIMATE on purpose -- it is a budget, not a bill.

	Then("what the pipeline SENT is inspectable", oLlm.WasAskedAbout("longer second"), TRUE)
	Then("...which is where prompt-assembly bugs actually live", oLlm.WasAskedAbout("never mentioned"), FALSE)
	Then("the last prompt is available", StzFindFirst("second", oLlm.LastPrompt()) > 0, TRUE)

	When("the counters are cleared between phases of a test")
	oLlm.ClearCallsQ()
	Then("cost resets", oLlm.NumberOfCalls(), 0)
	Then("...but the prepared answers remain", oLlm.Fallback(), "ok")
EndScenario()

Scenario("stzDLM promoted behind the port -- local-real, and it REASONS")
	oKb = new stzKnowledgeGraph("cuisine")
	oKb.Know("tajine", "dish").
	    KnowRelation("tajine", "origin-is", "morocco")
	oSrc = new stzDlmSource( StzDlmQ(oKb) )

	Then("it is LOCAL-REAL, not a fake", oSrc.IsLocalReal(), TRUE)

	aA = oSrc.Complete("what is tajine")
	Then("it answers from the facts it was given", aA[:text], "Tajine is a dish.")
	Then("...marked as coming from the DLM", aA[:from], :dlm)

	When("asked something outside its domain")
	aO = oSrc.Complete("who won in 1998")
	Then("it says so rather than INVENTING",
	     StzFindFirst("outside the 'cuisine' domain", aO[:text]) > 0, TRUE)
	# the opposite failure mode from a language model, and the reason this one is
	# legitimately shippable for a bounded, factual assistant.

	Given("no DLM at all")
	bRaised = FALSE
	try
		new stzDlmSource("not an object")
	catch
		bRaised = TRUE
	done
	Then("it refuses to be built", bRaised, TRUE)
EndScenario()

Scenario("through the registry: the fake is refused in production, the DLM is not")
	oLlm = new stzLlmSandbox()
	oLlm.SetFallbackQ("ok")
	oKb = new stzKnowledgeGraph("cuisine")
	oKb.Know("tajine", "dish")
	oSrc = new stzDlmSource( StzDlmQ(oKb) )

	oReg = new stzServiceRegistry("assistant")
	oReg.Bind(:generative, oLlm)
	oReg.Bind(:knowledge, oSrc)
	Then("the sandbox is detected as a fake", oReg.PostureOf(:generative), :sandbox)
	Then("the DLM source is detected as local", oReg.PostureOf(:knowledge), :local)

	When("the application asks through the service the registry hands back")
	oReg.Service(:generative).Complete("through the registry")
	Then("the ORIGINAL sandbox counted the cost -- state survived Ring's copy",
	     oLlm.NumberOfCalls(), 1)

	When("the phase becomes production")
	oReg.SetPhaseQ(:production)
	Then("exactly ONE thing is refused", len(oReg.Findings()), 1)
	Then("...the fake", oReg.Findings()[1][:where], "assistant/generative")
	# the live side is a frontier-API client behind the same one method, and is
	# infra-gated (a key and a network). The contract is defined; the registry makes
	# sure the sandbox cannot ship in its place.
EndScenario()

Summary()
