load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceMany. Archive block #792.

Scenario("Unifying the operators")
	o1 = new stzString("a + b - c / d = 0")
	o1.ReplaceMany([ "+", "-", "/" ], "*")
	Then("all become *", o1.Content(), "a * b * c * d = 0")
EndScenario()

Summary()
