load "../../stzBase.ring"
load "../_narrated.ring"

# ContainsXT(sub, :Before = n) / :After = n -- the shorter spelling of the
# position-anchored contains. Archive block #175.

Scenario("Contains :Before / :After a position")
	Then("'^' is before 3 in '^^♥^^'", Q("^^♥^^").ContainsXT("^", :Before = 3), TRUE)
	Then("'^' is after 2 in '--♥^^'", Q("--♥^^").ContainsXT("^", :After = 2), TRUE)
EndScenario()

Summary()
