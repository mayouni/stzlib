load "../../stzBase.ring"
load "../_narrated.ring"

# stzCCode transpiles the @char W form to executable Ring. (The archive
# showed a double space around = -- cosmetic.) Archive block #642.

Scenario("Transpiling a char condition")
	Then("the @char form lowers to This[@i]",
		StzCCodeQ('@char = "I"').Transpiled(), 'This[@i] = "I"')
EndScenario()

Summary()
