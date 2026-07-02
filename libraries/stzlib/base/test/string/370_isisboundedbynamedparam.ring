load "../../stzBase.ring"
load "../_narrated.ring"

# The :IsBoundedBy named-param plumbing: the param-shape detector on a
# Q()-list, the direct SubStringIsBoundedBy check (a single bound string
# widens to both sides), and the SubStringXT spelling.
# Archive block #370.

Scenario("IsBoundedBy in three spellings")
	Then("the named-param shape is recognised",
		Q(:IsBoundedBy = ".").IsIsBoundedByNamedParam(), TRUE)
	Then("the direct check",
		Q(".♥.").SubStringIsBoundedBy("♥", "."), TRUE)
	Then("the SubStringXT spelling",
		Q(".♥.").SubStringXT("♥", :IsBoundedBy = "."), TRUE)
EndScenario()

Summary()
