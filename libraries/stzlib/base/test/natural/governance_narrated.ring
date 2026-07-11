# Narrative
# --------
# P5 -- THE GOVERNANCE KIT (NNL_REVIEW section 7 realized): the natural
# stack as an AGENT CONTRACT. A policy is a named set of natural QUESTIONS
# that allows or denies a value -- and says why it denied; strict mode is
# GROUNDED (unknown referents refuse with the known roster); and
# StzAgentContract(lang) emits, deterministically, everything an external
# agent (an LLM, a program) needs to speak Softanza safely -- in the
# pack's own language.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("A policy allows and denies -- with reasons")
	oP = StzPolicyQ("clean-word")
	oP.RequireQ("Is it lowercase ?").RequireQ("Does it contain 'a' ?")

	Then("'banana' satisfies both questions", oP.Allows("banana"), TRUE)
	Then("...an allowed value was not denied",
		oP.WhyDenied(), "it was not denied")
	Then("'SKY' fails the FIRST question", oP.Allows("SKY"), FALSE)
	Then("...named precisely",
		oP.WhyDenied(), "requirement 1 (Is it lowercase ?) answered no")
	Then("'sky' fails the SECOND", oP.Allows("sky"), FALSE)
	Then("...named precisely",
		oP.WhyDenied(), "requirement 2 (Does it contain 'a' ?) answered no")

	# a policy the language cannot resolve is BROKEN, not permissive
	oBad = StzPolicyQ("broken").RequireQ("Is it zorgluboid ?")
	Then("an ununderstood policy denies and says so",
		oBad.Allows("x"), FALSE)
EndScenario()

Scenario("Grounded strict: an agent never acts on what does not exist")
	bRefused = FALSE
	cErr = ""
	try
		NaturallyStrict("Create a string with 'x' called tag Use ghost")
	catch
		bRefused = TRUE
		cErr = cCatchError
	done
	Then("the unknown referent refuses", bRefused, TRUE)
	Then("...naming the ghost", ( StzFindFirst(cErr, "'ghost'") > 0 ), TRUE)
	Then("...and offering the known roster",
		( StzFindFirst(cErr, "'tag'") > 0 ), TRUE)

	# permissive mode still skips quietly (unchanged behavior)
	oPerm = Naturally("Create a string with 'x' called tag2 Use ghost2")
	Then("non-strict narrations stay permissive", oPerm.Result(), "x")
EndScenario()

Scenario("The agent contract: one deterministic bundle, per language")
	StzKnow("gbasket", "list")
	c = StzAgentContract("en")
	Then("the protocol section is present",
		( StzFindFirst(c, "THE PROTOCOL") > 0 ), TRUE)
	Then("the WORLD lists the known entities",
		( StzFindFirst(c, "gbasket : list") > 0 ), TRUE)
	Then("the vocabulary is sampled from the lexicon",
		( StzFindFirst(c, "remove duplicates") > 0 ), TRUE)
	Then("accountability is part of the contract",
		( StzFindFirst(c, "ambiguity refuses") > 0 ), TRUE)

	cFr = StzAgentContract("fr")
	Then("the FRENCH contract speaks French verbs",
		( StzFindFirst(cFr, "doublons") > 0 ), TRUE)
EndScenario()

Summary()
