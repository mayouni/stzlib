load "../../stzBase.ring"
load "../_narrated.ring"

# Four spellings of space removal. Archive block #636.

Scenario("Removing the spaces")
	Then("the fluent Q form",
		Q("I Work For Afterward").RemoveCharQ(" ").Content(), "IWorkForAfterward")
	Then("the passive form",
		Q("I Work For Afterward").CharRemoved(" "), "IWorkForAfterward")
	Then("the expressive form",
		Q("I Work For Afterward").WithoutSpaces(), "IWorkForAfterward")
	Then("the removed form",
		Q("I Work For Afterward").SpacesRemoved(), "IWorkForAfterward")
EndScenario()

Summary()
