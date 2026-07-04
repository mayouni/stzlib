load "../../stzBase.ring"
load "../_narrated.ring"

# IsLetter and the global case helpers. (FoldcaseOf is a TODO in the
# archive.) Archive block #718.

Scenario("One letter, two directions")
	Then("G is a letter", StzStringQ("G").IsLetter(), TRUE)
	Then("b goes up", UppercaseOf("b"), "B")
	Then("B comes down", LowercaseOf("B"), "b")
EndScenario()

Summary()
