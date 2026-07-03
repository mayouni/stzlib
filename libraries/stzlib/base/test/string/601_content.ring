load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceSubStringAtPosition with the :With spelling. Archive block #601.

Scenario("Hearts become Ring")
	o1 = new stzString("Softanza embraces ♥♥♥ simplicty and flexibility")
	o1.ReplaceSubStringAtPosition(19, "♥♥♥", :With = "Ring")
	Then("replaced in place",
		o1.Content(), "Softanza embraces Ring simplicty and flexibility")
EndScenario()

Summary()
