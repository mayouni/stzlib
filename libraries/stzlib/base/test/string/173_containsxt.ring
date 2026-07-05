load "../../stzBase.ring"
load "../_narrated.ring"

# ContainsXT after a position, and ContainsInSection with inverted
# bounds. Archive block #173.

Scenario("Carets after a point")
	Then("a caret after position 2",
		Q("^^♥^^").ContainsXT("^", :AfterPosition = 2), TRUE)
	Then("a caret in the 5..3 span (normalized)",
		Q("^^♥^^").ContainsInSection("^", 5, 3), TRUE)
EndScenario()

Summary()
