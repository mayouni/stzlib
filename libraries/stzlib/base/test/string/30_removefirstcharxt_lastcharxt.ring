load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveFirstCharXT() / RemoveLastCharXT() -- peel the whole leading / trailing
# run of the end char. Archive block #30.

Scenario("Peeling both ends of a fenced word")
	Given('"---Ring---"')
	o1 = new stzString("---Ring---")
	o1.RemoveFirstCharXT()
	Then("the leading dashes go", o1.Content(), "Ring---")
	o1.RemoveLastCharXT()
	Then("the trailing dashes go too", o1.Content(), "Ring")
EndScenario()

Summary()
