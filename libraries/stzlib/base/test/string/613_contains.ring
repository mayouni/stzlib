load "../../stzBase.ring"
load "../_narrated.ring"

# Contains basics and the emptiness/inclusion edge rules.
# Archive block #613.

Scenario("Containment edges")
	Then("a string contains itself", Q("ring").Contains("ring"), TRUE)
	Then("but empty does not contain empty", Q("").Contains(''), FALSE)
	Then("a list is not INCLUDED in an equal list",
		Q([ 12, 66 ]).IsIncludedIn([ 12, 66 ]), FALSE)
	Then("its ITEMS are though",
		Q([ 12, 66]).AreInCludedIn([ 12, 66 ]), TRUE)
	Then("empty list does not contain empty list", Q([]).Contains([]), FALSE)
	Then("but a list can hold one", Q([ 1, [], 3 ]).Contains([]), TRUE)
EndScenario()

Summary()
