load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceSectionsByMany over three islands. Archive block #961.

Scenario("Caret islands")
	o1 = new stzString("---456----123--67---")
	o1.ReplaceSectionsByMany(
		[ [4, 6], [11, 13], [16, 17] ],
		[ "^^^", "^^^", "^^" ]
	)
	Then("all three replaced", o1.Content(), "---^^^----^^^--^^---")
EndScenario()

Summary()
