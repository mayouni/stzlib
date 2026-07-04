load "../../stzBase.ring"
load "../_narrated.ring"

# StringCase() classifies a string as uppercase / lowercase /
# capitalcase / hybridcase. RULING (chunk 38): block #653 and the settled
# CapitalCased vocabulary name the every-word-capitalised case
# :Capitalcase (this block's archive said titlecase -- same concept),
# and the mixed case is :Hybridcase (block #731's and the original
# impl's own word).
# Archive block #247.

Scenario("Classifying the case of a string")
	Then("'RING' is uppercase", Q("RING").StringCase(), "uppercase")
	Then("'ring' is lowercase", Q("ring").StringCase(), "lowercase")
	Then("'Ring' is capitalcase", Q("Ring").StringCase(), "capitalcase")
	Then("'Ring is AWOSOME!' is hybridcase", Q("Ring is AWOSOME!").StringCase(), "hybridcase")
EndScenario()

Summary()
