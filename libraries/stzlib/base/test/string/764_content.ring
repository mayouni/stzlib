load "../../stzBase.ring"
load "../_narrated.ring"

# TrimLeft / TrimRight. Archive block #764.

Scenario("Trimming one side at a time")
	o1 = new stzString(" same   ")
	o1.TrimLeft()
	Then("left trimmed", o1.Content(), "same   ")
	o1.TrimRight()
	Then("then right", o1.Content(), "same")
EndScenario()

Summary()
