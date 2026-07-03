load "../../stzBase.ring"
load "../_narrated.ring"

# Next-nth marquer from a position: string and position forms.
# Archive block #611.

Scenario("Second marquer after position 14")
	o1 = new stzString("My name is #1, my age is #2, and my job is #3. Again: my name is #1!")
	Then("the marquer", o1.NextNthMarquerST(2, :StartingAt = 14), "#3")
	Then("its position", o1.FindNextNthMarquerST(2, :StartingAt = 14), 44)
EndScenario()

Summary()
