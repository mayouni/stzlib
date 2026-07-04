load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveAll. Archive block #808.

Scenario("Ringos to Ring, thrice")
	o1 = new stzString("Ringos Ringos Ringos")
	o1.RemoveAll("os")
	Then("all os gone", o1.Content(), "Ring Ring Ring")
EndScenario()

Summary()
