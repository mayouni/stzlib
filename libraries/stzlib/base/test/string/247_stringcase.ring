load "../../stzBase.ring"
load "../_narrated.ring"

# StringCase() classifies a string as uppercase / lowercase / titlecase / mixed.
# Archive block #247.

Scenario("Classifying the case of a string")
	Then("'RING' is uppercase", Q("RING").StringCase(), "uppercase")
	Then("'ring' is lowercase", Q("ring").StringCase(), "lowercase")
	Then("'Ring' is titlecase", Q("Ring").StringCase(), "titlecase")
	Then("'Ring is AWOSOME!' is mixed", Q("Ring is AWOSOME!").StringCase(), "mixed")
EndScenario()

Summary()
