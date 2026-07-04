load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceSectionsByMany, same-width replacements. Archive block #965.

Scenario("Numbers to carets")
	o1 = new stzString("--345--89---")
	o1.ReplaceSectionsByMany([ [3, 5], [8, 9] ], [ "^^^", "^^" ])
	Then("shape preserved", o1.Content(), "--^^^--^^---")
EndScenario()

Summary()
