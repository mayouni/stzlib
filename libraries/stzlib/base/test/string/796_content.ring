load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveFirstOccurrence with :Of. Archive block #796.

Scenario("Only the first Land goes")
	o1 = new stzString("LandRingoriaLand")
	o1.RemoveFirstOccurrence( :Of = "Land")
	Then("the trailing one stays", o1.Content(), "RingoriaLand")
EndScenario()

Summary()
