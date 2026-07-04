load "../../stzBase.ring"
load "../_narrated.ring"

# ... and when the run breaks at the second char, there is none.
# (The list form returns [] -- the archive wrote "" loosely.)
# Archive block #767.

Scenario("No run when the second char differs")
	o1 = new stzString("exeeeeeTUNIS")
	Then("no repeated leading char", o1.RepeatedLeadingChar(), "")
	Then("empty list", len( o1.RepeatedLeadingChars() ), 0)
EndScenario()

Summary()
