load "../../stzBase.ring"
load "../_narrated.ring"

# ... and positionally, walking backward with step 3.
# Archive block #946.

Scenario("Tilde every three chars, from the right")
	o1 = new stzString("SOFTANZA")
	o1.SpacifyCharsXT("~", 3, :backward)
	Then("threes from the tail", o1.Content(), "SO~FTA~NZA")
EndScenario()

Summary()
