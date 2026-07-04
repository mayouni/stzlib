load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveXT with an empty options list is a plain remove-all.
# Archive block #892.

Scenario("No options, no hearts")
	o1 = new stzString("/♥♥♥\__/♥\/♥♥\__/♥\__")
	o1.RemoveXT("♥", [])
	Then("every heart gone", o1.Content(), "/\__/\/\__/\__")
EndScenario()

Summary()
