# Narrative
# --------
# INTERROGATIVE NARRATIONS (NATURAL_VISION step 4 -- the stzChainOfTruth
# absorption). A chain of truth is now just a narration that asks several
# questions: every QUERY records its answer, in order, and the folds read
# like the old chain surface --
#
#   legacy:  _("ring").IsA(:String).Which(:IsLowercase).Containing("g")._
#   now   :  Naturally("Create a string with 'ring'
#                       Is it lowercase ? Does it contain 'g' ?").AllYes()
#
# Same truth, ONE lexicon, no per-step eval of user strings. The legacy
# _() surface stays frozen for compatibility (see stzChainOfTruth.ring).
#
# Along the way this step fixed a meaning INVERSION: "contain" only
# appeared in DoesNotContain's word bag, so IDF scoring flipped the
# question -- the exact pass on number variants now runs BEFORE any
# scoring, and predicate verbs (Contains/Equals/StartsWith/EndsWith/
# Exists) are classified as QUERIES whatever their surface form says.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("A chain of truth as questions -- all yes")
	oq1 = Naturally("Create a string with 'ring' Is it lowercase ? Does it contain 'g' ?")
	Then("every question records its answer, in order",
		@@( oq1.Answers() ), "[ 1, 1 ]")
	Then("AllYes folds the chain like the legacy ._ closer", oq1.AllYes(), TRUE)
	Then("the paraphrase shows BOTH questions as asks",
		oq1.Understood(),
		"create a string with ring -> ask: is lowercase -> ask: contains")
EndScenario()

Scenario("Mixed answers distinguish All from Any")
	oq2 = Naturally("Create a string with 'RING' Is it lowercase ? Does it contain 'G' ?")
	Then("answers record the truth of each question",
		@@( oq2.Answers() ), "[ 0, 1 ]")
	Then("AllYes refuses on one no", oq2.AllYes(), FALSE)
	Then("AnyYes accepts on one yes", oq2.AnyYes(), TRUE)
EndScenario()

Scenario("The predicate-verb family answers instead of no-oping")
	oq3 = Naturally("Create a string with 'softanza' Does it contain 'xyz' ?")
	Then("a NO is a recorded answer, not a silence",
		@@( oq3.Answers() ), "[ 0 ]")

	# third-person morphology + predicate verb together
	oq4 = Naturally("Create a string with 'softanza' Contains it 'soft' ?")
	Then("bare 'contains' asks too", @@( oq4.Answers() ), "[ 1 ]")
EndScenario()

Scenario("Result() keeps its contract; no questions means no answers")
	oq5 = Naturally("Create a string with 'ring' Is it lowercase ?")
	Then("Result() is still the last thing produced", oq5.Result(), 1)

	oq6 = Naturally("Create a string with 'ring' and uppercase it")
	Then("a narration with no questions has no answers",
		@@( oq6.Answers() ), "[ ]")
	Then("and AllYes on no answers is FALSE, honestly", oq6.AllYes(), FALSE)
EndScenario()

Summary()
