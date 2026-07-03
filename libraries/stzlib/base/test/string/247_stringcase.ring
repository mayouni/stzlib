load "../../stzBase.ring"
load "../_narrated.ring"

# StringCase() classifies a string as uppercase / lowercase /
# capitalcase / mixed. RULING (chunk 38): block #653 and the settled
# CapitalCased vocabulary name the every-word-capitalised case
# :Capitalcase (this block's archive said titlecase -- same concept).
# Archive block #247.

Scenario("Classifying the case of a string")
	Then("'RING' is uppercase", Q("RING").StringCase(), "uppercase")
	Then("'ring' is lowercase", Q("ring").StringCase(), "lowercase")
	Then("'Ring' is capitalcase", Q("Ring").StringCase(), "capitalcase")
	Then("'Ring is AWOSOME!' is mixed", Q("Ring is AWOSOME!").StringCase(), "mixed")
EndScenario()

Summary()
