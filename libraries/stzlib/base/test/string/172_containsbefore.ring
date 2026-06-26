load "../../stzBase.ring"
load "../_narrated.ring"

# ContainsBefore / ContainsAfter -- whether the substring occurs before/after a
# given position or another substring. Both the positional and the named-param
# (:Position / :SubString) forms work here. Archive block #172.

Scenario("Relative containment of a substring")
	Then("♥ occurs before position 4", Q("^^♥^^").ContainsBefore("♥", :Position = 4), TRUE)
	Then("♥ occurs after position 3", Q("^^^♥^").ContainsAfter("♥", 3), TRUE)
	Then("♥ occurs before the substring '^^'", Q("--♥--^^").ContainsBefore("♥", :SubString = "^^"), TRUE)
	Then("♥ occurs after the substring '^^'", Q("--^^--♥^^").ContainsAfter("♥", "^^"), TRUE)
EndScenario()

Summary()
