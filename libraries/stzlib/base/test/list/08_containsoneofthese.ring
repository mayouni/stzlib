# Narrative
# --------
# ContainsOneOfThese (inclusive "any") vs ContainsOnlyOneOfThese (exclusive
# "exactly one").
#
# ContainsOneOfThese is TRUE if AT LEAST one of the given items is present.
# ContainsOnlyOneOfThese is stricter -- TRUE only when EXACTLY one is
# present. The first list holds both "me" and "you" (any: TRUE, only-one:
# FALSE); the second holds just "me" (both TRUE).
#
# Extracted from stzlisttest.ring, block #8.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("ContainsOneOfThese (inclusive any) vs ContainsOnlyOneOfThese (exclusive exactly one).")

	o1 = new stzList([ "me", "you", "all", "the", "others" ])
	Then("containsoneofthese example 1", @@( o1.ContainsOneOfThese([ "me", "you" ]) ), @@( TRUE ))

	Then("containsoneofthese example 2", @@( o1.ContainsOnlyOneOfThese([ "me", "you" ]) ), @@( FALSE ))

	o1 = new stzList([ "me", "and", "all", "the", "others" ])
	Then("containsoneofthese example 3", @@( o1.ContainsOnlyOneOfThese([ "me", "you" ]) ), @@( TRUE ))

	Then("containsoneofthese example 4", @@( o1.ContainsOneOfThese([ "me", "you" ]) ), @@( TRUE ))
EndScenario()

Summary()
