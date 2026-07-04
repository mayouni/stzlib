load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceFirst fed by a Section read. Archive block #803.

Scenario("Rewriting the tail of a sentence")
	o1 = new stzString("Softanza loves simplicity")
	Then("everything from position 10 becomes arrives!",
		o1.ReplaceFirstQ( o1.Section(10, :LastChar), "arrives!").Content(),
		"Softanza arrives!")
EndScenario()

Summary()
