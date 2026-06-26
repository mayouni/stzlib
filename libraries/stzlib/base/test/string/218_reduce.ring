load "../../stzBase.ring"
load "../_narrated.ring"

# Reduce() -- concatenate a list of strings into one. Archive block #218.

Scenario("Reducing a list of strings to one")
	Then("the parts join into a sentence",
		Q([ "I ", "believe ", "in ", "Ring!" ]).Reduce(), "I believe in Ring!")
EndScenario()

Summary()
