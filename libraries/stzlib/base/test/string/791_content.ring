load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceAllCS with the case dial off. Archive block #791.

Scenario("Changing towns, case-blind")
	o1 = new stzString("Tunis is the town of my memories.")
	o1.ReplaceAllCS("TUNIS", "Niamey", :CS = FALSE)
	Then("found despite the caps", o1.Content(),
		"Niamey is the town of my memories.")
EndScenario()

Summary()
