# Narrative
# --------
# Stringifying the items of a list
#
# Extracted from stzlisttest.ring, block #11.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("Stringifying the items of a list")

	o1 = new stzList([ 120, "abc", 1:3 ])
	o1.Stringify()
	Then("stringifying_the_items_of_a_list example 1", @@( o1.Content() ), @@( [ "120", "abc", "[ 1, 2, 3 ]" ] ))
EndScenario()

Summary()
