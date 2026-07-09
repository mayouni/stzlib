# Narrative
# --------

#
# Extracted from stzlisttest.ring, block #218.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("extract")

	 # Extract(item) removes the item from the list and returns it

	o1 = new stzList([ "A", "B", "_", "C" ])

	Then("extract example 1", @@( o1.Extract("_") ), @@( "_" ))

	Then("extract example 2", @@( o1.Content() ), @@( [ "A", "B", "C" ] ))
EndScenario()

Summary()
