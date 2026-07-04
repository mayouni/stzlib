load "../../stzBase.ring"
load "../_narrated.ring"

# SpacifyCharsXT with named params. Archive block #945.

Scenario("Tilde every two chars")
	o1 = new stzString("SOFTANZA")
	o1.SpacifyCharsXT(:Separator = "~", :Step = 2, :Direction = :Default)
	Then("pairs joined by tildes", o1.Content(), "SO~FT~AN~ZA")
EndScenario()

Summary()
