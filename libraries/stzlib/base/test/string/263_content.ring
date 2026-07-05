load "../../stzBase.ring"
load "../_narrated.ring"

# stzCCode transpiles the @item form. (The archive showed loose
# spacing/casing "isnumber( 0+  this[@i]  )"; the transpiler's actual
# output preserves the source form.) Archive block #263.

Scenario("Transpiling an item condition")
	o1 = new stzCCode("isNumber(0+ @item)")
	o1.Transpile()
	Then("the @item form lowers to This[@i]",
		o1.Content(), "isNumber(0+ This[@i])")
EndScenario()

Summary()
