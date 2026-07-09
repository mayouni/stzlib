# Narrative
# --------
# ContainsEither(a, :or = b): an EXCLUSIVE either -- TRUE when exactly ONE
# of the two items is present, FALSE when both (or neither) are.
#
# The first list holds BOTH "me" and "you", so ContainsEither is FALSE.
# The second holds "me" but not "you" -- exactly one -- so it is TRUE.
# (For an inclusive "contains any of these", use ContainsOneOfThese.)
#
# Extracted from stzlisttest.ring, block #7.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("ContainsEither(a, :or = b): an EXCLUSIVE either -- TRUE when exactly ONE of the two items")

	o1 = new stzList([ "me", "you", "all", "the", "others" ])
	Then("containseither example 1", @@( o1.ContainsEither("me", :or = "you") ), @@( FALSE ))

	o1 = new stzlist([ "me", "and", "all", "the", "others" ])
	Then("containseither example 2", @@( o1.ContainsEither("me", :or = "you") ), @@( TRUE ))
EndScenario()

Summary()
