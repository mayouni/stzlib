load "../../stzBase.ring"
load "../_narrated.ring"

# AllCharsAreXT with an evaluation-direction option, and the raw Check()
# predicate over each char. Archive block #481 (check variant).

Scenario("Multi-kind check and a raw predicate")
	Then("248 chars are even positive numbers (RTL evaluation)",
		Q("248").AllCharsAreXT([ :Even, :Positive, :Numbers ], :EvaluateFrom = :RTL), TRUE)
	# The archive's predicate was isnumber( 0+(@char) ). It could not fail:
	# Ring turns any text added to 0 into a number (0 + "a" is 0), and the
	# W evaluator Check() uses since R17 does no implicit coercion at all
	# (its explicit number() coerces the same way, so isnumber(number(@char))
	# holds for "12a" too). A digit test says what the row meant (2026-11-06).
	Then("every char of 123 is a digit",
		Q("123").Check( 'isdigit(@char)' ), TRUE)
	Then("NEGATIVE: a letter among them fails the same check",
		Q("12a").Check( 'isdigit(@char)' ), FALSE)
EndScenario()

Summary()
shutdown($_zst_fail)
