load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceAllQ chains. Archive block #721.

Scenario("Renaming a placeholder")
	Then("every @char becomes @item",
		StzStringQ("@char___@char___@char").ReplaceAllQ("@char", "@item").Content(),
		"@item___@item___@item")
EndScenario()

Summary()
