load "../../stzBase.ring"
load "../_narrated.ring"

# ContainsXT(sub, :Before = anchor) / :After = anchor -- here the anchor is a
# SUBSTRING rather than a position. Archive block #176.

Scenario("Contains before/after a substring anchor")
	Then("'^' occurs before '♥^' in '^^♥^^'", Q("^^♥^^").ContainsXT("^", :Before = "♥^"), TRUE)
	Then("'^' occurs after '-♥' in '--♥^^'", Q("--♥^^").ContainsXT("^", :After = "-♥"), TRUE)
EndScenario()

Summary()
