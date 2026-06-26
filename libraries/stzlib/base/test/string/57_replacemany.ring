load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceMany(olds, :By = new) -- replace EACH of several substrings by the SAME
# single replacement. Archive block #57.

Scenario("Collapsing several operators into one")
	Given('"a + b - c / d = 0"')
	o1 = new stzString("a + b - c / d = 0")
	o1.ReplaceMany([ "+", "-", "/" ], :By = "*")
	Then("+, - and / all become *", o1.Content(), "a * b * c * d = 0")
EndScenario()

Summary()
