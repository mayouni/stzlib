load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceAll. Archive block #790.

Scenario("Changing towns")
	o1 = new stzString("Tunis is the town of my memories.")
	o1.ReplaceAll("Tunis", "Niamey")
	Then("Niamey now", o1.Content(),
		"Niamey is the town of my memories.")
EndScenario()

Summary()
