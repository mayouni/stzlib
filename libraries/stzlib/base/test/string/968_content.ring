load "../../stzBase.ring"
load "../_narrated.ring"

# Shorter replacements shrink the string. Archive block #968.

Scenario("Numbers to single marks")
	o1 = new stzString("--345--89--")
	o1.ReplaceSectionsByMany([ [3, 5], [8, 9] ], [ "*", "~" ])
	Then("shrunk", o1.Content(), "--*--~--")
EndScenario()

Summary()
