load "../../stzBase.ring"
load "../_narrated.ring"

# ... while a proper list works. Archive block #967.

Scenario("Ups and downs")
	o1 = new stzString("123---789---")
	o1.ReplaceSectionsByMany([ [1, 3], [7, 9] ], [ "^^^", "vvv" ])
	Then("both replaced", o1.Content(), "^^^---vvv---")
EndScenario()

Summary()
