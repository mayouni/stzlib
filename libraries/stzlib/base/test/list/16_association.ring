# Narrative
# --------

#
# Extracted from stzlisttest.ring, block #16.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("association")

	Then("association example 1", @@( Association([ "A":"C", 1:3, "a":"c" ]) ), @@( [ [ "A", 1, "a" ], [ "B", 2, "b" ], [ "C", 3, "c" ] ] ))
EndScenario()

Summary()
