load "../../stzBase.ring"
load "../_narrated.ring"

# StringCase: lowercase / uppercase / hybridcase (the original's word
# for a mix). Archive block #731.

Scenario("Three strings, three cases")
	Then("ring", StzStringQ("ring").StringCase(), :Lowercase)
	Then("RING", StzStringQ("RING").StringCase(), :Uppercase)
	Then("RING and python", StzStringQ("RING and python").StringCase(), :Hybridcase)
EndScenario()

Summary()
