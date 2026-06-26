load "../../stzBase.ring"
load "../_narrated.ring"

# ContainsSubStringBoundedBy(sub, [open, close]) -- whether `sub` occurs enclosed
# by the given bounds. Archive block #184.

Scenario("Containment of a bounded substring")
	Then("'♥♥♥' is enclosed by '^^' .. '^^'",
		Q("^^♥♥♥^^").ContainsSubStringBoundedBy("♥♥♥", [ "^^", "^^" ]), TRUE)
EndScenario()

Summary()
