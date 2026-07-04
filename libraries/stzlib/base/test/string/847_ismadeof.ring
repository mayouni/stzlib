load "../../stzBase.ring"
load "../_narrated.ring"

# IsMadeOf with the :and narrative tail. Archive block #847.

Scenario("A binary-ish string of three digits")
	o1 = new stzString("10011033001")
	Then("made of 1, 0 and 3",
		o1.IsMadeOf([ "1", "0", "3" ]), TRUE)
	Then("same, said narratively",
		o1.IsMadeOf([ "1", "0", :and = "3" ]), TRUE)
EndScenario()

Summary()
