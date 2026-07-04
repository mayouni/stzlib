load "../../stzBase.ring"
load "../_narrated.ring"

# - with a list removes each item; a Q()-wrapped RHS keeps the result
# chainable. Archive block #786.

Scenario("Peeling Ringoria down to Ring")
	Then("raw list, raw result",
		Q("ORingoriaLand") - [ "O", "oria", "Land" ], "Ring")
	Then("Q-wrapped list, chainable result",
		( Q("ORingoriaLand") - Q([ "O", "oria", "Land" ]) ).Content(), "Ring")
EndScenario()

Summary()
