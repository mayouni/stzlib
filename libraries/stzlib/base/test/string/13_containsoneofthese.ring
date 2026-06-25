load "../../stzBase.ring"
load "../_narrated.ring"

# ContainsOneOfThese(list) -- TRUE if the string contains AT LEAST ONE of the
# items (inclusive). ContainsOnlyOneOfThese(list) -- TRUE only if it contains
# EXACTLY ONE of them (exclusive).

Scenario("Inclusive vs exclusive containment")
	Given('"me you all the others" (both) and "me and all the others" (only me)')
	Then("both present -> ContainsOneOfThese TRUE",
		Q("me you all the others").ContainsOneOfThese([ "me", "you" ]), TRUE)
	Then("both present -> ContainsOnlyOneOfThese FALSE",
		Q("me you all the others").ContainsOnlyOneOfThese([ "me", "you" ]), FALSE)
	Then("only one present -> ContainsOnlyOneOfThese TRUE",
		Q("me and all the others").ContainsOnlyOneOfThese([ "me", "you" ]), TRUE)
	Then("only one present -> ContainsOneOfThese TRUE",
		Q("me and all the others").ContainsOneOfThese([ "me", "you" ]), TRUE)
EndScenario()

Summary()
