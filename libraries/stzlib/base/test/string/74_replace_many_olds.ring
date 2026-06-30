load "../../stzBase.ring"
load "../_narrated.ring"

# Replace([olds], :By = new) is the ReplaceMany shorthand -- every listed old
# substring is replaced by the single new one. Archive block #74.

Scenario("Replacing many substrings by one")
	Given('"a + b - c / d = 0"')
	o1 = new stzString("a + b - c / d = 0")
	o1.Replace( [ "+", "-", "/" ], :By = "*" )
	Then("each operator becomes a star", o1.Content(), "a * b * c * d = 0")
EndScenario()

Summary()
