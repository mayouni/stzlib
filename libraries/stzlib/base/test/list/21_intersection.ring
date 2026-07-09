# Narrative
# --------

#
# Extracted from stzlisttest.ring, block #21.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("intersection")

	Then("intersection example 1", @@( Intersection([ 1:3, 2:7, 2:3 ]) ), @@( [ 2, 3 ] ))
EndScenario()

Summary()
