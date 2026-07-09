# Narrative
# --------
# ///
#
# Extracted from stzlisttest.ring, block #6.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("///")

	Then("manyremoved example 1", @@( Q(1:10).ManyRemoved([ 3, 7, 9 ]) ), @@( [ 1, 2, 4, 5, 6, 8, 10 ] ))
EndScenario()

Summary()
