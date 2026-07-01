load "../../stzBase.ring"
load "../_narrated.ring"

# ContainsXT(sub, :BeforePosition = n) / :AfterPosition = n -- is there an
# occurrence of sub before / after the given position? Archive block #174.

Scenario("Contains before/after a position")
	Then("'^' occurs before position 3 in '^^♥^^'", Q("^^♥^^").ContainsXT("^", :BeforePosition = 3), TRUE)
	Then("'^' occurs after position 2 in '--♥^^'", Q("--♥^^").ContainsXT("^", :AfterPosition = 2), TRUE)
EndScenario()

Summary()
