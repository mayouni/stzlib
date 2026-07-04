load "../../stzBase.ring"
load "../_narrated.ring"

# Trimmed and Simplify + Uppercased. Archive block #828.

Scenario("Whitespace housekeeping")
	o1 = new stzString("  lots   of    whitespace  ")
	Then("edges trimmed", o1.Trimmed(), "lots   of    whitespace")
	Then("then squeezed and shouted",
		o1.SimplifyQ().Uppercased(), "LOTS OF WHITESPACE")
EndScenario()

Summary()
