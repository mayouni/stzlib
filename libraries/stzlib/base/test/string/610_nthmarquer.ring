load "../../stzBase.ring"
load "../_narrated.ring"

# The nth marquer and its position. Archive block #610.

Scenario("The second of four")
	o1 = new stzString("My name is #1, my age is #2, and my job is #3. Again: my name is #1!")
	Then("the marquer", o1.NthMarquer(2), "#2")
	Then("its position", o1.FindNthMarquer(2), 26)
EndScenario()

Summary()
