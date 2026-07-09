# Narrative
# --------

#
# Extracted from stzlisttest.ring, block #220.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("extractall")

	o1 = new stzList([ "A", "B", "C" ])

	Then("extractall example 1", @@( o1.ExtractAll() ), @@( [ "A", "B", "C" ] ))

	Then("extractall example 2", @@( o1.Content() ), @@( [] ))
EndScenario()

Summary()
