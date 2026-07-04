load "../../stzBase.ring"
load "../_narrated.ring"

# IsHashList -- the option-shape check VizFind uses internally.
# Archive block #899.

Scenario("A one-pair hash list")
	Then("recognized",
		IsHashList([ [ "positionchar", "^" ] ]), TRUE)
EndScenario()

Summary()
